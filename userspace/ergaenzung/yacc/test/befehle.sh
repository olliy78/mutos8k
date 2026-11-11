yacc -vd calc.y && cat y.tab.h && cc -s -o calc y.tab.c && ./calc <in.txt
