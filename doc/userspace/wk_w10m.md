# W10m: die `-xhzero`-Reste von `all9` nach Ursachen (nur Befund, kein Codewechsel)

Fortsetzung von `wk_w10l.md`. Alles *gemessen* (Gastlauf 2026-11-20: `all9_c2.bin` auf c0 c2 convert ed init ld mv cpp, `--s0 --kurz`; danach Host-Vergleich), ausser wo *Annahme* steht.
Ergebnis vorweg: **kein c2-Code geaendert**; die Reste haben keine Ursache, die sich aus den Messdaten ohne erfundene Heuristik beheben liesse.
Zwei der acht `-xhzero`-Reste sind Fehler der **Abnahme**, nicht des c2x. Der c2-Quelltext ist unveraendert (`tokcheck` OK), deshalb kein Bau (`hz10`/`all10` entfallen) und die Zahlen
von W10i (hz 45/53) und W10l (all 54/65) bleiben stehen.

## 1. Abnahme-Befund: Regelmenge je Programm
`c2gegen.py xpush` (und die Zahlen W10i/k/l) wendet auf **jedes** Modul dieselbe Regelmenge an. Das Original hat aber je Programm Regeln aus (`pipeline.py` `C2_AUS`):
* **init: gleich**, sobald R3 im Modell steht. Der Rest `xorb ; cp #%A ; jr eq L9020 ; xorb ; jr L81` ist genau R3 (init hat R3 an, `C2_AUS` kennt nur sh/od/dd mit R3 aus);
  der c2x behaelt das `xorb` (hzkeep, Zweig `JBR`), die Abnahme ohne R3 kennt es nicht. R3 steht aus gutem Grund nicht in der Liste (W10h: mit R3 insgesamt schlechter, weil die R3-Stellen in pstat/ps/dd/od
  in der c1-Ausgabe gar kein `xorb` haben), ist aber fuer init die richtige Regel.
* **ld** (`C2_AUS`: R32, R43 aus) und **c2/c20, c2/c21** (`C2_AUS`: R5, R7, R32, R45 aus): das Modell der Abnahme setzt dort R32/R7/R43 an, die das Original nicht hat. Mit der Programm-Regelmenge (`aus |= C2_AUS`)
  wandert der erste Unterschied bei ld auf die R43-Stelle (Zeile 2226: c2x behaelt `xorb rh4` vor `ldb @r2,rl4`, Original nicht), bei c20/c21 auf die R7/R32-Stellen (c2x behaelt, Original nicht).
  Diese Module brauchen einen c2x **ohne** die jeweilige Regel; das ist die schon offene "Schaltermenge je Programm" (c2x-Schalter nur global), keine Ursache im Code.
  Damit ist auch die Frage nach ld beantwortet: das Modell R32 ist an dieser Stelle nicht uebergepasst, sondern ld hat R32 aus; die c1-Ausgabe hat dort (Switch-Kette `cp #2 ; jp eq ; cp #3`) tatsaechlich kein `xorb`.
  Dasselbe Bild bei c2/c20 `jp eq`-Kette: Modell (R32 an) setzt `xorb` vor `cp r2,#%6C`, das das c2-Original (R32 aus) nicht hat.

## 2. Reste ohne Regelmengen-Erklaerung (Ursache offen)
Erste Abweichung gegen ausgelieferten c2 + Regeln der Abnahme (Mengen wie W10l):
* **c0/c00 Zeile 1671**: c2x hat `L9105: xorb rh2,rh2 ; cp r2,#%18 ; jr ne L253`, das Modell nicht. c1: `ldb ; xorb ; cp #9 ; jp eq L252 ; ldb ; xorb ; cp #%18 ; jp ne L253 ; L252:`;
  der c2 baut daraus durch Sprungumkehr einen neuen Block `L9105`. Gleiche Form `jr eq Lx ; xorb ; cp ; jr ne Ly` erhaelt R32 in cpp (Zeile 1822) und od, wo das Modell das `xorb` behaelt. Warum das Original es hier loescht, ist aus den
  Messdaten nicht ableitbar (*Annahme*: die Sprungumkehr laeuft im Original vor `rmove`, dann steht ein Label vor dem `xorb`; nicht geprueft). Mit R3 im Modell: erster Unterschied Zeile 1200, dort setzt das Modell ein `xorb` vor `jr L154`,
  das in der c1-Ausgabe nicht steht (der c2x kann es nicht erzeugen, wie bei pstat/ps/dd/od).
* **c0/c02 Zeile 200**: c2x `jp eq L9` statt `jr eq L9` (Sprungspanne); Folge der Blocklaenge, *Annahme*: haengt am c00-Befund (`xorb`-Zahl), nicht geprueft.
* **convert Zeile 134**, **ed Zeile 141**, **cpp Zeile 510**: Blocklage/`jr`-Form (z. B. cpp: Modell `jr L81`, c2x `L81:` mit Kopie des Blocks; convert: `ld r0,_mode ; cp r0,#1` beim c2x). Nicht auf ein `xorb` zurueckgefuehrt;
  convert hat R2 aus (`C2_AUS`), also loescht `hzpass` dort Knoten, die das Original behaelt (Folge der Regelmenge, 2 Stellen), das verschiebt Spannen. *Annahme*, nicht mit einem Lauf getrennt.
* **mv Zeile 747**: `ld r12,r4 ; test r4` (c2x, gleich dem ausgelieferten c2) gegen Modell `ld r12,r2 ; test r2` (R63, Kopieanteil). Das ist Kopiepropagation (`-xcopyprop`), kein `xorb`-Thema; *nicht neu* (W10h Abschnitt 3 nennt es schon).

## 3. Messwerte
* Gastlauf `all9_c2.bin` auf c0, c2, convert, ed, init, ld, mv, cpp (15 Module, 8 Sitzungen, je 40-80 s): 14 weichen vom ausgelieferten c2 ab (erwartet, die Regeln stehen im Modell); von den 11 untersuchten Modulen (die acht Reste, cpp/cpy, c02, mv) weichen gegen das Modell der Abnahme 10 ab (c00, c02, c20, c21, convert, ed, init, ld, mv, cpp), cpy gleich.
* Mit R3 im Modell wird init gleich (11 -> 10 Abweichungen auf diesen Modulen); die Gesamtzahl 54/65 (W10l) bleibt als Bezugsgroesse, bei init-mit-R3 waeren es 55/65 (*Annahme*: die uebrigen 51 Module aendern sich durch R3 nicht, nicht gemessen; W10h: R3 verschlechtert dort).
* Standard-c2: `tokcheck` OK; `pipeline.py --check c2` OK (Text 16976, Daten 1984, 85 Funktionen); `pytest -m "not gast"` 212 passed, 3 skipped.

## 4. Verbrauch und naechster Schritt
* Bau 0, Gastlaeufe 2 (`lauf` all9 auf 8 Programmen, `--check c2`).
* Naechster Schritt: (a) `xpush`/`auswerten` mit `C2_AUS` je Programm und `R3` fuer Programme ohne R3-aus (damit init/ld/c20/c21 nicht mehr als c2x-Fehler zaehlen);
  (b) c00: einen c2x mit Zaehlern/Ausgabe je `hzkeep`-Treffer bauen und in c00 die Stelle `L251` verfolgen (ist ein Label vor dem zweiten `xorb`, wenn `rmove` es sieht?).
