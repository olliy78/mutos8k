"""Waechter fuer den Selbstbau des Branches `mutos-plus` (Plan 47 P3.3, `doc/plus/gastbau.md`).

Schnell (immer): `kernel/plus` und die beiden Makefiles passen zusammen, keine `dn*.s` mehr, die festen Adressen aus P2.3 sind Verweise,
alles ASCII, die V-Funde in `doc/plus/feste_adressen.md` sind als erledigt markiert, `bewerten` erkennt gute und schlechte Ausgaben.
Lang (nur mit K1520_PLUS=1; Gast im Emulator, ~1 Stunde, im Hintergrund starten): Fixpunkt des Selbstbaus, `gastbau.py fixpunkt`:
    K1520_PLUS=1 python3 -m pytest -q tests/test_plus_selbstbau.py -k lang
"""
import os
import re
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT

PLUS = PROJECT_ROOT / "kernel" / "plus"
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "kernel"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
import gesamtbau as G   # noqa: E402


def _makefiles():
    return {n: (PLUS / n).read_text() for n in ("mk1", "Makefile")}


def test_makefile_nennt_nur_vorhandene_quellen():
    suche = [PLUS, PROJECT_ROOT / "kernel" / "c", PROJECT_ROOT / "kernel" / "conf", PROJECT_ROOT / "kernel" / "h"]
    for n, t in _makefiles().items():
        for m in set(re.findall(r"\$\(SRC\)/([\w.]+)", t)):
            assert any((d / m).exists() for d in suche), "%s: $(SRC)/%s fehlt" % (n, m)


def test_jede_c_datei_des_baus_steht_im_makefile():
    mk = _makefiles()
    # mk1 baut die erste Haelfte (objs1), das Makefile die uebrigen und bindet alle
    objs1 = re.search(r"^objs1: (.*)$", mk["mk1"], re.M).group(1).split()
    objs = re.search(r"^OBJS = (.*)$", mk["Makefile"], re.M).group(1).split()
    for c in G.NAT_CDATEIEN:
        assert c + ".o" in objs, c + ".o wird nicht gelinkt"
        in_mk1 = c + ".o" in objs1 and re.search(r"^%s\.o:" % re.escape(c), mk["mk1"], re.M)
        in_mk = re.search(r"^%s\.o:" % re.escape(c), mk["Makefile"], re.M)
        assert bool(in_mk1) != bool(in_mk), "%s.o: Regel in mk1 und Makefile zusammen %d mal" % (c, bool(in_mk1) + bool(in_mk))
    # jedes Objekt der Linkliste hat genau eine Quelle
    for o in objs:
        assert o[:-2] in G.NAT_CDATEIEN or (PLUS / (o[:-2] + ".s")).exists() or (PLUS / (o[:-2] + ".c")).exists(), o


def test_kernel_plus_hat_alle_dateien_des_makefiles_und_keine_dn_mehr():
    for n in ("low.s", "shim.s", "abs.s", "bss.s", "daten.c", "mk1", "Makefile"):
        assert (PLUS / n).exists(), n
    assert not list(PLUS.glob("dn*.s"))
    assert not (PLUS / "abs.o").exists()
    for n in os.listdir(PLUS):
        assert not re.match(r"dn\d\.s$", n), n


def test_feste_adressen_sind_verweise():
    assert not re.search(r"WV\s+%888A", (PLUS / "low.s").read_text())
    assert "WV _cf_x88a" in (PLUS / "low.s").read_text()
    conf = (PROJECT_ROOT / "kernel" / "conf" / "conf.c").read_text()
    code = re.sub(r"/\*.*?\*/", "", conf, flags=re.S)       # the comment may name the old value
    assert "0x8A8C" not in code and "(struct proc *)&max_proc" in code


def test_kernel_plus_ist_ascii():
    for p in sorted(PLUS.iterdir()):
        if p.is_file() and p.name != "README.md":       # README.md is documentation (German, with section signs)
            p.read_bytes().decode("ascii")


def test_v_funde_sind_erledigt():
    t = (PROJECT_ROOT / "doc" / "plus" / "feste_adressen.md").read_text()
    abschnitt = re.search(r"## 1\. V-Funde(.*?)(?=\n## )", t, re.S).group(1)
    zeilen = [z for z in abschnitt.splitlines() if re.match(r"\|[^|]*\|[^|]*\| V \|", z)]
    assert zeilen, "keine V-Zeilen gefunden"
    zahl = {"zwei": 2, "drei": 3, "vier": 4, "fuenf": 5}
    m = re.search(r"Alle (\w+) erledigt", abschnitt)
    assert m and zahl.get(m.group(1)) == len(zeilen), "V-Zeilen nicht als erledigt markiert"


def test_bewerten_trennt_gut_und_schlecht():
    import gastbau
    gut = {"b1": ".profile\nbin\n", "b2": "getty\ninit\n", "b3": "int f(a)\n\treturn a + 1;\n", "b4": "",
           "b5": "-rw-rw-r-- 1 root 164 Oct 26 13:05 t.o\n", "b6": "Mon Oct 26 13:06:14 GMT 2026\n",
           "b7": "return a + 1;\n-rw-rw-r-- 1 root 35 Oct 26 13:06 /tmp/e1\n", "b8": "summe = 5050\nsumme = 5050\n",
           "b9": "-rw-rw-r-- 1 root 1600 Oct 26 13:12 prf.o\n", "b10": "x\n  -> 2 slp -sh\n  -> 49 RUN ps\n",
           "b11": "crw-rw-r-- 1 root 5, 0 Jan 9 1986 /dev/lp\n"}
    for n, t in gut.items():
        assert gastbau.bewerten(n, t) == [], n
    assert gastbau.bewerten("b8", "summe = 5050\n")
    assert gastbau.bewerten("b9", "prf.o 1599\n")
    assert gastbau.bewerten("b10", "tty owner\n")
    assert gastbau.bewerten("b1", "ls: not found\n")
    assert gastbau.bewerten("b6", "")
    assert gastbau.bewerten("pp", None)


@pytest.mark.gast
@pytest.mark.skipif(os.environ.get("K1520_PLUS") != "1", reason="langer Gastlauf (K1520_PLUS=1)")
def test_lang_fixpunkt_des_selbstbaus(tmp_path):
    r = subprocess.run([sys.executable, "-I", str(PROJECT_ROOT / "tools" / "plus" / "gastbau.py"), "fixpunkt", "--arbeit", str(tmp_path)],
                       cwd=str(PROJECT_ROOT), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    out = r.stdout.decode("latin-1")
    if r.returncode == 77:
        pytest.skip("Emulator fehlt")
    assert r.returncode == 0, out[-4000:]
    assert "FIXPUNKT: ja" in out, out[-4000:]
    assert "bewerten: no failure" in out
