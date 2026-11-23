# W10o: c2x mit Laufzeit-Schaltern je Regel (ein Binary)

Fortsetzung von `wk_w10n.md` Abschnitt 4. *Gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht. `tokcheck` OK, `pipeline.py --check c2` OK, `pytest -m "not gast"` 215 passed.

## 1. Aenderung
* Ein Compile-Define **`C2X`** ersetzt `XPUSH`/`XCMPMEM`/`XHZERO` (alle Zusatzcode unter `#ifdef C2X`; ohne Define bleibt der Quelltext token-identisch, `c2gegen.py tokcheck`).
  Bau: `c2gegen.py var c2x C2X`, dann `pipeline.py bau c2 --libc alt --quelle c2x=userspace/c2/work/var/c2x`.
* Laufzeit: ein Flagwort `xfl` (c2.h, Masken `XR<nr>`, 8-Zeichen-sicher). `main()` liest vor den Dateinamen Argumente `-x<Buchstaben>`; ein `-` ohne `x` bleibt das alte `-` (Statistik).
  Ohne `-x` ist `xfl` = 0 (Absicht: Verhalten wie ausgelieferter c2; erreicht ist es noch nicht, Abschnitt 3).
* Buchstaben (je eine Regel des aelteren c2): `p` R1 (`inc SP,#n+2 ; push` bleibt), `c` R4 (`ld r0,MEM ; cp r0,#k`), `m` R38 (R0-Wiederverwendung hinter kurzem `jr cc`, braucht `c`),
  `z` R2 (spaetes Streichen des toten `xorb`), Ausnahmen von `z`: `k` R30, `w` R63, `s` R43; `7` R7, `3` R3, `t` R10, `r` R32 (`xorb` bleibt, hzkeep).
  `A` = alles. Gruppennamen: `-xpush` = p, `-xcmpmem` = cm, `-xhzero` = zkws73tr (alle Buchstaben ausser p, c, m).
  R69 (sh-`jp eq`) kennt c2x nicht (wie bisher).
* `c2gegen.py`: `lauf --c2x BIN --auto --regeln ... --extra R3 [--null]` gibt jedem Modul `-x<Buchstaben>` aus `regelsatz(Programm)` (Regeln der Gruppen minus `C2_AUS`); `--null` fuehrt zusaetzlich c2x ohne Flag aus (`MOD.sz`) und vergleicht mit dem ausgelieferten c2.

## 2. Zahlen (65 Module, ein Gastlauf, c2x je Programm mit seinen Flags, Modell je Programm wie W10n, mit R3)
* **56 gleich, 9 abweichend** (W10n: 40/65). Die 18 Faelle (b) sind bis auf `ps` (siehe 3) gleich geworden.
* Rest: (a) mv (R63-Kopiepropagation, kein Schalter); (c) c0/c00, c0/c02, c2/c21, convert, cpp, ed, tar wie W10n; ps (Folge von 3).

## 3. Was nicht erreicht ist (Befund)
* **c2x ohne Flag == ausgelieferter c2 gilt in diesem Binary NICHT**: von 65 Modulen sind nur 9 gleich (die ohne `cp MEM,#k`/xorb-Stellen). Gemessen (ps, ein Modul, 6 Aufrufe in einer Sitzung):
  ohne Flag, `-x`, ohne Flag nochmal: je 21991 B gegen ausgelieferten c2 21968 B; Unterschied ist `ld r0,MEM ; cp r0,#k` (R4 aktiv trotz `xfl` = 0, auch mit explizitem `xfl = 0;` am Anfang von `main`).
  Mit Flags dagegen schalten alle Regeln einzeln richtig (as/df/rm ohne `c` bekommen kein R4, od ohne `3` kein R3).
* *Annahme (nicht mehr gemessen, Budget Bau erschoepft)*: Ursache ist der Bau. Das Binary kam aus `bau c2` **ohne `--c2emu`**, also mit dem ausgelieferten c2 als Optimierer fuer c2x selbst; die
  frueheren Abnahmen (W10d/f: 12/12, 33/33, 27/27 IDENTICAL) liefen mit dem `--c2emu`-Binary (`*_c2.bin`, Modell-Form, wie die Originale gebaut). Naechster Schritt: `bau c2 --c2emu ...` mit `var c2x C2X`
  und `lauf --null` wiederholen; erwartet 65/65 `SAME`. Der Befund "R4 trotz xfl = 0" waere dann ein Fehlcode des Optimierers beim Uebersetzen von `xfl & XR4`.
* Die 56/65 sind trotzdem aussagekraeftig: das Flag-Binary wendet je Modul genau die Regeln an, die das Modell fordert (Gegenprobe bestanden).

## 4. Verbrauch
Bau 2 (der erste mit `xfl` nur im BSS, der zweite mit `xfl = 0`), Gastlaeufe 3 (erster Lauf abgebrochen bei Sitzung 20, zweiter 65 Module, ein Diagnose-Lauf an ps).
