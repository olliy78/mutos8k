"""Guard for tools/plus/cpa_system.py (plan 48 C2.2).

Fast: konfig.txt readable, SHA-1 constant, Exit 77 without Workbench/emulator.  Guest (`gast`, ~3 min): `pruefen`.
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

SYS = PROJECT_ROOT / "tools" / "plus" / "cpa_system.py"
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
import cpa_system  # noqa: E402


def test_konfig_lesbar():
    k = cpa_system.konfig()
    assert k["CONFIG_SYSTEM_ANZDISK"] == "4"
    assert k["CONFIG_SYSTEM_CRT_K7024"] == "y"
    assert k["CONFIG_SYSTEM_CRT_BWSHP"] is None


def test_sha1_konstante():
    assert len(cpa_system.OS_SHA1) == 40 and int(cpa_system.OS_SHA1, 16) >= 0
    assert cpa_system.OS_SHA1.startswith("97bbdca9")


def test_ohne_emulator_exit_77():
    env = dict(os.environ, K1520EMU="/nonexistent")
    r = subprocess.run([sys.executable, "-I", str(SYS), "pruefen", "--arbeit", "/tmp/mplus/nirgends"],
                       env=env, capture_output=True, text=True)
    assert r.returncode == 77, r.stdout + r.stderr


@pytest.mark.gast
def test_pruefen(tmp_path):
    try:
        ok, rep = cpa_system.pruefen(str(tmp_path))
    except cpa_system.Fehlt:
        pytest.skip("Workbench, emulator or tool chain missing")
    assert ok, "\n".join(rep)
