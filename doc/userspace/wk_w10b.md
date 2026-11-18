# W10b: funktionale Gegenprobe des rekonstruierten c2 (Stand: nicht bestanden / ungeklaert)

Ziel: unser c2 (`userspace/c2/c2.h, c20.c, c21.c`, 4609/4717 Befehle gleich) laeuft als Optimierer und liefert fuer dieselbe
`.s0`-Eingabe (c1-Ausgabe) denselben Text wie das mitgelieferte `/usr/lib/c2`.

## Werkzeug

`tools/userspace/c2gegen.py lauf NAME... --c2x DATEI` (rein additiv): legt die c2-Binaerdatei als `/mnt/c2x` in den Gast und
laesst sie nach dem mitgelieferten c2 auf demselben `c5` laufen. Ergebnis je Modul: `MOD.s0` (c1), `MOD.s` (Original-c2),
`MOD.sn` (unser c2), zusaetzlich `MOD.sm` (unser c2 ein zweites Mal) und `MOD.sb` (Original-c2 ein zweites Mal), um
Nichtdeterminismus von Fehlern zu trennen. Ohne `--c2x` unveraendert.

## Messungen

* Bau: `pipeline.py alles c2 --c2emu --libc alt --ist neu_c2` -> `neu_c2.bin` (18956 Byte; 4609 von 4717 Befehlen gleich, wie bekannt).
* Lauf A (`lauf ed tar --c2x ...`, 2 Sitzungen, 135 s und 83 s): Original-c2 liefert saubere Ausgabe (`ed.s` 46511 B, `tar.s` 38687 B).
  Unser c2 laeuft ohne Fehlermeldung durch, die Ausgabe ist aber **nicht gleich und nicht als Text brauchbar**:
  `ed.sn` 43836 B, `tar.sn` 38329 B. Zeilenweiser Abgleich (difflib): ed 223, tar 132 Abweichungsbloecke.
  Der Anfang der Ausgabe (erste ca. 1 KB, in ed auch spaeter) ist zerstueckelt: Fragmente aus `.s` und `.s0` an falschen Stellen,
  Zeilen mitten im Wort abgeschnitten und aneinandergehaengt (z.B. `ld -%E(FP` direkt gefolgt von `:= global`, `call _dup`/`all _dup`),
  der Kopf `c_ module ... L := label` steht erst ab Zeile 36 statt Zeile 1, und in diesen Bereichen steht unoptimierter c1-Text
  (`jp ge L6` statt `jr ge L6`, `jp L3`). Grosse Mittelstuecke (tar: 3965 Byte am Stueck ab Offset 1024) sind dagegen byteweise gleich
  dem Original. Das Muster (stellenweise falsche, an 512-Byte-Grenzen beginnende Bereiche mit Altinhalt aus /tmp) sieht nach Schreiben an
  falschen Dateipositionen aus -- die Luecken zeigen dann Restbloecke frueherer /tmp-Dateien. *Annahme*, nicht bewiesen.
* Lauf B (12 kleine Module, `--c2x`): nach dem `cat`-Modul (unser c2 zweimal, ENDE3 erreicht) blieb der naechste Befehl
  (cpp/c0 von `wc`) ueber 36 Minuten Wandzeit haengen (ZVE1 im Gast-Kernel, `lauf.log` bei ENDE4); abgebrochen, keine Ergebnisse
  abgeholt. Ob unser c2 den Gast/das Dateisystem beschaedigt hat, ist *ungeklaert*; Auffaellig ist nur, dass der Hang nach dem ersten
  Einsatz von `c2x` auftrat.

## Befund

Unser c2 ist (noch) **nicht funktional gleich**: die Ausgabe wird fehlerhaft geschrieben. Dass die Optimierungslogik selbst
abweicht, laesst sich aus den zerstueckelten Bereichen nicht beurteilen; die intakten Mittelstuecke sind identisch.

## Naechste Schritte (nicht ausgefuehrt, Gast-Laeufe waren aufgebraucht)

1. Ausgabeweg pruefen: `freopen(argv[2], "w", stdout)` in `c20.c`, Puffer-/Array-Groessen in `c2.h` (ein Feld mit falscher Groesse
   kann `_iob`/den stdout-Puffer ueberschreiben; Layout von Daten und bss gegen das Original vergleichen -- Text ist 20 Byte kuerzer).
2. Gegenprobe mit `--libc disk` statt `alt` bauen, um die rekonstruierte libc auszuschliessen.
3. Ein kleines Modul (`cat`) einzeln mit `sn`, `sm` (Wiederholbarkeit) im Gast ansehen, die Ausgabe auf stdout statt Datei lenken.
