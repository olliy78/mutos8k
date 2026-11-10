# Ergaenzungen E2b: sort, find, diff, diffh (Plan 45)

*Ergaenzung, V7-Quelle, keine Originalreferenz* -- diese Programme liegen nicht auf den MUTOS-Disketten und sind nicht rekonstruiert.
Quelle: `original/unix-v7/usr/src/cmd/{sort,find,diff,diffh}.c`.  Stand 2026-11-10, Rahmen `tools/userspace/erg.py` (E0).  Alle Zahlen *gemessen*, soweit nicht als Annahme markiert.

| Programm | Ergebnis | Binaergroesse | Quelltext |
|----------|----------|---------------|-----------|
| sort | B | 11848 B | unveraendert |
| find | B | 11568 B | Abweichung: `sys/dir.h` flach |
| diff | B | 11170 B | unveraendert |
| diffh | B | 7552 B | unveraendert |

Alle vier uebersetzt der MUTOS-`cc -O -s` ohne Meldung (kein Problem mit 8 Zeichen oder K&R).  Text+Daten passen in 64 KB (Binaer < 12 KB).
Bauzeiten im Gast 77 bis 162 s wall clock.

## Abweichung find.c
`#include <sys/dir.h>` -> `#include <dir.h>` mit `/* Differs from V7: ... */`; `erg.json` `"header": ["sys/dir.h"]` (V7-Header unveraendert, fehlt in `/usr/include` der Platte `usr`;
Meldung ohne: `Can't find include file sys/dir.h`).  Ursache: Header-Ablage des Rahmens.

## sort
Test (`test/befehle.sh`): -r -u -f -d -n -nr, `-t: +1n`, `+1 -2`, `+0 -1 -r`, mehrere Dateien, `-m`, `-`/Stdin, `-o`, `-c` (sortiert, Exit 0) und eine Datei `s7.txt` mit 1200 Zeilen (13200 B).
Erwartung GNU coreutils sort 9.7, `LC_ALL=C`, V7-Syntax auf GNU uebersetzt; Gast = Erwartung.
*Annahme:* `s7.txt` erzwingt Zwischendateien in `/tmp` (V7 `sort` belegt per `sbrk` den Rest des 64-KB-Segments; ob konkret gespillt wurde, ist nicht eigens beobachtet).  `/tmp` im Gast ist die leere Platte, das reicht.
Abweichung V7/GNU (aus dem Test genommen): `sort -b` ohne Schluessel -- V7 wendet `-b` nur auf Feldvergleiche an, der Ganzzeilenvergleich bleibt bytegenau (`" leading"` steht vorn), GNU ignoriert die fuehrenden Blanks der ganzen Zeile.  Gemessen: erste Testfassung wich genau hier ab (T), sonst gleich.
Nicht getestet: `-T`, `-i`, `-c` bei Unordnung.

## find
Im Gast fehlt `pwd` (Platte `cmd` nicht eingehaengt), `find` ruft beim Start `popen("pwd")` (V7-Text): jedes Mal `sh: pwd: not found` auf stderr, Ergebnisse unberuehrt (stdout wird verglichen).
Kein Host-Referenzwerkzeug: Der Gast hat nur `/bin`, `/usr/bin`, `/usr/lib`, `/usr/include` (feste Inhalte, Modi, Groessen); der Test gibt `ls -l` dieser Verzeichnisse mit aus und
die find-Ausgaben (`-name -type -size -perm -mtime -a -o ! \( \) -exec -print`, mehrere Startpfade) wurden von Hand gegen Handbuch `find.1` und diese Daten geprueft (z. B. `-size +50`: c0, c1, libc.a; `-perm 751`: c0 c1 c2 cpp).  Erwartung = Gastausgabe; die Reihenfolge ist die Verzeichnisreihenfolge der Platte.
Nicht getestet: `-user/-group`, `-newer`, `-ok`, `-inum`, `-links`, Fehlermeldungen (stderr).

## diff und diffh
`diff` ruft fuer `-h` per `execv("/usr/lib/diffh", ...)` das Hilfsprogramm `diffh`; ohne `-h` wird es nicht gebraucht.  `diffh` ist ein eigenes Programm (`userspace/ergaenzung/diffh/`).
**`diff -h` im Gast nicht testbar** (gemessen): die Platte `usr` ist voll; `cc -o /usr/lib/diffh` endet mit `ld:/usr/lib/libc.a(strout.o): output error`, `cat /tmp/dh >/usr/lib/diffh` schreibt nur 4096 Byte.  Ausserdem gibt es kein `chmod`.  Der Quelltext wurde nicht auf einen anderen Pfad geaendert.  Auf einem System mit Platz: `diffh` nach `/usr/lib/diffh` installieren (Modus 755).
Nicht getestet ausserdem: Verzeichnisvergleich (`diff dir1 dir2`; kein `mkdir`/`pr` im Gast).

**diff** (12 Faelle): Normalformat, `-e`, `-f`, `-b`, Stdin (`-`), leere Datei, Exit 0/1, mehrere Bloecke; Erwartung GNU diffutils 3.10, gleich.
**diffh** (3 Faelle): direkt aufgerufen; gleicht GNU bei kleinen, einzelnen Aenderungen (und Exit 0 bei gleichen Dateien).
Abweichung diffh/GNU (aus dem Test genommen, *V7-Verhalten laut Quelltext/Handbuch*, nicht Compilerfehler): `diffh` bildet bei dichten Aenderungen oder am Dateiende groebere Bloecke (`3,7c3,7`, `1,$c1,$`, `11,$d10` -- `$` fuer "bis Dateiende") und liefert immer Exit 0 (auch bei Unterschieden).  Gemessen an `a.txt/b.txt`, `c.txt/d.txt`.

## Grenzen
Tests laufen im Gast als root.  Gast-Zeit nicht 1987.  Ergebnisse nur im Gast (Emulator) gemessen, nicht an einer echten Z8000-Maschine.
