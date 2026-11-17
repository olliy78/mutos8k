# C1.1 Werkzeug fuer CP/A-Sonden (`tools/plus/cpa.py`)

Stand 2026-11-17, Plan 48 C1.1.  Alle Aussagen *gemessen* im Arbeitsordner `/tmp/mplus/c1_1/` (Befehl jeweils dabei), sonst gekennzeichnet.

## 1. Erste Sonde (gemessen)

`k1520dbg --em em256 --laderom ul4 --gide=0xD0 --gide-image <platte.img.gz> sys.hfe -x s.dbg` mit `gscreen "A>" 300000000`, `keys DIR\r`, `screen`:
Boot bis `A>` nach 25,0 Mio. Takten, ganzer Lauf 1,7 s Wanduhr; Schirm zeigt `GIDE-Modul auf Adresse 0D0H`, `RTC 72421 auf Adresse 0D5H`, `DIR` listet
`@OS.COM`, `LINKMT.COM`, `M80.COM` ... (30 Dateien auf der Systemdiskette).  Plan 48 §2.1 Punkt 1 ist damit bestaetigt.

## 2. Ergebnis der Abnahme (`python3 -I tools/plus/cpa.py probe --arbeit /tmp/mplus/c1_1`, 9 s Wanduhr, Exit 0)

* **HALLO**: `HALLO.COM` (128 B, aus `versuche/plus_cpa/hallo.mac`, M80 + LINKMT) auf der Systemdiskette, am Prompt gestartet -> `HALLO MUTOS` auf dem Schirm.
* **EM256ADR** unter GIDE-CP/A: `=> Basis A8H: Attributspeicher erkannt, 16 Seiten geprueft`; **EM16ABL**: Zeilen A-G je `OK`, `ERGEBNIS: alle Ablaeufe OK`.
  Dieselben Zeilen (wortgleich) unter dem normalen CP/A (`a5120_cpa_k5601_system.hfe`, ohne GIDE, ohne `--laderom ul4`).  Das gleiche Ergebnis heisst:
  GIDE-Modul und RTC stoeren die EM256-Ansteuerung (Ports A8H-AFH/B0H-B7H, PIO, Interruptwege) nicht.
* **M80-Namenslaenge**: In `hallo.mac` stehen `LBLONE1`/`LBLONE2` (gleich in den ersten 6 Zeichen), auch als `PUBLIC`.  M80 meldet `No Fatal error(s)`, im Listing haben
  sie verschiedene Adressen (0129'/0138'), beide Texte kommen verschieden aus.  Zusaetzlich von Hand (`/tmp/mplus/c1_1/m2/`, zwei Module, `EXTRN`/`PUBLIC` mit denselben
  zwei Namen, LINKMT `X=MA,MB/p:100`): beide Verweise werden richtig aufgeloest (`LD DE,(LBLONE1)` -> 1111H, `LD HL,(LBLONE2)` -> 2222H).
  **Befund: M80 und LINKMT unterscheiden Namen mindestens bis zum 7. Zeichen, die 6-Zeichen-Annahme aus Plan 48 §6.5 trifft nicht zu**; die Regel (6 Zeichen eindeutig)
  bleibt als vorsichtige Hausregel zulaessig, ist aber nicht noetig.  Die genaue Obergrenze wurde nicht gemessen (nur 7).

## 3. Beobachtungen beim Bau des Werkzeugs (gemessen)

* Der normale CP/A fragt beim Boot die Uhrzeit (`Bitte Uhrzeit eingeben! HH:MM:SS`); ohne Eingabe verschluckt er die ersten Tasten.  `lauf(gide=False)` bestaetigt mit CR.
  Das GIDE-CP/A hat die RTC und fragt nicht.
* `EM256ADR`/`EM16ABL` halten seitenweise mit `-- weiter mit Taste --` an; die Taste wird dabei verbraucht (Folge: vom naechsten getippten Befehl fehlt sonst das erste Zeichen).
  `cpa.taste()` schickt Leerzeichen.
* Die Systemdiskette traegt `EM16ABL.COM`/`EM256ADR.COM` schon; das DiskTool ueberschreibt nicht, `diskette()` loescht gleichnamige Dateien vorher.
* `ORG 0100H` im relozierbaren `CSEG` plus LINKMT `/p:100` ergibt Code bei 0200H (die `.COM` laeuft dann nur, weil 0100H..01FFH Nullen = NOPs sind) -- `ORG` weglassen.
* Das GIDE-Abbild wird je Lauf als Kopie (`.gz`, 295 KB) in den Arbeitsordner gelegt; Schreibzugriffe landen dort.

## 4. API von `tools/plus/cpa.py` (Kopf der Datei ist massgebend)

`GIDE_SYS`, `GIDE_PLATTE`, `CPA_SYS`, `EM_DIR`; `fehlt(werkzeug=False)`, `Fehlt`; `diskette(arbeit, name, quelle, dateien)`; `com(name, quellordner, meldungen=None)`;
`lauf(arbeit, zeilen, a, b, c, d, laufwerke, em, gide, frist)` mit Schritten `cmd(text, warte, takte)` / `taste(zeichen, warte, takte)` (nach jedem Schritt ein `screen`);
`schirme(log)`, `schirm(log)`; `probe(arbeit)`; Kommandozeile `probe --arbeit DIR` (Exit 0/1, 77 ohne Emulator oder ohne Werkzeugkette).  `lauf.dbg` und `lauf.log` bleiben im Arbeitsordner.

Waechter: `tests/test_plus_cpa.py` (schnell: Schnittstelle, Schirmzerlegung, Exit 77; `gast`: `probe`).
