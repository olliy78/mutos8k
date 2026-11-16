"""Plan 47 P1.1: baseline measurement of the natural kernel build, with two source disks.

The sources of the natural build (gesamtbau.nat_quellen) no longer fit on one disk (239 KB).  They are split over two
disks; the guest builds half of the C files with `mk1`, then the disk is changed (gastlauf.lauf) and the Makefile of
disk 2 builds the rest and links `lk`.  The kernel image is cut from `lk` on the host exactly like gesamtbau.natuerlich
(the only host step; used here as a reference only).

  python3 -I tools/plus/basis.py [--nur-plan] [--boot] [--arbeit DIR]   (exit 77 without the emulator)
"""
import argparse
import hashlib
import os
import re
import struct
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))
import gesamtbau as G  # noqa: E402
import gast_as  # noqa: E402
import gastlauf  # noqa: E402
import rundlauf_gast  # noqa: E402

KAPAZITAET = 239 * 1024     # free bytes of an empty 26x128 MFM disk (measured, doc/plus/gastbau.md)
BSS_GRENZE = 0xD266         # `cfreelist` (first absolute symbol of abs.o) follows cfree directly in the original (gastbau.md 1.1)
ASM = ["low.s", "bss.s", "shim.s", "abs.o"] + ["dn%d.s" % i for i in range(len(G.NAT_DATEN))]


def regeln_trennen(makefile):
    """Makefile text -> (head, {target: rule text}); a rule = target line + its tab lines."""
    kopf = []
    regeln = {}
    cur = None
    for z in makefile.split("\n"):
        m = re.match(r"^([\w.]+):", z)
        if m:
            cur = m.group(1)
            regeln[cur] = [z]
        elif z.startswith("\t") and cur:
            regeln[cur].append(z)
        elif not regeln and z != "":
            kopf.append(z)
    return "\n".join(kopf), {k: "\n".join(v) for k, v in regeln.items()}


def aufteilen(q):
    """-> (disk1, disk2) as {name: bytes|str}."""
    mk = os.path.join(G.WURZEL, "userspace", "make")
    make = open(os.path.join(mk, "make.bin"), "rb").read()
    makeinfo = open(os.path.join(mk, "make.bin.fileinfo"), "r").read()
    hdr = {n: v for n, v in q.items() if n.endswith(".h")}
    cs = G.NAT_CDATEIEN
    groesse = {c: len(q[c + ".c"]) for c in cs}
    halb = sum(groesse.values()) / 2.0
    d1c, s = [], 0
    for c in cs:
        if s >= halb:
            break
        d1c.append(c)
        s += groesse[c]
    d2c = [c for c in cs if c not in d1c]
    kopf, regeln = regeln_trennen(q["Makefile"])
    srcvar = re.search(r"^SRC = .*$", kopf, re.M).group(0)
    cflags = re.search(r"^CFLAGS = .*$", kopf, re.M).group(0)
    mk1 = "# part 1: objects of the first half of the C files (plan 47 P1.1)\n%s\n%s\n\nobjs1: %s\n\tcat /dev/null\n\n%s\n" % (
        srcvar, cflags, " ".join(c + ".o" for c in d1c), "\n".join(regeln[c + ".o"] for c in d1c))
    # Makefile 2: the rules of part 1 are dropped, their objects are in /tmp already
    # bss.o is 36 KB of zeros: it goes to the root disk (40 KB free; /mnt has too little room, measured), otherwise the link runs out of space on A (measured, gastbau.md)
    kopf = kopf.replace("dn3.o bss.o", "dn3.o /bss.o")
    regeln["bss.o"] = "/bss.o: $(SRC)/bss.s\n\tas -u -o /bss.o $(SRC)/bss.s"
    rest = [t for t in regeln if not (t.endswith(".o") and t[:-2] in d1c)]
    mk2 = kopf + "\n\n" + "\n".join(regeln[t] for t in rest) + "\n"
    # head holds the OBJS line and the first rule `lk:`; keep the order of the original: head already contains `lk:` rule
    base = {"make": make, "make.fileinfo": makeinfo}
    base.update(hdr)
    disk1 = dict(base)
    disk1["mk1"] = mk1
    for c in d1c:
        disk1[c + ".c"] = q[c + ".c"]
    disk2 = dict(base)
    disk2["Makefile"] = mk2
    for c in d2c:
        disk2[c + ".c"] = q[c + ".c"]
    for n in ASM:
        disk2[n] = q[n]
    return disk1, disk2, d1c, d2c


def bss_groessen(bss_s):
    """bss.s text -> [(name, size)] in file order (G _name A[%SIZE B] lines)."""
    if isinstance(bss_s, bytes):
        bss_s = bss_s.decode("ascii")
    return [(m.group(1), int(m.group(2), 16)) for m in re.finditer(r"^G\t(\w+)\tA\[%([0-9A-Fa-f]+) B\]", bss_s, re.M)]


def anpassen(q):
    """Plan 47 P1.3 changes of the natural-build sources (in place): `nested` gets a name in bss.s (it was an unnamed
    common that ld put behind the BSS), the German Makefile comment is translated.  _cfree keeps %310 = 49 blocks (NCLIST 49)."""
    b = q["bss.s"]
    assert "_nested" not in b and re.search(r"^G\t_cfree\tA\[%310 B\]$", b, re.M)
    b = b.replace("end bss", "! trap.c: int nested (was an unnamed common behind the BSS) !\nG\t_nested\tA[%2 B]\nend bss")
    q["bss.s"] = b
    mf = q["Makefile"]
    mf = re.sub(r"^# Makefile fuer .*\n# Quellen und Header .*\n",
                "# Makefile of the MUTOS kernel (plan 47).  Call in the guest:  cd /tmp; /mnt/make -f /mnt/Makefile\n"
                "# Sources and headers are on /mnt (drive D), objects and result on /tmp (drive A), bss.o on the root.\n", mf, count=1, flags=re.M)
    q["Makefile"] = mf
    return q


def grenze_pruefen(bss_s, ende):
    """ende = start of the BSS (end of text+data).  The end of _cfree must not pass BSS_GRENZE.  -> (cfree_end, bss_end, ok)"""
    pos = ende
    cf = None
    for n, g in bss_groessen(bss_s):
        pos += g
        if n == "_cfree":
            cf = pos
    return cf, pos, cf is not None and cf <= BSS_GRENZE


def disketten_aus_plus(plus):
    """Rebuild the two source disks from the checked-in sources: kernel/plus (assembler, abs.o, mk1, Makefile),
    kernel/c, kernel/conf, kernel/h and userspace/make.  -> (disk1, disk2, d1c, d2c)"""
    def lies(pfad, binaer=True):
        return open(pfad, "rb" if binaer else "r").read()
    mk = os.path.join(G.WURZEL, "userspace", "make")
    base = {"make": lies(os.path.join(mk, "make.bin")), "make.fileinfo": lies(os.path.join(mk, "make.bin.fileinfo"), False)}
    for h in sorted(os.listdir(G.HQUELLEN)):
        if h.endswith(".h"):
            base[h] = lies(os.path.join(G.HQUELLEN, h))
    mk1 = lies(os.path.join(plus, "mk1"), False)
    d1c = re.search(r"^objs1: (.*)$", mk1, re.M).group(1).replace(".o", "").split()
    disk1, disk2 = dict(base), dict(base)
    disk1["mk1"] = mk1
    disk2["Makefile"] = lies(os.path.join(plus, "Makefile"), False)
    for c in G.NAT_CDATEIEN:
        (disk1 if c in d1c else disk2)[c + ".c"] = lies(G.cpfad(c))
    for n in ASM:
        disk2[n] = lies(os.path.join(plus, n))
    return disk1, disk2, d1c, [c for c in G.NAT_CDATEIEN if c not in d1c]


def laenge(d):
    return sum(len(v if isinstance(v, bytes) else v.encode("latin-1")) for v in d.values())


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--arbeit", default="/tmp/mplus/p1_1")
    ap.add_argument("--nur-plan", action="store_true")
    ap.add_argument("--boot", action="store_true")
    ap.add_argument("--plus", action="store_true", help="build from the checked-in kernel/plus sources (P1.3) instead of nat_quellen")
    ap.add_argument("--frist", type=int, default=6_000_000_000)
    a = ap.parse_args(argv)
    try:
        gast_as.pruefe_hilfsmittel()
    except gast_as.Fehlt as e:
        print("skip: missing", e)
        return 77
    if a.plus:
        d1, d2, c1, c2 = disketten_aus_plus(os.path.join(G.WURZEL, "kernel", "plus"))
    else:
        welt = G.Welt(rundlauf_gast.kernel_holen(), os.path.join(a.arbeit, "obj"))
        q, absnamen = G.nat_quellen(welt, a.arbeit)
        d1, d2, c1, c2 = aufteilen(q)
    for i, (d, c) in enumerate(((d1, c1), (d2, c2)), 1):
        print("disk %d: %d files, %d bytes (limit %d), C: %s" % (i, len(d), laenge(d), KAPAZITAET, " ".join(c)))
        if laenge(d) + 1024 * len(d) // 2 > KAPAZITAET:      # rough block rounding
            print("WARNING: disk %d may not fit" % i)
    if a.nur_plan:
        for n in ("mk1",):
            print(d1[n])
        print(d2["Makefile"])
        return 0
    befehle = ["(cd /tmp; /mnt/make -f /mnt/mk1) >/tmp/make1.log 2>&1", ("wechsel", 1),
               "(cd /tmp; /mnt/make -f /mnt/Makefile) >/tmp/make2.log 2>&1", "ls -l /tmp >/tmp/ls.log 2>&1", "df >/tmp/df.log 2>&1"]
    aus = {}
    erg = gastlauf.lauf(os.path.join(a.arbeit, "gast_plus" if a.plus else "gast_nat2"), [d1, d2], befehle, ["make1.log", "make2.log", "ls.log", "df.log", "lk"],
                        ausfuehrbar=["make"], frist=a.frist, ausgabe=aus)
    print("guest run time (wall clock): %.0f s, log %s" % (aus["dauer"], aus["log"]))
    for n in ("make1.log", "make2.log", "ls.log", "df.log"):
        print("---", n)
        print((erg.get(n) or b"(missing)").decode("latin-1")[-3000:])
    b = erg.get("lk")
    if not b:
        print("lk: not produced")
        return 1
    open(os.path.join(a.arbeit, "lk"), "wb").write(b)
    magic, text, data, bss = struct.unpack(">4H", b[:8])
    print("lk: text %d data %d bss %d  sha256 %s" % (text, data, bss, hashlib.sha256(b).hexdigest()))
    voll = b[16:16 + text + data]
    bsslen = sum(g for _, g in bss_groessen(d2["bss.s"]))     # the BSS is the tail of the data section (zeros)
    ist = voll[:len(voll) - bsslen]
    ende = len(ist)
    cf, bende, ok = grenze_pruefen(d2["bss.s"], ende)
    print("kernel: text+data %d bytes (original %d); BSS from %04X to %04X, cfree ends at %04X (limit %04X)" % (ende, G.BSS_VON, ende, bende, cf or 0, BSS_GRENZE))
    if not ok:
        print("ERROR: cfree reaches over cfreelist (D266)")
        return 1
    ist = ist.ljust((ende + 511) // 512 * 512, b"\0")
    open(os.path.join(a.arbeit, "mutos_1216.nat"), "wb").write(ist)
    print("mutos_1216.nat: %d bytes  sha256 %s" % (len(ist), hashlib.sha256(ist).hexdigest()))
    if bss != 0:
        return 1
    if a.boot and not G.boot_pruefen(os.path.join(a.arbeit, "nat_boot2"), ist):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
