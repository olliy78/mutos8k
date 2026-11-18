"""Guard for mutos_io/cpa/src/mutoscpa.mac (plan 48 chain C3.1 -> C4.1).

C3.1 (fast): ASCII only; none of the internal addresses (A lines of doc/plus/cpa/c1_4_inventar.md
section 3) appears as a number outside EQU lines.
C3.2 (fast): none of the UDOS dependencies replaced by the BIOS (console, [0003H], raw floppy, RST 38H,
UDOS vector slots) is left in the code; the stack lies in B936H..C8B5H.
C3.2 (`gast`, ~2 min): boot disk -> M8KBOOT -> mask -> r -> first kernel message, ticks, vectors, stack depth.
C3.3 (fast): no UDOS disk path (0BFDH, nucleus request block, callbacks) any more, the BIOS disk calls are used.
C3.3 (`gast`, ~2 min): boot to `login:` with root_mfm and root_8x512 in C:, no disk error, ticks keep running.
C3.4 (fast): the keyboard comes through BIOS CONST/CONIN in ISR_TAKT, nothing reads 5CH/5DH any more.
C3.4 (`gast`, ~10 min each): operation run (login, ls -l /, writes, control keys, 200 keys under load), second run reads the files back,
disk change in operation.
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


# ---------------------------------------------------------------- C3.4: keyboard through the BIOS, operation, disk change

def test_tastatur_ueber_bios_c3_4():
    """No IN from 5CH/5DH (only SIGNALTON writes 5CH); ISR_TAKT takes keys through TASTE_BIOS = BIOS CONST/CONIN."""
    code = "\n".join(c for _, c in _code_lines())
    assert not re.search(r"\bIN\s+\w,\s*\((5CH|5DH|0?5CH|0?5DH)\)", code, re.I)
    assert not re.search(r"\b(TASTE_LESEN|TAB_TASTE)\b", code)
    assert re.search(r"CALL\s+TASTE_ZWISCHEN\b", code) and re.search(r"^V_VERLUST:", code, re.M)
    m = re.search(r"^ISR_TAKT:(.*?)^IT_ENDE:", code, re.M | re.S)
    assert m and re.search(r"CALL\s+TASTE_BIOS\b", m.group(1)) and "QUEUE_PUSH" in m.group(1)
    m = re.search(r"^TASTE_BIOS:(.*?)\bRET\b", code, re.M | re.S)
    assert m and "B_CONST" in m.group(1) and "B_CONIN" in m.group(1) and "PUSH IY" in m.group(1)


def _folge():
    """The 200-character key sequence (all characters of the guest scripts) as five pieces of 40; (keys-text, file text)."""
    alpha = "abcdefghijklmnopqrstuvwxyz0123456789 /.-;><|&=:*$_'\""
    s = "".join(alpha[(i * 7) % len(alpha)] for i in range(200))
    assert set(s) == set(alpha)
    stuecke = [s[i:i + 40] for i in range(0, 200, 40)]
    return [x.replace(" ", "\\s") for x in stuecke], "".join(x + "\n" for x in stuecke)


def _c34_platten(arbeit):
    """tmp.hfe (empty /tmp), usr.hfe, root.hfe (root_mfm), d0.hfe = copy of the cmd disk (/mnt): all copies in `arbeit`."""
    import shutil
    import gast_as
    os.makedirs(arbeit, exist_ok=True)
    p = os.path.join(arbeit, "tmp.hfe")
    if os.path.exists(p):
        os.remove(p)
    rc, o = gast_as._lauf([gast_as.disktool(), "create", p, "--fs", "mutos8k_26x128_mfm", "--inodes", "200"])
    assert rc == 0, o
    shutil.copyfile(gast_as.disk("a5120_mutos8000_usr_mfm.hfe"), os.path.join(arbeit, "usr.hfe"))
    shutil.copyfile(gast_as.disk("a5120_mutos8000_root_mfm.hfe"), os.path.join(arbeit, "root.hfe"))
    shutil.copyfile(gast_as.disk("a5120_mutos8000_cmd_mfm.hfe"), os.path.join(arbeit, "d0.hfe"))


def _host_get(img, name, ziel):
    import gast_as
    os.makedirs(ziel, exist_ok=True)
    rc, o = gast_as._lauf([gast_as.disktool(), "get", img, name, "--to", ziel])
    assert rc == 0, o
    for wurzel, _, dateien in os.walk(ziel):       # `get bin/ls` may recreate the directory
        if os.path.basename(name) in dateien:
            with open(os.path.join(wurzel, os.path.basename(name)), "rb") as f:
                return f.read()
    raise AssertionError("get %s: nothing in %s" % (name, ziel))


def _logpunkte(log, adr):
    return [int(m.group(1)) for m in re.finditer(r"\[lp\] [+c](\d+)\s+%04X:" % adr, log)]


@pytest.mark.gast
def test_betrieb_c3_4(tmp_path):
    """Acceptance C3: boot to `#`, ls -l /, files on /tmp and the root, sync, second run reads them, control keys, 200/200 keys under load."""
    import cpa
    import cpa_disk
    import gast_as
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    basis = os.environ.get("MPLUS_ARBEIT")
    arbeit = os.path.join(basis, "betrieb") if basis else str(tmp_path)
    _c34_platten(arbeit)
    sym, _ = _symbole()
    stuecke, soll_k = _folge()
    ers = dict(ARBEIT=arbeit, ISR_ANFR="0x%04X" % sym["ISR_ANFRAGE"], B_READ="0x%04X" % sym["B_READ"], PL_ERG="0x%04X" % sym["PL_ERG"],
               PL_FEHLER="0x%04X" % sym["PL_FEHLER"], STKLEN=0xC8B6 - 0xB936, VERLUST="0x%04X" % sym["V_VERLUST"])
    for i, s in enumerate(stuecke, 1):
        ers["F%d" % i] = s
    platte = cpa_disk.bootdiskette(arbeit)
    log = cpa.lauf_dbg(arbeit, _skript("cpa_c3_4_betrieb.dbg", **ers), platte, laufwerke=cpa_disk.LAUFWERKE, rw=True, frist=7200, name="betrieb")
    scr = cpa._alles(log)
    schirme = cpa.schirme(log)
    # boot to the `#` prompt after "root" at login:, nothing about disk errors
    assert "mem = 196608" in scr and "err on dev" not in scr and "panic" not in scr
    assert any(re.search(r"^#", z) for z in schirme[0]), "no # prompt"
    assert not _logpunkte(log, sym["PL_FEHLER"]), "disk error branch hit"
    for k in range(1, 10):
        assert "MARK%d" % k in scr, "marker MARK%d missing" % k
    # ls -l / complete
    wurzel = "\n".join("\n".join(s) for s in schirme)
    for n in ("bin", "dev", "etc", "mnt", "tmp", "usr"):
        assert re.search(r"^[d-][rwx-]{9}.*\s%s$" % n, wurzel, re.M), "ls -l / without " + n
    # requests that arrive while BIOS READ runs are served afterwards, nothing fatal
    rd, erg, anf = _logpunkte(log, sym["B_READ"]), _logpunkte(log, sym["PL_ERG"]), _logpunkte(log, sym["ISR_ANFRAGE"])
    assert "fatal error" not in scr
    in_fenster = sum(1 for a in anf if any(r <= a <= e for r, e in zip(rd, erg)))
    print("READ windows %d, ISR_ANFRAGE %d, thereof inside READ %d" % (len(rd), len(anf), in_fenster))
    # host: files written to /tmp and the root equal the originals; long key sequence 200/200
    d = os.path.join(arbeit, "host")
    assert _host_get(os.path.join(arbeit, "tmp.hfe"), "t1", d) == _host_get(gast_as.disk("a5120_mutos8000_cmd_mfm.hfe"), "bin/ls", d + "/o1")
    assert _host_get(os.path.join(arbeit, "tmp.hfe"), "t2", d) == _host_get(gast_as.disk("a5120_mutos8000_usr_mfm.hfe"), "lib/libc.a", d + "/o2")
    assert _host_get(os.path.join(arbeit, "root.hfe"), "r1", d) == _host_get(gast_as.disk("a5120_mutos8000_cmd_mfm.hfe"), "bin/cat", d + "/o3")
    assert _host_get(os.path.join(arbeit, "tmp.hfe"), "e1", d) == b"abcd\ngh\n"     # BS (stty erase ^h) erases, ^U kills, ^Z ends cat (kernel/h/tty.h)
    k = _host_get(os.path.join(arbeit, "tmp.hfe"), "k", d)
    assert k.decode("latin-1") == soll_k, k
    assert _bytes_hinter(log, "d 0x%04X 1" % sym["V_VERLUST"], 1) == [0], "key ring overflowed (V_VERLUST)"
    # second run with the same copies: files readable and equal in the guest
    log2 = cpa.lauf_dbg(arbeit, _skript("cpa_c3_4_zweitlauf.dbg", ARBEIT=arbeit, PL_FEHLER="0x%04X" % sym["PL_FEHLER"]), platte,
                        laufwerke=cpa_disk.LAUFWERKE, rw=False, frist=3600, name="zweitlauf")
    scr2 = cpa._alles(log2)
    assert "MARK3" in scr2 and re.search(r"^SAME$", scr2, re.M), "files differ in the second run"
    assert not _logpunkte(log2, sym["PL_FEHLER"])
    assert soll_k.split("\n")[4] in scr2


@pytest.mark.gast
def test_wechsel_c3_4(tmp_path):
    """Disk change in operation: umount rk3, other disk of the same format in the debugger, mount, ls shows the new content."""
    import cpa
    import cpa_disk
    import gast_as
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    basis = os.environ.get("MPLUS_ARBEIT")
    arbeit = os.path.join(basis, "wechsel") if basis else str(tmp_path)
    _c34_platten(arbeit)
    os.makedirs(os.path.join(arbeit, "q"), exist_ok=True)
    for n in range(1, 7):
        with open(os.path.join(arbeit, "q", "m%d" % n), "w") as f:
            f.write("MARK%d\n" % n)
    rc, o = gast_as._lauf([gast_as.disktool(), "put", os.path.join(arbeit, "tmp.hfe")] + [os.path.join(arbeit, "q", "m%d" % n) for n in range(1, 7)])
    assert rc == 0, o
    for i, (name, text) in enumerate((("first", "FIRST-DISK"), ("second", "SECOND-DISK"))):
        img = os.path.join(arbeit, "d%d.hfe" % i)
        if os.path.exists(img):
            os.remove(img)
        rc, o = gast_as._lauf([gast_as.disktool(), "create", img, "--fs", "mutos8k_26x128_mfm", "--inodes", "50"])
        assert rc == 0, o
        with open(os.path.join(arbeit, "q", name), "w") as f:
            f.write(text + "\n")
        rc, o = gast_as._lauf([gast_as.disktool(), "put", img, os.path.join(arbeit, "q", name)])
        assert rc == 0, o
    sym, _ = _symbole()
    platte = cpa_disk.bootdiskette(arbeit)
    log = cpa.lauf_dbg(arbeit, _skript("cpa_c3_4_wechsel.dbg", ARBEIT=arbeit, PL_FEHLER="0x%04X" % sym["PL_FEHLER"], B_SELDSK="0x%04X" % sym["B_SELDSK"]),
                       platte, laufwerke=cpa_disk.LAUFWERKE, rw=True, frist=3600, name="wechsel")
    scr = cpa.schirme(log)
    txt = ["\n".join(s) for s in scr]
    alle = "\n".join(txt)
    assert "MARK6" in txt[-1] and not _logpunkte(log, sym["PL_FEHLER"])
    # explicit screen blocks: after MARK1 (first disk), MARK3 (second disk), MARK5 (first again), at the end
    assert len(txt) >= 4, len(txt)
    assert "FIRST-DISK" in txt[0] and "SECOND-DISK" not in txt[0]
    assert "SECOND-DISK" in txt[1], "disk change: still the old content\n" + txt[1]
    assert txt[2].rfind("FIRST-DISK") > txt[2].find("SECOND-DISK") > 0, txt[2]


# ---------------------------------------------------------------- C4.1: printer driver PRN_* (E7 b), tty1

def test_drucker_ohne_udos_c4_1():
    """No call of the UDOS printer driver (EB00H), no BIOS LIST and no IOBYTE write; DRUCKER starts PRN_START; the driver is hooked in
    the CP/A table (slots F7F0H..F7F6H) and its time-out counts in ISR_TAKT (CTC 0EH belongs to the BIOS)."""
    code = "\n".join(c for _, c in _code_lines())
    assert not re.search(r"\b0?EB00H\b", code, re.I)
    assert not re.search(r"CALL\s+B_LIST\b", code) and not re.search(r"\(0003H\)", code, re.I)
    m = re.search(r"^DRUCKER:(.*?)^DRUCKER_FERTIG:", code, re.M | re.S)
    assert m and re.search(r"CALL\s+PRN_START\b", m.group(1))
    m = re.search(r"^PRN_INIT:(.*?)\bRET\b", code, re.M | re.S)
    assert m
    for slot, isr in (("0F0H", "PRN_TXISR"), ("0F4H", "PRN_RXISR")):
        assert re.search(r"LD HL,%s\s+LD \(INTVEC\+%s\),HL" % (isr, slot), m.group(1)), slot
    assert "4DH" in re.search(r"^PRN_INITBL:\s*DB\s+([0-9A-FH,]+)", code, re.M).group(1)       # 2 stop bits like IFSSPR
    m = re.search(r"^ISR_TAKT:(.*?)^ISR_PARITAET:", code, re.M | re.S)
    assert m and re.search(r"CALL\s+PRN_TICK\b", m.group(1))
    assert not re.search(r"OUT\s+\(0EH\)", code, re.I)           # the BIOS owns CTC 0EH

# bytes at port 5EH for `cat /etc/motd > /dev/lp` under UDOS with IFSSPR: 63 x OUT (5EH),A = NUL, CR, NUL, LF, CR, NUL ... in two jobs (53 B, 2 B),
# measured with versuche/dbg/ifsspr_lp.dbg (logpoint at the OUT, doc/mutos_io/udos_lader.md section 2.4); the PRN_* driver must send the same
UDOS_LP_MOTD = (b"\x00\r\x00\n\r\x00    MUTOS 8000 V.1.0\n\r\x00\n\r\x00    actual system date :\n\r\x00" + b"\x00\x0c\r\x00")


def _ports(seg, port):
    return bytes(int(m.group(1), 16) for m in re.finditer(r"OUT \(%s\)=([0-9A-F]+)" % port, seg))


@pytest.mark.gast
def test_drucker_tty1_c4_1(tmp_path):
    """`cat /etc/motd > /dev/lp`: same 63 bytes at 5EH as under UDOS, two jobs ended normally (no time-out), TAB text expanded, tty1: 44
    characters at 50H, console keeps working (markers), ticks keep running."""
    import cpa
    import cpa_disk
    import gast_as
    if cpa.fehlt(werkzeug=True):
        pytest.skip("emulator or CP/M tool chain missing")
    basis = os.environ.get("MPLUS_ARBEIT")
    arbeit = os.path.join(basis, "drucker") if basis else str(tmp_path)
    _c34_platten(arbeit)
    with open(os.path.join(arbeit, "tab"), "wb") as f:
        f.write(b"AB\tC\nXYZ\tW\n")
    rc, o = gast_as._lauf([gast_as.disktool(), "put", os.path.join(arbeit, "tmp.hfe"), os.path.join(arbeit, "tab")])
    assert rc == 0, o
    sym, _ = _symbole()
    platte = cpa_disk.bootdiskette(arbeit)
    ers = dict(ARBEIT=arbeit, PRN_TXISR="0x%04X" % sym["PRN_TXISR"], PRN_ENDOK="0x%04X" % sym["PRN_ENDOK"], PRN_TCALL="0x%04X" % sym["PRN_TCALL"])
    log = cpa.lauf_dbg(arbeit, _skript("cpa_c4_1_lp.dbg", **ers), platte, laufwerke=cpa_disk.LAUFWERKE, rw=True, frist=3600, name="lp")
    scr = cpa._alles(log)
    for k in range(1, 5):
        assert "MARK%d" % k in scr, "marker MARK%d missing" % k
    assert "fatal error" not in scr and "panic" not in scr
    # the debugger echoes a command before it runs it: the output of part n lies between the echoes of MARKn and MARKn+1
    pos = [log.find('(dbg) gscreen "MARK%d"' % k) for k in (2, 3, 4)]
    assert all(p > 0 for p in pos)
    lp, tab, tty = log[pos[0]:pos[1]], log[pos[1]:pos[2]], log[pos[2]:]
    assert _ports(lp, "5EH") == UDOS_LP_MOTD, _ports(lp, "5EH")
    # per job WR1 = 1EH at the start and 0 at the end (IFSSPR: 01 1E ... 01 00), two jobs
    assert re.findall(r"OUT \(5FH\)=([0-9A-F]+)", lp) == ["01", "1E", "01", "00"] * 2
    assert len(_logpunkte(lp, sym["PRN_TXISR"])) == 63, "one transmit interrupt per character"
    assert len(_logpunkte(log, sym["PRN_ENDOK"])) == 4 and not _logpunkte(log, sym["PRN_TCALL"]), "jobs must end with status 80H, no time-out"
    # TAB: blanks up to the next multiple of 8 (IFSSPR table 24C4H), NUL after every CR, the rest as sent by the kernel
    assert _ports(tab, "5EH") == b"\x00\r\x00    AB      C\n\r\x00    XYZ     W\n\r\x00\x00\x0c\r\x00", _ports(tab, "5EH")
    assert len(_ports(tty, "50H")) == 44, _ports(tty, "50H")
    assert _ports(tty, "50H").startswith(b"\r\nMUTOS 8000 V.1.0\r\n")
    ts = [int(m.group(1)) for m in re.finditer(r"\[io\] c(\d+) OUT \(50H\)", tty)]
    mittel = sum(b - a for a, b in zip(ts, ts[1:])) / (len(ts) - 1)
    print("tty1 cycles per character: %.0f" % mittel)
    assert 2000 < mittel < 3200, mittel
