cat <<'MARK'
--- tail t.txt
MARK
tail t.txt
cat <<'MARK'
--- tail -3 t.txt
MARK
tail -3 t.txt
cat <<'MARK'
--- tail +13 t.txt
MARK
tail +13 t.txt
cat <<'MARK'
--- tail -3 < t.txt
MARK
tail -3 < t.txt
cat <<'MARK'
--- cat t.txt | tail -3
MARK
cat t.txt | tail -3
cat <<'MARK'
--- cat t.txt | tail +14
MARK
cat t.txt | tail +14
cat <<'MARK'
--- tail -2r t.txt
MARK
tail -2r t.txt
cat <<'MARK'
--- tail -8c t.txt
MARK
tail -8c t.txt
cat <<'MARK'
--- tail +30c t.txt
MARK
tail +30c t.txt
cat <<'MARK'
--- tail -2 n.txt
MARK
tail -2 n.txt
cat <<'MARK'
--- tail nosuch 2>&1; rc
MARK
tail nosuch 2>&1
cat <<RC
rc=$?
RC
