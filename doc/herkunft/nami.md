# Herkunft von `kernel/c/nami.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/nami.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  Dateiaehnlichkeit V7 84 % -> 92 %, System III PDP-11 61 % -> 67 %; `namei` 88 % -> 96 % gegen V7 (System III 64 % -> 70 %).
* Rundlauf: `namei` (36A0, 768 B) **bytegleich, vorher und nachher**.  Der V7-Text (`if((c=(*func)()) == '/')`, Marke `seloop` statt `cl2`, `for`-Schleife ueber `mount[]` mit gestuften `if`) uebersetzt unveraendert zu denselben Bytes.
* Abweichungen gegenueber V7 (alle markiert):
  1. Keine Multiplex-Dateien: die zwei `mpxip`-Tests (`c=='!'` in der Namensschleife und der `mpxip`-Rueckgabeblock) fehlen.
  2. `eo` ist `daddr_t` (V7 `off_t`), beides `long`.
  3. Kein `schar()` (V7 `schar`/`uchar`); `uchar` steht im Kernel bei 39BA und ist in `pipe.c`.
* Kein System-III-Zug erkennbar.  Rueckfall: keiner.

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| namei | 36A0 | veraendert (Punkte 1-3) | **gleich** (vorher gleich) |
