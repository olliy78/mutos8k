cat <<'MARK'
--- du -a s0 s1 s512 s513 s1000 s5000
MARK
du -a s0 s1 s512 s513 s1000 s5000
cat <<RC
rc=$?
RC
cat <<'MARK'
--- du -s s1000 s5000
MARK
du -s s1000 s5000
cat <<RC
rc=$?
RC
cat <<'MARK'
--- du -a s513
MARK
du -a s513
cat <<RC
rc=$?
RC
cat <<'MARK'
--- du s1000
MARK
du s1000
cat <<RC
rc=$?
RC
cat <<'MARK'
--- du nosuch 2>&1
MARK
du nosuch 2>&1
cat <<RC
rc=$?
RC
