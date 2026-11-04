# Herkunft von `kernel/c/malloc.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/malloc.c` (= System III PDP-11 `uts/os/malloc.c`, textgleich bis auf `register unsigned int a` in `mfree`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7 = SysIII).  Beide Funktionen tragen jetzt den V7-Text einschliesslich der Kommentare; die zwei MUTOS-Zeilen sind mit `/* MUTOS: ... */` markiert.
  Dateiaehnlichkeit V7 83 % -> 94 %, `malloc` 71 % -> 95 %, `mfree` 91 % -> 94 %.
* **Eigener Zug (weder V7 noch System III):** die Karte hat hoechstens 15 Eintraege: `malloc` bricht die Suche bei `bp - mp >= 15` ab, `mfree` ruft `panic("map overflow\n")`, wenn ein 16. Eintrag
  noetig wird (`bp - mp > 15`, Text bei 8AE4).  Weder `original/unix-v7` noch `original/sys3` enthalten diese Pruefung oder den Text (`rg 'map overflow' original/`: keine Treffer).  Herkunft *offen* (H6).
* Rundlauf: **0 von 2 bytegleich, vorher 0 von 2; Woerter unveraendert** (`malloc` 24 von 52, `mfree` 1 von 119) -- der V7-Text (`if ((bp->m_size -= size) == 0)`, `register unsigned int a/t`)
  erzeugt denselben Objektcode wie die alte Fassung.  Kein Rueckfall noetig, die Zahlen sind nicht schlechter.

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| malloc | 2DF0 | 71 % -> 95 % | veraendert | `if (bp - mp >= 15) break;` (eigen) | nahe (24 von 52 Woertern, wie vorher) |
| mfree | 2E5A | 91 % -> 94 % | veraendert | `if (bp - mp > 15) panic("map overflow\n");` (eigen); `register int a` | nahe (1 von 119 Woertern, wie vorher) |

## Ursache der Abweichung (gemessen am Wortvergleich `vergleich.py -v`, Deutung *angenommen*)

* `mfree`: das eine Wort ist `cp r2,#15` (Objekt) gegen `cp r3,#15` (Kernel): der Kernel-`c2` verwendet nach `exts rr2 ; div rr2,#4 ; ld r2,r3` den Quotienten in `r3` weiter,
  der Gast-`c2` bleibt bei `r2`.  Gleiche Wirkung in `malloc` (`cp r3,#15`), dort kommt hinzu, dass der Kernel nach `m_size -= size` ein `test r2` ausfuehrt, das der Gast-`c2` als ueberfluessig streicht
  (Kernel 2 Woerter laenger, daher verschieben sich die Sprungziele).  Das ist das Muster (B) aus `doc/kernel/c_rueckbau.md` (K7b), kein Quellformproblem.
  **Nachgemessen 2026-11-04 (Plan 43 Gruppe A):** 9 Formen des Vergleichs `(bp-mp) > MAPSIZ` (Konstante links, `>= MAPSIZ+1`, `(int)`/`(unsigned)`-Umwandlung, Differenz `- MAPSIZ > 0`, `!(<=)`, Zwischenvariable ohne/mit `register`) ergeben alle `cp r2,#15` (oder Speicher/Register der Zwischenvariable), nie `cp r3`; 4 Formen von `m_size -= size` (im `if`, getrennte Anweisung, `!(...)`, `!= 0` mit `goto`) ergeben alle ohne `test r2`.  Im ganzen Kernel steht hinter `ld r2,r3` sechsmal `cp r3,#..` (`malloc`, `mfree`, 3 in `tty2`, 1 in `exece`) und nie `cp r2,#..`: eine `c2`-Eigenheit, nicht ueber den Quelltext erreichbar.


## Nachzug H6d (2026-11-03): Text der Hippe-Sammlung

Vorlage: `original/hippe-v7/usr/sys/sys/malloc.c` der TUHS-Sammlung (Standardkonfiguration `conf/m.h`: `PROC_MAX`, `EXIT`, `LRUI` an; Schalterauflösung `tools/herkunft/ifdef_resolve.py`; "Hippe-Sammlung" = Name der Sammlung, nicht des Urhebers).
`malloc` und `mfree` tragen den Vorlagentext (`for(bp=mp;bp->m_size && ((bp-mp) < MAPSIZ);bp++)`, `if((bp-mp) > MAPSIZ) panic(...)`, `MAPSIZ = NPROC/2` in `param.h`; `CMAPSIZ/SMAPSIZ 50 (guessed)` entfallen).  Einzige Abweichung: die Zeichenkette heisst `"map overflow\n"` (Kernel 8AE4 hat das `\n`).
Rundlauf (Gast `cc -O -c`, je Funktion gegen `mutos_1216`) nach der Änderung: **weiter 0 von 2 bytegleich, Wortzahlen unveraendert** (`malloc` 24 von 52, `mfree` 1 von 119): der Vorlagentext ist nicht schlechter.  Gruppe B, Probevarianten in einem Lauf (`malloc`: Bedingungen vertauscht 47/52, `m_size -= size` getrennt 24/52, `break` statt Schleifenbedingung 24/52; `mfree`: `bp-mp > MAPSIZ` 1/119, `>= MAPSIZ+1` 3/119, Cast `(int)` 1/119): **keine Variante bytegleich**.
