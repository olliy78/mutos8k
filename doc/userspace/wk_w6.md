# Auftrag W6 (Plan 52): `c1` (`/usr/lib/c1`), der Codegenerator

Branch `us-wk-w6`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht *Annahme*.  Original: 35774 B (text 30176 = 0x75E0, data 5582, bss 1832).

## Teil 1: Karte und libc-Teil

**Karte** (`userspace/c1/karte_extra.txt`, `--check c1` OK, Ueberlappung 0, ungueltig 0).  W0 meldete 119 Ueberlappungen.  Ursache (gemessen): die Vorschlaege von `z8kdis` lesen Konstanten (`0x0200`, `0x0702` ...)
als Zeiger auf Code; ohne die Schalttabellen erreicht der Ablauf von `code 0` nur 9,7 % des Textes.  Danach:
* `db 5A40 6987`: die Codetabellen im Text (Mustertexte 5A40-631B, `optab`-Saetze 631C-6987).
* 18 `dwc`-Zeilen: Schalttabellen der Daten (Hash-Schalter `DIV RR2,#n` haben n Eintraege, Bereichsschalter `SUB/CP #k ; JR UGT` k+1): 7624 (4), 762C (0x5B), 76E2 76E6 (je 2), 76EA (8), 7B4C (11), 7B62 7B84 (17), 7BA6 (8), 7C6E (4),
  7C76 (9), 80CA (5), 80D4 (8), 80E4 (2), 80E8 (3), 80EE 80F2 (je 2), 80F6 (10).  Aufeinanderfolgende Tabellen schliessen lueckenlos aneinander an (Gegenprobe der Zaehlung).  Damit 73,3 % Code, 8609 Befehle.
* 3 `code`: 3578 und 4462 (`JP` hinter einem `JR`, nie erreicht), 7588 (`brk`, ohne Aufrufer; Teil des libc-Gliedes `sbrk`).
* 15 `code` in `doprnt` (Tabelle Formatbuchstabe/Ziel bei 8A3E, wie bei `c0`) und 5 `ohne` (7400 7408 740A 7472 7474: Zeigerkonstanten, die mitten in Befehle fallen).
* Atof: 57CE-5A40 wird als Code erkannt (EPA-Befehle dekodiert der Disassembler); Datenmitte 75A6 ist ein Operand, keine Marke.

**libc-Teil** (`userspace/libc_alt/c1.members` + `.zusatz`): 30 Glieder, davon 3 G (`flsbuf`, `endopen`, `malloc`: `bau c1` 0 Glieder abweichend).  Handkorrekturen (`zusatz`):
* `doprnt code=6C2C,6C32,6C48 data=8A3E:8A88` (Tabelle Formatbuchstabe/Ziel und `null` an 8A3E, 74 B; Sprungziele wie `c0` 2 B spaeter als automatisch).
* `data` (`__iob@8A88`, `__lastbu@8B28`; `printf`/`flsbuf` greifen auf iob+14 = 8A96 zu) und neues datenloses Glied `ctype` (`__ctype_@8B2A`, 130 B bis 8BAC; *Annahme*: von `atof` gebraucht, dessen Text nicht in den Gliedern steht).

## Teil 2: die Codetabellen (`table.s`, `cvopt`)

**Entscheidung (Annahme: so entstand die Tabelle im Original; belegt ist nur das Ergebnis):** weder die Z8000-`table.s` noch das MUTOS-`cvopt` sind vorhanden.  Das c1-Abbild hat aber genau das V7-Muster (Mustertexte, 6-Byte-`optab`-Saetze, `struct table`
in den Daten).  Deshalb:
* `tools/userspace/cvopt_z8k.py` ist eine Portierung von `original/unix-v7/usr/src/cmd/c/cvopt.c` (gleiche Zustandsmaschine) und schreibt statt PDP-11-`as` das Modul im Dialekt des MUTOS-`as` (`BV`/`WV`/Marken); es laeuft auf dem Host
  (`uebersetzen`), weil `cvopt` im Gast nicht gebraucht wird; das Ergebnis `userspace/c1/table_z8k.s` ist eingecheckt (Test `tests/test_userspace_wk_w6.py` prueft, dass es die Uebersetzung von `table.s` ist).
* `userspace/c1/table.s` (1122 Zeilen) ist die **ruecklesene** Quelle im V7-Format (`quelle`: Umkehrung von cvopt auf dem Abbild; Kommentare, Gruppen- und Vorlagennamen `crNN`/`efNN`/`ccNN`/`spNN`/`tNNNN` erfunden; jede Vorlage steht dort, wo ihre
  Zeichenkette im Abbild beginnt; spaetere Verwender nutzen die V7-Klammerform `%[tNNNN:]` / `% [tNNNN]`).
* Beleg (gemessen): `cvopt_z8k.py pruefen` -- Modell-Text 3912 B (5A40-6988) und Modell-Daten 400 B (88AE-8A3E, `regtab` 47, `efftab` 20, `cctab` 27, `sptab` 4 Eintraege) **gleich dem Abbild**; zusaetzlich Gastlauf: `as -u` uebersetzt
  `table_z8k.s` ohne Meldung zu Text 3912 B, Daten 400 B, und alle Worte gleich dem Abbild ausser den Relokationsworten (Wert = Abbildwert - 5A40; 0 Abweichungen).

Abweichungen des Z8000-Formats von V7-`cvopt` (alle gemessen am Abbild; im Kopf von `cvopt_z8k.py`):
1. `X Y T` setzen `snlflg` nicht mehr (die Zeichenketten behalten das `\n` nach Zeilen mit diesen Buchstaben).
2. Kein abschliessendes Nullwort am Dateiende (die letzte Gruppe laeuft unmittelbar in `freopen` bei 6988; V7 schreibt `0`).
3. Der Gradbuchstabe `c` nimmt Typbuchstaben (`%cl`: Grad 8, Typ 8); zusaetzliche Gradbuchstaben fuer die Werte 6, 7, 11 (`y`, `x`, `q`, **Namen erfunden**); `i` (12) und `1` (5) kommen im Abbild nicht vor.
4. Tabelleneintraege nennen Gruppen auch **mitten in einer Gruppe** (cctab: 16 Eintraege auf 692C); V7 legt vor jeder Marke ein Nullwort (`=.+2; 0`), hier steht dafuer die Zeile `name=.` (Marke ohne Nullwort).
5. Literale `S`/`R`/`%`/`\` brauchen den Fluchtstrich `\x` (das Abbild enthaelt Bytes `S`; V7 behandelt `S` immer als Teilbaum-Makro) -- *Annahme*: das Original-cvopt hat `S` anders buchstabiert.
6. Datenzeilen der Tabelle: `wv op,gruppe` (PLZ/ASM) statt `106.;\tcr106`.
Die Makrobuchstaben der Mustertexte entsprechen V7 (`A1 A2 B1 B2 BE BF C1 C2 F H R R1 S I`; Bytes `A B C D L P E F G H I J K M`; Bit 7 = vorangestelltes Tabulatorzeichen).  Der tote Zweig `M -> N` des V7-Kommentars ist falsch (V7 hat kein `case 'M'`).
Verbleibend fuer den Gesamtbau: `table_z8k.s` als Quelle zwischen `c13` und den libc-Gliedern in `userspace/c1/` einbinden (Teil 3).

## Teil 3: Gesamtbau (Stand: erster Durchlauf, **nicht abgeschlossen**)

* `userspace/c1/`: `c10.c c11.c c12.c c13.c c1.h` sind **unveraenderter V7-Text** (Platzhalter fuer die Rekonstruktion), dazu `atof.s` (Kopie von `userspace/libc/atof.s`, EPA-Code, vom Gast-`cc` nicht uebersetzbar) und `table_z8k.s`;
  `link.txt` legt die Linkreihenfolge fest (`c10 c11 c12 c13 atof table_z8k`, danach `libc_alt`); `pipeline.py quelle_lesen` liest `link.txt` (neu, auch `.s`).
* `alles c1 --c2emu --libc alt --ist neu_c2` (13 min): V7-Text uebersetzt und bindet.  Gemessen: text 25036 (Original 30176), data 4250 (5582), bss 54 (1832); Befehle original 7970, gebaut 6747, davon 4022 uebereinstimmend,
  853 Differenzbloecke (Bericht `userspace/c1/work/bau/neu_c2.bericht`).  Der Unterschied ist erwartungsgemaess gross: die V7-Codeausgabe schreibt PDP-11-Mnemonik, nicht Z8000.
* **Bindefehler behoben (gemessen):** die Ursache lag nicht an Symboltyp oder Abschnitt von `table_z8k.s` (identisch mit `libc_alt/c1/data.s`: `I` / `G` / `name L` / `name:`), sondern in `pipeline.py cmd_bau`: die zweite Runde (`--c2emu`) baute
  ihre Modulliste nur aus den `.s` der `.c`-Module (`cc -S`); `atof.s` und `table_z8k.s` fehlten dort, daher `Undefined: _regtab _efftab _cctab _sptab _end` (`_end` kommt aus `sbrk`, das nur ueber die Tabellen-Module hereingezogen wurde).  Jetzt werden `.s`-Module aus `link.txt` unveraendert (ohne c2-Modell) an ihrer Stelle der Linkreihenfolge in die zweite Runde uebernommen; ohne `.s` in der Quelle bleibt der Pfad unveraendert.
  Ergebnis: bindet, 33614 B (text 28948, data 4650, bss 1126; Original 30176/5582/1832), 6746 Befehle gegen 7970, 4027 gleich, 853 Bloecke, 383+193 s.
* Danach je Funktion `c10.c..c13.c` an das Binary angleichen (Z8000-Codeausgabe, `opdope` 14 Eintraege, 12 Nicht-V7-Funktionen, Registervariablen wie in `wk_w4.md`, `c13.c`-Daten gegen 75E0..).
  **Keine** Funktion ist bisher rekonstruiert; keine neuen c2-Regeln (R230-R259 unbenutzt).

## Teil 4: Regression und c10.c (W6b)

**Regression (gemessen, sequentiell im Gast, nach der `pipeline.py`-Aenderung):** `sh` (`alles sh --c2emu --variante v7fix`), `ed`, `tar`, `cc`, `ld` (`--ist neu_c2_s`) und `c0` (`--ist neu_c2`) ganzdatei `cmp`-gleich dem Original.  Nur `c1` hat `link.txt`; fuer alle anderen bleibt der Pfad unveraendert.

**c10.c (Stand: neu_c2 gebaut 33764 B, 6743 Befehle gegen 7970, 4080 gleich, 844 Bloecke; vorher 4027/853).**  Funktionen, die bis auf Datenadressen (Layout noch unvollstaendig) befehlsgleich sind:
* `main` (0030): Z8000-Modulkopf mit 6 `printf` (nur das erste mit `modname`), kein `fltused`, `printf("end %s\n", modname)`; die Verschmelzung der Stack-Slots macht das c2-Modell von selbst.  Offen sind nur Speicheradressen (`coremax` usw.: BSS-Layout).
* `comarg` (1B3E): Strukturkopie als Z8000-Code (`ld r0,#n` / `dec SP` / `dec rK` / `lddr`), kein `nstack`, kein `lsptab`-Zweig, `flagp` unbenutzt; `register i` vor `size` (belegt r11, `size` liegt in r10).  Nicht-V7-Hilfsfunktion `zreg` (21D6, Name *Annahme*; Registernummer 0..5 -> 2..7, 6..7 -> 0..1) am Dateiende (Binary: nach den c10-Funktionen, Reihenfolge noch nicht angeglichen).
* `sdelay` (1A22): nur `PLUS` wird verfolgt (kein `STAR`); 1 Block offen: Original `TEST R2` hinter `LD R12,R2`, gebaut `TEST R12` (R5-Modell; Quellvariante ungeklaert).
* Neue Daten: `char modname[] "c_"` (7B3E, 3 Bytes + Fuellbyte; *Annahme*: steht in `c11.c` vor `max`, da die Daten dort beginnen), in `c1.h` deklariert.
**Offen (gemessen am Listing, nicht rekonstruiert):** `match` (0186) ist im Original anders aufgebaut (Sonderfall `LONG` mit Operatorliste `+ * , I H J . L - K`, andere Bitmasken); 9 Null-initialisierte Int-Flags in den Daten (760C, 760E, 7610, 7614, 7616, 761A..7622) und 5 weitere ab 7B42; `rcexpr`, `cexpr`, `doinit`, die uebrigen Nicht-V7-Funktionen (1EFC, 1F66, 2028, 21FC, 2228); der V7-`movreg` existiert im Original anderswo (die Zuordnung 2104 -> `movreg` ist falsch: 2104 druckt Registernamen `r%d`/`rr%d`/`f%d`/`rl%d`).  Keine neuen c2-Regeln.
