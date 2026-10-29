#!/bin/bash
# Source this file: sets REPO, EMU (emulator project), K (k1520disktool), DBG (k1520dbg) and gdisk().
# Exit 77 when the emulator project is missing.  Builds the emulator tools once (dev.sh build).
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
EMU=${K1520EMU:-$REPO/../a5120emu}
if [ ! -x "$EMU/tools/dev.sh" ]; then echo "emulator project not found (set K1520EMU)" >&2; exit 77; fi
EMU=$(cd "$EMU" && pwd)
[ -n "$K1520EMU_NOBUILD" ] || (cd "$EMU" && tools/dev.sh build >/dev/null)
K=$EMU/build/k1520disktool
DBG=$EMU/build/k1520dbg
# finished guest disk: disks/gebaut first, else the emulator's disks/a5120_16_MUTOS
gdisk() {
  if [ -f "$REPO/disks/gebaut/$1" ]; then echo "$REPO/disks/gebaut/$1"; else echo "$EMU/disks/a5120_16_MUTOS/$1"; fi
}
