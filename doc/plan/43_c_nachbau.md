# Entwurf 43: Die letzten 36 Kernelfunktionen bytegleich aus C

Stand 2026-11-04.  Status: **geplant**, Bearbeitung in einer eigenen Sitzung.  Vorgänger: `41_kernel.md` (K7/K8), `42_unix_herkunft.md` (H3–H8).

## 1. Ausgangslage (gemessen)

* Gesamtbau Stufe 1: **191 von 227** (vor Arbeitspaket 0; danach 216 von 230) Funktionen bytegleich aus C, Abbild 36 352 Byte BYTEGLEICH (`doc/herkunft/README.md` Abschnitt 5).
  Die übrigen 36 kommen in Stufe 1 aus der Referenz-Disassemblierung (`kernel/asm/ref`).
* Alle 36 **liegen bereits als C vor** und waren im Original C (Rahmen `call csv` / `jp cret`, Text folgt V7 bzw. der Hippe-Sammlung).
  Echter Handassembler sind nur die 26 Funktionen von `low` (V7 `mch.s`-Art) – die zählen nicht zu den 227 und bleiben Assembler.
* Gesamtbau Stufe 2 (alle 227 aus C) ist funktionsgleich und bootet (`doc/kernel/gesamtbau.md`; Neumessung mit heutigem Quelltext und Tests `ps`/`lp`: 2026-11-04, Ergebnis dort).
  **Ziel dieses Plans ist also nicht Funktion, sondern Bytegleichheit** – d. h. die genaue Quellform bzw. der Nachweis, dass sie mit unserem `c2` nicht erreichbar ist.

## 2. Bestand: die 36 Funktionen

Zahl = abweichende Wörter / Länge in Wörtern (`vergleich.py`; ein verschobenes Wort zählt alle folgenden mit – große Zahlen können eine einzige Verschiebung sein).

| Gruppe | Funktionen | vermutete Ursache |
|---|---|---|
| **A sehr nahe** (≤ 8 Wörter) | `mfree` 1/119, `exece` 1/389, `ttyretype` 1/116, `ttread` 1/139, `estabur` 8/20 | Quellform (wie bei `bcopy`, `iomove`, `trap`, `swtch` gelöst); `ttread`: frühes `return(0)` springt im Kernel per `JR` auf das letzte `JP cret`; `estabur`: `LDK`-Form für `ENOMEM` |
| **B mittel** (14–54) | `mapalloc` 14/37, `lpintr` 21/75, `malloc` 24/52, `mapstart` 28/44, `ssig` 39/52, `tloop` 42/79, `lpwrite` 42/124, `startup` 45/90, `putchar` 54/88 | Muster (B) „Wert erneut laden“, (D) `test @r2`, Blockanordnung `lp*`; `malloc`: zusätzliches `test r2`; `ssig`: `uap` wird neu vom Stapel geladen; `startup`: Konstante 0xFCFF |
| **C weit** (> 60) | `itrunc` 61/93, `alloc` 84/158, `update` 85/119, `lpcanon` 104/212, `readi` 108/206, `ialloc` 169/220, `getxfile` 177/401, `ttioccomm` 181/371, `clock` 210/260, `bmap` 263/308, `ttyinput` 281/458 | (B)/(C)/(E) aus `c_rueckbau.md` K7b; `getxfile`: Anordnung der zwei Kopfformate; `ttioccomm`/`ttyinput`: Kernel-Compiler baut `switch` über Sprungtabelle (`cmd/6`, Tabelle 8D3A), unser `cc` nicht; `clock`: Hilfsstück 040C am Anfang, Vergleich über R2 |
| **D `dev0.c`** (11 Funktionen, `fd*`) | `fdopen`, `fdclose`, `fdsub`, `fdstrategy`, `fdstart`, `fdintr`, `fdadj`, `fdread`, `fdwrite`, `fdphys`, `fdioctl` | im Original **ohne `-O`** übersetzt; älterer `c1` vergleicht Registervariablen über R2 (`LD R2,R13 ; CP R2,#1`); `fdstart`/`fdioctl` Zustandsautomat bzw. Sprungtabelle |

Quellen der Befunde: `doc/kernel/c_rueckbau.md` (Muster A–F, K7d), `doc/herkunft/<modul>.md` (Stand je Modul), `doc/herkunft/daten/rundlauf_soll.txt` (Sollwerte `NAHE`).

## 3. Werkzeuge (vorhanden) und nötige Ergänzungen

* `tools/herkunft/rundlauf.sh WORKDIR modul…` – ein Gastlauf, `cc -O -c`, Vergleich je Funktion, Exit 0/1/77.  **Höchstens ~8 Module je Lauf** (Diskette läuft sonst voll).
* **Varianten in einem Lauf:** Datei mit Kopien derselben Funktion unter anderen Namen (`mfreeA`, `mfreeB`, …), alle mit derselben Marke `/* KERNEL xxxx */`; Datei mit **absolutem Pfad** übergeben.  `vergleich.py -v` zeigt die abweichenden Wörter.
* `tools/kernel/gesamtbau.py --arbeit DIR --uebersetzen --stufe 1 --boot` – Endprobe; nimmt jede Funktion, die als bytegleich erkannt ist, automatisch aus C.  Ergebnis erst lesen, wenn die Endzeile im Log steht; bei parallelen Gastläufen `K1520EMU_NOBUILD=1`.
* **Ergänzung E1:** `rundlauf.sh` kennt nur `-O`.  Für Gruppe D einen Schalter ohne `-O` ergänzen (`gast_lauf.sh` kann es: `NUR_O` weglassen bzw. `dev0.c` wie im Gesamtbau ohne `-O`), damit `dev0` je Funktion geprüft wird statt nur im Gesamtbau.
* **Ergänzung E2 (optional):** kleiner Zähler „Wörter bis zur ersten Abweichung“ neben „abweichende Wörter“ in `vergleich.py`, damit Verschiebungen von echten Unterschieden unterscheidbar sind.

## 4. Vorgehen

Reihenfolge nach Ertrag je Gastlauf; nach jeder Gruppe Gesamtbau Stufe 1 und ein Commit je Modul (Regel aus `42_unix_herkunft.md` §3.4).

1. **Gruppe A (ein bis zwei Läufe).**  Je Funktion 4–8 Varianten in einer Probedatei:
   * `mfree`/`malloc`: Schleifenform und Vergleich von `m_size` (V7 `malloc.c` wörtlich, dann `!=`/`==`-Varianten, `register`-Reihenfolge).
   * `exece`/`getxfile`: Reihenfolge der Lokalen (zuerst deklariert = höchste Adresse), `(daddr_t)`-Umwandlungen an Aufrufstellen.
   * `ttread`: früher `return(0)` als `if`-Block vs. Fallthrough zum Ende; Hippe-Text wörtlich.
   * `ttyretype`: ein Wort – Kandidat Konstante/Typ einer Zählvariable.
   * `estabur`: `u.u_error = ENOMEM; return(-1);` gegen Formen mit Zwischenvariable / `goto err`.
2. **Gruppe B.**  Muster (B) „Wert erneut laden“ einmal systematisch klären, weil es in Gruppe B und C wiederkehrt: eine Probedatei mit ~10 kleinen Funktionen, die nur dieses Muster enthalten (Zuweisung an Lokale, danach Test bzw. `push` derselben Lokalen; Lokale `register`/nicht `register`, `long`/`int`, `static`).  Trifft keine Form das Kernelmuster, gilt (B) als **`c2`-Eigenheit, nachgewiesen** – dann die betroffenen Funktionen nicht weiter verfolgen.
   Danach `lp*` (Blockanordnung: Fortsetzungsblöcke hinter `JP cret`, zusammengelegte Endstücke) mit Formen `goto out`/früher `return`/`else`-Ketten.
3. **Gruppe C.**  Nur nach Klärung von (B):
   * `ttioccomm`/`ttyinput`: prüfen, ab welcher Fallzahl/Dichte unser `cc` eine Sprungtabelle baut (Probedatei mit `switch` über 4, 6, 8, 12 dichte Fälle).  Baut er nie eine, ist die Sprungtabelle ein Compilerunterschied → Abbruch für diese zwei.
   * `getxfile`, `readi`, `bmap`, `clock`: Hippe-/V7-Text wörtlich als Ausgangspunkt, dann gezielt die Stelle der ersten Abweichung.
4. **Gruppe D.**  E1 umsetzen, dann `dev0` je Funktion; der R2-Vergleich ist vermutlich `c1`-Stand → zuerst eine Probe, ob irgendeine Quellform unseren `c1` zu `LD R2,R13 ; CP R2,#1` bringt (z. B. Vergleich über `(int)`-Umwandlung, Ausdruck statt Variable).

**Abbruchkriterium je Funktion:** zwei Läufe mit je ≥ 6 Varianten ohne Annäherung (Zahl der abweichenden Wörter sinkt nicht) → Status bleibt `NAHE`, Ursache in `doc/herkunft/<modul>.md` festhalten (gemessen: welche Varianten, welche Wörter).

## 5. Was mit dem Rest geschieht (Entscheidung des Projektinhabers nötig)

Für Funktionen, deren Abweichung als Compilerunterschied nachgewiesen ist:

* **(a) Empfohlen:** Status `NAHE` belassen.  Stufe 1 (bytegleich, Rest aus Referenz-Assembler) bleibt der Beweis für das Original; Stufe 2 (alles aus C, funktionsgleich + Boot- und Arbeitstest) der Beweis für den Quelltext.
* (b) Plan B aus `c_rueckbau.md`: die `.s` unseres Kompilats an den benannten Stellen von Hand nachbessern – erreicht Bytegleichheit, beweist aber nichts über die Quelle.
* (c) Den Kernel-`c2` nachbilden (Blockanordnung, Endstückzusammenlegung, Neuladen) – groß, nur sinnvoll, wenn ein Binärstand des älteren `c2` auftaucht.

## 5a. Befund 2026-11-04: Stufe 2 bootete mit heutigem Quelltext nicht -- Ursache im Werkzeug, behoben (gemessen)

* Symptom: Boot und Anmeldung gingen, danach `parity during waiting - segment = 0 offset = 0 + ??` (`trap.c` Fall 11) und die Shell hing.
  Gegenprobe Stufe 1 auf demselben Emulator: BYTEGLEICH, alle 11 Arbeitstests ok -> Emulator nicht schuld.
* Ursache: `gesamtbau.tote_marken` nullte in Stufe 2 auch die Sprungtabelle 8D46 von `ttyoutput`, das seit 2026-11-03 bytegleich aus C kommt
  (nur verschoben).  Beleg: Stufe-2-Bau mit allen nicht bytegleichen Funktionen aus Assembler = Stufe-1-Abbild bis auf genau diese 12 Byte.
  Behoben: Stufe 2 setzt Funktionsname + Abstand ein.  Danach Stufe 2 (227/227 aus C): bootet, alle 11 Arbeitstests ok (`doc/kernel/gesamtbau.md`).
* Die Liste der 36 in `doc/herkunft/README.md` §5 weicht von der Einstufung des Gesamtbaus ab.  `gesamtbau.Welt` (heute): 27 LAENGE, 7 ABW, 2 RELOC.
  Zusaetzlich zur README-Liste: `writei`, `namei`, `lpxfer` (LAENGE) und `core`, `setregs` (RELOC); dafuer gleich: `fdsub`, `fdstrategy`, `fdadj`, `fdread`, `fdwrite`.
  **LAENGE bei `writei`/`namei`/`lpxfer` ist kein Codefehler:** `vergleich.py` meldet sie bytegleich; hinter ihnen liegt Code, der in `funktionen.txt` fehlt
  und den der Gesamtbau der Funktion zuschlaegt: 274C `max` (V7 `rdwri.c`, ohne Aufrufer), 39A0 `schar` (Aufrufer `core`), 695A (Druckerteil, ohne Aufrufer).

### Schritt 0 fuer die neue Sitzung (vor Gruppe A)

1. **`schar` 39A0** in `nami.c` hinter `namei` als eigene Funktion (V7 `nami.c`/`pipe.c`), **`max` 274C** in `rdwri.c` vor `min`, die Funktion bei **695A** in `lp.c`
   hinter `lpxfer`; alle drei in `funktionen.txt` eintragen.  Dann sollten `namei`, `writei`, `lpxfer` im Gesamtbau GLEICH werden (+3 bis +6 Funktionen).
2. **`core`:** `namei(schar, 1)` wie V7 statt `uchar` (falsche Relokation 39A0 statt 39BA).  Folge des Fehlers: Ein core dump liest den Namen "core"
   aus dem Benutzerraum statt aus dem Kernel.
3. **`setregs`:** `bcopy((caddr_t)u.u_dbuf, (caddr_t)u.u_exname, DIRSIZ)` wie V7 (`u_comm`); heute sind die Argumente vertauscht (Relokationen u+0x10E/u-0x10E).
   Folge: `u_exname` (Befehlsname fuer `ps`) wird nie gesetzt.
4. README §5, `rundlauf_soll.txt`, Zaehlung "n von 227" mit der Einstufung von `gesamtbau.Welt` abgleichen; ein `gesamtbau.py --status`
   (Status und falsche Relokationen je Funktion, Vorlage `status.py`/`reloc_check.py` der Sitzung 2026-11-04) ergaenzen und
   `rundlauf_soll.txt` daraus pruefen lassen, damit die beiden Zaehlungen nicht wieder auseinanderlaufen.

## 6. Abschluss je Funktion / je Modul

1. C-Quelle ändern, Rundlauf grün, `rundlauf_soll.txt` `NAHE` → `GLEICH`.
2. `doc/herkunft/<modul>.md`: Form, die getroffen hat, und Lauf.  `c_rueckbau.md`: Eintrag als `[UEBERHOLT]` markieren.
3. Gesamtbau `--stufe 1 --boot`: BYTEGLEICH, neue Zahl „n von 227 aus C“ in `doc/herkunft/README.md` §5, `README.md`, `42_unix_herkunft.md` §4a.
4. `pytest -q` grün, Commit je Modul.

## 7. Stand Arbeitspaket 0 (2026-11-04, gemessen)

* Punkte 1-3 erledigt: `schar` (39A0, `nami.c`), `max` (274C, `rdwri.c`), `lpsgtty` (695A, `lp.c`; V7-/Hippe-Name, Quelle `original/hippe-v7/usr/sys/dev/lp.c`,
  im Kernel ohne Aufrufer, `cdevsw[5].d_sgtty` ist `nodev`) als eigene Funktionen, in `funktionen.txt` eingetragen; `core` ruft `namei(schar, 1)`; `setregs` kopiert `u_dbuf` nach `u_exname`.
* Rundlauf (`nami rdwri lp sig sys1`): `schar`, `max`, `lpsgtty` GLEICH, `core`, `setregs` weiter GLEICH; `rundlauf_soll.txt` ergaenzt.
* Gesamtbau `--stufe 1 --boot`: **216 von 230 C-Funktionen** verwendet (230 = 227 + 3 neue), `Gesamt: BYTEGLEICH`, 36 352 Byte, Boot und alle 11 Arbeitstests ok.
* Punkt 4 erledigt: `gesamtbau.py --arbeit DIR --status` (baut nichts, braucht die Objekte in `DIR/obj`) zeigt je Funktion Status und erste falsche Relokation und gleicht mit `rundlauf_soll.txt` ab.
  Messung: 230 Funktionen, 199 GLEICH, 24 LAENGE, 7 ABW, keine RELOC; Soll und Gesamtbau stimmen ueberein (Exit 0).  Verbleibend 31 = 25 NAHE + 6 `dev0` (`fdopen`, `fdclose`, `fdstart`, `fdintr`, `fdphys`, `fdioctl`); die "36" aus §1/§2 sind damit ueberholt.

## 8. Stand Gruppe A (2026-11-04, gemessen)

* **`estabur` GLEICH** (`ureg.c`): Blockanordnung `if (<= 256) return(0);` zuerst plus `u.u_error = u.u_error = ENOMEM;` (nur ein verwendeter Zuweisungswert gibt `ldk r2,#12 ; ldb u_error,rl2`).  Details `doc/herkunft/ureg.md`.
* **`mfree`, `exece`, `ttyretype`, `ttread`: ein Wort `cp r2` statt `cp r3`; `malloc` zusaetzlich ohne das `test r2` des Kernels.**  Probe: 9 Vergleichsformen (Zeigerdifferenz), 8 Formen (Byte gegen 0377, `ttyretype`/`ttread`), 4 Formen von `m_size -= size`: keine liefert `cp r3` bzw. `test r2`.
  Im ganzen Kernel steht hinter `ld r2,r3` sechsmal `cp r3,#..` (malloc 2x, tty2 3x, sys1 1x), nie `cp r2`; in allen bytegleichen Funktionen kommt das Muster nicht vor.  Wertung: **`c2`-Eigenheit, nachgewiesen**, Status bleibt `NAHE`.
  Das Muster betrifft auch Gruppe B/C (Muster (B)); dort nicht weiter als Quellformproblem verfolgen, wo die erste Abweichung ein `cp r3` ist.
* Neue Zaehlung: siehe `doc/herkunft/README.md` §5.

## 9. Stand Gruppe B (2026-11-04, gemessen)

Bytegleich geworden (Gesamtbau Stufe 1 `--boot`: **216 von 230**, BYTEGLEICH, Boot und 11 Arbeitstests ok): `mapalloc`, `mapstart`, `ssig`, `tloop`, `putchar`, `startup`, `lpwrite`.  Die Formen, die getroffen haben:

* **Explizit vergleichen** (`!= 0` statt Wahrheitswert) gibt `test @r2` statt `ld r3,@r2 ; test r3` (`mapalloc`, `mapstart`).
* **Initialisierung bei der Deklaration** gibt das erneute Laden der Lokalen aus dem Stapel: `uap = ...` im Kopf (`ssig`), `daddr_t nb = bap[i]` im inneren Block (`tloop`).  Das ist das Muster (B) "Wert erneut laden" -- es war Quellform, keine `c2`-Eigenheit.
* **Schleife als eine Bedingung** `while (a == 0 && --t != 0);` gibt `DJNZ` (`putchar`); die DJNZ-Frage ist fuer diesen Fall beantwortet.
* **Typ- und Umwandlungsformen:** `(int)c << 8` (SLA statt SLL) und `register char t` (`startup`).
* **Hippe-Struktur** mit `while`/`break` statt `goto` (`lpwrite`).

Offen aus Gruppe B: `lpintr` -- Endstueckzusammenlegung hinter dem letzten statt dem ersten Aufruf, `c2`-Eigenheit (Schluss aus dem Aufbau).  `malloc`/`mfree` siehe §8.

Fehlerquelle der Sitzung: `gesamtbau.py --uebersetzen` ohne `K1520EMU_NOBUILD=1` stoesst `dev.sh` an; laeuft im Emulatorprojekt gleichzeitig ein Build, scheitern alle sechs Gastlaeufe still (leere `g*.log`, `FileNotFoundError ... confO.o`).  Immer mit `K1520EMU_NOBUILD=1` starten.

Weiter mit Gruppe C: Muster (B) und (D) sind geklaert; `itrunc`, `lpcanon`, `alloc`, `update`, `readi`, `ialloc` zuerst mit diesen Formen, danach `getxfile`, `bmap`, `clock`, dann die Sprungtabellen (`ttioccomm`, `ttyinput`).

## 10. Stand Gruppe C (2026-11-04, gemessen)

Bytegleich geworden (Gesamtbau Stufe 1 `--boot`: **216 von 230**, BYTEGLEICH, Boot und 11 Arbeitstests ok): `itrunc`, `update`, `clock`.  Verbleibend 20 = 14 "nahe" (`bmap`, `readi`, `malloc`, `mfree`, `alloc`, `ialloc`, `exece`, `getxfile`, `lpcanon`, `lpintr`, `ttioccomm`, `ttyinput`, `ttyretype`, `ttread`) + 6 `dev0`.

Formen, die getroffen haben: Deklaration mit Initialisierung im Block (`itrunc`: `daddr_t bn`, `update`: `struct filsys *fp`), `display();` am Anfang von `clock` (V7), `(lbolt = lbolt + t) >= HZ`.

**`c2`-Eigenheiten, gemessen (Quellform ohne Wirkung):**
1. `ld r2,r3 ; cp r3,#..` im Kernel gegen `cp r2,#..` bei uns (6 Stellen im Kernel, nie `cp r2`): `mfree`, `exece`, `ttyretype`, `ttread`, `malloc` (§8).
2. Kernel behaelt das `test`/`testl` nach `sub`/`subl` und Speichern, unser `c2` streicht es: `malloc`, `readi` (§8, `rdwri.md`).
3. Kernel tests/pusht den Stapelplatz nach dem Speichern, unser `c2` das Register: `alloc`, `ialloc`, `bmap` -- umgehbar nur mit Initialisierer oder `for`-Kopf, nicht fuer Variablen auf Funktionsebene (`alloc.md`).
4. Endstueckzusammenlegung hinter dem letzten statt ersten Aufruf: `lpintr`.
5. Sprungweite: Kernel `jr` bei -254 Byte, Werkzeug `jp`: `ttioccomm` (`tty2.md`).

Offen ohne Befund: `lpcanon` (Anordnung des `default`-Zweiges), `getxfile` (Verzweigungsstruktur im Kopfteil: Kernel prueft `bit 8` einmal vor dem gemeinsamen Teil, wir pro Zweig), `ttyinput` (ein Wort weniger im Kernel).  Dann `dev0` (Gruppe D, ohne `-O`).

## 11. Stand Gruppe D (2026-11-04, gemessen)

`dev0.c` **11 von 11 bytegleich** (E1 umgesetzt: `OHNE_O=1` in `rundlauf.sh`, Sollwerte `rundlauf_soll_dev0.txt`).  Gesamtbau Stufe 1 `--boot`: **216 von 230**, BYTEGLEICH, Boot und 11 Arbeitstests ok.  Verbleibend 14, alle "nahe": `bmap`, `readi`, `malloc`, `mfree`, `alloc`, `ialloc`, `exece`, `getxfile`, `lpcanon`, `lpintr`, `ttioccomm`, `ttyinput`, `ttyretype`, `ttread`.

Die Annahme in §2/§4 (alter `c1` mit `LD R2,R13 ; CP R2,#1`) stimmte: der Original-`c1` laedt jeden Ganzzahloperanden vor dem Vergleich mit einer Konstanten nach r2.  Der Gast-`c1` tut das nicht; die einzige gefundene Quellform ist das Kommaglied (Makro `R2`, siehe `doc/herkunft/dev0.md`).

Fuer die verbleibenden Funktionen: die `c2`-Eigenheiten aus §10 (1-5) sind weiter ungeklaert, aber dieselbe Methode (Kommaglied, Zuweisungswert im Vergleich, Initialisierer) hat bei `dev0` 6 weitere Funktionen geloest.  Noch nicht angewandt auf `cp r3,#..` (§8) und `test` nach `sub` (§10 Nr. 2): z. B. `((x), (x))` auf `bp - mp` in `mfree`, `((diff = ..), diff) <= 0` in `readi`.

## 12. Nachprobe der c2-Muster mit den Methoden aus Gruppe D (2026-11-04, gemessen)

* `cp r3,#..` (mfree, malloc, ttyretype, ttread, exece): 11 weitere Formen (Kommaglied `(0, bp-mp)`, `(t = bp-mp, t)`, `&& 1`, `|| 0`, `(int)..+0`, Zuweisung an Globale; Byte-Vergleich mit `(c = ubyte(*cp++), c)`, `(0, ubyte(*cp++))`, Kommaglied vor dem Vergleich) -- alle `cp r2`/`cp r12`, nie `cp r3`.  Zusammen mit §8 und `malloc.md`: 32 Formen, **`c2`-Eigenheit belegt**; Status bleibt `NAHE`.
* `test r2`/`testl` nach `sub`/`subl` (malloc, readi): 13 Formen (`((diff = ..), diff) <= 0`, `diff = .., diff <= 0`, Cast, lokale Variable, `-diff >= 0`; `m_size` als Zuweisungswert, getrennt, `x = ..; m_size = x`, Kommaglied) -- keine behaelt den Test (nur `test @r13` auf den Speicher bei einer Kommaform, andere Befehlsfolge).  **`c2`-Eigenheit belegt**.
* Damit sind `mfree`, `exece`, `ttyretype`, `ttread` (je 1 Wort), `malloc`, `readi` abgeschlossen: nicht erreichbar mit unserem `c2`.
* Offen mit Aussicht auf Quellform: `lpcanon`, `getxfile`, `ttyinput`.  Nicht mit Quellform erreichbar (c2): `alloc`, `ialloc`, `bmap` (§10 Nr. 3), `lpintr` (Nr. 4), `ttioccomm` (Nr. 5).

## 13. Stand `lpcanon` (2026-11-05, gemessen)

`lpcanon` bytegleich: `default:` steht zuerst im `switch` und faellt in `case ' '` (Marke `sp:`), der Rest liegt hinter dem `switch` (`cr:`, `rest:`, `goto sp`); Einzelheiten `doc/herkunft/lp.md`.  Die Form ist logisch gleichwertig zur alten (alle uebrigen Faelle enden mit `return`).  Gesamtbau Stufe 1 `--boot`: **217 von 230**, BYTEGLEICH, 11 Arbeitstests ok.

## 14. Abschluss (2026-11-05, gemessen)

* `getxfile` bytegleich (`doc/herkunft/sys1.md`, Nachtrag): beide `ETXTBSY`-Pruefungen im Zweig des grossen Kopfes, `goto bad` nach `estabur`-Fehler (wie V7, die alte Annahme "Rueckgabe 1" war falsch), `ctos` im Overlay-Zweig.
* `ttyinput` bleibt: der Original-`c2` streicht vor `t_xstate ^= XPAGE` ein noetiges Laden (Fehler im Original, `doc/herkunft/tty2.md`).
* Gesamtbau Stufe 1 `--boot`: **218 von 230**, BYTEGLEICH, 11 Arbeitstests ok.  Die 12 verbleibenden Funktionen haben alle eine gemessene `c2`-Ursache; mit Quellformen ist hier nach heutigem Stand nichts mehr zu holen.
* Offen ist nur noch die Entscheidung aus §5 (empfohlen: Status `NAHE` belassen).

## 15. c2-Modell fuer den Kernel: 230 von 230 (2026-11-09, gemessen)

Methode aus dem Userspace (`doc/userspace/README.md`, `uspace.c2_emu_s`): der Gast-`cc -O -S` (c0/c1/c2 unveraendert) liefert die `.s`,
`tools/kernel/c2_modell.py` schreibt sie mit Musterregeln um, der Original-`as -u` im Gast assembliert.  Jede Regel ist an die Funktionen
gebunden, an denen sie gemessen wurde, und zaehlt ihre Stellen; die 218 Funktionen, die ohne Modell bytegleich sind, werden nicht beruehrt.

| Regel | Unterschied des aelteren Kernel-`c2` | Funktionen (Stellen) |
|---|---|---|
| K1 | vergleicht das Original-, nicht das Kopieregister (`ld r2,r3 ; cp r3,#k`) | mfree, malloc, exece, ttyretype, ttread, ttioccomm (je 1) |
| K2 | behaelt `test`/`testl` nach `sub`/`subl` und Speichern | malloc, readi (je 1) |
| K3 | testet bzw. pusht den Stapelplatz statt des gerade gespeicherten Registers | alloc 1, ialloc 1, bmap 3 |
| K4 | legt das gemeinsame Endstueck hinter den letzten Aufruf | lpintr 1 |
| K5 | kurze Spruenge an der Weitengrenze (`jr ne` bei -254 Byte als `wval %EE81`, weil der Gast-`as` ablehnt; dazu ein `jr`) | ttioccomm 2 |
| K6 | streicht ein noetiges Laden vor `xor` (Fehler des Originals, `doc/herkunft/tty2.md`) | ttyinput 1 |

Ausserdem eine Quellform ohne Modell: `ialloc` `for(adr = (daddr_t)SUPERB+1; ...)` (gibt `ldl rr2,#2` wie der Kernel; `SUPERB+1` gibt `ldk ; exts`).

**Ergebnis:** `gesamtbau.py --uebersetzen --c2modell --stufe 1 --boot`: **230 von 230 C-Funktionen**, `Gesamt: BYTEGLEICH`, 36 352 Byte, 11 Arbeitstests ok.
Ohne `--c2modell` bleibt es bei 218 von 230 (`rundlauf_soll.txt` beschreibt diesen Bau).

**Aussagekraft** (wie Userspace): belegt ist *C-Quelle + ausgelieferter Compiler + Regeln K1-K6 = Originalbytes*; nicht belegt ist, dass der
alte `c2` genau diese Regeln hatte.  Die Regeln greifen an 1 bis 6 Stellen (zusammen 19) und sind kernelspezifisch; K5 ist ein
Assembler-Behelf wie Userspace R16.  K6 baut den Fehler des Originals bewusst nach: ein Kernel aus diesem Weg hat ihn auch.
Damit ist die Entscheidung aus §5 praktisch als Mischung aus (a) und (c) gefallen: Status `NAHE` fuer den reinen Bau bleibt,
das Modell ist ein dritter, dokumentierter Bauweg.  Test: `tests/test_kernel_c2_modell.py` (Regeln auf dem Host).
