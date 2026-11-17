# UDOS-Lader `LOAD16` (und Umfeld) -- Befund Plan 48 C1.2

Befund zu Schritt C1.2 (Arbeitszweig `plan48-udos`, aus `main`; Entscheidung O1 in Plan 48 §11).  Kennzeichnung: *gemessen* (Skript/Lauf genannt),
*abgeleitet* (aus Quelle oder Doku gelesen), *Annahme*.  Datum der Laeufe 2026-11-17, Arbeitsordner `/tmp/mplus/c1_2/`, Ladediskette
`a5120_mutos8000_boot_udos_k5601.hfe` als Kopie (COW), `--em em256 --laufwerke K5601,K5601,K5601`.  §2 (Druckertreiber) folgt aus C1.3
(`doc/mutos_io/udos_drucker.md`).

## 1. `LOAD16`

### 1.1 Quelle und Rundlauf

* `LOAD16` ist eine UDOS-Datei Typ P, 512 B bei 5000H (`LOAD16 (C)ZFT/KEAW-841001`, 22.08.84; `.fileinfo`: `mem=5000:624A:0080` = LOW 5000, HIGH 624A, Stapel 80H).
  Code endet bei 5181H, dahinter Tabellen und Texte (bis 5198H), Auftragsblock und FFH-Fuellung bis 51FFH; der 4-KB-Lesepuffer 524BH-624AH liegt **ausserhalb** der Datei.
* Quelle `mutos_io/udos/src/load16.mac` (kommentiert, Namen Englisch), Karte `mutos_io/udos/load16.karte`, Bau `mutos_io/udos/build.py`,
  Ergebnis `mutos_io/udos/load16.bin`.  *Gemessen:* `python3 -I mutos_io/udos/build.py --check` -> `OK ... passt zur Quelle (512 Bytes)`, Exit 0
  (77 ohne Emulator/Werkzeugkette); `cmp load16.bin <k1520disktool get ... LOAD16>` gleich.  Die Karte allein (`z80_disasm2.py --format mac --karte`)
  ergibt ebenfalls bytegleich assemblierbaren Text.  Waechter `tests/test_udos_lader.py` (3 Tests, Gasttest ~5 s).
* Bauliste: `build.py` fuehrt nur `load16`; die Druckertreiber haben `build_drucker.py` (C1.3).  Zusammenlegen ist eine Zeile je Programm.

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
