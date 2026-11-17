# C1.5 CP/A-BIOS aus der Quelle (GIDE-CP/A, Variante `gide_a5120`)

Stand 2026-11-17, Plan 48 C1.5.  Quellen: `~/projects/CPA_Workbench/src/gide_a5120/` (nur gelesen; Zeilennummern = `rg -n`, Stand der Workbench am
2026-11-17), Emulator-Diskette `k1520emu: disks/a5120_cpa_gide/a5120_cpa_gide_k7024_2fdd_8gide_system.hfe` (2 Floppy, 8 GIDE, K7024).
Kennzeichnung: **gemessen** (Debuggerlauf, Muster Plan 48 §2.1, Arbeitsordner `/tmp/mplus/c1_5/`, 24,6 Mio. Takte bis `A>`, 3 s Wanduhr),
**abgeleitet** (Quelle Datei:Zeile), **Annahme**.

Vorbehalt Bauvariante: die Quelle waehlt in `setup.mac` `crt equ bwshp`; die Emulator-Diskette ist mit `crt = k7024` gebaut (`gide_cpa.md` Nr. 1).  Das
aendert nur den Bildschirmtreiber (`bioscrt.mac` statt `biosbw2.mac`) und die Laenge des BIOS; alle Adressen unten sind die der **Emulator-Diskette**
(gemessen) und verschieben sich bei einem anderen Bau.  `mutos_io` darf BIOS-Adressen nie festschreiben, sondern muss sie zur Laufzeit aus dem
Sprungvektor (`0001H`/`0005H`) bzw. aus `004EH` holen (Abschnitt 6).

## 0. Erste Sonde (gemessen)

Nach dem Boot (`gscreen "A>"`, `d 0xCB00 0x60`, `d 0xF700 0x100`, `d 0x0000 0x60`, `ivt`, `dev ctc|sio|pio|em`):
```
CB00: C3 E5 E7 C3 F1 E7 C3 1E E7 C3 2A E7 C3 36 E7 C3   kaltst E7E5, warmst E7F1, const E71E, conin E72A, conout E736, list ...
CB10: 72 E7 C3 5A E7 C3 4E E7 C3 13 DA C3 26 DA C3 7F   ... list E772, punch E75A, reader E74E, h_home DA13, h_seldsk DA26, h_settrk DA7F
CB20: DA C3 74 DA C3 8A DA C3 95 DA C3 2A DB C3 66 E7   h_setsec DA74, h_setdma DA8A, h_read DA95, h_write DB2A, listst E766
CB30: C3 6B DA 43 50 41 42 36 42 FE FF 13 D5 00 00 43   h_sectran DA6B, 'CPA', 'B','6', crtcps FE42, crtccn FF, kbdsst D513, synflg 00, synsem 00, 'COLBWS'...
F7D0: 00 .. 00 00 00 00 9A D9 E4 D9 | F7E0: 00 00 00 00 00 00 00 00 05 E4 00 .. | F7F0: .. 00 00 68 E6 8C E6
F700..F7CF: durchgehend FF (unbelegt)
0000: C3 03 CB 00 00 C3 06 BD   (Warmstart CB03, BDOS BD06, IOBYTE 00, Standardlaufwerk A)
```
Registerstand: `I=F7 IM=2 IFF1=1`, `PC=E7B3` (`JP (HL)` in der CONIN-Warteschleife; wartet auf Taste).  Kopfzeile: `TPA 100H - 0BD05H`.

## 1. Sprungleiste ab CB00 (Frage 1)

Abgeleitet `bios.mac:1364-1420` (Reihenfolge des festen BIOS-Vektors), gemessen oben.  Alle Eintraege sind `JP` zu je 3 Byte, CP/M-2.2-Konvention.
Mit GIDE (`anzgide > 0`) zeigen die Plattenvektoren auf `h_*` (`bios.mac:1370-1396`): sie pruefen `hdisk` und springen bei Floppy in die Floppy-Routinen.

| Adr | Name | Eingang | Ausgang | Bemerkung |
|-----|------|---------|---------|-----------|
| CB00 | BOOT | -- | -- | Kaltstart; bei wiederholtem Kaltstart `kalts1`: CTC-Quellen aus, `OUT (0AH),F7H` (Lade-ROM zu), `RST 0` = Neustart des Rechners (`biosnuc.mac:520-540`) |
| CB03 | WBOOT | -- | -- | Warmstart: `SP=0080`, CCP-Kopie (2 KB im BIOS bei E8A7) nach B500 zurueck, `I`/`IM 2` neu, Sprungzellen 0/5/38H neu (`biosnuc.mac:551-600,643`) |
| CB06 | CONST | -- | A=FF/00 | IOBYTE-Verteiler (`biosnuc.mac:47`), Standard `kbdst` |
| CB09 | CONIN | -- | A | wartet; zerstoert A,HL (`iodisp`), IX bleibt erhalten |
| CB0C | CONOUT | C | -- | Standard `crto` (Bildschirm) |
| CB0F | LIST | C | -- | Standard TTY (SIO A 50H/51H) |
| CB12 | PUNCH | C | -- | |
| CB15 | READER | -- | A | |
| CB18 | HOME | -- | -- | GIDE: kein Flush eines wartenden Schreibsatzes (`biosgide.mac:62`) |
| CB1B | SELDSK | C=Laufwerk 0..., E Bit0 | HL=DPH oder 0 | E Bit0=0: LOGIN, Formaterkennung (Floppy) |
| CB1E | SETTRK | BC (16 Bit) | -- | |
| CB21 | SETSEC | C (Floppy) / BC (GIDE) | -- | Floppy 1-basiert, GIDE 0-basiert, siehe Frage 2 |
| CB24 | SETDMA | BC | -- | |
| CB27 | READ | -- | A=0 ok / 1 Fehler | |
| CB2A | WRITE | C=0/1/2 | A=0 / 1 | |
| CB2D | LISTST | -- | A=FF/00 | |
| CB30 | SECTRAN | BC, DE | HL | Floppy HL=BC+1, GIDE HL=BC |
| CB33 | Kennung | -- | -- | `'CPA'`, danach `'B'` (Buerocomputer), `'6'` (Schnittstellenversion) |
| CB38 | `crtcps` | -- | -- | Wort: Kursor im Bildschirmpuffer (gemessen FE42); `crtccn` Byte CB3A |
| CB3B | `kbdsst` | -- | -- | Wort: Zeiger auf die Tastatur-Stringtabelle (gemessen D513) |
| CB3D | `synflg` | -- | -- | Bit 6 `stzaus` = 1: Uhr/Statusanzeige aus (gemessen 00 = Uhr an); CB3E `synsem` (>0 = keine asynchrone Arbeit) |
| CB3F | `'COLBWS'` | -- | -- | Merkzellen des Farb-BWS-Treibers (3 Byte), danach die DPH |

**CP/A-Zusaetze (Frage 1, erweiterter Vektor):** Das Wort bei **`004EH`** (`cpmext`, `bios.mac:1303`) zeigt auf die Zusatzsprungleiste; gemessen `004E = AA D2` -> **D2AA**.
Abgeleitet `bios.mac:1533-1577`, gemessen `d 0xD2AA`:

| Adr | Eintrag | Inhalt in dieser Bauart |
|-----|---------|-------------------------|
| D2AA | +00 Monitor | `RET` (kein Monitor, `monitor=0`) |
| D2AD | +03 `tim5on` | `JP E652` : 5-ms-CTC-Kanal 2 an |
| D2B0 | +06 `tim5of` | `JP E659` : 5 ms aus (stoppt damit auch die Tastaturabfrage im 5-ms-Takt) |
| D2B3 | +09 `tim1on` | `JP E65D` : 1-s-CTC-Kanal 3 an |
| D2B6 | +0C `tim1of` | `JP E664` : 1 s aus (stoppt Uhr) |
| D2B9..D2C8 | +0F..+1E | `RET` (Speicherschutz, Stop-Sperre, Umlaute nicht gebaut) |
| D2CB | +21 `diskio` | `JP DF8F` : **physischer Diskettentransfer** mit Steuerblock (`biosdsk.mac:885`, CDB-Aufbau dort Zeile 840-880); ermoeglicht Spur/Seite/Sektor/Sektorlaenge direkt (`diofps`), ohne Formaterkennung und ohne Fehlermeldung (`dioftr`) |

Die Adressen E652.. sind **Bauvariante**; stabil ist nur der Weg ueber `004EH` und die Reihenfolge der Zusaetze.  Weitere feste Zellen (`bios.mac:1290-1320`):
`0040` Lampen, `0041/42` 5-ms-Zaehler, `0043/44` 1-s-Zaehler, `0045/46` Adresse der Nutzer-1-s-Routine (`tim1rt`), `004A/4C` Anfang/Ende zeitkritischer Abschnitte
(`kritbg/kriten`, gemessen `E658` = `RET`), `0050..0052` Uhr HH:MM:SS (BCD), `0053..0055` Datum **nicht gepflegt** (`datvar=0`).  `RST 38H` = `JP 0000` = Warmstart (kein Monitor).

## 2. Platte (Frage 2)

### 2.1 Gemeinsam
* **SELDSK** (`biosgide.mac:79`): `lwtab` (`biosgipb.mac:73`, bei 2 Floppy: `00,01,A0..A7,FF...`) bildet Laufwerk -> Floppy-Nummer oder IDE-Kopf ab; Bit 7 = IDE.  Unbekanntes Laufwerk: HL=0, und
  ist es das Standardlaufwerk, wird dieses auf das Kaltstartlaufwerk (`clddev`) zurueckgesetzt.
* **WRITE-Typ (C)** hat Wirkung: C=1 (Verzeichnis) erzwingt **sofortiges Schreiben** (Floppy `biosdsk.mac:~735`, GIDE `biosgide.mac:240-250`); C=0/2 puffert.
  **Folgerung (abgeleitet):** `mutos_io` muss jeden Satz mit **C=1** schreiben, sonst bleibt der letzte Satz im Hostpuffer.  `HOME`, `SELDSK` und `WBOOT` schreiben **nicht** zurueck
  (Floppy: `seldsk` verwirft sogar einen veraenderten Puffer, `biosdsk.mac:53-57`).
* Fehlerrueckmeldung: A=1 bei Fehler (Floppy `drwerr`, `biosdsk.mac:609`; GIDE `herflag` aus Statusbit 0, `biosgide.mac:326`).  Zusaetzlich gibt das BIOS bei Diskettenfehlern
  `\r\nR/W<code>;T,Si,Se=<trk><sid><sec>` **auf den Bildschirm** (`biosdsk.mac:1071-1105`, `errvar=1`) -- Code `C/D/R/L/S/T/U/W` (`biosdskt.mac:42-50`).  GIDE: **keine** Wiederholung, keine Meldung.
* Der Lese-/Schreibpuffer des BIOS liegt im BIOS (Floppy `dbuf` 1 KB, GIDE `hdbuf` 512 B); `SETDMA` gilt fuer jeden Transfer neu (Nutzerpuffer wird je 128 B kopiert).

### 2.2 Floppy (gemessen die Standardlaufwerke A:/B:, 5", 80 Spuren, DD, DS, Typ 11580)
* **SETSEC ist 1-basiert** (`sectran` liefert BC+1, `biosdsk.mac:518`; `drw` prueft `1..dpbspt`, `biosdsk.mac:646`).  Ein Aufrufer ohne `SECTRAN` muss selbst 1..SPT uebergeben.
  Ob die Sektornummer dann ueber die Satz-Tabelle `dpbstr` (1,2,3,.. oder fuer 26x128 SCP-Versatz 1,7,13,..,`biosdsk.mac:1236`) in die physische Nummer geht, entscheidet die Formaterkennung.
* **READ/WRITE uebersetzen selbst** (logischer 128-Byte-Satz -> Spur/Seite/phys. Sektor, `diskio` ab `biosdsk.mac:~930`).  Entblockung: 1-KB-Puffer, ein phys. Sektor (128/256/512/1024) wird
  gelesen/geschrieben, der vorgeschaltete Lesevorgang entfaellt bei Schreiben in unbelegte Bloecke (`WRITE C=2`).
* **Spurzaehlung DS:** logische Spur `t` -> Zylinder `t/2`, Seite `t and 1` (Spuren wechseln die Seite), `biosdsk.mac:~955-960`; Sonderfall `dpbf86` (Rueckseite fortlaufend).  Bei SS: Spur = Zylinder.
  Spur ist 16 Bit.
* **Formaterkennung** (`format=1`, `@fact=1`, `biosdsk.mac:60-405`): laeuft bei **jedem `SELDSK` mit E Bit 0 = 0** (LOGIN); sie liest Sektorkennungen auf Spur 0 und auf der "Login-Spur" `dlgint=3`,
  entscheidet SS/DS, 40/80 Spuren (Doppelschritt), Sektorlaenge 128/256/512/1024 und stellt den DPB neu (Tabellen `dtrsl0..3`, `biosdsk.mac:1175-1230`).  Systemspuren (`dpbofs`) werden aus dem Inhalt
  von Spur 0 geraten (E5 = leer, `40H`/`<20H` = Daten ohne Systemspuren, sonst Verzeichnis).  **Ist das Format nicht erkennbar** (Kennungen widerspruechlich): `dpbslc = FF` ("BAD SECTOR"),
  `SELDSK` liefert **HL=0** (`seldle`, `biosdsk.mac:~250`).
  Erkannte 5"-Formate mit **128-Byte-Sektoren** (die der MUTOS-Disketten): 40 Spuren x 26, 80 x 26, 160 (DS) x 26; **kein 77-Spur-Eintrag** (der steht nur unter `disk8`, hier `disk8=0`).  Ob
  `ss77_26x128` der MUTOS-Wurzeldisketten auf diesem Weg richtig ankommt (z. B. Spuren 77-79, FM statt MFM: 5"-FM wird nur bei `dsk8mf` per `dioffm` versucht), ist **offen fuer C1.6**.
* Wiederholungen: CRC-Fehler und Spursuche mehrfach (`biosdskt.mac:164-170`, 4+1 Spurversuche), "nicht bereit" (`R`) endlos (`diorty`); `dioftr` unterdrueckt beides.

### 2.3 GIDE (abgeleitet `biosgide.mac`, `biosgipb.mac`; gemessen: `GIDE-Laufwerke C: bis J:`, 520 Cyl, 16 Hd, 63 Sec im Emulatorabbild)
* **Ein CP/A-Laufwerk = ein Kopf der Platte** (`lwtab` `A0+Kopf`, `IdeSDH`), also 8 Laufwerke = Koepfe 0-7.  Je Laufwerk **500 Spuren x 32 Sektoren x 512 B = 16 000 Sektoren = 8 MB** (Spur =
  Zylinder, `DPBHD`: SPT 128 Saetze zu 128 B = 32 Plattensektoren, Block 8 KB, DSM 1000 Bloecke -> `3E7H`, 1024 Verzeichniseintraege).  Genutzt wird nur Sektor 1..32 von 63.  Erstes GIDE-Laufwerk (C:)
  hat **2 Systemspuren** (`DPBHD0`, OFF=2, DSM `3E3H`), alle anderen 0.
* **SETSEC 0-basiert** (`h_sectran` = BC, `h_setsec` speichert BC unveraendert) -- **anders als Floppy**: `h_setsec`/`h_sectran` leiten bei Floppy weiter, bei GIDE nicht.  Satz `n` (0..127) liegt in
  Plattensektor `(n shr 2) + 1`, Byte-Versatz `(n and 3)*128`; `SETTRK` = Zylinder (16 Bit, `IdeCLo/CHi`).
* **Entblockung** (`biosgide.mac:173-253`): 512-Byte-Hostpuffer mit CP/M-Standardalgorithmus (`hstact/hstwrt`, `unacnt`); wartender Schreibsatz wird geschrieben, wenn ein **anderer** Hostsektor/Laufwerk
  verlangt wird oder bei `WRITE C=1`.  `HOME` loescht nur `hhstact` (wenn nichts wartet).
* **Fehler:** `herflag` = Statusbit 0 nach dem Transfer; BSY-Warten in `tfset`, DRQ-Warten in `wtrdy` **ohne Zeitgrenze** (haengt bei fehlender Platte); `hdinfo` im Kaltstart wartet `hdtim` s auf die Platte
  (`biosnuc.mac:~1000`).
* Emulator-Abbild: Basis D0H fest (`GIDEADR`), Ports D6H (DOR), D8H..DFH (`biosgide.mac:28-38`); kein Konflikt mit EM (A8H-AFH, B0H-B7H).

## 3. Interrupts (Frage 3)

Abgeleitet `bios.mac:1200-1262`, `biosnuc.mac:551-562,1417`, `biostimc.mac`, `bioschdc.mac`, `biosdskc.mac`; gemessen `ivt`, `dev ctc|pio|sio`.
* `LD I,F7H; IM 2` im Kaltstart **und bei jedem Warmstart** (`warmin`); die Tabelle `intvec = F700H` liegt immer 100H vor dem Bildschirmpuffer (`bios.mac:1200,1343`).  Vom BIOS belegt ist nur
  **F7D0..F7FF** (`intvl = intvb = intvsy-10H = D0H`); F700..F7CF sind **frei** (gemessen FF, durch den RAM-Test; die Kaltstart-Schleife `intvcl` loescht nur ab `intvr = F7D0`).
* Belegte Vektoren (gemessen `ivt`, Quelle): **F7E8 -> E405** `ivdsk1` (K5122-Steuer-PIO A, Vektor E8, Index-Interrupt fuer Motorabschaltung `itimeo`, `biosdskt.mac:662`), **F7FC -> E668** (CTC Kanal 2,
  `tim5it`, 5 ms), **F7FE -> E68C** (CTC Kanal 3, `tim1it`, 1 s).  Daneben **F7DC -> D99A, F7DE -> D9E4**: SIO-Kanal-A-Empfang/Sonderfall der UC1-Kopplung (`uc1rin/uc1err`, `bioschdc.mac:12-14`) --
  aktiv wird die UC1-SIO erst bei erster Benutzung von IOBYTE-Kanal UC1 (traege Initialisierung `uc1si`, `bioscsio.mac:190`); gemessen im Ruhezustand `dev sio`: `wr1=00 vec=00`, keine SIO-Interrupts.
  `ivpar F7E0`, `ivpiod F7E2`, `ivprot F7E6`, `ivdsk2 F7EA` (nur FORMAT.COM), `intvsy+0CH = F7EC`, `ivpun/ivrdr F7F0..F7F6`, `ivctc0 F7F8`, `ivctc1 F7FA` sind **nicht belegt** (gemessen 0000).
* Programmierte Bausteine (gemessen):
  * ZRE-CTC 0CH..0FH, Vektorbasis **F8** (`OUT (0CH),F8H`, `biostimc.mac`): **Kanal 0 und 1 im Reset** (`ctl=03`, kein INT); **Kanal 2** `ctl=B1`, TC=30H (Zeitgeber, Vorteiler 256 -> 5 ms), INT an; **Kanal 3**
    `ctl=D1`, TC=C8H (Zaehler aus Kanal 2, 200 x 5 ms = 1 s), INT an.  Der CTC-Kanal 1 (0DH), den `mutos_io` fuer 50 Hz benutzt, ist **frei**.
  * K5122-Steuer-PIO 10H-13H: Port A Modus 0, Vektor E8, INT an (Index); Port B Vektor 60 aus.
  * ZRE-PIO 08H-0BH: Modus 3, kein INT; `IN/OUT (0AH)` im Kaltstart (Lade-ROM aus).  K8025: SIO 5CH/5DH (Tastatur, **ohne Interrupt**), CTC 58H Kanal 0 (Tastaturtakt 9600 Bd).
  * EM-PIO A32 (A8H..), ADH, AFH: **unberuehrt** (`em256=0`, `dev em` im Grundzustand `U8001=RESET16`).
* ISRs: laufen auf **eigenem Stapel** `intstk` (12 Worte, `biosnuc.mac` Arbeitsfelder; `intsp` merkt SP, **nicht wiedereintrittsfest**).  `tim5it`: Zaehler `tim5cn`, Tastatur abfragen (`kbdsti`), Lampen.
  `tim1it` -> `tim1up`: Zaehler, **RTC lesen** und HH:MM:SS **in die Bildschirmecke schreiben** (Zeile 0, Spalte 72-79 = `F848..F84F` bei 24x80, `biostim.mac:250-300`), Motorabschaltung, dann
  Sprung ueber `tim1rt` (Nutzer-Hook, `004A`-Familie).
* `DI` in den Diskettenroutinen: **nur im Spurschritt** (`step`: `DI; OUT; OUT; EI`, wenige Takte, `biosdskt.mac:341-358`); der Datentransfer laeuft **mit offenen Interrupts**, weil ihn die zweite CPU (ZVE2)
  ausfuehrt (Abschnitt 6).  Die Interruptannahme der ersten CPU kostet dabei 6 Takte Busbelegung (Kommentar `biosdskp.mac:55-62`).  Messung der Latenz in C1.7.

## 4. Konsole (Frage 4)

* **CONOUT** (`bioscrt.mac:105-200`; Diskette = K7024-Treiber): schreibt **direkt in den Bildschirmspeicher** `F800H..FF7FH` (24 x 80 = `0780H` Byte, bei Loetbruecke an Port 0AH Bit 6 = 16 x 64 ab `FC00H`;
  `bioscrtc.mac:7-20`); keine Ports.  Kursor = Bit 7 des Zeichens an `crtcps`.  Steuerzeichen nach SCP/A5120 (Tabelle `crto09/crto11` in `bioscrt.mac`, unverifiziert im Einzelnen: BS/LF/CR/FF, Kursorsteuerung, `84H..87H` Hell/Invers, ESC-Folgen; `1B 5E/5F` Feldattribut mit `escpc=1`;
  `inslin=0`, `adm3a=0`, `umlaut=0` -> diese Erweiterungen fehlen).  Die genaue Steuerzeichenbelegung ist fuer C4 nur wichtig, wenn `mutos_io` die BIOS-Ausgabe statt eigener Bildschirmroutinen nutzt (*Annahme*: dann noetig).
  Ein Zeichenaufruf setzt waehrend der Ausgabe `intcrt` auf `JP`, damit die 1-s-ISR nicht gleichzeitig in den Bildschirm schreibt (`bioscrt.mac:107`).
* **Keine Statuszeile** (`cpastz=0`); nur die **Uhr** `HH:MM:SS` rechts oben, gesetzt von `tim1up` (abschaltbar mit `synflg` Bit 6 = CB3D).
* **CONST/CONIN** (`bioskbd.mac:47-300`): K7637-Tastatur an SIO **5CH (Daten) / 5DH (Status)**, **Abfrage ohne Interrupt**: `kbdst1` testet `IN (5DH)` Bit 0, `kbdrch` holt `IN (5CH)`, setzt Code um (Tastatur-
  Stringtabelle `kbdsst`), legt in den **20-Zeichen-Puffer** `kbdbl=20` (im BIOS, ohne Statuszeile).  Abgefragt wird (a) von `CONST`/`CONIN` und (b) **in jeder 5-ms-ISR** (`tim5it` ->`kbdsti`).
  Initialisierung (`bioskbdc.mac:62-72`, **gemessen nur ueber die Quelle**): CTC 58H Kanal 0 (`05H,01H` = Zeitgeber, Konstante 1 = 9600 Bd x 16), SIO-Programm `k37par` (WR4 44H, WR5 68H, WR3 C1H, kein Interrupt)
  -- dieselbe Hardware und Programmierung, die `mutos_io` kennt (`analyse.md` §11 Zeile 151).
  CONIN wartet mit Tastenwiederholung; **zwei Leser an 5CH** (BIOS-5-ms-ISR und `mutos_io`-Zeitgeber-ISR) klauen sich gegenseitig Zeichen -> Folge in §7.

## 5. LIST und IOBYTE (Frage 5)

Abgeleitet `bios.mac:583-615`, `biosnuc.mac:47-100,115-150`, `bioscsio.mac`.  IOBYTE bei `0003H`, nach Kaltstart **00H** (gemessen).
* **LST:** (Bits 7,6): 00 **TTY** = SIO A **50H/51H** (Daten/Kommando), Protokoll DTR ueber Kanal A (`iobtty = 01811`: keine Paritaet, 1 Stopbit, 8 Bit, 9600 Bd), Baudtakt **ZRE-CTC 0CH Kanal 0**
  (`ttycts = 0CH`); 01 CRT (Bildschirm); 10 **LPT** = **5EH/5FH** (IFSS), DC1/DC3, ungerade Paritaet, 7 Bit, 9600 Bd, Takt K8025-CTC **58H** Kanal 0; 11 hexadezimal auf den Bildschirm.
* **CON:/RDR:/PUN:** (Bits 1,0 / 3,2 / 5,4): Kanal 3 = **UC1** = SIO A 50H/51H mit **Empfangsinterrupt** und 20-Byte-Puffer (`uc1bfl=20`), `ivsio6/7`.
* Initialisiert wird eine serielle Schnittstelle **beim ersten Gebrauch** (`cdsins`/`uc1si`), nicht beim Kaltstart und nicht beim Warmstart (`bioschd.mac:chdwarm` leer) -- gemessen: SIO `wr1=00`, CTC 0CH Kanal 0 im Reset.
* **Folgerung (abgeleitet):** Das BIOS beruehrt SIO A (50H) und CTC 0CH nur, wenn jemand `LIST`/UC1 aufruft; ruft `mutos_io` `LIST` nicht, bleibt SIO A fuer `mutos_io` frei.  Auffaellig:
  das BIOS taktet SIO A mit CTC **0CH** Kanal 0, `mutos_io` (analyse.md) mit K8025-CTC **5AH** Kanal 2 -- zwei verschiedene Taktquellen fuer denselben Port; welche die Hardware wirklich nutzt, ist
  *Annahme* (beide laufen im Emulator); fuer C4.1 (tty1) zu messen.

## 6. Speicher (Frage 6)

Gemessen (`d 0xB400 0x4C00`, Auswertung der Fuellmuster) und abgeleitet (`bios.mac:198-206,1330-1360`, `biosnuc.mac:760-1040`):

| Bereich | Inhalt |
|---------|--------|
| 0000-0007, 0038-003A, 0040-0055 | Warmstart-Sprung, IOBYTE, Standardlaufwerk, BDOS-Sprung, `RST 38`, BIOS-Zellen (`lampbf`, Zaehler, Hooks, Uhr) |
| 0001/0002 | beim Diskettentransfer **kurz** mit der Adresse des ZVE2-Programms `dio` ueberschrieben (`biosdskp.mac:11-30`: `ld (1),hl ... ld (1),bc`) |
| 0100-BD05 | TPA |
| B500-BCFF | CCP (0800H), BD00-CAFF BDOS (0E00H), BDOS-Eingang BD06 |
| **CB00-F648** | **BIOS**: Sprungleiste CB00-CB3F, DPH/DPB-Tabellen, Treiber (Code ab ca. D200), Kaltstartcode (nur beim Start), CCP-Kopie **E8A7-F0B7** (`ccpload=0`), `dirbuf` F0D0 (128), `alv/csv` F15x, Diskettenpuffer `dbuf` **F234-F633** (1 KB), Tastaturpuffer, GIDE-`hdbuf` (512 B) |
| F649-F6FF | frei (Rest bis zur 100H-Grenze) |
| **F700-F7CF** | **frei** (FF), Teil der Interrupttabelle |
| F7D0-F7FF | BIOS-Interruptvektoren (siehe §3) |
| F800-FFFF | Bildschirmspeicher (K7024 24x80 = F800-FF7F; FF80-FFFF Rest) |

* BIOS-Lage: `biosad = rambyt - biosl0`, `biosl0` = Laenge auf 256 gerundet (`bios.mac:1340`).  Bei `anzgide=8`, `anzdisk=2`, `ccpload=0`: **CB00**; jeder Wechsel einer Option verschiebt alles.
* **Das Kaltstart-Programm** wird nach `0180H` kopiert und von dort ausgefuehrt (`kaltsb`, gemessen `0180: 21 00 00 36 00 ...`), loescht `0000-007F`, setzt die Bausteine zurueck
  (`OUT (0CH..0FH),03`, `OUT (09H),03`, `(11H),(13H)` PIO-Interrupts aus, `(18H) = FF`), liest die GIDE-Platte (`hdinfo`), stellt `I`/`IM 2` und fuellt die BIOS-Arbeitsfelder mit `FDH`.
  Danach wird `0180H` nicht mehr gebraucht (frei fuer `mutos_io` im Segment 0).
* **Was `mutos_io` unter CB00 nach dem Start noch braucht:** bei Benutzung der BIOS-Einspruenge der **gesamte BIOS-Teil CB00-F648** und die Zellen `0000-0002`, `0003/0004`, `004A-004F`, `0040-0055`;
  CCP/BDOS (B500-CAFF) werden **nicht** gebraucht, sobald nur BIOS-Einspruenge benutzt werden.  `mutos_io` (9000H.. mit Daten bis B936H) ueberdeckt den CCP, laeuft aber **nicht ueber CB00**; **nur der
  Stapel CB68** (`SP = CB68`, wachsend nach unten ab CB67) liegt in der Sprungleiste und den Merkzellen CB00-CB67 -- er **muss unter CB00 verlegt werden** (abgeleitet; C3.2).
* Zweite CPU: Der Diskettentransfer wird von der **ZVE2** ausgefuehrt (`OUT (04H),0` Reset, Start ueber `BUSRQ` durch Lesen von Port 16H), die ihr Programm aus dem **gemeinsamen RAM** (BIOS `dio`) holt und
  ueber `JP` bei `0000H` ankommt (`0001/0002` wie oben).  `0000H` muss `C3` enthalten; **EM-Fenster 4000-7FFF** wird vom Floppytransfer nicht benutzt (abgeleitet, `fldaad/fldabd` = Daten-PIO 14H-17H).

## 7. RTC (Frage 7, nur vorgemerkt fuer Plan 50)

Abgeleitet `biostim.mac:230-290`: RTC 72421 an **D5H** (`RTCADR = GIDEADR+5`), Registerwahl ueber **B** (`in a,(c)` mit `B` = Register, `C=D5H`).  Register `0DH` = Steuerregister (Bit 0 Hold, Bit 1 Busy),
Register 5..0 = Stunden-/Minuten-/Sekundenziffern (Zehner/Einer).  Gelesen wird **einmal je Sekunde** in `tim1up` (nur Zeit, kein Datum), Ablage `0050H..0052H`.  Fehlende Karte erkennt das BIOS an `IN` = FFH.
**Schreiben der Uhr** fehlt im BIOS (kommt aus `additions/gide_a5120`-Werkzeugen der Workbench, nicht gelesen).

## 8. Liste "frei fuer `mutos_io`"

Abgeleitet aus Quelle + gemessen (Bauvariante Emulator-Diskette).

| Betriebsmittel | frei | belegt vom BIOS |
|----------------|------|-----------------|
| Vektorplaetze (`I=F7`) | **F700-F7CF** (alle, inkl. UDOS-gleiche Plaetze `F730..F73F` SIO-Kanal B/A, `F7EA` PIO A32-A, `F7EC` PIO A32-B), `F7E0/E2/E4/E6`, `F7F0..F7FA` (CTC 0/1) | F7D0-F7DF (UC1-SIO, nur bei Benutzung), `F7E8` (Floppy-Index), `F7FC`, `F7FE` (CTC 2/3) |
| CTC 0CH-0FH | **Kanal 0 und 1** (0DH fuer 50 Hz: Vektor dann **F7FA** bei BIOS-Basis F8; mit eigener Basis (z. B. E0 wie UDOS) liegt Kanal 1 bei F7E2) | Kanal 2, 3 (Uhr, Tastatur im 5-ms-Takt); abschaltbar ueber `004E`-Leiste `tim5of`/`tim1of` |
| CTC 58H-5BH (K8025) | alle, **Kanal 0** nur gemeinsam mit BIOS (Tastaturtakt, gleiche Konstante 1) | Kanal 0 (Tastatur, LPT) |
| SIO 50H-53H | beide Kanaele, solange nie `LIST`/UC1 gerufen wird | Kanal A bei `LIST` (TTY) / UC1 |
| SIO 5CH/5DH | gemeinsam mit BIOS lesbar, **aber** BIOS pollt zusaetzlich in der 5-ms-ISR (Zeichen werden gestohlen) -> BIOS-Zeitgeber vorher abschalten (`tim5of`) oder BIOS-Tastatur benutzen | -- |
| EM-PIO A32, ADH, AFH (A8H-AFH, B0H-B7H) | **alles** | nichts |
| K5122-PIOs 10H-17H, Latch 18H, ZVE2, Port 04H, 16H | -- | BIOS (nur bei Floppy-Zugriff aktiv; IM-2-Index-Interrupt dauernd) |
| GIDE D0H-DFH, RTC D5H | -- | BIOS (Platte; Uhr jede Sekunde) |
| Speicher | `0180-01FF` (nach dem Start), **F649-F6FF**, **F700-F7CF**, TPA 0100-B4FF (unter dem CCP), `B500-CAFF` (CCP/BDOS, wenn nur BIOS-Einspruenge benutzt werden), EM-Fenster 4000-7FFF (wenn nicht Floppy-ZVE2-Programm dort) | CB00-F648 (BIOS), F7D0-F7FF, F800-FFFF (Bildschirm), 0000-0007/0038-003A/0040-0055 |
| Stapel `CB68` | **nein** -- liegt in der BIOS-Sprungleiste, nach unten verlegen (z. B. `CB00`) | -- |

## 9. Offene Punkte (an C1.6 / C1.7 / C3)

1. **C1.6:** Erkennt die Formaterkennung die MUTOS-Wurzeldisketten (`ss77_26x128`, FM und MFM) richtig, und kommen alle Saetze an (`dtrsl0` ohne 77-Spur-Zeile, 5"-FM nur ueber `dioffm` bei 8"-MFM)?
   Alternativ `diskio` (`D2CB`) mit physischen Werten (`diofps`) -- dann entfaellt die Erkennung.
2. **C1.7:** Latenz der Interrupts waehrend des ZVE2-Transfers, Verhalten von `mutos_io`-ISRs (EM-PIO, CTC-Kanal 1) neben BIOS-ISRs (CTC 2/3, Floppy-Index), und ob die BIOS-Uhr (`tim1it`) neben dem
   eigenen Zeitgeber laeuft.
3. **C3.2:** Stapel unter CB00 (§6), Zeitgeber/Tastatur des BIOS abschalten (`tim5of`, `tim1of`, §8), `mutos_io` darf `0001/0002` waehrend `diskio`/`READ` nicht benutzen.
4. SIO-Takt (§5) und `ccpload`-Wahl (2 spart 2 KB, aendert nichts am Plan).
