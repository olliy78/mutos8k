"""Regenerate userspace/ergaenzung/vmake/gram.c from gram.y with the MUTOS V7-yacc in the guest (plan 45, E3b).

  K1520EMU=... python3 -I tools/userspace/vmake_gram.py

Needs userspace/ergaenzung/yacc/work/bau/yacc.bin (python3 -I tools/userspace/erg.py bau yacc).
Guest: cd /tmp; cat /mnt/yaccpar >yaccpar; yacc gram.y (yaccpar must be in the cwd, see doc/userspace/erg_e3a.md);
the y.tab.c that comes back is stored as gram.c behind a header comment.
"""
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))
import uspace as U   # noqa: E402

ERG = os.path.join(U.REPO, "userspace", "ergaenzung")
KOPF = ("/* gram.c: GENERATED from gram.y (V7 make) by the MUTOS V7-yacc (userspace/ergaenzung/yacc, size class SMALL)\n"
        "   in the emulator guest: cd /tmp; yacc gram.y; y.tab.c -> gram.c.  Regenerate: tools/userspace/vmake_gram.py.\n"
        "   Not V7 source text, not edited by hand. */\n")


def main():
    try:
        U.pruefe()
        import gast_as
        yb = os.path.join(ERG, "yacc", "work", "bau", "yacc.bin")
        if not os.path.isfile(yb):
            raise SystemExit("yacc.bin missing: python3 -I tools/userspace/erg.py bau yacc")
        q = {"yacc": open(yb, "rb").read(),
             "yaccpar": open(os.path.join(ERG, "yacc", "yaccpar"), "rb").read(),
             "gram.y": open(os.path.join(ERG, "vmake", "gram.y"), "rb").read(),
             "defs": open(os.path.join(ERG, "vmake", "defs"), "rb").read()}
        befehle = ["cat /mnt/yaccpar >/tmp/yaccpar;cat /mnt/gram.y >/tmp/gram.y;cd /tmp;PATH=/mnt:/bin:/usr/bin yacc gram.y >/tmp/yacc.err 2>&1;cd /mnt"]
        r = gast_as.gast_befehle(os.path.join(ERG, "vmake", "work", "gram"), q, befehle, ["y.tab.c", "yacc.err"],
                                 frist=3_000_000_000, ausgabe={}, ausfuehrbar=("yacc",))
        err = (r.get("yacc.err") or b"").decode("latin-1")
        print("yacc messages: %r" % err)
        if not r.get("y.tab.c"):
            print("no y.tab.c")
            return 1
        txt = r["y.tab.c"].decode("latin-1").replace("\r", "")
        with open(os.path.join(ERG, "vmake", "gram.c"), "w", encoding="latin-1") as f:
            f.write(KOPF + txt)
        print("gram.c: %d bytes" % len(txt))
        return 0
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP


if __name__ == "__main__":
    sys.exit(main())
