# W10c: Ursache der zerstueckelten c2-Ausgabe gefunden (libc_alt-Anker), Gegenprobe nach der Behebung offen

Fortsetzung von `wk_w10b.md`. Alles *gemessen*, ausser wo *Annahme* steht. Werkzeug: `tools/userspace/c2gegen.py` (erweitert, siehe unten).

## 1. Befund im Gast

* Lauf mit `echo` (c1-Ausgabe 1323 B, Original-c2 liefert `echo.s` 1257 B): **unser c2 endet nicht.** Er schreibt, bis `/tmp` voll ist
  (`no space on dev 4/0` im Takt der Schreibversuche; der Gast bleibt danach in der Leerlaufschleife des Kerns, das war der "Hang" von W10b Lauf B).
* Die ersten 31232 Byte der Endlosausgabe (Sitzung mit `... & ` und `sync`, `echo.sn`) enthalten keinen c2-Kopf, sondern **Stuecke des Eingabetextes**
  (`d\tr2,r13`, `bitb %E+__iob,#%0`, `jp ne L6000` ...) an falschen Stellen, mit Luecken (`0xFF`) dazwischen. Das ist das Bild aus W10b (Fragmente von `.s0`
  in der Ausgabe), nur ohne Ende: Ein-/Ausgabepuffer ueberlappen.

## 2. Ursache

c2 benutzt die statischen stdio-Puffer `_sibuf` (stdin) und `_sobuf` (stdout). Im Original liegen sie bei **513A** und **533A** (512 Byte auseinander;
Beleg: `LD R2,#%513A` / `#%533A` in `_filbuf`/`_flsbuf`, `LD %553A,R7` = `_environ` in `crt0`, danach eigene c2-Variablen ab 553C).

`userspace/libc_alt/c2.members` nannte die Commons dagegen **52CC / 54CC / 56CC** (die Voreinstellung von `members_auto`: `bstart - 2 - 0x400`). Daraus erzeugte
`libc_alt.py` fuer `flsbuf` zwei verschiedene Operandenformen: `ld r2,#%513A` (absolutes Literal, weil 513A *vor* dem angenommenen Anker liegt) und
`ld r2,#%6E+__sibuf` (Anker + Abstand). Im Originallayout rechnen beide richtig. In **unserem** Bau steht das Datensegment 20 Byte tiefer (Text 16956 statt 16976 B,
`wk_w10b`): `__sibuf` landet bei 5126, das Literal zeigt weiter auf 513A, und `%6E+__sibuf` ergibt 5194. Gemessen im Listing `neu_c2.lst` vor der Behebung:
stdin-Puffer = 513A..533A, stdout-Puffer = 5194..5394, also **90 Byte Abstand statt 512**; jedes `putchar` zerstoert den Eingabepuffer und umgekehrt, die Listen
von `input()` werden mit Mischtext gefuellt und `output()` laeuft ohne Ende. Es ist dieselbe Art Fehler wie bei den drei `as`-Fehlern (W7p, W7s): eine im Original
benachbarte Anordnung wurde angenommen, nicht erzwungen -- hier in der Rueckbau-libc, nicht in den c2-Quellen.

Die c2-eigenen Felder (`c2.h`) sind **nicht** die Ursache: alle absoluten Datenoperanden des Eigencodes (549 im Original, 549 + 7 Disassembler-Artefakte im Bau) stimmen
nach Abzug der 20 Byte Textversatz mit dem Original ueberein (Skript-Vergleich der Operandenfolgen, Differenzen nur in als Daten fehldeutetem Text).

## 3. Behebung

`userspace/libc_alt/c2.members.zusatz` ersetzt die drei Zeilen (Mechanismus wie `ps.members.zusatz`):

    common __sibuf 513A 200 data
    common __sobuf 533A 200 data
    extern _environ 553A 2

`libc_alt.py members c2` und `quelle c2` (Host) erzeugen `data.s`, `filbuf.s`, `flsbuf.s` neu: `ld r2,#__sibuf`, `ld r2,#__sobuf`, `__iob` mit `WV __sibuf` statt `BV %51;BV %3A`.
Nur `flsbuf` (Quelle `G`) geht in `libc_alt/c2/libc_alt.a` ein; `data` kommt aus dem init-Archiv, `filbuf` aus der Auslieferung (beide waren schon symbolisch).
Wachposten (`libc_alt.py bau c2`, Gast-`as -u`, 26 s): `flsbuf endopen malloc` Text/Daten/BSS gleich dem Original, **0 Glieder abweichend**. Die Rueckbau-libc bleibt also bytegleich zum Original bei
Originaladressen und ist jetzt in jedem Layout richtig.

Neubau (`alles c2 --c2emu --libc alt --ist neu_c2`, 187 + 81 s): `neu_c2.bin` 18956 B, 4609 von 4717 Befehlen gleich (unveraendert), Kopf text 16956 / data 1984 / bss 3296.
Gemessen im neuen Listing: `_filbuf` und `_flsbuf` laden `#%5126` (stdin) und `#%5326` (stdout), **512 Byte Abstand**, `crt0` speichert `_environ` bei 5526 -- jeweils Originaladresse minus 20.

## 4. Werkzeug

`c2gegen.py lauf NAME... --c2x BIN [--c2o BIN] [--s0]`: je Modul `MOD.s` (ausgeliefert), `MOD.sn` (unser c2 mit Dateiargumenten), `MOD.sm` (zweiter Lauf), `MOD.sp`
(unser c2 mit Shell-Umlenkung statt `freopen`), `MOD.sb` (ausgeliefert, zweiter Lauf), `MOD.so` (ausgelieferte Binaerdatei von `/mnt` gestartet; Kontrolle).
Wiederholungen werden im Gast mit `cmp` verglichen und bei Gleichheit geloescht (`/tmp` ist klein); `MOD.cmp` haelt die Meldungen, der Host druckt je Modul `IDENTICAL`/`DIFFERS`.
`--s0` ueberspringt cpp/c0/c1 und nimmt `MOD.s0` einer frueheren Sitzung. Gastbefehlszeile unter 200 Zeichen; `dd`, `sleep` und `kill` liegen nicht in `PATH` (`/bin:/usr/bin:.`).

## 5. Offen

1. **Gegenprobe mit dem behobenen Bau ist nicht gelaufen**: die vier erlaubten Gastlaeufe sind verbraucht (Lauf `echo cat` -- Hang; Einzelschritt-Sonde -- Hang mit `no space`;
   Sonde mit `dd` -- `dd: not found`; Sonde mit Endlosausgabe -- Ergebnis aus Abschnitt 1). Naechster Schritt:
   `python3 -I tools/userspace/c2gegen.py lauf echo cat ed tar --c2x userspace/c2/work/bau/neu_c2.bin --c2o userspace/c2/work/c2.orig`.
   Erwartung (*Annahme*): `echo`/`cat` laufen durch; ob die Ausgabe byteweise gleich ist, haengt von den 28 Differenzbloecken der c2-Logik ab (nicht untersucht).
2. Die Eigencode-Abweichungen in `retopt` (`p == 0`, wenn der erste Block kein `call csv` hat) und `iterate` (`p->op <= JSW` schliesst `op 0` ein, `p->ref == 0`)
   lesen Adresse 0 (dort liegt der Text von `crt0`); das Original tut dasselbe (gleiche Befehlsfolge), ein Host-Lauf des c2-Quelltexts ist deshalb ohne Nachbildung
   dieser Lesungen nicht moeglich (versucht: Segfault in `iterate`/`retopt`).
3. Andere `libc_alt/*.members` mit abgeleiteten Commons (`bstart - 2 - 0x400`) koennen denselben Anker-Fehler haben, sobald ihr Bau vom Originallayout abweicht
   (nur relevant, wo der Eigencode nicht befehlsgleich und gleich lang ist).
