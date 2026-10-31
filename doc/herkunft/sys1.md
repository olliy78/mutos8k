# Herkunft von `kernel/c/sys1.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/sys1.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  Aufbau und Kommentare aller acht Funktionen folgen V7 (V7-Kommentare eingefuegt, jede abweichende Zeile mit `/* MUTOS: ... */`), der Code ist aber **nicht** V7-Text: Dateiaehnlichkeit V7 65 % -> 65 % (nur Kommentare dazu, Tokenvergleich ignoriert sie), System III 49 %.
  Der V7-Text konnte nicht unveraendert eingesetzt werden, weil Kopfformat, Argumentrahmen und Speicheraufbau der Z8001 andere Anweisungen verlangen -- das ist eine Annahme aus dem Textvergleich, kein Rundlauf der Reinform (der Mittelweg verlangt sie, hier ist der Aufwand ein Neuentwurf der Funktion, kein Formproblem).
  `sbreak` (23 % gegen V7) ist praktisch eigen.
* Rundlauf: **6 von 8 bytegleich, wie vorher.**  Offen wie vorher: `exece` (1 von 389 Woertern), `getxfile` (177 von 401; zwei Kopfformate, `c_rueckbau.md`).  Der Objekttext hat sich nicht veraendert (778 B / 802 B).
* **Eigene Zuege gegenueber V7** (alle am Objektcode gemessen):
  1. Ausfuehrbarer Kopf: Magic E807 (16 Byte) / E707 (40 Byte, Bit 8), Feld `u_ex[]` statt `u_exdata`; kein 410/411/405 (keine geteilten oder ueberlagerten Programme: `overlay` und `sep` bleiben 0).
  2. Argumente in 10 Swapbloecken (`malloc(swapmap, 10)`, V7 `(NCARGS+BSIZE-1)/BSIZE`), Grenze `nc >= 0x13FF`, `bdwrite` statt `bawrite`, Rahmen am Ende des 64-KB-Segments (`ucp = -nc - 2`), Aufruf `getxfile(ip, nc, ta)` mit drittem Argument; bei Fehler werden die 10 Argumentbloecke im Cache ungueltig gemacht (`B_AGE`, `getblk`) -- nicht in V7, nicht in System III (*Fremdzug fuer H6*).
  3. `getxfile`: kein `expand`, das ganze Segment (256 Clicks) wird geloescht; kein `SIGTRC`-Weg ausser `SIGTRAP`; Rueckgabe 1 bei `estabur`-Fehler.
  4. `setregs`: 8 Registerindizes, `u_r.r_val1/2 = 0`, Gleitkomma-Bereich `u_fparea`; Name `u_exname -> u_dbuf` (V7 `u_dbuf -> u_comm`, Richtung umgekehrt; *angenommen*: der Name steht hier schon in `u_exname`).
  5. `exit`: kein `acct()`; **eine** Schleife ueber `proc[0]..proctop` mit Zaehler `i` der Zombie-Kinder und einem `wakeup(&proc[1])`; Eltern geweckt in der Schleife, dann `swtch()` -- V7 hat zwei Schleifen mit Weckruf je Kind.  Weder V7 noch System III (SysIII: `resume`, `SIGCLD`, `p_pgrp`) -> *Fremdzug fuer H6*.
  6. `wait`: Tabellenende `proctop` wird nach Freigabe des letzten Eintrags zurueckgesetzt (MUTOS-eigene variable Prozesstabellengroesse, vgl. `slp.md`).
  7. `fork`: Swapbedarf aus der tatsaechlichen Bildgroesse (`ctod2(u_dsize) + 2 + ...`) statt `ctod(MAXMEM)`; `proctop` wird nachgezogen; kein `u_acflag`; `u_ar0[12] += 2` (PC) statt `u_ar0[R7] += NBPW`.
  8. `sbreak`: nur Groesse eintragen und neue Clicks loeschen (kein `estabur`, `expand`, `copyseg`).
* System III: kein Textzug.

| Funktion | Kernel | V7-Aehnlichkeit | Klasse | Rundlauf |
|---|---|---|---|---|
| exece | 41AC | 65 % | veraendert (Punkte 1, 2) | nahe (1/389, wie vorher) |
| getxfile | 44B6 | 55 % | veraendert (Punkt 3) | nahe (177/401, wie vorher) |
| setregs | 47E2 | 61 % | veraendert (4) | **gleich** |
| rexit | 48A6 | 46 % | veraendert | **gleich** |
| exit | 48C4 | 80 % | veraendert (5) | **gleich** |
| wait | 49F6 | 83 % | veraendert (6) | **gleich** |
| fork | 4AD4 | 78 % | veraendert (7) | **gleich** |
| sbreak | 4BD0 | 23 % | eigen (8) | **gleich** |

Rueckfall: keiner (der bytegleiche Code blieb unveraendert, es kamen nur Kommentare dazu).  `exec` (4198, 15 Byte) liegt in `sys3.c`.
