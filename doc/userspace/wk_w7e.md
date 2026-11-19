# W7e (Plan 52): Module ohne `-O` -- `as`-Tabellen wieder in je einem Modul

Fortsetzung von `wk_w7d.md`.  Alles *gemessen* (Gast-`cc`, sequentiell).

## 1. Pipeline-Aenderung

* `link.txt` darf je Zeile hinter dem Modulnamen die Marke `noopt` tragen (`as_y.c noopt`).  Das Modul wird dann mit den Flags des Programms **ohne `-O`** uebersetzt (`cc -c` bzw. `cc -S`).  Ohne Marke aendert sich nichts (gleiche Befehlszeilen wie vorher).
* `pipeline.quelle_lesen` liest die Marke und liefert die Quellen als `uspace.Module` (ein `dict` mit Attribut `noopt`); `uspace.gast_bauen/lauf_viele` bildet die Flags je Modul (`cfl_von`).  In der zweiten Runde (`--c2emu`) wird fuer `noopt`-Module das c2-Modell nicht angewendet (es gibt dort keinen c2; das `cc -S`-Ergebnis geht unveraendert in `as`).
* Einzeldatei-Programme (`gast_bauen` ohne `link.txt`) sind nicht betroffen.

## 2. Zusammenfuehrung der `as`-Module

* `as_y1/2/3.c` -> `as_y.c` (ganze yacc-Ausgabe, `noopt`); `as_tab1/2.c` + `as_tabd1/2/3.h` -> `as_tab.c` mit ganzem `as_tabd.h` (`noopt`).  `as_ysplit.py` ist damit entbehrlich und entfernt; `as_tabellen.py` ohne Teil-Header (`--write` schreibt nur `as_tabd.h`); `as.h`: `extern struct mnent mnem[]`.
* `yyparse` bleibt im `noopt`-Modul `as_y.c`: *Annahme* (nicht geprueft), dass die Befehlsform des Originals von `yyparse` hier noch nicht entscheidbar ist, solange die Aktionen leer sind; Aufteilen in ein `-O`-Modul nur fuer `yyparse` ist ein spaeterer Schritt, falls der Befehlsvergleich es verlangt.

## 3. Gesamtbau `as` (`alles as --c2emu --libc alt --ist neu_c2`)

* Baut und linkt: `neu` 18294 B (176 s), `neu_c2` 18294 B (110 s); kein Haenger.
* Kopf: Original text 22092 / data 13706 / bss 17744; gebaut text 6710 / data 11568 / bss 15644.
* **Datenlage**: `kwtab`, `ctab1`, `ctab2` und die ganze `mnem`-Tabelle (301 Eintraege) stehen hintereinander und stimmen in allen Nichtzeigerworten mit dem Original ueberein (kwtab 37/37 Eintraege, ctab1 100/100, ctab2 36/36, mnem 1806/1806 Nichtzeigerworte).  Der Zeichenkettenpool steht in der Originalreihenfolge (kw, ct1, ct2, mnem) hinter den Skalaren; die Zeigerworte weichen je Tabelle um eine feste Differenz ab (-21816 `kwtab`, -21817 `ctab1`, -21818 `ctab2`, -21819 `mnem`).  Die Differenz waechst je Tabelle um 1: im Original liegt zwischen den Tabellenpools ein Fuellbyte mehr (Pool-Anfaenge 8322, 83EB, 84A9, 850D), im Gastbau nicht.  Ursache offen (*Annahme*: im Original sind die Tabellen getrennte Module oder Zeichenketten werden je Tabelle ausgerichtet); die Datenlage ist damit bis auf diese 3 Bytes und die Grundverschiebung (fehlende Daten davor) gleich.
* Befehlsvergleich (Rahmenfunktionen): Original 5891 Befehle im Eigencode, gebaut 675, passend 296 (282 ohne c2-Modell), 70 Unterschiedsbloecke; 706 von 35798 Bytes gleich am gleichen Offset (vorher in W7d: 659 / 300 / 73 / 676, bei anderem Stubumfang und anderer Datenlage -- nicht direkt vergleichbar).
* `pipeline.py vergleich` meldet Exit 1 (Unterschiede erwartet, da Funktionen noch Stubs sind).

## 4. Regression der Pipeline-Aenderung

Gast, sequentiell, nach der Aenderung (Befehle wie im Auftrag):

* `sh` (`bau sh --c2emu --variante v7fix`): `cmp` gegen `sh.orig` gleich.
* `ed` (`alles ed --c2emu --libc alt --ist neu_c2_s`): 11456 von 11456 Byte, bytegleich.
* `c0` (`--ist neu_c2`): 26810 von 26810 Byte, bytegleich.
* `cpp` (`--ist neu_c2`): unveraendert, 3268 von 3323 Befehlen gleich, 13 Bloecke (wie `wk_w2.md`).
* `c1` (`--ist neu_c2`): unveraendert, 7211 gegen 7970 Befehle, 7057 gleich, 90 Bloecke (wie `wk_w6.md`).

## 5. Werkzeug-Aenderungen

`tools/userspace/pipeline.py` (`noopt`-Marke, zweite Runde), `tools/userspace/uspace.py` (`Module`, Flags je Modul), `tools/userspace/as_tabellen.py`, `userspace/as/{link.txt,as.h,as_tab.c}`.  Entfernt: `as_ysplit.py`, `as_y{1,2,3}.c`, `as_tab{1,2}.c`, `as_tabd{1,2,3}.h`.
