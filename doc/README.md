# Dokumentation -- Wegweiser

Alles ist Deutsch, soweit nicht anders vermerkt.  Aussagen sind als *gemessen/belegt* oder *vermutet* gekennzeichnet.
Verweise auf `k1520emu: <pfad>` zeigen in das Emulatorprojekt (`~/projects/a5120emu`, Nachbarordner), das hier nicht kopiert wird.

## Reihenfolge zum Einlesen

1. `../README.md`, `../CLAUDE.md` -- Ziel, Aufbau, Arbeitsregeln.
2. `plan/39_mutos8000.md` -- das System: Bootkette, Disketten, Dateisystem, Bedienung im Emulator (Entwurf 39, groesstes Dokument).
3. `system/befund.md` -- Befund K0: was der Kernel `mutos_1216` ist (Abbild, Segmente, Herkunft).
4. `plan/41_kernel.md` -- Konzept und Stand des Kernel-Rueckbaus (APs K0..K11).
5. `plan/40_mutos_io.md` + `mutos_io/` -- die U880-Seite.
6. `plan/42_unix_herkunft.md`, `herkunft/README.md` -- Herkunft der Quellen (V7 / System III / WEGA), Rundlauf-Beweis.
7. `userspace/README.md` -- Stand der Userspace-Programme (Originale bytegleich, V7-Ergaenzungen, Werkzeugkette), mit den Plaenen
   `plan/44_userspace_cmd.md`, `plan/45_v7_ergaenzungen.md`, `plan/52_werkzeugkette.md`.
8. `werkzeugkette/` und `kernel/` -- Einzelheiten, bei Bedarf.

## Verzeichnisse

| Ordner | Inhalt |
|--------|--------|
| `plan/` | Entwuerfe 39 (System), 40 (`mutos_io`), 41 (Kernel), 42 (Herkunft), 43 (Kernel bytegleich aus C), 44 (Userspace-Rueckbau), 45 (V7-Ergaenzungen), 52 (Werkzeugkette): Ziele, Stand, Entscheidungen.  Plaene 46-51 (Umbauten ohne Bytegleichheit) liegen im Branch `mutos-plus` |
| `herkunft/` | Herkunft je Kernelmodul (V7/System III/WEGA-Vergleich), `rundlauf.md` (Quelle -> Werkzeugkette -> Bytes), `README.md` (Uebersicht) |
| `system/` | `befund.md` -- erster Befund zum Kernel-Abbild; `bekannte_fehler.md` -- latente Fehler im Originalcode (auf `main` erhalten, auf `mutos-plus` behoben) |
| `kernel/` | `kernel_struktur.md` (Laufabdeckung, Funktionen), `kernel_namen.md` (Namen, Tabellen), `header_belegstand.md` (Header), `c_rueckbau.md` (C-Rueckbau, Abweichungen), `linkbau.md` (Neubinden aus Modulen), `gesamtbau.md` (+`gesamtbau_adressen.txt`; Selbstbau und Boot) |
| `mutos_io/` | `analyse.md` (Semantik der U880-Seite), `bauanleitung.md`, `merkposten.md` (Festlegungen mit Waechtern) |
| `werkzeugkette/` | `k1_cc_im_gast.md` (cc/as/ld im Gast), `as_dialekt.md`, `objformat.md` (a.out/Archiv; `libc_signaturen.txt`), `make.md` (unser `make`) |
| `referenz/` | Kopien aus dem Emulatorprojekt: `a5120_16.md` (EM256/U8001), `em1024.md` (1-MB-Modul), `udos_diskettenformat.md`. Original und Pflege bleiben im Emulator (`k1520emu: doc/design/17_a5120_16.md`, `k1520emu: doc/design/42_*`, `k1520emu: doc/udos_diskettenformat.md`) |
| `userspace/` | `README.md` (Stand, Herkunftstabellen, Stolpersteine, c2-Gegenprobe), `pipeline.md` (Rueckbau-Pipeline), je Arbeitspaket ein Dokument: `cmd_*` (Originalprogramme, Plan 44), `erg_*` (V7-Ergaenzungen, Plan 45), `wk_*` (Werkzeugkette, Plan 52), dazu `sh.md`, `init.md`, `libc_alt.md` u. a. |
| `disketten/` | noch leer (Diskettenbau steht in `../tools/disks/README.md`, Ergaenzungsdisketten in `userspace/erg_e6.md`) |

## Werkzeuge

Bauen/Testen: `./mk help`.  Werkzeug-Beschreibungen: `../tools/disks/README.md` (Diskettenbau), `../mutos_io/README.md`,
`../userspace/make/README.md`.  Userspace: `../tools/userspace/pipeline.py` (Rueckbau gegen ein Original, `userspace/pipeline.md`),
`erg.py` (V7-Ergaenzungen ohne Original, `userspace/erg_e0.md`), `libc_alt.py` (Bibliotheksstand der Originalprogramme),
`c2gegen.py`/`c2layout.py` (Gegenprobe mit dem echten c2, `userspace/wk_w5e.md`), `cvopt_z8k.py` (c1-Codetabellen, `userspace/wk_w6.md`),
`wk_w8.py` (`libc.a` je Glied, `userspace/wk_w8.md`).  Der Emulator selbst: `k1520emu: tools/k1520dbg.md`, `k1520emu: tools/k1520disktool.md`,
`k1520emu: doc/merkposten/disktool.md` (MUTOS-Dateisystem im DiskTool).
