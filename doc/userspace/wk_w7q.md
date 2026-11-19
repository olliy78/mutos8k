# W7q: funktionale Gegenprobe des rekonstruierten `as`, zweiter Anlauf (zwei Behebungen, 44 von 75 Eingaben bytegleich)

Werkzeug: `tools/userspace/asgegen.py` (`lauf`, `auswerten`). Alles *gemessen*, ausser wo *Annahme* steht.

## 1. Auswertung korrigiert

`auswerten` zaehlte Eingaben, bei denen keiner der beiden Assembler ein `.o` erzeugte (oder nur eine leere Datei nach `fatal()`), als EQUAL.
Jetzt: Zeile `NO-OBJ (beide ohne .o)` mit Exitstatus und Meldungen beider getrennt; nicht in der Zaehlung der identischen. Die Abschlusszeile nennt beide Zahlen.

## 2. Messung A (Bau mit der Symboltabellen-Behebung aus W7p, 4192/5891 Befehle gleich, `neu_c2.bin` 35358 B)

70 Eingaben (3 Compiler-Ausgaben, 4 `d_e*`, 63 libc). **Keine einzige identisch** mit Ausnahme der Fehlerfaelle: der W7p-Fehler (`symbol table overflow`) ist behoben, jeder
Lauf erzeugt jetzt ein `.o`. Die 12 zuerst gepruefte Faelle (`l_abort`, `l_access`, `l_acct`, `l_close`, ...) unterschieden sich schon im Kopf.

## 3. Fehler 1: Objektkopf, Worte 5..7 (behoben)

* Befund: `l_close` (80 Byte) unterscheidet sich vom Original nur in den Kopfbytes 10..15: Original `0 0 0`, unser `as` `1 0 0xFFCB`.
* Ursache: `modend` schreibt 16 Byte ab `&gca70` (gca70..gca78 + `char gca7a[6]`). Die Quelle nahm die Nachbarschaft an; im Bau lag `gca80` (Wert 1,
  gesetzt in `passini`) direkt hinter `gca78`, `gca7a` dahinter (gleiche Klasse von Fehler wie `symtab`/`gc79e`: der Linker haelt die Deklarationsreihenfolge nicht ein).
* Behebung (`as.h`, `as_tab.c`): ein Feld `int objhdr[8]`, `gca70..gca78` sind Makros auf `objhdr[0..4]`.
* Nach dem Neubau: kein `.o` mehr mit abweichendem Kopf (Worte 5..7 sind 0).

## 4. Fehler 2: Laenge in Pass 0 (teilweise behoben)

* Befund: bei `l_cerror`, `l_cuexit`, `l_abort` steht im Kopf Text 12/12/16 statt 14/14/18; die letzte Anweisung wird von den Relokationsdaten ueberschrieben
  (Textgroesse bestimmt die Dateioffsets der anderen vier Dateikennungen). Der Text stimmt bis dahin.
* Ursache (eingegrenzt, nicht am Original-Code belegt): in der Pass-0-Laengenweiche von `encode` fehlte (a) die Klasse 11 (`CALL`, `CLR`: Operand mit direkter Adresse,
  `call csv` = 4 Byte) und (b) bei Klasse 21 (`LD`, `PUSH`, `XOR`) der erste Operand (Ziel `ld _v,r4`).
  Behebung: `case 11: goto len1;` und bei Klasse 21 zweiter Durchlauf von `len1` mit `g90b0[0]` (Zaehler `n`).
* Nach dem Neubau: Kleinstfaelle `d_t1` (`call csv; ret`) und `d_t2` (`ld r2,#%FFFF; ret`) bytegleich (52 Byte). Befehlsbilanz des Neubaus 4189/5891 (vorher 4192), Bloecke 732;
  die Aenderung weicht also vom Original-Maschinencode ab, *Annahme*: das Original zaehlt die Operanden an anderer Stelle (nicht untersucht).

## 5. Messung B (Neubau, 75 Eingaben: +3 `d_t*`, `--libc 80`)

* **44 von 75 bytegleich.** Darunter 41 libc-Module und `d_t1`, `d_t2`.
* Kein `.o` auf beiden Seiten: 14 (`d_e0..e3` mit gleicher Meldung und Zeilennummer; `d_t3` mein Testfehler: `X _v W` ist keine gueltige Deklaration; und die letzten 9 libc-Eingaben
  `l_stime ... l_write`: `I can not creat l_x.n` -- das Gastdateisystem ist nach ca. 50 Laeufen voll, *Annahme*: jeder Lauf hinterlaesst `.o`/`.n`/`.e` plus Temporaerdateien, die `as` bei Fehlern nicht loescht.
  Die Reihenfolge der Eingaben sollte kuenftig die Faelle mit dem meisten Nutzen vorn haben, oder `/mnt` muss zwischendurch aufgeraeumt werden).
* Abweichungen mit `.o` (alle noch Text zu kurz, ausser `l_dup`):
  `c_echo` (218/180), `c_cat` (494/424), `l_cerror` (14/12), `l_fork` (26/24), `l_mcount` (36/32), `l_sbrk` (60/56), `l_setjmp` (64/62), `l_signal` (142/136), `l_dup` (gleiche Groesse, 1 Byte Abstand am Offset 21).
* `l_dup`: `jr $1` auf eine **nachfolgende** lokale Marke `$1:` ergibt im Original `E801` (+1 Wort), bei uns `E8FD` (-3): die Sprungweite zu einer Vorwaertsmarke ist falsch (auch `l_fork` hat `jr $1`). Nicht behoben.
* `l_cerror`: `ld _errno,r4` mit **spaeter definiertem** `_errno` (andere Sektion) bleibt 2 Byte zu kurz: in Pass 0 ist der Typ des Symbols noch offen,
  die neue Operandenpruefung greift dort nicht. *Annahme*: `ty` ist fuer ein noch undefiniertes Symbol weder 1, 2 noch 16.
* Zusaetzlich Meldungen unseres `as` bei Eingaben, die das Original uebersetzt: `l_crt0`, `l_execle`, `l_mcrt0`: `illegal number or type of operands` (Zeile 31/31/35),
  `c_cc`, `l_doprnt`: `ILLEGAL VALUE` (mehrere Zeilen). Ursache nicht untersucht.

## 6. Offen (naechster Schritt)

1. Pass-0-Laenge fuer Operanden mit noch undefinierten Symbolen (`cerror`, vermutlich auch echo/cat/fork/mcount/sbrk/signal) -- `ty` einer Vorwaertsreferenz bestimmen.
2. Vorwaertssprung `jr $n` (`l_dup`).
3. `illegal number or type of operands` (crt0/execle/mcrt0: Zeile ansehen) und `ILLEGAL VALUE` (c_cc/doprnt).
4. `lauf`: `/mnt`-Platz fuer die letzten Eingaben (Zwischenaufraeumen); `WORK` vor dem Lauf leeren (alte `.n` aus frueheren Laeufen bleiben sonst liegen).
5. `pytest -m "not gast"`: `test_bau_alle_kennt_genau_die_fertigen_disketten` schlaegt im Worktree fehl (Vergleich mit dem Ordner `disks/gebaut`, der im Worktree fehlt; *Annahme*: nicht durch diese Aenderung verursacht).
