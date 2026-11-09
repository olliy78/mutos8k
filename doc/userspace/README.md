# Userspace von MUTOS 8000 (Plan 42 H7, Plan 43)

Ziel: die Programme der Disketten (`root`: init, sh, cat, date, ls, stty, sync, login, getty, mount, umount ...; `cmd`, `bin`, `usr`)
so zurueckbauen, dass der MUTOS-`cc -O` im Emulator-Gast aus unserer Quelle das Original wieder erzeugt (V7-Text, wo er genuegt).

| Dokument | Inhalt |
|----------|--------|
| `pipeline.md` | Werkzeug `tools/userspace/`: holen, Karte+Listing, libc-Namen, Gast-Bau, Vergleich; Befehlszeilen |
| `init.md` | erstes Programm: `/etc/init` (V7 + 5 Abweichungen), Messungen, c2-Modell R1-R3, libc-Befund |
| `system_befehle.md` | `/bin/login`, `/etc/getty` (ganzdatei-bytegleich, Vorlage Hippe-Sammlung `getty.c.old`), `/etc/mount`, `/etc/umount` |
| `kleine_befehle.md` | `/bin/sync` (ganzdatei-bytegleich), `cat`, `date`, `ls` (Eigencode befehlsgleich); c2-Regeln R4-R9 |
| `stty.md` | `/bin/stty` (kein V7: erweitertes `stty`, gleiche Zeichenketten wie Hippe-Sammlung; Eigencode wortgleich bis auf Adressen); c2-Regel R10 |
| `sh.md` | `/bin/sh` (V7-Bourne-Shell, 20 Module, Mehrdatei-Bau; **ganzdatei-bytegleich**, 18296 B; anderer c2-Stand als `init`, c2-Regeln R11-R14/R16) |
| `libc_alt.md` | Rueckbau-libc der Originalprogramme (ohne Gleitkomma), Glied x Programm, c2-Regeln R20-R26/R31 |
| `../werkzeugkette/` | `cc`/`as`/`ld`-Befunde, a.out-Format, `libc_signaturen.txt` |
| `../plan/42_unix_herkunft.md`, `../plan/43_c_nachbau.md` | Plaene (H7 = Userspace) |

## Stand und Aussagekraft der Bytegleichheit (gemessen 2026-11-09, Stand `userspace-herkunft`)

Alle elf Programme der Wurzeldiskette werden **ganzdatei bytegleich** gebaut: `sync` 116, `getty` 1150, `cat` 4072, `umount` 4096,
`mount` 4272, `init` 4962, `date` 5758, `stty` 5814, `ls` 8244, `login` 9904, `sh` 18296 Byte
(`pipeline.py alles NAME --c2emu [--libc alt] --ist neu_c2_s`; `sh`: `bau sh --c2emu --variante v7fix`, dann `cmp`).
Was das belegt und was nicht:

**1. Der c2 wird nicht ersetzt und nicht gepatcht, sondern nachgebildet.**  Der Bau laeuft so:
`cc -O -S` im Gast (c0/c1/**ausgelieferter** c2 der Diskette, unveraendert) -> `.s` -> auf dem Host schreibt
`uspace.c2_emu_s` (Programme) bzw. `libc_alt.libc_regeln` (libc-Glieder) den Assemblertext mit Musterregeln um ->
Original-`as`/`ld` im Gast -> Bytevergleich.  Die Regeln (R1-R16, R20-R26, R30, R31) sind aus den Unterschieden
"Bau ohne Umschreibung gegen Original" abgeleitet, die sich durch keine Quelltextvariante erklaeren liessen.  Sie beschreiben,
**worin sich die Ausgabe des (verlorenen) alten c2 von der des ausgelieferten unterscheidet** -- sie sind ein Modell,
**kein Lauf des alten c2**.  Bewiesen ist damit: *C-Quelle + ausgelieferter Compiler + diese Regeln = Originalbytes*;
nicht bewiesen ist, dass der alte c2 genau diese Regeln hatte.

**2. Die Regeln sind schwach belegt und programmabhaengig.**  Viele greifen an 1 bis 4 Stellen (R12, R14, R16, R20-R26, R31
an genau einer).  `sh` wurde mit einem anderen c2-Stand uebersetzt als die uebrigen Programme: dort sind R1-R10/R30/R31 aus
(`pipeline.py: C2_AUS`), nur R11-R14/R16 an (`C2_NUR_SH`); die sh-Regeln auf `cat`/`login` angewandt zerstoeren deren
Bytegleichheit (gemessen, Waechter `test_sh_rules_are_off_for_other_programs`).  Jede neue Regel braucht eine Stellenzahl;
eine Regel mit einer Stelle ist kaum mehr als ein beschriebener Unterschied.

**3. Ohne Regeln** ist das Ergebnis "befehlsgleich bis auf die Regelstellen": `init` 29 Stellen (R1 20, R2 8, R3 1),
`sh` laengengleich mit 5249 von 5281 Befehlszeilen gleich.  Die Quellform (V7-Text bzw. belegte Abweichung) haengt nicht
an den Regeln: sie bestimmen nur Codeformen, die keine Quelle beeinflussen kann.

**4. R16 ist ein Assembler-Behelf**, kein c2-Verhalten: das Original enthaelt einen kurzen Sprung mit genau -256 Byte, den der
Gast-`as` ablehnt (`ILLEGAL VALUE`); die Regel schreibt das Befehlswort als `wval`.  Dasselbe macht `libc_alt` fuer
`! jr L !` + `WV %E881` (qsort in `ls`).

**5. Der libc-Teil belegt keine Herkunft.**  Die meisten libc-Glieder (`userspace/libc_alt/*/*.s`) sind **aus dem
Original-Abbild gewonnen**; ihre Gleichheit gilt per Konstruktion.  Unabhaengig (aus C gebaut) sind nur `printf`, `strout`,
`isatty`, `stty`, `data`, `flsbuf`, `malloc` (diese mit R20-R26/R31).  `doprnt` ist handgeschriebener Assembler.  `sh` bindet
die ausgelieferte `libc.a` unveraendert.

**6. Herkunft des Eigencodes** (das, was der Nachbau tatsaechlich belegt): V7-Text unveraendert `sync`, `cat`, `mount`,
`umount`, `date`, `ls`; V7 mit belegten Abweichungen `init` (5), `login` (3, wie Hippe-Sammlung `login.c.old`), `sh` (3);
nicht V7 `getty` (Struktur wie Hippe-Sammlung `getty.c.old`) und `stty` (gleiches Programm wie das Binary der Hippe-Sammlung,
Quelle rekonstruiert).  Die Hippe-Sammlung (TUHS) ist Vergleichsreferenz, keine Urheberangabe.

Der Kernel (Plan 43) nutzt dieses Regelmodell nicht: `gesamtbau.py --stufe 1` nimmt nur Funktionen aus C, die ohne
Umschreibung bytegleich sind (2026-11-09: 218 von 230, Kernel 36352 von 36352 Byte gleich, Boot und Arbeitstests ok).

Quellen: `userspace/NAME/NAME.c`; Karte/Listing/Namen daneben (`k.txt`, `NAME.lst`, `NAME.namen`, `NAME.strings`, `namen.txt`, optional
`karte_extra.txt`); Arbeitsdateien in `userspace/NAME/work/` (git-ignoriert).  Test: `tests/test_userspace_pipeline.py`
(`gast`; der Gast-Bau nur mit `USERSPACE_GAST=1`).

## Stolpersteine fuer weitere Programme (alle gemessen)
1. **Die ausgelieferte `libc.a` ist nicht die Bibliothek der Originalprogramme.**  In `init` fehlt der Gleitkomma-Teil von `doprnt` (Stub `ffltpr`), und die
   libc-Glieder sind mit dem aelteren `c2` uebersetzt.  Bytegleichheit der ganzen Datei ist deshalb fuer jedes Programm mit `printf`/stdio nicht erreichbar;
   Beweisziel ist der **eigene Code** `[0x30, erstes starkes libc-Glied)` (der Bericht trennt "own code" und "libc part").  `getty`, `login`, `sh` binden
   vermutlich weitere Glieder (`getpw*`, `ctime`, `qsort`) -- Treffer gegen die Diskettenbibliothek pruefen und Abweichungen getrennt ausweisen.
2. **Der `c2` des Originals ist aelter** (Kernel-Befund, hier erneut): `c2_kanon`/`c2_emu_s` in `uspace.py` bilden R1-R3 ab.  Neue Programme koennen weitere Regeln
   zeigen (z. B. `LD R0,mem ; CP R0,#k` statt `CP mem,#k` -- in den libc-Gliedern gesehen, im Eigencode von `init` nicht).  Erst eine Regel erweitern, wenn ein
   `0 Abweichungsbloecke`-Bericht sonst nicht erreichbar ist, und die Stellenzahl im Bericht angeben.
3. **Jeder Gast-Befehl muss im Verzeichnis `/mnt` enden** (`...;cd /mnt`): der Stapel haengt `;cat fertigN` an, die Marke liegt auf `/mnt`.  Wer nach `cd /tmp`
   uebersetzt und nicht zurueckwechselt, wartet je Befehl die volle Frist (20 Mrd. Takte, ca. 10 Min.) auf eine Marke, die nie kommt.
4. **Header:** `/usr/include` hat kein `utmp.h`, `setjmp.h`, `sys/dir.h`, `sys/ino.h`, `sys/filsys.h` ... (V7-Header liegen unter `original/unix-v7/usr/include`).  Fehlende
   Header in `PROGRAMME` eintragen; sie liegen auf `/mnt` und `-I/mnt` hat Vorrang -- nie einen Header eintragen, den `/usr/include` hat (`signal.h` ist V7-identisch).
5. **Ablauf der Befehle:** `cd /tmp; cc -O -s -I/mnt -o V /mnt/V.c` -- Ausgabe auf die leere `/tmp`-Diskette, Quelle von `/mnt` (Quelldiskette, ca. 250 KB, dort nur Quellen
   und Header).  `-s` setzt `flag 1`/`syms 0` wie im gestrippten Original.  Ein Lauf mit zwei Uebersetzungen dauert ~70 s Wanduhr; mehrere Varianten laufen parallel.
6. **Namen:** `finde_signaturen` nennt Glieder (`cuexit` = `exit`), die Karte nennt die exportierten Symbole (`dup.o` hat `_dup` bei +6 und `_dup2` bei 0).  Handnamen
   (`namen.txt`) gehen nur in die abgelegte Karte; der Vergleich benutzt die Karte ohne Handnamen, damit beide Seiten gleiche Marken haben.
7. **Reihenfolge im Abbild:** `crt0` 0x30 Byte, dann der eigene Code, dann libc-Glieder in der Reihenfolge der Referenzen; Daten stehen direkt hinter dem Text
   (Adresse = Textlaenge), die Daten des Programms zuerst; BSS dahinter, Programm-BSS zuerst (Reihenfolge der Deklarationen).  Zeichenketten-Literale legt der `cc` hinter die
   deklarierten Felder, in Reihenfolge des Auftretens im Code; mehrfach benutzte Literale entstehen mehrfach (deshalb `login[]` als Feld).
8. **Function-Zeiger:** Funktionen, die nur ueber Zeiger erreicht werden (`reset`), liefert erst `--vorschlaege`; im Vergleich werden sie als Funktionsanfaenge
   abstrahiert.  Sprungtabellen (`switch` mit vielen Faellen, z. B. in `sh`) in `karte_extra.txt` als `dwc`-Zeilen nachtragen, wenn `ungueltig`/`Unerreicht` in der
   Statistik auffaellt.
9. **Zeichensatz:** Quelle 7-Bit-ASCII, Kommentare `/* */`, K&R; `int merge();` vor der ersten Benutzung eines spaeter definierten Funktionsnamens als Wert.
10. **Kein `sleep`-Warten:** Gastlaeufe im Hintergrund starten (`run_in_background`) und die Benachrichtigung abwarten; die Platten sind Kopien in `work/bau/<variante>/`.
