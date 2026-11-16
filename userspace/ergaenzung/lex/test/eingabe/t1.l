D	[0-9]
%Start CMT
%%
"/*"			BEGIN CMT;
<CMT>"*/"		BEGIN 0;
<CMT>[^*]+		;
^#.*$			printf("PP");
foo[a-z]*		{ yyless(3); printf("F(%s)", yytext); }
abc			{ printf("A"); REJECT; }
[a-z]+			printf("W(%s)", yytext);
{D}+			printf("N(%s)", yytext);
{D}+"."{D}*		printf("R(%s)", yytext);
[-+*]			printf("O(%c)", yytext[0]);
"<"[a-z]+">"/";"	printf("T(%s)", yytext);
\n			ECHO;
[ \t]+			ECHO;
.			printf("?%c", yytext[0]);
