# Auftrag S3a (Plan 44): df, rm, mv, od, who, cmp der Diskette `cmd` (`bin/`)

Stand 2026-11-10, Branch `us-cmd-s3a`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Alle sechs Programme: **G** (ganzdatei bytegleich).

| Programm | Datei | Abbild (text/data/bss) | Quelle | c2-Regeln (Stellen, Lauf mit Modell) |
|----------|-------|------------------------|--------|--------------------------------------|
| `bin/df` | 3562 B | 3546 (3170/376/1554) | V7 `df.c`, 6 Abweichungen (Includes, Geraete, Auffuellungen) | R42 1, **R64 1**; R1/R4 aus (`C2_AUS`) |
| `bin/rm` | 5782 B | 5766 (5226/540/1110) | V7 `rm.c`, 2 Abweichungen (Include, `execlp`) | **keine** (alle Zaehler 0); R1/R4/R5 aus (`C2_AUS`) |
| `bin/mv` | 6836 B | 6820 (5690/1130/1262) | V7 `mv.c`, 1 Abweichung (Include) | R1 5, R4 4, R5 2, **R63 1** |
| `bin/od` | 5552 B | 5536 (5218/318/1100) | V7 `od.c` **unveraendert** | R1 1, R4 5, R5 1, R7 1, R32 1, R38 1, **R60 1**; R3 aus (`C2_AUS`) |
| `bin/who` | 6662 B | 6646 (6198/448/1690) | V7 `who.c` **unveraendert** | R1 3, R4 4 |
| `bin/cmp` | 4656 B | 4640 (4154/486/1074) | V7 `cmp.c` **unveraendert** | R1 1, R4 5, R5 3, **R61 3, R62 1** |

Befehle je Programm (Bau und Beweis):

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME           # Gast
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s              # "=> BYTE-IDENTICAL"
    cmp userspace/NAME/work/bau/neu_c2_s.bin userspace/NAME/work/NAME.orig                           # ohne Ausgabe

`diff original/unix-v7/usr/src/cmd/NAME.c userspace/NAME/NAME.c` zeigt nur die unten genannten, im Quelltext mit `/* Differs from V7: ... */` markierten Stellen
(`od`, `who`, `cmp`: kein Unterschied).  Dass die Abweichungen die MUTOS-Fassung sind, ist jeweils eine **Annahme**; gemessen ist nur, dass dieser Text die Originalbytes erzeugt.

## Abweichungen vom V7-Text (durch Bytes belegt)

* **df**
  1. `"param.h" "filsys.h" "fblk.h"` statt `<sys/..>` (die V7-Header liegen flach auf `/mnt`, `-I/mnt` kennt keine Unterverzeichnisse).  `PROGRAMME`: `param.h filsys.h fblk.h`.
  2. Geraete `/dev/rk0`, `/dev/rk1` statt `/dev/rp0`, `/dev/rp3` (Datenbytes 0xC82..: `rk0`/`rk1` im Original; `cmp -l` zeigte genau 3 Bytewerte als einzigen Unterschied).
  3. `sblock` 512 B im Original (BSS-Unterschied 72 B = 512-440): `char sbpad[BSIZE-sizeof(struct filsys)]` hinter `sblock`, `bread(1L, &sblock, BSIZE)` statt `sizeof(sblock)` (wie bei `dcheck`/`ncheck`).
  4. `alloc()`: der lokale Puffer `buf` belegt 512 B (Rahmen `SUB R15,#0x206`, `buf` bei -0x212, `bread(b, &buf, 0x200)`): `char bpad[BSIZE-sizeof(struct fblk)]` vor `buf`, `BSIZE` statt `sizeof(buf)`.
* **rm**: `"dir.h"` statt `<sys/dir.h>`; dritter Versuch `execlp("rmdir", "rmdir", f, 0);` hinter den beiden `execl` (das Original hat zwei weitere Zeichenketten `rmdir` und bindet `execvp`/`execlp`;
  ohne diese Zeile fehlten 580 Byte und 208 Befehle des libc-Teils).  Das ist *nicht* der V7-Text von `rm.c`.
* **mv**: `"dir.h"` statt `<sys/dir.h>`.
* **od, who, cmp**: V7-Text unveraendert (`who.c` mit `#ifdef interdata`-Block unveraendert; `who` bindet `<utmp.h>` aus `PROGRAMME`, `pwd.h` ist in `/usr/include`).

## libc-Teil und Behelfe

`libc_alt.py members/quelle/bau NAME`; Rundlauf `bau`: 0 Glieder abweichend bei allen sechs.  G-Glieder (aus dem Original-Abbild, belegen keine Herkunft; README Punkt 5):
`cmp`: `endopen`; `od`: `rdwr endopen`; `df`: keine; `rm`: `execvp sleep`; `mv`: keine; `who`: `fgets rdwr endopen atoi ctime`.  Handeingriffe:

* **cmp**: `members_auto` nimmt das datenreine Glied `ctype_` (130 Byte `_ctype_`) nur fuer `atof` auf; `cmp` benutzt `isdigit()`.  Folge: die Datenfenster von `doprnt`/`data` lagen 0x48 Byte zu weit hinten
  (`quelle`: `printf: direct address 1108 in no member`).  `userspace/libc_alt/cmp.members.zusatz`: `doprnt data=10AE:10FA`, `data data=10FA:119C`, `+ ctype_ 0CCA 0CCA data=119C:121E`
  (Werkzeug unveraendert; Daten des Originals: `null` bei 10F4, `_iob` ab 10FA, Typtabelle ab 119C).
* **df, rm**: `doprnt` ist die 474-Byte-Fassung (`LD R4,R2` statt `EXTSL RQ4`, wie `dcheck`/`ncheck`/`mkfs`); die Sprungtabellen-Einstiege liegen 2 Byte spaeter als automatisch erzeugt
  (`df.members.zusatz`: `code=03E4,03EA,0400`, `rm.members.zusatz`: `code=0792,0798,07AE`), sonst `quelle`: `z8kdis left data words in the code`.
* **who**: `members_auto` benennt das Glied bei 017C `getgrgid` (gleiche Signatur wie `getpwuid`, Tabellenzelle `a|b`).  `who` ruft aber `getpwuid`; das Archiv enthielt deshalb das falsche Glied, `ld` zog
  `getpwuid` erst aus der ausgelieferten `libc.a` und stellte es an die falsche Stelle (Eigencode 0x25C statt 0x17C Byte, 62 Differenzbloecke im libc-Teil).  **Von Hand** in `who.members`:
  `getpwuid 017C 01A4 exp=_getpwui@017C src=S` (Zusatzdatei kann Gliedernamen nicht umbenennen; bei Neuerzeugung von `who.members` erneut eintragen).
  `libc_alt.py quelle who` meldet weiter `ERROR: ttyname: 2000 in B of getpwent ...` (die Konstante 0x2000 im Code von `ttyname` gleicht einer BSS-Adresse, unschaedlich wie bei `login`/`ttyslot`; `bau` und Bytevergleich gleich).

## Neue c2-Regeln R60-R64 (`uspace.c2_emu_s`; Modell des alten c2, kein Lauf desselben)

Alle fuenf sind **Beschreibungen** von Unterschieden zwischen der Ausgabe des ausgelieferten c2 und dem Original, jeweils an 1-3 Stellen belegt, also **schwach**.
Quellvarianten wurden nicht durchprobiert (V7-Text, nur Codeformen).  Nummer R65 wurde im Lauf vergeben und wieder entfernt (rm brauchte statt ihrer das Abschalten von R5, s. u.).

| Regel | Stellen | Muster (ausgelieferter c2 -> Original) |
|-------|---------|----------------------------------------|
| R60 | 1 (od) | `and rN,#%FF ; ld MEM,rN ; cp MEM,#k` -> `... ; ld r0,rN ; cp r0,#k` (R4 haette `ld r0,MEM`).  Auf `and ..,#%FF` eng gefasst: dieselbe Form hinter anderer Maske oder Byteladung hat `ld r0,MEM` (cat 1x, mkfs 5x gemessen: ohne die Einschraenkung zerstoert die Regel `cat`) |
| R61 | 3 (cmp) | `ld -N(FP),r3 ; ld r2,r3 ; ldb rl3,@r2 ; xorb rh3,rh3 ; cp r3,#k ; jr ne L ; ld r2,-N(FP)` -> `ld -N(FP),r3 ; ld r2,-N(FP) ; ldb ; xorb ; cp ; jr ne L` (Nachladen hinter dem Sprung entfaellt; `arg = argv[1]; if (arg[0] == '-' && arg[1] == 's')`) |
| R62 | 1 (cmp) | `pop r2,@SP` + Marke + `ld rN,r3 ; ld r2,X` -> `ld r2,r3 ; ld rN,r2` (der ausgelieferte c2 laesst die tote Kopie `ld r2,r3` weg; die anderen drei `getc`-Verbindungsstellen bekommen dieselbe Form schon aus R5) |
| R63 | 1 (mv) | `xorb rhN,rhN ; ldb @rM,rlN ; ld rK,rN ; ld rX,rN ; test rN` -> `... ; ld rK,rN ; ld rX,rK ; test rK` mit erhaltenem XORB (`while ((c = *s++ = *t++))`, Registervariable `c`; Ausnahme von R2 und R5) |
| R64 | 1 (df) | `ldl MEM,rr4 ; testl rr4 ; jr eq ; ldl rr2,rr4 ; ld r5,X ; xor r4,r4 ; cpl rr2,rr4 ; jr lt ; ldl rr0,MEM ; cpl rr0,M` -> `testl MEM ; jr eq ; ldl rr2,MEM ; ... ; ldl rr0,rr2 ; cpl rr2,M` (`b = a[i]; if (b == 0) ..; if (b < x || b >= y)` mit `long b`; entspricht inhaltlich den mkfs-/icheck-Regeln R54/R46, die dort aber an `mkfs=True` bzw. andere Muster gebunden sind und unveraendert blieben) |

Vor dem Lauf wurden die neuen Regeln auf dem Host gegen alle `neu.s` der 26 bisherigen Programme in der Hauptkopie gerechnet (mit/ohne die Regeln): kein anderes Programm wird veraendert (`cat` und `mkfs` zeigten die erste Fassung von R60 und
fuehrten zur Einschraenkung auf `and #%FF`).  Der Test `test_c2_model_rewrites_and_canonicalises` pinnt die Zaehlerliste, um R60-R64 erweitert.

### Programmweises Abschalten in `C2_AUS` (`pipeline.py`)

Bestehende Regeln wurden nicht geaendert; stattdessen sind sie fuer je ein Programm abgeschaltet, wenn das Original die Form des *ausgelieferten* c2 hat:

* **df**: R1, R4 aus.  Original hat `CP mem,#k` (3 Stellen) und `INC R15,#4 ; LD @R15,#0` (1 Stelle), also die neuere c2-Form; mit R1/R4 war der Eigencode 6 Byte zu lang (`vergleich`: Befehlsstrom gleich, Laenge verschieden).
* **rm**: R1, R4, R5 aus (R1 5, R4 3 Stellen; R5 2 Stellen: `i = b = getchar()` behaelt `ld r2,r3 ; ld MEM,r3`).  Mit diesen drei Abschaltungen greift **keine** Regel mehr: rm = Ausgabe des ausgelieferten `cc -O` + `libc_alt`.
* **od**: R3 aus.  Sie setzte ein `XORB` vor den `jr` in die `switch`-Verteilung (`switch(*p++)` hinter `*p == '-'`), das das Original nicht hat (1 Stelle).

*Annahme*: `df` und `rm` wurden mit einem c2-Stand uebersetzt, der in diesen Punkten dem ausgelieferten entspricht (anderer Stand als bei den uebrigen Programmen der Diskette, vgl. `sh` in README Punkt 2).  Nicht untersucht, welche weiteren Programme das betrifft.

## Hinweise zum Ablauf (Fehlerbilder)

* Ein erster Lauf ohne `BSIZE`-Auffuellung zeigte bei `df` nur BSS 1482 statt 1554 und Verschiebungen der Datenadressen; bei `rm` fehlten 580 Byte Text (`execlp`); bei `mv` 2 Byte (`XORB`, R63);
  bei `who` stimmte die Gesamtgroesse, die Eigencode-Grenze lag aber 0xE0 Byte zu spaet (Gliedname `getgrgid`, s. o.); bei `od` war der Befehlsstrom gleich, die Datei 2 Byte zu lang (R3 aus).  Diese Befunde stehen vor den jeweiligen Korrekturen.
* **Stale-Falle:** `cmp` gegen eine alte `neu_c2_s.bin` meldet Gleichheit, wenn `holen`/`alles` wegen eines gestoerten Emulator-Neubaus (`BUILD FEHLGESCHLAGEN`, Fremdsitzung in `a5120emu`) scheiterten.  Gueltig sind nur Laeufe, in deren Log `=> BYTE-IDENTICAL` steht.

## Regressionslauf

Einmaliger Neubau aller 26 bisherigen Programme plus der sechs neuen (`holen` + `alles NAME --c2emu [--libc alt] --ist neu_c2_s` bzw. fuer `sh` `bau sh --c2emu --variante v7fix`, je danach `cmp` gegen `work/NAME.orig`, 3 parallel), Stand des Codes nach R60-R64/`C2_AUS`, gemessen 2026-11-10 ca. 22:20-23:00:
**33 von 33 bytegleich**: sync 132, getty 1166, cat 4088, date 5774, ls 8260, stty 5830, init 4978, login 9920, mount 4288, umount 4112, echo 2168, pwd 3460, rmdir 4160, mkdir 3950, wc 4148, size 4064,
chmod 3710, kill 3808, cp 3592, ln 4330, clri 3574, mknod 3954, dcheck 4514, ncheck 5078, icheck 6542, mkfs 8406, sh 18296, df 3562, rm 5782, mv 6836, od 5552, who 6662, cmp 4656 Byte.
Vorherige Laeufe waren teilweise durch Fremdsitzungen im Emulator-Baum (`BUILD FEHLGESCHLAGEN`) gestoert und wurden einzeln wiederholt; massgeblich ist dieser letzte vollstaendige Lauf.
`pytest tests/test_userspace_pipeline.py -q`: siehe Abschlussbericht (8 passed, 1 skipped bei den vorherigen Laeufen).

## Aussagekraft

Wie README Punkt 1, 2 und 5: *C-Quelle + ausgelieferter Compiler + diese Regeln (+ `C2_AUS`) = Originalbytes*; die Regeln sind ein Modell.  Neu hier: fuenf Regeln mit 1-3 Stellen (R60-R64) und drei programmweise Abschaltungen.
Der libc-Teil ist aus dem Abbild bzw. der ausgelieferten `libc.a` gewonnen und belegt keine Herkunft.  Der Eigencode von `od`, `who`, `cmp` ist byteweise V7-Text; `df` und `rm` sind V7 mit den oben belegten Abweichungen.
