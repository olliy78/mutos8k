# W7c (Plan 52): Verlinkungsgeruest fuer `as` (Stand: Quellen und Tabellen fertig, Gastbau haengt an `as_y.c`)

Alles *gemessen*, ausser wo *Annahme* steht.  **Der Bau ist nicht gelinkt**: `pipeline.py alles as ...` lief ueber 2 Stunden und wurde abgebrochen (Ursache siehe 4).

## 1. Quellen (`userspace/as/`)
`link.txt` (Reihenfolge = Adressfolge im Original): `as_y.c as_lex.c as_misc.c as_code.c as_main.c as_expr.c as_dir.c as_tab.c`; `as.h` (Strukturen, externe Variablen), `as_tabd.h` (erzeugt, 2).
`as_y.c` ist die eingecheckte Gast-yacc-Ausgabe von `as.y` (W7b), unveraendert.  Funktionsreihenfolge aus `v7zuordnung.txt` (plus `35EC`); die Modulgrenzen sind *Annahme* (gemessen nur die Reihenfolge; Daten-Layout und `csv`-Funktionen erlauben keine Grenze):
`as_lex` 09D4-1626, `as_misc` 167A-1BDA, `as_code` 1C0C-31BA, `as_main` 322C-35FE, `as_expr` 3620-3AC8, `as_dir` 3B78-43AE, `as_tab` 43C6-48A4 (Tabellen und Daten stehen im Original vor `43C6`, daher dort).
Alle nicht rekonstruierten Funktionen sind `f<adresse>()` mit `return (0)`, markiert `TEMPORARY STUB` (63 Stueck, plus `yylex` als Stub fuer `0AA8`).

## 2. Datentabellen (`tools/userspace/as_tabellen.py`, Host, gemessen)
* Berichtigung zu wk_w7a: Tabelle 1 `706E..7102` 37 x 4 B (letzter Eintrag `{"",0}`), Tabelle 2 `7102..722E` 50 x 6 B, Tabelle 3 `722E..729A` 18 x 6 B (`{Name, Token, Wert}`), Mnemonik **`729A`**..8310 (nicht 72AC): 301 x 14 B `{Name, 6 Worte}`; die Grenzen kommen aus den Code-Vergleichen `CP R13,#706E/7102/722E/729A/8310` in `44F0..4814`.
* `8310..8322` Skalare: `0000 8D28 8B32 8B3A C79E 928E C79E 0006 8DF6` = `pass`, `yysptr=yysbuf`, `yyin=stdin`, `yyout=stdout`, drei Zeiger in die Symboltabelle `928E..C79E` (849 x 16 B, *Annahme*), Wort 6, `lptr=lbuf` (Namen *Annahme*).
* Zeichenketten `8322..8A52`: Namen in Tabellenreihenfolge, **ein Pool je Tabelle, danach genau ein NUL-Byte** (Pools beginnen 8322, 83EB, 84A9, 850D; Daten der naechsten Funktion ab 8A52).
* Beweis: `as_tabellen.py` erzeugt `as_tabd.h` und liest den eigenen C-Text wieder ein; daraus wird `706E..8310` (4770 B) und der Pool (1840 B) wortgleich zum Abbild aufgebaut: **gleich**.  Beweis ist nur die Host-Rechnung; ob das Gast-`cc` dieselben Bytes legt (Poolreihenfolge, Ein-NUL-Abstand), ist nicht gemessen.

## 3. Rahmenfunktionen (Text, nicht uebersetzt -> nicht verglichen)
Rekonstruiert aus dem Listing, *Annahme* fuer alle Namen: `input` (09D4, V7-lex-Rahmen + Mitschrift der Listenzeile in Pass 2), `main` (322C, mit `goto` fuer die Zweipass-Schleife; `loc1[200]`, `loc2[3202]`), `args` (32E6: `-u -d -c -l -o`, `creat/open` x4, `freopen`, Listdatei `NAME.l`), `error` (35A8), `defla` (35EC), `prmsg` (3A9C: `fprintf(stderr,"%s \n",s)`, keine `unput`), `yyerror` (3AB6 = `error(s)`).
Abweichungen zum Auftrag: **`43C6` ist nicht `error`** (Schalter ueber 4 Faelle, 298 B, Knotenbelegung) und bleibt Stub; `3A9C` ist kein `unput`.  Offene Stellen gegenueber dem Listing: `args` setzt `p = *argv++` (Original: `INC argv` vor dem Laden, Wert aus dem `while`-Test wiederverwendet), `input` vergleicht `yycnt + 1 > yysptr` (Int gegen Zeiger, `JR ULE`), `main`-Schleife per `goto`.  Der Gast-Befehlsvergleich steht aus.
BSS (nur die benutzten Objekte, Groessen teils *Annahme*, z. B. `lname[64]`) ist in `as_tab.c` definiert; die Anordnung des ld weicht vom Original (8D24..CC22) ab.

## 4. Gastbau: Haenger bei `as_y.c` (gemessen)
`pipeline.py alles as --c2emu --libc alt --ist neu_c2` (Gast, 8 Moduluebersetzungen einzeln `cc -O -c`): Schritt 1 (`as_y.c`) meldet `ENDE1` nie; alle weiteren Schritte laufen in dasselbe haengende Kommando und warten jeweils die volle Frist (20e9 Zyklen) ab; nach 2 h abgebrochen.  Das Mounten, `libc_alt` und der Gast selbst sind in Ordnung.
Sonde (`uspace.gast_bauen`, drei Sitzungen parallel, Frist 5e9): `as_lex.c + as_misc.c` und `as_main.c` uebersetzen und linken (Link-Fehler erwartet) in je ca. 1,3-1,5e9 Zyklen **fertig**; `as_y.c` allein erreicht `ENDE1` auch nach 5e9 Zyklen nicht (Bildschirm: Kommando steht, kein Prompt).  Also liegt der Haenger im Uebersetzen von `as_y.c` (Gast-cc, welcher Durchlauf: nicht bestimmt), **nicht** in `as_main.c`/`goto`/`switch` der Rahmenfunktionen und nicht in `as_tabd.h` (noch nicht einzeln geprueft: `as_tab.c` war nicht in der Sonde).
*Annahme* zur Ursache, ungeprueft: die 171 gleichlautenden leeren `case`-Zweige (`{ /* action N */ } break;`) im `yyparse` fuehren in `c1`/`c2` zu einer Endlosschleife oder extrem langsamer Zweigoptimierung; `cpy.c` (cpp) hat nichtleere Aktionen.

## 5. Naechste Schritte
1. `as_y.c` bisektieren (Sonde wie oben, je Variante eine Sitzung, Frist 5e9): (a) `cc -S` statt `-c` (welcher Durchlauf), (b) `yyparse` ohne die Aktionen/mit nichtleeren Aktionen, (c) ohne `# line`-Zeilen.  Falls die leeren Zweige schuld sind: Aktionen mit je einem Dummy-Ausdruck fuellen (Regenerierung ueber `erg_yacc.py userspace/as/as`, Tabellen muessen wortgleich bleiben: `as_grammatik.py --check`).
2. Danach ein Gesamtbau, Befehlsvergleich der Rahmenfunktionen, Datensegment (`706E..8A52`) gegen das Abbild (Zeigerworte nach Namen normalisiert, da die Stubs Zeichenketten der uebrigen Funktionen weglassen).
3. `yyparse` des Originals ruft `fprintf(stderr, ..)` statt `printf` und `3AB6`/`0AA8`: `as_y.c` ist also nicht der Original-Text von `yaccpar` (Debug-Zeilen) -- bei der Textgleichheit beachten.

## 6. Werkzeug-Aenderungen
`tools/userspace/pipeline.py`: nur der Kommentar des `as`-Eintrags.  `libc_alt/as.members(.zusatz)`: `libc_alt.py members as` / `bau as` -> 27 Glieder, **0 weichen ab** (`doprnt code=4C82,4C88,4C9E`, wie bei cpp).  Keine neuen c2-Regeln.
