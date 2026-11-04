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
