# Herkunft von `kernel/c/iget.c` (AP H3, Pilot)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/iget.c`.  Rundlauf wie in `rundlauf.md`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7), 8 von 8 Funktionen mit V7-Text.  File-Aehnlichkeit (abs) V7 89 % -> 94 %; System III PDP-11 65 %.
* **Eigene MUTOS-Aenderungen gegenueber V7** (alle am Objektcode belegt, da der V7-Text mit genau diesen Zeilen bytegleich uebersetzt):
  1. **Freigabe-LRU statt "erster freier Eintrag":** `iget` waehlt unter den freien Eintraegen den mit dem kleinsten `i_lastr` (`oip == NULL || oip->i_lastr > ip->i_lastr`),
     setzt beim ersten Referenzieren `i_lastr = 0` (`if(ip->i_count++ == 0)`), `iput` setzt `i_lastr = time` und laesst `i_number` stehen (V7: `i_number = 0`).
     In V7 ist `i_lastr` das Lese-Vorauslese-Feld (`i_un.i_lastr`, ueberlagert `i_addr`); in MUTOS ist es ein eigenes Feld bei +46 (`kernel/h/inode.h`).
     Diese Aenderung steht weder in V7 noch in System III pdp11 (`iget.c`: `if(oip==NULL && ip->i_count==0)`) -- *eigen*, Quelle unbekannt (vgl. 2BSD-`iget`: *angenommen*, nicht geprueft).
  2. **Blockadressen von Hand (Z8001, big endian, `daddr_t` = long):** `iexpand` schreibt das Nullbyte zuerst (`*p1++ = 0; *p1++ = *p2++ ...`), V7 an zweiter Stelle (PDP-11-Wortordnung);
     `iupdat` prueft entsprechend das **erste** Byte (`"iaddress > 2^24"`), V7 das zweite.
  3. Flache Header: `ip->i_addr[]` statt `ip->i_un.i_addr[]`, `(struct dinode *)bp->b_addr` statt `bp->b_un.b_dino`, `(daddr_t *)bp->b_addr` statt `b_un.b_daddr`.
* Verbessert gegenueber der dekompilierten Fassung (Basislauf): `iupdat` ist jetzt **bytegleich**.  Die alte Fassung hatte den Frueh-Rueckkehr-Stil
  (`if ((flag) == 0) return;` statt V7 `if(flag != 0) { ... }`) und wich in 160 von 192 Woertern ab; K7b (`c_rueckbau.md`, Muster (A)) fuehrte das auf den aelteren `c2` zurueck.
  **Das war falsch (Befund):** mit dem V7-Quelltext (verschachtelter Block, `if(getfs(...)->s_ronly)` ohne `!= 0`) ist die Funktion bytegleich.  Welche der beiden Formen (Block oder `s_ronly` ohne Vergleich) den Unterschied macht, wurde nicht einzeln isoliert.  Die Annahme "alle Abweichungen sind `c2`" gilt nicht fuer Muster (A).

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung | Rundlauf |
|---|---|---|---|---|---|
| iget | 1122 | 88 % -> 88 % | veraendert | LRU (`i_lastr`), flaches `b_addr` | **gleich** |
| iexpand | 126A | 97 % -> 97 % | veraendert | Nullbyte zuerst (Z8001) | **gleich** |
| iput | 12FE | 91 % -> 91 % | veraendert | `i_lastr = time` statt `i_number = 0` | **gleich** |
| iupdat | 1372 | 81 % -> 92 % | veraendert | Nullbyte-Pruefung zuerst (Z8001), flaches `b_addr`/`i_addr`; Konstanten `IFMPC`/`IFMPB` (V7-Namen, neu in `inode.h`) statt `0030000`/`0070000` | **gleich** (vorher: nahe, 160/192) |
| itrunc | 14F6 | 89 % -> 89 % | identisch | flaches `i_addr` | nahe (61 von 93, wie vorher) |
| tloop | 15B2 | 95 % -> 95 % | identisch | flaches `b_addr` | nahe (42 von 79, wie vorher) |
| maknode | 1652 | 94 % -> 100 % | identisch | -- (`u.u_cmask` statt Makro `U_CMASK` aus `user_ext.h`: gleicher Code) | **gleich** |
| wdir | 16C2 | 87 % -> 100 % | identisch | -- (V7-Form mit `goto out`) | **gleich** |

## Rundlauf-Ergebnisse und Rueckfall

* 6 von 8 bytegleich (Basis 5 von 8).  `itrunc`/`tloop`: Objektcode **unveraendert** gegenueber der alten Fassung (gleiche Zahl abweichender Woerter); K7b-Muster (B) (*angenommen*).
* **Kein Rueckfall noetig.**  Die V7-Formen von `wdir` (`goto out`) und `maknode` (`u.u_cmask`) uebersetzen identisch zur alten Fassung.
* Der Header `iget.c` bindet weiter `user_ext.h` ein (nicht mehr noetig fuer `maknode`; Aufraeumen -> H4).

## Offene Punkte

* Herkunft der LRU-Aenderung (eigene Idee, BSD, Xenix?) -- Plan H6.
* `i_lastr` als eigenes Feld ist eine Struktur-Abweichung (kein `i_un`), die `inode.h` nicht V7-gleich macht -- H4.
