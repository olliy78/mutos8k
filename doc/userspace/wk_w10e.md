# W10e: Neubauten der sieben W10d-Programme, Karten-Ueberlappung bei `login ls passwd` behoben

Fortsetzung von `wk_w10d.md`. Alles *gemessen* (Gast, `pipeline.py alles NAME --c2emu --libc alt --ist ...`), ausser wo *Annahme* steht.

## 1. Neubauten nach der Anker-Korrektur

Je ein Bau pro Programm (`neu_c2_s` fuer `ls mv passwd login`, `neu_c2` fuer `cpp c1 as`), Wall-Clock je Bau in Klammern.

| Programm | vorher | nachher |
|----------|--------|---------|
| ls | bytegleich 8244 B | **bytegleich** 8244 B |
| mv | bytegleich 6820 B | **bytegleich** 6820 B |
| passwd | bytegleich 9124 B | **bytegleich** 9124 B |
| login | bytegleich 9904 B | **bytegleich** 9904 B |
| cpp | 3268 von 3323 Befehlen gleich, 13 Bloecke (`wk_w2.md`, `wk_w7e.md`) | 3268 von 3323, 13 Bloecke; Kopf text 13112 / data 3164 / bss 17780 (Original 13202 / 3164 / 17780) |
| c1 | 7057 von 7970 gleich, 90 Bloecke (`wk_w7e.md`) | 7057 von 7970, 90 Bloecke; Kopf text 30108 / data 5582 / bss 1824 (Original 30176 / 5582 / 1832) |
| as | 4137 von 5891 gleich, 724 Bloecke, `neu_c2.bin` 35364 B (`wk_w7s.md`) | 4137 von 5891, 724 Bloecke, 35364 B; Kopf text 21630 / data 13718 / bss 17724 (Original 22092 / 13706 / 17744) |

Befund: **nichts wurde schlechter, nichts besser** -- alle vier bytegleichen bleiben es, die drei Restfaelle haben dieselben Zahlen und Kopfwerte wie vorher.
Das ist zu erwarten (*Annahme*): die Anker betreffen nur den libc-Teil (Daten-/BSS-Lage der Stdio-Puffer), der beim Archiv-Bau (`libc_alt.py bau`, `wk_w10d.md`)
schon bytegleich war; die Befehlszaehlung vergleicht nur den Eigencode. Die BSS-Abweichungen von `c1` (-8) und `as` (-20) sowie `as`-data (+12) sind dieselben wie vor W10d
und kommen nicht aus den Ankern. Die Bau-Vorwerte stammen aus den Dokumenten, **nicht** aus einem eigenen Vorher-Bau (Budget); lokal vorhandene Altberichte
in `work/bau` waren veraltet und wurden nicht benutzt.

## 2. Karten-Ueberlappung (`--check login|ls|passwd`, Exit 1)

Ursache: `--vorschlaege` (Karte aus `uspace.py`, `karte_bauen`) schlaegt je einen `code`-Einstieg **mitten in einem Befehl** vor:
`login` 2064 (zwischen `L205E: SUB R15,#%001E` und `LDM`; Befehl 2062), `ls` 0800 (in `BIT %0014(R13),#15` ab 07FE), `passwd` 0B06 und 0B08
(in `LD %FFEE(R14),#%0020` ab 0B04). Das Listing meldet "Marke mitten im Befehl" und `Ueberlappung`. Die festgeschriebenen `k.txt` enthielten die Einstiege ebenfalls
(`code 2064` usw.); die Pruefung baut die Karte aber neu, daher kein Unterschied zwischen `main` und Gast. *Annahme*: erst ein neuerer `z8kdis`-Stand im
Emulatorprojekt liefert diese Vorschlaege (Ursache nicht gegen den alten Stand gemessen).

Behebung: `userspace/{login,ls,passwd}/karte_extra.txt` mit `ohne ADDR` (vorhandener Mechanismus, verwirft den Vorschlag). Danach
`--check login|ls|passwd|as|c1|mv|cpp` alle OK; `pytest -m "not gast"`: 214 bestanden. Die Bauten oben liefen mit diesen Dateien (die Karte aendert die Bytes nicht).

## 3. Offen

1. Restbloecke `cpp` (13), `c1` (90), `as` (724) wie bisher; Bau mit altem c2-Stand ist der naechste Hebel (Plan 52, W10).
2. Ob der neuere `z8kdis` weitere Einstiege mitten in Befehlen vorschlaegt, die nur noch nicht gepruefte Programme betreffen: `--check` laeuft nicht fuer alle Programme (nur die sieben hier gemessen).
