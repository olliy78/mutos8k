# Ergaenzung E3a: yacc (Plan 45)

*Ergaenzung, V7-Quelle, keine Originalreferenz.*  Quelle: `original/unix-v7/usr/src/cmd/yacc/` (`y1.c y2.c y3.c y4.c dextern files`), Parser-Rahmen `original/unix-v7/usr/lib/yaccpar`.
Ergebnis: **B** (baut, Test gruen).  Binary 28538 B, Bau ca. 275-314 s im Gast, Test 42 s.  Alles *gemessen*, soweit nicht als Annahme markiert.

## Benutzung im Gast (fuer make, bc, egrep ...)

`yacc` muss im Pfad liegen, `yaccpar` im **Arbeitsverzeichnis** (Abweichung 1):

```
cat /mnt/yaccpar >/tmp/yaccpar        # einmal; Datei: userspace/ergaenzung/yacc/yaccpar (= V7 usr/lib/yaccpar)
cd /tmp
yacc gram.y                           # erzeugt y.tab.c (Schalter: -v -> y.output, -d -> y.tab.h)
cc -s -o prog y.tab.c ...             # yyparse braucht yylex, yyerror, main
```
Zwischendateien `yacc.tmp`, `yacc.acts` entstehen im Arbeitsverzeichnis und werden geloescht.  Ein im Arbeitsverzeichnis gebautes Programm ruft man mit `./prog` auf (`.` steht nicht im `PATH` der Testskripte).

## Rahmen erg.py (Aenderung)

`erg.json` kennt neu das optionale Feld `dateien`: Dateien des Programmordners, die weder `.c` noch `.h` sind (hier `dextern`, `files`), werden wie Header flach neben die Quellen gelegt.
Mehrere `*.c` konnte der Rahmen schon (je `cc -O -c`, dann `cc -s -o NAME *.o` alphabetisch = V7 `y?.o`).  Ohne `dateien` ist das Verhalten unveraendert.

## Segmentbelegung (gemessen am a.out-Kopf)

| Fassung | Text | Daten | BSS | Summe |
|---------|------|-------|-----|-------|
| V7 `MEDIUM` unveraendert | 24214 | 4308 | 49792 | 78314 B, **ueber 64 KB** |
| `SMALL` (Abweichung 2) | 24214 | 4308 | 28192 | 56714 B |

Mit `MEDIUM` baut `cc` ohne Meldung, aber `sh` meldet beim Aufruf `yacc: too big`.  Ursache: V7 linkt `-i` (getrennte Befehls- und Datenbereiche, PDP-11); auf Z8000/MUTOS liegt alles in einem
64-KB-Segment.  Die BSS sind fast nur die Tabellen aus `dextern`.  *Annahme:* der Rest (ca. 8 KB) reicht fuer Stapel und stdio-Puffer -- die Testgrammatik laeuft; Grenzen der Grammatikgroesse sind nicht ausgemessen.

## Abweichungen vom V7-Text (alle als `/* Differs from V7: ... */` kommentiert; `y1.c`-`y4.c` unveraendert)

1. `files`: `PARSER "/usr/lib/yaccpar"` -> `"yaccpar"`.  Ursache: Plattenplatz (Platte `usr` voll).
2. `dextern`: neue Groessenklasse `SMALL` (`HUGE`, `MEDIUM` unveraendert): ACTSIZE 2000, MEMSIZE 4000, NSTATES 300, NTERMS 127, NPROD 200, NNONTERM 100, TEMPSIZE 400, CNAMSZ 2000,
   LSETSIZE 200, WSETSIZE 100 (MEDIUM: 4000 5200 600 127 400 200 800 4000 450 250); die Beziehungen aus dem Kommentar in `dextern` gelten weiter.  `files`: `MEDIUM` -> `SMALL`.
   Ursache: 64-KB-Segment (Speichermodell, nicht Compiler).  Folge: Grammatiken bis 200 Produktionen, 100 Nichtterminale, 300 Zustaende.

## Test

`test/`: `calc.y` (Taschenrechner mit `%left %right %prec`, `error`-Regel, `yylex`/`yyerror`/`main`), `in.txt` (9 Zeilen), `yaccpar`.  Befehl:
`yacc -vd calc.y && cat y.tab.h && cc -s -o calc y.tab.c && ./calc <in.txt`.  Erwartung von Hand aus der Arithmetik (Herkunft: `test/herkunft.txt`); Gast = Erwartung.
Host-`yacc` (byacc, bison) ist nicht installiert, ein Vergleich der `y.tab.c` entfaellt.  Nicht getestet: Inhalt von `y.output`, Konflikte, `%union`, grosse Grammatiken.

## Kapazitaetsprobe mit V7-Grammatiken (gemessen, einmalig, nicht im Test)

Mit `SMALL` laufen `original/unix-v7/usr/src/cmd/make/gram.y` (5053 B, `y.tab.c` ca. 724 Zeilen) und `.../cmd/bc.y` (12194 B, 597 Zeilen, `y.tab.c` ca. 800 Zeilen) fehlerfrei durch (Meldung leer, `y.tab.c` erzeugt).
Mit `MEMSIZE 2400` scheiterte `bc.y`: `fatal error: out of space, line 327` (Produktionsspeicher `mem0`, `y4.c`); daher 4000 statt 2400 (BSS +3200 B).  `gram.y` (fuer V7 `make`, E3b) brauchte das nicht.
Ob die erzeugten Parser laufen, ist nur fuer `calc.y` geprueft.  Mit 56714 B bleiben ca. 8 KB; Gast-Test mit `MEMSIZE 4000`: gleich (41 s).
