"""cvopt_z8k: the c1 code-table converter for the Z8000 (W6, doc/userspace/wk_w6.md).

V7 builds the code generator tables with `cvopt <table.s >table.i; as table.i` (original/unix-v7/usr/src/cmd/c/cvopt.c): the
tables are written as templates (`%a,n` header line + indented template lines), cvopt turns them into `.byte` records and
strings.  The MUTOS c1 binary has exactly this layout (pattern texts with macro letters, then 6-byte `optab` records, then
the `struct table` arrays in the data), but neither the Z8000 `table.s` nor the MUTOS `cvopt` exist.  This module

  * `uebersetzen`: ports cvopt.c (same state machine) and writes the module in the dialect of the MUTOS `as` (PLZ/ASM), plus a
    host model of the bytes (text, data) so that the result can be compared with the original image without a guest run;
  * `quelle`: reconstructs `userspace/c1/table.s` from the c1 image (inverse of cvopt for these tables);
  * `pruefen`: table.s -> model bytes == image bytes.

  python3 -I tools/userspace/cvopt_z8k.py quelle   [raw] > userspace/c1/table.s
  python3 -I tools/userspace/cvopt_z8k.py pruefen  [raw]            # exit 0 = text 5A40..6988 and data 88AE..8A3E equal
  python3 -I tools/userspace/cvopt_z8k.py uebersetzen [table.s]     # PLZ/ASM module on stdout

Differs from V7 cvopt.c: (1) the characters X, Y, T no longer set `snlflg` (measured: the original strings keep the newline after
lines that contain them); (2) no zero word at EOF (the last group of the c1 image is unterminated); (3) there is no `case 'M'` (V7 has none either: the comment table is wrong); (4) the output is PLZ/ASM
(`BV`, `WV`, labels) instead of PDP-11 `as`; (7) `\\x` writes the character x literally (the image has literal S bytes); (6) the degree letter `c` takes type letters, and the letters y x q (6 7 11) exist; (5) the data lines of table.s are `wv a,b` lines (Z8000 as has no `.byte`-like
`;` statements with decimal points).
"""
import os
import re
import struct
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HIER))
RAW = os.path.join(REPO, "userspace", "c1", "work", "c1.raw")
TEXT0, TEXT_END = 0x5A40, 0x6988        # table.o text in the c1 image
DATA0 = 0x88AE                          # table.o data (regtab) in the c1 image
TABLES = (("_regtab", "cr", 0x88AE, 47), ("_efftab", "ef", 0x896C, 20), ("_cctab", "cc", 0x89BE, 27), ("_sptab", "sp", 0x8A2C, 4))

# ---------------------------------------------------------------- forward: cvopt.c as a state machine


# degree letters of the header lines; y x q (6 7 11) occur in the Z8000 table but not in V7 cvopt (names invented, *Annahme*)
LET = {"a": 16, "i": 12, "z": 4, "r": 9, "1": 5, "e": 20, "n": 63, "y": 6, "x": 7, "q": 11}


class Fehler(Exception):
    pass


def flag(src):
    """cvopt.c flag(): type letters -> number."""
    tab = {"w": 1, "i": 2, "b": 3, "f": 4, "d": 5, "u": 9, "s": 6, "l": 8}
    f = 0
    while True:
        c = src.get()
        if c in tab:
            f = tab[c]
        elif c == "p":
            f += 16
        else:
            src.unget(c)
            return f


class Src:
    def __init__(self, t):
        self.t, self.i = t, 0

    def get(self):
        if self.i >= len(self.t):
            return None
        c = self.t[self.i]
        self.i += 1
        return c

    def unget(self, c):
        if c is not None:
            self.i -= 1


class Cvopt:
    """Result: .strings = [(labels, bytes)] in output order, .obuf = raw text lines (V7 cvopt.tmp), .alias = {Ln: name}."""

    def __init__(self):
        self.strings = []       # [(list of labels, bytearray)]
        self.pending = []       # labels (name:) waiting for the next string
        self.obuf = []          # raw text of the tmp stream
        self.alias = {}         # Ln -> name  (`% [name]`)
        self.cur = None         # current string (bytearray) or None

    # --- output primitives (cvopt.c put/fprintf, split by the stream they go to)
    def put(self, c, curbuf, tabflg):
        b = ord(c) if isinstance(c, str) else c
        if tabflg[0]:
            tabflg[0] = 0
            b += 0x80
        if curbuf[0] == "s" and self.cur is not None:
            self.cur.append(b)
        elif curbuf[0] == "s":
            self.name.append(chr(b))
        else:
            self.obuf.append(chr(b))

    def run(self, text):
        src = Src(text)
        tabflg = [0]
        labno = 1
        curbuf = ["o"]
        smode = nlflg = snlflg = ssmode = 0
        self.name = []
        put = lambda c: self.put(c, curbuf, tabflg)       # noqa: E731
        o = self.obuf

        def pf(m, t):
            c = src.get()
            if c == "*":
                m += 0o100
            else:
                src.unget(c)
            o.append(".byte %o,%o" % (m, t))

        while True:
            c = src.get()
            if c is None:           # EOF: V7 writes "0\n" here; the MUTOS table has no terminating word (Differs from V7)
                return
            if c not in "\n\t":
                nlflg = 0
            if ssmode != 0 and c != "%":
                ssmode = 0
                curbuf[0] = "s"
                self.cur = bytearray()
                self.strings.append((self.pending, self.cur))
                self.pending = []
                self.slabel = "L%d" % labno
                self.strings[-1][0].append(self.slabel)
                labno += 1
            if c == "\\":          # escape: the next character is literal (Differs from V7; the image has literal S and R bytes)
                put(src.get())
                continue
            if c == ":":
                if not smode:
                    o.append("=.+2; 0")
                else:
                    put(":")
                continue
            if c == "A":
                d = src.get()
                if d in ("1", "2"):
                    put(chr(ord(d) + ord("A") - ord("1")))
                else:
                    put("O")
                    src.unget(d)
                continue
            if c == "B":
                d = src.get()
                put({"1": "C", "2": "D", "E": "L", "F": "P"}.get(d, "?"))
                continue
            if c == "C":
                put(chr(ord(src.get()) + ord("E") - ord("1")))
                continue
            if c in "FHS":
                put({"F": "G", "H": "H", "S": "K"}[c])
                snlflg = 1
                t = ord("A")
                while True:
                    d = src.get()
                    if d == "*":
                        t += 1
                    elif d == "S":
                        t += 2
                    elif d == "C":
                        t += 4
                    elif d == "1":
                        t += 8
                    elif d == "2":
                        t += 16
                    else:
                        src.unget(d)
                        break
                put(t)
                continue
            if c == "R":
                d = src.get()
                if d == "1":
                    put("J")
                else:
                    put("I")
                    src.unget(d)
                continue
            if c == "I":
                put("M")
                continue
            if c == "#":
                put("#" if src.get() == "1" else '"')
                continue
            if c == "%":
                if smode:
                    curbuf[0] = "o"
                if ssmode == 0:
                    p = src.get()
                    if p == "[":
                        # %[name:]  defines a label in the string stream before the next string
                        nm = ""
                        while True:
                            d = src.get()
                            if d == "]":
                                break
                            nm += d
                        src.get()
                        self.pending.append(nm.rstrip(":"))
                        continue
                    src.unget(p)
                while True:        # loop1
                    c = src.get()
                    if c in (" ", "\t"):
                        continue
                    if c in LET:
                        m = LET[c]
                    elif c == "c":
                        pf(8, flag(src))        # V7: t = 0 (no type letters after c); here c takes them (Differs from V7)
                        continue
                    elif c == ",":
                        o.append(";")
                        continue
                    elif c == "[":
                        # % [name]: the pending string label Ln becomes an alias of `name`
                        o.append("L%d=" % labno)
                        labno += 1
                        nm = ""
                        while True:
                            d = src.get()
                            if d == "]":
                                break
                            nm += d
                        o.append(nm)
                        ssmode = smode = 0
                        break
                    elif c == "\n":
                        o.append("\nL%d\n" % labno)
                        ssmode = 1
                        nlflg = 1
                        smode = 1
                        break
                    else:
                        put(c)
                        continue
                    pf(m, flag(src))
                continue
            if c == "\t":
                if nlflg:
                    nlflg = 0
                    continue
                if smode:
                    tabflg[0] += 1
                    continue
                put("\t")
                continue
            if c == "\n":
                if not smode:
                    put("\n")
                    continue
                if nlflg:
                    nlflg = 0
                    self.cur.append(0)
                    self.cur = None
                    curbuf[0] = "o"
                    smode = 0
                    continue
                if not snlflg:
                    self.cur.append(10)
                snlflg = 0
                nlflg = 1
                continue
            put(c)      # X, Y, T: no snlflg here (Differs from V7)


# ---------------------------------------------------------------- model of the object (as semantics of the output)

def modell(text):
    """table.s text -> (text bytes, data bytes, labels {name: ('T'|'D', offset)}); labels resolved to image addresses."""
    cv = Cvopt()
    cv.run(text)
    tb = bytearray()
    labs = {}
    refs = []             # (text offset, label) word pointers in text
    drefs = []            # (data offset, label)
    for ls, bs in cv.strings:
        for n in ls:
            labs[n] = ("T", len(tb))
        tb += bs
    if len(tb) & 1:
        tb.append(0)
    db = bytearray()
    sec = "T"
    lines = "".join(cv.obuf).split("\n")
    i = 0
    rec = None
    while i < len(lines):
        z = lines[i].strip()
        i += 1
        if not z or z.startswith("/"):
            continue
        tgt = tb if sec == "T" else db
        refl = refs if sec == "T" else drefs
        if z == ".data":
            sec = "D"
        elif z == ".text":
            sec = "T"
        elif z.startswith(".globl"):
            continue
        elif z.startswith(".byte"):
            for part in z.split(";"):
                a, b = part[len(".byte"):].strip().split(",")
                tgt += bytes((int(a, 8), int(b, 8)))
            nxt = lines[i].strip()
            i += 1
            tgt += b"\0\0"
            refl.append((len(tgt) - 2, nxt))
        elif z.endswith("=.") and not z.startswith("L"):
            labs[z[:-2]] = (sec, len(tgt))
        elif z.endswith("=.+2; 0"):
            tgt += b"\0\0"
            labs[z.split("=")[0]] = (sec, len(tgt))
        elif re.match(r"L\d+=", z):
            a, b = z.split("=")
            cv.alias[a] = b
        elif z.startswith("wv"):
            for tok in z[2:].replace(" ", "").split(","):
                tgt += b"\0\0"
                if re.fullmatch(r"\d+", tok):
                    tgt[-2:] = struct.pack(">H", int(tok))
                else:
                    refl.append((len(tgt) - 2, tok))
        elif z == "0":
            tgt += b"\0\0"
        else:
            raise Fehler("unknown line in the tmp stream: %r" % z)
    return cv, tb, db, labs, refs, drefs


def abbild(text):
    """-> (text bytes at TEXT0.., data bytes at DATA0..) with the pointers resolved."""
    cv, tb, db, labs, refs, drefs = modell(text)
    tl = {n: TEXT0 + off for n, (s, off) in labs.items() if s == "T"}
    dl = {n: DATA0 + off for n, (s, off) in labs.items() if s == "D"}

    def val(n):
        n = cv.alias.get(n, n)
        if n in tl:
            return tl[n]
        if n in dl:
            return dl[n]
        raise Fehler("undefined label " + n)
    for off, n in refs:
        tb[off:off + 2] = struct.pack(">H", val(n))
    for off, n in drefs:
        db[off:off + 2] = struct.pack(">H", val(n))
    return bytes(tb), bytes(db)


ASM_KOPF = """$NONSEGMENTED
constant
\tFP\t:= r14
\tSP\t:= r15
\tX\t:= external
\tG\t:= global
\tI\t:= internal
\tA\t:= array
\tPR\t:= procedure
\tE\t:= entry
\tB\t:= byte
\tW\t:= word
\tBV\t:= bval
\tWV\t:= wval
\tLV\t:= lval
\tL\t:= label"""


def uebersetzen(text):
    """table.s -> PLZ/ASM module (what `cvopt <table.s | as` is in V7)."""
    cv, tb, db, labs, refs, drefs = modell(text)
    nm = lambda n: cv.alias.get(n, n)      # noqa: E731
    atT, atD = {}, {}
    for n, (s, off) in labs.items():
        (atT if s == "T" else atD).setdefault(off, []).append(n)
    rt = {off: nm(n) for off, n in refs}
    rd = {off: nm(n) for off, n in drefs}

    def dump(buf, at, rf):
        out, off, run = [], 0, []

        def flush():
            while run:
                out.append(";".join(run[:16]))
                del run[:16]
        while off < len(buf):
            if off in at:
                flush()
                out += [n + ":" for n in at[off]]
            if off in rf:
                flush()
                out.append("WV " + rf[off])
                off += 2
                continue
            run.append("BV %%%X" % buf[off])
            off += 1
        flush()
        for n in at.get(len(buf), []):
            out.append(n + ":")
        return out
    t = ["table_ module", ASM_KOPF, "G\t_table\tPR", "E", "_table:"]
    t += dump(tb, atT, rt)
    t += ["end _table", "I", "G"]
    t += ["%s\tL" % n for n in sorted(atD_all(atD))]
    t += dump(db, atD, rd)
    t.append("end table_")
    return "\n".join(t) + "\n"


def atD_all(atD):
    return [n for ns in atD.values() for n in ns]


# ---------------------------------------------------------------- inverse: image -> table.s

DEG = {v: k for k, v in LET.items()}
DEG[8] = "c"
TYP = {1: "w", 2: "i", 3: "b", 4: "f", 5: "d", 9: "u", 6: "s", 8: "l"}
INV = {"A": "A1", "B": "A2", "C": "B1", "D": "B2", "E": "C1", "F": "C2", "I": "R", "J": "R1", "L": "BE", "M": "I", "O": "A", "P": "BF"}
FLAGS = (("*", 1), ("S", 2), ("C", 4), ("1", 8), ("2", 16))


def kopfzeile(r):
    d1, t1, d2, t2 = r

    def one(d, t):
        star = d >= 64
        s = DEG.get(d - 64 if star else d)
        tl = ("p" if t & 16 else "") + ({0: ""}.get(t & 15) if (t & 15) == 0 else TYP.get(t & 15, "?"))
        if s is None or "?" in tl:
            raise Fehler("record field %d,%d" % (d, t))
        return s + tl + ("*" if star else "")
    # cvopt order: letter, type letters, `*`
    return "%" + one(d1, t1) + "," + one(d2, t2)


def mustertext(s):
    """pattern bytes -> template lines (inverse of the string part of cvopt)."""
    lines, cur, i = [], "\t", 0
    sub = False
    while i < len(s):
        b = s[i]
        i += 1
        if b == 10:
            lines.append(cur)
            cur = "\t"
            continue
        if b & 0x80:
            cur += "\t"
            b &= 0x7F
        c = chr(b)
        if c in "GHK":
            cur += {"G": "F", "H": "H", "K": "S"}[c]
            k = s[i] - ord("A")
            i += 1
            if not 0 <= k < 32:
                raise Fehler("flag byte")
            cur += "".join(f for f, v in FLAGS if k & v)
            lines.append(cur)
            cur = "\t"
            if i < len(s) and chr(s[i] & 0x7F) in "*SC12" and not s[i] & 0x80:
                raise Fehler("literal flag character after a subtree macro")
            continue
        if c == "#":
            cur += "#1"
        elif c == '"':
            cur += "#2"
        elif c in INV:
            cur += INV[c]
        elif c in "RS%\\":
            cur += "\\" + c
        else:
            cur += c
    if cur != "\t":
        lines.append(cur)
    return lines


def quelle(raw):
    b = raw
    strs = {}
    a = TEXT0
    while a < TEXT_END:
        if b[a:a + 2] == b"\0\0" and a >= 0x631A:
            break
        e = b.index(0, a)
        strs[a] = b[a:e]
        a = e + 1
    rs = a + (a & 1) + 2                   # a zero word, then the first group
    groups, grp, p, gs = [], [], rs, rs
    while p < TEXT_END:
        if b[p] == 0:
            groups.append((gs, grp))
            grp = []
            p += 2
            gs = p
            continue
        grp.append(struct.unpack(">BBBBH", b[p:p + 6]) + (p,))
        p += 6
    if grp:                                # the last group has no terminating zero word (measured: freopen starts at 6988)
        groups.append((gs, grp))
    out = ["/ c code tables for the Z8000 -- reconstructed from /usr/lib/c1 (wk_w6.md), format as V7 table.s",
           "/ regtab efftab cctab sptab use wv lines (op, group); the groups are header lines plus template, a template shared by",
           "/ consecutive header lines or by the bracket forms.  Group names (cr ef cc sp plus first op) are inventions.", "",
           ".globl\t_regtab _efftab _cctab _sptab", ".data"]
    names, tabs = {}, []
    for tn, pre, adr, n in TABLES:
        out.append(tn + "=.")
        for k in range(n):
            op, ptr = struct.unpack(">HH", b[adr + 4 * k:adr + 4 * k + 4])
            names.setdefault(ptr, "%s%d" % (pre, op))
            out.append("\twv %d,%s" % (op, names[ptr]))
        out.append("\twv 0")
        if struct.unpack(">H", b[adr + 4 * n:adr + 4 * n + 2])[0] != 0:
            raise Fehler("table terminator")
    out += [".text", ""]
    gstarts = {gs for gs, _g in groups}
    mid = {ptr: nm for ptr, nm in names.items() if ptr not in gstarts}      # entered in the middle of a group: label without zero word
    # blocks = consecutive records with the same template; the template body stands at the block that defines the string
    # (definitions must follow the string addresses; an earlier block that uses a later-defined string takes the bracket form)
    blocks = []                                   # (group index, [records]) in record order
    for gi, (gs, grp) in enumerate(groups):
        for r in grp:
            if blocks and blocks[-1][0] == gi and blocks[-1][1][-1][4] == r[4]:
                blocks[-1][1].append(r)
            else:
                blocks.append((gi, [r]))
    definer, prev = {}, -1
    for ptr in sorted(strs):
        cand = [k for k, (gi, rs_) in enumerate(blocks) if k > prev and rs_[0][4] == ptr]
        if not cand:
            raise Fehler("no block can define the template at %04X (used by blocks %s, previous definer %d)" % (ptr, [k for k, (gi, rs_) in enumerate(blocks) if rs_[0][4] == ptr], prev))
        definer[ptr] = prev = cand[0]
    shared = {ptr for k, (gi, rs_) in enumerate(blocks) if definer[rs_[0][4]] != k for ptr in (rs_[0][4],)}
    k = 0
    for gi, (gs, grp) in enumerate(groups):
        out.append("/ group at %04x" % gs)
        out.append("%s:" % names.get(gs, "xr%04x" % gs))
        while k < len(blocks) and blocks[k][0] == gi:
            rs_ = blocks[k][1]
            for r in rs_[1:]:
                if r[5] in mid:
                    raise Fehler("table pointer %04X lies inside a block of shared header lines" % r[5])
            if rs_[0][5] in mid:
                out.append("%s=." % mid[rs_[0][5]])
            ptr = rs_[0][4]
            heads = [kopfzeile(r[:4]) for r in rs_]
            if definer[ptr] == k:
                if ptr in shared:
                    out.append("%%[t%04x:]" % ptr)
                out += heads + mustertext(strs[ptr]) + [""]
            else:
                out += heads + ["%%\t[t%04x]" % ptr, ""]
            k += 1
    return "\n".join(out) + "\n"


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    cmd = sys.argv[1]
    if cmd == "uebersetzen":
        pfad = sys.argv[2] if len(sys.argv) > 2 else os.path.join(REPO, "userspace", "c1", "table.s")
        sys.stdout.write(uebersetzen(open(pfad).read()))
        return 0
    raw = open(sys.argv[2] if len(sys.argv) > 2 else RAW, "rb").read()
    if cmd == "quelle":
        sys.stdout.write(quelle(raw))
        return 0
    if cmd == "pruefen":
        tb, db = abbild(open(os.path.join(REPO, "userspace", "c1", "table.s")).read())
        ok = tb == raw[TEXT0:TEXT_END] and db == raw[DATA0:DATA0 + len(db)]
        print("text %d B %s, data %d B %s" % (len(tb), "equal" if tb == raw[TEXT0:TEXT_END] else "DIFFERENT",
                                              len(db), "equal" if db == raw[DATA0:DATA0 + len(db)] else "DIFFERENT"))
        return 0 if ok else 1
    return 2


if __name__ == "__main__":
    sys.exit(main())
