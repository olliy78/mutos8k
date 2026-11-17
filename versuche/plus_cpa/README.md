# versuche/plus_cpa -- Sonden fuer CP/A (Plan 48)

Quellen der Probeprogramme (M80-Syntax, `.Z80`).  Gebaut wird je Lauf durch `tools/plus/cpa.py` (`cpa.com(name, ordner)`), die `.COM` wird
**nicht** eingecheckt.  `hallo.mac`: BDOS-9-Ausgabe `HALLO MUTOS` und Sonde der M80-Namenslaenge (zwei Marken, die sich erst im 7. Zeichen unterscheiden).

    python3 -I tools/plus/cpa.py probe --arbeit /tmp/mplus/c1_1

`itest.mac` + `itest.py` (C1.7): ISR wie `mutos_io` (CTC 0DH, Vektor F7FAH) neben dem BIOS; Ticks/Luecken je Phase (READ, CONOUT, WRITE).
`python3 -I versuche/plus_cpa/itest.py --arbeit /tmp/mplus/c1_7/r1` (8 s; Exit 77 ohne Emulator/Werkzeugkette).  Der ISR muss bei 0130H bleiben (Logpoint des Treibers).
