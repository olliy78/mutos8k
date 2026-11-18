# C3.1 Namen statt Zahlen in `mutoscpa.mac` (Plan 48)

Stand: erledigt, 2026-11-18.  Arbeitsordner `/tmp/mplus/c3_1/` (`ers.py`, einmalige Ersetzung, nicht eingecheckt).

**Ergebnis (gemessen):** 23 Zahlen ersetzt (4 `.PHASE`-Basen, 5 Nachrichtenkopie, 1 Stapel, 13 Pufferzeiger); Werte unveraendert.
`python3 -I mutos_io/cpa/build.py --check` -> 0, `mutoscpa.bin` == `mutos_io/mutosio.bin` (`cmp`, 5376 Bytes).  Schnelltest `tests/test_plus_cpa_io.py`
(keine der A-Zahlen ausserhalb von `EQU`-Zeilen) gruen; gegen den Stand vor C3.1 rot (23 Zeilen), d. h. er greift.

| Zahl | Name | Stellen |
|------|------|---------|
| 9000H / 9400H / 0A400H / 0C8B6H | `SEG1_BASE` / `SEG2_BASE` / `SEG3_BASE` / `SEG4_BASE` | `.PHASE` (4) |
| 0A5A8H | `V_NACHR` (Nachricht +0 Klasse) | 3 |
| 0A5A9H | `V_NACHR+1` (Einheit) | 2 |
| 0CB68H | `INITSP` | `LD SP,` (1) |
| 0A8B6H (`0B6H,0A8H`) | `BUF_DISK` | DCB0, AUF0 |
| 0A7B6H | `BUF_LIST` (Drucker) | DCB1, AUF1 |
| 0B8B6H | `BUF_RAWFD` (Roh-Floppy) | DCB2, AUF2 |
| 0A5B6H | `BUF_CONS` | DCB3 |
| 0A636H (`36H,0A6H`) | `BUF_TTY1` | DCB4, AUF3 |
| 0A6B6H | `BUF_TTY2` | DCB5, AUF4 |
| 0A736H | `BUF_TTY3` | DCB6, AUF5 |

Die `EQU`s stehen im Kopf der Datei hinter dem Makro `FILLFF`.  Namen mit hoechstens 8 Zeichen (Gasttools).  Die Bytepaare `DB .. ,0B6H,0A8H,..` sind
als `DB ..` / `DW BUF_xxx` / `DB ..` aufgeteilt.  Uebersetzt wurden nur die beruehrten Kommentare (DCB-/AUF-Tabellenkopf).
Hinweis: Der Plan-Name `PUF_xxx` wurde nach der Sprachregel englisch zu `BUF_xxx`.
