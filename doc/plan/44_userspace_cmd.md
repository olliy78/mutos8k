# Plan 44: Userspace der Disketten `cmd`, `bin`, `usr` (Fortsetzung H7)

Stand 2026-11-10.  Vorlage: Plan 42 H7, Plan 43; Methode und Stolpersteine: `doc/userspace/README.md`, `doc/userspace/pipeline.md`.
Ziel: jedes Programm der Disketten so zurueckbauen, dass der MUTOS-`cc -O -s` im Emulator-Gast aus `userspace/NAME/NAME.c` das
Original erzeugt (V7-Text, wo er genuegt), mit demselben Beweisstandard wie bei den elf Programmen der Wurzeldiskette.
Dieses Dokument ist als Arbeitsauftrag fuer Agenten geschrieben (Modell Sonnet): jeder Auftrag ist in sich abgeschlossen.

## 1. Bestand (gemessen aus `disks/original/a5120_mutos8000_best_*.zip`, Dateigroessen)

* `cmd` (`bin/`): echo 2168, pwd 3460, df 3562, cp 3592, chmod 3710, kill 3808, mkdir 3950, strip 4030, size 4064, cat 4088, wc 4148,
  rmdir 4160, hex 4326, ln 4330, convert 4602, cmp 4656, chown 5522, od 5552, rm 5782, nm 6028, who 6662, mv 6836, pstat 6866, dd 7296,
  ps 7846, ls 8260, pr 8310, passwd 9140, ar 10050, ed 11472.
* `cmd` (`etc/`): clri 3574, mknod 3954, dcheck 4514, ncheck 5078, icheck 6542, mkfs 8406.
* `bin`: mt 4342, tar 17000, adb 27770.
* `usr`: Toolchain `bin/cc` 6536, `bin/ld` 10726, `bin/as` 35814, `lib/cpp` 16382, `lib/c0` 26826, `lib/c1` 35774, `lib/c2` 18976, `lib/libc.a` 71914.
* V7-Quellen: `original/unix-v7/usr/src/cmd/NAME.c` (vollstaendig), Hippe-Sammlung `original/hippe-v7/usr/src/cmd` (nur teilweise).
  Hippe-Sammlung nur als Vergleichsreferenz nennen, nie als Urheber (Memory `hippe-sammlung-keine-urheberschaft`).

## 2. Reihenfolge und Begruendung

Die Reihenfolge folgt dem erwarteten Aufwand (*Annahme*, durch Stufe 0 zu belegen): je weniger libc-Glieder ein Programm bindet, desto weniger
Behelfe (`libc_alt`, c2-Regeln mit einer Stelle) braucht die Ganzdatei-Bytegleichheit (README Stolperstein 1, Punkt 5).

| Stufe | Inhalt | Stand |
|-------|--------|-------|
| 0 | Triage: je Programm der `cmd`-Diskette `holen`, `karte`, libc-Glieder (`NAME.namen`) | Agentenauftrag A0, Host, Sekunden |
| 1 | Kleine Befehle: echo, pwd, rmdir, mkdir, chmod, kill, cp, ln, wc, size | Auftraege A1-A3 |
| 2 | Dateisystemwerkzeuge `/etc`: clri, mknod, dcheck, ncheck, icheck, mkfs | spaeter; V7-Header `filsys.h`, `ino.h` lokal beilegen |
| 3 | Mittlere/grosse Befehle: df, rm, mv, od, who, nm, strip, cmp, chown, dd, ps, pstat, pr, passwd, ar, ed, hex, convert | spaeter |
| 4 | Toolchain `as`, `ld`, `cc`, `cpp`, `c0`, `c1`, `c2` (Ziel: Selbsthosting, Regeln des alten c2 klaeren) | spaeter, eigener Plan |
| 5 | `bin`-Diskette: mt, tar, adb | zuletzt, niedrige Prioritaet |

Anmerkung zu Stufe 4 (*gemessen* an `original/unix-v7/usr/src/cmd`): In V7 haben Einzeldatei-Befehle (`echo.c`, `cp.c` ...) kein eigenes `makefile`;
das Skript `makeall` ruft je `*.c`/`*.s`/`*.y` `cmake` auf.  Mehrdatei-Programme (`sh`, `make`, `as`, `c`, `cpp`, `adb`, `awk`, `lex`, `yacc`, `sed` ...) sind
Unterverzeichnisse mit eigenem `makefile` und `*.h`.  Fuer die Toolchain (Selbsthosting) braucht jedes dieser Programme daher ein V7-`makefile`, das unsere
`make` im Gast versteht; die Pipeline-Reihenfolge (alphabetisch) ist bisher nur an `sh` gemessen, nicht gegen dessen `makefile` gegengelesen.

## 3. Regeln fuer alle Agentenauftraege

* Arbeitsverzeichnis ist ein eigener git-Worktree/Branch (`us-cmd-<auftrag>`); nie auf `main` committen, nie in einem anderen Worktree arbeiten.
* Emulator: Umgebungsvariable `K1520EMU=/home/olliy/projects/a5120emu` setzen; Werkzeuge nur ueber `tools/emu.py` bzw. `tools/userspace/pipeline.py`; nichts kopieren.
* Gast-Laeufe dauern Minuten: mit `run_in_background` starten, auf die Benachrichtigung warten, **nie** mit `sleep` pollen.  Platten nur als Kopien (die Pipeline tut das).
* Quellen: K&R-C, 7-Bit-ASCII, Kommentare auf Englisch, V7-Text soweit moeglich unveraendert.  Fehlende Header (`/usr/include` kennt nur `a.out ar ctype execargs grp math pwd sgtty signal stdio symbol time sys/{stat,types}`) aus `original/unix-v7/usr/include` in `PROGRAMME` eintragen; nie einen Header eintragen, den `/usr/include` hat.
* Quelltext bleibt V7-Text; jede Abweichung davon (auch Include-Zeilen) bekommt an der Stelle einen kurzen englischen Kommentar `/* Differs from V7: ... */`, sonst keine neuen Kommentare (Kommentare aendern die Bytes nicht, den Bau trotzdem erneut mit `cmp` pruefen).
* Dokumentation: Deutsch, Aussagen *gemessen* (mit Befehl) oder *Annahme*.  Pro Auftrag **eine eigene Datei** `doc/userspace/cmd_<auftrag>.md`; `README.md`, `pipeline.md` und `doc/herkunft/` nicht anfassen (das tut die Zusammenfuehrung).
* Aenderungen an `tools/userspace/pipeline.py`: nur Eintraege in `PROGRAMME` (eine Zeile je Programm).  Neue c2-Regeln in `uspace.py` nur, wenn ohne sie kein `0 Abweichungsbloecke` erreichbar ist; dann Stellenzahl angeben und **alle** bisherigen Programme (`sync cat date ls stty init login getty mount umount sh`) auf unveraenderte Bytegleichheit pruefen (README: Regeln koennen andere Programme zerstoeren).
* Nicht raten: ein Unterschied, den keine Quellvariante erklaert, wird gemessen berichtet, nicht wegmodelliert.

## 4. Ablauf je Programm (Definition of Done)

1. `pipeline.py holen NAME --platte cmd --pfad bin/NAME`, dann `karte NAME --ablegen` (Karte, Listing, `NAME.namen`, `NAME.strings` neben die Quelle).
2. Quelle: V7-`NAME.c` nach `userspace/NAME/NAME.c` (bei Abweichungen: aus Listing und Zeichenketten rekonstruieren, jede Abweichung gegen V7 im Dokument belegen).  Eintrag in `PROGRAMME` (Platte `cmd`).
3. `pipeline.py alles NAME` (Hintergrund).  Erst ohne c2-Modell lesen: Bericht auswerten, Kopf (text/data/bss), Bytegleichheit, Befehlsabweichungen.
4. Bei Abweichungen zuerst Quellvarianten pruefen (andere Zeichenketten, Reihenfolge der Deklarationen, `register`), dann `--c2emu` und bekannte Regeln R1-R10, R20-R31; neue Regel nur nach Punkt 3 oben.
5. Ergebnis je Programm eine von vier Aussagen, im Dokument festgehalten:
   **(G)** ganzdatei bytegleich; **(E)** Eigencode bytegleich/befehlsgleich, Ganzdatei nicht (libc-Anteil, dann die abweichenden Glieder nennen);
   **(A)** Abweichung ungeklaert (Unterschied beschreiben); **(F)** Fehlschlag (Ausgabe beifuegen).
6. `python3 -I tools/userspace/pipeline.py --check NAME` und `pytest tests/test_userspace_pipeline.py -q` gruen bzw. Exit 77 ohne Emulator.
7. Commit je abgeschlossenes Programm (Quelle, Karte-Dateien, `PROGRAMME`-Zeile), Doku-Commit am Ende.  Nachricht deutsch, kurz, mit den Attributionszeilen aus der Sitzung.

## 5. Auftraege der Stufe 1

* **A0 (Triage, ich selbst):** `holen` + `karte` fuer alle Programme von `cmd`; Tabelle Programm x gebundene libc-Glieder in `doc/userspace/cmd_triage.md`.  Haengt keine andere Arbeit ab; Ergebnis kann die Aufteilung A1-A3 aendern.
* **A1:** echo, pwd, rmdir, mkdir.  **A2:** chmod, kill, cp, ln.  **A3:** wc, size.  (Gleicher Aufwand; `wc` ist V7 mit stdio, `size` liest a.out-Koepfe.)
* Berichtsformat jedes Agenten (knapp): je Programm Aussage G/E/A/F, Bytezahlen, Quellherkunft (V7 unveraendert / Abweichungen), neue Regeln mit Stellenzahl, Branch, Commit-IDs.

## 6. Zusammenfuehrung (ich)

1. Branches nacheinander nach `main` mergen; `PROGRAMME`-Konflikte von Hand loesen.
2. Regressionslauf Bytegleichheit: alle elf Wurzelprogramme + alle neuen Programme mit den in der Dokumentation genannten Befehlen, `pytest tests/test_userspace_pipeline.py`.
3. Herkunft dokumentieren: Abschnitt in `doc/userspace/README.md` (Tabelle Programm -> Herkunft -> Aussage G/E/A/F), Verweis auf `cmd_*.md`; `doc/herkunft/` ergaenzen.
4. Commit auf `main`; nicht pushen ohne Auftrag.
