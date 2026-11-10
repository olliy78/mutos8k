rev r1
rev r2
rev r1 r2
rev < r2
rev nofile 2>&1
cat <<E
r=$?
E
