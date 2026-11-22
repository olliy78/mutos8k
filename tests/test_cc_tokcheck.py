"""Guard of the byte-identical cc source (Plan 52 W10r): without -DXCC, cc.c gives the same preprocessed token stream as
before the xcc code (userspace/cc/tokens.md5); with -DXCC it must differ (the xcc code exists)."""
import os
import shutil
import subprocess
import sys

import pytest

ROOT = os.path.join(os.path.dirname(__file__), "..")


@pytest.mark.skipif(shutil.which("cpp") is None, reason="host cpp missing")
def test_default_cc_token_identical():
    r = subprocess.run([sys.executable, "-I", os.path.join(ROOT, "tools", "userspace", "xcc.py"), "tokcheck"],
                       cwd=ROOT, capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
