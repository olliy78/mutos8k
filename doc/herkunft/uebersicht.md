# Herkunft des MUTOS-Kernels: Grobvergleich mit UNIX V7 und UNIX System III (AP H2)

Stand 2026-10-30.  Plan: `doc/plan/42_unix_herkunft.md`.  Werkzeug: `tools/herkunft/herkunft.py` (AP H1).
Alle Zahlen sind **gemessen** (Befehle in Abschnitt 2 und an den Stellen), sofern nicht ausdruecklich als *angenommen*
gekennzeichnet.  Die Einstufung sicher / wahrscheinlich / vermutet ist ein Urteil auf Basis der Messung.

## 1. Ergebnis in Kuerze

> **Zuordnung (Stand 2026-10-31, Recherche des Projektinhabers):** "Hippe" bezeichnet in der Herkunftsdoku nur die **Sammlung** `Distributions/Research/Torsten_Hippe_v7` im TUHS-Archiv, nicht den
> Urheber der Inhalte.  Torsten Hippe hat die Sammlung im Maerz 1995 als Student aus nicht naeher bekannten Quellen zusammengestellt und dem TUHS uebergeben; er ist weder Autor des Kernels noch
> kommt er als Urheber von MUTOS in Frage.  Dokumentiert wird die **grosse Uebereinstimmung** des Codes dieser Sammlung mit dem MUTOS-Code (`fremd.md`).  Wer die
> Aenderungen gegenueber Bell-V7 urspruenglich geschrieben hat, ist unbekannt (Linie nach den Funden: UNSW -> Vrije/Nijmegen -> unbekannt; `m.h` nennt Johan Stevenson, Vrije, fuer `XBUF`).
> Wo unten "Hippe-Kernel", "Hippe-Zuege" o. ae. steht, ist stets "Kernel/Zuege der Hippe-Sammlung" gemeint.


* **Hauptquelle: UNIX V7** (Spencer-Tarball `original/unix-v7`).  Einstufung **sicher** fuer den maschinenunabhaengigen
  Kern (alloc, iget, fio, bio, slp, sig, pipe, nami, rdwri, sys2-4, subr, prf, malloc, main).
* **System III ist im Kern nicht belegt.**  Kein Merkmal, das nur SysIII hat (`utssys`, `fcntl`, `ulimit`, `setpgrp`, `acct`/`errlog`,
  `sysinfo`, `var.h`, `utsname`, `NSIG 20`, `p_swaddr`, `m_flags`, ...) steht in `kernel/c`, `kernel/h` oder `kernel/conf`.  Mehrere
  Merkmale, die nur V7 hat, stehen darin (Abschnitt 4).  PDP-11 und VAX von SysIII sind gegenueber V7 gleich schlecht (47 % / 46 %
  gegen 66 % V7); eine Entscheidung zwischen beiden SysIII-Fassungen eruebrigt sich.
* **Einschraenkung (gemessen, AP H3):** `alloc.c` fuehrt die Zaehler `s_tfree`/`s_tinode` mit (`alloc`, `free`, `ialloc`, `ifree`).  Der V7-Kernel
  tut das nicht (`rg s_tfree original/unix-v7/usr/sys/sys` ohne Treffer; nur `mkfs`/`icheck` fassen die Felder an), `original/sys3/uts/pdp11/os/alloc.c` hat
  genau diese 6 Stellen.  Der Kern ist also V7 mit mindestens einem System-III-Zug; Herkunft offen (Plan H6).  Die Aussage "System III nicht belegt" gilt
  damit fuer die Feature-Ebene (Abschnitt 1a), nicht mehr absolut.
* **MUTOS-eigen (kein V7/SysIII-Bezug):** Diskettentreiber `dev0.c` (`fd*`), Drucker `lp.c`, Mailbox-Terminal `tty.c` (`tc*`),
  Plattentreiber-Teil von `rk.c`, `mapalloc`/`mapstart` in `bio.c`, Header `mbx.h`, `user_ext.h`, `devtab` in `conf.h`, die
  Z8001-Teile von `machdep.c`, `trap.c`, `ureg.c`.
* **Geklaert in H6 (Abschnitt 13, `fremd.md`):** `tty2.c` (Zeilendisziplin, 20 Funktionen) hat gegen V7/System III nur 17-34 %, stimmt aber mit `usr/sys/dev/tty.c` der V7-Variante
  `Torsten_Hippe_v7` ueberein (Tabellen byte-gleich); dieselbe Variante erklaert die uebrigen "Fremdzuege" und "System-III-Zuege" des Kerns.
  **Vorbehalt (2026-10-31):** Das belegt Verwandtschaft, nicht Abstammung.  Hippes Baum (Kernel-Quellen 1981-82, Neuubersetzung 1986, Laufzeitdaten bis 1988) ist
  der naechste *bekannte* Verwandte.  Die Gegenprobe (Abschnitt 14, `fremd.md` Abschnitt 8) ergibt: MUTOS stimmt inhaltlich weitgehend mit dem Kernel der Hippe-Sammlung ueberein (direkte Ableitung *wahrscheinlich*, Urheberschaft der Sammlung ausdruecklich ausgeschlossen); eine gemeinsame unbekannte Vorlage
  (Linie UNSW/Vrije/Nijmegen) ist *vermutet*, aber nicht zu trennen.  Dateidaten sind schwache Belege.

## 1a. Feature-Bewertung: Neuerungen von System III gegenueber V7

Frage: Steckt eines der Merkmale, die System III zu V7 hinzugefuegt hat, im MUTOS-Kernel?  Jede Zeile wurde in drei Baeumen
gesucht (`rg -F` ueber `original/sys3/uts`+`head`, `original/unix-v7/usr/sys`, `kernel/`); Ergebnis **gemessen**, Deutung
*angenommen*, wo so gekennzeichnet.  Sicherheit: sicher = Negativbefund in allen drei Baeumen bzw. eindeutiges Gegenmerkmal.

| Merkmal | System III (Beleg) | V7 | MUTOS | Bewertung |
|---------|--------------------|----|-------|-----------|
| **Named Pipes / FIFOs** (`IFIFO`, `S_IFIFO`, `mknod ... p`) | ja: `head/sys/stat.h:25`, `os/pipe.c:43` (Pipe ist `IFIFO`-Inode), `os/rdwri.c`, `fio.c`, `iget.c` (12 Dateien) | nein (Pipe = Inode mit `FPIPE`) | **nein**: kein `IFIFO`; `kernel/c/pipe.c` ist V7 (`FPIPE`, `PIPSIZ 4096`, Schlafkanaele `ip+1`/`ip+2`) | nicht vorhanden (sicher) |
| **IPC** (`msgbuf`, `msqid_ds`, Semaphoren, Shared Memory) | **auch nicht in System III**: 0 Treffer fuer `msqid_ds`, `msgbuf`, `semid`, `shmid`; IPC (`msgget`/`semget`/`shmget`) kam erst mit **System V** (1983) | nein | nein | nicht vorhanden; Praezisierung: gehoert zu System V, nicht zu III (sicher) |
| **Verbesserter Scheduler** | ja, `os/clock.c`: `p_cpu` bei 80 gedeckelt, Zerfall `p_cpu >>= 1`, `p_pri = (p_cpu>>1)+PUSER+...`, `runrun` aus dem Takt, `sysinfo`-Zaehler | nein: `SCHMAG 8/10`, `p_cpu = p_cpu*8/10 + p_nice - NZERO`, `setpri` mit `p_cpu/16` | **V7**: `kernel/c/clock.c` (`(p_cpu&0377)*8/10 + p_nice - NZERO`, `p_cpu` bis Ueberlauf), `kernel/c/slp.c` `setpri` mit `/16` | V7-Scheduler (sicher); System-III-Neuerung nicht enthalten |
| **File-Locking** | nein: `fcntl.h` kennt nur `O_NDELAY`; kein `F_SETLK`, `lockf`; `locking()` ist **Xenix**, `lockf`/`F_SETLK` kommt mit System V | nein | nein (Treffer "locking" nur im `iget`-Kommentar, V7-Text) | nicht vorhanden; auch System III hat es nicht (sicher) |
| **`sgttyb` -> `termio`** (`struct termio`, `TCGETA`/`TCSETA`, Basis `'T'<<8`) | ja: `head/sys/tty.h:220`, `ioctl.h:3-5`; `sgttyb` bleibt als Kompatibilitaet | nur `sgttyb`, ioctl `'t'<<8` | **nur V7-`sgttyb`**: `ttioctl` (`tty2.c:138`) hat 14 Kommandos `0x74xx` (dazu `0x6408`/`0x6409`) (`'t'<<8`: `TIOCGETP 0x7408`, `TIOCSETP 0x7409`, ...), keinen `'T'<<8`-Fall; `t_flags` mit V7-Werten (`ECHO 8`, `CRMOD 10H`, `RAW 20H`) | V7-Terminalschnittstelle (sicher); kein `termio` |
| `fcntl` (`O_NDELAY`, `F_DUPFD`) | ja, `sysent`-Eintrag, `head/fcntl.h` | nein | nein (nicht in `sysent.c`) | nicht vorhanden (sicher) |
| `ulimit`, `utssys` (`uname`, `ustat`), `sysinfo`, Fehlerprotokoll `errlog`, Abrechnung `acct` | ja (`sysent`, `os/utssys.c`, `os/errlog.c`, `os/acct.c`, `head/sys/sysinfo.h`) | `acct`: ja, `sysacct` (hier `nosys`) | nein: `sysacct` ist `nosys`, andere fehlen | nicht vorhanden (sicher) |
| Neue Prozess-/Terminal-Felder (`NSIG 20`, `p_swaddr`, `m_flags`) | ja | `NSIG 17` | `NSIG 17` | V7-Stand (sicher) |

**Folgerung (gemessen, daher sicher):** Keine der System-III-Neuerungen steckt im MUTOS-Kernel.  Das stuetzt Abschnitt 1:
MUTOS beruht auf V7, nicht auf System III.  Der Befund ist auch dann tragfaehig, wenn der GitHub-Spiegel von System III nicht
exakt dem Original entspraeche: er stuetzt sich auf das *Fehlen* von Merkmalen, die laut Literatur (FIFO, `termio`, `fcntl`,
`ulimit`, `utssys`) zu III gehoeren und im Spiegel vorhanden sind.

**Zwei Praezisierungen zur Ausgangsfrage:** (1) IPC mit `msgbuf`/`msqid_ds` gibt es erst in System V, nicht in III.  (2) Ein
Dateisperr-Mechanismus kam weder in III noch in V7; er ist Xenix- bzw. System-V-Gut.  Beides ist hier nur Negativbefund fuer MUTOS.

**Nebenbefund (gemessen, Deutung angenommen):** `kernel/c/tty2.c` (Zeilendisziplin) benutzt Funktionen, die weder V7 noch System III
haben (`ttyrub`, `ttyecho`, `ttycol`, `unputc`, `bitset`, `ttyspec`, `ttkick`).  Gegen das Berkeley-Neutreiber `ttynew.c` aus
2.8BSD (`https://www.tuhs.org/Archive/Distributions/UCB/2BSD/2.8bsd.tar.gz`, nur zu diesem Test geladen, nicht abgelegt) liegt
`tty2.c` bei nur 20 %; dort heissen die Funktionen `ntyrub`/`ntyecho`.  Ursprung offen; moegliche Quellen: 2.9BSD/4.1BSD-`tty.c`,
WEGA/ZEUS.  Das wird in H6 geklaert.  Bis dahin: `tty2.c` -> `Origin: none` (Ursprung unbekannt).

## 2. Messverfahren

```
V=original/unix-v7/usr/sys; S=original/sys3
python3 -I tools/herkunft/herkunft.py report \
  --ref v7=$V/sys:$V/dev:$V/h:$V/conf \
        s3pdp=$S/uts/pdp11/os:$S/uts/pdp11/io:$S/uts/pdp11/cf:$S/head/sys \
        s3vax=$S/uts/vax/os:$S/uts/vax/io:$S/uts/vax/cf:$S/head/sys \
  --json doc/herkunft/daten/vergleich_abs.json --md doc/herkunft/daten/vergleich_abs.md
python3 -I tools/herkunft/herkunft.py sysent kernel/conf/sysent.c \
  --ref v7=$V/sys/sysent.c s3pdp=$S/uts/pdp11/os/sysent.c s3vax=$S/uts/vax/os/sysent.c
python3 -I tools/herkunft/herkunft.py structs --mutos kernel/h --ref v7=$V/h s3pdp=$S/head/sys s3vax=$S/head/sys
```

* MOSS-Winnowing, k=5, w=4, Stufe `abs`: lokale Namen -> `ID`, Zahlen -> `NUM`, Skalartypen -> `T`; Casts, `register` und lokale
  Deklarationen entfallen (blendet die Nahtstelle PDP-11 -> Z8001 aus).  Aufrufnamen, Struct-Member, Strings, Schluesselwoerter bleiben.
  Die Stufen `names` und `strict` stehen je Paar im JSON (`sim_names`, `sim_strict`).
* `sim` einer Funktion = (Anteil der MUTOS-Fingerabdruecke in der Referenzfunktion + Anteil der Referenz in MUTOS) / 2; Containment je
  Richtung (`c_ab`, `c_ba`) und Jaccard (`jac`) stehen im JSON.  Beste Referenzfunktion je MUTOS-Funktion ueber den **ganzen**
  Quellbaum, nicht nur die gleichnamige Datei.
* Modulwert = mit der Tokenzahl gewichtetes Mittel der besten Funktionstreffer; in Klammern: Funktionen mit sim >= 50 % / alle Funktionen.
* Referenzumfang: V7 89 Dateien / 403 Funktionen; SysIII-PDP-11 114 / 463; SysIII-VAX 105 / 403.  `head/sys` ist fuer beide SysIII-Varianten
  derselbe Baum, daher stimmen deren Header-Spalten ueberein.  Der Echtheitsvorbehalt zum SysIII-Spiegel (Plan Abschnitt 2) gilt weiter.
* Grenzen: sehr kurze Funktionen (< 40 Token) erreichen leicht 100 % gegen irgendeine Stub-Funktion (daher `fakemx.c` als "beste Datei"
  bei `machdep`, `text`, `ureg`); dort zaehlt der Namensvergleich (`gl.Name` in `daten/vergleich_abs.md`).  Tabellen (`sysent.c`, `conf.c`)
  eignen sich nicht fuer Token-Vergleich; `sysent` wird slotweise gemessen (4.1).

## 3. Matrix Modul x Quelle

### 3.1 Funktionsdateien (`kernel/c`)

Spalten V7 / SysIII-PDP / SysIII-VAX: gewichtetes Mittel (Funktionen >= 50 % / Funktionen).  "Datei" = die V7-Datei mit den meisten
Treffern.  Einstufung nach Plan Abschnitt 5 (`Origin`).

| Modul | Fkt | Token | V7 | SysIII-PDP | SysIII-VAX | Datei | Einstufung |
|---|---|---|---|---|---|---|---|
| alloc.c | 7 | 1433 | 88% (7/7) | 69% (7/7) | 72% (7/7) | alloc.c | complete (V7), sicher |
| bio.c | 19 | 2547 | 81% (17/19) | 65% (15/19) | 64% (15/19) | bio.c | partial: V7; mapalloc/mapstart eigen, sicher |
| clock.c | 1 | 524 | 64% (1/1) | 41% (0/1) | 41% (0/1) | clock.c | partial: V7 clock, Z8001-Anpassung, wahrscheinlich |
| dev0.c | 11 | 2092 | 25% (2/11) | 18% (1/11) | 18% (1/11) | tm.c | none (Diskettentreiber fd*), wahrscheinlich |
| fio.c | 8 | 875 | 85% (6/8) | 63% (4/8) | 63% (4/8) | fio.c | complete (V7), sicher |
| iget.c | 8 | 1501 | 89% (8/8) | 65% (7/8) | 74% (8/8) | iget.c | complete (V7), sicher |
| lp.c | 7 | 1409 | 18% (0/7) | 24% (0/7) | 24% (0/7) | - | none (Drucker lp*), wahrscheinlich |
| machdep.c | 4 | 312 | 33% (2/4) | 29% (1/4) | 11% (1/4) | fakemx.c | partial/eigen (Z8001-Kern), vermutet |
| main.c | 3 | 563 | 84% (3/3) | 49% (1/3) | 48% (2/3) | main.c | complete (V7), sicher |
| malloc.c | 2 | 384 | 85% (2/2) | 85% (2/2) | 82% (2/2) | malloc.c | complete (V7 = SysIII), sicher |
| nami.c | 1 | 743 | 87% (1/1) | 64% (1/1) | 64% (1/1) | nami.c | complete (V7), sicher |
| pipe.c | 8 | 1092 | 95% (8/8) | 33% (4/8) | 42% (4/8) | pipe.c | complete (V7), sicher |
| prf.c | 5 | 355 | 100% (5/5) | 80% (4/5) | 80% (4/5) | prf.c | complete (V7), sicher |
| rdwri.c | 4 | 874 | 80% (4/4) | 42% (0/4) | 51% (2/4) | rdwri.c | complete (V7), sicher |
| rk.c | 13 | 928 | 35% (3/13) | 20% (3/13) | 13% (1/13) | rk.c | partial: mm*/sy* aus V7 mem.c/sys.c (ca. 36-45 %), rk* eigen, vermutet |
| sig.c | 10 | 1567 | 82% (10/10) | 73% (8/10) | 72% (9/10) | sig.c | complete (V7), sicher |
| slp.c | 11 | 2105 | 88% (11/11) | 58% (8/11) | 49% (7/11) | slp.c | complete (V7), sicher |
| subr.c | 7 | 927 | 85% (7/7) | 77% (7/7) | 78% (6/7) | subr.c | complete (V7), sicher |
| sys1.c | 8 | 3017 | 64% (6/8) | 44% (4/8) | 43% (4/8) | sys1.c | partial (V7; exece/getxfile/Z8001 geaendert), wahrscheinlich |
| sys2.c | 11 | 1331 | 89% (11/11) | 68% (9/11) | 68% (9/11) | sys2.c | complete (V7), sicher |
| sys3.c | 8 | 1298 | 87% (7/8) | 61% (6/8) | 66% (6/8) | sys3.c | complete (V7), sicher |
| sys4.c | 24 | 1740 | 83% (21/24) | 58% (13/24) | 57% (13/24) | sys4.c | complete (V7), sicher |
| text.c | 10 | 470 | 74% (10/10) | 74% (10/10) | 40% (9/10) | fakemx.c | partial (V7-Stubs, sehr kurz), vermutet |
| trap.c | 3 | 771 | 48% (2/3) | 32% (2/3) | 26% (2/3) | trap.c | partial (V7-Gerippe, Z8001-Traps eigen), wahrscheinlich |
| tty.c | 11 | 956 | 29% (4/11) | 21% (0/11) | 19% (0/11) | kl.c | none (Mailbox-Terminal tc*), wahrscheinlich |
| tty2.c | 20 | 4732 | 34% (7/20) | 17% (0/20) | 18% (0/20) | tty.c | partial/unklar, vermutet |
| ureg.c | 3 | 185 | 76% (3/3) | 17% (1/3) | 28% (2/3) | fakemx.c | partial (V7 estabur, Z8001-Segmente), vermutet |

Gesamt (227 Funktionen, 28 602 Token): V7 **66 %**, SysIII-PDP 47 %, SysIII-VAX 46 %.  Ohne die acht maschinen- und geraetenahen
Dateien (`dev0 lp rk tty tty2 machdep ureg trap`; 155 Funktionen, 19 277 Token): V7 **82 %**, SysIII-PDP 60 %, SysIII-VAX 60 %.
Je Funktion ist V7 in 134 Faellen um mehr als 5 Punkte besser als SysIII-PDP, SysIII in 12 Faellen, 81 Faelle liegen innerhalb
5 Punkten.  Textgleich (>= 99 %): 68 Funktionen zu V7, 35 zu SysIII-PDP; 34 davon sind auch V7-gleich, die einzige Ausnahme ist `iodone` (V7 hat dort
zusaetzlich UNIBUS-Code, s. u.).

Die 12 Funktionen mit SysIII-Vorsprung von mehr als 5 Punkten: neun davon sind MUTOS-eigene Treiberfunktionen mit Werten unter 32 % (`mapalloc`,
`mapstart`, `fdopen`, `lpopen`, `lpclose`, `lpcanon`, `ttstart`, `putchar`, `rkstrategy`: zufaellige Naehe, kein Beleg).  Die drei Kernfunktionen sind `iodone`
(V7 hat PDP-11-UNIBUS-Code `B_MAP`/`mapfree`, `rg -n -A14 '^iodone' original/unix-v7/usr/sys/dev/bio.c`; SysIII und MUTOS nicht), `itrunc` (Unterschied ist
`i_un.i_addr` gegen flaches `i_addr`, Z8001-Anpassung; MUTOS benutzt wie V7 `ICHG|IUPD`) und `psig` (88 % gegen 83 %, `savfp`/Z8001-Fliesskomma-Teil, kein
SysIII-Merkmal erkennbar).  Eine Funktion mit einem SysIII-Spezifikum wurde nicht gefunden.

### 3.2 Header und Konfiguration (Dateiebene, beste Referenzdatei)

Header sind kurz; die Dateiaehnlichkeit ist nur ein grober Hinweis.  Trennende Aussagen stehen in 4.2.

| Datei | Token | V7 | SysIII-PDP | SysIII-VAX |
|---|---|---|---|---|
| buf.h | 118 | 71% buf.h | 50% buf.h | 50% buf.h |
| callo.h | 34 | 66% callo.h | 88% callo.h | 88% callo.h |
| conf.h | 219 | 55% conf.h | 63% conf.h | 63% conf.h |
| dir.h | 22 | 54% dir.h | 54% dir.h | 54% dir.h |
| file.h | 62 | 47% file.h | 51% file.h | 51% file.h |
| filsys.h | 76 | 94% filsys.h | 78% filsys.h | 78% filsys.h |
| ino.h | 47 | 84% ino.h | 88% ino.h | 88% ino.h |
| inode.h | 136 | 61% inode.h | 60% inode.h | 60% inode.h |
| map.h | 33 | 28% map.h | 71% map.h | 71% map.h |
| mbx.h | 38 | - | - | - |
| mount.h | 33 | 63% mount.h | 24% mount.h | 24% mount.h |
| param.h | 356 | 52% param.h | 44% param.h | 44% param.h |
| proc.h | 141 | 75% proc.h | 65% proc.h | 65% proc.h |
| reg.h | 72 | - | 55% reg.h | 55% reg.h |
| systm.h | 211 | 49% systm.h | 49% systm.h | 49% systm.h |
| text.h | 63 | 78% text.h | 63% text.h | 63% text.h |
| tty.h | 214 | 29% tty.h | 7% tty.h | 7% tty.h |
| types.h | 48 | 29% types.h | 36% types.h | 36% types.h |
| user.h | 385 | 74% user.h | 62% user.h | 62% user.h |
| user_ext.h | 113 | - | - | - |
| conf.c | 762 | 34% partab.c | 34% partab.c | 34% partab.c |
| sysent.c | 587 | 2% sysent.c | 1% sysent.c | 1% sysent.c |

`mbx.h`, `user_ext.h` und `devtab` (in `conf.h`) haben kein Gegenstueck (MUTOS-eigen, Mailbox zur U880-Seite).  `-` bei `reg.h`/V7 bedeutet:
kein gemeinsamer Fingerabdruck (die Registerlayouts der CPUs sind verschieden).  `conf.c`/`sysent.c`: Tabellen, siehe 4.1 und 5.

## 4. V7 oder System III?  Trennmerkmale (Plan 3.3)

### 4.1 Systemaufruftabelle `sysent` (gemessen)

`python3 -I tools/herkunft/herkunft.py sysent ...`, Rohdaten `daten/sysent.json`; 64 Slots, Vergleich je Slot (Funktion, Argumentzahl):

* Gleiche Funktion im gleichen Slot wie **V7: 58 von 64** (Argumentzahl ebenfalls gleich: 58); **SysIII-PDP: 54** (52); **SysIII-VAX: 54** (49).
  Abweichungen zu V7: Slot 31 stty, 32 gtty, 51 sysacct, 52 sysphys, 53 syslock, 56 mpxchan sind in MUTOS `nosys`.
* Wie V7 und **anders als SysIII**: Slot 0 `nullsys` (SysIII `nosys`), 5 `open` mit 2 Argumenten (SysIII 3), 35 `ftime` (SysIII `nullsys`/`nosys`),
  38 `nullsys`, 39 `nullsys` (SysIII `setpgrp`), 41 `dup` mit 2 Argumenten (SysIII 1).
* In SysIII belegt, in MUTOS leer (`nosys`): 57 `utssys`, 62 `fcntl`, 63 `ulimit`; 39 `setpgrp`.  Es gibt keinen Slot, den MUTOS wie SysIII und
  anders als V7 belegt (alle 6 Abweichungen zu V7 sind Streichungen).
* Der Kommentar in `kernel/conf/sysent.c` ("Nummern nach der WEGA-/System-III-Tabelle") ist *angenommen* und durch die Messung nicht gedeckt:
  die Nummern sind die V7-Nummern.  Korrektur in H4.
* Der Token-Vergleich der Datei `sysent.c` (1-2 %) ist wertlos: MUTOS schreibt `{ 1, rexit }`, die Referenzen `1, 1, rexit`.

### 4.2 Strukturlayouts (gemessen)

`herkunft.py structs`: Verhaeltnis der Member-Namensfolgen (1,00 = gleich), Rohdaten `daten/structs.json`.

| Struktur | V7 | SysIII | Unterschied |
|---|---|---|---|
| `proc` | **1,00** | 0,90 | SysIII hat zusaetzlich `p_swaddr`, `p_swsize`, `p_tsize` |
| `mount` | **1,00** | 0,57 | SysIII hat `m_flags` |
| `filsys` | **1,00** | 0,91 | SysIII hat `s_dinfo` statt `s_m`, `s_n` |
| `cdevsw` | **1,00** | 0,83 | SysIII ohne `d_stop`, `d_ttys` |
| `text` | 1,00 | 0,80 | nur Reihenfolge der gleichen Member anders |
| `file`, `map`, `callo`, `dinode`, `direct`, `bdevsw`, `clist` | 1,00 | 1,00 | in beiden gleich, nicht trennend |
| `buf` | 0,92 | 0,80 | MUTOS `b_addr`, `b_xmem` (Z8001) statt `b_un`; SysIII hat `b_paddr`, `b_proc` |
| `inode` | 0,86 | 0,86 | MUTOS `i_addr` flach (Z8001), V7 `i_un`, SysIII `i_blks`: nicht trennend |
| `linesw` | 0,56 | 0,88 | MUTOS `l_input`, `l_output`, `l_x` -- eigene Tabelle, weder V7 (`l_rint`, `l_rend`, ...) noch SysIII (`l_mdmint`) |
| `user` | 0,75 | 0,63 | MUTOS-Fuellfelder `u_x..` und Z8001-Felder; SysIII hat u. a. `u_comm`, `u_acflag` |
| `tty` | 0,18 | 0,12 | MUTOS-eigene Struktur |

`proc`, `mount`, `filsys`, `cdevsw` sprechen eindeutig fuer **V7**; `linesw`, `tty` und `devtab`/`rkmbx` sind MUTOS-eigen.

### 4.3 Bausteine, die nur SysIII hat (gemessen)

`rg -il <Begriff> kernel/c kernel/h kernel/conf` ergibt fuer `acct`, `errlog`, `elog`, `utssys`, `sysinfo`, `utsname`, `var\.h`, `ubm`, `setpgrp`,
`ulimit`, `fcntl`, `ustat`, `p_swaddr`, `sysacct`, `sysphys`, `syslock`, `mpxchan`: **0 Treffer**.  Im SysIII-Baum
(`original/sys3/uts/pdp11/os`, `original/sys3/head/sys`) treffen `sysinfo` 9 Dateien, `utsname` 6, `var\.h` 18, `errlog` 1; im V7-Baum jeweils 0.
(`acct` steht in beiden Baeumen, `sysacct` nur in MUTOS nicht -- Slot 51 ist leer.)

### 4.4 Konstanten (`kernel/h/param.h`)

`NSIG`: MUTOS 17 (Kopfkommentar `param.h`: am Kernel gemessen, `psignal`: `sig < 17`), V7 17, SysIII **20**.  Nicht trennend: `PZERO 25`,
`NZERO 20`, `PINOD 10`, `PUSER 50`, `NICINOD 100`, `NICFREE 50`, `DIRSIZ 14`, `NOFILE 20`.  Konfigurationswerte (`NPROC`, `NBUF`, `NINODE`, `NFILE`,
`HZ`) weichen von beiden ab (Hardware): ohne Aussage.

### 4.5 Code-Einzelheiten (gemessen)

* Flag-Reihenfolge `ICHG|IUPD` / `IUPD|ICHG` (`rg -c`, summiert): `kernel/c` 1 / 9; V7 `usr/sys/sys` **1 / 9**; SysIII-PDP `uts/pdp11/os` 0 / 16.
* Namen: `iexpand` (SysIII `iread`), `deverror` (SysIII `deverr`) wie V7.  `copen(ip, mode, trf)` in `sys2.c` hat die Signatur und Aufrufe von V7
  `open1`; SysIII `copen(mode, arg)` ist anders.  *Vorsicht:* Der Name `copen` ist in `doc/kernel/kernel_namen.md` vergeben (wahrscheinlich); die
  Signatur ist gemessen, daher wird hier nicht der Name als Beleg gezaehlt.
* Stringliterale in `kernel/c` und `kernel/conf` (43 verschiedene, > 1 Zeichen): 26 in V7 **und** SysIII, 5 nur in V7 (`Running a dead proc`,
  `zero wchan`, `mem = %D`, `err`, Zeichentabelle in `tty`), 1 nur in SysIII (`trap type %x`: die VAX-Fassung schreibt `%x`, V7/SysIII-PDP `%o`;
  MUTOS' `%x` ist als Z8001-Eigenheit zu lesen, nicht als SysIII-Beleg), 11 in keinem (Paritaets-/Treibertexte, `map overflow`,
  `Random interrupt`).  Rohdaten `daten/strings_reihenfolge.json`.
* Funktionsreihenfolge: die gemeinsamen Funktionen stehen in jedem Modul in V7-Reihenfolge (0 Inversionen); das gilt auch gegen SysIII, die Reihenfolge ist
  daher *nicht trennend*.
* Funktionen eines MUTOS-Moduls, die in der gleichnamigen V7-Datei stehen, in der gleichnamigen SysIII-PDP-Datei aber nicht: `readp`, `writep` (pipe.c),
  `geteblk`, `clrbuf` (bio.c), `setpri` (slp.c).  Funktionen der gleichnamigen SysIII-Datei, die MUTOS nicht hat: u. a. `getablk`, `physck`, `binval`
  (bio.c), `delay` (clock.c), `gethead`, `freeproc` (sys1.c), `checkur` (ureg.c), `stray` (trap.c).  (Nur Dateivergleich; die Funktion kann in der
  anderen Quelle in einer anderen Datei stehen.)

### 4.6 Bewertung

| Frage | Befund | Sicherheit |
|---|---|---|
| V7 Hauptquelle des Kerns? | Funktionstext (82 % im Kern, 68 textgleiche Funktionen), `sysent` 58/64 Slots, `proc`/`mount`/`filsys`/`cdevsw`, `NSIG 17`, `ICHG\|IUPD`-Zaehlung, Signaturen | **sicher** |
| Stammt Code aus System III? | Kein SysIII-Alleinmerkmal in `kernel/c`, `kernel/h`, `kernel/conf` (4.1-4.4) | **sicher** (negativ) |
| Einzelne Funktionen aus SysIII? | nicht erkennbar; wo SysIII gleich nah ist, ist V7 = SysIII textgleich oder Hardware erklaert den Vorsprung | wahrscheinlich nein |
| SysIII-PDP oder -VAX? | nicht entscheidbar und gegenstandslos | -- |
| Exakt Spencer-V7 ohne Patches? | **nicht geprueft** (V7-Addenda fehlen, Plan 2); Abweichungen sind Z8001-Portierung und Dekompilierung | vermutet |

WEGA/ZEUS (Z8001, SysIII-Abkoemmling) bleibt als moegliche Vorlage fuer Z8001-Teile (`machdep`, `trap`, `ureg`, `tty2`) denkbar; das ist *angenommen*
(kein WEGA-Vergleich in H2).

## 5. Module ohne (belegten) Bezug -- MUTOS-eigen

* `dev0.c` (11 Funktionen `fd*`, Diskettentreiber): die `fd*`-Funktionen liegen gegen V7 unter 25 %, ausser `fdsub` (62 % gegen `tcommand`) und `fdioctl` (51 % gegen
  `mpxchan`); beides Treffer auf kurzen Mustern in einer anderen Funktion auf kurzen Mustern (andere Funktion, anderer Name). **wahrscheinlich** eigen.
* `lp.c` (Drucker): V7 18 %, SysIII 24 %, keine Funktion >= 50 %.  **wahrscheinlich** eigen.
* `tty.c` (Mailbox-Terminal `tc*`, `ttstart`, `putchar`, `ttyinit`): 29 % / 21 %; **wahrscheinlich** eigen.
* `rk.c`: `mmread`/`mmwrite`/`syopen`/`syread`/`sywrite`/`syioctl` ca. 36-45 % gegen V7 `mem.c`/`sys.c` (gleiches Grundgeruest, Z8001-Zugriff);
  `rkopen`, `rkstart`, `rkintr`, `rkstrategy`: unter 50 %.  **vermutet**: Plattentreiber ueber Mailbox ist eigen, `mm*`/`sy*` V7-nah.
* `bio.c`: `mapalloc`, `mapstart` ohne Gegenstueck (V7 `mapalloc` ist UNIBUS-Mapping): eigen.
* `machdep.c`, `ureg.c`, `trap.c`, `clock.c`: V7-Gerippe mit Z8001-Teilen (`startup`, `sigret`, Segmentverwaltung); `trap` 48 %.
* `tty2.c`: Ursprung offen (siehe 1).
* `conf.c`: Geraetetabellen sind MUTOS-spezifisch; Token-Vergleich nicht aussagekraeftig.
* Header: `mbx.h`, `user_ext.h`, `devtab` und `linesw` in `conf.h`, `tty.h`, `reg.h`.

## 6. Folgerungen fuer H3-H8

1. H3 nimmt als Referenz **V7** (`usr/sys/sys`, `dev`), Herkunftsvermerk `Source: UNIX V7 usr/sys/sys/<datei>`; SysIII nur bei Textgleichheit ("= SysIII").
2. Der Z8001-Nahtstelleneffekt (`i_addr`/`i_un`, `b_addr`/`b_un`, Skalartypen) ist je Datei zu pruefen; Rundlaufpruefung nach Plan 3.4.
3. `kernel/conf/sysent.c`-Kommentar in H4 auf V7-Nummern korrigieren (Dateikopf nennt WEGA/SysIII).
4. Offen: `tty2.c` (H6, WEGA/ZEUS), `rk.c`-Mischung (H5), V7-Addenda laden (Plan 2).

## 7. Dateien

* Werkzeug `tools/herkunft/herkunft.py`, Tests `tests/test_herkunft.py`
* Rohdaten in `doc/herkunft/daten/`: `vergleich_abs.json` (alle Funktions- und Dateivergleiche), `vergleich_abs.md` (maschineller Bericht),
  `sysent.json`, `structs.json`, `strings_reihenfolge.json`

## 8. Stand AP H3 (Pilot, 2026-10-31)

Wiederhergestellt (V7-Text, Rundlauf geprueft): `alloc`, `iget`, `slp`, `sig` -- siehe `alloc.md`, `iget.md`, `slp.md`, `sig.md`; Rundlaufweg in `rundlauf.md`.
Ergebnis: 31 von 36 Funktionen bytegleich (vorher 26 von 36); `alloc` enthaelt System-III-Zaehler (`s_tfree`/`s_tinode`), sonst V7.

## 9. Stand AP H4 (Header und Konfiguration, 2026-10-31)

Header und `conf.c`/`sysent.c` in V7-Form bei unveraendertem Layout, Details in `header.md`.  Rundlauf aller 27 Module: 181 von 227 Funktionen bytegleich (vorher 181);
Gesamtbau mit Boot BYTEGLEICH (36 352 Byte).  `alloc`, `iget`, `slp`, `sig` und die uebrigen Module nutzen `b_un`/`i_un`/`f_un`.  Die Strukturverhaeltnisse in 4.2 fuer `buf`/`inode` (0,92/0,86)
sind damit ueberholt (1,00 nach Angleichung, kein neuer Beleg).  `user_ext.h` entfaellt.

## 10. Stand AP H3, Gruppe `sys2 sys3 sys4 fio prf subr malloc pipe` (2026-10-31)

V7-Text (mit V7-Kommentaren, englisch) in allen 8 Modulen, Dateikoepfe nach Plan 42 Abschnitt 5, Einzelheiten in `sys2.md`, `sys3.md`, `sys4.md`, `fio.md`, `prf.md`, `subr.md`, `malloc.md`, `pipe.md`.
Neue Header `stat.h`, `timeb.h` (V7-Text, vorher lokale Deklarationen in `sys3.c`/`sys4.c`).  Alle Zahlen **gemessen** (Rundlauf je Funktion, `rundlauf.md`; Sollwerte in `daten/rundlauf_soll.txt`).

* Rundlauf: **69 von 73 Funktionen bytegleich, vorher 66 von 73** (sys2 11/11 vorher 10, sys3 8/8, sys4 23/24 vorher 22, fio 8/8, prf 5/5, subr 6/7 vorher 5, malloc 0/2, pipe 8/8).
  Zugewinn durch die V7-Form: `rdwr`, `chdirec`, `bcopy`.  Keine Funktion schlechter.  Zwischenstufen, die kurz schlechter waren und gezielt zurueckgenommen wurden: `smount` (`SUPERB` braucht `(daddr_t)`), `ftime` (`(int)ms`).
* Gesamtbau `gesamtbau.py --uebersetzen --stufe 1 --boot` auf dem endgueltigen Stand: **184 von 227** Funktionen aus C (vorher 181), `Gesamt: BYTEGLEICH (0 Byte ungleich)`, 36 352 Byte,
  Boot bis zur Shell und Arbeitstests (`summe = 5050` zweimal, `cc -O -c prf.c` 1600 B).  Gesamtes `pytest`: 213 bestanden, 2 uebersprungen.
* Noch "nahe" (Muster des aelteren Kernel-`c2`, `c_rueckbau.md` K7b/K7c): `bmap` 263/308, `ssig` 39/52, `malloc` 24/52, `mfree` 1/119 abweichende Woerter -- unveraendert gegenueber vorher.
  Befund entgegen K7a: `bcopy` war keine `c2`-Abweichung (kein "anderer c2-Stand"), sondern die Quellform (`register count` als Parameter); `doc/kernel/c_rueckbau.md` ist an dieser Stelle ueberholt.
* **Aussage "Kern V7, nur einzelne System-III-Zuege" bestaetigt**, Zahl der SysIII-Zuege waechst um einen: `smount` springt nach fehlgeschlagenem `d_open` nach `out1` (SysIII textgleich; V7 `out`).
  (Vorher: `s_tfree`/`s_tinode` in `alloc.c`.)  `seek` hat eine `off < 0`-Pruefung wie SysIII, aber in anderer Form (siehe unten).  Kein SysIII-Alleinmerkmal sonst; `pipe` ist V7 (kein `IFIFO`).
* **Fremdzuege (weder V7 noch System III) fuer H6:**
  1. `malloc.c`: Kartengroesse 15 Eintraege, `panic("map overflow\n")` (Text 8AE4).  `rg 'map overflow' original/` ohne Treffer.
  2. `sys2.c` `seek`: `if(uap->off < 0) { u.u_error = EINVAL; uap->off = 0; }` (SysIII: `return` ohne `off = 0`, V7: keine Pruefung).
  3. `sys3.c` `sumount`: Busy-Test ueber `i_count` und Freigabe `ip->i_number = 0` fuer unbenutzte Eintraege (V7/SysIII: `i_number != 0` -> `EBUSY`).
  4. `sys4.c` `stime`: loescht `i_lastr` aller Inodes (haengt an der MUTOS-eigenen Freigabezeit in `iget.c`).
  5. `sys4.c` `ftime`: Zeitzone 0 / kein DST (Konfigurationswert, keine Herkunftsaussage).
  6. `sys3.c` `exec`-Stumpf (`u_ap[2] = 0; exece()`): V7 hat `exec` in `sys1.c`; zusammen mit der leeren `expand` Teil der Z8001-Anpassung.
  7. Z8001-bedingt (kein Fremdzug): `proctop` in `kill`, kein `suibyte`/`fuibyte`, Zeiger auf `u` bei 0xFC00.

## 11. H3 Gruppe 2: nami, rdwri, bio, main, sys1, clock, text

Rundlauf (`tools/herkunft/rundlauf.sh`, alle 7 Module, Exit 0, keine Regression gegen `daten/rundlauf_soll.txt`): **39 von 46
Funktionen bytegleich** (vorher 38).  Gesamtbau-Ergebnis auf dem endgueltigen Stand: **BYTEGLEICH** (0 Byte ungleich, 36352 Byte), 185 von 227 Funktionen aus C (vorher 184), Arbeitstests ok (`summe = 5050`, `cc -O -c prf.c` 1600 B); `swbuf1`/`swbuf2` als reines `extern` in `bio.c` bauen und binden problemlos.  Gemessen.

| Modul | bytegleich vorher -> nachher | Stand |
|-------|------------------------------|-------|
| nami | 1/1 -> 1/1 | V7-Text (ohne mpx-Teile) |
| rdwri | 2/4 -> 3/4 | `iomove` jetzt bytegleich (V7-Form `do..while(--n)` mit `NBPW-1`: DJNZ war Quellform, keine `c2`-Abweichung, wie bei `bcopy`); `readi` V7-Text, aber nahe (108/206 Woerter) |
| bio | 17/19 -> 17/19 | 15 Funktionen V7-Text; `mapalloc` (14/37), `mapstart` (28/44) MUTOS-eigen; `swap`, `physio` MUTOS-Form mit V7-Original als Kommentar |
| main | 2/3 -> 2/3 | `binit` weicht in 1 von 84 Woertern ab (`b_error` bei +15) |
| sys1 | 6/8 -> 6/8 | V7-Code nicht einsetzbar (anderer Kopf, Argumentrahmen, Speicheraufbau): nur V7-Kommentare und `/* MUTOS: */`-Marken; `exece` (1/389), `getxfile` (177/401) nahe |
| clock | 0/1 -> 0/1 | Prozessteil V7 (`SCHMAG 8/10`), nahe (210/260); alter Kopf "System-III-Form (WEGA)" war falsch |
| text | 10/10 -> 10/10 | `xfree` in V7-Form bytegleich, aber nur mit vorzeichenbehaftetem `ctod` (`ctodu` macht 1/71 Woerter falsch) |

### Fremdzuege (weder V7 noch System III) fuer H6

1. `bio.c` `breada`: Vorauslesen nur bei freiem Puffer (`bfreelist.av_forw != &bfreelist`); System III prueft `b_bcount>1`, V7 nichts.
2. `sys1.c` `exit`: eine Schleife ueber `proc[0]..proctop` mit Zombie-Zaehler und einem `wakeup(&proc[1])` (V7: zwei Schleifen; System III: `resume`/`SIGCLD`).
3. `sys1.c` `exece`: bei Fehler werden die 10 Argumentbloecke im Cache ungueltig gemacht (`B_AGE`).
4. `clock.c`: alle 30 s bei gesetztem `cf_x88a` `sflag1` erhoeht und `runout` geweckt (*angenommen*: der Scheduler ruft daraufhin `update()`).
5. `sys1.c` `setregs`: Name von `u_exname` nach `u_dbuf` (V7: `u_dbuf` -> `u_comm`).
6. `sys1.c` `fork`/`wait`: `proctop` als variable Tabellengroesse.

Offen: ob `rdwri.c`-Probekopie (196 B, 9/98 Woerter) und echte Datei (194 B, bytegleich) beim `iomove` anders uebersetzen, ist ungeklaert (*Ursache unbekannt*).

## 12. H5: trap, machdep, ureg, rk, dev0, lp, tty (2026-10-31)

Einzelheiten in `trap.md`, `machdep.md`, `ureg.md`, `rk.md`, `dev0.md`, `lp.md`, `tty.md`.  `tty2.c` und `kernel/c/varianten/` sind nicht Teil dieses Pakets (H6).  Headern und `kernel/conf` aus H4 geprueft: alle 25 Dateien tragen den Herkunftskopf, kein Nicht-ASCII-Zeichen.

Rundlauf (`tools/herkunft/rundlauf.sh`, 6 Module, **vorher = nachher**, gemessen; `dev0` wird im Original ohne `-O` uebersetzt und ist nur vom Gesamtbau abgedeckt):

| Modul | Origin | bytegleich | Aenderung |
|---|---|---|---|
| trap | partial | 2/3 | V7-Kommentare, Kopf; V7-Text nicht einsetzbar (anderer Rahmen) |
| machdep | partial (schwach) | 3/4 | V7-`sendsig` als Kommentar, Kopf |
| ureg | partial | 2/3 | `cinit` in V7-Form (bytegleich), V7-`sureg` als Kommentar |
| rk | partial | 13/13 | `sy*` in V7-Text (bytegleich), V7-Kommentare an `mm*`, `rk*` |
| dev0 | none | -- (Gesamtbau) | nur Uebersetzung der Kommentare, Kopf |
| lp | none | 4/7 | nur Kommentare, Kopf |
| tty | none | 10/11 | nur Kommentare, Kopf |

Befunde entgegen der Erwartung:

* Der Spencer-V7-Baum hat **keine `lp.c`**; `lp.c` aehnelt eher System III `lp.c` (Merker- und Namensfamilie), 23 % Dateiaehnlichkeit.  Der Vermerk "folgt V7 lp.c" war nicht pruefbar.
* "WEGA-fd-Muster" im Kopf von `dev0.c` ist nicht belegt (WEGA `fd.c` 10 %, WEGA `lp.c` 10 %, `ttydev.c` 13 %): WEGA ist fuer diese Treiber **nicht** der Vorfahre (gemessen).
* `cinit` (in `ureg.c`) kommt aus V7 `prim.c`, nicht aus V7 `ureg.c`.

### Fremdzuege (weder V7 noch System III) fuer H6

1. `trap.c`: Zufallsinterrupt (Fall 15) mit `ident` in der Meldung und `goto out` (V7: `return`); Paritaetsfall 11 mit Auswertung von `ident` (Z8001-Hardware, *angenommen*).
2. `trap.c`: Systemaufruf 0 ist `sigret` (V7: indirekter Systemaufruf); Argumente aus dem Registerrahmen (vier Worte, `blk4`), nicht aus dem Befehlsstrom.
3. `machdep.c`: `kstub` (leere Funktion zwischen `startup` und `sendsig`), `sigret` (kein V7-Gegenstueck); `startup` mit Speicherpruefung ueber `usegm` und `mfree(swapmap, nswap, 1)`.
4. `ureg.c`: `estabur` ohne Segmentregister (nur Groessenpruefung, 256 Segmente).
5. `rk.c`: Mailbox-Plattentreiber (`rkstart`, Status 0xC8 = Einheit fehlt, 3 Wiederholungen, Blockgrenze 0x260); `mmread`/`mmwrite` waehlen das Segment ueber `usrseg`.
6. `lp.c`: Familie "klassischer UNIX-Zeilendrucker" (SysIII-Namen, `lpcanon`), ohne belegten Vorfahren; Kandidaten 2.9BSD/3BSD `usr/sys/dev/lp.c`, V7-Originalband (beide nicht lokal).
7. `dev0.c`: Diskettentreiber `fd*` mit Controller-Befehlen 25H/27H/51H/61H ueber Mailbox -- keine Quelle gefunden.
8. `tty.c`: Konsolenring `conlog` (8DE8..8E68) in `putchar`; Ausgabeablauf `ttstart`/`ttxfer` ueber Mailbox -- eigen.

## 13. H6: Fremdherkunft -- die V7-Variante der Hippe-Sammlung (2026-10-31)

Ausfuehrlich in `fremd.md` (Quellen mit URL und SHA-256, Befehle, Tabellen).  Geladen und ausgewertet: Hippe-V7, Nijmegen-V7, V7-Patches/-Addenda, Bostic-V7-Band, 2.8/2.9/2.10/2.11BSD, 3BSD, 4.1BSD, 32V, PWB, Interdata-V6, WEGA.

* **Quelle: `Distributions/Research/Torsten_Hippe_v7/v7.tar.gz`** (`usr/sys`, Standardkonfiguration aus `conf/m.h`: `PROC_MAX`, `EXIT`, `LRUI` an; `SYSACCT`, `SYSPHYS`, `SYSLOCK`, `DISKMON`, `MX`, `SGTTY`, `XBUF`, `UNIBMAP`
  aus).  Mit dieser Konfiguration (Schalter aufgeloest) ist `sysent` zu 64 von 64 Zeilen gleich MUTOS (V7: 58 von 64); NPROC 30, NINODE 50, NFILE 50, NMOUNT 5, MAXUPRC 15, HZ 50, TIMEZONE 0, `MAPSIZ = NPROC/2 = 15`.
* **Fremdzuege aus Hippe (sicher, je mit Fundstelle):** `malloc`-Kartenlimit mit `panic("map overflow")`, `seek` `off < 0`, `sumount`-Busytest, `stime`/`i_lastr` und `iget`/`iput`-LRU (`LRUI`), `breada`-Freilistentest,
  `exit`-Schleife (`EXIT`), `exece` mit `B_AGE`-Fehlerschleife, `proctop` (`PROC_MAX`), dazu die bisherigen "System-III-Zuege" `s_tfree`/`s_tinode` (`alloc.c`), `smount` -> `out1`, `iodone` ohne `B_MAP`, kein `DISKMON`.
  In keinem anderen der 15 Baeume treten `malloc`-Grenze, `seek`-Pruefung, `breada`-Test oder `exece`-Schleife auf (Nijmegen, Schwestervariante mit denselben Schaltern, hat nur `LRUI`/`EXIT`/`PROC_MAX`).
* **`tty2.c`: Quelle gefunden (sicher).** `maptab`/`cchars`/`wchars` sind Byte fuer Byte gleich Hippe `dev/tty.c`; Funktionen entsprechen eins zu eins (`ttywipe`=`ttyrub`, `ttyretype`=`ttycol`, `zapc`=`unputc`, `ttybit`=`bitset`,
  `ttyspcl`=`ttyspec`, `ttyblock`=`ttflow`, `ttstart`=`ttkick`, `ttychars`=`ttinit`, `ttioccomm`=`ttioctl`, `wflushtty`=`ttywait`, `flushtty`=`ttyflush`); `struct tty` stimmt im Layout bis +34.  Dateiaehnlichkeit 43 %
  (mit Namensabbildung 55 %) gegen 17-34 % bei allen anderen Baeumen; die Namen in `tty2.c` waren frei vergeben.  Empfehlung (Funktionsreihenfolge, erwartete Abweichungen): `fremd.md` Abschnitt 5.3.
* **`ptrace`-Reihenfolge** `req, pid, addr, data`: Konvention der Nicht-PDP-11-Systeme (32V, System III VAX, WEGA), kein Fremdzug.
* **Ungeklaert (keine Quelle in 15 Baeumen, vermutet MUTOS-eigen):** 30-s-`update()`-Anforderung (`clock` -> `sflag1` -> `sched`; `cf_x88a` ist 0, also abgeschaltet), `setregs` `u_exname` -> `u_dbuf`, `lp.c` (alle <= 23 %).
* **Ablage:** `original/hippe-v7/` nur als Vorschlag; Lizenz der Zusaetze Dritter unklar (V7-Basis Caldera), deshalb nicht abgelegt (`fremd.md` Abschnitt 7).
* Folge fuer H3/H4: `CMAPSIZ`/`SMAPSIZ 50 (guessed)` in `param.h` falsch (Karten haben `MAPSIZ+1 = 16` Eintraege); `linesw`-Namen auf V7 (`l_rint`..`l_modem`); `XTABS 02000` ist belegt (Hippe `sgtty.h`).

## 14. H6b: Gegenprobe zur Abstammung (2026-10-31)

Ausfuehrlich in `fremd.md` Abschnitt 8 (Variantentabelle, SHA-256, Befehle).  Frage: direkt von Hippe (direkte Ableitung), gemeinsame unbekannte Vorlage (gemeinsame Vorlage) oder andere Variante (andere Variante)?  Zusaetzlich geladen und entpackt: alle UNSW-Baender
(1, 4-7, 81-83, 85-87, 90, 92, 93, 106-110), V7M 2.1 (Jean Huens), Ultrix-11 3.1-Quellen, Bostic-V7-Band (jetzt als Baum), V7-Abbilder und Y2K-Platte, `Net.v7bugs`.  Nicht geladen (Grund in `fremd.md` 8.2): Coherent (i386), Research V8-V10,
Venix, Ultrix-3.0-Baender, CB_Unix.

* **Abweichungsanalyse** (`tools/herkunft/devdiff.py`): 177 MUTOS-Funktionen mit Hippe-Gegenstueck, 146 als Text vergleichbar, 112 ohne Abweichung; 95 Abweichungen: 72 Z8001-/Namensanpassung, 14 Hippe-Inhalt in anderer Schreibweise, 7 MUTOS-eigen,
  1 Z8001, **1 fraglich** (`exece`-Fehlerausgang `goto bad2` hat Nijmegen-/V7-Form, Hippe `iput; return`).  Keine eindeutige Stelle, an der MUTOS aelter oder einfacher als Hippe waere.  In allen 26 Funktionen, in denen Hippe von Bell-V7
  abweicht, traegt MUTOS die Hippe-Abweichung.  Vier Merkmale gibt es nur in Hippe (`malloc`-Kartengrenze mit `map overflow`, `getxfile(.., ns)`, `NPROC 30`/`NINODE 50`/`MAPSIZ`, die 128-Byte-`maptab`); MUTOS hat alle vier.
* **UNSW:** UNSW 81/83 sind identisch und gleich Bell-V7; UNSW 92 (V7, 1981) hat `exece`-`B_AGE` und `s_tfree`, aber nicht LRUI/PROC_MAX/Tabellen.  Die Hippe-Merkmale `i_lrt`, `max_proc`, `breada`-Test, `sumount`-`i_count` stehen schon in den **UNSW-V6-Kerneln**
  (UNSW 1, 4, 106): die Linie ist UNSW/AUSAM -> Vrije/Nijmegen -> Hippe, `exece`/`B_AGE`, `s_tfree` und `seek` sind keine Hippe-Eigenheiten (Korrektur an Abschnitt 13).  V7M (Overlay-Kernel) und Ultrix-11 haben das Hippe-Bild nicht.
* **Zeit:** Hippes Quellstempel (35 x 1980, 19 x 1981-82, 40 x 1986) sagen nichts ueber das Alter der Zuege: 22 von 25 Kernelmoduln sind in Hippes Bibliothek `LIB1.ok` (1982-01-13) und `LIB1` (1986-04-03) **byte-gleich**; die einzige
  Quelltextaenderung 1982 -> 1986 ist `malloc.c` (`map overflow`), und MUTOS hat sie.  Der Hippe-Kernel `rkunix` von 1982 enthaelt die MUTOS-Tabellen `maptab`/`cchars`/`wchars` byte-gleich.  Ein Kerneldatum fuer MUTOS ist aus den Disketten nicht
  ableitbar (keine `/unix`-Datei; Dateien ab 1986-01-09, `nroff`-Tabellen 1985).
* **Eigenanteil:** 30-s-`update()`, `setregs`-Kopie, Tickzaehlung in `clock`, `binit` `b_error`, `core` `namei(uchar)`, `setpri` ohne `return`, die Treiber und der Z8001-Teil (`fremd.md` 8.7).
* **Rangfolge:** direkte Ableitung *wahrscheinlich* (gemessen: 26/26 Hippe-Abweichungen, 4/4 Hippe-eigene Merkmale, `malloc`-Stand; angenommen: kein Zwischenglied), gemeinsame Vorlage *vermutet* (nicht zu trennen, die Vorlage muesste Hippe-Text gewesen sein; Indiz: der
  `exece`-Ausgang und Dateistempel), andere Variante *unwahrscheinlich* (kein geladener Baum kommt MUTOS naeher).  Entscheiden wuerden weitere Staende der Linie (Vrije/Calgary, Hippe vor 1986), ein Kerneldatum von MUTOS und Hinweise der Beteiligten.
* **Werkzeuge** (`tools/herkunft/`): `devdiff.py`, `traits.py`, `v7dump.py`, `v7fs_read.py`, `ifdef_resolve.py`, `mapnames.py`, `tables.py`, `tap2files.py`, `ftable.py`; Test `tests/test_herkunft_gegenprobe.py`.
* **Korrektur:** MUTOS hat kein DISKMON (der `io_info`-Text in `bio.c` ist tot); in Abschnitt 13 gilt "in keinem anderen Baum" nur fuer die damaligen 15 Baeume (siehe `fremd.md` 8.5).

## 15. H7: Speicherverwaltung -- V7 mit MMU, MUTOS ohne (2026-10-31)

Ausfuehrlich in `speicher.md` (Inventar je Funktion mit Adresse, Funktionsweise, Schutz, Vorlagenvergleich mit URL/SHA-256, Befehle).  Werkzeug: `tools/herkunft/speicher.py`, `tools/herkunft/v6fs_read.py`.

* **Inventar (36 V7-Funktionen mit Speicherbezug):** 5 unveraendert (`swtch`, `sched`, `xfree`, `malloc`, `mfree`), **16 weggelassen/Stumpf** (`sureg`, `expand`, 8 in `text.c`, `grow`, `sbreak` gekuerzt, `estabur` nur Groessenpruefung, `kstub`, `sysphys`, `mapfree`),
  **15 in V7-Form angepasst** (`newproc`, `swapin`, `xswap`, `swap`, `physio`, `getxfile`, `exece`, `fork`, `core`, `procxmt`, `startup`, `sendsig`, `trap`, `mmread`, `mmwrite`), dazu 3 neue C-Funktionen (`mapalloc`, `mapstart`, `sigret`) und etwa 8 Assemblerroutinen.
  Weggelassen: 1 825 von 21 485 abs-Tokens des V7-`usr/sys/sys` (8,5 %).  **Neu und speicherbezogen:** 0,55 bis 0,86 k C-Tokens (2 bis 3 % des MUTOS-C-Kerns; weit gezaehlt 1,46 k = 5 %) und ~0,43 KB Assembler (1,2 % des Abbilds).
* **Funktionsweise (gemessen am Code und Disassemblat):** ein Prozess = ein ganzes 64-KB-Segment 1..3 der EM256 (Segment 0 Kernel); `p_addr` (Klicknummer, Klick 256 Byte) ist bitgleich das Segmentwort `usegm`.  Adressraumwechsel: `resume` kopiert den u-Bereich
  (1 KB) zwischen `FC00` und dem Slot `EC00 + (usegm << 2)`, die Trap-Rueckkehr schreibt `usegm` in das PC-Segment des Rahmens.  Kernelzugriff auf Benutzerspeicher: kurze FCW-Umschaltung (`C000`), `nofault`; keine Adresspruefung.
  Swap: Dreiteil-Abbild (u-Bereich, Text+Daten, Stapel ab SP), Freigabe des Swapplatzes in `swap` (klaert `slp.md` Punkt 5); Uebertragung ueber die Mailbox mit `mb_seg = b_xmem`.  Hoechstens 3 Prozesse gleichzeitig im Speicher.
* **Schutz:** Prozess gegen Prozess **gemessen** (`doc/system/befund.md`); Prozess gegen Kernel **unbekannt** (nicht versucht); Text-Schreibschutz und Stapelgrenze **nicht vorhanden** (Code).  `backup` (trap, Fall 9) ist `ld r2,#-1; ret` bei 040E,
  `grow` wird nie erreicht; `kernel/karte/adressen.txt` fuehrt `_backup` irrtuemlich bei 3630 (= `sigret`).
* **Vorlage:** keine gefunden.  In 27 durchsuchten Baeumen (47 Dateien mit `estabur`) hat nur MUTOS ein `estabur` ohne Segmentregister.  Neu geladen: LSX, Mini-UNIX (V6 ohne MMU; ein Prozess im Speicher, Wechsel durch Auslagern; Funktionsaehnlichkeit 0,07 bis 0,38),
  V6-auf-286; WEGA (Z8001 mit Z8010) ist bei allen Speicherfunktionen weiter von MUTOS entfernt als V7/Hippe, `estabur` hat dort 4 statt 5 Argumente (MUTOS 5 wie V7), keine WEGA-Bezeichner im Kernel.  V7 und Hippe-Sammlung sind bei diesen Funktionen nicht zu trennen.
  Nicht geladen/nicht gefunden: Zilog-ZEUS, Onyx, Plexus, Coherent fuer Z8000, MUTOS1600.
* **Eigenanteil (Wertung):** (ii) einfache Hilfsrechnung ueber ein vorgegebenes Hardwaremodell (Segmentweiche Modus 2), mit einem (iii)-Kern aus ~0,43 KB Assembler und der Swap-/Slot-Logik; "nur weggelassen" trifft nicht zu, "grosse Eigenentwicklung" auch nicht.
  Die Spanne haengt daran, ob Z8001-Kopf-/Rahmenaenderungen, die Mailbox-DMA-Adressierung und das Hardwaremodell mitgezaehlt werden (`speicher.md` Abschnitt 8).
* **Offen:** Messung des Kernelschutzes im Gast, Stapelueberlauf, reale Z8001-Eigenschaft (nichtsegmentierte Zugriffe tragen das PC-Segment), `adressen.txt` und die 37 abweichenden Woerter von `trap`, `u_x54`-Luecke (14 Byte), weitere Vorlagen (`speicher.md` Abschnitt 10).
