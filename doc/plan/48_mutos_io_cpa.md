# Plan 48: `mutos_io` nach CP/A portieren

Stand 2026-11-15, Branch `mutos-plus` (Plan 47).  **Grobplan**; die Detailplanung der AP folgt nach C1.  Hervorgegangen aus Plan 46 (bis `5738a8e` auf `main`).
Aussagen sind *gemessen* (mit Fundstelle), *abgeleitet* (aus Quelle gelesen), *Angabe des Projektinhabers* oder *Annahme*.

## 1. Ziel

`mutos_io` (U880-Seite, heute ein UDOS-Programm bei 9000H) laeuft unter **CP/A** (CP/M-2.2-kompatibel, Robotron) statt unter UDOS 3/4.  Alle Dienste, die
`mutos_io` heute vom UDOS-Nukleus holt (Platte, Konsole, Drucker), kommen aus dem **CP/A-BIOS**; das Laden des Kernels in den EM uebernimmt ein CP/A-Programm.
Damit stehen die Faehigkeiten des CP/A zur Verfuegung, die UDOS fehlen: **zweiseitige Disketten** (Plan 49), **RTC** (Plan 50) und **GIDE-Festplatte** (Plan 51).

Abgrenzung: In diesem Plan bleibt der **Kernel unveraendert** und das **Postfach-Protokoll** (Nachricht im EM, Klassen 0-4, `doc/mutos_io/analyse.md` §2-§3) gleich.
Abnahme ist der Boot des unveraenderten `mutos_1216` ueber CP/A bis `login:` mit den bisherigen Wurzeldisketten (soweit CP/A deren Format kann, C1).

## 2. Ausgangslage

**`mutos_io` und UDOS** (gemessen, `doc/mutos_io/analyse.md`, Plan 39):
* Startkette: UDOS-Lader-Menue -> Skript `MUTOS` = `ACTIVATE $IFSSPR`, `LOAD16 mutos_1216` (Kernel in den EM), `mutos_io` (Plan 39 §2/Zeile 384).  `ACTIVATE`, `IFSSPR`,
  `LOAD16` sind UDOS-Programme und **nicht disassembliert**.
* UDOS-Einspruenge, die `mutos_io` ruft: `0BFDH` Platte (Zylinder/Sektor-Auftrag, je 128 B Rueckruf 9893), `0BEBH` Zeichenausgabe, `0BE8H` Tastenabfrage,
  `0BF1H` Textausgabe, `0EB00H` Druckertreiber (analyse.md §5-§7).
* Eigene Hardwarezugriffe: Interrupt an den Z8000 ueber PIO A32 und `OUT (ADH)`, Zeitgeber CTC 0DH 50 Hz mit Tastaturabfrage im Zeitgeber-ISR, SIO Kanal A (tty1),
  Bedienmaske; Lage 9000H..CB68H in vier Segmenten (analyse.md §1-§4, §10).
* Block -> (Zylinder, Sektor) rechnet `mutos_io` selbst (`SEKTOR_BERECHNEN`, 26 x 128 bzw. `K8X512`), mit 16-Bit-Blocknummer (analyse.md §12).

**CP/A mit GIDE** (gemessen bzw. aus Quelle gelesen; `k1520emu: doc/merkposten/gide_cpa.md`, `k1520emu: doc/design/50_gun_gide.md`, Quelle `CPA_Workbench/src/gide_a5120/`):
* GIDE-CP/A (Variante `gide_a5120` der CPA_Workbench, bitgleich reproduzierbar gebaut): bis 4 Floppy + 8 GIDE-Laufwerke zu je 8 MB, GIDE-Basis D0H, RTC 72421 an D5H,
  Uhr in der Statuszeile; bootet von Diskette oder (Lade-ROM UL4) von der Platte.  Fertige Disketten: `k1520emu: disks/a5120_cpa_gide/`.
* **Der Emulator kann GIDE und RTC in der A5120** (*Angabe des Projektinhabers*; `k1520emu: doc/design/50_gun_gide.md`: G2-G6 erledigt).  Ob die
  Kombination **EM256 + GIDE + RTC + CP/A** in einer Maschine laeuft, ist nicht gemessen (C1).
* Portkarte A5120 (`50_gun_gide.md` §7.1a): EM A8H-AFH und B0H-B7H, GIDE D0H-DFH -- kein Konflikt (abgeleitet).
* CP/A-BIOS: Interrupts im Modus 2 mit Vektortabelle an einer 100H-Grenze (`bios.mac` `intvec`), BDOS 0E00H lang, BIOS oben im Speicher; Diskettenparameter
  fuer zweiseitige Formate (`biosdpb.mac`: 624 und 780 KB) und eine 26 x 128-Uebersetzungstabelle (abgeleitet aus der Quelle, nicht im Lauf geprueft).

## 3. Entwurfsfragen (Empfehlung, Entscheidung in C1)

1. **Plattenzugriff ueber die Standard-BIOS-Einspruenge** (`SELDSK`, `SETTRK`, `SETSEC`, `SETDMA`, `READ`, `WRITE`; 128-B-Saetze, Entblockung im BIOS) statt ueber
   interne BIOS-Routinen.  *Empfohlen*: gilt fuer Floppy und GIDE gleich, und die Sektorlaenge der Diskette ist `mutos_io` egal (ein 512-B-Block = vier Saetze).
   Zu klaeren: `SECTRAN` umgehen (MUTOS rechnet seine Verschraenkung selbst) und wie das BIOS das Format eines Laufwerks kennt (fest je Laufwerk oder erkannt).
2. **Interrupts:** CP/A belegt IM2 selbst (Tastatur, Statuszeilen-Uhr, ggf. Diskette).  Entweder traegt `mutos_io` seine Vektoren (PIO A32, CTC) in die CP/A-Tabelle ein
   und laesst die BIOS-Interrupts weiterlaufen, oder es uebernimmt die Maschine ganz und ruft nur noch die Platten-Einspruenge.  *Empfohlen*: Vektoren eintragen,
   BIOS-Tastatur und -Konsole benutzen; Risiko: Zeitverhalten der BIOS-Diskettenroutinen bei laufenden Fremd-Interrupts.
3. **Lage im Speicher:** `mutos_io` als CP/A-Programm (`.COM` ab 0100H oder unter die BDOS-Grenze verschoben).  Was heute an festen Adressen haengt (Postfach D532
   ist eine Z8000-Adresse im EM, nicht im U880-Speicher -- abgeleitet), wird beim Umbau gelistet.
4. **Kernel laden:** ein CP/A-Programm (Ersatz fuer `ACTIVATE`/`LOAD16`) liest `mutos_1216` aus einer CP/A-Datei, schreibt ihn in den EM und startet den Z8000.
   Dafuer muessen `ACTIVATE`, `IFSSPR` und `LOAD16` zuerst verstanden werden (C1).
5. **Quellort:** neue Quelle `mutos_io/cpa/` (abgeleitet aus `mutos_io/src/mutosio.mac`), die UDOS-Fassung bleibt unveraendert (sie gehoert zu `main`).
   Bau mit M80/LINKMT wie bisher (`mutos_io/build.py`-Muster), Wiederverwendbares aus der CPA_Workbench nur aufrufen, nicht kopieren.
6. **Bootdiskette:** CP/A-Systemdiskette (GIDE-Fassung, K7024) plus Lader, `mutos_io` und `mutos_1216` als CP/A-Dateien; Zusammenbau mit dem DiskTool.

## 4. Arbeitspakete

| AP | Inhalt | Abnahme |
|----|--------|---------|
| C1 | **Analyse:** `ACTIVATE`, `IFSSPR`, `LOAD16` disassemblieren (EM-Aktivierung, Laden, Start); CP/A-BIOS: Einspruenge, Interrupttabelle, Speicherlage, Formaterkennung, welche MUTOS-Diskettenformate (26 x 128 FM/MFM, 8 x 512) das BIOS lesen kann; Emulator-Probe EM256 + GIDE + RTC + CP/A | Befunddokument `doc/plus/cpa_analyse.md`; Entscheidungen zu §3 |
| C2 | **Lader** (CP/A-Programm): Kernel in den EM, Z8000 starten | Kernel laeuft an (Debugger: Z8000 im Kernel), noch ohne `mutos_io` |
| C3 | **`mutos_io` Plattenweg** ueber das BIOS | Boot bis `login:` mit bisheriger Wurzel |
| C4 | Konsole, Tastatur, Zeitgeber, Drucker, tty1 ueber BIOS bzw. eigene Hardwarezugriffe | Arbeitstests wie Plan 47 P3 |
| C5 | **Bootdiskette und Bau** (`tools/`), Waechter (pytest, Marke `gast`) | Boot und Arbeitstests im Emulator; Eintrag in `doc/plus/abweichungen.md` |

## 5. Risiken

* Die UDOS-Startprogramme koennen mehr tun als angenommen (Speicherumschaltung, EM-Initialisierung) -- C1 klaert das vor jedem Bau.
* Das CP/A-BIOS kann einzelne MUTOS-Formate nicht (z. B. 26 x 128 auf K5601 MFM): dann sind die alten Wurzeldisketten ueber CP/A nicht nutzbar, und die Wurzel muss
  auf ein CP/A-Format umgezogen werden (vorgezogener Teil von Plan 49).
* BIOS-Aufrufe sind langsamer als der direkte Nukleusweg (vier Saetze je Block); messen, nicht annehmen.
