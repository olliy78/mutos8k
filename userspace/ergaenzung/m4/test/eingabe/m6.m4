define(`a', `A')dnl
define(`b', `a a')dnl
define(`c', `b b')dnl
c
define(`cat', `$1$2$3$4$5$6$7$8$9')dnl
cat(1,2,3,4,5,6,7,8,9)
define(`one_arg', `[$1]')dnl
one_arg() one_arg( ) one_arg(`  x  ')
define(`decr', `eval($1 - 1)')dnl
define(`rec', `ifelse($1, 0, done, `rec(decr($1))')')dnl
rec(10)
x1 x_y a1b2
Text with 'apostrophes' and "double quotes" and (parens), commas.
