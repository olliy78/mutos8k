#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
build.py  -  Bau der UDOS-Programme LOAD16, IFSSPR, PIOPR (Plan 48 C1.2, C1.3)
==========================================================================

Quelle src/load16.mac -> load16.bin (die UDOS-Datei LOAD16 so, wie sie auf der Ladediskette liegt:
512 Byte, mit FFH aufgefuellt).  M80 + LINKMT ueber tools/cpm_bau.py (CPA_TOOLS=<pfad>).
Ebenso die Druckertreiber src/ifsspr.mac, src/piopr.mac -> ifsspr.bin (768 B), piopr.bin (640 B), C1.3.

  python3 mutos_io/udos/build.py            # baut load16.bin, ifsspr.bin, piopr.bin
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

PROGRAMME = [cpm_bau.Programm('load16', HIER, endung='bin'),
             cpm_bau.Programm('ifsspr', HIER, endung='bin'),
             cpm_bau.Programm('piopr', HIER, endung='bin')]

if __name__ == '__main__':
    sys.exit(cpm_bau.hauptprogramm(PROGRAMME, __doc__))
