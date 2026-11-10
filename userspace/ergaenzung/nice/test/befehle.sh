echo '--- nice echo hi'
nice echo hi
echo '--- nice -3 echo hi'
nice -3 echo hi
echo '--- nice -3 echo a b c'
nice -3 echo a b c
echo '--- nice 2>&1; echo rc=$?'
nice 2>&1; echo rc=$?
echo '--- nice nosuchcmd 2>&1; echo rc=$?'
nice nosuchcmd 2>&1; echo rc=$?
