# Auftrag S3b-1 (Plan 44): nm, strip, chown der Diskette `cmd` (`bin/`)

Stand 2026-11-13, Branch `us-cmd-s3b1`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Alle drei Programme: **G** (ganzdatei bytegleich).

| Programm | Datei | Abbild (text/data/bss) | Quelle | c2-Regeln (Stellen) |
|----------|-------|------------------------|--------|---------------------|
| `bin/nm` | 6028 B | 6012 (5574/438/1124) | V7 `nm.c`, 2 Abweichungen (kein `A_MAGIC2`, Stub `swapw`) | R1 4, R4 2, R5 1, R45 1 |
| `bin/strip` | 4030 B | 4014 (3602/412/1102) | V7 `strip.c`, 1 Abweichung (kein `A_MAGIC2`) | R1 5, R4 1, **R65 1** |
| `bin/chown` | 5522 B | 5506 (4386/1120/1628) | V7 `chown.c` **unveraendert** | R1 1, R4 1, R39 1 |

Befehle je Programm (Bau und Beweis):

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME           # Gast
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s              # "=> BYTE-IDENTICAL"
    cmp userspace/NAME/work/bau/neu_c2_s.bin userspace/NAME/work/NAME.orig                           # ohne Ausgabe

Keine `PROGRAMME`-Besonderheiten (keine Zusatz-Header), keine Eintraege in `C2_AUS`.

## Abweichungen vom V7-Text (durch Bytes belegt)

* **chown**: keine (`diff original/unix-v7/usr/src/cmd/chown.c userspace/chown/chown.c` leer).
* **strip**: `a_magic[] = {A_MAGIC1, A_MAGIC3, A_MAGIC4, 0}`; das `a.out.h` der Diskette kennt kein `A_MAGIC2` (nur E807 E811 E805; mit V7-Text
  `illegal initialization`, gemessen).  Das Original hat die Werte `e807 e811 e805 0000` direkt vor `/tmp/sXXXXX` (0x0E12).  Gleiche Beobachtung wie bei `size` (cmd_a3.md).
* **nm**:
  1. `BADMAG` ohne `MAGIC!=A_MAGIC2` (gleicher Grund; mit V7-Text `A_MAGIC2 undefined`, gemessen).  `FORMAT` kommt aus dem MUTOS-`a.out.h` (`"%06x"`, Zeichenkette bei 0x16D2 im Original, V7 hat `%06o`).
  2. **Stub `swapw(p, n) register p, n; {}`** am Dateiende (leere Funktion, 16 Byte: `csv ; ld r13,4(fp) ; ld r12,6(fp) ; jp cret`, bei 0x05EE).  Das Original ruft sie dreimal:
     `swapw((char *)&exp, 1)` im `else`-Zweig hinter dem Magic-`fread` (statt `else if (BADMAG)` jetzt `else { swapw(..); if (BADMAG) {..} }`), `swapw((char *)&exp, 8)` hinter dem Kopf-`fread`,
     `swapw((char *)&sym.n_value, 1)` hinter dem Symbol-`fread` (Adressen 0x0242, 0x01C4, 0x02AE im Original; `&sym.n_value` = FP-0x16 aus dem Listing).
     Name und Klammerung des `else`-Zweigs sind **Annahmen** (nicht im Binary; gemessen ist nur Aufrufform, Argumente und leerer Rumpf).  *Annahme*: Byte-Order-Haken der MUTOS-Fassung (leer auf der Z8000-Seite).
     Ohne den Stub fehlten 62 Byte Text.

## libc-Teil und Behelfe

`libc_alt.py bau NAME`: 0 Glieder abweichend.  G-Glieder (aus dem Original-Abbild, keine Herkunftsaussage): `nm`: `ftell rdwr endopen qsort`; `strip`: `mktemp`; `chown`: `fgets endopen perror atoi`.

* **nm**: `members_auto` setzt die Eigencode-Grenze an das erste starke Glied (`fopen` 0x079C); davor liegen `ftell` (0x05FE..0x06BC) und `rdwr` (0x06BC..0x079C, `_fread@06BC`, `_fwrite@0724` wie bei `size`).
  Ohne Zusatz zog `ld` `fread`/`ftell` aus der ausgelieferten `libc.a` (Text 62 Byte kuerzer).  `userspace/libc_alt/nm.members.zusatz`: `+ ftell`, `+ rdwr`.
* **chown**: `chown` benutzt `isdigit()` (Datenglied `ctype_`, 130 Byte bei 0x14FE..0x1580), `members_auto` nimmt es nur fuer `atof` auf; alle Datenfenster hinter `getpwent` lagen 0x82 zu weit hinten
  (`quelle`: `printf: direct address 11C0 in no member`).  `userspace/libc_alt/chown.members.zusatz` (wie `cmp.members.zusatz`): `getpwent data=1160:1168`, `doprnt 1168:11B2`, `data 11B2:1254`,
  `perror 1254:1268`, `errlst 1268:14FE (_sys_ner@12AE)`, `+ ctype_ 14FE:1580`, `sbrk 1580:1582`.  `quelle` danach ohne Fehlermeldung.

## Neue c2-Regel R65 (`uspace.c2_emu_s`; Modell des alten c2, kein Lauf desselben)

**1 Stelle (strip, `copy()`)**: `ld rN,#k ; ldl rr2,X ; xor r0,r0 ; ld r1,rN ; cpl rr2,rr0` -> `... ; ld r1,#k ; cpl rr2,rr0`
(`s = 512; if (size < 512) s = size;` mit `long size`, `register s`: der ausgelieferte c2 nutzt das Register mit 512 wieder, das Original laedt die Konstante neu; Original `LD R1,#0x200`).
Das ist **schwach** (eine Stelle, nur beschriebener Unterschied).  Quellvarianten (`512L`) wurden *nicht* durchprobiert; *Annahme*: sie aendern nichts, weil die Konstante schon von c1 als `ld r1,#k` kommt.
Regression der Regel auf dem Host: `c2_emu_s` mit/ohne R65 ueber alle vorhandenen `neu.s` (35 Programme der Hauptkopie und der drei neuen; `sh` zusaetzlich: kein Modul enthaelt das Muster): nur `strip` aendert sich.
Der Test `test_c2_model_rewrites_and_canonicalises` pinnt die Zaehlerliste, um R65 erweitert.  `C2_AUS` unveraendert; bei `strip` bleiben R1/R4 an (ohne sie 4 Byte zu kurz; gemessen).

## Fehlerbilder (vor den Korrekturen, gemessen)

* nm/strip: `A_MAGIC2 undefined` / `illegal initialization` -> keine Binaerdatei (`neu_c2_s.bin` fehlt: erster Lauf brach im Vergleich ab).
* nm ohne `swapw` und ohne `ftell`/`rdwr`-Zusatz: Text 5512 statt 5574, 33 Differenzbloecke im libc-Teil.
* strip ohne R65: Text 3600 statt 3602, ein Block (`LD R1,R13` statt `LD R1,#%0200`).
* chown ohne Zusatz: `libc_alt.py quelle` meldete `direct address 11C0/11C1 in no member`.

## Regressionsstand

* `pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped.  `pipeline.py --check nm|strip|chown`: OK.
* Vollstaendiger Gast-Neubau aller 33 bisherigen Programme wurde **nicht** wiederholt.  Begruendung (*Annahme*): R65 aendert auf dem Host kein vorhandenes `neu.s`
  (siehe oben), `uspace.py` ist sonst unveraendert, `C2_AUS` unveraendert.  Der Gast-Beweis der 33 bleibt der aus `cmd_s3a.md`.
* Gemessen in diesem Auftrag: nm 6012, strip 4014, chown 5506 Byte, jeweils `=> BYTE-IDENTICAL` und `cmp` gegen `work/NAME.orig` ohne Ausgabe.
