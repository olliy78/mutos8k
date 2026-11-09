"""Host test of the kernel c2 model (tools/kernel/c2_modell.py, Plan 43 section 15): every rule rewrites its pattern, and only inside
the functions it is bound to.  The guest round trip (`gesamtbau.py --uebersetzen --c2modell --boot`) is the real proof; this test
guards the rewriting itself."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools", "kernel"))
import c2_modell as C  # noqa: E402


def blk(name, *zeilen):
    return ["~~%s:" % name[:8], "E", "call\tcsv"] + list(zeilen) + ["jp\tcret", "end _%s" % name[:8]]


def run(name, *zeilen):
    t, n = C.anwenden("\n".join(blk(name, *zeilen)), [name])
    return t.split("\n"), n[name]


def test_k1_compare_original_register():
    z, n = run("mfree", "ld\tr2,r3", "cp\tr2,#%F", "jr\tle\tL3")
    assert "cp\tr3,#%F" in z and n == {"K1": 1}


def test_k2_test_after_sub_kept():
    z, n = run("malloc", "ld\tr2,r3", "cp\tr2,#%F", "sub\tr2,%6(FP)", "ld\t@r12,r2", "jr\tne\tL8")
    assert z[z.index("ld\t@r12,r2") + 1] == "test\tr2" and n == {"K1": 1, "K2": 1}
    z, n = run("readi", "subl\trr2,%2A+_u", "ldl\t-%1C(FP),rr2", "jr\tmi\tL3")
    assert z[z.index("ldl\t-%1C(FP),rr2") + 1] == "testl\trr2"


def test_k3_stack_slot():
    z, n = run("bmap", "ldl\t-%18(FP),rr4", "testl\trr4", "jr\tne\tL6")
    assert "testl\t-%18(FP)" in z and "testl\trr4" not in z
    z, n = run("ialloc", "ld\t-%12(FP),r3", "cp\t-%12(FP),#%2", "jr\tc\tL33", "push\t@SP,r3")
    assert "push\t@SP,-%12(FP)" in z and n == {"K3": 1}


def test_k4_tail_behind_last_call():
    z, n = run("lpintr", "call\t_lpxfer", "L9006:", "inc\tSP,#%2", "L70:", "jp\tcret", "L72:", "push\t@SP,r11",
               "call\t_wakeup", "jr\tL9006", "L71:")
    i = z.index("call\t_wakeup")
    assert z[z.index("call\t_lpxfer") + 1] == "jr\tL9006"
    assert z[i + 1:i + 5] == ["L9006:", "inc\tSP,#%2", "L70:", "jp\tcret"] and n == {"K4": 1}


def test_k5_short_jumps():
    z, n = run("ttioccomm", "call\t_copyin", "inc\tSP,#%6", "test\tr2", "jp\tne\tL9000", "clrb\t%2C(r13)", "jp\tL21")
    assert "wval\t-%117F" in z and "jr\tL21" in z and n["K5"] == 2


def test_k6_reproduces_the_dropped_load():
    z, n = run("ttyinput", "ld\tr2,%2A(r12)", "xor\tr2,#%1", "ld\t%2A(r12),r2")
    assert "ld\tr2,%2A(r12)" not in z and n == {"K6": 1}


def test_other_functions_untouched():
    s = "\n".join(blk("swtch", "ld\tr2,r3", "cp\tr2,#%F", "ldl\t-%18(FP),rr4", "testl\trr4"))
    t, n = C.anwenden(s)
    assert t == s and n == {}
