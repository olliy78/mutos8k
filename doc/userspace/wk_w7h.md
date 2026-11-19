# W7h (Plan 52): `as` -- Ausdruck, Abschnitte/Direktiven, Knotenbelegung

Fortsetzung von `wk_w7g.md`.  *Gemessen* = Bau (`alles as --c2emu --libc alt --ist neu_c2`), sonst *Annahme*.  Alle Namen sind *Annahme*.

## 1. Fuellbyte der Tabellen-Pools (offener Punkt aus W7g)

* Host-Beweis `as_tabellen.py` (mit `work/as.raw` aus `pipeline.py holen as`): Tabellen 4770 B und Pool 1840 B gleich.
* Gast-Bau: der Pool 8322..8A51 (1807 B) steht **bytegleich** im gebauten Abbild (`bau/neu_c2.bin`).  Der Gast-`cc` behaelt `"\0"` also als Zwei-Byte-Zeichenkette; Punkt erledigt.

## 2. Rekonstruiert (je Funktion ein Block der Quelle)

* `as_expr.c`: `exprdo` (3620; unaer bei `b == 0`; Schalter ueber den 3-Eimer-Hash des Original-`cc`: `op / 3` wird verglichen, `op % 3` waehlt die Kette, Tabelle 6C06; Fallwerte also gewoehnliche Zahlen, aufsteigend), `upname` (3A18), `upstr` (3A5A, im Listing ohne eigenen Stub).
* `as_dir.c`: `secdir` (3B78, Tabelle 6E40), `outbyte` (3CEA), `dirset` (3D38), `dirclr` (3D52), `stpush`/`stpop` (3D6C/3DD0, Zustandsstapel `bufp3` mit Grenze `area3 + 94`, `bufp4`), `cpool` (3EC0, Konstantenpool ab `gc79e`, Zeiger `gca06`, Meldung `overflow of __constk__`), `secsave` (3F72), `secsel` (3FB0).
* `as_tab.c`: `nodeset` (43C6, 4-Fall-Schalter ueber Tabelle 6F7A: 0 Zaehler/Typ 2, 1 Kopie von 8 B, 2 Wert aus `B+4`/Typ 1, 3 Zeiger/Typ 20).
* Neu: `struct sect` (12 B) = Abschnittstabelle `sectab[8]` ab CA0A; `cp_o cp_q cp_p cp_r` sind Felder darin (CA24/26/30/32 gemessen), `gca12 + 12*n` aus `symget` ist `sectab[n].se_d`.  `gcc38` heisst `ucbuf`.
* 14 Funktionen; `exprdo` hat keinen Aufrufer (die yacc-Aktionen sind leer).

## 3. Messung

* W7g: gebaut 1996, passend 1198, 278 Bloecke.  W7h: gebaut **2421**, passend **1248** (1232 ohne c2-Modell), **288** Bloecke; text 12800 / data 12216 / bss 17724.
* Gast-`cc` kennt `(unsigned)` und `(unsigned char *)` als Cast nicht (`Misplaced 'unsigned'`): `& 0377` bzw. Vergleich ueber `(char *)`.
* Abweichungen (*Annahme*): `secdir` hat im Original `JP 3C98` auf die Fehlermeldung des zweiten Schalters (c2-Schwanzverschmelzung), hier zwei Aufrufe; `secdir` `default` im zweiten Schalter steht zuerst im Quelltext.  Das Grundlinien-Offen aus W7g (Datenadressen) bleibt.
* `--check as`: OK.  `pytest -m "not gast"`: 212 bestanden, 1 Fehlschlag (`test_bau_alle_kennt_genau_die_fertigen_disketten`, `disks/gebaut` fehlt im Worktree; wie W7g).
