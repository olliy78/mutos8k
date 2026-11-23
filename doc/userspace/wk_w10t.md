# W10t: c2x kennt R5, R42, R64 (Buchstaben `5`, `T`, `4`, `6`)

Plan 52 W10, Schritt 5. *Gemessen* (Gastlaeufe 2026-11-22/23), ausser wo *Annahme* steht. `tokcheck` OK, `pytest -m "not gast"` 212 passed, 4 skipped.

## 1. Aenderung
* `c21.c` (unter `C2X`): neuer Durchlauf `r5pass()` nach `hzpass()`, unmittelbar vor `output()`. Knotenweise Form der Modellregeln aus `uspace.c2_emu_s`, gleiche Bedingungen und Ausnahmen, nur Knoten in Folge (ein Label dazwischen bricht das Fenster, wie die Textzeile im Modell):
  * `5` = R5: `ld rA,rB ; test rB` -> `test rA`, `ld rA,rB ; ld DST,rB` -> `ld DST,rA`. Ausnahmen R33 (`call ; ld rA,r2 ; test r2`) und R39 (`xorb rhB,rhB` davor, A >= 8) fest eingebaut.
  * `T` = Pseudoregel R5T (pr): mit `5` nur die `ld DST`-Form.
  * `4` = R42: `ld rN,SRC ; ld MEM,rN ; test rN` -> `test MEM` (ohne den R37-Fall `jr cc ; ld r0,rN`).
  * `6` = R64: die zehn Knoten der df-Folge (`ldl MEM,rr4 ; testl rr4 ; ...`).
* Masken `XR5` 0x800, `XR5T` 0x1000, `XR42` 0x2000, `XR64` 0x4000 (`c2.h`); `-xA` setzt zusaetzlich XR5, XR42, XR64 (nicht T). `xfl` bleibt initialisiert (Datenbereich, wk_w10q); die neuen Hilfsfunktionen haben keine Globalen. Ohne `C2X` token-identisch (`tokcheck` OK).
* Buchstabenabbildung an einer Stelle: `c2gegen.FLAGBUCHSTABE` (R5 -> 5, R42 -> 4, R64 -> 6) plus `T`, wenn R5 im Satz und R5T in `C2_AUS` des Programms (`c2x_flags`); `xcc.REGELN` um R5, R42, R64 erweitert. R33/R39 sind keine Buchstaben (immer aktiv).
* `c2gegen.xpush`: die Pseudoregel R5T wird als aus uebergeben (sie ist kein Zaehlerschluessel; ohne das meldete der Vergleich pr falsch als abweichend). Fuer R5 muss der Vergleich `--extra R3,R33,R39` bekommen, sonst schaltet er die festen Ausnahmen im Modell ab.

## 2. Zahlen
* c2x-Bau (`bau c2 --c2emu --libc alt --quelle c2x=...`): `c2x_c2.bin` 23360 B (vorher 21190 B laut W10q, ein Teil davon ist wohl auch der Stand seit W10s), 345 s.
* Regression, 65 Module, ein Gastlauf (`lauf --kurz --s0 --auto --null --regeln ...,R5,R42,R64 --extra R3`): **ohne Flag 65/65 `SAME`**; je Programm mit Flags `xpush ... --extra R3,R33,R39`: **56 gleich, 9 abweichend** (wie W10q, nicht schlechter). Reste: c0/c00, c0/c02, c2/c21, convert, cpp, ed, mv, passwd, tar; ps ist jetzt gleich. passwd (`jr` statt `jp`, Folge von R4-Groessen) stand in der Liste von W10q nicht, die gesicherten alten `.sn` zeigen dieselbe Stelle -- *Annahme*: schon vorher abweichend, nicht durch diese Aenderung.
* Gastbau mit `--xcc --libc alt` und `vergleich --ist neu_x`, **alle byteidentisch**: wc (`-Xpcmzkws73tr546`, 4132 B, 156 s), cat (4072 B), df (`-Xmzkws73tr546`, 3546 B), echo (2152 B), rm (5766 B), zusaetzlich size (4048 B). Regeln ohne c2x-Buchstaben: bei allen keine.

## 3. Verbrauch
c2-`bau` 1, c2gegen-Gastlauf 1 (65 Module), Programmbauten mit `--xcc` 6 (wc, cat, df, echo, rm, size). Nicht gemacht: Mehrdatei-Programme, Stufenbau.
