# W10f: breiterer c2-Funktionsvergleich (72 Module) und erster Schalter `-xpush` (Variante c2x)

Fortsetzung von `wk_w10d.md`. Alles *gemessen* (Gast-Laeufe 2026-11-19), ausser wo *Annahme* steht. Werkzeug: `tools/userspace/c2gegen.py`
(neu: Module `k_NAME` = `kernel/c/NAME.c` mit allen `kernel/h/*.h`; `--kurz`; Befehl `xpush`).

## 1. Funktionsvergleich unser c2 gegen ausgelieferten c2

Stand `neu_c2.bin` 18956 B, **frisch neu gebaut** (das mitgebrachte war wieder veraltet: `_flsbuf` lud noch `#%513A/#%5194`; nach Neubau laden `_filbuf`
und `_flsbuf` je `#%5126`/`#%5326`; `libc_alt.py bau c2`: 0 Glieder abweichend). Je Modul: cpp, c0, c1 von Hand, dann ausgelieferter `/usr/lib/c2`
(`MOD.s`) und unser c2 auf derselben c1-Ausgabe (`MOD.sn`), dazu Zweitlauf, Shell-Umlenkung (`<c5 >out`), zweiter ausgelieferter Lauf und ausgelieferte
Binaerdatei von `/mnt`; `cmp` im Gast, alle `MOD.cmp` leer.

| Lauf | Module | Ergebnis |
|---|---|---|
| 1 | c0: c00-c05 (6); c1: c10-c13 (4); cpp: cpp, cpy (2) | 12 von 12 IDENTICAL |
| 2 | sh: 20 Module; ls mkfs ld ps stty icheck dd ncheck od pr mv passwd login (13) | 33 von 33 IDENTICAL |
| 3 | Kernel: alloc bio clock dev0 fio iget lp machdep main malloc nami pipe prf rdwri rk sig slp subr sys1 sys2 sys3 sys4 text trap tty2 tty ureg (27, alle `kernel/c`) | 27 von 27 IDENTICAL |

Zusammen **72 Module, 72 bytegleich** (zusammen mit W10d: echo cat ed tar). Groesste Eingaben: `c10` 48701 B, `c11` 44695 B, `cpp` 44350 B Ausgabe.
Kein DIFFERS, also keine Stelle zu verfolgen. Nicht gewertet: die beiden Assembler-Module von c1 (`atof.s`, `table_z8k.s`; kein C, die Zeilen
"IDENTICAL/DIFFERS" im Log sind leer gegen leer). Die 28 Differenzbloecke im Eigencode von c2 (4609 von 4717 Befehlen gleich) wirken sich damit auf 76
Eingaben (W10d + W10f) nicht aus. *Annahme:* Voraussetzung fuer Schritt 2 erfuellt; bewiesen ist es nur fuer diese Eingaben.

## 2. W10 Schritt 2: `-xpush` (Regel R1) als Variante c2x

**Mechanismus (gemessen am Original):** Der ausgelieferte c2 verschmilzt `inc SP,#k ; push @SP,x` zu `inc SP,#k-2 ; ld @SP,x` (`rmove`, `case INC`,
`userspace/c2/c21.c`). Beim Rest 0 entfaellt das `inc` ganz (`call f ; ld @SP,x`). Die Originale (R1 aktiv, Beispiel `ls`: 3x `call ; ld @SP`, daneben unverschmolzenes
`inc SP,#n ; push`) verschmelzen **nur im Fall Rest 0**; ein erster Versuch, das Verschmelzen ganz abzuschalten, wich vom Modell ab (Befund `c00`: Modell `ld @SP,#%1`,
c2x `inc SP,#%2`) und wurde verworfen. Der Schalter lautet daher: nicht verschmelzen, wenn nach der Subtraktion `r1 != 0`.

**Umsetzung:** compile-time, `#ifdef XPUSH` in `c21.c` (drei Zeilen vor `if (r1 == 0)`); der Bau `pipeline.py bau c2 --c2emu --libc alt --variante c2x
--flags "-O -s -DXPUSH"` liefert `work/bau/c2x.bin` (18968 B) und `c2x_c2.bin` (18958 B, mit c2-Modell wie `neu_c2.bin`). Kein Laufzeit-Schalter: ein
Kommandozeilenschalter im Binary haette das byte-identische c2 geaendert. Ohne `-DXPUSH` bleibt der c2 unveraendert: Vorverarbeitung von `c21.c` vor und nach der
Aenderung ist tokengleich (Host-`cpp -P`, Vergleich gemessen: gleich; mit `-DXPUSH` 6 Tokens mehr), `pipeline.py --check c2` OK (Text 16976, Daten 1984, 85 Funktionen).
Ein erneuter Gastbau des Standard-c2 wurde wegen des Budgets nicht gemacht (*Annahme:* wegen Tokengleichheit bytegleich zu `neu_c2.bin`).

**Abnahme** (`c2gegen.py lauf ... --s0 --kurz --c2x c2x_c2.bin`, dann `c2gegen.py xpush NAMEN`): `MOD.sn` (c2x) == `MOD.s` (ausgelieferter c2) plus Host-Regel R1
(`uspace.c2_emu_s` mit allen anderen Regeln aus). Ergebnis: **44 von 44 Modulen gleich** (c0 6, c1 4, cpp 2, sh 20, ls mkfs ld ps stty dd, Kernel bio tty2 sys1 slp trap alloc),
**127 R1-Stellen** in 26 Modulen (c10 14, c11 14, c12 7, c00 3, ...). Zuvor (erster Versuch, vollstaendig abgeschaltet) 5 von 6 c0-Modulen abweichend, siehe oben.

## 3. Verbrauch und offen
Gastlaeufe 5 (davon einer abgebrochen: c2x-Variante 1), c2-Neubauten 3 (neu_c2, c2x Variante 1 verworfen, c2x Variante 2). Offen: `-xcmpmem` (R4) als naechster Schalter;
Gastbau des Standard-c2 nach der Aenderung zur Bestaetigung; Weitergabe der Schaltermenge je Programm in `pipeline.py`.
