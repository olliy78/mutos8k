cat <<'MARK'
--- diff a.txt b.txt
MARK
diff a.txt b.txt
cat <<'MARK'
--- diff b.txt a.txt
MARK
diff b.txt a.txt
cat <<'MARK'
--- diff same.txt same2.txt; echo rc=$?
MARK
diff same.txt same2.txt; cat <<RC
rc=$?
RC
cat <<'MARK'
--- diff a.txt b.txt; echo rc=$?
MARK
diff a.txt b.txt; cat <<RC
rc=$?
RC
cat <<'MARK'
--- diff -e a.txt b.txt
MARK
diff -e a.txt b.txt
cat <<'MARK'
--- diff -f a.txt b.txt
MARK
diff -f a.txt b.txt
cat <<'MARK'
--- diff -b c.txt d.txt; echo rc=$?
MARK
diff -b c.txt d.txt; cat <<RC
rc=$?
RC
cat <<'MARK'
--- diff c.txt d.txt
MARK
diff c.txt d.txt
cat <<'MARK'
--- diff empty.txt c.txt
MARK
diff empty.txt c.txt
cat <<'MARK'
--- diff c.txt empty.txt
MARK
diff c.txt empty.txt
cat <<'MARK'
--- diff e.txt f.txt
MARK
diff e.txt f.txt
cat <<'MARK'
--- cat b.txt | diff a.txt -
MARK
cat b.txt | diff a.txt -
