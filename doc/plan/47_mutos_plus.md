# Plan 47: Branch `mutos-plus` -- funktionsfaehiges, aenderbares MUTOS

Stand 2026-11-15.  Gilt nur im Branch `mutos-plus`.  Vorlagen: Plan 41 (K8, K11), Plan 43 §15, `doc/kernel/gesamtbau.md`.  Folgeplaene: 48 (`mutos_io` nach CP/A), 49 (groessere Disketten), 50 (RTC), 51 (Festplatte).
Aussagen sind *gemessen* (mit Fundstelle), *abgeleitet* (aus Quelle gelesen, nicht im Lauf geprueft) oder *Annahme*.

## 1. Ziel

`main` bleibt die bytegleiche Rekonstruktion (Beweis der Herkunft).  `mutos-plus` liefert ein System, das

1. **vollstaendig im Gast aus eingecheckten Quellen gebaut wird** (`make`, `cc`, `as`, `ld`, `dd` von den MUTOS-Disketten), ohne Host-Schritt
   und ohne das c2-Modell (`tools/kernel/c2_modell.py`, Plan 43 §15);
2. **funktional dem Original entspricht** (Boot, Arbeitstests, `ps`/`pstat`/`lp`), aber nicht bytegleich sein muss;
3. **Aenderungen traegt**, die im Original nicht enthalten sind: zuerst die fest eingetragenen Adressen (Abschnitt 4, P2), dann die Plaene 48-51
   (groessere Datentraeger) und weitere Verbesserungen.

## 2. Regeln fuer den Branch

1. **Fluss nur `main` -> `mutos-plus`**, regelmaessig per Merge; nie zurueck.  Was das Original betrifft (Werkzeuge, Pipeline, Herkunftsbefunde,
   Korrekturen am rekonstruierten Quelltext, Doku zum Original), entsteht auf `main` und kommt per Merge hierher.  Hier entsteht nur, was vom Original abweicht.
2. **Konflikte klein halten:** Umbauten in eigene Dateien oder klar abgegrenzte Stellen.  Was `main` noch oft aendert (Userspace-Pipeline,
   c2-Regeln in `tools/userspace/uspace.py`), hier nicht umschreiben.  Die Referenzdisassemblierung `kernel/asm/ref/` bleibt unveraendert;
   editierbare Assemblerquellen liegen getrennt (P1).
3. **Nachweis je Teil:** Unveraenderte Teile behalten ihre Rundlauf-Waechter.  Fuer geaenderte Teile ersetzen Funktionstests die Bytegleichheit
   (Boot bis `#`, Arbeitstests, Fixpunkt des Selbstbaus).  Ein Waechter, der durch eine gewollte Aenderung rot wird, wird nicht geloescht, sondern
   auf den geaenderten Teil eingeschraenkt und in `doc/plus/abweichungen.md` vermerkt.
4. **Jede Abweichung vom Original** steht in `doc/plus/abweichungen.md` (was, warum, wo, wie geprueft).

## 3. Ausgangslage (gemessen, `doc/kernel/gesamtbau.md`)

* Natuerlicher Bau (`gesamtbau.py --natuerlich`): alle 29 C-Dateien + `conf.c`/`sysent.c` mit `cc -O` im Gast (`dev0.c` ohne `-O`), `make` im Gast,
  Bauzeit 736 s Wanduhr; Kernel Text+Daten 36 038 B (Original 36 288), BSS 8CC6..D15C (unter der Grenze D256); bootet bis `#`, neun Arbeitstests bestanden.
* **Host-Anteile je Bau** (abgeleitet aus `tools/kernel/gesamtbau.py`, Abschnitt "Natuerlicher Bau"): `low.s` und die BSS-Zuteilung kommen aus `z8kdis`
  (aus dem Original-Abbild), `shim.s` (zwei Spruenge), `abs.o` (absolute Symbole `u` FC00, Postfach und Puffer ab D256) aus `objformat.py`,
  Anfangswerte ohne C-Definition (`NAT_DATEN`: 88CC..88D4, 8A8C, 8B32..8B4E, 8C94..8C9A) aus dem Abbild, `Makefile` erzeugt, 16-B-Kopf auf dem Host abgeschnitten.
* **`ps`/`pstat` zeigen im verschobenen Kernel Unsinn** (gemessen fuer Stufe 2, 2026-11-04).  Ursache (abgeleitet): `ps` liest das Wort bei 0x23C
  (`userspace/ps/ps.c` `getnl()`), dort steht in `low` die **feste Zahl** `WV %888A` (`kernel/asm/ref/low.s:147`) statt eines Verweises auf `cf_x88a`;
  ausserdem `cf_proctop = (struct proc *)0x8A8C` fest in `kernel/conf/conf.c`.
* Ohne c2-Modell faellt der Fehler des Original-`c2` in `ttyinput` weg (Regel K6, `doc/herkunft/tty2.md`): unser Kernel rechnet dort richtig.

## 4. Arbeitspakete

| AP | Inhalt | Abnahme |
|----|--------|---------|
| **P0** | Branch, dieser Plan, `doc/plus/abweichungen.md`, Abschnitt in `CLAUDE.md` | Commit -- **erledigt** |
| **P1** | **Eingecheckter Quellbaum fuer den Gastbau:** `low.s`, `shim.s`, BSS-Zuteilung und die `NAT_DATEN`-Anfangswerte einmal aus dem natuerlichen Bau uebernehmen und als editierbare Quellen ablegen (Vorschlag `kernel/plus/`: `low.s`, `daten.c` bzw. `.s`, `Makefile`); `abs.o` durch eine Quelle ersetzen (Probe: kann der Gast-`as` absolute globale Symbole? sonst eingechecktes Objekt als Behelf, vermerkt); Kopf mit `dd` im Gast abschneiden (cmd-Diskette einlegen).  Ein Hostskript bereitet nur noch die Datentraeger vor und startet den Gast. | Gastbau ohne Host-Schritt zwischen Quelle und Kernel; Boot bis `#`, Arbeitstests |
| **P2** | **Fest eingetragene Adressen entfernen:** `low.s` `WV %888A` -> `WV _cf_x88a`; `cf_proctop` = Adresse der Variablen `max_proc` statt 0x8A8C (Berichtigung 2026-11-15, §7 P2.3); weitere feste Zahlen in `low.s`/`conf.c`/`NAT_DATEN` suchen (Liste in `abweichungen.md`).  Das feste Auffuellfeld `pad` entfaellt; die BSS darf schwimmen, muss aber unter D256 enden (Pruefung bleibt). | `ps`, `pstat` liefern im Gast die richtige Tabelle (scheduler, init, sh, ps); Arbeitstests |
| **P3** | **Funktionsnachweis und Fixpunkt:** Arbeitstests wie Stufe 2 (11, mit `ps`, `lp`); der selbstgebaute Kernel baut den Kernel erneut, `cmp` beider Kernel im Gast == gleich; Waechter als pytest (Marke `gast`, Exit/Skip 77 ohne Emulator) | `tests/test_plus_selbstbau.py` gruen |
| **P4** | Folgeplaene: 48 `mutos_io` nach CP/A, dann 49 groessere Disketten und 50 RTC (unabhaengig voneinander), zuletzt 51 Festplatte; Detailplanung dort | je AP nach dem jeweiligen Plan |
| **P5** | Weitere Verbesserungen nach Bedarf (Kandidaten, *nicht entschieden*): `NBUF`, EM1024 (1 MB), `/etc/rc` mit Einhaengen, `/etc/mtab` | je Aenderung ein Funktionstest |

Reihenfolge: P0 -> P1 -> P2 -> P3; P4 erst, wenn der Gastbau ohne Host-Schritt steht (jede spaetere Kernelaenderung soll diesen Weg nehmen).
Die Detailplanung von P1-P3 in Agentenschritten steht in §6-§8.

## 5. Offene Fragen

1. Ort der editierbaren Kernelquellen fuer `low`/Daten (`kernel/plus/` vorgeschlagen) -- oder `kernel/c` direkt im Branch aendern?  Vorschlag: C-Quellen
   in `kernel/c` direkt (Merges von `main` bleiben so moeglich, Konflikte nur an geaenderten Stellen), Assembler und Daten neu unter `kernel/plus/`.
   **Die Detailplanung (§7) setzt diesen Vorschlag voraus**; wird anders entschieden, sind P1.3, P2.2 und P2.3 anzupassen.
2. ~~Varianten von `mutos_io` (`K8X512`) vereinfachen?~~  Erledigt durch Plan 48 §3.5: die UDOS-Fassung bleibt unveraendert, die CP/A-Fassung ist eine eigene Quelle.

## 6. Regeln fuer die Agenten (gelten fuer jeden Schritt in §7)

Die Schritte in §7 sind so geschnitten, dass je einer von einem eigenen Agenten (Sonnet) ohne Vorwissen aus diesem Gespraech umgesetzt werden kann.
Jeder Agent bekommt als Auftrag: *"Arbeite im Worktree `/home/olliy/projects/mutos8k-plus` (Branch `mutos-plus`).  Lies `CLAUDE.md`,
`doc/plan/47_mutos_plus.md` §6 und §7 <Schritt>, fuehre genau diesen Schritt aus."*

1. **Lesen vor Handeln:** zuerst `CLAUDE.md` (Sprachregeln, Gastregeln, Nachweisregeln), dann die im Schritt unter *Lesen* genannten Stellen.
2. **Nicht anfassen:** `kernel/asm/ref/`, `tools/kernel/gesamtbau.py`, `tools/kernel/gast_as.py`, `tools/userspace/uspace.py`, alles unter `original/`
   und `disks/`.  Diese Dateien gehoeren zu `main` (Plan 47 §2.1).  Neue Hostwerkzeuge liegen unter `tools/plus/` und **importieren** `gesamtbau`/`gast_as`
   (`sys.path.insert(0, "<repo>/tools/kernel")`).  Braucht ein Schritt eine Aenderung an einer Datei von `main`: anhalten und melden, nicht selbst aendern.
3. **Gastlaeufe** (Emulator, Minuten bis eine Stunde): immer im Hintergrund starten (Bash `run_in_background`), Ausgabe in eine Logdatei im Arbeitsordner;
   **nie mit `sleep` pollen**, auf die Fertigmeldung warten.  Arbeitsordner ausserhalb des Repos: `/tmp/mplus/<schritt>/` (z. B. `/tmp/mplus/p1_1/`).
   Mehrere Gastlaeufe gleichzeitig sind erlaubt (bis 6 erprobt), aber `emu.py` baut beim ersten Aufruf das Emulatorprojekt: zwei Laeufe nicht in derselben Sekunde starten.
   `gast_as.gast_befehle` kopiert die Disketten selbst in den Arbeitsordner; Dateien in `disks/` werden nie beschrieben.
4. **Fehlt der Emulator** (`gast_as.Fehlt`), endet ein Skript mit Exit 77 und ein Test mit Skip; das ist kein Fehlschlag, aber auch keine Abnahme.
5. **Quelltext:** Englisch, nur ASCII, Namen fuer `cpp`/`as`/`ld` auf 8 Zeichen eindeutig, K&R-C wie der MUTOS-`cc` es kennt (keine Prototypen, kein `void`).
   PLZ/ASM-Syntax des Gast-`as`: `doc/werkzeugkette/as_dialekt.md`.  Dokumentation (`doc/plus/*.md`) Deutsch, ohne Umlaute wie die vorhandenen Plaene.
6. **Befunde** stehen in der im Schritt genannten Datei, jeder als *gemessen* (mit Befehl, Arbeitsordner, Datum), *abgeleitet* (mit Fundstelle) oder *Annahme*.
   Jede Abweichung vom Original kommt in `doc/plus/abweichungen.md` (Spalten: was, warum, Stelle, Pruefung).
7. **Abnahme nicht aufweichen.**  Wird die Abnahme nach vernuenftigem Aufwand (etwa drei Anlaeufe) nicht erreicht: anhalten, Befund mit Logauszug in die
   Befunddatei, Stand in §8 auf *blockiert* setzen, melden.  Nicht auf einen anderen Weg ausweichen, den der Schritt nicht vorsieht.
8. **Abschluss jedes Schritts:** Zeile in §8 aktualisieren (Stand, Datum, Commit), dann **ein Commit** mit Betreff `Plan 47 <Schritt>: <Inhalt>`
   (nur bei erreichter Abnahme; Schnelltests `python3 -m pytest -q tests` muessen gruen sein).  Kein Push, kein Merge.
9. **Parallele Agenten** arbeiten nur in den Dateien ihres Schritts (Spalte *Schreibt* in §8); committen nacheinander.

## 7. Detailplanung P1-P3

Gemeinsame Fakten (gemessen bzw. abgeleitet, Stand 2026-11-15):
* Der natuerliche Bau (`tools/kernel/gesamtbau.py --natuerlich`, Funktion `nat_quellen`) legt auf Diskette D (`/mnt`) flach ab: 31 C-Dateien
  (`NAT_CDATEIEN` = `kernel/c/*.c` ohne `varianten/` plus `kernel/conf/conf.c`, `sysent.c`), alle `kernel/h/*.h`, `low.s`, `bss.s`, `dn0.s`..`dn3.s`, `shim.s`,
  `abs.o`, `Makefile`, `make` (`userspace/make/make.bin`).  Im Gast: `cd /tmp; /mnt/make -f /mnt/Makefile` -> `/tmp/lk` (`ld -s`).
* `lk` = 16-B-Kopf + Text + Daten; die BSS steht als **Nullen im Datenabschnitt** (aus `bss.s`, Kopf meldet bss 0).  Der Host schneidet heute Kopf und
  BSS-Nullen ab und rundet auf 512 B.  Das ist der einzige Host-Schritt zwischen Quelle und Kernel.
* `low.s` loescht die BSS beim Start selbst (`ld r2,#L8DC0` .. `cp r2,#%D586`, `kernel/asm/ref/low.s:203-207`): die BSS-Nullen muessen nicht in der Datei stehen (abgeleitet).
* `ps` (`userspace/ps/ps.c` `getnl()`) und `pstat` (`userspace/pstat/pstat.c:103`) lesen das Wort bei 0x23C, dort 29 Worte ab (Wort + 2):
  `cf_nlist[22]`, `cf_x8b8[6]`, `cf_proctop` (`kernel/conf/conf.c:77-84`).  `ps` liest `nl[28]` als **Adresse** und dort den Zeiger `max_proc`
  (`ps.c:143`, `kernel/h/proc.h:47`).  Also muss `cf_proctop` = `&max_proc` sein, nicht das Ende von `proc[]` (abgeleitet).
* 0x23C liegt in `low` (`WV %888A`, `kernel/asm/ref/low.s:147`); `low.o` steht im Makefile zuerst, seine Lage ist damit fest -- 0x23C bleibt die Schnittstelle zu `ps`/`pstat`.
* Fest bleiben duerfen Adressen ab D256 (Postfach D532, Puffer, `mutos_io`-Vertrag) sowie `u` (FC00) und der Bereich EC00..FFFF (CLAUDE.md, `gesamtbau.KONST_AB`).
* Der Gast hat auf der Wurzel kein `dd`, `cmp`, `echo`; `dd`, `cmp`, `ps`, `pstat` liegen auf `a5120_mutos8000_cmd_mfm.hfe` und werden wie `ps` in
  `gesamtbau.boot_pruefen` per DiskTool auf die Quelldiskette kopiert (Ausfuehrbit + mtime 1987 ueber `ausfuehrbar=`).  Alle vier Laufwerke sind belegt
  (A `/tmp`, B `/usr`, C Wurzel, D `/mnt`); die cmd-Diskette selbst einzulegen ist nicht vorgesehen.
* Zeitbedarf (gemessen, `doc/kernel/gesamtbau.md`): `--uebersetzen` ~4 Min., `make` im Gast 736 s, Boot + Arbeitstests einige Minuten.

### P1.0 Gastlauf mit Diskettenwechsel (eingefuegt 2026-11-16)
*Anlass (gemessen, `doc/plus/gastbau.md` §1):* die Quellen (C 228 KB + Header 49 KB + `make` 20 KB + Assembler) passen nicht mehr auf eine
26x128-MFM-Diskette (239 KB frei); `/usr` (4 KB frei) und die Wurzel (40 KB frei) helfen nicht.  **Entscheidung:** keine Umformung der Quellen auf dem Host
(Kommentare entfernen waere ein Host-Schritt zwischen Quelle und Kernel), sondern **zwei Quelldisketten, im Gastlauf gewechselt** -- wie an der echten Maschine.
Die Objekte bleiben auf A (`/tmp`): rechnerisch Objekte 114 KB + `lk` ~55 KB + Kernel ~36-53 KB < 239 KB (abgeleitet aus P1.1-Objekten; messen).
*Haengt ab von:* nichts.  *Gastlauf:* ja (Probe ~10 Min.).
*Lesen:* `tools/kernel/gast_as.py` (`dbg_skript`, `gast_befehle`: Muster, nicht aendern), Abschnitt "Working in the guest" in `CLAUDE.md`.
*Tun:* `tools/plus/gastlauf.py` (Englisch, Exit 77 ohne Emulator) mit `lauf(arbeit, disketten, befehle, rueck, boot_hfe=None, ausfuehrbar=(), frist=...)`:
* `disketten` = Liste von {name: bytes} (eine Quelldiskette je Eintrag); jede wird als eigenes `.hfe` angelegt (Inodes reichlich, Dateien mtime 1987 setzen).
* `befehle` = Liste von Schritten; ein Schritt ist entweder ein Shellbefehl (wie in `gast_befehle`, mit `cat fertigN`-Marke; die Marken-Dateien liegen
  auf **jeder** Quelldiskette) oder `("wechsel", i)`: im Gast `cd /; /etc/umount /dev/rk3` (Prompt abwarten), im Debugger `eject D` + `mount D <diskette i>`,
  im Gast `/etc/mount /dev/rk3 /mnt; cd /mnt`.
* Boot, Einhaengen, PATH, `sync` am Ende und Rueckholen aus `tmp.hfe` wie `gast_as` (eigener Skriptgenerator, `gast_as.disk`/`disktool`/`pruefe_hilfsmittel` importieren).
*Abnahme:* Probelauf: Diskette 1 mit `a.txt`, Diskette 2 mit `b.txt`; Befehle `cat a.txt >/tmp/a`, Wechsel, `cat b.txt >/tmp/b`, `ls /mnt >/tmp/l` -> `/tmp/a`, `/tmp/b`
richtig, `/tmp/l` ohne `a.txt`.  Befund in `doc/plus/gastbau.md` §0.

### P1.1 Ausgangsmessung des natuerlichen Baus
*Haengt ab von:* P1.0.  *Gastlauf:* ja, ~25 Min.  (Erster Versuch 2026-11-16 mit `gesamtbau.py --natuerlich` blockiert: Platz, siehe P1.0.)
*Lesen:* `doc/kernel/gesamtbau.md` (Abschnitt "Natuerlicher Bau"), `tools/kernel/gesamtbau.py` (`natuerlich`, `nat_quellen`, `boot_pruefen`, `main`), `doc/plus/gastbau.md` §0/§1.
*Tun:*
1. `tools/plus/basis.py`: `Welt(rundlauf_gast.kernel_holen(), "/tmp/mplus/p1_1/obj")` (Objekte von 2026-11-16 liegen dort), `nat_quellen` aufrufen, den Inhalt auf
   zwei Disketten verteilen: Diskette 1 = Header + `make` + etwa die Haelfte der C-Dateien + `mk1` (Makefile, das nur deren Objekte baut);
   Diskette 2 = Header + `make` + uebrige C-Dateien + `low.s`, `bss.s`, `dn*.s`, `shim.s`, `abs.o` + `Makefile` (baut den Rest und bindet `lk`; die Objekte
   von Diskette 1 stehen darin ohne Regel, sie liegen schon in `/tmp`).  Regeln und `-D`-Abgleiche genau aus dem `nat_quellen`-Makefile uebernehmen.
   Befehle: `(cd /tmp; /mnt/make -f /mnt/mk1) >/tmp/make1.log 2>&1`, Wechsel, `(cd /tmp; /mnt/make -f /mnt/Makefile) >/tmp/make2.log 2>&1`, `ls -l /tmp >/tmp/ls.log 2>&1`.
2. Host: aus `lk` wie `gesamtbau.natuerlich` den Kernel schneiden (`mutos_1216.nat`, nur hier in P1.1 als Bezug) und mit `gesamtbau.boot_pruefen` booten.
3. Festhalten: Text/Daten aus dem `lk`-Kopf, Text+Daten des Kernels, BSS-Bereich, freier Platz auf A nach dem Bau (`ls.log`/`df` falls vorhanden), Ergebnis
   b1..b11 (b10 `ps` erwartungsgemaess Unsinn), `sha256sum` von `lk` und `mutos_1216.nat`.
*Schreibt:* `tools/plus/basis.py`, `doc/plus/gastbau.md` §1 (Befund des ersten Versuchs bleibt stehen, Messung darunter).  `/tmp/mplus/p1_1/` **bleibt stehen**.
*Abnahme:* Boot bis `#`, b1..b9 und b11 wie in `doc/kernel/gesamtbau.md`; Messwerte mit Datum.

### P1.2 Sonden der Werkzeugkette
*Haengt ab von:* nichts (parallel zu P1.0/P1.1).  *Gastlauf:* ja, ein bis zwei Laeufe zu ~10 Min.
*Lesen:* `doc/werkzeugkette/as_dialekt.md`, `doc/werkzeugkette/objformat.md`, `tools/kernel/gast_as.py` (`gast_assemblieren`, `gast_befehle`),
`tools/kernel/objformat.py`, `userspace/dd/dd.c`, `userspace/cmp/cmp.c`.
*Fragen (jede mit gemessenem Ergebnis beantworten):*
1. **Absolute globale Symbole:** kann der Gast-`as` ein Objekt erzeugen, das `_u` = FC00 (und weitere Symbole ab D256) als *absolut + extern*
   (Typ `0x21`, `objformat.md`) exportiert?  Kandidaten: `$ABS %FC00` vor einer `G`-Deklaration; `G _u L` hinter `$ABS`; Konstante mit `G`.
   Mehrere Varianten in einem Lauf (`gast_assemblieren` nimmt mehrere Teile), Objekte mit `objformat.py` auslesen.  Zusaetzlich binden:
   ein Testmodul, das `_u` benutzt, `ld` muss die absolute Adresse einsetzen.
2. **Echte BSS aus Assembler:** welche `$SECTION`-Schreibweise legt `G name A[%n B]` in den BSS-Abschnitt (Kopf: text 0, data 0, bss n; Symboltyp 4)?
   Anhaltspunkte: Abschnittsmarke `BSS_B` in `crt0.o` (`objformat.md` Zeile 38), `cc -S`-Ausgaben in `userspace/probe/`; nach `$SECTION`/`$DATA` in
   den `.s`- und `.lst`-Dateien des Repos suchen (`rg -n 'SECTION' userspace doc`).  Pruefen, dass `ld` die BSS hinter die Daten legt und Bezuege
   aus einem anderen Modul (Relokation Art 3) richtig aufloest.
3. **`ld`-Symbole `_etext`/`_edata`/`_end`:** definiert der Gast-`ld` sie?  Probe: Modul mit Bezug auf `_end`, binden, Wert im Ergebnis pruefen.
4. **`dd`/`cmp`:** liegen `bin/dd` und `bin/cmp` auf der cmd-Diskette (`k1520disktool ls`)?  Welche Optionen kennt `dd` laut `dd.c` (`ibs`, `obs`, `bs`,
   `skip`, `count`, `conv=sync`)?  Im Gast messen: `dd if=x of=y ibs=16 skip=1 obs=512` auf eine Datei bekannter Laenge, danach
   `dd if=y of=z bs=512 conv=sync`; Laengen per `ls -l`.  `cmp` auf gleiche und ungleiche Dateien: Ausgabe und Exitstatus (`cmp a b && ls a`).
*Schreibt:* `versuche/plus_sonden/` (Probequellen + kurzes `README`), `doc/plus/werkzeug_sonden.md` (Befunde, je Frage: Antwort, Beleg, Empfehlung).
*Abnahme:* alle vier Fragen gemessen beantwortet; Empfehlung fuer `abs.o` (Quelle oder eingechecktes Objekt) und fuer die BSS (Abschnitt oder Nullen).

### P1.3 Quellen nach `kernel/plus/` uebernehmen
*Haengt ab von:* P1.1.  *Gastlauf:* nein.
*Lesen:* `tools/kernel/gesamtbau.py` (`Welt`, `nat_quellen`, `nat_namen`, `nat_abs`, `MAKEFILE`, `SHIM`), `doc/plus/gastbau.md` §1.
*Tun:*
1. `tools/plus/extrahieren.py` (Englisch kommentiert): baut `Welt(rundlauf_gast.kernel_holen(), "/tmp/mplus/p1_1/obj")`, ruft `nat_quellen` in einem
   Arbeitsordner und schreibt nur die **nicht** aus `kernel/c`, `kernel/conf`, `kernel/h` stammenden Teile nach `kernel/plus/`:
   `low.s`, `bss.s`, `dn0.s`..`dn3.s`, `shim.s`, `abs.o`, `mk1` und `Makefile` (Aufteilung auf zwei Quelldisketten wie in P1.1, `tools/plus/basis.py` wiederverwenden).  Ohne `--force` keine vorhandene Datei ueberschreiben (nach P1.3 sind die
   Dateien in `kernel/plus/` die Quelle und werden von Hand gepflegt; das Skript bleibt nur als Herkunftsbeleg).
2. `kernel/plus/README.md` (Deutsch): Herkunft jeder Datei (erzeugt am Datum X aus Original-Abbild + Objekten von P1.1 durch `extrahieren.py`), ab jetzt
   von Hand gepflegt; Liste der `-D`-Namensabgleiche aus dem Makefile mit Grund (zwei C-Namen fuer eine Variable).
3. Kommentare in den `.s`-Dateien nur, wenn der `as` eine Kommentarform kennt (`as_dialekt.md`); sonst steht alles im README.
*Schreibt:* `tools/plus/extrahieren.py`, `kernel/plus/*`.
*Abnahme:* ein zweiter Lauf von `extrahieren.py --force` in einen Wegwerfordner erzeugt dieselben Bytes wie die eingecheckten Dateien (`diff -r`);
alle Dateien ASCII; `make -n` ist im Gast nicht noetig -- der Inhalt ist gleich dem von P1.1, also bereits gemessen.

**Nachtrag 2026-11-16 (aus P1.1, `doc/plus/gastbau.md` §1.1):** beim Uebernehmen zusaetzlich
4. `bss.s`: `_cfree` mit voller Laenge `%320` (800 B) statt `%310`; die BSS-Grenzpruefung (in `basis.py`/`gastbau.py`) gilt fuer **D266** (`cfreelist`), nicht D256.
5. Platz fuer die 4 B (ttyinput +2, Common `nested` +2): `NCLIST` in `kernel/c/ureg.c` 50 -> 49 und `_cfree` in `bss.s` entsprechend `%310` (784 B).
   Das gibt 16 B frei, 12 B Reserve.  Abweichung in `doc/plus/abweichungen.md` eintragen (Grund: Platz bis D266; Wirkung: ein Clist-Block weniger fuer tty/Drucker).
   `nested` bekommt in `bss.s` einen Namen (`G _nested A[%2 B]`, Lage egal), damit `lk` bss 0 meldet.
6. `bss.o` darf nicht auf A entstehen (Platz, §1.1): bis P1.4 sie als echte BSS erzeugt, `as -u -o /bss.o` (Wurzel) wie in `basis.py`.
*Abnahme* von P1.3 dann: Inhalt gleich `nat_quellen` bis auf die Punkte 4-6 (Diff im README belegt).

### P1.4 Gastbau-Werkzeug und Kernel ohne Host-Schritt
*Haengt ab von:* P1.2, P1.3.  *Gastlauf:* nur zur Fehlersuche.
*Lesen:* `doc/plus/werkzeug_sonden.md`, `kernel/plus/README.md`, `tools/kernel/gast_as.py` (`gast_befehle`), `tools/kernel/gesamtbau.py` (`natuerlich`,
`ladediskette`, `boot_pruefen`, `BOOTTEST`).
*Tun:*
1. **`abs.o`:** zeigt P1.2 Frage 1, dass der `as` absolute globale Symbole kann: `kernel/plus/abs.s` schreiben, Makefile-Regel `as -u`, `abs.o` loeschen.
   Sonst `abs.o` behalten und im README seine Symbole (Name, Wert) und die Erzeugung (`objformat.py`) auflisten.
2. **BSS:** zeigt P1.2 Frage 2 einen BSS-Abschnitt: `bss.s` dorthin verlegen (Reihenfolge der Variablen unveraendert).  Die BSS liegt dann nicht mehr in `lk`.
   Sonst bleiben die Nullen in der Datei (Folge: Kernel-Datei ~53 KB statt ~36 KB; ob der Lader `LOAD16` das annimmt, misst P1.5).
3. **Kernel-Datei im Gast:** Makefile-Ziel `mutos_1216: lk` mit zwei `dd`-Aufrufen nach P1.2 Frage 4 (Kopf 16 B weg, auf 512 B auffuellen).
   Standardziel des Makefiles wird `mutos_1216`.
4. **`tools/plus/gastbau.py`** (Englisch, Exit 77 ohne Emulator):
   * `quellen()`: zwei Quelldisketten nach `kernel/plus/mk1` und `kernel/plus/Makefile` (welche C-Datei wohin, liest das Werkzeug aus den beiden Makefiles):
     Header, `make` (+`make.fileinfo`) auf beide, `kernel/plus/*` (ohne `README.md`) und `dd`, `cmp` von der cmd-Diskette auf Diskette 2.  Pruefen, dass jede C-Datei aus `kernel/c`/`kernel/conf` genau einmal dabei ist.
   * `bauen(arbeit, boot_hfe=None, extra=None)`: `tools/plus/gastlauf.lauf` mit `make -f /mnt/mk1`, Wechsel, `make -f /mnt/Makefile` (Logs `make1.log`, `make2.log`) und
     `ls -l /tmp >/tmp/ls.log 2>&1`, holt Logs, `lk`, `mutos_1216`.  Der Host **prueft** nur (Kopf von `lk`: Ende der BSS < D256, `mutos_1216`
     vorhanden und Vielfaches von 512) und **veraendert keine Bytes**.
   * `boot(arbeit, kernel_bytes)`: ruft `gesamtbau.boot_pruefen` (Arbeitstests b1..b11).
   * Kommandozeile: `gastbau.py bauen --arbeit DIR`, `gastbau.py boot --arbeit DIR --kernel DATEI`, `gastbau.py alles --arbeit DIR` (bauen, dann booten).
*Schreibt:* `tools/plus/gastbau.py`, `kernel/plus/Makefile`, `kernel/plus/abs.s` bzw. README, `kernel/plus/bss.s`.
*Abnahme:* siehe P1.5 (dieser Schritt wird mit P1.5 zusammen committet, wenn er allein nicht pruefbar ist).

### P1.5 Abnahme P1
*Haengt ab von:* P1.4.  *Gastlauf:* ja, ~25 Min.
*Tun:* `python3 tools/plus/gastbau.py alles --arbeit /tmp/mplus/p1_5 >/tmp/mplus/p1_5.log 2>&1` im Hintergrund.
*Abnahme:*
1. Bytegleichheit mit P1.1 entfaellt (P1.1 lieferte keinen bootbaren Kernel, P1.3 Punkt 4-6 aendern die Lage).  Stattdessen: `mutos_1216` aus dem Gast == der Kernel, den der Host aus demselben `lk` schneidet (Kopf ab, BSS-Nullen ab, auf 512 gerundet).  Bei BSS-als-Nullen (P1.4 Punkt 2, zweiter Fall):
   die ersten `len(mutos_1216.nat)` Byte gleich, der Rest Null.  Jede andere Abweichung ist ein Befund (nicht weitermachen).
2. Boot bis `#`, b1..b9 und b11 wie P1.1.
3. `doc/plus/gastbau.md` Abschnitt "2. Gastbau ohne Host-Schritt": Aufruf, Messwerte, Laufzeit.  `doc/kernel/gesamtbau.md` nicht aendern (gehoert zu `main`).

### P2.1 Inventar fest eingetragener Adressen
*Haengt ab von:* P1.3 (liest `kernel/plus/`).  *Gastlauf:* nein.  Kann parallel zu P1.4/P1.5 laufen.
*Lesen:* `kernel/plus/*.s`, `kernel/conf/conf.c`, `kernel/c/*.c`, `kernel/h/*.h`, `userspace/ps/ps.c`, `userspace/pstat/pstat.c`, `kernel/karte/adressen.txt`.
*Tun:* jede Zahl suchen, die als Kerneladresse unter D256 benutzt wird:
`rg -n '%[0-9A-F]{4}' kernel/plus/*.s`, `rg -n '0x[0-9A-Fa-f]{3,4}' kernel/c kernel/conf kernel/h`, Marken `L[0-9A-F]{4}` in `kernel/plus/*.s`, die nicht im selben Modul definiert sind.
Je Fund eine Klasse:
* **F (fest, bleibt):** ab D256, `u`/FC00, EC00..FFFF, Hardware-Ports, Vektortabelle in `low`, 0x23C als Schnittstelle zu `ps`/`pstat`.
* **V (Verweis noetig):** zeigt auf Text, Daten oder BSS, die im Gastbau verschoben sein koennen (bekannt: `WV %888A`, `cf_proctop = 0x8A8C`).
* **K (keine Adresse):** Konstante, Maske, Groesse.
Zusaetzlich: welche Eintraege von `cf_nlist`/`cf_x8b8` lesen `ps` und `pstat` (Index -> Bedeutung), und stimmen sie im natuerlichen Bau (BSS-Namen aus `bss.s` sind Namen, also verschiebbar).
*Schreibt:* `doc/plus/feste_adressen.md` (Tabelle: Datei:Zeile, Wert, Klasse, Bedeutung, geplante Aenderung).
*Abnahme:* Tabelle vollstaendig fuer die drei `rg`-Muster (Suchbefehle im Dokument), jede V-Zeile mit Aenderungsvorschlag fuer P2.2/P2.3.

### P2.2 Anfangswerte als C-Quelle
*Haengt ab von:* P1.5, P2.1.  *Gastlauf:* ja, ~25 Min.
*Lesen:* `kernel/plus/dn0.s`..`dn3.s`, `doc/plus/feste_adressen.md`, Kopfkommentare von `kernel/c/main.c`, `sys1.c`, `sig.c`, `tty.c`, `lp.c`, `kernel/h/proc.h`.
*Tun:* `dn0.s`..`dn3.s` durch `kernel/plus/daten.c` ersetzen: `regloc[8]`, `max_proc` (Anfangswert aus `dn1.s`, laut `proc.h` `&proc[2]`), `icode[]` + `szicode`,
`cf_8c94`, `conptr` (zeigt in den Konsolenring der BSS: Namen aus `bss.s` verwenden, keine Zahl), `nlp`.  Werte genau aus den `dn*.s` uebernehmen,
Herkunftsadresse als Kommentar.  Namen und Typen passend zu den `extern`-Deklarationen in `kernel/c` (8 Zeichen!).  Makefile anpassen.
*Schreibt:* `kernel/plus/daten.c`, `kernel/plus/Makefile`, `kernel/plus/README.md`, `doc/plus/abweichungen.md` (Zeile: Datenlage der Anfangswerte).
*Abnahme:* `gastbau.py alles` -> Boot bis `#`, b1..b9, b11.  Der Kernel ist nicht mehr bytegleich zu P1.5; im Befund (`doc/plus/gastbau.md` §3) steht,
welche Bereiche sich verschoben haben (Vergleich der `lk`-Koepfe und der Datenabschnitte).

### P2.3 Verweise statt fester Zahlen
*Haengt ab von:* P2.2.  *Gastlauf:* ja, ~25 Min.
*Lesen:* `doc/plus/feste_adressen.md`, `kernel/plus/low.s` (Deklarationen `X`/`G` am Modulanfang), `kernel/conf/conf.c`.
*Tun:*
1. `kernel/plus/low.s`: `WV %888A` -> `WV _cf_x88a`; `_cf_x88a` als extern deklarieren (Form wie die vorhandenen Externen in `low.s`).
2. `kernel/conf/conf.c`: `struct proc *cf_proctop = (struct proc *)&max_proc;` (`max_proc` ist in `proc.h` deklariert).  Kommentar Englisch: ps reads the
   address of max_proc from nlist[28].  Diese Datei teilen sich `main` und `mutos-plus`: nur diese Zeile aendern.
3. alle weiteren V-Funde aus P2.1 entsprechend.
4. Pruefen, dass der BSS-Loeschbeginn in `low.s` ein Name ist (erste BSS-Variable) und kein `%8DC0`; das Ende `%D586` bleibt (Klasse F).
*Schreibt:* `kernel/plus/low.s`, `kernel/conf/conf.c`, ggf. weitere aus P2.1, `doc/plus/abweichungen.md` (je Aenderung eine Zeile; Zeile "Geplant" streichen).
*Abnahme:* `gastbau.py alles` -> Boot bis `#`, b1..b9, b11; **b10 `ps` zeigt die richtige Tabelle** (Zeilen fuer scheduler, init, sh, ps wie beim Original,
`doc/kernel/gesamtbau.md` "Stufe 1").  Ausgabe in `doc/plus/gastbau.md` §4.

### P3.1 Arbeitstests fuer `mutos-plus`
*Haengt ab von:* P2.3.  *Gastlauf:* ja, ~15 Min.
*Lesen:* `gesamtbau.BOOTTEST`, `gesamtbau.boot_pruefen`, `userspace/pstat/pstat.c` (Optionen `-a -i -x -p -t -u -f`), `doc/herkunft/tty2.md` (Fehler des Original-`c2` in `ttyinput`).
*Tun:*
1. In `tools/plus/gastbau.py` eigene Testliste = `gesamtbau.BOOTTEST` + `pstat -p`, `pstat -i`, `pstat -f` (je in eine Datei).  `boot_pruefen` nicht kopieren:
   `gast_as.gast_befehle` direkt mit der erweiterten Liste aufrufen (Quellen wie in `boot_pruefen` plus `pstat` von der cmd-Diskette).
2. **Automatische Bewertung** je Test (Funktion `bewerten(name, text)`): b8 enthaelt zweimal `summe = 5050`; b9 nennt `prf.o` mit 1600 B; b10 hat eine Zeile mit `sh`
   und eine mit `ps`; `pstat -p` listet mindestens drei belegte Eintraege; die uebrigen: Ausgabe vorhanden, kein `not found`/`core`.  Rueckgabe: Liste der Fehlschlaege.
3. `ttyinput` (Abweichung #1): pruefen, ob sich der Unterschied im Emulator ausloesen laesst (Weg zu `t_xstate ^= XPAGE` lesen: welche Taste, welcher Modus).
   Wenn ja: Test mit `keys` als eigener Schritt; wenn nein: Begruendung in `doc/plus/abweichungen.md` Spalte Pruefung (*abgeleitet*, nicht pruefbar weil ...).
*Schreibt:* `tools/plus/gastbau.py`, `doc/plus/gastbau.md` §5, `doc/plus/abweichungen.md`.
*Abnahme:* `gastbau.py boot` auf den P2.3-Kernel: `bewerten` meldet keinen Fehlschlag.  Gegenprobe: derselbe Lauf mit dem Original-Kernel
(`boot` mit `--kernel` = `mutos_1216` von der Original-Ladediskette) bewertet ebenfalls fehlerfrei -- sonst ist die Bewertung zu streng.

### P3.2 Fixpunkt des Selbstbaus
*Haengt ab von:* P3.1.  *Gastlauf:* ja, zwei Laeufe, zusammen ~50 Min.
*Tun:* in `tools/plus/gastbau.py` Befehl `fixpunkt --arbeit DIR`:
1. Lauf 1: `bauen` mit dem Original-Kernel -> K1.
2. Lauf 2: Ladediskette mit K1 (`gesamtbau.ladediskette`), Quellen wie in `bauen` plus K1 als `/mnt/k1` auf Diskette 2 (Platz pruefen; sonst K1 auf Diskette 1 und vor dem Wechsel nach `/tmp/k1` kopieren); Befehle: Bau (wie `bauen`), dann
   `cmp /tmp/mutos_1216 /mnt/k1 >/tmp/cmp.log 2>&1 && ls -l /tmp/mutos_1216 >/tmp/gleich 2>&1`, danach die Arbeitstests aus P3.1 im selben Lauf.
3. Host holt K2, `cmp.log`, `gleich` und vergleicht K1/K2 zusaetzlich selbst.
*Abnahme:* `cmp.log` leer, `gleich` vorhanden, K1 == K2 auf dem Host, `bewerten` ohne Fehlschlag.  Erwartung (abgeleitet): `cc`/`as`/`ld` sind Nutzerprogramme,
der laufende Kernel beeinflusst ihre Ausgabe nicht.  Sind K1 und K2 verschieden, ist das ein Befund ueber den neuen Kernel: erste abweichende Stellen
(Offset, Modul ueber `lk`-Kopf/Linkreihenfolge) in `doc/plus/gastbau.md` §6, nicht weitermachen.

### P3.3 Waechter und Abschluss
*Haengt ab von:* P3.2.  *Gastlauf:* nur fuer den Langtest.
*Lesen:* `tests/conftest.py` (Marke `gast`), `tests/test_mutos_gesamtbau.py` (Muster fuer Lang-Tests mit Umgebungsvariable).
*Tun:* `tests/test_plus_selbstbau.py`:
* Schnell (immer): `kernel/plus` enthaelt die Dateien des Makefiles; jede C-Datei aus `gesamtbau.NAT_CDATEIEN` steht im Makefile; keine `dn*.s` mehr;
  `kernel/plus/low.s` enthaelt kein `WV %888A`; `kernel/conf/conf.c` enthaelt kein `0x8A8C`; alle Dateien in `kernel/plus` ASCII;
  jede `V`-Zeile aus `doc/plus/feste_adressen.md` als erledigt markiert.
* Lang (`@pytest.mark.gast`, nur mit `K1520_PLUS=1`): `gastbau.fixpunkt` in `tmp_path`, Abnahme wie P3.2.
Dazu: `doc/plus/gastbau.md` Schluss (Aufrufe, Laufzeiten), §8 dieses Plans, `doc/plus/abweichungen.md` Spalte Pruefung auf *gemessen* mit Verweis auf den Test.
*Abnahme:* `python3 -m pytest -q tests/test_plus_selbstbau.py` gruen (schnell); `K1520_PLUS=1 python3 -m pytest -q tests/test_plus_selbstbau.py -k lang` gruen (einmal gemessen, Datum im Dokument).

## 8. Ablauf und Stand

Wellen (innerhalb einer Welle parallel): **1:** P1.0, P1.2 -- **1b:** P1.1 -- **2:** P1.3 -- **3:** P1.4, P2.1 -- **4:** P1.5 -- **5:** P2.2 -- **6:** P2.3 -- **7:** P3.1 -- **8:** P3.2 -- **9:** P3.3.

| Schritt | Schreibt | Gastlauf | Stand | Datum | Commit |
|---------|----------|----------|-------|-------|--------|
| P1.0 | `tools/plus/gastlauf.py`, `doc/plus/gastbau.md` §0 | ~10 Min. | erledigt | 2026-11-16 | (Commit) |
| P1.1 | `tools/plus/basis.py`, `doc/plus/gastbau.md` §1 | ~25 Min. | gemessen (Bau ok; Kernel 4 B zu gross fuer die BSS, Boot verschoben nach P1.5, gastbau.md §1.1) | 2026-11-16 | |
| P1.2 | `versuche/plus_sonden/`, `doc/plus/werkzeug_sonden.md` | ~10-20 Min. | offen | | |
| P1.3 | `tools/plus/extrahieren.py`, `kernel/plus/*` | -- | offen | | |
| P1.4 | `tools/plus/gastbau.py`, `kernel/plus/*` | (Fehlersuche) | offen | | |
| P1.5 | `doc/plus/gastbau.md` §2 | ~25 Min. | offen | | |
| P2.1 | `doc/plus/feste_adressen.md` | -- | offen | | |
| P2.2 | `kernel/plus/daten.c`, Makefile, README, `abweichungen.md` | ~25 Min. | offen | | |
| P2.3 | `kernel/plus/low.s`, `kernel/conf/conf.c`, `abweichungen.md` | ~25 Min. | offen | | |
| P3.1 | `tools/plus/gastbau.py`, `doc/plus/gastbau.md` §5, `abweichungen.md` | ~15 Min. | offen | | |
| P3.2 | `tools/plus/gastbau.py`, `doc/plus/gastbau.md` §6 | ~50 Min. | offen | | |
| P3.3 | `tests/test_plus_selbstbau.py`, Doku | (Langtest) | offen | | |
