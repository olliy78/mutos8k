"""Guard of the byte-identical c2 source (Plan 52 W10l): without switch defines, c20.c and c21.c must give the same
preprocessed token stream as before the first c2x switch (userspace/c2/tokens.md5).  The c2x switches (XPUSH, XCMPMEM,
XHZERO) may only add code under #ifdef."""
import os
import shutil
import subprocess
import sys

import pytest

ROOT = os.path.join(os.path.dirname(__file__), "..")


@pytest.mark.skipif(shutil.which("cpp") is None, reason="host cpp missing")
def test_default_c2_token_identical():
    r = subprocess.run([sys.executable, "-I", os.path.join(ROOT, "tools", "userspace", "c2gegen.py"), "tokcheck"],
                       cwd=ROOT, capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
