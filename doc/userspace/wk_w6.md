# Auftrag W6 (Plan 52): `c1` (`/usr/lib/c1`), der Codegenerator

Branch `us-wk-w6`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht *Annahme*.  Original: 35774 B (text 30176 = 0x75E0, data 5582, bss 1832).

## Teil 1: Karte und libc-Teil

**Karte** (`userspace/c1/karte_extra.txt`, `--check c1` OK, Ueberlappung 0, ungueltig 0).  W0 meldete 119 Ueberlappungen.  Ursache (gemessen): die Vorschlaege von `z8kdis` lesen Konstanten (`0x0200`, `0x0702` ...)
als Zeiger auf Code; ohne die Schalttabellen erreicht der Ablauf von `code 0` nur 9,7 % des Textes.  Danach:
* `db 5A40 6987`: die Codetabellen im Text (Mustertexte 5A40-631B, `optab`-Saetze 631C-6987).
* 18 `dwc`-Zeilen: Schalttabellen der Daten (Hash-Schalter `DIV RR2,#n` haben n Eintraege, Bereichsschalter `SUB/CP #k ; JR UGT` k+1): 7624 (4), 762C (0x5B), 76E2 76E6 (je 2), 76EA (8), 7B4C (11), 7B62 7B84 (17), 7BA6 (8), 7C6E (4),
  7C76 (9), 80CA (5), 80D4 (8), 80E4 (2), 80E8 (3), 80EE 80F2 (je 2), 80F6 (10).  Aufeinanderfolgende Tabellen schliessen lueckenlos aneinander an (Gegenprobe der Zaehlung).  Damit 73,3 % Code, 8609 Befehle.
* 3 `code`: 3578 und 4462 (`JP` hinter einem `JR`, nie erreicht), 7588 (`brk`, ohne Aufrufer; Teil des libc-Gliedes `sbrk`).
* 15 `code` in `doprnt` (Tabelle Formatbuchstabe/Ziel bei 8A3E, wie bei `c0`) und 5 `ohne` (7400 7408 740A 7472 7474: Zeigerkonstanten, die mitten in Befehle fallen).
* Atof: 57CE-5A40 wird als Code erkannt (EPA-Befehle dekodiert der Disassembler); Datenmitte 75A6 ist ein Operand, keine Marke.

**libc-Teil** (`userspace/libc_alt/c1.members` + `.zusatz`): 30 Glieder, davon 3 G (`flsbuf`, `endopen`, `malloc`: `bau c1` 0 Glieder abweichend).  Handkorrekturen (`zusatz`):
* `doprnt code=6C2C,6C32,6C48 data=8A3E:8A88` (Tabelle Formatbuchstabe/Ziel und `null` an 8A3E, 74 B; Sprungziele wie `c0` 2 B spaeter als automatisch).
* `data` (`__iob@8A88`, `__lastbu@8B28`; `printf`/`flsbuf` greifen auf iob+14 = 8A96 zu) und neues datenloses Glied `ctype` (`__ctype_@8B2A`, 130 B bis 8BAC; *Annahme*: von `atof` gebraucht, dessen Text nicht in den Gliedern steht).

## Teil 2: die Codetabellen (`table.s`, `cvopt`)

**Entscheidung (Annahme: so entstand die Tabelle im Original; belegt ist nur das Ergebnis):** weder die Z8000-`table.s` noch das MUTOS-`cvopt` sind vorhanden.  Das c1-Abbild hat aber genau das V7-Muster (Mustertexte, 6-Byte-`optab`-Saetze, `struct table`
in den Daten).  Deshalb:
* `tools/userspace/cvopt_z8k.py` ist eine Portierung von `original/unix-v7/usr/src/cmd/c/cvopt.c` (gleiche Zustandsmaschine) und schreibt statt PDP-11-`as` das Modul im Dialekt des MUTOS-`as` (`BV`/`WV`/Marken); es laeuft auf dem Host
  (`uebersetzen`), weil `cvopt` im Gast nicht gebraucht wird; das Ergebnis `userspace/c1/table_z8k.s` ist eingecheckt (Test `tests/test_userspace_wk_w6.py` prueft, dass es die Uebersetzung von `table.s` ist).
* `userspace/c1/table.s` (1122 Zeilen) ist die **ruecklesene** Quelle im V7-Format (`quelle`: Umkehrung von cvopt auf dem Abbild; Kommentare, Gruppen- und Vorlagennamen `crNN`/`efNN`/`ccNN`/`spNN`/`tNNNN` erfunden; jede Vorlage steht dort, wo ihre
  Zeichenkette im Abbild beginnt; spaetere Verwender nutzen die V7-Klammerform `%[tNNNN:]` / `% [tNNNN]`).
* Beleg (gemessen): `cvopt_z8k.py pruefen` -- Modell-Text 3912 B (5A40-6988) und Modell-Daten 400 B (88AE-8A3E, `regtab` 47, `efftab` 20, `cctab` 27, `sptab` 4 Eintraege) **gleich dem Abbild**; zusaetzlich Gastlauf: `as -u` uebersetzt
  `table_z8k.s` ohne Meldung zu Text 3912 B, Daten 400 B, und alle Worte gleich dem Abbild ausser den Relokationsworten (Wert = Abbildwert - 5A40; 0 Abweichungen).

Abweichungen des Z8000-Formats von V7-`cvopt` (alle gemessen am Abbild; im Kopf von `cvopt_z8k.py`):
1. `X Y T` setzen `snlflg` nicht mehr (die Zeichenketten behalten das `\n` nach Zeilen mit diesen Buchstaben).
2. Kein abschliessendes Nullwort am Dateiende (die letzte Gruppe laeuft unmittelbar in `freopen` bei 6988; V7 schreibt `0`).
3. Der Gradbuchstabe `c` nimmt Typbuchstaben (`%cl`: Grad 8, Typ 8); zusaetzliche Gradbuchstaben fuer die Werte 6, 7, 11 (`y`, `x`, `q`, **Namen erfunden**); `i` (12) und `1` (5) kommen im Abbild nicht vor.
4. Tabelleneintraege nennen Gruppen auch **mitten in einer Gruppe** (cctab: 16 Eintraege auf 692C); V7 legt vor jeder Marke ein Nullwort (`=.+2; 0`), hier steht dafuer die Zeile `name=.` (Marke ohne Nullwort).
5. Literale `S`/`R`/`%`/`\` brauchen den Fluchtstrich `\x` (das Abbild enthaelt Bytes `S`; V7 behandelt `S` immer als Teilbaum-Makro) -- *Annahme*: das Original-cvopt hat `S` anders buchstabiert.
6. Datenzeilen der Tabelle: `wv op,gruppe` (PLZ/ASM) statt `106.;\tcr106`.
Die Makrobuchstaben der Mustertexte entsprechen V7 (`A1 A2 B1 B2 BE BF C1 C2 F H R R1 S I`; Bytes `A B C D L P E F G H I J K M`; Bit 7 = vorangestelltes Tabulatorzeichen).  Der tote Zweig `M -> N` des V7-Kommentars ist falsch (V7 hat kein `case 'M'`).
Verbleibend fuer den Gesamtbau: `table_z8k.s` als Quelle zwischen `c13` und den libc-Gliedern in `userspace/c1/` einbinden (Teil 3).

## Teil 3: Gesamtbau (Stand: erster Durchlauf, **nicht abgeschlossen**)

* `userspace/c1/`: `c10.c c11.c c12.c c13.c c1.h` sind **unveraenderter V7-Text** (Platzhalter fuer die Rekonstruktion), dazu `atof.s` (Kopie von `userspace/libc/atof.s`, EPA-Code, vom Gast-`cc` nicht uebersetzbar) und `table_z8k.s`;
  `link.txt` legt die Linkreihenfolge fest (`c10 c11 c12 c13 atof table_z8k`, danach `libc_alt`); `pipeline.py quelle_lesen` liest `link.txt` (neu, auch `.s`).
* `alles c1 --c2emu --libc alt --ist neu_c2` (13 min): V7-Text uebersetzt und bindet.  Gemessen: text 25036 (Original 30176), data 4250 (5582), bss 54 (1832); Befehle original 7970, gebaut 6747, davon 4022 uebereinstimmend,
  853 Differenzbloecke (Bericht `userspace/c1/work/bau/neu_c2.bericht`).  Der Unterschied ist erwartungsgemaess gross: die V7-Codeausgabe schreibt PDP-11-Mnemonik, nicht Z8000.
* **Bindefehler behoben (gemessen):** die Ursache lag nicht an Symboltyp oder Abschnitt von `table_z8k.s` (identisch mit `libc_alt/c1/data.s`: `I` / `G` / `name L` / `name:`), sondern in `pipeline.py cmd_bau`: die zweite Runde (`--c2emu`) baute
  ihre Modulliste nur aus den `.s` der `.c`-Module (`cc -S`); `atof.s` und `table_z8k.s` fehlten dort, daher `Undefined: _regtab _efftab _cctab _sptab _end` (`_end` kommt aus `sbrk`, das nur ueber die Tabellen-Module hereingezogen wurde).  Jetzt werden `.s`-Module aus `link.txt` unveraendert (ohne c2-Modell) an ihrer Stelle der Linkreihenfolge in die zweite Runde uebernommen; ohne `.s` in der Quelle bleibt der Pfad unveraendert.
  Ergebnis: bindet, 33614 B (text 28948, data 4650, bss 1126; Original 30176/5582/1832), 6746 Befehle gegen 7970, 4027 gleich, 853 Bloecke, 383+193 s.
* Danach je Funktion `c10.c..c13.c` an das Binary angleichen (Z8000-Codeausgabe, `opdope` 14 Eintraege, 12 Nicht-V7-Funktionen, Registervariablen wie in `wk_w4.md`, `c13.c`-Daten gegen 75E0..).
  **Keine** Funktion ist bisher rekonstruiert; keine neuen c2-Regeln (R230-R259 unbenutzt).

## Teil 4: Regression und c10.c (W6b)

**Regression (gemessen, sequentiell im Gast, nach der `pipeline.py`-Aenderung):** `sh` (`alles sh --c2emu --variante v7fix`), `ed`, `tar`, `cc`, `ld` (`--ist neu_c2_s`) und `c0` (`--ist neu_c2`) ganzdatei `cmp`-gleich dem Original.  Nur `c1` hat `link.txt`; fuer alle anderen bleibt der Pfad unveraendert.

**c10.c (Stand: neu_c2 gebaut 33764 B, 6743 Befehle gegen 7970, 4080 gleich, 844 Bloecke; vorher 4027/853).**  Funktionen, die bis auf Datenadressen (Layout noch unvollstaendig) befehlsgleich sind:
* `main` (0030): Z8000-Modulkopf mit 6 `printf` (nur das erste mit `modname`), kein `fltused`, `printf("end %s\n", modname)`; die Verschmelzung der Stack-Slots macht das c2-Modell von selbst.  Offen sind nur Speicheradressen (`coremax` usw.: BSS-Layout).
* `comarg` (1B3E): Strukturkopie als Z8000-Code (`ld r0,#n` / `dec SP` / `dec rK` / `lddr`), kein `nstack`, kein `lsptab`-Zweig, `flagp` unbenutzt; `register i` vor `size` (belegt r11, `size` liegt in r10).  Nicht-V7-Hilfsfunktion `zreg` (21D6, Name *Annahme*; Registernummer 0..5 -> 2..7, 6..7 -> 0..1) am Dateiende (Binary: nach den c10-Funktionen, Reihenfolge noch nicht angeglichen).
* `sdelay` (1A22): nur `PLUS` wird verfolgt (kein `STAR`); 1 Block offen: Original `TEST R2` hinter `LD R12,R2`, gebaut `TEST R12` (R5-Modell; Quellvariante ungeklaert).
* Neue Daten: `char modname[] "c_"` (7B3E, 3 Bytes + Fuellbyte; *Annahme*: steht in `c11.c` vor `max`, da die Daten dort beginnen), in `c1.h` deklariert.
**Offen (gemessen am Listing, nicht rekonstruiert):** `match` (0186) ist im Original anders aufgebaut (Sonderfall `LONG` mit Operatorliste `+ * , I H J . L - K`, andere Bitmasken); 9 Null-initialisierte Int-Flags in den Daten (760C, 760E, 7610, 7614, 7616, 761A..7622) und 5 weitere ab 7B42; `rcexpr`, `cexpr`, `doinit`, die uebrigen Nicht-V7-Funktionen (1EFC, 1F66, 2028, 21FC, 2228); der V7-`movreg` existiert im Original anderswo (die Zuordnung 2104 -> `movreg` ist falsch: 2104 druckt Registernamen `r%d`/`rr%d`/`f%d`/`rl%d`).  Keine neuen c2-Regeln.

## Teil 5: c10.c, Fortsetzung (W6c)

Alles *gemessen* am Listing `userspace/c1/c1.lst` und am Bericht `userspace/c1/work/bau/neu_c2.bericht`; Namen mit *Annahme* sind erfunden.

**Daten/BSS von c10 (Ziel 1).**  Das Original-Datenlayout 75E0..: Fuellwort, `maprel` (75E2), `notrel` (75EC), `czero` (75F6), `cone` (75FC), `sfuncr` (7602, 10 Byte, Feld `nloc` = 760A),
danach Null-initialisierte Int-Flags **in den Daten** (`int x 0;`, nicht BSS): 760C 760E 7610, `nreg` (7612, Wert **5**, V7: 3), 7614 7616, `isn` (7618, 10000), 761A 761C 761E 7620 7622; erst danach die Schalttabellen (7624..).  In `c11.c` stehen hinter `modname` (7B3E) fuenf weitere Flags 7B42..7B4A (vor der Schalttabelle 7B4C).
`cregtab` liegt im BSS bei 8BD6 (Vergleiche `CP R8,%8BD6` ohne `#`), direkt dahinter die Tabelle der Gleitkommakonstanten bei 8BD8 (50 Eintraege zu 14 Byte = `struct ftconst`, Zaehler 760C).
Bedeutung der Flags (aus den Verwendern; Namen *Annahme*): 760C `nfpool` (naechster freier Eintrag der Tabelle bei 8BD8), 760E/7610 in `rcexpr`/CALL: Registerpaar-Ausrichtung (gerade/ungerade) der Funktionsergebnis-Register, 7614 `rlused` (`preg` hat einen Byteregisternamen `rl%d` gedruckt),
7616 in `rcexpr`/cctab gesetzt, 761A `wregf` (naechster Registername als Wortregister `r%d`), 761C `bregf` (Byteregister `rl%d`), 761E `lregf` (Langregister `rr%d`), 7620 in `cexpr`/Namensausgabe, 7622 sperrt `delay` in `rcexpr` (von `cexpr` am Anfang auf 1 gesetzt).  Die Flags 760E, 7610, 7616, 7620, 7622 heissen bis zur Rekonstruktion von `cexpr` `zf1 zf2 zf4 zf8 zf9`, die 7B42..7B4A `yf0..yf4` (in `c11.c`/`c12.c` noch nicht benutzt).

**`match` (0186).**  V7-Text, aber: kein `lsptab`-Zweig; `op`, `d1`, `p2`, `p1`, `tree`, `opt` sind Registervariablen (r13..r8 in dieser Reihenfolge; die Reihenfolge `p2` vor `p1` ist die einzige, die r11/r10 trifft), `d2` und `dope` Stack (`d2` bei FFF2, `dope` bei FFF0);
vor der Wegnahme der Umwandlung: `tree->type==LONG` mit `op` in `/ * % /= *= %= << <<= >> >>=` (10 Operatoren, Reihenfolge `DIVIDE TIMES MOD ASDIV ASTIMES ASMOD LSHIFT ASLSH RSHIFT ASRSH`) oder `p2->op==ITOL && p2->tr1->type==UNSIGN` lassen die Umwandlung stehen (leere `if`-Anweisungen vor den beiden V7-`if`s);
`notcompat` bekommt nur zwei Argumente (kein `op`).  Die in der Doku "Operatorliste `+ * , I H J . L - K`" sind die ASCII-Buchstaben der Werte 43 42 44 73 72 74 46 76 45 75.

**Nicht-V7-Funktionen (gemessen entschluesselt; Namen *Annahme*).**
* `1EFC` ist das **echte `movreg`** (nicht 2104): `movreg(r0,r1,tree)`, gibt `ldl rr%d,rr%d` / `ld r%d,r%d` / `fld f%d,f%d` aus (Ziel zuerst), Registernummern ueber `zreg`.
* `1F66` `ltod(l,p)`: Langzahl nach 4-Wort-Double (Vorzeichen, 11 Bit Exponent mit Bias 1023); `2028` `ftol(p)`: Double nach Long (Vorzeichen wird nicht behandelt; Fehler "floating to large for long"); `21FC` `fcopy` (4 Worte kopieren);
  `2228` `outfp(p,neg)`: Gleitkommakonstante ausgeben (`L%d:` und `WV %%%x;...`) und in der Tabelle bei 8BD8 merken (ruft zwei Hilfsfunktionen in c12, 3C58/3CAA: derzeit leere Platzhalter `fphead`/`fptail` am Ende von `c12.c`).
* `2104` `preg(tree,reg)`: druckt den Registernamen: `FP` fuer 14, sonst je nach Flags/`isfloat`: `r%d`, `rr%d` (long), `f%d` (float, `nfloat++`), `rl%d` (Byteregister, nur bis 8, sonst Fehler "byte-operation on register greater 8").
* `21D6` `zreg` (Registernummer 0..5 -> 2..7, 6..7 -> 0..1).
* In c11/c12 (noch nicht rekonstruiert, als Funktionen am Dateiende der Quelle): `2DAE` `bitnum` (Bitnummer einer Einbitkonstanten, sonst -1), `2EE4` `bitop` (AND/OR/ASAND/ASOR mit Einbitkonstante -> neue Operatoren 82/81/84/83), `577A` `regnode(class,type,reg)` (NAME-Knoten fuer ein Register).

**`rcexpr` (039E), Aufbau im Original (Rekonstruktion in `c10.c`).**  Kein `RELAT`-Kurzschluss und kein `ANDN`; Schalter ueber `tree->op` (Hash mit 4 Eimern `op%4`, Tabelle 7624): `STRASG INIT RFORCE SEQNC CALL`, die Langschiebungen (`ASLSH LSHIFT RSHIFT ASRSH`, ohne Operatoraenderung),
`DIVIDE MOD ASDIV ASMOD` (nur bei `UNSIGN`) und `TIMES ASTIMES` (`pow2`; bei geaendertem `op` zurueck nach `again`), `OR ASOR` / `AND ASAND` (`bitnum`/`bitop`).  `RFORCE` gibt bei Typwechsel nach `float`/`double` `fclr f0` aus.
`CALL` rettet die lebenden Register `0..reg-1` (`push @SP,r%d`, bei `nfloat` auch `dec SP,#8 / fldd`), uebergibt die Argumente, ruft sich mit `CALL2` und `tr2=0` rekursiv (Register 0), poppt, bewegt das Ergebnis nach `reg` (`movreg(0,reg,tree)`) und kehrt mit `reg` zurueck.
Danach (neu): STAR-Operanden, die kein Registername sind, werden mit `rcexpr(tnode(LOAD,...))` in ein Register geladen und durch einen REG-Knoten ersetzt (`regnode`), `reg` rueckt weiter; `delay` nur, wenn Flag 7622 frei; Rueckgabe von `cexpr` gilt als Erfolg ab `>= -2`;
`fixup` druckt fuer `sptab` `push%c @SP,<reg>` / `dec SP,#8; fldd`, fuer `cctab` `test%c <reg>` / `fcpzx f%d` (nicht bei den 9 `AS`-Operatoren mit Byte-/Nicht-Long-Operanden und nicht bei Long-Zuweisungsoperatoren ausser `%= = &= |= ^=`).

**`cexpr` (0B9E, 2682 Byte) ist NICHT rekonstruiert.**  Befund: Der Rahmen hat 22 Byte Stack; es gibt `c`, `opd`, `reg`, `p1=tree->tr2` nur fuer `!(op&0400)`; relationale/logische Werte bauen Marken ueber die Hilfen 2F6C (`cbranch`), 31E8, 3310 (`label`), `isn` (7618) auf (kein `branch`-Aufruf in V7-Form);
die Makroexpansion (`loop:`) ist eine **Z8000-Neufassung**: `putchar` ist eingebettet (`BITB 8A96`/`DEC 8A92`), Ausgabebuchstaben 9 `b` `d` `s` `l` `k` `+`, Schalter ueber Zeichen 0..0x5A mit Sprungtabelle 762C (0x5B Eintraege, `L15EC` = Standardziel), Zeichenketten fuer `FP`, `@SP`, `#%%`, `#%%%x`, `rr0 rh0 rh%d rq4 rq0`; die `.data/.text`-Ausgabe der Gleitkonstanten ruft `outfp`.
Jede V7-Zeile von `cexpr` muss gegen diese Neufassung neu gelesen werden; das ist der groesste offene Block von c10.

**Verbleibend (c10):** `cexpr`, `doinit` (Z8000-Ausgabe, 648 Byte), Reihenfolge der c10-Funktionen im Binary (Nicht-V7-Funktionen stehen schon an der richtigen Stelle).
**Fuer c11-c13:** die obigen Funktionen `bitnum`, `bitop`, `regnode`, `fphead`, `fptail` stehen als Platzhalter am Ende von `c11.c`/`c12.c` (Binary: 2DAE, 2EE4, 577A, 3C58, 3CAA) und sind an die richtige Stelle zu verschieben; Flags `yf0..yf4` (7B42..7B4A) werden in 3C58..3CAA, 3A50.. (c12) benutzt; `isfloat` (28EE) liefert im Original `'f'`, `'l'` oder 0 (V7: nur `'f'`).

**Stand nach dem Bau (gemessen, `alles c1 --c2emu --libc alt --ist neu_c2`, 4 Durchlaeufe, `--check c1` OK, `pytest -m "not gast"`: 213 bestanden, 1 Fehler `test_bau_alle_kennt_genau_die_fertigen_disketten` -- vergleicht das Skript mit dem Ordner `disks/gebaut`, der in diesem Worktree leer ist, nicht von W6c beruehrt).**
Gebaut 30820 B Text (Original 30176; `cexpr`/`doinit` sind noch V7-Text), Daten 5102 (5582), BSS 1826 (1832); Befehle 7239 gegen 7970, **4790 gleich** (vorher 4080), 786 Bloecke (vorher 844).
* Befehlsgleich bis auf Datenadressen (die erst mit `cexpr` verschwinden, weil dessen Schalttabellen 762C.. und Zeichenketten vor den Zeichenketten der ersten Funktionen liegen; Zeichenketten stehen im Original um 0x86 weiter hinten): `main`, `movreg` (1EFC), `ltod` (1F66), `fcopy`, `outfp`, `zreg`, `preg` (2104; 1 Befund siehe unten), `bitnum`/`bitop`/`regnode` (nicht verglichen: am Dateiende).
* `rcexpr` (039E): bis auf Datenadressen und **zwei Stellen, die das c2-Modell erzeugt**: (a) `if (r = delay(...))` bleibt im Original `ld r13,r2 ; test r2` (`TEST R13` gebaut; ebenso `match` 2 Stellen, `sdelay` 1 Stelle: 4 Stellen), (b) der Hash-Schalter am Anfang hat im Original `xor r2,r2`, das Modell setzt `exts rr2` (R45).  Beides sind bereits bekannte Regeln, die fuer andere Programme abgeschaltet werden (`C2_AUS` in `tools/userspace/pipeline.py`: `pr` `R5T`, `ed` `R45`);
  der Eintrag `"c1": {"R5T", "R45"}` fehlt noch und wurde **nicht** gesetzt (Aenderung am Werkzeug war in dieser Sitzung nicht erlaubt); mit ihm verschwinden 5 Bloecke.  Keine neue c2-Regel noetig, keine Quellvariante gefunden.
* `match` (0186): ausser den Datenadressen nur die `TEST R2`-Stellen (siehe (a)).
* `ftol` (2028): 1 Block: Original `ld r2,p ; xor r10,r10 ; ld r11,@r2`, gebaut `xor r10,r10` davor (Quellvariante ungeklaert; `sgn` ist im Original ein toter Speicher).
* `preg`: Original prueft `if ((c = isfloat(t))=='l')` (kein `xorb` zwischen `ldb` und `cp`).

**BSS-Reihenfolge (gemessen; wichtig fuer c11-c13).**  `as` schreibt jede im Kopf `c1.h` deklarierte Skalarvariable als `X name W` in die Symboltabelle; `ld` legt die Commons in dieser Reihenfolge an (auch fuer Namen, die gleichzeitig mit Anfangswert in den Daten definiert sind: sie verbrauchen dann zusaetzlich BSS).  Original-BSS ab Anfang: `namsiz line nerror nstack` (B+0..B+7), `funcbase curbase coremax` (B+8..B+D), `fczero` (14), `totspace` (4), `xlab1 xlab2 xop xzero` (8), `cregtab` (B+28), `fptab` (B+2A, 700 B), `nfloat` (B+2E6).
Daraus: `nreg`, `isn` und `lsptab` gehoeren **nicht** in `c1.h` (`c11.c`/`c12.c` deklarieren `extern int nreg, isn`, `lsptab` steht vor `cexpr` in `c10.c`), `nfloat` steht nicht im Kopf, sondern in `c10.c` hinter `fptab` (und als Deklaration in `c11.c`).  Zwischen `nfloat` (B+2E8) und der libc (B+6E8) liegen im Original 1024 Byte weiterer BSS-Variablen (c11-c13; nicht zugeordnet).
Deshalb stehen jetzt auch alle BSS-Zugriffe in `main` und `rcexpr` an den Original-Adressen.

**Offen:** `cexpr` (0B9E, 2682 B, Befund oben), `doinit` (Z8000-Ausgabe), `c1.h`/Datenadressen (Zeichenketten und Schalttabellen verschieben sich mit `cexpr`), Eintrag `C2_AUS["c1"]`.

## Teil 6: `cexpr` und `doinit` (W6d)

Alles *gemessen* am Listing `userspace/c1/c1.lst` (Original), soweit nicht *Annahme*; Namen erfunden = *Annahme*.  Die Ausgabe ist im Dialekt des MUTOS-`as` (`BV`/`WV`/`LV`, Register `r%d`/`rr%d`/`rq%d`/`rh%d`/`f%d`).

**`cexpr` (0B9E).**  Rahmen 22 Byte (11 Stack-Slots FFF2..FFDE, absteigend in der Deklarationsreihenfolge; FFF2 = `fl` nur in `M`, FFEE ungenutzt), Registervariablen r13 `p`, r12 `p1`, r11 `tree`, r10 `r`, r9 `k`, r8 `ctable`.
`p` und `tree` zeigen bis zur Schleife auf denselben Knoten (`p = tree` am Anfang, `tree = p` danach); wer von beiden im Original steht, ist an den Registern abzulesen und so nachgebildet.
* Vorspann: `zf9=1; lregf=0; wregf=0` (7622, 761E, 761A); `c = p->op`; `if (!(c&0400)) p1 = tree->tr2` (Test auf **`c`**, nicht auf `opd`); RELAT/LOGAND/LOGOR/EXCLA-Zweig und `QUEST` wie V7, aber **Misserfolg = -3** (nicht -1) und bei `QUEST` kein `nstack`, `r` ist Registervariable, `movreg` nur bei `p1->tr2->op != CALL`.
* Neu: bei Zuweisungsoperatoren (`opd&ASSGOP`) auf `char`-Registervariable (`tr1->op==NAME`, `class==REG`) wird der Typ auf `int` gesetzt (auch bei `p1`); die V7-Sonderbehandlung `char = *intreg++` fehlt.
* `x+(-n)`: `c==PLUS||c==ASPLUS`, `p1->op==CON`, `-16 <= value <= -1` -> `value = -value; c = ++p->op`.
* Tabellenwahl: `efftab` wird bei `cctab` **nicht** versucht, wenn `c` in `INCAFT DECAFT MOD`, bei `type==LONG` und `AND OR EXOR`, oder bei `ASSIGN CALL LOAD 89 CALL2` (89: im Kopf `c1.h` ohne Namen).
* Gleitkommakonstanten: statt `.data/.text`-Ausgabe `fpfind(p)` (neu, 229E, siehe unten) und sonst `outfp(p, 1)`.
* Makro-Expansion: Schalter `switch (c)` mit Sprungtabelle 762C (0x5B Eintraege, Standardziel `putchar(c)`), `putchar` eingebettet.  Buchstaben (Reihenfolge der Faelle = Codereihenfolge):
  `\n` setzt `bregf=0`; `\0` Ende (`MOD`/`ASMOD`: `reg--`, bei `LONG` nochmals); `@` `#` `"` drucken `@SP`, `#%`, `@`; `A`/`B` Adresse (`+` -> Flag 1, `'` -> `wregf=1`, `zf8=1` bei `INCAFT/DECAFT` ueber `STAR` mit `tr1->nloc<8`; `pname(p,c)`);
  `M` `prins(op, fl, c, instab)` (neu: `fl` = Typ FLOAT/DOUBLE); `T` (`k` statt Byte-/Typbuchstaben, wenn `dcalc(p1,0)<6` und kein Blatt) faellt in `C` (Byte/Typ von `p1` oder `tree`), `P` (`k` wenn `dcalc(p2,0)<6`) faellt in `D` (`p2`): `b` + `bregf=1` fuer `CHAR`, dann `d`/`s`/`l` je nach `isfloat`;
  `L` `l` wenn `isfloat==l`, `V` `f` wenn `isfloat==f`; `G K H` Teilbaum (wie V7 `F S H`, aber ohne `collcon`/`lsptab`, `!` setzt `r=k=1`, Zielregister `r += reg1|reg|areg`, `zf1/zf2` zaehlen CALL-Umwandlungen, `CALL`/`CALL2` ohne Nachbewegung, `movreg` nur bei Abweichung bzw. mit `k` auf `reg+1`);
  `U` (`lregf=1`) / `I` / `J` / `N` Registername (`I`: `-` -> `r--` und bei `isfloat==l` nochmals; `+`; `'` -> `wregf=1`; Pruefung `(FLOAT||DOUBLE)&&r>=7 || r>nreg`; `N` = Register 6) ueber `preg`; `E R O Q F S Y W` feste Texte (`r1`, `f%d`+`nfloat++`, `rr0`, `rh0`, `r0`, `rh%d`, `rq4`/`rq0`, `SP`); `Z` `#%%%x` mit `~mask`; `X` Vorzeichen-/Nullerweiterung (`extsl rq`, `xor`, `exts rr`; nicht bei `TIMES/ASTIMES`).
* Nicht uebernommen aus V7: `-`/`)` (`-(sp)`), `#1`/`#2`, `T`/`V`/`X`-Langvergleich der PDP-11-Ausgabe (`sxt`, `adc`); `dbprint`.
* Quellformen, die das Original erzwingt (gemessen am Ergebnis): `if (!(c&0400))` und `if (!(opd&LEAF) && ...)` ergeben `BIT mem,#8`, `(x&LEAF) != 0` dagegen `AND` + `JR Z`; `printf(fmt, fval)` mit `int fval[4]` (vier einzelne `PUSH`, bei `double` kaeme `EXT4F`); `if (r1==r0)` in `movreg` (R0 laedt r1 zuerst); die Marke `preg:` geht nicht, weil `preg` eine Funktion ist (im Binary vermutlich anders benannt).

**`fpfind` (229E, 86 Byte; Name *Annahme*; die Zuordnung `229E` = `max` in `v7zuordnung.txt` ist falsch, `max` liegt bei 22F4).**  Sucht in der Gleitkommatabelle `fptab` (`nfpool` Eintraege zu 14 Byte) einen Eintrag mit gleichen vier Wertworten (Offset 6..12); liefert dessen `value` (bei `outfp` negativ gespeichert) oder 0.  Steht in `c11.c` vor `max`.

**`doinit` (1C74).**  `chrf=0`; `CHAR` -> `printf("BV")`, `chrf=1`; Schalter 76EA (0..7: `INT UNSIGN`, `FLOAT DOUBLE`, `LONG`); Ausgabe `" %%%x\n"` (Zeichen) bzw. `"WV %%%x\n"`, `WV <name>`, `LV %%%lx`; `FTOI`/`FTOL` ohne `SFCON`; Gleitkomma immer 4 Worte (`ltod`, `fcopy`, `WV %x;WV %x;WV %x;WV %x`), `CON`/`LCON` als Nullkonstante; Zweig `yf0` (7B42) mit `getblk(14)` und `outfp(tree,0)`.
Der Aufruf `fcopy(tree->value, &fval)` im `yf0`-Zweig steht so im Binary (vermutlich nie ausgefuehrt, `yf0` wird nie gesetzt).  `ftol` wird in `doinit` vor seiner Definition (`long`) als `int` benutzt (`EXTS RR2`), wie im Original.  Fehlertext `"illegal initialization\n"` (mit Zeilenende).

**`sreorder` (16D0, 692 Byte).**  V7-Text bis zum Schalter, dann: kein `ANDN`/`ASANDN`; `ASLSH`/`ASRSH` lassen `p->type==LONG` in Ruhe (`return(0)`); `isfloat(p->tr2)=='f'` statt `isfloat(p->tr2)`; der innere Schalter ueber `p->tr2->op` hat zusaetzlich die Operatoren **107 und 108** (nicht in `c1.h`, *Annahme*: Z8000-Schiebungen), `LSHIFT RSHIFT 107 108` pruefen `p->tr2->type==LONG` (dann `break` -> `goto OK`), `TIMES` springt nach `pow2` an der Schiebungspruefung vorbei; Vergleich `p->tr1->nloc==p1->nloc` (V7: umgekehrt).
Die Schalter sind beide Hash-Schalter mit 2 Eimern (Tabellen 76E2/76E6; Eimer `v%2`, verglichen wird `v/2`: 70 = 0x23 usw.).  Damit stimmen die Adressen der Zeichenketten und Schalttabellen innerhalb von c10 (gemessen: alle verbleibenden `D+`-Abweichungen in c10 sind Adressen in c11-c13-Daten: `__iob` -242, `opdope` -96, weitere Tabellen; Daten gebaut 5348 gegen 5582).

**Abschnittsausgabe (3C2A, 3C58, 3CAA, c11).**  Drei kleine Funktionen geben Abschnittsanweisungen des `as` aus (`$DATA`, `$SECTION BSS_B`, `$SECTION %s_d` mit `modname`, `$CODE`, `$SDEFAULT`, `G`/`I`); Steuerung ueber die Flags 7B42/7B44/7B46 (`yf0` Abschnittsmodus, `yf1` globale Daten, `yf2` Abschnitt offen; Namen/Deutung *Annahme*, Texte und Fluss gemessen).  `3C58` und `3CAA` sind `fphead`/`fptail` (von `outfp` mit `neg` aufgerufen), `3C2A` (Aufrufer 34FA, 35F4, 3DEA; Name `secbss` *Annahme*) ist noch nicht eingehaengt.
Die Platzhalter `bitnum` (2DAE), `bitop` (2EE4), `fphead`/`fptail` (3C58/3CAA) und `regnode` (577A) stehen jetzt an ihrer Binaerposition (c11: zwischen `ispow2`/`pow2`, `pow2`/`cbranch`, `getree`/`geti`; c12: nach `isconstant`).

**Werkzeug (gemessen).**  `C2_AUS["c1"]` ist jetzt `{R5, R5T, R45, R4}`: das Original hat in `cexpr` durchgehend `CP mem,#k` (R4 laedt sonst `R0` und nutzt es in der Kette weiter) und in `fpfind` `ld r2,r3 ; ld r12,r3` (R5, Kopie der Form des gelieferten c2); wie bei `df`/`rm` (R4) und `c2` (R5).
Der Befehlsvergleich liest die Schalttabellen des *gebauten* Abbilds nicht selbst (Disassembler ohne Karte); mit einer Hilfsrechnung ausserhalb des Repositorys (Tabellen aus `LD R1,Lxxxx(Rn)` + `CP R2,#n` / `DIV RR2,#n` des gebauten Listings, als `dwc`-Zeilen) steigt die Zahl der gleichen Befehle ohne Quelle-Aenderung um etwa 60 (5416 -> 5503).  Das gehoert nach `pipeline.py cmd_vergleich` (Aenderung nur fuer den Vergleich, betrifft alle Programme mit Schalttabellen) und ist hier nicht gemacht.

**Stand nach dem Bau (W6d, gemessen, `alles c1 --c2emu --libc alt --ist neu_c2`, `--check c1` OK, `pytest -m "not gast"`: 213 bestanden, derselbe eine Fehler `test_bau_alle_kennt_genau_die_fertigen_disketten` wie in Teil 5).**
Gebaut Text 30890 B (Original 30176), Daten 5348 (5582), BSS 1826 (1832); Befehle 7444 gegen 7970, **5648 gleich** laut `pipeline.py` (vorher 4790), 5727 mit den Schalttabellen des gebauten Abbilds (Hilfsrechnung, siehe oben); 609 bzw. 641 Bloecke (vorher 786).
Alle c10-Funktionen sind befehlsgleich bis auf Datenadressen in c11-c13 und zwei Reste: `ftol` (1 Block, `xor r10,r10` steht im Original hinter dem Laden von `p`) und der BSS-Zugriff in `main` (`LD B+6E8,R7`: die 1024 Byte BSS der noch nicht rekonstruierten c11-c13-Variablen fehlen).
Offen: c11-c13 sind weiter V7-Text (nur die Nicht-V7-Funktionen `fpfind`, `bitnum`, `bitop`, `fphead`, `fptail`, `regnode` sind rekonstruiert und an Binaerposition; `secbss` (3C2A) noch nicht in `cbranch`/`branch`/`strasg` eingehaengt, die dort V7-Text sind); die V7-Funktionen `collcon`, `xlongrel`, `popstk` kommen im Binary nicht vor, `hardlongs` ebenfalls nicht (die Zuordnung 577A = `hardlongs` ist falsch, es ist `regnode`).

## Teil 7: c11 (W6e)

Alles *gemessen* am Listing `userspace/c1/c1.lst` und am Bericht `userspace/c1/work/bau/neu_c2.bericht`; Namen mit *Annahme* sind erfunden.  Schalttabellen-Adressen und Datenreihenfolge folgen der Quellreihenfolge (Zeichenketten in Reihenfolge der Verwendung).

**Rekonstruiert (c11.c, Z8000-Fassung statt V7-Text):** `pname` (23AE; kein `AUTOI/AUTOD/SFCON`, `#` fuer `AMPER`, `@` fuer `STAR` ausser `zf8`/`OFFS`, Register-Paar-Zweitwort ueber `flag`, `FP`-Sonderfall, Flag 7B48 = `yf3` "Offset gedruckt"), `isfloat` (28EE; liefert auch `'l'`; **setzt `nstack`, nicht `nfloat`**: Adresse 8BB4, `nfloat` = 8E94 wird nur in `getree` geloescht), `oddreg` (293C, Operatorliste `PTOI TIMES DIVIDE MOD ASTIMES ASDIV ASMOD`, Fehler "Register overflow..." bei Long ab Register 3), `pswitch`/`breq` (2A1E/2C70; `dirsw`/`hashsw` in `$DATA/$SECTION %s_d`-Form mit `modname`, Tabellenende ueber `fptail()`; Frame: `ncase tabs worst best range` auf dem Stack, `swp fp lp i j poctab` Register), `cbranch` (2F6C; Konstantenbedingungen, Bit-Test `op=85` mit Bitnummer aus `bitnum`, Blattoperand wird mit 0 verglichen, vorzeichenlose Zeichenvergleiche `op+=4`, kein `longrel`), `branch` (31E8; 3 Argumente, `zf4` waehlt die `jp pl/mi/eq`-Folgen, `yf4` unterdrueckt das Sprungziel, `prins(op,0,c,branchtab)`), `psoct` (33C6; `-` und `%%%x`), `getree` (3416; Hash-Schalter `op%9`, kein `SETREG`, `FCON` immer `DOUBLE` mit `atof(numbuf,&fp->fvalue)`, `NAME` ausser `EXTERN` ueber `regnode`, zweiter statischer Namenpuffer `s1` (92A2) fuer `RLABEL`, lokale Flags `endf`/`globf` (FEDA/FED8, *Annahme*), Ausgaben `testl rr2` / `fcpzx f0` / `jp gt|lt`), `strasg` (3DAE; `secbss`/`fptail` um den Ergebnispuffer, `ld r2,#L%d`, ein `ldir`).  Die Zeichenkette `"ld\tr2,#L%d\n,call\tmcount\n"` (PROFIL) enthaelt im Original ein Komma -- uebernommen.
**Korrektur zu Teil 6:** `popstk` (3326) und `label` (3310) **gibt es** im Binary; es fehlen nur `collcon`, `longrel`, `xlongrel` (und `lrtab`).  `v7zuordnung.txt` ist hier falsch (3310 ist `label`, 31E8 `branch`).  `hardlongs` fehlt im Binary weiterhin (noch in `c12.c`, Aufrufer dort offen).

**Stand nach dem Bau (`alles c1 --c2emu --libc alt --ist neu_c2`):** Text 30694 (Original 30176), Daten 5436 (5582), BSS 1836 (1832); Befehle 7345 gegen 7970, **6275 gleich** (vorher 5648), 474 Bloecke (vorher 641).

**Offen (c11):** die meisten Restbloecke in `pname`, `cbranch`, `getree`, `strasg` sind Datenadressen (`D+14B0` gegen `D+1416` usw.: Daten noch 146 Byte kleiner, Ursache nicht gefunden; Kandidaten: nicht rekonstruierte c12/c13-Daten und die 1024 Byte BSS), dazu echte Formabweichungen: `oddreg` (Original legt den Zweig `(reg+1)&~1` vor den Rueckgaben 4/0 an), `branch` (Original berechnet `k = op>200?op-200:op` vor der Bedingung, Bedingungsfolge anders gemischt), `cbranch` (Spruenge im Original weiter: `JP` statt `JR`, also mehr Code dazwischen; Konstantentest), `pname` FCON (`NEG` im Original vor dem Push, hinter einem vorgezogenen Block).  `degree`, `pbase`, `xdcalc`, `dcalc`, `notcompat`, `prins`, `arlength`, `sort`, `ispow2`, `pow2`, `error`, `geti`, `outname`, `setype`, `decref`, `incref` unveraendert V7 (nur Datenadressen bzw. nicht untersucht); c12/c13 nicht angefasst.

## Teil 8: c11, Rest (W6f)

Alles *gemessen* am Listing `userspace/c1/c1.lst` und am Bericht `neu_c2.bericht`; Zuordnung der Adressen: `regerr` 264E, `pbase` 2660, `xdcalc` 269C, `dcalc` 26D8, `notcompat` 279C, `prins` 2826 (in `v7zuordnung.txt` nicht verlaesslich).

**Neu geschrieben (c11.c):**
* `dcalc` (26D8): dichter Schalter `NAME..STAR` (Tabelle 7B84, Standardziel `nrleft`-Rechnung); `NAME` ausser `REG` sowie `FCON`/`AMPER` -> 12, `LCON` -> 11 (kein `AUTOI/AUTOD/SFCON`); `CON`: 0 -> 4, positiv `<16` 5, `==16` 6, `<33` 7, sonst 8, nicht positiv 12; `STAR`: Operand `NAME`/`REG` -> 9, `NAME`/`OFFS` -> 12.
* `notcompat` (279C): ohne die V7-Ausnahme `NAME/REG/ASSIGN/CHAR`; `op` bleibt ungenutzt.
* `prins` (2826): vier Argumente `(op, fl, c, itable)` (bisher falsch mit dreien); Eintrag `{iop, str1, str2}`; Zeichenkette `"!"...` zaehlt nur `yf4` hoch; sonst `printf("%s")`, bei `'m'` und `!fl` danach `putchar('t')`; beginnt sie mit `t`, `x`, `o` oder `an`, wird `zf4 = 1` (Bedingungsfolgen in `branch`).  Namen/Deutung von `fl` *Annahme*.
* `degree`, `pbase`, `xdcalc`, `regerr` sind im Binary V7-gleich (nur Datenadressen) und blieben unveraendert.

**Formkorrekturen:** `oddreg` (`if (LONG) { if (reg>2) error else {...} } else return((reg+1)|1)` erzeugt die Blockreihenfolge des Originals), `branch` (`k` per `if/else` statt `?:`: das Original hat zwei getrennte Stores).  Beide sind jetzt befehlsgleich bis auf Datenadressen.

**Stand nach dem Bau:** Text 30826 (Original 30176), Daten 5436 (5582), BSS 1836 (1832); Befehle 7386 gegen 7970, **6353 gleich** (vorher 6275), 459 Bloecke (vorher 474).  `--check c1` OK; pytest 213 bestanden, derselbe eine Fehler wie in Teil 5.

**Offen:** `dcalc` hat einen Rest (`LDK R2,#11; JR` steht im Original an anderer Stelle, 1 Block); `cbranch` (`JP` statt `JR`, ein Block `LD @R8,#85...` im Original nach hinten verlegt) und `pname` FCON (`NEG`-Block) unveraendert; ausserdem noch die Datenadressen (146 Byte Daten fehlen).

## Teil 9: c12 beginnt -- `optim` (W6g)

Alles *gemessen* am Listing `c1.lst` und am Bericht `neu_c2.bericht`.  Der c12-Bereich beginnt bei **3FD6** (`optim`, 1454 Byte) direkt nach `incref` (3FB6); danach `unoptim` 4584, `lvfield` 4BFC, `acommute` 4D76, `distrib` 50BE, `squash` 525C, `const` 5278, `lconst` 536C, `insert` 54E6, `tnode` 5666.  Wegen der Groesse von `optim` wurde nur diese eine Funktion rekonstruiert (der Auftrag nannte 5-8; `unoptim` weicht in der Struktur stark ab, siehe unten).

**`optim` (c12.c) nach dem Binary, nicht nach dem V7-Text:**
* Alle sechs Variablen in Registern (`op R13, dope R12, d1 R11, d2 R10, t R9, tree R8`); `tree->regno = 14` (R14 = Rahmenzeiger, V7 hat 5).
* Es fehlen: `FCON`/`SFCON`-Umwandlung, `ASAND` -> `ASANDN`, `AND` -> `ANDN` im `COMMUTE`-Zweig (dort nur `acommute`, Typ zurueck, `return`), `DOUBLE` in `MINUS`, `ispow2/pow2` bei `MOD`, **`hardlongs`**: bei `LONG` in der Divisions-/Modulo-Gruppe wird `tree` unveraendert zurueckgegeben.  `hardlongs` ist damit im Binary nicht vorhanden und die offenen Aufrufer aus Teil 7 sind erledigt (die Funktion bleibt als V7-Text in c12.c, bis sie entfernt wird).
* Neu gegenueber V7: `ASAND` mit Konstante 0 wird `ASSIGN` (`goto again`); `OR`/`ASOR` mit Konstante 0 liefert `tr1`; Schiebezaehler-Begrenzung (`LONG` > 32 -> 32, sonst > 16 -> 16; ein Long-Zaehler <= 32 wird also ebenfalls bei 16 abgeschnitten -- so im Binary); vorzeichenlose Schiebeoperatoren **107/108/137/138** (in `c1.h` als `ZRSH`, `ZLSH`, `ASZRSH`, `ASZLSH`, Namen *Annahme*): `LSHIFT->108`, `ASLSH->138`, `RSHIFT->107`, `ASRSH->137` bei `UNSIGN`-Operand; Rechtsschiebe werden zu negativen Linksschiebern per `op++` (nicht `op =+ LSHIFT-RSHIFT`); ein konstanter positiver Zaehler geht direkt nach `constant`.
* `ULSH`/`ASULSH` (17/18) kommen in der Schalttabelle von `optim` nicht vor; Schaltbuckets nach `op%8`, Vergleich mit `op/8` (Tabellen 80D4/80CA gelesen und den Operatoren zugeordnet: FSELA 16; CALL 100; ASAND 77; OR 48, ASOR 78; COLON 8, QUEST 90; DIVIDE 43, ASDIV 73, ASTIMES 72, PTOI 14; MOD 44, ASMOD 74; 107/108/137/138; RSHIFT 45, LSHIFT 46, ASRSH 75, ASLSH 76).

**Stand nach dem Bau (`alles c1 --c2emu --libc alt --ist neu_c2`, zweiter Bau mit `op = ASSIGN; tree->op = op;`):** Text 30494 (Original 30176), Daten 5442 (5582), BSS 1836 (1832); Befehle 7301 gegen 7970, **6578 gleich** (vorher 6353), 368 Bloecke (vorher 459).  Fuer `optim` bleiben nur Datenadressen (`opdope` D+BA8 gegen D+BA6, `maprel`/`notrel`, Zeichenkette B2A gegen B28; Daten weiter 140 Byte zu klein) und die `&czero`/`&cone`-Rueckgaben (442A: Original legt `LD R2,#D+1C; JP` / `#D+16` dahinter an, hier fehlen sie: vermutlich nur die Datenadressen-Bloecke) sowie ein c2-Unterschied am Funktionsende (4568/4576: `DEC R15,#2`, gemeinsamer `return(tree->tr1)`-Schwanz).  Der Block `LD R13,#80; LD @R8,R13` der `ASSIGN`-Zuweisung ist nach der Umstellung auf `op = ASSIGN; tree->op = op;` gleich.

**Offen (c12):** `unoptim` (4584): Struktur weicht laut Bericht stark vom V7-Text ab (andere Schaltwerte, fehlende/zusaetzliche Zweige, z.B. Block 463A ff., 47BC ff., 4944 ff.; *nicht* naeher untersucht); alle weiteren c12-Funktionen unveraendert V7-Text.  Die 140 fehlenden Datenbytes sind weiter nicht gefunden (`maprel`/`notrel`-Tabellen und c12-Zeichenketten pruefen).


## Teil 10: c12, `unoptim`, `lvfield`, `acommute`, `distrib` (W6h)

Alles *gemessen* am Listing `c1.lst` und am Bericht `neu_c2.bericht`.  Die Schalter von `unoptim` und `lvfield` sind Hash-Schalter (`op%3` bzw. `op%2` waehlt die Tabelle L80E8/L80E4/L80EE, verglichen wird mit `op/3` bzw. `op/2`); die Operatoren sind aus Quotient und Rest zurueckgerechnet.

**`unoptim` (4584) nach dem Binary** (nicht V7; Abweichungen im Kopfkommentar von c12.c):
* Vor `again:`: ein `CHAR`-Operand mit `class==REG` wird zu `INT`.
* `ITOF`/`LTOF` (51/57) statt `FTOI`/`LTOF`/`ITOF` von V7: Konstante 0 (`CON`/`LCON`) liefert `optim(subtre)`; sonst `CON`/`LCON` -> `FCON` (14 Byte, `isn++`, Wert per `ltod(l, &tree->fvalue)`, bei `CON` mit `(long)`-Umwandlung); alles andere `break`.  Kein `FTOI`, kein `SFCON`.
* `ITOC`: `CON` wird mit `0377` maskiert (V7: Vorzeichenerweiterung); `NAME`: `type = CHAR`, `offset =+ 1` (Byte steht im Big-Endian-Wort hinten).
* `LTOI`: Reihenfolge `LCON`, `NAME`, `STAR`, `ITOL`, dann `PLUS/MINUS/AND/OR/EXOR` (ohne `ANDN`), `NEG/COMPL`; bei `NAME` wird ein `CHAR`-Zieltyp zu `INT`.
* `STAR`: kein `INCAFT/DECBEF` -> `AUTOI/AUTOD`; stattdessen `if (opdope[subtre->op]&LEAF) return(tree)` (ohne Gradberechnung) nach dem `NAME`/`REG`-Fall.
* `NEG`: kein `SFCON`-Fall (nur `FCON`, Vorzeichenbit in `fvalue.intx[0]`).  `fv`/`fp`/`ITOF`-`SFCON`-Zweig entfallen (`static double fv` weg: Daten 5442 -> 5434).
* `FSEL`, `FSELR`, `AMPER`, `EXCLA`, `COMPL`, Schwanz (`degree`): wie V7 (`p`/`subtre` wie dort).

**`lvfield` (4BFC):** `ASAND` (nicht `ASANDN`) im Fallbereich; vor dem Schalter und nochmals vor `optim(tnode(FSELT...))` wird bei `ASAND` `tr2 = tnode(COMPL, tr2->type, tr2, NULL)` gebildet (*gemessen*: zwei gleiche Bloecke 4C04 und 4CE6; die Absicht, warum zweimal, ist *nicht* geklaert).

**`acommute` (4D76):** Register `t1 R13, t2 R12, tree R11, t R10, flt R9, op R8`; `d`, `i`, `d1` auf dem Stapel hinter `acl`.  `flt` wird mit `'f'` verglichen (`isfloat` liefert einen Buchstaben, c10.c nutzt dasselbe).  "+0"-Entfernung nur bei `nextl>0` (Klammerung `a && (b || c)`).  Der `TIMES`-/`hardlongs`-Aufruf am Ende fehlt im Binary.

**`distrib` (50BE):** nur Deklarationen: `p1 R13, p2 R12, t R11, ndmaj R10, ndmin R9, dividend R8` sind `register`, `divisor`/`maxnod`/`mindiv` liegen auf dem Stapel.  Der Rumpf ist V7.  `squash` (525C) war schon befehlsgleich.

**`hardlongs`** ist aus c12.c entfernt (im Binary nicht vorhanden, keine Aufrufer mehr).

**Stand nach dem zweiten Bau** (`alles c1 --c2emu --libc alt --ist neu_c2`): Text 30134 (Original 30176), Daten 5434 (5582, 148 Byte zu klein), BSS 1828 (1832); Befehle 7212 gegen 7970, **6798 gleich** (vorher 6578), 271 Bloecke (vorher 368).  Fuer `unoptim`, `lvfield`, `acommute`, `distrib` bleiben nur Datenadressen (`opdope` D+BA8 gegen D+B9E, `notrel`, Zeichenkette B42/B38, die Konstante 0x8000 wird vom Bericht als Datenadresse gedeutet) und in `acommute` bei 4FD0 ein Sprungunterschied in `--acl.nextl <= 0` (Original `JR Z; JP PL`, hier anders: nicht naeher untersucht) und in `unoptim` bei 49E2 (ein `JP`; *nicht* untersucht).

**Offen (c12):** `const` (5278), `lconst` (536C), `insert` (54E6), `tnode` (5666) und der Rest sind noch V7-Text; im Bericht zeigt `const` bei 5308 einen Befehlsunterschied (`COM/AND` statt Original), `lconst` ebenso weitere.  Die 148 fehlenden Datenbytes sind weiter nicht gefunden.


## Teil 11: c12-Rest und c13 (W6i)

Alles *gemessen* an den Originaldaten (`c1.orig`) und am Bericht `neu_c2.bericht`.

**Datenbereich von c13 (Fund der fehlenden Bytes):**
* `opdope` und `opntab` haben im Original **139** Eintraege (Operator 0..138), nicht 117: `opdope` bei 8188, `opntab` bei 829E (je 278 Byte).  Eintraege 117..136 sind 0, 137/138 sind `ASZRSH`/`ASZLSH` (`012253`, ">>=unsigned", "<<=unsigned").  Das sind 2 x 44 Byte.
* Gegenueber V7 weichen aus: 27/28 (`012253`, ">>= unsigned"/"<<= unsigned" statt `*r++`/`*--r`), 81..85 (`bitset` 016161, `bitclr` 020161, `bitset=` 012253, `bitclr=` 012253, `bittest` 020161; Namen aus `opntab`, Bedeutung *Annahme*), 86..88 und 91/92 gleich 0, 107/108 (`000001`, ">>unsigned"/"<<unsigned"), `opntab[17]/[18]` ">> unsigned"/"<< unsigned", `[29]` "indirection", `[89]` "load byte register", `[98]` 0.
* `instab`/`branchtab` sind die **Z8000-Tabellen** (ld, clr, cp, test, ... `jp<TAB>eq`; Zeichenketten 83B4..8470, `instab` 8470..8594, `branchtab` bis 8612), nicht die PDP-11-Tabellen von V7.  Die Variablennamen sind verloren (*Annahme*: Praefix `z_`).  `sdal`, `jpl`, `jmi` stehen im Original in den Zeichenketten, werden aber von keiner Tabelle benutzt.  Eintraege fuer ZRSH/ZLSH/ASZRSH/ASZLSH und 81..84 (set/res).

**c12-Funktionen** (Listing 5278..577A): `const` ohne `ANDN`; `lconst` ohne `ANDN`, `LTIMES`, `LDIV`, `LMOD` (Schalter nur ueber 40..49); `insert`: `d1`, `i`, `t` in Registern (R10, R9, R8) und `isfloat(tree) != 'f'`; `isconstant` ohne `SFCON`.  `tnode`, `tconst`, `getblk`, `islong` waren schon gleich.  c12 ist damit vollstaendig im Binary-Bereich (der Eintrag `hardlongs` bei 577A in `v7zuordnung.txt` ist in Wahrheit `regnode`).

**Stand nach dem Bau** (`alles c1 --c2emu --libc alt --ist neu_c2`, ein Bau): Text 29968 (Original 30176), Daten **5590** (5582), BSS 1828 (1832); Befehle 7155 gegen 7970, **6901 gleich** (vorher 6798), 143 Bloecke (vorher 271).  Alle 200 Zeichenketten liegen im Datenbereich auf demselben Offset wie im Original; die eigenen Daten (bis "null" bei Offset 14A2) sind damit deckungsgleich, `opdope` liegt bei D+BA8 wie im Original.  Die verbleibenden +8 Byte Daten und -4 Byte BSS liegen *nach* den c1-eigenen Daten im libc-Teil (vor `_ctype`: Original `8B28`, hier `8A58 920A` und 8 Nullbytes mehr); das ist der `--libc alt`-Anteil, nicht c13.  Die 1024-Byte-BSS-Luecke zwischen `nfloat` und libc wurde nicht weiter verfolgt.

**Offen:** `lconst` (bei 540E/5490 im Bericht "delete": Case-Reihenfolge/Zweigform noch anders), `unoptim` 494C (`AND R3,#100` statt `BIT`), 49E2; `acommute` 4FD0; `optim` 4130/43AA; `distrib` 50BE (Konstante 1000 als Datenadresse gedeutet); `getree` (3416, 50 Bloecke, c11).

## Teil 12: `getree` und `ctype_` im libc-Teil (W6j)

Alles *gemessen* an `c1.lst` und `neu_c2.bericht`.

**`getree` (c11.c), 50 -> 18 Bloecke:**
* Die Original-Frame ist 2 Byte groesser (`SUB SP,#11C` statt `11A`): zwischen `numbuf` (FEEC) und `fp` (FEE8) liegt ein ungenutztes Wort bei FEEA.  Ergaenzt als `int unused1;` (*Annahme*, Name erfunden); damit stimmen alle Frame-Offsets (`globf` FED8, `endf` FEDA, `lbl3` FEDC, `lbl2` FEDE, `cond` FEE0, `lbl` FEE2, `sap` FEE4, `lp` FEE6, `fp` FEE8).  Das waren rund 30 der 50 Bloecke.
* `BDATA`: das Original gibt **pro Wert** `BV ` aus; der Text `;` steht *vor* dem `BV `-Block, der Eintritt springt darueber (`JR L34B0`).  Das ist ein `while`, dessen Bedingung die Ausgaben enthaelt: `while (printf("BV "), printf("%%%x", geti()), geti() == 1) printf(";");`.  Die Form ist aus der Codelage erschlossen (Original-Quelltext unbekannt); der Bau gibt dieselbe Befehlsfolge wie das Original (Eintritts-`JR`, `;`-Block, Bedingungssprung `JR Z` rueckwaerts).
* Binaerer `default`-Zweig: `*sp = tnode(op, geti(), *--sp, t); sp++;` (Original: `LD @R13,R2` dann `INC R13,#2`, nicht `INC` vor dem Aufruf).
* Rest in `getree` (18 Bloecke): 11 Bloecke sind BSS-Adressen (`B+6EA` gegen `B+6EE`, `B+6F4` gegen `B+6F8`: die statischen Puffer `s`/`s1` liegen im Bau 4 Byte weiter hinten, Ursache unter "Offen"), `PROG` (Original `JP NZ` auf den `fptail`-Block bei 3604 im `PROFIL`-Zweig, der Bau legt den gemeinsamen Block im `PROG`-Zweig an und springt aus `PROFIL` hin; Frage der c2-Querverkettung, Mastervariante), die `CSPACE`-Tabelle (3544/355E) und `CALL _atof` gegen `CALL L57CE` (nur Namensdarstellung; `userspace/c1/namen.txt` aendert das nicht).

**libc-Teil, `_ctype_`:** `c1.members(.zusatz)` fuehrten `ctype ... src=A`; das Glied heisst im Archiv `ctype_` (so bei chown/cmp, `src=S`).  Unter dem Namen `ctype` fand `libc_alt.py bau c1` kein Objekt (`altobj.get`), `ctype_` fehlte im c1-Archiv; `ld` zog es erst am Ende aus der ausgelieferten libc, hinter `sbrk`.  Folge: `sbrk`-Datenwort (`92D6`) lag vor der Zeichentabelle.  Nach der Umbenennung (`ctype_ ... exp=__ctype@8B2A src=S`) steht `ctype_` in Archivreihenfolge hinter `data`: vor `_ctype` steht jetzt `8A64` (= `__lastbu`, Selbstadresse im verschobenen Abbild) wie `8B28` im Original, das Wort `920A` ist weg und `sbrk` steht nach der Tabelle.  `libc_alt.py bau c1`: 0 Glieder verschieden (Archiv 11618 B).

**Stand nach dem Bau** (`alles c1 --c2emu --libc alt --ist neu_c2`): Text 29980 (Original 30176), Daten 5590 (5582), BSS 1828 (1832); Befehle 7156 gegen 7970, **6941 gleich** (vorher 6901), 109 Bloecke (vorher 143).

**Offen:**
* Daten +8: am Abbildende (nach dem `sbrk`-Wort) stehen 8 Nullbytes, die das Original nicht hat; Herkunft nicht gefunden (kein Glied von `libc_alt.a` hat Daten dahinter; vermutet ein weiteres aus der ausgelieferten libc gezogenes Glied oder Linker-Auffuellung -- ohne Linkkarte nicht entscheidbar).  Zusammen mit BSS -4 (und `s`/`s1` +4 vor dem Puffer) spricht das fuer ein BSS-/Datenobjekt, das im Bau an anderer Stelle liegt; ein Linker-Lauf mit Karte ist der naechste Schritt.
* Restbloecke je Funktion (Bericht): 0000:1 0186:3 039E:4 0B9E:10 1C74:2 1F66:2 2028:3 2104:3 2228:1 23AE:3 264E:1 26D8:1 2826:1 29EC:1 2A1E:1 2C70:2 2CA6:5 2D12:5 2DAE:4 2DEA:6 2EE4:3 2F6C:9 3416:18 3CD2:1 3FD6:5 4584:7 4D76:1 50BE:1 536C:2 56DE:2 577A:1.

## Teil 13: Daten +8 und BSS (W6k)

Alles *gemessen* an `neu_c2.bericht` und am Vergleich des Daten-Abschnitts von `c1.orig` und `neu_c2.bin`.

**Daten +8: Ursache `ldexp.o`.**  Der Daten-Abschnitt ist bis zum `sbrk`-Wort Byte fuer Byte ausgerichtet (Verschiebung 0, nur Adress-Worte unterscheiden sich); danach folgten die 8 Nullbytes.  Das sind Daten von `ldexp.o` (shipped libc: Text 48, Daten 8 Nullbytes): `atof.s` (Kopie des ausgelieferten `atof.o`) hat `X _ldexp`, kein Glied von `libc_alt` definiert es, `ld` zog es am Ende aus der libc (Text ab 74EC am Abbildende, im Original gibt es weder diesen Text noch diese Daten).  Das Original-`atof` (ab 57CE) weicht vom ausgelieferten ab (ab Offset 17E um 4 Byte versetzt) und ruft das `ldexp.o` nicht.  Abhilfe (nur c1): `atof.s` definiert `_ldexp` als nulllaengige Prozedur (wie `pfloat`/`pgen` in `ffltpr.s`); der `CALL _ldexp` im Fremd-`atof` zeigt damit auf das Ende von `atof` (der Aufruf kommt im Original nicht vor, solange `atof.s` nicht aus den Original-Bytes statt aus dem ausgelieferten Glied gebaut wird; offen).  Daten jetzt **5582 = Original**, Text 29932 (Original 30176; vorher 29980).

**BSS: `lsptab`.**  `struct table lsptab[1];` in `c10.c` (W6c als "BSS-Platzhalter" gedacht) ist ein 4-Byte-Common hinter `nfloat`, also zwischen `nfloat` und `__sibuf`; im Original liegt `__sibuf` direkt bei `nfloat+2` (8E96).  Dadurch standen `environ` (`B+6E8` im Original), `s`, `s1` um 4 Byte zu weit hinten.  `lsptab` wird nirgends benutzt und ist entfernt; die `B+6E8/6EA/6F4`-Abweichungen sind weg (13 Befehle, 13 Bloecke weniger).

**Stand nach dem Bau** (`alles c1 --c2emu --libc alt --ist neu_c2`): Text 29932 (30176), Daten **5582** (5582), BSS 1824 (1832); Befehle 7156 gegen 7970, **6954 gleich** (vorher 6941), 96 Bloecke (vorher 109).  Restbloecke je Funktion: 0186:3 039E:4 0B9E:10 1C74:2 1F66:2 2028:3 2104:3 2228:1 23AE:3 264E:1 26D8:1 2826:1 29EC:1 2A1E:1 2C70:2 2CA6:5 2D12:5 2DAE:4 2DEA:6 2EE4:3 2F6C:9 3416:6 3CD2:1 3FD6:5 4584:7 4D76:1 50BE:1 536C:2 56DE:2 577A:1.

**Offen:**
* BSS -8: im Original liegen zwischen `s1` (92A2, belegt bis 92AC) und dem BSS von `filbuf` (92B4) 8 Byte, auf die kein Befehl im Original zugreift; Herkunft nicht gefunden (c12/c13-Statik oder ein Glied der libc; *Annahme*, nicht gemessen).
* `cexpr` (0B9E, 10 Bloecke) und `cbranch` (2F6C, 9 Bloecke) in dieser Runde nicht angefasst.
* `pytest -m "not gast"`: `test_bau_alle_kennt_genau_die_fertigen_disketten` schlaegt fehl, weil im Worktree `disks/gebaut` fehlt (nicht von dieser Aenderung).

## Teil 14: Restbloecke cexpr, cbranch, unoptim, pow2, getree (W6l)

Reine Analyse, **keine Quelländerung**; Bau unveraendert gegenueber Teil 13 (*gemessen*: 7156 gegen 7970 Befehle, 6954 gleich, 96 Bloecke, Text 29932, Daten 5582, BSS 1824).  `--check c1` OK.  Grundlage: `neu_c2.bericht`, Original `c1.lst`.

**Einordnung je Funktion** (Adressen des Berichts):
* `cexpr` 0B9E (10): sieben der zehn sind `delete`-Bloecke mit `PUSH #D+36x/37x/3B5; JP/JR L`-Ketten (0FCA, 100E, 108C, 12A2, 148E, 14A2, 14EC, 1552), also Fehler-/Zweig-Fortsetzungen, die das Original an anderer Stelle platziert hat; die Befehle sind im Bau vorhanden, nur verschoben.  *Annahme*: Block-Platzierung/Cross-Jump des aelteren c2-Stands (`wk_w5e.md`), keine Quellvariante gefunden.  0E02 (`CP 4(R12),#FFF0` gegen `DJNZ`) und 13E4 (`CALL L` gegen `SUB`) sind Folgeverschiebungen im Bericht (der Bau ist dort um die geloeschten Bloecke versetzt).
* `cbranch` 2F6C (9): 2FC0..3004 sind nur `JR`/`JP`-Wahl (Sprungweite haengt von der Blockreihenfolge ab, Folge der Verschiebung 3012/3174/3182: im Original liegt der `LD R2,8(R8); INC R2,#2`-Block vor dem `TEST 8(R14)`-Block, im Bau dahinter).  Klasse: aelterer c2-Zustand (Blockreihenfolge), nicht per Quelle erklaerbar.
* `unoptim` 4584 (7): 4A00 (`ADD R2,#75B0` gegen `74BC`) und 4B6C (`XOR R2,#D+A20` gegen `D+B14`) sind **Adressfolgen** (BSS bzw. Zeichenkettentabelle um 0xF4/8 verschoben, die 8 fehlenden BSS-Bytes aus Teil 13; nicht Code).  494C (`LD R3,@R2; AND R3,#%0100` gegen `BIT @R2,#8`): im Original fehlt die c2-Umsetzung auf `BIT`, der aeltere c2 kennt sie noch nicht (selber Befund wie in `wk_w5e.md`, *Annahme*).  49D8/4A64/4A94/4B96 Folgeverschiebungen.
* `pow2` 2DEA (6): **Quellunterschied gefunden, nicht umgesetzt.**  Original: `ispow2` (2D12) liefert `long` (Rueckgabe RR2, `TESTL RR2`), `d` ist ein `long`-Automatic (`-16(R14)`, `LDL`/`SDAL RR0,R2` fuer `d=>>1`), Register: `tree` R12, `i` R13 (also `register int i; register struct tnode *tree; long d;`).  Der Bau hat `d` als Register-int.  Die Umstellung haengt an `ispow2` (2D12, 5 Bloecke): das Original dort ist **nicht** die V7-Fassung, sondern prueft `tr2->op` auf CON(21)/LCON(25)/ITOL(58) (Schleife ueber `tr2->tr1` bei ITOL), liest bei LCON `lvalue` (`LDL 4(R13)`), bei CON `value` mit `EXTS`, und liefert `d` wenn `d>0 && (d&(d-1))==0`, sonst 0L (`XOR R3,R3; EXTS RR2`); `tree` bleibt nicht-Register (liest `4(R14)` jedes Mal), `p` in R13.  Die genaue Quellform (Reihenfolge der Tests, wo `d` abgelegt wird) ist nicht eindeutig aus dem Listing abzuleiten; ohne Bau-Experiment nicht geraten.  Naechster Schritt: `ispow2` als `long`-Funktion nach diesem Listing schreiben, `pow2` auf `long d` umstellen (zusammen 11 Bloecke).
* `getree` 3416 (6): 348A (`PUSH #D+8B0` gegen `LDCTL`), 3544 (`PUSH #D+8C5/8C8/8CB; JR` gegen nichts), 355E, 35E8: wie `cexpr` verschobene Fehlerzweige (Block-Platzierung); 390A `CALL L` gegen `CALL _atof`: Fremd-`atof` (Teil 13, `atof.s` ist ein ausgeliefertes Glied, das Original-`atof` liegt woanders).  34C8 (`JP NZ` gegen `JR Z; CALL; JR`) ist eine Verzweigungs-Umkehr derselben Verschiebung.

**Ergebnis:** 0 Bloecke behoben; 5 Funktionen klassifiziert.  Einzige echte Quellaufgabe: `ispow2`/`pow2` (long).

## Teil 15: `ispow2` (long) und `pow2` umgeschrieben (W6m)

Quelle: `userspace/c1/c11.c`.  Erste Form traf; die zweite Probe war nicht noetig (*gemessen*: ein Bau).

**`ispow2`** (2D12): `long ispow2(atree)`, `register struct tnode *p; long d;`.  `p = tr2` bei `op` CON/LCON, `p = tr2->tr1` bei ITOL mit CON darunter, sonst `return(0L)`; `d = p->lvalue` bei LCON, sonst `d = p->value`; `if (d>1 && (d&(d-1))==0) return(d); return(0L);`.  Wichtig: der Test ist `d>1` (Original `CPL RR2,RR0` mit RR0=1), nicht `d>0` wie in der ersten Analyse (Teil 14) angenommen.  Andere Aufrufer (c10.c, c12.c) bleiben ohne Deklaration (int), wie im Original (`TEST R2` nach dem Aufruf).  Bis auf die BSS-Adresse bei 2DA4 (Folge der 8 fehlenden BSS-Bytes) deckungsgleich.

**`pow2`** (2DEA): `register int i; register struct tnode *tree; long d;`.  Das Original setzt den Wert nicht je Fall, sondern einmal nach dem `switch`: je Fall nur `tree->op` und ggf. `i = -i` bzw. `i = (1<<i)-1`; DIVIDE/ASDIV waehlen bei `tree->type==UNSIGN` ZLSH(108)/ASZLSH(138), sonst LSHIFT/ASLSH (nicht ULSH).  Danach `if (tr2->op==ITOL) tr2->tr1->value = i; else if (tr2->op==LCON) tr2->lvalue = i; else tr2->value = i;`.  Vollstaendig deckungsgleich.

Alternativform (nicht gebaut): `p`/`d` anders verteilen oder `d>0`; unnoetig.

**Stand nach dem Bau:** Text 30108 (Original 30176), Daten 5582 (gleich), BSS 1824 (1832); Befehle 7211 gegen 7970, **7057 gleich** (vorher 6954), 90 Bloecke (vorher 96).  `ispow2`/`pow2` nur noch die Adressfolge bei 2DA4.  `--check c1` OK; pytest 213 bestanden, derselbe eine Fehler wie in Teil 5.
