sum sa.txt
sum sa.txt sb.txt
sum < sa.txt
sum nofile 2>&1
cat <<E
r=$?
E
