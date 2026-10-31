"""Source text rules for kernel/{c,h,conf} (AP H4).  No emulator needed.

The MUTOS guest tools are 7-bit and old:
  * only /* */ comments (the guest cc does not know //),
  * comments do not nest: a comment (also commented-out original text) must not contain /* ,
  * every comment is closed,
  * 7-bit ASCII only (no umlauts, no typographic quotes).
"""
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
DIRS = [ROOT / "kernel" / "c", ROOT / "kernel" / "h", ROOT / "kernel" / "conf"]
# kernel/c/varianten holds throw-away experiments for the c2 analysis (not part of the build): not checked.
SKIP_DIRS = {"varianten"}


def sources():
    out = []
    for d in DIRS:
        for p in sorted(d.rglob("*")):
            if p.suffix in (".c", ".h") and not (SKIP_DIRS & set(p.relative_to(d).parts)):
                out.append(p)
    return out


def check_text(text):
    """Return a list of (line, message) for the comment rules; strings and character constants are skipped."""
    errs = []
    i, n, line = 0, len(text), 1
    comment_start = None
    while i < n:
        c = text[i]
        two = text[i:i + 2]
        if comment_start is not None:
            if two == "*/":
                comment_start = None
                i += 2
                continue
            if two == "/*":
                errs.append((line, "'/*' inside a comment (comments do not nest)"))
                i += 2
                continue
            if c == "\n":
                line += 1
            i += 1
            continue
        if two == "/*":
            comment_start = line
            i += 2
            continue
        if two == "*/":
            errs.append((line, "'*/' outside a comment (an earlier '*/' inside a comment closed it too early)"))
            i += 2
            continue
        if two == "//":
            errs.append((line, "'//' comment (the guest cc does not know it)"))
            while i < n and text[i] != "\n":
                i += 1
            continue
        if c in "\"'":
            q = c
            i += 1
            while i < n and text[i] != q and text[i] != "\n":
                i += 2 if text[i] == "\\" else 1
            i += 1
            continue
        if c == "\n":
            line += 1
        i += 1
    if comment_start is not None:
        errs.append((comment_start, "comment not closed"))
    return errs


def test_scanner_finds_violations():
    assert check_text("int a; /* ok */ char *s = \"/* not a comment */\"; char c = '\"';") == []
    assert [m for _, m in check_text("/* a /* b */")] == ["'/*' inside a comment (comments do not nest)"]
    assert [m for _, m in check_text("int a; // x\n")][0].startswith("'//'")
    assert [m for _, m in check_text("/* open\n")] == ["comment not closed"]
    assert check_text("a = b; /* x\n y */ c;\n")[:1] == []
    assert [m[:5] for _, m in check_text("/* dk_*/tk_* x */")] == ["'*/' "]


def test_sources_found():
    assert len(sources()) >= 40


@pytest.mark.parametrize("path", sources(), ids=lambda p: str(p.relative_to(ROOT)))
def test_comment_rules(path):
    errs = check_text(path.read_text(encoding="latin-1"))
    assert not errs, "%s: %s" % (path.relative_to(ROOT), "; ".join("line %d: %s" % e for e in errs[:5]))


@pytest.mark.parametrize("path", sources(), ids=lambda p: str(p.relative_to(ROOT)))
def test_ascii_only(path):
    data = path.read_bytes()
    bad = [(data[:k].count(b"\n") + 1, hex(b)) for k, b in enumerate(data) if b > 127 or (b < 32 and b not in (9, 10))]
    assert not bad, "%s: non-ASCII or control byte at %s" % (path.relative_to(ROOT), bad[:5])
