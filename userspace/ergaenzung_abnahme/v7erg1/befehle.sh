cat >t1.txt <<'E'
pear
apple
banana
apple
E
cat >t2.txt <<'E'
apple
cherry
E
cat >t3.txt <<'E'
a1
a2
a3
a4
a5
a6
a7
a8
E
cat >t4.txt <<'E'
a1
a2
a3
a5
a6
a7
a8
E
cat <<'E'
--- names in /v7/bin and /v7/lib
E
ls /v7/bin /v7/lib
cat <<'E'
--- basename
E
basename /usr/lib/x.c .c
cat <<'E'
--- tee
E
tee o1.txt <t2.txt
cat o1.txt
cat <<'E'
--- sleep, touch, yes, mesg, time, nice
E
sleep 1
touch tt.txt
ls tt.txt
yes | test 1 = 1
mesg >/dev/null 2>&1
time sort t2.txt >/dev/null 2>&1
nice sort t2.txt
cat <<'E'
--- tty
E
tty </dev/null
cat <<'E'
--- sum
E
sum t2.txt
cat <<'E'
--- rev
E
rev t2.txt
cat <<'E'
--- sort | uniq -c
E
sort t1.txt | uniq -c
cat <<'E'
--- comm -12
E
sort t1.txt >s1.txt
sort t2.txt >s2.txt
comm -12 s1.txt s2.txt
cat <<'E'
--- split -1
E
split -1 t2.txt xx
cat xxaa xxab
cat <<'E'
--- tail -1, look
E
tail -1 t1.txt
look ban s1.txt
cat <<'E'
--- cal
E
cal 2 1987
cat <<'E'
--- test, expr
E
test -f t1.txt
cat <<R
rc=$?
R
expr 2 + 3 \* 4
cat <<'E'
--- grep, fgrep
E
grep app t1.txt
fgrep cherry t2.txt
cat <<'E'
--- find
E
find /v7/lib -print
cat <<'E'
--- tr, join
E
tr a-z A-Z <t2.txt
join s1.txt s2.txt
cat <<'E'
--- diff, diff -h
E
diff t3.txt t4.txt
diff -h t3.txt t4.txt
cat <<'E'
--- du, file
E
du -a t2.txt
file t2.txt
