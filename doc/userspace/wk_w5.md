# Auftrag W5 (Plan 52): `c2` (`/usr/lib/c2`)

Stand 2026-11-17, Branch `us-wk-w5`.  Alles *gemessen* (Listing `userspace/c2/c2.lst`), soweit nicht *Annahme*.

**Ergebnis: F (keine bauende Quelle).**  Erreicht sind: Karte (`--check c2` OK), libc-Teil (`libc_alt` 26 Glieder, `bau c2`: 0 Glieder abweichend),
Kopf `userspace/c2/c2.h` (Entwurf, nicht gebaut), und eine Lesung des Binaries (unten).  Es gibt keine `c20.c`/`c21.c`, keinen Gastbau, keine neuen c2-Regeln
(R170-R199 unbenutzt), und deshalb **keine Gegenprobe**.  Grund: das Binary ist kein V7-`c2` mit Z8000-Tabellen, sondern eine weitgehende Neufassung (siehe 2).

## 1. Karte (fertig)
`userspace/c2/karte_extra.txt`: 12 `ohne` (Vorschlaege, die Datenworte als Zeiger lesen und mitten in Befehle fallen: 0902 206C 2074 20AA 2102 2120 2578 2920 2A2A 2A36 2E2C 2F2C) und
30 `code`-Zeilen (Sprungtabellen der Daten bei 4770-48D2 sowie 43C6; tote `jr` bei 2324 250A 305E; Funktionen ohne Aufrufer 20EC 2BD4; doprnt-Faelle).
Wegen der Tabellen im Datenteil war W0s Ansatz (nur `ohne`) nicht ausreichend, `code` noetig.  `--check c2`: OK (Ueberlappung 0).
Das Binary: Text 16976 = 0x4250, Daten ab 0x4250, `line[512]` bei 4A10 (BSS-Anfang), `first` 4C10.

## 2. Befund zur Struktur (Lesung, nicht bewiesen durch Bau)
Gegenueber V7 `c20.c/c21.c` (Funktionszuordnung von W0 war an mehreren Stellen falsch, s. Tabelle):
* Opcodes: `jr cc`=1, `jp cc`=2, `jr`=3, `jp`=4, WV-Zeile=5, Label=6, Dlabel=7, `E`=8, `ld`=10 ... gemaess `optab` bei 0x4286 (75 Eintraege, `{char *name; int op|sub<<8}`), davor `conds[12]` bei 0x4252 (`eq ne le ge lt gt c ugt ule uge pl mi` = 0..11), `revbr[12]` bei 43B6, `isn=9000` (43C2), `lastseg=32` (43C4).  `c1`-Ausgabe hat immer `jp`; c2 macht `jr` daraus (13EA: `op--` wenn `toofar(p,0)` falsch).
* Register-Verfolgung: `regs[38][20]` (4C4C; 36 Register in 2 Baenken zu 14 plus 8, `RT1=36`, `RT2=37`), `rsz[38]` (4F44: Groessenzeichen r/l/h/q/f), `rnode[38]` (4F6A: Knoten, der den Wert lud), `cregs[8][20]`, `conloc/conval`, `ccloc` (5056..5098), `fflag` 509A, `ophash[79]` 509C.  Operandenreihenfolge ist Z8000 (Ziel zuerst), daher sind `RT1`/`RT2` gegenueber V7 vertauscht.
* `main`: kopiert die erste Zeile bis `;` unveraendert, dann `do{ input; do{ refcount; do{iterate;niter++}while(nchange); clearreg; comjump; if(retopt()) break; rmove;}while(nchange); addsob; do{shortjmp}while(nchange); output;}while(isend)`.  `movedat` und `jumpsw` fehlen im Ablauf (`jumpsw` 20EC steht als toter V7-Rest im Binary).
* Funktionsliste (Adresse = Zuordnung nach Lesung): 0030 main, 039A input (Bedingungsnamen ueber `conds`), 0568 getline (`f`-Praefix, `!`/`~`-Kommentare, `:`), 0704 getnum, 0748 output (Hash-switch op/3, Suffixe b l s d, `djnz`), 09C6 copy, 0A4A opsetup (79 Buckets), 0AAE oplook (Suffixbehandlung, `WV L`), 0CDA refcount (+ Entfernen von `I`/`G`-Deklarationen), 0E54 iterate, 10C8 xjump, 1152 insertl, 11CC codemove, 1382 comjump, 13EA shortjmp (neu), 1430 backjmp, 149C retopt (neu: `call csv; jp cret` -> `ret`), 151E rmove (3232 B, Sprungtabelle 4778 ueber `op-1`), 20EC jumpsw (V7, ungenutzt), 21BE addsob (`djnz`, plus Entfernen doppelter Befehle und redundanter `test`), 23E4 toofar(p,flag), 244E ilen (Tabellen 484C/4808), 2510 adrlen, 2572 abs, 258C equop, 25FE decref, 2622 nonlab, 2644 alloc, 26A2 clearreg, 2702 savereg(ai,as,sz,np), 278C dest(as,sz,flt), 2932 clrptr (neu), 2A36 singop, 2A72 dualop, 2AF2 findrand(as,sz,flt), 2BC0 isreg, 2BD4 check (ungenutzt), 2BFC repladdr, 2E5A redunbr, 2F26 findcon, 2F94 compare (Zahlen ueber `atoh` ohne Zeigervorschub: vergleicht effektiv nur gleiche Zeichenketten), 3060 setcon, 30C0 equstr, 311E setcc, 315C clrcc, 316C natural, 31BA atoh, 322E delnode (mit `nchange++`), 3256 regno, 3322 setrsz, 33AE kill (4er-Gruppe ausgerollt), 34E4 clrptr30, 3504 log2n, 3536 mkshift (`mult`/`and`/`or` mit Zweierpotenz -> `sla`/`res`/`set`).
* Daraus fuer die Gegenprobe (Vorschau, *Annahme*, nicht ausgefuehrt): der ausgelieferte c2 kennt `xor r,r` statt `ld r,#0`, Schiebebefehle statt Multiplikation mit Zweierpotenzen, Entfernen von `inc SP` + `push` ueber Ueberschreiben, `djnz`, gemeinsame Schwaenze (`comjump`) und Blockverschiebung (`codemove`) -- also genau die Codelage-Effekte, an denen W2 (cpp, 13 Bloecke) scheiterte.

## 3. Offene Punkte
* `c20.c`/`c21.c` schreiben (die oben gelesenen Funktionen sind bis auf `rmove`-Zweige 1A00-1F6E/21BE im Detail ausgewertet; Registerzuordnung der Locals, `register`-Parameter in umgekehrter Deklarationsreihenfolge) und im Gast iterieren; BSS-Luecke 5096-5098 (`ccloc` 22 statt 20?) klaeren.
* Danach Gegenprobe R1-R112 / K1-K6 und Regression (`sh ed tar cc ld`): nicht ausgefuehrt.

# Teil b (Branch `us-wk-w5b`): `c2.h` + `c20.c`

Stand 2026-11-17.  Quellen: `userspace/c2/c2.h`, `userspace/c2/c20.c` (Funktionen 0030..151E, 17 Stueck), `userspace/c2/c21.c` (**vorlaeufiger Stub**, nur damit das Programm bindet; Teil zwei ersetzt ihn).
Aufruf (Gast, ca. 6 min je Lauf): `python3 -I tools/userspace/pipeline.py alles c2 --c2emu --libc alt --ist neu_c2`; Bericht `userspace/c2/work/bau/neu_c2.bericht`.

## Funktionen (Adresse im Original, V7-Gegenstueck, Befund)
| Adresse | Funktion | V7 | Befund (gemessen) |
|---------|----------|----|-------------------|
| 0030 | `main` | c20.c main | V7-Rahmen, aber: erste Eingabezeile bis `;` unveraendert durchgereicht, kein `movedat`/`jumpsw`, `retopt()`-Abbruch, `do shortjmp() while (nchange)`; Register `niter maxiter isend c nflag` = R13..R9 |
| 039A | `input` | c20.c input | `case`-Reihenfolge im Quelltext `default, LABEL, CMT, JBR/JMP/JSW` (die Rumpfreihenfolge im Binary; der Compiler sortiert die Vergleichskette selbst); `JBR/JMP/JSW` zerlegen die Bedingung (`jp eq,L5`) ueber die Tabelle `conds` (Schritt 2 Zeichen: `cc += 2`); `CMT` (`!`) -> Knoten mit `op` 0; Registervariablen R13..R8 (`p lastp oper cp s np`), `cc` Stapel |
| 0568 | `getline` | c20.c getline | `f`-Praefix (`fflag`), Kommentarzeilen `!`/`~`, `:` liest noch ein Zeichen (Zeilenende) |
| 0704 | `getnum` | c20.c getnum | V7 |
| 0748 | `output` | c20.c output | Hash-Schalter (`op/3`); `LABEL`/`DLABEL` mit `\n`; Suffixe `b l s d`; `WV L%d`, `djnz`; kein `reducelit` (das V7-`reducelit` gibt es nicht; die Zuordnung von W0 war falsch) |
| 09C6 | `copy` | c20.c copy | V7, aber `onp` Registervariable (R11) |
| 0A4A | `opsetup` | c20.c opsetup | V7 (`OPHS` 79) |
| 0AAE | `oplook` | c20.c oplook | Suffix-Behandlung `ld cp or ex` + `b l s d`; `WV Ln` statt `Ln`-Sprungschalter |
| 0CDA | `refcount` | c20.c refcount | V7 + Entfernen von `I`/`G`-Deklarationszeilen (`delnode`); Schleifenkopf `p->op<=JSW` |
| 0E54 | `iterate` | c20.c iterate | stark erweitert (JBR/JMP, CBRS/CBR, `delnode`, Sprung auf Folgebefehl) |
| 10C8 | `xjump` | c20.c xjump | V7 + Pseudobefehlsbereich `CODE..CMT` bricht ab; `JMP` statt `JBR` |
| 1152 | `insertl` | c20.c insertl | V7 |
| 11CC | `codemove` | c20.c codemove | V7 mit `JMP`/`JBR`, Schleifenbedingung `p3->op && p3->op>CBR`; `t tl n` Registervariablen |
| 1382 | `comjump` | c20.c comjump | V7 mit `JBR`/`JMP` |
| 13EA | `shortjmp` | nicht V7 | `jp` -> `jr`, wenn `!toofar(p,0)` (`p->op--`); Name *Annahme* |
| 1430 | `backjmp` | c20.c backjmp | V7, `delnode(p2)` statt Auskettung |
| 149C | `retopt` | nicht V7 | `call csv ; ... ; jp cret` -> `ret`; Name *Annahme* |

Konstanten/Tabellen: `optab` (76 Eintraege, `0x4286`), `conds` (12 Paare + Ende, `0x4252`), `revbr`, `isn = 9000`, `lastseg = 32` (alle gemessen).
`lastseg` wird nur in `output` gesetzt (`CODE` 31 / `DATA` 36 / `BSS` 34) und nirgends gelesen (`movedat` fehlt).  `DATA` (36) hat keinen `optab`-Eintrag; die tote V7-Pruefung
`p->forw->op!=DATA` in `iterate` ist erhalten (Wert 0x24 im Binary gemessen).  Namen `DSEC` (32), `CODE`, `SDEF` usw. sind *Annahme*.

## Ergebnis Teil b (gemessen, Gast, `alles c2 --c2emu --libc alt --ist neu_c2`)
**Alle 17 Funktionen von `c20.c` befehlsgleich (E auf Funktionsebene)**: im Bericht bleiben in 0030..149C keine Befehlsbloecke ausser vier Artefakten, die mit Teil zwei verschwinden:
* `PUSH @R15,#D+..`/`ADD ..,#B+..` mit konstantem Versatz 0x1AA (Daten) bzw. Adressen in `libc`: das gebaute Abbild hat 426 B weniger Daten (Tabellen von c21) und 106 B weniger BSS, weil `c21.c` noch Stub ist.
* `0748` `CP R2,#4 ; JR UGT` und `0AAE` `ADD R2,#%2000`: Darstellungsartefakte des Berichts (der Disassembler des Gebauten kennt die `ohne`-Marke 0902 des Originals nicht bzw. deutet 0x2000 als Funktionsadresse); die Bytes sind gleich.
* `149C`/ab `151E`: Stub-Code statt `rmove` usw.
Daten von `c20` (Zeichenketten, `conds`, `optab`, `revbr`, `isn`, `lastseg`) gleich dem Original (Bytevergleich mit Zeigerversatz, `diff` leer).  BSS-Adressen aller Globalen aus `c2.h` stimmen (`fflag` 509A usw.).

Quellvarianten, die probiert wurden (je ein Gastlauf), und was sie entschied:
* `input`: `case`-Rumpfreihenfolge muss `default, LABEL, CMT, JBR..` sein (Rumpf folgt der Quelle, Vergleichskette sortiert der Compiler); die Zerlegung der Bedingung ist eine `if`-Kette (`'\t' ' ' ',' '\n'`), kein `switch` (der sortiert die Vergleiche); `conds` ist ein `int`-Feld mit Schritt 2 (`int *cc; *cc != 0; cc += 2`; mit `*cc` allein oder `char **` ergibt der Compiler `ld r3,@r2 ; test r3`, das Original `test @r2`); `(p->subop & FLTF) == 0` statt `!(..)` (sonst `bitb`).
* `oplook`: erste Stelle `(c = tmpop[2]) == 'b' || ...` als Ausdruck, zweite Stelle `c = *lp++;` als Anweisung davor (sonst fehlt `xorb`).
* `codemove`: `t tl n` sind Registervariablen R10 R9 R8.
* `main`: `putchar(c = getchar())` ist `c = getchar(); putchar(c);` (zwei Anweisungen).

c2-Modell: **keine neue Regel.**  `C2_AUS["c2"] = {R5, R7, R32, R45}` in `tools/userspace/pipeline.py` (nur fuer das Programm `c2`, wie bei `sh`/`ed`): der gelieferte c2 selbst zeigt die Formen des aelteren Standes (`ld rA,rB ; test rB`, `ld DST,rB` nach `getchar`, kein `xorb` zwischen `ldb` und `cp` bei `tmpop[1]`, `xor r2,r2` vor dem Hash-Schalter in `output`).  R1 (3), R2 (6), R4 (7), R30 (2) feuern und stimmen.  Andere Programme sind nicht beruehrt (Schluessel ist der Name).

## Offene Punkte fuer Teil zwei (`c21.c`, 0x151E..0x3590)
* Funktionen laut Karte: `rmove` (3232 B, Sprungtabelle 4778), `jumpsw` (20EC, ungenutzt, V7-Rest), `addsob`, `toofar`, `ilen`, `adrlen`, `abs`, `equop`, `decref`, `nonlab`, `alloc`, `clearreg`, `savereg`, `dest`, `clrptr`, `singop`, `dualop`, `findrand`, `isreg`, `check` (ungenutzt), `repladdr`, `redunbr`, `findcon`, `compare`, `setcon`, `equstr`, `setcc`, `clrcc`, `natural`, `atoh`, `delnode`, `regno`, `setrsz`, `kill`, `clrptr30`, `log2n`, `mkshift` (Namen *Annahme*, Zuordnung der W0-Tabelle ist an mehreren Stellen falsch).
* BSS-/Daten-Adressen der Globalen und der Statics (`labhash` 5566, `tmpop` 5546, `cbuf` 553C in `c20`) stimmen schon; die Daten von c21 (Tabellen 4808, 484C, 4778 ..) und c21-Statics fehlen noch (426 B Daten, 106 B BSS).
* Aufrufschnittstellen aus `c20` (aus den Aufrufen gemessen): `toofar(p, 0)`, `equop(p1,p2)`, `decref(p)`, `nonlab(p)`, `alloc(n)`, `equstr(s1,s2)`, `delnode(p)` (ruft `nchange++`), `clearreg()`, `rmove()`, `addsob()`; Rueckgabe `retopt()` 1/0.
