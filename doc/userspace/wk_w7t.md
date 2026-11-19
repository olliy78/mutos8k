# W7t: Gegenprobe des rekonstruierten `as` mit dem c2-Bau (`neu_c2.bin`)

Fortsetzung von `wk_w7s.md`. Werkzeug `tools/userspace/asgegen.py`. Alles *gemessen*.

## 1. Messung

* Bau `pipeline.py alles as --c2emu --libc alt --ist neu_c2`: `userspace/as/work/bau/neu_c2.bin` **35364 B** (wie W7s).
  (Die aus dem Hauptbaum kopierte `neu_c2.bin` war ein aelterer Stand mit 30478 B und musste neu gebaut werden.)
* Gast `asgegen.py lauf --asx userspace/as/work/bau/neu_c2.bin --libc 80` (610 s) und `auswerten`:
  **identical 76 of 80 (without .o on both sides: 4)**. Alle 76 Eingaben mit Objekt sind bytegleich:
  `c_echo c_cat c_cc` (680, 1632, 9064 B), `d_t1..d_t8` und alle 65 libc-Module (`l_*`).
* Die vier uebrigen sind `d_e0..d_e3` (absichtlich unvollstaendige Modulkoepfe): das Original erzeugt ebenfalls kein `.o`, Meldungen gleich.
  Es gibt also **keinen Unterschied** mehr zum Original in der Eingabemenge.
* `pipeline.py --check as` OK (text 22092, data 13706); `pytest -m "not gast"`: 213 passed, 1 skipped.

## 2. `syntax error` in Zeile 8 (W7s Abschnitt 4.1)

Mit `neu_c2.bin` tritt er **nicht** auf (`c_echo c_cat c_cc d_t1..d_t8` bytegleich). Er gehoert zum schlichten Bau `neu.bin`
(`cc -O` ohne c2-Modell). Zeile 8 der Eingaben ist `PR := procedure` (erste Deklaration mit dem Schluesselwort `procedure`);
`d_e3` (bis Zeile 8 `I := internal`) war bei `neu.bin` unauffaellig. *Annahme*: Das Schluesselwort `procedure` wird im schlichten Bau
falsch erkannt (Codegenerator-Unterschied `cc -O` gegen das Original-`c2`), nicht ein Quellfehler; nicht weiter untersucht,
da der massgebliche Bau (`neu_c2`) bytegleich ist und das Rundlauf-Kriterium dieser Linie `neu_c2` ist.

## 3. Offen

* Der schlichte Bau `neu.bin` liefert den Syntaxfehler weiter; falls er gebraucht wird, Ursache dort suchen (Vergleich der Funktion fuer
  Schluesselwort-Suche in `yylex`/Symboltabelle zwischen `neu.bin` und Original).
* Weitere Eingabeklassen (z. B. die Quellen von `ed`, `make`, eigene `.s` des Kernels) in `asgegen.py` aufnehmen.
