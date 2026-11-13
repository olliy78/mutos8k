# Auftrag S3b-2 (Plan 44): dd, pr, passwd der Diskette `cmd` (`bin/`)

Stand 2026-11-13, Branch `us-cmd-s3b2`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Alle drei Programme: **G** (ganzdatei bytegleich), Quelle jeweils **V7-Text unveraendert**.

| Programm | Datei | Abbild (text/data/bss) | Quelle | c2-Regeln (Stellen, Lauf mit Modell) |
|----------|-------|------------------------|--------|--------------------------------------|
| `bin/dd` | 7296 B | 7280 (5284/1996/1128) | V7 `dd.c` unveraendert | R1 6, R2 1, R4 2, **R65 1, R66 1**; R3 aus (`C2_AUS`, 1 Stelle) |
| `bin/pr` | 8310 B | 8294 (7796/498/8618) | V7 `pr.c` unveraendert (gleicher Text wie `original/hippe-v7/usr/src/cmd/pr.c`, nur Vergleichsreferenz) | R1 1, R4 5, R5 1, R38 1 (mit neuer Ausnahme), **R69 1**; R5-`test`-Form aus (`C2_AUS` Pseudoregel `R5T`, 4 Stellen) |
| `bin/passwd` | 9140 B | 9124 (7546/1578/3382) | V7 `passwd.c` unveraendert | R1 5, R4 21, R5 1, **R67 1, R68 1** |

Befehle je Programm (Bau und Beweis):

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME           # Gast
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s              # "=> BYTE-IDENTICAL"
    cmp userspace/NAME/work/bau/neu_c2_s.bin userspace/NAME/work/NAME.orig                           # ohne Ausgabe

`diff original/unix-v7/usr/src/cmd/NAME.c userspace/NAME/NAME.c` ist fuer alle drei leer.  Header: `stdio.h signal.h pwd.h sys/types.h sys/stat.h` sind alle in `/usr/include` der Diskette; `PROGRAMME` traegt keinen Zusatz-Header.
Dass der V7-Text die MUTOS-Fassung ist, ist gemessen nur insoweit, als er die Originalbytes erzeugt (Annahme darueber hinaus).

## libc-Teil und Behelfe

`libc_alt.py bau NAME`: 0 Glieder abweichend bei allen drei.  Glieder aus dem Original-Abbild (G, belegen keine Herkunft): `dd`: `perror`; `pr`: `rdwr setbuf endopen atoi ctime`;
`passwd`: `getpass fgets setbuf endopen getlogin atoi crypt`.  Handeingriffe (je eine `NAME.members.zusatz`, bei Neuerzeugung von `NAME.members` erhalten):

* **passwd**: `getpass` (V7 `stdio/getpass.c`) liegt **vor** dem ersten starken libc-Treffer und wird von `members_auto` dem Eigencode zugeschlagen (gleicher Fall wie bei `login`).
  Ohne Zusatzzeile: Eigencode des Baus 1196 statt 1506 B (0x4AC statt 0x5E2), 109 Differenzbloecke im libc-Teil.  Zeile: `+ getpass 04C8 05E2 data=1F32:1F40 bss=29B4:A exp=_getpass@04C8 src=G`.
* **pr**: `rdwr` (`fread` bei 096E, `fwrite` bei 09D6; ein Glied, wie in `od`/`who`) liegt vor `fopen`, gleicher Grund.  Zeile: `+ rdwr 096E 0A4E exp=_fread@096E,_fwrite@09D6 src=G`.
  Zwei Fehlversuche, im Lauf gemessen: getrennte Glieder `fread`/`fwrite` (der Bau band das `fread` der ausgelieferten `libc.a`, libc-Teil 1797 statt 1757 Befehle) und ein Glied `fwrite` allein (Text 120 B = 0x78 kuerzer).
  Die Funktion bei 092C (`LD R0,%3D68 ...`) ist kein libc-Glied, sondern `put()` aus `pr.c`.
* `libc_alt.py quelle passwd|pr` meldet weiter `ERROR: ttyslot/ttyname: ... in B of ... without an exported symbol` (Konstante im Code gleicht einer BSS-Adresse, unschaedlich wie bei `login`/`who`; `bau` und Bytevergleich gleich).

## Neue c2-Regeln R65-R69 (`uspace.c2_emu_s`; Modell des alten c2, kein Lauf desselben)

Alle fuenf sind **Beschreibungen** von Unterschieden zwischen der Ausgabe des ausgelieferten c2 und dem Original, je **genau eine Stelle**, also **schwach**.  Quellvarianten wurden nicht durchprobiert (V7-Text, nur Codeformen).

| Regel | Stellen | Muster (ausgelieferter c2 -> Original) |
|-------|---------|----------------------------------------|
| R65 | 1 (dd) | `ldb @r2,rl3 ; djnz rN,L` -> `ldb @r2,rl3 ; dec rN,#1 ; jr ne L` (Ende von `do { a = *ip++; ip[-1] = *ip; *ip++ = a; } while(--c)`, Registervariable `c`; das Original hat kein DJNZ; auf den vorangehenden `ldb @r2,rl3` eng gefasst, `sh` hat ein DJNZ in `fault.s`, das erhalten bleibt) |
| R66 | 1 (dd) | `ld r3,MEM ; ldb rl0,@r2 ; cpb rl0,@r3 ; jr eq L ; ld r2,r3 ; testb @r2` -> `... ; jr eq L ; ld r2,MEM ; testb @r2` (`match()`: `while(*cs++ == *s) ...; if(*s != 0)`, `s` Parameter) |
| R67 | 1 (passwd) | Bereichspruefung am Ende einer else-if-Kette (`else if(c>='0' && c<='9') ..; else ..`, nach R4): `cp r0,#lo ; jr ge LB ; LX: set..` mit frueher stehendem Block `LB: ld r0,M ; cp r0,#hi ; jr gt LX ; <Rumpf> ; jr LEND` -> Block steht inline: `cp r0,#lo ; jr lt LX ; cp r0,#hi ; jr gt LX ; <Rumpf> ; jr LEND ; LX: set..`.  Die beiden frueheren Bereiche derselben Kette (`a-z`, `A-Z`) behalten den Sprung zum Block (dort folgt auf `LX:` ein Test, kein `set`); auf `set` hinter `LX:` eng gefasst |
| R68 | 1 (passwd) | `call _strcmp ; inc SP,#4 ; test r2 ; jr eq L21 ; push @SP,#L20 ; jr L9015` -> `jp eq L21` (das Original hat an dieser Stelle einen langen Sprung, Ziel 0x10C Byte entfernt; mit den uebrigen Regeln ist das kurze `jr` fuer den Gast-`as` ausser Reichweite, `ILLEGAL VALUE`, gemessen im ersten Lauf).  Das zweite `strcmp` von passwd behaelt `jr`; deshalb am Label `L21` festgemacht |
| R69 | 1 (pr) | `div rr2,MEM ; ld MEM2,r3` -> `div rr2,MEM ; ld r2,r3 ; ld MEM2,r2` (`colw = width / ncol`).  Nicht bei Direktoperand und nicht vor `jr`: `sh` (`service.s`, `div rr2,#2 ; ld MEM,r3 ; jr eq`) haette sonst eine Stelle bekommen; zusaetzlich in `C2_AUS["sh"]` |

Aenderung an bestehender Regel **R38** (dcheck): `cp M,#k ; jr cc L ; ld rN,M` -> `ld rN,r0`; fuer `rN = r0` entfaellt die Zeile ganz (sonst `ld r0,r0`; pr `ncol > 72 || ncol > width`, 1 Stelle).  Bei den frueheren Programmen ist `rN = r0` nie vorgekommen (gemessen, s. Regression).

### Programmweises Abschalten in `C2_AUS` (`pipeline.py`)

* **dd**: R3 aus.  Sie setzte ein `XORB` hinter `cp r2,#%30 ; jr nc` in `number()` (1 Stelle, Befund: erster Lauf Text 5286 statt 5284 B bei sonst befehlsgleichem Code); das Original hat keins (wie bei `od`).
* **pr**: `R5T` (Pseudoregel, nur die `test`-Form von R5 `ld rA,rB ; test rB -> test rA`).  Das Original behaelt `ld r11,r2 ; test r2` an 4 Stellen (`tpgetc(0)`-Ketten).  Die zweite Form von R5 (`ld rA,rB ; ld DST,rB -> ld DST,rA`)
  wird in `pr` an 1 Stelle gebraucht (`LD R12,R2` hinter dem `getc`-Verbund), daher nicht ganz R5 abgeschaltet.
* **sh**: R69 aus (s. o.).

*Annahme*: `dd` und `pr` stammen aus einem c2-Stand, der in diesen Punkten dem ausgelieferten entspricht (wie `od`, `df`, `rm`).

## Hinweise zum Ablauf (Fehlerbilder, in der Reihenfolge des Auftretens)

* Erster Lauf `dd`: 2 Differenzbloecke, Text 5282 statt 5284 B (R65, R66 fehlten); mit R65/R66 5286 B, `difference blocks 0` aber 2 B zu lang (R3, s. o.).
* Erster Lauf `passwd`: Eigencode 1196 B statt 1506 B (`getpass`, s. o.); danach `ILLEGAL VALUE` im Gast-`as` (R68), dann ein Differenzblock im `else if`-Verbund (R67).
* Erster Lauf `pr`: 8 Differenzbloecke, `fread`/`fwrite` als Eigencode des Originals (s. o.), `LD R0,R0` (R38), `TEST R2` (R5T), `div` (R69), `LD R12,R2` (R5 zweite Form, mit `R5T` statt ganz R5 aus).
* **Stale-Falle** (wie `cmd_s3a.md`): gueltig sind nur Laeufe, in deren Log `=> BYTE-IDENTICAL` steht (`pr`, `dd`, `passwd`: alle drei gesehen, danach `cmp` ohne Ausgabe).

## Regressionsstand

Nicht alle 33 frueheren Programme wurden im Gast neu gebaut (je ca. 2 Minuten, 33 Laeufe).  Stattdessen **Host-Beweis** (*gemessen*): das c2-Modell `c2_emu_s` des Standes `main` (`git show main:tools/userspace/uspace.py`) und der neue Stand wurden auf alle Eingaben der
frueheren Programme angewandt (je mit ihrer `c2_aus`-Menge) und der Ausgabetext verglichen: die 32 `work/bau/neu.s` (alle Einzeldatei-Programme der Hauptkopie), die 20 Modul-`.s` von `sh` (`v7fix_s`) -- **52 Eingaben, 0 Unterschiede**.
Die Eingabe des Modells (`cc -S`) und alles hinter ihm (`as`, `ld`, `libc_alt`) ist unveraendert, also sind die Bytes der 33 Programme unveraendert.  Dieser Beweis fand eine Stelle: R69 traf `sh` (`service.s`); gegated und in `C2_AUS` abgeschaltet.
Grenzen: nicht abgedeckt ist ein Programm, dessen `neu.s` in der Hauptkopie fehlt (alle 32 Einzeldatei-Programme dort vorhanden) und die libc-Glieder-Quellen von `libc_alt` (`c_*.s` nicht gefunden; `c2_emu_s` dort ohne `aus` -- R65-R69/R5T/R38-Aenderung haetten dort nur bei den genannten Mustern gegriffen).
`pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped (Gast-Bau nur mit `USERSPACE_GAST=1`); die Zaehlerliste in `test_c2_model_rewrites_and_canonicalises` ist um R65-R69 erweitert.
`pipeline.py --check dd|pr|passwd`: ok.

## Aussagekraft

Wie README Punkt 1, 2 und 5: *C-Quelle + ausgelieferter Compiler + diese Regeln (+ `C2_AUS`) = Originalbytes*; die Regeln sind ein Modell.  Neu: fuenf Einzelstellenregeln (R65-R69), eine Ausnahme in R38, zwei programmweise Abschaltungen (dd R3, pr R5T).
Der libc-Teil ist aus dem Abbild bzw. der ausgelieferten `libc.a` gewonnen und belegt keine Herkunft.  Der Eigencode aller drei ist byteweise V7-Text.
