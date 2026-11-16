# Gastbau des Kernels (Branch `mutos-plus`)

Plan: `doc/plan/47_mutos_plus.md` §7.  Arbeitsordner der Messungen: `/tmp/mplus/<schritt>/`.

## 0. Gastlauf mit Diskettenwechsel (`tools/plus/gastlauf.py`, P1.0)

`lauf(arbeit, disketten, befehle, rueck, boot_hfe=None, ausfuehrbar=(), frist=...)`: `disketten` = Liste von `{name: bytes}` (je Eintrag eine
26x128-MFM-Quelldiskette, Disk 0 wird als D/`/mnt` eingelegt); `befehle` = Shellbefehle oder `("wechsel", i)`.  Der Wechsel macht im Gast
`cd /; /etc/umount /dev/rk3`, im Debugger `eject D` + `mount D d<i>.hfe`, im Gast `/etc/mount /dev/rk3 /mnt; cd /mnt`.  Jeder Schritt endet mit einer
Marke (`cat fertigN`); die Marken des Umhaengens liegen auf A (`/tmp`), alle anderen auf jeder Quelldiskette.  Dateien bekommen mtime 1987.
Ohne Emulator: `Fehlt` bzw. Exit 77 (`python3 -I tools/plus/gastlauf.py [arbeit]` fuehrt die Probe aus).

Probe (gemessen 2026-11-16, Arbeitsordner `/tmp/mplus/p1_0/`, 26 s Wanduhr): Disk 1 `a.txt`, Disk 2 `b.txt`; `cat a.txt >/tmp/a`, Wechsel,
`cat b.txt >/tmp/b`, `ls /mnt >/tmp/l` -> `/tmp/a` = `AAA`, `/tmp/b` = `BBB`, `/tmp/l` = `b.txt fertig1..fertig5` (ohne `a.txt`).  **Abnahme erreicht.**
Das Umhaengen im laufenden Gast (Debugger `eject`/`mount` nach `umount`) funktioniert ohne Zusatzmassnahmen.

## 1. Ausgangsmessung des natuerlichen Baus

**Stand 2026-11-16: BLOCKIERT (P1.1 nicht abgenommen).**  Das Uebersetzen im Gast gelingt, der natuerliche Bau scheitert aber vor dem
Gast-`make`, weil die Quelldiskette D (`/mnt`) die heutigen Quellen nicht mehr fasst.

Befehl (gemessen, 2026-11-16):
`python3 tools/kernel/gesamtbau.py --arbeit /tmp/mplus/p1_1 --uebersetzen --natuerlich --boot >/tmp/mplus/p1_1.log 2>&1`

* `--uebersetzen`: sechs parallele Gastlaeufe (`cc -O -c`), ca. 5 Min. Wanduhr, 30 Objekte in `/tmp/mplus/p1_1/obj/` (gemessen).
* `natuerlicher Bau: 60 Dateien, 291861 Byte` (Log); im Arbeitsordner `gast_nat/q/` 65 Dateien, 312 414 Byte inkl. `fertig*`-Marken.
* `gast_as.gast_befehle` -> `k1520disktool put quelle.hfe ...` bricht ab: `Fehler: Kein Platz mehr auf dem Datentraeger`
  (Abbruch bei `sys1.c`; Log `/tmp/mplus/p1_1.log`, `RuntimeError: put:` in `gast_as.py:203`).
* Kapazitaet einer leeren `mutos8k_26x128_mfm`-Diskette: **239 KB frei** (`k1520disktool ls <leer.hfe> -l`, gemessen).  Bedarf: 291 861 B Nutzdaten
  (ohne Blockrundung; `kernel/c`+`kernel/conf` allein 228 239 B, `kernel/h` 48 682 B).
* Ursache (abgeleitet): `doc/kernel/gesamtbau.md` nennt fuer den Lauf vom 2026-10-28 "Quellen+Header 172 KB".  Seitdem sind die C-Quellen und Header
  durch Plan 43 (Kommentare, bytegleiche Umformungen) und die Hippe-Angleichung gewachsen (`git diff --stat 01e126b..HEAD -- kernel/c kernel/h kernel/conf`:
  53 Dateien, +5475/-2370 Zeilen; z. B. `tty2.c` 16 076 -> 23 239 B).
* Folge: Messwerte (Text/Daten/BSS, b1..b11, sha256 von `lk`/`mutos_1216.nat`) liegen **nicht** vor.

Nicht behoben, weil die Abhilfe Dateien von `main` betrifft (Plan 47 §6 Regel 2): `tools/kernel/gesamtbau.py` (`nat_quellen`) / `gast_as.py` (`gast_befehle`)
legen alles auf eine 239-KB-Diskette.  Moegliche Wege (Empfehlung: erster):
1. Neues Hostwerkzeug unter `tools/plus/`, das `nat_quellen` importiert und die Quellen **ohne Kommentare/Leerraum** auf D legt (der Kernel aendert sich
   dadurch nicht; Pruefung: Objekte bytegleich zu `/tmp/mplus/p1_1/obj/`).  Reicht rechnerisch nur, wenn der Rest unter 239 KB faellt (Annahme, ungemessen).
2. Aufteilen auf zwei Disketten (D und eine weitere); alle vier Laufwerke sind aber belegt (A `/tmp`, B `/usr`, C Wurzel, D `/mnt`).
3. Eine groessere Diskette fuer D (`--blocks`/anderes `--fs`), sofern der Emulator ein passendes Format fuer `rk3` kennt (ungeprueft).

### 1.1 Zweiter Versuch mit Diskettenwechsel (`tools/plus/basis.py`, gemessen 2026-11-16)

Aufruf: `python3 -I tools/plus/basis.py --boot` (Objekte aus `/tmp/mplus/p1_1/obj/`, `nat_quellen` auf zwei Quelldisketten verteilt, Gastlauf mit `gastlauf.lauf`).
* Disk 1: 41 Dateien, 184 852 B (Header, `make`, `mk1`, C-Dateien `alloc`..`sig`); Disk 2: 46 Dateien, 197 015 B (Header, `make`, `Makefile`, `slp`..`sysent`,
  `low/bss/shim/dn*.s`, `abs.o`).  Beide passen.
* Lauf 1 (907 s): `ld:bss.o: output error` -- A (`/tmp`) voll.  `bss.o` besteht aus 35 948 B Nullen (BSS als Daten), `lk` 53 864 B, dazu Zwischendateien von `ld`.
* Lauf 2: `bss.o` nach `/mnt` -> `no space on dev 4/3`.
* Lauf 3 (1028 s, Log `/tmp/mplus/p1_1_basis3.log`): `as -u -o /bss.o` auf die **Wurzel** (40 KB frei) -> `make` und `ld` laufen durch.
  `lk`: text 34 652, data 19 196, **bss 2**; sha256 `8dce008cf1605283c8b94e12a6b82a4436f221394aa6a81d131398aff7a6d60d`.
  Kernel Text+Daten 36 290 B (Original 36 288), BSS 8DC2..D258 -> `basis.py` bricht mit "BSS reaches over the mailbox" ab; kein Boot.

**Ursachen (abgeleitet aus Objekten und Karte, 2026-11-16):**
1. Text 34 652 statt 34 650: der Fehler des Original-`c2` in `ttyinput` kostet das Original ein Wort, unser `cc` erzeugt es (Abweichung #1, `doc/herkunft/tty2.md`).
   Seit Plan 43 ist der uebrige Text bytegleich lang; am 2026-10-28 war der natuerliche Text noch 266 B kuerzer und liess Platz.
2. `bss 2`: `int nested;` in `kernel/c/trap.c` ist ein Common (2 B), das in `bss.s` keinen Namen hat (Original: 88E0); `ld` legt es hinter die BSS.
   (`_cfreeli` ist ebenfalls ein Common, wird aber von `abs.o` definiert.)
3. Die Grenze **D256 ist zu eng gezogen, die echte Grenze ist D266**: `cfree` (50 x 16 = 800 B, `kernel/c/ureg.c`) liegt im Original bei CF46..D266,
   unmittelbar danach `cfreelist` (D266, erstes absolutes Symbol in `abs.o`).  `bss.s` (z8kdis bis `BSS_BIS` = D256) deklariert `_cfree` nur mit 784 B (`%310`);
   der letzte Block von `cfree` liegt auch im Original jenseits D256.  Massgeblich: Ende von `cfree` (Anfang + 800) <= D266.
4. Mit 1.-2. liegt `cfree` 4 B zu hoch und ueberschriebe `cfreelist`.  Im Original ist zwischen BSS und D266 kein Byte frei.
Folge fuer P1: die extrahierten Quellen brauchen 4 B Platz in der BSS.  Weg: Plan 47 §7 P1.3 (Nachtrag 2026-11-16).

## 1.2 Bau aus `kernel/plus/` (P1.3, Vorgriff auf P1.5; gemessen 2026-11-16)

Aufruf: `python3 -I tools/plus/basis.py --plus --arbeit /tmp/mplus/p1_3` (Quellen aus `kernel/plus`, `kernel/c`, `kernel/conf`, `kernel/h`; `NCLIST` 49, `_nested` benannt,
`/bss.o` auf der Wurzel; Log `/tmp/mplus/p1_3/lauf.log`, 897 s Wanduhr, zwei Quelldisketten mit 184 852 B und 197 161 B).
* `make1.log`/`make2.log` ohne Fehler, `lk` entsteht.  `lk`: text 34 652, data 19 198, **bss 0**; sha256 `9e0681c3b0d18b39938bb4166361cd60132ef3ec53346b4ee893b4beaff0486e`.
* Text+Daten des Kernels = 34 652 + 19 198 - 17 560 (BSS-Nullen, Summe der Groessen in `bss.s` = 0x4498) = **8DC2** (36 290 B; Original 36 288 = 8DC0, +2 durch `ttyinput`).
* BSS 8DC2..D25A, `_cfree` endet bei **D258** (Grenze D266, 14 B Reserve; `basis.grenze_pruefen`), danach `_nested` D258..D25A.  Kein Boot (P1.5).
* `basis.py` brach nach dem Lauf in der Auswertung ab (bytes/str-Fehler in `bss_groessen`, danach behoben); die Zahlen oben sind aus dem gesicherten `lk` nachgerechnet.

## 2. Gastbau ohne Host-Schritt (`tools/plus/gastbau.py`, P1.4/P1.5)

Aufruf: `python3 -I tools/plus/gastbau.py alles --arbeit /tmp/mplus/p1_5b >/tmp/mplus/p1_5b.log 2>&1` (`bauen`: nur Bau + Pruefung; `boot --kernel F`: nur Boot und b1..b11).
Quellen: `kernel/plus` (mk1, Makefile, `abs.s`, `bss.s`, `low.s`, `shim.s`, `dn0..3.s`), `kernel/c`, `kernel/conf`, `kernel/h`, `make`, dazu `dd`/`cmp` von der cmd-Diskette auf Diskette 2.
Der Host prueft nur (lk-Kopf, Ende der BSS, Laenge der Kernel-Datei) und vergleicht `mutos_1216` aus dem Gast mit dem Schnitt desselben `lk`; er veraendert kein Byte.

Aenderungen gegenueber P1.3 (gemessen im selben Lauf):
* `abs.o` -> `abs.s` (`$ABS %adr` / `G` / `_name L` / `_name:`).  Pruefung: Objekt aus dem Gast-`as` (`/tmp/mplus/p1_5_abs/abs.o`, Einzelprobe) hat per `objformat.py nm` dieselben 12 Symbole,
  Typen und Werte wie das alte `abs.o` (`diff` leer; `_cfreeli` D266 ... `_u` FC00).
* `bss.s` in `$SECTION BSS_B` ... `$SDEFAULT`: `lk` meldet **text 34 652, data 1 638, bss 17 560** (vorher data 19 198, bss 0); `bss.o` ist 856 B (vorher 36 KB), `/bss.o` auf der Wurzel entfaellt.
* `dn1.s`: `_max_pro` = `WV %38+_proc` statt der Zahl A154 (der Gast-`ld` verschiebt den Zusatzwert richtig: Kernel bootet, fork/exec/pipe laufen, b1..b9, b11).
  *Nicht direkt gemessen:* der Zahlenwert im Kernel (`lk` ist gestrippt); abgeleitet: `_proc` A11E + 38 = A156 (= `&proc[2]`).
* Makefile-Standardziel `mutos_1216: lk` mit **einer Pipe** aus den zwei `dd`-Aufrufen (`dd if=lk ibs=16 skip=1 obs=512 | dd of=mutos_1216 bs=512 conv=sync`).
  Die Variante mit Zwischendatei `lk.body` (zwei getrennte Aufrufe, `werkzeug_sonden.md` Frage 4) scheiterte im ersten Lauf: `write: No space left on device` auf A
  (Objekte, `lk` und `lk.body`; `mutos_1216` kam mit 33 280 statt 36 352 B an, `ls.log` fehlte).  Die Pipe ist in P1.2 als gleichwertig gemessen.

Messwerte (2026-11-16, Arbeitsordner `/tmp/mplus/p1_5b/`, Log `/tmp/mplus/p1_5b.log`):
* `lk`: text 34 652, data 1 638, bss 17 560; sha256 `dedf3ac26e1bf9505c3bbfbc4c18d2422b07d43ef26d8404836ad2632e11d973`.
* Kernel: Text+Daten 36 290 B = **8DC2**; BSS 8DC2..**D25A**, `_cfree` endet bei **D258** (Grenze D266, 14 B Reserve).
* `mutos_1216` aus dem Gast: 36 352 B (71 x 512), sha256 `3c2c232dec59053e8bb054ff2c49d03d69ab97753acf6f3aa6dd31f121c6d44c`, **bytegleich** zum Host-Schnitt aus demselben `lk` (Kopf ab, auf 512 gerundet).
* Boot bis `#`, Arbeitstests **b1..b9 und b11 bestanden** (b8 `summe = 5050` zweimal, b9 `prf.o` 1600 B, b11 ohne Fehler).  b10 `ps`: nur die Kopfzeilen, keine Prozesszeilen
  (erwartet: `cf_proctop`/0x23C zeigen noch nach P2.3).
* Laufzeit: Gastbau 852 s (erster Lauf, gleiche Quellen bis auf das Makefile-Ziel); Gesamtlauf `alles` 15 Min. 26 s, davon Boot + Tests 79 s.
* Nebenbefund: `df` gibt es im Gast nicht; `ls.log` zeigt A mit allen Objekten, `lk` 36 306 B, `mutos_1216` 36 352 B.

**Abnahme P1.5: erreicht** (alle drei Punkte).
