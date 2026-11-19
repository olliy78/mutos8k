# W7u: breitere Gegenprobe des rekonstruierten `as` (Kernel-`.s`, `sh`, `mkfs`), schlichter Bau gegen c2-Bau

Fortsetzung von `wk_w7t.md`. Werkzeug `tools/userspace/asgegen.py`. Alles *gemessen*, ausser wo *Annahme* steht.
Die Gastlaeufe gingen ueber das Budget von vier Laeufen (Lauf 2 lief in das Zeitlimit, siehe Abschnitt 4), deshalb ist die Menge nicht vollstaendig.

## 1. Werkzeug

* `asgegen.py lauf` neu: `--kern MOD...` (Kernel-Quellen `kernel/asm/ref/MOD.s`, Eingabe `k_MOD`), `--only MOD...` (nur diese Module der
  `--prog`-Programme uebersetzen), `--nodiag` (ohne `d_*`), `--asx2 FILE` (zweites `as` von uns in derselben Sitzung, `X.m`; `auswerten` meldet es
  als eigene Zeile `asx2 ...`). Neue Kleinstfaelle `d_k1..d_k7` (je eine Schluesselwort-Deklaration hinter Kopf wechselnder Laenge).
* Fehler im Werkzeug (gemessen): (a) Die Tastatur-/tty-Zeile des Gastes fasst weniger als ca. 240 Zeichen; mit drei `as`-Laeufen in einem Befehl
  (245 Zeichen) wurden `k_dev0 k_sys2 c_echo ...` gar nicht ausgefuehrt (keine `.e`, `.o`). `asbefehl` liefert jetzt je `as`-Lauf einen eigenen Befehl.
  (b) `echo st=$?` schrieb nie etwas (im Gast findet die Root-Shell kein `echo`; das V7-`sh` nimmt `st=...` ausserdem als Zuweisung). Der Status
  entfaellt; `auswerten` vergleicht Objekte und zeigt die Meldungen aus `X.e` (alle Laeufe hintereinander).
* Grenze: die `/tmp`-Diskette fasst ca. 250 KB. Ist sie voll (`no space on dev 4/0`), bleiben spaetere `.o/.n/.m/.e` leer; `auswerten` zeigt das als
  `NO-OBJ` oder `DIFF o=... n=None`. Das ist **kein** Unterschied des `as` (Abschnitt 2, `k_sys1`). Je Sitzung hoechstens ca. 100 KB Quelltext waehlen
  (die `.o` werden dreifach abgelegt, `k_bss.o` allein 36 KB).

## 2. Messung mit `neu_c2.bin` (35364 B, neu gebaut) und `neu.bin` (35354 B, neu gebaut)

Bauten: `alles as --c2emu --libc alt --ist neu_c2` lieferte beide Dateien. `neu.bin` und ein zusaetzlicher Bau `alles as --libc alt --variante neu_alt`
sind **byteidentisch**: `--libc alt` aendert am `as` nichts (der `as` braucht kein Bibliotheksmodul der alten Lib), der Unterschied schlicht/c2 ist also
allein das c2-Modell.

| Lauf | Assembler | Eingaben | Ergebnis |
|---|---|---|---|
| 1 | `neu_c2` | Kernel `alloc bio clock dev1 fio iget machdep main malloc nami pipe prf rdwri rk sig subr sys3 sys4 text trap tty` (21), `sh`: `xec cmd service` | **24 von 24 bytegleich** (Kernel 1016..6084 B, `c_xec` 8996, `c_cmd` 6940, `c_service` 7588) |
| 3 | `neu` (schlicht) und `neu_c2` | `c_echo`, `d_t1..d_t8`, `d_k1..d_k7`, Kernel `slp low bss` | beide Assembler **bytegleich** zum Original (`k_bss` 35948 B, `k_slp` 5792, `k_low` 4256; `d_e0..d_e3` ohne `.o`, Meldungen gleich) |
| 4 | `neu_c2` (und `neu` als `asx2`) | `sh`: `expand macro main name word`, `mkfs`, Kernel `dev0` | 7 von 7 bytegleich, beide Assembler (`c_mkfs` 12544 B, `k_dev0` 6512 B) |

Nicht entschieden (Lauf 4, `/tmp` voll, Abschnitt 1): `k_sys1` (Original erzeugte 6664 B), `k_sys2`, `k_mbx`, `k_daten`; in Lauf 3 liefen `dev0 sys2 daten` wegen der
zu langen Zeile nicht. Diese vier Kernelmodule sind **noch nicht** gegengeprueft. `ed` (25 KB) uebersetzt der Gast in einer Sitzung mit anderen Eingaben nicht innerhalb von 1500 s (Lauf 2, Zeitlimit),
`make` hat keinen Eintrag in `PROGRAMME` (`c2gegen.quellen`).

Zusammen: **bytegleich zum Original** sind mit `neu_c2` 24 Kernel-/`sh`-Eingaben (Lauf 1) + 7 (Lauf 4) + `c_echo`, `d_t*`, `d_k*`, `k_slp k_low k_bss` (Lauf 3); eine funktionale Abweichung
gegenueber dem Original wurde nicht gefunden, also auch nichts zu beheben.

## 3. `syntax error` in Zeile 8 beim schlichten Bau

* **Nicht reproduzierbar.** Der frisch gebaute schlichte `neu.bin` (35354 B, Quelle unveraendert gegen W7s) uebersetzt `c_echo`, `d_t1..d_t8`, `d_k1..d_k7`, `k_slp`, `k_low`, `k_bss`,
  `c_expand c_macro c_main c_name c_word c_mkfs k_dev0` bytegleich zum Original (Lauf 3 und 4), also genau die Eingabeklasse (`.s` ohne Kommentarzeile vorweg,
  `PR := procedure` in Zeile 8), die in W7s `syntax error` meldete. Die schlichte Variante hat damit keinen Fehler mehr, den die c2-Variante nicht auch hat.
* Gegenpruefung des Unterschieds schlicht/c2 (Host): `U.c2_emu_s` auf die `.s` des schlichten Baus (`work/bau/neu_s`): 8 Module, Aenderungen nur `R5` (Registerwahl, 17x), `R10`, `R32` (zusaetzliches
  `xorb rhN,rhN`, 5x, +10 Byte = 21620 gegen 21630 Byte Text), `R42` (1x). Jede abweichende Zeile im Zusammenhang gelesen (`as_lex.s` 64/342/703 `ld _yytchar`, `as_code.s` 1686, `as_dir.s` 513/567, `as_expr.s` 473/511, `as_y.s` 2284, `as_tab.s` 3087):
  in allen Faellen steht im anderen Register eine Kopie desselben Wertes, bzw. das ueberzaehlige `xorb` loescht ein Byteregister, das nur als Wort gelesen wird. Befehlsfolgen sind also gleichwertig.
* Untersucht und als Ursache **ausgeschlossen**: (1) Layout/Bibliothek (`neu_alt` = `neu`, s. o.); (2) die Hashtabelle `loc2[3202]` in `main` liegt auf dem Stack und wird nicht geloescht; das Original tut dasselbe
  (`SUB R15,#0D4A`, dann sofort `hashini`), und der Kernel loescht bei `exec` das ganze 256-Click-Segment (`kernel/c/sys1.c` Zeile 304), der Stack ist also null; (3) `gcc -O2 -Wmaybe-uninitialized` auf alle
  `as_*.c`: nur `fa/fb` (`iniput`) und `r9/r10` (`mkpair`), jeweils im Fehlerzweig direkt vor `fatal()`/Fehlermeldung.
* *Annahme*: Der W7s-Befund ging auf einen anderen Stand der damals gebauten `neu.bin` zurueck (die kopierten Arbeitsdateien waren dort mehrfach veraltet, vgl. `wk_w7s.md` Abschnitt 4.2); belegen laesst sich das nicht,
  die damalige Datei ist nicht mehr vorhanden. Es wurde **keine Quelle geaendert** (ohne Befund kein erfundener Eingriff).

## 4. Pruefungen

* `pipeline.py --check as`: OK (text 22092, data 13706). `pytest -m "not gast"`: 213 passed, 1 skipped (mit `K1520EMU`).
* Gastlaeufe: Lauf 1 407 s, Lauf 2 Zeitlimit 1500 s (`ed` + Kernel; kein Ergebnis, zugleich lief ein zweiter Bau), Lauf 3 1005 s, Lauf 4 778 s. Baeue: 2 (der zweite, `neu_alt`, war ueberfluessig, s. Abschnitt 2).

## 5. Offen

* `k_sys1 k_sys2 k_mbx k_daten` in einer eigenen Sitzung (mit `--nodiag`, nichts Weiteres) gegenpruefen; `ed` allein (Zeitlimit ca. 40 min ansetzen), `make` in `PROGRAMME` aufnehmen.
* Hat jemand den `syntax error` des schlichten Baus erneut, dann sofort die Binaerdatei sichern (`cp work/bau/neu.bin`), denn nur so laesst sich der Fall zerlegen.
