/* machdep.c -- machine dependent code in C (kernel mutos_1216, 34F6..36A0): startup, one RET stub, sendsig, sigret.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/sys/machdep.c, only in the skeleton: startup (memory sizing loop "zero and free all of core", message
 *           "mem = %D"), sendsig (push PC and PS on the user stack, set the new PC).  Both are rewritten for the Z8001
 *           (segmented memory probed through usegm, no UNIBUS map, no MAXMEM, other frame): MUTOS own text.  kstub and sigret have no V7
 *           counterpart (the PDP-11 returns from a signal with rti; V7 sigret does not exist).  The V7 functions mapalloc, dump, estabur etc.
 *           of machdep.c are not in this file (mapalloc is in bio.c).  System III PDP-11 uts/pdp11/os/machdep.c: same skeleton, no
 *           System III feature present.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): startup 23% (System III 21%), sendsig 55% (49%), sigret 14%
 *           against sendsig, kstub 100% (noise: empty function); file similarity 20% (V7), 23% (System III).  Only a weak skeleton.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/machdep.md.
 * Deviations: all four functions are Z8001 specific; the V7 text is kept as a comment where it explains the structure.
 *
 * Hand assembler (mch.s, NOT rebuilt here): csv/cret, savu/resume, spl0..spl7/splx, fuword/fubyte/suword/subyte,
 * copyin/copyout/copyseg/clearseg, idle, trap entry 030E, start 027E.
 * Data: segment selection of the user accesses usegm = 8DC0 (suword/fuword read it), maxmem = 8DDC, text 8B4E "mem = %D\n".
 * Names of the user space accesses: 04CC = fubyte (read byte), 04DA = fuword (read word), 0508 = subyte, 0514 = suword -- the map
 * (kernel_namen.md K6b) had them swapped; this assignment holds in the sources.
 * K6b called 3630 "backup"; it is the return from the signal (sigret, counterpart of sendsig, sub function 0 of sysent). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "map.h"

extern int usegm;
extern int maxmem;

/*
 * Machine-dependent startup code
 *
 * V7: zero and free all of core by probing with fuibyte through UISA/UISD
 * until a segment does not answer; 11/70: initialize UBMAP; print
 * "mem = %D"; clip to MAXMEM.  MUTOS: the same loop over the segment
 * numbers (usegm selects the segment the user byte access reads), then
 * the swap map is freed.
 */
/* KERNEL 34F6 */
startup()
{
	register unsigned c;
	register t;

	mchinit();
	c = 0xFCFF;
	c >>= 8;
	c += 4;
	t = 0x55;
	for (; c < 0x400; c++) {
		usegm = c & 0x7F00;
		subyte(c << 8, t);
		if (fubyte(c << 8) != t)
			break;
		clearseg(c);
		maxmem++;
		mfree(coremap, 1, c);
	}
	printf("mem = %D\n", (long)maxmem << 8);
	usegm = 0;
	if (maxmem > 256)
		maxmem = 256;
	mfree(swapmap, nswap, 1);
	swplo--;
}

/*
 * MUTOS: empty function (V7 has no counterpart; position between startup and sendsig).
 */
/* KERNEL 35AC */
kstub()
{
}

/*
 * Let a process handle a signal by simulating an interrupt
 *
 * V7 text (PDP-11: push PS and PC, clear the trace bit, set the new PC):
 *
 * sendsig(p, signo)
 * caddr_t p;
 * {
 *	register unsigned n;
 *
 *	n = u.u_ar0[R6] - 4;
 *	grow(n);
 *	suword((caddr_t)n+2, u.u_ar0[RPS]);
 *	suword((caddr_t)n, u.u_ar0[R7]);
 *	u.u_ar0[R6] = n;
 *	u.u_ar0[RPS] &= ~TBIT;
 *	u.u_ar0[R7] = (int)p;
 * }
 *
 * MUTOS: pushes four words (ar0[-1], ar0[10], ar0[11], ar0[12]) on the user
 * stack, which is grown first; user SP is ar0[8], the new PC goes to ar0[12].
 * (Assumed from the code: ar0[12] is the saved PC, ar0[10..11] the saved
 * FCW / segment word; not measured against the entry code.)
 */
/* KERNEL 35AE */
sendsig(p, n)
{
	register sp;

	sp = u.u_ar0[8];
	sp -= 8;
	grow(sp);
	suword(sp+6, u.u_ar0[12]);
	suword(sp+4, u.u_ar0[11]);
	suword(sp+2, u.u_ar0[10]);
	suword(sp, u.u_ar0[-1]);
	u.u_ar0[8] = sp;
	u.u_ar0[12] = p;
}

/*
 * MUTOS: return from a signal (sysent entry 0, called from trap() in
 * case 6+USER): reloads ar0[12], ar0[11] and ar0[10] from the user stack and
 * drops the frame built by sendsig.  No V7 counterpart (PDP-11: rti).
 */
/* KERNEL 3630 */
sigret()
{
	register sp;

	sp = u.u_ar0[8];
	u.u_ar0[12] = fuword(sp+6);
	u.u_ar0[11] = fuword(sp+4);
	u.u_ar0[10] = fuword(sp+2);
	u.u_ar0[8] = sp + 8;
}
