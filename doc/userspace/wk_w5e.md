# Auftrag W5, Teil e (Plan 52): Gegenprobe des c2-Modells gegen den ausgelieferten `/usr/lib/c2`

Stand 2026-11-18, Branch `us-wk-w5e`.  Alles *gemessen* (Werkzeug `tools/userspace/c2gegen.py`, Rohdaten `userspace/c2/gegenprobe.tsv`,
`userspace/c2/gegenprobe_regeln.tsv`), soweit nicht *Annahme*.

## a) Woher die Pipeline den Eingabetext des Modells holt
`pipeline.py bau --c2emu` holt den Text mit `cc -O -S` im Gast (`uspace.gast_bauen`, Stufen `cpp`, `c0`, `c1`, **`/usr/lib/c2`**).
**Der Eingabetext des Modells (`c2_emu_s` und die programmgebundenen Saetze) ist schon die Ausgabe des ausgelieferten c2.**  Das Modell bildet
"Ausgabe des ausgelieferten c2" auf "Ausgabe des c2, der das Originalprogramm baute" ab.  Fuer jede Regel folgt:

* Regel fuer ein Programm **aktiv**, feuert an n Stellen: das Original hat dort die umgeschriebene Form, der ausgelieferte c2 erzeugt sie **nicht**
  (anderer c2-Stand beim Bau des Programms).
* Regel fuer ein Programm **abgeschaltet** (`C2_AUS`, `C2_NUR_SH`) oder Programm ohne Modell (mt), Muster kommt n-mal vor: das Original hat dort die Form des
  ausgelieferten c2; der ausgelieferte c2 **macht es wie das Original**.
* Regel feuert nirgends: nicht belegt.

## b) Messung
`c2gegen.py lauf NAME...` (Gast): `cpp`, `c0`, `c1` von Hand (`MOD.s0` = unoptimierter Text, Eingabe des c2), dann `/usr/lib/c2 c5 MOD.s`.
52 Programme, 78 Module.  Eine volle `/tmp`-Diskette zeigt sich als `Binary expression botch` bzw. abgeschnittene Ausgabe (fehlendes `end c_`, im Werkzeug geprueft);
betroffene Laeufe wurden mit kleineren Gruppen wiederholt.  `auswerten` rechnet auf `MOD.s` das Modell (Folge der Pipeline) und zaehlt je Regel die Stellen; fuer
abgeschaltete Regeln wird die Regel einzeln eingeschaltet und gezaehlt.  `bauen` assembliert und bindet (x) das c2-`.s` unveraendert und (y) das Modell-`.s`
(`libc_alt`, sonst Diskettenlibc; getty, sh, sync ohne `libc_alt`) und vergleicht die ganze Datei mit dem Original.

## c) Bytegleichheit mit dem echten c2 statt des Modells
Gemessen (`bauen`; ganze Datei samt Kopf):
* **Echter c2 bytegleich zum Original: sync (132 B), rm (5782 B), pstat (6866 B), mt (4342 B).**  Fuer diese vier ist das Modell ersetzbar; bei mt
  ist das Modell sogar falsch (4348 B), `mt` wird ohne Modell gebaut (`cmd_s5.md`).
* ps: echter c2 7848 B gegen 7846 B; mit Modell gleich, noetig ist nur R77 (1 Stelle).
* Mit Modell bytegleich: cat cp ls mkfs ed sh tar cc ld c0 ps ar chmod chown clri cmp convert date dcheck dd df echo getty hex icheck init kill sync rm pstat (und die
  vier oben mit R-frei).  Nicht gleich: `c2` selbst (Blocklage, 18956 B gegen 18976 B, Teil 2 unten) und `cpp` (16292 B gegen 16382 B, W2).
  Nicht gebaut (Zeit): login, mkdir ... who (Regelzaehlung gemessen, Bau nicht).
* Der echte c2 ist ohne Modell fuer **kein anderes** der gebauten Programme bytegleich (alle haben aktive Regeln).  Das heisst: die Platte wurde nicht mit dem
  ausgelieferten c2 gebaut; er stimmt nur fuer die Programme ohne aktive Regel (sync rm pstat mt) und fuer R5/R7/R32/R45 bei c2, sh, ps, pstat.

## d) Tabelle Regel -> Befund (Stellen / Programme)
Spalte 2: ausgelieferter c2 macht es **nicht** (Regel aktiv).  Spalte 3: macht es **wie das Original** (Regel aus; Stellen, an denen sie feuern wuerde).  "-" nicht belegt.

| Regel | ausgelieferter c2 macht es NICHT (Stellen / Programme) | ausgelieferter c2 macht es (Stellen / Programme) |
|---|---|---|
| R1 | 197 / 33 | 72 / 6 |
| R2 | 67 / 12 | 19 / 4 |
| R3 | 7 / 3 | 5 / 5 |
| R4 | 201 / 39 | 38 / 5 |
| R5 | 44 / 16 | 54 / 4 |
| R6 | 1 / 1 | - |
| R7 | 9 / 6 | 26 / 3 |
| R8 | 1 / 1 | - |
| R9 | 1 / 1 | - |
| R10 | 3 / 2 | - |
| R11 | 4 / 1 | 23 / 14 |
| R12 | 1 / 1 | - |
| R13 | 2 / 1 | 11 / 6 |
| R14 | 1 / 1 | - |
| R16 | 1 / 1 | - |
| R30 | 34 / 8 | - |
| R32 | 7 / 4 | 28 / 3 |
| R33 | 1 / 1 | - |
| R34 | 1 / 1 | - |
| R35 | 1 / 1 | - |
| R36 | 1 / 1 | - |
| R37 | 1 / 1 | - |
| R38 | 8 / 6 | - |
| R39 | 9 / 3 | - |
| R42 | 8 / 4 | 4 / 3 |
| R43 | 1 / 1 | 1 / 1 |
| R45 | 4 / 3 | 5 / 3 |
| R46 | 4 / 2 | - |
| R47 | 1 / 1 | - |
| R48 | 1 / 1 | - |
| R49 | 5 / 1 | - |
| R50 | 3 / 1 | - |
| R51 | 1 / 1 | - |
| R52 | 1 / 1 | - |
| R53 | 2 / 1 | - |
| R54 | 1 / 1 | - |
| R55 | 2 / 1 | - |
| R56 | 1 / 1 | - |
| R57 | 1 / 1 | - |
| R58 | 1 / 1 | - |
| R60 | 1 / 1 | - |
| R61 | 3 / 1 | - |
| R62 | 1 / 1 | - |
| R63 | 1 / 1 | - |
| R64 | 1 / 1 | - |
| R65 | 1 / 1 | - |
| R66 | 1 / 1 | - |
| R67 | 1 / 1 | - |
| R68 | 1 / 1 | - |
| R69 | 1 / 1 | - |
| R70 | 1 / 1 | - |
| R71 | 1 / 1 | - |
| R72 | 2 / 1 | - |
| R73 | 1 / 1 | - |
| R74 | 1 / 1 | - |
| R75 | 1 / 1 | - |
| R76 | 1 / 1 | - |
| R77 | 1 / 1 | - |
| R80 | 12 / 1 | - |
| R81 | 2 / 1 | - |
| R82 | 2 / 1 | - |
| R84 | 4 / 1 | - |
| R85 | 1 / 1 | - |
| R86 | 1 / 1 | - |
| R87 | 2 / 1 | - |
| R88 | 2 / 1 | - |
| R89 | 1 / 1 | - |
| R90 | 1 / 1 | - |
| R91 | 1 / 1 | - |
| R92 | 1 / 1 | - |
| R93 | 2 / 1 | - |
| R94 | 7 / 1 | - |
| R95 | 4 / 1 | - |
| R96 | 2 / 1 | - |
| R97 | 2 / 1 | - |
| R98 | 1 / 1 | - |
| R99 | 1 / 1 | - |
| R100 | 1 / 1 | - |
| R101 | 13 / 1 | - |
| R102 | 24 / 1 | - |
| R103 | 1 / 1 | - |
| R104 | 3 / 1 | - |
| R105 | 1 / 1 | - |
| R106 | 1 / 1 | - |
| R107 | 2 / 1 | - |
| R108 | 2 / 1 | - |
| R109 | 1 / 1 | - |
| R110 | 1 / 1 | - |
| R111 | 1 / 1 | - |
| R112 | 1 / 1 | - |
| R130 | 3 / 1 | - |
| R131 | 1 / 1 | - |
| R132 | 1 / 1 | - |
| R133 | 1 / 1 | - |

Zusammenfassung:
* 94 Regeln feuern; **82 nur in Spalte 2** (217 Stellen).  Gemischt (derselbe c2-Stand reicht nicht fuer alle Programme): R1 R2 R3 R4 R5 R7 R11 R13 R32 R42 R43 R45.
  Summe ueber alle 52 Programme: 774 Stellen "macht es nicht", 280 "macht es".
* Nicht belegt (0 Stellen): **R15, R26, R129** (nur in Kommentaren) und **R59** (mkfs: Muster kommt im Text nicht vor).
* Programmgebundene Saetze (ed R80-R91, mkfs R49-R58, tar R92, cc/ld R93-R100, cpp R101-R112, c0 R130-R133, convert R72-R76 ...) feuern nur im eigenen Programm: alle "macht es nicht".

## e) Was der echte c2 tut, ohne dass das Modell es umkehrt
Befehlszaehler ueber alle Module, c1-Ausgabe (s0) -> echter c2 (s) -> Modell:
`jp` 10011 -> 1405 (`jr` 6327), `inc` 5613 -> 5103, `push` 6423 -> 5783 (Modell 5980: R1 macht `inc SP,#n-2 ; ld @SP` rueckgaengig), `clr` 611 -> 414 und
`xor` 360 -> 457, `xorb` 1168 -> 1041 (Modell 1003), `djnz` 0 -> 9 (Modell 8), `exts` 214 -> 208.  Was das Modell nicht anfasst, steht im Original genauso (bytegleiche
Programme): dort tun der echte c2 und der c2 der Platte dasselbe.  Einen Befund, den keine Regel modelliert und der dem Original widerspraeche, gibt es nicht: waere
er vorhanden, waere das Modell-Bau nicht bytegleich.  Dass R1/R4/R5/R7 Spuren eines aelteren `rmove` sind, ist *Annahme*.
