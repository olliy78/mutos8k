# C5.2 Waechter, Doku, Abschluss (Plan 48)

**Stand: erledigt**, 2026-11-18.  Arbeitsordner `/tmp/mplus/c5_2/` (`lang.log`, `lang/boot/lauf.log`).  *gemessen* soweit nicht anders bezeichnet.

## 1. Langtest
* `tests/test_plus_cpa_lang.py::test_lang_arbeitstests_ueber_cpa` (`gast`, nur mit `K1520_PLUS=1`): ruft `cpa_lauf.py boot` mit dem Original-Kernel (`cpa_disk.bootdiskette` inkl. Workbench-Bau, M8KBOOT, b1..b11, pp, pi, pf) und verlangt Exit 0, `bewerten: no failure`, kein `FAILURE`.
* Lauf: `K1520_PLUS=1 MPLUS_ARBEIT=/tmp/mplus/c5_2/lang python3 -m pytest -q -s tests/test_plus_cpa_lang.py` -> **1 passed in 156.88 s** (2026-11-18).
* Der Lauf ist der Arbeitstest von C4.2 mit Original-Kernel, jetzt als Waechter; der Plan (15-30 Min.) war zu hoch geschaetzt.

## 2. Dokumentation
* `doc/plus/cpa.md` (neu), `mutos_io/cpa/README.md` (Verweise, Bytegleichheit ab C3.2 entfaellt), `doc/plus/abweichungen.md` (Zeile C5.2; alle Zeilen C2.4a, C2.4b, C3.4, C4.1 haben Test/Befund in der Spalte *Pruefung*),
  `doc/plan/51_festplatte.md` (GIDE-Laufwerksbuchstaben E: bis L: bei vier Floppys, C: bis J: nur bei 2 Floppys; erstes GIDE-Laufwerk E: traegt `@OS.COM`).
* Drucker-Konfigurierbarkeit (heute fest 7O2): nur als offener Punkt in `cpa.md` §5.  Plan 48 selbst nicht geaendert (Stand-Zeile §10 setzt die leitende Sitzung).

## 3. Fixpunkt ueber CP/A (O6, optional): **nicht ausgefuehrt**
Grund: `gastbau.fixpunkt` ruft `G.ladediskette` und `gast_as.gast_befehle` (UDOS-Weg) fest auf und benutzt `bauen(..., boot_hfe=, extra=, d3=, rueck_extra=)`, dessen Bau ebenfalls `gast_as` nutzt;
`cpa_lauf.gast_befehle` kennt `quelle_hfe`/`extra_dateien`/`mnt` nicht.  Ein Fixpunkt ueber CP/A braucht damit eine Aenderung an `gastbau.py` (Plan 48 §9.0 und Plan 47 §6.2: nur importieren) oder eine Kopie des Ablaufs (Doppelcode).  Nicht billig, daher offen
(Aufwand: ~30 Min. Gastlauf plus Umbau; Voraussetzung ist eine Entscheidung, `gastbau.py` um eine Boot-/Lauf-Funktion zu parametrisieren).
