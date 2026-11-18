/*
 * Return the ptr in sp at which the character c last
 * appears; NULL if not found
*/

#define NULL 0

char *
rindex(sp, c)
register char *sp;
char c;   /* Differs from V7: not a register variable (the shipped object keeps c on the stack) */
{
	register char *r;

	r = NULL;
	do {
		if (*sp == c)
			r = sp;
	} while (*sp++);
	return(r);
}
