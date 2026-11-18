# C3.3 `mutoscpa`: Plattenweg ueber das BIOS (Plan 48)

**Stand: erledigt** (Abnahme erreicht), 2026-11-18.  Arbeitsordner `/tmp/mplus/c3_3/`.  Kennzeichnung: *gemessen* (Lauf genannt), *abgeleitet*, *Annahme*.
Quelle `mutos_io/cpa/src/mutoscpa.mac` (`PLATTE` ... `V_K`), Bauergebnis `mutos_io/cpa/mutoscpa.bin` (4608 B, Abbild 14 696 B unveraendert),
Waechter `tests/test_plus_cpa_io.py` (schnell: kein UDOS-Plattenweg; `gast`: Boot bis `login:` mit beiden Wurzeln), Debuggerskripte
`versuche/dbg/cpa_c3_3_boot.dbg` (CP/A-Fassung) und `cpa_c3_3_udos.dbg` (Vergleichslauf UDOS).

## 1. Erste Sonde: voller ISR neben `READ` (gemessen)

Nur der Lesezweig eingebaut, Schreiben meldete Fehler (`PL_FEHLER`); Boot mit `root_mfm` in C: (A = leere `/tmp`-Diskette, B = `/usr`, D = leere `/mnt`, wie `gast_as.PLATTEN`;
Diskettenwechsel in der Bedienmaske per `eject`/`mount`).  Logpunkte: BIOS-`READ` (Eintritt, Sprungleiste), Zeile nach `CALL B_READ`, `ISR_TAKT`, `ISR_ANFRAGE`, `PL_FEHLER`
(Lauf `/tmp/mplus/c3_3/p1`, 1,5 Mrd. Takte Frist, weil `login:` wegen des Schreibfehlers nie kam).
* **Daten richtig, Boot kommt weiter als in C3.2:** 428 `READ`-Saetze ohne Fehler; die Anzeige erreicht `mem = 196608` und `single user`; der Kernel liest Superblock und Inodes
  (`iinit` kein `panic` mehr).  Erst der erste **Schreib**auftrag (`bn=12`, dann `bn=250`) lief in den Fehlerzweig (8 Treffer = 2 Bloecke x 4 Wiederholungen des Kernels): erwartet, der Schreibzweig fehlte.
* **Ticks:** `ISR_TAKT` 30 407 Eintraege, mittlerer Abstand 49 248 Takte (wie `c1_7` §2: 49 249); kein Tick ausgefallen (groesster Abstand 60 911 = 1,24 Perioden, kleinster 37 604).
  519 Ticks fielen in `READ`-Fenster; ihre Verspaetung gegen das mittlere Raster war dort hoechstens 8 900 Takte (0,18 Perioden), ausserhalb bis 18 400.
* **`ISR_ANFRAGE`:** 381 Eintraege, **keiner innerhalb eines `READ`-Fensters** -- der Kernel stellt waehrend des Bootvorgangs genau einen Auftrag nach dem anderen.
  Die Erwartung "jede Anforderung waehrend `READ` wird nach dem Block bedient" ist damit **nicht ausgeloest, also weder bestaetigt noch widerlegt** (im Boot kommt sie nicht vor; Stoerfall
  erst mit Tastatur/Konsolzeichen waehrend Plattenzugriff, C3.4/C4.2).  Mit `READ` laufen aber `ISR_TAKT` (519 Mal im Fenster) und die BIOS-Interrupts ohne Stoerung.
* Folge: **nichts blockiert**, Einbau des Schreibzweigs.

## 2. Aenderungen an `mutoscpa.mac`

| Nr. | vorher (UDOS-Weg) | nachher |
|-----|-------------------|---------|
| 1 | `PLATTE` (Auftragsblock `AUF0`, `V_BUSY`, `BLOCK_START`, Rueckruf `PLATTE_FERTIG`, `CALL 0BFDH`), asynchron | `PLATTE` **synchron**: Meldung nach `V_*` kopieren, Einheit -> CP/A-Laufwerk, anmelden, Blockrechnung, je Satz `SETTRK/SETSEC/SETDMA/READ|WRITE`, Ergebnis in `IX+9`/`IX+14/15`, `JP ENDE_WIEDER` (kein Rueckruf, nichts mehr im Interruptkontext) |
| 2 | `TAB_RK_LAUFWERK` -> Nukleus-Laufwerk | `TAB_RK_LAUFWERK` (Maske: Einheit -> Floppy 0..3) -> neue Tabelle `TAB_RK_CPA` (8 Eintraege `00 01 02 03 FF FF FF FF`, Einheit 4..7 indizieren sie direkt; FFH = Fehlerstatus; Plan 49/51 tragen GIDE ein) |
| 3 | `TAB_KL0` Einheit 4..7 -> `IGNORIEREN` | -> `PLATTE` (eine Anforderung an rk4..7 bekommt Fehlerstatus statt Stille; sonst waeren die 8 Eintraege von `TAB_RK_CPA` tot) |
| 4 | Anmeldung: Nukleus | `V_ANGEM[8]` je Einheit; erster Zugriff nach der Maske `SELDSK` mit E Bit 0 = 0 (Formaterkennung), danach E = 1; `M_FERTIG` loescht die Merker; nach **jedem** `SELDSK`: DPH+10 -> DPB, `SPT` (+0) und `OFF` (+13) neu gelesen; HL = 0 -> Fehler |
| 5 | Blockrechnung `BLOCK_START`/`SEKTOR_BERECHNEN`/`SEKTOR_WEITER` (Zeiger auf Nukleus-ID, `K8X512`-Zweige) | `l = 4*bn`, `q = l div PERTRK`, `pos = l mod PERTRK`, `skew = 6*q mod 26` (Zaehlschleife); 26 x 128 (`SPT` 26): `ID` wie bisher, `SETSEC = ID` unter `OFF`, sonst `INV[ID]` (`INVT`, `cpa_analyse` §4); 8 x 512 (`SPT` 32 oder 36): `SETTRK = l div 32 + 1`, `SETSEC = l mod 32 + 1`; sonst Fehler |
| 6 | Schreiben: Nukleus | `WRITE` mit `C = 0,0,0,1` je Block (letzter Satz eines Blocks und letzter der Anforderung = 1) |
| 7 | `0BFDH`, `BLOCK_*`, `BR_*`, `SEKTOR_WEITER`, `V_RUECKRUF_*`, `NUK_AUFTRAG`, `PLATTE_FERTIG`, `NUKLEUS_INIT`, `V_BUSY`, `K8X512`/`SEKLEN`/`SPT` | entfernt (ASCII-Waechter `test_keine_udos_platte_c3_3`).  Das Byte hinter `V_TAKT` (frueher `V_BUSY`) bleibt als Fuellbyte, damit Segment 4 und das Abbild (14 696 B) gleich lang bleiben |
| 8 | `ENDE_LOESCHEN` nach dem Auftrag (Nukleus laeuft weiter) | `ENDE_WIEDER` (Anforderungsbit loeschen, Fertigbit setzen) -- `MELDEN` kopiert danach beim Lesen den Z80-Puffer ins EM wie bisher |

Das BIOS darf `IX` zerstoeren: `PLATTE` kopiert alle Felder der Nachricht (Satzzahl `2*IX+14 + Bit 7 von IX+15`, Befehl, `bn` = `IX+18` hoch / `IX+19` tief, Puffer `IX+2/3`, Einheit) vor dem
ersten BIOS-Aufruf in `V_NREC`, `V_CMD`, `V_BN`, `V_DMA`, `V_UNIT` und setzt `IX := DCB0` am Ende.  Die Pruefung "Anforderung laenger als 1000H" (Fatal `'L'`) bleibt wie im UDOS-Weg.
Fehlerstatus `C0H` (Bit 6 gesetzt, wie ein Nukleusfehler ueber `BR_ABBRUCH`), Zaehlung 0.  Grenzen der Rechnung: `bn >= 4000H` und Zylinder > 255 -> Fehler (der UDOS-Weg hatte 1664).

## 3. Abnahme (alle *gemessen*)

Aufruf: `MPLUS_ARBEIT=/tmp/mplus/c3_3/t1 python3 -m pytest -q tests/test_plus_cpa_io.py` (Boot ueber `cpa_disk.bootdiskette`, Original-Kernel, vier Floppys, `--em em256`);
die Zahlen unten stammen aus den Laeufen `p7` (`root_mfm`) und `p8` (`root_8x512`) mit zusaetzlichen Logpunkten (`SETTRK`/`SETSEC`/`WRITE` mit Dump).
* **Boot bis `login:`:** mit `root_mfm` in C: **0 Plattenfehler** (`PL_FEHLER` nie getroffen), Bildschirm `mem = 196608`, `single user login:`; ebenso mit `root_8x512` in C:.
* **Zeit bis `login:`** (Takte von `keys r` in der Maske bis `login:`, Debugger `+-cyc`): CP/A-Weg `root_mfm` **23 779 494** (9,7 s Emulatorzeit), `root_8x512` **20 660 601**;
  **UDOS-Weg** (`cpa_c3_3_udos.dbg`, Originalladediskette, gleiche `root_mfm`) **23 856 792**.  Der CP/A-Weg ist **gleich schnell** (-0,3 %).  UDOS mit `root_8x512` nicht gemessen
  (das serienmaessige `mutos_io` rechnet nur 26 x 128).
* **Takte je Block** (ueber den ganzen Boot, Mittel aus den Logpunkten `READ` Eintritt -> Zeile nach dem Aufruf; je Satz, Block = 4 Saetze): `root_mfm` `READ` Mittel 76 423 / Median 47 824 je Satz
  (188 Saetze) = **305 693 Takte je Block** (Spursuchen und Drehwartezeit eingerechnet; fortlaufend gemessen sind es 198 602, `c1_6` §5); `WRITE` Mittel 124 072 je Satz (8 Saetze).
  `root_8x512`: `READ` Mittel 61 635 / Median 4 056 je Satz (180 Saetze, der erste Satz eines Sektors holt die 512 B, die drei folgenden kommen aus dem BIOS-Puffer) = 246 542 je Block; `WRITE` Mittel 197 882 (8 Saetze).
  UDOS je Block: erster Sektor ~1,19 Mio. Takte, danach 30 000-45 000 je 128 B (`c1_4` §6, andere Messart).
* **Ticks (`root_mfm`):** 480 `ISR_TAKT`, mittlerer Abstand 49 253, kleinster 37 764, groesster 60 760 (1,23 Perioden), **kein Tick verloren**.  Innerhalb der BIOS-`READ`/`WRITE`-Fenster (310 Ticks)
  hoechstens **187 Takte** Verspaetung, ausserhalb bis 11 600 (Meldungs-`LDIR` bei `DI` in `MELDEN`, Konsolausgabe; nicht `READ`).  `root_8x512`: 417 Ticks, 1,24 Perioden, im Fenster hoechstens 275 Takte.
  `ISR_ANFRAGE`: 77 bzw. 74 Eintraege, **keiner im BIOS-Fenster** (wie in §1).
* **Stapeltiefe (Stapelbereich B936H..C8B5H mit E5H gefuellt, nach dem Lauf bis `login:` gelesen):** tiefste benutzte Adresse **C888H = 46 Byte** unter `SP` = C8B6H, in beiden Laeufen (also nicht tiefer als in C3.2).
  *Abgeleitet:* die BIOS-Interrupts (5 ms, 1 s, Floppy) wechseln auf einen eigenen Stapel `intstk` (`biostim.mac:102/147`, `biosdskt.mac:663`); der Hauptpfad `READ` nutzt den Stapel von `mutoscpa`.
  *Nicht gemessen:* `ISR_ANFRAGE` genau waehrend `READ` (kam nicht vor), Langlast (C4.2).  Rest 3 922 Byte.
* **Schreibzweig (gemessen mit `--rw` auf Kopien, `p7`/`p8`):** der Boot schreibt 2 Bloecke (`root_mfm`: `bn=12` und `bn=250`; 8 Saetze mit `C = 0,0,0,1`).  Vergleich der Abbilder vor/nach (`k1520disktool save-as`, IMD):
  jeder geschriebene Satz steht **byteweise gleich dem Z80-Puffer** am physischen Sektor, der sich aus der CP/A-Skew-Tabelle der gewaehlten Satznummer ergibt (`root_mfm`: Zylinder 2 und 39), und es hat sich
  **sonst kein Sektor geaendert**; `root_8x512` je ein 512-B-Sektor an Zylinder 2 und 32 (`bn=10` und `bn=250`) komplett gleich (4 Saetze `C = 0,0,0,1`).
* **Anmeldung/OFF:** Der DPB der leeren `/tmp`-Diskette (`create --fs mutos8k_26x128_mfm`), der Wurzel und der leeren `/mnt`-Diskette ist im Gast identisch (SPT 26, OFF 2; `RDTEST B 1 2`, `/tmp/mplus/c3_3/dpb/`):
  die Formaterkennung raet auch fuer die leere Diskette richtig (*gemessen*).  rk0/rk1/rk3 wurden in diesem Schritt noch nicht gemountet (Tastatur kommt erst in C3.4).
* `python3 -I mutos_io/cpa/build.py --check` -> 0; Schnelltests gruen (`K1520EMU=/nonexistent python3 -m pytest -q tests`, bekannt rot und unabhaengig: `test_bau_alle_kennt_genau_die_fertigen_disketten`).

## 4. Auffaelligkeiten und Grenzen

* Waehrend `READ`/`WRITE` steht die Hauptschleife (synchron); der Kernel wartet ohnehin auf die Platte.  Konsolausgaben anderer Klassen, die in dieser Zeit eintreffen, bleiben bis zum Blockende in der Warteschlange
  (nicht ausgeloest, §1); in C3.4/C4.2 mit Tastatur und Last pruefen.
* Die Verspaetung einzelner Ticks ausserhalb der BIOS-Fenster (bis 0,24 Perioden) stammt aus den `DI`-Abschnitten von `MELDEN` (512-B-`LDIR` = ~10 800 Takte) und der Konsolausgabe, nicht aus dem Plattenweg;
  sie bestand schon in C3.2 (+-3 %, dort ohne Plattenverkehr) und ist beim UDOS-Weg dieselbe Schleife (*abgeleitet*).
* `K8X512`-Fassung entfaellt endgueltig in `mutoscpa.mac` (kein `IF`-Zweig mehr; 8 x 512 wird zur Laufzeit am DPB erkannt).
* Mehrfachanfragen (`> 1000H`) und Anforderungen ueber mehrere Bloecke laufen als fortlaufende Satzfolge (`l = 4*bn + j`) mit Spur- und Skewfortschritt, wie die alte Schleife (`SEKTOR_WEITER`); nur im Swap-Betrieb zu erwarten,
  im Boot nicht beobachtet (*abgeleitet*).
* Merkposten fuer den Emulator (O5): keine neuen noetig.
* Der Waechter `test_start_maske_kernel` (C3.2) wurde angepasst: der erwartete Plattenfehler des Stummels entfaellt (nur noch `mem = 196608`), und die Tickgrenze ist von 1,05 auf **1,5 Perioden**
  gestiegen -- im Lauf nach dem Umbau war der groesste Abstand 51 653 Takte (1,051), weil der Kernel jetzt wirklich von der Platte liest und `MELDEN` mit `DI` arbeitet.
  Ein ausgefallener Tick waere ein Abstand von ~2 Perioden; in C3.3 sind es hoechstens 1,24 (§3).
