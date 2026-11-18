#!/usr/bin/env python3
"""Boot disk of the MUTOS CP/A variant (plan 48 C2.4); stdlib only.

The 4-floppy system disk of cpa_system.py plus the three files the loader needs:
  M8KBOOT.COM   mutos_io/cpa/m8kboot.com
  MUTOS.SYS     the kernel (default: mutos_1216 of the original boot disk, 36352 bytes)
  MUTOSIO.IMG   image of the current mutos_io/cpa/src/mutoscpa.mac (build.abbild())
No autostart: M8KBOOT is typed at the A> prompt.

API:
  original_kernel(arbeit)                   bytes of mutos_1216 (k1520disktool get from the original boot disk)
  bootdiskette(arbeit, kernel=None, io_quelle=None) -> path of <arbeit>/boot4.hfe
                                            kernel: bytes or file name; io_quelle: .mac path (default mutoscpa.mac)
  kstart(arbeit) -> (ok, report)            acceptance C2 on the 4-floppy disk: `M8KBOOT K` and full operation `M8KBOOT`
Command line: cpa_disk.py diskette|kstart --arbeit DIR [--kernel FILE].  Exit 77 without emulator/Workbench/tool chain.
"""
import argparse
import importlib.util
import os
import re
import subprocess
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.dirname(HIER))
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))
import cpa  # noqa: E402
import cpa_system  # noqa: E402
import emu  # noqa: E402

SKIP = 77
REPO = emu.repo()
CPA = os.path.join(REPO, "mutos_io", "cpa")
DBG = os.path.join(REPO, "versuche", "dbg")
KERNEL_LEN = 36352
BIOS_4FLOPPY = 0xCA00
LAUFWERKE = "K5601,K5601,K5601,K5601"
Fehlt = cpa_system.Fehlt


def _build():
    spec = importlib.util.spec_from_file_location("cpa_build", os.path.join(CPA, "build.py"))
    b = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(b)
    return b


def original_kernel(arbeit):
    """The original kernel mutos_1216 (36352 B, no UDOS header) from the original boot disk."""
    import gast_as
    ziel = os.path.join(arbeit, "mutos_1216")
    if not os.path.exists(ziel):
        os.makedirs(arbeit, exist_ok=True)
        subprocess.run([emu.binary("k1520disktool"), "get", gast_as.disk("a5120_mutos8000_boot_udos_k5601.hfe"),
                        "mutos_1216", "--to", arbeit], check=True, capture_output=True)
    with open(ziel, "rb") as f:
        return f.read()


def bootdiskette(arbeit, kernel=None, io_quelle=None):
    """<arbeit>/boot4.hfe = 4-floppy system disk + M8KBOOT.COM + MUTOS.SYS + MUTOSIO.IMG.  Returns the path."""
    arbeit = os.path.abspath(arbeit)
    if cpa.fehlt(werkzeug=True):
        raise Fehlt("emulator or CP/M tool chain missing")
    if kernel is None:
        kern = original_kernel(arbeit)
    elif isinstance(kernel, (bytes, bytearray)):
        kern = bytes(kernel)
    else:
        with open(kernel, "rb") as f:
            kern = f.read()
    img = _build().abbild(io_quelle)
    with open(os.path.join(CPA, "m8kboot.com"), "rb") as f:
        com = f.read()
    sysd = cpa_system.systemdiskette(arbeit)
    return cpa.diskette(arbeit, "boot4.hfe", sysd, {"M8KBOOT.COM": com, "MUTOS.SYS": kern, "MUTOSIO.IMG": img})


def release_adr():
    """Address of 'LD A,2CH' (OUT that releases RESET16) in m8kboot.com; the pattern must be unique."""
    with open(os.path.join(CPA, "m8kboot.com"), "rb") as f:
        d = f.read()
    if d.count(b"\x3e\x2c\xd3\xa9") != 1:
        raise RuntimeError("release pattern in m8kboot.com not unique")
    return 0x100 + d.find(b"\x3e\x2c\xd3\xa9")


def _skript(datei, **ers):
    with open(os.path.join(DBG, datei)) as f:
        t = f.read()
    for k, v in ers.items():
        t = t.replace("@%s@" % k, str(v))
    return [ln for ln in t.splitlines() if ln.strip() and not ln.startswith("#")]


def _bytes_hinter(log, befehl):
    """Bytes of the first 'd' output after the debugger command line `befehl` (None when absent)."""
    i = log.find("(dbg) " + befehl)
    if i < 0:
        return None
    m = re.search(r"\n\s*(?:em:)?[0-9A-F]{4,5}:?\s+((?:[0-9A-F]{2} )+)", log[i:])
    return [int(x, 16) for x in m.group(1).split()] if m else None


def _resets(arbeit):
    with open(os.path.join(arbeit, "em.log")) as f:
        em = f.read().splitlines()
    return em, [ln.split()[3] for ln in em if ln.split()[2:3] == ["RESET16"]]


def _lauf(arbeit, platte, zeilen, name):
    """Run the debugger lines on the 4-floppy boot disk (B: C: D: = copies of the GIDE disk, only attached)."""
    b = cpa.diskette(arbeit, "b.hfe", cpa.GIDE_SYS)
    c = cpa.diskette(arbeit, "c.hfe", cpa.GIDE_SYS)
    d = cpa.diskette(arbeit, "d.hfe", cpa.GIDE_SYS)
    return cpa.lauf_dbg(arbeit, zeilen, platte, b, c, d, laufwerke=LAUFWERKE, name=name)


def kstart(arbeit):
    """Acceptance C2 on the 4-floppy disk; returns (all ok, report lines).

    Run 1 `M8KBOOT K` (as C2.3): EM segment 0 == kernel, U8001 starts at <<0>>%027E, counter >= 1, EM 0006H changed.
    Run 2 `M8KBOOT`: BIOS start CA00H measured, breakpoint 9000H reached, 9000H.. == MUTOSIO.IMG, U8001 stays in reset."""
    arbeit = os.path.abspath(arbeit)
    if cpa.fehlt(werkzeug=True):
        raise Fehlt("emulator or CP/M tool chain missing")
    rep, ok = [], True
    kern = original_kernel(arbeit)
    img = _build().abbild()
    platte = bootdiskette(arbeit, kernel=kern)
    rep.append("MUTOS.SYS %d B, MUTOSIO.IMG %d B" % (len(kern), len(img)))
    ok &= cpa._ok("kernel is %d B" % KERNEL_LEN, len(kern) == KERNEL_LEN, rep)

    # run 1: K mode
    ka = os.path.join(arbeit, "k")
    os.makedirs(ka, exist_ok=True)
    log = _lauf(ka, platte, _skript("cpa_c2_3_k.dbg", ARBEIT=ka, RELEASE="0x%04X" % release_adr()), "k")
    with open(os.path.join(ka, "em0.bin"), "rb") as f:
        ok &= cpa._ok("K: EM segment 0 == mutos_1216 (all %d B)" % KERNEL_LEN, f.read() == kern, rep)
    ok &= cpa._ok("K: message KERNEL LOADED", "KERNEL LOADED" in cpa._alles(log) or "KERNEL LOADED" in log, rep)
    ok &= cpa._ok("K: U8001 runs at <<0>>%027E", re.search(r"\*\* bp.*U8001.*027E|U8001 PC=<<0>>%027E", log) is not None, rep)
    em, reset = _resets(ka)
    ok &= cpa._ok("K: RESET16 ... 1 then 0 (%s)" % reset[-2:], len(reset) >= 2 and reset[-1] == "0" and reset[-2] == "1", rep)
    n = _bytes_hinter(log, "d 0xffe 2")
    ok &= cpa._ok("K: INT-16 counter >= 1 (%s)" % n, bool(n) and n[0] + 256 * n[1] >= 1, rep)
    w = _bytes_hinter(log, "d em:6 2")
    ok &= cpa._ok("K: EM 0006H = mailbox pointer, not 0 and not 027EH (%s)" % (w and "%02X%02X" % tuple(w[:2])),
                  bool(w) and w[:2] != [0, 0] and w[:2] != [0x02, 0x7E], rep)

    # run 2: full operation
    va = os.path.join(arbeit, "voll")
    os.makedirs(va, exist_ok=True)
    log = _lauf(va, platte, _skript("cpa_c2_3_voll.dbg", ARBEIT=va, IMGLEN=len(img)), "voll")
    v = _bytes_hinter(log, "d 0x0001 2")
    bios = (v[0] + 256 * v[1] - 3) if v else None
    rep.append("  (0001H) = %s -> BIOS start %s" % (v and "%02X%02X" % (v[1], v[0]), bios is not None and "%04XH" % bios))
    ok &= cpa._ok("full: BIOS start CA00H", bios == BIOS_4FLOPPY, rep)
    with open(os.path.join(va, "em0.bin"), "rb") as f:
        ok &= cpa._ok("full: EM segment 0 == mutos_1216", f.read() == kern, rep)
    ok &= cpa._ok("full: breakpoint 9000H reached (position check positive)", re.search(r"bp.*PC=9000", log) is not None, rep)
    with open(os.path.join(va, "io9000.bin"), "rb") as f:
        got = f.read()
    ok &= cpa._ok("full: bytes 9000H..%04XH == MUTOSIO.IMG (%d B)" % (0x9000 + len(img) - 1, len(img)), got == img, rep)
    em, reset = _resets(va)
    ok &= cpa._ok("full: U8001 stays in reset (last RESET16 = 1)", bool(reset) and reset[-1] == "1", rep)
    return bool(ok), rep


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=("diskette", "kstart"))
    ap.add_argument("--arbeit", required=True, help="work folder, e.g. /tmp/mplus/c2_4")
    ap.add_argument("--kernel", help="kernel file (default: mutos_1216 of the original boot disk)")
    a = ap.parse_args(argv)
    try:
        if a.cmd == "diskette":
            print("built", bootdiskette(a.arbeit, kernel=a.kernel))
            return 0
        ok, rep = kstart(a.arbeit)
    except Fehlt as e:
        print("SKIP:", e)
        return SKIP
    print("\n".join(rep))
    print("KSTART", "OK" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
