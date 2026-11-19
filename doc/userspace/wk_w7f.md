# W7f (Plan 52): `as` -- Scanner rekonstruiert (`as_lex.c`)

Fortsetzung von `wk_w7e.md`.  Alles *gemessen* (Gast-`cc`, `alles as --c2emu --libc alt --ist neu_c2`, zwei Laeufe), ausser wo *Annahme* steht.  Alle Namen sind *Annahme*.

## 1. Rekonstruierte Funktionen (`userspace/as/as_lex.c`)

| Adresse | Name | Inhalt | Unterschiedsbloecke Lauf 2 |
|---|---|---|---|
| 0AA8 | `yylex` (`plzlex`) | Schalter ueber das Ergebnis von `plzlook` | 112 |
| 1330 | `getobj` | freie Zelle in `objtab[10]` (10 B) | 5 |
| 13A2 | `iniobj` | alle Zellen frei (`o_t = -1`) | 2 |
| 13C8 | `plzlook` | `yylook`-Ersatz, Klassentabelle `cls` (8F42) | 9 |
| 1476 | `inlist` | nicht in der alten Stubliste (Luecke zwischen 13C8 und 14A6) | nicht einzeln gelistet |
| 14A6 | `yywrap` | `return 1` | 0 |
| 14B0 | `cmp8` | 8 Zeichen, 7-Bit-maskiert, bis NUL | 1 |
| 1502 | `setcls` | Klassenmaske in `cls[]` ODERn | 1 |
| 1540 | `escchar` | Zeichenkonstante, `%`-Escapes, 0x200 = Ende | 1 |
| 1626 | `hexdig` | Ziffernwert, Meldung `hex_digit expected` | 2 |

Alle Stubs dieses Bereichs sind ersetzt.  Rest-Bloecke sind ueberwiegend verschobene Datenadressen (BSS-Lage des `ld` weicht ab, in W7e bekannt) und die Zeichenkettenadressen der Meldungen.

## 2. Befunde zum Original (gemessen am Listing)

* **`BIT n` testet die Maske `1<<n`**: `BIT @R2,#1` = Klassenmaske 2 (Hexziffer), `#2` = 4 (Dezimalziffer), `#4` = 16 (Grossbuchstabe A-F).  Erster Entwurf las die Bitnummer als Maske; der Befehlsvergleich im ersten Lauf zeigte das (`BIT #1` gegen `#2`).
* Der Schalter in `yylex` ist ein Hash-Schalter des cc: `DIV RR2,#5` (Tabelle 6800, 5 Ketten); die Ketten vergleichen den **Quotienten**, die Kette waehlt der Rest.  Rueckgerechnet sind die Fallwerte (Klassenmasken von `plzlook`): -1, 0, 1, 3, 17, 19, 32, 65, 67, 71, 79, 81, 128, 257, 259, 296, 321, 512, 1024, 2048 (0x800).  Der 5er-Hash steht mit `XOR R2,R2` (unsigned) im Original; `switch ((unsigned)c)` erzeugt im Bau weiter `EXTS RR2` -- offen.
* Der `default`-Zweig meldet `bad switch in plzlex returning from yylook` (V7-lex-Rahmen `yylex`: `while ((nstr = yylook()) >= 0) switch (nstr) { case 0: if (yywrap()) return 0; break; ... default: ... }`).
* `plzlook` entspricht dem lex-`unput` (inline, mit Mitschrift der Listenzeile): Makro `UNPUT` in `as.h`.
* Datenwoerter: `yylval` (8BD6) bekommt Zeiger auf Zellen aus `getobj` (`struct obj`: Typ, long Wert bei +2, Verweis bei +6, 10 B); Symbolverweise `struct sym` (`s_t`, `s_v`, `s_w`).  Neue Variablen `yytext[200]` (8E76), `yyleng` (8F3E), `cls[128]` (8F42), `g8d06`..`g904a` (Zustandsworte, Bedeutung *Annahme*), in `as_tab.c` (BSS).
* Tokenwerte: 293 `NUMBER`, 297, 298 `IDENT`, 302, 311, 314, 315 (die yacc-Konstanten aus `as_y.c`).

## 3. Messung (Befehlsvergleich, ganzer Eigencode)

* Vorher (W7e): Original 5891 Befehle, gebaut 675, passend 296, 70 Bloecke.
* Lauf 1: gebaut 1608, passend 1007, 208 Bloecke (`neu` 21462 B, `neu_c2` 21504 B).
* Lauf 2 (nach Korrektur der Bitmasken, `g9046` unsigned, Reihenfolge `yylval`/`o_t` in einem Zweig, zwei `switch (ch = *s++)` in der `R`-Zahl, `UNPUT(*--p)`): gebaut 1600, passend 1002 (984 ohne c2-Modell), 203 Bloecke.  Das Passend-Mass sank leicht, weil die Blockzahl sich verschob; die Aenderungen sind nach dem Listing richtiger.
* `--check as`: OK (Rundlauf der Rahmendaten unveraendert).  `pytest -m "not gast"`: 209 bestanden, 1 Fehlschlag `test_bau_alle_kennt_genau_die_fertigen_disketten` (Disketten-Ordner `disks/gebaut` fehlt im Worktree; *Annahme*: unabhaengig von dieser Aenderung, nicht gegen `main` verglichen).

## 4. Offene Punkte

1. `yylex`: 5er-Hash mit unsigned `DIV` (`XOR R2,R2`) noch nicht erreicht; `CP R2,#0200` statt `CP e,#0200` (Original verwendet R2 direkt, `e` ist wohl keine Variable: `escchar()`-Ergebnis direkt weiterbenutzt); Zweig `R`-Zahl: Original legt die Schleifenprobe ans Ende, der Bau (c2) zieht sie vor.
2. `LD R2,R13`-Variante bei `yylval = sp = f48a4(6)` unbestaetigt (Lauf 2 nicht einzeln gewertet).
3. `g8d06` (Vergleich ueber `R2` im Original) und die Datenlage (BSS) stehen fuer den echten Wortvergleich aus.
4. Weitere Stubs im Modul: `f3a18`, `f46da`, `f4814`, `f48a4`, `f3ec0`, `f4298` (andere Module).
