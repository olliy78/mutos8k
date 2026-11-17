# mutos_io/udos - Programme der UDOS-Ladediskette, rekonstruiert

Originalprogramme der MUTOS-Ladediskette (Plan 48 C1.2/C1.3), die **vor** `mutos_io` laufen (Skript `MUTOS`).  Je Programm: kommentierte Quelle
`src/<name>.mac` (M80, nur ASCII, Kommentare Englisch), Bauergebnis `<name>.bin` (eingecheckt, = die UDOS-Datei), Karte `<name>.karte`
(Ausgangsstand fuer `z80_disasm2.py --format mac`, danach nur Nachweis).  Befund: `doc/mutos_io/udos_lader.md`.

| Programm | Bau | Inhalt |
|----------|-----|--------|
| `load16` | `build.py` | Lader: Kernel `mutos_1216` aus einer UDOS-Datei in den EM256 (C1.2, `udos_lader.md` §1) |
| `ifsspr`, `piopr` | `build_drucker.py` | Druckertreiber (C1.3) |

```sh
python3 -I mutos_io/udos/build.py            # baut load16.bin
python3 -I mutos_io/udos/build.py --check    # Quelle -> M80/LINKMT -> Bytes == eingechecktes load16.bin; 77 ohne Werkzeugkette
```

Waechter: `tests/test_udos_lader.py` (`--check`; `load16.bin` == Datei `LOAD16` der Originaldiskette; Gastlauf der Ladefolge, Skip ohne Emulator).
Messskripte: `versuche/dbg/load16_*.dbg`.
