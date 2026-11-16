cat <<'M'
--- expr 2 + 3
M
expr 2 + 3
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 10 - 4
M
expr 10 - 4
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 6 '*' 7
M
expr 6 '*' 7
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 17 / 5
M
expr 17 / 5
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 17 % 5
M
expr 17 % 5
cat <<RC
rc=$?
RC
cat <<'M'
--- expr '(' 2 + 3 ')' '*' 4
M
expr '(' 2 + 3 ')' '*' 4
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 2 + 3 '*' 4
M
expr 2 + 3 '*' 4
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 100 / 7 / 2
M
expr 100 / 7 / 2
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 2 '*' 3 '*' 4 - 1
M
expr 2 '*' 3 '*' 4 - 1
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 3 '<' 5
M
expr 3 '<' 5
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 5 '<' 3
M
expr 5 '<' 3
cat <<RC
rc=$?
RC
cat <<'M'
--- expr abc '=' abc
M
expr abc '=' abc
cat <<RC
rc=$?
RC
cat <<'M'
--- expr abc '!=' abd
M
expr abc '!=' abd
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 5 '>' 3
M
expr 5 '>' 3
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 5 '>=' 5
M
expr 5 '>=' 5
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 10 '>' 9
M
expr 10 '>' 9
cat <<RC
rc=$?
RC
cat <<'M'
--- expr abc '<' abd
M
expr abc '<' abd
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 7 '==' 7
M
expr 7 '==' 7
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 0 '|' 7
M
expr 0 '|' 7
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 0 '|' 0
M
expr 0 '|' 0
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 5 '|' 7
M
expr 5 '|' 7
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 5 '&' 0
M
expr 5 '&' 0
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 5 '&' 7
M
expr 5 '&' 7
cat <<RC
rc=$?
RC
cat <<'M'
--- expr abc : 'a\(.*\)'
M
expr abc : 'a\(.*\)'
cat <<RC
rc=$?
RC
cat <<'M'
--- expr hello : '.*'
M
expr hello : '.*'
cat <<RC
rc=$?
RC
cat <<'M'
--- expr hello : 'h'
M
expr hello : 'h'
cat <<RC
rc=$?
RC
cat <<'M'
--- expr hello : 'e'
M
expr hello : 'e'
cat <<RC
rc=$?
RC
cat <<'M'
--- expr hello : 'hel\(l\)o'
M
expr hello : 'hel\(l\)o'
cat <<RC
rc=$?
RC
cat <<'M'
--- expr length hello
M
expr length hello
cat <<RC
rc=$?
RC
cat <<'M'
--- expr substr hello 2 3
M
expr substr hello 2 3
cat <<RC
rc=$?
RC
cat <<'M'
--- expr substr hello 1 1
M
expr substr hello 1 1
cat <<RC
rc=$?
RC
cat <<'M'
--- expr substr abc 2 10
M
expr substr abc 2 10
cat <<RC
rc=$?
RC
cat <<'M'
--- expr index hello l
M
expr index hello l
cat <<RC
rc=$?
RC
cat <<'M'
--- expr index hello xyz
M
expr index hello xyz
cat <<RC
rc=$?
RC
cat <<'M'
--- expr match hello 'h.*'
M
expr match hello 'h.*'
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 0
M
expr 0
cat <<RC
rc=$?
RC
cat <<'M'
--- expr ''
M
expr ''
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 42
M
expr 42
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 2 +
M
expr 2 +
cat <<RC
rc=$?
RC
cat <<'M'
--- expr a + 1
M
expr a + 1
cat <<RC
rc=$?
RC
cat <<'M'
--- expr 
M
expr 
cat <<RC
rc=$?
RC
cat <<'M'
--- V7 quirk: expr 3 '<=' 5 (LEQ tests i>=0)
M
expr 3 '<=' 5
cat <<RC
rc=$?
RC
