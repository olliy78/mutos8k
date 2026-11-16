cat <<'MARK'
--- m1: define, args, quoting, comment
MARK
m4 m1.m4
cat <<'MARK'
--- m2: ifdef ifelse incr len index substr translit changequote
MARK
m4 m2.m4
cat <<'MARK'
--- m3: eval
MARK
m4 m3.m4
cat <<'MARK'
--- m4: divert undivert divnum
MARK
m4 m4.m4
cat <<'MARK'
--- m5: include sinclude
MARK
m4 m5.m4
cat <<'MARK'
--- m6: nesting, rescan, 9 args, names
MARK
m4 m6.m4
cat <<'MARK'
--- stdin
MARK
cat m1.m4 | m4
cat <<'MARK'
--- two files, definitions persist
MARK
m4 m7.m4 m8.m4
cat <<'MARK'
--- file then stdin (-)
MARK
cat m8.m4 | m4 m7.m4 -
cat <<'MARK'
--- unix predefined
MARK
m4 m9.m4
cat <<'MARK'
--- no newline at EOF (name at EOF)
MARK
m4 m10.m4
cat <<R
|rc=$?
R
cat <<'MARK'
--- EOF in string
MARK
m4 m11.m4 2>/dev/null
cat <<R
|rc=$?
R
cat <<'MARK'
--- missing file
MARK
m4 nonexistent.m4 2>/dev/null
cat <<R
|rc=$?
R
