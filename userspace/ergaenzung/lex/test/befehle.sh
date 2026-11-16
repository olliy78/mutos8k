cat <<'MARK'
--- lex t1.l
MARK
lex t1.l
cat <<R
rc=$?
R
cat <<'MARK'
--- cc lex.yy.c with libl
MARK
cc -s -o scan lex.yy.c main.c yywrap.c yyless.c reject.c >/dev/null
cat <<R
rc=$?
R
cat <<'MARK'
--- scan < in.txt
MARK
./scan <in.txt
cat <<R
rc=$?
R
