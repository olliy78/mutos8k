"""wk_w0: triage of the tool chain programs (plan 52, W0) -- host only, no guest runs.

  python3 -I tools/userspace/wk_w0.py zuordnung NAME [--ablegen]   # own functions of NAME <-> V7 functions
  python3 -I tools/userspace/wk_w0.py tabellen                      # yacc tables of cpp vs. V7 yacc run, opdope, c1/c2 tables
  python3 -I tools/userspace/wk_w0.py libc                          # libc.a members (archive order)

NAME in cc ld cpp c0 c1 c2 (as has no V7 counterpart: only the function list).  Needs the files that
`pipeline.py holen/karte NAME --ablegen` leave behind (userspace/NAME/NAME.lst, .namen, .strings, work/NAME.orig).

Method (all heuristics, the result is evidence and not proof; doc/userspace/wk_w0.md):
  * binary functions = `call csv` entries plus call targets between 0x30 (end of crt0) and the first libc member;
  * V7 functions = definitions found in the V7 sources (K&R scanner, no preprocessor);
  * both lists are aligned in order (dynamic programming) with a score from shared string literals, shared libc
    calls, size per source line and number of calls of own functions;
  * a pair counts as "same" if string literals, libc calls and number of own calls agree.
"""
import math
import os
import re
import struct
import sys
from collections import Counter

HIER = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HIER))
V7 = os.path.join(REPO, "original", "unix-v7", "usr", "src", "cmd") + os.sep
CFG = {
    "cc": ["cc.c"],
    "ld": ["ld.c"],
    "cpp": ["cpp/cpp.c", "cpp/yylex.c"],
    "c0": ["c/c0%d.c" % i for i in range(6)],
    "c1": ["c/c1%d.c" % i for i in range(4)],
    "c2": ["c/c20.c", "c/c21.c"],
}
LIB0 = {"c1": 0x57CE}   # first libc function (atof) is not found by the signature search: measured by hand
KW = set("if while for switch return sizeof else do case default goto break continue".split())
MAC = {"getc": "filbuf", "getchar": "filbuf", "putc": "flsbuf", "putchar": "flsbuf"}


# ---------------------------------------------------------------- binary side
def load(n):
    d = os.path.join(REPO, "userspace", n)
    hdr = struct.unpack(">8H", open(os.path.join(d, "work", n + ".orig"), "rb").read(16))
    ins = []
    for z in open(os.path.join(d, n + ".lst")):
        m = re.match(r"([0-9A-F]{4})  ([0-9A-F ]+?)\s{2,}(\S.*)$", z.rstrip())
        if m:
            ins.append((int(m[1], 16), m[3]))
    strs = {}
    for z in open(os.path.join(d, n + ".strings")):
        a, _, t = z.rstrip("\n").partition(" ")
        strs[int(a, 16)] = t
    nam = []
    for z in open(os.path.join(d, n + ".namen")):
        if z.startswith("#") or not z.strip():
            continue
        t = z.split()
        nam.append((int(t[0], 16), int(t[1]), t[2], len(t) > 3))
    return hdr[1], hdr[2], hdr[3], ins, strs, nam


def binfuncs(n):
    text, data, bss, ins, strs, nam = load(n)
    strong = [a for a, ln, nm, w in nam if not w and "|" not in nm]
    lib0 = LIB0.get(n, min(strong))
    tg = set()
    for a, m in ins:
        mm = re.match(r"(CALL|CALR) L([0-9A-F]{4})$", m)
        if mm:
            tg.add(int(mm[2], 16))
    addrs = {a for a, m in ins}
    starts = sorted({a for a, m in ins if m.startswith("CALL csv")} | (tg & addrs) | {0x30})
    ends = starts[1:] + [ins[-1][0] + 2]
    out = []
    for s, e in zip(starts, ends):
        if s >= lib0:
            break
        refs, calls, own = [], [], []
        for a, m in ins:
            if not (s <= a < e):
                continue
            for h in re.findall(r"%([0-9A-F]{4})\b", m):
                v = int(h, 16)
                if v in strs and v >= text:
                    refs.append(strs[v])
            mm = re.match(r"(CALL|CALR) (\S+)", m)
            if mm:
                t = mm[2]
                if t in ("csv", "cret"):
                    continue
                if re.match(r"L[0-9A-F]{4}$", t):
                    own.append(int(t[1:], 16))
                else:
                    calls.append(t.lstrip("_"))
        out.append(dict(a=s, size=e - s, refs=refs, calls=calls, own=own))
    return out, lib0


# ------------------------------------------------------------------- V7 side
def unesc(t):
    try:
        return t.encode().decode("unicode_escape")
    except Exception:
        return t


def parse_v7(path):
    src = open(V7 + path, errors="replace").read()
    src = re.sub(r"/\*.*?\*/", " ", src, flags=re.S)
    src = "\n".join("" if l.lstrip().startswith("#") and not l.startswith("%") else l for l in src.split("\n"))
    out = []
    depth = stmt = i = 0
    n = len(src)

    def skipq(j, q):
        j += 1
        while j < n and src[j] != q:
            j += 2 if src[j] == "\\" else 1
        return j + 1

    while i < n:
        c = src[i]
        if c in "\"'":
            i = skipq(i, c)
            continue
        if c == "{":
            if depth == 0:
                head = src[stmt:i]
                hm = None
                for seg in reversed(head.split(";")):
                    mm = re.match(r"\s*(?:[A-Za-z_][\w \t\*\n]*?[ \t\*\n])?([A-Za-z_]\w*)\s*\([\w\s,\*]*\)[^()=]*$", seg)
                    if mm and mm[1] not in KW:
                        hm = mm
                        break
                    if "(" in seg:
                        break
                if hm and not re.match(r"\s*(struct|union|enum)\b[^()]*$", head):
                    d = 0
                    j = i
                    while j < n:
                        ch = src[j]
                        if ch in "\"'":
                            j = skipq(j, ch)
                            continue
                        if ch == "{":
                            d += 1
                        elif ch == "}":
                            d -= 1
                            if d == 0:
                                break
                        j += 1
                    body = src[i:j + 1]
                    out.append(dict(name=hm[1], file=path.split("/")[-1], body=body, lines=body.count("\n") + 1))
                    i = j + 1
                    stmt = i
                    continue
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                stmt = i + 1
        i += 1
    for f in out:
        b = f["body"]
        f["strs"] = [unesc(x) for x in re.findall(r'"((?:[^"\\]|\\.)*)"', b)]
        b2 = re.sub(r'"(?:[^"\\]|\\.)*"', "", b)
        f["calls"] = [c for c in re.findall(r"\b([A-Za-z_]\w*)\s*\(", b2) if c not in KW]
    return out


def v7funcs(n):
    fs = []
    for f in CFG[n]:
        fs += parse_v7(f)
    names = {f["name"] for f in fs}
    for f in fs:
        f["lib"] = [c for c in f["calls"] if c not in names]
        f["ownc"] = [c for c in f["calls"] if c in names]
    return fs


def macros(n):
    names = set()
    for f in CFG[n] + (["c/c0.h", "c/c1.h", "c/c2.h"] if n in ("c0", "c1", "c2") else []):
        for l in open(V7 + f, errors="replace"):
            m = re.match(r"\s*#\s*define\s+([A-Za-z_]\w*)\(", l)
            if m:
                names.add(m[1])
    return names


# ------------------------------------------------------------------ alignment
def score(b, f):
    s = 3.0 * len(set(b["refs"]) & set(x for x in f["strs"] if x))
    cb = Counter(b["calls"])
    cf = Counter(f["lib"])
    uni = sum((cb | cf).values())
    s += 3.0 * sum((cb & cf).values()) / uni if uni else 0.6
    s -= 0.4 * abs(math.log(max(b["size"], 1) / max(f["lines"], 1) / 18.0))
    nb, nf = len(b["own"]), len(f["ownc"])
    s -= 0.3 * abs(nb - nf) / (1 + max(nb, nf))
    if nb == nf and nb > 0:
        s += 0.8
    elif nb and nf:
        s += 0.4 * min(nb, nf) / max(nb, nf)
    return s


def align(B, F, gap=0.9, off=0.9):
    nb, nf = len(B), len(F)
    D = [[0] * (nf + 1) for _ in range(nb + 1)]
    P = [[None] * (nf + 1) for _ in range(nb + 1)]
    for i in range(1, nb + 1):
        D[i][0], P[i][0] = -gap * i, "b"
    for j in range(1, nf + 1):
        D[0][j], P[0][j] = -gap * j, "f"
    S = [[score(B[i], F[j]) for j in range(nf)] for i in range(nb)]
    for i in range(1, nb + 1):
        for j in range(1, nf + 1):
            D[i][j], P[i][j] = max((D[i - 1][j - 1] + S[i - 1][j - 1] - off, "m"), (D[i - 1][j] - gap, "b"), (D[i][j - 1] - gap, "f"))
    i, j, res = nb, nf, []
    while i > 0 or j > 0:
        p = P[i][j]
        if p == "m":
            res.append((i - 1, j - 1, S[i - 1][j - 1]))
            i, j = i - 1, j - 1
        elif p == "b":
            res.append((i - 1, None, 0))
            i -= 1
        else:
            res.append((None, j - 1, 0))
            j -= 1
    return res[::-1]


def zuordnung(n):
    """-> rows (one per binary function), v7only, lib0, B, F"""
    B, lib0 = binfuncs(n)
    F = v7funcs(n)
    mac = macros(n)
    allsrc = "".join(open(V7 + f, errors="replace").read() for f in CFG[n])
    binraw = raw_of(n)
    rows, v7only = [], []
    for i, j, sc in align(B, F):
        if i is None:
            v7only.append(F[j])
            continue
        b = B[i]
        if j is None:
            rows.append(dict(a=b["a"], size=b["size"], v7=None, cls="nicht V7", sc=0.0, why=""))
            continue
        f = F[j]
        sb = set(x for x in b["refs"] if x not in allsrc and x.replace("\\", "") not in allsrc)
        sf = set(x for x in f["strs"] if len(x) > 1 and x.encode("latin1", "replace") not in binraw)
        cb = Counter(b["calls"])
        cf = Counter(MAC.get(c, c) for c in f["lib"] if c not in mac)
        nb, nf = len(b["own"]), len(f["ownc"])
        why = []
        if sb:
            why.append("Zeichenkette nur im Binary: " + "; ".join(sorted(sb))[:60])
        if sf:
            why.append("V7-Zeichenkette fehlt: " + "; ".join(sorted(x[:20] for x in sf))[:60])
        if cb != cf:
            why.append("libc-Aufrufe +%s -%s" % (dict(cb - cf), dict(cf - cb)))
        if sb or sf or cb != cf:
            cls = "V7 abweichend"
        elif nb != nf:
            cls = "V7 gleich*"
        else:
            cls = "V7 gleich"
        rows.append(dict(a=b["a"], size=b["size"], v7=f["file"] + ":" + f["name"], cls=cls, sc=round(sc, 1),
                         why=" | ".join(why).replace("\n", " ").replace("\t", " ") + ("" if nb == nf else " | eigene Aufrufe %d/%d" % (nb, nf))))
    return rows, v7only, lib0, B, F


def cmd_nur_binary(n, ablegen):
    """`as`: no V7 counterpart, only the function list with strings and libc calls."""
    B, lib0 = binfuncs(n)
    lines = ["# %s: own functions (csv entries and call targets in 0030..%04X), no V7 counterpart (tools/userspace/wk_w0.py zuordnung)" % (n, lib0),
             "# addr size own-calls libc-calls  strings"]
    for b in B:
        lines.append("%04X %5d %3d  %-30s %s" % (b["a"], b["size"], len(b["own"]), ",".join(sorted(set(b["calls"]))),
                                                " | ".join(r[:28] for r in b["refs"][:3])))
    txt = "\n".join(lines) + "\n"
    if ablegen:
        with open(os.path.join(REPO, "userspace", n, "v7zuordnung.txt"), "w") as f:
            f.write(txt)
    else:
        sys.stdout.write(txt)


def cmd_zuordnung(n, ablegen):
    if n not in CFG:
        return cmd_nur_binary(n, ablegen)
    rows, v7only, lib0, B, F = zuordnung(n)
    c = Counter(r["cls"] for r in rows)
    by = Counter()
    for r in rows:
        by[r["cls"]] += r["size"]
    lines = ["# %s: own functions (csv entries and call targets in 0030..%04X) <-> V7 (tools/userspace/wk_w0.py zuordnung)" % (n, lib0),
             "# addr size  v7-function  class  score  notes   (assignment by order + features, evidence not proof)"]
    for r in rows:
        lines.append("%04X %5d  %-22s %-14s %5.1f  %s" % (r["a"], r["size"], r["v7"] or "-", r["cls"], r["sc"], r["why"]))
    for f in v7only:
        lines.append("----  V7 function without binary counterpart: %s:%s (%d lines)" % (f["file"], f["name"], f["lines"]))
    lines.append("# summary: " + ", ".join("%s %d (%d B)" % (k, c[k], by[k]) for k in sorted(c)) + "; V7 functions %d, without counterpart %d" % (len(F), len(v7only)))
    txt = "\n".join(lines) + "\n"
    if ablegen:
        with open(os.path.join(REPO, "userspace", n, "v7zuordnung.txt"), "w") as f:
            f.write(txt)
    else:
        sys.stdout.write(txt)


# --------------------------------------------------------------------- tables
def v7_opdope(path):
    s = open(V7 + "c/" + path).read()
    m = re.search(r"int\s+opdope\[\]\s*\{(.*?)\n\};", s, re.S)
    body = re.sub(r"/\*.*?\*/", "", m[1], flags=re.S)
    return [int(x, 8) for x in re.findall(r"\b0[0-7]*\b", body)]


def raw_of(n):
    return open(os.path.join(REPO, "userspace", n, "work", n + ".raw"), "rb").read()


def cmd_tabellen():
    for n, path in (("c1", "c13.c"), ("c0", "c05.c")):
        v = v7_opdope(path)
        raw = raw_of(n)
        w = struct.unpack(">%dH" % (len(raw) // 2), raw[:len(raw) // 2 * 2])
        for i in range(len(w) - 8):
            if list(w[i:i + 6]) == v[:6] and w[i + 4] != 0:
                b = list(w[i:i + len(v)])
                d = [k for k in range(len(v)) if v[k] != b[k]]
                print("%s opdope at %04X: V7 %s has %d entries, %d differ %s" % (n, 2 * i, path, len(v), len(d), d))
                break
    raw = raw_of("c1")
    W = lambda a: struct.unpack(">H", raw[a:a + 2])[0]
    a = 0x88AE
    for nm in ("regtab", "efftab", "cctab", "sptab"):
        st, k = a, 0
        while W(a) != 0:
            k += 1
            a += 4
        a += 2
        print("c1 %s at %04X: %d entries" % (nm, st, k))
    raw = raw_of("c2")
    W = lambda a: struct.unpack(">H", raw[a:a + 2])[0]

    def cs(a):
        return raw[a:raw.index(b"\0", a)].decode("latin1")

    for st, nm in ((0x4252, "condition names"), (0x4286, "optab")):
        a, k = st, []
        while not (W(a) == 0 and W(a + 2) == 0):
            k.append("%s:%04X" % (cs(W(a)), W(a + 2)))
            a += 4
        print("c2 %s at %04X: %d entries: %s" % (nm, st, len(k), " ".join(k)))


# ----------------------------------------------------------------------- libc
def cmd_libc():
    sys.path[:0] = [os.path.join(REPO, "tools", "userspace"), os.path.join(REPO, "tools", "kernel"), os.path.join(REPO, "tools")]
    import uspace as U
    import objformat as O
    import tempfile
    d = tempfile.mkdtemp()
    lib = U.platte_holen("usr", "lib/libc.a", d)
    for i, m in enumerate(O.Archiv.lesen(lib).mitglieder):
        o = m.objekt()
        print("%3d %-12s text %5d data %4d bss %4d syms %3d" % (i, m.name.decode(), len(o.text), len(o.data), o.bss, len(o.syms)))


def main(argv):
    if len(argv) >= 3 and argv[1] == "zuordnung":
        cmd_zuordnung(argv[2], "--ablegen" in argv)
    elif len(argv) >= 2 and argv[1] == "tabellen":
        cmd_tabellen()
    elif len(argv) >= 2 and argv[1] == "libc":
        cmd_libc()
    else:
        print(__doc__)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
