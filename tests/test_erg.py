"""Guest tests of the V7 additions (plan 45 section 7): one test per userspace/ergaenzung/NAME/test.

The directories are found by themselves -- a program agent adds nothing here.  Marker `gast`: needs the emulator
project (skipped without it).  Each program is built in the guest (cc -O -s) and tests/befehle.sh is compared with
test/erwartet.txt (python3 -I tools/userspace/erg.py alles NAME).
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

ERG = PROJECT_ROOT / "tools" / "userspace" / "erg.py"
PROGRAMME = sorted(p.parent.name for p in (PROJECT_ROOT / "userspace" / "ergaenzung").glob("*/test")
                   if (p / "befehle.sh").is_file())


@pytest.mark.gast
@pytest.mark.parametrize("name", PROGRAMME)
def test_ergaenzung(name):
    r = subprocess.run([sys.executable, "-I", str(ERG), "alles", name], cwd=PROJECT_ROOT,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=1500,
                       env=dict(os.environ))
    if r.returncode == 77:
        pytest.skip("emulator missing")
    assert r.returncode == 0, r.stdout


def test_ergaenzung_ordner_vollstaendig():
    """Host-only: every program directory has source, erg.json and the complete test directory."""
    for p in (PROJECT_ROOT / "userspace" / "ergaenzung").iterdir():
        if not p.is_dir():
            continue
        assert (p / "erg.json").is_file(), p
        assert any(p.glob("*.c")), p
        for f in ("befehle.sh", "erwartet.txt", "herkunft.txt"):
            assert (p / "test" / f).is_file(), (p, f)
