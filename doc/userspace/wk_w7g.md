# W7g (Plan 52): `as` -- BSS-Lage und Symboltabellen-Gruppe

Fortsetzung von `wk_w7f.md`.  *Gemessen* = Gast-Bau (`alles as --c2emu --libc alt --ist neu_c2`, zwei Laeufe), sonst *Annahme*.  Alle Namen sind *Annahme*.

## 1. BSS-Lage (`as_tab.c`)

* Aus dem Listing: jede Adresse >= 8BD6 mit Zugriffsbreite.  Eigen-BSS = 8BD6..CCEE: `yylval yyval yyv[150]` (8BD6..8D06, aus `as_y.c`), dann in Adressreihenfolge `g8d06..g8d12`, `yycnt` (8D24), `yyskip`, `yysbuf[200]` (8D28), `yytchar`, `yylineno`, `lflag` (8DF4), `lbuf[128]`, `yytext[200]` (8E76), `yyleng`, `cls[128]` (8F42), Zustandsworte 9042..904A, `objtab` (904C), `bufp2` (90C8), `uflag` (90E4), zwei 200-B-Puffer (90E6, 91AE), `fd_o` (927A), `fd_q`, `numcls[8]` (927E), `errcount` (9286, 35AC `INC`), `cflag` (928A), `oname` (928C), `symtab[13584]` (928E..C79E; Ende = `symlim`), Hilfsfeld 616 B (C79E..CA06), `curname` (CA08, `error()` schiebt es als Modulname), Satztabelle ab CA12 (12-B-Saetze; `cp_o` CA24, `cp_q` CA26, `cp_p` CA30, `cp_r` CA32 liegen darin), `fd_p fd_r fd_s` (CA6A/6C/6E), `gca78` (laufende Symbolnummer), `bufp1` (CB22), `area3` (CB24), `bufp3` (CB88), `area4` (CB8A), `bufp4` (CC20), `lname` (CC22, nur 20 B bis zum Nachbarn CC36: Dateinamenpuffer, *Annahme*), CC36..CCEE.
* Luecken zwischen zwei Zugriffen sind `gXXXX`-Fueller (Inhalt unbekannt).  Fehler im ersten Entwurf: ein Feld `gccee[1080]` bis D126.  Befund: **CCEE ist der Anfang des libc-BSS** (die 1080 B ab CCEE sind libc).  Gemessen: nach der Korrektur steht `environ` im Bau an der Originaladresse (der erste Unterschied des Befehlsvergleichs ist nicht mehr `LD B+4518,R7`); bss gebaut 17724 gegen 17744 -- die 20 B Rest liegen im gebauten libc-BSS (`libc_alt`, hier nicht angefasst).
* Befund: `%CB22` (`ADD R2,%CB22`) ist der **Zeiger `bufp1`** (Hashtabelle auf dem Stack von `main`, `loc2[3202]` = 1601 Worte), nicht die Tabelle selbst.
* Das Fuellbyte zwischen den Tabellen-Pools (wk_w7e.md): Sentinel-Eintrag jeder Tabelle jetzt `"\0"` (zwei Bytes NUL + Ende) statt `""` (`as_tabd.h`, `as_tabellen.py` angepasst; *Annahme*: so schrieb es das Original).  **Nicht gemessen**: der Host-Beweis (`as_tabellen.py`) braucht `work/as.raw`, das im Worktree fehlt; die Pool-Adressen im gebauten Abbild wurden nicht verglichen (offen, ob der Gast-`c0` `"\0"` als 2-Byte-Zeichenkette behaelt).

## 2. Symboltabellen-Gruppe (aus dem Listing, Namen *Annahme*)

* 44F0 `hashfind(s, ind)` (`as_tab.c`): Hash aus den ersten drei Zeichen (4 Bit versetzt), `% 1601`, Schritt 32 rueckwaerts; Tabelle `*bufp1`; `ind` = Eintrag zeigt auf Namenszeiger, sonst Zelle mit Name bei +8; Vergleich mit `cmp8`.
* 46DA `kwlook(s)`: Suche in Schluesselwort-/Bedingungs-/Flag-/Mnemonik-Tabelle, setzt `yylval`; die Suche steht im Original zweimal hintereinander.
* 4814 `symadd(n)`: Zelle (16 B) anlegen; n = 6 unten (`symcur`), sonst oben (`symend`, `d831e = 0`); Meldungen `illegal --totab-- in PASS1`, `fatal error: symbol table overflow`; Name 8 Zeichen, `s_w = -1`.
* 48A4 `symget(n)`: Suche (Hash bzw. linear `symend+16..symlim`); in Pass 1 laufende Nummer (`gca78`), Schalter ueber Typ & ~0x20 (`undefined symbol`, Relokation ueber Tabelle CA12).
* 16A0 `labsym(a, t)` (`as_misc.c`): Marke `"#%6d"` (Token 0x125) anlegen/suchen; `:` setzt Wert und Typbits.
* 3E1E `getlab()` (`as_dir.c`): numerische Marke, Zaehlerzeichenkette `numcls`, Uebertrag ueber 8 Stellen; Meldungen `too many generic labels`, `getlab: label not found in PASS1`.

`struct sym` ist jetzt die 16-B-Zelle `{s_t, s_v, s_x, s_w (+6), s_name[8] (+8)}` (vorher `s_w` bei +4, falsch).  Aufrufer in `as_lex.c` umbenannt.  Offen: `s_v` ist im Original an einer Stelle `long` (LDL bei +2), an anderer ein Zeigerwort (+2); mit einem Feld nicht beides darstellbar.  Die Zustandsworte (`g90dc` ...) sind Entwurf.

## 3. R45

`C2_AUS["as"] = {"R45"}` gesetzt (Hash-Schalter `yylex`).  Wirkung: das c2-Modell schreibt R45 nicht mehr um (`R45: 0` im Lauf).  Ob der Schalter nun Block fuer Block `XOR R2,R2` hat, wurde nicht einzeln geprueft.

## 4. Messung (Befehlsvergleich, ganzer Eigencode)

* W7f Lauf 2: gebaut 1600, passend 1002, 203 Bloecke.
* W7g Lauf 1 (BSS-Fehler `gccee`): gebaut 1996, passend 1197 (1181 ohne c2-Modell), 279 Bloecke.
* W7g Lauf 2: gebaut **1996**, passend **1198** (1182 ohne c2-Modell), **278** Bloecke; text 11034 / data 11948 / bss 17724 (Original 22092 / 13706 / 17744).  Die Blockzahl ist hoeher als in W7f, weil rund 400 neue Befehle (die sechs Funktionen) dazukamen, deren Datenadressen (Zeichenketten, Daten-Grundverschiebung) noch abweichen; die BSS-Lage selbst liegt nun an den Originaladressen.
* `--check as`: OK.  `pytest -m "not gast"`: 212 bestanden, 1 Fehlschlag `test_bau_alle_kennt_genau_die_fertigen_disketten` (wie in W7f: `disks/gebaut` fehlt im Worktree).
