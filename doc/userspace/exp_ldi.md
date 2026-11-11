# Experiment: getrennte Befehls-/Datenbereiche (`ld -i`) fuer yacc MEDIUM

*Messauftrag, kein Ergebnis fuer main.*  Frage: Unterstuetzen MUTOS-Werkzeug und -Kernel Programme mit getrenntem Text- und Datensegment (V7 `cc -i`), sodass
V7-`yacc` wieder mit `MEDIUM` (Text 24214 + Daten 4308 + BSS 49792 B, siehe `erg_e3a.md`) laufen koennte?

**Antwort: nein.**  Das Werkzeug erzeugt die Magic `E811`; der Kernel nimmt sie nicht an.

## 1. Kernel (gelesen, nicht gemessen)

* `kernel/c/sys1.c:227-244` (`getxfile`): akzeptiert nur `0xE807` (Kopf 16 B, `:227`) und `0xE707` (grosser Kopf 40 B); jede andere Magic gibt `ENOEXEC` (`:244`).  Kommentar `:226`: "only the plain (407-like) formats; sep stays 0".  Kopfkommentar `:14`: "no separate-I/D support".
* `sys1.c:228-233`: bei `E807` wird `a_text` zu `a_data` addiert und `u_ex[1] = 0` gesetzt, d.h. Text liegt mit den Daten ab Adresse 0 in einem Segment; `sys1.c:338` `u_sep = sep` bleibt 0.
* `kernel/c/ureg.c:105-113` (`estabur`): nur Groessenpruefung `nt + nd + ns <= 256` (`:108`; Klicks zu 256 B = 64 KB); `sep` wird ignoriert.  Daher das "too big".  `text.c` `xalloc` ist leer (kein geteilter Text).
* `doc/herkunft/speicher.md:119` sagt dasselbe (dort als gemessen).

## 2. Messung im Gast

Programm `userspace/ergaenzung/ldtest/` (4 Ballastdateien `ldtest1-4.c` mit je 40 Funktionen + `ldtest.c` mit `main`, `char buf[25000], buf2[25000]`; Pruefsumme 1274708 per Python).
Eine Datei mit `buf[50000]` ging nicht: `Constant required` (int ist 16 Bit, 50000 nicht darstellbar); zu viel Text in einer Datei -> Assembler-Fehler (`too many local areas`, `symbol table overflow`, `overflow of expression/operands list`), daher Mehrdatei.
Befehl: `K1520EMU=/home/olliy/projects/a5120emu python3 -I tools/userspace/erg.py test ldtest`.  Bau A: `flags` `-O -s` (je `cc -O -c`, Link `cc -s -o ldtest *.o`).
Bau B: `flags` `-O -s -i` (Link `cc -s -i -o ldtest *.o`; dafuer wurde `tools/userspace/uspace.py` so geaendert, dass `-i` nur an den Link-Schritt geht).

| Bau | Magic | text | data | bss | Datei | Start im Gast |
|-----|-------|------|------|-----|-------|---------------|
| A `-O -s` | E807 | 0xB8B6 = 47286 | 0x0120 = 288 | 0xC7B0 = 51120 | 47590 B | `/mnt/ldtest: too big` |
| B `-O -s -i` | E811 | 0xB900 = 47360 | 0x0120 = 288 | 0xC7B0 = 51120 | 47664 B | `ldtest: syntax error at line 1: `(' unexpected` |

Text 47 KB <= 64 KB und Daten+BSS 51 KB <= 64 KB, Summe 98694 B > 64 KB.
* `cc` und `ld` nehmen `-i` an und geben die Option weiter (gemessen: Magic E811, keine Fehlermeldung).  Der Text wird auf 256 Byte aufgefuellt (47286 -> 47360; *Annahme*: Ausrichtung fuer ein getrenntes Datensegment); Dateilaenge = 16 + text + data.
* Bau B: `exec` weist die Datei ab, die Shell liest sie als Skript und meldet den Syntaxfehler (gemessen).  Dass der Grund `ENOEXEC` ist, folgt aus Abschnitt 1 (gelesen), nicht aus einem Kernel-Trace.
* Die Pruefsumme konnte nicht verglichen werden, keines der Programme lief.

## 3. Schritt 3 (yacc MEDIUM mit -i)

Nicht ausgefuehrt: die Bedingung "nur wenn B funktioniert" ist nicht erfuellt.  `userspace/ergaenzung/yaccm/` und der `cgram.y`-Vergleich entfallen.

## 4. Folgerung

yacc bleibt bei `SMALL` (`erg_e3a.md`).  `MEDIUM` mit `-i` braeuchte einen Kernel, der `E811` annimmt und dem Prozess ein zweites 64-KB-Datensegment der U8001 gibt (`getxfile`, `estabur`, Segmentzuordnung, U880-Seite) -- *Annahme*, nicht bewertet.  Zwischenweg ohne Kernelaenderung: Tabellengroessen zwischen SMALL und MEDIUM (Grenze: 64 KB minus 24 KB Text, 4 KB Daten, Stapel/stdio), nicht gemessen.

## 5. Korrektur (Angabe des Projektinhabers, 2026-11-11)

**Der Rechner hat keinen Z8010 (keine MMU).**  Damit entfaellt die in Abschnitt 4 genannte Kernelarbeit ("zweites 64-KB-Datensegment"): Der kompilierte Code hat 16-Bit-Zeiger,
und getrennte Befehls- und Datenraeume braeuchten Hardware, die Befehlsholen und Datenzugriff auf verschiedene Segmente abbildet.  Das passt zum Kernel: `ureg.c` stellt fest, dass es keine
Speicherverwaltungshardware gibt, `estabur` ist nur eine Groessenpruefung (`nt+nd+ns <= 256` Klicks).  **Getrennte I&D sind auf dieser Maschine kein gangbarer Weg**, auch nicht mit Kernelaenderung.
Die Annahme in Abschnitt 4 und die Frage nach der MMU-Faehigkeit im Gespraech waren falsch bzw. gegenstandslos.
Verbleibend: ein Programm hat hoechstens 64 KB fuer Text, Daten, BSS und Stapel zusammen.  Dynamisch angelegte Tabellen (sbrk) aendern daran nichts, sie liegen im selben Segment.
Fuer `yacc` bleibt nur eine Tabellengroesse zwischen `SMALL` und `MEDIUM` (ungemessen, hoechstens wenige KB mehr) oder das Erzeugen grosser Parser mit einem `yacc` auf dem Host.
