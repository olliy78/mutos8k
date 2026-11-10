echo '--- tail t.txt'
tail t.txt
echo '--- tail -3 t.txt'
tail -3 t.txt
echo '--- tail +13 t.txt'
tail +13 t.txt
echo '--- tail -3 < t.txt'
tail -3 < t.txt
echo '--- cat t.txt | tail -3'
cat t.txt | tail -3
echo '--- cat t.txt | tail +14'
cat t.txt | tail +14
echo '--- tail -2r t.txt'
tail -2r t.txt
echo '--- tail -8c t.txt'
tail -8c t.txt
echo '--- tail +30c t.txt'
tail +30c t.txt
echo '--- tail -2 n.txt'
tail -2 n.txt
echo '--- tail nosuch 2>&1; echo rc=$?'
tail nosuch 2>&1; echo rc=$?
