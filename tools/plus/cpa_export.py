#!/usr/bin/env python3
"""Export the MUTOS CP/A boot disk contents as an archive for the emulator project (plan 48 follow-up); stdlib only.

Builds afresh (like cpa_disk.py):
  @OS.COM       4-floppy CP/A system (cpa_system.os_com; Workbench variant gide_a5120, SHA-1 97bbdca9...)
  M8KBOOT.COM   mutos_io/cpa/src/m8kboot.mac  (build.py --out, M80 + LINKMT)
  MUTOSIO.IMG   mutos_io/cpa/src/mutoscpa.mac (build.abbild())
and writes a5120_mutos8000_boot_cpa.zip in the layout of the emulator archives (a5120emu: disks/a5120_mutos8000/*.zip):
  bauangaben.yaml   flat `key: value` (build recipe + provenance)
  herkunft.txt      human readable provenance (mutos8k commit, Workbench commit, SHA-1 per file, reference to plan 48)
  dateien/          the three files
The kernel MUTOS.SYS is NOT in the archive: bauangaben.yaml says it is `mutos_1216` of boot_udos.zip (original kernel).
The zip is deterministic for equal inputs (fixed time stamps, sorted names).

API:
  dateien(arbeit) -> {name: bytes}              fresh build of the three files
  herkunft(dat)   -> dict of provenance values
  archiv_schreiben(ziel, dat, her)              write the zip
Command line: cpa_export.py archiv --arbeit DIR --out FILE.zip.  Exit 77 without emulator/Workbench/tool chain.
"""
import argparse
import hashlib
import os
import subprocess
import sys
import zipfile

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.dirname(HIER))
import cpa  # noqa: E402
import cpa_system  # noqa: E402
import emu  # noqa: E402

SKIP = 77
REPO = emu.repo()
Fehlt = cpa_system.Fehlt
ARCHIV_NAME = "a5120_mutos8000_boot_cpa.zip"
NAMEN = ("@OS.COM", "M8KBOOT.COM", "MUTOSIO.IMG")
ZEIT = (2026, 11, 18, 0, 0, 0)          # fixed: equal inputs give an identical zip
BASIS_DISKETTE = "a5120_cpa_gide/a5120_cpa_gide_k7024_2fdd_8gide_system.hfe"
KERNEL_ARCHIV = "a5120_mutos8000/a5120_mutos8000_boot_udos.zip"


def _git(*args):
    r = subprocess.run(["git", "-C", REPO] + list(args), capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else ""


def dateien(arbeit):
    """Fresh build of @OS.COM, M8KBOOT.COM, MUTOSIO.IMG (see module doc)."""
    arbeit = os.path.abspath(arbeit)
    if cpa.fehlt(werkzeug=True):
        raise Fehlt("emulator or CP/M tool chain missing")
    os.makedirs(arbeit, exist_ok=True)
    os_com = cpa_system.os_com(arbeit)
    build = os.path.join(REPO, "mutos_io", "cpa", "build.py")
    boot = os.path.join(arbeit, "m8kboot.com")
    r = subprocess.run([sys.executable, "-I", build, "--out", boot, "m8kboot"], capture_output=True, text=True)
    if r.returncode == SKIP:
        raise Fehlt("emulator or CP/M tool chain missing")
    if r.returncode != 0 or not os.path.isfile(boot):
        raise RuntimeError("build of m8kboot.com failed:\n" + r.stdout + r.stderr)
    with open(boot, "rb") as f:
        com = f.read()
    import cpa_disk
    img = cpa_disk._build().abbild()
    return {"@OS.COM": os_com, "M8KBOOT.COM": com, "MUTOSIO.IMG": img}


def herkunft(dat):
    """Provenance values for bauangaben.yaml / herkunft.txt."""
    wb = cpa_system.workbench()
    dirty = bool(_git("status", "--porcelain", "--", "mutos_io/cpa", "tools/plus"))
    return {
        "commit": _git("rev-parse", "HEAD"),
        "zweig": _git("rev-parse", "--abbrev-ref", "HEAD"),
        "unsauber": dirty,
        "workbench": cpa_system._stand(wb) or "unknown",
        "sha1": {n: hashlib.sha1(b).hexdigest() for n, b in dat.items()},
        "groesse": {n: len(b) for n, b in dat.items()},
    }


def bauangaben(her):
    s = her["sha1"]
    g = her["groesse"]
    z = [
        "# Build recipe of the MUTOS CP/A boot disk (consumed by a5120emu: tools/mutos8000/bau_cpa.py).",
        "# Flat `key: value`, one value per line.  Written by mutos8k tools/plus/cpa_export.py.",
        "art: cpa_bootdiskette",
        "# Base disk in the emulator project: its system tracks stay; @OS.COM is replaced (rm + put), see mutos8k doc/plus/cpa/c1_8_vier_floppy.md.",
        "basis_diskette: " + BASIS_DISKETTE,
        "# Files of dateien/ put onto the base disk (CP/M names).",
        "dateien: " + " ".join(NAMEN),
    ]
    for n in NAMEN:
        z.append("sha1_%s: %s" % (n.replace("@", "").replace(".", "_").lower(), s[n]))
        z.append("groesse_%s: %d" % (n.replace("@", "").replace(".", "_").lower(), g[n]))
    z += [
        "# The kernel is NOT part of this archive: MUTOS.SYS = `mutos_1216` (original kernel, 36352 bytes) of the UDOS boot archive.",
        "kernel_name: MUTOS.SYS",
        "kernel_archiv: " + KERNEL_ARCHIV,
        "kernel_datei: dateien/mutos_1216",
        "kernel_groesse: 36352",
        "# Provenance",
        "herkunft_projekt: mutos8k",
        "herkunft_zweig: " + her["zweig"],
        "herkunft_commit: " + her["commit"] + (" (uncommitted changes in mutos_io/cpa or tools/plus)" if her["unsauber"] else ""),
        "herkunft_workbench: CPA_Workbench " + her["workbench"] + ", variant gide_a5120, anzdisk=4, crt=k7024",
        "herkunft_plan: Plan 48 (mutos8k doc/plan/48_mutos_io_cpa.md, doc/plus/cpa.md)",
    ]
    return "\n".join(z) + "\n"


def herkunft_txt(her):
    z = ["MUTOS 8000 under CP/A: boot disk contents (plan 48, mutos8k)", "",
         "mutos8k   : branch %s, commit %s%s" % (her["zweig"], her["commit"], " (+ uncommitted changes)" if her["unsauber"] else ""),
         "Workbench : CPA_Workbench commit %s (variant gide_a5120, anzdisk=4, crt=k7024; settings mutos_io/cpa/system/konfig.txt)" % her["workbench"],
         "Reference : mutos8k doc/plus/cpa.md, doc/plan/48_mutos_io_cpa.md; findings doc/plus/cpa/c*.md", "",
         "Files (dateien/):"]
    for n in NAMEN:
        z.append("  %-12s %6d bytes  SHA-1 %s" % (n, her["groesse"][n], her["sha1"][n]))
    z += ["", "Not included: MUTOS.SYS = mutos_1216 of %s (original kernel)." % KERNEL_ARCHIV,
          "The disk is built on the emulator side from this archive, the kernel and the CP/A GIDE base disk (%s)." % BASIS_DISKETTE,
          "No autostart: type M8KBOOT at the A> prompt, then `r` in the control mask."]
    return "\n".join(z) + "\n"


def archiv_schreiben(ziel, dat, her):
    """Deterministic zip: bauangaben.yaml, herkunft.txt, dateien/<name>."""
    os.makedirs(os.path.dirname(os.path.abspath(ziel)), exist_ok=True)
    teile = [("bauangaben.yaml", bauangaben(her).encode("ascii")),
             ("herkunft.txt", herkunft_txt(her).encode("ascii"))] + \
            [("dateien/" + n, dat[n]) for n in sorted(dat)]
    with zipfile.ZipFile(ziel, "w", zipfile.ZIP_DEFLATED) as z:
        for name, b in teile:
            zi = zipfile.ZipInfo(name, ZEIT)
            zi.compress_type = zipfile.ZIP_DEFLATED
            zi.external_attr = 0o644 << 16
            z.writestr(zi, b)
    return ziel


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=("archiv",))
    ap.add_argument("--arbeit", required=True, help="work folder, e.g. /tmp/mplus/emu_cpa")
    ap.add_argument("--out", required=True, help="target zip, e.g. .../" + ARCHIV_NAME)
    a = ap.parse_args(argv)
    try:
        dat = dateien(a.arbeit)
    except Fehlt as e:
        print("SKIP:", e)
        return SKIP
    her = herkunft(dat)
    archiv_schreiben(a.out, dat, her)
    print("written", a.out)
    for n in NAMEN:
        print("  %-12s %6d  %s" % (n, her["groesse"][n], her["sha1"][n]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
