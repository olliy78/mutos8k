cat <<'M'
--- chain (file argument)
M
tsort chain
cat <<RC
rc=$?
RC
cat <<'M'
--- dag from stdin, duplicates and self pair
M
tsort <dag
cat <<RC
rc=$?
RC
cat <<'M'
--- single node
M
tsort solo
cat <<'M'
--- cycle (stdout only, message on stderr)
M
tsort cycle
cat <<RC
rc=$?
RC
cat <<'M'
--- odd data
M
tsort odd
cat <<RC
rc=$?
RC
cat <<'M'
--- missing file
M
tsort nonexistent
cat <<RC
rc=$?
RC
