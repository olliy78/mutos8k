# Plan 46: Groessere Datentraeger -- zweiseitige Disketten (Teil A) und Festplatte (Teil B)

Stand 2026-11-10.  **Grobplan.**  Die detaillierte Ausplanung der Arbeitspakete (AP) folgt in einer eigenen Sitzung; die Ausplanung von Teil B erst nach Abschluss von Teil A.
Beides sind **Varianten** im Sinn von CLAUDE.md Ziel 3 (dokumentiert, getestet), kein Rueckbau: die betroffenen Kernel-Funktionen sind danach nicht mehr bytegleich zum Original,
das Original bleibt als Referenz erhalten (Ort der Varianten: `kernel/c/varianten`, Vorgehen in der Detailplanung festzulegen).  Aussagen sind *gemessen*, *Angabe des Projektinhabers* oder *Annahme*.

## 1. Ausgangslage (gemessen, Stand `main`)

* Der Kernel hat zwei Blocktreiber: Major 0 `fd` (direkt) und Major 4 `rk` (Mailbox-Ersatztreiber, `kernel/c/rk.c`).  Die Wurzel liegt auf `rk` (`rootdev 0x0402` = Einheit 2).
* **Grenzen im Kernel:** `rkopen` lehnt Einheiten >= 4 ab; `rkstrategy` lehnt Blocknummern >= 0x260 = **608** ab (76 Spuren zu 8 Bloecken zu 512 B = 304 KB); `swplo 250`/`nswap 244` liegen auf dem Wurzellaufwerk; `NBUF 20`.
* **Mailbox** (`mbx.h`, D532): Einheit, Richtung, Segment, Adresse, Anzahl, **32-Bit-Blocknummer**.  Die U880-Seite (`mutos_io`) rechnet nur mit **16 Bit** (abgeleitet, `doc/mutos_io/analyse.md` §12) -- das waeren hoechstens 65 535 Bloecke = 32 MB.
* **U880-Seite:** `SEKTOR_BERECHNEN` rechnet Block -> (Zylinder, Sektor) fest fuer Disketten; es gibt die Variante `K8X512` (8 x 512 B statt 26 x 128 B).  Die Rueckseite einer Diskette ist im bisherigen UDOS ein eigenes Laufwerk n+4; der Nukleus weist die Laufwerke 4-7 ab (`doc/plan/39_mutos8000.md` §11.7), die Laufwerkstabelle kennt nur vier.
* **Dateisystem:** V7-Format, 512-Byte-Bloecke fest im Kernel (`BSIZE`); 24-Bit-Blockadressen (laut V7-Quellen, nicht an MUTOS gemessen).
* **Werkzeuge** (Rueckbau Plan 44) haben feste Tabellen fuer Disketten: `ncheck` BSS 25 770 B, `icheck` 5788 B, `dcheck` 5734 B, `NI` 8, `ncheck` `HSIZE` 1103; `mkfs`, `df` sind nicht auf grosse Datentraeger geprueft.

## 2. Teil A: zweiseitige Disketten mit UDOS 5.0

**Ziel:** MUTOS-Disketten im Format **ds80_9x512** (80 Zylinder, 2 Seiten, 9 Sektoren zu 512 B = 720 KB = 1440 Bloecke), zugehoerige Bootdiskette mit **UDOS 5.0**.
Das Format ds80_5x1024 (800 KB) wird **nicht** weiterverfolgt: es braucht in `mutos_io` eine Sektorentblockung (Lesen-Aendern-Schreiben, weil ein Block ein halber Sektor ist) fuer 11 % mehr Platz (*Entscheidung 2026-11-10 auf Empfehlung*).

**Angaben des Projektinhabers (nicht von mir geprueft):**
* UDOS 5.0 ist dem UDOS 3.0 des P8000 aehnlich; es spricht eine zweiseitige Diskette **als ein Laufwerk** an.
* Das Dateisystem von UDOS 5.0 unterscheidet sich von dem der UDOS 3 und 4 des A5120.
* `mutos_io` muss angepasst werden; moeglicherweise haben sich die Betriebssystem-Schnittstellen (Nukleus) geaendert.

**Betroffene Schichten (Annahme, im AP A1 zu klaeren):** UDOS 5.0 / Nukleus -> `mutos_io` -> Kernel -> Werkzeuge -> Wurzeldiskette/Boot -> Emulator-Format.

| AP | Inhalt (grob) |
|----|----------------|
| A1 | **Analyse UDOS 5.0:** Nukleus-Schnittstelle gegenueber der bisher von `mutos_io` genutzten (`CALL 0BFDH`, Zylinder/Sektor-Auftrag), Adressierung der zweiten Seite als ein Laufwerk, Bootvorgang, UDOS-Dateisystem fuer die Bootdiskette; was aendert sich fuer `BOOT MUTOS`.  Ergebnis: Liste der Aenderungen je Schicht |
| A2 | `mutos_io`: Block -> (Zylinder, Seite, Sektor) fuer 9 x 512 x 2 Seiten, Laufwerkstabelle, Pufferlogik; Variantenschalter nach Vorbild `K8X512`; Bytegleichheitsnachweis der bisherigen Varianten |
| A3 | Kernel `rk`: Groessengrenze je Einheit statt fester 608 (Tabelle), `swplo`/`nswap`, ggf. `NBUF`; als Variante mit Test (Boot, Arbeit, Dateisystem auf 1440 Bloecken) |
| A4 | Werkzeuge: `mkfs`, `icheck`, `ncheck`, `dcheck`, `df` auf 1440 Bloecke pruefen und anpassen (Tabellen), Gast-Tests |
| A5 | Datentraegerbau: Wurzel-/Cmd-/Usr-Disketten im neuen Format (`tools/disks`), Boot mit UDOS 5.0 |
| A6 | Emulator: Format ds80_9x512 und UDOS 5.0 im Projekt `a5120emu` (**nicht hier**; Abstimmung) |

**Offene Fragen:** Liegt UDOS 5.0 (Abbild, Dokumentation) vor, und wo?  Bleibt die alte Auslieferung (einseitig, 26 x 128 bzw. 8 x 512) lauffaehig (Varianten nebeneinander)?  Wie wird bei 80 statt 77 Spuren und 2 Seiten die Blockanzahl je Einheit bestimmt (feste Tabelle oder aus der Diskette gelesen)?

## 3. Teil B: Festplatte (GIDE am K1520)

**Stand (Angabe des Projektinhabers):** Die Festplattenkarte **GIDE** fuer den K1520 ist im Emulatorprojekt in Entwicklung, nicht abgeschlossen.  UDOS 5.0 hat **keine** Festplattenunterstuetzung und diese soll nicht nachentwickelt werden.

**Ansatz (Vorschlag des Projektinhabers, zu klaeren):** `mutos_io` bekommt einen **Raw-Modus**, der die Platte direkt ueber Koepfe und Sektoren (bzw. den Controller) anspricht, ohne UDOS.  An MUTOS werden dann entweder **Koepfe/Sektoren (CHS)** oder ein **linearer Sektorbereich (LBA)** weitergereicht.

**Groessen:** z. B. 8 MB oder 40 MB.  Bei 512-Byte-Bloecken sind 40 MB = 81 920 Bloecke; die bisherige 16-Bit-Blocknummer der U880-Seite reicht dafuer nicht (Grenze 32 MB, abgeleitet) -> die Blocknummer muss auf der U880-Seite mindestens 17 Bit tragen, die Mailbox hat bereits 32 Bit.

**Entwurfsfragen (offen, fuer die spaetere Detailplanung):**
1. CHS oder LBA an der Mailbox-Schnittstelle.  Vorschlag der Analyse: LBA (die 32-Bit-Blocknummer der Mailbox ist schon vorhanden; die Geometrie bleibt in `mutos_io`).
2. **Eigene Mailbox-Klasse und eigener Major** (Platte unabhaengig vom Diskettenpfad; `rkstrategy` und der Diskettenpfad bleiben bytegleich zum Original) oder derselbe Pfad mit groesseren Einheitsnummern.  Empfehlung der Analyse: eigener Major/eigene Klasse -- Entscheidung steht aus.
3. Partitionen/Mehrfachdateisysteme (Einheitsnummer = Minor): Zahl und Groessentabelle.
4. Swap und Wurzel auf der Platte; Boot von der Platte hat UDOS 5.0 nicht (Boot bleibt Diskette).
5. Dateisystemgrenzen bei 40 MB (V7: 24-Bit-Blockadresse, 16-Bit-I-Node-Nummer), Pufferzahl `NBUF`, Werkzeuge mit festen Tabellen (`icheck`, `ncheck`, `dcheck` zu klein, gemessen siehe oben), `fsck` gibt es in V7 nicht und wird nicht ergaenzt (Grundsatz Plan 45).
6. Test: Platte im Emulator (GIDE) ist Voraussetzung; Gast-Tests (Dateisystem anlegen, pruefen, neu starten).

**Abhaengigkeit:** Teil B beginnt nach Abschluss von Teil A und nach dem Stand der GIDE-Emulation.  Teil A liefert die Grundlagen (Kernel-Groessentabelle je Einheit, Werkzeuge ohne feste Diskettengroessen, Block -> Position in `mutos_io`).

## 4. Nicht-Ziele

* Kein Nachbau von UDOS 5.0 oder eines UDOS-Plattentreibers.
* Keine Programme aus System III (Grundsatz Plan 45).
* Keine Aenderung am Emulator in diesem Repository (gehoert zu `a5120emu`).

## 5. Naechster Schritt

Eigene Sitzung: Detailplanung der APs von Teil A (A1 Analyse UDOS 5.0 zuerst), Klaerung der offenen Fragen aus Abschnitt 2.
