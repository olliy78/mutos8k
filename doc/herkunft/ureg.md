# Herkunft von `kernel/c/ureg.c` (AP H5)

Stand 2026-10-31.  Quellen: UNIX V7 `usr/sys/sys/prim.c` (`cinit`) und `usr/sys/sys/ureg.c` (`sureg`, `estabur`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  `cinit` ist V7-Text (aus `prim.c`, nicht aus `ureg.c`), `sureg` ein leerer Stumpf, `estabur` eine reine Groessenpruefung (Z8001 ohne PDP-11-Segmentregister).
  Dateiaehnlichkeit: V7 `prim.c` 34 %, System III `ureg.c` 8 %.
* `cinit` in V7-Form (`register int ccp`, Makros `CROUND`, `CBSIZE`, `NCLIST`): **bytegleich**.  MUTOS-Konstanten: `NCLIST` 50 (V7 100), `c_info[14]` (V7 6), `CROUND` 017 (V7 07).
  Vorher 85 % gegen V7, jetzt textgleich bis auf diese Konstanten.
* `sureg` und `estabur`: das V7-Original von `sureg` steht als Kommentar vor dem Stumpf; von `estabur` steht nur der Fehlerausgang als Kommentar (V7-Text ~90 Zeilen PDP-11-Register, wuerde nur Platz kosten).
  Die Werkzeugwerte 100 % (`sureg`) und 55 % (`estabur`) sind Rauschen (leere/kurze Funktion).
* Rundlauf: **2 von 3 bytegleich, wie vorher** (`cinit`, `sureg` gleich; `estabur` 8 von 20 Woertern: LDK-Form fuer `ENOMEM`, `c_rueckbau.md` K7c).
* System III hat in `ureg.c` zusaetzlich `checkur`; kein SysIII-Zug in MUTOS.

| Funktion | Kernel | V7 abs | Klasse | Rundlauf |
|---|---|---|---|---|
| cinit | 3D04 | 85 % -> V7-Text | identisch (Konstanten MUTOS) | gleich |
| sureg | 3D40 | -- | eigen (leer) | gleich |
| estabur | 3D42 | -- | eigen (Z8001) | nahe (8/20) |
