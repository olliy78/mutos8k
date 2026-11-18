# W10, Schritt 1: Schaltergruppen fuer den modifizierten c2 (Plan 52 §6a)

Stand 2026-11-18, Branch `us-wk-w10a`, nur Host.  Werkzeug `tools/userspace/c2gruppen.py` (liest `userspace/c2/gegenprobe.tsv`; Aufruf ohne Argumente
druckt Regelgruppen, Programmgruppen, Zeitprobe und die Matrix).  *gemessen* = aus den TSV-Daten (51 Programme mit Modell, 94 feuernde Regeln; `mt` hat keins);
*Annahme* = Deutung.  Zuordnung Regel -> c2-Funktion beruht auf dem Regeltext in `uspace.py` und dem Quelltext `userspace/c2/c21.c`, **nicht** auf einem Lauf.

Richtung: "aktiv" (A) = der ausgelieferte c2 macht es nicht, das Original hat die Form des aelteren c2.  "aus" (S) = Muster kommt vor, Original = ausgelieferter c2.
Meist bedeutet A: der ausgelieferte c2 fuehrt eine **Optimierung** aus, die der aeltere Stand nicht kannte -- der Schalter schaltet sie im `c2x` ab (einfach zu bauen).
Ausnahme R11-R14 (nur sh): der aeltere Stand tut etwas **mehr** (Kopie-Propagation beim `cp`); das muesste hinzukommen.

## 1. Gemessen: Gruppierung
* **Regelgruppen mit identischer Programmmenge** (gemessen) sind genau die programmgebundenen Saetze: sh (R11-R14, R16), dcheck (R35-37), icheck (R47/48),
  mkfs (R49-58), cmp (R61/62), dd (R66/67), passwd (R68/69), convert (R72-76), ed (R80-91), cc (R93-96), ld (R97-100), cpp (R101-112), c0 (R130-133), getty (R8/9).
  Die **allgemeinen** Regeln (R1-R5, R7, R10, R30, R32, R38, R39, R42, R43, R45, R46) haben alle verschiedene Programmmengen: keine zwei fallen zusammen.
* **Programme mit gleicher aktiver Regelmenge:** `echo mknod size umount` {R4}; `ln mkdir rmdir who` {R1,R4}; `cat wc` {R4,R5}; `chown clri` {R1,R4,R39};
  `mt pstat rm` {} (ausgelieferter c2 genuegt, rm/pstat nur mit R-frei); sonst hat jedes Programm eine eigene Menge.
  R1 und R4 treten in 31 Programmen gemeinsam auf (nur `init`, `pwd`: R1 ohne R4; `cat dcheck echo kill mknod size umount wc`: R4 ohne R1 -- vermutlich fehlendes Muster, nicht Stand).
* **Zeitprobe** (Hypothese "ein Stand-Strang": Regel r aktiv <=> Programm vor t_r gebaut): 24 widersprechende Regelpaare.  Davon 18 durch R11/R13 (sh baut
  *neuer* in R1-R10, aber *anders* in R11-R16: kein Strang), 6 ohne sh: R1/R42 (df: R1,R4 aus, R42 aktiv), R2/R5 (c2 gegen hex), R3/R5, R3/R7, R3/R32 (c2 gegen od),
  R32/R45 (ed gegen ld).  Folgerung (*Annahme*): **kein einzelner aelterer Stand**, sondern ein c2, der in kleinen Schritten geaendert wurde; die Programme entstanden zu
  verschiedenen Zeitpunkten, und die Schalter sind weitgehend unabhaengig.  Die Auffaellige Mischung hat `c2` selbst (R1-R4,R10,R30 alt, R5,R7,R32,R45 neu).

## 2. Regel -> was im c2 (Annahme, aus Regeltext und c21.c)
| Regel | Umformung | c2-Stelle |
|---|---|---|
| R1 | `inc SP,#n ; ld @SP,x` statt `inc SP,#n+2 ; push` -- ausgeliefert verschmilzt `INC SP`+`PUSH` | `rmove`, `case INC` (c21.c ~124-155, `redunm++`) |
| R4 | `ld r0,MEM ; cp r0,#k` statt `cp MEM,#k` -- Speicheroperand fuer R0-Kopie einsetzen | `rmove` `CP`-Zweig / `repladdr`, `findcon` |
| R5 | `ld rA,rB ; test rB` bzw. `ld DST,rB` ohne Kopie-Propagation (`test rA`, `ld DST,rA`) | `rmove` `TST`/`MOV`, `repladdr` mit `savereg`-Kopien |
| R2, R30, R43, R63 | `xorb rhN,rhN` vor Bytespeicher bleibt (nicht entfernt); R30/R43/R63 Ausnahmen | `rmove` `case XOR` (`cregs`, `rnode`, `delnode`) |
| R3, R10, R7, R32 | `xorb rhN` neu vor erstem Volllregister-Gebrauch hinter `jr cc`, zwischen `ldb` und `cp` | `rmove` `cregs`-Verfolgung der hohen Haelfte bei Sprung/Label (`clearreg`) |
| R42 | `test MEM` statt `ld rN,SRC ; ld MEM,rN ; test rN` | `rmove` `TST` / `setcc` (Bedingungscode-Speicherort `ccloc`) |
| R45 | `exts rr2 ; div` statt `xor r2,r2 ; div` (vorzeichenbehaftet) | `rmove` `XOR`-Konstantenverfolgung / Befehlswahl `DIV` |
| R38, R60, R13, R37, R48 | Speicherwert statt Register beim `cp` neu laden (`ld r0,MEM`) | `repladdr`, `kill` (wann gilt eine Registerkopie noch) |
| R11, R12, R14 (sh) | **mehr** Propagation: `cp rB,#k` statt `cp rA,#k` hinter `ld rA,rB` | `rmove` `savereg`/`repladdr` (aelter, nicht ausgeliefert) |
| R16, R77, R69 | `jr` statt `jp` (Spanne ~0xA8, 256 B) bzw. umgekehrt | `toofar`/`ilen`/`adrlen`, `shortjmp` (Laengenschaetzung) |
| R66 (dd) | kein `djnz`/`dec;jr` | `addsob` |
| R6, R8, R9, R33, R34, R35, R36, R39, R46, R47, R61, R62, R64, R65, R67, R70, R71 | je 1-4 Stellen: Registerkopie-/Laden-Reihenfolge | `rmove`/`repladdr`; Stelle je Regel zu klaeren |
| `c2` Blocklage (wk_w5e Ziel 2, nicht als Regel) | erster gleicher Rueckgabeblock bleibt, `jp cret` nicht verschoben | `codemove`, `comjump`, `backjmp` |
| ed/mkfs/cc/ld/cpp/c0/convert-Saetze | Mischung der obigen; 80 Regeln feuern in genau einem Programm (166 Stellen, 55 davon 1 Stelle) | je Fall |

## 3. Ueberanpassungsverdacht (programmgebunden, 1 Stelle; *Annahme*)
Mit Quellform erklaerbar, bevor ein Schalter gebaut wird (Quelle vor Modell pruefen):
* **R71** (ar `p2 = s; for (p1 = s ...)`): Zuweisungsreihenfolge/Form; **R70** (pr `colw = width/ncol`), **R61** (cmp `arg = argv[1]`), **R67** (dd Zeigervergleich),
  **R65** (strip `s = 512; if (size < 512)`), **R64** (df `b = a[i]; if (b == 0)`), **R60** (od `c &= 0377`), **R36** (dcheck `and ... #FF`), **R35** (dcheck `ldb @r2,#FF`
  -> Quelle `~0`/`0377`?): Ausdrucksform oder Deklarationsreihenfolge kann die Registerzuteilung in c1 aendern, sogar ohne c2-Aenderung.
* **R63** (mv `while ((c = *s++ = *t++))`), **R30**, **R43** (ncheck), **R33**, **R34**, **R39**: als "Ausnahme von R2/R5" modelliert -- das Muster der Ausnahme spricht fuer
  eine zu grobe Regel, nicht fuer viele Einzelfaelle: der echte Mechanismus (`cregs`/`rnode`-Verfolgung) liefert sie vermutlich gemeinsam.
* **R3 aus in od/dd** (je 1 Stelle, Schalter-Dispatch), **R2 aus in hex/convert** (je 2 Stellen, Byte-Array-Kopie), **R32/R43 aus in ld** (je 1 Stelle): die Bedingungen von R2/R3/R32
  sind unscharf; `C2_AUS` je Programm kaschiert das.  Erwartung: eine scharfere Bedingung im `c2x` ersetzt die Eintraege.
* **R16, R77, R69** (sh, ps, passwd): drei Spannenfaelle -> ein Mechanismus (Laengenschaetzung `toofar`/`ilen`), kein programmgebundener Schalter noetig.
* **R66** (dd `djnz`): `addsob`-Bedingung; allgemein, nicht 1 Programm.
* Grosse Saetze (ed R80-91, mkfs R49-58, cpp R101-112, c0 R130-133, cc/ld R93-100): erst pruefen, ob dieselben 3-4 Mechanismen (Kopie-Propagation, hohe Haelfte, Sprungspanne)
  hinter vielen Regeln stecken; erwartet: nach dem Einbau der Gruppen A-E schrumpft der Rest deutlich.

## 4. Vorschlag Schaltersatz `c2x` (*Annahme*, Namen vorlaeufig; Schalter fuer c2 als `-xNAME`)
Reihenfolge nach Abdeckung (Stellen / Programme, gemessen) -- jeweils "schaltet aelteres Verhalten ein", ohne Schalter = ausgelieferter c2.

| Nr | Schalter | Regeln | Programme (aktiv) | Abdeckung |
|---|---|---|---|---|
| 1 | `-xcmpmem` (kein Speicheroperand fuer `cp` mit R0-Kopie) | R4 (+ R38, R60, R13-aehnliche) | 39 Programme (alle mit R4 aktiv; aus: df mt ps pstat rm sh) | 201 / 39 |
| 2 | `-xpush` (kein `inc SP`+`push`-Verschmelzen) | R1 | 33 (ar c2 chmod chown clri cmp convert cp cpp date dd ed getty icheck init ld ln login ls mkdir mkfs mount mv ncheck nm od passwd pr pwd rmdir strip stty who) | 197 / 33 |
| 3 | `-xhzero` (hohe Byte-Haelfte nicht verfolgt: `xorb` bleibt/neu) | R2, R3, R10, R30, R43, R63 (R7, R32 als Untergruppe `-xhzero2`) | R2: 12, R3: 3, R10: 2, R30: 8, R7: 6, R32: 4 | 67+7+3+34+9+7 = 127 |
| 4 | `-xcopyprop` (keine Kopie-Propagation bei `test`/`ld`) | R5 (+ R33, R39 Ausnahmen, R5T, R6, R34, R46-R48, R61, R62, R70) | 16 (cat cmp cpp date ed hex icheck ld login mv ncheck nm od passwd pr wc) | 44 + ~25 |
| 5 | `-xtestmem` | R42 | ar df icheck ncheck | 8 / 4 |
| 6 | `-xexts` | R45 | ld ncheck nm | 4 / 3 |
| 7 | `-xjrange` (Laengenschaetzung/Spannen, `codemove`-Reihenfolge fuer c2 selbst) | R16, R77, R69, Blocklage c2 (+ cpp W2) | sh, ps, passwd, c2, cpp | 4 + Blocklage |
| 8 | `-xsh` (aeltere Kopie-Propagation beim `cp`; **hinzufuegen**, nicht abschalten) | R11, R12, R13, R14 | nur sh | 5 Regeln / 1 |
| 9 | `-xdjnz` | R66 | dd | 1 |
| 10 | Rest: programmgebundene Saetze erst nach 1-9 neu zaehlen (`c2gegen.py`), Schalter je verbleibender Mechanismus | ed R80-91, mkfs R49-58, cpp R101-112, c0, cc/ld, convert, getty, ... | | ~150 Stellen |

Programm -> noetige Schalter (allgemeine Gruppen 1-7; "-" ausgelassen):
* nur 1+2 (+3 Teilmengen): ar, chmod, chown, clri, cp, ln, mkdir, mount, rmdir, strip, who, mv, nm, od, ...; nur 1: echo, mknod, size, umount, kill (+R32), wc (+4).
* c2: 2,1,3 ohne `-xhzero2`, ohne 4/6; cpp: 1,2,3,4 (ohne 5); ld: 1,2,3 (R32/R43 aus),4,6; ed: 1,2,3,4 (R42/R45 aus); sh: nur 8 (+7); ps: nur 7 (R77); pstat, rm, df, mt: keiner bzw. nur 5 (df).
* Schalter-Granularitaet: pro Programm Schaltermenge in `pipeline.py` statt `C2_AUS` (Negativmenge); `xcc` reicht sie durch.

**Anzahl:** 9 Schaltergruppen (1-9) plus Rest; Hypothese fuer den Herkunftsbefund (W11): kein einzelner aelterer Stand, sondern mindestens **4 unabhaengige Schaltbits**
(`xcmpmem`/`xpush` gehen meist gemeinsam, aber df/rm/pstat/ps/sh zeigen sie getrennt vom Rest), plus die sh-Besonderheit.

## 5. Reihenfolge der Umsetzung
1. `-xpush` (R1, kleinster Eingriff, 197 Stellen) und `-xcmpmem` (R4, 201 Stellen): zusammen decken sie ~400 von 774 "macht es nicht"-Stellen.  Abnahme: ar, ln, mkdir, rmdir, who.
2. `-xhzero` (R2/R3/R10/R30; Untergruppe R7/R32): Messung an `c2`, `stty`, `pwd`, `ar`.
3. `-xcopyprop` (R5, mit R33/R39): cat, wc, cmp, login, date.
4. `-xtestmem`, `-xexts`: kleine Eingriffe, je 3-4 Programme.
5. `-xjrange` zusammen mit Ziel 2 (`codemove`): bringt `c2`/`cpp` bytegleich (W10-Endziel).
6. `-xsh`, `-xdjnz`, dann Rest neu zaehlen; Modell-Programmsaetze nur fuer das, was bleibt.
Vor jedem Schritt: Quellformen fuer die Verdachtsliste (Abschnitt 3) pruefen.
