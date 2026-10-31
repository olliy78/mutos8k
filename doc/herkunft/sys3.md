# Herkunft von `kernel/c/sys3.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/sys3.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7): 7 Funktionen V7-Text, `exec` ist ein MUTOS-Stumpf (V7 `exec` steht in `sys1.c`; hier nur `u.u_ap[2] = 0; exece();`).  Dateiaehnlichkeit V7 88 % -> 97 %, System III PDP-11 52 % -> 55 %.
* Rundlauf: **8 von 8 bytegleich, vorher 8 von 8.**  Zwei Zwischenstufen: (1) `bread(dev, SUPERB)` (V7-Text) ergibt 67 von 161 abweichende Woerter in `smount`: `SUPERB` ist im Kernel ein `int` (siehe `header.md`),
  `bread` erwartet einen `long`; mit `bread(dev, (daddr_t)SUPERB)` bytegleich.  (2) Der `exec`-Stumpf fiel kurz aus der Pruefung, weil zwischen Marke und Funktion ein Kommentar stand (`vergleich.py` verlangt die Marke unmittelbar davor).
* `struct stat` und `struct dinode` stammen jetzt aus Headern (`stat.h` neu, V7-Text; `ino.h` vorhanden) statt aus lokalen Deklarationen.  Layout unveraendert (`copyout` mit `sizeof(ds)`, 22 Byte), Objektcode gleich.
* **Eigene Zuege gegenueber V7:**
  1. `smount`: nach fehlgeschlagenem `d_open` Sprung nach `out1` (V7: `out`, der Inode wird dann mit `EBUSY` ueberschrieben).  System III hat `goto out1` an derselben Stelle (`uts/pdp11/os/sys3.c`, gemessen mit `rg`) -- **SysIII-Zug**.
  2. `sumount`: der Test `if(ip->i_number != 0 && dev == ip->i_dev) { EBUSY; return }` (V7 und SysIII-PDP) ist ersetzt durch `if (dev == ip->i_dev) { if (ip->i_count) { EBUSY; return } ip->i_number = 0; }` -- Eintraege der Platte, die
     nicht benutzt sind, werden freigegeben.  Weder in V7 noch in SysIII (*Herkunft offen*, H6).
  3. `exec`: Stumpf, siehe oben.

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| fstat | 3D6A | 100 % -> 100 % | identisch | `(off_t)0` (Z8001: kein Prototyp) | **gleich** |
| stat | 3DA2 | 100 % -> 100 % | identisch | -- | **gleich** |
| stat1 | 3DDC | 100 % -> 100 % | identisch | -- | **gleich** |
| dup | 3EB2 | 74 % -> 100 % | identisch | -- | **gleich** |
| smount | 3F3C | 95 % -> 97 % | veraendert | `goto out1` (SysIII), `(daddr_t)SUPERB` | **gleich** |
| sumount | 4080 | 91 % -> 91 % | veraendert | Busy-Test mit `i_count`, `i_number = 0` (eigen) | **gleich** |
| getmdev | 413C | 100 % -> 100 % | identisch | -- | **gleich** |
| exec | 4198 | 29 % -> 29 % | eigen | Stumpf | **gleich** |

* Rueckfall: keiner.
