# W7i (Plan 52): `as` -- Objektausgabe und kleine Kodierer-Hilfen

Fortsetzung von `wk_w7h.md`.  *Gemessen* = Bau (`pipeline.py alles as --c2emu --libc alt --ist neu_c2`, zwei Laeufe), sonst *Annahme*.  Alle Namen sind *Annahme*.

## 1. Rekonstruiert (11 Funktionen, je ein Block der Quelle)

* `as_code.c` (Objektausgabe): `swabw` (2FF4; mit `cflag` Bytes jedes Wortes vertauschen, `*q++ = *p >> 8 | *p++ << 8`, `unsigned`), `owrite` (3038; nur Pass 2, Dateien 1/3/4/5 gepuffert, Schalter 6BEE, Datei 2 und > 20 Byte direkt, Schreibfehler `fatal output error`), `oflush` (3100), `oflall` (3188; Puffer 1, 3, 4, 5), `fatal` (31BA; `oflall`, `creat(oname)`, `error exit from assembler`, `exit(4)`).
* Neu: `struct obf {ob_n, ob_b, ob_p}` = Ausgabepuffer-Tabelle `obtab[6]` ab 6BCA (initialisiert, in `as_main.c` hinter `errfile`); die Puffer sind die vorhandenen BSS-Felder `gca82` (Datei 1), `gcaaa` (Dateien 3 und 4, je 40 B), `gcafa` (Datei 5).  Der Schalter hat 5 Eintraege (Wert-1), der Eintrag fuer Datei 2 ist `default`.
* `as_expr.c`: `symout` (3988; 12-Byte-Satz Name (7 Bit) / Typbyte / 0 / Wert in `fd_s` (CA6E); `s_x == -1` zaehlt als 0, Typ 0x20: Wert = Nummer).  Aufrufer `symget` (vorher `f3988`).
* `as_misc.c`: `opmatch` (174A; Mnemoniktabelle ab `mp` ueber die Eintraege `"#"` nach Operandenzahl (Byte +3) und Operandenmasken absuchen, `g90b0[]` Operandenzellen, `g90d2[]` Masken; Treffer -> 1C0C), `opclass` (181A; Hash-Schalter `DIV RR2,#6`, 21 Klassenwerte aus der Tabelle 68E2 gelesen: Bit 14/15 nach Typ des 1./2. Operanden), `oppush` (191A), `opreg` (1B2A; Code des Symbols des aktuellen Operanden `g90e2`), `opmask` (1B82; Typmaske einschraenken, Meldung `illegal value`).
* Umbenennungen der Stubs (alle Aufrufer geprueft, `rg` ohne Treffer fuer `f2ff4 f3038 f3100 f3188 f31ba f3988 f174a f181a f191a f1b2a f1b82`): `f3038 -> owrite`, `f31ba -> fatal`, `f3188 -> oflall`, `f3988 -> symout`.  Der Stub-Aufruf `f13a2` aus der Disassemblierung ist das schon vorhandene `iniobj`.
* Datenaenderungen in `as_tab.c`: `g90b0` jetzt `int *g90b0[3]` (90B0, vorher drei einzelne Woerter), `g90d2` `int[5]` (90D2..90DB, ersetzt `g90d2` + `g90d4[8]`), `g90e2` `int *`; `struct sym.s_w` ist `unsigned` (`SLL` in `opreg`).
* Nicht begonnen (Absicht): 1C0C (naechster Schritt), 40A4/4298 (Initialisierung, 500 B / 210 B, mit Tabellen 6F6A/6F72 -- zu gross fuer diesen Schritt).

## 2. Messung

* Bau 2 (mit allen Korrekturen): text 13972 / data 12412 / bss 17724; `--check as`: OK; `pytest -m "not gast"`: 212 bestanden, 1 Fehlschlag (`test_bau_alle_kennt_genau_die_fertigen_disketten`, `disks/gebaut` fehlt im Worktree; wie W7g/W7h).
* Befehlszahlen der Pipeline: W7h gebaut 2421, passend 1248 (1232 ohne c2-Modell), 288 Bloecke.  W7i Bau 1: gebaut 2830, passend 1130 (1125), 265 Bloecke; **Bau 2: gebaut 2866, passend 1207 (1229 ohne Modell), 279 Bloecke**.
* **Die Kennzahl ist hier nicht aussagekraeftig:** die Karte des gebauten Abbilds (`neu_c2.k`) entsteht aus `--vorschlaege` und erreicht Funktionen ohne Aufrufer nicht; `yyparse` ist noch ein Stub, also sind `opmatch`, `opclass`, `oppush`, `opreg`, `opmask` (und teilweise `symout`) im gebauten Listing nur `DW`-Zeilen und werden nicht gezaehlt (Karte enthaelt ausserdem falsche Einstiege wie `code 00CA`).  Pruefung von Hand: Karte aus den Bytes `5F00 366E` (`CALL csv`) als Funktionsanfaenge + `z8kdis`; danach sind `swabw`, `oflush`, `oflall` (Bau 2) Befehl fuer Befehl gleich (Verhaeltnis 1.00), `owrite` und `symout` bis auf die unten genannten Stellen gleich.  Die Handpruefung fuer die uebrigen Funktionen scheiterte an der Karte (Sprungtabellen fehlen), bleibt *Annahme*.

## 3. c2-Modell fuer `as` (Aenderung in `pipeline.py`, nur `as`-Eintrag)

Das Original-Listing von `as` zeigt, dass sein c2 **nicht** die Formen des alten `usr/bin/c2` (Modell R1/R2/R4) erzeugt: `INC R15,#2 ; LD @R15,x` (31D0, 3ADA ...), `XORB RH4,RH4 ; LDB @R2,RL4` (20 Stellen) und `CP MEM,#k` (61 Stellen gegen 13 mit `LD R0`).  Folge: `"as": {"R1","R2","R4","R45"}` ausgeschaltet.  Wirkung (gemessen, Bau 1 -> Bau 2, gleiche Quelle bis auf die unten genannten Umbauten): ohne Modell passend 1125 -> 1229; R1/R2/R4/R30 schreiben 0 Stellen um.  Die uebrigen Regeln (R5 7x, R10 2x, R32 2x) senken die Zahl jetzt von 1229 auf 1207, d.h. sind fuer `as` vermutlich ebenfalls falsch (*Annahme*, nicht getestet: ein Bau pro Schritt).

## 4. Abweichungen und Hinweise fuer den Kodierer 1C0C

* `opmatch`: im Original hat die Funktion einen 0x2E-Byte-Rahmen (`SUB R15,#2E`, nirgends benutzt) und ueberspringt R12 (`i` = R11, `r` = R10); nachgebildet mit einem ungenutzten `char frame[46]` und einer ungenutzten Registervariable (*Annahme*; im Bau 2 nicht Wort fuer Wort geprueft).  Struktur umgestellt, damit der Treffer-Block nach dem `return(1)` liegt (wie im Original): `if (Anzahl != g90de) { next: mp++; ... }`, `goto next` aus der Treffer-Schleife.
* `opreg`: der `t == 32`-Block steht direkt hinter dem Test (Marke `num`, Sprung von der `uflag`-Stelle), `opmask`: `w = m & w` (nicht `&=`), beides um die Befehlsfolge des Originals zu treffen.
* `owrite`: im Original steht `XORB RH4,RH4` vor dem Byte-Speichern der Kopierschleife; mit R2 aus entsteht es im Gast-`cc` ebenfalls (Bau 2: nicht noch einmal nachgesehen).
* Was `1C0C` von diesen Hilfen braucht: `opreg()` (Registercode des Operanden, 72 Aufrufer insgesamt hauptsaechlich im Kodierer), `opmask(m)` (liefert die eingeschraenkte Maske und rueckt `g90e2 = g90b0[++g90c4]` weiter), `owrite(fd,p,n)` (alle Wort-/Byteausgaben, Wortordnung ueber `swabw` bei `cflag`), `symout`.  Die Operandenzellen `g90b0[i]` zeigen auf `int`-Zellen, Wort 0 = Typmaske, Wort 2 = Maske/Wert (+4), Wort 3 = Symbolzelle (+6); der Mnemonikeintrag ist `struct mnent` mit Klassenbyte +2 und Operandenzahl +3 (`m_w[0]`).
* Nicht-Pass-2-Ausgabe: `owrite` tut in Pass 1 nichts (`if (pass)`); Dateien 3/4/5 sind Abschnitte (Text/Daten/Relokation, siehe `sectab[].se_a/se_b`, *Annahme* fuer die Zuordnung).
