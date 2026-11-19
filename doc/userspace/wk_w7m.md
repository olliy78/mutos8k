# W7m: as: Aktionen 61..165 des Parsers

Ergebnis: in `userspace/as/as.y` sind alle Faelle des Schalters 65CE (yyparse) eingetragen; die Regeln 166..171 haben im Original keinen Fall (nur `$$ = $1`).  Aktionen 1..60 stammen aus W7l.  Regeln ohne Fall (Standardsprung 09C4) bleiben leer.  `as_y.c` neu mit dem Gast-yacc; `as_grammatik.py --check`: alle 8 Tabellen EQUAL (gemessen).

## Lesart (gemessen aus as.lst)

* Tabelle 65CE, Index = Regelnummer - 1 (`SUB R2,#1`, Grenze 0xA5); `$n` einer Regel mit k Symbolen liegt bei `@R13 - 2*(k-n)`; `$$` ist das Wort 8BD8 (`yyval`).  Argumente werden rueckwaerts gepusht.
* 61: `f404a($1,$5,CELL4($4)); $4->o_t = -1` (wie 43).  62: `g8d0c = g8d0e = 1`.  63: `g8d0e = 1`.  64..68, 109: `f3fd6()` (65 setzt vorher `g8d0e = 1`).
* 72/73: `$$ = f40a4($1)` bzw. `f40a4(0)`.  74: `f43ae($1)`.  75: `f19da($1,$4)`.  76: `$$ = f4372($1)`.  77: `$$ = f1a1e($1)`.
* 82: `nodeset($1,0,0)`.  83: `g8d0e = 0`.  84: `g8d10 = 1; g8d0e = 1`.  104..106: `nodeset($1,1|2|3,$4)`.
* 107: `dirclr()`.  108: `dirset()`.  110: `f3e9e(g8d12); stpop()`.  111: `f167a()`.  112: `labsym($1,':')`.  113: `labsym($2,0x125)`.
* 125: `$$ = exprdo($1,'*',$2)`.  126: `$$ = $1`.  127: `opmatch($1)`.  128: `error(" error in operands ")`.  130: `oppush($2)`.
* 131..136, 140..142: `$$ = f1938(Operand, Maske)` mit Masken 8, 4000, 2000, 1000, 4, 10, 22, 840, 100 (hex; Operand `$2` bei 135/136, sonst `$1`).  143: `$$ = $2`.  144..146: `$$ = f1ab6($1,$3,1|0x400|0x200)`.
* 147..161: `$$ = exprdo($1,Op,$3)` (150/151: `$4`), Op = '<' '>' '=' 0x3D3C 0x3D3E '+' '-' 0x11E 0x11F '*' '/' 0x121 0x122 0x123 0x120.  162..164: `exprdo($2,'+'|'-'|0x124,0)`.  165: `$$ = $2`.
* Hinweis: Der Kommentar in `as_expr.c` nennt 0x3D3B als `<=`; der Parser uebergibt 0x3D3C (zu pruefen, *nicht geaendert*).

## Messung (`alles as --c2emu --libc alt --ist neu_c2`, ein Bau)

Vorher 3031 gleiche von 5891 Befehlen, 539 Differenzbloecke (gebaut 4129 Befehle); nachher 3456 gleich, 574 Bloecke (gebaut 4604).  `--check as`: OK.  Im Bericht stehen noch 59 "delete"-Bloecke, davon 12 in yyparse (0030) bei den Fallkoerpern (u.a. 0374, 043A, 0522, 05DA, 062E, 069C, 0782, 098A).  Ursache *nicht untersucht* (Ausrichtung der Diffs oder anders uebersetzte Faelle); die Fallkoerper wurden nicht Befehl fuer Befehl geprueft.  Ein zweiter Bau fand nicht statt.

## Offen

Stubs, die der Parser aufruft: f2dac, f2dcc, f2e38, f3844, f404a, f3fd6, f40a4, f4372, f43ae, f3e9e, f167a, f19da, f1a1e, f1938, f1ab6.  Test `test_bau_alle_kennt_genau_die_fertigen_disketten` schlaegt im Worktree fehl (kein `disks/gebaut`), unabhaengig von dieser Aenderung (nicht gegen main geprueft).
