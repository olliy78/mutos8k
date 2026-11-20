# W10l: spaeter Durchgang `cmppass` fuer `-xcmpmem` (R38), Variantengenerator, Token-Pruefung

Fortsetzung von `wk_w10k.md` Abschnitt 4. Alles *gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht.

## 1. Reproduzierbarkeit (Aufgabe 0, nur Host)
* **Variantenverzeichnisse:** `python3 -I tools/userspace/c2gegen.py var NAME DEF...` schreibt `userspace/c2/work/var/NAME/{c20.c,c21.c,c2.h}`;
  beiden Dateien werden `#define DEF 1`-Zeilen vorangestellt (`var cm9 XCMPMEM`, `var all9 XPUSH XCMPMEM XHZERO`).
  Bau danach wie bisher: `pipeline.py bau c2 --c2emu --libc alt --quelle cm9=.../var/cm9 --quelle all9=.../var/all9`.
* **Token-Pruefung des Standard-c2:** `c2gegen.py tokcheck` bildet `cpp -P -I userspace/c2 DATEI | tr -s ' \t\n' '\n' | md5sum` (ohne Defines) von `c20.c` und `c21.c`
  und vergleicht mit `userspace/c2/tokens.md5` (committet). Soll-Wert = Quellen vor dem ersten c2x-Schalter (Git-Stand `705e611^`, vor W10f);
  `tokcheck --update` leitet die Datei daraus neu ab. Ergebnis: `c20.c f52f21b0...`, `c21.c b23c00a0...` -- die in W10j dokumentierte Summe `b23c00a0` ist damit **reproduziert**
  (Methode war `cpp -P -I<c2-Verzeichnis>`, nicht im Arbeitsverzeichnis mit anderem Include-Pfad).
* **Befund:** `c21.c` lag seit W10g bei `88c7208a...`, nicht `b23c00a0...`: der Block `} else if (r1 >= 0) { savereg(...); x4keep... }` hatte Klammern, die im Standard-c2 fehlten
  (semantisch gleich, tokenweise nicht). Jetzt steht die Klammer nur noch innerhalb `#ifdef XCMPMEM`; Standard-c2 wieder tokengleich zum Ausgangsstand.

## 2. Aenderung (`c21.c`/`c20.c`, nur unter `XCMPMEM`)
* `repladdr` blendet `regs[0]` bei gesetztem `x4keep` **immer** aus (Ausnahme hinter `CBRS`/`CBR` aus W10k entfernt).
* Neu `cmppass()` (c21.c), aufgerufen in `c20.c` nach der `shortjmp`-Schleife, vor `hzpass`: Muster `ld r0,MEM [X4MARK] ; cp r0,.. ; jr cc ; ld rN,MEM`
  (Wort, N != 0, gleicher Speicheroperand, Zwischenknoten keine) -> `ld rN,r0`, nur wenn der Sprung nach `shortjmp` ein `CBRS` (`jr`) ist. Weite `jp cc` bleiben unberuehrt.
* Bau: `cm9_c2.bin` 19554 B, `all9_c2.bin` 20688 B (der Zuwachs von +206 B gegen cm7/all7 ist der neue Code in c2 selbst).
  Ein erster Bau (Verbrauch) scheiterte am Linken (`_cmppass` undefiniert: Einfuegestelle nicht getroffen, ohne Gastlauf).

## 3. Abnahme
* **`cm9` gegen ausgelieferten c2 + R4,R38,R69, 39 Dateien: 38 gleich**, 1 abweichend (W10k: 35/39). Rest: tar Zeile 2349
  (Original `push @SP,r0`, c2x `push @SP,-%E(FP)`), schon aus W10k bekannt. cpp, cpy, sh/xec, pr, passwd, od, mkfs, sh/cmd, sh/stak jetzt gleich.
* **`all9` auf den 65 Modulen gegen ausgelieferten c2 + R1,R4,R38,R69,R2,R7,R10,R30,R32,R43,R63: 54 gleich**, 11 abweichend (W10k: 52/65).
  Abweichend: die `-xhzero`-Reste c0/c00, c0/c02, c2/c20, c2/c21, convert, ed, init, ld (wie W10i/k) sowie cpp (Zeile 510: Modell `jr L81`, c2x `L81:`), mv (Zeile 747: `ld r12,r2` gegen `ld r12,r4`)
  und tar (wie cm9). cpp und mv sind **neu** gegen die W10k-Liste (cpp war dort mit anderer Stelle abweichend, mv ist neu): *Annahme*: Folge von `cmppass` bzw. der Sprungweite, nicht untersucht.
* Behalten: `cm9`/`all9` (beide besser als W10k).

## 4. Pruefung des Standard-c2
`tokcheck` OK; `pipeline.py --check c2` OK (Text 16976, Daten 1984, 85 Funktionen); `pytest -m "not gast"` 214 passed.

## 5. Verbrauch
Bau 2 Aufrufe (je cm9/all9; der erste unbrauchbar), Gastlaeufe: `lauf` all9 (65 Module), `lauf` cm9 (39 Dateien), `--check c2`.
