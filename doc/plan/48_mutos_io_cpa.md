# Plan 48: `mutos_io` nach CP/A portieren

Stand 2026-11-18, Branch `mutos-plus` (Plan 47).  **C1 erledigt (§7); E1-E9 entschieden (§8, 2026-11-17); C2-C5 endgueltig in Agentenschritte zerlegt (§9), Wellen §10.**
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
8. **Commit:** Betreff `Plan 48 <Schritt>: <Inhalt>`, Stand-Zeile in §10 im selben Commit (C1; ab C2 Regel 9).  Vorher `python3 -m pytest -q tests` (bekannt rot und unabhaengig:
   `test_bau_alle_kennt_genau_die_fertigen_disketten`).  Kein Push, kein Merge (ausser C1.9 Punkt 1).
9. **Ab C2:** Auftrag nach §9 (Kopf), gemeinsame Festlegungen §9.0.  Agenten aendern **diesen Plan nicht**; der Stand steht in der Kopfzeile des Befunds, die leitende Sitzung
   traegt §10 nach.  Nur die Dateien der Spalte *Schreibt* des eigenen Schritts aendern; fehlt eine Datei dort, anhalten und melden.

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

### Vorlagen aus C1.9 (Stand 2026-11-17; ausfuehrlich mit Belegen in `doc/plus/cpa_analyse.md` §6, Abweichungen vom Plan dort §7)

Nicht entschieden; Empfehlung = Vorschlag an den Projektinhaber.  Kuerzel `c1_n` = `doc/plus/cpa/c1_n_*.md`.

* **E1 Plattenweg.**  Optionen (a) Standard-Einspruenge, (b) `diskio` (D2CB-Leiste), (c) eigener FDC-Treiber.  Messwerte: alle Saetze gleich (root_fm/mfm 2002/2002, 8x512 2528/2528, GIDE 1280/1280), 198 602 Takte je 512 B (`c1_6` §1, §5);
  **aber** nur mit inverser CP/A-Skew-Tabelle ab Spur `OFF` (2 oder 0 je Diskette), Schreiben `C = 0,0,0,1`; `SETSEC = ID` waere bei 824 von 2002 Saetzen falsch (`c1_6` §3, §4).  **Empfehlung (a).**  Folge: Wurzel-Umzug entfaellt; C3.3 mit der Regel aus `c1_6` §4.
* **E2 Interrupts.**  Optionen (a) Vektoren in die CP/A-Tabelle, (b) Maschine uebernehmen.  Messwerte: 0 Tickverluste bei READ/CONOUT/WRITE, groesste Verspaetung 0,68 ms, BIOS liest/schreibt richtig (`c1_7` §2); frei F700-F7CF, CTC-Kanal 0/1 (`c1_5` §8):
  CTC F7FA, PIO A32 F7EA/F7EC, SIO F730-F73E.  Nicht gemessen: voller `ISR_ANFRAGE` neben `READ`.  **Empfehlung (a).**
* **E3 Lage.**  Optionen (a) 9000H behalten + Stapel unter BIOS, (b) `.COM` ab 0100H, (c) andere feste Lage.  Messwerte: BIOS 2 Floppy CB00, **4 Floppy CA00**, nur 152 B ueber C968 (`c1_8` §4, §5); B936-C8B5 frei (`c1_4` §5).
  **Empfehlung (a) mit Stapel in B936-C8B5** (`SP` = C8B6; Annahme, in C3 zu pruefen); die Planbedingung ist nur mit dieser Verlegung erfuellt.
* **E4 Lader.**  Optionen (a) ein `M8KBOOT.COM`, (b) Kernel-Lader + `mutos_io` als eigenes `.COM`.  Messwerte: `LOAD16` ein Dateidienst, EM-Init und 4-KB-`LDIR` durch Fenster 0000-3FFF, **startet den U8001 nicht** (`udos_lader` §1.3 a-d, Zweig `plan48-udos`, Merge ausstehend).
  **Empfehlung (a).**  Folge: `M8KBOOT K` muss den U8001 selbst starten (C2.3), Fenster 4000-7FFF, Lesepuffer ab 8000H.
* **E5 Laufwerke.**  Optionen (a) 4-Floppy-Variante, (b) 2 Floppy + GIDE.  Messwerte: gebaut und gebootet, A:-D:, GIDE E:-L:, RTC D5H, `@OS.COM` reproduzierbar (`c1_8` §2, §4).  **Empfehlung (a)**; Anforderung des Projektinhabers erfuellt.
* **E6 Konsole/Tastatur.**  Optionen (a) Ausgabe BIOS, Tastatur eigenes Pollen im ISR; (b) alles ueber BIOS, `CONST` in der Hauptschleife; (c) alles selbst; **(d, neu)** Ausgabe `CONOUT` aus der Hauptschleife, Tastatur `CONST`/`CONIN` im 50-Hz-ISR.
  Messwerte: BIOS pollt 5CH/5DH selbst, zwei Leser stehlen Zeichen (`c1_5` §4); (d) gemessen: 4/4 Tasten, +0,9..2,5 % Laufzeit (`c1_7` §2); (a) braeuchte `tim5of`, dann steht die Uhr (abgeleitet).  Keine Statuszeile im BIOS, nur Uhr.
  **Empfehlung (d)** (weicht vom Plan-Vorschlag (a) ab).  Nicht gemessen: `CONOUT` im ISR, lange Tastenfolgen, Umlaute/Steuercodes.
* **E7 Drucker/tty1.**  Optionen (a) BIOS `LIST` mit IOBYTE 80H (LPT), (b) `IFSSPR`-Kern in `mutos_io`, (c) weglassen.  Messwerte: LPT = 5EH/5FH, 7 Bit, ungerade Paritaet, 9600 Bd = `IFSSPR` (`c1_5` §5, `udos_lader` §2.4); Emulator zeigt Zeichen nur am Port; `LIST` selbst ungemessen.
  **Empfehlung (a), vorlaeufig**, Pruefung in C4.1 (Port, TAB, NUL nach CR); Zeilen `[0003H]` streichen, `0003H := 80H`.
* **E8 Startmedium.**  Optionen (a) CP/A-Bootdiskette in A: + Wechsel, (b) GIDE.  Messwerte: Boot von A: (§2.1); Neuanmeldung nach Wechsel noetig (`c1_6` §7); GIDE heisst bei 4 Floppys E:.  **Empfehlung (a)**; (b) Plan 51 P6.
* **E9 Ablage der Variante.**  Optionen (a) im Repo (`mutos_io/cpa/system/`), (b) in der Workbench.  Messwerte: Bau ohne Oberflaeche ~10 s, SHA-1 `97bbdca9...` (`c1_8` §2, §6).  **Empfehlung (a)**; mit O3 (§11) schon so entschieden.

**Ergebnis (Entscheidung des Projektinhabers 2026-11-17: alle Empfehlungen aus C1.9 uebernommen; Belege `doc/plus/cpa_analyse.md` §6):**
* **E1 = (a)** Standard-BIOS-Einspruenge `SELDSK/SETTRK/SETSEC/SETDMA/READ/WRITE`, Satzregel `cpa_analyse` §4 (inverse CP/A-Skew-Tabelle ab Spur `OFF`, `OFF` aus dem DPB nach jedem `SELDSK`), Schreiben je Block `C = 0,0,0,1`.  Kein Wurzel-Umzug.  -> C3.3.
* **E2 = (a)** Vektoren in die CP/A-Tabelle (`I` = F7 bleibt, BIOS-ISRs laufen weiter): CTC 0DH -> F7FA, PIO A32 -> F7EA/F7EC, SIO -> F730-F73E.  -> C3.2.
* **E3 = (a)** `.PHASE 9000H` ff. bleiben, BDOS/CCP werden ueberschrieben, Stapel nach B936-C8B5 (`SP` = C8B6; Tiefe in C3.2/C4.2 messen).  -> C2.3, C3.2.
* **E4 = (a)** ein Lader `M8KBOOT.COM` (Kernel in den EM, `mutos_io` nach 9000H, Sprung); Betriebsart `K` startet den U8001 selbst.  -> C2.3.
* **E5 = (a)** 4-Floppy-Variante des GIDE-CP/A (A:-D: K5601, GIDE ab E:, RTC D5H).  -> C2.2.
* **E6 = (d)** Ausgabe ueber BIOS `CONOUT` aus der Hauptschleife, Tastatur ueber BIOS `CONST`/`CONIN` im 50-Hz-ISR (kein eigenes Pollen von 5CH/5DH).  -> C3.2, C3.4.
* **E7 = (a), vorlaeufig** BIOS `LIST` mit IOBYTE 80H (LPT 5EH/5FH); Pruefung in C4.1.  Faellt die Pruefung durch, haelt C4.1 an (Rueckfall (b) braucht eine neue Entscheidung, §12).
* **E8 = (a)** CP/A-Bootdiskette in A:, Wechsel in der Bedienmaske; Start von GIDE erst Plan 51 P6.  -> C2.4, C3.3, C5.1.
* **E9 = (a)** Konfiguration der Variante in diesem Repo (`mutos_io/cpa/system/`), Bau ueber eine frische Workbench-Kopie (`tools/plus/cpa_system.py`).  -> C2.2.
* Weiter gelten O1-O6 und die Anforderung an die CP/A-Variante aus §11.

## 9. Detailplanung C2-C5 (endgueltig fuer E1a, E2a, E3a, E4a, E5a, E6d, E7a, E8a, E9a; Stand 2026-11-18)

Form wie §7.  Jeder Schritt ist fuer einen Agenten ohne Vorwissen geschnitten; die Spalte *Schreibt* ist verbindlich (parallele Schritte haben keine gemeinsame Datei).
Auftrag je Schritt: *"Arbeite im Worktree `/home/olliy/projects/mutos8k-plus` (Branch `mutos-plus`).  Lies `CLAUDE.md`, `doc/plan/47_mutos_plus.md` §6,
`doc/plan/48_mutos_io_cpa.md` §2, §6, §9.0 und §9 <Schritt>, fuehre genau diesen Schritt aus."*

### 9.0 Gemeinsame Festlegungen fuer C2-C5

**Dateien und Orte**
* `mutos_io/cpa/` = CP/A-Fassung: `src/mutoscpa.mac` (aus `mutos_io/src/mutosio.mac` kopiert, dann umgebaut), `src/m8kboot.mac` (Lader), `build.py`, die Bauergebnisse
  `mutoscpa.bin` und `m8kboot.com` (**eingecheckt**, wie `mutos_io/mutosio.bin`; Plan 48 §6.6), `README.md`, `system/` (Konfiguration der CP/A-Variante, E9).
* `mutos_io/src/`, `mutos_io/build.py`, `mutos_io/ladediskette.py`, `mutos_io/mutosio.bin`, `mutos_io/udos/` gehoeren zu `main`: **nur lesen bzw. importieren** (§6.2).
  `tools/kernel/*`, `tools/plus/gastbau.py`, `tools/plus/gastlauf.py`, `tools/plus/cpa.py`: in C2-C5 **nur importieren**, nicht aendern (neue Hilfen kommen in die Werkzeuge des Schritts).
* Hostwerkzeuge neu: `tools/plus/cpa_system.py` (C2.2), `tools/plus/cpa_disk.py` (C2.4), `tools/plus/cpa_lauf.py` (C5.1).  Probeprogramme unter `versuche/plus_cpa/`, Debuggerskripte
  unter `versuche/dbg/cpa_<schritt>_*.dbg`, Arbeitsordner `/tmp/mplus/<schritt>/` (z. B. `/tmp/mplus/c3_3/`).  Gebaute Disketten nie in `disks/`.
* Befund je Schritt `doc/plus/cpa/<schritt>_<thema>.md` (z. B. `c2_3_lader.md`), Kopfzeile mit **Stand** (erledigt / blockiert), Datum, Arbeitsordner.
* Tests je Schritt in einer eigenen Datei (Spalte *Schreibt*); `tests/test_plus_cpa_io.py` gehoert der Kette C3.1 -> C3.2 -> C3.3 -> C3.4 -> C4.1, die streng nacheinander laeuft.
  Schnelltests ohne Emulator gruen oder Skip; Gasttests mit `@pytest.mark.gast` (Skip ohne Emulator, Skripte Exit 77).

**Technische Festlegungen (aus C1, gelten fuer alle Schritte)**
* BIOS-Einspruenge nie fest: `mutoscpa` liest beim Start einmal `WBOOT = (0001H)` und legt eine eigene Sprungleiste an (`CONST = WBOOT+3`, `CONIN +6`, `CONOUT +9`, `LIST +0CH`,
  `HOME +15H`, `SELDSK +18H`, `SETTRK +1BH`, `SETSEC +1EH`, `SETDMA +21H`, `READ +24H`, `WRITE +27H`; gemessen `c1_5` §1, `c1_6` §2); spaeter nie mehr `0001H` lesen (das BIOS ueberschreibt 0001/0002 waehrend
  des Floppytransfers, `c1_5` §6).  `0000H`, `0001/0002`, `0003H` (IOBYTE), `0040-0055H` nicht als Speicher benutzen.
* `INTVEC EQU 0F700H`; `INIT` prueft `LD A,I` = F7H (sonst Meldung und Halteschleife).  Vektoren: CTC 0DH -> `INTVEC+0FAH` (CTC-Basis F8H **nicht** umprogrammieren),
  PIO A32 A/B -> `INTVEC+0EAH`/`+0ECH` (Vektorbytes EAH/ECH bleiben), SIO-Kanaele -> `INTVEC+30H..3EH` (WR2 = 30H bleibt).
* Speicher (`cpa_analyse` §2): `mutoscpa` 9000..C967, Stapel `SP = C8B6H` (waechst nach unten in B936..C8B5), BIOS ab CA00 (4 Floppy) bzw. CB00 (2 Floppy).
  Lader: Code/Stapel 0100H..0FFFH, Kernel-Lesepuffer 1000H..1FFFH, Bildpuffer fuer `mutos_io` ab 8000H (bis hoechstens BC05H), EM-Fenster 4000H..7FFFH.
* Dateien auf der Bootdiskette (CP/M 8.3): `M8KBOOT.COM`, `MUTOS.SYS` (Kernel ohne UDOS-Kopf, 36 352 B; Vorgabe `mutos_1216` der Original-Ladediskette), `MUTOSIO.IMG`
  (Speicherabbild 9000H..Ende des letzten Segments, Luecken 00H; erzeugt von `mutos_io/cpa/build.py abbild`).
* Emulatoraufruf CP/A mit vier Floppys: `k1520dbg --em em256 --laderom ul4 --gide=0xD0 --gide-image <kopie.img.gz> --laufwerke K5601,K5601,K5601,K5601 <boot.hfe> [-b/-c/-d ...]`
  (Muster `tools/plus/cpa.py lauf_dbg`, `c1_8` §4).  MUTOS-Disketten wie in `tools/kernel/gast_as.py` (`PLATTEN`, A = `/tmp` rk0, B = `/usr` rk1, C = Wurzel rk2, D = `/mnt` rk3).
* Kernel: Original `mutos_1216` (`gast_as.disk("a5120_mutos8000_boot_udos_k5601.hfe")`, `k1520disktool get ... mutos_1216`) und P3.4-Kernel (sha256 `a0e2a9c5...e97e25`,
  gebaut mit `python3 -I tools/plus/gastbau.py bauen --arbeit DIR`, `doc/plus/gastbau.md` §8).  Kernel bleibt unveraendert (O4).
* Jede Abweichung vom Original in `doc/plus/abweichungen.md` -- geschrieben nur von den Schritten C2.4, C3.4, C4.1, C5.2 (die nie parallel laufen).

### C2.1 Geruest `mutos_io/cpa/` und bytegleiche Kopie
*Haengt ab von:* nichts.  *Gastlauf:* nein (M80/LINKMT ueber `emu.cpm_bau()`).
*Lesen:* `mutos_io/README.md`, `mutos_io/build.py`, `mutos_io/udos/build.py` (Muster `cpm_bau.Programm`), `mutos_io/ladediskette.py` (`baue`, `segmente`), `k1520emu: tools/cpm_bau.py`.
*Erste Sonde:* `python3 -I mutos_io/build.py --check` -> 0 (Werkzeugkette da, Ausgangslage bytegleich).
*Tun:*
1. `mutos_io/cpa/src/mutoscpa.mac` = Kopie von `mutos_io/src/mutosio.mac` (nur der Kopfkommentar nennt die Herkunft und den Plan; Code unveraendert).
2. `mutos_io/cpa/build.py` (Muster `mutos_io/udos/build.py`): Programmliste aus `src/*.mac` (sortiert), Endung `com` fuer `m8kboot`, sonst `bin`; `--check` wie `cpm_bau.hauptprogramm`.
   Zusaetzlich Unterbefehl `abbild [--out DATEI]`: baut `mutoscpa` ueber `ladediskette.baue(quelle=...)` (importieren, nicht kopieren), legt die Segmente an ihre Adressen
   (Dateiversatz = Summe der auf 100H gerundeten Vorgaengerlaengen, gemessen: 5376 B = 300H+F00H+200H+100H) und schreibt `MUTOSIO.IMG` ab 9000H; Funktion `abbild()` fuer C2.4.
3. `mutoscpa.bin` bauen und einchecken; `README.md` (Deutsch): Zweck, Bau, Bezug: **Basis-Commit** = der Commit dieses Schritts (`git diff <basis> -- mutos_io/cpa/src/mutoscpa.mac` zeigt alle CP/A-Aenderungen).
*Schreibt:* `mutos_io/cpa/src/mutoscpa.mac`, `mutos_io/cpa/build.py`, `mutos_io/cpa/mutoscpa.bin`, `mutos_io/cpa/README.md`, `tests/test_plus_cpa_quelle.py`
(schnell: Datei ASCII; `gast`: `build.py --check` -> 0, `abbild()` liefert C968H-9000H Byte mit den Segmentinhalten an den richtigen Stellen).
*Abnahme:* `cmp mutos_io/cpa/mutoscpa.bin mutos_io/mutosio.bin` gleich; `python3 -I mutos_io/cpa/build.py --check` -> 0; `abbild` erzeugt ein Abbild, dessen Bytes an 9000/9400/A400/C8B6 den Segmenten gleichen; ohne Emulator Exit 77.
*Dauer:* ~1 h.

### C2.2 CP/A-Variante mit vier Floppys bauen (`tools/plus/cpa_system.py`)
*Haengt ab von:* nichts (parallel zu C2.1).  *Gastlauf:* ja, kurz (Sekunden).
*Lesen:* `doc/plus/cpa/c1_8_vier_floppy.md` ganz (Bauentwurf §2, Systemdiskette §3, Start §4, Vorschlag §6, Auffaelligkeiten §7), §11 (O2/O3, Anforderung), `tools/plus/cpa.py` (Kopf, `lauf`, `schirm`).
**Nie** `cpa_workbench.py` ohne Argumente starten; in `~/projects/CPA_Workbench` nichts schreiben.
*Erste Sonde:* Entwurf aus `c1_8` §2 in einer frischen Kopie unter `/tmp/mplus/c2_2/wb/` mit `anzdisk = 4` laufen lassen: SHA-1 der `@os.com` = `97bbdca995953cc928e5b09cc0d3ae32d9a2ef45`?
*Tun:*
1. `mutos_io/cpa/system/konfig.txt`: die Abweichungen von der Vorgabe der Variante `gide_a5120` (`CONFIG_SYSTEM_CRT_K7024=y`, `CONFIG_SYSTEM_ANZDISK=4`), je Zeile `SCHLUESSEL=WERT`, Kommentar `#`;
   `mutos_io/cpa/system/README.md`: Workbench-Stand (`0045dc6`), erwarteter SHA-1, Bauweg.
2. `tools/plus/cpa_system.py` (Englisch, stdlib): Workbench aus `CPA_WORKBENCH` (Vorgabe `~/projects/CPA_Workbench`); jedes Mal frische Kopie (`src config prebuilt tools additions diskdefs cpaFormates.cfg`)
   nach `<arbeit>/wb/`; Stand pruefen (`git rev-parse HEAD`, abweichend = Warnung); eigene `.config` (nie die der Workbench); `run_patch_mac extract` -> Werte aus `konfig.txt` -> `patch` -> `build_os`;
   SHA-1 pruefen (abweichend = Fehler).  Funktionen `os_com(arbeit) -> bytes`, `systemdiskette(arbeit) -> pfad` (Kopie von `cpa.GIDE_SYS`, `@OS.COM` ersetzt, `c1_8` §3).
   Kommandozeile `cpa_system.py bauen|pruefen --arbeit DIR`; `pruefen` bootet die Diskette (`cpa.lauf`, `laufwerke=['K5601']*4`) und prueft Kopfzeile (`A:`..`D:`, `GIDE-Laufwerke E: bis L:`,
   `RTC 72421`), `DIR E:` (Eintrag `@OS`) und die Uhr (`d 0x0050 3` an zwei Zeitpunkten, Sekunden laufen).  Exit 77 ohne Workbench, Emulator oder Werkzeugkette.
3. Nebenbei messen: bootet die 4-Floppy-Diskette **ohne** `--laufwerke`? (offen aus `cpa_analyse` E5; Ergebnis in den Befund, kein Umbau.)
*Schreibt:* `tools/plus/cpa_system.py`, `mutos_io/cpa/system/konfig.txt`, `mutos_io/cpa/system/README.md`, `tests/test_plus_cpa_system.py` (schnell: `konfig.txt` lesbar, SHA-1-Konstante;
`gast`: `pruefen`), `doc/plus/cpa/c2_2_system.md`.
*Abnahme:* `python3 -I tools/plus/cpa_system.py pruefen --arbeit /tmp/mplus/c2_2` -> 0 (SHA-1 gleich, A:-D:, E:-L:, RTC, `DIR E:`, Uhr laeuft); Workbench danach `git status` sauber.
*Dauer:* ~2 h.

### C2.3 Lader `M8KBOOT.COM`
*Haengt ab von:* C2.1 (`build.py` baut `src/*.mac`).  Parallel zu C2.2 und C3.1.  *Gastlauf:* ja, kurz (2-Floppy-GIDE-Systemdiskette `cpa.GIDE_SYS` genuegt; die 4-Floppy-Diskette erst in C2.4).
*Lesen:* `doc/mutos_io/udos_lader.md` §1 (vor allem §1.3 b-e, §1.4), `mutos_io/udos/src/load16.mac`, `mutos_io/src/mutosio.mac` (`INIT` 9400 ff., `SEITE_ABBILDEN`, `TAB_PIO_A/B`, Start 9000-9009),
`doc/plus/cpa/c1_5_bios.md` §1 und §6, `c1_6` §7 (BDOS merkt sich `SELDSK`), `tools/plus/cpa.py`, `k1520emu: tools/k1520dbg.md` §12 (`emlog`, `cpu u8000`, `dev em`), §9.0.
*Erste Sonde:* Kleinprogramm `versuche/plus_cpa/emfenst.mac`: A22 alle Seiten 0FH, PIO A32 wie `TAB_PIO_A/B`, Seiten 4..7 auf EM-Segment 0 Adresse 0000H abbilden (Logik `SEITE_ABBILDEN`), `OUT (A9H),38H`,
warten auf PIO A Bit 6, 4 KB Muster nach 4000H, `OUT (A9H),3CH`; im Debugger `d <<0>>%0000 32` (bzw. `cpu u8000` + `d`) zeigt das Muster.  Bestaetigt das Fenster 4000-7FFF unter CP/A (LOAD16 benutzte 0000-3FFF).
*Tun:*
1. `mutos_io/cpa/src/m8kboot.mac` (Englisch, M80, ohne `ORG`; Lage §9.0): `MUTOS.SYS` per BDOS (Open 15, Read Sequential 20, SETDMA 26) in 4-KB-Stuecken nach 1000H lesen und je Stueck
   wie `LOAD16` (`udos_lader` §1.3 b) ueber das Fenster 4000-7FFF in EM-Segment 0 ab 0000H kopieren (`DI` um `OUT 38H`..`LDIR`..`OUT 3CH`); Ende = Dateiende; Laenge pruefen (> 0, <= 64 KB).
2. Dann `MUTOSIO.IMG` nach 8000H lesen; BIOS-Anfang = `(0001H) - 3`; Abbruch mit Meldung, wenn `9000H + Laenge > BIOS-Anfang`; nach dem **letzten** BDOS-Aufruf `DI`, Abbild mit `LDDR` (ueberlappend)
   nach 9000H schieben, `JP 9000H`.  Der U8001 bleibt im Reset (den Start macht `mutoscpa` wie heute, `udos_lader` §1.3 f).
3. Betriebsart `M8KBOOT K` (Kommandozeile ab 0080H): nur Kernel laden, dann EM-Init wie `mutos_io` `INIT` (A22, PIO), Vektor `INTVEC+0EAH` auf eine Zaehl-ISR (`EI; RETI`, Zaehler an fester,
   im Listing genannter Adresse), `OUT (A9H),2CH`, `EI`, Halteschleife.  Ohne EM-Karte (PIO A Bit 6 kommt nicht): Zeitgrenze, Meldung `NO EM`, Rueckkehr zum CCP.
4. Fehlertexte (Datei fehlt, zu gross, kein EM, `mutos_io` ragt ins BIOS) ueber BDOS 9, dann Warmstart -- solange BDOS noch nicht ueberschrieben ist.
5. `m8kboot.com` bauen und einchecken.  Debuggerskripte `versuche/dbg/cpa_c2_3_*.dbg`.
*Schreibt:* `mutos_io/cpa/src/m8kboot.mac`, `mutos_io/cpa/m8kboot.com`, `versuche/plus_cpa/emfenst.mac`, `versuche/dbg/cpa_c2_3_*.dbg`, `tests/test_plus_cpa_lader.py`
(`gast`: `M8KBOOT K` auf einer Kopie von `cpa.GIDE_SYS` mit `MUTOS.SYS`), `doc/plus/cpa/c2_3_lader.md`.
*Abnahme* (Original-Kernel, 2-Floppy-GIDE-Diskette): `M8KBOOT K` -> EM-Segment 0 ab 0 bytegleich `mutos_1216` (Dump auf dem Host verglichen, alle 36 352 B); `emlog`: `RESET16 0`, U8001 laeuft
bei `<<0>>%027E` los; Zaehl-ISR >= 1 und EM 4006H != 0 (erste Postfach-Anforderung steht an); ohne `--em` meldet der Lader `NO EM` statt zu haengen.  `build.py --check` -> 0.
*Dauer:* ~3-4 h.

### C3.1 Namen statt Zahlen in `mutoscpa.mac` (bytegleich)
*Haengt ab von:* C2.1.  Parallel zu C2.2/C2.3 (schreibt nur `mutoscpa.*`).  *Gastlauf:* nein.
*Lesen:* `doc/plus/cpa/c1_4_inventar.md` §1, §3 (A-Zeilen), §4, §9 Punkt 5; `mutos_io/cpa/README.md`.
*Erste Sonde:* `rg -n '0A5A[89]H|0CB68H|0B6H,0A[5-9B]H' mutos_io/cpa/src/mutoscpa.mac` -- Umfang gegen `c1_4` §3 (23 A-Zeilen).
*Tun:* jede A-Zeile aus `c1_4` §3 durch einen Namen ersetzen: `V_NACHR` (A5A8H, `V_NACHR+1`), Stapelanfang `INITSP EQU 0CB68H` (Wert noch unveraendert), Pufferzeiger in `AUF*`/`DCB*` als `DW PUF_xxx`
mit `PUF_xxx EQU` je Puffer (A5B6 ... B8B6).  Beruehrte deutsche Kommentare ins Englische uebersetzen; Namen neu Englisch.  Ergebnis bleibt **bytegleich** zu `mutos_io/mutosio.bin`.
*Schreibt:* `mutos_io/cpa/src/mutoscpa.mac`, `tests/test_plus_cpa_io.py` (schnell: ASCII; keine der A-Zahlen aus `c1_4` §3 mehr ausserhalb von `EQU`-Zeilen), `doc/plus/cpa/c3_1_namen.md` (Tabelle Zahl -> Name).
*Abnahme:* `build.py --check` -> 0 und `mutoscpa.bin` == `mutos_io/mutosio.bin`; Schnelltest gruen.
*Dauer:* ~1-2 h.

### C2.4 Bootdiskette (`tools/plus/cpa_disk.py`) und Abnahme C2
*Haengt ab von:* C2.2, C2.3 (C2.1 `abbild`).  *Gastlauf:* ja, kurz.
*Lesen:* `doc/plus/cpa/c2_2_system.md`, `c2_3_lader.md`, `tools/plus/cpa_system.py`, `tools/plus/cpa.py` (`diskette`), `mutos_io/cpa/build.py` (`abbild`), §9.0.
*Erste Sonde:* Systemdiskette aus `cpa_system.systemdiskette()` + die drei Dateien mit `k1520disktool put`; `k1520disktool ls -l` zeigt Laengen 36 352 (MUTOS.SYS) und Laenge des Abbilds.
*Tun:*
1. `tools/plus/cpa_disk.py`: `bootdiskette(arbeit, kernel=None, io_quelle=None) -> pfad` (4-Floppy-Systemdiskette + `M8KBOOT.COM` aus `mutos_io/cpa/m8kboot.com`, `MUTOS.SYS` = `kernel` bytes oder Original,
   `MUTOSIO.IMG` = `abbild()` der aktuellen `mutoscpa.mac`); Kommandozeile `cpa_disk.py diskette --arbeit DIR [--kernel DATEI]` und `cpa_disk.py kstart --arbeit DIR` (Abnahmelauf `M8KBOOT K`).
   Exit 77 ohne Emulator/Workbench/Werkzeugkette.  Kein Autostart: `M8KBOOT` wird am Prompt getippt (Autostart ist nicht Teil von Plan 48).
2. Abnahme C2 auf der 4-Floppy-Diskette: wie C2.3, zusaetzlich BIOS-Anfang CA00 gemessen und die Lage-Pruefung des Laders positiv (Vollbetrieb `M8KBOOT` erreicht 9000H; danach macht die unveraenderte
   UDOS-Fassung noch nichts Sinnvolles -- nur der Sprung wird geprueft, Haltepunkt 9000H).
3. `doc/plus/abweichungen.md`: Zeilen "Startkette CP/A statt UDOS (`M8KBOOT` statt `ACTIVATE`/`LOAD16`/`IFSSPR`)" und "CP/A-Variante 4 Floppy (`mutos_io/cpa/system/`)".
*Schreibt:* `tools/plus/cpa_disk.py`, `tests/test_plus_cpa_disk.py` (schnell: Import/Exit 77; `gast`: `kstart`), `doc/plus/cpa/c2_4_bootdiskette.md`, `doc/plus/abweichungen.md`.
*Abnahme:* `python3 -I tools/plus/cpa_disk.py kstart --arbeit /tmp/mplus/c2_4` -> 0 (EM == Kernel, U8001 laeuft, Anforderung steht an, BIOS CA00); Haltepunkt 9000H im Vollbetrieb erreicht, Bytes 9000..C967 == `MUTOSIO.IMG`.
*Dauer:* ~2 h.

### C3.2 `mutoscpa`: Start, Lage, Interrupts, Konsolausgabe, Bedienmaske
*Haengt ab von:* C3.1, C2.4.  *Gastlauf:* ja, Minuten (MUTOS-Start im Hintergrund, §6.3).
*Lesen:* `c1_4` §3, §4, §5, §8; `c1_5` §1, §3, §4, §8; `c1_7` §1, §4; `cpa_analyse` §2, §3; `mutoscpa.mac` (Start 9000, `INIT`, `ISR_*`, `KONSOLE_AUS`, `DRUCKER`, `NUKLEUS_INIT`, `ROH`/`KMD_*`, `MASKE` ff.); `cpa_disk.py`; §9.0.
*Erste Sonde:* nur Start + Bedienmaske umgebaut (Stapel, BIOS-Sprungleiste, `0BEBH`/`0BF1H`/`0BE8H` in der Maske, Meldezeile), `INIT` und Kernelstart noch hinter einem Halt: Maske erscheint ueber `CONOUT`,
`r` wird angenommen (Haltepunkt nach `CALL MASKE`).  **Stapeltiefe:** der Start fuellt B936..C8B5 mit E5H (bleibt drin); nach dem Lauf Dump, tiefste benutzte Adresse in den Befund.
*Tun* (je Punkt Fundstelle aus `c1_4` §3/§4 im Befund):
1. Start: Stapel fuellen, `LD SP,0C8B6H`, BIOS-Sprungleiste anlegen (§9.0), BIOS-Tastaturpuffer leeren (`CONST`/`CONIN`-Schleife).
2. `0BEBH` -> `PUTC` (BC, DE, HL retten, `LD C,A`, BIOS `CONOUT`); `0BF1H` -> Textausgabe (Laengenbyte + Text) ueber `PUTC`; `0BE8H` -> `CONST`/`CONIN` (Rueckgabe wie UDOS: Z = keine Taste, sonst A);
   Meldezeile `0FF60H` -> Zeilenumbruch + Text ueber `PUTC`; `SIGNALTON` (5CH) bleibt.
3. `INIT`: `I` pruefen, Vektoren nach §9.0 (`INTVEC+0EAH/0ECH/0FAH`, SIO `+30H..3EH`); `NUKLEUS_INIT`-Zeilen `[0003H]` streichen; `RST 38H` (2 Stellen) -> `FEHLERHALT` (Meldung, `DI`, Schleife);
   Klasse 3 (`ROH`/`KMD_*`, 01B5H, `OUT 1CH`) durch einen Handler ersetzen, der sofort mit Fehlerstatus meldet.
4. Stummel: `PLATTE` meldet sofort Fehler (Status wie `BR_ABBRUCH`), `DRUCKER` meldet sofort Status FFH (bis C3.3 bzw. C4.1).  `ISR_TAKT` vorerst ohne Tastatur (Aufruf `TASTE_LESEN` raus; C3.4).
5. `INITSP` auf C8B6H; Seg.-Lage unveraendert.  `doc/plus/cpa/c3_2_start.md` mit allen Ersetzungen.
*Schreibt:* `mutos_io/cpa/src/mutoscpa.mac`, `mutos_io/cpa/mutoscpa.bin`, `tests/test_plus_cpa_io.py` (ergaenzen: kein `0BEBH/0BF1H/0BE8H/0FF60H/[0003H]/01B5H/RST 38H/0FE2H/0FEAH/0FECH/0F3xH` mehr im Code;
`gast`: Lauf bis zur Kernelmeldung), `versuche/dbg/cpa_c3_2_*.dbg`, `doc/plus/cpa/c3_2_start.md`.
*Abnahme:* Boot ueber `cpa_disk.bootdiskette`: `M8KBOOT` -> Maske -> `r` -> erste Meldung des Kernels auf dem Schirm (Text wie im UDOS-Boot), danach Plattenfehler (erwartet); Logpunkte: `ISR_TAKT` ~50/s
(Takte je Tick wie `c1_7` §2), `ISR_ANFRAGE` >= 1; BIOS-Uhr `0050H..0052H` laeuft weiter; Stapel nicht unter B936H.
*Dauer:* ~4-6 h.

### C3.3 `mutoscpa`: Plattenweg ueber das BIOS
*Haengt ab von:* C3.2.  *Gastlauf:* ja, Minuten (Hintergrund).
*Lesen:* `cpa_analyse` §4, `c1_6` §3, §4, §6, §7; `c1_4` §6, §7; `versuche/plus_cpa/blktest.mac` (Vorlage der Rechnung); `mutoscpa.mac` `PLATTE` .. `SEKTOR_BERECHNEN`, `PLATTE_FERTIG`, `TAB_RK_LAUFWERK`, `M_FERTIG`; §9.0.
*Erste Sonde:* **voller ISR neben `READ`**: zuerst nur den Lesezweig einbauen (Schreiben meldet Fehler), Boot mit `root_mfm` in C:; Logpunkte auf BIOS-`READ` Ein-/Austritt (Adressen der eigenen Sprungleiste),
`ISR_TAKT` und `ISR_ANFRAGE` mit Takt.  Erwartet: Ticks fallen in `READ`-Fenster, kein Tick verloren (Abstaende wie `c1_7` §2), jede Anforderung waehrend `READ` wird nach dem Block bedient, Daten richtig
(Boot kommt weiter als in C3.2).  Faellt das anders aus: blockiert, melden.
*Tun:*
1. `PLATTE` synchron: Einheit -> CP/A-Laufwerk ueber `TAB_RK_LAUFWERK` (Werte 0..3 = A:-D:) und eine neue Tabelle `TAB_RK_CPA` mit 8 Eintraegen (rk4-7 = FFH = Fehler; Plan 49/51 tragen GIDE ein); Klasse 5 bleibt frei.
2. **Anmeldung:** je Einheit ein Merker "angemeldet", geloescht am Ende der Bedienmaske; erster Zugriff -> `SELDSK` mit E Bit 0 = 0 (Formaterkennung), danach E = 1.  Nach **jedem** `SELDSK`: DPH -> DPB,
   `SPT` (DPB+0) und `OFF` (DPB+13) lesen.  HL = 0 -> Fehlerstatus.
3. Regel nach `cpa_analyse` §4: `SPT` = 26 -> 26 x 128 (inverse Tabelle `INV` ab Spur `OFF`), `SPT` = 32 oder 36 -> 8 x 512; sonst Fehlerstatus.  Je Block vier Saetze `SETTRK/SETSEC/SETDMA/READ`
   bzw. `WRITE` mit `C = 0,0,0,1`.  Puffer wie heute (`IY+2/3`, A8B6..).  Fehler (`A` != 0) -> Status wie `BR_ABBRUCH` (Wert >= 40H), Abbruch des Blocks.
4. Entfernen: `0BFDH`-Weg (`BLOCK_START`, `BLOCK_RUECKRUF`, `BR_*`, `SEKTOR_WEITER`, `V_RUECKRUF_*`, `NUK_AUFTRAG`); `V_BUSY` und Wiedervorlage `90F2` nur, wenn nichts anderes sie braucht.  Fertigmeldung direkt
   (wie `KONSOLE_AUS` ueber `ENDE_WIEDER`), nicht mehr im Interruptkontext.
5. Takte je Block und Zeit bis `login:` gegen den UDOS-Weg (`gastbau`/UDOS-Boot, `c1_4` §6) messen.
*Schreibt:* `mutos_io/cpa/src/mutoscpa.mac`, `mutos_io/cpa/mutoscpa.bin`, `tests/test_plus_cpa_io.py` (ergaenzen: kein `0BFDH`; `gast`: Boot bis `login:`), `versuche/dbg/cpa_c3_3_*.dbg`, `doc/plus/cpa/c3_3_platte.md`.
*Abnahme:* Boot bis `login:` mit `root_mfm` in C: (A/B/D wie `gast_as.PLATTEN`, A = leere `/tmp`-Diskette), 0 Plattenfehler (Logpunkt im Fehlerzweig); ebenso mit `root_8x512` in C: bis `login:`;
Erste Sonde *gemessen*.
*Dauer:* ~4-6 h.

### C3.4 `mutoscpa`: Tastatur (E6d), Diskettenwechsel, Abnahme C3
*Haengt ab von:* C3.3.  *Gastlauf:* ja, Minuten (Hintergrund).
*Lesen:* `c1_7` §1, §2, §4 (`CONST` im ISR, `itest.mac`), `c1_5` §4; `mutoscpa.mac` `ISR_TAKT`, `TASTE_LESEN`, `TAB_TASTE`, `EING_TASTE`, `QUEUE_*`; `tools/plus/gastlauf.py` (Wechselablauf); §9.0.
*Erste Sonde:* `ISR_TAKT` ruft `CONST`, bei Taste `CONIN` -> `QUEUE_TASTE` (alle Register retten; BIOS-Codes direkt, `TASTE_LESEN`/`TAB_TASTE` nicht mehr benutzt).  Boot, `keys root\r` am `login:` -> `#`.
**Lange Tastenfolge:** danach `cat >/tmp/k` und eine Folge von 200 Zeichen mit allen Zeichen der Gastskripte (`a-z0-9 /.-;><|&=:*$_'"`, Ziffern) in Stuecken zu 40 waehrend `ls -lR /usr >/dev/null &`
eintippen, `^D`; Host vergleicht `/tmp/k` (aus der `--rw`-Kopie) mit der Folge.  Verlust oder falsche Codes -> blockiert, melden.
*Tun:*
1. Tastatur wie in der Ersten Sonde; Steuerzeichen pruefen, die der Kernel braucht (CR -> Zeilenende, BS/DEL, `^C`, `^D`, `^\`); Abweichungen der BIOS-Codes gegen `TAB_TASTE` im Befund.
2. **Diskettenwechsel im Betrieb** (Muster `gastlauf.skript`): `/etc/mount /dev/rk3 /mnt`, `ls /mnt`, `/etc/umount /dev/rk3`, im Debugger `eject D`/`mount D <andere Diskette gleichen Formats>`, mount, `ls /mnt` zeigt
   den neuen Inhalt.  Liest es den alten oder falschen Inhalt: Neuanmeldung (`SELDSK` E Bit 0 = 0) bei jedem **Lesen von Block 1** (Superblock; `mount` liest ihn zuerst) einbauen und Kosten messen.
   Eine andere Regel nur nach Rueckfrage (anhalten, melden).
3. Abnahme C3 (unten), `doc/plus/abweichungen.md`: Zeile "`mutos_io` CP/A-Fassung" (BIOS statt UDOS-Nukleus, Stapel C8B6, Klasse 3 entfernt, Tastatur ueber BIOS-Codes, Plattenregel; Verweis auf die Befunde C3.1-C3.4).
*Schreibt:* `mutos_io/cpa/src/mutoscpa.mac`, `mutos_io/cpa/mutoscpa.bin`, `tests/test_plus_cpa_io.py` (ergaenzen: kein Lesen von 5CH mehr ausser `SIGNALTON`), `versuche/dbg/cpa_c3_4_*.dbg`,
`doc/plus/cpa/c3_4_tastatur.md`, `doc/plus/abweichungen.md`.
*Abnahme:* Boot bis `#` mit `root_mfm` in C:, `ls -l /` vollstaendig, Datei auf `/tmp` und auf der Wurzel schreiben, `sync`; zweiter Emulatorlauf mit denselben Kopien: Dateien lesbar und auf dem Host
(`k1520disktool get`) gleich; Wechsel (Punkt 2) richtig; Tastenfolge 200/200.
*Dauer:* ~3-5 h.

### C4.1 Drucker (E7a) und tty1
*Haengt ab von:* C3.4.  Parallel zu C5.1.  *Gastlauf:* ja.
*Lesen:* `doc/mutos_io/udos_lader.md` §2.3-§2.6, `c1_5` §5, `cpa_analyse` E7, `mutoscpa.mac` `DRUCKER`, `DRUCKER_FERTIG`, `INIT_SIO`, `TTY_AUS`; `versuche/dbg/ifsspr_lp.dbg` (Messmuster), `doc/mutos_io/analyse.md` §7.
*Erste Sonde:* **`LIST` unter CP/A**, ohne MUTOS: `versuche/plus_cpa/lsttest.mac` setzt IOBYTE 80H und gibt `AB<TAB>C<CR><LF>` und 50 Zeichen ueber BIOS `LIST` aus; Logpunkte auf `OUT (5EH)`/`OUT (5FH)`.
Vergleich mit `IFSSPR` (`udos_lader` §2.4): Port 5EH, SIO-Programmierung (WR4 4DH?, WR3/WR5), TAB unveraendert oder expandiert, NUL nach CR, Takte je Zeichen.  Kommt nichts an 5EH an oder ist die
Programmierung anders als `IFSSPR` in Paritaet/Bits: Befund, blockiert, melden (Rueckfall E7 (b) braucht eine Entscheidung, §12).
*Tun:*
1. `INIT`: IOBYTE `0003H := 80H`.  `DRUCKER`: Puffer zeichenweise ueber BIOS `LIST` (synchron), danach Fertigmeldung direkt; `DRUCKER_FERTIG` und `CALL 0EB00H` entfallen.
   Sichtbares Verhalten wie `IFSSPR` herstellen, wo `LIST` es nicht selbst tut: NUL nach CR, TAB auf 8er-Spalten mit Leerzeichen (nur wenn die Sonde zeigt, dass `LIST` das nicht tut).
2. tty1: `cat /etc/motd > /dev/tty1` -> Zeichen an 50H (Zahl wie `analyse.md` §7); SIO-A-Takt messen (CTC 0CH des BIOS gegen 5AH von `mutos_io`, `c1_5` §5) -- nur Befund.
3. `doc/plus/abweichungen.md`: Zeile "Drucker ueber BIOS `LIST` statt `IFSSPR`" (mit den Unterschieden aus der Sonde).
*Schreibt:* `mutos_io/cpa/src/mutoscpa.mac`, `mutos_io/cpa/mutoscpa.bin`, `versuche/plus_cpa/lsttest.mac`, `versuche/dbg/cpa_c4_1_*.dbg`, `tests/test_plus_cpa_io.py` (ergaenzen: kein `0EB00H`),
`doc/plus/cpa/c4_1_drucker.md`, `doc/plus/abweichungen.md`.
*Abnahme:* `cat /etc/motd > /dev/lp`: Bytefolge an 5EH == UDOS-Messung (`udos_lader` §2.4: 55 Zeichen des Kernels + NUL nach CR), abgesehen von im Befund belegten Unterschieden (z. B. NUL am Auftragsanfang);
Text mit TAB wie `IFSSPR`; `cat /etc/motd > /dev/tty1` sendet alle Zeichen ueber 50H; Takte je Druckzeichen gemessen.
*Dauer:* ~3 h.

### C5.1 Gastlauf-Werkzeug ueber CP/A (`tools/plus/cpa_lauf.py`)
*Haengt ab von:* C3.4 (Boot bis `#`, Tastatur, Wechsel).  Parallel zu C4.1.  *Gastlauf:* ja (~10 Min., Hintergrund).
*Lesen:* `tools/kernel/gast_as.py` (`PLATTEN`, `dbg_skript`, `gast_befehle`), `tools/plus/gastlauf.py` (`skript`, `lauf`, `probe`), `tools/plus/gastbau.py` (`TESTS`, `testdateien`, `auswerten`, `boot`),
`tools/plus/cpa_disk.py`, `doc/plus/cpa/c3_4_tastatur.md`, §9.0.  Diese Werkzeuge **nur importieren**.
*Erste Sonde:* nur der neue Vorspann: CP/A-Boot von der Bootdiskette, `gscreen "A>"`, `keys M8KBOOT\r`, `gscreen` auf den Maskentext, `eject A` + `mount A <tmp.hfe> udos_ss77`, B/C/D mounten, `keys r`,
`gscreen "login:"` -- erreicht in einem Lauf?
*Tun:* `cpa_lauf.py` (Englisch): `skript(...)` = CP/A-Vorspann + der Teil von `gastlauf.skript` ab `keys root` (Text dort holen und am Anker schneiden; Anker genau einmal vorhanden, sonst Fehler);
`gast_befehle(...)` und `lauf(...)` mit denselben Parametern und Rueckgaben wie `gast_as.gast_befehle` bzw. `gastlauf.lauf` (Dateivorbereitung neu schreiben, Hilfen `_lauf`, `disktool`, `disk` importieren),
Emulatoraufruf nach §9.0 (Plattenkopie `.gz` im Arbeitsordner); `boot(arbeit, kernel_bytes)` wie `gastbau.boot` (gleiche `TESTS`, `testdateien`, `auswerten`).  Kommandozeile
`cpa_lauf.py probe|boot --arbeit DIR [--kernel DATEI]`; Exit 77 ohne Emulator/Workbench/Werkzeugkette.
*Schreibt:* `tools/plus/cpa_lauf.py`, `tests/test_plus_cpa_lauf.py` (schnell: Skript enthaelt Vorspann und genau die Marken von `gastlauf.skript`; `gast`: `probe`), `doc/plus/cpa/c5_1_gastlauf.md`.
*Abnahme:* `python3 -I tools/plus/cpa_lauf.py probe --arbeit /tmp/mplus/c5_1` -> 0 (Plan 47 P1.0: `cat a.txt`, Wechsel, `cat b.txt`, `ls /mnt` richtig); Laufzeit im Befund.
*Dauer:* ~3 h.

### C4.2 Arbeitstests und Leistung (Abnahme C4, O6)
*Haengt ab von:* C4.1, C5.1.  *Gastlauf:* ja (je Lauf ~5-15 Min., Hintergrund; zwei Laeufe duerfen parallel, nicht in derselben Sekunde starten).
*Lesen:* `doc/plus/gastbau.md` §5, §8; `tools/plus/cpa_lauf.py`; `doc/plus/cpa/c3_3_platte.md`, `c4_1_drucker.md`.
*Erste Sonde:* `cpa_lauf.py boot` mit dem Original-Kernel, nur `b1` (`ls -l /`) -- laeuft der Werkzeugweg durch?
*Tun:* `cpa_lauf.py boot` mit dem Original-Kernel und mit dem P3.4-Kernel (§9.0): `bewerten` ohne Fehlschlag.  Messen: Wanduhr und Takte Boot bis `#` und je Test gegen den UDOS-Weg
(`gastbau.py boot` mit demselben Kernel); Takte je Plattenblock; tiefste Stapeladresse nach allen Tests (E5H-Fuellung, `d 0xB936 ...`); Verzoegerung der Konsolausgabe waehrend Plattenzugriff.
Kein Code aendern: ein Fehlschlag, der `mutoscpa` betrifft -> Befund, blockiert, melden.
*Schreibt:* `doc/plus/cpa/c4_2_arbeitstests.md` (nur Befund; Logauszuege).
*Abnahme:* `bewerten: no failure` mit beiden Kerneln (Logpfad, Datum, Dauer im Befund); Stapel bleibt >= 100H Byte ueber B936H.
*Dauer:* ~2-3 h (meist Laufzeit).

### C5.2 Waechter, Doku, Abschluss
*Haengt ab von:* C4.2.  *Gastlauf:* Langtest (~15-30 Min., Hintergrund).
*Lesen:* alle Befunde `doc/plus/cpa/c2_*`..`c5_*`, `tests/test_plus_cpa_*.py`, `tests/test_plus_selbstbau.py` (Muster Langtest `K1520_PLUS=1`), `doc/plus/abweichungen.md`.
*Tun:*
1. `tests/test_plus_cpa_lang.py`: Langtest (`gast`, nur mit `K1520_PLUS=1`): `cpa_disk` + `cpa_lauf.boot` mit dem Original-Kernel, `bewerten` ohne Fehlschlag.
2. `doc/plus/cpa.md` (Deutsch): Startkette, Aufrufe (`cpa_system`, `cpa_disk`, `cpa_lauf`), Speicherkarte (gemessen), Laufzeiten, Grenzen (kein Rueckweg nach CP/A, Autostart fehlt); `mutos_io/cpa/README.md` aktualisieren.
3. `doc/plus/abweichungen.md` pruefen und vervollstaendigen (je Zeile Pruefung mit Test/Befund).  In `doc/plan/51_festplatte.md` die GIDE-Laufwerksbuchstaben fuer die 4-Floppy-Variante nachtragen (E: bis L: statt C: bis J:, `c1_8` §4).
4. Optional (O6): `gastbau.py fixpunkt` ueber den CP/A-Start nur, wenn `cpa_lauf` es ohne Aenderung an `gastbau.py` kann; sonst als offen vermerken.
*Schreibt:* `tests/test_plus_cpa_lang.py`, `doc/plus/cpa.md`, `mutos_io/cpa/README.md`, `doc/plus/abweichungen.md`, `doc/plan/51_festplatte.md` (nur die Laufwerksbuchstaben), `doc/plus/cpa/c5_2_abschluss.md`.
*Abnahme:* `python3 -m pytest -q tests` gruen (ausser dem bekannten Fall, §6.8); Langtest einmal gruen (Datum, Dauer im Befund).
*Dauer:* ~2-3 h.

## 10. Ablauf und Stand

Wellen (innerhalb einer Welle parallel):
**C1-1:** C1.1, C1.2 [main], C1.3 [main], C1.4, C1.5, C1.8 -- **C1-2:** C1.6, C1.7 -- **C1-3:** C1.9 -- **Entscheidung (Projektinhaber, 2026-11-17)** --
**C2-1:** C2.1, C2.2 -- **C2-2:** C2.3, C3.1 (C2.2 darf noch laufen) -- **C2-3:** C2.4 -- **C3-1:** C3.2 -- **C3-2:** C3.3 -- **C3-3:** C3.4 -- **C4-1:** C4.1, C5.1 -- **C4-2:** C4.2 -- **C5:** C5.2.
Kette auf `mutoscpa.mac` (strikt nacheinander): C2.1 -> C3.1 -> C3.2 -> C3.3 -> C3.4 -> C4.1.  `doc/plus/abweichungen.md` schreiben nur C2.4, C3.4, C4.1, C5.2 (nie in derselben Welle).

**Ab C2 traegt die leitende Sitzung die Zeilen dieser Tabelle nach** (aus Kopfzeile und Bericht des Befunds); Agenten in C2-C5 aendern diesen Plan nicht (§6 Regel 9).

| Schritt | Schreibt | Gastlauf | Dauer (Schaetzung) | Stand | Datum | Commit |
|---------|----------|----------|--------------------|-------|-------|--------|
| C1.1 | `tools/plus/cpa.py`, `versuche/plus_cpa/`, `tests/test_plus_cpa.py`, `doc/plus/cpa/c1_1_werkzeug.md` | Sekunden | 2 h | erledigt (probe: HALLO, EM256ADR/EM16ABL gleich unter GIDE-CP/A und normalem CP/A, 9 s; M80/LINKMT unterscheiden >= 7 Zeichen) | 2026-11-17 | s. git log |
| C1.2 [main] | `mutos_io/udos/` (load16), `tests/test_udos_lader.py`, `doc/mutos_io/udos_lader.md` §1, `versuche/dbg/load16_*` | Sekunden | 3 h | erledigt, gemergt (main `7025b21`, nach `mutos-plus` `932ccf3`) | 2026-11-17 | `c3c8fad` |
| C1.3 [main] | `mutos_io/udos/` (ifsspr, piopr), `doc/mutos_io/udos_lader.md` §2, `versuche/dbg/ifsspr_*` | Sekunden | 3 h | erledigt, gemergt (main `7025b21`, nach `mutos-plus` `932ccf3`) | 2026-11-17 | `63e61e1`, `9ec23d4` |
| C1.4 | `doc/plus/cpa/c1_4_inventar.md` | -- | 2-3 h | fertig | 2026-11-17 | Betreff "Plan 48 C1.4" |
| C1.5 | `doc/plus/cpa/c1_5_bios.md` | Sekunden | 3 h | fertig | 2026-11-17 | Betreff "Plan 48 C1.5" |
| C1.6 | `versuche/plus_cpa/rdtest.mac`, `wrtest.mac`, `doc/plus/cpa/c1_6_formate.md` | Minuten | 3-4 h | fertig (alle Saetze gleich bei root_fm/mfm/8x512 und GIDE; Regel SETSEC: Tabelle ab OFF, Schreiben C=0,0,0,1) | 2026-11-17 | Betreff "Plan 48 C1.6" |
| C1.7 | `versuche/plus_cpa/itest.mac`, `itest.py`, `doc/plus/cpa/c1_7_interrupts.md` | Sekunden | 2 h | erledigt (keine Tickverluste, groesste Verspaetung 0,68 ms; BIOS liest/schreibt mit Fremd-ISR richtig; E2 (a), E6 Tastatur ueber BIOS `CONST`) | 2026-11-17 | s. git log |
| C1.8 | `doc/plus/cpa/c1_8_vier_floppy.md` | Sekunden | 2-4 h | erledigt | 2026-11-17 | 7f41132 |
| C1.9 | `doc/plus/cpa_analyse.md`, §8-§10, §12 | -- | 1-2 h | erledigt (Vorlage `a3789ba`; Entscheidung 2026-11-17: alle Empfehlungen; Punkt 4: §8 Ergebnis, §9 endgueltig, §10, §12) | 2026-11-18 | Betreff "Plan 48: C1.9 Punkt 4" |
| C2.1 | `mutos_io/cpa/{src/mutoscpa.mac,build.py,mutoscpa.bin,README.md}`, `tests/test_plus_cpa_quelle.py` | -- | 1 h | erledigt | 2026-11-18 | 91fa315 |
| C2.2 | `tools/plus/cpa_system.py`, `mutos_io/cpa/system/`, `tests/test_plus_cpa_system.py`, `doc/plus/cpa/c2_2_system.md` | Sekunden | 2 h | erledigt | 2026-11-18 | 2717fec |
| C2.3 | `mutos_io/cpa/src/m8kboot.mac`, `m8kboot.com`, `versuche/plus_cpa/emfenst.mac`, `versuche/dbg/cpa_c2_3_*`, `tests/test_plus_cpa_lader.py`, `doc/plus/cpa/c2_3_lader.md` | Sekunden | 3-4 h | erledigt | 2026-11-18 | ccd7eb5 |
| C3.1 | `mutos_io/cpa/src/mutoscpa.mac`, `tests/test_plus_cpa_io.py`, `doc/plus/cpa/c3_1_namen.md` | -- | 1-2 h | erledigt | 2026-11-18 | cca1059 |
| C2.4 | `tools/plus/cpa_disk.py`, `tests/test_plus_cpa_disk.py`, `doc/plus/cpa/c2_4_bootdiskette.md`, `doc/plus/abweichungen.md` | Sekunden | 2 h | erledigt | 2026-11-18 | 1101041 |
| C3.2 | `mutos_io/cpa/{src/mutoscpa.mac,mutoscpa.bin}`, `tests/test_plus_cpa_io.py`, `versuche/dbg/cpa_c3_2_*`, `doc/plus/cpa/c3_2_start.md` | Minuten | 4-6 h | erledigt | 2026-11-18 | d6acddf |
| C3.3 | wie C3.2, `doc/plus/cpa/c3_3_platte.md` | Minuten | 4-6 h | offen | | |
| C3.4 | wie C3.2, `doc/plus/cpa/c3_4_tastatur.md`, `doc/plus/abweichungen.md` | Minuten | 3-5 h | offen | | |
| C4.1 | wie C3.2, `versuche/plus_cpa/lsttest.mac`, `doc/plus/cpa/c4_1_drucker.md`, `doc/plus/abweichungen.md` | Minuten | 3 h | offen | | |
| C5.1 | `tools/plus/cpa_lauf.py`, `tests/test_plus_cpa_lauf.py`, `doc/plus/cpa/c5_1_gastlauf.md` | ~10 Min. | 3 h | offen | | |
| C4.2 | `doc/plus/cpa/c4_2_arbeitstests.md` | 5-15 Min. je Lauf | 2-3 h | offen | | |
| C5.2 | `tests/test_plus_cpa_lang.py`, `doc/plus/cpa.md`, `mutos_io/cpa/README.md`, `doc/plus/abweichungen.md`, `doc/plan/51_festplatte.md`, `doc/plus/cpa/c5_2_abschluss.md` | Langtest | 2-3 h | offen | | |

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

## 12. Offene Punkte nach E1-E9

Keiner muss jetzt entschieden werden.  Bedingt vorzulegen ist nur:
* **E7-Rueckfall:** zeigt die Erste Sonde von C4.1, dass BIOS `LIST` an 5EH nicht wie `IFSSPR` sendet (Port, Paritaet/Bits), haelt C4.1 an.  *Empfehlung dann:* (b) Treiberkern aus
  `mutos_io/udos/src/ifsspr.mac` (ab `HWINIT`) in `mutoscpa` uebernehmen -- gleiche Hardware, bytegleich rekonstruiert, im Emulator am Port gemessen.
Alle anderen Messpunkte aus `cpa_analyse` §8 sind als Erste Sonden eingeplant (voller ISR neben `READ` C3.3, Stapeltiefe C3.2/C4.2, lange Tastenfolgen C3.4, `LIST` C4.1,
Diskettenwechsel C3.4 mit vorab festgelegtem Rueckfall).  `CONOUT` im ISR entfaellt mit E6 (d) (Ausgabe nur aus der Hauptschleife); C4.2 misst stattdessen die Verzoegerung der Ausgabe.
Nicht untersucht bleibt `diskio` (nicht noetig, E1 (a)).
