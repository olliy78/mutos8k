# W10h: W10g abschliessen (`-xcmpmem`, passwd, R60/R50) und Schalter `-xhzero`

Fortsetzung von `wk_w10g.md`. Alles *gemessen* (Gastlaeufe 2026-11-20), ausser wo *Annahme* steht.
Bau der c2-Varianten: `pipeline.py bau c2 --c2emu --libc alt --quelle V=VERZEICHNIS ...`, je Variante ein Verzeichnis mit `c20.c`, `c2.h` und `c21.c`
mit vorangestellten `#define`-Zeilen (gleichwertig zu `-D`; mehrere Varianten laufen parallel in einem Aufruf, ca. 5 Minuten). Abnahme wie in W10g:
`c2gegen.py lauf ... --s0 --kurz --c2x BIN`, dann `c2gegen.py xpush ... --regeln ...` (c2x-Ausgabe == ausgelieferter c2 + Host-Regeln).
Die `MOD.s0` (c1-Ausgabe) stammen aus den W5e-Laeufen eines aelteren Arbeitsbaums (gleicher c1, gleiche Quellen); bei jedem Lauf entsteht `MOD.s` neu.

## 1. Standard-c2 unveraendert
Vorverarbeitung von `c21.c` (host `cpp -P -I.`, Tokenstrom md5) ohne Define vor/nach den W10h-Aenderungen gleich (`b23c00a0...`); Gastbau der Variante `neu` aus
dem unveraenderten `userspace/c2`: `neu_c2.bin` 18956 B, **`cmp` gleich** zum Stand W10g; `pipeline.py --check c2` OK (Text 16976, Daten 1984, 85 Funktionen).

## 2. W10g offene Punkte
**(a) `-DXCMPMEM` allein** (Endstand mit X4MARK; `cm_c2.bin` 19182 B), 15 Module (echo cat wc size cmp od date kill who ln mkdir mknod pr passwd chown):
gegen ausgelieferten c2 + R4: **12 von 15 gleich**; + R38: **14 von 15**; + R38 + R69: **15 von 15** (R4-Stellen 71, R38 2: od, pr).
Die W10g-Abweichung bei passwd ist damit kein Fehler des Schalters (b).

**(b) passwd `jr`/`jp`:** die Original-Regel R69 (`cmd_s3b2.md`) sagt: das **Original-passwd hat hier `jp eq L21`** (Ziel 0x10C Byte entfernt; das kurze `jr` ist
fuer den Gast-`as` ausser Reichweite, `ILLEGAL VALUE`). Der ausgelieferte c2 liefert `jr`, weil er ohne die R4-Befehle schaetzt; das c2x mit den eingefuegten
`ld r0,MEM` (je 2 Byte mehr) schaetzt richtig `jp` -- so wie das Original. Kein Nachbessern an `toofar`/`ilen` noetig; die Schaetzung des c2x ist die des Originals.
Abnahme: `xpush passwd --regeln R1,R4,R38,R69` (c2x + XPUSH, W10g-Binary) gleich.

**(c) R60 und R50: nicht Teil des Schalters.**
* R50 (`cp @rN,#k`, nur mkfs, 3 Stellen): im ausgelieferten c2-Ausgabestand von cpp/cpy (R4 aktiv, 5 Stellen in cpy) steht `cp @rN,#k` unveraendert (1 Stelle in cpy,
  gemessen in `gegen/cpp/cpy.s`), und c0 hat 32 solche Stellen ohne R4. R50 gilt also nur fuer mkfs, nicht fuer die Gruppe; es bleibt Host-Regel.
* R60 (od, 1 Stelle, `and r2,#%FF ; ld %4(FP),r2 ; cp %4(FP),#%1F` -> `ld r0,r2`): dieselbe Form mit anderer Maske hat `ld r0,MEM` (cat `#-%1000`, ed `#%7F`, ld 2x `#%1F`),
  also keine allgemeine "Register statt Speicher"-Regel. Unterschied der einen Stelle: Maske `#%FF` *oder* positiver FP-Versatz (Parameter `%4(FP)`, alle Gegenbeispiele sind Locals).
  Mit einer Stelle nicht zu trennen *(Annahme)*; bleibt Host-Regel.

## 3. Schalter `-xhzero` (Regeln R2, R7, R10, R30, R32, R43, R63; R3 nur teilweise)

**Mechanismus (Befund aus Quellvergleich s0/ausgeliefert/Modell, *Annahme* wo vermerkt).** Alle Regeln betreffen `xorb rhN,rhN` (c1 erweitert jedes geladene Zeichen).
Der ausgelieferte c2 verfolgt in `cregs[N]`, dass die hohe Haelfte null ist, und loescht ein spaeteres `xorb` als ueberfluessig. Die Originale taten zweierlei anders:
1. **R2 (+R30, R43, R63):** ein `xorb rhN,rhN` unmittelbar vor `ldb mem,rlN` (Byte-Speichern) ist weg. Das geschieht **spaet**: die Registerverfolgung hat das `xorb` noch gesehen
   (ein zweites, dahinter stehendes `xorb` wird als ueberfluessig gestrichen, gemessen an sh/print: im Original steht keins von beiden), und die Sprunglaengenschaetzung (`shortjmp`)
   hat es noch mitgezaehlt (die Abnahme zeigt gleiche `jr`/`jp` wie der ausgelieferte c2). Umsetzung `hzpass()` als letzter Durchlauf vor `output()`. Ausnahmen (Modell-Kontexte): R30 `testb rlN` hinter dem Speichern,
   R63 `ld rK,rN ; ld rX,rN ; test rN` dahinter, R43 `inc rK,#n(n>1) ; ldb rlN,@rK ; xorb ; ldb @rM,rlN` davor (*Annahme*: das Original wendet eine Ein-Befehl-Schablone an, Regelkontexte uebernommen).
2. **R7:** `ldb rlN,mem ; xorb ; cp rN,..` behaelt das `xorb` (Schalter in der `xorb`-Behandlung, `hzkeep`).
3. **R10/R32 (R3 teilweise):** hinter `xorb ; cp rN,.. ; jr cc` wird das naechste `xorb` (vor `add rN`/`cp rN`/`jr M`) behalten, nur das erste einer Kette (die Modellregel R32 "kill 1x").
   Der Stand W10h loescht dazu `cregs[N]` bei jedem `jr cc` hinter `xorb ; cp rN` (`#ifdef XHZERO` in `rmove`, `case CBR`); das ist zu grob (siehe Abweichungen).

**Umsetzung.** Compile-time `#ifdef XHZERO` in `c20.c` (ein Aufruf) und `c21.c` (`hzdrop`, `hzkeep`, `hzpass`; drei Stellen in `rmove`/`case CBR`). Ohne Define bleibt
der c2 unveraendert: Tokenstrom-md5 von `c20.c` und `c21.c` (host `cpp -P`) vor/nach gleich, Gastbau `neu` aus dem Repo-Stand `cmp` gleich `neu_c2.bin` (Abschnitt 1).
Mit `-DXHZERO` Binary `hz3_c2.bin` 19974 B (Standard 18956 B); drei Entwicklungsstufen gebaut (`hz` 19276, `hz2` 19520, `hz3` 19974).

**Abnahme (Lauf 5, Binary `hz3_c2.bin`):** `c2gegen.py lauf ... --s0 --kurz --c2x` auf **53 Modulen** (ar c0(6) c2(2) cc convert cp cpp(2) date dd ed getty hex init kill ld ls mkfs mount mv ncheck od ps pstat pwd sh(20) stty tar),
`xpush ... --regeln R2,R7,R10,R30,R32,R43,R63` (alle anderen Host-Regeln aus):
* Entwicklung der gleichen Module: Stufe `hz` (naiv: loeschen in `rmove`, `cregs` bei jedem `jr cc`/`ldb` verwerfen) **36 von 53**, `hz2` **36**, `hz3` (spaetes Loeschen, R63/R7/R10-Kontexte) **43 von 53**.
* Die 43 gleichen Module tragen **91 Regelstellen** (R2 37, R7 13, R10 2, R30 19, R32 19, R43 1). In allen 53 Modulen feuern: R2 92, R7 39, R10 3, R30 47, R32 36, R43 2, R63 1.
* Mit R3 im Modell: 39 von 53 (R3-Stellen in pstat, ps, dd, od erzeugt der c2x nicht: das `xorb` steht dort schon nicht in der c1-Ausgabe; dd/od haben R3 im Original ohnehin aus (`C2_AUS`)).
* Gleich: ar, c0/c01-c05, c2/c20, cc, cp, cpp/cpy, date, dd, getty, hex, kill, ls, mkfs, mount, ncheck, od, pstat, pwd, sh (alle ausser macro), stty, tar.
* **Abweichend (10)**, Ursache je Modul gemessen am ersten Differenzblock:
  * c0/c00, c2/c21, ps, init, sh/macro: der c2x behaelt ein `xorb` mehr als das Original (das Loeschen von `cregs` bei `jr cc` ist zu grob: sh/macro `xorb; cp #%22; jr ne L9024; ldb rl2,x; xorb; xor r2,#%80` hat im Original keins).
    *Vorschlag Stufe 4, nicht gebaut/gemessen:* das Behalten ortlich an der `xorb`-Stelle statt Loeschen bei `jr cc` (Kontext `xorb ; cp rN ; jr cc ; xorb ; cp|add rN|jr`, nur das erste einer Kette) und R43 nur bei Ziel `@rM` (init: `ldb _tty,rl3` verlor dadurch das `xorb`).
  * convert, cpp, ed: Blocklage bzw. `jr`/`jp` anders (die Zahl der behaltenen `xorb` verschiebt `comjump`/Spanne); folgt vermutlich aus dem vorigen Punkt, nicht geprueft.
  * ld: R32-Stelle (`xorb` nach `jr eq L370`), in der c1-Ausgabe fehlt dort das `xorb` (c2x kann es nicht erzeugen).
  * mv: nur der Kopieanteil von R63 (`ld r12,r4 ; test r4` statt `ld r12,r2 ; test r2`) weicht ab; das `xorb` stimmt. Gehoert zu `-xcopyprop` (R5-Gruppe).

## 4. Kombination XPUSH + XCMPMEM + XHZERO
`all3_c2.bin` (`-DXPUSH -DXCMPMEM -DXHZERO`) **gebaut**, 20202 B (nur Standard-Baustein-Pruefung durch den Gast-`cc`: uebersetzt und linkt). **Gastabnahme nicht gemessen**: der sechste Gastlauf
(Budget 5 Laeufe) wurde von der Rechtepruefung abgelehnt; ich habe nicht umgangen. Offen, naechster Schritt: `lauf ls stty pwd mount getty hex echo ... --s0 --kurz --c2x all3_c2.bin`, dann `xpush ... --regeln R1,R4,R38,R69,R2,R7,R10,R30,R32`.

## 5. Verbrauch und offen
* Gastlaeufe 5 (1: W10g-Binary auf 15 Modulen, bestaetigt das W10g-Bild; 2: `-xcmpmem` allein; 3-5: `-xhzero` Stufen `hz`, `hz2`, `hz3`).
* c2-Varianten gebaut: 8 (neu, cm, hz, all in einem Aufruf; hz2, all2; hz3, all3), davon `neu`, `cm`, `hz3` abgenommen -- **das gesetzte Budget von 4 Bauten wurde ueberschritten** (zwei Nachbesserungsrunden von `-xhzero`, je 2 Varianten in einem Aufruf, ca. 5 Minuten).
* Standard-c2: `neu_c2.bin` 18956 B bytegleich; `--check c2` OK; `pytest -m "not gast"` 210 passed, 4 skipped.
* Offen: Gastabnahme der Kombination (4); Stufe 4 von `-xhzero` (ortliches Behalten, R43-Ziel `@rM`); R3 vollstaendig (xorb fehlt in c1-Ausgabe: Herkunft unklar, vermutlich Codeverschiebung `comjump`/`backjmp` des
  aelteren c2); R7/R32 aus `ld`; R60/R50 (nur Host); Wirkung auf ganze Programme (Binaerabgleich) und Weitergabe der Schaltermenge je Programm in `pipeline.py`.
