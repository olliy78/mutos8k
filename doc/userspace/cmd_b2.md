# Auftrag B2 (Plan 44): `ncheck` und `icheck` der Diskette `cmd`

Stand 2026-11-10, Branch `us-cmd-b2`.  Alles *gemessen* mit den genannten Befehlen (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Aussage | Datei | Abbild | Quelle | c2-Regeln (Stellen) |
|----------|---------|-------|--------|--------|---------------------|
| `etc/ncheck` | **G** ganzdatei bytegleich | 5078 B | 5062 B (text 4650, data 412, bss 25770) | V7 `ncheck.c`, 3 Abweichungen (+ Header-Pfade) | R1 3, R4 7, R5 1, R7 1, R35 2, R36 1, R37 1, R38 1 |
| `etc/icheck` | **G** ganzdatei bytegleich | 6542 B | 6526 B (text 5758, data 768, bss 5788) | V7 `icheck.c`, 3 Abweichungen (+ Header-Pfade) | R1 1, R4 9, R5 1, R35 3, R37 2, R39 3, R40 1, R41 1 |

Befehle (je Programm):

    python3 -I tools/userspace/pipeline.py holen NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s
    cmp userspace/NAME/work/NAME.orig userspace/NAME/work/bau/neu_c2_s.bin     # leer = gleich

Header: `sys/{param,inode,ino,dir,filsys,fblk}.h` aus `original/unix-v7/usr/include` in der `PROGRAMME`-Liste, in der Quelle als `"x.h"` eingebunden.
Alle Abweichungen vom V7-Text stehen im Quelltext mit `/* Differs from V7: ... */` (geprueft mit `diff original/unix-v7/usr/src/cmd/NAME.c userspace/NAME/NAME.c`).

## Abweichungen vom V7-Text (durch Bytes belegt)

* **Beide:** `NI` 8 statt 16 (der Originalaufruf `bread(.., itab, 0x1000)` und die Schleife `i += 8`/`j < 64`; `itab` ist 4096 B).
* **ncheck:** `HSIZE` 1103 statt 2503 (`DIV #0x44F`; `htab` endet bei der Adresse von `aflg`).
* **Beide:** `sblock` ist im Original 512 B gross (`PUSH #0x200` beim Lesen, `itab` liegt 0x200 hinter `sblock`), `struct filsys` des V7-Headers nur 440 B.
  Nachgebildet mit `char sbpad[BSIZE-sizeof(struct filsys)]` hinter `sblock` und `BSIZE` statt `sizeof(sblock)` bei `bread`.  *Annahme:* die MUTOS-Fassung hat
  ein grosseres `filsys` bzw. eine andere Deklaration; belegt ist nur, dass dieses Layout die Bytes erzeugt.
* **icheck:** `n = ndirect + nindir + niindir + niiindir` (V7-Text addiert `niindir` zweimal; das Original adressiert die vier Zaehler `2BF0..2BFC`).
* Alle `#include <sys/x.h>` -> `"x.h"` (`-I/mnt` kennt keine Unterverzeichnisse).

## libc-Teil

`userspace/libc_alt/{ncheck,icheck}.members`, Archive `userspace/libc_alt/{ncheck,icheck}/libc_alt.a`; Glieder `atol`, `l3` als G (je 136 B), sonst A/S.
Rundlauf `libc_alt.py bau`: 0 Glieder abweichend.  Behelfe (Handeingriffe):
* `doprnt` ist hier die kuerzere Fassung (`LD R4,R2` statt `EXTSL RQ4`, 474 B statt 472), Quelle S; die `code=`-Eintraege der Sprungtabelle mussten um 2 verschoben werden
  (`ncheck`: `089C,08A2,08B8`; `icheck`: `0CCC,0CD2,0CE8`), sonst meldet `libc_alt.py quelle` Datenworte im Code.
* `userspace/ncheck/k.txt`: falschen vorgeschlagenen Eintrag `code 1000` (mitten in `realloc`) entfernt.

## Neue c2-Regeln (`uspace.c2_emu_s`, Modell des alten c2, kein Lauf desselben; je Regel nur wenige Stellen = schwach belegt)

| Regel | Wirkung | Stellen |
|-------|---------|---------|
| R35 | `ld rN,SRC ; ld MEM,rN ; test rN` -> `test MEM` (SRC Speicher/`@r`; ein Aufrufergebnis behaelt `test r2`, R33) | ncheck 2, icheck 3 |
| R36 | Ausnahme von R2: `inc rK,#n(n>1) ; ldb rlN,@rK ; xorb ; ldb @rM,rlN` behaelt das XORB (Elementkopie `h_name[k] = d_name[k]`) | ncheck 1 |
| R37 | R4-Form `ld r0,MEM ; cp r0,#k ; jr cc` + `ld rX,MEM` -> `ld rX,r0` | ncheck 1, icheck 2 |
| R38 | `xor r2,r2 ; div rr2,#k` -> `exts rr2 ; div ..` (unsigned `i%HSIZE` rechnet das Original vorzeichenbehaftet) | ncheck 1 |
| R39 | `ldl rr0,rr2 ; cpl rr2,M ; jr cc` -> `cpl rr0,M` (Sonderform mit `ldl rr2,rr0` danach und `pushl rr0`: 1 der 3 Stellen) | icheck 3 |
| R40 | `divl rq0,rr4 ; ld rN,r3` -> `ld r2,r3 ; ld rN,r2` (wie R26) | icheck 1 |
| R41 | `ld MEM,rN ..; ld r0,rN ; cp rN,X` -> `ld r0,MEM ; cp r0,X` | icheck 1 |

R35 und R38 treffen auch `sh` (18298 statt 18296 B, gemessen) und sind in `C2_AUS["sh"]` abgeschaltet.
Vor dem Einbau der Regeln wurden alle 20 vorhandenen `neu.s` der Hauptkopie auf dem Host durchgerechnet: die neuen Regeln trafen kein anderes Programm ausser `sh` (R35/R38, siehe oben).

## Regression (gemessen, `cmp` gegen `work/NAME.orig`)

Ganzdatei bytegleich nach den Regeln: sync getty cat date ls stty init login mount umount echo pwd rmdir mkdir wc size chmod kill cp ln (`alles NAME --c2emu [--libc alt]`);
`sh`: `bau sh --c2emu --variante v7fix` zuerst 18298 B (R35 1x, R38 1x griffen), nach Abschalten in `C2_AUS["sh"]` 18296 B und `cmp` gegen `work/sh.orig` gleich.

## Aussagekraft

Wie in `README.md` (Stand und Aussagekraft): C-Quelle + ausgelieferter Compiler + Regeln = Originalbytes; die Regeln sind ein Modell.  Mit R35-R41 sind es hier ungewoehnlich viele
Einzelstellen-Regeln; ein Teil (R39) betrifft Long-Vergleiche, die vorher nicht vorkamen.  Der libc-Teil ist aus dem Abbild gewonnen und belegt keine Herkunft.
