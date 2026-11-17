# C1.7 Interrupt-Koexistenz mit dem BIOS (GIDE-CP/A)

Stand 2026-11-17, Plan 48 C1.7.  Alles *gemessen* mit `python3 -I versuche/plus_cpa/itest.py --arbeit /tmp/mplus/c1_7/r8` (8 s Wanduhr, Exit 0; Arbeitsordner und
Logs dort: `itest.log`, `itrace.txt`), sonst gekennzeichnet.  Maschine: `k1520dbg --em em256 --laderom ul4 --gide=0xD0 --rw`, Systemdiskette
`a5120_cpa_gide_k7024_2fdd_8gide_system.hfe` (Kopie), B: = Kopie von `a5120_mutos8000_root_fm.hfe` (`ss77_26x128`).  Takte = Maschinentakte des Debuggers (Zeile `[lp] c...`).

## 1. Aufbau

`versuche/plus_cpa/itest.mac` (-> `ITEST.COM`) traegt einen ISR wie `ISR_TAKT` von `mutos_io` in die CP/A-Tabelle ein: Vektor `F7FAH` (Register `I` = F7, gemessen `I=F7`;
CTC-Kanal 1 bei BIOS-Vektorbasis F8H, C1.5 §8), programmiert CTC 0DH wie `mutosio.mac:386-389` (`A7H`, `C0H`).  Der ISR zaehlt, liest die Tastatur ueber BIOS `CONST`/`CONIN`
in eine Warteschlange und endet mit `EI`/`RETI`; er laeuft auf dem Stapel des Unterbrochenen (wie `ISR_TAKT`).  Phasen, je dreimal: ISR aus (kalt), ISR aus (warm, gleiche
Startbedingungen wie der Lauf mit ISR), ISR an:

* **P** Leerlauf (`HALT`), bis 500 Ticks gezaehlt sind.
* **A** 400 Saetze `READ` von B: ueber die BIOS-Sprungleiste (Adresse aus `0001H`; `SELDSK` C=1 E=0, `SETTRK`, `SETSEC` 1-basiert, `SETDMA`, `READ`, ohne `SECTRAN`; Spur 0..15 bei SPT = 26).
* **B** 2000 Zeichen `CONOUT` (A-Z, Zeilenumbruch alle 70).
* **C** 200 Saetze `WRITE` (C=1) auf B: ab Spur 40, danach zurueckgelesen und verglichen; Muster je Lauf anders (Startwert 11H, 33H, 77H; der ISR-Lauf schreibt zuletzt).

Die Phasengrenzen sind `CALL`s auf Ein-Byte-`RET`-Routinen bei `0110H+n`; der Treiber setzt dort `logpoint` (Taktstand) und einen auf der ersten ISR-Anweisung (`0130H`) =
**jeder** ISR-Eintrag mit Takt.  `itrace` laeuft zusaetzlich mit.  Ab Beginn von Phase B (ISR an) tippt der Treiber `wxyz` ein (`keys`, laeuft die Maschine ~3 Mio. Takte).

## 2. Ergebnis (Lauf r8)

Takte je Tick (Phase P, 500 Ticks = 24 624 612 Takte): **49 249** gegen 49 152 nominal (+0,2 %, = 1/512; dasselbe Verhaeltnis zeigt der 5-ms-Takt des BIOS: 12 312 statt 12 288).
Der Debugger zaehlt Maschinentakte etwas schneller als der CTC-Eingang; *Annahme* (nicht untersucht), die Spalte "erwartet" ist deshalb mit Phase P geeicht.  500 Ticks = 10,02 s bei 2,4576 MHz.

| Phase | Takte | Ticks | ISR-Eintraege (Logpoint) | erwartet | laengste Luecke | kuerzeste Luecke | mittlere Luecke | BIOS-5-ms-Ticks (erwartet) |
|-------|------:|------:|------:|------:|------:|------:|------:|------:|
| P Leerlauf, ISR an | 24 624 612 | 500 | 500 | 500,0 | 49 267 | 49 244 | 49 248 | 2000 (2000,0) |
| A 400 READ, aus (kalt) | 24 149 948 | -- | -- | -- | -- | -- | -- | 1962 (1961,4) |
| A 400 READ, aus (warm) | 22 841 201 | -- | -- | -- | -- | -- | -- | 1856 (1855,2) |
| **A 400 READ, ISR an** | 23 051 149 | **468** | 468 | 468,1 | **49 277** | 49 236 | 49 250 | 1872 (1872,2) |
| B 2000 CONOUT, aus (warm) | 2 968 584 | -- | -- | -- | -- | -- | -- | 241 (241,1) |
| **B 2000 CONOUT, ISR an** | 3 043 361 | **61** | 61 | 61,8 | **49 263** | 49 230 | 49 247 | 248 (247,2) |
| C 200 WRITE, aus (warm) | 9 171 051 | -- | -- | -- | -- | -- | -- | 745 (744,9) |
| **C 200 WRITE, ISR an** | 9 272 610 | **188** | 188 | 188,3 | **49 272** | 49 232 | 49 250 | 753 (753,1) |

(Die kalten Laeufe sind laenger: erster Kopfzugriff/Motor, Spur 15 -> 0; `warm` und `an` starten gleich.  Die Zeilen B/C `aus (kalt)` stehen im Log.)

* **Gehen Ticks verloren?  Nein.**  In jeder Phase gleichen der Zaehler im Gast, die Logpunkte und die aus den Takten erwartete Zahl einander (letzte Stelle).  Kein Abstand ueber 1,03 Perioden.
* **Jitter:** die Luecken liegen in A, B, C und im Leerlauf bei 49 230..49 277 (+-30 Takte um 49 248).  In frueheren Laeufen (r4/r7, `itest.mac` mit dem Zaehler-ISR ohne Tastaturabfrage) zeigten sich
  einzelne Ausreisser: **+-660 Takte (0,27 ms)** abwechselnd in Phase P (der 50-Hz-Tick faellt auf jeden vierten 5-ms-Tick des BIOS und wartet dann dessen ISR ab) und **+1660/-1677 Takte (0,68 ms)** einmal
  in Phase B (Taste bzw. 1-s-Uhr-ISR des BIOS; Ursache dort nicht getrennt).  Groesste beobachtete Verspaetung eines Ticks: **0,68 ms** gegen 20 ms Periode.
* **Die BIOS-ISRs laufen weiter,** auch waehrend `READ`/`WRITE` und waehrend der Konsolausgabe: BIOS-5-ms-Zaehler (`0041H/0042H`) = Takte / 12 312 in **jeder** Phase.  Die BIOS-Uhr (`0050H..0052H`, in der
  Bildschirmecke) zaehlt weiter: am Anfang der Leerlaufphase 20:15:34, am Ende 20:15:44 (BCD, 10 s); die Ecke zeigt nach dem Lauf wieder `20:16:57` (waehrend der Konsolausgabe wird sie weggescrollt).
* **Das BIOS liest richtig mit Fremd-ISR:** Pruefsumme der 400 Saetze (je 128 B) im Lauf `aus (warm)` und im Lauf `an` gleich (`F537`), Lesefehler 0.  400 Saetze = Spur 0..15 der Wurzeldiskette;
  dass das BIOS dieselben Saetze wie die Diskette liefert, ist Gegenstand von C1.6, hier nur "mit ISR == ohne ISR".
* **Das BIOS schreibt richtig mit Fremd-ISR:** 200 Saetze mit `WRITE` C=1: Schreibfehler 0, Rueckleseabweichungen 0 (alle drei Laeufe).  Host (`k1520disktool save-as b.hfe b.img`, danach Mustersuche und Vergleich mit dem
  Original): **genau 200 Saetze unterscheiden sich**, alle in den Spuren 40..47 des Abbilds, jeder der 200 Muster (Startwert 77H, ISR-Lauf) kommt genau einmal vor und liegt in diesen Spuren;
  sonst wurde nichts veraendert.  (Das Abbild war eine `--rw`-Kopie im Arbeitsordner.)
* **Kosten des ISR:** mit Tastaturabfrage ueber `CONST` je Tick gegen `aus (warm)`: A +0,9 %, B +2,5 %, C +1,1 % Laufzeit (~450 Takte je Tick, davon ~60 fuer den blossen Zaehler:
  der Zaehler-ISR allein kostete 0,1-0,2 %, Lauf r4).
* **Tastatur:** vier waehrend B/C eingetippte Zeichen `wxyz` kamen alle im ISR an (`KQ: 04 wxyz`), der BIOS-Puffer war danach leer (`KBD:` leer).  Das BIOS sammelt Tasten selbst in seiner 5-ms-ISR
  (C1.5 §4) -- im Lauf ohne ISR-Abfrage (r6) standen dieselben vier Zeichen unveraendert im BIOS-Puffer (`KBD: wxyz`).

## 3. Fehlende Faehigkeiten des Emulators (Merkposten nach O5)

`~/projects/a5120emu/doc/merkposten/itrace_luecken.md` (uncommittet): `itrace` verzeichnet nicht jede angenommene Unterbrechung (im Lauf r7: 1407 `vec=FA`-Zeilen gegen 1454 ISR-Eintraege laut Logpoint
und Zaehler; in den Fenstern 454/464, 177/186, 52/61, im Leerlauf 490/500).  Behelf hier: `logpoint` auf der ISR (Treiber).  Ausserdem Wunsch: Tasten waehrend eines laufenden `g` zeitlich verteilt einspeisen
(`keys` laeuft die Maschine selbst).

## 4. Schlussfolgerungen

* **§3.2 / E2 (a) bestaetigt.**  Vektoreintrag in die CP/A-Tabelle (`F7FAH` fuer CTC 0DH, Basis nicht aendern) mit weiterlaufenden BIOS-ISRs: keine Tickverluste (Abnahmekriterium "nicht ueber 1 Tick"
  ist mit grossem Abstand erfuellt: Verspaetung <= 0,7 ms, nie ein ausgefallener Tick), Daten beim Lesen/Schreiben unveraendert.  Nicht gemessen: ein ISR mit der vollen Arbeit von `ISR_TAKT`/`ISR_ANFRAGE`
  (EM-Zugriffe, PIO A32); der ISR laeuft auf dem Stapel des Unterbrochenen -- der Stapel von `mutos_io` (jetzt `CB68`, C1.5 §6, muss ohnehin unter CB00) braucht Reserve fuer BIOS-`READ` plus ISR plus `CONST`.
* **§3.8 / E6: Empfehlung (b) fuer die Tastatur, nicht (a).**  Das BIOS pollt `5CH/5DH` in seiner 5-ms-ISR und waehrend `READ`/`WRITE` weiter (gemessen: 5-ms-Zaehler laeuft in allen Phasen, Zeichen gehen
  nicht verloren); `mutos_io` bekommt die Tasten billig ueber `CONST`/`CONIN` im 50-Hz-ISR (+450 Takte je Tick, ~0,9 % Laufzeit, funktioniert waehrend `READ`/`WRITE` und `CONOUT`).  Option (a) (eigenes Pollen)
  braeuchte `tim5of` (C1.5 §1: stoppt die BIOS-Tastaturabfrage; *abgeleitet*, nicht gemessen: da Kanal 3 aus Kanal 2 zaehlt, laeuft dann auch die 1-s-Uhr nicht mehr) -- Uhr weg, ausserdem stehlen sich zwei
  Leser an 5CH Zeichen.  Der Einwand "Tastatur nur bei freier Hauptschleife" aus E6 (b) trifft nicht zu, solange `CONST` aus dem ISR gerufen wird.  Nicht gemessen: lange Tastenfolgen / Wiederholung
  waehrend Plattenzugriff (nur vier Zeichen); Ausgabe: `CONOUT` aus dem Hauptprogramm funktioniert mit laufendem ISR (Phase B), `CONOUT` **aus** dem ISR waere wegen `intcrt` (C1.5 §4) gesondert zu pruefen.
