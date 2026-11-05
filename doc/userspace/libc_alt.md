# libc_alt -- Rueckbau-libc der Originalprogramme

Alles *gemessen*, soweit nicht als *Annahme* markiert.  Werkzeug: `tools/userspace/libc_alt.py`; Quellen/Bibliothek: `userspace/libc_alt/`;
Test: `tests/test_userspace_libc_alt.py` (`gast`, Gastlauf nur mit `USERSPACE_GAST=1`).

## Ergebnis
* **`/etc/init` ganzdatei bytegleich** (4978 B, Kopf und alle 4962 Byte Abbild) mit
  `python3 -I tools/userspace/pipeline.py alles init --c2emu --libc alt --ist neu_c2_s` (Eigencode mit c2-Modell R1-R3, libc-Teil aus `libc_alt`).
* 32 Glieder des libc-Teils von init (`userspace/libc_alt/init.members`) als as-Quellen `userspace/libc_alt/init/*.s`; Rundlauf
  `.s -> Gast-as -u -> Objekt -> wie ld relokiert -> Bytes == Original-Glied` fuer **alle 32 Glieder gleich** (Text, Daten, BSS, Commons, Exporte).
  Bibliothek `userspace/libc_alt/init/libc_alt.a` (10710 B, Reihenfolge wie im Programm, ohne Gleitkomma-Teil: `doprnt` 472 B, `ffltpr`-Stub 10 B).

## Aufruf
    python3 -I tools/userspace/pipeline.py holen init
    python3 -I tools/userspace/pipeline.py karte init --ablegen
    python3 -I tools/userspace/libc_alt.py quelle init    # z8kdis -> .s (Host)
    python3 -I tools/userspace/libc_alt.py bau init       # Gast-as, Waechter, libc_alt.a
    python3 -I tools/userspace/libc_alt.py pruefen init   # Waechter auf den Objekten des letzten Baus (Host)
    python3 -I tools/userspace/libc_alt.py tabelle init   # Glied x Programm (Host, ~10 s)
    python3 -I tools/userspace/libc_alt.py cbau init [GLIED...]   # C-Quellen userspace/libc_alt/c/*.c
    python3 -I tools/userspace/pipeline.py bau NAME --c2emu --libc alt ...   # NAME zuerst, dann init-Archiv vor -lc

## Dialekt-Befunde (as, gemessen)
* Externe Symbole: `X name PR;` (mit `;`, wie `cret` in `cc -S`) bzw. `X name W|A[%n B]`; ohne Deklaration `undefined symbol`.
* BSS: `$SECTION BSS_B` / `I` / `label:` / `$REL $+%n` / `$SDEFAULT`; Commons (`_sibuf`) = externe `A[..]`-Deklaration.
* `as -u` laesst undefinierte Namen als Externe zu.  Ein Modulname gleich einem Prozedurnamen verliert das Symbol (`csv`): Modul heisst `NAME_`.
* Mehrere Einstiege an einer Adresse: leere Prozeduren `G n PR / E / end n` vor der echten (`ffltpr`: `pfloat pscien pgen`).
* Die Gast-Sitzung braucht `>asm.out;as ...;cat asm.out >X.o` (kein `mv` im Gast).

## Glieder des libc-Teils von init (Text-Stand: Gast-as-Rundlauf)
| Glied | Quelle | Ergebnis |
|-------|--------|----------|
| printf, strout, isatty, stty, data | C (V7-Text unveraendert, `userspace/libc_alt/c/`) | **bytegleich** (Gast `cc -O -S`, c2-Modell, `as`); strout nutzt R4 1x |
| flsbuf (`_flsbuf fflush _cleanup fclose fseek`) | C (V7 flsbuf.c + fseek.c, Abweichungen unten) | Text noch **nicht** gleich: 4 Differenzbloecke |
| malloc (`malloc free realloc`) | C (V7 malloc.c, `GRANULE 256` statt 0, `register` in realloc) | Text noch **nicht** gleich: Rest 3 Stellen (`ld r2,r3 ; ld r10,r2` gegen `ld r10,r3`, Namensunterschiede der statischen Variablen sind Auswertungsartefakt) |
| doprnt | nur .s (Original war V7-PDP-11-Assembler `doprnt.s`; hier compilierter C-Code, Neuschrieb nach Listing **offen**) | .s bytegleich |
| ffltpr, cuexit, setjmp, csv, cerror, sbrk, signal, fork, Systemaufrufe (access .. write) | .s (V7 Assembler) | .s bytegleich |

Abweichungen der C-Fassungen vom V7-Text (belegt durch das Listing des Originals): `_flsbuf` kennt `stdin` (`_sibuf`) und `_IORW` mit `fseek`/`_IOREAD`-Rueckstellung;
`fclose` setzt `_base = NULL` immer; `malloc` hat `GRANULE 256`.  Diese Fassungen sind *Annahme* bis der Text gleich ist.

### Neue c2/c1-Regeln der Bibliothek (`libc_regeln`, ab R20; R1-R10 in `uspace.py`, R11-R19 reserviert fuer sh)
R20 `x = y = expr` ueber r2; R21 Zuweisungswert neu geladen; R22 `test MEM` -> `test r0`; R23 `ldl` hinter dem Sprung wiederholt;
R24 vorzeichenbehaftete Division durch Zweierpotenz als `sda` (alter c1); R25 `ld r2,MEM ; ld r3,r2` -> `ld r3,MEM`.
Stellenzahl im letzten Lauf: flsbuf R4 1, R5 2, R23 1; malloc R4 1, R5 1, R24 1, R25 1 (R20-R22 treffen nicht oder nur ohne Wirkung; ungesichert).

## Glied x Programm (Wurzeldiskette, `libc_alt.py tabelle init`, Text-Suche mit Relokationswildcards)
`=` gleich Diskettenglied, `A` gleich dem aus init rueckgebauten Glied (alte libc), `~NN` aehnlich (NN %, anderer Compilerstand), `.` nicht gebunden.
* **Alt in allen stdio-Programmen** (init, cat, date, ls, login, stty, mount, umount): `doprnt`, `strout`, `flsbuf`, `malloc` = `A`  (sh bindet sie nicht).
* **Gleich Diskette** in allen Programmen: `cuexit`, `csv`, `cerror`, `ioctl`, `lseek`, `write`, `sbrk`, `stty`, meist `isatty`, `close`, `open`, `read`, `creat`.
* Glieder mit `~` (z. B. `access chmod chown kill stat time` in cat/ls/login ...): dieselbe Quelle, anderer Stand der Relokationsworte/Aufrufziele -- in der Tabelle als aehnlich gewertet, einzeln nicht nachgemessen.
* Nur andere Programme: `getpw*`, `ctime`, `qsort`, `strcpy` .. (login, ls, date) -- gleich Diskette (`=`) soweit gefunden; `fgets`, `getpass`, `getgrent`, `atoi`, `crypt`, `execvp`, `sleep` (~87-98 %) abweichend, **nicht** in libc_alt aufgenommen.
Vollstaendige Tabelle: `python3 -I tools/userspace/libc_alt.py tabelle init`.

## Weitere Programme mit `--libc alt` (ganzdatei NICHT erreicht)
Gebunden wurde zuerst das eigene, dann das init-Archiv.  Eigencode: umount 143/144, mount 191/192 (je 1 Block: `perror`-Aufruf, Glied fehlt in libc_alt), ls 671/677, date 383/393, login 401/504 (Eigencode bricht ab: Programm bindet mehr alte Glieder).
libc-Teil weicht ab, weil Glieder fehlen (`perror`, `strlen`, `fgetc`, `fopen`, `getpw*` ...): umount 828/892, mount 828/949, ls 1288/1795, date 795/1330, login 1682/2457, cat 556/1065.
Folge: fuer diese Programme braucht es `libc_alt` aus **deren** Abbild (`NAME.members` + `quelle/bau`); Mechanik steht, Mitgliederlisten stehen aus.

## Offen
* `NAME.members` fuer login, mount, umount, cat, date, ls, sh ... (Grenzen aus der `.namen`-Datei, `exp=` fuer Neuglieder).
* C-Rest: Text von `flsbuf`, `malloc`; `doprnt` in C schreiben.
* Das Original-`strlen`/`perror` usw. unterscheiden sich vom Diskettenglied (`~`): Ursache (c2-Stand) nicht je Glied belegt.
