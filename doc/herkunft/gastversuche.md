# Gastversuche V4-V6 (AP H9): Einzelschritt, Mailbox-Fehlerpfad, Floppy-Kette

Stand 2026-11-03.  Schliesst drei offene Punkte aus `z8001_kontext.md` (Abschnitt 9, Punkt 2) und `mailbox_treiber.md` (Abschnitt 7).
Alle Messungen: MUTOS 8000 im Emulator (`k1520dbg --rw --em em256 --laufwerke K5601,K5601,K5601,K5601`, Platten nur als Kopien im Arbeitsordner),
nur vorhandene Gastprogramme (`adb`, `dd`, `mknod`, `ls`, `cat`, `mount`), Beobachtung im Debugger (`cpu u8000`: `trap`, `psa`, `lp`, `wp`, `iow`, `dev em`; `cpu zve1`: `iow`, `lp`).
Aussagen sind **gemessen** (mit Verweis auf Auszug) oder **abgeleitet/angenommen** gekennzeichnet.

Aufbau, Skripte und Auszuege: `versuche/gast_h9/`

* `lauf.sh V4|V5|V6 ARBEITSORDNER` baut die Platten (Boot-, Wurzel-, usr-Diskette als Kopie, Arbeitsdiskette = Kopie von "bin" mit `adb mt tar` plus `echo dd od ps` (cmd) und `mknod`, Dateizeiten 1987),
  startet den Gast (Vorspann `vorspann.dbg`: Boot, `root`, `/usr` rk1, `/mnt` rk3 = Arbeitsdiskette, `/tmp` rk0 leer, Gastdatum 1987-01-01) und dann `v4.dbg`, `v5.dbg` oder `v6.dbg`.
  Jede Sitzung endet mit `sync`.  Laufzeit je Versuch 1,5 bis 8 Minuten Wanduhr (V5 Fall 4 am laengsten); im Hintergrund starten.
* `auszug.sh VN lauf.log` zieht die belegenden Zeilen; `auszug_v4.txt`, `auszug_v5.txt` (gekuerzt: je Art hoechstens 24 bzw. 200 Zeilen), `auszug_v6.txt`.
  Die Zeilennummern vorne sind die des vollstaendigen `lauf.log` (nicht eingecheckt, aus dem Skript reproduzierbar; die Laeufe sind deterministisch bis auf die Tastenverzahnung).
* Marker im Gast: `echo A''1` -- der Bildschirm zeigt den getippten Text mit `''`, nur die Ausgabe `A1` ist der Treffer fuer `gscreen`.

## V4 Einzelschritt mit `adb`

**Aufbau.**  `adb ./echo` auf der Arbeitsdiskette (`echo` aus "cmd", gestrippt, Eintritt 0, erster Befehl `ld r6,@SP`).  `adb` dieser Diskette hat einen Z8000-Disassembler (zeigt `ld r6,@SP`, `#0:`).
Debugger: `b <<0>>%030E if FCW == %400C` (Eintritt des gemeinsamen Trap-Codes nur fuer den NVI-Eintrag), `iow %80` (Schattenregister A33 des Kernels), `trap`, `psa 4`, `dev em`.
Teil A: nach `adb ./echo` ohne Haltepunkt viermal `:s`, dann `$r`, `:c`.  Teil B: `0:b`, `:r`, dreimal `:s`, `$r`.

**Erwartung (vor der Messung, aus `z8001_kontext.md` Abschnitt 4/9 abgeleitet).**  `ptrace` Einzelschritt setzt im gesicherten FCW Bit 11 (NVIE); die A5120.16 liefert nach "einem" Befehl einen NVI;
der Eintritt ueber PSA-Eintrag NVI (FCW `400C`, Behandlung `030E`) fuehrt in `trap` Fall 3 -> SIGTRAP und loescht NVIE; `adb` zeigt danach den **naechsten** Befehl (PC 0 -> 2).  Breakpoint `7C06` -> PRIV-Trap -> SIGTRAP.

**Messung.**

1. Haltepunkte funktionieren: `0:b`, `:r` -> `breakpoint #0: ld r6,@SP`; je Haltepunkt ein PRIV-Trap (`trap`: PRIV 1).  `:c` bis Programmende: `process terminated`.  (Auszug 21808-21848.)
2. **Der Einzelschritt kommt ueber den Mechanismus wie erwartet zustande, aber ohne Befehlsfortschritt.**  Je `:s` (Teil A, Schritte 2-4; Schritt 1 ist nur der Halt nach `exec`) genau ein NVI:
   `Ausnahme: NVI Kennung=%FFFF bei <<0>>%03F6 gekellert <<1>>%0000 FCW %1820->%400C Behandlung <<0>>%030E`.  Rahmen auf dem Systemstapel: `FFFF 1820 0100 0000`
   = Kennung FFFF, FCW `1820` (VIE + **NVIE** + S-Flag, Normalmodus), PC = Segment 1, Offset **0000**, also der noch **nicht ausgefuehrte** erste Befehl.  `trap`-Zaehler: NVI 1 je Schritt.
3. `adb` meldet nach jedem Schritt `stopped at #0: ld r6,@SP`; `$r` zeigt `pc #0`, `ps #1020` (NVIE vom Kernel wieder geloescht, wie `trap` Fall 3 es vorsieht), alle Register unveraendert.  Dreimal hintereinander derselbe Befund (Auszug 5476, 11081, 16660; `$r` 21788).
4. Teil B: `:s` am Haltepunkt zeigt abwechselnd `stopped at #0` und `breakpoint #0` (PRIV-Zaehler wechselt mit).  Deutung (**abgeleitet**, V7-`adb`): bei einem Schritt ueber einen Haltepunkt tritt `adb` den ersten Schritt mit entferntem Haltepunkt (NVI, PC bleibt 0), setzt den Haltepunkt wieder ein und laeuft weiter; dieser trifft beim naechsten `:s` sofort wieder `7C06`.
5. Port 0x80 (Schatten A33): bei jedem `:s` genau die Folge `00C8` bei PC `03E2`, `00C0` bei PC `03E8` (in den drei Fenstern A2-A4 je einmal, sonst nie): Bit 3 = "Einzelbefehl-Freigabe" (EM-Karte, `a5120emu/core/cards/em/em.h`) wird kurz gesetzt.
   Im Kernel (`kernel/asm/ref/low.s` Zeilen 296-310): `bit 2(r15),#11` (NVIE im gesicherten FCW) -> `out 80,..|8`, `nop`, `out 80,..`, dann `popl rr0` + `push r0` + `pop r0` (**4 Stapelzugriffe**), danach `ldps 875A`/`iret` (**4 weitere Lesezugriffe**).
   Der Einzelbefehlszaehler A53 der EM-Karte (Vorlast 11, Emulator laut Geraetemessung vom 2026-09-29) zaehlt jeden Stapelzugriff rueckwaerts, NVI = Pegel `QD` ab Stand 7.  Nach den vier Zugriffen vor dem `iret` liegt der NVI also schon an (**abgeleitet** aus Quelltext und Emulatormodell; Zaehlerstand dort nicht einzeln gemessen).  `dev em` nach dem Schritt: `A53=11 (Vorlast 11), A54 gehalten`.

**Deutung.**  Mechanismus und Vektor gemessen: NVIE-Bit im Benutzer-FCW + A53-Zaehler -> NVI-Pegel -> PSA-Eintrag `+0x32` (FCW `400C`) -> `030E` -> SIGTRAP.  **Der Einzelschritt funktioniert im Emulator nicht**: der NVI wird am Ende des `iret` mit dem *neuen* FCW (NVIE gesetzt) angenommen, bevor der erste Benutzerbefehl lief; `adb` kommt nie ueber PC 0 hinaus (vier Wiederholungen).
Das ist mit dem Kernelentwurf nicht vereinbar (ein Debugger muesste dann nie funktionieren) -- entweder liegt es am Emulator oder an einer Voraussetzung, die der Gast nicht erfuellt.

**Emulator-Verdacht (nicht gepruft, nichts geaendert).**  `core/primitives/z8000.cpp` `checkInterrupts()` tastet nach jedem Befehl mit dem aktuellen FCW ab, auch nach `IRET`.  Zwei Hinweise sprechen dafuer, dass die echte Karte den NVI erst **nach dem naechsten Anwenderbefehl** annimmt:
(a) der Kernel verbraucht vor dem `iret` selbst vier Zaehlschritte (`popl/push/pop`) -- diese Auffuellung waere sinnlos, wenn der NVI ohnehin am `iret`-Ende genommen wuerde; (b) die P8000-Doku im Emulatorprojekt (`doc/p8000/schaltplan_16bit.md`, "Single-Step", MON16 `p.brk.s`) beschreibt fuer die Schwesterkarte: "sein Interrupt kommt nach dem naechsten Anwenderbefehl".
Ob das Verhalten vom Prozessor selbst (kein Abtasten mit dem neuen FCW unmittelbar nach `IRET`/`LDPS`) oder von der Kartenlogik stammt, ist ohne Zilog-Referenz/Geraet **offen**.  Die Annahme `ps &= ~0x0800` und die Kernelseite sind dagegen unauffaellig.
Zu pruefen im Emulatorprojekt: Gegenprobe "NVI-Pegel steht schon vor `IRET` an" gegen MAME-Orakel und Zilog §7.5/§9.6.1 (Abtastzeitpunkt), ggf. ein Einzelschritttest `em16abl` am Geraet.

**gemessen / angenommen.**  Gemessen: Haltepunkte, NVI-Eintritt und Rahmen, kein Fortschritt (4 von 4), Port-80-Folge `C8`/`C0`.  Abgeleitet: Rolle des Auffuellens, Deutung des `breakpoint/stopped`-Wechsels.  Offen: Verhalten auf echter Hardware.

## V5 Mailbox-Treiber

### V5a Vektorzuordnung (Logpoints an den Kellerstuecken `0246..0276` und den Handlern)

**Erwartung** (`mailbox_treiber.md` 3.5, aus Tabellenposition abgeleitet): Vektor 02 -> `clock`, 0A -> `rkintr`, 12 -> `lpintr`, 1A -> `fdintr`, 22 -> `tcrint`, 24 -> `tcxint`.

**Messung** (Logpoint am Kellerstueck, Kennung bei `[SP]w`; Handler-Logpoint folgt je Treffer nach etwa 250 Zyklen; Auszug `auszug_v5.txt`).  Arbeit: `ls -l /`, `cat /etc/motd > /dev/lp`, `cat /etc/passwd > /tmp/p`, `sync`:

* Kennung `xx02` -> Stueck `0246` -> `clock` (im Lauf 3198 Treffer; Hochbyte 01 oder 05 = Status-8, wechselt).
* Kennung `xx0A` -> `025E` -> `rkintr` (187 Treffer; `[D535]` = 1 bei jedem; Hochbyte 01, einmal 03).
* Kennung `0112` -> `0256` -> `lpintr` (2 Treffer bei `cat /etc/motd > /dev/lp`: der Drucker "laeuft", ohne dass etwas ausgegeben wird; die U880-Seite quittiert den Auftrag).
* Kennung `cc22` -> `0266` -> `tcrint` (103 Treffer): **das Hochbyte der Kennung ist das eingetippte Zeichen**.  Die ersten sechs Treffer `6C 73 20 2D 6C 20` = `l s <Leerzeichen> - l <Leerzeichen>` -- genau der getippte Text `ls -l /;echo ...` (ein Vorlauf mit Grenze 8 zeigte zusaetzlich `2F 3B` = `/ ;`).  Das Hochbyte ist Status-8 der EM-Karte; damit ist die bisher *angenommene* Herkunft des Zeichens in `tcrint` (`ch >> 8`) **gemessen**.
* Kennung `xx24` -> `026E` -> `tcxint` (177 Treffer; Hochbyte = zuletzt gelesener Statuswert, hier dasselbe Zeichen wie davor).
* `fdintr` (`0276`, Vektor 1A): 0 Treffer, wie erwartet (kein Floppyzugriff).
* Zaehler waehrend `ls -l /`: clock 896, rkintr 87, tcrint 18, tcxint 85, lpintr 0, fdintr 0.

**Deutung.**  Vektorzuordnung der Tabelle in `mailbox_treiber.md` 3.5 bestaetigt (rk, lp, tc*, clock gemessen; fd nur aus der Tabelle).  Nicht geprueft: die Ebenenschwellen (6/5/4).  Die Leitungen tty1..3 (Vektoren 26..30) blieben ungenutzt.
**Ueberraschung:** die Kennung traegt Nutzdaten (Zeichen) im Hochbyte; die Zuordnung "Vektor = Kennung & FF" gilt, die Handlerwahl ignoriert das Hochbyte.

### V5b Fehler- und Wiederholungspfad `rk`

**Aufbau.**  `/etc/umount /dev/rk1`, dann `eject B` (Laufwerk leer), `PATH=/bin:/mnt:.`.  Logpoints `rkstart 6B60` und `rkintr 6BCA` nur bei `[D535] != 1`, `deverror 18A4` (Argumente `[SP+4]w`, `[SP+6]w`), `wp em:0D535 changed` (roh, zeigt auch Schreibzugriffe der U880-Seite; `wp <<0>>%D535` zeigt nur U8001-Schreibzugriffe).

**Erwartung** (`rk.c`, `mailbox_treiber.md` 3.4): Status 0xC8 ("Einheit fehlt") -> `ENXIO` sofort; andere Fehler `deverror`, bis zu 3 Wiederholungen (insgesamt 4 Versuche), dann `B_ERROR`.

**Messung.**

1. Fall 1 `dd if=/dev/rrk1 of=/dev/null count=1` (leeres Laufwerk): vier Fehlschlaege hintereinander, Statuswert der U880-Seite (`wp`, Schreiber `ZVE1.PC=9093`) **`0xC2`**, nicht `0xC8`.  Folge je Fehlschlag: `rkintr` (`[D535]` = C2) -> `deverror(.., 0, C2)` -> `rkstart` (Wiederholung); Abstand der Versuche etwa 0,93 Mio Maschinentakte; nach dem vierten Fehlschlag folgt kein weiterer Versuch derselben Anforderung (zwei spaetere `rkstart`-Aufrufe bei 875244654 und 875935977 sind nicht zugeordnet, vermutlich Folgeauftraege von `dd`).  Auszug: `wp ... =C2` bei Takt 872116702, 873051523, 873986272, 874920949.
   **3 Wiederholungen bestaetigt** (1 + 3 Versuche).  Konsole je Versuch zweizeilig: `err on dev 13/1` und `bn=0 er=0,302` (Oktal 302 = 0xC2).  Danach `dd`: `read: I/O error`, `0+0 records in/out`.
2. Fall 2 `dd if=/dev/rk1 skip=5 ...` (Blockgeraet): dieselben Vierfachversuche je Block, mit `bn=4`, `5` und `6` -- auch nach der Fehlermeldung von `dd` (`read: I/O error`) laufen noch Versuche fuer `bn=6` weiter (V7-Vorauslesen, asynchron).  `dd` liest `skip` blockweise (Fall 4: Blocknummern 605..607), nicht per `lseek` (**abgeleitet**).  Gesamt 52 Fehlerschreibungen `C2` im Lauf.
3. Fall 3 `/etc/mount /dev/rk1 /usr` mit leerem Laufwerk: `bn=1` (Superblock) vierfach, Meldung `mount: I/O error`.
4. Fall 4 `dd if=/dev/rrk3 skip=700 ...`: Das Laufwerk rk3 hat nur 494 echte Bloecke (**abgeleitet**: 456 Fehler = 114 Bloecke x 4 Versuche bis Block 607; erster fehlerhafter Block 494).  Fuer diese Bloecke meldet die U880-Seite **`0xC5`** (Satz/Spur nicht gefunden, Bedeutung **angenommen**), ebenfalls 4 Versuche (Konsole `bn=605..607 er=0,305`).  Ab Block 608 (`rkstrategy`-Grenze 0x260) kein Mailboxauftrag mehr: `read: No such device or address` (`ENXIO`).
5. `0xC8` wurde **nicht** ausgeloest; die Annahme in `rk.c`/`mailbox_treiber.md` 3.4 ("Einheit fehlt") bleibt unbelegt.  Leeres Laufwerk liefert C2, Lesen hinter dem Plattenende C5.

**Deutung.**  Der rk-Fehlerpfad entspricht der Quelle: `deverror` bei jedem Fehlschlag, 3 Wiederholungen, dann `B_ERROR` (EIO ohne `b_error` -> `I/O error`); nur der Statuswert war anders als im Quelltext vermerkt.  Der Benutzer sieht je Fehlschlag zwei Konsolzeilen (insgesamt acht pro fehlerhaftem Block) und je nach Programm `I/O error`.  Bei einem schweren Ausfall (Laufwerk ohne Diskette) dauert das Scheitern etwa 4 x 0,93 Mio Takte je Block, `mount` und `dd` blockieren so lange.
**Ueberraschung:** (1) der Status fuer "keine Diskette" ist `C2`, in `mutosio.mac` als Zeitablauf der Roh-Floppy (`KMD_ZEIT`) bekannt; die Platten-Seite verwendet offenbar denselben Code fuer "Einheit nicht bereit"; (2) `skip` liest wirklich durch; (3) das Plattenende der Diskette (494 Bloecke) liegt vor der Kernelgrenze 608.

**Offen:** `0xC8`, Fehlerpfad beim Schreiben, `lp`-Wiederholungen (10), Fehlerstatus `FFH` des Druckers.

## V6 Floppy-Kette `fd*`

**Aufbau.**  `mknod fd0 b 0 0` und `mknod rfd0 c 10 0` (Major 0 = `bdevsw` `fd`, cdevsw 10 = `fd` roh, laut `kernel/conf/conf.c`) auf der Arbeitsdiskette; `dd if=rfd0 ...`, `dd if=fd0 ...`, `dd if=rfd0 bs=1k count=4`.
Beobachtung: `lp` an `fdopen 7E16`, `fdstrategy 7F94`, `fdstart 7FDC`, `fdintr 821A` (mit `[D55B]` = `fdmbx.mb_stat`), `deverror 18A4`; U880-Seite `lp` an 9A00 (Klasse 3), 9BEE (`KMD_STARTEN`, `OUT (1CH),A`), 9BFC, 9C00; `iow 0x1C`; Kommandoblock `01B5` vorher/nachher.

**Erwartung** (`mailbox_treiber.md` 3.6, `analyse.md` Abschnitt 8): `mknod` geht, `fdopen/fdstrategy` werden erreicht, Port 1CH bleibt ohne Antwort (Hardware am A5120 nicht vorhanden); Zeitablauf C2, danach Fehlerbits F1..F8; unklar, ob der Gast haengt.

**Messung.**

* Knoten: `brw-rw-r-- 0, 0 fd0`, `crw-rw-r-- 10, 0 rfd0`.  Beide Zugriffsarten erreichen `fdopen` (raw: Argument `0A00`, Block: `0000`), `fdstrategy`, `fdstart`, die Mailbox (Kommandobyte `IX+8` = 00, dann 51H) und die U880-Seite 9A00.
* Je Mailboxauftrag **ein** `OUT (1CH),00` (Zeile `[io] ... OUT (1CH)=00 ZVE1.PC=9BF2`), kein `IN`; danach 128 `DJNZ`-Durchlaeufe je Auftrag (Zeitablauf; `lpl`: 256 Treffer an 9BFC fuer zwei Auftraege), `LD (IY+0AH),C2H` bei 9C00 (Status C2), 9A00 wird erneut gerufen, `fdintr` laeuft.  Je `dd` zwei Auftraege (zwei `fdstrategy`/`fdstart`/`fdintr`-Paare, zwei `OUT (1CH)`).
* `fdintr` sieht zuerst `[D55B]` = 1, dann **`0xF7`**.  Konsole: `tm0: bn = 0 0 old er = F7 err stat = F7` (einmal), `dd`: `0+0 records in`, `0+0 records out`.  **Kein Haenger, keine Wiederholung** (nicht 6 Versuche): der Fehler tritt im Zustand ein, in dem `fdintr` ohne Wiederholschleife meldet (Zustand `s` nicht einzeln gemessen).
* Kommandoblock `01B5` vorher `E7 03 7E CD F7 03 CD 36 04 ...` (UDOS-Nukleus-Code), nachher `83 00 00 00 00 00 00 00 00 CD ...`: der Kommandoblock *liegt im Nukleus* und wird von der Roh-Floppy-Routine ueberschrieben (wie `analyse.md` Abschnitt 8 vermerkt).  Der Gast lief danach normal weiter (`sync`).
* Alle drei `dd`-Aufrufe (roh, Block, `bs=1k count=4`) gleich.

**Deutung.**  Die Floppy-Kette Kernel -> Mailbox -> U880-Klasse 3 ist im Emulator **ausfuehrbar und terminiert** (Hardware antwortet nicht; Port 1CH ist unbelegt).  F7 entsteht (**abgeleitet** aus `analyse.md` 8): das Statusbyte `01BD` bleibt 0, die Fehlertabelle `TAB_FEHLER` meldet "Bit 3 geloescht = F7".
**Ueberraschungen:** (1) `dd` meldet keinen Lesefehler (`0+0 records`), im Gegensatz zu `rk` (`read: I/O error`) -- der `B_ERROR` aus `fdintr` erreicht `dd` also nicht als Fehlerrueckgabe (Ursache in `fdphys 8554`/`fdread 84E4` nicht untersucht); (2) kein Haengen trotz fehlender Hardware; (3) der Kommandoblock im Nukleus wird zerstoert -- ein Floppy-Zugriff im Gast ist nicht folgenlos fuer das UDOS-Fenster (nur `01B5..01BD`, Folgen nicht untersucht).
**Offen:** Verhalten mit einer anderen Maschinenvariante (WD179x-aehnlicher Controller, Port 1CH belegt); Statuswege F1..F6.

## V1-V3 Speicherschutz, privilegierte Befehle, Stapel und brk (AP H10, 2026-11-03)

**Methode (rein Debugger, kein neues Gastprogramm, Kernel und Emulator unveraendert).**  Ein vorhandenes Kommando (`cat`, wartet auf der Konsole) wird mit Haltepunkten `b <<1..3>>%0000` an seinem ersten Benutzerbefehl angehalten (FCW `1020`, nichtsegmentiert, Normalbetrieb; hier Segment 3).
Dort ueberschreibt der Debugger den Befehl bei PC 0 (`e`/`a`) und setzt Register (`set`); der Kernel wird mit Logpoints an Funktionseintritten protokolliert (`[SP+2]w`, `[SP+4]w` = erste zwei Argumente): `trap` 087A (dev, ident), `psignal` 0B6E, `psig` 0C7C, `core` 0D56, `exit` 48C4, `sigret` 3630, `sendsig` 35AE, `sbreak` 4BD0.
`e`/`d` im Benutzerzustand gehen durch die Segmentweiche (Benutzersegment); Kernelspeicher wird roh ueber `em:` gelesen (Segment 0 = `em:0xxxx`, Segment 3 = `em:3xxxx`).
Ein Gastboot je Fall (`gen_faelle.sh` erzeugt `faelle/*.dbg`, `alle.sh` fuehrt sie mit vier parallelen Emulatoren aus; V1 mit `lauf.sh V1 ARBEITSORDNER`).  Auszuege: `versuche/gast_v1v3/auszug_v1.txt`, `auszug_v2.txt`, `auszug_v3.txt`.
Mehrere Faelle nacheinander in einem Boot waren nicht brauchbar (der Gast nahm danach keine Zeilen mehr an; Ursache nicht untersucht), daher ein Boot je Fall.  Absolute Werte (Stapelinhalt, Bytes von `u`) schwanken zwischen Bootlaeufen, die Befunde nicht.

### V1 Speicherschutz -- gemessen

* `LD R1,@R2` mit `R2 = FC00` im Normalbetrieb: `R1 = 5A5A`, das vorher mit `e %FC00` in das **eigene Segment 3** geschriebene Muster; Buszyklus `N W R <<3>>%FC00`, Rohwatch `RD <<3>>%FC00 (em:3FC00)=5A`.  Die Kernelkopie von `u` (`em:0FC00`) bleibt unveraendert, der Watch auf `em:0FC00` spricht nicht an.  `LDB RL1,@R2` liefert `005A`.
* `LD @R2,R1` mit `R2 = D586` (freier Bereich in Segment 0), `R1 = A5A5`: Schreibzugriff `WR <<3>>%D586 (em:3D586)`; `em:0D586` bleibt `FF FF ...`.
* **Ergebnis:** ein nichtsegmentierter Benutzerzugriff erreicht nur das eigene 64-KB-Segment (Segmentnummer = PC-Segment), weder `u` noch Kernel noch fremde Segmente.  **Grenze:** gemessen am *Emulatormodell* der Segmentweiche (Modus 2); ob die echte Karte gleich arbeitet, bleibt *angenommen*.

### V2 Privilegierte Befehle und ungueltiger SC -- gemessen

* **DI `7C00`, HALT `7A00`, IN `3B04 0080`, OUT `3B06 0080`, LDCTL R0,FCW `7D02`, LDCTL FCW,R0 `7D0A`, IRET `7B00`:** in allen sieben Faellen derselbe Ablauf: PRIV-Ausnahme (PSA-Eintrag 10h, Kennzahl 2), `trap(2, ident = Opcode)` (Fall `2+USER`, `ident` nicht 7C04..06), `psignal(p, 4)` = SIGINS, `psig` -> `core` -> `exit(0x84)` (Signal 4 mit Core-Bit 0200).  Konsole: `Illegal instruction - core dumped`.  Der Befehl wird nicht ausgefuehrt.  Das bestaetigt die Lesung von `trap.c`; `7C04..7C06` ergeben SIGEMT/SIGIOT/SIGTRC (Haltepunkt `7C06` aus V4).
* **SC `7F20`, `7F3F`, `7FFF`:** `trap(6, 7Fnn)`, **kein** `psignal`, kein Prozessende.  Hinter dem SC `R4 = 0016` (EINVAL) und Carry gesetzt (FCW `10A0`): V7-Fehlerrueckgabe von `nosys`; der Prozess laeuft weiter (kein SIGSYS).  `ident & 077` bildet `7FFF` auf Eintrag 63 ab.
* **SC `7F40`** (`ident & 077 = 0`): die Nummer wird auf Eintrag 0 abgebildet, `trap` ruft `sigret` (3630) statt `nosys`.  Der Lauf endete mit `trap(3, FFFF)` im Systembetrieb und `panic: trap` (Konsole: `trap type 3`, `ident = FFFF`, `panic: trap`).  Die Nummern 64..255 sind also **keine** ungueltigen Aufrufe, sondern Aliase von 0..63.  Weitere Auswertung dieses Falls (Abhaengigkeit vom Stapelinhalt) ist nicht Teil dieser Messung.

### V3 Stapel und brk -- gemessen

* **Signalzustellung bei SP nahe 0** (`u_signal[4]` per `e em:0FCDA` auf Handler `0200` gesetzt, Handler = `SC #1`, DI bei PC 0): `sendsig(0200, 4)` ruft **keine** Pruefung auf.
  * `SP = 0000`: Rahmen `7C00 1020 0300 0002` (ident, FCW, PC-Segment, PC) bei `FFF8..FFFF`; die Umgebungsstrings am Segmentende (`PATH=/bin:/usr/bin:/m...`) werden still ueberschrieben, der Handler laeuft, `exit(0)`.
  * `SP = 0008`: Rahmen bei `0000..0007`, ueberschreibt den eigenen Programmtext (den DI-Befehl).
  * `SP = 0004`: Rahmen laeuft ueber die Segmentgrenze (Woerter bei `FFFC`, `FFFE`, `0000`, `0002`): der 16-Bit-Offset wickelt um, ohne Segmentfehler.
  * Der Rahmen bleibt immer im eigenen Segment.
* **brk** (`SC #17` = `7F11`, Argument in R0; `u_dsize` vorher `0017`):

  | R0 | `u_dsize` danach | Befund |
  |---|---|---|
  | `FF00` | `00FF` | Klicks bis `FEFF` geloescht, Carry nicht gesetzt |
  | `FF01` | `0000` | 16-Bit-Ueberlauf in `btoc` (`FF01 + 255 = 0`) |
  | `FFFF` | `0000` | wie `FF01` |
  | `0100` | `0001` | Verkleinern, nichts geloescht |

  * Mit `SP = FE80` und dem Muster `77..` bei `FE80` ist das Muster nach `brk(FF00)` null: **brk loescht Stapeldaten**, die unterhalb des neuen Datenendes liegen (keine Pruefung gegen den Stapel).  `brk` nahe `FFFF` fuehrt nicht zu einer Kollision, sondern zu `u_dsize = 0` (Ueberlauf).
  * *Nicht gemessen:* Auslagerung (`xswap`/`swap`) mit solchen Groessen.

### Folgerung fuer die Doku

`speicher.md` 5.8: die Zeilen "Benutzerprozess greift auf Kernel zu" und "E/A-Befehle, `ldctl`, `iret`" sind jetzt gemessen; "Stapelueberlauf in die Daten" ist fuer `sendsig` und `brk` gemessen (kein Fehler, Umlauf bzw. Loeschen).  Offen bleibt: Auslagern nach `brk`, echte Karte statt Emulatormodell, Vorgehen bei Stapelwachstum durch `call` (nicht durch Signal) nahe 0.

## Nachpruefen

```sh
SCR=/pfad/zum/arbeitsordner
K1520EMU_NOBUILD=1 bash versuche/gast_h9/lauf.sh V4 $SCR/v4     # ~6 Minuten, Ausgabe $SCR/v4/lauf.log
K1520EMU_NOBUILD=1 bash versuche/gast_h9/lauf.sh V5 $SCR/v5     # ~8 Minuten
K1520EMU_NOBUILD=1 bash versuche/gast_h9/lauf.sh V6 $SCR/v6     # ~2 Minuten
versuche/gast_h9/auszug.sh V4 $SCR/v4/lauf.log
# V1-V3 (AP H10): gen_faelle.sh; alle.sh $SCR/fa (V2/V3, 19 Faelle, 4 parallel); lauf.sh V1 $SCR/v1 (V1); auszug.sh v1 $SCR; auszug.sh v2|v3 $SCR/fa
```
