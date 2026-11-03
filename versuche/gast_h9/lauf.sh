#!/bin/bash
# AP H9: Gastversuche V4 (adb-Einzelschritt), V5 (Mailbox-Fehlerpfad/Vektoren), V6 (Floppy-Kette).
# Aufruf: lauf.sh V4|V5|V6 ARBEITSORDNER [Zusatz-dbg-Datei statt vN.dbg]   (Minuten bis Stunden Wanduhr; im Hintergrund starten)
# Ausgabe: ARBEITSORDNER/lauf.log (Debugger-Protokoll mit Bildschirmauszuegen).
# Plattenbelegung wie versuche/kontext/lauf.sh: A=rk0 leer (/tmp), B=rk1 /usr, C=rk2 Wurzel (Kopie), D=rk3 Arbeitsdiskette (/mnt)
# Arbeitsdiskette = Kopie der Diskette "bin" (adb mt tar) + echo dd od ps (cmd) + mknod; alles --rw nur auf Kopien in ARBEITSORDNER.
set -e
HIER=$(cd "$(dirname "$0")" && pwd)
. "$HIER/../../tools/emu_env.sh"
V=${1:?V4|V5|V6}; W=$(realpath -m "${2:?Arbeitsordner}"); SKRIPT=${3:-$HIER/$(echo $V | tr A-Z a-z).dbg}
rm -rf "$W"; mkdir -p "$W/cp" "$W/x"
for d in usr_mfm root_mfm boot_udos_k5601; do cp "$(gdisk a5120_mutos8000_$d.hfe)" "$W/cp/"; done
cp "$(gdisk a5120_mutos8000_bin_mfm.hfe)" "$W/arbeit.hfe"
CMD=$(gdisk a5120_mutos8000_cmd_mfm.hfe)
(cd "$W/x" && "$K" get "$CMD" bin/echo bin/dd bin/od bin/ps etc/mknod --to . >/dev/null)
mkdir "$W/flach"; cp "$W"/x/bin/echo "$W"/x/bin/dd "$W"/x/bin/od "$W"/x/bin/ps "$W"/x/etc/mknod "$W/flach/"
"$K" put "$W/arbeit.hfe" "$W"/flach/* >/dev/null
# 1987 (536457600 = 1987-01-01) und ausfuehrbar
for f in echo dd od ps mknod adb mt tar; do "$K" attr "$W/arbeit.hfe" $f --mode 0755 --mtime 536457600 >/dev/null; done
"$K" create "$W/tmp.hfe" --fs mutos8k_26x128_mfm --inodes 24 >/dev/null
# Vorspann: Boot, Anmeldung, Platten einhaengen, Datum 1987 (Gastdatum), PATH
sed "s|@W@|$W|g" "$HIER/vorspann.dbg" > "$W/lauf.dbg"
sed "s|@W@|$W|g" "$SKRIPT" >> "$W/lauf.dbg"
"$DBG" --rw --em em256 --laufwerke K5601,K5601,K5601,K5601 "$W/cp/a5120_mutos8000_boot_udos_k5601.hfe" -x "$W/lauf.dbg" > "$W/lauf.log" 2>&1
echo fertig: "$W"
