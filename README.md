# mutos8k -- MUTOS 8000 erforschen, dokumentieren, wieder bauen

MUTOS 8000 ist das UNIX-V7-Derivat für den robotron **A5120.16**: einen A5120 (U880) mit der Erweiterungskarte
EM064/EM256, auf der ein **U8001** (Z8001) den UNIX-Kernel fährt, während der U880 mit `mutos_io` Disketten,
Konsole und Drucker bedient.

Dieses Projekt sammelt alles, um das System zu verstehen und aus Quellen wieder zu bauen:

* **Kernel** `mutos_1216`: vollständig disassembliert, in Module zerlegt und mit den Original-Werkzeugen
  bytegleich neu gebunden; ~75 % der Funktionen bytegleich aus C zurückgewonnen, der Rest funktional gleich.
  **MUTOS baut seinen Kernel selbst** (`make`, `cc`, `as`, `ld` im Gast) und bootet ihn.
* **`mutos_io`** (U880-Seite): rekonstruierte, kommentierte Quelle, die bytegleich zur Originaldatei baut.
* **Werkzeugkette** (`cc`/`as`/`ld`, a.out- und Archivformat, ein eigenes `make`).
* **Disketten**: Originalabzüge und die Werkzeuge, die daraus lauffähige Lade-, Wurzel- und Datendisketten bauen.
* später: **Userspace** und der Vergleich mit den Original-Quellen von UNIX V7 (`original/unix-v7/`).

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
