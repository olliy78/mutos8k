"""Guard for tools/plus/cpa_lauf.py (plan 48 C5.1).

Fast: script = CP/A prelude + the marks of gastlauf.skript; exit 77 without emulator.
Guest (`gast`, ~5 min): probe (plan 47 P1.0 over CP/A).
"""
import os
import re
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

sys.path.insert(0, str(PROJECT_ROOT / "tools"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
CPA_LAUF = PROJECT_ROOT / "tools" / "plus" / "cpa_lauf.py"
BEFEHLE = ["cat a.txt >/tmp/a", ("wechsel", 1), "cat b.txt >/tmp/b", "ls /mnt >/tmp/l"]


def test_skript_vorspann_und_marken():
    import cpa_lauf
    import gastlauf
    sk, n = cpa_lauf.skript("/x", [{}, {}], BEFEHLE, 1000)
    sk0, n0 = gastlauf.skript("/x", [{}, {}], BEFEHLE, 1000)
    assert n == n0 == 5
    z = sk.splitlines()
    assert z.index('gscreen "A>" 300000000') < z.index("keys M8KBOOT\\r") < z.index('gscreen "ready (r)" 300000000')
    assert z.index('gscreen "ready (r)" 300000000') < z.index("eject A") < z.index("keys r") < z.index('gscreen "login:" 600000000')
    assert z.index('gscreen "login:" 600000000') < z.index("keys root\\r")
    for lw, img in (("A", "tmp"), ("B", "usr"), ("C", "root"), ("D", "d0")):
        assert "mount %s /x/%s.hfe" % (lw, img) in z
    assert "keys BOOT\\sMUTOS\\r" not in z
    # same markers as the UDOS script, same order
    marken = lambda t: re.findall(r'gscreen "(END\w*)"', t)
    assert marken(sk) == marken(sk0) and len(marken(sk)) == 6
    assert z[-1] == "q"


def test_ohne_emulator_exit_77(tmp_path):
    env = dict(os.environ, K1520EMU="/nonexistent")
    for cmd in ("probe", "boot"):
        r = subprocess.run([sys.executable, "-I", str(CPA_LAUF), cmd, "--arbeit", str(tmp_path)],
                           env=env, capture_output=True, text=True)
        assert r.returncode == 77, (cmd, r.stdout + r.stderr)


@pytest.mark.gast
def test_probe(tmp_path):
    import cpa_lauf
    arbeit = os.environ.get("MPLUS_ARBEIT") or str(tmp_path)
    try:
        rc = cpa_lauf.probe(arbeit)
    except cpa_lauf.Fehlt as e:
        pytest.skip(str(e))
    assert rc == 0
