# Fremdherkunft des MUTOS-Kernels (AP H6): Hippe-Sammlung (TUHS) als naechster bekannter Verwandter

Stand 2026-10-31.  Plan: `doc/plan/42_unix_herkunft.md` (H6).  Kurzfassung: `uebersicht.md` Abschnitt 13.
Alle Zahlen **gemessen**, sofern nicht als *vermutet* oder *angenommen* gekennzeichnet.  Stufen: **sicher** (mehrere unabhaengige Merkmale, Gegenprobe negativ),
**wahrscheinlich**, **vermutet**, **ungeklaert**.  Es wurde nichts in `kernel/` oder `original/` veraendert; alle Quellen liegen nur im Scratchpad (Abschnitt 2).

> **Zuordnung (Stand 2026-10-31, Recherche des Projektinhabers):** "Hippe" bezeichnet in diesem Dokument nur die **Sammlung** `Distributions/Research/Torsten_Hippe_v7` im TUHS-Archiv, nicht den
> Urheber der Inhalte.  Torsten Hippe hat die Sammlung im Maerz 1995 als Student aus nicht naeher bekannten Quellen zusammengestellt und dem TUHS uebergeben; er ist weder Autor des Kernels noch
> kommt er als Urheber von MUTOS in Frage.  Dokumentiert wird die **grosse Uebereinstimmung** des Codes dieser Sammlung mit dem MUTOS-Code (Messungen in den Abschnitten 1, 5 und 8).  Wer die
> Aenderungen gegenueber Bell-V7 urspruenglich geschrieben hat, ist unbekannt (Linie nach den Funden: UNSW -> Vrije/Nijmegen -> unbekannt; `m.h` nennt Johan Stevenson, Vrije, fuer `XBUF`).
> Wo unten "Hippe-Kernel", "Hippe-Zuege" o. ae. steht, ist stets "Kernel/Zuege der Hippe-Sammlung" gemeint.

## 1. Ergebnis in Kuerze

* **Die "Fremdzuege" und die "System-III-Zuege" des MUTOS-Kerns stimmen zusammen mit einer Quelle ueberein: der V7-Variante `Distributions/Research/Torsten_Hippe_v7/v7.tar.gz`
  (Kernel `usr/sys`, Standardkonfiguration von `usr/sys/conf/m.h`).**  Es ist ein V7 mit Zusatzoptionen (`PROC_MAX`, `EXIT`, `LRUI`, `XBUF`, ...), ein 11/40-Kernel mit kleinen Tabellen.
  Sie erklaert: malloc-Kartenlimit samt `panic("map overflow")`, `seek` `off < 0`, `sumount`-Busytest, `stime`/`i_lastr`, `iget`/`iput`-LRU, `breada`, `exit`-Schleife, `exece`-`B_AGE`,
  `proctop`, `s_tfree`/`s_tinode` in `alloc.c`, `smount`-`out1`, die gesamte Systemaufruftabelle (64 von 64 Zeilen gleich, V7: 58 von 64), die Parameter (NPROC 30, NINODE 50, NFILE 50,
  NMOUNT 5, MAXUPRC 15, HZ 50, TIMEZONE 0, DSTFLAG 0, MAPSIZ = NPROC/2 = 15) -- und **`tty2.c`**.
* **`tty2.c` (bisher "Ursprung unbekannt") ist die Zeilendisziplin `usr/sys/dev/tty.c` dieser Variante** (sicher): die drei Tabellen `maptab`/`cchars`/`wchars` sind Byte fuer Byte gleich
  (128 + 16 + 16 Byte), Kontrollfluss und Funktionen entsprechen eins zu eins, die `struct tty` stimmt bis +34 im Layout.  Die Funktionsnamen im MUTOS-Quelltext (`ttyrub`, `ttycol`, `bitset`, ...) sind
  bei der Rueckuebersetzung frei vergeben worden; die Originalnamen sind `ttywipe`, `ttyretype`, `ttybit`, ... (Abschnitt 5).
* **Nicht erklaert** (keine Quelle in 15 Baeumen): die 30-s-`update()`-Anforderung in `clock`/`sched`, die Kopierrichtung in `setregs` (`u_exname` -> `u_dbuf`).  Beides vermutlich MUTOS-eigen.
* `ptrace`-Argumentreihenfolge `req, pid, addr, data` ist die Konvention aller Nicht-PDP-11-Systeme im Satz (32V, System III VAX, WEGA/Z8001) und von 2.10BSD an; kein Fremdzug, sondern Portierung.
* Rechtlich: die Hippe-Variante steht **nicht** unter einer klaren Lizenz (Abschnitt 7); empfohlen wird, sie nicht unter `original/` abzulegen, bevor das geklaert ist.

> **Vorbehalt:** Uebereinstimmung heisst Verwandtschaft, nicht Abstammung.  "Vorlage" in diesem Dokument meint den naechsten bekannten Verwandten; ob MUTOS direkt von Hippe
> abstammt oder von einer gemeinsamen unbekannten Vorlage, prueft die Gegenprobe in **Abschnitt 8** (Stand 2026-10-31): MUTOS ist inhaltlich der Hippe-Kernel (direkte Ableitung *wahrscheinlich*), eine gemeinsame unbekannte Vorlage
> ist *vermutet*, nicht widerlegbar; Dateidaten sind schwache Belege.

## 2. Quellen (Scratchpad, nichts davon im Repo)

Wurzel: `/tmp/claude-1000/-home-olliy-projects-mutos8k/9fec9724-1e2d-4a7c-841d-7f8cfc3a3344/scratchpad/`.  Heruntergeladene Archive in `h6_dl/` (Namen: Pfad ab `Distributions/` mit `_` statt `/`);
Pruefsummen in `h6_sha256.txt`.  Basis-URL: `https://www.tuhs.org/Archive/Distributions/`.

| Kuerzel | Verzeichnis | Pfad ab Basis-URL | SHA-256 |
|---------|-------------|-------------------|---------|
| hippe | `h6_hippe` | `Research/Torsten_Hippe_v7/v7.tar.gz` | `b960f8de80331f106e459ec046ceb4383edbdaa3db044eab557a3ce4a4db4a5e` |
| nij | `h6_nijmegen` | `Research/Nijmegen_v7/nijmegen_v7kernsrc.tar.gz` | `acb2089eeb5fa2b61311d601673a0970e10fdc365d1144812f4b9e877b0cbc69` |
| v7patches | `h6_v7patches` | `Research/Henry_Spencer_v7/v7.patches.tar.gz` | `241c86b9eda61ce6e15210427cd6a1074bf259fa2f30c09093ae7e61b8c277e6` |
| v7addenda | `h6_v7addenda` | `Research/v7addenda.tar.gz` | `a0db95eca400340566bfcf535a5e3437113e30cb0366182f9e11cf6d3b4735ae` |
| bostic | `h6_bostic_raw` (Dump, nur Textsuche) | `Research/Keith_Bostic_v7/v7.tap.gz` | `f30d62d6539c9bb185d1a6dd64e3b7d15bc210be27840b77eeb25c0b58097cea` |
| b28 | `h6_2.8bsd` | `UCB/2BSD/2.8bsd.tar.gz` | `b274e33f190c2aea81a8a690e32958e3c1d3afc474d730449fed7b612590dc13` |
| b29 | `h6_2.9bsd_usr` (`src/sys`) | `UCB/2BSD/2.9BSD/usr.tar.gz` | `f2b0ad29bd71991dc682f3ce6dc507e4cf3c3327d8e8315a438fa6235ef7b2ef` |
| b29root | `h6_2.9bsd_root` (keine Quellen) | `UCB/2BSD/2.9BSD/root.tar.gz` | `b3ee7908be3dbfd8a49f8319dbb3abaf599c063a3c768b5c282044f81b7183b8` |
| b210 | `h6_2.10bsd` | `UCB/2BSD/2.10bsd.tar.gz` | `abe77f9a9648a16e7beeabd8ff4db9c0206a3f4e8137b975152a3f479d033ba8` |
| b211 | `h6_2.11_f7` (`sys`), `h6_2.11_f6`, `h6_2.11_f8` | `UCB/2BSD/2.11BSD/file{6,7,8}.tar.gz` | f6 `7c10c0de...f814`, f7 `da70b5e238386d85fcb99e0aac77c5b84a7bd6401013b590511c1ad04e05be34`, f8 `7d5e87af91d95627f776401787fe1eaddaf0e85cdd4f4c1c21fb4d4e1859fdd7` |
| b211pl | `h6_2.11pl195_sys` (aus `sys.tar.gz`) | `UCB/2BSD/2.11BSD-pl195.tar` | `f95bee3dc2618c21ebf9b79557c63a0fbcd4b945807f3d90849916d542c6cfd9` |
| 2bsd, 2.79 | `h6_2bsd`, `h6_2.79bsd` (nur Anwendungen) | `UCB/2BSD/2bsd.tar.gz`, `2.79bsd.tar.gz`, `spencer_2bsd.tar.gz` | `143c70e4...`, `2220cf89...`, `e4e67910...` |
| b3 | `h6_3bsd` | `UCB/3BSD/3bsd.tar.gz` | `7bdb2ce517148766c40d1823c1425367910ebc3b28b2664318e5c5792b7bd369` |
| b41 | `h6_4.1bsd` (aus `tape1.tap` per `tap2files.py` + `tar`) | `UCB/4BSD/4.1BSD-19810901-reconstructed/tape1.tap.xz` | `0c840a3be8f6d18d11077a3c15365b7c962f7c9d82ec898e8c21bf9c4802bbbc` |
| v32 | `h6_32v` | `USDL/32V/32v_usr.tar.gz` | `be0652099273ff9c41cb1fb7d649a6ad7849cee44703a38afda9b0e48eba424c` |
| pwb | `h6_pwb_spencer` | `USDL/spencer_pwb.tar.gz` | `11ac194c123b8aad7ee237d896aa96d693796f9355ab37414301d0ca48920a0a` |
| idata | `h6_interdata` (V6) | `Other/Interdata/interdata_v6.tar.gz` | `3c47fb35d9da5ed7c5b47b37adfa671a097849f318d258a0459e8c71a52f7a7d` |
| wega | `h6_wega/P8000` | `git clone https://github.com/OlliL/P8000`, Commit `626fc77fb083b31392ccafb0d125bbc2c8127d4a` (2026-10-30), `WEGA/src/uts` | -- |
| v7, s3 | `original/unix-v7`, `original/sys3` | bereits im Repo | siehe deren README |

Weitere heruntergeladen, aber ohne Kernelquellen oder ohne Bezug: `Other/Xenix/sco-xenix86-2.1.3.zip` (`2f89dce6fa8c97b54fe0d75f6012af61c4c94bbb22fd2395202f4f03510d5828`: PC-Emulator mit Plattenabbild, keine Quellen),
`USDL/32V/file1.gz`, `file2.tar.gz`, `USDL/bostic_pwb.tar.gz` (`a048beed...a0a`; gleiche Linie wie `spencer_pwb`, nicht ausgewertet).  **Nicht geladen (Stand H6):** UNSW-Baender, CB_Unix, Ultrix-11, Coherent (i386-Kernel),
2.9BSD-Zweige `2.9-derivatives`.  Die Aussage "in allen Baeumen kein Treffer" gilt nur fuer die Tabelle oben.  **Nachgeladen in H6b:** UNSW, V7M, Ultrix-11, Bostic-Band als Baum (Abschnitt 8.2).

Hilfsskripte (jetzt in `tools/herkunft/`, Abschnitt 8.9): `ifdef_resolve.py` (loest `#ifdef` fuer eine feste Makromenge auf),
`mapnames.py` (benennt Hippe-`tty.c` in das MUTOS-Vokabular um), `tables.py` (vergleicht die drei Tabellen), `tap2files.py` (SIMH-`.tap` in Dateien), `ftable.py` (Funktionstabelle aus dem JSON).

## 3. Vorgehen

1. Alle Baeume in `h6_*` entpackt (jeweils eigenes Verzeichnis; Skripte ausserhalb; `python3 -I`).
2. Dateivergleich `tty2.c` gegen alle Baeume (`herkunft.py compare`), danach Funktions- und Stringsuche (`rg`) nach den Fremdzuegen in allen Baeumen (Abschnitt 4, Tabelle der Merkmale).
3. Befund Hippe: der Kernel dieser Variante ist mit Praeprozessor-Schaltern gebaut.  Die Standardkonfiguration steht in `usr/sys/conf/m.h`: eingeschaltet sind nur `PROC_MAX`, `EXIT`, `LRUI`
   (und `_1140`, `TUDUMP`); `SYSACCT`, `SYSPHYS`, `SYSLOCK`, `DISKMON`, `INSTRM`, `MX`, `SGTTY`, `SEPID`, `UNIBMAP`, `XBUF` sind auskommentiert.  Mit dieser Menge wurde ein "wirksamer Baum"
   `h6_hippe_eff` erzeugt (`ifdef_resolve.py ... PROC_MAX EXIT LRUI _1140 TUDUMP DELTAB`; `DELTAB` ist in `tty.c` selbst definiert) und neben die Rohfassung gestellt.  Der Vergleich nur gegen
   die Rohfassung unterschaetzt die Naehe (z. B. `alloc.c` 91 % roh, 100 % wirksam).

## 4. Befund je Fremdzug

Spalte "V7 / Hippe": Funktionsaehnlichkeit (Stufe `abs`, gleichnamige Funktion) MUTOS-Funktion gegen V7 bzw. Hippe-wirksam; Rohdaten `h6_out/rep_all.json`, Auszug mit
`python3 -I h6_tools/ftable.py h6_out/rep_all.json malloc,mfree,...`.  Die Aehnlichkeit ist nur Begleitwert; **Beleg ist das Vorhandensein des Merkmals** (Spalte "Beleg") bei gleichzeitigem Fehlen
in V7, System III und den anderen Baeumen (Abschnitt 4.2).

### 4.1 Tabelle

| # | Fremdzug (MUTOS) | Befund | Beleg in Hippe (`usr/sys/...`) | V7 / Hippe | Anmerkung |
|---|------------------|--------|--------------------------------|-----------|-----------|
| 1 | `malloc.c`: Karte hoechstens 15 Eintraege, `panic("map overflow\n")` | **sicher** Hippe | `sys/malloc.c:21` (`(bp-mp) < MAPSIZ`), `:71-72` (`> MAPSIZ` -> `panic("map overflow")`); `h/param.h:14` `MAPSIZ (NPROC/2)`, `NPROC 30` -> 15 | malloc 95/82, mfree 94/94 | Textform in MUTOS anders (`break` im Rumpf statt Schleifenbedingung), Grenze und Text gleich; das `\n` ist MUTOS (Text 8AE4).  Folge: `CMAPSIZ`/`SMAPSIZ 50 (guessed)` in `kernel/h/param.h` sind falsch; die Karten haben `MAPSIZ+1 = 16` Eintraege (Hippe `conf/c.c:73-74`, MUTOS coremap A09C / swapmap A0DC: je 64 Byte) |
| 2 | `sys2.c` `seek`: `off < 0` -> `EINVAL`, `off = 0` | **sicher** Hippe | `sys/sys2.c:202-205` genau dieser Text | 85/100 | System III: gleiche Pruefung, aber `return` ohne `off = 0` |
| 3 | `sys3.c` `sumount`: Busytest `i_count`, sonst `i_number = 0` | **sicher** Hippe (`LRUI`) | `sys/sys3.c:243-252` (`#ifdef LRUI`) | 91/97 | auch in Nijmegen |
| 4 | `sys4.c` `stime`: `i_lastr` aller Inodes loeschen | **sicher** Hippe (`LRUI`) | `sys/sys4.c:63-72` (`ip->i_lrt = 0`); `h/inode.h:48` `#define i_lrt i_un.i_lastr` | 34/78 | `i_lrt` ist in Hippe ein Alias fuer `i_un.i_lastr`; MUTOS nennt das Feld `i_lastr` (eigenes Feld +46) |
| 5 | `iget`/`iput`: Freigabealter `i_lastr` (LRU) | **sicher** Hippe (`LRUI`) | `sys/iget.c:62-65` (`i_count++ == 0` -> `i_lastr = 0`), `:70-76` (kleinstes `i_lrt`), `:160` (`i_lrt = time`) | iget 91/93, iput 90/92 | auch in Nijmegen |
| 6 | `bio.c` `breada`: Vorauslesen nur bei freiem Puffer | **sicher** Hippe | `dev/bio.c:101-102` (`&& (bfreelist.av_forw != &bfreelist)`) | 96/90 | nur Hippe; frueher als "Idee aus System III" gedeutet, das war falsch |
| 7 | `sys1.c` `exit`: eine Schleife, Zombiezaehler, ein `wakeup(&proc[1])` | **sicher** Hippe (`EXIT`) | `sys/sys1.c:384-413` (`#ifndef EXIT` ... `#else`, `if(i) wakeup(&proc[1])`) | 80/92 | auch in Nijmegen |
| 8 | `sys1.c` `exece`: Argumentbloecke bei Fehler mit `B_AGE` verwerfen | **sicher** Hippe | `sys/sys1.c:153-160` (`getblk(swapdev,swplo+bno+nc)`, `B_AGE`, `&= ~B_DELWRI`); ebenso Zugriffstest zuerst (`:41`) und `getxfile(ip,nc,ns)` | 65/68 | **Korrektur H6b (8.5):** `B_AGE`/`bdwrite` auch Nijmegen, UNSW 92, System III, Ultrix-11; nur `getxfile(.., ns)` ist Hippe-eigen; erklaert auch die "MUTOS:"-Marke zum Zugriffstest in `exece` |
| 9 | `proctop` (`signal`, `stop`, `ptrace`, `sched`, `newproc`, `clock`, `fork`/`wait`) | **sicher** Hippe (`PROC_MAX`) | `h/proc.h:71-72` (`MAX_PROC` = `max_proc`), `sys/slp.c:13`, `sys/sys1.c:449-451` (`wait` senkt), `:511-512` (`newproc` hebt) | -- | auch in Nijmegen; MUTOS `proctop` = Hippe `max_proc` |
| 10 | `alloc.c`: `s_tfree`/`s_tinode` mitfuehren | **sicher**, dass Hippe es hat; Urspruenglicher Erfinder offen | `sys/alloc.c:71-72, 78, 127, 190-191, 241, 259` | alloc 97/100, ialloc 96/100, ifree 89/100 | auch System III, 2.8BSD, 2.9BSD, 4.1BSD, PWB, WEGA; V7 und Nijmegen nicht (Gegenprobe Tabelle 4.2) |
| 11 | `sys3.c` `smount`: nach Fehler von `d_open` Sprung nach `out1` | **sicher** Hippe | `sys/sys3.c:183, 187` | smount 97/100 | frueher "System III textgleich"; Hippe hat dieselbe Form |
| 12 | `sysent.c`: stty, gtty, sysacct, sysphys, syslock, mpxchan = `nosys` | **sicher** Hippe | `herkunft.py sysent`: Hippe-wirksam 64/64 Zeilen (Funktion und Argumentzahl) gleich, V7 58/64 | -- | die Schalter `SGTTY`, `SYSACCT`, `SYSPHYS`, `SYSLOCK`, `MX` sind in `m.h` aus |
| 13 | Parameter `param.h`: NPROC 30, NINODE 50, NFILE 50, NMOUNT 5, MAXUPRC 15, HZ 50, TIMEZONE 0, DSTFLAG 0 | **sicher** Hippe | `h/param.h:6-21`; V7: 150/200/175/8/25/HZ 60/TIMEZONE 5*60/DSTFLAG 1 | -- | abweichend von Hippe (gemessen am Kernel): NBUF 20 (Hippe 12), NCALL 9 (Hippe 10) |
| 14 | `tty2.c` (Zeilendisziplin) | **sicher** Hippe, siehe Abschnitt 5 | `dev/tty.c` | Datei 43 %, mit Namensabbildung 55 % | auch Nijmegen aehnlich (41 %), aber `maptab` weicht ab |
| 15 | `bio.c` `iodone` ohne `B_MAP`, kein `io_info` (`DISKMON`) | **sicher** Hippe | `dev/bio.c` (`UNIBMAP` und `DISKMON` aus; Hippe entfernt `#define DISKMON 1`) | iodone 84/100 | frueher als "System-III-Zug" gedeutet |
| 16 | `clock.c`: alle 30 s `sflag1`++ und `runout` wecken; `sched` ruft `update()` | **ungeklaert**, vermutet MUTOS-eigen | kein Treffer in 15 Baeumen (`rg -w sflag1`, `update()` in `sched`/`clock`) | -- | `cf_x88a` ist in `conf.c` 0: die Funktion ist abgeschaltet.  Zweck vermutet: Ersatz fuer den Daemon `/etc/update` |
| 17 | `sys1.c` `setregs`: Name von `u_exname` nach `u_dbuf` | **ungeklaert**, vermutet MUTOS-eigen | `u_exname` kommt in keinem Baum vor.  Schwache Parallele: 2.9BSD `sys1.c:223, 576` legt den Interpreternamen in `u_dbuf` ab, bevor `setregs` `u_dbuf` -> `u_comm` kopiert | 61/64 | nicht als Herkunft zu werten |
| 18 | `sig.c` `ptrace`: Reihenfolge `req, pid, addr, data` | **sicher**: Konvention der Nicht-PDP-11-Systeme | gleiche Reihenfolge in `sys3/uts/vax/os/sig.c`, 32V `sys/sig.c`, WEGA `sys/sig.c:338-343`, 2.10BSD `sys_process.c`; PDP-11 (V7, System III, Hippe, 2.8/2.9BSD) `data, pid, addr, req` | 94/96 | Grund: PDP-11-Stapelreihenfolge der Argumente; Z8001 uebergibt in Quellreihenfolge |
| 19 | `lp.c` (H5-Frage) | **ungeklaert**, MUTOS-eigen | alle Dateien <= 23 % (System III 23 %, V7-Addenda/Hippe/Nijmegen 21 %, 2.8BSD 20 %, 2.9BSD 15 %, WEGA 10 %) | -- | Kandidaten 2.9BSD/3BSD aus H5 erledigt: negativ |

### 4.2 Gegenprobe: Merkmale in allen Baeumen (Anzahl Dateien mit Treffer)

Befehl (gekuerzt; Muster je Zeile siehe Skript im Scratchpad, `h6_out/traits.txt`):
`rg -U -l --glob '*.[ch]' -e '<Muster>' <Baum>`.

```
trait                              v7 s3 hippe nij b28 b29 b210 b211 b3 b41 v32 pwb idata wega
T01 malloc MAPSIZ-Grenze+panic      0  0   1    0   0   0   0    0    0  0   0   0   0    0
T02 seek off<0 -> EINVAL, off=0     0  0   1    0   0   0   0    0    0  0   0   0   0    0
T03 sumount i_count-Test            0  0   1    1   0   0   0    0    0  0   0   0   0    0
T04 stime i_lrt = 0                 0  0   1    1   0   0   0    0    0  0   0   0   0    0
T05 breada freelist-Test            0  0   1    0   0   0   0    0    0  0   0   0   0    0
T06 exit eine Schleife              0  0   1    1   0   0   0    0    0  0   0   0   0    0
T07 exece B_AGE-Fehlerschleife      0  0   1    0   0   0   0    0    0  0   0   0   0    0
T08 MAX_PROC                        0  0   6    6   0   0   0    0    0  0   0   0   0    0
T09 iget i_lastr = 0 bei count 0    0  0   1    1   0   0   0    0    0  0   0   0   0    0
T10 alloc s_tfree--                 0  2   1    0   1   1   0    0    0  1   0   1   0    1
T11 smount d_open-Fehler -> out1    0  0   1    1   0   0   0    0    0  0   0   0   0    0
T12 tty: cchars+wchars              0  0   1    1   0   0   0    0    0  0   0   0   0    0
T13 ptrace req,pid,...              0  1   0    0   0   0   1    1    1  1   1   0   0    1
T14 sflag1 (clock/sched)            0  0   0    0   0   0   0    0    0  0   0   0   0    0
T15 u_exname (setregs)              0  0   0    0   0   0   0    0    0  0   0   0   0    0
```

(`T13`: s3 = nur `uts/vax`, b211 = `2.11pl195 sys_process.c`; V7-Bostic-Band: `map overflow`, `Whoa there Trigger`, `i_lrt`, `bfreelist.av_forw != &bfreelist`, `ttyretype`, `MAX_PROC` per `rg -a -F` auf den
Dumps: keine Treffer, `SCHMAG` und `Sleeping on wchan 0` treffen -- das Band ist das Bell-V7.)

Nijmegen ist eine **Schwestervariante** (gleiches Optionssystem: `LRUI`, `PROC_MAX`, `EXIT`; eigene Zusaetze `EtxAck`, `SEMAPHORES`, `ttyfecho`, `CSTATUS`), steht MUTOS aber ferner:
es fehlen malloc-Grenze, `seek`, `breada`, `exece`-Fehlerschleife; `maptab` weicht an 26 von 128 Stellen ab; `NPROC 150`, `NINODE 200`.

### 4.3 Vollstaendige Funktionsaehnlichkeiten (Stufe `abs`, gleichnamig; `( )` = Name fehlt, beste andere Funktion)

```
func      file         v7    s3 hippe   nij   b28   b29  b210  b211    b3   b41   v32   pwb idata  wega
alloc     alloc.c     97%   72%  100%   97%   86%   56%   31% (51%)   97%   82%   97%   74%   69%  100%
free      alloc.c     99%   80%  100%   99%   95%   65%   24%   21%   99%   99%   99%   79%   77%  100%
ialloc    alloc.c     96%   53%  100%   96%   60%   61%   32%   33%   73%   62%   93%   61%   58%   95%
ifree     alloc.c     89%   55%  100%   89% (53%)   65%   23%   23%   65%   77%   89%   81%   69%  100%
breada    bio.c       96%   74%   90%   90%   96%   96%   63%   53%   96%   70%   96%   68%   67%   73%
iodone    bio.c       84%  100%  100%  100%   84%   81% (76%) (76%)   67%   60%  100%   65%   59%  100%
clock     clock.c     69%   43%   72%   72%   60%   55% (31%) (31%)   57% (21%)   69%   49%   40% (50%)
iget      iget.c      91%   56%   93%   93%   74%   56%   50%   46%   91%   70%   91%   59%   63%   70%
iput      iget.c      90%   75%   92%   92%   57%   53%    0%    0%   90%   48%   90%   64%   63%   59%
malloc    malloc.c    95%   95%   82%   95%   81%   58%   13%   13%   72% (55%)   95%   69%   65%   95%
mfree     malloc.c    94%   94%   94%   94%   90%   50%   14%   14%   73% (48%)   87%   83%   73%   94%
ptrace    sig.c       94%   93%   96%   96%   94%   90%   67%   55% (57%)   57%   94%   63%   63%   89%
sched     slp.c       92%   62%   93%   77%   92%   63%   34%   32%   46%   28%   74%   55%   32%   85%
exece     sys1.c      65%   48%   68%   68%   53%   51% (50%) (50%)   56%   48%   63% (40%) (27%)   27%
setregs   sys1.c      61%   57%   64%   64%   61%   48%    0%    0%   51%   29%   53%   54% (23%)   37%
exit      sys1.c      80%   66%   92%   92%   76%   51%   30%   28%   61%   39%   68%   40%   27%   73%
seek      sys2.c      85%   51%  100%   85% (51%)   50% (51%) (22%)   85%   85%   85%   13%   11%   57%
smount    sys3.c      97%   59%  100%   98%   83%   65%   13%    3%   94%   79%   97%   58%   61%   80%
sumount   sys3.c      91%   62%   97%   94%   75%   45% (51%) (31%)   91%   61%   91%   66%   67%   74%
stime     sys4.c      34%   38%   78%   78%   31%   26% (16%) (16%)   16%   23%   16%    8%    8%   34%
```

(b210/b211/b41 haben eine andere Kernelstruktur, daher niedrige Werte.  `kill`, `wait`, `fork` ergaben keinen Unterschied V7/Hippe.)  Die Hippe-Zeile ist **wirksam** (Schalter aufgeloest); Nijmegen ebenso (`PROC_MAX EXIT LRUI DELTAB`).

## 5. `tty2.c`: Quelle gefunden

### 5.1 Belege

1. **Tabellen:** `ttylcmap`, `ttyctl`, `ttyword` in `kernel/c/tty2.c` sind **Byte fuer Byte gleich** `maptab[128]`, `cchars[16]`, `wchars[16]` in Hippe `usr/sys/dev/tty.c`.
   `python3 -I h6_tools/tables.py kernel/c/tty2.c <tty.c>`: Hippe maptab/cchars/wchars `IDENTICAL`; Nijmegen cchars/wchars identisch, `maptab` weicht an 26 von 128 Stellen ab;
   V7, 2.8BSD, 2.9BSD, 4.1BSD: `maptab` weicht an 65 Stellen ab, `cchars`/`wchars` fehlen.  (V7-`maptab` kennt das Paritaetsbit-Schema `P = 0200` nicht: 65 Abweichungen ueber alle 16 Zeilen; `cchars`/`wchars` existieren nur in Hippe und Nijmegen, `rg -w wchars` ueber alle Baeume.  Hippe und Nijmegen unterscheiden sich in `maptab` in den Zeilen 0x40..0x5F, MUTOS folgt Hippe.)
2. **Ablauf:** `ttyinput` (Seitenschalter ^P, ^R `CRETYPE`, ^W `CWORD`, `XLITRL`, `SCOPE`-Loeschen, `out0..out3`), `ttyoutput` (`Whoa there Trigger`-Seitengrenze, `LCASE`-Paare `"({)}!|^~'`"`, `t_htdly`
   bei `XTABS`), `ttread`, `ttwrite` (`XPAGE2`), `ttioccomm` (`TIOCSETA`/`TIOCGETA` 0x740B/0x740C, `TIOCNRD` 0x740F, `TIOCFLUSH` 0x7410, `TIOCSETC`/`TIOCGETC` 0x7411/0x7412) stimmen mit MUTOS ueberein.
   Alle Flag-Werte stimmen: `SCOPE 0400` = 0x100, `INDCTL 01000` = 0x200, `XTABS 02000`, `TTSTOP 0400`, `HUPCLS 01000`, `TBLOCK 02000`, `XPAGE..XERASE` 1/2/4/8/0x10, `TTYHOG 256` (0x33 = TTYHOG/5).
   Damit ist auch der in `kernel/h/tty.h` als "unattributed" gefuehrte Wert `XTABS 02000` geklaert.
3. **Strukturlayout:** `struct tty` Hippe (PDP-11, 16-Bit-Zeiger) und MUTOS stimmen bis `t_line` +34 ueberein: `t_iproc` +0E, `t_addr` +12, `t_ispeed/t_ospeed` +16/+17, `t_erase` +18, `t_kill` +19, `t_flags` +1A,
   `t_nldly..t_vtdly` +1C..+1F, `t_width` +20, `t_length` +21, `union{tc, t_ctlq}` +22..+27, `t_state` +28, `t_xstate` +2A, `t_lnum` +2C, `t_col` +2D, `t_delct` +2E, `t_char` +2F, `t_chan`/`t_linep` +30..+33, `t_line` +34;
   MUTOS haengt `t_ocnt`, `t_hwp`, `t_hwf` an (+36..).  Die Kopierlaengen 6 und 12 Byte in `ttioctl` entsprechen `sizeof(sttiocb)` und `sizeof(ttiocb)`.
4. **Messung:** Datei 43 % (Hippe-wirksam; Nijmegen 41 %, V7 33 %, 3BSD 31 %, 32V 33 %, 2.8BSD `ttyold.c` 26 %, 4.1BSD 26 %, 2.9BSD 22 %, 2.10BSD 21 %, 2.11BSD 18 %, PWB 23 %, WEGA 13 %, System III 17 %).
   Die niedrigen Werte kommen von den frei vergebenen Namen und den hexadezimalen Konstanten.  Wird Hippe-`tty.c` ins MUTOS-Vokabular umbenannt (`mapnames.py`: 11 Funktionsnamen, 9 Membernamen, Makrowerte als Zahlen),
   steigt die Dateiaehnlichkeit auf **55 %**; Funktionen: `ttyopen` 100, `ttyclose` 100, `ttrstrt` 100, `ttyoutput` 74, `ttkick` 70, `ttflow` 69, `ttyflush` 72, `ttywait` 71, `ioctl` 71, `bitset` 64, `ttyecho` 62,
   `ttycol` 57, `unputc` 53, `ttyrub` 52, `ttread` 52, `ttioctl` 52, `ttyinput` 50, `ttwrite` 38, `ttinit` 18, `ttyspec` 12 (Rest: Reihenfolge der Bedingungen / `goto`-Form des Dekompilats).
5. Gegenprobe: der 2.8BSD/2.9BSD/4.1BSD-Treiber `ttynew.c` (`ntyrub`, `ntyecho`) ist eine *andere* Neuentwicklung (20 %).  Die Namen `unputc` (2.8BSD/2.9BSD `prim.c`, 2.11BSD `tty_subr.c`) und `ttyrub` (2.11BSD `tty.c`) kommen bei Berkeley vor, die Rumpfe sind aber anders (Berkeley-`unputc`: Test `c_cc <= 0`, kein 0377-Begrenzer; MUTOS = Hippe-`zapc` mit 0377-Test und `cp -= sizeof(char *)`; `unputc` gegen 2.8BSD 14 %, gegen Hippe-`zapc` 53 %).  Die Namen in `tty2.c` sind laut Dateikopf frei vergeben; der Anklang ist ein Namens-, kein Textbezug.

### 5.2 Namensabbildung MUTOS -> Hippe

| MUTOS (`tty2.c`) | Hippe `dev/tty.c` | | MUTOS | Hippe |
|---|---|---|---|---|
| `ttyopen` | `ttyopen` (2 Parameter; Nijmegen hat 3) | | `ttyspec` | `ttyspcl` |
| `ttinit` | `ttychars` | | `ttflow` | `ttyblock` |
| `ttyclose` | `ttyclose` | | `ttyoutput` | `ttyoutput` |
| `ioctl` | `ioctl` | | `ttrstrt` | `ttrstrt` |
| `ttioctl` | `ttioccomm` | | `ttkick` | `ttstart` |
| `ttywait` | `wflushtty` | | `ttread`, `ttwrite` | `ttread`, `ttwrite` |
| `ttyflush` | `flushtty` | | Members `t_inq`, `t_lstate`, `t_cnt2c`, `t_page` | `t_rawq`, `t_xstate`, `t_lnum`, `t_length` |
| `ttyinput` | `ttyinput` | | `t_dnl`, `t_dcr`, `t_dtab`, `t_dvt` | `t_nldly`, `t_crdly`, `t_htdly`, `t_vtdly` |
| `ttycol` | `ttyretype` (mit `DELTAB`, Parameter `flag`) | | `bitset` | `ttybit` |
| `ttyrub` | `ttywipe` | | `unputc` | `zapc` |
| `ttyecho` | `ttyecho` | | Tabellen `ttylcmap`, `ttyctl`, `ttyword` | `maptab`, `cchars`, `wchars` |

Namenslaenge: signifikant 8 Zeichen -- `ttyretype`, `wflushtty`, `ttioccomm` werden zu `ttyretyp`, `wflushtt`, `ttioccom`; untereinander und gegen vorhandene Namen eindeutig (`rg` ueber `kernel/`).

### 5.3 Empfehlung: `tty2.c` auf den Hippe-Text bringen

* **Vorlage:** `usr/sys/dev/tty.c` (SHA-256 `0271a7fab1fa668b13d0f577013fdcd60c28d08ff1a2a4a2c8d23cff81baf937`), Praeprozessor aufgeloest mit `DELTAB` definiert (steht im Quelltext), `MX`, `SGTTY`, `INSTRM` undefiniert
  (`stty`/`gtty` und die `scontrol`/`sdata`-Teile entfallen -- passt zu `sysent` mit `nosys`); die auskommentierte `ttyrend` weglassen.
  Header: `usr/include/sys/tty.h` und `usr/include/sgtty.h` (Konstanten `CPAGE`, `CRETYPE`, `CWORD`, `CBELL`, `TTHIWAT 100`, `TTYHOG 256`, `XPAGE..`, `CNTLQ`).
* **Reihenfolge nach `plan 42`:** pro Funktion Hippe-Text einsetzen, dann `tools/herkunft/rundlauf.sh`; bleibt die Funktion bytegleich, gilt der Hippe-Text, sonst Kompilatorform belassen und Hippe-Text als Kommentar.
  Zuerst die kurzen Funktionen (`ttyopen`, `ttyclose`, `ttrstrt`, `ttstart`, `ttybit`, `ttyflush`, `ttywait`), dann `ttyoutput`, `ttyecho`, `ttyretype`, `ttywipe`, `zapc`, zuletzt `ttyinput`, `ttread`, `ttwrite`, `ttioccomm`.
* **Zu erwartende Abweichungen** (MUTOS gegen Hippe, gemessen am Lesen beider Texte):
  1. `ttyspcl`: Hippe laeuft mit `sizeof(struct tc)` ueber `tun.t_intrc..`; MUTOS schleife 6 Byte ab `&t_intrc` und prueft `0x10/0x12/0x17` per `switch` -- wohl `iscntrl`-Makro-/Compiler-Form, Wirkung gleich.
  2. `ttyinput`: Hippe schreibt `c = ... SIGINT:SIGQUIT; signal; ttyecho('\n'); ttstart; return`, MUTOS springt auf `kick`; der `goto`-Aufbau (`out0..out3`) ist im Dekompilat anders benannt (`store/put/eol/echo/kick`).
  3. `ttread`: MUTOS zeigt `goto top/chk/wt/have` (Compilerform der verschachtelten `while`-Bedingung); Hippe hat die V7-Form mit `while(...||...)`.
  4. `ttwrite`: Hippe `caddr_t ttwrite` mit Schleife `while(u.u_count)`; MUTOS `goto cnt/slp/put`, Rueckgabe 0.
  5. `ttinit` (= `ttychars`): Hippe mit Makros `CINTR..CKILL`; MUTOS mit Zahlen (`03, 034, 021, 023, 032, 0377, 0177, 025`) -- Werte gleich.
  6. `ioctl`: gleich bis auf die Literale (`FIOCLEX` 0x6601, `IFMPC` 0x3000).
  7. `struct tty` in `kernel/h/tty.h`: Membernamen auf Hippe umstellen (`t_rawq` statt `t_inq`, `t_xstate`, `t_lnum`, `t_length`, `t_nldly`.., `t_iproc`, `t_addr`, `t_ispeed/t_ospeed`, `t_char`, `t_chan`, `t_linep`, `union tc/t_ctlq`);
     `t_ocnt`, `t_hwp`, `t_hwf` bleiben MUTOS-Zusatz hinter `t_line`; `struct linesw` auf V7-Namen (`l_rint`, `l_rend`, `l_meta`, `l_start`, `l_modem`; V7 `l_write` liefert `char *`) -- die SysIII-Namen in `conf.h` waren am Binaerabbild nicht messbar.
  8. Die Aufrufer in `kernel/c/tty.c` benutzen `ttinit`, `ttkick`, `ttioctl(cmd, tp, addr, dev)`: nach der Umbenennung dort ebenfalls anpassen (`ttychars`, `ttstart`, `ttioccomm`); `kernel/conf/conf.c` nennt `ttyopen, ttread, ttwrite, ttyinput, ttkick`.
* **Auch ausserhalb von `tty2.c`** lohnt sich der Hippe-Text: `exece` (Zugriffstest zuerst, `getxfile(ip, nc, ns)`: `sys1.md` fand "V7-Code nicht einsetzbar"), `malloc`/`mfree` (`MAPSIZ`-Form), `breada`, `exit`,
  `seek`, `sumount`, `stime`, `iget`/`iput` -- statt der `/* MUTOS: */`-Marken die Hippe-Form einsetzen und im Dateikopf `Source: Torsten-Hippe-V7 usr/sys/...` nennen.  `CMAPSIZ/SMAPSIZ 50 (guessed)` durch `MAPSIZ (NPROC/2)` ersetzen.

## 6. Offene Punkte

1. **Wer hat die Hippe-/Nijmegen-Aenderungen geschrieben?**  Nicht belegt.  Hinweise: `usr/sys/conf/m.h` ("XBUF ... taken from the Vrije system by Johan Stevenson who converted it from Version 6 Calgary system"),
   Nijmegen `Warren_READ_THIS` (Wilko Bulte, Universitaet Nijmegen), Dateizeit der V7-Originale in `dev/orig/` Oktober 1980.  Sicher ist nur: gemeinsame Optionstechnik (`m.h`), Hippe naeher an MUTOS als Nijmegen.
   Ob es eine dritte, noch naehere Fassung gibt (z. B. eine Z8001-Portierung desselben Ursprungs), ist offen.
2. **Warum wird diese Variante auf einer Z8001 verwendet?**  Offen.  Die Parameter (kleine Tabellen, 11/40) und die Schalter passen zu einer kleinen Konfiguration; ob der Autor des MUTOS-Kerns (Robotron) sie bewusst gewaehlt hat, ist nicht erkennbar.
3. `clock`/`sched` 30-s-`update()` und `setregs`-Namenskopie: keine Quelle; Rueckfrage nur durch Disassemblieren des Userspaces (`/etc/update`, Accounting) zu klaeren.
4. Die UNSW-Baender, Ultrix-11 und V7M wurden in H6b nachgeladen (Abschnitt 8); CB_Unix und Coherent nicht (V6-/i386-Linie, 8.2).  Eine Negativaussage gilt nur fuer die geladenen Baeume.

## 7. Ablage unter `original/` und Lizenz

* **Vorschlag, nicht ausgefuehrt:** `original/hippe-v7/` mit `usr/sys` (Kernelquellen, etwa 2 MB roh) und `usr/include/sys`, dazu `README.md` mit URL, SHA-256 und dem Satz "Aenderungen Dritter, Urheber unbekannt".
* **Lizenz:** Die V7-Basis faellt unter die Caldera-Lizenz (16-Bit-UNIX bis V7).  Die Zusaetze (`XBUF`, `LRUI`, `PROC_MAX`, `EXIT`, SCOPE-/Seiten-`tty.c`, Nijmegen-Teile wie `EtxAck`, `SEMAPHORES`) stammen von Dritten
  ohne eigene Lizenzangabe; TUHS legt sie als "Research"-Distribution ab.  **Bei diesen Zweifeln nicht ablegen**, bevor das geklaert ist (z. B. Anfrage an die TUHS-Betreiber oder den Einreicher).
  Bis dahin reicht: dieses Dokument mit URL und SHA-256, und die Skripte aus Abschnitt 2 (Neuerzeugung in Minuten).  Wird `tty2.c` auf den Hippe-Text gebracht, uebernimmt die MUTOS-Quelle Text Dritter -- dann
  ist die Lizenzfrage vorher zu entscheiden.
* **Nijmegen** wie Hippe: nicht ablegen.  **Berkeley-Baeume** (2.8/2.9/2.10/2.11BSD, 3BSD, 4.1BSD): fuer MUTOS ohne Treffer, daher keine Ablage noetig (BSD-Lizenz der Regents ohne Weiteres moeglich, falls spaeter gebraucht).
* **WEGA** (`OlliL/P8000`): bleibt Referenz, nicht kopiert (`original/wega/README.md`); fuer diese Fragen nur Gegenprobe (`ptrace`, `alloc`, `iodone`).

## 8. Gegenprobe (AP H6b): Abstammung oder nur Verwandtschaft?

Stand 2026-10-31.  Frage: Stammt MUTOS **direkt** vom Kernelstand der Hippe-Sammlung ab (*direkte Ableitung*), von einer **gemeinsamen unbekannten Vorlage** (*gemeinsame Vorlage*, Linie Vrije/Nijmegen/UNSW) oder von einer **anderen,
der Sammlung nur aehnelnden Variante** (*andere Variante*)?  (Fruehere Kurzbezeichnungen H-A/H-B/H-C sind durch diese Begriffe ersetzt.)  Alles *gemessen*, sofern nicht als *angenommen* oder *vermutet* gekennzeichnet.  Werkzeuge: `tools/herkunft/` (Abschnitt 8.9).  Es wurde nichts in `kernel/` oder
`original/` veraendert; alle Quellen liegen im Scratchpad (Wurzel wie Abschnitt 2, Verzeichnisse `h6_unsw*`, `h6_v7m*`, `h6_ultrix11`, `h6_bostic`, `h6_y2k_*`, `h6_v7bugs`, `h6_out2`).

### 8.1 Ergebnis in Kuerze

* **Rangfolge:** (1) **direkte Ableitung vom Kernelstand der Hippe-Sammlung (der MUTOS-Kern stimmt inhaltlich weitgehend mit ihm ueberein)** (Stand mindestens mit der `malloc`-Aenderung von 1982-86) -- *wahrscheinlich*; (2) **Gemeinsame Vorlage** (gemeinsame unbekannte Vorlage) -- *vermutet/moeglich*,
  aber nur mit der Zusatzannahme, dass die Vorlage in allen gemessenen Punkten gleich Hippe ist, also praktisch Hippe-Text war; (3) **Andere Variante** -- *unwahrscheinlich*, ohne jeden Beleg in 30+ geladenen Baeumen.
  Begruendung und Grenzen in 8.8.  **Vorbehalt aus Abschnitt 1 bleibt**: Direkte Ableitung und gemeinsame Vorlage unterscheiden sich im Text nicht, nur in der Weitergabe (wer hat von wem kopiert); das entscheiden nur Daten, die nicht vorliegen (8.8).
* **Abweichungsanalyse (8.4):** 177 MUTOS-Funktionen haben ein gleichnamiges Hippe-Gegenstueck; 146 sind als Text vergleichbar, davon 112 ohne jede Abweichung.  Von 95 Abweichungen sind 72 Z8001-/Namens-/Makroanpassung,
  **keine ist eindeutig "MUTOS aelter/einfacher als Hippe"** (MUTOS = V7/Nijmegen/UNSW, Hippe hat Zusatz), 14 sind Hippe-Inhalt in anderer Schreibweise, 7 sind MUTOS-eigen, 1 ist Z8001.  **Eine Stelle ist fraglich**: der Fehlerausgang von `exece` (`goto bad2` -> `iput`) hat die Form von Nijmegen/V7, Hippe hat `iput(ip); return;` -- das einzige Indiz gegen eine reine Hippe-Kopie.
  In allen 26 Funktionen, in denen Hippe textlich von Spencer-V7 abweicht, traegt MUTOS die Hippe-Abweichung.
* **Merkmale, die nur Hippe hat** (in keinem der geladenen Baeume): `malloc`-Kartengrenze mit `panic("map overflow")`, `getxfile(ip, nargc, ns)`, `NPROC 30`/`NINODE 50`/`MAPSIZ = NPROC/2`, die 128-Byte-`maptab` -- MUTOS hat **alle vier**.
  `seek`-`off = 0` kommt nur noch in Ultrix-11 3.1 vor (1988, spaeter als MUTOS).
* **Korrekturen an Abschnitt 4** (neue Baeume): `exece`/`B_AGE`, `sumount`-`i_count`, LRU-Inode (`i_lrt`), `PROC_MAX`, `exit`-Schleife und `breada`-Test sind **nicht Hippe-eigen**: sie stehen schon in den UNSW-V6-Kerneln
  (UNSW 1, 4, 106; Baender 1978-81) und teils in Nijmegen, UNSW 92, System III, Ultrix-11.  Sie belegen die **Linie** (UNSW/AUSAM -> Vrije/Nijmegen -> Hippe), nicht Hippe selbst.  Nur die Merkmale oben sind Hippe-spezifisch.
* **Zeit (8.6):** Hippes Dateidaten taugen nicht (21 `sys/*.c` tragen 1986, sind aber als Objekt **byte-gleich** zu Hippes Bau vom 1982-01-13; `malloc.c` traegt 1981, enthaelt aber eine Pruefung, die dem 1982er Bau fehlt).
  Die `tty`-Tabellen **stehen byte-gleich im Hippe-Kernel `rkunix` vom 1982-01-13**; die `malloc`-Aenderung ist die **einzige** Quelltextaenderung Hippes zwischen 1982 und 1986 und steckt in MUTOS.
* **Eigenanteil (8.7):** 30-s-`update()`, `setregs`-Namenskopie, Tick-Zaehlung in `clock`, `binit`-`b_error`, `core`-`namei(uchar)`, `setpri` ohne Rueckgabewert, dazu alle Treiber/Z8001-Teile.
* **Korrektur an Abschnitt 4.1 Zeile 15 und `bio.c`:** MUTOS hat **kein** DISKMON im Binaerabbild (`bio.c` Zeile 29: `#define` entfernt, `#ifdef`-Text tot); die `io_info`-Anweisungen in `bio.c` sind toter Text und zaehlen nicht.

## 8.2 Alle auf TUHS gefundenen V7-Varianten

Basis-URL `https://www.tuhs.org/Archive/Distributions/`; Pfad ab dort.  "Merkmale" = Treffer von `traits.py` (8.5): XBUF, LRUI (`i_lrt`), EXIT (Schleife), PROC_MAX (`max_proc`), MAPSIZ-15 (`NPROC 30`/`MAPSIZ NPROC/2`), malloc-Limit, tty-Tabellen (`cchars`+`wchars`).
Volle SHA-256 in 8.2b.  Bell-V7 = Spencer-Tarball (`original/unix-v7`).

| Pfad | Kernelquellen | geladen | Ergebnis (Merkmale) |
|------|---------------|---------|---------------------|
| `Research/Henry_Spencer_v7/v7.tar.gz` | ja | ja (heute geladen; `usr/sys` ist byte-gleich `original/unix-v7/usr/sys`) | Bell-V7: kein Merkmal |
| `Research/Henry_Spencer_v7/v7.patches.tar.gz`, `Research/v7addenda.tar.gz` | nein (Patches, `lp.c`, `lpr`, `c2`, `awk`; `malloc.c` ist die Bibliotheks-`malloc`) | ja (H6) | kein Kernel |
| `Research/Keith_Bostic_v7/v7.tap.gz` (+ `f0..f6.gz`) | ja (Tape-Datei 6, `dump`-Format) | **ja, jetzt als Baum** (`v7dump.py`; 194 + 1945 Dateien) | `sys` byte-gleich Spencer: kein Merkmal |
| `Research/Torsten_Hippe_v7/v7.tar.gz` (+ `v7.gz` RL02-Abbild) | ja | ja (`v7.gz` nicht: gleicher Inhalt als Abbild) | alle Merkmale: LRUI, EXIT, PROC_MAX, XBUF (aus), MAPSIZ-15, malloc-Limit, tty-Tabellen |
| `Research/Nijmegen_v7/nijmegen_v7kernsrc.tar.gz` | ja | ja | LRUI, EXIT, PROC_MAX, XBUF, `sumount`, `exece`-`B_AGE`, `cchars`/`wchars`; **kein** MAPSIZ-15 (`NPROC 150`), kein malloc-Limit, `maptab` 26/128 anders |
| `Research/Bug_Fixes/7th_Edition_Y2K/v7unix.dsk.gz` | nein (kein `/usr/sys`), aber `rkunix` | ja (`v7fs_read.py`, 514 Dateien) | `rkunix` **byte-gleich** Hippes `rkunix`, `bin` und (bis auf eine Datei) `etc` gleich, `usr/include/sys/param.h` mit `NPROC 30`: Kopie des Hippe-Systems mit Y2K-Korrektur, **keine eigene Variante** |
| `Research/Bug_Fixes/Net.v7bugs/` (109 Postings 1979-82) | Fehlerberichte | ja | kein Posting zu `map overflow`, `MAPSIZ`, `breada`, `sumount`, `i_lrt`, `max_proc`, `s_tfree`, `seek`; nur 0003 (`exece`: `~B_DELWRI` nach `bread`) ist Kernel-relevant |
| `Research/Bug_Fixes/V7_on11-34/`, `V6enb/` | Patches (`mch11.s`, `trap.c`) / V6 | nein | nur Randpatches bzw. V6, nicht ausgewertet |
| `Boot_Images/v7_rk05_1145.gz`, `v7_rl02_1145.gz` | nein (Abbilder) | ja (`v7fs_read.py`) | Kernel (`hptmunix`, `rphtunix`, `rptmunix`, `hphtunix`) **byte-gleich** Spencer; `rkunix` ohne Hippe-Symbole |
| `DEC/Jean_Huens_v7m/` (V7M 2.1, 1981-10-01) | ja (`tapefile7` = `/sys`, Overlay-Kernel fuer PDP-11 ohne getrenntes I/D) | ja (`tapefile6` Root-Dump, `7` Quellen, `8` `/usr`; `1..5` Boot/README) | kein Merkmal (nur V7-Baseline); Overlay-Anpassung in `slp.c`, `malloc.c`, `sig.c`, `main.c` u. a., aber kein Hippe/UNSW-Zug |
| `UNSW/81`, `UNSW/83` (laut `DETAILS` identisch) | ja | ja | Inhalt **identisch** (`diff -r` leer, nur die `.gz`-Huellen unterscheiden sich); Kernelquellen byte-gleich Spencer (nur `LIB1`/`LIB2` anders): kein Merkmal |
| `UNSW/92` (1981-03/09, "Level 7, UNSW") | ja (`sys/sys`, `sys/dev`) | ja | **eigene V7-Aenderungen** (`limits.c`/`lnode`, `p_pgrp`, `copen`); `exece` mit `bdwrite`+`B_AGE`, `s_tfree`; **kein** LRUI/PROC_MAX/EXIT/malloc-Limit/tty-Tabellen |
| `UNSW/93` | nein (nur `include`, `libc6`, `src`) | ja | kein Kernel |
| `UNSW/1`, `4`, `106`, `107`, `108`, `110` | `1`, `4`, `106`: V6-Kernel (AUSAM); `107`: nur Header (`proc.h`, `inode.h`, `defines.h`); `108`, `110`: Werkzeuge | ja | **V6**, aber mit `i_lrt` (LRU-Inode), `max_proc` (`MAX_PROC`-Schalter), `breada`-Freilistentest, `sumount`-`i_count`; kein EXIT/malloc/tty |
| `UNSW/5`, `6`, `7`, `82`, `85`, `86`, `87`, `90` | `87`: PWB-Kernel; `86`: nur Binaerkernel (`unix*`); `5`, `6`, `7`, `82`, `85`, `90`: Anwendungen/Sprachen ohne Kernelquellen | ja | `87`: `s_tfree` (PWB); sonst kein Merkmal; `2`, `3`, `88`, `89` nicht geladen (Spiele, Binaerdateien, Sprachen, `nroff`-Tabellen) |
| `DEC/Ultrix-11/Ultrix-3.1-src/ultrix11-src.tar.gz` | ja (`sys/sys`; V7-/2.9BSD-/System-III-Mischung, 1988) | ja | `seek` mit `off = 0`, `exece`-`B_AGE`, `s_tfree`; sonst kein Merkmal |
| `DEC/Ultrix-11/Ultrix-3.0/`, `DEC/Fred-Ultrix3/`, `DEC/Ultrix-3.1/` | Binaerbaender/Baukaesten (Quellen = 3.1-src) | nein | Binaerdaten ohne Quellen bzw. Doppelung |
| `DEC/Venix/` | nein (Binaer-Disketten) | nein | V7-Abkoemmling fuer 8086/PRO, nur Binaerdateien |
| `Other/Coherent/kernelsource/` | ja, aber i386 (4.2.10) | nein | Neuentwicklung (Mark Williams), keine V7-Linie |
| `Research/Dan_Cross_v8,v10`, `Norman_v9,v10` | ja | nein | Research-UNIX V8-V10 (VAX/4.1BSD-Linie), 8-71 MB; nicht die V7-PDP-11-Linie |
| `USDL/32V`, `PWB`, `UCB/*` | ja | ja (H6, Abschnitt 2) | keine Hippe-Merkmale |
| `USDL/CB_Unix`, `Early_Networking/*`, `Other/{PCIX,KSOS,GUN,NOS-MT,Xinu,V6on286,OS_Course}` | teils | nein | V6-/System-III-Linie oder anderes Betriebssystem; `Early_Networking` ist V6 |

### 8.2b Quellen (neu geladen in H6b), SHA-256

Archive in `h6_dl/` (Namen mit `_` statt `/`), entpackt je in ein eigenes Verzeichnis.  Weitere (Hippe, Nijmegen, Berkeley, ...) siehe Abschnitt 2 und `h6_sha256.txt`.

```
bb58a22c07e4f2101b4b8f4f298bd7e8d915b293b49d2dd2b93437ef58497dc9 Boot_Images/v7_rk05_1145.gz
6553f55c3898bee11dd66969926f579cd5a90e689dd34b22a848544b7e4d8f34 Boot_Images/v7_rl02_1145.gz
1ad9a84b280055ddf14458e10123ddf77a9bbd4f6349a98331b28265ff2b6283 DEC/Jean_Huens_v7m/tapefile6.gz
1f56268749f33939f0d67fac7cbe0dfce6102d6a57284e60acfc263eaa865e40 DEC/Jean_Huens_v7m/tapefile7.tar.gz
051bc227504656a0e2e131f7c2e70e7c9290425ae278575e86cae13dab0d3987 DEC/Jean_Huens_v7m/tapefile8.tar.gz
46ffac3f2649adb59e11d0f8c2f12da5c70c6e3fc498855616f5e5bb029971f7 DEC/Ultrix-11/Ultrix-3.1-src/ultrix11-src.tar.gz
f7b131be92617d04816be55693313e9ffb2393b1c18cc2fb4bf72c34585b6f5c Research/Bug_Fixes/7th_Edition_Y2K/v7unix.dsk.gz
e0fd7bdd046e17de177f5d997acf8123fa43c57b46b032c7337f7666ab69a07e Research/Henry_Spencer_v7/v7.tar.gz
bfa330ea98468cb221e72659368b2cbc617005b0d1db3c2e294190ae0f62dc85 Research/Keith_Bostic_v7/f5.gz
d65f7d8765a0260f499e26f0cdf330d84d75220b13b5de890f6b31e554ff31e5 Research/Keith_Bostic_v7/f6.gz
c071c2572a26ef0c1e0ed392cd97f1b0583082538230d0e693441fed7b2d4c1f UNSW/1/record0.tar.gz
f4148316508f28584644ecdcb7af2913f3a8cda44357b0fdc31b3346c10a79fa UNSW/106/106.tar.gz
d6af6347109fbcd67dd2243ae2d2afb6f2cbbb9aa5528a1596675effd12d0e8b UNSW/107/107.tar.gz
3a93109714a91a5bfe1f572b3fbce5d810655c4c500eab711db80445b5f8273d UNSW/108/108.tar.gz
5935bf0d229f6e7745edcfaf57faec7d5cc8ac8ed77f359f8bb3e47ccc2b0998 UNSW/110/110.tar.gz
e43e59ba68440e04716a6ced0f6413b3d9e7cc348de6ad1baeb77607f4ca37f9 UNSW/4/record0.tar.gz
24b0346e60b5378202db88e624b2bec38db9e686c0e274d77714eb1fd0ba3dad UNSW/4/record1.tar.gz
04962a684e64bce5c1355cc290529b3fb2122aef23dc91978eb909201b7a7892 UNSW/5/record0.tar.gz
dbcefc10aa1c323399fda68b80e700307004a897d2208a24ee86ecaff712c1f9 UNSW/6/record0.tar.gz
663e5fb5e2466bd097496e4fe6c2c0faf21085db286333e9e3d59c2493835d65 UNSW/7/record0.tar.gz
4869fa9424cba5cfec12af30afe3b0bbac393c75310fcaf80f0b21475d143a2b UNSW/81/record0.tar.gz
c1772552496503223aa32ac9cdc3a22025577b244caef95740193e323e2861dd UNSW/82/record0.tar.gz
7b154ecdcd8b9b61526b1ffd0e61814dd05327c86929f38c9f99d79ddead8fd2 UNSW/83/record0.tar.gz
db8c2f6ebd4890b7477250dd71127e5c4f1727fe41548612ca5f77b64a8421ed UNSW/85/record0.tar.gz
18b67d2b579984e1a52d5c83fd892545f9676b2439253ad0099f89a99722b995 UNSW/86/record0.tar.gz
cccfb349f4d9f00d7f368221245d1faacae3714ff10de466034fec4de86e4be8 UNSW/87/record0.tar.gz
0d5c1f61b13995061f549d13fdbb3c28c21d2e94dc359d91e5506227837eee2a UNSW/90/record0.tar.gz
6cc966835a173ccb6b001341bf17990b43755fe005d26e33668cb6c998fc4071 UNSW/92/92.tar.gz
d852f04384d0271193f80b7320ec6244535bbf0d95888ebba120cd876ecb0f17 UNSW/93/93.tar.gz
```

`Net.v7bugs`: 109 Postings (`.../Research/Bug_Fixes/Net.v7bugs/0001..0109`), Sammelsumme `sha256sum 0001..0109 | sha256sum` = `1b4290115dcd25cf5862821b15a8a022c413b6bef4da49683f2dcdfa3048e16c`.
`UNSW/92` und `UNSW/93` sind `tar`-Archive, die beim Entpacken Dateien ohne Leserecht anlegen (`chmod -R u+rwX` auf dem entpackten Verzeichnis).

### 8.3 Verfahren und Nachpruefen

```sh
# Bostic-Band als Baum (dump-Format, Tape-Dateien 5 und 6), V7-Abbilder, Y2K-Platte
python3 -I tools/herkunft/v7dump.py --tap v7.tap SCR/h6_bostic/t           # -> t_f5 (root), t_f6 (/usr)
python3 -I tools/herkunft/v7fs_read.py Boot_v7_rl02.img SCR/h6_v7_rl02     # V7-Dateisystem lesen
# Schalter aufloesen (Hippe-Standardkonfiguration aus conf/m.h; MUTOS-Seite ohne Schalter)
python3 -I tools/herkunft/ifdef_resolve.py SCR/h6_hippe/usr/sys SCR/h6_hippe_eff PROC_MAX EXIT LRUI _1140 TUDUMP DELTAB
python3 -I tools/herkunft/ifdef_resolve.py kernel/c SCR/h6_mutos_eff
# Merkmale ueber alle Baeume (8.5) und Kernel-Binaerdateien (8.6)
python3 -I tools/herkunft/traits.py hippe=SCR/h6_hippe/usr/sys nij=SCR/h6_nijmegen u92=SCR/h6_unsw92/sys ...
python3 -I tools/herkunft/traits.py --aout SCR/h6_hippe/rkunix SCR/h6_y2k_chk/rkunix
# Abweichungsanalyse (8.4): Anweisungsliste je Funktion, Hunks gegen die anderen Baeume gesucht
python3 -I tools/herkunft/devdiff.py --mutos SCR/h6_mutos_eff/*.c --subject hippe=SCR/h6_hippe_eff/sys:SCR/h6_hippe_eff/dev \
    --tree v7=original/unix-v7/usr/sys/sys:original/unix-v7/usr/sys/dev --tree nij=SCR/h6_nijmegen_eff/kernel:SCR/h6_nijmegen_eff/dev \
    --tree u92=SCR/h6_unsw92/sys/sys:SCR/h6_unsw92/sys/dev --tree v7m=SCR/h6_v7m/sys:SCR/h6_v7m/dev --tree ult11=SCR/h6_ultrix11/sys/sys:SCR/h6_ultrix11/sys/dev \
    --tree u1=SCR/h6_unsw1/ken:SCR/h6_unsw1/dmr --tree u106=SCR/h6_unsw106/source/ken:SCR/h6_unsw106/source/dmr \
    --tree s3=original/sys3/uts/pdp11/os:original/sys3/uts/pdp11/io --aux hraw=SCR/h6_hippe/usr/sys/sys:SCR/h6_hippe/usr/sys/dev \
    --soll doc/herkunft/daten/rundlauf_soll.txt --base v7 --json dev.json --md dev.txt
```

`SCR` = Scratchpad.  `devdiff.py` normiert wie `herkunft.py` (Ebene `abs`: Kommentare, Casts, `register`/`auto`, lokale Deklarationen, Klammern weg; Lokale = `ID`; Zahlen dezimal; Typen = `T`), zerlegt jeden Rumpf in
Anweisungen, richtet MUTOS und Hippe aus (`difflib`) und sucht jede abweichende Seite ("Hunk") in der gleichnamigen Funktion jedes anderen Baums (alle Anweisungen der Seite muessen dort vorkommen).
Die Spalte `bytes` stammt aus `daten/rundlauf_soll.txt`: `GLEICH` = der MUTOS-Quelltext der Funktion wird vom Original-`cc` zu den Originalbytes uebersetzt (Textform ist dann belegt), `NAHE` = nur nahe (Form kann Rekonstruktion sein).
Funktionen mit Anweisungsverhaeltnis < 0,6 gelten als **Kompilatorform** (Z8001-Dekompilat) und werden nicht ausgewertet.

### 8.4 Abweichungsanalyse MUTOS <-> Hippe (wirksam)

**Funktionen** (`kernel/c/*.c` ohne `tty2.c` und `varianten/`, MUTOS-Seite schalteraufgeloest, d. h. ohne toten `DISKMON`-Text):

| Gruppe | Anzahl |
|---|---|
| MUTOS-Funktionen gesamt | 207 |
| ohne Hippe-Gegenstueck (Eigenanteil, 8.7) | 30 |
| mit Gegenstueck | 177 |
| davon Kompilatorform (nicht auswertbar; 102 Hunks) | 31 |
| davon Textform | 146 |
| davon ohne Abweichung nach Normierung | 112 |
| davon mit Abweichung (insgesamt 95 Hunks) | 34 |
| Textform, in der Hippe von Spencer-V7 abweicht (= trennscharf) | 26 |
| davon MUTOS traegt die Hippe-Abweichung | 26 |

**Hunks** (95 in Textform-Funktionen; `GLEICH`/`NAHE` = Rundlaufstand der Funktion):

| Klasse | GLEICH | NAHE | Summe | Deutung |
|---|---|---|---|---|
| A: Z8001-, Namens-, Makro- und Konstantenanpassung (`u_ar0`, `NBPW`, `ctod`, `savu`/`save`, `proctop`/`MAX_PROC`, `i_lastr`/`i_lrt`, `copen`/`open1`, Segmentarithmetik, `rk_*`/`b_*`) | 53 | 19 | 72 | regelbasiert (grob), keine Herkunftsaussage |
| B1: Hippe-Inhalt in anderer Schreibweise (`malloc`/`mfree`: 15 statt `MAPSIZ`, `"map overflow\n"`) | 0 | 2 | 2 | MUTOS = Hippe |
| B2: gleichwertige Form/Reihenfolge (`breada`-Klammer, `clock` `do`/`while`, `iexpand`/`iupdat` Anweisungsreihenfolge, `newproc`, `exece` 0/`NULL`, `sumount` ohne `else`, `timeout` `NCALL`) | 8 | 4 | 12 | MUTOS = Hippe |
| B2a: `exece` Fehlerausgang `goto bad2` statt Hippe `iput; return` | 0 | 1 | 1 | **MUTOS = Nijmegen/V7-Form**, Funktion `NAHE` (1 von 389 Woertern ungleich, `sys1.md`) |
| B3: MUTOS-eigen (30-s-`update`, `sched`-`update`, `binit`-`b_error`, `clock` Tickzaehlung 2x, `core` `namei(uchar)`, `setpri` ohne `return`) | 3 | 4 | 7 | 8.7 |
| B4: Z8001 (`procxmt`: 16 statt 8 Register) | 1 | 0 | 1 | von der Regel nicht erfasst |
| **MUTOS aelter/einfacher als Hippe (= V7/Nijmegen/UNSW, Hippe hat Zusatz)** | | | **0 eindeutig, 1 fraglich (B2a)** | spraeche fuer gemeinsame Vorlage |
| **MUTOS hat Zusatz, den es ausser in Hippe nirgends gibt (als Hunk)** | | | 0 | siehe Merkmalsliste unten |
| **MUTOS = anderer Baum als Hippe, mit Inhalt** | | | 0 | spraeche fuer andere Variante/gemeinsame Vorlage |

Ohne Schalteraufloesung der MUTOS-Seite stuenden 5 weitere Hunks (`io_info` in `bread`, `breada`, `bwrite`, `getblk`) als "MUTOS = V7/UNSW 81, Hippe hat es nicht" da; `kernel/c/bio.c` Zeile 29 zeigt, dass es toter Text ist
(`#define DISKMON` entfernt), das Binaerabbild hat keine `io_info`-Zaehler.  Das ist die einzige Stelle, an der MUTOS "V7-naeher" als Hippe aussieht, und sie ist Textstand, nicht Kernstand.

**Anweisungen statt Hunks** (`--base v7`): Hippe hat in den 146 Textform-Funktionen 64 Anweisungen, die Spencer-V7 nicht hat; 35 stehen woertlich in MUTOS (33 auch in anderen Baeumen: System III 23, Nijmegen 22, UNSW 92 20,
Ultrix-11 17, UNSW V6 11, V7M 2; **2 nur in Hippe**: der Aufruf `getxfile(ip, nc, ns)` und `ap = ucp - ns` in `exece`), die uebrigen 29 stehen in MUTOS in anderer Schreibweise (`MAX_PROC` -> `proctop` 18, `i_lrt` -> `i_lastr` 4,
`MAPSIZ` -> 15 3, `NBPW`/`NCARGS`/`IEXEC`-Konstanten in `exece` 4).  Umgekehrt hat MUTOS 190 Anweisungen, die V7 nicht hat: 147 sind in keinem Baum (Z8001-Formen, MUTOS-eigen), 33 stehen auch in Hippe, 2 nur in Hippe, 8 nur in
einem anderen Baum (Ultrix-11/Nijmegen/UNSW: `clock`-`do`/`while`, `runout`, `goto bad2`, `exit` `i = 0`) -- keine davon ist ein Inhaltszug.

**Hippe-eigene Merkmale und ob MUTOS sie hat** (nicht als Anweisung zaehlbar, daher gesondert; "nur Hippe" = in keinem der geladenen Baeume, `traits.py`):

| Merkmal | andere Baeume | MUTOS |
|---|---|---|
| `malloc`/`mfree`: Karte `< MAPSIZ`, `panic("map overflow")` | keiner (T01) | ja (15, `"map overflow\n"`) |
| `getxfile(ip, nargc, ns)` mit `ns = (na+3)*NBPW` | keiner (alle: `getxfile(ip, nargc)`; 2.8/2.9BSD mit `uid, gid`) | ja (`getxfile(ip, nc, ta)`, `ta = (na+3)*2`) |
| `NPROC 30`, `NINODE 50`, `MAPSIZ (NPROC/2)` | keiner (T13-T15; Nijmegen 150/200) | ja (30/50/15) |
| `maptab` 128 Byte (+ `cchars`, `wchars`) | `cchars`/`wchars` auch Nijmegen; `maptab` dort 26/128 anders; sonst keiner | alle drei byte-gleich |
| `seek`: `off < 0` -> `EINVAL`, `off = 0` | nur Ultrix-11 3.1 (1988) | ja |
| `breada`: Vorauslesen nur bei freiem Puffer | UNSW V6 (1, 4, 106), nicht Nijmegen/UNSW 92 | ja |

### 8.5 Merkmale ueber alle Baeume (Dateien mit Treffer)

Befehl: `traits.py` (Muster: `traits.py --list`).  Spalten MUTOS: `1` = Treffer in `kernel/c`, `(name)` = Merkmal vorhanden, aber unter MUTOS-Namen.  Nicht aufgefuehrt (Nullspalten): Bostic-Band und UNSW 83 (= Spencer / UNSW 81), UNSW 93 (kein Kernel).
T13-T15 gelten fuer `h/param.h` (MUTOS: `kernel/h/param.h` hat andere Namen, Werte siehe Abschnitt 4.1 Zeile 13).

| Merkmal (Dateien mit Treffer) | MUTOS | Spencer/Bostic | UNSW 81/83 | UNSW 92 | V7M | Nijmegen | Hippe | Ultrix-11 | UNSW 1 (V6) | UNSW 4 (V6) | UNSW 106 (V6) | UNSW 87 (PWB) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| T01 malloc: panic(map overflow) | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| T02 seek: off<0 -> EINVAL, off=0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| T03 sumount: i_count test | 1 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |
| T04 LRUI: i_lrt (inode age) | (i_lastr) | 0 | 0 | 0 | 0 | 3 | 3 | 0 | 4 | 5 | 4 | 0 |
| T05 breada: bfreelist.av_forw test | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 1 | 0 |
| T06 exit: one loop, wakeup(&proc[1]) once | (proctop) | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| T07 exece: B_AGE on discarded arg blocks | 1 | 0 | 0 | 1 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |
| T08 PROC_MAX: max_proc / MAX_PROC | (proctop) | 0 | 0 | 0 | 0 | 6 | 6 | 0 | 7 | 10 | 7 | 0 |
| T09 alloc: s_tfree-- in alloc() | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 1 |
| T10 smount: d_open error -> out1 | 1 (Kommentar dazwischen) | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| T11 tty: cchars+wchars tables | (ttyctl, ttyword) | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| T12 tty: ttyretype/ttywipe | (ttyrub) | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| T13 param: NPROC 30 | n/a | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| T14 param: NINODE 50 | n/a | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| T15 param: MAPSIZ (NPROC/2) | n/a | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| T16 switch XBUF | 0 | 0 | 0 | 0 | 0 | 13 | 16 | 0 | 0 | 0 | 0 | 0 |
| T17 switch LRUI | 0 | 0 | 0 | 0 | 0 | 4 | 3 | 0 | 0 | 0 | 0 | 0 |
| T18 switch EXIT | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| T19 switch PROC_MAX | 0 | 0 | 0 | 0 | 0 | 3 | 3 | 0 | 0 | 0 | 0 | 0 |
| T20 switch SYSACCT/INSTRM/SEPID | 0 | 0 | 0 | 0 | 0 | 17 | 20 | 0 | 0 | 0 | 0 | 0 |
| T21 clock: sflag1 (30 s update) | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| T22 setregs: u_exname | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

Lesehinweise:

* **Die Merkmale der Hippe-Linie sind in der UNSW-V6-Linie alt**: `i_lrt` (LRU-Inode), `max_proc`/`MAX_PROC` (Schalter in `slp.c`), `breada`-Freilistentest und `sumount`-`i_count` stehen in UNSW 1 (Januar 1978), UNSW 4 (Nov. 1979) und
  UNSW 106 (Band 1981); in der UNSW-**V7**-Fassung (92, 1981) fehlen sie, in der V7M und Bell-V7 auch.  Hippe und Nijmegen sind V7-Portierungen dieser Aenderungen (Hinweis `conf/m.h`: "XBUF taken from the Vrije system ... converted from Version 6 Calgary").
* **Korrektur Abschnitt 4.2/Tabelle 4.1**: `exece`-`B_AGE` (T07) steht auch in Nijmegen, UNSW 92, System III und Ultrix-11 (und `bdwrite` statt `bawrite`); der Kern ist der Fehlerbericht `Net.v7bugs/0003` ("bug in exece", `~B_DELWRI`).
  Bell-V7 selbst prueft `access` schon zuerst (`goto bad`); der Fehlerausgang unterscheidet: V7 `bad` (gibt Swap frei), Nijmegen `goto out`, Hippe `iput; return`, **MUTOS `goto bad2`** (Nijmegen-Form); `getxfile(ip, nargc, ns)` hat nur Hippe.  Die H6-Aussage "Zugriffstest zuerst = Hippe" (Abschnitt 4.1 Zeile 8) war zu grob.  `s_tfree` (T09) steht auch in UNSW 92, PWB, System III, Ultrix-11.  `seek` (T02) auch in Ultrix-11 3.1.
  `breada`- und `sumount`-Zug und die Merkmale `LRUI`/`PROC_MAX`/`EXIT` sind nicht Hippe-eigen (UNSW V6, Nijmegen).  Die Aussagen "in keinem anderen der 15 Baeume" in Abschnitt 4/6 gelten nur fuer die damaligen 15 Baeume.
* Ultrix-11 (1988) und UNSW 92 sind **nicht** Vorlage fuer MUTOS: UNSW 92 hat weder LRUI noch PROC_MAX noch die Tabellen, Ultrix-11 ist spaeter, hat kein `max_proc`, keine Tabellen, `getxfile(ip, nargc)`.
* V7M (Overlay-Kernel) ist reines Bell-V7 plus Overlay-Aenderungen: kein einziges Merkmal.

### 8.6 Zeitliche Analyse

**Dateidaten sind schwache Belege** (Kopieren, `tar`, `touch` aendern sie); sie dienen hier nur zur Gruppierung.  Hippe `usr/sys` (94 `.c`/`.h`): **1980: 35 Dateien** (Okt.-Dez.; alle `h/*.h` ausser `param.h`, `systm.h`, `map.h`, `mount.h`; `sys/prf.c`, `sys/sysent.c`;
`dev/{dn,dsort,du,mem,pc,pk3,sem,tc,vp,xsort}.c`), **1981-82: 19 Dateien** (`h/param.h` 81-03, `sys/malloc.c` 81-07, `dev/bio.c` 81-07, `h/map.h`, `h/mount.h` 81-05, `h/systm.h` 81-10, `conf/m.h` 82-01-13, `dev/{rf,rk,rl,rp,si,tm,hk,hp,ht,rm}.c`,
`conf/{mch,smch}.c` 81-12), **1986: 40 Dateien** (Maerz-April: **alle** `sys/*.c` ausser `malloc.c`/`prf.c`/`sysent.c`, dazu `dev/tty.c`, `dev/{kl,lp,dz,dh,dc,...}.c`, `conf/c.c`, `conf/mkconf.c`).  Die MUTOS-relevanten Zuege fallen danach fast alle in die
**1986**-Gruppe (`alloc.c`, `iget.c`, `slp.c`, `sys1-4.c`, `clock.c`, `sig.c`, `tty.c`), nur `malloc.c`, `bio.c` und `param.h` in die 1981-82-Gruppe.  Zwei Gegenbefunde zeigen, dass das nicht das Alter der Zuege ist:

1. **Objektvergleich.** `usr/sys/sys/LIB1.ok` (Datum 1982-01-13, gleich `rkunix`/`rl1unix`/`m.h`) und `LIB1` (1986-04-03) sind `ar`-Archive mit je 25 Moduln.  **22 Moduln sind byte-gleich** (`alloc`, `clock`, `fio`, `sig`, `slp`, `sys1-4`, `text`, `trap`, `nami`, ...); verschieden sind
   `malloc.o` (1176 -> 1296 Byte), `iget.o` (-4 Byte) und `subr.o` (-8 Byte).  Die letzten beiden unterscheiden sich nur durch je ein weggefallenes `tst` (`005704`/`005765`) -- *angenommen*: Bau mit `cc -O` statt ohne, keine Quelltextaenderung
   (`subr.c` weicht von V7 nur in `passc`/`cpass` ab).  Der einzige Quelltextunterschied 1982 -> 1986 ist `malloc.c`: die Pruefung gegen `MAPSIZ` und `panic("map overflow")` (`strings`: nur in `LIB1`, nicht in `LIB1.ok`, nicht in `rkunix`).
   Damit gilt, *angenommen* dass die Objekte aus den heutigen Quellen entstanden: **`LRUI`, `EXIT`, `exece`, `seek`, `sumount`, `stime`, `alloc`-Zaehler, `breada` standen schon im Hippe-Stand von 1982**; die `mtime` 1986 ist Kopierdatum.
   Umgekehrt trug `malloc.c` die `mtime` 1981-07-29, enthaelt aber etwas, das dem 1982er Bau fehlt -- die `mtime` ist dort **zu alt**.
2. **Binaerabbild `rkunix` (1982-01-13).**  Es ist nicht gestript.  Gemessen: Symbole `ttywipe`, `ttyretype`, `zapc`, `ttybit`, `ttychars`, `ttyspcl`, `ttyblock`, `ttioccomm`, `max_proc`, `bfreelist`, `getxfile`, `clkstart` vorhanden;
   `io_info` (DISKMON) nicht.  Die **128 + 16 + 16 Byte `maptab`/`cchars`/`wchars` aus `tty2.c` stehen byte-gleich und zusammenhaengend in `rkunix` (Offset 33486/33614/33630) und `rl1unix`** -- die MUTOS-Tabellen sind also mindestens so alt wie
   Hippes Bau vom 1982-01-13 (Datum selbst nur Dateistempel).

**Aenderungen der 1986er Dateien, die MUTOS fehlen:** Aus 1. folgt nur `malloc.c` als echte spaetere Aenderung -- und MUTOS **hat** sie (Grenze 15, `"map overflow\n"`).  Fuer `dev/*.c`, `conf/*.c` und die Header gibt es keinen 1982er Objektstand
(ausser `tty.c` ueber `rkunix`), also keine Aussage.  Hinweis zur Einordnung: `malloc.c` ist die **einzige** Stelle, an der MUTOS sicher *neuer* ist als der Hippe-Stand von 1982; der Hippe-Stand mit dieser Pruefung ist frueestens 1982-01, sein Bau
(`LIB1`) traegt 1986-04-03.  Die ersten MUTOS-Dateien auf den Disketten tragen 1986-01-09 (Wurzel: `bin/*`, `etc/*`, `dev/*` zwischen 1986-01-09 21:08 und 1986-01-28; `m8k_root.txt`) bzw. 1985-06-26 bis 1986-01-30 (`nroff`-Tabellen
vom Fremdsystem); die `/unix`-Datei steht nicht im Dateisystem (der Kernel liegt in den Bootspuren, `mutos_1216` = 36 352 Byte), ein Kerneldatum ist daher aus den Disketten **nicht ableitbar**.  Waere der Hippe-Stand mit der `malloc`-Pruefung
erst April 1986, koennte MUTOS (Januar 1986) ihn nicht kopiert haben -- das ist aber nur mit den Dateistempeln begruendet, die nach 1. fuer `malloc.c` falsch sind; beweisend ist es nicht.

### 8.7 Eigenanteil: MUTOS-Zuege ohne Gegenstueck in allen geladenen Baeumen

Geprueft gegen Hippe, Nijmegen, V7/Bostic/Boot-Abbilder, V7M, UNSW (1, 4, 81, 83, 92, 106, ...), Ultrix-11, System III, WEGA, 32V, 2.8-2.11BSD, 3BSD, 4.1BSD, PWB (Abschnitt 2).

| Zug | Stelle | Befund |
|---|---|---|
| 30-s-`update()`: `sflag0`/`sflag1`, `cf_x88a`, `sched` ruft `update()` | `clock.c`, `slp.c` | `rg -w sflag1` in allen Baeumen ohne Treffer; schwache Parallele nur: Nijmegen `clock.c` weckt `runout` jede Sekunde bei `backgr` ("added for priority tune; hjt") |
| `setregs`: Name `u_exname` -> `u_dbuf` | `sys1.c` | `u_exname` in keinem Baum |
| `clock`: Tickzaehlung (`lbolt += n`, `u_utime += n`, `addupc(.., n)`) statt je ein Tick | `clock.c` | in keinem Baum; folgt aus dem Mailbox-Takt (*angenommen*) |
| `binit`: `b_error = 0` | `main.c` | in keinem Baum |
| `core`: `namei(uchar, 1)`, zusaetzlicher `writei`-Block | `sig.c` | alle Baeume `schar`; Z8001-Anpassung (*angenommen*) |
| `setpri` ohne Rueckgabewert | `slp.c` | alle Baeume (V6, V7, Hippe, Nijmegen, UNSW) `return(a)` |
| `exece` ohne Hippe-`iput; return`, sondern `goto bad2` am Ende; `SIZE_OF_BLK` = 10 Bloecke | `sys1.c` | Form wie Nijmegen (`out:`), Wert = `(NCARGS+BSIZE-1)/BSIZE` = 10 |
| Treiber: Diskette `fd*` (`dev0.c`), Drucker `lp.c`, Mailbox-Terminal `tc*`, `rk.c` (Mailbox), `mapalloc`/`mapstart` | `dev0.c`, `lp.c`, `tty.c`, `rk.c`, `bio.c` | `lp.c`: Anweisungsverhaeltnis 0,00-0,21 gegen Nijmegen/UNSW 92/System III; die uebrigen ohne gleichnamige Funktion |
| Z8001-Teile: `trap`, `machdep` (`kstub`, `sigret`), `ureg` (`estabur`, `sureg`), `text.c` (`xstub1/2`), `copen` | mehrere | Kompilatorform bzw. ohne Gegenstueck; `copen` ist V7-`open1` unter anderem Namen (UNSW 92 und System III kennen `copen` mit anderer Signatur) |

Die 30 Funktionen ohne Hippe-Gegenstueck: `mapalloc`, `mapstart`, `fd*` (11), `lpcanon`, `lpintr`, `lpxfer`, `kstub`, `sigret`, `syioctl`, `copen`, `xstub1`, `xstub2`, `tc*` (6), `ttxfer`, `ttyinit`.
Hinweis: DISKMON, `proctop` und `NBUF 20`/`NCALL 9` (Hippe 12/10) sind Konfiguration, kein Eigenanteil im Sinn von Quelltext.

### 8.8 Auswertung: direkte Ableitung, gemeinsame Vorlage, andere Variante

**Gemessene Tatsachen:**

1. In 26 von 26 trennscharfen Funktionen traegt MUTOS die Hippe-Abweichung gegenueber Bell-V7; null eindeutige Hunks "MUTOS aelter als Hippe", ein fraglicher (`exece`-Fehlerausgang).
2. Alle vier Hippe-eigenen Merkmale (`malloc`-Grenze, `getxfile(..., ns)`, `NPROC 30`/`NINODE 50`/`MAPSIZ`, `maptab`) stehen in MUTOS; keiner der anderen geladenen Baeume (8.2) hat auch nur eines davon.  Nijmegen, die naechste
   Schwester, hat 0 von 4 (aber `cchars`/`wchars`).
3. Die Linie ist in den UNSW-V6-Kerneln (1978-80) angelegt; UNSW-V7 (92), V7M, Bell-V7, Ultrix-11 haben das Hippe-Bild nicht.  Es gibt in den geladenen Baeumen **keine** Variante zwischen Nijmegen und Hippe.
4. Hippe aendert zwischen 1982 und 1986 im Quelltext nur `malloc.c`; MUTOS hat die neue Fassung.
5. `rkunix` (1982) enthaelt die MUTOS-Tabellen.

**Rangfolge:**

| Rang | Hypothese | Stufe | gemessen / angenommen |
|---|---|---|---|
| 1 | **Direkte Ableitung**: Der MUTOS-Kern ist inhaltlich der Hippe-Kernel (Stand >= `malloc`-Aenderung), ueber den Z8001-Anteil und kleine eigene Aenderungen hinaus uebernommen | **wahrscheinlich** (nicht sicher) | gemessen: 1., 2., 4.; angenommen: dass kein unbekannter Zwischenschritt dazwischen liegt und `exece` MUTOS-eigen geaendert wurde |
| 2 | **Gemeinsame Vorlage**: gemeinsame unbekannte Vorlage (Linie UNSW/Vrije/Nijmegen), aus der Hippe und MUTOS unabhaengig stammen | **vermutet**, nicht widerlegt | gemessen: die Linie (3.); angenommen: eine Vorlage, die in allen vier Hippe-eigenen Merkmalen und in `getxfile`/`maptab` mit Hippe uebereinstimmt, also Hippe-Text war |
| 3 | **Andere Variante**: eine andere Variante, die Hippe nur aehnelt | **unwahrscheinlich** | gemessen: kein geladener Baum kommt MUTOS naeher als Hippe; angenommen: keine nicht geladene Variante (Calgary, Vrije, Johan Stevensons System) |

Begruendung: Gemeinsame Vorlage und direkte Ableitung sind im Text nicht zu trennen -- jede Vorlage, aus der MUTOS stammen koennte, muesste die vier Hippe-eigenen Merkmale tragen und damit Hippe *sein* (inhaltlich).  Gegen eine *unabhaengige* Entwicklung von Hippe-Merkmalen
spricht, dass sie keine bekannten Fehlerberichte sind (`Net.v7bugs` ohne `malloc`/`seek`) und dass MUTOS die komplette `maptab` (128 Byte) hat.  Fuer gemeinsame Vorlage (und gegen "Hippe-Band direkt") sprechen nur (a) die Dateistempel (Hippe-Stand mit
`malloc`-Pruefung im Objekt erst 1986-04-03, erste MUTOS-Dateien 1986-01-09 -- schwach, 8.6), (b) dass MUTOS nach Quelle `NBUF 20`/`NCALL 9`/`HZ 50` fuehrt, die in `m.h` ebenfalls einstellbar sind (kein Beleg), (c) dass `exece` das `goto`-Ende von
Nijmegen/V7 statt Hippes `iput; return` hat (Funktion `NAHE` mit 1 von 389 ungleichen Woertern, die Form ist also im Binaerabbild gestuetzt; Hippes Form steht schon im 1982er Objekt -- ein MUTOS-Stand mit der alten `exece`-Form *und* der
spaeteren `malloc`-Pruefung passt auf keinen Hippe-Stand; er wuerde eine MUTOS-eigene Aenderung oder einen Zweig mit Mischstand bedeuten).  andere Variante haette ein Gegenstueck; es gibt keines.  Von Hippes **Zusatzoptionen** (`XBUF`, `SYSACCT`,
`SYSPHYS`, `SYSLOCK`, `INSTRM`, `SEPID`, `MX`, `SGTTY`) steckt nichts in MUTOS (`traits.py` T16-T20: 0 Treffer); das passt zu Hippes Standardkonfiguration (`m.h`), nicht zu einer fruehen Vorlage mit Optionen.

**Was die Frage entscheiden wuerde (nicht vorhanden):**

* weitere Staende der Linie (Johan Stevensons Vrije-/Calgary-System, Hippes Band vor 1986, Fassungen zwischen Nijmegen und Hippe) -- sie lieferten ein gemeinsame Vorlage-Zwischenglied oder schlossen es aus;
* das **Datum des MUTOS-Kernels**: aus den Disketten nicht ableitbar (kein `/unix` im Dateisystem; Kernel in den Bootspuren); ein Datum vor dem Hippe-`malloc`-Stand wuerde direkte Ableitung mindestens fuer diese Stelle ausschliessen;
* Dateistempel des **Originalbandes** von Hippe (nicht der TUHS-Kopie) und ein Vergleich der Hippe-`dev/*.o` mit Quellen (1982er Objekte fuer `dev`, `conf` fehlen);
* eine PDP-11-Uebersetzung der Hippe-Quellen (`cc -O`), um `iget`/`subr` 1982 gegen 1986 gegen den Quelltext zu pruefen (hier nur als "ohne -O gebaut" *angenommen*);
* Hinweise der Beteiligten (Wer brachte die Hippe-/Nijmegen-Fassung nach Robotron/DDR?).

### 8.9 Werkzeuge, Grenzen

* Neu in `tools/herkunft/`: `devdiff.py` (8.3), `traits.py` (8.5, 8.6), `v7dump.py`, `v7fs_read.py`; aus H6 uebernommen: `ifdef_resolve.py`, `mapnames.py`, `tables.py`, `tap2files.py`, `ftable.py`.  Alle mit Aufrufbeispiel im Kopf, Pfade als Argumente.  Test: `tests/test_herkunft_gegenprobe.py` (synthetische Quellen, ohne die grossen Baeume).
* **Grenzen:** (1) Nur geladene Baeume; ungeladen siehe 8.2.  (2) `devdiff.py` vergleicht Anweisungstexte nach grober Normierung; Klasse A beruht auf einer Wortliste und ist nicht handgeprueft; Funktionen in Kompilatorform (31) fehlen.
  (3) `GLEICH` belegt die Textform nur, soweit der Original-`cc` verschiedene Fassungen unterscheidet.  (4) Das Hippe-Gegenstueck ist die Standardkonfiguration; Schalter anderer Konfigurationen (z. B. `SEPID`) sind nicht aufgeloest.
  (5) Alle Datierungen beruhen auf Dateistempeln und dem Objektvergleich 1982/1986 (*angenommen*: Objekte aus heutigen Quellen).  (6) Die Bewertung "Hippe-eigen" gilt nur gegenueber den geladenen Baeumen.

## 9. Robotron-Umfeld: MUTOS1600 (K1630) als moegliche Zwischenstufe

Stand 2026-10-31.  Keine Quelltexte von MUTOS1600 bekannt; alles Folgende ist Literaturlage, nicht Messung am Code.

* `robotrontechnik.de/html/software/mutos.html` (lokale Spiegelung `~/projects/robotron/Robotron_Technik/`): "Die MUTOS-Entwicklung begann Anfang der 80er Jahre durch die Portierung von UNIX fuer die K1630-Rechner
  (MUTOS1600). Spaeter wurde daraus die Versionen fuer den A5120.16 (MUTOS8000) abgeleitet."  Danach MUTOS1700 (A7100/A7150) und MUTOS1834 (EC1834) auf K1810WM86, MUTOS1800 auf K1840 (32 Bit).
* `robotrontechnik.de/html/computer/k1600.html`: K1600-Rechner waren auf Anwenderebene PDP-11-kompatibel, Betriebssysteme aber nicht austauschbar (andere Geraetetreiber).  MUTOS1600 gilt dort als "ausgestorben".
* TIB-Eintrag "Programmierwerkzeuge unter dem Betriebssystem MUTOS 1630": entwickelt von INEUM Leningrad, VEB Kombinat Robotron und TH Ilmenau fuer den K1630; "kompatibel zu UNIX Version 7".
* Widerspruch: die deutsche Wikipedia ("K 1600") nennt MUTOS 1630 eine "Unix-5-Variante" (ohne Beleg); Messungen (V7-Kern, Abschnitt 1 der `uebersicht.md`) sprechen fuer V7.
* Deutung (*vermutet*): V7-Derivat auf PDP-11-Basis -> K1630 (MUTOS1600) -> Z8001 (MUTOS8000).  Passt zu direkte Ableitung/gemeinsame Vorlage (Abschnitt 8): die Vorlage waere dann die Hippe-nahe PDP-11-Konfiguration.  Ohne MUTOS1600-Quellen nicht pruefbar.

### 9.1 Speicherverwaltung: V7-Vorlage mit MMU, MUTOS ohne

* Hippe-V7 ist fuer die PDP-11/40-Klasse konfiguriert (`conf/m.h`: nur `_1140`; `SEPID`, `PARITY`, `UNIBMAP`, `FPP` aus; Assist `m40.s`; RL01/RL02-Platten) und nutzt die KT11-MMU
  (`KISA`/`UISA`/`SSR0` in `m40.s`, `sureg`/`estabur` in `sys/ureg.c`).  Gemessen.
* MUTOS8000: `sureg` ist nur `RET` (Karte 3D40), `estabur` nur eine Groessenpruefung; Abbild nichtsegmentiert, Ladeadresse 0.  Gemessen.  Wie Prozesse getrennt werden, ist offen (Swapping auf feste Stelle,
  Z8001-Schutz oder keiner): *ungeklaert*, siehe `kernel_struktur.md`.
