# Auftrag W2 (Plan 52): `cpp` (`/usr/lib/cpp`)

Stand 2026-11-17, Branch `us-wk-w2` (von `main` nach Merge `us-wk-w13`).  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Datei | Ergebnis |
|----------|-------|----------|
| `cpp` | Original 16382 B (text 13202, data 3164, bss 17780); gebaut 16292 B (text 13112, data 3164, bss 17780) | **A** (Abweichung benannt, nicht G): Eigencode 3268 von 3323 Befehlen gleich, 13 Differenzbloecke; text 90 B kuerzer; data/bss gleich |

Befehle (Rundlauf libc-Teil: `libc_alt.py members cpp`, `quelle cpp`, `bau cpp`):

    python3 -I tools/userspace/erg_yacc.py userspace/cpp/cpy                  # cpy.c im Gast aus cpy.y (braucht erg.py bau yacc)
    python3 -I tools/userspace/pipeline.py alles cpp --c2emu --libc alt --ist neu_c2     # Bericht: userspace/cpp/work/bau/neu_c2.bericht

## 1. Die yacc-Frage (Schluessel dieses APs): *gemessen*, Antwort ja

Der **Gast-yacc** (V7-yacc, Groessenklasse `SMALL`, `erg.py bau yacc`, 28538 B) erzeugt aus dem **unveraenderten** V7-`cpy.y` ein `y.tab.c`, dessen acht Tabellen
**wortgleich** mit den Daten des Original-`cpp` sind (Suche der big-endian-Wortfolge im Abbild, Skript im Gespraech):

| Tabelle | Worte | Adresse im Original |
|---------|-------|---------------------|
| `yyexca` | 70 | 3858 |
| `yyact` | 363 | 38E4 |
| `yypact` | 62 | 3BBA |
| `yypgo` | 4 | 3C36 |
| `yyr1` | 30 | 3C3E |
| `yyr2` | 30 | 3C7A |
| `yychk` | 62 | 3CB6 |
| `yydef` | 62 | 3D32 |

(683 Worte; gleiche Zahlen wie der Host-Lauf in `wk_w0.md` 3a, damit ist die dortige *Annahme* "Gast-yacc = Host-yacc" bestaetigt.)  Folge fuer die Quelle: `cpy.y` (V7, unveraendert) ist die Quelle,
`cpy.c` ist **erzeugt** (`tools/userspace/erg_yacc.py userspace/cpp/cpy`, Kopfkommentar "GENERATED") und wird wie bei `expr`/`egrep`/`bc` (E3c) eingecheckt.  Das gilt als Beleg fuer W7 (`as`): ein V7-yacc-Gastlauf reproduziert die Originaltabellen.

## 2. Quelle

`userspace/cpp/`: `cpp.c`, `cpy.y`, `yylex.c` (V7-Text; `cpy.y`/`yylex.c` unveraendert), `cpy.c` (erzeugt, enthaelt `# include "yylex.c"`).  Linkreihenfolge wie V7-`makefile` (`cpp.o cpy.o`): alphabetisch
`cpp.c`, `cpy.c`; `yylex.c` ist **kein** eigenes Modul (Werkzeug: `pipeline.quelle_lesen` nimmt ein `.c`, das ein anderes `.c` des Ordners per `#include "NAME"` einbindet, als Kopf).
Funktionsreihenfolge im Binary = V7 (`wk_w0.md`).  **Nicht** gebaut wird mit `-Dunix=1 -Dpdp11=1` (V7-makefile): das Original definiert `unix` und `U8000` (Zeichenketten 379C, 37A1).

Abweichungen von V7 in `cpp.c` (je mit `/* Differs from V7 */`):
1. `#define unix 1`, `#define U8000 1` statt `-D`; `varloc=stsym("U8000")` (V7: `"pdp11"`).  Gemessen: Zeichenketten und Datenteil gleich.
2. `symsiz 500` statt 400 (BSS 400 B groesser = 100 Eintraege `struct symtab`; danach stimmt die BSS-Lage: 17780 B, alle `B+`-Adressen gleich).  *Annahme*: das Original hat die `gcos`-Zahl 500.
3. `lookup`: `if (enterf==1) sp->name=namep;` (V7: `enterf>0`); gemessen: das Original vergleicht mit 1 (`CP R0,#1 ; JR NZ`).

`main`: die V7-Zeichenketten fuer `gcos ibm ...` und die Aufrufe `intss`/`inquire` entfallen ohne die Makros von selbst (V7-Text unveraendert, `#if`-Zweige); die Zeichenketten des Datenteils sind danach gleich (*gemessen*).

**libc-Teil**: `userspace/libc_alt/cpp.members` (29 Glieder), `cpp.members.zusatz`: `doprnt code=292A,2930,2946` (wie bei `tar`/`cc`: 474-B-Variante, Sprungtabelle 2 Byte spaeter).  Rundlauf `libc_alt.py bau cpp`: 0 Glieder abweichend.
`karte_extra.txt` (aus W0): `ohne 2624`.  Der libc-Abschnitt des Befehlsvergleichs meldet 5 Bloecke und 15 Befehle weniger (1123 von 1138); *Annahme*: Randeffekt der Grenze Eigencode/libc (der Eigencode endet 90 B frueher), nicht untersucht.

## 3. c2-Regeln R101-R112 (nur `cpp`, `uspace.c2_cpp_s` nach `c2_emu_s` mit dem Standardmodell R1-R91, `C2_AUS["cpp"] = {R42}`)

Im Gegensatz zu `cc`/`ld` bleibt das Standardmodell wirksam (der ausgelieferte c2 trifft den `cpp` in den meisten Formen nicht, das Modell der aelteren c2-Staende dagegen oft).  Neue Regeln, Stellen je Lauf gezaehlt:

| Regel | Form | Stellen |
|-------|------|---------|
| R101 | `ld M1,rV ; ld M2,rV` (V7 `outp = inp = p`) und die Modellform `ld r2,rV ; ld M1,r2 ; ld M2,rV` -> beide Stores ueber r2 | 13 |
| R102 | `ldb DST,#k` -> Konstante zuerst laden (`ldk`/`ld rT,#k ; ldb DST,rlT`, rT=r3 bei `@r2`, sonst r2); direkt folgende gleiche Konstante wird nicht neu geladen (`*p++='/'; *p++='*'; *p++='*'`) | 24 (Orig.: kein `ldb mem,#imm` im Eigencode, 0 Ausnahmen) |
| R103 | char-Switch: `add r2,r3` -> `add r2,r2` | 1 |
| R104 | `inc rV,#1 ; ldb @r2,..` ohne vorheriges `ld r2,rV` -> `ld r2,rV` davor | 3 |
| R105 | `ld r2,rV ; ld _M,r2 ; cp rV,X` -> `cp r2,X` | 1 |
| R106 | `ld r2,@rK ; ld rV,r2 ; test rV` -> `test r2` (Ausnahme zu R5) | 1 |
| R107 | nach R4-Form `ld r0,M ; cp r0,#k ; jcc` kommt der Wert fuer die Folgeseite aus r0 (`ld r2,r0`), auch im yyparse-Fall | 2 |
| R108 | `sla r4,#1 ; sub r2,r4` -> `ld r3,r4 ; sub r2,r3` (yyparse) | 2 |
| R109 | `ld r13,r9 ; ld r2,r13` -> `ld r2,r9` (yyparse; die R1-Form des Standardmodells ist hier falsch) | 1 |
| R110 | erstes `Lx: inc r13,#1 ; jr Ly` in `cotoken` -> `jp` (Original: JP; ohne das lehnt der Assembler das `jr` nach R104 ab: ILLEGAL VALUE) | 1 |
| R111 | `ld r2,r10 ; ld r3,r2` -> `ld r3,r10` (`lookup`, Hash; R5-Form falsch) | 1 |
| R112 | `call _strdex ; inc SP,#4 ; ld rV,r2 ; test rV` -> `test r2` (`main`) | 1 |

R42 (`ld rN,SRC ; ld MEM,rN ; test rN` -> `test MEM`) trifft im Standardmodell eine Stelle (`dodef`, `if (oldval=np->value)`), das Original behaelt dort `test r3`; deshalb `C2_AUS`.
R103, R106, R107, R109-R112 sind **Einzelstellen** (schwach belegt wie in README Punkt 2); R101/R102 sind breit belegt.  Alle Regeln sind Beschreibungen (Modell eines aelteren c2), kein Lauf von ihm.
Von R101-R129 sind **R101-R112** vergeben.

## 4. Offene Unterschiede (13 Bloecke, Eigencode) -- warum A statt G

Gemessen (`neu_c2.bericht`); alle haengen an **Codelage** (Verschiebung von Bloecken, Zusammenfuehren gleicher Schwaenze), die ein c2-Lauf des Originals erzeugt und die das Modell nicht nachbildet:
* `refill` (2 Bloecke): im Original teilen sich `*np++='\n'` und die Schleife `while (--n>=0) *np++=')'` das `ldb @r2,rl3` (Schwanz zusammengefuehrt, Schleifenkoerper hinter das Funktionsende verlagert); dazu `JR GE` statt `JP GE` (kuerzere Entfernung).
* `cotoken` (4 Bloecke): im Original steht der Block `dec r13 ; cp r13,_pend ; jr nc` an der ersten Stelle inline und der Block `while (!iscom(*p++))` hinter dem Sprung; die gebaute Fassung hat es umgekehrt (`jr`-Sprung auf den Block); zwei `JP`-Ziele (Schwanz `LDB @R2,RL3` bei 0488 gemeinsam genutzt).
* `dodef` (3 Bloecke): Reihenfolge der Tests `*pin=='\\' && pin[1]=='\n'` / `*pin=='\n'` im Eigencode anders gelegt.
* `subst` (1), `strdex`-Bereich (1), `main` (1): Einzelbefehle (`test`/`ld r2,...`); nicht weiter zerlegt.
Der Rest des Text-Unterschieds (90 B) liegt in diesen Stellen (Zusammenfuehren gleicher Schwaenze spart Befehle).  *Annahme*: eine bytegleiche Fassung braucht die echte c2-Quelle (W5: `comjump`/`codemove` aus V7 `c21.c`); das Modell dafuer von Hand zu bauen war nicht verhaeltnismaessig.
Die Daten (3164 B) unterscheiden sich nur in den Worten, die auf verschobene Textadressen zeigen (272 Bytes, *gemessen*); BSS-Lage und Zeichenketten gleich.

## 5. Werkzeugaenderungen

* `tools/userspace/erg_yacc.py`: `NAME` darf `userspace/PROG/NAME` sein (Grammatik ausserhalb von `ergaenzung/`); alter Aufruf unveraendert.
* `tools/userspace/pipeline.py`: `quelle_lesen` behandelt ein `.c`, das ein anderes `.c` des Ordners `#include`t, als Kopf (nur `cpp/yylex.c` betroffen); `C2_AUS["cpp"]`; `c2_cpp_s` fuer `cpp`.
* `tools/userspace/uspace.py`: `c2_cpp_s` (R101-R112).  Alle anderen Programme laufen durch den gleichen Code wie vorher.

## 6. Regression

Gemessen 2026-11-17 (Gast, sequentiell, nach den Aenderungen an `uspace.py`/`pipeline.py`/`erg_yacc.py`): `sh` (`bau sh --c2emu --variante v7fix`), `ed`, `tar`, `cc`, `ld` (`alles NAME --c2emu --libc alt --ist neu_c2_s`) ganzdatei bytegleich zum Original (`cmp` ohne Ausgabe).

## 7. Offene Punkte

* Codelage-Modell (Abschnitt 4) bzw. echte c2-Quelle aus W5 fuer G.
* `--check cpp`: OK (61 Funktionen, 23 libc-Namen); `pytest -q -m "not gast"`: 207 bestanden.
