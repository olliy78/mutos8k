"""Plan 47 P1.4/P1.5: build the MUTOS kernel entirely in the guest (no host step between source and kernel).

Sources: kernel/plus (assembler, abs.s, bss.s, mk1, Makefile), kernel/c, kernel/conf, kernel/h, userspace/make.  They go onto two
source disks (the sources do not fit on one, doc/plus/gastbau.md 1); the guest builds with `make -f /mnt/mk1`, the disk is changed
(gastlauf.lauf), `make -f /mnt/Makefile` builds the rest, links `lk` and cuts the kernel file `mutos_1216` with two dd calls.
The host only CHECKS (lk header, end of BSS, kernel file length) and never changes a byte.

  python3 -I tools/plus/gastbau.py bauen --arbeit DIR            build in the guest
  python3 -I tools/plus/gastbau.py boot  --arbeit DIR --kernel F boot F, run the work tests b1..b11
  python3 -I tools/plus/gastbau.py alles --arbeit DIR            build, compare with the host cut, boot
  python3 -I tools/plus/gastbau.py fixpunkt --arbeit DIR         build with the original kernel (K1), then boot K1, build again (K2), K1 == K2?
All commands take --make vmake (default, the V7 make, userspace/ergaenzung/vmake) or --make make (own make, userspace/make).
Exit 77 without the emulator.
"""
import argparse
import hashlib
import os
import re
import struct
import subprocess
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))
import basis  # noqa: E402  (imports gesamtbau, gast_as, gastlauf)

G = basis.G
gast_as = basis.gast_as
gastlauf = basis.gastlauf
PLUS = os.path.join(G.WURZEL, "kernel", "plus")
NICHT_AUF_DISK = ("README.md",)
CMD_HFE = "a5120_mutos8000_cmd_mfm.hfe"
MAKE = "vmake"     # guest make program on /mnt: "vmake" (V7 make, default, plan 47 P3.4) or "make" (own make)
VMAKE_BIN = os.path.join(G.WURZEL, "userspace", "ergaenzung", "vmake", "work", "bau", "vmake.bin")
ERG_PY = os.path.join(G.WURZEL, "tools", "userspace", "erg.py")


class Fehler(Exception):
    pass


def _cmd_programme(arbeit, namen):
    """Copy programs from the cmd disk (read only) -> {name: bytes}."""
    d = os.path.join(arbeit, "cmdbin")
    os.makedirs(d, exist_ok=True)
    aus = {}
    for n in namen:
        r = subprocess.run([gast_as.disktool(), "get", gast_as.disk(CMD_HFE), "bin/" + n, "--to", d],
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        pf = os.path.join(d, "bin", n)
        if r.returncode or not os.path.exists(pf):
            raise Fehler("disktool get %s: %s" % (n, r.stdout.decode("latin-1")))
        aus[n] = open(pf, "rb").read()
    return aus


def make_programm():
    """-> {guest name: bytes} for the selected make.  vmake.bin is NOT checked in (it belongs to main's userspace/ergaenzung and is
    a build product, work/ is ignored): use the existing build of tools/userspace/erg.py, else build it in the guest (~200 s)."""
    if MAKE == "make":
        mk = os.path.join(G.WURZEL, "userspace", "make")
        return {"make": open(os.path.join(mk, "make.bin"), "rb").read(),
                "make.fileinfo": open(os.path.join(mk, "make.bin.fileinfo"), "r").read()}
    if not os.path.isfile(VMAKE_BIN):
        print("vmake.bin missing: building it with erg.py (guest, ~200 s)")
        if subprocess.run([sys.executable, "-I", ERG_PY, "bau", "vmake"]).returncode or not os.path.isfile(VMAKE_BIN):
            raise Fehler("erg.py bau vmake failed")
    return {"vmake": open(VMAKE_BIN, "rb").read()}


def quellen(arbeit):
    """-> (disk1, disk2, d1c, d2c): the two source disks.  Which C file goes where is read from mk1 (objs1: line) and Makefile (OBJS)."""
    def lies(pfad, binaer=True):
        return open(pfad, "rb" if binaer else "r").read()
    base = dict(make_programm())
    for h in sorted(os.listdir(G.HQUELLEN)):
        if h.endswith(".h"):
            base[h] = lies(os.path.join(G.HQUELLEN, h))
    mk1 = lies(os.path.join(PLUS, "mk1"), False)
    mk2 = lies(os.path.join(PLUS, "Makefile"), False)
    d1c = re.search(r"^objs1: (.*)$", mk1, re.M).group(1).replace(".o", "").split()
    objs2 = re.search(r"^OBJS = (.*)$", mk2, re.M).group(1).replace(".o", "").split()
    # every C file of kernel/c + kernel/conf exactly once: in mk1's objs1 or compiled by a rule of Makefile (and linked)
    d2c = [c for c in G.NAT_CDATEIEN if c not in d1c]
    for c in G.NAT_CDATEIEN:
        zahl = (c in d1c) + len(re.findall(r"^%s\.o:" % re.escape(c), mk2, re.M))
        if zahl != 1:
            raise Fehler("C file %s is built %d times (mk1 + Makefile)" % (c, zahl))
        if c not in objs2:
            raise Fehler("object %s.o is not linked by Makefile" % c)
    disk1, disk2 = dict(base), dict(base)
    disk1["mk1"] = mk1
    disk2["Makefile"] = mk2
    for c in G.NAT_CDATEIEN:
        (disk1 if c in d1c else disk2)[c + ".c"] = lies(G.cpfad(c))
    for n in sorted(os.listdir(PLUS)):
        if n in NICHT_AUF_DISK or n in ("mk1", "Makefile"):
            continue
        disk2[n] = lies(os.path.join(PLUS, n))
    disk2.update(_cmd_programme(arbeit, ("dd", "cmp")))
    return disk1, disk2, d1c, d2c


def lk_pruefen(lk, bss_s):
    """Host check of lk (read only).  -> (text, data, bss, cfree_end, bss_end); raises Fehler."""
    magic, text, data, bss = struct.unpack(">4H", lk[:8])
    ende = text + data + bss          # BSS follows the data
    cf, bende, ok = basis.grenze_pruefen(bss_s, text + data)
    if bss != sum(g for _, g in basis.bss_groessen(bss_s)):
        raise Fehler("lk header bss %d != sum of bss.s (%d)" % (bss, sum(g for _, g in basis.bss_groessen(bss_s))))
    if not ok or bende > basis.BSS_GRENZE or ende > basis.BSS_GRENZE:
        raise Fehler("BSS reaches over cfreelist (D266): cfree ends %04X, BSS ends %04X" % (cf or 0, bende))
    return text, data, bss, cf, bende


def bau_befehle():
    return ["(cd /tmp; /mnt/%s -f /mnt/mk1) >/tmp/make1.log 2>&1" % MAKE, ("wechsel", 1),
            "(cd /tmp; /mnt/%s -f /mnt/Makefile) >/tmp/make2.log 2>&1" % MAKE,
            "ls -l /tmp >/tmp/ls.log 2>&1"]


def bauen(arbeit, boot_hfe=None, extra=None, frist=6_000_000_000, d3=None, rueck_extra=()):
    """Build in the guest.  extra = list of additional shell commands (run after the build; strings or ("wechsel", i)).
    d3: files of an optional third source disk (reached with ("wechsel", 2)).  rueck_extra: additional names to fetch from /tmp.
    Returns {name: bytes|None} with make1.log make2.log ls.log lk mutos_1216 and the dict key '_dauer'."""
    d1, d2, c1, c2 = quellen(arbeit)
    for i, d in enumerate((d1, d2), 1):
        print("disk %d: %d files, %d bytes" % (i, len(d), basis.laenge(d)))
    befehle = bau_befehle() + list(extra or [])
    aus = {}
    disks = [d1, d2] + ([d3] if d3 else [])
    if d3:
        print("disk 3: %d files, %d bytes" % (len(d3), basis.laenge(d3)))
    erg = gastlauf.lauf(os.path.join(arbeit, "gast"), disks, befehle,
                        ["make1.log", "make2.log", "ls.log", "lk", "mutos_1216"] + list(rueck_extra),
                        boot_hfe=boot_hfe, ausfuehrbar=["make", "vmake", "dd", "cmp", "ps", "pstat"], frist=frist, ausgabe=aus)
    print("guest run time (wall clock): %.0f s, log %s" % (aus["dauer"], aus["log"]))
    for n in ("make1.log", "make2.log", "ls.log"):
        print("---", n)
        print((erg.get(n) or b"(missing)").decode("latin-1")[-3000:])
    erg["_dauer"] = aus["dauer"]
    erg["_bss_s"] = d2["bss.s"]
    for n in ("lk", "mutos_1216"):
        if erg.get(n):
            open(os.path.join(arbeit, n), "wb").write(erg[n])
    return erg


def pruefen(erg):
    """Check a build result (host only reads).  Returns the list of failures (empty = ok)."""
    fehler = []
    lk, kern = erg.get("lk"), erg.get("mutos_1216")
    if not lk:
        return ["lk not produced"]
    try:
        text, data, bss, cf, bende = lk_pruefen(lk, erg["_bss_s"])
    except Fehler as e:
        return [str(e)]
    print("lk: text %d data %d bss %d  sha256 %s" % (text, data, bss, hashlib.sha256(lk).hexdigest()))
    print("kernel: text+data %d = %04X; BSS %04X..%04X, cfree ends %04X (limit %04X)" % (
        text + data, text + data, text + data, bende, cf, basis.BSS_GRENZE))
    if not kern:
        return ["mutos_1216 not produced"]
    if len(kern) % 512 or not kern:
        fehler.append("mutos_1216 length %d is not a multiple of 512" % len(kern))
    # what the host would cut from the same lk (comparison only)
    schnitt = lk[16:16 + text + data]
    schnitt = schnitt.ljust((len(schnitt) + 511) // 512 * 512, b"\0")
    print("mutos_1216 (guest): %d bytes sha256 %s; host cut: %d bytes" % (len(kern), hashlib.sha256(kern).hexdigest(), len(schnitt)))
    if kern != schnitt:
        n = next((i for i in range(min(len(kern), len(schnitt))) if kern[i] != schnitt[i]), min(len(kern), len(schnitt)))
        fehler.append("mutos_1216 differs from the host cut of lk (first difference at offset %d)" % n)
    return fehler


# work tests: gesamtbau.BOOTTEST (b1..b11) plus pstat (P3.1).  pstat reads the kernel tables through /dev/mem.
TESTS = list(G.BOOTTEST) + [
    ("pp", "pstat -p >/tmp/pp 2>&1"),
    ("pi", "pstat -i >/tmp/pi 2>&1"),
    ("pf", "pstat -f >/tmp/pf 2>&1"),
]


def testdateien(arbeit):
    """Files the work tests need in the current directory (/mnt): t.c, t2.c, prf.c, the kernel headers, ps, pstat (the last two from the cmd disk)."""
    q = {"t.c": "int f(a)\nint a;\n{\n\treturn a + 1;\n}\n",
         "t2.c": "main()\n{\n\tint i, s;\n\ts = 0;\n\tfor (i = 1; i <= 100; i++)\n\t\ts += i;\n"
                 "\tprintf(\"summe = %d\\n\", s);\n}\n",
         "prf.c": open(G.cpfad("prf"), "rb").read()}
    for h in sorted(os.listdir(G.HQUELLEN)):        # prf.c includes param.h, systm.h, buf.h
        if h.endswith(".h"):
            q[h] = open(os.path.join(G.HQUELLEN, h), "rb").read()
    q.update(_cmd_programme(arbeit, ("ps", "pstat")))
    return q


def _zeilen(text):
    return [z for z in text.replace("\r", "").split("\n") if z.strip()]


def bewerten(name, text):
    """Automatic judgement of one work test output (str).  -> list of failures (empty = ok)."""
    f = []
    if text is None:
        return ["%s: no output file" % name]
    if re.search(r"not found|\bcore\b|cannot|can't|No space|error", text, re.I):
        f.append("%s: error text in the output" % name)
    z = _zeilen(text)
    if name != "b4" and not z:         # b4 = `cc -c t.c`: silent on success
        f.append("%s: empty output" % name)
    if name == "b1" and not re.search(r"\.profile", text):
        f.append("b1: no .profile in ls -l /")
    elif name == "b2" and not re.search(r"^init$", text, re.M):
        f.append("b2: no init in ls /etc")
    elif name in ("b3", "b7") and not re.search(r"return a \+ 1", text):
        f.append("%s: cat of t.c missing" % name)
    elif name == "b4" and z:
        f.append("b4: cc -c t.c printed something")
    elif name == "b5" and not re.search(r"\bt\.o\b", text):
        f.append("b5: no t.o")
    elif name == "b7" and not re.search(r"\b35\b.*/tmp/e1", text):
        f.append("b7: e1 is not 35 bytes")
    elif name == "b8" and len(re.findall(r"summe = 5050", text)) != 2:
        f.append("b8: summe = 5050 not exactly twice")
    elif name == "b9" and not re.search(r"\b1600\b.*\bprf\.o\b", text):
        f.append("b9: no prf.o with 1600 bytes")
    elif name == "b10":
        if not any(re.search(r"\bsh\b", l) for l in z):
            f.append("b10: no sh line in ps")
        if not any(re.search(r"\bps\b", l) for l in z):
            f.append("b10: no ps line in ps")
    elif name == "b11" and not re.search(r"/dev/lp", text):
        f.append("b11: no /dev/lp in ls -l")
    elif name == "pp":
        n = sum(1 for l in z if PSTAT_P_BELEGT.search(l))
        if n < 3:
            f.append("pp: pstat -p lists %d occupied entries (< 3)" % n)
    return f


# pstat -p line of an occupied process-table entry: `LOC S F ...` with LOC = 4 hex digits (measured 2026-11-16, doc/plus/gastbau.md 5)
PSTAT_P_BELEGT = re.compile(r"^[0-9A-F]{4}\s+\d")


def boot(arbeit, kernel_bytes, frist=20_000_000_000):
    """Boot the kernel, run the work tests (TESTS) in the guest, judge them (bewerten).  -> True when no failure."""
    lade = G.ladediskette(arbeit, kernel_bytes)
    aus = {}
    erg = gast_as.gast_befehle(os.path.join(arbeit, "boot"), testdateien(arbeit), [b for _, b in TESTS], [n for n, _ in TESTS],
                               frist=frist, ausgabe=aus, boot_hfe=lade, schirm=True, ausfuehrbar=["ps", "pstat"])
    print("boot test run time (wall clock): %.0f s, log %s" % (aus["dauer"], aus["log"]))
    return auswerten(erg)


def auswerten(erg):
    """Print and judge the test outputs in erg.  -> True when no failure."""
    fehler = []
    for n, b in TESTS:
        v = erg.get(n)
        print("--- %s  (%s)" % (b, "missing" if v is None else "ok"))
        t = None if v is None else v.decode("latin-1")
        if t is not None:
            print(t.rstrip())
        fehler += bewerten(n, t)
    for x in fehler:
        print("FAILURE:", x)
    print("bewerten: %s" % ("no failure" if not fehler else "%d failure(s)" % len(fehler)))
    return not fehler


def fixpunkt(arbeit, k1_datei=None):
    """P3.2: run 1 builds K1 with the original kernel; run 2 boots K1, builds K2 and compares K2 with K1 in the guest and on the host.
    Neither source disk has room for K1 and the test files (a disk holds ~230 KB with the file system overhead, disk 1 is at 207 KB,
    disk 2 at 233 KB), so a THIRD disk carries k1, cmp, the test files and the headers; the work tests run on it (cwd /mnt).
    k1_datei: use that file as K1 instead of run 1 (only to repeat run 2 with the same K1; the test and the plan do the full fixpunkt).
    -> True when cmp.log is empty, gleich exists, K1 == K2 and bewerten finds no failure."""
    os.makedirs(arbeit, exist_ok=True)
    if k1_datei:
        k1 = open(k1_datei, "rb").read()
        print("=== run 1 skipped: K1 = %s (%d B, sha256 %s)" % (k1_datei, len(k1), hashlib.sha256(k1).hexdigest()))
    else:
        print("=== run 1: build with the original kernel")
        e1 = bauen(os.path.join(arbeit, "lauf1"))
        f = pruefen(e1)
        for x in f:
            print("FAILURE:", x)
        if f:
            return False
        k1 = e1["mutos_1216"]
    lade = G.ladediskette(os.path.join(arbeit, "lade_k1"), k1)
    print("=== run 2: boot K1, build, cmp with K1, work tests")
    d3 = testdateien(arbeit)
    d3["k1"] = k1
    d3.update(_cmd_programme(arbeit, ("cmp",)))
    extra = [("wechsel", 2),
             "cmp /tmp/mutos_1216 /mnt/k1 >/tmp/cmp.log 2>&1 && ls -l /tmp/mutos_1216 >/tmp/gleich 2>&1",
             "rm -f /tmp/*.o"] + [b for _, b in TESTS]
    e2 = bauen(os.path.join(arbeit, "lauf2"), boot_hfe=lade, extra=extra, d3=d3, rueck_extra=["cmp.log", "gleich"] + [n for n, _ in TESTS])
    ok = not pruefen(e2)
    k2 = e2.get("mutos_1216")
    cmplog, gleich = e2.get("cmp.log"), e2.get("gleich")
    print("cmp.log: %s; gleich: %s" % ("missing" if cmplog is None else "%d bytes" % len(cmplog), "missing" if gleich is None else gleich.decode("latin-1").strip()))
    if cmplog:
        print(cmplog.decode("latin-1"))
        ok = False
    if gleich is None:
        ok = False
    if k2 is None:
        print("FAILURE: K2 not produced")
        return False
    print("K1 sha256 %s (%d B)\nK2 sha256 %s (%d B)" % (hashlib.sha256(k1).hexdigest(), len(k1), hashlib.sha256(k2).hexdigest(), len(k2)))
    if k1 != k2:
        ok = False
        m = [i for i in range(min(len(k1), len(k2))) if k1[i] != k2[i]]
        print("FAILURE: K1 != K2: %d differing bytes (length %d/%d); first offsets: %s" % (
            len(m) + abs(len(k1) - len(k2)), len(k1), len(k2), " ".join("%04X" % i for i in m[:20])))
    if not auswerten(e2):
        ok = False
    print("FIXPUNKT:", "ja" if ok else "NEIN")
    return ok


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=("bauen", "boot", "alles", "fixpunkt"))
    ap.add_argument("--arbeit", required=True)
    ap.add_argument("--kernel")
    ap.add_argument("--make", choices=("vmake", "make"), default="vmake", help="guest make program (default vmake, the V7 make)")
    ap.add_argument("--k1", help="fixpunkt: use this file as K1 instead of building it (repeat run 2 only)")
    a = ap.parse_args(argv)
    global MAKE
    MAKE = a.make
    try:
        gast_as.pruefe_hilfsmittel()
        if a.cmd == "boot":
            return 0 if boot(a.arbeit, open(a.kernel, "rb").read()) else 1
        if a.cmd == "fixpunkt":
            return 0 if fixpunkt(a.arbeit, a.k1) else 1
        erg = bauen(a.arbeit)
        f = pruefen(erg)
        for x in f:
            print("FAILURE:", x)
        if f:
            return 1
        if a.cmd == "alles" and not boot(a.arbeit, erg["mutos_1216"]):
            print("FAILURE: boot/work tests")
            return 1
        return 0
    except gast_as.Fehlt as e:
        print("skip: missing", e)
        return 77


if __name__ == "__main__":
    sys.exit(main())
