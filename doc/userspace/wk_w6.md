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
