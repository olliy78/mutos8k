"""Guard for the UDOS loader LOAD16 (Plan 48 C1.2).

1. source -> M80/LINKMT -> bytes == the checked-in load16.bin            (build.py --check)
2. the checked-in load16.bin == the file LOAD16 on the original boot disk (k1520disktool get)
3. (guest) BOOT MUTOS up to the entry of mutos_io (9000H), EM card log:  the facts of
   doc/mutos_io/udos_lader.md section 1 -- 16 attribute pages disabled first, nine 4-KB pieces
   copied with PIO B 38H/3CH pairs, U8001 in reset (not started) when mutos_io is entered.

Skipped without the emulator project or the CP/M tool chain (exit 77 of the build script)."""
import re
import subprocess
import sys

import pytest

import emu
from conftest import PROJECT_ROOT, EMU_ROOT, emu_tool_path

UDOS = PROJECT_ROOT / "mutos_io" / "udos"
DISKTOOL = emu_tool_path("k1520disktool")
BOOT = (EMU_ROOT / "disks" / "a5120_16_MUTOS" / "a5120_mutos8000_boot_udos_k5601.hfe") if EMU_ROOT else None
SCRIPT = PROJECT_ROOT / "versuche" / "dbg" / "load16_ablauf.dbg"
EMLOG = PROJECT_ROOT / "out" / "load16_emlog.txt"

pytestmark = pytest.mark.gast


def test_round_trip_source_to_bytes():
    r = subprocess.run([sys.executable, "-I", str(UDOS / "build.py"), "--check"],
                       capture_output=True, text=True)
    if r.returncode == 77:
        pytest.skip("emulator project or CP/M tool chain missing")
    assert r.returncode == 0, r.stdout + r.stderr


def test_bin_equals_file_on_original_boot_disk(tmp_path):
    if BOOT is None or not BOOT.exists() or not DISKTOOL.exists():
        pytest.skip("boot disk image or k1520disktool missing")
    r = subprocess.run([str(DISKTOOL), "get", str(BOOT), "LOAD16", "--to", str(tmp_path)],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    assert (tmp_path / "LOAD16").read_bytes() == (UDOS / "load16.bin").read_bytes()


def test_guest_load_sequence():
    if BOOT is None or not BOOT.exists():
        pytest.skip("boot disk image missing")
    EMLOG.parent.mkdir(exist_ok=True)
    EMLOG.unlink(missing_ok=True)
    r = emu.dbg(["--em", "em256", "--laufwerke", "K5601,K5601,K5601", str(BOOT), "-x", str(SCRIPT)],
                capture_output=True, text=True, timeout=300)
    assert r.returncode == 0, r.stdout[-2000:] + r.stderr[-2000:]
    log = EMLOG.read_text().splitlines()
    first16 = [l for l in log[:16] if "A22-OUT" in l and re.search(r"Seite \w=F\b", l)]
    assert len(first16) == 16, "LOAD16 starts by disabling all 16 attribute pages"
    b = [re.search(r"B-Daten=(\w\w)", l).group(1) for l in log if "PIO B-Daten" in l]
    assert b == ["38", "3C"] * 9, "nine pieces of 4 KB (36352 bytes = 8 * 4096 + 3584)"
    # RESET16 is 0 only between the PIO B mode word (U8001 halted by /STOP) and the first 38H;
    # at the entry of mutos_io the last RESET16 event is 1: the U8001 is held in reset
    reset = [l.split()[3] for l in log if l.split()[2:3] == ["RESET16"]]
    assert reset == ["0", "1"], reset
