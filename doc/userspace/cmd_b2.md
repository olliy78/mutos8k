# Auftrag B2 (Plan 44): `ncheck` und `icheck` der Diskette `cmd`

Stand 2026-11-10, Branch `us-cmd-b2`.  Alles *gemessen* mit den genannten Befehlen (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Aussage | Datei | Abbild | Quelle | c2-Regeln (Stellen) |
|----------|---------|-------|--------|--------|---------------------|
| `etc/ncheck` | **G** ganzdatei bytegleich | 5078 B | 5062 B (text 4650, data 412, bss 25770) | V7 `ncheck.c`, 3 Abweichungen (+ Header-Pfade) | R1 3, R4 7, R5 1, R7 1, R38 1 (B1), R42 2, R43 1, R45 1 |
| `etc/icheck` | **G** ganzdatei bytegleich | 6542 B | 6526 B (text 5758, data 768, bss 5788) | V7 `icheck.c`, 3 Abweichungen (+ Header-Pfade) | R1 1, R4 9, R5 1, R38 2 (B1), R42 3, R46 3, R47 1, R48 1 |

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
| R42 | `ld rN,SRC ; ld MEM,rN ; test rN` -> `test MEM` (SRC Speicher/`@r`; ein Aufrufergebnis behaelt `test r2`, R33; nicht, wenn B1s R37 dieselbe Stelle trifft) | ncheck 2, icheck 3 |
| R43 | Ausnahme von R2: `inc rK,#n(n>1) ; ldb rlN,@rK ; xorb ; ldb @rM,rlN` behaelt das XORB (Elementkopie `h_name[k] = d_name[k]`) | ncheck 1 |
| R44 | **entfallen**: dieselbe Form (`cp M,#k ; jr ; ld rN,M` -> `ld rN,r0`) deckt B1s R38 (`cmd_b1.md`); gemessen: ncheck 1x, icheck 2x durch R38 erzeugt, R44 hat 0 Treffer, Code entfernt | - |
| R45 | `xor r2,r2 ; div rr2,#k` -> `exts rr2 ; div ..` (unsigned `i%HSIZE` rechnet das Original vorzeichenbehaftet) | ncheck 1 |
| R46 | `ldl rr0,rr2 ; cpl rr2,M ; jr cc` -> `cpl rr0,M` (Sonderform mit `ldl rr2,rr0` danach und `pushl rr0`: 1 der 3 Stellen) | icheck 3 |
| R47 | `divl rq0,rr4 ; ld rN,r3` -> `ld r2,r3 ; ld rN,r2` (wie R26) | icheck 1 |
| R48 | `ld MEM,rN ..; ld r0,rN ; cp rN,X` -> `ld r0,MEM ; cp r0,X` | icheck 1 |

R42 und R45 treffen auch `sh` (18298 statt 18296 B, gemessen) und sind in `C2_AUS["sh"]` abgeschaltet.
Vor dem Einbau der Regeln wurden alle 20 vorhandenen `neu.s` der Hauptkopie auf dem Host durchgerechnet: die neuen Regeln trafen kein anderes Programm ausser `sh` (R42/R45, siehe oben).

## Regression (gemessen, `cmp` gegen `work/NAME.orig`)

Ganzdatei bytegleich nach den Regeln: sync getty cat date ls stty init login mount umount echo pwd rmdir mkdir wc size chmod kill cp ln (`alles NAME --c2emu [--libc alt]`);
`sh`: `bau sh --c2emu --variante v7fix` zuerst 18298 B (R42 1x, R45 1x griffen), nach Abschalten in `C2_AUS["sh"]` 18296 B und `cmp` gegen `work/sh.orig` gleich.

## Aussagekraft

Wie in `README.md` (Stand und Aussagekraft): C-Quelle + ausgelieferter Compiler + Regeln = Originalbytes; die Regeln sind ein Modell.  Mit R42-R48 sind es hier ungewoehnlich viele
Einzelstellen-Regeln; ein Teil (R46) betrifft Long-Vergleiche, die vorher nicht vorkamen.  Der libc-Teil ist aus dem Abbild gewonnen und belegt keine Herkunft.

## Wechselwirkung mit B1 (R35-R39, `cmd_b1.md`), gemessen nach dem Merge

B2s Regeln hiessen urspruenglich R35-R41, nach dem Merge mit B1 R42-R48.  Beim ersten Regressionslauf nach dem Merge war `dcheck` nicht bytegleich: R42 (+R48) griff an der Stelle von B1s R37 (`R37` 0 statt 1 Treffer).
R42 wird deshalb uebersprungen, wenn `test rN ; jr cc ; ld r0,rN` folgt.  B1s R38 erzeugt dieselbe Form wie B2s R44; R44 hatte danach 0 Treffer und wurde entfernt (Nummer bleibt frei).
Endstand: alle 24 Programme plus `sh` bytegleich (siehe Bericht).

## Regressionsstand nach dem Merge (gemessen 2026-11-10, Endstand des Codes, Gast-Neubau, `cmp` gegen `work/NAME.orig`)

Ganzdatei bytegleich (alle neu gebaut, 12:03-12:36): sync getty cat date ls stty init login mount umount echo pwd rmdir mkdir wc size chmod kill cp ln clri mknod dcheck ncheck icheck;
`sh` (`holen sh`, `bau sh --c2emu --variante v7fix`): `v7fix_c2.bin` 18296 B, `cmp` gegen `work/sh.orig` gleich (12:36).  `pytest tests/test_userspace_pipeline.py -q`: 7 passed, 2 skipped.
