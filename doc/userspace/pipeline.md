# Pipeline fuer Userspace-Programme (`tools/userspace/`)

Wiederverwendbar fuer jedes Programm der Disketten (init, sh, cat, date, ls, stty, sync, login, getty, mount, umount ...).
Python (stdlib), Aufruf mit `python3 -I`.  Bibliothek `tools/userspace/uspace.py`, Kommandozeile `tools/userspace/pipeline.py`.
Exit 77 = Emulator oder Diskette fehlt (wie bei den Kernel-Werkzeugen).  Ein Programm wird in der Tabelle `PROGRAMME`
von `pipeline.py` eingetragen: Diskette, Pfad im Gast, Quelle (`userspace/NAME/NAME.c`), Zusatz-Header.

Arbeitsordner: `userspace/NAME/work/` (git-ignoriert).  Mit `--ablegen` kopiert `karte` die kleinen Ergebnisse
(`k.txt` Karte, `NAME.lst` Listing, `NAME.namen` libc-Treffer, `NAME.strings`) neben die Quellen und sie werden committet.

## Schritte und Befehlszeilen

| Schritt | Befehl | Ergebnis |
|---------|--------|----------|
| (a) holen | `python3 -I tools/userspace/pipeline.py holen NAME [--platte root --pfad etc/init]` | `work/NAME.orig` (ganze Datei), `NAME.raw` (ohne 16-Byte-Kopf, Text + Daten, Textbasis 0) |
| (b)+(c) Karte, Listing, Namen | `... karte NAME [--ablegen]` | `NAME.k` (Karte), `NAME.lst`, `NAME.strings`, `NAME.namen` |
| (d) bauen | `... bau NAME [--quelle V=DATEI]... [--flags "-O -s"] [--asm] [--parallel 4]` | `work/bau/V.bin`, `V.err`, optional `V.s` (cc -S) |
| Vergleich | `... vergleich NAME [--ist V] [--voll]` | `work/bau/V.bericht`; Exit 0 nur bei Bytegleichheit |
| alles | `... alles NAME [--quelle ...]` | holen, karte, bau, vergleich |
| Selbsttest | `... --check [NAME]` | holen + Karte + Namen auf dem Host (Sekunden); 77 ohne Emulator |

Guest-Laeufe dauern Minuten bis Stunden Wanduhr: **im Hintergrund starten** (`run_in_background`), nie mit `sleep` warten.

### (a) Holen
`k1520disktool get <fertige Diskette> <pfad>` ueber `tools/emu.py` (der Emulator wird nie kopiert).  Der a.out-Kopf hat
8 Worte `magic text data bss syms entry unused flag` (`objformat.md`); `raw` = `text+data` Bytes ab Dateioffset 16.
Bei init: `e807 1202 0160 0924 0 0 0 0001` -- Text 4610, Daten 352, BSS 2340, gestrippt (`flag` 1, `syms` 0).
Gemessen: Textbasis ist 0, die Daten folgen **ohne Luecke** direkt hinter dem Text (Adresse = Textlaenge), BSS dahinter.

### (b) Karte
`karte_bauen`: `seg 0 0 <len>` + `code 0`, dann `z8kdis --vorschlaege` und die gelieferten `code`-Einstiege werden
uebernommen, bis nichts Neues kommt (init: 2 Runden, 275 Einstiege, 0 ungueltig, 0 Ueberlappung).  Nichtsegmentierter
Modus (Z8002) -- die Programme sind keine U8001-Segmentprogramme.  `NAME.k` ist die vollstaendige Karte;
Handnamen kommen aus `userspace/NAME/namen.txt` (`ADRESSE name`).  Funktionsgrenzen = Ziele von `CALL`/`CALR` plus 0
(Naeherung: Funktionen, die nur ueber Zeiger erreicht werden, fehlen -- ihre Einstiege stehen aber als `code` in der Karte).
Die Texte im Datenteil (NUL-beendete druckbare Ketten, ab Textende) stehen in `NAME.strings`.

### (c) libc-Namen
`lib/libc.a` und `lib/crt0.o` kommen von der `usr`-Diskette.  Je Archivglied wird der **maskierte Text** (Relokationsworte
sind Wildcards, `finde_signaturen.py`) wortausgerichtet im Abbild gesucht; ab 14 Byte Text zaehlt ein Treffer als belegt
(darunter "weak", z. B. `fakcu`).  Als Marke in der Karte dient das **exportierte Symbol** des Glieds mit Versatz
(`dup.o` liefert `_dup` bei +6 und `_dup2` bei 0, `cuexit.o` liefert `_exit`), nicht der Gliedname.  Gleiche Signaturen
(`getpwuid`/`getgrgid`, `stat`/`fstat` ...) werden als `a|b` gefuehrt und nicht in die Karte uebernommen.
Treffer = der Text stimmt an der Stelle mit dem Glied der **mitgelieferten** `libc.a` ueberein (siehe Stolperstein 1).

### (d) Gast-Bau
Wiederverwendet `gast_as.gast_befehle` (AP K5): je Variante eine eigene Emulator-Sitzung (parallel, `--parallel`),
Platten als **Kopien** (`--rw` nur darauf), Laufwerk A = leere Diskette als `/tmp`, B = `usr` (`/usr`), C = `root`,
D = Quelldiskette (`/mnt`) mit `V.c` und den Zusatz-Headern.  Befehl im Gast: `cd /tmp; cc -O -s -I/mnt -o V /mnt/V.c`
(Ausgabe nach `/tmp`, Meldungen nach `V.err`); mit `--asm` zusaetzlich `cc -O -S` -> `V.s`.  Am Ende `sync`.
Fehlende V7-Header (`utmp.h`, `setjmp.h`) legt `PROGRAMME` neben die Quelle (`-I/mnt` hat Vorrang vor `/usr/include`,
deshalb nie einen Header eintragen, den `/usr/include` hat).  Zeitstempel (1987) spielen nur fuer `make` eine Rolle.

### Vergleich
Gemessen wird dreifach: Kopf (text/data/bss), Bytes gleich an gleichem Offset, und ein Befehlsvergleich: beide Abbilder werden mit
derselben Karte-Prozedur disassembliert, Adressen **abstrahiert** (Sprung-/Aufrufziele `L`, Datenadressen `D+off`, BSS `B+off`,
bekannte Funktionsanfaenge `F`, Konstanten bleiben exakt) und mit `difflib` verglichen; Unterschiede stehen je Funktion des
Originals.  So bleibt der Bericht lesbar, auch wenn ein Groessenunterschied alle folgenden Adressen verschiebt.

## Erweiterungen durch `sh` (Mehrdatei-Programme)
* Quelle in `PROGRAMME` darf ein **Verzeichnis** sein (alle `*.c` alphabetisch einzeln `cc -O -c`, dann `cc -s -o NAME *.o`; `*.h` des Verzeichnisses auf `/mnt`).
* `bau --variante NAME` (Standard `neu`): sprechender Name je Quellfassung; **hoechstens 9 Zeichen** (Gastnamen 14 Zeichen, `NAME.err2`), mit `--c2emu` entsteht `NAME_c2`.
* `--asm` bei Mehrdatei-Programmen: `.s` je Modul in Sitzungen zu <= 40 KB, ausgegeben als `work/bau/NAME_s/*.s`; `--c2emu` schreibt jedes Modul um und baut `NAME_c2`.
* `C2_AUS` (pipeline.py): je Programm abgeschaltete c2-Regeln (`sh`: R1-R10, R30, R31).  `karte_extra.txt`: `ohne ADDR` / `code ADDR` (siehe `sh.md`).
* `vergleich --karte-extra-beide`: `karte_extra.txt` auch fuer das gebaute Abbild.

## Erweiterungen seit Stufe 3 (Stand 2026-11-18)

Gemessen eingefuehrt in den genannten Arbeitspaketen; Einzelheiten dort.

* **`--libc alt`** -- bindet gegen das aus den Originalabbildern zurueckgewonnene Archiv `userspace/libc_alt` statt gegen die mitgelieferte `libc.a`
  (Stolperstein 1).  Je Programm `userspace/libc_alt/NAME.members`, Hand-Nachtraege in `NAME.members.zusatz` (z. B. `doprnt code=...`, Exportadressen,
  `common`-Adressen).  Ohne libc-Glieder (`getty`, `sync`) bleibt `--libc disk`.  Werkzeug: `libc_alt.py bau NAME` (Rundlauf: 0 Glieder abweichend).
* **Varianten:** `--ist neu` (ohne c2-Modell), `neu_c2` (c2-Modell je Modul, Mehrdatei-Programme: `c0`, `c1`, `c2`, `cpp`), `neu_c2_s` (c2-Modell auf das ganze `.s`).
* **c2-Modell:** `uspace.c2_emu_s` mit allgemeinen Regeln, `C2_AUS` je Programm (pipeline.py), programmgebundene Regelsaetze (`mkfs ed tar cc c0` als Parameter,
  `c2_ld_s`, `c2_cpp_s`, `c2_convert_s` danach).  Regelbereiche: R1-R91 (Plan 44), R92 tar, R93-R100 cc/ld, R101-R112 cpp, R130-R133 c0; frei R170-R199 (c2), R200-R229 (libc), R230-R259 (c1).
  Was die Regeln gegenueber dem ausgelieferten c2 bedeuten: `README.md`, Abschnitt c2-Gegenprobe.
* **`karte_extra.txt`:** `ohne ADDR` (Vorschlag verwerfen), `code ADDR` (zusaetzlicher Einstieg, z. B. Sprungtabellenziel, toter Code), `db/dw/dwc/txt` (Tabellen und Zeichenketten,
  `dwc` = Sprungtabelle mit Codezeigern).  `--check NAME` liest sie mit (seit Stufe 5).
* **Mehrdatei-Programme:** ohne `link.txt` werden alle `*.c` alphabetisch gebunden; `userspace/NAME/link.txt` legt die Reihenfolge fest und darf `.s`-Module enthalten
  (c1: `atof.s`, `table_z8k.s`), die unveraendert in die c2-Runde gehen.  Eine Zeile `NAME.c noopt` uebersetzt das Modul ohne `-O` (und ohne c2-Modell in der zweiten Runde): der ausgelieferte c2 haengt bei Modulen mit mehr als
  ~10 KB initialisierter Daten (`as`, `wk_w7d.md`); reine Datenmodule brauchen `-O` nicht (W7e).  Eine `.c`, die von einer anderen `#include`d wird (cpp: `yylex.c`), zaehlt als Header.
* **Stufenbau** fuer Quellen ab 20000 B (`STUFEN_AB`): `cpp`, `c0`, `c1`, `c2`, `as`, `ld` einzeln (`/tmp`-Platz); seit W3 in drei kurzen Gastbefehlen statt einem 440-Zeichen-Befehl
  (im Gast-tty ging ein Zeichen verloren, die Kette lief dann still nicht).
* **yacc-Quellen:** `tools/userspace/erg_yacc.py [DIR/]NAME` erzeugt `NAME.c` aus `NAME.y` mit dem Gast-yacc (Plan 45; cpp `cpy.y` W2).  Die erzeugte `.c` wird eingecheckt.


## `--xcc`: Bau im Gast mit `xcc` + `c2x` (W10s, `wk_w10s.md`)
`python3 -I tools/userspace/pipeline.py bau NAME --xcc --libc alt` und `vergleich NAME --ist neu_x`.
Voraussetzung: `userspace/cc/work/bau/xcc_c2_s.bin` (`xcc.py var` + `bau cc --c2emu`, `wk_w10r.md`) und `userspace/c2/work/bau/c2x_c2.bin` (`bau c2 --c2emu` mit `c2x`).
Der Gast uebersetzt mit `xcc -O -X<Buchstaben des Programms>` (c2gegen.c2x_flags, Gruppen von c2x minus `C2_AUS`), kein Host-Patch des `.s`; `noopt`-Module ohne `-O`.
`xcc` und `c2x` liegen auf der `usr`-Kopie der Sitzung (dort ersetzt ein Ein-Glied-Archiv `libc.a`). Bei Programmen, deren Hostmodell Regeln ohne c2x-Buchstaben braucht, meldet `bau` diese vorab.
