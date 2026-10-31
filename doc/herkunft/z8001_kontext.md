# Z8001-Prozessorkontext, Traps, Systemaufruf und Signale in MUTOS 8000: V7-Struktur auf dem Z8001 (AP H8)

Stand 2026-10-31.  Plan: `doc/plan/42_unix_herkunft.md`.  Einordnung: `uebersicht.md` Abschnitte 12 und 15, `speicher.md` (Speicherteile werden hier **nicht** wiederholt, nur verwiesen), `fremd.md` 8.4 und 8.7.
Alle Zahlen **gemessen** (Befehle in Abschnitt 10), sofern nicht als *angenommen* oder *unbekannt* gekennzeichnet.  In `kernel/` und `original/` wurde nichts veraendert.
Vorbemerkung: Namen von Personen werden nicht als Urheber genannt; "Vorlage" meint einen Quelltext, kein Urteil ueber Urheberschaft.

## 1. Ergebnis in Kuerze

Frage des Projektinhabers: Wie gross ist der Eigenanteil gegenueber V7 und der Hippe-Sammlung, gibt es eine historische Vorlage (WEGA, V7/PDP-11, andere), was ist reines Anpassen an den Z8001 und was eigene Konstruktion?

* **Vorlage fuer die Struktur: UNIX V7, sicher.**  `trapent` (030E) ist eine Z8001-Umschrift von V7 `mch.s` `trap`/`call` (Abschnitt 4.2: `nofault`-Ersatz des gespeicherten PC, Benutzer-SP sichern, `dev` auf den Stapel, `runrun` -> Trap 12 beim Verlassen,
  Benutzer-SP zurueck, `rtt` = `iret`).  `trap()` ist das V7-Gerippe (Abschnitt 3.1), `save`/`resume`, `csv`/`cret`, `fubyte..`, `copyin/out`, `savfp/restfp` tragen die V7-Namen und die V7-Idiome (Rueckgabe 0/1, `nofault`, `tst fpp`).
* **Vorlage fuer die Benutzerseite des Systemaufrufs und der Signale: WEGA, textnah (neu, gemessen).**  Die Bibliothek `libc.a` von MUTOS (`signal.o`, `fork.o`, `read.o`, `cerror.o`) stimmt mit der WEGA-Bibliothek `WEGA/src/lib/libc/sys/*.s` (SCCS-Kopf `2.1  09/12/83`)
  befehlsweise ueberein: `SC #n`, Argumente in `r0..r2`, Ergebnis in `r4`, Fehler = Carry-Flag + Fehlernummer in `r4` an `cerror`, `fork` mit `SC #2; JR uid` und `_par_uid`, `signal` mit 20 `CALR`-Zwischenfunktionen
  und **`SC #0` als Rueckkehr aus dem Signalhandler** (WEGA: `sysiret`).  **Die Idee "sigret ueber Systemaufruf 0" ist also keine MUTOS-Erfindung.**  Der Kernel dazu ist **nicht** WEGA-Text (Funktionsaehnlichkeit `trap` 0,34, `sendsig` 0,07), setzt aber dieselbe Konvention um.
* **Anteil (V7 als Basis, Token-Ebene `abs`, 21 Funktionen aus `trap.c`, `machdep.c`, `sys1.c`, `sig.c`):** 4 701 MUTOS-Tokens; davon 79 % mit V7 gleich, 21 % (986) neu.  Klassen: **unveraendert 6 Funktionen (502 Tokens, 10,7 %)**,
  **angepasst 11 (3 964, 84,3 %)**, **ersetzt 2 (169, 3,6 %)**, **neu 2 (66, 1,4 %)**.  Assembler `low` (0000..0673, 1 652 B = 4,5 % des Abbilds): **angepasst 518 B (31 %), ersetzt 394 B (24 %), neu 740 B (45 %, davon 574 B Tabellen PSA/Vektoren)**.
* **Eigenanteil (Wertung): Spanne "reines Anpassen" bis "kleine eigene Konstruktion".**  Neu geschriebener C-Text im engeren Z8001-Kontext (`trap`, `sendsig`, `sigret`, `setregs`) 297 Tokens = **1,0 %** des C-Kerns (28 933), weit gezaehlt (alle 986) **3,4 %**.
  Eigenstaendig gegenueber V7 *und* WEGA sind nur Einzelzuege: Abbildung der privilegierten Befehle `7C04..06` auf `bpt/iot/emt`, Einzelschritt ueber das NVIE-Bit, Paritaetsdiagnose (Faelle 10/11), Zufallsinterrupt mit `ident`,
  `regloc[16]` mit Rueckgriff auf den `csv`-Rahmen von `trap`, Rahmen mit Port-0x80-Schatten, 4-Wort-Signalrahmen.  Was die Spanne bestimmt: Abschnitt 8.
* **Offene Frage aus `speicher.md` beantwortet:** `backup` (040E) und `_backup 3630` in `adressen.txt` erklaeren die 37 abweichenden Woerter von `trap` **nicht** (Aufrufziele sind im Vergleich Platzhalter).  Die Abweichung kommt aus Fall 15: der Kernel **kehrt dort direkt zurueck** (V7 `return`), der Quelltext hat `goto out`.
  Mit drei kleinen Aenderungen (Fall 15 `return`, Fall 10 `break`, kein `sigbus:`/`return;`) ist `trap` im Gast **bytegleich** (Abschnitt 5.4, Diff `versuche/kontext/trap_bytegleich.diff`).  Korrektur an `trap.md`/`uebersicht.md`: "`goto out` statt V7 `return`" ist falsch (Abschnitt 6).
* **Gastbeobachtung (neu):** Signalzustellung ist jetzt *gemessen*: ein Testprogramm faengt zweimal SIGTERM, die Handler laufen auf dem Benutzerstapel (`FF70`), Variablen bleiben unversehrt, `sendsig` (35AE) und `sigret` (3630) laufen je zweimal (Abschnitt 5.5).

## 2. Methode und Werkzeuge

* Token-Diff je Funktion (V7/Hippe/WEGA gegen MUTOS, Ebene `abs`, `difflib`) und Bestaehnlichkeit gegen 13 Baeume: neues `tools/herkunft/kontext.py` (`inv`, `cmp`), gleiche Maschinerie wie `speicher.py`.  Klassen (Regel, siehe Kopf von `kontext.py`):
  *unveraendert* = hoechstens 2 % neue Tokens und mindestens 95 % der V7-Tokens erhalten; *ersetzt* = weniger als 60 % der V7-Tokens erhalten; *neu* = kein V7-Gegenstueck; sonst *angepasst*.
* Disassemblat: `kernel/asm/ref/low.s` (Handassembler), `kernel/asm/ref/trap.s`; PSA und Tabellen direkt aus dem Abbild `mutos_1216` (`xxd`); Befehlsabdeckung `kernel/abdeckung/funktionen.txt`.
* Gastlaeufe (Abschnitt 5.5, 5.4): `tools/herkunft/rundlauf.sh` (Rundlauf), `versuche/kontext/lauf.sh` (neu, Signaltest), Probekopien im Scratchpad; `disks/` nur ueber Kopien.
* WEGA: Klon `https://github.com/OlliL/P8000`, Commit `626fc77fb083b31392ccafb0d125bbc2c8127d4a`; Auszuege der Benutzerbibliothek: `WEGA/src/lib/libc/sys/`.
* **Grenze:** Die Tokenzahlen betreffen den *rekonstruierten* Quelltext (`kernel/c`), der zu denselben Bytes uebersetzt, aber nicht der Originaltext ist (vgl. `speicher.md` Abschnitt 2).  Der Assembleranteil ist am Disassemblat gemessen, nicht an einem Originalquelltext.

## 3. Inventar

### 3.1 C-Funktionen (V7 als Basis; Spalten: V7-Tokens, gleich, nur V7, nur MUTOS, Aehnlichkeit nach Dice, Klasse)

| MUTOS (Datei, Adresse) | V7-Gegenstueck | V7 | gleich | gestr. | neu | Ae. | Klasse |
|---|---|---|---|---|---|---|---|
| `trap` (trap.c, 087A) | `trap` | 744 | 466 | 278 | 179 | 0,67 | angepasst |
| `nosys` (0B2A), `nullsys` (0B38) | gleichnamig | 8 / 2 | 8 / 2 | 0 | 0 | 1,00 | unveraendert |
| `startup` (machdep.c, 34F6) | `startup` | 168 | 71 | 97 | 43 | 0,50 | ersetzt (V7-Gedanke; Speicher: `speicher.md`) |
| `kstub` (35AC) | `clkstart` | 46 | 2 | 44 | 0 | -- | neu (leer) |
| `sendsig` (35AE) | `sendsig` | 72 | 56 | 16 | 37 | 0,68 | angepasst |
| `sigret` (3630) | -- | -- | -- | -- | 26 (gegen V7 `sendsig`) | 0,56 | neu |
| `exece` (sys1.c, 41AC) | `exece` | 607 | 527 | 80 | 106 | 0,85 | angepasst |
| `getxfile` (44B6) | `getxfile` | 613 | 507 | 106 | 361 | 0,68 | angepasst |
| `setregs` (47E2) | `setregs` | 194 | 175 | 19 | 55 | 0,83 | angepasst |
| `rexit` (48A6), `exit` (48C4), `wait` (49F6), `fork` (4AD4) | gleichnamig | 21 / 291 / 227 / 236 | 19 / 239 / 217 / 218 | 2 / 52 / 10 / 18 | 3 / 40 / 32 / 45 | 0,84..0,91 | angepasst |
| `sbreak` (4BD0) | `sbreak` | 207 | 47 | 160 | 8 | 0,36 | ersetzt (gekuerzt) |
| `psig` (sig.c, 0C7C), `issig` (0BC8), `psignal` (0B6E), `ptrace` (0E42) | gleichnamig | 173 / 71 / 59 / 194 | 171 / 71 / 59 / 188 | 2 / 0 / 0 / 6 | 1 / 0 / 0 / 2 | 0,98..1,00 | unveraendert |
| `procxmt` (0F12), `core` (0D56) | gleichnamig | 524 / 191 | 472 / 162 | 52 / 29 | 14 / 34 | 0,93 / 0,84 | angepasst |

Summen (21 Funktionen, `kontext.py inv`): MUTOS 4 701 Tokens, gleich 3 715 (79 %), neu 986 (21 %).  Mit Hippe-Sammlung als Basis: 82 % gleich, 848 neu (`exit` 0,98, `exece` 0,91, `procxmt` 0,96: die Hippe-Zuege `EXIT`, `B_AGE`-Schleife, `PROC_MAX` sind in MUTOS enthalten, `fremd.md` 8.4).
Mit WEGA als Basis (nur 17 der 21 Funktionen haben ein gleichnamiges Gegenstueck; `trap`, `nosys`, `nullsys`, `startup`, `kstub`, `sbreak` fehlen dort): 69 % gleich.  WEGA liegt bei jeder einzelnen Funktion *weiter* von MUTOS entfernt als V7 oder Hippe (Abschnitt 7.1).

| Klasse | Funktionen | MUTOS-Tokens | Anteil | davon neu |
|---|---|---|---|---|
| unveraendert | 6 | 502 | 10,7 % | 3 |
| angepasst | 11 | 3 964 | 84,3 % | 906 |
| ersetzt | 2 | 169 | 3,6 % | 51 |
| neu | 2 | 66 | 1,4 % | 26 |

Die 21 Funktionen sind 16,2 % der 28 933 C-Tokens des Kerns (`speicher.py total`); die 986 neuen Tokens sind 3,4 %.  Doppelzaehlung mit `speicher.md`: `getxfile` (361), `fork` (45), `startup` (43), `sbreak` (8) und Teile von `core`, `trap` (Fall 9) sind dort schon als Speicheranteil gefuehrt.

Zerlegung von `trap` nach Faellen (Tokens ohne Kommentare, `kernel/c/trap.c`): Kopf 60, `default` 60, Fall 0 11, Fall 1 38, Fall 2 44, Fall 3 16, **Fall 6 (Systemaufruf) 216**, Fall 9 36, Faelle 10/11 71, Fall 15 18, Fall 12 und `out` 110; zusammen 680.

### 3.2 Handassembler `low` (0000..0673, `kernel/asm/ref/low.s`; V7-Gegenstueck: `conf/mch.s`, `conf/l.s` im Baum `original/unix-v7`)

| Routine | Adresse, Laenge | V7-Gegenstueck | Klasse | Inhalt (gemessen am Disassemblat) |
|---|---|---|---|---|
| PSA und Vektortabelle | 0000..023D, 574 B | `l.s` Vektortabelle | neu (durch die CPU vorgegeben) | 7 Eintraege zu 8 B, dann Vektoren je [Info, Stumpf] (Abschnitt 4.1) |
| VI-Stumpfe | 023E..027D, 64 B | `l.s` `jsr r0,call; _clock` | angepasst | 8 Stumpfe `push @r15,#_handler; jp L033A` |
| `start` | 027E..030D, 144 B | `l.s` `start` | neu (Hardware) | PSA-Zeiger, FCW `4000`, Refresh, Zaehler-/Timer-Probe (`ex r0,@r1`), loescht `EC00..FFFF` und `8DC0..D585`, `call _main`, dann **`ldps`** in den ersten Benutzerprozess |
| `trapent` | 030E..03F7, 234 B | `mch.s` `trap`/`call` | angepasst | Abschnitt 4.2 |
| `savfp`, `restfp`, `stst`-Rest | 03F8..040D, 22 B | `mch.s` `_savfp`/`_restfp`/`_stst` | angepasst (Stumpf) | `test D57A` (V7 `tst fpp`), `ret`; kein Gleitkomma-Befehl |
| `backup` | 040E..0413, 6 B | `mch.s` `backup` (PDP-11-Befehlsdecodierer) | ersetzt | `ld r2,#-1; ret` |
| `addupc` | 0414..0473, 96 B | `mch.s` `_addupc` | angepasst | Profilzaehler per `usegm`-Zugriff |
| `splx`, `spl0..7` | 0474..04CB, 88 B | `mch.s` `spl*` | ersetzt | Pegel in Port-0x80-Schatten `8DC2` (Abschnitt 4.2) |
| `fubyte`, `fuword`, `subyte`, `suword` | 04CC..0555, 138 B | `mch.s` `fubyte..suword` | ersetzt | `ex r1,nofault` (V7: `mov $err,nofault`), FCW `C000`, Zugriff `usegm:Offset` |
| `copyin`, `copyout` | 0556..05A1, 76 B | `mch.s` `copyin/out` | ersetzt | `ldir`, `nofault` |
| `copyseg`, `clearseg`, `idle` | 05A2..05F7, 86 B | `mch.s` `copyseg`, `clearseg`, `idle` | ersetzt | Segment:Offset aus Klick; `idle`: `spl0; ei; halt` |
| `csv`, `cret` | 05F8..0613, 28 B | `mch.s` `csv`/`cret` | angepasst | `csv` sichert `r8..r14` (7 Register, 14 B) |
| `save` | 0614..061F, 12 B | `mch.s` `_save` | angepasst | sichert Rueckkehradresse und `r8..r15`, Ergebnis 0 |
| `resume` | 0620..065D, 62 B | `mch.s` `_resume` | angepasst | (Speicheranteil: u-Bereich kopieren, `speicher.md` 5.3), Ergebnis 1 |
| `mapaddr` | 065E..0673, 22 B | -- | neu | Mailbox anstossen |

Summen: angepasst 518 B (VI 64, `trapent` 234, FP 22, `addupc` 96, `csv/cret` 28, `save` 12, `resume` 62), ersetzt 394 B (`backup` 6, `spl` 88, `fu/su` 138, `copyin/out` 76, `copyseg/clearseg/idle` 86), neu 740 B (PSA 574, `start` 144, `mapaddr` 22); zusammen 1 652 B.
Nur Code, ohne die 574 B Tabellen: 1 078 B, angepasst 48 %, ersetzt 37 %, neu 15 % (166 B).  `idle` ist ein Fall von "angepasst" (V7-Idiom), steht der Messung halber bei `copyseg`.

## 4. Rekonstruktion des Ablaufs

### 4.1 PSA, FCW und Vektoren (aus dem Abbild `mutos_1216`, `xxd -s 0 -l 64`)

Das Programmstatus-Feld liegt bei Adresse 0 (Segment 0; `start` setzt `psapseg`/`psapoff` auf 0).  Eintraege zu 8 Byte [reserviert, FCW, PC-Segment, PC-Offset]:

| Offset | Ereignis (Z8001) | FCW im Eintrag | Kennzahl `dev` (= `(FCW>>2) & 0xF`) | `trap`-Fall |
|---|---|---|---|---|
| 00 | Reset | `C000` | -- | `start` (027E) |
| 08 | EPU / nicht implementierter Befehl | `4004` | 1 | 1+USER: Befehl `F009` (Gleitkomma-Probe, wie V7 `SETD`) wird uebersprungen, sonst SIGILL |
| 10 | privilegierter Befehl | `4008` | 2 | 2+USER: `ident` `7C06` -> SIGTRAP, `7C04` -> SIGEMT, `7C05` -> SIGIOT, sonst SIGILL |
| 18 | Systemaufruf (SC) | `4018` | 6 | 6+USER (Abschnitt 4.4) |
| 20 | Segmentfehler | `4024` | 9 | 9+USER (`backup` ist Stumpf: immer SIGSEG, `speicher.md` 5.9) |
| 28 | NMI | `4028` | 10 | 10, 10+USER: "parity during running"; Benutzermodus -> SIGBUS, Systemmodus -> `panic("parity")` |
| 30 | NVI | `400C` | 3 | 3+USER: SIGTRAP, `ps &= ~0x0800` (Einzelschritt, 4.6) |
| 38 | VI, Vektoren ab 3C | `4000` | aus der Tabelle | 0: bus error, 11: Vektor 0 ("parity waiting"), 15: nicht belegter Vektor ("Random interrupt") |

Alle Eintraege haben FCW `40xx`: **Systembetrieb, nichtsegmentiert (Bit 15 = 0), Interrupts gesperrt**; der Handler `trapent` laeuft also im 16-Bit-Modus von Segment 0, der Benutzer ebenfalls (FCW `1000` im Benutzerbetrieb: Bit 14 = 0, Bit 12 = VIE).
Die Kennzahl steckt in den Bits 2..5 des FCW des Eintrags; `trapent` liest sie mit `ldctl r6,fcw; rr r6,#2; and r6,#F`.  Das ist eine MUTOS-eigene Verschluesselung der Ereignisart (V7: PDP-11-Vektor `PS_` mit Trap-Nummer in den Bits 0..4 des PS-Worts, `bic $!37`).
Vektortabelle ab `003C`: Paare [Info, Stumpf]; Info = Pegel (hohes Halbbyte) und Kennzahl/Einheit (niedriges): `007B/023E` (Vektor 0, Pegel 7, `dev` 11), `0060/0246` Takt (`clock`), `0050/025E` Platte (`rkintr`), `0040..43/0256` Drucker (`lpintr`), `0040..43/0266` und `0041..43/026E` Terminal (`tcrint`, `tcxint`), `0050/0276` Diskette (`fdintr`);
alle uebrigen (108 von 128 Vektoren) `000F/024E` -> `trap` mit `dev` 15.  Der Fall 11 ist damit **erreichbar** (Vektor 0), die Faelle 10 (NMI) und 11 sind die beiden Paritaetswege.

### 4.2 Eintritt `trapent` (030E..03F7) und Registerrahmen

Hardware legt auf den Systemstapel (von niedrig nach hoch): `ident`, `FCW`, PC-Segment, PC-Offset (Z8001 legt immer das segmentierte Format mit 4 Worten ab; gemessen am Zugriff `0006(r15)`, `0008..000C(r15)`).  Dann (gemessen, Befehl fuer Befehl):

1. `push #_trap; pushl rr6`: Platz fuer die Handleradresse, `r6/r7` gerettet; `r7 := ident`; `r6 := FCW` des Eintrags.
2. **`test nofault (D578)`**: ist die Fangadresse gesetzt, wird PC-Segment und PC im Rahmen durch `D576:D578` ersetzt und mit `ldps`/`iret` zurueckgekehrt (Ergebnis -1 in `fubyte` & Co.).  = V7 `mch.s` `trap:` `tst nofault; bne 1f ... mov nofault,(sp); rtt`.
3. sonst `dev := (FCW >> 2) & 0xF` (oder fuer Vektoren aus der Tabelle: `dev := Info & 0xF`, Pegel `Info >> 4` ueber `splx`), `dec r15,#12; ldm @r15,r0,#6` (r0..r5 sichern).
4. Benutzermodus (FCW-Bit 14 = 0)?  Dann wird das PC-Segment im Rahmen auf `usegm` (`8DC0`) gesetzt, im Systemmodus auf 0 (Speicheranteil, `speicher.md` 5.3).
5. Der Port-0x80-Schatten `8DC2` (Pegel/Steuerbits der U880-Seite) wird in den `ident`-Platz gelegt; der Benutzer-SP (`ldctl nsp`) wird mit dem `_trap`-Platz getauscht (`ex r4,0010(r15)`), `r4` enthaelt danach die Handleradresse.
6. `splx(Pegel)`, `pushl rr6` (= `dev`, `ident` als Argumente), `call @r4`.
7. Rueckkehr: war es ein Benutzerprozess (FCW-Bit 14 = 0 im Rahmen) und ist `runrun` (`8DC4`) gesetzt, wird `trap(12)` gerufen (V7: `mov $12.,(sp); jsr pc,_trap`, "trap 12 is give up cpu"); dann `ldctl nsp` (Benutzer-SP, auch wenn `sendsig`/`sigret` ihn verstellt haben), **`usegm` ins PC-Segment**, Schatten `8DC2` zurueck (`out 0x80`), `ldm r0,@r15,#8`.
   Ist im geretteten FCW das Bit 11 (NVIE) gesetzt, folgt eine Impulsfolge auf Port 0x80 (Quittierung; Bedeutung *angenommen*, U880-Seite).  Zum Schluss `ldps (875A)` mit FCW `C000` und PC `03F6` (= der folgende `iret`): der `iret` wird damit **segmentiert** ausgefuehrt und holt den 4-Wort-Rahmen.

**Registerrahmen** (gemessen: stimmt mit den Parametern `trap(dev, ident, r0..r7, sp, xx, ps, pcseg, pc)` ueberein; `u.u_ar0 = &r0`):

| Index `ar0[i]` | Byte ab `r0` | Inhalt |
|---|---|---|
| -2, -1 | -4, -2 | `dev`, `ident` (Argumente von `trap`; `ar0[-1]` = Kennung des Ereignisses, bei SC `7Fnn`, bei Vektoren die Vektorkennung) |
| 0..7 | 00..0E | `r0..r7` |
| 8 | 10 | Benutzer-SP (`nsp`, Register `r15` des Benutzers) |
| 9 | 12 | Schatten von Port 0x80 (`xx`; Hardware legte hier `ident` ab) |
| 10 | 14 | FCW des Benutzers (`ps`) |
| 11 | 16 | PC-Segment (auf `usegm` normiert) |
| 12 | 18 | PC-Offset |
| -10..-5 | -20..-10 | `r8..r13`, aus dem **`csv`-Rahmen von `trap`** (`csv` legt `r8..r14` unter die Rueckkehradresse) |
| -4 | -8 | `r14` |

Nur `r0..r7` liegen im Rahmen; `r8..r14` des Benutzers bleiben erhalten, weil jede C-Funktion sie ueber `csv/cret` rettet (kein Kernelcode aendert sie sonst).  Dazu passt die Tabelle `regloc[16]` bei `88CC`
(16 Byte, gemessen: `00 01 02 03 04 05 06 07 F6 F7 F8 F9 FA FB FC 08`): sie bildet die 16 Z8001-Register auf Indizes relativ zu `ar0` ab, einschliesslich der `csv`-Plaetze (-10..-4) und des SP (8).  Sie wird von `procxmt` (16 Eintraege, V7: 9) benutzt, von `setregs` nur zu 8 (V7: 6).
V7 `regloc[9]` ist die Vorlage (Tabelle der Plaetze relativ zu `R0`); der Rueckgriff auf den `csv`-Rahmen ist MUTOS-eigen.

### 4.3 Erster Benutzerprozess und `exec`

* `main` laesst `newproc()` den Prozess 1 erzeugen und kehrt im Kind zurueck (V7: "Return goes to loc. 0 of user init code").  In V7 geschieht das ueber den Trap-Rueckweg; hier nimmt `start` (nach `call _main`) ein vorbereitetes Statuswort (`875E`: `0000 1000 usegm 0000`: FCW `1000`, PC-Segment, PC 0) und fuehrt **`ldps @r4`** aus.  So kommt der erste Benutzerprozess mit FCW `1000` an Adresse 0 (gemessen am Disassemblat, `start`).
* Spaetere FCW-Werte erben alle Prozesse durch `fork` (der Rahmen liegt im kopierten u-Bereich; `fork` erhoeht nur `ar0[12]` um 2, `sys1.c` 568, V7 `R7 += NBPW`, passend zum Aufruf `SC #2; JR` der Bibliothek).
* `setregs` (47E2): loescht `ar0[regloc[0..7]]` (also `r0..r7`; `r8..r14` und SP bleiben), `r_val1/2`, setzt `ar0[12]` aus dem Kopf (`u_ex[5]` bzw. `u_ex[8]` fuer 40-Byte-Kopf), loescht `u_fparea` (0x90 Byte), schliesst `close-on-exec`-Dateien und kopiert den Namen `u_exname -> u_dbuf`.
  `exece` setzt `ar0[8] = ap` (SP, `sys1.c` 135), Aufbau der Argumente am Segmentende: `speicher.md` 5.7.
* `exit`/`wait`/`fork`: V7-Text mit `proctop`, einer Schleife statt zwei (Hippe `EXIT`), kein Z8001-spezifischer Zug ausser `ar0[12]`; Einzelheiten `sys1.md`, Speicher `speicher.md`.

### 4.4 Systemaufruf (`SC #n`, Fall 6+USER, `trap.c` 115..150)

Gemessen am Quelltext, an `trap.s` und an den Bibliotheksstumpfen:

* **Aufruf (Benutzerseite, `libc.a`):** `SC #n` (Befehlswort `7Fnn`).  Argumente in `r0, r1, r2, r3` (nach `ldm r0,4(r14),#3` aus dem Aufrufrahmen), Ergebnis in `r4` (`read.o`: `sc #3; jp c,cerror; ld r2,r4; ret`).
* **Kernel:** `ident` = `7Fnn`; `sysent[ident & 077]` (64 Eintraege zu 4 B bei `8B58`; `sy_nrarg` ist in allen Eintraegen 0, V7: Zahl der Registerargumente).  `u_error = 0`, `ps &= ~EBIT` (`EBIT` = `0x80` = Carry-Flag im FCW; V7 `0200` = C-Bit des PS).
  **Argumente:** `*(struct blk4 *)argp = *rp`, d. h. **vier Worte `ar0[0..3]` werden in `u_arg[0..3]` kopiert** (V7: `for i < sy_nrarg: u_arg[i] = u_ar0[regloc[i]]`, danach `fetch` aus dem Befehlsstrom; hier gibt es keinen Befehlsstrom, `narg` wird nicht ausgewertet).  `u_dirp = u_arg[0]`, `r_val1 = ar0[4]`, `r_val2 = ar0[5]` (V7: `R0`, `R1`), `u_ap = u_arg`.
* Aufruf mit `save(u_qsav)` fuer `EINTR` wie V7.  **Rueckgabe:** bei Fehler `ps |= EBIT`, `ar0[4] = u_error`, `ar0[5] = u_deverr`; sonst `ar0[4] = r_val1`, `ar0[5] = r_val2`.  Danach `goto out`.
  (WEGA: `RETRLO 4`, `RETRHI 5`, `EBIT 0x0080`, `SCINS 0x7F00` in `head/sys/state.h` -- **dieselben Werte**; Abschnitt 7.2.)
* **Eintrag 0:** V7 benutzt `sysent[0]` fuer den *indirekten* Systemaufruf.  MUTOS: `callp == sysent` -> `sigret(); goto out;` (nicht aus der Tabelle: `sysent[0]` ist `nullsys` (`0B38`), der Aufruf steht fest in `trap`, `call L3630`).  WEGA traegt `sysiret` dagegen **in die Tabelle** ein (`0, sysiret, /* 0 = indir */`).
* `fork`: Kind kehrt am `JR` nach `SC` zurueck (liest `r4` als Eltern-Benutzerkennung nach `_par_uid`), Eltern bei `PC + 2`.  `ptrace`: Reihenfolge `req, pid, addr, data` wie die Nicht-PDP-11-Systeme (`sig.md`).

### 4.5 Signalzustellung und Rueckweg

1. `psig` (V7-Text) ruft `sendsig(p, n)` am Ende von `trap` (Marke `out`).  `sendsig` (35AE): `sp = ar0[8] - 8; grow(sp)` (Stumpf); legt auf den **Benutzerstapel** vier Worte ab -- `sp+6 := ar0[12]` (PC), `sp+4 := ar0[11]` (PC-Segment), `sp+2 := ar0[10]` (FCW), `sp+0 := ar0[-1]` (`ident`) --, setzt `ar0[8] = sp` und `ar0[12] = p`.
   Das ist ein **Z8001-Interruptrahmen im Benutzerstapel** (`ident, FCW, PC-Segment, PC`); die PDP-11-Vorlage legt zwei Worte (PC, PS) ab (V7 `sendsig`: 56 von 72 Tokens erhalten, 37 neu).
2. `p` ist die Adresse, die der Benutzer mit `signal` eintrug, in der Praxis die **Zwischenfunktion der Bibliothek** (Tabelle `tvect` in `signal.o`, 20 Einsprunge `CALR asyncex`).  Diese rettet `r0..r14` (`sub r15,#1E; ldm @r15,r0,#15`), leitet die Signalnummer aus der Rueckkehradresse des `CALR` ab (`r7 - 0x40`, durch 2), ruft den Benutzerhandler (`call @r2`), holt die Register zurueck, entfernt Register und Einsprungadresse (`add r15,#20`) und fuehrt **`SC #0`** aus (gemessen, Disassemblat von `signal.o`).
3. `SC #0`: `trap` Fall 6 -> `sigret()` (3630): `sp = ar0[8]; ar0[12] = fuword(sp+6); ar0[11] = fuword(sp+4); ar0[10] = fuword(sp+2); ar0[8] = sp + 8`.  Die `ident`-Zelle wird nur uebersprungen (Symmetrie zum Interruptrahmen).
   Nach `out:` fuehrt `trapent` mit dem wiederhergestellten FCW/PC und dem Benutzer-SP zurueck an die unterbrochene Stelle.
4. **Warum Systemaufruf 0?**  Der Z8001 hat keinen Befehl "Rueckkehr aus Benutzerhandler mit Wiederherstellung von FCW und PC" fuer den Benutzerbetrieb (`iret` ist privilegiert); die Rueckkehr muss also in den Kernel (SC).  Die Nummer 0 war durch V7 frei (indirekter Aufruf, hier nicht gebraucht) -- und WEGA verfaehrt genauso (Abschnitt 7.2).
5. Fehlerfaelle (kein gueltiger Stapel) werden nicht abgefangen: `suword` liefert -1 (`nofault`), `sendsig` prueft es nicht (WEGA setzt `u_error = EFAULT`).

### 4.6 Weitere Faelle von `trap`

* **Zufallsinterrupt (Fall 15, `dev` 15 = nicht belegter Vektor):** Meldung `Random interrupt (ident = %x) ignored`, danach **`return` (nicht `goto out`)** -- am Disassemblat: `push r13 (ident); push #L89C3; call _printf; inc r15,#4; jr L0B26` mit `L0B26: jp cret`.  V7 hat dieselbe Rueckkehr ohne Signalpruefung; neu ist nur `ident` in der Meldung (18 Tokens).
* **Paritaet (Fall 10 = NMI, 11 = Vektor 0):** Fall 10: `printf("parity during running - segment = %x offset = %x")` mit PC-Segment und PC; Benutzermodus -> SIGBUS (`jp ne,L0926`, dort `i = 10`), sonst `panic`.  Fall 11: `i = ident >> 14; t = (ident << 2) & 0xF600`, Meldung "parity during waiting ... + ??", dann `out`.
  Die Auswertung von `ident` (Bits 14/15, Maske `F600`) setzt voraus, dass die Paritaetslogik der Karte die Fehleradresse in die Vektorkennung legt (*angenommen*, Schaltplan nicht ausgewertet); V7 gibt die Paritaetsregister der 11/70 aus (`mem_error`).
* **`default`:** `nested`-Sperre (`88E0`, Endlosschleife beim zweiten Eintritt), Ausgabe `seg`, `aps`, `pc`, `ps`, `trap type`, `ident`, dann `panic("trap")`.  V7: `ka6`, `aps`, `trap type`, `panic`.
* **Fall 2 und 3, Einzelschritt:** `ptrace` schreibt als Haltepunktbefehl `7C06` (`adb`: das Wort `0DF9 7C06` = `push #7C06` steht zweimal im Programm `adb`, gemessen) und `procxmt` Fall 9 setzt `ar0[10] |= 0x800` (NVIE); der folgende NVI-Trap (Kennzahl 3) setzt SIGTRAP und loescht das Bit.  Ob die Hardware nach jedem Befehl einen NVI liefert, ist *angenommen* (Emulator/Karte nicht geprueft).
  Die Wahl privilegierter Befehle (`7C04..06`, im Benutzerbetrieb sicher Trap 2) fuer `bpt/iot/emt` ist MUTOS-eigen: WEGA behandelt den privilegierten Befehl nur als SIGILL.

## 5. Belege am Lauf

### 5.1 Befehlsabdeckung (`kernel/abdeckung/funktionen.txt`, ohne Signalzustellung)

`trapent` 59 von 78 Befehlen, `trap` 96 von 147, `startup` 56 von 56, `setregs` 62 von 66, `sendsig` und `sigret` **0 von 46 bzw. 43** (nicht gelaufen).  Das war die Luecke, die der Test in 5.5 schliesst.

### 5.2 Rundlauf (Wiederholung 2026-10-31, `tools/herkunft/rundlauf.sh`, 85 s)

`trap` 37 von 343 Woertern abweichend (wie vorher), `nosys`, `nullsys` gleich; `sendsig`, `sigret`, `kstub` gleich, `startup` 45 von 90; `setregs`, `rexit`, `exit`, `wait`, `fork`, `sbreak` gleich, `exece` 1/389, `getxfile` 177/401.  Ergebnis wie `trap.md`, `machdep.md`, `sys1.md`.

### 5.3 Die 37 Woerter von `trap` (offene Frage aus `speicher.md` 5.9 und 10 Punkt 4)

Messung `python3 -I tools/kernel/vergleich.py KERNEL OBJEKT trap.c -v` und Wortdiff `Kernel` gegen `Objekt`:

* Die Aufrufziele (`call _printf`, `call L040E` = `backup`, `call L3630` = `sigret`, `call L0E38` = `grow`) sind **Relokationsstellen** und im Vergleich Platzhalter (`~`, 90 von 343 Woertern).  **`backup` bei 040E oder `_backup 3630` in `adressen.txt` kann die Abweichung daher nicht erklaeren**; `gesamtbau.py` bildet `_backup` ohnehin auf `_sigret` ab (Zeile 925), das betrifft nur den Linkvorgang, nicht den Vergleich.
* Die wirklichen Abweichungen (`!`) beginnen bei `0A32`: alle Sprungverschiebungen zum Marke `out` sind im Kernel um **ein Wort** laenger.  Ursache: in Fall 15 hat der Kernel `printf; inc r15,#4; jr L0B26` (Sprung auf das letzte `jp cret`), das Objekt nur `printf; jr out`
  (der Uebersetzer spart den `inc r15,#4`, wenn danach `goto out` folgt).  Die Kernelform ist also **`return`** (V7), nicht `goto out`.
* Probe 1 (Scratchpad, `trapA`: Fall 15 mit `return`): weiter 37 von 344 Woertern; die `inc`-Zeile stimmt jetzt, das Objekt setzt aber ein eigenes `jp cret` (2 Worte) an die Stelle, der Kernel springt kurz (`jr`) auf das **letzte** `jp cret` der Funktion; alle Folgeverschiebungen sind Folge dieses einen Worts.
  Probe 2 (`trapD`/`trapE`): Abschnitt 5.4 -- mit `return` in Fall 15, `break` in Fall 10 statt `sigbus:` und ohne abschliessendes `return;` ist `trap` **bytegleich**.
* Damit ist das Layout "Faelle 10/11/15" aus `c_rueckbau.md` K7c geklaert: **Quelltextfehler der Rekonstruktion** (Rueckkehrform von Fall 15 und die Marke `sigbus`), kein `c2`-Effekt und kein Adressproblem von `backup`.

### 5.4 Ergebnis von Probe 2: `trap` wird bytegleich

Probe 2 (`trapD`, Gastlauf `gast_lauf.sh` mit `NUR_O=1`, Vergleich mit `vergleich.py`): **`087A trapD GLEICH 688 B`**, 0 abweichende Woerter.  Die Aenderung gegenueber `kernel/c/trap.c` sind drei Stellen
(Vorschlag als Diff in `versuche/kontext/trap_bytegleich.diff`, `kernel/c/trap.c` selbst blieb unveraendert):

1. Fall 15: `return;` statt `goto out;` (V7-Form).
2. Fall 10: `if (dev & USER) { i = SIGBUS; break; }` statt `goto sigbus;`.
3. Die Marke `sigbus:` samt `return;` am Funktionsende entfaellt (V7 hat kein abschliessendes `return;`); `psignal`/`out` werden dann ueber das gemeinsame Ende erreicht.

Die Gegenprobe `trapE` (nur 2. und 3., Fall 15 weiter `goto out`) bleibt bei 37 von 343 Woertern: **die Rueckkehrform von Fall 15 ist die entscheidende Abweichung**, die Marke `sigbus` der Rekonstruktion die zweite.
Mit Probe 1 (nur 1.) ergaben sich weiter 37 Woerter: erst alle drei Aenderungen zusammen erzeugen das kurze `jr` auf das gemeinsame `jp cret`.
Damit ist die bei `trap.md` und `c_rueckbau.md` K7c "nahe (37/343)" gefuehrte Funktion **geloest**; nach der Aenderung waeren 3 von 3 Funktionen von `trap.c` bytegleich.  Der gesamte Kernel wurde mit dem Vorschlag **nicht** neu gebaut (`gesamtbau.py`), nur die Funktion verglichen.

### 5.5 Gastbeobachtung Signalzustellung (neu, `versuche/kontext/lauf.sh`, Lauf 2026-10-31)

Testprogramm `versuche/kontext/sigtest.c`: faengt SIGTERM (15), sendet sich zweimal `kill(getpid(), 15)`, haelt `n`, `cnt`, Adresse einer Handler-Variablen, und besitzt Variablen `i`, `j` in Registern/Stapel.  Ablauf: im Gast uebersetzen (`cc`), mit `cover on` ausfuehren.

* Ausgabe: `AFTER n=15 cnt=2 i=12345 j=-11215 loc=FF70` und `SIGDONE`.  (`54321` als 16-Bit-Zahl ist `-11215`; beide Variablen unversehrt.)  Der Handler hat also zweimal gelaufen, seine lokale Variable liegt bei `FF70`, **auf dem Benutzerstapel** (Segment des Prozesses), und der unterbrochene Code ist ohne Registerverlust weitergelaufen.
* Abdeckung (U8001, Kernel): `sendsig` (35AE) 2 mal betreten, `sigret` (3630) 2 mal betreten, alle 43 Befehle von `sigret`; `grow` (0E38, Stumpf) 2 mal gerufen.  Damit ist die Kette `psig -> sendsig -> Bibliothek-Stub -> SC #0 -> trap Fall 6 -> sigret -> iret` **gemessen**, einschliesslich der Annahme "`ar0[-1]` = `ident` wird nur uebersprungen".
* Die Abdeckung der Kernelbefehle in diesem Lauf (4 100 verschiedene Adressen, Segment 0) liegt in `.../scratchpad/h8/sig/cov.txt`.

## 6. Folgen fuer die vorhandene Dokumentation (nicht von diesem AP geaendert)

* `trap.md` Abschnitt "Fremdzuege" Punkt 2 und `uebersicht.md` Abschnitt 12 Fremdzug 1: "`goto out` statt V7 `return`" ist falsch; der Kernel kehrt in Fall 15 mit `return` zurueck (V7-Verhalten).  Fremd bleibt nur `ident` in der Meldung.
* `trap.md`/`uebersicht.md`: "37 von 343 Woertern, bekannt" entfaellt, wenn `versuche/kontext/trap_bytegleich.diff` in `kernel/c/trap.c` uebernommen wird (Rundlauf danach 3 von 3; `rundlauf_soll.txt`: `trap trap GLEICH`).
* `speicher.md` 5.9 und 10 Punkt 4: die Frage "erklaert `_backup 3630` die 37 Woerter" ist mit **nein** beantwortet; `adressen.txt` (`_backup 3630` statt 040E) bleibt trotzdem ein Namensfehler der Karte (`sigret` ist 3630).

## 7. Vorlagenvergleich

### 7.1 Funktionsaehnlichkeit (`kontext.py cmp`, Ebene `abs`; `( )` = bester Treffer hat anderen Namen)

| MUTOS | V7 | Hippe | Nijmegen | SysIII PDP | SysIII VAX | WEGA | 32V | Interdata | UNSW 92 | 2.9BSD | 2.11BSD | Ultrix-11 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `trap` | 0,48 | 0,50 | 0,49 | 0,32 | 0,25(nosys) | 0,34(getuid) | 0,50(nosys) | 0,50(nosys) | 0,46 | 0,34(getuid) | 0,22 | 0,50 |
| `startup` | 0,23 | 0,25 | 0,25 | 0,21 | 0,07 | 0,12 | 0,07 | 0,10 | 0,18 | 0,13 | 0,07 | 0,13 |
| `sendsig` | 0,55 | 0,55 | 0,55 | 0,49 | 0,07 | 0,07 | 0,09 | 0,28 | 0,55 | 0,34 | 0,06 | 0,55 |
| `sigret` | 0,14 | 0,14 | 0,14 | 0,14 | 0,10 | 0,08 | 0,10 | 0,17 | 0,14 | 0,11 | 0,08 | 0,14 |
| `setregs` | 0,61 | 0,64 | 0,64 | 0,57 | 0,47 | 0,37 | 0,53 | 0,23 | 0,46 | 0,48 | 0,08 | 0,27 |
| `exece` | 0,65 | 0,68 | 0,68 | 0,48 | 0,56 | 0,50 | 0,63 | 0,27 | 0,57 | 0,51 | 0,17 | 0,50 |
| `exit` | 0,80 | 0,92 | 0,92 | 0,66 | 0,57 | 0,73 | 0,68 | 0,27 | 0,68 | 0,51 | 0,04 | 0,36 |
| `fork` | 0,78 | 0,81 | 0,81 | 0,51 | 0,50 | 0,61 | 0,76 | 0,38 | 0,60 | 0,50 | 0,10 | 0,50 |
| `procxmt` | 0,81 | 0,83 | 0,83 | 0,76 | 0,72 | 0,52 | 0,71 | 0,54 | 0,81 | 0,73 | 0,13 | 0,63 |
| `core` | 0,77 | 0,77 | 0,77 | 0,60 | 0,56 | 0,39 | 0,73 | 0,74 | 0,52 | 0,59 | 0,12 | 0,59 |

Vollstaendige Tabelle (21 Funktionen, 13 Baeume): `kontext.py cmp` (Aufruf in Abschnitt 10).  Lesehilfe: **Kein Baum steht bei irgendeiner der z8001-nahen Funktionen (`trap`, `sendsig`, `sigret`, `startup`) deutlich ueber V7/Hippe.**  `trap` (0,48 V7, 0,50 Hippe) ist der V7-Rahmen; `sigret` 0,14 gegen `sendsig` ist Rauschen.
WEGA liegt bei `trap` (kein gleichnamiges Gegenstueck: dort `evntentry`, `syscall`, `segvio`, `privinstr`, `nmint` je ein Handler pro PSA-Eintrag), `sendsig` 0,07, `setregs` 0,37, `core` 0,39 am weitesten weg; die Kernel-Struktur von WEGA ist eine andere (Abschnitt 7.2).

### 7.2 WEGA: was gemeinsam ist und was nicht (Befund mit Belegen)

**Kernel** (`WEGA/src/uts`): eigener Entwurf (`struct state` mit 15 Registern, `s_sp`, `s_eventid`, `s_ps`, `s_pcseg`, `s_pc`; ein Eintrittsstumpf je PSA-Eintrag in `event.s`; `evntentry` merkt `u_state`; `scfunc` waehlt die Funktion aus `eventid & 0xFF`; Segment-MMU).  Gemeinsam mit MUTOS sind **nur** Vorgaben des Prozessors oder der Schnittstelle:

* Reihenfolge am Rahmenende `sp, eventid, ps, pcseg, pc` (MUTOS: `sp, xx, ps, pcseg, pc` -- gleiche Plaetze, anderer Inhalt in `xx`);
* PSA-Reihenfolge: reserviert, EPU-Befehl, privilegierter Befehl, Systemaufruf, Segment, NMI, NVI, VI (`event.s`) -- durch die CPU vorgegeben;
* `EBIT = 0x80`, `RETRLO = 4`, `RETRHI = 5`, `SCINS = 0x7F00`, Argumente aus dem Registerrahmen, Ergebnis `r4/r5` (`head/sys/state.h`, `uts/sys/trap.c` `syscall`) -- gleich MUTOS `0200`, `ar0[4]`, `ar0[5]`, `7Fnn`;
* **Systemaufruf 0 = Rueckkehr aus dem Signalhandler** (`sysiret`, `uts/sys/machdep.c` mit Kommentar "System Call 0 / Exit von User Signal Service Routine (reti von simuliertem Interrupt)"; `sysent.c`: `0, sysiret, /* 0 = indir */`);
  `sendsig` legt wie MUTOS Zustand auf den Benutzerstapel ("PC und FCW (ps) werden im Userstack gerettet (analog Interrupt)"), aber drei Worte (`pcseg, pc, ps`) und mit `EFAULT`-Pruefung;
* `nofault` als Fangadresse in `fuword`/`copyin` (V7-Idiom), `_save`/`_resume` mit Ergebnis 0/1 (V7-Idiom).
Text-Aehnlichkeit bei diesen Stellen: `sendsig` 0,07, `trap` 0,34 -- die Gemeinsamkeit liegt in der **Konvention**, nicht im Code.

**Benutzerbibliothek** (`WEGA/src/lib/libc/sys/*.s`, nichtsegmentierte Fassung, SCCS-Kopf `2.1  09/12/83 ... 87wega3.2`) gegen `libc.a` der MUTOS-Wurzel (`disks/original/a5120_mutos8000_best_usr.zip`, `dateien/lib/libc.a`):

| Stelle | WEGA `signal.s` | MUTOS `signal.o` (Disassemblat) |
|---|---|---|
| Fehlerzahl `22` fuer `cerror` | `ld r2,#22` | `ld r4,#0x16` (Fehlerregister `r4`) |
| Signalnummer pruefen | `cp r0,#%0014; jp ge,cerror` | `cp r0,#0x14; jp ge,cerror` |
| alte/neue Funktion | `sla r3,#1; ld r2,L1(r3); ld L1(r3),r1` | `sla r3,#1; ld r2,8E(r3); ld 8E(r3),r1` |
| Sonderwerte 0/1 | `rr r1,#1; rl r1,#1; jr ule,L2; lda r1,L5(r3)` | `rr r1,#1; rl r1,#1; jr ule,2E; lda r1,3E(r3)` |
| Systemaufruf | `sc #48` | `sc #0x30` |
| Fehler/Ergebnis | `bit r4,#0; jr z,L4; ld r2,r4; L4: ret nc; jp cerror` | `bit r4,#0; jr z,3A; ld r2,r4; 3A: pop; ret` mit vorherigem `jp c,cerror` |
| 20 Zwischenfunktionen | 20 x `calr L7` | 20 x `calr 66` |
| Zwischenfunktion | `sub r15,#30; ldm @r15,r0,#15; ld r7,30(r15); sub r7,#L6; ld r2,L1(r7); srl r7,#1; call @r2; ldm r0,@r15,#15; add r15,#32; sc #0` | `sub r15,#1E; ldm @r15,r0,#15; ld r7,1E(r15); sub r7,#40; ld r2,8E(r7); srl r7,#1; push r7; call @r2; inc r15,#2; ldm r0,@r15,#15; add r15,#20; sc #0` |

Alle zehn Befehle der WEGA-Zwischenfunktion stehen in gleicher Reihenfolge in MUTOS; MUTOS fuegt nur `push r7`/`inc r15,#2` hinzu (Argument auf dem Stapel statt in `r7`: Aufrufkonvention des MUTOS-`cc`).  Dieselbe Entsprechung gilt fuer `fork` (`sc #2; jr uid; ... uid: ld _par_uid,r4`, WEGA und MUTOS; V7 `fork.s` hat `_par_uid` ebenfalls, in `original/unix-v7/usr/src/libc/sys/fork.s`),
`read` (`sc #3` mit `r0..r2`, `ret nc / jp cerror`) und `cerror` (`ld _errno,r4; ld r2,#-1`).  Von den 55 `libc`-Mitgliedern mit `SC` haben **alle 48 echten Aufrufstumpfe** ein gleichnamiges Quellstueck in `WEGA/src/lib/libc/sys/` (die uebrigen 7 Treffer sind zufaellige `7F`-Bytes); insgesamt haben 126 von 140 Mitgliedern von `libc.a` einen gleichnamigen WEGA-Quellnamen (Namensgleichheit bei Standardnamen, schwaches Indiz).
Die Zwischenfunktion mit `CALR`-Tabelle und `SC #0` gibt es in V7/PDP-11 nicht (dort kehrt der Handler mit `rti` zurueck).  Die WEGA-Datei ist alter (SCCS 1983) als jede MUTOS-Datei, die bekannt ist (Disketten ab 1986); *ob* MUTOS von WEGA oder beide von einer gemeinsamen Z8000-Vorlage stammen (etwa Zilog-UNIX, ZEUS: **nicht gefunden**), ist aus den Dateien **nicht entscheidbar**.

Folgerung (gemessen/angenommen):
* Gemessen: die Benutzer-ABI von MUTOS (SC-Nummer im Befehl, Argumente `r0..`, Ergebnis `r4`, Carry = Fehler, Rueckkehr aus Signalen ueber `SC #0` mit Stub und 20er-Tabelle) ist die der WEGA-Bibliothek, bis in die Befehle.
* Gemessen: der MUTOS-Kernel ist keine WEGA-Ableitung (kein Text, andere Struktur), erfuellt aber diese ABI.
* *Angenommen*: der Kernelentwurf musste diese ABI bedienen, weil Compiler/Bibliothek aus dieser Familie kamen; die Reihenfolge der Entstehung ist unbekannt.

### 7.3 V7 und PDP-11-Konvention (`original/unix-v7/usr/sys/conf/mch.s`, `sys/trap.c`)

* `trapent` = `mch.s` `trap:`/`call:` (Abschnitt 4.2); `trap()` = V7 `trap()` (46 % Datei, 48 % bzw. 67 % Funktion); `save`/`resume`, `csv/cret` (V7: `csv`, `cret`), `nofault`, `fpp`-Test, `regloc`.
* Fehlerkonvention V7: `ps |= EBIT` und Fehlernummer im Ergebnisregister; MUTOS: `FCW |= 0x80`, Fehlernummer in `ar0[4]`.  Dazu die V7-Bibliothek (`jmp cerror` bei Carry) -- gleiche Konvention auf anderem Prozessor.
* System III PDP-11 `trap.c` ist V7 mit Zusaetzen; kein SysIII-Zug in MUTOS (`trap.md`).  32V/VAX (`trap` 0,50 gegen `nosys`): VAX-Trap mit `pcb`, `chmk`; ohne Bezug.  Interdata-V6, 2.9BSD, 2.11BSD, Ultrix-11: V7-Linie mit PDP-11; nichts naeher als V7/Hippe.
* Hippe-Sammlung: bei `trap`, `sendsig`, `sigret`, `startup` nicht von V7 zu trennen; bei `exit`, `exece`, `procxmt` naeher (die bekannten Hippe-Zuege, `fremd.md` 8.4).

### 7.4 Quellen und Pruefsummen (neu in diesem AP)

| Kuerzel | Datei | SHA-256 |
|---|---|---|
| WEGA `signal.s` (nichtsegmentiert) | `WEGA/src/lib/libc/sys/signal.s` | `4f712883d9d62b5fdd5ea565f0e67d8b8c15463de89418a937d557e10e047e6e` |
| WEGA `fork.s` | `WEGA/src/lib/libc/sys/fork.s` | `5a0d336ea7d10bd660c0dbcf70925b882f1fdf83e80c5bc30d188e1983c56a54` |
| WEGA `read.s` | `WEGA/src/lib/libc/sys/read.s` | `a62ba65a18b140c6b6e64c682a698f6aa8a8c845860b5f259befb4f5c21a84de` |
| WEGA `trap.c` | `WEGA/src/uts/sys/trap.c` | `819f2c87b8e0c05c244bce2ce759231f57ff76916f034436bc95358b79ec635a` |
| WEGA `machdep.c` | `WEGA/src/uts/sys/machdep.c` | `23e645bb14cef8f30b19d2c284d8223814e293e7263abb4a207003823c0f552f` |
| WEGA `sysent.c` | `WEGA/src/uts/sys/sysent.c` | `fdbe48fce95ca5b662c29e7e240a34702402f113072b08927acbe0ee1021b700` |
| WEGA `event.s` | `WEGA/src/uts/conf/event.s` | `e40da87fb39bf397b99654749e35c1b429b8d28afbdeef61c696468d1473697c` |
| WEGA `state.h` | `WEGA/src/head/sys/state.h` | `161c44da69ca72df90aa41a83a8d3704dd24c66b336f288acfec0ca7725e92e0` |
| WEGA `signal.s` (lcc, segmentiert) | `WEGA/contrib/lcc/lib/libc/u8k/sys/signal.s` | `0b1172cf0de80a8069a74fdc68fb474eb1a10ecf1b9a69921fc4fa62525c3219` |
| MUTOS `libc.a` | `disks/original/a5120_mutos8000_best_usr.zip`, `dateien/lib/libc.a` | `59a489a5c84e5b8d13461d7e7d4016fded040453ddd05330633d93c5bcbd9cfd` |
| MUTOS best_usr (Archiv) | `disks/original/a5120_mutos8000_best_usr.zip` | `cea18cc3ec4fa25a178956b735d3aadee6670c3efb95aa879fe15b65f64275b4` |

Die uebrigen Baeume (Hippe, Nijmegen, V7, SysIII, 32V, Interdata, UNSW 92, 2.9/2.11BSD, Ultrix-11) mit URL und SHA-256: `fremd.md` Abschnitt 2 und 8.2b.

## 8. Bewertung des Eigenanteils

Massstab wie `speicher.md` Abschnitt 8: (i) reines Weglassen, (ii) Anpassung / Ersatz durch eine Standardloesung des Prozessors oder der Familie, (iii) eigenstaendige Konstruktion.

| Teil | Umfang | Stufe | Begruendung |
|---|---|---|---|
| `nosys`, `nullsys`, `psig`, `issig`, `psignal`, `ptrace` | 6 Fkt., 502 Tokens | (i)/(ii) | V7-Text (Namen der Signale, Argumentreihenfolge von `ptrace` wie Nicht-PDP-11-Systeme) |
| `trap` Rahmen und `out`, `procxmt`, `core`, `exit`, `wait`, `fork`, `exece`, `setregs`, `sendsig` | 9 Fkt., ~3 000 Tokens, ~500 neu | (ii) | V7-Gerippe; Registerindizes (`ar0[8]`, `[10]`, `[12]`), 16 Register, `proctop`, Hippe-Zuege |
| Fall 6 Systemaufruf (Argumente `blk4`, `r4/r5`, Carry, `sigret` bei Eintrag 0) | 216 Tokens | (ii) | folgt aus der Z8001-Konvention (SC-Befehl ohne Befehlsstrom); gleiche Konvention in WEGA; V7-`regloc`-Weg verallgemeinert |
| Paritaetsfaelle 10/11, Zufallsinterrupt mit `ident`, `default` mit `nested` | ~160 Tokens | (iii) klein | Diagnose fuer die A5120-Hardware (NMI, Vektor 0); kein V7-/WEGA-Gegenstueck; Bedeutung der Bits *angenommen* |
| `7C04..06` als `bpt/iot/emt`, Einzelschritt ueber NVIE | ~60 Tokens | (iii) klein | Abbildung auf Z8001-Mittel; WEGA kennt sie nicht; Hardware-Voraussetzung nicht geprueft |
| `regloc[16]` mit `csv`-Plaetzen | 16 B Tabelle, ~10 Tokens | (iii) klein | geschickt, aber klein; V7-Gedanke (`regloc`) |
| `sendsig` (4-Wort-Rahmen), `sigret` | 63 neue Tokens | (ii) | Rahmen = Z8001-Interruptformat; `SC #0` wie WEGA |
| `trapent` (Umschrift von `trap`/`call`), `save`, `resume`-Rahmen, `csv/cret`, `addupc`, `savfp` | 518 B | (ii) | V7-Struktur Befehl fuer Befehl; Z8001-Befehle statt PDP-11 |
| `spl`, `fu/su`, `copyin/out`, `copyseg/clearseg` | 394 B | (ii) | V7-Funktion, anderer Mechanismus (Port-Schatten, FCW-Umschaltung, `LDIR`); `speicher.md` |
| PSA/Vektoren, `start`, `mapaddr` | 740 B (574 B Tabellen) | (iii) fuer `start`, sonst durch Hardware vorgegeben | Initialisierung der A5120-Hardware; Tabellen folgen der CPU und den angeschlossenen Geraeten |
| Benutzer-ABI (SC, `r0..r4`, Carry, `signal`-Stub, `SC #0`) | nicht im Kernel | **Vorlage vorhanden (WEGA)** | Abschnitt 7.2 |

**Spanne.**
* *Umfang:* neu geschriebener C-Text im engeren Z8001-Kontext (`trap` 179, `sendsig` 37, `sigret` 26, `setregs` 55 = 297 Tokens) **1,0 %** des C-Kerns; alle 986 neuen Tokens der 21 Funktionen **3,4 %**; davon sind etwa 400 (`getxfile`, `fork`, `startup`, `sbreak`) schon im Speicheranteil von `speicher.md` gezaehlt.
  Assembler: neu **166 B Code (15 % des Handcodes)** oder 740 B mit Tabellen (45 %), das sind 0,5 % beziehungsweise 2,0 % des Abbilds (36 352 B).
* *Wertung:* **(ii) mit kleinen (iii)-Anteilen.**  Das Z8001-Verhalten (PSA, Eintritt, Carry-Fehler, `SC`, Signalrahmen) ist entweder von der CPU vorgegeben, von der V7-Struktur (`mch.s`) uebernommen oder -- die Benutzerseite -- in der WEGA-Bibliothek schon vorhanden.
  Eigenstaendig sind Einzelzuege (Abschnitt 1, vorletzter Punkt) von zusammen etwa 250 C-Tokens und 170 B Code.
* **Was die Spanne bestimmt:** (1) ob die Benutzer-ABI (aus der Bibliothek) dem Kernelentwurf zugerechnet wird -- sie ist es nach 7.2 nicht, der Kernel *erfuellt* sie nur; (2) ob PSA/Vektortabelle und `start` als "Hardware vorgegeben" oder als Konstruktion zaehlen (574 + 144 B);
  (3) ob die Paritaets-/Einzelschrittzuege (Hardware der Karte, *angenommen*) als Eigenentwurf gelten; (4) ob die Token des *Originals* denen der Rekonstruktion entsprechen (`speicher.md` Abschnitt 2).  Mit diesen Entscheidungen liegt der Eigenanteil zwischen etwa 1 % (nur Z8001-Kontext-C) und 3,4 % (alle Abweichungen) des C-Kerns, im Handcode zwischen 15 % und 45 %.

## 9. Offene Punkte

1. **Uebernahme in `kernel/c/trap.c`** (Diff vorhanden, Abschnitt 5.4) und anschliessend `gesamtbau.py --stufe 1 --boot`: nicht ausgefuehrt (Auftrag: `kernel/` nicht aendern).
2. **Einzelschritt**: ob die A5120.16 nach jedem Befehl einen NVI liefert (`procxmt` Fall 9 `|= 0x800`); Test mit `adb` im Gast (Haltepunkt `7C06`, Einzelschritt) steht aus.
3. **Bits der Vektorkennung bei Paritaet** (`ident >> 14`, `& F600`): Schaltplan/EM-Karte (`doc/referenz/a5120_16.md`) nicht ausgewertet.
4. **Port 0x80** (Schatten `8DC2`, Impulsfolge am Ende von `trapent`): Bedeutung der Bits nur aus der U880-Seite abzuleiten (`mutos_io`).
5. **Fehlerbehandlung `sendsig`**: ungueltiger Benutzerstapel wird nicht geprueft; Verhalten bei Stapelueberlauf im Gast nicht getestet (`speicher.md` 10 Punkt 3).
6. **Datierung der WEGA-Bibliothek gegenueber MUTOS**: SCCS-Kopf 1983 gegen "ab 1986" der MUTOS-Dateien -- schwache Indizien, kein Beleg fuer die Richtung der Uebernahme; Zilog-ZEUS/Onyx-Quellen nicht gefunden (`speicher.md` 6.1).
7. **`r8..r14` im Benutzerkontext**: Erhalt ueber `csv`-Rahmen von `trap` ist aus `regloc` und `csv` abgeleitet, nicht in einem Wechselversuch geprueft (`resume` sichert `r8..r15` ueber `save`).
8. **Das Gleitkomma-Modell**: `savfp/restfp` sind Stumpfe; ob eine FPU/Emulation im Original je vorhanden war (`F009`-Probe), unbekannt.

## 10. Nachpruefen (Befehle)

```sh
SCR=/tmp/claude-1000/-home-olliy-projects-mutos8k/9fec9724-1e2d-4a7c-841d-7f8cfc3a3344/scratchpad
# Inventar (V7, Hippe, WEGA als Basis) und Klassen
python3 -I tools/herkunft/kontext.py inv --ref hippe=$SCR/h6_hippe_eff --ref wega=$SCR/h6_wega/P8000/WEGA/src/uts
# Funktionsaehnlichkeit gegen 13 Baeume
python3 -I tools/herkunft/kontext.py cmp --ref v7=original/unix-v7/usr/sys/sys --ref hippe=$SCR/h6_hippe_eff/sys \
  --ref nij=$SCR/h6_nijmegen_eff/kernel --ref s3pdp=original/sys3/uts/pdp11/os --ref s3vax=original/sys3/uts/vax/os \
  --ref wega=$SCR/h6_wega/P8000/WEGA/src/uts/sys --ref v32=$SCR/h6_32v/usr/src/sys/sys --ref idata=$SCR/h6_interdata/usr/sys \
  --ref unsw92=$SCR/h6_unsw92/sys/sys --ref b29=$SCR/h6_2.9bsd_usr/src/sys/sys --ref b211=$SCR/h6_2.11pl195_sys/sys/pdp \
  --ref b4=$SCR/h6_4.1bsd/sys/sys --ref ux11=$SCR/h6_ultrix11/sys/sys
# PSA, regloc, Zahlenwerte aus dem Abbild
unzip -p disks/original/a5120_mutos8000_boot_udos.zip dateien/mutos_1216 > $SCR/h8/mutos_1216
xxd -s 0 -l 64 $SCR/h8/mutos_1216; xxd -s 0x88CC -l 16 $SCR/h8/mutos_1216; xxd -s 0x875A -l 8 $SCR/h8/mutos_1216
# Rundlauf und Wortdiff von trap
tools/herkunft/rundlauf.sh $SCR/h8/rl_trap/w trap machdep sys1
python3 -I tools/kernel/vergleich.py $SCR/h8/rl_trap/w/mutos_1216 $SCR/h8/rl_trap/w/g/out/trapO.o kernel/c/trap.c -v | rg -v ' [=~] obj'
# Bibliotheksstumpfe: libc.a aus der Wurzeldiskette, Mitglied entpacken, disassemblieren
unzip -o disks/original/a5120_mutos8000_best_usr.zip 'dateien/lib/libc.a' -d $SCR/h8/lib
python3 -I - <<'EOF'
import sys, struct; sys.path.insert(0, "tools/kernel"); import objformat as O
a = O.Archiv.lesen(open("%s/h8/lib/dateien/lib/libc.a" % __import__("os").environ["SCR"], "rb").read())
m = [x for x in a.mitglieder if x.name.startswith(b"signal.o")][0]
t = struct.unpack(">8H", m.daten[:16])[1]; open("signal.txt.bin", "wb").write(m.daten[16:16 + t])
EOF
python3 -I -c "import sys; sys.path.insert(0,'tools'); import emu; print(emu.binary('z8kdis'))"      # Pfad von z8kdis
z8kdis --entry 0 --entry 3E --entry 62 signal.txt.bin
# WEGA-Vergleichsdateien
sha256sum $SCR/h6_wega/P8000/WEGA/src/lib/libc/sys/signal.s
# Signaltest im Gast (Minuten; im Hintergrund)
K1520EMU_NOBUILD=1 bash versuche/kontext/lauf.sh $SCR/h8/sig      # Ausgabe: lauf.log, cov.txt
```
