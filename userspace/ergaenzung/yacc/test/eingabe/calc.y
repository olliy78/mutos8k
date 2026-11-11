%{
#include <stdio.h>
%}
%token NUMBER
%left '+' '-'
%left '*' '/'
%right UMINUS
%%
lines	: lines line
	|
	;
line	: expr '\n'		{ printf("%d\n", $1); }
	| error '\n'		{ yyerrok; }
	;
expr	: expr '+' expr		{ $$ = $1 + $3; }
	| expr '-' expr		{ $$ = $1 - $3; }
	| expr '*' expr		{ $$ = $1 * $3; }
	| expr '/' expr		{ $$ = $1 / $3; }
	| '(' expr ')'		{ $$ = $2; }
	| '-' expr %prec UMINUS	{ $$ = -$2; }
	| NUMBER
	;
%%
yylex()
{
	register c;

	while ((c = getchar()) == ' ')
		;
	if (c >= '0' && c <= '9') {
		yylval = c - '0';
		while ((c = getchar()) >= '0' && c <= '9')
			yylval = yylval * 10 + c - '0';
		ungetc(c, stdin);
		return (NUMBER);
	}
	if (c == EOF)
		return (0);
	return (c);
}

yyerror(s)
char *s;
{
	printf("error\n");
}

main()
{
	return (yyparse());
}
