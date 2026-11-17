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


def test_v7erg_bauangaben_verteilen_jedes_programm_einmal():
    """Host-only (plan 45 E6): tools/disks/bauangaben_v7erg{1,2}.yaml name every program directory exactly once
    (diffh as /v7/lib/diffh), and every lib file of erg.json exists in erg.LIBDATEIEN."""
    import json
    sys.path.insert(0, str(PROJECT_ROOT / "tools" / "userspace"))
    import erg
    gelistet = []
    for n in "12":
        for z in (PROJECT_ROOT / "tools" / "disks" / ("bauangaben_v7erg%s.yaml" % n)).read_text().splitlines():
            if z.startswith("bin:"):
                gelistet += z[4:].split()
            if z.startswith("lib:"):
                gelistet += [l for l in z[4:].split() if l == "diffh"]
    ordner = sorted(p.name for p in (PROJECT_ROOT / "userspace" / "ergaenzung").iterdir() if p.is_dir())
    assert sorted(gelistet) == ordner
    for p in (PROJECT_ROOT / "userspace" / "ergaenzung").glob("*/erg.json"):
        for l in json.loads(p.read_text()).get("lib", []):
            assert l in erg.LIBDATEIEN, (p, l)


@pytest.mark.gast
def test_v7erg_abnahme():
    """Plan 45 E6: mount v7erg1/v7erg2 (disks/gebaut, made by bau_alle.py --v7erg) at /v7 and compare the short calls."""
    r = subprocess.run([sys.executable, "-I", str(PROJECT_ROOT / "tools" / "userspace" / "erg_abnahme.py")], cwd=PROJECT_ROOT,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=1500, env=dict(os.environ))
    if r.returncode == 77:
        pytest.skip("emulator or v7erg disks missing")
    assert r.returncode == 0, r.stdout
