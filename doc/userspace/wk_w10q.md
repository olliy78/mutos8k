# W10q: c2x ohne Flag -- Ursache und Fix (`xfl` in den Datenbereich)

Fortsetzung von `wk_w10p.md`. *Gemessen* (Gastlaeufe 2026-11-22), ausser wo *Annahme* steht. `tokcheck` OK, `pipeline.py --check c2` OK, `pytest -m "not gast"` 215 passed.

## 1. Ursache (Host-Durchsicht, Annahme bestaetigt durch Lauf)
* BSS-Reihenfolge (`work/bau/c2x_s/c20.s`): `... _ccsz, _fflag, _ophash[79]` und danach `_xfl` -- `xfl` liegt direkt hinter `ophash`.
* `opsetup()` (c20.c, V7-Original) prueft `if (ophp > &ophash[OPHS]) ophp = ophash;` -- `>` statt `>=`: bei Kollision in Slot 78 wird `ophash[79]` (ein Wort hinter dem Feld) gelesen und, wenn 0, **beschrieben** (Zeiger auf eine `optab`-Zeile, daher 0x4BB6).
  Im ausgelieferten c2 trifft das den Nachbarn hinter `ophash` (Ende des BSS, folgenlos); im c2x war es `xfl`.
* Mit Flags (`xfl` != 0) liest die Schleife `ophash[79]` als belegt und laeuft weiter: deshalb blieb 7FF erhalten -- erklaert den Befund aus W10p.
* `oplook()` bricht mit `>=` ab und sieht Slot 79 nie; der Fehler ist im Original folgenlos.

## 2. Fix
`int xfl = 0;` (Datenbereich, `_xfl:` vor `_revbr`-Nachbarschaft, im Listing als Label statt `X _xfl W`) mit Kommentar in c20.c. Der Ueberlauf selbst bleibt unveraendert (er gehoert zum Original); ohne `C2X` bleibt der Quelltext token-identisch.

## 3. Zahlen (Bau `c2x_c2.bin` 21190 B, 65 Module, ein Gastlauf, `lauf --kurz --s0 --auto --null`)
* **Ohne Flag: 65/65 `SAME as shipped c2`** (W10p/W10o: 9/65).
* Je Programm mit Flags: **56 gleich, 9 abweichend** (`xpush ... --extra R3`), wie W10o; Reste unveraendert (mv R63, c0/c00, c0/c02, c2/c21, convert, cpp, ed, tar, ps).

## 4. Verbrauch
Bau 2, Gastlaeufe 2 (der erste, beim 1. Bau, ohne den Fix gefahren und nach ca. 30 Modulen abgebrochen: die Aenderung an c20.c war wegen eines abgelehnten Befehls nicht angewendet; Befund ohne Fix wie W10p reproduziert).
