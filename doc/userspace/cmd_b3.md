# Auftrag B3 (Plan 44): `mkfs` der Diskette `cmd`

Stand 2026-11-10, Branch `us-cmd-b3`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Aussage | Datei | Abbild | Quelle | c2-Regeln (Stellen) |
|----------|---------|-------|--------|--------|---------------------|
| `etc/mkfs` | **G** ganzdatei bytegleich | 8406 B | 8390 B (text 7714, data 676, bss 2684) | V7 `mkfs.c` mit 5 belegten Abweichungen (Include-Zeilen, `badflag`/`badblk`, `>`) | R1 11, R4 32, R30 1 (alt) + **R35-R45** (neu, nur mkfs) |

Befehle:

    python3 -I tools/userspace/pipeline.py holen mkfs ; ... karte mkfs --ablegen
    python3 -I tools/userspace/libc_alt.py members mkfs && ... quelle mkfs && ... bau mkfs      # Gast, ~40 s
    python3 -I tools/userspace/pipeline.py alles mkfs --c2emu --libc alt --ist neu_c2_s         # "=> BYTE-IDENTICAL"
    cmp userspace/mkfs/work/bau/neu_c2_s.bin userspace/mkfs/work/mkfs.orig                      # ohne Ausgabe

## Quelle: V7 `mkfs.c` und Abweichungen (alle im Quelltext mit `/* Differs from V7: ... */` markiert)

`diff original/unix-v7/usr/src/cmd/mkfs.c userspace/mkfs/mkfs.c` zeigt nur diese Stellen.

1. **Include-Zeilen**: `/usr/include` der Diskette hat kein `sys/param.h ino.h inode.h filsys.h fblk.h dir.h`; die V7-Header liegen flach auf `/mnt`
   (`PROGRAMME`-Headerliste), der Quelltext schreibt `"param.h"` usw. (`-I/mnt` kennt keine Unterverzeichnisse, wie bei `pwd`/`rmdir`/`ls`).
   `sys/types.h`, `stdio.h`, `a.out.h` sind in `/usr/include` und nicht eingetragen.  Die V7-Header selbst haben keine `#include`-Zeilen.
2. **`int badflag = 0;`** (neue Variable): die Originaldaten haben hinter `f_n = 0x01F4`, `f_m = 3` ein weiteres Datenwort 0 (Daten `00 00 01F4 0003 0000 "usage: ..."`;
   mit V7-Quelltext fehlen diese 2 Byte, Datenteil 674 statt 676 B).  Das Wort wird in `main` mit `INC` erhoeht und in `badblk` getestet.
3. **`if(argc == 6) badflag++;`** vor `bflist()`: im Listing `CP 4(R14),#6 ; JR NZ ; INC L1E28,#1` zwischen `ino = 0` (`CLR`) und `CALL bflist`.
4. **`badblk()`**: V7 ist ein Stumpf (`return(0)`).  Das Original (Listing 0x1076..0x10C0) hat einen lokalen 512-Byte-Puffer, testet `badflag`, macht
   `lseek(fsi, bno*512, 0)` und `read(fsi, b, 512)` und liefert 1 bei `!= 512`, sonst 0.  *Annahme*: das ist die MUTOS-Fassung (Pruefung der Bloecke
   mit sechstem Argument); gemessen ist nur, dass dieser Text die Bytes erzeugt.  Ob der Parametername/die Variablennamen so hiessen, ist nicht belegbar (Binary gestrippt).
5. **`if(*aibc > LADDR)`** statt `>=` in `iput` (Listing 0x0FE0: `CP R0,#10 ; JR LE`): kein Indirektblock bei genau 10 Adressen.  Die Schleife davor (`i >= LADDR`) ist wie V7.

Zeichenketten (inkl. `"%s: cannot  open init"` mit zwei Leerzeichen und `"d--777 0 0 $ "`) sind wortgleich zu V7 (`xxd` des Datenteils gegen den Quelltext).
Funktionen: 15, in V7-Reihenfolge (`main cfile gmode getnum getstr rdfs wtfs alloc bfree entry newblk getch bflist iput badblk`).
Der Zusatz `struct inode *mpxip;` aus `inode.h` liegt im BSS (BSS-Groesse stimmt: 2684).

## libc-Teil

`libc_alt.py members mkfs` (27 Glieder, `userspace/libc_alt/mkfs.members`, Archiv `.../mkfs/libc_alt.a`): `A` aus dem init-Archiv, `S` ausgelieferte `libc.a`
(`fopen filbuf findiop`), `G` Lueckenglieder aus dem Original-Abbild (`endopen` 294 B, `atoi` 114 B, `l3` = `ltol3`/`l3tol` 136 B, **`doprnt` 474 B**).
Rundlauf `libc_alt.py bau mkfs`: 0 Glieder abweichend.  Der Libc-Teil belegt keine Herkunft (README, Punkt 5).

**`doprnt` ist hier nicht das Glied der anderen Programme** (dort 472 B, `src=A`): im Original steht an einer Stelle `LD R4,R2 ; LD R5,R4` statt `EXTSL RQ4`
(2 Byte laenger; Befehlsvergleich gegen `ls`-`doprnt`: ein inhaltlicher Block neben Adressverschiebungen).  Die automatische Wahl `src=S` scheiterte
(`z8kdis left data words in the code`, die `code=`-Einstiege waren wegen der 2 Byte um 2 verschoben); von Hand `doprnt 1202 13DC ... code=132C,1332,1348 src=G`
(Behelf, nur `mkfs.members`).  *Annahme*: mkfs wurde mit einer anderen Bibliotheksfassung gelinkt; nicht weiter untersucht.

## c2-Modell: neue Regeln R35-R45 (nur mkfs)

Ohne neue Regeln: nach den Quelltextkorrekturen 26 Differenzbloecke im Eigencode, Libc-Teil gleich.  Alle Bloecke sind Codeformen, die kein Quelltext
beeinflusst (Befehlsmenge gleich, nur Registerwahl/Nachladen).  Die Regeln stehen in `uspace.c2_mkfs_s`, laufen hinter `c2_emu_s` und **nur mit `mkfs=True`**
(`pipeline.py` uebergibt es nur fuer `mkfs`); alle anderen Programme und `libc_alt` rufen `c2_emu_s` unveraendert auf.
Sie sind **Beschreibungen** der Unterschiede (Modell, kein Lauf des alten c2), die meisten an 1-3 Stellen und damit schwach belegt.

| Regel | Stellen | Muster (Ausgabe des ausgelieferten c2 -> Original) |
|-------|---------|-----------------------------------------------------|
| R35 | 5 (+1 `push`/`test` Folgeverwendung je Stelle, 2x) | `ld MEM,rN [;test rN;jr..]; ld r0,MEM; cp r0,#k` -> `ld r0,rN; cp r0,#k`; die naechste `push @SP,rN`/`test rN` hinter der Sprungkette nimmt r0.  Nicht bei Byte-Laden (`xorb` davor): dort laedt das Original aus MEM (1 Stelle, gemessen) |
| R36 | 3 | `cp @rN,#k` -> `ld r0,@rN; cp r0,#k` (R4 fuer register-indirekte Operanden; R4 selbst schliesst sie aus) |
| R37 | 3 | nach `ld r0,MEM; cp r0,#k` ein spaeteres `ld rN,MEM` im selben Block -> `ld rN,r0` |
| R38 | 1 | `mult rr4,#k; ld r4,r5; sub rX,r5` -> `sub rX,r4` |
| R39 | 2 | `call _getnum; ld -N(FP),r3` -> `ld r2,r3; ld -N(FP),r2` |
| R40 | 1 | `ldl MEM,rr4; testl rr4` -> `testl MEM` |
| R41 | 2 | `dp = x; dp += y`: hinter `ld MEM,rN` wird `ld rN,MEM` nachgeladen (entry, iput) |
| R42 | 1 | `ld r4,@r3; sla r4,#4; add r2,r4` -> `...; ld r3,r4; add r2,r3` |
| R43 | 1 | `ld r3,MEM; ..; ld r2,r3; inc @r2,#1` -> `ld r2,MEM` |
| R44 | 1 | `ldl rr2,MEM; ldl DST,rr2; ld r5,#25; exts rr4; extsl rq0; divl` -> `ldl rr2,MEM; nop; nop; nop; ldl DST,rr2; ldl rr2,MEM; ...` (die 3 `NOP` = 6 Byte im Original sind unerklaert; nachgebildet) |
| R45 | 1 | `ldl rr0,rr2; cpl rr2,M; jr; ld r5..; xor r4,r4; cpl rr2,rr4; jr; pushl rr2` -> `cpl rr0,M`, `ldl rr2,rr0` hinter dem ersten `jr`, `pushl rr0` |

Zaehlerstand des letzten Laufs: `R1 11, R4 32, R30 1, R35 5, R36 3, R37 3, R38 1, R39 2, R40 1, R41 2, R42 1, R43 1, R44 1, R45 1`.
Sechs der Regeln (R38, R40, R42-R45) haben **eine** Stelle: kaum mehr als ein beschriebener Unterschied.  Quellvarianten wurden dafuer nicht durchprobiert
(*Annahme*: Codeformen des aelteren c2, der V7-Text steht fest; nur die Abweichungen 2-5 oben waren Quelltext).

## Ergebnis

`alles mkfs --c2emu --libc alt --ist neu_c2_s`: **8390 von 8390 Byte gleich**, Kopf gleich, Eigencode 1327 von 1327 Befehlen, Libc-Teil 1118 von 1118.
`cmp userspace/mkfs/work/bau/neu_c2_s.bin userspace/mkfs/work/mkfs.orig`: gleich.

## Regressionslauf

Nach den Aenderungen an `uspace.py`/`pipeline.py` (`c2_mkfs_s`, Parameter `mkfs`): `alles NAME --c2emu --libc alt --ist neu_c2_s` meldet `=> BYTE-IDENTICAL` fuer
`cat date ls stty init login mount umount echo pwd rmdir mkdir wc size chmod kill cp ln`; `sync` und `getty` (ohne `--libc alt`, wie bisher) ebenfalls;
`sh`: `bau sh --c2emu --variante v7fix` = 18296 B, `cmp` gegen `work/sh.orig` ohne Ausgabe (Zaehler nur R11-R16, keine neuen Regeln).
`pipeline.py --check mkfs` ok; `pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped.

## Aussagekraft

Wie README Punkt 1/2/5.  Bewiesen: *C-Quelle + ausgelieferter Compiler + diese Regeln = Originalbytes*.  Das ist fuer mkfs mit elf zusaetzlichen, programmspezifischen Regeln
erkauft; die Herkunft des Eigencodes (V7 + fuenf Abweichungen) ist davon unabhaengig und durch Listing/Zeichenketten belegt, die libc-Glieder `endopen atoi l3 doprnt` sind aus dem Abbild.
