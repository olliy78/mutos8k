# Ergaenzungen E2a: grep fgrep tr join du file (Plan 45)

**Ergaenzung, V7-Quelle, keine Originalreferenz.**  Quellen: `original/unix-v7/usr/src/cmd/NAME.c`, vom MUTOS-`cc -O -s` im Emulator-Gast uebersetzt
(Rahmen `tools/userspace/erg.py`, `doc/userspace/erg_e0.md`).  Kein Original zum Bytevergleich; Beweis = *baut* + *Gast-Test gleich Erwartung*.  Nichts hier ist "rekonstruiert".
Stand 2026-11-10, alle Werte *gemessen* (`erg.py alles`), sofern nicht als Annahme markiert.

| Programm | Ergebnis | Binaergroesse | Abweichung vom V7-Text |
|----------|----------|---------------|------------------------|
| grep  | B | 7684 | `#include <param.h>` statt `<sys/param.h>` |
| fgrep | B | 6986 | keine |
| tr    | B | 3162 | keine |
| join  | B | 7500 | keine |
| du    | B | 5768 | `<param.h>`, `<dir.h>` statt `<sys/...>` |
| file  | B | 8468 | `<param.h>` statt `<sys/param.h>` |

Abweichung, Ursache: V7-Header `sys/param.h`, `sys/dir.h` liegen nicht auf den MUTOS-Disketten (gemessen: `Can't find include file sys/param.h`); der Rahmen legt sie flach neben die Quelle
(`erg.json` `header`), daher ohne `sys/`; kommentiert mit `/* Differs from V7: ... */`.  Kein Compiler- oder libc-Problem; kein Gleitkomma, kein `yacc`.
Der V7-`param.h` (PDP-11-Werte) dient nur fuer `BSIZE`, `BSHIFT`, `DIRSIZ`, `major/minor`, Typen.

## Tests (Erwartung je Programm in `test/herkunft.txt`)

* **grep** (18 Faelle): Referenz GNU grep 3.11 (`/usr/bin/grep`; der Shell-Alias auf ugrep wurde nicht benutzt).  -v -c -n -l -h -s -e, -y (= GNU -i), `^ $ . *`, `[..]`, Stdin, Exit 0/1/2.  Nicht getestet: -b, Zeilen > 256 Zeichen.
* **fgrep** (18 Faelle): GNU `grep -F`; -v -c -n -l -h -x -s -f -e, Stdin.  Fehlermeldung `fgrep: can't open` aus dem Quelltext.  Eine erste Erwartung (`egrep:`) war von mir falsch gelesen; der Test hat es gezeigt (T), Erwartung korrigiert, danach gleich.
  Beobachtung V7: fgrep nennt sich in manchen Meldungen "egrep" (Quelle ist ein gemeinsamer Zweig).
* **tr** (18 Faelle): GNU coreutils 9.7; Bereiche, -d, -c, -cd, -cs, -s mit zwei Argumenten, Auffuellen, `\101`, `\012`, `\\`.
* **join** (14 Faelle): GNU coreutils 9.7 mit uebersetzten V7-Optionen (`-a1`, `-o 1.1 2.2`, `-j1 2 -j2 1`, `-t:`), Kreuzprodukt bei Mehrfachschluesseln, `-` fuer Stdin; Fehlertexte aus dem Quelltext.
* **du** (5 Faelle): GNU `du --apparent-size -B512` auf Dateien der Groesse 0, 1, 512, 513, 1000, 5000 Byte (`-a`, `-s`); V7 rundet `(st_size+511)>>9`.  `du DATEI` ohne `-a` druckt nichts (V7).
* **file** (5 Befehle): Erwartung von Hand aus `file.c`/`file.1` (GNU file spricht anders): c program text, assembler program text, ascii text, English text, data (Byte mit Bit 7), cannot stat, directory, `-f`-Liste (Exit 1), `-f` fehlt (Exit 2).

## Grenzen (*gemessen*, wo nicht anders vermerkt)

* **file erkennt keine Z8000-Programme:** MUTOS-a.out-Magic ist `E807` (`doc/werkzeugkette/objformat.md`), V7 kennt nur 0407/0410/0411.  `file /bin/cat` meldet `data`.  Archive (Magic `FF65` = 0177545) werden als `archive` erkannt (`/usr/lib/libc.a`).
  Nicht getestet: roff-Text (V7 liest `buf[-1]`), Geraetedateien, "commands text" (braucht Ausfuehrbit; kein `chmod` im Gast), Fortran.
* **du: Verzeichnisse nicht getestet.**  Im Gast gibt es kein `mkdir`/`ln`; `/tmp` ist nicht stabil (der Rahmen schreibt dort die Ausgabe).  Getestet ist nur der Dateizweig; Rekursion, Hardlink-Erkennung und die Zaehlung der Verzeichnisbloecke sind gebaut, aber ungeprueft.
* **grep/fgrep -b:** V7 gibt Blocknummer zu 512 Byte, GNU Byte-Offset -- nicht getestet.
* **tr:** V7 `-s` mit nur einem Argument quetscht nichts (GNU schon), NUL wird verworfen -- aus dem Test genommen.
* **join:** `-e` mit unpaarigen Zeilen und mehrfache Leerzeichen als ein Trenner nicht getestet (V7 und GNU verschieden).
* Tests laufen als root; Gastzeit nicht 1987 (nur fuer `make` relevant).
