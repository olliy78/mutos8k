# C2.3 Lader `M8KBOOT.COM` (Plan 48)

**Stand: erledigt** (Abnahme erreicht), 2026-11-18.  Arbeitsordner `/tmp/mplus/c2_3/`.  Kennzeichnung: *gemessen* (Lauf genannt), *abgeleitet*, *Annahme*.
Quelle `mutos_io/cpa/src/m8kboot.mac`, Bauergebnis `mutos_io/cpa/m8kboot.com` (1024 B nach LINKMT-Rundung, eingecheckt), Wachter `tests/test_plus_cpa_lader.py`,
Debuggerskripte `versuche/dbg/cpa_c2_3_k.dbg`, `cpa_c2_3_voll.dbg` (Platzhalter `@ARBEIT@` usw., der Test setzt sie ein).

## 1. Erste Sonde: Fenster 4000H-7FFFH unter CP/A (`versuche/plus_cpa/emfenst.mac`)

*Gemessen* (2-Floppy-GIDE-Diskette, `--em em256`): A22 alle Seiten 0FH, PIO A32 wie `TAB_PIO_A/B`, Seiten 4..7 := Attribut 0CH (EM 0000H-3FFFH), `OUT (A9H),38H`, Warten auf PIO A Bit 6,
4-KB-Muster (`(i + i/256) XOR 5AH`) per `LDIR` nach 4000H, `OUT (A9H),3CH`.  Ergebnis: `d em:0 32` und `cpu u8000` + `d <<0>>%0000 16` zeigen `5A 5B 58 59 5E ...` ab EM 0000H; `em:0FE0` zeigt
das Ende des Musters (`... 5A 5B ...` bei 0FF1H, danach EM unbeschrieben).  `dev em`: A22 Seiten 4-7 `PW00`.  **Das Fenster 4000-7FFF funktioniert unter CP/A** (LOAD16 unter UDOS benutzte 0000-3FFF).  Annahme des Plans bestaetigt.

## 2. Aufbau des Laders

Lage (Plan §9.0): Code ab 0100H (1024 B), Stapel `SP` = 0FF0H, **`ICOUNT` = 0FFEH** (Wort, nur K-Modus), Kernel-Lesepuffer 1000H-1FFFH, Abbildpuffer ab 8000H (hoechstens 120 Saetze = bis BBFFH; ein 121. Satz
wird nur zur Pruefung "Datei zu Ende" nach BC00H gelesen, das liegt unter dem BDOS), Fenster 4000H-7FFFH (je Stueck eine 4-KB-Seite).

Ablauf (BDOS: 15 Open, 20 Read Sequential, 26 SETDMA; eigener FCB, die Kommandozeile bei 0080H bleibt unberuehrt):
1. `(0001H)-3` = BIOS-Anfang merken (vor dem ersten BDOS-Aufruf, das BIOS ueberschreibt 0001/0002 beim Floppytransfer); Kommandozeile nach `K` absuchen.
2. `EMINIT`: A22 alle 0FH, PIO A/B wie `LOAD16`/`INIT`, `OUT (A9H),38H`, **Rueckleseprobe** `IN (A9H)` (Bits 0-6 muessen 38H sein) und Warten auf PIO A Bit 6 mit Zeitgrenze (65536 Runden), `OUT (A9H),3CH`.
   Schlaegt eines fehl: `M8KBOOT: NO EM`, Warmstart.
3. `MUTOS.SYS` in 4-KB-Stuecken (32 Saetze) nach 1000H, je Stueck A22-Seite (Formel `SEITE_ABBILDEN`, ein Fenster), `DI`, `OUT 38H`, Warten, `LDIR`, `OUT 3CH`, `EI`; EM-Adresse waechst um 1000H.
   Gesamtlaenge 0 oder > 512 Saetze (64 KB): Fehler.  Danach A22 wieder 0FH.
4. Mit `K`: `LD A,I` muss F7H sein; `(F7EAH)` := `ISRCNT` (zaehlt in `ICOUNT`, `EI; RETI`), Meldung `KERNEL LOADED, U8001 STARTED`, `DI`, `OUT (A9H),2CH`, `EI`, Halteschleife (Marke `HALTLP`).
   Die Adresse des `LD A,2CH` (Haltepunkt der Abnahme) findet der Test im `.COM` (Muster `3E 2C D3 A9`, eindeutig): heute 0209H; `ISRCNT` 0210H.
5. Ohne `K`: `MUTOSIO.IMG` nach 8000H; Abbruch `REACHES INTO THE BIOS`, wenn `9000H + Laenge` > BIOS-Anfang (Laenge = Satzzahl x 128), `TOO BIG` ab 121 Saetzen, `MISSING OR EMPTY`;
   danach `DI` (letzter BDOS-Aufruf ist durch), `LDDR` (ueberlappend, absteigend) nach 9000H, `JP 9000H`.  Der U8001 bleibt im Reset.
6. Fehlertexte ueber BDOS 9, dann A22 aus und Warmstart `JP 0` (solange nichts ueberschrieben ist).

## 3. Abnahme (alle *gemessen*, `python3 -m pytest -q tests/test_plus_cpa_lader.py`, 7 Tests, ~35 s; K-Modus einzeln ~7 s)

Original-Kernel `mutos_1216` (36 352 B, `k1520disktool get` von `a5120_mutos8000_boot_udos_k5601.hfe`), Kopie von `cpa.GIDE_SYS` (2 Floppy), `--em em256`, `M8KBOOT K`:
* **EM-Segment 0 ab 0, alle 36 352 B, bytegleich `mutos_1216`** (`save em0.bin em:0 36352` am Haltepunkt vor `OUT 2CH`, `cmp` im Test).
* `emlog`: zehn Paare `PIO B-Daten=38`/`3C` (1 Anwesenheitsprobe + 9 Stuecke wie `LOAD16`), zuletzt `Moduswechsel 16-Bit-Mode`, **`RESET16 0`**; danach Haltepunkt `<<0>>%027E` des U8001 getroffen (`** bp U8001`, FCW C000).
* Zaehl-ISR: `ICOUNT` = **1** nach 30 Mio. Takten (die erste Anforderung kommt, weitere erst nach Bedienung durch `mutos_io`).
* **EM 0006H** (= "4006H" des U880) = `D26A`, vorher (Reset-PC im Kernelabbild) `027E`: der Kernel hat sein Postfach-Zeigerwort geschrieben.  Der Planwortlaut "!= 0" ist wegen `027E` schon vor dem Start erfuellt; der Test verlangt deshalb zusaetzlich `!= 027E`.
* Ladedauer: von `M8KBOOT` bis `RESET16 0` rund 15,5 Mio. Takte (`emlog` c33059696 .. c48547995), fast alles BDOS-Plattenlesen.
* **Ohne `--em`**: Meldung `M8KBOOT: NO EM`, Rueckkehr zum Prompt `A>` (kein Haengen).  *Befund:* die blosse Zeitgrenze auf PIO A Bit 6 reichte **nicht** -- ohne EM-Karte meldete `IN (A8H)` Bit 6 sofort
  als 1, der Lader meldete `KERNEL LOADED` ins Leere.  Darum die Rueckleseprobe von Port B (ohne Karte FFH, mit Karte die geschriebenen Bits 0-6).
* `build.py --check` -> 0 (`mutoscpa.bin` unveraendert, `m8kboot.com` wird mitgebaut).

Zusaetzlich *gemessen* (2-Floppy-Diskette, BIOS CB00H):
* Vollbetrieb `M8KBOOT` mit `MUTOSIO.IMG` aus `build.abbild()` (14 696 B): Haltepunkt 9000H erreicht, Speicher 9000H.. == Abbild (alle 14 696 B, `LDDR` ueberlappend richtig), EM == Kernel, letztes `RESET16` = 1 (U8001 im Reset).
* Fehlerpfade je mit Meldung und Rueckkehr zu `A>`: `MUTOS.SYS NOT FOUND`; MUTOS.SYS 64 KB + 128 B -> `OVER 64 KB`; `MUTOSIO.IMG MISSING`; Abbild 16 000 B -> `TOO BIG`; 15 200 B -> `REACHES INTO THE BIOS` (9000H + 15 232 B = CB80H > CB00H).

## 4. Auffaelligkeiten und Grenzen

* *Nicht gemessen:* 4-Floppy-Diskette (BIOS CA00H; C2.4), Stapeltiefe der BDOS-Aufrufe (Stapel 0FF0H abwaerts, 3 KB frei; kein Ueberlauf beobachtet), `M8KBOOT` mit Kommandozeile ausser `K`/leer.
* Gelesene Dateien werden auf volle 128-B-Saetze aufgefuellt (CP/M): ein `MUTOSIO.IMG`, das nicht auf 128 B endet, wird mit den Fuellbytes der Diskette bis zur naechsten Satzgrenze nach 9000H kopiert (hier 14 696 -> 14 720 B,
  also bis C97FH; frei, unter BIOS CA00H).  Die Lagepruefung rechnet mit der aufgerundeten Laenge.
* Waehrend `OUT 38H` .. `OUT 3CH` sind Interrupts gesperrt (je Stueck ~86 000 Takte, wie bei `LOAD16`); die BIOS-Uhr verliert dabei hoechstens einen Tick je Stueck (*Annahme*, nicht gemessen).
* Der Lader gibt in K-Modus die Kontrolle nie zurueck (Halteschleife); Abbruch nur durch Reset/Debugger.
