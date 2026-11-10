cat <<'MARK'
--- test a = a
MARK
test a = a
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test a = b
MARK
test a = b
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test a != b
MARK
test a != b
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -n x
MARK
test -n x
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -z ""
MARK
test -z ""
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -z x
MARK
test -z x
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -f t.txt
MARK
test -f t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -f nosuch
MARK
test -f nosuch
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -d /tmp
MARK
test -d /tmp
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -d t.txt
MARK
test -d t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -r t.txt
MARK
test -r t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -w t.txt
MARK
test -w t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -s t.txt
MARK
test -s t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -s empty
MARK
test -s empty
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test 3 -lt 5
MARK
test 3 -lt 5
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test 5 -lt 3
MARK
test 5 -lt 3
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test 10 -eq 10
MARK
test 10 -eq 10
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test 10 -ne 10
MARK
test 10 -ne 10
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test 7 -ge 7
MARK
test 7 -ge 7
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test 7 -gt 7
MARK
test 7 -gt 7
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test ! -f nosuch
MARK
test ! -f nosuch
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -f t.txt -a -d /tmp
MARK
test -f t.txt -a -d /tmp
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -f nosuch -o -d /tmp
MARK
test -f nosuch -o -d /tmp
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test -f nosuch -a -d /tmp
MARK
test -f nosuch -a -d /tmp
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test \( -n x \)
MARK
test \( -n x \)
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test x
MARK
test x
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test ""
MARK
test ""
cat <<RC
rc=$?
RC
cat <<'MARK'
--- test
MARK
test
cat <<RC
rc=$?
RC
