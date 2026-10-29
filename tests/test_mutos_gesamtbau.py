"""Waechter fuer tools/kernel/gesamtbau.py (AP K8, doc/kernel/gesamtbau.md).

Schnell (immer): die Bausteine sind vollstaendig vorhanden, die Adresstabelle `adressen.txt` ist wohlgeformt, jede
C-Datei des natuerlichen Baus und jeder Header existiert, die Linkkarte nennt die Module.
Voll (nur mit K1520_GESAMTBAU=1; Minuten bis Stunden, Gast im Emulator): Stufe 1 muss BYTEGLEICH sein und Stufe 2 bis `#`
booten -- dieser Lauf gehoert nicht in die Standardregression, von Hand:
    K1520_GESAMTBAU=1 python3 -m pytest tests/test_mutos_gesamtbau.py -k voll
"""
import os
import re
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

TOOLS_DIR = PROJECT_ROOT / "tools" / "kernel"
KERNEL_DIR = PROJECT_ROOT / "kernel"
sys.path.insert(0, str(TOOLS_DIR))
import gesamtbau as G   # noqa: E402


def test_adressen_txt_ist_wohlgeformt():
    n = 0
    for z in (KERNEL_DIR / "karte" / "adressen.txt").read_text().splitlines():
        if not z.strip() or z.startswith("#"):
            continue
        name, adr = z.split()
        assert name.startswith("_") and len(name) <= 8, z
        assert re.fullmatch(r"[0-9A-F]{4}", adr), z
        n += 1
    assert n >= 20


def test_alle_quellen_des_natuerlichen_baus_sind_da():
    for c in G.NAT_CDATEIEN:
        assert os.path.exists(G.cpfad(c)), c
    assert (KERNEL_DIR / "h" / "param.h").exists()
    assert (PROJECT_ROOT / "userspace" / "make" / "make.bin").exists()


def test_c_dateien_haben_marken_fuer_jede_funktion():
    import vergleich
    n = 0
    for c in G.CDATEIEN:
        n += len(list(vergleich.funktionen_aus_quelle(G.cpfad(c))))
    assert n >= 220


def test_linkkarte_und_shim():
    assert "modul low 0000 0674" in (KERNEL_DIR / "karte" / "linkkarte.txt").read_text()
    assert "_save" in G.SHIM and "_mchinit" in G.SHIM


@pytest.mark.gast
@pytest.mark.skipif(os.environ.get("K1520_GESAMTBAU") != "1", reason="langer Gastlauf (K1520_GESAMTBAU=1)")
@pytest.mark.parametrize("stufe,erwartung", [(1, "BYTEGLEICH"), (2, "ABWEICHUNG")])
def test_voll(tmp_path, stufe, erwartung):
    # --uebersetzen: cc im Gast (sechs Laeufe); --boot: Kernel auf die Ladediskette und Arbeitstests
    r = subprocess.run([sys.executable, "-I", str(TOOLS_DIR / "gesamtbau.py"), "--arbeit", str(tmp_path), "--uebersetzen",
                        "--stufe", str(stufe), "--boot"], cwd=str(PROJECT_ROOT), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    out = r.stdout.decode("latin-1")
    assert "Gesamt: " + erwartung in out, out[-3000:]
    assert r.returncode == 0, out[-3000:]
    assert "summe = 5050" in out
