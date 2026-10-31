#!/usr/bin/env python3
"""kontext.py -- Z8001 context / trap / system call functions of MUTOS against UNIX V7 and other trees (AP H8, doc/herkunft/z8001_kontext.md).

Uses tools/herkunft/herkunft.py (tokenizer, level abs).  Run with `python3 -I`.  Reads only; writes nothing.
  cmp  --ref LABEL=dir[:dir...] best-match similarity (level abs) of the functions against reference trees (as speicher.py cmp)
  inv  [--ref LABEL=DIR ...]   token diff per function (reference tokens, equal, deleted, inserted) against V7 (original/unix-v7/usr/sys)
                               and further trees; DIR is the directory that contains sys/ (e.g. .../h6_hippe_eff, .../WEGA/src/uts)
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

# (reference file below usr/sys, reference function, MUTOS file, MUTOS function, group)
ROWS = [
    ("sys/trap.c", "trap", "trap.c", "trap", "trap"),
    ("sys/trap.c", "nosys", "trap.c", "nosys", "trap"),
    ("sys/trap.c", "nullsys", "trap.c", "nullsys", "trap"),
    ("sys/machdep.c", "startup", "machdep.c", "startup", "machdep"),
    ("sys/machdep.c", "clkstart", "machdep.c", "kstub", "machdep"),
    ("sys/machdep.c", "sendsig", "machdep.c", "sendsig", "machdep"),
    ("sys/machdep.c", "sendsig", "machdep.c", "sigret", "machdep"),
    ("sys/sys1.c", "exece", "sys1.c", "exece", "sys1"),
    ("sys/sys1.c", "getxfile", "sys1.c", "getxfile", "sys1"),
    ("sys/sys1.c", "setregs", "sys1.c", "setregs", "sys1"),
    ("sys/sys1.c", "rexit", "sys1.c", "rexit", "sys1"),
    ("sys/sys1.c", "exit", "sys1.c", "exit", "sys1"),
    ("sys/sys1.c", "wait", "sys1.c", "wait", "sys1"),
    ("sys/sys1.c", "fork", "sys1.c", "fork", "sys1"),
    ("sys/sys1.c", "sbreak", "sys1.c", "sbreak", "sys1"),
    ("sys/sig.c", "psig", "sig.c", "psig", "sig"),
    ("sys/sig.c", "issig", "sig.c", "issig", "sig"),
    ("sys/sig.c", "psignal", "sig.c", "psignal", "sig"),
    ("sys/sig.c", "procxmt", "sig.c", "procxmt", "sig"),
    ("sys/sig.c", "ptrace", "sig.c", "ptrace", "sig"),
    ("sys/sig.c", "core", "sig.c", "core", "sig"),
]


def funcmap(path):
    return {f.name: f for f in H.Source(str(path)).funcs}


def absn(f):
    return H.norm_function(f, "abs")


# Classes (rule of thumb, token level abs): MUTOS tokens not in V7 (ins), V7 tokens kept (eq/ref).
#   neu          no V7 counterpart (kstub, sigret) or V7 counterpart is a different function
#   unveraendert ins <= 2 % of the MUTOS tokens and eq >= 95 % of the V7 tokens
#   ersetzt      less than 60 % of the V7 tokens are kept (V7 idea, mostly other text)
#   angepasst    everything else (V7 text with changes)
NEU = ("kstub", "sigret")


def klasse(mn, nref, nmut, eq):
    if mn in NEU:
        return "neu"
    if (nmut - eq) * 50 <= nmut and eq * 100 >= 95 * nref:
        return "unveraendert"
    if eq * 100 < 60 * nref:
        return "ersetzt"
    return "angepasst"


def cmd_inv(a):
    roots = [("v7", REPO / "original/unix-v7/usr/sys")] + [(l, Path(p)) for l, p in (r.split("=", 1) for r in (a.ref or []))]
    cache = {}
    for label, root in roots:
        print("== reference %s (%s)" % (label, root))
        print("%-10s %-8s | ref  equal deleted inserted(MUTOS)  similarity" % ("function", "group"))
        tot = [0, 0, 0, 0]
        classes = {}
        for rf, rn, mf, mn, grp in ROWS:
            rp = root / rf
            if not rp.exists():
                continue
            mfs = cache.setdefault(mf, funcmap(REPO / "kernel/c" / mf))
            rfs = cache.setdefault(str(rp), funcmap(rp))
            if rn not in rfs or mn not in mfs:
                print("%-10s %-8s | not found" % (mn, grp))
                continue
            x, y = absn(rfs[rn]), absn(mfs[mn])
            sm = difflib.SequenceMatcher(None, x, y, autojunk=False)
            eq = sum(t.size for t in sm.get_matching_blocks())
            cl = klasse(mn, len(x), len(y), eq)
            print("%-10s %-8s | %4d %5d %7d %8d   %.2f  %s" % (mn, grp, len(x), eq, len(x) - eq, len(y) - eq, 2.0 * eq / max(1, len(x) + len(y)), cl))
            tot[0] += len(y); tot[1] += eq; tot[2] += len(x) - eq; tot[3] += len(y) - eq
            ct = classes.setdefault(cl, [0, 0, 0]); ct[0] += 1; ct[1] += len(y); ct[2] += len(y) - eq
        for cl, ct in sorted(classes.items()):
            print("class %-14s %2d functions, MUTOS tokens %5d, of them new %4d" % (cl, ct[0], ct[1], ct[2]))
        print("MUTOS tokens %d, equal %d (%.0f %%), inserted %d (%.0f %%)" % (tot[0], tot[1], 100.0 * tot[1] / max(1, tot[0]), tot[3], 100.0 * tot[3] / max(1, tot[0])))


def cmd_cmp(a):
    refs = [H.parse_ref(r, H.DEFAULT_K, H.DEFAULT_W) for r in a.ref]
    cache = {}
    seen = set()
    print("%-9s %5s  %s" % ("function", "tok", "  ".join("%-12s" % r.label for r in refs)))
    for _, _, mf, mn, _ in ROWS:
        if mn in seen:
            continue
        seen.add(mn)
        src = cache.setdefault(mf, H.Source(str(REPO / "kernel/c" / mf)))
        f = {x.name: x for x in src.funcs}.get(mn)
        if not f:
            continue
        cells = []
        for r in refs:
            m = r.best_function(src, f, "abs")
            nm = m.get("ref_name") or "-"
            cells.append("%.2f%s" % (m["sim"], "" if nm == mn else "(" + nm[:6] + ")"))
        print("%-9s %5d  %s" % (mn, len(absn(f)), "  ".join("%-12s" % c for c in cells)))


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("inv"); p.add_argument("--ref", action="append"); p.set_defaults(f=cmd_inv)
    p = sub.add_parser("cmp"); p.add_argument("--ref", action="append", required=True, help="LABEL=dir[:dir...]"); p.set_defaults(f=cmd_cmp)
    a = ap.parse_args(argv)
    a.f(a)


if __name__ == "__main__":
    main()
