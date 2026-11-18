#!/usr/bin/env python3
"""W10 step 1: group the c2 rules by co-occurrence over programs (host only, reads userspace/c2/gegenprobe.tsv).

Output: rule groups with identical program sets, program groups with identical active rule set, and the matrix
program x rule (A = active, S = switched off but pattern present, . = absent) for the general rules R1-R45.
Doc: doc/userspace/wk_w10a.md"""
import csv
import os
import re
import sys
from collections import defaultdict

TSV = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "userspace", "c2", "gegenprobe.tsv")


def lesen(pfad=TSV):
    """-> {program: {rule: (state, sites)}}, summed over the modules of a program."""
    m = defaultdict(dict)
    with open(pfad, newline="") as f:
        for z in csv.DictReader(f, delimiter="\t"):
            for e in (z["rule:state:sites"] or "").split(","):
                if not e:
                    continue
                r, st, n = e.split(":")
                old = m[z["program"]].get(r, (st, 0))
                m[z["program"]][r] = (st, old[1] + int(n))
    return m


def rnum(r):
    return int(re.sub(r"\D", "", r))


def main():
    m = lesen()
    progs = sorted(m)
    regeln = sorted({r for p in m.values() for r in p}, key=rnum)
    print("programs %d, rules %d" % (len(progs), len(regeln)))
    print("\nrule groups with identical ACTIVE program set (size>1):")
    g = defaultdict(list)
    for r in regeln:
        g[frozenset(p for p in progs if m[p].get(r, ("", 0))[0] == "active")].append(r)
    for ps, rs in sorted(g.items(), key=lambda x: -len(x[0])):
        if ps and len(rs) > 1:
            print("  %s -> %s" % (" ".join(rs), " ".join(sorted(ps))))
    print("\nprogram groups with identical active rule set:")
    h = defaultdict(list)
    for p in progs:
        h[frozenset(r for r in regeln if m[p].get(r, ("", 0))[0] == "active")].append(p)
    for rs, ps in sorted(h.items(), key=lambda x: -len(x[1])):
        print("  %s : %s" % (" ".join(ps), " ".join(sorted(rs, key=rnum)) or "(none)"))
    zeitprobe(m, progs, regeln)
    print("\nmatrix (A active, S switched off, . absent), general rules R1-R45:")
    allg = [r for r in regeln if rnum(r) <= 45]
    print("%-8s %s" % ("", " ".join("%3s" % r[1:] for r in allg)))
    for p in progs:
        print("%-8s %s" % (p, " ".join("%3s" % {"active": "A", "aus": "S"}.get(m[p].get(r, ("", 0))[0], ".") for r in allg)))


def zeitprobe(m, progs, regeln):
    """Linear-time hypothesis (*Annahme*): rule r is active iff the program was built before time t_r, i.e. the c2 stands form a chain.
    A pair (r, s) contradicts it when one program has r active / s switched off and another has r off / s active."""
    gen = [r for r in regeln if any(v[0] == "aus" for p in progs for rr, v in m[p].items() if rr == r)]
    gen += [r for r in regeln if r not in gen and sum(1 for p in progs if m[p].get(r, ("", 0))[0] == "active") > 1]
    gen = sorted(set(gen), key=rnum)
    print("\nlinear-time test over the %d general rules (rules with an off-state or active in >1 program):" % len(gen))
    st = lambda p, r: m[p].get(r, ("", 0))[0]
    bad = []
    for i, r in enumerate(gen):
        for s in gen[i + 1:]:
            a = [p for p in progs if st(p, r) == "active" and st(p, s) == "aus"]
            b = [p for p in progs if st(p, r) == "aus" and st(p, s) == "active"]
            if a and b:
                bad.append((r, s, a, b))
    for r, s, a, b in bad:
        print("  %s/%s: %s=on,%s=off in %s; reverse in %s" % (r, s, r, s, ",".join(a), ",".join(b)))
    print("  %d contradicting pairs" % len(bad))


if __name__ == "__main__":
    sys.exit(main())
