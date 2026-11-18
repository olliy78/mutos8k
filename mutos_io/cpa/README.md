# mutos_io/cpa -- CP/A-Fassung von mutos_io (Plan 48)

Zweck: `mutos_io` (U880-Seite von MUTOS 8000) unter CP/A statt UDOS (Plan 48, `doc/plan/48_mutos_io_cpa.md`).
Branch `mutos-plus`; `mutos_io/src/`, `mutos_io/build.py`, `mutos_io/mutosio.bin` gehoeren zu `main` und bleiben unberuehrt.

* `src/mutoscpa.mac` -- CP/A-Fassung, hervorgegangen aus `mutos_io/src/mutosio.mac` (C2.1 bytegleiche Kopie, C3.1 Namen statt Zahlen,
  ab C3.2 umgebaut: Start, Stapel C8B6H, BIOS-Sprungleiste, Vektoren in der CP/A-Tabelle F700H, Ausgabe ueber CONOUT; Befunde `doc/plus/cpa/c3_*.md`).
* `mutoscpa.bin` -- Bauergebnis des aktuellen Stands, eingecheckt; `--check` vergleicht dagegen.  Bytegleich zu `mutos_io/mutosio.bin` war es bis C3.1.
* `src/m8kboot.mac`, `m8kboot.com` -- CP/A-Lader (C2.3).
* `build.py` -- Bau aller `src/*.mac` (M80 + LINKMT ueber `tools/emu.py` -> `cpm_bau`); `m8kboot` ergibt `.com`, sonst `.bin`.

```
python3 -I mutos_io/cpa/build.py                 # baut mutoscpa.bin, m8kboot.com
python3 -I mutos_io/cpa/build.py --check         # 0 gleich, 1 verschieden, 77 ohne Werkzeugkette/Emulator
python3 -I mutos_io/cpa/build.py abbild [--out MUTOSIO.IMG]
```

`abbild` legt die vier Ladesegmente (9000H, 9400H, A400H, C8B6H) an ihre Adressen, Luecken 00H; Laenge C968H-9000H = 14696 Byte
(*gemessen*).  Die Funktion `build.abbild()` ist fuer C2.4 (Bootdiskette) importierbar.  Der Bau nutzt `ladediskette.baue(quelle=...)`.

**Basis-Commit** = der Commit von Plan 48 C2.1: `git diff <basis> -- mutos_io/cpa/src/mutoscpa.mac` zeigt alle CP/A-Aenderungen.
