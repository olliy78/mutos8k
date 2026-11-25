# W10ag: die 8 abweichenden Module der c2x-Regression; xpush-Werkzeug (tar, c0, cc), c2x-Flags `b` (R130) und `l` (R131-R133)

Stand 2026-11-25.  Plan 52, W10.  Vorgaenger: `wk_w10af.md`.

## Ergebnis (alles *gemessen*)
* `xpush` (c2x mit Flags je Programm gegen Hostmodell, 65 Module): vorher **57 gleich, 8 abweichend** (c0/c00, c0/c02, c2/c21, convert, cpp, ed, passwd, tar) -- jetzt **59 gleich, 6 abweichend**
  (c2/c21, cc, convert, cpp, ed, passwd).  No-flag c2x == ausgeliefertes c2: **65/65** (Lauf mit dem endgueltigen c2x).
* Wichtig fuer den Vergleich mit W10af: `cc` zaehlt jetzt als abweichend, weil das Werkzeug es korrekt prueft (siehe 2); die alte 57 enthielt cc als "gleich" zufaellig (Flags und Modell ohne `cc=True`).
* c2x-Bild: Text 22860 / Daten 2674 / BSS 2268 = **27802 B** (W10af: 27138; +664 B: Text +592, Daten +72); Datei 25550 B (vorher 24886).  Das ist mehr als "klein": die R131-R133-Muster in `xsite()` sind
  ausgeschrieben; `as_code` (nahe der 64-KB-Grenze) wurde nicht neu gebaut -- vor dem naechsten `bau as --xcc` pruefen.  Bau 313 s + 131 s.

## Aenderungen
1. **Werkzeug (`c2gegen.py xpush`)**: ruft das Modell jetzt mit `tar=True`/`cc=True`/`c0=True` auf, wie `pipeline.py` (sonst fehlt R92 bei tar).  mkfs/ed (Zusatzregeln ohne c2x-Buchstaben, R49-R59 bzw. ed-Regeln)
   nur mit neuer Option `--spezial`; ohne sie bleibt der Vergleich wie in W10af (Modell = allgemeine Regeln).
2. **`pipeline.py` `C2_AUS`**: `c0` und `cc` = R1-R100 aus.  Beide werden *nur* durch `c2_c0_s` (R130-R133) bzw. `c2_cc_s` (R93-R96) modelliert; ohne den Eintrag bekamen sie alle allgemeinen Buchstaben
   (`pcmz...`), das c2x wendete R4 usw. an, das Modell nicht (c0: 5 Module "abweichend" nur deshalb).  `C2_NUR_C0` (R130-R133) fuer alle anderen Programme aus.
3. **c2x (`C2X`, Standard-c2 tokengleich, `tokcheck` OK)**: `b` (`XR130`, `c21.c` rmove INC): `inc SP,#%A ; push @SP,x` wird zu `inc SP,#%8 ; ld @SP,x`
   (Ursache der Quirk: `atoh` kennt keine grossen Hexziffern, `#%A` gibt 0 -- das ausgelieferte c2 verschmilzt nicht; das Original schon).  `l` (`XR131`, `c20.c` `xsite`/`shortjmp`): die drei
   Einzelstellen R131/R132/R133 (`jp eq` -> `jr eq`, c0 `tree`/`treeout`).  `FLAGBUCHSTABE`: R130 `b`, R131 `l`, R132/R133 ohne eigenen Buchstaben; `xcc.REGELN` um R130-R133.
4. Ein Versuch, `codemove()` (n = 16) die R4-Knoten nicht mitzaehlen zu lassen (Hypothese fuer passwd/cpp), aenderte keine Ausgabe (cpp 74 Hunks vorher und nachher) und wurde zurueckgenommen (c2x-Bau 1 war damit verbraucht).

## Die 8 (Ursache, Klasse)
| Modul | Klasse | Ursache | Stand |
|---|---|---|---|
| tar | (a) Werkzeug | `xpush` rief das Modell ohne `tar=True`; R92 fehlte (Zeile 194: Modell `jp eq`, c2x `jr eq`; die Gegenprobe `vergleich tar` war schon bytegleich) | **gleich** |
| c0/c02 | (b) fehlende Regel, klein | R130: 3x `inc SP,#%A ; push` (Modell `inc SP,#%8 ; ld @SP,r2`); dazu bekam c0 alle allgemeinen Buchstaben (Werkzeug, Punkt 2) | **gleich** (Flag `b`) |
| c0/c00 | (b) | R131 (`cp r9,#%8 ; jp ne ; cp @r13,#%5A ; jp eq` -> `jr eq`) und R132 (`cp r2,#%3 ; jp eq ; cp r2,#%7 ; jp eq ; jp` -> `jr eq ; jr`), Zeilen 1918, 1957; dazu der Werkzeugfehler | **gleich** (Flag `l`) |
| c0/c04 | (b) | R133 (`jp eq` hinter `cp r2,#%17`, Zeile 215) | **gleich** (Flag `l`) |
| c2/c21 | (b) Reihenfolge, nicht klein | 3 Stellen (Zeilen 1457, 1920, 3340): das Modell (R3/R10) setzt ein `xorb rhN,rhN` hinter ein `jr cc`; dort entsteht das Muster `xorb ; cp ; jr cc ; add\|jr` erst nach der Sprungoptimierung (`jp L180` fuehrt in einen gemeinsamen Block, `xjump`-Zusammenfuehrung des `xor r2,r2`), das c2x aber `hzkeep` im `rmove` entscheidet.  Abhilfe waere ein spaeter Einfuegepass (wie `hzpass`); nicht gemacht (Platz, Bauten) | abweichend, 3 Zeilen `-xorb` |
| convert | (b) Regel ohne Buchstabe | R72-R76 (`c2_convert_s`): u. a. R74 Schleifeninversion rueckgaengig (Block `L21` Zeile 134), R72 `testl rr2` statt `test r2`; 5 Hunks.  Nicht klein (Umordnung) | abweichend |
| ed | (c) heapabhaengig | c2x-Bau 1 (W10af-Quelltext + nichts Wirksames) war *gleich* (`ed.sn` 46562 B), Bau 2 (gleiche Flags `pcmzkwWs73tr56andgoquv`) weicht ab (46548 B): Zeile 141 Schleifenlage `jr L8` / `L8:`.  Dieselben Flags, anderes Bild -> andere Halde -> `refc`-Altlast in `addsob`/Schleifenentscheidung (F6, `doc/system/bekannte_fehler.md`).  (Zusatzregeln des ed-Modells, `--spezial`, haben keinen Buchstaben: ca. 29 Hunks, davon Kopierweiterleitung `ld r3,r12`) | abweichend |
| cpp | (c) Layout + (b) | Zeile 510: Schleifenlage (`jr L81` / `L81:`), 9 Hunks nach Normierung der Marken; dazu R101-R112 (`c2_cpp_s`) ohne Buchstaben (cpp/cpy gleich: dort keine Stelle) | abweichend |
| passwd | (b) Sprungweite (gemessen) + (c) Layout | Lauf nur mit Flag `c` (R4): **ein** Unterschied, Zeile 134 Modell `jr eq L11`, c2x `jp eq L11` -- der von R4 eingefuegte `ld r0,MEM` verlaengert die Spanne ueber 254 B (`toofar`), das Original hat die Spanne ohne ihn gemessen.  Mit allen Flags kommen Schleifenumordnungen dazu (61 Hunks nach Normierung), Ursache nicht isoliert (Annahme: wie ed) | abweichend |

Hinweis `cc` (neu in der Liste): Modell `c2_cc_s` R93-R96 hat keine c2x-Buchstaben (Zeile 142: `push @SP,_outfile` gegen `push @SP,r3`); vorher durch das Werkzeug verdeckt.

## Messungen
* Laeufe: Gast-`lauf --c2x --kurz --s0 --auto --null` (65 Module je Lauf: `lauf1` mit Bild W10af, `lauf3` mit dem Endbild; Teilmenge c0 cc convert cpp ed passwd c2 tar ld mkfs pr mit Bau 1).
  c0 im Endlauf mit `--regeln` einschliesslich R130-R133 nachgefahren (Flags `bl`): alle 6 Module gleich.
* Einzellauf passwd mit `--regeln R4 --extra ""` (Flag `c`): 8364 B gegen 8220 B, ein Unterschied (s. o.).
* `tokcheck` (c2/cc) OK; `pytest -q -m "not gast"`: 212 ok, 4 uebersprungen.

## Budget
c2x-Bau 2, 65-Module-Lauf 2 (+1 Teilmengenlauf), Einzel-/c0-Laeufe 3 (c0 zweimal, passwd), Host-`xpush` beliebig oft.
