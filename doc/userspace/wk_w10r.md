# W10r: `xcc` -- cc mit Wahl des angepassten Optimierers c2x

Plan 52 W10, Schritt 3. *Gemessen* (Gastlaeufe 2026-11-22), ausser wo *Annahme* steht. `pipeline.py --check cc` OK, `xcc.py tokcheck` OK, `pytest -m "not gast"` 216 passed.

## 1. Aenderung
* `userspace/cc/cc.c`: Zusatzcode unter `#ifdef XCC` (Variablen `pass2x`, `xopt`, `xflag`; `case 'X'`; Aufruf von `c2x` statt `c2`). Ohne Define bleibt der Quelltext **token-identisch**
  (`tools/userspace/xcc.py tokcheck`, md5 in `userspace/cc/tokens.md5` aus Git-Stand `4a695c9`, Systemheader als leere Attrappen, daher rechnerunabhaengig; Test `tests/test_cc_tokcheck.py`).
  Der bytegleiche Bau `neu_c2_s` (mit `--c2emu`) liefert wieder `cc` 6536 B, `cmp` gleich `work/cc.orig`.
* Verhalten: `-X<Buchstaben>` (7 Bit, Namen <= 8 Zeichen) laesst `-O` den Optimierer `/usr/lib/c2x` statt `/usr/lib/c2` rufen, als `c2x -x<Buchstaben> in out`
  (`-X` ohne Buchstaben: c2x ohne Schalter). Mehr als 15 Buchstaben werden abgeschnitten. Ohne `-X` ist `xcc` == `cc`. `-X` wirkt nur mit `-O`.
* Bau: `python3 -I tools/userspace/xcc.py var` (schreibt `userspace/cc/work/var/xcc/cc.c` mit `#define XCC 1`), dann
  `pipeline.py bau cc --c2emu --libc alt --quelle xcc=userspace/cc/work/var/xcc/cc.c` -> `work/bau/xcc_c2_s.bin` (6810 B; mit ausgeliefertem c2 `xcc.bin` 6792 B). Bau 73 s + 30 s.

## 2. Installation im Gast (Pfade)
* `/usr/bin/xcc` (xcc_c2_s.bin) und `/usr/lib/c2x` (W10q-Bau `userspace/c2/work/bau/c2x_c2.bin`, 21190 B), Modus 0755; `/usr/bin/cc` und `/usr/lib/c2` bleiben unberuehrt.
* Der Gast hat nur `cat ls sh sync date stty` (kein `cp`/`chmod`/`mv`/`rm`/`cmp`): Installation **auf dem Host in das Plattenabbild**: `k1520disktool put usr.hfe <ordner mit bin/xcc und lib/c2x>`,
  dann `attr usr.hfe bin/xcc --mode 0755 --mtime 536457600` (ebenso `lib/c2x`).
* **Platzbefund:** die `usr`-Platte hat nur 4 KB frei, `xcc` + `c2x` brauchen rund 28 KB. Die Vorfuehrung (`xcc.py demo`) wirft in ihrer Kopie `lib/libc.a` und `lib/mcrt0.o` weg und uebersetzt daher nur mit `-c`/`-S`;
  fuer Linken braucht es eine groessere Platte (*Annahme*, nicht gebaut).

## 3. Vorfuehrung (`python3 -I tools/userspace/xcc.py demo userspace/cc/work/bau/xcc_c2_s.bin userspace/c2/work/bau/c2x_c2.bin`, ein Gastlauf, 261 s)
Je Modul drei Vergleiche, Ergebnis auf dem Host verglichen; Flags je Programm wie in W10o/q (`c2x_flags`, Regeln R1,R4,R38,R2,R7,R10,R30,R32,R43,R63 + R3):

1. `xcc -S -O -X<fl> f.c` == cpp/c0/c1 + `c2x -x<fl>` (der Lauf von `c2gegen`);
2. `xcc -S -O f.c` == `cc -S -O f.c`;
3. `xcc -O -c f.c` == `cc -O -c f.c` (Objektbytes).

Module: `df` und `rm` (`-Xmzkws73tr`), `wc` und `echo` (`-Xpcmzkws73tr`): **alle 12 Vergleiche gleich** (4 x 3). Zusaetzlich `wc.s`/`echo.s` gleich den `.sn`-Dateien aus W10q (`work/gegen`).
Gegenprobe, dass `-X` etwas bewirkt: bei `wc` und `echo` unterscheidet sich die Ausgabe mit `-X` von der ohne; bei `df` und `rm` nicht (deren Flags greifen an diesen Stellen nicht).

## 4. Verbrauch
Bau 1 (`bau cc`, liefert `neu` und `xcc`), Gastlaeufe 2 (der erste scheiterte an der Annahme, der Gast habe `cp`/`mv`/`cmp`; der zweite lief mit Installation im Plattenabbild und `cat`-Kopien).
Nicht gemacht: Bauvariante in `pipeline.py` fuer ganze Programme mit `xcc` (W10 Schritt 4).
