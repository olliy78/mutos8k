"""Guard for tools/plus/cpa_export.py (archive of the CP/A boot disk contents for the emulator project).

Fast: import, deterministic zip from fake bytes (layout, no kernel, provenance), exit 77 without emulator.
Guest (`gast`, ~1 min incl. the Workbench build; skip without emulator/Workbench/tool chain): fresh build, SHA-1 of @OS.COM.
"""
import hashlib
import os
import subprocess
import sys
import zipfile

import pytest

from conftest import PROJECT_ROOT

sys.path.insert(0, str(PROJECT_ROOT / "tools"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "plus"))
CPA_EXPORT = PROJECT_ROOT / "tools" / "plus" / "cpa_export.py"


def _fake():
    return {"@OS.COM": b"\x01" * 16, "M8KBOOT.COM": b"\x02" * 8, "MUTOSIO.IMG": b"\x03" * 32}


def test_archiv_layout_und_herkunft(tmp_path):
    import cpa_export
    dat = _fake()
    her = cpa_export.herkunft(dat)
    z1, z2 = tmp_path / "a.zip", tmp_path / "b.zip"
    cpa_export.archiv_schreiben(str(z1), dat, her)
    cpa_export.archiv_schreiben(str(z2), dat, her)
    assert z1.read_bytes() == z2.read_bytes()                 # deterministic
    with zipfile.ZipFile(z1) as z:
        namen = z.namelist()
        assert set(namen) == {"bauangaben.yaml", "herkunft.txt", "dateien/@OS.COM", "dateien/M8KBOOT.COM", "dateien/MUTOSIO.IMG"}
        assert not any("MUTOS.SYS" in n or "mutos_1216" in n for n in namen if n.startswith("dateien/"))
        ang = z.read("bauangaben.yaml").decode("ascii")
        assert z.read("dateien/MUTOSIO.IMG") == dat["MUTOSIO.IMG"]
    assert "kernel_archiv: a5120_mutos8000/a5120_mutos8000_boot_udos.zip" in ang
    assert "kernel_datei: dateien/mutos_1216" in ang
    assert "sha1_os_com: " + hashlib.sha1(dat["@OS.COM"]).hexdigest() in ang
    assert "Plan 48" in ang and "herkunft_commit: " in ang
    for n in ang.splitlines():
        assert all(ord(c) < 128 for c in n)


def test_ohne_emulator_exit_77(tmp_path):
    env = dict(os.environ, K1520EMU="/nonexistent")
    r = subprocess.run([sys.executable, "-I", str(CPA_EXPORT), "archiv", "--arbeit", str(tmp_path),
                        "--out", str(tmp_path / "x.zip")], env=env, capture_output=True, text=True)
    assert r.returncode == 77, r.stdout + r.stderr


@pytest.mark.gast
def test_archiv_frisch_gebaut(tmp_path):
    import cpa_export
    arbeit = os.environ.get("MPLUS_ARBEIT") or str(tmp_path)
    try:
        dat = cpa_export.dateien(arbeit)
    except cpa_export.Fehlt as e:
        pytest.skip(str(e))
    assert hashlib.sha1(dat["@OS.COM"]).hexdigest().startswith("97bbdca9")
    assert dat["M8KBOOT.COM"] == (PROJECT_ROOT / "mutos_io" / "cpa" / "m8kboot.com").read_bytes()
    assert len(dat["MUTOSIO.IMG"]) == 14696
    z = cpa_export.archiv_schreiben(str(tmp_path / "x.zip"), dat, cpa_export.herkunft(dat))
    with zipfile.ZipFile(z) as zf:
        assert zf.read("dateien/@OS.COM") == dat["@OS.COM"]
