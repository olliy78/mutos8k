cat <<'MARK'
--- grep apple g1.txt
MARK
grep apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -n apple g1.txt
MARK
grep -n apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -v apple g1.txt
MARK
grep -v apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -c apple g1.txt
MARK
grep -c apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -y apple g1.txt
MARK
grep -y apple g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -l apple g1.txt g2.txt
MARK
grep -l apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep apple g1.txt g2.txt
MARK
grep apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -h apple g1.txt g2.txt
MARK
grep -h apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep '^[Bb]anana' g1.txt
MARK
grep '^[Bb]anana' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep 'e$' g1.txt
MARK
grep 'e$' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep 'ab*c' g1.txt
MARK
grep 'ab*c' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep 'a.*c' g1.txt
MARK
grep 'a.*c' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep '^$' g1.txt
MARK
grep '^$' g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -e -v g1.txt
MARK
grep -e -v g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -s apple nosuch
MARK
grep -s apple nosuch
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep -s zzz g1.txt
MARK
grep -s zzz g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- grep zzz g1.txt
MARK
grep zzz g1.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- cat g1.txt | grep jelly
MARK
cat g1.txt | grep jelly
cat <<RC
rc=$?
RC
