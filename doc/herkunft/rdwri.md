# Herkunft von `kernel/c/rdwri.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/rdwri.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  Dateiaehnlichkeit V7 85 % -> 96 %, System III PDP-11 38 % -> 37 %.
* Rundlauf: **3 von 4 bytegleich, vorher 2 von 4.**  Zugewinn: `iomove` (2780, 194 B).  Die V7-Form `(n&(NBPW-1)) == 0` mit `do ... while (--n)` (DJNZ-Schleife) in beiden Zweigen ist bytegleich;
  die bisherige Fassung `while (n--)` war 49 von 102 Woerter abweichend.  Probedatei mit sechs Kopien unter anderen Namen (ein Lauf): Literal `1` statt `NBPW-1` mit `do..while(--n)` 14/97 Woerter, Mischformen 28 bis 49;
  die Kopie mit `NBPW-1` und `do..while(--n)` lieferte in der Probedatei **196 B / 9 von 98 Woertern**, obwohl ihr Text mit dem Funktionsrumpf in `rdwri.c` uebereinstimmt, der dort 194 B und bytegleich uebersetzt.
  Ursache **ungeklaert** (*angenommen*: Einfluss der Nachbarfunktionen/Reihenfolge im Uebersetzungslauf); massgeblich ist das Ergebnis der echten Datei (zwei Laeufe, beide gleich).
  *Befund entgegen K7a*: der DJNZ-Effekt war keine `c2`-Abweichung, sondern die Quellform (wie bei `bcopy`, siehe `subr.md`).
* `readi` (2460) bleibt "nahe": **108 von 206 Woertern, wie vorher**, auch mit V7-Text (`return((*cdevsw[..].d_read)(dev))`, `(long)bn<0`).  Drei Probevarianten (V7 mit/ohne `(long)`, mit getrenntem Aufruf und `return;`)
  ergaben dieselben 108 Woerter -> die Abweichung liegt nicht in diesen Stellen; Muster (E) aus `c_rueckbau.md` (ueberzaehliges `testl` hinter `subl`) bleibt die *angenommene* Ursache.  Die Quelle ist jetzt V7-Text (Aehnlichkeit `readi` 91 % -> 100 %).
* `writei`, `min` bytegleich wie vorher; V7 `max` ist nicht im Kernel (kein Aufrufer).
* Abweichungen gegenueber V7: Z8001 ohne getrennten Befehlsraum: `iomove` ruft immer `copyin`/`copyout` (V7 waehlt `copyiin`/`copyiout` bei `u_segflg==2`); `NBPW` ist in `param.h` nicht definiert und steht lokal als `sizeof(int)`.
* Kein System-III-Zug.  Rueckfall: keiner.

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| readi | 2460 | identisch | nahe (108/206, wie vorher) |
| writei | 25FE | identisch | **gleich** |
| min | 2766 | identisch | **gleich** |
| iomove | 2780 | veraendert (kein copyiin) | **gleich** (vorher nahe, 49/102) |
