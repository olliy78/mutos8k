/* as_misc.c: reconstructed /usr/bin/as, original addresses 167A..1BDA (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* TEMPORARY STUB for the function at 167A (original 167A) */
f167a()
{
	return (0);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* labsym (original 16A0): symbol for token T of the cell A.  T = 0x125 (numeric label reference): the symbol "#%6d" of the
   number is allocated (pass 1) or looked up (pass 2).  Otherwise, in pass 1 only: T = 0x1B marks the cell (bit 5) while
   g8d06 is 14 or 6; T = ':' sets the value to g9046 and the type bits (bit 0 if g90ce, else g90d0).  Returns the cell. */
labsym(a, t)
register struct sym *a;
register int t;
{
	register struct sym *sp;
	char buf[8];

	sp = a;
	if (t == 0x125) {
		t = a->s_x;
		sprintf(buf, "#%6d", t);
		if (pass == 0) {
			sp = (struct sym *)symadd(30);
			sp->s_v = g9046;
			sp->s_t = 2;
		} else {
			sp = (struct sym *)symget(30);
			iniobj();
		}
		return ((int)sp);
	}
	if (pass)
		return ((int)sp);
	if (t == 0x1B) {
		if (g8d06 == 14 || g8d06 == 6)
			a->s_t |= 32;
		return ((int)sp);
	}
	if (t != ':')
		return ((int)sp);
	sp->s_v = g9046;
	if (g90ce)
		sp->s_t |= 1;
	else
		sp->s_t |= g90d0;
	return ((int)sp);
}

/* TEMPORARY STUB for the function at 174A (original 174A) */
f174a()
{
	return (0);
}

/* TEMPORARY STUB for the function at 181A (original 181A) */
f181a()
{
	return (0);
}

/* TEMPORARY STUB for the function at 191A (original 191A) */
f191a()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1938 (original 1938) */
f1938()
{
	return (0);
}

/* TEMPORARY STUB for the function at 19DA (original 19DA) */
f19da()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1A1E (original 1A1E) */
f1a1e()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1A54 (original 1A54) */
f1a54()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1A86 (original 1A86) */
f1a86()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1AB6 (original 1AB6) */
f1ab6()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1B2A (original 1B2A) */
f1b2a()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1B82 (original 1B82) */
f1b82()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1BDA (original 1BDA) */
f1bda()
{
	return (0);
}
