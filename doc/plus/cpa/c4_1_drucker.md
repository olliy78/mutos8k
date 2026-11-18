# Plan 48 C4.1 -- Drucker ueber BIOS LIST (E7 a): Erste Sonde, Stand ANGEHALTEN

Stand 2026-11-18.  Die Erste Sonde zeigt, dass BIOS `LIST` (IOBYTE 80H) am Port 5EH **nicht** wie `IFSSPR` sendet.  Nach Plan 48 §9 C4.1 / §12 haelt der Schritt hier an;
der Rueckfall E7 (b) braucht eine Entscheidung des Projektinhabers.  `mutoscpa.mac`/`mutoscpa.bin` und `abweichungen.md` sind **nicht** veraendert.

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

## 3. Bewertung und Empfehlung (Entscheidung beim Projektinhaber)

* Port, Paritaet (ungerade) und 7 Bit stimmen; verschieden sind **Stoppbits (1 statt 2)**, der **Auftragsanfang (DEL statt NUL)** und das **Fehlen von NUL nach CR und TAB-Expansion**.
* Schwerer wiegt die einmalige **Wartezeit von 76,6 Mio. Takten** beim ersten Zeichen: `LIST` blockiert die Hauptschleife von `mutoscpa` (Kernel-Mailbox, Plattenzugriffe) -- *abgeleitet*,
  dass MUTOS beim ersten Druck rund 20-30 s steht (bei 2,4576-4 MHz *Annahme*); ob am echten Drucker mit DC1 die Wartezeit entfaellt, ist am Emulator nicht pruefbar.
* **Empfehlung:** Rueckfall (b) nach `plan 48 §12`: Treiberkern aus `mutos_io/udos/src/ifsspr.mac` (ab `HWINIT`) in `mutoscpa` uebernehmen (gleiche Hardware, bytegleich rekonstruiert,
  asynchron, 2 Stopp, NUL vorweg und nach CR).  Alternative (a) mit eigener Anpassung (NUL nach CR, TAB, Vorlauf umgehen) wuerde Treiberverhalten nachbauen, ohne die Wartezeit ausschliessen zu koennen.
* Nicht erledigt (wartet auf die Entscheidung): Umbau `DRUCKER`, `0003H`, tty1-Pruefung (Punkt 2 des Plans), Zeile in `doc/plus/abweichungen.md`, Test "kein `0EB00H`".
