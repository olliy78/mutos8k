# W10k: Verfeinerungen von `-xcmpmem`, gueltige Kombinationsmessung

Fortsetzung von `wk_w10j.md` Abschnitt 5. Alles *gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht.

## 1. Schalter erreichen beide Module (Aufgabe 0)
`hzpass` steht in `c20.c`, die uebrigen Schalter in `c21.c`; eine Variante ist nur gueltig, wenn **beide** Dateien die Defines sehen.
Gemacht wird das wie in W10h, aber fuer beide Dateien: je Variante ein Verzeichnis `userspace/c2/work/var/NAME/` mit `c20.c`, `c21.c`, `c2.h`,
wobei `c20.c` und `c21.c` mit `#define XPUSH 1` / `#define XCMPMEM 1` / `#define XHZERO 1` beginnen (Schleife in der Shell, `cat hdr c20.c > ...`).
Bau: `pipeline.py bau c2 --c2emu --libc alt --quelle cm7=.../var/cm7 --quelle all7=.../var/all7` (mehrere Varianten in einem Aufruf).
`--flags "-O -s -DXHZERO"` wurde nicht benutzt: es gilt fuer **alle** Quellen eines Aufrufs, also nur eine Variante je Aufruf.
Pruefung der Wirkung: `all7_c2.bin` 20482 B gegen `cm7_c2.bin` 19348 B; die Differenz (1134 B) entspricht dem `hzpass`/`-xhzero`-Zuwachs von W10i
(`hz4` 20088 B gegen Standard 18956 B = 1132 B). Der ungueltige `all6` (20416 B, ohne `hzpass`) lag darunter.

## 2. Aenderungen (`c21.c`, nur unter `XCMPMEM`)
* `repladdr` blendet `regs[0]` (`x4keep`) nicht aus, wenn der Knoten ein `MOV` unmittelbar hinter einem bedingten Sprung (`CBRS`/`CBR`) ist (R38: `cp r0,#k ; jr cc ; ld rN,MEM` -> `ld rN,r0`).
* `mv:` loescht ein wiederholtes eingefuegtes `ld r0,MEM` (X4MARK) nur noch bei gesetztem `x4keep`.
* Standard-c2 unveraendert: `cpp -P -I.` Tokenstrom-md5 (`tr -s ' \t\n' '\n'`) von `c21.c` vor und nach der Aenderung gleich (`88c7208a...`);
  die Methode, die `b23c00a0...` ergab, ist nicht mehr bekannt (nicht reproduzierbar), deshalb Vorher/Nachher-Vergleich und `pipeline.py --check c2` (Abschnitt 5).
* Gebaut: `cm7_c2.bin` 19348 B, `all7_c2.bin` 20482 B (Stand im Commit); `cm8_c2.bin` 19330 B, `all8_c2.bin` 20464 B (nur `jr`-Sprung `CBRS`, verworfen).

## 3. Abnahme (Stand im Commit)
* **`cm7` gegen ausgelieferten c2 + R4,R38,R69, 39 Dateien: 35 gleich**, 4 abweichend (W10j: 36/39).
  Gleich jetzt: tar (Zeile 2346 behoben), pr, passwd; abweichend: cpp, cpp/cpy, sh/xec (c2x reuse `ld r2,r0`, Original `ld r2,_fretop` / `-%1E(FP)` / `sla`) und tar (spaeter, Zeile 2349: Original `push @SP,r0`, c2x `push @SP,-%E(FP)`).
* **`all7` auf den 65 Modulen gegen ausgelieferten c2 + R1,R4,R38,R69,R2,R7,R10,R30,R32,R43,R63: 52 gleich**, 13 abweichend (W10i: 50/65, ungueltiger all6: 32/65).
  Abweichend: `-xhzero`-Reste c0/c00, c0/c02, c2/c20, c2/c21, convert, ed, init, ld, mv (wie W10i) und die `-xcmpmem`-Reste cpp, cpp/cpy, sh/xec, tar.
  Behoben gegenueber W10i: mkfs, sh/cmd, sh/stak, od, ncheck (R38-Stellen), c0/c03.

## 4. Befund zu R38 und Rueckschritt `cm8`/`all8` (verworfen)
Das Original reuse R0 hinter `jr cc` (R38, kurzer Sprung), nicht hinter einem weiten `jp cc` (cpp `jp ge L34`, xec `jp ge L13`).
Eine Unterscheidung `CBRS` gegen `CBR` in `rmove` ist nicht moeglich: dort sind alle bedingten Sprung noch `jp` (`shortjmp` laeuft spaeter).
Der Versuch, nur `CBRS` zuzulassen (`cm8`/`all8`): cm 35/39 (cpp, cpy, xec behoben; od, mkfs, stak neu abweichend), all 49/65 (schlechter als `all7`).
* **Naechster Schritt (nicht gebaut)**: R0-Wiederverwendung in einem spaeten Durchgang nach `shortjmp` (neben `hzpass`): Muster `ld r0,MEM [X4MARK] ; cp r0,.. ; jr cc ; ld rN,MEM` -> `ld rN,r0`;
  `repladdr` blendet `regs[0]` dann immer aus (Stand W10j). Das trennt kurze und weite Spruenge.

## 5. c2/c20 -xorb-Rueckschritt (nur Befund, nicht behoben)
Weiter abweichend: c2/c20 (c2x loescht `xorb rh2,rh2` vor `cp r2,#%6C`, das Modell behaelt es), c2/c21, c0/c00, init (c2x behaelt eins mehr), ld.
Die Stelle in c20 ist die `jp eq`-Kette `xorb ; cp r2,#62 ; jp eq ; ldb rl2,-D(FP) ; xorb ; cp r2,#6C ...`.
`hzpass` (nur Folgeknoten `ldb mem,rlN`) ist hier nicht die Ursache (*gemessen*: Muster passt nicht), vermutlich entscheidet `hzkeep` in `rmove` falsch, wenn das redundante
`ldb rl2,-D(FP)` schon vor dem `xorb` geloescht ist (dann ist `p->back` der Sprung und nur der `CBR`-Zweig mit "erstes `xorb` der Kette" gilt) (*Annahme*, nicht gebaut).

## 6. Verbrauch
Bau 2 Aufrufe (je 2 Varianten: `cm7`/`all7`, `cm8`/`all8`); Gastlaeufe: `lauf` all7 (65 Module), cm7 (39 Dateien), all8, cm8, plus `--check c2` (ein Fehlstart mit `$=VAR` in bash ohne Gastlauf).
