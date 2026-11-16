"""Generate NAME.c from NAME.y with the MUTOS V7-yacc in the guest (plan 45, E3c: expr, egrep, bc).

  K1520EMU=... python3 -I tools/userspace/erg_yacc.py NAME [NAME...]

Needs userspace/ergaenzung/yacc/work/bau/yacc.bin (python3 -I tools/userspace/erg.py bau yacc).
For every NAME the file userspace/ergaenzung/NAME/NAME.y (V7 text, unchanged) is run through yacc in one guest session
(cd /tmp; cat /mnt/yaccpar >yaccpar; yacc NAME.y; y.tab.c -> NAME.c); NAME.c is stored behind a header comment.
Same method as tools/userspace/vmake_gram.py (doc/userspace/erg_e3b.md), which handles gram.y of vmake.
"""
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))
import uspace as U   # noqa: E402

ERG = os.path.join(U.REPO, "userspace", "ergaenzung")
KOPF = ("/* %s.c: GENERATED from %s.y (V7 text, unchanged) by the MUTOS V7-yacc (userspace/ergaenzung/yacc, size class SMALL)\n"
        "   in the emulator guest: cd /tmp; yacc %s.y; y.tab.c -> %s.c.  Regenerate: tools/userspace/erg_yacc.py %s.\n"
        "   Not V7 source text, not edited by hand. */\n")


def main(namen):
    try:
        U.pruefe()
        import gast_as
        yb = os.path.join(ERG, "yacc", "work", "bau", "yacc.bin")
        if not os.path.isfile(yb):
            raise SystemExit("yacc.bin missing: python3 -I tools/userspace/erg.py bau yacc")
        q = {"yacc": open(yb, "rb").read(), "yaccpar": open(os.path.join(ERG, "yacc", "yaccpar"), "rb").read()}
        befehle = ["cat /mnt/yaccpar >/tmp/yaccpar;cd /mnt"]
        rueck = []
        for n in namen:
            q[n + ".y"] = open(os.path.join(ERG, n, n + ".y"), "rb").read()
            befehle.append("cat /mnt/%s.y >/tmp/%s.y;cd /tmp;PATH=/mnt:/bin:/usr/bin yacc %s.y >/tmp/%s.yerr 2>&1;cat y.tab.c >/tmp/%s.c;cd /mnt"
                           % (n, n, n, n, n))
            rueck += [n + ".c", n + ".yerr"]
        r = gast_as.gast_befehle(os.path.join(ERG, namen[0], "work", "yacc"), q, befehle, rueck,
                                 frist=3_000_000_000, ausgabe={}, ausfuehrbar=("yacc",))
        rc = 0
        for n in namen:
            err = (r.get(n + ".yerr") or b"").decode("latin-1").replace("\r", "")
            print("%s: yacc messages: %r" % (n, err))
            if not r.get(n + ".c"):
                print("%s: no y.tab.c" % n)
                rc = 1
                continue
            txt = r[n + ".c"].decode("latin-1").replace("\r", "")
            with open(os.path.join(ERG, n, n + ".c"), "w", encoding="latin-1") as f:
                f.write(KOPF % (n, n, n, n, n) + txt)
            print("%s.c: %d bytes" % (n, len(txt)))
        return rc
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
