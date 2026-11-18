#!/usr/bin/env python3
"""Build the MUTOS CP/A variant (4 floppies A:-D:, GIDE from E:, RTC) in a fresh copy of the CPA_Workbench (plan 48 C2.2); stdlib only.

The Workbench (env CPA_WORKBENCH, default ~/projects/CPA_Workbench) is only READ.  Every build copies it afresh to <arbeit>/wb/
(its builder skips up-to-date targets, so a reused copy would hide changes) and never starts the GUI (cpa_workbench.py).
The settings that differ from the variant default are in mutos_io/cpa/system/konfig.txt.

API:
  os_com(arbeit)          build; returns the bytes of @OS.COM (checks size/SHA-1)
  systemdiskette(arbeit)  boot disk <arbeit>/sys4.hfe = copy of cpa.GIDE_SYS with the new @OS.COM; returns the path
  pruefen(arbeit)         builds and boots it; returns (all ok, report lines)
Command line: cpa_system.py bauen|pruefen --arbeit DIR.  Exit 77 when Workbench, emulator or tool chain is missing.
"""
import argparse
import hashlib
import importlib.util
import os
import re
import shutil
import subprocess
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.dirname(HIER))
import cpa  # noqa: E402
import emu  # noqa: E402

SKIP = 77
REPO = emu.repo()
KONFIG = os.path.join(REPO, "mutos_io", "cpa", "system", "konfig.txt")
VARIANTE = "gide_a5120"
WB_STAND = "0045dc6"                    # Workbench commit the SHA-1 below was measured with
OS_SHA1 = "97bbdca995953cc928e5b09cc0d3ae32d9a2ef45"
OS_GROESSE = 16768
KOPIE = ("src", "config", "prebuilt", "tools", "additions", "diskdefs", "cpaFormates.cfg")


class Fehlt(Exception):
    """Workbench, emulator or tool chain missing (callers exit 77 / skip)."""


def workbench():
    return os.path.abspath(os.path.expanduser(os.environ.get("CPA_WORKBENCH") or "~/projects/CPA_Workbench"))


def konfig(pfad=KONFIG):
    """konfig.txt -> {KEY: value or None (empty value = option not set)}."""
    d = {}
    with open(pfad, encoding="ascii") as f:
        for z in f:
            z = z.split("#", 1)[0].strip()
            if z:
                k, _, v = z.partition("=")
                d[k.strip()] = v.strip() or None
    return d


def _stand(wb):
    r = subprocess.run(["git", "-C", wb, "rev-parse", "--short", "HEAD"], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def _baue(arbeit):
    """Fresh copy + build; returns (path of @os.com, report lines)."""
    wb0 = workbench()
    if not os.path.isfile(os.path.join(wb0, "tools", "cpa_builder.py")):
        raise Fehlt("CPA_Workbench not found: " + wb0)
    if not emu.cpm_bau().werkzeugkette_da():
        raise Fehlt("CP/M tool chain (CPA_TOOLS) missing")
    rep = []
    stand = _stand(wb0)
    if stand != WB_STAND:
        rep.append("WARNUNG Workbench at %s, expected %s" % (stand, WB_STAND))
    wb = os.path.join(os.path.abspath(arbeit), "wb")
    shutil.rmtree(wb, ignore_errors=True)
    os.makedirs(wb)
    for n in KOPIE:
        s = os.path.join(wb0, n)
        if os.path.isdir(s):
            shutil.copytree(s, os.path.join(wb, n), symlinks=True)
        elif os.path.exists(s):
            shutil.copy2(s, wb)
    cwd = os.getcwd()
    os.chdir(wb)        # patch_mac.py works with relative paths
    try:
        spec = importlib.util.spec_from_file_location("cpa_builder", os.path.join(wb, "tools", "cpa_builder.py"))
        m = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(m)
        b = m.CPABuilder(wb)
        cfgp = os.path.join(wb, ".config")      # our own, never the one of the Workbench (other variant)
        with open(cfgp, "w") as f:
            f.write("CONFIG_VARIANT_%s=y\n" % VARIANTE)
        b.run_patch_mac(cfgp, VARIANTE, "extract")      # values from setup.mac
        cfg = b.load_config(cfgp)
        cfg.update(konfig())
        b.save_config(cfg, cfgp)
        b.run_patch_mac(cfgp, VARIANTE, "patch")        # back into setup.mac
        b.build_os(cfg)
    finally:
        os.chdir(cwd)
    p = os.path.join(wb, "build", "@os.com")
    if not os.path.isfile(p):
        raise RuntimeError("build produced no @os.com")
    return p, rep


def os_com(arbeit):
    p, _ = _baue(arbeit)
    with open(p, "rb") as f:
        b = f.read()
    h = hashlib.sha1(b).hexdigest()
    if h != OS_SHA1 or len(b) != OS_GROESSE:
        raise RuntimeError("@OS.COM differs: %d bytes, SHA-1 %s (expected %d, %s)" % (len(b), h, OS_GROESSE, OS_SHA1))
    return b


def systemdiskette(arbeit):
    """Boot disk <arbeit>/sys4.hfe: the system tracks hold the fixed loader, @OS.COM comes from the file system (c1_8 sec.3)."""
    b = os_com(arbeit)
    return cpa.diskette(arbeit, "sys4.hfe", cpa.GIDE_SYS, {"@OS.COM": b})


def _bau_oder_skip(arbeit):
    if cpa.fehlt(werkzeug=True):
        raise Fehlt("emulator or CP/M tool chain missing")
    return systemdiskette(arbeit)


def pruefen(arbeit):
    """Build, boot with four floppies and check header, DIR E:, RTC; returns (all ok, report lines)."""
    arbeit = os.path.abspath(arbeit)
    wb0 = workbench()
    vorher = subprocess.run(["git", "-C", wb0, "status", "--porcelain"], capture_output=True, text=True).stdout
    sysd = _bau_oder_skip(arbeit)
    rep, ok = [], True
    rep.append("@OS.COM %d bytes, SHA-1 %s" % (OS_GROESSE, OS_SHA1))
    ok &= cpa._ok("SHA-1 equal", True, rep)
    # B: C: D: only need to be readable; the plain GIDE boot disk twice stands in for them (no MUTOS disks needed)
    b = cpa.diskette(arbeit, "b.hfe", cpa.GIDE_SYS)
    c = cpa.diskette(arbeit, "c.hfe", cpa.GIDE_SYS)
    d = cpa.diskette(arbeit, "d.hfe", cpa.GIDE_SYS)
    log = _lauf(arbeit, sysd, b, c, d, ["DIR E:"])
    txt = cpa._alles(log)
    for t in ("A:5\"(80,DD,DS)/B:", "C:5\"(80,DD,DS)/D:5\"(80,DD,DS)", "GIDE-Laufwerke E: bis L:", "RTC 72421 auf Adresse 0D5H"):
        ok &= cpa._ok("header: " + t, t in txt, rep)
    ok &= cpa._ok("TPA 100H - 0BC05H", "0BC05H" in txt, rep)
    ok &= cpa._ok("DIR E: lists @OS", re.search(r"@OS\b", txt.split("DIR E:")[-1]) is not None, rep)
    for z in txt.splitlines():
        if "GIDE-CP/A" in z or "Disketten:" in z or "GIDE-Modul" in z or "RTC 72421" in z:
            rep.append("  kopf: " + z.strip())
    # clock: two samples of the RTC registers in RAM at 0050H, seconds must advance
    w = _uhr(arbeit, sysd, b, c, d)
    rep.append("  uhr: " + w[0] + " -> " + w[1])
    ok &= cpa._ok("clock runs", w[0] != w[1] and "?" not in w[0] + w[1], rep)
    nachher = subprocess.run(["git", "-C", wb0, "status", "--porcelain"], capture_output=True, text=True).stdout
    ok &= cpa._ok("Workbench git status unchanged", vorher == nachher, rep)
    return bool(ok), rep


def _lauf(arbeit, sysd, b, c, d, zeilen):
    return cpa.lauf(arbeit, zeilen, sysd, b, c, d, laufwerke="K5601,K5601,K5601,K5601")


def _uhr(arbeit, sysd, b, c, d):
    """Two `d 0x0050 3` dumps; returns the two byte strings."""
    log = cpa.lauf_dbg(arbeit, ["d 0x0050 3", "g 100000000", "d 0x0050 3", "g 100000000", "d 0x0050 3"], sysd, b, c, d,
                       laufwerke="K5601,K5601,K5601,K5601", name="uhr")
    werte = re.findall(r"^\s*0*50[: ]+((?:[0-9A-Fa-f]{2} ?){3})", log, re.M)
    werte = [w.strip() for w in werte]
    if len(werte) < 2:
        return ["?", "?"]
    return [werte[0], werte[-1]]


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=("bauen", "pruefen"))
    ap.add_argument("--arbeit", required=True, help="work folder, e.g. /tmp/mplus/c2_2")
    a = ap.parse_args(argv)
    try:
        if a.cmd == "bauen":
            p = _bau_oder_skip(a.arbeit)
            print("built", p)
            return 0
        ok, rep = pruefen(a.arbeit)
    except Fehlt as e:
        print("SKIP:", e)
        return SKIP
    print("\n".join(rep))
    print("PRUEFEN", "OK" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
