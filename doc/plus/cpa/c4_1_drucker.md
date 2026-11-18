# Plan 48 C4.1 -- Drucker (E7): Erste Sonde zu BIOS LIST, Entscheidung E7 (b), Treiber PRN_*

Stand 2026-11-18.  Die Erste Sonde (§1-§3) zeigte, dass BIOS `LIST` (IOBYTE 80H) am Port 5EH **nicht** wie `IFSSPR` sendet; der Schritt hielt an (Plan 48 §12).
Der Projektinhaber hat danach **E7 (b)** entschieden: Treiberkern aus `IFSSPR` in `mutoscpa`.  Ausfuehrung und Abnahme: §4 ff.

## 1. Messung

`versuche/plus_cpa/lsttest.mac` (setzt `(0003H) := 80H`, ruft BIOS `LIST` mit `AB<TAB>C<CR><LF>` und 50 Zeichen `0`..`9`; Grenzen 0110H/0111H) unter der GIDE-CP/A-Bootdiskette
(`cpa.GIDE_SYS`, EM256), Debugger `iow 5EH`/`iow 5FH`, `versuche/dbg/cpa_c4_1_sonde.dbg`.  Aufruf (Arbeitsordner frei waehlbar):

    python3 -I -c "import sys; sys.path.insert(0,'tools/plus'); import cpa; a=cpa.diskette('/tmp/mplus/c4_1/sonde','sys.hfe',cpa.GIDE_SYS,{'LSTTEST.COM':cpa.com('lsttest','versuche/plus_cpa')}); \
      cpa.lauf_dbg('/tmp/mplus/c4_1/sonde',[l for l in open('versuche/dbg/cpa_c4_1_sonde.dbg') if l[0]!='#'], a, name='lst')"

(*gemessen*, 56 x `OUT (5EH)`: 1 + 55 Zeichen.)

## 2. Befund gegen `IFSSPR` (`udos_lader` §2.4)

| Punkt | `IFSSPR` (UDOS, gemessen) | BIOS `LIST` (gemessen) |
|-------|---------------------------|------------------------|
| Port | 5EH Daten, 5FH Steuerung | gleich |
| WR3 / WR5 | 41H (7 Bit Empfang) / 28H (7 Bit Senden) | gleich (41H, 28H) |
| WR4 | **4DH** (x16, **2 Stopp**, ungerade Paritaet) | **45H** (x16, **1 Stopp**, ungerade Paritaet); Folge 18H, 04,45, 01,00, 03,41, 05,28 |
| WR1 | 1EH waehrend des Auftrags (Interrupts), danach 0 | 00 (Abfrage statt Interrupt) |
| Auftragsanfang | NUL | **7FH (DEL)**, einmal beim ersten `LIST` (laesst die SIO-Init laufen) |
| Wartezeit vor dem 1. Zeichen | keine | **76,6 Mio. Maschinentakte** (3000 Abfragen `IN (5FH)` im Abstand 25,5k Takte; ohne Drucker/Antwort ein Zeitablauf, danach geht es weiter) |
| TAB | im Treiber zu Blanks (Tabelle 24C4H) | **unveraendert** (09H) |
| NUL nach CR | ja | **nein** (0DH, 0AH direkt) |
| Takte je Zeichen | ca. 2850 | **Mittel 13809** (870 bei freiem Sendepuffer, 26,7k wenn gewartet wird; Abfrage im 5-ms-Takt des BIOS) |

Zeichenfolge sonst unveraendert (`B<TAB>C<CR><LF>0123...`).  SIO danach `wr1=00`, CTC 0CH Kanal 0 im Reset (die BIOS-Baudrate laeuft also nicht ueber 0CH; 58H nicht per `dev ctc` sichtbar, nicht weiter verfolgt).

## 3. Bewertung (damalige Empfehlung, inzwischen entschieden)

* Port, Paritaet (ungerade) und 7 Bit stimmen; verschieden sind **Stoppbits (1 statt 2)**, der **Auftragsanfang (DEL statt NUL)** und das **Fehlen von NUL nach CR und TAB-Expansion**.
* Schwerer wiegt die einmalige **Wartezeit von 76,6 Mio. Takten** beim ersten Zeichen: `LIST` blockiert die Hauptschleife von `mutoscpa` (Kernel-Mailbox, Plattenzugriffe) -- *abgeleitet*,
  dass MUTOS beim ersten Druck rund 20-30 s steht (bei 2,4576-4 MHz *Annahme*); ob am echten Drucker mit DC1 die Wartezeit entfaellt, ist am Emulator nicht pruefbar.
* **Empfehlung:** Rueckfall (b) nach `plan 48 §12`: Treiberkern aus `mutos_io/udos/src/ifsspr.mac` (ab `HWINIT`) in `mutoscpa` uebernehmen (gleiche Hardware, bytegleich rekonstruiert,
  asynchron, 2 Stopp, NUL vorweg und nach CR).  Alternative (a) mit eigener Anpassung (NUL nach CR, TAB, Vorlauf umgehen) wuerde Treiberverhalten nachbauen, ohne die Wartezeit ausschliessen zu koennen.

## 4. Ausfuehrung E7 (b): Treiber `PRN_*` in `mutoscpa.mac`

Quelle: `mutos_io/udos/src/ifsspr.mac` (unveraendert; Herkunft steht im Kopfkommentar des Blocks `PRN_*`).  Uebernommen: Koroutine `PUTCH`/`TXISR`/`ISRRET`, Hardwareschicht (`HWINIT`, `TXON`, `TXOFF`, `RXISR` mit
XON/XOFF, `INITBL`: WR4 = 4DH, 2 Stopp, ungerade Paritaet, 7 Bit, CTC 58H Kanal 0 TC 1), Auftragsablauf (`STRTJB`, NUL vorweg, NUL nach CR, FFH-Ende, Status 80H, Rueckruf `DRUCKER_FERTIG`).
`DRUCKER` ruft `PRN_START` statt `CALL 0EB00H`; `PRN_INIT` laeuft am Ende von `INIT`.  `0003H`/IOBYTE und BIOS `LIST` werden nicht benutzt (kein Schreiben nach `0003H` mehr noetig).

Anpassungen (alle in `doc/plus/abweichungen.md`, Zeile C4.1):
* **Vektoren** in der CP/A-Tabelle: F7F0H (SIO B Senden), F7F4H (Empfang), F7F2H/F7F6H (nur `EI`/`RETI`); SIO-WR2 = F0H.  Frei laut `c1_5` §8 (`F7F0..F7FA`); das BIOS belegt dort nichts (CTC-Kanal 1 bei F7FAH bleibt).
* **Zeitablauf** (UDOS: CTC 0EH Kanal 2, im CP/A-BIOS belegt): `PRN_TICK` aus `ISR_TAKT` zaehlt 744 Takte zu 49152 Zyklen (gleiche Dauer); bei 0 Status C2H, Fehlerrueckruf, WR1 := 0.
* **Nach CR genau ein NUL** (UDOS: Auffuellen bis Bit 0 von `0FDBH`; gemessen ein NUL).  **TAB** bis zur naechsten Spalte durch 8 (UDOS-Tabelle 24C4H, *gemessen* nach dem Boot der Ladediskette: `01H` bei Spalte 8, 16, 24 ...; `d 0x24C4 0x80`).
* Ein Sende-Interrupt ohne laufenden Auftrag wird ignoriert (IFSSPR haette ueber `IY = 0` geschrieben).
* Nicht uebernommen: Befehle 00/02/04/06/44/48/10, Besitzerpruefung (`mutos_io` nutzt nur 0FH); Auftrag mit Zahl 0 meldet wie IFSSPR Status 80H ohne Rueckruf.
* Platz: das Segment 9400H wuchs von 0D00H auf 0E00H (Datei 5120 B), Abbild weiter bis C968H (14696 B).

## 5. Abnahme (*gemessen*, `tests/test_plus_cpa_io.py::test_drucker_tty1_c4_1`, `versuche/dbg/cpa_c4_1_lp.dbg`)

* `cat /etc/motd > /dev/lp`: **63 x `OUT (5EH)`, Bytefolge gleich der UDOS-Messung** (Lauf `versuche/dbg/ifsspr_lp.dbg` mit Logpunkt am `OUT`, Vergleich Byte fuer Byte: `True`); zwei Auftraege (53 B, 2 B), je `WR1 = 1EH` zu Beginn und `0` am Ende,
  63 Sende-Interrupts, beide Auftraege enden ueber `PRN_ENDOK` (Status 80H), kein Zeitablauf; mittlerer Abstand der Zeichen am Port 3003 Takte (UDOS: rund 2850).
* Text mit TAB (`AB<TAB>C`, `XYZ<TAB>W`): am Port `AB` + 6 Blanks + `C`, `XYZ` + 5 Blanks + `W` (Spalte durch 8), NUL nach jedem CR -- wie `IFSSPR`.
* `cat /etc/motd > /dev/tty1`: **44 Zeichen ueber `OUT (50H)`** (Zahl wie `analyse.md` §7), mittlerer Abstand 2624 Takte.  *Befund SIO-A-Takt:* nach dem Lauf steht CTC 0CH Kanal 0 des BIOS im Reset (`run=0`);
  die Baudrate von SIO A33 kommt von `mutos_io` (CTC 5AH Kanal 2, `INIT_SIO`); das BIOS-`LIST`/UC1 wird nie gerufen, also kein Konflikt zwischen den Taktquellen.
* Tastatur-Abnahme C3.4 (`test_betrieb_c3_4`, `test_wechsel_c3_4`) bleibt gruen, siehe Stand-Zeile im Plan.
* Offen/nicht gemessen: Verhalten bei XOFF (im Emulator kommt nie ein Zeichen von der Gegenseite), Zeitablauf-Pfad `PRN_TICK` (kein Drucker, der haengt; nur lesend geprueft).
