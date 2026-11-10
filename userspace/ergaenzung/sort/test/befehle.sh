cat <<'MARK'
--- sort s1.txt
MARK
sort s1.txt
cat <<'MARK'
--- sort -r s1.txt
MARK
sort -r s1.txt
cat <<'MARK'
--- sort -u s1.txt
MARK
sort -u s1.txt
cat <<'MARK'
--- sort -f s1.txt
MARK
sort -f s1.txt
cat <<'MARK'
--- sort -d s1.txt
MARK
sort -d s1.txt
cat <<'MARK'
--- sort -n s2.txt
MARK
sort -n s2.txt
cat <<'MARK'
--- sort -nr s2.txt
MARK
sort -nr s2.txt
cat <<'MARK'
--- sort -t: +1n s3.txt
MARK
sort -t: +1n s3.txt
cat <<'MARK'
--- sort -t: +1 -2 s3.txt
MARK
sort -t: +1 -2 s3.txt
cat <<'MARK'
--- sort -t: +0 -1 -r s3.txt
MARK
sort -t: +0 -1 -r s3.txt
cat <<'MARK'
--- sort -f s4.txt
MARK
sort -f s4.txt
cat <<'MARK'
--- sort s5.txt s6.txt
MARK
sort s5.txt s6.txt
cat <<'MARK'
--- sort -m s5.txt s6.txt
MARK
sort -m s5.txt s6.txt
cat <<'MARK'
--- cat s1.txt | sort
MARK
cat s1.txt | sort
cat <<'MARK'
--- sort - s5.txt < s6.txt
MARK
sort - s5.txt < s6.txt
cat <<'MARK'
--- sort -o o1.txt s1.txt; cat o1.txt
MARK
sort -o o1.txt s1.txt; cat o1.txt
cat <<'MARK'
--- sort s7.txt
MARK
sort s7.txt
cat <<'MARK'
--- sort -c s5.txt; echo rc=$?
MARK
sort -c s5.txt; cat <<RC
rc=$?
RC
