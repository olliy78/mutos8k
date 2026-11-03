#!/bin/bash
# Extracts the evidence lines for gastversuche.md from the run directory (alle.sh output, plus WORKDIR/v1 from lauf.sh V1 v1.dbg):
#   auszug.sh v1|v2|v3 WORKDIR > auszug_vN.txt
V=$1; W=$2
case $V in
v1) rg -N "^\(dbg\) (# ===|e |a |u |set R[12] |s$)|<<[0-9]>>%(FC00|D586)|em:[03](FC00|D586)|^\[w[pr]16\]|^    R0 =|\[lp\]" "$W/v1/lauf.log" | rg -v "R0 =0000 R1 =0000 R2 =0000" | cut -c1-170 ;;
v2) for f in "$W"/v2_*/lauf.log; do n=$(basename $(dirname $f)); echo "##### $n"
      rg -N "^  %000[02]:|^\[lp\].*%(087A|0B6E|0C7C|0D56|35AE|3630|48C4):|^    R0 =.*R4 =00|FCW=%10A0|FCW=%508C|U8001-Ausnahmen|^\(dbg\) d %FFB0|^  <<3>>%FF[BC]0|^\(dbg\) x/8xw|^  <<3>>%FFCC|ore dumped|panic|trap type|^  \|(seg|aps|pc|ident) |^  \|pc " "$f" | rg -v "%087A.*\[SP\+4\]w=3[0-9]+\(%7F(0[1-9A-F]|1[0-9A-F]|3[0-9A-F]|2[3-9A-F])\)" | rg -v "7F04|7F03|7F1B|7F3B|7F36|7F06|7F02|7F07|7F14|7F30|7F0D|7F23|7F1C" | cut -c1-170 | sed 's/CALL %05F8 *//; s/: 5F00 05F8 *//'; done ;;
v3) for f in "$W"/v3_*/lauf.log; do n=$(basename $(dirname $f)); echo "##### $n"
      rg -N "^\(dbg\) (set R0|set R15|e em|e %0)|^  em:0FC[AD]|^  <<3>>%(FFE0|FFF0|0000|FE80|FFF8|FFFC|0008)|^\[lp\].*%(087A|0B6E|0C7C|0D56|35AE|3630|48C4|4BD0):|^    R0 =FF|Ausnahme: (PRIV|SC)|^  <<3>>%[0-9A-F]+ +:" "$f" | rg -v "7F04|7F03|7F1B" | cut -c1-170 | sed 's/CALL %05F8 *//; s/: 5F00 05F8 *//'; done ;;
esac
