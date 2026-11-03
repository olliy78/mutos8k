# Quellen und Herkunft

## Originalabbilder in `disks/original/`

Alle Dateien heissen `a5120_mutos8000_<name>` (Pfade der Ursprungsrechner nach Entwurf 39, Abschnitt 1, `plan/39_mutos8000.md`).

| Datei | Herkunft | Inhalt |
|-------|----------|--------|
| `boot_udos.dmk` (+ `boot_udos.zip`) | `~/projects/A5120.16/discs/Mutos8000_Bootdisk.dmk` | UDOS-Ladediskette, 19 Dateien inkl. `mutos_1216` (Kernel) und `mutos_io`; das Zip ist das DiskTool-Archiv davon |
| `root.td0`, `cmd.td0`, `cc1.td0`, `cc2.td0`, `disk_root_26x128.td0` | `~/projects/A5120.16/discs/DISK_*.TD0` | DISK-Satz: 5,25 Zoll, Zylinder 0 = 26x128, ab Zylinder 1 8x512, UNIX-Dateisystem |
| `m8k_root.td0`, `m8k_cmd.td0`, `m8k_bin.td0`, `m8k_usr.td0`, `m8k_root.hfe` | `~/projects/robotron/A5120/discs/MUTOS8000/M8K*.TD0` (TeleDisk 1.5, 15.04.2011) | M8K-Satz; `M8KROOT` ist als Abbild beschaedigt (Entwurf 39, 4.6.6) |
| `m8k2_{root,usr,cmd,nroff}.td0` (+ `disk_root_26x128.td0`, MFM-Wurzelabzug von 2005) | Vier Abzuege von 2008 (Entwurf 39, 10.6) | heile Wurzel/Befehle, `nroff`; Grundlage des Best-of |
| `m8k_root.zip`, `best_{bin,cc1,cc2,cmd,nroff,usr}.zip` | **abgeleitet** (`tools/disks/archiv_erzeugen.py`) | Bauarchive: Dateien + Metadaten + Bauangaben, aus denen `tools/disks/bau_*.py` die Disketten baut |

### Die Disketten als Teil von MUTOS 8000

Alle überlieferten Disketten und die Programme darauf (z. B. `nroff`, `ed`) gelten als Bestandteil von MUTOS 8000
und seines Userspace.  Einen offiziellen, vollständigen Diskettensatz kennen wir nicht; jeder Satz (DISK, M8K, M8K2)
ist eine Auswahl, wie sie an der Maschine benutzt wurde.  Der Userspace dieses Projekts entsteht deshalb als
Vereinigung aller Sätze (Best-of, je Datei mit Herkunft und Grund in `tools/disks/best_of.py`).

Die **fertigen** Disketten (`disks/gebaut/`) werden nicht eingecheckt; Referenzstand liegt im Emulator
(`k1520emu: disks/a5120_16_MUTOS/`).

## Handbuecher

* MUTOS-8000-Systemhandbuch Teil I-III, MON8000, Anwendungsbeschreibung AS 120.16:
  `~/projects/robotron/tiffe_de_Robotron/www.tiffe.de/Robotron/K1520/A5120_16/MUTOS/` (AS 120.16 gescannt, ohne Text).
* MUTOS-Handbuch Teil II, Abschnitt 3 (adb): `~/projects/A5120.16/docs/MUTOS8000_Teil_II_abschn3_adb.pdf`
  (Kopie auch unter `~/projects/robotron/MUTOS/`), ferner `mutos_sys.pdf` ebendort.

## Externe Quellen

* **WEGA / P8000**: https://github.com/OlliL/P8000 (`WEGA/src/uts` -- rueckuebersetzter Kernel, Z8001).
  Naechster Verwandter mit Quellen; nur Orientierung, nicht kopiert (`original/wega/README.md`).  Vergleichsstand: Commit `626fc77fb083b31392ccafb0d125bbc2c8127d4a` (2026-10-30), `WEGA/src/uts` (Kernel) und `WEGA/src/lib/libc/sys/` (Systemaufruf-Huellen, SCCS 1983); Ergebnisse `doc/herkunft/z8001_kontext.md`, `speicher.md`.
* **UNIX V7** (Bell Labs 1979, Caldera-Lizenz): TUHS-Archiv, https://www.tuhs.org (Unix Heritage Society).
  Liegt seit 2026-10-30 unveraendert unter `original/unix-v7/` (Herkunft, Pruefsumme: `original/unix-v7/README.md`).
* **TUHS-Sammlung `Torsten_Hippe_v7`** (zusammengestellt 1995 aus unbekannten Quellen; der Sammler ist nicht Urheber): unter `original/hippe-v7/` (Herkunft, Pruefsumme, Lizenzlage: `original/hippe-v7/README.md`).  Naechster bekannter Verwandter des MUTOS-Kernels.
* **Weitere TUHS-Baeume** (UNSW-Baender, Nijmegen-V7, V7M, V7-Patches/Addenda, Bostic-V7-Band, 2.8-2.11BSD, 3BSD, 4.1BSD, 32V, PWB, Ultrix-11, LSX, Mini-UNIX u. a.): nur zur Gegenprobe in den Arbeitssitzungen geladen und **nicht** im Repository;
  URL, Pfad im Archiv und SHA-256 je Baum stehen in `doc/herkunft/fremd.md` (Abschnitte 2 und 8) und `doc/herkunft/speicher.md` (Abschnitt 6).  Das Scratchpad ist fluechtig; zum Nachpruefen die Archive erneut laden und die Pruefsummen vergleichen.
* **Lizenzlage** der eingecheckten Fremdquellen: Abschnitt "Third-party sources" in [`LICENSE`](../LICENSE).
* **UNIX System III** (USG 1980): GitHub-Spiegel `Krush206/unix-system-III`, unter `original/sys3/` (eingecheckt auf Entscheidung des Projektinhabers; `original/sys3/README.md`).
* Schaltplaene/Geraeteunterlagen: tiffe.de (siehe `k1520emu: doc/design/16_k8915.md`, `17_a5120_16.md`).
