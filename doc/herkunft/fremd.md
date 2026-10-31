# Fremdherkunft des MUTOS-Kernels (AP H6): Torsten-Hippe-V7 als Vorlage

Stand 2026-10-31.  Plan: `doc/plan/42_unix_herkunft.md` (H6).  Kurzfassung: `uebersicht.md` Abschnitt 13.
Alle Zahlen **gemessen**, sofern nicht als *vermutet* oder *angenommen* gekennzeichnet.  Stufen: **sicher** (mehrere unabhaengige Merkmale, Gegenprobe negativ),
**wahrscheinlich**, **vermutet**, **ungeklaert**.  Es wurde nichts in `kernel/` oder `original/` veraendert; alle Quellen liegen nur im Scratchpad (Abschnitt 2).

## 1. Ergebnis in Kuerze

* **Die "Fremdzuege" und die "System-III-Zuege" des MUTOS-Kerns kommen zusammen aus einer Quelle: der V7-Variante `Distributions/Research/Torsten_Hippe_v7/v7.tar.gz`
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
`USDL/32V/file1.gz`, `file2.tar.gz`, `USDL/bostic_pwb.tar.gz` (`a048beed...a0a`; gleiche Linie wie `spencer_pwb`, nicht ausgewertet).  **Nicht geladen:** UNSW-Baender, CB_Unix, Ultrix-11, Coherent (i386-Kernel),
2.9BSD-Zweige `2.9-derivatives`.  Die Aussage "in allen Baeumen kein Treffer" gilt nur fuer die Tabelle oben.

Hilfsskripte (nur Scratchpad `h6_tools/`, **nicht im Repo**; Uebernahme nach `tools/herkunft/` waere sinnvoll): `ifdef_resolve.py` (loest `#ifdef` fuer eine feste Makromenge auf),
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
| 8 | `sys1.c` `exece`: Argumentbloecke bei Fehler mit `B_AGE` verwerfen | **sicher** Hippe | `sys/sys1.c:153-160` (`getblk(swapdev,swplo+bno+nc)`, `B_AGE`, `&= ~B_DELWRI`); ebenso Zugriffstest zuerst (`:41`) und `getxfile(ip,nc,ns)` | 65/68 | nur Hippe; erklaert auch die "MUTOS:"-Marke zum Zugriffstest in `exece` |
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
4. Die UNSW-Baender, Ultrix-11, CB_Unix und Coherent wurden **nicht** geladen; fuer die gefundenen Merkmale ist das nicht noetig, eine vollstaendige Negativaussage gilt nur fuer Tabelle 2.

## 7. Ablage unter `original/` und Lizenz

* **Vorschlag, nicht ausgefuehrt:** `original/hippe-v7/` mit `usr/sys` (Kernelquellen, etwa 2 MB roh) und `usr/include/sys`, dazu `README.md` mit URL, SHA-256 und dem Satz "Aenderungen Dritter, Urheber unbekannt".
* **Lizenz:** Die V7-Basis faellt unter die Caldera-Lizenz (16-Bit-UNIX bis V7).  Die Zusaetze (`XBUF`, `LRUI`, `PROC_MAX`, `EXIT`, SCOPE-/Seiten-`tty.c`, Nijmegen-Teile wie `EtxAck`, `SEMAPHORES`) stammen von Dritten
  ohne eigene Lizenzangabe; TUHS legt sie als "Research"-Distribution ab.  **Bei diesen Zweifeln nicht ablegen**, bevor das geklaert ist (z. B. Anfrage an die TUHS-Betreiber oder den Einreicher).
  Bis dahin reicht: dieses Dokument mit URL und SHA-256, und die Skripte aus Abschnitt 2 (Neuerzeugung in Minuten).  Wird `tty2.c` auf den Hippe-Text gebracht, uebernimmt die MUTOS-Quelle Text Dritter -- dann
  ist die Lizenzfrage vorher zu entscheiden.
* **Nijmegen** wie Hippe: nicht ablegen.  **Berkeley-Baeume** (2.8/2.9/2.10/2.11BSD, 3BSD, 4.1BSD): fuer MUTOS ohne Treffer, daher keine Ablage noetig (BSD-Lizenz der Regents ohne Weiteres moeglich, falls spaeter gebraucht).
* **WEGA** (`OlliL/P8000`): bleibt Referenz, nicht kopiert (`original/wega/README.md`); fuer diese Fragen nur Gegenprobe (`ptrace`, `alloc`, `iodone`).
