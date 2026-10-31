"""Tests for the H6 counter-check tools (tools/herkunft/{devdiff,traits,ifdef_resolve,tables,v7dump}.py).

Everything runs on small synthetic sources; the large TUHS trees are not needed.
"""
import importlib.util
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools" / "herkunft"
sys.path.insert(0, str(TOOLS))


def load(name):
    spec = importlib.util.spec_from_file_location(name, TOOLS / (name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


dd = load("devdiff")
tr = load("traits")
ir = load("ifdef_resolve")
tb = load("tables")
vd = load("v7dump")

V7_SEEK = """
seek()
{
	register struct file *fp;
	register struct a { int fdes; off_t off; int sbase; } *uap;
	uap = (struct a *)u.u_ap;
	fp = getf(uap->fdes);
	if(fp == NULL)
		return;
	u.u_r.r_off = uap->off;
}
"""
HIPPE_SEEK = V7_SEEK.replace("	u.u_r.r_off", "	if(uap->off < 0) {\n		u.u_error = EINVAL;\n		uap->off = 0;\n	}\n	u.u_r.r_off")
# MUTOS: Hippe text with renamed local (locals are normalised away)
MUTOS_SEEK = HIPPE_SEEK.replace("fp", "f")


def write(p, text):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text)
    return p


def test_devdiff_classifies_hunks(tmp_path):
    m = write(tmp_path / "m" / "sys2.c", MUTOS_SEEK)
    write(tmp_path / "h" / "sys2.c", HIPPE_SEEK)
    write(tmp_path / "v" / "sys2.c", V7_SEEK)
    res = dd.analyse([str(m)], dd.load_tree("hippe=%s" % (tmp_path / "h")), [dd.load_tree("v7=%s" % (tmp_path / "v"))],
                     [], {}, 0.6)
    r = res[0]
    assert r["status"] == "ok" and r["hunks"] == []  # MUTOS == Hippe up to local names

    # MUTOS = V7 (no off<0 test) while Hippe has the test: the hunk is H_OTHER (V7 has the other side)
    m2 = write(tmp_path / "m2" / "sys2.c", V7_SEEK)
    r = dd.analyse([str(m2)], dd.load_tree("hippe=%s" % (tmp_path / "h")), [dd.load_tree("v7=%s" % (tmp_path / "v"))],
                   [], {}, 0.6)[0]
    assert len(r["hunks"]) == 1
    h = r["hunks"][0]
    assert h["verdict"] == "H_ONLY" and h["M"] == [] and any("EINVAL" in s for s in h["H"])


def test_devdiff_novel_statements(tmp_path):
    m = write(tmp_path / "m" / "sys2.c", MUTOS_SEEK)
    write(tmp_path / "h" / "sys2.c", HIPPE_SEEK)
    write(tmp_path / "v" / "sys2.c", V7_SEEK)
    r = dd.analyse([str(m)], dd.load_tree("hippe=%s" % (tmp_path / "h")), [dd.load_tree("v7=%s" % (tmp_path / "v"))],
                   [], {}, 0.6, base="v7")[0]
    # the three statements of the off<0 block are not in V7 but in Hippe
    assert len(r["novel"]) >= 2 and all(n["in"] == ["hippe"] for n in r["novel"])
    assert all(n["in_mutos"] for n in r["subj_novel"])


def test_traits_scan(tmp_path):
    write(tmp_path / "t" / "sys" / "sys2.c", HIPPE_SEEK)
    write(tmp_path / "t" / "sys" / "malloc.c", 'mfree(){ if (x > MAPSIZ) panic("map overflow"); }')
    write(tmp_path / "t" / "h" / "param.h", "#define NPROC 30\n#define MAPSIZ (NPROC/2)\n")
    counts, files = tr.scan(str(tmp_path / "t"))
    assert files == 3
    assert counts["T01"] == 1 and counts["T02"] == 1 and counts["T13"] == 1 and counts["T15"] == 1
    assert counts["T03"] == 0 and counts["T16"] == 0


def test_ifdef_resolve():
    src = ["a", "#ifdef X", "b", "#else", "c", "#endif", "#ifndef Y", "d", "#endif", "#ifdef Z", "e", "#ifdef X", "f", "#endif", "#endif"]
    assert ir.resolve(src, {"X"}) == ["a", "b", "d"]
    out = ir.resolve(src, {"X", "Z"})
    assert out == ["a", "b", "d", "e", "f"]
    assert ir.resolve(src, set()) == ["a", "c", "d"]


def test_tables_parse(tmp_path):
    p = write(tmp_path / "tty.c", "char maptab[] = { 000, 'a', 0200+'b', 010 };\nchar cchars[] = { 1, 2 };\n")
    assert tb.parse(str(p), "maptab") == [0, 97, 0x80 + 98, 8]
    assert tb.parse(str(p), "wchars") is None


def _dump_header(typ, ino, mode, size, cnt, addr):
    h = bytearray(512)
    struct.pack_into("<h", h, 0, typ)
    struct.pack_into("<H", h, 16, ino)
    struct.pack_into("<h", h, 18, vd.MAGIC - 65536)
    struct.pack_into("<H", h, 22, mode)
    struct.pack_into("<HH", h, 30, size >> 16, size & 0xFFFF)
    struct.pack_into("<h", h, 86, cnt)
    h[88:88 + len(addr)] = bytes(addr)
    return bytes(h)


def test_v7dump_roundtrip(tmp_path):
    # root directory (inode 2) with one entry "f" -> inode 3 (a 5 byte file)
    dirent = struct.pack("<H", 3) + b"f".ljust(14, b"\0")
    dirdata = (struct.pack("<H", 2) + b".".ljust(14, b"\0") + dirent).ljust(512, b"\0")
    img = bytearray()
    img += _dump_header(vd.TS_TAPE, 0, 0, 0, 0, [])
    img += _dump_header(vd.TS_INODE, 2, 0o040755, 48, 1, [1]) + dirdata
    img += _dump_header(vd.TS_INODE, 3, 0o100644, 5, 1, [1]) + b"hello".ljust(512, b"\0")
    img += _dump_header(vd.TS_END, 0, 0, 0, 0, [])
    n = vd.extract(bytes(img), str(tmp_path / "out"))
    assert n == 1
    assert (tmp_path / "out" / "f").read_bytes() == b"hello"
