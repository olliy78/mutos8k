# W7p: funktionale Gegenprobe des rekonstruierten `as` (Stand: Fehler gefunden und behoben, Gegenprobe nach der Behebung offen)

Werkzeug: `tools/userspace/asgegen.py` (`lauf --asx BIN`, `auswerten`; additiv). Eine Gastsitzung uebersetzt dieselben `.s`-Eingaben mit
dem mitgelieferten `/usr/bin/as -u -o` und mit unserem `as` (als `/mnt/asx`) und holt `.o` beider sowie Exitstatus/Meldungen (`X.e`).

## Messung 1 (Bau `alles as --c2emu --libc alt --ist neu_c2`, 4192/5891 Befehle gleich)

* Eingaben: 65 libc-`.s` (`userspace/libc/*.s`, inkl. `crt0.s`). Die Compiler-Ausgaben (echo, cat, cc) entstanden in diesem Lauf nicht
  (`Can't create temp`: `/tmp` war nach den 65 Assemblerlaeufen voll, *Annahme*: Reste abgebrochener `as`-Laeufe); Reihenfolge danach umgestellt.
* Ergebnis: **0 von 65 identisch.** Jeder Lauf unseres `as` endet mit `fatal error: symbol table overflow`, `error exit from assembler`,
  keine `.o`-Datei. Das Original uebersetzt alle (z.B. `close.s` 80 Byte).

## Messung 2 (Sitzung mit Kleinsteingaben d_e0..d_e3 und Compiler-Ausgaben)

* `d_e0` (leer), `d_e1` (nur `m1_ module`): Meldungen und Status bei Original und Bau gleich (syntax error, Zeile 0 bzw. 1).
* `d_e2` (`module`, `$NONSEGMENTED`, `constant`, `FP := r14`): Original meldet `syntax error` in Zeile 4, unser `as` bricht mit
  `symbol table overflow` ab. Kleinstes Beispiel: schon das erste Symbol (`symadd`).
* Compiler-Ausgaben `c_echo`, `c_cat`, `c_cc` (cpp, c0, c1, Original-c2): Original-.o 680 / 1632 / 9064 Byte; unser `as`: gleicher Abbruch.
  Ergebnis insgesamt: **0 von 72 identisch** (4 `d_`-Faelle mit gleicher Meldung zaehlt `auswerten` als EQUAL, ohne `.o`).

## Ursache (gemessen am Listing `neu_c2.lst`)

`passini` setzt `symend = symlim = gc79e`; im Bau stand dort `LD R2,#%9098`, waehrend `symtab` auf `951A..CA2A` lag (Original: `LD R2,#%C79E`
= `symtab + 13584`). `gc79e` war ein eigenes Feld `char gc79e[616]`; der Linker legte es in der Reihenfolge der BSS-Felder **vor**
`symtab`. Damit war `symend < symcur` bei der ersten `symadd`-Zelle. Die Quelle nahm die Nachbarschaft (`gc79e` = Ende von `symtab`) an, ohne sie zu erzwingen.

Behebung (`userspace/as/as.h`, `as_tab.c`): ein Feld `char symtab[13584 + 616]`, `#define gc79e (symtab + 13584)`.
Gemessen nach dem Neubau (`neu_c2.lst`): `passini` laedt jetzt `#%C5A8` = `symtab (9098) + 13584`; die Initialwerte `symend/symlim` stehen auf `C5A8`,
`symcur` auf `9098`. Befehlsbilanz unveraendert (4192 gleich, 728 Bloecke); bytegleich am gleichen Offset 3198 (vorher 3201).

## Offen

* Gegenprobe mit dem behobenen Bau **nicht gelaufen** (Auflage: hoechstens zwei Gastlaeufe). Naechster Schritt: `asgegen.py lauf` + `auswerten`,
  dabei die Compiler-Ausgaben vor den libc-Eingaben (jetzt so sortiert).
* Weitere Fehler hinter dem ersten sind wahrscheinlich (neue Funktionen `hashini/hashins/symdump` usw. nie ausgefuehrt, *Annahme*).
* Das Layout der BSS-Felder weicht insgesamt vom Original ab (bss 17724 gegen 17744 Byte); weitere Annahmen ueber Nachbarschaft sind zu pruefen.
