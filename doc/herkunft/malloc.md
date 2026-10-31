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
