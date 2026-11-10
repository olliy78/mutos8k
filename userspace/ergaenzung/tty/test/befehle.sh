tty < /dev/null
cat <<E
r=$?
E
tty -s < /dev/null
cat <<E
r=$?
E
