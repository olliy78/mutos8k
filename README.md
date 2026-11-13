# mutos8k -- MUTOS 8000 erforschen, dokumentieren, wieder bauen

MUTOS 8000 ist das UNIX-V7-Derivat für den robotron **A5120.16**: einen A5120 (U880) mit der Erweiterungskarte
EM064/EM256, auf der ein **U8001** (Z8001) den UNIX-Kernel fährt, während der U880 mit `mutos_io` Disketten,
Konsole und Drucker bedient.

Dieses Projekt sammelt alles, um das System zu verstehen und aus Quellen wieder zu bauen:

* **Kernel** `mutos_1216`: vollständig disassembliert, in Module zerlegt und mit den Original-Werkzeugen
  bytegleich neu gebunden; 218 von 230 Funktionen (95 %) bytegleich aus C zurückgewonnen, mit dem c2-Modell (`gesamtbau.py --c2modell`, Regeln K1-K6) alle 230.
  **MUTOS baut seinen Kernel selbst** (`make`, `cc`, `as`, `ld` im Gast) und bootet ihn.
* **`mutos_io`** (U880-Seite): rekonstruierte, kommentierte Quelle, die bytegleich zur Originaldatei baut.
* **Werkzeugkette** (`cc`/`as`/`ld`, a.out- und Archivformat, ein eigenes `make`).
* **Userspace**: ein minimales System ist komplett aus Quellen baubar -- Kernel, `mutos_io` und **33 Programme der
  Originaldisketten** (alle 11 der Wurzeldiskette inkl. `init`, `sh`, `login`, `getty`, `mount`; dazu 22 von `cmd`, u. a. `cp`, `rm`, `mv`, `mkfs`,
  `ncheck`, `icheck`), jeweils **ganzdatei bytegleich** mit dem Original (Stand 2026-11-11).  Zusätzlich 29 Programme **aus V7-Quellen**, die auf den
  Disketten fehlen (u. a. `grep`, `sort`, `find`, `diff`, `tr`, `yacc`, V7-`make`); dafür gibt es kein Original, Beleg ist Bau + Gasttest.
* **Disketten**: Originalabzüge und die Werkzeuge, die daraus lauffähige Lade-, Wurzel- und Datendisketten bauen.
* Vergleich mit den Original-Quellen von UNIX V7 (`original/unix-v7/`): läuft mit; die Userspace-Quellen sind überwiegend V7-Text mit belegten Abweichungen.

**Grenzen der Bytegleichheit** (Details: [`doc/userspace/README.md`](doc/userspace/README.md), Abschnitt „Stand und Aussagekraft"):

* Der ausgelieferte `c2` (Peephole-Optimierer) wird nicht ersetzt, sondern durch Musterregeln **nachgebildet**
  (Kernel K1-K6, Userspace R1-R64).  Bewiesen ist: C-Quelle + ausgelieferter Compiler + Regeln = Originalbytes; nicht, dass der alte `c2` genau so arbeitete.
  Viele Regeln greifen nur an einer Stelle und sind schwach belegt.
* Der libc-Teil der Programme stammt überwiegend aus dem Originalabbild (`userspace/libc_alt`); seine Gleichheit sagt nichts über die Herkunft aus.
* Dass die Abweichungen vom V7-Text die MUTOS-Fassung sind, ist eine Annahme; gemessen ist nur, dass dieser Text die Originalbytes erzeugt.
* `yacc` läuft nur in der Größenklasse SMALL (getrennte I&D startet im MUTOS-Kernel nicht, `doc/userspace/exp_ldi.md`).

## Herkunft des Kernels

Der Kernel ist ein Derivat von **UNIX V7** (nicht von System III).  Naechster bekannter Verwandter ist die TUHS-Sammlung `Torsten_Hippe_v7` (eine stark veraenderte V7-Variante; der Sammler ist nicht Urheber);
ob MUTOS direkt davon abstammt oder von einer gemeinsamen unbekannten Vorlage, ist nicht entscheidbar.  Eigenanteil sind die Anpassung an die A5120.16 (Speicher ohne MMU, Z8001-Kontext, Mailbox-Treiber, U880-Seite).
Mit dem Quelltext der Vorlagen sind inzwischen 218 von 230 Kernelfunktionen bytegleich aus C erzeugbar, mit dem Modell des älteren Kernel-`c2` alle 230 (Plan 43 §15).  Gesamtbericht: [`doc/herkunft/README.md`](doc/herkunft/README.md).  Lizenzlage der Fremdquellen: [`LICENSE`](LICENSE).

## Voraussetzung: der Emulator daneben

Die Maschine, der Debugger, das DiskTool und die Disassembler kommen aus dem Emulatorprojekt
**k1520emu** (`~/projects/a5120emu`).  `tools/emu.py` findet es über `K1520EMU` oder als Nachbarordner
`../a5120emu`.  Ohne Emulator laufen nur die reinen Host-Tests; die Gasttests werden übersprungen.

## Schnellstart

```sh
./mk test                 # schnelle Tests (Formate, Rundläufe gegen eingecheckte Ergebnisse)
./mk gast-test            # Gasttests (MUTOS im Emulator, Minuten bis Stunden; im Hintergrund)
./mk disketten            # alle Disketten nach disks/gebaut/ bauen
./mk kernel               # Kernel im Gast bauen (Selbstbau) + Boottest
```

Wegweiser durch die Dokumentation: [`doc/README.md`](doc/README.md).  Arbeitsregeln: [`CLAUDE.md`](CLAUDE.md).
