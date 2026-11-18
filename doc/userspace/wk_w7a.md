# W7a (Plan 52): Triage des Z8000-Assemblers `as`

Programm: `/usr/bin/as` (Diskette `usr`, 35814 B; text 22092, data 13706, bss 17744; Abbild ohne Kopf 35798 B = 0x8BD6).  Kein V7 (V7-`as` ist PDP-11).  Messwerkzeuge: `pipeline.py karte/--check as`,
`z8kdis` (Karte, `--pruefen`), ein Host-Skript fuer die Tabellen (nicht im Repository).  Aussagen sind *gemessen*, ausser wo *Annahme* steht.

## 1. Karte sauber (gemessen)

`python3 -I tools/userspace/pipeline.py --check as` -> `as: text 22092 data 13706, 103 functions, 22 libc names; OK` (vorher 66 Ueberlappungen).  Neu: `userspace/as/karte_extra.txt`
(`k.txt`, `as.lst` neu erzeugt; `z8kdis --pruefen`: 35798 Bytes, 0 abweichend; `v7zuordnung.txt` bewusst nicht neu erzeugt, bleibt der W0-Stand mit 70 Funktionen).

* **66 `ohne`** (Vorschlaege, die Konstanten oder Datenadressen als Codeziele lesen und in die Mitte eines echten Befehls fallen, z. B. `01B6`, `2E20` = Datenadresse `90D0` als Konstante hinter `OR R2,%90D0`).
  Gefunden mit einer Kopie von `z8kdis.h` im Scratchpad (nicht im Repository), die bei jeder Ueberlappung die Adressen nennt (die Standardausgabe zeigt nur die Zahl 66).  Regel: die jeweils hoehere der
  beiden Adressen ist der falsche Einstieg; danach 0 Ueberlappungen, 0 nicht kanonische, 0 Marken mitten im Befehl.  Sieben davon (`16FE/1700`, `2E1E/2E20`, `2EC8/2ECA`, `2FD0/2FD2`, `4022/4024`, `43E0/43E2`,
  `548E/5490`) sind Faelle, in denen der *niedrigere* Einstieg Vorrang bekam; dass das richtig ist, belegt nur der Rundlauf (die Bytes sind in jedem Fall abgedeckt), nicht eine Lesung jeder Stelle (*Annahme*).
* **15 `dwc`** fuer die Schalttabellen (`LD R1,Lxxxx(Rn)` + `JP @R1`, im Datenteil bei 65C6, 65CE, 6800, 680A, 68E2, 69B0, 69B4, 6A8E, 6BEE, 6C06, 6E40, 6F6A, 6F72, 6F7A, 8A6C; Bereichsschalter k+1 Eintraege,
  Hash-Schalter `DIV RR2,#n` n Eintraege).  65CE ist der `case`-Schalter des `yyparse` (0..165, Vorgabe 09C4).  Wirkung: Code von 59,9 % auf 61,7 % des Abbilds, **der Text ist bis auf 6 Byte Code**.
* **16 `code`** fuer toten Code im Text (`JP` hinter `JR`, ungerufene Funktion bei 1476: `CALL csv`, 48 B; 5454..54F4 liegt im libc-Bereich).

## 2. Tabellen (gemessen)

Datenteil beginnt bei 564C.  Alle Adressen aus dem `yyparse`-Code abgelesen (W0) und hier gegen die Gestalt geprueft:

| Bereich | Inhalt |
|---|---|
| 564E-566A | `yyexca` 14 Worte (`-1,1,0,-1,-2,0,-1,170,315,69,93,69,-2,70`) |
| 566A-5C2C | `yyact` 737 Worte (= `YYLAST`), Werte 0..267 |
| 5C2C-5E44 | `yypact` 268 |
| 5E44-5EDE | `yypgo` 77 |
| 5EDE-6036 | `yyr1` 172 (Werte 0..76: 77 verschiedene linke Seiten) |
| 6036-618E | `yyr2` 172 (Laenge 0..8; 15 leere Regeln) |
| 618E-63A6 | `yychk` 268 (72 verschiedene Token, 76 Nichtterminale) |
| 63A6-65BE | `yydef` 268 |
| 65BE-65C6 | `0, -1, 0, 0`: yaccpar-Variablen (`-1` = `yychar`; `TEST 65BE` vor dem `fprintf` = `yydebug`), *Annahme* |
| 65C6-671A | Schalttabellen (siehe 1.), davon 65CE-671A der `case`-Schalter |
| 672E-7066 | Zeichenketten (Fehlermeldungen, Zeichenklassen `#|.?@<>()[]+-*/:=%`, `01234567`, `abcdefABCDEF`) |
| 706E-7102 | Schluesselworttabelle, 4-Byte-Eintraege `{Name, Token}` (`MODULE`=3, `CONSTANT`=0x102 ... `LNOT`=0x124) |
| 7102-72AA | 69 Eintraege zu 6 B `{Name, Token 0x130..0x13D, Wert}`: Bedingungen (`ULT UGE ULE UGT NOV ...`), Flags, Steuerregister (`FCW NSPOFF PSAPSEG REFRESH`), Fliesskomma-Flags |
| 72AC-8310 | Mnemonik-Tabelle, 14-Byte-Eintraege `{Name, Opcodewort(e), Klasse...}` (`SRA 6102 0008 0010 0000 0000 3309`), etwa 299 Eintraege (`CALL .. TSETB`, ohne die Fliesskomma-Mnemonik FLD.. gesondert) |
| 8310-8BD6 | Lex-Laufzeitvariablen und Namen (8310 `yymorfg`, 8312 `yysptr`, 8320 `yytext`-Zeiger), Mnemonik-Namen 8322-8B40 |
| BSS ab 8BD6 | 17744 B; `yysbuf` 8D28 (200 B), `yytchar` 8DF0, `yylineno` 8DF2, `yytext` 8E76, Zeichenklassentabelle 8F42 (128 Worte) |

Die Namen der Lex-Variablen folgen aus der Form des Codes (siehe 3.), nicht aus Symbolen (*Annahme* fuer die Namen, gemessen die Funktion).  Die Mnemonikzaehlung 299 ist die Rechnung mit festem Schritt 14 und kann an den Raendern um 1-2 abweichen.

## 3. Scanner `plzlex`: **kein Lex-DFA, handgeschrieben im Lex-Rahmen** (gemessen / *Annahme* wo markiert)

* `09D4` (212 B) ist wortgetreu das `input()` des V7-lex-Rahmens (`yysptr > yysbuf ? *--yysptr : getc(yyin)`, Zeilenzaehler bei `\n`, EOF -> 0, Aufnahme in `yytext`).  `3A9C` (26 B) passt zu `unput`.
* `0AA8` (2184 B) ist `plzlex`: ruft `13C8` (nennt sich in der Meldung `yylook`), schaltet mit einem Hash-Schalter (`DIV RR2,#5`, Tabelle 6800) und Bereichsschaltern ueber das Ergebnis; der Zweig `default` ruft `35A8`
  mit `bad switch in plzlex returning from yylook` (Text weicht vom V7-`ncform` ab: dort `bad switch yylook %d`).
* **Keine Lex-Tabellen** (`yycrank`, `yysvec`, `yymatch`, `yyextra`): Datenteil enthaelt sie nicht (Rechnung: 65BE-8310 sind Schalttabellen, Zeichenketten und die Schluessel-/Mnemonik-Tabellen).  `13C8` liest Zeichen mit der
  Klassentabelle 8F42 (`AND R11,@R2`) in einer Schleife, also ein handgeschriebenes Gegenstueck zu `yylook`.  Verdikt: der Scanner wurde **nicht von `lex` erzeugt**; die W0-*Annahme* "Lex-Scanner" gilt nur fuer den Rahmen
  (`input/unput/yytext/yylineno`, evtl. ein `lex`-Muster als Vorlage).  Es gibt keine `.l`; die Quelle ist normales C (im Binary: `13C8`, `1540`, `1626`, `0AA8`).

## 4. Funktionsgruppen (70 Funktionen, `v7zuordnung.txt`; Aufruferdiagramm aus `as.lst`, Rolle aus Aufrufen und Zeichenketten, die Namen sind *Annahme*)

* **Rahmen:** `0000` Anfang (`crt0`), `322C` `main` (186 B: ruft `yyparse`, `32E6`, `3AC8`, `459C`), `32E6` (706 B) Aufrufargumente + `creat/open/fopen/freopen` + `asm.out`, `3AC8` baut die Zeichenklassentabelle
  (`01234567`, `abcdef`, `A-Z`; `1502` setzt Bits), `459C`/`4628` (Pass-2-Anlauf, nutzen `31BA`).
* **Parser:** `0030` `yyparse` (2468 B mit allen 166 Aktionen; Aufrufe in fast alle Gruppen).
* **Scanner:** `09D4` input, `3A9C` unput, `13C8` yylook-Ersatz, `0AA8` plzlex, `1540`/`1626` Zahlen (`hex_digit expected`), `14A6`, `3A18`, `3AB6`.
* **Fehler/Meldungen:** `35A8` `error` (86 B, von 23 Stellen gerufen, ruft sich selbst), `43C6` (` %s :   line: %d.`), `1330` (`overflow of exp`), `3844`/`38B6` (`fatal output error`, `defla not implemented`).
* **Ausdruecke:** `3620` (548 B: `illegal expression`, `unimplemented operation in exprdo`), `1330`, `13A2` (38 B, viele Aufrufer: Knotenzuweisung), `1938`, `19DA`, `1A1E`, `1A54`, `1A86` (Pruefungen mit Fehlermeldung).
* **Symboltabelle:** `16A0` (170 B, `sprintf "#%6d"`: Namen fuer lokale Marken), `4814`/`48A4` (`symbol table overflow`, `undefined symbol`), `14B0`, `44F0` (Hashen/Suchen), `46DA` (314 B, `illegal --totab-- in PASS1`), `3E1E` (`getlab: label not found in PASS1`, `too many generic labels`), `3D6C` (`nesting too deep`).
* **Anweisungs-Kodierung:** `1C0C` (**4512 B**, 72 Aufrufe: der grosse Kodierer mit `illegal value`, `ILLEGAL VALUE`), `174A` (`illegal number or type of operands`), `181A` (256), `1B2A`, `1B82` (`illegal value`), `1AB6` (`opxba: wrong =Q=`), `2DAC`, `2DCC`, `2E38` (444, `lseek`).
* **Abschnitte/Direktiven:** `3B78` (`illegal section name`, `unimplmented ASSDIR`), `3CEA`, `3D38`, `3D52`, `3FD6`, `3F72`, `3FB0`, `3EC0` (`overflow of __constk__`: Konstantenpool), `167A`, `191A`, `4372`, `43AE`.
* **Initialisierung (BVAL/WVAL/LVAL):** `40A4` (500 B: `longer then long not supported`, `initialization only in TEXT or DATA!`), `4298` (`type longer LVAL`, `*ATDB`), `404A`.
* **Objektausgabe:** `2FF4`, `3038` (200 B, `write`), `3100`, `3188`, `31BA` (`creat exit fprintf`), `3988`, `38B6`; Relokation/Kopf liegen vermutlich in `3038`-`3188`/`2E38` (*Annahme*).
* **libc (22 Namen, `as.namen`):** `freopen fopen fprintf sprintf filbuf doprnt fakcu(weak) strout findiop cuexit isatty stty close creat ioctl lseek open read sbrk write cerror csv` -- also Ein-/Ausgabe und Systemrufe; kein
  `malloc`/`str*` (Speicher selbst verwaltet, 17744 B BSS).  `5454`-`54F4` und `551A` liegen im libc-Bereich (`stty`, `isatty`).

## 5. Machbarkeit der naechsten Schritte (*Annahme*)

1. **Grammatik zurueckgewinnen (W7b).**  Gute Aussichten fuer die *Form*: Alle Tabellen sind da, `cpp` hat gezeigt, dass das V7-yacc und der Gast-yacc die Tabellen wortgleich erzeugen (wk_w2).  Aus `yyr1/yyr2`
   (172 Regeln, linke Seite, Laenge), `yychk` (Zugangssymbol je Zustand) und `yydef/yyact/yypgo` (Reduktion/Verschiebung) laesst sich die Regelrechte Seite rekonstruieren, indem man den LR(0)-Automaten aus den
   `yyact`/`yypact`-Spruengen nachbaut (Zustandsuebergang `s --X--> t` mit `yychk[t]=X`; die rechte Seite einer Regel ist der Pfad, den `yyr2` Symbole lang zurueck fuehrt).  Token-Namen und -Nummern: 41 Schluesselworte mit
   Token aus 706E-7102, 69 Konstanten (0x130-0x13D) aus 7102; Tokens 3..24 (kleine Nummern) und der Rest sind aus den Aktionen/yychk zu benennen.  Nichtterminalnamen gehen verloren (nur Zahlen 0..76), muessen aus
   den Aktionen benannt werden.  Der Beweis ist derselbe wie bei `cpp`: Gast-yacc auf der rekonstruierten `.y` -> `yyexca..yydef` wortgleich (1976 Worte).  Offen: Reihenfolge der Regeln und Praezedenz (`%left`) -- beides
   aus den Tabellen ableitbar (Reihenfolge = `yyr1`-Reihenfolge, Praezedenz aus `yyexca`/Konflikten), aber nicht eindeutig; falls nicht wortgleich, Ergebnis **A** (generierte `.c`-Tabellen als Quelle, Aktionen von Hand).
2. **Scanner (W7c).**  Kein lex: der Scanner ist C (`13C8`, `1540`, `0AA8`, Klassentabelle 8F42) und damit wie `c0` Zeile fuer Zeile aus dem Listing rekonstruierbar (Muster: wk_w4/wk_w6 mit `--vergleich`); mittlere Groesse, ca. 700 B Code.
3. **Aktionen und Kodierer (W7d+).**  `yyparse` 2468 B enthaelt 166 `case`-Aktionen (Schalttabelle 65CE, jetzt in der Karte); `1C0C` (4512 B) und die Mnemonik-Tabelle (299 x 14 B) sind der Hauptaufwand.
   Die Tabelle liesse sich als Datenfeld aus dem Binary uebernehmen (wie `opntab` in c13).  Die Rekonstruktion ist gross, aber nicht blockiert; Ergebnis A ist realistisch, G (bytegleich) nur mit viel Lesearbeit.
4. **Reihenfolge:** (a) Token-/Nichtterminal-Tabelle und Regelliste ausgeben (Skript nach `tools/userspace/`), (b) `.y`-Entwurf mit Gast-yacc vergleichen, (c) Scanner, (d) Datenteil (Schluessel-/Mnemonik-Tabellen als C-Initialisierer), (e) Aktionen.

## 6. Nicht geprueft

* Kein Gastlauf (der Gast-yacc wurde nicht auf eine `as`-Grammatik angewendet).
* Rollen der Funktionen sind aus Aufrufgraph und Meldungen geschlossen, keine Zeile des Kodierers wurde gelesen.
* Das Verdikt "kein Lex" stuetzt sich auf die Datenbereichsrechnung und `13C8`; ein auffaelliger DFA in der BSS-Initialisierung ist ausgeschlossen, weil BSS keine Initialwerte hat.
