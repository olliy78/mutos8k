# Auftrag S3b-3 (Plan 44): ar und ed der Diskette `cmd` (`bin/`)

Stand 2026-11-13, Branch `us-cmd-s3b3`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.

| Programm | Datei | Ergebnis | Quelle | c2-Regeln (Stellen) |
|----------|-------|----------|--------|---------------------|
| `bin/ar` | 10050 B (Abbild 10034: text 8148, data 1886, bss 1764) | **G** ganzdatei bytegleich | V7 `ar.c` **unveraendert** (`diff` ohne Ausgabe) | R1 20, R2 1, R4 3, R30 1, R42 2, **R65 1** |
| `bin/ed` | 11472 B (Abbild 11456: text 11222, data 234, bss 4900) | **A** (Eigencode abweichend, libc-Teil gleich) | V7 `ed.c` unveraendert gebaut; die MUTOS-Fassung ist **nicht** der V7-Text | -- |

Befehle:

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME ; ... quelle NAME ; ... bau NAME            # Gast, 0 Glieder abweichend
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s              # ar: "=> BYTE-IDENTICAL"
    USERSPACE_STUFEN=1 ... (ar, Pruefung des Stufenbaus, s. u.; fuer ed ohne Variable, die Quelle ist ueber 20000 B)

## ar (G)

* Bau ohne `--libc alt`/c2-Modell: text 9476 statt 8148 (libc.a der Diskette statt der Originalglieder), also wie bei den anderen Programmen nicht ganzdatei erreichbar.
* Mit `libc_alt` und c2-Modell: Kopf gleich, **10034 von 10034 Byte gleich** (`pipeline.py alles ar --c2emu --libc alt --ist neu_c2_s`, Zeile `=> BYTE-IDENTICAL`; gebaute Datei 10050 B = 10034 B Abbild + 16 B a.out-Kopf).
* Zwischenstand vor R65: Eigencode 1210 Befehle beidseitig, 1208 gleich, ein Unterschied in `trim()` (2 Byte): Original `ld r12,4(FP) ; ld r13,4(FP)`, ausgelieferter c2 `ld r12,4(FP) ; ld r13,r12` (`p2 = s; for (p1 = s; ...)`).
* **Neue Regel R65** (`uspace.c2_emu_s`; Modell des alten c2, kein Lauf desselben): `ld rA,%k(FP) ; ld rB,rA ; jr L` -> `ld rA,%k(FP) ; ld rB,%k(FP) ; jr L`.  **1 Stelle** (ar `trim`), also schwach belegt.
  Regression: Host-Lauf `c2_emu_s` mit und ohne R65 ueber alle 52 vorhandenen `.s` (32 `neu.s` der bisherigen Programme, 20 Module `sh`): **0 Aenderungen**; der Test `test_c2_model_rewrites_and_canonicalises` zaehlt R65 mit.
  Da die Quelltexte und `.s` der 33 bisherigen Programme unveraendert sind, bleiben deren Bytes unveraendert (Schluss aus dem Hostvergleich; **kein** neuer Gast-Lauf aller 33).
* **libc-Behelfe**: `userspace/libc_alt/ar.members` (erzeugt von `members`), Zusatz nur bei `ctime`: der Karteneintrag `code 18F4` (aus dem Adresswert in `MULTL RQ4,@R15` bei 1668 abgeleitet, steht mitten in einem Befehl von `ctime`) wurde aus `userspace/ar/k.txt` **von Hand gestrichen**; sonst meldet `libc_alt.py quelle ar`: `ctime: z8kdis left data words in the code`.  Bei Neuerzeugung von `k.txt` erneut streichen.  G-Glieder (aus dem Original-Abbild, belegen keine Herkunft): `perror ctime mktemp` (`bau`: text/data/bss OK, 0 Glieder abweichend).
* Herkunft: V7-Text unveraendert; das ist durch die Bytes belegt (Eigencode von 1210 Befehlen). Aussagekraft wie README Punkte 1, 2, 5.

## ed (A)

* libc-Teil: 522 von 522 Befehlen gleich, 0 Differenzbloecke; Behelf `ed.members`: das 2-Byte-Glied `fakcu` (`__cleanu`, `RET`) bei 283C steht vor `mktemp` (Export bei 283E) -- `members_auto` hatte es dem Glied `mktemp` (Start 283C) zugeschlagen (`quelle`: `code before the first export label`); in `ed.members` von Hand eingetragen (`fakcu 283C 283E exp=__cleanu@283C src=S`, `mktemp 283E ...`).  Bei Neuerzeugung der Datei erneut eintragen.
* Eigencode (0000-2624 im Original): **3212 Befehle im Original, 3194 gebaut, 3140 gleich, 45 Differenzbloecke**; text 11154 statt 11222 (68 Byte kuerzer), data 234 und bss 4900 gleich (Zeichenketten gleich: `TMP`, `WRITE ERROR`, `/tmp/eXXXXX`, `Entering encrypting mode!`, `ed.hup`, `MEM?`, `/bin/sh`, `Input not tty`, `Key:`, `/usr/lib/makekey`, `/lib/makekey`, `crypt: cannot generate key`).
  Bericht: `userspace/ed/work/bau/neu_c2_s.bericht` (git-ignoriert).  Das c2-Modell ist an (R1 15, R2 7, R4 11, R5 4, R7 1, R30 12, R32 1, R42 2, R45 2).
* **Unterschiede, die eine Quellvariante nahelegen** (Original gegenueber V7-`ed.c`; gemessen, nicht nachgebaut):
  1. `move()` (Original 18C2): im `else`-Zweig (kein `cflag`) steht vor `ad2 = addr2` ein Test `adt == addr1 || adt == addr1-1` mit Ruecksprung (`CP R13,addr1 ; JR Z,cret ; LD R2,addr1 ; DEC R2,#2 ; CP R2,R13 ; JR Z,cret`, 14 Byte); der V7-Text hat ihn nicht.
  2. `main()` (0030): die Schleife `while (argc>1 && **argv=='-')` steht im Original mit Test oben (`CP argc,#1 ; JR LE` am Anfang, `JR` zurueck am Ende) und `case 0` (`-`) zuerst; der gebaute Code testet unten (Sprung auf den Test) und ordnet die `switch`-Aeste anders.  Ob das Quellform (z. B. `for (;;)`/`goto`) oder ein anderer c1 ist, ist **ungeklaert**.
  3. `22F6` (Original) erweitert mit `EXTS RR2` (Vorzeichen), der gebaute Code mit `XOR R2,R2` (ohne Vorzeichen) an zwei Stellen, und umgekehrt eine `EXTS`-Stelle fehlt: ein Typunterschied (`int`/`unsigned`) an der Quelle; nicht aufgeloest.
  4. `17B0` (`TEST R2` fehlt gebaut), `02D2` (`LD R2,mem` fehlt gebaut), `1BE8` (`XORB` fehlt gebaut): kleine Quellformunterschiede.
* **Unterschiede der Art c2** (ca. 30 Bloecke): das Original laedt globale Variablen und Argumente erneut aus dem Speicher (`LD R2,B+40E`, `LD R11,%4(R14)`), der ausgelieferte c2 verwendet vorhandene Registerkopien (`LD R2,R11`); `ADD R2,R3` gegen `ADD R2,R5`; `LD R0,mem ; CP R0,mem` gegen `LD R0,R2 ; CP R2,mem` (Familie der Regeln R5/R6/R60-R65).  Nach den Gepflogenheiten des Projekts waere das ein Dutzend neuer Regeln mit je 1-3 Stellen; da zugleich echte Quellunterschiede (1-4) bestehen, wurden **keine** Regeln eingefuehrt (Plan 44 Abschnitt 3: nur wenn unvermeidbar).
* Nicht untersucht: ob die MUTOS-`ed` aus einer anderen V7-Fassung (Dezember 1978 bis 1979) stammt; `original/sys3/cmd/ed/ed.c` ist ein anderes Programm (anderer Zeilentyp `LINE`) und passt **nicht** (`move()` dort ohne den Test aus 1.).

## Stufenbau fuer grosse Quellen (Neuerung in `uspace.gast_bauen`)

Messung: der Bau von `ed.c` (24850 B) im Gast scheitert mit `no space on dev 4/0` (Wiederholung in `neu/lauf.log`): die Platte `/tmp` (ca. 250 KB) fasst die Zwischendateien von `cpp`, `c0`, `c1`, `c2` des einstufigen `cc` nicht gleichzeitig.
Ab 20000 B Quelle (`STUFEN_AB`) oder mit `USERSPACE_STUFEN=1` laufen die Passe von Hand in der Reihenfolge von V7 `cc.c` (`/usr/lib/cpp -I/mnt`, `c0`, `c1`, `c2`, `/usr/bin/as -u`, `cc -s -o` zum Binden), und jeder Schritt leert die verbrauchten Dateien (`>datei`; `rm` liegt auf der nicht eingehaengten Befehlsdiskette).  Pfade aus den Zeichenketten von `cc` (`/usr/lib/c0`, `/usr/lib/cpp`, `/usr/bin/as`).
Beleg der Gleichwertigkeit: `ar` mit `USERSPACE_STUFEN=1` liefert aus dem Stufen-`cc -O -S` dasselbe `.s` und damit **dieselbe bytegleiche Datei** (10034 von 10034, `BYTE-IDENTICAL`).  Offen: die Variante `neu` (Binden im Stufenbau, ohne c2-Modell) liefert **kein** Binary (`NO binary`, `neu.err` leer; nicht untersucht); fuer den Beweis wird nur `neu.s` und `neu_c2_s` gebraucht.
Betrifft von den bisherigen Programmen keines (groesste Quelle `make.c` 13835 B).

## Aussagekraft

Wie README Punkte 1, 2 und 5.  `ar`: C-Quelle (V7 unveraendert) + ausgelieferter Compiler + c2-Modell (R65 mit einer Stelle neu) + `libc_alt` = Originalbytes.  `ed`: **keine** Bytegleichheit; die MUTOS-Fassung weicht an mindestens vier Stellen vom V7-Quelltext ab (s. o.) und der c2-Anteil ist nicht abgetrennt.
