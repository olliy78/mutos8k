# CP/A-Variante fuer MUTOS (vier Floppys, GIDE, RTC)

Konfiguration der Variante `gide_a5120` der CPA_Workbench mit Abweichungen aus `konfig.txt`
(`crt = k7024`, `anzdisk = 4`).  Plan 48 C2.2, Befund `doc/plus/cpa/c2_2_system.md`, Entwurf `doc/plus/cpa/c1_8_vier_floppy.md`.

* Workbench-Stand: `0045dc6` (`git rev-parse HEAD` in `~/projects/CPA_Workbench`; anderer Stand = Warnung).
* Erwartete `@OS.COM`: 16768 Byte, SHA-1 `97bbdca995953cc928e5b09cc0d3ae32d9a2ef45`.
* Bau: `python3 -I tools/plus/cpa_system.py bauen --arbeit /tmp/mplus/c2_2` (frische Kopie der Workbench unter `<arbeit>/wb/`,
  die Workbench selbst bleibt unberuehrt), Pruefung: `... pruefen --arbeit ...` (bootet die Diskette `<arbeit>/sys4.hfe`).
* Die Systemdiskette wird gebaut, nicht eingecheckt.
