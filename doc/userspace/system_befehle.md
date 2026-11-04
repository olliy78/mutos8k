# Systembefehle /bin/login, /etc/getty, /etc/mount, /etc/umount (Branch us-system)

Alles *gemessen* (Pipeline `doc/userspace/pipeline.md`, `alles NAME --c2emu`), soweit nicht als *Annahme* markiert.
Quellen: `userspace/{login,getty,mount,umount}/NAME.c`; Karte/Listing/Namen daneben.  Hippe-Sammlung (TUHS) nur als
Vergleichsreferenz ("grosse Uebereinstimmung"), nie als Urheber.

## Ergebnis
| Programm | Vorlage | Ergebnis |
|----------|---------|----------|
| `/etc/getty` | **nicht V7-`getty.c`**, sondern Hippe `getty.c.old` (Tabelle gekuerzt) | **Ganzdatei bytegleich** (1150 B, `neu_c2_s`) |
| `/bin/login` | V7-`login.c`-Struktur = Hippe `login.c.old` (Stand mit `'\177'`/`'\25'`, `"password:"`) | Eigencode 0030-04FA befehlsgleich (399 von 406 Befehlen; Rest = Adressoperanden/libc-Ziele); Datei nicht bytegleich (libc, Stolperstein 1) |
| `/etc/mount` | V7-`mount.c` unveraendert | Eigencode 192/192 befehlsgleich bis auf Datenadresse und `perror`-Ziel |
| `/etc/umount` | V7-`umount.c` unveraendert | Eigencode 144/144 ebenso |

## getty: welche Vorlage passt (wichtigster Befund)
V7-`getty.c` baut im MUTOS-Gast gar nicht (`NL1`, `CR1`, `FF1`, `TAB1` fehlen im MUTOS-`sgtty.h`; "illegal initialization").
Das MUTOS-`sgtty.h` hat die erweiterte `struct sgttyb` (Verzoegerungen `sg_nldly..sg_vtdly`, `sg_width`, `sg_length`), `SCOPE`, `TIOCSETA`.
`gettyok.c`/`getty.c.old` der Hippe-Sammlung nutzen genau diese Felder.  Das Original entspricht `getty.c.old` mit:
tchars `^C`/`^Z` (`getty.c.old`; `gettyok.c` hat DEL/`^D`), `ERASE` DEL, `KILL` `^U`, `EOT` `^Z`, Vorgabetabelle `'-'`, keine Debug-Schleife
(`gettyok.c` hat sie), und **nur zwei Tabelleneintraege**: `'2'` (9600 Baud, 80x24, `SCOPE`) und `'w'` (9600 Baud, 64x16); beide mit
`"\n\rlogin: "`; Eintrag 0 ist Rueckfall bei unbekanntem Namen.  Die Baudratentabelle der Vorlagen (V7: 300/1200/150/110 ...) ist im MUTOS **nicht** vorhanden.
Daher passt `getty.c.old` (nicht `gettyok.c`, nicht V7) -- Belege: Tabelle 0x03AC.. im Listing, Datenstrings `login: `, `/bin/login`, `login`.
Die Zeichenketten `"login: "` liegen zweimal (zwei Tabelleneintraege), `"/bin/login"`, `"login"` danach: Datenlage 210 B stimmt.
c2-Regeln fuer getty: R1 3x, R2 2x, R4 1x, R5 1x, R6 1x (siehe unten).

## login
Strukturgleich mit V7; Abweichungen D1-D3 im Quellkopf: Loeschzeichen DEL und `^U` (V7 `#`, `@`), Deklarationsreihenfolge (Datenlage), `"password:"`
statt `"Password:"` und keine Meldung `Login incorrect`.  Das Programm bindet `getpass`, `crypt`, `execlp`, `fopen` ... aus einer alten `libc.a`;
die Funktion `getpass` (04FA) liegt vor dem ersten starken Treffer und zaehlt daher im Bericht zum "Eigencode" (1 Block "delete" ist sie, kein Fehler).
Handnamen in `userspace/login/namen.txt` (*Annahme* der Namen, Adressen gemessen).  V7-`login.c` im Gast: 23 Bloecke (`'#'`/`'@'`, `Login incorrect`, Datenreihenfolge).

## mount / umount
V7-Text reicht unveraendert.  Die Fehlertexte stammen aus `perror` (`sys_errlist`, 35 Eintraege, `Unknown error`) der libc.
Rest-Unterschiede: Aufrufziel `perror` und Datenadresse (verschoben durch den groesseren libc-Teil); `umount`: `PUSH #0400` wird im Vergleich als
Funktionsanfang abstrahiert (Artefakt der Abstraktion, Konstante `NMOUNT*2*NAMSIZ`).

## Neue c2-Regeln (Original-`c2` gegen Disketten-`c2`), Stellenzahl
* **R4** `LD R0,mem ; CP R0,#k` statt `CP mem,#k`: login 3, getty 1, mount 3, umount 1 (Stolperstein 2 hatte sie nur in libc-Gliedern gesehen; hier im Eigencode).
* **R5** `LDB RLa,mem ; XORB RHa,RHa ; LDB RLb,RLa` -> Original laedt erneut aus `mem` (`LDB RLb,mem`): getty 1 (`putchr`).
* **R6** keine Weitergabe von Registerkopien: `LD rA,rB ; LD dst,rB` -> `LD dst,rA` (login 2, getty 1); `AND rX,#k ; OR rA,rX` mit X=A+2 -> `AND ; LD rA+1,rX ; OR rA,rA+1` (getty 1).
Modell: `c2_emu_s` (Umschreibung der `cc -S`-Ausgabe), `c2_kanon` kennt R4.  Test: `tests/test_userspace_pipeline.py`.

## Pipeline-Erweiterungen
* `PROGRAMME`: login (+V7 `utmp.h`), getty, mount, umount.  Gast-Befehl wie bisher.
* `c2_emu_s`: R4-R6.  Handnamen je Programm (`namen.txt`), damit Aufrufe in `getpass`/`perror` usw. gleiche Marken bekommen.
* Stolperstein: das MUTOS-`sgtty.h` weicht vom V7-Header ab (nicht auf `/mnt` legen!); V7-Quellen mit `NL1`/`CR1` bauen nicht.

## Offen
* Ganzdatei-Gleichheit login/mount/umount braucht die alte `libc.a` (in Arbeit, nicht hier).
* `sys_errlist`-Texte mount/umount: nur indirekt aus `perror` belegt.
