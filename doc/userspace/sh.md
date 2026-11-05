# /bin/sh -- Befunde und Rekonstruktion (Branch us-sh)

Alles *gemessen*, soweit nicht als *Annahme* markiert.  Werkzeug: `doc/userspace/pipeline.md`; Quelle: `userspace/sh/*.c|*.h`
(V7 `usr/src/cmd/sh`, 20 Module); Karte/Listing: `userspace/sh/{k.txt,sh.lst,sh.namen,sh.strings}`.

## Ergebnis (Stand der Messung)
* `/bin/sh` der Wurzeldiskette: 18296 B, Kopf `e807 416a 05fe 014a 0 0 0 0001` (Text 16746, Daten 1534, BSS 330, gestrippt).
* V7-Quelle, im Gast mit dem MUTOS-`cc -O` je Modul uebersetzt (`cc -O -c`) und mit `cc -s -o sh *.o` gebunden
  (Reihenfolge der V7-Makefile: Glob `*.o` = alphabetisch, bestaetigt: `args.o` steht bei 0x30): **18296 B, Text/Daten/BSS wie das Original**.
* Eigener Code 0030-3E44: 5245 Befehle im Original; der Klartext-Bau hat dieselbe Laenge und stimmt bis auf 15 Abweichungsbloecke
  (Messwert: 5249 von 5266 Befehlszeilen gleich ohne c2-Modell) ueberein.  Der libc-Teil (3E44-4170, 280 Befehle) stimmt mit der
  **ausgelieferten** `libc.a` Befehl fuer Befehl ueberein (0 Bloecke) -- anders als bei `init` braucht `sh` keinen Rueckbau der Bibliothek
  fuer den Befehlsvergleich (`--libc alt` siehe unten).
* Die 15 Bloecke sind: fuenf kleine c2-Regeln (R11-R14, unten), vier Karten-Artefakte (falsche Einstiege, Disassemblierung mitten im Befehl),
  zwei Adressverschiebungen (Daten), ein `JR`/`JP`-Unterschied (folgt aus den Laengen der anderen Stellen).  Ganzdatei-Bytegleichheit ist
  deshalb noch **nicht** gemessen (siehe Stand unten).

## Gewinnung und Karte
    python3 -I tools/userspace/pipeline.py holen sh          # root: bin/sh
    python3 -I tools/userspace/pipeline.py karte sh --ablegen
Karte: 2 Runden, 1043 Einstiege, 0 ungueltig; 13 Ueberlappungen und 7 "Marken mitten im Befehl" (Fehleinstiege aus `--vorschlaege`; sie erzeugen
im Vergleich Scheinbloecke, siehe Offen).  151 Funktionen (Aufrufziele), 29 libc-Treffer (26 eindeutig); 81 Zeichenketten.
libc-Reihenfolge im Abbild: `exit`, `setjmp`, `stty`(`gtty`), `alarm`, `chdir` ... `signal`, `stat`, `times`, `umask`, `unlink`, `wait`, `write`, `cerror`, `csv`.

## Mehrdatei-Bau (Erweiterung der Pipeline)
* `PROGRAMME["sh"]` hat als Quelle das **Verzeichnis** `userspace/sh`: alle `*.c` (alphabetisch) werden einzeln mit `cc -O -c` uebersetzt, dann
  `cc -s -o NAME *.o` (mit `--libc alt` die Archive hinter den Objekten); die `*.h` des Verzeichnisses liegen auf `/mnt`.
  V7-`sys/dir.h` und `setjmp.h` kommen aus `original/unix-v7/usr/include` (siehe Stolpersteine).
* `--asm`: je Modul `cc -O -S`; **die `/tmp`-Diskette (ca. 250 KB) fasst nicht alle `.s` neben den Compiler-Temporaerdateien**.  Deshalb laufen die `.s`
  in eigenen kurzen Sitzungen (je <= 40 KB Quelle).  Nach dem Binden `rm -f *.o` (sonst fehlen die letzten Module).
* `--c2emu` schreibt jedes Modul-`.s` nach dem Regelmodell um (`C2_AUS` je Programm), assembliert und bindet erneut (`NAME_c2`).
* `--variante NAME` benennt die Bauvariante (Dateien `work/bau/NAME.*`); je Quellfassung ein sprechender Name:
  `neu` = erste V7-Fassung, `v1` = alle `REG` bei `char`-Skalaren entfernt, `f_<modul>` = nur dieses Modul mit `REG`,
  `v7regfix` = aktuelle Quelle mit Regelmodell, `v7regalt` = aktuelle Quelle mit `--libc alt`.
  (Die Messreihen der Fruehzeit liefen unter `neu`/`v1`/`f_*`; die Zahlen stehen unten bei der jeweiligen Fassung.)

## Abweichungen vom V7-Text (alle belegt)
Reihenfolge der Messung: Mittelweg (je Modul erst V7 einsetzen).  Ergebnis der Reihe (Befehle, Bloecke gegen das Original):
| Fassung | Text | Befehle gleich | Bloecke |
|---------|------|----------------|---------|
| V7 unveraendert (`neu`, Bau 1) | 16368 | 4805 von 5245 | 237 |
| ohne `REG` bei allen `char`/`BOOL`-Skalaren (`v1`) | 16816 | 5179 | 52 |
| `REG` nur in einem Modul wieder gesetzt (`f_*`, 8 Laeufe) | -- | je Modul bestimmt | -- |
| aktuelle Fassung | **16746** | 5249 von 5266 (Rest = c2-Regeln, Karte) | 15 |

1. **`REG` vor `char`/`BOOL`-Skalaren fehlt im Original** (das alte `cc` legt sie auf den Stack, `LDB %FFF3(R14),RL2`): entfernt in `name.c`
   (`first`), `cmd.c` (`inout: c`), `print.c` (`stoi: c`), `string.c` (`any: c, d`), `expand.c` (`slash`, `c`), `service.c` (nicht: `trim` behaelt `REG CHAR c,q`),
   `macro.c`, `word.c`.  **Ausnahmen, in denen `REG` bleibt (gemessen, Modul-Vergleich `f_name`/`f_service`/`macro`):** `name.c:readvar c`, `service.c:trim c,q`,
   `macro.c:macro savqu` (nicht `savq`).  Die Regel dahinter (welche `register char` das alte `cc` behaelt) ist *nicht* bestimmt; beobachtet: von zwei
   `register`-Zeichen derselben Funktion (`savqu`, `savq`) wird nur das erste Register.  Am Rand jeder Stelle steht der V7-Text als Kommentar.
2. `name.c: chkid` liefert `return(0377)` statt `return(TRUE)`: das Original gibt den Zeichenwert 255 zurueck (`LD R2,#%00FF`), unser `c1` bildet `-1`.
3. `expand.c`: `#include "dir.h"` statt `<sys/dir.h>` (MUTOS hat das Verzeichnis `sys/dir.h` nicht; gleicher Inhalt, keine Wirkung auf den Code).
4. Meldungstexte (`msg.c`), Builtins, Signalbehandlung, `setbrk`/`brkincr`: **gleich V7** (die Zeichenketten aus `sh.strings` stimmen mit `msg.c`
   ueberein, einschliesslich `FILEMATCH`, `/tmp/sh-`, `.profile`; Daten 1534 B bytelang gleich der Quelle).  Es wurden keine funktionalen
   Abweichungen gefunden; *Annahme:* MUTOS-`sh` = V7-`sh` (sys137) ohne Aenderung am Text, nur anderer Compilerstand.

## Frage: anderer c2-Stand oder ueberangepasstes Regelmodell? (gemessen, Entscheidung)
`init` (und `cat`, `date` ...) brauchen R1, R2, R4 ... (der Original-`c2` ist aelter als der ausgelieferte).  Fuer `sh` gilt das **nicht**:
* Der Klartext-Bau (ausgelieferter `c2`, keine Umschreibung) hat dieselbe Textlaenge (16746) wie das Original; mit den Regeln R1/R2/R4/R5 umgeschrieben
  (erster `--c2emu`-Lauf: R1 10x, R2 21x, R4 21x, R5 34x) waere er laenger/kuerzer.  Das Original zeigt an den Stellen die Form des ausgelieferten `c2`:
  `ld r2,r3 ; test r3` (`0E3A`, nicht `test r2`), `ld r2,r3 ; ld mem,r3` (`2CC4`), `INC R15 ; LD @R15` und `XORB ; LDB mem` wie der Disketten-`c2`.
* **Entscheidung:** `sh` wurde mit einem **anderen (neueren) `c2`-Stand** als `init` & Co. uebersetzt -- naeher am ausgelieferten, aber nicht
  identisch: es bleiben die kleinen Unterschiede R11-R14 (unten).  Das Regelmodell ist damit nicht "ueberangepasst", sondern *programmabhaengig*:
  `C2_AUS["sh"]` schaltet R1-R10 und R30/R31 ab.
* Gegenprobe: `vergleich sh --ohne-c2` (kein Modell, Rohvergleich): dieselben 15 Bloecke wie mit Modell; mit allen Regeln umgeschrieben und
  assembliert (`--c2emu` ohne `C2_AUS`) stimmt die Laenge nicht.  Der Lauf `v7regfix` (nur R11-R14) ist die positive Gegenprobe (Ergebnis unten).
* *Annahme:* die Rootdiskette ist aus Programmen verschiedener Uebersetzungslaeufe zusammengesetzt (sh juenger als init).  Offen: die Compilerstaende
  der anderen Programme gegen `sh` ordnen (`cat`/`ls` zeigen R4, `sh` nicht).

## Neue c2-Regeln (nur `sh`, Stellenzahl aus dem Bau; Nummern ab R11)
* **R11** `ld rA,rB ; [test rB | ld MEM,rB | jr cc L]* ; cp rA,#k` -> `cp rB,#k` (der Original-`c2` leitet die Kopie nicht in den Vergleich weiter).
  6 Stellen (`gmatch` Switch 3x, `skipto`/`getch` 18D4, `2CB0`, `34A4`).
* **R12** `ldb rl0,rlN ; cpb rlN,X` mit frueherem `ldb MEM,rlN` -> `ldb rl0,MEM ; cpb rl0,X` (nach einem Sprung wird das Byte neu geladen).  1 Stelle (`any`).
* **R13** `ld MEM,rN ; cp MEM,#k` -> `cp rN,#k` (das gerade gespeicherte Register wird verglichen).  2 Stellen (`main` 1AB8, `34A4`).
* **R14** `ldb MEM,rlN ; and rN,#k` -> dazwischen `ldb rlN,MEM ; xorb rhN,rhN` (Reload, `stoi`: `digit(c)`).  2 Stellen vom Modell, im Original 1 belegt (`26A0`).
  (*Die zweite Stelle des Modells ist noch zu pruefen.*)

## `--libc alt` und libc-Teil
Siehe Abschnitt "Messung" unten (Lauf `v7regalt`).  Der Befehlsvergleich des libc-Teils ist mit der ausgelieferten `libc.a` bereits 280/280.

## Messung (Abschlusslaeufe)
(wird nach den Laeufen `v7regfix`/`v7regalt` ergaenzt)

## Offen
* Karten-Artefakte beseitigen (`karte_extra.txt` / falsche `code`-Einstiege, 7 Marken mitten im Befehl: `0240`, `0CC4`, `2062`, `206E`, `2072`, `20DA`, `2420`;
  `0200/0202` in `args.c`).  Sprungtabellen (`dwc`) wurden nicht gefunden; das `switch` des MUTOS-`cc` ist ein Vergleichsketten-Code.
* Regel zu `register char` (siehe Abweichung 1) und die zweite R14-Stelle.
* Ganzdatei-Bytegleichheit (`cmp sh sh.orig`): erst nach Bereinigung der verbleibenden Blocke zu messen.
