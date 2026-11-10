cd /tmp
yes | dd bs=10 count=1 2>/dev/null
echo
yes no | dd bs=9 count=1 2>/dev/null
echo ende
