# Herkunft von `kernel/c/ureg.c` (AP H5)

Stand 2026-10-31.  Quellen: UNIX V7 `usr/sys/sys/prim.c` (`cinit`) und `usr/sys/sys/ureg.c` (`sureg`, `estabur`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  `cinit` ist V7-Text (aus `prim.c`, nicht aus `ureg.c`), `sureg` ein leerer Stumpf, `estabur` eine reine Groessenpruefung (Z8001 ohne PDP-11-Segmentregister).
  Dateiaehnlichkeit: V7 `prim.c` 34 %, System III `ureg.c` 8 %.
* `cinit` in V7-Form (`register int ccp`, Makros `CROUND`, `CBSIZE`, `NCLIST`): **bytegleich**.  MUTOS-Konstanten: `NCLIST` 50 (V7 100), `c_info[14]` (V7 6), `CROUND` 017 (V7 07).
  Vorher 85 % gegen V7, jetzt textgleich bis auf diese Konstanten.
* `sureg` und `estabur`: das V7-Original von `sureg` steht als Kommentar vor dem Stumpf; von `estabur` steht nur der Fehlerausgang als Kommentar (V7-Text ~90 Zeilen PDP-11-Register, wuerde nur Platz kosten).
  Die Werkzeugwerte 100 % (`sureg`) und 55 % (`estabur`) sind Rauschen (leere/kurze Funktion).
* Rundlauf: **3 von 3 bytegleich (2026-11-04)**.  `estabur` war 8 von 20 Woertern; zwei Quellformen waren noetig (gemessen, Probe Plan 43 Gruppe A, 7+10 Varianten):
  (1) Blockanordnung: `if (nt + nd + ns <= 256) return(0);` zuerst, dann der Fehlerzweig (die Form `if (> 256) { ...; return(-1); } return(0);` legt den Fehlerzweig vor `xor r2,r2`);
  (2) `LDK`-Form: nur ein *verwendeter* Zuweisungswert laedt die Konstante nach r2 (`ldk r2,#12 ; ldb u_error,rl2`), also `u.u_error = u.u_error = ENOMEM;`.  Die einfache Zuweisung gibt `ldb u_error,#12` (so im ganzen uebrigen Kernel).
  Die Doppelzuweisung ist die einzige gefundene Form, kein Beleg fuer den Originaltext; sie ist im Quelltext kommentiert.
* System III hat in `ureg.c` zusaetzlich `checkur`; kein SysIII-Zug in MUTOS.

| Funktion | Kernel | V7 abs | Klasse | Rundlauf |
|---|---|---|---|---|
| cinit | 3D04 | 85 % -> V7-Text | identisch (Konstanten MUTOS) | gleich |
| sureg | 3D40 | -- | eigen (leer) | gleich |
| estabur | 3D42 | -- | eigen (Z8001) | gleich (2026-11-04) |
