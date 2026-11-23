# W7r: Gegenprobe des rekonstruierten `as`, dritter Anlauf (Pass-0-Laenge nach dem Original, lokale Marken, 66 von 75 bytegleich)

Fortsetzung von `wk_w7q.md`. Werkzeug `tools/userspace/asgegen.py`. Alles *gemessen*, ausser wo *Annahme* steht.

## 1. `lauf`: Platz und alte Ergebnisse

* Ursache der Meldung `I can not creat` bei den letzten 9 libc-Eingaben: die Gast-Diskette `/tmp` (`tmp.hfe`) hatte nur **200 Inodes** (`gast_befehle`, fest);
  jede Eingabe legt `.o`/`.n`/`.e` an (plus Compilerausgaben) -> nach ca. 50 Eingaben keine freien Inodes. *Gemessen* indirekt: mit 500 Inodes laufen alle 75 Eingaben durch.
  (Blockplatz nicht als Ursache nachgewiesen, die Dateien sind klein.)
* Behebung: `gast_befehle(..., tmp_inodes=200)` (neuer Parameter), `asgegen lauf` ruft mit 500. `lauf` loescht ausserdem `userspace/as/work/gegen` vor dem Lauf (alte `.n`).
* Der Pipeline-/Lauf-Aufruf im Worktree braucht `K1520EMU=/home/olliy/projects/a5120emu` (Standard `../a5120emu` gibt es dort nicht) und eine Kopie von `userspace/as/work` (nicht eingecheckt).

## 2. Pass-0-Laenge: Abgleich mit dem Original (`as_code.c`, `encode`)

Original 1C0C..1E24: nach `g9046 += 2` springt Schalter 2 (Tabelle 69B4, Index `cls - 11`, 108 Eintraege) in fuenf Gruppen (*gemessen*, aus `as.lst`):

* 1D8E (Klassen 11 12 22 23 51 97 98): Operand `g90b0[g90c4]` -> Woerter nach Typ (1/2: +2, 16: +2 bzw. +4 bei `g9278`), danach 51/97 noch +2 (+2).
* 1D7E (13 14 81): wie 1D8E, bei Typ 64 vorher `g90b0[1]`. 1DE8 (21): `g90b0[1]`, dann 1D8E. 1DFC (61) / 1E04 (62 101 102 105 106 109 115 116): +2 und 1D8E. 1DF4 (41-44, 63-67, 71 72 103 104 107 108 118): nur +2. Rest: nichts.
* W7q hatte nur Klasse 11 ergaenzt und fuer Klasse 21 einen **erfundenen** zweiten Durchlauf ueber `g90b0[0]` (Variable `n`) eingefuehrt; die Klassen 12 22 23 51 97 98 fehlten ganz
  (u. a. `ld _errno,r4` ist ein Speicher-LD mit dem Ziel im ersten Operanden = Klasse 22). Jetzt: `case 11 12 22 23 51 97 98: goto len1`, der Zusatzdurchlauf entfaellt, Klasse 119 (nicht in der 108er-Tabelle) entfaellt aus der 1E04-Gruppe.
* Wirkung: die Textlaengen von `l_cerror l_fork l_mcount l_sbrk l_setjmp l_signal c_echo c_cat` stimmen (Messung C).

## 3. Lokale Marken `$n`: Wort +4 statt +6 (`as_lex.c`)

* Befund (Messung C): alle Vorwaertssprünge auf `$n` (`jr $1`, `jr eq,$1`) hatten falsche Weite (`l_dup`: `E8FD` statt `E801`; `l_time`, `l_wait`, `l_fork`, ...); alle Module mit nur *definierten* `$n` (`ldexp frexp fltpr`) waren gleich.
* Ursache (am Original belegt): der Lexer prueft nach `symget(30)` (Original 0EC4..0ED4) das Wort **+4** (`s_x`) der gefundenen Zelle auf -1 (dann: Zelle verwerfen, neue anlegen); unsere Quelle pruefte `s_w` (+6), das in Pass 0 fuer *jede* Zelle -1 ist.
  Folge: jedes `$1` legte in Pass 0 eine neue Zelle an, Verweis und Definition waren verschiedene Symbole. Behebung: `sp->s_x == -1`.
* *Annahme*: `s_x` ist fuer neue Zellen nicht -1 (`symadd` setzt nur `s_w`); die Messung bestaetigt es (Vorwaertssprünge stimmen).

## 4. Messungen (75 Eingaben: 3 Compiler-Ausgaben, 4 `d_e*`, 3 `d_t*`, 65 libc, `--libc 80`; jeweils vollstaendiger Gastlauf ca. 575 s)

| Stand | bytegleiche `.o` | Bemerkung |
|---|---|---|
| W7q (Ausgangslage) | 44 | die letzten 9 Eingaben ohne `.o` (Inodes) |
| C: Pass-0-Weiche nach Original, 500 Inodes | 58 | alle 75 Eingaben laufen; Rest: Vorwaertsmarken, `crt0 execle mcrt0` (Operandenfehler), `doprnt` (`ILLEGAL VALUE`) |
| D: zusaetzlich `s_x` | **66** | Rest: `crt0 execle mcrt0 doprnt` (`illegal number or type of operands`, Zeilen 31/31/35/245) und 5 Eingaben ohne `.o` auf beiden Seiten (`d_e0..e3`, `d_t3`: Fehlfaelle mit gleicher Meldung) |

* `ILLEGAL VALUE` (`c_cc`, `doprnt`) tritt nicht mehr auf (Folge der richtigen Sprungweiten); `doprnt` meldet jetzt `illegal number or type of operands` (Zeile 245, vorher 197..240+) wie die drei anderen, **nicht untersucht**.
* Bilanz des Neubaus (`alles as`, Befehle des eigenen Codes): W7q 4189 -> 4145 gleich (von 5891; das Original-Muster weicht an anderen Stellen ab, *Annahme*: c2-Modell des Baus), Bloecke 732 -> 721; `neu_c2.bin` 35364 B.
  Dass die Zahl sinkt, obwohl die Funktion dem Original-Verhalten folgt, ist ein Zeichen, dass der Bau der Quelle (`cc -O` der Gegenseite) an dieser Stelle anders uebersetzt; Byte-Identitaet von `as` ist noch nicht erreicht.
* `pipeline --check as` OK (text 22092, data 13706). `pytest -m "not gast"`: 212 bestanden, 1 Fehlschlag (`test_bau_alle_kennt_genau_die_fertigen_disketten`, `disks/gebaut` fehlt im Worktree; wie W7q).

## 5. Offen

1. `illegal number or type of operands` bei `crt0` (Zeile 31), `execle` (31), `mcrt0` (35), `doprnt` (245): Zeilen ansehen (`opmatch`/Klassentabelle).
2. `d_t3` (`X _v W` ist keine gueltige Deklaration) durch einen gueltigen Test ersetzen.
3. Die Anzahl gleicher Befehle des Baus fiel von 4189 auf 4145: die geaenderten Stellen im Maschinencode (`encode` Pass 0, `yylex`) gegen das Original ansehen.
