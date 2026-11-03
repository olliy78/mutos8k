# Entwurf 42: Herkunft des MUTOS-Codes -- Vergleich mit UNIX V7 und UNIX System III

Stand 2026-11-03.  Status: **Kernel-Herkunftsanalyse abgeschlossen (H0-H6, H8); Userspace (H7) offen.**  Ergebnis: `doc/herkunft/README.md`; Statustabelle in Abschnitt 4a.
(Ursprungsstand 2026-10-30: Plan, nur Quellen beschafft; der Text der Abschnitte 1-7 ist der Plan und wurde nicht umgeschrieben.)

## 1. Ziel

1. Fuer jede Quelldatei in `kernel/c`, `kernel/h`, `kernel/conf` (spaeter `userspace/`) feststellen, ob sie
   **ganz, teilweise oder gar nicht** auf UNIX V7 bzw. UNIX System III zurueckgeht -- und auf welche Datei/Funktion.
2. Dort, wo die Herkunft belegt ist, den **Originaltext** wiederherstellen: Funktions- und Variablennamen,
   Kommentare, Makros, Struktur der Anweisungen.  Die Pflicht aus `CLAUDE.md` bleibt: Rundlauf-Pruefung
   (Quelle -> MUTOS-Toolchain -> Bytes == Original) ist der Massstab; wo sie nicht erreichbar ist, "funktional gleich" + Boot-/Arbeitstest.
3. Im **Dateikopf** steht ein einheitlicher Herkunftsvermerk (Abschnitt 5).
4. Code ohne V7-/SysIII-Bezug (MUTOS-eigene Treiber `rk`, Mailbox-Terminal, Z8001-Speicherverwaltung, `mutos_io`)
   wird als solcher gekennzeichnet; Hinweise auf andere Quellen (WEGA/Zilog ZEUS, Berkeley, Xenix) werden gesammelt.

Sprachregeln aus `CLAUDE.md` gelten: Code und Kommentare Englisch (Originalkommentare von V7 sind englisch -- passt),
7-Bit-ASCII, 8 signifikante Zeichen, K&R-C.  Die Dokumentation hier ist Deutsch.

## 2. Beschaffte Quellen (erledigt)

| Quelle | Ort | Herkunft | Git? |
|--------|-----|----------|------|
| UNIX V7 (Spencer-Tarball, 2144 Eintraege) | `original/unix-v7/` | TUHS `Distributions/Research/Henry_Spencer_v7/v7.tar.gz`, SHA-256 siehe dort | ja (Caldera-Lizenz) |
| UNIX System III (PDP-11 + VAX) | `original/sys3/` | GitHub `Krush206/unix-system-III`, Commit `08908678` | ja (Entscheidung Projektinhaber 2026-10-30) |

Offene Punkte:

* **Lizenz System III:** Projektinhaber hat entschieden: einchecken, belegte Abschnitte und Kommentare duerfen in die MUTOS-Quellen uebernommen werden.  Rest-Hinweis: die Caldera-Lizenz nennt System III nicht ausdruecklich; die Lizenzlage ist in `LICENSE` zu dokumentieren, sobald geklaert.
* **Echtheit des SysIII-Spiegels** ist ungeprueft (TUHS fuehrt System III im aktuellen Archivbaum nicht unter `Distributions/`; Spiegel stammt laut Wiki von der UCB-Tape, K. McKusick/K. Bostic).  Gegenpruefung gegen `tuhs.org/cgi-bin/utree.pl` oder eine zweite Kopie.
* Fehlen: V7-Patches/Addenda (`v7.patches.tar.gz`, `v7addenda.tar.gz`) -- erst laden, wenn ein Unterschied dadurch erklaerbar wird.
* **WEGA** (`OlliL/P8000`, ebenfalls Z8001, ZEUS = System-III-Abkoemmling) bleibt Vermittler: ein Z8001-Kernel, der selbst aus Objektcode rueckuebersetzt ist; kein Original, aber nuetzlich, um die Z8001-Eigenheiten von V7/SysIII-Text zu trennen.

## 3. Methode

Alle Schritte werkzeugbasiert und reproduzierbar (`tools/herkunft/`, Python, `pytest`); Ergebnisse in `doc/herkunft/`.

### 3.1 Vorverarbeitung (Normalisierung)

Die MUTOS-Quellen sind *dekompiliert*: Kommentare sind eigene (deutsch, Adressen), Namen teils vergeben, Reihenfolge der Deklarationen und `register`-Zuordnung stammen vom Compiler.  Fuer den Vergleich daher:

* Kommentare und Praeprozessor-Leerraum entfernen; Tokenstrom bilden.
* Bezeichner **abstrahieren** (alle lokalen Namen -> `ID`, Konstanten -> `NUM`, Strings erhalten), damit Umbenennungen nichts verdecken (Typ-2-Klone); zusaetzlich eine Fassung mit erhaltenen Namen (Typ 1).
* Funktionen einzeln extrahieren (Funktionsanfang = `/* KERNEL xxxx */`-Marke bei MUTOS; bei V7/SysIII per Parser, z. B. `ctags`/`tree-sitter-c`).

### 3.2 Aehnlichkeitsmasse (mehrere, unabhaengig)

1. **Strukturell**: Funktionen paarweise vergleichen -- Name (falls bekannt), Zahl/Folge von Anweisungen, Aufrufgraph, Konstanten, Fehlermeldungstexte.  Die Textpool-Strings (`panic: %s`, `Bad free count`, ...) sind das staerkste Indiz und liegen bereits in `doc/kernel/kernel_namen.md`.
2. **Token-N-Gramm / Winnowing** (eigene Implementierung, MOSS-Algorithmus: k-Gramme, Fingerprints, Winnowing) -- laeuft offline, braucht keinen externen Dienst.
3. **Klon-Detektoren als Gegenprobe**, nur wenn lokal lauffaehig: *CCFinderX* (Windows/Wine; Token-basiert, C-faehig) und *SourcererCC*/`simian`.  **MOSS** ist ein Webdienst der Stanford University: dorthin muessten Quelltexte hochgeladen werden -- **nicht ohne ausdrueckliche Freigabe** (und System-III-Dateien gar nicht, Lizenz).  Daher Standard = eigene Winnowing-Implementierung; MOSS/CCFinderX nur als optionale Stichprobe nach Absprache.
4. **Z8001-Nahtstelle**: Die Normalisierung muss den Unterschied PDP-11 -> Z8001 (`int` 16 Bit, `long` 32 Bit, `char *` Segmentadressen, `register`-Anzahl) ausblenden, sonst scheitern Abgleiche bei jeder Zeigerarithmetik.

### 3.3 Unterscheidung V7 vs. System III

Die beiden stehen sich nahe (SysIII PDP-11 ist V7-Abkoemmling).  Merkmale, die trennen -- zuerst pruefen:

* Systemaufrufe in `sysent`: SysIII fuegt u. a. `utssys`, `ustat`, `ulimit`... hinzu bzw. aendert die Nummern; V7 hat `profil`, `times`, `lock`.  (`kernel/conf/sysent.c` hat 76 Zeilen -- gegen `sys3/uts/pdp11/os/sysent.c` und `usr/sys/sys/sysent.c` auslegen.)
* Kernel-Dateien: SysIII `acct.c`, `errlog.c`, `utssys.c`, `ubm.c`; Header `sysinfo.h`, `var.h`, `utsname.h`, `elog.h`.  Vorhandensein/Fehlen im MUTOS-Kern entscheidet vieles.
* Strukturlayout `proc`, `user`, `inode`, `buf`, `filsys` (gemessen in `doc/kernel/header_belegstand.md`) gegen beide.
* Fehlertexte und Konstanten (`NOFILE`, `NPROC`, `NCALL`, `PZERO`...), Reihenfolge der Funktionen je Modul.

### 3.4 Wiederherstellung

Pro Funktion mit Belegstufe **identisch / veraendert / eigen**:

* *identisch*: Originalname, -kommentar, -text uebernehmen; Rundlauf muss gleich bleiben.
* *veraendert*: Original uebernehmen, Abweichungen als `#ifdef MUTOS`-freie Zeilen mit Kommentar `/* MUTOS: ... */` markieren (kein Praeprozessor-Ballast; der Quelltext soll der Bytefolge folgen).
* *eigen*: unveraendert lassen, Kopf "keine Herkunft".

Reihenfolge pro Datei: Vergleich -> Doku-Eintrag (`doc/herkunft/<modul>.md`) -> Quelle anpassen -> Rundlauf (`--check`) -> Commit.  **Ein Modul pro Commit**, nur Zustaende, die den Rundlauf bestehen.

## 4. Arbeitspakete

| AP | Inhalt | Ergebnis |
|----|--------|----------|
| H0 | Quellen beschaffen, Lizenz und Herkunft dokumentieren | erledigt (Abschnitt 2) |
| H1 | Werkzeug `tools/herkunft/`: Tokenizer/Normalisierer, Funktionsextraktion, Winnowing, Bericht je Datei | Test mit synthetischen Beispielen (V7 gegen V7 -> 100 %) |
| H2 | Grobvergleich aller Module (Datei-Ebene, V7 und SysIII), Trennmerkmale 3.3 | `doc/herkunft/uebersicht.md` mit Matrix Modul x Quelle, Kernfrage "V7 oder SysIII?" beantwortet |
| H3 | Kernel Modul fuer Modul: `alloc`, `iget`, `bio`, `slp`, `sig`, `pipe`, `nami`, `rdwri`, `sys1..4`, `fio`, `clock`, `text`, `malloc`, `subr`, `prf`, `main`... | je Modul Detailvergleich + wiederhergestellte Quelle + Rundlauf |
| H4 | Header `kernel/h` und `conf`: Strukturen, Makros, Kommentare | wiederhergestellte Header, Herkunftsvermerk |
| H5 | Treiber und Maschinennahes (`rk`, `tty`, `tty2`, `lp`, `dev0`, `machdep`, `trap`, `ureg`): vermutlich Eigenanteil; Vergleich mit V7-Treibern (`dev/*.c`), WEGA | Eigenanteil dokumentiert |
| H6 | Fremdherkunft: Reste, die weder V7 noch SysIII erklaeren, gegen WEGA/ZEUS, Xenix (`~/projects/retro/xenix`), BSD (`UCB/2BSD`, `3BSD`) pruefen | Liste "andere Quellen" |
| H7 | Userspace (`userspace/`, Best-of-Disketten): `cmd`, `libc` gegen V7/SysIII | wie H3, spaeter |
| H8 | Abschluss: Herkunftsvermerke in allen Dateikoepfen, Gesamtbericht, `CLAUDE.md`/README nachziehen | |

H1 und H2 zuerst; H3 beginnt mit den Modulen, die durch `kernel_namen.md` bereits "sicher" benannt sind (`alloc`, `iget`, `slp`, `sig`).

## 4a. Status der Arbeitspakete (2026-11-03)

| AP | Status | Ergebnis / Fundstelle |
|----|--------|-----------------------|
| H0 | erledigt | Quellen V7, System III (Abschnitt 2); spaeter Hippe-Sammlung (`original/hippe-v7/`) |
| H1 | erledigt | `tools/herkunft/herkunft.py`, `tests/test_herkunft.py` |
| H2 | erledigt | `doc/herkunft/uebersicht.md` Abschnitte 1-7 (Abschnitt 1 teils ueberholt, dort markiert): V7 Hauptquelle, System III nicht beteiligt |
| H3 | erledigt | maschinenunabhaengige Module (alloc, iget, slp, sig, sys1-4, fio, prf, subr, malloc, pipe, nami, rdwri, bio, main, clock, text), je `doc/herkunft/<modul>.md` |
| H4 | erledigt | Header, `conf.c`, `sysent.c`, `header.md`; Layout unveraendert (`tests/test_header_layout.py`) |
| H5 | erledigt | trap, machdep, ureg, rk, dev0, lp, tty |
| H6 | erledigt | Fremdherkunft: Hippe-Sammlung als naechster bekannter Verwandter, `fremd.md`; `tty2.c` geklaert |
| H6b | erledigt (zusaetzlich) | Gegenprobe Abstammung (direkte Ableitung wahrscheinlich, gemeinsame Vorlage vermutet), `fremd.md` Abschnitt 8; Robotron-Umfeld/MUTOS1600 als Hypothese (Abschnitt 9) |
| H6c, H6d | erledigt (zusaetzlich) | `tty2.c` und weitere Kernelquellen im Text der Hippe-Sammlung (`tty2.md`, Abschnitte "Nachzug H6d") |
| H7 | **offen** | Userspace (`userspace/`, Best-of-Disketten: `cmd`, `libc`) gegen V7/Hippe/WEGA |
| H7-Speicher | erledigt (zusaetzlich) | Speicherverwaltung ohne MMU: `speicher.md` |
| H8 | erledigt | Herkunftsvermerke in den Dateikoepfen (27 Module, 25 Header/Konfiguration), Gesamtbericht `doc/herkunft/README.md`, `CLAUDE.md`/README/LICENSE nachgezogen |
| H8a | erledigt (zusaetzlich) | Z8001-Prozessorkontext, WEGA-`libc`-ABI: `z8001_kontext.md` |
| H8b | erledigt (zusaetzlich) | Mailbox-Treiber, U880-Seite, `fd*` als umgebauter Bandtreiber: `mailbox_treiber.md` |

Stand der Quellen: 191 von 227 Kernelfunktionen bytegleich aus C, Gesamtbau BYTEGLEICH 36 352 Byte (`doc/herkunft/README.md` Abschnitt 5).

## 4b. Beschluesse des Projektinhabers (Festhaltung)

* **MOSS/CCFinderX:** kein Upload von Quelltexten; eigene Winnowing-Implementierung (Abschnitt 7 Nr. 1).
* **System III:** wird im Repository eingecheckt (`original/sys3/`, 2026-10-30); belegte Abschnitte und Kommentare duerfen uebernommen werden.  Die Caldera-Lizenz nennt System III nicht ausdruecklich; die Lage steht in `LICENSE`.
* **Hippe-Sammlung:** wird im Repository eingecheckt (`original/hippe-v7/`, 2026-11-01), zu Forschungs- und Vergleichszwecken; Zusaetze Dritter ohne Lizenzangabe, Urheber unbekannt.  Der Sammler ist nicht Urheber (Zuordnung 2026-10-31).
* **Mittelweg bei der Wiederherstellung** (Abschnitt 7 Nr. 3): Originaltext einsetzen, Rundlauf pruefen; bytegleich -> Originaltext gilt, sonst bytegleiche Fassung behalten und Originaltext als Kommentar.
* Weitere TUHS-Baeume (UNSW, BSD, Nijmegen u. a.) liegen nur im Scratchpad und sind nicht eingecheckt (`fremd.md` Abschnitt 2); WEGA bleibt Referenz ohne Kopie.


## 5. Einheitlicher Herkunftsvermerk im Dateikopf

```c
/* Origin:   complete | partial | none
 * Source:   UNIX V7 usr/sys/sys/alloc.c ; (UNIX System III uts/pdp11/os/alloc.c : identical to V7 except ...)
 * Evidence: same strings, same call graph, 11 of 11 functions match (similarity 0.93)
 * Deviations: (kurz, je Funktion oder "see doc/herkunft/alloc.md")
 */
```

* `complete`: alle Funktionen der Datei lassen sich auf eine Quelldatei zurueckfuehren (Abweichungen nur Portierung Z8001).
* `partial`: Teile; die uebrigen Funktionen sind im Kopf einzeln mit `eigen` / `Quelle X` aufzufuehren.
* `none`: kein Bezug (MUTOS-eigen oder unbekannt).
* Die Zeile `Source` nennt ausdruecklich die **Version** (V7 / System III PDP-11 / System III VAX).  Sicherheit wie in `kernel_namen.md`: sicher / wahrscheinlich / vermutet; *gemessen* und *angenommen* getrennt.

## 6. Risiken

* Dekompilierter Code folgt dem Compiler (Registerzuordnung, Schleifenform), der Originaltext nicht: wiederhergestellter V7-Text kann einen anderen Rundlauf liefern.  Dann Originalform zuerst, Rundlauf pruefen, notfalls die Compiler-Form belassen und den Originaltext als Kommentar daneben -- Entscheidung je Funktion, dokumentiert.
* SysIII-Spiegel unsicher (Abschnitt 2); Ergebnisse, die nur darauf beruhen, entsprechend kennzeichnen.
* Ein Treffer in V7 kann zugleich in SysIII stehen (gleicher Text); dann nennt der Vermerk beide ("V7 = SysIII"), und das Trennmerkmal bleibt offen.

## 7. Offene Fragen an den Auftraggeber

1. **MOSS/CCFinderX:** entschieden -- kein Upload; eigene Winnowing-Implementierung, CCFinderX nur lokal als Stichprobe.
2. **System III:** entschieden -- im Repository; belegte Abschnitte und Kommentare werden uebernommen.
3. **Wiederherstellung vs. Rundlauf:** entschieden (Mittelweg) -- je Funktion zuerst den Originaltext einsetzen und den Rundlauf pruefen; bleibt er bytegleich, gilt der Originaltext.  Sonst bleibt die bytegleiche Fassung, der Originaltext steht als Kommentar daneben, die Abweichung wird in `doc/herkunft/<modul>.md` festgehalten.
