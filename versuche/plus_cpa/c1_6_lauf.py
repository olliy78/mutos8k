#!/usr/bin/env python3
"""Host side of plan 48 C1.6: run RDTEST/WRTEST in the GIDE-CP/A and compare with the disk image (IMD sector dump).

  c1_6_lauf.py rd  NAME FIRST LAST [--arbeit DIR]   read tracks FIRST..LAST of NAME (root_fm|root_mfm|root_8x512) through the BIOS
  (analysis functions are used by doc/plus/cpa/c1_6_formate.md; see there)
Work folder default /tmp/mplus/c1_6.  Images are copies; the emulator is run with --rw only on the copies."""
import argparse
import os
import re
import shutil
import subprocess
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HIER))
sys.path.insert(0, os.path.join(REPO, "tools", "plus"))
sys.path.insert(0, os.path.join(REPO, "tools", "disks"))
import cpa  # noqa: E402
import emu  # noqa: E402
import m8k  # noqa: E402

MUTOS_DIR = os.path.join(cpa.EM_DIR and os.path.dirname(os.path.dirname(cpa.EM_DIR)) or "", "disks", "a5120_16_MUTOS")
SKEW = [1, 7, 13, 19, 25, 5, 11, 17, 23, 3, 9, 15, 21, 2, 8, 14, 20, 26, 6, 12, 18, 24, 4, 10, 16, 22]   # biosdpb.mac:374


def imd_ref(abbild, arbeit, neu=False):
    """{(cyl, head): {ID: bytes}} of a MUTOS disk image (DiskTool save-as .imd, read with m8k.imd_laden); neu: dump again."""
    imd = os.path.join(arbeit, os.path.basename(abbild) + ".imd")
    if neu and os.path.exists(imd):
        os.remove(imd)
    if not os.path.exists(imd):
        subprocess.run([emu.binary("k1520disktool"), "save-as", abbild, imd], check=True, capture_output=True)
    return {(c, h): {s["r"]: s["data"] for s in secs} for c, h, secs, _m in m8k.imd_laden(imd)}


def hole_raw(platte, name, ziel, lw="lw0"):
    """RAW.BIN from lw<N> (default lw0 = C:) of the GIDE image copy -> bytes."""
    os.makedirs(ziel, exist_ok=True)
    subprocess.run([emu.binary("k1520disktool"), "get", platte, lw + "/" + name, "--to", ziel], check=True, capture_output=True)
    with open(os.path.join(ziel, lw, name), "rb") as f:
        return f.read()


def takte_marken(log):
    """[(cycle, 'A'|'B')] of the logpoint lines at 0103/0104."""
    return [(int(m.group(1)), "A" if m.group(2) == "0103" else "B")
            for m in re.finditer(r"\[lp\] c(\d+)\s+(0103|0104):", log)]


INV = {i: r + 1 for r, i in enumerate(SKEW)}     # physical ID -> SETSEC record that the BIOS translates to it (data tracks)


def vergleiche(name, raw, ref, off=2):
    """Compare the RDTEST raw dump with the disk image: returns a dict of counts and first deviations.

    26x128 (root_fm, root_mfm): BIOS track t = cylinder, SPT 26; rule R1 (naive, SETSEC = ID) and R2 (SETSEC = ID for t < off,
    INV[ID] from track `off` on).  8x512 (root_8x512): SPT 36 (the BIOS assumes 9 x 512), cylinder 1..79,
    record (ID-1)*4+k+1 (k = 0..3 = 128-byte quarter of the 512-byte sector)."""
    erg = {}
    if name == "root_8x512":
        spt = 36
        ok = bad = 0
        erste = None
        for cyl in range(1, 80):
            for i in range(1, 9):
                for k in range(4):
                    r = (i - 1) * 4 + k + 1
                    o = (cyl * spt + r - 1) * 128
                    if raw[o:o + 128] == ref[(cyl, 0)][i][k * 128:(k + 1) * 128]:
                        ok += 1
                    else:
                        bad += 1
                        erste = erste or (cyl, i, k)
        erg["R"] = (ok, bad, erste)
        # cylinder 0 (26 x 128, boot track): the BIOS reads it with record = ID
        n0 = sum(raw[(r - 1) * 128:r * 128] == ref[(0, 0)][r] for r in range(1, 27))
        erg["Z0"] = (n0, 26 - n0, None)
        return erg
    spt = 26
    for regel in ("R1", "R2"):
        ok = bad = 0
        erste = None
        for cyl in range(0, len(raw) // (spt * 128)):
            for i in range(1, 27):
                r = i if (regel == "R1" or cyl < off) else INV[i]
                o = (cyl * spt + r - 1) * 128
                if raw[o:o + 128] == ref[(cyl, 0)][i]:
                    ok += 1
                else:
                    bad += 1
                    erste = erste or (cyl, i)
        erg[regel] = (ok, bad, erste)
    return erg


def je_spur(log):
    """Cycles per track from the logpoints MKA -> MKB (list of ints)."""
    m = takte_marken(log)
    return [b[0] - a[0] for a, b in zip(m, m[1:]) if a[1] == "A" and b[1] == "B"]


def lies(name, arbeit, erste, letzte, laufwerk="B", abbild=None, base=1, ausg="C", prog="rdtest", args=None, tag=None, platte=None, lw="lw0"):
    """Run RDTEST (or `prog` with the argument text `args`) in the guest on a copy of `abbild` (drive B:).

    Returns (RAW.BIN bytes from C:/D:, debugger log).  The program is built fresh (cpa.com) from versuche/plus_cpa."""
    arbeit = os.path.abspath(arbeit)
    sub = os.path.join(arbeit, (tag or "rd_" + name))
    shutil.rmtree(sub, ignore_errors=True)
    os.makedirs(sub)
    com = cpa.com(prog, HIER)
    sysd = cpa.diskette(sub, "sys.hfe", cpa.GIDE_SYS, {prog.upper() + ".COM": com})
    if platte:                          # prepared GIDE image copy (cpa.lauf_dbg keeps an existing one)
        shutil.copyfile(platte, os.path.join(sub, "platte.img.gz"))
    b = None
    if abbild:
        b = os.path.join(sub, "b.hfe")
        shutil.copyfile(abbild, b)
    z = ["logpoint 0x103", "logpoint 0x104"]
    args = args or "%s %d %d %d %s" % (laufwerk, erste, letzte, base, ausg)
    z += ["keys %s\\s%s\\r" % (prog.upper(), args.replace(" ", "\\s")),
          'gscreen "%s DONE" 4000000000' % prog.upper(), "screen"]
    log = cpa.lauf_dbg(sub, z, sysd, b=b, rw=True, name="rd", frist=3000)
    raw = hole_raw(os.path.join(sub, "platte.img.gz"), "RAW.BIN", os.path.join(sub, "out"), lw)
    return raw, log


# the 8 targets of wrtest.mac: (BIOS track, record); data tracks >= 3 of root_mfm, SETSEC record -> physical ID via SKEW
WR_ZIELE = [(3, 5), (10, 14), (20, 2), (30, 26), (40, 13), (50, 7), (60, 20), (70, 9)]


def muster(t, r):
    """The pattern wrtest.mac writes to record (t, r): byte i = (i + t + 3r + 5AH) mod 256."""
    return bytes((i + t + 3 * r + 0x5A) & 0xFF for i in range(128))


def schreibe(skript, arbeit, tag, leer=150000000, name="root_mfm"):
    """Run WRTEST on a copy of `name` (root_mfm or root_8x512, drive B:) with the command token `skript`, let the machine idle
    `leer` cycles, then quit.  Judged on the image file the emulator leaves behind (--rw on the copy), per 128-byte piece.

    Returns (log, {(t, r): 'muster'|'alt'|'anders'}, collateral changes [(cyl, ID, piece)])."""
    arbeit = os.path.abspath(arbeit)
    sub = os.path.join(arbeit, tag)
    shutil.rmtree(sub, ignore_errors=True)
    os.makedirs(sub)
    sysd = cpa.diskette(sub, "sys.hfe", cpa.GIDE_SYS, {"WRTEST.COM": cpa.com("wrtest", HIER)})
    quelle = os.path.join(MUTOS_DIR, "a5120_mutos8000_%s.hfe" % name)
    b = os.path.join(sub, "b.hfe")
    shutil.copyfile(quelle, b)
    z = ["keys WRTEST\\sB\\s%s\\r" % skript, 'gscreen "WRTEST DONE" 4000000000', "screen", "g %d" % leer, "screen"]
    log = cpa.lauf_dbg(sub, z, sysd, b=b, rw=True, name="wr", frist=3000)
    alt = imd_ref(quelle, arbeit)
    neu = imd_ref(b, sub, neu=True)

    def wo(t, r):                      # BIOS (track, record) -> (cyl, ID, 128-byte piece)
        if name == "root_8x512":
            return t, (r - 1) // 4 + 1, (r - 1) % 4
        return t, SKEW[r - 1], 0
    erg, ziel = {}, set()
    ziele = [(5, 9), (5, 10), (5, 11), (5, 12)] if skript in ("B", "b") else WR_ZIELE
    for t, r in ziele:
        c, i, k = wo(t, r)
        ziel.add((c, i, k))
        d = neu[(c, 0)][i][k * 128:(k + 1) * 128]
        erg[(t, r)] = "muster" if d == muster(t, r) else ("alt" if d == alt[(c, 0)][i][k * 128:(k + 1) * 128] else "anders")
    fremd = []
    for (c, h), secs in neu.items():
        for i, d in secs.items():
            for k in range(len(d) // 128):
                if (c, i, k) not in ziel and d[k * 128:(k + 1) * 128] != alt[(c, h)][i][k * 128:(k + 1) * 128]:
                    fremd.append((c, i, k))
    return log, erg, fremd


def schreibe_gide(skript, arbeit, tag, leer=150000000, laufwerk="D"):
    """WRTEST on a GIDE drive (default D: = lw1, head 1; SETSEC is 0-based there, the table targets r = 2..26 are fine).

    Judged on the .img.gz copy: CHS layout cyl = BIOS track, head = drive number - 2, sector = (r div 4) + 1, offset (r mod 4)*128,
    LBA = (cyl*16 + head)*63 + sector - 1 (measured: KNOWN.BIN at C: track 11).  Returns (log, {(t, r): 'muster'|'alt'|'anders'},
    number of 512-byte sectors that changed besides the target sectors)."""
    import gzip
    arbeit = os.path.abspath(arbeit)
    sub = os.path.join(arbeit, tag)
    shutil.rmtree(sub, ignore_errors=True)
    os.makedirs(sub)
    sysd = cpa.diskette(sub, "sys.hfe", cpa.GIDE_SYS, {"WRTEST.COM": cpa.com("wrtest", HIER)})
    platte = os.path.join(sub, "platte.img.gz")
    shutil.copyfile(cpa.GIDE_PLATTE, platte)
    z = ["keys WRTEST\\s%s\\s%s\\r" % (laufwerk, skript), 'gscreen "WRTEST DONE" 4000000000', "screen", "g %d" % leer, "screen"]
    log = cpa.lauf_dbg(sub, z, sysd, rw=True, name="wr", frist=3000)
    head = ord(laufwerk) - ord("C")

    def lba(t, r):
        return (t * 16 + head) * 63 + (r >> 2), (r & 3) * 128
    ziel = {lba(t, r)[0] for t, r in WR_ZIELE}
    erg = {}
    with gzip.open(platte, "rb") as neu, gzip.open(cpa.GIDE_PLATTE, "rb") as alt:
        for t, r in WR_ZIELE:
            l, o = lba(t, r)
            neu.seek(l * 512 + o)
            alt.seek(l * 512 + o)
            d, a = neu.read(128), alt.read(128)
            erg[(t, r)] = "muster" if d == muster(t, r) else ("alt" if d == a else "anders")
    fremd = 0
    with gzip.open(platte, "rb") as neu, gzip.open(cpa.GIDE_PLATTE, "rb") as alt:
        lb = 0
        while True:
            x, y = neu.read(1 << 20), alt.read(1 << 20)
            if not x and not y:
                break
            if x != y:
                for k in range(0, len(x), 512):
                    if x[k:k + 512] != y[k:k + 512] and (lb + k // 512) not in ziel:
                        fremd += 1
            lb += len(x) // 512
    return log, erg, fremd


def block_soll(name, ref, bn):
    """The 512 bytes of kernel block `bn` as mutos_io formula + image say (doc/plus/cpa/c1_4_inventar.md section 7)."""
    if name == "root_8x512":
        return ref[(bn // 8 + 1, 0)][bn % 8 + 1]
    out = b""
    for k in range(4):
        l = 4 * bn + k
        q, pos = divmod(l, 26)
        x = 2 * pos
        x = x + 1 if x >= 26 else x
        out += ref[(q + 1, 0)][(x + 6 * q) % 26 + 1]
    return out


def bloecke(name, raw, ref):
    """(blocks checked, blocks different, first different) of a BLKTEST dump (26 x 128: bn < 494 = cylinders 1..76)."""
    nb = min(len(raw) // 512, 632 if name == "root_8x512" else 494)
    bad = [b for b in range(nb) if raw[b * 512:(b + 1) * 512] != block_soll(name, ref, b)]
    return nb, len(bad), (bad[0] if bad else None)


def je_block(log, nb):
    """Cycles per 512-byte block for every complete chunk of 64 blocks (BLKTEST: MKA..MKB around a chunk)."""
    return [c / 64 for c in je_spur(log)][:nb // 64]


def _med(x):
    x = sorted(x)
    return x[len(x) // 2]


def alles(arbeit):
    """The whole measurement of C1.6 (about 15 min wall clock); prints the table, returns True when every expectation holds."""
    import collections
    arbeit = os.path.abspath(arbeit)
    os.makedirs(arbeit, exist_ok=True)
    gut = True
    zeilen = []
    nullspur = ""
    for name in ("root_fm", "root_mfm", "root_8x512"):
        abb = os.path.join(MUTOS_DIR, "a5120_mutos8000_%s.hfe" % name)
        ref = imd_ref(abb, arbeit)
        bis = 79 if name == "root_8x512" else 76
        raw, log = lies(name, arbeit, 0, bis, abbild=abb)
        v = vergleiche(name, raw, ref)
        gelesen = v["R2"] if "R2" in v else v["R"]
        raw, log = lies(name, arbeit, 0, 0, abbild=abb, prog="blktest", tag="blk_" + name,
                        args="B 0 %d %s" % (631 if name == "root_8x512" else 493, "5" if name == "root_8x512" else "2"))
        nb, schlecht, erst = bloecke(name, raw, ref)
        takte = _med(je_block(log, nb))
        sk = ("1", "0", "0X") + (("B",) if name == "root_8x512" else ())
        wr = {}
        for k in sk:
            _l, erg, fremd = schreibe(k, arbeit, "wr_%s_%s" % (name, k), leer=1, name=name)
            wr[k] = (collections.Counter(erg.values()), len(fremd))
        gut &= gelesen[1] == 0 and schlecht == 0 and wr["1"][0]["muster"] == 8 and wr["0X"][0]["muster"] == 8
        zeilen.append((name, gelesen, (nb, schlecht), takte, wr))
        if "Z0" in v:
            gut &= v["Z0"][1] == 0
            nullspur = "Zylinder 0 (26 x 128) von root_8x512: %d / 26 Saetze gleich (Satz = ID)" % v["Z0"][0]
    # GIDE: read the known file back, write targets
    import random
    sub = os.path.join(arbeit, "gide")
    os.makedirs(sub, exist_ok=True)
    rnd = random.Random(48)
    bekannt = bytes(rnd.getrandbits(8) for _ in range(200 * 1024))
    kp = os.path.join(sub, "KNOWN.BIN")
    with open(kp, "wb") as f:
        f.write(bekannt)
    plat = os.path.join(sub, "platte.img.gz")
    shutil.copyfile(cpa.GIDE_PLATTE, plat)
    subprocess.run([emu.binary("k1520disktool"), "put", plat, kp, "--as", "lw0/KNOWN.BIN"], check=True, capture_output=True)
    raw, log = lies("gide", arbeit, 2, 20, laufwerk="C", base=0, ausg="D", platte=plat, lw="lw1", tag="rd_gide")
    idx = {raw[i * 128:(i + 1) * 128]: i for i in range(len(raw) // 128)}
    pos = [idx.get(bekannt[n * 128:(n + 1) * 128]) for n in range(len(bekannt) // 128)]
    gef = [p for p in pos if p is not None]
    folge = all(b == a + 1 for a, b in zip(gef, gef[1:]))
    gtakte = _med(je_spur(log)) / 32          # 128 records = 32 blocks per track
    gw = {}
    for k in ("1", "0", "0X"):
        _l, erg, fremd = schreibe_gide(k, arbeit, "wrg_" + k, leer=1)
        gw[k] = (collections.Counter(erg.values()), fremd)
    gut &= len(gef) > 0 and folge and gw["1"][0]["muster"] == 8
    print("%-11s %-26s %-26s %-18s  %s" % ("Format", "gelesen gleich (Saetze)", "Bloecke (Formel)", "Takte/512 B", "geschrieben (WRITE C=1 / C=0 / C=0+X)"))
    for name, g, b, t, wr in zeilen:
        print("%-11s %5d / %-5d %-12s %4d / %-4d %-12s %9d       %s" % (
            name, g[0], g[0] + g[1], "ja" if g[1] == 0 else "NEIN", b[0] - b[1], b[0], "ja" if b[1] == 0 else "NEIN", t,
            " | ".join("%s: %s%s" % (k, dict(c), " fremd=%d" % f if f else "") for k, (c, f) in wr.items())))
    print("%-11s %5d / %-5d %-12s %-26s %9d       %s" % (
        "GIDE D:", len(gef), len(pos) - sum(p is None for p in pos[len(gef):]) if False else len(gef), "ja" if folge else "NEIN", "(Datei KNOWN.BIN, Spur 11 ff.)",
        gtakte, " | ".join("%s: %s%s" % (k, dict(c), " fremd=%d" % f if f else "") for k, (c, f) in gw.items())))
    print(nullspur)
    return gut


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=["alles"])
    ap.add_argument("--arbeit", default="/tmp/mplus/c1_6")
    a = ap.parse_args()
    if cpa.fehlt(True):
        print("SKIP: emulator / CP/M tool chain missing")
        sys.exit(77)
    sys.exit(0 if alles(a.arbeit) else 1)
