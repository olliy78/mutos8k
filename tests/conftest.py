"""Shared pytest helpers: repo root, emulator lookup, finished-disk directory."""
import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "tools"))
import emu  # noqa: E402

EMU_ROOT = Path(emu.emulator()) if emu.emulator() else None


def finished_disks_dir():
    """disks/gebaut when it holds disks, else the emulator's disks/a5120_16_MUTOS (reference set)."""
    own = PROJECT_ROOT / "disks" / "gebaut"
    if own.is_dir() and any(own.glob("*.hfe")):
        return own
    if EMU_ROOT and (EMU_ROOT / "disks" / "a5120_16_MUTOS").is_dir():
        return EMU_ROOT / "disks" / "a5120_16_MUTOS"
    return own


def emu_tool_path(name):
    """Binary of an emulator tool (not built here; dev.sh does that when a script calls it)."""
    return (EMU_ROOT / "build" / name) if EMU_ROOT else Path("/nonexistent") / name


def pytest_configure(config):
    config.addinivalue_line("markers", "gast: needs the emulator project")


def pytest_collection_modifyitems(config, items):
    """Guest tests are skipped (not failed) without the emulator project."""
    import pytest
    if emu.fehlt():
        skip = pytest.mark.skip(reason="emulator project not found (K1520EMU)")
        for it in items:
            if "gast" in it.keywords:
                it.add_marker(skip)
