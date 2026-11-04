"""Command line of the user-space pipeline (library: uspace.py, doc: doc/userspace/pipeline.md).

  python3 -I tools/userspace/pipeline.py holen   NAME [--platte root --pfad etc/init]
  python3 -I tools/userspace/pipeline.py karte   NAME [--ablegen]          # map + listing + libc names + strings
  python3 -I tools/userspace/pipeline.py bau     NAME [--quelle V=FILE]... [--flags "-O -s"] [--asm]   (guest, minutes)
  python3 -I tools/userspace/pipeline.py vergleich NAME [--ist VARIANTE]   # report against the original
  python3 -I tools/userspace/pipeline.py alles   NAME [--quelle V=FILE]... # holen, karte, bau, vergleich
  python3 -I tools/userspace/pipeline.py --check [NAME]                    # host-side self test (no guest run)

Programs are listed in PROGRAMME (disk, path in the guest, default source, header directory).  The working directory is
userspace/NAME/work (ignored by git); --ablegen copies the small artifacts (map k.txt, NAME.lst, NAME.namen,
NAME.strings) next to the sources.  Exit 77 when the emulator project or a disk is missing.
"""
import argparse
import os
import shutil
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U   # noqa: E402

# name -> (disk, path in the guest, default source relative to the repo, header files relative to the repo).
# The MUTOS /usr/include lacks some V7 headers (utmp.h, setjmp.h ...); they are put next to the source on /mnt, which
# `cc -I/mnt` searches first -- so never list a header here that /usr/include has (it would shadow the MUTOS one).
V7INC = "original/unix-v7/usr/include/"
PROGRAMME = {
    # a directory as source = multi-file program: all *.c (alphabetical = V7 `cc *.o` link order), *.h travel along
    "sh": ("root", "bin/sh", "userspace/sh", [V7INC + "setjmp.h", V7INC + "sys/dir.h"]),
    "init": ("root", "etc/init", "userspace/init/init.c", [V7INC + "utmp.h", V7INC + "setjmp.h"]),
    "login": ("root", "bin/login", "userspace/login/login.c", [V7INC + "utmp.h"]),
    "getty": ("root", "etc/getty", "userspace/getty/getty.c", []),
    "mount": ("root", "etc/mount", "userspace/mount/mount.c", []),
    "umount": ("root", "etc/umount", "userspace/umount/umount.c", []),
    "sync": ("root", "bin/sync", "userspace/sync/sync.c", []),
    "cat": ("root", "bin/cat", "userspace/cat/cat.c", []),
    "stty": ("root", "bin/stty", "userspace/stty/stty.c", []),   # not V7: extended stty, doc/userspace/stty.md
    "date": ("root", "bin/date", "userspace/date/date.c", [V7INC + "sys/timeb.h", V7INC + "utmp.h"]),
    "ls": ("root", "bin/ls", "userspace/ls/ls.c", [V7INC + "sys/param.h", V7INC + "sys/dir.h"]),
}


def pfad(name, *teile):
    return os.path.join(U.REPO, "userspace", name, *teile)


def arbeit_von(name, a):
    return os.path.abspath(a.arbeit) if a.arbeit else pfad(name, "work")


def info(name):
    if name not in PROGRAMME:
        raise SystemExit("unknown program %s (known: %s); add it to PROGRAMME" % (name, ", ".join(PROGRAMME)))
    return PROGRAMME[name]


def cmd_holen(name, a):
    platte, pf, _q, _h = info(name)
    platte, pf = a.platte or platte, a.pfad or pf
    k, raw = U.holen(arbeit_von(name, a), name, platte, pf)
    print("%s: text %d data %d bss %d syms %d entry %d flag %d; image %d B -> %s.raw" %
          (name, k[1], k[2], k[3], k[4], k[5], k[7], len(raw), name))


def laden(name, a):
    ar = arbeit_von(name, a)
    orig = os.path.join(ar, name + ".orig")
    if not os.path.isfile(orig):
        cmd_holen(name, a)
    with open(orig, "rb") as f:
        b = f.read()
    return ar, U.roh_von(b)


def hand_namen(name):
    """Hand-made names (userspace/NAME/namen.txt: `ADDR name` per line, # comments) for the map."""
    p = pfad(name, "namen.txt")
    erg = {}
    if os.path.isfile(p):
        for z in open(p):
            if z.strip() and not z.startswith("#"):
                t = z.split()
                erg[int(t[0], 16)] = t[1]
    return erg


def extra_karte(name):
    """userspace/NAME/karte_extra.txt: map lines (dwc/db/txt/kom ...) added verbatim, e.g. for jump tables."""
    p = pfad(name, "karte_extra.txt")
    return [z.rstrip("\n") for z in open(p) if z.strip() and not z.startswith("#")] if os.path.isfile(p) else []


def cmd_karte(name, a):
    ar, (k, raw) = laden(name, a)
    libc = None if a.ohne_libc else U.libc_archiv(ar)
    an = U.analysieren(ar, name, raw, k, libc, hand_namen(name), extra=extra_karte(name))
    print(an.stat.strip())
    print("libc matches: %d (%d unambiguous, strong)" % (len(an.namen), sum(1 for x in an.namen if "|" not in x[2] and not x[3])))
    print("functions (call targets): %d, strings in the data part: %d" % (len(an.funk), len(an.texte)))
    if a.ablegen:
        for src, dst in ((name + ".k", "k.txt"), (name + ".lst", name + ".lst"), (name + ".namen", name + ".namen"),
                         (name + ".strings", name + ".strings")):
            p = os.path.join(ar, src)
            if os.path.isfile(p):
                shutil.copyfile(p, pfad(name, dst))
        print("filed in userspace/%s/" % name)
    return an


def quelle_lesen(p):
    """FILE -> text; DIRECTORY -> {file.c: text} in alphabetical order; the *.h of the directory go to `koepfe` (second value)."""
    p = os.path.join(U.REPO, p) if not os.path.isabs(p) else p
    if not os.path.isdir(p):
        return open(p, encoding="latin-1").read(), {}
    dat, koepfe = {}, {}
    for f in sorted(os.listdir(p)):
        if f.endswith(".c"):
            dat[f] = open(os.path.join(p, f), encoding="latin-1").read()
        elif f.endswith(".h"):
            koepfe[f] = open(os.path.join(p, f), "rb").read()
    return dat, koepfe


def quellen_lesen(name, a):
    """--quelle V=FILE (repeatable); default: the program's own source as variant `neu`."""
    _pl, _pf, q, h = info(name)
    v = {}
    koepfe = {}
    for s in (a.quelle or []):
        if "=" in s:
            n, p = s.split("=", 1)
        else:
            n, p = os.path.splitext(os.path.basename(s))[0], s
        v[n], k = quelle_lesen(p)
        koepfe.update(k)
    if not v:
        v["neu"], k = quelle_lesen(q)
        koepfe.update(k)
    for hd in list(h) + (a.kopf or []):
        d = os.path.join(U.REPO, hd) if not os.path.isabs(hd) else hd
        koepfe[os.path.basename(d)] = open(d, "rb").read()
    return v, koepfe


def cmd_bau(name, a):
    ar = arbeit_von(name, a)
    v, koepfe = quellen_lesen(name, a)
    erg = U.gast_bauen(os.path.join(ar, "bau"), v, koepfe, flags=a.flags, asm=a.asm or a.c2emu, parallel=a.parallel)
    os.makedirs(os.path.join(ar, "bau"), exist_ok=True)
    if a.c2emu:     # second round: assemble the rewritten .s (original-c2 model) and link it
        zwei = {}
        for n, r in erg.items():
            if r["s"]:
                zwei[n + "_c2_s"], cnt = U.c2_emu_s(r["s"])
                print("%s: c2 model rewrote %s" % (n, cnt))
        erg2 = U.gast_bauen(os.path.join(ar, "bau"), zwei, koepfe, parallel=a.parallel)
        erg.update(erg2)
    for n, r in erg.items():
        if r["bin"]:
            with open(os.path.join(ar, "bau", n + ".bin"), "wb") as f:
                f.write(r["bin"])
        with open(os.path.join(ar, "bau", n + ".err"), "w") as f:
            f.write(r["err"])
        if isinstance(r["s"], dict):
            os.makedirs(os.path.join(ar, "bau", n + "_s"), exist_ok=True)
            for fn, t in r["s"].items():
                with open(os.path.join(ar, "bau", n + "_s", fn), "w") as f:
                    f.write(t)
        elif r["s"]:
            with open(os.path.join(ar, "bau", n + ".s"), "w") as f:
                f.write(r["s"])
        if r["err"].strip():
            print("%s: cc messages:\n%s" % (n, r["err"].strip()))
    return erg


def cmd_vergleich(name, a):
    ar, (ko, raw) = laden(name, a)
    libc = U.libc_archiv(ar)
    soll = U.analysieren(ar, name + "_v", raw, ko, libc, None, log=lambda *x: None,
                       extra=extra_karte(name))   # no hand names: labels must match the built side
    namen = {x[0]: x[2] for x in soll.namen if "|" not in x[2]}
    namen.update(hand_namen(name))
    bd = os.path.join(ar, "bau")
    ist = [a.ist] if a.ist else sorted(f[:-4] for f in os.listdir(bd) if f.endswith(".bin"))
    ergebnis = {}
    for v in ist:
        b = open(os.path.join(bd, v + ".bin"), "rb").read()
        ki, ri = U.roh_von(b)
        ai = U.analysieren(os.path.join(bd, v + "_a"), v, ri, ki, libc, None, log=lambda *x: None)
        zeilen, z = U.vergleichen(raw, ko, ri, ki, soll.lst, ai.lst, soll.funk, namen,
                                  U.eigen_ende(soll.namen), U.eigen_ende(ai.namen), c2=not a.ohne_c2,
                                  zeiger_soll=soll.zeiger, zeiger_ist=ai.zeiger)
        txt = "\n".join(zeilen) + "\n"
        with open(os.path.join(bd, v + ".bericht"), "w") as f:
            f.write(txt)
        print("== %s\n%s" % (v, txt if a.voll else "\n".join(zeilen[:8])))
        ergebnis[v] = z
    return ergebnis


def check(name):
    """Host-side self test: fetch, map, names; asserts the invariants measured for the program.  0 ok, 77 no emulator."""
    try:
        U.pruefe()
    except U.Fehlt as e:
        print("skipped: %s missing" % e)
        return U.SKIP
    import tempfile
    ar = tempfile.mkdtemp(prefix="uspace_check_")
    platte, pf, _q, _h = info(name)
    k, raw = U.holen(ar, name, platte, pf)
    libc = U.libc_archiv(ar)
    an = U.analysieren(ar, name, raw, k, libc, hand_namen(name), log=lambda *x: None)
    fehler = []
    if len(raw) != k[1] + k[2]:
        fehler.append("image length != text+data")
    if "ungueltig 0" not in an.stat or "Ueberlappung 0" not in an.stat:
        fehler.append("map has invalid entries or overlaps:\n" + an.stat)
    starke = {x[2] for x in an.namen if not x[3]}
    for erwartet in ERWARTET.get(name, ()):
        if not any(erwartet in n.split("|") for n in starke):
            fehler.append("libc function %s not found by signature" % erwartet)
    print("%s: text %d data %d, %d functions, %d libc names%s" % (name, k[1], k[2], len(an.funk), len(an.namen),
                                                                   "; OK" if not fehler else ""))
    for f in fehler:
        print("FAIL:", f)
    shutil.rmtree(ar, ignore_errors=True)
    return 1 if fehler else 0


# libc functions that must be found (measured, doc/userspace/init.md)
ERWARTET = {"init": ("signal", "setjmp", "open", "close", "kill", "wait", "alarm", "fork", "execl", "creat", "csv")}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", nargs="?", choices=["holen", "karte", "bau", "vergleich", "alles"])
    ap.add_argument("name", nargs="?", default="init")
    ap.add_argument("--check", nargs="?", const="init", metavar="NAME", help="host-side self test (default init); exit 77 without the emulator")
    ap.add_argument("--arbeit")
    ap.add_argument("--platte")
    ap.add_argument("--pfad")
    ap.add_argument("--ablegen", action="store_true")
    ap.add_argument("--ohne-libc", action="store_true")
    ap.add_argument("--quelle", action="append", help="VARIANTE=DATEI (repeatable)")
    ap.add_argument("--kopf", action="append", help="extra header FILE (put next to the source)")
    ap.add_argument("--flags", default="-O -s")
    ap.add_argument("--asm", action="store_true", help="also cc -S (assembler source of the variant)")
    ap.add_argument("--c2emu", action="store_true", help="also assemble the .s rewritten to the original c2's form (R1-R3)")
    ap.add_argument("--parallel", type=int, default=4)
    ap.add_argument("--ist", help="variant to compare")
    ap.add_argument("--ohne-c2", action="store_true", help="compare without the c2 model (c2_kanon)")
    ap.add_argument("--voll", action="store_true", help="print the full report")
    a = ap.parse_args(argv)
    try:
        if a.check or a.cmd is None:
            return check(a.check or a.name)
        if a.cmd == "holen":
            cmd_holen(a.name, a)
        elif a.cmd == "karte":
            cmd_karte(a.name, a)
        elif a.cmd == "bau":
            cmd_bau(a.name, a)
        elif a.cmd == "vergleich":
            erg = cmd_vergleich(a.name, a)
            return 0 if all(z["gleich"] for z in erg.values()) else 1
        elif a.cmd == "alles":
            cmd_holen(a.name, a)
            cmd_karte(a.name, a)
            cmd_bau(a.name, a)
            erg = cmd_vergleich(a.name, a)
            return 0 if all(z["gleich"] for z in erg.values()) else 1
    except U.Fehlt as e:
        print("skipped: %s missing" % e, file=sys.stderr)
        return U.SKIP
    return 0


if __name__ == "__main__":
    sys.exit(main())
