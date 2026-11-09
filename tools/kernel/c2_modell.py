#!/usr/bin/env python3
"""c2 model for the kernel: rewrite the `cc -O -S` output of the guest c2 so that it reads as the ORIGINAL (older) kernel c2
emitted it, then assemble it with the original guest `as` (Plan 43 section 15).

Same method as tools/userspace/uspace.py c2_emu_s (doc/userspace/README.md): the guest c0/c1/c2 run unchanged, the rules are a
MODEL of the differences of the lost older c2, not a run of it.  Proven by a byte-identical result is only
"C source + shipped compiler + these rules = original bytes".

Every rule is bound to the functions where it was measured (RULES below) and counted per site; a rule never touches other
functions, so every function that is byte-identical without the model stays untouched.  Function blocks in the .s are
`~~name:` (name cut to 8 characters) up to the next `end _...`.

Rules (all measured against kernel/asm/ref, Plan 43 section 8, section 10, section 12, section 14):
  K1  `ld r2,r3 ; cp r2,#k`  ->  `ld r2,r3 ; cp r3,#k`   (compare the original, not the copy; = userspace R11, simple form)
  K2  `sub rN,X ; ld MEM,rN ; jr..` -> `test rN` inserted before the jump; `subl rrN,X ; ldl MEM,rrN ; jr..` -> `testl rrN`
      (the older c2 keeps the test after the store)
  K3  `ldl MEM,rrN ; testl rrN` -> `ldl MEM,rrN ; testl MEM`;  `ld MEM,rN ; cp MEM,#k ; jr cc L ; push @SP,rN` -> `push @SP,MEM`
      (the older c2 does not replace the stack slot by the register just stored)
  K4  shared tail `call A ; Lt: inc SP,#k ; Lr: jp cret ... call B ; jr Lt`  ->  `call A ; jr Lt ... call B ; Lt: inc SP,#k ;
      Lr: jp cret` (the older c2 places the merged tail behind the LAST call that uses it)
  K5  ttioccomm, 2 sites: `jp ne L` at the TIOCSETA error exit -> `jr ne L`, and the backward `jp L` behind `clrb %2C(rN)` -> `jr L` (the older c2/as take the short jump at -254 bytes); written
      as `wval -%117F` (= %EE81) because the guest `as` rejects the displacement (ILLEGAL VALUE, cf. userspace R16)
  K6  `ld r2,MEM ; xor r2,#k ; ld MEM,r2` -> load dropped.  This reproduces a FAULT of the original c2: r2 does not hold MEM at
      that point (ttyinput, `t_xstate ^= XPAGE`, doc/herkunft/tty2.md).  The kernel built with K6 has the original's bug.

Call:  python3 c2_modell.py --s DIR --arbeit DIR [--module m,...] [--objekte DIR]
       DIR of --s holds <m>O.s from `gast_lauf.sh` (NUR_O=1, without KEIN_S); the result objects are written to ARBEIT/obj
       (<m>O.o) and compared with tools/kernel/vergleich.py; --objekte copies a full object directory (gesamtbau obj/) and
       replaces the rewritten modules, for `gesamtbau.py --objekte`.
"""
import argparse
import os
import re
import shutil
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)

# function (full C name) -> rules measured there
RULES = {
    "mfree": ["K1"], "malloc": ["K1", "K2"], "exece": ["K1"], "ttyretype": ["K1"], "ttread": ["K1"],
    "readi": ["K2"], "alloc": ["K3"], "ialloc": ["K3"], "bmap": ["K3"],
    "lpintr": ["K4"], "ttioccomm": ["K5", "K1"], "ttyinput": ["K6"],
}
MODULE = {"malloc": ["malloc", "mfree"], "sys1": ["exece"], "tty2": ["ttioccomm", "ttyinput", "ttyretype", "ttread"],
          "rdwri": ["readi"], "alloc": ["alloc", "ialloc"], "subr": ["bmap"], "lp": ["lpintr"]}


def k1(z, n):
    out = []
    for i, a in enumerate(z):
        if i and z[i - 1] == "ld\tr2,r3" and re.match(r"cp\tr2,#", a):
            a = a.replace("cp\tr2,", "cp\tr3,", 1)
            n["K1"] += 1
        out.append(a)
    return out


def k2(z, n):
    out = []
    for i, a in enumerate(z):
        out.append(a)
        if i >= 1 and re.match(r"jr\t", z[i + 1] if i + 1 < len(z) else ""):
            m = re.match(r"ld(l?)\t[^,]+,(rr?\d+)$", a)
            s = re.match(r"sub(l?)\t(rr?\d+),", z[i - 1])
            if m and s and m.group(1) == s.group(1) and m.group(2) == s.group(2):
                out.append("test%s\t%s" % (m.group(1), m.group(2)))
                n["K2"] += 1
    return out


def k3(z, n):
    out = []
    i = 0
    while i < len(z):
        a = z[i]
        b = z[i + 1] if i + 1 < len(z) else ""
        m = re.match(r"ldl\t([^,]+),(rr\d+)$", a)
        if m and b == "testl\t" + m.group(2):
            out += [a, "testl\t" + m.group(1)]
            n["K3"] += 1
            i += 2
            continue
        m = re.match(r"ld\t([^,@]+),(r\d+)$", a)
        if (m and i + 3 < len(z) and z[i + 1].startswith("cp\t%s,#" % m.group(1)) and z[i + 2].startswith("jr\t")
                and z[i + 3] == "push\t@SP," + m.group(2)):
            out += [a, z[i + 1], z[i + 2], "push\t@SP," + m.group(1)]
            n["K3"] += 1
            i += 4
            continue
        out.append(a)
        i += 1
    return out


def k4(z, n):
    for i in range(len(z) - 4):
        lt = re.match(r"(L\d+):$", z[i + 1])
        if z[i].startswith("call\t") and lt and z[i + 2].startswith("inc\tSP,") and re.match(r"L\d+:$", z[i + 3]) \
                and z[i + 4] == "jp\tcret":
            for j in range(i + 5, len(z) - 1):
                if z[j].startswith("call\t") and z[j + 1] == "jr\t" + lt.group(1):
                    tail = z[i + 1:i + 5]
                    n["K4"] += 1
                    return z[:i + 1] + ["jr\t" + lt.group(1)] + z[i + 5:j + 1] + tail + z[j + 2:]
    return z


def k5(z, n):
    for i, a in enumerate(z):
        if re.match(r"jp\tne\tL\d+$", a) and i >= 3 and z[i - 1] == "test\tr2" and z[i - 2].startswith("inc\tSP,") \
                and z[i - 3] == "call\t_copyin":
            # `jr ne` with disp -127 words; the guest `as` rejects it (ILLEGAL VALUE, like userspace R16), so the word is data
            z = z[:i] + ["wval\t-%117F"] + z[i + 1:]
            n["K5"] += 1
            # second site of the same case: the backward `jp L` behind `clrb %2C(rN)` is short in the original (-250 bytes)
            for j in range(i + 1, len(z) - 1):
                if re.match(r"clrb\t%2C\(r\d+\)$", z[j]) and re.match(r"jp\tL\d+$", z[j + 1]):
                    z = z[:j + 1] + [z[j + 1].replace("jp\t", "jr\t", 1)] + z[j + 2:]
                    n["K5"] += 1
                    break
            break
    return z


def k6(z, n):
    out = []
    i = 0
    while i < len(z):
        m = re.match(r"ld\tr2,([^,]+\(r\d+\))$", z[i])
        if m and i + 2 < len(z) and re.match(r"xor\tr2,#", z[i + 1]) and z[i + 2] == "ld\t%s,r2" % m.group(1):
            n["K6"] += 1
            i += 1
            continue
        out.append(z[i])
        i += 1
    return out


FUNKTION = {"K1": k1, "K2": k2, "K3": k3, "K4": k4, "K5": k5, "K6": k6}


def anwenden(s, funktionen=None):
    """Rewrite the .s text; only the blocks of the functions in RULES (or `funktionen`) are touched.
    Returns (text, {function: {rule: count}})."""
    z = s.split("\n")
    zaehl = {}
    out = []
    i = 0
    namen = {f[:8]: f for f in (funktionen or RULES)}
    while i < len(z):
        m = re.match(r"~~(\w+):$", z[i])
        if m and m.group(1) in namen:
            f = namen[m.group(1)]
            j = i
            while not z[j].startswith("end _"):
                j += 1
            blk = z[i:j]
            n = {r: 0 for r in RULES[f]}
            for r in RULES[f]:
                blk = FUNKTION[r](blk, n)
            zaehl[f] = n
            out += blk
            i = j
            continue
        out.append(z[i])
        i += 1
    return "\n".join(out), zaehl


def objekte_ersetzen(arbeit, objdir, module=None, log=print):
    """For gesamtbau --c2modell: guest `cc -O -S` of the model modules, rewrite, guest `as -u`, and replace <m>O.o in objdir.
    Returns {function: {rule: count}}; raises RuntimeError when a module gives no object."""
    import subprocess
    import gast_as
    module = module or list(MODULE)
    sdir = os.path.join(arbeit, "c2s")
    wurzel = os.path.dirname(os.path.dirname(HIER))
    env = dict(os.environ, NUR_O="1", K1520EMU_NOBUILD=os.environ.get("K1520EMU_NOBUILD", "1"))
    env.pop("KEIN_S", None)
    with open(os.path.join(arbeit, "c2s.log"), "w") as lf:
        subprocess.run(["bash", os.path.join(HIER, "gast_lauf.sh"), sdir] +
                       [os.path.join(wurzel, "kernel", "c", m + ".c") for m in module], env=env, stdout=lf, stderr=subprocess.STDOUT)
    teile, alle = {}, {}
    for m in module:
        t, zaehl = anwenden(open(os.path.join(sdir, "out", m + "O.s"), encoding="latin-1").read(), MODULE[m])
        for f, n in zaehl.items():
            log("  c2-Modell %-10s %s" % (f, " ".join("%s:%d" % kv for kv in n.items())))
            if any(v == 0 for v in n.values()):
                raise RuntimeError("c2-Modell: Regel ohne Stelle in %s %s" % (f, n))
        alle.update(zaehl)
        teile[m + "O"] = t
    erg = gast_as.gast_assemblieren(os.path.join(arbeit, "c2as"), teile,
                                    kommando=">asm.out;as -u %s.s >/tmp/%s.err 2>&1;cat asm.out >/tmp/%s.o")
    for m in module:
        err, obj = erg[m + "O"]
        if not obj:
            raise RuntimeError("c2-Modell: kein Objekt fuer %s: %s" % (m, (err or "").strip()[:300]))
        open(os.path.join(objdir, m + "O.o"), "wb").write(obj)
    return alle


def main(argv=None):
    import subprocess
    import gast_as
    ap = argparse.ArgumentParser()
    ap.add_argument("--s", required=True, help="directory with <m>O.s (gast_lauf.sh without KEIN_S)")
    ap.add_argument("--arbeit", required=True)
    ap.add_argument("--module", default=",".join(MODULE))
    ap.add_argument("--kernel", help="mutos_1216 image (default: from the disk archive)")
    ap.add_argument("--objekte", help="full object directory to copy (gesamtbau obj/); rewritten modules replace their objects")
    a = ap.parse_args(argv)
    arbeit = os.path.abspath(a.arbeit)
    os.makedirs(os.path.join(arbeit, "obj"), exist_ok=True)
    module = [m for m in a.module.split(",") if m]
    teile = {}
    for m in module:
        s = open(os.path.join(a.s, m + "O.s"), encoding="latin-1").read()
        t, zaehl = anwenden(s, MODULE[m])
        for f, n in zaehl.items():
            print("%-8s %-10s %s" % (m, f, " ".join("%s:%d" % kv for kv in n.items())))
            if any(v == 0 for v in n.values()):
                print("  WARNUNG: Regel ohne Stelle in", f)
        teile[m + "O"] = t
        open(os.path.join(arbeit, m + "O.s"), "w", newline="\n").write(t)
    # `as -u`: undefined symbols are external, as `cc` calls it
    erg = gast_as.gast_assemblieren(os.path.join(arbeit, "as"), teile,
                                    kommando=">asm.out;as -u %s.s >/tmp/%s.err 2>&1;cat asm.out >/tmp/%s.o")
    if a.kernel:
        kernel = open(a.kernel, "rb").read()
    else:
        import rundlauf_gast
        kernel = rundlauf_gast.kernel_holen()
    bad = 0
    for m in module:
        err, obj = erg[m + "O"]
        if err and err.strip():
            print("== %s: as meldet:\n%s" % (m, err.strip()[:600]))
        if not obj:
            print("== %s: KEIN OBJEKT" % m)
            bad = 1
            continue
        p = os.path.join(arbeit, "obj", m + "O.o")
        open(p, "wb").write(obj)
        quelle = os.path.join(os.path.dirname(HIER), "..", "kernel", "c", m + ".c")
        print("== %s" % m)
        kp = os.path.join(arbeit, "mutos_1216")
        open(kp, "wb").write(kernel)
        r = subprocess.run([sys.executable, "-I", os.path.join(HIER, "vergleich.py"), kp, p, os.path.abspath(quelle)],
                           capture_output=True, text=True)
        print(r.stdout.rstrip())
    if a.objekte:
        ziel = os.path.join(arbeit, "obj_gesamt")
        shutil.rmtree(ziel, ignore_errors=True)
        shutil.copytree(a.objekte, ziel)
        for m in module:
            q = os.path.join(arbeit, "obj", m + "O.o")
            if os.path.exists(q):
                shutil.copy(q, os.path.join(ziel, m + "O.o"))
        print("Objekte fuer gesamtbau --objekte:", ziel)
    return bad


if __name__ == "__main__":
    sys.exit(main())
