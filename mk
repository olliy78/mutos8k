#!/bin/bash
# Entry point for the usual jobs of this repo.  Usage: ./mk <test|gast-test|disketten|kernel|mutos_io|help>
set -e
cd "$(dirname "$0")"
# interpreter with pytest: $PYTHON, else python3, else the emulator project's venv
PY=${PYTHON:-python3}
if ! $PY -c 'import pytest' 2>/dev/null; then
  alt=${K1520EMU:-../a5120emu}/venv/bin/python3
  [ -x "$alt" ] && PY=$alt
fi
cmd=${1:-help}; shift || true
case "$cmd" in
  test)       exec $PY -m pytest -m "not gast" "$@" ;;
  gast-test)  exec $PY -m pytest -m gast "$@" ;;
  disketten)  exec python3 -I tools/disks/bau_alle.py --ueberschreiben "$@" ;;
  kernel)     mkdir -p out/kernel
              # the guest-compiled objects (out/kernel/obj) are needed first: compile once with --uebersetzen
              [ -d out/kernel/obj ] && U= || U=--uebersetzen
              exec python3 -I tools/kernel/gesamtbau.py --arbeit out/kernel $U --natuerlich --boot "$@" ;;
  mutos_io)   exec python3 -I mutos_io/build.py --check "$@" ;;
  help|*)     cat <<'EOT'
./mk test        fast guards (pytest -m "not gast"); skips what needs the emulator/M80
./mk gast-test   guest tests (need the emulator project, minutes; run in the background)
./mk disketten   build all disks into disks/gebaut (tools/disks/bau_alle.py)
./mk kernel      build the kernel from kernel/c and boot it (tools/kernel/gesamtbau.py --natuerlich --boot; hours)
./mk mutos_io    round-trip check of the U880 driver (mutos_io/build.py --check)
Emulator project: env K1520EMU, default ../a5120emu.
EOT
  ;;
esac
