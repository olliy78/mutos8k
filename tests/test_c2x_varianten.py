"""c2x variants per rule group (Plan 52 W10aj), host checks without the guest:
(1) every program is assigned the variant whose rule group holds all of its -x letters (nothing is built with a letter the variant refuses),
(2) the preprocessed source of each variant contains a group's code exactly when the variant has the group,
(3) the refusal of foreign group letters (xdeny) is in the source for exactly the letters of the missing groups."""
import os
import re
import shutil
import subprocess
import sys

import pytest

ROOT = os.path.join(os.path.dirname(__file__), "..")
sys.path.insert(0, os.path.join(ROOT, "tools", "userspace"))

pytestmark = pytest.mark.skipif(shutil.which("cpp") is None, reason="host cpp missing")

C2DIR = os.path.join(ROOT, "userspace", "c2")


def _g():
    import c2gegen
    return c2gegen


def _cpp(defs):
    cmd = ["cpp", "-P", "-I" + C2DIR] + ["-D" + d for d in defs] + [os.path.join(C2DIR, "c20.c")]
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout


def test_program_gets_variant_with_its_letters():
    import pipeline
    import xcc
    g = _g()
    alle = "".join(g.GRUPPENBUCHSTABEN.values())
    for n in pipeline.PROGRAMME:
        v = g.c2x_variante(n)
        assert v in g.VARIANTEN
        fl = g.c2x_flags(n, xcc.REGELN, ("R3",))
        fremd = set(fl) & set(alle) - set(g.variante_erlaubt(v))
        assert not fremd, (n, v, fremd)
    # the three group programs get their own variants, everything else the base variant
    assert (g.c2x_variante("ld"), g.c2x_variante("cc"), g.c2x_variante("c0"), g.c2x_variante("as"), g.c2x_variante("convert")) == ("c2xld", "c2xcc", "c2xc0", "c2x", "c2xcv")
    # ... and each of them really uses its group letters (otherwise the variant would be pointless)
    assert set("fhij") <= set(g.c2x_flags("ld", xcc.REGELN, ("R3",)))
    assert "y" in g.c2x_flags("cc", xcc.REGELN, ("R3",))
    assert set("bl") <= set(g.c2x_flags("c0", xcc.REGELN, ("R3",)))
    assert "V" in g.c2x_flags("convert", xcc.REGELN, ("R3",))      # W10ak: R72-R76 only for convert
    assert not any("V" in g.c2x_flags(n, xcc.REGELN, ("R3",)) for n in pipeline.PROGRAMME if n != "convert")


def test_variant_source_has_group_code_only_when_selected():
    g = _g()
    marken = {"C2X_LD": '"rh3,rh3"', "C2X_CC": "xccpass()", "C2X_C0": '"r2,#%16"', "C2X_CV": "xcvpass()"}   # a text only the group's code contains
    for v, defs in g.VARIANTEN.items():
        t = _cpp(defs)
        for grp, m in marken.items():
            assert (m in t) == (grp in defs), (v, grp)
        fehlt = [x for x in marken if x not in defs]
        assert ("xdeny(c)" in t) == bool(fehlt), v


def test_deny_letters_match_missing_groups():
    g = _g()
    for v, defs in g.VARIANTEN.items():
        t = _cpp(defs)
        verlangt = "".join(g.GRUPPENBUCHSTABEN[x] for x in g.GRUPPENBUCHSTABEN if x not in defs)
        gef = "".join(re.findall(r"c == '(\w)'", "".join(re.findall(r"if \(c == '\w'[^)]*\)\s*xdeny\(c\);", t))))
        assert sorted(gef) == sorted(verlangt), (v, gef, verlangt)
