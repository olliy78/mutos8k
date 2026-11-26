# W10aj: c2x-Varianten je Regelgruppe

Stand 2026-11-26.  Plan 52, W10.  Vorgaenger: `wk_w10ai.md`.  Ziel: schlanke Grundvariante von c2x; die programmeigenen Regelgruppen nur in der Variante, die sie braucht.
**Ergebnis (gemessen): Grundvariante 25342 B Bild (W10ai: 26712, -1370 B).  as bindet und laeuft mit der Grundvariante weiter nur MIT Schalter S (ohne S: Bau haengt/Zeitgrenze 1500 s).
ld, cc, od, pr, ps, tar, c0 bytegleich mit `--xcc`; Regression 65/65 (ohne Schalter) und `xpush` 60/65, mit der Vollvariante wie mit den Einzelvarianten.**

## Aenderungen (eine Quelle `userspace/c2/c20.c`, `c21.c`; Standard-c2 tokengleich, `tokcheck` OK)
1. Compilerschalter (zusaetzlich zu `C2X`): `C2X_LD` (R97-R100, Buchstaben f h i j: Tabelleneintraege in `xlt`, Faelle in `xldrules`), `C2X_CC` (R93-R96, `y`: `xr93`, `xld2m`, `xccpass`, `xhdeq`, `xccvar`, Aufruf in `main`), `C2X_C0` (R130 in `c21.c`; R131-R133, `l`: vier Eintraege in `xst`).
   R45 (`e`) bleibt allgemein (nur die Fallnummer in `xldrules` haengt davon ab: `XCASE45` 5 mit LD, sonst 1); R92 in `xsite` ebenso (`XSI92` 6 bzw. 2).  `xfl3` bleibt in jeder Variante (Datenlage).
2. Schutz: `xparse` ruft fuer einen Buchstaben einer fehlenden Gruppe `xdeny()` (Meldung `c2x: switch -x<c> needs a c2x variant with its rule group`, exit 1).  Gast nicht gemessen (nur Quelltext-/Host-Test).
3. `c2gegen.py`: `VARIANTEN` (c2x, c2xld, c2xcc, c2xc0, c2xall), `c2x_variante(programm)`, `c2x_bin()`, `variante_erlaubt()`; `var NAME` ohne Defines nimmt die der Variante.
   `pipeline.py xcc_einstellung` waehlt die Variante je Programm (ld -> c2xld, cc -> c2xcc, c0 -> c2xc0, sonst c2x) und bricht ab, wenn ein Buchstabe der Programmflags der Variante fehlt.  Es liegt immer nur eine c2x auf der usr-Platte.
4. Bau: `c2gegen.py var <variante>`, dann `pipeline.py bau c2 --c2emu --libc alt --quelle <variante>=userspace/c2/work/var/<variante>` -> `userspace/c2/work/bau/<variante>_c2.bin`.
5. Host-Test `tests/test_c2x_varianten.py` (Variantenwahl gegen alle Programmflags, Gruppencode nur in der gewaehlten Variante, `xdeny`-Buchstaben = fehlende Gruppen; per `cpp`).

## Messung (gemessen, Kopf der `.bin`; Bytes)
| Variante | Text | Daten | BSS | Bild | Datei |
|---|---|---|---|---|---|
| W10ai (alles) | 21896 | 2548 | 2268 | 26712 | 24460 |
| c2x (Grund) | 20938 | 2136 | 2268 | 25342 | 23090 |
| c2xld | 21192 | 2364 | 2268 | 25824 | 23572 |
| c2xcc | 21692 | 2204 | 2268 | 26164 | 23912 |
| c2xc0 | 20956 | 2310 | 2268 | 25534 | 23282 |
| c2xall | 21912 | 2548 | 2268 | 26728 | 24476 |
c2xall ist 16 B groesser als W10ai (Tabellen/Makros), Ausgabe gleich.

## Abnahme (gemessen)
1. Grundvariante 25342 B < 26712 B (-1370 B).  OK.
2. `bau as --xcc --libc alt`: **ohne S** (`C2GEGEN_NOS=1`, Grundvariante): Bau lief in die Zeitgrenze 1500 s (kein Binary, Log leer) -- as_code passt auch mit der schlanken Grundvariante nicht in das 64-KB-Segment (Annahme; Ursache nicht weiter untersucht).  **Mit S**: Binary 35330 B (418 s), 4140 von 5891 Befehlen gleich, 725 Differenzbloecke (wie bisher).  S bleibt fuer as_code noetig.
3. `vergleich X --ist neu_x`: **ld** 10710/10710, **cc** 6520/6520, **od** 5536/5536, **pr** 8294/8294, **ps** 7830/7830, **tar** 16984/16984 BYTE-IDENTICAL (alle `--xcc`, jeweils mit der Variante des Programms).  **c0** (Variante c2xc0; c01/c03/c05 ohne Regel mit plain cc): 26810/26810 BYTE-IDENTICAL.
4. 65-Module-Lauf (`lauf ... --kurz --s0 --auto --null --extra R3,R33,R39 --regeln <alle>`):
   Lauf 1 mit c2xall, Lauf 2 mit je Programm passender Variante (ld/cc/c0 eigene, Rest Grundvariante; kein Abbruch durch `xdeny`): beide **ohne Schalter 65/65 SAME**, `xpush ... --extra R3,R33,R39` **60 gleich, 5 abweichend** (c21, convert, cpp, ed, passwd -- wie W10ai).
   Ausgabegroessen aller 65 Module in Lauf 1 und 2 gleich; die 5 schwierigen Module (c21, convert, cpp, cpy, ed, passwd) byteweise gleich zwischen den Laeufen.  Hinweis: ein Vergleich der `.sn` mit den von Hand kopierten Dateien der Hauptsitzung (44 Abweichungen) taugt nicht als Referenz (alter Lauf mit anderen Flags); massgebend ist `xpush`.
   Wahl der Vollvariante fuer Lauf 1: gleiche Regressionsmenge wie W10ai; Lauf 2 prueft die Variantenwahl.
5. `tokcheck` OK; `pytest -q -m "not gast"`: 216 ok, 3 uebersprungen.

## Budget
c2x-Baeue 5 (Grund, all, ld, cc, c0; ein Fehlstart wurde abgebrochen und nicht gezaehlt), 65-Module-Laeufe 2, Baeue ld cc od pr ps tar c0 je 1, **as 2** (ohne S haengt, mit S) -- einer ueber Budget, noetig fuer die Abnahme 2.

## Offen
* Abbruch von c2x bei fremdem Gruppenbuchstaben im Gast nicht gemessen.
* Warum as_code ohne S selbst mit der Grundvariante nicht laeuft (Heap, nicht Bildgroesse?) -- Bildgroesse 25342 B ist nur 1,3 KB kleiner als W10ai.
* Die c2x-Binaries liegen in `userspace/c2/work/bau/` (nicht im Repo); die Hauptsitzung muss sie kopieren.
