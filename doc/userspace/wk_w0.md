# W0 (Plan 52): Triage der Werkzeugkette `cc ld as cpp c0 c1 c2`, `libc.a`, `crt0.o`/`mcrt0.o`

Stand 2026-11-16, Branch `us-wk-w0`.  Nur Host (kein Gastlauf, kein Bau).  Alles *gemessen* (Befehl dabei), soweit nicht *Annahme*.
Quellen der Programme: Diskette `usr` (`bin/cc bin/ld bin/as lib/cpp lib/c0 lib/c1 lib/c2 lib/libc.a lib/crt0.o lib/mcrt0.o`), V7: `original/unix-v7/usr/src/cmd/{cc.c,ld.c,c/,cpp/}`.

## 0. Befehle und Ablage

    export K1520EMU=/home/olliy/projects/a5120emu
    python3 -I tools/userspace/pipeline.py holen NAME --platte usr --pfad bin/cc     # PROGRAMME-Eintrag: Platte usr, Quelle userspace/NAME (Verzeichnis, noch leer)
    python3 -I tools/userspace/pipeline.py karte NAME --ablegen                      # k.txt, NAME.lst, NAME.namen, NAME.strings
    python3 -I tools/userspace/wk_w0.py zuordnung NAME --ablegen                     # userspace/NAME/v7zuordnung.txt (neu, dieses Dokument)
    python3 -I tools/userspace/wk_w0.py tabellen                                     # opdope, c1-/c2-Tabellen (Abschnitt 3b, 3c)
    python3 -I tools/userspace/wk_w0.py libc                                         # Gliederliste libc.a (Abschnitt 3d)

`PROGRAMME` bekommt sieben Zeilen (`"cc": ("usr", "bin/cc", "userspace/cc", [])` usw., Pfade `bin/cc bin/ld bin/as lib/cpp lib/c0 lib/c1 lib/c2`); die Quelle ist wie bei `adb` ein Verzeichnis,
das noch keine Quelle enthaelt -- `holen`/`karte`/`--check` brauchen die Quelle nicht (gemessen: alle sieben laufen).  Neben die Karten kommt je Programm `v7zuordnung.txt`
(Funktionsliste mit V7-Zuordnung, erzeugt von `tools/userspace/wk_w0.py`).  `karte_extra.txt` (`ohne ADDR`) wurde nur dort angelegt, wo es eindeutig begruendet ist (Abschnitt 1).

## 1. Karte und `--check`

| Programm | Datei (B) | Einstiege | Ueberlappung | Marken mitten im Befehl | nicht kanonisch | unerreicht | `--check` |
|----------|-----------|-----------|--------------|--------------------------|-----------------|------------|-----------|
| cc  | 6536  | 323 (324 ohne Extra) | 0 (1) | 0 (1) | 0 | 13,2 % | OK mit `karte_extra.txt` (`ohne 0102`) |
| ld  | 10726 | 527 (529) | 0 (2) | 0 (2) | 0 | 12,2 % | OK mit `ohne 01B6`, `ohne 0400` |
| cpp | 16382 | 611 (612) | 0 (1) | 0 (1) | 0 | 20,5 % | OK mit `ohne 2624` |
| c0  | 26826 | 1552 | 16 | 12 | 2 | 13,4 % | FAIL (nicht erzwungen) |
| c1  | 35774 | 2080 (1 ungueltig) | 119 | 86 | 12 | 27,6 % | FAIL (Tabellen im Text, s. 3b) |
| c2  | 18976 | 1051 | 25 | 8 | 5 | 12,6 % | FAIL (nicht erzwungen) |
| as  | 35814 | 1652 | 66 | 59 | 3 | 40,1 % | FAIL (Daten im Text) |

Die `ohne`-Zeilen sind die "Marken mitten im Befehl", die `z8kdis --vorschlaege` in ein Adresswort eines Zweiwortbefehls setzt (cc: `0100 JP NZ,L02F0`, Marke 0102 liegt im Adresswort;
gleiche Form wie bei `tar`/`mt`).  Bei c0 (12 Marken) und c2 (8) genuegten die entsprechenden `ohne`-Zeilen **nicht** (gemessen: Ueberlappung 4 bzw. 19 bleibt); dort sind es Tabellen
und Daten im Text.  Nach dem Prinzip "nicht erzwingen" wurden diese Zeilen wieder entfernt.  Die vier FAIL-Programme verhalten sich wie `adb` (`cmd_s5.md`).

## 2. Messtabelle

Kopf aus `pipeline.py holen` (text/data/bss, `flag 1`, `syms 0`); "Funktionen im Eigenteil" = `call csv`-Einstiege und Aufrufziele zwischen 0030 (Ende `crt0`) und dem ersten libc-Glied
(`wk_w0.py`); "Funktionen in der Karte" = Zeile `functions (call targets)` von `karte` (enthaelt die libc-Funktionen).  Eigenteil/libc in Bytes des Textes.

| Programm | text | data | bss | Funktionen in Karte | im Eigenteil | Eigenteil (B) | libc-Bereich (B) | davon als Glied der mitgelieferten libc.a erkannt (B) | Glieder (stark/alle) |
|----------|------|------|-----|---------------------|--------------|---------------|-------------------|---------------------------------------------------------|----------------------|
| cc  | 5902  | 618  | 2660  | 44  | 10 | 2850  | 3004 | 1144 | 20/22 |
| ld  | 9686  | 1024 | 35924 | 72  | 34 | 6524  | 3114 | 742  | 22/26 |
| cpp | 13202 | 3164 | 17780 | 61  | 25 | 9884  | 3270 | 1250 | 22/23 |
| c0  | 23614 | 3196 | 12074 | 111 | 72 | 18912 | 4654 | 2118 | 24/27 |
| c1  | 30176 | 5582 | 1832  | 104 | 71 | 22430 | 7698 (davon ca. 4,9 KB Tabellen im Text, 0,6 KB `atof`) | 1522 | 20/21 |
| c2  | 16976 | 1984 | 3296  | 83  | 51 | 13662 | 3266 | 1628 | 21/22 |
| as  | 22092 | 13706 | 17744 | 99 | 70 | 18776 | 3268 | 1630 | 21/22 |

* `crt0`: die ersten 0x30 Byte jedes der sieben Programme sind der Text von `lib/crt0.o` (48 B), gemessen: nur die drei relokierten Woerter (0x20 `_environ`, 0x24 `_main`, 0x2C `_exit`) unterscheiden sich.
* Nur ein Teil des libc-Bereichs stimmt mit den Gliedern der **mitgelieferten** `libc.a` ueberein (742 bis 2118 B von 3004 bis 7698 B); der Rest ist wie bei `init` (`libc_alt.md`) ein anderer Stand
  der Bibliothek bzw. des c2.  Das Muster `doprnt`/`strout`/`filbuf` stimmt mit der Diskette ueberein (anders als bei `init`, wo `doprnt` ohne Gleitkomma ist) -- Hinweis auf den Bibliotheksstand der Bauzeit.
* Erkannte Glieder: cc `fprintf printf doprnt cuexit isatty stty access close creat execv fork ioctl lseek sbrk signal unlink wait write cerror csv (+getpid, fakcu schwach)`;
  ld `printf cuexit isatty stty strncmp access chmod close creat fstat ioctl link lseek open read sbrk signal umask unlink write cerror csv`;
  as `freopen fopen fprintf sprintf filbuf doprnt strout findiop cuexit isatty stty close creat ioctl lseek open read sbrk write cerror csv`;
  cpp `fopen fprintf printf sprintf doprnt findiop cuexit isatty stty strcat strcmp strcpy close creat ioctl lseek open read sbrk write cerror csv`;
  c0 `freopen fopen fprintf filbuf setbuf doprnt gcvt strout findiop cuexit modf isatty stty strncmp close creat ioctl lseek open read sbrk write cerror csv`;
  c1 `freopen fprintf printf filbuf doprnt strout cuexit abort isatty stty close creat ioctl lseek open read sbrk write cerror csv`;
  c2 `freopen fprintf printf sprintf filbuf doprnt strout cuexit abort isatty stty close creat ioctl lseek open read sbrk write cerror csv` (Listen je `NAME.namen`).
* Die Zahl der Eigenteil-Funktionen hat im c1 eine Besonderheit: `atof` (0x57CE-0x5A40, EPU-Befehle `EXT4F/EXT8E`) steht **vor** dem Text der Codetabellen und wird von der Signatursuche nicht gefunden
  (`LIB0` in `wk_w0.py` ist von Hand auf 0x57CE gesetzt); danach folgen Tabellen im Text (0x5A40-0x6988) und erst ab 0x6988 (`freopen`) die erkannten libc-Glieder.  Ob `atof/ldexp/modf` aus `libc.a` stammen
  oder eigene Objekte sind, ist offen (*Annahme*: libc, anderer Stand).

## 3. V7-Zuordnung (Reihenfolge = Datei-/Linkreihenfolge)

Verfahren (`wk_w0.py`, Heuristik, **Beleg, kein Beweis**): Funktionen des Binaries (Einstiege) und Funktionen der V7-Quellen (K&R-Scanner ohne Praeprozessor) werden in der Reihenfolge ausgerichtet
(dynamische Programmierung) mit den Merkmalen gemeinsame Zeichenketten, gemeinsame libc-Aufrufe (`putc/getc` = `flsbuf/filbuf`, Makros der V7-Quelle ausgenommen), Bytes je Quellzeile und Zahl der Aufrufe
eigener Funktionen.  Klassen je Paar: **V7 gleich** (Zeichenketten, libc-Aufrufe und Zahl eigener Aufrufe gleich -- *Annahme* "wahrscheinlich unveraendert", nicht bewiesen), **V7 gleich\*** (wie gleich, aber Zahl der
Aufrufe eigener Funktionen abweichend: Makro/Inline), **V7 abweichend** (Zeichenkette oder libc-Aufruf unterscheidet sich: V7 geaendert, oder falsche Zuordnung), **nicht V7** (Eigenfunktion ohne V7-Gegenstueck).
Die Klasse sagt nichts ueber Gleichheit des erzeugten Codes; sie ordnet nur die Arbeit (welche Funktionen sind eine Rekonstruktion aus dem Listing).  Je Zeile Begruendung in `userspace/NAME/v7zuordnung.txt`.

| Programm | Funktionen (Eigenteil) | V7-Funktionen | gleich | gleich\* | abweichend | nicht V7 | V7 ohne Gegenstueck im Binary |
|----------|------------------------|---------------|--------|----------|------------|----------|--------------------------------|
| cc  | 10 | 10 | 7 (514 B) | 0 | 3 (2336 B) | 0 | -- |
| ld  | 34 | 37 | 30 (4950 B) | 0 | 4 (1574 B) | 0 | `record restore cp8c` |
| cpp | 25 | 26 | 12 (978 B) | 1 (624 B) | 11 (7334 B) | 1 (948 B, `yyparse`) | `trmdir` (+ ein spurious Treffer `stsym`) |
| c0  | 72 | 72 | 53 (7374 B) | 13 (8332 B) | 6 (3206 B) | 0 | -- |
| c1  | 71 | 62 | 31 (4170 B) | 10 (5804 B) | 18 (11346 B) | 12 (1110 B) | `oddreg xlongrel popstk` |
| c2  | 51 | 45 | 20 (3128 B) | 15 (3992 B) | 8 (5716 B) | 8 (826 B) | `copy addsob` |
| as  | 70 | -- (kein V7) | -- | -- | -- | 70 (18776 B) | -- |

### cc (10/10 Funktionen, V7-Reihenfolge exakt)
`main idexit dexit error getsuf setsuf callsys copy nodup cunlink` in V7-Reihenfolge (`cc.c`).  Abweichend: `main` (Pfade `/usr/lib/c0 c1 c2 cpp crt0.o mcrt0.o`, `/usr/bin/as`, `/usr/bin/ld` statt `/lib/..`;
die V7-Optionen `-B -P -X -f -l2 -lfpsim` und ihre Meldungen fehlen im Binary; Aufrufe `close`/`unlink` statt `strcpy/strcat`), `error` (kein `flsbuf`-Aufruf), `copy` (kein `malloc`; Aufrufzahl 3/2).
Erwartung (Plan 52) "V7 `cc.c` mit geaenderten Pfaden" ist gemessen **teilweise** richtig: die Funktionsliste ist V7, `main` ist gekuerzt.

### ld (34 von 37)
V7-Reihenfolge exakt.  Es fehlen `record`, `restore` (Overlay-Verwaltung, in V7 ueber Option `-v`; die V7-Meldung `-v: arg missing` fehlt im Binary) und `cp8c`.  `main`/`endload`: kein `atoi`-Aufruf (passt zu fehlendem `-v`).
Neu: `load2td` enthaelt `CALLR : illegal destination` / `CALLR : out of range` (Relokation Z8000); `setupout`: kein `mktemp`-Aufruf (Name `/tmp/ldaXXXXX` fest).  *Annahme*: V7-`ld.c` ohne Overlay, mit CALLR-Behandlung.

### cpp (25: 24 V7-Funktionen + `yyparse`)
Reihenfolge `cpp.c` (22 Funktionen), `yylex.c` (`yylex`, `tobinary`), dann `yyparse` (0x2318, 948 B; das Ergebnis von `cpy.y`, Abschnitt 3a).  `trmdir` fehlt (V7: Verzeichnisname beim `#include`), `intss`/`inquire`-Aufrufe fehlen
in `main`.  Abweichend u. a. `main` (vordefinierte Namen `unix`, `U8000` statt `pdp11 ... gcos ibm`; 18 V7-Zeichenketten fehlen), `pperror`, `subst` (`%s: argument mismatch` neu), `dodef` (`%s redefined` neu), `doincl`.

### c0 (72/72, `c00.c`..`c04.c` in dieser Reihenfolge)
Blockgrenzen (Adresse): `c00.c` 0030-13B8 (12 Funktionen), `c01.c` 13B8-2094 (16), `c02.c` 2094-3250 (14), `c03.c` 3250-4154 (13), `c04.c` 4154-4A10 (17); Anzahl je Datei **gleich** der V7-Anzahl.
`c05.c` hat in V7 keine Funktionen, nur die Tabelle `opdope`; sie steht in den Daten bei 0x6638 und ist **wortgleich** mit V7 (111 von 111 Eintraegen, `wk_w0.py tabellen`).
Abweichend: `symbol` (kein `filbuf`; Pfad-/Zeichenkettenteil), `putstr`, `getcc` (neu `No character constant`), `mapch`, `blkend` (neu `names %.8s and %.8s conflict`, `strncmp`), `outcode` (kein `flsbuf`/`ferror`).
Hoechste V7-Naehe aller Programme (alle 72 Funktionen in V7-Reihenfolge); "wenige Aenderungen" (Plan 52) bestaetigt.

### c1 (71, V7-Rahmen `c10.c c11.c c12.c`, `c13.c` nur Tabellen)
Reihenfolge `c10.c` (14 V7-Funktionen) 0030-2228, `c11.c` (33) 229E-3FD6, `c12.c` (15) 3FD6-57CE; die Einzelzuordnung ist unsicherer (viele neue Funktionen dazwischen).  12 Funktionen ohne V7-Gegenstueck (u. a. bei 1C42,
1C74, 1EFC, 1F66, 21D6, 21FC, 22F4, 2DAE, 2EE4, 3C2A, 3C58, 3CAA -- *Annahme*: Z8000-Zusaetze, z. B. Langzahl-/Registerbehandlung); 18 abweichend, weil sie Maschinencode ausgeben (`printf`-Vorlagen der PDP-11 sind durch Z8000 ersetzt).
Das Programm ist V7-Rahmen mit **umgeschriebener Codeausgabe**; groesster Rekonstruktionsaufwand der drei Passe.

### c2 (51, `c20.c` dann `c21.c`)
V7-Funktionen in V7-Reihenfolge, dazwischen 8 neue Funktionen (13EA, 1430, 278C, 315C, 322E, 34E4, 3504, 3536); `addsob`/`copy` (PDP-11 `sob`) fehlen.  `rmove` (3232 B) ist die groesste Funktion.
Zuordnung im c2 unsicher (die Zeichenkettenmerkmale tragen kaum: V7-Befehle sind durch Z8000-Mnemonik ersetzt; `check` ruft `abort` nicht mehr auf).  Optabelle: Abschnitt 3c.

### as (70, nicht V7)
Erster "Funktionsblock" ist `yyparse` (0x0030-0x09D4, 2468 B, mit Aktionen), danach Scanner/Parser-Hilfen, Ausdrucksauswertung (`illegal expression`, `unimplemented operation in exprdo`), Datei-/Objektausgabe (`fatal output error`,
`asm.out`), Symboltabelle (`symbol table overflow`).  Zeichenketten: PLZ/ASM-Dialekt (`plzlex`, `$SECTION`, `$NONSEGMENTED`, `BVAL WVAL LVAL`, Hunderte von Mnemonik- und Direktivennamen im Datenteil: 360 Zeichenketten).
Funktionsliste mit Adressen, Groessen, libc-Aufrufen und Meldungen: `userspace/as/v7zuordnung.txt`.  Die V7-`as`-Quellen (`original/unix-v7/usr/src/cmd/as/as*.s`) sind PDP-11-Assembler und haben keine Entsprechung.

## 3a. yacc-Frage (cpp, as)

* **Skelett gleich.**  Beide Binaries enthalten die Literale des V7-`yaccpar` in dessen Reihenfolge: `state %d, char 0%o` (yydebug), `yacc stack overflow`, `syntax error`, `error recovery pops state %d, uncovers %d`,
  `error recovery discards char %d`, `reduce %d` (`strings -n 5 NAME.orig`; cpp Zeilen 63-68, as 13-18).  `userspace/ergaenzung/yacc/yaccpar` ist wortgleich mit `original/unix-v7/usr/lib/yaccpar` (`cmp`).
  Beide `yyparse` haben denselben Rahmen `SUB R15,#0130` = `short yys[150]` (YYMAXDEPTH 150) + 4 B, `YYFLAG` -1000 (`CP R10,#FC18`), dieselbe Registerbelegung (R12 yystate, R11 yyps, R9 yypv).
  Normalisiert (Adressen, JR/JP) stimmen 206 von 314 Befehlszeilen des cpp-`yyparse` mit dem `as`-`yyparse` ueberein (`difflib`, Skript im Gespraech); der Rest sind die Aktionen und der (bei `as` wegen der Funktionsgroesse
  hinter den Rumpf verlegte) Prolog `JP L09CC ... SUB R15`.  Diese Prologform hat der Gast-`cc` auch bei bereits bytegleichen Programmen (`sh`, `tar`: `CALL csv` gefolgt von `JP`), ist also kein Hinweis auf einen anderen Compiler.
* **Tabellen von cpp: gleich dem V7-yacc.**  Experiment auf dem Host (nicht im Repository): V7-`yacc` (`original/unix-v7/usr/src/cmd/yacc/y1.c-y4.c`, `files` mit `PARSER "yaccpar"`) mit
  `gcc -std=gnu89 -w -DWORD32 -o yacc y1.c y2.c y3.c y4.c` uebersetzt, auf `original/unix-v7/usr/src/cmd/cpp/cpy.y` angewandt: `yyexca 70 yyact 363 yypact 62 yypgo 4 yyr1 30 yyr2 30 yychk 62 yydef 62` Worte
  (`YYLAST 363`).  Verglichen mit den Daten von `cpp` ab 0x3858 (die Adressen stehen im `yyparse`: `yyexca` 3858, `yyact` 38E4, `yypact` 3BBA, `yychk` 3CB6, `yydef` 3D32): **alle acht Tabellen wortgleich** (683 Worte, auch die Reihenfolge
  im Speicher = y.tab.c-Reihenfolge).  Damit gilt: Das Original-`cpp` wurde mit V7-`cpy.y` und einem V7-yacc erzeugt (Tabellen) -- ob der **Gast-yacc** (Groessenklasse `SMALL`, 16-Bit-`int`) dieselben Tabellen liefert, ist
  *Annahme* (gleicher Algorithmus; Beleg offen: W2 muss `cpy.c` im Gast erzeugen und die Tabellen vergleichen).  Die offene Frage des Plans (Abschnitt 2/6) "erzeugt V7-yacc die Original-Tabellen?" ist fuer `cpp` **beantwortet: ja**.
* **as:** Grammatik nicht vorhanden.  Tabellen im Binary (aus dem `yyparse`-Code abgelesen und auf Konsistenz geprueft): `yyexca` 564E (14 Worte), `yyact` 566A (737 = `YYLAST` 0x2E1), `yypact` 5C2C (268 Zustaende), `yypgo` 5E44 (77 Nichtterminale),
  `yyr1` 5EDE und `yyr2` 6036 (je 172 Produktionen), `yychk` 618E, `yydef` 63A6 (je 268), Ende 65BE; zusammen 1976 Worte = 3952 B.  Ein V7-`yacc`-Lauf waere nur mit einer rekonstruierten `.y`-Datei vergleichbar (W7: Grammatik aus
  `yyr1/yyr2/yychk` und den `case`-Rumpf-Aktionen zurueckgewinnen -- *Annahme*: sehr aufwendig, `A` ist wahrscheinlich).  Der Scanner `plzlex` ist ein Lex-Scanner (Meldung `bad switch in plzlex returning from yylook`; *Annahme*).

## 3b. c1: Codetabellen

* Format wie V7 (`c1.h`): `struct table {int tabop; struct optab *tabp;}` in den **Daten** (`regtab` 0x88AE 47 Eintraege, `efftab` 0x896C 20, `cctab` 0x89BE 27, `sptab` 0x8A2C 4; Zeilen mit `op, ptr`, Abschluss 0),
  `struct optab {char tabdeg1, tabtyp1, tabdeg2, tabtyp2; char *tabstring;}` (6 B, Zeiger zuletzt) in den **Text**: 41 Felder ab 0x631C bis 0x6988 (266 Datensaetze, 1596 B), die Mustertexte (`tabstring`, 141 verschiedene
  Zeiger, 139 Texte mit Makrobuchstaben mit gesetztem Bit 7 wie `cvopt` sie erzeugt: z. B. `4D 27 4C C9 2C 42 0A`) in 0x5A40-0x631C (2268 B).  V7 `table.s`: `regtab` 50, `efftab` 14, `cctab` 26, `sptab` 7 Zeilen
  (gezaehlt `\t<n>.;`) -- die Z8000-Tabellen haben andere Eintragszahlen, gleiche Struktur.  `cvopt`-Format also **erhalten**; eine Z8000-`table.s` im V7-Format ist rekonstruierbar (Annahme, W6): `cvopt` ist deterministisch,
  die Mustertexte stehen im Binary.
* `opdope` (V7 `c13.c`, 117 Eintraege) bei 0x8188: 103 von 117 Eintraegen gleich V7, 14 verschieden (Index 27, 28, 81-88, 91, 92, 107, 108; `wk_w0.py tabellen`).  `maprel/notrel` liegen am Datenanfang (0x75E0).
* EPU-Befehle (`EXT4F/EXT8E`, Gleitkomma) stehen in 80 Zeilen von `c1.lst`: 25 im Eigenteil (ab 0x1DBA, in den Funktionen bei 1C74/1DBA, *Annahme*: Konstantenverarbeitung), der Rest in `atof`/libc.  Der Gast-`cc` muss also EPU-Befehle erzeugen koennen (Gleitkomma `-f`).

## 3c. c2: Z8000-Befehlstabelle

`optab` (V7 `c20.c`: `struct optab {char *opstring; int opcode;}`) in den Daten bei 0x4286, 75 Eintraege (V7: 51 Zeilen `\t"..."` in `c20.c`, gezaehlt), davor bei 0x4252 die Bedingungsnamen `eq ne le ge lt gt c ugt ule uge pl mi` (Nummern 0..11):
`jr:3`, `jp cc` (`jp eq:0002 .. jp mi:0B02`, Klasse 2 = CBR, Bedingung im High-Byte), `jr cc` (Klasse 1), `jp:4`, `djnz:34h`, `E:8`, `ld:0A ldk:37 ldir:35 lddr:36 clr:0B com:0C inc:0D dec:0E neg:0F test:10 sra:11 sla:12 exts:13
cp:14 add:15 sub:16 or:17 and:18 set:29 res:2A bit:2B mult:1A mul:26 ldil:09 cpfx:28 cpzx:27 setmode:31 resmode:39 ldctl:38 div:1B ex:2C pop:2D push:2E srl:32 sll:33 sdl:19 sda:1C xor:1D`, `$SECTION c_p:1E`, `$CODE:1F`,
`$SECTION c_d:20`, `$SDEFAULT:21`, `$SECTION BSS_B:22`, `$EVEN:23`, `!:25`, `call:2F`, `end c_:30` (`wk_w0.py tabellen`).  Die Nummern 0x0A-0x1D belegen dieselben Slots wie V7 `c2.h` (dezimal `MOV 10 CLR 11 COM 12 INC 13 DEC 14 NEG 15 TST 16 ASR 17 ASL 18 SXT 19 CMP 20 ADD 21 SUB 22 .. MUL 26 DIV 27 ASH 28 XOR 29 TEXT 30`; gemessen: `ld=0A clr=0B ... exts=13 cp=14 add=15 sub=16 mult=1A div=1B sda=1C xor=1D`;
`BIT/BIC/BIS` 23-25 sind `or/and/sdl`), die Sprunggruppe (1-4 `jr`/`jp`) und alles ab 0x1E (Sektionen, `call`, `end`) ist neu belegt.  c2 ist also **V7-`c2.h` mit Z8000-Erweiterung** (*Annahme*: Nummernplan aus V7 uebernommen).  Die Funktion mit den Befehlsmustern (Gegenprobe der c2-Regeln, W5) ist wahrscheinlich `rmove` (3232 B, 107 Aufrufe eigener Funktionen).

## 3d. libc.a (140 Glieder, 71914 B)

`python3 -I tools/userspace/wk_w0.py libc`; Archiv `0177545` big endian (Magic 0xFF65), 140 Glieder, Summe Text 17996 B, Daten 2534 B, bss 2746 B.  Reihenfolge im Archiv (`index name text/data/bss`; `a` = es gibt eine
Quelle in `userspace/libc_alt` (`.s` aus dem Programmabbild oder C), `T` = von einem der sieben Toolchain-Programme gebunden):

```
  0 getgrgid    40/  0/   0 a-     1 getgrnam    46/  0/   0 --     2 getgrent   298/ 18/ 722 --
  3 getpass    282/ 14/  10 a-     4 getpwnam    44/  0/   0 a-     5 getpwuid    40/  0/   0 a-
  6 getpwent   318/ 20/ 532 a-     7 timezone   138/118/  10 a-     8 fgetc       66/  0/   0 a-
  9 fputc       68/  0/   0 --    10 getchar     56/  0/   0 --    11 putchar     56/  0/   0 --
 12 popen      384/ 14/  40 --    13 freopen     34/  0/   0 aT    14 fgets      114/  0/   0 a-
 15 fputs       80/  0/   0 a-    16 getpw      232/ 14/   2 --    17 ftell      188/  0/   0 a-
 18 rew         86/  0/   0 a-    19 rdwr       226/  0/   0 a-    20 system     154/ 14/   0 a-
 21 fopen       28/  0/   0 aT    22 fdopen     122/  0/   0 --    23 scanf      132/  0/   0 a-
 24 doscan    1876/166/   0 a-    25 fprintf     52/  0/   0 aT    26 gets       106/  0/   0 --
 27 getw       126/  0/   0 --    28 printf      48/  0/   0 aT    29 puts       120/  0/   0 a-
 30 putw       110/  0/   0 --    31 sprintf    106/  0/   0 aT    32 ungetc      88/  0/   0 a-
 33 filbuf     244/  0/  20 aT    34 setbuf      76/  0/   0 aT    35 doprnt     474/ 74/   0 aT
 36 fltpr      320/  4/   0 --    37 gcvt       418/  0/   0 -T    38 ecvt       602/ 24/  80 --
 39 strout     294/  0/   0 aT    40 flsbuf     818/  0/   0 a-    41 endopen    290/  0/   0 a-
 42 findiop     40/  0/   0 aT    43 clrerr      26/  0/   0 --    44 data         0/162/   0 a-
 45 cuexit      14/  0/   0 aT    46 execvp     396/ 32/   0 a-    47 getenv     112/  0/   0 a-
 48 getlogin   130/ 10/  20 a-    49 perror     122/ 20/   0 a-    50 sleep      138/  0/   6 a-
 51 ttyslot    220/ 10/  32 --    52 ttyname    222/  6/  32 a-    53 abort       18/  0/   0 -T
 54 abs         28/  0/   0 --    55 atof       542/ 32/   0 --    56 atoi       114/  0/   0 a-
 57 atol       142/  0/   0 a-    58 crypt     1080/840/1130 a-    59 ctime     1150/118/  44 a-
 60 calloc      88/  0/   0 --    61 malloc     512/  0/  12 a-    62 errlst       0/662/   0 a-
 63 fakcu        2/  0/   0 aT    64 modf        34/  0/   0 -T    65 frexp      110/  0/   0 --
 66 ldexp       48/  8/   0 --    67 isatty      38/  0/   0 aT    68 l3         148/  0/   0 a-
 69 mktemp     122/  2/   0 a-    70 mon        256/  8/   4 --    71 nlist      328/  8/   0 --
 72 qsort      436/  0/   4 a-    73 rand        58/  4/   0 --    74 setjmp      64/  0/   0 a-
 75 stty        52/  0/   0 aT    76 swab        62/  0/   0 --    77 tell        28/  0/   0 --
 78 ctype_       0/130/   0 a-    79 index       38/  0/   0 a-    80 rindex      38/  0/   0 a-
 81 strcat      52/  0/   0 aT    82 strncat     66/  0/   0 a-    83 strcmp      54/  0/   0 aT
 84 strncmp     66/  0/   0 aT    85 strcpy      38/  0/   0 aT    86 strncpy     68/  0/   0 a-
 87 strlen      32/  0/   0 a-    88 access      22/  0/   0 aT    89 acct        20/  0/   0 --
 90 alarm       14/  0/   0 a-    91 chdir       20/  0/   0 a-    92 chroot      20/  0/   0 --
 93 chmod       22/  0/   0 aT    94 chown       22/  0/   0 a-    95 close       20/  0/   0 aT
 96 creat       22/  0/   0 aT    97 dup         32/  0/   0 a-    98 execl       22/  0/   0 a-
 99 execle      28/  0/   0 --   100 execv       20/  0/   0 aT   101 execve      16/  0/   0 --
102 exit        10/  0/   0 a-   103 fork        26/  0/   2 aT   104 fstat       22/  0/   0 aT
105 getgid      24/  0/   0 a-   106 getpid      12/  0/   0 aT   107 getuid      24/  0/   0 a-
108 ioctl       22/  0/   0 aT   109 kill        22/  0/   0 a-   110 link        22/  0/   0 aT
111 lock        20/  0/   0 --   112 lseek       22/  0/   0 aT   113 mknod       22/  0/   0 a-
114 mount       22/  0/   0 a-   115 nice        20/  0/   0 a-   116 open        22/  0/   0 aT
117 pause       10/  0/   0 a-   118 pipe        22/  0/   0 a-   119 profil      16/  0/   0 --
120 ptrace      26/  0/   0 --   121 read        22/  0/   0 aT   122 sbrk        60/  2/   0 aT
123 setgid      20/  0/   0 a-   124 setuid      20/  0/   0 a-   125 signal     142/  0/  40 aT
126 stat        22/  0/   0 a-   127 stime       24/  0/   0 a-   128 sync        10/  0/   0 a-
129 time        36/  0/   0 a-   130 times       14/  0/   0 --   131 umask       20/  0/   0 aT
132 umount      20/  0/   0 a-   133 unlink      20/  0/   0 aT   134 utime       22/  0/   0 a-
135 wait        26/  0/   0 aT   136 write       22/  0/   0 aT   137 cerror      14/  0/   2 aT
138 mcount      36/  0/   2 --   139 csv         28/  0/   0 aT
```

* **Schon abgedeckt:** 103 von 140 Gliedern haben in `userspace/libc_alt/*/*.s` oder `userspace/libc_alt/c/*.c` eine Quelle (Zaehlung: Dateinamen).  Das sagt **nicht**, dass die Quelle das Glied der mitgelieferten `libc.a`
  bytegleich erzeugt: die `.s` sind aus den Abbildern der *Programme* gewonnen (alter Bibliotheksstand, `libc_alt.md`, Herkunftsnachweis), der Rundlauf prueft nur die Zerlegung.  Fuer die Diskettenbibliothek ist noch nichts
  Glied fuer Glied gegen `libc.a` geprueft (W8).  Ohne Quelle: `getgrnam getgrent fputc getchar putchar popen getpw fdopen gets getw putw fltpr gcvt ecvt clrerr ttyslot abort abs atof calloc modf frexp ldexp mon nlist rand swab tell acct chroot execle execve lock profil ptrace times mcount` (37).
* **Von der Werkzeugkette gebunden:** 42 Glieder (Signaturtreffer in den sieben `NAME.namen`, stark oder schwach), davon 39 mit Quelle in `libc_alt`; ohne Quelle `gcvt` (c0), `abort` (c1, c2), `modf` (c0); dazu unbenannt `atof` (c1, EPU-Code, nicht per Signatur
  gefunden) und `ldexp/modf` (c1 0x57CE-0x5A40, *Annahme*).  Die Gleitkommakette `fltpr gcvt ecvt atof` ist die Luecke: c0 bindet `gcvt`, c1 `atof`.
* Datenglieder: `data.o` (162 B Daten, `_iob`), `errlst.o` (662 B), `ctype_.o` (130 B), `crypt.o` (840 B).  Groesste Glieder: `doscan` 1876 B, `ctime` 1150 B, `crypt` 1080 B, `ecvt` 602, `atof` 542, `getgrent` 298/`getpwent` 318.

## 3e. crt0.o und mcrt0.o

`python3 -I` mit `objformat.py` (`Objekt.lesen`), Dateien `lib/crt0.o` 200 B, `lib/mcrt0.o` 548 B (beide `E807`, Magic wie die Programme, nicht gestrippt):
* `crt0.o`: text 48, data 2 (ein Nullwort), bss 2, Symbole `start` (T), `$1` (t), `_environ` (B, bss 0x32), undefiniert `_main`, `_exit`.  Inhalt (Listing): `argc/argv` vom Stapel, Ende der `argv`-Liste mit `CPIR` suchen (`_environ` setzen), `call _main`, `call _exit`, `SC #1` (exit).  Das ist der 48-Byte-Anfang jedes Programms.
* `mcrt0.o` (Profiling-Start): text 146, data 30, bss 4; `start`, `_exit` (T 0x7A, ruft `_cleanup`, `monitor(0)`, `exit`), `_environ`, `countbas`; undefiniert `_main _monitor _sbrk _etext __cleanu`;
  Daten: die Meldung `No space for monitor buffer\n`; Ablauf (*Annahme*, aus den Importen `_sbrk _monitor _etext __cleanu`): `sbrk` fuer den Zaehlerpuffer, `monitor(...)`, dann wie `crt0` `main`.  `cc -p` (Option `proflag` in `cc.c`) linkt dieses Objekt; keines der sieben Programme benutzt es.
* Beide sind kleine Assemblerobjekte: nach der Struktur (`as`-Dialekt Zilog, `as_dialekt.md`) aus Listing rekonstruierbar (W8); der Rundlauf braucht den Gast-`as` (nicht in W0).

## 4. Empfehlung W1-W8 (alles *Annahme*, aus den obigen Messungen abgeleitet)

Reihenfolge der V7-Naehe (aus Abschnitt 3): c0 > cc, ld > cpp > c2 > c1 > as.  G = ganzdatei bytegleich; fuer jedes Programm wird zusaetzlich ein libc-Teil gebraucht, der nur zu etwa einem Drittel bis zur Haelfte mit
der mitgelieferten `libc.a` uebereinstimmt (Abschnitt 2) -- daher `libc_alt`-Glieder (`members`/`quelle`/`bau`, wie bei `ed`, `tar`) fuer jedes Programm; das ist die Haupt-Arbeit der "kleinen" Pakete.

| AP | Programm | V7-Naehe (gemessen) | G erreichbar? (*Annahme*) | Aufwand | Besonderheit |
|----|----------|---------------------|---------------------------|---------|--------------|
| W1 | cc | 10/10 Funktionen V7-Reihenfolge, `main` gekuerzt | **hoch** | klein | Pfade, Optionssatz aus dem Listing; `--check cc` OK |
| W3 | ld | 34/37, ohne Overlay, + CALLR | **hoch** | mittel | CALLR-Zweige der Relokation (`load2td`) aus dem Listing; `ld.c` 35 KB bss |
| W2 | cpp | 24 V7-Funktionen + `yyparse` | **hoch** | mittel | yacc-Frage fuer cpp beantwortet (3a): V7-yacc-Tabellen gleich; `main` Symbole `unix U8000`; Gast-yacc-Lauf als Gegenprobe |
| W4 | c0 | 72/72 V7-Reihenfolge, `opdope` wortgleich | **mittel-hoch** | mittel-gross | Groesse 23,6 KB: Stufenbau; 6 abweichende Funktionen (`getcc`, `blkend`, `outcode` ...); `c05.c` nur Tabelle |
| W5 | c2 | 20+15 V7-Funktionen, 8 neu, `optab` 75 Eintraege | **mittel** | gross | Z8000-Muster in `rmove`; Gegenprobe der Regeln R1-R92 erst danach; c2 ist selbst mit einem c2-Stand uebersetzt (Selbstbezug) |
| W6 | c1 | V7-Rahmen, Codeausgabe neu (18 abweichend, 12 neu) | **niedrig-mittel** | gross | Z8000-`table.s` aus 141 Mustertexten + 41 Feldern ruecklesen, `cvopt` (ggf. angepasst) bauen; EPU-`atof` im Text; `opdope` 14 Eintraege anders |
| W7 | as | **kein V7**, 70 Funktionen, yacc + Lex | **niedrig** (A/E wahrscheinlich) | sehr gross | Grammatik aus 268 Zustaenden/172 Produktionen/77 Nichtterminalen zurueckgewinnen (Tabellen liegen vor); Lex-Tabellen; 360 Zeichenketten (Mnemonik) |
| W8 | `libc.a` + `crt0/mcrt0` | 103/140 Glieder mit `libc_alt`-Quelle (aus anderem Stand) | **mittel** (Glieder), Archivkopf wird von `libc_alt.archiv_bauen` schon erzeugt | mittel | Fehlende 37 Glieder inkl. Gleitkomma (`fltpr gcvt ecvt atof`); Glied fuer Glied gegen die Diskette pruefen |

Aufteilung auf Agenten (Empfehlung): Agent A **W1 + W3** (beide klein, gleiche Ablaufbasis `--c2emu --libc alt`, erste G-Belege der Kette), Agent B **W2** (cpp; danach `yacc`-Gegenprobe im Gast), Agent C **W4 dann W6**
(`c0.h`/`c1.h` und `opdope`-Kenntnis gemeinsam, W6 braucht `table.s`-Rekonstruktion), Agent D **W5** (c2), Agent E **W8** (libc.a; Bedarf an `gcvt abort modf atof` den anderen melden).  W7 erst nach W2 (yacc-Befund) und
getrennt bearbeiten; Ergebnis A ist zulaessig.  W9 (Selbsthosting) braucht W1-W6 und W8; fuer `as` das Original (`W7` offen).

Naechste Schritte aus der Triage, die W0 nicht leistete (kein Gastlauf): (1) `cpy.c` im Gast mit dem Gast-yacc erzeugen und gegen die Tabellen des `cpp` vergleichen; (2) die `ohne`-Zeilen fuer c0/c1/c2/as erst im jeweiligen AP klaeren
(Daten im Text: c1-Tabellen 0x5A40-0x6988, `as`-Tabellen); (3) die Zuordnung c1/c2 per Einzellesen verifizieren (die Heuristik ist bei Funktionen ohne Zeichenketten schwach: c2 Ergebnisse 0.0-0.8).

## 5. Grenzen der Messung

* Die V7-Zuordnung ist eine Heuristik (Reihenfolge + Merkmale); "V7 gleich" heisst nicht "bytegleich" und ist **nicht** durch Uebersetzen belegt.  Die Praeprozessor-Makros des V7-Textes (cpp.c, c0.h, c1.h) werden nicht expandiert:
  Funktionen, deren Aufrufe in Makros stehen, fallen in "abweichend" (z. B. `getc/putc` ersetzt durch `filbuf/flsbuf` ist behandelt, andere Makros nur wenn sie als `#define name(` stehen).
* Die Zeichenketten-Auswertung benutzt `NAME.strings` (nur druckbare, NUL-beendete Ketten; Ketten mit Zeilenumbruch fehlen dort) fuer die Binary-Seite und die rohe Abbilddatei fuer die V7-Seite.
* Der Host-yacc-Lauf (64-Bit-`gcc`, `-DWORD32`) ist ein Messmittel ausserhalb des Repositories; das Ergebnis (Tabellengleichheit) stuetzt sich auf 683 Worte und ist reproduzierbar mit den in 3a genannten Befehlen.
* `c1`: Der Eigenteil endet bei 0x57CE (von Hand); `atof/ldexp/modf` davor und hinter den Tabellen sind nicht den libc-Gliedern zugeordnet.
