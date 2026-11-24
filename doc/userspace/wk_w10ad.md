# W10ad: c2x-Flags `o` (R60) und `q` (R70); od und pr byteidentisch mit `--xcc`

Stand 2026-11-24.  Plan 52, W10.  Vorgaenger: `wk_w10ac.md`.

## Aenderungen (alles unter `C2X`, Standard-c2 tokengleich)
* `userspace/c2/c2.h`: `XR60` (0x40) und `XR70` (0x80) in `xfl2`; `c20.c` `xparse`: Buchstaben `o` (R60), `q` (R70), beide auch in `A`.
* **R60** (`o`, `c21.c` `cmppass`, eigene kleine Schleife am Ende): `and rN,#%FF ; ld MEM,rN ; ld r0,MEM [X4MARK] ; cp r0,..` -> der eingefuegte
  Knoten wird `ld r0,rN` (wie das Hostmodell).  Spaet gemacht, damit Register-Verfolgung und R38 (`p->code+3` = MEM) unberuehrt bleiben.
* **R70** (`q`, `c21.c` `r5pass`): `div rr2,MEM ; ld MEM2,r3` (MEM kein `#`, MEM2 kein Register/`@`, danach kein `jr`/`jp`) -> `ld r2,r3 ; ld MEM2,r2`.
  Neuer Helfer `xins(p, s)` in `c20.c` (fuegt einen MOV-Knoten hinter p ein; c21.o ist nahe am Symboltabellenlimit des Gast-`as`).
* `tools/userspace/c2gegen.py` `FLAGBUCHSTABE`: `R60 -> o`, `R70 -> q`; `tools/userspace/xcc.py` `REGELN` um R60, R70 erweitert.

## Messungen (alle *gemessen*)
* c2x-Bild: Text 20958 / Daten 2440 / BSS 2268 = **25666 B** (vorher 20518/2280/2268 = 25066; +600 B); Datei 23414 B (vorher 22814).  Bau 288 s.
* Einzelmodullauf `lauf od pr --c2x ... --auto --s0 --kurz --null`: Flags od `...goq`, pr `...goqT`; no-flag SAME; `xpush od pr` (Modell gegen c2x): **2 von 2 EQUAL** (erster Versuch).
* `bau od --xcc --libc alt` (36 s) und `bau pr --xcc --libc alt` (44 s); `vergleich od --ist neu_x`: **BYTE-IDENTICAL** (5536 von 5536 B);
  `vergleich pr --ist neu_x`: **BYTE-IDENTICAL** (8294 von 8294 B).  Ohne Rest.
* Regression (ein 65-Module-Lauf, 41 Programmverzeichnisse, `--kurz --s0 --auto --null --extra R3,R33,R39`, alle Regelbuchstaben): **no-flag 65/65 SAME**;
  mit Flags je Programm gegen das Hostmodell **57 gleich, 8 abweichend** (dieselben wie W10aa: c2/c21, c0/c00, c0/c02, passwd, cpp, convert, ed, tar).
* `tokcheck` (c2 ohne Define) OK; `pytest -q -m "not gast"`: 212 ok, 1 Fehler (`test_bau_alle_kennt_genau_die_fertigen_disketten`, braucht `disks/gebaut`, im Worktree nicht vorhanden).

## Budget
c2x-Bau 1, 65-Module-Lauf 1 (davon 2 Fehlstarts ohne Gastlauf: zsh splittet `$N` nicht), Einzelmodullauf 1, `bau od` 1, `bau pr` 1, `vergleich` 2 (Host).
