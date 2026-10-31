/* rdwri.c -- read and write inodes (kernel mutos_1216, 2460..2842): readi, writei, min, iomove.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/rdwri.c (readi, writei, min, iomove).  V7 max() is not in the kernel (no caller).
 *           System III PDP-11 uts/os/rdwri.c is changed (FIFO, readahead); not used.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 81% V7 / 38% System III PDP-11 (before the
 *           restoration), 4 of 4 functions above 50% against V7.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/rdwri.md.
 * Deviations: no separate instruction space (iomove has no copyiin/copyiout); see doc/herkunft/rdwri.md.
 *
 * Data: rablock = 8DE4 (see subr.c), cdevsw 8796 (d_read +4), 879A/879C = cdevsw[0].d_read/d_write. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "inode.h"
#include "buf.h"
#include "conf.h"

#define NBPW sizeof(int)	/* V7 param.h; not in MUTOS param.h */

/*
 * Read the file corresponding to
 * the inode pointed at by the argument.
 * The actual read arguments are found
 * in the variables:
 *	u_base		core address for destination
 *	u_offset	byte offset in file
 *	u_count		number of bytes to read
 *	u_segflg	read to kernel/user/user I
 */
/* KERNEL 2460 */
readi(ip)
register struct inode *ip;
{
	struct buf *bp;
	dev_t dev;
	daddr_t lbn, bn;
	off_t diff;
	register on, n;
	register type;

	if(u.u_count == 0)
		return;
	if(u.u_offset < 0) {
		u.u_error = EINVAL;
		return;
	}
	ip->i_flag |= IACC;
	dev = (dev_t)ip->i_un.i_rdev;
	type = ip->i_mode&IFMT;
	if (type==IFCHR || type==IFMPC) {
		return((*cdevsw[major(dev)].d_read)(dev));
	}

	do {
		lbn = bn = u.u_offset >> BSHIFT;
		on = u.u_offset & BMASK;
		n = min((unsigned)(BSIZE-on), u.u_count);
		if (type!=IFBLK && type!=IFMPB) {
			diff = ip->i_size - u.u_offset;
			if(diff <= 0)
				return;
			if(diff < n)
				n = diff;
			bn = bmap(ip, bn, B_READ);
			if(u.u_error)
				return;
			dev = ip->i_dev;
		} else
			rablock = bn+1;
		if ((long)bn<0) {
			bp = geteblk();
			clrbuf(bp);
		} else if (ip->i_un.i_lastr+1==lbn)
			bp = breada(dev, bn, rablock);
		else
			bp = bread(dev, bn);
		ip->i_un.i_lastr = lbn;
		n = min((unsigned)n, BSIZE-bp->b_resid);
		if (n!=0)
			iomove(bp->b_un.b_addr+on, n, B_READ);
		brelse(bp);
	} while(u.u_error==0 && u.u_count!=0 && n>0);
}

/*
 * Write the file corresponding to
 * the inode pointed at by the argument.
 * The actual write arguments are found
 * in the variables:
 *	u_base		core address for source
 *	u_offset	byte offset in file
 *	u_count		number of bytes to write
 *	u_segflg	write to kernel/user/user I
 */
/* KERNEL 25FE */
writei(ip)
register struct inode *ip;
{
	struct buf *bp;
	dev_t dev;
	daddr_t bn;
	register n, on;
	register type;

	if(u.u_offset < 0) {
		u.u_error = EINVAL;
		return;
	}
	dev = (dev_t)ip->i_un.i_rdev;
	type = ip->i_mode&IFMT;
	if (type==IFCHR || type==IFMPC) {
		ip->i_flag |= IUPD|ICHG;
		(*cdevsw[major(dev)].d_write)(dev);
		return;
	}
	if (u.u_count == 0)
		return;

	do {
		bn = u.u_offset >> BSHIFT;
		on = u.u_offset & BMASK;
		n = min((unsigned)(BSIZE-on), u.u_count);
		if (type!=IFBLK && type!=IFMPB) {
			bn = bmap(ip, bn, B_WRITE);
			if((long)bn<0)
				return;
			dev = ip->i_dev;
		}
		if(n == BSIZE) 
			bp = getblk(dev, bn);
		else
			bp = bread(dev, bn);
		iomove(bp->b_un.b_addr+on, n, B_WRITE);
		if(u.u_error != 0)
			brelse(bp);
		else
			bdwrite(bp);
		if(u.u_offset > ip->i_size &&
		   (type==IFDIR || type==IFREG))
			ip->i_size = u.u_offset;
		ip->i_flag |= IUPD|ICHG;
	} while(u.u_error==0 && u.u_count!=0);
}

/*
 * Return the logical minimum
 * of the 2 arguments.
 */
/* KERNEL 2766 */
min(a, b)
unsigned a, b;
{

	if(a < b)
		return(a);
	return(b);
}

/*
 * Move n bytes at byte location
 * &bp->b_un.b_addr[o] to/from (flag) the
 * user/kernel (u.segflg) area starting at u.base.
 * Update all the arguments by the number
 * of bytes moved.
 *
 * There are 2 algorithms,
 * if source address, dest address and count
 * are all even in a user copy,
 * then the machine language copyin/copyout
 * is called.
 * If not, its done byte-by-byte with
 * cpass and passc.
 */
/* KERNEL 2780 */
iomove(cp, n, flag)
register caddr_t cp;
register n;
{
	register t;

	if (n==0)
		return;
	if(u.u_segflg != 1 &&
	  (n&(NBPW-1)) == 0 &&
	  ((int)cp&(NBPW-1)) == 0 &&
	  ((int)u.u_base&(NBPW-1)) == 0) {
		/* MUTOS: no separate I space, so no copyiin/copyiout (V7 chooses them for u_segflg 2) */
		if (flag==B_WRITE)
			t = copyin(u.u_base, (caddr_t)cp, n);
		else
			t = copyout((caddr_t)cp, u.u_base, n);
		if (t) {
			u.u_error = EFAULT;
			return;
		}
		u.u_base += n;
		u.u_offset += n;
		u.u_count -= n;
		return;
	}
	if (flag==B_WRITE) {
		do {
			if ((t = cpass()) < 0)
				return;
			*cp++ = t;
		} while (--n);
	} else
		do {
			if(passc(*cp++) < 0)
				return;
		} while (--n);
}
