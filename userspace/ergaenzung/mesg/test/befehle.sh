mesg 2>/dev/console
cat <<E
abfrage r=$?
E
mesg n 2>/dev/console
cat <<E
n r=$?
E
mesg 2>/dev/console
cat <<E
abfrage r=$?
E
mesg y 2>/dev/console
cat <<E
y r=$?
E
mesg 2>/dev/console
cat <<E
abfrage r=$?
E
mesg x 2>/dev/console
cat <<E
falsch r=$?
E
