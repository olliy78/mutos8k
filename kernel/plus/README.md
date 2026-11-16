# kernel/plus -- Quellen des Selbstbaus (Branch `mutos-plus`)

Plan 47 P1.3.  Diese Dateien sind die **nicht-C-Teile** des natuerlichen Kernelbaus (`tools/kernel/gesamtbau.py`, `nat_quellen`);
die C-Quellen und Header liegen weiter in `kernel/c`, `kernel/conf`, `kernel/h`.  Erzeugt am 2026-11-16 **einmalig** aus dem
Original-Abbild `mutos_1216` und den Objekten von P1.1 (`/tmp/mplus/p1_1/obj/`) durch `tools/plus/extrahieren.py` (Aufteilung auf zwei
Quelldisketten durch `tools/plus/basis.py`).  **Ab jetzt von Hand gepflegt**; `extrahieren.py` bleibt nur als Herkunftsbeleg
(`extrahieren.py --force --ziel <Wegwerfordner>` erzeugte am 2026-11-16 dieselben Bytes; seit P1.4 nicht mehr: `abs.o` -> `abs.s`, `bss.s`, `Makefile` sind von Hand geaendert).

| Datei | Inhalt | Herkunft |
|-------|--------|----------|
| `low.s` | Assemblerteil `low` (Vektoren, Trap-Eintritt, Start; Text 0000..0674 + Daten bis 875A) | z8kdis des Originals, Modul `low` |
| `shim.s` | Hilfsroutinen, die der Gast-`cc` erwartet | `gesamtbau.SHIM` |
| `daten.c` | initialisierte Daten des Kernels (P2.2; ersetzt `dn0.s`..`dn3.s`): `regloc[8]`, `max_proc = &proc[2]`, `icode[26]` + `szicode`, `cf_8c94` (4), `conptr = conlog`, `nlp` (1); Werte aus den `dn*.s`, Originaladressen im Kommentar.  `icode` als `char`-Array mit Bytewerten (Maschinencode) und Zeichen fuer `"/etc/init"` -- sauber ausdrueckbar, kein Sonderweg.  Linkreihenfolge wie vorher (hinter `sysent.o`, vor `bss.o`) | `dn0`..`dn3` des z8kdis-Auszugs |
| `bss.s` | BSS als echter BSS-Abschnitt (`$SECTION BSS_B` ... `$SDEFAULT`, `G _name A[%n B]`; ab P1.4, vorher Nullen im Datenabschnitt) | z8kdis, Modul `bss`; plus `_nested` (unten) |
| `abs.s` | die absoluten Symbole (`_cfreeli` D266 ... `_mapbusy` D584, `_u` FC00), je Symbol `$ABS %adr` / `G` / `_name L` / `_name:` (ab P1.4; ersetzt das Objekt `abs.o` von `gesamtbau.nat_abs`) | Symbole und Werte des alten `abs.o` (`objformat.py nm`) |
| `mk1` | Makefile fuer Diskette 1 (baut die erste Haelfte der C-Dateien `alloc`..`sig`) | `basis.aufteilen` |
| `Makefile` | Makefile fuer Diskette 2 (Rest, `low/shim/abs/bss`, `daten.c`, bindet `lk`; Standardziel `mutos_1216` = `lk` ohne Kopf per zwei `dd`-Aufrufe, auf 512 B aufgefuellt) | `basis.aufteilen`, P1.4 |

Alle Dateien sind reines ASCII.  Der `as` kennt `! ... !`-Kommentare (`doc/werkzeugkette/as_dialekt.md`), die Quellen
tragen aber (bis auf die Zeile zu `_nested`) keine; die Erklaerungen stehen hier.

## Aufteilung auf zwei Quelldisketten

Die Quellen (292 KB) passen nicht auf eine Diskette (239 KB, `doc/plus/gastbau.md` §1).  Diskette 1 = Header + `make` + `mk1` + C-Dateien
`alloc bio clock dev0 fio iget lp machdep main malloc nami pipe prf rdwri rk sig`; Diskette 2 = Header + `make` + `Makefile` + `slp subr sys1 sys2
sys3 sys4 text trap tty tty2 ureg conf sysent` + `low.s bss.s shim.s dn*.s abs.o`.  Im Gast: `(cd /tmp; /mnt/make -f /mnt/mk1)`, Diskettenwechsel,
`(cd /tmp; /mnt/make -f /mnt/Makefile)`.  Die Objekte von Diskette 1 liegen dann schon in `/tmp` und haben im `Makefile` keine Regel.

## `-D`-Namensabgleiche (zwei C-Namen fuer eine Variable)

Das Original hat dieselbe Variable in verschiedenen Modulen unter verschiedenen Namen angesprochen; die C-Quellen benutzen je Datei den
ihr bekannten Namen, das Makefile gleicht per `-D` ab (aus den undefinierten Symbolen der Objekte von P1.1 abgeleitet, `nat_quellen`):

| Datei | Option | Grund |
|-------|--------|-------|
| `bio.c`, `rk.c` | `-Dusrseg=usegm` | `usrseg` in diesen Dateien ist die Variable `usegm` (BSS, erstes Symbol von `bss.s`) |
| `trap.c` | `-Dbackup=sigret` | `backup` und `sigret` sind dieselbe Routine in `low` |
| `conf.c` | `-Dcf_a620=ipc -Dcf_a628=buffers -Dcf_ceac=rfdbuf` | die Konfigurationstabelle benennt die Zeiger auf `ipc`, `buffers`, `rfdbuf` unter ihrer Adresse |

Die Spalte *Grund* ist **Annahme**; belegt ist nur: das Objekt der Datei verweist auf den ersten Namen, das Original definiert den zweiten.

## Unterschied zu `nat_quellen` (Nachtrag 2026-11-16, Punkte 4-6; Abweichung #2 in `doc/plus/abweichungen.md`)

Diff gegenueber der Ausgabe von `nat_quellen` (gemessen 2026-11-16, `diff` der Arbeitsordner `/tmp/mplus/p1_3/ref/` und `kernel/plus/`):
* `bss.s`: zwei Zeilen mehr (Kommentar und `G _nested A[%2 B]`).  `int nested;` in `trap.c` war im Original bei 88E0 benannt; hier war es ein Common, das `ld`
  hinter die BSS legte (`lk` meldete bss 2).  Mit dem Namen meldet `lk` bss 0.  `_cfree` bleibt `%310` = 784 B = 49 Bloecke (siehe `NCLIST`).
* `kernel/c/ureg.c`: `NCLIST` 50 -> 49 (nur diese Zeile und Kommentare).  Grund: der Kernel ist 4 B zu gross (Text +2 durch `ttyinput` ohne c2-Fehler,
  `nested` +2); die BSS darf nicht ueber D266 (`cfreelist`) reichen.  Mit 49 Bloecken endet `cfree` 12 B unter D266.
  `cfree[]` ist eine Common-Variable, `bss.s` gibt ihr nur Platz und Namen; die Laenge in `bss.s` entspricht `NCLIST*16` (784), nicht dem
  Originalwert 800 (`%320`) -- ein Block weniger fuer tty und Drucker.
* `Makefile`: Kopfkommentar englisch; die Regeln der ersten Haelfte stehen in `mk1`.  (Das Provisorium `/bss.o` auf der Wurzel entfiel mit P1.4:
  `bss.o` ist jetzt ein echter BSS-Abschnitt ohne Nullen und liegt wieder auf A.)
* Sonst (low, shim, dn0, dn2, dn3) bytegleich zu `nat_quellen`.
* P1.4: `abs.o` -> `abs.s`; `bss.s` in `$SECTION BSS_B`; `dn1.s` `max_proc` als Verweis; `Makefile` mit Ziel `mutos_1216`.

Die BSS-Grenzpruefung (Ende von `_cfree` <= D266, nicht D256) steht in `tools/plus/basis.py` (`grenze_pruefen`).

* P2.2/P2.3: `dn0.s`..`dn3.s` -> `daten.c`; `low.s` Wort bei 0x23C = `WV _cf_x88a`; `conf.c` `cf_proctop = &max_proc`.  Gegenueber P1.5b sind im Kernel genau 4 Byte anders (`gastbau.md` §3).
