/* callo.h -- callout table entry.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/callo.h.
 * Evidence: measured; same members in the same order (H2 file similarity 66% V7 / 88% System III PDP-11, which has the
 *           same structure with different comments); c_time 0, c_arg 2, c_func 4 measured in timeout; NCALL 9 from
 *           callout CE58..CE8E (54 bytes, 6 per entry).
 * Deviations: the table is only declared here (extern); the definition "struct callo callout[NCALL];" is in subr.c.
 */
#ifndef CALLO_H
#define CALLO_H
/*
 * The callout structure is for
 * a routine arranging
 * to be called by the clock interrupt
 * (clock.c) with a specified argument,
 * in a specified amount of time.
 * Used, for example, to time tab
 * delays on typewriters.
 */

struct	callo
{
	int	c_time;		/* incremental time */		/* +0 */
	caddr_t	c_arg;		/* argument to routine */	/* +2 */
	int	(*c_func)();	/* routine */			/* +4 */
};
extern struct callo callout[];
#endif
