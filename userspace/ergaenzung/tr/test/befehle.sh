cat <<'MARK'
--- tr a-z A-Z <t.txt
MARK
tr a-z A-Z <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr A-Z a-z <t.txt
MARK
tr A-Z a-z <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -d aeiou <t.txt
MARK
tr -d aeiou <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -d '0-9' <t.txt
MARK
tr -d '0-9' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -cd '0-9' <t.txt
MARK
tr -cd '0-9' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -cd '0-9\012' <t.txt
MARK
tr -cd '0-9\012' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -s ' ' ' ' <t.txt
MARK
tr -s ' ' ' ' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -s 'a-z' 'a-z' <t.txt
MARK
tr -s 'a-z' 'a-z' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -cs A-Za-z '\012' <t.txt
MARK
tr -cs A-Za-z '\012' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr abc x <t.txt
MARK
tr abc x <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr abcdef 12 <t.txt
MARK
tr abcdef 12 <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr 'lo' 'xy' <t.txt
MARK
tr 'lo' 'xy' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr '\101' 'z' <t.txt
MARK
tr '\101' 'z' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr ' ' '\012' <t.txt
MARK
tr ' ' '\012' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -c 'a-z' '_' <t.txt
MARK
tr -c 'a-z' '_' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr -c 'a-zA-Z0-9' '\012' <t.txt
MARK
tr -c 'a-zA-Z0-9' '\012' <t.txt
cat <<RC
rc=$?
RC
cat <<'MARK'
--- cat t.txt | tr a-c A-C
MARK
cat t.txt | tr a-c A-C
cat <<RC
rc=$?
RC
cat <<'MARK'
--- tr '\\' '/' <t.txt
MARK
tr '\\' '/' <t.txt
cat <<RC
rc=$?
RC
