"""Fast guards for the repo itself: tools import/--help, ASCII-only code, mutos_io round trip."""
import os
import re
import subprocess
import sys

import pytest

import emu
from conftest import PROJECT_ROOT

CODE_EXT = {".py", ".c", ".h", ".s", ".mac", ".sh", ".dbg"}
CODE_DIRS = ["tools", "mutos_io", "userspace", "versuche", "kernel", "tests"]


def _files(exts, dirs):
    for d in dirs:
        for root, _, names in os.walk(PROJECT_ROOT / d):
            for n in names:
                if os.path.splitext(n)[1] in exts:
                    yield os.path.join(root, n)


def test_no_non_ascii_in_code():
    bad = []
    for p in _files(CODE_EXT, CODE_DIRS):
        data = open(p, "rb").read()
        if re.search(rb"[\x80-\xff]", data):
            bad.append(os.path.relpath(p, PROJECT_ROOT))
    assert not bad, "non-ASCII characters in code: %s" % bad


def test_python_tools_compile():
    import py_compile
    for p in _files({".py"}, ["tools", "mutos_io"]):
        py_compile.compile(p, doraise=True)


# scripts that have an argparse interface and must answer --help without touching the emulator
HELP_SCRIPTS = ["tools/disks/bau_alle.py", "tools/disks/bau_aus_archiv.py", "tools/disks/bau_8x512.py",
                "tools/disks/bau_ladediskette.py", "tools/disks/bau_wurzel.py", "tools/disks/archiv_erzeugen.py",
                "tools/disks/best_of.py", "tools/disks/mutos_patch.py", "tools/disks/m8kroot_lesen.py",
                "tools/kernel/gesamtbau.py", "tools/kernel/linkbau.py", "tools/kernel/rundlauf_gast.py"]


@pytest.mark.parametrize("script", HELP_SCRIPTS)
def test_script_help(script):
    r = subprocess.run([sys.executable, "-I", str(PROJECT_ROOT / script), "--help"],
                       capture_output=True, text=True, timeout=60)
    assert r.returncode == 0, r.stdout + r.stderr


def test_emulator_lookup_consistent():
    assert emu.repo() == str(PROJECT_ROOT)
    assert emu.fehlt() == (emu.emulator() is None)


def test_mutos_io_roundtrip():
    """mutos_io/build.py --check: M80 build of the U880 source == committed mutosio.bin (77 = no toolchain)."""
    if emu.fehlt():
        pytest.skip("emulator project not found")
    r = subprocess.run([sys.executable, "-I", str(PROJECT_ROOT / "mutos_io" / "build.py"), "--check"],
                       capture_output=True, text=True, timeout=600)
    if r.returncode == emu.SKIP:
        pytest.skip("CP/M toolchain missing")
    assert r.returncode == 0, r.stdout[-2000:] + r.stderr[-2000:]
