# MUTOS unter CP/A (Plan 48): Uebersicht

Stand 2026-11-18, Branch `mutos-plus`.  Kennzeichnung wie sonst: *gemessen* (Befund in `doc/plus/cpa/`), *abgeleitet*, *Annahme*.
MUTOS 8000 laeuft hier mit der U880-Seite `mutoscpa` auf einem CP/A-System (BIOS statt UDOS-Nukleus); der Kernel ist unveraendert (Original `mutos_1216` und P3.4-Kernel laufen beide).

## 1. Startkette

1. Lade-ROM UL4 bootet die **4-Floppy-CP/A-Systemdiskette** (`@OS.COM` aus der Workbench-Variante `gide_a5120` mit `anzdisk = 4`, Konfiguration `mutos_io/cpa/system/konfig.txt`): Laufwerke A:-D:, GIDE E: bis L:, RTC D5H, `A>`.
2. Am Prompt `M8KBOOT` tippen (**kein Autostart**).  `M8KBOOT.COM` (`mutos_io/cpa/src/m8kboot.mac`) liest `MUTOS.SYS` per BDOS in 4-KB-Stuecken ueber das Fenster 4000H-7FFFH in EM-Segment 0,
   liest `MUTOSIO.IMG` nach 8000H, prueft die Lage gegen den BIOS-Anfang, schiebt das Abbild nach 9000H und springt dorthin; der U8001 bleibt im Reset.  `M8KBOOT K` laedt nur den Kernel und startet den U8001 (Abnahmebetrieb).
3. `mutoscpa` (`mutos_io/cpa/src/mutoscpa.mac`): Bedienmaske ueber BIOS `CONOUT` (Disketten waehlen, `r`), dann Start des U8001; Platte ueber die BIOS-Einspruenge `SELDSK`/`SETTRK`/`SETSEC`/`SETDMA`/`READ`/`WRITE` (synchron),
   Tastatur ueber `CONST`/`CONIN` im 50-Hz-ISR, Drucker als Treiberkern `PRN_*` (aus `IFSSPR`, E7 (b), fest 7 Bit / ungerade Paritaet / 2 Stoppbits), Vektoren in der CP/A-Tabelle F700H.
4. Kernel bootet bis `login:` bzw. `#`.  **Ein Rueckweg nach CP/A fehlt** (Reset des Rechners).

## 2. Aufrufe (alle ohne Argument-Kenntnis des Emulators; Exit 77 ohne Emulator/Workbench/Werkzeugkette)

* `python3 -I tools/plus/cpa_system.py bauen|pruefen --arbeit DIR` -- 4-Floppy-`@OS.COM` in frischer Workbench-Kopie bauen (`CPA_WORKBENCH`, Vorgabe `~/projects/CPA_Workbench`; SHA-1 `97bbdca9...`) bzw. booten und Kopfzeile/`DIR E:`/Uhr pruefen.
* `python3 -I tools/plus/cpa_disk.py diskette --arbeit DIR [--kernel DATEI]` -- Bootdiskette `boot4.hfe` (Systemdiskette + `M8KBOOT.COM`, `MUTOS.SYS`, `MUTOSIO.IMG`); `kstart --arbeit DIR` -- Abnahmelauf `M8KBOOT K`.
* `python3 -I tools/plus/cpa_export.py archiv --arbeit DIR --out a5120_mutos8000_boot_cpa.zip` -- baut `@OS.COM`, `M8KBOOT.COM`, `MUTOSIO.IMG` frisch und schreibt sie samt Bauangaben/Herkunft als Archiv fuer das Emulatorprojekt (dort `tools/mutos8000/bau_cpa.py` baut die Diskette; `MUTOS.SYS` = `mutos_1216` aus dessen `boot_udos.zip`, nicht im Archiv).  Waechter `tests/test_plus_cpa_export.py`.
* `python3 -I tools/plus/cpa_lauf.py probe|boot --arbeit DIR [--kernel DATEI]` -- Gastlauf-Werkzeug (wie `gastlauf`/`gastbau.boot` ueber UDOS): `probe` zwei Disketten mit Wechsel, `boot` die Arbeitstests b1..b11, pp, pi, pf mit `bewerten`.
* `python3 -I mutos_io/cpa/build.py [--check | abbild]` -- `mutoscpa.bin`, `m8kboot.com` bauen/pruefen (Bau ueber `tools/emu.py` -> M80/LINKMT im Emulator).
* Langtest: `K1520_PLUS=1 python3 -m pytest -q tests/test_plus_cpa_lang.py` (Hintergrund).

## 3. Speicherkarte des U880 (gemessen: `c2_3`, `c2_4`, `c3_2`, `c3_4`, `c1_8`)

| Bereich | Inhalt |
|---|---|
| 0100H-04FFH, Stapel 0FF0H, Puffer 1000H-1FFFH, 8000H-BBFFH | nur `M8KBOOT` (danach ueberschrieben) |
| 4000H-7FFFH | EM-Fenster (nur waehrend des Ladens, `OUT 38H`..`3CH`) |
| 9000H-C967H | Abbild `mutoscpa` (14 696 B; Segmente 9000H, 9400H, A400H, C8B6H); Postfach/Tabellen A5A8H.. wie unter UDOS |
| B936H-C8B5H | Stapel (3968 B, mit E5H gefuellt); `SP` = C8B6H; tiefste benutzte Stelle C87CH nach allen Arbeitstests (3910 B frei) |
| BC06H-C9FFH | CP/A-BDOS bis BIOS-Anfang **CA00H** (4 Floppys; 2 Floppys: CB00H); TPA 100H-BC05H |
| F700H-F7FFH | Interrupttabelle (`I` = F7H): `F7EAH` Anforderung, `F7ECH` Paritaet, `F7FAH` 50-Hz-Takt, `F7F0H`-`F7F6H` Drucker |

## 4. Laufzeiten (gemessen)

* Workbench-Bau `@OS.COM` ~10 s; Bootdiskette ~33 s; `kstart` ~45 s; `cpa_lauf probe` 19 s Gastlauf (~50 s gesamt).
* Boot bis `login:` 76 Mio. Takte (`A>` 25, `M8KBOOT` bis `ready (r)` 24, bis `login:` 27).  Arbeitstests: Gastlauf 78-125 s Wanduhr, 2984 Mio. Takte gesamt gegen 2670 Mio. ueber UDOS (**+12 %**; in den Tests +31 %,
  plattenlastige b4/b8/b9 +28..39 %; Ursache **nicht gemessen**, Annahme: BIOS-`READ`/`WRITE` je Block teurer als der UDOS-Lader), Ergebnis `bewerten: no failure` mit beiden Kerneln, `c4_2`.
* Langtest `tests/test_plus_cpa_lang.py` (Arbeitstests ueber CP/A, Original-Kernel, gesamt inkl. Bootdiskette): 156,9 s Wanduhr, bestanden (2026-11-18, `c5_2_abschluss.md`).

## 5. Grenzen und offene Punkte

* Kein Autostart, kein Rueckweg nach CP/A; der Start verlangt die Diskette mit `M8KBOOT` in A: (Start von der Platte: Plan 51 P6).
* Unter Plattenlast liegt die Tastenlatenz bis zu einem Tick (20 ms) ueber dem UDOS-Weg; Tastenpuffer verwirft bei Ueberlauf (`V_VERLUST`, gemessen 0).  DEL-Eingabe ungeprueft (Emulator-`keys` kann 7FH nicht senden).
* Selbstbau-Fixpunkt ueber CP/A: **nicht ausgefuehrt** (O6 optional), siehe `c5_2_abschluss.md` §3.
* **Offen mit dem Projektinhaber: Konfigurierbarkeit des Druckers** (heute fest 7O2 wie `IFSSPR`); nicht umgesetzt.
* Die 4-Floppy-Variante braucht die Workbench `CPA_Workbench` (fremdes Projekt, nur als Kopie gelesen); GIDE-Laufwerke heissen E: bis L: (Plan 51).
* Abweichungen vom Original: `doc/plus/abweichungen.md` (Zeilen C2.4a, C2.4b, C3.4, C4.1, C5.2).  Befunde: `doc/plus/cpa/c*.md`, Analyse `doc/plus/cpa_analyse.md`.
