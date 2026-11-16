cc -c a.c
cc -c b.c
ar r lib.a a.o b.o
cat <<'M'
--- members before ranlib
M
ar t lib.a
ranlib lib.a
cat <<RC
rc=$?
RC
cat <<'M'
--- members after ranlib
M
ar t lib.a
ranlib lib.a
cat <<'M'
--- members after a second ranlib
M
ar t lib.a
cat <<'M'
--- table content
M
ar x lib.a __.SYMDEF
cat __.SYMDEF
cat <<'M'

--- link pulls fb out of the archive
M
cc -c m.c
cc -s -o m m.o lib.a
./m
cat <<'M'
--- not an archive, missing file
M
ranlib m.c nonexistent
cat <<RC
rc=$?
RC
