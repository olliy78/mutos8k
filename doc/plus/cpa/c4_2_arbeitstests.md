# Plan 48 C4.2 -- Arbeitstests und Leistung ueber CP/A

Stand 2026-11-18.  Nur Befund, kein Code an `mutoscpa`.  Arbeitsordner `/tmp/mplus/c4_2/` (Treiber `drv.py`, Auswertung `ana.py`, je Lauf `<weg>_<kernel>/boot/lauf.log`, `<weg>_<kernel>.out`).
*gemessen* soweit nicht anders bezeichnet.

## 1. Aufruf
* CP/A: `cpa_lauf.boot(arbeit, kernel)` (= `cpa_lauf.py boot`); UDOS: `gastbau.boot(arbeit, kernel)`.  `drv.py` ruft beide auf; beim CP/A-Weg haengt es vor dem `q` des
  Debuggerskripts `d 0xB936 0x1000` an (Stapel; E5H-Fuellung macht `mutoscpa` selbst, c3_2).
* Kernel: Original `mutos_1216` (sha256 `5e105bc0...bb3c1`, aus der Originaldiskette) und P3.4-Kernel `/tmp/mplus/p2_3/mutos_1216` (sha256 `a0e2a9c5...e97e25`, Stand `doc/plus/gastbau.md`).
* Vier Laeufe, je zwei parallel gestartet (5 s Abstand).

## 2. Ergebnis

| Kernel | Startweg | `bewerten` | Wanduhr Gastlauf | Maschinentakte gesamt |
|---|---|---|---|---|
| Original | CP/A | no failure | 125 s | 2984 Mio |
| P3.4 | CP/A | no failure | 123 s | 2984 Mio |
| Original | UDOS | no failure | 122 s | 2670 Mio |
| P3.4 | UDOS | no failure | 121 s | 2670 Mio |

**Abnahme ja:** `bewerten: no failure` mit beiden Kerneln; Stapel: tiefste benutzte Adresse **C87CH** (58 Byte unter `SP` = C8B6H), **F46H = 3910 Byte** ueber B936H (gefordert >= 100H), in beiden CP/A-Laeufen gleich.
(Die Gesamttakte sind je Weg bei beiden Kerneln auf die Mio genau gleich -- der Emulator ist deterministisch, die Kernel unterscheiden sich in diesen Tests nicht in der Laufzeit.)

## 3. Takte je Test (Mio, `gscreen`-Wartezeit bis zur Marke `END<n>`; gleich fuer beide Kernel)

CP/A: b1 45, b2 88, b3 138, b4 (cc -c) 259, b5 46, b6 33, b7 70, b8 (cc, a.out) 547, b9 (cc -O) 518, b10 (ps) 62, b11 (lp) 126, pp 46, pi 47, pf 44, Abschluss 22 -- Summe 2091.
UDOS: 34, 92, 129, 202, 33, 19, 50, 393, 387, 46, 107, 31, 30, 27, 12 -- Summe 1592.
Boot: CP/A bis `A>` 25, M8KBOOT bis `ready (r)` 24, bis `login:` 27 Mio (zusammen 76 Mio); UDOS-Boot im Skript mit festen `g`-Schritten, nicht vergleichbar aufgeloest.

## 4. CP/A gegen UDOS
* Funktional kein Unterschied: dieselben Ausgaben, kein Fehlschlag, `lp` (b11) laeuft ueber den Treiberkern aus C4.1.
* CP/A braucht **+12 % Takte gesamt, +31 % in den Tests** (Summen 2091 gegen 1592 Mio; Wanduhr nur +2..3 s, der Emulator laeuft schneller als die Takte, Host-Zeit dominiert vom Start).
  Der Aufschlag liegt in den plattenlastigen Tests (b4 +28 %, b8 +39 %, b9 +34 %, b5/b6 +40..75 % bei kleiner Basis).  Ursache **nicht gemessen**; Annahme: das Plattenpfad-Verhalten
  (GIDE/Floppy ueber BIOS `READ`/`WRITE` mit Interrupt-Wechsel auf `intstk`, c3_3 §) kostet mehr Takte je Block als der UDOS-Lader.
* Stapel: tiefste Stelle 58 Byte unter `SP` nach allen Tests (C3: 46 Byte bis `login:`); kein Risiko.

## 5. Nicht ausgefuehrt (Plan 48 C4.2 "Messen")
* Takte je Plattenblock und Verzoegerung der Konsolausgabe waehrend Plattenzugriff: nicht gemessen (kein Zaehler je Block im Gastlauf; Aufwand ein eigener Sondenlauf).  Die Abnahme verlangt sie nicht.
  Keine neue Emulatorluecke.
* Ursache des Takt-Aufschlags nicht isoliert (s. §4).
