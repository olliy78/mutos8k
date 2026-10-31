# Herkunft von `kernel/c/machdep.c` (AP H5)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/machdep.c` (nur Gerippe).  Alle Zahlen **gemessen** (Ebene abs), sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial** (schwach).  Dateiaehnlichkeit V7 20 %, System III 23 %, WEGA unter 10 %.
* `startup` (23 %): V7-Gedanke "gesamten Kernspeicher durchtasten, nullen und freigeben, `mem = %D` ausgeben", aber Z8001-Segmentwahl ueber `usegm`, kein UNIBUS-Abbild, keine `MAXMEM`-Kappung der V7-Art -> **eigen**.
* `sendsig` (55 % gegen V7 `sendsig`): gleiches Muster (Rahmen auf den Nutzerstapel schieben, `grow`, `suword`, Stapelzeiger und PC setzen), aber vier Worte statt zwei und kein `TBIT` -> **veraendert** (Z8001).
  V7-Text als Kommentar daneben.
* `sigret` (14 %) und `kstub` (leer): kein V7-Gegenstueck (PDP-11 kehrt mit `rti` zurueck).  `kstub` liegt zwischen `startup` und `sendsig` (*angenommen*: Rest einer entfernten Funktion, z. B. V7 `mapalloc`-Platz).
* Rundlauf: **3 von 4 bytegleich, wie vorher**; `startup` 45 von 90 Woertern (Konstante `0xFCFF`, `c_rueckbau.md` K7c).  Nur Kommentare geaendert.

| Funktion | Kernel | V7 abs | Klasse | Rundlauf |
|---|---|---|---|---|
| startup | 34F6 | 23 % | eigen (V7-Gedanke) | nahe (45/90) |
| kstub | 35AC | -- | eigen (leer) | gleich |
| sendsig | 35AE | 55 % | veraendert | gleich |
| sigret | 3630 | 14 % | eigen | gleich |

Handassembler (`mch.s`: `csv/cret`, `savu/resume`, `spl*`, `fuword/...`, `copyin/copyout`, Trap-Eintritt) ist nicht Teil der C-Quellen.
Bei V7 liegen `mapalloc` (UNIBUS) und `dump` ebenfalls in `machdep.c`; MUTOS hat `mapalloc` in `bio.c` (eigener Mailbox-Zugriff).
