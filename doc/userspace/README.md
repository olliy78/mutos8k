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
| `cmd_s3a.md` | `cmd`-Diskette: df, rm, mv, od, who, cmp (ganzdatei bytegleich), c2-Regeln R60-R64, `C2_AUS` fuer df/rm/od |
| `exp_ldi.md` | Experiment: getrennte I&D (`ld -i`, E811) startet im MUTOS-Kernel nicht; Folge fuer yacc (SMALL bleibt). Branch `us-exp-ldi` (nicht gemergt) |
| `erg_e3a.md`, `erg_e3b.md` | Ergaenzungen aus V7: yacc (verkleinert, SMALL), vmake (V7 make) |
| `erg_e2a.md`, `erg_e2b.md` | Ergaenzungen aus V7 (Plan 45): grep fgrep tr join du file; sort find diff diffh |
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

**Warnung zu den Regeln.**  Mit Stufe 2 kamen 22 weitere c2-Regeln hinzu (B1: R35-R39, B2: R42, R43, R45-R48, B3: R49-R59; die Nummer R44 ist frei, weil B1s R38 dieselbe Form erzeugt).  Die Mehrzahl
greift an nur einer Stelle (Schaetzung nach den Agentenberichten, nicht ausgezaehlt): sie beschreiben einen Unterschied, erklaeren aber nicht den alten c2.  Die Regeln von drei Auftraegen sind getrennt entstanden und mussten
umbenannt werden (B2: R35-R41 zu R42-R48; B3: R35-R45 zu R49-R59, gelten nur in `c2_mkfs_s`); B2s R42 und R45 (urspruenglich R35, R38) treffen sonst `sh` (dort in `C2_AUS` abgeschaltet).
Regel R42 (B2) weicht der B1-Regel R37 aus: das ist eine nachtraegliche Anpassung, die Bytegleichheit bleibt (Regression 26/26).

## Herkunft der Quellen: Diskette `cmd`, Stufe 3a (gemessen 2026-11-11)

Sechs weitere Programme, **ganzdatei bytegleich** (`pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s`).  Nach dem Merge wiederholt gemessen (cmp/Bericht): df rm mv od who cmp
sowie als Stichprobe cat ls mkfs ncheck init -- 11 von 11 gleich; der Agent meldet 33 von 33 aller Rueckbau-Programme (22:20-23:00, nicht von mir wiederholt).  Aussagekraft wie oben.

| Programm | Datei (B) | Abweichung vom V7-Text | c2-Regeln |
|----------|-----------|------------------------|-----------|
| od | 5552 | keine | R60 1; `C2_AUS` R3 |
| who | 6662 | keine | -- |
| cmp | 4656 | keine | R61 3, R62 1 |
| mv | 6836 | `"dir.h"` statt `<sys/dir.h>` | R63 1 |
| rm | 5782 | `"dir.h"`; **eine Zeile, die nicht V7 ist** (`execlp("rmdir","rmdir",f,0);`, ohne sie fehlten 580 B im libc-Teil) | `C2_AUS` R1 R4 R5 (keine Regel greift) |
| df | 3562 | `"x.h"`-Includes, Geraete `/dev/rk0`/`rk1` statt `rp0`/`rp3`, `sblock`/`buf` auf 512 B aufgefuellt, `BSIZE` statt `sizeof` | R64 1; `C2_AUS` R1 R4 |

Dass die Abweichungen die MUTOS-Fassung sind, ist **Annahme**; gemessen ist nur, dass der Text die Originalbytes erzeugt.  Dass df und rm mit einem anderen c2-Stand uebersetzt wurden
(`C2_AUS`), ist Annahme.  R60-R64 sind schwach belegt (1 bis 3 Stellen).  Behelfe: `who.members` von Hand (Glied `getgrgid` in `getpwuid` umbenannt, geht bei Neuerzeugung verloren),
`cmp.members.zusatz`, `df.members.zusatz`, `rm.members.zusatz`.
Gemessener Stolperstein: ein parallel gestarteter Lauf scheitert gelegentlich beim Emulator-Neubau (`dev.sh build failed`, GoogleTest-Ziele) -- das ist kein Befund zum Programm; Wiederholung einzeln.

## Ergaenzungen aus V7 (Plan 45) -- keine Originale

Programme, die auf den MUTOS-Disketten **fehlen**, aus den V7-Quellen (nur V7, nichts aus System III).  Es gibt keine Originalreferenz, deshalb keine Bytegleichheit:
Beweis ist der Bau mit dem unveraenderten Gast-`cc -O -s` plus ein Gast-Test gegen eine Erwartung (`erg.py alles NAME`, Ergebnis B = baut und Test gleich).
Rahmen und Vertrag: `doc/plan/45_v7_ergaenzungen.md` Abschnitt 7, `erg_e0.md`.

| Gruppe | Programme (Ergebnis B) | Abweichungen vom V7-Text | Doku |
|--------|------------------------|--------------------------|------|
| E0 | basename, tee | keine (tee braucht `errno.h` aus V7) | `erg_e0.md` |
| E1a | sleep, touch, yes, tty, sum, rev (`mesg`: **X**, baut, nicht getestet) | keine | `erg_e1a.md` |
| E1b | uniq, comm, split, tail, cal, look, nice, time, test | `time.c`: `<times.h>` statt `<sys/times.h>` | `erg_e1b.md` |
| E2a | grep, fgrep, tr, join, du, file | grep, du, file: `<param.h>`/`<dir.h>` statt `<sys/..>` | `erg_e2a.md` |
| E2b | sort, find, diff, diffh | find: `<dir.h>` statt `<sys/dir.h>` | `erg_e2b.md` |
| E3a | yacc | `files`: `yaccpar` im Arbeitsverzeichnis statt `/usr/lib` (usr-Platte voll); `dextern`: Groessenklasse `SMALL` statt `MEDIUM` (MEDIUM = 78314 B, ueber 64 KB), MEMSIZE 4000 | `erg_e3a.md` |
| E3b | vmake (V7 make) | `files.c`: `<dir.h>`, `A_MAGIC2` auf `A_MAGIC1`; `gram.y` unveraendert, `gram.c` im Gast mit dem MUTOS-yacc erzeugt (`tools/userspace/vmake_gram.py`) | `erg_e3b.md` |

Gemessen (Agentenberichte, danach einzeln vom Hauptagenten wiederholt): alle 29 B im Gast (E0 bis E3b).  Grenzen: Erwartungen stammen von GNU-/util-linux-Werkzeugen, nur fuer Faelle, in denen V7 und
GNU gleich arbeiten.  `tty` ist nur ohne Terminal getestet, `time` und `nice` nur Aufruf und Exitstatus (nicht Werte/Wirkung), `look` ohne `/usr/dict/words`.
E2: `file` erkennt keine Z8000-Programme (MUTOS-Magic E807, V7 kennt nur 0407/0410/0411); `diff -h` ist im Gast nicht testbar (`/usr/lib/diffh` fest, `usr`-Platte voll);
`find` hat keine Host-Referenz (Erwartung = Gastausgabe, von Hand gegen das Handbuch geprueft); `du` nur Dateizweig getestet.
E3: `yacc` laeuft nur in der Groessenklasse `SMALL` (`ld -i` hilft nicht: der Kernel nimmt nur E807/E707, `sys1.c:227`, gelesen; E811 wird im Gast als Skript gelesen, gemessen, `exp_ldi.md`) (56714 B Text+Daten+BSS; 300 Zustaende, 200 Produktionen, 127 Terminale); grosse Grammatiken koennen mit `out of space` scheitern
(`bc.y` brauchte MEMSIZE 4000).  `vmake` (28820 B): V7-make kennt `$(X:.c=.o)` nicht (`misc.c` `subst()` liest `X:.c=.o` als Namen); nicht getestet: Neubau bei juengerer Quelle,
`-p -d -k`, Archivnotation, Wildcards.  Die Ergaenzung `vmake` ist **nicht** unser Eigenbau `userspace/make` (Vergleich: `erg_e3b.md`).
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
