/* clock.c -- clock interrupt (kernel mutos_1216, 2842..2A4C): clock.  timeout (2A4C) is in subr.c (it sits behind clock in the kernel).
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/sys/clock.c (clock): callout list, user/system time, lbolt/time, the per-process once-a-second loop
 *           with p_cpu = p_cpu*SCHMAG + p_nice - NZERO (SCHMAG 8/10), p_clktim alarm, setpri, runin wakeup.  System III
 *           PDP-11 uts/os/clock.c has a different once-a-second loop (p_cpu >>= 1, no SCHMAG); not used.
 *           Closest known relative: TUHS collection Research/Torsten_Hippe_v7 (assembled 1995 from unknown sources; not the
 *           author) - matches proctop (PROC_MAX) in the once-a-second loop (fremd.md 4.1 no. 9).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): clock 64% V7 / 41% System III PDP-11 (before the
 *           restoration; the earlier file header said "System III form (WEGA)": wrong, the decay is V7).  The signal name
 *           SIGALRM is the System III spelling of V7 SIGCLK (both 14).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/clock.md.  Not bytegleich (before and after).
 * Deviations: the Z8001 interrupt entry passes the saved registers and the frame as arguments; the interrupt may stand for
 *           several ticks (t = tk >> 8); no display(), no dk_time[], no clock restart (lks); the MUTOS once-a-second block wakes
 *           the scheduler through sflag0/sflag1 (see slp.c); proctop instead of &proc[NPROC].
 *
 * The interrupt entry hands over (argument words): 4 dev, 6 ticks (upper half of the word), 1A priority of the interrupted code
 * (and 7 = not nested), 1C FCW (4000 = system mode), 20 PC.
 * Data: cf_x88a (888A, conf.c), sflag0/sflag1 (8DE0/8DE2, slp.c), runin 8DD6, runout 8DD8, runrun 8DC4, lbolt 8DCA, time 8DCC. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "callo.h"

#define	SCHMAG	8/10

extern int cf_x88a, sflag0, sflag1;

/*
 * clock is called straight from
 * the real time clock interrupt.
 *
 * Functions:
 *	implement callouts
 *	maintain user/system times
 *	maintain date
 *	profile
 *	lightning bolt wakeup (every second)
 *	alarm clock signals
 *	jab the scheduler
 */

/* KERNEL 2842 */
clock(dev, tk, f2, f3, f4, f5, f6, f7, f8, f9, f10, ps0, ps, pcseg, pc)
unsigned tk;
{
	register struct callo *p1, *p2;
	register struct proc *pp;
	register n;
	register t;
	int a;

	t = tk >> 8;	/* MUTOS: number of ticks this interrupt stands for (V7: one) */
	/*
	 * callouts
	 * if none, just continue
	 * else update first non-zero time
	 */
	if (callout[0].c_func) {
		n = t;
		p2 = &callout[0];
		do {
			while (p2->c_time <= 0 && p2->c_func)
				p2++;
			p2->c_time--;
		} while (--n > 0);
		/*
		 * if ps is high, just return from the callout part
		 * MUTOS: ps0 & 07 is the priority of the interrupted code (V7 BASEPRI(ps))
		 */
		if ((ps0 & 07) == 0) {
			/*
			 * callout
			 */
			spl5();
			if (callout[0].c_time <= 0) {
				p1 = &callout[0];
				while (p1->c_func != 0 && p1->c_time <= 0) {
					(*p1->c_func)(p1->c_arg);
					p1++;
				}
				p2 = &callout[0];
				while (p2->c_func = p1->c_func) {
					p2->c_time = p1->c_time;
					p2->c_arg = p1->c_arg;
					p1++;
					p2++;
				}
			}
		}
	}
	/*
	 * lightning bolt time-out
	 * and time of day
	 */
	if ((ps & 0x4000) == 0) {	/* V7 USERMODE(ps) */
		u.u_utime += t;
		if (u.u_prof.pr_scale)
			addupc(pc, &u.u_prof, t);
	} else
		u.u_stime += t;
	pp = u.u_procp;
	if (++pp->p_cpu == 0)	/* V7: if(++pp->p_cpu == 0) */
		pp->p_cpu--;
	lbolt += t;
	if (lbolt >= HZ) {
		if (ps0 & 07)	/* V7 BASEPRI(ps) */
			return;
		lbolt -= HZ;
		++time;
		spl1();
		/* MUTOS: every 30 s (and cf_x88a set) the scheduler is told through sflag1/runout to run update(), see sched in slp.c; not in V7 */
		if (++sflag0 >= 30 && cf_x88a) {
			++sflag1;
			if (runout) {
				runout = 0;
				wakeup((caddr_t)&runout);
			}
		}
		runrun++;
		wakeup((caddr_t)&lbolt);
		for (pp = &proc[0]; pp <= proctop; pp++)
			if (pp->p_stat && pp->p_stat < SZOMB) {
				if (pp->p_time != 127)
					pp->p_time++;
				if (pp->p_clktim)
					if (--pp->p_clktim == 0)
						psignal(pp, SIGCLK);
				a = (pp->p_cpu & 0377) * SCHMAG + pp->p_nice - NZERO;
				if (a < 0)
					a = 0;
				if (a > 255)
					a = 255;
				pp->p_cpu = a;
				if (pp->p_pri >= PUSER)
					setpri(pp);
			}
		if (runin != 0) {
			runin = 0;
			wakeup((caddr_t)&runin);
		}
	}
}
