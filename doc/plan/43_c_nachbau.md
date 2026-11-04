# Entwurf 43: Die letzten 36 Kernelfunktionen bytegleich aus C

Stand 2026-11-04.  Status: **geplant**, Bearbeitung in einer eigenen Sitzung.  Vorgänger: `41_kernel.md` (K7/K8), `42_unix_herkunft.md` (H3–H8).

## 1. Ausgangslage (gemessen)

* Gesamtbau Stufe 1: **191 von 227** (vor Arbeitspaket 0; danach 199 von 230) Funktionen bytegleich aus C, Abbild 36 352 Byte BYTEGLEICH (`doc/herkunft/README.md` Abschnitt 5).
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
* Gesamtbau `--stufe 1 --boot`: **199 von 230 C-Funktionen** verwendet (230 = 227 + 3 neue), `Gesamt: BYTEGLEICH`, 36 352 Byte, Boot und alle 11 Arbeitstests ok.
* **Offen aus Punkt 4:** `gesamtbau.py --status` und der Abgleich von README §5 mit `gesamtbau.Welt` (Liste der verbleibenden Funktionen) -- nicht umgesetzt.
