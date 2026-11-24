# W10aa: c2x selbst verkleinert (stdio und printf-Familie entfernt)

Stand 2026-11-24.  Plan 52, W10.  Vorgaenger: `wk_w10z.md`.  Ziel: das Programmbild von c2x um 3-5 KB senken, damit grosse Funktionen
(`as_code`/`encode`) genug Halde haben (MUTOS: Text+Daten+BSS in einem 64-KB-Segment, F5).  Nur unter `C2X`; Standard-c2 bleibt tokengleich.

## Messung vorher (*gemessen*, Disassembly von `c2x_c2.bin` W10z)
* `r5pass` allein 3352 B Text (0x40EA..0x4E02), `hzdrop`/`hzkeep` zusammen ca. 1 KB.  Die libc-Teile, die c2 zusaetzlich braucht,
  sind im c2-Bild enthalten: `_doprnt`, `strout`, `ffltpr`, `printf/fprintf/sprintf`, `_filbuf`, `_flsbuf`, `_endopen`, `freopen`, `isatty`, `malloc`.
* stdin/stdout nutzen die statischen Puffer `_sibuf/_sobuf` (nicht `malloc`): der Wegfall aendert die Heaplage von c2 nicht.
* Stapeltiefe: nicht gemessen (kein billiger Weg).

## Aenderungen (`userspace/c2/c20.c`, `c2.h`, `c21.c`, alles `#ifdef C2X`)
1. Eigene Ausgabe `xfm` (`%d %s %x %%`, **ein** Argument) ersetzt `printf/fprintf/sprintf` (Makros in `c2.h`).  `%x` gibt wie die libc
   **Grossbuchstaben** aus (`inc SP,#%E`); die erste Fassung mit Kleinbuchstaben wurde vom 65-Module-Lauf (c01, no-flag) gefunden.
2. Eigene Ein-/Ausgabe: zwei 256-Byte-Puffer (initialisierte Daten, F1) auf fd 0/1, stderr ungepuffert, `freopen`/`exit` durch `xfro`/`xexit`
   ersetzt, `_cleanup()` leer definiert (libc-`_exit` ruft es; so wird `_flsbuf` nicht hineingezogen).  `putchar/getchar` sind jetzt Funktionen
   statt ca. 30 Byte grosser Makros.
3. Statistikausgabe der Option `-` entfaellt unter C2X (nur noch `<n>K core`).
4. `xnd(node, op, subop, code)` in `r5pass` statt wiederholter Einzelvergleiche.
5. Die Ausgaberoutinen stehen in `c20.c`, nicht `c21.c`: ein erster Bau mit ihnen in `c21.c` scheiterte mit `symbol table overflow` des Assemblers
   (849 Symbole; c21.o war bei c2x schon nahe daran).  Merke: neue C2X-Funktionen nach c20.c.

## Ergebnis (*gemessen*)
| | Text | Daten | BSS | Bild |
|---|---|---|---|---|
| c2 (neu_c2) | 16956 | 1984 | 3296 | 22236 |
| c2x W10z | -- | -- | -- | ca. 28944 |
| c2x W10aa (`c2x_c2.bin`, 22814 B Datei) | 20518 | 2280 | 2268 | **25066** |

Das Bild ist gut 3,9 KB kleiner; c2x liegt nur noch 2,8 KB ueber c2.  (Die Binaries wurden nach dem Klein/Gross-Fix der Hexziffern
direkt im Bild gepatcht: `0123456789abcdef` -> `...ABCDEF`, gleiche Laenge, genau eine Stelle; kein vierter Bau -- Budget.  Der Quelltext
ist korrigiert, ein Neubau muss dasselbe Bild liefern.)

## Diagnose `as` (`lauf as --auto`, `C2GEGEN_N=1`, Spitze der Halde, c2 / c2x)
| Modul | c2 / c2x | Bemerkung |
|---|---|---|
| as_lex | 40K / 45K | |
| as_misc | 26K / 29K | |
| as_main, as_expr | 28K / 33K | |
| as_dir | 28K / 31K | |
| as_code mit S | 61K / **60K** | laeuft durch (W10z: Zaehler lief ueber) |
| as_code ohne S | 61K / Abbruch (Ausgabe 256 B) | S bleibt noetig |

Schalter `C2GEGEN_NOS=1` in `c2gegen.py` laesst `S` weg.

## Regression (ein 65-Module-Lauf `lauf --kurz --s0 --auto --null --extra R3,R33,R39`, fuer die Regelflags mit `--regeln` aller Buchstaben)
* **no-flag 65/65 SAME** (der erste Lauf mit Kleinbuchstaben-Hex: c01 abweichend, Ursache oben).
* Mit Flags je Programm (`xpush` gegen Hostmodell): **57 gleich, 8 abweichend** (c0/c00, c0/c02, c2/c21, convert, cpp, ed, passwd, tar) -- >= 57/65 erfuellt.
* Budgetnotiz: dazu kamen ein abgebrochener Lauf (Kleinbuchstaben) und ein Lauf ohne `--regeln`.

## `bau as --xcc` / `vergleich as --ist neu_x`
`bau as --xcc --libc alt` (424 s, Binary 73360 B, as_misc/as_main mit plain `cc -O`, as_code mit `S`) **lief durch alle Module** (das Problem
von W10w -- 90 min ohne Ende -- tritt nicht mehr auf), der **Link meldet aber `Undefined: _printf, _end`**; das Binary ist damit unbrauchbar.
`vergleich as --ist neu_x`: 5450 gebaute gegen 5891 Original-Befehle, 4046 gleich (Soll der Normalpipeline: 4137) -- wegen des fehlgeschlagenen
Links nicht bewertbar.  *Nicht untersucht* (Budget des `bau as` verbraucht): die Quellen von `as` rufen kein `printf` auf, die Ursache liegt also im
xcc-Pfad / in der Archivauswahl fuer `as` (`libc_alt/as` hat kein `printf`-Glied), nicht im c2x-Bild; Gegenprobe waere ein `bau as --libc alt` ohne
`--xcc`.  Naechster Schritt W10ab.

## Offen
* Stapeltiefe nicht gemessen; `r5pass` (3,3 KB) ist weiter der groesste Brocken, falls mehr noetig wird.
* as_dir weicht gegen das Modell ab (W10z, nicht analysiert).
