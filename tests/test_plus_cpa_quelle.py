"""Guard for mutos_io/cpa (plan 48 C2.1, switched in C3.2).

Fast: sources ASCII, checked-in bin is a whole number of 100H segment pages, exit 77 without emulator.
Guest (`gast`, seconds): `build.py --check` -> 0 (source -> mutoscpa.bin of the current state),
`abbild()` places the segments correctly.
Since C3.2 mutoscpa.bin is deliberately NOT identical to mutos_io/mutosio.bin any more; the comparison with the
UDOS version stays with the UDOS source (tests/test_waechter.py: mutos_io/build.py --check == mutosio.bin).
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

CPA = PROJECT_ROOT / "mutos_io" / "cpa"
sys.path.insert(0, str(PROJECT_ROOT / "tools"))
import emu  # noqa: E402


def test_quellen_ascii():
    for f in (CPA / "src").glob("*.mac"):
        f.read_bytes().decode("ascii")


def test_bin_seitenweise():
    """UDOS file layout: every segment rounded up to 100H (build.bild); the bin differs from mutosio.bin since C3.2."""
    f = (CPA / "mutoscpa.bin").read_bytes()
    assert len(f) % 0x100 == 0 and f != (PROJECT_ROOT / "mutos_io" / "mutosio.bin").read_bytes()


def test_ohne_emulator_exit_77():
    env = dict(os.environ, K1520EMU="/nonexistent")
    r = subprocess.run([sys.executable, "-I", str(CPA / "build.py"), "--check"],
                       env=env, capture_output=True, text=True)
    assert r.returncode == 77, r.stdout + r.stderr


@pytest.mark.gast
def test_check_und_abbild():
    if emu.fehlt():
        pytest.skip("no emulator")
    r = subprocess.run([sys.executable, "-I", str(CPA / "build.py"), "--check"], capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    sys.path.insert(0, str(CPA))
    import importlib
    b = importlib.import_module("build")
    img = b.abbild()
    sys.path.insert(0, str(PROJECT_ROOT / "mutos_io"))
    import ladediskette
    daten, segs = ladediskette.baue(quelle=str(CPA / "src" / "mutoscpa.mac"))
    assert [a for a, _ in segs] == [0x9000, 0x9400, 0xA400, 0xC8B6]
    for (a, n), (nxt, _) in zip(segs, segs[1:]):
        assert a + n <= nxt, "segment %04X overlaps the next one" % a
    assert len(img) == segs[-1][0] + segs[-1][1] - 0x9000
    f = (CPA / "mutoscpa.bin").read_bytes()
    assert f == daten
    off = 0
    for a, n in segs:
        assert img[a - 0x9000:a - 0x9000 + n] == f[off:off + n], hex(a)
        off += (n + 0xFF) & ~0xFF
    assert off == len(f)
