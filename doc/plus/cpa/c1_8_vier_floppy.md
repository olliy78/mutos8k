# C1.8 CP/A-Variante mit vier Floppy-Laufwerken (Sonde)

Stand 2026-11-17, Plan 48 §7 C1.8.  Arbeitsordner `/tmp/mplus/c1_8/` (Kopie der Workbench in `wb0/` fuer die Erste Sonde, `wb/` fuer die 4-Floppy-Fassung).
Alle Aussagen *gemessen*, soweit nicht als abgeleitet/Annahme bezeichnet.

## 1. Ergebnis in Kuerze

* **Abnahme erreicht:** bootfaehige 4-Floppy-Systemdiskette, Kopfzeile und BIOS-Anfang gemessen (§4).
* **Erste Sonde bestanden:** der Bau in der Kopie ohne Oberflaeche liefert `@OS.COM` **bytegleich** zur Emulator-Systemdiskette (§2).
* Mit vier Floppys wird das BIOS **0100H Byte groesser**: BIOS-Anfang **CA00** (2 Floppy: CB00), BDOS BC06, TPA `100H - 0BC05H`.
  `mutos_io` (9000..C968) passt noch, aber mit nur 98H = 152 Byte bis zum BIOS-Anfang (§5).
* GIDE-Laufwerke heissen mit vier Floppys **E: bis L:** (nicht C: bis J:).

## 2. Erste Sonde: Bauweg ohne Oberflaeche

Quelle: `~/projects/CPA_Workbench` (Git `0045dc6`, 2026-11-14, sauber), nur gelesen.  Kopiert wurden `src config prebuilt tools additions diskdefs cpaFormates.cfg`
(~7 MB).  Die `.config` der Workbench gehoert zu einer anderen Variante (`bc_a5120`) und wurde **nicht** benutzt.

`build_os` patcht `setup.mac` nicht selbst; das macht in der Oberflaeche `patch_mac.py`.  Ohne Oberflaeche geht es ueber den Builder (`run_patch_mac`),
Arbeitsverzeichnis = Kopie (patch_mac.py arbeitet mit relativen Pfaden):

```python
# Entwurf, nicht eingecheckt (Ort: siehe §6).  Aufruf: python3 bau.py <kopie> <anzdisk|->
import sys, os, importlib.util
wb = os.path.abspath(sys.argv[1]); anz = sys.argv[2]
os.chdir(wb)
spec = importlib.util.spec_from_file_location("cpa_builder", wb + "/tools/cpa_builder.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
B = m.CPABuilder(wb)
cfg_path = wb + "/.config"
open(cfg_path, "w").write("CONFIG_VARIANT_gide_a5120=y\n")
B.run_patch_mac(cfg_path, "gide_a5120", "extract")     # Werte aus setup.mac lesen
cfg = B.load_config(cfg_path)
cfg["CONFIG_SYSTEM_CRT_K7024"] = "y"; cfg["CONFIG_SYSTEM_CRT_BWSHP"] = None
if anz != "-": cfg["CONFIG_SYSTEM_ANZDISK"] = anz
B.save_config(cfg, cfg_path)
B.run_patch_mac(cfg_path, "gide_a5120", "patch")       # zurueck in setup.mac
B.build_os(cfg)                                          # build/@os.com (+ k2526ul4.bin)
```

* `bau.py <wb0> -` (nur `crt = k7024`): `@OS.COM` 16640 Byte, SHA-1 `ed796d01...`, `cmp` mit `k1520disktool get <Emulator-Systemdiskette> '@OS.COM'` -> **gleich**.
  Der Patch aendert in `setup.mac` nur `crt` (und entfernt Leerzeichen am Zeilenende, `diff` gemessen).  Laufzeit des Baus ~10 s.
* `bau.py <wb> 4`: `@OS.COM` 16768 Byte, SHA-1 `97bbdca9...`, M80 `/p:0B380`, "No Fatal error(s)", "No Undefined Symbols".
* `diskA..diskD` in `bios.mac:712-733` folgen `anzdisk` selbst (alle `11580` = K5601), keine weitere Aenderung noetig.  `biosln` waechst um `anzdisk*40H` (`bios.mac:240`),
  dazu kommen Diskettenpuffer/DPB (`biosgipb.mac` je `anzdisk`).

## 3. Systemdiskette

Die Systemspuren (15104 B) enthalten den festen SYL-Lader, **nicht** `@OS.COM`; der Lader holt `@OS.COM` aus dem Dateisystem.  Also genuegt:

```
cp <k1520emu>/disks/a5120_cpa_gide/a5120_cpa_gide_k7024_2fdd_8gide_system.hfe sys4.hfe
k1520disktool rm  sys4.hfe '@OS.COM'
k1520disktool put sys4.hfe wb/build/@os.com        # legt @os.com an; das Verzeichnis zeigt @OS.COM
```
`boot-get` der neuen Diskette = `boot-get` der alten (Systemspuren unveraendert, `cmp` gleich); `get` liefert die neue `@OS.COM` zurueck (gleich).
`build_diskimage` der Workbench wurde nicht gebraucht (Diskette der Emulatorprojekts als Vorlage mit allen Werkzeugen).

## 4. Start mit vier Floppys und GIDE (gemessen)

```
k1520dbg --em em256 --laderom ul4 --gide=0xD0 --gide-image platte.img.gz --laufwerke K5601,K5601,K5601,K5601 \
         sys4.hfe -b rfm.hfe -c rfm.hfe -d rmfm.hfe -x s4.dbg      # rfm = a5120_mutos8000_root_fm.hfe, rmfm = ..._root_mfm.hfe (Kopien)
```
`A>` nach 24,6 Mio. Takten.  Kopfzeile:
* `GIDE-CP/A (mod. KW), Version 31.07.25, TPA 100H - 0BC05H`
* `Disketten: A:5"(80,DD,DS)/B:5"(80,DD,DS)/C:5"(80,DD,DS)/D:5"(80,DD,DS)`
* `GIDE-Modul auf Adresse 0D0H ... 520 Cyl; 16 Hd; 63 Sec; GIDE-Laufwerke E: bis L:`, `RTC 72421 auf Adresse 0D5H`
* `d 0x0000 8` -> `C3 03 CA 00 00 C3 06 BC`: BIOS-Warmstart **CA03**, **BIOS-Anfang CA00**, BDOS **BC06**.
* `r` -> `I=F7 IM=2` (Vektortabelle unveraendert F700).
* `DIR E:` liest die GIDE-Platte (`@OS.COM`, `DATE`, `HDFORMAT`, `HDINFO`, `PIP`, `SYSWRCPA`, `TIME`, `WDAY`).
* `DIR C:` und `DIR D:` mit den MUTOS-Wurzeldisketten (FM bzw. MFM): wie §2.1 Punkt 3 Muell-Eintraege (`C:   :   :`), **kein BDOS-Fehler**; beweist nur,
  dass Spur 0/1 lesbar sind, nicht die Geometrie (C1.6).  `STAT DSK:` gibt es auf der Diskette nicht (`STAT?`).
* Ohne `--laufwerke` wurde die 4-Floppy-Diskette nicht gestartet (Annahme aus §2.1 Punkt 4: fuer vier Laufwerke noetig; hier mit dem Schalter gemessen).

## 5. Folgen fuer `mutos_io` (Entscheidung E3)

* Platz: 2 Floppy BIOS ab CB00, 4 Floppy ab CA00.  `mutos_io` 9000..C968 laeuft bis CA00 mit **152 Byte** fuer Stapel/Reste; in der 2-Floppy-Lage reichte es bis CB68
  (*abgeleitet* aus §2.1: dort ueberdeckt der Stapel die ersten 68H Byte des BIOS).  Bei vier Floppys darf der Stapel
  **nicht** ins BIOS: Stapel unter C968 verlegen (C1.4 liefert, was dort liegt) oder `mutos_io` um etwa 100H verkleinern/verschieben.
* Das ist kein Grund gegen E3(a): BDOS (BC06..C9FF) wird ohnehin ueberschrieben, die Lage 9000..CA00 bleibt moeglich, wenn der Stapel passt.  *Abgeleitet*, Messung erst in C3.
* TPA nach dem Start entfaellt ohnehin; fuer CP/A-Programme (Lader `M8KBOOT.COM`) sinkt die TPA von 0BD05H auf 0BC05H.

## 6. Vorschlag zu O3/E9 (Ablage der Konfiguration)

*Empfehlung:* Konfiguration **in diesem Repo** (`mutos_io/cpa/system/`), Bau ueber eine Kopie der Workbench; die Workbench bleibt unveraendert.
* Im Repo liegen nur: eine kleine Textdatei mit den Abweichungen von der Workbench-Vorgabe (`crt = k7024`, `anzdisk = 4`, sonst Vorgabe der Variante `gide_a5120`),
  das Bauskript (Entwurf §2 als `tools/plus/cpa_system.py`, Exit 77 ohne Workbench/Emulator) und die **Pruefsumme** der erwarteten `@OS.COM`
  (hier `97bbdca9...`, voller SHA-1 `97bbdca995953cc928e5b09cc0d3ae32d9a2ef45`).
* Das Skript legt jedes Mal frisch eine Kopie (`src config prebuilt tools additions diskdefs cpaFormates.cfg`) unter `/tmp/mplus/` an, baut und prueft den SHA-1;
  Workbench-Stand (`git rev-parse HEAD` = `0045dc6`) wird im Skript fest eingetragen und beim Lauf verglichen; bei anderem Stand Warnung statt stiller Abweichung.
* Wuerde der Projektinhaber eine fertige 4-Floppy-Variante in der Workbench pflegen (E9 b), entfiele die Kopie, aber C5 haengte an einem fremden Stand.
* Die fertige Systemdiskette (`sys4.hfe`) wird gebaut, nicht eingecheckt (`disks/gebaut/`).

## 7. Auffaelligkeiten

* `~/projects/CPA_Workbench/.config` gehoert zu `bc_a5120` (nicht `gide_a5120`); ohne eigene `.config` extrahieren (`extract`) und dann aendern, sonst wuerde die falsche Variante gebaut.
* `build_os` hat eine Aktualitaetspruefung (`_os_is_up_to_date`): in einer wiederverwendeten Kopie wird nicht neu gebaut, wenn `build/@os.com` neuer ist als die Quellen;
  das Skript soll jedes Mal in eine frische Kopie bauen.
* `build_os` ruft zuletzt `build_urlader` (`build/k2526ul4.bin`, 1024 B) mit auf; harmlos.
* Das Quellverzeichnis bleibt unberuehrt (`git status` der Workbench sauber, vor und nach).
