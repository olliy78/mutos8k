touch -c tn1
touch ta
touch -c ta
ls t[an]*
cat > th <<E
hi
E
touch th
cat th
touch -c nofile 2>&1
cat > told <<E
old
E
sleep 2
cat > tnew <<E
new
E
ls -t told tnew
touch told
ls -t told tnew
