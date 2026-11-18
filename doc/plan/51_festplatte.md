# Plan 51: Festplatte (GIDE) fuer MUTOS

Stand 2026-11-15, Branch `mutos-plus` (Plan 47).  **Grobplan.**  Hervorgegangen aus Plan 46 Teil B (auf `main` geloescht in `5738a8e`); setzt Plan 48 und Plan 49 voraus.

## 1. Ausgangslage

* **GIDE im CP/A** (`k1520emu: doc/merkposten/gide_cpa.md`): Treiber fest im BIOS, Plattenformat nach Heiko Poppe, **8 Laufwerke zu je 8 MB** (bei der fertigen Emulator-Diskette mit 2 Floppys C: bis J:; bei der **4-Floppy-Variante von Plan 48 E: bis L:**, *gemessen* `doc/plus/cpa/c1_8_vier_floppy.md` §4; 256 MB Abbild,
  500 Spuren x 16 x 63 Sektoren); bootet mit Lade-ROM UL4 auch ohne Diskette von der Platte.  Unvertraeglich mit dem Kingstener-Format (`gidn`).
* **Emulator:** GIDE-Karte, ATA-Platte und RTC umgesetzt (`k1520emu: doc/design/50_gun_gide.md`, G2-G6); fertige formatierte Platte `k1520emu: disks/a5120_cpa_gide/`.
* Der fruehere Ansatz aus Plan 46 (Raw-Modus in `mutos_io` am Controller vorbei, weil UDOS keine Platte kennt) **entfaellt**: ueber das CP/A-BIOS ist jedes
  GIDE-Laufwerk wie eine Diskette ansprechbar (Plan 48 §3.1).
* 8 MB = 16 384 Bloecke zu 512 B: passt in die 16-Bit-Blocknummer von `mutos_io` und in die V7-Grenzen (abgeleitet).
* Kernel und Werkzeuge: Grenzen wie in Plan 49 §1 (Einheiten < 4, feste Groesse, Tabellen von `icheck`/`ncheck`/`dcheck`).

## 2. Ziel

MUTOS-Dateisysteme auf GIDE-Laufwerken: zuerst als zusaetzliche einhaengbare Dateisysteme, danach **Wurzel und Swap auf der Platte**, zuletzt (optional) Start ganz
ohne Diskette (CP/A bootet von der Platte, der Lader aus Plan 48 startet MUTOS von dort).

## 3. Entwurfsfragen (Empfehlung, Entscheidung in P1)

1. **Ein CP/A-Laufwerk = eine MUTOS-Einheit** (8 MB).  Groessere Dateisysteme ueber mehrere CP/A-Laufwerke sind nicht vorgesehen.
2. **Eigener Major** fuer die Platte (Diskettenweg bleibt unberuehrt) oder derselbe `rk` mit mehr Einheiten?  *Empfohlen:* derselbe `rk` mit Einheitentabelle aus
   Plan 49 B3 (Groesse je Einheit), weil der Weg in `mutos_io` gleich ist (BIOS-Laufwerk); Minor-Nummern fuer die Platteneinheiten festlegen.
3. **Belegung:** welche der 8 Laufwerke bekommt MUTOS, welche bleiben CP/A (das erste GIDE-Laufwerk -- **E:** bei der 4-Floppy-Variante, C: bei 2 Floppys -- traegt `@OS.COM` und die Werkzeuge, fuer den Plattenstart unverzichtbar).
   Ein von MUTOS belegtes Laufwerk ist fuer CP/A unbrauchbar (und umgekehrt).
4. **Swap:** eigene Einheit auf der Platte (`swapdev`, `swplo`, `nswap`), entlastet die Wurzel.
5. **Werkzeuge:** `icheck`, `ncheck`, `dcheck` sind fuer 16 384 Bloecke zu klein (gemessen fuer Disketten, Plan 49 §1); `fsck` wird nicht ergaenzt (MUTOS bleibt V7).
6. **Pufferzahl** `NBUF` und Speicher: messen, ob 20 Puffer bei Plattenbetrieb genuegen.

## 4. Arbeitspakete

| AP | Inhalt | Abnahme |
|----|--------|---------|
| P1 | Entscheidungen §3, Minor-Plan, Laufwerksbelegung | Eintrag in diesem Plan |
| P2 | `mutos_io`: Einheiten -> GIDE-Laufwerke ueber das BIOS | Lesen/Schreiben aller Bloecke einer Platteneinheit (Muster) |
| P3 | Kernel: Einheiten und Groessen fuer die Platte, Geraeteknoten | `mkfs` auf der Platte, einhaengen, schreiben, nach Neustart lesen |
| P4 | Werkzeuge fuer 16 384 Bloecke (`icheck`, `ncheck`, `dcheck`, `df`, `mkfs`) | Gast-Tests auf voller Platteneinheit |
| P5 | Wurzel und Swap auf der Platte, Bau einer Plattenwurzel (`tools/disks`) | Boot mit Plattenwurzel, Arbeitstests, Swap unter Last |
| P6 | (optional) Start ohne Diskette: CP/A von der Platte, Lader und Kernel auf C: | Kaltstart nur mit Platte bis `login:` |

Alle Aenderungen in `doc/plus/abweichungen.md`.  Emulatorarbeiten (z. B. DiskTool fuer MUTOS-Dateisysteme in GIDE-Laufwerken) gehoeren nach `a5120emu`.
