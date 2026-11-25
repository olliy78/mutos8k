# W10ae: c2x-Flags `u` (R77) und `v` (R92); ps und tar byteidentisch mit `--xcc`

Stand 2026-11-25.  Plan 52, W10.  Vorgaenger: `wk_w10ad.md`.

## Aenderungen (alles unter `C2X`, Standard-c2 tokengleich)
* Beide Regeln sind Sprungentscheidungen: der ausgelieferte c2 haelt ein `jp cc` lang, das das Original kurz (`jr cc`) hat.  In `shortjmp()` (`c20.c`) gibt es unter `C2X`
  eine eigene Fassung (`#ifdef C2X ... #else <Original> #endif`, damit die Token des Standard-c2 gleich bleiben); sie fragt zusaetzlich die neue Funktion `xsite(p)` (`c20.c`).
* **R77** (`u`, Bit `XR77` in `xfl2`): `ldb rl2,@r13 ; xorb rh2,rh2 ; cp r2,#%1 ; jp ne,L` wird `jr ne` (ps `pstatus`, 1 Stelle).
* **R92** (`v`, `XR92`): `test _rflag ; jp eq L ; test _cflag ; jr eq ; jp|jr L` (gleiches Ziel) wird `jr eq` (tar `main`, 1 Stelle).
* `c2gegen.py` `FLAGBUCHSTABE` (`R77 -> u`, `R92 -> v`), `xcc.py` `REGELN`, `pipeline.py` `C2_AUS["tar"]` = R1-R91 (das Hostmodell wendet bei tar mit `tar=True` ohnehin nur R92 an; so bekommt tar nur den Buchstaben `v`).

## Messungen (alle *gemessen*)
* c2x-Bild: Text 21328 / Daten 2478 / BSS 2268 = **26074 B** (vorher 25666; +408 B); Datei 23822 B.  Bau 276 s + 116 s.
* `bau ps --xcc --libc alt` (Flags `uv`, 55 s) und `bau tar --xcc --libc alt` (Flag `v`, 108 s); `vergleich ps --ist neu_x`: **BYTE-IDENTICAL** (7830 von 7830 B);
  `vergleich tar --ist neu_x`: **BYTE-IDENTICAL** (16984 von 16984 B).  Ohne Rest.
* Regression (ein 65-Module-Lauf, 41 Programme, `--kurz --s0 --auto --null --extra R3,R33,R39`): **no-flag 65/65 SAME**.  `xpush` (Flag-Lauf gegen Hostmodell): **57 gleich, 8 abweichend**
  (c0/c00, c0/c02, c2/c21, convert, cpp, ed, passwd, tar -- dieselben wie W10ad).  ps ist jetzt gleich (vorher keine Flagregel dafuer).
* **tar bleibt in der xpush-Liste**, aber aus einem Messgrund: `xpush` ruft das Modell ohne `tar=True` auf, es kennt R92 dort nicht (Differenz genau die R92-Stelle, Zeile 194: Modell `jp eq`, c2x `jr eq`).
  Die echte Gegenprobe (`vergleich` gegen das Original) ist bytegleich; die Abweichung ist also ein Artefakt des Pruefwerkzeugs, keine des c2x.  Nicht geaendert.
* `tokcheck` (c2/cc) OK; `pytest -q -m "not gast"`: 216 ok (mit kopiertem `disks/gebaut`).

## Budget
c2x-Bau 1, 65-Module-Lauf 1, `bau ps` 1, `bau tar` 1, `vergleich` 2 (Host), `xpush` 1 (Host).
