# Ergaenzung E6: Disketten v7erg1 / v7erg2 unter /v7 (Plan 45)

*Ergaenzungen, V7-Quellen, keine Originalreferenz.*  Spezifikation: `doc/plan/45_v7_ergaenzungen.md` Abschnitt 8.  Alles *gemessen* am 2026-11-17 (Worktree `us-erg-e6`),
soweit nicht als *Annahme* markiert.  Ergebnis: **beide Disketten gebaut, alle 39 Programmtests unter `/v7` gruen (B), Abnahme im Gast gleich.**

## Aufteilung (gemessen)

Alle 39 Ergaenzungen neu gebaut (`erg.py alles`, Gast `cc`), Summe der gestrippten Binaries 373 KB.  Format wie `cmd`: `mutos8k_26x128_fm` / `_mfm`, 494 Bloecke, 48 Inodes.
Freier Platz laut `k1520disktool ls` nach dem Bau (FM und MFM gleich); 1 KB = 2 Bloecke zu 512 B.

| Diskette | Inhalt | Nutzdaten | frei |
|----------|--------|-----------|------|
| `v7erg1` (Alltag) | `bin/`: basename tee sleep touch yes tty mesg sum rev uniq comm split tail cal look nice time test grep fgrep sort find diff tr join du file expr (27); `lib/diffh` | 176122 B | 52 KB (ca. 104 Bloecke) |
| `v7erg2` (Entwicklung) | `bin/`: yacc lex m4 sed dc bc egrep vmake ranlib tsort (10); `lib/`: yaccpar ncform libl.a lib.b | 206659 B | 31 KB (ca. 62 Bloecke) |

Die Aufteilung des Plans passt ohne Verschieben (nichts weggelassen).  `diffh` liegt nur als `/v7/lib/diffh` (so ruft `diff -h` es, wie V7 `/usr/lib/diffh`), nicht zusaetzlich in `bin/`.
Binary-Groessen (B): basename 2154, bc 16526, cal 5452, comm 6050, dc 33174, diff 11168, diffh 7552, du 5768, egrep 11290, expr 10584, fgrep 6986, file 8468, find 11568, grep 7684,
join 7500, lex 36420, look 6254, m4 15490, mesg 4894, nice 6208, ranlib 7298, rev 5152, sed 16130, sleep 4678, sort 11848, split 5622, sum 5268, tail 1766, tee 1240, test 2874, time 6634,
touch 4652, tr 3162, tsort 8794, tty 4714, uniq 6034, vmake 22406, yacc 28554, yes 4188.  Lib-Dateien: lib.b 1609, libl.a 1804, ncform 3917, yaccpar 3247, diffh 7552.
Alle Dateien: Datum 1987-01-01, `bin/*` und `lib/diffh` 0755, sonst 0644, Besitzer 0/0; Verzeichnisse `bin`, `lib` 0755.

## Pfadaenderungen (je Stelle `/* Differs from V7: ... */`)

| Programm | V7 | hier | Ursache |
|----------|----|------|---------|
| yacc (`files`) | `PARSER "/usr/lib/yaccpar"` (E3a: `"yaccpar"`) | `"/v7/lib/yaccpar"` | Platte `usr` voll |
| lex (`once.h`) | `"/usr/lib/lex/ncform"` (E3d: `"ncform"`) | `"/v7/lib/ncform"` | wie yacc |
| bc (`bc.y`, `bc.c`) | `execl("/bin/dc")`, `"/usr/bin/dc"`, danach E3c-Rueckfall `execvp` | zuerst `/v7/bin/dc`, dann V7 `/bin/dc`, `/usr/bin/dc`; **`execvp`-Rueckfall entfernt** | Test haengt die Diskette unter `/v7` ein |
| bc `-l` | `"/usr/lib/lib.b"` | `"/v7/lib/lib.b"` | wie oben |
| diff `-h` | `execv("/usr/lib/diffh")` | `execv("/v7/lib/diffh")` | wie oben |

`bc.c` ist erzeugt: neben der Handaenderung gegengeprueft -- `erg_yacc.py bc` (jetzt ueber `/v7/lib/yaccpar`) erzeugt **bytegleich** dieselbe `bc.c`.  `lex`: der V7-Quelltext von `lex` nennt `libl` selbst nicht
(das Linken mit `-ll` macht der Aufrufer von `cc`), also gibt es dort keine Pfadstelle; das Linken geschieht ueber `/v7/lib/libl.a` (siehe unten).  Die V7-`cc` hat kein `-l` fuer `/v7/lib`;
*Annahme*: ein Anwender schreibt `cc x.c /v7/lib/libl.a` (so macht es der Test).  Die libl-Quelle `once.h`/`ncform` ist sonst unveraendert.  Binary `bc` jetzt 16526 B (vorher 17358 B mit `execvp`).

`lib.b`: **nicht in `original/unix-v7`** (dort fehlt `usr/lib/lib.b`); die Datei ist V7-Text und liegt in `original/hippe-v7/usr/lib/lib.b` (Sammlung, nicht Urheber -- siehe Projektregeln); Kopie unveraendert nach
`userspace/ergaenzung/bc/lib.b`.  `bc -l` mit ihr: `scale=10; e(1)` ergibt `2.7182818284` (= GNU bc, neuer Test "bc -l").  Nicht getestet: `s c a l j` ausser `e`.

## Rahmen (Aenderungen, fuer alle anderen Programme rueckwaertskompatibel)

* `tools/kernel/gast_as.py` `gast_befehle`: neue Parameter `mnt` (Einhaengepunkt von Laufwerk D, Vorgabe `/mnt`; die Marken `fertigN` und `cd` laufen dort) und `quelle_hfe` (vorhandenes Abbild statt neu erzeugtem).
  `mnt != /mnt`: der Einhaengepunkt wird auf der **Kopie** der Wurzel mit `k1520disktool mkdir` angelegt (die Wurzel hat nur `/mnt /tmp /usr`; ein zweites Einhaengen derselben Platte entfaellt, V7 `mount` lehnt dasselbe Geraet zweimal ab -- *Annahme*, nicht probiert).
  Schluessel von `quellen` duerfen `/` enthalten (`bin/NAME`, `lib/NAME`): dann wird der ganze Staging-Ordner mit **einem** `put` aufgespielt (`put` nimmt einen Ordner nur allein; sein Inhalt landet in `/`).
* `tools/userspace/erg.py`: Testplatte jetzt **`/v7`** statt `/mnt`: `bin/NAME` + Hilfswerkzeuge (`werkzeuge`) in `/v7/bin`, Lib-Dateien in `/v7/lib`, Skript und Eingaben (`e_*`) in `/v7`; `PATH=/v7/bin:/bin:/usr/bin`.
  Neuer Schluessel `"lib": [...]` in `erg.json` (Namen aus `erg.LIBDATEIEN`: yaccpar ncform lib.b diffh libl.a), gesetzt fuer yacc (yaccpar), lex (ncform, libl.a), bc (lib.b), diff (diffh).  Neu `libl_bauen()`: `libl.a` im Gast
  aus den V7-Quellen `lex/lib/{main,yywrap,yyless,reject}.c` (`cc -c -O`, `ar r`, `ranlib`; `ar` von der Diskette `cmd`, `ranlib` die Ergaenzung), Ergebnis `userspace/ergaenzung/lex/work/libl/libl.a` (1804 B).
  `allprint.c` nur mit `LEXDEBUG` (nicht im Archiv).  Der Gast-`ar` meldet `ar: creating libl.a` (V7-Verhalten).
* `tools/userspace/erg_yacc.py`, `vmake_gram.py` (erzeugen `*.c` mit dem Gast-yacc) arbeiten ebenfalls unter `/v7` (`yaccpar` aus `/v7/lib`).
* Testdateien: `ncform` aus `lex/test/eingabe/` nach `userspace/ergaenzung/lex/ncform`; die vier libl-Quellen und `yacc/test/eingabe/yaccpar` entfallen als Eingaben (kommen aus Archiv bzw. `lib/`).
  `lex/test/befehle.sh`: `cc -s -o scan lex.yy.c /v7/lib/libl.a` (statt vier Quellen).  Neue Faelle: `bc -l` (`bc/test/eingabe/mathlib`), `diff -h` (`diff/test/eingabe/g.txt`, gleiche Erwartung wie `diffh`).
* `tools/disks/bau_alle.py --v7erg` baut die vier Abbilder (nicht in der Standardliste: `test_bau_alle_kennt_genau_die_fertigen_disketten` bleibt unveraendert, weil die Ergaenzungen erst per `erg.py bau` entstehen).

## Testergebnisse (alle 39 unter `/v7`, `erg.py alles`, je Programm Bau + Test)

Ergebnis **B (Bau gruen, Test gleich)** fuer: basename tee sleep touch yes tty mesg sum rev uniq comm split tail cal look nice time test grep fgrep sort find diff diffh tr join du file expr
yacc lex m4 sed dc bc egrep vmake ranlib tsort -- **39 von 39, kein T, kein N.**  Bauzeit im Gast je Programm 30 s bis 6 min (yacc 317 s, lex 360 s, vmake 266 s, dc 297 s), Test 22 bis 96 s.
Laeufe sequentiell: basename, yacc, bc, lex, diff+diffh, dc+ranlib einzeln, die uebrigen 31 in einem Lauf (`erg.py alles ...`).

## Abnahme der Disketten (Gast, gemessen)

`python3 -I tools/userspace/erg_abnahme.py [1|2] [--hfe IMAGE] [--neu]` haengt `disks/gebaut/a5120_mutos8000_v7erg<N>_mfm.hfe` (Kopie) als Laufwerk D unter `/v7` ein und fuehrt
`userspace/ergaenzung_abnahme/v7erg<N>/befehle.sh` aus (cwd `/tmp`, `PATH=/v7/bin:/bin:/usr/bin`).  Inhalt: `ls /v7/bin /v7/lib` (Namen), je Programm ein kurzer Aufruf,
fuer `v7erg2` die Kette `yacc calc.y; cc y.tab.c; ./calc` (yaccpar aus `/v7/lib`) und `lex w.l; cc lex.yy.c /v7/lib/libl.a; ./scan` (ncform aus `/v7/lib`).  Erwartung `erwartet.txt`; Werte gegen den Host
geprueft, wo es dort ein Werkzeug gibt (sum, rev, uniq, diff, bc: GNU), sonst von Hand.  `ls -l` liegt in `work/ls_l.txt` (nicht verglichen: Groessen aendern sich bei jedem Neubau).
Ergebnis: **v7erg1 gleich (73 s), v7erg2 gleich (124 s)**; `ls -l` zeigt alle Dateien mit Datum `Jan 1 1987`.  Pytest-Wacht: `tests/test_erg.py::test_v7erg_abnahme` (Marke `gast`; ueberspringt ohne Emulator/Abbilder).

Befunde der Abnahme:
* `diff -h` ruft `/v7/lib/diffh` (gemessen: gleiche Ausgabe wie `diff` bei einer Aenderung in der Mitte).  `diffh` bildet am Dateiende grobe Bloecke (`2,$c2,$`), siehe `erg_e2b.md` -- V7-Verhalten.
* V7-`sh` kennt keine `#`-Kommentare (`syntax error ... '(' unexpected`), die Abnahmeskripte haben deshalb keine Kopfzeile.
* `ranlib` kann auf `v7erg2` allein nicht arbeiten (`ar` liegt auf der Diskette `cmd`, nicht in `/v7/bin`): in der Abnahme nur der Aufruf mit Fehlermeldung (`not archive`); die Funktion deckt der Programmtest mit `ar` von `cmd` ab.
  *Annahme*: im Betrieb sind `cmd` und `v7erg*` zusammen eingehaengt (`PATH` mit `/mnt` und `/v7/bin`), sonst fehlt `ar`.
* `vmake` braucht den aufgerufenen Befehl im `PATH`: auf `v7erg2` ist `sort` nicht vorhanden (`v7erg1`), `Cannot load sort` -- Abnahme nimmt `cat`.

## Bau und Einhaengen

```
export K1520EMU=/home/olliy/projects/a5120emu
for n in $(ls userspace/ergaenzung); do python3 -I tools/userspace/erg.py bau $n; done   # oder erg.py alles ...
python3 -I tools/disks/bau_alle.py --v7erg [--ueberschreiben]     # disks/gebaut/a5120_mutos8000_v7erg{1,2}_{fm,mfm}.hfe
python3 -I tools/userspace/erg_abnahme.py                          # Abnahme beider Disketten im Gast
```
`bau_v7erg.py` liest `tools/disks/bauangaben_v7erg{1,2}.yaml` (Schluessel `bin:` und `lib:`), nimmt nur `userspace/ergaenzung/NAME/work/bau/NAME.bin` und die Lib-Dateien aus `erg.LIBDATEIEN`
(`libl.a` wird bei Bedarf im Gast gebaut), schreibt `dateien/` samt `.fileinfo` (Datum 1987) und ruft `bau_aus_archiv.bauen` (`check --full`: ohne Befund; Zylinder 0 mit den Etiketten von `cmd`).
Im Gast (je eine Diskette zur Zeit; Laufwerk D, FM-Abbild fuer MF3200, MFM fuer K5601):

```
/etc/mount /dev/rk3 /v7        # das Verzeichnis /v7 muss auf der Wurzel existieren (mkdir /v7; die Original-Wurzel hat es nicht)
PATH=$PATH:/v7/bin
```
Das Verzeichnis `/v7` auf der Original-Wurzel *fehlt*: einmal `mkdir /v7` (cmd-Befehl) oder `k1520disktool mkdir WURZEL.hfe v7` auf einer Kopie.

## Offen

* `look` braucht `/usr/dict/words` (196513 B in V7): nicht auf den Disketten (v7erg1 hat 52 KB frei); `look` nur mit Dateiargument -- unveraendert offen (Plan 45 Abschnitt 8).
* `mkdir /v7` auf der ausgelieferten Wurzel nicht bereitgestellt (Wurzelarchiv nicht angefasst).
* `dc`, `bc`, `lex` weiter ohne `-O` (E3c/E3d); `libl.a` ohne `allprint.o`.
* Ob Programme beider Disketten gleichzeitig noetig sind (z. B. `make` mit `sort`/`yacc`), ist *Annahme*: nur eine Diskette gleichzeitig (Plan), `PATH`-Reihenfolge ist Sache des Anwenders.
