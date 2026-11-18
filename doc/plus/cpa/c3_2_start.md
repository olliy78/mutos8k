# C3.2 `mutoscpa`: Start, Lage, Interrupts, Konsolausgabe, Bedienmaske (Plan 48)

**Stand: erledigt** (Abnahme erreicht), 2026-11-18.  Arbeitsordner `/tmp/mplus/c3_2/`.  Kennzeichnung: *gemessen* (Lauf genannt), *abgeleitet*, *Annahme*.
Quelle `mutos_io/cpa/src/mutoscpa.mac`, Bauergebnis `mutos_io/cpa/mutoscpa.bin` (**4608 B**, vorher 5376 B), Waechter `tests/test_plus_cpa_io.py`
(schnell: keine UDOS-Abhaengigkeit mehr; `gast`: Gesamtlauf und Fehlerweg), Debuggerskripte `versuche/dbg/cpa_c3_2_start.dbg`, `cpa_c3_2_fatal.dbg`.
Ab diesem Schritt ist `mutoscpa.bin` **absichtlich nicht mehr bytegleich** zu `mutos_io/mutosio.bin`; der Waechter `build.py --check` vergleicht (wie immer) gegen das
eingecheckte `mutoscpa.bin`, `tests/test_plus_cpa_quelle.py` ist darauf umgestellt (kein Vergleich mehr mit `mutosio.bin`; der Vergleich Quelle == `mutosio.bin` bleibt bei der UDOS-Quelle:
`tests/test_waechter.py`, `mutos_io/build.py --check`).

## 1. Erste Sonde (Maske ueber `CONOUT`, Stapeltiefe)

Boot ueber `cpa_disk.bootdiskette` (4 Floppy), `M8KBOOT`, Haltepunkt auf der ersten Anweisung nach `CALL MASKE` (`CALL INIT`):
* *Gemessen:* die Bedienmaske erscheint ueber BIOS `CONOUT` (Striche, `remove mutos8000 boot - disk`, `insert ... rk2`, `floppy - drive......:   0   1   2   3`, `mutos  - rk.........:   0   1   2   3`,
  `change / ready (r)..:`); `r` am ersten Eingabefeld wird angenommen (Haltepunkt getroffen, `I=F7 IM=2`, `SP=C8B6`).  Zeilenwechsel: `LF` allein der Maske wurde durch `NEWLINE` (CR LF) ersetzt,
  damit der Text unabhaengig von der BIOS-Auslegung von `LF` in Spalte 0 beginnt.
* **Stapeltiefe (gemessen, Stapelbereich B936H..C8B5H vom Start mit E5H gefuellt):** nach der Maske (Haltepunkt) ist die tiefste benutzte Adresse **C890H** (38 Byte unter `SP` = C8B6H);
  nach dem Kernelstart und 120 Mio. Takten (Kernelmeldungen, 146 `ISR_ANFRAGE`, rund 2440 `ISR_TAKT`, Konsolausgabe) **C888H = 46 Byte**.  Der Stapel hat damit 3922 von 3968 Byte frei.
  *Nicht gemessen:* Tiefe unter BIOS-`READ`/`WRITE` (C3.3), langer Tastatur-/Druckerbetrieb (C3.4/C4.1), Messung unter Last in C4.2.

## 2. Aenderungen an `mutoscpa.mac` (Fundstelle der Vorlage: `c1_4` §3/§4)

| Nr. | vorher (UDOS) | nachher (CP/A) | Fundstelle |
|-----|---------------|----------------|------------|
| 1 | `LD SP,0CB68H` (Stapel in der BIOS-Sprungleiste) | `DI`, `LD SP,INITSP` (`INITSP EQU SEG4_BASE` = C8B6H), Stapelbereich `STKBOT` = B936H bis `INITSP`-1 mit **E5H** fuellen (`LDIR`, bleibt eingebaut), `CALL BIOS_LINK`, `CALL CHECK_I`, `CALL KBD_FLUSH`, `EI` | c1_4 §3 (Zeile 53), §5, §9 Punkt 2; c1_5 §6 |
| 2 | UDOS-Einsprung fest | `BIOS_LINK`: `WBOOT` = `(0001H)` **einmal** lesen (`L` muss 03H sein, sonst `FEHLERHALT 'W'`), Sprungleiste `B_CONST`, `B_CONIN`, `B_CONOUT`, `B_LIST`, `B_HOME`, `B_SELDSK`, `B_SETTRK`, `B_SETSEC`, `B_SETDMA`, `B_READ`, `B_WRITE` = `JP WBOOT+Versatz` (Versaetze 03 06 09 0C 15 18 1B 1E 21 24 27, Plan §9.0); vor dem Verlinken zeigen alle Plaetze auf `STOP` | Plan §9.0; c1_5 §1, §6 |
| 3 | BIOS-Tastaturpuffer unbekannt | `KBD_FLUSH`: `CONST`/`CONIN`-Schleife bis leer | Plan C3.2 Punkt 1 |
| 4 | `CALL 0BEBH` (26 Stellen) | `PUTC`: `AF BC DE HL IX IY` retten, `LD C,A`, `CALL B_CONOUT`; in `KONSOLE_AUS` und der Maske; `LD A,0AH / CALL 0BEBH` der Maske -> `NEWLINE` (CR LF) | c1_4 §3 (U), c1_5 §4 |
| 5 | `CALL 0BF1H` (9 Stellen, Laengenbyte + Text) | `PUTS` ueber `PUTC` | c1_4 §3 |
| 6 | `CALL 0BE8H` (Taste, Z = keine) | `GETC`: `CONST`; ist eine Taste da `CONIN`, Rueckgabe Z = keine, sonst A (Code 00H zaehlt als "keine"); retten `BC DE HL IX IY` | c1_4 §3, c1_5 §1 |
| 7 | Meldezeile `0FF60H` (30 Byte nach `LDIR`) | `MELDUNG_AUSGEBEN`: `NEWLINE`, 30 Zeichen ueber `PUTC`, dann unveraendert `SIGNALTON` (`OUT (5CH)`) | c1_4 §3 |
| 8 | Tabellenplaetze `0FEAH`/`0FECH`/`0FE2H`/`0F30H..0F3EH` (`I` = 0FH angenommen) | `INTVEC EQU 0F700H`: PIO A -> `INTVEC+0EAH`, PIO B -> `+0ECH`, CTC Kanal 1 -> `+0FAH` (CTC-Basis F8H bleibt), SIO -> `+30H..+3EH` | c1_4 §4, §8; c1_5 §3, §8; c1_7 §4 |
| 9 | `I` ungeprueft | `CHECK_I`: `LD A,I`, Vergleich mit F7H, sonst `FEHLERHALT 'I'` (steht im Start **vor** der Maske, nicht erst in `INIT`: die Maske laeuft schon unter den BIOS-Interrupts) | Plan C3.2 Punkt 3 |
| 10 | `NUKLEUS_INIT`: `OR 01H` auf `[0003H]` (IOBYTE!), K8X512-Zweig `LD (0003H),A` | nur noch `V_BUSY := 0` | c1_4 §9 Punkt 1 |
| 11 | `RST 38H` in `ISR_ANFRAGE` (`IA_BELEGT`) und `BLOCK_START` | `FEHLERHALT` mit Code `'B'` bzw. `'L'`: `DI`, `NEWLINE`, `mutoscpa: fatal error <Code>` ueber `PUTS`/`PUTC`, `HALT`-Schleife (`STOP`) | c1_4 §4 |
| 12 | Klasse 3 `ROH`, `KMD_*`, `TAB_KMD`, `TAB_FEHLER` (UDOS-Block 01B5H, `OUT (1CH)`) | `ROH` = Stummel: Status C1H (wie "Befehl unbekannt" des Originals), Zaehlung 0, `ENDE_WIEDER` | c1_4 §4, §9 Punkt 3 |
| 13 | `PLATTE` (Nukleus-Auftrag, `BLOCK_START`, `0BFDH`) | `PLATTE` = Stummel: Status C0H (Bit 6 gesetzt, wie ein Nukleusfehler ueber `BR_ABBRUCH`), Zaehlung 0 (`MELDEN` kopiert keine Daten), `ENDE_WIEDER`.  `PLATTE_FERTIG`, `BLOCK_START`, `BLOCK_RUECKRUF` bleiben unbenutzt stehen (C3.3 ersetzt sie; `0BFDH` kommt dort noch vor) | Plan C3.2 Punkt 4 |
| 14 | `DRUCKER` (`CALL 0EB00H`) | Stummel: Status FFH, `ENDE_WIEDER`; `DRUCKER_FERTIG` unbenutzt bis C4.1 (`0EB00H` bleibt dort) | Plan C3.2 Punkt 4 |
| 15 | `ISR_TAKT` ruft `TASTE_LESEN` | Aufruf samt Warteschlangen-/Klassenmeldung entfernt, `ISR_TAKT` zaehlt nur noch `V_TAKT` und meldet (ACH, Vektor 02H); `TASTE_LESEN` und `TAB_TASTE` stehen unbenutzt (C3.4 loescht sie) | c1_4 §8 Konflikt 4; c1_7 §4 |

Layout: Segmentgrenzen `.PHASE` unveraendert (9000H, 9400H, A400H, C8B6H); Segment 1 endet bei 91A1H (vorher 922DH), Segment 2 bei A073H (vorher A2B0H, Grenze A400H), Segment 3 und 4 unveraendert
(`V_NACHR` A5A8H und die Puffer A5B6H.. bleiben).  `abbild` bleibt 14 696 B (9000H..C967H).  Neue Namen Englisch, hoechstens 8 Zeichen, in den ersten 6 Zeichen eindeutig
(Beleg: der Bau mit M80 meldet keinen Fehler; `BL_SCHL` kollidierte mit einer bestehenden Marke und wurde `LK_SCHL`).

## 3. Abnahme (alle *gemessen*, `MPLUS_ARBEIT=/tmp/mplus/c3_2/g1 python3 -m pytest -q tests/test_plus_cpa_io.py`)

Boot ueber `cpa_disk.bootdiskette` (4-Floppy-Diskette, Original-Kernel `mutos_1216`, `--em em256`, `--laufwerke K5601 x4`), 76 s Wanduhr fuer beide Gastlaeufe samt Workbench-Bau
(`6 passed`, `tests/test_plus_cpa_io.py`):
* `M8KBOOT` -> Maske auf dem Schirm -> `r` -> Haltepunkt nach `CALL MASKE` getroffen -> Kernel laeuft.  Bildschirm danach: `mem = 196608` (die erste Kernelmeldung des UDOS-Boots,
  `doc/system/befund.md`), dann viermal `err on dev 4/2` / `bn=1 er=0,300` (Status C0H oktal 300 = unser Stummel; rk2 ist die Wurzel) und `panic: iinit` -- der erwartete Plattenfehler.
* Vektorplaetze (Dump `F7E8..F7FF`): `F7EA` = `ISR_ANFRAGE` (94ADH), `F7EC` = `ISR_PARITAET` (94A0H), `F7FA` = `ISR_TAKT` (947EH); die BIOS-Vektoren `F7E8` (Floppy-Index), `F7FC`, `F7FE` unveraendert belegt.
* `ISR_TAKT` (Logpunkt): **2441 Eintraege in 120,2 Mio. Takten**, mittlere Luecke **49 249 Takte** (c1_7 §2: 49 249), kleinste 47 978, groesste 51 467 (+-3 %, in c1_7 §2 +-0,1 %, dort ohne Kernelbetrieb;
  *nicht untersucht*, vermutlich Anteil der BIOS-5-ms-ISR und der `CONOUT`-Ausgabe der Kernelmeldungen; kein ausgefallener Tick, Luecke < 1,05 Perioden).
* `ISR_ANFRAGE`: **146 Eintraege** (>= 1), erster bei 1,44 Mio. Takten nach dem Halt hinter der Maske.
* BIOS-Uhr (`0050H..0052H`, BCD): vor dem Kernelstart `01:22:15`, 120,2 Mio. Takte (48,9 s) spaeter `01:23:04` -- laeuft weiter.
* Stapel: tiefste benutzte Adresse **C888H** (46 Byte), der Bereich B936H.. unberuehrt (E5H).
* Fehlerweg (`cpa_c3_2_fatal.dbg`, Register `I` am Haltepunkt 9000H auf 00H gesetzt): Bildschirm `mutoscpa: fatal error I.` (der Punkt ist das Cursorzeichen), danach `DI`/`HALT`.
* `python3 -I mutos_io/cpa/build.py --check` -> 0 (`mutoscpa.bin` 4608 B == Bau der Quelle); `abbild` 14 696 B, Segmentgrenzen ohne Ueberlappung (`tests/test_plus_cpa_quelle.py`, `gast`).
* Schnelltests: neuer Test "keine UDOS-Abhaengigkeit mehr" ist gegen den Stand C3.1 rot (60 Zeilen) und gegen den neuen Stand gruen (*gemessen* mit der Vorversion der Quelle).

## 4. Auffaelligkeiten und Grenzen

* `FEHLERHALT` aus `ISR_ANFRAGE` (`'B'`) schreibt ueber `CONOUT` aus einem Interrupt: das BIOS sperrt waehrenddessen Zugriffe der 1-s-Uhr mit `intcrt`; war die Hauptschleife gerade in `CONOUT`,
  koennte die Meldung die Bildschirmpflege stoeren.  Der Fall trat im UDOS-Lauf nie auf (analyse.md §9); wegen `DI`/`HALT` danach unkritisch (*abgeleitet*, nicht erprobt).
* Die BIOS-Uhr `HH:MM:SS` in der Bildschirmecke wird von den Zeilenvorschuben der Maske und der Kernelmeldungen mitgescrollt und vom BIOS jede Sekunde neu gesetzt (c1_7 §2); stoert nicht.
* Tasten erreichen den Kernel noch nicht: `ISR_TAKT` pollt nicht mehr, die Tastatur kommt in C3.4.  Die Maske nimmt Tasten ueber `GETC` (BIOS `CONST`/`CONIN`) an.
* Die K8X512-Zweige (`IF K8X512`) in `BLOCK_*`/`SEKTOR_*` bleiben bis C3.3 unveraendert; fuer `K8X512 = 1` wird die CP/A-Fassung nicht mehr gebaut (der Plattenweg wird in C3.3 neu geschrieben).
* Merkposten fuer den Emulator (O5): keine neuen noetig.
