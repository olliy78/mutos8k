# Mailbox-Treiber: Eigenanteil der Hardware-Anbindung gegenueber V7/Hippe-Sammlung (AP H8, Paket 1)

Stand 2026-10-31.  Frage: Wie gross ist der Eigenanteil der Anbindung Z8001-Kernel <-> U880-Teil `mutos_io` gegenueber V7 und dem Kernel der Hippe-Sammlung, gibt es eine historische Vorlage, was wurde gegenueber der V7-Treiberstruktur neu konstruiert?
"Hippe" meint wie in `uebersicht.md` nur die **Sammlung** (TUHS `Distributions/Research/Torsten_Hippe_v7`), nicht einen Urheber.
Kennzeichnung: **gemessen** = Werkzeugausgabe oder Lesen des Codes/Disassemblats mit Fundstelle; **abgeleitet** = Schluss aus Gemessenem; **angenommen** = ohne Beleg.
Es wurde nichts am Gast gemessen; alle Aussagen zum Protokoll stammen aus Quelltext, Disassemblat und den vorhandenen Gastmessungen in `doc/mutos_io/analyse.md`.

## 1. Ergebnis in Kuerze

* **Umfang:** die Mailbox-Treiber umfassen 38 C-Funktionen und 4 189 abs-Tokens = **14,5 %** des Kernel-C (28 933 Tokens, 227 Funktionen); dazu 7 Assemblerbefehle (`mapaddr`), die Vektortabelle und die gesamte U880-Seite (`mutosio.mac`, 2 032 Zeilen, `mutosio.bin` 5 376 Byte).
* **Klassifikation der 4 189 Tokens (Strukturmass, Abschnitt 2):** unveraendert 0,7 %, **angepasst** 73,5 % (V7-/Hippe-Gerippe, Hardwarezugriff durch Mailbox ersetzt), **ersetzt** 17,1 % (gleiche Rolle, neuer Rumpf), **neu** 8,7 %.
  Nach dem **Textmass** (`herkunft.py`, Funktionsaehnlichkeit >= 40 % gegen irgendeine Vorlage) sind nur 11 % der Tokens "Vorlagentext".  Die Spanne zwischen beiden Massen ist der Kern der Antwort (Abschnitt 6).
* **Vorlage je Treiber:** `rk` ja (V7 `rk.c`/Hippe `rk.c`, Gerippe + Text); `lp` ja fuer die Zeilenaufbereitung (Hippe/Nijmegen/System III `lp.c`, Logik gleich, Text umbenannt), nein fuer den Ausgabepfad; `tty` (`tc*`) ja fuer die Huellen (V7-/Hippe-`kl.c`), nein fuer `ttstart`/`putchar`;
  `fd` (`dev0.c`) **Gerippe ja, aber aus dem Magnetbandtreiber `tm.c` samt BSD-`tmioctl`, nicht aus einem Plattentreiber** (neuer Befund, korrigiert "none/eigen" in `dev0.md`); Protokoll, `mapalloc`/`mapstart` und die U880-Seite **nein** (keine Vorlage in den lokal entpackten Baeumen (`SCR/h6_*`, `SCR/h7`) und in `~/projects/UDOS`, `~/projects/A5120.16`).
* **WEGA** (Z8001 mit zweitem Prozessor) ist **nicht** die Vorlage: andere Kopplung (PIO, Bytestrom `'R'/'W'` + Blocknummer + Laenge, keine Speicherbox), Funktionsaehnlichkeit unter 25 % ausser auf Allerweltsmustern.
* **Eigenanteil (Wertung, Abschnitt 6):** das Protokoll und die U880-Seite sind eigenstaendige Konstruktion (iii); die Kernel-Treiber sind ueberwiegend Anpassung der V7-Struktur (ii); Spanne **3,7 % bis 12,9 % des Kernel-C** (Untergrenze: neu + ersetzt; Obergrenze: alles ohne Textvorlage), dazu die komplette U880-Seite.

## 2. Inventar der Treiberfunktionen

Quellen der Zahlen: Adresse = `/* KERNEL xxxx */` in `kernel/c`; Tokens = abs-Tokens je Funktion (`tools/herkunft/herkunft.py`, Tokenizer + `speicher.absn`, Skript `SCR/h8/tok.py`, Ausgabe `SCR/h8/tok.txt`);
Aehnlichkeit = bestes Funktionsgegenstueck (`herkunft.py compare ... --level abs`, Ausgaben `SCR/h8/{rk,tty,lp,dev0}_cmp.txt`); `SCR` = Scratchpad `/tmp/claude-1000/-home-olliy-projects-mutos8k/9fec9724-1e2d-4a7c-841d-7f8cfc3a3344/scratchpad/`.
Klassen (Strukturmass, abgeleitet aus Lesen der Funktion gegen das V7-/Hippe-Gegenstueck):
**unveraendert** = Text gleich; **angepasst** = V7-/Hippe-Gerippe (gleiche Verzweigungsfolge, Zustandsvariablen, Konstanten), Hardwarezugriff geaendert, auch bei geringer Textaehnlichkeit; **ersetzt** = gleiche Rolle im V7-Rahmen, Rumpf neu; **neu** = keine Rolle in V7.

### 2.1 rk.c (Plattenersatz, Major 4)

| Funktion | Kernel | Tokens | V7-Gegenstueck | Aehnl. V7 / Hippe | Klasse |
|---|---|---|---|---|---|
| rkopen | 6ADA | 21 | keins (V7 `rk.c` ohne open) | 31 % (dn.c, Zufall) | neu |
| rkclose | 6AFE | 2 | keins (leer) | -- | neu |
| rkstrategy | 6B06 | 86 | `rkstrategy` | 42 % / **50 %** | angepasst |
| rkstart | 6B60 | 110 | `rkstart` (RK11-Register) | 15 % | ersetzt |
| rkintr | 6BCA | 139 | `rkintr` | 24 % / 24 % | angepasst |
| rkread, rkwrite | 6C52, 6C70 | 14 + 14 | `rkread`, `rkwrite` | 100 % | unveraendert |
| mmread, mmwrite | 69CE, 6A52 | 100 + 116 | `mem.c` | 45 % / 41 % | angepasst (Z8001-`usrseg`, kein Mailboxbezug) |
| syopen .. syioctl | 6C8E..6D12 | 42 + 22 + 22 + 28 | `sys.c` | 100 % | unveraendert (kein Mailboxbezug) |

Mailboxbezogen sind 7 Funktionen / 386 Tokens; `mm*`, `sy*` (330 Tokens) zaehlen nicht mit.
`rkstrategy` ist V7: Pruefung der Blockgrenze, Anhaengen an `b_actf/b_actl`, `spl5`, Start wenn untaetig; **gemessen** (Quelle `rk.c`, Kommentar vor der Funktion): Grenze `0x260` statt 4872 und `b_error = ENXIO`; die UNIBUS-Abbildung `mapalloc(bp)` entfaellt (die Mailbox-Uebergabe steht in `rkstart`).

### 2.2 dev0.c (Diskette `fd*`, Major 0 und cdevsw 10)

| Funktion | Kernel | Tokens | Gerippe-Gegenstueck (abgeleitet) | Aehnl. Text | Klasse |
|---|---|---|---|---|---|
| fdopen | 7E16 | 96 | `tmopen` | 5 % | angepasst |
| fdclose | 7E94 | 64 | `tmclose` | 10 % | angepasst |
| fdsub | 7F00 | 123 | `tcommand` | **62 %** | angepasst |
| fdstrategy | 7F94 | 57 | `tmstrategy` (Warteschlange) | 10 % | angepasst |
| fdstart | 7FDC | 480 | `tmstart` + EOF-Zweig von `tmstrategy` | 13 % | angepasst |
| fdintr | 821A | 448 | `tmintr` | 8 % | angepasst |
| fdadj | 8468 | 81 | keins (Blocknummer nach Suchfehler) | 4 % | neu |
| fdread, fdwrite | 84E4, 851C | 27 + 27 | `tmread`, `tmwrite` | 13 % / 8 % | angepasst |
| fdphys | 8554 | 54 | `tmphys` | 11 % | angepasst |
| fdioctl | 85B0 | 307 | BSD `tmioctl` (2.9BSD/4.1BSD-Fassung) | 12 % (Ultrix-11) / 35 % (`tsioctl`) | angepasst |

11 Funktionen, 1 764 Tokens.  Die Einstufung "angepasst" beruht **nicht** auf dem Token-Mass (das liegt bei 4-13 %, `fdsub` 62 %), sondern auf den Belegen in Abschnitt 4.4; sie ist deshalb "wahrscheinlich", nicht "sicher".
`dev0.c` wird im Original ohne Optimierer uebersetzt, steht nicht im Rundlauf (nur Gesamtbau, `dev0.md`).  `fdintr` ist ueber die Vektortabelle erreichbar (`low.s` L0276, Abschnitt 3.5), hat aber keinen Aufruf in der Aufrufkarte.

### 2.3 tty.c (Mailbox-Terminal `tc*`, cdevsw 0)

| Funktion | Kernel | Tokens | V7-Gegenstueck | Aehnl. V7 / Hippe | Klasse |
|---|---|---|---|---|---|
| tcopen | 60CC | 141 | `klopen` | 29 % / **44 %** (Nijmegen 38 %) | angepasst |
| tcclose | 616C | 18 | `klclose` | 62 % | angepasst |
| tcread, tcwrite | 618E, 61B0 | 14 + 14 | `dcread` (Huelle) | 33 % | angepasst |
| tcxint | 61D2 | 44 | `dcxint` | 53 % | angepasst |
| tcrint | 620E | 26 | `klrint` | 39 % | angepasst |
| tcioctl | 623C | 30 | `klioctl` | 67 % | angepasst |
| ttstart | 6274 | 203 | `klstart`/`dzstart` (Rolle `t_oproc`) | 22 % / 26 % | ersetzt |
| ttxfer | 633A | 66 | keins | 8 % | neu |
| putchar | 6384 | 167 | `kl.c:putchar` (Register-Spinloop) | 10 % | ersetzt |
| ttyinit | 6432 | 16 | keins | 9 % | neu |

11 Funktionen, 739 Tokens.  Die allgemeinen `tt*`-Routinen (`tty2.c`, 20 Funktionen, 3 909 Tokens) gehoeren zur V7/Hippe-Zeilendisziplin (`fremd.md` 8) und sind nicht mitgezaehlt.

### 2.4 lp.c (Drucker, cdevsw 5)

| Funktion | Kernel | Tokens | V7/Hippe-Gegenstueck | Aehnl. Hippe / SysIII / 2.9BSD | Klasse |
|---|---|---|---|---|---|
| lpopen | 6444 | 114 | `lpopen` | 25 % / 25 % / 11 % | angepasst |
| lpclose | 64DA | 124 | `lpclose` | 14 % / 18 % / 11 % | angepasst |
| lpwrite | 6570 | 247 | `lpwrite` | 29 % / 29 % / 31 % | angepasst |
| lpcanon | 6668 | 398 | Hippe/SysIII `lpoutput` (2.9BSD `lpcanon`) | 32 % / 32 % / 27 % | angepasst |
| lpoutput | 680E | 89 | Rolle von `lpint` (Zeichen aus Warteschlange zum Geraet) | 9 % | ersetzt |
| lpintr | 6874 | 148 | `lpint`/`lpintr` | 12 % | ersetzt |
| lpxfer | 690A | 69 | keins | 9 % | neu |

7 Funktionen, 1 189 Tokens.  Der V7-Baum hat kein `lp.c` (`ls original/unix-v7/usr/sys/dev`); die Familie steht in System III, Hippe-Sammlung, Nijmegen, 2.9BSD, Interdata.

### 2.5 bio.c und Assembler (Uebergabe an die U880-Seite)

| Funktion | Kernel | Tokens | Klasse |
|---|---|---|---|
| mapalloc | 5CAE | 38 | neu (V7 `mapalloc` = UNIBUS-Abbildung, anderer Zweck) |
| mapstart | 5CF6 | 73 | neu |
| iodone | 5C62 | 36 | unveraendert gegenueber System III (V7 hat `B_MAP`/`mapfree`), nicht mitgezaehlt |
| `mapaddr` | `low.s` L065E (`_mapaddr` 065E) | 7 Befehle | neu (Tuerklingel, Abschnitt 3.3) |

### 2.6 Summen (nur Mailbox-Treiber: rk-Teil 386, dev0 1 764, tty 739, lp 1 189, mapalloc/mapstart 111 = 4 189 Tokens)

| Klasse | Funktionen | Tokens | Anteil an 4 189 | Anteil am Kernel-C (28 933) |
|---|---|---|---|---|
| unveraendert | 2 | 28 | 0,7 % | 0,1 % |
| angepasst | 23 | 3 078 | 73,5 % | 10,6 % |
| ersetzt | 5 | 717 | 17,1 % | 2,5 % |
| neu | 8 | 366 | 8,7 % | 1,3 % |
| **gesamt** | **38** | **4 189** | 100 % | **14,5 %** |

Reproduktion der Tokenzahlen (laufen aus dem Repo, nichts wird geschrieben):

```
python3 -I SCR/h8/tok.py                       # Tokens je Funktion in rk, dev0, tty, lp, bio, tty2
python3 -I tools/herkunft/speicher.py total    # MUTOS kernel/c (227, 28933), V7 sys (165, 21485), V7 dev (234, 28476)
```

**Textmass zum Vergleich:** Funktionen mit Aehnlichkeit >= 40 % gegen irgendeine Vorlage: `rkstrategy` 86, `rkread`/`rkwrite` 28, `tcopen` 141, `tcclose` 18, `tcxint` 44, `tcioctl` 30, `fdsub` 123 = 470 Tokens = **11,2 %**.
Das Textmass unterschaetzt hier systematisch: es erfasst keine umgeschriebenen Gerippe (Abschnitt 4.4).

## 3. Das Mailbox-Protokoll (Rekonstruktion)

### 3.1 Datenstruktur

Eintrag `struct rkmbx`, 14 Byte (`kernel/h/mbx.h`; Gegenprobe U880-Seite `analyse.md` Abschnitt 3):

| Off. | Feld | Kernel schreibt | U880 (`mutosio.mac`) |
|---|---|---|---|
| +0 | `mb_cmd` | 2 x Klasse: 0 Platte, 2 Drucker, 4 Terminal, 6 Floppy | waehlt Beschreiber `A405 + 4*Klasse` (Handlertabelle) |
| +1 | `mb_unit` | Einheit (Minor; Drucker: dev; Konsole 0) | Bitnummer in den Masken, Index im Handlertabelle; Platte: `TAB_RK_LAUFWERK[minor]` (Bedienmaske) |
| +2 | `mb_dir` | 0 lesen, 1 schreiben; Konsole 01H oder **81H**; Floppy: Controllerbefehl (25H 27H 45H 47H 51H 61H, 6) | Bit 7 = "ohne Interrupt"; `&7F`: 0/1 -> UDOS-Nukleus 0BH/0FH (`PLATTE`), Floppy: Befehlstabelle `TAB_KMD` |
| +3 | `mb_stat` | 0 (laeuft) | schreibt Ergebnis: 1 gut, >= 40H Fehlercode des Nukleus bzw. C1/C2 (Floppy-Zeit) / F1..F8 (Floppy-Fehlerbits), FFH Terminal-Eingang |
| +4 | `mb_seg` | `b_xmem` (rk), `b_xmem & 3` (fd), 0 (tty, lp) | nur Bits 0-1 zaehlen (Port-B-Segmentwahl `48H+n`) |
| +6 | `mb_addr` | Pufferadresse im Segment | Offset im EM |
| +8 | `mb_cnt` | Zaehlung in Byte | schreibt die uebertragene Zahl zurueck |
| +A | `mb_blk` | Blocknummer (32 bit) | nur die unteren 16 Bit benutzt (`IX+18/19`) |

Orte der Eintraege (**gemessen**, `rk.c`, `tty.c`, `lp.c`, `dev0.c`, `mbx.h`): Platte `D532` (fest, `MBX`), Terminal `ttyhw[4]` ab `D26A` (14 Byte je Leitung, Ausgabepuffer `ttyobuf[4][80]` ab `D2A2`),
Drucker `lpmbx[2]` ab `D516` (Puffer `lpbuf[2][128]` `D416`), Floppy `fdmbx` `D558`.  Die Eintraege liegen lueckenlos hintereinander (D516 + 2 x 14 = D532).
Der Kernel-Zeiger auf den Eintrag steht im **Wort an Adresse 6** (`mapstart`: `*(int *)06 = bp`); die U880-Seite liest es als EM-Adresse `4006H` (`analyse.md` Abschnitt 3, gemessen 94C1..94D5).

### 3.2 Ablauf Anforderung -> Fertigmeldung (gemessen/abgeleitet)

1. Treiber (`rkstart`, `ttxfer`, `lpxfer`, `putchar`, `fdstart`) fuellt den Eintrag, `mb_stat = 0`, und ruft `mapalloc(mp, n)` mit `n = mb_cmd` (gemessen im Quelltext; `n >> 1` ist der Slot in `mapq[4]`).
2. `mapalloc` (5CAE): wartet, bis der Slot `mapq[n>>1]` frei ist (`mapstart` anstossen, wenn nicht gerade aktiv), traegt `bp` ein, startet `mapstart`.
3. `mapstart` (5CF6): `mapbusy++`; schleift ueber `mapq[0..3]`; fuer jeden belegten Slot: **wartet, bis Wort 6 == 0** (die U880-Seite hat den vorigen Zeiger abgeholt und `(4006) = 0` gesetzt), schreibt `bp` in Wort 6, ruft `mapaddr`, leert den Slot; wiederholt, bis nichts mehr in der Schlange ist.  Damit ist die Uebergabe auf **einen Zeiger gleichzeitig** serialisiert; vier Klassen koennen gleichzeitig ausstehen, aber nie zwei Eintraege derselben Klasse (der Slot ist je Klasse einzeln).
4. `mapaddr` (`low.s` L065E, **gemessen** im Disassemblat): `ld r6,L8DC2; ld r7,r6; or r7,#10h; out 80h,r7; nop; out 80h,r6; ret`.  Das ist ein Puls auf Bit 4 des Ausgabeports 80H = das Signal "INT-16" an die U880-Seite (`analyse.md` Abschnitt 3: "setzt A33 Bit 4 (INT-16)"; die Zuordnung Bit 4 = INT-16 ist **abgeleitet**).  `L8DC2` ist die Schattenkopie des Ports (beim Start `00C7`).
5. U880: Interrupt 94C1 holt den Zeiger aus EM `4006H`, kopiert die 14 Byte in den DCB (`DCB+6`), setzt das Anforderungsbit der Klasse (Maske `A405+4k`), bei Schreiben holt sie die Daten sofort EM -> Z80-Puffer; die Hauptschleife (9014) ruft den Handler (Platte 90EB -> UDOS-Nukleus 0BFDH/0700H, je 128-Byte-Sektor, Drucker 91A8 -> 0EB00H, Konsole 9208 -> 0BEBH, tty1..3 9D57..).
6. Fertig: Handler setzt das Fertigbit; die Schleife (903D..90B7) schreibt bei Lesen die Daten Z80-Puffer -> EM, **dann `mb_stat` (+3) und `mb_cnt` (+8/+9) in den Eintrag im EM**, und loest den Vektor aus (`OUT (ADH),Vektor`).  Zugestellt wird nur, wenn die Ebene des Z8000 kleiner ist als die Schwelle im DCB (Platte 5, Drucker 4, Floppy 5, Konsole/tty 4) oder Bit 7 gesetzt ist (dann gar kein Vektor).  Der Status steht **im Eintrag, nicht in einem Register** (gemessen, `analyse.md` Abschnitt 1.2).
7. Kernel: Vektor -> Handler (3.5) -> `rkintr`/`lpintr`/`tcxint`/`fdintr` liest `mb_stat`/`mb_cnt`.

Eine zweite Anforderung derselben Klasse, solange die erste laeuft, wird nicht vom Kernel verhindert, sondern von den Treibern: `rk_busy`/`b_bcount` (rk, fd), `mb_stat == 0` (tty `ttstart` kehrt zurueck, solange der letzte Auftrag laeuft), Flag `0x80` (lp).  Die U880-Seite hat als Notnagel `RST 38H` und den Ersatzpfad `951C..9534` (nie gelaufen, `analyse.md` Abschnitt 9).

### 3.3 mb_seg / b_xmem und Puffer

* Der Kernel liegt in Segment 0, ein Prozess in Segment 1..3 der EM256 (`speicher.md`).  `physio` setzt `b_xmem = (usrseg >> 8) & 0377` (bio.c 744), `swap` setzt `b_xmem = (coreaddr >> 8) & 0177` (bio.c 586): beides ist die **Segmentnummer des Benutzerprozesses**; Puffer des Buffer-Cache liegen im Kernelsegment 0.
* `rkstart` uebergibt `mb_seg = b_xmem` unbeschnitten, `fdstart` `b_xmem & 3`, `ttxfer`/`lpxfer`/`putchar` immer 0 (Ausgabepuffer sind Kernelspeicher).  Die U880-Seite wertet nur die unteren 2 Bit aus (`analyse.md` Abschnitt 3: "nur Bits 0-1 zaehlen") und schaltet die Segmentwahl ueber Port B (`48H + n`, "Bus anfordern").  Der DMA-artige Zugriff der U880-Seite auf den Z8001-Speicher laeuft also ueber die Bus-Anforderung, nicht ueber eine Kernel-Kopie.
* Platte: Puffer des Z80 4 KB (Obergrenze 1000H, `RST 38H` darueber, gemessen nie ausgeloest).  Terminal und Drucker: 128-Byte-Puffer je Einheit auf der Z80-Seite; die Kernel-Seite sendet hoechstens 0x50 (tty) bzw. 0x80 (lp) Byte je Auftrag.

### 3.4 Wiederholungen, Fehler, Blockgrenze

| Treiber | Fehlererkennung | Wiederholungen | Fundstelle |
|---|---|---|---|
| rk | `mb_stat != 1`; `0xC8` -> `b_error = ENXIO` sofort; sonst `deverror(bp, mb_dir, mb_stat)` | `++rk_errs > 3` -> `B_ERROR`: bis zu **3 Wiederholungen** (V7: 10) | `rkintr` 6BCA |
| fd | `mb_stat != 1`; F5 (Suchfehler) -> `fdadj`; F6 beim Lesen roh = gut; sonst `printf("tm%d: bn = %d ...")` | `++fdtab.b_resid < 7` -> neu starten: **6 Wiederholungen** (V7 `tm.c`: 1) | `fdintr` 821A |
| lp | `mb_stat != 1` | `++l_err <= 10` -> `lpxfer` erneut: **10 Wiederholungen**, dann `u.u_error = EIO` | `lpintr` 6874 |
| tty | keine Auswertung von `mb_stat` ausser als "Auftrag laeuft" | -- | `ttstart` 6274 |

* Status `0xC8` ist der UDOS-Fehlercode "DISK INITIALIZATION ERROR C8" (`doc/referenz/udos_diskettenformat.md`, Rueckseitenlaufwerk ohne Dateisystem): Bit 6 gesetzt, `PLATTE_FERTIG` reicht den Nukleus-Statusbyte unveraendert durch (`mutosio.mac`, `PF_STATUS`); "Einheit fehlt" ist die Lesart von `c_rueckbau.md`, am Gast nicht ausgeloest (**angenommen**).
* Blockgrenze `0x260 = 608` Bloecke (`rkstrategy`): 76 Spuren zu 8 Bloecken, passt zur Geraetegroesse (`c_rueckbau.md`); `mb_blk` ist 32 bit breit, die U880-Seite nutzt nur 16 Bit (`analyse.md` Abschnitt 12, abgeleitet).
* Blockabbildung: die Nukleus-Schnittstelle kennt 128-Byte-Sektoren (Variante `K8X512`: 512); `SEKTOR_BERECHNEN` wandelt Block -> (Zylinder, Sektor); je Auftrag mehrere Sektoraufrufe mit Rueckruf `9893` (744 Aufrufe im Boot, `analyse.md` Abschnitt 5).

### 3.5 Zusammenspiel mit den V7-Schnittstellen

* **Vektortabelle** (`kernel/asm/ref/low.s`, PSA ab L0000, **abgeleitet** aus der Tabellenposition; fuenf Treffer bestaetigen den Index = Vektor/2 gegen die gemessenen DCB-Vektoren aus `analyse.md`):

  | Vektor (U880, DCB+0) | PSA-Wort | Handler | Bedeutung |
  |---|---|---|---|
  | 02H | 0060 | `clock` | Zeitgeber 50 Hz (Ebene 6) |
  | 0AH | 0050 | `rkintr` | Platte (Ebene 5) |
  | 12H | 0040 | `lpintr` | Drucker (Ebene 4); 14H..18H: 0041..0043 |
  | 1AH | 0050 | `fdintr` | Floppy (Ebene 5) |
  | 22H | 0040 | `tcrint` | Tastenzeichen (Ebene 4) |
  | 24H | 0040 | `tcxint` | Konsole Ausgabe fertig; 26H/28H, 2AH/2CH, 2EH/30H: tty1..3 (0041..0043) |

  Das PSA-Wort (0060/0050/0040) entspricht der Ebenenschwelle im DCB (6/5/4); die Ziffer 1..3 bei den Mehrfacheintraegen ist die Leitungsnummer.  Alle uebrigen Eintraege fuehren auf `trap` (`L024E`).
* **bdevsw/cdevsw** (`kernel/conf/conf.c`): `bdevsw[0] = {fdopen, fdclose, fdstrategy, &fdtab}`, `bdevsw[4] = {rkopen, rkclose, rkstrategy, &rktab}`; `cdevsw[0] = tc*`, `[2] = mm*`, `[5] = lp`, `[10] = fd raw`.  Form wie V7 `c.c`, nur die Zeilen sind andere.
* **Warteschlange und iodone:** `rk` und `fd` fuehren die V7-Kette (`b_actf/b_actl` bzw. `av_forw/av_back`), beenden mit `iodone` (5C62, = System III), `b_error`/`B_ERROR` wie V7; `physio` (bio.c) ist V7 mit Z8001-Segment.  `rk_busy` und `b_bcount` ersetzen `d_active` (kein UNIBUS-`B_MAP`).
* **tty:** `t_hwp` (+38) zeigt auf den Eintrag `ttyhw[d]`, `t_oproc = ttstart`, `t_obuf` (+12) auf `ttyobuf[d]`, `t_ocnt` (+36) die Laenge; `ttxfer` ruft `mapalloc(hp, 4)`; Rueckkehr ueber `tcxint` -> `ttkick` -> `ttstart`.  `tcrint(dev, ch)`: das Zeichen wird als `ch >> 8` entnommen und an `ttyinput` gegeben; dass es das ACH-Datum der U880-Seite ist (`analyse.md` Abschnitt 4), ist **angenommen**.
* **Konsole `putchar` (6384):** schreibt jedes Zeichen zuerst in den Ring `conlog` (8DE8..8E68), wartet bis zu 10 000 Schleifen auf `ttyhw[0].mb_stat != 0`, sendet dann mit `mb_dir = 0x81` (**ohne Interrupt**, die U880-Seite quittiert ohne Vektor), ruft `mapalloc(hp, 4)`, wartet erneut (`putchar(0)`) und **setzt `mb_stat = 1` selbst**, auch bei Zeitablauf.  Zweck: Meldungen des Kernels vor Interruptfreigabe und aus dem Interrupt (`spl7`), ohne den Vektorweg.
* **lp:** Flag `0x80` Ausgabe laeuft, `0x40` Schlaf; Rueckkehr ueber `lpintr` -> naechster Zeilenpuffer (`lpoutput`) oder Schlaf wecken.

### 3.6 Abgrenzung der Aufgaben

| Aufgabe | Z8001-Kernel | U880-Teil `mutos_io` |
|---|---|---|
| Puffercache, Warteschlange, `physio`, Swap | ja (V7/Hippe-Struktur) | nein |
| Zeilendisziplin (`tty2.c`), Zeichenumsetzung `lpcanon` | ja | nein (nur Tastenabfrage, Tabelle 9755, SIO-Paritaet) |
| Blockgrenze, Wiederholungen, Fehlermeldung | ja | nein |
| Block -> Zylinder/Sektor, Minor -> Laufwerk (Bedienmaske), 128-/512-Byte-Zerlegung | nein | ja |
| Plattenzugriff, Drucker- und Konsolenausgabe, SIO | nein | ja (UDOS-Nukleus 0BFDH/0BEBH/0EB00H, SIO-Kanal A 50H/51H) |
| Segmentwahl und Datenkopie EM <-> Z80 | gibt `b_xmem`/Adresse vor | fuehrt die Kopie aus (Bus anfordern) |
| Zeitgeber 50 Hz, Tastatur (Abfrage im Zeitgeber-ISR) | Vektor -> `clock`/`tcrint` | erzeugt Tick und Zeichen |
| Floppy-Controller | Befehle 25H 27H 45H 47H 51H 61H | Klasse 3 (9A00/9B00) spricht Port 1CH; am A5120 **nicht belegt**, im Betrieb nie benutzt, Geraeteknoten fehlt (`analyse.md` Abschnitt 8) |

Folgerung: die Floppy-Kette Kernel -> Mailbox -> U880 ist in beiden Teilen vorhanden, aber **nicht im Gast ausgefuehrt** (gemessen: nie gelaufen); ihre Tauglichkeit ist offen.

## 4. Vorlagensuche

### 4.1 Quellen und Pruefsummen

Gesamt-Tarballs: `SCR/h6_sha256.txt`, Basis-URL `https://www.tuhs.org/Archive/Distributions/` (siehe `fremd.md` 2 und 8.2b); einzeln verglichene Dateien (SHA-256):

| Kuerzel | Pfad / URL (Basis `https://www.tuhs.org/Archive/Distributions/`) | SHA-256 |
|---|---|---|
| v7 (Tarball) | `Research/Henry_Spencer_v7/v7.tar.gz` | `e0fd7bdd046e17de177f5d997acf8123fa43c57b46b032c7337f7666ab69a07e` |
| v7 `rk.c` | `original/unix-v7/usr/sys/dev/rk.c` | `23e07b7452be64a50fed8df8b4ea359fbce67017b6a494406d7569d7b0109177` |
| v7 `kl.c` | `original/unix-v7/usr/sys/dev/kl.c` | `b76f9e52a01c26912d2052562c56302f73fa5a3639b6955f3e2b4b3da86712fd` |
| v7 `tm.c` | `original/unix-v7/usr/sys/dev/tm.c` | `459be6f00243bb1fa5f25b40bd134c5a681e4ef5a9564d56bf0f902bdeadd009` |
| hippe (Tarball) | `Research/Torsten_Hippe_v7/v7.tar.gz` | `b960f8de80331f106e459ec046ceb4383edbdaa3db044eab557a3ce4a4db4a5e` |
| hippe `lp.c` | `usr/sys/dev/lp.c` | `a5bc7544cb099e71fa9ba1b4ba38763a299db828dca9cc3a2977944cde9f8567` |
| hippe `rk.c` | `usr/sys/dev/rk.c` | `9bfe582b6bdc9d9c88cafc5ca0cf641e10ec13af7ea6018e032bf28f8261914e` |
| hippe `kl.c` | `usr/sys/dev/kl.c` | `e74bce1ba0f79c359f008c588846727da5135035c8dfe32ab9d1a6996176737a` |
| hippe `tm.c` | `usr/sys/dev/tm.c` | `695fc4d60043d5a7874288ecbacf13bf20ca3c261efc3a3da962cbe1ab42f8d1` |
| nij (Tarball) | `Research/Nijmegen_v7/nijmegen_v7kernsrc.tar.gz` | `acb2089eeb5fa2b61311d601673a0970e10fdc365d1144812f4b9e877b0cbc69` |
| nij `lp.c` | `sys/dev/lp.c` | `62fb9f0a73640aab17852079a639aa033b5cdbca3ea65a35c864d36a6bb3b4f3` |
| sys3 `lp.c` | `original/sys3/uts/pdp11/io/lp.c` | `8116d0778d07c017779a44adb6a58004e894ab9fc8f6899e3d09724ae495b363` |
| 2.8bsd (Tarball) | `UCB/2BSD/2.8bsd.tar.gz` | `b274e33f190c2aea81a8a690e32958e3c1d3afc474d730449fed7b612590dc13` |
| 2.8bsd `tm.c` | `usr/kernel/sys/dev/tm.c` | `881320c52e3c69330c10b54d0712fb4ba7edc0c1bc231d4d09cfb53d82adf338` |
| 2.9bsd (Tarball) | `UCB/2BSD/2.9BSD/usr.tar.gz` | `f2b0ad29bd71991dc682f3ce6dc507e4cf3c3327d8e8315a438fa6235ef7b2ef` |
| 2.9bsd `tm.c` | `src/sys/dev/tm.c` | `3d0d0fa4aa900887ec1d4e63a3dde4e37f9b6756efeac67c034e811dac6abf19` |
| 2.9bsd `lp.c` | `src/sys/dev/lp.c` | `1f7fec63989a92d581889ff407d74192c6bc95701c17d9ed350ab6a306bd6ac5` |
| 2.9bsd `mtio.h` | `include/sys/mtio.h` | `a0f7e24e15a5853f8f32cc1dba57f951b237bcb7de91b6806a30702bb4ec1f92` |
| 2.11bsd (Tarball) | `UCB/2BSD/2.11BSD-pl195.tar` | `f95bee3dc2618c21ebf9b79557c63a0fbcd4b945807f3d90849916d542c6cfd9` |
| 2.11bsd `lp.c` | `sys/pdpuba/lp.c` | `a01ae2032f708aa4e33cd961854035c4107827574bb58f03b824983846e9d958` |
| 4.1bsd (Tarband) | `UCB/4BSD/4.1BSD-19810901-reconstructed/tape1.tap.xz` | `0c840a3be8f6d18d11077a3c15365b7c962f7c9d82ec898e8c21bf9c4802bbbc` |
| 4.1bsd `mtio.h` | `sys/h/mtio.h` | `e15cf89868f9171b1fad7a47fe03b0766a7cd7492d71cc92df7b271d58a99c34` |
| ux11 (Tarball) | `DEC/Ultrix-11/Ultrix-3.1-src/ultrix11-src.tar.gz` | `46ffac3f2649adb59e11d0f8c2f12da5c70c6e3fc498855616f5e5bb029971f7` |
| ux11 `tm.c` | `sys/dev/tm.c` | `87654c57c24a0d41964c419650ce3b45ca3d67581ab3350b21c6e46abcb4d602` |
| interdata (Tarball) | `Other/Interdata/interdata_v6.tar.gz` | `3c47fb35d9da5ed7c5b47b37adfa671a097849f318d258a0459e8c71a52f7a7d` |
| interdata `lp.c` | `usr/sys/lp.c` | `c3f517368d0fa0a095a2f6864d2a959591c39de8e71e82cfc0a1373daf25ceea` |
| wega | `git clone https://github.com/OlliL/P8000`, Commit `626fc77fb083b31392ccafb0d125bbc2c8127d4a` | -- (Git-Baum) |
| wega `fd.c` | `WEGA/src/uts/dev/fd.c` | `fe4a38ac769f11513be067cdce7f41384d1fc5eea21f64c919c3cc15f3101be1` |
| wega `koppel.s` | `WEGA/src/uts/dev/koppel.s` | `76a52850c6e5d15d8b57c973e6ffcccb15d03860c2aa8e18ea189f615a7ed896` |
| wega `lp.c` | `WEGA/src/uts/dev/lp.c` | `860c0126c1f0565d35bf08865a6c6b00ff01aa63bba45dabd253cf1d5915931e` |
| wega `mt.c` | `WEGA/src/uts/dev/mt.c` | `9a5ae2d52c71fa9ac5bb4c427a444093a1538e2a244ec6a8e07333316550834e` |
| A5120.16 | `~/projects/A5120.16/docs/rfe83-10-629ff-16BitZRE-KartezumK1520.txt` | `26e4b7f60a1e8f8148282ca3e490b33c12e50fd10b88251b4a066683b3e0133d` |

Tarball-Pruefsummen: `SCR/h6_sha256.txt`; Dateiwerte mit `sha256sum` aus den entpackten Baeumen gebildet.

Befehle (alle lesen nur):

```
SCR=/tmp/claude-1000/-home-olliy-projects-mutos8k/9fec9724-1e2d-4a7c-841d-7f8cfc3a3344/scratchpad
python3 -I tools/herkunft/herkunft.py compare kernel/c/dev0.c --level abs --top 3 \
   --ref v7=original/unix-v7/usr/sys/dev hippe=$SCR/h6_hippe/usr/sys/dev b29=$SCR/h6_2.9bsd_usr/src/sys/dev \
         wega=$SCR/h6_wega/P8000/WEGA/src/uts/dev sys3=original/sys3/uts/pdp11/io        # ebenso rk.c, tty.c, lp.c
sha256sum $SCR/h6_hippe/usr/sys/dev/tm.c $SCR/h6_2.9bsd_usr/src/sys/dev/tm.c ...
```

Ausgewertet wurden 11 Referenzbaeume fuer die Treiberdateien (V7, Hippe, 2.8BSD, 2.9BSD (+net), 2.11BSD, Ultrix-11, 4.1BSD, System III, WEGA, Interdata, Nijmegen); `rg -l 'mb_cmd|mb_unit|rkmbx|mailbox' h6_* h7` fand in den Baeumen nur WEGA-`contrib/K5JB` (Amateurfunk-Software, `ax_mbx`), also **keinen** Treffer fuer einen Mailbox-Treiber.

### 4.2 rk: Vorlage ja

V7 `rk.c`/Hippe `rk.c` (Nijmegen gleich): `rkread`/`rkwrite` 100 % (14 Tokens), `rkstrategy` 42 % V7 / 50 % Hippe, `rkintr` 24 %, `syopen`..`sysioctl` 100 %.  Das Gerippe (Queue, `spl5`, `deverror`, `iodone`, Wiederholungszaehler) ist V7.
Hippe ist bei `rkstrategy` naeher als V7 (50 gegen 42 %), in den uebrigen Funktionen gleich.  `rkstart`, `rkopen`, `rkclose`: keine Vorlage; WEGA `usr1close`/`u1open` (25 bis 100 % auf Einzeiler) sind Zufallstreffer.  WEGA `sys.c`/Interdata `dsk.c`: unter 15 %.

### 4.3 tty und lp

* **tty:** `tcopen` 44 % Hippe-`klopen` (V7 29 %, Nijmegen 38 %); `tcclose`/`tcxint`/`tcioctl` 53-67 % gegen V7-`kl.c`/`dc.c`-Huellen.  Das ist "allgemeine Routine mit richtiger `tty`-Struktur aufrufen" (`tty.md`), kein Herkunftsbeleg im Einzelnen, aber die Huelle ist die V7-Zeilentreiberform.
  `ttstart` 22-26 % (`klstart`, `dzstart`), `putchar` 6-14 % (alle Baeume): Rumpf eigen.  WEGA `ttydev.c`/`siok.c`: 0-20 %, Interdata `vdu.c`/`cli.c`: 0-24 %.
* **lp:** `lpopen` ist bis in die Konstanten die Hippe-/Nijmegen-/System-III-Funktion: `unit >= lp_cnt || unit >= LPMAX || flag` ~ `d >= nlp || d >= 2 || l_flag`, `flag = (dev & 077) | OPEN` ~ `(dev & 0x3F) | 8`, `ind = 4`, Spalten 80 (MUTOS 0x84 = 132), Zeilen 66 (MUTOS 0x42 = 66), anschliessend Seitenvorschub `FORM`;
  `PRILP 33 = PZERO + 8` mit `PZERO 25` (`param.h`) ~ `LPPRI (PZERO+8)`; Flagwerte 8/0x10/0x20/0x40 = `OPEN` 010, `CAP` 020, `NOCR` 040, `ASLP` 0100 (oktal) mit zusaetzlichem `0x80` (Ausgabe laeuft) und `4` (roh).
  `lpcanon` hat dieselbe Verzweigung wie Hippe-/SysIII-`lpoutput` (`CAP`-Tabelle `{ } ` | ~` mit `esc:`-Rekursion und `ccc--`, `\t` -> `((ccc + 8 - ind) & ~7) + ind`, `\n` -> `mlc++ ... FORM`, `\b`), nur Felder umbenannt und die Pufferung ueber `putc`; der Name `lpcanon` und die Funktion `lpwrite` mit `fubyte`-Schleife stehen auch in 2.9BSD/2.11BSD (27/26 %), nicht in Hippe/SysIII.
  `lpoutput` (Zeilenpuffer fuellen), `lpintr` (Wiederholung bis 10, Schlaf wecken), `lpxfer`: eigen.  WEGA `lp.c` 7-16 %, Interdata `lp.c` 6-18 %: nicht die Vorlage.
  Revision zu `lp.md`: "eigen (Familie System III)" bleibt als Tokenbefund richtig, die Konstantenlage zeigt aber, dass **Hippe/Nijmegen-`lp.c` die naechste Vorlage** ist (Hippe `lpopen` mit `LPMAX`, `lp_cnt`, `col = 80`, `line = 66`; SysIII hat `lpopen(dev, mode)` ohne diese).
  Nicht entscheidbar, ob direkt Hippe oder die gemeinsame Vorlage (Abschnitt 8 `fremd.md`).

### 4.4 fd (dev0.c): Gerippe aus dem Magnetbandtreiber `tm.c`

Das Token-Mass findet keine Vorlage (Datei 10-18 %, Abschnitt 2.2).  Das Lesen der Funktionen gegen V7 `tm.c`, Hippe `tm.c` und 2.8/2.9BSD `tm.c` ergibt jedoch eine durchgehende Entsprechung; die Belege sind gemessene Gleichheiten von Konstanten und Folgen:

| Beleg (MUTOS `dev0.c`) | Entsprechung | Fundstelle |
|---|---|---|
| `fdtab.b_flags |= 0x400` | `tmtab.b_flags |= B_TAPE`; `B_TAPE` = `02000` = `0x400` (`kernel/h/buf.h`, V7 `buf.h`) | `fdopen`; V7/Hippe `tmopen` |
| Zustaende `b_bcount` = 1 (Suche) / 2 (E/A) / 3 (Befehl) | `SSEEK 1`, `SIO 2`, `SCOM 3` | `fdstart`; V7 `tm.c` |
| `(dev & 0x80) == 0` -> Befehl 51H (Rueckspulen) | `(minor(dev) & 0200) == 0` -> `REW` | `fdclose`; V7 `tmclose` |
| `flag == 2 \|\| ((flag & 2) && fp->fu_x1)` -> 61H | `flag == FWRITE \|\| ((flag&FWRITE) && t_flags&T_WRITTEN)` -> `WEOF` | `fdclose`; V7 `tmclose` |
| Anfangswert `fu_x6 = 0x7FFF`, `fu_blk = 0` | `t_nxrec = 65535`, `t_blkno = 0` | `fdopen`; V7 `tmopen` |
| `d >= 1 \|\| fu_flag` -> `ENXIO` | `unit >= NTM \|\| t_openf[unit]` -> `ENXIO` (NTM nur in Hippe) | `fdopen`; Hippe `tmopen` |
| `blkno == fu_x6 && B_READ` -> `clrbuf`, `b_resid`, fertig | `*p <= blkno ... if B_READ { clrbuf; b_resid = 0; iodone }` | `fdstart`; V7 `tmstrategy` |
| Vorwaerts-/Rueckwaertssuche 25H/27H mit Zaehler `blkno - lb` | `SFORW`/`SREV` mit `tmbc = *blkno - bp->b_blkno` | `fdstart`; V7 `tmstart` |
| `fdsub(dev, a, b)`: `B_BUSY`-Schleife, `bp->b_resid = a`, `bp->b_blkno = 0`, `iowait`, `B_WANTED` | `tcommand` (62 %) | `fdsub` 7F00 |
| `fdread`/`fdwrite`: `fdphys(dev); physio(fdstrategy, &rfdbuf, dev, ...)` | `tmread`/`tmwrite` mit `rtmbuf` | 84E4, 851C |
| `fdphys`: `lb = u.u_offset >> 9; fu_blk = lb; fu_x6 = lb + 1` | `tmphys`: `a = u.u_offset >> BSHIFT; t_blkno = a; t_nxrec = a + 1` | 8554 |
| `fdioctl`: Befehle `0x6D01` / `0x6D02` | `MTIOCTOP = ('m'<<8)\|1 = 0x6D01`, `MTIOCGET = ('m'<<8)\|2 = 0x6D02` (2.9BSD und 4.1BSD `mtio.h`) | 85B0 |
| `switch (lv[0])` 0..7 mit (n, x): 0 -> (cnt, 1); 1,2 -> (cnt, 0x7FFF); 3,4 -> (1, cnt); 5,7 -> (1, 1) | `MTWEOF` / `MTFSF,MTBSF` mit `INF` (2.8BSD 32760) / `MTFSR,MTBSR` / `MTREW,MTNOP` | `fdioctl`; 2.8/2.9BSD `tmioctl` |
| Tabelle `fdcmd[] = {0x61,0x45,0x47,0x25,0x27,0x51,6}` in der Reihenfolge der Bandoperationen | `static tmops[] = {WEOF,SFORW,SREV,SFORW,SREV,REW,OFFL,NOP}` ("we depend on the values and order of the MT codes") | `fdioctl`; 2.8/2.9BSD |
| `if ((op == 3 \|\| op == 4) && bp->b_resid) u.u_error = EIO`, `if (B_ERROR) break`, `geterror(bp)` | identisch in `tmioctl` | `fdioctl` |
| `copyout(info, arg, 16)` mit `info[0]=4`, `[1]=dsreg`, `[2]=erreg`, `[3]=resid` | `struct mtget { mt_type, mt_dsreg, mt_erreg, mt_resid, daddr_t x2 }` = 16 Byte (nur 2.9BSD-Fassung hat `mt_type`; 2.8BSD: 10 Byte); Typ 4 ist neu (1 TS, 2 HT, 3 TM) | `fdioctl`; 2.9BSD `mtio.h` |
| Meldungen `"tm%d: bn = %d ..."`, `"tmintr\n"` | Namensrest "tm" (Magnetband) in einem Diskettentreiber | `fdintr` |

* Mit **2.9BSD/4.1BSD** stimmen die Zahlenwerte von `MTIOCTOP`/`MTIOCGET` und das Layout von `mtget` mit `mt_type` ueberein; Hippe und V7 haben kein `tmioctl` (Hippe-`tm.c` hat keine ioctl-Routine, `v7addenda` nur einen leeren Stumpf).  Das passt auf ein 2.9BSD-nahes Band (Ultrix-11 `tm.c` traegt "add ioctl routine (from 2.9 BSD)"), ist aber **kein** Beleg fuer genau diese Quelle: 2.8BSD (CGL_MTOP), 2.9BSD, Ultrix-11 und 4.1BSD teilen die Form.
* Schluss (**abgeleitet**, wahrscheinlich): der Floppy-Treiber behandelt die Diskette wie ein Band (Block `fu_blk` als Bandposition, "Spur vor/zurueck" 25H/27H als Satzabstand, `fu_x6` als Dateiende, `fdioctl` als `MTIOCTOP`) und ist aus einem `tm.c` einer 2.9BSD-nahen Linie umgebaut, wobei die Registerzugriffe durch Mailbox-Befehle ersetzt und der Text stark umgeschrieben wurde (daher 5-15 % Textaehnlichkeit).
  Das korrigiert `dev0.md` ("Origin none", "Hinweis WEGA-fd-Muster nicht belegt"): die Herkunftsstufe `partial/Muster` ist angemessen; die WEGA-Hypothese bleibt widerlegt.
* Was **nicht** aus `tm.c` stammt: die Befehlscodes 25H/27H/45H/47H/51H/61H (Controllerseite der U880-Roh-Floppy, `TAB_KMD` 9B16: Befehl -> Maske -> Controllerbefehl; nicht in einer der durchsuchten Quellen), die Mailbox-Uebergabe, `fdadj`, die Statuswerte F1..F8.

### 4.5 WEGA (Z8001 mit eigener Hardware)

* `fd.c` (WEGA 3.2, 287 Zeilen): Funktionen `fdstrat`/`fdstart`/`fdint`/`fdread`/`fdwrite`/`fdioctl`; Auftraege werden nach `b_dev`/`b_blkno` einsortiert (Aufzugsstrategie), die MMU-Segmentbasis wird gesetzt (`loadsd`), dann `fd_disk(rw, dev, blk)` (`koppel.s`): Bytestrom ueber **PIO**: Kopf `'R'/'W'` + Floppytyp/Drive + Blocknummer + Laenge, Handshake ueber `PIO0D_B` Bits 5/6, Rueckgabewert `ACK = 6` als Interruptparameter.  Daten byteweise (`fdrint`).
* Unterschiede zu MUTOS: kein Speicher-Briefkasten und kein Zeiger-Wort, keine Klassen/Einheiten/Statusfeld im gemeinsamen Speicher, keine Wiederholungen im Kernel, keine `B_TAPE`/`tm`-Struktur; Funktionsaehnlichkeit `fdstrategy` 14 %, `fdstart` 23 % (gegen `mt.c`), `fdioctl` 27 %; `fdread` 47 % und `fdwrite` 40 % sind Zweizeiler gegen `mtread`/`mtwrite` (`tmphys; physio`) und sagen nur "gleiche V7-Idiome".
* Gemeinsam ist nur die **Idee** "16-Bit-Teil beauftragt den 8-Bit-Teil" (P8000-Architektur); ACK = 6 gegen `fdcmd[6] = 6` ist ein Zufall (in MUTOS ein Controllerbefehl).  **Vorlage: nein.**
* WEGA `lp.c` (7-16 %), `ttydev.c`/`siok.c` (0-20 %): nein.

### 4.6 UDOS, A5120.16, Zilog, Interdata, BSD-Plattentreiber

* `~/projects/UDOS`: UDOS-Quellen sind Z80-Bios und Floppytreiber (`PFLOPPY equ 0BFDH`, `README.md` Zeile 157); sie liefern die **Nukleus-Einspruenge**, die `mutos_io` ruft (0BFDH Platte, 0BEBH Zeichen, 0EB00H Drucker), kein Z8000-Protokoll (`rg -ic 'z8000|z8001|mutos'` ohne Treffer in den Quelldateien ausser `README.md`).  Die U880-Seite ist insoweit "Anwender" des UDOS-Bios, die Mailbox ist darueber gelegt.
* `~/projects/A5120.16/docs`: die Beschreibung der 16-Bit-ZRE-Karte (Z8001 fuer K1520, RFE 83) behandelt Hardware, nicht Software; kein Mailbox-/Nachrichtenfeld im Text (`rg -i 'mailbox|nachricht|4006'` ohne Treffer).
* Zilog-ZEUS, Onyx, Plexus, Coherent-Z8000: **nicht geladen/nicht gefunden** (wie `speicher.md` Abschnitt 10); fuer ein Mailbox-Protokoll ist keine Quelle bekannt.
* Interdata-V6 (`dsk.c`, `mt.c`, `lp.c`, `vdu.c`): nein (6-35 %, Einzeiler).  2.9BSD/2.11BSD Plattentreiber (`rl`, `hp`, `rk`): `rk` 23 % in `rkstrategy`, unter 20 % sonst.  2.11BSD `tmscp.c` (`fdsub` 73 % gegen `tmscpcommand`): Allerweltsmuster (Kommandopuffer-Warteschleife), kein Beleg.

### 4.7 Ergebnis je Treiber

| Treiber | Vorlage fuer das Gerippe | Vorlage fuer Hardware-/Protokollteil | Beleg |
|---|---|---|---|
| rk (`rk*`) | **ja**: V7/Hippe `rk.c` | nein | Abschnitt 4.2 |
| fd (`fd*`) | **ja, aber Magnetband**: `tm.c` + BSD-`tmioctl` | nein | 4.4 |
| tty (`tc*`, `ttstart`, `putchar`) | ja fuer die `tc*`-Huellen (`kl.c`); nein fuer `ttstart`/`putchar`/`ttxfer` | nein | 4.3 |
| lp | **ja**: Hippe/Nijmegen/SysIII `lp.c` fuer Aufbereitung und Flags | nein | 4.3 |
| mapalloc/mapstart/mapaddr, Mailbox | nein | nein | 4.1, 4.6 |
| mutos_io (U880-Seite) | nein (UDOS-Bios nur als Dienst) | nein | `analyse.md`, 4.6 |

## 5. Was gegenueber der V7-Treiberstruktur neu konstruiert wurde

* **Die Austauschstelle.**  V7-Treiber bestehen aus `xxstrategy` (Warteschlange) -> `xxstart` (Controllerregister programmieren) -> `xxintr` (Registerstatus lesen, `iodone`).  MUTOS hat dieses Tripel gelassen und nur den mittleren und letzten Schritt ausgetauscht: Register -> `struct rkmbx`, "Interrupt vom Controller" -> "Vektor der U880-Seite", UNIBUS-`mapalloc` -> eigenes `mapalloc/mapstart/mapaddr`.
* **Das Protokoll** (14-Byte-Eintrag, Klassen 0/2/4/6, Zeiger in Wort 6, Klingel Port 80H Bit 4, Status im Eintrag, Fertigmeldung nur ueber Vektor, Bit 7 = "ohne Interrupt", Ebenenschwellen) ist neu und in keiner Vorlage zu finden; es ist durch die Hardware (Bus anfordern, Segmentwahl, `/VI`, Ebenen) und die Dienste des UDOS-Nukleus vorgegeben, in der Ausgestaltung aber freie Konstruktion.
* **Serialisierung** (`mapq[4]`, `mapbusy`, Wortzeiger als Einzelplatz) und der **Konsolenpfad** (`putchar` mit Ring, `0x81`, erzwungenes `mb_stat = 1`) sind neu.
* **Beibehalten** wurde die gesamte Schnittstelle nach oben: `bdevsw`/`cdevsw`-Zeilen, `b_actf`/`av_forw`, `iodone`, `b_error`/`B_ERROR`, `physio`, `tty`-Struktur und `t_oproc`, `ttyinput`/`ttread`/`ttwrite`/`ttioctl`; `t_hwp` (+38) und `t_hwf` (+3A) sind die neuen Strukturfelder (`kernel/h/tty.h`).
* **Ungewoehnlich gegenueber V7:** der Fehlerpfad zaehlt Wiederholungen je Treiber verschieden (3, 6, 10), die Diskette ist als Band modelliert, die Platte hat eine Blockgrenze 608, alle Treiber teilen eine Klingel und einen Zeiger.

## 6. Bewertung des Eigenanteils (mit Zahlen)

**Zwei Zaehlweisen:**

| Mass | Eigenanteil im Sinn von | Tokens (von 4 189) | Anteil am Kernel-C (28 933) |
|---|---|---|---|
| Struktur, enge Zaehlung | **neu + ersetzt** (kein V7-Text, kein V7-Rumpf) | 1 083 (25,9 %) | **3,7 %** |
| Struktur, Mitte | neu + ersetzt + angepasste Funktionen mit Textaehnlichkeit unter 25 % (`fd*` ohne `fdsub` 1 560, `lpclose` 124) | 2 767 (66,0 %) | 9,6 % |
| Text, weite Zaehlung | alles unter 40 % Funktionsaehnlichkeit | 3 719 (88,8 %) | **12,9 %** |

Dazu kommen **ohne Vergleichsbasis** die U880-Seite (`mutosio.mac`, 2 032 Zeilen Z80-Quelltext, 5 376 Byte, **100 % eigen** im Sinn von "keine C-Vorlage", aber auf UDOS-Nukleus-Aufrufen aufgebaut), `mapaddr`, die Vektortabelle (gemessen) und die Datenobjekte (`ttyhw`, `lpmbx`, `fdmbx`, `rktab`...).

**Wertung (Stufen wie in `speicher.md` Abschnitt 8):**

* Kernel-Treiber (`rk`, `lp`, `tty`-Huellen): **(ii) Anpassung** der V7-/Hippe-Struktur an ein vorgegebenes Hardwaremodell; die Anpassung ist stellenweise (Blockgrenze, Wiederholungen, Status) Konfiguration, nicht Konstruktion.
* `fd*`: **(ii) Anpassung eines Bandtreibers**; die Leistung liegt im Abbilden von Band-Semantik auf eine Diskette ueber eine Befehlsschnittstelle (25H/27H/51H/61H) und im Nachweis, dass die Zustandsmaschine das traegt; der Text ist weitgehend umgeschrieben, die Zustandsmaschine nicht.
* Protokoll, `mapalloc`/`mapstart`/`mapaddr`, Konsolenpfad, U880-Seite: **(iii) eigenstaendige Konstruktion**; fachlich der groesste Eigenanteil, in Tokens aber klein (`mapalloc` 38, `mapstart` 73, `ttxfer` 66, `lpxfer` 69, `rkstart` 110, `putchar` 167, `rkopen` 21 = 544 C-Tokens, 1,9 % des Kernel-C) und ohne den U880-Teil nicht sichtbar.
* Zusammenfassung: **"nur Anpassung der V7-Struktur" trifft fuer den Kernel-C zu, "eigenstaendige Konstruktion" fuer Protokoll und U880-Seite.**  Die Mailbox-Treiber sind im Kernel-C keine grosse Eigenentwicklung (3,7 % bis 12,9 %), die Anbindung als Ganzes ist es (Protokoll + 2 032 Zeilen U880-Quelle).

**Was die Spanne bestimmt:**

1. Ob `fd*` (1 764 Tokens, 42 % der Mailbox-Treiber) als "angepasst" (Strukturmass) oder "neu" (Textmass) zaehlt; allein dies verschiebt die Obergrenze um 8 Prozentpunkte des Kernel-C.  Die Belege in 4.4 sprechen fuer "angepasst", sind aber Gleichheiten von Konstanten, nicht von Text.
2. Ob umbenannte V7-Funktionen (`lpcanon` 398 Tokens gegen Hippe-`lpoutput`) als Vorlage zaehlen.
3. Ob `ttstart`/`putchar`/`lpintr`/`rkstart` ("ersetzt") als Eigenanteil zaehlen: ihre Rolle ist V7, ihr Inhalt nicht.
4. Ob die U880-Seite und das Protokoll in den Eigenanteil einfliessen (sie haben keine Tokenbasis).

## 7. Offene Punkte

* **Gast nicht beobachtet:** Wiederholungspfade (`rk` 3, `lp` 10, `fd` 6) sind Quellaussagen; im Lauf wurde nur der Gutfall gemessen (135 Platten-Auftraege, alle Status 01, `analyse.md` Abschnitt 5).  Ebenso der Pfad `0xC8`.
* **Vektor-Zuordnung** `low.s` (3.5) ist aus Tabellenposition und fuenf gemessenen DCB-Vektoren abgeleitet; ein Gastlauf mit Logpoints auf `rkintr`/`tcxint` und Port 80H wuerde es belegen (`versuche/dbg/mutos_io_nachricht.dbg` als Muster).
* **`mapaddr` Bit 4 = INT-16:** Zuordnung abgeleitet (Quelle: `analyse.md` "setzt A33 Bit 4"); die Pulsform (Bit 4 hoch, dann Schattenwert) ist gemessen im Disassemblat, nicht am Port.
* **`mb_seg`:** Kernel gibt bei `rkstart` das volle `b_xmem` mit, die U880-Seite nutzt 2 Bit; ob ein Segment > 3 (EM1024) die Seite stoert, ist offen (Anpassung EM1024 laut CLAUDE.md geplant).
* **Floppy:** Kernel-Treiber vorhanden, U880-Klasse 3 am A5120 funktionslos (Port 1CH unbelegt, Geraeteknoten fehlt); ob eine andere Maschinenvariante (K5601? WD179x-aehnliche Fehlerbits) den Pfad nutzt, ist offen.
* **Quelle des `tm.c`-Gerippes:** 2.9BSD-nahe Zahlenwerte (`0x6D01`, `mtget` mit `mt_type`), aber kein einzelner Baum erklaert alles; weitere Staende (2.9BSD-Zwischenbaender, Ultrix-11-Vorgaenger, UNSW) koennten das eingrenzen.  Hippe selbst hat kein `tmioctl`, die Linie Hippe -> MUTOS erklaert `fdioctl` also nicht.
* **Hippe oder gemeinsame Vorlage fuer `lp.c`/`kl.c`:** nicht trennbar (wie `fremd.md` Abschnitt 8).
* **Nicht geladen:** Zilog-ZEUS, Onyx, Plexus, Coherent-Z8000, MUTOS1600 (kein lokaler Quelltext); ein Treffer dort koennte ein Mailbox-Muster liefern.
* **Korrekturen an bestehenden Dokumenten** (nicht in diesem Auftrag bearbeitet, vom Auftraggeber zu uebernehmen): `dev0.md` ("none") und `dev0.c`-Kopf ("WEGA-fd-Muster nicht belegt" bleibt richtig, aber `tm.c`-Gerippe ist belegt); `lp.md` ("eigen, Familie System III": naechste Vorlage Hippe/Nijmegen `lp.c`, `lpopen`-Konstanten); `uebersicht.md` Abschnitt 1 ("Diskettentreiber MUTOS-eigen").
