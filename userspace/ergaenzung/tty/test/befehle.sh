cd /tmp
tty < /dev/null
echo r=$?
tty -s < /dev/null
echo r=$?
