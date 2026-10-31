# Herkunft von `kernel/c/sys2.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/sys2.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7), 11 von 11 Funktionen mit V7-Text und -Kommentaren.  Dateiaehnlichkeit V7 91 % -> 96 %, System III PDP-11 63 % -> 62 % (dort `copen(mode, arg)`, FIFOs).
* Rundlauf: **11 von 11 bytegleich, vorher 10 von 11**.  `rdwr` (vorher 72 von 113 Woertern abweichend, "Kernel prueft `FPIPE` mit AND, hier BITB", K7c) ist mit der V7-Form
  `if((fp->f_flag&FPIPE) != 0)`, `if (fp->f_flag&FMP)` und `(ip->i_mode&(IFCHR&IFBLK)) == 0` bytegleich.  Welche der drei Schreibweisen es entscheidet, wurde **nicht** einzeln ermittelt.
* **Eigener Zug in `seek`:** nach der Basisauswertung `if(uap->off < 0) { u.u_error = EINVAL; uap->off = 0; }`.  V7 hat das nicht; System III hat `if (uap->off < 0) { u.u_error = EINVAL; return; }` (ohne `off = 0`,
  ohne Zuweisung von `f_offset`).  Die MUTOS-Fassung ist also weder V7 noch SysIII; Zug ist am Objektcode gemessen (126 Byte, gleich).  Herkunft *offen* (H6).
* Name: `open1` heisst im Kernel-Namensverzeichnis `copen` (`doc/kernel/kernel_namen.md`, `gesamtbau_adressen.txt`); Signatur und Aufrufe sind die von V7 `open1`.  Der Name bleibt `copen` (Kommentar im Text).

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| read | 51B2 | 100 % -> 100 % | identisch | -- | **gleich** |
| write | 51C4 | 100 % -> 100 % | identisch | -- | **gleich** |
| rdwr | 51D6 | 86 % -> 100 % | identisch | -- | **gleich** (vorher nahe, 72/113) |
| open | 52BE | 64 % -> 85 % | identisch | Name `copen` fuer `open1` | **gleich** |
| creat | 52F2 | 84 % -> 84 % | identisch | Name `copen` | **gleich** |
| copen | 5344 | 100 % -> 100 % | identisch | V7-Name `open1` | **gleich** |
| close | 53FE | 100 % -> 100 % | identisch | -- | **gleich** |
| seek | 542C | 77 % -> 85 % | veraendert | `off < 0`-Pruefung (eigen) | **gleich** |
| link | 54AA | 100 % -> 100 % | identisch | -- | **gleich** |
| mknod | 5556 | 100 % -> 100 % | identisch | -- | **gleich** |
| saccess | 55AE | 100 % -> 100 % | identisch | -- | **gleich** |

* Rueckfall: keiner.  `saccess` steht im Kernel direkt vor `xswap` (55AE), gehoert aber nach V7 zu `sys2.c`.
