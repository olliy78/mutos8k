# Inventar fest eingetragener Adressen (Plan 47 P2.1)

Stand 2026-11-16, Quellen `kernel/plus/*.s` (P1.3), `kernel/conf/conf.c`, `kernel/c`, `kernel/h`.  Kein Gastlauf; Messwerte sind aus dem
gesicherten `lk` von P1.3 (`/tmp/mplus/p1_3/lk`, sha256 `9e0681c3...`, text 34 652, Daten ab 0x875C) abgelesen.
Klassen: **F** fest, bleibt (ab D256, u/FC00, EC00..FFFF, Ports, PSA/Vektoren, 0x23C); **V** Verweis noetig (zeigt auf Text/Daten/BSS, die im
Gastbau wandern); **K** keine Adresse (Konstante, Maske, Groesse, Offset).  Kopfkommentare mit Adressen sind keine Funde.
Zusatzklasse **F-low**: Adresse im Text von `low` (0000..0674).  `low.o` steht im Makefile zuerst und `low.s` aendert seine Groesse nicht, die Lage ist also
fest (abgeleitet); Aenderung nur noetig, wenn `low.s` Code hinzubekommt oder verliert.

## Ergebnis

* **Drei V-Funde, alle gemessen falsch im heutigen Bau** (Tabelle 1).  Alle anderen Funde sind F, F-low oder K.
* Im Bau aus `kernel/plus` liegen die Daten von `conf.o` bei **0x8C4C** (Original 887C): `rootdev` 8C4C, `cf_x88a` 8C5A, `cf_nlist` 8C5C, `cf_proctop` 8C94;
  `max_proc` bei 8D9E, `proc` bei A11E (Original A11C, Text +2).  Das Wort bei 0x23C ist 0x888A (`low.s:147`), `cf_proctop` ist 0x8A8C:
  `ps`/`pstat` lesen damit Unsinn (abgeleitet aus `getnl()`/`pstat.c:103`; Gastlauf steht aus, P2.3).
* `max_proc` wird in `dn1.s` mit **0xA154** vorbelegt; mit `proc` bei A11E waere `&proc[2]` = **A156**.  Wer `dn1.s` in P2.2 "Werte genau uebernehmen" nach `daten.c` kopiert,
  uebernimmt den Fehler: der Wert muss `&proc[2]` sein, kein Zahlenwert.

## 1. V-Funde

| Stelle | Wert | Klasse | Bedeutung | Aenderung (Schritt) |
|--------|------|--------|-----------|---------------------|
| `kernel/plus/low.s:147` | `WV %888A` | V | Wort bei 0x23C: Adresse von `cf_x88a` (`conf.c`); `ps`/`pstat` lesen dort ein Wort `w` und ab `w+2` die 29 Worte (`ps.c:137-141`, `pstat.c:103-107`) | `WV _cf_x88a`; `G`/`X`-Deklaration `_cf_x88a L` wie die Externen am Modulanfang (P2.3 Punkt 1) |
| `kernel/conf/conf.c:84` | `(struct proc *)0x8A8C` | V | `cf_proctop` = Adresse der Variablen `max_proc` (`ps` liest `nl[28]` als Adresse und dort den Zeiger, `ps.c:143`) | `(struct proc *)&max_proc` (`proc.h:48` deklariert `max_proc`; Name `_max_pro` stimmt mit `dn1.s`); P2.3 Punkt 2 |
| `kernel/plus/dn1.s` (Zeile `_max_pro:`, `BV %A1;BV %54`) | 0xA154 | V | Anfangswert von `max_proc` = `&proc[2]` (`proc.h:47`; `sizeof(struct proc)` = 0x1C, 2 Eintraege = 0x38) | Assembler: `WV %38+_proc` (Form `WV %n+marke` ist belegt, `as_dialekt.md:63`; Annahme: `ld` verschiebt den Anteil auf externe Symbole richtig -- sonst in C `struct proc *max_proc = &proc[2];` in `slp.c`); P2.2 (`daten.c`: `struct proc *max_proc = &proc[2];`, `proc` ist in `proc.h` als Feld deklariert) |

Die dritte Zeile ist ein Fund gegenueber dem Plan: P2.2 spricht von "Anfangswert aus `dn1.s`", der Zahlenwert ist aber genau der Wert fuer proc bei A11C.

## 2. Muster 1: `rg -n '%[0-9A-F]{4}' kernel/plus/*.s`

Befehl: `rg -n '%[0-9A-Fa-f]{3,4}' kernel/plus/*.s` (270 Zeilen in `low.s`, 8 in `bss.s`, die `BV`-Datenbytes der `dn*.s`).  Zeilen gleicher Art sind gruppiert.

| Datei:Zeile | Wert | Klasse | Bedeutung | Aenderung |
|-------------|------|--------|-----------|-----------|
| `low.s:74-146` (PSA-Tabelle, ~73 Zeilen) | `%C000`, `%4004`.. `%4018`, `%4000`, `%0060`, `%000F`, `%0040`..`%0043`, `%0050`, `%007B` | K | Programmstatuswort/Bezeichner je Vektor (FCW, Identifikator); die Sprungziele sind Namen (`start`, `_trapent`, `L023E`..`L0276`, alle in `low.s` definiert) | keine |
| `low.s:147` | `%888A` | **V** | siehe Tabelle 1 | siehe Tabelle 1 |
| `low.s:173,175` | `ld r0,#%0000` -> `psapseg`/`psapoff` | K | PSA liegt bei 0 | keine |
| `low.s:177-178` | `r12,r13 = 0` | K | Stack: Segment 0, Basis 0 (`rr14 = rr12`) | keine |
| `low.s:180` | `#%4000` | K | FCW | keine |
| `low.s:182` | `#%8800` | K | Refresh-Register | keine |
| `low.s:184` | `ld r1,#%0036` | F | Adresse des PSA-Eintrags (Vektortabelle) | keine |
| `low.s:185` | `ld r0,#%03F2` | F-low | Adresse von `L03F2` (`ldps L875A; iret`), als Handler in 0x36 eingetragen | keine; optional `#L03F2` (Name statt Zahl, bytegleich) |
| `low.s:195` | `ld r2,#%EC00` | F | Anfang des Loeschbereichs EC00..FFFF (Benutzerbereiche, u) | keine |
| `low.s:201` | `cp r2,#%0000` | F | Ende (Wrap bei 10000) des Loeschens EC00..FFFF | keine |
| `low.s:203` | `ld r2,#_usegm` | -- (Name) | **Beginn des BSS-Loeschens ist ein Name** (erste BSS-Variable, `bss.s`); Plan 47 P2.3 Punkt 4 ist erfuellt | keine |
| `low.s:207` | `cp r2,#%D586` | F | Ende des BSS-/Absolutbereichs (D266..D586, Postfach, Puffer); bleibt | keine |
| `low.s:209,211,292,302,304,386,397,571,573` u. a. | `ld r0,#%00C7`, `out %0080,r0` | K / F | `%00C7` Wert des Latches; `%0080` Hardware-Port | keine |
| `low.s:210,264,291,299,382,387,393,398,568` | `L8DC2` | -- (Name) | Marke: zweite BSS-Variable in `bss.s` (`G L8DC2 A[%2 B]`), im Original 8DC2 -- das Latch-Abbild.  Ist in der Extraktion ein **Name** (verschiebt sich mit der BSS) | keine |
| `low.s:214,234,235,357,460,488` | `%D576`, `%D578` | F | Zellen von `low` (Trap-/Fehlerbehandlung: `D578` Fehlerhandler fuer `copyin/copyout/addupc`, `D576/D578` gesicherter Zustand, Deutung Annahme); liegen **nicht** in `abs.o` (`_fdu` D566..D576, `_mapq` D57C), also zwischen D576 und D57C unbenannt (abgeleitet) | keine (Bereich ab D256) |
| `low.s:228,312,315,317` | `%D57A` | F | wie oben (`test %D57A`, FPU-Merker; 317 ist ein toter Rohbefehl) | keine |
| `low.s:219,226,242..298` u. a. (Offsets `%0004(r5)`, `%0006(r15)`, `%0014(r15)`, `%001A(r15)`..) | | K | Stack-/Struct-Offsets, Masken `%000F`, `%01FC`, `%4000`, `%0008`, `%00C0`, `%0010`, `%0200` | keine |
| `low.s:217,220,213,253` | `#%0000`, `#%C000` | K | Null, FCW | keine |
| `low.s:342,414,442,477` | `ld r1,#%0462`, `#%0548` (414, 442), `#%0594` (477) | F-low | Adressen der Fehlerhandler in `low` (Befehl nach der Zugriffsstelle in `addupc`, `copyin`, `copyout`; Zuordnung abgeleitet); `ex r1,%D578` | keine; optional Marken vergeben (`low.s` aendert sich nicht) |
| `low.s:317,323,378,458,486` | `WV %4D04;WV %D57A;WV %E800`, `WV %2102;WV %FFFF;WV %9E08`, `WV %BD13..`, `WV %7D3A;WV %2102;WV %FFFF` | F / K | Rohwoerter (nicht disassemblierte, tote Befehle hinter Spruengen); nur 317 enthaelt eine Adresse (D57A, F) | keine |
| `low.s:536` | `ldm r8,%FFF4(r5),#6` | K | Offset -12 (`cret`) | keine |
| `low.s:552,560` | `add r6/r8,#%EC00` | F | Benutzerbereich EC00 (`resume`: Segmentnummer `<< 2` + EC00) | keine |
| `low.s:553` | `ld r7,#%FC00` | F | Adresse von `u` (FC00, `abs.o`) | keine (oder `#_u`, bytegleich) |
| `low.s:554` | `ld r0,#%0200` | K | Groesse der `u`-Kopie in Worten | keine |
| `low.s:498,511` | `#%0080`, `#%007F` | K | Wortzahlen (`copyseg`, `clearseg`) | keine |
| `low.s:579` (`L875A`) | `WV %C000;WV %03F6` | K / F-low | PSW: FCW C000, PC 03F6 (Befehl `iret` in `low`, F-low); Marke `L875A` ist ein Name | keine |
| `low.s:581` (`L875E`) | `%0000;%1000;%0000;%0000` | K | Anfangswerte des `low`-Datenblocks (Namen `L875E`) | keine |
| `bss.s:37-39,49,62-64,74` | `%1E0`, `%E74`, `%190`, `%310`, `%BB8`, `%61E`, `%162A`, `%310` | K | Groessen von `buf`, `inode`, `file`, `proc`-Rest (`LA138`), `buffers` usw. (Format `G name A[%n B]`); alle Variablen sind Namen | keine (Abweichung #2: `_cfree` 784 B) |
| `bss.s` (Rest) | `%2`, `%4`, `%A`, ... | K | Groessen | keine |
| `dn0.s` | `BV %00..%07` | K | `regloc[8]` (Registerindex-Tabelle, keine Adressen) | keine |
| `dn2.s` | `BV %21;%00;%00;%10;%21;%01;%00;%0C;%7F;%0B;%E8;%FF;%00;%10;%00;%00` + `"/etc/init"`; `szicode` `%001A` | K | `icode`: Benutzerprogramm (`ld r0,#10; ld r1,#0C; sc #11; jr -1`, argv); die Adressen 0x10/0x0C sind **relativ zum Benutzersegment** (Programm laeuft ab 0), keine Kerneladressen; `szicode` = 26 | keine |
| `dn3.s` | `_cf_8c94: BV %00;BV %04`, `_nlp: BV %00;BV %01`, `WV _conlog` | K / Name | `cf_8c94` = 4 (Zahl der Terminals), `nlp` = 1 (Zahl der Drucker); `conptr` zeigt per **Name** in den Konsolenring | keine |
| `shim.s` | `jp _savu`, `jp _ttyinit` | -- (Namen) | keine Zahlen | keine |

## 3. Muster 2: `rg -n '0x[0-9A-Fa-f]{3,4}' kernel/c kernel/conf kernel/h` (ohne Kommentare, 53 Treffer in Code)

Befehl: Kommentare herausgefiltert (`/* ... */` durch Leerzeichen ersetzt), dann das Muster auf `kernel/c/*.c`, `kernel/conf/*.c`, `kernel/h/*.h`.

| Datei:Zeile | Wert | Klasse | Bedeutung | Aenderung |
|-------------|------|--------|-----------|-----------|
| `kernel/conf/conf.c:84` | `0x8A8C` | **V** | `cf_proctop` | Tabelle 1 |
| `kernel/conf/conf.c:71-73` | `0x0402` | K | Geraetenummern `rootdev`, `swapdev`, `pipedev` | keine |
| `kernel/c/rk.c:47` | `0xD532` | F | Postfach `rkmbx` (Vertrag mit `mutos_io`) | keine |
| `kernel/c/slp.c:364`, `text.c:54` | `0xEC00` | F | Basis der Benutzerbereiche | keine |
| `kernel/c/slp.c:575,592` | `0xECFF` | F | dito (Endadresse) | keine |
| `kernel/c/machdep.c:47` | `0xFCFF` | F | `startup()`: oberes Ende der Speicherpruefung, Segment FC (`u`) | keine |
| `kernel/c/slp.c:365`, `text.c:67`, `bio.c:547,556`, `slp.c`/`text.c` `0x104`, `0x100`, `0x400` | | K | Groessen (Benutzerbereich 0x104 Worte, 1 KB-Schritte) | keine |
| `kernel/c/sys1.c:227,235` | `0xE807`, `0xE707` | K | a.out-Kennungen | keine |
| `kernel/c/sys1.c` (`0x100`) | | K | Merkerbit | keine |
| `kernel/c/trap.c:94,100-104,112,176`, `clock.c:99`, `trap.c:60` | `0xF009`, `0x7C04..06`, `0x0800`, `0xF600`, `0x4000` | K | Opcode/FCW-Masken, Trapkennungen | keine |
| `kernel/c/sig.c:245-254,354,399-412` | `0x400`, `0xFF00`, `0x4800`, `0x1000`, `0x800` | K | Groessen, Masken | keine |
| `kernel/c/dev0.c:67,70,398,411,445` | `0x400`, `0x7FFF`, `0x6D01`, `0x6D02` | K | Merker, ioctl-Kommandos | keine |
| `kernel/c/machdep.c:51-52`, `tty.c:56` | `0x400`, `0x7F00`, `0x518` | K | Segmentgrenze, Maske, Flags | keine |
| `kernel/h/user.h:103` | `0x3FC - 0x15C` | K | Fuellfeldgroesse in `struct user` | keine |

Gegenprobe: `rg '\*\)\s*\(?(0[xX]...|[0-9]{4,})'` auf `kernel/c kernel/conf kernel/h` findet nur die Zeilen oben (`MBX`, `up`, `cf_proctop`); kein Zeiger wird aus einer Dezimalzahl gebildet.
`rg 'D5[0-9A-F]{2}|E000|0xFC00'` ausserhalb von Kommentaren findet nur `rk.c:47`.

## 4. Muster 3: Marken `L[0-9A-F]{4}` ohne Definition im selben Modul

Befehl: Skript ueber `kernel/plus/*.s` (Definition = `name:` oder `G name A[...]`).  Ergebnis: alle Marken `L0000..L059A`, `L875A`, `L875E` sind in `low.s` definiert;
einzige fremde Marke ist `L8DC2` (`low.s`, aus `bss.s`): **Name**, kein Zahlenwert, verschiebbar.  `dn*.s`, `shim.s` benutzen nur `_name`; Marken in `bss.s` (`LA120` ...) sind
dort definierte Namen.  Keine V-Funde.

## 5. Absolute Symbole in `kernel/plus/abs.o` (alle F)

`python3 -I tools/kernel/objformat.py nm kernel/plus/abs.o`: `_cfreeli` D266, `_ttyhw` D26A, `_ttyobuf` D2A2, `_lpt` D3E2, `_lpbuf` D416, `_lpmbx` D516,
`_fdbuf` D540, `_fdmbx` D558, `_fdu` D566, `_mapq` D57C, `_mapbusy` D584, `_u` FC00.  Alle ab D256 bzw. in FC00: Klasse F (Vertrag mit `mutos_io`, Postfachbereich).
Die BSS (8DC2..D25A) muss unter `_cfreeli` (D266) enden (`basis.grenze_pruefen`, `gastbau.md` §1.1).

## 6. Die 29 Worte bei `*(0x23C)+2` (`ps`, `pstat`)

`ps.c:137-142` und `pstat.c:103-108`: `w` = Wort bei 0x23C, danach 29 Worte ab `w+2` nach `nl[0..28].n_value`.  Quelle im Kernel: `conf.c:77-84`
(`cf_x88a` bei `w`, `cf_nlist[22]`, `cf_x8b8[6]`, `cf_proctop`; diese vier Objekte liegen unmittelbar hintereinander in `conf.o`, gemessen: 8C5A, 8C5C, 8C5C+44, +56).
Alle `cf_nlist`-Eintraege sind **Namen** (vom Linker aufgeloest), die Spalte *Wert* ist aus dem `lk` von P1.3 gelesen (gemessen; Original in Klammern).

| Index | `ps`/`pstat`-Name | Bedeutung | Kernelsymbol | Wert (Orig.) | Benutzt von | stimmt im verschobenen Kernel |
|-------|-------------------|-----------|--------------|--------------|-------------|-------------------------------|
| 0 | `_proc` | Prozesstabelle | `proc` | A11E (A11C) | ps, pstat | ja (Name) |
| 1 | `_file` | Dateitabelle | `file` | 9EF0 | pstat `-f` | ja (Name) |
| 2 | `_kl11` | Terminaltabelle | `ttyt` | A532 | pstat `-t` | ja (Name) |
| 3 | `_nkl11` | Zahl der Terminals (Wert 4) | `cf_8c94` (`dn3.s`) | 8DBC | pstat `-t` | ja (Name); `dn3.s` Wert 4 |
| 4 | `_ipc` | ptrace-Struktur | `cf_a620` = `ipc` (`-D`) | A622 | -- (nur wchan-Namen in `ps`) | ja (Name) |
| 5 | `_buf` | Pufferkoepfe | `buf` | 8E9C | -- | ja |
| 6 | `_buffers` | Pufferdaten | `cf_a628` = `buffers` (`-D`) | A62A | -- | ja |
| 7 | `_bfreeli` | Freiliste | `&bfreelist` (`_bfreeli`) | A51A | -- | ja |
| 8, 9 | `_swbuf1`, `_swbuf2` | Swappuffer | `swbuf1`, `swbuf2` | CE2A, CE42 | -- | ja |
| 10, 11 | `_runin`, `_runout` | Scheduler-Merker | `runin`, `runout` | 8DD8, 8DDA | -- | ja |
| 12 | `_u` | Benutzerbereich | `&u` | FC00 | -- | ja (F) |
| 13, 14 | `_lbolt`, `_time` | Zeit | `lbolt`, `time` | 8DCC, 8DCE | -- | ja |
| 15 | `_callout` | Callout-Tabelle | `callout` | CE5A | -- | ja |
| 16 | `_rrkbuf` | Roh-Puffer rk | `rrkbuf` | CE96 | -- | ja |
| 17 | `_text` | Texttabelle | `cf_a464` (`_cf_a464`) | A466 | pstat `-x` | ja (Name) |
| 18 | `_inode` | Inodetabelle | `inode` | 907C | pstat `-i` | ja |
| 19 | `_swapdev` | Adresse von `swapdev` | `&swapdev` (`conf.c`) | 8C4E (887E) | **ps** (liest den Wert) | ja (Name); haengt an der Lage von `conf.o`-Daten, nicht an Zahlen |
| 20 | `_swplo` | Adresse von `swplo` | `&swplo` | 8C54 (8884) | **ps** | ja (Name) |
| 21 | `_rtmbuf` | Puffer fd | `cf_ceac` = `rfdbuf` (`-D`) | CEAE | -- | ja (Name) |
| 22-27 | (leer) | `cf_x8b8[6]` | Nullen | 0 | ps (wchan-Suche ueberspringt 0) | ja (K) |
| 28 | `_max_pro` | **Adresse** von `max_proc` | `cf_proctop` | **8A8C (Zahl)**; richtig 8D9E | **ps** (`getnl`: Zeiger lesen, `nproc = max_proc - &proc[0] + 1`) | **nein** -> V (Tabelle 1) |

Folgerung: ausser dem Wort bei 0x23C (`low.s:147`) und `cf_proctop` zeigt jeder Eintrag richtig, weil `cf_nlist` nur Namen enthaelt.  Zusaetzlich muss `max_proc` selbst
richtig vorbelegt sein (`&proc[2]`, Tabelle 1 Zeile 3), sonst zeigt `nproc` in `ps` daneben.  Voraussetzung (Annahme, vom Linker fuer ein Modul in Deklarationsreihenfolge): `cf_x88a`,
`cf_nlist`, `cf_x8b8`, `cf_proctop` bleiben in `conf.c` in dieser Reihenfolge und ohne Zwischenobjekte; gemessen im `lk` von P1.3 (Abstand 2, 44, 12).
Der Kommentar `conf.c:77ff` und `userspace/ps` bleiben unveraendert.

## 7. Aufgaben fuer P2.2/P2.3

1. P2.3: Tabelle 1 Zeilen 1 und 2.
2. P2.2: `max_proc` als `struct proc *max_proc = &proc[2];` (nicht den Wert 0xA154 kopieren); `cf_8c94` = 4, `nlp` = 1, `conptr` = `conlog` als Namen.
3. Optional (P2.3): `#%03F2`, `#%0462`, `#%0548`, `#%0594`, `L875A`-PC `%03F6` durch Marken ersetzen; nur sinnvoll, wenn `low.s` weiter bearbeitet wird.
