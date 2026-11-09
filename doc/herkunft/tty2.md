# `kernel/c/tty2.c` auf den Text der Hippe-Sammlung gebracht (AP H6c)

Stand 2026-10-31.  Vorlage: `original/hippe-v7/usr/sys/dev/tty.c` (SHA-256 `0271a7fab1fa668b13d0f577013fdcd60c28d08ff1a2a4a2c8d23cff81baf937`) der TUHS-Sammlung
`Research/Torsten_Hippe_v7` ("Hippe-Sammlung" = Name der Sammlung, nicht des Urhebers; `fremd.md` Zuordnungshinweis).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* Alle 20 Funktionen von `tty2.c` tragen jetzt den **Text der Vorlage**: Funktionsnamen, Variablennamen, Makros (`iscntrl`, `isspcl`, `isupper`, `isword`, `max`, `ubyte`), Tabellen `maptab`/`cchars`/`wchars`
  in Originalform (`P`, Zeichenkonstanten) und Originalkommentare.  Schalter wie `conf/m.h`: `DELTAB` an (steht im Quelltext), `MX`, `SGTTY`, `INSTRM` aus; `stty`/`gtty` und die auskommentierte `ttyrend` entfallen.
* Rundlauf (`tools/herkunft/rundlauf.sh`, Gast `cc -O -c`, je Funktion gegen `mutos_1216`): **16 von 20 bytegleich** (vorher mit der Dekompilatform 12 von 20).  Vier Funktionen weichen ab, mit Vorlagentext wie mit der
  alten Dekompilatform (Abschnitt "Abweichungen"); die Vorlagenform ist dabei nie schlechter und bei `ttyinput` (281 statt 348 Woerter) und `ttread` (1 statt 119 Woerter) deutlich besser.
* Fuer **keine** Funktion musste auf die Dekompilatform zurueckgefallen werden; die Rueckfallregel ("bytegleiche bisherige Fassung behalten") griff nicht, weil die bisherige Fassung in denselben vier Funktionen auch nicht bytegleich war.
* Gesamtbau: siehe Abschnitt "Absicherung".

## Funktionstabelle

Klasse: **identisch** = Vorlagentext, Rundlauf bytegleich; **Vorlagentext, nahe** = Vorlagentext unveraendert, Objektcode weicht durch Eigenheit des Kernel-`c2` ab; **eigen** = ohne Gegenstueck (keine in `tty2.c`).
Namensspalte "frueher" = bis 2026-10-31 frei vergebener Dekompilatname (gilt auch fuer die Karte `kernel/karte/karte.txt`).

| Kernel | Vorlage (= jetziger Name) | frueher | Klasse | Rundlauf | Anmerkung |
|---|---|---|---|---|---|
| 6D44 | `ttyopen` | `ttyopen` | identisch | gleich | |
| 6D8C | `ttychars` | `ttinit` | identisch | gleich | Makros `CINTR`..`CKILL`, `tun.` |
| 6DD0 | `ttyclose` | `ttyclose` | identisch | gleich | |
| 6DF0 | `ioctl` | `ioctl` | identisch | gleich | `FIOCLEX`, `EXCLOSE`, `IFMPC` statt Zahlen; `struct a` im Kopf der Funktion |
| 6E7A | `ttioccomm` | `ttioctl` | Vorlagentext, nahe | 181 von 371 Woertern | siehe unten (1) |
| 715C | `wflushtty` | `ttywait` | identisch | gleich | |
| 71A4 | `flushtty` | `ttyflush` | identisch | gleich | |
| 7222 | `ttyinput` | `ttyinput` | Vorlagentext, nahe | 281 von 458 Woertern | siehe unten (2); lokale Variable `t_flags` wie in der Vorlage |
| 75B2 | `ttyretype` | `ttycol` | Vorlagentext, nahe | 1 von 116 Woertern | siehe unten (3); Fassung mit `DELTAB` und Parameter `flag` |
| 769A | `ttyecho` | `ttyecho` | identisch | gleich | vorher 16 von 75 Woertern |
| 772E | `ttywipe` | `ttyrub` | identisch | gleich | vorher 160 von 191 Woertern |
| 78A8 | `zapc` | `unputc` | identisch | gleich | |
| 7948 | `ttybit` | `bitset` | identisch | gleich | |
| 797A | `ttyspcl` | `ttyspec` | identisch | gleich | Schleife ueber `sizeof(struct tc)`; vorher 18 von 51 Woertern (`switch` der Dekompilatform) |
| 79E0 | `ttyblock` | `ttflow` | identisch | gleich | `TTYHOG/2` |
| 7A34 | `ttyoutput` | `ttyoutput` | identisch | gleich | Zeichenkette `"({)}!|^~'`"` jetzt als Literal in der Funktion (vorher eigene Tabelle `ttylcpr`); vorher 187 von 260 Woertern |
| 7C4A | `ttrstrt` | `ttrstrt` | identisch | gleich | |
| 7C62 | `ttstart` | `ttkick` | identisch | gleich | |
| 7C90 | `ttread` | `ttread` | Vorlagentext, nahe | 1 von 139 Woertern | siehe unten (3); V7-Form mit `while(...||...)`; vorher 119 von 140 Woertern (`goto`-Form) |
| 7DA6 | `ttwrite` | `ttwrite` | identisch | gleich | `caddr_t ttwrite`, Schleife `while(u.u_count)` |

Tabellen (Daten 8C9A..8D3A): `maptab` (frueher `ttylcmap`), `cchars` (`ttyctl`), `wchars` (`ttyword`) mit dem Text der Vorlage; `tools/herkunft/tables.py kernel/c/tty2.c original/hippe-v7/usr/sys/dev/tty.c`: alle drei IDENTICAL.
Die Zeichenkette fuer die `LCASE`-Paare (8D52) liegt wie im Kernel hinter den beiden Sprungtabellen (8D3A fuer `ttioccomm`, 8D46 fuer `ttyoutput`).

### Namensabbildung (Dekompilat -> Vorlage), vollstaendig

`ttinit` -> `ttychars`, `ttioctl` -> `ttioccomm`, `ttywait` -> `wflushtty`, `ttyflush` -> `flushtty`, `ttycol` -> `ttyretype`, `ttyrub` -> `ttywipe`, `unputc` -> `zapc`, `bitset` -> `ttybit`,
`ttyspec` -> `ttyspcl`, `ttflow` -> `ttyblock`, `ttkick` -> `ttstart`; Tabellen `ttylcmap`/`ttyctl`/`ttyword` -> `maptab`/`cchars`/`wchars`; `cf_x882` (conf.c) -> `nldisp`.
**Kollision:** der Name `ttstart` war in `tty.c` (Kernel 6274, Mailbox-Start) vergeben, der Vorlagenname gehoert aber dem allgemeinen Start (7C62).  Die Mailbox-Routine heisst jetzt **`tcstart`** (Muster `tc...`
der uebrigen Huellen), siehe `tty.md`.  Namenslaenge: signifikant sind 7 Zeichen (`_` mitgezaehlt 8, `vergleich.py`/`gesamtbau.py` kuerzen auf `[:8]`): `ttyretype` -> `_ttyret`, `ttioccomm` -> `_ttiocco`,
`wflushtty` -> `_wflusht`, `flushtty` -> `_flushtt`, `ttyblock` -> `_ttybloc`; untereinander und gegen alle anderen Kernelnamen eindeutig (`rg` ueber `kernel/`).

## Abweichungen vom Vorlagentext

Nur MUTOS-bedingte Zeilen (im Quelltext erklaert): `CBSIZE 14`/`CROUND 017` (16-Byte-Klistbloecke wie `ureg.c`/`pipe.c`; die Vorlage hat sie in `param.h`), `EXCLOSE 01` (Vorlage: `user.h`), `nldisp` (Variable in `conf.c`
bei 8882), Include-Reihenfolge ohne Pfade.  Die Vorlage fuehrt `#include "../h/reg.h"`; `kernel/h/reg.h` ist ein Platzhalter.  `t_obuf` (MUTOS-Ausgabepuffer der Leitung) heisst jetzt `t_addr` (Vorlagenname, gleiche Stelle +12).

## Funktionen, die nicht bytegleich sind (Wortvergleich gegen `mutos_1216`, `vergleich.py -v`)

1. **`ttioccomm`** (181 von 371 Woertern): bei `TIOCSETA` setzt der Kernel-Compiler den Fehlerzweig als `jr ne,<gemeinsamer Block>` (8 Bit Abstand), unserer als `jp ne` (zwei Worte): ein Wort mehr, alles danach verschoben.
   Die gemeinsame Fehlerstelle (`ldb u.u_error,#14`) liegt an derselben Adresse.  Probeform: `break` statt `return(1)` in `TIOCSETN`/`TIOCSETA` (einzeln und beide) aendert nichts (Versuch 2026-10-31); dieselbe Abweichung hatte die
   Dekompilatform.  *Vermutung:* die Sprungweitenschaetzung des alten `c2` rechnet vor dem Zusammenlegen gleicher Schwaenze.
2. **`ttyinput`** (281 von 458): bei `tp->t_xstate ^= XPAGE` laesst der Kernel das Laden `ld r2,t_xstate` aus (`xor r2,#1` ohne vorheriges Laden -- der Kernel rechnet an dieser Stelle mit dem Inhalt von `r2` von davor), unser `cc` laedt.
   Ein Wort weniger im Kernel, danach alles verschoben; davor und danach stimmt der Text.  Erprobt ohne Wirkung: `goto contin` entfernt, lokale Variable `flg` statt `t_flags`, `register t_flags` ohne `int`, `t_xstate = t_xstate ^ XPAGE`,
   `short` -> `int` in `struct tty`; die alte Dekompilatform brachte es nicht besser (348 Woerter).  Hinweis: die Kernelform ist semantisch auffaellig (die Seitenbremse ^P setzt `t_xstate` auf `r2 ^ 1`, nicht auf `t_xstate ^ 1`);
   *ungeprueft* im Lauf, nur aus dem Disassemblat gelesen.
3. **`ttyretype`** und **`ttread`** (je 1 Wort): der Vergleich `(*p & 0377) == 0377` laeuft im Kernel ueber `r3` (`ld r2,r3` / `cp r3,#255`), bei uns ueber `r2` (`cp r2,#255`); dieselbe Stelle in `ttioccomm` (`TIOCNRD`) zeigt dasselbe.
   Gleichwertig; gleiche Abweichung hatte die Dekompilatform von `ttycol` (1 Wort).  Erprobt ohne Wirkung: Makro `ubyte` durch den Ausdruck ersetzt, `while` statt `for`, `register` ohne `int`.

Diese vier stehen in `doc/herkunft/daten/rundlauf_soll.txt` als `NAHE`; die 16 anderen als `GLEICH`.  Fuer den Gesamtbau bleiben sie Funktionen, die aus dem Original-Abbild uebernommen werden
(`gesamtbau.py` setzt nur bytegleiche C-Funktionen ein).

## Folgeaenderungen

* `kernel/h/tty.h`: Mitglieder und Konstanten nach `usr/include/sys/tty.h` der Sammlung (`t_rawq`, `t_iproc`, `t_addr`, `t_ispeed`/`t_ospeed`, `t_nldly`..`t_vtdly`, `t_length`, `union { struct tc; struct clist t_ctlq; } t_un` mit `#define tun tp->t_un`,
  `t_xstate`, `t_lnum`, `t_char`, `t_chan`, `t_linep`; `struct tc`, `struct ttiocb`, `TTIPRI`/`TTOPRI`, `CERASE`..`CBELL`, `TTHIWAT`/`TTLOWAT`/`TTYHOG`, Modus-, Zustands- und `XPAGE..`-Bits, `TIOC*`); **Layout unveraendert** (`tests/test_header_layout.py`:
  die Pruefung versteht jetzt auch `struct tc;` in einer Union).  Die MUTOS-Zusatzfelder `t_ocnt`, `t_hwp`, `t_hwf` stehen unveraendert hinter `t_line` (+36..+3A).  Typ `short` wie in der Sammlung (gleiche Breite wie `int`; `int` aendert den Objektcode nicht).
* `kernel/h/conf.h`: `struct linesw` mit den V7-Namen `l_open`, `l_close`, `l_read`, `l_write`, `l_ioctl`, `l_rint`, `l_rend`, `l_meta`, `l_start`, `l_modem` (20 Byte wie vorher); `conf.c`: `{ ttyopen, nulldev, ttread, ttwrite, nodev, ttyinput, ttstart, 0, 0, 0 }`.
* `kernel/c/tty.c`: Aufrufe `ttychars`, `ttstart`, `ttioccomm`; eigene Routine `ttstart` -> `tcstart`; `t_obuf` -> `t_addr`, `t_lstate` -> `t_xstate`, Zustandsbits als Namen (`TTSTOP`, `ASLEEP`, `XPAGE1`).
* `kernel/karte/{karte,karte_basis}.txt`, `kernel/karte/adressen.txt` (`_nldisp`), `kernel/asm/ref/{mbx,tty,daten}.s` (Referenz-Disassemblat, Marken umbenannt; assembliert weiter bytegleich), `doc/kernel/kernel_namen.md`,
  `doc/kernel/gesamtbau_adressen.txt`, `tools/herkunft/tables.py` (nimmt beide Tabellennamen), `tests/test_header_layout.py`, `doc/herkunft/daten/rundlauf_soll.txt` (`tcstart`; 20 Zeilen `tty2`).
* **Namensabbildung im Gesamtbau:** `tools/kernel/gesamtbau.py` bildet C-Namen ueber die Marken `/* KERNEL xxxx */` im Quelltext auf Adressen ab (`funktionen_aus_quelle`, Symbol = `"_" + Name`, auf 8 Zeichen gekuerzt) und
  liest zusaetzlich `kernel/karte/karte.txt` (`name ADRESSE _NAME`) fuer die Namen, die der aus dem Original-Abbild uebernommene Rest benutzt.  Die Umbenennung musste daher an **beiden** Stellen stattfinden (Quelltext und Karte),
  sonst haengen die aus dem Abbild disassemblierten Funktionen an den alten Namen.  Eine Alias-Abbildung war nicht noetig.
* `kernel/c/varianten/var7d*.c` (Wegwerf-Probedateien) benutzen die alten Mitgliedsnamen und uebersetzen mit dem neuen `tty.h` nicht mehr; sie sind nicht Teil des Baus (`kernel/c/varianten/README.md`).

## Aenderung an `tools/kernel/gesamtbau.py` (noetig geworden)

Erster Gesamtbau mit dem neuen `tty2.c` (190 von 227 aus C): 12 Byte ungleich bei 8D46..8D51 -- die Sprungtabelle von `ttyoutput`; der Kernel bootete nicht (Boot-Test nach 3 h abgebrochen, **Protokoll
`gb/boot/lauf.log`, kein Prompt**).  Ursache: `ttyoutput` ist erst jetzt bytegleich und damit ein C-Stueck; die Tabelle (Daten, bleibt Assembler `da*`) enthaelt Marken `L7BE8..` im Innern dieses Stuecks, die es im C-Objekt
nicht als Symbole gibt, und `tote_marken` setzte sie auf 0.  Behebung: in Stufe 1 (Layout unveraendert, jede C-Funktion bytegleich an ihrer Adresse) setzt `tote_marken(.., fest=True)` die Marke als Zahl (`WV %7BE8`)
statt 0.  Stufe 2 (verschobenes Layout) nullt weiter.  Ein erster Versuch, die Tabelle mitzubinden (Waisen), brach das Layout (1429 Byte ungleich) und wurde verworfen.

## Absicherung

`python3 -I tools/kernel/gesamtbau.py --arbeit <Scratchpad> --uebersetzen --stufe 1 --boot` (Endstand, 2026-11-01): alle C-Dateien uebersetzen im Gast, **190 von 227** Funktionen aus C (vorher 186; neu bytegleich: `ttyecho`, `ttywipe`, `ttyspcl`, `ttyoutput`), `Gesamt: BYTEGLEICH (0 Byte ungleich)`, 36 352 Byte, Boot bis `#` (68 s) und Arbeitstests ok (`summe = 5050` zweimal, `cc -O -c prf.c` -> 1600 B).  `pytest` ganz: 219 passed, 2 skipped.

## Nachtrag 2026-11-04 (Plan 43 Gruppe C)

`ttioccomm`: unsere `switch` baut die Sprungtabelle wie der Kernel (`div rr2,#6 ; ... ; jp @r1` stimmt bis zur ersten Abweichung); die erste Abweichung ist der Fehlersprung im Fall TIOCSETA: Kernel `jr ne` (Abstand genau -254 Byte, Reichweite von `jr`), Werkzeug `jp ne`.  Die Wahl `jr`/`jp` trifft das Werkzeug (Randfall der Sprungweite), nicht der Quelltext.  Die Annahme in Plan 43 §2 ("unser `cc` baut nie eine Sprungtabelle") war falsch.
