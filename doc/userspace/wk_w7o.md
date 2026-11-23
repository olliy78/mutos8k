# W7o: as: zweite Haelfte der restlichen Stubs (12 Funktionen) -- keine Stubs mehr

Alle Namen sind *Annahme*.  Lesart aus `as.lst`, je Funktionsbereich.

* 3844 `modend` (nach END): Pass 2: `g ca78 *= 12`, `oflush(fd_o)`, `lseek(fd_o,0)`, Kopf `gca70` (16 Byte) schreiben; dann `secsave`; bei `lflag`: `lstflush`, in Pass 2 `symdump`.
* 38B6 `symdump`: Symboltabellenliste ("SYMBOL - TABLE", "LOCAL SYMBOLS:", "Number of input lines:"), Name je Zelle nach D0FA kopiert.
* 3AC8 `clsini`: 12 Aufrufe `setcls(Zeichenfolge, Maske)` (Zeichenklassen).  Beide Dateien Zeichenfolgen aus dem Image gelesen (*gemessen*).
* 3E9E `labset`; 3FD6 `inifin`; 404A `inibeg`; 40A4 `iniput` (Tabellen 6F6A/6F72: `switch` ueber `g90d0` = 2/3 bzw. `g9048` = 1..4); 4298 `inibyte`; 4372 `textsec`; 43AE `labtyp`.
* 459C `hashini` (Tabellen 729A/706E/7102/722E in `hashins` eintragen), 4628 `hashins` (Gegenstueck zu `hashfind`, Meldung "HASHSZ too small").
* 35FE `valobj`: Aufrufer ist Regel 166 (`SIZEOF '(' IDENT ')'`), jetzt als Aktion in `as.y`; `as_y.c` neu, `as_grammatik.py --check`: alle 8 Tabellen EQUAL (gemessen).
* `se_pc` in `struct sect` jetzt `unsigned`; `gccb8` ist `int *` (`as.h`).  `passini` hat danach `XOR R2,R2` statt `EXTS` (laut Listing; Rest der Funktion unveraendert 0.95).

## Messung (`alles as --c2emu --libc alt --ist neu_c2`, zwei Baeue)

Vorher 3764 gleich von 5891 Befehlen, 618 Bloecke.  Bau 1: 4183 gleich, 729 Bloecke (gebaut 5570).  Bau 2 (symdump-Schleife umgestellt, labtyp mit Registerparameter): **4192 gleich, 728 Bloecke**, gebaut 5571 Befehle, Text 21824 gegen 22092 Byte (Original), Daten 13518 gegen 13706.  Bytegleich am gleichen Offset: 3201 von 35798.  `--check as`: OK.  pytest `-m "not gast"`: 212 bestanden, 1 Fehlschlag (`test_bau_alle_kennt_genau_die_fertigen_disketten`, kein `disks/gebaut` im Worktree, wie W7m/W7n).  Es gibt keine TEMPORARY STUBs mehr in `userspace/as`.

Die Blockzahl stieg, weil jetzt Code verglichen wird, der vorher fehlte.  Funktionsweise Vergleich (Hilfsskript, Befehle mit Normalisierung der Adressen): identisch (Ratio 1.0): modend, clsini, labset, textsec, mklabs, endproc, procnam, lapush, lapop, lstflush, setcon, valobj.

## Offen

* Lange Spruenge: das Original hat in `hashini`/`hashins`/`hashfind` kurze `JR`, der Bau `JP` (Funktionen nach einem Rahmen mit mehr Registern; Ratio 0.66/0.58/0.54).  Vermutlich c2-Pfad (*Annahme*), nicht untersucht.
* `hashins`: Original `LD R2,R13; LD R3,R11; ADD R2,R11; LD R13,R2`, Bau `ADD R13,R11` (c2-Regel-Kandidat R260ff, nicht umgesetzt).
* `symdump`: Reihenfolge der beiden Schleifen im Original umgekehrt (Ratio 0.875).  `inifin`/`inibeg`: Registerwahl `R5`/`R3` bzw. `R3`/`R2` vor `LD @R2,..`.  `iniput`: Sprungtabelle/Ende der Funktion anders angeordnet (0.87).  `mkpair`: `AND` mit Maske statt `XOR R2,R2` unveraendert offen.
* Die Luecke 5571 gegen 5891 Befehle entstammt vor allem den ausgeglichenen Datenadress-Differenzen und den langen/kurzen Spruengen (*Annahme*, nicht Block fuer Block ausgewertet).
* Bericht ist auf 400 Zeilen gekuerzt (`uspace.py`); fuer diese Auswertung wurde die Grenze nur lokal (ohne Commit) hochgesetzt.
