cat <<'M'
--- egrep apple g1.txt
M
egrep apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'apple|banana' g1.txt
M
egrep 'apple|banana' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep '^a' g1.txt
M
egrep '^a' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'e$' g1.txt
M
egrep 'e$' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'ab*c' g1.txt
M
egrep 'ab*c' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'a(b|X)+c' g1.txt
M
egrep 'a(b|X)+c' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'ap+le' g1.txt
M
egrep 'ap+le' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep '[a-c]an' g1.txt
M
egrep '[a-c]an' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep '[^a-z ]' g1.txt
M
egrep '[^a-z ]' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'ba?nana' g1.txt
M
egrep 'ba?nana' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep '^$' g1.txt
M
egrep '^$' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep '(an)*a' g1.txt
M
egrep '(an)*a' g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -v apple g1.txt
M
egrep -v apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -c apple g1.txt
M
egrep -c apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -n apple g1.txt
M
egrep -n apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -n -v apple g1.txt
M
egrep -n -v apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep apple g1.txt g2.txt
M
egrep apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -c apple g1.txt g2.txt
M
egrep -c apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -l apple g1.txt g2.txt
M
egrep -l apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -h apple g1.txt g2.txt
M
egrep -h apple g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -n banana g1.txt g2.txt
M
egrep -n banana g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -e -v g1.txt
M
egrep -e -v g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -f pat.txt g1.txt g2.txt
M
egrep -f pat.txt g1.txt g2.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -s apple g1.txt
M
egrep -s apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -s zebra g1.txt
M
egrep -s zebra g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep zebra g1.txt
M
egrep zebra g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep apple nonexistent
M
egrep apple nonexistent
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep apple <g1.txt
M
egrep apple <g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep -c e <g1.txt
M
egrep -c e <g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep Apple g1.txt
M
egrep Apple g1.txt
cat <<RC
rc=$?
RC
cat <<'M'
--- egrep 'a|b|c' g2.txt
M
egrep 'a|b|c' g2.txt
cat <<RC
rc=$?
RC
