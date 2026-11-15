# Plan 49: Groessere Disketten -- zweiseitig, im neuen `mutos_io` und im Kernel

Stand 2026-11-15, Branch `mutos-plus` (Plan 47).  **Grobplan.**  Hervorgegangen aus Plan 46 Teil A (bis `5738a8e` auf `main`); setzt Plan 48 voraus.
Der dortige Weg ueber UDOS 5.0 entfaellt: das CP/A-BIOS kann zweiseitige Disketten bereits (*Angabe des Projektinhabers*; `biosdpb.mac` der GIDE-CP/A
kennt 624- und 780-KB-Formate, abgeleitet).

## 1. Ausgangslage (gemessen, Stand `main`)

* Kernel: Blocktreiber Major 4 `rk` (Postfach), Wurzel `rootdev 0x0402`.  `rkopen` lehnt Einheiten >= 4 ab; `rkstrategy` lehnt Blocknummern >= 0x260 = **608** ab
  (`kernel/c/rk.c`); `swplo 250`/`nswap 244` auf dem Wurzellaufwerk; `NBUF 20` (`kernel/conf/conf.c`).
* Postfach: 32-Bit-Blocknummer; `mutos_io` (UDOS) rechnet nur mit 16 Bit (abgeleitet, `doc/mutos_io/analyse.md` §12) -- fuer Disketten ausreichend.
* Dateisystem: V7-Format, 512-B-Bloecke.  Werkzeuge mit festen Tabellen (Rueckbau Plan 44): `ncheck` BSS 25 770 B, `icheck` 5788 B, `dcheck` 5734 B, `NI` 8,
  `ncheck` `HSIZE` 1103; `mkfs`, `df` sind nicht auf grosse Datentraeger geprueft.

## 2. Ziel und Formatwahl

MUTOS-Disketten in einem **zweiseitigen CP/A-Format**; alte einseitige Disketten bleiben lesbar (soweit Plan 48 C1 sie ueber das BIOS erreicht).
Weil das BIOS entblockt (Plan 48 §3.1), faellt der Grund weg, aus dem Plan 46 das 5 x 1024-Format verworfen hatte.  *Empfehlung:* das CP/A-Standardformat
**780 KB** (80 Zylinder, 2 Seiten, 5 x 1024 B) bzw. dessen Rohgroesse -- ob MUTOS die CP/A-Systemspuren mitbenutzt (1600 statt 1560 Bloecke), entscheidet B1.
Alternative 624 KB (16 x 256).  Die Entscheidung faellt in B1 mit Messung der Geschwindigkeit.

## 3. Arbeitspakete

| AP | Inhalt | Abnahme |
|----|--------|---------|
| B1 | Formatwahl, Blockanzahl je Einheit, Laufwerk -> Format in `mutos_io` (fest, Tabelle oder vom BIOS erfragt) | Entscheidung in diesem Plan |
| B2 | `mutos_io` (CP/A): Block -> (Spur, Satz) fuer das neue Format, Einheit -> CP/A-Laufwerk | Lesen/Schreiben jedes Blocks einer Testdiskette (Muster) |
| B3 | Kernel `rk`: Groessengrenze je Einheit aus einer Tabelle statt fest 608; `swplo`/`nswap` fuer die groessere Wurzel; `NBUF` pruefen | Boot, Arbeitstests, Dateisystem ueber die ganze Diskette gefuellt |
| B4 | Werkzeuge `mkfs`, `icheck`, `ncheck`, `dcheck`, `df` auf 1600 Bloecke pruefen, Tabellen vergroessern (Aenderungen gegen V7-Text kommentiert) | Gast-Tests auf voller Diskette |
| B5 | Datentraegerbau: Wurzel-, cmd-, usr-Disketten im neuen Format (`tools/disks`), Bootdiskette aus Plan 48 | Boot von CP/A mit zweiseitiger Wurzel |
| B6 | Emulator/DiskTool: MUTOS-Dateisystem auf dem neuen Format (Projekt `a5120emu`, **nicht hier**; Abstimmung) | DiskTool liest/schreibt die neue Wurzel |

Alle Aenderungen in `doc/plus/abweichungen.md`.

## 4. Offene Fragen

1. Systemspuren: nutzt MUTOS die ganze Diskette (CP/A kann sie dann nicht mehr lesen, wie heute) oder bleiben die CP/A-Systemspuren frei (bootfaehige Datendiskette)?
2. Feste Blockanzahl je Einheit im Kernel oder Groesse aus dem Superblock bzw. von `mutos_io` erfragt?
3. Mischbetrieb einseitig/zweiseitig in verschiedenen Laufwerken: Format je Laufwerk fest konfiguriert oder je Diskette erkannt?
