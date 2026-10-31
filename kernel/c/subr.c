/* subr.c -- file block mapping and small helpers (kernel mutos_1216, 20FE..243A): bmap, passc, cpass, nodev, nulldev, bcopy;
 * timeout (2A4C) is in V7 clock.c and sits behind the clock in the kernel, so it is kept at the end of this file.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/subr.c (bmap, passc, cpass, nodev, nulldev, bcopy) and usr/sys/sys/clock.c (timeout).
 *           System III PDP-11 uts/os/subr.c has bmap/passc/cpass/nodev/nulldev; bcopy and timeout are in its machdep.c/clock.c.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 74% V7 / 56% System III PDP-11 (before the
 *           restoration: bmap 85%, passc 89%, cpass 87%, nodev/nulldev/bcopy 100%, timeout 97% against V7; System III 62%,
 *           82%, 80%, 100%, 100%, 96%).  Same string "Timeout table overflow".
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/subr.md.
 * Deviations: no separate instruction space (no suibyte/fuibyte in passc/cpass); NADDR/NSHIFT/NMASK constants and
 *           the V7 comments kept; timeout compares with &callout[NCALL]; see doc/herkunft/subr.md.
 *
 * Data: rablock = 8DE4 (daddr_t), callout = CE58..CE8E (9 entries of 6 bytes, BSS), text 8AC2 "Timeout table overflow".
 * 236C passc and 23CA cpass call the user-space accessors 0508 = subyte and 04CC = fubyte (K6b called them
 * suword/fuword; they work on single bytes here). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "inode.h"
#include "buf.h"
#include "callo.h"

daddr_t rablock;
struct callo callout[NCALL];

/*
 * Bmap defines the structure of file system storage
 * by returning the physical block number on a device given the
 * inode and the logical block number in a file.
 * When convenient, it also leaves the physical
 * block number of the next block of the file in rablock
 * for use in read-ahead.
 */
/* KERNEL 20FE */
daddr_t
bmap(ip, bn, rwflg)
register struct inode *ip;
daddr_t bn;
{
	register i;
	struct buf *bp, *nbp;
	int j, sh;
	daddr_t nb, *bap;
	dev_t dev;

	if(bn < 0) {
		u.u_error = EFBIG;
		return((daddr_t)0);
	}
	dev = ip->i_dev;
	rablock = 0;

	/*
	 * blocks 0..NADDR-4 are direct blocks
	 */
	if(bn < NADDR-3) {
		i = bn;
		nb = ip->i_un.i_addr[i];
		if(nb == 0) {
			if(rwflg==B_READ || (bp = alloc(dev))==NULL)
				return((daddr_t)-1);
			nb = bp->b_blkno;
			bdwrite(bp);
			ip->i_un.i_addr[i] = nb;
			ip->i_flag |= IUPD|ICHG;
		}
		if(i < NADDR-4)
			rablock = ip->i_un.i_addr[i+1];
		return(nb);
	}

	/*
	 * addresses NADDR-3, NADDR-2, and NADDR-1
	 * have single, double, triple indirect blocks.
	 * the first step is to determine
	 * how many levels of indirection.
	 */
	sh = 0;
	nb = 1;
	bn -= NADDR-3;
	for(j=3; j>0; j--) {
		sh += NSHIFT;
		nb <<= NSHIFT;
		if(bn < nb)
			break;
		bn -= nb;
	}
	if(j == 0) {
		u.u_error = EFBIG;
		return((daddr_t)0);
	}

	/*
	 * fetch the address from the inode
	 */
	nb = ip->i_un.i_addr[NADDR-j];
	if(nb == 0) {
		if(rwflg==B_READ || (bp = alloc(dev))==NULL)
			return((daddr_t)-1);
		nb = bp->b_blkno;
		bdwrite(bp);
		ip->i_un.i_addr[NADDR-j] = nb;
		ip->i_flag |= IUPD|ICHG;
	}

	/*
	 * fetch through the indirect blocks
	 */
	for(; j<=3; j++) {
		bp = bread(dev, nb);
		if(bp->b_flags & B_ERROR) {
			brelse(bp);
			return((daddr_t)0);
		}
		bap = bp->b_un.b_daddr;
		sh -= NSHIFT;
		i = (bn>>sh) & NMASK;
		nb = bap[i];
		if(nb == 0) {
			if(rwflg==B_READ || (nbp = alloc(dev))==NULL) {
				brelse(bp);
				return((daddr_t)-1);
			}
			nb = nbp->b_blkno;
			bdwrite(nbp);
			bap[i] = nb;
			bdwrite(bp);
		} else
			brelse(bp);
	}

	/*
	 * calculate read-ahead.
	 */
	if(i < NINDIR-1)
		rablock = bap[i+1];
	return(nb);
}

/*
 * Pass back  c  to the user at his location u_base;
 * update u_base, u_count, and u_offset.  Return -1
 * on the last character of the user's read.
 * u_base is in the user address space unless u_segflg is set.
 */
/* KERNEL 236C */
passc(c)
register c;
{
	register id;

	if((id = u.u_segflg) == 1)
		*u.u_base = c;
	else
		/* MUTOS: no separate I space, so no suibyte (V7: id?suibyte(u.u_base, c):subyte(u.u_base, c) < 0) */
		if(subyte(u.u_base, c) < 0) {
			u.u_error = EFAULT;
			return(-1);
		}
	u.u_count--;
	u.u_offset++;
	u.u_base++;
	return(u.u_count == 0? -1: 0);
}

/*
 * Pick up and return the next character from the user's
 * write call at location u_base;
 * update u_base, u_count, and u_offset.  Return -1
 * when u_count is exhausted.  u_base is in the user's
 * address space unless u_segflg is set.
 */
/* KERNEL 23CA */
cpass()
{
	register c, id;

	if(u.u_count == 0)
		return(-1);
	if((id = u.u_segflg) == 1)
		c = *u.u_base;
	else
		/* MUTOS: no separate I space, so no fuibyte (V7: (c = id==0?fubyte(u.u_base):fuibyte(u.u_base)) < 0) */
		if((c = fubyte(u.u_base)) < 0) {
			u.u_error = EFAULT;
			return(-1);
		}
	u.u_count--;
	u.u_offset++;
	u.u_base++;
	return(c&0377);
}

/*
 * Routine which sets a user error; placed in
 * illegal entries in the bdevsw and cdevsw tables.
 */
/* KERNEL 242A */
nodev()
{

	u.u_error = ENODEV;
}

/*
 * Null routine; placed in insignificant entries
 * in the bdevsw and cdevsw tables.
 */
/* KERNEL 2438 */
nulldev()
{
}

/*
 * copy count bytes from from to to.
 */
/* KERNEL 243A */
bcopy(from, to, count)
caddr_t from, to;
register count;
{
	register char *f, *t;

	f = from;
	t = to;
	do
		*t++ = *f++;
	while(--count);
}

/*
 * timeout is called to arrange that
 * fun(arg) is called in tim/HZ seconds.
 * An entry is sorted into the callout
 * structure. The time in each structure
 * entry is the number of HZ's more
 * than the previous entry.
 * In this way, decrementing the
 * first entry has the effect of
 * updating all entries.
 *
 * The panic is there because there is nothing
 * intelligent to be done if an entry won't fit.
 */
/* KERNEL 2A4C */
timeout(fun, arg, tim)
int (*fun)();
caddr_t arg;
{
	register struct callo *p1, *p2;
	register int t;
	int s;

	t = tim;
	p1 = &callout[0];
	s = spl7();
	while(p1->c_func != 0 && p1->c_time <= t) {
		t -= p1->c_time;
		p1++;
	}
	/* MUTOS: V7 compares with &callout[NCALL-1] */
	if (p1 >= &callout[NCALL])
		panic("Timeout table overflow");
	p1->c_time -= t;
	p2 = p1;
	while(p2->c_func != 0)
		p2++;
	while(p2 >= p1) {
		(p2+1)->c_time = p2->c_time;
		(p2+1)->c_func = p2->c_func;
		(p2+1)->c_arg = p2->c_arg;
		p2--;
	}
	p1->c_time = t;
	p1->c_func = fun;
	p1->c_arg = arg;
	splx(s);
}
