# Auftrag W1/W3 (Plan 52): `cc` und `ld`

Stand 2026-11-17, Branch `us-wk-w13` (von `main` nach Merge `us-wk-w0`).  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Datei | Ergebnis | Quelle | c2-Regeln (Stellen) |
|----------|-------|----------|--------|---------------------|
| `cc` (`/usr/bin/cc`) | 6536 B (text 5902, data 618, bss 2660) | **G** ganzdatei bytegleich | V7 `cc.c` mit MUTOS-Pfaden, gekuerztem Optionssatz und 3 weiteren Abweichungen | R93 2, R94 7, R95 4, R96 2 (nur `cc`, ohne R1-R91) |
| `ld` (`/usr/bin/ld`) | 10726 B (text 9686, data 1024, bss 35924) | **G** ganzdatei bytegleich | V7 `ld.c` ohne Overlay und `-n`, mit Z8000-Relokation | R97 2, R98 1, R99 1, R100 1 zusaetzlich zum Standardmodell (R32, R43 aus) |

Befehle (je Programm vorher `libc_alt.py members NAME`, `quelle NAME`, `bau NAME`; Rundlauf: 0 Glieder abweichend):

    python3 -I tools/userspace/pipeline.py alles cc --c2emu --libc alt --ist neu_c2_s    # danach cmp work/bau/neu_c2_s.bin work/cc.orig
    python3 -I tools/userspace/pipeline.py alles ld --c2emu --libc alt --ist neu_c2_s

`PROGRAMME`: `cc` und `ld` zeigen jetzt auf `userspace/NAME/NAME.c` (statt auf das leere Verzeichnis).  Ohne `--c2emu` sind beide nicht ganzdatei gleich (cc: 15 Differenzbloecke, ld: 84 mit
Standardmodell, ohne Modell mehr).

## 1. cc (G)

Quelle `userspace/cc/cc.c`, V7-Text von `original/unix-v7/usr/src/cmd/cc.c`.  Alle Funktionen ausser `main` und `error`/`copy` (nur libc-Makros/Aufrufe, Text unveraendert) sind V7 unveraendert
(`idexit dexit getsuf setsuf callsys nodup cunlink`, ausserdem `error`, `copy`, `setsuf`).  `main` hat folgende Abweichungen (gemessen am Listing, je mit Kommentar im Quelltext):

1. Pfade: `/usr/lib/c0 c1 c2 cpp crt0.o mcrt0.o`, `/usr/bin/as`, `/usr/bin/ld` statt `/lib/..`, `/bin/..`.
2. Optionssatz gekuerzt: ohne `-B -f -2 -t` und ohne `-l2`/`-lfpsim`; es bleiben `S o O p E P c D I U C`.  Variablen `noflflag chpass npassname`, `f20` entfallen (Frame und BSS passen erst so: 2660 B).
3. `-o` ohne Ausgabenamen (naechstes Wort ist Option oder `.c`/`.o`-Name): `--i; outfile = (char *)-1`, spaeter wird der Name aus dem ersten `.o`-Namen gebildet (`setsuf(t, 0)`, letzte zwei Zeichen entfernt).  **Nicht V7.**  Die Typisierung in `case 'o'`
   (Ergebnis von `getsuf` in `t` statt `c`) ist ein Behelf: nur so entsteht `LD FFF2,R2` statt `LD FF18,R2` (*Annahme*: das Original hat dort eine Variable dieser Lage; welche, ist nicht belegbar).
4. Temporaerdatei: `copy("/tmp/ctm0XXXXXX")` + `mktemp(tmp0)` + `creat(tmp0,0400)`/`close` mit `cc: cannot create temp`, Platz fuer `[8]`-Ziffern wie V7; `setbuf(stdout, NULL)` bleibt.
5. Schleife je Quelldatei beginnt mit `cunlink(tmp1/tmp2/tmp3 (nur ohne -S)/tmp4/tmp5)`; nach `c0` wird `unlink(tmp4)`, nach `c1` `unlink(tmp1); unlink(tmp2)`, nach dem Assemblieren (ohne `-S`) `unlink(tmp3)` direkt aufgerufen (V7: nur `cunlink` im Assemblerschritt).
6. Der Objektdateizaehler `nxo` wird im Zweig fuer `.o`-Namen erhoeht, dort steht auch die Namensbildung aus Punkt 3.

Der `ptemp`-Grenztest `pv >= ptemp+MAXOPT` ist V7 unveraendert (der Gast-`cc` uebersetzt `ptemp+MAXOPT` anders als der Leser denkt, Listing 0164: Vergleich mit `ptemp`; Verhalten damit "immer Fehler" -- *gemessen* im Listing, nicht im Lauf).

**libc-Teil** (`userspace/libc_alt/cc.members`, 28 Glieder, `cc.members.zusatz`: `doprnt code=0D2A,0D30,0D46` wie bei tar): `mktemp` und `setbuf` gehen aus `G`-Schnitten, `malloc`, `signal`, `flsbuf` u. a. aus dem Abbild.
Rundlauf `libc_alt.py bau cc`: 0 Glieder abweichend.  `karte_extra.txt`: `ohne 0102` (aus W0).  `--check cc`: OK.

**c2-Regeln R93-R96** (`uspace.c2_cc_s`, aufgerufen mit `c2_emu_s(..., cc=True)`; dann wirken **nur** diese, nicht R1-R91).  Der `cc`-Text stimmt mit der Ausgabe des ausgelieferten c2 bis auf folgende Formen ueberein
(gemessen: ohne die Regeln 15 Differenzbloecke, alle von dieser Art):
* **R93** `ld r3,@r2 ; ld MEM,r3 ; push @sp,r3` -> `push @sp,MEM` (2 Stellen: `outfile`, `t` vor `getsuf`).
* **R94** `cp VAR,#k` mit VAR Stackvariable `-x(FP)` oder Registervariable r8..r13, `k` nicht -1 -> `ld r2,VAR ; cp r2,#k` (7 Stellen: `nc>=MAXFIL`, `nl>=MAXLIB`, `nc>1`, `nc==1`, `nxo==1` in `main`, zwei in `getsuf`).
  (`k = -1` bleibt bei dem `ld r0,MEM ; cp r0,#-1`, das der ausgelieferte c2 selbst erzeugt.)
* **R95** `cp VAR,#k2`, solange r2 den Wert von VAR spiegelt (nach `ld VAR,r2` oder einem R94-Laden; ueber `cp/test/jr` hinweg, bis zu Marke oder Aufruf) -> `cp r2,#k2` (4 Stellen: `c=='c'||c=='o'`, `c=='c'||c=='s'`, `status`-Vergleich in `callsys`, zweiter Vergleich in `getsuf`).
* **R96** `test r2` -> `test MEM`, wo r2 den Wert nicht mehr haelt (a: `ld M1,r2 ; ld M2,r2 ; test r2` in `copy`, b: nach R94 `eflag`-Test in `main`) (2 Stellen).
Das sind beschriebene Unterschiede (Modell des alten c2), kein Lauf von ihm; Aussagekraft wie README Punkt 2.  Der Nachweis, dass die Quelltextvarianten (z. B. `if (nc>1)` mit anderen Typen) die Formen nicht erklaeren,
beschraenkt sich auf die oben genannte Messung der Differenzbloecke; weitere Varianten wurden nicht durchprobiert.

## 2. ld (G)

Quelle `userspace/ld/ld.c`, V7-Text von `original/unix-v7/usr/src/cmd/ld.c`; Header `<sys/types.h>`, `<sys/stat.h>` (auf der Diskette vorhanden).  Funktionsliste und Reihenfolge wie V7 (34 von 37 Funktionen; `W0` fuehrte `eq` und `cp8c`
irrtuemlich: `cp8c` bei 18FC **ist** im Binary, nur `record`, `restore`, `eq` entfallen).  Abweichungen (je mit `/* Differs from V7 */` bzw. `/* Not V7 */`):

1. **Overlay entfernt:** `struct overlay`, `vnodes`, `vindex`, `vflag`, `record`, `restore`, `eq`, Option `-v` in `main` (in `endload` bleibt `case 'v'` mit `++c; ++p` -- gemessen: `CP R2,#0x76`).  Die Locals `found` und `vscan` in `main` bleiben deklariert und unbenutzt (nur so passt der Frame, `DEC R15,#8`).
2. **Option `-n` entfernt:** keine Variable `nflag` (BSS-Lage: `Oflag` liegt unmittelbar hinter `sflag`), kein `NMAGIC`, `if (rflag) sflag = iflag = Oflag = 0`, `if (iflag) tsize = (tsize + 0377) & ~0377` (Ausrichtung 256 B statt 64), `dorigin = tsize` ohne NMAGIC-Zweig, `finishout` fuellt mit Maske `0377`.
3. **Magic:** `OMAGIC 0xE805`, `FMAGIC 0xE807`, `IMAGIC 0xE811` (a.out-Kopf von MUTOS).
4. **`filhdr.tsize/dsize` unsigned:** `loc + filhdr.tsize + filhdr.dsize` wird mit `XOR R4,R4 ; ADDL` (Nullerweiterung) gerechnet (V7: `int`).  *Annahme*: das Original deklariert die Felder so; gemessen ist nur, dass dieser Text die Bytes erzeugt.
5. **`middle()`**: `errlev |= 01` steht *innerhalb* von `if (arflag==0 && sp->svalue==0)` (V7 davor; Reihenfolge der Befehle im Listing).
6. **`ldrand()`**: `if (*(pp = slookup(...)) == 0)` (V7 testet den Zeiger, `TEST @R2` im Listing).
7. **Relokation `load2td()`** (Teile ohne V7-Gegenstueck, aus dem Listing 0F18-10C6 rekonstruiert): Sprungtabelle `L261E` mit 11 Eintraegen (Fall 0 = `RABS` -> direkt `putw`, ohne die pc-relative Korrektur; Fall `010` und `012` gleich).
   `REXT`: `r = (r&07) + ((nsym+(sp-symtab))<<4) + REXT` (drei Flagbits statt eines); Flags 3 = Z8000-`CALLR`: Ziel nicht `EXTERN+TEXT` -> `CALLR : illegal destination` (Fehlerstufe 2), sonst `creloc` wird zur Entfernung
   (`creloc = ((t&07777)<<1) - creloc`; `if (creloc & 0170000)` -> `CALLR : out of range`; `t = (t&0170000) | (creloc>>1)`) und die V7-Korrektur `if (r&01) t -= creloc` wird uebersprungen.
   Die Marken `callrtext:`, `callr:`, `putit:` sind *Annahme* (Namen nicht im Binary); die Befehlsfolge ist gemessen.

**libc-Teil** (`libc_alt/ld.members`, 31 Glieder, ohne Handkorrektur; `atoi` und `mktemp` aus `G`-Schnitten): Rundlauf 0 Glieder abweichend.  `karte_extra.txt`: `ohne 01B6`, `ohne 0400` (aus W0).  `--check ld`: OK.
Der Befehlsvergleich meldet zwei **Auswerteartefakte** (kein Befund): `PUSH #01B6` (Bytewert `0666` in `tcreat`) wird als Funktionsanfang `F` abstrahiert, solange eine Funktion bei 01B6 beginnt.

**c2-Modell fuer ld:** Standardmodell (R1-R91) mit `C2_AUS["ld"] = {R32, R43}` (R32 an 1 Stelle in `symreloc`, R43 an 1 Stelle in `getfile` haetten ein `XORB` eingefuegt, das das Original nicht hat) plus vier neue Regeln
(`uspace.c2_ld_s`, nach `c2_emu_s` angewandt), jeweils mit Stellenzahl:
* **R97** `sub r2,r12 ; ld MEM,r2 ; jr mi` -> `test r2` vor dem `jr` (`mget`, 2 Stellen; der ausgelieferte c2 laesst den redundanten Test weg).
* **R98** nach R45 (`xorb rh3 ; exts rr2 ; div rr2,#3` in `main`, Hash-Switch ueber `ap[i]`) -> `xorb rh3 ; ld r2,r3 ; ld r3,r2 ; xor r2,r2 ; div` (1 Stelle; R45 trifft sonst richtig in `middle`, 1 weitere Stelle).
* **R99** `mult rr4,#%C ; ld r13,r5 ; add r13,#X ; ld MEM,r13 ; ld @r2,r13` -> Umweg ueber r3 (`enter`, 1 Stelle).
* **R100** `ld LOCAL,r3 ; ld r2,r3` -> `ld r2,LOCAL` (`ldrand`, `sp = *pp; sp->stype`, 1 Stelle).
Zaehlung des Laufs: R1 13, R2 5, R4 8, R5 5, R7 1, R30 1, R45 2, R97 2, R98 1, R99 1, R100 1.  Schwach belegt (die meisten 1-2 Stellen), wie README Punkt 2.

## 3. Werkzeugaenderungen

* `tools/userspace/uspace.py`: `c2_cc_s` (R93-R96), `c2_ld_s` (R97-R100); `c2_emu_s(..., cc=False)`.  Alle anderen Programme laufen durch denselben Code wie vorher (`cc=False`).
* `tools/userspace/pipeline.py`: `PROGRAMME` fuer `cc`/`ld` auf die Dateien; `C2_AUS["ld"]`; Aufruf `c2_ld_s` fuer `ld`.
* **Stufenbau** (`stufen_befehl`, Quellen ueber 20000 B): ein Gastbefehl von rund 440 Zeichen wird vom Gast-tty beschaedigt (gemessen: ein Zeichen fehlt, die Kette laeuft stumm nicht; `ld.c` mit `libc_alt`-Archiv).  Jetzt drei Befehle
  (cpp+c0, c1+c2, as+cc), jeder endet in `/mnt`.  Bei `ed` ist der Befehl kuerzer; das Ergebnis des Regressionslaufs steht in Abschnitt 4.

## 4. Regression

Gemessen 2026-11-17 (Gast, sequentiell, nach den Aenderungen an `uspace.py`/`pipeline.py`): `ls`, `cp`, `tar`, `ed` (`alles NAME --c2emu --libc alt --ist neu_c2_s`) und `sh` (`bau sh --c2emu --variante v7fix`) ganzdatei
bytegleich zum Original (`cmp` ohne Ausgabe); ausserdem `cc` nach dem `ld`-Stand erneut gleich.  `ed` (Stufenbau) laeuft mit den drei Gastbefehlen unveraendert gleich.
