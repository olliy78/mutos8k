"""Guard for tools/plus/cpa.py (plan 48 C1.1).

Fast: import, helpers, Exit-77 behaviour without the emulator.  Guest (`gast`, seconds): `cpa.py probe`.
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

CPA = PROJECT_ROOT / "tools" / "plus" / "cpa.py"
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
import cpa  # noqa: E402


def test_import_und_schnittstelle():
    for n in ("diskette", "com", "lauf", "cmd", "taste", "schirm", "schirme", "probe", "fehlt", "Fehlt"):
        assert hasattr(cpa, n), n


def test_schirm_zieht_den_letzten_block():
    log = "(dbg) screen\n  |A>X      |\n  |         |\n(dbg) keys A\n(dbg) screen\n  |A>HALLO  |\n(dbg) q\n"
    assert len(cpa.schirme(log)) == 2
    assert cpa.schirm(log) == "A>HALLO"
    assert cpa.schirm("nothing") == ""


def test_cmd_maskiert_leerzeichen_und_haengt_cr_an():
    assert cpa.cmd("DIR B:")[1] == "DIR\\sB:\\r"
    assert cpa.taste()[1] == "\\s"


def test_ohne_emulator_exit_77():
    env = dict(os.environ, K1520EMU="/nonexistent")
    r = subprocess.run([sys.executable, "-I", str(CPA), "probe", "--arbeit", "/tmp/mplus/nirgends"],
                       env=env, capture_output=True, text=True)
    assert r.returncode == 77, r.stdout + r.stderr


@pytest.mark.gast
def test_probe(tmp_path):
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    ok, rep = cpa.probe(str(tmp_path))
    assert ok, "\n".join(rep)
