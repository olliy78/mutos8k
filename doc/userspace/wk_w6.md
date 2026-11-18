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
