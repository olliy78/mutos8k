# UDOS-Lader `LOAD16` und Druckertreiber -- Befund Plan 48 C1.2/C1.3

Befund zu Schritt C1.2 (Arbeitszweig `plan48-udos`, aus `main`; Entscheidung O1 in Plan 48 §11).  Kennzeichnung: *gemessen* (Skript/Lauf genannt),
*abgeleitet* (aus Quelle oder Doku gelesen), *Annahme*.  Datum der Laeufe 2026-11-17, Arbeitsordner `/tmp/mplus/c1_2/`, Ladediskette
`a5120_mutos8000_boot_udos_k5601.hfe` als Kopie (COW), `--em em256 --laufwerke K5601,K5601,K5601`.  §2 (Druckertreiber) ist der Befund von C1.3.

## 1. `LOAD16`

### 1.1 Quelle und Rundlauf

* `LOAD16` ist eine UDOS-Datei Typ P, 512 B bei 5000H (`LOAD16 (C)ZFT/KEAW-841001`, 22.08.84; `.fileinfo`: `mem=5000:624A:0080` = LOW 5000, HIGH 624A, Stapel 80H).
  Code endet bei 5181H, dahinter Tabellen und Texte (bis 5198H), Auftragsblock und FFH-Fuellung bis 51FFH; der 4-KB-Lesepuffer 524BH-624AH liegt **ausserhalb** der Datei.
* Quelle `mutos_io/udos/src/load16.mac` (kommentiert, Namen Englisch), Karte `mutos_io/udos/load16.karte`, Bau `mutos_io/udos/build.py`,
  Ergebnis `mutos_io/udos/load16.bin`.  *Gemessen:* `python3 -I mutos_io/udos/build.py --check` -> `OK ... passt zur Quelle (512 Bytes)`, Exit 0
  (77 ohne Emulator/Werkzeugkette); `cmp load16.bin <k1520disktool get ... LOAD16>` gleich.  Die Karte allein (`z80_disasm2.py --format mac --karte`)
  ergibt ebenfalls bytegleich assemblierbaren Text.  Waechter `tests/test_udos_lader.py` (3 Tests, Gasttest ~5 s).
* Bauliste: `build.py` baut `load16`, `ifsspr` und `piopr` (eine gemeinsame Liste).

### 1.2 Messungen

| Skript (`versuche/dbg/`) | Inhalt |
|--------------------------|--------|
| `load16_ablauf.dbg` | Logpunkte auf 5000, 1003H (UDOS-Aufruf mit IY-Block), 5149 (Seitenwahl), `emlog` der EM-Karte bis zum Eintritt in `mutos_io` (9000) |
| `load16_kopf.dbg` | Attributblock der Kerneldatei (nach 51CBH) und Zellen 0FB4/0FBA |
| `load16_start.dbg` | ab 9000: Bedienmaske mit `keys r` verlassen, `emlog` und erste Befehle des U8001 |

Zeitlage (Takte der Maschine): `LOAD16` startet bei c100148137, der letzte UDOS-Aufruf (close) bei c120675781, `mutos_io` beginnt bei c123351538;
das Laden dauert rund 20 Mio. Takte, davon fast alles UDOS-Plattenlesen.

### 1.3 Antworten (a)-(f)

**(a) Welche UDOS-Dienste ruft `LOAD16`?  (gemessen, `load16_ablauf.dbg`)**  Genau **einen Einsprung: `CALL 1003H`** (dort `JP 1608H`, der SYSTEM-Dienst
des Nukleus, `k1520emu: doc/udos_diskettenformat.md` §14.1), mit `IY` = Auftragsblock bei 5199H.  Aufrufe in dieser Reihenfolge (IY+0 = Klasse, IY+1 = Funktion):

| Nr. | IY+0 | IY+1 | Zweck | Parameter (gemessen) |
|-----|------|------|-------|----------------------|
| 1 | 04 | 02 | Datei oeffnen | IY+2 = `[0FBBH]` = E586H = Zeiger auf das erste Kommandozeilenargument (Text ` mutos_1216`<CR>), IY+11 -> Optionsbyte 0 |
| 2 | 04 | 04 | Attributblock lesen | 128 B nach 51CBH |
| 3-11 | 04 | 0A | Bytes lesen | je 1000H B nach 524BH; neun Aufrufe |
| 12 | 04 | 06 | Datei schliessen | alles 0 |
| (Fehler) | 02 | 10 | Textzeile auf die Konsole | 13 B ab 518CH: `I/O ERROR xx`<CR> |

Die Bedeutung der Funktionscodes ist aus dem Gebrauch *abgeleitet* (kein UDOS-Quelltext vorhanden).  Rueckgabe im Statusbyte IY+10 (51A3H): nach dem Oeffnen, dem
Attributlesen und den ersten acht Leseaufrufen `80H` mit Zaehlung 1000H, der **neunte Leseaufruf liefert `C9H` (= Dateiende, Bit 6 gesetzt) mit Zaehlung 0E00H** (gemessen, Logpunkt 50C1);
`LOAD16` kopiert dieses letzte Stueck noch und schliesst dann.  Bit 6 = Bedingung; ein anderer Code mit Bit 6 fuehrt in den Fehlerzweig (aus dem Code abgeleitet, im Lauf nie ausgeloest).  Weitere UDOS-Zellen: `0FBBH` (Argumentzeiger), `0FB4H` (Fehlerbyte, bei falschem Dateityp `48H` =
ILLEGAL FILE TYPE).  **Kein** Aufruf von 0BFDH/0BEBH (die `mutos_io` benutzt).  Vom Dateikopf liest `LOAD16` nur Typ (Block+0, Bits 7-4 muessen `8` sein: P/P1) und
**LOW ADDRESS** (Block+110 = Kopfsektor-Offset 122; Kerneldatei: `0000`); der Block ist der Kopfsektor ab Offset 12 (Typ, Satzzahl 011CH = 284 x 128 B = 36352 B,
Satzlaenge 80H, ..., HIGH `CEFF` bei Block+112).

**(b) Reihenfolge der EM-Initialisierung (gemessen, `emlog`):**
1. A22: alle 16 Seiten := `0FH` (= gesperrt, die Werte sind negiert; c100148173..).  `OUT (C),A` mit `B` = Seite * 16, `C` = AFH.
2. PIO A32 Port A (Steuer AAH): `EA CF FF B7 EF` = Vektor EAH, Modus 3, alles Eingang, Interruptsteuerwort mit Maske (INT-16 Bit 4); Port B (ABH): `EC CF 80 97 7F` = Vektor ECH,
   Modus 3, Bit 7 (/PE) Eingang, Interrupt auf /PE.
3. Mit dem Moduswort `80` bekommt Port B sein Ausgaberegister (= 0): Meldung des Emulators `16-Bit-Mode, RESET16 0, STOP16 1` -- der U8001 ist **nicht im Reset, aber durch /STOP
   angehalten** (`k1520dbg` zeigt `EM=16-Bit U8001=STOP`, PC `<<127>>%FFFF`); das gilt von c100149148 bis zum ersten Kopieren (~8 Mio. Takte, UDOS liest dabei).
4. Je Stueck (neunmal): A22 zweier benachbarter Seiten (`SETPAG`), `OUT (A9H),38H` (Bit 2 /RAMEN = 0: EM-RAM freigegeben, Bit 4 RESET16 = 1), Warten auf PIO A Bit 6 (8/16-Flag
   = 1, `IN (A8H)` = 48H; die Schleife lief im Lauf ohne Umlauf), `LDIR`, `OUT (A9H),3CH` (/RAMEN wieder 1).
   Die A22-Werte: `(~H AND C0H) >> 4` mit H = Hoehenbyte der EM-Adresse (Bits 3/2 = EM-Adressbits 15/14, PEN/WE = 0 = aktiv); die Seite ergibt sich aus Z80-Adressbits 13/12 (`B` = H AND 30H),
   die Folgeseite bekommt das Attribut von H+10H (faengt ein Stueck ab, das ueber eine 4-KB-Grenze laeuft).
5. Segment: PIO B Bits 0/1 (SG0P/SG1P) bleiben 0 (Segment 0, `dev em`: `SG=0`).  Paritaet: PR wird von `LOAD16` nicht angefasst (Bit 6 bleibt 0).
Der Port B (Bitbelegung abgeleitet aus `k1520emu: doc/design/17_a5120_16.md` §7.2): Bit 0/1 SG0P/SG1P, 2 /RAMEN, 3 /STOP, 4 RESET16, 5 /TRQ8, 6 PR, 7 /PE.

**(c) Wohin wird der Kernel geschrieben?  (gemessen)**  In den **EM-Segment 0** ab EM-Adresse **LOW ADDRESS der Kerneldatei = 0000H**, fortlaufend in neun Stuecken
(8 x 1000H + 0E00H = 36352 B = Dateilaenge; die Zaehlung 0E00H im letzten Stueck liefert UDOS zusammen mit `C9H`).  Kopiert wird durch das Z80-Fenster **0000H-3FFFH** (A22-Seiten 0..3; die EM-Adresse
ist `Attribut (Bits 15/14) + Z80-Adresse (Bits 13..0)`), nicht durch 4000-7FFF wie spaeter `mutos_io`.  Die Quelle liegt im Puffer 524BH-624AH.  Die Menge ist **nicht**
begrenzt: `LOAD16` liest bis zum Dateiende; die EM-Adresse ist ein 16-Bit-Wort (`+1000H` je Stueck), bei mehr als 64 KB laeuft sie in Segment 0 ueber (*abgeleitet*; die 36 352 B
der Kerneldatei bleiben darunter).  Das Kerneldatei-Abbild (`k1520disktool get`) beginnt mit `0000 C000 0000 027E`: Wort 0 reserviert, FCW `C000`, PC-Segment `0000`, PC-Offset `027EH`
(Reset-Vektor, gemessen mit `d <<0>>%0000 16`).

**(d) Wie wird der U8001 gestartet?  (gemessen, `load16_start.dbg`)**  **`LOAD16` startet ihn nicht.**  Am Ende von `LOAD16` ist PIO B = `3CH`: RESET16 = 1 (U8001 im Reset), 8-Bit-Mode.
Den Start macht `mutos_io`: nach der Bedienmaske (wartet auf eine Taste) und `INIT` (A22 wieder alle `0FH`, PIO-Tabellen noch einmal) ein `OUT (0A9H),2CH` (9009): RESET16 := 0,
/STOP, /TRQ8, /RAMEN inaktiv.  Folge im `emlog`: `Moduswechsel 16-Bit-Mode`, `RESET16 0`; der U8001 holt FCW/PC aus Segment 0, Adresse 0002H..0007H, und
laeuft bei `<<0>>%027E` los (`LD R0,#0 / LDCTL PSAPSEG,R0 ...`, FCW C000 = Segmentmodus, System). 

**(e) Zustand, den `LOAD16` fuer `mutos_io` hinterlaesst (gemessen, `dev em` / `r` bei 9000):**
* U880: `IM 2`, Interrupts **EI**, `I = 0FH` (UDOS-Vektortabelle bei 0F00H); `SP = CBFB` (UDOS-Stapel); `mutos_io` setzt `SP = CB68` selbst.
* EM: 8-Bit-Mode (A29), `U8001=RESET16`, A33 = 0, A35/A34/A36 = 0, A22: Seiten 0-4 freigegeben (Attribute vom letzten Stueck, `PW10 PW10 PW01 PW01 PW10`), Seiten 5-F gesperrt;
  PIO A: Modus 3, Vektor EAH, Interrupt freigegeben (`en=1`), PIO B: Modus 3, Ausgaberegister `3CH`, Vektor ECH, Interrupt freigegeben.
* Die Interruptvektorplaetze 0FEAH/0FECH (INT-16, /PE) sind in UDOS **leer (FFFFH)**: `mutos_io` traegt `ISR_ANFRAGE`/`ISR_PARITAET` selbst ein (9400-Segment) -- bis dahin darf kein
  INT-16/Paritaetsinterrupt kommen; er kann nicht, weil der U8001 noch im Reset ist.  Der Zeitgeber-Interrupt (CTC, Vektor E6H -> 0B3CH) des UDOS laeuft weiter.
* UDOS-Fehlerbyte 0FB4H = `80H` (kein Fehler).  Das Kommando `LOAD16` kehrt mit `RET` nach UDOS zurueck; das Skript `MUTOS` startet danach `mutos_io`.

**(f) Was tut `mutos_io` davon noch einmal?  (abgeleitet aus `mutosio.mac`, gemessen im `emlog` ab 9000)**  Alles Hardwarenahe, ausser dem Kopieren und dem Dateizugriff:
A22 alle 16 Seiten `0FH` (INIT 9400, identisch), PIO-A- und PIO-B-Tabellen **bytegleich** (`TAB_PIO_A` = `EA CF FF B7 EF`, `TAB_PIO_B` = `EC CF 80 97 7F`), dann erst der Start des U8001
(`OUT A9H`,2CH).  Es verlaesst sich nur auf den **Kerneldaten im EM** (Segment 0 ab 0) und darauf, dass der U8001 im Reset steht; es braucht **nichts** von `LOAD16`s PIO/A22-Zustand.
Das gilt fuer den CP/A-Lader (C2): wer die Kerneldaten in den EM bringt und den U8001 im Reset laesst, kann `mutos_io` unmittelbar danach starten.

### 1.4 Folgerungen fuer den CP/A-Lader (Plan 48 C2; Annahmen sind so gekennzeichnet)

* Reihenfolge wie `LOAD16`: A22 sperren, PIO A32 programmieren, Datei in 4-KB-Stuecken lesen, je Stueck A22-Seiten setzen, `OUT (A9H),38H`, auf PIO A Bit 6 warten, `LDIR`, `OUT (A9H),3CH`.
  Ohne die Schritte 1-2 fehlt der Moduswechsel A29 (der Emulator setzt 8-Bit-Mode erst mit `38H`).
* **Die Kopierschleife und ihr Stapel muessen ausserhalb des Z80-Fensters liegen.**  `LOAD16` nutzt 0000-3FFF (UDOS-Vektoren und Nukleus liegen dort, werden also waehrend des `LDIR`
  durch EM-RAM ueberdeckt; das ging, weil in den neun Fenstern (je ~86 000 Takte) im Lauf **kein** Interrupt kam: alle 414 aufgezeichneten Interrupts (c100279746..c125803021, ab 5000 bis kurz hinter den Start von `mutos_io`) lagen ausserhalb der neun Fenster -- *gemessen*
  mit `bint on` und dem `emlog`, Ursache nicht untersucht, *Annahme*: der UDOS-Zeitgeber laeuft nur waehrend des Plattenwartens).  Unter CP/A beginnt die TPA bei 0100H:
  `M8KBOOT.COM` aus 0100H wuerde sich selbst ueberdecken.  Empfehlung: Fenster 4000H-7FFFH (A22-Seiten 4..7 wie `SEITE_ABBILDEN` in `mutos_io`) und Programm/Puffer/Stapel anderswo, oder
  Kopierstueck nach 8000H+ legen; `DI` um `LDIR`.
* Der Lesepuffer darf nicht im Fenster liegen (Plan 48 §9 C2: so vorgesehen).
* Kerneldatei unter CP/A: das Abbild ohne UDOS-Kopf (36 352 B, LOW ADDRESS 0000 ist dann Konstante im Lader); der Kopfsektor wird nicht gebraucht (Typpruefung entfaellt).
* Der Lader muss **nichts** an `mutos_io` uebergeben (Zustand siehe (e)).

### 1.5 Offen

* Warum im Lauf kein Zeitgeber-Interrupt in die `LDIR`-Fenster fiel (siehe 1.4, *Annahme*).
* Bedeutung von IY+6/7, Optionsbyte 2 (51A8H, vor dem Attributlesen auf FFH gesetzt -- war es schon) und der Funktionscodes ausser den benutzten: kein UDOS-Quelltext (nur *abgeleitet*).
* Der Fehlerzweig (`I/O ERROR xx`, falscher Dateityp) wurde nicht im Lauf ausgeloest.

## 2. Druckertreiber `IFSSPR` und `PIOPR` (Plan 48 C1.3)

Befund zu Schritt C1.3 (Arbeitszweig `plan48-udos`, aus `main`).  Kennzeichnung: *gemessen* (Skript/Lauf genannt), *abgeleitet* (aus dem
Programmtext), *Annahme*.  Arbeitsordner der Laeufe: `/tmp/mplus/c1_3/`, Datum 2026-11-17, Disketten als Kopie.

### 2.1 Ergebnis in einem Absatz

`ACTIVATE` rekonstruieren war nicht noetig: `ACTIVATE $IFSSPR` legt die Datei bei EB00 ab und ruft sie **einmal mit Befehl 0 (install)**;
der Treiber haengt sich selbst in die IM-2-Tabelle des UDOS-Nukleus.  `IFSSPR` (768 B) und `PIOPR` (640 B) sind als `mutos_io/udos/src/ifsspr.mac`
und `piopr.mac` **bytegleich** rekonstruiert (`python3 -I mutos_io/udos/build.py --check` -> 0; `tests/test_udos_drucker.py`).
Beide sind **derselbe Treiber** mit anderer Hardwareschicht: `IFSSPR` = SIO A32 Kanal B (5EH/5FH, Stromschleife IFSS), `PIOPR` = PIO A31 (54H-57H).
Der Emulator kennt nur den IFSS-Weg; an PIO A31 hat er keinen Drucker.

Bauliste: gemeinsam mit `LOAD16` in `mutos_io/udos/build.py`.

### 2.2 Erste Sonde: `ACTIVATE` legt den Treiber nur ab (gemessen)

`versuche/dbg/ifsspr_probe.dbg`: Haltepunkt bei Beginn von `LOAD16` (PC=5000, also nach `ACTIVATE`); `verify <IFSSPR> @0xEB00`: **765 von 768 Byte gleich**.  Die drei
Abweichungen (ED09, ED12, ED13) sind Arbeitszellen (Datei FFH, Speicher 00H).  `ACTIVATE` veraendert den Treiber also nicht, er laedt nur und ruft ihn.

Aufruf (`versuche/dbg/ifsspr_install.dbg`, Logpunkte und Watchpoints):
* genau **ein** Aufruf bei EB14 mit `IY=4348H`, `IY+1 = 0` (Befehl install); der Block liegt im Speicher von `ACTIVATE` (4000-43FF).
* der Treiber schreibt (in dieser Reihenfolge) `0FF0 := EC9E`, `0FE4 := EC86`, `0FDB := 0FDB or 8FH` (6FH -> EFH), `0FF4 := ED60`, `0FF6 := ED79`
  und programmiert CTC 58H und SIO 5FH.  Nach dem Boot (`mutos_io` laeuft) stehen die Eintraege unveraendert (`d 0xFE0`), `LOAD16` und `mutos_io` fassen sie nicht an.
  (Die `wp`-Treffer bei PC=50F8 sind LDIR-Schreibzugriffe von `LOAD16` in den EM-Speicher, keine Zugriffe auf 0FExx.)
* Die Tabelle bei 0FE0/0FF0 ist die IM-2-Tabelle des Nukleus (I=0FH): E4H = CTC-Kanal 2 des Systems, F0H/F2H/F4H/F6H = SIO A32 Kanal B
  (Sendepuffer leer / Status / Empfang / Sonderempfang).  *Abgeleitet* aus dem Basisvektor `WR2 = F0H` und der Vektorabbildung der SIO.

### 2.3 Schnittstelle bei EB00 (abgeleitet aus dem Text, Teile gemessen)

Aufruf: `CALL 0EB00H` mit **IY = Parameterblock**; `mutos_io` ruft von 91D9 mit IY = AUF1 (A567H), Rueckruf bei 91E1 (`analyse.md` §7).  Block (gemessen die Felder
beim Druckauftrag: `IY+1 = 0FH`, `+2 = A7B6`, `+4 = Zaehlung`, `+6 = +8 = 91E1`, `+10 = 00` vor, `80H` nach dem Auftrag):

| Feld | Bedeutung |
|------|-----------|
| +0 | Einheit (Befehl 04 merkt sie, die Schreibbefehle pruefen sie, wenn geoeffnet) |
| +1 | Befehl; **Bit 0 = asynchron** (sofort zurueck, Ende ueber Rueckruf), sonst Warten bis Status Bit 7 |
| +2/+3 | Pufferadresse |
| +4/+5 | Zaehlung herein, bearbeitete Bytes heraus |
| +6/+7 | Rueckruf "Auftrag fertig" (nur asynchron) |
| +8/+9 | Rueckruf "Fehler" (Status mit Bit 6); 0 = stattdessen +6/+7 |
| +10 | Status: 00 laeuft, 80H gut, C1H falscher Befehl, C2H Zeitablauf, CBH fremde Einheit, D6H belegt, 49H siehe unten |

Befehle (Bit 0 ausmaskiert): 00 install, 02 nichts/gut, 04 oeffnen (Zeile 0), 06 schliessen, 44 entfernen (Slot 0FF0 zurueck, 0FDB Bit 7 loeschen),
**0E Text schreiben** (BC Bytes; Byte FFH beendet; TAB wird nach der UDOS-Tabelle bei 24C4H zu Blanks), 10 Zeile schreiben (endet nach CR), 48 binaer (unveraendert).
**`mutos_io` benutzt nur 0FH = 0E + asynchron** (gemessen, beide Auftraege der Messung).

Ablauf eines Auftrags (*abgeleitet*, Verhalten *gemessen*): der Treiber ist eine **Koroutine**.  `PUTCH` holt die Ruecksprungadresse vom Stapel (Fortsetzung `CONTIN`),
gibt das Byte aus und kehrt zum Aufrufer des Treibers zurueck; der naechste Sende-Interrupt (`TXISR`, Slot 0FF0) baut Register und Fortsetzung wieder auf und laeuft
hinter dem `CALL PUTCH` weiter.  Der Auftrag beginnt mit einem **NUL** (gemessen: je Auftrag ein `OUT (5EH),0` vorweg).  Nach **CR** sendet der Treiber NUL-Fuellbytes,
bis Bit 0 von `0FDBH` gesetzt ist (gemessen: ein NUL, die Bedingung war erfuellt); Bit 1 von `0FDBH` loest beim ersten CR einmal Status 49H aus -- *die Bedeutung der
Nukleus-Bits ist offen*, im Lauf nie ausgeloest.  Zeitablauf: CTC 0EH Kanal 2 (TC C0H, Vorteiler 256, Interrupt in Slot 0FE4) zaehlt `TMOCNT = 03E8H` herunter
(232 + 2 x 256 = 744 Ticks); bei 0 Status C2H.  **Gemessen** mit `PIOPR` (kein Drucker): C2H nach 36,6 Mio. Maschinentakten, das sind bei 2,4576 MHz *(Annahme: Taktrate)* 14,9 s.

### 2.4 Hardware und Ports

`IFSSPR` (*gemessen*, `versuche/dbg/ifsspr_lp.dbg`; *abgeleitet* nach `doc/design/06_k8025_ass.md` des Emulatorprojekts):

| Port | Baustein | Nutzung |
|------|----------|---------|
| 5EH / 5FH | SIO A32 Kanal B Daten / Steuerung = **Hauptdrucker IFSS** (K8025, Stecker X3) | Zeichen `OUT (5EH)`; WR1 per `OUT (5FH)` |
| 58H | CTC A34 Kanal 0 | Baudtakt (07H, TC 01H = 9600 Bd x16), gemeinsam mit der Tastatur-SIO |
| 0EH | System-CTC (K2526) Kanal 2 | Zeitablauf (B7H/37H, TC C0H) |

SIO-Init aus der Tabelle (`INITBL`): 18H, 18H (Reset), WR4 = 4DH (x16, 2 Stopp, Paritaet an/ungerade), WR3 = 41H (Empfang 7 Bit), WR5 = 28H (Senden 7 Bit),
WR2 = F0H (Vektorbasis); beim Auftrag WR1 = 1EH (Empfangs- und Sendeinterrupt, Status veraendert Vektor), danach WR1 = 0.  Handshake im Empfangsinterrupt (`RXISR`, Slot 0FF4):
**XOFF (13H)** -> WR1 = 1CH (Sendeinterrupt aus), **jedes andere Zeichen** (XON) -> WR1 = 1EH und ein NUL senden.  (SIO-Bedeutungen aus dem Datenblatt abgeleitet, nicht gemessen.)
Gemessene Folge im Emulator: `OUT 5FH = 01, 1E` beim Auftragsstart; `dev sio` nach dem Lauf: Kanal B `wr1=00 vec=F0 txBusy=0`; `dev ctc`: Kanal 2 `ctl=37` (Interrupt aus, gestoppt).

**Druckmessung** (`cat /etc/motd > /dev/lp`, `ifsspr_lp.dbg`, UDOS-Ladediskette + Wurzel `root_mfm` in C): zwei Auftraege (53 B, dann 2 B), zusammen **63 x `OUT (5EH),A`**
(die 55 Zeichen des Kernels plus die NUL des Treibers), nach jedem Zeichen ein Sende-Interrupt (EC9E, 63 Treffer), Ende mit Status 80H und Rueckruf 91E1; Abstand
ca. 2850 Maschinentakte je Zeichen (= 9600 Bd mit 7 Bit + Paritaet + 2 Stopp, Annahme).  Am Zeilenende steht am Port LF, CR, NUL (LF/CR vom Kernel, NUL vom Treiber nach dem CR).  **Die Zeichen sind nur
am Port sichtbar**, nicht am Drucker: `k1520dbg` haengt keinen Seriell-Hub an die Karte (Merkposten `~/projects/a5120emu/doc/merkposten/a5120_drucker_pio_a31_und_dbg_seriell.md`, uncommittet).

`PIOPR` (*gemessen*, `versuche/dbg/piopr_lp.dbg`): PIO A31 = 54H (A Daten), 55H (A Steuerung), 56H/57H (B).  Init: A Modus 2 (8FH), Vektor F0H, B 7FH/FFH/FEH; je Auftrag `IN (54H)`, `OUT (57H),87H`,
je Zeichen `IN (54H)`, `OUT (54H),A`.  Nur Slot 0FF0 (Vektor F0H) und 0FE4 werden eingehaengt.  **Im Emulator kommt nie eine Antwort**: `IN (54H)` liefert stets AEH (Abbild der DIL-Schalter, kein Drucker),
kein Interrupt; jeder Auftrag endet mit **Status C2H** (36,6 Mio. Takte), der Kernel wiederholt ihn.  Die Steuerworte sind nach dem Z80-PIO-Datenblatt gedeutet, nicht gemessen.

### 2.5 Rundlauf und Dateien

`mutos_io/udos/src/ifsspr.mac`, `piopr.mac` (M80, englische Kommentare, nur ASCII; `ifsspr.mac` traegt die ganze Beschreibung, `piopr.mac` nur die Unterschiede), `ifsspr.karte`, `piopr.karte`
(Ausgangsstand fuer `z80_disasm2.py`), `ifsspr.bin`, `piopr.bin` (eingecheckt = Dateien der Ladediskette), `build.py`; Waechter `tests/test_udos_drucker.py` (Quelle -> Bytes == `.bin`,
und `.bin` == Datei der Original-Ladediskette; Skip ohne Werkzeugkette).  Messskripte: `versuche/dbg/ifsspr_probe.dbg`, `ifsspr_install.dbg`, `ifsspr_lp.dbg`, `piopr_lp.dbg`.

### 2.6 Empfehlung fuer Plan 48 §3.9 (Drucker und tty1)

**Variante (a): BIOS `LIST` mit IOBYTE = LPT (Bits 7,6 = 10, also IOBYTE 80H).**  Begruendung:
* *Gleiche Hardware:* `doc/plus/cpa/c1_5_bios.md` §5 (abgeleitet) -- LPT des BIOS ist **5EH/5FH**, DC1/DC3, ungerade Paritaet, 7 Bit, 9600 Bd, Takt CTC 58H Kanal 0.  Das ist exakt
  das, was `IFSSPR` programmiert (§4).  Der Konflikt aus §3.9 (`LST:` TTY = 50H = tty1) entsteht nur bei IOBYTE-Vorgabe 00H; mit LPT bleibt SIO A33 (50H) fuer tty1 frei.
* Der IFSS-Weg kommt im Emulator an (gemessen §4): die Karte nimmt die Zeichen an und meldet Sende-Interrupts; ein eigener Treiber wie `IFSSPR` ist nicht noetig.
* **Vorbehalte** (nicht gemessen, fuer C1.5/C4.1): (1) `IFSSPR` arbeitet interrupt-getrieben und asynchron, `LIST` blockiert die Hauptschleife von `mutos_io` bis das Zeichen
  gesendet (und XON da) ist -- bei 9600 Bd rund 1 ms je Zeichen, sollte tragbar sein, ist aber zu messen; (2) `IFSSPR` haengt hinter jedes CR ein NUL (Wagenruecklauf-Zeit des Druckers):
  die Anpassung gehoert in den Aufruf von `LIST` (NUL nach CR) und ist beim SD 1157 nicht noetig, wenn dessen Puffer/DC3-Fluss reicht (Merkposten Drucker Nr. 18: DC3 bei Druckbeginn) -- *Annahme*;
  (3) TAB-Expansion und FFH-Ende kommen im Treiber aus dem UDOS-Nukleus (Tab-Tabelle 24C4H); ob der Kernel TAB selbst zu Blanks expandiert, ist nicht gemessen (`/etc/motd` enthaelt kein TAB) -- *offen*, in C4.1 mit einem Text mit TAB pruefen.
* Fallback (b) bleibt offen: den Treiberkern (`ifsspr.mac` ab `HWINIT`) in `mutos_io` uebernehmen, falls (1) die Messung in C4.1 nicht traegt.  Die PIO-Variante ist nicht uebertragbar (am Emulator nicht pruefbar).

### 2.7 Auffaelligkeiten

* `ACTIVATE` bleibt unrekonstruiert (Zilog-Standardkommando, 1979); fuer die CP/A-Variante genuegt "Treiber laden und install aufrufen" zu verstehen, und das entfaellt bei (a).
* Das System braucht den Treiber an der festen Adresse EB00 nur wegen `CALL 0EB00H` in `mutos_io` (91D9); mit (a) entfaellt auch das.
* Die Arbeitszelle `JOBPTR` (ED12) dient zugleich als Busy-Flag (`BUSYWT` wartet auf 0): ein Auftrag, der nie endet (kein Drucker an PIOPR, ohne Zeitablauf), wuerde den naechsten blockieren;
  hier verhindert nur der Zeitablauf C2H das Haengen.
