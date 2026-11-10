cat <<'MARK'
--- file c.txt asm.txt short.txt english.txt garb.txt
MARK
file c.txt asm.txt short.txt english.txt garb.txt
cat <<'MARK'
--- file nosuch /
MARK
file nosuch /
cat <<'MARK'
--- file /bin/cat /usr/lib/libc.a
MARK
file /bin/cat /usr/lib/libc.a
cat <<'MARK'
--- file -f lst.txt; rc
MARK
file -f lst.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- file -f nosuch.lst 2>&1; rc
MARK
file -f nosuch.lst 2>&1
cat <<RC
rc=$?
RC
