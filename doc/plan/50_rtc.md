# Plan 50: Echtzeituhr (RTC 72421) fuer MUTOS

Stand 2026-11-15, Branch `mutos-plus` (Plan 47).  **Grobplan.**  Setzt Plan 48 voraus (nur die U880-Seite erreicht die K1520-Ports).

## 1. Ziel

MUTOS laeuft mit der **echten Uhrzeit**: beim Start liest das System die RTC; `date` (Stellen) schreibt die Zeit auch in die RTC zurueck.

## 2. Ausgangslage

* **Hardware** (`k1520emu: doc/design/50_gun_gide.md` §4, abgeleitet aus `gidertc.mac`, im Emulator umgesetzt, AP G3 dort): Epson RTC 72421 am GIDE-Port **+5 = D5H**,
  16 Register ueber **A8-A11** (`ld bc,0F00h+RTC / out (c),a`: B = Registernummer); Ziffern S1..Y10, Wochentag, CD (HOLD/BUSY), CF (24h).  Lesen: HOLD setzen,
  BUSY = 0 abwarten, Ziffern lesen, HOLD loeschen.  Kein Interrupt.  Im Emulator laeuft die Uhr in Maschinenzeit und springt beim Start nicht zurueck.
* **CP/A** liest die RTC bereits (Statuszeile, `TIME`/`DATE`, `k1520emu: disks/a5120_cpa_gide/README.md`).
* **Kernel** (V7, abgeleitet): die Zeit `time` kommt beim Start aus dem Superblock der Wurzel (`iinit`) und wird mit `stime` (`date`) gestellt; der 50-Hz-Takt
  (`clock`, Vektor 02H von `mutos_io`) zaehlt weiter.  Gemessen wird das im AP R1.
* **Arbeitsablauf:** fuer `make` im Gast wird heute bewusst das Jahr 1987 gestellt (CLAUDE.md "Working in the guest"); eine echte Uhr darf diesen Ablauf nicht brechen.

## 3. Entwurf (Empfehlung)

1. **Neue Postfach-Klasse "Uhr"** in `mutos_io` (Klasse 5): Lesen liefert die RTC-Zeit, Schreiben stellt sie.  Der Kernel fragt beim Start (nach `iinit`) und setzt
   `time`; `stime` schreibt zusaetzlich in die RTC.  Alternative ohne Kernelaenderung: ein Gastprogramm `/etc/rtc` ueber ein neues Zeichengeraet -- braucht aber
   ebenfalls einen Treiber, daher nicht empfohlen.
2. **Umrechnung** BCD-Kalender <-> Sekunden seit 1970 im Kernel (C) oder in `mutos_io` (Z80)?  *Empfohlen:* in `mutos_io` nur rohe Ziffern, Umrechnung im Kernel (C ist leichter zu pruefen).
3. **Zeitzone:** RTC traegt Ortszeit (CP/A zeigt sie so an, *Annahme*), V7 rechnet intern GMT und die libc mit fester Zeitzone -- welche die MUTOS-libc verwendet, wird in R1 gemessen.
4. **Schalter** fuer den Gastbau: RTC ignorieren bzw. Startzeit fest (z. B. 1987), damit `make` und die bisherigen Tests unveraendert laufen.
5. **Jahr 2000 ff.:** `time_t` ist 32 Bit (bis 2038); `date` stellt mit zweistelliger Jahreszahl (19yy) -- pruefen, ob Jahre >= 2000 gestellt und angezeigt werden.

## 4. Arbeitspakete

| AP | Inhalt | Abnahme |
|----|--------|---------|
| R1 | Messung: Zeitquelle beim Start, `stime`, Zeitzone der libc, Verhalten von `date` mit Jahren >= 2000 | Befund in diesem Plan |
| R2 | `mutos_io`: RTC lesen/stellen, Klasse 5 | Debugger-Probe: Nachricht liefert die Emulatorzeit |
| R3 | Kernel: Zeit beim Start holen, `stime` schreibt zurueck; Schalter fuer feste Zeit | `date` nach dem Boot == RTC (Emulator), Neustart behaelt gestellte Zeit |
| R4 | Werkzeuge/Doku: ggf. `date` fuer vierstellige Jahre (Abweichung vom V7-Text kommentiert), Eintrag in `doc/plus/abweichungen.md` | Gast-Test |
