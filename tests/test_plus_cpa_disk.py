"""Guard for the CP/A boot disk tool tools/plus/cpa_disk.py (plan 48 C2.4).

Fast: import, API present, exit 77 without emulator.
Guest (`gast`, ~2 min incl. the Workbench build; skip without emulator/Workbench/tool chain): kstart on the 4-floppy disk.
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

sys.path.insert(0, str(PROJECT_ROOT / "tools"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
CPA_DISK = PROJECT_ROOT / "tools" / "plus" / "cpa_disk.py"


def test_import_und_api():
    import cpa_disk
    for n in ("bootdiskette", "kstart", "original_kernel", "release_adr"):
        assert callable(getattr(cpa_disk, n))


def test_ohne_emulator_exit_77(tmp_path):
    env = dict(os.environ, K1520EMU="/nonexistent")
    for cmd in ("diskette", "kstart"):
        r = subprocess.run([sys.executable, "-I", str(CPA_DISK), cmd, "--arbeit", str(tmp_path)],
                           env=env, capture_output=True, text=True)
        assert r.returncode == 77, (cmd, r.stdout + r.stderr)


@pytest.mark.gast
def test_kstart(tmp_path):
    import cpa_disk
    arbeit = os.environ.get("MPLUS_ARBEIT") or str(tmp_path)
    try:
        ok, rep = cpa_disk.kstart(arbeit)
    except cpa_disk.Fehlt as e:
        pytest.skip(str(e))
    assert ok, "\n".join(rep)
