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


## Nachzug H6d (2026-11-03): Text der Hippe-Sammlung

Vorlage: `original/hippe-v7/usr/sys/sys/sys1.c` der TUHS-Sammlung (Standardkonfiguration `conf/m.h`: `PROC_MAX`, `EXIT`, `LRUI` an; Schalterauflösung `tools/herkunft/ifdef_resolve.py`; "Hippe-Sammlung" = Name der Sammlung, nicht des Urhebers).
`exit` (eine Schleife, `wakeup(&proc[1])` einmal), `wait` (`while((--max_proc)->p_stat == NULL)`), `fork` (`if(p2 > max_proc)`), `rexit` (`struct a { int rval; }`) und `exece` (Zugriffstest mit `iput(ip); return;`, `ns`, `getxfile(ip, nc, ns)`, `NBPW`, `BMASK`, `NCARGS`, `(NCARGS+BSIZE-1)/BSIZE`, `struct execa`, `B_AGE`-Schleife wie die Vorlage) im Vorlagentext; `proctop` heisst `max_proc` (`MAX_PROC`).  Z8001-Abweichungen bleiben: `u_ar0[8]`, `fork`-Groesse, Kopfformate in `getxfile`, `setregs`.
Rundlauf (Gast `cc -O -c`, je Funktion gegen `mutos_1216`) nach der Änderung: `exit`, `wait`, `fork`, `rexit`, `setregs`, `sbreak` bytegleich (wie vorher); `exece` 1 von 389 Woertern (wie vorher, jetzt auch mit der Vorlagenform `iput; return`), `getxfile` 177 von 401 (Z8001-Kopfformate, unveraendert).

## Nachtrag 2026-11-05 (Plan 43): getxfile bytegleich

`getxfile` ist bytegleich (sys1 7 von 8, nur `exece` weicht ab: `c2`-Eigenheit `cp r3`, Plan 43 §8).  Aenderungen gegen den alten Stand, alle durch die Bytegleichheit belegt:

* Die beiden `ETXTBSY`-Pruefungen stehen beide im Zweig des grossen Kopfes (`u_ex[0] & 0x100`); der Kernel testet Bit 8 nur einmal.  Fuer den kleinen Kopf gibt es keine Pruefung.  `u_ex[1]` und `u_ex[14]` werden vorher geloescht, die Pruefungen greifen also nie (*aus dem Text geschlossen*).
* Bei einem `estabur`-Fehler `goto bad` (wie V7) statt `return(1)`: die fruehere Annahme "Rueckgabe 1" war falsch.  `estabur` scheitert nur bei mehr als 256 Klicks.
* `psignal(.., SIGTRC)` als `else`-Zweig hinter der SUID/SGID-Behandlung (`if ((p_flag & STRC) == 0) {..} else psignal(..)`), gleiche Wirkung.
* Im Overlay-Zweig `ctos(x)` = `((x)+255)/256` (vorzeichenlose Division, `LD Rn,#-8 ; SDL`) statt `btoc`.
