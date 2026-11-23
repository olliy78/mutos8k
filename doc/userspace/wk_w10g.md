# W10g: Schalter `-xcmpmem` (Regel R4) als c2x-Variante

Fortsetzung von `wk_w10f.md`. Alles *gemessen* (Gastlaeufe 2026-11-19/20), ausser wo *Annahme* steht.

## 1. Standard-c2 unveraendert
`pipeline.py bau c2 --c2emu --libc alt --variante neu` aus den aktuellen Quellen: `neu_c2.bin` 18956 B, **bytegleich** zum Stand W10f (`cmp`); `--check c2` OK
(Text 16976, Daten 1984, 85 Funktionen). Vorverarbeitung von `c21.c` (host `cpp -P -I.`) ohne Define vor/nach der Aenderung tokengleich (gleiche md5); mit `-DXCMPMEM` +80 Tokens.

## 2. Mechanismus R4
Der ausgelieferte c2 laesst `cp MEM,#k` stehen (c1 liefert diese Form, gemessen an `MOD.s0` von echo/cat/wc/size: 5/9/15/2 Stellen, c2 aendert sie nicht).
Die Originale haben `ld r0,MEM ; cp r0,#k`. Umsetzung (`userspace/c2/c21.c`, `rmove`, `case CMP`, `#ifdef XCMPMEM`): bei Wort-`cp` (nicht BYTE/LONG/FLTF) mit
Speicheroperand (nicht Register, nicht `@`) und Direktwert wird vor dem `cp` ein `MOV r0,MEM`-Knoten eingefuegt und `cp` auf `r0,#k` umgestellt; der neue Knoten
laeuft selbst durch die Registerverfolgung, daher entfaellt ein zweites `ld r0,MEM` hinter `jr cc` (R0-Wiederverwendung des Modells) von selbst.
Verfeinerung gegen die Messung (erster Versuch ohne): der eingefuegte Knoten (`labno == X4MARK`) bekommt **keine** Kopie-Propagation aus einem Register (`repladdr` ausgelassen);
sonst entstand `ld r0,r2` statt `ld r0,MEM` (cat, od). Die R60-Form (`ld r0,rN` hinter `and rN,#%FF`) bleibt damit Modell-Sonderfall (1 Stelle, od), nicht Teil des Schalters
*(Annahme: ein Schalter fuer R60 waere eine eigene Gruppe)*. Das c2 waechst um 210 B (`c2x_c2.bin` 19168; zusammen mit `-DXPUSH` 19184).

## 3. Abnahme (`c2gegen.py lauf ... --s0 --kurz --c2x`, dann `c2gegen.py xpush ... --regeln R1,R4[,R38]`)
Module (15, alle R4-Stellen): echo cat wc size cmp od date kill who ln mkdir mknod pr passwd chown; R4-Stellen 1+4+4+2+5+6+8+2+4+4+1+3+5+21+1 = 71.
* `-DXCMPMEM` allein (erster Stand, ohne X4MARK): 11 von 15 gleich shipped + R4; cat und od (`ld r0,r2`), pr, passwd weichen ab (Ursachen unten). Mit dem Endstand
  nicht mehr allein gebaut (Bau-Budget), nur zusammen mit XPUSH:
* `-DXPUSH -DXCMPMEM` (Endstand): gegen shipped + R1+R4: **12 von 15 gleich**; gegen shipped + R1+R4+R38: **14 von 15 gleich** (od, pr gleich, weil R38 - Wegfall von
  `ld r0,M` hinter `cp r0,#k ; jr cc` - genau das ist, was das Original tut: R38-Stellen 1 in od, 1 in pr; das neue c2 liefert sie von selbst).
* R1-Stellen in diesen Modulen: 23 (cmp 1, od 1, date 1, who 3, ln 2, mkdir 7, pr 1, passwd 5, chown 1, ...).
* Rest: `passwd` 1 Stelle: `jr eq L21` (shipped/Modell) gegen `jp eq L21` (c2x): die eingefuegten Befehle verlaengern den Code, die Sprungweitenschaetzung des c2 (`toofar`/`ilen`,
  Regeln R16/R77) kippt. Ob die Originale hier `jr` haben, wurde nicht gegen das Original-Binary geprueft *(offen)*.

## 4. Verbrauch und offen
Gastlaeufe 4 (g1 s0-Erzeugung echo cat wc size; Abnahme 1; 15 Module voll; 15 Module `--s0`), c2-Neubauten 4 (neu, c2x XCMPMEM v1, v2, XPUSH+XCMPMEM).
Offen: `-DXCMPMEM` allein mit dem Endstand (X4MARK) nicht erneut gebaut; passwd-`jr`/`jp`; R60; Wirkung auf ganze Programme (Binaerabgleich mit den Originalen) nicht gemessen;
R4-Formen `cp @rN,#k` (R50, mkfs) und der Satz ed/mkfs/cc/ld nicht untersucht.
