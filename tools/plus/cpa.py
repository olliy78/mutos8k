#!/usr/bin/env python3
"""Probe tool for the GIDE-CP/A under the emulator (plan 48 C1.1); stdlib only.

Everything here runs the emulator (k1520dbg) with the A5120.16 (EM256) and the GIDE-CP/A boot disk, types commands
at the CP/A prompt and returns the screen text.  Exit 77 (skip) when the emulator or the M80/LINKMT tool chain is missing.

API (all paths absolute; the work folder `arbeit` is created, nothing outside it is written):
  GIDE_SYS, GIDE_PLATTE, CPA_SYS, EM_DIR   paths in the emulator project (None when it is missing)
  fehlt(), Fehlt                           True / exception when emulator (or tool chain with werkzeug=True) is missing
  diskette(arbeit, name, quelle=GIDE_SYS, dateien={})   copy of a disk image in `arbeit`, files {'NAME.EXT': bytes} put into it
  com(name, quellordner)                   build <quellordner>/<name>.mac with M80 + LINKMT (0100H) -> bytes of the .COM
  lauf(arbeit, zeilen, a, b=None, c=None, d=None, laufwerke=None, em='em256', gide=True, frist=120)
                                           run the emulator; returns the debugger log (str)
  cmd(text, warte=None, takte=8_000_000)   step: type `text` + CR, wait for screen text `warte` (else run `takte` cycles)
  taste(zeichen='\\s', warte=None, ...)     step: press one key (page prompts of the em256 programs)
  schirm(log), schirme(log)                last / all `screen` blocks (list of 24 lines, frame stripped)
  probe(arbeit)                            the acceptance run of C1.1 (also: cpa.py probe --arbeit DIR)
"""
import argparse
import contextlib
import gzip
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HIER))
import emu  # noqa: E402

SKIP = 77
REPO = emu.repo()


class Fehlt(Exception):
    """Emulator or tool chain not available (callers exit 77 / skip)."""


def _emu_pfad(*teile):
    e = emu.emulator()
    return os.path.join(e, *teile) if e else None


GIDE_SYS = _emu_pfad("disks", "a5120_cpa_gide", "a5120_cpa_gide_k7024_2fdd_8gide_system.hfe")
GIDE_PLATTE = _emu_pfad("disks", "a5120_cpa_gide", "a5120_cpa_gide_platte_256M.img.gz")
CPA_SYS = _emu_pfad("disks", "a5120_cpa", "a5120_cpa_k5601_system.hfe")     # plain CP/A (no GIDE), reference
EM_DIR = _emu_pfad("tools", "em256")


def fehlt(werkzeug=False):
    """True when the emulator (and with werkzeug=True the M80/LINKMT chain) is missing."""
    if emu.fehlt() or not (GIDE_SYS and os.path.isfile(GIDE_SYS)):
        return True
    return werkzeug and not emu.cpm_bau().werkzeugkette_da()


def _need(werkzeug=False):
    if fehlt(werkzeug):
        raise Fehlt("emulator%s not available" % (" / CP/M tool chain (CPA_TOOLS)" if werkzeug else ""))


def diskette(arbeit, name, quelle=None, dateien=None):
    """Copy `quelle` (default GIDE_SYS) to arbeit/name and put `dateien` {'NAME.EXT': bytes} into it.  Returns the path."""
    _need()
    quelle = quelle or GIDE_SYS
    os.makedirs(arbeit, exist_ok=True)
    ziel = os.path.join(arbeit, name)
    shutil.copyfile(quelle, ziel)
    if dateien:
        with tempfile.TemporaryDirectory(prefix="cpa_put_") as t:
            pfade = []
            for n, b in dateien.items():
                p = os.path.join(t, n.lower())      # the DiskTool upper-cases the CP/M name
                with open(p, "wb") as f:
                    f.write(b)
                pfade.append(p)
            dt = emu.binary("k1520disktool")
            # the DiskTool refuses to overwrite: remove same-named files first (a missing file is no error)
            subprocess.run([dt, "rm", ziel] + [n.upper() for n in dateien], capture_output=True)
            r = subprocess.run([dt, "put", ziel] + pfade, capture_output=True, text=True)
            if r.returncode != 0:
                raise RuntimeError("disktool put failed: " + r.stdout + r.stderr)
    return ziel


def _prog(name, ordner):
    """cpm_bau.Programm with the source directly in `ordner` (not in ordner/src); class made lazily (needs the emulator)."""
    class Prog(emu.cpm_bau().Programm):
        @property
        def quelle(self):
            return os.path.join(self.ordner, "%s.mac" % self.name)
    return Prog(name, ordner)


def com(name, quellordner, meldungen=None):
    """Build <quellordner>/<name>.mac with the emulator's cpm_bau (M80, LINKMT at 0100H); returns the .COM bytes.

    The tool output goes to the list `meldungen` (lines) when given, else is dropped.  RuntimeError when M80/LINKMT fail."""
    _need(True)
    cb = emu.cpm_bau()
    p = _prog(name, os.path.abspath(quellordner))
    with tempfile.TemporaryDirectory(prefix="cpa_com_") as t:
        ziel = os.path.join(t, name + ".com")
        buf = io.StringIO()
        try:
            with contextlib.redirect_stdout(buf):
                cb.baue(p, os.path.join(t, "build"), ziel)
        finally:
            if meldungen is not None:
                meldungen.extend(buf.getvalue().splitlines())
        with open(ziel, "rb") as f:
            return f.read()


def cmd(text, warte=None, takte=8000000):
    return ("keys", text.replace(" ", "\\s") + "\\r", warte, takte)


def taste(zeichen="\\s", warte=None, takte=20000000):
    return ("keys", zeichen, warte, takte)


def lauf(arbeit, zeilen, a, b=None, c=None, d=None, laufwerke=None, em="em256", gide=True, frist=120):
    """Boot CP/A in the emulator, run the steps `zeilen` (str = cmd(str), or tuples from cmd()/taste()) and return the log.

    a, b, c, d: disk images (paths; use diskette() so that the originals stay untouched).  gide=True adds
    `--laderom ul4 --gide=0xD0 --gide-image <copy of the 256 MB GIDE disk .gz>`; gide=False is the plain CP/A (reference).
    After every step the screen is dumped (`screen`).  frist: wall-clock limit in seconds."""
    _need()
    os.makedirs(arbeit, exist_ok=True)
    z = []
    if not gide:
        # the plain CP/A (no RTC) asks for the time at boot: accept the proposal with CR
        z += ['gscreen "HH:MM:SS" 300000000', "g 3000000", "keys \\r"]
    z += ['gscreen "A>" 300000000', "screen"]
    for s in zeilen:
        if isinstance(s, str):
            s = cmd(s)
        _, text, warte, takte = s
        z.append("keys " + text)
        z.append('gscreen "%s" %d' % (warte, takte * 20) if warte else "g %d" % takte)
        z.append("screen")
    z.append("q")
    dbg = os.path.join(arbeit, "lauf.dbg")
    with open(dbg, "w") as f:
        f.write("# generated by tools/plus/cpa.py -- do not edit by hand\n" + "\n".join(z) + "\n")
    args = [emu.binary("k1520dbg"), "--em", em]
    if gide:
        platte = os.path.join(arbeit, "platte.img.gz")
        shutil.copyfile(GIDE_PLATTE, platte)
        args += ["--laderom", "ul4", "--gide=0xD0", "--gide-image", platte]
    if laufwerke:
        args += ["--laufwerke", laufwerke]
    args += [a]
    for opt, img in (("-b", b), ("-c", c), ("-d", d)):
        if img:
            args += [opt, img]
    args += ["-x", dbg]
    r = subprocess.run(args, capture_output=True, text=True, errors="replace", timeout=frist, stdin=subprocess.DEVNULL)
    log = r.stdout + r.stderr
    with open(os.path.join(arbeit, "lauf.log"), "w") as f:
        f.write(log)
    return log


def schirme(log):
    """All `screen` blocks of a debugger log: list of lists of 24 text lines (frame '|' removed, right side stripped)."""
    bloecke, cur = [], None
    for ln in log.splitlines():
        if ln.startswith("(dbg) screen"):
            cur = []
            bloecke.append(cur)
        elif cur is not None and ln.startswith("  |"):
            cur.append(ln[3:].rstrip().rstrip("|").rstrip())
        elif cur is not None and ln.startswith("(dbg)"):
            cur = None
    return bloecke


def schirm(log):
    """The last screen block as text (empty string when none)."""
    b = schirme(log)
    return "\n".join(b[-1]) if b else ""


def _alles(log):
    return "\n".join("\n".join(b) for b in schirme(log))


def _ok(zeile, bedingung, bericht):
    bericht.append("%s  %s" % ("OK    " if bedingung else "FEHLER", zeile))
    return bool(bedingung)


def _ergebnis(log):
    """The text after 'ERGEBNIS' of a em256 test program (None when absent)."""
    m = re.findall(r"ERGEBNIS:?([^\n]*)", _alles(log))
    return m[-1].strip() if m else None


def probe(arbeit):
    """Acceptance run of C1.1; returns (all ok, report lines)."""
    _need(True)
    arbeit = os.path.abspath(arbeit)
    os.makedirs(arbeit, exist_ok=True)
    rep, ok = [], True
    # 1. HALLO.COM (BDOS 9) + M80 name length (two labels that differ only in the 7th character)
    meld = []
    hallo = com("hallo", os.path.join(REPO, "versuche", "plus_cpa"), meld)
    rep += ["M80/LINKMT: " + l.strip() for l in meld if "rror" in l or "FERTIG" in l]
    sysd = diskette(arbeit, "sys.hfe", GIDE_SYS, {"HALLO.COM": hallo})
    log = lauf(arbeit, [cmd("HALLO", "LONGNAME-TWO")], sysd)
    txt = _alles(log)
    kopf = "GIDE-CP/A" in txt and "RTC 72421" in txt
    ok &= _ok("header GIDE-CP/A + RTC 72421 on screen", kopf, rep)
    ok &= _ok("HALLO MUTOS printed", "HALLO MUTOS" in txt, rep)
    ok &= _ok("labels differing in the 7th char stay distinct (LONGNAME-ONE and -TWO)",
              "LONGNAME-ONE" in txt and "LONGNAME-TWO" in txt, rep)
    # 2. EM16ABL / EM256ADR under GIDE-CP/A and under plain CP/A
    erg = {}
    for titel, gide, quelle in (("GIDE-CP/A", True, GIDE_SYS), ("plain CP/A", False, CPA_SYS)):
        if not (quelle and os.path.isfile(quelle)):
            rep.append("SKIP    %s: boot disk missing" % titel)
            continue
        sub = os.path.join(arbeit, "gide" if gide else "plain")
        dsk = diskette(sub, "sys.hfe", quelle, {n.upper() + ".COM": open(os.path.join(EM_DIR, n + ".com"), "rb").read()
                                                 for n in ("em16abl", "em256adr")})
        # page prompts ("weiter mit Taste") eat one key each: press space until the result line is there
        schritte = [cmd("EM256ADR", "weiter mit Taste"), taste(), cmd("EM16ABL", "weiter mit Taste"), taste(), taste()]
        lg = lauf(sub, schritte, dsk, gide=gide)
        t = _alles(lg)
        adr = re.findall(r"=> Basis A8H:[^\n]*", t)
        abl = re.findall(r"ERGEBNIS: alle Ablaeufe[^\n]*", t)
        erg[titel] = (adr[-1] if adr else None, abl[-1] if abl else None)
        ok &= _ok("%s: EM256ADR '%s'" % (titel, erg[titel][0]), erg[titel][0] is not None, rep)
        ok &= _ok("%s: EM16ABL '%s'" % (titel, erg[titel][1]), erg[titel][1] is not None, rep)
    if len(erg) == 2:
        ok &= _ok("EM256ADR/EM16ABL result identical under GIDE-CP/A and plain CP/A", erg["GIDE-CP/A"] == erg["plain CP/A"], rep)
    return ok, rep


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sp = ap.add_subparsers(dest="cmd", required=True)
    p = sp.add_parser("probe", help="C1.1 acceptance run")
    p.add_argument("--arbeit", required=True, help="work folder, e.g. /tmp/mplus/c1_1")
    a = ap.parse_args(argv)
    if a.cmd == "probe":
        try:
            ok, rep = probe(a.arbeit)
        except Fehlt as e:
            print("SKIP:", e)
            return SKIP
        print("\n".join(rep))
        print("PROBE", "OK" if ok else "FAILED")
        return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
