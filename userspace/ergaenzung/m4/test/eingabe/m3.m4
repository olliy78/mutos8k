eval(1+2*3) eval((1+2)*3) eval(7/2) eval(-7/2) eval(10%3) eval(2^10) eval(2**3)
eval(1<2) eval(2<1) eval(2<=2) eval(3>=4) eval(1==1) eval(1!=1) eval(!0) eval(!5)
eval(1&&0) eval(1||0) eval(1&0) eval(3|0) eval(-3+5) eval(- -3) eval(100000*20000)
eval(  8 / 2 / 2 ) eval(2+3 == 5)
define(`fact', `ifelse($1, 0, 1, `eval($1 * fact(eval($1 - 1)))')')dnl
fact(5) fact(7)
define(`loop', `ifelse(eval($1 > 0), 1, `$1 loop(eval($1 - 1))')')dnl
loop(5)
