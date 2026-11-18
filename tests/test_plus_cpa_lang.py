"""Long guard for the CP/A start chain (plan 48 C5.2, `doc/plus/cpa.md`).

Only with K1520_PLUS=1 (guest in the emulator, ~3 min wall clock, start in the background):
    K1520_PLUS=1 python3 -m pytest -q tests/test_plus_cpa_lang.py
Builds the 4-floppy boot disk with the ORIGINAL kernel (cpa_disk), boots it over M8KBOOT and runs the
work tests b1..b11, pp, pi, pf (cpa_lauf.boot); `bewerten` must find no failure.
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

CPA_LAUF = PROJECT_ROOT / "tools" / "plus" / "cpa_lauf.py"


@pytest.mark.gast
@pytest.mark.skipif(os.environ.get("K1520_PLUS") != "1", reason="long guest run (K1520_PLUS=1)")
def test_lang_arbeitstests_ueber_cpa(tmp_path):
    arbeit = os.environ.get("MPLUS_ARBEIT") or str(tmp_path)
    r = subprocess.run([sys.executable, "-I", str(CPA_LAUF), "boot", "--arbeit", arbeit],
                       cwd=str(PROJECT_ROOT), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    out = r.stdout.decode("latin-1")
    if r.returncode == 77:
        pytest.skip("emulator or tool chain missing")
    assert r.returncode == 0, out[-4000:]
    assert "bewerten: no failure" in out, out[-4000:]
    assert "FAILURE" not in out, out[-4000:]
