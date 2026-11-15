# Abweichungen vom Original (Branch `mutos-plus`)

Jede Aenderung in diesem Branch, die vom Original MUTOS 8000 abweicht.  Regeln: `doc/plan/47_mutos_plus.md` Abschnitt 2.
Spalten: was geaendert ist, warum, Stelle, wie geprueft (*gemessen* mit Lauf/Test oder *abgeleitet*).

| # | Abweichung | Grund | Stelle | Pruefung |
|---|------------|-------|--------|----------|
| 1 | `ttyinput` ohne den Fehler des Original-`c2` (Regel K6: gestrichenes Laden vor `t_xstate ^= XPAGE`) | Bau ohne c2-Modell (Plan 47 Ziel 1) | `kernel/c/tty2.c` `ttyinput` (Quelle unveraendert, Unterschied entsteht im Compiler) | *abgeleitet* (Plan 43 §15, `doc/herkunft/tty2.md`); Funktionstest steht aus (P3) |

Geplant (noch nicht umgesetzt): feste Adressen `WV %888A` in `low` und `cf_proctop = 0x8A8C` in `conf.c` (Plan 47 P2).
