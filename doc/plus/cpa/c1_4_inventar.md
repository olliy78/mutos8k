# C1.4 Inventar von `mutosio.mac` fuer den Umzug nach CP/A (Plan 48)

Stand 2026-11-17.  Quelle: `mutos_io/src/mutosio.mac` (2032 Zeilen, bytegleich zum Original), `doc/mutos_io/analyse.md`, Plan 48 §2/§2.1/§7 C1.4.
Kennzeichnung: **gemessen** = im Debuggerlauf beobachtet (Arbeitsordner `/tmp/mplus/c1_4/`, Ladediskette `a5120_mutos8000_boot_udos_k5601.hfe` als COW-Kopie,
Wurzel `..._root_mfm.hfe`, `--em em256 --laufwerke K5601,K5601,K5601`, Skripte `sonde.dbg`/`sonde2.dbg`/`sonde3.dbg`); **abgeleitet** = aus Quelle gelesen (Datei:Zeile);
**Annahme** = nicht geprueft.  CP/A-Quellen: `~/projects/CPA_Workbench/src/gide_a5120/` (nur gelesen).  Kein Gastlauf mit CP/A in diesem Schritt.

## 1. Ergebnis

* Beide Suchmuster aus Plan 48 §7 sind vollstaendig klassifiziert (Abschnitt 3): Muster 1 `\b0?[0-9A-F]{3,4}H\b` trifft **198 Zeilen**, Muster 2
  `CALL\s+0[0-9A-F]+H|JP\s+0[0-9A-F]+H` trifft 40 Zeilen (39 Code, 1 Kommentar), alle schon in Muster 1 enthalten.
* Haupt-Klasse je Zeile (Vorrang U > A > E > H > K): **U 62**, **A 23**, **E 3**, **H 25**, **K 64**, Kommentarzeilen (Zahl nur im Text) **21**; Summe 198.
  Je Zahl gezaehlt: U 62, A 32, E 3, H 25, K 241.  Dazu **Zusatzfunde ohne Treffer der Muster** (Abschnitt 4): zweistellige Ports, `RST 38H`, die Annahme `IM 2`/`I = 0FH`, die CTC-Vektorbasis.
* **Die Quelle ist schon weitgehend symbolisch**: alle Spruenge/Aufrufe/Datenzugriffe im eigenen Programm laufen ueber Namen.  Echte A-Zahlen im Code sind nur `0A5A8H`/`0A5A9H`
  (Nachrichtenkopie, 5 Zeilen), `0CB68H` (Stapel) und die Pufferzeiger als Bytepaare in den DCB-/AUF-Tabellen (13 Zeilen) sowie die vier `.PHASE`-Basen.  Die in Plan 48 §2 genannten
  `996EH`, `922CH`, `C967H` stehen **nur in Kommentaren**.
* **Das ganze UDOS-Wissen steckt in 62 Zeilen**: `CALL 0BEBH` (26), `0BF1H` (9), `0BE8H` (1), `0BFDH` (2), `0EB00H` (1), `[0003H]` (2), Roh-Floppy-Kommandoblock `01B5H..01BAH` (7),
  UDOS-Vektortabelle (11 Zeilen + 2 Vektorbytes), Meldezeile `0FF60H` (1).  Dazu die Annahmen `IM 2`/`I = 0FH`, CTC-Basis `E0H` und `RST 38H`.
* Die vier Fragen (Abschnitte 5-8) in einem Satz:
  (1) CP/A (2 Floppy) liegt BDOS ab BD06H und BIOS ab CB00H genau dort, wo `mutos_io` seine Ringe (C8B6..C967) und den Stapel (CB68) hat; Verlagerung um -8F00H passt (0100H..2A67H) und bleibt unter dem EM-Fenster 4000H.
  (2) `0BFDH` ist **asynchron** (gemessen: Rueckkehr nach ~3200 Takten, erster Rueckruf ~1,19 Mio. Takte spaeter); die Hauptschleife laeuft waehrenddessen weiter, mit BIOS-`READ` blockiert sie je Sektor.
  (3) Block -> (Zylinder, Sektor) ist als geschlossene Formel angegeben und **gegen 540 gemessene Nukleusaufrufe** bestaetigt.
  (4) `mutos_io` braucht CTC Kanal 1, PIO A32 (A/B) und SIO A/B; vom Nukleus laeuft im Betrieb nur CTC Kanal 3 (Plattenende) -- in CP/A kollidieren der CTC-Vektor (Basis F8H statt E0H) und die Tastaturabfrage.

## 2. Suchbefehle und Methode

```
rg -n '\b0?[0-9A-F]{3,4}H\b' mutos_io/src/mutosio.mac | wc -l                    # 198
rg -n 'CALL\s+0[0-9A-F]+H|JP\s+0[0-9A-F]+H' mutos_io/src/mutosio.mac              # 40 Zeilen
rg -n -i '\bIM\b|LD\s+I,|\bRST\b|HALT|\bRETN\b' mutos_io/src/mutosio.mac           # RST 38H (517, 836), kein IM/LD I,A
rg -o '(IN|OUT) (A,)?\(([0-9A-F]+H|C)\)(,A)?' mutos_io/src/mutosio.mac | sort | uniq -c   # Portliste
```
Die Tabelle in Abschnitt 3 ist aus Muster 1 erzeugt (Skripte `/tmp/mplus/c1_4/inv.py`, `gen.py`, nicht eingecheckt: einmalige Auswertung); Klasse je Zahl nach den Regeln aus Plan 48 §7:
**U** UDOS-Dienst/-Datum, **H** Hardwareport, **E** EM-/Z8000-Adresse, **A** interne Adresse als Zahl, **K** Konstante; **Kom** = Zahl steht nur im Kommentar.
Zeilen mit mehreren Klassen stehen mit allen (z. B. `U/K`).  Die Spalte *CP/A-Ersatz* ist ein **Vorschlag** (Annahme), entschieden wird in C2/C3.

## 3. Fundtabelle (alle 198 Zeilen)

| Zeile | Quelltext | Wert | Kl. | Bedeutung | CP/A-Ersatz |
|------:|-----------|------|-----|-----------|-------------|
| 8 | `SEKLEN EQU 0200H` | 0200H | K | SEKLEN 512 B (Variante K8X512) | bleibt |
| 11 | `SEKLEN EQU 0080H` | 0080H | K | SEKLEN 128 B (Nukleus-Sektor) | bleibt |
| 19 | `DB 0FFH` | 0FFH | K | FILLFF-Makro (Fuellbyte) | bleibt |
| 24 | `; ---- Segment 9000H .. 922CH ----` | 9000H, 922CH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 25 | `.PHASE 9000H` | 9000H | A | Segmentbasis `.PHASE` (UDOS-Programm besteht aus vier Segmenten mit fester Ladeadresse, im `.fileinfo` der Ladediskette) | bei Verlagerung nur Basis in `.PHASE` und Fuellrechnung; Segmente nicht mehr in UDOS-Dateikopf, sondern vom CP/A-Lader (C2) laden |
| 36 | `; EM-Offset 4006H, und setzt A33 Bit 4 (INT-16` | 4006H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 40 | `; 4. Der Handler fuehrt den Auftrag aus (Platt` | 0BFDH, 0BEBH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 53 | `LD SP,0CB68H` | 0CB68H | A | Anfangsstapel CB68H = Ende des UDOS-Programmspeichers (Vorgabe `mem=` der Ladediskette) | CB68H liegt in CP/A (2-Floppy, gemessen) 68H Byte **im** BIOS (CB00H..); neu: unterhalb BIOS-Anfang (Abschnitt 5) |
| 57 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 100 | `IN A,(0A8H)` | 0A8H | H | PIO A32 lesen: Bit 0-2 Ebene des Z8000, Bit 3 /VI, Bit 6 Bus erhalten | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 119 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 125 | `LD BC,0003H` | 0003H | K | Offset +3 (Status) in der Nachricht | bleibt |
| 133 | `LD BC,0005H` | 0005H | K | Offset +5 (Zaehlung) in der Nachricht | bleibt |
| 141 | `OUT (0ADH),A` | 0ADH | H | Vektor -> VI an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 145 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 159 | `IN A,(0A8H)` | 0A8H | H | PIO A32 lesen: Bit 0-2 Ebene des Z8000, Bit 3 /VI, Bit 6 Bus erhalten | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 168 | `OUT (0ACH),A` | 0ACH | H | Status-8: Datum (Zeichen/Tickzahl) an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 170 | `OUT (0ADH),A` | 0ADH | H | Vektor -> VI an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 268 | `; UDOS-Nukleus auf 128-Byte-Sektoren: [0003H] ` | 0003H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 272 | `LD A,04H ; Sektorlaenge/128 = 4 (512 B); der N` | 0003H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 277 | `LD A,(0003H)` | 0003H | U | UDOS-Nukleusdatum `[0003H]` (Sektorlaenge/128, global): wird gelesen, mit 01 verodert, zurueckgeschrieben | **streichen**: in CP/A ist 0003H das IOBYTE (`bios.mac:iobyte equ 3`) -- die Zeile wuerde die Geraetezuordnung veraendern; BIOS-Sektorlaenge kommt aus dem Laufwerkstyp |
| 280 | `LD (0003H),A` | 0003H | U | UDOS-Nukleusdatum `[0003H]` (Sektorlaenge/128, global): wird gelesen, mit 01 verodert, zurueckgeschrieben | **streichen**: in CP/A ist 0003H das IOBYTE (`bios.mac:iobyte equ 3`) -- die Zeile wuerde die Geraetezuordnung veraendern; BIOS-Sektorlaenge kommt aus dem Laufwerkstyp |
| 284 | `; --- DRUCKER: Klasse 1: Ausgabe ueber den UDO` | 0EB00H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 302 | `CALL 0EB00H` | 0EB00H | U | CALL Druckertreiber (IFSSPR/PIOPR, UDOS, vom Skript MUTOS nach EB00 geladen) | BIOS `LIST` (synchron je Zeichen) oder Drucker streichen; DRUCKER_FERTIG entfaellt; EB00 ist in CP/A TPA und darf nicht mehr gerufen werden |
| 312 | `LD A,0FFH` | 0FFH | K | Druckerfehler-Status FFH | bleibt |
| 325 | `; --- KONSOLE_AUS: Klasse 2 Einheit 0: je Zeic` | 0BEBH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 336 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 348 | `REPT (100H-(($-SEG9000) AND 0FFH)) AND 0FFH` | 100H, 0FFH x2 | K | Segmentfuellung auf 100H | bleibt |
| 349 | `DB 0FFH` | 0FFH | K | Fuellbyte | bleibt |
| 353 | `; ---- Segment 9400H .. A2AFH ----` | 9400H, A2AFH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 354 | `.PHASE 9400H` | 9400H | A | Segmentbasis `.PHASE` (UDOS-Programm besteht aus vier Segmenten mit fester Ladeadresse, im `.fileinfo` der Ladediskette) | bei Verlagerung nur Basis in `.PHASE` und Fuellrechnung; Segmente nicht mehr in UDOS-Dateikopf, sondern vom CP/A-Lader (C2) laden |
| 363 | `LD BC,00AFH` | 00AFH | H | Port AFH Attributspeicher (B = Seite) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 373 | `LD (0FEAH),HL` | 0FEAH | U | Eintrag in die UDOS-IM-2-Tabelle (I = 0FH, gemessen): 0FEAH PIO-A32 Port A, 0FECH Port B, 0FE2H CTC-Kanal 1 | Tabelle liegt in CP/A bei F700H (`intvec`, I = F7, gemessen): Adresse als `INTVEC+0EAH` usw.; CTC-Kanal 1 hat dort Vektor FAH (`ivctc1`), nicht E2H -- Slot FA nehmen, Basis nicht aendern (Abschnitt 8) |
| 375 | `LD (0FECH),HL` | 0FECH | U | Eintrag in die UDOS-IM-2-Tabelle (I = 0FH, gemessen): 0FEAH PIO-A32 Port A, 0FECH Port B, 0FE2H CTC-Kanal 1 | Tabelle liegt in CP/A bei F700H (`intvec`, I = F7, gemessen): Adresse als `INTVEC+0EAH` usw.; CTC-Kanal 1 hat dort Vektor FAH (`ivctc1`), nicht E2H -- Slot FA nehmen, Basis nicht aendern (Abschnitt 8) |
| 376 | `LD C,0AAH` | 0AAH | H | PIO-A32 Steuerport A (OTIR TAB_PIO_A) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 380 | `LD C,0ABH` | 0ABH | H | PIO-A32 Steuerport B (OTIR TAB_PIO_B) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 385 | `LD (0FE2H),HL` | 0FE2H | U | Eintrag in die UDOS-IM-2-Tabelle (I = 0FH, gemessen): 0FEAH PIO-A32 Port A, 0FECH Port B, 0FE2H CTC-Kanal 1 | Tabelle liegt in CP/A bei F700H (`intvec`, I = F7, gemessen): Adresse als `INTVEC+0EAH` usw.; CTC-Kanal 1 hat dort Vektor FAH (`ivctc1`), nicht E2H -- Slot FA nehmen, Basis nicht aendern (Abschnitt 8) |
| 386 | `LD A,0A7H` | 0A7H | K | CTC-Steuerwort Kanal 1 (Zeitgeber, Vorteiler 256) | bleibt |
| 388 | `LD A,0C0H` | 0C0H | K | CTC-Zeitkonstante 192 = 50 Hz | bleibt |
| 413 | `DB 00H,18H,02H,08H,01H,00H,04H,44H,05H,68H,03H` | 0C1H | K | SIO-Tastatur-Folge (C1H = WR3) | bleibt |
| 415 | `DB 0EAH,0CFH,0FFH,0B7H,0EFH` | 0EAH, 0CFH, 0FFH, 0B7H, 0EFH | U/K | PIO-A32-Programmierung (Port A: Vektor EAH, Mode 3, ...; Port B: Vektor ECH): `0EAH`/`0ECH` sind die Vektornummern = Tabellenplaetze 0FEAH/0FECH | Vektorbytes mit den Tabellenplaetzen koppeln (Namen); in CP/A sind E8H = `ivdsk1` (Floppy-Index, belegt), EAH `ivdsk2` (deklariert, nie gesetzt), ECH frei -- nutzbar (Abschnitt 8) |
| 417 | `DB 0ECH,0CFH,80H,97H,7FH` | 0ECH, 0CFH | U/K | PIO-A32-Programmierung (Port A: Vektor EAH, Mode 3, ...; Port B: Vektor ECH): `0EAH`/`0ECH` sind die Vektornummern = Tabellenplaetze 0FEAH/0FECH | Vektorbytes mit den Tabellenplaetzen koppeln (Namen); in CP/A sind E8H = `ivdsk1` (Floppy-Index, belegt), EAH `ivdsk2` (deklariert, nie gesetzt), ECH frei -- nutzbar (Abschnitt 8) |
| 434 | `IN A,(0A8H)` | 0A8H | H | PIO A32 lesen: Bit 0-2 Ebene des Z8000, Bit 3 /VI, Bit 6 Bus erhalten | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 441 | `OUT (0ACH),A` | 0ACH | H | Status-8: Datum (Zeichen/Tickzahl) an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 443 | `OUT (0ADH),A` | 0ADH | H | Vektor -> VI an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 454 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 456 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 461 | `; Zeiger holen aus EM-Seite 4 Offset 6 (4006H)` | 4006H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 467 | `LD BC,40AFH` | 40AFH | E | B = 40H (Seite 4), C = AFH: Attribut 0CH fuer die Postfachseite | bleibt (Z8000/EM-Seite) |
| 470 | `LD DE,0000H` | 0000H | K | Zeiger-Loeschwert 0 | bleibt |
| 473 | `LD HL,(4006H)` | 4006H | E | EM-Postfach: Zeiger auf die Nachricht (Seite 4, Offset 6), Z8000-Kernel schreibt, U880 loescht | bleibt (Z8000/EM-Seite) |
| 474 | `LD (4006H),DE` | 4006H | E | EM-Postfach: Zeiger auf die Nachricht (Seite 4, Offset 6), Z8000-Kernel schreibt, U880 loescht | bleibt (Z8000/EM-Seite) |
| 476 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 482 | `LD DE,0A5A8H` | 0A5A8H | A | Kopie der 14-Byte-Nachricht (A5A8H..A5B5H), nicht in der Datei deklariert (liegt vor den Puffern) | Namen `V_NACHR` im Datensegment, mit 0A5A9H = +1 (Einheit) als `V_NACHR+1`; vermeidet Verschiebefehler |
| 483 | `LD BC,000EH` | 000EH | K | 14 Byte Nachricht | bleibt |
| 488 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 489 | `LD A,(0A5A8H)` | 0A5A8H | A | Kopie der 14-Byte-Nachricht (A5A8H..A5B5H), nicht in der Datei deklariert (liegt vor den Puffern) | Namen `V_NACHR` im Datensegment, mit 0A5A9H = +1 (Einheit) als `V_NACHR+1`; vermeidet Verschiebefehler |
| 493 | `LD A,(0A5A9H)` | 0A5A9H | A | Nachricht +1 (Einheit) | `V_NACHR+1` |
| 498 | `LD BC,0006H` | 0006H | K | Offset 6 (DCB+6) | bleibt |
| 500 | `LD DE,0A5A8H` | 0A5A8H | A | Kopie der 14-Byte-Nachricht (A5A8H..A5B5H), nicht in der Datei deklariert (liegt vor den Puffern) | Namen `V_NACHR` im Datensegment, mit 0A5A9H = +1 (Einheit) als `V_NACHR+1`; vermeidet Verschiebefehler |
| 502 | `LD BC,000EH` | 000EH | K | 14 Byte Nachricht | bleibt |
| 534 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 541 | `LD A,(0A5A9H)` | 0A5A9H | A | Nachricht +1 (Einheit) | `V_NACHR+1` |
| 571 | `LD C,0FFH` | 0FFH | K | Zaehler-Startwert (C = FFH) | bleibt |
| 651 | `; SEITE_ABBILDEN: EM-Adresse HL auf das Z80-Fe` | 4000H, 7FFFH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 659 | `LD C,0AFH` | 0AFH | H | Port AFH Attributspeicher (B = Seite) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 662 | `AND 0C0H` | 0C0H | K | Maske EM-Adressbits 14/15 | bleibt |
| 674 | `AND 0C0H` | 0C0H | K | Maske EM-Adressbits 14/15 | bleibt |
| 701 | `OUT (0A9H),A` | 0A9H | H | PIO-A32 Port B: 2CH Grundzustand, 6CH PR-Impuls, 48H+n Bus anfordern (/TRQ8, Segment n) | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 703 | `IN A,(0A8H)` | 0A8H | H | PIO A32 lesen: Bit 0-2 Ebene des Z8000, Bit 3 /VI, Bit 6 Bus erhalten | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 759 | `CP 0FFH` | 0FFH | K | Tastencode FFH = CR | bleibt |
| 765 | `AND 0F0H` | 0F0H | K | Maske Praefix 9xH/BxH | bleibt |
| 768 | `CP 0B0H` | 0B0H | K | Praefix BxH | bleibt |
| 814 | `DB 10H,11H,12H,15H,14H,15H,16H,17H,18H,19H,1AH` | 0FFH | K | Tastentabelle (Fuellbyte FFH am Ende) | bleibt |
| 818 | `; Nukleus-Aufruf (CALL 0BFDH -> JP 0700H) mit ` | 0BFDH, 0700H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 821 | `; NUK_AUFTRAG (996EH) ist der Auftragsblock de` | 996EH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 884 | `LD DE,0D00H` | 0D00H | K | Teiler 0D00H = 26 << 7 (Formel Abschnitt 7) | bleibt |
| 907 | `LD DE,001AH` | 001AH | K | Teiler 26 (Sektoren je Spur) | bleibt |
| 920 | `CALL 0BFDH` | 0BFDH | U | UDOS-Plattenauftrag (JP 0700H), IY = NUK_AUFTRAG, **asynchron** (Bit 0 im Befehl), Rueckruf BLOCK_RUECKRUF je 128-B-Sektor | synchrones BIOS `SELDSK/SETTRK/SETSEC/SETDMA/READ\|WRITE` je Sektor (Abschnitt 3 dieses Dokuments); Rueckrufkette entfaellt |
| 944 | `OR A  ; Rest - 0200H; Uebertrag = halber Schlu` | 0200H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 965 | `CALL 0BFDH` | 0BFDH | U | UDOS-Plattenauftrag (JP 0700H), IY = NUK_AUFTRAG, **asynchron** (Bit 0 im Befehl), Rueckruf BLOCK_RUECKRUF je 128-B-Sektor | synchrones BIOS `SELDSK/SETTRK/SETSEC/SETDMA/READ\|WRITE` je Sektor (Abschnitt 3 dieses Dokuments); Rueckrufkette entfaellt |
| 1040 | `AND 0E0H` | 0E0H | K | Maske Laufwerk<<5 | bleibt |
| 1050 | `; Arbeitsvariablen der Blockabbildung; ab 996E` | 996EH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1058 | `DB 0FFH,0FFH` | 0FFH x2 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1060 | `DB 0FFH,0FFH` | 0FFH x2 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1062 | `DB 0FFH,0FFH` | 0FFH x2 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1064 | `DB 0FFH,0FFH` | 0FFH x2 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1066 | `DB 0FFH,0FFH` | 0FFH x2 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1068 | `DB 0FFH` | 0FFH | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1070 | `DB 0FFH,0FFH,0FFH` | 0FFH x3 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1079 | `; Kommandoblock bei 01B5H (liegt am A5120 im U` | 01B5H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1121 | `LD HL,0000H` | 0000H | K | Rueckrufzeiger 0 = keiner | bleibt |
| 1162 | `LD IX,01B5H` | 01B5H | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1168 | `DB 0FFH,0FFH` | 0FFH x2 | K | Vorbelegung FFH | bleibt |
| 1180 | `DB 80H,0F1H,40H,0F2H,10H,0F3H,08H,0F4H,20H,0F5` | 0F1H, 0F2H, 0F3H, 0F4H, 0F5H, 0F6H, 0F7H, 0F8H | K | Fehlercodes F1H..F8H der Roh-Floppy | bleibt |
| 1184 | `LD DE,0004H` | 0004H | K | Eintragslaenge 4 der TAB_KMD | bleibt |
| 1193 | `LD (IY+10),0C1H` | 0C1H | K | Fehlercode C1H (Roh-Floppy: Befehl unbekannt) | bleibt |
| 1203 | `LD IX,01B5H` | 01B5H | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1210 | `LD (01B6H),DE` | 01B6H | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1216 | `LD (01B8H),DE` | 01B8H | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1286 | `LD (IY+10),0C2H` | 0C2H | K | Fehlercode C2H (Roh-Floppy: Zeitablauf) | bleibt |
| 1293 | `LD HL,(01BAH)` | 01BAH | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1299 | `LD HL,01B5H` | 01B5H | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1300 | `LD DE,01B6H` | 01B6H | U | Kommandoblock Roh-Floppy 01B5H..01BCH (liegt im UDOS-Nukleus, gemessen: Klasse 3 zerstoert dort 8 Byte) | Klasse 3 (ROH, KMD_*) ersatzlos streichen (nie gelaufen); in CP/A waere 01B5H eigener Code, wenn `.COM` ab 0100H (E3b) |
| 1301 | `LD BC,0008H` | 0008H | K | 8 Byte Kommandoblock loeschen | bleibt |
| 1324 | `IN A,(0A8H)` | 0A8H | H | PIO A32 lesen: Bit 0-2 Ebene des Z8000, Bit 3 /VI, Bit 6 Bus erhalten | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 1334 | `OUT (0ACH),A` | 0ACH | H | Status-8: Datum (Zeichen/Tickzahl) an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 1336 | `OUT (0ADH),A` | 0ADH | H | Vektor -> VI an den Z8000 | bleibt (Hardware, gleiche Karte; Konfliktpruefung Abschnitt 8) |
| 1410 | `LD A,0FFH` | 0FFH | K | tty-Fehlerstatus FFH | bleibt |
| 1424 | `; IM-2-Tabelle 0F30H-0F3EH: Kanal B Tx 9F18/Rx` | 0F30H, 0F3EH | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1439 | `LD (0F30H),DE` | 0F30H | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1441 | `LD (0F32H),DE` | 0F32H | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1442 | `LD (0F34H),DE` | 0F34H | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1443 | `LD (0F36H),DE` | 0F36H | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1445 | `LD (0F38H),DE` | 0F38H | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1447 | `LD (0F3AH),DE` | 0F3AH | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1448 | `LD (0F3CH),DE` | 0F3CH | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1449 | `LD (0F3EH),DE` | 0F3EH | U | Eintrag in die UDOS-IM-2-Tabelle: 0F30..0F3EH = SIO-Vektoren (WR2 = 30H) Kanal B Tx/Ext/Rx/Spez, Kanal A | `INTVEC+30H..3EH` (F730H..F73EH, im BIOS-Bereich E0..FF nicht belegt, `intvl = intvsy = E0`); SIO-Kanal A/B teilt sich das BIOS mit dem UC1-Treiber (`iobuc1 = 1811`), siehe Abschnitt 8 |
| 1526 | `LD A,0C0H` | 0C0H | K | Sende-Fehlerstatus C0H | bleibt |
| 1572 | `DB 0C8H,00H` | 0C8H | K | Vorbelegung V_SIO_REST = 00C8H | bleibt |
| 1583 | `; (Ausgabe mit UDOS 0BF1H), die drei Fehlertex` | 0BF1H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1612 | `; Fehlertexte (je 30 Byte, werden mit MELDUNG_` | FF60H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1636 | `LD BC,0400H` | 0400H | K | B = 4 Spalten, C = 0 | bleibt |
| 1645 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1647 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1651 | `LD BC,0478H` | 0478H | K | B = 4, C = 78H | bleibt |
| 1654 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1655 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1656 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1658 | `CALL 0BE8H` | 0BE8H | U | UDOS-Tastenabfrage (JP 05CBH), Z = keine Taste, sonst A = Zeichen | BIOS `CONST` + `CONIN` (A != 0 -> Zeichen holen); nur Bedienmaske |
| 1666 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1685 | `AND 0CCH` | 0CCH | K | Maske Zifferpruefung | bleibt |
| 1742 | `LD BC,0400H` | 0400H | K | B = 4 Spalten, C = 0 | bleibt |
| 1756 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1758 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1763 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1765 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1767 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1769 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1771 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1773 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1775 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1777 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1779 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1781 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1783 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1785 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1787 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1789 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1791 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1795 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1797 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1799 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1801 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1803 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1805 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1807 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1809 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1811 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1813 | `CALL 0BEBH` | 0BEBH | U | UDOS-Zeichenausgabe (JP 0513H), A = Zeichen | BIOS `CONOUT` (CP/M: Zeichen in C, `LD C,A`; Sprungleiste CB00+0CH, *abgeleitet* aus CP/M-2.2-Layout, C1.5 prueft); HL/BC bleiben von KONSOLE_AUS gerettet, DE zusaetzlich retten |
| 1815 | `CALL 0BF1H` | 0BF1H | U | UDOS-Textausgabe (JP 044EH): HL = laengenvorangestellte Zeichenkette | Schleife ueber BIOS `CONOUT` (Laenge im ersten Byte); nur Bedienmaske betroffen |
| 1817 | `; Meldung (30 Byte ab HL) nach FF60H kopieren,` | FF60H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1819 | `LD DE,0FF60H` | 0FF60H | U | Meldezeile des UDOS-Bildschirms (30 Byte, Fehlermeldungen der Bedienmaske) | nur Bedienmaske: ueber CONOUT ausgeben oder Maske streichen |
| 1820 | `LD BC,001EH` | 001EH | K | 30 Byte Meldung | bleibt |
| 1829 | `REPT (100H-(($-SEG9400) AND 0FFH)) AND 0FFH` | 100H, 0FFH x2 | K | Segmentfuellung auf 100H | bleibt |
| 1830 | `DB 0FFH` | 0FFH | K | Fuellbyte | bleibt |
| 1834 | `; ---- Segment A400H .. A5A7H ----` | A400H, A5A7H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 1835 | `.PHASE 0A400H` | 0A400H | A | Segmentbasis `.PHASE` (UDOS-Programm besteht aus vier Segmenten mit fester Ladeadresse, im `.fileinfo` der Ladediskette) | bei Verlagerung nur Basis in `.PHASE` und Fuellrechnung; Segmente nicht mehr in UDOS-Dateikopf, sondern vom CP/A-Lader (C2) laden |
| 1953 | `DB 0AH,05H,0B6H,0A8H,0FFH,0FFH,0FFH,0FFH,0FFH,` | 0B6H, 0A8H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1954 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1956 | `DB 12H,04H,0B6H,0A7H,0FFH,0FFH,0FFH,0FFH,0FFH,` | 0B6H, 0A7H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1957 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1959 | `DB 1AH,05H,0B6H,0B8H,0FFH,0FFH,0FFH,0FFH,0FFH,` | 0B6H, 0B8H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1960 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1962 | `DB 24H,04H,0B6H,0A5H,0FFH,0FFH,0FFH,0FFH,0FFH,` | 0B6H, 0A5H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1963 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1965 | `DB 28H,04H,36H,0A6H,0FFH,0FFH,0FFH,0FFH,0FFH,0` | 0A6H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1966 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1968 | `DB 2CH,04H,0B6H,0A6H,0FFH,0FFH,0FFH,0FFH,0FFH,` | 0B6H, 0A6H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1969 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1971 | `DB 30H,04H,36H,0A7H,0FFH,0FFH,0FFH,0FFH,0FFH,0` | 0A7H, 0FFH x12 | A/K | DCB+2/+3: Z80-Puffer der Einheit als Bytepaar (B6 A8 = A8B6 Platte, B6 A7 = A7B6 Drucker, B6 B8 = B8B6 Roh-Floppy, B6 A5 = A5B6 Konsole, 36 A6/B6 A6/36 A7 = A636/A6B6/A736 tty1..3) | je `DW PUF_xxx` mit Namen; Puffer (insgesamt A5B6..B935, 0DB0H Byte, in der Datei nicht angelegt) als eigene Reservierung |
| 1972 | `DB 0FFH,0FFH,0FFH,0FFH,00H,00H,00H` | 0FFH x4 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 1975 | `DB 00H,0AH,0B6H,0A8H` | 0B6H, 0A8H | A | AUFx+2/+3: derselbe Puffer als Bytepaar im Nukleus-Auftragsblock | je `DW PUF_xxx` |
| 1983 | `DB 00H,0EH,0B6H,0A7H,00H,00H,00H,00H,00H,00H` | 0B6H, 0A7H | A | AUFx+2/+3: derselbe Puffer als Bytepaar im Nukleus-Auftragsblock | je `DW PUF_xxx` |
| 1987 | `DB 00H,0EH,0B6H,0B8H,00H,00H,00H,00H,00H,00H,0` | 0B6H, 0B8H | A | AUFx+2/+3: derselbe Puffer als Bytepaar im Nukleus-Auftragsblock | je `DW PUF_xxx` |
| 1989 | `DB 01H,0EH,36H,0A6H,00H,00H,00H,00H,00H,00H` | 0A6H | A | AUFx+2/+3: derselbe Puffer als Bytepaar im Nukleus-Auftragsblock | je `DW PUF_xxx` |
| 1993 | `DB 02H,0EH,0B6H,0A6H,00H,00H,00H,00H,00H,00H` | 0B6H, 0A6H | A | AUFx+2/+3: derselbe Puffer als Bytepaar im Nukleus-Auftragsblock | je `DW PUF_xxx` |
| 1997 | `DB 00H,0EH,36H,0A7H,00H,00H,00H,00H,00H,00H` | 0A7H | A | AUFx+2/+3: derselbe Puffer als Bytepaar im Nukleus-Auftragsblock | je `DW PUF_xxx` |
| 2001 | `REPT (100H-(($-SEGA400) AND 0FFH)) AND 0FFH` | 100H, 0FFH x2 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 2002 | `DB 0FFH` | 0FFH | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 2006 | `; ---- Segment C8B6H .. C967H ----` | C8B6H, C967H | Kom | Kommentar, kein Code | bei Umbenennung/Neubau mitziehen |
| 2007 | `.PHASE 0C8B6H` | 0C8B6H | A | Segmentbasis `.PHASE` | siehe oben |
| 2011 | `DB 04H,04H,00H,00H,0FFH,0FFH,0FFH,0FFH,0FFH,0F` | 0FFH x12 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 2014 | `DB 04H,04H,00H,00H,0FFH,0FFH,0FFH,0FFH,0FFH,0F` | 0FFH x12 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 2017 | `DB 04H,04H,00H,00H,0FFH,0FFH,0FFH,0FFH,0FFH,0F` | 0FFH x12 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 2020 | `DB 04H,04H,00H,00H,0FFH,0FFH,0FFH,0FFH,0FFH,0F` | 0FFH x12 | K | Konstante / Fuellbyte / Vorbelegung 0FFH | bleibt |
| 2028 | `REPT (100H-(($-SEGC8B6) AND 0FFH)) AND 0FFH` | 100H, 0FFH x2 | K | Segmentfuellung auf 100H | bleibt |
| 2029 | `DB 0FFH` | 0FFH | K | Fuellbyte | bleibt |

## 4. Zusatzfunde (nicht von den Mustern erfasst)

| Fundstelle | Wert | Klasse | Bedeutung | CP/A-Ersatz |
|------------|------|--------|-----------|-------------|
| 517, 836 | `RST 38H` | U | Fehlerhalt (`IA_BELEGT`: zweite Nachricht trifft belegten DCB; Plattenauftrag > 1000H); im UDOS-Lauf nie ausgefuehrt (analyse.md §9) | CP/A: `rst 38h` fuehrt zum Monitor, ohne Monitor zum Warmstart (`bios.mac:137`, `biosnuc.mac:8`) -- mit ueberschriebenem BDOS ungeeignet, besser eigene Halteschleife |
| gesamte Datei | kein `IM 2` / `LD I,A` | U | `mutos_io` setzt weder Interruptmodus noch `I` und schreibt in die UDOS-Tabelle: Annahme `IM 2`, `I = 0FH` (**gemessen**: `ivt` zeigt `ZVE1: I=0F IM 2`) | CP/A: `I = F7`, Tabelle `intvec = 0F700H` (**gemessen** §2.1, `bios.mac:1205`); alle Tabellenadressen als `INTVEC + n` |
| `OUT (0DH),A` Zeile 387/389 | CTC-Kanal 1 ohne Vektorprogrammierung | U | Vektorbasis des System-CTC (Port 0CH) setzt UDOS auf E0H (**gemessen**: `ivt` Kanal 1 = E2H, Kanal 3 = E6H) -- `mutos_io` schreibt nur in den Tabellenplatz 0FE2H | CP/A: Basis F8H (`ivctc0 = intvsy+18h`, `biostimc.mac:17`), Kanal 1 = **FAH**; Tabellenplatz und (falls noetig) Basis anpassen |
| `OUT (0DH)`, `OUT (58H)`, `OUT (5AH)` | CTC 0DH Kanal 1 (50 Hz), 58H Tastaturtakt, 5AH SIO-Takt | H | | CP/A nutzt 0CH (Vektor), 0EH (5 ms), 0FH (1 s) -- 0DH frei (`biostimc.mac:4-16`); 58H nutzt das BIOS gleich (`kbdsct equ 58h`, `bios.mac:882`) |
| `IN/OUT (50H..53H)` | SIO A/B (tty1..3, Senden nur Kanal A) | H | | CP/A programmiert dieselbe SIO fuer den UC1-Treiber (`iobuc1 = 1811`, `bios.mac:616`, Vektorbasis `intvuc = D0H`); `INIT_SIO` schreibt WR2 = 30H um -- UC1 und `mutos_io`-tty1 schliessen sich aus (Entscheidung C3) |
| `IN (5CH/5DH)`, `OUT (5CH)` | Tastatur-SIO (abgefragt) | H | | CP/A fragt dieselbe SIO selbst ab (`kbdsci equ 5ch`, `kbdpin = 0` = kein Tastaturinterrupt, Abfrage im 5-ms-Zeitgeber `biostim.mac`): beide wuerden Zeichen stehlen -- eine Seite muss abgeschaltet werden (Abschnitt 8) |
| `OUT (1CH),A` Zeilen 1275 | Roh-Floppy-Start | H | am A5120 unbelegt (analyse.md §8) | Klasse 3 streichen |

## 5. Frage (1): Speicherkarte `mutos_io` neben CP/A, Vorschlag fuer §3.3

**Karte `mutos_io`** (Segmente: `mutos_io/karte.txt`, Zeile `seg`; Rest aus Quelle/analyse.md §2, *abgeleitet*; EM-Fenster *gemessen*):

| Bereich | Groesse | Inhalt |
|---------|---------|--------|
| 9000..922C | 022DH | Segment 1: Hauptschleife, Handler Platte/Drucker/Konsole (Fuellung bis 92FF) |
| 9400..A2AF | 0EB0H | Segment 2: INIT, ISRs, Warteschlangen, Blockabbildung, Roh-Floppy, SIO, Bedienmaske |
| A400..A5A7 | 01A8H | Segment 3: Klassen-Beschreiber, Handlertabellen, 7 DCBs, 6 Auftragsbloecke |
| A5A8..A5B5 | 000EH | Kopie der 14-Byte-Nachricht (nicht in der Datei, nur Zahl `0A5A8H`) |
| A5B6..B935 | 1380H | Z80-Puffer (nicht in der Datei): Konsole A5B6, tty1 A636, tty2 A6B6, tty3 A736, Drucker A7B6 (je 128 B), Platte A8B6..B8B5 (4 KB), Roh-Floppy B8B6 (128 B) |
| B936..C8B5 | 0F80H | unbenutzt |
| C8B6..C967 | 00B2H | Segment 4: Ringe Tastatur C8B6, tty1 C8E2, tty2 C90E, tty3 C93A (je 2CH), `V_TAKT` C966, `V_BUSY` C967 |
| ..CB68 | | Stapel (`LD SP,0CB68H`), waechst nach unten |
| EM-Fenster 4000..7FFF | 4000H | beliebige EM-Seite per Port AFH eingeblendet (je zwei 4-KB-Seiten); davon `mutos_io` selbst nichts |

**Karte CP/A** (2-Floppy-Systemdiskette, **gemessen** Plan 48 §2.1): TPA 0100..BD05H, BDOS BD06H.., BIOS ab **CB00H** (Warmstart CB03H), `I = F7` (Tabelle F700H..F7FFH), `iobyte` bei 0003H (`bios.mac:1293`).  Mit `anzdisk > 2` waechst das BIOS (C1.8 misst die Lage).

**Ueberdeckung (abgeleitet aus beiden Karten):**
* Segment 4 (C8B6..C967) und alles ab 9000 ueberdeckt BDOS (BD06H..CAFFH).  `mutos_io` ruft kein BDOS (`CALL 5` kommt nicht vor) -- das BDOS kann bleiben, nur wird es zerstoert; ein Rueckweg nach CP/A ist ohne Neuladen nicht moeglich.
* Stapel CB68H liegt 68H Byte **im** BIOS (CB00H..CB67H = Sprungleiste) -- muss unter CB00H, **mit Pflicht**, auch wenn BDOS/CCP preisgegeben werden.  Gemessene Stapeltiefe: SP im Betrieb CB58..CB66 (Logpoints, `sonde.log`), also nur wenige Byte; ein Platz C968..CAFF (198H = 408 B) genuegt (*Annahme*, keine Grenzmessung).
* Das EM-Fenster 4000..7FFF liegt in der TPA und ist frei, solange nichts dort lebt; bei einer `.COM`-Fassung (E3b) darf das Programm samt Puffern die 4000H nicht erreichen.

**Vorschlag fuer §3.3 / E3:**
* **(a) feste Lage beibehalten** (`.PHASE 9000H` usw.): nur `LD SP` auf einen Wert unter dem BIOS-Anfang (2 Floppy: `0CB00H`; Bedingung: BIOS-Anfang >= C968H + Stapel, 4-Floppy-Lage aus C1.8); alles andere bleibt; BDOS wird zerstoert.  Aufwand klein.
* **(b) `.COM` ab 0100H**: Verschiebung um -8F00H (9000 -> 0100, C967 -> 2A67); mit dem Stapel unter 2C00H endet alles vor 4000H.  Vorher alle A-Zahlen aus Abschnitt 3 durch Namen ersetzen (`V_NACHR`, `INITSP`, `PUF_*` als `DW`), und die 01B5H-Zeilen (Roh-Floppy) muessen weg, sonst liegen sie in den eigenen Code.  Zusammenpacken ohne die Luecken (B936..C8B5, Segmentfuellungen) spart ~4 KB und ist fuer die Entscheidung nicht noetig.
* Empfehlung: **(a)** fuer C2/C3 (kleinster Schritt, bytegleiche Segmente bleiben bis auf die U-Zeilen), (b) erst nach der Namensersetzung.

## 6. Frage (2): Ablauf des Plattenauftrags `9800..9904` mit dem Nukleus

**Quelle (abgeleitet):** `PLATTE` (90EB) baut `AUF0` und ruft `BLOCK_START`; dieses rechnet den ersten 128-B-Sektor, setzt `IY = NUK_AUFTRAG` und `CALL 0BFDH` (988D).  Der Befehl ist `0BH`/`0FH` **mit Bit 0 = 1**
(`BLOCK_START`: `LD A,H; OR 01H`) -- laut `doc/plan/39_mutos8000.md` §11.1 heisst Bit 0 *asynchron mit Rueckruf*.  Der Nukleus-Einsprung `0700H` (**gemessen**, `u 0x700`, `sonde2.log`):
```
0700 LD HL,(0FC7H) / OR / JR NZ,0700H     ; wartet, bis kein anderer Auftrag laeuft (Zeiger 0FC7H = laufender Auftrag)
0707 LD (HL),C3H ; LD (IY+0AH),IYL ; LD (0FC7H),IY
0710 BIT 0,(IY+01H) ; JR NZ,0720H         ; Bit 0 gesetzt: Auftrag starten und zurueck (asynchron)
0716 CALL 0720H ; 0719 BIT 7,(IY+0AH) ; JR Z,0719H ; RET   ; Bit 0 klar: starten und warten (synchron)
```
Das Ende meldet die **CTC-Kanal-3-ISR** `0B3C` (Vektor E6H): sie setzt `(IY+0AH)` Bit 7 und kehrt per `EX (SP),HL; RETI` in den Rueckruf `(IY+6/7)` bzw. `(IY+8/9)` zurueck (`0B57..0B7E`).

**Messung** (`sonde.dbg`, Logpoints, 135 Plattenauftraege beim Boot bis `#`):
* `CALL 0BFDH` kehrt **vor** dem Ende zurueck: `9800` (Eintritt) -> `9890` (Rueckkehr nach der CALL) im Mittel nach ~3200..3600 Takten, der **erste Rueckruf `9893` erst ~1 185 000 Takte spaeter** (Positionieren/Drehwartezeit), die weiteren Sektoren je ~30 000..45 000 Takte.
* Je Kernelblock (512 B) **4 Rueckrufe** `9893` (540 insgesamt = 135 x 4), davon **3 mit erneutem `CALL 0BFDH`** aus dem Rueckruf (`98E0`, Rueckkehr `98E3` rund 2400 Takte spaeter) und der letzte mit `9163` (`PLATTE_FERTIG`) knapp danach.  SP im Rueckruf CB62..CB66: der Rueckruf laeuft auf dem Stapel der unterbrochenen Hauptschleife.
* Alle 1109 CTC-Kanal-3-Interrupts (E6H) nach dem Start von `mutos_io` fallen in die ersten 3 Mio. Takte nach einem `9800`-Aufruf, also **nur** in Plattenauftraege (`itrace`, `sonde.dbg`).
* Waehrend des Auftrags bedient die Hauptschleife die anderen Klassen weiter: `PLATTE` loescht das Anforderungsbit sofort (`JP ENDE_LOESCHEN`, "Auftrag laeuft im Nukleus weiter"), `V_BUSY` (C967) sperrt nur einen zweiten Plattenauftrag.  `MELDEN` an den Z8000 geschieht erst, wenn `PLATTE_FERTIG` das Fertigbit gesetzt hat.

**Folgen fuer ein synchrones BIOS-`READ`/`WRITE` (abgeleitet, Vorschlag):**
1. `BLOCK_START`/`BLOCK_RUECKRUF`/`BR_FERTIG`/`BR_ABBRUCH` und die Zeiger `V_RUECKRUF_*` fallen weg; `PLATTE` wird eine Schleife ueber 4 Sektoren (26 x 128) bzw. 1 Sektor (K8X512) mit `SELDSK/SETTRK/SETSEC/SETDMA/READ|WRITE`, danach direkt Status und Fertigbit (`ENDE_WIEDER` wie `KONSOLE_AUS`).  `PLATTE_FERTIG` laeuft nicht mehr im Interrupt-Kontext (kein `REGS_RETTEN`/`DI` noetig).
2. **Die Hauptschleife blockiert** je Sektor (gemessen im UDOS-Lauf: ~1,2 Mio. Takte fuer den ersten Sektor eines Auftrags, grob 0,5 s bei 2,46 MHz [Annahme Taktfrequenz], danach 30 000..45 000 Takte je Sektor); Konsolenausgabe und Tastenmeldungen verzoegern sich entsprechend.  Weiter laufen nur die Interrupts: `ISR_ANFRAGE` (neue Nachrichten werden angenommen und stehen als Anforderungsbit), `ISR_TAKT`.  Ob das BIOS beim Lesen die Interrupts freilaesst, ist **offen** (BIOS-Abschnitte `kritbg/kriten`, C1.5/C1.7 messen).
3. `V_BUSY` und der Wiedervorlage-Zweig (`90F2`) werden ueberfluessig (nie zwei Plattenauftraege gleichzeitig); der Fehlerrueckruf (`9904..991A`, nie gelaufen) wird zum Rueckgabewert von `READ`: BIOS liefert A = 0/1 (CP/M), `mutos_io` muss daraus einen Status mit Bit 6 (>= 40H, vom Kernel als Fehler gelesen) machen -- z. B. fester Code.
4. Daten: der Nukleus liest direkt in den Puffer `IY+2/3` (A8B6..); mit `SETDMA` auf denselben Puffer entfaellt nichts.  Fuer 26 x 128 und das BIOS-Sektorformat 128 B bleibt die 4-Sektoren-Schleife; die Eingabe `[0003H]` entfaellt.

## 7. Frage (3): Block -> (Zylinder, Sektor)

Eingabe: Blocknummer `bn` (16 Bit, `IX+18` hoch / `IX+19` niedrig aus der Nachricht +12/+13; die oberen 16 Bit der Nachricht werden nie benutzt, analyse.md §3), Laufwerk `d = TAB_RK_LAUFWERK[minor]` (0..3).

**26 x 128 (`K8X512 = 0`, `SPT = 26`), je Kernelblock 4 Aufrufe `k = 0..3`:**
```
l   = 4*bn + k                    ; logischer 128-B-Sektor
q   = l div 26     (nur 8 Bit)    ; Zylinder relativ;  gueltig fuer l < 6656, d. h. bn < 1664 (gemessen am Modell: Ueberlauf ab bn = 1664)
pos = l mod 26
v   = (6*q) mod 26                ; Spurversatz 6 je Zylinder
x   = 2*pos ; wenn x >= 26 dann x = x + 1        ; Verschraenkung 2: erst 13 ungerade, dann 13 gerade Positionen
ID  = ((x + v) mod 26) + 1        ; physische Sektor-ID 1..26   (Nukleus +11: (d << 5) | (ID-1))
Zylinder = q + 1                  ; Nukleus +12; Zylinder 0 gehoert nicht zum Blockraum
```
Die Division macht `BLOCK_START` als 8-fache Schiebe-Subtraktion mit `DE = 0D00H` (= 26 << 7) auf `HL = 4*bn`: L = `q`, H = `pos`.  `SEKTOR_WEITER` setzt `pos+1`, bei 26 `pos = 0`, `q+1`, `v = (v+6) mod 26` -- das gleiche wie die Formel.
Beispiele: bn 0 -> (Zyl 1; ID 1,3,5,7); bn 1 -> (1; 9,11,13,15); bn 6 -> (1; 24,26) dann (2; 7,9).

**Pruefung (gemessen):** Modell der Assemblerfolge und geschlossene Formel stimmen fuer alle bn 0..1663 ueberein (`/tmp/mplus/c1_4/formel.py`), und gegen den Lauf: `sonde3.dbg` loggt an `CALL 0BFDH` (988D, 98E0) `IY+0`, `IY+1`, `IY+11`, `IY+12` und an `90FC` die Blocknummer -- **135 Auftraege, 540 Aufrufe, 0 Abweichungen** (nur Laufwerk 2 = rk2, bn <= 250, Befehl `0BH` lesen/`0FH` schreiben, `IY+11 >> 5 = 2`).

**8 x 512 (`K8X512 = 1`, `SPT = 8`; *abgeleitet* aus der Quelle, hier nicht gelaufen):** `pos = bn mod 8`, `q = bn div 8`, Zylinder `q + 1`, `ID = pos + 1` (keine Verschraenkung, kein Versatz), **ein** Aufruf je Block mit Laenge 0200H (`SEKLEN`), Sektorlaenge 512 muss dem Nukleus ueber `[0003H] = 4` mitgeteilt werden (in CP/A entfaellt das: Laenge kommt aus dem Laufwerkstyp).

**Fuer C1.6 (Pruefung gegen das BIOS), Annahmen:**
* Ruft `mutos_io` das BIOS **unmittelbar** (`SETTRK`, `SETSEC`) auf, ist `SETSEC = ID` (1-basig, **ohne** `SECTRAN`) und `SETTRK = Zylinder`.  Die CP/A-Tabelle `biosdpb.mac:374` (`1,7,13,19,25,5,11,...`, Verschraenkung 6) gehoert zu `SECTRAN` fuer das BDOS und ist **nicht** die MUTOS-Verschraenkung; sie darf nicht dazwischenkommen.
* Offen: ob das BIOS `SETSEC` 0- oder 1-basig nimmt (Kommentar `bios.mac:1395`: "log. Sektnr (ab 0!!)" bei `SECTRAN`), ob die Spurnummer dem Zylinder entspricht (Spur 0 / Systemspuren) und ob bei zweiseitigen Formaten eine Kopfzuordnung dazukommt (Wurzeldisketten sind einseitig `ss77_26x128`).  Diese Punkte misst C1.6.

## 8. Frage (4): Interrupts

**`mutos_io` erwartet (gemessen: `ivt all` nach `INIT`, `sonde.log`; UDOS: `I = 0F`, IM 2):**

| Quelle | Vektor | Tabellenplatz | ISR | Setzt wer |
|--------|--------|---------------|-----|-----------|
| EM PIO A32 Port A (INT-16 vom Z8000) | EAH | 0FEAH | `ISR_ANFRAGE` (94C1) | `mutos_io` (Vektorbyte `TAB_PIO_A`, Tabelle `INIT`) |
| EM PIO A32 Port B (Paritaet /PE) | ECH | 0FECH | `ISR_PARITAET` (94B4) | `mutos_io` |
| System-CTC Kanal 1 (Port 0DH, 50 Hz) | E2H | 0FE2H | `ISR_TAKT` (947E) | Tabelle `mutos_io`, **Vektorbasis E0H UDOS** (nicht in der Quelle) |
| K8025-SIO A33 (Kanal A/B) | 30H..3EH | 0F30H..0F3EH | `ISR_SIO_*` (9F18, 9E61, 9EFB, 9E3E) | `mutos_io` (WR2 = 30H, `INIT_SIO`) |
| Tastatur-SIO A32 | -- | -- | keine, abgefragt (IE = 0) | -- |

Zeitgeber-ISR und PIO-ISR fallen im Lauf an: 3297 x `E2H`, 170 x `EAH` (`itrace`, rund 198 Mio. Takte Betrieb); nie: `ECH`, SIO.

**Was der UDOS-Nukleus nach dem Start von `mutos_io` noch bedient (gemessen, `itrace` ueber den ganzen Lauf, 13 780 U880-Interrupts):**
* **CTC Kanal 3 (E6H -> `0B3C`)**: 1109 Interrupts, **alle** im Plattenauftrag (Abschnitt 6) -- Plattenende/Rueckruf des Nukleus.  Entfaellt mit dem BIOS-`READ`.
* BS-PIO (B8H -> `007A`): 62 x, nur beim UDOS-Boot (vor Takt 83 000); K5122-Steuer-PIO (BAH -> `01C7`): 5 x bei 0,6..2,5 Mio. Takten (UDOS-Boot) -- danach nie wieder.  Kein weiterer Nukleus-Interrupt.
* Der Nukleus ruft `mutos_io` nur ueber die Rueckrufe, sonst gar nicht (nicht ISR-getrieben).

**CP/A-Seite (abgeleitet, `bios.mac:1205-1262`, `biostimc.mac`, `biosdskc.mac`, `bioschdc.mac`):** `intvec = F700H`, belegt `E0H..FFH` (`intvsy = E0H`): E0 Paritaet EM256 (`ivpar`), **E2 PIO-Drucker (`ivpiod`)**, E6 Speicherschutz,
E8 Floppy-Index (`ivdsk1`, gesetzt in `biosdskc.mac`), EA `ivdsk2` (deklariert, **nirgends gesetzt**), EC/EE frei, F0..F6 Lochstreifen, **F8..FE CTC (`ivctc0..3`)**; Kanaele 2 und 3 des System-CTC (5 ms / 1 s) sind belegt, **Kanal 1 (0DH) ist frei**.  Unterhalb E0H ist alles frei, ausser SIO/UC1 `D0..DE` (`iobuc1`).
* **Konflikt 1 (CTC):** `ISR_TAKT` nach `F7FAH` (Kanal 1 bei Basis F8H) statt `F7E2H` (= PIO-Drucker); die Vektorbasis aendert man **nicht** (BIOS-Zeitgeber haengen daran).
* **Konflikt 2 (PIO A32):** EAH/ECH sind nicht gesetzt oder frei, daher **keine Aenderung noetig** (Annahme, `itest` in C1.7 prueft; Alternative bei Bedarf E4H/EEH).
* **Konflikt 3 (SIO):** `INIT_SIO` setzt WR2 = 30H und Rx/Tx-Modus (7 Bit, ungerade Parit.); das BIOS-UC1 braucht dieselbe SIO mit `D0H` und 8 Bit -- einer von beiden muss die tty-Leitung abgeben (C3).
* **Konflikt 4 (Tastatur):** das BIOS fragt Tastatur-SIO 5DH/5CH im 5-ms-Zeitgeber ab und uebersetzt in CP/A-Codes; `ISR_TAKT` fragt dieselbe SIO roh ab (`TAB_TASTE`, Praefixe 9xH/BxH).  Vorschlag: `TASTE_LESEN` durch `CONST`/`CONIN`-Abfrage aus `HAUPT` ersetzen (BIOS-Codes, Maske braucht dann keine eigene Abfrage) und `ISR_TAKT` nur noch als Tickgeber (Zaehler/`ACH`) behalten.  *Annahme:* BIOS-Tastencodes reichen fuer `getty`/Anmeldung; Umlaute/Steuercodes sind zu pruefen.
* `I`-Register: `mutos_io` darf `I` nicht aendern (BIOS: `F7`); alle Tabellenzugriffe `INTVEC + n` (Namen statt `0F..H`).
* `EI`/`DI`-Gewohnheiten (Hauptschleife `EI`, ISR mit `EI; RETI`) bleiben; BIOS-Floppyroutinen schalten im Lesen kurz `DI` (`kritbg`) -- in C1.7 Latenz der `ISR_ANFRAGE` messen.

## 9. Auffaelligkeiten

1. **`[0003H]`-Schreibzugriff ist in CP/A gefaehrlich**: dort liegt das IOBYTE (`bios.mac:1293`); `NUKLEUS_INIT` verodert Bit 0 und aendert damit die Zuordnung der Konsole.  Zeilen 277/280 streichen (gehoeren zu keiner Variante, die in CP/A laeuft).
2. **Stapel in der BIOS-Sprungleiste**: `LD SP,0CB68H` laege im 2-Floppy-BIOS (CB00H) -- ohne Aenderung bricht der erste `PUSH` die Sprungleiste.
3. **Klasse 3 (Roh-Floppy) ist doppelt hinderlich**: sie schreibt in 01B5H..01BCH (UDOS-Nukleus, gemessen zerstoerend) und startet `OUT (1CH)` (unbelegt); in einer `.COM` ab 0100H waeren das eigene Bytes.  Ersatzlos streichen; der Kernel hat zwar einen `fd`-Treiber, aber keinen Geraeteknoten.
4. **Obergrenze der Blockrechnung**: Quotient nur 8 Bit, ab `bn = 1664` falsch (Zylinder > 255); fuer die 26 x 128-Disketten (494 Bloecke) und 8 x 512 (608) bedeutungslos, bei groesseren Medien/Platte (Plan 48 spaeter) nicht verwendbar.
5. `AUF0..AUF5`/`DCB*`-Tabellen haben die Pufferzeiger als **Bytepaare** (`0B6H,0A8H` = A8B6H) -- bei jeder Verlagerung per Hand zu aendern, daher als `DW PUF_xxx` schreiben (Abschnitt 3, Zeilen 1953..1997).
6. `ISR_TAKT` meldet nur bei Ebene < 6 und freiem `/VI`; Zeitgeber-ISR-Rate im Lauf 3297 Aufrufe in ~198 Mio. Takten -- *nicht* 50 Hz nach der Rechnung der analyse.md (60 000 statt 49 152 Takte Abstand im `itrace`-Zaehler); Ursache nicht untersucht (Zeitbasis des `itrace`-Zaehlers vs. `Takte`), fuer den Umzug ohne Belang.
