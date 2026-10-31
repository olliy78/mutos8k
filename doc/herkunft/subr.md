# Herkunft von `kernel/c/subr.c` (AP H3)

Stand 2026-10-31.  Quellen: UNIX V7 `usr/sys/sys/subr.c` (`bmap`, `passc`, `cpass`, `nodev`, `nulldev`, `bcopy`) und `usr/sys/sys/clock.c` (`timeout`, im Kernel hinter dem Taktgeber bei 2A4C).
Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  Dateiaehnlichkeit V7 74 % -> 82 %, System III PDP-11 56 % -> 64 %.  Alle sieben Funktionen tragen V7-Text und V7-Kommentare (`NADDR`, `NSHIFT`, `NMASK`, `NINDIR` statt der Zahlen 10, 7, 0177, 127).
* Rundlauf: **6 von 7 bytegleich, vorher 5 von 7.**  `bcopy` (243A) war als "nahe" (2 von 18 Woertern, DJNZ-Effekt) mit Empfehlung "Handassembler/gepatchte `.s`" (`c_rueckbau.md`, K7a) abgelegt;
  die V7-Form `bcopy(from, to, count) caddr_t from, to; register count; { register char *f, *t; ... do *t++ = *f++; while(--count); }` (Parameter `count` selbst als Registervariable)
  ist **bytegleich**.  Die damalige Annahme "anderer `c2`-Stand" war fuer `bcopy` falsch: es war die Quellform.
* `bmap` bleibt "nahe" (263 von 308 Woertern, **wie vorher**, 616 Byte gleiche Laenge): Muster (B) aus K7b (`c2` verwendet `nb`/`bn` nicht aus dem Register weiter).  Die V7-Form aendert daran nichts.
* **Z8001-Anpassungen:** `passc`/`cpass` ohne `suibyte`/`fuibyte` (V7 trennt Befehls- und Datenraum, MUTOS nicht); der V7-Text steht im Kommentar daneben.
  `timeout` vergleicht mit `&callout[NCALL]` statt V7 `&callout[NCALL-1]`: `NCALL` ist 9 (Tabelle CE58..CE8E, 6 Byte je Eintrag, gemessen); mit `NCALL-1` ergaebe sich ein anderer Immediatewert.

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| bmap | 20FE | 85 % -> 100 % | identisch | -- | nahe (263 von 308 Woertern, wie vorher) |
| passc | 236C | 89 % -> 89 % | veraendert | kein `suibyte` (kein I-Raum) | **gleich** |
| cpass | 23CA | 87 % -> 87 % | veraendert | kein `fuibyte` | **gleich** |
| nodev | 242A | 100 % -> 100 % | identisch | -- | **gleich** |
| nulldev | 2438 | 100 % -> 100 % | identisch | -- | **gleich** |
| bcopy | 243A | 100 % -> 100 % | identisch | -- | **gleich** (vorher nahe, 2/18) |
| timeout | 2A4C | 97 % -> 97 % | veraendert | `&callout[NCALL]` (V7: `NCALL-1`) | **gleich** |

* `passc`/`cpass` rufen `subyte` (0508) und `fubyte` (04CC); K6b nannte sie `suword`/`fuword`.
* Rueckfall: keiner.
