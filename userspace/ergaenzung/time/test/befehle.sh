echo '--- time echo hi 2>t.err; echo rc=$?'
time echo hi 2>t.err; echo rc=$?
echo '--- time sh -c "exit 3" 2>t.err; echo rc=$?'
time sh -c "exit 3" 2>t.err; echo rc=$?
echo '--- time nosuchcmd 2>t.err; echo rc=$?'
time nosuchcmd 2>t.err; echo rc=$?
echo '--- time; echo rc=$?'
time; echo rc=$?
echo '--- stderr lines'
time echo hi 2>t.err
wc -l t.err
