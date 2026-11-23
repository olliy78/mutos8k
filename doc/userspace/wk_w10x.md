# W10x: c2x mit exaktem Vergleich in `copy()` -- Regression, Abbruch vor den Programmbauten

Plan 52 W10, Schritt 9. *Gemessen* (Gastlaeufe 2026-11-23). Kein Quelltext geaendert.

## 1. Bau
`c2gegen.py var c2x C2X`, `pipeline.py bau c2 --c2emu --libc alt --quelle c2x=userspace/c2/work/var/c2x`: **c2x 26184 B** (745 s), **c2x_c2 26176 B** (327 s). `tokcheck` c2 und cc OK, `pytest -m "not gast"` 213 passed, 3 skipped.

## 2. Regression (67 Programme/`lauf --kurz --s0 --auto --null --extra R3,R33,R39`, ein Lauf)
* **no-flag: 62 gleich, 3 abweichend (dd, ed, tar)** -- erwartet war 65/65. Genau dieselben drei wie bei der `equstr`-Fassung (W10w, 62/65): die Ursache ist also **nicht** der Vergleich (`#%5` gegen `#5`); der exakte Vergleich aendert nichts.
* Jeweils eine einzige Zeile: das Original-c2 macht `djnz r12,L90`, c2x ohne Flag laesst `dec r12,#%1` / `jr ne L90` stehen (dd Zeile 1302, ed 3485, tar 2498; `MOD.s` gegen `MOD.sz` in `userspace/c2/work/gegen/`). Der `addsob()`-Zweig (c21.c, `p->op == DEC ... SOB`) wird nicht genommen.
* Mit Flags: 23 Programme identisch, 44 abweichend (vorher 57/65 gleich); diese Zahl ist wegen der no-flag-Abweichung nicht bewertbar und wurde nicht weiter ausgewertet.
* Erwartung "no-flag 65/65" nicht erfuellt -> gemaess Auftrag **kein `lauf as --s0`, keine `--xcc`-Programmbauten** (ls, hex, as nicht neu gebaut). Heapbedarf (`-`-Option) nicht gemessen (`lauf` reicht die Option nicht durch; kein Budget fuer einen Extralauf).

## 3. Analyse (Quelltext gelesen, *Annahme*, nicht gemessen)
* Die `addsob`-Bedingungen (`refc`-Vergleich, `toofar`, `ilen`/`dualop`) vergleichen keine Zeiger auf Knotentexte; `rg` findet keine Zeigervergleiche von `->code` in c20.c/c21.c. Die Annahme aus W10w ("Zeiger werden nie verglichen") bleibt damit unwiderlegt, aber die Ursache ist offen.
* Mit der Fassung ohne gemeinsame Zeichenketten (25636 B) war no-flag 65/65 gleich; die Aenderung liegt also an `copy()` (Verschiebung der Heapadressen oder gemeinsame Zeichen), nicht an den Regeln.
* Verdacht 1: unbelegte Heapfelder (`alloc` nullt nicht; `insertl()`/c21.c 1699 legen Knoten an) -- die gemeinsamen Zeichenketten verschieben alle Adressen. Verdacht 2: `toofar` liegt bei den Schleifen von dd/ed/tar knapp an 254 Byte; die Laengen kommen aus `ilen`, hier ist kein Texteinfluss zu sehen.
* Naechster Schritt: auf dd.s0 (kleinstes Beispiel) c2x ohne Flag mit der Fassung 25636 B und der aktuellen vergleichen, `copy()`-Sharing mit einem Schalter ausschalten (nur Knoten mit Operandentext ohne `#` teilen) und bisektieren; falls der Fehler an der Adresslage haengt, `alloc()` im C2X-Zweig nullen. Danach erst ls/hex/as.

## 4. Verbrauch
c2-`bau` 1, `lauf` 65-Module-Regression 1; `lauf as --s0` und alle `--xcc`-Bauten nicht ausgefuehrt. Nichts laeuft mehr.
