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
