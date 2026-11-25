# W10af: c2x-Flags `f` (R97), `h` (R98), `i` (R99), `j` (R100); ld byteidentisch mit `--xcc`

Stand 2026-11-25.  Plan 52, W10.  Vorgaenger: `wk_w10ae.md`.

## Aenderungen (alles unter `C2X`, Standard-c2 tokengleich)
* `userspace/c2/c2.h`: `XR97` (0x400), `XR98` (0x800), `XR99` (0x1000), `XR100` (0x2000) in `xfl2`; `c20.c` `xparse`: Buchstaben `f`, `h`, `i`, `j` (auch in `A`).
* Die vier Regeln stehen in **einer** Funktion `xldrules(p)` in `c20.c` (Aufruf in `r5pass`, `c21.c`, vor R45): die erste Fassung mit dem Code in `c21.c` scheiterte im Gast-`as`
  mit `symbol table overflow` (c21.o am Limit); in `c20.c` ist Platz.  Die Hilfen `xnd`, `xcomma`, `xhead` bleiben in `c21.c` (`char *xhead(), *xcomma();` in `c20.c` deklariert).
* **R97** (`f`): `sub r2,r12 ; ld MEM,r2 ; jr mi L` -> `test r2` vor dem `jr` (`mget`, 2 Stellen).
* **R98** (`h`): `xorb rh3,rh3 ; xor r2,r2 ; div rr2,#%3` -> `ld r2,r3 ; ld r3,r2` vor dem `xor`, R45 greift dort nicht (`main`, Hash-Switch; die zweite R45-Stelle in `middle` bleibt).
* **R99** (`i`): `mult rr4,#%C ; ld r13,r5 ; add r13,#X ; ld MEM,r13 ; ld @r2,r13` laeuft ueber r3 (`enter`, 1 Stelle).
* **R100** (`j`): `ld r3,@r2 ; ld -%X(FP),r3 ; ld r2,r3` -> `ld r2,-%X(FP)` (`ldrand`, 1 Stelle; die zweite Form `ld -%E(FP),r3` in `symreloc` bleibt).
* Fehler beim ersten Wurf (R98): `xins(p->back, ..)` setzt `p->back` auf den neuen Knoten; das zweite `xins(p->back->forw, ..)` landete hinter dem `xor`.  Jetzt mit lokalem Zeiger.
* `tools/userspace/c2gegen.py`: `FLAGBUCHSTABE` um `R97 f, R98 h, R99 i, R100 j`; `xpush` wendet fuer ld zusaetzlich `c2_ld_s` an (die R97-R100 sind dort Modell nur fuer ld).
* `tools/userspace/xcc.py` `REGELN` um R97-R100; `pipeline.py`: `C2_NUR_LD` = R97-R100 sind fuer alle Programme ausser ld in `c2_aus` aus (sonst bekaeme jedes Programm die Buchstaben `fhij`);
  `xcc_luecken_texte` zaehlt R97-R100 nicht mehr als Luecke.

## Messungen (alle *gemessen*)
* c2x-Bild (`c2x_c2.bin`): Text 22268 / Daten 2602 / BSS 2268 = **27138 B** (vorher 26074; +1064 B: Text +940, Daten +124); Datei 24886 B.  Bau 295 s + 125 s.  Erster Bau (Code in c21.c): `symbol table overflow`.
  **Achtung:** das c2x ist 1 KB groesser; `as_code` (nahe der 64-KB-Grenze) wurde in diesem Paket *nicht* neu gebaut -- vor dem naechsten `bau as --xcc` pruefen.
* `bau ld --xcc --libc alt` (Flags `pcmzkwW73t546eandgoquvfhij`, 99 s, "model rules without a c2x letter: none"); `vergleich ld --ist neu_x`: **BYTE-IDENTICAL** (10710 von 10710 B).  Der erste Versuch
  (R98-Fehler oben) hatte 10706 von 10710 B gleich (ein vertauschtes `xor`/`ld`-Paar).
* Regression (ein 65-Module-Lauf, 41 Programme, `--kurz --s0 --auto --null --extra R3,R33,R39 --regeln <alle>`): **no-flag 65/65 SAME**.  `xpush` (Flaglauf gegen Hostmodell): **57 gleich, 8 abweichend**
  (c0/c00, c0/c02, c2/c21, convert, cpp, ed, passwd, tar -- dieselben wie W10ae); ld ist gleich.
* `tokcheck` (c2/cc) OK; `pytest -q -m "not gast"`: 212 ok, 4 uebersprungen.

## Budget
c2x-Bau 3 (einer davon Fehlschlag: Symboltabellenueberlauf; einer mit R98-Fehler), 65-Module-Lauf 1, `bau ld` 2, `vergleich` 3, Einzelmodullauf 0.
