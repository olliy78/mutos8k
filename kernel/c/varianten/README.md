# kernel/c/varianten -- historische Probedateien (nicht Teil des Baus)

Wegwerf-Probedateien aus den K7-Arbeiten (2026-10-27/28, `doc/kernel/c_rueckbau.md`): `pilot.c`, `djnz.c`, `djnz3.c`, `varianten.c`, `k7bvar.c`, `k7bv2.c`, `var7c.c`, `var7d.c`, `var7d2.c`.
Sie enthalten je Funktion mehrere Schreibweisen, mit denen der Gast-`c2` auf Unterschiede zum Kernel abgetastet wurde (DJNZ-Frage, Muster A..F).

* **Sie uebersetzen nicht mehr** (gemessen fuer `var7d*.c`, `tty2.md`; fuer die uebrigen nicht einzeln geprueft, wegen derselben Headeraenderungen angenommen).  Seit den Umbenennungen und Headeraenderungen der Herkunftsanalyse (H3-H6: Mitgliedsnamen in `tty.h`/`inode.h`/`proc.h`, `open1`, `max_proc`, `i_lrt` u. a.)
  passen die Probedateien nicht mehr zu `kernel/h` (`doc/herkunft/tty2.md`, `header.md`).  Sie wurden bewusst nicht nachgezogen.
* **Nicht Teil des Baus:** `tools/kernel/gesamtbau.py` fuehrt sie nicht auf, `tests/test_quelltext_regeln.py` prueft sie nicht (`SKIP_DIRS`).  Nichts im Repository haengt davon ab.
* **Nicht neu verwenden.**  Neue Probevarianten gehoeren in den Arbeitsordner eines Gastlaufs (`doc/herkunft/rundlauf.md`), nicht hierher.
* Einige Deutungen, die auf diesen Versuchen beruhen (insbesondere "alter `c2`" bei `bcopy`/`iomove`/`iupdat`), sind widerlegt; siehe den Hinweis am Anfang von `doc/kernel/c_rueckbau.md`.
* Die Dateien bleiben als Dokument des damaligen Erkenntnisstandes erhalten.
