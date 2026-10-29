#!/bin/bash
# Uebersetzt C-Quellen im MUTOS-Gast (cc -S und cc -c, ohne und mit -O) und holt .s/.o zurueck.
# Aufruf: gast_lauf.sh ARBEITSORDNER QUELL.c [QUELL.c ...]   (Quellen aus kernel/c/)
# Ergebnis: ARBEITSORDNER/out/<name>.s, <name>.o, <name>O.s, <name>O.o, err*.
# (Gast-Puffer: am Ende `sync`, sonst fehlen die Dateien auf dem Abbild.)  Der Lauf dauert Minuten (Wanduhr); Skript im Hintergrund starten.
# Umgebung: NUR_O=1  nur die Laeufe mit -O (die ohne -O sind fuer den Kernelvergleich wertlos, ~Haelfte der Zeit);
#           KEIN_S=1 ohne -S (nur .o, spart Platz auf der Quelldiskette).
# Die Header aus c/h/*.h liegen flach neben den Quellen (`#include "param.h"` findet sie im Arbeitsverzeichnis des Gasts).
set -e
HIER=$(cd "$(dirname "$0")" && pwd)
. "$HIER/../emu_env.sh"
W=$(realpath -m "${1:?Arbeitsordner}"); shift
rm -rf "$W"; mkdir -p "$W/cp" "$W/src" "$W/out"
for d in usr_mfm root_mfm boot_udos_k5601; do cp "$(gdisk a5120_mutos8000_$d.hfe)" "$W/cp/"; done
DATEIEN=""
for q in "$@"; do
  n=$(basename "$q" .c)
  case "$q" in /*) qp=$q;; *) qp=$REPO/kernel/c/$q;; esac
  cp "$qp" "$W/src/${n}O.c"; [ -n "$NUR_O" ] || cp "$qp" "$W/src/$n.c"
  DATEIEN="$DATEIEN $n"
done
for h in "$REPO"/kernel/h/*.h; do cp "$h" "$W/src/"; done
NV=2; [ -n "$NUR_O" ] && NV=1
NA=1; [ -z "$KEIN_S" ] && NA=2
NSTEP=$(( $(echo $DATEIEN | wc -w) * NV * NA ))
for i in $(seq 1 $((NSTEP+1))); do echo ENDE$i > "$W/src/fertig$i"; done
"$K" create "$W/quelle.hfe" --fs mutos8k_26x128_mfm --inodes 110 >/dev/null
"$K" put "$W/quelle.hfe" "$W"/src/* >/dev/null
"$K" create "$W/tmp.hfe" --fs mutos8k_26x128_mfm --inodes 24 >/dev/null
{
cat <<EOT
g 80000000
keys BOOT\sMUTOS\r
g 100000000
eject A
mount A $W/tmp.hfe udos_ss77
mount B $W/cp/a5120_mutos8000_usr_mfm.hfe udos_ss77
mount C $W/cp/a5120_mutos8000_root_mfm.hfe udos_ss77
mount D $W/quelle.hfe udos_ss77
keys r
g 100000000
keys root\r
g 100000000
keys /etc/mount\s/dev/rk1\s/usr\r
g 30000000
keys /etc/mount\s/dev/rk3\s/mnt\r
g 30000000
keys /etc/mount\s/dev/rk0\s/tmp\r
g 30000000
keys cd\s/mnt\r
g 20000000
keys PATH=/bin:/usr/bin:.\r
g 20000000
EOT
i=1
for n in $DATEIEN; do
  for v in "" O; do
    [ -n "$NUR_O" ] && [ -z "$v" ] && continue
    o=""; [ -n "$v" ] && o="-O\s"
    if [ -z "$KEIN_S" ]; then
    echo "keys cc\s${o}-S\s$n$v.c\s>err_S_$n$v\s2>&1;cat\sfertig$i\r"; echo "gscreen \"ENDE$i\" 4000000000"; i=$((i+1))
    fi
    echo "keys cc\s${o}-c\s$n$v.c\s>err_c_$n$v\s2>&1;cat\sfertig$i\r"; echo "gscreen \"ENDE$i\" 4000000000"; i=$((i+1))
  done
done
echo "keys sync;sync;cat\sfertig$((NSTEP+1))\r"; echo "gscreen \"ENDE$((NSTEP+1))\" 400000000"; echo "keys sync\r"; echo "g 100000000"; echo "keys ls\s-l\r"; echo "g 50000000"; echo screen; echo q
} > "$W/lauf.dbg"
echo "Start (Hintergrund empfohlen):"
"$DBG" --rw --em em256 --laufwerke K5601,K5601,K5601,K5601 "$W/cp/a5120_mutos8000_boot_udos_k5601.hfe" -x "$W/lauf.dbg" > "$W/lauf.log"
for f in $("$K" ls "$W/quelle.hfe" 2>/dev/null | awk '{print $NF}' | rg '\.(s|o)$|^err'); do
  "$K" get "$W/quelle.hfe" "$f" --to "$W/out" >/dev/null || true
done
echo fertig: "$W/out"
