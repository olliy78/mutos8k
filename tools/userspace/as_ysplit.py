"""Split the generated userspace/as/as_y.c into three modules for the guest `cc -O` (plan 52, W7d).

  python3 -I tools/userspace/as_ysplit.py [--check]

Why: the guest c2 (-O pass) hangs (no result after 5e9 cycles) as soon as one module carries about 14 KB of
initialised table data (measured W7d: all 8 yacc tables = 14.5 KB c5 -> hang; the five smaller tables 9.5 KB,
yyact alone 5.3 KB and the parser body 8 KB each pass in 40 s).  The split keeps the data order of the
single file (as_y1 yyexca..yypgo, as_y2 yyr1..yydef, as_y3 yydebug.. + code), so the link order
as_y1 as_y2 as_y3 gives the same layout.  as_y.c stays the unchanged yacc output (not compiled).
--check: the three files are what this script writes now (exit 0), or exit 1.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DIR = os.path.join(os.path.dirname(os.path.dirname(HERE)), "userspace", "as")
NAMES = ("yyexca", "yyact", "yypact", "yypgo", "yyr1", "yyr2", "yychk", "yydef")


def split(src):
    L = src.split("\n")
    i_tab = next(i for i, l in enumerate(L) if l.startswith("short yyexca[]"))
    i_r1 = next(i for i, l in enumerate(L) if l.startswith("short yyr1[]"))
    i_body = next(i for i, l in enumerate(L) if l.startswith("# define YYFLAG"))
    head = L[:i_tab]          # typedef, token defines, yylval/yyval, YYERRCODE
    iv = next(i for i, l in enumerate(head) if l.startswith("YYSTYPE yylval, yyval;"))
    ext = head[:iv] + ["extern YYSTYPE yylval, yyval;"] + head[iv + 1:]
    defs = [l for l in L[i_tab:i_r1] if l.startswith("# define YYNPROD") or l.startswith("# define YYLAST")]
    externs = ["extern short %s[];" % n for n in NAMES]
    why = ("split of as_y.c by tools/userspace/as_ysplit.py: the guest c2 hangs on 14 KB of table data in one module")
    out = {}
    out["as_y1.c"] = ["/* as_y1.c: part 1 of as_y.c (yyexca..yypgo); " + why + " */"] + head + L[i_tab:i_r1]
    out["as_y2.c"] = ["/* as_y2.c: part 2 of as_y.c (yyr1..yydef), see as_y1.c */"] + ext + L[i_r1:i_body]
    out["as_y3.c"] = ["/* as_y3.c: part 3 of as_y.c (yydebug, yyparse), see as_y1.c */"] + ext + defs + externs + L[i_body:]
    return {k: "\n".join(v) for k, v in out.items()}


def main():
    src = open(os.path.join(DIR, "as_y.c"), encoding="latin-1").read()
    out = split(src)
    if "--check" in sys.argv:
        bad = [k for k, v in out.items() if not os.path.exists(os.path.join(DIR, k))
               or open(os.path.join(DIR, k), encoding="latin-1").read() != v]
        print("as_ysplit: %s" % ("OK (3 files current)" if not bad else "OUT OF DATE: " + " ".join(bad)))
        return 1 if bad else 0
    for k, v in out.items():
        open(os.path.join(DIR, k), "w", encoding="latin-1").write(v)
        print(k, len(v))
    return 0


if __name__ == "__main__":
    sys.exit(main())
