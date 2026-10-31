# Herkunft von `kernel/c/pipe.c` (AP H3)

Stand 2026-10-31.  Quellen: UNIX V7 `usr/sys/sys/pipe.c` (`pipe`, `readp`, `writep`, `plock`, `prele`), `nami.c` (`uchar`), `prim.c` (`getc`, `putc`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  Alle 8 Funktionen tragen V7-Text mit V7-Kommentaren.  `uchar` steht im Kernel hinter `namei` (39BA) und stammt aus V7 `nami.c`; `getc`/`putc` stehen im Kernel hinter `prele` und stammen aus V7 `prim.c`
  (V7 `prim.c` hat weitere Funktionen -- `q_to_b`, `b_to_q`, `ndqb`, `ndflush`, `putw`, `getw`; sie kommen in `kernel/c` nicht vor, *angenommen*: der MUTOS-Terminaltreiber braucht sie nicht).
* System III PDP-11: 26 % -- dort ist die Pipe ein FIFO-Inode (`IFIFO`, `closep`), `readp`/`writep` gibt es nicht.  Dateiaehnlichkeit V7 (nur gegen `pipe.c`) 77 % -> 78 %: die Zahl bleibt niedrig,
  weil drei der acht Funktionen aus `nami.c`/`prim.c` kommen; je Funktion gegen die V7-Baumsuche sind es 100 %.
* Rundlauf: **8 von 8 bytegleich, vorher 8 von 8**.  `readp` ist wieder in der V7-Form (`loop:` ... `goto loop`) statt `while (plock(ip), ip->i_size == 0)`; beide Formen uebersetzen identisch.

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| uchar | 39BA | 100 % -> 100 % | identisch | aus `nami.c` | **gleich** |
| pipe | 39E2 | 100 % -> 100 % | identisch | -- | **gleich** |
| readp | 3A68 | 91 % -> 100 % | identisch | -- | **gleich** |
| writep | 3AFE | 100 % -> 100 % | identisch | -- | **gleich** |
| plock | 3BBE | 100 % -> 100 % | identisch | -- | **gleich** |
| prele | 3BE0 | 100 % -> 100 % | identisch | -- | **gleich** |
| getc | 3BFC | 100 % -> 100 % | identisch | aus `prim.c` | **gleich** |
| putc | 3C80 | 100 % -> 100 % | identisch | aus `prim.c` | **gleich** |

* Abweichungen im Quelltext: `PIPSIZ` kommt aus `inode.h` (V7 definiert es in `pipe.c`; als Kommentar vermerkt); `cblock`/`clist`/`CBSIZE 14`/`CROUND 017` sind lokale Kopien des V7-Textes (`param.h`/`tty.h`/`prim.c`),
  weil `kernel/h/tty.h` ein anderes `clist`-Umfeld hat (Hinweis im Kopf von `tty.h`: nicht beide einbinden).
* Rueckfall: keiner.
