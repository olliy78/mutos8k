# Ergaenzung E3c: tsort, ranlib, dc, expr, egrep, bc (Plan 45)

*Ergaenzungen, V7-Quellen, keine Originalreferenz* (`original/unix-v7/usr/src/cmd/`).  Alle sechs: **B** (baut im Gast, Test gleich).  Gemessen 2026-11-16
mit `python3 -I tools/userspace/erg.py alles NAME`; Binary = Dateigroesse von `work/bau/NAME.bin` (gestrippt).

| Programm | Ergebnis | Binary | Test deckt ab |
|----------|----------|--------|---------------|
| tsort | B | 8794 B | Kette (Datei), DAG ueber stdin mit Duplikaten und Selbstpaar, Einzelknoten, Zyklus, ungerade Tokenzahl (Exit 1), fehlende Datei (Exit 1) |
| ranlib | B | 7298 B | Archiv mit `ar r`, `ar t` vor/nach ranlib und nach einem zweiten Lauf, Inhalt von `__.SYMDEF` (3 Symbole, Offsets), Linken ueber das Archiv, Nicht-Archiv und fehlende Datei |
| dc | B | 33174 B | ganze Zahlen (+ - * / % ^, negativ), Skalierung (k, X, Wurzel), Basen (i o I O), Register/Makros/Vergleiche, Zeichenketten, z Z f c, Fehlermeldungen, 100! (Zeilenumbruch bei 70), Datei als Argument |
| expr | B | 10584 B | 42 Faelle (41 mit GNU-Vergleich, 1 V7-Fehler aus dem Text): Arithmetik, Vergleiche, `\|` `&`, `:` mit `\( \)`, length/substr/index/match, Exit-Status 0/1/2 |
| egrep | B | 11290 B | 31 Faelle: Muster (`\| + * ? ( ) [ ] ^ $ .`), -v -c -n -l -h -s -e -f, mehrere Dateien, stdin, Exit 0/1/2 |
| bc | B | 17358 B | acht Programme (Arithmetik, scale, Schleifen, rekursive Funktionen, Felder, Basen, quit, Kommentare) ueber die ganze Kette bc -> Pipe -> dc |

Die Reihenfolge der Arbeit war tsort, ranlib, dc, expr, egrep, bc; je Programm ein Commit.

## Rahmen (Aenderungen an `tools/userspace/erg.py`, rueckwaertskompatibel)

* Neuer optionaler Schluessel `"werkzeuge": [...]` in `erg.json`: Hilfsprogramme, die der **Test** im Gast braucht (Gast hat nur `root` und `usr`).  Name eines Ordners in
  `userspace/ergaenzung/` (dann dessen `work/bau/NAME.bin`, bei Bedarf gebaut) oder sonst `bin/NAME` der Originaldiskette `cmd` (`uspace.platte_holen`).  Sie kommen mit
  Ausfuehrbit auf `/mnt` (PATH).  Benutzt von `ranlib` (`ar` von `cmd`) und `bc` (`dc` der Ergaenzung).  Ohne den Schluessel unveraendert.
* Neues Werkzeug `tools/userspace/erg_yacc.py NAME...` fuer `.y`-Programme (expr, egrep, bc): legt `NAME.y` (V7-Text) und `yaccpar` im Gast ab, laesst das **MUTOS-yacc** (E3a) laufen
  und speichert `y.tab.c` als `userspace/ergaenzung/NAME/NAME.c` hinter einem Kopfkommentar (erzeugt, nicht von Hand zu aendern).  Voraussetzung: `erg.py bau yacc`.  Gleiches
  Verfahren wie `vmake_gram.py` (E3b).  `erg.py` selbst kennt `.y` nicht: es baut `NAME.c` wie jedes Einzeldatei-Programm.  Kein Host-yacc beteiligt.
* Pruefung: `python3 -m pytest -q -m "not gast"` -> 203 bestanden, 2 Fehlschlaege, **beide nicht von E3c**: `test_ergaenzung_ordner_vollstaendig` (Ordner `mesg` hat kein `test/`, schon im Ausgangsstand)
  und `test_bau_alle_kennt_genau_die_fertigen_disketten` (`disks/gebaut` fehlt im Worktree).  `erg.py alles tty` nach den Aenderungen: B.

## Befunde je Programm

### tsort (V7 `tsort.c`)
Unveraendert, `cc -O -s`.  Kein Host-Referenzwert fuer Zyklen: GNU `tsort` ordnet Zyklen anders; die Zyklenausgabe (`x`, `y`) ist aus dem V7-Text abgeleitet (`findloop`).
Meldungen gehen nach stderr und werden nicht verglichen.  V7 beendet bei Zyklus mit Exit 0 (meldet nur).

### ranlib (V7 `ranlib.c`)
Eine Abweichung (kommentiert): `#define A_MAGIC2 A_MAGIC1`, falls fehlend -- das MUTOS-`a.out.h` kennt nur A_MAGIC1/3/4 (Ursache: Header; wie bei vmake `files.c`).
Das Archiv-/Objektformat von MUTOS (`doc/werkzeugkette/objformat.md`: Kopf 26 B mit `ar_size` 32 Bit, Symbol 12 B) passt zu den V7-Strukturen unveraendert (`struct ar_hdr`, `struct exec`, `struct nlist`
aus den MUTOS-Headern); ranlib erzeugt `__.SYMDEF` (Eintrag 12 B: Name 8 B + 32-Bit-Offset, big-endian -- *gemessen* am Test: Offsets 0x40, 0x40, 0x152 = 2 + 26 + 3x12 und + 26 + 248).
`ranlib` ruft `ar rl`/`ar rlb` per `system()`; die Datei `__.SYMDEF` entsteht im Arbeitsverzeichnis.  `cc` nimmt das Archiv danach beim Linken an (Test "link").
*Nicht geprueft:* ob `ld` die Tabelle `__.SYMDEF` zum Aufloesen benutzt (die Linkprobe haette auch ohne Tabelle funktioniert); Datum-Patch (`fixdate`) nur ausgefuehrt, nicht bewertet.

### dc (V7 `dc/dc.c`, `dc/dc.h`)
Vier Abweichungen, alle kommentiert; `dc.h` unveraendert.
1. **`dc.c` in drei Dateien geteilt** (`dc1.c`: Zeilen 4-575 = `main`, `commnds`; `dc2.c`: 576-1245; `dc3.c`: 1246-Ende), je mit den drei `#include`-Zeilen vorn.  Ursache: das ganze `dc.c`
   uebersetzt der Gast nicht -- *gemessen*: mit `-O` Abbruch des Laufs nach 21e9 Zyklen (Cap) ohne Binary, ohne `-O` `fatal error: symbol table overflow / error exit from assembler`
   (Assembler-Symboltabelle, Grenze pro Uebersetzungseinheit).  Geteilt baut es (die gemeinsamen Daten aus `dc.h` sind tentative Definitionen, `ld` loest sie).
2. **`#define interdata 1`** vor `dc.h`: der MUTOS-`cc` hat `char` **ohne** Vorzeichen (PDP-11: mit).  `dc.h` bringt fuer solche Maschinen vorzeichenerweiternde Fassungen von `sgetc/slookc/sbackc`
   (`#ifdef interdata`).  *Gemessen* ohne die Zeile: negative Zahlen als Muell (`\x01\x9c\x01`), `2vp` -> `2.0000000000` (richtig 1.4142135623), `>`-Vergleiche falsch, damit die Fakultaets-Schleife ohne Ende
   (der erste Testlauf blieb haengen: Zeitkappe, keine Ausgabe).
3. In `cond()` (jetzt `dc3.c`): `register int cc` statt `register char cc` -- das Ergebnis von `sbackc()` wird auf `<0`/`>0` geprueft (Ursache: unsigned char).
4. `cc` ohne `-O` (`"flags": "-s"` in `erg.json`).  Der erste Versuch mit `-O` an der ungeteilten Datei lief in die Zeitkappe; `-O` an den drei Teilen wurde **nicht** versucht (*offen*).

*V7-Verhalten, kein Fehler des Ports* (aus `dc.c` `tenot()` abgeleitet, vom Gast reproduziert): bei **ungerader** Skalierung wird eine fuehrende 0 gedruckt (`5k 1 3/p` -> `0.33333`, bei gerader `.3333`).  Der Test benutzt deshalb gerade Skalierungen
(Ausnahme: `bc`-Test "quirk").  `dc -` (so ruft `bc` es) behandelt `-` als Schalter (`dbg=1`), harmlos.
Nicht getestet: `!`, `?`, Arrays, `Q`, Speichererschoepfung ("Out of space"), Eingabe von der Tastatur.

### expr (V7 `expr.y`)
`expr.y` unveraendert; `expr.c` vom MUTOS-yacc im Gast erzeugt (Groessenklasse SMALL, E3a): keine Meldung, 17495 B.  `cc -O -s` ohne Meldung.  Keine Abweichung vom V7-Text.
V7-Fehler, den der Test **bewusst abbildet** (Erwartung aus dem Text): `rel()` hat `case LEQ: i = i>=0;` -- `expr 3 '<=' 5` ergibt in V7 `0` (richtig waere 1).  Der Rest stimmt mit GNU expr 9.7 ueberein.
Negative Zahlen sind kein gueltiger Operand von `arith()` (V7: "non-numeric argument", Exit 2; GNU akzeptiert) -- nicht getestet.

### egrep (V7 `egrep.y`)
`egrep.y` unveraendert; `egrep.c` im Gast erzeugt (Meldung: `conflicts: 2 shift/reduce`; *Annahme*, dass V7-yacc dieselben meldet -- nicht verglichen, kein zweites yacc).  `cc -O -s` ohne Meldung, keine Abweichung.
Erwartung GNU grep 3.11 `-E`; -s entspricht GNU `-q`.  `-b` (Blocknummer) nicht getestet.

### bc (V7 `bc.y`)
`bc.y` bis auf **eine kommentierte Abweichung** unveraendert: hinter `execl("/bin/dc")` und `execl("/usr/bin/dc")` steht ein Rueckfall `execvp("dc", {"dc","-",0})` (PATH-Suche).  Ursache: im Testgast gibt es weder `/bin/dc` noch
`/usr/bin/dc` (Platten voll, kein `chmod`); `dc` liegt auf `/mnt` (im PATH).  Nur erreicht, wenn beide V7-Pfade fehlschlagen.  So findet V7-bc dc: `/bin/dc`, dann `/usr/bin/dc`; `-l` laedt `/usr/lib/lib.b` (im Gast nicht vorhanden, nicht getestet).
`bc.c` im Gast erzeugt (`conflicts: 12 shift/reduce, 30 reduce/reduce`, wie *erwartet* fuer die V7-Grammatik, *nicht* mit V7-yacc verglichen).  **`cc -O` scheitert** (*gemessen*: `Fatal error in /usr/lib/c2`, vermutlich der Optimierer an `yyparse`), daher
`"flags": "-s"` (ohne `-O`, Code etwas groesser).  bc nutzt `fork`, `pipe`, `dup`, `execl` -- im Gast ohne Anpassung lauffaehig.
Der Test vergleicht gegen GNU bc 1.07.1; Ausnahme "quirk" (V7-dc, siehe oben).  Nicht getestet: `-l`, `-c`, `else`, Zeilenumbruch langer Ergebnisse, `=+` (V7 anders als GNU).

## Offen

* `dc`, `bc` ohne Optimierung gebaut; ob `dc` geteilt mit `-O` baut, nicht versucht.
* Die V7-yacc-Konfliktmeldungen von egrep/bc nicht gegen ein zweites yacc geprueft.
* `ranlib`: Wirkung von `__.SYMDEF` auf `ld` nicht isoliert (Linkprobe auch ohne Tabelle gruen).
* Tests von dc/bc: einzelne Erwartungen sind aus Handbuch/Quelle abgeleitet statt von einem Referenzwerkzeug (siehe `test/herkunft.txt`).
