# Herkunft von `kernel/c/bio.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/dev/bio.c` (nicht `sys/`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  15 Funktionen V7-Text, `swap`/`physio` V7-Funktionen im Z8001-Umbau (V7-Original als Kommentar daneben), `mapalloc`/`mapstart` MUTOS-eigen.
  Dateiaehnlichkeit V7 78 % -> 84 %, System III PDP-11 59 % -> 57 % (der Rueckgang: V7-Kommentare und `DISKMON`-Text zaehlen jetzt mit).
* Rundlauf: **17 von 19 bytegleich, wie vorher.**  Offen wie vorher: `mapalloc` (14 von 37 Woertern), `mapstart` (28 von 44), Muster (D) aus `c_rueckbau.md` (`test @r2` gegen `ld r3,@r2; test r3`).
  Die V7-Form aller anderen Funktionen (`bread` ... `clrbuf`, `bflush`, `geterror`) ist bytegleich; `bflush` mit `B_DELWRI && (...)` ohne Klammer, `clrbuf` mit `BSIZE/sizeof(int)`.
* **DISKMON:** V7 definiert `DISKMON 1` und zaehlt in `io_info`.  Der Kernel hat das nicht; der `#ifdef DISKMON`-Text steht unveraendert als toter Text im Quelltext, das `#define` entfaellt (gemessen: der Kernel enthaelt keinen `io_info`).
* **System-III-Zuege:** `iodone` ist textgleich mit System III (ohne `B_MAP`/`mapfree`; V7 hat sie fuer die UNIBUS-Abbildung).  `breada`: Vorauslesen nur, wenn ein Puffer frei ist
  (`bfreelist.av_forw != &bfreelist`); System III prueft `bfreelist.b_bcount>1`, V7 prueft nichts.  Gleicher Gedanke, andere Form -> **Fremdzug** (Idee aus System III, Text eigen).
* Z8001-Anpassungen: Zeiger-Casts auf `d_tab` (`struct devtab *`); `swap` mit fuenf Argumenten und Ganzprozess-Zweig (`count >= 0x104`); `physio` mit 256-Byte-Clicks und Segment `usrseg`;
  Datenobjekte `swbuf1/2` nur `extern` (Definition kommt aus dem Datenmodul des Gesamtbaus).  Die V7-Fassungen von `swap` und `physio` stehen als Kommentar vor den Funktionen (ohne eingebettete Kommentare).
* `mapalloc`/`mapstart`: kein Gegenstueck in V7 oder System III (V7 `mapalloc` ist die UNIBUS-Abbildung); Ablaufwarteschlange fuer die Mailbox (Wort bei Adresse 6), Zweck *angenommen*.

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| bread breada bwrite bdwrite bawrite brelse incore getblk geteblk iowait notavail clrbuf bflush geterror | 57D4..60A8 | identisch / Cast | **gleich** |
| iodone | 5C62 | veraendert (= System III) | **gleich** |
| mapalloc, mapstart | 5CAE, 5CF6 | eigen | nahe (wie vorher) |
| swap, physio | 5D4A, 5F56 | veraendert (Z8001) | **gleich** |

Rueckfall: keiner.
