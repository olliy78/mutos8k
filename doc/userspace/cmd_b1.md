# Auftrag B1 (Plan 44): `clri`, `mknod`, `dcheck` der Diskette `cmd` (`etc/`)

Stand 2026-11-10, Branch `us-cmd-b1`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Aussage | Datei | Abbild | Quelle | c2-Regeln (Stellen) |
|----------|---------|-------|--------|--------|---------------------|
| `etc/clri` | **G** ganzdatei bytegleich | 3574 B | 3558 B (text 3206, data 352, bss 1554) | V7 `clri.c`, 1 Include-Zeile | R1 4, R4 2, **R39 1** |
| `etc/mknod` | **G** ganzdatei bytegleich | 3954 B | 3938 B (text 2964, data 974, bss 1040) | V7 `mknod.c` unveraendert | R4 3 |
| `etc/dcheck` | **G** ganzdatei bytegleich | 4514 B | 4498 B (text 4074, data 424, bss 5734) | V7 `dcheck.c` mit 4 Abweichungen | R4 4, **R35 1, R36 1, R37 1, R38 1** |

Befehle je Programm: `pipeline.py holen/karte NAME --ablegen`, `libc_alt.py members/quelle/bau NAME`, dann
`python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s` ("=> BYTE-IDENTICAL"); zusaetzlich `cmp work/NAME.orig work/bau/neu_c2_s.bin` (gleich, auch nach dem Einfuegen der Kommentare in die Quellen).
`pipeline.py --check mknod` ok.

## Quellen (Abweichungen vom V7-Text, im Quelltext jeweils kommentiert)
* Header: `/usr/include` der Diskette hat `sys/types.h`, aber kein `sys/ino.h`, `param.h`, `inode.h`, `dir.h`, `filsys.h`, `fblk.h`.  Sie stehen in `PROGRAMME` (aus `original/unix-v7/usr/include/sys`) und werden flach als `"x.h"` eingebunden;
  `<sys/types.h>` bleibt.  clri: `"ino.h"`; dcheck: `param inode ino dir filsys fblk`.  Kein V7-Header haengt von einem anderen per `#include` ab.
* dcheck `NI 8` statt 16: der Bau mit 16 hat bss 9758 B, das Original 5734; `itab` ist im Original 4096 B (`PUSH #%1000` beim `bread`).  Mit 8 gleiche Groesse (*gemessen*; die Ursache im MUTOS-Original ist *Annahme*: kleinerer Puffer).
* dcheck `sblock`: im Original 512 B (`PUSH #%0200` vor `&sblock`, `itab` direkt dahinter), die V7-`struct filsys` des Kernels (`kernel/h/filsys.h`, gemessen) hat 440 B.  Behelf: `char sbrest[BSIZE-sizeof(struct filsys)]` hinter `sblock` und `bread(1, &sblock, BSIZE)`
  statt `sizeof(sblock)`.  Wie das Original dies im Quelltext hatte, ist unbekannt (*Annahme*: z. B. eine Fuellung in einem eigenen `filsys.h`).  Es gibt das gleiche Abbild, belegt keine Herkunft.

## Neue c2-Regeln (`uspace.c2_emu_s`; Modell, kein Lauf des alten c2; alle schwach belegt, je eine Stelle)
* **R39** (clri 1x): Ausnahme zu R5: `xorb rhN,rhN ; ld rA,rN ; test rN` bleibt (`while (c = *s++)` mit Registervariable `c`).  Nur fuer Ziel `rA` in r8..r13: ohne die Einschraenkung zerstoert sie `cat` (dort `ld r2,r3 ; test r3` -> `test r2`, gemessen: 1 Byte Abweichung, erster Lauf).
* **R35** (dcheck 1x): `ldb @r2,#%FF` -> `ld r3,#%FF ; ldb @r2,rl3` (`ecount[kno] = 0377`).
* **R36** (dcheck 1x): `and rB,#%FF ; ld rA,rB ; cp rB,M` -> `cp rA,M` (`ip->di_nlink == (ecount[i] & 0377)`).
* **R37** (dcheck 1x): `ld M,rN ; test rN ; jr cc ; ld r0,rN ; cp rN,X` -> `test M ; jr cc ; ld r0,M ; cp r0,X` (das Original arbeitet auf der Speicherkopie von `kno`); R4 nutzt danach R0 weiter.
* **R38** (dcheck 1x): `cp M,#k ; jr cc ; ld rN,M` -> `... ld rN,r0` (R4-Folge in `bmap`).
`tests/test_userspace_pipeline.py`: nur die erwartete Zaehlerliste um R35-R39 erweitert.

## Regression der bisherigen Programme (nach den Regeln, je `alles NAME --c2emu [--libc alt] --ist neu_c2_s` + `cmp` gegen `work/NAME.orig`)
sync getty cat date ls stty init login mount umount echo pwd rmdir mkdir wc size chmod kill cp ln: alle bytegleich (cat erst nach der Einschraenkung von R39, vorher 4071/4072 Byte).
sh (`bau sh --c2emu --variante v7fix`, `cmp` gegen `work/sh.orig`): bytegleich, 18296 B.

## libc-Teil / Behelfe
* `clri`: `atoi` als Lueckenglied (G, 114 B).  `mknod`: `perror` (G, 124 B), `errlst`, `strlen`, `mknod` aus der Diskettenbibliothek (S).  `dcheck`: `atol`, `l3` (G), `doprnt` aus der Diskettenbibliothek (S; ohne die Gleitkommastelle ist es das Original-`doprnt` dieses Programms, es unterscheidet sich vom `init`-`doprnt` in `EXTSL`/`LD`-Folge) mit handgesetzten `code=065C,0662,0678` in `userspace/libc_alt/dcheck.members`
  (die automatisch erzeugte Datei nannte `065A,0660,0676` und scheiterte mit "z8kdis left data words"), `sync` (S).  Alle Rundlaeufe `libc_alt.py bau`: 0 Glieder abweichend.
* Der libc-Teil ist zum grossen Teil aus dem Abbild gewonnen und belegt keine Herkunft (README, Punkt 5).
