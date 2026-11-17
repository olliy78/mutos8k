cat <<'M'
--- arith
M
bc arith </dev/null
cat <<'M'
--- scale
M
bc scale </dev/null
cat <<'M'
--- loop
M
bc loop </dev/null
cat <<'M'
--- func
M
bc func </dev/null
cat <<'M'
--- array
M
bc array </dev/null
cat <<'M'
--- base
M
bc base </dev/null
cat <<'M'
--- quit
M
bc quit </dev/null
cat <<'M'
--- cmt
M
bc cmt </dev/null
cat <<'M'
--- V7 quirk: odd scale prints a leading 0 (dc.c tenot)
M
bc quirk </dev/null
cat <<'M'
--- standard input
M
bc <arith
cat <<'M'
--- bc -l
M
bc -l mathlib </dev/null
