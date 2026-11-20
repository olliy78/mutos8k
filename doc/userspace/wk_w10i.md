# W10i: `-xhzero` Stufe 4 und Kombinationsabnahme

Fortsetzung von `wk_w10h.md` (Abschnitte 3, 4). Alles *gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht.
Bau und Abnahme wie in W10h (`pipeline.py bau c2 --c2emu --libc alt --quelle V=VERZEICHNIS`, `c2gegen.py lauf ... --s0 --kurz --c2x BIN`, `c2gegen.py xpush ... --regeln ...`).
Die `MOD.s0` stammen aus einem aelteren Arbeitsbaum (gleicher c1, gleiche Quellen).

## 1. Stufe 4 von `-xhzero` (`c21.c`)
* Das Behalten fuer R3/R10/R32 sitzt jetzt **oertlich an der `xorb`-Stelle** (`hzkeep` erkennt `xorb ; cp rN ; jr cc ; xorb ; jr|add rN|cp rN`, nur das erste einer Kette);
  das grobe Loeschen von `cregs[N]` bei jedem `jr cc` in `rmove` (`case CBR`) entfaellt.
* R43 nur bei Ziel `@rM` (`ldb @rM,rlN`).
* Standard-c2 unveraendert: `cpp -P` Tokenstrom-md5 von `c21.c` `b23c00a0...` wie vor der Aenderung; `pipeline.py --check c2` OK (Text 16976, Daten 1984, 85 Funktionen);
  `pytest -m "not gast"` 210 passed, 4 skipped.
* Gebaut in einem Aufruf: `hz4_c2.bin` 20088 B (`-DXHZERO`), `all4_c2.bin` 20316 B (`-DXPUSH -DXCMPMEM -DXHZERO`); Standard 18956 B.

## 2. Abnahme `hz4` (53 Module, Regeln R2,R7,R10,R30,R32,R43,R63)
**45 von 53 gleich** (Stufe 3: 43). Abweichend (8): c0/c00, c2/c21, init (c2x behaelt noch ein `xorb` mehr), c2/c20 (neu: c2x loescht ein `xorb`, das das Modell behaelt, bei `cp r2,#%6C`),
convert, cpp (`jr`/Blocklage, Folge der `xorb`-Zahl), ld (R32 nach `jr eq L370`, c1-Ausgabe hat dort kein `xorb`), mv (nur der Kopieanteil von R63, gehoert zu `-xcopyprop`).
Stufe 4 behoben gegenueber Stufe 3: zwei der bisher abweichenden Module (sh/macro u.a.); c20 ist dagegen neu abweichend.
Stufe 4 bleibt im Commit (besser als 3).

## 3. Abnahme der Kombination `all4` (65 Module = 53 + echo cat wc size cmp who ln mkdir mknod pr passwd chown)
Gegen ausgelieferten c2 + R1,R4,R38,R69,R2,R7,R10,R30,R32,R43,R63: **50 von 65 gleich**, 15 abweichend.
* **`-xhzero`-Reste (9)**, gleiche Ursachen wie in Abschnitt 2: c0/c00, c2/c20, c2/c21, init, ld, mv, convert, ed (`jr`/Blocklage), c0/c02 (`jp` statt `jr`, Spanne, *Annahme*: Folge der `xorb`-Zahl).
* **`-xcmpmem` auf groesseren Modulen (6, neu)**: cpp, cpp/cpy, mkfs, sh/cmd, sh/xec, tar. Der c2x ersetzt eine spaetere Speicherverwendung durch `r0` (`ld r2,r0`, `test r0`, `push @SP,r0`),
  das Modell behaelt den Speicheroperanden (`ld r2,_fretop`, `test r2`, `push @SP,%4(FP)`): der eingefuegte `ld r0,MEM` bleibt als Registerkopie in `cregs` stehen.
  Diese Module gehoerten nicht zur 15er-Menge von W10g/h; der Schalter allein ist dort nicht gemessen (*Annahme*: nicht durch `-xhzero` verursacht, Gegenprobe mit `-DXCMPMEM` allein offen).

## 4. Verbrauch und offen
* Bau 1 Aufruf (2 Varianten), Gastlaeufe 3 (hz4/53 Module, all4/65 Module, `--check c2`).
* Offen: `cregs[0]` nach dem eingefuegten `ld r0,MEM` im Sinne des ausgelieferten c2 verwerfen (6 Module); c20 (Stufe-4-Rueckschritt) und c00/c21/init (`xorb` zu viel);
  R3 vollstaendig; Binaerabgleich ganzer Programme und Schaltermenge je Programm in `pipeline.py`.
