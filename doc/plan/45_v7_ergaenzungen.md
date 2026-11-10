# Plan 45: V7-Ergaenzungen -- Befehle, die auf den MUTOS-Disketten fehlen

Stand 2026-11-10.  Vorlage: Plan 44 (Rueckbau vorhandener Programme).  Hier geht es um das Gegenteil: Programme, die **nicht** auf den Originaldisketten
liegen, aus den V7-Quellen (`original/unix-v7/usr/src/cmd`) mit dem MUTOS-`cc` fuer MUTOS bauen und als **Ergaenzung** (nicht als Original) fuehren.
Auftrag des Projektinhabers (2026-11-10): fehlende V7-Programme wie `make`, `yacc`, `bc`, `egrep` aus V7 nachbauen und ergaenzen.

**Grundsatz (Entscheidung des Projektinhabers, 2026-11-10): MUTOS bleibt ein UNIX V7.**  Ergaenzt wird nur, was V7 selbst enthaelt (`original/unix-v7`).
Keine Programme aus System III oder anderen Quellen (z. B. `fsck`, `fsdb`, die in V7 fehlen); `original/sys3` bleibt Vergleichsmaterial.  Die vorhandenen Dateisystemwerkzeuge
(`icheck dcheck ncheck clri mkfs`) sind die V7-Werkzeuge und passen zum System.

## 1. Bestand (gemessen)

Alle Abbilder in `disks/original` (`best_*.zip` und die einzelnen `td0`) per `k1520disktool ls` ausgelesen; die `td0` enthalten **keine** Befehle ausser den
unten genannten (`m8k2_usr`, `m8k_root` sind fuer das Werkzeug nicht lesbar).  Vorhanden sind:

* `root`: cat date login ls sh stty sync, `etc/` getty init mount umount.
* `cmd`: ar cat chmod chown cmp convert cp dd df echo ed hex kill ln ls mkdir mv nm od passwd pr ps pstat pwd rm rmdir size strip wc who; `etc/` clri dcheck icheck mkfs mknod ncheck.
* `usr`: as cc ld, `lib/` cpp c0 c1 c2 (`convert`, `hex` sind kein V7).  `bin`: adb mt tar.  `nroff`: nroff samt Tabellen.
* Nur in einem Root-Image (`a5120_mutos8000_root.td0`) zusaetzlich: `update`, `rc`, `mkdir.tot` -- nicht in der Best-of-Zusammenstellung (*Annahme*: ungeprueft, ob lauffaehig).

**Es fehlt ein grosser Teil von V7**, u. a.: `grep fgrep egrep sort find sed tr tail uniq comm diff tee test expr sleep touch time nice su write wall mail cal basename du file`,
`make yacc lex m4 bc dc awk`, `cron at ac restor dump quot`.  Aufstellung aus `ls original/unix-v7/usr/src/cmd` abzueglich des Bestands (siehe Abschnitt 4).
(Unser `make` unter `userspace/make` ist selbst gebaut und liegt nicht auf den Disketten.)

## 2. Was "bytegleich" hier bedeutet -- nichts

Es gibt **kein Original**, gegen das man vergleichen koennte.  Die Beweisstandards aus CLAUDE.md gelten abgewandelt:

1. **Bau:** `cc -O -s` des unveraenderten MUTOS-Gastes uebersetzt die Quelle fehlerfrei; Abweichungen vom V7-Text sind minimal und mit `/* Differs from V7: ... */` kommentiert.
2. **Funktion:** ein skriptgesteuerter Gast-Test (Marke `gast`, Exit 77 ohne Emulator) vergleicht die Ausgabe mit einer Erwartung, die auf dem Host mit einem Referenzwerkzeug (GNU/BSD) oder aus dem V7-Handbuch (`original/unix-v7/usr/man`) bestimmt wurde.  Erwartung und Herkunft stehen im Test.
3. **Kennzeichnung:** Die Programme liegen unter `userspace/ergaenzung/NAME/` (nicht unter `userspace/NAME/`), die Doku fuehrt sie als *Ergaenzung, V7-Quelle, keine Originalreferenz*.  Nie als "rekonstruiert" bezeichnen.
4. **Diskette:** ein eigenes Abbild `v7erg` (zusaetzliche Platte; Bauangaben wie `tools/disks/bauangaben_cmd.yaml`), nicht in die Originalabbilder mischen.

## 3. Grenzen der Ziel-Toolchain (*Annahmen*, je Programm zu messen)

* Der MUTOS-`cc` ist K&R-C mit 8 signifikanten Zeichen; V7 ist PDP-11-C -- `int` ist hier 16 Bit wie dort, `long` 32 Bit.  Groessenabhaengiges (Zeiger in `int`, `char`-Vorzeichen) pruefen.
* Die ausgelieferte `libc.a` hat keinen Gleitkomma-`printf` (README Stolperstein 1): Programme mit `double` (`units`, `spline`, `graph`, `awk`, `bc` nicht, `dc` nein) brauchen eine passende libc oder entfallen.
* `.y`-Quellen (`bc`, `egrep`, `expr`) brauchen `yacc`; bis dahin liegt das erzeugte `y.tab.c` vom Host (aus V7-`yacc`) bei, oder `yacc` wird zuerst gebaut (V7-`yacc` besteht aus C-Quellen, braucht kein `yacc`).
* Programme, die PDP-11-Kernelstrukturen lesen (`dmesg`, `iostat`, `sa`, `prof`, `ps`-artiges), und Mehrdatei-Grosswerke (`f77`, `troff`, `lint`, `pcc`, `uucp`) bleiben ausserhalb.
* Das Z8000-Textsegment ist 64 KB: grosse Programme (`awk`, `sed`, `m4`) auf Passen pruefen.

## 4. Reihenfolge

| Stufe | Programme | Begruendung |
|-------|-----------|-------------|
| E0 | Rahmen: `userspace/ergaenzung/`, Pipeline-Modus ohne Original (nur `bau` + Funktionstest), Test-Skelett, Diskette `v7erg` | Voraussetzung, ein Agent |
| E1 | Kleine Einzeldatei-Befehle: `basename tee sleep touch yes tty mesg sum rev uniq comm split tail cal look nice time test` | wenig libc, einfache Tests |
| E2 | Alltagswerkzeuge: `grep fgrep sort find diff (diffh) tr join du file expr` | grosser Nutzen; `expr` braucht `yacc` (E3) |
| E3 | Entwicklungswerkzeuge: `yacc` (zuerst), dann `make` (V7, `gram.y`), `egrep`, `bc`, `dc`, `lex`, `m4`, `sed`, `ranlib`, `tsort` | `make` = Selbsthosting; `yacc` schaltet `.y` frei |
| E4 | Systemverwaltung: `su newgrp chgrp mail write wall update cron at ac restor dump quot` | haengt von Kernel und Konfiguration ab (utmp, acct), je Programm klaeren |
| E5 | Rest nach Bedarf: `awk`, `ratfor`, `units`, `ptx`, `crypt`, ... | gross oder Gleitkomma |

`make`: V7-`make` (Verzeichnis `make/`, 8 `.c` + `gram.y`, Mehrdatei) neben unserem `userspace/make`; Vergleich beider ist ein eigener Auftrag.

## 5. Regeln fuer Agentenauftraege

Wie Plan 44 Abschnitt 3 (Worktree/Branch `us-erg-<auftrag>`, `K1520EMU=/home/olliy/projects/a5120emu`, Gast-Laeufe ohne `sleep`-Polling und ohne die Runde mit "warte auf Hintergrundlauf" zu beenden,
Doku deutsch in `doc/userspace/erg_<auftrag>.md`, `README.md` nicht anfassen, je Programm ein Commit, Nachricht deutsch mit Leerzeile vor den Attributionszeilen, nicht pushen).  Zusaetzlich:

* Quelle = V7-Text; jede Abweichung kommentiert (`/* Differs from V7: ... */`).  Bei Abweichung die **Ursache** nennen (Compiler, libc, Header, Wortbreite).
* Ergebnis je Programm: **B** (baut, Test gruen), **T** (baut, Test zeigt Abweichung -- beschreiben), **N** (baut nicht -- Compilermeldung beilegen, Ursache), **X** (bewusst ausgelassen, mit Grund).
* Fehlende Header: aus `original/unix-v7/usr/include` flach neben die Quelle (wie Plan 44); nie einen vorhandenen `/usr/include`-Header ersetzen.
* Tests: `tests/test_erg_<auftrag>.py`, Marke `gast`; Erwartungswerte mit Herkunft.

## 6. Zusammenfuehrung

Merge der Branches, Regressionslauf der Rueckbau-Programme (Plan 44 Abschnitt 6) unveraendert, dazu die Funktionstests der Ergaenzungen; Uebersicht in `doc/userspace/README.md` (eigener Abschnitt "Ergaenzungen, keine Originale").

## 7. Schnittstelle des Rahmens E0 (Vertrag fuer parallele Agenten)

Damit E1/E2-Agenten parallel zu E0 arbeiten koennen, ist die Schnittstelle vorab festgelegt.  E0 setzt sie um (`tools/userspace/erg.py`); die Programmagenten
bereiten Quelle und Test vor und benutzen sie, sobald der Branch `us-erg-e0` den Commit "E0: Rahmen nutzbar" enthaelt (`git log us-erg-e0 --oneline`; mit `git merge us-erg-e0` uebernehmen).

* **Ordner je Programm:** `userspace/ergaenzung/NAME/` mit `NAME.c` (oder mehreren `*.c`/`*.h` bei Mehrdatei-Programmen), `erg.json`
  (`{"header": ["sys/xxx.h", ...], "flags": "-O -s", "quelle": "original/unix-v7/usr/src/cmd/NAME.c"}`; `header` = V7-Header relativ zu `original/unix-v7/usr/include`,
  flach neben die Quelle gelegt) und `test/`.  Es gibt **keine gemeinsame Tabelle** (kein `PROGRAMME`-Eintrag), damit parallele Branches nicht kollidieren.
* **Test je Programm:** `test/befehle.sh` (Gast-Shell-Skript, Standardausgabe wird verglichen), `test/erwartet.txt` (Soll-Ausgabe), optional `test/eingabe/*` (Dateien,
  die vor dem Lauf nach `/tmp` des Gastes kommen) und `test/herkunft.txt` (woher die Erwartung stammt: Referenzwerkzeug mit Befehl und Version, oder V7-Handbuchstelle).
* **Aufrufe:**
  * `python3 -I tools/userspace/erg.py bau NAME [--parallel N]` -- Gast-Bau `cc -O -s`; Ergebnis `userspace/ergaenzung/NAME/work/bau/NAME.bin` (git-ignoriert), Meldungen `NAME.err`.  Exit 0 = gebaut.
  * `python3 -I tools/userspace/erg.py test NAME` -- baut bei Bedarf, fuehrt `befehle.sh` im Gast aus, vergleicht mit `erwartet.txt`; Exit 0 = gleich, 1 = Abweichung (Diff ausgeben), 77 = Emulator fehlt.
  * `python3 -I tools/userspace/erg.py alles NAME...` -- bau + test fuer mehrere Programme, Ergebniszeile je Programm (B/T/N, siehe Abschnitt 5).
* **Gast:** wie Plan 44 (Laufwerk A leeres `/tmp`, `usr` fuer `cc`, Quelle auf `/mnt`); Platten nur als Kopien; Gast-Zeit 1987.
* **Pytest:** `tests/test_erg.py` sammelt alle `userspace/ergaenzung/*/test` (Marke `gast`, Skip ohne Emulator); jeder Programmagent traegt nichts in diese Datei ein, sie findet die Ordner selbst.
