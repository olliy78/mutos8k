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
