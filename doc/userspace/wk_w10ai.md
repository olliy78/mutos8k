# W10ai: c2x verkleinert (Mustertabellen statt ausgeschriebener Vergleiche) -- UNVOLLSTAENDIG, Budget der c2x-Baeue verbraucht

Stand 2026-11-25.  Plan 52, W10.  Vorgaenger: `wk_w10ah.md`.  Ziel: c2x-Bild 28994 B -> <= 26 KB, Ausgabe unveraendert.
**Ergebnis: Zwischenstand gemessen 26852 B (-2142 B); Zielwert 26624 B noch nicht erreicht; Abnahme (Regression, bau ld/cc/od/pr/ps/tar/as) nicht gefahren.**

## Aenderungen (alles unter `C2X`, Standard-c2 tokengleich, `tokcheck` OK)
1. **Musterwerk** in `c20.c` (`xg`, `xmn`, `xm`, `xmt`, Fenster `xw[10]`): Muster = Flagmaske, Ankerindex, Paare (Opwort `XP(op,sub)`, Codetext), Ende 0.
   Sonderops `XCB` (CBR oder CBRS), `XBR` (JMP oder JBR), `XNL` (kein Label), `XSA` (jeder Subop); Texte mit `*` (bis zum naechsten Komma) und `~` (Rest beliebig).
   Es wird nichts allokiert; alle `alloc`-Folgen (`xhead`/`copy`/`xins`) bleiben wie vorher (Haldenlage, F6).
2. Als Tabellen: `xsite` (R131-R133, R77, R92; R92 prueft das Sprungziel nach dem Treffer), `xldrules` (R97-R100, jetzt auch R45; Aufruf-Gate in `r5pass` um `XR45` erweitert),
   R64 (10 Knoten, `xr64`), R70 (`xr70`), R93 (`xr93`).  `R34` nutzt `xins`.
3. `xnd(n, XP(op,sub), s)` (ein Argument weniger); fuer die 21 Stellen ohne Text das Inline-Makro `XN(n, op, sub)`.
4. `xhead` kuerzer (gleiche Allokation).  `XBS` 256 -> 32 (zwei initialisierte Puffer, -448 B Daten).
5. **Nicht gebaut (Stand der Quelle im Baum):** `xparse` mit zwei Buchstabenstrings (`xl1`, `xl2`: Bit i = Buchstabe i) statt Tabelle `xpt`; `xld2m`/`xccpass` mit `XN`/`xg`.
   Erwartung ca. -180 B gegenueber dem gemessenen Stand (*Annahme*, nicht gemessen): damit ca. 26670 B, das Ziel 26624 B waere knapp verfehlt.  Ein Versuch, `xsp`/`sprintf` zu streichen,
   scheiterte am Link (`c21.c` `rmove` ruft `sprintf`, `_flsbuf` wurde hineingezogen: `Multiply defined _cleanup`); die Aenderung ist zurueckgenommen.

## Messung (gemessen, `c2x_c2.bin`, Disassembly `uspace.analysieren`; Funktionsgroessen in Byte, Aufrufziel-Zerlegung)
| Teil | W10ah | Zwischenstand (Bau 3) |
|---|---|---|
| `xsite` | 886 | 62 |
| `xldrules` (mit R45) | 892 | 340 |
| Musterwerk `xg+xmn+xm+xmt` | -- | 404 |
| `xccpass` | 730 | 640 |
| `xparse` | 348 | 212 (+ Tabelle `xpt`, 132 B Daten) |
| `r5pass` | 3612 | 2774 |
| Text / Daten / BSS | 23980 / 2746 / 2268 | 21940 / 2644 / 2268 |
| **Bild** | **28994** | **26852** |

## Baeue (Budget 4)
Bau 1: Uebersetzungsfehler (`xnd`-Definition vom Ersetzen zerstoert, `xw` ohne `extern`).  Bau 2: ok, Bild 26950 (`c2x_c2.bin` 24698 B).  Bau 3: ok, Bild 26852 (24600 B; die Datei wurde
von Bau 4 ueberschrieben).  Bau 4 (mit Punkt 5 und der `sprintf`-Streichung): Linkfehler.  Damit ist das Budget erschoepft; der Quelltext im Baum (Punkt 5 ohne `sprintf`-Streichung)
ist **uebersetzt noch nicht geprueft**.

## Abnahme
Gefahren: 65-Module-Lauf mit dem alten c2x (W10ah-Bild) als Vergleichsbasis: no-flag 65/65 SAME, `xpush` 60 gleich / 5 abweichend (c2/c21, convert, cpp, ed, passwd) -- wie W10ah.
Die Ausgaben (`.sn`) dieses Laufs liegen als Vergleich fuer den neuen Lauf bereit (gleiche Ausgabe Byte fuer Byte ist das Kriterium; ed/cpp/passwd koennen sich haldenbedingt aendern).
Nicht gefahren (kein gueltiges Endbild): 65-Module-Lauf mit neuem c2x, `bau ld/cc/od/pr/ps/tar/as --xcc` samt `vergleich`.
`pytest -q -m "not gast"`: 213 ok, 3 uebersprungen.

## Naechster Schritt
Ein c2x-Bau aus dem Quelltext im Baum; Bild messen (Ziel <= 26624 B).  Fehlen noch ca. 50 B: `cmppass` (R38/R60) ueber das Musterwerk, `xmn`-Sonderops zusammenfassen, doppelte
Mustertexte (`r2,#%3`, `r2,#%7`) teilen.  Danach 65-Module-Lauf (Vergleich der `.sn` mit dem alten Lauf) und die `bau`-/`vergleich`-Abnahme.
