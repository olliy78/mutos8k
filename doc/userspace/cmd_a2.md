# cmd A2: chmod, kill, cp, ln (Plan 44, Stufe 1)

Alles *gemessen* (2026-11-10, Branch `us-cmd-a2`, `K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Alle vier Programme der Diskette `cmd` (`bin/NAME`) sind **ganzdatei bytegleich (G)**.  Befehle je Programm:

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME      # Gast, ~20 s
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s         # "=> BYTE-IDENTICAL"

`cmp userspace/NAME/work/bau/neu_c2_s.bin userspace/NAME/work/NAME.orig` ist fuer alle vier ohne Ausgabe.

| Programm | Datei | Abbild (text/data/bss) | Aussage | Eigencode-Quelle | c2-Modell (Stellen) |
|----------|-------|------------------------|---------|------------------|---------------------|
| chmod | 3710 B | 3694 (3326/368/1074) | G | V7 `chmod.c` unveraendert | R1 2, R4 1, **R33 1** |
| kill | 3808 B | 3792 (2850/942/1040) | G | V7 `kill.c` unveraendert | R4 2, **R32 1** |
| cp | 3592 B | 3576 (3188/388/1612) | G | V7 `cp.c` unveraendert | R1 1, R4 2, R30 2, **R34 1** |
| ln | 4330 B | 4314 (3304/1010/1040) | G | V7 `ln.c` unveraendert | R1 2, R4 4 |

## Ablauf und Befunde
* Ohne Modell, ausgelieferte libc: Kopf weicht ab (libc-Teil 845-960 Befehle im Original, 1281-1440 gebaut: alte libc mit `doprnt` ohne Gleitkomma).
* Mit `libc_alt` und Modell: chmod 1 Differenzblock (`TEST R2` im Original, `TEST R13` gebaut), kill 2 Byte kuerzer (fehlendes `XORB RH4,RH4`), cp 1 Differenzblock (`TEST R2` im Original fehlt im Bau), ln gleich.
* **kill**: `sys_errlist` wird direkt benutzt, nicht ueber `perror`; `libc_alt.py members` fuegt `errlst` nur zusammen mit `perror` ein und hatte die Datenfenster falsch (`printf`: "direct address 0BA4 in no member").  Von Hand in `userspace/libc_alt/kill.members`:
  `doprnt data=0B4C:0B96`, `data data=0B96:0C38`, `errlst 09F6 09F6 data=0C38:0ECE exp=_sys_err@0C38,_sys_ner@0C7E src=S` (Gliedgroesse 0x296 wie bei `ln`); `atoi` ist Lueckenglied (G, 114 B).  Werkzeug unveraendert.
* **ln**: die Karte lieferte einen falschen `code`-Einstieg bei 0B00 (mitten in `realloc`, "nicht kanonisch"), `libc_alt quelle` meldete `malloc: z8kdis left data words`.  `userspace/ln/karte_extra.txt` = `ohne 0B00` behebt das (0 nicht kanonisch).  G-Glied `perror` (124 B, ln.members).
* Header: alle in `/usr/include` der Diskette (`stdio.h`, `signal.h`, `sys/types.h`, `sys/stat.h`); `PROGRAMME`-Zeilen mit leerer Header-Liste.  Kein Quelltext geaendert; die Quellen sind V7 byteweise (Abweichung 0).

## Neue c2-Regeln (`uspace.c2_emu_s`), je **eine Stelle**, schwach belegt (Modell, kein Lauf des alten c2)
* **R32** `xorb rhN,rhN ; cp rN,.. ; jr cc L ; cp rN,..` -> `xorb` vor dem zweiten `cp` wiederholt (Verallgemeinerung von R10 auf `cp`; kill `**argv<'0' || **argv>'9'`).  Trifft auch `sh` (1x, `sh` waere 18298 statt 18296 B): fuer `sh` abgeschaltet (`C2_AUS["sh"]`, eine Zeile in `pipeline.py`; `sh` hat einen anderen c2-Stand).
* **R33** Ausnahme von R5: `call f ; ld rA,r2 ; test r2` behaelt `test r2` (chmod `while (o = what())`).  R5 haette `test r13` daraus gemacht.
* **R34** `ld MEM,rN ; test rN ; jr eq|ne L ; jr mi|pl|lt|ge|gt|le L2` -> `test rN` wird nach dem ersten Sprung wiederholt (cp `while (n = read(..)) { if (n < 0)`).  Erste Fassung ohne die `ld MEM`-Bedingung zerstoerte `getty` (gemessen: `read(); test r2; jr eq; jr pl` bleibt dort ohne zweiten Test, 1152 statt 1150 B); deshalb eng gefasst.
* Quellvarianten wurden **nicht** durchprobiert (die drei Unterschiede sind Codeformen des aelteren c2, V7-Text steht fest); *Annahme*, nicht gemessen.

## Regressionslauf (nach den Regeln)
`alles NAME --c2emu --libc alt --ist neu_c2_s` ("=> BYTE-IDENTICAL"): cat date ls stty init login mount umount echo pwd rmdir mkdir wc size chmod kill cp ln.  `sync` und `getty` ohne `--libc alt`
(wie bisher): beide bytegleich (116 bzw. 1150 B).  `sh`: `bau sh --c2emu --variante v7fix` = 18296 B, `cmp` gegen `sh.orig` gleich (nach Abschalten von R32 fuer `sh`).
Die neuen Regeln feuern in keinem anderen Programm ausser `sh` (R32) und, in der ersten R34-Fassung, `getty`.
`pipeline.py --check chmod|kill|cp|ln`: OK; `pytest tests/test_userspace_pipeline.py -q`: 7 passed, 2 skipped (Test `test_c2_model_rewrites_and_canonicalises` pinnt die Zaehlerliste, um R32-R34 erweitert).

## Aussagekraft
Wie README Punkt 5: libc-Teil weitgehend aus dem Original-Abbild (A/G) oder der ausgelieferten `libc.a` (S) und belegt keine Herkunft; Eigencode = V7-Text + ausgelieferter Compiler + die genannten Regeln.
