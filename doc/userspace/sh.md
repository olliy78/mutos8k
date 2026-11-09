# /bin/sh -- Befunde und Rekonstruktion (Branch us-sh)

Alles *gemessen*, soweit nicht als *Annahme* markiert.  Werkzeug: `doc/userspace/pipeline.md`; Quelle: `userspace/sh/*.c|*.h`
(V7 `usr/src/cmd/sh`, 20 Module); Karte/Listing: `userspace/sh/{k.txt,sh.lst,sh.namen,sh.strings}`.

## Ergebnis (gemessen)
**`/bin/sh` ist ganzdatei-bytegleich reproduziert**: 18296 B, `cmp` gegen das Original der Wurzeldiskette: 0 abweichende Bytes
(Variante `v7fix_c2`; Befehle: `pipeline.py bau sh --c2emu --variante v7fix`, dann `cmp work/bau/v7fix_c2.bin work/sh.orig`).
Das gilt mit der **ausgelieferten** `libc.a`; ein Bau mit `--libc alt` (`v7regalt`) ist byteweise gleich dem ohne (0 Unterschiede):
`sh` braucht keinen Rueckbau der Bibliothek, der libc-Teil (3E44-4170, 280 Befehle) steckt unveraendert in der Diskettenbibliothek.
* Kopf `e807 416a 05fe 014a 0 0 0 0001`: Text 16746, Daten 1534, BSS 330, gestrippt.
* Bau: V7-Quelle (20 Module) je Modul `cc -O -c`, gebunden mit `cc -s -o sh *.o` (Glob = alphabetisch; `args.o` steht bei 0x30).
* **Ohne** Umschreibung des Assemblers (`v7regfix`, nur `cc -O`): gleiche Laenge (Text/Daten/BSS wie das Original), Eigencode 5249 von 5281
  Befehlszeilen gleich; Rest = die kleinen c2-Unterschiede R11-R14/R16 (unten).  Mit dem Modell (nur diese fuenf Regeln, 9 Stellen) und
  einem Wort aus Daten (R16) ist die ganze Datei gleich.

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
* Gegenprobe (gemessen): (1) Der Klartext-Bau ohne jede Umschreibung ist laengengleich (16746) und hat 5249 von 5281 Befehlszeilen gleich.  (2) Mit dem vollen
  `init`-Regelmodell (R1 10x, R2 21x, R4 21x, R5 34x ...) umgeschrieben und neu assembliert ist der Bau **nicht** gleich (Text 16750 statt 16746, mehr Abweichungsbloecke als
  ohne Modell: 26 gegen 15).  (3) Mit nur R11-R14/R16 (9 Stellen) ist die Datei bytegleich.  Das Modell fuer `init` ist also nicht falsch, gilt aber fuer `sh` nicht.
* *Annahme:* die Rootdiskette ist aus Programmen verschiedener Uebersetzungslaeufe zusammengesetzt (sh juenger als init).  Offen: die Compilerstaende
  der anderen Programme gegen `sh` ordnen (`cat`/`ls` zeigen R4, `sh` nicht).

## Neue c2-Regeln (nur `sh`; Nummern R11-R16, Stellenzahl aus dem Bau `v7regfix_s`)
Alle wirken auf die `cc -O -S`-Ausgabe (`c2_emu_s`) und sind je Programm abschaltbar (`C2_AUS`).
* **R11** `ld rA,rB ; [test rB | ld MEM,rB | jr cc]* ; cp rA,#k` -> `cp rB,#k` (rA Scratch-Register r0-r5; der Original-`c2` leitet die Kopie nicht in den
  Vergleich weiter).  **4 Stellen**: `gmatch` (expand.c, Switch ueber `c`: 3 Vergleiche in einer Kette = 1 Stelle), `macro.c`, `service.c` (3 Ketten), `xec.c`.
  Gegenprobe: ohne die Einschraenkung auf Scratch-Register traf R11 auch `ld r11,r2 ; cp r11,#k` (Registervariable) und verlaengerte den Bau um 2 Byte.
* **R12** `ldb MEM,rlN ; ... ; ldb rl0,rlN ; cpb rlN,X` -> `ldb rl0,MEM ; cpb rl0,X`, nur wenn das Byte vorher **geladen** wurde (`xorb` direkt vor dem Speichern),
  nicht bei einem Aufrufergebnis (`macro.c skipto` bleibt).  **1 Stelle** (`any`, string.c).
* **R13** `ld MEM,rN ; cp MEM,#k` -> `cp rN,#k`.  **2 Stellen** (`main` in main.c: `IF dolc<2`; xec.c).  Das ist das Gegenstueck zu R4 (c2-Modell von `init`: dort laedt
  das Original `R0`; hier vergleicht es das gerade gespeicherte Register).
* **R14** `ldb rlN,@rM ; xorb rhN ; ldb MEM,rlN ; and rN,#k` -> `ldb rlN,MEM` direkt hinter dem Speichern.  **1 Stelle** (`stoi`, print.c: `WHILE (c = *cp, digit(c))`);
  dieselbe Form mit Offset-Operand (`word.c`) wird **nicht** nachgeladen -- Abgrenzung nach Gegenprobe (die allgemeine Fassung traf 2 Stellen und verlaengerte den Bau).
* **R16** `jp ne,L` mit Rueckwaertsabstand genau 256 Byte (`word()`: `and r2,#%80 ; jp ne,L7 ; ... ; jp eq,L7`) -> im Original ein kurzes `JR NZ` (`EE80`).
  **1 Stelle.**  Der Gast-`as` lehnt dieses `jr` mit `ILLEGAL VALUE` ab (Grenzfall -256 Byte); das Wort wird deshalb als Daten `wval -%1180` (= `0xEE80`) ausgegeben.
  *Befund:* der `as`/`c2`-Stand des Originals unterscheidet sich von dem der Diskette im Grenzfall der Sprungweite.
(R15 wurde erprobt und verworfen: `ld r11,r2 ; cp r2` war ein Artefakt von R11.)

## Stolpersteine, neu bei `sh` (gemessen)
* **Gastdateinamen sind auf 14 Zeichen begrenzt**: `NAME.err2` muss passen, Variantennamen hoechstens 9 Zeichen (der Bau bricht sonst ab); mit `_c2` darf der Basisname hoechstens 6 haben
  (`v7fix` -> `v7fix_c2`).  Beim Verstoss verschwindet die Fehlerdatei still (`.er`), und man sieht nur "NO binary".
* `k1520disktool` wird im Emulatorordner ausgefuehrt: **Pfade muessen absolut sein** (relative Pfade ergeben "Abbild nicht ladbar").
* `rm` liegt nicht im Gast-`PATH` (`rm: not found`); die `.o` bleiben liegen, der Bau haengt davon nicht ab.
* `/tmp`-Diskette (ca. 250 KB): `cc -S` aller Module passt nicht auf einmal; Pipeline fuehrt die `.s` in Sitzungen zu je <= 40 KB aus.
* `karte_extra.txt`: Zeilen `ohne ADDR` verwerfen falsche `--vorschlaege`-Einstiege (Ziele mitten im Befehl), `code ADDR` fuegt nur ueber Zeiger/hinter `JP` erreichte Einstiege hinzu
  (`sh`: 12 `ohne`, 4 `code`: 245C, 3820, 39FE, 3CC8).  `vergleich --karte-extra-beide` wendet das auch auf das gebaute Abbild an (nur bei gleichem Layout).

## Karte nach der Bereinigung
970 Einstiege, 0 ungueltig, 0 Ueberlappung, 0 Marken mitten im Befehl, 0 nicht kanonische Befehle.  Unerreicht bleiben 1610 B (8,8 %), davon der Rest der libc-Glieder
(nur ueber Bibliotheksaufrufe erreichbar) -- keine Auswirkung auf den Eigencode.

## Offen
* Die Regel, welche `register char` das alte `cc` behaelt (Abweichung 1), ist nicht bestimmt, nur die 3 Ausnahmen sind gemessen.
* `R16` ist ein Einzelfall (Daten statt `jr`): ob der Original-`as` allgemein -256 zulaesst, ist nicht geprueft (nur diese eine Stelle in `sh`).
* Die Frage "anderer c2-Stand oder Modell" ist fuer `sh` entschieden (siehe oben), fuer die uebrigen Programme der Wurzeldiskette (`cat`/`ls` zeigen R4) nur gegenueber `sh` abgegrenzt.

## Nachtrag nach dem Merge in `userspace-herkunft` (gemessen)
R11-R14 galten zunaechst fuer alle Programme; R12-R14 fragten den Abschaltschalter nicht ab.  Folge nach dem Merge:
`cat` 4060/4072, `login` 9902/9904 B.  Jetzt sind R11-R14 nur fuer `sh` an (`pipeline.py: C2_NUR_SH`, `c2_aus()`), alle Regeln
pruefen den Schalter.  Regression danach: `sh` 18296 B (`cmp` 0 Abweichungen), init, cat, ls, date, mount, login, umount, stty
(`--libc alt`), getty, sync -- alle elf ganzdatei bytegleich.  Waechter: `tests/test_userspace_pipeline.py::test_sh_rules_are_off_for_other_programs`.
