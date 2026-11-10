cat <<'MARK'
--- time cat h.txt 2>t.err; rc
MARK
time cat h.txt 2>t.err
cat <<RC
rc=$?
RC
cat <<'MARK'
--- time sh -c "exit 3" 2>t.err; rc
MARK
time sh -c "exit 3" 2>t.err
cat <<RC
rc=$?
RC
cat <<'MARK'
--- time nosuchcmd 2>t.err; rc
MARK
time nosuchcmd 2>t.err
cat <<RC
rc=$?
RC
cat <<'MARK'
--- time; rc
MARK
time
cat <<RC
rc=$?
RC
