# Kleine Wurzel-Befehle: sync, cat, date, ls, stty (Branch us-klein)

Alles *gemessen* (`pipeline.py alles NAME --c2emu`), soweit nicht als *Annahme* markiert.  Quellen `userspace/NAME/NAME.c`,
Karte/Listing daneben.  Vergleichsreferenz: Hippe-Sammlung (TUHS) `original/hippe-v7/usr/src/cmd` (nur `cat.c`, `sync.c` vorhanden).

## sync -- ganze Datei bytegleich
V7-`sync.c` unveraendert (identisch zur Hippe-Sammlung).  `cc -O -s`: 116 von 116 Byte gleich (Text 114, Daten 2, BSS 2), auch mit c2-Modell (0 Regeln noetig).

## cat -- V7-`cat.c` unveraendert, eigener Code befehlsgleich
V7 = Hippe-Sammlung (diff leer).  Eigener Code 0030-0222: 184 von 184 Befehlen, 0 Befehlsabweichungen; die 9 Bloecke im Bericht sind nur
Adressoperanden (libc-Aufrufziele `setbuf`, `_flsbuf`, `fclose`, Datenadressen `_iob`/`stdbuf`, die mit dem groesseren libc-Teil wandern).
Ganzdatei **nicht** bytegleich (Text 5128 statt 3782): `stdio` zieht die ausgelieferte `libc.a` nach (Stolperstein 1 in README.md).

## date -- V7-`date.c`, Header lokal
V7-Text unveraendert bis auf `#include "timeb.h"`/`"utmp.h"` statt `<sys/..>`: `/usr/include` hat beide nicht (V7-Header liegen auf `/mnt`).
Eigener Code 0030-04AC: 400/400 Befehle, 8 Bloecke = nur libc-Aufrufziele (`localtime`, `gmtime`, `asctime`, `dysize`).
Ganzdatei nicht bytegleich (Text 6484 statt 5144), libc-Teil wie bei `cat`.

## ls -- V7-`ls.c`, Header lokal
Wie `date`: `"param.h"`, `"dir.h"` aus `original/unix-v7/usr/include/sys`.  Eigener Code 0030-0892: 684/684 Befehle, 14 Bloecke = libc-Ziele
und Datenadressen; `CP R2,#D+28C` gegen `CP R2,#%2000` ist ein Normalisierungsartefakt (gleiche Konstante 0x2000, Original-Textende 0x1D74 + 0x28C).
Ganzdatei nicht bytegleich (Text 8878 statt 7540).

## Neue c2-Regeln (in `uspace.py:c2_emu_s`, Stellenzahl = gemessen an diesen Programmen)
Der Original-`c2` ist aelter als der der Disketten.  Zusaetzlich zu R1-R3 (`init.md`) fuer das Original-Verhalten:
* **R4** `CP mem,#k` (Rahmen-/Direktoperand) -> `LD R0,mem ; CP R0,#k`; weitere `CP mem,..` direkt hinter einem `JR cc` der Kette nutzen R0 weiter.
  cat 4x, date 8x, ls 3x.  (In `init` ohne Treffer im Eigencode, aber in den libc-Gliedern gesehen.)
* **R5** keine Kopienpropagation: `LD rA,rB ; TEST rB` -> `TEST rA`; `LD rA,rB ; LD rC,rB` -> `LD rC,rA`.  cat 1x, date 1x.
* **R6** `LD rA,M ; TESTB @rA ; JR cc ; LD rB,rA` -> `LD rB,M` (geladener Wert wird nicht weitergereicht).  date 1x.
* **R7** `LDB RLn,mem ; CP Rn,..` -> der Original-`c2` setzt `XORB RHn,RHn` dazwischen (der neue weiss, dass RHn schon null ist).  ls 3x.
Regression: `init` bleibt bei 0 Abweichungsbloecken (536/536) mit R1-R7.

## Pipeline-Erweiterungen
* `PROGRAMME`: sync, cat, stty, date, ls (Diskette `root`, `bin/NAME`); Zusatz-Header fuer date/ls.
* `c2_emu_s`: R4-R7.
* Stolperstein: `/usr/include` hat nur `a.out ar ctype execargs grp math pwd sgtty signal stdio symbol time sys/{stat,types}`; V7 `sys/param.h`, `sys/dir.h`,
  `sys/timeb.h`, `utmp.h` muessen lokal als `"x.h"` eingebunden werden (Dateiname ohne Verzeichnis, `-I/mnt`).
