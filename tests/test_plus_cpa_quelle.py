"""Guard for mutos_io/cpa (plan 48 C2.1).

Fast: sources ASCII, checked-in bin equals mutos_io/mutosio.bin, exit 77 without emulator.
Guest (`gast`, seconds): `build.py --check` -> 0, `abbild()` places the segments correctly.
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


def test_bin_gleich_original():
    assert (CPA / "mutoscpa.bin").read_bytes() == (PROJECT_ROOT / "mutos_io" / "mutosio.bin").read_bytes()


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
    assert len(img) == 0xC968 - 0x9000
    f = (CPA / "mutoscpa.bin").read_bytes()
    off = 0
    for a, n in [(0x9000, 0x22D), (0x9400, 0xEB0), (0xA400, 0x1A8), (0xC8B6, 0xB2)]:
        assert img[a - 0x9000:a - 0x9000 + n] == f[off:off + n], hex(a)
        off += (n + 0xFF) & ~0xFF
    assert off == len(f)
