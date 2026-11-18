/* as_main.c: reconstructed /usr/bin/as, original addresses 322C..35FE (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* Not V7: reconstructed from the MUTOS binary */
FILE *lstfile = stderr;
FILE *errfile = stderr;

/* Not V7: reconstructed from the MUTOS binary */
main(argc, argv)
int argc;
char **argv;
{
	register int *p;
	register int i;
	char loc1[200];
	char loc2[3202];

	bufp1 = loc2;
	bufp2 = loc1;
	bufp3 = area3;
	bufp4 = area4;
	f459c();
	f3ac8();
	args(argc, argv);
	goto first;
again:
	pass = 1;
	fseek(yyin, 0L, 0);
	for (p = (int *)symtab; p < (int *)symcur; p += 8)
		if (*p == 0x128)
			*p = 0x102;
	yylineno = 0;
first:
	for (i = 0; i < 8; i++)
		numcls[i] = '0';
	yysptr = yysbuf;
	yyparse();
	if (pass == 0)
		goto again;
	if (errcount)
		f31ba();
	f3188();
	exit(0);
}

/* Not V7: reconstructed from the MUTOS binary */
/* argument handling and opening of the files (original 32E6, 706 B) */
args(argc, argv)
int argc;
char **argv;
{
	char *p;
	char *q;

	oname = "asm.out";
	argv[argc] = 0;
	argv++;
	while (*argv && **argv == '-') {
		p = *argv++;
		for (; *p; p++) {
			switch (*p) {
			case '-':
				if (**argv)
					break;
			case 'u':
				uflag++;
				break;
			case 'd':
				yydebug++;
				break;
			case 'c':
				cflag++;
				cflag &= 1;
				break;
			case 'l':
				lflag++;
				break;
			case 'o':
				oname = *argv++;
				break;
			}
		}
	}
	close(1);
	if ((fd_o = creat(oname, 0666)) < 0) {
		fprintf(errfile, " I can not creat %s \n", oname);
		exit(1);
	}
	if ((fd_p = open(oname, 2)) < 0) {
		fprintf(errfile, " I can not open %s \n", oname);
		exit(1);
	}
	if ((fd_q = open(oname, 2)) < 0) {
		fprintf(errfile, " I can not open %s \n", oname);
		exit(1);
	}
	if ((fd_r = open(oname, 2)) < 0) {
		fprintf(errfile, " I can not open %s \n", oname);
		exit(1);
	}
	if ((fd_s = open(oname, 2)) < 0) {
		fprintf(errfile, " I can not open %s \n", oname);
		exit(1);
	}
	cp_o = fd_o;
	cp_q = fd_q;
	cp_p = fd_p;
	cp_r = fd_r;
	if (*argv) {
		if (freopen(*argv++, "r", yyin) == 0) {
			fprintf(errfile, " I can not open %s \n", argv[-1]);
			exit(1);
		}
		if (lflag) {
			p = lname;
			q = argv[-1];
			while (*p++ = *q++)
				;
			p[-1] = '.';
			*p++ = 'l';
			*p = 0;
			lstfile = fopen(lname, "w");
			if (lstfile == 0) {
				fprintf(errfile, " I can not open %s \n", lname);
				exit(1);
			}
			errfile = lstfile;
			f1bda();
			fprintf(lstfile, "\nPLZ/ASM  -  ASSEMBLER\t\tV 1.0\t%s\n", argv[-1]);
		}
	}
}

/* Not V7: reconstructed from the MUTOS binary */
/* error message: counts the error, prints module name, line number and text (original 35A8, 86 B) */
error(s)
char *s;
{
	errcount++;
	fprintf(errfile, "\n %s : ", curname);
	fprintf(errfile, "  line: %d. ", yylineno);
	fprintf(errfile, " %s \n", s);
	return (0);
}

/* Not V7: reconstructed from the MUTOS binary */
defla()
{
	error("defla not implemented");
}

/* TEMPORARY STUB for the function at 35FE (original 35FE) */
f35fe()
{
	return (0);
}
