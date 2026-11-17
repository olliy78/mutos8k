# Plan 48: `mutos_io` nach CP/A portieren

Stand 2026-11-17, Branch `mutos-plus` (Plan 47).  **C1 in Agentenschritte zerlegt (§7); C2-C5 vorlaeufig (§9), endgueltig nach dem Entscheidungspunkt (§8).**
Hervorgegangen aus Plan 46 (auf `main` geloescht in `5738a8e`).
Aussagen sind *gemessen* (mit Befehl/Fundstelle), *abgeleitet* (aus Quelle gelesen), *Angabe des Projektinhabers* oder *Annahme*.

## 1. Ziel

`mutos_io` (U880-Seite, heute ein UDOS-Programm bei 9000H) laeuft unter **CP/A** (CP/M-2.2-kompatibel, Robotron) statt unter UDOS 3/4.  Alle Dienste, die
`mutos_io` heute vom UDOS-Nukleus holt (Platte, Konsole, Drucker), kommen aus dem **CP/A-BIOS**; das Laden des Kernels in den EM uebernimmt ein CP/A-Programm.
Damit stehen die Faehigkeiten des CP/A zur Verfuegung, die UDOS fehlen: **zweiseitige Disketten** (Plan 49), **RTC** (Plan 50) und **GIDE-Festplatte** (Plan 51).

Abgrenzung: In diesem Plan bleibt der **Kernel unveraendert** und das **Postfach-Protokoll** (Nachricht im EM, Klassen 0-4, `doc/mutos_io/analyse.md` §2-§3) gleich.
Abnahme ist der Boot des unveraenderten Kernels ueber CP/A bis `login:`/`#` mit den bisherigen Wurzeldisketten (soweit CP/A deren Format kann, C1.6) und die
Arbeitstests aus Plan 47 P3.1 (`tools/plus/gastbau.py` `TESTS`/`bewerten`).

Was Plan 49-51 von hier erwarten (abgeleitet aus deren Text): Plattenweg ueber die **Standard-BIOS-Einspruenge** mit Einheit -> CP/A-Laufwerk als Tabelle
(49 B2, 51 P2), einen Lader, der auch von einem GIDE-Laufwerk starten kann (51 P6), und eine freie Postfach-Klasse 5 fuer die Uhr (50 R2).  C3 legt die
Laufwerkstabelle deshalb gleich als Tabelle an (nicht fest verdrahtet) und laesst Klasse 5 frei.

## 2. Ausgangslage

**`mutos_io` und UDOS** (gemessen, `doc/mutos_io/analyse.md`, Plan 39):
* Startkette: UDOS-Lader-Menue -> Skript `MUTOS` = `ACTIVATE $IFSSPR`, `LOAD16 mutos_1216` (Kernel in den EM), `mutos_io` (Plan 39 §2/Zeile 384).  `ACTIVATE`, `IFSSPR`,
  `LOAD16` sind UDOS-Programme und **nicht disassembliert**.
* Groesse und Lage (gemessen 2026-11-17, `k1520disktool ls <k1520emu>/disks/a5120_16_MUTOS/a5120_mutos8000_boot_udos_k5601.hfe -l`; deckt sich mit Plan 39 Tabelle Zeile 687-698):
  `ACTIVATE` P/WS 1024 B bei 4000 (Zilog-Standardkommando 1979), `IFSSPR` P1 768 B bei **EB00** (Druckertreiber IFSS), `PIOPR` P1 640 B bei EB00 (Druckertreiber PIO),
  `LOAD16` P **512 B** bei 5000 (ZFT/KEAW 1984), `mutos_io` P 5376 B bei 9000, `mutos_1216` 36 352 B.  Eigens fuer MUTOS sind nur `LOAD16`, `IFSSPR`/`PIOPR`, `mutos_io`.
* UDOS-Einspruenge, die `mutos_io` ruft: `0BFDH` Platte (Zylinder/Sektor-Auftrag, je 128 B Rueckruf 9893), `0BEBH` Zeichenausgabe, `0BE8H` Tastenabfrage,
  `0BF1H` Textausgabe, `0EB00H` Druckertreiber (= `IFSSPR`, analyse.md §5-§7).
* Eigene Hardwarezugriffe: Interrupt an den Z8000 ueber PIO A32 und `OUT (ADH)`, Zeitgeber CTC 0DH 50 Hz mit Tastaturabfrage (Ports 5CH/5DH) im Zeitgeber-ISR, SIO Kanal A
  (tty1, Ports 50H/51H), Bedienmaske; IM2-Tabelle von UDOS (0F30..0F3E SIO, 0FE2 CTC, PIO-A32-Vektoren EAH/ECH).
* Speicher: Segmente 9000+022D, 9400+0EB0, A400+01A8, C8B6+00B2; Puffer A5B6..B936 (Platte A8B6 4 KB); Stapel **CB68**; EM-Fenster **4000H-7FFFH** (analyse.md §2-§4, Plan 39).
* Block -> (Zylinder, Sektor) rechnet `mutos_io` selbst (`SEKTOR_BERECHNEN`, 26 x 128 bzw. `K8X512`), mit 16-Bit-Blocknummer (analyse.md §12).
* Die Quelle ist nicht frei verschiebbar: neben `.PHASE 9000H/9400H/0A400H/0C8B6H` stehen Zahlen wie `0A5A8H`, `996EH`, `922CH`, `C967H`, `0F30H`, `0F3EH`, `4006H`
  (gemessen: `rg -o '\b0?[0-9A-F]{3,4}H\b' mutos_io/src/mutosio.mac | sort | uniq -c`); Inventar in C1.4.

**CP/A mit GIDE** (gemessen bzw. aus Quelle gelesen; `k1520emu: doc/merkposten/gide_cpa.md`, `k1520emu: doc/design/50_gun_gide.md`, Quelle `CPA_Workbench/src/gide_a5120/`):
* GIDE-CP/A (Variante `gide_a5120` der CPA_Workbench, bitgleich reproduzierbar gebaut): bis 4 Floppy + 8 GIDE-Laufwerke zu je 8 MB, GIDE-Basis D0H, RTC 72421 an D5H,
  Uhr in der Statuszeile; bootet von Diskette oder (Lade-ROM UL4) von der Platte.  Fertige Disketten: `k1520emu: disks/a5120_cpa_gide/` (Systemdiskette fuer **2 Floppy**, Platte 256 MB als `.img.gz`).
* Portkarte A5120 (`50_gun_gide.md` §7.1a): EM A8H-AFH und B0H-B7H, GIDE D0H-DFH -- kein Konflikt (abgeleitet; im Lauf bestaetigt, §2.1).
* CP/A-BIOS (abgeleitet aus der Quelle): Interrupts im Modus 2, Vektortabelle an einer 100H-Grenze (`bios.mac:1205` `intvec`), BDOS 0E00H lang (`bios.mac:198`), BIOS oben im Speicher;
  Laufwerkstypen je Laufwerk fest in `bios.mac:712-733` (`diskA`..`diskD`, Vorgabe `11580` = DD, DS, 5", 80 Spuren = K5601), automatische Formaterkennung (`format equ 1`, `bios.mac:745`),
  Diskettenparameter fuer zweiseitige Formate (`biosdpb.mac`) und eine 26 x 128-Uebersetzungstabelle (`biosdpb.mac:374`).  Anzahl Floppy-Laufwerke `anzdisk` 1..4 in `setup.mac`
  (`config/gide_a5120/Kconfig.system`); die GIDE-Laufwerke folgen auf die Floppys.
* Bau: `CPA_Workbench/tools/cpa_builder.py` (Klasse `CPABuilder(project_dir)`, `load_config`, `build_os`, `build_diskimage`) -- ohne Oberflaeche aufrufbar (abgeleitet, nicht erprobt).
  `python3 cpa_workbench.py --help` startet die **Oberflaeche** (gemessen 2026-11-17: blieb haengen, abgebrochen) -- nicht ohne Bildschirm aufrufen.

### 2.1 Sonden 2026-11-17 (gemessen, Arbeitsordner `/tmp/mplus/c0_sonde/`)

Aufruf (Kopien der Emulator-Disketten im Arbeitsordner; das Plattenabbild bleibt `.gz`):
```
cp <k1520emu>/disks/a5120_cpa_gide/a5120_cpa_gide_k7024_2fdd_8gide_system.hfe sys.hfe
cp <k1520emu>/disks/a5120_cpa_gide/a5120_cpa_gide_platte_256M.img.gz platte.img.gz
<k1520emu>/build/k1520dbg --em em256 --laderom ul4 --gide=0xD0 --gide-image $PWD/platte.img.gz $PWD/sys.hfe [-b $PWD/r_fm.hfe] -x s1.dbg
s1.dbg:  gscreen "A>" 300000000 / keys DIR\r / ... / screen / gide / dev em / r / d 0x0000 8 / q
```
1. **EM256 + GIDE (D0H) + RTC + GIDE-CP/A laufen in einer Maschine.**  Boot bis `A>` in 24,6 Mio. Takten, **3 s Wanduhr** fuer den ganzen Lauf.  Kopfzeile:
   `GIDE-CP/A (mod. KW), Version 31.07.25, TPA 100H - 0BD05H`, `Disketten: A:5"(80,DD,DS)/B:5"(80,DD,DS)`, `max. phys. Sektorlaenge: 1024, mit autom. Formaterkennung`,
   `GIDE-Modul auf Adresse 0D0H ... 520 Cyl; 16 Hd; 63 Sec; GIDE-Laufwerke C: bis J:`, `RTC 72421 auf Adresse 0D5H`.  `DIR C:` liest die Platte (`@OS.COM`, `PIP` ...).
   `dev em`: EM256 an A8H im Grundzustand (U8001 in RESET16), `gide`: 512 Datenlesungen ohne Fehler.
2. **Speicherlage des BIOS (Systemdiskette fuer 2 Floppy):** `d 0x0000` -> `C3 03 CB` (BIOS-Warmstart **CB03**, BIOS-Anfang **CB00**), `d 0x0005` -> `C3 06 BD` (BDOS **BD06**);
   `r` -> **`I=F7 IM=2`** (Vektortabelle F700).  Wartend steht der U880 bei `D3C5: IN A,(5DH)` (BIOS fragt die Tastatur-SIO 5DH selbst ab, wie `mutos_io`).
   *Abgeleitet daraus:* `mutos_io` (9000..CB68) ueberdeckt BDOS (BD00..CAFF) und mit seinem Stapel die ersten 68H Byte des BIOS; das EM-Fenster 4000-7FFF liegt in der TPA.
3. **MUTOS-Wurzeldisketten in B: lesbar ohne BDOS-Fehler:** `DIR B:` mit `a5120_mutos8000_root_fm.hfe` und `..._root_mfm.hfe` (beide `ss77_26x128`, laut `k1520disktool info`)
   liefert Muell-Eintraege (das V7-Dateisystem als CP/M-Verzeichnis gelesen), mit `..._root_8x512.hfe` `No File`.  **Das beweist nur, dass Spur 0/1 ohne Fehler gelesen werden**,
   nicht welche Geometrie das BIOS annimmt und ob alle Saetze richtig ankommen (C1.6).
4. Standardlaufwerke des Emulators ohne `--laufwerke`: A:/B: wie oben (die Kopfzeile meldet 5", 80, DD, DS); fuer vier Floppys ist `--laufwerke K5601,K5601,K5601,K5601` noetig (Annahme, C1.8).
5. Wirtsplatte: `/` zu 92 % belegt (24 GB frei, `df -h`), `/tmp` tmpfs 12 GB frei.  Das GIDE-Abbild **nie entpacken** (256 MB); der Emulator liest/schreibt `.img.gz` direkt.

## 3. Entwurfsfragen (Empfehlung, Entscheidung am Entscheidungspunkt §8)

1. **Plattenzugriff ueber die Standard-BIOS-Einspruenge** (`SELDSK`, `SETTRK`, `SETSEC`, `SETDMA`, `READ`, `WRITE`; 128-B-Saetze, Entblockung im BIOS) statt ueber
   interne BIOS-Routinen.  *Empfohlen*: gilt fuer Floppy und GIDE gleich, und die Sektorlaenge der Diskette ist `mutos_io` egal (ein 512-B-Block = vier Saetze).
   Zu klaeren: `SECTRAN` umgehen (MUTOS rechnet seine Verschraenkung selbst), wie das BIOS das Format eines Laufwerks kennt (fest je Laufwerk oder erkannt), wann
   zurueckgestellte Schreibsaetze (`WRITE` mit C=0) auf die Diskette gehen.  C1.5 (Quelle), C1.6 (Messung).
2. **Interrupts:** CP/A belegt IM2 selbst (Tabelle F700, gemessen).  Entweder traegt `mutos_io` seine Vektoren (PIO A32, CTC, SIO) in die CP/A-Tabelle ein
   und laesst die BIOS-Interrupts weiterlaufen, oder es uebernimmt die Maschine ganz und ruft nur noch die Platten-Einspruenge.  *Empfohlen*: Vektoren eintragen,
   BIOS-Konsole benutzen; Risiko: Zeitverhalten der BIOS-Diskettenroutinen bei laufenden Fremd-Interrupts.  C1.5, C1.7.
3. **Lage im Speicher:** *Empfohlen (neu, aus §2.1):* `mutos_io` behaelt seine Adressen (`.PHASE 9000H` ff.), weil die Analyse (`analyse.md`) und alle Debuggerskripte
   diese Adressen tragen; der Lader liest `mutos_io` in die TPA und schiebt es an 9000H, **das BDOS wird dabei ueberschrieben** (nach dem Start ruft `mutos_io` nur noch
   das BIOS).  Noetig: Stapel und alles Uebrige unter den BIOS-Anfang (2 Floppy: CB00; 4 Floppy: C1.8 misst).  Alternative: `.COM` ab 0100H -- verlangt, alle Zahlen
   aus C1.4 durch Namen zu ersetzen, und 0100..3FFF reicht knapp (Programm + Puffer ~3B68H).  Das Postfach D532 ist eine Z8000-Adresse im EM, nicht im U880-Speicher (abgeleitet).
4. **Kernel laden:** ein CP/A-Programm (Ersatz fuer `ACTIVATE`/`LOAD16`) liest den Kernel aus einer CP/A-Datei, schreibt ihn in den EM, startet den Z8000 und springt
   in `mutos_io`.  Dafuer muss `LOAD16` zuerst verstanden werden (C1.2); `ACTIVATE` laedt nur den Druckertreiber (C1.3).  *Empfohlen:* **ein** Programm `M8KBOOT.COM`
   (laedt Kernel und `mutos_io`), keine SUBMIT-Kette.
5. **Quellort:** neue Quelle `mutos_io/cpa/` (abgeleitet aus `mutos_io/src/mutosio.mac`), die UDOS-Fassung bleibt unveraendert (sie gehoert zu `main`).
   Bau mit M80/LINKMT wie bisher (`mutos_io/build.py`-Muster, `emu.cpm_bau()`), Wiederverwendbares aus der CPA_Workbench nur aufrufen, nicht kopieren.
6. **Bootdiskette:** CP/A-Systemdiskette (GIDE-Fassung, K7024) plus Lader, `mutos_io` und Kernel als CP/A-Dateien; Zusammenbau mit dem DiskTool.
7. **(neu) Zahl der Floppy-Laufwerke:** MUTOS benutzt heute vier (A `/tmp`, B `/usr`, C Wurzel, D `/mnt`; alle Gastlaeufe von Plan 47 brauchen sie).  Die fertige
   GIDE-Systemdiskette kennt **zwei** (gemessen §2.1); C:..J: sind GIDE.  *Empfohlen:* eigene CP/A-Variante mit `anzdisk = 4` (alle K5601), Bau als Sonde in C1.8.
8. **(neu) Konsole und Tastatur:** das BIOS fragt die Tastatur-SIO 5DH im `CONIN` selbst ab (gemessen §2.1), `mutos_io` im Zeitgeber-ISR.  BIOS-Routinen sind nicht
   wiedereintrittsfest (Annahme), duerfen also nicht aus einem ISR gerufen werden.  *Empfohlen:* Ausgabe ueber BIOS `CONOUT` aus der Hauptschleife (Statuszeile mit Uhr bleibt),
   Tastatur weiter selbst im Zeitgeber-ISR (wie heute) -- falls C1.5 zeigt, dass kein BIOS-Interrupt die SIO 5CH/5DH liest.
9. **(neu) Drucker und tty1:** `IFSSPR` (UDOS) wird durch BIOS `LIST` ersetzt oder als eigener Treiber in `mutos_io` uebernommen.  Konflikt (gemessen, Kopfzeile §2.1):
   CP/A-`LST:` TTY = Port **50H**, das ist die SIO Kanal A von tty1.  C1.3/C1.5.
10. **(neu) Startmedium:** CP/A-Bootdiskette in A:, nach dem Laden Diskettenwechsel in der Bedienmaske (wie heute mit UDOS) -- *empfohlen fuer C5*; Start von GIDE C:
    (UL4 ohne Diskette in A:) erst in Plan 51 P6.

## 4. Arbeitspakete

| AP | Inhalt | Abnahme |
|----|--------|---------|
| C1 | **Analyse** in neun Agentenschritten (§7): Werkzeug, `LOAD16`, `ACTIVATE`/`IFSSPR`/`PIOPR`, Inventar `mutos_io`, BIOS aus der Quelle, Formate ueber das BIOS, Interrupt-Koexistenz, CP/A mit vier Floppys, Zusammenfuehrung | Befunddateien `doc/plus/cpa/c1_*.md`, Vorlage `doc/plus/cpa_analyse.md`, Entscheidungen §8 |
| C2 | **Lader** `M8KBOOT.COM`: Kernel in den EM, Z8000 starten; Bootdiskette | Kernel laeuft an (Debugger: U8001 im Kernel, erste Postfach-Anforderung), noch ohne `mutos_io` |
| C3 | **`mutos_io` (CP/A)**: Lage, Interrupts, **Konsole/Tastatur minimal** und Plattenweg ueber das BIOS | Boot bis `#` mit bisheriger Wurzel |
| C4 | Drucker, tty1, Zeitgeber, Arbeitstests, Leistung | Arbeitstests wie Plan 47 P3.1 (`bewerten` ohne Fehlschlag) |
| C5 | Gastlauf-Werkzeug ueber CP/A, Waechter (pytest, Marke `gast`), Doku | Langtest gruen; Eintrag in `doc/plus/abweichungen.md` |

Aenderung gegenueber dem Grobplan: die Konsole ist in C3 (ohne sie ist `login:` nicht sichtbar); C4 behaelt Drucker, tty1 und die Arbeitstests.

## 5. Risiken

* Die UDOS-Startprogramme koennen mehr tun als angenommen (Speicherumschaltung, EM-Initialisierung, Paritaet) -- C1.2 klaert das vor jedem Bau.
* Das CP/A-BIOS kann einzelne MUTOS-Formate nicht (z. B. 26 x 128 MFM auf 77 Spuren in einem 80-Spur-DS-Laufwerk): dann sind die alten Wurzeldisketten ueber CP/A nicht
  nutzbar, und die Wurzel muss auf ein CP/A-Format umgezogen werden (vorgezogener Teil von Plan 49, mit DiskTool-Arbeit im Emulatorprojekt, Plan 49 B6).
* BIOS-Aufrufe sind langsamer als der direkte Nukleusweg (vier Saetze je Block, Formaterkennung); messen (C1.6), nicht annehmen.
* Eine CP/A-Variante mit vier Floppys macht das BIOS groesser und schiebt den BIOS-Anfang nach unten; `mutos_io` (bis C968 + Stapel) passt dann evtl. nicht mehr unter das BIOS (C1.8).
* `mutos_io` laeuft heute im UDOS-Speicher, der ab 0F30 Vektoren traegt; in CP/A ist 0100..BD05 TPA -- Reste der UDOS-Annahmen (Nukleus-Daten wie 01B5) muessen alle gefunden werden (C1.4).

## 6. Regeln fuer die Agenten

Es gelten **Plan 47 §6 Regeln 1-9 sinngemaess** (Lesen vor Handeln, Gastlaeufe im Hintergrund, Exit 77/Skip ohne Emulator, Befunde mit Kennzeichnung, Abnahme nicht aufweichen,
ein Commit je Schritt, parallele Agenten nur in ihren Dateien).  Ergaenzungen fuer Plan 48:

1. **Auftrag:** *"Arbeite im Worktree `/home/olliy/projects/mutos8k-plus` (Branch `mutos-plus`).  Lies `CLAUDE.md`, `doc/plan/47_mutos_plus.md` §6,
   `doc/plan/48_mutos_io_cpa.md` §2, §6 und §7 <Schritt>, fuehre genau diesen Schritt aus."*  Schritte mit Vermerk **[main]** laufen im Checkout
   `/home/olliy/projects/mutos8k` (Branch `main`), siehe Offene Entscheidung O1.
2. **Nicht anfassen** (zusaetzlich zu Plan 47 §6.2): `mutos_io/src/`, `mutos_io/build.py`, `mutos_io/ladediskette.py`, `mutos_io/mutosio.bin` (gehoeren zu `main`).
   **Ausserhalb des Repos nur lesen:** `~/projects/a5120emu` (nur ueber `tools/emu.py`: `emu.binary('k1520dbg')`, `emu.binary('k1520disktool')`, `emu.cpm_bau()`; Werkzeuge wie
   `tools/z80_disasm2.py` mit `python3 <k1520emu>/tools/z80_disasm2.py` aufrufen, nie kopieren) und `~/projects/CPA_Workbench` (Bau nur in einer Kopie unter `/tmp/mplus/`, C1.8).
   Disketten und Plattenabbilder aus beiden Projekten immer erst nach `/tmp/mplus/<schritt>/` kopieren.
3. **Gastlaeufe:** CP/A-Laeufe sind kurz (Boot ~25 Mio. Takte, Lauf 3 s, §2.1) und duerfen im Vordergrund laufen, wenn sie unter 2 Min. bleiben (`timeout` setzen).
   MUTOS-Boots (ab C2.3) und alles ueber 2 Min.: **im Hintergrund** (`run_in_background`), Ausgabe in eine Logdatei; **zusaetzlich** einen zweiten Hintergrundbefehl
   `while kill -0 <PID>; do sleep 20; done` starten, dessen Ende die Fertigmeldung sicher ausloest (Befund aus Plan 47: das Ende eines Laufs wurde mehrfach verpasst).
   Nie im Vordergrund mit `sleep` warten.
4. **Fruehe Sonde zuerst:** jeder Schritt beginnt mit der billigsten Messung, die seine Hauptannahme prueft (im Schritt unter *Erste Sonde*).  Faellt sie anders aus als
   der Plan annimmt: Befund schreiben, Stand *blockiert*, melden -- nicht den Plan im Alleingang umbauen (Plan 47 §6.7).
5. **Z80-Quellen:** M80-Syntax (`.Z80`, `CSEG`), Bau ueber `emu.cpm_bau()` (CRLF, M80, LINKMT ab 0100H).  Neue Namen und Kommentare Englisch, nur ASCII, M80-Namen
   auf 6 Zeichen eindeutig (M80/LINKMT-Grenze; *Annahme* fuer M80 - in C1.1 mit einem Probelauf pruefen).  CP/M-Dateinamen 8.3, Grossbuchstaben.
6. **Rekonstruktionen** (C1.2, C1.3) haben einen Rundlaufwaechter wie `mutos_io/build.py --check` (Quelle -> M80/LINKMT -> Bytes == Original), Exit 77 ohne Werkzeugkette.
   Probeprogramme unter `versuche/plus_cpa/` werden je Lauf gebaut und **nicht** als `.COM` eingecheckt; eingecheckt wird nur, was der Bootweg braucht (ab C2).
7. **Befunddateien:** je Schritt eine eigene Datei `doc/plus/cpa/c1_<n>_<thema>.md` (parallele Agenten schreiben nie in dieselbe Datei).  Jede Aussage *gemessen* (Befehl,
   Arbeitsordner, Datum, Takte/Wanduhr) / *abgeleitet* (Datei:Zeile) / *Annahme*.
8. **Commit:** Betreff `Plan 48 <Schritt>: <Inhalt>`, Stand-Zeile in §10 im selben Commit.  Vorher `python3 -m pytest -q tests` (bekannt rot und unabhaengig:
   `test_bau_alle_kennt_genau_die_fertigen_disketten`).  Kein Push, kein Merge (ausser C1.9 Punkt 1).

## 7. Detailplanung C1

Gemeinsame Fakten: §2 und §2.1.  Laufwerksnamen im Emulator: `--laufwerke K5601,...` wie in `doc/mutos_io/analyse.md` Kopf.  Debuggerbefehle: `k1520emu: tools/k1520dbg.md`
(`gscreen "txt" N`, `keys TEXT\r` mit `\s` fuer Leerzeichen, `screen`, `d ADR N`, `u ADR N`, `b`/`lp` Haltepunkte und Logpunkte, `dev em`, `emlog`, `gide`, `cpu u8000` §12).

### C1.1 Werkzeug fuer CP/A-Sonden (`tools/plus/cpa.py`)
*Haengt ab von:* nichts.  *Gastlauf:* ja, kurz (Sekunden).
*Lesen:* `tools/emu.py`, `k1520emu: tools/cpm_bau.py` (Klasse `Programm`, `baue`, `werkzeugkette_da`), `k1520emu: tools/em256/README.md`, §2.1 dieses Plans, `tools/plus/gastlauf.py` (Muster fuer Exit 77).
*Erste Sonde:* den Lauf aus §2.1 mit `emu.binary('k1520dbg')` nachstellen (Kopfzeile `GIDE-CP/A` auf dem Schirm).
*Tun:* `tools/plus/cpa.py` (Englisch, stdlib, Exit 77 ohne Emulator oder ohne Werkzeugkette):
* `GIDE_SYS`, `GIDE_PLATTE` = Pfade der Emulator-Disketten (`emu.emulator()` + `disks/a5120_cpa_gide/...`).
* `diskette(arbeit, name, quelle=GIDE_SYS, dateien={})`: Kopie nach `arbeit`, `dateien` ({`NAME.EXT`: bytes}) per `k1520disktool put` hinein.
* `com(name, quellordner)`: baut `<quellordner>/<name>.mac` mit `emu.cpm_bau()` in ein Wegwerfverzeichnis, gibt die Bytes zurueck.
* `lauf(arbeit, zeilen, a, b=None, c=None, d=None, laufwerke=None, em='em256', gide=True, frist=120)`: schreibt `lauf.dbg`, ruft `k1520dbg --em ... --laderom ul4 --gide=0xD0
  --gide-image <kopie>` (Platte als Kopie im Arbeitsordner, `.gz`), gibt das Log zurueck; `schirm(log)` holt den letzten `screen`-Block.
* Kommandozeile `cpa.py probe --arbeit DIR`: baut `versuche/plus_cpa/hallo.mac` (BDOS 9: `HALLO MUTOS`), legt `HALLO.COM` auf die Systemdiskette, startet, prueft den Schirm.
* zweite Probe im selben Werkzeug: `EM16ABL.COM` und `EM256ADR.COM` aus `k1520emu: tools/em256/` (nur auf die Wegwerf-Diskette legen) unter dem GIDE-CP/A mit EM256 laufen lassen.
* M80-Namenslaenge: in `hallo.mac` zwei Marken, die sich erst im 7. Zeichen unterscheiden; Ergebnis (Fehler oder nicht) in den Befund.
*Schreibt:* `tools/plus/cpa.py`, `versuche/plus_cpa/hallo.mac`, `versuche/plus_cpa/README.md`, `tests/test_plus_cpa.py` (schnell: Import + Exit-77-Verhalten; `gast`: `probe`), `doc/plus/cpa/c1_1_werkzeug.md`.
*Abnahme:* `python3 -I tools/plus/cpa.py probe --arbeit /tmp/mplus/c1_1` zeigt `HALLO MUTOS`; `EM16ABL` und `EM256ADR` melden unter dem GIDE-CP/A dasselbe Ergebnis wie unter
dem normalen CP/A (`k1520emu: tools/em256/README.md`, Zeilen `OK`/`ERGEBNIS`); `K1520EMU=/nonexistent python3 -m pytest -q tests/test_plus_cpa.py` -> skip, nicht rot.
*Dauer:* ~2 h.

### C1.2 `LOAD16` rekonstruieren und messen **[main]**
*Haengt ab von:* nichts.  *Gastlauf:* ja, kurz (UDOS-Boot ~80 Mio. Takte, Sekunden).
*Lesen:* Plan 39 §2 und Tabelle Zeile 680-700, `doc/mutos_io/analyse.md` §3-§4 und §10 (Ports A8H-AFH), `k1520emu: doc/design/17_a5120_16.md` (EM-Register, A22, A33, PIO A32,
RESET16), `k1520emu: tools/k1520dbg.md` §12 (`emlog`, `cpu u8000`), `mutos_io/README.md` (Bau- und Rundlaufmuster), `k1520emu: tools/z80_disasm.md`.
*Erste Sonde:* `LOAD16` aus der Ladediskette holen (`k1520disktool get <k1520emu>/disks/a5120_16_MUTOS/a5120_mutos8000_boot_udos_k5601.hfe LOAD16 --to DIR`; erwartet 512 B
und `.fileinfo` mit Start 5000) und einmal mit `z80_disasm2.py --format mac` disassemblieren; Umfang abschaetzen.
*Tun:*
1. Quelle `mutos_io/udos/load16.mac` (Karte `mutos_io/udos/load16.karte` wie `mutos_io/karte.txt`), kommentiert, Namen Englisch; Bau `mutos_io/udos/build.py`
   (Muster `mutos_io/build.py`, `cpm_bau.Programm(..., endung='bin')`), `--check` = bytegleich mit der Datei der Ladediskette.
2. Messen (Debugger auf der UDOS-Ladediskette, `BOOT MUTOS`, Haltepunkt 5000, `emlog` an, Logpunkte auf jedes `OUT` an A8H-AFH/B0H und auf die UDOS-Aufrufe):
   Fragen, je mit Beleg: (a) welche UDOS-Dienste `LOAD16` zum Dateilesen ruft; (b) Reihenfolge der EM-Initialisierung (PIO A32 Modi/Vektoren, A22-Seiten, A33, Paritaet/PR,
   /RAMEN); (c) wohin der Kernel geschrieben wird (Segment, Adressen, Seitenweise ueber das Fenster 4000-7FFF?) und wie viel (feste Laenge oder Dateilaenge; nimmt es mehr
   als 36 352 B an?); (d) wie der U8001 gestartet wird (RESET16, /STOP, Segmentmodus, erste Befehle des Kernels); (e) welchen Zustand `LOAD16` fuer `mutos_io` hinterlaesst
   (Seiten, PIO, Interrupts, Bus); (f) was davon `mutos_io` selbst noch einmal tut (Abgleich mit `analyse.md` §3 Init 9400..9410).
*Schreibt:* `mutos_io/udos/load16.mac`, `mutos_io/udos/load16.karte`, `mutos_io/udos/build.py`, `mutos_io/udos/README.md`, `tests/test_udos_lader.py` (`--check`, Skip ohne
Werkzeugkette), `doc/mutos_io/udos_lader.md` §1 (Befund; Deutsch).  Debuggerskripte unter `versuche/dbg/load16_*.dbg`.
*Abnahme:* `python3 -I mutos_io/udos/build.py --check` -> 0; Fragen (a)-(f) beantwortet, (b)-(e) *gemessen*.
*Dauer:* ~3 h.

### C1.3 `ACTIVATE`, `IFSSPR`, `PIOPR` **[main]**
*Haengt ab von:* nichts (parallel zu C1.2; eigene Dateien, gemeinsames `mutos_io/udos/build.py` legt C1.2 an -- C1.3 legt seine Programme in derselben Liste an und
committet nach C1.2, oder baut bis dahin mit eigener Liste in `mutos_io/udos/build_drucker.py`; Entscheidung des Agenten, im Befund nennen).
*Gastlauf:* ja, kurz.
*Lesen:* wie C1.2, dazu `doc/mutos_io/analyse.md` §7 (Drucker 91A8 -> `CALL 0EB00H`, IY = AUF1 A567, Rueckruf 91E1), `versuche/dbg/mutos_io_tty_drucker.dbg`,
`k1520emu: tools/boot_trace_printer.h` (welche Drucker der Emulator an welchen Ports kennt).
*Erste Sonde:* Debugger auf der UDOS-Ladediskette nach `BOOT MUTOS`: `d 0xEB00 768` gleich der Datei `IFSSPR`?  (Zeigt, ob `ACTIVATE` den Treiber nur ablegt oder veraendert.)
*Tun:*
1. `ACTIVATE` (Zilog-Standard, 1024 B) **nicht** rekonstruieren; nur messen, was es mit `$IFSSPR` tut: Ladeort, Eintraege in Nukleus-Tabellen (Speicher vor/nach vergleichen, `d`).
2. `IFSSPR` (768 B) und `PIOPR` (640 B) als `mutos_io/udos/ifsspr.mac`, `piopr.mac` mit Rundlauf.
3. Befund: Aufrufschnittstelle bei EB00 (Register, Parameterblock IY, Rueckruf, Fehlerweg), benutzte Ports und Signale (IFSS = Stromschleife ueber welchen Baustein?),
   Interrupts (eigene Vektoren?), Abgleich mit CP/A `LIST`/IOBYTE (Kopfzeile §2.1: `LST:` TTY = 50H, LPT = 5EH).  Empfehlung fuer §3.9.
4. Messung `cat /etc/motd > /dev/lp` mit Portprotokoll (Logpunkte), ob der Emulator die Zeichen am Drucker sieht.
*Schreibt:* `mutos_io/udos/ifsspr.mac`, `piopr.mac` (+ Karten, Bauliste), `doc/mutos_io/udos_lader.md` §2, `versuche/dbg/ifsspr_*.dbg`.
*Abnahme:* Rundlauf beider Treiber gruen; Schnittstelle und Ports *gemessen*; Empfehlung fuer §3.9 mit Begruendung.
*Dauer:* ~3 h.

### C1.4 Inventar von `mutosio.mac` fuer den Umzug
*Haengt ab von:* nichts.  *Gastlauf:* nein (hoechstens kurze Debuggerproben auf der UDOS-Ladediskette).
*Lesen:* `mutos_io/src/mutosio.mac` (ganz), `doc/mutos_io/analyse.md` (ganz), `doc/plus/feste_adressen.md` (Form der Tabelle), §2.1.
*Erste Sonde:* `rg -n '\b0?[0-9A-F]{3,4}H\b' mutos_io/src/mutosio.mac | wc -l` und `rg -n 'CALL\s+0[0-9A-F]+H|JP\s+0[0-9A-F]+H' mutos_io/src/mutosio.mac` -- Umfang.
*Tun:* jede Zahl, die eine Adresse sein kann, und jeden UDOS-Bezug klassifizieren:
* **U** UDOS-Dienst oder -Datum (0BE8, 0BEB, 0BF1, 0BFD, 0EB00, Nukleusbereich 01B5.., UDOS-Vektortabelle 0F30..0FE2, Setzen von `I`) -> geplanter CP/A-Ersatz.
* **H** Hardwareport (fest, bleibt): A8H-AFH, ACH/ADH, 0DH, 50H-53H, 58H/5AH, 5CH/5DH, 1CH.
* **E** EM-Adresse (Z8000-Seite: 4006H, D532, D26A ...) -- bleibt.
* **A** interne Adresse als Zahl statt Name (z. B. `0A5A8H`, `996EH`, `922CH`, `C967H`) -> Name einsetzen (fuer jede Verschiebung noetig).
* **K** Konstante.
Dazu: (1) Speicherkarte von `mutos_io` (Segmente, Puffer, Ringe, Stapel, EM-Fenster) neben der CP/A-Karte aus §2.1, mit Vorschlag fuer §3.3;
(2) **Ablauf des Plattenauftrags** 9800..9904 mit dem Nukleus: kehrt `0BFDH` vor dem Ende der Uebertragung zurueck (asynchron mit Rueckruf je 128 B) oder synchron?
Was tut die Hauptschleife waehrenddessen?  Daraus: was sich mit einem synchronen BIOS-`READ` aendert; (3) die Rechnung Block -> (Zylinder, Sektor) in Formeln (26 x 128 und `K8X512`),
damit C1.6 sie gegen das BIOS pruefen kann; (4) welche Interrupts `mutos_io` erwartet und welche der UDOS-Nukleus waehrend des Betriebs selbst noch bedient (Messung: Haltepunkte
auf die UDOS-ISRs waehrend eines Boots, nur wenn aus der Quelle nicht klar).
*Schreibt:* `doc/plus/cpa/c1_4_inventar.md` (Tabelle Datei:Zeile, Wert, Klasse, Bedeutung, CP/A-Ersatz; Suchbefehle im Dokument).
*Abnahme:* jede Fundstelle der beiden `rg`-Muster klassifiziert; jede U-Zeile mit Ersatzvorschlag; Fragen (1)-(4) beantwortet.
*Dauer:* ~2-3 h.

### C1.5 CP/A-BIOS aus der Quelle
*Haengt ab von:* nichts.  *Gastlauf:* kurze Debuggerproben (Dumps nach dem Boot), Muster §2.1.
*Lesen:* `~/projects/CPA_Workbench/src/gide_a5120/` (`bios.mac`, `setup.mac`, `biosdsk*.mac`, `biosdpb*.mac`, `biosgide.mac`, `biosgipb.mac`, `bioskbd*.mac`, `biostim*.mac`,
`bioscrt*.mac`, `bioscsio.mac`, `biosmem.mac`; nur lesen), `k1520emu: doc/merkposten/gide_cpa.md`, CP/M-2.2-BIOS-Schnittstelle (allgemein bekannt).
*Erste Sonde:* nach dem Boot `d 0xCB00 0x60` (Sprungleiste) und `d 0xF700 0x100` (Vektortabelle) -- welche Eintraege sind belegt.
*Tun:* je Frage Antwort mit Fundstelle (Datei:Zeile) und, wo billig, Debuggerbeleg:
1. Sprungleiste ab CB00: alle Einspruenge (auch CP/A-Zusaetze), Registerkonventionen.
2. Platte: was `SETSEC` erwartet (0- oder 1-basiert, logischer 128-B-Satz), ob `READ`/`WRITE` selbst uebersetzen; Entblockung (Hostpuffer, wann ein zurueckgestellter
   Schreibsatz geschrieben wird: `WRITE` C=0/1/2, `HOME`, `SELDSK`); Formaterkennung (wann: beim ersten `SELDSK` mit E Bit 0 = 0?, was bei unbekanntem Format);
   Spurzaehlung bei DS (Spur*2+Seite oder Seite ueber Sektornummer); GIDE-Laufwerke (Spuren, Saetze je Spur, 8 MB = 16 384 Bloecke zu 512 B?); Fehlerrueckmeldung und Wiederholungen.
3. Interrupts: welche Vektoren der Tabelle F700 belegt sind, welche Bausteine das BIOS programmiert (ZRE-CTC 0CH-0FH? Kanal 1 = Port 0DH, den `mutos_io` fuer 50 Hz nimmt;
   PIO, SIO), welche ISRs laufen (Uhr der Statuszeile, Diskettenmotor, Tastatur?); wie lange `DI` in den Diskettenroutinen (Quelle; Messung in C1.7).
4. Konsole: `CONOUT` (Steuerzeichen, Statuszeile, Bildschirm K7024), `CONST`/`CONIN` (Tastatur K7637 an 5CH/5DH, Abfrage oder Interrupt).
5. `LIST` und IOBYTE: Ports und Bausteine (TTY 50H, LPT 5EH laut Kopfzeile).
6. Speicher: was das BIOS ab CB00 belegt (Puffer, Bildwiederholspeicher, CCP-Kopie bei `ccpload=0`), was unter CB00 nach dem Start noch gebraucht wird.
7. RTC-Routinen (fuer Plan 50 vormerken, nicht vertiefen).
*Schreibt:* `doc/plus/cpa/c1_5_bios.md`.
*Abnahme:* Fragen 1-6 mit Fundstelle beantwortet; Dumps CB00/F700 *gemessen*; Liste "frei fuer `mutos_io`" (Vektorplaetze, CTC-Kanaele, Speicher).
*Dauer:* ~3 h.

### C1.6 MUTOS-Formate ueber das BIOS lesen und schreiben
*Haengt ab von:* C1.1 (Werkzeug), C1.5 (Konventionen von `SETSEC`/`WRITE`).  Kann ohne C1.4 beginnen; Punkt 4 braucht C1.4 (3).  *Gastlauf:* ja, kurz bis mittel (Minuten).
*Lesen:* `doc/plus/cpa/c1_1_werkzeug.md`, `c1_5_bios.md`, `tools/plus/cpa.py`, `k1520emu: tools/k1520disktool.md` (`info`, `measure`, `save-as`, GIDE-Abschnitt `lw0/NAME`).
*Erste Sonde:* Programm `versuche/plus_cpa/rdtest.mac` liest ueber die **BIOS-Sprungleiste** (Adresse aus 0001H, nicht BDOS) Spur 0..2 von B: Satz fuer Satz und schreibt sie als
Datei auf C: (GIDE, BDOS-Dateifunktionen); Host holt die Datei aus der Plattenkopie (`k1520disktool get platte.img.gz lw0/RAW.BIN`).
*Tun:*
1. `RDTEST.COM`: Parameter Laufwerk, erste/letzte Spur; je Spur alle Saetze `1..SPT` (bzw. nach C1.5) ueber `SELDSK`/`SETTRK`/`SETSEC`/`SETDMA`/`READ` ohne `SECTRAN`;
   gibt SPT und Spurzahl aus dem DPB aus und die Takte (Debugger: Zykluszaehler vor/nach) je 100 Saetze.
2. Host: Sollinhalt jeder Diskette als Satzfolge (Spur, Sektor) aus dem Abbild (`k1520disktool save-as` nach `.img` oder `measure`; Reihenfolge belegen) und mit `RAW.BIN` vergleichen.
3. Durchlauf fuer `a5120_mutos8000_root_fm.hfe`, `..._root_mfm.hfe`, `..._root_8x512.hfe` (aus `<k1520emu>/disks/a5120_16_MUTOS/`) und ein GIDE-Laufwerk (D:):
   erkanntes Format (DPB), alle Saetze gleich ja/nein (erste Abweichung), Takte je 512 B.
4. Abgleich mit der Blockrechnung von `mutos_io` (C1.4 (3)): liefert (Spur, Satz) ueber das BIOS dieselben 512 B wie heute ueber den Nukleus?  Regel fuer `mutos_io` als Formel.
5. `WRTEST.COM` (Kopie der Diskette): Muster in 8 verstreute Saetze schreiben (mit `WRITE` C=0 und C=1), dann ohne Warmstart weiter lesen; Host prueft die Kopie
   (Debugger `--rw` **nur auf die Kopie** im Arbeitsordner).  Antwort: wann ist ein Satz wirklich auf der Diskette.
*Schreibt:* `versuche/plus_cpa/rdtest.mac`, `wrtest.mac`, `tools/plus/cpa.py` (nur Hilfsfunktionen ergaenzen), `doc/plus/cpa/c1_6_formate.md`.
*Abnahme:* Tabelle Format x {gelesen gleich, geschrieben gleich, Takte/512 B} fuer die drei Wurzeldisketten und ein GIDE-Laufwerk, *gemessen*; Formel Block -> (Spur, Satz) je Format.
*Dauer:* ~3-4 h.

### C1.7 Interrupt-Koexistenz mit dem BIOS
*Haengt ab von:* C1.1, C1.5 (freie Vektorplaetze, CTC-Kanaele).  *Gastlauf:* ja, kurz.
*Lesen:* `doc/plus/cpa/c1_5_bios.md`, `doc/mutos_io/analyse.md` §1.3, §4 (CTC 0DH `A7H`/`C0H` = 50 Hz; PIO A32 Vektoren EAH/ECH), `mutos_io/src/mutosio.mac` Zeitgeber-ISR 947E.
*Erste Sonde:* nur den 50-Hz-ISR eintragen (Vektorplatz nach C1.5) und 10 s Maschinenzeit am Prompt zaehlen: kommen 500 Ticks?  Laeuft die Uhr der Statuszeile weiter?
*Tun:* `versuche/plus_cpa/itest.mac`: traegt einen CTC-ISR wie `mutos_io` ein (Zaehler), dann (a) 400 Saetze ueber BIOS `READ` von B:, (b) 2000 Zeichen ueber `CONOUT`, (c) 200 Saetze
`WRITE` auf eine Kopie; misst Ticks gegen Maschinentakte (erwartet 1 Tick je 49 152 Takte, `analyse.md` §1.3), laengste Luecke zwischen zwei Ticks (Debugger-Logpunkt im ISR mit Takt),
und ob die gelesenen Daten stimmen.  Zusaetzlich: PIO-A32-Vektor in die Tabelle eintragen und einen INT-16 vom U8001 ausloesen ist **nicht** Teil dieses Schritts (C2/C3).
*Schreibt:* `versuche/plus_cpa/itest.mac`, `doc/plus/cpa/c1_7_interrupts.md`.
*Abnahme:* Ticks und laengste Luecke je Fall (a)-(c) *gemessen*; Aussage, ob Ticks verloren gehen und ob das BIOS mit dem Fremd-ISR richtig liest/schreibt; Empfehlung fuer §3.2 und §3.8.
*Dauer:* ~2 h.

### C1.8 CP/A-Variante mit vier Floppy-Laufwerken (Sonde)
*Haengt ab von:* nichts (C1.1 hilft beim Startversuch, ist aber nicht noetig).  *Gastlauf:* ja, kurz.
*Lesen:* `~/projects/CPA_Workbench/README.md`, `tools/cpa_builder.py` (`CPABuilder`, `load_config`, `build_os`, `build_diskimage`, `_get_disk_format`), `config/gide_a5120/`,
`src/gide_a5120/setup.mac`, `bios.mac:680-740`; `k1520emu: doc/merkposten/gide_cpa.md` (Festlegung 1: Emulator braucht `crt = k7024`).
**Nie** `cpa_workbench.py` ohne Argumente starten (Oberflaeche, haengt).  In `~/projects/CPA_Workbench` nichts schreiben: Kopie von `src/`, `config/`, `prebuilt/`, `tools/`,
`additions/`, `diskdefs/`, `cpaFormates.cfg` nach `/tmp/mplus/c1_8/wb/` (~7 MB) und dort bauen.
*Erste Sonde:* in der Kopie die unveraenderte Konfiguration `gide_a5120` mit `crt = k7024` ohne Oberflaeche bauen (`CPABuilder(...).build_os(config)`) und `@OS.COM` mit dem
`@OS.COM` der Emulator-Systemdiskette vergleichen (`k1520disktool get`).  Gleich -> der Bauweg ist reproduzierbar; sonst Befund und anhalten.
*Tun:*
1. Konfiguration mit `anzdisk = 4` (alle `11580`), sonst wie die Emulator-Diskette; `@OS.COM` bauen.
2. Systemdiskette: Kopie der Emulator-Systemdiskette mit dem neuen System in den Systemspuren (Weg aus der Workbench: `build_diskimage` oder `k1520disktool create --boot` / `boot-get`;
   welcher Weg geht, ist Teil des Befunds).
3. Start mit `--laufwerke K5601,K5601,K5601,K5601` und GIDE: Kopfzeile (Disketten A:-D:, GIDE E: bis L:?), `TPA 100H - ...`, `d 0x0000 3` (BIOS-Anfang), `r` (I-Register),
   `DIR` auf C: und D: mit MUTOS-Disketten (wie §2.1 Punkt 3).
4. Vorschlag, wo die Konfiguration der MUTOS-CP/A-Variante liegen soll (Offene Entscheidung O3) und wie der Bau ohne Aenderung der Workbench ablaeuft (Skript-Entwurf im Befund, nicht einchecken).
*Schreibt:* `doc/plus/cpa/c1_8_vier_floppy.md` (mit der benutzten Konfiguration als Textblock).
*Abnahme:* entweder bootfaehige 4-Floppy-Systemdiskette (Kopfzeile und BIOS-Anfang *gemessen*) oder belegter Grund, warum nicht (dann Entscheidung §3.7 neu).
*Dauer:* ~2-4 h (Risiko: Bauweg der Workbench ohne Oberflaeche).

### C1.9 Zusammenfuehrung und Entscheidungsvorlage
*Haengt ab von:* C1.1-C1.8.  *Gastlauf:* nein.
*Tun:*
1. Falls C1.2/C1.3 auf `main` liefen: `main` in `mutos-plus` mergen (`git merge main`, Konflikte nur in Doku erwartet; bei Konflikten in Code anhalten und melden).
2. `doc/plus/cpa_analyse.md`: Kurzfassung aller Befunde (je Thema 3-6 Zeilen mit Verweis auf die Befunddatei), Speicherkarte U880 unter CP/A (Vorschlag), Tabelle der
   UDOS-Abhaengigkeiten mit Ersatz, Messwerte (Takte je Block, Ticks), Liste der Abweichungen vom Plan.
3. Fuer jede Entscheidung E1-E9 (§8) eine Vorlage: Optionen, Messwerte, Empfehlung.  **Nicht selbst entscheiden**: die Vorlage geht an den Projektinhaber.
4. Nach der Entscheidung (eigener Auftrag): §8 "Ergebnis" ausfuellen, §9 fuer die gewaehlten Varianten endgueltig machen (Form wie §7), Stand-Tabelle §10 ergaenzen.
*Schreibt:* `doc/plus/cpa_analyse.md`, §8/§9/§10 dieses Plans.
*Abnahme:* jede Entscheidung E1-E9 hat Optionen, Messwerte mit Verweis und eine Empfehlung; keine Aussage ohne Kennzeichnung.
*Dauer:* ~1-2 h.

## 8. Entscheidungspunkt nach C1

Die Entscheidungen fallen durch den Projektinhaber auf Grundlage von `doc/plus/cpa_analyse.md`.  Je Entscheidung: woraus sie folgt, Optionen, vorlaeufige Empfehlung,
und was sich in C2-C5 je nach Ausgang aendert.

| # | Frage (§3) | Grundlage | Optionen | vorlaeufige Empfehlung | Folge fuer C2-C5 |
|---|-----------|-----------|----------|------------------------|------------------|
| E1 | Plattenweg (§3.1) | C1.5, C1.6 | (a) BIOS-Standardeinspruenge; (b) interne BIOS-Routinen; (c) eigener FDC-Treiber in `mutos_io` | (a), wenn C1.6 alle Saetze der Wurzeldisketten gleich liest | (a): C3.3 wie §9.  (b)/(c): C3.3 doppelt so gross, GIDE spaeter extra.  Liest CP/A die 26 x 128-Disketten **nicht** richtig: Wurzel-Umzug auf ein CP/A-Format vor C3 (Teil von Plan 49 B1/B5/B6 vorziehen, eigener Plan) |
| E2 | Interrupts (§3.2) | C1.5, C1.7 | (a) Vektoren in die CP/A-Tabelle, BIOS-ISRs laufen weiter; (b) Maschine uebernehmen (eigene Tabelle, BIOS-ISRs aus) | (a), wenn C1.7 keine Tick-Verluste ueber 1 Tick zeigt | (b): `mutos_io` muss die BIOS-ISRs, die `READ` braucht, nachbilden oder abschalten -- C3.2 groesser, Uhr der Statuszeile steht |
| E3 | Lage (§3.3) | C1.4, C1.8 | (a) `.PHASE 9000H` behalten, BDOS ueberschreiben, Stapel unter den BIOS-Anfang; (b) `.COM` ab 0100H; (c) andere feste Lage unter dem BIOS | (a), wenn der BIOS-Anfang der 4-Floppy-Variante >= C968 + Stapel | (b)/(c): erst alle A-Zahlen aus C1.4 durch Namen ersetzen (eigener Schritt C3.1b) |
| E4 | Lader (§3.4) | C1.2 | (a) ein `M8KBOOT.COM` laedt Kernel und `mutos_io`; (b) Lader nur fuer den Kernel, `mutos_io` als eigenes `.COM` | (a) | (b): `mutos_io` muss sich selbst an 9000 schieben |
| E5 | Laufwerke (§3.7) | C1.8 | (a) 4-Floppy-CP/A-Variante; (b) 2 Floppy + GIDE fuer `/tmp`/`/mnt` | (a) | (b): braucht MUTOS-Dateisystem auf GIDE im DiskTool (Emulatorprojekt) und aendert alle Gastlauf-Werkzeuge -- nicht vor Plan 51 |
| E6 | Konsole/Tastatur (§3.8) | C1.5, C1.7 | (a) Ausgabe BIOS `CONOUT`, Tastatur selbst im Zeitgeber-ISR; (b) beides ueber BIOS (Abfrage `CONST` in der Hauptschleife); (c) beides selbst (K7024 direkt) | (a) | (b): Tastatur nur bei freier Hauptschleife (waehrend `READ` keine Zeichen) -- C1.7 sagt, ob das stoert.  (c): Statuszeile/Uhr weg |
| E7 | Drucker/tty1 (§3.9) | C1.3, C1.5 | (a) BIOS `LIST` mit IOBYTE auf LPT (5EH); (b) Treiber aus `IFSSPR` in `mutos_io` uebernehmen; (c) Drucker zunaechst weglassen | (a), falls der IFSS-Weg im Emulator gleich ankommt; sonst (b) | tty1 bleibt eigener SIO-A-Treiber; `LST:` darf nicht auf TTY (50H) stehen |
| E8 | Startmedium (§3.10) | C1.8 | (a) CP/A-Bootdiskette in A:, Wechsel in der Bedienmaske; (b) Start von GIDE | (a) | (b) erst Plan 51 P6 |
| E9 | Ablage der CP/A-Variante (O3) | C1.8 | (a) Konfiguration in diesem Repo, Bau ueber eine Kopie der Workbench; (b) eigene Variante in der Workbench (Projektinhaber pflegt sie dort) | (a) | (b): C5 haengt von einem Workbench-Stand ab |

**Ergebnis:** *(nach C1.9 eintragen: Datum, Entscheidung je Zeile, Verweis)*

## 9. C2-C5 (vorlaeufig, fuer die Empfehlungen E1a, E2a, E3a, E4a, E5a, E6a, E7a, E8a)

Weicht eine Entscheidung ab, passt C1.9 Punkt 4 die betroffenen Schritte an (Spalte "Folge" in §8).  Die Form der Schritte ist dieselbe wie in §7; *Lesen* ergaenzt C1.9.

### C2.1 Lader `M8KBOOT.COM`
*Haengt ab von:* E3, E4; Befund C1.2.  *Gastlauf:* kurz.
*Tun:* `mutos_io/cpa/m8kboot.mac` (Englisch): Kernel `MUTOS.SYS` (Datei des Kernels, 8.3) per BDOS in Stuecken lesen und ueber das EM-Fenster 4000-7FFF in den EM schreiben
(Lesepuffer **ausserhalb** 4000-7FFF), EM-Initialisierung und Start des U8001 wie `LOAD16` (C1.2 (b)-(d)), dann `MUTOSIO.BIN` lesen, nach 9000H ff. schieben (Segmente wie
`mutos_io`), BIOS-Anfang pruefen (Abbruch mit Meldung, wenn `mutos_io` hineinragt), springen.  Schalter (Kommandozeile `K`): nur Kernel laden und starten, danach Halteschleife (fuer C2.3).
`mutos_io/cpa/build.py` (Muster `mutos_io/build.py`, `--check`), `.COM` eingecheckt.
*Abnahme:* Rundlauf `--check`; Probelauf `M8KBOOT K` ohne EM-Karte meldet Fehler statt zu haengen.

### C2.2 Bootdiskette `tools/plus/cpa_disk.py`
*Haengt ab von:* C1.8 (Systemdiskette 4 Floppy), C2.1.  *Gastlauf:* nein.
*Tun:* Systemdiskette (aus C1.8, Bau nach E9) + `M8KBOOT.COM`, `MUTOS.SYS` (Kernel: Vorgabe `mutos_1216` der Original-Ladediskette, wahlweise Datei), `MUTOSIO.BIN`;
Kaltstartkommando der Variante auf `M8KBOOT` nur, wenn die Workbench das ohne Aenderung kann (sonst Eingabe per `keys`).
*Abnahme:* `k1520disktool ls` zeigt die Dateien mit richtigen Laengen; Test `tests/test_plus_cpa.py::test_bootdiskette` (gast).

### C2.3 Abnahme C2: Kernel laeuft an
*Haengt ab von:* C2.1, C2.2.  *Gastlauf:* kurz.
*Tun/Abnahme:* `M8KBOOT K` im Debugger: EM-Inhalt Segment 0 ab 0 == Kernel-Datei (Dump ueber `cpu u8000`/`d`, Vergleich auf dem Host), U8001 laeuft im Kerneltext (PC < 8DC2),
und die erste Postfach-Anforderung steht an (EM 4006 != 0, A33 Bit 4 = INT-16) -- der Kernel wartet auf `mutos_io`.  Befund `doc/plus/cpa/c2_lader.md`.

### C3.1 Quelle `mutos_io/cpa/mutoscpa.mac` anlegen
*Haengt ab von:* C2.1 (Baugeruest).  *Gastlauf:* nein.
*Tun:* Kopie von `mutos_io/src/mutosio.mac`; Bau `mutos_io/cpa/build.py` um `mutoscpa` ergaenzen.  **Erster Commit: unveraenderte Kopie baut bytegleich zu `mutos_io/mutosio.bin`**
(Bezugspunkt fuer alle weiteren Diffs).  Dann alle A-Zahlen aus C1.4 durch Namen ersetzen -- weiterhin bytegleich.  Deutsche Kommentare, die beruehrt werden, uebersetzen.
*Abnahme:* zwei Rundlaeufe bytegleich (Waechter `tests/test_plus_cpa.py::test_mutoscpa_basis` prueft das am Commit der Kopie per `git show`).

### C3.2 Lage, Start, Interrupts, Konsole (minimal)
*Haengt ab von:* C3.1, C2.3, E2/E3/E6.  *Gastlauf:* ja, Minuten (MUTOS-Boot im Hintergrund).
*Tun:* Stapel unter den BIOS-Anfang; `I` vom BIOS uebernehmen, Vektoren (PIO A32 EAH/ECH, CTC, SIO) in freie Plaetze der CP/A-Tabelle (C1.5); UDOS-Initialisierung, die CP/A
schon gemacht hat, weglassen (C1.4); `0BEBH`/`0BF1H` -> BIOS `CONOUT` (aus der Hauptschleife), `0BE8H` (Bedienmaske) -> eigene Abfrage wie im Zeitgeber-ISR oder BIOS `CONIN`
vor dem Start der Interrupts.  Platte noch ueber einen Stummel, der Fehler meldet.
*Abnahme:* Bedienmaske erscheint, `r` wird angenommen, der Kernel meldet `mem = 196608` auf dem Schirm (Konsolenweg Klasse 2), dann Plattenfehler (erwartet).

### C3.3 Plattenweg ueber das BIOS
*Haengt ab von:* C3.2, C1.6 (Formel), E1.  *Gastlauf:* ja.
*Tun:* `9800..9904` ersetzen: Einheit -> CP/A-Laufwerk ueber die Tabelle der Bedienmaske (A12A, Werte jetzt Laufwerksbuchstaben 0..3 = A:-D:), Block -> (Spur, Satz) nach C1.6,
vier `READ`/`WRITE` je Block, Schreiben nach C1.6 (5) so, dass der Satz sicher auf der Diskette ist (C=1 oder Abschluss nach C1.5); Fehler -> Status wie heute (>= 40H).
Rueckruf-/Fertigweg (9163) bleibt.  Laufwerkstabelle so anlegen, dass Plan 49/51 weitere Einheiten (GIDE) eintragen koennen.
*Abnahme:* Boot bis `#` mit `a5120_mutos8000_root_mfm.hfe` in C: (rk2), `ls -l /`, `sync`, Neustart, Dateisystem unveraendert lesbar.  Befund `doc/plus/cpa/c3_mutos_io.md`.

### C4.1 Drucker und tty1
*Haengt ab von:* C3.3, E7.  *Gastlauf:* ja.
*Tun:* `0EB00H` -> BIOS `LIST` (IOBYTE auf LPT) bzw. nach E7; tty1 (SIO A) unveraendert pruefen; SIO-Vektoren aus der UDOS-Tabelle 0F30.. in die CP/A-Tabelle.
*Abnahme:* `cat /etc/motd > /dev/lp` kommt am Drucker des Emulators an; `cat /etc/motd > /dev/tty1` sendet 44 Zeichen ueber 50H (wie `analyse.md` §7).

### C4.2 Arbeitstests und Leistung
*Haengt ab von:* C4.1, C5.1.  *Gastlauf:* ja (~2-5 Min. je Lauf, Hintergrund).
*Tun/Abnahme:* `gastbau.TESTS` ueber den CP/A-Start (`tools/plus/cpa_lauf.py`, C5.1): `bewerten` ohne Fehlschlag mit dem Original-Kernel und dem P3.4-Kernel (sha256 `a0e2a9c5...`);
Zeit Boot bis `#` und Takte je Plattenblock gegen den UDOS-Weg (`gastbau.py boot`).  Befund `doc/plus/cpa/c4_arbeitstests.md`.

### C5.1 Gastlauf-Werkzeug ueber CP/A `tools/plus/cpa_lauf.py`
*Haengt ab von:* C2.2, C3.2 (Bedienmaske ueber CP/A); kann parallel zu C3.3 entstehen.  *Gastlauf:* ja.
*Lesen:* `tools/kernel/gast_as.py` (`dbg_skript`, `gast_befehle`: Muster, nicht aendern), `tools/plus/gastlauf.py`, `tools/plus/gastbau.py` (`boot`, `testdateien`).
*Tun:* wie `gastlauf.lauf`, aber Start: CP/A-Bootdiskette in A: (`--laderom ul4 --gide=0xD0`, Platte als Kopie, `--laufwerke K5601` x4), `M8KBOOT`, Bedienmaske, dann
`eject A` + `mount A <tmp.hfe>` und die uebrigen Laufwerke wie heute; danach dieselben Befehle/Marken/Rueckholung.  `gastbau.boot` bekommt eine Option `--start cpa` **in
`tools/plus/`** (nichts in `tools/kernel/`).
*Abnahme:* Probe wie Plan 47 P1.0 (`cat a.txt`, Wechsel, `cat b.txt`) ueber den CP/A-Start.

### C5.2 Waechter, Doku, Abweichungen
*Haengt ab von:* C4.2.  *Gastlauf:* Langtest.
*Tun:* `tests/test_plus_cpa.py`: schnell (Rundlauf `mutos_io/cpa/build.py --check`, ASCII, Laufwerkstabelle vorhanden, keine UDOS-Einspruenge `0BE8H/0BEBH/0BF1H/0BFDH/0EB00H` mehr in
`mutoscpa.mac`); lang (`gast`, nur mit `K1520_PLUS=1`): Boot ueber CP/A + `bewerten` ohne Fehlschlag.  `doc/plus/cpa.md` (Aufrufe, Laufzeiten, Speicherkarte),
`mutos_io/cpa/README.md`, `doc/plus/abweichungen.md` (Startkette CP/A statt UDOS, `mutos_io` CP/A-Fassung, Lader, CP/A-Variante).
*Abnahme:* schnelle Tests gruen; Langtest einmal gruen (Datum, Dauer im Dokument).  Optional, wenn Zeit: `gastbau.py fixpunkt` ueber den CP/A-Start (Selbstbau unter CP/A).

## 10. Ablauf und Stand

Wellen (innerhalb einer Welle parallel):
**C1-1:** C1.1, C1.2 [main], C1.3 [main], C1.4, C1.5, C1.8 -- **C1-2:** C1.6, C1.7 -- **C1-3:** C1.9 -- **Entscheidung (Projektinhaber)** --
**C2:** C2.1 -> C2.2 -> C2.3 (C3.1 parallel zu C2.2) -- **C3:** C3.2 -> C3.3 (C5.1 parallel) -- **C4:** C4.1 -> C4.2 -- **C5:** C5.2.

| Schritt | Schreibt | Gastlauf | Dauer (Schaetzung) | Stand | Datum | Commit |
|---------|----------|----------|--------------------|-------|-------|--------|
| C1.1 | `tools/plus/cpa.py`, `versuche/plus_cpa/`, `tests/test_plus_cpa.py`, `doc/plus/cpa/c1_1_werkzeug.md` | Sekunden | 2 h | erledigt (probe: HALLO, EM256ADR/EM16ABL gleich unter GIDE-CP/A und normalem CP/A, 9 s; M80/LINKMT unterscheiden >= 7 Zeichen) | 2026-11-17 | s. git log |
| C1.2 [main] | `mutos_io/udos/` (load16), `tests/test_udos_lader.py`, `doc/mutos_io/udos_lader.md` §1, `versuche/dbg/load16_*` | Sekunden | 3 h | offen | | |
| C1.3 [main] | `mutos_io/udos/` (ifsspr, piopr), `doc/mutos_io/udos_lader.md` §2, `versuche/dbg/ifsspr_*` | Sekunden | 3 h | offen | | |
| C1.4 | `doc/plus/cpa/c1_4_inventar.md` | -- | 2-3 h | fertig | 2026-11-17 | Betreff "Plan 48 C1.4" |
| C1.5 | `doc/plus/cpa/c1_5_bios.md` | Sekunden | 3 h | fertig | 2026-11-17 | Betreff "Plan 48 C1.5" |
| C1.6 | `versuche/plus_cpa/rdtest.mac`, `wrtest.mac`, `doc/plus/cpa/c1_6_formate.md` | Minuten | 3-4 h | offen | | |
| C1.7 | `versuche/plus_cpa/itest.mac`, `doc/plus/cpa/c1_7_interrupts.md` | Sekunden | 2 h | offen | | |
| C1.8 | `doc/plus/cpa/c1_8_vier_floppy.md` | Sekunden | 2-4 h | erledigt | 2026-11-17 | 7f41132 |
| C1.9 | `doc/plus/cpa_analyse.md`, §8-§10 | -- | 1-2 h | offen | | |
| C2.1-C2.3 | `mutos_io/cpa/m8kboot.mac`, `build.py`, `tools/plus/cpa_disk.py` | Minuten | 1 Tag | vorlaeufig | | |
| C3.1-C3.3 | `mutos_io/cpa/mutoscpa.mac` | Minuten | 1-2 Tage | vorlaeufig | | |
| C4.1-C4.2 | `mutos_io/cpa/mutoscpa.mac`, `doc/plus/cpa/c4_*` | ~5 Min. je Lauf | 1 Tag | vorlaeufig | | |
| C5.1-C5.2 | `tools/plus/cpa_lauf.py`, `tests/test_plus_cpa.py`, Doku | Langtest | 1 Tag | vorlaeufig | | |

## 11. Offene Entscheidungen fuer den Projektinhaber (jetzt, vor C1)

| # | Frage | Empfehlung | Begruendung |
|---|-------|-----------|-------------|
| O1 | Wohin gehoeren die Rekonstruktionen von `LOAD16`, `IFSSPR`, `PIOPR` (C1.2, C1.3)? | **`main`** (`mutos_io/udos/`, `doc/mutos_io/udos_lader.md`), danach Merge nach `mutos-plus` (C1.9) | Es sind Originalprogramme der MUTOS-Ladediskette mit Rundlauf; CLAUDE.md: Arbeit am Original gehoert nach `main`.  Alternative: alles auf `mutos-plus` unter `doc/plus/cpa/` -- einfacher, aber die Rekonstruktion fehlte dann auf `main` |
| O2 | Duerfen Agenten die CPA_Workbench in einer **Kopie** unter `/tmp/mplus/` bauen (C1.8), oder soll der Projektinhaber eine 4-Floppy-Variante in der Workbench selbst anlegen? | Kopie unter `/tmp` (nichts in der Workbench aendern) | Haelt die Workbench unberuehrt; die Sonde zeigt, ob der Bau ohne Oberflaeche geht |
| O3 = E9 | Wo liegt spaeter die Konfiguration der MUTOS-CP/A-Variante? | in diesem Repo (`mutos_io/cpa/system/`), Bau ueber die Workbench-Kopie | Bootdiskette reproduzierbar aus diesem Repo; Workbench bleibt fremdes Projekt |
| O4 | Haelt der Plan an "Kernel unveraendert" fest, auch wenn C1 einen kleinen Kernel-Eingriff naheliegend macht (z. B. Einheiten > 4 erst in Plan 49)? | ja | Abnahme bleibt eindeutig (Original-Kernel und P3.4-Kernel laufen beide) |
| O5 | Wird der Emulator gebraucht und fehlt etwas (z. B. `keys ... wait`, Abdeckung, `em msg`; `analyse.md` §11): Wunsch an das Emulatorprojekt melden statt Behelf? | melden, Behelf nur, wenn er im Schritt billig ist | CLAUDE.md: Hardware-/Werkzeugaenderungen gehoeren nach `a5120emu` |
| O6 | Abnahmeumfang C4: reicht `bewerten` (Plan 47 P3.1), oder auch der Selbstbau-Fixpunkt ueber CP/A? | `bewerten` Pflicht, Fixpunkt optional in C5.2 | Fixpunkt kostet ~30 Min. Gastlauf und haengt am Platz der Quelldisketten, nicht an `mutos_io` |

**Entscheidungen des Projektinhabers (2026-11-17):**
* **O1:** `main`.  Umsetzung: C1.2/C1.3 arbeiten in einem eigenen Worktree auf einem Zweig von `main` (nicht im Checkout `~/projects/mutos8k`, dort arbeiten andere
  Sitzungen); den Merge nach `main` und danach nach `mutos-plus` macht die leitende Sitzung.
* **O2, O3:** wie empfohlen (Workbench nur als Kopie unter `/tmp/mplus/`; Konfiguration der Variante in diesem Repo, `mutos_io/cpa/system/`, Bau ueber
  `tools/plus/cpa_system.py` in frischer Kopie, Pruefung von Workbench-Stand und SHA-1, Exit 77 ohne Workbench; Entwurf in `doc/plus/cpa/c1_8_vier_floppy.md` §2).
* **O4:** wie empfohlen (Kernel bleibt in Plan 48 unveraendert).
* **O5:** abweichend von der Empfehlung: fehlende Emulator-/Debugger-Faehigkeiten legen Agenten **direkt im Emulatorprojekt** als Merkposten ab
  (`~/projects/a5120emu/doc/merkposten/<thema>.md`, nur Doku, kein Code, kein Commit dort -- die Datei bleibt fuer den Projektinhaber uncommittet liegen);
  Verweis im Befund.  Einen Behelf hier nur, wenn er billig ist.
* **O6:** wie empfohlen (C4: `bewerten` Pflicht; Fixpunkt ueber CP/A optional in C5.2).
* **Anforderung an die CP/A-Variante (Projektinhaber, 2026-11-17):** vier Floppy-Laufwerke A:-D: **und** GIDE-Unterstuetzung (erstes GIDE-Laufwerk E:) **und** RTC.
  Stand C1.8 (*gemessen*, `doc/plus/cpa/c1_8_vier_floppy.md`): die gebaute Variante `anzdisk = 4` zeigt Disketten A:-D:, GIDE E: bis L: (`DIR E:` liest die Platte)
  und die RTC an D5H -- die Anforderung ist damit erfuellt; `tools/plus/cpa_system.py` (C5) und sein Waechter pruefen alle drei Punkte (Kopfzeile, `DIR E:`, Uhr).
