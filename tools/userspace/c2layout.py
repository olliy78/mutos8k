"""Plan 52 W5e goal 2: block layout of single c2 functions, compared at instruction level (mnemonic, condition, jump target
index) against the ORIGINAL listing userspace/c2/c2.lst -- without a 6-minute build of the whole c2.

  python3 -I tools/userspace/c2layout.py lauf FILE.c...   guest: each FILE (a candidate of ONE function, plus the header
                                                          userspace/c2/c2.h) goes through cpp, c0, c1, the shipped c2
                                                          (= `cc -O -S`); result userspace/c2/work/layout/FILE.s
  python3 -I tools/userspace/c2layout.py zeig FUNC FILE.s  skeleton of FUNC in the original and in FILE.s, first difference

Skeleton: one tuple per instruction (op, cc, target) where jumps use `J` + condition, target = index of the instruction the
jump lands on, calls carry no target.  Operands are NOT compared (the full comparison stays with pipeline.py vergleich).
"""
import os
import re
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U       # noqa: E402

LST = os.path.join(U.REPO, "userspace", "c2", "c2.lst")
WORK = os.path.join(U.REPO, "userspace", "c2", "work", "layout")
# function -> (start, end) in the original (measured, doc/userspace/wk_w5.md)
FUNCS = {"addsob": (0x21BE, 0x23E4), "toofar": (0x23E4, 0x244E), "ilen": (0x244E, 0x2510), "adrlen": (0x2510, 0x2572),
         "equop": (0x258C, 0x25FE), "findrand": (0x2AF2, 0x2BC0), "compare": (0x2F94, 0x3060)}
CC = {"eq": "Z", "ne": "NZ", "lt": "LT", "ge": "GE", "gt": "GT", "le": "LE", "lo": "C", "his": "NC", "hi": "UGT", "los": "ULE",
      "pl": "PL", "mi": "MI", "z": "Z", "nz": "NZ"}


def skel_lst(f):
    a, e = FUNCS[f]
    ins, lab = [], {}
    for z in open(LST, encoding="latin-1"):
        z = z.rstrip("\n")
        m = re.match(r"^(L[0-9A-F]{4}):", z)
        if m:
            lab[m.group(1)] = len(ins)
            continue
        m = re.match(r"^([0-9A-F]{4})  ([0-9A-F ]+?)\s{2,}(\S.*)$", z)
        if not m:
            continue
        ad = int(m.group(1), 16)
        if ad < a or ad >= e:
            continue
        ins.append((ad, m.group(3)))
    raw = []
    for i, (ad, t) in enumerate(ins):
        w = t.split(None, 1)
        op = w[0].upper()
        rest = w[1] if len(w) > 1 else ""
        if op in ("JR", "JP"):
            p = rest.split(",")
            cc, tgt = (p[0].strip().upper(), p[1].strip()) if len(p) > 1 else ("", p[0].strip())
            raw.append(("J", {"NC": "NC", "C": "C"}.get(cc, cc), tgt))
        elif op == "CALL":
            raw.append(("CALL", "", ""))
        else:
            raw.append((op, "", ""))
    out = []
    for op, cc, tgt in raw:
        if op == "J":
            out.append((op, cc, lab.get(tgt, tgt)))   # external target (cret, ...) stays a name
        else:
            out.append((op, cc, ""))
    return out


def skel_s(f, path):
    z = open(path, encoding="latin-1").read().split("\n")
    i0 = next(i for i, x in enumerate(z) if x.startswith("~~" + f + ":"))
    ins, lab = [], {}
    for x in z[i0 + 1:]:
        if x.startswith("end _" + f):
            break
        if not x or x[0] in "~$" or x.startswith("E") and len(x) == 1:
            continue
        m = re.match(r"^(L\d+):$", x)
        if m:
            lab[m.group(1)] = len(ins)
            continue
        w = x.split("\t")
        if len(w) < 1 or not re.match(r"^[a-z]", w[0]):
            continue
        ins.append(w)
    out = []
    for w in ins:
        op = w[0].upper()
        if op in ("JR", "JP"):
            if len(w) == 3:
                out.append(("J", CC.get(w[1], w[1].upper()), w[2]))
            elif w[1] in ("cret",):
                out.append(("J", "", w[1]))
            else:
                out.append(("J", "", w[1]))
        elif op == "CALL":
            out.append(("CALL", "", ""))
        else:
            out.append((op, "", ""))
    return [(op, cc, lab.get(t, t) if op == "J" else "") for op, cc, t in out]


def zeig(f, path):
    a, b = skel_lst(f), skel_s(f, path)
    print("%s: original %d instructions, candidate %d" % (f, len(a), len(b)))
    for i in range(max(len(a), len(b))):
        x = a[i] if i < len(a) else None
        y = b[i] if i < len(b) else None
        print("%3d %s %-28s %-28s" % (i, " " if x == y else "*", x, y))
    return a == b


def lauf(dateien):
    sys.path.insert(0, os.path.join(U.TOOLS, "kernel"))
    import gast_as
    U.pruefe()
    U.emu.build()
    os.makedirs(WORK, exist_ok=True)
    kopf = open(os.path.join(U.REPO, "userspace", "c2", "c2.h"), "rb").read()
    for g in range(0, len(dateien), 8):
        grp = dateien[g:g + 8]
        q = {"c2.h": kopf}
        bs, rueck = [], []
        for p in grp:
            n = os.path.splitext(os.path.basename(p))[0]
            q[n + ".c"] = open(p, "rb").read()
            e = n + ".err"
            bs.append("cd /tmp;/usr/lib/cpp -I/mnt /mnt/%s.c ci >%s 2>&1;/usr/lib/c0 ci c1 c2 >>%s 2>&1;>ci;cd /mnt" % (n, e, e))
            bs.append("cd /tmp;/usr/lib/c1 c1 c2 c5 >>%s 2>&1;>c1;>c2;/usr/lib/c2 c5 %s.s >>%s 2>&1;>c5;cd /mnt" % (e, n, e))
            rueck += [n + ".s", n + ".err"]
        r = gast_as.gast_befehle(os.path.join(WORK, "sess"), q, bs, rueck, frist=20_000_000_000, ausgabe={})
        for p in grp:
            n = os.path.splitext(os.path.basename(p))[0]
            if r.get(n + ".s"):
                open(os.path.join(WORK, n + ".s"), "wb").write(r[n + ".s"])
            e = (r.get(n + ".err") or b"").decode("latin-1").strip()
            print(n, "ok" if r.get(n + ".s") else "MISSING", e[:100])


def main():
    a = sys.argv[1:]
    if a and a[0] == "lauf":
        lauf(a[1:])
    elif a and a[0] == "zeig":
        sys.exit(0 if zeig(a[1], a[2]) else 1)
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
