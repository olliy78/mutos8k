#!/bin/bash
# Zieht aus lauf.log (ARBEITSORDNER/lauf.log) die fuer gastversuche.md belegenden Zeilen:  auszug.sh V4|V5|V6 lauf.log > auszug_vN.txt
V=$1; L=$2
case $V in
V4) rg -n "^\(dbg\) # ===|Ausnahme: NVI|^  <<0>>%FF|^\[io16\].*%0080=00C8|%0080=00C0  U8001 PC=<<0>>%03E8|U8001-Ausnahmen|stopped at|breakpoint  |process terminated|^  \|ps |^  \|pc |A53 \(Einzel" "$L" | cut -c1-190 ;;
V5) rg -n "^\(dbg\) # ===|^\[lp\].* %(0246|0256|025E|0266|026E|0276):|^\[lp\].* %(6874|6BCA|61D2|620E|821A):|U8001 <<0>>%(0246|0256|025E|0266|026E|0276|6874|6BCA|61D2|620E|821A) |=C[25] |^\[lp\].* %(18A4|6B60)|err on dev|bn=|er=|I/O error|No such device|mount:|records" "$L" | cut -c1-190 | awk '{k=($0 ~ /^[0-9]+:\[lp\]/)?"lp":($0 ~ /=C5 /)?"c5":(($0 ~ /bn=|err on dev/)?"bn":"x"); if(k=="x"||++n[k]<=(k=="lp"?200:24)) print}' ;;
V6) rg -n "^\(dbg\) # ===|^\[lp\]|^\[io\]|tm0|records|brw|crw|01B5:|lpl|U8001 <<0>>|^    9" "$L" | rg -v "DJNZ" | cut -c1-190 ;;
esac
