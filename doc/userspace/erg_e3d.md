# Ergaenzung E3d: sed, m4, lex (Plan 45)

*Ergaenzungen, V7-Quellen, keine Originalreferenz* (`original/unix-v7/usr/src/cmd/{sed,m4,lex}`).  Alle drei: **B** (baut im Gast, Test gleich).  Gemessen 2026-11-16
mit `python3 -I tools/userspace/erg.py alles NAME`; Binary = Dateigroesse von `work/bau/NAME.bin` (gestrippt).  Segmentbelegung aus dem a.out-Kopf (Text + Daten + BSS; Grenze 64 KB).

| Programm | Ergebnis | Binary | Text / Daten / BSS | Test deckt ab |
|----------|----------|--------|--------------------|---------------|
| sed | B | 16130 B | 14792 / 1322 / 22682 (Summe 38796) | 55 Faelle (54 gegen GNU sed 4.9, `l` aus dem Quelltext): s (g, p, w, &, `\(\)`, Trennzeichen), Adressen (Zeile, `$`, Muster, Bereich, `!`), d p P n N D q = l, a i c (auch mehrzeilig), r w, Halteraum (g G h H x), Marken b t, Gruppen `{}`, -n -e -f, `#n`, mehrere Dateien, stdin, y |
| m4 | B | 15490 B | 13162 / 2312 / 10826 (Summe 26300) | 13 Dateien/Laeufe: define (Argumente, Schachtelung, Rescan), undefine, ifdef, ifelse (>4 Argumente), incr, len, index, substr, translit, changequote, eval (alle Operatoren, 32 Bit, Rekursion), divert/undivert/divnum, dnl, include/sinclude, Kommentar `#`, mehrere Dateien, stdin, EOF ohne Zeilenende, EOF im String, fehlende Datei |
| lex | B | 36412 B | 29468 / 6928 / 4832 (Summe 41228) | Ganze Kette im Gast: `lex t1.l` -> `lex.yy.c` -> `cc` mit den libl-Quellen -> Lauf: Definitionen, `%Start`/BEGIN, `^` `$`, Trailing Context `/`, Klassen, `+ * ?`, laengste Uebereinstimmung gegen Regelreihenfolge, ECHO, yytext, yyless, REJECT |

Reihenfolge der Arbeit: sed, m4, lex; je Programm ein Commit.  Bauzeiten im Gast: sed 216 s, m4 165 s, lex 419 s; Tests 102 s, 58 s, 109 s Wanduhr.

## Rahmen

`tools/userspace/erg.py` ist **nicht** geaendert.  Geaendert ist nur `tools/userspace/erg_yacc.py` (rueckwaertskompatibel): ein Argument darf `ORDNER/NAME` lauten, wenn die Grammatik `NAME.y` heisst und im
Ordner eines anderen Programms liegt (`m4/m4y`, `lex/parser`); dann steht `NAME.c` ebenfalls dort.  *Gemessen*: `erg_yacc.py bc` nach der Aenderung erzeugt eine mit dem Stand im Repo identische `bc.c`.
`m4y.c` und `parser.c` sind erzeugte Quellen (Kopfkommentar), V7-`m4y.y` und -`parser.y` stehen unveraendert daneben; Voraussetzung `erg.py bau yacc`.  Die Gast-Meldungen von yacc waren leer (kein Konflikt).

## Abweichungen vom V7-Text (alle als `/* Differs from V7: ... */` im Quelltext kommentiert)

### sed
Keine.  `sed0.c`, `sed1.c`, `sed.h` byteweise V7; `cc -O -s` ohne Meldung.  `sed.h` definiert Variablen (`char *cp; char *reend; ...`) in beiden Modulen, `ld` loest das als gemeinsame Definitionen.
Erst bei *gemessenen* V7-Besonderheiten (Teil "Befunde") gibt es etwas zu beachten; der Test wurde daran angepasst, das Programm nicht.

### m4
1. **`getchr()` liest zurueckgelegte Zeichen vorzeichenerweitert** (neue Funktion `ipget`).  Ursache: Wortbreite/Compiler -- der MUTOS-`cc` hat `char` ohne Vorzeichen (PDP-11: mit).  `putbak(EOF)` legt `-1` in einen `char`-Puffer;
   V7 liest es als -1 (EOF) zurueck, mit `unsigned char` wird 255 daraus, ein gewoehnliches Zeichen.  *Gemessen*: das **unveraenderte** V7-`m4.c` gibt bei einer Eingabe ohne Zeilenende, die mit einem Namen endet
   (`x` am Dateiende), ein Byte `0xFF` aus (`1\377` statt `1`); mit `ipget` ist der Test gleich.  Alle uebrigen 12 Testfaelle waren auch mit dem unveraenderten Text gleich.  (Dieselbe Fehlerklasse wie bei `dc`, `erg_e3c.md`.)
   Nebenwirkung, V7-treu: ein zurueckgelegtes Zeichen >= 128 kommt negativ zurueck und wird als Dateiende behandelt (auf der PDP-11 genauso).
2. `unix` ist im MUTOS-`cpp` vordefiniert (*gemessen* mit einer Probe `#ifdef unix`), also braucht V7 `install("unix", ...)` keine Aenderung.  Ein zuerst eingefuegter Ersatz `#define unix 1` wurde wieder entfernt.

Sonst unveraendert.  `m4y.c` entsteht aus unveraendertem `m4y.y` (Operatoren `| & ! == != < <= > >= + - * / % ^ **` mit `long`-Werten, `YYSTYPE long`).  `cc -O -s` ohne Meldung.

### lex
1. **`-DSMALL`** (`erg.json` `flags`): V7-`ldefs.c` kennt die Groessenklasse `SMALL` (NSTATES 300, NTRANS 1500, MAXPOS 1500, TREESIZE 600, NOUTPUT 1500) schon; V7 baut `lex` mit `cc -i` und grossen Tabellen,
   hier gibt es kein getrenntes I&D (`exp_ldi.md`).  *Gemessen*: mit SMALL belegt `lex` Text 29468 + Daten 6928 + BSS 4832 = 41228 B; der Rest des 64-KB-Segments (ca. 24 KB) ist der `calloc`-Speicher fuer die Tabellen, der Test lief
   ohne `Too little core`.  Grenzen grosser Spezifikationen wurden **nicht** ausgemessen.
2. **`once.c` heisst `once.h`**, `lmain.c`: `# include "once.h"`.  Ursache: der Rahmen uebersetzt jede `*.c` des Ordners als eigene Einheit; `once.c` enthaelt Speicherdefinitionen und ist nur als Einschub gedacht.
   `ldefs.c` bleibt unveraendert: `erg.json` nimmt es ueber `header` direkt aus `original/unix-v7/usr/src/cmd/lex/ldefs.c` (Pfad `../src/cmd/lex/ldefs.c` relativ zu `usr/include`), das ist V7-Text byteweise; `parser.y` und `sub1.c` `sub2.c` `header.c` sind unveraendert.
3. **`cname = "ncform"`** statt `"/usr/lib/lex/ncform"` (in `once.h`).  Ursache: Platte `usr` im Gast ist voll (wie `yaccpar` bei `yacc`, `erg_e3a.md`); `ncform` wird im Test ins Arbeitsverzeichnis kopiert (unveraendert V7, `test/eingabe/ncform`).
4. **Ohne `-O`** (`flags "-DSMALL -s"`).  *Gemessen*: der erste Bau mit `-O` blieb in einem Schritt ueber 18e9 Emulatorzyklen (ca. 30 Minuten) haengen; ich habe ihn abgebrochen, ohne das Ende abzuwarten (ob er fertig geworden waere, ist *offen*).
   Ohne `-O` baut alles (fuenf Module + `parser.c`) in 419 s ohne Meldung.  Wahrscheinlich bremst der Optimierer `c2` an grossen Funktionen (*Annahme*, wie bei `dc` und `bc`).
5. Die V7-Notationen `=+`, `=-` und Initialisierer ohne `=` (`char *cname "..."`, `int ctable[2*NCH] {...}`) uebersetzt der MUTOS-`cc` (*gemessen* mit Probe; `calloc`/`cfree` sind in der libc).

**libl.**  V7 baut `libln.a` aus `lib/{allprint,main,reject,yyless,yywrap}.c`; ein Lex-Programm wird mit `cc lex.yy.c -ll` gelinkt.  Hier gibt es kein `libln.a`: der Rahmen baut aus mehreren `.c` ein Programm, kein Archiv.
Der Test uebersetzt deshalb die V7-Quellen `main.c yywrap.c yyless.c reject.c` (unveraendert, als Eingabe kopiert) zusammen mit `lex.yy.c`: `cc -s -o scan lex.yy.c main.c yywrap.c yyless.c reject.c`.
`allprint.c` wird nur mit `LEXDEBUG` gebraucht (*aus dem Treiber-Quelltext abgeleitet*, nicht gebaut).
*Annahme*, nicht untersucht: der Treiber `ncform` vergleicht Zeiger ueber `(int)`-Casts (`(int)yyt > (int)yycrank`); bei 16-Bit-Zeigern im 64-KB-Segment waere das ueber 32 KB falsch.  Der Testscanner (kleine Tabellen) laeuft; grosse Scanner sind nicht geprueft.

## Befunde je Programm

### sed (V7 `sed0.c`, `sed1.c`)
Erwartung: GNU sed 4.9 auf dem Host (`LC_ALL=C`), nur Faelle, in denen V7 und GNU gleich arbeiten.  Der erste Gastlauf war T mit drei Abweichungen, alle V7-Verhalten (keine Fehler des Ports, im Quelltext belegt):
* **Marken laufen bis Zeilenende.**  `ta;s/$/x/;:a` ergibt im Gast `Label too long` (nur 8 Zeichen, `;` beendet die Marke nicht, `sed0.c` `jtcommon`); GNU akzeptiert es.  Test: Zeilenumbruch nach `b`/`t`/`:`-Marken.
* **`sflag` wird nur von `t` zurueckgesetzt**, nicht beim Lesen einer neuen Zeile (`sed1.c` Z. 341/612; das Handbuch sagt etwas anderes).  Ein erfolgreiches `s` einer frueheren Zeile laesst das naechste `t` springen.  Der Test vermeidet das (nach `t` nur `y`).
* **`l`** druckt Tab als `>` BS `-` (Ueberdruck), Steuerzeichen als `\01`, ohne `$` am Ende (Tabelle `trans[]`); GNU anders.  Erwartung von Hand aus dem Quelltext.
`char` ohne Vorzeichen: `y`, `l` und die Klassen-Bitmaps (`ep[c>>3]`) indizieren mit Zeichen; der Test verwendet nur ASCII, 8-Bit-Eingaben wurden **nicht** geprueft (*Annahme*: mit unsigned char eher besser als auf der PDP-11, ungemessen).
Nicht getestet: Zeichen >= 128, Zeilen ueber 4000 Zeichen, mehr als 10 `w`-Dateien, `-g`.

### m4 (V7 `m4.c`, `m4y.y`)
**Auf dem Host ist kein m4 installiert**; alle Erwartungen sind von Hand aus Handbuch und Quelltext abgeleitet, vor dem Gastlauf (siehe `test/herkunft.txt`).  Erster Lauf: 11 von 13 Abschnitten gleich; die beiden Abweichungen waren Rechenfehler der Erwartung, nicht des Programms:
* `ifdef(`unix', `unix is defined', ...)`: der Ersatztext wird erneut gelesen und `unix` ist selbst ein Makro (leerer Wert) -> `" is defined"`.  Test auf `yes`/`no` umgestellt.
* EOF im String: die Zeichen werden schon waehrend des Lesens ausgegeben (`putchr` in der `lquote`-Schleife), danach `m4: EOF in string`, Exit 1 -> stdout `abc`.
V7-Besonderheiten: `shift` ist "not yet implemented"; `$0`-Rekursion nicht getestet (V7 liest den Ersatztext erneut, `$0` im Wert ruft das Makro wieder); fuehrende Leerzeichen der Argumente werden uebersprungen, nachgestellte bleiben.
`mktemp`/`divert`-Dateien (`/tmp/m4aXXXXX`) funktionieren; `delexit` raeumt sie auf.  Nicht getestet: `maketemp`, `syscmd`, `errprint`, `dumpdef`, Argument-/Aufrufstapel-Ueberlauf (`STACKS 50`), `changequote` mit Mehrzeichen.

### lex (V7 `lmain.c sub1.c sub2.c header.c parser.y`, `ldefs.c`, `once.c`)
**Auf dem Host ist weder lex noch flex installiert**; Erwartung von Hand, Zeile fuer Zeile vor dem Gastlauf; der erste Lauf stimmte (zwei Fehler der Erwartung bzw. des Skripts: ein vergessenes Leerzeichen am Zeilenende und die Dateinamenausgabe von `cc` bei mehreren Dateien).
Das Testprogramm (`test/eingabe/t1.l`, 18 Zeilen) und die Eingabe stehen in `test/eingabe/`; die Ausgabe des Scanners: `F(foo)W(bar) N(12)O(+)N(34) AW(abc)` usw. -- siehe `test/erwartet.txt`.
Damit ist die gesamte Kette (lex als Gastprogramm, Treiber `ncform`, libl, MUTOS-`cc` fuer das erzeugte C, Lauf) im Gast belegt, nicht nur die Ausgabe von `lex`.
Nicht getestet: Optionen `-v -n -f -t -r`, Zeichen ab 128, `yymore`, `input`/`unput`, Tabellengroessen (`%p %n %a %e`), mehrere Quelldateien, grosse Spezifikationen, `lex -t` (stdout) und der Zeilenumbruch in `lex.yy.c`.

## Offen

* `lex` ohne `-O`; ob der `-O`-Bau fertig wird, nicht abgewartet.  Wenn ja, spart das Text (Groessenvergleich offen).
* `lex`: Kapazitaet bei grossen Spezifikationen (SMALL-Grenzen) nicht gemessen; kein Vergleich mit einem zweiten lex (keiner auf dem Host).
* `m4`, `lex`: Erwartungen aus Handrechnung; ein Host-Vergleich entfaellt, weil weder m4 noch flex installiert sind.
* `sed`: 8-Bit-Zeichen (V7 mit negativem `char` anders als hier) nicht untersucht.
* libl als Archiv `libln.a` (mit `ar`/`ranlib`) nicht gebaut; die Quellen werden direkt mitkompiliert.
