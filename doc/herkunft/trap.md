# Herkunft von `kernel/c/trap.c` (AP H5)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/trap.c`.  Alle Zahlen **gemessen** (`tools/herkunft/herkunft.py`, Ebene abs), sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial** (V7-Gerippe, Z8001-Fallunterscheidung eigen).  Dateiaehnlichkeit V7 46 %, System III PDP-11 29 %, WEGA 13 %.
* Rahmen von `trap()` (`syst`, `u_fpsaved`, `USER` addieren, `u_ar0 = &r0`, `switch`), das Ende `out:` (`issig`/`psig`, `setpri`, `qswtch`, `addupc`, `restfp`),
  die Systemaufruf-Folge (`u_error = 0`, `EBIT`, `save(u_qsav)` / `EINTR`, Ergebnis nach `ar0`) sind V7.  `nosys`, `nullsys` sind V7-Text (V7 = System III).
* Z8001/MUTOS-eigen: Trap-Nummern 0..12 (V7 PDP-11 0..15 mit `bpt/iot/emt/fpe`), Registerrahmen mit 16 Bit-Segmentzeigern, Argumentuebernahme aus dem Rahmen (`blk4`, vier Worte;
  V7 holt Argumente mit `fuiword` aus dem Befehlsstrom), Systemaufruf 0 = `sigret` (V7: indirekter Systemaufruf), Fall 9 (Segmentfehler) mit `backup()`/`grow(sp)`,
  Paritaetsfaelle 10/11 mit anderen Meldungen, `nested`-Sperre im `default`-Fall.  Kein System-III-Zug.
* Rundlauf: **2 von 3 bytegleich, wie vorher** (`nosys`, `nullsys` gleich; `trap` 37 von 343 Woertern abweichend, bekannt: `c_rueckbau.md` K7c, Layout der Faelle 10/11/15).
  Aenderung in diesem AP: nur Kommentare (V7-Kommentare an den Faellen, englischer Kopf).  Der V7-Text wurde **nicht** eingesetzt: Fallverteilung, Rahmen und Argumentweg sind anders.

| Funktion | Kernel | V7 abs | Klasse | Rundlauf |
|---|---|---|---|---|
| trap | 087A | 48 % | veraendert (V7-Gerippe, Z8001-Faelle eigen) | nahe (37/343) |
| nosys | 0B2A | 100 % | identisch (`register i` bleibt fuer den Prolog) | gleich |
| nullsys | 0B38 | 100 % | identisch | gleich |

## Fremdzuege fuer H6

* `trap`, Fall 11: Ausgabe "parity during ... waiting - segment = %x offset = %x + ??" und Auswertung von `ident` (Bits 14/15 und Maske `0xF600`): kein V7-/SysIII-Gegenstueck (V7 gibt 11/70-Paritaetsregister aus) -- Z8001-Hardware (*angenommen*).
* Text "Random interrupt (ident = %x) ignored" mit `ident` (V7: ohne), Rueckkehr wie V7 mit `return` (gemessen im Gast, Probe `trapD`, `z8001_kontext.md`; die fruehere Angabe "`goto out`" war falsch).
