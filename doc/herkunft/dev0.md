# Herkunft von `kernel/c/dev0.c` (AP H5)

Stand 2026-10-31.  Vergleich gegen UNIX V7 `usr/sys/dev/*.c`, System III PDP-11 `uts/pdp11/io/*.c` und WEGA `src/uts/dev/*.c`.  Alle Zahlen **gemessen** (Ebene abs), sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: none** (MUTOS-eigener Diskettentreiber `fd*` ueber die Mailbox).  Dateiaehnlichkeit: V7 16 % (`dsort.c`), System III 16 % (`ht.c`), WEGA 18 % (`mt.c`), 10 % (`fd.c`).
  Der Kopf von `dev0.c` nannte bisher "WEGA-fd-Muster": **nicht belegt** (WEGA `fd.c` 10 %).
* Keine Funktion erreicht 50 % gegen eine gleichnamige Quelle.  `fdsub` (62 % gegen `tm.c:tcommand`, 55 % gegen SysIII `ht.c:hcommand`) und `fdioctl` (51 % gegen `mpxchan`) sind Treffer auf kurzen Allerweltsmustern.
  Strukturell erinnert `fdstrategy`/`fdstart`/`fdintr` an das V7-Tripel `xxstrategy/xxstart/xxintr` (Warteschlange `av_forw`, `iodone`), aber der Text ist verschieden.
* Das Modul ist im Original **ohne Optimierer** uebersetzt (alle Spruenge `JP`); der Rundlauf (`rundlauf.sh`, nur `cc -O`) deckt es nicht ab, `dev0` steht deshalb nicht in `rundlauf_soll.txt`.
  Die Absicherung ist der Gesamtbau (BYTEGLEICH).  An `dev0.c` sind in diesem AP nur Kommentare geaendert (Uebersetzung ins Englische, Kopf).
* Verwandte fuer H6 (*nicht belegt*): WEGA `dev/fd.c` (P8000), die U880-Seite `mutos_io` (Befehlscodes 25H/27H/51H/61H sind Controller-Befehle).

| Funktion | Kernel | bestes V7-Gegenstueck | Klasse |
|---|---|---|---|
| fdopen, fdclose, fdstrategy, fdstart, fdintr, fdadj, fdread, fdwrite, fdphys | 7E16..8554 | unter 25 % | eigen |
| fdsub | 7F00 | 62 % (`tcommand`, Muster) | eigen |
| fdioctl | 85B0 | 51 % (`mpxchan`, Muster) | eigen |
