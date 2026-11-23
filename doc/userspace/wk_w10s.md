# W10s: Gast-Bauweg mit `xcc` + `c2x` in der Pipeline

Plan 52 W10, Schritt 4. *Gemessen* (Gastlaeufe 2026-11-22), ausser wo *Annahme* steht.

## 1. Aenderung
* `pipeline.py bau NAME --xcc --libc alt` (Variantenname `neu_x`, Vergleich mit `vergleich NAME --ist neu_x`, derselbe Vergleich wie sonst).
  Kein `--c2emu`, kein Host-Umschreiben des `.s`: der Gast uebersetzt jedes Modul mit `xcc -O -s -X<Buchstaben>`, `xcc` ruft `/usr/lib/c2x -x<Buchstaben>`.
* Buchstaben: `xcc_einstellung()` ruft `c2gegen.c2x_flags(name, xcc.REGELN, ("R3",))` -- dieselbe Funktion wie `c2gegen lauf --auto` (Gruppen von c2x
  minus `C2_AUS` des Programms), nur ein Buchstabensatz je Programm. Module mit `noopt` in `link.txt` bleiben ohne `-O` und damit ohne `-X`.
* Installation (`uspace.xcc_usr`, auf der Kopie der `usr`-Platte der Sitzung, die Originalplatten bleiben): `bin/xcc` (`userspace/cc/work/bau/xcc_c2_s.bin`) und `lib/c2x`
  (`userspace/c2/work/bau/c2x_c2.bin`), Modus 0755, mtime 1987. Platz (nur 4 KB frei): `lib/libc.a` (72 KB) wird durch ein Archiv mit ihrem kleinsten Glied ersetzt;
  gebunden wird gegen das `libc_alt`-Archiv des Programms (`--libc alt` ist Pflicht, ohne `libc_alt` geht `--xcc` nicht).
* Stufenbau (Quellen ab 20000 B) ruft statt `/usr/lib/c2` dann `/usr/lib/c2x -x...` (`stufen_befehl(..., c2=)`), *nicht gemessen*.
* `pipeline.py bau` meldet vorab die Regeln des Hostmodells, fuer die c2x keinen Buchstaben hat (`xcc_luecken`: `c2_emu_s`-Zaehler auf `work/bau/neu.s`).

## 2. Ergebnis je Programm (Bau ca. 30 s je Programm)
| Programm | Flags | Ergebnis | Regeln ohne c2x-Buchstaben |
|----------|-------|----------|----------------------------|
| echo | `-Xpcmzkws73tr` | **byteidentisch** (2152 B) | keine |
| rm | `-Xmzkws73tr` | **byteidentisch** (5766 B) | keine |
| wc | `-Xpcmzkws73tr` | erste Abweichung Offset 0x81, 2 Bloecke (198 von 200 Befehlen gleich) | R5 (2 Stellen: `ld r2,r3`/`ld r3,r2`-Form, `LD %FFD6(R14),R2` statt `R3`) |
| cat | `-Xpcmzkws73tr` | erste Abweichung 0x81, 2 Bloecke (179 von 181) | R5 (2 Stellen, `TEST R2` statt `TEST R3`) |
| df | `-Xmzkws73tr` | erste Abweichung 0x21, 4 Bloecke (177 von 182), Text 0x252 statt 0x256 | R42 (1), R64 (1) |

Die Luecken sagen die Abweichungen voraus: wc, cat, df koennen mit `xcc` erst G sein, wenn c2x R5 (Kopiepropagation `ld rA,rB ; test rB`) bzw. R42/R64 kennt.
Offen: pruefen, ob die vier Blocke von df allein R42/R64 sind (nicht einzeln nachgerechnet).

## 3. Verbrauch
Bau 7 (echo 3: die ersten zwei scheiterten an der Installation -- `crt0.o` als Archivglied: `Bad format`, dann Sidecar-Datei `.fileinfo` statt `libc.a` gelesen --; wc, df, rm, cat je 1), kein weiterer Gastlauf.
Nicht gemacht: Mehrdatei-Programme mit `xcc`, `--xcc` mit Programmen ohne `libc_alt`, Stufenbau.
