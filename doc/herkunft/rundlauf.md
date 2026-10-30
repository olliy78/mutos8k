# Rundlauf fuer wiederhergestellte Kernelmodule (AP H3)

Stand 2026-10-31.  Frage: bleibt ein Modul bytegleich zu `mutos_1216`, wenn man den V7-Text einsetzt?  Alle Zahlen und Dauern **gemessen** (Wirt: diese Umgebung, Emulator `~/projects/a5120emu` vorhanden).

## Der billigste verlaessliche Weg

```
tools/herkunft/rundlauf.sh ARBEITSORDNER alloc iget slp sig        # Exit 0 / 1 / 77
```

* Intern: `tools/kernel/gast_lauf.sh` mit `NUR_O=1 KEIN_S=1` (nur `cc -O -c`, kein `-S`, kein Lauf ohne `-O`: ohne `-O` ist nach `c_rueckbau.md` keine Funktion gleich),
  danach `tools/kernel/vergleich.py` **je Funktion** (nicht `-m`: das gilt nur fuer Module ohne bekannte Abweichungen).
* **Ein** Gastlauf fuer beliebig viele Module: feste Kosten (Boot, Mounts) ~45 s und je Datei ~15 s.  Gemessen: 4 Module in 101-105 s Wanduhr bei freiem Rechner,
  eine Datei mit vier Probevarianten 57 s; bei gleichzeitiger Last (Emulator-Neubau, zweiter Gastlauf) 220-490 s.  Gastlaeufe niemals pollen, im Hintergrund starten.
* Sollwerte: `doc/herkunft/daten/rundlauf_soll.txt` (`Modul Funktion GLEICH|NAHE`).  Exit 1, wenn eine als `GLEICH` erwartete Funktion abweicht oder ein Modul nicht uebersetzt;
  `NAHE` (bekannte `c2`-Abweichung) wird nicht geprueft -- der Objekttext darf sich dort aber nicht verschlechtern: Zahl der abweichenden Woerter vor/nach vergleichen
  (`alloc` 84/158, `ialloc` 169/220, `update` 85/119, `itrunc` 61/93, `tloop` 42/79 sind der Stand 2026-10-31).
* Exit 77: Emulator (`../a5120emu`, Umgebungsvariable `K1520EMU`) oder `disks/original/a5120_mutos8000_boot_udos.zip` fehlt.

## Stolpersteine (gemessen)

* `gast_lauf.sh` liefert **immer Exit 0**, auch wenn `cc` scheitert; `vergleich.py` ebenso bei Abweichungen.  Das Skript `rundlauf.sh` prueft deshalb Objektdatei und `err_c_*` selbst.
* Quelldateien ausserhalb von `kernel/c/` (Probevarianten) nur mit **absolutem Pfad** uebergeben; ein relativer Pfad wird als `kernel/c/<pfad>` gelesen und der Lauf bricht kommentarlos ab.
* Arbeitsordner wird geloescht (`rm -rf`); `gast_lauf.sh` arbeitet auf Kopien der Disketten (`cp/`), nie auf `disks/`.  Alle Laeufe enden mit `sync` (im Skript).
* Eine laufende Emulator-Kompilierung (`tools/dev.sh build`) verlaengert die Laufzeit; `K1520EMU_NOBUILD=1` (Vorgabe in `rundlauf.sh`) unterdrueckt den Neubau durch `emu_env.sh`.
* Mehrere Funktionsvarianten in **einem** Lauf: Datei mit mehreren Kopien derselben Funktion unter anderem Namen (`newprocA`, `newprocB`, ...), alle mit der Marke `/* KERNEL xxxx */`;
  `vergleich.py` vergleicht jede Variante gegen dieselbe Kerneladresse.  So wurden `newproc` und `core` in 1-2 Laeufen geloest (siehe `slp.md`, `sig.md`).
* `vergleich.py` maskiert Relokationsstellen (Aufrufziele, Globale, `u`): eine Funktion mit falscher Argumentreihenfolge oder falscher Adresse sieht dort "gleich" aus.
  Die endgueltige Absicherung ist der Gesamtbau (`tools/kernel/gesamtbau.py --uebersetzen --stufe 1 --boot`, 36 352 von 36 352 Byte, Boot, Arbeitstests; Minuten bis Stunden).

## Absicherung durch den Gesamtbau (2026-10-31, gemessen)

Nach den Aenderungen an `alloc.c`, `iget.c`, `slp.c`, `sig.c` und den Headern (`fblk.h` neu, `inode.h` +`IFMPC/IFMPB`, `param.h` +`SIGINS/SIGTRC/SIGFPT`):
alle 29 C-Dateien uebersetzen im Gast; `gesamtbau.py --stufe 1 --boot`: **181 von 227** Funktionen aus C (vorher 177), `Gesamt: BYTEGLEICH (0 Byte ungleich)`, 36 352 Byte,
Boot bis `#` und Arbeitstests (`summe = 5050` zweimal, `cc -O -c prf.c` -> 1600 B).  Dauer: Uebersetzen ~8 min (zwei Gastlaeufe parallel, Last), Bau + Boot 245 s.
`gesamtbau.py --uebersetzen` rief `gast_lauf.sh` mit `conf.c`/`sysent.c` ohne Pfad auf (lagen frueher in `c/`, jetzt `kernel/conf/`) und brach ab; behoben (`cpfad(x)`).

## Einordnung gegen die teureren Wege

| Weg | Was er beweist | Dauer |
|---|---|---|
| `rundlauf.sh` (hier) | je Funktion Bytes == Original (ausser Relokationsstellen) | ~2 min (alle Module zusammen) |
| `gesamtbau.py --uebersetzen --stufe 1` | ganzer Kernel bytegleich, Adressen der Namen gemessen | Minuten bis Stunden |
| `+ --boot` | Kernel bootet, Arbeitstests | zusaetzlich Minuten |
| `rundlauf_gast.py` | Assemblerquelle (`z8kdis --format as`) -> `as` -> Original (AP K4, nicht der C-Weg) | Minuten bis Stunden |
