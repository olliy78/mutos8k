#
/*
 * TEMPORARY STUB (part one of the c2 reconstruction): only so that c20.c links.
 * The real c21.c (rmove .. mkshift, 0x151E..0x3590 in the binary) is part two.
 */

#include "c2.h"

rmove()
{
}

addsob()
{
}

clearreg()
{
}

toofar(p, flag)
struct node *p;
{
	return(1);
}

equop(p1, p2)
struct node *p1, *p2;
{
	return(0);
}

decref(p)
struct node *p;
{
}

struct node *
nonlab(p)
struct node *p;
{
	return(p);
}

char *
alloc(n)
{
	return(sbrk(n));
}

equstr(p1, p2)
char *p1, *p2;
{
	return(0);
}

delnode(p)
struct node *p;
{
}
