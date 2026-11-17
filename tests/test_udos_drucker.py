"""Guard for the UDOS printer drivers IFSSPR and PIOPR (Plan 48 C1.3).

1. source -> M80/LINKMT -> bytes == the checked-in ifsspr.bin / piopr.bin  (build_drucker.py --check)
2. the checked-in .bin == the file of the same name on the original boot disk (k1520disktool get)

Skipped without the emulator project or the CP/M tool chain (exit 77 of the build script)."""
import subprocess
import sys

import pytest

from conftest import PROJECT_ROOT, EMU_ROOT, emu_tool_path

UDOS = PROJECT_ROOT / "mutos_io" / "udos"
DISKTOOL = emu_tool_path("k1520disktool")
BOOT = (EMU_ROOT / "disks" / "a5120_16_MUTOS" / "a5120_mutos8000_boot_udos_k5601.hfe") if EMU_ROOT else None

pytestmark = pytest.mark.gast


def test_round_trip_source_to_bytes():
    r = subprocess.run([sys.executable, "-I", str(UDOS / "build_drucker.py"), "--check"],
                       capture_output=True, text=True)
    if r.returncode == 77:
        pytest.skip("emulator project or CP/M tool chain missing")
    assert r.returncode == 0, r.stdout + r.stderr


@pytest.mark.parametrize("name", ["IFSSPR", "PIOPR"])
def test_bin_equals_file_on_original_boot_disk(name, tmp_path):
    if BOOT is None or not BOOT.exists() or not DISKTOOL.exists():
        pytest.skip("boot disk image or k1520disktool missing")
    r = subprocess.run([str(DISKTOOL), "get", str(BOOT), name, "--to", str(tmp_path)],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    assert (tmp_path / name).read_bytes() == (UDOS / (name.lower() + ".bin")).read_bytes()
