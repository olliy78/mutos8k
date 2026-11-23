# W10z: Speicherbedarf von c2x bei `as_code` (Teilstand)

Stand 2026-11-23.  Plan 52, W10.  Vorgaenger: `wk_w10y.md`.  Nachfolger: W10aa (c2x verkleinern).

## Speichermodell (gemessen)

* MUTOS laedt nur einfache Programme (Magic E807/E707): Text, Daten und BSS liegen **zusammen** in einem 64-KB-Segment ab Adresse 0
  (`kernel/c/sys1.c`, `getxfile`: `u_ex[2] = text + data`); keine getrennten I/D-Raeume.  `sbreak()` prueft nicht gegen den Stapel (F5).
* Die Option `-` von c2 meldet die absolute Haldenobergrenze (einschliesslich Programmbild).
* Programmbild (Text+Daten+BSS): `neu_c2` 22236 B, c2x (25636 B, W10w) 28944 B -- **+6,7 KB, fast nur Text** (0x423C -> 0x5BC4).
  Daten/BSS zu verkleinern hilft daher nicht; der Hebel ist die Halde oder die Textgroesse.
* Stapeltiefe: nicht gemessen.

## Teilen der Zeichenketten als Schalter `S`

* `copy()` teilt gleiche Zeichenketten jetzt per Laufzeitschalter `S` (Bit `XR_SH` in `xfl2`), nicht mehr per `C2XSHARE`; geteilt wird erst,
  wenn die Halde der laufenden Funktion `XTHR` = 6144 B uebersteigt -- kleinere Funktionen bleiben haldengleich zu c2 (F6).
* `c2gegen.py` setzt `S` fuer `as_code` (`SHARE_MODS`), `C2GEGEN_N=1` gibt `-` mit; `pipeline.py` (`xcc_je_modul`) haengt `S` fuer `as_code` an.

## Messung (Gast, c2x 26158 B mit XTHR 6144)

| Modul | Spitze ausgel. c2 / c2x | gegen Modell |
|---|---|---|
| as_lex | 40K / 49K | gleich |
| as_misc | 26K / 33K | gleich |
| as_main | 28K / 37K | gleich |
| as_expr | 28K / 37K | gleich |
| as_dir | 28K / 35K | **verschieden** (Zeile 71: Modell behaelt `xorb rh2,rh2`, c2x `cp r2,#%44`; R32/R3-Luecke, nicht analysiert) |
| as_code (mit S) | 61K / "0K" | gleich |

* Bei `as_code` laeuft der Zaehler ueber (>= 64K): c2x erreicht trotz Teilen die Grenze; die Ausgabe war dennoch richtig -- **zu knapp**.
  Ein Versuch mit `XTHR` 0 wurde gebaut, aber nicht gemessen (abgebrochen); committet ist der gemessene Stand 6144.
* Nicht gemacht: 65-Module-Rueckwaertspruefung, `bau as --xcc`.

## Folgerung

Teilen allein reicht nicht sicher.  Naechster Schritt W10aa: c2x selbst um 3-5 KB verkleinern (`printf`-Familie ersetzen, Zusatzdurchlaeufe straffen),
Stapeltiefe messen; danach `as_dir` und `bau as --xcc`.
