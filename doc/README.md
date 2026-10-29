# Dokumentation -- Wegweiser

Alles ist Deutsch, soweit nicht anders vermerkt.  Aussagen sind als *gemessen/belegt* oder *vermutet* gekennzeichnet.
Verweise auf `k1520emu: <pfad>` zeigen in das Emulatorprojekt (`~/projects/a5120emu`, Nachbarordner), das hier nicht kopiert wird.

## Reihenfolge zum Einlesen

1. `../README.md`, `../CLAUDE.md` -- Ziel, Aufbau, Arbeitsregeln.
2. `plan/39_mutos8000.md` -- das System: Bootkette, Disketten, Dateisystem, Bedienung im Emulator (Entwurf 39, groesstes Dokument).
3. `system/befund.md` -- Befund K0: was der Kernel `mutos_1216` ist (Abbild, Segmente, Herkunft).
4. `plan/41_kernel.md` -- Konzept und Stand des Kernel-Rueckbaus (APs K0..K11).
5. `plan/40_mutos_io.md` + `mutos_io/` -- die U880-Seite.
6. `werkzeugkette/` und `kernel/` -- Einzelheiten, bei Bedarf.

## Verzeichnisse

| Ordner | Inhalt |
|--------|--------|
| `plan/` | Entwuerfe 39 (System), 40 (`mutos_io`), 41 (Kernel): Ziele, Stand, Entscheidungen |
| `system/` | `befund.md` -- erster Befund zum Kernel-Abbild |
| `kernel/` | `kernel_struktur.md` (Laufabdeckung, Funktionen), `kernel_namen.md` (Namen, Tabellen), `header_belegstand.md` (Header), `c_rueckbau.md` (C-Rueckbau, Abweichungen), `linkbau.md` (Neubinden aus Modulen), `gesamtbau.md` (+`gesamtbau_adressen.txt`; Selbstbau und Boot) |
| `mutos_io/` | `analyse.md` (Semantik der U880-Seite), `bauanleitung.md`, `merkposten.md` (Festlegungen mit Waechtern) |
| `werkzeugkette/` | `k1_cc_im_gast.md` (cc/as/ld im Gast), `as_dialekt.md`, `objformat.md` (a.out/Archiv; `libc_signaturen.txt`), `make.md` (unser `make`) |
| `referenz/` | Kopien aus dem Emulatorprojekt: `a5120_16.md` (EM256/U8001), `em1024.md` (1-MB-Modul), `udos_diskettenformat.md`. Original und Pflege bleiben im Emulator (`k1520emu: doc/design/17_a5120_16.md`, `k1520emu: doc/design/42_*`, `k1520emu: doc/udos_diskettenformat.md`) |
| `disketten/`, `userspace/` | noch leer (Platz fuer Diskettenreferenz und Userspace-Dokumentation) |

## Werkzeuge

Bauen/Testen: `./mk help`.  Werkzeug-Beschreibungen: `../tools/disks/README.md` (Diskettenbau), `../mutos_io/README.md`,
`../userspace/make/README.md`.  Der Emulator selbst: `k1520emu: tools/k1520dbg.md`, `k1520emu: tools/k1520disktool.md`,
`k1520emu: doc/merkposten/disktool.md` (MUTOS-Dateisystem im DiskTool).
