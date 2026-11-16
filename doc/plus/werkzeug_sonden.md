# Sonden der Werkzeugkette (Plan 47 P1.2)

Messdatum 2026-11-16, Skript `versuche/plus_sonden/sonde_p1_2.py`, Arbeitsordner `/tmp/mplus/p1_2/` (Lauf 1: alle Sonden, `lauf1.log`;
Lauf 2 `k2/`, `lauf2.log`: Wiederholung der Verbraucher nach Syntaxkorrektur).  Alles *gemessen* am Gast-`as`/`ld`, sofern nicht anders vermerkt.
Wanduhr: Lauf 1 7555 s, Lauf 2 3379 s (as/ld im Emulator brauchen je Aufruf ein bis zwei Minuten).

Allgemein: `as -u -o x.o x.s` schreibt das Objekt; `ld -o l x.o ...` ohne `-s` behaelt die Symbole.  Externvereinbarungen (`X name W`) muessen
**vor** `G name PR` stehen, sonst `syntax error` (Lauf 1, alle Verbraucher).

## 1. Absolute globale Symbole

**Antwort: ja.**  Mit `$ABS %FC00` vor (a1) oder `G`-Marke gefolgt von `$ABS` (a2):
```
$ABS %FC00
G
_u	L
_u:
```
ergibt Objekt `text 0 data 0 bss 0`, Symbol `_u` Typ `A` (abs, extern = 0x21), Wert FC00.  Gemessen: a1, a2; a5 (zwei Symbole `_mbox` D532 und `_u` FC00 hintereinander
mit `$ABS` vor jedem) liefert beide als abs+extern.
Nicht brauchbar: `G _u := %FC00` (a3, syntax error); `$ABS` + `G _u A[%400 B]` (a4: Objekt 1040 B, Kopf text 0 data 0 bss 0, Symbol ohne Namen/Typ 0 -- unbrauchbar);
`constant`-Konstante + Marke ohne `$ABS` (a6: Marke `D`, Daten, nicht absolut).
Falle: `$REL $+%40` hinter `$ABS %D532` (a5) bewegt den Daten-/Textzaehler um den absoluten Wert: Objekt mit 109 324 B (data 54 642).  Also **kein `$REL $+n` nach `$ABS`**;
benachbarte Symbole einfach mit je eigenem `$ABS` setzen.
Binden (Lauf 2): Verbraucher `ua1` (`X _u W`, `ld r2,#_u`, `ld r3,_u`) + `a1` -> `ld` ohne Fehler, Symbol `_u` bleibt `A` FC00 im Ergebnis, Text `ua1` unveraendert 10 B.
(Der Einsatz der Adresse im Befehl wurde nicht Byte fuer Byte geprueft: *nicht gemessen*, aber `ld` meldete keinen Fehler und ordnete `_u` als abs ein.)
**Empfehlung:** `abs.o` als **Quelle** (`abs.s`, je Symbol `$ABS %xxxx` / `G` / `_name L` / `_name:`), kein eingechecktes Objekt noetig.  Namen auf 8 Zeichen.
Bytegleichheit zu `abs.o` des natuerlichen Baus (`nat_abs`: Typ 0x21, kein Text) ist per `objformat.py dump` pruefbar (Symbolreihenfolge und -werte), in P1.3 zu belegen.

## 2. Echte BSS aus dem Assembler

**Antwort: ja, `$SECTION BSS_B`.**  Gemessen (Lauf 1/2):
* b1 `$SECTION BSS_B` / `G _g A[%10 B]` / `$SDEFAULT` -> `text 0 data 0 bss 16`, Symbol `_g` Typ `B` (bss+extern = 0x24), Wert 0, dazu Abschnittsmarke `BSS_B` (`s`, 0x1E).
* b3 (Stil `cerror.s`: `$SECTION BSS_B` / `I` / `B1:` / `G` / `_g L` / `_g:` / `I` / `$REL $+%30` / `$SDEFAULT`) -> bss 48 (= 0x30): `_g` Typ `B` Wert 0, lokales `B1` Typ `b`.  Die Groesse kommt aus `$REL $+n`.
* b2 `X _g A[%20 B]` in `BSS_B` erzeugt **nur** ein undefiniertes Symbol (U, Wert 0x20 = common-Groesse), keine BSS im Objekt.
* b4 `G _g A[%40 B]` **ohne** Abschnitt (so schreibt `bss.s` heute) -> `data 64` (Nullen im Datenabschnitt), Symbol `D`.  Das ist der heutige Zustand (BSS als Nullen in `lk`).
Binden (Lauf 2): `ub1`+`b1` -> `lb1` mit `bss 16`, `_g` bei 0x0A = Textende (Text 10, Daten 0): BSS liegt **hinter** den Daten, Kopf `bss 16`.  `lmix` (Text 28 B + Daten 2 + BSS 48
aus `mix`, Verbraucher `mixuse` mit Text/Daten/BSS-Bezuegen): `_f` 0x12, `_dv` 0x1C (Daten), `_bv` 0x1E (= Text+Daten, BSS), Kopf text 28 data 2 bss 48 -- Bezuege aus anderem Modul aufgeloest, `ld` ohne Meldung.
Mit `ld -s` entsteht damit ein `lk` **ohne** BSS-Nullen (BSS nur als Kopfgroesse); der Reihenfolge der Variablen entspricht die Reihenfolge der Deklarationen.
**Empfehlung:** `bss.s` auf `$SECTION BSS_B` + `G _name A[%n B]` umstellen (Form b1; jede Variable einzeln, Reihenfolge unveraendert).  Dann liegt `lk` = Kopf + Text + Daten, und die BSS-Nullen entfallen.
Voraussetzung (*Annahme*, nicht gemessen): der Kernel-Start loescht die BSS selbst (`low.s:203-207`) -- so ist es abgeleitet; der Bootlader muss die BSS-Groesse nicht kennen.  Ob der Bootpfad (`mutos_io` lädt die Datei, keine Kopfauswertung) mit
`bss` im Kopf zurechtkommt, ist durch die `dd`-Kopfabtrennung (Frage 4) ohnehin gegenstandslos: der Kopf wird abgeschnitten.  Die BSS-Adresse folgt im Link hinter den Daten -- die Pruefung "BSS endet unter D256" bleibt am `lk`-Kopf (text+data+bss).

## 3. `_etext`/`_edata`/`_end`

**Antwort: mit `X name W`-Bezuegen nicht definiert -- `ld` behandelt sie als gewoehnliche Symbole (common).**  Probe `ldsym` (`X _etext W`, `X _edata W`, `X _end W`; `ld r2,#_end` usw.):
Das Objekt enthaelt die Symbole als `U` mit Wert 2 (Groesse des `W`).  `ld` (`lsym0`, nur `ldsym.o`) legt sie als **BSS-Common** an (`B`, bss 6, `_etext` 0x0E, `_edata` 0x10, `_end` 0x12, direkt hinter dem Text 0x0E) und meldet je Symbol `Multiply defined` (Ausgabe auf stderr; Ergebnisdatei wird trotzdem geschrieben).
Mit weiteren Modulen (`lsym1`) liegen sie ebenfalls hinter dem Text als Common-BSS (0x2C/0x2E/0x30), **nicht** am Ende von Text/Daten/BSS.  Also liefert `ld` fuer solche Bezuege keine Segmentgrenzen.
*Nicht gemessen:* ob `ld` die Namen definiert, wenn der Bezug Wert 0 hat (`X name PR`, V7-`ld` tut das nur dann).  Das Skript enthaelt dafuer die Variante (`P12_KURZ=2`), der Lauf wurde auf Anweisung des Koordinators abgebrochen.
Der Hinweis `Undefined: ... _end` in `doc/userspace/erg_e3b.md:72` passt dazu, ist hier nicht weiter untersucht.
**Empfehlung:** sich **nicht** auf `_end`/`_etext` verlassen.  Die Kernel-BSS-Grenze steht ohnehin im `lk`-Kopf (text+data+bss); Pruefungen am Host bzw. per `dd`/Kopf, und falls der Kernel eine Endmarke braucht, eine eigene letzte BSS-Variable (z. B. `_kend`) in `bss.s`.

## 4. `dd` und `cmp` von der cmd-Diskette

**Antwort: beide vorhanden** (`k1520disktool ls a5120_mutos8000_cmd_mfm.hfe`: `bin/dd` 7296 B, `bin/cmp`, dazu `bin/ps`, `bin/pstat`, `bin/echo`).  Holen:
`k1520disktool get <cmd.hfe> bin/dd --to <dir>` legt die Datei unter `<dir>/bin/dd` ab; auf die Quelldiskette `put` und `attr --mode 0755 --mtime 536457600` (`gast_befehle(..., ausfuehrbar=("dd","cmp"))`); im Gast dann `/mnt/dd`, `/mnt/cmp`.
Optionen laut `userspace/dd/dd.c`: `if= of= ibs= obs= bs= cbs= skip= seek= count= conv=` (ascii, ebcdic, ibm, lcase, ucase, swab, noerror, sync, ...).  Gemessen im Gast (Eingabe `x` = 1516 B, davon 16 B Kopf):

| Befehl | Ergebnis |
|---|---|
| `dd if=/mnt/x of=y ibs=16 skip=1 obs=512` | `93+1 records in`, `2+1 out`, y = **1500 B** (Kopf weg) |
| `dd if=y of=z bs=512 conv=sync` | `2+1 in`, `3+0 out`, z = **1536 B** (auf 512 aufgefuellt) |
| `dd if=/mnt/x ibs=16 skip=1 obs=512 \| dd of=z3 bs=512 conv=sync` | z3 = 1536 B, `cmp z z3` gleich |
| `dd if=/mnt/x of=y4 ibs=16 skip=1 conv=sync` (eine Stufe) | y4 = 1504 B (nur auf **ibs** aufgefuellt, nicht auf obs) |
| `dd if=/mnt/x of=y5 bs=16 skip=1 count=3` | y5 = 48 B |

`cmp` (Meldungen auf stdout, Exit 0 gleich, 1 verschieden/EOF, 2 nicht oeffnbar; `cmp a b && ... || ...` mit Marken-Dateien gemessen, da kein `echo` auf der Wurzel):
gleiche Dateien: keine Ausgabe, Erfolg; `x` gegen `x2` (letztes Byte anders): `/mnt/x /mnt/x2 differ: char 1516, line 7`, Misserfolg; fehlende Datei: `cmp: cannot open /mnt/nofile`, Misserfolg;
`y` gegen `z` (z laenger): `cmp: EOF on y`, Misserfolg (cmp meldet also auch bei Praefixgleichheit; fuer den Abgleich gegen `.nat` muessen die Laengen gleich sein).
**Empfehlung (Makefile-Ziel, Kopf weg und auf 512 B auffuellen):**
```
mutos_1216: lk
	/mnt/dd if=lk of=lk.body ibs=16 skip=1 obs=512
	/mnt/dd if=lk.body of=mutos_1216 bs=512 conv=sync
```
oder als eine Pipe `dd if=lk ibs=16 skip=1 obs=512 | dd of=mutos_1216 bs=512 conv=sync` (gemessen gleichwertig, z3 = z).  Eine einzelne `dd`-Stufe geht **nicht** (y4: Auffuellung nur auf `ibs`).
Die Binaerdateien `dd`/`cmp` muessen wie `ps` per DiskTool auf Diskette D gelegt werden (Ausfuehrbit + mtime 1987); sie sind nicht Teil der Wurzel.  `make` sucht `PATH=/bin:/usr/bin:.`, also `/mnt/dd` mit vollem Pfad.

## Zusammenfassung der Empfehlungen
* `abs.o`: aus **Quelle** (`abs.s` mit `$ABS`).
* BSS: **Abschnitt** (`$SECTION BSS_B`, `G name A[%n B]`), nicht Nullen.
* Kopf/Auffuellen: zwei `dd`-Aufrufe wie oben.
* `_end`: nicht verwenden (offen: Wert-0-Bezug).
