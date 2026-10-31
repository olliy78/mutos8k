# Herkunft von `kernel/c/prf.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/prf.c`; Vergleich mit `tools/herkunft/herkunft.py compare`; Rundlauf mit `tools/herkunft/rundlauf.sh` (siehe `rundlauf.md`).
Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7), alle 5 Funktionen mit V7-Text und V7-Kommentaren.  Die Datei war vorher schon textgleich zu V7 (100 %); geaendert wurden nur Dateikopf, Kommentare (Deutsch -> V7-Englisch)
  und die Deklaration `register long a;` in `printn` (V7; die alte Fassung hatte `long a;`) -- der Gast-`cc` uebersetzt beides identisch.
* System III PDP-11 `prf.c`: 62 % (nur `printf` und `panic` stehen dort textgleich; `printn` 14 %, `deverr` statt `deverror` 50 %).  Kein SysIII-Zug.
* Rundlauf: **5 von 5 bytegleich, vorher 5 von 5**.

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| printf | 1724 | 100 % -> 100 % | identisch | -- | **gleich** |
| printn | 17E0 | 100 % -> 100 % | identisch | -- (`register long a` wie V7) | **gleich** |
| panic | 1856 | 100 % -> 100 % | identisch | -- | **gleich** |
| prdev | 187A | 100 % -> 100 % | identisch | -- | **gleich** |
| deverror | 18A4 | 100 % -> 100 % | identisch | -- | **gleich** |

* Include-Liste: V7 bindet `seg.h` und `conf.h` ein, MUTOS nicht (`seg.h` gibt es nicht; `conf.h` wird nicht gebraucht) -- ohne Wirkung auf den Objektcode.
* Rueckfall: keiner.
