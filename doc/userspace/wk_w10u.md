# W10u: Luecken-Uebersicht `xccgap` und 14 weitere `--xcc`-Bauten

Plan 52 W10, Schritt 6. *Gemessen* (Gastlaeufe 2026-11-23), ausser wo *Annahme* steht. `tokcheck` OK, `pytest -m "not gast"` 213 passed, 3 skipped.

## 1. Befehl
`python3 -I tools/userspace/pipeline.py xccgap [NAME]` (nur Host; braucht `userspace/*/work/bau/neu.s` bzw. `neu_s/`, `v7fix_s/` eines frueheren Normalbaus).
Je Programm: Art (`single`, `multi(Module)`, `noopt`) und die Modellregeln (`c2_emu_s`-Zaehler mit den `C2_AUS` des Programms), fuer die c2x **keinen Buchstaben** hat, mit Stellenzahl; `ready` = keine Luecke.
R33 und R39 zaehlen nicht als Luecke: sie sind feste Ausnahmen zu R5 in `r5pass()` (W10t). `bau --xcc` meldete sie bisher faelschlich; `xcc_luecken` benutzt jetzt dieselbe Ausnahme (`XCC_EINGEBAUT`).
Nicht erfasst: `mt` (ohne Modellregeln, kein `neu.s`), `c2` nur als `multi(2)` mit seinen `all*`-Texten; `sh` nur Fassung `v7fix`.
Die Zaehler laufen auf dem Text des Normalbaus; "Luecke" ist daher eine Vorhersage (W10s bestaetigte sie fuer wc, cat, df).

## 2. Tabelle
Einzeldatei, ohne Luecke (`ready`, 26): cat chmod chown clri df echo hex init kill ln login ls mkdir mknod mount mv pstat pwd rm rmdir size stty sync umount wc who.
Mehrdatei ohne Luecke: as (8 Module, `noopt` in `link.txt`), c2 (2), cpp (2; dort nur R39, eingebaut). `noopt` kommt nur bei as vor (c1 hat eine `link.txt` ohne `noopt` bei den erfassten Modulen).

Mit Luecke (Regel(Stellen)):
| Programm | fehlende Regeln |
|---|---|
| ar | R71(1) |
| cp | R34(1) |
| date | R6(1) |
| ld | R45(2) |
| ncheck | R45(1) |
| nm | R45(1) |
| od | R60(1) |
| pr | R70(1) |
| ps | R77(1) |
| strip | R65(1) |
| tar | R92(1) |
| c1 (multi 4) | R48(1) R62(1) |
| cmp | R61(3) R62(1) |
| dd | R66(1) R67(1) |
| getty | R8(1) R9(1) |
| passwd | R68(1) R69(1) |
| dcheck | R35(1) R36(1) R37(1) |
| icheck | R46(3) R47(1) R48(1) |
| c0 (multi 6) | R130(3) R131(1) R132(1) R133(1) |
| cc | R93(2) R94(7) R95(4) R96(2) |
| convert | R72(2) R73(1) R74(1) R75(1) R76(1) |
| mkfs | R46(1) R49(5) R50(3) R51(1) R52(1) R53(2) R54(1) R55(2) R56(1) R57(1) R58(1) |
| ed | R80(12) R81(2) R82(2) R84(4) R85(1) R86(1) R87(2) R88(2) R89(1) R90(1) R91(1) |
| sh (v7fix, multi 20) | R11(4) R12(1) R13(2) R14(1) R16(1) |

## 3. Bauten (`bau NAME --xcc --libc alt` + `vergleich NAME --ist neu_x`), 14 Programme
**13 byteidentisch**: chmod (3694 B), chown (5506), clri (3558), ln (4314), mkdir (3934), mknod (3938), rmdir (4144), pwd (3444), kill (3792), who (6646), stty (5814), umount (4096), mount (4272). Je Bau 25-47 s; Flags bei allen `-Xpcmzkws73tr546`.
**mv: eine Abweichung** (6819 von 6820 Byte, erste bei 0x7A1, 1 Block): Funktion 0774 `TEST R2` (Original) gegen `TEST R4` (c2x). Das Modell meldet keine Luecke, also eine **c2x-Abweichung bei R5** (mv stand schon in W10t unter den 9 abweichenden Modulen des c2gegen-Laufs). Ursache nicht untersucht.
Mit W10s/W10t sind damit 19 Programme mit `--xcc` byteidentisch (echo rm wc cat df size + 13). `ready`, aber nicht gebaut (Budget): init login ls hex pstat sync und die Mehrdatei-Programme as, c2, cpp.
Mehrdatei mit `--xcc` ist weiter ungemessen (Stufenbau mit `c2x` statt `c2`, W10s).

## 4. Rangfolge der fehlenden Regeln (Programme, die sie freischalten)
* Freischaltung je Regel: **R45 3** (ld, ncheck, nm; je Programm die einzige fehlende Regel), R46 2 (icheck, mkfs; beide haben weitere Luecken), R48 2 (c1, icheck), R62 2 (c1, cmp), alle anderen 1.
* **Erster Kandidat R45**: schaltet drei Programme sofort frei. Danach je ein Programm mit einer einzigen Regel: R71 (ar), R34 (cp), R6 (date), R60 (od), R70 (pr), R77 (ps), R65 (strip), R92 (tar).
* Zwei Regeln: cmp (R61, R62), dd (R66, R67), getty (R8, R9), passwd (R68, R69), c1 (R48, R62); mit R62 zusammen fallen cmp und c1 beinahe (je eine weitere Regel).
* Drei: dcheck (R35-R37), icheck (R46-R48). Gross: cc, c0, convert, mkfs, ed, sh.
* Vorab: die R5-Abweichung in mv klaeren (c2x gegen Modell).

## 5. Verbrauch
14 Bauten (je ein `bau` + `vergleich`), keine Wiederholung, keine Gastfehler. Keine c2x-Aenderung.
