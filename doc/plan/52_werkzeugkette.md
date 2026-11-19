# Plan 52: Werkzeugkette `cc cpp c0 c1 c2 as ld` und `libc.a` (Plan 44, Stufe 4)

Stand 2026-11-16 (Plan).  Vorlage: Plan 44 (Methode, Agentenregeln, Definition of Done), `doc/userspace/README.md` (Stolpersteine, c2-Modell),
`doc/werkzeugkette/` (Messungen zur Kette im Gast).  Nummer 52, weil 46-51 im Branch `mutos-plus` liegen.
Ziel: jedes Programm der Werkzeugkette so zurueckbauen, dass der MUTOS-`cc -O -s` im Gast aus unserer Quelle das Original **ganzdatei bytegleich** erzeugt (G);
wo das nicht erreichbar ist, die Aussagen E/A/F aus Plan 44 §4.  Danach baut MUTOS **seinen eigenen Compiler** (Selbsthosting der Werkzeugkette, nicht nur des Kernels).

Warum sich das lohnt (ueber Ziel 2 hinaus): Der ausgelieferte `c2` wird bisher durch Musterregeln **nachgebildet** (Kernel K1-K6, Userspace R1-R91, viele nur an einer
Stelle belegt; `sh` und `ed` mit einem anderen c2-Stand).  Eine bytegleiche `c2`-Quelle zeigt, was der ausgelieferte Optimierer wirklich tut, und erlaubt die Gegenprobe
jeder Regel (W5).

## 1. Bestand (gemessen 2026-11-16)

Dateien aus `disks/original/a5120_mutos8000_best_cc1.zip` / `best_cc2.zip` (gleich denen der `usr`-Diskette, DISK-Satz 1987, alle `E807`, Symboltabelle 0 = gestrippt).
Segmentgroessen aus dem a.out-Kopf (8 Worte, big endian).  "Zeichenketten in V7" = Anteil der Zeichenketten des Binaries (`strings -n 6`), die woertlich in den
V7-Quellen `original/unix-v7/usr/src/cmd/{cc.c,ld.c,c/,cpp/,as/}` vorkommen -- ein grobes Mass, keine Herkunftsaussage.

| Programm | Datei (B) | text | data | bss | Zeichenketten in V7 | Befund (gemessen) | Erwartung (*Annahme*) |
|----------|-----------|------|------|-----|---------------------|-------------------|-----------------------|
| `cc` | 6536 | 5902 | 618 | 2660 | 8 / 17 | fehlend sind nur die Pfade `/usr/lib/c0` ... `/usr/lib/mcrt0.o` (V7: `/lib/...`) | V7 `cc.c` mit geaenderten Pfaden; leicht |
| `cpp` | 16382 | 13202 | 3164 | 17780 | 41 / 53 | neu u. a. `%s: argument mismatch`, `# %d "%s"` | V7 `cpp.c` + `cpy.y` (yacc) + `yylex.c`, kleinere Aenderungen |
| `ld` | 10726 | 9686 | 1024 | 35924 | 38 / 40 | neu nur `CALLR : illegal destination`, `CALLR : out of range` | V7 `ld.c` + Z8000-Relokation (CALLR = 12-Bit-relativer Aufruf) |
| `c0` | 26826 | 23614 | 3196 | 12074 | 95 / 109 | neu `No character constant`, `Disallowed conversion` | V7 `c00.c`-`c05.c`, maschinenunabhaengig, wenige Aenderungen |
| `c2` | 18976 | 16976 | 1984 | 3296 | 22 / 46 | Z8000-Spruenge `jp eq` ... `jr uge`, `setmode`/`resmode` | Geruest V7 `c20.c c21.c c2.h`, Befehlstabelle und Muster Z8000; mittel bis schwer |
| `c1` | 35774 | 30176 | 5582 | 1832 | 60 / 262 | Codetabellen (`GAcall`, `KAandC` ...) statt PDP-11-`table.s` | Geruest V7 `c10.c`-`c13.c`, Tabellen Z8000 (aus dem Binary, ggf. mit angepasstem `cvopt`); schwer |
| `as` | 35814 | 22092 | 13706 | 17744 | 1 / 130 | **yacc-Parser** (`yacc stack overflow`, `error recovery pops state`) | **kein V7** (V7-`as` ist PDP-11-Assembler in Assembler); Z8000-Assembler mit yacc-Grammatik, ganz aus dem Binary; am schwersten |
| `libc.a` | 71914 | -- | -- | -- | -- | V7-Archiv, Magic 0177545 big endian | Glieder einzeln; Teil schon in `userspace/libc_alt` (`doc/userspace/libc_alt.md`) |
| `crt0.o`, `mcrt0.o` | 200, 548 | | | | | Assembler-Objekte | aus Listing, `as` im Gast |

Weitere Fakten: `ed` und `nm` liegen auch auf `cc1`/`cc2` (schon G).  Die `nroff`-Diskette (`bin/nroff` 39838 B, `lib/term/tab1152`) steht in keinem Plan (offen, nicht Teil dieses Plans).
Die Kette laeuft im Gast (K1, `doc/werkzeugkette/k1_cc_im_gast.md`); Quellen ab 20000 B baut `uspace.py` in Stufen (`STUFEN_AB`, eingefuehrt fuer `ed`).

## 2. Besonderheiten gegenueber Plan 44

* **Groesse:** `c0`, `c1`, `as` sind 2-3 mal so gross wie `ed` (bisher groesstes G).  Mehrdatei-Programme: der Bau je Datei (`-c`) und die **Glied-/Linkreihenfolge**
  muessen aus der Karte gelesen werden (Funktionsreihenfolge im Binary = Dateireihenfolge beim `ld`).  `/tmp`-Platz (`no space on dev 4/0`) begrenzt: Stufenbau.
* **Selbstbezug:** Wir bauen den Compiler mit dem Original-Compiler.  Bytegleichheit (G) heisst: unsere Quelle + Original-Kette = Original-Binary.  Ist ein Pass G,
  ist er austauschbar; erst dann gilt "MUTOS baut seinen Compiler".
* **yacc:** `as` (und `cpp` ueber `cpy.y`) enthalten yacc-Tabellen.  Unser Gast-yacc ist V7-yacc in Groessenklasse `SMALL` (`erg_e3a.md`).  Ob die Originale mit
  diesem yacc erzeugt wurden, ist offen; erzeugt V7-yacc andere Tabellen (Reihenfolge der Zustaende, `yyexca`, Packung), bleibt nur, die erzeugte `.c`-Datei als
  Quelle zu fuehren (wie `bc.c` in E3c, dann aber mit Beleg) -- zuerst an `cpp`/`cpy.y` messen, das ist der kleinere Fall.
* **Tabellen in `c1`:** V7 erzeugt sie mit `cvopt` aus `table.s`.  Ziel ist eine Z8000-`table.s` im V7-Format plus (falls noetig) ein angepasster `cvopt`; Beleg:
  die erzeugten Daten sind byte-gleich den Daten von `c1`.
* **c2-Modell:** Diese Programme wurden (wie alle) mit **einem** c2-Stand uebersetzt; welche Regeln greifen, ist Teil des Befunds (`C2_AUS` je Programm wie bei `ps`).
* **Nicht raten:** Programmteile ohne V7-Gegenstueck (Z8000-Befehlstabellen, `as`-Grammatik, Relokation) werden aus Listing und Zeichenketten rekonstruiert
  (Vorbild `hex`, `convert`, `ps`); Namen, die nicht im Binary stehen, sind *Annahme* und so markiert.  WEGA (`original/wega/README.md`) nur als Orientierung, nichts kopieren.

## 3. Arbeitspakete und Reihenfolge

| AP | Inhalt | haengt ab von | Aufwand (*Annahme*) |
|----|--------|---------------|---------------------|
| W0 | **Triage**: `holen` + `karte` fuer alle 7 Programme (`--platte usr --pfad lib/c0` usw.), Dateigrenzen aus der Funktionsreihenfolge, libc-Glieder je Programm (`NAME.namen`), Gliederliste von `libc.a`; Ergebnis `doc/userspace/wk_w0.md`, Tabelle Programm x V7-Datei x Funktionen mit/ohne V7-Gegenstueck | -- | klein, Host |
| W1 | `cc` (V7 `cc.c`, Pfade) | W0 | klein |
| W2 | `cpp` (`cpp.c`, `cpy.y`, `yylex.c`); dabei die **yacc-Frage** klaeren (Abschnitt 2) | W0 | mittel |
| W3 | `ld` (V7 `ld.c` + CALLR-Relokation) | W0 | mittel |
| W4 | `c0` (V7 `c00.c`-`c05.c`, `c0.h`) | W0 | mittel-gross (Groesse) |
| W5 | `c2` (V7 `c20.c c21.c c2.h` als Geruest, Z8000-Teil aus dem Binary); danach **Gegenprobe**: jede Regel K1-K6, R1-R91 gegen die `c2`-Quelle einordnen (tut der ausgelieferte c2 das? -> Regel durch echten Lauf ersetzbar; sonst: anderer c2-Stand, z. B. `sh`, `ed`) | W0 | gross |
| W6 | `c1` (V7 `c10.c`-`c13.c`, `c1.h`, Z8000-`table.s`, `cvopt`) | W0, nach W4 (gemeinsame Header-Kenntnis `c0.h`/`c1.h`) | gross |
| W7 | `as` (Z8000-Assembler, yacc) | W2 (yacc-Befund) | sehr gross; Ergebnis A ist zulaessig |
| W8 | `libc.a` als Ganzes (alle Glieder, Reihenfolge, Archivkopf) und `crt0.o`/`mcrt0.o` | W0; nutzt `libc_alt` | mittel |
| W9 | **Selbsthosting-Beweis**: Gastdiskette `usr` aus den neu gebauten Passen zusammenstellen, damit (a) den Kernel bauen (`tools/kernel/gesamtbau.py`, Ergebnis gleich) und (b) Stichprobe Userspace (`sh`, `ed`, `ls` G) | alle G-Programme | mittel |
| W10 | **Angepasste Werkzeugkette: `cc` mit waehlbarem `c2`, `c2` mit Schaltern fuer aeltere Staende** (eingeplant 2026-11-18, Abschnitt 6a; Vorrang vor W11, Entscheidung Projektinhaber) | W5 (c2-Quelle), W5e (Gegenprobe), W6 (c1) | gross, in kleinen Schritten |
| W11 | **Herkunft/Verwandtschaft des Compilers** (eingeplant 2026-11-18, Abschnitt 6b; technisch nicht noetig, nach W10) | W5, W6 (c1, c2 weitgehend rekonstruiert), W7 | mittel |

Parallel moeglich nach W0: W1, W2, W3, W4, W5, W8 (je eigener Branch, je Agent).  W6 nach W4, W7 nach W2.  W9 zuletzt; fuer Programme ohne G nimmt W9 das Original
und nennt das.

## 4. Regeln fuer Agentenauftraege

Wie Plan 44 §3 (Worktree/Branch `us-wk-<ap>`, `K1520EMU=/home/olliy/projects/a5120emu`, Werkzeuge nur ueber `tools/userspace/pipeline.py`, Gastlaeufe im Vordergrund mit
Zeitgrenze 600000 ms oder im Hintergrund mit Benachrichtigung, nie `sleep`, Runde nicht vor dem Ergebnis beenden, nie pushen).  Zusaetzlich:

* Quellen unter `userspace/NAME/` (Mehrdatei: alle `.c`/`.h`/`.y`/`.s` dort), Eintrag in `PROGRAMME` (Platte `usr`).  V7-Text, wo er genuegt; jede Abweichung
  `/* Differs from V7: ... */`; Teile ohne V7-Gegenstueck: Kopfkommentar `/* Not V7: reconstructed from the MUTOS binary (listing address ...) */`.
* Neue c2-Regeln ab **R92** (vorher `git log` und `uspace.c2_emu_s` auf die hoechste Nummer pruefen), nur programmgebunden (wie `ed=True`), Stellenzahl angeben;
  danach Regression `sh` (`bau sh --c2emu --variante v7fix`), `ed`, `ar`, `ls`, `cp` gleich.
* Zwischenstaende sind wertvoll: pro Datei/Funktionsgruppe, die befehlsgleich ist, darf committet werden (Nachricht nennt den Stand); "G" erst bei 0 Abweichungsbloecken der ganzen Datei.
* Doku je AP `doc/userspace/wk_<ap>.md` (Deutsch, gemessen/Annahme); `README.md`, `doc/plan/*`, `doc/herkunft/` fasst nur die Zusammenfuehrung an.
* Bericht: Aussage G/E/A/F, Bytezahlen, Herkunft je Datei (V7 unveraendert / mit Abweichungen / rekonstruiert), neue Regeln mit Stellen, Regression, Commits, offene Punkte.

## 5. Zusammenfuehrung (Hauptsitzung)

Wie Plan 44 §6: Branches einzeln mergen, Host-Tests, Regression aller 45 G-Programme plus `sh` im Gast (sequentiell), Herkunftstabelle in `doc/userspace/README.md`
(Abschnitt "Werkzeugkette"), Stand in Plan 44 Stufe 4 und Plan 42 H7 nachtragen.

## 5a. Reihenfolge ab 2026-11-18 (Entscheidung Projektinhaber)

1. W10b (erledigt, `wk_w10b.md`): unser gebauter `c2` (98 % befehlsgleich) ist **funktional noch nicht** gleich -- seine Ausgabedatei ist stueckweise verfaelscht (Teile an falscher Stelle, wie Schreiben an falsche Dateipositionen; Ursache offen: `freopen`, Feldgroessen in `c2.h`, Daten-/BSS-Anordnung oder `libc_alt`).  Erster Punkt von W10, bevor Schalter eingebaut werden.  W10c (`wk_w10c.md`): Ursache gefunden -- nicht c2 selbst, sondern geratene Anker `__sibuf`/`__sobuf` in `libc_alt/c2.members` (stdin- und stdout-Puffer ueberlappten, weil unser Text 20 B kuerzer ist); korrigiert.  W10d (`wk_w10d.md`): gleicher Ankerfehler bei as, c1, login, ls, mv, passwd, cpp behoben; unser c2 liefert auf echo/cat/ed/tar **bytegleiche Ausgabe** wie der ausgelieferte.  Offen: groesserer c2-Testsatz, Neubau der sieben Programme mit `--libc alt`, `--check` login/ls/passwd meldet Kartenueberlappung (schon vor W10d, auf main gemessen 2026-11-19).  W10e (`wk_w10e.md`): Neubau der sieben Programme unveraendert (ls/mv/passwd/login G, cpp/c1/as Zahlen wie vorher); Kartenueberlappung per `karte_extra.txt` behoben, `--check` fuer alle Programme mit `link.txt` gruen (2026-11-19).  W10f (`wk_w10f.md`): unser c2 funktional gleich dem ausgelieferten auf 76 Eingaben (c0, c1, cpp, alle sh-Module, 13 Programme, alle 27 Kernelmodule); **Schritt 2 erledigt**: `-DXPUSH` (R1, verfeinert: Verschmelzen nur bei Rest 0) als Bauvariante `c2x`, 44 von 44 Modulen gleich Original-c2 + R1.  Naechster Schalter `-xcmpmem` (R4).
2. **W7 `as`** (*W7a erledigt 2026-11-18, `wk_w7a.md`: Karte sauber, 8 yacc-Tabellen = 1976 Worte verortet, Scanner handgeschriebenes C im lex-Rahmen, Kodierer 1C0C 4,5 KB; W7b: Grammatik `as.y` (171 Regeln) zurueckgewonnen, Gast-yacc erzeugt alle 1976 Tabellenworte wortgleich; W7c/W7d: Geruest bindet (Datentabellen, Rahmenfunktionen, Rest Platzhalter); der ausgelieferte c2 haengt bei Modulen mit mehr als ~10 KB initialisierter Daten -- seit W7e je ein Modul mit `noopt` in `link.txt`, Tabellen zusammenhaengend, Nicht-Zeiger-Worte gleich; W7f: Scanner (`yylex`, `plzlook` u. a.) rekonstruiert, W7g: BSS-Anordnung wie im Original, Symboltabelle; W7h: Ausdruecke, Abschnitte/Direktiven (14 Funktionen); W7j/W7k: Befehlskodierer vollstaendig (71 % befehlsgleich), c2-Runde haelt jetzt die Modulreihenfolge -- W7l/W7m: alle Parser-Aktionen; W7n: 12 weitere Funktionen; W7o: alle Platzhalter ersetzt, Quelle vollstaendig; 4192 von 5891 Befehlen gleich (71 %), Text 21824 statt 22092 B; W7p/W7q: Funktionstest im Gast gegen das Original (`asgegen.py`): Symboltabelle und Objektkopf je als ein Feld (Linker haelt Deklarationsreihenfolge nicht), Pass-0-Laengen in `encode`; W7r: Pass-0-Klassengruppen wie Original, `jr $n` nach vorn (Lexer prueft `s_x`), Gast-/tmp mit 500 Inodes; 66 von 75 Eingaben erzeugen bytegleiche `.o` W7s: Operandenfeld `g90b0` als ein Feld wie im Original (4-Operanden-`cpir`), crt0/execle/mcrt0/doprnt bytegleich (gemessen mit `neu.bin`, `wk_w7s.md`); W7t: `neu_c2.bin` uebersetzt 76 von 80 Eingaben bytegleich, die 4 uebrigen liefern wie das Original kein `.o` -- **`as` funktional gleich** auf diesem Testsatz; W7u: Testsatz um 22 Kernelmodule und 8 sh-/mkfs-Module erweitert, alle gemessenen bytegleich (offen: k_sys1/sys2/mbx/daten wegen voller /tmp-Diskette); der Syntaxfehler von `neu.bin` ist mit frischem Bau nicht reproduzierbar (vermutlich veraltetes Binary, `wk_w7u.md`); Befehlsgleichheit 4137/5891; W7i: Objektausgabe, Kodierer-Helfer (11 Funktionen; Zaehlung erfasst ungerufene Funktionen noch nicht); fuer `as` schaden R1/R2/R4 (abgeschaltet) -- Hinweis fuer W10: `as` wurde mit einem c2 gebaut, der diese Formen schon wie der ausgelieferte erzeugt*) in kleinen Schritten (Triage, yacc-Grammatik, Scanner `plzlex`, Codeerzeugung) -- groesste echte Luecke, Voraussetzung fuer W9 und die E-Glieder von `libc.a`.
3. W10 weiter (Schalter im `c2`), dann gemeinsam fuer die Restbloecke von `c1`, `c2`, `cpp` und `as`.
4. W9 Selbsthosting mit beiden Ketten; zuletzt W11 (Herkunft ZEUS/WEGA).

## 6a. W10: Original- und angepasste Werkzeugkette (Auftrag des Projektinhabers 2026-11-18)

**Ziel:** Alle Teile des Systems bytegleich **im MUTOS-Gast** bauen, ohne Zwischenergebnisse (`.s`) auf dem Linux-Host zu patchen.

**Zwei Werkzeugketten nebeneinander:**
1. **Original-Werkzeugkette** -- die rekonstruierten, bytegleichen `cc c0 c1 c2 as ld` (+ `libc.a`, `crt0.o`).  Bleibt unveraendert; sie ist das Rekonstruktionsziel.
2. **Angepasste Werkzeugkette** -- daneben, unter eigenen Namen (die Originale werden nicht ersetzt):
   * ein **modifizierter `cc`** (Name *Annahme*, z. B. `xcc`; 8-Zeichen-Grenze beachten) mit einem Parameter, der waehlt, ob der unveraenderte bytegleiche `c2`
     oder ein **modifizierter `c2`** (z. B. `/usr/lib/c2x`) laeuft, und der dessen Schalter durchreicht;
   * der **modifizierte `c2`** aus unserer `c2`-Quelle (W5) mit **Schaltern**, die das Verhalten aelterer c2-Staende nachbilden.  Ohne Schalter verhaelt er sich
     wie der ausgelieferte `c2`.

**Begruendung (gemessen, `wk_w5e.md`, `wk_w6.md` Teil 14):** die Originale wurden mit einem aelteren c2-Stand gebaut als dem ausgelieferten -- auch `c2` selbst, `cpp`
und Teile von `c1`; ihre Restbloecke (Blockanordnung, `JR`/`JP`, fehlende `BIT`-Umformung) erklaert keine Quellform.  Bisher bildet das Regelmodell auf dem Host
(`uspace.c2_emu_s`, R1-R133, programmgebundene Saetze) diesen Unterschied als Textersetzung nach.

**Schritte (je klein, mit Gegenprobe):**
1. Regeln nach gemeinsamem Auftreten ueber die Programme gruppieren (`userspace/c2/gegenprobe_regeln.tsv`) -> Hypothese, wie viele c2-Staende/Schaltergruppen es gibt;
   programmgebundene 1-Stellen-Regeln auf Ueberanpassung pruefen (erklaert eine Quellform sie doch?).  Die Zahl der noetigen Schaltergruppen ist selbst ein Herkunftsbefund (W11).
2. Erste Schaltergruppe in die `c2`-Quelle (allgemeine Regeln R1-R10 u. a.); Abnahme: fuer alle Module der Gegenprobe liefert `c2x` mit Schalter dasselbe `.s`
   wie ausgelieferter `c2` + Regelmodell (`tools/userspace/c2gegen.py`).
3. `xcc` aus unserer bytegleichen `cc`-Quelle ableiten (Parameter, Pfad zu `c2x`, Schalter durchreichen); die bytegleiche `cc`-Quelle bleibt unveraendert daneben.
4. Gast-Bauweg in der Pipeline (Variante neben `neu_c2`/`neu_c2_s`): Bau mit `xcc` und den Schaltern des Programms, **kein** Host-Patch; an einem Programm vorfuehren,
   dann alle G-Programme; Regelmodell bleibt als Pruefung (beide Wege muessen dieselben Bytes liefern).
5. Weitere Schaltergruppen und programmgebundene Saetze; zuletzt `c2`, `cpp`, `c1` selbst bytegleich mit `xcc` bauen (Henne-Ei: `c2x` wird mit der Original-Kette
   gebaut, muss dafuer nur richtig arbeiten, nicht bytegleich sein).  Kernelregeln K1-K6 einbeziehen.
6. Abnahme W9 (Selbsthosting) mit beiden Ketten: Original-Kette fuer alles, was sie bytegleich baut; angepasste Kette fuer den Rest.

*Stand 2026-11-18:* Schritt 1 erledigt (`wk_w10a.md`, `tools/userspace/c2gruppen.py`): **keine** einzelne Kette aelterer Staende (24 widerspruechliche Regelpaare), sondern
weitgehend unabhaengige Schalter; Vorschlag 9 Gruppen (`-xpush` R1, `-xcmpmem` R4 -- zusammen rund 400 der 774 Stellen --, `-xhzero`, `-xcopyprop`, `-xtestmem`, `-xexts`,
`-xjrange` mit Blockanordnung, `-xsh`, `-xdjnz`) plus Rest; 80 von 94 Regeln greifen in genau einem Programm, Ueberanpassungskandidaten benannt.
Vor Schritt 2: pruefen, dass unsere `c2`-Quelle (W5, 98 % befehlsgleich) als Optimierer **funktional** gleich dem ausgelieferten arbeitet (gleiche `.s` fuer alle Module).

**Ablage:** Quellen der angepassten Kette im Repository auf `main` (sie sind Werkzeug der Rekonstruktion, aendern kein Original); Abweichungen gegen die bytegleiche
Quelle je Stelle kommentiert.  Installation im Gast unter eigenen Namen auf einer eigenen Platte oder neben den Originalen -- die Originaldateien bleiben unangetastet.

## 6b. W11: Herkunft der Z8000-Portierung (Auftrag des Projektinhabers 2026-11-18)

**Frage:** Wer hat den V7-Compiler auf den Z8000 portiert -- der MUTOS-Hersteller selbst, oder stammt die Portierung (`c0`/`c1`/`c2`/`as`, Codetabellen,
Abschnittsdirektiven) aus einer aelteren Z8000-UNIX-Linie?

**Gemessen bisher (W0-W6):** MUTOS-`c1` ist V7-`c1` mit neuer Codeausgabe und neuen Tabellen im V7-Format (`cvopt`), `c2` ein V7-Geruest mit Z8000-Befehlstabelle,
`c0` fast reines V7, `as` kein V7 (yacc-Parser).

**Einordnung (Recherche des Projektinhabers, 2026-11-18):** Zilog **ZEUS war urspruenglich ein V7-System**; erst spaeter wurde daraus ein System-III-System,
und davon ist WEGA (P8000) abgeleitet.  Eine direkte Abstammung MUTOS <- WEGA ist damit unwahrscheinlich, eine **gemeinsame Vorlage** aber naheliegend:
der Z8000-Compiler der **fruehen V7-Fassung von ZEUS** (ein Vorgaenger von WEGA), aus dem sowohl MUTOS als auch die spaetere ZEUS/WEGA-Werkzeugkette stammen koennten.
Arbeitshypothese (*Annahme*, zu pruefen): MUTOS-`c0`/`c1`/`c2`/`as` = ZEUS-V7-Werkzeugkette (ggf. angepasst); WEGA traegt deren weiterentwickelte Fassung.
Die Quellenlage (Versionen, Jahre, erhaltene ZEUS-V7-Binaries oder -Handbuecher) ist noch mit Belegen festzuhalten.

**Vorgehen (Entwurf):**
1. Recherche: ZEUS-Versionsgeschichte (V7-Fassung, Uebergang zu System III), erhaltene Binaries/Handbuecher der V7-Fassung, andere fruehe Z8000-V7-Portierungen;
   Ergebnis mit Quellenangabe, Vermutetes markiert.  Findet sich eine ZEUS-V7-Werkzeugkette, ist sie der wichtigste Vergleichspartner (vor WEGA).
2. WEGA-Werkzeugkette (https://github.com/OlliL/P8000, lokale Kopie **ausserhalb** des Repositorys, nichts kopieren -- `original/wega/README.md`):
   Zeichenketten, Fehlermeldungen, Funktionsreihenfolge, Codetabellen (Format, Musterbuchstaben, Eintragszahlen), Assembler-Dialekt (`as_dialekt.md`),
   Abschnittsdirektiven (`$DATA`, `$SECTION`, `$CODE`), Registerkonvention, `c2`-Befehlstabelle -- je Pass gegen MUTOS vergleichen.
3. Gemeinsamkeiten ueber V7 hinaus (gleiche Z8000-spezifische Funktionen, gleiche Tabellenzeilen, gleiche Meldungen) sprechen fuer eine gemeinsame Vorlage;
   Unterschiede in den maschinenabhaengigen Teilen fuer unabhaengige Portierungen.  Ergebnis als Verwandtschaftstabelle je Pass, gemessen vs. *Annahme*.
4. Falls ein frueher Z8000-V7-Compiler auftaucht: derselbe Vergleich; ggf. erklaert er den **aelteren c2-Stand**, mit dem die MUTOS-Originale gebaut wurden (`wk_w5e.md`).

Nicht-Ziel: nichts aus WEGA/System III in die MUTOS-Quellen uebernehmen (Grundsatz "MUTOS bleibt V7"); WEGA ist nur Vergleichsmaterial.

## 6. Risiken und offene Fragen

* **yacc-Stand** (W2/W7): erzeugt V7-yacc die Original-Tabellen?  Wenn nicht: welcher yacc dann (Zilog-Werkzeugkette?), und reicht die generierte `.c` als belegte Quelle.
* **`as` passt nicht in `SMALL`-yacc**: bei `out of space` die Grammatik nicht aendern, sondern messen und berichten.
* **Bau der grossen Passe im Gast**: Zyklusgrenze (`lex` mit `-O` brach nach 18e9 Zyklen ab, E3d) und `symbol table overflow` in `as` (`dc`, E3c) -- Teilung in
  mehrere Dateien ist hier **keine** freie Wahl, sondern muss der Originalaufteilung folgen (Karte).
* **Gleitkomma** in `c0`/`c1` (Konstantenfaltung `double`): ob die ausgelieferte `libc.a` den Gleitkommateil enthaelt, ist bei `init` als fehlend gemessen (Stub `ffltpr`).
* Die Hippe-Sammlung (`original/hippe-v7/lib/c2`) ist ein PDP-11-Binary: nur Vergleich, nie Urheber.

## 7. Stand

*2026-11-17:* W0 erledigt (`wk_w0.md`), W1 `cc` und W3 `ld` **G** (`wk_w13.md`), Regression gleich.  W4 `c0` **G** (`wk_w4.md`).  W2 `cpp` **A** (`wk_w2.md`): 13 Restbloecke sind Codeanordnung des alten c2 -- G erst mit der c2-Quelle (W5).  Der Gast-yacc erzeugt die cpp-Tabellen wortgleich (gutes Zeichen fuer W7 `as`).  W8 `libc.a` (`wk_w8.md`): 111 von 140 Gliedern G, 24 E, 5 A; die ausgelieferte `libc.a` braucht **kein** c2-Modell (Stolperstein 1 betrifft nur `libc_alt`).  W5 `c2` (`wk_w5.md`, auf `main`): `c20.c` und `rmove` befehlsgleich, 4609/4717 Befehle, 28 Bloecke Blockanordnung.  W5e Gegenprobe erledigt (`wk_w5e.md`): Originale nicht mit dem ausgelieferten c2 gebaut; 82/94 Regeln bilden einen aelteren c2-Stand nach.  Offen bei c2: Blockanordnung (Hypothese `codemove`/`backjmp`, ungeprueft).  W6 `c1` (`wk_w6.md`, Zwischenstand auf `main`): Karte sauber, Codetabellen ueber `table.s` + `cvopt_z8k.py` bytegleich, Bau bindet (`link.txt`), `c10.c` vollstaendig (`cexpr`, `doinit`, `sreorder` aus dem Binary, W6d), Abschnittsausgabe `fphead`/`fptail` in c12; `c11.c` rekonstruiert (W6e/W6f, Reste in `dcalc`, `cbranch`, `pname`); `c12.c` vollstaendig, `c13.c` Daten (`opdope`/`opntab` 139 Eintraege, Z8000-`instab`/`branchtab`), alle 200 Zeichenketten an Originaladresse (W6g-W6i); 7057 von 7970 Befehlen gleich, 90 Bloecke, Daten gleich gross, BSS 8 B kurz (nach W6m); die Restbloecke sind ueberwiegend Effekte des aelteren c2-Standes (Teil 14) -> W10 (2026-11-18).  Offen: Restbloecke (`getree` 50, `lconst`, `unoptim`, `optim`, `acommute`, `cbranch`, `dcalc`, `pname`), libc-Teil Daten +8/BSS -4, W7 `as`, W9.

## 8. Naechster Schritt (urspruenglich)

W0 (Triage) als erster Agentenauftrag; danach Aufteilung W1-W5, W8 je nach W0-Befund.
