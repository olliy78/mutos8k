# Abweichungen vom Original (Branch `mutos-plus`)

Jede Aenderung in diesem Branch, die vom Original MUTOS 8000 abweicht.  Regeln: `doc/plan/47_mutos_plus.md` Abschnitt 2.
Spalten: was geaendert ist, warum, Stelle, wie geprueft (*gemessen* mit Lauf/Test oder *abgeleitet*).

| # | Abweichung | Grund | Stelle | Pruefung |
|---|------------|-------|--------|----------|
| 1 | `ttyinput` ohne den Fehler des Original-`c2` (Regel K6: gestrichenes Laden vor `t_xstate ^= XPAGE`) | Bau ohne c2-Modell (Plan 47 Ziel 1) | `kernel/c/tty2.c` `ttyinput` (Quelle unveraendert, Unterschied entsteht im Compiler) | *abgeleitet* (Plan 43 §15, `doc/herkunft/tty2.md`); Funktionstest steht aus (P3) |
| 2 | `NCLIST` 50 -> 49 (ein Clist-Block weniger fuer tty/Drucker); `_nested` in `bss.s` benannt; `/bss.o` auf der Wurzel statt `bss.o` auf A | der Kernel ist 4 B zu gross fuer die BSS (Text +2 wegen #1, `nested` +2); die BSS muss unter D266 (`cfreelist`) enden; Platz auf A (Provisorium bis P1.4, mit P1.4 entfallen: `/bss.o` ist wieder `bss.o` auf A) | `kernel/c/ureg.c`, `kernel/plus/bss.s`, `kernel/plus/Makefile`, `kernel/plus/README.md` | *abgeleitet* (`doc/plus/gastbau.md` §1.1); Grenzpruefung `basis.grenze_pruefen`; Gastbau in P1.4/P1.5 |
| 3 | `max_proc` (`dn1.s`) als Verweis `WV %38+_proc` statt der Zahl A154; `abs.o` als Quelle `abs.s`; BSS als echter Abschnitt; Kernel-Datei im Gast per `dd`-Pipe | die Lage im Gastbau weicht vom Original ab (`proc` A11E statt A11C); Selbstbau ohne Host-Schritt | `kernel/plus/dn1.s`, `abs.s`, `bss.s`, `Makefile` | *gemessen* (`doc/plus/gastbau.md` §2: Boot, b1..b9, b11; `abs.s` gleich altem `abs.o` per `objformat.py nm`) |

Geplant (noch nicht umgesetzt): feste Adressen `WV %888A` in `low` und `cf_proctop = 0x8A8C` in `conf.c` (Plan 47 P2).
