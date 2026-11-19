# W7s: Gegenprobe des rekonstruierten `as`, vierter Anlauf (`g90b0` als ein Feld, vierter Operand von `cpir`)

Fortsetzung von `wk_w7r.md`. Werkzeug `tools/userspace/asgegen.py`. Alles *gemessen*, ausser wo *Annahme* steht.

## 1. `illegal number or type of operands` bei `crt0 execle mcrt0 doprnt`

* Die vier Zeilen sind genau die vier Vorkommen von `cpir`/`cpirb` mit **vier Operanden** (Zielregister, `@Quelle`, Zaehlregister, Bedingung):
  `cpir r0,@r7,r1,z` (crt0 31, mcrt0 35), `cpir r4,@r2,r3,z` (execle 31), `cpirb rl0,@r10,r11,eq` (doprnt 245). Alle anderen Befehle haben hoechstens drei.
* `opmatch` (Original 174A) und `mkopnd` (1938) wurden gegen das Original-Listing (`as.lst`) Zeile fuer Zeile verglichen: gleich (Eintragsschritt 14 Byte, Zaehler Byte +3, Masken Worte 1..4, Zusammenfuehren nur bei Maske 0x800/256). Die Logik war also nicht die Ursache.
* Ursache (*Annahme*, durch die Wirkung bestaetigt): die Operandenzellen `g90b0` waren als `int *g90b0[3]` plus ungenutztem `char g90b6[14]` deklariert; im Original liegen sie als ein Feld 90B0..90C3 (bis `g90c4` auf 90C4, 10 Worte).
  `oppush` legt die vierte Zelle auf `g90b0[3]`, also hinter das 3er-Feld; ob dort noch `g90b6` liegt, haengt von der Reihenfolge ab, in der `ld` die Common-Symbole anordnet. Jetzt: `int *g90b0[10]`, `g90b6` entfaellt (gleiche Gesamtgroesse).
* Messung (Bau `alles as` ohne `--c2emu`, also schlichtes `cc -O`; Gast `asgegen lauf --asx neu.bin --libc 80`): `l_crt0 l_execle l_mcrt0 l_doprnt` **bytegleich** (200, 96, 548, 1736 Byte); ausserdem alle 61 weiteren libc-Module, die vorher gleich waren.
  Gesamt 65 von 80 Eingaben gleich; die 15 uebrigen (3 Compilerausgaben, `d_t1..d_t8`, 4 `d_e*` ohne `.o` auf beiden Seiten) siehe Abschnitt 4.

## 2. `d_t3` ersetzt, neue Kleinstfaelle

`d_t3` (`X _v W`, keine gueltige Deklaration) ist jetzt `ld r4,#1; ret`. Neu: `d_t4` `cpir r0,@r7,r1,z`, `d_t5` `cpirb rl0,@r10,r11,eq`, `d_t6` `ldir @r2,@r3,r4`, `d_t7` `cpsir @r2,@r3,r4,z`, `d_t8` `jr z,_f` (Vier-Operanden-Faelle gegen Drei-Operanden-Faelle; Kopf wie `d_t1`).

## 3. Stand der Befehlsbilanz (Punkt 3 der Aufgabe)

* Neubau `alles as --c2emu --libc alt --ist neu_c2`: `neu_c2.bin` 35364 B (wie W7r), eigener Code **4137** von 5891 Befehlen gleich (W7r: 4145), Bloecke 724 (W7r: 721); `--check as` OK (text 22092, data 13706).
  Der Rueckgang um 8 Befehle kommt aus der Aenderung in Abschnitt 1 (anderer Datenaufbau, *Annahme*) oder aus der c2-Seite; nicht weiter untersucht. Die in W7r geaenderten Funktionen (`encode` Pass 0, `yylex`) wurden *nicht* erneut gegen das Original abgeglichen
  (`yylex` 0EA6..0ED6 nur gelesen: `sp && brk == 0 && sp->s_x == -1` stimmt mit dem Original ueberein).

## 4. Offen / Vorbehalte

1. **Die Gegenprobe mit `neu_c2.bin` (dem eigentlichen Bau) ist nicht gelaufen**: die Gastlaeufe waren aufgebraucht (zwei davon durch Umgebungsfehler, s. u.). Gelaufen ist sie mit dem schlichten `neu.bin` (65/80). Dort melden `c_echo c_cat c_cc` und `d_t1..d_t8` `syntax error` in Zeile 8
   mit `error exit`; **nur unsere Seite**, das Original uebersetzt sie (`.o` vorhanden). Gemeinsam: der `.s`-Kopf hat *keine* Kommentarzeile vorweg (die libc-Quellen beginnen mit `! RECONSTRUCTED ...`). Ob das ein Fehler der Quelle oder nur des schlichten Baus (ohne c2-Modell) ist, ist offen:
   mit `neu_c2.bin` pruefen (`asgegen.py lauf --asx userspace/as/work/bau/neu_c2.bin --libc 80`). In W7r waren `c_*` und `d_t1 d_t2` mit `neu_c2.bin` bytegleich.
2. Umgebung im Worktree: `disks/gebaut` (nicht eingecheckt) muss aus dem Hauptbaum kopiert werden, sonst startet der Gast von den Originaldisketten ohne `/bin/echo` u. a. und jede Eingabe schlaegt fehl (so gingen zwei Laeufe verloren);
   ausserdem enthielt die kopierte `userspace/as/work/bau/neu_c2.bin` einen aelteren Stand (30478 B), neu bauen mit `--c2emu --libc alt --ist neu_c2` (ohne diese Optionen baut `alles as` nur `neu`).
3. Die Einzel-Pruefung auf Vier-Operanden-Faelle `d_t4..d_t8` liegt vor, ist aber noch nicht mit dem c2-Bau gelaufen.
