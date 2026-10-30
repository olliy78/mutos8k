# Herkunft von `kernel/c/slp.c` (AP H3, Pilot)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/slp.c`.  Rundlauf wie in `rundlauf.md`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7).  10 von 11 Funktionen tragen V7-Text (mit markierten MUTOS-Zeilen), `expand` ist ein leerer Stumpf (*eigen*).
  File-Aehnlichkeit (abs) V7 85 % -> 88 %, System III PDP-11 61 %.  Die Zeichenkette `"zero wchan"` steht in V7, **nicht** in System III `slp.c` (gemessen mit `rg`): starkes V7-Indiz.
* **Alle 11 Funktionen bytegleich** (Basis: 9 von 11).  `swtch` und `newproc` waren vorher "nahe"/offen (K7a: "Quellform noch nicht getroffen").
* Die frueheren Kopf-Angaben "System-III-nahe Fassung wie WEGA slp.c" waren falsch bzw. unbelegt: der Text ist V7 (88 % gegen 58 % System III).
* **Eigene MUTOS-Aenderungen gegenueber V7:**
  1. `sleep`: die zweite Pruefung `if (chan==0) panic("Sleeping on wchan 0");` fehlt (und der Text fehlt im Kernel).  Die erste (`"zero wchan"`) ist da.
  2. `setpri`: kein `return(p)` (V7 gibt die Prioritaet zurueck).
  3. `sched`: zusaetzlicher Block am Schleifenkopf (`sflag1` -> `update()`, setzt `sflag0`/`sflag1` zurueck): der Scheduler-Prozess ruft `update()` auf (Zweck *angenommen*: periodisches `sync`; V7-`sched` hat diesen Block nicht).  Namen `sflag0/sflag1` sind geraten.
  4. `proctop` statt `&proc[NPROC]` (`sched`, `newproc`; auch `sig.c`): variable Prozesstabellengroesse (Zeiger `proctop` bei 8A8C).
  5. `swapin`: statt `swap(p->p_addr, a, p->p_size, B_READ); mfree(swapmap, ...)` ein Fuenf-Argument-`swap(p->p_addr, a, 0x104, B_READ, t)` mit `t = (a << 2) + 0xEC00` (Z8001-Segment des u-Bereichs); das Swap-Platzfreigeben (`mfree(swapmap...)`) fehlt hier (steht evtl. im `swap`/`xswap`-Pfad, *angenommen*).
  6. `swtch`: `savu` statt `save`, `u.u_fparea` statt `&u.u_fps` (Gleitkomma-Sicherung der Z8001).
  7. `newproc`: Bildgroesse fest `n = 256` (V7 `rip->p_size`), `malloc` in `a` (V7 `a2`), nach dem Kopieren zusaetzlich 4 Segmenteinheiten des u-Bereichs (`copyseg` ab `((unsigned)&u + 0xFF) >> 8`) in das neue Bild, Gleitkomma-Sicherung (`savfp(u.u_fparea)`) vor dem `malloc`.
  8. `expand`: V7 hat einen Rumpf (`expand(newsize)` mit `malloc`/`copyseg`/`resume`); der Kernel hat 8 Byte (`csv; jp cret`).  Auch `grow` (sig.c) ist leer: der Z8001-Kern vergroessert Stapel/Daten nicht (*angenommen*).

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung | Rundlauf |
|---|---|---|---|---|---|
| sleep | 18D4 | 96 % -> 96 % | veraendert | 1. | **gleich** |
| wakeup | 19A8 | 100 % -> 100 % | identisch | `register s` (V7 `int s`) | **gleich** |
| setrq | 1A30 | 100 % -> 100 % | identisch | -- | **gleich** |
| setrun | 1A7C | 100 % -> 100 % | identisch | -- | **gleich** |
| setpri | 1AE8 | 74 % -> 94 % | veraendert | 2. | **gleich** |
| sched | 1B34 | 92 % -> 92 % | veraendert | 3., 4., `register maxsize` | **gleich** |
| swapin | 1CCA | 80 % -> 80 % | veraendert | 5., `register t`/`x` | **gleich** |
| qswtch | 1D8E | 100 % -> 100 % | identisch | -- | **gleich** |
| swtch | 1DA4 | 81 % -> 90 % | veraendert | 6. | **gleich** (vorher nahe, 93/129) |
| newproc | 1EA2 | 83 % -> 84 % | veraendert | 4., 7. | **gleich** (vorher offen, 159/293) |
| expand | 20F6 | 0 % -> 0 % | eigen | 8. | **gleich** |

## Rundlauf: was `swtch` und `newproc` geloest hat (gemessen)

* `swtch`: statt der absoluten Zellen `(*(int *)0xFD5A)` / `(char *)0xFD5C` jetzt `u.u_fpsaved` / `u.u_fparea` (Header `user.h` kennt sie laengst) und V7-Form der Kommentare/Klammern -> bytegleich.
* `newproc`, in vier Probeschritten (Probelaeufe, Dateien nur im Arbeitsordner):
  1. V7-Form (`if(up->p_textp != NULL)`, `savu`, `u.u_fpsaved`): Abweichung 155 von 291 Woertern -> 89 von 290 (die `test @r2`-Form);
  2. die u-Bereichs-Adresse nicht als Konstante `(unsigned)0xFCFF >> 8`, sondern `((unsigned)&u + 0xFF) >> 8`: `c2` faltet die Konstante nicht, es entsteht `ld r2,#u+FF` mit Relokation (das Kernelwort `FCFF` ist `u` = FC00 plus 0xFF) -> 84 von 296;
  3. der Rest (zwei Woerter `ld r2,..; ld r10,r2`) verschwand mit `a = (rpp->p_addr >> 8) * 0x400;` statt `a = rpp->p_addr >> 8 << 10;`: bytegleich (596 B).  Die Formen `(unsigned)(...)`, `(...) + 0`, `a = a + 0xECFF`, `a >>= 8; a <<= 10` und `|= 0` ergaben alle 84 Woerter.
* Der Befund legt nahe, dass der Originalquelltext die Multiplikation mit 1024 (Segment -> u-Bereich-Offset) schrieb (*angenommen*).

## Rueckfall

Keiner.  Jede Funktion hat den V7-Text mit MUTOS-Markierungen; es gibt keinen auskommentierten Zweitext.  Funktionen mit grosser V7-Abweichung (`swapin`, `newproc`, `expand`)
wurden nicht als reiner V7-Text versucht (anderes Verhalten: Fuenf-Argument-`swap`, feste Bildgroesse, leerer Rumpf), das ist eine Annahme aus dem Textvergleich, kein Rundlauf.
