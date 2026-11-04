# Herkunft von `kernel/c/tty.c` (AP H5)

Stand 2026-10-31.  Vergleich gegen V7 `dev/kl.c`, `dc.c`, `tty.c`, System III `kl.c`, `tt0.c` und WEGA `ttydev.c`/`siok.c`.  `tty2.c` (die allgemeinen `tt*`-Routinen) ist **nicht** Teil dieses Auftrags (H6; Text der Hippe-Sammlung seit H6c, `tty2.md`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial** (Nachtrag 2026-11-01: `tc*`-Huellen nach V7/Hippe-`kl.c`, `ttstart`/`ttxfer`/`putchar` eigen; Mailbox-Terminal).  Dateiaehnlichkeit: V7 25 % (`kl.c`), System III 15 %, WEGA 13 % (`ttydev.c`).
* Die Huellen `tcopen`..`tcioctl` rufen die allgemeinen Routinen (`ttyopen`, `ttread`, `ttyinput`, `ttioccomm` ... in `tty2.c`) und haben die Gestalt der V7-Zeilentreiber (`klopen`, `klclose`, `klrint`, `klxint`, `klioctl`; 33..67 %),
  das ist das gemeinsame Muster "allgemeine Routine mit der richtigen `tty`-Struktur aufrufen", **kein** Herkunftsbeleg.  Namen frei vergeben (`tc...`).
* `tcstart` (22 %; bis 2026-10-31 `ttstart`, der Name gehoert seitdem der allgemeinen Startroutine in `tty2.c`, vorher `ttkick`), `ttxfer`, `putchar` (Konsolenring, Mailbox-Zeichenausgabe), `ttyinit`: eigen.  System III `kl.c:putchar` (31 %) ist eine andere Form.
* Rundlauf: **10 von 11 bytegleich, wie vorher**; `putchar` 54 von 88 Woertern (Kernel-`c2`, `c_rueckbau.md`).  Nur Kommentare geaendert.

| Funktion | Kernel | V7 abs | Klasse | Rundlauf |
|---|---|---|---|---|
| tcopen | 60CC | 51 % (Muster) | eigen | gleich |
| tcclose | 616C | 62 % | eigen (V7-Muster) | gleich |
| tcread, tcwrite | 618E, 61B0 | 33 % | eigen (V7-Muster) | gleich |
| tcxint | 61D2 | 53 % | eigen (V7-Muster) | gleich |
| tcrint | 620E | 39 % | eigen | gleich |
| tcioctl | 623C | 67 % | eigen (V7-Muster) | gleich |
| tcstart | 6274 | 22 % | eigen | gleich |
| ttxfer | 633A | 8 % | eigen | gleich |
| putchar | 6384 | 10 % | eigen | nahe (54/88) |
| ttyinit | 6432 | 9 % | eigen | gleich |

**Nachtrag 2026-10-31 (AP H6c):** Namen und Membernamen der Huellen folgen der Zeilendisziplin (`tty2.md`): `ttstart` (6274) -> `tcstart`, `ttinit` -> `ttychars`, `ttkick` -> `ttstart`, `ttioctl` -> `ttioccomm`, `t_obuf` -> `t_addr`, `t_lstate` -> `t_xstate`.
Rundlauf unveraendert 10 von 11 (`putchar` 54 von 88 Woertern).

## Nachtrag 2026-11-04 (Plan 43 Gruppe B)

`putchar` ist bytegleich (tty 11 von 11).  Die Warteschleife als **eine Bedingung** `while (hp->mb_stat == 0 && --t != 0) ;` (auch `!hp->mb_stat && --t` und `for (t = 10000; hp->mb_stat == 0 && --t; )`) gibt das `DJNZ` des Kernels; `do { if (..) break; } while (--t)` (4 Formen) gibt `DEC ; JR NZ`.  Das beantwortet die offene DJNZ-Frage aus `c_rueckbau.md` fuer diese Schleife.
