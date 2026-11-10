cd /tmp
mkdir td
cd td
touch -c n1
touch a
touch -c a
ls
echo hi > h
touch h
cat h
touch -c nofile 2>&1
cd /tmp
mkdir td2
cd td2
echo old > old
sleep 2
echo new > new
ls -t
touch old
ls -t
cd /tmp
