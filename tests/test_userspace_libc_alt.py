"""Guard for tools/userspace/libc_alt.py (rebuilt libc of the original programs, doc/userspace/libc_alt.md).

* pure parts (members file parser, relocation model, archive writer) run everywhere;
* `gast`: sources from z8kdis (host only, seconds) -- every member source must be produced without error;
* `gast` + USERSPACE_GAST=1: the guest round trip (`as -u` of every member source, minutes of wall clock):
  object -> relocated like ld -> bytes == the member of the original /etc/init.
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

TOOLS = PROJECT_ROOT / "tools" / "userspace"
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "kernel"))
sys.path.insert(0, str(TOOLS))
import libc_alt as L   # noqa: E402
import objformat as O  # noqa: E402

LIBC_ALT = TOOLS / "libc_alt.py"


def test_members_file_parser(tmp_path):
    p = tmp_path / "x.members"
    p.write_text("# c\nprintf 065E 068E\ndoprnt 068E 0866 data=1274:12BE exp=__doprnt@068E code=07B6\n"
                 "bss1 0000 0002 bss=1C4E:C new exp=_x@0000\ncommon __sibuf 184C 200 data\nextern _end 1C86 0\n")
    ms, com, ext = L.parse(str(p))
    assert [m.name for m in ms] == ["printf", "doprnt", "bss1"]
    assert ms[1].data == (0x1274, 0x12BE) and ms[1].exp == {"__doprnt": 0x68E} and ms[1].code == [0x7B6]
    assert ms[2].bss == (0x1C4E, 12) and ms[2].neu
    assert com == [("__sibuf", 0x184C, 0x200, "data")] and ext == [("_end", 0x1C86, 0)]


def test_relocation_model_and_archive():
    o = O.Objekt()
    o.text = bytes.fromhex("5f000000" "5e080002" "6102" "0010")          # call ext; jp text+2; ld r2,bss; word data
    o.bss = 4
    o.data = b"\0\0"
    o.syms = [O.Symbol(b"_foo", 0x20, 0, 0)]
    o.rtext = [0, 0x0008 | 0, 0, (1 << 1), 0, (3 << 1), 0, (2 << 1)][:len(o.text) // 2]
    o.rtext = [0, (0 << 4) | (4 << 1), 0, (1 << 1), 0, (3 << 1)]
    o.rtext = o.rtext + [0] * (len(o.text) // 2 - len(o.rtext))
    o.rdata = [0]
    o.rtext[1] = (0 << 4) | (4 << 1)            # word 1: external symbol 0
    m = L.Mitglied("x")
    m.t0, m.data, m.bss = 0x100, (0x200, 0x202), (0x300, 4)
    t, d = L.relozieren(m, o, [(0x1234, "_foo", "T", None)])
    w = L.worte(t)
    assert w[1] == 0x1234 and w[3] == 0x0002 + 0x100
    a = L.archiv_bauen([("x", o.schreiben())])
    assert O.Archiv.lesen(a).mitglieder[0].name == b"x.o"


@pytest.mark.gast
def test_sources_from_z8kdis():
    pytest.importorskip("libc_alt")
    pl = PROJECT_ROOT / "userspace" / "init" / "work" / "init.raw"
    if not pl.exists():
        r = subprocess.run([sys.executable, "-I", str(TOOLS / "pipeline.py"), "holen", "init"], capture_output=True,
                           text=True, timeout=300)
        if r.returncode == 77:
            pytest.skip("emulator or disk missing")
        assert r.returncode == 0, r.stdout + r.stderr
    r = subprocess.run([sys.executable, "-I", str(LIBC_ALT), "quelle", "init"], capture_output=True, text=True, timeout=600)
    if r.returncode == 77:
        pytest.skip("emulator or disk missing")
    assert r.returncode == 0 and "ERROR" not in r.stderr, r.stdout + r.stderr


@pytest.mark.gast
@pytest.mark.skipif(not os.environ.get("USERSPACE_GAST"), reason="guest run takes minutes: set USERSPACE_GAST=1")
def test_guest_roundtrip_members_equal_original():
    r = subprocess.run([sys.executable, "-I", str(LIBC_ALT), "bau", "init"], capture_output=True, text=True, timeout=7200)
    if r.returncode == 77:
        pytest.skip("emulator or disk missing")
    assert "NO OBJECT" not in r.stdout, r.stdout
    assert r.returncode == 0, r.stdout + r.stderr
