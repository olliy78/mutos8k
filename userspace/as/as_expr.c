/* as_expr.c: reconstructed /usr/bin/as, original addresses 3620..3AC8 (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* exprdo (original 3620): evaluates the operation OP on the value cells A and B (B == 0: unary); A is the result, B is
   marked free.  Cell: o_val = value (long), o_ref = relocation reference (0 = absolute).  The original cc compiles the switch
   through a 3-bucket hash (op / 3 compared, op % 3 selects the chain: measured from the table at 6C06), so the case values
   are plain numbers: the ASCII operators, 0x11E..0x124 (Annahme: | &~ & % << >> ~ of the grammar) and 0x3D3B, 0x3D3E
   (Annahme: <= and >=). */
struct obj *exprdo(a, op, b)
register struct obj *a;
register int op;
register struct obj *b;
{
	register int *r1, *r2;

	if (b == 0) {
		if (op != '+' && a->o_ref)
			error("illegal expression");
		switch (op) {
		case '+':
			return (a);
		case '-':
			a->o_val = -a->o_val;
			return (a);
		case 0x124:
			a->o_val = ~a->o_val;
			return (a);
		}
		error("unimplemented operation in exprdo");
		b->o_t = -1;	/* the original really stores through the null pointer here */
		return (a);
	}
	if (op != '-' && op != '+' && a->o_ref)
		error("illegal expression");
	switch (op) {
	case '*':
		a->o_val = a->o_val * b->o_val;
		break;
	case '+':
		if (a->o_ref && b->o_ref)
			error("illegal expression");
		a->o_val += b->o_val;
		if (a->o_ref == 0)
			a->o_ref = b->o_ref;
		break;
	case '-':
		a->o_val -= b->o_val;
		if (a->o_ref && b->o_ref) {
			r1 = (int *)a->o_ref;
			r2 = (int *)b->o_ref;
			if (*r1 != *r2)
				error("illegal expr");
			else
				a->o_ref = 0;
		}
		break;
	case '/':
		a->o_val = a->o_val / b->o_val;
		break;
	case '<':
		a->o_val = a->o_val < b->o_val;
		break;
	case '=':
		a->o_val = a->o_val == b->o_val;
		break;
	case '>':
		a->o_val = a->o_val > b->o_val;
		break;
	case 0x11E:
		a->o_val = a->o_val | b->o_val;
		break;
	case 0x11F:
		a->o_val = a->o_val & ~b->o_val;
		break;
	case 0x120:
		a->o_val = a->o_val & b->o_val;
		break;
	case 0x121:
		a->o_val = a->o_val % b->o_val;
		break;
	case 0x122:
		a->o_val = a->o_val << (int)b->o_val;
		break;
	case 0x123:
		a->o_val = a->o_val >> (int)b->o_val;
		break;
	case 0x3D3B:
		a->o_val = a->o_val <= b->o_val;
		break;
	case 0x3D3E:
		a->o_val = a->o_val >= b->o_val;
		break;
	default:
		error("unimplemented operation in exprdo");
	}
	b->o_t = -1;
	return (a);
}

/* TEMPORARY STUB for the function at 3844 (original 3844) */
f3844()
{
	return (0);
}

/* TEMPORARY STUB for the function at 38B6 (original 38B6) */
f38b6()
{
	return (0);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* symout (original 3988): write the 12-byte record of the symbol cell SP to the file fd_s: 8 name characters (7 bits),
   type byte, 0, value (bytes swapped with cflag).  Number -1 counts as 0; type 0x20: the number is the value. */
struct orec { char or_nm[8]; char or_t; char or_z; int or_v; int or_x; };

symout(sp)
register struct sym *sp;
{
	struct orec rec;
	register char *d;
	register char *s;
	register int i;

	d = rec.or_nm;
	s = sp->s_name;
	for (i = 0; i < 8; i++)
		*d++ = *s++ & 0177;
	rec.or_t = sp->s_t;
	rec.or_v = sp->s_v;
	rec.or_x = sp->s_x;
	if (rec.or_x == -1)
		rec.or_x = 0;
	if (sp->s_t == 32)
		rec.or_v = rec.or_x;
	rec.or_z = 0;
	swabw(2, &rec.or_v);
	owrite(fd_s, &rec, 12);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* upname (original 3A18): the token text yytext in upper case, in ucbuf; returns ucbuf */
char *upname()
{
	register char *d, *sp;
	register int c;

	d = ucbuf;
	sp = yytext;
	while (c = *sp++ & 0377)
		*d++ = (c <= 'z' && c >= 'a') ? c - 32 : c;
	*d = 0;
	return (ucbuf);
}

/* upstr (original 3A5A, lies behind 3A18 without a stub of its own): as upname, for the string S */
char *upstr(s)
char *s;
{
	register char *d, *sp;
	register int c;

	d = ucbuf;
	sp = s;
	while (c = *sp++ & 0377)
		*d++ = (c <= 'z' && c >= 'a') ? c - 32 : c;
	*d = 0;
	return (ucbuf);
}

/* Not V7: reconstructed from the MUTOS binary */
/* debug message to stderr (original 3A9C, called from the parser and the scanner) */
prmsg(s)
char *s;
{
	fprintf(stderr, "%s \n", s);
}

/* Not V7: reconstructed from the MUTOS binary */
/* yyerror of the generated parser: reports through error() (original 3AB6) */
yyerror(s)
char *s;
{
	error(s);
}

/* TEMPORARY STUB for the function at 3AC8 (original 3AC8) */
f3ac8()
{
	return (0);
}
