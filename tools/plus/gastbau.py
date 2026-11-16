"""Plan 47 P1.4/P1.5: build the MUTOS kernel entirely in the guest (no host step between source and kernel).

Sources: kernel/plus (assembler, abs.s, bss.s, mk1, Makefile), kernel/c, kernel/conf, kernel/h, userspace/make.  They go onto two
source disks (the sources do not fit on one, doc/plus/gastbau.md 1); the guest builds with `make -f /mnt/mk1`, the disk is changed
(gastlauf.lauf), `make -f /mnt/Makefile` builds the rest, links `lk` and cuts the kernel file `mutos_1216` with two dd calls.
The host only CHECKS (lk header, end of BSS, kernel file length) and never changes a byte.

  python3 -I tools/plus/gastbau.py bauen --arbeit DIR            build in the guest
  python3 -I tools/plus/gastbau.py boot  --arbeit DIR --kernel F boot F, run the work tests b1..b11
  python3 -I tools/plus/gastbau.py alles --arbeit DIR            build, compare with the host cut, boot
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


def quellen(arbeit):
    """-> (disk1, disk2, d1c, d2c): the two source disks.  Which C file goes where is read from mk1 (objs1: line) and Makefile (OBJS)."""
    def lies(pfad, binaer=True):
        return open(pfad, "rb" if binaer else "r").read()
    mk = os.path.join(G.WURZEL, "userspace", "make")
    base = {"make": lies(os.path.join(mk, "make.bin")), "make.fileinfo": lies(os.path.join(mk, "make.bin.fileinfo"), False)}
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


def bauen(arbeit, boot_hfe=None, extra=None, frist=6_000_000_000):
    """Build in the guest.  extra = list of additional shell commands (run after the build, on the source disk 2).
    Returns {name: bytes|None} with make1.log make2.log ls.log lk mutos_1216 and the dict key '_dauer'."""
    d1, d2, c1, c2 = quellen(arbeit)
    for i, d in enumerate((d1, d2), 1):
        print("disk %d: %d files, %d bytes" % (i, len(d), basis.laenge(d)))
    befehle = ["(cd /tmp; /mnt/make -f /mnt/mk1) >/tmp/make1.log 2>&1", ("wechsel", 1),
               "(cd /tmp; /mnt/make -f /mnt/Makefile) >/tmp/make2.log 2>&1",
               "ls -l /tmp >/tmp/ls.log 2>&1"] + list(extra or [])
    aus = {}
    erg = gastlauf.lauf(os.path.join(arbeit, "gast"), [d1, d2], befehle,
                        ["make1.log", "make2.log", "ls.log", "lk", "mutos_1216"], boot_hfe=boot_hfe,
                        ausfuehrbar=["make", "dd", "cmp"], frist=frist, ausgabe=aus)
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


def boot(arbeit, kernel_bytes):
    """Boot the kernel and run the work tests b1..b11 (gesamtbau.boot_pruefen)."""
    return G.boot_pruefen(os.path.join(arbeit, "boot"), kernel_bytes)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=("bauen", "boot", "alles"))
    ap.add_argument("--arbeit", required=True)
    ap.add_argument("--kernel")
    a = ap.parse_args(argv)
    try:
        gast_as.pruefe_hilfsmittel()
        if a.cmd == "boot":
            return 0 if boot(a.arbeit, open(a.kernel, "rb").read()) else 1
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
