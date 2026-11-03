#!/bin/bash
# Runs all cases of faelle/ (4 parallel guest boots).  Usage: alle.sh WORKDIR   (minutes of wall clock; start in the background)
# Result: WORKDIR/<case>/lauf.log
HIER=$(cd "$(dirname "$0")" && pwd); W=$(realpath -m "${1:?workdir}"); mkdir -p "$W"
. "$HIER/../../tools/emu_env.sh"   # builds the emulator once; the parallel runs must not rebuild
export K1520EMU_NOBUILD=1
ls "$HIER"/faelle/*.dbg | xargs -P 4 -I{} bash -c 'n=$(basename {} .dbg); bash "'"$HIER"'/lauf.sh" V0 "'"$W"'/$n" {} > "'"$W"'/$n.out" 2>&1'
echo alle-fertig
