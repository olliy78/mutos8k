#!/usr/bin/env python3
"""Driver of plan 48 C1.7: runs itest.mac under the GIDE-CP/A and evaluates ticks and gaps (stdlib only).

    python3 -I versuche/plus_cpa/itest.py --arbeit /tmp/mplus/c1_7 [--b <MUTOS disk .hfe>]

Boots CP/A (GIDE, EM256), starts ITEST.COM from A: with a *copy* of a MUTOS root disk in B: (mounted --rw: phase C writes
to that copy), sets log points on the phase borders (0110H+n, machine cycle in the log) and `itrace` for every accepted INT.
Prints per phase: ticks, duration (machine cycles), longest/mean tick gap from the itrace, ticks expected from the duration.
Exit 0 = run complete and data equal; 77 = no emulator / no tool chain.
"""
import os
import re
import shutil
import subprocess
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(HIER)), "tools", "plus"))
import cpa  # noqa: E402

NOM = 49152          # nominal cycles per tick: CTC prescaler 256 x time constant 192 (analyse.md 1.3); the machine clock counts
                     # about 0.2 % more per tick, so 'expected' below is calibrated with the idle phase P (500 ticks)
# border pairs (start, end), with the ISR on in the pass named
PHASEN = [("P idle 500 ticks (ISR on)", 0, 1, True),
          ("A 400 READ, off (cold)", 2, 3, False), ("A 400 READ, off (warm)", 14, 15, False), ("A 400 READ, ISR on", 4, 5, True),
          ("B 2000 CONOUT, off (cold)", 6, 7, False), ("B 2000 CONOUT, off (warm)", 16, 17, False), ("B 2000 CONOUT, ISR on", 8, 9, True),
          ("C 200 WRITE, off (cold)", 10, 11, False), ("C 200 WRITE, off (warm)", 18, 19, False), ("C 200 WRITE, ISR on", 12, 13, True)]


def run(arbeit, bdisk):
    arbeit = os.path.abspath(arbeit)
    meld = []
    com = cpa.com("itest", HIER, meld)
    sysd = cpa.diskette(arbeit, "sys.hfe", cpa.GIDE_SYS, {"ITEST.COM": com})
    b = os.path.join(arbeit, "b.hfe")
    shutil.copyfile(bdisk, b)
    platte = os.path.join(arbeit, "platte.img.gz")
    shutil.copyfile(cpa.GIDE_PLATTE, platte)
    itr = os.path.join(arbeit, "itrace.txt")
    z = ['gscreen "A>" 300000000'] + ["logpoint 0x%04X" % a for a in list(range(0x110, 0x124)) + [0x130]]   # 0130H = first instruction of the ISR
    z += ["itrace " + itr, "keys ITEST\\r", "tb 0x0118", "g 400000000", "keys wxyz", 'gscreen "FERTIG" 600000000', "screen", "g 7000000", "screen", "itrace off", "q"]   # last screen: the BIOS clock back in the corner
    dbg = os.path.join(arbeit, "itest.dbg")
    open(dbg, "w").write("\n".join(z) + "\n")
    args = [cpa.emu.binary("k1520dbg"), "--em", "em256", "--laderom", "ul4", "--gide=0xD0", "--gide-image", platte, "--rw",
            sysd, "-b", b, "-x", dbg]
    r = subprocess.run(args, capture_output=True, text=True, errors="replace", timeout=300, stdin=subprocess.DEVNULL)
    log = r.stdout + r.stderr
    open(os.path.join(arbeit, "itest.log"), "w").write(log)
    return log, itr


def auswerten(log, itr):
    grenz = {}
    for m in re.finditer(r"^\[lp\] c(\d+)\s+0([0-9A-F]{3}):", log, re.M):
        grenz[int(m.group(2), 16) - 0x110] = int(m.group(1))
    if len(grenz) < 20:
        raise RuntimeError("only %d borders seen" % len(grenz))
    # every ISR entry from the log points (itrace alone misses some accepted INTs, see doc c1_7 section 3)
    zeiten = [int(m.group(1)) for m in re.finditer(r"^\[lp\] c(\d+)\s+0130:", log, re.M)]
    isr = "0130"
    gesehen = [int(m.group(1)) for m in (re.match(r"IT c(\d+) .* vec=FA ", ln) for ln in open(itr)) if m]
    def tabelle(n1, n2):    # two screen rows (10 words each) -> 20 words
        a = re.findall(r"^\s*\|%s: ([0-9A-F ]+)" % n1, log, re.M)[-1].split()
        b = re.findall(r"^\s*\|%s: ([0-9A-F ]+)" % n2, log, re.M)[-1].split()
        return [int(x, 16) for x in a + b]
    ticks = tabelle("T", "T2")
    b5 = tabelle("B5", "B52")
    out = []
    kal = (grenz[1] - grenz[0]) / 500.0            # measured machine cycles per tick
    kal5 = (grenz[1] - grenz[0]) / ((b5[1] - b5[0]) & 0xFFFF)   # ... per BIOS 5 ms tick
    for name, s, e, an in PHASEN:
        dauer = grenz[e] - grenz[s]
        zt = [t for t in zeiten if grenz[s] <= t <= grenz[e]]
        luecken = [b - a for a, b in zip(zt, zt[1:])]
        n = ticks[e] if an else 0
        zi = [t for t in gesehen if grenz[s] <= t <= grenz[e]]
        bios = (b5[e] - b5[s]) & 0xFFFF
        out.append(dict(itr=len(zi), bios=bios, bios_erw=dauer / kal5, name=name, dauer=dauer, ticks=n, ist=len(zt), erwartet=dauer / kal,
                        maxl=max(luecken) if luecken else 0, minl=min(luecken) if luecken else 0,
                        mittel=(sum(luecken) / len(luecken)) if luecken else 0))
    return grenz, isr, ticks, out


def main(argv):
    arbeit = argv[argv.index("--arbeit") + 1]
    bdisk = argv[argv.index("--b") + 1] if "--b" in argv else os.path.join(cpa.emu.emulator(), "disks", "a5120_16_MUTOS",
                                                                           "a5120_mutos8000_root_fm.hfe")
    try:
        log, itr = run(arbeit, bdisk)
    except cpa.Fehlt as e:
        print("SKIP:", e)
        return 77
    grenz, isr, ticks, out = auswerten(log, itr)
    print("cycles per tick (calibrated, phase P): %.1f (nominal %d)" % ((grenz[1] - grenz[0]) / 500.0, NOM))
    print("ISR at %s; borders (machine cycles): %s" % (isr, [grenz[i] for i in range(20)]))
    print("%-27s %10s %6s %6s %6s %8s %9s %9s %9s %7s %8s" % ("phase", "cycles", "ticks", "ISRs", "itrace", "expected", "max gap", "min gap", "mean gap", "BIOS5ms", "expected"))
    for o in out:
        print("%-27s %10d %6d %6d %6d %8.1f %9d %9d %9.0f %7d %8.1f" % (
            o["name"], o["dauer"], o["ticks"], o["ist"], o["itr"], o["erwartet"], o["maxl"], o["minl"], o["mittel"], o["bios"], o["bios_erw"]))
    ok = "FERTIG" in log
    print("screen: " + " | ".join(l.strip(" |") for l in log.splitlines() if re.match(r"\s*\|(CK|WERR|BIOS|T:)", l))[:600])
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
