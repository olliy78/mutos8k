# Auftrag W8 (Plan 52): `libc.a`, `crt0.o`, `mcrt0.o`

Stand 2026-11-18, Branch `us-wk-w8`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Werkzeug: `tools/userspace/wk_w8.py` (Gastlaeufe, Vergleich, Archiv), `tools/userspace/wk_w8_tabelle.py` (diese Tabelle); Quellen: `userspace/libc/` (`NAME.c`, `NAME.s`, `crt0.s`, `mcrt0.s`).

## 1. Ergebnis

* **`/usr/lib/libc.a`** (71914 B, 140 Glieder): **111 Glieder G** (Objektdatei bytegleich zur Diskette), 24 E, 5 A, 0 F.  Das **Archiv als Ganzes ist nicht G** (nur ein Teil der Glieder ist G; Reihenfolge, Gliedkoepfe, Auffuellbytes sind aber gleich, Abschnitt 4).
* Je Klasse: **C-Glieder (77)**: 53 G, 24 E; **Assembler-Glieder (63)**: 58 G, 5 A.  `crt0.o` (200 B) und `mcrt0.o` (548 B): **E** (Text, Daten, BSS, Relokation, Exporte gleich; nur der Wert zweier Abschnittssymbole `BSS_B`/`crt0_s_d` bzw. `mcrt0_s_` ist im Original 0x34/0xB4, bei uns 0).
* Klassen: **G** Objektdatei bytegleich; **E** Text/Daten/BSS und alle Relokationsworte gleich, nur der *Wert* der `~f`-Symbole (Funktionsmarken der Debugtabelle) bzw. der Abschnittssymbole weicht ab; **A** Text/Daten/BSS und Relokation gleich, aber die Symboltabelle (Reihenfolge, lokale Marken) weicht ab, Quelle = Datenworte.
  Alle Aussagen: Gast `cc -O -c` (C) bzw. Gast `as -u` (Assembler) auf der Original-`usr`-Diskette, Vergleich der ganzen Objektdatei (`wk_w8.py cbau/sbau`).

## 2. Befunde

1. **Der ausgelieferte `cc` baut die V7-Quellen fast unveraendert zur ausgelieferten `libc.a`**: ohne jedes c2-Modell sind 53 C-Glieder G (davon 46 mit V7-Text unveraendert) und 24 E.  Die Stolperstein-1-Aussage ("libc.a-Glieder mit aelterem `c2` uebersetzt", `README.md`) trifft fuer die *Diskettenbibliothek* nicht zu; sie betrifft die *Programme* (`libc_alt`), deren Glieder mit dem alten Stand gelinkt sind.  Gemessen: das Glied `flsbuf` der `libc_alt` (aus den Programmabbildern rekonstruiert) uebersetzt der Gast-`cc` zum Diskettenglied (Text und Relokation gleich, E).
2. **Ein c2-Unterschied**: `inc SP,#%A ; push @SP,X` (Aufraeumen von fuenf Argumenten, dann sofort ein neues erstes Argument) wird im Original zu `inc SP,#%8 ; ld @SP,X` verschmolzen, der Gast-`c2` laesst es (`popen`, `system`; im Original-`c0` ebenso, R130 aus `wk_w4.md`).  Modell: `wk_w8.py modell` (`cc -O -S` -> Regel -> `as -u`), 2 Stellen.  Damit gehoert die Diskettenbibliothek zum selben c2-Stand wie `c0`.
3. **Mehr `register`-Variablen** (wie im `c0`): bei 19 C-Gliedern (58 sind V7-Text unveraendert) weicht der Quelltext vom V7 ab, meist durch zusaetzliche `register`-Deklarationen (Reihenfolge = Register R13, R12, ...; die Reihenfolge der Deklarationen steht auch in der Debugtabelle des Originals, `a`/`r`-Symbole), Stellen mit `/* Differs from V7: ... */` im Quelltext markiert: getpass, timezone, rdwr, system, doscan, execvp, sleep, crypt, malloc, qsort, nlist, ctime, l3, getw, putw, index, rindex (und die rekonstruierten filbuf, flsbuf).
4. **Weitere Abweichungen vom V7-Text** (je im Quelltext markiert): `timezone` kennt `-1*60, "MET", "MEST"`; `getw`/`putw` big endian (`(i<<8)|getc`, High-Byte zuerst); `l3` nimmt den `interdata`-Zweig; `malloc` `GRANULE 256`; `nlist` ohne `A_MAGIC2` (die `a.out.h` der Diskette kennt es nicht); `ctime`: `copyt = *tim; copyt -= (long)systime.timezone*60;` (Ein Ausdruck gibt im Gast-`cc` ein ungueltiges `popl`); `filbuf`: `_IORW` und `_sibuf`/`_sobuf` (rekonstruiert aus dem Objekt, Reihenfolge der Anweisungen nach der Befehlsfolge); `flsbuf` = `libc_alt/c/flsbuf.c` (`_flsbuf fflush _cleanup fclose fseek` ein Glied).
5. **Assembler-Glieder** (`userspace/libc/*.s`): der Befehlstext stammt aus den `libc_alt`-Quellen (Programmabbilder); Aufzaehlung der Externen vor dem ersten `G`/`I` (Reihenfolge wie im Original), **die Marken tragen die V7-Namen** (`$1`, `loop`, `nd`, `dvect`, `tvect`, `asyncex`, `swtab`, `prbuf` ...), mehrere Einstiege mit `G name L` vor der Prozedur (`dup`), Daten mitten im Code (`doprnt`: `$DATA ... $CODE`), Referenzen auf nicht benannte Stellen als `Marke+%n` (`signal`: `tvect+%2`).  Die Gast-`as`-Regel dahinter: `$n`-Marken sind je **Prozedur** lokal, deshalb ist `doprnt` im Original in drei Prozeduren (`__doprnt`, `prstr`, `gnum`) zerlegt.  Zehn kleine Systemaufruf-Glieder (`acct chroot execle execve lock profil ptrace times abort mcount`) ohne `libc_alt`-Quelle sind von Hand aus dem Disassembler geschrieben.
6. **Gleitkomma**: `ecvt` und `atof` (EPA-Befehle) kann der Gast-`c1` nicht uebersetzen (`Fatal error in /usr/lib/c1`); `gcvt` und `modf` ja (G).  `fltpr`, `frexp`, `ldexp`, `ecvt`, `atof` sind als **Datenwort-Quellen** (`wk_w8.py wbau`, `WV` je Wort, Relokationen als Symbolausdruecke, `userspace/libc/*.s`) A: Text/Daten/BSS und Relokationsworte gleich, Symboltabelle (Reihenfolge) anders.  Eine Befehlsquelle fuer `frexp`, `ldexp`, `fltpr` waere der naechste Schritt (G wahrscheinlich, *Annahme*: wie `doprnt`).
7. **Rest bei E**: Der Gast-`as` gibt den `~f`-Symbolen der Funktionsmarken `~~f:` (Debugtabelle von `cc`) einen anderen Wert als der `as` des Originals (Original: Adresse der Funktion, Gast: konstant, = Groesse des Datenabschnitts); ebenso die Abschnittssymbole `BSS_B`, `crt0_s_d` (Original: Gesamtgroesse, Gast: 0).  Probiert und verworfen: Marke hinter `E` (Syntaxfehler), Marke vor `G ... PR` (Syntaxfehler), `ld -r` auf den Gast-Objekten (gibt zusaetzlich ein `f`-Symbol, aendert die Werte nicht), Abschnittsreihenfolge/`$SDEFAULT` bei `crt0`.  Ursache (anderer `as`-Stand) *Annahme*.  Text, Daten, Relokation, Exporte sind gleich; fuer das Binden mit `ld -s` ist die Abweichung wirkungslos (*Annahme*, nicht je Programm nachgebunden).

## 3. Tabelle je Glied

Reihenfolge wie im Archiv (`wk_w0.md`, 3d), danach `crt0`, `mcrt0`.  Herkunft: "V7 unchanged" = Quelltext byteweise der V7-Text, "V7 + changes" = V7-Rahmen mit markierten Abweichungen, "reconstructed" = aus Disketten-/Programmabbild (Assembler) bzw. Objekt rekonstruiert, "data words" siehe Befund 6.  `c2-Modell R130`: Bau ueber `cc -S`, Regel, `as`.

| Glied | Art | Quelle | Herkunft | Klasse | c2-Modell |
|-------|-----|--------|----------|--------|-----------|
| getgrgid | C | `getgrgid.c` | V7 unchanged | **G** |  |
| getgrnam | C | `getgrnam.c` | V7 unchanged | **G** |  |
| getgrent | C | `getgrent.c` | V7 unchanged | **E** |  |
| getpass | C | `getpass.c` | V7 + changes | **G** |  |
| getpwnam | C | `getpwnam.c` | V7 unchanged | **G** |  |
| getpwuid | C | `getpwuid.c` | V7 unchanged | **G** |  |
| getpwent | C | `getpwent.c` | V7 unchanged | **E** |  |
| timezone | C | `timezone.c` | V7 + changes | **E** |  |
| fgetc | C | `fgetc.c` | V7 unchanged | **G** |  |
| fputc | C | `fputc.c` | V7 unchanged | **G** |  |
| getchar | C | `getchar.c` | V7 unchanged | **G** |  |
| putchar | C | `putchar.c` | V7 unchanged | **G** |  |
| popen | C | `popen.c` | V7 unchanged | **E** | R130 |
| freopen | C | `freopen.c` | V7 unchanged | **G** |  |
| fgets | C | `fgets.c` | V7 unchanged | **G** |  |
| fputs | C | `fputs.c` | V7 unchanged | **G** |  |
| getpw | C | `getpw.c` | V7 unchanged | **G** |  |
| ftell | C | `ftell.c` | V7 unchanged | **G** |  |
| rew | C | `rew.c` | V7 unchanged | **G** |  |
| rdwr | C | `rdwr.c` | V7 + changes | **E** |  |
| system | C | `system.c` | V7 + changes | **G** | R130 |
| fopen | C | `fopen.c` | V7 unchanged | **G** |  |
| fdopen | C | `fdopen.c` | V7 unchanged | **G** |  |
| scanf | C | `scanf.c` | V7 unchanged | **E** |  |
| doscan | C | `doscan.c` | V7 + changes | **E** |  |
| fprintf | C | `fprintf.c` | V7 unchanged | **G** |  |
| gets | C | `gets.c` | V7 unchanged | **G** |  |
| getw | C | `getw.c` | V7 + changes | **G** |  |
| printf | C | `printf.c` | V7 unchanged | **G** |  |
| puts | C | `puts.c` | V7 unchanged | **G** |  |
| putw | C | `putw.c` | V7 + changes | **G** |  |
| sprintf | C | `sprintf.c` | V7 unchanged | **G** |  |
| ungetc | C | `ungetc.c` | V7 unchanged | **G** |  |
| filbuf | C | `filbuf.c` | V7 + changes | **G** |  |
| setbuf | C | `setbuf.c` | V7 unchanged | **G** |  |
| doprnt | asm | `doprnt.s` | reconstructed | **G** |  |
| fltpr | asm | `fltpr.s` | data words | **A** |  |
| gcvt | C | `gcvt.c` | V7 unchanged | **G** |  |
| ecvt | asm | `ecvt.s` | data words | **A** |  |
| strout | C | `strout.c` | V7 unchanged | **G** |  |
| flsbuf | C | `flsbuf.c` | V7 + changes | **E** |  |
| endopen | C | `endopen.c` | V7 unchanged | **E** |  |
| findiop | C | `findiop.c` | V7 unchanged | **G** |  |
| clrerr | C | `clrerr.c` | V7 unchanged | **G** |  |
| data | C | `data.c` | V7 unchanged | **G** |  |
| cuexit | asm | `cuexit.s` | reconstructed | **G** |  |
| execvp | C | `execvp.c` | V7 + changes | **E** |  |
| getenv | C | `getenv.c` | V7 unchanged | **E** |  |
| getlogin | C | `getlogin.c` | V7 unchanged | **E** |  |
| perror | C | `perror.c` | V7 unchanged | **G** |  |
| sleep | C | `sleep.c` | V7 + changes | **E** |  |
| ttyslot | C | `ttyslot.c` | V7 unchanged | **E** |  |
| ttyname | C | `ttyname.c` | V7 unchanged | **E** |  |
| abort | asm | `abort.s` | reconstructed | **G** |  |
| abs | C | `abs.c` | V7 unchanged | **G** |  |
| atof | asm | `atof.s` | data words | **A** |  |
| atoi | C | `atoi.c` | V7 unchanged | **G** |  |
| atol | C | `atol.c` | V7 unchanged | **G** |  |
| crypt | C | `crypt.c` | V7 + changes | **E** |  |
| ctime | C | `ctime.c` | V7 + changes | **E** |  |
| calloc | C | `calloc.c` | V7 unchanged | **E** |  |
| malloc | C | `malloc.c` | V7 + changes | **E** |  |
| errlst | C | `errlst.c` | V7 unchanged | **G** |  |
| fakcu | asm | `fakcu.s` | reconstructed | **G** |  |
| modf | asm | `modf.s` | reconstructed | **G** |  |
| frexp | asm | `frexp.s` | data words | **A** |  |
| ldexp | asm | `ldexp.s` | data words | **A** |  |
| isatty | C | `isatty.c` | V7 unchanged | **G** |  |
| l3 | C | `l3.c` | V7 + changes | **E** |  |
| mktemp | C | `mktemp.c` | V7 unchanged | **G** |  |
| mon | C | `mon.c` | V7 unchanged | **G** |  |
| nlist | C | `nlist.c` | V7 + changes | **E** |  |
| qsort | C | `qsort.c` | V7 + changes | **E** |  |
| rand | C | `rand.c` | V7 unchanged | **E** |  |
| setjmp | asm | `setjmp.s` | reconstructed | **G** |  |
| stty | C | `stty.c` | V7 unchanged | **E** |  |
| swab | C | `swab.c` | V7 unchanged | **G** |  |
| tell | C | `tell.c` | V7 unchanged | **G** |  |
| ctype_ | C | `ctype_.c` | V7 unchanged | **G** |  |
| index | C | `index.c` | V7 + changes | **G** |  |
| rindex | C | `rindex.c` | V7 + changes | **G** |  |
| strcat | C | `strcat.c` | V7 unchanged | **G** |  |
| strncat | C | `strncat.c` | V7 unchanged | **G** |  |
| strcmp | C | `strcmp.c` | V7 unchanged | **G** |  |
| strncmp | C | `strncmp.c` | V7 unchanged | **G** |  |
| strcpy | C | `strcpy.c` | V7 unchanged | **G** |  |
| strncpy | C | `strncpy.c` | V7 unchanged | **G** |  |
| strlen | C | `strlen.c` | V7 unchanged | **G** |  |
| access | asm | `access.s` | reconstructed | **G** |  |
| acct | asm | `acct.s` | reconstructed | **G** |  |
| alarm | asm | `alarm.s` | reconstructed | **G** |  |
| chdir | asm | `chdir.s` | reconstructed | **G** |  |
| chroot | asm | `chroot.s` | reconstructed | **G** |  |
| chmod | asm | `chmod.s` | reconstructed | **G** |  |
| chown | asm | `chown.s` | reconstructed | **G** |  |
| close | asm | `close.s` | reconstructed | **G** |  |
| creat | asm | `creat.s` | reconstructed | **G** |  |
| dup | asm | `dup.s` | reconstructed | **G** |  |
| execl | asm | `execl.s` | reconstructed | **G** |  |
| execle | asm | `execle.s` | reconstructed | **G** |  |
| execv | asm | `execv.s` | reconstructed | **G** |  |
| execve | asm | `execve.s` | reconstructed | **G** |  |
| exit | asm | `exit.s` | reconstructed | **G** |  |
| fork | asm | `fork.s` | reconstructed | **G** |  |
| fstat | asm | `fstat.s` | reconstructed | **G** |  |
| getgid | asm | `getgid.s` | reconstructed | **G** |  |
| getpid | asm | `getpid.s` | reconstructed | **G** |  |
| getuid | asm | `getuid.s` | reconstructed | **G** |  |
| ioctl | asm | `ioctl.s` | reconstructed | **G** |  |
| kill | asm | `kill.s` | reconstructed | **G** |  |
| link | asm | `link.s` | reconstructed | **G** |  |
| lock | asm | `lock.s` | reconstructed | **G** |  |
| lseek | asm | `lseek.s` | reconstructed | **G** |  |
| mknod | asm | `mknod.s` | reconstructed | **G** |  |
| mount | asm | `mount.s` | reconstructed | **G** |  |
| nice | asm | `nice.s` | reconstructed | **G** |  |
| open | asm | `open.s` | reconstructed | **G** |  |
| pause | asm | `pause.s` | reconstructed | **G** |  |
| pipe | asm | `pipe.s` | reconstructed | **G** |  |
| profil | asm | `profil.s` | reconstructed | **G** |  |
| ptrace | asm | `ptrace.s` | reconstructed | **G** |  |
| read | asm | `read.s` | reconstructed | **G** |  |
| sbrk | asm | `sbrk.s` | reconstructed | **G** |  |
| setgid | asm | `setgid.s` | reconstructed | **G** |  |
| setuid | asm | `setuid.s` | reconstructed | **G** |  |
| signal | asm | `signal.s` | reconstructed | **G** |  |
| stat | asm | `stat.s` | reconstructed | **G** |  |
| stime | asm | `stime.s` | reconstructed | **G** |  |
| sync | asm | `sync.s` | reconstructed | **G** |  |
| time | asm | `time.s` | reconstructed | **G** |  |
| times | asm | `times.s` | reconstructed | **G** |  |
| umask | asm | `umask.s` | reconstructed | **G** |  |
| umount | asm | `umount.s` | reconstructed | **G** |  |
| unlink | asm | `unlink.s` | reconstructed | **G** |  |
| utime | asm | `utime.s` | reconstructed | **G** |  |
| wait | asm | `wait.s` | reconstructed | **G** |  |
| write | asm | `write.s` | reconstructed | **G** |  |
| cerror | asm | `cerror.s` | reconstructed | **G** |  |
| mcount | asm | `mcount.s` | reconstructed | **G** |  |
| csv | asm | `csv.s` | reconstructed | **G** |  |
| crt0 | asm | `crt0.s` | reconstructed | **E** |  |
| mcrt0 | asm | `mcrt0.s` | reconstructed | **E** |  |

C {'E': 24, 'G': 53}
asm {'A': 5, 'E': 2, 'G': 58}

## 4. Archiv

    python3 -I tools/userspace/wk_w8.py archiv    # Host: Archiv aus work/bau/*.o mit den Originalkoepfen
    python3 -I tools/userspace/wk_w8.py arbau     # Gast: original bin/ar der cmd-Diskette ueber unsere Objekte

* **Gliederung (gemessen)**: schreibt man die *ausgelieferten* Glieder mit den ausgelieferten Koepfen (Name, Datum, uid 0, gid 1, Modus 0100664, Auffuellbyte hinter ungerader Laenge) zusammen, entsteht `libc.a` **bytegleich** (Wachter `structure guard`).  Datum je Glied eigen (1986, aufsteigend, `520268144` ..); alle 140 Glieder uid 0, gid 1, Modus 0100664.
* **Archiv aus unseren Objekten**: 70966 B statt 71914 B (111 Glieder bytegleich, 29 nicht: 24 E, 5 A, Groessenunterschied nur durch die Symboltabellen der A-Glieder) -- **kein G**, weil die 29 Glieder nicht G sind.
* **Gast-`ar`** (das Original-`/bin/ar` der `cmd`-Diskette, in 12er-Gruppen `ar rc`): Reihenfolge und Namen aller 140 Glieder gleich; Kopf-Felder weichen ab: gid (Gast 0, Original 1), Modus (0100644 statt 0100664) und Datum (Gastuhr) -- das sind Eigenschaften der Original-Sitzung, kein Quellunterschied (*Annahme*: Original-`umask 002`, Gruppe 1; nicht nachgestellt).

## 5. Offen

* Die 24 E-Glieder: Wert der `~f`-/Abschnittssymbole (Befund 7) -- brauchte den `as`-Stand des Originals (W7).
* Befehlsquellen fuer `fltpr frexp ldexp`; `ecvt`/`atof` bleiben Datenworte, solange der Gast-`c1` EPA-Code nicht erzeugt (W6).
* `gid`, `umask` und Datum des Archivs im Gast nachstellen (Archiv G, sobald alle Glieder G sind).
* Regel R130 (Befund 2) hat nur zwei Belege in der Bibliothek (und drei im `c0`).
