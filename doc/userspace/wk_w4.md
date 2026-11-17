# Auftrag W4 (Plan 52): `c0`, der C-Compiler-Vorderteil

Stand 2026-11-17, Branch `us-wk-w4` (von `main` nach Merge `us-wk-w13`).  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Datei | Ergebnis | Quelle | c2-Regeln (Stellen) |
|----------|-------|----------|--------|---------------------|
| `c0` (`/usr/lib/c0`) | 26826 B (text 23614, data 3196, bss 12074) | **G** ganzdatei bytegleich | V7 `usr/src/cmd/c/c00.c..c05.c`, `c0.h` mit MUTOS-Abweichungen (Abschnitt 2) | R130 3, R131 1, R132 1, R133 1 (nur `c0`, ohne R1-R91) |

Befehle (je Programm vorher `libc_alt.py members c0`, `quelle c0`, `bau c0`; Rundlauf: 0 Glieder abweichend):

    python3 -I tools/userspace/pipeline.py alles c0 --c2emu --libc alt --ist neu_c2    # danach cmp userspace/c0/work/bau/neu_c2.bin userspace/c0/work/c0.orig

`PROGRAMME["c0"]` zeigt auf das Verzeichnis `userspace/c0` (alle `*.c` alphabetisch = Linkreihenfolge `c00 c01 c02 c03 c04 c05`, `c0.h` reist mit; Mehrdateien-Weg wie `sh`: je `.c` ein `cc -O -c`,
dann `cc -s -o`).  Ohne `--c2emu` ist die Datei nicht ganzdatei gleich (text 23616 statt 23614 B, 24 Differenzbloecke; die Differenz sind genau die c2-Formen unten).

## 1. Vorgehen und Stand je Quelldatei

Alle sechs Dateien sind ganzdatei bytegleich (Funktionen in V7-Reihenfolge, `c05.c` = Tabelle `opdope`, byteweise V7-Text, kein Unterschied zu `original/unix-v7/.../c05.c`).
Zeilen, die vom V7-Text abweichen (`diff`): `c00.c` 24, `c01.c` 20, `c02.c` 49, `c03.c` 18, `c04.c` 7, `c05.c` 0, `c0.h` 5; jede Stelle mit `/* Differs from V7: ... */` bzw. `/* Not V7: ... */` im Quelltext.

Schrittfolge (jede Messung ein Gastlauf, Block-/Bytevergleich gegen `work/c0.orig`):
1. Karte: `--check c0` meldete 16 Ueberlappungen.  Ursache: 13 Sprungtabellen (`LD R1,Lxxxx(Rn) ; JP @R1`) in den Daten, die nicht als `dwc` eingetragen waren; die Vorschlaege verfolgten Tabelleneintraege als Code
   mitten in Befehle.  `userspace/c0/karte_extra.txt`: 13 `dwc`-Zeilen (Hash-Schalter `DIV RR2,#n` haben n Eintraege, Bereichsschalter `CP R2,#k ; JR UGT` k+1) und drei `ohne`-Zeilen (4DE8 und 4E4E in `doprnt`,
   4F04 in `gcvt`: Marke mitten im Befehl).  Danach Ueberlappung 0, `--check c0` OK.
2. V7-Quelle unveraendert uebersetzt (Gast `cc -O -c`): 27300 B, 915 Differenzbloecke; die Haupt-Abweichungen sind Registervariablen (unten), `HSHSIZ`, die drei neuen Meldungen.
3. Je Funktion: Vergleich der Befehlsfolge (Adressen normalisiert) und Zuordnung Stapelplatz (Original-Register) -> Deklaration; Frame-Groesse und `DEC R15,#n` im Prolog bestaetigen.
4. c2: nach den Quelltextaenderungen bleiben 4 Formen (Abschnitt 3), die nur ein anderer c2 erklaert.

## 2. Abweichungen vom V7-Text (Quelltext in `userspace/c0/`)

**Allgemeine Beobachtung (gemessen):** MUTOS hat sechs Registervariablen (R8..R13, die PDP-11 drei).  Das Original deklariert in vielen Funktionen mehr Variablen `register` als V7; die Reihenfolge der
`register`-Deklarationen bestimmt die Register (erste = R13).  Stapelvariablen liegen in Deklarationsreihenfolge von hoch nach niedrig ab FP-14 (csv rettet R8..R13 = 12 B), die erste zuerst.

`c0.h`
* `HSHSIZ 420` (V7 400): `DIV RR2,#%01A4` in `lookup`; BSS 12074 B.
* `STAUTO (-12)` (V7 -6): erste Automatik hinter den von `csv` geretteten Registern (`LD R2,#%FFF4` in `cfunc`).
* **neue globale Variable** `int regmin;` zwischen `sbufp` und `regvar` (2 B BSS an 92F2): `cfunc` setzt `regmin = 8`, `regvar = 14` (V7: `regvar = 5`); `blockhead` liest `r = regmin`.  Der Zweck ist nicht belegt
  (*Annahme*: untere Registergrenze; sie wird nirgends sonst gelesen -- `goodreg` vergleicht `regvar<9` mit einer Konstanten).  Der Name `regmin` ist erfunden.

`c00.c`: `lookup` (`register int ihash`), `findkw` (`register` fuer `wp`, `firstc`), `getnum` (Register `np c base expseen sym maxdigit`, Stapel `nsyn` vor `ndigit`), `tree` (Register `op pp p andflg o cs`, Stapel `opst prst ps os cmst lcp`),
`xprtype` (`register scp`), **`getcc`** (nicht V7): `ccp` wird nach `cc = 0` um 1 erhoeht (das Zeichen kommt in das niedrige Byte des Big-Endian-Wortes), und ein zweites Zeichen ergibt
`error("No character constant")` (V7 nimmt zwei Zeichen); die Meldung `Long character constant` bleibt als toter Zweig.
`c01.c`: `build` (Register `t1 t2 t p1 p2 p3`; `if (p2) t2 = p2->type;`; im `FSEL`-Zweig `p3 = block(...); *cp++ = p3;` statt `*cp++ = block(..., *--cp, ...)`),
`chkfun` und `disarray` (`if (p==0) return(p);` zuerst -- die Befehlsfolge zeigt die Pruefung am Anfang; `chkfun` mit der Form `p!=0 && ...` gab 2 B weniger, gemessen als Variante; `disarray` mit `p==0 || ...` (Variante) hatte dieselbe Funktionslaenge, die Bytes wurden nicht verglichen -- gewaehlt ist die getrennte `if`-Anweisung), `fold` (`register unsignf`).
`c02.c`: `extdef` (Register `o scflag cb ds`), `cinit` (`o cb s` Register), `statement` (`register o o1 o2 o3 np sauto`; Stapel `sreg`; das `outcode("BN", SETREG, ...)` entfaellt), `forstmt`, `pswitch` (alle lokalen Variablen Register),
`funchead` (nach `cs->hoffset = pl;` neu `if (cs->htype==CHAR) cs->hoffset++;` -- `char`-Parameter liegen im niedrigen Byte; das abschliessende `outcode("BN", SETREG, regvar)` entfaellt), `blockhead` (`r = regmin`, kein `SETREG`),
`blkend` (`endcs` Register; **neu**: fuer `hclass==EXTERN` wird die Tabelle durchlaufen und `strncmp(cs->name, ncs->name, NCPS-1)==0` ergibt `error("names %.8s and %.8s conflict", cs->name, ncs->name)`),
`cfunc` (`regmin`, `regvar = 14`).
`c03.c`: `getkeywords` (Register `isadecl ismos unsignf`, `o` bleibt Stapel), `decl1` (Register `t1 chkoff elsize skw dsym tptr`, Stapel `type` vor `a`; bei `skw==AUTO` nach `dsym->hoffset = autolen;` neu `if (dsym->htype==CHAR) dsym->hoffset++;`),
`getype` (`register type`), `align` (`register ftl`), `goodreg` (`register type`; `regvar<9` statt `regvar<3`).
`c04.c`: `length` (`register nd`), `doret` (ohne die `ITOC`-Umwandlung fuer `char`-Funktionen), `outcode` (`register n`).

Die Zuordnung von W0 ("abweichend": `symbol putstr getcc mapch blkend outcode`) hat sich als *Messartefakt* erwiesen, soweit `getchar`/`putc` Makros sind (stdio.h der Diskette expandiert sie inline, `filbuf`/`flsbuf` stehen nicht
als Aufruf im Quelltext): `symbol`, `putstr`, `mapch` sind unveraendert V7-Text; `getcc`, `blkend`, `outcode` weichen wie oben ab.
Die neuen Meldungen `No character constant`, `names %.8s and %.8s conflict` stammen aus den Aenderungen an `getcc` und `blkend`; `Disallowed conversion` steht schon im V7-Text.

## 3. c2-Regeln R130-R133 (`uspace.c2_c0_s`, nur `c0`)

Aufruf `c2_emu_s(..., c0=True)`: dann wirken **nur** diese, nicht R1-R91.  Modell des alten c2 aus dem Listing (kein Lauf von ihm).  Nach den Quelltextaenderungen unterscheidet sich die Ausgabe des ausgelieferten c2 genau an diesen Stellen:
* **R130** `inc SP,#%A ; push @SP,r2` -> `inc SP,#%8 ; ld @SP,r2` (3 Stellen: `cinit`/`statement`/`dogoto` -- Aufruf mit fuenf Argumenten, dessen Ergebnis sofort das erste Argument des naechsten Aufrufs ist; die uebrigen
  Zaehlungen 2, 4, 6, 14 gleich im Original und im c2-Lauf, nur 10 wird nicht verschmolzen).
* **R131** `cp r9,#%8 ; jp ne,La ; cp @r13,#%5A ; jp eq,Lb` -> letztes `jp` als `jr` (1 Stelle, `tree`: Sprungweite des alten c2 kleiner geschaetzt).
* **R132** `cp r2,#%3 ; jp eq,La ; cp r2,#%7 ; jp eq,Lb ; jp Lc` -> `jr eq,Lb ; jr Lc` (1 Stelle, `tree`, Operator-Schalter).
* **R133** `cp r2,#%16 ; jp eq,La ; cp r2,#%17 ; jp eq,Lb ; cp r2,#%19` -> `jr eq,Lb` (1 Stelle, `treeout`).
Die `jp`->`jr`-Faelle sind Entscheidungen der Sprungweiten-Schaetzung des alten c2 (gemessen: im Original bleiben `JP`-Spruenge mit kleinerer Weite, z. B. 10FC mit 230 B, und andere mit 228 B werden `JR`);
die Regeln benennen die Stelle nach ihrer Form.  Schwach belegt (Einzelstellen), wie README Punkt 2.  Ob eine Quelltextvariante diese Formen erklaert, wurde nicht durchprobiert.

## 4. libc-Teil (`userspace/libc_alt/c0.members`, 30 Glieder)

Zerlegung `libc_alt.py members c0` mit `c0.members.zusatz`:
* `doprnt code=4CEC,4CF2,4D08` (474-B-Fassung wie `cc`, Sprungeinsprunge 2 B spaeter als automatisch angenommen);
* **`fltpr`** `exp=pgen@4D9C,pfloat@4DC6,pscien@4E3A,sign@67FA,decpt@67FC` (V7-Reihenfolge `pgen pfloat pscien`; automatisch standen alle drei bei 4D9C -- die Aufrufe aus `doprnt` zeigten das als Bytefehler an 4CEF/4D04/4D05);
* `common __sibuf 9356`, `__sobuf 9556`, `extern _environ 9756` (die automatisch abgeleiteten 9370/9570/9770 waren falsch: Referenzen im Original 9356 4x, 9556 2x, `crt0` `LD B+2E9C`; ein Bytefehler an `548D`).
Glieder `gcvt` und `modf` stammen aus der mitgelieferten `libc.a` (S), `fltpr`, `ecvt`, `flsbuf`, `endopen`, `malloc` als Luecken-Glieder (G, Quelle aus dem Abbild), die uebrigen aus dem init-Archiv (A) oder `libc.a` (S).
Rundlauf `libc_alt.py bau c0`: 5 G-Glieder, 0 Glieder abweichend.

**Gleitkomma (W0-Frage):** `fltpr`/`ecvt`/`gcvt`/`modf` enthalten EPA-Befehle (`EXT0E/0F/4E/4F/8E/8F`, 59 Stellen), die der Diskettenassembler nicht kennt (`doc/werkzeugkette/as_dialekt.md`).
`libc_alt.py` schreibt sie jetzt als Datenwoerter im Code (`WV %w0;WV %w1[;WV adresse]`, Adresswort symbolisch, damit es relokiert wird); damit werden `fltpr` (298 B) und `ecvt` (610 B) Wort fuer Wort gleich.
`c0` selbst (Eigencode) enthaelt **keinen** EPA-Befehl: die Konstantenfaltung `fcon` arbeitet ohne Gleitkomma-Befehle (alle 59 Stellen liegen in der Bibliothek, `fltpr`/`ecvt`/`modf`/`gcvt`).
Werkzeugfehler behoben: `ecvt` adressiert `&buf[80]` (= Ende des eigenen BSS, zugleich Anfang des BSS von `malloc`); `libc_alt.py` brach mit "without an exported symbol" ab, jetzt wird die Adresse als eigenes BSS-Ende erkannt.

## 5. Werkzeugaenderungen

* `tools/userspace/uspace.py`: `c2_c0_s` (R130-R133), `c2_emu_s(..., c0=False)`.
* `tools/userspace/pipeline.py`: `PROGRAMME["c0"]`, Aufruf mit `c0=(name=="c0")`.
* `tools/userspace/libc_alt.py`: EPA-Befehle als `WV`, BSS-Ende-Adresse eines Gliedes.
* `userspace/c0/`: Quellen `c00.c..c05.c c0.h`, `karte_extra.txt`.

## 6. Regression

Gemessen 2026-11-17 (Gast, sequentiell, nach den Aenderungen an `uspace.py`/`pipeline.py`/`libc_alt.py`): `sh` (`bau sh --c2emu --variante v7fix`), `ed`, `tar` (`alles NAME --c2emu --libc alt --ist neu_c2_s`),
`cc` und `ld` ganzdatei bytegleich zum Original (`cmp` ohne Ausgabe).  `--check c0`: OK.  `pytest -m "not gast"`: 205 bestanden, 1 Fehler `test_bau_alle_kennt_genau_die_fertigen_disketten`
(erwartet `disks/gebaut/*.hfe`, die im Worktree fehlen -- nicht committet, unabhaengig von W4).
