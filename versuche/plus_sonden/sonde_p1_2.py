#!/usr/bin/env python3
"""Plan 47 P1.2: probes of the guest tool chain (absolute globals, real BSS, ld symbols, dd/cmp).

One guest run; results go to <arbeit>/ergebnis/ and are printed.  Exit 77 without emulator.
Usage: python3 -I versuche/plus_sonden/sonde_p1_2.py [arbeit]   (default /tmp/mplus/p1_2)
"""
import os
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "tools", "kernel"))
sys.path.insert(0, os.path.join(REPO, "tools"))
import gast_as  # noqa: E402
import objformat as O  # noqa: E402

KOPF = """%s module
$NONSEGMENTED
constant
	FP	:= r14
	SP	:= r15
	X	:= external
	G	:= global
	I	:= internal
	A	:= array
	PR	:= procedure
	E	:= entry
	B	:= byte
	W	:= word
	BV	:= bval
	WV	:= wval
	LV	:= lval
	L	:= label
"""

# --- question 1: absolute global symbols ---------------------------------------------------------
ABS = {
    "a1": "$ABS %FC00\nG\n_u\tL\n_u:\n",
    "a2": "G\n_u\tL\n$ABS %FC00\n_u:\n",
    "a3": "G\n_u\t:= %FC00\n",
    "a4": "$ABS %FC00\nG\n_u\tA[%400 B]\n",
    "a5": "$ABS %D532\nG\n_mbox\tL\n_mbox:\n$REL $+%40\n$ABS %FC00\nG\n_u\tL\n_u:\n",
    "a6": "constant\n\t_u\t:= %FC00\nG\n_u2\tL\n_u2:\n",
}
USE_ABS = """X\t_u\tW
G\t_tst\tPR
E
_tst:
	ld	r2,#_u
	ld	r3,_u
	ret
end _tst
"""

# --- question 2: BSS from the assembler ----------------------------------------------------------
BSS = {
    "b1": "$SECTION BSS_B\nG\t_g\tA[%10 B]\n$SDEFAULT\n",
    "b2": "$SECTION BSS_B\nX\t_g\tA[%20 B]\n$SDEFAULT\n",
    "b3": "$SECTION BSS_B\nI\nB1:\nG\n_g\tL\n_g:\nI\n$REL $+%30\n$SDEFAULT\n",
    "b4": "G\t_g\tA[%40 B]\n",
}
USE_G = """X\t_g\tW
G\t_tst\tPR
E
_tst:
	ld	r2,#_g
	ld	_g,r2
	ret
end _tst
"""
# text + data + bss in one module, plus a consumer from another module
MIX = """G\t_f\tPR
E
_f:
	ld	r2,_dv
	ld	r3,_bv
	ret
end _f
$SECTION BSS_B
I
B7:
G
_bv\tL
_bv:
I
$REL $+%30
$SDEFAULT
I
G
_dv\tL
_dv:
WV %1234
"""
MIXUSE = """X\t_f\tPR
X\t_dv\tW
X\t_bv\tW
G\t_tst\tPR
E
_tst:
	call	_f
	ld	r2,#_dv
	ld	r3,#_bv
	ld	_bv,r2
	ret
end _tst
"""
# question 3: linker symbols
LDSYM = """X\t_etext\tW
X\t_edata\tW
X\t_end\tW
G\t_tst\tPR
E
_tst:
	ld	r2,#_etext
	ld	r3,#_edata
	ld	r4,#_end
	ret
end _tst
"""


LDSYM0 = LDSYM.replace("\tW\n", "\tPR\n")


def modul(name, rumpf):
    return (KOPF % (name + "_")) + rumpf + "end %s_\n" % name


def main():
    arbeit = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "/tmp/mplus/p1_2")
    q = {}
    cmds = ["cd /tmp"]
    rueck = []

    def asm(n):
        cmds.append("as -u -o %s.o /mnt/%s.s >%s.err 2>&1" % (n, n, n))
        rueck.extend([n + ".o", n + ".err"])

    def link(erg, *objs):
        cmds.append("ld -o %s %s >%s.err 2>&1" % (erg, " ".join(o + ".o" for o in objs), erg))
        rueck.extend([erg, erg + ".err"])

    kurz = os.environ.get("P12_KURZ")
    for n, r in ABS.items():
        if kurz and (kurz == "2" or n not in ("a1", "a6")):
            continue
        q[n + ".s"] = modul(n, r)
        asm(n)
        q["u" + n + ".s"] = modul("u" + n, USE_ABS)
        asm("u" + n)
        link("l" + n, "u" + n, n)
    for n, r in BSS.items():
        if kurz and (kurz == "2" or n not in ("b1", "b3", "b4")):
            continue
        q[n + ".s"] = modul(n, r)
        asm(n)
        q["u" + n + ".s"] = modul("u" + n, USE_G)
        asm("u" + n)
        link("l" + n, "u" + n, n)
    q["mix.s"] = modul("mix", MIX)
    q["mixuse.s"] = modul("mixuse", MIXUSE)
    asm("mix")
    asm("mixuse")
    link("lmix", "mixuse", "mix")
    q["ldsym.s"] = modul("ldsym", LDSYM)
    asm("ldsym")
    link("lsym0", "ldsym")                     # only the symbol reference
    link("lsym1", "ldsym", "mixuse", "mix")    # text + data + bss behind it
    # same with value-0 externs (PR): then ld may define the symbols itself
    q["ldsymp.s"] = modul("ldsymp", LDSYM0.replace("_tst", "_tsp"))
    q["mixusp.s"] = modul("mixusp", MIXUSE.replace("_tst", "_tsq"))
    asm("ldsymp")
    asm("mixusp")
    link("lsym2", "ldsymp")
    link("lsym3", "ldsymp", "mixusp", "mix")
    # question 4: dd / cmp (they live on the source disk D, /mnt, copied from the cmd disk)
    x = bytes([0xAA] * 16) + bytes((i * 7 + 1) & 0xFF for i in range(1500))
    q["x"] = x
    q["x2"] = x[:-1] + b"\x00"
    q["yes"] = "YES\n"
    q["no"] = "NO\n"
    D, C = "/mnt/dd", "/mnt/cmp"
    if kurz:
        cmds, rueck = cmds[:], rueck[:]
    cmds += [] if kurz else [
        "%s if=/mnt/x of=y ibs=16 skip=1 obs=512 >dd1.err 2>&1" % D,
        "%s if=y of=z bs=512 conv=sync >dd2.err 2>&1" % D,
        "%s if=/mnt/x ibs=16 skip=1 obs=512 2>dd3a.err | %s of=z3 bs=512 conv=sync >dd3b.err 2>&1" % (D, D),
        "%s if=/mnt/x of=y4 ibs=16 skip=1 conv=sync >dd4.err 2>&1" % D,
        "%s if=/mnt/x of=y5 bs=16 skip=1 count=3 >dd5.err 2>&1" % D,
        "ls -l /mnt/x y z z3 y4 y5 >ls.out 2>&1",
    ]
    if not kurz:
        for i, (a, b) in enumerate([("/mnt/x", "/mnt/x"), ("/mnt/x", "/mnt/x2"), ("/mnt/x", "/mnt/nofile"), ("y", "z"), ("z", "z3")], 1):
            cmds.append("%s %s %s >cmp%d.out 2>&1 && cat /mnt/yes >cmp%d.rc || cat /mnt/no >cmp%d.rc" % (C, a, b, i, i, i))
        rueck += ["dd1.err", "dd2.err", "dd3a.err", "dd3b.err", "dd4.err", "dd5.err", "y", "z", "z3", "y4", "y5", "ls.out"]
        for i in range(1, 6):
            rueck += ["cmp%d.out" % i, "cmp%d.rc" % i]
    cmdd = os.path.join(arbeit, "cmdd")
    os.makedirs(cmdd, exist_ok=True)
    tool = gast_as.disktool()
    hfe = gast_as.disk("a5120_mutos8000_cmd_mfm.hfe")
    for n in ("dd", "cmp"):
        subprocess.run([tool, "get", hfe, "bin/" + n, "--to", cmdd], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        pf = os.path.join(cmdd, "bin", n)
        q[n] = open(pf, "rb").read()
    aus = {}
    erg = gast_as.gast_befehle(arbeit, q, cmds, rueck, ausfuehrbar=("dd", "cmp"), ausgabe=aus, frist=6_000_000_000)
    ed = os.path.join(arbeit, "ergebnis")
    os.makedirs(ed, exist_ok=True)
    for n, b in erg.items():
        if b is not None:
            open(os.path.join(ed, n), "wb").write(b)
    print("dauer %.0f s, log %s" % (aus.get("dauer", 0), aus.get("log")))
    for n in rueck:
        b = erg.get(n)
        if b is None:
            print("== %s: FEHLT" % n)
        elif n.endswith((".err", ".out", ".rc")):
            print("== %s:\n%s" % (n, b.decode("latin-1").rstrip()))
        elif n.startswith("l") or n.endswith(".o"):
            print("== %s: %d B" % (n, len(b)))
            try:
                print(O.dump(O.Objekt.lesen(b), n))
            except Exception as e:     # noqa: BLE001
                print("   (objformat: %r)" % (e,))
        else:
            print("== %s: %d B" % (n, len(b)))


if __name__ == "__main__":
    try:
        main()
    except gast_as.Fehlt as e:
        print("fehlt: %s" % e)
        sys.exit(77)
