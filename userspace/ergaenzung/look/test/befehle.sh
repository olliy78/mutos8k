cat <<'MARK'
--- look ban w.txt
MARK
look ban w.txt
cat <<'MARK'
--- look -f ban f.txt
MARK
look -f ban f.txt
cat <<'MARK'
--- look Ba w.txt
MARK
look Ba w.txt
cat <<'MARK'
--- look apple w.txt
MARK
look apple w.txt
cat <<'MARK'
--- look zebra w.txt
MARK
look zebra w.txt
cat <<'MARK'
--- look zzz w.txt
MARK
look zzz w.txt
cat <<'MARK'
--- look -t: key t.txt
MARK
look -t: key t.txt
cat <<'MARK'
--- look -d ab d.txt
MARK
look -d ab d.txt
cat <<'MARK'
--- look foo /nonexistent 2>&1; rc
MARK
look foo /nonexistent 2>&1
cat <<RC
rc=$?
RC
