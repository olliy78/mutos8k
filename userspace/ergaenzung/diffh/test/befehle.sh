cat <<'MARK'
--- diffh same.txt same2.txt; echo rc=$?
MARK
diffh same.txt same2.txt; cat <<RC
rc=$?
RC
cat <<'MARK'
--- diffh e.txt g.txt
MARK
diffh e.txt g.txt
cat <<'MARK'
--- diffh g.txt e.txt
MARK
diffh g.txt e.txt
