# Herkunft von `kernel/c/alloc.c` (AP H3, Pilot)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/alloc.c`; Vergleich: `tools/herkunft/herkunft.py compare kernel/c/alloc.c --ref v7=... s3pdp=...`.
Rundlauf: `tools/herkunft/rundlauf.sh` (siehe `rundlauf.md`), Bezug `mutos_1216` aus dem Original-Archiv.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7), alle 7 Funktionen tragen jetzt den V7-Text (Namen, Struktur, englische Originalkommentare).
* **Bemerkenswert:** `alloc`, `free`, `ialloc`, `ifree` enthalten die **System-III-Zaehler** `s_tfree`/`s_tinode` (`if(fp->s_tfree) fp->s_tfree--;`,
  `fp->s_tfree = 0;` bei `nospace`, `fp->s_tfree++`, `if(fp->s_tinode) fp->s_tinode--;`, `fp->s_tinode = 0;` bei "Out of inodes", `fp->s_tinode++`).
  V7 pflegt diese Felder nicht; die Zeilen stehen **textgleich** in `original/sys3/uts/pdp11/os/alloc.c` und `.../vax/os/alloc.c`.
  Der Rest (Pruefung "Bad free count", Schleife ueber `badblock`, `ROOTINO`-Test in `ialloc`) ist V7, nicht System III (SysIII: `copyio`, `paddr`, `delay(5*HZ)`).
  Das widerspricht der Aussage aus H2 "System III im Kern nicht belegt" **nur in diesem Detail**: der Kern ist V7 mit einzelnen SysIII-Zuegen.
  Herkunft dieser Zuege (SysIII-Anleihe, V7-Zusatz, WEGA/ZEUS) ist *offen* (Plan H6).
* Der Code ist byteweise nicht schlechter als vor der Wiederherstellung: der Objekttext von `alloc.c` ist **identisch** zum Objekttext der alten (dekompilierten) Fassung
  (verglichen mit `objformat.Objekt.text`, 1440 Byte).

## Funktionen

| Funktion | Kernel | V7-Aehnlichkeit abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| alloc | 2F48 | 86 % -> 93 % | veraendert | `s_tfree--`, `s_tfree = 0` (SysIII); `b_addr` statt `b_un.b_addr` (flache `buf.h`); `struct fblk` aus neuem `kernel/h/fblk.h` | nahe (84 von 158 Woertern, wie vorher) |
| free | 3086 | 81 % -> 93 % | veraendert | `s_tfree++` (SysIII); `b_addr` | **gleich** |
| badblock | 316A | 100 % -> 100 % | identisch | im Kernel `static` (kein Symbol); hier global, damit `vergleich.py` die Funktion findet | **gleich** |
| ialloc | 319E | 89 % -> 93 % | veraendert | `s_tinode--`, `s_tinode = 0` (SysIII); `i_addr[i]` statt `i_un.i_addr[i]`; `(struct dinode *)b_addr` statt `b_un.b_dino` | nahe (169 von 220 Woertern, wie vorher) |
| ifree | 335A | 89 % -> 89 % | veraendert | `s_tinode++` (SysIII) | **gleich** |
| getfs | 339E | 95 % -> 95 % | identisch | `(struct filsys *)...b_addr` statt `b_un.b_filsys` | **gleich** |
| update | 3400 | 92 % -> 95 % | identisch | Cast `(daddr_t)SUPERB` (long auf Z8001, keine Prototypen); `b_addr` | nahe (85 von 119 Woertern, wie vorher) |

"Klasse": *identisch* = nur Header-Idiome (flache Strukturen, Casts) bzw. Z8001-Casts; *veraendert* = inhaltlich abweichende Zeilen; *eigen* = kein V7-Text.
Beleg der Klasse: Textvergleich mit `original/unix-v7/usr/sys/sys/alloc.c` (gemessen, `diff` nach Normalisierung des Leerraums).

## Rundlauf-Ergebnisse und Rueckfall

* 4 von 7 Funktionen bytegleich (`free`, `badblock`, `ifree`, `getfs`), 3 "nahe" (`alloc`, `ialloc`, `update`) -- **genau dieselben Zahlen wie vor der Wiederherstellung**
  (Basislauf mit der alten Fassung: `alloc` 84/158, `ialloc` 169/220, `update` 85/119 abweichende Woerter).
* **Kein Rueckfall noetig:** der V7-Text erzeugt den gleichen Objektcode wie die alte Fassung.  Auch die V7-Form `if(dp->di_mode != 0) goto cont;` in `ialloc`
  (die alte Fassung hatte die verschachtelte Form `if (dp->di_mode == 0) {...}`) und die V7-Formen mit `FBLKP`-Casts (statt `*((int *)b_addr)`) uebersetzen identisch.
* Die drei "nahen" Funktionen sind in `doc/kernel/c_rueckbau.md` (K7b) als Muster (B) bzw. (B)+(C) des aelteren Kernel-`c2` beschrieben
  (*angenommen*, hier nicht neu analysiert; die V7-Form aendert nichts daran, was die K7b-Annahme stuetzt).

## Offene Punkte

* `kernel/h/buf.h`/`inode.h` sind flach (kein `b_un`, kein `i_un`); die V7-Schreibweise (`bp->b_un.b_addr`) braucht eine Unionsform in den Headern -- H4.
* `fblk.h` ist neu (V7-Text, unveraendert); Layout `df_free` bei +2 stimmt mit dem alten `(int *)b_addr + 1` (gleicher Objektcode).
