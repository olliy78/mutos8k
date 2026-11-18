"""Guard for mutos_io/cpa/src/mutoscpa.mac (plan 48 chain C3.1 -> C4.1).

C3.1 (fast): ASCII only; none of the internal addresses (A lines of doc/plus/cpa/c1_4_inventar.md
section 3) appears as a number outside EQU lines.
C3.2 (fast): none of the UDOS dependencies replaced by the BIOS (console, [0003H], raw floppy, RST 38H,
UDOS vector slots) is left in the code; the stack lies in B936H..C8B5H.
C3.2 (`gast`, ~2 min): boot disk -> M8KBOOT -> mask -> r -> first kernel message, ticks, vectors, stack depth.
C3.3 (fast): no UDOS disk path (0BFDH, nucleus request block, callbacks) any more, the BIOS disk calls are used.
C3.3 (`gast`, ~2 min): boot to `login:` with root_mfm and root_8x512 in C:, no disk error, ticks keep running.
"""
import os
import re
import sys

import pytest

from conftest import PROJECT_ROOT

SRC = PROJECT_ROOT / "mutos_io" / "cpa" / "src" / "mutoscpa.mac"
DBG = PROJECT_ROOT / "versuche" / "dbg"
sys.path.insert(0, str(PROJECT_ROOT / "tools"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "kernel"))
import emu  # noqa: E402

# .PHASE bases, message copy, initial stack, DCB/AUF buffer pointers (as bytes of the pair)
A_NUMBERS = ["9000H", "9400H", "0A400H", "0C8B6H", "0A5A8H", "0A5A9H", "0CB68H",
             "0A8B6H", "0A7B6H", "0B8B6H", "0A5B6H", "0A636H", "0A6B6H", "0A736H"]
A_BYTE_PAIRS = re.compile(r"\bDB\b[^;\n]*\b(0B6H|36H),(0A[5-8]H|0B8H)\b", re.I)

# C3.2: UDOS entries and fixed addresses that must not occur any more in code (comments are not code)
UDOS_GONE = [r"\b0BEBH\b", r"\b0BF1H\b", r"\b0BE8H\b", r"\b0FF60H\b", r"\(0003H\)", r"\b01B5H\b", r"\b01B6H\b",
             r"\b01B8H\b", r"\b01BAH\b", r"\bRST\s+38H\b", r"\b0FE2H\b", r"\b0FEAH\b", r"\b0FECH\b",
             r"\b0F3[0-9A-F]H\b", r"\(1CH\)"]
# C3.3: the UDOS disk path (nucleus call 0BFDH, request block, callbacks) is gone
DISK_GONE = [r"\b0BFDH\b", r"\bBLOCK_START\b", r"\bBLOCK_RUECKRUF\b", r"\bBR_ABBRUCH\b", r"\bBR_FERTIG\b", r"\bSEKTOR_WEITER\b",
             r"\bSEKTOR_BERECHNEN\b", r"\bV_RUECKRUF_OK\b", r"\bV_RUECKRUF_ERR\b", r"\bNUK_AUFTRAG\b", r"\bV_BUSY\b",
             r"\bPLATTE_FERTIG\b", r"\bNUKLEUS_INIT\b", r"\b996EH\b"]


def _code_lines():
    for n, ln in enumerate(SRC.read_text(encoding="ascii").splitlines(), 1):
        code = ln.split(";", 1)[0]
        if re.match(r"^\w+\s+EQU\b", code):
            continue
        yield n, code


def test_quelle_ascii():
    SRC.read_bytes().decode("ascii")


def test_keine_a_zahlen_ausser_equ():
    bad = [(n, c) for n, c in _code_lines()
           if any(re.search(r"\b%s\b" % z, c, re.I) for z in A_NUMBERS) or A_BYTE_PAIRS.search(c)]
    assert not bad, bad


def test_keine_udos_abhaengigkeit_c3_2():
    bad = [(n, c.strip()) for n, c in _code_lines() if any(re.search(p, c, re.I) for p in UDOS_GONE)]
    assert not bad, bad


def test_keine_udos_platte_c3_3():
    bad = [(n, c.strip()) for n, c in _code_lines() if any(re.search(p, c, re.I) for p in DISK_GONE)]
    assert not bad, bad


def test_platte_ruft_bios_c3_3():
    """PLATTE uses the six standard BIOS entries through the own jump list and the CP/A record rules of c1_6."""
    code = "\n".join(c for _, c in _code_lines())
    for call in ("B_SELDSK", "B_SETTRK", "B_SETSEC", "B_SETDMA", "B_READ", "B_WRITE"):
        assert re.search(r"CALL\s+%s\b" % call, code), call
    assert re.search(r"^TAB_RK_CPA:", code, re.M)
    assert re.search(r"^INVT:", code, re.M)
    # the inverse CP/A skew table (c1_6 section 4), 26 entries
    m = re.search(r"^INVT:\s*DB\s+([0-9,]+)", code, re.M)
    assert m and [int(x) for x in m.group(1).split(",")] == [1, 14, 10, 23, 6, 19, 2, 15, 11, 24, 7, 20, 3, 16, 12, 25, 8, 21, 4, 17, 13, 26, 9, 22, 5, 18]


def test_stapel_unter_c8b6():
    t = SRC.read_text(encoding="ascii")
    assert re.search(r"^INITSP\s+EQU\s+SEG4_BASE\b", t, re.M)
    assert re.search(r"^STKBOT\s+EQU\s+0B936H\b", t, re.M)
    assert re.search(r"^INTVEC\s+EQU\s+0F700H\b", t, re.M)
    assert re.search(r"^SEG4_BASE\s+EQU\s+0C8B6H\b", t, re.M)


# ---------------------------------------------------------------- guest part (C3.2)

def _symbole():
    """(symbols {name: address}, address of the first instruction after CALL MASKE) from the M80 listing."""
    import shutil
    import subprocess
    import tempfile
    cpm_bau = emu.cpm_bau()
    with tempfile.TemporaryDirectory(prefix="mutoscpa_lst_") as tmp:
        text = SRC.read_text(encoding="ascii").replace("\r\n", "\n").replace("\n", "\r\n")
        with open(os.path.join(tmp, "MUTOSIO.MAC"), "wb") as f:
            f.write(text.encode("ascii"))
        shutil.copy2(os.path.join(cpm_bau.CPA_TOOLS, "m80.com"), tmp)
        subprocess.run([cpm_bau._cparun(), "m80", "MUTOSIO,MUTOSIO=MUTOSIO"], cwd=tmp, capture_output=True, timeout=60)
        prn = [f for f in os.listdir(tmp) if f.lower() == "mutosio.prn"]
        assert prn, "M80 produced no listing"
        lst = open(os.path.join(tmp, prn[0]), errors="replace").read()
    sym = {n: int(w, 16) for w, n in re.findall(r"([0-9A-F]{4})\s+\t?([A-Z0-9_]+)", lst)}
    m = re.search(r"^\s*([0-9A-F]{4})\s+CD [0-9A-F]{4}\s+CALL MASKE\b", lst, re.M)
    assert m, "CALL MASKE not found in the listing"
    return sym, int(m.group(1), 16) + 3


def _skript(datei, **ers):
    t = (DBG / datei).read_text()
    for k, v in ers.items():
        t = t.replace("@%s@" % k, str(v))
    return [ln for ln in t.splitlines() if ln.strip() and not ln.startswith("#")]


def _bytes_hinter(log, befehl, n=1, nach=0):
    """The first `n` bytes of the hex dump printed after the debugger command line `befehl` (None when absent)."""
    i = log.find("(dbg) " + befehl, nach)
    if i < 0:
        return None
    out = []
    for ln in log[i:].splitlines()[1:]:
        m = re.match(r"\s*(?:em:)?[0-9A-F]{4,5}:?\s+((?:[0-9A-F]{2} )+)", ln)
        if not m:
            break
        out += [int(x, 16) for x in m.group(1).split()]
        if len(out) >= n:
            break
    return out[:n] or None


def _boot_und_lauf(arbeit, skriptname, **ers):
    import cpa
    import cpa_disk
    os.makedirs(arbeit, exist_ok=True)
    platte = cpa_disk.bootdiskette(arbeit)
    b, c, d = (cpa.diskette(arbeit, n + ".hfe", cpa.GIDE_SYS) for n in "bcd")
    zeilen = _skript(skriptname, ARBEIT=arbeit, **ers)
    return cpa.lauf_dbg(arbeit, zeilen, platte, b, c, d, laufwerke=cpa_disk.LAUFWERKE, name=skriptname[:-4])


def _tiefste_adresse(pfad, basis=0xB936):
    """Lowest address in the painted stack area that is no longer E5H (None: untouched)."""
    d = open(pfad, "rb").read()
    benutzt = [i for i, b in enumerate(d) if b != 0xE5]
    return basis + min(benutzt) if benutzt else None


@pytest.mark.gast
def test_start_maske_kernel(tmp_path):
    import cpa
    import cpa_disk
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    arbeit = os.environ.get("MPLUS_ARBEIT") or str(tmp_path)
    sym, call_init = _symbole()
    stklen = 0xC8B6 - 0xB936
    log = _boot_und_lauf(arbeit, "cpa_c3_2_start.dbg", CALL_INIT="0x%04X" % call_init, ISR_TAKT="0x%04X" % sym["ISR_TAKT"],
                         ISR_ANFR="0x%04X" % sym["ISR_ANFRAGE"], STKLEN=stklen)
    scr = cpa._alles(log)
    schirme = cpa.schirme(log)
    # probe 1: the mask on the screen (BIOS CONOUT), "r" accepted, run stopped right after CALL MASKE
    assert "floppy - drive......:   0   1   2   3" in "\n".join(schirme[0]), "mask not on the screen"
    assert "mutos  - rk.........:   0   1   2   3" in "\n".join(schirme[0])
    assert re.search(r"bp ZVE1.*PC=%04X|PC=%04X" % (call_init, call_init), log), "no stop after CALL MASKE"
    # kernel: first message like the UDOS boot (since C3.3 the disk path is real, the stub error is no longer expected)
    assert "mem = 196608" in scr
    # registers: I = F7, IM 2
    assert "I=F7 IM=2" in log
    # vector slots (bytes at F7E8..F7FF): EA -> ISR_ANFRAGE, EC -> ISR_PARITAET, FA -> ISR_TAKT
    v = _bytes_hinter(log, "d 0xF7E8 0x18", 0x18)
    assert v and len(v) >= 0x18, v
    w = lambda off: v[off - 0xE8] + 256 * v[off - 0xE8 + 1]
    assert w(0xEA) == sym["ISR_ANFRAGE"] and w(0xEC) == sym["ISR_PARITAET"] and w(0xFA) == sym["ISR_TAKT"], v
    assert w(0xE8) != 0 and w(0xFC) != 0 and w(0xFE) != 0, "BIOS vectors (floppy index, 5 ms, 1 s) must stay"
    # BIOS clock keeps running (0050H..0052H, BCD HH MM SS): the two readings differ
    u1 = _bytes_hinter(log, "d 0x0050 3", 3)
    u2 = _bytes_hinter(log, "d 0x0050 3", 3, log.find("(dbg) mark"))
    assert u1 and u2 and u1 != u2, (u1, u2)
    # ticks and requests (logpoints)
    takt = [int(m.group(1)) for m in re.finditer(r"\[lp\] \+(\d+)\s+%04X:" % sym["ISR_TAKT"], log)]
    anfr = re.findall(r"\[lp\] \+(\d+)\s+%04X:" % sym["ISR_ANFRAGE"], log)
    assert len(anfr) >= 1, "no ISR_ANFRAGE"
    assert len(takt) >= 100, len(takt)
    luecken = [b - a for a, b in zip(takt, takt[1:])]
    mittel = sum(luecken) / len(luecken)
    assert 49000 < mittel < 49500, mittel            # c1_7: 49 249 cycles per tick
    # a lost tick would show as a gap of ~2 periods; since C3.3 the kernel reads the disk here, so single ticks may be late (DI sections of MELDEN)
    assert max(luecken) < 49152 * 1.5, max(luecken)
    # stack: never below B936H (area intact at its low end), depth reported by the test run
    ende = _tiefste_adresse(os.path.join(arbeit, "stack_end.bin"))
    assert ende is None or ende >= 0xB936 + 0x100, hex(ende)
    assert ende is not None and ende > 0xC000, hex(ende)       # the stack is really used, and only slightly


@pytest.mark.gast
def test_fatal_i(tmp_path):
    import cpa
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    arbeit = os.environ.get("MPLUS_ARBEIT_FATAL") or str(tmp_path)
    log = _boot_und_lauf(arbeit, "cpa_c3_2_fatal.dbg")
    assert "mutoscpa: fatal error I" in cpa._alles(log)


# ---------------------------------------------------------------- C3.3: disk path through the BIOS

def _platten(arbeit, root):
    """Disk copies in `arbeit` for the guest: tmp.hfe (empty /tmp), usr.hfe, root.hfe (copy of `root`), d0.hfe (empty /mnt)."""
    import shutil
    import gast_as
    for n in ("tmp.hfe", "d0.hfe"):
        p = os.path.join(arbeit, n)
        if os.path.exists(p):
            os.remove(p)
        rc, o = gast_as._lauf([gast_as.disktool(), "create", p, "--fs", "mutos8k_26x128_mfm", "--inodes", "200"])
        assert rc == 0, o
    shutil.copyfile(gast_as.disk("a5120_mutos8000_usr_mfm.hfe"), os.path.join(arbeit, "usr.hfe"))
    shutil.copyfile(gast_as.disk(root), os.path.join(arbeit, "root.hfe"))


def _c33_boot(arbeit, root="a5120_mutos8000_root_mfm.hfe", frist=300000000, rw=False):
    """Boot MUTOS through mutoscpa to `login:` with the disks of gast_as.PLATTEN; returns (log, symbols).  rw=True: writes reach the disk copies."""
    import cpa
    import cpa_disk
    os.makedirs(arbeit, exist_ok=True)
    _platten(arbeit, root)
    sym, _ = _symbole()
    platte = cpa_disk.bootdiskette(arbeit)
    zeilen = _skript("cpa_c3_3_boot.dbg", ARBEIT=arbeit, ISR_TAKT="0x%04X" % sym["ISR_TAKT"], ISR_ANFR="0x%04X" % sym["ISR_ANFRAGE"],
                     B_READ="0x%04X" % sym["B_READ"], B_WRITE="0x%04X" % sym["B_WRITE"], PL_ERG="0x%04X" % sym["PL_ERG"],
                     PL_FEHLER="0x%04X" % sym["PL_FEHLER"], STKLEN=0xC8B6 - 0xB936, FRIST=frist)
    log = cpa.lauf_dbg(arbeit, zeilen, platte, laufwerke=cpa_disk.LAUFWERKE, rw=rw, frist=3600, name="cpa_c3_3_boot")
    return log, sym


def _zaehler(log, adresse):
    return len(re.findall(r"\[lp\] \+\d+\s+%04X:" % adresse, log))


@pytest.mark.gast
@pytest.mark.parametrize("root", ["a5120_mutos8000_root_mfm.hfe", "a5120_mutos8000_root_8x512.hfe"])
def test_boot_bis_login_c3_3(tmp_path, root):
    """Boot to `login:` with the root disk in C: (A = empty /tmp, B = /usr, D = empty /mnt): no disk error, ticks keep running."""
    import cpa
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    basis = os.environ.get("MPLUS_ARBEIT")
    arbeit = os.path.join(basis, "c3_3_" + root.split("_")[-1][:-4]) if basis else str(tmp_path)
    log, sym = _c33_boot(arbeit, root)
    scr = cpa._alles(log)
    assert re.search(r"login:", scr), "no login: on the screen"
    assert "mem = 196608" in scr and "err on dev" not in scr and "panic" not in scr
    assert _zaehler(log, sym["PL_FEHLER"]) == 0, "disk error branch hit"
    assert _zaehler(log, sym["B_READ"]) >= 100
    takt = [int(m.group(1)) for m in re.finditer(r"\[lp\] \+(\d+)\s+%04X:" % sym["ISR_TAKT"], log)]
    assert len(takt) >= 100
    luecken = [b - a for a, b in zip(takt, takt[1:])]
    mittel = sum(luecken) / len(luecken)
    assert 49000 < mittel < 49500, mittel
    assert max(luecken) < 1.5 * mittel, max(luecken)           # no tick lost (late ticks of the console/report DI sections allowed)
    ende = _tiefste_adresse(os.path.join(arbeit, "stack_end.bin"))
    assert ende is not None and ende > 0xC000, hex(ende or 0)   # stack used, and only slightly (measured C888H)
