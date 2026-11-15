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
| **P0** | Branch, dieser Plan, `doc/plus/abweichungen.md`, Abschnitt in `CLAUDE.md` | Commit |
| **P1** | **Eingecheckter Quellbaum fuer den Gastbau:** `low.s`, `shim.s`, BSS-Zuteilung und die `NAT_DATEN`-Anfangswerte einmal aus dem natuerlichen Bau uebernehmen und als editierbare Quellen ablegen (Vorschlag `kernel/plus/`: `low.s`, `daten.c` bzw. `.s`, `Makefile`); `abs.o` durch eine Quelle ersetzen (Probe: kann der Gast-`as` absolute globale Symbole? sonst eingechecktes Objekt als Behelf, vermerkt); Kopf mit `dd` im Gast abschneiden (cmd-Diskette einlegen).  Ein Hostskript bereitet nur noch die Datentraeger vor und startet den Gast. | Gastbau ohne Host-Schritt zwischen Quelle und Kernel; Boot bis `#`, Arbeitstests |
| **P2** | **Fest eingetragene Adressen entfernen:** `low.s` `WV %888A` -> `WV _cf_x88a`; `cf_proctop` aus `proc[]`/`NPROC` statt 0x8A8C; weitere feste Zahlen in `low.s`/`conf.c`/`NAT_DATEN` suchen (Liste in `abweichungen.md`).  Das feste Auffuellfeld `pad` entfaellt; die BSS darf schwimmen, muss aber unter D256 enden (Pruefung bleibt). | `ps`, `pstat` liefern im Gast die richtige Tabelle (scheduler, init, sh, ps); Arbeitstests |
| **P3** | **Funktionsnachweis und Fixpunkt:** Arbeitstests wie Stufe 2 (11, mit `ps`, `lp`); der selbstgebaute Kernel baut den Kernel erneut, `cmp` beider Kernel im Gast == gleich; Waechter als pytest (Marke `gast`, Exit/Skip 77 ohne Emulator) | `tests/test_plus_selbstbau.py` gruen |
| **P4** | Folgeplaene: 48 `mutos_io` nach CP/A, dann 49 groessere Disketten und 50 RTC (unabhaengig voneinander), zuletzt 51 Festplatte; Detailplanung dort | je AP nach dem jeweiligen Plan |
| **P5** | Weitere Verbesserungen nach Bedarf (Kandidaten, *nicht entschieden*): `NBUF`, EM1024 (1 MB), `/etc/rc` mit Einhaengen, `/etc/mtab` | je Aenderung ein Funktionstest |

Reihenfolge: P0 -> P1 -> P2 -> P3; P4 erst, wenn der Gastbau ohne Host-Schritt steht (jede spaetere Kernelaenderung soll diesen Weg nehmen).

## 5. Offene Fragen

1. Ort der editierbaren Kernelquellen fuer `low`/Daten (`kernel/plus/` vorgeschlagen) -- oder `kernel/c` direkt im Branch aendern?  Vorschlag: C-Quellen
   in `kernel/c` direkt (Merges von `main` bleiben so moeglich, Konflikte nur an geaenderten Stellen), Assembler und Daten neu unter `kernel/plus/`.
2. ~~Varianten von `mutos_io` (`K8X512`) vereinfachen?~~  Erledigt durch Plan 48 §3.5: die UDOS-Fassung bleibt unveraendert, die CP/A-Fassung ist eine eigene Quelle.
