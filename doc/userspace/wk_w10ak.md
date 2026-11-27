# W10ak: c2x-Variante fuer convert (R72-R76); passwd analysiert

Stand 2026-11-27.  Plan 52, W10.  Vorgaenger: `wk_w10aj.md`.  Teil 1 von W10ak (convert, passwd); Teil 2 (c21, cpp, ed) folgt.
Der Agent wurde vom Wochenlimit abgebrochen; Abnahme, Korrektur und Bericht hat die Hauptsitzung gemacht.

**Ergebnis (gemessen): convert mit `xcc` bytegleich (4586/4586 B, Variante `c2xcv`).  passwd baut mit `xcc`, ist aber nicht
bytegleich (+4 B, zwei fehlende `r0`-Wiederverwendungen, R38).  Regression ohne Schalter 65/65, `xpush` 62/65 mit R69 fuer passwd
(61/65 ohne).**

## Aenderungen
1. Neuer Compilerschalter `C2X_CV` (Buchstabe `V`, Wort `xfl3`, `XRCV` in `c2.h`), `xcvpass` in `c20.c`: die fuenf Einzelstellen
   R72-R76 von convert (Hostmodell `c2_convert_s`).  Variante `c2xcv` = `C2X` + `C2X_CV`; `pipeline.py` `C2_NUR_CV` (R72-R76 nur
   fuer convert), `xcc.REGELN` um R72-R76 erweitert; `c2gegen.py` `VARIANTEN`/`PROGRAMM_VARIANTE` (convert -> c2xcv); Host-Test erweitert.
2. `c2xall` (Regressionsvariante) bleibt ohne `C2X_CV`: mit allen vier Gruppen meldet `as` beim Bau von `c20.c` *symbol table
   overflow* (gemessen vom Agenten).  convert laeuft in der Regression mit `c2xcv`.
3. **Zurueckgenommen:** der Agent hatte in `toofar()` (`c21.c`) die R4-Einfuegung `ld r0,MEM` nur mit 2 B gezaehlt, damit c2x bei
   passwd `jr eq` erzeugt wie das `xpush`-Modell.  Gemessen: das Original hat dort `JP Z` (R69, `vergleich passwd`), das Modell
   war ohne R69 unvollstaendig; mit der Aenderung brach der `xcc`-Bau von passwd im Assembler ab (`line 134. ILLEGAL VALUE`,
   `jr` zu weit).  `c21.c` ist wieder Stand W10aj.

## Messung (Bild = Text + Daten + BSS aus dem a.out-Kopf, Byte)
| Variante | Text | Daten | BSS | Bild | W10aj |
|---|---|---|---|---|---|
| c2x | 20952 | 2136 | 2268 | 25356 | 25342 |
| c2xcv | 21890 | 2328 | 2268 | 26486 | -- |
| c2xld | 21206 | 2364 | 2268 | 25838 | 25824 |
| c2xcc | 21706 | 2204 | 2268 | 26178 | 26164 |
| c2xc0 | 20970 | 2310 | 2268 | 25548 | 25534 |
| c2xall | 21978 | 2606 | 2268 | 26852 | 26728 |

+14 B je Variante: Pruefung `xdeny('V')` in `xparse`.

## Abnahme (gemessen, alle Varianten aus der Endquelle neu gebaut)
* `bau X --xcc --libc alt` + `vergleich X --ist neu_x`: **convert** 4586/4586, **ld** 10710/10710, **cc** 6520/6520,
  **c0** 26810/26810, **tar** 16984/16984 BYTE-IDENTICAL.
* **passwd** `--xcc`: Text 7550 statt 7546 B, 462 von 467 Befehlen gleich.  Funktion 0030: das Original vergleicht nach
  `ld r0,MEM ; cp r0,#'0' ; jr lt` weiter mit `cp r0,#'9'` (R38, Wiederverwendung von r0 hinter `jr`), c2x mit `cp MEM,#'9'`
  (je 2 B mehr, zwei Stellen).  Das Hostmodell (mit R69) liefert dasselbe wie c2x, ist hier also ebenfalls unvollstaendig.
* Nebenbefund: `bau passwd --libc alt` (ohne xcc) ist auf main wie im Branch **nicht** bytegleich (635/9124 B; `JR Z` statt `JP Z`
  an der R69-Stelle).  Welcher Bauweg passwd frueher G machte, ist nicht geklaert.
* 65-Module-Lauf (`lauf <Programme> --c2x c2xall_c2.bin --kurz --s0 --auto --null --regeln <xcc.REGELN> --extra R3,R33,R39`,
  convert getrennt mit `c2xcv_c2.bin`): **ohne Schalter 65/65**; `xpush --extra R3,R33,R39` 61/65 (c21, cpp, ed, passwd),
  mit `R69` zusaetzlich **62/65** (c21, cpp, ed).
* `tokcheck` OK; `pytest -m "not gast"` gruen bis auf `test_bau_alle_kennt_genau_die_fertigen_disketten` (Worktree ohne
  `disks/gebaut`, Umgebung).

## Budget
c2x-Baeue: Agent 4 (c2x, c2xcv, c2xall zweimal), Hauptsitzung 6 (alle Varianten nach der Ruecknahme).  65-Module-Laeufe 2
(Agent 1, Hauptsitzung 1), Einzellaeufe convert 2.  xcc-Baeue: convert 2, passwd 2, ld cc c0 tar je 1; passwd ohne xcc 2.

## Offen
* passwd: R38-Wiederverwendung von `r0` hinter `jr lt` (c2x `cmppass`); Hostmodell um diese Stellen und R69 ergaenzen.
* Teil 2: c21 (spaete `xorb`-Einfuegung), cpp (R101-R112, Schleifenlage), ed (Schleifenlage, Halde; Annahme: aehnlich passwd).
