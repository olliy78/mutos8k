# W7n: as: erste Haelfte der restlichen Stubs (12 Funktionen)

Alle Namen sind *Annahme* (das Original hat keine Symbole).  Lesart aus `as.lst`, je Funktionsbereich.

* 167A `mklabs`: `stpush(); g90cc = getlab(); g8d12 = getlab(); f3e9e(g90cc)`.
* 1938 `mkopnd(a,m)`: Operandzelle.  m = 16/34: nur Typ setzen.  Sonst neue Zelle (`getobj`); bei 2112 mit Operand 0x800 wird `a = 1 << a`; bei 256/2112 Verschmelzen mit der obersten Zelle von g90b0 (Wert or-en, g90de--).
* 19DA `endproc(a,b)`: Namen vergleichen ("wrong END of procedure"); Pass 1: `lapush(symend); symlim = symend`; dann `secsel(3); g8d10 = 0`.
* 1A1E `procnam(a)`: `g8d0e = d831e = 0`; g8d06 == 32: Bit 5 setzen; sonst Pass 2: `symend = lapop()`.
* 1A54 / 1A86 `lapush` / `lapop`: Wortstapel bufp2 mit Index g90c6 (Grenze 100, "too many local areas"); beide zaehlen **hoch** (`g90c6++`) -- so gemessen.
* 1AB6 `mkpair(a,b,m)`: m = 1 / 512 / 1024: Zelle waehlen, Typ m, Wert = (alter Wert & 0xFFFF) | (Index << 16); sonst `prmsg` + `fatal`.
* 1BDA `lstflush`: `fprintf(lstfile, "\t\t%05d  %s\n", yylineno, lbuf)`, wenn lptr != lbuf.
* 2DAC `setcon(a,b)`: Pass 1: `a[1] = b`; Typ 0x128; Ergebnis 0.
* 2DCC `symdef(a,b)`: Pass 1: `a[2] = b`; Schalter g8d06: 5 -> Typ 0x12B; 6 -> Bit 5, dann wie 7: `|= g90d0`, `a[1] = g9046`, `g9046 += b`; 32 -> Bit 5; sonst "error in typdf".
* 2E38 `passini(p)`: Pass 1: Konstantenpool gc79e+16, curname = D0F0 (8 Byte von p+8 kopiert), `*p = 0x40`.  Pass 2: Abschnittsgroessen auf gerade runden, se_d aufsummieren, 5 `lseek` der Ausgabedateien, Kopfworte gca70 = 0xE807, gca72..76 = Groessen.  Danach Zaehler 1..4 loeschen, g90e2 = objtab, gca80 = 1, g90d0 = 3.
* 35FE `valobj(a)`: `stpop()`, neue Zelle mit dem vorzeichenlosen Wort a[2] als Wert (im Quelltext noch ohne Aufrufer).

Neue Globale nur als `extern` in `as.h` (g90c6, gca70..gca76, gc79e; definiert in as_tab.c).  Aufrufe in `as.y`, `as_lex.c`, `as_main.c` umbenannt; `as_y.c` neu mit dem Gast-yacc, `as_grammatik.py --check`: alle 8 Tabellen EQUAL (gemessen).  mkopnd/mkpair/procnam/endproc sind unprototypisiert (K&R); Zeiger werden als `int` zurueckgegeben.

## Messung (`alles as --c2emu --libc alt --ist neu_c2`, zwei Baeue)

Vorher 3456 gleich von 5891 Befehlen, 574 Bloecke.  Bau 1: 3709 gleich, 627 Bloecke (gebaut 4951 Befehle).  Bau 2 (nach Korrekturen: Registerreihenfolge, `switch` statt `if` in mkopnd/mkpair/symdef, Rahmen von endproc 2 Worte, passini 5 Longs): **3764 gleich, 618 Bloecke** (gebaut 4961).  `--check as`: OK.  pytest `-m "not gast"`: 212 bestanden, 1 Fehlschlag (`test_bau_alle_kennt_genau_die_fertigen_disketten`, wie schon in W7m: kein `disks/gebaut` im Worktree).

## Offen

* mkpair: Original `LDL; XOR R2,R2; LDL` (Null-Erweiterung des unteren Wortes); mein `& 65535L` uebersetzt zu `AND` mit Maske.  Ein `(unsigned)`-Cast geht im Gast-cc nicht.
* passini: Original erweitert `sectab[i].se_pc` mit Null (`XOR R2,R2`), mein `long b = sectab[2].se_pc` mit Vorzeichen (`EXTS`); das deutet auf ein `unsigned` se_pc, nicht geaendert (Wirkung auf anderen Code ungeprueft).  Auch die Adressrechnung von `sectab[i].se_d` ist im Original anders geordnet.
* Der Bau-2-Bericht wurde nicht Block fuer Block ausgewertet; die uebrigen Unterschiede in diesen Funktionen sind laut Bau 1 vor allem verschobene Datenadressen, die erst mit den restlichen Stubs verschwinden (*Annahme*).
* Fuer yacc und `as_grammatik.py` wurden die unversionierten Dateien `userspace/ergaenzung/yacc/work/bau/yacc.bin` und `userspace/as/work/` aus dem Haupt-Checkout in den Worktree kopiert (nicht committet).
