echo '--- test a = a'
test a = a
echo rc=$?
echo '--- test a = b'
test a = b
echo rc=$?
echo '--- test a != b'
test a != b
echo rc=$?
echo '--- test -n x'
test -n x
echo rc=$?
echo '--- test -z ""'
test -z ""
echo rc=$?
echo '--- test -z x'
test -z x
echo rc=$?
echo '--- test -f t.txt'
test -f t.txt
echo rc=$?
echo '--- test -f nosuch'
test -f nosuch
echo rc=$?
echo '--- test -d /tmp'
test -d /tmp
echo rc=$?
echo '--- test -d t.txt'
test -d t.txt
echo rc=$?
echo '--- test -r t.txt'
test -r t.txt
echo rc=$?
echo '--- test -w t.txt'
test -w t.txt
echo rc=$?
echo '--- test -s t.txt'
test -s t.txt
echo rc=$?
echo '--- test -s empty'
test -s empty
echo rc=$?
echo '--- test 3 -lt 5'
test 3 -lt 5
echo rc=$?
echo '--- test 5 -lt 3'
test 5 -lt 3
echo rc=$?
echo '--- test 10 -eq 10'
test 10 -eq 10
echo rc=$?
echo '--- test 10 -ne 10'
test 10 -ne 10
echo rc=$?
echo '--- test 7 -ge 7'
test 7 -ge 7
echo rc=$?
echo '--- test 7 -gt 7'
test 7 -gt 7
echo rc=$?
echo '--- test ! -f nosuch'
test ! -f nosuch
echo rc=$?
echo '--- test -f t.txt -a -d /tmp'
test -f t.txt -a -d /tmp
echo rc=$?
echo '--- test -f nosuch -o -d /tmp'
test -f nosuch -o -d /tmp
echo rc=$?
echo '--- test -f nosuch -a -d /tmp'
test -f nosuch -a -d /tmp
echo rc=$?
echo '--- test \( -n x \)'
test \( -n x \)
echo rc=$?
echo '--- test x'
test x
echo rc=$?
echo '--- test ""'
test ""
echo rc=$?
echo '--- test'
test
echo rc=$?
