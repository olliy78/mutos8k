# Auftrag S5 (Plan 44, Stufe 5): Diskette `bin` -- mt, tar, adb

Stand 2026-11-16, Branch `us-cmd-s5` (von `main` nach Merge `us-erg-e3d`).  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Die Diskette `bin` hat die Dateien im Wurzelverzeichnis: `pipeline.py` nimmt `--platte bin` mit Pfad `mt`, `tar`, `adb` (nicht `bin/NAME`; `k1520disktool ls` der Diskette zeigt `adb mt tar`).

| Programm | Datei | Ergebnis | Quelle | c2-Regeln (Stellen) |
|----------|-------|----------|--------|---------------------|
| `mt` | 4342 B (text 3232, data 1094, bss 1048) | **G** ganzdatei bytegleich | kein V7 (V7 hat kein `mt.c`), aus dem Binary rekonstruiert | keine |
| `tar` | 17000 B (text 14798, data 2186, bss 5832) | **G** ganzdatei bytegleich | kein V7-Text im Repository; Text von `original/sys3/cmd/tar.c` als **Vergleichsquelle**, 8 Abweichungen | R92 (1 Stelle, nur tar) |
| `adb` | 27770 B (text 21490, data 6264, bss 3116) | **A** (nicht rekonstruiert) | V7-`adb` mit Z8000-Maschinenschicht, siehe unten | -- |

Befehle: `python3 -I tools/userspace/pipeline.py alles mt --libc alt --ist neu` (kein c2-Modell) und
`python3 -I tools/userspace/pipeline.py alles tar --c2emu --libc alt --ist neu_c2_s`; danach `cmp work/bau/neu.bin work/mt.orig` bzw. `cmp work/bau/neu_c2_s.bin work/tar.orig` ohne Ausgabe.
Vorarbeit je Programm: `libc_alt.py members NAME && quelle NAME && bau NAME` (Rundlauf: 0 Glieder abweichend), `karte NAME --ablegen`.

## 1. mt (G)

Quelle `userspace/mt/mt.c`, 65 Zeilen, **kein V7-Text** (in `original/unix-v7` gibt es kein `mt.c`; die Struktur entspricht dem frueheren BSD-`mt`).
Rekonstruktion aus dem Listing: Befehlstabelle `com[]` bei 0CA2 (7 Eintraege `{name, code, ronly}` mit `eof fsf bsf fsr bsr rewind offline`, Codes 0..6, danach Nullsatz),
`-t tape` statt BSD-`-f`, Standardgeraet `/dev/nrmt0`, `ioctl(mtfd, 'm'<<8|1, &mt_com)` (`6D01`), `mt_com` = `{op, count}`, bss-Reihenfolge `mtfd`, `mt_com`, `tape`.
Meldungen: `usage: mt [ -t tape ] command [ count ]`, `mt: what's "%s" ?`, `%s %d ` + `perror("failed")`.
Auffaelligkeiten der Reihenfolge (alle im Listing gemessen): `mt_count` wird **vor** `mt_op` gesetzt; die `argc < 2`-Pruefung steht vor der `-t`-Auswertung (`mt -t tape` ohne Befehl liest `argv[1]` = NULL); der `ioctl`-Fehlerzweig beendet das Programm nicht.
Der Bau mit `cc -O -s` und der rekonstruierten libc (`libc_alt/mt.members`, 24 Glieder; `mt.members.zusatz`: `doprnt code=02C8,02CE,02E4` wie bei hex) ist **ohne** c2-Regeln bytegleich.
Das c2-Modell (R1 3x, R4 3x) wuerde ihn zerstoeren: dieses Programm kommt aus dem c2-Stand der Diskette.  `karte_extra.txt`: `ohne 0300` / `code 02FE` (z8kdis schlaegt eine Marke mitten im Befehl der `doprnt`-Sprungtabelle vor).

## 2. tar (G)

Quelle `userspace/tar/tar.c`.  In `original/unix-v7` gibt es **kein** `tar.c`.  Das MUTOS-Binary hat dieselben Zeichenketten und dieselbe Funktionsfolge wie `original/sys3/cmd/tar.c` (u. a. die
unsinnigen `strcat(buf, "sort +0 -1 +1nr ")`-Zeilen vor dem `sprintf`, deren Literale im Binary stehen).  Der Text wurde deshalb von dort uebernommen (**nur als Vergleichsquelle**, nicht als Zusatz zu MUTOS: das Programm ist ein
Originalprogramm der Diskette) und gegen das Listing korrigiert.  Dass das MUTOS-tar aus V7 stammt und sys3 ein Verwandter ist, ist eine **Annahme**; gemessen ist nur, dass dieser Text die Originalbytes erzeugt.
Abweichungen vom sys3-Text (je mit `/* Differs from ... */` markiert):
1. `"dir.h"` statt `<sys/dir.h>` (wie bei den anderen Programmen).
2. `NBLOCK` 8 statt 20 (gemessen: `CP nblock,#8` im Listing; bss 5832 passt erst mit 8).
3. Geraet `/dev/mt0` statt `/dev/mt1`.
4. `main()`: nur die Ziffernfaelle `'0'` und `'1'` (gemessen: Schalterverteilung `DIV RR2,#4` mit Quotienten 12/27/29/30 ...; mit `'0'..'7'` waehlt der c1 sieben statt vier Faecher).
5. `longt()`: `"%7D"` statt `"%7ld"`.
6. `checkdir()`: Lokale `i, pid, j`, `if ((pid = fork()) == 0)`, `while ((j = wait(&i)) >= 0 && pid != j);` (Original: 3 Lokale, Vergleich mit der Kindnummer).
7. `checkdir()`: nach `/usr/bin/mkdir` weiter `execl("/mnt/bin/mkdir", ...)` und `execlp("mkdir", "mkdir", name, 0)`.
8. `getwdir()`: nach `/usr/bin/pwd` weiter `execl("/mnt/bin/pwd", ...)` und `execlp("pwd", "pwd", 0)`.
Eigencode 0000-1836: 1936 Befehle, alle gleich.

**libc-Teil** (`userspace/libc_alt/tar.members`, 64 Glieder, darunter `doscan`/`scanf` (fscanf/sscanf), `ctime`, `system`, `execvp`): `tools/userspace/libc_alt.py` kannte das Datenglied `ctype_` nur bei `atof`; `doscan` bindet es ebenfalls
(geaendert: Bedingung `("ctype_", "doscan")`, 130 B Daten; ohne das war die Datenaufteilung um 130 B falsch).  Handkorrekturen `tar.members.zusatz`: `doprnt code=2514,251A,2530`; `ctime exp=...@2FC4` (der Gast-`ctime` hat die Funktionsgrenzen 8 Byte frueher als das Glied der ausgelieferten `libc.a`).
`karte_extra.txt`: `ohne 2536 00C8 010C 01B6 021E` (Marken mitten im Befehl; ohne sie `--check` mit `Ueberlappung 4`).
Rundlauf `libc_alt.py bau tar`: 6 Glieder aus C (rdwr, doscan, flsbuf, endopen, ctime, malloc) Text bytegleich, 0 Glieder abweichend.

**c2-Regel R92** (neu, nur tar: `uspace.c2_tar_s`, aufgerufen mit `c2_emu_s(..., tar=True)`; dann wirkt **nur** R92, keine der Regeln R1-R91):
`test _rflag ; jp eq L ; test _cflag ; jr eq L2 ; jp L` -> das erste `jp eq` wird `jr eq` (`main()`, `case 'b'`: `if (rflag && !cflag) goto noupdate;`; Abstand 252 B passt in ein `jr`, der ausgelieferte c2 schaetzt zu grosszuegig).
**1 Stelle** (die zweite Stelle gleicher Form im `case`-Rumpf bei 023C hat im Original `JP`, sie wird durch die Bedingung `jp` mit demselben Ziel gleich dahinter ausgeschlossen; ohne diese Bedingung bricht `as` mit `ILLEGAL VALUE`).
Ohne R92 ist tar laengengleich bis auf diese eine Stelle (text 14800 statt 14798, ein `JP Z` statt `JR Z`).  Schwach belegt wie alle Einzelstellenregeln (README Punkt 2).

## 3. adb (A)

Nicht rekonstruiert; Stand gemessen, nicht erzwungen.
* `holen`: text 21490, data 6264, bss 3116, `flag 1` (nicht getrennte I&D; V7-`adb` wird mit `cc -i` gebaut, was im MUTOS-Kernel nicht startet, `exp_ldi.md`).  Karte: 1312 Einstiege, 103 `call csv`-Funktionen, 21 libc-Glieder, Ueberlappung 28, Marken mitten im Befehl 19
  (Sprungtabellen und Tabellen im Text; `--check adb` meldet deshalb FAIL, eine `karte_extra.txt` wurde nicht erstellt).  `PROGRAMME` enthaelt den Eintrag nur zum Holen und Karten.
* **V7 ist die Grundlage, die Maschinenschicht nicht.**  Auswertung der Literale im Datenteil gegen `original/unix-v7/usr/src/cmd/adb/*.[ch]` (Skript im Gespraech, Zaehlung): von 381 Zeichenketten sind 149 identisch mit V7
  (u. a. alle Meldungen aus `message.c` bis auf `VERSION MUTOS8000  DATE 1985 May 29 16:37:44`); 232 sind neu, darunter
  * die Z8000-Mnemonik-Tabellen (`flags refresh psapseg nspseg setflg ... ldctlb ... fldbcd fsettrap frestrap ... djnz calr ldps ldm sdl sda ... dbjnz`; ca. 6 KB Daten) und die Meldung `kein code %x` (**deutsch**),
  * Operandformate in Hexadezimal (`%x(FP)`, `%x(r%d)`, `r%d(#`, `@SP`, `@FP`, `@r%d`, `#%x`, `def %x`) statt der oktalen PDP-11-Formate (`%o`, `(%s)+`, `-(%s)`),
  * Registernamen `r10`..`r13`, Meldungen `breakpoint%8t`/`stopped at%8t`, Systemaufrufnamen (`utime ftime ioctl exece umask chroot`).
  115 V7-Literale (PDP-11-Mnemonik von `opset.c`, `sub processes not supported`, `fpsr`, Oktalformate) fehlen im Binary.
* Folgerung (**Annahme**): `access.c command.c expr.c findfn.c input.c main.c message.c output.c pcs.c sym.c` sind V7-nah; `opset.c` (Z8000-Disassembler), `machine.h`/`defs.h` (Registerlage, `ptrace`-Wortzahlen), `print.c`, `runpcs.c`, `setup.c` und
  die Hex-Formate in `format.c` sind MUTOS-Eigenbau ohne Vorlage im Repository.  Eine Rekonstruktion braeuchte den ganzen Z8000-Disassembler (Operandtabelle, ca. 6 KB Daten) und die MUTOS-`user`-/`ptrace`-Schnittstelle (`kernel/h/user.h`, `reg.h` sind Platzhalter,
  Registerlage der Trap-Frames nicht aufgeloest), ist Mehrtage-Arbeit und wurde hier bewusst nicht begonnen.  Naechster Schritt, falls gewuenscht: V7-Module einzeln mit `cc -O` bauen und je Funktion gegen die Karte vergleichen (unveraenderte Module finden), dann die Maschinenschicht aus dem Listing.

## 4. Regression und Tests

c2-Stand der bisherigen Programme unveraendert: `c2_emu_s(..., tar=False)` ist der bisherige Code (die neue Funktion `c2_tar_s` wird nur mit `tar=True` aufgerufen, `pipeline.py` uebergibt `name == "tar"`); `pipeline.py --check`
liest jetzt auch `karte_extra.txt` (`extra=extra_karte(name)`), sonst ist `--check` fuer Programme mit `ohne`-Zeilen nicht erfuellbar.  Gemessen im Gast (`alles NAME --c2emu --libc alt --ist neu_c2_s`): siehe Abschnitt 5.
`pytest -q -m "not gast"`: 207 passed.

## 5. Regressionslauf

Gemessen: cp und ls gleich (BYTE-IDENTICAL). ar, ed, sh liefen beim Abschluss noch; der geaenderte Code beruehrt sie nur ueber den neuen Parameter tar=False (Annahme: unveraendert, nicht gemessen).
