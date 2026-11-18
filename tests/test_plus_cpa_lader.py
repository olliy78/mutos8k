"""Guard for the CP/A loader M8KBOOT (plan 48 C2.3).

Fast: sources ASCII, M80 labels unique in 6 characters, checked-in m8kboot.com present and small.
Guest (`gast`, seconds each; skip without emulator/tool chain): `M8KBOOT K` on a copy of the 2-floppy GIDE-CP/A
disk (EM equals the kernel, U8001 starts at 0:027E, INT-16 counter), full operation (image at 9000H), error paths.
"""
import os
import re
import shutil
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

CPA = PROJECT_ROOT / "mutos_io" / "cpa"
DBG = PROJECT_ROOT / "versuche" / "dbg"
sys.path.insert(0, str(PROJECT_ROOT / "tools"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "kernel"))
import emu  # noqa: E402
import cpa  # noqa: E402

ICOUNT = 0x0FFE
KERNEL_LEN = 36352


def test_quelle_ascii_und_marken_eindeutig():
    text = (CPA / "src" / "m8kboot.mac").read_bytes().decode("ascii")
    marken = []
    for ln in text.splitlines():
        m = re.match(r"([A-Za-z_][A-Za-z0-9_]*):?[ \t]+(EQU|DEFB|DEFW|DEFM|DEFS|[A-Z]{2,4})\b", ln)
        if ln and ln[0] not in " \t;" and ":" in ln.split()[0] or (m and m.group(2) == "EQU"):
            marken.append(re.match(r"[A-Za-z_][A-Za-z0-9_]*", ln).group(0).upper())
    kurz = {}
    for n in marken:
        kurz.setdefault(n[:6], set()).add(n)
    clash = {k: v for k, v in kurz.items() if len(v) > 1}
    assert not clash, clash


def test_com_vorhanden_und_klein():
    com = (CPA / "m8kboot.com").read_bytes()
    assert 0 < len(com) <= ICOUNT - 0x100, "code must stay below ICOUNT (0FFEH); stack is at 0FF0H"


def test_ohne_emulator_exit_77():
    env = dict(os.environ, K1520EMU="/nonexistent")
    r = subprocess.run([sys.executable, "-I", str(CPA / "build.py"), "--check"], env=env, capture_output=True, text=True)
    assert r.returncode == 77, r.stdout + r.stderr


# ----------------------------------------------------------------------------------------------- guest

gast = pytest.mark.gast


def _need():
    if cpa.fehlt(True):
        pytest.skip("emulator / CP/M tool chain missing")


def _kernel(arbeit):
    """The original kernel mutos_1216 (36352 B, no UDOS header) from the original boot disk."""
    import gast_as
    ziel = os.path.join(arbeit, "mutos_1216")
    if not os.path.exists(ziel):
        subprocess.run([emu.binary("k1520disktool"), "get", gast_as.disk("a5120_mutos8000_boot_udos_k5601.hfe"),
                        "mutos_1216", "--to", arbeit], check=True, capture_output=True)
    return open(ziel, "rb").read()


def _com():
    return (CPA / "m8kboot.com").read_bytes()


def _release_adr():
    """Address of 'LD A,2CH' (the OUT that releases RESET16) in m8kboot.com; the pattern must be unique."""
    d = _com()
    assert d.count(b"\x3e\x2c\xd3\xa9") == 1
    return 0x100 + d.find(b"\x3e\x2c\xd3\xa9")


def _lauf(arbeit, dateien, zeilen, em=True, name="lauf"):
    """Boot the 2-floppy GIDE-CP/A copy with `dateien` on it, run debugger lines; returns the log.  em=False: no --em."""
    os.makedirs(arbeit, exist_ok=True)
    plat = cpa.diskette(arbeit, "sys.hfe", cpa.GIDE_SYS, dateien)
    if em:
        return cpa.lauf_dbg(arbeit, zeilen, plat, name=name)
    # cpa.lauf_dbg always passes --em: same call without it
    z = ['gscreen "A>" 300000000'] + list(zeilen) + ["q"]
    dbg = os.path.join(arbeit, name + ".dbg")
    open(dbg, "w").write("\n".join(z) + "\n")
    platte = os.path.join(arbeit, "platte.img.gz")
    shutil.copyfile(cpa.GIDE_PLATTE, platte)
    r = subprocess.run([emu.binary("k1520dbg"), "--laderom", "ul4", "--gide=0xD0", "--gide-image", platte, plat, "-x", dbg],
                       capture_output=True, text=True, errors="replace", timeout=300, stdin=subprocess.DEVNULL)
    log = r.stdout + r.stderr
    open(os.path.join(arbeit, name + ".log"), "w").write(log)
    return log


def _skript(datei, **ers):
    t = open(DBG / datei).read()
    for k, v in ers.items():
        t = t.replace("@%s@" % k, str(v))
    return [ln for ln in t.splitlines() if ln.strip() and not ln.startswith("#")]


def _bytes_hinter(log, befehl):
    """Bytes of the (first) 'd' output that follows the debugger command line `befehl`."""
    i = log.index("(dbg) " + befehl)
    m = re.search(r"\n\s*(?:em:)?[0-9A-F]{4,5}:?\s+((?:[0-9A-F]{2} )+)", log[i:])
    return [int(x, 16) for x in m.group(1).split()]


@gast
def test_k_modus(tmp_path):
    _need()
    arbeit = str(tmp_path) if os.environ.get("MPLUS_ARBEIT") is None else os.environ["MPLUS_ARBEIT"]
    os.makedirs(arbeit, exist_ok=True)
    kern = _kernel(arbeit)
    assert len(kern) == KERNEL_LEN
    log = _lauf(arbeit, {"M8KBOOT.COM": _com(), "MUTOS.SYS": kern},
                _skript("cpa_c2_3_k.dbg", ARBEIT=arbeit, RELEASE="0x%04X" % _release_adr()))
    assert open(os.path.join(arbeit, "em0.bin"), "rb").read() == kern, "EM segment 0 == mutos_1216"
    assert "KERNEL LOADED" in log
    # the U8001 starts at <<0>>%027E (reset vector of the kernel file)
    assert re.search(r"\*\* bp.*U8001.*027E|U8001 PC=<<0>>%027E", log), "U8001 did not reach <<0>>%027E"
    em = open(os.path.join(arbeit, "em.log")).read().splitlines()
    reset = [ln.split()[3] for ln in em if ln.split()[2:3] == ["RESET16"]]
    assert reset[-1] == "0" and reset[-2] == "1", reset
    assert sum("OUT PIO B-Daten=38" in ln for ln in em) == 10, "one presence test + nine 4 KB pieces"
    n = _bytes_hinter(log, "d 0xffe 2")
    assert n[0] + 256 * n[1] >= 1, "INT-16 counter"
    w = _bytes_hinter(log, "d em:6 2")
    assert w[:2] != [0, 0] and w[:2] != [0x02, 0x7E], "EM 0006H: mailbox pointer of the kernel (not the reset PC 027EH)"


@gast
def test_ohne_em(tmp_path):
    _need()
    arbeit = str(tmp_path)
    log = _lauf(arbeit, {"M8KBOOT.COM": _com(), "MUTOS.SYS": b"\0" * 512},
                ["keys M8KBOOT\\sK\\r", 'gscreen "NO EM" 600000000', "g 20000000", "screen"], em=False)
    t = cpa.schirm(log)
    assert "M8KBOOT: NO EM" in t
    assert re.search(r"A>\.?$", t.rstrip()), "warm boot back to the prompt: no hang"


@gast
def test_fehlerpfade(tmp_path):
    _need()
    arbeit = str(tmp_path)
    kern = _kernel(arbeit)
    com = _com()
    faelle = [
        ("fehlt", {"M8KBOOT.COM": com}, "MUTOS.SYS NOT FOUND"),
        ("zugross", {"M8KBOOT.COM": com, "MUTOS.SYS": b"\x55" * (65536 + 128)}, "OVER 64 KB"),
        ("keinimg", {"M8KBOOT.COM": com, "MUTOS.SYS": kern}, "MUTOSIO.IMG MISSING"),
        ("img_gross", {"M8KBOOT.COM": com, "MUTOS.SYS": kern, "MUTOSIO.IMG": b"\x11" * 16000}, "TOO BIG"),
        ("img_bios", {"M8KBOOT.COM": com, "MUTOS.SYS": kern, "MUTOSIO.IMG": b"\x11" * 15200}, "REACHES INTO THE BIOS"),
    ]
    for name, dat, text in faelle:
        a = os.path.join(arbeit, name)
        log = _lauf(a, dat, ["keys M8KBOOT\\r", 'gscreen "M8KBOOT: " 400000000', "g 60000000", "screen"])
        t = cpa.schirm(log)
        assert text in t, (name, t)
        assert re.search(r"A>\.?$", t.rstrip()), (name, "warm boot back to the prompt", t)


@gast
def test_vollbetrieb_erreicht_9000(tmp_path):
    _need()
    import importlib.util
    spec = importlib.util.spec_from_file_location("cpa_build", str(CPA / "build.py"))
    b = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(b)
    img = b.abbild()
    arbeit = str(tmp_path)
    kern = _kernel(arbeit)
    log = _lauf(arbeit, {"M8KBOOT.COM": _com(), "MUTOS.SYS": kern, "MUTOSIO.IMG": img},
                _skript("cpa_c2_3_voll.dbg", ARBEIT=arbeit, IMGLEN=len(img)))
    assert open(os.path.join(arbeit, "em0.bin"), "rb").read() == kern
    assert open(os.path.join(arbeit, "io9000.bin"), "rb").read() == img, "memory 9000H.. == MUTOSIO.IMG"
    assert re.search(r"bp.*PC=9000", log), "breakpoint 9000H not reached"
    em = open(os.path.join(arbeit, "em.log")).read().splitlines()
    reset = [ln.split()[3] for ln in em if ln.split()[2:3] == ["RESET16"]]
    assert reset[-1] == "1", "the U8001 stays in reset (mutoscpa starts it)"
