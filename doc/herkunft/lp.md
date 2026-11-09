# Herkunft von `kernel/c/lp.c` (AP H5)

Stand 2026-10-31.  Vergleich gegen V7, System III PDP-11 `uts/pdp11/io/lp.c` und WEGA `dev/lp.c`.  Alle Zahlen **gemessen** (Ebene abs), sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial** (Nachtrag 2026-11-01, `mailbox_treiber.md` 4.3: naechste Vorlage fuer Zeilenaufbereitung und Flags ist `lp.c` der Hippe-Sammlung bzw. Nijmegen (`lpopen` mit `LPMAX`, `lp_cnt`, `col = 80`, `line = 66`); der Ausgabepfad ueber die Mailbox ist eigen).  Frueher hier "none".  Dateiaehnlichkeit: V7 11 %, System III `lp.c` 23 %, WEGA `lp.c` 10 %.
* **Befund entgegen der Erwartung:** der Spencer-V7-Baum hat **keine `lp.c`** (`ls original/unix-v7/usr/sys/dev`); der bisherige Satz "Aufbau folgt V7 lp.c" (Kopf, `c_rueckbau.md` K7c) ist an dem Baum nicht pruefbar.
  Die Funktionsnamen `lpopen`, `lpclose`, `lpwrite`, `lpintr`, die Merkerbits (`OPEN` 010, `CAP` 020, `NOCR` 040, `ASLP` 0100 oktal = MUTOS 8, 0x10, 0x20, 0x40: gleiche Werte) und die Spaltenzaehler (`ind`, `col`, `ccc`, `mcc`, `mlc`, `line`)
  stehen in System III `lp.c`; MUTOS hat aber `lpcanon` (V7-/2BSD-Name; in SysIII heisst der Zeilenaufbereiter `lpoutput`) und `lpoutput` mit anderer Aufgabe (Zeilenpuffer fuellen).
  Verwandt ist also die **Familie** des klassischen UNIX-Zeilendruckers; ein belegter Vorfahre fehlt.  `lpwrite` 29 %, `lpcanon` 32 % (gegen SysIII `lpoutput`), `lpopen` 25 %, Rest unter 15 %.
* Eigen: Ausgabepfad ueber die Mailbox (`lpxfer`, Befehl 2), Zeilenpuffer 128 Byte je Drucker, Fehlerzaehler `l_err`, die Zustandsbits 0x40/0x80 (Schlaf / Ausgabe laeuft) in `lpclose`, `lpwrite`, `lpintr`.
* Rundlauf: **4 von 7 bytegleich, wie vorher** (`lpopen`, `lpclose`, `lpoutput`, `lpxfer`; nahe: `lpwrite` 42/124, `lpcanon` 104/212, `lpintr` 21/75 Woerter, nur Blockanordnung des Kernel-`c2`).  Nur Kommentare geaendert.
* Verwandte fuer H6: 2.9BSD/3BSD `usr/sys/dev/lp.c` und das V7-`lp.c` des Originalbandes (nicht lokal vorhanden); WEGA `lp.c` ist es nachweislich nicht.

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| lpopen | 6444 | eigen (Familie System III) | gleich |
| lpclose | 64DA | eigen | gleich |
| lpwrite | 6570 | eigen (Familie System III, 29 %) | nahe |
| lpcanon | 6668 | eigen (Familie klassisches `lp.c`, 32 %) | nahe |
| lpoutput | 680E | eigen | gleich |
| lpintr | 6874 | eigen | nahe |
| lpxfer | 690A | eigen | gleich |

## Nachtrag 2026-11-04 (Plan 43 Gruppe B)

`lpwrite` ist bytegleich in drei Quellformen (Hippe-Struktur `while (u.u_count) {..}` mit `break`; Sprungmarken `goto done`; `for (;;)` mit `break`); im Quelltext steht die Hippe-Struktur.  Die frueheren Schwierigkeiten kamen vom `if (c >= 0) {..; goto loop;}` vor dem Fehlerzweig.  **`lpintr`** (21 von 75) bleibt: der Kernel legt das gemeinsame Endstueck `inc r15,#2` hinter den *letzten* Aufruf (`wakeup`), unser `c2` hinter den *ersten* (`lpxfer`); keine Quellform kann das umkehren (**`c2`-Eigenheit**, aus dem Aufbau geschlossen, nicht durch Varianten belegt).  **`lpcanon`** (104 von 212) noch offen (Blockanordnung).

## Nachtrag 2 2026-11-04 (Plan 43 Gruppe C)

`lpcanon` bleibt (104 von 212).  Aufbau gleich bis auf die Anordnung des `default`-Zweiges: im Kernel liegt sein Anfang (`ccc < col`, dann `flag & 0x20` -> `ccc++; return`) hinter der Vergleichskette der `switch`-Faelle und teilt das Endstueck `ccc++` mit `case ' '`.  3 Quellformen (NOCR-Zweig umgekehrt; `default` an den Anfang; beides) liefern 418, 428 und 422 Byte statt 424.  Offen.

## Nachtrag 3 2026-11-04 (Plan 43 Gruppe C, lpcanon)

`lpcanon` ist bytegleich (lp 7 von 8, nur `lpintr` bleibt).  Die Form: im `switch (c)` steht `default:` **zuerst** (`if (ccc >= col) goto rest; if ((flag & 0x20) == 0) goto cr;`), es faellt in `case ' ': sp: ccc++; return;`; hinter dem `switch` stehen die Marken `cr:` (`putc('\r'); col = 0;`) und `rest:` (Ausgabe der Spalte/des Zeichens), das mit `goto sp;` endet.  Damit liegt der Kopf des default-Zweigs vor `case ' '` und das `ccc++` wird gemeinsam benutzt (`jr L674C`).  Gemessen an 6 Varianten: nur die Formen mit `if (!(flag & 0x20)) goto cr;` bzw. `if (flag & 0x20) goto sp; goto cr;` treffen; `goto rest` ohne `sp`-Marke (426 B), Vergleich `col <= ccc` (428 B) nicht.  Die Struktur ist eine Quellform, kein Beleg fuer den Originaltext.
