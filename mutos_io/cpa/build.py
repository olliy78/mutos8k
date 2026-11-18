#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
build.py  -  Bau der CP/A-Fassung von mutos_io (Plan 48 C2.1)
=============================================================

Programme = alle src/*.mac (sortiert): m8kboot -> m8kboot.com, sonst <name>.bin.
Heute: src/mutoscpa.mac -> mutoscpa.bin (UDOS-Dateiabbild wie mutos_io/mutosio.bin).
M80 + LINKMT ueber tools/cpm_bau.py (CPA_TOOLS=<pfad>).

  python3 -I mutos_io/cpa/build.py            # baut alle Programme
  python3 -I mutos_io/cpa/build.py --out <datei> [name]
  python3 -I mutos_io/cpa/build.py --check    # 0 gleich, 1 verschieden, 77 ohne Werkzeugkette
  python3 -I mutos_io/cpa/build.py abbild [--out DATEI]
        # MUTOSIO.IMG: Speicherabbild 9000H..Ende des letzten Segments (Luecken 00H)
"""
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
IO = os.path.dirname(HIER)                      # mutos_io/
sys.path.insert(0, os.path.join(os.path.dirname(IO), 'tools'))
import emu  # noqa: E402  (tools/emu.py)
if emu.fehlt():
    print("UEBERSPRUNGEN: emulator project not found (set K1520EMU).")
    sys.exit(emu.SKIP)
cpm_bau = emu.cpm_bau()

BASIS = 0x9000


def _programme():
    namen = sorted(f[:-4] for f in os.listdir(os.path.join(HIER, 'src')) if f.endswith('.mac'))
    return [cpm_bau.Programm(n, HIER, endung='com' if n == 'm8kboot' else 'bin') for n in namen]


PROGRAMME = _programme()


def bild(daten, segs, basis=BASIS):
    """Dateiinhalt + [(anfang, laenge)] -> Speicherabbild ab `basis` (Luecken 00H).

    Jedes Segment liegt in der Datei auf 100H aufgerundet (gemessen: 5376 B = 300H+F00H+200H+100H)."""
    ende = max(a + n for a, n in segs)
    img = bytearray(ende - basis)
    off = 0
    for a, n in segs:
        img[a - basis:a - basis + n] = daten[off:off + n]
        off += (n + 0xFF) & ~0xFF
    if off != len(daten):
        raise RuntimeError(f"Dateilaenge {len(daten)} != Summe der Segmente {off}")
    return bytes(img)


def abbild(quelle=None):
    """mutoscpa bauen -> Speicherabbild (bytes) ab 9000H; fuer C2.4."""
    sys.path.insert(0, IO)
    import ladediskette
    daten, segs = ladediskette.baue(quelle=quelle or os.path.join(HIER, 'src', 'mutoscpa.mac'))
    return bild(daten, segs)


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['abbild']:
        out = a[a.index('--out') + 1] if '--out' in a else os.path.join(HIER, 'build', 'MUTOSIO.IMG')
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
        try:
            img = abbild()
        except RuntimeError as e:
            print(f"FEHLER: {e}", file=sys.stderr)
            sys.exit(1)
        open(out, 'wb').write(img)
        print(f"FERTIG: {out} ({len(img)} Bytes, ab {BASIS:04X}H)")
        sys.exit(0)
    sys.exit(cpm_bau.hauptprogramm(PROGRAMME, __doc__))
