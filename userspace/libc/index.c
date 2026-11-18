/*
 * Return the ptr in sp at which the character c appears;
 * NULL if not found
 */

#define	NULL	0

char *
index(sp, c)
register char *sp;
char c;   /* Differs from V7: not a register variable (the shipped object keeps c on the stack) */
{
	do {
		if (*sp == c)
			return(sp);
	} while (*sp++);
	return(NULL);
}
