# Ergaenzungen E1a: sleep, touch, yes, tty, mesg, sum, rev (Plan 45)

*Ergaenzung, V7-Quelle, keine Originalreferenz* -- diese Programme liegen nicht auf den MUTOS-Disketten und sind nicht rekonstruiert.
Quelle: `original/unix-v7/usr/src/cmd/NAME.c`, **unveraendert** nach `userspace/ergaenzung/NAME/NAME.c` kopiert (keine Abweichung, kein V7-Header noetig:
`stdio.h`, `sys/types.h`, `sys/stat.h` liegen auf der Diskette; `erg.json` hat `"header": []`).  Stand 2026-11-10, Rahmen `tools/userspace/erg.py` (E0).

| Programm | Ergebnis | Binaergroesse (gemessen) | Test |
|----------|----------|--------------------------|------|
| sleep | B | 4678 B | Meldungen "bad character"/"arg count" (V7-Quelltext), `sleep 1` kehrt zurueck |
| touch | B | 4652 B | Anlegen, `-c`, Inhalt bleibt, Meldung fuer fehlende Datei, `ls -t`-Reihenfolge vor/nach `touch` (Gastuhr laeuft) |
| yes | B | 4188 B | erste Zeile mit `read` gelesen (y, no, "a b"); Referenz GNU yes 9.7 |
| tty | B | 4714 B | nur Fall "kein Terminal" (`</dev/null`): "not a tty", Exit 1, `-s` still |
| mesg | **B** (nachgetragen 2026-11-15) | 4894 B | siehe unten |
| sum | B | 5268 B | Pruefsumme gleich GNU `sum -r` 9.7; Blockzahl nach V7-Formel (BUFSIZ 512, durch den Test bestaetigt); Name bei mehreren Dateien; Stdin; Fehlerfall Exit 10 |
| rev | B | 5152 B | Referenz util-linux rev 2.41.5 auf Dateien und Stdin; Fehlerfall Exit 1 |

Erwartung und Herkunft je Programm: `userspace/ergaenzung/NAME/test/herkunft.txt`.  Alle sechs Tests liefen im Gast gleich (`erg.py alles`, 2026-11-10).

## mesg: nachgetragen 2026-11-15 (zuerst X, nicht getestet)

`mesg` ruft `ttyname(2)` auf (Standardfehlerausgabe).  Der Rahmen leitet stderr des Testskripts in eine Datei (`/tmp/aus.err`), also gibt es dort kein Terminal;
`ttyname` liefert 0 und `stat(0, ...)` ist undefiniert.  Deshalb blieb `mesg` zunaechst ungetestet (ohne `test/`, was `test_ergaenzung_ordner_vollstaendig` rot machte).

Nachtrag: `/dev` des Gastes gemessen (`ls -l /dev` als Testskript, 2026-11-15): `console` (0,0) und `tty1` (0,1) mit `crw--w--w-`, dazu `tty` (1,0).
Der Test lenkt bei jedem Aufruf stderr auf `/dev/console` um und vergleicht nur den Exit-Code (0 = y, 1 = n, 255 bei falschem Argument), die Meldung geht auf die Konsole.
Folge abfrage/n/abfrage/y/abfrage/falsch: gleich der Erwartung (`erg.py alles mesg`, gemessen 2026-11-15).
Handbuch (Exit 2 bei Fehler) und Quelltext (`exit(-1)` = 255) widersprechen sich; gemessen ist 255.

## Befunde und Grenzen

* Im Gast gibt es kein `echo` (Bourne-Shell ohne Builtin, Diskette `cmd` nicht eingebunden): Testskripte nutzen `cat <<E` statt `echo` (erster Lauf scheiterte daran, nicht an den Programmen).
* `yes` ist unbegrenzt; geprueft wird nur argv[1]-Ausgabe bzw. "y" und dass SIGPIPE `yes` beendet (sonst haette der Lauf die Frist ausgeschoepft).
* `tty`: der Fall mit Terminal (Konsolenname) ist nicht getestet -- haengt von `/dev` des Gastes ab (nicht gemessen).
* `sleep`: die Dauer wird nicht gemessen, nur dass der Aufruf zurueckkehrt (`touch` nutzt `sleep 2` und die laufende Gastuhr, dort bestaetigt).
* `sum`: V7 zaehlt Bloecke zu 512 Byte, GNU zu 1024; die Blockzahl stammt aus der V7-Formel, nicht vom Host.  `rev`: V7 verwirft eine letzte Zeile ohne Zeilenende (anders als util-linux), die Eingaben enden daher mit Zeilenende.
