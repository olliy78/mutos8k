# W7d (Plan 52): `as`-Geruest baut und linkt (Stand: c2-Haenger umgangen, 10 Module)

Fortsetzung von `wk_w7c.md`.  Alles *gemessen* (Gast-`cc -O`, Sonden in einzelnen Sitzungen, Frist je Befehl 5e9 Zyklen).

## 1. Ursache des Haengers (gemessen)

* Nicht `yyparse`, nicht die 171 leeren `case`-Zweige, nicht die `# line`-Zeilen: `as_y.c` ohne `switch`, mit gefuellten Aktionen und ohne `# line` haengt **gleichermassen**.
* Der Haenger liegt im **c2** (Optimierer, Aufruf mit `-O`): `cpp`, `c0`, `c1` liefern in jeder Variante in 1-2 Minuten (Gastzeit), `c2` erreicht keine Ausgabe (`c3` fehlt).
* Ausloeser ist die **Menge initialisierter Tabellendaten in einem Modul**: alle 8 yacc-Tabellen zusammen (c5 = 14,5 KB) haengen; die fuenf kleineren (9,5 KB), `yyact` allein (5,3 KB) und der Parserkoerper ohne Tabellen (8 KB) laufen in je ca. 40 s durch.  Die genaue Schwelle liegt zwischen 9,5 und 14,5 KB c5 (nicht naeher bestimmt); *Annahme*: Knotenspeicher des c2 laeuft voll.
* Dieselbe Ursache hat der zweite Haenger: `as_tab.c` mit `as_tabd.h` (18 KB Quelle, 3300 Datenworte) haengt im `-O`-c2 ebenfalls.  Das Pipeline-Protokoll sah danach nur den "Haenger im Linken": `gscreen ENDE10` lief die vollen 20e9 Zyklen, danach fehlte `as_tab.o` (und `as_y3.o`, siehe 3.) und `ld` bekam fehlende Dateien.  Ohne `-O` (nur c0/c1) baut jedes Modul in 20-60 s.

## 2. Abhilfe (kleinster Eingriff ohne Aenderung von pipeline.py/uspace.py)

Aufteilen der Daten auf mehrere Module, Linkreihenfolge unveraendert:

* `tools/userspace/as_ysplit.py`: `as_y.c` (unveraenderte yacc-Ausgabe, wird nicht mehr uebersetzt) -> `as_y1.c` (yyexca..yypgo), `as_y2.c` (yyr1..yydef), `as_y3.c` (yydebug, `yyparse`); `--check` prueft, dass die drei Dateien aktuell sind.  Die Aktionen bleiben leer, `as.y` und `erg_yacc.py` sind unveraendert, `as_grammatik.py --check`-Ergebnis daher unveraendert.
* `tools/userspace/as_tabellen.py --write` erzeugt neben `as_tabd.h` (ganzer Text, Beweis wie in W7c) `as_tabd1.h` (kwtab, ctab1, ctab2 + `mnem[0..99]`), `as_tabd2.h` (`mnem_b`, 100 Eintraege), `as_tabd3.h` (`mnem_c`, 101 Eintraege, Endmarke `""`) -> `as_tab1.c`, `as_tab2.c`, `as_tab.c` (Skalare, BSS, Stubs).  Namen `mnem_b/_c` *Annahme*.
* `link.txt`: `as_y1 as_y2 as_y3 as_lex as_misc as_code as_main as_expr as_dir as_tab1 as_tab2 as_tab`.
* Nachteil (gemessen): die drei `mnem`-Teile liegen im Gastbau **nicht** hintereinander, weil `cc` den Zeichenkettenpool je Modul hinter dessen Daten legt.  Fuer das Geruest unerheblich (nichts liest `mnem`); fuer echte Datenlage-Gleichheit muss die Tabelle wieder in **ein** Modul (c2-Fehler beheben oder pro Modul ohne `-O` uebersetzen -- dafuer muesste `uspace.gast_bauen` je-Modul-Flags kennen, nicht Teil dieses Auftrags).
* Fehler beim ersten Aufteilen: `# define YYFLAG` lag zwischen den Tabellen und `# define YYERROR`; `as_y3.c` brach mit `YYFLAG undefined` ab (stand nur in der Fehlerdatei, `cc -c` laeuft weiter).  Behoben (Trennstelle jetzt vor `YYFLAG`).

## 3. Gesamtbau (`pipeline.py alles as --c2emu --libc alt --ist neu_c2`)

* **Linkt**: `neu` 17416 B (206 s), `neu_c2` 17418 B (100 s); der Gesamtlauf braucht nur wenige Minuten, sobald nichts mehr haengt.
* Kopf: Original text 22092 / data 13706 / bss 17744; gebaut text 5832 / data 11570 / bss 15644.  Text ist klein (Stubs), die Datensegmentdifferenz (2136 B) und die BSS-Differenz (2100 B) entsprechen fehlenden Zeichenketten und BSS der noch nicht rekonstruierten Funktionen.
* Datenlage: `kwtab`, `ctab1`, `ctab2` und `mnem[0..99]` stehen hintereinander und stimmen mit dem Original ueberein (bis auf die Zeigerworte, die auf den Pool zeigen); ab Eintrag 100 verschiebt der Modulpool die Teile (s. 2).  Skalardaten (`pass`, `yysptr`..) liegen hinter `mnem_c`, ihre Werte sind Zeigerworte und stimmen nicht mit dem Original ueberein (andere Adressen).
* Rahmenfunktionen (Bericht `userspace/as/work/bau/neu_c2.bericht`, Unterschiede je Funktion nach Befehlsvergleich mit c2-Modell): `input` (09D4) 8 Bloecke, `main` (322C) 7, `args` (32E6) 34, `error` (35A8) 5; `defla`/`prmsg`/`yyerror` ohne Unterschiedsblock gemeldet (nicht einzeln geprueft).  Die meisten Bloecke sind verschobene Operandadressen (andere Datenlage) und fehlender Stubcode; echte Abweichungen: `args` (`TESTB @R3` im Original gegen `LDB RL4,@R3; XORB RH4,RH4; TESTB RL4` im Bau, d. h. dort steht im Original wohl ein `char`-Zeigerzugriff anders), `error`-Eingang.  Nicht weiter verfolgt.
* Summe: 5891 Originalbefehle im Eigencode, 659 gebaut, 300 passend (286 ohne c2-Modell), 73 Unterschiedsbloecke; 676 von 35798 Bytes gleich am gleichen Offset.

## 4. Naechste Schritte

1. Pipeline-Zeitrahmen: `timeout 2400` reicht nicht, wenn Module haengen (volle 20e9 Zyklen je haengendem Schritt); im Normalfall genuegen 10-15 min.
2. Tabellen wieder in ein Modul (c2 untersuchen: Datenmenge je Modul) -- dann Poolreihenfolge und Zeigerworte pruefbar.
3. Stubs durch Funktionen ersetzen, Befehlsvergleich je Modul, danach Datensegment gegen das Abbild normalisiert vergleichen.

## 5. Werkzeug-Aenderungen

Neu: `tools/userspace/as_ysplit.py`.  Geaendert: `tools/userspace/as_tabellen.py` (Teil-Header), `userspace/as/{link.txt,as.h,as_tab.c}`.  Neu: `as_y{1,2,3}.c`, `as_tab{1,2}.c`, `as_tabd{1,2,3}.h`.  pipeline.py/uspace.py/libc_alt.py unveraendert; keine neuen c2-Regeln.
