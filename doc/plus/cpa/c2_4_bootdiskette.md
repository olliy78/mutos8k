# C2.4 Bootdiskette und Abnahme C2 (Plan 48)

**Stand: erledigt** (Abnahme erreicht), 2026-11-18.  Arbeitsordner `/tmp/mplus/c2_4/`.  Alles *gemessen*, soweit nicht anders bezeichnet.
Werkzeug `tools/plus/cpa_disk.py`, Waechter `tests/test_plus_cpa_disk.py` (schnell: Import, Exit 77; `gast`: `kstart`, ~45 s mit gebautem Workbench-Stand).

## 1. Erste Sonde

`python3 -I tools/plus/cpa_disk.py diskette --arbeit /tmp/mplus/c2_4` (~33 s, davon ~10 s Workbench-Bau) -> `boot4.hfe`; `k1520disktool ls -l` (31 Dateien, 502 KB frei):
`@OS.COM` 16768, `M8KBOOT.COM` 1024, **`MUTOS.SYS` 36352**, **`MUTOSIO.IMG` 14720** (Abbild 14696 B, vom DiskTool auf 128 B aufgerundet, wie in C2.3 beschrieben).

## 2. Inhalt der Bootdiskette

4-Floppy-Systemdiskette aus `cpa_system.systemdiskette()` (Kopie von `cpa.GIDE_SYS` mit der 4-Floppy-`@OS.COM`) plus drei Dateien:
`M8KBOOT.COM` (= `mutos_io/cpa/m8kboot.com`), `MUTOS.SYS` (`kernel` oder Original `mutos_1216`), `MUTOSIO.IMG` (`build.abbild()` der aktuellen `mutoscpa.mac`).
Kein Autostart: `M8KBOOT` bzw. `M8KBOOT K` wird am Prompt getippt.  Die Diskette wird gebaut, nicht eingecheckt.

## 3. Abnahme C2 (`python3 -I tools/plus/cpa_disk.py kstart --arbeit /tmp/mplus/c2_4` -> Exit 0)

Zwei Laeufe auf der 4-Floppy-Diskette (B:-D: = Kopien der GIDE-Diskette, nur angeschlossen; `--laufwerke K5601 x4`, `--em em256`), die Skripte sind die von C2.3 (`versuche/dbg/cpa_c2_3_*.dbg`):
* `M8KBOOT K`: EM-Segment 0 == `mutos_1216` (alle 36 352 B); Meldung `KERNEL LOADED`; letzte `RESET16` 1 -> 0; U8001 trifft `<<0>>%027E`; Zaehl-ISR `ICOUNT` = 1;
  EM 0006H = `D26A` (strenges Kriterium aus C2.3: weder 0 noch `027E`).
* `M8KBOOT` (Vollbetrieb): `(0001H)` = `CA03` -> **BIOS-Anfang CA00H** (4 Floppy; 2 Floppy: CB00H); Lage-Pruefung des Laders positiv (keine Fehlermeldung, Haltepunkt **9000H erreicht**);
  Bytes 9000H..C967H == `MUTOSIO.IMG` (14 696 B; die aufgefuellten Satzbytes bis C97FH liegen unter CA00H); EM == Kernel; letzte `RESET16` = 1 (U8001 bleibt im Reset).
* Erwartungsgemaess macht die unveraenderte UDOS-Fassung hinter 9000H nichts Sinnvolles; geprueft wird nur der Sprung.

## 4. Grenzen

* *Nicht gemessen:* ob der Start der 4-Floppy-Diskette mit Kommandozeile ausser `K`/leer sich anders verhaelt (wie C2.3); B:-D: tragen keine MUTOS-Disketten.
* Kernelabbild ist das Original; ein anderer Kernel geht ueber `--kernel` bzw. `bootdiskette(kernel=...)`, die Pruefung `EM == Kernel` gilt dann dem uebergebenen Kernel nur in `bootdiskette`; `kstart` selbst prueft immer gegen `mutos_1216`.
* Schalter und Merkposten fuer den Emulator (O5): keine neuen noetig.
