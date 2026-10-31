# Herkunft von `kernel/c/rk.c` (AP H5)

Stand 2026-10-31.  Quellen: UNIX V7 `usr/sys/dev/sys.c`, `mem.c`, `rk.c`.  Alle Zahlen **gemessen** (Ebene abs), sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  Dateiaehnlichkeit V7 `sys.c` 51 % (ref-in-mut 90 %), `mem.c` 25 %; System III `rk.c` 19 %; WEGA `sys.c` 50 % (= V7-Text), sonst unter 12 %.
* `syopen`, `syread`, `sywrite`, `syioctl` (V7 `sysioctl`): **V7-Text** (jetzt ohne `dev_t`-Deklarationen, `NULL`, `caddr_t addr`), bytegleich.  Der Name `syioctl` bleibt (Adressliste des Gesamtbaus).
  System III `sys.c` liegt bei 28..51 % (V7 naeher); kein SysIII-Zug.
* `mmread`, `mmwrite`: V7 `mem.c`-Gerippe (Minor 0/1/2, `passc`/`cpass`-Schleife, `spl7`...`spl0`, `ENXIO`), aber der Zugriff geht ueber das Segmentwahlwort `usrseg` statt UISA/UISD (Z8001) -> **veraendert**;
  der V7-Zugriffstext steht als Kommentar vor `mmread`.
* `rkstrategy`, `rkintr`, `rkread`, `rkwrite`: V7 `rk.c`-Gerippe (Warteschlange `b_actf/b_actl`, `spl5`, `deverror`, Wiederholungen, `iodone`, `physio`); `rkread`/`rkwrite` sind textgleich (100 %).
  `rkstrategy` (42 %) und `rkintr` (24 %) sind **veraendert**: Mailbox-Status statt RK11-Register, 3 statt 10 Wiederholungen, Blockgrenze 0x260 statt 4872.
* `rkopen`, `rkclose`, `rkstart`: **eigen** (kein V7-Gegenstueck; `rkstart` fuellt die Mailbox D532 und uebergibt mit `mapalloc(mp, 0)`).
* Rundlauf: **13 von 13 bytegleich, wie vorher.**  Der V7-Text der `sy*`-Funktionen blieb bytegleich.

| Funktion | Kernel | V7 abs | Klasse | Rundlauf |
|---|---|---|---|---|
| mmread | 69CE | 45 % | veraendert (Z8001-Segmentwahl) | gleich |
| mmwrite | 6A52 | 41 % | veraendert | gleich |
| rkopen | 6ADA | -- | eigen | gleich |
| rkclose | 6AFE | -- | eigen (leer) | gleich |
| rkstrategy | 6B06 | 42 % | veraendert | gleich |
| rkstart | 6B60 | 15 % | eigen | gleich |
| rkintr | 6BCA | 24 % | veraendert | gleich |
| rkread, rkwrite | 6C52, 6C70 | 100 % | identisch | gleich |
| syopen | 6C8E | 79 % -> V7-Text | identisch | gleich |
| syread, sywrite | 6CC6, 6CEC | 100 % | identisch | gleich |
| syioctl | 6D12 | 100 % | identisch (V7 `sysioctl`) | gleich |

*Angenommen:* die Mailbox-Treiber (`rk*`) sind MUTOS-Eigenbau fuer die Z8001/U880-Aufteilung; es gibt keinen Beleg fuer eine andere Quelle.
