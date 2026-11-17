cat >t1.txt <<'E'
pear
apple
banana
apple
E
cat <<'E'
--- names in /v7/bin and /v7/lib
E
ls /v7/bin /v7/lib
cat <<'E'
--- dc, bc, bc -l
E
dc <<'E2'
2 3 + p
E2
bc <<'E2'
2^10
E2
bc -l <<'E2'
scale=10
e(1)
E2
cat <<'E'
--- sed, egrep
E
sed 's/a/A/g' t1.txt
egrep 'pe|ban' t1.txt
cat <<'E'
--- m4
E
m4 <<'E2'
define(`x', `hello')x world
E2
cat <<'E'
--- tsort
E
tsort <<'E2'
a b
b c
E2
cat <<'E'
--- vmake
E
cat >mk <<'E2'
x:
	@cat t1.txt
E2
vmake -f mk
cat <<'E'
--- ranlib (no ar on this disk: error message only; function tested in erg test)
E
ranlib t1.txt 2>&1
cat <<'E'
--- yacc chain: yacc calc.y, cc, run (yaccpar from /v7/lib)
E
cat >calc.y <<'E2'
%{
#include <stdio.h>
%}
%token NUM
%left '+' '-'
%left '*' '/'
%%
lines : lines line
      |
      ;
line  : expr '\n' { printf("%d\n", $1); }
      ;
expr  : expr '+' expr { $$ = $1 + $3; }
      | expr '-' expr { $$ = $1 - $3; }
      | expr '*' expr { $$ = $1 * $3; }
      | expr '/' expr { $$ = $1 / $3; }
      | '(' expr ')' { $$ = $2; }
      | NUM
      ;
%%
yylex()
{
	int c, n;

	while ((c = getchar()) == ' ')
		;
	if (c >= '0' && c <= '9') {
		n = c - '0';
		while ((c = getchar()) >= '0' && c <= '9')
			n = n * 10 + c - '0';
		ungetc(c, stdin);
		yylval = n;
		return NUM;
	}
	if (c == EOF)
		return 0;
	return c;
}
yyerror(s)
char *s;
{
	printf("%s\n", s);
}
main()
{
	yyparse();
	return 0;
}
E2
cat >calc.in <<'E2'
1+2
2+3*4
(2+3)*4
100/7-3
E2
yacc calc.y
cc -s -o calc y.tab.c
./calc <calc.in
cat <<'E'
--- lex chain: lex, cc with /v7/lib/libl.a, run (ncform from /v7/lib)
E
cat >w.l <<'E2'
%%
[0-9]+		printf("N(%s)", yytext);
[a-z]+		printf("W(%s)", yytext);
.|\n		ECHO;
E2
cat >w.in <<'E2'
abc 12 +x
E2
lex w.l
cc -s -o scan lex.yy.c /v7/lib/libl.a
./scan <w.in
