#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
build_drucker.py  -  Bau der UDOS-Druckertreiber IFSSPR und PIOPR (Plan 48 C1.3)
================================================================================

Quelle src/ifsspr.mac, src/piopr.mac -> ifsspr.bin, piopr.bin (die UDOS-Dateien so, wie sie auf
der Ladediskette liegen: 768 bzw. 640 Byte, mit FFH auf 128 B aufgefuellt).  Eigene Bauliste,
solange mutos_io/udos/build.py (C1.2, LOAD16) nicht eingecheckt ist; danach gehoeren beide in
dieselbe Liste.

  python3 mutos_io/udos/build_drucker.py            # baut ifsspr.bin, piopr.bin
  python3 mutos_io/udos/build_drucker.py --check    # 0 gleich, 1 verschieden, 77 ohne Werkzeugkette
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

PROGRAMME = [cpm_bau.Programm('ifsspr', HIER, endung='bin'),
             cpm_bau.Programm('piopr', HIER, endung='bin')]

if __name__ == '__main__':
    sys.exit(cpm_bau.hauptprogramm(PROGRAMME, __doc__))
