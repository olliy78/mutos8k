# Woher stammt der MUTOS-8000-Kernel?  Gesamtbericht der Herkunftsanalyse

Stand 2026-11-03 (Abschluss AP H8).  Plan: `doc/plan/42_unix_herkunft.md`.  Dieses Dokument fasst die Ergebnisse fuer Leser zusammen, die die Einzelprotokolle
nicht kennen; die Belege stehen in den verlinkten Detaildokumenten.  Aussagen sind **gemessen** (Befehl bzw. Lauf in der Detaildatei), **angenommen** oder
**vermutet**, wo es dasteht; die Einstufung *sicher / wahrscheinlich / vermutet* ist ein Urteil auf Basis der Messung, kein Beweis.
`uebersicht.md` bleibt das zeitlich geordnete Arbeitsprotokoll (Abschnitt 1 dort enthaelt teils ueberholte Zwischenstaende, vorne gekennzeichnet).

## 1. Fragestellung

MUTOS 8000 ist das UNIX-Derivat fuer den robotron A5120.16 (Z8001 auf der Erweiterungskarte, U880 als Ein-/Ausgaberechner).  Quellen des Systems sind nicht
ueberliefert; der Kernel `mutos_1216` wurde aus dem Binaerabbild rekonstruiert (`doc/kernel/`).  Gefragt wurde:

1. Auf welches UNIX geht der Kernel zurueck -- Bell-V7, System III, eine Variante?
2. Welche Teile sind unveraendert, welche angepasst, welche Eigenentwicklung (Speicher ohne MMU, Z8001, Treiber, U880-Seite)?
3. Laesst sich dort, wo die Herkunft belegt ist, der **Originaltext** (Namen, Kommentare, Schreibweise) wiederherstellen, ohne dass die Toolchain andere
   Bytes erzeugt?

## 2. Quellen

| Quelle | Ort | Rolle |
|---|---|---|
| UNIX V7, Bell Labs 1979 (Spencer-Tarball, TUHS) | `original/unix-v7/` | Grundlage des Vergleichs; eingecheckt (Caldera-Lizenz) |
| UNIX System III (GitHub-Spiegel, PDP-11 und VAX) | `original/sys3/` | Gegenprobe "V7 oder System III?"; eingecheckt auf Entscheidung des Projektinhabers; Echtheit des Spiegels nicht gegen ein TUHS-Original geprueft |
| TUHS-Sammlung `Research/Torsten_Hippe_v7` ("Hippe-Sammlung") | `original/hippe-v7/` | naechster bekannter Verwandter des Kernels; eingecheckt |
| WEGA (P8000, Z8001; rueckuebersetzter Kernel, `libc`) | nur Referenz, nicht kopiert (`original/wega/README.md`) | Vergleich fuer Z8001-Teile und Benutzerseite der Systemaufrufe |
| weitere TUHS-Baeume (UNSW-Baender, Nijmegen-V7, V7M, 2.8-2.11BSD, 3BSD, 4.1BSD, 32V, PWB, Ultrix-11, LSX, Mini-UNIX u. a., zusammen 27 durchsuchte Baeume) | nur im Scratchpad der Arbeitssitzungen, nicht im Repository | Gegenprobe zur Abstammung (`fremd.md` Abschnitte 2 und 8, `speicher.md` Abschnitt 6) |

**"Hippe" bezeichnet in der gesamten Doku nur die Sammlung, nicht den Urheber.**  Die Sammlung wurde im Maerz 1995 von einem Studenten aus nicht naeher bekannten
Quellen zusammengestellt und dem TUHS uebergeben; der Sammler hat den Code nicht geschrieben.  Wer die Aenderungen gegenueber Bell-V7 urspruenglich verfasst hat,
ist unbekannt (nach den Funden eine Linie UNSW/AUSAM -> Vrije/Nijmegen -> unbekannt).

## 3. Methode

* **Winnowing-Werkzeug** (`tools/herkunft/herkunft.py`, Test `tests/test_herkunft.py`): eigene Implementierung des MOSS-Algorithmus (k-Gramme, Fingerabdruecke),
  offline.  Vorverarbeitung: Kommentare, Casts, `register` und lokale Deklarationen entfallen, lokale Namen werden `ID`, Zahlen `NUM`, Skalartypen `T` -- das blendet die
  Nahtstelle PDP-11 -> Z8001 aus.  Verglichen wird je Funktion gegen den ganzen Quellbaum.  MOSS selbst (Webdienst) wurde nicht benutzt: kein Upload (Entscheidung des Inhabers).
  Zusatzwerkzeuge fuer Tabellen, Strukturlayouts, Schalteraufloesung (`ifdef_resolve.py`) und Abweichungsanalyse (`devdiff.py`) liegen daneben.
* **Rundlauf** (`tools/herkunft/rundlauf.sh`, `rundlauf.md`): Funktion in Quelltext -> MUTOS-`cc -O` im Emulator-Gast -> Bytes gegen `mutos_1216`.  Das ist der
  Wahrheitsmassstab; Sollwerte je Funktion in `daten/rundlauf_soll.txt` (GLEICH / NAHE).
* **Gesamtbau** (`tools/kernel/gesamtbau.py --uebersetzen --stufe 1 --boot`): alle C-Dateien uebersetzen, binden, Abbild gegen das Original, Boot bis zur Shell, Arbeitstest.
* **Mittelweg-Regel** (Beschluss des Inhabers): je Funktion zuerst den Originaltext der Vorlage einsetzen und den Rundlauf pruefen.  Bleibt er bytegleich, gilt der Originaltext;
  sonst bleibt die bytegleiche Fassung und der Originaltext steht als Kommentar daneben, die Abweichung steht in `doc/herkunft/<modul>.md`.
  Jede Datei traegt einen Herkunftskopf (`Origin: complete | partial | none`, `Source:`, `Evidence:`, Plan 42 Abschnitt 5).

## 4. Kernergebnisse

### 4.1 MUTOS gehoert zur V7-Linie, nicht zu System III (gemessen, sicher)

Der maschinenunabhaengige Kern (alloc, iget, fio, bio, slp, sig, pipe, nami, rdwri, sys1-4, subr, prf, malloc, main) ist V7-Text.  Gegen Bell-V7 liegt der Kern bei 82 %
Funktionsaehnlichkeit, 68 Funktionen sind textgleich; `sysent` stimmt in 58 von 64 Slots mit V7 ueberein, `proc`/`mount`/`filsys`/`cdevsw` haben exakt das V7-Layout, `NSIG` ist 17.
Keines der System-III-Merkmale ist im Kernel vorhanden (`uebersicht.md` Abschnitte 1a und 4): keine FIFOs (`IFIFO`), kein `termio`, kein `fcntl`/`ulimit`/`utssys`, kein `sysinfo`/`errlog`,
der Scheduler ist der V7-Scheduler.  **System III ist an MUTOS nicht beteiligt.**  Zwei Praezisierungen: Dateisperren und IPC (`msgget` u. a.) gehoeren weder zu V7 noch zu System III, sondern zu
Xenix bzw. System V.  Die frueher als "System-III-Zuege" gedeuteten Stellen (`s_tfree`/`s_tinode` in `alloc`, `smount` -> `out1`, `iodone` ohne UNIBUS-Teil, `seek` mit `off < 0`) stehen
ebenfalls in der Hippe-Sammlung und sind damit erklaert (`fremd.md` Abschnitt 4).

Die System-III-Neuerungen im Einzelnen (FIFO, IPC, Scheduler, Dateisperren, `termio`, `fcntl`, `ulimit`/`utssys`/`sysinfo`/`errlog`/`acct`, `NSIG`) wurden in je drei Baeumen gesucht:
`uebersicht.md` Abschnitt 1a.

### 4.2 Naechster bekannter Verwandter: die Hippe-Sammlung

Die V7-Variante der Sammlung (`usr/sys`, Standardkonfiguration `conf/m.h`: `PROC_MAX`, `EXIT`, `LRUI` an) erklaert alle bisherigen "Fremdzuege" auf einmal (`fremd.md` Abschnitte 4 und 8):
`malloc`-Kartenlimit mit `panic("map overflow")`, `sumount`-Busytest, `stime`/`i_lastr`, die `iget`/`iput`-LRU, `breada`-Freilistentest, die `exit`-Schleife, `exece`-Fehlerschleife mit `B_AGE`,
`max_proc`; dazu die Systemaufruftabelle (64 von 64 Zeilen gleich) und die Parameter (NPROC 30, NINODE 50, NFILE 50, HZ 50, `MAPSIZ` = 15).  Die Zeilendisziplin `tty2.c`
(20 Funktionen, Tabellen `maptab`/`cchars`/`wchars` byte-gleich) ist `usr/sys/dev/tty.c` der Sammlung.  In allen 26 Funktionen, in denen die Sammlung von Bell-V7 abweicht, traegt MUTOS
die Abweichung; alle vier Merkmale, die nur die Sammlung hat, hat auch MUTOS.  Kein anderer der geladenen Baeume kommt MUTOS naeher.

**Einschraenkung (wichtig):** Das belegt grosse inhaltliche Uebereinstimmung, nicht die Abstammung.  Zwei Lesarten sind nicht zu trennen: (a) direkte Ableitung vom Kernel der Sammlung
(*wahrscheinlich*) oder (b) eine gemeinsame, unbekannte Vorlage (UNSW/Vrije/Nijmegen-Linie; *vermutet*), die dann Text der Sammlung gewesen sein muesste.  Dateidaten sind schwache Belege
(die Quellstempel der Sammlung 1980-1986 sagen nichts ueber das Alter der Zuege; 22 von 25 Kernelmodulen ihrer Bibliothek sind 1982 und 1986 byte-gleich).  Eindeutige Stellen, an denen MUTOS aelter oder
einfacher waere als die Sammlung, gibt es nicht; ein einziger fraglicher Fall ist der Fehlerausgang von `exece` (Nijmegen-/V7-Form statt Sammlung).  Die Urheberschaft der Sammlung ist ausdruecklich
ausgeschlossen.  Entscheiden wuerden weitere Staende der Linie, ein Kerneldatum von MUTOS oder Hinweise der Beteiligten.

### 4.3 MUTOS-Eigenanteil

Der Eigenanteil liegt in der Anpassung an die A5120.16-Hardware, nicht im Betriebssystemkern (Zahlen als Spannen, je nachdem, was mitgezaehlt wird; Wertung, keine Messung der "Leistung"):

* **Speicher ohne MMU** (`speicher.md`): Ein Prozess ist ein ganzes 64-KB-Segment der EM256, `p_addr` ist bitgleich das Segmentwort; `resume` kopiert den u-Bereich in den Slot des Prozesses;
  `estabur` prueft nur die Groesse.  Von 36 V7-Funktionen mit Speicherbezug sind 5 unveraendert, 16 weggelassen oder Stumpf, 15 in V7-Form angepasst; neu 2-3 % des C-Kerns (weit 5 %) und
  ~0,43 KB Assembler.  Keine Vorlage in 27 Baeumen gefunden.  Schutz Prozess gegen Prozess gemessen; Prozess gegen Kernel unbekannt (nicht versucht); kein Text-Schreibschutz, keine Stapelgrenze.
* **Z8001-Kontext** (`z8001_kontext.md`): Trap-Eintritt `trapent` als Z8001-Umschrift von V7 `mch.s`; 79 % der betroffenen Funktionen V7-gleich; Z8001-C 1-3,4 % des C-Kerns.  Die Benutzerseite des
  Systemaufrufs (`libc`: `SC #n`, Ergebnis `r4`, Carry-Fehler) stimmt befehlsweise mit der **WEGA-`libc`** ueberein; der Kernel ist kein WEGA-Text, setzt aber dieselbe ABI um.  Ob MUTOS von WEGA oder beide
  von einer gemeinsamen Z8000-Vorlage stammen, ist nicht entscheidbar (Zilog-ZEUS nicht gefunden).
* **Mailbox-Treiber und U880-Seite** (`mailbox_treiber.md`): 38 Treiberfunktionen (14,5 % des Kernel-C), Eigenanteil im C 3,7-12,9 %.  Das Mailbox-Protokoll (14-Byte-Eintraege, Klingel ueber Port 80H), `mapalloc`/`mapstart` und
  die U880-Seite `mutos_io` (`mutosio.mac`) haben keine Vorlage; WEGA koppelt anders.  `rk`, `lp` und die `tc*`-Huellen folgen V7/Hippe-Vorbildern; **`fd*` (`dev0.c`) ist ein umgebauter Magnetbandtreiber `tm.c`**
  mit BSD-artigem `tmioctl` (*wahrscheinlich*).
* **Kleine Einzelzuege** in `clock`/`sched`/`setregs` ohne Gegenstueck in den geladenen Baeumen (30-s-`update()`-Anforderung, abgeschaltet; `setregs`-Kopierrichtung; zwei Tickzaehlungen).

### 4.4 Robotron-Umfeld (Hypothese)

Literaturlage, keine Messung am Code: MUTOS entstand Anfang der 80er Jahre als Portierung von UNIX auf den K1630 (**MUTOS1600**, "kompatibel zu UNIX Version 7"); MUTOS8000 wurde daraus abgeleitet.
Passend waere ein PDP-11-V7-Derivat in der Naehe der Sammlung als Zwischenstufe.  Quellen von MUTOS1600 sind nicht bekannt; die Frage ist ohne sie nicht pruefbar (`fremd.md` Abschnitt 9).

## 5. Stand der Quellen: Rundlauf und Gesamtbau (gemessen, 2026-11-03)

Gesamtbau `--uebersetzen --stufe 1 --boot`: **216 von 230 Funktionen bytegleich aus C** (Stand 2026-11-04 nach Arbeitspaket 0 von Plan 43: +`schar`, `max`, `lpsgtty` neu als Funktionen, +`namei`, `writei`, `lpxfer`, `core`, `setregs` jetzt gleich), `Gesamt: BYTEGLEICH (0 Byte ungleich)`, 36 352 Byte, Boot bis `#`, Arbeitstests ok.
Die restlichen 14 sind "nahe" Funktionen (unten); `dev0.c` ist seit 2026-11-04 vollstaendig bytegleich (Rundlauf ohne `-O`: `OHNE_O=1 SOLL=doc/herkunft/daten/rundlauf_soll_dev0.txt tools/herkunft/rundlauf.sh WORKDIR dev0`).  `gesamtbau.py --arbeit DIR --status` listet sie mit Status und gleicht die Zaehlung mit `rundlauf_soll.txt` ab (Exit 1 bei Abweichung).
"Origin" ist der Wert aus dem Dateikopf; "bytegleich" zaehlt die Funktionen mit `GLEICH` in `daten/rundlauf_soll.txt` (Rundlauf je Funktion).

| Modul | Origin | bytegleich | | Modul | Origin | bytegleich |
|---|---|---|---|---|---|---|
| alloc | complete | 4/7 | | sig | complete | 10/10 |
| bio | partial | 17/19 | | slp | complete | 11/11 |
| clock | partial | 0/1 | | subr | complete | 6/7 |
| dev0 | partial | Gesamtbau (11 Fkt.) | | sys1 | complete | 6/8 |
| fio | complete | 8/8 | | sys2 | complete | 11/11 |
| iget | complete | 6/8 | | sys3 | complete | 8/8 |
| lp | partial | 4/7 | | sys4 | complete | 23/24 |
| machdep | partial | 3/4 | | text | partial | 10/10 |
| main | complete | 3/3 | | trap | partial | 3/3 |
| malloc | complete | 0/2 | | tty | partial | 10/11 |
| nami | complete | 1/1 | | tty2 | complete | 16/20 |
| pipe | complete | 8/8 | | ureg | partial | 2/3 |
| prf | complete | 5/5 | | rk | partial | 13/13 |
| rdwri | complete | 3/4 | | | | |

Verbleibende "nahe" Funktionen (25, Wortzahlen = abweichende Woerter, `rundlauf_soll.txt` und Modulprotokolle): `alloc` 84/158, `ialloc` 169/220, `update` 85/119, `itrunc` 61/93, `tloop` 42/79, `ssig` 39/52,
`bmap` 263/308, `malloc` 24/52, `mfree` 1/119, `readi` 108/206, `mapalloc` 14/37, `mapstart` 28/44, `exece` 1/389, `getxfile` 177/401, `clock` 210/260, `startup` 45/90, ``lpwrite` 42/124,
`lpcanon` 104/212, `lpintr` 21/75, `putchar` 54/88, `ttioccomm` 181/371, `ttyinput` 281/458, `ttyretype` 1/116, `ttread` 1/139.  Ihre Ursachen sind teils Eigenheiten des Kernel-`c2` (Blockanordnung, Registerladen),
teils offene Quellformen; das alte Bild "alle Abweichungen sind `c2`" gilt nicht mehr (`doc/kernel/c_rueckbau.md`, Hinweise dort).  Die Funktionen, deren Abweichung sich als reine Quellform erwies,
sind jetzt bytegleich (u. a. `bcopy`, `iomove`, `iupdat`, `swtch`, `newproc`, `core`, `procxmt`, `rdwr`, `chdirec`, `binit`, `trap`, 16 Funktionen von `tty2`).

## 6. Offene Punkte

* **Abstammung** direkt oder ueber gemeinsame Vorlage (4.2): weitere Staende der Linie (Vrije/Calgary, Hippe vor 1986), Kerneldatum von MUTOS, Hinweise der Beteiligten.
* **Userspace (H7)**: `cmd`, `libc` und die Disketten sind noch nicht gegen V7/Hippe verglichen; die WEGA-`libc`-Uebereinstimmung ist bisher nur fuer die Systemaufruf-Huellen gemessen.
* **Schutz Prozess gegen Kernel**, Stapelueberlauf und das Verhalten nichtsegmentierter Zugriffe im Gast: nicht gemessen (`speicher.md` Abschnitt 10).
* **Mailbox**: Wiederholungs-/Fehlerpfade, Vektorzuordnung und die Floppy-Kette (`fd*`, nie ausgefuehrt) ungemessen; Z8001-Einzelschritt (NVI) und Paritaetsbits offen (`z8001_kontext.md`).
  *Stand AP H9 (`gastversuche.md`):* Vektorzuordnung, `rk`-Fehlerpfad (Status C2/C5, 3 Wiederholungen) und Floppy-Kette (F7, kein Haenger) gemessen; Einzelschritt: Mechanismus gemessen, aber ohne Befehlsfortschritt im Emulator (Verdacht Abtastzeitpunkt NVI nach `IRET`).  Weiter offen: Status `0xC8`, `lp`-/`fd`-Wiederholungen, Paritaetsbits, Speicherschutz/privilegierte Befehle/Stapelueberlauf (V1-V3, Abschnitt dort).
* **Nahe Funktionen** (25, Abschnitt 5): Quellformen fuer `ssig`, `bmap`, `readi`, `malloc`/`mfree`, `ialloc` u. a. nicht gefunden; ob der Unterschied am Kernel-`c2` oder an der Quellform liegt, ist je Funktion offen.
* **Echtheit des System-III-Spiegels** gegen ein TUHS-Original; V7-Patches/Addenda sind nicht in `original/` (nur im Scratchpad geladen).
* **MUTOS1600**-Quellen und Zilog-ZEUS: nicht gefunden.

## 7. Wegweiser zu den Detaildokumenten

| Thema | Dokument |
|---|---|
| Protokoll H2-H8, Matrix Modul x Quelle, Trennmerkmale V7/System III | `uebersicht.md` |
| Fremdherkunft, Hippe-Sammlung, Gegenprobe Abstammung, MUTOS1600 | `fremd.md` |
| Speicherverwaltung ohne MMU | `speicher.md` |
| Z8001-Prozessorkontext, WEGA-`libc` | `z8001_kontext.md` |
| Mailbox-Treiber, U880-Seite, `fd*` als Bandtreiber | `mailbox_treiber.md` |
| Gastversuche H9: Einzelschritt, Mailbox-Fehlerpfad, Vektoren, Floppy-Kette | `gastversuche.md`, `versuche/gast_h9/` |
| Zeilendisziplin | `tty2.md` |
| Header, `conf.c`, `sysent.c` | `header.md` |
| Rundlaufverfahren, Sollwerte | `rundlauf.md`, `daten/rundlauf_soll.txt` |
| je Kernelmodul | `alloc.md`, `bio.md`, `clock.md`, `dev0.md`, `fio.md`, `iget.md`, `lp.md`, `machdep.md`, `main.md`, `malloc.md`, `nami.md`, `pipe.md`, `prf.md`, `rdwri.md`, `rk.md`, `sig.md`, `slp.md`, `subr.md`, `sys1.md` .. `sys4.md`, `text.md`, `trap.md`, `tty.md`, `ureg.md` |
| Plan und Beschluesse | `doc/plan/42_unix_herkunft.md` |
| Quellenverzeichnis, Lizenzlage | `doc/quellen.md`, `LICENSE` |
