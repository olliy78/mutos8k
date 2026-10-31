#!/usr/bin/env python3
"""speicher.py -- memory management functions of MUTOS against UNIX V7 and other trees (AP H7, doc/herkunft/speicher.md).

Uses tools/herkunft/herkunft.py (tokenizer, function splitter, winnowing).  Run with `python3 -I`.
Paths are arguments; nothing is written into kernel/ or original/.

  inv   [--v7 DIR] [--base LABEL=DIR]   token diff (level abs) of the memory functions: V7 tokens, equal, deleted, inserted
  snip                                  tokens of the line ranges that carry the NEW memory logic of MUTOS (kernel/c)
  cmp   --ref LABEL=dir[:dir...] ...    best/same-name similarity of the memory functions against reference trees
  total                                 abs-token totals of kernel/c and of V7 usr/sys/{sys,dev}

Examples (SCR = scratchpad with the unpacked trees):
  python3 -I tools/herkunft/speicher.py inv --base hippe=SCR/h6_hippe_eff
  python3 -I tools/herkunft/speicher.py snip
  python3 -I tools/herkunft/speicher.py cmp --ref v7=original/unix-v7/usr/sys/sys:original/unix-v7/usr/sys/dev \
        --ref wega=SCR/h6_wega/P8000/WEGA/src/uts/sys:SCR/h6_wega/P8000/WEGA/src/uts/dev --ref lsx=SCR/h7/x/lsx_usr
"""
import argparse
import difflib
import importlib.util
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
_spec = importlib.util.spec_from_file_location("herkunft", REPO / "tools/herkunft/herkunft.py")
H = importlib.util.module_from_spec(_spec)
sys.modules["herkunft"] = H
_spec.loader.exec_module(H)

# (V7 file below usr/sys, V7 function, MUTOS file below kernel/c, MUTOS function, class)
# class: a unchanged (MMU independent), b omitted/stub, c V7 logic replaced/adapted, d new without V7 counterpart
ROWS = [
    ("sys/ureg.c", "sureg", "ureg.c", "sureg", "b"),
    ("sys/ureg.c", "estabur", "ureg.c", "estabur", "b"),
    ("sys/slp.c", "expand", "slp.c", "expand", "b"),
    ("sys/text.c", "xalloc", "text.c", "xalloc", "b"),
    ("sys/text.c", "xexpand", "text.c", "xstub1", "b"),
    ("sys/text.c", "xlock", "text.c", "xlock", "b"),
    ("sys/text.c", "xunlock", "text.c", "xunlock", "b"),
    ("sys/text.c", "xccdec", "text.c", "xccdec", "b"),
    ("sys/text.c", "xumount", "text.c", "xumount", "b"),
    ("sys/text.c", "xrele", "text.c", "xrele", "b"),
    ("sys/text.c", "xuntext", "text.c", "xstub2", "b"),
    ("sys/sig.c", "grow", "sig.c", "grow", "b"),
    ("sys/sys1.c", "sbreak", "sys1.c", "sbreak", "b"),
    ("sys/slp.c", "newproc", "slp.c", "newproc", "c"),
    ("sys/slp.c", "swapin", "slp.c", "swapin", "c"),
    ("sys/text.c", "xswap", "text.c", "xswap", "c"),
    ("sys/sys1.c", "getxfile", "sys1.c", "getxfile", "c"),
    ("sys/sys1.c", "fork", "sys1.c", "fork", "c"),
    ("sys/sys1.c", "exece", "sys1.c", "exece", "c"),
    ("sys/sig.c", "core", "sig.c", "core", "c"),
    ("sys/sig.c", "procxmt", "sig.c", "procxmt", "c"),
    ("sys/machdep.c", "startup", "machdep.c", "startup", "c"),
    ("sys/machdep.c", "sendsig", "machdep.c", "sendsig", "c"),
    ("sys/trap.c", "trap", "trap.c", "trap", "c"),
    ("dev/bio.c", "swap", "bio.c", "swap", "c"),
    ("dev/bio.c", "physio", "bio.c", "physio", "c"),
    ("dev/mem.c", "mmread", "rk.c", "mmread", "c"),
    ("dev/mem.c", "mmwrite", "rk.c", "mmwrite", "c"),
    ("sys/slp.c", "swtch", "slp.c", "swtch", "a"),
    ("sys/slp.c", "sched", "slp.c", "sched", "a"),
    ("sys/text.c", "xfree", "text.c", "xfree", "a"),
    ("sys/malloc.c", "malloc", "malloc.c", "malloc", "a"),
    ("sys/malloc.c", "mfree", "malloc.c", "mfree", "a"),
]

# line ranges (kernel/c) carrying NEW memory logic; checked against the sources of 2026-10-31
SNIPS = [
    ("slp.c", 356, 359, "swapin: u area address + 5 argument swap"),
    ("slp.c", 542, 542, "newproc: fixed image size 256"),
    ("slp.c", 567, 573, "newproc: copy u area (swap branch)"),
    ("slp.c", 584, 590, "newproc: copy u area (core branch)"),
    ("text.c", 53, 60, "xswap: swap size from u"),
    ("bio.c", 546, 569, "swap: whole image branch (3 parts)"),
    ("machdep.c", 44, 61, "startup: segment loop"),
    ("sys1.c", 305, 307, "getxfile: clear the whole segment"),
    ("sys1.c", 524, 526, "fork: swap demand from u"),
    ("sys1.c", 579, 590, "sbreak: clear new clicks"),
    ("rk.c", 84, 94, "mmread: usrseg"),
    ("rk.c", 111, 125, "mmwrite: usrseg"),
    ("bio.c", 744, 744, "physio: b_xmem from usrseg"),
    ("sig.c", 248, 256, "core: data/stack from u_dsize and SP"),
    ("ureg.c", 107, 111, "estabur: size check"),
]


def funcmap(path):
    s = H.Source(str(path))
    return {f.name: f for f in s.funcs}


def absn(f):
    return H.norm_function(f, "abs")


def cmd_inv(a):
    v7 = Path(a.v7)
    bases = [("v7", v7)] + [tuple(b.split("=", 1)) for b in (a.base or [])]
    cache = {}
    for label, root in bases:
        root = Path(root)
        print("== base %s (%s)" % (label, root))
        print("%-9s %-3s | ref  equal deleted inserted(MUTOS)" % ("function", "cl"))
        tot = {}
        for vf, vn, mf, mn, kl in ROWS:
            rp = root / vf
            if not rp.exists():
                print("%-9s missing %s" % (vn, rp))
                continue
            mfs = cache.setdefault(mf, funcmap(REPO / "kernel/c" / mf))
            rfs = cache.setdefault(str(rp), funcmap(rp))
            if vn not in rfs or mn not in mfs:
                print("%-9s not found" % vn)
                continue
            x, y = absn(rfs[vn]), absn(mfs[mn])
            sm = difflib.SequenceMatcher(None, x, y, autojunk=False)
            eq = sum(t.size for t in sm.get_matching_blocks())
            print("%-9s %-3s | %4d %5d %7d %8d" % (vn, kl, len(x), eq, len(x) - eq, len(y) - eq))
            t = tot.setdefault(kl, [0, 0, 0, 0, 0])
            t[0] += 1; t[1] += len(x); t[2] += eq; t[3] += len(x) - eq; t[4] += len(y) - eq
        for kl, t in sorted(tot.items()):
            print("class %s: %2d functions, ref %5d, equal %5d, deleted %5d, inserted %5d" % ((kl,) + tuple(t)))


def cmd_snip(a):
    total = 0
    for f, s, e, lab in SNIPS:
        lines = (REPO / "kernel/c" / f).read_text(encoding="latin-1").splitlines()[s - 1:e]
        toks, _ = H.tokenize("\n".join(lines))
        n = len([t for t in toks if not t.pp])
        total += n
        print("%-10s %4d-%-4d %4d tok  %s" % (f, s, e, n, lab))
    print("sum", total)


def cmd_cmp(a):
    refs = [H.parse_ref(r, H.DEFAULT_K, H.DEFAULT_W) for r in a.ref]
    cache = {}
    names = ["%s" % r.label for r in refs]
    print("%-9s %5s  %s" % ("function", "tok", "  ".join("%-8s" % n for n in names)))
    for vf, vn, mf, mn, kl in ROWS:
        src = cache.setdefault(mf, H.Source(str(REPO / "kernel/c" / mf)))
        f = {x.name: x for x in src.funcs}.get(mn)
        if not f:
            continue
        cells = []
        for r in refs:
            m = r.best_function(src, f, "abs")
            nm = m.get("ref_name") or "-"
            sn = (m.get("same_name") or {}).get("sim")
            cells.append("%.2f%s" % (m["sim"], "" if nm == mn else "(" + nm[:6] + ")"))
        print("%-9s %5d  %s" % (mn, len(absn(f)), "  ".join("%-8s" % c for c in cells)))


def cmd_total(a):
    def tot(d):
        n = fn = 0
        for p in sorted(Path(d).glob("*.c")):
            s = H.Source(str(p))
            fn += len(s.funcs)
            n += sum(len(absn(f)) for f in s.funcs)
        return fn, n
    print("MUTOS kernel/c          functions/tokens:", tot(REPO / "kernel/c"))
    print("V7 usr/sys/sys          functions/tokens:", tot(REPO / "original/unix-v7/usr/sys/sys"))
    print("V7 usr/sys/dev          functions/tokens:", tot(REPO / "original/unix-v7/usr/sys/dev"))


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("inv")
    p.add_argument("--v7", default=str(REPO / "original/unix-v7/usr/sys"))
    p.add_argument("--base", action="append", help="LABEL=dir (tree with sys/ and dev/ below)")
    p.set_defaults(fn=cmd_inv)
    p = sub.add_parser("snip")
    p.set_defaults(fn=cmd_snip)
    p = sub.add_parser("cmp")
    p.add_argument("--ref", action="append", required=True, help="LABEL=dir[:dir...]")
    p.set_defaults(fn=cmd_cmp)
    p = sub.add_parser("total")
    p.set_defaults(fn=cmd_total)
    a = ap.parse_args(argv)
    a.fn(a)


if __name__ == "__main__":
    main()
