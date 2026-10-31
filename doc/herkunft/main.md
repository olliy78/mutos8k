# Herkunft von `kernel/c/main.c` (AP H3)

Stand 2026-10-31.  Quellen: UNIX V7 `usr/sys/sys/main.c` (`main`, `iinit`) und `usr/sys/dev/bio.c` (`binit`; V7 hat `binit` in `bio.c`, hier bleibt es nach der Kernelreihenfolge bei 07D2).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  Dateiaehnlichkeit V7 83 % -> 88 %, System III PDP-11 44 % -> 45 %; `main` 83 % -> 88 %.
* Rundlauf: **2 von 3 bytegleich, wie vorher.**  `binit` (07D2) weicht **1 von 84 Woertern** ab (wie vorher): im Objekt liegt `b_error` bei +15 statt +14 (siehe `c_rueckbau.md`, K7c); die V7-Form aendert daran nichts.
* Abweichungen gegenueber V7 (markiert): `proc[0].p_addr = 0`, `p_size = 0` (V7 `ka6->r[0]`, `USIZE`); `kstub()` an Stelle von `clkstart()` und ein zusaetzliches `spl0()`
  (Zweck *angenommen*: Interrupts freigeben); `SUPERB` braucht `(daddr_t)` (gemessen in `param.h`); `binit` setzt zusaetzlich `b_error = 0` und hat einen `devtab`-Zeiger; `buffers` ist nur `extern`.
  `btoc` (256-Byte-Click), `USIZE 4` und `RO 2` stehen lokal (nicht in `param.h`).
* Kein System-III-Zug.  Rueckfall: keiner.

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| main | 0674 | veraendert | **gleich** |
| iinit | 0746 | identisch | **gleich** |
| binit | 07D2 | veraendert (`b_error`) | nahe (1/84, wie vorher) |
