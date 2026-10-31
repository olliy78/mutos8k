# Herkunft der Header und Konfiguration (AP H4)

Stand 2026-10-31.  Quellen: `kernel/h/*.h`, `kernel/conf/{conf,sysent}.c`; Referenz `original/unix-v7/usr/sys/h` und `usr/sys/{sys,conf}`.
Zahlen **gemessen**, sofern nicht als *angenommen* markiert.  Werkzeug: `tools/herkunft/herkunft.py structs` (Verhaeltnis der Membernamen), Layoutpruefung `tests/test_header_layout.py`.

## Ergebnis

* Alle Header tragen jetzt die V7-Form (Unions `b_un`, `i_un`, `f_un`; V7-Namen, V7-Kommentare, englisch) bei **unverändertem Layout**; Dateikopf im Format von Plan 42 Abschnitt 5.
* Rundlauf (`tools/herkunft/rundlauf.sh`, alle 27 Module in 4 Gastlaeufen, je Funktion): **181 von 227 Funktionen bytegleich, vorher 181 von 227**; keine Funktion schlechter
  (die "nahen" `alloc` 84/158, `ialloc` 169/220, `update` 85/119 unveraendert).  Die Module `alloc iget slp sig` verwenden wieder die V7-Zugriffe (`b_un.b_addr`, `i_un.i_addr`, ...).
* Gesamtbau `gesamtbau.py --uebersetzen --stufe 1 --boot`: 181 von 227 aus C, **BYTEGLEICH (0 Byte ungleich)**, 36 352 Byte, Boot und Arbeitstests (`summe = 5050`, `cc -O -c prf.c` 1600 B).
* Befund entgegen der Erwartung: V7-Form von `SUPERB` (`((daddr_t)1)`) macht `ialloc` um 2 Byte laenger (`adr = SUPERB+1` wird `LDL imm` statt `LDK/EXTSL`); der Kernel hat also `SUPERB` als **int 1**.
  Bleibt int, `update` behaelt `(daddr_t)SUPERB`.  `short`/`unsigned short` statt `int`, `NINDIR (BSIZE/sizeof(daddr_t))`, `NODEV (dev_t)(-1)`, `ROOTINO ((ino_t)2)`, Unions: ohne Wirkung auf den Objektcode.
* Die Strukturmaße in `uebersicht.md` 4.2 (`buf` 0,92, `inode` 0,86) sind durch die Angleichung jetzt 1,00; das ist **kein neuer Herkunftsbeleg** (die Header sind angepasst, nicht neu gemessen).

## Tabelle

Klassen: **I** identisch, **F** Layout identisch, Form jetzt V7 (vorher flach), **E** MUTOS-eigen, **L** abweichendes Layout.

| Header | Klasse | Beleg Layout | Abweichung von V7 |
|---|---|---|---|
| `buf.h` | F (`b_un`) | gemessen (24 B, `b_error` +15, `b_resid` +16) | ohne `B_PBUSY/B_PACK`, ohne `b_actf..b_errcnt`; `b_xmem`/`b_error`-Lage Z8001 |
| `inode.h` | F (`i_un`) | gemessen (74 B, `i_addr` +12, `i_lastr` +46); Reihenfolge `i_mode..i_size` angenommen | ohne mpx (`group`, `NINDEX`, `mpxip`, `i_group`); `PIPSIZ` aus V7 `pipe.c` |
| `file.h` | F (`f_un.f_offset`) | gemessen (8 B); `f_inode` angenommen | I sonst |
| `mount.h`, `callo.h`, `ino.h`, `dir.h`, `fblk.h` | I | gemessen (6 / 6 / 64 / 16 / 202 B) | Tabellen nur `extern`; `dir.h` bindet `param.h` ein |
| `filsys.h` | I | gemessen bis `s_tinode`; Rest V7 | `s_tfree/s_tinode` werden gepflegt (SysIII-Zug) |
| `proc.h` | I | gemessen (28 B) | `slpque` hier deklariert; `xproc` jetzt aus V7 (vorher lokale Kopie in `sys1.c`, gleiches Layout) |
| `text.h`, `map.h` | I | ungemessen (Stubs / `malloc`) | `short` wie V7 |
| `types.h` | E/teilweise V7 | gemessen (Breiten, `label_t` 9 Worte) | V7 hat die Typen in `param.h`; `cnt_t` aus SysIII (unbenutzt) |
| `param.h` | teilweise V7 | gemessen: NOFILE, BSIZE, NINODE, NFILE, NBUF, NMOUNT, NPROC, MAXUPRC, NCALL, HZ, DIRSIZ, NSIG; Rest *angenommen* | MUTOS-Werte; Click 256 B (`ctod`); SysIII-Signalnamen mit V7-Aliassen; `SUPERB` int |
| `systm.h` | teilweise V7 | Adressen gemessen; `sy_nrarg` = 0 in allen 64 Zeilen gemessen | nur Deklarationen (`extern`) |
| `conf.h` | teilweise V7 | gemessen (8 / 14 / 20 B) | `linesw` mit SysIII-Namen; `devtab` MUTOS (weder V7 noch SysIII) |
| `user.h` | L teilweise | Offsets gemessen (Liste im Kopf); Fuellfelder angenommen | Z8001-Layout; `u_ex[]`, `u_exname` statt `u_exdata`, `u_comm`; `u_ttyp/u_ttyd` benannt (loest `user_ext.h` ab) |
| `tty.h` | L | gemessen (60 B) | SysIII/ZEUS-Aufbau, nicht V7 (`rawq/canq`); `XTABS 02000` |
| `reg.h` | E (Origin none) | ungemessen | Platzhalter |
| `mbx.h` | E (Origin none) | gemessen | U880-Mailbox |
| `user_ext.h` | entfallen | -- | Makros durch `u.u_sep`, `u.u_ttyp`, `u.u_ttyd`, `u.u_cmask`, `u.u_ar0` ersetzt, Objektcode gleich |
| `conf.c` | E (partial) | Datenbytes 8766..88C5 (Gesamtbau gleich) | Inhalt MUTOS, Form wie V7 `c.c` |
| `sysent.c` | partial V7 | gemessen (64 Zeilen) | 6 Zeilen `nosys` statt `stty gtty sysacct sysphys syslock mpxchan`; `nrarg` 0; V7-Numerierung (Altvermerk "WEGA/SysIII-Tabelle" war falsch) |

## Pruefungen

* `tests/test_header_layout.py`: Offsets/Groessen aller Strukturen gegen die gemessenen Werte (host, ohne Emulator).
* `tests/test_quelltext_regeln.py`: nur `/* */`, keine Verschachtelung, kein vorzeitiges `*/`, 7-Bit-ASCII ueber `kernel/{c,h,conf}` (ohne `c/varianten`).
  Der Test fand ein vorzeitiges `*/` in `systm.h` (`dk_*/tk_*` im Kommentar), das den Gast-`cc` abbrechen liess.
* Offen: Header-Kommentare in `kernel/c` ausserhalb der vier H3-Module sind noch teils deutsch (H3); `c/varianten/*` nicht angepasst (Probedateien).
