# Herkunftsvergleich (maschinell erzeugt)

Parameter: k=5, w=4, Stufe `abs`, Schwelle 50%.  Werte: token-gewichtetes Mittel der besten Funktionstreffer (`wmean`), in Klammern Funktionen mit sim >= Schwelle / alle Funktionen, `gl.Name` = davon Funktionen mit namensgleichem Treffer >= Schwelle; `sim` = (Containment MUTOS-in-Ref + Ref-in-MUTOS) / 2.

## Referenzen

* `v7`: 89 Dateien, 403 Funktionen
* `s3pdp`: 114 Dateien, 463 Funktionen
* `s3vax`: 105 Dateien, 403 Funktionen

## Matrix Modul x Quelle (Funktionsebene)

| Modul | Fkt | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| alloc.c | 7 | 1433 | 88% (7/7, gl.Name 7) alloc.c | 69% (7/7, gl.Name 7) alloc.c | 72% (7/7, gl.Name 7) alloc.c |
| bio.c | 19 | 2547 | 81% (17/19, gl.Name 17) bio.c | 65% (15/19, gl.Name 14) bio.c | 64% (15/19, gl.Name 15) bio.c |
| clock.c | 1 | 524 | 64% (1/1, gl.Name 1) clock.c | 41% (0/1, gl.Name 0) - | 41% (0/1, gl.Name 0) - |
| dev0.c | 11 | 2092 | 25% (2/11, gl.Name 0) tm.c | 18% (1/11, gl.Name 0) ht.c | 18% (1/11, gl.Name 0) ht.c |
| fio.c | 8 | 875 | 85% (6/8, gl.Name 6) fio.c | 63% (4/8, gl.Name 4) fio.c | 63% (4/8, gl.Name 4) fio.c |
| iget.c | 8 | 1501 | 89% (8/8, gl.Name 8) iget.c | 65% (7/8, gl.Name 7) iget.c | 74% (8/8, gl.Name 7) iget.c |
| lp.c | 7 | 1409 | 18% (0/7, gl.Name 0) - | 24% (0/7, gl.Name 0) - | 24% (0/7, gl.Name 0) - |
| machdep.c | 4 | 312 | 33% (2/4, gl.Name 1) fakemx.c | 29% (1/4, gl.Name 0) subr.c | 11% (1/4, gl.Name 0) subr.c |
| main.c | 3 | 563 | 84% (3/3, gl.Name 3) main.c | 49% (1/3, gl.Name 1) main.c | 48% (2/3, gl.Name 2) main.c |
| malloc.c | 2 | 384 | 85% (2/2, gl.Name 2) malloc.c | 85% (2/2, gl.Name 2) malloc.c | 82% (2/2, gl.Name 2) malloc.c |
| nami.c | 1 | 743 | 87% (1/1, gl.Name 1) nami.c | 64% (1/1, gl.Name 1) nami.c | 64% (1/1, gl.Name 1) nami.c |
| pipe.c | 8 | 1092 | 95% (8/8, gl.Name 8) pipe.c | 33% (4/8, gl.Name 4) pipe.c | 42% (4/8, gl.Name 4) pipe.c |
| prf.c | 5 | 355 | 100% (5/5, gl.Name 5) prf.c | 80% (4/5, gl.Name 3) prf.c | 80% (4/5, gl.Name 3) prf.c |
| rdwri.c | 4 | 874 | 80% (4/4, gl.Name 4) rdwri.c | 42% (0/4, gl.Name 0) - | 51% (2/4, gl.Name 2) rdwri.c |
| rk.c | 13 | 928 | 35% (3/13, gl.Name 2) rk.c | 20% (3/13, gl.Name 3) rk.c | 13% (1/13, gl.Name 0) subr.c |
| sig.c | 10 | 1567 | 82% (10/10, gl.Name 9) sig.c | 73% (8/10, gl.Name 8) sig.c | 72% (9/10, gl.Name 8) sig.c |
| slp.c | 11 | 2105 | 88% (11/11, gl.Name 10) slp.c | 58% (8/11, gl.Name 7) slp.c | 49% (7/11, gl.Name 6) slp.c |
| subr.c | 7 | 927 | 85% (7/7, gl.Name 7) subr.c | 77% (7/7, gl.Name 7) subr.c | 78% (6/7, gl.Name 6) subr.c |
| sys1.c | 8 | 3017 | 64% (6/8, gl.Name 6) sys1.c | 44% (4/8, gl.Name 4) sys1.c | 43% (4/8, gl.Name 4) sys1.c |
| sys2.c | 11 | 1331 | 89% (11/11, gl.Name 10) sys2.c | 68% (9/11, gl.Name 8) sys2.c | 68% (9/11, gl.Name 8) sys2.c |
| sys3.c | 8 | 1298 | 87% (7/8, gl.Name 7) sys3.c | 61% (6/8, gl.Name 6) sys3.c | 66% (6/8, gl.Name 6) sys3.c |
| sys4.c | 24 | 1740 | 83% (21/24, gl.Name 21) sys4.c | 58% (13/24, gl.Name 13) sys4.c | 57% (13/24, gl.Name 13) sys4.c |
| text.c | 10 | 470 | 74% (10/10, gl.Name 2) fakemx.c | 74% (10/10, gl.Name 2) subr.c | 40% (9/10, gl.Name 1) subr.c |
| trap.c | 3 | 771 | 48% (2/3, gl.Name 2) trap.c | 32% (2/3, gl.Name 1) cat.c | 26% (2/3, gl.Name 1) machdep.c |
| tty.c | 11 | 956 | 29% (4/11, gl.Name 0) kl.c | 21% (0/11, gl.Name 0) - | 19% (0/11, gl.Name 0) - |
| tty2.c | 20 | 4732 | 34% (7/20, gl.Name 3) tty.c | 17% (0/20, gl.Name 0) - | 18% (0/20, gl.Name 0) - |
| ureg.c | 3 | 185 | 76% (3/3, gl.Name 1) fakemx.c | 17% (1/3, gl.Name 0) subr.c | 28% (2/3, gl.Name 0) subr.c |
| buf.h | 0 | 118 | - | - | - |
| callo.h | 0 | 34 | - | - | - |
| conf.h | 0 | 219 | - | - | - |
| dir.h | 0 | 22 | - | - | - |
| file.h | 0 | 62 | - | - | - |
| filsys.h | 0 | 76 | - | - | - |
| ino.h | 0 | 47 | - | - | - |
| inode.h | 0 | 136 | - | - | - |
| map.h | 0 | 33 | - | - | - |
| mbx.h | 0 | 38 | - | - | - |
| mount.h | 0 | 33 | - | - | - |
| param.h | 0 | 356 | - | - | - |
| proc.h | 0 | 141 | - | - | - |
| reg.h | 0 | 72 | - | - | - |
| systm.h | 0 | 211 | - | - | - |
| text.h | 0 | 63 | - | - | - |
| tty.h | 0 | 214 | - | - | - |
| types.h | 0 | 48 | - | - | - |
| user.h | 0 | 385 | - | - | - |
| user_ext.h | 0 | 113 | - | - | - |
| conf.c | 0 | 762 | - | - | - |
| sysent.c | 0 | 587 | - | - | - |

## Matrix Modul x Quelle (Dateiebene, beste Referenzdatei)

| Modul | v7 | s3pdp | s3vax |
|---|---|---|---|
| alloc.c | 87% alloc.c | 69% alloc.c | 72% alloc.c |
| bio.c | 77% bio.c | 59% bio.c | 56% bio.c |
| clock.c | 58% clock.c | 37% clock.c | 36% clock.c |
| dev0.c | 50% partab.c | 50% partab.c | 50% partab.c |
| fio.c | 87% fio.c | 65% fio.c | 65% fio.c |
| iget.c | 89% iget.c | 65% iget.c | 77% iget.c |
| lp.c | 11% tty.c | 23% lp.c | 23% lp.c |
| machdep.c | 20% machdep.c | 23% machdep.c | 7% machdep.c |
| main.c | 79% main.c | 44% main.c | 44% main.c |
| malloc.c | 83% malloc.c | 83% malloc.c | 59% malloc.c |
| nami.c | 83% nami.c | 61% nami.c | 62% nami.c |
| pipe.c | 72% pipe.c | 27% pipe.c | 27% pipe.c |
| prf.c | 100% prf.c | 62% prf.c | 62% prf.c |
| rdwri.c | 81% rdwri.c | 38% rdwri.c | 46% rdwri.c |
| rk.c | 26% mem.c | 19% rk.c | 11% sys.c |
| sig.c | 77% sig.c | 69% sig.c | 66% sig.c |
| slp.c | 85% slp.c | 59% slp.c | 45% slp.c |
| subr.c | 71% subr.c | 58% subr.c | 64% subr.c |
| sys1.c | 64% sys1.c | 49% sys1.c | 47% sys1.c |
| sys2.c | 86% sys2.c | 65% sys2.c | 65% sys2.c |
| sys3.c | 83% sys3.c | 52% sys3.c | 57% sys3.c |
| sys4.c | 83% sys4.c | 57% sys4.c | 58% sys4.c |
| text.c | 45% text.c | 45% text.c | 27% text.c |
| trap.c | 51% fakemx.c | 29% trap.c | 23% trap.c |
| tty.c | 25% kl.c | 15% kl.c | 13% cons.c |
| tty2.c | 32% tty.c | 17% partab.c | 17% partab.c |
| ureg.c | 34% prim.c | 9% subr.c | 14% machdep.c |
| buf.h | 71% buf.h | 50% buf.h | 50% buf.h |
| callo.h | 66% callo.h | 88% callo.h | 88% callo.h |
| conf.h | 55% conf.h | 63% conf.h | 63% conf.h |
| dir.h | 54% dir.h | 54% dir.h | 54% dir.h |
| file.h | 47% file.h | 51% file.h | 51% file.h |
| filsys.h | 94% filsys.h | 78% filsys.h | 78% filsys.h |
| ino.h | 84% ino.h | 88% ino.h | 88% ino.h |
| inode.h | 61% inode.h | 60% inode.h | 60% inode.h |
| map.h | 28% map.h | 71% map.h | 71% map.h |
| mbx.h | - | - | - |
| mount.h | 62% mount.h | 24% mount.h | 24% mount.h |
| param.h | 52% param.h | 44% param.h | 44% param.h |
| proc.h | 75% proc.h | 65% proc.h | 65% proc.h |
| reg.h | - | 55% reg.h | 55% reg.h |
| systm.h | 49% systm.h | 49% systm.h | 49% systm.h |
| text.h | 78% text.h | 63% text.h | 63% text.h |
| tty.h | 29% tty.h | 7% tty.h | 7% tty.h |
| types.h | 29% types.h | 36% types.h | 36% types.h |
| user.h | 74% user.h | 62% user.h | 62% user.h |
| user_ext.h | - | - | - |
| conf.c | 34% partab.c | 34% partab.c | 34% partab.c |
| sysent.c | 2% sysent.c | 1% sysent.c | 1% sysent.c |

## Funktionen je Modul

### alloc.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| alloc | 2F48 | 261 | 86% alloc.c:alloc | 74% alloc.c:alloc | 78% alloc.c:alloc |
| free | 3086 | 174 | 81% alloc.c:free | 81% alloc.c:free | 83% alloc.c:free |
| badblock | 316A | 35 | 100% alloc.c:badblock | 100% alloc.c:badblock | 100% alloc.c:badblock |
| ialloc | 319E | 361 | 89% alloc.c:ialloc | 55% alloc.c:ialloc | 58% alloc.c:ialloc |
| ifree | 335A | 50 | 89% alloc.c:ifree | 55% alloc.c:ifree | 55% alloc.c:ifree |
| getfs | 339E | 97 | 95% alloc.c:getfs | 74% alloc.c:getfs | 77% alloc.c:getfs |
| update | 3400 | 204 | 92% alloc.c:update | 72% alloc.c:update | 76% alloc.c:update |

### bio.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| bread | 57D4 | 62 | 81% bio.c:bread | 81% bio.c:bread | 81% bio.c:bread |
| breada | 581A | 171 | 89% bio.c:breada | 77% bio.c:breada | 77% bio.c:breada |
| bwrite | 58F0 | 90 | 94% bio.c:bwrite | 82% bio.c:bwrite | 82% bio.c:bwrite |
| bdwrite | 594A | 45 | 100% bio.c:bdwrite | 77% bio.c:bdwrite | 77% bio.c:bdwrite |
| bawrite | 5984 | 13 | 100% bio.c:bawrite | 71% bio.c:bawrite | 71% bio.c:bawrite |
| brelse | 599A | 161 | 100% bio.c:brelse | 79% bio.c:brelse | 82% bio.c:brelse |
| incore | 5A22 | 56 | 100% bio.c:incore | 65% bio.c:incore | 65% bio.c:incore |
| getblk | 5A64 | 269 | 92% bio.c:getblk | 84% bio.c:getblk | 84% bio.c:getblk |
| geteblk | 5B70 | 142 | 100% bio.c:geteblk | 62% bio.c:getblk~ | 95% bio.c:geteblk |
| iowait | 5BFC | 34 | 100% bio.c:iowait | 69% bio.c:iowait | 69% bio.c:iowait |
| notavail | 5C2E | 39 | 100% bio.c:notavail | 67% bio.c:notavail | 80% bio.c:notavail |
| iodone | 5C62 | 36 | 84% bio.c:iodone | 100% bio.c:iodone | 100% bio.c:iodone |
| clrbuf | 5C86 | 31 | 59% bio.c:clrbuf | 20% machdep.c:bcopy~ | 59% bio.c:clrbuf |
| mapalloc | 5CAE | 38 | 0% -:None~ | 6% tt0.c:ttioctl~ | 6% tt0.c:ttioctl~ |
| mapstart | 5CF6 | 73 | 15% pk0.c:pkaccept~ | 21% hp.c:hpclr~ | 22% hp.c:hpclr~ |
| swap | 5D4A | 390 | 71% bio.c:swap | 42% bio.c:swap | 37% bio.c:swap |
| bflush | 5F10 | 76 | 84% bio.c:bflush | 84% bio.c:bflush | 84% bio.c:bflush |
| physio | 5F56 | 317 | 74% bio.c:physio | 65% bio.c:physio | 42% bio.c:physio |
| geterror | 60A8 | 30 | 100% bio.c:geterror | 100% bio.c:geterror | 100% bio.c:geterror |

### clock.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| clock | 2842 | 448 | 64% clock.c:clock | 41% clock.c:clock | 41% clock.c:clock |

### dev0.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| fdopen | 7E16 | 96 | 8% acct.c:compress~ | 14% lp.c:lpclose~ | 14% lp.c:lpclose~ |
| fdclose | 7E94 | 64 | 15% ht.c:htclose~ | 12% tt0.c:ttin~ | 12% tt0.c:ttin~ |
| fdsub | 7F00 | 123 | 62% tm.c:tcommand~ | 55% ht.c:hcommand~ | 55% ht.c:hcommand~ |
| fdstrategy | 7F94 | 57 | 20% rk.c:rkstrategy~ | 19% rk.c:rkstrategy~ | 13% ht.c:htstrategy~ |
| fdstart | 7FDC | 478 | 18% dsort.c:disksort~ | 18% hs.c:hsstrategy~ | 18% ht.c:htstrategy~ |
| fdintr | 821A | 448 | 15% dsort.c:disksort~ | 11% ht.c:htstrategy~ | 11% ht.c:htstrategy~ |
| fdadj | 8468 | 81 | 7% sys2.c:rdwr~ | 6% nami.c:uchar~ | 6% ht.c:htintr~ |
| fdread | 84E4 | 27 | 22% hp.c:hpread~ | 18% sys2.c:copen~ | 18% sys2.c:copen~ |
| fdwrite | 851C | 27 | 20% mx2.c:mxwrite~ | 20% sys2.c:copen~ | 20% sys2.c:copen~ |
| fdphys | 8554 | 54 | 18% dh.c:dhopen~ | 20% tm.c:tmphys~ | 19% ht.c:htphys~ |
| fdioctl | 85B0 | 307 | 51% fakemx.c:mpxchan~ | 19% trace.c:trioctl~ | 19% trace.c:trioctl~ |

### fio.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| getf | 2AD4 | 41 | 33% fio.c:getf | 33% fio.c:getf | 33% fio.c:getf |
| closef | 2B06 | 218 | 85% fio.c:closef | 33% fio.c:closef | 33% fio.c:closef |
| openi | 2C0C | 100 | 78% fio.c:openi | 46% fio.c:openi | 46% fio.c:openi |
| access | 2C8C | 145 | 100% fio.c:access | 100% fio.c:access | 100% fio.c:access |
| owner | 2D0A | 58 | 100% fio.c:owner | 100% fio.c:owner | 100% fio.c:owner |
| suser | 2D48 | 26 | 46% fio.c:access~ | 46% fio.c:access~ | 46% fio.c:access~ |
| ufalloc | 2D62 | 62 | 100% fio.c:ufalloc | 83% fio.c:ufalloc | 83% fio.c:ufalloc |
| falloc | 2D9A | 91 | 83% fio.c:falloc | 75% fio.c:falloc | 75% fio.c:falloc |

### iget.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| iget | 1122 | 320 | 88% iget.c:iget | 57% iget.c:iget | 57% iget.c:iget |
| iexpand | 126A | 99 | 97% iget.c:iexpand | 25% iget.c:iupdat~ | 76% iget.c:iread~ |
| iput | 12FE | 96 | 91% iget.c:iput | 76% iget.c:iput | 76% iget.c:iput |
| iupdat | 1372 | 271 | 81% iget.c:iupdat | 51% iget.c:iupdat | 71% iget.c:iupdat |
| itrunc | 14F6 | 154 | 89% iget.c:itrunc | 95% iget.c:itrunc | 95% iget.c:itrunc |
| tloop | 15B2 | 130 | 95% iget.c:tloop | 83% iget.c:tloop | 95% iget.c:tloop |
| maknode | 1652 | 98 | 94% iget.c:maknode | 84% iget.c:maknode | 84% iget.c:maknode |
| wdir | 16C2 | 87 | 87% iget.c:wdir | 64% iget.c:wdir | 64% iget.c:wdir |

### lp.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| lpopen | 6444 | 114 | 7% pk0.c:pkreset~ | 25% lp.c:lpopen | 25% lp.c:lpopen |
| lpclose | 64DA | 124 | 7% tm.c:tmclose~ | 18% tm.c:tmphys~ | 17% ht.c:htphys~ |
| lpwrite | 6570 | 247 | 26% mkconf.c:equal~ | 29% lp.c:lpwrite | 29% lp.c:lpwrite |
| lpcanon | 6668 | 398 | 25% mkconf.c:equal~ | 32% lp.c:lpoutput~ | 32% lp.c:lpoutput~ |
| lpoutput | 680E | 89 | 10% dz.c:dzscan~ | 11% du.c:duxint~ | 11% tt0.c:ttout~ |
| lpintr | 6874 | 148 | 12% mx2.c:rmdata~ | 11% bio.c:iodone~ | 11% bio.c:iodone~ |
| lpxfer | 690A | 69 | 8% pk0.c:pkaccept~ | 12% du.c:duxint~ | 11% kmc.c:kmcset~ |

### machdep.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| startup | 34F6 | 114 | 23% machdep.c:startup | 21% machdep.c:startup | 14% hp.c:hpclr~ |
| kstub | 35AC | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| sendsig | 35AE | 93 | 55% machdep.c:sendsig | 49% machdep.c:sendsig | 7% sys1.c:setregs~ |
| sigret | 3630 | 64 | 14% machdep.c:sendsig~ | 14% machdep.c:sendsig~ | 10% machdep.c:sendsig~ |

### main.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| main | 0674 | 180 | 83% main.c:main | 74% main.c:main | 57% main.c:main |
| iinit | 0746 | 112 | 75% main.c:iinit | 40% main.c:iinit | 52% main.c:iinit |
| binit | 07D2 | 147 | 93% main.c:binit | 26% main.c:binit | 33% main.c:binit |

### malloc.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| malloc | 2DF0 | 106 | 71% malloc.c:malloc | 71% malloc.c:malloc | 71% malloc.c:malloc |
| mfree | 2E5A | 230 | 91% malloc.c:mfree | 91% malloc.c:mfree | 87% malloc.c:mfree |

### nami.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| namei | 36A0 | 686 | 87% nami.c:namei | 64% nami.c:namei | 64% nami.c:namei |

### pipe.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| uchar | 39BA | 30 | 100% nami.c:uchar | 100% nami.c:uchar | 100% nami.c:uchar |
| pipe | 39E2 | 152 | 100% pipe.c:pipe | 60% pipe.c:pipe | 60% pipe.c:pipe |
| readp | 3A68 | 127 | 69% pipe.c:readp | 16% sys2.c:rdwr~ | 16% sys2.c:rdwr~ |
| writep | 3AFE | 169 | 100% pipe.c:writep | 26% trap.c:nosys~ | 26% trap.c:nosys~ |
| plock | 3BBE | 31 | 100% pipe.c:plock | 100% pipe.c:plock | 100% pipe.c:plock |
| prele | 3BE0 | 31 | 100% pipe.c:prele | 100% pipe.c:prele | 100% pipe.c:prele |
| getc | 3BFC | 160 | 100% prim.c:getc | 11% slp.c:wakeup~ | 26% clist.c:getc |
| putc | 3C80 | 168 | 100% prim.c:putc | 11% alloc.c:badblock~ | 43% clist.c:putc |

### prf.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| printf | 1724 | 148 | 100% prf.c:printf | 100% prf.c:printf | 100% prf.c:printf |
| printn | 17E0 | 47 | 100% prf.c:printn | 15% kl.c:klioctl~ | 15% slp.c:expand~ |
| panic | 1856 | 26 | 100% prf.c:panic | 100% prf.c:panic | 100% prf.c:panic |
| prdev | 187A | 19 | 100% prf.c:prdev | 100% prf.c:prdev | 100% prf.c:prdev |
| deverror | 18A4 | 24 | 100% prf.c:deverror | 50% prf.c:deverr~ | 50% prf.c:deverr~ |

### rdwri.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| readi | 2460 | 304 | 83% rdwri.c:readi | 46% rdwri.c:readi | 50% rdwri.c:readi |
| writei | 25FE | 264 | 86% rdwri.c:writei | 45% rdwri.c:writei | 47% rdwri.c:writei |
| min | 2766 | 18 | 100% rdwri.c:min | 24% fio.c:ufalloc~ | 24% fio.c:ufalloc~ |
| iomove | 2780 | 169 | 65% rdwri.c:iomove | 32% rdwri.c:pimove~ | 62% rdwri.c:iomove |

### rk.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| mmread | 69CE | 100 | 45% mem.c:mmread | 9% dh.c:dhclose~ | 10% mem.c:mmread |
| mmwrite | 6A52 | 116 | 41% mem.c:mmwrite | 10% rdwri.c:writei~ | 10% rdwri.c:writei~ |
| rkopen | 6ADA | 21 | 31% dn.c:dnopen~ | 26% sys2.c:copen~ | 28% mem.c:mmread~ |
| rkclose | 6AFE | 2 | 100% fakemx.c:sdata~ | 100% rk.c:rkclose | 100% subr.c:nulldev~ |
| rkstrategy | 6B06 | 86 | 42% rk.c:rkstrategy | 48% rk.c:rkstrategy | 23% ht.c:htstrategy~ |
| rkstart | 6B60 | 108 | 13% rl.c:rlstart~ | 11% rk.c:rkaddr~ | 10% errlog.c:logberr~ |
| rkintr | 6BCA | 139 | 24% rk.c:rkintr | 17% rk.c:rkintr | 7% hp.c:hpstrategy~ |
| rkread | 6C52 | 14 | 100% rk.c:rkread | 59% rk.c:rkread | 22% dmr.c:dmrread~ |
| rkwrite | 6C70 | 14 | 100% rk.c:rkwrite | 62% rk.c:rkwrite | 0% -:None~ |
| syopen | 6C8E | 36 | 44% sys.c:syopen | 14% err.c:erropen~ | 14% err.c:erropen~ |
| syread | 6CC6 | 18 | 20% sys.c:syread | 17% sys.c:syread | 17% sys.c:syread |
| sywrite | 6CEC | 18 | 20% sys.c:sywrite | 17% sys.c:sywrite | 17% sys.c:sywrite |
| syioctl | 6D12 | 24 | 36% sys.c:sysioctl~ | 32% sys.c:syioctl | 32% sys.c:syioctl |

### sig.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| signal | 0B3A | 42 | 81% sig.c:signal | 82% sig.c:signal | 82% sig.c:signal |
| psignal | 0B6E | 59 | 100% sig.c:psignal | 44% sig.c:psignal | 44% sig.c:psignal |
| issig | 0BC8 | 71 | 100% sig.c:issig | 65% sig.c:issig | 65% sig.c:issig |
| stop | 0C18 | 93 | 92% sig.c:stop | 93% sig.c:stop | 93% sig.c:stop |
| psig | 0C7C | 172 | 83% sig.c:psig | 88% sig.c:psig | 82% sig.c:psig |
| fsig | 0D2C | 43 | 100% sig.c:fsig | 79% sig.c:fsig | 79% sig.c:fsig |
| core | 0D56 | 196 | 71% sig.c:core | 54% sig.c:core | 50% sig.c:core |
| grow | 0E38 | 7 | 55% pk1.c:pklive~ | 0% -:None~ | 50% slp.c:newproc~ |
| ptrace | 0E42 | 194 | 80% sig.c:ptrace | 79% sig.c:ptrace | 79% sig.c:ptrace |
| procxmt | 0F12 | 461 | 79% sig.c:procxmt | 74% sig.c:procxmt | 74% sig.c:procxmt |

### slp.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| sleep | 18D4 | 178 | 96% slp.c:sleep | 69% slp.c:sleep | 69% slp.c:sleep |
| wakeup | 19A8 | 110 | 100% slp.c:wakeup | 13% slp.c:swtch~ | 14% slp.c:swtch~ |
| setrq | 1A30 | 57 | 100% slp.c:setrq | 100% slp.c:setrq | 100% slp.c:setrq |
| setrun | 1A7C | 88 | 100% slp.c:setrun | 24% slp.c:setrun | 24% slp.c:setrun |
| setpri | 1AE8 | 49 | 74% slp.c:setpri | 10% slp.c:sched~ | 10% slp.c:sched~ |
| sched | 1B34 | 386 | 92% slp.c:sched | 62% slp.c:sched | 50% slp.c:sched |
| swapin | 1CCA | 182 | 80% slp.c:swapin | 80% slp.c:swapin | 21% slp.c:swapin |
| qswtch | 1D8E | 13 | 100% slp.c:qswtch | 53% slp.c:qswtch | 53% slp.c:qswtch |
| swtch | 1DA4 | 254 | 81% slp.c:swtch | 57% slp.c:swtch | 58% slp.c:swtch |
| newproc | 1EA2 | 499 | 83% slp.c:newproc | 60% slp.c:newproc | 54% slp.c:newproc |
| expand | 20F6 | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |

### subr.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| bmap | 20FE | 426 | 79% subr.c:bmap | 67% subr.c:bmap | 74% subr.c:bmap |
| passc | 236C | 78 | 89% subr.c:passc | 82% subr.c:passc | 82% subr.c:passc |
| cpass | 23CA | 87 | 87% subr.c:cpass | 80% subr.c:cpass | 80% subr.c:cpass |
| nodev | 242A | 8 | 100% subr.c:nodev | 100% subr.c:nodev | 100% subr.c:nodev |
| nulldev | 2438 | 2 | 100% subr.c:nulldev | 100% subr.c:nulldev | 100% subr.c:nulldev |
| bcopy | 243A | 29 | 100% subr.c:bcopy | 100% machdep.c:bcopy | 20% bio.c:clrbuf~ |
| timeout | 2A4C | 151 | 97% clock.c:timeout | 96% clock.c:timeout | 96% clock.c:timeout |

### sys1.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| exece | 41AC | 629 | 63% sys1.c:exece | 48% sys1.c:exece | 54% sys1.c:exece |
| getxfile | 44B6 | 868 | 55% sys1.c:getxfile | 25% trap.c:nosys~ | 25% trap.c:nosys~ |
| setregs | 47E2 | 230 | 61% sys1.c:setregs | 57% sys1.c:setregs | 47% sys1.c:setregs |
| rexit | 48A6 | 22 | 46% sys1.c:rexit | 46% sys1.c:rexit | 46% sys1.c:rexit |
| exit | 48C4 | 279 | 80% sys1.c:exit | 66% sys1.c:exit | 57% sys1.c:exit |
| wait | 49F6 | 249 | 83% sys1.c:wait | 57% sys1.c:wait | 57% sys1.c:wait |
| fork | 4AD4 | 263 | 78% sys1.c:fork | 51% sys1.c:fork | 50% sys1.c:fork |
| sbreak | 4BD0 | 55 | 23% sys1.c:sbreak | 23% sys1.c:sbreak | 26% sys1.c:sbreak |

### sys2.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| read | 51B2 | 7 | 100% sys2.c:read | 100% sys2.c:read | 100% sys2.c:read |
| write | 51C4 | 7 | 100% sys2.c:write | 100% sys2.c:write | 100% sys2.c:write |
| rdwr | 51D6 | 217 | 80% sys2.c:rdwr | 54% sys2.c:rdwr | 54% sys2.c:rdwr |
| open | 52BE | 37 | 64% sys2.c:open | 64% sys3.c:stat~ | 64% sys3.c:stat~ |
| creat | 52F2 | 76 | 84% sys2.c:creat | 45% sys3.c:stat~ | 45% sys3.c:stat~ |
| copen | 5344 | 162 | 100% sys2.c:open1~ | 50% sys2.c:copen | 50% sys2.c:copen |
| close | 53FE | 41 | 100% sys2.c:close | 100% sys2.c:close | 100% sys2.c:close |
| seek | 542C | 118 | 68% sys2.c:seek | 61% sys2.c:seek | 61% sys2.c:seek |
| link | 54AA | 161 | 100% sys2.c:link | 92% sys2.c:link | 92% sys2.c:link |
| mknod | 5556 | 85 | 89% sys2.c:mknod | 51% sys2.c:mknod | 51% sys2.c:mknod |
| saccess | 55AE | 127 | 100% sys2.c:saccess | 100% sys2.c:saccess | 100% sys2.c:saccess |

### sys3.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| fstat | 3D6A | 48 | 86% sys3.c:fstat | 75% sys3.c:fstat | 75% sys3.c:fstat |
| stat | 3DA2 | 41 | 100% sys3.c:stat | 89% sys3.c:stat | 89% sys3.c:stat |
| stat1 | 3DDC | 165 | 90% sys3.c:stat1 | 60% sys3.c:stat1 | 82% sys3.c:stat1 |
| dup | 3EB2 | 148 | 74% sys3.c:dup | 46% sys3.c:dup | 46% sys3.c:dup |
| smount | 3F3C | 297 | 89% sys3.c:smount | 57% sys3.c:smount | 62% sys3.c:smount |
| sumount | 4080 | 184 | 91% sys3.c:sumount | 62% sys3.c:sumount | 62% sys3.c:sumount |
| getmdev | 413C | 74 | 92% sys3.c:getmdev | 82% sys3.c:getmdev | 82% sys3.c:getmdev |
| exec | 4198 | 15 | 29% sys1.c:exec | 29% sys1.c:exec | 29% sys1.c:exec |

### sys4.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| gtime | 4C14 | 10 | 100% sys4.c:gtime | 0% -:None~ | 0% -:None~ |
| ftime | 4C24 | 90 | 51% sys4.c:ftime | 14% sys4.c:times~ | 14% sys4.c:times~ |
| stime | 4C94 | 49 | 34% sys4.c:stime | 38% sys4.c:stime | 19% sys4.c:stime |
| setuid | 4CC6 | 49 | 86% sys4.c:setuid | 77% sys4.c:setuid | 77% sys4.c:setuid |
| getuid | 4CF4 | 22 | 100% sys4.c:getuid | 21% sys4.c:getuid | 21% sys4.c:getuid |
| setgid | 4D0C | 41 | 82% sys4.c:setgid | 71% sys4.c:setgid | 71% sys4.c:setgid |
| getgid | 4D32 | 22 | 100% sys4.c:getgid | 20% sys4.c:getgid | 20% sys4.c:getgid |
| getpid | 4D4A | 26 | 100% sys4.c:getpid | 34% sys4.c:getpid | 34% sys4.c:getpid |
| sync | 4D6A | 6 | 100% sys4.c:sync | 100% sys4.c:sync | 100% sys4.c:sync |
| nice | 4D76 | 72 | 91% sys4.c:nice | 73% sys4.c:nice | 73% sys4.c:nice |
| unlink | 4DBC | 211 | 92% sys4.c:unlink | 87% sys4.c:unlink | 87% sys4.c:unlink |
| chdir | 4E84 | 10 | 100% sys4.c:chdir | 100% sys4.c:chdir | 100% sys4.c:chdir |
| chroot | 4E96 | 16 | 100% sys4.c:chroot | 50% sys4.c:chroot | 50% sys4.c:chroot |
| chdirec | 4EB0 | 93 | 74% sys4.c:chdirec | 74% sys4.c:chdirec | 74% sys4.c:chdirec |
| chmod | 4F1C | 86 | 100% sys4.c:chmod | 83% sys4.c:chmod | 83% sys4.c:chmod |
| chown | 4F78 | 54 | 100% sys4.c:chown | 57% sys4.c:chown | 57% sys4.c:chown |
| ssig | 4FB0 | 79 | 91% sys4.c:ssig | 48% sys4.c:ssig | 48% sys4.c:ssig |
| kill | 501C | 167 | 92% sys4.c:kill | 39% sys4.c:kill | 39% sys4.c:kill |
| times | 50B0 | 33 | 46% sys4.c:times | 40% sys4.c:times | 40% sys4.c:times |
| profil | 50D6 | 52 | 45% sys4.c:profil | 45% sys4.c:profil | 45% sys4.c:profil |
| alarm | 5100 | 37 | 61% sys4.c:alarm | 52% sys4.c:alarm | 52% sys4.c:alarm |
| pause | 511E | 15 | 100% sys4.c:pause | 100% sys4.c:pause | 100% sys4.c:pause |
| umask | 5132 | 33 | 78% sys4.c:umask | 59% sys4.c:umask | 59% sys4.c:umask |
| utime | 5150 | 81 | 92% sys4.c:utime | 48% sys4.c:utime | 48% sys4.c:utime |

### text.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| xswap | 562C | 183 | 67% text.c:xswap | 67% text.c:xswap | 20% text.c:xswap |
| xfree | 5702 | 135 | 80% text.c:xfree | 80% text.c:xfree | 61% text.c:xfree |
| xalloc | 5790 | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xstub1 | 579C | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xlock | 57A4 | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xunlock | 57AC | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xccdec | 57B4 | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xumount | 57BC | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xrele | 57C4 | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| xstub2 | 57CC | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |

### trap.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| trap | 087A | 645 | 48% trap.c:trap | 32% trap.c:trap | 25% trap.c:nosys~ |
| nosys | 0B2A | 8 | 100% trap.c:nosys | 54% cat.c:catopen~ | 53% machdep.c:chksize~ |
| nullsys | 0B38 | 2 | 100% trap.c:nullsys | 100% trap.c:nullsys | 100% trap.c:nullsys |

### tty.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| tcopen | 60CC | 141 | 51% fakemx.c:mpxchan~ | 20% err.c:erropen~ | 20% err.c:erropen~ |
| tcclose | 616C | 18 | 62% kl.c:klclose~ | 18% vpmb.c:vpmwake~ | 18% vpmb.c:vpmwake~ |
| tcread | 618E | 14 | 33% dc.c:dcread~ | 0% -:None~ | 0% -:None~ |
| tcwrite | 61B0 | 14 | 33% dc.c:dcread~ | 0% -:None~ | 0% -:None~ |
| tcxint | 61D2 | 44 | 53% dc.c:dcxint~ | 15% dza.c:dzaproc~ | 15% dza.c:dzaproc~ |
| tcrint | 620E | 26 | 39% kl.c:klrint~ | 22% vpmb.c:vpmwake~ | 22% vpmb.c:vpmwake~ |
| tcioctl | 623C | 30 | 67% kl.c:klioctl~ | 23% bio.c:geterror~ | 23% bio.c:geterror~ |
| ttstart | 6274 | 203 | 22% dz.c:dzstart~ | 30% tt0.c:ttout~ | 30% tt0.c:ttout~ |
| ttxfer | 633A | 66 | 8% dh.c:dhstop~ | 6% tty.c:ttinit~ | 6% tty.c:ttinit~ |
| putchar | 6384 | 167 | 10% mx1.c:challoc~ | 22% kl.c:putchar | 13% cons.c:putchar |
| ttyinit | 6432 | 16 | 9% rl.c:rlio~ | 11% hp.c:hpopen~ | 11% hp.c:hpopen~ |

### tty2.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| ttyopen | 6D44 | 69 | 74% tty.c:ttyopen | 27% tty.c:ttopen~ | 27% tty.c:ttopen~ |
| ttinit | 6D8C | 62 | 9% pk0.c:pkreset~ | 7% tty.c:ttinit | 7% tty.c:ttinit |
| ttyclose | 6DD0 | 25 | 55% tty.c:ttyclose | 28% kl.c:klclose~ | 23% tty.c:ttclose~ |
| ioctl | 6DF0 | 143 | 63% tty.c:ioctl | 38% sys3.c:ioctl | 44% sys3.c:ioctl |
| ttioctl | 6E7A | 560 | 50% fakemx.c:mpxchan~ | 30% kl.c:klclose~ | 26% dl.c:dlwrite~ |
| ttywait | 715C | 59 | 67% tty.c:wflushtty~ | 19% tty.c:ttwrite~ | 19% tty.c:ttwrite~ |
| ttyflush | 71A4 | 93 | 67% tty.c:flushtty~ | 12% kmc.c:kmcdclr~ | 12% kmc.c:kmcdclr~ |
| ttyinput | 7222 | 866 | 25% tty.c:ttyinput | 13% du.c:duxint~ | 12% bio.c:breada~ |
| ttycol | 75B2 | 197 | 17% mx2.c:zero~ | 7% tt0.c:ttin~ | 8% text.c:xswap~ |
| ttyecho | 769A | 140 | 26% mkconf.c:equal~ | 14% kl.c:klioctl~ | 14% bio.c:incore~ |
| ttyrub | 772E | 335 | 25% mkconf.c:equal~ | 13% kl.c:klioctl~ | 13% iget.c:tloop~ |
| unputc | 78A8 | 171 | 37% prim.c:getc~ | 9% subr.c:cpass~ | 30% clist.c:getcf~ |
| bitset | 7948 | 33 | 8% dz.c:dzmodem~ | 13% bio.c:incore~ | 13% bio.c:incore~ |
| ttyspec | 797A | 107 | 22% sig.c:procxmt~ | 21% sig.c:procxmt~ | 23% sig.c:procxmt~ |
| ttflow | 79E0 | 77 | 30% tty.c:ttyblock~ | 13% dh.c:dhproc~ | 11% dz.c:dzproc~ |
| ttyoutput | 7A34 | 494 | 34% tty.c:ttyoutput | 21% tt0.c:ttxput~ | 21% tt0.c:ttxput~ |
| ttrstrt | 7C4A | 14 | 42% tty.c:ttrstrt | 17% kl.c:klproc~ | 17% cons.c:conproc~ |
| ttkick | 7C62 | 35 | 68% tty.c:ttstart~ | 23% dmb.c:dmbload~ | 23% dmb.c:dmbload~ |
| ttread | 7C90 | 298 | 24% tty.c:ttread | 10% mem.c:mmread~ | 9% tty.c:canon~ |
| ttwrite | 7DA6 | 128 | 26% mkconf.c:equal~ | 14% tty.c:ttwrite | 14% tty.c:ttwrite |

### ureg.c

| Funktion | Marke | Token | v7 | s3pdp | s3vax |
|---|---|---|---|---|---|
| cinit | 3D04 | 72 | 85% prim.c:cinit | 10% subr.c:bmap~ | 11% machdep.c:sendsig~ |
| sureg | 3D40 | 2 | 100% fakemx.c:sdata~ | 100% subr.c:nulldev~ | 100% subr.c:nulldev~ |
| estabur | 3D42 | 31 | 55% fakemx.c:mpxchan~ | 26% ureg.c:checkur~ | 64% machdep.c:chksize~ |

