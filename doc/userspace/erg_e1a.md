# Ergaenzungen E1a: sleep, touch, yes, tty, mesg, sum, rev (Plan 45)

*Ergaenzung, V7-Quelle, keine Originalreferenz* -- diese Programme liegen nicht auf den MUTOS-Disketten und sind nicht rekonstruiert.
Quelle: `original/unix-v7/usr/src/cmd/NAME.c`, unveraendert kopiert nach `userspace/ergaenzung/NAME/NAME.c`.

## Stand: Vorbereitung fertig, Bau/Test offen

Der Rahmen `tools/userspace/erg.py` (Branch `us-erg-e0`) war bei Abschluss dieser Runde nicht nutzbar (kein Commit "E0: Rahmen nutzbar").
**Nichts davon ist im Gast gebaut oder gelaufen.**  Alle Erwartungswerte unten sind aus Quelltext/Handbuch/Host abgeleitet, nicht im Gast gemessen.

| Programm | Header (erg.json) | Abweichung vom V7-Text | Test (Erwartung aus) | Ergebnis |
|----------|-------------------|------------------------|----------------------|----------|
| sleep | keine | keine bekannt | V7-Quelltext/Handbuch | offen |
| touch | keine (`stdio.h`, `sys/types.h`, `sys/stat.h` liegen auf der Diskette) | keine bekannt | V7-Handbuch, Quelltext | offen |
| yes | keine | keine bekannt | GNU yes 9.7 (gemessen) | offen |
| tty | keine | keine bekannt | V7-Quelltext; nur Fall "kein Terminal" | offen |
| mesg | keine | keine bekannt | V7-Quelltext | offen (Verdacht X, s. u.) |
| sum | keine | keine bekannt | GNU sum -r 9.7 (Pruefsumme, gemessen); Blockzahl V7-Formel | offen |
| rev | keine | keine bekannt | util-linux rev 2.41.5 (gemessen) | offen |

Alle benoetigten libc-Glieder (`sleep`, `ttyname`, `stat`, `chmod`, `creat`, `lseek`, `strcmp`, `fprintf`) stehen in `doc/werkzeugkette/libc_signaturen.txt` (gemessen);
dass `stdio.h` der Diskette `BUFSIZ`, `ferror`, `getc`, `putc` und `%05u` in `printf` bietet, ist **Annahme**.

## Annahmen des Tests (ungeprueft)

* `befehle.sh` ruft die Programme nur mit Namen auf und nimmt an, dass der Rahmen sie im `PATH` des Gastes ablegt und die `eingabe/*` nach `/tmp` kopiert (Plan 45 §7 sagt dazu nichts; nachpruefen, sobald `erg.py` steht).
* `yes` nutzt `dd` (Diskette `cmd`) zum Abschneiden; fehlt `dd` im Gast, ist der Test anzupassen.
* `touch`: Zeitreihenfolge mit `ls -t` setzt eine laufende Gastuhr voraus.
* `tty`: der Fall mit Terminal (Konsolenname) fehlt bewusst; er haengt von `/dev` des Gastes ab (unbekannt).
* `mesg`: braucht eine Geraetedatei der Konsole in `/dev`, die `ttyname(2)` findet; sonst im Gast nicht testbar (dann X mit Begruendung).  V7-Handbuch (Exit 2 bei Fehler) und Quelltext (`exit(-1)`) widersprechen sich; der Test folgt dem Quelltext (255).
* `sum`: V7 zaehlt Bloecke zu `BUFSIZ` (512), GNU zu 1024; Blockzahl daher aus der V7-Formel, nicht vom Host.  `rev`: V7 verwirft eine letzte Zeile ohne Zeilenende.
