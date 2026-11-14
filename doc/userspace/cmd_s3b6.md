# Auftrag S3b-6 (Plan 44): `ed` der Diskette `cmd` (`bin/ed`, 11472 B)

Stand 2026-11-14, Branch `us-cmd-s3b6` (von `us-cmd-s3b3`).  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Ausgangslage (`doc/userspace/cmd_s3b3.md`, nachgemessen): libc-Teil 522/522 gleich; Eigencode 3212 Befehle Original, 3194 gebaut, 3140 gleich, 45 Differenzbloecke; text 11154 statt 11222.

| Programm | Datei | Ergebnis | Quelle | c2-Regeln (Stellen) |
|----------|-------|----------|--------|---------------------|
| `bin/ed` | 11472 B (Abbild 11456: text 11222, data 234, bss 4900) | **G** ganzdatei bytegleich | V7 `ed.c` mit **3 belegten Abweichungen** | bekannte: R1 15, R2 7, R4 11, R5 4, R7 1, R30 12, R32 1; neu (nur ed): R80 12, R81 2, R82 2, R84 4, R85 1, R86 1, R87 2, R88 2, R89 1, R90 1, R91 1 |

Befehl: `python3 -I tools/userspace/pipeline.py alles ed --c2emu --libc alt --ist neu_c2_s` (Stufenbau, da Quelle > 20000 B).

## 1. Quellabweichungen gegen V7 (`userspace/ed/ed.c`, je mit `/* Differs from V7: ... */`)

1. **`move()`**, Zweig ohne `cflag`: vor `ad2 = addr2` steht `if (adt==addr1 || adt==addr1-1) return;`.
   Beleg: Original 193E-194C `CP R13,addr1 ; JR Z,cret ; LD R2,addr1 ; DEC R2,#2 ; CP R2,R13 ; JR Z,cret` (14 B); nach der Aenderung baut der Block gleich.
   Wirkung: `m` eines Blocks direkt vor/hinter sich selbst tut nichts (V7 wuerde trotzdem umordnen und `fchange` setzen).
2. **`commands()` `case 'j'`**: V7 `if (addr2==0) { addr1 = dot; addr2 = dot+1; }`, MUTOS
   `if (addr2==addr1) { if (addr1==0) addr1 = dot; addr2 = addr1+1; }`.
   Beleg: Original 02C4-02E2 `LD R0,addr2 ; CP R0,addr1 ; JR NZ ; TEST addr1 ; JR NZ ; LD R2,dot ; LD addr1,R2 ; LD R2,addr1 ; INC R2,#2 ; LD addr2,R2`
   (gebaut aus V7: `TEST addr2 ; JR NZ ; LD R2,dot ; LD addr1,R2 ; INC R2,#2 ; LD addr2,R2`).  Wirkung: `5j` verbindet Zeile 5 mit 6 (V7: Fehler/keine Wirkung bei einer Adresse).
   Diese Abweichung hatte der Vorgaenger als "02D2 `LD R2,mem` fehlt" gefuehrt.
3. **`crinit()`**: `ic = ((int)random&0377) % (k+1);` und `ic = ((int)random&0377) % k;` (V7 ohne `(int)`, `random` ist `unsigned`).
   Beleg: Original 24DA und 252A `EXTS RR2` vor `DIV` (vorzeichenbehaftet); V7-Text liefert `XOR R2,R2`.  Varianten gemessen (Gast-Bau, je `.s`):
   `vb` = Casts (beide `EXTS`, `random >>= 8` bleibt `SRL`) **passt**; `vc` = `int random;` liefert `EXTS`, aber `SRA` statt `SRL` bei `random >>= 8` (Original `SRL`) -- verworfen.
   Mit den Casts verschwindet auch der dritte Block (2568, `EXTS` im Schleifenrest: der c2 legt beide Pfade wieder zusammen).  Ob im Original wirklich Casts standen oder
   ein anderer Ausdruck mit `int`-Typ (z. B. eine `int`-Hilfsvariable), ist aus den Bytes nicht zu entscheiden (*Annahme*: kleinste Aenderung).

Nicht Quelle (gemessen): die `main()`-Argumentschleife.  Drei Formen (`while`, `for (; ...; argv++, argc--)`, `goto`-Schleife; Dateien `m1`-`m3`) liefern **dasselbe** `.s`
(Test unten, erster Fall inline); der ausgelieferte c2 dreht die Schleife unabhaengig von der Quellform.  Das Original hat den Test oben -> c2-Unterschied (R90).

Zwischenstand nach 1-3 (ohne neue Regeln, mit R42/R45 aus, s. u.): 32 Differenzbloecke, text 11206.

## 2. `C2_AUS` fuer ed: R42, R45

R42 (`test MEM` statt `test r2`, 2 Stellen) und R45 (`exts` statt `xor r2,r2` vor `div rr2,#k`, 2 Stellen: die beiden `switch`-Hashes) widersprechen dem Original
(0B2C/0B7C `TEST R2`; 0218/0702 `XOR R2,R2`) und sind fuer ed abgeschaltet (`pipeline.py: C2_AUS["ed"]`).

## 3. Neue c2-Regeln R80-R91 (nur ed: `uspace.c2_ed_s`, aufgerufen mit `c2_emu_s(..., ed=True)`)

Modell des alten c2, **kein Lauf desselben**; jede Regel ist an genau den angegebenen ed-Stellen gemessen.  Gemeinsamer Kern: der c2, der ed uebersetzte, gibt
weniger Registerkopien weiter als der ausgelieferte (laedt Variablen erneut aus dem Speicher).

| Regel | Form (ausgelieferter c2 -> Original) | Stellen (Original) |
|-------|---------------------------------------|--------------------|
| R80 | `ld rB,rA` (rA haelt MEM aus Laden/Speichern im selben Block) -> `ld rB,MEM`; globales MEM nur bei Hilfsregister r0-r7; lokales MEM nicht, wenn direkt nach einem Bytelade-`xorb` gespeichert (`i = *ep++` als Wert); nie fuer Registerparameter (`~x:=rA`) und `ld rB,rA ; inc rA` (`*p++`) | 12: 0696, 0AA6, 1038, 11A2, 1CF4, 218C, 2194, 2302, 230A, 24AE, 24D4, 0894 (mit R81) |
| R81 | `ld rA,rB ; cp rB,X` -> `cp rA,X` | 2: 0894 (setall), 044A |
| R82 | `switch`-Hash `ld r3,rX ; xor r2,r2 ; div ; ex` -> `ld r2,rX ; ld r3,r2 ; ...` | 2: 0214, 06FE |
| R84 | `ld r3,r5 \| div rr4,#k ; add/sub r2,r5` -> `... add/sub r2,r3` | 4: 1664, 1E92, 1EE2, 1F2C |
| R85 | `and rX,#k ; ld rN,rX ; ld MEM,rN ; jr eq/ne` -> `test rN` vor dem Sprung | 1: 17D4 |
| R86 | `cp rN,MEM`, waehrend r0 MEM haelt (R4) -> `cp rN,r0` | 1: 1814 |
| R87 | `div rr2 \| ldl rr2,rr4 ; ld MEM,r3` -> `ld r2,r3 ; ld MEM,r2`, naechstes Lesen von r3 laedt neu | 2: 191A, 24BC |
| R88 | `ldb rl2,X ; [xorb] ; ld rV,r2` (rV = r8-r13) -> ueber r0 mit `xorb rh0` | 2: 1D2A, 2006 |
| R89 | `ldb rlN,X ; inc rN ; ldb Y,rlN` -> `xorb rhN` bleibt | 1: 1C1E |
| R90 | `while`-Schleife mit `switch`: Test oben, Fallkette vor dem Inkrement, erster Fall dahinter (kein Drehen) | 1: 0090 (main) |
| R91 | `jp` dessen Ziel in `jr`-Reichweite liegt -> `jr` | 1: 0658 |

Zu R91: im gebauten Eigencode gibt es genau **einen** `JP cc`, dessen Ziel in `JR`-Reichweite liegt, im Original **keinen** (Auszaehlung beider Listings).  Das `.s` traegt keine
Adressen; die Regel erkennt die Stelle daher an ihrer Form (`cp r2,#%1FFF ; jp eq`, EOF-Fall der `commands()`-Kette) -- eine beschriebene Einzelstelle, keine allgemeine Regel.
R90 ist ebenso eine Einzelstelle (regulaerer Ausdruck auf die Blockfolge).

Gegenproben (warum die Bedingungen von R80 so eng sind, gemessen): 0EFE `a1 = ++dol; a2 = a1+1` behaelt `LD R12,R13` (Kopie in Registervariable, globales MEM);
1E46/1EA2 `braelist[i = *ep++]` behalten `LD R2,R3`; 1FCA `backref` (`register i` Parameter) behaelt `LD R2,R13`; 20D6 `*lp++` behaelt `LD R2,R13`.

Regression: Hostvergleich `c2_emu_s` vor/nach (Stand `us-cmd-s3b3` gegen jetzt) ueber alle 58 vorhandenen `.s` anderer Programme (`userspace/*/work/bau/neu.s` des Haupt-Checkouts,
20 Module `sh/v7fix_s`): **0 Aenderungen**.  Die Regeln greifen nur mit `ed=True`.  Information: auf die anderen Programme angewandt griffe R80 an 33, R88 an 6 Stellen --
deren (bytegleiche) Originale wurden also mit einem c2 uebersetzt, der Kopien weitergibt: ed stammt aus einem **anderen c2-Stand** (wie `sh`, README Punkt 2).
Test: `test_c2_model_ed_rules_r80_r90` (Regeln nur mit `ed=True`, Gegenproben Registerparameter und `*p++`).

## 4. Ergebnis

**G**: `pipeline.py alles ed --c2emu --libc alt --ist neu_c2_s` -> Kopf gleich (text 11222, data 234, bss 4900), `11456 of 11456 equal ... => BYTE-IDENTICAL`;
`cmp work/bau/neu_c2_s.bin work/ed.orig` ohne Ausgabe (11472 B = Abbild + 16 B Kopf).  `pipeline.py --check ed` ok, `pytest tests/test_userspace_pipeline.py` 9 passed, 1 skipped.

Weg (Eigencode-Differenzbloecke im Bericht bzw. Hilfsvergleich): 45 (Ausgang) -> 32 (Quelle 1-3, R42/R45 aus; text 11206) -> 9 (R80-R90; text 11224, nur noch 0658 `JP`/`JR`
und Adressfolgen) -> 0 (R91).  Restliche Zeilen des Hilfsvergleichs bei 9 Bloecken (`OUT @R4,R0`, `DJNZ R15`, `LDB RH6,R13(...)`) waren Fehldeutungen der Karte an Marken
mitten im Befehl (gleiche Bytes), keine Unterschiede.
Die Variante `neu` (Binden im Stufenbau ohne c2-Modell) liefert weiterhin `NO binary` (wie in cmd_s3b3.md, nicht untersucht); der Beweis braucht nur `neu.s` -> `neu_c2_s`.

## Aussagekraft

Wie README Punkte 1, 2 und 5.  Die drei Quellabweichungen sind durch Bytes belegt (Gast-Bau, Vergleich vor/nach).  Der c2-Anteil (R80-R91, 29 Stellen, alle nur in ed) ist
ein Modell mit schwachen Belegen (6 Regeln mit 1-2 Stellen, R90/R91 Einzelstellen nach Form); er belegt keine Eigenschaft des alten c2, sondern beschreibt, worin dessen
Ausgabe sich von der des ausgelieferten c2 unterscheidet.
