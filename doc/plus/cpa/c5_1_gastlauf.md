# C5.1 Gastlauf-Werkzeug ueber CP/A (Plan 48)

**Stand: erledigt** (Abnahme erreicht), 2026-11-18.  Arbeitsordner `/tmp/mplus/c5_1/` (`lauf.log`, `boot/boot/lauf.log`).  *gemessen* soweit nicht anders bezeichnet.
Werkzeug `tools/plus/cpa_lauf.py`, Waechter `tests/test_plus_cpa_lauf.py` (schnell: Skript, Exit 77; `gast`: `probe`).

## 1. Aufbau
* `skript()` = Vorspann (`gscreen "A>"`, `keys M8KBOOT\r`, `gscreen "ready (r)"`, `eject`/`mount` A..D ohne Formatangabe, `keys r`, `gscreen "login:"`)
  + der Teil von `gastlauf.skript` ab der Zeile `keys root\r` (Anker, muss genau einmal vorkommen, sonst Fehler).  Marken (`END<n>`, `ENDES`), Mounts und Wechselschritte sind damit die des UDOS-Wegs;
  nur das Formatwort ` udos_ss77` der `mount`-Zeilen wird gestrichen (die CP/A-Skripte aus C3 mounten ohne).
* `lauf()` / `gast_befehle()` / `boot()` wie `gastlauf.lauf` / `gast_as.gast_befehle` / `gastbau.boot` (gleiche `TESTS`, `testdateien`, `auswerten`).  `boot_hfe` ist hier eine CP/A-Bootdiskette
  (Vorgabe `cpa_disk.bootdiskette(arbeit)` mit Originalkernel; `boot(arbeit, kernel_bytes)` baut sie mit dem Kernel).  `gast_befehle` kennt `mnt`, `quelle_hfe`, `extra_dateien` nicht (NotImplementedError).
* Emulatoraufruf: `k1520dbg --em em256 --rw --laderom ul4 --gide=0xD0 --gide-image <platte.img.gz Kopie> --laufwerke K5601 x4 boot4.hfe -x lauf.dbg`.
* Kommandozeile `cpa_lauf.py probe|boot --arbeit DIR [--kernel DATEI]`; Exit 77 ohne Emulator/Workbench/Werkzeugkette.  Dateiende im Gast ist ^Z.

## 2. Abnahme
* `python3 -I tools/plus/cpa_lauf.py probe --arbeit /tmp/mplus/c5_1` -> **0**: `a` = `AAA\n`, `b` = `BBB\n`, `ls /mnt` nach dem Wechsel = `b.txt` (+ Marken, kein `a.txt`); `ABNAHME ja`.
  Gastlauf **19 s** Wanduhr; Gesamtaufruf ~50 s (davon Bootdiskette inkl. Workbench-Bau).
* Zusatz (nicht gefordert): `cpa_lauf.py boot --arbeit /tmp/mplus/c5_1/boot` mit dem Originalkernel: alle Tests `b1..b11`, `pp`, `pi`, `pf` ohne Fehlschlag (`bewerten: no failure`), Gastlauf **78 s**, gesamt ~117 s.
  Das ist eine Vorabmessung fuer C4.2, kein Abnahmeergebnis (kein UDOS-Vergleich der Takte).

## 3. Grenzen
* Gemessen nur mit der `mutoscpa.bin`-Fassung zum Zeitpunkt des Laufs (C3.4); aendert C4.1 die Bootdiskette, baut `bootdiskette` sie bei jedem Lauf neu.
* Der Lauf nutzt keine Fristen auf Prozessebene (Subprozess ohne Timeout); die `gscreen`-Fristen des Skripts begrenzen ihn.
* Keine neuen Merkposten fuer den Emulator.
