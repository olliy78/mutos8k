# W10ac: as_y.c ruft fprintf wie das Original; as_dir-Luecke ist ein Hostmodell-Befund

Stand 2026-11-24.  Plan 52, W10.  Vorgaenger: `wk_w10ab.md`.

## 1. Funktion 0030 (yydebug)
* Original (`as.lst` 0054..006A): `PUSH L65C0; PUSH R12; PUSH #671A; PUSH #8B42; CALL _fprintf` = `fprintf(stdout, fmt, yystate, yychar)` (8B42 = stdout).
* `userspace/as/as_y.c`: die vier `printf(`-Aufrufe der yydebug-Zweige sind jetzt `fprintf(stdout, ` (Handpatch nach yacc, im Dateikopf vermerkt).
* `xcc_usr()` (`tools/userspace/uspace.py`): Ersatzarchiv wieder nur mit einem Glied (`printf.o` entfernt).
* *Gemessen*: `bau as --xcc --libc alt` 411 s, Link ohne printf.o ok, Binary 35330 B, `neu_x.err` leer.
  `vergleich as --ist neu_x`: Befehle 5891 / gebaut 5462, **gleich 4140** (vorher 4137; ohne c2-Modell 4167), 725 Differenzbloecke.
  Funktion 0030 unterscheidet sich nur noch in Datenadressen.

## 2. as_dir
* *Gemessen* (`neu_x.bericht`): hinter Funktion 3038 gibt es keinen Differenzblock mehr; as_dir (Original ca. 3A80..3E60, u. a. der
  Schalter `cp r2,#%42 / #%44 / #%50 ...` bei 3C1C..3C3E mit nur einem `xorb rh2,rh2` davor) ist im c2x-Bau **befehlsgleich zum Original**.
* Die R32/R3-Luecke aus W10z betrifft damit nur das **Hostmodell** (`uspace.py` R32: fuegt `xorb` vor dem 2. `cp` einer Kette ein, das Original
  hat es in dieser Schalterkette nicht); c2x liegt richtig.  Modell nicht geaendert (kein Gastlauf, c2/c2x unveraendert).

## Budget / offen
1 `bau as --xcc`, 2 `vergleich` (Host), kein c2-Bau.  Ein `bau as --libc alt` (ohne xcc) zur Regressionspruefung (Soll >= 4137) war beim Abschluss
des Auftrags gestartet, Ergebnis nicht abgewartet.  `pytest -m "not gast"`: 211 ok, 1 Fehler (`test_bau_alle_kennt_genau_die_fertigen_disketten`, braucht disks/gebaut).
