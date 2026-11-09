# libc_alt -- Rueckbau-libc der Originalprogramme

Alles *gemessen*, soweit nicht als *Annahme* markiert.  Werkzeug: `tools/userspace/libc_alt.py`; Quellen/Bibliothek: `userspace/libc_alt/`;
Test: `tests/test_userspace_libc_alt.py` (`gast`, Gastlauf nur mit `USERSPACE_GAST=1`).

## Ergebnis
* **`/etc/init` ganzdatei bytegleich** (4978 B, Kopf und alle 4962 Byte Abbild); ebenso umount, cat, stty, ls, date (Tabelle unten) mit
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
| malloc (`malloc free realloc`) | C (V7 malloc.c, `GRANULE 256` statt 0, `register` in realloc) | **Text bytegleich** (R24-R26, R31; Namensunterschiede der statischen Variablen im Befehlsvergleich sind Auswertungsartefakt) |
| doprnt | nur .s -- **handgeschriebener Assembler**, kein cc-Erzeugnis (lokale `calr`-Unterprogramme mit Werteuebergabe in r1-r9, rekursiv; Sprungtabelle `jp @r4`; `cpirb`; gemeinsame Schwaenze `jp L069E`).  Eine C-Fassung ist daher nicht moeglich | .s bytegleich |
| ffltpr, cuexit, setjmp, csv, cerror, sbrk, signal, fork, Systemaufrufe (access .. write) | .s (V7 Assembler) | .s bytegleich |

Abweichungen der C-Fassungen vom V7-Text (belegt durch das Listing des Originals): `_flsbuf` kennt `stdin` (`_sibuf`) und `_IORW` mit `fseek`/`_IOREAD`-Rueckstellung;
`fclose` setzt `_base = NULL` immer; `malloc` hat `GRANULE 256`.  Diese Fassungen sind *Annahme* bis der Text gleich ist.

### Herkunftsnachweis: .s-Glieder gegen C-Glieder
* **.s-Glieder** (Quellen `userspace/libc_alt/NAME/*.s`) sind *aus dem Original-Abbild gewonnen* (z8kdis -> as).  Der Rundlauf `.s -> as -> Objekt -> ld-Relokation -> Bytes`
  beweist nur, dass die Zerlegung stimmt, **nicht** die Herkunft des Textes.
* **C-Glieder** (`userspace/libc_alt/c/*.c`: printf, strout, isatty, stty, data, flsbuf, malloc) sind *aus C gebaut* (Gast `cc -O -S` -> c2-Modell -> `as`); bytegleich ist
  ein unabhaengiger Nachweis fuer den C-Text.  Stand: printf, strout, isatty, stty, data bytegleich; flsbuf **Text bytegleich** (824 B); **malloc Text bytegleich** (522 B, 201 Befehle; Gast `cc -O -S`, Modell, `as`).
  Das Neuladen `ld r2,_alloct` nach `ld _alloct,r2` ist **Modellregel R31**: Quelltextvarianten brachten es nicht hervor (leere `ASSERT`-Anweisung, `(alloct = q->ptr = ..)->ptr = ..`,
  getrennte Zuweisungen `q->ptr = ..; alloct = q->ptr;` -- jeweils 200 Befehle, gemessen).
* doprnt ist Assembler im Original, bleibt .s.

### Neue c2/c1-Regeln der Bibliothek (`libc_regeln`, ab R20; R1-R10 in `uspace.py`, R11-R19 reserviert fuer sh)
Die Regeln sind ein **nachgebildetes Modell** des alten c2/c1 aus dem Listing des Originals, **kein Lauf** des echten c2.  Jede Regel ist an **genau einer Stelle**
belegt und damit **schwach belegt** (Stellen im letzten Lauf):
| Regel | Wirkung | Stellen |
|-------|---------|---------|
| R20 | `sub ; ld r2,rN ; ld rA,r2 ; jr mi` bekommt `test rA` | flsbuf 1 |
| R21 | Zuweisungswert wird neu geladen und in r2 getestet | flsbuf 1 |
| R22 | `test MEM` nach `ld r0,MEM` -> `test r0` | flsbuf 1 |
| R23 | `ldl rr2,M` hinter dem Sprung wiederholt | flsbuf 1 |
| R24 | vorzeichenbehaftete Division durch Zweierpotenz als `sda` | malloc 1 |
| R25 | `ld r2,MEM ; ld r3,r2` -> `ld r3,MEM` | malloc 1 |
| R26 | `div rr2,.. ; ld rB,r3` laeuft ueber r2 | malloc 1 |
| R31 | `ld @rX,r2 ; ld MEM,r2 ; ld r3,.. ; set r3,#n ; ld @r2,r3` -> `ld r2,MEM` hinter dem Speichern (verkettete Zuweisung `alloct = q->ptr = ..; alloct->ptr = ..`) | malloc 1 |
Regeln mit 0 Stellen wurden entfernt.

### Regeln im Eigencode ab R30 (`uspace.c2_emu_s`)
Ebenfalls ein **nachgebildetes Modell**, kein Lauf des alten c2; Beleg je Stelle schwach.
| Regel | Wirkung | Stellen |
|-------|---------|---------|
| R30 | Ausnahme von R2: `xorb rhN,rhN ; ldb mem,rlN ; testb rlN` (der gespeicherte Wert einer Zuweisung wird sofort getestet) behaelt das `xorb` (R2 loescht es nur, wenn der Wert nicht weiterverwendet wird) | mount 2 |

## Glied x Programm (Wurzeldiskette, `libc_alt.py tabelle init`, Text-Suche mit Relokationswildcards)
`=` gleich Diskettenglied, `A` gleich dem aus init rueckgebauten Glied (alte libc), `~NN` aehnlich (NN %, anderer Compilerstand), `.` nicht gebunden.
* **Alt in allen stdio-Programmen** (init, cat, date, ls, login, stty, mount, umount): `doprnt`, `strout`, `flsbuf`, `malloc` = `A`  (sh bindet sie nicht).
* **Gleich Diskette** in allen Programmen: `cuexit`, `csv`, `cerror`, `ioctl`, `lseek`, `write`, `sbrk`, `stty`, meist `isatty`, `close`, `open`, `read`, `creat`.
* Glieder mit `~` (z. B. `access chmod chown kill stat time` in cat/ls/login ...): dieselbe Quelle, anderer Stand der Relokationsworte/Aufrufziele -- in der Tabelle als aehnlich gewertet, einzeln nicht nachgemessen.
* Nur andere Programme: `getpw*`, `ctime`, `qsort`, `strcpy` .. (login, ls, date) -- gleich Diskette (`=`) soweit gefunden; `fgets`, `getpass`, `getgrent`, `atoi`, `crypt`, `execvp`, `sleep` (~87-98 %) abweichend, **nicht** in libc_alt aufgenommen.
Vollstaendige Tabelle: `python3 -I tools/userspace/libc_alt.py tabelle init`.

## Stand je Programm (`pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s`, Endstand gemessen)
| Programm | Ganzdatei | Bemerkung |
|----------|-----------|-----------|
| init | **bytegleich** (4962 B) | |
| umount | **bytegleich** (4096 B) | `perror` als Luecken-Glied (G) |
| cat | **bytegleich** (4072 B) | `setbuf`, `endopen` als G |
| stty | **bytegleich** (5814 B) | `atoi` als G; falschen Eintrag `code 0960` aus `userspace/stty/k.txt` entfernt |
| ls | **bytegleich** (8244 B) | `rdwr setbuf endopen ctime qsort` als G; `jr` mit Ziel -254 B bleibt als `WV %E881` (z8kdis und as kennen den Randfall nicht) |
| date | **bytegleich** (5758 B) | `timezone` als G mit `_zonetab` (ctime liest dessen Daten; `date.members.zusatz`) |
| mount | **bytegleich** (4272 B) | Eigencode: Original behaelt `xorb rh4,rh4` nach `ldb rl4,@r3` bei `(*np++ = *argv[n]++) == 0` (0x16E, 0x19E); c2-Regel **R30** (unten).  `cc -S` liefert das `xorb` schon, erst das R2-Modell nahm es weg; Quelltextvarianten wurden **nicht** durchprobiert (der Ausdruck ist V7-Text, R30 reichte).  libc-Teil bytegleich; die Zaehlung 947/949 Befehle kam vom fehlenden `xorb` (Folgeverschiebung), nicht von `perror` |
| login | **bytegleich** (9904 B) | `getpass` (04FA-0614, V7 `stdio/getpass.c`, 282 B) lag vor dem ersten starken libc-Treffer und zaehlte als Eigencode: die 98 fehlenden Befehle waren nur eine Zuordnungsfrage, `login.c` war richtig.  `getpass` steht als G-Glied in `login.members`; die Zeile kommt aus `login.members.zusatz` (`+`-Zeile, von `libc_alt.py members login` eingefuegt -- Neuerzeugung gemessen gleich der Handfassung, login danach weiter bytegleich; Daten 3 Literale 14 B, BSS `pbuf` 10 B); mit `fgets setbuf endopen execvp sleep atoi crypt` 8 G-Glieder, `libc_alt.py bau login`: Text/Daten/BSS aller 8 gleich dem Original-Abbild.  `libc_alt.py quelle login` meldet weiter einen (unschaedlichen) Fehler fuer das S-Glied `ttyslot` (Adresse `2D2E` = Ende des eigenen BSS) |

Mechanik: `libc_alt.py members NAME` (zerlegt den libc-Teil; Handkorrekturen in `NAME.members.zusatz`), `quelle NAME`, `bau NAME` (nur G-Glieder werden assembliert, das Archiv
enthaelt alle Glieder in Programmreihenfolge).  A = Glied aus dem init-Archiv, S = aus der mitgelieferten libc.a, G = Luecke, nach dem aehnlichsten Glied benannt (Anteil der festen Woerter im Lauf-Log).

## Offen
* `sh` und weitere Programme ohne `NAME.members`.
* Die c2-Regeln R20-R26 sind je an einer Stelle belegt; weitere Belege fehlen.
* Das Original-`strlen`/`perror` usw. unterscheiden sich vom Diskettenglied (`~`): Ursache (c2-Stand) nicht je Glied belegt.
