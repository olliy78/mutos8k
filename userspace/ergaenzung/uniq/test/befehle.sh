echo '--- uniq u.txt'
uniq u.txt
echo '--- uniq -u u.txt'
uniq -u u.txt
echo '--- uniq -d u.txt'
uniq -d u.txt
echo '--- uniq -c u.txt'
uniq -c u.txt
echo '--- uniq -1 f.txt'
uniq -1 f.txt
echo '--- uniq +2 g.txt'
uniq +2 g.txt
echo '--- cat u.txt | uniq'
cat u.txt | uniq
echo '--- uniq u.txt o.out; cat o.out'
uniq u.txt o.out; cat o.out
echo '--- uniq nosuch 2>&1; echo rc=$?'
uniq nosuch 2>&1; echo rc=$?
