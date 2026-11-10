cat <<'MARK'
--- join j1.txt j2.txt
MARK
join j1.txt j2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -a1 j1.txt j2.txt
MARK
join -a1 j1.txt j2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -a2 j1.txt j2.txt
MARK
join -a2 j1.txt j2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -a1 -a2 j1.txt j2.txt
MARK
join -a1 -a2 j1.txt j2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -o 1.1 2.2 1.3 j1.txt j2.txt
MARK
join -o 1.1 2.2 1.3 j1.txt j2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -j1 2 -j2 1 j3.txt j4.txt
MARK
join -j1 2 -j2 1 j3.txt j4.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -j1 2 -j2 1 -a1 j3.txt j4.txt
MARK
join -j1 2 -j2 1 -a1 j3.txt j4.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -t: c1.txt c2.txt
MARK
join -t: c1.txt c2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join -t: -a1 -a2 c1.txt c2.txt
MARK
join -t: -a1 -a2 c1.txt c2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join - j2.txt <j1.txt
MARK
join - j2.txt <j1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- cat j1.txt | join - j2.txt
MARK
cat j1.txt | join - j2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join j1.txt j4.txt
MARK
join j1.txt j4.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join nosuch j2.txt 2>&1
MARK
join nosuch j2.txt 2>&1
cat <<RC
rc=$?
RC
cat <<'MARK'
--- join j1.txt 2>&1
MARK
join j1.txt 2>&1
cat <<RC
rc=$?
RC
