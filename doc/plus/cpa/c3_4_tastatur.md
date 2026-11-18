# C3.4 `mutoscpa`: Tastatur (E6d), Diskettenwechsel, Abnahme C3 (Plan 48)

**Stand: erledigt** (Abnahme erreicht nach Abhilfe, Entscheidung der leitenden Sitzung: bleibt im Rahmen von E6), 2026-11-18.  Arbeitsordner `/tmp/mplus/c3_4/` (Laeufe `r5/betrieb`, `r6/wechsel`, `exp/*`).
Abweichungszeile C3.4 in `doc/plus/abweichungen.md`.  Kennzeichnung: *gemessen* / *abgeleitet*.

## 1. Umbau (Quelle `mutoscpa.mac`, `mutoscpa.bin` neu gebaut, Abbild 14 696 B)
* `ISR_TAKT` ruft `TASTE_BIOS` (`PUSH IY`, `CONST`, bei Taste `CONIN`, Code 00H = keine) und legt den Code in `QUEUE_TASTE`, Klasse 4 (wie vorher `TASTE_LESEN`).
  `TASTE_LESEN`/`TAB_TASTE` entfernt; kein `IN` von 5CH/5DH mehr (Test `test_tastatur_ueber_bios_c3_4`).

## 2. Gemessen
* **Boot bis `#`** mit `root_mfm` in C:, `ls -l /` vollstaendig, `cp` nach `/tmp` (t1 8260 B, t2 71 914 B) und auf die Wurzel (r1), `sync`: die Dateien sind auf dem Host (`k1520disktool get`) gleich den Originalen.
* **BIOS-Codes** (Haltepunkt nach `CONIN`): ^D 04, ^C 03, ^U 15, ^Z 1A, ^\ 1C, BS 08, Buchstaben unveraendert; CR kommt als Zeilenende an.  ^C beendet `cat`, ^\ meldet `Quit - core dumped`, ^U loescht die Zeile, BS loescht nach `stty erase '^h'` (Datei `abcd`).
  **Abweichung vom Planwortlaut:** der Plan nennt ^D als Dateiende; der Kernel hat EOT = ^Z (`kernel/h/tty.h` `CEOT` 032), die Tests verwenden ^Z.  Loeschzeichen ist DEL (7FH).  Der Emulator-Befehl `keys` kann 7FH nicht einspeisen (die Taste verpufft, Haltepunkt nie getroffen): DEL ist **ungeprueft** (Merkposten `~/projects/a5120emu/doc/merkposten/keys_del_7f.md`, uncommittet); der BS-Test genuegt fuer die Abnahme.
* **Diskettenwechsel im Betrieb: direkt, ohne Rueckfall.**  `versuche/dbg/cpa_c3_4_wechsel.dbg` (`tests::test_wechsel_c3_4`, bestanden): `mount rk3`, `ls /mnt`/`cat` = `FIRST-DISK`, `umount`, `eject D`/`mount D d1`, `mount`, `ls`/`cat` = `SECOND-DISK`, wieder zurueck = `FIRST-DISK`; keine Plattenfehler.  Die Anmeldung nur nach der Bedienmaske genuegt.
* **Lange Tastenfolge** (5 x 40 Zeichen mit allen Zeichen der Gastskripte, `cat >/tmp/k`, Host-Vergleich):
  ohne Last **gleich** (`exp/none`); mit `ls -lR /usr >/dev/null &` **verschieden** (`exp/ls`), mit Dauerlast `cat /usr/lib/libc.a` ebenso; die gleiche Folge mit dem **UDOS-Weg** (Originalladediskette, `exp/udos`, `ls`-Last) **gleich**.
  Es fehlen Bloecke von rund 40 Zeichen (z. B. `...fmt` dann `-:bipw3...`), dazu verlorene ganze Zeilen.
* **Ursache (gemessen, Logpunkte `exp/ls`):** alle 364 getippten Zeichen kommen im 50-Hz-ISR an (`QUEUE_PUSH` 364), aber `EING_TASTE` gibt sie unter Plattenlast nicht weiter (Uebergaben 324, Tiefe des Rings steigt auf 45, Ring hat 40 Plaetze).  `QUEUE_PUSH` hat keine Ueberlaufpruefung: ueberholt der Schreibindex den Leseindex, gilt der Ring als leer, 40 Zeichen sind weg.
  *Abgeleitet:* synchrones `PLATTE` (C3.3) plus Klassenreihenfolge der Hauptschleife (Klasse 0 vor Klasse 4) lassen Klasse 4 verhungern, solange der Kernel fortlaufend Plattenauftraege stellt; im UDOS-Weg lief die Platte asynchron.  Weder BIOS-Tastaturpuffer noch `CONST`/`CONIN` sind die Ursache.
* `ISR_ANFRAGE` waehrend `READ`: 665 Anforderungen, **keine** im `READ`-Fenster (der Kernel stellt synchron einen Auftrag nach dem anderen) -- die offene Frage aus C3.3 tritt nicht auf.

## 3. Abhilfe und Abnahme (gemessen)
Vor der Abhilfe: Tastenfolge unter `ls -lR`/`cat libc.a`-Last verschieden (Ring ueberlief, s. o.; Zaehler nach der ersten Teilabhilfe 25..30).  Schritte, jeweils mit demselben Lauf gemessen:
1. `QUEUE_PUSH` ohne Ueberlaufschutz -> bei vollem Ring (naechster Schreibindex == Leseindex) wird das **neue** Zeichen verworfen und `V_VERLUST` (das frueher unbenutzte Byte hinter `V_TAKT`, C967H) erhoeht; der Ring erscheint nie leer.
2. `TASTE_ZWISCHEN` (Uebergabe wie `EING_TASTE`: Z8000-Ebene < 4, /VI frei) nach jedem fertigen Plattenauftrag und am Anfang von `PLATTE`: **reichte nicht** (Tiefe 54, Verluste 25..30; Uebergabe nur bei etwa jedem vierten Aufruf: Ebene des Z8000 oder leerer Ring).
3. Zusaetzlich `TASTE_UEBERGABE` (derselbe Kern ohne `DI`/`EI`) in `ISR_TAKT` je Tick, auch bei bereits angestautem Ring: **Tastenfolge gleich** mit `ls`-Last und mit `cat`-Dauerlast.  Das ist die kleinste Aenderung, die die Abnahme erreichte: waehrend eines BIOS-`READ` steht die Hauptschleife, nur der Tick-ISR laeuft.
Begruendung: unter UDOS lief die Hauptschleife waehrend der asynchronen Uebertragung weiter und bediente Klasse 4; mit dem synchronen BIOS-`READ` nicht mehr, die Aenderung stellt das gleichwertige Verhalten her.
* **Abnahme** (`MPLUS_ARBEIT=/tmp/mplus/c3_4/r9 python3 -m pytest -q -s tests/test_plus_cpa_io.py`: 13 passed, 314 s): Boot bis `#`, `ls -l /` vollstaendig, Dateien t1/t2 auf `/tmp` und r1 auf der Wurzel nach `sync` auf dem Host gleich den Originalen,
  zweiter Emulatorlauf mit denselben Kopien liest sie gleich (`cmp` -> `SAME`), Wechsel von rk3 richtig (§2), Tastenfolge 200/200 unter `ls -lR /usr`- und `cat /usr/lib/libc.a`-Last, **`V_VERLUST` = 0** am Ende des Betriebslaufs, `PL_FEHLER` nie getroffen.
* `ISR_ANFRAGE` im `READ`-Fenster: 13 446 `READ`-Saetze, 4303 Anforderungen, **0** innerhalb eines Fensters (der Kernel stellt synchron einen Auftrag nach dem anderen).
* Grenze: unter Last liegt die Latenz einer Taste bis zu einem Tick (20 ms) ueber dem UDOS-Weg; DEL ungeprueft; ein Zaehler ungleich 0 wuerde den Ueberlauf melden (der Test prueft ihn).
