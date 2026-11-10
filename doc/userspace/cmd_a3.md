# Auftrag A3 (Plan 44): `wc` und `size` der Diskette `cmd`

Stand 2026-11-10, Branch `us-cmd-a3`.  Alles *gemessen* mit den genannten Befehlen (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Aussage | Datei | Abbild | Quelle | c2-Regeln (Stellen) |
|----------|---------|-------|--------|--------|---------------------|
| `bin/wc` | **G** ganzdatei bytegleich | 4148 B | 4132 B (text 3836, data 296, bss 1060) | V7 `wc.c` unveraendert | R4 4x, R5 2x |
| `bin/size` | **G** ganzdatei bytegleich | 4064 B | 4048 B (text 3714, data 334, bss 1060) | V7 `size.c` mit 3 Abweichungen | R4 2x |

Befehle (je Programm):

    python3 -I tools/userspace/pipeline.py holen NAME            # Eintrag in PROGRAMME (Platte cmd, bin/NAME)
    python3 -I tools/userspace/pipeline.py karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME     # Gast, ~1 Min
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s        # Gast, ~2 Min

Neue c2-Regeln: **keine**.  Es greifen nur R4 (wc 4, size 2) und R5 (wc 2) aus `uspace.c2_emu_s`; die Wurzelprogramme wurden nicht neu gebaut,
weil `uspace.py` unveraendert ist.  Geaendert: nur die zwei Zeilen in `PROGRAMME`.

## wc

* Quelle `userspace/wc/wc.c` = `original/unix-v7/usr/src/cmd/wc.c`, **Byte fuer Byte unveraendert**.
* Ohne c2-Modell und mit der Diskettenbibliothek (`alles wc`): Abbild 5496 B statt 4132 B (Diskett-`doprnt` hat den Gleitkommateil), Eigencode 200/200 Befehle,
  195 gleich, 5 Differenzbloecke: zwei Register-Kopien (`LD R2,R3 ; LD m,R2` im Original, `LD m,R3` im Bau, an 0x7E und 0x120 *Annahme*: dies sind die Stellen von R4/R5),
  die Datenadressen (`D+84` gegen `D+A0`, nur Folge des laengeren Datenteils) und `CALL fclose` (Namensartefakt).
* Mit `--c2emu --libc alt`: **4132 von 4132 Byte gleich**, Kopf gleich.  R4 4x, R5 2x.
* libc-Teil: `userspace/libc_alt/wc.members` (25 Glieder), Archiv `userspace/libc_alt/wc/libc_alt.a`.  Aus `libc_alt` (A) die Glieder `printf doprnt ffltpr strout flsbuf data cuexit malloc
  isatty stty close creat ioctl lseek open read sbrk write cerror csv`, aus der Diskettenbibliothek (S) `fopen fprintf filbuf findiop`, als Lueckenglied (G) `endopen`
  (294 B, Text/Daten/BSS wie das Original-Abbild; Rundlauf `libc_alt.py bau wc`: 0 Glieder abweichend).

## size

* Quelle `userspace/size/size.c` = V7 `size.c` mit **drei belegten Abweichungen**:
  1. `a_magic[] = {A_MAGIC1,A_MAGIC3,A_MAGIC4,0}`: das `a.out.h` der Diskette (`/usr/include/a.out.h`, gelesen mit `k1520disktool get`) kennt kein `A_MAGIC2`
     (nur `0xE807 0xE811 0xE805`); der Datenteil bei 0x0E84 ist `e807 e811 e805 0000` (`xxd`).  V7 mit `A_MAGIC2` uebersetzt nicht (`A_MAGIC2 undefined`, gemessen).
  2. Format `"%x+%x+%x = "` statt `"%u+%u+%u = "` (Zeichenkette bei 0x0ECA im Original).
  3. Format `"%Db = 0%Xb\n"` statt `"%Db = 0%Ob\n"` (bei 0x0ED6).
  Alles andere (Meldungen `not found`, `not an object file`, `a.out`, `r`, `%s: `) ist wortgleich zu V7.  *Annahme*: die Formatwechsel stammen aus der MUTOS-Fassung
  des Programms (Hex-Ausgabe); belegt ist nur, dass sie die Bytes erzeugen.
* Ohne Modell, mit Diskettenbibliothek: Eigencode-Zaehlung ist unbrauchbar, weil `fread`/`fwrite` (Glied `rdwr`) vor dem ersten starken Treffer (`fopen` 0x242) liegen und als Eigencode
  zaehlen (189 gegen 111 Befehle; gemessen im ersten Lauf).  Abhilfe: `userspace/libc_alt/size.members.zusatz` (`+ rdwr 0162 0242 exp=_fread@0162,_fwrite@01CA src=G`, wie `ls`: `_fwrite` bei +0x68).
* Mit `--c2emu --libc alt`: **4048 von 4048 Byte gleich**, Kopf gleich.  R4 2x.
* libc-Teil: `size.members` (24 Glieder + `rdwr`), G-Glieder `endopen` und `rdwr` (224 B), Archiv `userspace/libc_alt/size/libc_alt.a`; Rundlauf: 0 Glieder abweichend.

## Aussagekraft

Wie bei den Wurzelprogrammen (`README.md`, Abschnitt "Stand und Aussagekraft"): bewiesen ist *C-Quelle + ausgelieferter Compiler + die genannten Regeln = Originalbytes*; der libc-Teil
ist zum grossen Teil aus dem Original-Abbild gewonnen (A/G) und belegt keine Herkunft.  Der Eigencode beider Programme braucht nur R4/R5, keine neue Regel.
`size`: die V7-Herkunft des Textes ist durch die Meldungstexte und die Struktur belegt, die drei Abweichungen sind durch die Zeichenketten bzw. den Header belegt.

Tests: `pipeline.py --check wc|size` ok; `pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped.
