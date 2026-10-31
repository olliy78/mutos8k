/* timeb.h -- structure returned by the ftime system call.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/timeb.h.
 * Evidence: V7 text; the old local declaration in sys4.c had the same members (time_t, unsigned, short, short; 10 bytes).
 * Deviations: include guard only.
 */
#ifndef TIMEB_H
#define TIMEB_H
/*
 * Structure returned by ftime system call
 */
struct timeb {
	time_t	time;
	unsigned short millitm;
	short	timezone;
	short	dstflag;
};
#endif
