# Herkunft von `kernel/c/sys4.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/sys4.c`.  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: complete** (V7), alle 24 Funktionen mit V7-Text (V7 hat in dieser Datei kaum Kommentare, sie bleiben so).  Dateiaehnlichkeit V7 83 % -> 97 %, System III PDP-11 57 % -> 64 %.
* Rundlauf: **23 von 24 bytegleich, vorher 22 von 24.**  Neu gleich: `chdirec` (V7-Form mit `goto bad`; vorher "Layout der Fehlerbloecke offen", K7c).  Weiter "nahe": `ssig` (39 von 52 Woertern, wie vorher).
* `ssig`: Der Kernel-`c2` laedt `uap` (Stapelvariable FFF2) vor jedem Zugriff neu aus dem Stapel; der Gast-`c2` behaelt den Wert im Register (Deutung aus Kernel-Disassemblat `kernel/asm/ref/sys2.s` und Wortvergleich, *angenommen*).  Gleiches Muster wie K7c beschrieb ("laedt `uap` nach dem Speichern"); keine Quellform gefunden, die es erzeugt.
* `ftime`: der V7-Text `t.millitm = (1000*ms)/HZ;` mit `unsigned ms` ergibt ein Wort Unterschied (Objekt `8922`, Kernel `B12A`; *angenommen*: Nullerweiterung `sub r2,r2` statt `exts rr2`, der Kernel teilt vorzeichenbehaftet).
  Vier Probevarianten in einem Gastlauf (`(1000*(int)ms)/HZ`, `(int)(1000*ms)/HZ`, `1000*(int)ms/HZ`, `(int)ms*1000/HZ`) sind alle bytegleich; im Text steht die V7-nahe `(1000*(int)ms)/HZ`.
* `unlink`: V7 `sizeof(struct direct)` ist bytegleich (die alte Fassung hatte `DIRSIZ+2` mit Cast); `struct direct` = 16 Byte.
* Neue Header: `timeb.h` (V7-Text, vorher lokale `struct timeb` mit `tb_`-Praefixen).  Die Mitgliedsnamen `time`/`timezone` koennen neben der Variablen `time` stehen (gemessen: uebersetzt).
* **Eigene Zuege gegenueber V7:**
  1. `stime` loescht zusaetzlich `i_lastr` aller Inodes (die Freigabezeit der freien Eintraege, siehe `iget.md`); sonst wuerde die Aenderung der Systemzeit die Austauschreihenfolge verfaelschen (Zweck *angenommen*).
  2. `kill` laeuft bis `proctop` statt `&proc[NPROC]` (variable Prozesstabelle, wie `slp.c`/`sig.c`).
  3. `ftime`: `TIMEZONE`/`DSTFLAG` sind 0 (V7: `5*60`, 1) -- im Kern gemessen als `timezone = 0`, `dstflag = 0` (die Konstanten stehen lokal in der Datei).
  4. `ssig`: `SIGKIL` wie V7 (`SIGKILL` ist als SysIII-Alias definiert).

## Funktionen

| Funktion | Kernel | V7 abs (vorher -> nachher) | Klasse | Abweichung von V7 | Rundlauf |
|---|---|---|---|---|---|
| gtime | 4C14 | 100 % -> 100 % | identisch | -- | **gleich** |
| ftime | 4C24 | 51 % -> 100 % | veraendert | `(int)ms`, `TIMEZONE`/`DSTFLAG` = 0 | **gleich** |
| stime | 4C94 | 34 % -> 34 % | veraendert | `i_lastr`-Schleife (eigen) | **gleich** |
| setuid | 4CC6 | 86 % -> 100 % | identisch | -- | **gleich** |
| getuid | 4CF4 | 100 % -> 100 % | identisch | -- | **gleich** |
| setgid | 4D0C | 82 % -> 100 % | identisch | -- | **gleich** |
| getgid | 4D32 | 100 % -> 100 % | identisch | -- | **gleich** |
| getpid | 4D4A | 100 % -> 100 % | identisch | -- | **gleich** |
| sync | 4D6A | 100 % -> 100 % | identisch | -- | **gleich** |
| nice | 4D76 | 91 % -> 100 % | identisch | -- | **gleich** |
| unlink | 4DBC | 92 % -> 100 % | identisch | -- | **gleich** |
| chdir | 4E84 | 100 % -> 100 % | identisch | -- | **gleich** |
| chroot | 4E96 | 100 % -> 100 % | identisch | -- | **gleich** |
| chdirec | 4EB0 | 74 % -> 100 % | identisch | -- | **gleich** (vorher nahe, 23/54) |
| chmod | 4F1C | 100 % -> 100 % | identisch | -- | **gleich** |
| chown | 4F78 | 100 % -> 100 % | identisch | -- | **gleich** |
| ssig | 4FB0 | 91 % -> 100 % | identisch | -- | nahe (39 von 52 Woertern, wie vorher) |
| kill | 501C | 92 % -> 95 % | veraendert | `proctop` | **gleich** |
| times | 50B0 | 46 % -> 100 % | identisch | -- | **gleich** |
| profil | 50D6 | 45 % -> 100 % | identisch | -- | **gleich** |
| alarm | 5100 | 61 % -> 100 % | identisch | -- | **gleich** |
| pause | 511E | 100 % -> 100 % | identisch | -- | **gleich** |
| umask | 5132 | 78 % -> 100 % | identisch | -- | **gleich** |
| utime | 5150 | 92 % -> 100 % | identisch | -- | **gleich** |

* Die V7-Form der Funktionen mit `struct a *uap` (statt `register *uap` mit Indexzugriff in der alten Fassung, z.B. `setuid`, `nice`, `times`, `profil`, `alarm`, `umask`) ist bytegleich -- die alte Dekompilat-Form war also nicht zwingend.
* Rueckfall: keiner.
