cat <<M
== -n all
M
vmake -n all
cat <<M
== -n macro on the command line
M
vmake -n NAME=there show
cat <<M
== -n question-mark macro
M
vmake -n list
cat <<M
== -s -n (nothing)
M
vmake -s -n show
cat <<M
== -f Mk2, suffix substitution, several targets in one rule
M
vmake -n -f Mk2
cat <<M
== built-in suffix rule .c.o
M
vmake -n t.o
cat <<M
== run prog
M
vmake prog
cat prog
cat <<M
== prog again
M
vmake prog
cat <<M
== run all
M
vmake all
cat <<M
== -q
M
vmake -q prog
cat <<M
rc=$?
M
vmake -q show
cat <<M
rc=$?
M
cat <<M
== -t
M
vmake -t list
ls list
vmake list
cat <<M
== error stops
M
vmake bad
cat <<M
rc=$?
M
cat <<M
== -i
M
vmake -i bad
cat <<M
== ignored by -
M
vmake badi
cat <<M
== unknown target
M
vmake nosuch
cat <<M
rc=$?
M
