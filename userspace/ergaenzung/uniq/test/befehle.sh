cat <<'MARK'
--- uniq u.txt
MARK
uniq u.txt
cat <<'MARK'
--- uniq -u u.txt
MARK
uniq -u u.txt
cat <<'MARK'
--- uniq -d u.txt
MARK
uniq -d u.txt
cat <<'MARK'
--- uniq -c u.txt
MARK
uniq -c u.txt
cat <<'MARK'
--- uniq -1 f.txt
MARK
uniq -1 f.txt
cat <<'MARK'
--- uniq +2 g.txt
MARK
uniq +2 g.txt
cat <<'MARK'
--- cat u.txt | uniq
MARK
cat u.txt | uniq
cat <<'MARK'
--- uniq u.txt o.out; cat o.out
MARK
uniq u.txt o.out; cat o.out
cat <<'MARK'
--- uniq nosuch 2>&1; rc
MARK
uniq nosuch 2>&1
cat <<RC
rc=$?
RC
