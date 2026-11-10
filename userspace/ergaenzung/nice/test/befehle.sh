cat <<'MARK'
--- nice cat h.txt
MARK
nice cat h.txt
cat <<'MARK'
--- nice -3 cat h.txt h.txt
MARK
nice -3 cat h.txt h.txt
cat <<'MARK'
--- nice 2>&1; rc
MARK
nice 2>&1
cat <<RC
rc=$?
RC
cat <<'MARK'
--- nice nosuchcmd 2>&1; rc
MARK
nice nosuchcmd 2>&1
cat <<RC
rc=$?
RC
