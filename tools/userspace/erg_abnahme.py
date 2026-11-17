"""Acceptance of the V7 supplement disks v7erg1 / v7erg2 in the guest (plan 45 E6, doc/userspace/erg_e6.md).

  python3 -I tools/userspace/erg_abnahme.py [1|2] [--hfe IMAGE] [--neu]

Mounts the finished disk (default disks/gebaut/a5120_mutos8000_v7erg<N>_mfm.hfe; a COPY) at /v7 and runs
userspace/ergaenzung_abnahme/v7erg<N>/befehle.sh there (cwd /tmp, PATH=/v7/bin:/bin:/usr/bin): `ls` of /v7/bin and /v7/lib, one short
call per program, for v7erg2 also the yacc and lex chain through /v7/lib.  stdout is compared with erwartet.txt (--neu writes it
from the guest run for review).  `ls -l /v7/bin /v7/lib` is stored in work/ls_l.txt (not compared: sizes change with every rebuild).
Exit 0 equal, 1 different, 77 emulator or disk missing.
"""
import argparse
import difflib
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U   # noqa: E402
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))

ABN = os.path.join(U.REPO, "userspace", "ergaenzung_abnahme")


def lauf(n, hfe, neu):
    import gast_as
    d = os.path.join(ABN, "v7erg" + n)
    hfe = hfe or os.path.join(U.REPO, "disks", "gebaut", "a5120_mutos8000_v7erg%s_mfm.hfe" % n)
    if not os.path.isfile(hfe):
        raise U.Fehlt(hfe)
    skript = open(os.path.join(d, "befehle.sh"), "rb").read()
    befehle = ["cd /tmp;ls -l /v7/bin /v7/lib >/tmp/ls_l.txt 2>&1;cd /v7",
               "cd /tmp;PATH=/v7/bin:/bin:/usr/bin sh /v7/abnahme.sh >/tmp/aus.txt 2>/tmp/aus.err;cd /v7"]
    arbeit = os.path.join(d, "work")
    aus = {}
    r = gast_as.gast_befehle(arbeit, {"abnahme.sh": skript}, befehle, ["aus.txt", "aus.err", "ls_l.txt"],
                             frist=3_000_000_000, ausgabe=aus, mnt="/v7", quelle_hfe=hfe)
    ist = (r.get("aus.txt") or b"").decode("latin-1").replace("\r", "")
    for name, k in (("ist.txt", "aus.txt"), ("stderr.txt", "aus.err"), ("ls_l.txt", "ls_l.txt")):
        with open(os.path.join(arbeit, name), "w") as f:
            f.write((r.get(k) or b"").decode("latin-1").replace("\r", ""))
    pe = os.path.join(d, "erwartet.txt")
    if neu:
        with open(pe, "w") as f:
            f.write(ist)
        print("v7erg%s: erwartet.txt written (review!)" % n)
        return 0
    soll = open(pe, encoding="latin-1").read()
    if soll == ist:
        print("v7erg%s: acceptance equal (%d s wall clock)" % (n, aus.get("dauer", 0)))
        return 0
    print("".join(difflib.unified_diff(soll.splitlines(True), ist.splitlines(True), "erwartet.txt", "gast")))
    print("v7erg%s: acceptance DIFFERS (see %s)" % (n, os.path.join(arbeit, "ist.txt")))
    return 1


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("disks", nargs="*", choices=["1", "2"], help="default: both")
    ap.add_argument("--hfe")
    ap.add_argument("--neu", action="store_true")
    a = ap.parse_args(argv)
    try:
        U.pruefe()
        rc = 0
        for n in a.disks or ["1", "2"]:
            rc = lauf(n, a.hfe, a.neu) or rc
        return rc
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP


if __name__ == "__main__":
    sys.exit(main())
