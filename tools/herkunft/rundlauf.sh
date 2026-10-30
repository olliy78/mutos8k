#!/bin/bash
# Cheapest reliable round trip for restored kernel modules (AP H3):
#   source (kernel/c/<m>.c) -> guest cc -O -c (original MUTOS toolchain) -> per-function byte comparison with mutos_1216.
# One guest run for ALL given modules (fixed cost: boot + mounts, ~2 min; each file adds ~20-60 s).
# Usage:   tools/herkunft/rundlauf.sh WORKDIR MODULE [MODULE ...]        (MODULE = alloc, iget, ... without .c)
#          SOLL=file  expected results, lines "module function GLEICH|NAHE"; default doc/herkunft/daten/rundlauf_soll.txt
# Exit:    0 = every function expected GLEICH is bytegleich and no module failed to compile,
#          1 = regression / compile error, 77 = emulator or original kernel image missing.
# Notes:   gast_lauf.sh itself always exits 0 and vergleich.py exits 0 on mismatches -> this wrapper checks objects and
#          err files itself.  Source files must be given by absolute path (gast_lauf.sh prefixes kernel/c/ to relative ones).
set -u
HIER=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HIER/../.." && pwd)
W=$(realpath -m "${1:?workdir}"); shift
[ $# -ge 1 ] || { echo "no module given" >&2; exit 2; }
SOLL=${SOLL:-$REPO/doc/herkunft/daten/rundlauf_soll.txt}
ARCHIV=$REPO/disks/original/a5120_mutos8000_boot_udos.zip
[ -f "$ARCHIV" ] || { echo "original disk archive missing" >&2; exit 77; }
mkdir -p "$W"
python3 -I - "$ARCHIV" "$W/mutos_1216" <<'PY' || exit 77
import sys, zipfile
open(sys.argv[2], "wb").write(zipfile.ZipFile(sys.argv[1]).read("dateien/mutos_1216"))
PY
FILES=""
for m in "$@"; do FILES="$FILES $REPO/kernel/c/$m.c"; done
t0=$(date +%s)
K1520EMU_NOBUILD=${K1520EMU_NOBUILD:-1} NUR_O=1 KEIN_S=1 bash "$REPO/tools/kernel/gast_lauf.sh" "$W/g" $FILES > "$W/lauf.log" 2>&1
rc=$?
[ $rc -eq 77 ] && exit 77
echo "guest run: $(( $(date +%s) - t0 )) s (log $W/lauf.log)"
bad=0
for m in "$@"; do
  o="$W/g/out/${m}O.o"
  if [ ! -f "$o" ]; then echo "== $m: NO OBJECT (compile error?)"; cat "$W/g/out/err_c_${m}O" 2>/dev/null | head -20; bad=1; continue; fi
  [ -s "$W/g/out/err_c_${m}O" ] && { echo "== $m: cc messages:"; head -20 "$W/g/out/err_c_${m}O"; }
  echo "== $m"
  python3 -I "$REPO/tools/kernel/vergleich.py" "$W/mutos_1216" "$o" "$REPO/kernel/c/$m.c" | tee "$W/$m.txt"
  if [ -f "$SOLL" ]; then
    while read -r sm sf st; do
      [ "$sm" = "$m" ] && [ "$st" = GLEICH ] || continue
      rg -q "^[0-9A-F]{4} +$sf +GLEICH" "$W/$m.txt" || { echo "REGRESSION: $m $sf expected GLEICH"; bad=1; }
    done < <(rg -v '^#' "$SOLL")
  fi
done
exit $bad
