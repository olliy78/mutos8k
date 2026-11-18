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
                x.name == y.name and x.typ == y.typ and (x.wert == y.wert or x.name.startswith(b"~") or x.basistyp == 0x1E)
                for x, y in zip(oa.syms, ob.syms)):
            return "E1"     # only the value of `~f` symbols / section symbols differs (see doc)
        def gest(q):    # relocation kinds with the names of externals (symbol numbering is irrelevant)
            return [[(off, r.art, q.syms[r.sym].name if r.art == O.R_EXT else None) for off, r in q.relocs(k)] for k in ("text", "data")]
        if gest(oa) == gest(ob):
            return "A1"     # text, data, bss and relocation words equal; the symbol table (order, local labels) differs
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


def hochziehen(name, text):
    """Declare the external symbols of the shipped member (in the shipped table order) before the first G/I line, so the
    object's symbol table starts with them like the shipped one (`as -u` otherwise creates them at first use)."""
    o = O.Objekt.lesen(schiff(name))
    decl = []
    for x in o.syms:
        if x.basistyp == O.N_UNDF and x.ext:
            nm = x.name.decode("latin-1")
            decl.append("X\t%s\tA[%%%X B]" % (nm, x.wert) if x.wert else "X\t%s\tPR;" % nm)
    z = text.decode("latin-1").split("\n")
    i = next(k for k, l in enumerate(z) if re.match(r"[GI]\t", l))
    return "\n".join(z[:i] + decl + z[i:]).encode("latin-1")


def umbenennen(name, text, gebaut):
    """Give the generated labels (L1592, B23B0, D2730) the names of the shipped member's local symbols with the same
    section and value (V7 labels: $1, $2, nd, dvect ...); a generated label without a shipped counterpart is dropped."""
    sh = O.Objekt.lesen(schiff(name))
    ob = O.Objekt.lesen(gebaut)
    soll = {(x.basistyp, x.wert): x.name.decode() for x in sh.syms if not x.ext and x.basistyp in (O.N_TEXT, O.N_DATA, O.N_BSS)
            and not x.name.startswith(b"~") and not re.match(rb"L\d+$", x.name)}
    ren = {}
    for x in ob.syms:
        if not x.ext and x.basistyp in (O.N_TEXT, O.N_DATA, O.N_BSS) and re.match(rb"[LBD][0-9A-F]{3,4}$", x.name):
            r = soll.get((x.basistyp, x.wert))
            if r is None:       # no shipped label here: references become `previous label + offset`
                prev = [(w, nm) for (bt, w), nm in soll.items() if bt == x.basistyp and w < x.wert]
                if prev and re.search(r"[^\w]" + x.name.decode() + r"\b(?!:)", text.decode("latin-1")):
                    w, nm = max(prev)
                    r = "%s+%%%X" % (nm, x.wert - w)
                    ren["#" + x.name.decode()] = r
            ren[x.name.decode()] = r if not r or "+" not in r else None
    out = []
    for l in text.decode("latin-1").split("\n"):
        m = re.match(r"(\w+):\s*$", l)
        if m and m[1] in ren:
            if ren[m[1]] is None:
                continue
            l = ren[m[1]] + ":"
        elif re.match(r"\s*[BD][0-9A-F]{3,4}:?\s*$", l) and l.strip().rstrip(":") in ren:
            continue
        else:
            l = re.sub(r"\b([LBD][0-9A-F]{3,4})\b", lambda k: ren.get("#" + k[1]) or (ren[k[1]] if ren.get(k[1]) else k[1]), l)
        out.append(l)
    # shipped text labels the source does not define yet (the generated source only labels jump targets; the shipped one also
    # carries named entry points that open a new scope for the generic labels $n): insert them in front of the instruction
    defd = {l.split(":")[0].strip() for l in out if re.match(r"\s*[^\s;]+:\s*$", l)}
    fehl = {w: nm for (bt, w), nm in soll.items() if bt == O.N_TEXT and nm not in defd}
    if fehl:
        import tempfile
        adr = [a for a, _m in befehle(ob, tempfile.mkdtemp())]
        k0 = next(i for i, l in enumerate(out) if l == "E") + 1
        ins = [i for i in range(k0, len(out)) if re.match(r"\t[a-z]", out[i])]
        if len(ins) != len(adr):
            print("%s: %d instruction lines, %d listed instructions: labels %s not inserted" % (name, len(ins), len(adr), sorted(fehl.values())))
        else:
            ad2line = dict(zip(adr, ins))
            for w in sorted(fehl, key=lambda w: -ad2line.get(w, -1)):
                if w in ad2line:
                    out.insert(ad2line[w], fehl[w] + ":")
    return "\n".join(out).encode("latin-1")


def wv_quelle(name):
    """as source of a shipped member whose text is written as data words (`WV`) -- for members with instructions the guest tool
    chain cannot produce (EPA/floating point codegen) or no decoder knows.  Externals, exported/local text labels, data and bss
    labels come from the shipped symbol table; relocated words become symbol expressions."""
    o = O.Objekt.lesen(schiff(name))
    w = open(os.path.join(LIBC, "write.s"), encoding="latin-1").read()
    hdr = w[:w.index("G\t_write")].replace("X\tcerror\tPR;\n", "").replace("write_ module", name + "_ module")
    hdr = hdr.split("\n", 1)[1] if hdr.startswith("!") else hdr
    note = "! RECONSTRUCTED (W8): text and data of the shipped libc.a member as data words (no source with these instructions), labels from its symbol table !\n"
    nt, nd = len(o.text), len(o.data)
    ext = [x for x in o.syms if x.basistyp == O.N_UNDF]
    names = {}      # (kind, address) -> [names]
    for x in o.syms:
        k = {O.N_TEXT: "t", O.N_DATA: "d", O.N_BSS: "b"}.get(x.basistyp)
        if k and not x.name.startswith(b"~") and not re.match(rb"L\d+$", x.name):
            names.setdefault((k, x.wert - (nt if k == "d" else nt + nd if k == "b" else 0)), []).append((x.name.decode(), x.ext))
    rt, rd = dict(o.relocs("text")), dict(o.relocs("data"))
    gen = set()

    def ref(kind, addr):
        if (kind, addr) not in names:
            names[(kind, addr)] = [("%s%X" % (kind.upper(), addr), False)]
            gen.add((kind, addr))
        return names[(kind, addr)][0][0]

    def word(w, r, base):
        if r is None:
            return "WV\t%%%X" % w
        if r.art == O.R_EXT:
            return "WV\t" + o.syms[r.sym].name.decode() + ("+%%%X" % w if w else "")
        k, a = ("t", w) if r.art == O.R_TEXT else ("d", w) if r.art == O.R_DATA else ("b", w)
        if k == "d":
            a -= nt
        elif k == "b":
            a -= nt + nd
        return "WV\t" + ref(k, a)

    code = []
    for i in range(0, nt, 2):
        r = rt.get(i)
        code.append((i, word(int.from_bytes(o.text[i:i + 2], "big"), r, 0)))
    data = []
    for i in range(0, nd, 2):
        data.append((i, word(int.from_bytes(o.data[i:i + 2], "big"), rd.get(i), 0)))
    exports = [(a, n) for (k, a), L in sorted(names.items()) if k == "t" for n, e in L if e]
    first = min(exports)[1] if exports else name
    out = [note + hdr.replace(name + "_ module", name + "_ module")]
    out = [out[0].replace("\n$NONSEGMENTED", "\n$NONSEGMENTED", 1)]
    t = "".join("X\t%s\t%s\n" % (x.name.decode(), "A[%%%X B]" % x.wert if x.wert else "PR;") for x in ext)
    t += "".join("G\t%s\tL\n" % n for a, n in sorted(exports) if n != first)
    t += "G\t%s\tPR\nE\n" % first
    for a, wv in code:
        for n, e in names.get(("t", a), []):
            t += n + ":\n"
        t += "\t" + wv + "\n"
    for n, e in names.get(("t", nt), []):
        t += n + ":\n"
    t += "end %s\n" % first
    dsec = ""
    if nd:
        dsec += "I\n"
        for a, wv in data:
            for n, e in names.get(("d", a), []):
                dsec += ("G\n%s\tL\n" % n if e else "") + n + ":\n" + ("I\n" if e else "")
            dsec += wv + "\n"
    bsec = ""
    if o.bss:
        bsec += "$SECTION BSS_B\nI\n"
        pos = 0
        for (k, a), L in sorted(names.items()):
            if k != "b":
                continue
            if a > pos:
                bsec += "$REL\t$+%%%X\n" % (a - pos)
                pos = a
            for n, e in L:
                bsec += ("G\n%s\tL\n" % n if e else "") + n + ":\n" + ("I\n" if e else "")
        if o.bss > pos:
            bsec += "$REL\t$+%%%X\n" % (o.bss - pos)
        bsec += "$SDEFAULT\n"
    return (out[0] + t + dsec + bsec + "end %s_\n" % name).encode("latin-1")


def archiv(blau=None):
    """Archive in the shipped member order with the shipped headers (date, uid, gid, mode), member data = our objects from work/bau
    (NAME.o) -- the guard `shipped members -> archive == libc.a` shows that order, headers and padding are reproduced."""
    soll = open(os.path.join(WORK, "libc.a"), "rb").read()
    ar = O.Archiv.lesen(soll)
    probe = O.Archiv([O.Mitglied(m.name, m.datum, m.uid, m.gid, m.mode, m.daten, m.pad) for m in ar.mitglieder]).schreiben()
    print("structure guard (shipped members): %s" % ("identical" if probe == soll else "DIFFERENT"))
    neu, stat = [], {}
    for m in ar.mitglieder:
        n = m.name.decode()[:-2]
        p = os.path.join(WORK, "bau", n + ".o")
        d = open(p, "rb").read() if os.path.isfile(p) else None
        stat[n] = "missing" if d is None else "G" if d == m.daten else "diff"
        neu.append(O.Mitglied(m.name, m.datum, m.uid, m.gid, m.mode, d if d is not None else m.daten, m.pad if d is None or len(d) == len(m.daten) else (b"\0" if len(d) & 1 else b"")))
    b = O.Archiv(neu).schreiben()
    open(os.path.join(WORK, "libc_w8.a"), "wb").write(b)
    n = sum(1 for v in stat.values() if v == "G")
    print("archive from our objects: %d B (shipped %d B), %d of %d members identical, archive %s" % (
        len(b), len(soll), n, len(stat), "IDENTICAL" if b == soll else "differs"))
    for k, v in stat.items():
        if v != "G":
            print("  not identical: %s (%s)" % (k, v))
    return 0 if b == soll else 1


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
        print("%-9s %-4s %s%s" % (n, res if res in ("G", "E1", "A1") else "-", res if res not in ("G", "E1", "A1") else "", ("  cc: " + err[:150].replace("\n", " | ")) if err else ""))
    return 0


def main(argv):
    if not argv or argv[0] not in ("holen", "cbau", "sbau", "archiv", "diff", "ssau", "mbau", "abau", "hbau", "rbau", "wbau"):
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
        elif argv[0] == "hbau":      # NAME=K: variant NAME__vK (from abau) with hoisted external declarations
            vs = []
            for a in argv[1:]:
                n, k = a.split("=")
                v = "%s__h%s" % (n, k)
                t = open(os.path.join(WORK, "var", "%s__v%s.s" % (n, k)), "rb").read()
                open(os.path.join(WORK, "var", v + ".s"), "wb").write(hochziehen(n, t))
                vs.append(v)
            return bauen(vs, "s")
        elif argv[0] == "rbau":      # NAME=K: rename labels of NAME__hK like the shipped symbols (needs the object from hbau)
            vs = []
            for a in argv[1:]:
                n, k = a.split("=")
                v = "%s__r%s" % (n, k)
                t = open(os.path.join(WORK, "var", "%s__h%s.s" % (n, k)), "rb").read()
                g = open(os.path.join(WORK, "bau", "%s__h%s.o" % (n, k)), "rb").read()
                open(os.path.join(WORK, "var", v + ".s"), "wb").write(umbenennen(n, t, g))
                vs.append(v)
            return bauen(vs, "s")
        elif argv[0] == "wbau":      # members as data-word sources -> userspace/libc/NAME.s -> guest as -> compare
            for n in argv[1:]:
                open(os.path.join(LIBC, n + ".s"), "wb").write(wv_quelle(n))
            return bauen(argv[1:], "s")
        elif argv[0] == "abau":      # libc_alt .s variants of the given members -> guest as -> compare
            return bauen(asm_varianten(argv[1:]), "s")
        elif argv[0] == "ssau":
            erg = gast(argv[1:], "S")
            for n in argv[1:]:
                open(os.path.join(WORK, "bau", n + ".s"), "w").write((erg[n][1] or b"").decode("latin-1")) if os.makedirs(os.path.join(WORK, "bau"), exist_ok=True) is None else None
            print({n: erg[n][0] for n in argv[1:]})
        elif argv[0] == "archiv":
            return archiv()
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
