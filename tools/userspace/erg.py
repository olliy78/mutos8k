"""Framework for the V7 additions (plan 45 section 7, doc/userspace/erg_e0.md).

  python3 -I tools/userspace/erg.py bau   NAME [--parallel N]   # guest build cc -O -s -> work/bau/NAME.bin
  python3 -I tools/userspace/erg.py test  NAME                  # (build if needed), run test/befehle.sh in the guest, compare
  python3 -I tools/userspace/erg.py alles NAME...               # bau + test per program, result line B/T/N

Program directory: userspace/ergaenzung/NAME/ with NAME.c (or several *.c / *.h), erg.json
({"header": [...relative to original/unix-v7/usr/include], "dateien": [extra files of the folder without .c/.h suffix, optional], "flags": "-O -s", "quelle": "..."}) and test/
(befehle.sh, erwartet.txt, optional eingabe/*, herkunft.txt).  There is no original to compare with: the proof is
"builds" plus "output equals the expectation".  Exit: 0 ok, 1 difference / no build, 77 emulator or disk missing.

The guest has only the root and usr disks (no cmd disk): the test script may use sh, cat, ls, date, stty, sync
and the program under test (it is on /mnt, PATH=/mnt:/bin:/usr/bin).  Input files (test/eingabe/*) are copied to
/tmp (the cwd of the script) before the run.  Only the standard output of the script is compared; its standard
error is kept in work/test/NAME.stderr.
"""
import argparse
import difflib
import json
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U   # noqa: E402
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))

V7INC = "original/unix-v7/usr/include/"
ERGDIR = os.path.join(U.REPO, "userspace", "ergaenzung")
FRIST = 3_000_000_000     # emulator cycles per guest command


def pfad(name, *teile):
    return os.path.join(ERGDIR, name, *teile)


def konfig(name):
    if not os.path.isdir(pfad(name)):
        raise SystemExit("no program directory userspace/ergaenzung/%s" % name)
    p = pfad(name, "erg.json")
    k = json.load(open(p)) if os.path.isfile(p) else {}
    k.setdefault("header", [])
    k.setdefault("flags", "-O -s")
    return k


def quellen(name):
    """(text of NAME.c | {file.c: text} alphabetical = link order, headers {name: bytes})."""
    d = pfad(name)
    cs = sorted(f for f in os.listdir(d) if f.endswith(".c"))
    if not cs:
        raise SystemExit("%s: no .c file" % name)
    koepfe = {f: open(os.path.join(d, f), "rb").read() for f in os.listdir(d) if f.endswith(".h")}
    for f in konfig(name).get("dateien", []):   # extra files without .c/.h suffix (V7 make: "defs"), next to the sources
        koepfe[f] = open(os.path.join(d, f), "rb").read()
    for h in konfig(name)["header"]:
        koepfe[os.path.basename(h)] = open(os.path.join(U.REPO, V7INC + h), "rb").read()
    if cs == [name + ".c"]:
        return open(os.path.join(d, cs[0]), encoding="latin-1").read(), koepfe
    return {f: open(os.path.join(d, f), encoding="latin-1").read() for f in cs}, koepfe


def bau(name, parallel=4):
    """Guest build; writes work/bau/NAME.bin and NAME.err.  Returns (ok, messages)."""
    if len(name) > 9:
        raise SystemExit("program name %r too long (at most 9 characters: NAME.err2 must fit 14)" % name)
    q, koepfe = quellen(name)
    ar = pfad(name, "work")
    erg = U.gast_bauen(os.path.join(ar, "bau"), {name: q}, koepfe, flags=konfig(name)["flags"], parallel=parallel)
    r = erg[name]
    os.makedirs(os.path.join(ar, "bau"), exist_ok=True)
    pb = os.path.join(ar, "bau", name + ".bin")
    if os.path.exists(pb):
        os.remove(pb)
    if r["bin"]:
        with open(pb, "wb") as f:
            f.write(r["bin"])
    with open(os.path.join(ar, "bau", name + ".err"), "w") as f:
        f.write(r["err"])
    if r["err"].strip():
        print("%s: cc messages:\n%s" % (name, r["err"].strip()))
    return bool(r["bin"]), r["err"]


def test(name):
    """Run test/befehle.sh in the guest.  0 equal, 1 difference, 2 no build."""
    import gast_as
    td = pfad(name, "test")
    for f in ("befehle.sh", "erwartet.txt"):
        if not os.path.isfile(os.path.join(td, f)):
            raise SystemExit("%s: test/%s missing" % (name, f))
    pb = pfad(name, "work", "bau", name + ".bin")
    if not os.path.isfile(pb):
        ok, _ = bau(name)
        if not ok:
            return 2
    q = {name: open(pb, "rb").read(), "befehle.sh": open(os.path.join(td, "befehle.sh"), "rb").read()}
    ein = os.path.join(td, "eingabe")
    eingaben = sorted(os.listdir(ein)) if os.path.isdir(ein) else []
    for f in eingaben:
        q["e_" + f[:12]] = open(os.path.join(ein, f), "rb").read()   # guest names are cut at 14 characters
    befehle = ["cat /mnt/e_%s >/tmp/%s;cd /mnt" % (f[:12], f) for f in eingaben]
    befehle.append("cd /tmp;PATH=/mnt:/bin:/usr/bin sh /mnt/befehle.sh >/tmp/aus.txt 2>/tmp/aus.err;cd /mnt")
    ar = pfad(name, "work", "test")
    aus = {}
    r = gast_as.gast_befehle(ar, q, befehle, ["aus.txt", "aus.err"], frist=FRIST, ausgabe=aus, ausfuehrbar=(name,))
    ist = (r.get("aus.txt") or b"").decode("latin-1")
    with open(os.path.join(ar, name + ".ist"), "w") as f:
        f.write(ist)
    with open(os.path.join(ar, name + ".stderr"), "w") as f:
        f.write((r.get("aus.err") or b"").decode("latin-1"))
    soll = open(os.path.join(td, "erwartet.txt"), encoding="latin-1").read()
    ist = ist.replace("\r", "")     # a tty line discipline could add CR
    if ist == soll:
        print("%s: test equal (%d s wall clock)" % (name, aus.get("dauer", 0)))
        return 0
    print("".join(difflib.unified_diff(soll.splitlines(True), ist.splitlines(True), "erwartet.txt", "gast")))
    print("%s: test DIFFERS (see %s)" % (name, os.path.join(ar, name + ".ist")))
    return 1


def alles(namen, parallel=4):
    zeilen, rc = [], 0
    for n in namen:
        ok, _err = bau(n, parallel)
        if not ok:
            zeilen.append("%s: N (build failed)" % n)
            rc = 1
            continue
        t = test(n)
        zeilen.append("%s: %s" % (n, "B" if t == 0 else "T (test differs)"))
        rc = rc or t
    print("\n".join(zeilen))
    return rc


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["bau", "test", "alles"])
    ap.add_argument("namen", nargs="+")
    ap.add_argument("--parallel", type=int, default=4)
    a = ap.parse_args(argv)
    try:
        U.pruefe()
        if a.cmd == "bau":
            return 0 if bau(a.namen[0], a.parallel)[0] else 1
        if a.cmd == "test":
            return test(a.namen[0])
        return alles(a.namen, a.parallel)
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP


if __name__ == "__main__":
    sys.exit(main())
