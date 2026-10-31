# Herkunft von `kernel/c/text.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/text.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  `xswap` und `xfree` tragen V7-Text (mit Z8001-Aenderungen), acht weitere Funktionen sind leere Stumpfe (`csv; jp cret`, je 8 oder 12 Byte): es gibt keine Texttabelle.
  Die V7-Originale der acht stehen als Kommentar vor den Stumpfen.  Dateiaehnlichkeit 45 % -> 50 % (V7 und System III gleich: beide Dateien sind fuer diese Funktionen textgleich).
* Rundlauf: **10 von 10 bytegleich, wie vorher.**  `xfree` in V7-Form (fruehes `return` bei `p_textp == NULL`) ist bytegleich; Zwischenstufe mit dem vorzeichenlosen Makro `ctodu` in `xfree` war 1 von 71 Woertern abweichend -> `xfree` benutzt das vorzeichenbehaftete `ctod` wie V7, `xswap` weiter `ctodu`.
* `xswap`: berechnet die Auslagerungsgroesse aus der u-Struktur (Datengroesse und benutzter Stapel, Z8001-Segment) statt V7 `ctod(p_size)`; `swap(a, p_addr, 0x104, B_WRITE, up)` mit fuenf Argumenten (siehe `bio.md`).
* Namen: 579C `xstub1` und 57CC `xstub2` liegen dort, wo V7 `xexpand` und `xuntext` stuenden (*angenommen* nach der Funktionsreihenfolge); die Namen bleiben (Adressliste des Gesamtbaus).
* Hinweis zum Werkzeug: der Funktionsvergleich meldet fuer die leeren Stumpfe 100 % gegen irgendeine leere Funktion (Rauschen).
* Kein System-III-Zug.  Rueckfall: keiner.

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| xswap | 562C | veraendert (Z8001) | **gleich** |
| xfree | 5702 | veraendert (`ctod`-Gleichheit, sonst V7) | **gleich** |
| xalloc, xstub1 (xexpand), xlock, xunlock, xccdec, xumount, xrele, xstub2 (xuntext) | 5790..57CC | eigen (leer) | **gleich** |
