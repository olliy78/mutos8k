# Plan 53: Fehlerbereinigung und einheitlicher Compiler-Regelsatz (`mutos-plus`)

Stand 2026-11-23.  Gilt nur im Branch `mutos-plus` (Regeln aus Plan 47 §2).  Auftrag des Projektinhabers 2026-11-23.
Aussagen sind *gemessen* (mit Fundstelle), *abgeleitet* oder *Annahme*.

## 1. Ziel

Alles -- Kernel, `mutos_io`-unabhaengige Userspace-Programme, Werkzeugkette -- wird mit **einem einheitlichen Compiler-Regelsatz**
gebaut und ist **funktional** gleich dem Original, nicht bytegleich.  Voraussetzung: die latenten Fehler im Originalcode sind behoben,
denn sie wirken, sobald sich Speicheranordnung oder Optimierung aendern.

Auf `main` bleiben die Fehler erhalten (sie gehoeren zum Original); dort sind sie gesammelt: `doc/system/bekannte_fehler.md`.

## 2. Einheitlicher Regelsatz

**Vorschlag:** der ausgelieferte MUTOS-`cc -O` mit dem ausgelieferten `c2` -- ohne Host-Regelmodell (`uspace.c2_emu_s`, `C2_AUS`,
Kernel K1-K6) und ohne `c2x`-Schalter.  Das ist die Kette, die auf den MUTOS-Disketten liegt und mit der ein Anwender im Gast baut
(Plan 47 Ziel 1).  Sobald unsere rekonstruierte Kette (`cc c0 c1 c2 as ld`, Plan 52) funktional gleich ist, gilt sie als gleichwertig.

Folge: Programme, die heute nur ueber programmgebundene Regeln oder `noopt` bytegleich werden, entstehen hier mit anderem Code.  Das ist
gewollt; geprueft wird das Verhalten.

## 3. Arbeitspakete

| AP | Inhalt | Abnahme |
|---|---|---|
| B0 | Bestand: je Programm Bauweg auf `mutos-plus` (Regelsatz, `noopt`, `libc_alt`/Disketten-`libc`), Funktionstest vorhanden? | Tabelle in `doc/plus/fehler.md` |
| B1 | Bekannte Fehler F1-F4 beheben (`doc/system/bekannte_fehler.md`): `c2` `opsetup` `>=` (F1), Nullpruefungen `retopt`/`iterate` (F2), `as` `loc2` loeschen (F3), Kernel ohne K6 (F4, auf `mutos-plus` schon so, Plan 47 §3) | je Fehler ein Test, der ihn ohne Behebung zeigt (z. B. `c2` mit verschobener Anordnung, `as` aus tiefer Stackposition) |
| B2 | Natuerlicher Bau aller Userspace-Programme mit dem Regelsatz aus §2 im Gast | jedes Programm baut; Funktionstest je Programm (vorhandene `gast`-Tests, sonst neu) |
| B3 | **Fehlersuche durch Variation:** jedes Programm zusaetzlich mit anderer Anordnung/anderen Regeln bauen (z. B. `c2x -xA`, ohne `-O`, BSS-Reihenfolge vertauscht) und das Verhalten vergleichen; Abweichungen = Kandidaten fuer latente Fehler | Liste der Kandidaten mit Ursache |
| B4 | Gefundene Fehler beheben; jeden in `doc/plus/abweichungen.md` (Behebung) **und** auf `main` in `doc/system/bekannte_fehler.md` (Befund) eintragen | B2-Tests gruen mit beiden Bauweisen aus B3 |
| B5 | Kernel mit dem Regelsatz aus §2 (natuerlicher Bau, Plan 47) und die Werkzeugkette selbst (`c0 c1 c2 as`) | Boot + Arbeitstests; Werkzeugkette: Fixpunkt des Selbstbaus (Plan 52 W9) |

Reihenfolge: B0 -> B1 -> B2 -> B3/B4 im Wechsel -> B5.  Jedes AP klein schneiden (ein Programm oder eine Fehlerklasse je Schritt).

## 4. Fehlerklassen, nach denen B3 sucht

Aus den bisherigen Funden (`doc/system/bekannte_fehler.md`):

1. Schreiben ueber Feldgrenzen in einen Nachbarn (F1).
2. Verlass auf Nachbarschaft getrennter Variablen (bei der Rekonstruktion von `as` dreimal aufgetreten).
3. Lesen ueber Nullzeiger (F2) -- unter MUTOS harmlos, sonst Absturz.
4. Uninitialisierte lokale Felder, die durch das Loeschen beim `exec` zufaellig 0 sind (F3).
5. Feste Adressen in Bibliotheks- oder Programmcode, die nur bei Originallaenge passen (`libc_alt`, `ps`-Adressen, Plan 47 P2).
6. Compilerfehler, die falschen Code erzeugen (F4) -- hier nicht im Programm zu beheben, sondern durch einen anderen Regelsatz.

## 5. Offene Fragen

* Soll der einheitliche Regelsatz der **ausgelieferte** `c2` sein (Vorschlag) oder unser rekonstruierter `c2` ohne Schalter (funktional gleich,
  gemessen auf 76 Eingaben, `doc/userspace/wk_w10f.md`)?  Beide liefern dieselbe Ausgabe; die Wahl betrifft nur, welche Binaries im Gast liegen.
* Wie weit wird F4 (Fehlcode des alten `c2`) als eigene Klasse gesucht: gibt es weitere Stellen, an denen der alte `c2` falschen Code erzeugt hat?
