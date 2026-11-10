# cmd A1: echo, pwd, rmdir, mkdir (Plan 44, Stufe 1)

Alles *gemessen* (2026-11-10, Branch `us-cmd-a1`), soweit nicht als *Annahme* markiert.  Alle vier Programme der Diskette `cmd` (`bin/NAME`)
sind **ganzdatei bytegleich (G)**.  Befehl je Programm (nach `libc_alt.py members NAME`, `quelle NAME`, `bau NAME`):

    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s     # "=> BYTE-IDENTICAL"

| Programm | Abbild (Kopf ausgenommen) | Datei | Aussage | Eigencode-Quelle | c2-Modell (Stellen) | G-Glieder |
|----------|---------------------------|-------|---------|------------------|---------------------|-----------|
| echo | 2152 B (text 1986, data 166, bss 1040) | 2168 B | G | V7 `echo.c` unveraendert | R4 1 | `fputs` |
| pwd | 3444 B (3134/310/1630) | 3460 B | G | V7 `pwd.c`, 2 Include-Zeilen geaendert | R1 5, R2 2 | keine |
| rmdir | 4144 B (3630/514/1040) | 4160 B | G | V7 `rmdir.c`, 1 Include-Zeile geaendert | R1 4, R4 1 | keine |
| mkdir | 3934 B (3562/372/1080) | 3950 B | G | V7 `mkdir.c` unveraendert | R1 7, R4 1 | keine |

## Herkunft
* Der Eigencode ist V7-Text (`original/unix-v7/usr/src/cmd/NAME.c`); ohne c2-Modell bleiben nur die Regelstellen (Befehlsvergleich Eigencode: pwd 169 von 172,
  mkdir 198 von 202 Befehlen gleich *ohne* Modell-Treffer 159/183 -- die Zahlen des Berichts "matching (without c2 model)" gelten fuer die Variante mit shipped-libc).
* pwd, rmdir: `/usr/include` der Diskette hat kein `sys/param.h` und kein `sys/dir.h`; wie bei `ls` stehen die V7-Header flach auf `/mnt`
  und der Quelltext schreibt `#include "param.h"` bzw. `"dir.h"` (Kommentar im Quelltext).  Das aendert den Code nicht (gemessen: bytegleich).
  Der erste Versuch mit `<sys/param.h>` scheiterte: `Can't find include file sys/param.h` (`-I/mnt` kennt keine Unterverzeichnisse).
* Neue c2-Regeln: **keine**.  Verwendet wurden nur R1, R2, R4 (Stellenzahlen oben).  `pipeline.py` hat nur die vier `PROGRAMME`-Zeilen bekommen,
  `uspace.py` ist unveraendert, daher keine Regressionsgefahr fuer die elf Wurzelprogramme (nicht neu gebaut; *Annahme* aus der unveraenderten Regeldatei).

## Aussagekraft (wie in README, Punkt 5)
* Der libc-Teil stammt aus `userspace/libc_alt/*` (init-Archiv `A`, ausgelieferte `libc.a` `S`, Luecken `G`).  Er belegt keine Herkunft.
  Ohne `--libc alt` (ausgelieferte libc.a) ist keines der vier Programme bytegleich: Kopf weicht ab (echo 1968 statt 1986 Byte Text; pwd 4486/3134; rmdir 4976/3630;
  mkdir 4908/3562), weil die Originale mit der alten libc (stdio `doprnt`, `flsbuf`, `malloc`) gelinkt sind.
* **echo**: `fputs` (80 B, V7 `stdio/fputs.c`) liegt vor dem ersten starken libc-Treffer (`flsbuf` 015C) und zaehlte zuerst als Eigencode
  (408 statt 376 Befehle; Bericht: ein Differenzblock "delete ... JP cret; CALL csv ..."). Es ist ein G-Glied aus dem Original-Abbild
  (`userspace/libc_alt/echo.members.zusatz`, wie `getpass` bei `login`); `libc_alt.py bau echo` meldet `structure equals shipped member: no`,
  d. h. das Original-`fputs` ist nicht das der ausgelieferten `libc.a`.  Das Glied ist *aus dem Abbild gewonnen*; sein Text beweist keine Herkunft.
  Der Eigencode von echo (0x30..0x10C) ist V7-Text.
* Die Regeln R1/R2/R4 sind je an wenigen Stellen belegt (siehe README: Modell, kein Lauf des alten c2).

## Pruefung
`pipeline.py --check NAME` fuer alle vier: OK; `pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped.
