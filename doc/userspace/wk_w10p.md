# W10p: c2x ohne Flag -- Befund, kein Fix

Fortsetzung von `wk_w10o.md` Abschnitt 3. *Gemessen* (Gastlaeufe 2026-11-20/22), ausser wo *Annahme* steht. Keine Quelltext-Aenderung (Diagnose-Ausgaben wieder entfernt); `tokcheck` OK, `pipeline.py --check c2` OK, `pytest -m "not gast"` 215 passed.

## 1. Host-Durchsicht
Alle C2X-Pfade geprueft: R4-Einfuegung (c21.c, `(xfl & XR4) && p->op == CMP ...`), `x4keep`/`X4MARK` (nur gesetzt durch eingefuegte Knoten), `cmppass` (nur `xfl & XR38`), `hzpass` (nur `xfl & XR2`), `hzkeep`-Tore. Jeder Pfad prueft sein Bit; Masken, Klammern und Breiten stimmen (`xfl` ist `int`, Masken <= 0x400). Im erzeugten Assembler (`work/bau/c2x_s/c21.s`) ist das R4-Tor `bit _xfl,#%1 ; jr eq L115` -- korrekt. Kein Gate-Fehler im Quelltext.

## 2. Bau und Lauf
* `bau c2 --c2emu --libc alt --quelle c2x=...` (c2x_c2.bin 21188 B): `lauf --kurz --s0 --auto --null` an `ar` (erstes Modul): ohne Flag weiter DIFFERS (`ld r0,%4(FP) ; cp r0,#%3` statt `cp %4(FP),#%3`, 3 Stellen). Der Befund aus W10o ist also **nicht** durch `--c2emu` behoben; die Annahme dort ist widerlegt. Der volle 65-Module-Lauf wurde deshalb nicht gefahren.
* Diagnose-Bau (Ausgabe von `xfl` in `main` nach dem Parsen und am R4-Tor, nur lokal, nicht eingecheckt), `lauf ... ar`:
  * mit Flags: `xfl=7FF` am Start und an allen 61 Toren;
  * **ohne Flag: `xfl=0` am Start, aber `xfl=4BB6` an allen 61 Toren** -- das Wort wird zwischen Parser und erstem Tor ueberschrieben (Bit 1 gesetzt, daher R4).

## 3. Schluss (Annahme)
Ursache ist ein Speicherueberschreiber (z. B. Feld-Ueberlauf im BSS oder Heap/`sbrk`-Anfang, der `_xfl` trifft), nicht die Bit-Pruefung. Mit Flags bleibt der Wert 7FF, vermutlich weil dort derselbe Schreiber eine Stelle trifft, die vom Wert unabhaengig ist -- nicht geklaert. Naechster Schritt (ein Bau + ein Lauf): `xfl` nach `opsetup()`, nach dem ersten `input()` und in `rmove` ausgeben, um den Schreiber einzugrenzen; BSS-Reihenfolge im Link (Karte mit `ld -m`) pruefen. Brauchbare Gegenprobe: `xfl` als Teil einer initialisierten Struktur/`int xfl = 0;` im Datenbereich (Annahme: aendert die Lage, behebt den Ueberschreiber nicht).

## 4. Verbrauch
Bau 2 (Normal-, Diagnose-Bau), Gastlaeufe 3 (ein leerer Aufruf ohne Namen, ein Abbruch nach `ar` und c0, ein Diagnose-Lauf `ar`).
