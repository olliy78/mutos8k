# W10j: `-xcmpmem` auf groesseren Modulen

Fortsetzung von `wk_w10i.md` Abschnitt 3. Alles *gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht. Bau/Abnahme wie in W10h/W10i.
Hinweis zum Aufbau: `c2gegen.py lauf NAME` liest `MOD.s0` aus `userspace/c2/work/gegen/NAME/` (je Programm ein Unterverzeichnis, nicht flach).

## 1. Gegenprobe `-DXCMPMEM` allein (W10g-Binary `cm_c2.bin`, vor der Aenderung)
Gegen ausgelieferten c2 + R4, 6 Module/24 Dateien (cpp cpy mkfs sh/* tar): **17 gleich, 7 abweichend** (cpp, cpy, mkfs, sh/cmd, sh/stak, sh/xec, tar).
Alle gleiche Ursache wie in W10i: der eingefuegte `ld r0,MEM` bleibt als Registerinhalt (`regs[0]`) stehen, `repladdr` ersetzt spaetere `ld r2,MEM`, `test MEM`, `push MEM` durch `r0`;
das Original behaelt den Speicheroperanden (oder nimmt ein anderes Register). Die Ursache liegt also im Schalter selbst, nicht in `-xhzero`/`-xpush`.
(`cregs` aus W10i ist die Konstantentabelle; gemeint ist `regs[0]`.)

## 2. Aenderung (`c21.c`, nur unter `XCMPMEM`)
`x4keep` (gesetzt in `rmove`, wenn ein X4MARK-Knoten `ld r0,MEM` in R0 gespeichert wird; geloescht von `kill(0)`); `repladdr` blendet `regs[0]` waehrend der beiden `findrand`-Suchen aus.
Der erste Versuch (Pruefung `rnode[0]->labno == X4MARK`) wirkte nicht: `rnode[0]` ist nach dem folgenden `cp r0,#k` schon 0 (Benutzung loescht den Verweis); deshalb das Flag.
Das zweite `cp MEM,#k` (`mv:`-Loeschung des wiederholten `ld r0,MEM`) bleibt unberuehrt.
Standard-c2 unveraendert: `cpp -P` Tokenstrom-md5 von `c21.c` `b23c00a0...`; `pipeline.py --check c2` OK (Text 16976, Daten 1984, 85 Funktionen); `pytest -m "not gast"` 214 passed.
Gebaut: `cm6_c2.bin` 19286 B (`-DXCMPMEM`), `all6_c2.bin` 20416 B (siehe 4: ungueltig).

## 3. Abnahme `cm6` gegen ausgelieferten c2 + R4
* **36 von 39 gleich** (19 Programme der 15er-Menge + cpp mkfs sh tar = 39 Dateien); vorher 17 von 24 auf den 6 Modulen. cpp, cpy, mkfs, sh/cmd, sh/stak, sh/xec, od jetzt gleich.
* Abweichend (3):
  * pr (`ld r0,_ncol` / `cp r0,_width`) und passwd (`jr`/`jp`): beide wie in W10g (pr gleich erst mit R38; passwd Sprungweite), keine neue Ursache.
  * **tar** Zeile 2346 (neu): `ld r0,M ; cp r0,_nblock ; jr eq L ; cp M,#1`. Das Original behaelt hier kein R0 fuer das zweite `cp` (Modell: `ld r0,M ; cp r0,#1` wieder), c2x loescht den eingefuegten `ld r0,M`, weil `regs[0]` aus dem *gewoehnlichen* `ld r0,M` stammt.

## 4. Kombination `all` (XPUSH+XCMPMEM+XHZERO) auf 65 Modulen: **nicht gueltig gemessen**
`all6_c2.bin` wurde ohne `#define XHZERO` in `c20.c` gebaut (nur `c21.c` bekam die Defines; `hzpass` steht in `c20.c`, Zeile 170): 32 von 65 gleich, fast alle Abweichungen sind `xorb` an Stellen, die `hzpass` loeschen soll.
**Variantenverzeichnisse brauchen die Defines in `c20.c` und `c21.c`.** Der Wert 50/65 aus W10i bleibt der letzte gueltige.
Neben dem Fehler sind zwei echte Befunde aus diesem Lauf lesbar (mit R38 im Modell): mkfs (2), ncheck, od, sh/stak, c0/c03 erwarten `ld rN,r0` (R38) und bekommen mit dem Ausblenden den Speicheroperanden.

## 5. Naechster Schritt (nicht gebaut, Budget erschoepft)
* R38 ist die einzige Stelle, an der das Original `regs[0]` aus dem X4-Knoten weiterverwendet: `cp r0,#k ; jr cc ; ld rN,MEM` -> `ld rN,r0`. Das Ausblenden in `repladdr` also nur lassen, wenn **nicht** `p->op == MOV && p->back->op == CBR` (der unmittelbar vorangehende Knoten ein `jr cc`).
* tar: die `mv:`-Loeschung eines X4-Knotens nur, wenn `x4keep` gesetzt ist (R0 stammt aus einem X4-Knoten, nicht aus einem gewoehnlichen `ld r0,MEM`).
* Danach `cm` (R4,R38) und `all` mit Defines in beiden Dateien auf 65 Modulen neu messen; c2/c20-Rueckschritt von W10i (Aufgabe 2) wurde nicht untersucht (kein gueltiger `all`-Lauf, kein Budget).

## 6. Verbrauch
Bau 2 Aufrufe (je 2 Varianten: `cm5`/`all5` vor dem Flag-Fix wirkungslos-Stand `rnode`, `cm6`/`all6` mit `x4keep`); Gastlaeufe 4 (`lauf` cm alt auf 6 Programme, cm5 auf 19, cm6 auf 19, all6 auf 65); ein Fehlstart (zsh teilt `$VAR` nicht in Woerter) ohne Gastlauf.
