# W7b (Plan 52): Grammatik des `as` zurueckgewonnen

Ergebnis: `userspace/as/as.y` (171 Regeln + `$accept`) erzeugt mit dem **Gast-yacc** (SMALL, `erg_yacc.py`) **alle 8 Tabellen wortgleich** zum Original (yyexca 14, yyact 737, yypact 268, yypgo 77, yyr1 172, yyr2 172, yychk 268, yydef 268 Worte).
Gleiches Ergebnis mit einem Host-V7-yacc (`original/unix-v7/usr/src/cmd/yacc`, `gcc -std=gnu89 -w -DWORD32`, im Scratchpad gebaut, `files`: `PARSER "yaccpar"`).  Ein Gastlauf fuer die Grammatik (plus der einmalige Bau `erg.py bau yacc`).

## Verfahren (gemessen)

`tools/userspace/as_grammatik.py` (`userspace/as/work/as.raw` aus `pipeline.py holen as`; `--y` schreibt `as.y`; `--check DATEI.c` vergleicht die 8 Tabellen einer yacc-Ausgabe mit dem Original):

* Tabellen aus dem Abbild (Adressen wk_w7a.md).  Schiebeuebergaenge `s --t--> yyact[yypact[s]+t]` mit `yychk[Ziel]==t`; Reduktionen aus `yydef` und `yyexca`.
* Gotos (`yypgo`) sind nicht pro Zustand ablesbar (Standardziel gilt fuer beliebige Zustaende).  Loesung: Fixpunkt -- ein Goto `p --lhs--> q` wird erst aufgenommen, wenn `p` der Zustand `yyr2` Schritte unter einem Zustand ist, der die Regel reduziert.
* Rechte Seite einer Regel = `yychk` der Zustaende auf diesen Pfaden (der Zugangssymbol-Satz je Position ist fuer alle 169 anderen Regeln einelementig, also eindeutig).
* Token: Zahlen aus `yychk`; Namen aus der Schluesselworttabelle 706E-7102 und der Bedingungstabelle 7102-72AA (z. B. `MODULE`=3, `END`=29, `IF`=281, `CASE`=285, `LNOT`=292); Zeichen als `'c'`; 256 = `error`.

## Befunde

* **Zwei Regeln (122, 123) werden im Original nie reduziert** (yacc: "2 rules never reduced"; die Reduce/Reduce-Konflikte mit der leeren Regel 91 gehen zugunsten der frueheren Regel).  Ihre rechte Seite ist aus den Tabellen nicht ablesbar.  Gesetzt (*Annahme*, durch den Tabellenvergleich bestaetigt): 122 leer, 123 `ELSE nt53`; die zwei Goto-Kanten 240->252 (Regel 118) und 261->266 (Regel 121) sind in `EXTRA` von Hand fixiert.  Lesart: `IF cc THEN stmts [ELSE stmts] FI` (118) und `IF nt75 CASE expr THEN stmts [ELSE stmts] FI` (121) (*Annahme* fuer die Deutung).
* **Praezedenz** (aus den uebrig bleibenden Shifts der Original-Tabellen, gemessen; Rest *Annahme*): Stufe 1 `< > =` (links), 2 `+ - LOR LXOR` (links), 3 `* / MOD SHL SHR LAND` (links), 4 `LNOT`; die unaeren `+ -` (Regeln 162/163) binden staerker als alle binaeren (ihre Zustaende reduzieren bei jedem Operator): `%prec LNOT`.  Ohne Praezedenz: 371 S/R-Konflikte und abweichende yyact/yypact/yypgo (yyexca, yyr1/2, yychk, yydef waren schon gleich); mit: 137 S/R + 7 R/R, alles gleich.  Ob das Original ein Hilfstoken statt `LNOT` fuer `%prec` verwendete, ist aus den Tabellen nicht entscheidbar.
* Nichtterminal-Nummern des Originals: `nt1..nt17` kommen vor der Startregel (nt18), also vor der ersten Regel vorab genannt -- `%union`/`%type <u> nt1 ... nt17` in `as.y` reproduziert das (*Annahme*: das Original deklarierte sie per `%type`; nt1 = Ausdruck, nt2 = Ausdrucksliste, nt3, nt4 = Operand, nt13..16 = Adressierungsformen `#expr`, `r(n)`).
* Tokens 16 `SEG`, 17 `OFFSET`, 25 `RECORD` stehen in der Schluesselworttabelle, kommen aber in keiner Regel vor.  Ohne Namen (`TOKnnn`, *Annahme* fuer die Bedeutung): 294, 296, 297, 299, 300, 302, 305, 311, 314, 315; `IDENT`=298, `NUMBER`=293 sind aus den Regeln geschlossen.  Gruppen: `CCODE`=306, `CCODE2`=307 (Z C), `SPV`=308, `CTLREG`=309, `FPFLAG`=310, `VIFLAG`=312, `SECDIR`=313 (`$NONSEG` ..), `INITKW`=304 (`BVAL WVAL LVAL`), `DATADIR`=316, `CODEDIR`=317.
* Nichtterminalnamen: nur `ntN` (die Tabellen kennen keine Namen); Aktionen sind Platzhalter `{ /* action N */ }`, Aktionsnummer = Regelnummer = `case N` im Schalter 65CE.

## Dateien

`userspace/as/as.y`; `userspace/as/as_y.c` (Gast-yacc-Ausgabe, von `erg_yacc.py userspace/as/as` als `as.c` erzeugt, hier umbenannt; `as_grammatik.py --check userspace/as/as_y.c` -> 8 x EQUAL); `tools/userspace/as_grammatik.py`.

## Offen

* Namen der Nichtterminale und der Tokens 294..315 (Aktionen lesen: W7e), Bedeutung der Regeln 118/121.
* Das `%prec`-Token, die Lage der `%left`-Zeilen und die `%type`-Deklaration sind nur nach ihrer Tabellenwirkung bestimmt.
* Naechster Schritt: Scanner (W7c) und Aktionen.
