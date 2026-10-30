"""Tests for tools/herkunft/herkunft.py (provenance comparison).  No emulator needed."""
import importlib.util
import re
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools" / "herkunft" / "herkunft.py"
V7SYS = ROOT / "original" / "unix-v7" / "usr" / "sys" / "sys"
V7DEV = ROOT / "original" / "unix-v7" / "usr" / "sys" / "dev"

spec = importlib.util.spec_from_file_location("herkunft", TOOL)
hk = importlib.util.module_from_spec(spec)
sys.modules["herkunft"] = hk
spec.loader.exec_module(hk)

needs_v7 = pytest.mark.skipif(not (V7SYS / "alloc.c").is_file(), reason="original/unix-v7 not present")

SAMPLE = r'''
#include "param.h"
#define NX 10		/* comment */
int tab[NX] = { 1, 2, 3 };
struct foo { int a; char *b; };
char *msg = "has /* not a comment */ inside";

/* KERNEL 1234 */
int
add(a, b)
register int a;
char *b;
{
	register int i;
	struct foo *fp;

	i = a + 1;	/* tail */
	if (i > 0)
		printf("x %d\n", i);
	return(i);
}

sub(x)
{
	{ int q; q = x; return(q); }
}
int decl(), other();
'''


def test_tokenizer_comments_strings_pp():
    toks, markers = hk.tokenize(SAMPLE)
    texts = [t.text for t in toks]
    assert markers == [(8, "1234")]
    assert '"has /* not a comment */ inside"' in texts  # strings preserved
    assert "comment" not in texts and "tail" not in texts
    assert "include" not in texts  # #include dropped
    assert any(t.pp and t.text == "define" for t in toks)


def test_function_extraction_kr():
    toks, markers = hk.tokenize(SAMPLE)
    funcs, rest = hk.split_file(toks, markers, "s.c")
    assert [f.name for f in funcs] == ["add", "sub"]  # `int decl(), other();` is no function
    assert funcs[0].marker == "1234"
    assert funcs[0].params == ["a", "b"]
    assert funcs[0].body[0].text == "{" and funcs[0].body[-1].text == "}"
    assert "tab" in [t.text for t in rest]  # initializer and struct body are not functions


def test_abstraction_levels():
    toks, markers = hk.tokenize(SAMPLE)
    f = hk.split_file(toks, markers)[0][0]
    names = hk.norm_function(f, "names")
    assert "i" in names and "register" in names
    ab = hk.norm_function(f, "abs")
    assert "i" not in ab and "register" not in ab and "NUM" in ab
    assert "printf" in ab  # calls kept on abs
    assert "printf" not in hk.norm_function(f, "strict")
    assert '"x %d\\n"' in ab  # strings kept


def test_winnow_basics():
    toks = list("abcdefghijklmnop")
    h = hk.kgram_hashes(toks, 3)
    assert len(h) == 14
    fp = hk.winnow(h, 4)
    assert fp and all(isinstance(x, tuple) for x in fp)
    assert len(fp) < len(h)
    # guarantee: any window of w hashes contains a selected one
    pos = [p for _, p in fp]
    for s in range(len(h) - 4 + 1):
        assert any(s <= p < s + 4 for p in pos)
    assert hk.winnow([], 4) == []
    assert hk.kgram_hashes(["x"], 5)  # shorter than k -> one gram


def test_similarity_measures():
    a, b = frozenset({1, 2, 3, 4}), frozenset({3, 4, 5, 6, 7, 8, 9, 10})
    s = hk.similarity(a, b)
    assert s["c_ab"] == 0.5 and s["c_ba"] == 0.25
    assert s["jac"] == pytest.approx(2 / 10)
    assert hk.similarity(a, a)["sim"] == 1.0


@needs_v7
def test_self_similarity_is_100_percent():
    src = hk.Source(V7SYS / "alloc.c")
    assert len(src.funcs) >= 7
    for lv in hk.LEVELS:
        assert hk.similarity(src.fp(lv), src.fp(lv))["sim"] == 1.0
    ref = hk.RefTree("v7", [V7SYS])
    for f in src.funcs:
        m = ref.best_function(src, f, "abs")
        assert m["sim"] == 1.0 and m["name_equal"]


@needs_v7
def test_renamed_variant_is_high():
    text = (V7SYS / "alloc.c").read_bytes().decode("latin-1")
    # rename locals/params and change constants and register/int widths
    for old, new in [("bp", "xbuf"), ("fp", "xfs"), ("bno", "blkno"), ("ip", "xip"), ("dev", "xd"),
                     ("register ", ""), ("int ", "long ")]:
        text = re.sub(r"\b%s" % re.escape(old) if old[-1] != " " else re.escape(old), new, text)
    var = hk.Source("variant.c", text=text)
    ref = hk.Source(V7SYS / "alloc.c")
    a = hk.similarity(var.fp("abs"), ref.fp("abs"))
    assert a["sim"] > 0.75
    # abstracted level sees through the renaming better than the name level
    assert a["sim"] > hk.similarity(var.fp("names"), ref.fp("names"))["sim"]


@needs_v7
def test_foreign_file_is_low():
    a = hk.Source(V7SYS / "alloc.c")
    b = hk.Source(V7DEV / "tty.c")
    assert hk.similarity(a.fp("abs"), b.fp("abs"))["sim"] < 0.2


@needs_v7
def test_cli_compare_runs():
    out = subprocess.run([sys.executable, "-I", str(TOOL), "compare", str(V7SYS / "alloc.c"),
                          "--ref", "v7=%s" % V7SYS], capture_output=True, text=True, check=True).stdout
    assert "100%" in out and "alloc" in out


def test_cli_sysent_parse(tmp_path):
    p = tmp_path / "s.c"
    p.write_text("struct sysent sysent[3] = {\n { 0, nullsys },\n { 1, rexit },\n { 0, fork },\n};\n")
    q = tmp_path / "v.c"
    q.write_text("struct sysent sysent[] =\n{\n 0, 0, nosys,\n 1, 1, rexit,\n 0, 0, fork\n};\n")
    assert hk.parse_sysent(p) == [(0, "nullsys"), (1, "rexit"), (0, "fork")]
    assert hk.parse_sysent(q) == [(0, "nosys"), (1, "rexit"), (0, "fork")]
