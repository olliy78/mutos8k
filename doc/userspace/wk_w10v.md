# W10v: c2x kennt R63-Kopieanteil (`W`) und R45 (`e`); init login ls hex pstat mv ncheck nm mit `--xcc` bytegleich

Plan 52 W10, Schritt 7. *Gemessen* (Gastlaeufe 2026-11-23), ausser wo *Annahme* steht. `tokcheck` (c2 und cc) OK, `pytest -m "not gast"` 213 passed, 3 skipped.

## 1. Aenderungen
* **mv-Abweichung (W10u) = R63-Kopieanteil, nicht R5.** Das Modell (`uspace.c2_emu_s`, R63) macht aus `xorb ; ldb @rM,rlN ; ld rK,rN ; ld rX,rN ; test rN` die Folge `... ; ld rK,rN ; ld rX,rK ; test rK`; c2x kannte nur den xorb-Anteil (`w`). R5 allein erzeugte `ld rX,rK ; test rN` (= `TEST R4`), das Original hat `TEST R2`.
  Neu: Buchstabe `W` (`XR63C` 0x8000, `r5pass`, vor R42/R5, gleiche Bedingungen wie das Modell); `FLAGBUCHSTABE["R63"]` = `wW`.
* **R45** (`xor r2,r2 ; div rr2,#k` -> `exts rr2 ; div rr2,#k`): Buchstabe `e`, `XR45` 0x1 in einem **zweiten Flagwort `xfl2`** (`xfl` ist mit 0x8000 voll; `int xfl2 = 0;` im Datenbereich, nicht BSS, wie W10q). `-xA` enthaelt W und e.
* `FLAGBUCHSTABE["R45"]` = `e`, `xcc.REGELN` um R45 erweitert (eine Stelle je Regel).
* **xcc**: `-X` nahm hoechstens 15 Buchstaben, ncheck/nm brauchen jetzt 16 (`-XpcmzkwWs73tr546e`); das 16. wurde stumm abgeschnitten (erster Lauf: `XOR` statt `EXTS`). Grenze in `cc.c` (unter `XCC`) auf 17, `xcc_c2_s.bin` neu gebaut (6810 B, Tokenstrom ohne `-DXCC` unveraendert, `tokcheck` OK).
* `pipeline.py xccgap`: fuer `ld` zaehlen jetzt R97-R100 (`c2_ld_s`) als Luecke.

## 2. Regression (c2x_c2.bin 24028 B, 40 Programme / 65 Module, ein Gastlauf, `lauf --kurz --s0 --auto --null --extra R3,R33,R39`)
* Ohne Flag: **65/65 `SAME`** (je `MOD.sz` gegen `MOD.s`, Host-`cmp`).
* Je Programm mit Flags (`xpush`): **57 gleich, 8 abweichend** (vorher 56/9; mv ist jetzt gleich). Reste unveraendert: c0/c00, c0/c02, c2/c21, convert, cpp, ed, passwd, tar.

## 3. Bauten mit `--xcc` (`bau NAME --xcc [--libc alt]`, `vergleich NAME --ist neu_x`)
Bytegleich: **init** (4962 B, `-Xpcmzkws73tr546`), **login** (9904), **ls** (8244), **hex** (4310), **pstat** (6850, kein Flag noetig), **mv** (6820), **ncheck** (5062), **nm** (6012).
ls und hex liefen mit dem alten c2x (vor W/e; die Buchstaben waren dem Binary unbekannt): bytegleich, also dort ohne Wirkung; mit neuem c2x nicht wiederholt.
* **ld**: nicht bytegleich (7 Differenzbloecke, erste `LD R2,R3 ; LD R3,R2 ; XOR R2,R2` gegen `EXTS RR2`). Ursache: R97-R100 (nur ld, `c2_ld_s`, wk_w13) haben keinen c2x-Buchstaben; R45 allein reicht nicht. Der alte xccgap-Eintrag "ld: R45(2)" sagte das nicht, weil er R97-R100 nicht zaehlte (jetzt ja). Die Differenz an dieser Stelle ist R98.
* **sync**: nicht gebaut -- ohne `--libc alt` fehlen `_exit csv cret _sync`; es gibt kein `libc_alt/sync.members` (`libc_alt.py quelle sync` waere der erste Schritt).
* **cpp** (16230 B, 53 Bloecke) und **c2** (18950 B, 29 Bloecke): Mehrdatei-Pfad laeuft mit `--xcc` durch (Stufenbau ohne Pipelineaenderung), aber nicht bytegleich; die Abweichungen decken sich mit den Resten des c2gegen-Laufs (cpp, c2/c21), zusaetzlich Registerwahl (`LD B+6,R2` gegen `R12`) in cpp -- *Annahme*: Folge der R42-Reste, nicht untersucht.
* **as**: `/usr/lib/c2x` bricht bei einem Modul mit `Fatal error` ab, danach `ld:as_code.o: cannot open` (kein Binary). Das ist ein c2x-Fehler auf as-Eingaben (as ist nicht in den 65 Modulen der Regression); Eingrenzung versucht (`c2gegen lauf ... as`), aber der Lauf blieb auf `as_y.c` (noopt, > 10 KB Daten, haengt im ausgelieferten c2, wk_w7e) bis zum Limit stehen, ohne Ergebnis. Offen: as_code.s0 allein gegen c2x laufen lassen.

## 4. Verbrauch
c2x-`bau` 1, xcc-`bau` 1, c2gegen-Regression 1 (65 Module) plus 1 as-Eingrenzung (ergebnislos, Zeitlimit), Programmbauten mit `--xcc` 16 (init login ls hex pstat sync[Fehler] mv ld ncheck nm cpp c2 as, ncheck nm ld wiederholt). Das Budget (14 Bauten) ist um die Wiederholungen nach der xcc-Grenze ueberschritten.
Insgesamt `--xcc`-bytegleich: 27 Programme (19 aus W10u + init login ls hex pstat mv ncheck nm).
