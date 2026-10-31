# Speicherverwaltung von MUTOS 8000: V7-Vorlage mit MMU, MUTOS ohne (AP H7)

Stand 2026-10-31.  Plan: `doc/plan/42_unix_herkunft.md`.  Einordnung: `uebersicht.md` Abschnitt 15 (Kurzfassung), `fremd.md` Abschnitt 9.1.
Alle Zahlen **gemessen** (Befehle in Abschnitt 9), sofern nicht als *angenommen* oder *unbekannt* gekennzeichnet.  Es wurde nichts in `kernel/` oder `original/` veraendert.
Ausdrueckliche Vorbemerkung: Namen von Personen werden nicht als Urheber genannt; "Vorlage" meint einen Quelltext, kein Urheberurteil.

## 1. Ergebnis in Kuerze

Frage des Projektinhabers: Gibt es fuer die speicherverwaltungsbezogenen Teile eine andere historische Vorlage, oder ist das Robotron-Eigenentwicklung?  Wurde nur weggelassen, was eine MMU braeuchte?

* **Vorlage: keine gefunden.**  In 27 durchsuchten Kernel-Baeumen (V6/V7-Linie, BSD, System III, 32V, WEGA, LSX, Mini-UNIX, Interdata, V6-auf-286 ...) gibt es unter 47 Dateien mit `estabur` **keine**, die ohne Segmentregister-Bezug auskommt;
  die einzigen Treffer sind die MUTOS-Kopien selbst (Abschnitt 6.3).  LSX und Mini-UNIX (V6, ohne MMU) haben die Funktionen gar nicht (kein `estabur`, `sureg`, `expand`, `malloc(coremap)`) und loesen das Problem durch
  "ein Prozess im Speicher, Wechsel durch Auslagern"; Funktionsaehnlichkeit zu MUTOS 0,07 bis 0,38 (ausser `core`, Abschnitt 6.2).  WEGA (gleicher Prozessor, Z8010-MMU) ist bei allen Speicherfunktionen *weiter* von MUTOS entfernt als V7 oder die Hippe-Sammlung.
  Bei den Speicherfunktionen sind V7 und die Hippe-Sammlung nicht zu unterscheiden (gleicher Text); die MUTOS-Funktionen sind V7-Text mit Aenderungen.
* **Es wurde mehr getan als weggelassen, aber nicht viel mehr.**  Von 36 V7-Funktionen mit Speicherbezug sind 5 unveraendert (a), 16 weggelassen oder Stumpf (b), 15 in V7-Form angepasst (c); dazu kommen 3 C-Funktionen (`mapalloc`, `mapstart`, `sigret`) und etwa 8 Assemblerroutinen ohne V7-Gegenstueck (d).
  Weggelassen wurden 1 825 von 21 485 Tokens des V7-`usr/sys/sys` (8,5 %); **neu geschriebene speicherbezogene C-Logik: etwa 0,55 bis 0,86 k Tokens = 2 bis 3 % des MUTOS-C-Kerns** (weit gezaehlt 1,46 k = 5 %), dazu **etwa 0,43 KB Hand-Assembler (1,2 % des Abbilds)**.
* **Die tragende Idee ist nicht im Kernel-C, sondern in der Hardware-Abbildung:** ein Prozess = ein ganzes 64-KB-Segment der EM-Karte (Segmentweiche Modus 2, Segmentnummer vom U8001), der Benutzer laeuft nichtsegmentiert im Normalbetrieb;
  `p_addr` (Klicknummer des Segmentanfangs, Klick = 256 Byte) ist **bitgleich** das Segmentwort `usegm`.  Der Kernel baut darauf vier Dinge (Umschaltung des Adressraums, Zugriff auf Benutzerspeicher, Abbild auf der Platte, `u`-Bereich als Kopie) neu.
* **Schutz:** Prozess gegen Prozess **ja, gemessen** (Versuch 2026-10-28, `doc/system/befund.md`).  Prozess gegen Kernel **nicht gemessen** (nur aus dem Mechanismus erwartet).  Innerhalb eines Prozesses **kein** Schutz (kein Text-Schreibschutz, keine Stapelgrenze, kein Segmentfehler).
* **Eigenanteil (Abschnitt 8):** Spanne von "(ii) einfache Hilfsrechnung ueber ein vorgegebenes Hardwaremodell" bis "unteres (iii) eigenstaendige Konstruktion"; ob der Entwurf des Hardwaremodells selbst (Segmentweiche, EM-Karte, nicht im Kernel) dazugehoert, entscheidet die Spanne.
* **Funde nebenbei:** (1) `backup` (trap, Fall 9) ist ein 6-Byte-Stumpf `ld r2,#-1; ret`, `grow` wird nie erreicht -- jede Segmentverletzung wird zu `SIGSEG` (Abschnitt 5.9).
  (2) `kernel/karte/adressen.txt` fuehrt `_backup 3630`; 3630 ist `sigret`, der Aufruf in `trap` geht nach 040E (Abschnitt 5.9).  (3) Die offene Frage aus `slp.md` Punkt 5 (wo wird der Swap-Platz beim Einlagern freigegeben) ist beantwortet: in `swap()` selbst.

## 2. Methode und Werkzeuge

* Funktionsaehnlichkeit: `tools/herkunft/herkunft.py` (Winnowing, Ebene `abs`, k = 5, w = 4), Aufruf ueber das neue `tools/herkunft/speicher.py cmp`.
* Token-Diff je Funktion (V7 gegen MUTOS, Ebene `abs`, `difflib`): `speicher.py inv`.  **Gleich** = in beiden Folgen gematcht; **gestrichen** = nur V7; **neu** = nur MUTOS.
* Neue speicherbezogene Zeilenbereiche (von Hand ausgewaehlt, `SNIPS` in `speicher.py`): `speicher.py snip`.  Gesamtgroessen: `speicher.py total`.
* Zeilen des Disassemblats: `kernel/asm/ref/low.s`; Befehlsabdeckung: `kernel/abdeckung/funktionen.txt`; Aufbau und Versuche: `doc/system/befund.md`, `doc/kernel/kernel_struktur.md`.
* **Grenze:** Die Tokenzahlen betreffen den **rekonstruierten** Quelltext in `kernel/c`.  Er uebersetzt (fast ueberall) zu denselben Bytes wie das Original, ist aber nicht der Originaltext (Schreibweise, Makros, Hilfsvariablen koennen anders gewesen sein).
  Die Zahl der Tokens ist also eine Schaetzung der Menge, kein Abdruck des Originals.

## 3. Inventar V7 -> MUTOS

Klassen: **a** unveraendert (MMU-unabhaengig); **b** weggelassen / Stumpf; **c** V7-Logik angepasst oder ersetzt; **d** neu, kein V7-Gegenstueck.
Spalten `V7 / gleich / gestr. / neu`: abs-Tokens (V7-Funktion, gematchte Tokens, nur V7, nur MUTOS).  Die Spalte `neu` enthaelt auch Z8001-Aenderungen, die nichts mit Speicher zu tun haben (Kopfformat, Registerrahmen);
der Speicheranteil steht in Abschnitt 4 (`snip`).

### 3.1 Funktionen in C

| V7 (Datei) | MUTOS (`kernel/c`, Adresse) | Kl. | V7 / gleich / gestr. / neu | Was fehlt oder ist neu |
|---|---|---|---|---|
| `sureg` (ureg.c) | `sureg` (ureg.c, 3D40) | b | 131 / 2 / 129 / 0 | leer (2 Byte `ret`); V7 laedt `UISA`/`UISD` aus `u_uisa`/`u_uisd`.  Rufer bleiben: `swtch`, `newproc` |
| `estabur` (ureg.c) | `estabur` (ureg.c, 3D42) | b | 539 / 25 / 514 / 6 | nur `nt+nd+ns > 256` -> `ENOMEM`; keine Prototyp-Register, `sep` und `xrw` werden ignoriert (Signatur 5 Argumente wie V7).  6 Rufer bleiben |
| `expand` (slp.c) | `expand` (slp.c, 20F6) | b | 150 / 2 / 148 / 0 | Stumpf (8 Byte); V7 vergroessert, kopiert, `resume`.  Rufer: `main` |
| `xalloc`, `xexpand`, `xlock`, `xunlock`, `xccdec`, `xumount`, `xrele`, `xuntext` (text.c) | `xalloc`, `xstub1`, `xlock`, `xunlock`, `xccdec`, `xumount`, `xrele`, `xstub2` (text.c, 5790..57CC) | b | 317+109+31+26+84+44+48+83 / je 2 / 826 / 0 | alle 8 Byte; es gibt **keine Texttabelle** (kein geteilter Text).  Rufer: `getxfile` (2), `swapin` (3), `xswap`, `sys3`, `sys4` (2), `fio` |
| `grow` (sig.c) | `grow` (sig.c, 0E38) | b | 155 / 7 / 148 / 0 | `return(0)` (10 Byte); V7: `estabur`, `expand`, `copyseg`, `clearseg`.  Rufer: `trap` (nie erreicht, 5.9), `sendsig` |
| `sbreak` (sys1.c) | `sbreak` (sys1.c, 4BD0) | b | 207 / 47 / 160 / 8 | nur Groesse eintragen und neue Klicks loeschen; kein `estabur`, `expand`, Stapelverschiebung, **kein Test** gegen den Stapel |
| `clkstart` (machdep.c) | `kstub` (machdep.c, 35AC) | b | V7 roh 55 | leer; nicht MMU-bezogen, aber an der Stelle |
| `sysphys`, `mapfree` (machdep.c) | -- | b | V7 roh 261 / 37 | fehlen ganz (Abbildung physischen Speichers, UNIBUS-Karte) |
| `newproc` (slp.c) | `newproc` (slp.c, 1EA2) | c | 402 / 387 / 15 / 134 | feste Abbildgroesse `n = 256`; **u-Bereich (4 Klicks ab `&u`) wird in den u-Slot des Kindes kopiert** (zweimal, 57 + 57 Tokens); `savfp`, `proctop` |
| `swapin` (slp.c) | `swapin` (slp.c, 1CCA) | c | 186 / 169 / 17 / 13 | `swap(p_addr, a, 0x104, B_READ, t)` mit `t = (a<<2) + 0xEC00` (u-Slot); `mfree(swapmap)` ist in `swap` gewandert |
| `xswap` (text.c) | `xswap` (text.c, 562C) | c | 119 / 113 / 6 / 70 | Auslagergroesse aus `u_dsize` und gesichertem Benutzer-SP (69 Tokens); u-Slot `EC00 + (p_addr<<2)` |
| `swap` (dev/bio.c) | `swap` (bio.c, 5D4A) | c | 233 / 225 / 8 / 167 | Ganzabbild-Zweig `count >= 0x104`: u-Bereich, Text+Daten, Stapel ab SP (186 Tokens); Klick 256 Byte; `b_xmem` = Segment |
| `physio` (dev/bio.c) | `physio` (bio.c, 5F56) | c | 333 / 282 / 51 / 41 | V7-Bereichspruefung in 256-Byte-Klicks, SP aus `u_ar0[8]`; `b_xmem = usrseg >> 8` |
| `getxfile` (sys1.c) | `getxfile` (sys1.c, 44B6) | c | 613 / 507 / 106 / 361 | kein `expand`, **ganzes Segment (256 Klicks) loeschen**, `ss = btoc(nargc+ucount)+5`; Rest der neuen Tokens: Kopfformat E807/E707 (nicht Speicher) |
| `exece` (sys1.c) | `exece` (sys1.c, 41AC) | c | 607 / 527 / 80 / 106 | Argumente in 10 Swapbloecken, Rahmen am Segmentende (`ucp = -nc - 2`); V7 legt ihn ebenfalls bei 64 K ab (virtueller Raum) -- Speicheranteil klein |
| `fork` (sys1.c) | `fork` (sys1.c, 4AD4) | c | 236 / 218 / 18 / 45 | Swapbedarf aus `u_dsize` und Benutzer-SP statt `ctod(MAXMEM)` (34 Tokens) |
| `core` (sig.c) | `core` (sig.c, 0D56) | c | 191 / 162 / 29 / 34 | Daten `u_dsize<<8`, Stapel ab `u_ar0[8] & 0xFF00`; V7: `p_size - USIZE`, `estabur` |
| `procxmt` (sig.c) | `procxmt` (sig.c, 0F12) | c | 524 / 472 / 52 / 14 | `estabur(..., 6/2)` bleibt als Aufruf (Stumpf); sonst Z8001-Register |
| `startup` (machdep.c) | `startup` (machdep.c, 34F6) | c | 168 / 71 / 97 / 43 | V7-Schleife "alles loeschen und freigeben" beibehalten, aber **Segmentschleife** `usegm = c & 0x7F00`, Schreib-Lese-Test mit 0x55, Obergrenze `c < 0x400`; keine UNIBUS-Karte |
| `sendsig` (machdep.c) | `sendsig` (machdep.c, 35AE) | c | 72 / 56 / 16 / 37 | vier Worte; ruft `grow` (Stumpf) |
| `trap` (trap.c) | `trap` (trap.c, 087A) | c | 744 / 466 / 278 / 179 | Fall 9 (Segmentfehler) mit `backup`/`grow` im V7-Gerippe, aber wirkungslos (5.9); Rest Z8001-Traps |
| `mmread`, `mmwrite` (dev/mem.c) | `mmread`, `mmwrite` (rk.c, 69CE, 6A52) | c | 168 / 91 / 77 / 9 ; 182 / 99 / 83 / 17 | `usrseg = bn << 8` statt `UISA->r[0]` |
| `swtch`, `sched` (slp.c) | `swtch` (1DA4), `sched` (1B34) | a | 263 / 258 / 5 / 4 ; 368 / 356 / 12 / 30 | V7 (`sureg()` ist Stumpf); `sched` mit `update()`-Block (kein Speicher) |
| `xfree` (text.c) | `xfree` (text.c, 5702) | a | 132 / 132 / 0 / 0 | V7-Text; kehrt sofort zurueck (`p_textp == NULL`) |
| `malloc`, `mfree` (malloc.c) | `malloc` (2DF0), `mfree` (2E5A) | a | 96 / 96 / 0 / 10 ; 219 / 219 / 0 / 13 | V7-Text (Kartengrenze 15 Eintraege wie Hippe-Sammlung); Einheit jetzt 256-Byte-Klick |
| -- | `mapalloc` (bio.c, 5CAE), `mapstart` (5CF6) | d | -- | Warteschlange von 4 Eintraegen zur Mailbox (D532 / Wort 6, `mapaddr` 065E); gleicher Name wie V7-`mapalloc` (UNIBUS), kein Textbezug (0,00 .. 0,19) |
| -- | `sigret` (machdep.c, 3630) | d | -- | Rueckkehr aus dem Signal; kein Speicherbezug im engeren Sinn |

### 3.2 Hand-Assembler (`mch.s`, nicht in `kernel/c`; Disassemblat `kernel/asm/ref/low.s`, Adressen `kernel/karte/karte.txt`)

| Routine | Adresse, Laenge | Kl. | Inhalt (gemessen am Disassemblat) |
|---|---|---|---|
| `start` | 027E, 144 B | d | loescht EC00..FFFF (u-Slots und `u`) und 8DC0..D585 (BSS); setzt PSA, Stapel auf 0 |
| `trapent` | 030E, 234 B | d | **Segmentwort im Rahmen**: Eintritt aus dem Benutzerbetrieb setzt das PC-Segment im Rahmen auf `usegm`, Eintritt aus dem Systembetrieb auf 0; **Rueckkehr** in den Benutzerbetrieb schreibt `usegm` (nach einem Prozesswechsel das *neue* Segment) in den Rahmen -- so wechselt der Adressraum |
| `fubyte`, `fuword`, `subyte`, `suword` | 04CC, 04DA, 0508, 0514 (138 B) | d | Systembetrieb, FCW `C000` (segmentiert), Adresse = `usegm:Offset`, Zugriff, zurueck; Fangadresse in `D578` (`nofault`) liefert -1 |
| `copyin`, `copyout` | 0556, 0560 (76 B) | d | `ldir` zwischen `usegm:Offset` und Segment 0, gleiche Umschaltung und `nofault` |
| `copyseg`, `clearseg` | 05A2, 05C6 (72 B) | c | Klicknummer -> Segment:Offset (`click >> 8`, `(click & FF) << 8`); 128 Worte; V7 setzt dafuer KISA-Register |
| `savu`, `resume` | 0614, 0620 (74 B) | c | `resume(p_addr, label)`: u-Bereich (0x400 Byte) von FC00 in den Slot des alten Prozesses `EC00 + (usegm<<2)`, Slot des neuen nach FC00, `usegm := p_addr`, Register aus `label`.  V7: KISA6 umschalten |
| `backup` | 040E, 6 B | b | `ld r2,#-1; ret` (nicht gelaufen; von Hand gelesen: Bytes `2102 FFFF 9E08`) |
| `mapaddr` | 065E, 22 B | d | Mailbox anstossen |

Header: `user.h` hat statt `u_uisa[16]`/`u_uisd[16]` (V7: 64 Byte) nur 14 Byte Fuellung `u_x54` (Offsets aus Zugriffen gemessen, Groesse der Luecke: `0x62 - 0x54`); `u_stack` fehlt.  `proc.h` und `text.h` sind V7; `p_addr` bedeutet weiter "Klicknummer des Abbilds", `p_size` ist immer 256 (ausser `proc[0]`: 0).

## 4. Quantifizierung

Gesamtgroessen (abs-Tokens, `speicher.py total`): MUTOS `kernel/c` 227 Funktionen / **28 933** Tokens (davon `tty2.c` 3 909); V7 `usr/sys/sys` 165 Funktionen / **21 485**; V7 `usr/sys/dev` 234 / 28 476.  Abbild des Kernels 36 352 Byte.

| Klasse | Funktionen | V7-Tokens | davon gleich | nur V7 (gestrichen) | nur MUTOS (neu) |
|---|---|---|---|---|---|
| a unveraendert | 5 | 1 078 | 1 061 | 17 | 57 |
| b weggelassen / Stumpf | 13 | 1 924 | 99 | **1 825** | 14 |
| c angepasst | 15 | 4 778 | 3 845 | 933 | 1 270 |
| d neu | 3 C + 8 asm | -- | -- | -- | ~175 (C: 38 + 73 + 64 abs) |

* **Weggelassen:** 1 825 abs-Tokens in 13 Funktionen (95 % ihres V7-Texts, 8,5 % von `usr/sys/sys`), dazu `sysphys`, `mapfree` (V7 roh 298 Tokens) und die UNIBUS-/KISA-Teile von `startup` (97 gestrichene Tokens).  Von den 227 MUTOS-C-Funktionen sind 11 **leer** (`sureg`, `expand`, 8 in `text.c`, `kstub`), 2 minimal (`grow`, `estabur`), 1 gekuerzt (`sbreak`).
* **Neu und speicherbezogen (C):** die 15 handgewaehlten Bereiche in `speicher.py snip` zaehlen **863 Tokens** (3,0 % von 28 933; knapp zwei Drittel davon `swap`-Ganzabbild 186, `startup` 96, `mmread/mmwrite` 148, `newproc` 118).  Sie enthalten Tokens, die V7 schon hatte (z. B. das Schleifengeruest in `startup`); eng gezaehlt (nur die gegenueber V7 neuen Tokens dieser Bereiche, Schaetzung aus dem Token-Diff: `swap` 167, `newproc` 118, `xswap` 70, `startup` 43, `core` 34, `fork` 34, `mmread/mmwrite` 26, `getxfile` 23, `swapin` 13, `physio` 12, `sbreak` 8, `estabur` 6) sind es etwa 550 (1,9 %).
  Weit gezaehlt (alle neuen Tokens der Klassen b, c, d, also auch Z8001-Kopfformat, Registerrahmen, `mapalloc`/`mapstart`, `sigret`: 14 + 1 270 + 175) 1 459 Tokens = 5,0 %.
* **Neu (Assembler):** `trapent`-Segmentteil (~40 B), `fubyte..suword` 138 B, `copyin/out` 76 B, `copyseg/clearseg` 72 B, `resume` 62 B, `start`-Loeschschleifen (~40 B): **~430 B = 1,2 %** des Abbilds (Spanne 0,4 bis 0,6 KB je nachdem, ob `savu`, `mapaddr`, `backup` gezaehlt werden).
* **Aufrufstellen:** die V7-Rufer der Stumpfe sind unveraendert geblieben (ca. 20 Stellen: 6 x `estabur`, 2 x `sureg`, 3 x `xrele` ...).  Das ist der Kern der Methode: die maschinenunabhaengigen Funktionen bleiben V7, nur die Rufziele wurden geleert.
* **Hippe-Sammlung gegen V7:** bei allen hier betrachteten Speicherfunktionen sind Hippe und V7 gleich bis auf `PROC_MAX`/`LRUI` (`newproc` 402 -> 422 Tokens); die Aussagen oben aendern sich bei Basis Hippe kaum (b: 1 636 gestrichen, c: 805 / 1 160).

## 5. Funktionsweise von MUTOS ohne MMU (rekonstruiert)

Stufen: **[gemessen]** am Code, Disassemblat oder Lauf; **[angenommen]**; **[unbekannt]**.

### 5.1 Physischer Speicher und Aufteilung

* EM256: 4 Segmente zu 64 KB.  Segment 0 = Kernel, Segmente 1..3 = Benutzerprozesse; `startup` meldet `mem = 196608` (3 x 64 KB) [gemessen, `befund.md`].
* Segment 0: `0000..8DBF` Text und Daten (Abbild 36 352 B), `8DC0..D531` BSS, `D532` Postfach (84 B), `D586..EBFF` frei (5 754 B), `EC00..FBFF` **vier u-Slots zu 1 KB**, `FC00..FFFF` das **laufende** `u` samt Kernelstapel (SP startet bei 0) [gemessen, `befund.md`; `resume`, `start`].
* Ein Prozess belegt immer **genau ein Segment**: `newproc` setzt `p_size = 256` Klicks; `startup` gibt die Klicks 0x100..0x3FF in `coremap` frei, alle Zuteilungen sind 256 Klicks gross (erstes Passen), also auch 256-ausgerichtet [gemessen am Code; die Ausrichtung ist eine *angenommene* Folge, nichts erzwingt sie].
  Der Prozess 0 (Swapper) hat `p_addr = 0`, `p_size = 0`, laeuft in Segment 0 und benutzt den Slot `EC00`.
* **`p_addr == usegm`:** Klick = 256 Byte, Segmentanfang = Klicknummer `seg * 256`, das ist `seg << 8` und damit das Segmentwort des Z8001 (Bits 8..14).  `resume` setzt `usegm := p_addr`, `fubyte` benutzt `usegm` als hohes Wort der Adresse, `copyseg` leitet das Segment aus `click >> 8` ab [gemessen].  Dass die 256-Byte-Klickgroesse *deshalb* gewaehlt wurde, ist *angenommen* (sie ist zugleich die Granularitaet der Z8010-Deskriptoren und die von WEGA, 6.4).

### 5.2 Adressraum eines Benutzerprozesses

* Der Benutzer laeuft im **Normalbetrieb, nichtsegmentiert** (FCW ohne SEG-Bit, Befund K0: alle Werkzeuge `$NONSEGMENTED`); 16-Bit-Adressen `0000..FFFF` im eigenen Segment [gemessen: Versuch `wache`: Puffer `12C6..22C5`, SP `FFB6` in beiden Prozessen].
* Text und Daten liegen **zusammen** ab Adresse 0 (`E807`: `a_text` wird zu `a_data` addiert, `u_ex[1] = 0`, `u_tsize = 0`, `u_sep = 0`): kein getrennter Text, kein I/D-Raum, kein geteilter Text [gemessen, `getxfile`].
* Der Stapel waechst von oben: Argumente ab `FFFF` abwaerts (`ucp = -nc - 2`), SP danach z. B. `FFB6` [gemessen].  `u_ssize` wird nur bei `exec` gesetzt und fast nie gelesen; die Stapelausdehnung ergibt sich aus dem **gesicherten Benutzer-SP** `u_ar0[8]` (in `xswap`, `swap`, `fork`, `physio`, `core`) [gemessen].
* `sbreak` setzt `u_dsize` auf `btoc(arg)` und loescht neue Klicks; das Argument ist 16 Bit, der Klickindex bleibt im eigenen Segment [gemessen].

### 5.3 Umschaltung des Adressraums

1. `swtch` waehlt den Prozess und ruft `resume(p->p_addr, label)` [V7-Text].
2. `resume` (0620): sichert `FC00..FFFF` in den Slot des alten (`EC00 + (usegm << 2)`), laedt den Slot des neuen nach `FC00`, setzt `usegm := p_addr`, laedt die Register [gemessen, 20 Befehle].
   **Jeder Prozesswechsel kopiert 2 KB im Kernelsegment** (V7: Umschalten von KISA6).
3. Die Trap-Rueckkehr (`trapent`, ab `03AA`) schreibt `usegm` in das PC-Segment des Rahmens; der `iret` setzt den Benutzer damit in sein Segment [gemessen].  Der Benutzer kann sein Segment nicht selbst waehlen (kein segmentierter Befehl im Normalmodus; FCW-Laden ist privilegiert) [angenommen, Z8000-Architektur].

### 5.4 Zugriff des Kernels auf Benutzerspeicher

* `fubyte`, `fuword`, `subyte`, `suword`, `copyin`, `copyout` schalten kurz in den segmentierten Systembetrieb (`ldctl fcw, #C000`), greifen mit `usegm:Offset` zu und schalten zurueck.  Eine Fangadresse in `D578` (`nofault`) wandelt einen Zugriffsfehler in Rueckgabewert -1 [gemessen].
* **Es gibt keine Adresspruefung:** jede 16-Bit-Adresse ist im eigenen Segment gueltig.  `EFAULT` entsteht praktisch nur durch `nofault`, nicht durch ungueltige Zeiger.  Der Segmentrand wird vom Z8001 nicht ueberschritten (16-Bit-Offsetarithmetik, *angenommen*).
* `physio` prueft den Bereich (V7-Pruefung in 256-Byte-Klicks, `base >= base + count` weist Ueberlauf zurueck): die U880-Seite uebertraegt `mb_seg:mb_addr` mit `mb_cnt` und wuerde den Segmentrand *nicht* umbrechen [gemessen: Pruefung vorhanden; Begruendung *angenommen*].

### 5.5 Speicherzuteilung

`coremap` (16 Eintraege, Einheit 256-Byte-Klick) und `malloc/mfree` sind V7-Text.  `startup` testet Klick fuer Klick (`usegm = c & 0x7F00`, Schreiben und Lesen von 0x55, `clearseg`, `mfree(coremap, 1, c)`), bis ein Klick nicht antwortet oder `c == 0x400`; `maxmem` wird auf 256 gekappt, danach `mfree(swapmap, nswap, 1)` [gemessen].
Folge: **hoechstens 3 Benutzerprozesse gleichzeitig im Speicher** (EM256); jeder weitere wird ausgelagert [gemessen: `befund.md`; Abdeckung: `sched`, `swapin`, `xswap`, `swap` gelaufen, `xswap` 64 von 67 Befehlen].  Mit EM1024 waeren es 15 (`doc/referenz/em1024.md`, Entwurf, nicht gemessen); dann reichten die vier u-Slots nicht.

### 5.6 Swapping

* **Auslagern** (`xswap`, 562C): Platzbedarf `t = ctod(u_dsize) + 2 + ctod(256 - (SP >> 8))` Bloecke (2 = u-Bereich); `malloc(swapmap, t)` (Swapbereich `swplo = 250`, `nswap = 244` Bloecke, `rk2`) [gemessen].  `swap(a, p_addr, 0x104, B_WRITE, up)`.
* **Format auf der Platte** (`swap`, Zweig `count >= 0x104`): (1) u-Bereich 4 Klicks aus dem Slot, (2) `u_tsize + u_dsize` Klicks ab Segmentanfang, (3) Stapel von `(SP >> 8) & ~1` bis zum Segmentende.  **Der Zwischenraum Daten..Stapel wird nicht geschrieben** (V7 schrieb `p_size` zusammenhaengend, weil `expand` die Teile hintereinander legte) [gemessen].
* **Einlagern** (`swapin`): `malloc(coremap, 256)`, `swap(..., 0x104, B_READ, t)` mit `t = (a << 2) + 0xEC00`; am Ende gibt `swap` den Swapplatz frei (`mfree(swapmap, t, blkno - t)`) [gemessen].
* Die Uebertragung ist ein normaler Blockzugriff ueber die Mailbox: `rkstart` setzt `mb_seg = b_xmem` (aus `coreaddr >> 8`), `mb_addr = coreaddr << 8`; die U880-Seite blendet das Segment ueber `EM_BUS` ein (Segment `& 3`) [gemessen].  Dieselbe Zeile `b_xmem = (coreaddr >> 8) & 0177` ist die V7-Zeile `(coreaddr >> 10) & 077` mit anderen Konstanten.
* `fork` ohne freies Segment: `newproc` kopiert den u-Bereich in den Slot des Elternprozesses und ruft `xswap(rpp, 0, 0)`, das Kind entsteht direkt auf der Platte [gemessen].  Mit freiem Segment werden **alle 256 Klicks** kopiert (V7: `p_size`) plus 4 Klicks u-Bereich.

### 5.7 exec, fork, Stapelwachstum

* `getxfile`: kein `expand`, kein `estabur` ausser der Pruefung `ds + ss <= 256` (sonst `ENOMEM`); loescht alle 256 Klicks des Segments, liest Text+Daten ab Adresse 0 per `readi` (Zugriff ueber `usegm`) [gemessen].
* `expand`, `grow`: Stumpf.  Es gibt **kein Wachsen** des Stapels (der Stapel hat das ganze Restsegment) und **kein Verschieben**.  Ein Programm, das mehr als `64 KB - Argumente` braucht, scheitert beim `exec`.

### 5.8 Schutz (gemessen / angenommen / unbekannt)

| Frage | Befund | Stufe |
|---|---|---|
| Prozess A ueberschreibt Speicher von Prozess B? | **nein**: `schreib` ueberschrieb 59 778 Byte seines Raums, `wache B` blieb heil (beide an denselben Adressen) | **gemessen** (2026-10-28) |
| Mechanismus dafuer | Datenzugriffe im nichtsegmentierten Modus tragen die Segmentnummer des PC (Emulator `dataSeg() = pcSeg`; EM-Segmentweiche Modus 2 nimmt SN von der CPU) | Emulatormodell gemessen; reale Chipeigenschaft *angenommen* (Z8000-Handbuch, hier nicht geprueft) |
| Benutzerprozess greift auf Kernel (Segment 0) zu? | nach dem Mechanismus nicht erreichbar; **nicht versucht** | **unbekannt** (erwartet: nein) |
| E/A-Befehle, `ldctl`, `iret` im Benutzerbetrieb | privilegiert -> Trap 2 -> `SIGILL` (`trap`, Fall 2+USER) | Code gelesen; Ausloesung **nicht getestet** |
| Segmentfehler / Bus-Error durch ungueltige Adresse | die Schaltplanauswertung nennt `SEGT` fest auf H (kein Segment-Trap, `doc/referenz/a5120_16.md`); der Kernel-Fall 9 ist zudem wirkungslos (5.9) | Schaltplan-Auswertung; keine Messung am Kernel |
| Stapelueberlauf in die Daten | keine Grenze, kein Wachstum: ueberschreibt eigene Daten oder Text | *angenommen* (nicht getestet) |
| Schreibschutz des Programmtexts | keiner (`estabur` ignoriert `xrw`, kein `RO`-Segment) | gemessen (Code) |
| Prueft der Kernel Benutzerzeiger? | nein, ausser `physio` (5.4) | gemessen (Code) |
| `u` eines Prozesses durch den Prozess erreichbar? | nein: `u` liegt in Segment 0 | gemessen (Layout) |
| Schutz des Kernels vor Kernelfehlern | keiner (Systembetrieb ohne Pruefung, `panic`) | wie V7 |

### 5.9 Auffaelligkeiten im Code

* **`backup` liefert immer -1** (`040E`: `2102 FFFF 9E08` = `ld r2,#-1; ret`; nicht gelaufen: `040E`/`0E38` stehen nicht in `abdeckung_gesamt.txt`).  In `trap` Fall 9 gilt `if (backup(...) == 0) if (grow(a)) goto out; i = SIGSEG;` -- die Bedingung ist nie wahr, `grow` wird nie gerufen.
  Das Disassemblat (`trap.s`: `call L040E`) und der Quelltext stimmen; **`kernel/karte/adressen.txt` hat `_backup 3630`**, das ist `sigret` (die Karte nennt 040E nicht).  Ob das die 37 abweichenden Woerter von `trap` im Rundlauf (`trap.md`) erklaert, ist *ungeprueft* (Nachlauf `gesamtbau.py` mit 040E).
* Die Namen im Kernelquelltext (`sureg`, `estabur`, `expand`, `grow`, `xalloc`, `backup`) sind V7-Namen: die Funktionen wurden *geleert*, nicht entfernt und umbenannt; das spricht (*angenommen*) dafuer, dass das Original aus V7-Text entstand und nicht aus einer MMU-losen Vorlage.
* `u_ssize` ist praktisch tot, `p_size` ist konstant 256, `maxmem` wird nur in `startup` benutzt.
* `sbreak` kann die Daten bis `FFFF` ausdehnen (Kollision mit dem Stapel ungeprueft); die Auslagerrechnung (`xswap`) bleibt dabei konsistent, weil sie nur Daten und Stapel getrennt zaehlt.

## 6. Vorlagenvergleich

### 6.1 Geladene Quellen

Alle in `SCR/` = `/tmp/claude-1000/-home-olliy-projects-mutos8k/9fec9724-1e2d-4a7c-841d-7f8cfc3a3344/scratchpad/`; Basis-URL `https://www.tuhs.org/Archive/Distributions/`.  Die in `fremd.md` Abschnitt 2 und 8.2b aufgefuehrten Baeume (Hippe, Nijmegen, UNSW, V7M, Ultrix-11, 2.8 bis 2.11BSD, 3BSD, 4.1BSD, 32V, PWB, Interdata, V7, System III, WEGA) wurden wiederverwendet (47 Dateien mit `estabur` ueberprueft).  **Neu geladen in H7** (`SCR/h7/dl/`):

| Kuerzel | Pfad ab Basis-URL | SHA-256 | Inhalt |
|---|---|---|---|
| lsx | `USDL/LSX/lsxfs.tar.bz2` | `2d304d426aee4708214d250d4f89f34a38d0073cc89e25ba0491e59026b8436a` | V6-Dateisysteme von LSX (LSI-11, ohne MMU); Kernel in `usr.fs` (mit `v6fs_read.py` entpackt, 274 Dateien) |
| lsx (Abbilder) | `USDL/LSX/lsximgs.tar.bz2` | `e162ede495b8af5fdb771cfb30c3f000c5ef2da0c7e48034300e3968cd356b36` | rohe Plattenabbilder (nicht ausgewertet) |
| lsx (Lauf) | `USDL/LSX/log.txt` | `c396502e061b5ee7c769131d83d76d730b4aca84a9b01fb3f479aa346ef80fce` | Sitzung: Programm `main` bei 16410, Stapel 40934 (ein Prozess im Speicher) |
| mini | `USDL/Mini-Unix/tape1.tar.gz` | `ae583312ff745b6424f0360f20c8d34c682ad92be21fdcc475a805801e843c22` | Mini-UNIX (V6 fuer PDP-11 ohne MMU), Kernel in `usr/sys/mxsys` |
| mini | `USDL/Mini-Unix/tape2.tar.gz`, `tape3.tar.gz`, `mxutil.tar.gz`, `README` | vollstaendig unter der Tabelle | Quellen, Handbuch, Werkzeuge (nicht ausgewertet ausser tape1) |
| v6286 | `Other/V6on286/v6_on_286.zip` | `957007e9497618f30561bfeb662446e1148e1508a076870c4e962c180fecdff7` | V6 auf 286 im Schutzmodus (hat Segmentierung, also kein MMU-loser Fall) |
| pcix | `Other/PCIX/README` | `6497a4c447b9e7a3f0ec25cbb306eabaad95f5b7d38819713251bbf6a9c4e50c` | nur Beschreibung (Abbilder, keine Quellen) |
| coh | `Other/Coherent/README` | `4ddd374297130402718c0b8abe754fbd8e2019cfd0031edabd4c8556c08b78e5` | nur Beschreibung; `kernelsource/` ist i386 (4.2.10), nicht geladen |

Vollstaendige Pruefsummen der uebrigen Dateien (`sha256sum`, `SCR/h7/sha256.txt`):

```
3bbd362635b19c130b4aeb632966b35e90ca90a2cca2848f07ab408963143d25  USDL_Mini-Unix_tape2.tar.gz
1ad42098d35e38f79951731a9a3c4c53ec450b91230046fa265a36a6acd6e03d  USDL_Mini-Unix_tape3.tar.gz
bbe87ccc1030be1ab698ef65cdfedc154a459199baf162e12acb3aac28e2b517  USDL_Mini-Unix_mxutil.tar.gz
d22d10d5d455c8659295108905fdc6ecfcf3c934546dd7d814cd0acaa27a3a6c  USDL_Mini-Unix_README
```

Nicht geladen: Coherent-Kernel (i386, anderer Prozessor), Xenix/Venix/PC-IX (nur Binaerabbilder oder Emulatorplatten, keine Quellen), Zilog ZEUS / Onyx / Plexus / Unisoft / Commodore-900-Coherent (nicht im TUHS-Archiv gefunden), MUTOS1600-Quellen (nicht bekannt).
Die Aussage "keine Vorlage" gilt **nur fuer die geladenen Baeume**.

### 6.2 Funktionsaehnlichkeit (abs, `speicher.py cmp`; Rauschwerte: leere Funktionen gleichen jeder leeren Funktion)

| MUTOS | V7 | Hippe | WEGA | LSX | Mini-UNIX |
|---|---|---|---|---|---|
| `newproc` | 0,82 | 0,86 | 0,79 | 0,26 | 0,37 |
| `swapin` | 0,80 | 0,80 | 0,76 | 0,13 | 0,13 |
| `sched` | 0,92 | 0,93 | 0,85 | 0,19 | 0,15 |
| `swtch` | 0,90 | 0,90 | 0,65 | 0,08 | 0,10 |
| `xswap` | 0,66 | 0,66 | 0,62 | 0,09 | 0,11 |
| `xfree` | 1,00 | 1,00 | 0,84 | 0,10 | 0,18 |
| `swap` | 0,72 | 0,72 | 0,47 | 0,22 | 0,34 |
| `physio` | 0,76 | 0,76 | 0,33 | 0,26 | 0,34 |
| `getxfile` | 0,55 | 0,55 | 0,50 (Rauschen) | 0,17 | 0,20 |
| `fork` | 0,78 | 0,81 | 0,61 | 0,35 | 0,38 |
| `core` | 0,77 | 0,77 | 0,39 | 0,53 | 0,71 |
| `procxmt` | 0,81 | 0,83 | 0,52 | 0,07 | 0,17 |
| `startup` | 0,23 | 0,25 | 0,26 | 0,08 | 0,08 |
| `sendsig` | 0,55 | 0,55 | 0,07 | 0,33 | 0,33 |
| `sbreak` | 0,23 | 0,23 | 0,23 | 0,09 | 0,19 |
| `estabur` (31 Tokens) | 0,55 | 0,55 | 0,55 | 0,17 | 0,18 |

Lesehilfe: kein Wert spricht fuer eine Vorlage *neben* V7.  `core` (Mini-UNIX 0,71) ist eine V6-Funktion, die V7 fast unveraendert uebernahm; sie sagt nichts ueber die Speicherabbildung.  `startup` (alle <= 0,26) und `sbreak` (<= 0,23) sind in allen Baeumen eigen.
Die Stumpfe (`sureg`, `expand`, 8 in `text.c`) liefern 1,00 gegen irgendeine leere Funktion in jedem Baum: **Rauschen**, kein Beleg.

### 6.3 Gezielte Suchen

* `^estabur(` in allen geladenen `.c`/`.s`: 47 Dateien; ohne jeden Bezug auf `uisa`/`UISA`/`u_segmts`/`sg_base`/`KDSA`/`mmu`/`pcb`: **nur die MUTOS-Kopien** (`kernel/c/ureg.c` und Arbeitsstaende im Scratchpad).  Kommando: Abschnitt 9.
* Bezeichner `usegm`, `usrseg` in 27 durchsuchten Baeumen: 0 Treffer ausser MUTOS.  `b_xmem` kommt in der V7-Linie vor (PDP-11-Erweiterungsbits), in WEGA, LSX und Mini-UNIX nicht.
* WEGA-eigene Bezeichner (`setscr`, `invsdrs`, `shufflecore`, `segureg`, `loadsd`, `u_segmts`, `u_segmented`, `sg_base`, `mmut`, `CPAS`, `ENOSEG`): **0 Treffer in `kernel/`**.
* `estabur` hat in V7, Hippe, Nijmegen, V7M, 32V, System III **5 Argumente** (`nt, nd, ns, sep, xrw`); WEGA hat **4**; MUTOS hat 5 und die Aufrufe `estabur(..., 2)`/`(..., 6)` (V7: `RO`/`RW`).  Das Geruest ist V7, nicht WEGA.
* Nach "ohne MMU"-Hinweisen (`nommu`, `no mmu`, `without mmu`, `11/23`, `LSI-11`) in Hippe, Nijmegen, UNSW, V7M, Ultrix-11, 2.9BSD, Interdata, PWB: Treffer nur in Dokumentation und Treibern; **keine MMU-lose Konfiguration des V7-Kernels**.

### 6.4 Die naechsten Verwandten, jeweils eine Zeile

* **LSX** (V6, LSI-11 ohne MMU): kein `estabur`/`sureg`/`expand`/`malloc(coremap)`; **ein** Prozess im Speicher bei festem Ladeort, `swap(B_WRITE)` bei `fork` und beim Wechsel; Stapel und Daten werden durch den Prozess selbst begrenzt.  Konzeptionell der naechste MMU-lose Fall, textlich ohne Beziehung zu MUTOS.
* **Mini-UNIX** (V6, ohne MMU): dasselbe Muster (`swap(rp, B_READ/B_WRITE)` in `slp.c`, `swap(rpp, B_WRITE)` beim `newproc`); `core` nahe an MUTOS, weil V6-Erbe; sonst unabhaengig.
* **WEGA** (V7/SysIII-Linie, Z8001 + Z8010): voller MMU-Weg (`sureg` laedt Deskriptoren, `estabur` berechnet Basis/Limit, `sestabur`, `mkseg`, `shufflecore`, `grow` mit `expand`); feste *logische* Segmentnummern (`USEG 3F`, `STAK 7F`).  Gemeinsam mit MUTOS sind nur Dinge, die der Prozessor oder die Klickgroesse vorgeben:
  Klick 256 Byte (`ctob(x) ((x)<<8)`, `ctod(x) (((x)+1)>>1)`, `btoc` mit 255, `CPAS 256`), die Maske `0x7F00` (Segmentwort), `copyseg` = 128 Worte per `ldir`, `clearseg` = erstes Wort loeschen und `ldir` (ein allgemeines Z8000-Muster).
  `USIZE` 10 (WEGA) gegen 4 (MUTOS; V7 16 x 64 Byte = 1 KB wie MUTOS), `SSIZE 5` ist in beiden die V7-Groesse (20 x 64 Byte = 1 280 Byte) in Klicks, kein Merkmal; kein `u_segmts` in MUTOS.  Das stuetzt "beide stammen aus Z8001-Anpassungen mit 256-Byte-Klick", ist aber **kein Textbeleg** (die Klickgroesse folgt aus der Z8010-Granularitaet bzw. der 64-KB-Segmentgroesse, *angenommen*).
* **Interdata-V6** (Basisadresse `klick << 8`, 15 Segmentregister): hat `sureg`/`estabur` mit Segmentregistern; keine MMU-lose Form.

## 7. Was die Vorlagenlage fuer die Frage heisst

* Die Speicher*schnittstellen* (Namen, Signaturen, Rufer, `p_addr`/`p_size` in Klicks, `coremap`, `copyseg`/`clearseg`, `b_xmem`) sind V7.  Der Kernel behaelt sie bei und ersetzt nur die Rufziele.  Das ist **Anpassung von V7**, keine zweite Vorlage.
* Eine historische Vorlage fuer die *neuen* Teile (Segmentwort `usegm`, u-Slots, Dreiteil-Swap, Segmentumschaltung im Trap) wurde **nicht gefunden**; ausgeschlossen ist sie nicht (Abschnitt 6.1: nicht geladene und nicht oeffentliche Quellen, besonders eine denkbare MUTOS1600-Stufe, `fremd.md` Abschnitt 9).
* Keine Aussage ueber Urheberschaft: "Eigenentwicklung" heisst hier nur "ohne gefundene Vorlage".

## 8. Bewertung des schoepferischen Anteils

Massstaebe: (i) reines Weglassen (Stumpf), (ii) Ersatz durch einfache Hilfsrechnung, (iii) eigenstaendige Konstruktion.

| Teil | Umfang | Stufe | Begruendung |
|---|---|---|---|
| `sureg`, `expand`, 8 Text-Funktionen, `grow`, `backup`, `estabur`-Rumpf, `sysphys`, `mapfree` | 16 Funktionen, ~1 800 V7-Tokens weg, 0 neu | (i) | leere oder Ein-Zeilen-Rumpf; Rufer bleiben |
| feste Konstanten (`n = 256`, `0x7F00`, `0xEC00`, `0x104`, `256 - (SP>>8)`, `ss = ... + 5`) | ~100 Tokens | (ii) | Rechnungen, die sich aus dem Hardwaremodell ergeben |
| `startup`-Schleife, `getxfile` (Segment loeschen), `fork` (Swapbedarf), `sbreak`, `mmread/mmwrite`, `physio`-Zeile, `core` | ~350 Tokens | (ii) | V7-Geruest mit anderen Groessen/Segmentwort |
| `newproc` (u-Bereich in Slot), `swapin`, `xswap`, `swap`-Ganzabbild | ~400 Tokens | (ii) bis (iii) | das Abbildformat (3 Teile, 2 + n + m Bloecke, Slot-Adresse aus `p_addr << 2`) musste neu entworfen werden; die Logik ist klein, aber folgenreich (Freigabe des Swapplatzes in `swap`, Kind direkt auf der Platte) |
| `resume`, `trapent`-Segmentteil, `fubyte..copyout`, `copyseg/clearseg` | ~0,43 KB | (iii) | Adressraumwechsel ueber Segmentwort im Rahmen, Zugriff durch kurzzeitige FCW-Umschaltung mit `nofault`; kein V7- oder WEGA-Gegenstueck |
| Hardwarebild (Segmentweiche Modus 2, 3 Benutzersegmente, nichtsegmentierter Normalbetrieb) | nicht im Kernel | nicht zaehlbar | bestimmt fast alle obigen Entscheidungen; Urheber und Zeitpunkt unbekannt |

**Spanne.**  Nach Umfang: neue speicherbezogene Logik 2 % (eng) ueber 3 % (mit V7-Geruest) bis 5 % (weit) der C-Tokens plus 1,2 % des Abbilds in Assembler; weggelassen 8,5 % des V7-Kerns.  Nach Entwurfsaufwand: die Aufgabe "V7 ohne MMU zum Laufen bringen" war mit
einem **vorgegebenen** Hardwaremodell (ein Prozess = ein Segment, p_addr = Segmentwort) in wenigen hundert Token zu loesen; dass sie sich so klein loesen laesst, ist selbst ein Entwurfsergebnis (V7-Schnittstellen unveraendert, Rufer unberuehrt).
Mein Urteil (Wertung, nicht Messung): **(ii), mit einem (iii)-Kern aus dem Assembler (~0,43 KB) und der Swap-/Slot-Logik (~400 C-Tokens; Objektgroesse dieser C-Teile nicht gemessen)**; "nur weggelassen" trifft nicht zu, "grosse Eigenentwicklung" auch nicht.

Was die Spanne bestimmt:

1. ob die Z8001-Aenderungen an `getxfile`, `exece`, `trap`, `sendsig` (Kopf, Registerrahmen) zur "Speicheranpassung" gezaehlt werden (3 % gegen 5 %; eng gezaehlt 2 %);
2. ob `mapalloc`/`mapstart` (DMA-Adressierung ueber die Mailbox) dazugehoeren;
3. ob das Hardwaremodell (EM-Segmentweiche) dem Kernelentwurf zugerechnet wird -- das ist die groesste Unsicherheit und mit den vorliegenden Quellen nicht entscheidbar;
4. ob die Kernel-Tokens des *Originals* denen der Rekonstruktion entsprechen (Abschnitt 2).

## 9. Nachpruefen (Befehle)

```sh
SCR=/tmp/claude-1000/-home-olliy-projects-mutos8k/9fec9724-1e2d-4a7c-841d-7f8cfc3a3344/scratchpad
# Quellen neu laden (Basis-URL siehe 6.1) und Pruefsummen vergleichen
B=https://www.tuhs.org/Archive/Distributions; mkdir -p $SCR/h7/dl && cd $SCR/h7/dl
for u in USDL/LSX/lsxfs.tar.bz2 USDL/LSX/lsximgs.tar.bz2 USDL/LSX/log.txt USDL/Mini-Unix/tape1.tar.gz USDL/Mini-Unix/tape2.tar.gz \
         USDL/Mini-Unix/tape3.tar.gz USDL/Mini-Unix/mxutil.tar.gz USDL/Mini-Unix/README Other/V6on286/v6_on_286.zip; do
  curl -sf -o $(echo $u | tr / _) $B/$u; done; sha256sum *
# Entpacken (LSX: V6-Dateisystem; Mini-UNIX und V6on286: tar/zip)
mkdir -p ../x/lsxfs ../x/mu1; tar -xjf USDL_LSX_lsxfs.tar.bz2 -C ../x/lsxfs; tar -xzf USDL_Mini-Unix_tape1.tar.gz -C ../x/mu1
cd - ; python3 -I tools/herkunft/v6fs_read.py $SCR/h7/x/lsxfs/usr.fs $SCR/h7/x/lsx_usr
# Inventar und Token-Diff (V7 und Hippe als Basis)
python3 -I tools/herkunft/speicher.py inv --base hippe=$SCR/h6_hippe_eff
python3 -I tools/herkunft/speicher.py snip ; python3 -I tools/herkunft/speicher.py total
# Funktionsaehnlichkeit gegen V7, Hippe, WEGA, LSX, Mini-UNIX
python3 -I tools/herkunft/speicher.py cmp \
  --ref v7=original/unix-v7/usr/sys/sys:original/unix-v7/usr/sys/dev --ref hippe=$SCR/h6_hippe_eff/sys:$SCR/h6_hippe_eff/dev \
  --ref wega=$SCR/h6_wega/P8000/WEGA/src/uts/sys:$SCR/h6_wega/P8000/WEGA/src/uts/dev \
  --ref lsx=$SCR/h7/x/lsx_usr --ref minix=$SCR/h7/x/mu1/usr/sys/mxsys
# estabur ohne MMU-Bezug irgendwo?
rg -l --glob '*.c' '^estabur\s*\(' $SCR | while read f; do rg -q 'uisa|UISA|u_segmts|sg_base|KDSA|mmu|MMU|pcb' "$f" || echo "ohne MMU-Bezug: $f"; done
# backup-Stumpf: Bytes bei 040C..0413 im Kernelabbild (mutos_1216 aus der Ladediskette), Aufruf in trap
xxd -s 0x40C -l 8 $SCR/mutos_1216          # 9e08 2102 ffff 9e08
rg -n 'call\s+L040E' kernel/asm/ref/trap.s
rg -n '^(040E|0E38)' kernel/abdeckung/funktionen.txt   # 0E38: 0/3 Befehle gelaufen; 040E steht nicht in abdeckung_gesamt.txt
```

## 10. Offene Punkte und naechste Messungen

1. **Schutz des Kernels gegen Benutzerprozesse** (unbekannt): Versuchsprogramm im Gast, das (a) eine Schleife ueber `0000..FFFF` liest, (b) `ldctl`/`out` ausfuehrt (erwartet `SIGILL`), (c) den Stapel bis in die Daten laufen laesst, (d) `brk` bis `FFFF` ausdehnt und danach ausgelagert wird.  Ablauf wie `versuche/schutz/`; nicht begonnen (Gastlauf, Minuten).
2. **Reale Z8001-Eigenschaft "nichtsegmentierte Zugriffe tragen die Segmentnummer des PC"**: hier nur ueber das Emulatormodell (`dataSeg()`) und `befund.md` gestuetzt; am Handbuch zu belegen.
3. **Stapelueberlauf**: ob der Z8001-Stapelzeiger bei 0 auf `FFFE` umbricht (Folge: unauffaelliges Ueberschreiben) -- Messung im Emulator.
4. **`adressen.txt` `_backup`**: auf 040E setzen und `gesamtbau.py` laufen lassen (aendert `kernel/`, nicht in diesem AP); pruefen, ob die 37 abweichenden Woerter von `trap` verschwinden.
5. **`u_x54` (14 Byte)**: ob V7 hier `u_uisa[7]` o. ae. hatte oder die Luecke zufaellig ist -- nicht aus Zugriffen ableitbar.
6. **Weitere Vorlagen**: MUTOS1600-/K1630-Quellen (falls je auffindbar), Zilog-ZEUS-/Onyx-/Plexus-Z8000-Kerne, Coherent fuer Z8000/PDP-11; die Linie UNSW -> Vrije -> Hippe (`fremd.md` Abschnitt 8) enthaelt nach den hier geprueften Baeumen keine Speicheraenderung.
7. **Originaltext der Speicherfunktionen**: die Rekonstruktion trifft die Bytes (`slp.md`, `bio.md`, `text.md`), nicht notwendig den Text; Token-Anteile koennen sich dadurch um einige Prozent verschieben.
8. **EM1024** (`em1024.md` 3): u-Slots (`EC00 + (usegm << 2)`) reichen nur fuer Segmente 0..3; fuer mehr Segmente muss die Slotrechnung (`resume`, `xswap`, `swapin`, `newproc`) geaendert werden -- Folge dieser Analyse, keine Messung.
