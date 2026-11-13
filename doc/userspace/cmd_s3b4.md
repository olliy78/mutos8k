# Auftrag S3b-4 (Plan 44): ps, pstat der Diskette `cmd` (`bin/`)

Stand 2026-11-13, Branch `us-cmd-s3b4`.  Alles *gemessen* (`K1520EMU=/home/olliy/projects/a5120emu`), soweit nicht als *Annahme* markiert.
Beide Programme: **G** (ganzdatei bytegleich).

| Programm | Datei | Abbild (text/data/bss) | Quelle | c2-Regeln (Stellen) |
|----------|-------|------------------------|--------|---------------------|
| `bin/ps` | 7846 B | 7830 (6722/1108/14732) | **kein V7-Text**; MUTOS-eigene Fassung im Aufbau der Hippe-`ps.c` (nur Vergleichsreferenz), s. u. | **R77 1**; alle R1-R64 aus (`C2_AUS`) |
| `bin/pstat` | 6866 B | 6850 (5500/1350/1062) | V7-`pstat.c` als Gerüst, aber an fast jeder Stelle abweichend, s. u. | **keine** (alle Zähler 0) |

Befehle je Programm (Bau und Beweis):

    python3 -I tools/userspace/pipeline.py holen NAME --platte cmd --pfad bin/NAME ; ... karte NAME --ablegen
    python3 -I tools/userspace/libc_alt.py members NAME && ... quelle NAME && ... bau NAME            # Gast, libc-Teil
    python3 -I tools/userspace/pipeline.py alles NAME --c2emu --libc alt --ist neu_c2_s               # "=> BYTE-IDENTICAL"
    cmp userspace/NAME/work/bau/neu_c2_s.bin userspace/NAME/work/NAME.orig                            # ohne Ausgabe

Der Eigencode von `ps` endet bei 0D74 (`printf`), der von `pstat` bei 0BB8; der Rest ist libc (`libc_alt`: `printf strout isatty stty close ioctl lseek open read sbrk write cerror csv cuexit`
aus dem init-Archiv bzw. der ausgelieferten `libc.a`; G-Glieder, aus dem Abbild gewonnen und ohne Herkunftsaussage: `flsbuf malloc` bei beiden, zusätzlich `qsort` bei `ps`).

## Gemeinsame Befunde

* **Keine PDP-11-Strukturen.**  `/usr/include` der Diskette hat kein `sys/proc.h`, `user.h`, `inode.h`, `tty.h`.  Beide Programme lesen den Kern über `/dev/kmem` bzw. `/dev/mem`
  und nutzen die **MUTOS-Z8001-Layouts**: `struct proc` 28 B (`p_stat` 0, `p_flag` 1, `p_pri` 2 ... `p_wchan` 14h, `p_textp` 16h, `p_link` 18h, `p_clktim` 1Ah), `struct user` 0x400 B
  (`u_uid` 16h, `u_ruid` 1Ah, `u_dsize` AAh, `u_utime` F4h, `u_ar0` 104h, `u_ttyp` 114h, `u_ttyd` 116h, `u_comm` 140h), `struct inode` 74 B (`i_size` +0E, `i_rdev` +14 als Langwort-Teil), `struct file` 8 B,
  `struct tty` 60 B (`t_state` +28, `t_delct` +2E).  Alle Abstände stimmen mit `kernel/h` (`doc/kernel/header_belegstand.md`) überein; die Listings zeigen sie an den Zugriffen
  (`LD R2,%0016(...)` usw.).  Die Quelle benutzt dafür die Datei `userspace/ps/mutosk.h` (Auszug aus `kernel/h`, mit `u_fparea` bis 0x400 aufgefüllt, weil beide Programme die ganze `u` lesen,
  `read(..., 0x400)` bzw. BSS `u` 1F6C..236C); sie steht in `PROGRAMME` bei beiden Programmen.  `sys/dir.h` aus `original/unix-v7/usr/include`, flach als `"dir.h"`.
* **Adresstabelle des Kerns statt `nlist()`.**  Beide haben dieselbe Tabelle `nl[29]` mit je 10 Byte (`char n_name[8]; unsigned n_value;`, **nicht** das 12-Byte-`struct nlist` aus `/usr/include/a.out.h`):
  `_proc _file _kl11 _nkl11 _ipc _buf _buffers _bfreeli _swbuf1 _swbuf2 _runin _runout _u _lbolt _time _callout _rrkbuf _text _inode _swapdev _swplo _rtmbuf`, danach sechs leere Einträge,
  Eintrag 28 `_max_pro` (Daten 1A44..1B66 bei `ps`).  Die Werte kommen nicht aus der Symboltabelle: `lseek(core, 0x23C, 0); read(core, &w, 2); lseek(core, w+2, 0); read(core, a, 58)` und
  `nl[i].n_value = a[i]` für `i = 0..28` (Listing `ps` 0210, `pstat` 0110-0186; `w` ist `unsigned`, der Aufruf schiebt `w+2` ohne Vorzeichenerweiterung).  Die Namen sind nur Ballast der Tabelle.
* `-I` kennt nur `/usr/include`; die Quellen haben deshalb `#include "dir.h"`, `"mutosk.h"` (mit `/* Differs from V7 */`-Kommentar).
* Die Nummern der Indizes (`nl[19]` = `_swapdev`, `nl[20]` = `_swplo`, `nl[18]` = `_inode` ...) sind am Code gemessen; die Namen der Tabelle bestätigen sie.

## ps: Abweichungen (Vergleich mit V7 `ps.c` und der Hippe-`ps.c`)

Das Original-`ps` ist **nicht** das V7-`ps.c` (andere Ausgabe: Spalten `tty owner pid status size cptime command`, Baumausgabe nach Sitzung).  Es entspricht im Aufbau der Hippe-`ps.c`
(`struct INFO info[NPROC]`, `icomp`, `qsort`, `output`, `out1`, `out2`, `gwchan`, `getnames`, `seq`, `puid`, `pstatus`, `getdev`; gleiche Zeichenketten `system scheduler `,
`proc[0%d] `, `%-8.8s`), weicht aber so ab (jeweils durch Bytes belegt; die Herkunft ist *Annahme*):

1. Keine Zwischenspeicher `/tmp/ss.*` und kein `nlist`; `getnl()` liest die Adresstabelle des Kerns wie oben, danach `max_proc` (`nl[28]`) und `nproc = max_proc - nl[0] + 1`.
2. Zwei Öffnungen: `core = open("/dev/kmem")`, `pcore = open("/dev/mem")` (Hippe: beide `/dev/mem`); `getnames()` liest `/etc/passwd` ohne Cache-Datei; `getdev()` ohne Cache-Datei und nur `console` ('C') und `ttyX`.
3. **`getusr()` ohne `getptr/getbyte/within/round/datmap`.**  Die Argumentzeile wird nur aus den letzten 512 Byte des Stapelsegments gelesen (V7/Hippe-Schleife nach `*--i == -1 || *i == 0`, Zeichen für Zeichen gleich).
   Die Lage dieser 512 Byte (`stkaddr`) und des `u`-Blocks (`addr`) wird Z8001-spezifisch berechnet: geladen (`p_flag & 05`, also `SLOAD|SLOCK`): `stkaddr = ((long)p_addr<<8) + 0xFE00`,
   `addr = 0xEC00 - (memorg>>6) + (p_addr<<2) + memorg` mit `memorg = (long)p_addr<<8` des Prozesses 0 (in `main` bei `j == 0` gesetzt); ausgelagert: `addr = ((long)p_addr + swplo)<<9`,
   `stkaddr = addr + 0x400`, dazu `((u_dsize+1)&~1)<<8` und `(0xFE - ((i[8]>>8)&~1)) << 8` mit `i = (int *)((char *)u.u_ar0 - 0xFC00 + (int)&u)` (Segmentnummer aus dem gerade gelesenen Trap-Rahmen).
   **Die Ausdrücke sind eine Rekonstruktion**: gemessen ist nur, dass dieser Text den Befehlsstrom erzeugt; die Bedeutung der Konstanten (Segment-/Klickmaß) ist *Annahme*.
4. Zeit: `ltime = u_utime + u_stime + 25; cptime = ltime/50` (HZ 50; V7: 30 und 60).  Größe: `p_size >> 2` (Klick 256 B; Hippe `>> 5`).  `SLOAD`-Test ist `p_flag & 05`.
5. `pstatus()`: `mess = pp->p_pri ? "slp" : "SLP"` (Test auf 0, nicht `> 0`); die Fallunterscheidung über `nlp - &nl[0]` hat die Fälle 0, 2, 4, 5, 6, 7, 8/9, 10, 11, 12, 13-15, 16/21, 17, 18
   (`proc kl11 trace I/O filsys freebuf swap runin runout pause clock raw I/O text inode`); `default`: `printf("%-8x ", pp->p_wchan)` (Hippe `%-8d`).  `gwchan` läuft bis `&nl[NSYMB]` mit `NSYMB = 28`.
6. `puid`, `out2`, `output`, `out1`, `icomp`, `seq`, `getnames` sonst wie Hippe (Registerzuordnung gemessen: `out2(ip, level) register struct INFO *ip; register int j`).
7. Daten: `nl` zuerst, dann `mem`, `passwd`, `devdir`, `cbfree`, `nbfree`, `nproc = NPROC (30)`; BSS `core pcore swap swplo memorg ndev devc[65] devl[65] mf u cmndbuf[4096] names[3050] namebuf[1024] totalusage totalsize info[NPROC] lastinfo max_proc`.

## pstat: Abweichungen (Vergleich mit V7 `pstat.c`)

Gerüst und Aufrufreihenfolge (`doinode dotext dotty doproc dousr dofil`, Schalter `-a -i -x -p -t -u -f` in V7-Reihenfolge der `case`) sind V7; alles andere ist MUTOS:

1. `fcore = "/dev/kmem"` (V7 `/dev/mem`), kein `fnlist`, kein `nlist`, keine Meldung `no namelist`; die Adresstabelle wird in `main` (inline, Hilfsvariable `unsigned nlbase`) gelesen (gemeinsame Befunde); Meldung `Can't find %s`.
2. `dotext()` ist **leer** (`RET`).
3. `-u`: Argument wird als **Hex** gelesen (`oatoi` mit `v <<= 4`, `unsigned`, Zeichen `0-9 A-F a-f`) und als Byteadresse benutzt (`lseek(fc, ubase, 0)`, V7: `ubase<<6`).
   **Fehler im Original, mitgebaut:** die Ziffernprüfung lautet `c >= '0' && c <= 9` (Listing 0A88-0A8E: `CP R11,#%0009`), Ziffern werden also nie umgesetzt, nur `A-F`/`a-f`.
4. Ausgabeformate durchweg hexadezimal und schmaler (`%4x`, `%5x`, `%X` für das Langwort `f_offset`); Kopfzeilen kürzer (`" LOC FLAGS  CNT DEVICE   INO   MODE NLK UID  SIZE/DEV"`, `" LOC S  F PY  SIG UI TI CP NI PGR  PI PPI ADD SIZ  WCH LINK TEXT CLKT"`, `" LOC FLG CNT INOD OFFS"`).
   `doinode`: `%6ld` mit `(long)ip->i_number`; `i_rdev` als `i_un.i_rdev`.  `doproc`: `p_uid&0377`, `p_time&0377`, `p_cpu&0377`, Zeilenende `" %5x"` für `p_clktim`.
5. `dotty()` ruft `ttylist(3, 2, "terminals")` auf (`nl[3]` = `_nkl11` = Zahl der Leitungen, `nl[2]` = `_kl11` = Tabelle bis `struct tty dh11[48]`), `ttyprt` mit den MUTOS-`tty`-Feldern
   (`t_rawq.c_cc`, `t_outq.c_cc`, `t_flags`, `t_addr`, `t_delct`, `t_col`, `t_state` mit `TIMEOUT WOPEN ISOPEN CARR_ON BUSY ASLEEP XCLUDE HUPCLS` = 1 2 4 10h 20h 40h 80h 200h, `t_pgrp`); `t_inq` heißt im Kern `t_rawq` (V7-Name beibehalten).
6. `dousr()`: erste Zeile `user structure at %lx`; `rsav`, `qsav`, `ssav` geben die Worte **0, 7, 8** aus (Listing: Abstände 0, 0Eh, 10h); keine `dseg`/`tseg`-Zeilen (keine `u_uisa`), kein `sep`;
   Zeiten `/50`; `u_intflg` = Byte bei 112h, `u_comm` bei 140h.
7. `dofil()`: V7-Rumpf, Ausgabe `%4x %c%c%c %4d %5x %X`.
8. `doinode()` belegt **2 Byte mehr** Rahmen (0xE76 = 50*74 + 2) als der V7-Text: eine unbenutzte `int`-Variable als erste Deklaration (`int pad`) bildet das nach.  *Annahme:* im Original war es eine nicht mehr benutzte Variable;
   andere Erklärungen (Ausrichtung) wurden nicht untersucht, sind aber an `dofil`/`doproc` (Rahmen genau `sizeof`) nicht zu sehen.

## c2-Regeln

Beide Programme sind mit der **ausgelieferten** c2-Form gebaut (wie `df`/`rm`): kein Zähler von R1-R64 greift (`neu: c2 model rewrote` alles 0 bei `pstat`; bei `ps` griffen R1-R5, R7, R30 (zusammen 28 Stellen) und verschlechterten das Ergebnis,
gemessen: mit dem Modell 1095 statt 1102 Befehle gleich, 9 statt 0 Differenzblöcke im Eigencode) und sind deshalb in `C2_AUS` abgeschaltet (`ps`, `pstat`: R1-R69).

* **R77 (neu, 1 Stelle, nur `ps`):** `ldb rl2,@r13 ; xorb rh2,rh2 ; cp r2,#%1 ; jp ne,L` -> `jr ne,L` (`pstatus`: `if (pp->p_stat == SSLEEP)`, Spanne 0xA8 Byte).  Das Original hat die kurze Form, der ausgelieferte
  c2 behält `jp` (2 Byte mehr, alle folgenden Adressen verschoben).  Wie R60-R64 eine **schwache Modellregel** (eine Stelle).  Quelltextvarianten wurden dafür nicht durchprobiert; die Spanne ist gleich lang, ein Quelltextgrund ist unwahrscheinlich.
* Host-Prüfung: `c2_emu_s` auf allen `neu.s` der Hauptkopie (32 Programme plus die `*/*.s` von `sh`) ergibt R77 = 0; die Regel verändert kein anderes Programm.
* Zählerliste in `tests/test_userspace_pipeline.py` um `R77` ergänzt.

## libc-Teil

* `doprnt` ist beide Male die 474-Byte-Fassung; Sprungtabelleneinstiege 2 Byte später als automatisch (`ps.members.zusatz`: `code=0FC2,0FC8,0FDE`; `pstat.members.zusatz`: `code=0D12,0D18,0D2E`), wie bei `df`/`rm`.
* **`ps` hat eigenes BSS** (`static lasttty` in `out2`, 2 Byte bei 57FA) zwischen `_environ` (57F8) und dem libc-BSS.  `members_auto` nimmt `_environ` unmittelbar vor dem libc-BSS an und setzte die Commons `__sibuf/__sobuf` 2 Byte zu spät (53FA statt 53F8);
  der erzeugte Operand `#%1FE+__sibuf` ergab 55F6 statt 55F8 (ein einziges abweichendes Byte, 0x123F).  Behelf: `libc_alt.py` lässt in `*.members.zusatz` jetzt ganze `common`/`extern`-Zeilen ersetzen
  (`ps.members.zusatz`: `common __sibuf 53F8 200 data`, `common __sobuf 55F8 200 data`, `extern _environ 57F8 2`; Beleg: `crt0` `LD %57F8,R7`).  Werkzeugänderung ist wirkungslos, wo keine solche Zeile steht.

## Verlauf (Fehlerbilder)

* Erster `ps`-Lauf: 27 Differenzblöcke, 78 Byte zu lang: `out2` hatte `ip` nicht als `register`-Parameter (Original `LD R13,%0004(R14)`).  Danach Eigencode gleich lang, 11 Blöcke (nur libc-Adressen, `qsort`/`flsbuf`-Namen und R77).
* Mit dem c2-Modell (alle Regeln an) war `ps` schlechter als ohne (u. a. `LD R3,R5` -> `LD R3,R4` bei 03E2, `LD R11,R3` -> `LD R11,R2` viermal in `getnames`); daher `C2_AUS`.
* `pstat`: erster Lauf 70 Blöcke durch **ein** fehlendes Leerzeichen in der Kopfzeile von `doproc` (alle folgenden Datenadressen um 1 verschoben); `nlbase` zunächst `int` (Listing: `PUSH R2 ; PUSH #0`, also `unsigned`).
  Die Zeichenketten beider Quellen wurden danach maschinell gegen die Datenbereiche des Originals verglichen (Reihenfolge und Inhalt gleich).

## Regressionslauf

Alle 33 bisherigen Programme wurden nach den Werkzeugänderungen (R77, `common`-Zeilen in `libc_alt.py`, `C2_AUS` für `ps`/`pstat`) im Gast neu gebaut, 3 parallel, 2026-11-13 gemessen
(`alles NAME --c2emu --libc alt --ist neu_c2_s`; `sync`, `getty` ohne `--libc alt` (haben kein eigenes Archiv): `alles NAME --c2emu`; `sh`: `bau sh --c2emu --variante v7fix`; je danach `BYTE-IDENTICAL` im Log bzw. `cmp` gegen `work/NAME.orig`):
**33 von 33 bytegleich**: sync, getty, cat, date, ls, stty, init, login, mount, umount, echo, pwd, rmdir, mkdir, wc, size, chmod, kill, cp, ln, clri, mknod, dcheck, ncheck, icheck, mkfs, sh, df, rm, mv, od, who, cmp.
(Erster Versuch: `sync`/`getty` meldeten `no libc_alt archive` wegen falscher Aufrufform des Regressionsskripts, nicht wegen der Änderungen.)
Dazu `pytest tests/test_userspace_pipeline.py -q`: 8 passed, 1 skipped; `pipeline.py --check ps|pstat` Exit 0.

## Aussagekraft

Wie README Punkt 1, 2 und 5: *C-Quelle + ausgelieferter Compiler (+ R77) = Originalbytes*.  Der Text beider Programme ist **eine** Quelle, die diese Bytes erzeugt, keine Rekonstruktion des Originaltexts:
Namen der Hilfsvariablen und -funktionen (`ttylist`, `memorg`, `stkaddr`, `nlbase`, `pad`), die Gestalt der Adressausdrücke in `ps getusr` und die Kommentare sind erfunden.  Bei `ps` sind die Z8001-Adressformeln (Konstanten 0xFE00, 0xEC00, 0xFC00, 0xFE)
nur als Befehlsfolge belegt.  Der libc-Teil ist aus dem Abbild bzw. der ausgelieferten `libc.a` gewonnen und belegt keine Herkunft.
