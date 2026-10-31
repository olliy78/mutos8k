/* text.c -- shared text management (kernel mutos_1216, 562C..57D4): xswap, xfree and eight empty functions.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/sys/text.c: xswap (V7 text with Z8001 changes), xfree (V7 text, byte-identical).  The other V7 functions (xalloc, xexpand,
 *           xlock, xunlock, xccdec, xumount, xrele, xuntext) exist in the kernel only as empty stubs (csv/cret): MUTOS has no
 *           shared text table (K6a), the V7 originals are kept below as comments.  System III PDP-11 uts/os/text.c has the
 *           same function set as V7 (xalloc with XLOAD/XWRIT logic); no System III feature is present.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): xswap 67% and xfree 80% against V7 (System III 67% / 80%);
 *           file similarity 45%.  The stubs have no text (the comparison tool finds 100% on any empty function: noise).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/text.md.
 * Deviations: xswap swaps the whole Z8001 image in the form swap(a, addr, 0x104, 0, up) with the swap size computed from the
 *           user area (V7: ctod(p_size) and a plain swap); the stubs; see doc/herkunft/text.md.
 *
 * Data: swapmap = A0DC, coremap = A09C, runout = 8DD8, text 8C64 "out of swap space".
 * saccess (55AE) is before xswap in the kernel but belongs to sys2.c.
 * Names: 562C is V7 xswap (K6b called it xalloc); 579C and 57CC (xstub1, xstub2) lie where V7 xexpand and xuntext would be
 * (assumed from the function order, the names stay for the address list of the full build). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "text.h"
#include "map.h"
#include "inode.h"
#include "buf.h"

#define ctodu(x)	(((unsigned)(x)+1)>>1)	/* MUTOS: unsigned ctod (the clicks are 256 bytes) */

/*
 * Swap out process p.
 * The ff flag causes its core to be freed--
 * it may be off when called to create an image for a
 * child process in newproc.
 * Os is the old size of the data area of the process,
 * and is supplied during core expansion swaps.
 *
 * panic: out of swap space
 *
 * MUTOS: the swap area needed is computed from the user area (data size and the used part of the stack segment),
 * the image is written with the five-argument swap() (see bio.c).
 */
/* KERNEL 562C */
xswap(p, ff, os)
register struct proc *p;
register os;
{
	register a, t;
	register struct user *up;

	if(os == 0)
		os = p->p_size;
	t = p->p_addr << 2;
	up = (struct user *)(t + 0xEC00);	/* user area of p: segment base 0xEC00 + 1 KB per user area */
	t = up->u_dsize;
	t = ctodu(t) + 2;
	a = (int)up->u_ar0;
	a += 0x400;
	a += (int)up;
	a = *(int *)(a + 0x10);	/* saved stack pointer of the process */
	t += ctodu(0x100 - ((unsigned)a >> 8));
	a = malloc(swapmap, t);	/* V7: malloc(swapmap, ctod(p->p_size)) */
	if(a == NULL)
		panic("out of swap space");
	p->p_flag |= SLOCK;
	xccdec(p->p_textp);
	swap(a, p->p_addr, 0x104, B_WRITE, up);	/* V7: swap(a, p->p_addr, os, B_WRITE) */
	if(ff)
		mfree(coremap, os, p->p_addr);
	p->p_addr = a;
	p->p_flag &= ~(SLOAD|SLOCK);
	p->p_time = 0;
	if(runout) {
		runout = 0;
		wakeup((caddr_t)&runout);
	}
}

/*
 * relinquish use of the shared text segment
 * of a process.
 */
/* KERNEL 5702 */
xfree()
{
	register struct text *xp;
	register struct inode *ip;

	if((xp=u.u_procp->p_textp) == NULL)
		return;
	xlock(xp);
	xp->x_flag &= ~XLOCK;
	u.u_procp->p_textp = NULL;
	ip = xp->x_iptr;
	if(--xp->x_count==0 && (ip->i_mode&ISVTX)==0) {
		xp->x_iptr = NULL;
		mfree(swapmap, ctod(xp->x_size), xp->x_daddr);	/* signed ctod as in V7 (the unsigned ctodu of xswap gives 1 word more here, measured) */
		mfree(coremap, xp->x_size, xp->x_caddr);
		ip->i_flag &= ~ITEXT;
		if (ip->i_flag&ILOCK)
			ip->i_count--;
		else
			iput(ip);
	} else
		xccdec(xp);
}

/*
 * V7 original of xalloc (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * Attach to a shared text segment.
 *  * If there is no shared text, just return.
 *  * If there is, hook up to it:
 *  * if it is not currently being used, it has to be read
 *  * in from the inode (ip); the written bit is set to force it
 *  * to be written out as appropriate.
 *  * If it is being used, but is not currently in core,
 *  * a swap has to be done to get it back.
 *
 * xalloc(ip)
 * register struct inode *ip;
 * {
 * 	register struct text *xp;
 * 	register unsigned ts;
 * 	register struct text *xp1;
 *
 * 	if(u.u_exdata.ux_tsize == 0)
 * 		return;
 * 	xp1 = NULL;
 * 	for (xp = &text[0]; xp < &text[NTEXT]; xp++) {
 * 		if(xp->x_iptr == NULL) {
 * 			if(xp1 == NULL)
 * 				xp1 = xp;
 * 			continue;
 * 		}
 * 		if(xp->x_iptr == ip) {
 * 			xlock(xp);
 * 			xp->x_count++;
 * 			u.u_procp->p_textp = xp;
 * 			if (xp->x_ccount == 0)
 * 				xexpand(xp);
 * 			else
 * 				xp->x_ccount++;
 * 			xunlock(xp);
 * 			return;
 * 		}
 * 	}
 * 	if((xp=xp1) == NULL) {
 * 		printf("out of text");
 * 		psignal(u.u_procp, SIGKIL);
 * 		return;
 * 	}
 * 	xp->x_flag = XLOAD|XLOCK;
 * 	xp->x_count = 1;
 * 	xp->x_ccount = 0;
 * 	xp->x_iptr = ip;
 * 	ip->i_flag |= ITEXT;
 * 	ip->i_count++;
 * 	ts = btoc(u.u_exdata.ux_tsize);
 * 	xp->x_size = ts;
 * 	if((xp->x_daddr = malloc(swapmap, (int)ctod(ts))) == NULL)
 * 		panic("out of swap space");
 * 	u.u_procp->p_textp = xp;
 * 	xexpand(xp);
 * 	estabur(ts, (unsigned)0, (unsigned)0, 0, RW);
 * 	u.u_count = u.u_exdata.ux_tsize;
 * 	u.u_offset = sizeof(u.u_exdata);
 * 	u.u_base = 0;
 * 	u.u_segflg = 2;
 * 	u.u_procp->p_flag |= SLOCK;
 * 	readi(ip);
 * 	u.u_procp->p_flag &= ~SLOCK;
 * 	u.u_segflg = 0;
 * 	xp->x_flag = XWRIT;
 * }
 */
/* KERNEL 5790 */
xalloc(ip)
register struct inode *ip;
{
}

/*
 * V7 original of xexpand (assumed) (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * Assure core for text segment
 *  * Text must be locked to keep someone else from
 *  * freeing it in the meantime.
 *  * x_ccount must be 0.
 *
 * xexpand(xp)
 * register struct text *xp;
 * {
 * 	if ((xp->x_caddr = malloc(coremap, xp->x_size)) != NULL) {
 * 		if ((xp->x_flag&XLOAD)==0)
 * 			swap(xp->x_daddr, xp->x_caddr, xp->x_size, B_READ);
 * 		xp->x_ccount++;
 * 		xunlock(xp);
 * 		return;
 * 	}
 * 	if (save(u.u_ssav)) {
 * 		sureg();
 * 		return;
 * 	}
 * 	xswap(u.u_procp, 1, 0);
 * 	xunlock(xp);
 * 	u.u_procp->p_flag |= SSWAP;
 * 	qswtch();
 * 	 no return 
 * }
 */
/* KERNEL 579C */
xstub1()
{
	register i;
}

/*
 * V7 original of xlock (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * Lock and unlock a text segment from swapping
 *
 * xlock(xp)
 * register struct text *xp;
 * {
 *
 * 	while(xp->x_flag&XLOCK) {
 * 		xp->x_flag |= XWANT;
 * 		sleep((caddr_t)xp, PSWP);
 * 	}
 * 	xp->x_flag |= XLOCK;
 * }
 */
/* KERNEL 57A4 */
xlock()
{
	register i;
}

/*
 * V7 original of xunlock (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 * xunlock(xp)
 * register struct text *xp;
 * {
 *
 * 	if (xp->x_flag&XWANT)
 * 		wakeup((caddr_t)xp);
 * 	xp->x_flag &= ~(XLOCK|XWANT);
 * }
 */
/* KERNEL 57AC */
xunlock()
{
	register i;
}

/*
 * V7 original of xccdec (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * Decrement the in-core usage count of a shared text segment.
 *  * When it drops to zero, free the core space.
 *
 * xccdec(xp)
 * register struct text *xp;
 * {
 *
 * 	if (xp==NULL || xp->x_ccount==0)
 * 		return;
 * 	xlock(xp);
 * 	if (--xp->x_ccount==0) {
 * 		if (xp->x_flag&XWRIT) {
 * 			xp->x_flag &= ~XWRIT;
 * 			swap(xp->x_daddr,xp->x_caddr,xp->x_size,B_WRITE);
 * 		}
 * 		mfree(coremap, xp->x_size, xp->x_caddr);
 * 	}
 * 	xunlock(xp);
 * }
 */
/* KERNEL 57B4 */
xccdec()
{
	register i;
}

/*
 * V7 original of xumount (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * free the swap image of all unused saved-text text segments
 *  * which are from device dev (used by umount system call).
 *
 * xumount(dev)
 * register dev;
 * {
 * 	register struct text *xp;
 *
 * 	for (xp = &text[0]; xp < &text[NTEXT]; xp++) 
 * 		if (xp->x_iptr!=NULL && dev==xp->x_iptr->i_dev)
 * 			xuntext(xp);
 * }
 */
/* KERNEL 57BC */
xumount()
{
	register i;
}

/*
 * V7 original of xrele (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * remove a shared text segment from the text table, if possible.
 *
 * xrele(ip)
 * register struct inode *ip;
 * {
 * 	register struct text *xp;
 *
 * 	if (ip->i_flag&ITEXT==0)
 * 		return;
 * 	for (xp = &text[0]; xp < &text[NTEXT]; xp++)
 * 		if (ip==xp->x_iptr)
 * 			xuntext(xp);
 * }
 */
/* KERNEL 57C4 */
xrele()
{
	register i;
}

/*
 * V7 original of xuntext (assumed) (usr/sys/sys/text.c), not in the kernel (the function body is empty here):
 *
 *
 *  * remove text image from the text table.
 *  * the use count must be zero.
 *
 * xuntext(xp)
 * register struct text *xp;
 * {
 * 	register struct inode *ip;
 *
 * 	xlock(xp);
 * 	if (xp->x_count) {
 * 		xunlock(xp);
 * 		return;
 * 	}
 * 	ip = xp->x_iptr;
 * 	xp->x_flag &= ~XLOCK;
 * 	xp->x_iptr = NULL;
 * 	mfree(swapmap, ctod(xp->x_size), xp->x_daddr);
 * 	ip->i_flag &= ~ITEXT;
 * 	if (ip->i_flag&ILOCK)
 * 		ip->i_count--;
 * 	else
 * 		iput(ip);
 * }
 */
/* KERNEL 57CC */
xstub2()
{
	register i;
}
