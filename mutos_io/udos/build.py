#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
build.py  -  Bau des UDOS-Laders LOAD16 (Plan 48 C1.2)
=====================================================

Quelle src/load16.mac -> load16.bin (die UDOS-Datei LOAD16 so, wie sie auf der Ladediskette liegt:
512 Byte, mit FFH aufgefuellt).  M80 + LINKMT ueber tools/cpm_bau.py (CPA_TOOLS=<pfad>).
Die Druckertreiber IFSSPR/PIOPR (C1.3) haben ihre eigene Liste in build_drucker.py.

  python3 mutos_io/udos/build.py            # baut load16.bin
  python3 mutos_io/udos/build.py --out <datei>
  python3 mutos_io/udos/build.py --check    # 0 gleich, 1 verschieden, 77 ohne Werkzeugkette
"""
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(HIER)), 'tools'))
import emu  # noqa: E402  (tools/emu.py)
if emu.fehlt():
    print("UEBERSPRUNGEN: emulator project not found (set K1520EMU).")
    sys.exit(emu.SKIP)
cpm_bau = emu.cpm_bau()

PROGRAMME = [cpm_bau.Programm('load16', HIER, endung='bin')]

if __name__ == '__main__':
    sys.exit(cpm_bau.hauptprogramm(PROGRAMME, __doc__))
