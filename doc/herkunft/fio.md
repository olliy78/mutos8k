# Herkunft von `kernel/c/fio.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/fio.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7), alle 8 Funktionen mit V7-Text und V7-Kommentaren.  Dateiaehnlichkeit V7 90 % -> 99 %, System III PDP-11 65 % -> 69 %.
* `closef` und `openi` enthalten die V7-**Multiplexer-Reste** (`IFMPC`/`IFMPB`, `FMP`, `struct chan *cp = fp->f_un.f_chan`), die System III nicht mehr hat (dort `IFIFO`, `closep`).
  Die alte Fassung schrieb dafuer die Zahlen `0030000`, `0070000`, `030`; jetzt stehen die V7-Namen, ohne Wirkung auf den Objektcode.
* Rundlauf: **8 von 8 bytegleich, vorher 8 von 8**.  `getf` jetzt mit V7-Form `if(0 <= f && f < NOFILE)` statt `f >= 0 && f < 20`.

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| getf | 2AD4 | 33 % -> 100 % | identisch | -- | **gleich** |
| closef | 2B06 | 89 % -> 100 % | identisch | -- | **gleich** |
| openi | 2C0C | 89 % -> 100 % | identisch | -- | **gleich** |
| access | 2C8C | 100 % -> 100 % | identisch | -- | **gleich** |
| owner | 2D0A | 100 % -> 100 % | identisch | -- | **gleich** |
| suser | 2D48 | 46 % -> 79 % | veraendert | ohne `u.u_acflag \|= ASU` (kein `acct`) | **gleich** |
| ufalloc | 2D62 | 100 % -> 100 % | identisch | -- | **gleich** |
| falloc | 2D9A | 89 % -> 100 % | identisch | -- | **gleich** |

* Include-Liste: ohne `reg.h` und `acct.h` (V7); es gibt keine Abrechnung.  `acct` steht in beiden Referenzbaeumen, `sysacct` fehlt in `sysent` (Slot 51 leer, siehe `uebersicht.md`).
* Rueckfall: keiner.
