"""Recover the yacc grammar of /usr/bin/as from its parser tables (plan 52, W7b).

  python3 -I tools/userspace/as_grammatik.py [--y]       list rules (default) / write userspace/as/as.y

Reads userspace/as/work/as.raw (python3 -I tools/userspace/pipeline.py holen as), decodes yyexca, yyact,
yypact, yypgo, yyr1, yyr2, yychk, yydef (addresses from doc/userspace/wk_w7a.md) and rebuilds the
right-hand sides: the accessing symbol of every state is yychk[state], so a rule of length L that is
reduced in state s has as RHS the yychk values of any L-state path ending in s.
"""
import os
import struct
import sys
from collections import defaultdict

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW = os.path.join(REPO, "userspace", "as", "work", "as.raw")

TAB = dict(yyexca=(0x564E, 14), yyact=(0x566A, 737), yypact=(0x5C2C, 268), yypgo=(0x5E44, 77),
           yyr1=(0x5EDE, 172), yyr2=(0x6036, 172), yychk=(0x618E, 268), yydef=(0x63A6, 268))
KEYTAB = (0x706E, 0x7102)     # {name ptr, token}, 4 bytes each
CONDTAB = (0x7102, 0x72AA)    # {name ptr, token, value}, 6 bytes each


def words(raw, adr, n):
    return list(struct.unpack(">%dh" % n, raw[adr:adr + 2 * n]))


def cstr(raw, p):
    e = raw.index(0, p)
    return raw[p:e].decode("latin-1")


def load():
    raw = open(RAW, "rb").read()
    t = {k: words(raw, a, n) for k, (a, n) in TAB.items()}
    toknam = {}
    for a in range(KEYTAB[0], KEYTAB[1], 4):
        p, tok = struct.unpack(">Hh", raw[a:a + 4])
        toknam.setdefault(tok, []).append(cstr(raw, p))
    for a in range(CONDTAB[0], CONDTAB[1], 6):
        p, tok, _v = struct.unpack(">Hhh", raw[a:a + 6])
        toknam.setdefault(tok, []).append(cstr(raw, p))
    return t, toknam


def reductions(t):
    """red[state] = set of rules that state can reduce (yydef default and the yyexca exceptions)."""
    red = defaultdict(set)
    for s, d in enumerate(t["yydef"]):
        if d > 0:
            red[s].add(d)
    ex, i = t["yyexca"], 0
    while i < len(ex):             # -1, state, (token, rule)*, -2, rule
        st = ex[i + 1]
        i += 2
        while ex[i] >= 0:
            if ex[i + 1] > 0:
                red[st].add(ex[i + 1])
            i += 2
        if ex[i + 1] > 0:
            red[st].add(ex[i + 1])
        i += 2
    return red


def rules(t, extra=()):
    """Fixpoint over valid transitions: start with the shifts, add a goto (p, lhs) only when p is
    the state L steps below a state that reduces the rule (L = yyr2).  Gives exact RHS symbol sets."""
    act, pact, pgo, chk, r1, r2 = t["yyact"], t["yypact"], t["yypgo"], t["yychk"], t["yyr1"], t["yyr2"]
    last, n = len(act), len(pact)
    red = reductions(t)
    pred = defaultdict(set)            # pred[q] = states p with a valid transition p -> q
    for s in range(n):
        if pact[s] > -1000:
            for tok in range(0, 600):
                j = pact[s] + tok
                if 0 <= j < last and chk[act[j]] == tok:
                    pred[act[j]].add(s)

    for p, q in extra:             # edges that no reduction can prove (rules never reduced)
        pred[q].add(p)

    def goto(p, g):
        j = pgo[g] + p + 1
        if j < last and chk[act[j]] == -g:
            return act[j]
        return act[pgo[g]]

    def back(s, k):
        lvl = {s}
        for _ in range(k):
            lvl = {p for q in lvl for p in pred[q]}
        return lvl

    changed = True
    while changed:
        changed = False
        for s, rs in red.items():
            for r in rs:
                for p in back(s, r2[r]):
                    q = goto(p, r1[r])
                    if p not in pred[q]:
                        pred[q].add(p)
                        changed = True
    out, amb = {}, []
    for r in range(1, len(r1)):
        syms = None
        for s, rs in red.items():
            if r in rs:
                cur, lvl = [], {s}
                for _ in range(r2[r]):
                    cur.append({chk[x] for x in lvl})
                    lvl = {p for q in lvl for p in pred[q]}
                cur.reverse()
                syms = cur if syms is None else [a | b for a, b in zip(syms, cur)]
        if syms is None:
            amb.append((r, "never reduced"))
            syms = []
        elif any(len(x) != 1 for x in syms):
            amb.append((r, syms))
        out[r] = tuple(sorted(x)[0] if x else None for x in syms)
    return out, amb


# Rules that no reduction can prove: 122/123 are never reduced in the original tables (yacc resolved a
# reduce/reduce conflict against the empty rule 91), so the walk cannot cross their goto edges.  The two
# edges are fixed by hand: state 240 -nt74-> 252 (rule 118) and state 261 -nt74-> 266 (rule 121).
EXTRA = ((240, 252), (261, 266))
# RHS of the never-reduced rules (Annahme, from yyr1/yyr2: empty / length 2; ELSE nt53 since state 253 has
# accessing symbol ELSE=283 and 261 follows nt53)
FIXED = {122: (), 123: (283, -53)}

# names for tokens that the keyword tables do not give (all names Annahme; groups named by their table role)
TOKNAME = {298: "IDENT", 293: "NUMBER", 306: "CCODE", 307: "CCODE2", 308: "SPV", 309: "CTLREG", 310: "FPFLAG",
           312: "VIFLAG", 313: "SECDIR", 316: "DATADIR", 317: "CODEDIR", 304: "INITKW", 256: "error"}
# nonterminal names (Annahme; invented from the role of the rules), index = yacc number
NTNAME = {}


# Operator precedence (low to high), measured from the original tables: after `expr relop expr`, `expr + expr` ...
# the shifts that remain (see doc/userspace/wk_w7b.md).  Unary + - bind tighter than every binary operator
# (their states reduce on all of them), so rules 162/163 carry %prec LNOT (Annahme: the original may have used
# another dummy token or a placement of its own; only the table effect is measured).
PREC = [[60, 62, 61], [43, 45, 286, 287], [42, 47, 289, 290, 291, 288], [292]]
PRECRULE = {162: 292, 163: 292}


def tokname(x, toknam):
    if x in TOKNAME:
        return TOKNAME[x]
    if 32 < x < 127:
        return "'%c'" % x
    if x in toknam and len(toknam[x]) == 1:
        return toknam[x][0]
    return "TOK%d" % x


def build():
    t, toknam = load()
    out, amb = rules(t, EXTRA)
    for r, v in FIXED.items():
        out[r] = v
    return t, toknam, out, amb


def write_y(path):
    t, toknam, out, amb = build()
    r1 = t["yyr1"]
    nt = lambda g: NTNAME.get(g, "nt%d" % g)
    toks = sorted({c for c in t["yychk"] if c > 0} | {x for x in toknam if x in range(256, 400) or x in (16, 17, 25)})
    toks = [x for x in toks if x != 256 and not (32 < x < 127)]
    L = ["/* as.y: yacc grammar of /usr/bin/as, RECOVERED from the parser tables (tools/userspace/as_grammatik.py).",
         "   Rules in yyr1 order, so rule N here = rule N of the original tables = `case N` of yyparse.  Names of",
         "   nonterminals (ntN = yacc number N) and of unnamed tokens (TOKn) are invented; actions are placeholders. */",
         "%union { int u; }", ""]
    inprec = {x for lv in PREC for x in lv}
    for x in toks:
        if x not in inprec:
            L.append("%%token %s %d" % (tokname(x, toknam), x))
    for lv in PREC:
        L.append("%%left %s" % " ".join(tokname(x, toknam) + ("" if 32 < x < 127 else " %d" % x) for x in lv))
    L.append("")
    L.append("%type <u> " + " ".join(nt(g) for g in range(1, 18)))
    L += ["", "%%"]
    for r in range(1, len(r1)):
        rhs = " ".join(nt(-x) if x < 0 else tokname(x, toknam) for x in out[r])
        L.append("%s : %s { /* action %d */ }\n   ;" % (nt(r1[r]), rhs, r) if False else
                 "%s\t: %s\t{ /* action %d */ }" % (nt(r1[r]), rhs, r))
        if r in PRECRULE:
            L[-1] = L[-1].replace("\t{", " %%prec %s\t{" % tokname(PRECRULE[r], toknam))
        L[-1] += ";"
    L.append("")
    open(path, "w").write("\n".join(L).replace("\\t", "\t").replace("\\n", "\n"))
    return amb


def tables_of_c(path):
    """The eight tables of a yacc-generated y.tab.c / as.c as lists of ints."""
    import re
    txt = open(path, encoding="latin-1").read()
    res = {}
    for name in TAB:
        m = re.search(r"short\s+%s\[\]\s*=\s*\{(.*?)\}\s*;" % name, txt, re.S)
        res[name] = [int(x) for x in re.findall(r"-?\d+", m.group(1))] if m else None
    return res


def compare(path):
    """Compare the generated tables with the original; print per-table result, return True if all equal."""
    t, _ = load()
    g = tables_of_c(path)
    ok = True
    for name in TAB:
        eq = g[name] == t[name]
        ok &= eq
        n = len(g[name] or [])
        diff = "" if eq else " first diff at %s" % next((i for i, (a, b) in enumerate(zip(g[name] or [], t[name])) if a != b), "len")
        print("%-7s original %4d words, generated %4d: %s%s" % (name, len(t[name]), n, "EQUAL" if eq else "DIFFERENT", diff))
    return ok


def main():
    if "--check" in sys.argv:
        sys.exit(0 if compare(sys.argv[sys.argv.index("--check") + 1]) else 1)
    if "--y" in sys.argv:
        amb = write_y(os.path.join(REPO, "userspace", "as", "as.y"))
        print("userspace/as/as.y written; ambiguous rules:", [a[0] for a in amb])
        return
    t, toknam, out, amb = build()
    for r in range(1, len(t["yyr1"])):
        print(r, "nt%d" % t["yyr1"][r], out[r])
    for a in amb:
        print("AMBIG", a, file=sys.stderr)


if __name__ == "__main__":
    main()
