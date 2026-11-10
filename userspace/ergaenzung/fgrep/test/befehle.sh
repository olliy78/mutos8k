cat <<'MARK'
--- fgrep apple g1.txt
MARK
fgrep apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -n apple g1.txt
MARK
fgrep -n apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -v apple g1.txt
MARK
fgrep -v apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -c apple g1.txt
MARK
fgrep -c apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -l apple g1.txt g2.txt
MARK
fgrep -l apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep apple g1.txt g2.txt
MARK
fgrep apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -h apple g1.txt g2.txt
MARK
fgrep -h apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -x 'grape jelly' g1.txt
MARK
fgrep -x 'grape jelly' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -x grape g1.txt
MARK
fgrep -x grape g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep 'ab*c' g1.txt
MARK
fgrep 'ab*c' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep 'a.c' g1.txt
MARK
fgrep 'a.c' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -f pat.txt g1.txt
MARK
fgrep -f pat.txt g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -e -v g1.txt
MARK
fgrep -e -v g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep zzz g1.txt
MARK
fgrep zzz g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep -s zzz g1.txt
MARK
fgrep -s zzz g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- cat g1.txt | fgrep jelly
MARK
cat g1.txt | fgrep jelly
cat <<RC
rc=$?
RC
cat <<'MARK'
--- fgrep apple nosuch 2>&1
MARK
fgrep apple nosuch 2>&1
cat <<RC
rc=$?
RC
