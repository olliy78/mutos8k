"""Guard for the c1 code table (tools/userspace/cvopt_z8k.py, userspace/c1/table.s; doc/userspace/wk_w6.md).

* table.s is 7-bit ASCII and `quelle` (image -> table.s) reproduces it; `pruefen` (table.s -> model bytes) equals the c1 image
  (needs userspace/c1/work/c1.raw from `pipeline.py holen c1`; skips without it);
* the PLZ/ASM output table_z8k.s is what `uebersetzen` writes from table.s (host only).
"""
import sys

import pytest

from conftest import PROJECT_ROOT

TOOLS = PROJECT_ROOT / "tools" / "userspace"
sys.path.insert(0, str(TOOLS))
import cvopt_z8k as C  # noqa: E402

C1 = PROJECT_ROOT / "userspace" / "c1"


def test_sources_are_ascii():
    for n in ("table.s", "table_z8k.s"):
        (C1 / n).read_bytes().decode("ascii")


def test_table_z8k_is_the_translation_of_table_s():
    assert C.uebersetzen((C1 / "table.s").read_text()) == (C1 / "table_z8k.s").read_text()


def test_table_matches_the_image():
    raw = C1 / "work" / "c1.raw"
    if not raw.is_file():
        pytest.skip("userspace/c1/work/c1.raw missing (pipeline.py holen c1)")
    img = raw.read_bytes()
    text = (C1 / "table.s").read_text()
    tb, db = C.abbild(text)
    assert tb == img[C.TEXT0:C.TEXT_END]
    assert db == img[C.DATA0:C.DATA0 + len(db)]
    assert C.quelle(img) == text
