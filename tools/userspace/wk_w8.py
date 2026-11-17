"""wk_w8: rebuild the shipped /usr/lib/libc.a, crt0.o, mcrt0.o from sources (plan 52, W8; doc/userspace/wk_w8.md).

  python3 -I tools/userspace/wk_w8.py holen               # shipped objects -> userspace/libc/work/ship/*.o (host)
  python3 -I tools/userspace/wk_w8.py cbau  [MEMBER...]   # guest `cc -O -c` of userspace/libc/*.c (else V7 text) -> compare
  python3 -I tools/userspace/wk_w8.py sbau  [MEMBER...]   # guest `as` of userspace/libc/*.s -> compare
  python3 -I tools/userspace/wk_w8.py archiv              # archive from the built objects (host, original headers) -> compare

Members are compared as whole object files (header, text, data, relocations, symbol table).  The guest run is
`cc -O -c` of the original tool chain (guest c0/c1/c2/as) -- no c2 model here.  Exit 77 = emulator/disks missing.
Working directory userspace/libc/work (not committed).
"""
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HIER)
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.join(TOOLS, "kernel"))
sys.path.insert(0, TOOLS)
import uspace as U         # noqa: E402
import objformat as O      # noqa: E402
import emu                 # noqa: E402

REPO = U.REPO
LIBC = os.path.join(REPO, "userspace", "libc")
WORK = os.path.join(LIBC, "work")
SHIP = os.path.join(WORK, "ship")
V7 = os.path.join(REPO, "original", "unix-v7", "usr", "src", "libc")
V7INC = os.path.join(REPO, "original", "unix-v7", "usr", "include")
# headers the usr disk does not have (V7 text, put on the source disk; -I/mnt wins over /usr/include)
EXTRA_INC = ["errno.h", "setjmp.h", "utmp.h", "sys/dir.h", "sys/timeb.h"]


def holen():
    os.makedirs(SHIP, exist_ok=True)
    b = U.libc_archiv(WORK)
    open(os.path.join(WORK, "libc.a"), "wb").write(b)
    ar = O.Archiv.lesen(b)
    for m in ar.mitglieder:
        open(os.path.join(SHIP, m.name.decode()), "wb").write(m.daten)
    for n in ("crt0", "mcrt0"):
        open(os.path.join(SHIP, n + ".o"), "wb").write(U.platte_holen("usr", "lib/%s.o" % n, WORK))
    return ar


def schiff(name):
    return open(os.path.join(SHIP, name + ".o"), "rb").read()


def mitglieder():
    return [m.name.decode()[:-2] for m in O.Archiv.lesen(open(os.path.join(WORK, "libc.a"), "rb").read()).mitglieder]


def quelle_c(name):
    """userspace/libc/NAME.c if it exists, else the V7 text (gen, stdio)."""
    p = os.path.join(LIBC, name + ".c")
    if os.path.isfile(p):
        return open(p, "rb").read()
    for d in ("gen", "stdio"):
        p = os.path.join(V7, d, name + ".c")
        if os.path.isfile(p):
            return open(p, "rb").read()
    return None


def vergleich(a, b):
    """(text) description of the difference between two object files"""
    if a == b:
        return "G"
    oa, ob = O.Objekt.lesen(a), O.Objekt.lesen(b)
    t = []
    for k in ("text", "data"):
        x, y = getattr(oa, k), getattr(ob, k)
        if x != y:
            d = [i for i in range(min(len(x), len(y))) if x[i] != y[i]]
            t.append("%s %d/%d B, %d differing bytes%s" % (k, len(x), len(y), len(d) + abs(len(x) - len(y)),
                     " first +%X" % d[0] if d else ""))
    if oa.bss != ob.bss:
        t.append("bss %d/%d" % (oa.bss, ob.bss))
    if not t:
        t.append("relocations/symbols differ")
    return "; ".join(t)


def gast(namen, art, frist=20_000_000_000):
    """art 'c': cc -O -c; art 's': as.  Returns {name: (messages, object|None)}."""
    import gast_as
    try:
        gast_as.pruefe_hilfsmittel()
    except gast_as.Fehlt as e:
        raise U.Fehlt(str(e))
    emu.build()
    quellen, befehle, rueck = {}, [], []
    for n in namen:
        if art == "c":
            quellen[n + ".c"] = quelle_c(n)
            befehle.append("cd /tmp;cc -O -c -I/mnt /mnt/%s.c >%s.err 2>&1;cd /mnt" % (n, n))
        else:
            quellen[n + ".s"] = open(os.path.join(LIBC, n + ".s"), "rb").read()
            befehle.append("cd /tmp;>asm.out;as -u /mnt/%s.s >%s.err 2>&1;cat asm.out >%s.o;cd /mnt" % (n, n, n))
        rueck += [n + ".o", n + ".err"]
    for h in EXTRA_INC:
        quellen[h] = open(os.path.join(V7INC, h), "rb").read()
    aus = {}
    os.makedirs(WORK, exist_ok=True)
    r = gast_as.gast_befehle(os.path.join(WORK, "gast_" + art), quellen, befehle, rueck, frist=frist, ausgabe=aus)
    print("guest run: %.0f s wall clock" % aus.get("dauer", 0))
    return {n: ((r.get(n + ".err") or b"").decode("latin-1").strip(), r.get(n + ".o")) for n in namen}


def bauen(namen, art):
    os.makedirs(os.path.join(WORK, "bau"), exist_ok=True)
    erg = gast(namen, art)
    for n in namen:
        err, ob = erg[n]
        if ob:
            open(os.path.join(WORK, "bau", n + ".o"), "wb").write(ob)
        res = "NO OBJECT" if not ob else vergleich(ob, schiff(n))
        print("%-9s %-4s %s%s" % (n, "G" if res == "G" else "-", res if res != "G" else "", ("  cc: " + err[:150].replace("\n", " | ")) if err else ""))
    return 0


def main(argv):
    if not argv or argv[0] not in ("holen", "cbau", "sbau", "archiv"):
        print(__doc__)
        return 2
    try:
        U.pruefe()
        if argv[0] == "holen":
            ar = holen()
            print("%d members" % len(ar.mitglieder))
        elif argv[0] in ("cbau", "sbau"):
            art = argv[0][0]
            namen = argv[1:] or [n for n in mitglieder() if (quelle_c(n) is not None if art == "c" else
                                                            os.path.isfile(os.path.join(LIBC, n + ".s")))]
            return bauen(namen, art)
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
