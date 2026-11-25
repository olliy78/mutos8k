# W10ai: c2x verkleinert (Mustertabellen statt ausgeschriebener Vergleiche)

Stand 2026-11-25.  Plan 52, W10.  Vorgaenger: `wk_w10ah.md`.  Ziel: c2x-Bild 28994 B -> ca. 26 KB, Ausgabe unveraendert.
**Ergebnis (gemessen): Bild 26712 B (-2282 B; Text 21896, Daten 2548, BSS 2268), Datei `c2x_c2.bin` 24460 B.  Alle 65 Ausgaben (`.sn`) byteweise gleich dem Lauf mit dem W10ah-c2x;
cc, ld, od, pr, ps, tar byteidentisch mit `--xcc`; `as` linkt (4140/5891).**  Das Ziel 26624 B ist um 88 B verfehlt (Entscheidung des Koordinators: ~26,7 KB genuegt).

## Aenderungen (alles unter `C2X`, Standard-c2 tokengleich, `tokcheck` OK)
1. **Musterwerk** in `c20.c` (`xg`, `xmn`, `xm`, `xmt`, Fenster `xw[10]`): Muster = Flagmaske, Ankerindex, Paare (Opwort `XP(op,sub)`, Codetext), Ende 0.
   Sonderops `XCB` (CBR oder CBRS), `XBR` (JMP oder JBR), `XNL` (kein Label), `XSA` (jeder Subop); Texte mit `*` (bis zum naechsten Komma) und `~` (Rest beliebig).
   Es wird nichts allokiert; alle `alloc`-Folgen (`xhead`/`copy`/`xins`) bleiben wie vorher (Haldenlage, F6).
2. Als Tabellen: `xsite` (R131-R133, R77, R92; R92 prueft das Sprungziel nach dem Treffer), `xldrules` (R97-R100, jetzt auch R45; Aufruf-Gate in `r5pass` um `XR45` erweitert),
   R64 (`xr64`), R70 (`xr70`), R93 (`xr93`).  R34 nutzt `xins`.
3. `xnd(n, XP(op,sub), s)` (ein Argument weniger); 21 Stellen ohne Text nutzen das Inline-Makro `XN(n, op, sub)`; `xld2m`/`xccpass` ebenfalls.
4. `xhead` kuerzer (gleiche Allokation).  `XBS` 256 -> 32 (zwei initialisierte Puffer).  `xparse`: zwei Buchstabenstrings `xl1`/`xl2` (Bit i = Buchstabe i, Reihenfolge wie `c2.h`) statt Tabelle.
5. Versuch, `xsp`/`sprintf` zu streichen: Linkfehler (`c21.c` `rmove` ruft `sprintf`; `_flsbuf` wurde hineingezogen, `Multiply defined _cleanup`); zurueckgenommen.

## Messung (gemessen, Disassembly `uspace.analysieren`; Funktionsgroessen in Byte; Bau 3 = Zwischenstand, Endbild siehe oben)
| Teil | W10ah | Bau 3 |
|---|---|---|
| `xsite` | 886 | 62 |
| `xldrules` (mit R45) | 892 | 340 |
| Musterwerk `xg+xmn+xm+xmt` | -- | 404 |
| `xccpass` | 730 | 640 |
| `xparse` | 348 | 212 (+ Tabelle `xpt` 132 B Daten, im Endstand durch 32 B Strings ersetzt) |
| `r5pass` | 3612 | 2774 |
| Text / Daten / BSS | 23980 / 2746 / 2268 | 21940 / 2644 / 2268 |
| Bild | 28994 | 26852 (Endstand 26712) |

## Abnahme (gemessen)
* c2x-Bau (`bau c2 --c2emu --libc alt --quelle c2x=...`): 321 s + 139 s.  Gesamtzahl der Baeue in W10ai: 5 (Uebersetzungsfehler, ok, ok, Linkfehler, Endbau).
* 65-Module-Lauf (`lauf ... --kurz --s0 --auto --null --extra R3,R33,R39 --regeln <alle>`): **no-flag 65/65 SAME**; **alle 65 `.sn` byteweise gleich** dem Lauf mit dem c2x von W10ah (`cmp`);
  `xpush`: **60 gleich, 5 abweichend** (c2/c21, convert, cpp, ed, passwd) -- wie W10ah.
* `bau X --xcc --libc alt` + `vergleich X --ist neu_x`: **ld** 10710 von 10710 B, **cc** 6520/6520, **od** 5536/5536, **pr** 8294/8294, **ps** 7830/7830, **tar** 16984/16984: BYTE-IDENTICAL.
  **as**: linkt, Binary 35330 B (482 s), 4140 von 5891 Befehlen gleich, 725 Differenzbloecke (wie W10ah).
* `tokcheck` c20.c/c21.c OK; `pytest -q -m "not gast"`: 213 ok, 3 uebersprungen.

## Budget
c2x-Baeue 5 (4 + 1 Zusatz des Koordinators), 65-Module-Laeufe 2 vollstaendig (Basis, neu) + 1 abgebrochen (Worktree entfernt), bau ld cc od pr ps tar as je 1, `vergleich` Host.

## Offen
Fuer 26624 B fehlen 88 B: `cmppass` (R38/R60) ueber das Musterwerk, `xmn`-Sonderops zusammenfassen, doppelte Mustertexte teilen.
