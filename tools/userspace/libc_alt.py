"""libc_alt: rebuild the members of the libc part of an ORIGINAL program as as-sources (doc/userspace/libc_alt.md).

The original programs of the root disk were linked against an OLDER libc.a than the one shipped on `usr`/`cc2`
(see doc/userspace/init.md).  Its members are not available as objects, so they are written back from the program
image: z8kdis --format as gives the instruction text of one member, this module adds the object structure
(external symbols, data, bss, relocations) that the guest `as` needs to turn the text into an object which `ld`
places exactly like the original.

  python3 -I tools/userspace/libc_alt.py quelle  NAME   # members file -> userspace/libc_alt/NAME/*.s (host only)
  python3 -I tools/userspace/libc_alt.py bau     NAME   # guest: as every .s, host: ar -> NAME/libc_alt.a, guard
  python3 -I tools/userspace/libc_alt.py pruefen NAME   # host-side guard on the objects of the last build

Members file: userspace/libc_alt/NAME.members (format in the file header).  Working directory: userspace/libc_alt/work.
Exit 77 = emulator or disk missing.
"""
import os
import re
import struct
import subprocess
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
LIBDIR = os.path.join(REPO, "userspace", "libc_alt")


class Mitglied:
    def __init__(self, name):
        self.name = name
        self.t0 = self.t1 = 0
        self.data = None         # (from, to) or None
        self.bss = None          # (addr, size) or None
        self.exp = None          # {sym: addr} explicit, None = from the shipped member
        self.code = []           # extra code entries
        self.neu = False
        self.sym = {}            # resolved exports {sym: (addr, kind)}  kind T text, D data, B bss
        self.src = None          # A init archive, S shipped, G gap (only G members go into the program's archive)
        self.noimm = set()       # instruction addresses whose immediate only looks like an address (noimm=ADDR,...)
        self.nodptr = set()      # data word addresses that are NOT pointers (nodptr=ADDR,...)


def parse(pfad):
    """members file -> (list of Mitglied, commons [(sym, addr, size)])"""
    ms, com, ext = [], [], []
    for z in open(pfad):
        z = z.split("#")[0].strip()
        if not z:
            continue
        t = z.split()
        if t[0] == "extern":
            ext.append((t[1], int(t[2], 16), int(t[3], 16)))
            continue
        if t[0] == "common":
            com.append((t[1], int(t[2], 16), int(t[3], 16), t[4] if len(t) > 4 else None))
            continue
        m = Mitglied(t[0])
        m.t0, m.t1 = int(t[1], 16), int(t[2], 16)
        for o in t[3:]:
            if o == "new":
                m.neu = True
            elif o.startswith("data="):
                a, b = o[5:].split(":")
                m.data = (int(a, 16), int(b, 16))
            elif o.startswith("bss="):
                a, b = o[4:].split(":")
                m.bss = (int(a, 16), int(b, 16))
            elif o.startswith("exp="):
                m.exp = {}
                for e in o[4:].split(","):
                    s, a = e.split("@")
                    m.exp[s] = int(a, 16)
            elif o.startswith("noimm="):
                m.noimm = {int(x, 16) for x in o[6:].split(",")}
            elif o.startswith("nodptr="):
                m.nodptr = {int(x, 16) for x in o[7:].split(",")}
            elif o.startswith("src="):
                m.src = o[4:]
            elif o.startswith("code="):
                m.code = [int(x, 16) for x in o[5:].split(",")]
            else:
                raise SystemExit("members file: unknown option %s" % o)
        ms.append(m)
    return ms, com, ext


# ---------------------------------------------------------------- symbols of the shipped members
def diskette_objekte(libc):
    """{member name without .o: Objekt} of the shipped libc.a."""
    return {m.name.decode("latin-1")[:-2]: m.objekt() for m in O.Archiv.lesen(libc).mitglieder}


def symbole_aufloesen(ms, dobj):
    """Fill Mitglied.sym: exported text/data symbols with their image addresses."""
    for m in ms:
        if m.exp is not None:
            for s, a in m.exp.items():
                kind = ("B" if m.bss and m.bss[0] <= a < m.bss[0] + m.bss[1] else
                        "D" if (m.data and m.data[0] <= a < m.data[1] and not (m.t0 <= a < m.t1)) else "T")
                m.sym[s] = (a, kind)
            continue
        o = dobj.get(m.name)
        if o is None:
            raise SystemExit("member %s: not in the shipped libc.a and no exp=" % m.name)
        if len(o.text) != m.t1 - m.t0:
            raise SystemExit("member %s: text %d B in the image, %d B in the shipped libc.a: give exp=" %
                             (m.name, m.t1 - m.t0, len(o.text)))
        for x in o.syms:
            if x.ext and x.basistyp in (O.N_TEXT, O.N_DATA, O.N_BSS):
                nm = x.name.decode("latin-1")
                if x.basistyp == O.N_TEXT:
                    m.sym[nm] = (m.t0 + x.wert, "T")
                elif x.basistyp == O.N_DATA:     # data symbol values are text-size relative in the object
                    m.sym[nm] = (m.data[0] + x.wert - len(o.text), "D")
                else:                            # bss values are text+data size relative
                    m.sym[nm] = (m.bss[0] + x.wert - len(o.text) - len(o.data), "B")
    return ms


def alle_symbole(ms, com):
    """Sorted address table of all global symbols: [(addr, name, kind, member|None)], kind T D C(common) B(bss)."""
    t = []
    for m in ms:
        for s, (a, k) in m.sym.items():
            t.append((a, s, k, m))
    for s, a, sz, _o in com:
        t.append((a, s, "C", None))
    return sorted(t, key=lambda x: (x[0], x[1]))


# ---------------------------------------------------------------- z8kdis views of one member
STD_KONST = {"FP", "SP", "X", "G", "I", "A", "PR", "E", "B", "W", "BV", "WV", "LV", "L"}


def karte_text(basis_karte, ms, laenge):
    """Map for the whole image: the program's map plus a code entry for every text export / explicit code= of the members."""
    zeilen = [z for z in basis_karte.split("\n") if z.strip() and not z.startswith("#") and not z.startswith("name ")]
    codes = {z.split()[1] for z in zeilen if z.startswith("code ")}
    for m in ms:
        for a in [a for a, k in m.sym.values() if k == "T"] + m.code:
            if "%04X" % a not in codes and a != 0:
                zeilen.append("code %04X" % a)
                codes.add("%04X" % a)
        if m.t1 > m.t0 and "%04X" % m.t0 not in codes:
            zeilen.append("code %04X" % m.t0)
            codes.add("%04X" % m.t0)
    return "\n".join(zeilen) + "\n"


def referenzen(raw, karte):
    """z8kdis --referenzen -> {instruction addr: [(art, value, text)]}"""
    import tempfile
    d = tempfile.mkdtemp(prefix="libc_alt_")
    kp, rp = os.path.join(d, "k.txt"), os.path.join(d, "i.raw")
    open(kp, "w").write(karte)
    open(rp, "wb").write(raw)
    o, _ = U.z8kdis(["--karte", kp, "--referenzen", rp])
    erg = {}
    for z in o.split("\n"):
        t = z.split(None, 3)
        if len(t) == 4:
            erg.setdefault(int(t[0], 16), []).append((t[1], int(t[2], 16), t[3]))
    return erg, kp, rp


def stueck(kp, rp, name, von, bis):
    """as text of the piece [von,bis) of the image"""
    o, _ = U.z8kdis(["--karte", kp, "--format", "as", "--modul", name, "--teil", "%X:%X" % (von, bis), rp])
    return o


def listing_befehle(kp, rp):
    """[(addr, mnemonic text)] of the listing (DW lines included as 'DW ...')"""
    o, _ = U.z8kdis(["--karte", kp, rp])
    return [(a, m) for a, _b, m in U.befehle_lesen(o)]


# ---------------------------------------------------------------- guard: relocate an object like ld and compare
def adresse_von(tab, name):
    """image address of a global symbol name (exports, commons, bss labels)"""
    for a, n, _k, _m in tab:
        if n == name:
            return a
    return None


def relozieren(m, obj, tab):
    """(text, data) of the object `obj` of member `m` as ld would place them in the program image.
    Relocation words: text -> + member text base, data/bss -> placement of the member's data/bss, ext -> symbol address."""
    tl, dl = len(obj.text), len(obj.data)
    out = []
    for teil, b, rel in (("text", obj.text, obj.rtext), ("data", obj.data, obj.rdata)):
        w = bytearray(b)
        for i, r in enumerate(rel):
            if not r:
                continue
            art, sym = (r >> 1) & 7, r >> 4
            v = struct.unpack(">H", w[2 * i:2 * i + 2])[0]
            if art == O.R_TEXT:
                v = v + m.t0
            elif art == O.R_DATA:
                v = m.data[0] + (v - tl)
            elif art == O.R_BSS:
                v = m.bss[0] + (v - tl - dl)
            elif art == O.R_EXT:
                s = obj.syms[sym]
                a = adresse_von(tab, s.name.decode("latin-1"))
                if a is None:
                    raise ValueError("%s: unresolved external %s" % (m.name, s.name.decode("latin-1")))
                v = v + a
            w[2 * i:2 * i + 2] = struct.pack(">H", v & 0xFFFF)
        out.append(bytes(w))
    return out


def archiv_bauen(objekte):
    """objekte: [(name, bytes)] in archive order -> archive bytes (header fields like the shipped libc.a)"""
    mem = [O.Mitglied((n + ".o").encode(), 0x1F02A970, 0, 0, 0o100664, b) for n, b in objekte]
    return O.Archiv(mem).schreiben()


# ---------------------------------------------------------------- one member -> as source
ASM_KOPF = """$NONSEGMENTED
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


class Fehler(Exception):
    pass


def stueck_zerlegen(text):
    """as piece of z8kdis -> (constants {name: addr}, body lines between `E` and the last `end`)"""
    z = text.split("\n")
    konst, i = {}, 0
    while z[i] != "constant":
        i += 1
    i += 1
    while not z[i].startswith("G\t"):
        m = re.match(r"\t(\S+)\t:= %([0-9A-F]+)$", z[i])
        if m and m.group(1) not in STD_KONST:
            konst[m.group(1)] = int(m.group(2), 16)
        i += 1
    while z[i] != "E":
        i += 1
    i += 1
    ende = max(j for j, x in enumerate(z) if x.startswith("end "))
    ende = max(j for j, x in enumerate(z[:ende]) if x.startswith("end "))
    return konst, z[i:ende]


def ist_befehl(z):
    return z.startswith("\t") and not re.match(r"\t(WV|BV|LV)\b", z)


class Quelle:
    """Builds the as source of one member from the image."""

    def __init__(self, ctx, m):
        self.c, self.m = ctx, m

    # -- address classification -------------------------------------------------------------------
    def im_bereich(self, a):
        """address -> ('T'|'D'|'B', member) or None, over all members/commons"""
        for m in self.c.ms:
            if m.t0 <= a < m.t1:
                return "T", m
            if m.data and m.data[0] <= a < m.data[1]:
                return "D", m
            if m.bss and m.bss[0] <= a < m.bss[0] + m.bss[1]:
                return "B", m
        for s, ad, sz, _o in self.c.com:
            if ad <= a < ad + sz:
                return "C", s
        for s, ad, sz in self.c.ext:
            if ad <= a < ad + max(sz, 1):
                return "E", s
        return None

    def ausdruck(self, a, kontext):
        """as expression for the image address `a`, referenced from this member; records needs."""
        b = self.im_bereich(a)
        if b is None:
            raise Fehler("%s: address %04X outside every member (context: %s)" % (self.m.name, a, kontext))
        art, w = b
        eigen = (w is self.m)
        if not eigen:           # `block - 1` style address one byte before the member's own data/bss start
            b1 = self.im_bereich(a + 1)
            if b1 is not None and b1[1] is self.m and b1[0] in "DB" and not (self.m.t0 <= a + 1 < self.m.t1):
                return self.ausdruck(a + 1, kontext) + "-%1"
        if art in "CE":
            ad = [x for x in (self.c.com if art == "C" else self.c.ext) if x[0] == w][0][1]
            return w if a == ad else "%%%X+%s" % (a - ad, w)
        # nearest preceding global symbol of that member and kind
        if art == "T":
            cand = [(ad, s) for s, (ad, k) in w.sym.items() if k == "T" and ad <= a]
            if eigen:
                for s, (ad, k) in w.sym.items():
                    if k == "T" and ad == a:
                        return s
                self.labels_text.add(a)
                return "L%04X" % a
        elif art == "D":
            cand = [(ad, s) for s, (ad, k) in w.sym.items() if k == "D" and ad <= a]
            if eigen:
                self.labels_data.add(a)
                for s, (ad, k) in w.sym.items():
                    if k == "D" and ad == a:
                        return s
                return "D%04X" % a
        else:
            cand = [(ad, s) for s, (ad, k) in w.sym.items() if k == "B" and ad <= a]
            if eigen:
                self.labels_bss.add(a)
                for s, (ad, k) in w.sym.items():
                    if k == "B" and ad == a:
                        return s
                return "B%04X" % a
        if not cand:
            raise Fehler("%s: %04X in %s of %s without an exported symbol before it (context: %s)" %
                         (self.m.name, a, art, w.name, kontext))
        ad, s = max(cand)
        return s if a == ad else "%%%X+%s" % (a - ad, s)


def _ersetze_token(zeile, v, konst):
    """first token of `zeile` that denotes the value v (constant name, Lxxxx, %hex) -> (start, end, token) or None"""
    for mt in re.finditer(r"L[0-9A-F]{4}\b|%[0-9A-F]+\b|[A-Za-z_][A-Za-z_0-9]*", zeile):
        t = mt.group()
        if t in konst:
            w = konst[t]
        elif re.match(r"L[0-9A-F]{4}$", t):
            w = int(t[1:], 16)
        elif t[0] == "%":
            w = int(t[1:], 16)
        else:
            continue
        if w == v:
            return mt.start(), mt.end(), t
    return None


def code_umschreiben(self):
    """Body lines of the member's code with all address operands turned into symbolic expressions."""
    c, m = self.c, self.m
    piece = stueck(c.kp, c.rp, m.name, m.t0, m.t1)
    konst, body = stueck_zerlegen(piece)
    for sn, (ad, k) in m.sym.items():           # own export labels also denote their address
        if k == "T":
            konst.setdefault(sn, ad)
    # z8kdis marks a jr whose target lies at the very edge of the range (-254 bytes) as `! jr L !` + data word, and the old
    # `as` rejects that jr as well: keep the comment and the word (WV %E881 assembles to exactly the original jr)
    erlaubt = {i for i in range(1, len(body)) if re.match(r"\t! jr\s+\S+ !$", body[i - 1])}
    daten_im_code = [z for i, z in enumerate(body) if re.match(r"\t(WV|BV|LV)\b", z) and i not in erlaubt]
    if daten_im_code:
        raise Fehler("%s: z8kdis left data words in the code (add code= entries): %s" % (m.name, daten_im_code[:2]))
    adr = [a for a, mn in c.befehle if m.t0 <= a < m.t1]
    ins = [i for i, z in enumerate(body) if ist_befehl(z)]
    if len(adr) != len(ins):
        raise Fehler("%s: %d listing instructions, %d source instructions" % (m.name, len(adr), len(ins)))
    self.addr_of = dict(zip(ins, adr))
    neu = list(body)
    for i, a in self.addr_of.items():
        z = neu[i]
        werte = []
        for art, v, txt in c.refs.get(a, []):
            if art not in ("DA", "IMW", "X"):
                continue
            if art == "X" and (re.search(r"\(r14\)", z, re.I) or v < 0x100 or v >= 0xFF00):
                continue
            if art == "IMW" and (self.im_bereich(v) is None or a in m.noimm):
                continue
            if art == "IMW" and m.t0 <= v < m.t1 and False:
                continue
            if art == "DA" and self.im_bereich(v) is None:
                raise Fehler("%s: %04X: direct address %04X in no member (`%s`)" % (m.name, a, v, z.strip()))
            if v not in werte:
                werte.append(v)
        for v in werte:
            r = _ersetze_token(z, v, konst)
            if r is None:
                raise Fehler("%s: %04X: operand value %04X not found in `%s`" % (m.name, a, v, z.strip()))
            s0, s1, t = r
            ex = self.ausdruck(v, "%04X %s" % (a, z.strip()))
            if t == ex:
                continue
            z = z[:s0] + ex + z[s1:]
        # out-of-piece names that were not flagged as address operands (call/jp to other members)
        for mt in list(re.finditer(r"[A-Za-z_][A-Za-z_0-9]*", z)):
            t = mt.group()
            if t in konst:
                z = z[:mt.start()] + self.ausdruck(konst[t], "%04X %s" % (a, z.strip())) + z[mt.end():]
                break
        neu[i] = z
    self.body = neu


def daten_zeilen(self):
    """`I` section lines for the member's data; collects the labels it needs."""
    c, m = self.c, self.m
    if not m.data or m.data[1] <= m.data[0]:
        return []
    d0, d1 = m.data
    raw = c.raw
    ptr = {}
    for a in range(d0, d1 - 1, 2):
        v = struct.unpack(">H", raw[a:a + 2])[0]
        tm = c.dobj.get(m.name)         # same-size shipped member: a data word is a pointer only where it has a relocation
        if tm is not None and len(tm.data) == m.data[1] - m.data[0] and m.src in ("S", "A", "G"):
            if (a - m.data[0]) not in {off for off, _r in tm.relocs("data")}:
                continue
        if self.im_bereich(v) is not None and v >= 0x30 and a not in m.nodptr:
            ptr[a] = self.ausdruck(v, "data word at %04X" % a)
    return ptr


def daten_ausgeben(self, ptr):
    c, m = self.c, self.m
    d0, d1 = m.data
    raw = c.raw
    lab = {}
    for a in self.labels_data:
        lab.setdefault(a, []).append(("L", "D%04X" % a))
    for s, (ad, k) in m.sym.items():
        if k == "D":
            lab.setdefault(ad, []).append(("G", s))
    z = ["I"]
    a = d0
    buf = []

    def spuelen():
        for i in range(0, len(buf), 8):
            z.append(";".join("BV %%%X" % b for b in buf[i:i + 8]))
        del buf[:]
    while a < d1:
        if a in lab:
            spuelen()
            for k, n in lab[a]:
                if k == "G":
                    z += ["G", "%s\tL" % n, "%s:" % n]
                else:
                    z.append("%s:" % n)
        if a in ptr:
            spuelen()
            z.append("WV %s" % ptr[a])
            a += 2
        else:
            buf.append(raw[a])
            a += 1
    spuelen()
    return z


def bss_ausgeben(self):
    c, m = self.c, self.m
    z = []
    if m.bss:
        b0, sz = m.bss
        lab = {}
        for a in self.labels_bss:
            lab.setdefault(a, []).append(("L", "B%04X" % a))
        for s, (ad, k) in m.sym.items():
            if k == "B":
                lab.setdefault(ad, []).append(("G", s))
        z += ["$SECTION BSS_B", "I"]
        pos = b0
        for a in sorted(lab):
            if a > pos:
                z.append("$REL\t$+%%%X" % (a - pos))
                pos = a
            for k, n in lab[a]:
                if k == "G":
                    z += ["G", "%s\tL" % n, "%s:" % n, "I"]
                else:
                    z.append("%s:" % n)
        if b0 + sz > pos:
            z.append("$REL\t$+%%%X" % (b0 + sz - pos))
        z.append("$SDEFAULT")
    mine = [x for x in c.com if x[3] == m.name]
    if mine:
        z.append("$SECTION BSS_B")
        for s, ad, sz, _o in mine:
            z.append("X\t%s\tA[%%%X B]" % (s, sz))
        z.append("$SDEFAULT")
    return z


def erzeugen(self):
    """as source text of the member (str)."""
    c, m = self.c, self.m
    self.labels_text, self.labels_data, self.labels_bss = set(), set(), set()
    self.body = []
    self.addr_of = {}
    if m.t1 > m.t0:
        self.code_umschreiben()
    ptr = self.daten_zeilen() or {}
    # labels required in the code, then the procedures
    procs = []
    if self.body:
        defined = {z[:-1] for z in self.body if re.match(r"\S+:$", z)}
        out = []
        for i, z in enumerate(self.body):
            a = self.addr_of.get(i)
            if a is not None and a in self.labels_text and ("L%04X" % a) not in defined:
                out.append("L%04X:" % a)
                defined.add("L%04X" % a)
            out.append(z)
        exports = sorted((ad, s) for s, (ad, k) in m.sym.items() if k == "T")
        names = {s for _a, s in exports}
        cur = None
        for z in out:
            mm = re.match(r"(\S+):$", z)
            if mm and mm.group(1) in names:
                a0 = m.sym[mm.group(1)][0]
                for ad, sn in exports:      # aliases at the same address: empty procedures in front (measured: as accepts them)
                    if ad == a0 and sn != mm.group(1):
                        procs.append((sn, []))
                cur = (mm.group(1), [])
                procs.append(cur)
            elif cur is None:
                raise Fehler("%s: code before the first export label: %s" % (m.name, z))
            else:
                cur[1].append(z)
        if sorted(p[0] for p in procs) != sorted(s for _a, s in exports):
            raise Fehler("%s: export labels %s do not match the code labels %s" %
                         (m.name, [s for _a, s in exports], [p[0] for p in procs]))
    mod = m.name + "_"            # module name must differ from every procedure name (else the symbol is lost: csv)
    t = ["%s module" % mod, ASM_KOPF.rstrip("\n")]
    for nm, zl in procs:
        t += ["G\t%s\tPR" % nm, "E", "%s:" % nm] + zl + ["end %s" % nm]
    t += self.bss_ausgeben()
    if m.data and m.data[1] > m.data[0]:
        t += self.daten_ausgeben(ptr)
    t.append("end %s" % mod)
    return "\n".join(t) + "\n"


Quelle.code_umschreiben = code_umschreiben
Quelle.daten_zeilen = daten_zeilen
Quelle.daten_ausgeben = daten_ausgeben
Quelle.bss_ausgeben = bss_ausgeben
Quelle.erzeugen = erzeugen


# ---------------------------------------------------------------- driver
class Kontext:
    def __init__(self, name):
        self.name = name
        self.dir = os.path.join(LIBDIR, name)
        self.ms, self.com, self.ext = parse(os.path.join(LIBDIR, name + ".members"))
        self.arbeit = os.path.join(REPO, "userspace", name, "work")
        rawp = os.path.join(self.arbeit, name + ".raw")
        if not os.path.isfile(rawp):
            raise U.Fehlt("%s (run: pipeline.py holen %s)" % (rawp, name))
        self.raw = open(rawp, "rb").read()
        U.pruefe()
        self.libc = U.libc_archiv(self.arbeit)
        self.dobj = diskette_objekte(self.libc)
        symbole_aufloesen(self.ms, self.dobj)
        self.tab = alle_symbole(self.ms, self.com)
        basis = open(os.path.join(REPO, "userspace", name, "k.txt")).read()
        karte = karte_text(basis, self.ms, len(self.raw))
        karte += "\n".join("name %04X %s" % (a, s) for a, s, k, _m in self.tab if k == "T") + "\n"
        self.refs, self.kp, self.rp = referenzen(self.raw, karte)
        self.befehle = [(a, m) for a, m in listing_befehle(self.kp, self.rp) if not m.startswith("DW")]
        self.zeiger = []

    def im_ranges(self, a):
        return Quelle(self, self.ms[0]).im_bereich(a)


def quellen_erzeugen(name):
    c = Kontext(name)
    os.makedirs(c.dir, exist_ok=True)
    erg = {}
    fehler = []
    for m in c.ms:
        try:
            q = Quelle(c, m).erzeugen()
        except Fehler as e:
            fehler.append(str(e))
            continue
        with open(os.path.join(c.dir, m.name + ".s"), "w", newline="\n") as f:
            f.write(q)
        erg[m.name] = q
    for f in fehler:
        print("ERROR:", f, file=sys.stderr)
    return c, erg


# ---------------------------------------------------------------- libc members in other programs
import difflib       # noqa: E402
import collections   # noqa: E402

ROOT_PROGRAMME = ["etc/init", "bin/cat", "bin/date", "bin/ls", "bin/sh", "bin/login", "bin/stty", "bin/sync",
                  "etc/getty", "etc/mount", "etc/umount"]


def worte(b):
    return [struct.unpack(">H", b[i:i + 2])[0] for i in range(0, len(b) - 1, 2)]


def masken_worte(o):
    """member text as word list, relocated words are None (wildcards)"""
    t = worte(o.text)
    for off, _r in o.relocs("text"):
        t[off // 2] = None
    return t


def aehnlichkeit(mw, pw, anker=3):
    """(ratio of the matching non-wildcard words, start word) of the member's word list inside the program words, by seeds"""
    fest = [(i, tuple(mw[i:i + anker])) for i in range(len(mw) - anker + 1) if None not in mw[i:i + anker]]
    if not fest or len(fest) < 2:
        return 0.0, None
    index = collections.defaultdict(list)
    for j in range(len(pw) - anker + 1):
        index[tuple(pw[j:j + anker])].append(j)
    stimmen = collections.Counter()
    for q, key in fest:
        for p in index.get(key, ()):
            stimmen[p - q] += 1
    best = (0.0, None)
    nf = sum(1 for w in mw if w is not None)
    for st, n in stimmen.most_common(4):
        if n < 2:
            break
        fenster = pw[max(st, 0):max(st, 0) + len(mw) + 24]
        sm = difflib.SequenceMatcher(None, [w for w in mw if w is not None], [w for w in fenster], autojunk=False)
        r = sum(b.size for b in sm.get_matching_blocks()) / max(nf, 1)
        if r > best[0]:
            best = (r, st * 2)
    return best


def tabelle(alt_archiv, log=print):
    """Member x program table: '=' identical to the shipped member, 'A' identical to the member rebuilt from init (libc_alt),
    '~NN' similar (NN %, other compiler state), '.' not found.  Returns (columns, rows)."""
    import tempfile
    d = tempfile.mkdtemp(prefix="libc_tab_")
    libc = U.platte_holen("usr", "lib/libc.a", d)
    ship = {m.name.decode()[:-2]: m.objekt() for m in O.Archiv.lesen(libc).mitglieder}
    alt = {m.name.decode()[:-2]: m.objekt() for m in O.Archiv.lesen(alt_archiv).mitglieder} if alt_archiv else {}
    zeilen = collections.OrderedDict()
    for pg in ROOT_PROGRAMME:
        b = U.platte_holen("root", pg, d)
        k, raw = U.roh_von(b)
        text = raw[:k[1]]
        pw = worte(text)
        for n, o in ship.items():
            if not o.text:
                continue
            mw = masken_worte(o)

            def gleich(oo):
                m2 = masken_worte(oo)
                if len(m2) > len(pw):
                    return False
                for st in range(0, len(pw) - len(m2) + 1):
                    if all(a is None or a == pw[st + i] for i, a in enumerate(m2)):
                        return True
                return False
            st = "."
            if len(o.text) >= 14 and any(w is not None for w in mw):
                if gleich(o):
                    st = "=" if not (n in alt and masken_worte(alt[n]) != mw) else "D"
                elif n in alt and gleich(alt[n]):
                    st = "A"
                else:
                    r, _p = aehnlichkeit(mw, pw)
                    if r >= 0.6:
                        st = "~%d" % round(100 * r)
            else:
                st = "."            # too short to be told apart
            zeilen.setdefault(n, {})[pg] = st
    return ROOT_PROGRAMME, zeilen


# ---------------------------------------------------------------- members file generator for any program
def zusatz_anwenden(txt, pfad):
    """Hand-made corrections that must survive a regeneration: file NAME.members.zusatz, one line `MEMBER key=value ...`;
    each key replaces the same option of that member line (or is appended).  A line `+ MEMBER FROM TO key=value ...` adds a
    whole member line that members_auto does not find (e.g. login getpass, which lies in front of the first strong match);
    it is inserted in address order unless a line for MEMBER already exists."""
    if not os.path.isfile(pfad):
        return txt
    zus, neu_zeilen = {}, []
    for z in open(pfad).read().split("\n"):
        if z.strip() and not z.startswith("#"):
            t = z.split()
            if t[0] == "+":
                neu_zeilen.append(t[1:])
            else:
                zus[t[0]] = dict(x.split("=", 1) for x in t[1:])
    zeilen = txt.split("\n")
    vorhanden = {z.split()[0] for z in zeilen if z.strip() and not z.startswith("#")}
    for t in neu_zeilen:
        if t[0] in vorhanden:
            continue
        von = int(t[1], 16)
        pos = len(zeilen)
        for i, z in enumerate(zeilen):
            u = z.split()
            if len(u) > 2 and not z.startswith("#") and u[0] not in ("common", "extern") \
                    and re.match(r"[0-9A-Fa-f]{4}$", u[1]) and int(u[1], 16) > von:
                pos = i
                break
        zeilen.insert(pos, " ".join(t))
    out = []
    for z in zeilen:
        t = z.split()
        if t and t[0] in zus and len(t) > 2 and not t[0] in ("common", "extern"):
            opt = [x.split("=", 1) for x in t[3:]]
            keys = {k for k, _v in opt}
            neu = [(k, zus[t[0]].get(k, v)) for k, v in opt] + [(k, v) for k, v in zus[t[0]].items() if k not in keys]
            z = " ".join(t[:3] + ["%s=%s" % kv for kv in neu])
        out.append(z)
    return "\n".join(out)


def teile_zerlegen(name, libc, alt_archiv, log=print):
    """Segment the libc part of program NAME into members -> text of NAME.members, plus a list of gap members.
    Exact pieces come from the init archive (A) and the shipped libc.a (S); uncovered gaps are cut at `call csv` function
    starts and named after the most similar shipped member (G).  Sizes of data/bss of a member are taken from its template
    object (ASSUMPTION, checked by the final byte comparison)."""
    ar = os.path.join(REPO, "userspace", name, "work")
    b = open(os.path.join(ar, name + ".orig"), "rb").read()
    k, raw = U.roh_von(b)
    pw = worte(raw[:k[1]])
    ship = {m.name.decode()[:-2]: m.objekt() for m in O.Archiv.lesen(libc).mitglieder}
    alt = {m.name.decode()[:-2]: m.objekt() for m in O.Archiv.lesen(alt_archiv).mitglieder}

    def finde(o):
        mw = masken_worte(o)
        return [st * 2 for st in range(0, len(pw) - len(mw) + 1)
                if all(a is None or a == pw[st + i] for i, a in enumerate(mw))]
    cov = {}
    for tag, d in (("A", alt), ("S", ship)):
        for n, o in d.items():
            if len(o.text) >= 14:
                for p in finde(o):
                    if p >= 0x30 and p not in cov:
                        cov[p] = (len(o.text), n, tag, o)
    # csv address: the member csv is exact in every program
    csvs = finde(alt["csv"])
    if not csvs:
        raise Fehler("%s: csv not found" % name)
    csv_a = csvs[0]
    starts = [i * 2 for i in range(len(pw) - 1) if pw[i] == 0x5F00 and pw[i + 1] == csv_a and i * 2 >= 0x30]
    # a compiled function starts with `call csv`; so do not trust matches before the first library member
    pieces, pos = [], min(cov)
    end = len(pw) * 2
    for p in sorted(cov):
        if p < pos:
            continue
        if p > pos:
            pieces.append(("G", pos, p, None, None))
        ln, n, tag, o = cov[p]
        pieces.append((tag, p, p + ln, n, o))
        pos = p + ln
    if pos < end:
        pieces.append(("G", pos, end, None, None))
    # cut gaps
    out = []
    for tag, a, bnd, n, o in pieces:
        if tag != "G":
            out.append((tag, a, bnd, n, o))
            continue
        if bnd - a < 14:
            seg = pw[a // 2:bnd // 2]
            hit = None
            for tag2, d in (("A", alt), ("S", ship)):
                for n2, o2 in sorted(d.items()):
                    mw = masken_worte(o2)
                    if len(o2.text) == bnd - a and mw and all(x is None or x == y for x, y in zip(mw, seg)):
                        hit = hit or (tag2, a, bnd, n2, o2)
            if hit:
                out.append(hit)
            else:
                log("%s: small gap %04X-%04X (%d B) not identified" % (name, a, bnd, bnd - a))
                out.append(("X", a, bnd, None, None))
            continue
        cuts = sorted({a} | {x for x in starts if a <= x < bnd} | {bnd})
        cur = a
        while cur < bnd:
            best = None
            for n2, o2 in ship.items():
                if len(o2.text) < 14 or cur + 2 * 8 > bnd:
                    continue
                mw = [w for w in masken_worte(o2) if w is not None]
                win = pw[cur // 2:min(bnd, cur + len(o2.text) + 24) // 2]
                sm = difflib.SequenceMatcher(None, [w for w in masken_worte(o2)], win, autojunk=False)
                # wildcards (None) never match: count only the fixed words
                ok = sum(bl.size for bl in sm.get_matching_blocks())
                r = ok / max(len(mw), 1)
                if best is None or r > best[0]:
                    best = (r, n2, o2)
            if best is None or best[0] < 0.6:
                nxt = min((c for c in cuts if c > cur), default=bnd)
                out.append(("X", cur, nxt, None, None))
                cur = nxt
                continue
            r, n2, o2 = best
            e0 = cur + len(o2.text)
            e = min((c for c in cuts if c > cur and c >= e0 - 12), key=lambda c: abs(c - e0), default=bnd)
            e = min(max(e, cur + 2), bnd)
            out.append(("G", cur, e, n2, o2))
            log("%s: gap member %04X-%04X = %s (%d%% of the fixed words, shipped %d B, here %d B)" %
                (name, cur, e, n2, round(100 * r), len(o2.text), e - cur))
            cur = e
    # data-only members (text 0) follow the archive order of the shipped libc.a: data.o when flsbuf is linked,
    # errlst.o when perror is (sys_errlist)
    order = [m.name.decode()[:-2] for m in O.Archiv.lesen(libc).mitglieder]
    names = {x[3] for x in out}
    for dn, need in (("data", "flsbuf"), ("errlst", "perror"), ("ctype_", "atof")):
        if need in names:
            o = alt.get(dn) or ship[dn]
            pos = next((i for i, x in enumerate(out) if x[3] in order and order.index(x[3]) > order.index(dn)), len(out))
            ref = out[pos - 1][2] if pos else 0
            out.insert(pos, ("A" if dn in alt else "S", ref, ref, dn, o))
    # placement of data/bss
    mem = [x for x in out if x[0] != "X"]
    for x in out:
        if x[0] == "X":
            log("%s: UNRESOLVED %04X-%04X (%d B)" % (name, x[1], x[2], x[2] - x[1]))
    dsum = sum(len(x[4].data) for x in mem)
    bsum = sum(x[4].bss for x in mem)
    dstart = k[1] + k[2] - dsum
    bend = k[1] + k[2] + k[3]
    bstart = bend - bsum
    com_a = None
    if any(x[3] == "data" for x in mem):
        com_a = bstart - 2 - 0x400
    initcode = {}
    ims, _c, _e = parse(os.path.join(LIBDIR, "init.members"))
    for m0 in ims:
        if m0.code:
            initcode[m0.name] = [c0 - m0.t0 for c0 in m0.code]
    lines = ["# generated by libc_alt.py members_auto: A = init archive, S = shipped libc.a, G = gap cut at `call csv` starts"]
    dpos, bpos = dstart, bstart
    for tag, a, bnd, n, o in mem:
        t = [n, "%04X" % a, "%04X" % bnd]
        exp = []
        te = sorted((x.wert, x.name.decode("latin-1")) for x in o.syms if x.ext and x.basistyp == O.N_TEXT)
        fs = [x for x in starts if a <= x < bnd]
        for i, (w, sn) in enumerate(te):
            if bnd - a == len(o.text):
                exp.append("%s@%04X" % (sn, a + w))
            else:       # length differs from the template: the export is the same-numbered `call csv` function start
                csvi = [k for k, x in enumerate(o.syms) if x.name == b"csv"]
                tf = [off - 2 for off, r in o.relocs("text") if csvi and r.art == O.R_EXT and r.sym == csvi[0]
                      and off >= 2 and o.text[off - 2:off] == b"\x5f\x00"]
                k = max([j for j, t in enumerate(tf) if t <= w], default=0)
                if len(tf) != len(fs):
                    log("%s: member %s: %d function starts in the template, %d in the image (exports are guesses)" %
                        (name, n, len(tf), len(fs)))
                exp.append("%s@%04X" % (sn, fs[min(k, len(fs) - 1)] if fs else a))
        for x in o.syms:
            if x.ext and x.basistyp == O.N_DATA:
                exp.append("%s@%04X" % (x.name.decode("latin-1"), dpos + x.wert - len(o.text)))
            elif x.ext and x.basistyp == O.N_BSS:
                exp.append("%s@%04X" % (x.name.decode("latin-1"), bpos + x.wert - len(o.text) - len(o.data)))
        if len(o.data):
            t.append("data=%04X:%04X" % (dpos, dpos + len(o.data)))
        if o.bss:
            t.append("bss=%04X:%X" % (bpos, o.bss))
        if exp:
            t.append("exp=" + ",".join(exp))
        if n in initcode and bnd > a:
            t.append("code=" + ",".join("%04X" % (a + off) for off in initcode[n]))
        t.append("src=" + tag)
        lines.append(" ".join(t))
        dpos += len(o.data)
        bpos += o.bss
    if com_a is not None:
        lines.append("common __sibuf %04X 200 data" % com_a)
        lines.append("common __sobuf %04X 200 data" % (com_a + 0x200))
    lines.append("extern _environ %04X 2" % (bstart - 2))
    lines.append("extern _end %04X 0" % bend)
    return "\n".join(lines) + "\n", [x for x in out if x[0] == "G"], out


def gast_objekte(c, texte=None, frist=20_000_000_000, log=print, arbeit="libc_alt_gast"):
    """Assemble member sources in the guest with `as -u`; returns {member: (messages, object bytes|None)}.
    texte = {member: source text}; default: the generated userspace/libc_alt/NAME/MEMBER.s of all members."""
    pruefe_gast()
    import gast_as
    emu.build()
    quellen, befehle, rueck = {}, [], []
    for m in c.ms:
        if texte is not None and m.name not in texte:
            continue
        quellen[m.name + ".s"] = (texte[m.name].encode("latin-1") if texte is not None
                                  else open(os.path.join(c.dir, m.name + ".s"), "rb").read())
        # every command ends in /mnt (the runner appends `cat fertigN`, a file on /mnt)
        befehle.append("cd /tmp;>asm.out;as -u /mnt/%s.s >%s.err 2>&1;cat asm.out >%s.o;cd /mnt" % (m.name, m.name, m.name))
        rueck += [m.name + ".o", m.name + ".err"]
    aus = {}
    r = gast_as.gast_befehle(os.path.join(c.arbeit, arbeit), quellen, befehle, rueck, frist=frist, ausgabe=aus)
    log("guest run: %.0f s wall clock" % aus.get("dauer", 0))
    return {m.name: ((r.get(m.name + ".err") or b"").decode("latin-1"), r.get(m.name + ".o") or None)
            for m in c.ms if texte is None or m.name in texte}


def pruefe_gast():
    import gast_as
    try:
        gast_as.pruefe_hilfsmittel()
    except gast_as.Fehlt as e:
        raise U.Fehlt(str(e))


def pruefen_objekte(c, objs, log=print):
    """Guard: relocate every object like ld and compare with the image (text and data).  Returns the number of bad members."""
    schlecht = 0
    for m in c.ms:
        if m.name not in objs:
            continue
        err, ob = objs[m.name]
        if not ob:
            log("%-8s NO OBJECT  %s" % (m.name, err.strip()[:200]))
            schlecht += 1
            continue
        o = O.Objekt.lesen(ob)
        try:
            t, d = relozieren(m, o, c.tab + [(a, s, "E", None) for s, a, _z in c.ext])
        except ValueError as e:
            log("%-8s %s" % (m.name, e))
            schlecht += 1
            continue
        soll_t = c.raw[m.t0:m.t1]
        soll_d = c.raw[m.data[0]:m.data[1]] if m.data else b""
        gt, gd = t == soll_t, d == soll_d
        bs = (m.bss[1] if m.bss else 0)
        gb = o.bss == bs
        for sn, _ad, sz, ow in c.com:      # commons: undefined external symbols whose value is the size
            if ow == m.name:
                gb = gb and any(x.name.decode("latin-1") == sn and x.typ == 0x20 and x.wert == sz for x in o.syms)
        defd = {x.name.decode("latin-1") for x in o.syms if x.ext and x.basistyp != O.N_UNDF}
        fehlend = sorted(set(m.sym) - defd)       # an export the object does not define (e.g. module name = procedure name)
        if fehlend:
            log("   exports missing in the object: %s" % ", ".join(fehlend))
        if not (gt and gd and gb) or fehlend:
            schlecht += 1
        hinweis = ""
        dm = c.dobj.get(m.name)
        if dm is not None:
            def gestalt(q):     # text bytes + relocation kinds with symbol names (symbol numbering is irrelevant)
                return q.text, [(off, r.art, q.syms[r.sym].name if r.art == O.R_EXT else None) for off, r in q.relocs("text")]
            hinweis = "  structure equals shipped member: %s" % ("yes" if gestalt(dm) == gestalt(o) else "no")
        diff = [i for i in range(min(len(t), len(soll_t))) if t[i] != soll_t[i]][:4]
        log("%-8s text %s (%d B) data %s (%d B) bss %s%s%s" % (
            m.name, "OK" if gt else "DIFF", len(soll_t), "OK" if gd else "DIFF", len(soll_d), "OK" if gb else "DIFF",
            hinweis, "  first diffs at +%s" % ",".join("%X" % x for x in diff) if diff else ""))
        if err.strip():
            log("   as: " + err.strip().replace("\n", " | ")[:300])
    return schlecht


def _norm_s(t):
    """instruction lines of an as source in a comparable form (numbers decimal, FP/SP = r14/r15, labels = L)"""
    def num(m):
        v = int(m.group(2), 16)
        return str((-v) & 0xFFFF if m.group(1) == "-" else v)
    erg = []
    for z in t.split("\n"):
        z = z.strip()
        if not z or z[0] in "$~" or re.match(r"\S+:$", z) or re.match(r"(G|I|E|X|end)\b", z) or z.endswith(" module"):
            continue
        z = re.sub(r"(-?)%([0-9A-Fa-f]+)", num, z)
        z = z.replace("FP", "r14").replace("SP", "r15").replace(",", " ").lower()
        z = re.sub(r"\b[ldb][0-9][0-9a-f]*\b", "L", z)
        z = re.sub(r"^jr c\b", "jr ult", z)
        z = re.sub(r"\bjr c\b", "jr ult", z)
        erg.append(re.sub(r"\s+", " ", z))
    return erg


def libc_regeln(s):
    """MODEL of c2/c1 differences of the ORIGINAL library compiler, derived from the shipped listing -- NOT a run of the old c2.
    Only in libc members (R20.. ; R1..R10 belong to uspace.c2_emu_s, R11..R19 to another branch).  Applied after c2_emu_s.
    Each rule is evidenced at exactly the places counted in doc/userspace/libc_alt.md (last run: flsbuf R20 1, R21 1, R22 1, R23 1;
    malloc R24 1, R25 1, R26 1, R31 1).
      R20  `sub rN,.. ; ld r2,rN ; ld rA,r2 ; jr mi`  ->  `test rA` inserted before the jr (value of `x = a - b` tested)
      R21  `ld rA,r2 ; ld r2,rA ; ld DST,r2 ; test rA` -> `.. ; test r2` (value of an assignment tested in r2)
      R22  `test MEM` after `ld r0,MEM` (no write to r0 in between) -> `test r0`
      R23  `ldl M,rr2 ; test.. ; jr cc ; push @SP,r2 ; push @SP,r3` -> `ldl rr2,M` re-inserted behind the jr
      R24  `ld rB,rX ; add rB,#2^n ; exts rrA ; div rrA,#2^n ; ld rA,rB` (A=B-1) -> `ld rA,rX ; add rA,#2^n ; ld rB,#-n ; sda rA,rB`
           (the old c1 turns a signed division by a power of two into an arithmetic shift)
      R25  `ld r2,MEM ; ld r3,r2` (MEM not a register) -> `ld r2,MEM ; ld r3,MEM`
      R26  `div rr2,.. ; ld rB,r3` (B != 2) -> `.. ; ld r2,r3 ; ld rB,r2` (quotient/remainder goes through r2)
      R31  `ld @rX,r2 ; ld MEM,r2 ; ld r3,.. ; set r3,#n ; ld @r2,r3` -> `ld r2,MEM` inserted behind the store (malloc, 1x)
    Returns (new text, {rule: count})."""
    z = s.split("\n")
    out, n = [], {"R20": 0, "R21": 0, "R22": 0, "R23": 0, "R24": 0, "R25": 0, "R26": 0, "R31": 0}
    r0mem = None
    i = 0
    reg = r"(r\d+|rr\d+|rq\d+|rl\d+|rh\d+|SP|FP)$"
    while i < len(z):
        a = z[i]
        b = z[i + 1] if i + 1 < len(z) else ""
        c = z[i + 2] if i + 2 < len(z) else ""
        d = z[i + 3] if i + 3 < len(z) else ""
        e = z[i + 4] if i + 4 < len(z) else ""
        m = re.match(r"ld\tr2,(r\d+)$", a)
        mb = re.match(r"ld\t(r\d+),r2$", b)
        if m and mb and c.startswith("jr\tmi\t") and out and re.match(r"sub\t%s," % m.group(1), out[-1]):
            out += [a, b, "test\t%s" % mb.group(1)]
            n["R20"] += 1
            i += 2
            continue
        m = re.match(r"ld\t(r\d+),r2$", a)
        mb = re.match(r"ld\tr2,%s$" % (m.group(1) if m else "x"), b)
        mc = re.match(r"ld\t([^,]+),r2$", c)
        if m and mb and mc and d == "test\t" + m.group(1):
            out += [a, b, c, "test\tr2"]
            n["R21"] += 1
            i += 4
            continue
        m = re.match(r"div\trr2,", a)
        mb = re.match(r"ld\t(r\d+),r3$", b)
        if m and mb and mb.group(1) != "r2":
            out += [a, "ld\tr2,r3", "ld\t%s,r2" % mb.group(1)]
            n["R26"] += 1
            i += 2
            continue
        m = re.match(r"ld\tr(\d+),(\d+)$", a) if False else None
        mt = re.match(r"test\t([^,]+)$", a)
        if mt and r0mem == mt.group(1) and not re.match(reg, mt.group(1)):
            out.append("test\tr0")
            n["R22"] += 1
            i += 1
            continue
        m = re.match(r"ld\tr0,([^,]+)$", a)
        if m and not re.match(reg, m.group(1)):
            r0mem = m.group(1)
        elif re.match(r"(call|jp|\w+:|ld\tr0,|ldb\trl0,|ldl\trr0,|pop\tr0,|clr\tr0)", a) or a.endswith(":") or re.match(r"[a-z]+\t(r0|rr0|rq0|rl0|rh0)[,]", a) and not a.startswith(("cp", "test", "push", "bit")):
            r0mem = None
        ml = re.match(r"ldl\t([^,]+),rr2$", a)
        if ml and not re.match(reg, ml.group(1)) and re.match(r"(test|cp)\t", b) and re.match(r"jr\t\w+\t\w+$", c) \
                and d == "push\t@SP,r2" and e == "push\t@SP,r3":
            out += [a, b, c, "ldl\trr2,%s" % ml.group(1)]
            n["R23"] += 1
            i += 3
            continue
        m = re.match(r"ld\t(r\d+),(r\d+)$", a)
        ma = re.match(r"add\t(r\d+),#%([0-9A-F]+)$", b)
        if m and ma and ma.group(1) == m.group(1):
            k = int(ma.group(2), 16)
            rb = int(m.group(1)[1:])
            if k > 1 and k & (k - 1) == 0 and c == "exts\trr%d" % (rb - 1) and d == "div\trr%d,#%%%X" % (rb - 1, k) \
                    and e == "ld\tr%d,r%d" % (rb - 1, rb):
                nb = k.bit_length() - 1
                out += ["ld\tr%d,%s" % (rb - 1, m.group(2)), "add\tr%d,#%%%X" % (rb - 1, k), "ld\tr%d,#-%%%X" % (rb, nb),
                        "sda\tr%d,r%d" % (rb - 1, rb)]
                n["R24"] += 1
                i += 5
                continue
        # R31  `ld @rX,r2 ; ld MEM,r2 ; ld r3,.. ; set r3,#n ; ld @r2,r3` -> `ld r2,MEM` re-inserted after the store to MEM
        #      (chained assignment `alloct = q->ptr = ..; alloct->ptr = ..`: the old c1 reloads the stored global)
        if re.match(r"ld\t@r\d+,r2$", a) and re.match(r"ld\t[A-Za-z_]\w*,r2$", b) and re.match(r"ld\tr3,", c) \
                and re.match(r"set\tr3,", d) and e == "ld\t@r2,r3":
            out += [a, b, "ld\tr2,%s" % b.split("\t")[1].split(",")[0]]
            n["R31"] += 1
            i += 2
            continue
        m = re.match(r"ld\tr2,([^,]+)$", a)
        if m and not re.match(reg, m.group(1)) and b == "ld\tr3,r2":
            out += [a, "ld\tr3,%s" % m.group(1)]
            n["R25"] += 1
            i += 2
            continue
        out.append(a)
        i += 1
    return "\n".join(out), n


def c_quellen():
    d = os.path.join(LIBDIR, "c")
    return sorted(f[:-2] for f in os.listdir(d) if f.endswith(".c")) if os.path.isdir(d) else []


def c_bauen(name, nur=None):
    """C sources userspace/libc_alt/c/MEMBER.c -> guest `cc -O -S` -> c2 model (R1..) -> guest `as -u` -> guard.
    Writes work/c_MEMBER.s (cc output) and work/c_MEMBER.s2 (rewritten), prints a diff against the disassembled original."""
    import gast_as
    c = Kontext(name)
    namen = [n for n in c_quellen() if (not nur or n in nur) and any(m.name == n for m in c.ms)]
    pruefe_gast()
    emu.build()
    quellen, befehle, rueck = {}, [], []
    for n in namen:
        quellen[n + ".c"] = open(os.path.join(LIBDIR, "c", n + ".c"), "rb").read()
        befehle.append("cd /tmp;cc -O -S /mnt/%s.c >%s.err 2>&1;cd /mnt" % (n, n))
        rueck += [n + ".s", n + ".err"]
    r = gast_as.gast_befehle(os.path.join(c.arbeit, "libc_alt_c1"), quellen, befehle, rueck, frist=20_000_000_000)
    texte, zaehler = {}, {}
    for n in namen:
        err = (r.get(n + ".err") or b"").decode("latin-1").strip()
        s = (r.get(n + ".s") or b"").decode("latin-1")
        if err:
            print("%s: cc messages: %s" % (n, err[:300]))
        if not s:
            print("%s: NO .s" % n)
            continue
        open(os.path.join(c.arbeit, "c_%s.s" % n), "w").write(s)
        s2, cnt = U.c2_emu_s(s)
        s2, cnt2 = libc_regeln(s2)
        s2, cnt3 = libc_regeln(s2)          # second pass: R22 behind a line group that R23 swallowed
        cnt.update({k: cnt2[k] + cnt3[k] for k in cnt2})
        s2 = re.sub(r"^\w+ module", n + "_ module", s2, count=1, flags=re.M) if False else s2
        open(os.path.join(c.arbeit, "c_%s.s2" % n), "w").write(s2)
        texte[n] = s2
        zaehler[n] = {k: v for k, v in cnt.items() if v}
        print("%s: c2 model rewrote %s" % (n, zaehler[n]))
    objs = gast_objekte(c, texte, arbeit="libc_alt_c2")
    schlecht = pruefen_objekte(c, objs)
    for n in texte:
        da = _norm_s(open(os.path.join(c.dir, n + ".s")).read())
        db = _norm_s(open(os.path.join(c.arbeit, "c_%s.s2" % n)).read())
        sm = difflib.SequenceMatcher(None, da, db, autojunk=False)
        n_diff = sum(1 for t in sm.get_opcodes() if t[0] != "equal")
        print("%s: instruction lines original %d, built %d, difference blocks %d" % (n, len(da), len(db), n_diff))
        with open(os.path.join(c.arbeit, "c_%s.diff" % n), "w") as f:
            for t, i1, i2, j1, j2 in sm.get_opcodes():
                if t != "equal":
                    f.write("%s orig#%d: %s\n          built: %s\n" % (t, i1, " ; ".join(da[i1:i2][:10]), " ; ".join(db[j1:j2][:10])))
    return 1 if schlecht else 0


def bauen(name):
    """Assemble the members the program's own archive needs (src=G; every member for `init`), guard them, write the archive."""
    c, erg = quellen_erzeugen(name)
    sel = [m for m in c.ms if name == "init" or m.src == "G"]
    texte = {m.name: erg[m.name] for m in sel}
    objs = gast_objekte(c, texte) if texte else {}
    for m in sel:
        err, ob = objs[m.name]
        if ob:
            with open(os.path.join(c.arbeit, m.name + ".o"), "wb") as f:
                f.write(ob)
    schlecht = pruefen_objekte(c, objs)
    # one archive in the order of the program's libc part (the old libc.a had one order; ld pulls members in archive order):
    # G members assembled here, A members from the init archive, S members from the shipped libc.a
    altobj = {}
    ap = os.path.join(LIBDIR, "init", "libc_alt.a")
    if os.path.isfile(ap):
        altobj = {mm.name.decode()[:-2]: mm.daten for mm in O.Archiv.lesen(open(ap, "rb").read()).mitglieder}
    shipobj = {mm.name.decode()[:-2]: mm.daten for mm in O.Archiv.lesen(c.libc).mitglieder}
    glieder = []
    for m in c.ms:
        if name == "init" or m.src == "G":
            b = objs[m.name][1]
        elif m.src == "A":
            b = altobj.get(m.name)
        else:
            b = shipobj.get(m.name)
        if b:
            glieder.append((m.name, b))
    arch = archiv_bauen(glieder)
    ziel = os.path.join(c.dir, "libc_alt.a")
    with open(ziel, "wb") as f:
        f.write(arch)
    print("%s: %d B, %d members; %d members differ" % (ziel, len(arch), len(sel), schlecht))
    return 1 if schlecht else 0


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    if len(argv) < 2 or argv[0] not in ("quelle", "bau", "pruefen", "tabelle", "cbau", "members"):
        print(__doc__)
        return 2
    try:
        if argv[0] == "quelle":
            c, erg = quellen_erzeugen(argv[1])
            print("%d members -> %s" % (len(erg), c.dir))
        elif argv[0] == "members":
            ar = os.path.join(REPO, "userspace", argv[1], "work")
            U.pruefe()
            txt, gaps, out = teile_zerlegen(argv[1], U.libc_archiv(ar),
                                            open(os.path.join(LIBDIR, "init", "libc_alt.a"), "rb").read())
            txt = zusatz_anwenden(txt, os.path.join(LIBDIR, argv[1] + ".members.zusatz"))
            open(os.path.join(LIBDIR, argv[1] + ".members"), "w").write(txt)
            print(txt)
        elif argv[0] == "bau":
            return bauen(argv[1])
        elif argv[0] == "cbau":
            return c_bauen(argv[1], argv[2:])
        elif argv[0] == "pruefen":
            c = Kontext(argv[1])
            objs = {}
            for m in c.ms:
                p = os.path.join(c.arbeit, m.name + ".o")
                objs[m.name] = ("", open(p, "rb").read() if os.path.isfile(p) else None)
            return 1 if pruefen_objekte(c, objs) else 0
        elif argv[0] == "tabelle":
            U.pruefe()
            ap = os.path.join(LIBDIR, argv[1], "libc_alt.a")
            spalten, zeilen = tabelle(open(ap, "rb").read() if os.path.isfile(ap) else None)
            print("%-9s" % "member" + " ".join("%-8s" % p.split("/")[-1] for p in spalten))
            for n, z in zeilen.items():
                if any(v != "." for v in z.values()):
                    print("%-9s" % n + " ".join("%-8s" % z.get(p, ".") for p in spalten))
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP
    except Fehler as e:
        print("ERROR:", e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
