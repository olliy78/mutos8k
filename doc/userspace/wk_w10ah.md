# W10ah: c2x-Flag `y` (R93-R96); cc byteidentisch mit `--xcc`

Stand 2026-11-25.  Plan 52, W10.  Vorgaenger: `wk_w10ag.md`.

## Aenderungen (alles unter `C2X`, Standard-c2 tokengleich)
* `userspace/c2/c2.h`: dritte Flagwort `xfl3` (`xfl2` ist mit 16 Bits voll), `XR93` (0x1); `c20.c`: `int xfl3 = 0;` (initialisierte Daten wie `xfl2`), in `main` zurueckgesetzt, `xparse`: Buchstabe `y`
  (nicht in `A`: R93-R96 sind reine cc-Regeln).
* `c20.c` `xccpass()` (neu, Aufruf in `main` vor `output()`, nur mit `y`): die Knotenform von `uspace.c2_cc_s` (R93 `ld MEM,r3 ; push @SP,r3` -> `push @SP,MEM`; R94 `cp VAR,#k` -> `ld r2,VAR ; cp r2,#k`;
  R95 dasselbe, wenn r2 schon VAR spiegelt; R96 `test r2` -> `test MEM`).  Zustand (`mir`, `stale`) wie im Modell; Hilfen `xhdeq`, `xccvar`, `xld2m` ebenfalls in `c20.c` (c21.o bleibt unberuehrt).
* `c2gegen.py` `FLAGBUCHSTABE`: R93 `y`, R94-R96 ohne eigenen Buchstaben; `xcc.REGELN` um R93-R96; `pipeline.py`: `C2_AUS["cc"]` laesst R93-R96 an, neu `C2_NUR_CC` = R93-R96 fuer alle anderen Programme aus
  (wie `C2_NUR_LD`/`C2_NUR_C0`).  `c2x_flags('cc')` = `y`; die anderen Programme: Buchstaben unveraendert (ld `pcmzkwW73t546eandgoquvfhij`, c0 `bl`).

## Messungen (alle *gemessen*)
* c2x-Bild: Text 23980 / Daten 2746 / BSS 2268 = **28994 B** (W10ag: 27802; **+1192 B**: Text +1120, Daten +72); Datei 26742 B (vorher 25550).  Mehr als die angepeilten ~600 B (Knoten-Mustererkennung,
  ausgeschrieben); Bau 321 s + 138 s.
* **`bau as --xcc --libc alt` linkt noch**: Binary 35330 B, 414 s; `vergleich as --ist neu_x`: 4140 von 5891 Befehlen gleich (W10ab: 4137), 725 Differenzbloecke.
* `bau cc --xcc --libc alt` (Flag `-Xy`, "model rules without a c2x letter: none", 46 s): **`vergleich cc --ist neu_x`: BYTE-IDENTICAL** (6520 von 6520 B).
* Regression (ein 65-Module-Lauf `lauf ... --kurz --s0 --auto --null`, 41 Programme): **no-flag 65/65 SAME**.  `xpush`: **60 gleich, 5 abweichend** (c2/c21, convert, cpp, ed, passwd -- wie W10ag ohne cc).
* `tokcheck` (c20.c, c21.c) OK; `pytest -q -m "not gast"`: 213 ok, 3 uebersprungen.

## Budget
c2x-Bau 1, 65-Module-Lauf 1, `bau cc` 1, `bau as --xcc` 1, `vergleich` 2 (cc, as; Host), Einzelmodullaeufe 0.
