#!/bin/bash
# Signalzustellung (AP H8): sigtest.c im Gast uebersetzen und laufen lassen; U8001-Abdeckung von sendsig/sigret.
# Aufruf: lauf.sh ARBEITSORDNER   (dauert einige Minuten Wanduhr)
set -e
HIER=$(cd "$(dirname "$0")" && pwd); 
. "$HIER/../../tools/emu_env.sh"
W=$(realpath -m "${1:?Arbeitsordner}")
rm -rf "$W"; mkdir -p "$W/cp" "$W/src"
for d in usr_mfm root_mfm boot_udos_k5601; do cp "$(gdisk a5120_mutos8000_$d.hfe)" "$W/cp/"; done
cp "$HIER"/sigtest.c "$W/src/"
for i in 1 2; do echo ENDE$i > "$W/src/fertig$i"; done
"$K" create "$W/quelle.hfe" --fs mutos8k_26x128_mfm --inodes 40 >/dev/null; "$K" put "$W/quelle.hfe" "$W"/src/* >/dev/null
"$K" create "$W/tmp.hfe" --fs mutos8k_26x128_mfm --inodes 24 >/dev/null
cat > "$W/lauf.dbg" <<EOT
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
keys cc\s-o\ssigtest\ssigtest.c;cat\sfertig1\r
gscreen "ENDE1" 2000000000
cpu u8000
cover on
keys sigtest;cat\sfertig2\r
gscreen "ENDE2" 400000000
g 50000000
cover report $W/cov.txt
screen
q
EOT
"$DBG" --rw --em em256 --laufwerke K5601,K5601,K5601,K5601 "$W/cp/a5120_mutos8000_boot_udos_k5601.hfe" -x "$W/lauf.dbg" > "$W/lauf.log" 2>&1
echo fertig: "$W"
