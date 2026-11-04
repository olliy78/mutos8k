# Kleine Wurzel-Befehle: sync, cat, date, ls (rekonstruiert), stty (offen) (Branch us-klein)

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

## stty -- NICHT V7: Quelle offen (Befund)
`bin/stty` (Text 4652, Daten 1162, BSS 1054) ist eine erweiterte Fassung; die V7-`stty.c` als Quelle genuegt nicht (V7-Bau wuerde ausserdem nicht uebersetzen:
das MUTOS-`sgtty.h` hat `short sg_flags` plus Bytefelder `sg_nldly sg_crdly sg_htdly sg_vtdly sg_width sg_length`, Modi `SCOPE 0400 INDCTL 01000 XTABS 02000`,
aber **keine** `NLDELAY/CR0../ALLDELAY`-Makros; Probebau mit V7-Text: ~40 "undefined"-Meldungen und kein Binary).
Aus den Daten des Originals gelesen (`userspace/stty/stty.strings`, Tabellen bei Datenadresse 0x1232 ff.):
* Geschwindigkeitstabelle wie V7 (`0 50 75 ... 9600 exta extb`, `134.5`), Modustabelle (Name, set, reset) nur: `even odd raw cooked crmod echo LCASE lcase tabs cbreak scope indctl tandem`
  und die `-`-Formen (`crmod` statt V7 `nl`; `-tabs` setzt `XTABS` 02000).
* Weitere Woerter: `ek erase kill gspeed hup nl0..nl3 cr0..cr3 tab0..tab2 ff0 ff1 bs0 bs1 width length nl cr ht vt dac ban tek sat tty33 tty37 vt05 tn300 ti700`
  -- Verzoegerungen und Terminaltypen als Namen, nicht als Makrotabelle; Meldung `"%s - no effect\n"`.
* Ausgabe: `input speed `/`output speed `/`speed `, `erase = ...`, Flags `even odd raw crmod echo lcase -tabs cbreak scope indctl tandem`, Zeile `nldly crdly htdly vtdly`
  (Feld-Werte `"%s\t%d\n"`), `width`, `length`; Anwendungsstrings in `fprintf`-Aufrufen (21 Aufrufstellen).
*Annahme:* Quelle ist ein Derivat (PWB/Berkeley-nah), nicht V7; Rueckbau braucht eigene Dekompilierung (Eigencode ab 0x30; Karte `userspace/stty/k.txt`).
Hippe-Sammlung (TUHS) hat kein `stty.c` zum Vergleich; `original/sys3/cmd/stty.c` (termio) passt nicht zum `sgttyb`-Aufbau.
Die V7-Quelle kann als Ausgangsbasis dienen: `original/unix-v7/usr/src/cmd/stty.c`.
