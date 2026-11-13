# Auftrag S3b-5 (Plan 44): hex und convert der Diskette `cmd` (`bin/`)

Stand 2026-11-13, Branch `us-cmd-s3b5`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Beide Programme: **G** (ganzdatei bytegleich).  **Beide sind kein V7-Programm**; die Quelle ist aus Listing, Karte und Zeichenketten rekonstruiert
(Namen, Kommentare und Struktur der Quelle sind unsere; bewiesen ist nur, dass dieser Text die Originalbytes erzeugt).

| Programm | Datei | Abbild (text/data/bss) | Quelle | c2-Regeln (Stellen, Lauf mit Modell) |
|----------|-------|------------------------|--------|--------------------------------------|
| `bin/hex` | 4326 B | 4310 (3994/316/1188) | rekonstruiert, kein V7 | nur bekannte: R5 1; R2 aus (`C2_AUS`, 2 Stellen) |
| `bin/convert` | 4602 B | 4586 (4182/404/2138) | rekonstruiert, kein V7 | **R65 2, R66 1, R67 1, R68 1, R69 1**; R1 9, R4 7; R2 aus (`C2_AUS`, 2 Stellen) |

Befehle je Programm (Bau und Beweis):

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME           # Gast, ~1 Min
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s              # "=> BYTE-IDENTICAL"
    cmp userspace/NAME/work/bau/neu_c2_s.bin userspace/NAME/work/NAME.orig                           # ohne Ausgabe

## Quellensuche (negativer Befund)
* `fd -t f -a '^(hex|convert)(\.[a-z]+)?$' original`: nur `original/{unix-v7,sys3}/.../mip/convert` -- ein Shell-Skript des Portable C Compiler, das mit dem
  Programm nichts zu tun hat.  In `original/hippe-v7/bin` gibt es weder `hex` noch `convert`.
* `rg -l -a 'block_special_file|inode :|%06X %-40s|hex: cannot open' original`: **kein** Treffer in V7, System III, Hippe-Sammlung oder wega; die Zeichenketten der beiden Programme kommen in keiner Quelle der Sammlungen vor.
* Folgerung: Rekonstruktion allein aus dem Binary.  Die Herkunft der Programme (Eigenentwicklung des MUTOS-Umfelds) ist *Annahme*; gemessen ist nur das Fehlen im Quellbestand.

## hex (`bin/hex`, Eigencode 0030-02A2, `main` und `hex`)

Woran die Struktur erkannt wurde (Listing `userspace/hex/hex.lst`):
* Daten: `"%06X %-40s  %s\n"` (vor allen Funktionsstrings, also globales `char fmt[]`, das von `printf` per Adresse benutzt wird), `-`, `/dev/tty`, `r`, `r`,
  `hex: cannot open %s\n`, `" %02x"`, `"%02x"`, `"*\n"` (2x), `"%06X\n"`.  Die Reihenfolge im Datenteil folgt der Quelle (V7-`cc`: Funktionsstrings in Quellreihenfolge,
  globale Zeichenfeld-Initialisierer davor).  Die Sprungtabelle `d o x f e g c s l L u r D O X U` bei 0FE8 gehoert zu `doprnt` (libc), nicht zum Programm.
* `main` (0030): `argc--; if (argc == 0) hex(); else while (argv++, --argc >= 0) { if (strcmp(*argv,"-")==0) freopen("/dev/tty","r",stdin); else if (freopen(*argv,"r",stdin)==NULL) { fprintf(stderr,...); continue; } hex(); } exit(0);`
  Belege: `DEC R13 ; JR NZ,L0076` springt in den Schleifenkopf; `JR MI` am Kopf ist das Schleifenende; `Z`-Test hinter `strcmp` waehlt `/dev/tty`.  Das `"-"` bedeutet
  *Terminal*, nicht Standardeingabe (so im Code; **Annahme:** Absicht, weil die Standardeingabe ohnehin der Fall ohne Argumente ist).
* `hex()` (00A4): Zeilenpuffer `obuf[41]` (10D6), Vorgaengerzeile `pbuf[41]` (1100), `ascii[17]` (112A), `pascii[17]` (113C), `long paddr` (114E), `long addr` (1152); Gliederung:
  `i` Byte in der Zeile (R11), `c` Zeichen (R12), `j` (R13), lokales `long n` Zeilenzaehler (`addr = n++ << 4`).  Je Byte `sprintf(&obuf[i/2*5], " %02x", c)` (gerades `i`)
  bzw. `sprintf(&obuf[i/2*5+3], "%02x", c)` (ungerades): `DIV RR2,#2` und `MULT RR2,#5` im Listing, 5 Zeichen je Bytepaar, 8 Paare, 41 = 40 + NUL (Schleife bis `#%0029`).
  Nichtdruckbare (`c > '~'` unsigned, `c < ' '`) werden `.`.  Ist die Zeile voll (`i == 16`), wird `obuf` mit `pbuf` verglichen; bei Unterschied wird die *vorige* Zeile ausgegeben
  (`printf(fmt, paddr, pbuf, pascii)`), davor nichts, wenn `addr == 0`, danach `*` wenn `addr - paddr > 16` (Zeilenunterdrueckung wie `od`).  Am Dateiende die Restausgabe
  und die Laengenzeile `"%06X\n"` mit `i + (i ? addr : addr + 16)`.
* Quellvarianten, die Bytes veraenderten (jeweils gemessen): Reihenfolge der Registervariablen (`register j, c, i` gibt `i=R11, c=R12, j=R13`); `n = 0; paddr = 0;` getrennt (`paddr = n = 0`
  gab `EXTS RR2` statt `LDL RR0`); `if (argc == 0) hex(); else while ...` mit gemeinsamem `exit(0)` (die erste Fassung mit `exit(0)` im `if` und danach nochmal erzeugte anderen Code);
  `(unsigned)c > '~'` (ohne Cast `JR GT` statt `JR UGT`); `if ((c = getc(stdin)) == EOF)` (sonst `LD R12,R3` statt `LD R12,R2`).
* *Annahmen* (aus dem Code nicht unterscheidbar): Namen aller Variablen; `if (i > 0 || addr > 0 && addr != paddr) if (i > 0) ascii[i] = 0;` ist die einfachste Quelle mit
  diesem Sprungmuster (die aeussere Bedingung ist semantisch ohne Wirkung); `return 0;` am Ende von `hex()` (`XOR R2,R2 ; JP cret`).
* Eigencode 0000-02A6 mit libc_alt wortgleich (227 Befehle).  libc-Teil: `userspace/libc_alt/hex.members` (26 Glieder, G-Glied nur `endopen`), `doprnt` ist die 474-Byte-Fassung,
  Einsprungstellen 2 Byte spaeter als `members_auto` annimmt (`hex.members.zusatz`: `code=05B4,05BA,05D0`, wie bei `df`/`rm`); Rundlauf `libc_alt.py bau hex`: 0 Glieder abweichend.

## convert (`bin/convert`, Eigencode 0030-0646)

*Funktion (gemessen aus dem Code):* Aufruf `convert BLOCKDATEI to|from`.  Setzt ein MUTOS-Dateisystem (Z8000, big endian) in die Byteanordnung des PDP-11-V7 um (`to`)
oder zurueck (`from`): Superblock-Felder, Freilistbloecke, Inodes, einfach- und zweifach-indirekte Bloecke und die Inode-Nummern der Verzeichniseintraege werden wortweise
bytevertauscht, die 3-Byte-Blockadressen im Inode (`di_addr`) in ihrem Tiefwort.  *Annahme:* `to` heisst "in das PDP-11-Format" (gemessen ist nur: bei `to` (mode 0) wird nach der Benutzung
vertauscht, bei `from` (mode 1) davor).  Das Programm schreibt in das Geraet (`open(.., 2)`).

Woran die Struktur erkannt wurde (`userspace/convert/convert.lst`):
* Zeichenketten: `seek error %s  0x%06X\n`, `read error %s  0x%04x\n`, `write error %s 0x%04x\n`, `block :`, `inode :`, `to`, `from`, `usage : convert block_special_file 'to'/'from'\n`,
  `can't open %s\n`.  `block :`/`inode :` und die drei Fehlertexte stehen *vor* den Strings von `main` und werden in `blk`/`rdino` direkt als Adresse gepusht: also globale
  `char[]` (nicht Zeiger).  Erstes Datenwort 1058 ist eine **initialisierte** `long` (Wert 1 = Superblock): `long blkno = 1`.
* Datenstrukturen: BSS 11F4 (64 B) = `struct dinode` (die Offsets 11F4 `di_mode`, 1200 `di_addr` (40 B), 1228/122C/1230 Zeiten, 1234 Ende), 1234 (512 B) = Superblock
  (1234 `s_isize`, 1236 `s_fsize`, 123C `s_free[]`, 13CE `s_flock`, 13D2 `s_time`, 13E0 `s_fname`; zugleich Freilistblock `fblk` (`df_free[0]` bei 1236) und Indirektblock),
  1434 (512 B) = Verzeichnisblock (`struct direct`, Schleife `INC R12,#16` bis 1634).  Die V7-Header `param.h ino.h filsys.h fblk.h dir.h` passen (Eintrag in `PROGRAMME`).
  Der Superblock belegt 512 B (wie bei `df`/`dcheck`: `char sbpad[BSIZE-sizeof(struct filsys)]`).
* Funktionen (Quellreihenfolge = Codereihenfolge): `main` (0030), `blk(buf, rw)` (01BE: `off = blkno << 9`, `lseek`, `read`/`write` von 512 B, Fehlerausgabe + `exit(1)`),
  `swabsb` (0266: `swab` ueber 1234..13CE und 13D2..13E0), `rdino(rw)` (029A: Offset `(inum+15) << 6` = Inode `inum` ab Block 2, 64 B), `swabino` (034E: Inodekopf, 3-Byte-Adressen
  `swab(++b, 2); b += 2` je Adresse, Indirektbloecke, Zeiten), `convdir` (04C2: Verzeichnisbloecke, `swab(dp, 2)` je 16-Byte-Eintrag), `swab(p, n)` (05CE, Paartausch; `n >>= 1; while (--n >= 0)`),
  `l3tol(p)` (0604: 3 Byte -> `long`, `((long)c << 16) + (unsigned)w`).
* `main`: Superblock lesen; bei `from` sofort `swabsb`; `inum = (s_isize - 2) << 3` (zwei Anweisungen, `unsigned`: der Offset in `rdino` erweitert ohne Vorzeichen); `curr = s_free[0]`;
  bei `to` danach `swabsb`.  Schleife ueber die Freilistbloecke: Block schreiben, `curr == 0` -> Ende, `blkno = curr`, lesen, bei `from` vertauschen, `curr = df_free[0]`, bei `to` vertauschen.
  Dann `while (inum != 0)`: Inode lesen, bei `from` `swabino`, wenn `di_mode != 0`: bei Verzeichnis (`di_mode & 040000`) `convdir`, bei `to` `swabino`, Inode schreiben; `inum--`.  `sync()` vorn und am Ende.
* **Befund (kein Fehler der Rekonstruktion, aber ungewoehnlich):** bei Verzeichnissen mit Indirektblock wird der Indirektblock von `convdir` *und* von `swabino` bearbeitet (Vertauschung zweimal);
  das ist der Code des Originals, wortwoertlich uebernommen.  *Annahme:* nur selten ausgeloest (Verzeichnis > 10 Bloecke).
* *Annahmen:* alle Namen (`blk`, `swab`, `l3tol`, `curr` ...); `goto usage` im Kopf von `main` (der Code hat genau einen Usage-Block, der von drei Stellen angesprungen wird);
  `strcmp("to", argv[2])` (die Argumente stehen so im Code: zuerst `argv[2]` gepusht, also zweites Argument); `printf(rderr, blkname, (int)blkno)` (der Code pusht nur das Tiefwort 105A).
* Quellvarianten, die Bytes veraenderten: `if ((fd = open(argv[1], 2)) == -1)` (sonst Zusatzbefehl `LD R0,R2`); `q = (char *)&w;` *vor* `c = *p++ & 0377;` in `l3tol`.
* Eigencode 0000-0648 (497 Befehle) und libc-Teil (849 Befehle) wortgleich; `libc_alt.members`: 21 Glieder, **kein** G-Glied, nur die doprnt-Zusatzdatei (`code=07A2,07A8,07BE`), Rundlauf 0 Glieder abweichend.

## Neue c2-Regeln R65-R69 (`uspace.c2_convert_s`; Modell des alten c2, kein Lauf desselben)

Alle fuenf **beschreiben** Unterschiede zwischen dem ausgelieferten c2 und dem Original an je 1-2 Stellen (also **schwach belegt**) und sind **auf den Text von `convert` beschraenkt**:
`c2_emu_s` ruft `c2_convert_s` nur auf, wenn der `.s`-Text die Funktion `_convdir` enthaelt (kein anderes Programm hat eine).  Quellvarianten wurden fuer R65, R66, R68, R69 nicht durchprobiert
(V7-Text-Konventionen, nur Codeformen); Nummern R65-R69 koennen mit anderen Auftraegen kollidieren (bei der Zusammenfuehrung umnummerieren).

| Regel | Stellen | Muster (ausgelieferter c2 -> Original) |
|-------|---------|----------------------------------------|
| R65 | 2 (`blk`, `rdino`) | `call _lseek ; inc SP,#%8 ; test r2 ; jr pl L` -> `testl rr2 ; jr pl L` (`lseek(..) < 0`: der alte c2 verkuerzt den Vorzeichentest nicht) |
| R66 | 1 (`swab`) | `sra r12,#%1` -> `ld r2,#-%1 ; sda r12,r2` (`n >>= 1`) |
| R67 | 1 (`main`) | Schleifeninversion des ausgelieferten c2 (`ivloop` in `c20.c`) rueckgaengig fuer die Freilistschleife: `jr Lh ; L9nnn: BODY Lh: KOPF jr ne L9nnn ; jr Lx` -> `Lh: KOPF jr eq Lx ; BODY jr Lh`.  Das Original hat die Schleife nicht invertiert (`JR Z,L01A6` im Kopf, `JR L0106` am Ende).  Quelltext-Ursache **nicht gefunden** (`for (;;) { blk(); if (curr == 0) break; ..}` wird vom ausgelieferten c2 invertiert; die Bedingung `p3->labno == p1->forw->labno` in `codemove` trifft dort zu) |
| R68 | 1 (`swab`) | `inc rK,#%1 ; ld r2,rK ; inc rK,#%1 ; ld r3,rM ; ldb @r2,rl3` -> `inc rK,#%1 ; ld r2,rK ; ld r3,rM ; ldb @r2,rl3 ; inc rK,#%1` (`*p++ = t` mit Registerwert: der alte c2 zaehlt hinter dem Speichern hoch) |
| R69 | 1 (`swab`) | `ldb rl2,%1(r13) ; ldb @r13,rl2` -> `xorb rh2,rh2` dazwischen (`*p = p[1]`; der ausgelieferte c2 streicht die Nullerweiterung, das Original behaelt sie) |

R2 (XORB streichen) ist fuer `hex` und `convert` abgeschaltet (`C2_AUS`): das Original behaelt `xorb rhN,rhN` vor Bytespeicherungen (hex: Feldkopien `pbuf[j] = obuf[j]` und `pascii[j] = ascii[j]`; convert: `l3tol`).
Das ist dieselbe Art Befund wie bei `df`/`rm` (neuere c2-Form im ausgelieferten c2).

## Regression der bisherigen Programme

Geprueft ist, dass die neuen Regeln und `C2_AUS`-Eintraege **die Eingabe der anderen Programme nicht veraendern**: alle 32 vorhandenen `userspace/*/work/bau/neu.s` der Hauptkopie
(sh ist Mehrdatei, dort gibt es kein `_convdir`) wurden mit dem Stand vor und nach dieser Aenderung durch `c2_emu_s(text, c2_aus(name), name == "mkfs")` geschickt: Ergebnis (Text und Zaehler)
**in allen 32 Faellen gleich** (Skript im Verlauf dieser Sitzung, Ausgabe `32 programs, 0 different`).  Da `as`/`ld` deterministisch sind, bleibt damit die Bytegleichheit der 33 Programme unveraendert;
**kein Gastlauf** der 33 Programme in dieser Sitzung (Annahme, durch die Gleichheit der Eingabetexte begruendet).  `pipeline.py --check hex|convert` OK, `pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped.

## Offen
* R67: Quelltextform, die den ausgelieferten c2 die Freilistschleife nicht invertieren laesst (vielleicht eine andere Schleifenart oder ein anderer Aufbau des Endes von `main`).
* Funktion beider Programme ist aus dem Code gelesen, nicht im Gast ausgefuehrt (`convert` hat nicht gegen ein echtes Dateisystem gelaufen).
