# W10d: gleiche Anker-Fehler in sieben weiteren libc_alt-Bauten behoben, c2-Gegenprobe gelaufen (echo cat ed tar bytegleich)

Fortsetzung von `wk_w10c.md`. Alles *gemessen*, ausser wo *Annahme* steht.

## 1. Anker-Fehler in anderen `libc_alt/*.members`

`members_auto` setzt die Commons auf `bstart - 2 - 0x400` (Vermutung). Pruefung am erzeugten Quelltext: wo `flsbuf.s`/`filbuf.s` ein absolutes Literal
`ld r2,#%XXXX` oder die Form `#%OFF+__sibuf` enthalten, liegt der Originalpuffer *nicht* auf dem geratenen Anker (das Literal ist der echte Wert des
stdin-Puffers, `Anker+OFF` der des stdout-Puffers). Programme, deren Quelltext nur `#__sibuf`/`#__sobuf` enthaelt, stimmen mit dem Raten ueberein.
Betroffen waren sieben Programme (gemessene Originaladressen: stdin-Puffer / stdout-Puffer / `_environ` = stdout + 0x200):

* `as` CCEE / CEEE / D0EE (geraten CD02, Differenz 0x14), `c1` 8E96 / 9096 / 9296 (8EB2, 0x1C), `login` 26D4 / 28D4 / 2AD4 (26DE, 0x0A),
  `ls` 2A68 / 2C68 / 2E68 (2AE0, 0x78), `mv` 1AE0 / 1CE0 / 1EE0 (1B44, 0x64), `passwd` 25B2 / 27B2 / 29B2 (25BC, 0x0A).
* `cpp`: stdin-Puffer **8352**, stdout-Puffer **8022** (also *vor* dem stdin-Puffer; geraten 8152 / 8352), `_environ` 8552 unveraendert.

`_environ = stdout + 0x200` ist fuer die sechs ersten aus dem c0/c2-Muster *angenommen*, nicht einzeln gemessen; die Bytegleichheit des Archivs (unten) prueft es nur,
soweit `_environ` im Archiv vorkommt.

Folgefehler, die dabei verschwanden: `data.s` (Anfangswerte der `__iob`-Zeiger standen bei `login`, `ls`, `mv`, `passwd`, `c1` als rohe Bytes `BV %26;BV %D4`, jetzt `WV __sibuf`),
und `execv`/`getenv` bei `login`/`mv` benutzten `%1F6+__sobuf` statt `_environ`.
Behebung: je Programm `userspace/libc_alt/NAME.members.zusatz` (Mechanismus wie c2), danach `libc_alt.py members NAME` und `quelle NAME`.

Beleg (Wachposten, Gast-`as -u`, je 20-30 s): `libc_alt.py bau` fuer `as c1 login ls mv passwd cpp`: **0 Glieder abweichend** bei allen sieben (Text/Daten/BSS gleich dem Original).
`pipeline.py --check`: `as c1 mv cpp` OK; `login ls passwd` melden `Ueberlappung 1/1/2` in der Karte (Exit 1). Das ist unabhaengig von dieser Aenderung
(die Pruefung benutzt nur das Originalabbild und die Karte, nicht `libc_alt`) und wurde hier nicht angefasst *(Annahme: schon vorher so; nicht gegen den alten Stand gegengemessen)*.
Die uebrigen Programme haben ihre Anker richtig (nur symbolische Operanden).

## 2. c2-Gegenprobe

**Befund vor dem Lauf:** das mitgebrachte `neu_c2.bin` (18956 B) war **veraltet**: `_filbuf` lud `#%5126`/`#%5326`, aber `_flsbuf` noch `#%513A`/`#%5194`
(alte Operandenformen), die Puffer ueberlappten also weiter. Erster Gastlauf `echo cat ed tar` mit diesem Stand: `echo`: Endlosausgabe bis `no space on dev 4/0`,
danach haengt die Sitzung (Abbruch durch `timeout` nach 75 min). Ursache war nicht die c2-Logik: der W10c-Neubau enthielt das behobene `flsbuf` nicht
(die Angabe in `wk_w10c.md` Abschnitt 3 zu `_flsbuf` im neuen Listing war nur fuer `_filbuf` gemessen).

Neubau (`libc_alt.py bau c2`, dann `pipeline.py alles c2 --c2emu --libc alt --ist neu_c2`): `neu_c2.bin` 18956 B; im Listing laden `_filbuf` **und** `_flsbuf` jetzt
`#%5126` (stdin) und `#%5326` (stdout), `crt0` speichert `_environ` bei 5526.

Zweiter Lauf `c2gegen.py lauf echo cat ed tar --c2x ... --c2o ...`, Exit 0, Gast 72 + 240 + 152 s:

    echo  s  1257 B  sn  1257 B  IDENTICAL
    cat   s  2864 B  sn  2864 B  IDENTICAL
    ed    s 46511 B  sn 46511 B  IDENTICAL
    tar   s 38687 B  sn 38687 B  IDENTICAL

Alle `MOD.cmp` leer: unser c2 liefert aus dem c1-Ausgang byteweise dasselbe wie das ausgelieferte `/usr/lib/c2`; Zweitlauf (`.sm`), Shell-Umlenkung (`.sp`),
zweiter ausgelieferter Lauf (`.sb`) und ausgelieferte Binaerdatei von `/mnt` (`.so`) stimmen ebenfalls ueberein. Die 28 bekannten Differenzbloecke im Eigencode
(4609 von 4717 Befehlen gleich) wirken sich auf diesen vier Eingaben **nicht** aus; ein Logikfehler wurde nicht gefunden. Dass sie auch bei anderen Eingaben folgenlos
sind, ist damit nicht bewiesen (vier Module).

## 3. Offen

1. Die 28 Differenzbloecke in `c2` bleiben; weitere Module (`c0`, `c1`, `sh`, Kernel) wuerden die Abdeckung erhoehen.
2. `pipeline.py --check` fuer `login`, `ls`, `passwd`: Karten-Ueberlappung (gegen den alten Stand pruefen).
3. Programm-Neubauten (`alles NAME --libc alt`) der sieben korrigierten Programme sind nicht gelaufen; `bau` bestaetigt nur das Archiv.
