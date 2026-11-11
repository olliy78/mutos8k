# Ergaenzung E3b: vmake (V7-make) (Plan 45)

**Ergaenzung, V7-Quelle, keine Originalreferenz.**  Das V7-`make` (`original/unix-v7/usr/src/cmd/make`) liegt nicht auf den MUTOS-Disketten.  Es wird
unter `userspace/ergaenzung/vmake/` gefuehrt und heisst im Gast `vmake` (Name <= 9 Zeichen; Quelle bleibt V7-Text), damit es nicht mit dem Eigenbau
`userspace/make` (`make`) verwechselt wird.  Nichts hier ist "rekonstruiert".  Stand: **Vorbereitung fertig, Bau offen** (siehe "Stand").

## Quellen und Abweichungen vom V7-Text

Kopiert (byteweise, danach nur die unten genannten Stellen geaendert): `defs` (Header ohne Endung), `ident.c main.c doname.c misc.c files.c dosys.c gram.y`.
`gcos.c` aus dem V7-`makefile` gibt es in dem V7-Verzeichnis nicht und wird nicht gebraucht.  Das V7-`makefile` selbst wird nicht benutzt (Bau durch `erg.py`).

| Datei | Abweichung | Ursache |
|-------|------------|---------|
| `files.c` | `#include <dir.h>` statt `<sys/dir.h>` | Rahmen legt V7-Header flach (`erg.json` `header`), wie bei `find` |
| `files.c` | `#define A_MAGIC2 A_MAGIC1`, falls A_MAGIC2 fehlt | das MUTOS-`a.out.h` kennt nur A_MAGIC1/3/4 (gemessen: `A_MAGIC2 undefined; func. getobj`); betrifft nur die Archivnotation `lib((symbol))` |
| `erg.json` | Zusatzheader `errno.h` (V7, unveraendert) | fehlt in `/usr/include` (gemessen: `Can't find include file errno.h`) |

Alle sieben `.c`-Module uebersetzen mit `cc -O -c` ohne weitere Meldung (gemessen).  `defs` wird als Datei neben die Quellen gelegt (`"dateien": ["defs"]`).
Annahme (nicht geprueft): `objhead.a_flag` (V7: "keine Relokation") hat im MUTOS-`a.out.h` dieselbe Bedeutung; nur fuer `lib((sym))` wichtig.

## Rahmen (erg.py)

Mehrdatei-Programme konnte `erg.py` schon (`*.c` alphabetisch einzeln `-c`, dann `cc -s -o NAME *.o`).  Neu, rueckwaertskompatibel: der optionale Schluessel
`"dateien"` in `erg.json` nennt Dateien des Ordners ohne `.c`/`.h`-Endung (hier `defs`), die als Header neben die Quellen kommen.  Bestehende Programme sind unberuehrt
(Schluessel fehlt = leer; nicht erneut gebaut, nur die Funktion `quellen()` um drei Zeilen erweitert).
Linkreihenfolge = alphabetisch: `doname dosys files gram ident main misc` (V7-`makefile`: `ident main doname misc files dosys gram`; fuer das Linken ohne Ueberlagerungen unerheblich).
Bau V7 `-n -s`: `-n` (Textsegment schreibgeschuetzt/teilbar, PDP-11-Eigenschaft) entfaellt, der Rahmen benutzt `cc -s -o`.

## gram.c (erzeugte Quelle)

`gram.y` braucht `yacc`.  **Noch nicht erzeugt** (E3a-Branch `us-erg-e3a` hat keinen Commit "E3a: yacc B"; Host hat kein byacc/bison).  Vorgesehen: im Gast mit dem MUTOS-`yacc`
aus E3a (Befehlszeile: `doc/userspace/erg_e3a.md`) `y.tab.c` erzeugen, als `userspace/ergaenzung/vmake/gram.c` ablegen (erzeugte Quelle, Kopfzeile mit Befehl und
yacc-Stand) und den Test laufen lassen.  Ein Host-yacc waere nur ein gekennzeichneter Notbehelf, kein Ergebnis B.
Ohne `gram.c` bleiben beim Linken nur `yyparse`, `yylineno`, `zznextc` undefiniert (gemessen, Bau 175 s, `vmake.bin` 40640 B mit offenen Symbolen -- **kein** lauffaehiges Programm).

## Test

`test/befehle.sh` (Gast-Shell), `test/erwartet.txt`, `test/herkunft.txt` (Herkunft je Abschnitt), `test/eingabe/` (Makefile, Mk2, `s1.sa s2.sa data.sa ex3 t.c`).
Der Gast hat kein `echo/cp/rm/touch/sleep`; das Makefile nutzt nur `cat` und `sh`.  Ablauf: `-n` (Befehlsliste, 4 Faelle), `-s -n`, Makros auf der Befehlszeile, `$(X:.c=.o)`,
Ziele mit mehreren Namen, Suffixregel `.sa.sb` (`$<`, `$@`, `$?`), eingebaute Regel `.c.o` (`cc  -c t.c`), echter Lauf (Befehle, Ausgabe, "is up to date"), `-q` (Exit 0/255),
`-t` (`touch(list)`, Datei entsteht), Fehlerabbruch (`*** Error code 3`, Exit 1), `-i`, `-` am Befehl, unbekanntes Ziel (Exit 1).
Erwartung: die `-n`-Befehlslisten von GNU Make 4.4.1 (Host, gleich mit V7); Meldungen, Exit-Codes und die `.c.o`-Regel aus dem V7-Text (`doname.c`, `files.c`).
**Nicht getestet** (Gast ohne `sleep`/`touch`, Dateizeiten mit Sekundenaufloesung): Neubau bei juengerer Quelle; ausserdem `-p -d -k`, Archivnotation, Umgebungsmakros, Wildcards in Abhaengigkeiten.
Ergebnis: **offen** (noch nicht im Gast gelaufen).

## V7-make gegen unseren Eigenbau `userspace/make`

Unser `make` (`userspace/make/make.c`, ~750 Zeilen, Eigenbau, `doc/werkzeugkette/make.md`) hat den Umfang eines V7-make, ist aber kein V7-Code.  Unterschiede (aus den Quellen/READMEs, nicht alle durch Laufvergleich belegt):

* Grammatik: V7 parst per `yacc` (`gram.y`) und handgeschriebenem `yylex`; der Eigenbau per Handparser (der Grund seiner Entstehung: der Gast hatte kein `yacc`).
* Gleiche Syntax: Regeln, `$(X)`, `$(X:.c=.o)`, `$@ $< $* $?`, Suffixregeln, `-`/`@`.  Nur Eigenbau: `${}`/`$N`, `$^`.  Nur V7: `.DEFAULT`, `-k -t -q -p -d -S`, Archivnotation `lib(x.o)`/`lib((sym))`, Wildcards `* ? [ ]` in Abhaengigkeiten (Verzeichnissuche `srchdir`), Umgebungsvariablen als Makros (Rangfolge nicht geprueft), `.SUFFIXES:` mit leerer Liste loescht die Liste, Mehrfach-Regeln `::`.
* Regelbehandlung: Eigenbau ersetzt eine zweite Befehlszeilen-Regel; V7 meldet "Too many command lines" / "Multiple rules lines".  Ein Ziel ohne Datei gilt beim Eigenbau stets als zu bauen; V7 ebenso, bei Dateien vergleicht es `st_mtime` (V7 "neuer" = echt groesser, wie der Eigenbau).
* Befehlsausfuehrung: Eigenbau `system()`; V7 `fork/exec` direkt, nur bei Metazeichen `/bin/sh -ce` (mit `-e`, ausser unter `-i`), Fehlerausgabe `*** Error code N`.
* Meldungstexte: V7 `` `x' is up to date.``, Eigenbau `'x' ist aktuell`.
* Groesse: Eigenbau 19866 B; `vmake` mit offenem `gram.c` 40640 B (Endwert nach Erzeugung von `gram.c` offen).
* Vergleich durch Laeufe (gleiche Makefiles in beiden) ist ein eigener Auftrag und nicht gemacht.

## Segmentbelegung

Noch nicht gemessen (kein lauffaehiges Binary).  Vorlaeufig: Text+Daten des unvollstaendigen Binaers 40640 B < 64 KB; V7-make belegt zusaetzlich Puffer (`char word[INMAX]` 1500 B, `OUTMAX` 2500 B, `string[OUTMAX]` je Rekursion) auf dem Stack.
*Annahme:* passt, nicht gemessen.
