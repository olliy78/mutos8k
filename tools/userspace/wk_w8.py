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
import re
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
    if "__" in name:      # experiment variant NAME__x: work/var/NAME__x.c (compared against member NAME)
        p = os.path.join(WORK, "var", name + ".c")
        return open(p, "rb").read() if os.path.isfile(p) else None
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
        if oa.rtext == ob.rtext and oa.rdata == ob.rdata and len(oa.syms) == len(ob.syms) and all(
                x.name == y.name and x.typ == y.typ and (x.wert == y.wert or x.name.startswith(b"~")) for x, y in zip(oa.syms, ob.syms)):
            return "E1"     # only the value of `~f` symbols differs (see doc)
        t.append("relocations/symbols differ")
    return "; ".join(t)


def befehle(obj, tmp):
    """[(addr, mnemonic)] of the text of object `obj` (code entries: offset 0 and every text symbol)."""
    kp, rp = os.path.join(tmp, "k.txt"), os.path.join(tmp, "i.raw")
    ein = {0} | {x.wert for x in obj.syms if x.basistyp == O.N_TEXT and not x.name.startswith(b"~") and x.wert < len(obj.text)}
    open(kp, "w").write("".join("code %04X\n" % a for a in sorted(ein)))
    open(rp, "wb").write(obj.maskierter_text()[0])
    o, _ = U.z8kdis(["--karte", kp, rp])
    return [(a, m) for a, _b, m in U.befehle_lesen(o)]


def diffen(name, kontext=3):
    """instruction diff built (work/bau) vs shipped member, via z8kdis"""
    import difflib
    import tempfile
    t = tempfile.mkdtemp(prefix="wk_w8_")
    # relocated words (addresses of data/bss/externals) are zeroed: only the code is compared
    a = befehle(O.Objekt.lesen(open(os.path.join(WORK, "bau", name + ".o"), "rb").read()), t)
    b = befehle(O.Objekt.lesen(schiff(name)), t)
    ma = [m for _a, m in a]
    mb = [m for _a, m in b]
    for z in difflib.unified_diff(mb, ma, "shipped", "built", n=kontext, lineterm=""):
        print(z)
    # relocations and symbols (plain words left out)
    def meta(b):
        return [z for z in O.dump(O.Objekt.lesen(b)).split("\n") if z.startswith("  sym") or "#" in z or " pc" in z
                or z.startswith("  text") and ("abs" in z or "text" in z.split(":", 1)[-1] or "data" in z.split(":", 1)[-1])
                or not z.startswith("  ")]
    for z in difflib.unified_diff(meta(schiff(name)), meta(open(os.path.join(WORK, "bau", name + ".o"), "rb").read()),
                                  "shipped", "built", n=1, lineterm=""):
        print(z)


def modell(s):
    """Model of the c2 that built the shipped libc.a, applied to a `cc -O -S` source (MODEL, not a run of it):
      T1 `~~f:` moves before the `G|I f PR` line (the shipped objects hold the real address in the `~f` symbol of static functions)
      R130 `inc SP,#%A ; push @SP,r2` -> `inc SP,#%8 ; ld @SP,r2` (as in c0, doc/userspace/wk_w4.md)"""
    z = s.split("\n")
    n = {"R130": 0}
    for i in range(len(z) - 1):
        if z[i] == "inc\tSP,#%A" and z[i + 1].startswith("push\t@SP,"):
            z[i], z[i + 1] = "inc\tSP,#%8", "ld\t@SP," + ("#" if z[i + 1][10:11] == "%" else "") + z[i + 1][10:]
            n["R130"] += 1
    return "\n".join(z), n


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
        if art in "cS":
            quellen[n + ".c"] = quelle_c(n)
            befehle.append("cd /tmp;cc -O -%s -I/mnt /mnt/%s.c >%s.err 2>&1;cd /mnt" % (art if art == "S" else "c", n, n))
            if art == "S":
                rueck.append(n + ".s")
                rueck.append(n + ".err")
                continue
        else:
            pf = (os.path.join(WORK, "bau", n + ".m.s") if art == "m" else
                  os.path.join(WORK, "var", n + ".s") if "__" in n else os.path.join(LIBC, n + ".s"))
            quellen[n + ".s"] = open(pf, "rb").read()
            befehle.append("cd /tmp;>asm.out;as -u /mnt/%s.s >%s.err 2>&1;cat asm.out >%s.o;cd /mnt" % (n, n, n))
        rueck += [n + ".o", n + ".err"]
    for h in EXTRA_INC:
        quellen[h] = open(os.path.join(V7INC, h), "rb").read()
    aus = {}
    os.makedirs(WORK, exist_ok=True)
    r = gast_as.gast_befehle(os.path.join(WORK, "gast_" + art), quellen, befehle, rueck, frist=frist, ausgabe=aus)
    print("guest run: %.0f s wall clock" % aus.get("dauer", 0))
    return {n: ((r.get(n + ".err") or b"").decode("latin-1").strip(), r.get(n + (".s" if art == "S" else ".o"))) for n in namen}


def asm_varianten(namen):
    """Distinct userspace/libc_alt/**/NAME.s texts (reconstructed from program images) as variants work/var/NAME__vK.s."""
    import glob
    import hashlib
    os.makedirs(os.path.join(WORK, "var"), exist_ok=True)
    erg = []
    for n in namen:
        seen = {}
        for f in sorted(glob.glob(os.path.join(REPO, "userspace", "libc_alt", "*", n + ".s"))):
            t = open(f, "rb").read()
            seen.setdefault(hashlib.md5(t).hexdigest(), (f, t))
        for k, (f, t) in enumerate(seen.values()):
            v = "%s__v%d" % (n, k)
            open(os.path.join(WORK, "var", v + ".s"), "wb").write(t)
            open(os.path.join(WORK, "var", v + ".from"), "w").write(os.path.relpath(f, REPO) + "\n")
            erg.append(v)
    return erg


def stapel(namen, art, grenze=110_000):
    """split the names into guest runs whose sources fit on the source disk"""
    gr, cur, size = [], [], 0
    for n in namen:
        f = os.path.join(WORK, "var", n + (".c" if art == "c" else ".s")) if "__" in n else os.path.join(LIBC, n + (".c" if art == "c" else ".s"))
        z = os.path.getsize(f) if os.path.isfile(f) else 4000
        if cur and (size + z > grenze or len(cur) >= 40):
            gr.append(cur)
            cur, size = [], 0
        cur.append(n)
        size += z
    return gr + ([cur] if cur else [])


def bauen(namen, art):
    os.makedirs(os.path.join(WORK, "bau"), exist_ok=True)
    erg = {}
    for st in stapel(namen, art):
        erg.update(gast(st, art))
    for n in namen:
        err, ob = erg[n]
        if ob:
            open(os.path.join(WORK, "bau", n + ".o"), "wb").write(ob)
        res = "NO OBJECT" if not ob else vergleich(ob, schiff(n.split("__")[0]))
        print("%-9s %-4s %s%s" % (n, res if res in ("G", "E1") else "-", res if res not in ("G", "E1") else "", ("  cc: " + err[:150].replace("\n", " | ")) if err else ""))
    return 0


def main(argv):
    if not argv or argv[0] not in ("holen", "cbau", "sbau", "archiv", "diff", "ssau", "mbau", "abau"):
        print(__doc__)
        return 2
    try:
        U.pruefe()
        if argv[0] == "holen":
            ar = holen()
            print("%d members" % len(ar.mitglieder))
        elif argv[0] == "mbau":      # work/bau/NAME.s (from ssau) -> model -> guest as -> compare
            for n in argv[1:]:
                t, c = modell(open(os.path.join(WORK, "bau", n + ".s")).read())
                open(os.path.join(WORK, "bau", n + ".m.s"), "w").write(t)
                print(n, {k: v for k, v in c.items() if v})
            return bauen(argv[1:], "m")
        elif argv[0] == "abau":      # libc_alt .s variants of the given members -> guest as -> compare
            return bauen(asm_varianten(argv[1:]), "s")
        elif argv[0] == "ssau":
            erg = gast(argv[1:], "S")
            for n in argv[1:]:
                open(os.path.join(WORK, "bau", n + ".s"), "w").write((erg[n][1] or b"").decode("latin-1")) if os.makedirs(os.path.join(WORK, "bau"), exist_ok=True) is None else None
            print({n: erg[n][0] for n in argv[1:]})
        elif argv[0] == "diff":
            diffen(argv[1])
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
