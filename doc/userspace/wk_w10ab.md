# W10ab: Link von `bau as --xcc --libc alt` repariert

Stand 2026-11-24.  Plan 52, W10.  Vorgaenger: `wk_w10aa.md`.

## Ursache (*gemessen*/hergeleitet aus Quellen und Archiven)
* `xcc_usr()` (`tools/userspace/uspace.py`) ersetzt auf der Sitzungs-`usr`-Platte (nur 4 KB frei) `libc.a` durch ein Archiv mit **einem**
  Glied (kleinstes Glied, `fakcu.o`, 32 B); gelinkt wird gegen `libc_alt/as/libc_alt.a`.
* `as_y.c` (yacc-Ausgabe) ruft in `if (yydebug) printf(...)` (Zeile 336) `printf` auf; `libc_alt/as` hat kein `printf`-Glied (nur
  `fprintf`, `sprintf`, `doprnt`).  Beim normalen Bau (`--libc alt` ohne `--xcc`) liefert die volle `libc.a` `printf.o` (232 B); mit dem
  Ein-Glied-Archiv blieb `_printf` offen.
* `_end` ist nur der Folgehinweis des `ld` neben offenen Symbolen (wie schon `wk_w6.md`/`erg_e3b.md`: `_end` kommt aus `sbrk`), keine eigene Ursache.
* Die Annahme "die Quellen rufen kein printf auf" aus W10aa traf nicht zu (nur `fprintf` in den Programmquellen, aber `as_y.c`).

## Fix
`xcc_usr`: das Ersatzarchiv behaelt zusaetzlich `printf.o` (kleinstes Glied + `printf.o`, +232 B).  c2/c2x unveraendert.

## Ergebnis (*gemessen*)
* `bau as --xcc --libc alt`: 414 s, **Binary 35362 B** (vorher 73360 B ohne Link), `neu_x.err` leer.
* `vergleich as --ist neu_x`: Header original text 22092 / data 13706 / bss 17744, gebaut text 21628 / data 13718 / bss 17724;
  Befehle original 5891, gebaut 5459, **gleich 4137** (ohne c2-Modell 4164), 726 Differenzbloecke -- das Soll der Normalpipeline (4137) ist erreicht.
* Rest-Unterschied (nicht behandelt): Funktion 0030 im Original `fprintf(stderr-artig, ...)` mit zwei Argumenten, gebaut `printf(...)` (`as_y.c` yydebug-Zweig);
  die Quelle weicht dort vom Original ab (Folgeschritt: `as_y.c` auf `fprintf` umstellen, dann ist `printf.o` entbehrlich).

## Budget
2 Gastlaeufe: ein `bau as --xcc` (der erste Versuch brach auf dem Host ab: `xcc_c2_s.bin` fehlte im Worktree, `work/` wird nicht eingecheckt, Dateien aus dem Hauptbaum kopiert,
kein Gastlauf), ein `vergleich` (Host).
