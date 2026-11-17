# UDOS-Druckertreiber IFSSPR und PIOPR (Plan 48 C1.3)

Befund zu Schritt C1.3 (Arbeitszweig `plan48-udos`, aus `main`).  Diese Datei wird von der leitenden Sitzung spaeter als §2 in
`doc/mutos_io/udos_lader.md` uebernommen (C1.2 legt dort §1 an).  Kennzeichnung: *gemessen* (Skript/Lauf genannt), *abgeleitet* (aus dem
Programmtext), *Annahme*.  Arbeitsordner der Laeufe: `/tmp/mplus/c1_3/`, Datum 2026-11-17, Disketten als Kopie.

## 1. Ergebnis in einem Absatz

`ACTIVATE` rekonstruieren war nicht noetig: `ACTIVATE $IFSSPR` legt die Datei bei EB00 ab und ruft sie **einmal mit Befehl 0 (install)**;
der Treiber haengt sich selbst in die IM-2-Tabelle des UDOS-Nukleus.  `IFSSPR` (768 B) und `PIOPR` (640 B) sind als `mutos_io/udos/src/ifsspr.mac`
und `piopr.mac` **bytegleich** rekonstruiert (`python3 -I mutos_io/udos/build_drucker.py --check` -> 0; `tests/test_udos_drucker.py`).
Beide sind **derselbe Treiber** mit anderer Hardwareschicht: `IFSSPR` = SIO A32 Kanal B (5EH/5FH, Stromschleife IFSS), `PIOPR` = PIO A31 (54H-57H).
Der Emulator kennt nur den IFSS-Weg; an PIO A31 hat er keinen Drucker.

Bauliste: eigene Liste `mutos_io/udos/build_drucker.py` (C1.2 hat `mutos_io/udos/build.py` noch nicht eingecheckt); die Zusammenfuehrung in
eine Liste ist Sache der leitenden Sitzung (zwei `Programm(...)`-Zeilen).

## 2. Erste Sonde: `ACTIVATE` legt den Treiber nur ab (gemessen)

`versuche/dbg/ifsspr_probe.dbg`: Haltepunkt bei Beginn von `LOAD16` (PC=5000, also nach `ACTIVATE`); `verify <IFSSPR> @0xEB00`: **765 von 768 Byte gleich**.  Die drei
Abweichungen (ED09, ED12, ED13) sind Arbeitszellen (Datei FFH, Speicher 00H).  `ACTIVATE` veraendert den Treiber also nicht, er laedt nur und ruft ihn.

Aufruf (`versuche/dbg/ifsspr_install.dbg`, Logpunkte und Watchpoints):
* genau **ein** Aufruf bei EB14 mit `IY=4348H`, `IY+1 = 0` (Befehl install); der Block liegt im Speicher von `ACTIVATE` (4000-43FF).
* der Treiber schreibt (in dieser Reihenfolge) `0FF0 := EC9E`, `0FE4 := EC86`, `0FDB := 0FDB or 8FH` (6FH -> EFH), `0FF4 := ED60`, `0FF6 := ED79`
  und programmiert CTC 58H und SIO 5FH.  Nach dem Boot (`mutos_io` laeuft) stehen die Eintraege unveraendert (`d 0xFE0`), `LOAD16` und `mutos_io` fassen sie nicht an.
  (Die `wp`-Treffer bei PC=50F8 sind LDIR-Schreibzugriffe von `LOAD16` in den EM-Speicher, keine Zugriffe auf 0FExx.)
* Die Tabelle bei 0FE0/0FF0 ist die IM-2-Tabelle des Nukleus (I=0FH): E4H = CTC-Kanal 2 des Systems, F0H/F2H/F4H/F6H = SIO A32 Kanal B
  (Sendepuffer leer / Status / Empfang / Sonderempfang).  *Abgeleitet* aus dem Basisvektor `WR2 = F0H` und der Vektorabbildung der SIO.

## 3. Schnittstelle bei EB00 (abgeleitet aus dem Text, Teile gemessen)

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

## 4. Hardware und Ports

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

## 5. Rundlauf und Dateien

`mutos_io/udos/src/ifsspr.mac`, `piopr.mac` (M80, englische Kommentare, nur ASCII; `ifsspr.mac` traegt die ganze Beschreibung, `piopr.mac` nur die Unterschiede), `ifsspr.karte`, `piopr.karte`
(Ausgangsstand fuer `z80_disasm2.py`), `ifsspr.bin`, `piopr.bin` (eingecheckt = Dateien der Ladediskette), `build_drucker.py`; Waechter `tests/test_udos_drucker.py` (Quelle -> Bytes == `.bin`,
und `.bin` == Datei der Original-Ladediskette; Skip ohne Werkzeugkette).  Messskripte: `versuche/dbg/ifsspr_probe.dbg`, `ifsspr_install.dbg`, `ifsspr_lp.dbg`, `piopr_lp.dbg`.

## 6. Empfehlung fuer Plan 48 §3.9 (Drucker und tty1)

**Variante (a): BIOS `LIST` mit IOBYTE = LPT (Bits 7,6 = 10, also IOBYTE 80H).**  Begruendung:
* *Gleiche Hardware:* `doc/plus/cpa/c1_5_bios.md` §5 (abgeleitet) -- LPT des BIOS ist **5EH/5FH**, DC1/DC3, ungerade Paritaet, 7 Bit, 9600 Bd, Takt CTC 58H Kanal 0.  Das ist exakt
  das, was `IFSSPR` programmiert (§4).  Der Konflikt aus §3.9 (`LST:` TTY = 50H = tty1) entsteht nur bei IOBYTE-Vorgabe 00H; mit LPT bleibt SIO A33 (50H) fuer tty1 frei.
* Der IFSS-Weg kommt im Emulator an (gemessen §4): die Karte nimmt die Zeichen an und meldet Sende-Interrupts; ein eigener Treiber wie `IFSSPR` ist nicht noetig.
* **Vorbehalte** (nicht gemessen, fuer C1.5/C4.1): (1) `IFSSPR` arbeitet interrupt-getrieben und asynchron, `LIST` blockiert die Hauptschleife von `mutos_io` bis das Zeichen
  gesendet (und XON da) ist -- bei 9600 Bd rund 1 ms je Zeichen, sollte tragbar sein, ist aber zu messen; (2) `IFSSPR` haengt hinter jedes CR ein NUL (Wagenruecklauf-Zeit des Druckers):
  die Anpassung gehoert in den Aufruf von `LIST` (NUL nach CR) und ist beim SD 1157 nicht noetig, wenn dessen Puffer/DC3-Fluss reicht (Merkposten Drucker Nr. 18: DC3 bei Druckbeginn) -- *Annahme*;
  (3) TAB-Expansion und FFH-Ende kommen im Treiber aus dem UDOS-Nukleus (Tab-Tabelle 24C4H); ob der Kernel TAB selbst zu Blanks expandiert, ist nicht gemessen (`/etc/motd` enthaelt kein TAB) -- *offen*, in C4.1 mit einem Text mit TAB pruefen.
* Fallback (b) bleibt offen: den Treiberkern (`ifsspr.mac` ab `HWINIT`) in `mutos_io` uebernehmen, falls (1) die Messung in C4.1 nicht traegt.  Die PIO-Variante ist nicht uebertragbar (am Emulator nicht pruefbar).

## 7. Auffaelligkeiten

* `ACTIVATE` bleibt unrekonstruiert (Zilog-Standardkommando, 1979); fuer die CP/A-Variante genuegt "Treiber laden und install aufrufen" zu verstehen, und das entfaellt bei (a).
* Das System braucht den Treiber an der festen Adresse EB00 nur wegen `CALL 0EB00H` in `mutos_io` (91D9); mit (a) entfaellt auch das.
* Die Arbeitszelle `JOBPTR` (ED12) dient zugleich als Busy-Flag (`BUSYWT` wartet auf 0): ein Auftrag, der nie endet (kein Drucker an PIOPR, ohne Zeitablauf), wuerde den naechsten blockieren;
  hier verhindert nur der Zeitablauf C2H das Haengen.
