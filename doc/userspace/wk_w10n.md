# W10n: Abnahme des c2x mit der Regelmenge je Programm (nur Host-Auswertung plus 2 Gastlaeufe, kein Bau)

Fortsetzung von `wk_w10m.md` Abschnitt 4 (a). Alles *gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht. Kein c2-Code geaendert (`tokcheck` OK).

## 1. Aenderung der Abnahme (`tools/userspace/c2gegen.py`)
* Neu `regelsatz(name, regeln, extra)`: Regelmenge = (`--regeln` + `--extra`) minus `pipeline.c2_aus(name)` (derselbe Code wie der echte Bau); `KEIN_MODELL` (mt) = leer.
  `xpush` nutzt sie je Programm und druckt je Modul `EQUAL`/`DIFFERS` mit den im Programm ausgeschalteten Regeln der Gruppe (`off:...`). `--global` liefert die alte Einheitsliste.
  `--extra R3` ergaenzt programmgebundene Regeln (R3 ist nur fuer Programme ohne R3 in `C2_AUS` an).
* Die liegenden `.sn` in `userspace/c2/work/gegen` waren **veraltet** (gemischt aus cm9/all9-Laeufen, unter dem all9-Modell nur 31/65 gleich statt 54/65); deshalb 2 Gastlaeufe
  (`lauf ... --s0 --kurz --c2x all9_c2.bin` und `cm9_c2.bin`, je alle 65 Module, 28 Sitzungen, je rund 30 min). Die Einheitsliste reproduziert W10l: all9 54/65.

## 2. Zahlen (65 Module)
* **all9**, Einheitsliste (alt): 54 gleich, 11 abweichend.  **Je Programm: 39 gleich, 26 abweichend**; mit `--extra R3`: **40 gleich, 25 abweichend** (init wird gleich, sonst aendert R3 nichts).
* **cm9** (R4,R38,R69), Einheitsliste: 61 gleich, 4 abweichend.  **Je Programm: 54 gleich, 11 abweichend.**  R3 gehoert nur zur xhzero-Gruppe: in cm9 macht `--extra R3` c00, c21, cpp, init *schlechter* (50/15), also dort nicht ansetzen.
* Die Verschlechterung gegenueber der Einheitsliste ist erwartet: c2x wendet die Regeln ueberall an; Programme mit ausgeschalteter Regel (Fall b) werden jetzt als Abweichung gezaehlt statt versteckt.

## 3. Reste nach Ursache
(a) Schalter im Modell, c2x kann ihn nicht; (b) Programm hat die Regel aus, c2x wendet sie unbedingt an (braucht feineren/programmweisen Schalter); (c) echter c2x-Fehler.
all9 je Programm + R3 (25):
* **(b) 18**: sh args, cmd, expand, io, macro, main, name, print, service, stak, word, xec (12; alle Gruppenregeln R1,R4,R2,R7,R10,R30,R32 aus; Befund: erste Abweichung R4-`cp MEM,#k`, R1-`inc SP`, R2/R7/R32-`xorb`),
  ps, pstat (alle aus), hex (R2), ld (R32,R43; erste Stelle Zeile 2226 `xorb` vor `ldb @r2,rl4`), c2/c20, c2/c21 (R7,R32).
* **(a) 1**: mv Zeile 747 (`ld r12,r4` gegen Modell `ld r12,r2`, R63/Kopiepropagation; Schalter `-xcopyprop` fehlt, wie W10h/W10m).
* **(c) 6**: c0/c00 (Zeile 1671, `xorb` vor `cp r2,#%18` fehlt im Modell; mit R3 Zeile 1200), c0/c02 (`jp eq` statt `jr eq`, Folge der Blocklaenge; *Annahme*), cpp (Zeile 510, Blocklage `L81:`),
  ed (Zeile 141, `L8:` statt `jr L8`), tar (Zeile 2347, `push @SP,-%E(FP)` statt `push @SP,r0`), convert (Zeile 134, `jr L21` statt `L21:`).
  convert/ed/c02/tar weichen auch in **cm9** ab (gleiche Stelle), sind also nicht xhzero-Folgen, sondern cmppass/Sprungspanne/Blocklage (cm9: auch dort (c)); convert hat R2 aus, das ist hier nicht die Ursache (*gemessen*: Abweichung ohne R2-Beteiligung in cm9).
* cm9 je Programm (11): **(b) 7**: sh args, cmd, main, service, stak, xec und ps (R4 aus, c2x setzt `ld r0,MEM ; cp r0,#k`); **(c) 4**: c02, convert, ed, tar (wie oben).
* Fall (a) ausser mv: keiner. Neu gegen W10m: nur die Einordnung; init ist mit R3 gleich, ld/c20/c21 sind (b) (Bestaetigung W10m 1).

## 4. Tabelle: Schaltergruppen je Programm (Eingabe fuer W10 Schritt 3/4)
Betrachtet: all9-Regeln R1 (xpush), R4,R38,R69 (xcmpmem), R2,R7,R10,R30,R32,R43,R63 (xhzero u. a.) und R3 (nur xhzero/init). Programme, die nicht genannt sind (alle uebrigen, u. a. cat, ls, tar, mkfs, cc, c0), haben **alles an**.
Quelle: `pipeline.C2_AUS` (gemessen je Programm, doc/userspace/wk_w*.md); "an" nur, soweit c2x die Regel kennt (nicht von c2x implementiert: R2,R7,R10,R30,R32,R43,R63,R3 nur teilweise, siehe W10h-m).

| Programm | aus | an |
|---|---|---|
| sh | R1 R2 R3 R4 R7 R10 R30 R32 | R38 R69 R43 R63 |
| ps, pstat, mt | alle | - |
| as | R1 R2 R4 | rest |
| df, rm | R1 R4 | rest |
| c1 | R4 | rest |
| c2 (c20, c21) | R7 R32 | rest |
| ld | R32 R43 | rest |
| convert, hex | R2 | rest |
| od, dd | R3 | rest (R3 ohnehin nur xhzero) |
| init | - (R3 **an** noetig) | alle inkl. R3 |
| cpp, ed, pr | - | alle (Abweichungen: Fall c) |

Daraus fuer xcc: je Programm die Schalterliste wie `-xpush` (R1), `-xcmpmem` (R4,R38,R69), `-xhzero` (R2,R7,R10,R30,R32,R43,R3) nur dann, wenn **alle** Regeln der Gruppe an sind; teilweise Gruppen (sh, ps/pstat, as, df, rm, c1, c2, ld, convert, hex) brauchen feinere Schalter je Regel (R4 getrennt von R38/R69; R2, R7, R32, R43 einzeln) -- das ist der naechste Schritt, nicht Fall c.

## 5. Verbrauch
Bau 0, Gastlaeufe 2 (all9, cm9 auf je 65 Modulen). `tokcheck` OK; `pytest -m "not gast"` siehe Commit.
