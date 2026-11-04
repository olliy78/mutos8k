# /bin/stty -- rekonstruiert (Branch us-stty)

Alles *gemessen* (`pipeline.py alles stty --c2emu --asm`), soweit nicht als *Annahme* markiert.  Quelle `userspace/stty/stty.c`,
Karte/Listing/Namen daneben.  Vergleichsreferenz: Hippe-Sammlung (TUHS) `original/hippe-v7/bin/stty` (nur Binary).

## Herkunft (Befund)
* **Nicht V7.**  Das V7-`stty.c` (`original/unix-v7/usr/src/cmd/stty.c`) liefert nur das Geruest (`main` mit `if (eq(..))`-Kette, `eq`, `prmodes`,
  `delay`, `prspeed`, `speeds[]`/`modes[]`); es baut im Gast nicht (das MUTOS-`sgtty.h` hat kein `NLDELAY/CR0../ALLDELAY`, ~40 "undefined").
* **Nicht System III:** `original/sys3/cmd/stty.c` arbeitet mit `termio`.
* **Dasselbe Programm wie die Hippe-Sammlung:** `original/hippe-v7/bin/stty` (PDP-11, 5358 B) enthaelt **dieselbe Zeichenkettenliste in derselben
  Reihenfolge** (Geschwindigkeiten, `crmod`, `scope indctl tandem`, `ek erase kill gspeed`, `nl0..tab2`, `%s - no effect`, `hup width length`, `tty33 tty37 vt05 tn300 ti700`,
  `erase = DEL; `, `nldly crdly htdly vtdly`, `%s\t%d`, `%s%d baud`; gemessen mit `strings -n 2`).  Das Hippe-`sgtty.h` hat dieselbe erweiterte `struct sgttyb`
  und `TIOCSETA/TIOCGETA` wie das MUTOS-`sgtty.h`.  Das MUTOS-`stty` ist also keine MUTOS-Eigenentwicklung, sondern ein Derivat aus dem Umfeld dieses
  erweiterten V7 (Quelle `stty.c` liegt in der Sammlung nicht vor).  *Annahme:* gemeinsame Vorfahren, keine Aussage ueber Urheberschaft.
* Auch `getty` (`getty.c.old`) und `stty` gehoeren zusammen: dieselben Verzoegerungsbytes und `width/length`.

## Abweichungen vom V7-`stty.c` (im Quellkopf als S1-S5 vermerkt)
1. Modustabelle ohne Verzoegerungseintraege und ohne `33/37/05/tn/ti`; `crmod`/`-crmod` statt `nl`/`-nl`; neu `scope indctl tandem` (+ `-`-Formen);
   Reihenfolge `even -even odd -odd raw -raw cooked crmod -crmod echo -echo LCASE lcase -LCASE -lcase -tabs tabs cbreak -cbreak scope -scope indctl -indctl tandem -tandem`.
2. Verzoegerungen/Terminaltypen als `if (eq(..))`-Kette in `main` (kein Tabellenlauf).  Werte (gemessen aus dem Code, Bytes der Struktur):
   `nl0`=0 `nl1`=`nl2`=6; `cr0`=0 `cr1`=5 `cr2`=10; `tab0` htdly=0 und XTABS aus, `tab1` htdly=5; `ff0` vtdly=0, `ff1` vtdly=0261;
   `bs0 bs1 nl3 cr3 tab2` -> `"%s - no effect\n"`.  `width length nl cr ht vt` lesen eine Zahl (`atoi(*++argv)`, `argc--`); `vt` loescht dabei auch XTABS
   (so im Code; vermutlich Fehler des Originals, wortgetreu uebernommen).
   `dac` 4800 Baud 24x80 `ANYP+CRMOD+ECHO+XTABS+SCOPE`; `ban` 9600 24x80 `CRMOD+ECHO+XTABS+SCOPE`; `tek` 9600 30x72 `ANYP+CRMOD+ECHO+XTABS`;
   `sat` 9600 0x0 `ANYP+CRMOD+ECHO+XTABS+LCASE`; `tty33` crdly 5; `tty37` nl 6, cr 10, ht 5, vt 0261, XTABS aus; `vt05` nl 6; `tn300` cr 5; `ti700` cr 10.
   Namen der Verzoegerungswerte (`NL1` ...) gibt es im MUTOS-`sgtty.h` nicht: im Quelltext stehen die gemessenen Zahlen.
3. `ek`: erase DEL (0177), kill `^U` (025) statt `#`/`@`.
4. Gelesen/geschrieben wird mit `ioctl(1, TIOCGETA, &mode)` / `ioctl(1, TIOCSETA, &mode)` (0x740C / 0x740B), nicht `gtty/stty`.
5. `prmodes`: `crmod ` (V7 `-nl `), `erase = DEL; ` (neu), `scope indctl tandem`, `-tabs` ueber ein Bit (`m & XTABS`), kein `delay((m&NLDELAY)/NL1,..)`;
   stattdessen Zeilen `nldly crdly htdly vtdly` und `width length` ueber `delay(value, name)` mit Format `"%s\t%d\n"`, je Gruppe ein `"\n"`.
6. Die Kette endet mit `if (eq("ti700")) ... else for (speeds)`: der V7-Zweig `if (eq("hup")) .. else for (speeds)` wurde offenbar durch Einfuegen der neuen
   Zweige auseinandergerissen -- das `else` haengt nun an `ti700`; `hup` ist ein eigener `if`.  Belegt durch den Sprung `JR Z,04E8` hinter `ti700`
   (Geschwindigkeits-Schleife) und Durchfall in die Modus-Schleife.

## Ergebnis (`cc -O -s`, c2-Modell aus `c2_emu_s`)
| Messung | Ergebnis |
|---------|----------|
| Eigener Code 0030-0816 | 646 von 646 Befehlen, **Laenge 0030-0816 wie im Original**; Wortvergleich: ausser Adressoperanden kein Unterschied; Befehlsvergleich mit R1-R10: 27 Abweichungsbloecke, alle Adressoperanden (21x `stderr`-Adresse `_iob+..`, 6x libc-Ziel `atoi`) |
| Datenteil des Programms (122C-15C8, 0x39C Byte: Tabellen, Zeichenketten, `speed[]`) | wortweise gleich; Unterschied nur die um +0x544 verschobenen Zeiger (grosser libc-Teil davor) |
| Ganzdatei | nicht bytegleich: `printf`-Familie zieht die ausgelieferte `libc.a` (Text 5996 statt 4652), Stolperstein 1 in `README.md` |

## c2-Regeln
Neu nur **R10** (`uspace.py:c2_emu_s`): `XORB RHn,RHn ; CP Rn,.. ; JR cc,L ; ADD Rn,..` -> der Original-`c2` setzt `XORB RHn,RHn` hinter dem `JR cc`
nochmals (der Disketten-`c2` weiss, dass RHn noch null ist).  Stellen: 2 (`prmodes`, `erase`/`kill` `'@' + sg_erase`; ohne die Regel ist der gebaute Code um 4 Byte kuerzer).
Sonst nur bekannte Regeln: R1 8x, R2 2x, R4 1x.  Der Wechsel `TEST R2` / `TESTB RL2` hinter `eq(..)` im Original ist **kein** Quelltextunterschied:
der `cc` erzeugt ihn selbst.

## Offen
* Ganzdatei-Bytegleichheit: braucht die alte `libc.a` (nicht Aufgabe dieses Programms).
