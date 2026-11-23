# W10w: as-Absturz von c2x (Speichergrenze), Regeln R71 R34 R6 R65, ar cp date strip mit `--xcc` bytegleich

Plan 52 W10, Schritt 8. *Gemessen* (Gastlaeufe 2026-11-23), ausser wo *Annahme* oder *nicht gemessen* steht. `tokcheck` (c2 und cc) OK, `pytest -m "not gast"` 213 passed, 3 skipped.
**Stand der letzten Quelltextaenderung (`copy()`: exakter Vergleich, Abschnitt 2c) ist nicht im Gast gebaut und nicht gemessen** -- die Erlaubnis fuer weitere Gastlaeufe wurde verweigert (Budget ueberschritten). Naechster Schritt steht in Abschnitt 6.

## 1. Eingrenzung: welches Modul, welche Flags
* `c2gegen.quellen()` ueberspringt jetzt `noopt`-Module (as_y.c, as_tab.c; sie gehen nie an c2). Damit haengt `lauf ... as` nicht mehr auf as_y.c.
* Nur **`as_code.c`** bricht ab (`as_lex.c` laeuft; die anderen as-Module nicht einzeln gemessen). Der Fehler ist **flagunabhaengig**: `/usr/lib/c2x` ohne Flag auf `as_code.s0` (26034 B, 2430 Zeilen, eine Funktion `encode` mit 1850 Zeilen) liefert 0 Byte (Binary 24028 B) bzw. haengt (Binary 25636 B, nach 1058 s abgebrochen). Das ausgelieferte c2 und `neu_c2.bin` (unser c2 ohne `C2X`) sind auf derselben Eingabe in Ordnung (22388 B, gleich).
* Ein Lauf im Mehrmodul-Sitzungsmodus lief beim ersten Mal mit 1480 s und lieferte dazu `.sz` nicht (Platte /tmp voll nach c0/c1); mit `--s0` (c1-Ausgabe von der ersten Sitzung wiederverwendet) sind es 60 s je Modul.

## 2. Ursache
### a) Speichergrenze (gemessen)
* `sbreak()` des Kerns (`kernel/c/sys1.c`) prueft nichts: das Segment hat 64 KB, Heap und Stack stossen ohne Meldung aneinander. Folge: Absturz oder Haenger, keine Fehlermeldung (`C Optimizer: out of space` kommt nie).
* c2 gibt die Heapspitze mit der Option `-` aus (`%dK core`). Gemessen mit `neu_c2.bin`: **as_code 61K**, c21 50K, cpp 42K, ed 32K. Alle anderen der 65 Module liegen darunter; `encode` ist die groesste Funktion des Bestands (c2 gibt den Heap je Funktion frei, `lasta = firstr` hinter `output()`).
* c2x ist groesser als c2 (Text+Daten+BSS): 24028 B Datei (W10v) gegen 18956 B, *Annahme* rund 5 KB mehr Speicher, mit den neuen Regeln (25636 B) rund 6,7 KB. as_code braucht nur wenige KB mehr als c2 hat -> die Grenze wird gerissen. Ed, c21, cpp bleiben darunter.
### b) `x4keep` (Nebenbefund, Annahme)
`int x4keep;` (c21.c, nur unter `C2X`) lag als BSS-Variable hinter `ophash[79]`, in das `opsetup()` ein Wort hinter das Feld schreiben kann (W10q). Jetzt `int x4keep = 0;` (Datenbereich). Die Wirkung wurde nicht einzeln gemessen: der as_code-Absturz blieb danach bestehen (jetzt als Haenger).
### c) Fix: gemeinsame Zeichenketten in `copy()` (nur `C2X`)
`copy()` (c20.c) legt gleiche Zeichenketten nur einmal an (Hashkette `xih[64]`, Verbindungswort vor jeder Kette, Puffer `xtb`, beides im Datenbereich; `xih` wird mit dem Heap nach jeder Funktion geleert). Sicher, weil Knotentexte nach `copy()` nie beschrieben werden (alle Schreiber arbeiten auf `regs[]`, in c21.c durchgesehen) und Zeiger nie verglichen werden. Rechnung auf as_code.s0: 1802 Operandentexte, 588 verschieden, 15092 B gegen 5892 B.
* Erste Fassung verglich mit `equstr()`, das `#%5` und `#5` gleichsetzt: verschmolz verschiedene Texte. Messung (c2x 26170 B, 65 Module): **no-flag 62/65 SAME** (dd, ed, tar wichen ab, `djnz` fehlte), per Programm 56 gleich/9 abweichend. Auf as_code und as_lex (xpush, `--extra R3,R33,R39`): beide **EQUAL**, ohne Flag SAME -- der Absturz war also behoben.
* Aktuelle Fassung vergleicht Zeichen fuer Zeichen. **Nicht im Gast gebaut oder gemessen** (siehe oben).

## 3. Neue Flagbuchstaben (c2x, zweites Flagwort `xfl2`)
`a` R71 (ar, `ld rA,%k(FP) ; ld rB,rA ; jr L`), `n` R34 (cp, `test rN` hinter `ld MEM,rN` nach dem ersten Sprung wiederholt, fuegt einen Knoten ein), `d` R6 (date, `ld rA,M ; testb @rA ; jr cc ; ld rB,rA` -> `ld rB,M`), `g` R65 (strip, `ld r1,#k` statt Register). Knotenweise Form der Modellregeln in `r5pass()`, gleiche Bedingungen; `-xA` enthaelt sie. Eine Stelle je Regel: `c2gegen.FLAGBUCHSTABE`, `xcc.REGELN`.
**xcc**: `-X` addiert jetzt mehrere Optionen (bis 36 Buchstaben, Puffer 40; sonst Meldung statt stummem Abschneiden). Tokenstrom ohne `-DXCC` unveraendert; `xcc_c2_s.bin` 6890 B.

## 4. Messungen (c2x_c2.bin 25636 B = mit neuen Regeln und x4keep, **ohne** gemeinsame Zeichenketten)
* Regression 65 Module, ein Gastlauf: **no-flag 65/65 SAME**; je Programm mit Flags **57 gleich, 8 abweichend** (wie W10v; c0/c00, c0/c02, c2/c21, convert, cpp, ed, passwd, tar).
* Bauten `bau NAME --xcc --libc alt` + `vergleich --ist neu_x`, alle **bytegleich**: **ls** 8244 B, **hex** 4310, **ar** 10034, **cp** 3576, **date** 5758, **strip** 4014 (R71, R34, R6, R65 frei geschaltet).
* ls und hex sind damit mit einem c2x nach W10w gemessen, aber mit dem Binary **vor** den gemeinsamen Zeichenketten; mit dem endgueltigen c2x nicht wiederholt.
* **as**: `bau as --xcc --libc alt` (Binary 25636 B) lief 90 min ohne Fehlermeldung bis zum Zeitlimit (alle Module in einem Gast hintereinander; as_code allein braucht c1 ca. 25 min). Nicht bewertbar. Mit `lauf as --s0` (c2x-Lauf auf den c1-Ausgaben) sind as_lex und as_code mit dem Binary 26170 B gleich dem Modell (Abschnitt 2c).

## 5. xccgap (`pipeline.py xccgap`)
`ready` zusaetzlich: **ar, cp, date, strip**. Offen (Regel(Stellen)): c0 R130-133, c1 R48 R62, cc R93-96, cmp R61 R62, convert R72-76, dcheck R35-37, dd R66 R67, ed R80-91, getty R8 R9, icheck R46-48, ld R97-100 (R45 ist da), mkfs R46-58, od R60, passwd R68 R69, pr R70, ps R77, sh R11-16, tar R92. Naechste Einzelregeln: od (R60), pr (R70), ps (R77), tar (R92).

## 6. Offen / naechster Schritt
1. `python3 -I tools/userspace/c2gegen.py var c2x C2X`, dann `pipeline.py bau c2 --c2emu --libc alt --quelle c2x=userspace/c2/work/var/c2x` (c2x mit exaktem Vergleich in `copy()`).
2. Regression (`lauf ... --kurz --s0 --auto --null --regeln R1,R4,R38,R2,R30,R63,R43,R7,R3,R10,R32,R5,R42,R64,R45,R71,R34,R6,R65 --extra R3,R33,R39`): erwartet no-flag 65/65 SAME, per Programm nicht schlechter als 57/65, dazu `lauf as --s0 ...` (as_code muss durchlaufen).
3. ls und hex neu bauen; danach `bau as --xcc --libc alt` mit grossem Zeitlimit (mehrere Stunden; ein Gast baut alle Module nacheinander).
Fallback, falls die gemeinsamen Zeichenketten nicht reichen: c2x schlanker machen (Speicherbedarf gegen as_code) oder die `-X`-Regeln fuer as_code ueber ein eigenes, kleineres c2x-Binary legen.

## 7. Verbrauch
c2-`bau` 2 (1. neue Regeln + x4keep, 2. + gemeinsame Zeichenketten mit `equstr`-Vergleich; der 3. Bau mit exaktem Vergleich wurde verweigert), xcc-`bau` 1, c2gegen-Laeufe: as-Eingrenzung (3, davon 1 mit 25 min je Modul), Bisektion (ergebnislos, haengt), Speichermessung, 2 Regressionen (65 Module) plus 2 `lauf as`; Programmbauten mit `--xcc`: ls hex ar cp date strip, ls (abgebrochen), as (Zeitlimit). Das Budget wurde ueberschritten.
