# W10y: djnz-Ursache (F6), gemeinsame Zeichenketten abgeschaltet, xcc je Modul

Plan 52 W10, Schritt 10. Alles *host-only*; **kein Gastlauf** (siehe 4). `tokcheck` c2 und cc OK, `pytest -m "not gast"` 215 passed, 1 skipped.

## 1. Hypothese der Koordination: bestaetigt (Quelltext), Messung offen
Siehe `doc/system/bekannte_fehler.md` F6. `addsob()` vergleicht `p->refc` (dec-Knoten) mit `p1->ref->refc` (Marke). Der dec-Knoten kommt aus `input()` und bekommt `refc` nie gesetzt; `jumpsw()` (V7-Nummerierung) wird im MUTOS-c2 nicht aufgerufen. `refc` ist also Rest des Heaps der vorigen Funktion. Gemeinsame Zeichenketten aendern die Heap-Lage und damit diesen Wert. *Gemessen* ist nur das Symptom (W10x: dd/ed/tar, je eine djnz-Zeile); dass genau dieses Feld die Ursache ist, wurde nicht per Gastlauf bestaetigt (kein Budgetposten dafuer genutzt).

## 2. Aenderung am c2-Quelltext
`copy()`-Teilen steht jetzt hinter `#ifdef C2XSHARE` (Standard aus; Deklarationen `xtb`/`xih`, Rueckstellung je Funktion und `copy()`-Zweig). Das c2x ohne `C2XSHARE` ist quelltextgleich zum gemessenen Binary `c2x_c2.bin` (25636 B, no-flag 65/65, W10w), deshalb **kein c2-`bau`, keine Regression**. `tokcheck` c2/cc OK (Standard-c2 tokengleich).

## 3. xcc je Modul (`pipeline.py`: `xcc_je_modul`, `uspace.py`: `cc_von`)
`bau --xcc` ordnet jedem Modul ein `-X`-Flagwort zu oder `None`; `None` = einfaches `cc -O` (ausgeliefertes c2, kleiner als c2x). `None` genau dann, wenn das Hostmodell (`c2gegen.modell`, eigener Regelsatz des Programms) auf `work/bau/neu_s/<modul>.s` keine Stelle einer Regel mit c2x-Buchstaben findet. Module mit Stelle behalten die volle Buchstabenmenge des Programms (Verhalten wie bisher).
**Befund fuer `as` (Hostmodell, *gemessen*):** as_code **hat Stellen** (R5 x6, R32 x1), ebenso as_dir (R5, R32), as_expr (R5 x2), as_lex (R5 x4, R10 x2, R32); keine Stelle nur in **as_main** und **as_misc** (-> `cc -O`); as_tab (R42) und as_y (R5) sind `noopt`. Die Auswahl rettet **as_code also nicht**: das Modul braucht c2x (R5/R32) und c2x passt mit 61K Heap + 6,7 KB nicht in 64 KB (F5). Der Auftragspunkt 3 loest das as-Problem damit nicht.

## 4. Verbrauch / offen
Kein Gastlauf (kein c2-`bau`, keine Regression, kein `--xcc`-Bau); der Pfad `None` im Gast ist ungetestet (nur Hostpruefung der Auswahl). Naechste Schritte (nicht begonnen): (a) as_code: Sharing nur ab einer Heapschwelle (z.B. > 16K) einschalten, damit kleine Funktionen heap-gleich zum Original bleiben und `encode` Platz gewinnt (Annahme: spart ~5-7 KB; braucht c2-`bau` + Regression no-flag); oder (b) F6 auf `mutos-plus` beheben und as_code dort mit Sharing bauen; (c) as_code per Hostmodell (`--c2emu`) statt c2x. Nichts laeuft mehr.
