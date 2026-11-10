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
| `cmd_a1.md` | `cmd`-Diskette: echo, pwd, rmdir, mkdir (ganzdatei bytegleich) |
| `cmd_a2.md` | `cmd`-Diskette: chmod, kill, cp, ln (ganzdatei bytegleich), c2-Regeln R32-R34 |
| `cmd_a3.md` | `cmd`-Diskette: wc, size (ganzdatei bytegleich) |
| `cmd_b1.md` | `cmd`-Diskette `/etc`: clri, mknod, dcheck (ganzdatei bytegleich), c2-Regeln R35-R39 |
| `cmd_b2.md` | `/etc`: ncheck, icheck (ganzdatei bytegleich), c2-Regeln R42-R48 |
| `cmd_b3.md` | `/etc`: mkfs (ganzdatei bytegleich), c2-Regeln R49-R59 (nur mkfs) |
| `erg_e0.md`, `erg_e1a.md`, `erg_e1b.md` | Ergaenzungen aus V7 (Plan 45): Rahmen `erg.py`, 17 Programme |
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

Der Kernel (Plan 43 §15) nutzt dieselbe Methode mit eigenen Regeln K1-K6 (`tools/kernel/c2_modell.py`, `gesamtbau.py --c2modell`):
230 von 230 Funktionen bytegleich aus C; ohne Modell 218 von 230 (2026-11-09, Kernel 36352 von 36352 Byte gleich, Boot und Arbeitstests ok).

Quellen: `userspace/NAME/NAME.c`; Karte/Listing/Namen daneben (`k.txt`, `NAME.lst`, `NAME.namen`, `NAME.strings`, `namen.txt`, optional
`karte_extra.txt`); Arbeitsdateien in `userspace/NAME/work/` (git-ignoriert).  Test: `tests/test_userspace_pipeline.py`
(`gast`; der Gast-Bau nur mit `USERSPACE_GAST=1`).

## Herkunft der Quellen: Diskette `cmd`, Stufe 1 (Plan 44; gemessen 2026-11-10)

Zehn weitere Programme, alle **ganzdatei bytegleich** (`pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s`, danach `cmp` gegen `work/NAME.orig`).
Die Bytegleichheit hat dieselbe Aussagekraft und dieselben Grenzen wie oben (Punkte 1, 2, 5): c2-Regeln als Modell, libc-Teil aus `libc_alt`, daher
**keine** Herkunftsaussage ueber den libc-Teil.  Ohne `--libc alt` und c2-Modell ist keines der zehn ganzdatei gleich (z. B. pwd Text 4486 statt 3134 B).

| Programm | Datei (B) | Eigencode-Quelle | Abweichung vom V7-Text | c2-Regeln (Stellen) | Doku |
|----------|-----------|------------------|------------------------|---------------------|------|
| echo | 2168 | V7 `echo.c` | keine; `fputs` als Zusatzglied (nicht das der ausgelieferten `libc.a`) | R4 1 | `cmd_a1.md` |
| pwd | 3460 | V7 `pwd.c` | `"param.h"`, `"dir.h"` statt `<sys/..>` (`-I/mnt` kennt keine Unterverzeichnisse) | R1 5, R2 2 | `cmd_a1.md` |
| rmdir | 4160 | V7 `rmdir.c` | `"dir.h"` | R1 4, R4 1 | `cmd_a1.md` |
| mkdir | 3950 | V7 `mkdir.c` | keine | R1 7, R4 1 | `cmd_a1.md` |
| chmod | 3710 | V7 `chmod.c` | keine | R1 2, R4 1, R33 1 | `cmd_a2.md` |
| kill | 3808 | V7 `kill.c` | keine | R4 2, R32 1 | `cmd_a2.md` |
| cp | 3592 | V7 `cp.c` | keine | R1 1, R4 2, R30 2, R34 1 | `cmd_a2.md` |
| ln | 4330 | V7 `ln.c` | keine | R1 2, R4 4 | `cmd_a2.md` |
| wc | 4148 | V7 `wc.c` | keine | R4 4, R5 2 | `cmd_a3.md` |
| size | 4064 | V7 `size.c` | **3**: `A_MAGIC2` entfaellt (kein `A_MAGIC2` im `a.out.h` der Diskette), Format `%x+%x+%x`, `%Db = 0%Xb` | R4 2 | `cmd_a3.md` |

Vergleichsquelle ist `original/unix-v7/usr/src/cmd/NAME.c`.  Ob die drei `size`-Abweichungen die MUTOS-Fassung sind oder anderswo herkommen, ist eine **Annahme**
(gemessen ist nur: ohne sie baut der Gast-`cc` nicht bzw. andere Bytes).
Neue c2-Regeln R32-R34 (je **eine** Stelle, kill/chmod/cp) sind schwach belegt: ein beschriebener Unterschied, keine Erklaerung des alten c2; Quellvarianten wurden
dafuer nicht durchprobiert.  R32 trifft auch `sh` (18298 statt 18296 B) und ist deshalb in `C2_AUS["sh"]` abgeschaltet.
Behelfe: `kill` (Datenfenster und `errlst` in `libc_alt/kill.members` von Hand), `ln` (`karte_extra.txt`: `ohne 0B00`), `size` (Zusatzglied `rdwr`).

## Herkunft der Quellen: Diskette `cmd`, Stufe 2 (`/etc`, Plan 44; gemessen 2026-11-10)

Sechs weitere Programme, alle **ganzdatei bytegleich** (`pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s`).  Regressionslauf aller 26 Rueckbau-Programme nach dem Merge
(sync getty cat date ls stty init login mount umount sh echo pwd rmdir mkdir wc size chmod kill cp ln clri mknod dcheck ncheck icheck mkfs): **26 von 26 gleich**.
Aussagekraft wie oben (Punkte 1, 2, 5).  Die Quellen sind V7 (`original/unix-v7/usr/src/cmd/NAME.c`), die V7-Header liegen flach als `"x.h"` neben der Quelle.

| Programm | Datei (B) | Abweichung vom V7-Text | c2-Regeln (Stellen) | Doku |
|----------|-----------|------------------------|---------------------|------|
| mknod | 3954 | keine | R4 3 | `cmd_b1.md` |
| clri | 3574 | 1 (Include) | R1 4, R4 2, R39 1 | `cmd_b1.md` |
| dcheck | 4514 | 4: `NI` 8 statt 16, `sblock` mit Auffuellung auf 512 B, Includes | R4 4, R35-R38 je 1 | `cmd_b1.md` |
| ncheck | 5078 | `NI` 8, `HSIZE` 1103 statt 2503, `sblock`-Auffuellung, Includes | R42 2, R43 1, R45 1, R38 1 u. a. | `cmd_b2.md` |
| icheck | 6542 | `NI` 8, `sblock`-Auffuellung, `n = ndirect+nindir+niindir+niiindir`, Includes | R42 3, R46 3, R47 1, R48 1, R38 2 u. a. | `cmd_b2.md` |
| mkfs | 8406 | 5: Includes, Variable `badflag`, `if(argc == 6) badflag++`, `badblk()` mit `lseek`/`read` statt Stumpf, `>=` zu `>` in `iput` | R49-R59 (elf, nur mkfs) | `cmd_b3.md` |

Alle Abweichungen sind an der Stelle mit `/* Differs from V7: ... */` kommentiert und im Dokument belegt.  Dass sie die **MUTOS-Fassung** sind, ist jeweils eine
**Annahme**; gemessen ist nur, dass dieser Text die Originalbytes erzeugt (z. B. `itab` 4096 B im Original, `sblock` 512 B statt 440 B der V7-`struct filsys`).

**Warnung zu den Regeln.**  Mit Stufe 2 kamen 25 weitere c2-Regeln hinzu (R35-R59 ohne R40, R44; R44 entfaellt, weil B1s R38 dieselbe Form erzeugt).  Mehr als die Haelfte
greift an genau einer Stelle: sie beschreiben einen Unterschied, erklaeren aber nicht den alten c2.  Die Regeln von drei Auftraegen sind getrennt entstanden und mussten
umbenannt werden (B2: R35-R41 zu R42-R48; B3: R35-R45 zu R49-R59, gelten nur in `c2_mkfs_s`); R35 und R38 aus `cmd_b2`/B1 treffen sonst `sh` (dort in `C2_AUS` abgeschaltet).
Regel R42 (B2) weicht der B1-Regel R37 aus: das ist eine nachtraegliche Anpassung, die Bytegleichheit bleibt (Regression 26/26).

## Ergaenzungen aus V7 (Plan 45) -- keine Originale

Programme, die auf den MUTOS-Disketten **fehlen**, aus den V7-Quellen (nur V7, nichts aus System III).  Es gibt keine Originalreferenz, deshalb keine Bytegleichheit:
Beweis ist der Bau mit dem unveraenderten Gast-`cc -O -s` plus ein Gast-Test gegen eine Erwartung (`erg.py alles NAME`, Ergebnis B = baut und Test gleich).
Rahmen und Vertrag: `doc/plan/45_v7_ergaenzungen.md` Abschnitt 7, `erg_e0.md`.

| Gruppe | Programme (Ergebnis B) | Abweichungen vom V7-Text | Doku |
|--------|------------------------|--------------------------|------|
| E0 | basename, tee | keine (tee braucht `errno.h` aus V7) | `erg_e0.md` |
| E1a | sleep, touch, yes, tty, sum, rev (`mesg`: **X**, baut, nicht getestet) | keine | `erg_e1a.md` |
| E1b | uniq, comm, split, tail, cal, look, nice, time, test | `time.c`: `<times.h>` statt `<sys/times.h>` | `erg_e1b.md` |

Gemessen (auch vom Projektinhaber-Agenten nachgepruft): alle 17 B im Gast.  Grenzen: Erwartungen stammen von GNU-/util-linux-Werkzeugen, nur fuer Faelle, in denen V7 und
GNU gleich arbeiten.  `tty` ist nur ohne Terminal getestet, `time` und `nice` nur Aufruf und Exitstatus (nicht Werte/Wirkung), `look` ohne `/usr/dict/words`.
**Offen:** `tail -2` auf eine Datei ohne Schlusszeilenumbruch gibt im Gast drei statt zwei Zeilen aus; vermutlich V7-Verhalten, **nicht** gegen eine PDP-11 und nicht gegen einen
Compilerfehler abgegrenzt.

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
