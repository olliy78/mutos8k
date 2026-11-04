# /etc/init -- Befunde und Rekonstruktion (Branch userspace-herkunft)

Alles *gemessen*, soweit nicht als *Annahme* markiert.  Werkzeug: `doc/userspace/pipeline.md`; Quelle:
`userspace/init/init.c`; Karte/Listing: `userspace/init/{k.txt,init.lst,init.namen,init.strings,namen.txt}`.

## Ergebnis in einem Satz
`init.c` = V7-`init.c` mit fuenf belegten Abweichungen.  Im Gast mit dem MUTOS-`cc -O` uebersetzt stimmt der **eigene Code**
(0030-065E, 537 Befehle) mit dem Original **Befehl fuer Befehl** ueberein, sobald drei c2-Unterschiede (R1-R3, unten)
beruecksichtigt sind; die Daten des Programms (0x72 Byte, Zeichenketten und Felder) sind **bytegleich**.
Die ganze Datei (4978 B) ist **nicht** bytegleich erreichbar: der libc-Teil des Originals stammt aus einer anderen
(aelteren) `libc.a` als der auf `usr`/`cc2` ausgelieferten (Belege unten).

## Gewinnung (gemessen)
    python3 -I tools/userspace/pipeline.py holen init      # root-Diskette etc/init -> work/init.orig, init.raw
    python3 -I tools/userspace/pipeline.py karte init --ablegen
Kopf `e807 1202 0160 0924 0 0 0 0001`: Text 4610 (0x1202), Daten 352, BSS 2340, gestrippt (`flag` 1); Datei 4978 B, Mode 0775,
mtime 505689331.  Textbasis 0, Daten direkt hinter dem Text (0x1202), BSS ab 0x1362.  Karte: 2 Runden `--vorschlaege`, 275 Einstiege,
0 ungueltig, 0 Ueberlappung, 4350 B Code (87,7 %); 612 B Daten.

## Aufbau des Abbilds (gemessen)
| Adresse | Inhalt |
|---------|--------|
| 0000-002F | `crt0` (argc/argv, `exit`) |
| 0030-0647 | eigener Code in V7-Reihenfolge: `main` 0030, `shutdown` 0084, `single` 011C, `runcom` 01BA, `multiple` 0218, `term` 025C, `rline` 0288, `maktty` 031A, `get` 035C, `merge` 0398, `dfork` 04A6, `rmut` 0554, `reset` 0648 |
| 065E-0CCF | libc: `printf` 065E, `doprnt` 068E, Stub 0866, `strout` 0870, `flsbuf`/`fseek`/`malloc`/`fclose`/`fflush`/`free`/`findiop` ... |
| 0CD0-11F5 | `exit`, `isatty`, `setjmp` 0F0E, `longjmp` 0F1E, `stty`, `access`, `alarm`, `chmod`, `chown`, `close`, `creat`, `dup` (`dup2` 0FFC, `dup` 1002), `execl`, `fork`, `ioctl`, `kill`, `lseek`, `open`, `read`, `sbrk`, `signal` 10F6, `time`, `wait`, `write`, `cerror`, `csv` 11E6, `cret` 11F4 |
| 1202-1273 | Daten des Programms: `shell` 1204, `getty` 120C, `minus` 1218, `runc` 121A, `ifile` 1222, `utmp` 122C, `wtmpf` 1236, `ctty` 1244, `dev` 1252, `"/bin/login"` 1258, `"single user "` 1264, `"/"` 1271 |
| 1274-1361 | Daten der libc (`doprnt`-Sprungtabelle, `_iob` ...) |
| BSS 1362 | `wtmp` 1362 (20 B), `line` 1376, `itab` 1380 (100 x 12 B), `fi` 1830, `tty` 1832, `sjbuf` 1846 (3 Worte) -- Reihenfolge der V7-Deklarationen |

## Vorlage: V7-`init.c` mit fuenf Abweichungen (gemessen)
Die Vorgaengerfassung dieses Dokuments hielt die V7-Quelle fuer ungeeignet, weil `/bin/login` und `single user ` fehlen.
Der Gast-Bau zeigt: V7 plus die folgenden Aenderungen genuegt.
1. `main`: zusaetzlich `signal(SIGTERM, merge)` (Handler = `merge` 0398, nicht `reset`).
2. `main`-Schleife: `close(creat(utmp, 0644))` steht zwischen `runcom()` und `merge()`; in V7 ist es der Anfang von `merge()`.
3. `merge`: `signal(SIGINT, merge); signal(SIGTERM, merge);` (V7 nur SIGINT).
4. `single`: nach `open(ctty,2); dup(0); dup(0);` folgt `printf("single user "); execl("/bin/login", "/bin/login", 0);` vor dem V7-`execl(shell, minus, 0)`;
   `"/bin/login"` liegt als **Feld** `login[]` hinter `dev[]` (erklaert die Datenlage 1252/1258/1264/1271; ein Literal ergaebe zwei Kopien).
5. `multiple`: bei `wait() == -1` wird **fortgefahren** (`continue`), nicht zurueckgekehrt: der Schleifenkopf 021C wird angesprungen,
   `multiple` hat kein `return` (V7: `return`).  Folge: `main` kehrt aus `multiple` nie zurueck.
Der Name `login` fuer das Feld ist *Annahme* (das Original ist gestrippt).  `printf` zieht `doprnt`/`strout`/stdio nach (daher 4,6 KB statt 2,2 KB).

Hippe-Sammlung (TUHS, PDP-11-Binary `original/hippe-v7/etc/init`, 4810 B): nur Strukturhinweis; sie enthaelt dieselben Zeichenketten
(`/bin/login`, `single user `, `(null)` statt `null`); grosse Uebereinstimmung.  Ihre Quelle liegt nicht vor.  *Annahme:* die fuenf Aenderungen
gehen auf ein V7-Derivat zurueck, nicht auf MUTOS selbst.

## Basislinie: unveraenderte V7-`init.c` im Gast (gemessen)
`cc -O -s -I/mnt -o v7 /mnt/v7.c` (+ V7-`utmp.h`, `setjmp.h` auf der Quelldiskette; 67 s Wanduhr): 2334 B (Text 2230, Daten 88, BSS 1304, kein `printf`).
Eigener Code: 521 Befehle statt 536; mit dem c2-Modell stimmen 511 ueberein, 9 Abweichungsbloecke: Aufrufe von `signal(SIGTERM)`,
`creat`/`close` in `main` statt `merge`, `printf`/`execl(login)` fehlen, Zeichenkette `"/"` an anderer Stelle (`D+56` statt `D+6F`),
`multiple`-Schlusssprung (`JP cret` hinter `multiple`), BSS-Adressen in `crt0`.  Das sind genau die fuenf Abweichungen oben.

## Stand von `init.c` (gemessen, `pipeline.py alles init --c2emu`)
| Messung | Ergebnis |
|---------|----------|
| `cc -O -s` ohne c2-Modell | 6368 B (Text 5972), eigener Code 536 Befehle gegen 536; 496 gleich, Rest R1-R3 |
| mit c2-Modell (Vergleich normalisiert) | 536/536 gleich, **0 Abweichungsbloecke** |
| `.s` auf Original-c2-Form umgeschrieben (`c2_emu_s`: R1 20x, R2 8x, R3 1x), mit `as`/`ld` gebaut | eigener Code 537/537 Befehle **ohne** Modell gleich, 0 Bloecke; Eigencode-Laenge 0030-065E **wie im Original** |
| Daten 1202-1273 | **bytegleich** (0x72 Byte) |
| Eigencode, Woerter die im Abbild noch abweichen | 149 von 815 -- nur Adressoperanden (libc-Aufrufziele, Daten- und BSS-Adressen, die mit dem groesseren libc-Teil wandern) |
| Gesamtdatei | 1710 von 4962 Byte gleich an gleicher Stelle (Text 5958 statt 4610) -- **nicht** bytegleich |

### c2-Unterschiede R1-R3 (gemessen)
Der Original-Compiler (`c2`) ist aelter als der auf den Disketten (derselbe Befund wie beim Kernel, `doc/kernel/c_rueckbau.md`):
* **R1** `INC R15,#k ; LD @R15,x` (Disketten-`c2`) gegen `INC R15,#k+2 ; PUSH @R15,x` (Original): der Disketten-`c2` fasst das Argumentwort nach Aufrufen
  mit mehr als einem Argumentwort zusammen, der Original-`c2` nur nach einem Einwort-Aufruf (dort stehen auch im Original `CALL f ; LD @R15,x` ohne `INC`).  20 Stellen.
* **R2** `XORB RHn,RHn ; LDB mem,RLn` (Disketten-`c2`) gegen `LDB mem,RLn` (Original): das Original laesst das Nullen des oberen Bytes vor dem Bytespeichern weg.  8 Stellen
  (`maktty`, `merge`, `dfork`, `rmut`).
* **R3** in `get`: `XORB RH2,RH2 ; CP R2,#10 ; JR Z,.. ; XORB RH2,RH2 ; JR ..` -- das Original wiederholt das `XORB`, der Disketten-`c2` nicht.  1 Stelle.
Das Modell wird *nicht* im Quelltext nachgebildet (kein Quelltext liefert die Original-Formen mit diesem `c2`), sondern als Umschreibung der `cc -S`-Ausgabe
(`c2_emu_s`); dass die drei Regeln **alle** Unterschiede des Eigencodes erklaeren, ist damit durch Assemblieren und Binden belegt, nicht nur im Vergleich.

### Der libc-Teil des Originals ist nicht die ausgelieferte `libc.a` (gemessen)
* `doprnt` des Originals (068E-0866, 472 B) hat keinen Gleitkomma-Code: die Faelle `e f g` rufen den Stub 0866 (`INC R13,#8 ; LDB @R10,#'?' ; INC R10,#1 ; RET`),
  die `libc.a` enthaelt `doprnt.o` (474 B) mit den Externen `pfloat/pscien/pgen` aus `fltpr.o` (320 B); ein Stub-Glied (V7 `ffltpr.s`) fehlt in der `libc.a`.
  Der Bau mit der Diskettenbibliothek zieht daher `fltpr`, `gcvt`, `ecvt` ... nach: libc-Teil 1442 statt 994 Befehle, BSS 2420 statt 2340, Text 5958 statt 4610.
* Auch die uebrigen libc-Glieder sind mit dem aelteren `c2` uebersetzt (z. B. `LD R0,%000C(R14) ; CP R0,#F` statt `CP %000C(R14),#F`, `EXTSL RQ4`);
  von 994 Befehlen stimmen 922 mit der ausgelieferten Bibliothek ueberein (56 Abweichungsbloecke).  Die Symbolsignaturen (maskierter Text) der Syscall-Stubs und
  von `csv`, `setjmp`, `signal` ... treffen exakt, daher stammen diese Glieder aus demselben Quelltext/Compilerstand.
* Folge: Bytegleichheit der ganzen Datei braucht die alte `libc.a` (nicht vorhanden) oder deren Rekonstruktion; sie ist **nicht** Aufgabe dieses Programms.
  Bausteine fuer spaeter: `ffltpr`-Stub, `doprnt` ohne Gleitkomma (V7-`doprnt.s`-nah).

## Offen
* Die alte `libc.a` bzw. ihre Glieder `doprnt`, `strout`, `flsbuf`, ... (andere Programme profitieren: jedes, das `printf` benutzt).
* Name des Feldes `login` (Annahme); Kommentare des Originals sind nicht erhalten (gestrippt).
* Hippe-`init` (PDP-11): kein Disassembler im Repo geprueft; die Zeichenketten genuegten als Strukturhinweis.
