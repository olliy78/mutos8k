/* ureg.c -- cinit (character lists), sureg, estabur (kernel mutos_1216, 3D04..3D6A; lies between pipe.c and sys3.c).
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/sys/prim.c: cinit (V7 text, byte-identical).  sureg and estabur are MUTOS/Z8001 own: V7 usr/sys/sys/ureg.c
 *           (sureg, estabur) loads and sets up the PDP-11 memory management registers (UISA/UISD); the Z8001 kernel has no such hardware
 *           in this form, so sureg is an empty stub and estabur only checks the size.  The V7 originals are kept below as comments.
 *           System III PDP-11 uts/pdp11/os/ureg.c has the same two functions (plus checkur); no System III feature is present.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): cinit 85% against V7 prim.c (after the restoration 100% with the
 *           MUTOS constants); sureg 100% and estabur 55% are noise (empty / tiny function matched against any other); file similarity 34%
 *           (V7 prim.c), 8% (System III ureg.c).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/ureg.md.
 * Deviations: MUTOS cblock is 16 bytes (c_info[14], V7 8 bytes with c_info[6]) and NCLIST is 50 (V7 100): CROUND is 017.
 *           sureg and estabur: see above.
 *
 * Data: cfree = CF46 (50 blocks of 16 bytes, BSS), cfreelist = D266, nchrdev = 8DD2, cdevsw = 8796. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "conf.h"

#define NCLIST	50		/* MUTOS: V7 param.h has 100 */
#define CBSIZE	14		/* MUTOS: V7 has 6 (8-byte cblock) */
#define CROUND	017		/* MUTOS: V7 has 07 */
struct cblock {
	struct cblock	*c_next;
	char		c_info[CBSIZE];
};
struct cblock cfree[NCLIST];
struct cblock *cfreelist;

/*
 * Initialize clist by freeing all character blocks, then count
 * number of character devices. (Once-only routine)
 */
/* KERNEL 3D04 */
cinit()
{
	register int ccp;
	register struct cblock *cp;
	register struct cdevsw *cdp;

	ccp = (int)cfree;
	ccp = (ccp+CROUND) & ~CROUND;
	for(cp=(struct cblock *)ccp; cp <= &cfree[NCLIST-1]; cp++) {
		cp->c_next = cfreelist;
		cfreelist = cp;
	}
	ccp = 0;
	for(cdp = cdevsw; cdp->d_open; cdp++)
		ccp++;
	nchrdev = ccp;
}

/*
 * MUTOS: no segmentation registers to load; empty stub.
 * V7 text (PDP-11 UISA/UISD):
 *
 * Load the user hardware segmentation
 * registers from the software prototype.
 * The software registers must have
 * been setup prior by estabur.
 *
 * sureg()
 * {
 *	register *udp, *uap, *rdp;
 *	int *rap, *limudp;
 *	int taddr, daddr;
 *	struct text *tp;
 *
 *	taddr = daddr = u.u_procp->p_addr;
 *	if ((tp=u.u_procp->p_textp) != NULL)
 *		taddr = tp->x_caddr;
 *	limudp = &u.u_uisd[16];
 *	if (cputype==40)
 *		limudp = &u.u_uisd[8];
 *	rap = (int *)UISA;
 *	rdp = (int *)UISD;
 *	uap = &u.u_uisa[0];
 *	for (udp = &u.u_uisd[0]; udp < limudp;) {
 *		*rap++ = *uap++ + (*udp&TX? taddr: (*udp&ABS? 0: daddr));
 *		*rdp++ = *udp++;
 *	}
 * }
 */
/* KERNEL 3D40 */
sureg()
{
}

/*
 * MUTOS: without memory management hardware estabur is only a size check
 * (text + data + stack at most 256 segments of 256 bytes).  V7 sets up the
 * PDP-11 prototype segmentation registers u_uisa/u_uisd here (for the
 * 3 pseudo text, data, stack segment sizes, separate I/D flag sep,
 * text read-write flag xrw) and calls sureg(); the V7 text is
 * in usr/sys/sys/ureg.c (not repeated here: ~90 lines of PDP-11 register set-up).
 * The error exit of V7 is the same as here:
 *
 * err:
 *	u.u_error = ENOMEM;
 *	return(-1);
 */
/* KERNEL 3D42 */
estabur(nt, nd, ns, sep, xrw)
unsigned nt, nd, ns;
{
	if (nt + nd + ns > 256) {
		u.u_error = ENOMEM;
		return(-1);
	}
	return(0);
}
