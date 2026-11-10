yes | (read x; cat <<E
got $x
E
)
yes no | (read x; cat <<E
got $x
E
)
yes 'a b' | (read x; cat <<E
got $x
E
)
cat <<E
ende
E
