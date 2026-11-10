# E0: Rahmen fuer die V7-Ergaenzungen (Plan 45)

Ergaenzung, V7-Quelle, **keine Originalreferenz** -- die Programme sind nie "rekonstruiert".  Vertrag: `doc/plan/45_v7_ergaenzungen.md` Abschnitt 7.
Umsetzung: `tools/userspace/erg.py` (nutzt `uspace.gast_bauen` und `gast_as.gast_befehle`; `pipeline.py`/`uspace.py` unveraendert).

## Aufrufe

```
python3 -I tools/userspace/erg.py bau   NAME [--parallel N]   # Gast: cc -O -s -> userspace/ergaenzung/NAME/work/bau/NAME.bin, NAME.err
python3 -I tools/userspace/erg.py test  NAME                  # baut bei Bedarf, fuehrt test/befehle.sh im Gast aus, vergleicht
python3 -I tools/userspace/erg.py alles NAME...               # bau + test, Ergebniszeile je Programm: B | T | N
python3 -I -m pytest tests/test_erg.py                        # alle userspace/ergaenzung/*/test (Marke gast)
```

Exit: 0 gleich/gebaut, 1 Abweichung oder kein Binary, 77 Emulator fehlt (`K1520EMU=/home/olliy/projects/a5120emu`).
`alles` meldet B (Bau und Test gruen), T (gebaut, Test weicht ab), N (Bau fehlgeschlagen); X (ausgelassen) traegt der Agent in seine Doku ein.

## Ordner je Programm

`userspace/ergaenzung/NAME/`: `NAME.c` (oder mehrere `*.c`/`*.h`, dann alphabetisch einzeln `-c` und gelinkt), `erg.json`
(`header` relativ zu `original/unix-v7/usr/include`, flach neben die Quelle auf `/mnt`; `flags`; `quelle`), `test/befehle.sh`,
`test/erwartet.txt`, `test/herkunft.txt`, optional `test/eingabe/*`.  `work/` ist git-ignoriert.  Programmname hoechstens 9 Zeichen
(`NAME.err2` muss in 14 Gastzeichen passen).

## Ablauf des Tests (gemessen)

Eine Emulator-Sitzung (Platten als Kopien): A = leeres `/tmp`, B = `usr`, C = `root`, D = Quelldiskette = `/mnt` mit dem Binary
(Ausfuehrbit 0755), `befehle.sh` und den Eingaben.  Befehle im Gast: `cat /mnt/e_X >/tmp/X` je Eingabedatei, dann
`cd /tmp; PATH=/mnt:/bin:/usr/bin sh /mnt/befehle.sh >/tmp/aus.txt 2>/tmp/aus.err`.  Verglichen wird nur die Standardausgabe
(CR werden entfernt); Standardfehlerausgabe liegt in `work/test/NAME.stderr`, das Ist in `work/test/NAME.ist`.

Grenzen fuer Testskripte (*gemessen am Aufbau*, nicht jedes Werkzeug einzeln geprueft): im Gast sind nur die Platten `root` und `usr`
eingehaengt, also keine `cmd`-Befehle (`echo`, `cp`, `wc`, `rm`, `mkdir` ...).  Verfuegbar: `sh` (mit Pipes, Umlenkung), `cat`, `ls`, `date`, `stty`,
`sync`, `cc`/`as`/`ld`, das Testprogramm.  Eingaben also als Dateien unter `test/eingabe/` liefern, nicht per `echo`.
Dateinamen auf `/mnt` werden bei 14 Zeichen abgeschnitten (Eingabe-Praefix `e_`, daher Eingabenamen mit hoechstens 12 Zeichen).
*Annahme/Luecke:* die Gastzeit wird nicht auf 1987 gestellt (nur fuer `make`-Tests noetig; die Quellplatte traegt mtime 1987).

## Nachweis an zwei Programmen (gemessen)

| Programm | V7-Quelle | Bau | Test | Ergebnis |
|----------|-----------|-----|------|----------|
| basename | `cmd/basename.c`, unveraendert | 2154 B, 37 s | gleich (9 Faelle) | B |
| tee | `cmd/tee.c`, unveraendert, Zusatzheader `errno.h` | 1240 B, 39 s | gleich (3 Laeufe, 40 Zeilen = 1,2 KB, ueber die 512-Byte-Puffer) | B |

* `tee` braucht `errno.h` (fehlt in `/usr/include`, Fehler ohne: `Can't find include file errno.h`); aus V7 flach daneben gelegt (`erg.json`).
* Erwartung: GNU coreutils 9.7 auf dem Host (`sh befehle.sh > erwartet.txt`), Herkunft in `test/herkunft.txt`.  Nur Faelle, in denen V7 und GNU gleich
  arbeiten (V7-`basename` ohne Argument gibt eine Leerzeile, GNU einen Fehler -- nicht getestet; ebenso Suffix = ganzer Name).
* Der Bau ist hier ohne Quelltextaenderung gelungen, also keine `Differs from V7`-Kommentare.
