# Bekannte Fehler im Originalcode (latente Fehler)

Stand 2026-11-23.  Gesammelt bei der Rekonstruktion der Werkzeugkette (Plan 52, W7 `as`, W10 `c2`/`c2x`).

Gemeint sind Fehler, die **im Original stecken**, dort aber nicht wirken, weil die konkrete Anordnung im Speicher oder die
Laufzeitumgebung sie verdeckt.  Sie werden sichtbar, sobald sich Anordnung oder Compilerregeln aendern (anderer `c2`-Stand,
neue Variablen, Bau auf dem Host).

* Auf **`main`** (bytegleiche Rekonstruktion) bleiben sie **absichtlich erhalten** -- sie gehoeren zum Original.  Code, der
  daneben neu entsteht (z. B. `c2x`), wird um sie herum gebaut.
* Auf **`mutos-plus`** werden sie behoben (Plan 53), damit alles mit einem einheitlichen Compiler-Regelsatz funktional gebaut
  werden kann.

Jeder Eintrag ist *gemessen* (mit Fundstelle), Annahmen sind markiert.

## 1. Echte latente Fehler

### F1 `c2`: Ueberlauf hinter `ophash` in `opsetup()`

* **Ort:** `userspace/c2/c20.c`, `opsetup()` (Zeile ~543); V7-Vorlage `original/unix-v7/usr/src/cmd/c/c20.c:381`.
* **Fehler:** Die Grenzpruefung beim linearen Sondieren lautet `if (ophp > &ophash[OPHS])` statt `>=`.  Bei einer Kollision
  im letzten Eintrag (`ophash[78]`) wird `ophash[79]` -- ein Wort **hinter** dem Feld -- gelesen und, wenn es 0 ist, mit
  einem `optab`-Zeiger beschrieben.  Die Suchfunktion `oplook()` derselben Datei (V7 Zeile 415) prueft richtig mit `>=`.
* **Im Original verdeckt:** das Wort hinter `ophash` gehoert einem Nachbarn, dem der Zeiger nicht schadet.
* **Sichtbar geworden:** W10p/W10q (`doc/userspace/wk_w10q.md`).  In `c2x` lag die neue BSS-Variable `xfl` dort; sie wurde
  ohne Schalter mit `0x4BB6` ueberschrieben, und R4 war eingeschaltet (nur 9/65 Module gleich dem ausgelieferten `c2`).
* **Umgehung auf `main`:** `xfl` in den initialisierten Daten (`int xfl = 0;`), der Ueberlauf bleibt.
* **Behebung (`mutos-plus`):** `>=` statt `>`.  Der Fehler stammt aus V7 selbst (auch PDP-11-`c2`).

### F2 `c2`: Lesen ueber Nullzeiger in `retopt()` und `iterate()`

* **Ort:** `userspace/c2/c21.c`, `retopt()` (`p == 0`, wenn der erste Block kein `call csv` hat) und `iterate()`
  (`p->op <= JSW` schliesst `op 0` ein, `p->ref == 0`); gemessen in W10c (`doc/userspace/wk_w10c.md`, Punkt 2).
* **Im Original verdeckt:** unter MUTOS ist Adresse 0 des Datensegments lesbar; der gelesene Wert fuehrt zu keiner falschen
  Entscheidung (*Annahme*, durch 76 bytegleiche Funktionsvergleiche gestuetzt).
* **Sichtbar geworden:** ein Bau der `c2`-Quellen auf dem Linux-Host stuerzt mit Segfault ab.
* **Behebung (`mutos-plus`):** Nullpruefung vor dem Zugriff.  Ob die V7-Vorlage dieselben Stellen hat, ist nicht geprueft.

### F3 `as`: uninitialisiertes lokales Feld `loc2[3202]` in `main`

* **Ort:** `userspace/as/as_main.c`, `main`; W7u (`doc/userspace/wk_w7u.md`).
* **Fehler:** Die Hashtabelle liegt auf dem Stack und wird nicht geloescht; der Code setzt voraus, dass sie mit Nullen beginnt.
* **Im Original verdeckt:** der Kernel loescht beim `exec` das ganze Segment (`kernel/c/sys1.c:304`), der Stack ist beim ersten
  Aufruf von `main` also leer.
* **Wirkt bei:** jedem anderen Laufzeitsystem (Host-Bau, anderer Kernel, Aufruf aus einer tieferen Stackposition).
* **Behebung (`mutos-plus`):** Feld ausdruecklich loeschen (oder `static`).

### F4 Kernel `ttyinput`: Fehlcode des alten `c2` (Regel K6)

* **Ort:** `kernel/c/tty2.c`, `ttyinput`, `tp->t_xstate ^= XPAGE`; `doc/herkunft/tty2.md` (Nachtrag 2026-11-05),
  `tools/kernel/c2_modell.py` K6.
* **Fehler:** Kein Fehler im C-Text, sondern im **Compiler**: der alte `c2` laesst das Laden `ld r2,t_xstate` weg und rechnet
  mit einem fremden Inhalt von `r2`.  Der Original-Kernel kippt `XPAGE` deshalb nicht zuverlaessig.
* **Auf `main`:** der bytegleiche Kernelbau reproduziert den Fehler absichtlich (K6).
* **Behebung (`mutos-plus`):** Kernel ohne K6 bauen; `c2x` bekommt dafuer keinen Schalter, der den Fehler einschaltet,
  ausser fuer den bytegleichen Nachweis.

### F5 Kernel `sbreak()`: keine Pruefung Halde gegen Stapel

* **Ort:** Kernel `sbreak()` (`kernel/c/sys1.c` bzw. Speicherverwaltung); gemessen in W10w (`doc/userspace/wk_w10w.md`).
* **Fehler:** `sbreak()` prueft nicht, ob die wachsende Halde in den Stapel laeuft; im 64-KB-Prozess kollidieren beide stillschweigend.
* **Im Original verdeckt:** die ausgelieferten Programme bleiben knapp darunter -- `c2` braucht bei `as_code` 61K Halde (gemessen mit `c2 -`).
* **Sichtbar geworden:** `c2x` (6-7 KB groesser) liefert bei `as_code` 0 Byte oder haengt, ohne Fehlermeldung.
* **Behebung (`mutos-plus`):** Kollisionspruefung in `sbreak()` (Fehler `ENOMEM` statt stiller Zerstoerung).  Ob V7 hier prueft, ist nicht verglichen.

### F6 `c2`: `addsob()` liest `refc` eines `dec`-Knotens, den nichts setzt (djnz-Entscheidung haengt vom Heap-Inhalt ab)

* **Ort:** `addsob()` (`userspace/c2/c21.c`, Zeile `if (p->refc < p1->ref->refc) continue;`); V7 hat dieselbe Zeile (`original/unix-v7/usr/src/cmd/c/c21.c`, ~255).
* **Befund (Quelltext gelesen, *nicht im Gast gemessen*):** Instruktionsknoten bekommen `refc` in `input()` nie gesetzt (c20.c, Zweige `default`/`CBR`/`JBR`: `op`, `subop`, `labno`, `code`); `refcount()` setzt nur `refc` der Marken (`LABEL`). In V7 nummeriert `jumpsw()` vorher alle Knoten (`p->refc = ++t`); im MUTOS-c2 wird `jumpsw()` nie aufgerufen (c20.c "no jumpsw()"; Kommentar c21.c "nothing calls it"). Folge: `p->refc` des `dec`-Knotens ist der **Rest des Heaps** aus der vorigen Funktion (`alloc()` nullt nicht, `lasta = firstr` je Funktion), verglichen mit dem Referenzzaehler der Zielmarke. Nur Knoten, die nach einer Nummerierung angelegt werden (`insertl`, R34), setzen `refc = 0` selbst.
* **Folge (*Annahme*, passt zu W10x):** jede Aenderung der Heap-Belegung (z.B. gemeinsame Zeichenketten in `copy()`) kippt die djnz-Entscheidung; dd/ed/tar verloren so je eine `djnz`-Zeile (W10w/W10x), obwohl die Bedingungen von `addsob` sonst nichts vergleichen. Die Ausgabe des ausgelieferten c2 ist hier eine Funktion der Heap-Lage.
* **Behandlung:** auf `main` muss es **bleiben** (Bytegleichheit; der Heap-Inhalt ist Teil des Originalverhaltens). Auf `mutos-plus`: `p->refc = 0` bzw. echte Knotennummerierung (V7 `jumpsw`-Schritt) in `input()` setzen -- das aendert dann die djnz-Entscheidung gegenueber dem Original und ist dort bewusst zu pruefen.
* **Nicht geprueft:** ob weitere Knotenfelder unbelegt gelesen werden (`ref` wird nur nach `op <= JSW` gelesen, stichprobenhaft).

## 2. Gleiches Schadensbild, aber Fehler der Rekonstruktion (behoben)

Zur Abgrenzung -- diese Faelle sahen aus wie F1, lagen aber an uns:

| Programm | Befund | Ursache | behoben in |
|---|---|---|---|
| `as` | „symbol table overflow“ bei jeder Eingabe | `symtab`/`gc79e` getrennt deklariert, Original setzt Nachbarschaft voraus | W7p |
| `as` | Objektkopf Worte 5..7 Muell | Kopf als Einzelvariablen statt ein Feld | W7q |
| `as` | „illegal number or type of operands“ bei `cpir` | Operandenfeld `g90b0` zu klein erschlossen (3 statt 10 Worte) | W7s |
| `c2`, `as`, `c1`, `cpp`, `login`, `ls`, `mv`, `passwd` | Ausgabe verfaelscht / Platte voll | Pufferadressen in `libc_alt` geraten statt gemessen | W10c, W10d |

## 3. Regeln fuer neuen Code neben den Originalen

* Neue Variablen in die **initialisierten Daten**, nicht ans Ende von BSS (F1).
* Felder, die im Original zusammenhaengen, als **ein** Feld deklarieren (Abschnitt 2).
* Feste Adressen in Bibliotheksgliedern messen, nicht raten.

## 4. Noch nicht untersucht

Funktional geprueft sind bisher `c2` (76 Eingaben) und `as` (rund 110 Eingaben).  `c1`, `cpp`, `c0` und die grossen Programme
(`sh`, `ed`, `tar`) sind nur auf Bytegleichheit verglichen; latente Fehler dort sind wahrscheinlich, aber unbekannt.
