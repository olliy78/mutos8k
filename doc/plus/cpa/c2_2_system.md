# C2.2 CP/A-Variante mit vier Floppys (`tools/plus/cpa_system.py`)

Stand 2026-11-18, Plan 48 C2.2.  Alle Aussagen *gemessen* (Arbeitsordner `/tmp/mplus/c2_2/`), soweit nicht anders bezeichnet.

* **Erste Sonde bestanden:** frische Workbench-Kopie (Stand `0045dc6`), `anzdisk = 4`, `crt = k7024` -> `@OS.COM` 16768 Byte, SHA-1 `97bbdca995953cc928e5b09cc0d3ae32d9a2ef45`
  (gleich dem Wert aus `c1_8`).  Bau ~10 s.
* **Abnahme:** `python3 -I tools/plus/cpa_system.py pruefen --arbeit /tmp/mplus/c2_2` -> 0.  Kopfzeile: `GIDE-CP/A (mod. KW), Version 31.07.25, TPA 100H - 0BC05H`,
  `Disketten: A:..D: 5"(80,DD,DS)`, `GIDE-Modul auf Adresse 0D0H ... GIDE-Laufwerke E: bis L:`, `RTC 72421 auf Adresse 0D5H`; `DIR E:` zeigt `@OS`;
  Uhr in der Statuszeile laeuft (`00:57:35` -> `00:57:41`), die RTC-Bytes bei `d 0x0050 3` gehen `00 57 37` -> `00 58 59`; `git status` der Workbench davor/danach gleich (sauber).
* **Aufbau:** Konfiguration `mutos_io/cpa/system/konfig.txt` (nur Abweichungen), eigene `.config` (nie die der Workbench), `run_patch_mac extract` -> Werte -> `patch` -> `build_os`;
  jedes Mal frische Kopie.  Systemdiskette = Kopie von `cpa.GIDE_SYS` mit ersetzter `@OS.COM` (`c1_8` §3).
* **Offener Punkt aus E5 gemessen:** die 4-Floppy-Diskette bootet auch **ohne** `--laufwerke` (nur A: angegeben): gleiche Kopfzeile mit A:-D:, `DIR E:` liest die Platte.
  Der Schalter ist also fuer den Start nicht noetig; `pruefen` setzt ihn trotzdem (B:-D: sind dann angeschlossen).  Ob B:-D: ohne den Schalter ansprechbar sind, wurde nicht gemessen.
* B:-D: sind in `pruefen` Kopien der GIDE-Systemdiskette (nur Anschluss, kein Inhaltstest; MUTOS-Wurzeldisketten siehe `c1_8` §4).
