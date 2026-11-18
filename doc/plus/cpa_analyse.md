# CP/A-Analyse und Entscheidungsvorlage (Plan 48 C1.9)

Stand 2026-11-17, Branch `mutos-plus`.  Zusammenfuehrung von C1.1-C1.8 und Vorlage fuer die Entscheidungen E1-E9 (`doc/plan/48_mutos_io_cpa.md` §8).
**Entschieden 2026-11-17: alle Empfehlungen E1-E9 uebernommen** (Plan 48 §8 Ergebnis, Umsetzung §9).  Die Vorlagen unten bleiben als Begruendung stehen.  Jede Aussage ist *gemessen* (Befund/Lauf), *abgeleitet* (Quelle) oder
*Annahme*; die Verweise nennen Befunddatei und Abschnitt (`c1_4` = `doc/plus/cpa/c1_4_inventar.md` usw.).

Befunde zu den UDOS-Programmen (C1.2 `LOAD16`, C1.3 `IFSSPR`/`PIOPR`) stehen in `doc/mutos_io/udos_lader.md` §1/§2 (Pfad nach dem Merge; Zweig `plan48-udos`,
Merge nach `main` ausstehend).  Sie wurden direkt im Worktree `mutos8k-udos` gelesen, dort nichts veraendert; `udos_lader` = diese Datei, `udos_readme` = `mutos_io/udos/README.md`.

## 1. Kurzfassung der Befunde

**C1.1 Werkzeug** (`c1_1` §1-§3).  `tools/plus/cpa.py probe` laeuft in 9 s: `HALLO MUTOS`; `EM256ADR`/`EM16ABL` melden unter dem GIDE-CP/A wortgleich wie unter dem
normalen CP/A (*gemessen*) -- GIDE und RTC stoeren die EM256-Ansteuerung nicht.  M80/LINKMT unterscheiden Namen mindestens bis zum 7. Zeichen (*gemessen*), die
6-Zeichen-Grenze aus Plan 48 §6.5 trifft nicht zu.  Boot bis `A>`: 25,0 Mio. Takte, 1,7 s Wanduhr.

**C1.2 `LOAD16`** (`udos_lader` §1.3).  Genau ein UDOS-Einsprung (`CALL 1003H`, Dateidienst); EM-Init: A22 alle Seiten `0FH`, PIO A32 `EA CF FF B7 EF` / `EC CF 80 97 7F`, je Stueck
`OUT (A9H),38H`, Warten auf PIO-A-Bit 6, `LDIR`, `OUT (A9H),3CH` (*gemessen*).  Kernel nach EM-Segment 0 ab 0000H, 36 352 B, durch das Z80-Fenster **0000-3FFF**.
**`LOAD16` startet den U8001 nicht**: das tut `mutos_io` mit `OUT (0A9H),2CH` (9009); `mutos_io` braucht von `LOAD16` nur die Kerneldaten im EM und den U8001 im Reset (*gemessen*).

**C1.3 Drucker** (`udos_lader` §2).  `ACTIVATE` legt `IFSSPR` nur bei EB00 ab und ruft es einmal (Befehl 0 = install; *gemessen*); `IFSSPR` = SIO A32 Kanal B, Ports **5EH/5FH**,
7 Bit, ungerade Paritaet, 9600 Bd, Takt CTC 58H -- **dieselbe Hardware und Einstellung wie das BIOS-`LIST` auf LPT** (C1.5 §5).  Beide Treiber bytegleich rekonstruiert.
Der Emulator zeigt die Zeichen nur am Port (63 x `OUT (5EH)` fuer `cat /etc/motd > /dev/lp`), nicht an einem Drucker (*gemessen*; Merkposten im Emulatorprojekt).

**C1.4 Inventar** (`c1_4` §1, §5-§8).  198 Zeilen mit Adresszahlen: U 62, A 23, E 3, H 25, K 64, Kommentar 21.  Das ganze UDOS-Wissen steckt in 62 U-Zeilen (§3).
`0BFDH` (Platte) ist **asynchron** (Rueckkehr nach ~3200 Takten, erster Rueckruf ~1,19 Mio. Takte spaeter; *gemessen*).  Block -> (Zylinder, ID) als Formel gegen 540 gemessene
Nukleusaufrufe geprueft, 0 Abweichungen.  Im Betrieb bedient der UDOS-Nukleus nur CTC Kanal 3 (Plattenende), und das entfaellt mit BIOS-`READ`.

**C1.5 BIOS** (`c1_5` §1-§8).  Sprungleiste ab CB00 (2 Floppy), CP/A-Zusaetze ueber das Wort bei `004EH`.  Alle Platten-Einspruenge haben CP/M-2.2-Konvention;
Floppy-`SETSEC` 1-basiert, GIDE 0-basiert.  `WRITE` mit C=1 schreibt sofort.  `I = F7`, Tabelle F700; belegt nur F7D0-F7FF, F700-F7CF **frei**; CTC 0CH-0FH: Kanal 2/3 belegt,
**Kanal 0/1 frei**.  Das BIOS pollt die Tastatur 5CH/5DH in der 5-ms-ISR.  CONOUT schreibt direkt in den Bildschirmspeicher F800.., **keine Statuszeile**, nur die Uhr rechts oben.

**C1.6 Formate** (`c1_6` §1, §3-§6).  Alle drei Wurzeldisketten (FM, MFM, 8x512) und ein GIDE-Laufwerk lassen sich ueber die BIOS-Sprungleiste lesen und schreiben, alle Saetze
gleich dem Abbild (*gemessen*) -- aber nur mit der Satzregel in §4 unten (inverse CP/A-Skew-Tabelle ab Spur `OFF`; mit der naiven Regel `SETSEC = ID` stimmen 824 von 2002 Saetzen nicht).
`OFF` ist 2 oder 0 je Diskette (`bin_*`, `nroff_*`: 0) und muss nach jedem Login aus dem DPB gelesen werden.  Schreiben je Block `C = 0,0,0,1`.

**C1.7 Interrupts** (`c1_7` §2, §4).  CTC-0DH-ISR in Tabellenplatz `F7FAH` neben laufenden BIOS-ISRs: **keine Tickverluste** in Leerlauf, 400 `READ`, 2000 `CONOUT`, 200 `WRITE`;
groesste Verspaetung 0,68 ms; BIOS liest und schreibt mit Fremd-ISR richtig (Pruefsumme gleich, 200 Schreibsaetze genau am Ziel).  Tastatur ueber `CONST` im ISR: +0,9..2,5 % Laufzeit.

**C1.8 Vier Floppys** (`c1_8` §1-§5).  `@OS.COM` aus der Workbench-Kopie ohne Oberflaeche bytegleich zur Emulator-Diskette (Bauweg reproduzierbar); mit `anzdisk = 4`:
**BIOS-Anfang CA00**, BDOS BC06, TPA `100H-0BC05H`, Disketten A:-D:, **GIDE E: bis L:**, RTC D5H.  Die Anforderung des Projektinhabers (4 Floppy + GIDE + RTC) ist erfuellt (*gemessen*).

## 2. Speicherkarte U880 unter CP/A (Vorschlag fuer E3 (a), 4-Floppy-Variante)

*Abgeleitet* aus der Karte von `mutos_io` (`c1_4` §5) und der gemessenen CP/A-Lage (`c1_8` §4, `c1_5` §6); der Stapelort ist ein **Vorschlag, nicht gemessen**.

| Bereich | Inhalt | Beleg |
|---------|--------|-------|
| 0000-0007, 0038-003A, 0040-0055 | CP/A-Zellen: Warmstartsprung (`C3` bei 0000 muss stehen bleiben), IOBYTE 0003, BIOS-Uhr/Zaehler 0040-0055 | `c1_5` §6 |
| 0001/0002 | beim Floppytransfer kurz vom BIOS mit der Adresse des ZVE2-Programms beschrieben -- `mutos_io` darf sie nicht benutzen | `c1_5` §6 (abgeleitet) |
| 0100-3FFF | nur beim Start: Lader `M8KBOOT.COM`; danach frei (Kaltstartcode bei 0180 ebenfalls frei) | `c1_5` §6, `udos_lader` §1.4 |
| 4000-7FFF | EM-Fenster (A22/AFH); nichts Lebendes darin | `c1_4` §5, `udos_lader` §1.4 |
| 8000-8FFF | nur beim Start: Lesepuffer des Laders (4 KB, ausserhalb des Fensters) -- Vorschlag | Annahme |
| 9000-922C / 9400-A2AF / A400-A5A7 | Segmente 1-3 (Code, Tabellen, DCBs) | `c1_4` §5 |
| A5B6-B935 | Z80-Puffer (Konsole, tty1-3, Drucker, Platte A8B6 4 KB, Roh-Floppy B8B6) | `c1_4` §5 |
| **B936-C8B5** | unbenutzt (0F80H) -- **Vorschlag: Stapel, `SP` = C8B6** (waechst nach unten) | `c1_4` §5 (abgeleitet), Stapeltiefe im UDOS-Lauf nur wenige Byte (gemessen), Tiefe unter BIOS-`READ` + ISR + `CONST` Annahme |
| C8B6-C967 | Segment 4 (Ringe, `V_TAKT`, `V_BUSY`) | `c1_4` §5 |
| C968-C9FF | 98H = 152 Byte frei bis zum BIOS-Anfang (CA00) -- zu knapp fuer den Stapel | `c1_8` §5 |
| CA00-F648 | BIOS (4 Floppy; bei 2 Floppy ab CB00); wird weiter benutzt | `c1_8` §4 |
| F649-F6FF | frei | `c1_5` §6 |
| F700-F7CF | Interrupttabelle, **frei**: dort F730-F73E (SIO), F7EA/F7EC (PIO A32) | `c1_5` §3, §8 |
| F7D0-F7FF | BIOS-Vektoren; **F7FA = CTC 0DH** fuer `ISR_TAKT` (Basis F8 bleibt) | `c1_5` §3, `c1_7` §1 |
| F800-FFFF | Bildschirmspeicher K7024 | `c1_5` §4 |

BDOS (BC06..C9FF) und CCP (B500..) werden von `mutos_io` ueberschrieben; ein Rueckweg nach CP/A ist ohne Neuladen nicht moeglich (*abgeleitet*, `c1_4` §5).
Das BIOS-Ende haengt von der Bauvariante ab (`c1_5` Kopf): `M8KBOOT` muss den BIOS-Anfang aus dem Warmstartvektor `0001H` holen und mit Meldung abbrechen, wenn `mutos_io` hineinragt.

## 3. UDOS-Abhaengigkeiten von `mutos_io` und ihr Ersatz

Aus `c1_4` §3/§4 (alle 62 U-Zeilen); der Ersatz ist ein *Vorschlag* (Annahme), entschieden wird in C3/C4.

| UDOS-Bezug | Zeilen | Ersatz unter CP/A | Entscheidung |
|------------|-------:|-------------------|--------------|
| `CALL 0BEBH` Zeichenausgabe | 26 | BIOS `CONOUT` (C = Zeichen), aus der Hauptschleife; DE zusaetzlich retten | E6 |
| `CALL 0BF1H` Textausgabe, `0FF60H` Meldezeile | 9 + 1 | Schleife ueber `CONOUT` (nur Bedienmaske) | E6 |
| `CALL 0BE8H` Tastenabfrage | 1 | BIOS `CONST`/`CONIN` (Bedienmaske); Betrieb im 50-Hz-ISR | E6 |
| `CALL 0BFDH` Plattenauftrag (asynchron, Rueckruf je Satz) | 2 | synchrone Schleife `SELDSK/SETTRK/SETSEC/SETDMA/READ|WRITE` nach §4; `V_BUSY`/Rueckrufkette entfallen | E1 |
| `CALL 0EB00H` Druckertreiber | 1 | BIOS `LIST` (IOBYTE LPT), je Zeichen; `DRUCKER_FERTIG` entfaellt | E7 |
| `[0003H]` Lesen/Schreiben (Sektorlaenge) | 2 | **streichen**: 0003 ist in CP/A das IOBYTE; fuer den Drucker `0003H := 80H` setzen | E7 |
| Roh-Floppy 01B5H-01BCH, `OUT (1CH)` | 7 + 1 | Klasse 3 ersatzlos streichen (nie gelaufen; 01B5 ist UDOS-Nukleus) | -- |
| IM-2-Tabelle 0FE2/0FEA/0FEC, 0F30-0F3E (`I = 0FH` angenommen) | 11 + 2 Vektorbytes | `INTVEC + n` mit `I` aus dem BIOS (F7): CTC F7FA, PIO F7EA/F7EC, SIO F730-F73E | E2 |
| CTC-Vektorbasis E0H (UDOS) | -- | Basis F8H des BIOS bleibt, Kanal 1 = FAH | E2 |
| `RST 38H` (Fehlerhalt, 2 Stellen) | 2 | eigene Halteschleife (`RST 38H` fuehrt in CP/A zum Warmstart, BDOS ueberschrieben) | C3 |
| Stapel `LD SP,0CB68H` | 1 | Stapel in B936-C8B5 (§2); CB68 laege in der BIOS-Sprungleiste | E3 |
| Tastaturabfrage 5CH/5DH im Zeitgeber-ISR | 1 Routine | `CONST` im ISR (nicht eigenes Pollen) | E6 |

## 4. Plattenregel (gemessen, `c1_6` §4)

`bn` = Kernelblock, `k = 0..3`, `OFF` = DPB+13 nach `SELDSK` (E Bit 0 = 0), `d` = CP/A-Laufwerk.  **26 x 128 (FM wie MFM; 494 Bloecke, 0 Abweichungen):**
`l = 4*bn + k; q = l div 26; pos = l mod 26; v = 6*q mod 26; x = 2*pos (+1 wenn >= 26); ID = (x+v) mod 26 + 1; SETTRK = q+1;`
`SETSEC = ID` fuer Spuren unter `OFF`, sonst `INV[ID]` (Umkehrung der CP/A-Tabelle `biosdpb.mac:374`).
**8 x 512 (632 Bloecke):** `SETTRK = bn div 8 + 1; SETSEC = (bn mod 8)*4 + k + 1`.  **GIDE:** `L = 4*bn + k; SETTRK = L div 128 + Anfangsspur; SETSEC = L mod 128` (0-basiert).
Schreiben je Block `C = 0,0,0,1`.  Vorlage fuer C3.3: `versuche/plus_cpa/blktest.mac`.

## 5. Messwerte

| Messung | Wert | Quelle |
|---------|------|--------|
| Boot GIDE-CP/A bis `A>` | 24,6-25,0 Mio. Takte, 1,7-3 s Wanduhr | `c1_1` §1, Plan 48 §2.1 |
| Takte je 512 B, 26 x 128 (FM = MFM) | 198 602 (196 480..199 211) = 0,081 s | `c1_6` §5 |
| Takte je 512 B, 8 x 512 / GIDE | 147 561 / 28 190 | `c1_6` §5 |
| UDOS-Nukleus je Block (nicht gleichartig) | erster Sektor ~1,19 Mio., danach 30 000-45 000 je 128 B | `c1_4` §6 |
| Takte je 50-Hz-Tick (Leerlauf, 500 Ticks) | 49 249 (nominal 49 152) | `c1_7` §2 |
| Tickverluste bei READ / CONOUT / WRITE | 0 / 0 / 0; Luecken 49 230..49 277 | `c1_7` §2 |
| groesste Tick-Verspaetung (frueherer Lauf) | 0,68 ms bei 20 ms Periode | `c1_7` §2 |
| Mehrlaufzeit durch ISR mit `CONST` | READ +0,9 %, CONOUT +2,5 %, WRITE +1,1 % (~450 Takte/Tick) | `c1_7` §2 |
| Leerlauf 8 x 512 bei Fehlersektor | ~8,4 Mio. Takte je Spur Wiederholungen | `c1_6` §3 |
| Druck IFSSPR (UDOS) | ~2850 Takte je Zeichen | `udos_lader` §2.4 |
| `@OS.COM` 4 Floppy | 16 768 B, SHA-1 `97bbdca9...` (2 Floppy: 16 640 B) | `c1_8` §2 |

## 6. Vorlagen E1-E9

Die gleichen Vorlagen stehen kurz in Plan 48 §8.  Eine Spalte "gilt nur wenn" nennt die Bedingung, unter der die Empfehlung kippt.

### E1 Plattenweg
* **Optionen:** (a) Standard-Einspruenge `SELDSK/SETTRK/SETSEC/SETDMA/READ/WRITE`; (b) CP/A-Zusatz `diskio` (physisch, `004E`-Leiste, ohne Formaterkennung); (c) eigener FDC-Treiber in `mutos_io`.
* **Messwerte:** (a) alle gelesenen Saetze gleich (`root_fm`/`root_mfm` 2002/2002, `root_8x512` 2528/2528 + 26/26, GIDE 1280/1280), Bloecke nach Formel 494/494 bzw. 632/632; geschrieben gleich mit C=1 (`c1_6` §1, §6).
  198 602 Takte je 512 B (`c1_6` §5).  (b) nicht untersucht (`c1_6` §7).  (c) nicht untersucht; der Datentransfer laeuft ueber die zweite CPU ZVE2 (`c1_5` §6, abgeleitet) -- hoher Aufwand (Annahme).
* **Kosten (a):** `mutos_io` braucht die inverse Skew-Tabelle und `OFF` aus dem DPB (`OFF` 2 oder 0 je Diskette); nach Diskettenwechsel neu anmelden (`SELDSK` mit E Bit 0 = 0); Schreiben `C = 0,0,0,1`;
  Lesefehler bringt eine `R/W`-Meldung auf den Schirm und Wiederholungen (8,4 Mio. Takte je Spur).  Nicht gemessen: Zugriff auf einen einzelnen weit entfernten Block.
* **Empfehlung: (a).**  Die Bedingung aus Plan §8 (alle Saetze der Wurzeldisketten gleich) ist erfuellt; der Sonderfall "26 x 128 nicht lesbar" tritt nicht ein.  (b) nur, falls die Skew-Rechnung stoert -- das Ergebnis waere mit weniger Aufwand nicht besser.
* **Folge:** C3.3 wie §9, aber mit der Regel §4 (nicht `SETSEC = ID`); Wurzel-Umzug auf ein CP/A-Format **entfaellt**.

### E2 Interrupts
* **Optionen:** (a) Vektoren in die CP/A-Tabelle, BIOS-ISRs laufen weiter; (b) Maschine uebernehmen, eigene Tabelle, BIOS-ISRs aus.
* **Messwerte:** 0 Tickverluste in allen vier Phasen, Verspaetung <= 0,68 ms, BIOS liest/schreibt richtig (`c1_7` §2).  Frei: F700-F7CF, CTC-Kanal 0/1, EM-PIO (`c1_5` §8).  Kein Vektor belegt, den `mutos_io` braucht,
  wenn CTC auf F7FA (Basis F8 unveraendert), PIO A32 auf F7EA/F7EC (EA = `ivdsk2` nur FORMAT.COM, *abgeleitet*) und SIO auf F730-F73E gelegt wird (`c1_4` §8).
* **Nicht gemessen:** ein ISR mit der vollen Arbeit von `ISR_TAKT`/`ISR_ANFRAGE` (EM-Zugriffe, PIO A32); INT-16 vom U8001 neben BIOS-Floppytransfer; `CONOUT` aus einem ISR.
* **Empfehlung: (a).**  Bedingung des Plans (nicht mehr als 1 Tick verloren) mit grossem Abstand erfuellt.  Alle Tabellenadressen als `INTVEC + n`, `I` zur Laufzeit aus dem BIOS (`I` nie aendern).
* **Folge (b):** `mutos_io` muss ISRs des BIOS nachbilden, die `READ` braucht (Floppy-Index F7E8, 5-ms-Zeitgeber), Uhr steht -- nicht empfohlen.

### E3 Lage im Speicher
* **Optionen:** (a) `.PHASE 9000H` behalten, BDOS ueberschreiben, Stapel unter den BIOS-Anfang; (b) `.COM` ab 0100H; (c) andere feste Lage unter dem BIOS.
* **Messwerte:** BIOS-Anfang 2 Floppy CB00, **4 Floppy CA00** (`c1_8` §4); `mutos_io` laeuft bis C968, davon bis CA00 nur **152 Byte** (`c1_8` §5).  Der alte Stapel CB68 laege in der Sprungleiste (`c1_4` §9).
  B936-C8B5 (0F80H) sind unbenutzt (`c1_4` §5, abgeleitet).  UDOS-Stapeltiefe im Betrieb wenige Byte (`c1_4` §5, gemessen); BIOS-`READ` + ISR + `CONST` auf demselben Stapel nicht gemessen.
* **Empfehlung: (a) mit Stapel in B936-C8B5** (`SP` = C8B6).  Die Planbedingung "BIOS-Anfang >= C968 + Stapel" ist bei 4 Floppys **nur mit dieser Verlegung** erfuellt (152 B reichen nicht sicher); das kostet nichts, weil die Luecke ohnehin frei ist.
  `0001/0002` und `0003` nicht anfassen.  Der Lader prueft den BIOS-Anfang (Abbruch mit Meldung).  Der Stapelort ist *Annahme*, in C3 mit Marke/Grenzmessung bestaetigen.
* **Folge (b)/(c):** erst alle A-Zahlen durch Namen ersetzen (C3.1b), `.COM` hat nur 0100-3FFF fuer Code und Puffer (Fenster 4000H) -- knapp.

### E4 Lader
* **Optionen:** (a) ein `M8KBOOT.COM` laedt Kernel und `mutos_io`; (b) Lader nur fuer den Kernel, `mutos_io` als eigenes `.COM` (schiebt sich selbst nach 9000H).
* **Messwerte:** `LOAD16` = ein Dateidienst + EM-Init (A22, PIO A32, `OUT A9H 38H/3CH`, `LDIR`, 4-KB-Stuecke); schreibt in 0000-3FFF, **startet den U8001 nicht** (`udos_lader` §1.3 a-d);
  `mutos_io` braucht nur Kerneldaten im EM und U8001 im Reset (§1.3 e/f).  In CP/A beginnt die TPA bei 0100: die `LDIR`-Schleife darf nicht im Fenster liegen, Lesepuffer ausserhalb (8000H+).
* **Empfehlung: (a).**  Der Lader muss nichts an `mutos_io` uebergeben.  Das BDOS merkt sich `SELDSK` (`c1_6` §7): vor jedem BDOS-Zugriff den Zustand neu setzen.
* **Folge fuer C2.3:** Der Plan nahm an, `M8KBOOT K` lasse "den U8001 im Kerneltext laufen"; da `LOAD16` ihn nicht startet, muss der Lader in der Betriebsart `K` den Start (`OUT (A9H),2CH`) selbst ausfuehren.

### E5 Laufwerke
* **Optionen:** (a) 4-Floppy-CP/A-Variante (`anzdisk = 4`); (b) 2 Floppy + GIDE fuer `/tmp`/`/mnt`.
* **Messwerte:** (a) gebaut, bootet, Kopfzeile A:-D:, GIDE E:-L:, `DIR E:` liest die Platte, RTC D5H (`c1_8` §4); Bauweg bytegleich reproduzierbar (§2); Preis: BIOS +100H, TPA 0BC05H, Stapel-Luecke 152 B.
  Anforderung des Projektinhabers (4 Floppy + GIDE + RTC) damit erfuellt.
* **Empfehlung: (a).**  (b) verlangt MUTOS-Dateisystem auf GIDE im DiskTool (Emulatorprojekt) und aendert alle Gastlauf-Werkzeuge -- nicht vor Plan 51.  Alle Gastlaeufe von Plan 47 nutzen vier Floppys.
* **Offen:** ohne `--laufwerke K5601,...` wurde die 4-Floppy-Diskette nicht gestartet (`c1_8` §4); ob der Schalter noetig ist, ist *Annahme*.

### E6 Konsole und Tastatur
* **Optionen:** (a) Ausgabe BIOS `CONOUT`, Tastatur selbst im Zeitgeber-ISR (Plan); (b) beides ueber BIOS, Abfrage `CONST` in der **Hauptschleife**; (c) beides selbst (K7024 direkt);
  **(d, neu aus C1.7)** Ausgabe BIOS `CONOUT` aus der Hauptschleife, Tastatur ueber `CONST`/`CONIN` **im 50-Hz-ISR**.
* **Messwerte:** das BIOS pollt 5CH/5DH selbst in der 5-ms-ISR und waehrend `READ`/`WRITE` weiter; zwei Leser stehlen sich Zeichen (`c1_5` §4, abgeleitet).  Variante (d) gemessen: vier Tasten `wxyz` kamen alle im ISR an,
  Kosten +0,9..2,5 % Laufzeit, funktioniert waehrend `READ`/`WRITE`/`CONOUT` (`c1_7` §2).  Fuer (a) muesste `tim5of` den BIOS-Takt abschalten; dann steht (abgeleitet) die 1-s-Uhr (`c1_7` §4).
  CONOUT schreibt direkt in den Bildschirmspeicher; **keine Statuszeile** (`cpastz=0`), die Uhr rechts oben scrollt weg (`c1_5` §4, `c1_7` §2).
* **Nicht gemessen:** lange Tastenfolgen/Wiederholung waehrend Plattenzugriff, `CONOUT` aus dem ISR (`intcrt`), ob die BIOS-Tastencodes (Umlaute, Steuercodes) fuer `getty`/Anmeldung reichen (Annahme), Steuerzeichen von `CONOUT` im Einzelnen (`c1_5` §4).
* **Empfehlung: (d)** statt des Plan-Vorschlags (a).  (a) ist nach C1.7 schlechter (Uhr steht oder Zeichen gehen verloren), (b) kippt auf (d), weil `CONST` im ISR billig und waehrend `READ` nutzbar ist; (c) verliert die BIOS-Konsole.
* **Folge:** `ISR_TAKT` ruft `CONST`/`CONIN` (nicht `TASTE_LESEN`/5CH); `TAB_TASTE` und Rohcodes entfallen, Bedienmaske braucht keine eigene Abfrage.

### E7 Drucker und tty1
* **Optionen:** (a) BIOS `LIST` mit IOBYTE = LPT (`0003H := 80H`); (b) Treiberkern aus `IFSSPR` in `mutos_io`; (c) Drucker zunaechst weglassen.
* **Messwerte:** BIOS-LPT = Ports 5EH/5FH, 7 Bit, ungerade Paritaet, 9600 Bd, DC1/DC3, Takt CTC 58H -- gleich `IFSSPR` (`c1_5` §5, `udos_lader` §2.4); der Emulator zeigt die Zeichen nur am Port, **nicht** an einem Drucker
  (`udos_lader` §2.4, Merkposten).  **`LIST` selbst ist ungemessen** (C1.3 Vorbehalte 1-3).  `IFSSPR` sendet ein NUL nach CR und expandiert TAB (`udos_lader` §2.3); beides muesste dann `mutos_io`/Kernel leisten (offen).
  `LIST` blockiert die Hauptschleife ~2850 Takte je Zeichen (Wert von `IFSSPR`, Annahme gleich).  Stopbits der BIOS-LPT-Programmierung gegen `IFSSPR` (WR4 4DH = 2 Stopp) nicht verglichen.
  tty1 (SIO A 50H) bleibt eigener Treiber; das BIOS beruehrt SIO A nur bei `LIST`-TTY/UC1 (`c1_5` §5); Taktquellen CTC 0CH (BIOS) gegen 5AH (`mutos_io`) offen.
* **Empfehlung: (a), vorlaeufig.**  Die Planbedingung "IFSS-Weg im Emulator gleich angekommen" ist am Port, nicht am Drucker nachpruefbar.  Pruefung in C4.1 mit Portprotokoll plus TAB-Text.  Fallback (b) bleibt.
* **Folge:** Zeilen 277/280 (`[0003H]`) streichen und `0003H := 80H` setzen; `LST:` darf nicht TTY (50H) bleiben.

### E8 Startmedium
* **Optionen:** (a) CP/A-Bootdiskette in A:, nach dem Laden Wechsel in der Bedienmaske; (b) Start von GIDE.
* **Messwerte:** Boot von A: gemessen (§5); das BIOS erkennt das Format nur bei `SELDSK` mit E Bit 0 = 0, nach einem Wechsel also neu anmelden (`c1_6` §7).  GIDE bei 4 Floppys heisst **E:** (nicht C:) (`c1_8` §4); Lade-ROM UL4 bootet auch von der Platte (Plan 48 §2).
* **Empfehlung: (a)** wie heute mit UDOS.  (b) gehoert zu Plan 51 P6.
* **Folge:** Gastlauf-Werkzeug (C5.1) `eject A`/`mount A` nach der Bedienmaske; im Plan genannte "GIDE C:" in Plan 51 auf E: berichtigen.

### E9 Ablage der CP/A-Variante
* **Optionen:** (a) Konfiguration in diesem Repo (`mutos_io/cpa/system/`), Bau ueber frische Workbench-Kopie; (b) eigene Variante in der Workbench.
* **Messwerte:** Bau ohne Oberflaeche ~10 s, `@OS.COM` reproduzierbar, Workbench unberuehrt (`c1_8` §2, §6, §7); Stand `0045dc6`, SHA-1 der 4-Floppy-`@OS.COM` `97bbdca995953cc928e5b09cc0d3ae32d9a2ef45`.
* **Empfehlung: (a)**; **entschieden bereits mit O3 am 2026-11-17** (Plan 48 §11), diese Vorlage nur zur Bestaetigung.  (b) hinge C5 an einen fremden Stand.

## 7. Abweichungen vom Plan

Was C1 anders ergab als die Annahmen in Plan 48 §2/§3/§7 (jeweils mit Beleg):

1. **Satzregel (§3.1, C1.4 §7 "SETSEC = ID, ohne SECTRAN"):** falsch.  Das BIOS uebersetzt `SETSEC` in `READ`/`WRITE` selbst ueber die CP/A-Skew-Tabelle ab Spur `OFF`;
   `mutos_io` muss sie umkehren (`c1_6` §3, §4; naive Regel: 824 von 2002 Saetzen falsch).  `OFF` ist je Diskette 2 oder 0 und nicht festschreibbar.
2. **Befuerchtung "77 Spuren/FM nicht lesbar" (Plan §5, `c1_5` §2.2 offen):** tritt nicht ein; die Formaterkennung liefert fuer FM und MFM SPT 26/OFF 2 (`c1_6` §3.1).
   `root_8x512` wird als 9 x 512 erkannt (Zylinder 0 als 26 x 128), die Blockformel greift nie auf Sektor 9 (`c1_6` §3.2).
3. **Schreiben (§3.1 "wann geht ein Satz auf die Diskette"):** Regel `C = 0,0,0,1` je Block; ein einzelner zurueckgestellter Satz bleibt ohne Warmstart aus (`c1_6` §6).
4. **Tastatur (§3.8 Empfehlung (a)):** durch (d) ersetzt -- `CONST` im 50-Hz-ISR statt eigenem Pollen (`c1_7` §4); die Annahme "BIOS-Routinen nicht aus einem ISR" war fuer `CONST` unnoetig vorsichtig (laeuft, gemessen).
5. **"Statuszeile mit Uhr bleibt" (§3.8):** es gibt keine Statuszeile (`cpastz=0`), nur die Uhr rechts oben, die beim Scrollen wegfaellt (`c1_5` §4, `c1_7` §2).
6. **Stapel (§3.3, §9 C3.2 "Stapel unter den BIOS-Anfang"):** bei 4 Floppys bleiben nur 152 Byte bis CA00; der Stapel muss nach B936-C8B5 (`c1_8` §5, §2 oben).  Zusaetzlich: `[0003H]` ist das IOBYTE, nicht ein Nukleusdatum (`c1_4` §9).
7. **Lader (§3.4, C2.3 "Kernel laeuft an" nur mit Lader):** `LOAD16` startet den U8001 nicht, der Start steckt in `mutos_io` (9009); `M8KBOOT K` muss ihn selbst starten (`udos_lader` §1.3 d).
   Das Fenster ist bei `LOAD16` 0000-3FFF (nicht 4000-7FFF), unter CP/A nicht uebertragbar (TPA ab 0100, `udos_lader` §1.4).  `ACTIVATE` war nicht zu rekonstruieren noetig (legt nur ab, `udos_lader` §2.2).
8. **GIDE-Laufwerksbuchstaben (§3.10, Plan 51):** bei vier Floppys **E: bis L:**, nicht C: bis J: (`c1_8` §4); die fertige Emulator-Diskette hat 2 Floppy (C:-J:).
9. **M80-Namenslaenge (§6.5):** mindestens 7 Zeichen unterschieden, 6-Zeichen-Regel unnoetig (`c1_1` §2).
10. **Inventar (§2 Zeile 35):** die Zahlen `996EH`, `922CH`, `C967H` stehen nur in Kommentaren; die Quelle ist schon weitgehend symbolisch, echte A-Zahlen nur in 23 Zeilen (`c1_4` §1).
11. **Drucker (§3.9 Konflikt "LST: TTY = 50H"):** entsteht nur bei IOBYTE-Vorgabe 00H; mit LPT (80H) bleibt SIO A frei (`udos_lader` §2.6, `c1_5` §5).  Im Emulator ist aber nur der Port, nicht ein Drucker sichtbar.
12. **BDOS merkt sich `SELDSK`:** ein Programm mit eigenem `SELDSK` und BDOS-Dateizugriff auf ein anderes Laufwerk bekommt `Bad Sector` (`c1_6` §7) -- fuer den Lader relevant, im Plan nicht vorgesehen.
13. **Emulator-Merkposten (O5):** `a5120emu/doc/merkposten/itrace_luecken.md` (`itrace` verzeichnet nicht jede Unterbrechung; Tasten zeitlich verteilt einspeisen) und `a5120_drucker_pio_a31_und_dbg_seriell.md`
    (kein Drucker/Seriell-Hub im `k1520dbg`); beide uncommittet im Emulatorprojekt.
14. **Gleichzeitige Leser an 5CH (C1.5 §4):** auch ohne `mutos_io`-Pollen sammelt das BIOS in seinem Puffer (`c1_7` §2: `KBD: wxyz`); fuer (d) bedeutet das, dass `mutos_io` vor dem Start den BIOS-Tastaturpuffer leert (Annahme).

## 8. Offene Punkte (nicht gemessen)

Vollstaendiger `ISR_TAKT`/`ISR_ANFRAGE` neben BIOS-`READ`; Stapeltiefe unter `READ`+ISR; Einzelblockzugriff weit entfernt (Spursuche); `LIST`/TAB/NUL in der Praxis; `CONOUT` aus dem ISR;
lange Tastenfolgen; SIO-A-Takt (CTC 0CH gegen 5AH); `diskio` als Alternative; BIOS-Adressen bei anderer Bauvariante (nur ueber `0001H`/`004EH` zu holen).
