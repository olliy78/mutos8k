# W7l: Aktionen 1..60 des `as`-Parsers

Ergebnis: in `userspace/as/as.y` sind die Aktionen der Regeln 1..60 aus dem Schalter 65CE (yyparse 0030) eingetragen; 61..171 bleiben Platzhalter.  `as_y.c` neu mit dem Gast-yacc erzeugt; `as_grammatik.py --check`: alle 8 Tabellen EQUAL (gemessen).

## Lesart (gemessen aus as.lst)

Rahmen wie yaccpar: `@R13` = `$n` der letzten Position, `FFFE` = `$(n-1)` usw.; Argumente werden rueckwaerts gepusht.

* 1: `if ($1 != $4) error("wrong end of module"); f3844();`  2: `$$ = $1; f2e38($1)` (Modulbeginn).
* 13/17/21/23/27: `g8d06 = 258/5/6/7/32` (CONSTANT, TYPE, GLOBAL, INTERNAL, EXTERNAL).
* 28: `f2dac($1,$2); g8d08 = 0`.  29: `if (g8d06 == 258) g8d08 = 1; else error(" wrong: IDENT :=___")`.
* 30..32: `secdir($1, 0)` bzw. `secdir($1, $2)`.  33: Fehlertext " invalid ASSDIR construction", dann `yyerrflag = 0` (65C4 ist das yaccpar-Global `yyerrflag`, `yyerrok`).
* 34: `f2dcc($1,$2)`.  36,37,42: `$$ = $1`.  38/39/40: `$$ = 1/2/4`.  41,44: `$$ = *(int*)($1 + 4)`.
* 43: `$$ = *(int*)($3 + 4) * $4; $3->o_t = -1` (Zelle $3 ist ein `struct obj`, wird freigegeben; *Annahme*: +4 = unteres Wort von o_val).
* 45: `g8d0a = 1`.  53: `labsym($1, ':')`.  59: `f404a($1,$2,1)`.  60: `f404a($1,$5,-1)`.
* Alle uebrigen Regeln 1..60 haben im Original keinen Fall (Standardsprung 09C4), also nur den yaccpar-Default `$$ = $1`.

Die Aufrufe 2DAC, 2DCC, 2E38, 3844, 404A sind noch Stubs (`f2dac` usw.; Namen *Annahme*).

## Technik

* `as.y` bindet jetzt `as.h` ein (`%{ ... %}`), mit `#define IN_AS_Y`, damit `extern int yylval` aus `as.h` nicht mit dem yacc-`YYSTYPE yylval` kollidiert (Gast-cc: "yylval redeclared").  `g8d0a` neu in `as.h`.
* Aktionen nutzen `$<u>n`, da Terminale/ntN ohne `%type` untypisiert sind.

## Messung (`alles as --c2emu --libc alt --ist neu_c2`)

Vorher 2984 gleiche von 5891 Befehlen, 528 Differenzbloecke; nachher 3031 gleich, 539 Bloecke (gebaut 4129 Befehle; Aktionen 61.. fehlen noch).  `--check as`: OK.  Im Vergleich erscheinen die Fallkoerper 13..60 teils als "delete"-Bloecke (Ausrichtungseffekt, solange die Faelle 61.. leer sind; *nicht weiter untersucht*).  Die Fallkoerper wurden nicht Befehl fuer Befehl gegen das Original geprueft.

## Offen

Aktionen 61..171; die Stubs 2DAC/2DCC/2E38/3844/404A.
