# Herkunft von `kernel/c/dev0.c` (AP H5)

Stand 2026-10-31.  Vergleich gegen UNIX V7 `usr/sys/dev/*.c`, System III PDP-11 `uts/pdp11/io/*.c` und WEGA `src/uts/dev/*.c`.  Alle Zahlen **gemessen** (Ebene abs), sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial** (Nachtrag 2026-11-01, `mailbox_treiber.md` Abschnitt 4.4: Gerippe eines Magnetbandtreibers `tm.c` (V7/Hippe) mit BSD-`tmioctl` (2.9BSD-nah), Einstufung *wahrscheinlich*; die Mailbox-Ankopplung an den U880-Floppycontroller ist MUTOS-eigen).  Frueher hier "none" (nur Tokenmass, 4-13 %).  Dateiaehnlichkeit: V7 16 % (`dsort.c`), System III 16 % (`ht.c`), WEGA 18 % (`mt.c`), 10 % (`fd.c`).
  Der Kopf von `dev0.c` nannte bisher "WEGA-fd-Muster": **nicht belegt** (WEGA `fd.c` 10 %).
* Keine Funktion erreicht 50 % gegen eine gleichnamige Quelle.  `fdsub` (62 % gegen `tm.c:tcommand`, 55 % gegen SysIII `ht.c:hcommand`) und `fdioctl` (51 % gegen `mpxchan`) sind Treffer auf kurzen Allerweltsmustern.
  Strukturell erinnert `fdstrategy`/`fdstart`/`fdintr` an das V7-Tripel `xxstrategy/xxstart/xxintr` (Warteschlange `av_forw`, `iodone`), aber der Text ist verschieden.
* Das Modul ist im Original **ohne Optimierer** uebersetzt (alle Spruenge `JP`); der Rundlauf (`rundlauf.sh`, nur `cc -O`) deckt es nicht ab, `dev0` steht deshalb nicht in `rundlauf_soll.txt`.
  Die Absicherung ist der Gesamtbau (BYTEGLEICH).  An `dev0.c` sind in diesem AP nur Kommentare geaendert (Uebersetzung ins Englische, Kopf).
* Verwandte fuer H6 (*nicht belegt*): WEGA `dev/fd.c` (P8000), die U880-Seite `mutos_io` (Befehlscodes 25H/27H/51H/61H sind Controller-Befehle).

| Funktion | Kernel | bestes V7-Gegenstueck | Klasse |
|---|---|---|---|
| fdopen, fdclose, fdstrategy, fdstart, fdintr, fdadj, fdread, fdwrite, fdphys | 7E16..8554 | unter 25 % | eigen |
| fdsub | 7F00 | 62 % (`tcommand`, Muster) | eigen |
| fdioctl | 85B0 | 51 % (`mpxchan`, Muster) | eigen |

## Nachtrag 2026-11-04 (Plan 43 Gruppe D): dev0 11 von 11 bytegleich

Rundlauf ohne `-O` (`OHNE_O=1`, Ergaenzung E1 in `tools/herkunft/rundlauf.sh`, Sollwerte `daten/rundlauf_soll_dev0.txt`).  Vorher 5 von 11; getroffen haben:

* **`ld r2,X ; cp r2,#c` fuer jeden Ganzzahlvergleich mit Konstante** (Register, Speicher, Feld): der Original-`c1` (ohne Optimierer) laedt den Operanden zuerst nach r2, der Gast-`c1` vergleicht direkt.  Gemessen an 37 Quellformen, nur das Kommaglied `((x), (x))` gibt die Originalform (andere: Klammern, Casts, `+0`, `|0`, `!!x`, Typen `unsigned`/`char`, `x - c == 0`); es steht als Makro `R2(x)` in `dev0.c`, an 21 Stellen.  Das Makro wiederholt das Argument: nie mit Nebenwirkung verwenden (`R2(++x)` fuehrte das `++` zweimal aus; dort steht `(++fdtab.b_resid, fdtab.b_resid) < 7`).
* `fdioctl`: `while (--n >= 0)` ohne `R2` (der Kernel testet nach `dec` direkt mit `test`).
* `fdstart`: `if ((lb = fp->fu_blk) == bp->b_blkno)` (Zuweisungswert im Vergleich), der zweite Vergleich einfach `lb < bp->b_blkno`.
* `fdintr`: `mp->mb_cnt = fp->fu_xc = 0;` (Kettenzuweisung, ein `XOR R2,R2`, zuerst `fu_xc`), `break;` am Ende von `default:` des aeusseren `switch`, `(++fdtab.b_resid, fdtab.b_resid) < 7`.

Die Formen mit `R2` sind **Quellformen, die dieselben Bytes erzeugen**, kein Beleg fuer den Originaltext; die Stellen sind im Quelltext kenntlich.
