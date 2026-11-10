"""Guard for tools/userspace/ (user-space pipeline, doc/userspace/pipeline.md).

* pure parts (listing parser, normalisation, signature naming) run everywhere;
* `gast`: fetch /etc/init from the finished root disk, build the map, name the libc functions (needs the emulator
  tools, a few seconds);
* `gast` + USERSPACE_GAST=1: the guest build of userspace/init/init.c (minutes of wall clock) and the byte
  comparison against the original; the expected state is documented in doc/userspace/init.md.
"""
import os
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

TOOLS = PROJECT_ROOT / "tools" / "userspace"
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "kernel"))
sys.path.insert(0, str(TOOLS))
import uspace as U   # noqa: E402

PIPELINE = TOOLS / "pipeline.py"


def test_listing_parser_and_normalisation():
    lst = "\n".join([
        "L0030:",
        "0030  5F00 11E6             CALL L11E6",
        "0034  0DF9 1846             PUSH @R15,#%1846",
        "0038  0DF9 0064             PUSH @R15,#%0064",
        "003C  5F00 0030             CALL L0030",
        "1202  0000 2F62 696E 2F73   DW %0000,%2F62,%696E,%2F73",
    ])
    b = U.befehle_lesen(lst)
    assert [x[0] for x in b] == [0x30, 0x34, 0x38, 0x3C, 0x1202]
    assert U.aufrufziele(b) == {0x30, 0x11E6}
    st = {0x30, 0x11E6}
    n = U.normalisieren(b[:4], st, 0x1202, 0x1362, 0x1C86)
    assert n[0] == "CALL L"
    assert n[1] == "PUSH @R15,#B+4E4"                                  # bss address becomes bss-relative
    assert n[2] == "PUSH @R15,#%0064"                                  # a constant stays exact


def test_strings_and_function_ranges():
    raw = b"\0\0/bin/sh\0\0-\0xx"
    assert U.texte_finden(raw, 0) == [(2, "/bin/sh")]
    assert U.funktionen([], {0, 0x30, 0x65E}, 0x700) == [(0, 0x30), (0x30, 0x65E), (0x65E, 0x700)]


def test_c2_model_rewrites_and_canonicalises():
    s = "\n".join(["call\t_signal", "inc\tSP,#%4", "ld\t@SP,#%3C", "call\t_alarm",
                   "ldb\trl3,@r2", "xorb\trh3,rh3", "ldb\t_tty(r13),rl3",
                   "xorb\trh2,rh2", "cp\tr2,#%A", "jr\teq\tL9020", "jr\tL82"])
    t, n = U.c2_emu_s(s)
    assert n == {"R1": 1, "R2": 1, "R3": 1, "R4": 0, "R5": 0, "R6": 0, "R7": 0, "R8": 0, "R9": 0, "R10": 0, "R30": 0, "R11": 0, "R12": 0, "R13": 0, "R14": 0, "R16": 0, "R32": 0, "R33": 0, "R34": 0}
    assert "inc\tSP,#%6\npush\t@SP,#%3C" in t and t.count("xorb") == 2
    # the canonical form of the listing lines equalises both compilers' output
    orig = ["INC R15,#6", "PUSH @R15,#%003C", "LDB RL3,@R2", "LDB %1832(R13),RL3"]
    neu = ["INC R15,#4", "LD @R15,#%003C", "LDB RL3,@R2", "XORB RH3,RH3", "LDB %1832(R13),RL3"]
    assert U.c2_kanon(orig) == U.c2_kanon(neu)


def test_c2_model_r4_r5_r8_r9():
    s = "\n".join(["cp\t%4(FP),#%1", "cp\tr13,#-%1", "ldb\trl2,-%D(FP)", "xorb\trh2,rh2", "ldb\trl3,rl2",
                   "ld\tr2,r3", "ld\t-%12(FP),r3", "and\tr4,#%80", "or\tr2,r4"])
    t, n = U.c2_emu_s(s)
    assert (n["R4"], n["R5"], n["R8"], n["R9"]) == (1, 1, 1, 1)
    assert t.split("\n")[:3] == ["ld\tr0,%4(FP)", "cp\tr0,#%1", "cp\tr13,#-%1"]
    assert "ldb\trl3,-%D(FP)" in t and "ld\t-%12(FP),r2" in t and "ld\tr3,r4\nor\tr2,r3" in t
    assert U.c2_kanon(["LD R0,%4(R14)", "CP R0,#1"]) == ["CP %4(R14),#1"]


def test_header_parser():
    k = U.kopf_lesen(bytes.fromhex("e807 1202 0160 0924 0000 0000 0000 0001".replace(" ", "")))
    assert k[1:4] == (0x1202, 0x160, 0x924) and k[7] == 1
    with pytest.raises(ValueError):
        U.kopf_lesen(b"\0" * 16)


@pytest.mark.gast
def test_init_fetch_map_names():
    r = subprocess.run([sys.executable, "-I", str(PIPELINE), "--check", "init"], capture_output=True, text=True,
                       timeout=300)
    if r.returncode == 77:
        pytest.skip("emulator or disk missing")
    assert r.returncode == 0, r.stdout + r.stderr


@pytest.mark.gast
@pytest.mark.skipif(not os.environ.get("USERSPACE_GAST"), reason="guest build takes minutes: set USERSPACE_GAST=1")
def test_init_guest_build_matches_original(tmp_path):
    r = subprocess.run([sys.executable, "-I", str(PIPELINE), "alles", "init", "--c2emu", "--ist", "neu_c2_s",
                        "--arbeit", str(tmp_path)], capture_output=True, text=True, timeout=7200)
    if r.returncode == 77:
        pytest.skip("emulator or disk missing")
    assert "NO binary" not in r.stdout
    # state reached (doc/userspace/init.md): the own code is identical to the original once the c2 model R1-R3 is applied;
    # the whole file is not (older libc in the original) -> exit 1 is the expected result, 0 would be byte identity
    assert r.returncode in (0, 1), r.stdout + r.stderr
    assert "own code: instruction streams identical" in r.stdout, r.stdout


def test_c2_model_sh_rules_r11_r16():
    """R11-R16 (sh): each rule on a minimal snippet; rules switched off via the second argument."""
    s = "\n".join(["ld\tr2,r3", "test\tr3", "jr\teq\tL1", "cp\tr2,#%2A", "jr\teq\tL2",
                   "and\tr2,#%80", "jp\tne\tL7", "ldb\trl2,-%D(FP)", "xorb\trh2,rh2", "add\tr2,#_t", "bitb\t@r2,#%6", "jp\teq\tL7"])
    t, n = U.c2_emu_s(s, {"R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "R30"})
    assert n["R11"] == 1 and n["R16"] == 1
    assert "cp\tr3,#%2A" in t and "wval\t-%1180" in t and "jp\tne" not in t
    t2, n2 = U.c2_emu_s(s, {"R11", "R16"})
    assert n2["R11"] == 0 and n2["R16"] == 0 and "cp\tr2,#%2A" in t2


def test_sh_rules_are_off_for_other_programs():
    # R11-R14 were measured on sh only; applied to cat/login they broke byte identity (measured after the us-sh merge)
    import pipeline as P
    assert P.c2_aus("cat") >= {"R11", "R12", "R13", "R14"} and not (P.c2_aus("sh") & {"R11", "R12", "R13", "R14"})
    s = "\n".join(["ld\t-%2C(FP),r2", "cp\t-%2C(FP),#%2000"])      # R13 shape (sh); must stay untouched for cat
    t, n = U.c2_emu_s(s, P.c2_aus("cat"))
    assert n["R13"] == 0
    t, n = U.c2_emu_s(s, P.c2_aus("sh"))
    assert n["R13"] == 1
