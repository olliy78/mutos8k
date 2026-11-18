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

## 6. Risiken und offene Fragen

* **yacc-Stand** (W2/W7): erzeugt V7-yacc die Original-Tabellen?  Wenn nicht: welcher yacc dann (Zilog-Werkzeugkette?), und reicht die generierte `.c` als belegte Quelle.
* **`as` passt nicht in `SMALL`-yacc**: bei `out of space` die Grammatik nicht aendern, sondern messen und berichten.
* **Bau der grossen Passe im Gast**: Zyklusgrenze (`lex` mit `-O` brach nach 18e9 Zyklen ab, E3d) und `symbol table overflow` in `as` (`dc`, E3c) -- Teilung in
  mehrere Dateien ist hier **keine** freie Wahl, sondern muss der Originalaufteilung folgen (Karte).
* **Gleitkomma** in `c0`/`c1` (Konstantenfaltung `double`): ob die ausgelieferte `libc.a` den Gleitkommateil enthaelt, ist bei `init` als fehlend gemessen (Stub `ffltpr`).
* Die Hippe-Sammlung (`original/hippe-v7/lib/c2`) ist ein PDP-11-Binary: nur Vergleich, nie Urheber.

## 7. Stand

*2026-11-17:* W0 erledigt (`wk_w0.md`), W1 `cc` und W3 `ld` **G** (`wk_w13.md`), Regression gleich.  W4 `c0` **G** (`wk_w4.md`).  W2 `cpp` **A** (`wk_w2.md`): 13 Restbloecke sind Codeanordnung des alten c2 -- G erst mit der c2-Quelle (W5).  Der Gast-yacc erzeugt die cpp-Tabellen wortgleich (gutes Zeichen fuer W7 `as`).  W8 `libc.a` (`wk_w8.md`): 111 von 140 Gliedern G, 24 E, 5 A; die ausgelieferte `libc.a` braucht **kein** c2-Modell (Stolperstein 1 betrifft nur `libc_alt`).  W5 `c2` (`wk_w5.md`, auf `main`): `c20.c` und `rmove` befehlsgleich, 4609/4717 Befehle, 28 Bloecke Blockanordnung.  In Arbeit: W5e (Gegenprobe mit dem Original-`c2` im Gast, Restfunktionen), W6 `c1` (Regeln R230-R259).

## 8. Naechster Schritt (urspruenglich)

W0 (Triage) als erster Agentenauftrag; danach Aufteilung W1-W5, W8 je nach W0-Befund.
