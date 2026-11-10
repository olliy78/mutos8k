# Ergaenzungen E1b: uniq comm split tail cal look nice time test (Plan 45)

**Ergaenzung, V7-Quelle, keine Originalreferenz.**  Diese Programme liegen nicht auf den MUTOS-Disketten; sie sind die unveraenderten V7-Quellen
(`original/unix-v7/usr/src/cmd/NAME.c`), vom MUTOS-`cc -O -s` im Emulator-Gast uebersetzt (Rahmen `tools/userspace/erg.py`, `doc/userspace/erg_e0.md`).
Es gibt kein Original zum Bytevergleich; Beweis = *baut* + *Gast-Test gleich Erwartung*.  Nichts hier ist "rekonstruiert".

Ordner: `userspace/ergaenzung/NAME/` (`NAME.c`, `erg.json`, `test/befehle.sh|erwartet.txt|herkunft.txt|eingabe/`).
Aufruf: `K1520EMU=... python3 -I tools/userspace/erg.py alles NAME...` (gemessen 2026-11-10, je Programm 1 bis 2 Min Wanduhr fuer Bau, ca. 1 Min Test).

## Ergebnis (gemessen)

| Programm | Ergebnis | Binaergroesse | Quelltext-Abweichung von V7 |
|----------|----------|---------------|-----------------------------|
| uniq  | B | 6034 | keine |
| comm  | B | 6050 | keine |
| split | B | 5622 | keine |
| tail  | B | 1766 | keine (`erg.json`: Header `errno.h`) |
| cal   | B | 5452 | keine |
| look  | B | 6254 | keine |
| nice  | B | 6208 | keine |
| time  | B | 6634 | `#include <times.h>` statt `<sys/times.h>` (kommentiert) |
| test  | B | 2874 | keine |

B = baut, Test gleich.  Keines musste Gleitkomma, `yacc` oder eigene libc-Glieder: `sys_errlist` (nice, time) loest die ausgelieferte `libc.a` auf (gemessen: Bau ok).

## Abweichung `time.c`
`erg.py` legt V7-Header flach (`basename`) nach `/mnt`; `#include <sys/times.h>` fand deshalb nichts (gemessen: `Can't find include file sys/times.h`, N).
Behoben im Quelltext mit Kommentar `/* Differs from V7: ... */` (Ursache: Header-Ablage des Rahmens, nicht Compiler).  `times.h` selbst ist V7-unveraendert.

## Testumfang und Erwartung (Herkunft je Datei `test/herkunft.txt`)
Im Gast gibt es nur sh, cat, ls, date, stty, sync; Marken laufen daher ueber Here-Documents statt `echo`, Rueckgabewerte ueber `cat <<RC`.

* **uniq, comm, split, tail, look, test**: Erwartung vom Host (GNU coreutils 9.7 bzw. util-linux 2.41.5 `look`), V7-Syntax mit Wrapper uebersetzt (`-N`/`+N` bei uniq und tail, `-N` bei split, `tail -Nr` als `tail|tac`, `uniq -c` mit `%4d `).  *Gemessen*: gleich.
* **cal**: auf dem Host gibt es kein `cal`.  Erwartung *abgeleitet* aus `cal.c`/`cal.1` (Layout) und Python-`calendar` (Tagesraster 1900, 2000, 2024, 2026); 9 1752 von Hand (historisch).  Getestet auch Jahresansicht 2026, `Bad argument`, Aufruf ohne Argument.  Gast = Erwartung.
* **nice, time**: kein Referenzwerkzeug; Erwartung aus Quelltext und Handbuch.  `nice`: Aufruf, Option `-n`, Usage, Fehlerpfad `No such file or directory: CMD`.  Die Wirkung der Prioritaet ist im Gast **nicht** beobachtet (Annahme: `nice()` des MUTOS-Kernels, `kernel/conf/sysent.c` Nr. 34, wirkt).
  `time`: Weitergabe von Ausgabe und Exit-Status (auch 3 und 1 bei unbekanntem Befehl).  Die Zeitwerte auf stderr (real/user/sys) sind **nicht** geprueft: nicht deterministisch, und der Gast hat kein `wc`/`ed`.  Annahme: `times()` liefert brauchbare Werte; ungeprueft.  `time.c` schreibt Nullbytes in die Ausgabe (`printf("%c", 0)` fuer `sep`/`nsep`) -- V7-Verhalten.
* **test**: Rueckgabewerte von 28 Ausdruecken (-r -w -d -f -s -n -z, = !=, -eq .. -le, !, -a, -o, Klammern) gleich GNU `test`.  Nicht getestet: `-t`, `-l`, die Form `[ ... ]` (Binaer nicht als `[` verlinkt).

## Abweichungen V7 gegen GNU (aus dem Test ausgenommen)
* **tail** bei Datei **ohne** Schlusszeilenumbruch: `tail -2` auf `abc\ndef\nghi` liefert im Gast alle drei Zeilen (`abc def ghi`), GNU nur `def ghi`.  V7 zaehlt die unvollstaendige letzte Zeile nicht als Zeile (`tail.c`, Rueckwaertssuche nach `\n`); *Annahme*, dass das dem V7-Quelltext entspricht und nicht dem Compiler -- nicht an einer PDP-11 gegengeprueft.  Fall aus dem Test genommen.
* **uniq -c**: V7 `%4d `, GNU `%7d `; im Test durch den Wrapper angeglichen.
* **look**: V7 ohne Dateiargument nutzt `/usr/dict/words` (fehlt im Gast; nicht getestet).  Mit Datei faltet/filtert V7 nur bei `-f`/`-d` -- Testdateien sind passend sortiert.
* **tail -r**, `cal`-Format, `nice`/`time`-Meldungen: GNU/BSD abweichend, daher Erwartung aus V7-Text.

## Grenzen
Alle Tests laufen im Gast als root; Rechtepruefungen (`test -r/-w`) sind damit schwach.  Gast-Zeit nicht 1987 (nur fuer `make` relevant).
