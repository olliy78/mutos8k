# Gastbau des Kernels (Branch `mutos-plus`)

Plan: `doc/plan/47_mutos_plus.md` §7.  Arbeitsordner der Messungen: `/tmp/mplus/<schritt>/`.

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
