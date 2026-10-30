# Herkunft von `kernel/c/sig.c` (AP H3, Pilot)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/sig.c`.  Rundlauf wie in `rundlauf.md`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  9 von 10 Funktionen tragen V7-Text (mit markierten MUTOS-Zeilen), `grow` ist ein leerer Stumpf (*eigen*).
  File-Aehnlichkeit (abs) V7 77 % -> 82 %, System III PDP-11 70 %.  Die Struktur `ipc`, `IPCPRI`, die Signalnamen und `core`-Logik sind V7.
* **Alle 10 Funktionen bytegleich** (Basis: 8 von 10).  `core` (2 Woerter) und `procxmt` (67 von 257) waren vorher "nahe".
* Die Namen `SIGILL`/`SIGTRAP`/`SIGFPE` in `kernel/h/param.h` sind BSD-/SysIII-Namen; der Text benutzt jetzt die V7-Namen `SIGINS`/`SIGTRC`/`SIGFPT`
  (gleiche Werte 4/5/8, als Alias in `param.h` ergaenzt).  Welche Namen das Original benutzte, ist am Binaerabbild **nicht messbar** (Makros) -- die V7-Namen sind die
  einfachere Annahme, weil der Rest V7 ist.  `trap.c`/`sys1.c` benutzen weiter `SIGILL`/`SIGTRAP`.
* **Eigene MUTOS-Aenderungen gegenueber V7:**
  1. `proctop` statt `&proc[NPROC]` (`signal`, `stop`, `ptrace`).
  2. `ipc.ip_addr` ist `int` (V7 `int *`): Benutzeradressen sind 16 Bit, daher auch `u.u_ar0[12] = ipc.ip_addr` ohne Cast.
  3. `ptrace`: Argumentreihenfolge `req, pid, addr, data` (V7 und System III: `data, pid, addr, req`) -- *gemessen* an den Offsets, Grund unbekannt (Z8001-Aufrufkonvention?).
  4. `core`: `u.u_count = 0x400` (V7 `ctob(USIZE)`), Datenlaenge `u.u_dsize << 8` und Stapelsegment ab `u_ar0[8] & 0xFF00` bis Segmentende (V7: `p_size - USIZE`, `estabur`); `namei(uchar, 1)` (V7 `schar` -- gibt es im Kern nicht).
  5. `procxmt`: Anforderungen 1 und 2 gleich (kein getrenntes I/D-Raum: `fubyte`/`fuword` fuer beide); Fall 4 `suword` statt `suiword`, `estabur(..., 6)`/`(..., 2)` (V7 `RW`/`RO`); Fall 6: 16 Register ueber `regloc[]`, Statuswort `u_ar0[10]` mit `&= ~0x4800`, `|= 0x1000` (V7 8 Register, `RPS`: `|= 0170000`, `&= ~0340`); Fall 9: `u_ar0[10] |= 0x800` (V7 `RPS |= TBIT`); Fall 7: `u_ar0[12]` (V7 `PC`).  Der Gleitkomma-Bereich in Fall 6 (`u_fparea`, 0x90 Byte) entspricht V7 `u_fps`..`u_fpregs[6]`.
  6. `psig`: `savfp(u.u_fparea)` statt `savfp(&u.u_fps)`.
  7. `grow`: V7 hat einen Rumpf (`estabur`, `expand`, `copyseg`, `clearseg`); der Kernel hat 10 Byte (`csv; xor r2,r2; jp cret`).

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung | Rundlauf |
|---|---|---|---|---|---|
| signal | 0B3A | 81 % -> 81 % | veraendert | 1. | **gleich** |
| psignal | 0B6E | 100 % -> 100 % | identisch | V7-Form `register sig` + `(unsigned)`-Cast; Basis hatte `register unsigned sig` (gleicher Code) | **gleich** |
| issig | 0BC8 | 100 % -> 100 % | identisch | -- | **gleich** |
| stop | 0C18 | 92 % -> 92 % | veraendert | 1. | **gleich** |
| psig | 0C7C | 83 % -> 96 % | identisch | 6. (V7-Namen der Signale, `(caddr_t)`-Cast) | **gleich** |
| fsig | 0D2C | 100 % -> 100 % | identisch | -- | **gleich** |
| core | 0D56 | 71 % -> 77 % | veraendert | 4. | **gleich** (vorher nahe, 2/113) |
| grow | 0E38 | 0 % -> 0 % | eigen | 7. | **gleich** |
| ptrace | 0E42 | 80 % -> 94 % | veraendert | 1., 2., 3.; `IPCPRI`, V7-Reihenfolge der Bedingungen in der Suchschleife | **gleich** |
| procxmt | 0F12 | 79 % -> 79 % | veraendert | 2., 5. | **gleich** (vorher nahe, 67/257) |

## Rundlauf: was `core` und `procxmt` geloest hat (gemessen)

* `core`: einzige Abweichung war `u.u_count = -s;` (`ld r2,r12; neg r2`); der Kernel hat `xor r2,r2; sub r2,r12`, also `u.u_count = 0 - s;` -> bytegleich.
  Die Formen `register unsigned s` und `(unsigned)(-s)` aenderten nichts (2 Woerter).
* `procxmt` Fall 6: die frueher dekompilierte Fassung hatte den Gleitkomma-Bereich nicht und rechnete `p = &((int *)&u)[ipc.ip_addr>>1]` ohne `i`; die Kernelbytes zeigen aber die
  V7-Form: `i = ip_addr` in einem Register, `p = &u[i>>1]`, danach `cp r12,#FD5C / #FDEC` (Gleitkommabereich = `u_fparea` .. +0x90).  Mit dieser V7-Form ist die gesamte Funktion bytegleich (528 B).
  `c_rueckbau.md` (K7c) fuehrt `procxmt` als "Status offen"; die Abweichung war **ein Quelltextfehler der Dekompilierung**, kein `c2`-Effekt.

## Rueckfall

Keiner.  `core`, `procxmt`, `grow`, `ptrace` weichen inhaltlich von V7 ab (Z8001-Speichermodell und Registerkarte) und tragen deshalb MUTOS-Zeilen mit Kommentar;
ein reiner V7-Text wurde dafuer nicht uebersetzt (anderes Verhalten, *angenommen*).
