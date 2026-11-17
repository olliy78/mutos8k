# C1.6 MUTOS-Formate ueber das CP/A-BIOS lesen und schreiben (Plan 48)

Stand 2026-11-17, Plan 48 C1.6.  Alle Aussagen *gemessen* (Gastlauf im Emulator, GIDE-CP/A mit 2 Floppy, EM256; Arbeitsordner `/tmp/mplus/c1_6/`), soweit nicht als
*abgeleitet* oder *Annahme* gekennzeichnet.  Plattenabbilder und Disketten nur als Kopien, `--rw` nur auf den Kopien.

## 1. Ergebnis in Kuerze

**Abnahme erreicht:** die Wurzeldisketten `root_fm`, `root_mfm`, `root_8x512` und ein GIDE-Laufwerk lassen sich ueber die BIOS-Sprungleiste (nicht BDOS) satzweise lesen
und schreiben, **alle gemessenen Saetze gleich dem Abbild** -- aber nur mit einer **Satznummernregel**, die `mutos_io` kennen muss (§4): das BIOS uebersetzt die Satznummer
von `SETSEC` in READ/WRITE selbst (CP/A-Tabelle mit Versatz 6) und **nur auf Datenspuren** (ab `OFF` aus dem DPB).  Mit der naiven Regel `SETSEC = Sektor-ID` stimmen
824 von 2002 Saetzen nicht.

| Format (Abbild) | erkannt als (DPB, gemessen) | gelesen gleich | Bloecke nach Formel gleich | Takte je 512 B | geschrieben gleich |
|---|---|---|---|---|---|
| 26 x 128 MFM (`root_mfm`) | SPT 26, BSH 4, DSM 7DH, OFF 2 | 2002/2002 (Zyl. 0..76) | 494/494 | 198 602 | C=1 ja; C=0 ja (128-B-Sektor = Satz) |
| 26 x 128 FM (`root_fm`) | wie `root_mfm` | 2002/2002 | 494/494 | 198 602 | wie `root_mfm` |
| 8 x 512 (`root_8x512`) | **SPT 36 (= 9 x 512)**, Zyl. 0 als 26 x 128 | 2528/2528 (Zyl. 1..79) + Zyl. 0 26/26 | 632/632 | 147 561 | C=1 ja; C=0: **letzter Satz bleibt offen** (§6) |
| GIDE `D:` (Kopf 1) | SPT 128, OFF 2 (C:) | 1280/1280 (Datei `KNOWN.BIN`, 200 KB) | -- | 28 190 | C=1 ja; C=0: letzter Satz bleibt offen |

Takte: Maschinentakte (Debugger `c`-Zaehler, 2,4576 MHz), Mittelwert je Block ueber Laeufe von 64 aufeinanderfolgenden Bloecken (Spurwechsel eingeschlossen), BIOS-Interrupts laufen.
Floppy: 198 602 Takte = 0,081 s je 512 B.  FM und MFM sind im Emulator **taktgleich** (zeitlich wie inhaltlich nur die Rotation).  GIDE: 16-KB-Spuren in Folge, ohne Fremdzugriffe.

## 2. Programme und Aufruf

Alle Quellen M80-Syntax (`.Z80`), gebaut je Lauf (`cpa.com`), die `.COM` wird nicht eingecheckt.  Gemeinsam: BIOS-Einspruenge werden aus dem Warmstartvektor `0001H` gebildet
(`WBOOT + 18H` SELDSK, `+1BH` SETTRK, `+1EH` SETSEC, `+21H` SETDMA, `+24H` READ, `+27H` WRITE, `+15H` HOME), nie `SECTRAN`, nie BDOS fuer die Platte der Pruefung.
Debuggermarken: `MKA` (`0103H`) und `MKB` (`0104H`) sind `RET`; `logpoint 0x103`/`0x104` liefert den Takt.

* `versuche/plus_cpa/rdtest.mac`: `RDTEST d first last [base [o]]` -- Spuren `first..last` Satz fuer Satz `SETSEC = base..base+SPT-1` (SPT aus dem DPB), Ausgabe als `RAW.BIN`
  auf Laufwerk `o` (BDOS-Dateifunktionen), 24 DPB-Byte auf den Schirm.  Ein fehlerhafter Satz wird `EEH`-gefuellt gespeichert.
* `versuche/plus_cpa/blktest.mac`: `BLKTEST d first last f [o]` -- **Kernelbloecke** nach der Formel von `mutos_io` (C1.4 §7, Z80-Fassung der Schiebe-Subtraktion), `f` = `2` (26 x 128) oder `5` (8 x 512),
  `OFF` zur Laufzeit aus dem DPB (Wort bei +13).  Das ist die Vorlage fuer C3.3.
* `versuche/plus_cpa/wrtest.mac`: `WRTEST d skript` -- schreibt Muster `byte i = (i + t + 3r + 5AH) mod 256` in 8 verstreute Saetze `(t, r)`, Befehle `0 1 2` (WRITE C=0/1/2),
  `R` (zurueckLesen), `X` (fremde Spur lesen), `H` HOME, `S` SELDSK, `P` 2 s warten, `B`/`b` (vier Saetze eines 512-B-Sektors mit C=0,0,0,1 / 0,0,0,0).  Danach laeuft der Rechner **ohne
  Warmstart** weiter (`JR $`), der Debugger laesst ihn `leer` Takte leerlaufen und beendet sich; beurteilt wird die vom Emulator hinterlassene Abbilddatei.
* Host: `versuche/plus_cpa/c1_6_lauf.py` (IMD-Abzug des Sollinhalts durch `k1520disktool save-as`, Vergleich, Takte).  **Gesamtlauf** (3 Min.):
  `python3 -I versuche/plus_cpa/c1_6_lauf.py alles --arbeit /tmp/mplus/c1_6/alles` (Exit 0 = alles wie erwartet, 77 ohne Emulator).
* `tools/plus/cpa.py`: nur ergaenzt um `lauf_dbg()` (rohe Debuggerzeilen, `--rw` wahlweise).

Sollinhalt: `k1520disktool save-as <hfe> <imd>` liefert je Spur die Sektoren **mit ihrer ID** (`m8k.imd_laden`); verglichen wird je (Zylinder, ID) gegen den 128-B-Satz, den die BIOS-Regel liefert.
Das GIDE-Abbild wird als `.img.gz` direkt gelesen (CHS: `LBA = (Zyl*16 + Kopf)*63 + Sektor - 1`, gemessen: `KNOWN.BIN` liegt bei C: Spur 11 = LBA 11088).

## 3. Befunde

1. **Erkennung (gemessen, DPB-Auszug `RDTEST`):** beide 26 x 128-Wurzeldisketten (FM **und** MFM, 77 Spuren) werden erkannt und fehlerfrei gelesen: SPT 26, BSH 4, EXM 1, DSM 7DH, DRM 7FH,
   **OFF 2**.  Das widerlegt die Befuerchtung aus C1.5 (kein 77-Spur-Eintrag): das Format wird richtig behandelt, auch der FM-Zweig.
2. **`root_8x512`:** Erkennung als **9 x 512** (SPT 36 Saetze).  Sektor 9 gibt es nicht: Saetze 33..36 melden Fehler (`R/W`-Meldung `RS;T,Si,Se=<spur><seite><sektor>` auf dem Schirm, mit Wiederholungen
   rund 8,4 Mio. Takte je Spur) -- die Blockformel greift auf Sektor 9 nie zu.  Zylinder 0 (26 x 128, Ladespur) wird mit `SETSEC = ID` richtig gelesen (26/26).
3. **Die Regel fuer die Satznummer (Hauptbefund):** `READ`/`WRITE` uebersetzen den 128-B-Satz `SETSEC = r` selbst in die physische Sektor-ID, und zwar ueber die CP/A-Tabelle
   `1,7,13,19,25,5,11,17,23,3,9,15,21,2,8,14,20,26,6,12,18,24,4,10,16,22` (`biosdpb.mac:374`, Versatz 6) **ab Spur `OFF`**; auf Spuren darunter (Systemspuren) ist `ID = r`.
   Gemessen an `root_mfm`: Spuren 0 und 1 identisch, Spuren 2..39 Tabelle (Spuren 40..76 sind leer, nicht unterscheidbar).  `SECTRAN` (Floppy: `BC+1`) spielt dafuer keine Rolle.
   Die Tabelle gehoert zur CP/M-Verschraenkung (`SECTRAN` fuer das BDOS) und hat **nichts** mit der MUTOS-Verschraenkung zu tun; `mutos_io` muss die Tabelle also **umkehren** (`INV`), damit die MUTOS-ID
   herauskommt.
4. **`OFF` haengt vom Medium ab** (Formaterkennung raet es aus Spur 0, C1.5 §2.2): gemessen an den 12 weiteren 26 x 128-Disketten (6 Namen, je FM und MFM; Spuren 0..5, `cmd_8x512` nicht): `root_*`, `usr_*`, `cmd_*`, `cc1_*`, `cc2_*`
   **OFF 2** (Spuren 0/1 identisch, ab 2 Tabelle), `bin_*` und `nroff_*` **OFF 0, DSM 81H** (Tabelle schon ab Spur 0).  `mutos_io` darf `OFF` daher nicht festschreiben, sondern muss es nach jedem
   `SELDSK` mit Bit 0 = 0 aus dem DPB lesen (Wort bei +13).
5. **Eigenes Format je Spur?** Nein fuer die 26 x 128-Disketten: eine DPB-Beschreibung fuer die ganze Diskette.  Bei `root_8x512` liest das BIOS Zylinder 0 aber trotzdem als 26 x 128
   (Spurkennungen), den Rest als 512-B-Sektoren.

## 4. Regel Block -> (Spur, Satz), gemessen

`bn` = Kernelblock (16 Bit), `k = 0..3` = Viertel (je 128 B), `d` = CP/A-Laufwerk (`SELDSK C=d`), `OFF` = DPB+13 nach `SELDSK` (E Bit 0 = 0).  Je Viertel `SETTRK`, `SETSEC`, `SETDMA`, `READ`/`WRITE`.

**26 x 128 (FM wie MFM)** -- 494 Bloecke (Zylinder 1..76) gegen das Abbild geprueft, 0 Abweichungen:
```
l   = 4*bn + k;  q = l div 26;  pos = l mod 26;  v = (6*q) mod 26
x   = 2*pos;  wenn x >= 26 dann x = x + 1
ID  = ((x + v) mod 26) + 1                       ; MUTOS-Sektor-ID, unveraendert gegen C1.4 §7
SETTRK = q + 1                                   ; Zylinder = BIOS-Spur (Zylinder 0 gehoert nicht zum Blockraum)
SETSEC = ID            wenn q+1 < OFF
SETSEC = INV[ID]       sonst        INV[1..26] = 1,14,10,23,6,19,2,15,11,24,7,20,3,16,12,25,8,21,4,17,13,26,9,22,5,18
```
(`INV` = Umkehrung der CP/A-Tabelle: `SETSEC = INV[ID]` liefert die physische ID.)  Zylinder 1..76; Block 494 und hoeher liegt hinter der Diskette (gemessen: kommt als Fehler, Satz `EEH`-gefuellt).

**8 x 512** -- 632 Bloecke (Zylinder 1..79) gleich:
```
SETTRK = bn div 8 + 1;   ID = bn mod 8 + 1;   SETSEC = (ID-1)*4 + k + 1      ; vier aufeinanderfolgende Saetze = ein Sektor
```
Keine Verschraenkung, kein Versatz; ein Sektor = vier Saetze; Sektorlaenge 512 muss `mutos_io` dem BIOS nicht mitteilen (das erkennt es).

**GIDE** (*SETSEC 0-basig*, gemessen `KNOWN.BIN` Satz 0..1279 = BIOS-Saetze ab Spur 11 Satz 0, fortlaufend): `L = 4*bn + k` im Laufwerk, `SETTRK = L div 128 + Anfangsspur`, `SETSEC = L mod 128`
(128 Saetze je Spur, Spur = Zylinder, ein Laufwerk = ein Kopf).  Spur-Anfang je Laufwerk (Systemspuren `OFF`) entscheidet der Partitionsentwurf (Plan 51).

## 5. Takte

* 26 x 128: 198 602 Takte je 512 B im Mittel (Minimum 196 480, Maximum 199 211 je 64-Block-Lauf), also etwa 0,4 Umdrehungen (200 ms = 491 520 Takte je Umdrehung); der Spurwechsel ist darin.
* 8 x 512: 147 561 (145 369..147 597).  GIDE: 28 190 (16-KB-Spuren).
* Vergleich mit dem UDOS-Nukleus (C1.4 §6): dort ~1,19 Mio. Takte bis zum **ersten** Sektor eines Auftrags, danach 30 000..45 000 Takte je 128 B.  **Nicht gleichartig gemessen**: die Floppyzahlen hier
  gelten fuer fortlaufende Blockfolgen; der Zugriff auf einen einzelnen weit entfernten Block (Spursuche, Drehwartezeit) ist **nicht gemessen**.
* Durchsatz-Folge fuer `mutos_io`: das BIOS-`READ` blockiert (synchron); die Hauptschleife steht je 128-B-Satz im Mittel ~50 000 Takte (1 Interrupt-Tick = 49 152 Takte, C1.7 misst die Tickverluste).

## 6. Schreiben: wann ist ein Satz auf der Diskette (gemessen)

Beurteilt an der Abbilddatei nach Ende der Programmlaeufe (8 Saetze je Szenario, ausserdem Fremdaenderungen: **keine**).

| Szenario | 26 x 128 (MFM) | 8 x 512 | GIDE |
|---|---|---|---|
| alle 8 mit WRITE C=1 | 8/8 sofort | 8/8 | 8/8 |
| alle 8 mit WRITE C=0 (danach Leerlauf, **kein** Warmstart) | 8/8 | **7/8, der letzte bleibt aus** | **7/8, der letzte bleibt aus** |
| C=2 | -- | 7/8 | -- |
| C=0, dann `X` (fremde Spur lesen) | 8/8 | 8/8 | 8/8 |
| C=0, dann `R` (die 8 zurueckLesen, trifft fremden Sektor) | 8/8, RB=8 | 8/8, RB=8 | 8/8, RB=8 |
| C=0, dann HOME / SELDSK / 2 s warten | -- | 7/8 (unveraendert) | -- |
| C=0, Leerlauf 400 Mio. Takte (~160 s) | -- | 7/8 (unveraendert) | 7/8 |
| vier Saetze eines Sektors, C=0,0,0,1 (`B`) | -- | 4/4 sofort | -- |
| vier Saetze eines Sektors, C=0,0,0,0 (`b`) | -- | 4/4 sofort (voller Sektor wird nach dem 4. Satz geschrieben) | -- |

**Antwort:** ein Satz ist auf der Diskette (a) bei **C=1 sofort**, (b) bei 128-B-Sektoren (26 x 128) **immer sofort** (Satz = Sektor, nichts zu entblocken), (c) bei 512-B-Sektoren und GIDE, wenn der **Sektor
vollstaendig** geschrieben wurde oder ein **anderer** Sektor angefasst wird; `HOME`, `SELDSK`, Warten und Leerlauf schreiben **nicht** zurueck (die Quelle sagte das voraus, C1.5 §2.1).  Ein Programmende ohne
Warmstart mit einem einzelnen zurueckgestellten Satz verliert diesen.  **Regel fuer `mutos_io`:** je Block die Saetze in Folge, den **letzten mit C=1** (`C = 0,0,0,1`); damit ist jeder Block bei Rueckkehr von
`WRITE` auf dem Medium.  Es wurde keine Auswirkung auf Nachbarsaetze gemessen (Fremdaenderungen 0 in allen Szenarien).

## 7. Auffaelligkeiten

* **Das BDOS merkt sich das gewaehlte Laufwerk** und ruft `SELDSK` nicht erneut, wenn die Datei auf dem zuletzt vom BDOS gewaehlten Laufwerk liegt: ein Programm, das mit eigenem `SELDSK` auf B: liest und dann BDOS-Datei auf C:
  schreibt, bekommt `Bdos Err On C: Bad Sector` (erste Sonde).  `rdtest`/`blktest` waehlen daher vor jedem BDOS-Zugriff ihr Ziel per `SELDSK` zurueck.  Fuer `mutos_io` ohne BDOS unerheblich, fuer den Lader (C2) beachten.
* `bn >= 494` (26 x 128, 77 Spuren) liegt hinter dem Medium: `READ` meldet Fehler (gemessen: Saetze kommen als Fehler zurueck, `BLKTEST` mit Bloecken bis 1663 endete nicht in der Frist).  Die in C1.4 genannte Grenze `bn < 1664` ist nur die 8-Bit-Grenze der Division, nicht das Plattenende;
  die tatsaechliche Plattengroesse begrenzt der Kernel (Dateisystemgroesse).
* Fehler: `READ` gibt A=1 und das BIOS schreibt die Meldung `R...;T,Si,Se=...` auf den Schirm (gemessen bei Sektor 9 von `root_8x512`); Wiederholungen kosten rund 8,4 Mio. Takte je Spur.  Wirkung auf den Schirm von `mutos_io`: nicht untersucht.
* FM- und MFM-Abbild liefern bis auf das Takt **genau** dieselben Ergebnisse (`root_fm` und `root_mfm` sind im Emulator nicht zu unterscheiden).
* `diskio` (CP/A-Zusatzeinsprung, C1.5) wurde **nicht** untersucht: die Erkennung ist in keinem der vier Faelle falsch, damit entfaellt der Anlass.  Falls C3 die Schreibsatzrechnung (INV) vermeiden will, ist `diskio` die
  Alternative (physisch ohne Formaterkennung, Steuerblock `biosdsk.mac:840-885`).
* Offen fuer C3: Diskettenwechsel -- das BIOS erkennt das Format nur bei `SELDSK` mit E Bit 0 = 0; `mutos_io` muss nach einem Wechsel (Bedienmaske) so neu anmelden und `OFF` neu lesen.  Heute zeigt
  der UDOS-Nukleus die Einheit selbst an (analyse.md).
* Merkposten fuer den Emulator (O5): **keine** noetig (Logpoints mit Takt, `--rw`, `save-as .imd` genuegten).

## 8. Folgerungen

* E1 (Plan 48 §8, Plattenweg): **(a) Standard-BIOS-Einspruenge reichen** -- alle gemessenen Saetze der drei Wurzeldisketten und des GIDE-Laufwerks stimmen; der Sonderfall "CP/A kann die 26 x 128-Disketten nicht" tritt **nicht** ein.
* C3.3: Zeilen `9800..9904` ersetzen durch die Regel §4; je Block vier Aufrufe (`SETTRK`, `SETSEC`, `SETDMA`, `READ`/`WRITE`), Schreiben mit `C = 0,0,0,1`; `OFF` und Sektorlaenge aus dem DPB nach jedem Login;
  Vorlage: `versuche/plus_cpa/blktest.mac`.
* Kein Eingriff in die Disketten noetig; die Zwischenablage `RAW.BIN` ist reine Messhilfe.

## 9. Reproduktion

```
python3 -I versuche/plus_cpa/c1_6_lauf.py alles --arbeit /tmp/mplus/c1_6/alles      # Gesamtlauf, Tabelle in §1 (3 Min.)
```
Einzeln (Muster, im Arbeitsordner): `cpa.com('rdtest', 'versuche/plus_cpa')` -> `RDTEST.COM` auf eine Kopie der GIDE-Systemdiskette; `k1520dbg --em em256 --laderom ul4 --gide=0xD0 --gide-image <platte.img.gz> sys.hfe -b b.hfe --rw`,
`logpoint 0x103`, `logpoint 0x104`, `keys RDTEST\sB\s0\s76\r`, `gscreen "RDTEST DONE"`; Ergebnis `k1520disktool get <platte.img.gz> lw0/RAW.BIN --to <ordner>`.
