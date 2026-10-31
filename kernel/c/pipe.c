/* pipe.c -- pipes, inode locks, character lists (kernel mutos_1216, 39BA..3CF0): uchar, pipe, readp, writep, plock, prele,
 * getc, putc.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/pipe.c (pipe, readp, writep, plock, prele); uchar from usr/sys/sys/nami.c; getc and putc
 *           from usr/sys/sys/prim.c (the kernel places them behind prele).  System III PDP-11 uts/os/pipe.c is
 *           FIFO based (IFIFO, no readp/writep) and not used.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 95% V7 / 33% System III PDP-11 (before the
 *           restoration), 8 of 8 functions above 50% against V7.  Sleep channels ip+1 (writer) and ip+2 (reader), PIPSIZ
 *           4096 as in V7.  (K6b called readp/writep openp/closep.)
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/pipe.md.
 * Deviations: PIPSIZ comes from inode.h; the cblock/clist/CROUND declarations are local copies of the V7 prim.c/tty.h
 *           text (CBSIZE 14); see doc/herkunft/pipe.md.
 *
 * Data: cfreelist = D266 (BSS), cblock = 16 bytes (c_next + 14 characters).  uchar reads one byte from user space (04CC =
 * fubyte, as in cpass). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "inode.h"
#include "file.h"

#define	CBSIZE	14	/* number of chars in a clist block (V7 param.h) */
#define	CROUND	017	/* clist rounding: sizeof(int *) + CBSIZE - 1 (V7 param.h) */
struct cblock {
	struct cblock *c_next;
	char	c_info[CBSIZE];
};
struct clist {
	int	c_cc;		/* character count */
	char	*c_cf;		/* pointer to first */
	char	*c_cl;		/* pointer to last */
};
extern struct cblock *cfreelist;

/*
 * Return the next character from the
 * user string pointed at by dirp.
 */
/* KERNEL 39BA */
uchar()
{
	register c;

	c = fubyte(u.u_dirp++);
	if(c == -1)
		u.u_error = EFAULT;
	return(c);
}

/*
 * Max allowable buffering per pipe.
 * This is also the max size of the
 * file created to implement the pipe.
 * If this size is bigger than 5120,
 * pipes will be implemented with large
 * files, which is probably not good.
 */
/* MUTOS: PIPSIZ (4096) is defined in inode.h; V7 defines it here: #define PIPSIZ 4096 */

/*
 * The sys-pipe entry.
 * Allocate an inode on the root device.
 * Allocate 2 file structures.
 * Put it all together with flags.
 */
/* KERNEL 39E2 */
pipe()
{
	register struct inode *ip;
	register struct file *rf, *wf;
	int r;

	ip = ialloc(pipedev);
	if(ip == NULL)
		return;
	rf = falloc();
	if(rf == NULL) {
		iput(ip);
		return;
	}
	r = u.u_r.r_val1;
	wf = falloc();
	if(wf == NULL) {
		rf->f_count = 0;
		u.u_ofile[r] = NULL;
		iput(ip);
		return;
	}
	u.u_r.r_val2 = u.u_r.r_val1;
	u.u_r.r_val1 = r;
	wf->f_flag = FWRITE|FPIPE;
	wf->f_inode = ip;
	rf->f_flag = FREAD|FPIPE;
	rf->f_inode = ip;
	ip->i_count = 2;
	ip->i_mode = IFREG;
	ip->i_flag = IACC|IUPD|ICHG;
}

/*
 * Read call directed to a pipe.
 */
/* KERNEL 3A68 */
readp(fp)
register struct file *fp;
{
	register struct inode *ip;

	ip = fp->f_inode;

loop:
	/*
	 * Very conservative locking.
	 */

	plock(ip);
	/*
	 * If nothing in the pipe, wait.
	 */
	if (ip->i_size == 0) {
		/*
		 * If there are not both reader and
		 * writer active, return without
		 * satisfying read.
		 */
		prele(ip);
		if(ip->i_count < 2)
			return;
		ip->i_mode |= IREAD;
		sleep((caddr_t)ip+2, PPIPE);
		goto loop;
	}

	/*
	 * Read and return
	 */

	u.u_offset = fp->f_un.f_offset;
	readi(ip);
	fp->f_un.f_offset = u.u_offset;
	/*
	 * If reader has caught up with writer, reset
	 * offset and size to 0.
	 */
	if (fp->f_un.f_offset == ip->i_size) {
		fp->f_un.f_offset = 0;
		ip->i_size = 0;
		if(ip->i_mode & IWRITE) {
			ip->i_mode &= ~IWRITE;
			wakeup((caddr_t)ip+1);
		}
	}
	prele(ip);
}

/*
 * Write call directed to a pipe.
 */
/* KERNEL 3AFE */
writep(fp)
register struct file *fp;
{
	register c;
	register struct inode *ip;

	ip = fp->f_inode;
	c = u.u_count;

loop:

	/*
	 * If all done, return.
	 */

	plock(ip);
	if(c == 0) {
		prele(ip);
		u.u_count = 0;
		return;
	}

	/*
	 * If there are not both read and
	 * write sides of the pipe active,
	 * return error and signal too.
	 */

	if(ip->i_count < 2) {
		prele(ip);
		u.u_error = EPIPE;
		psignal(u.u_procp, SIGPIPE);
		return;
	}

	/*
	 * If the pipe is full,
	 * wait for reads to deplete
	 * and truncate it.
	 */

	if(ip->i_size >= PIPSIZ) {
		ip->i_mode |= IWRITE;
		prele(ip);
		sleep((caddr_t)ip+1, PPIPE);
		goto loop;
	}

	/*
	 * Write what is possible and
	 * loop back.
	 * If writing less than PIPSIZ, it always goes.
	 * One can therefore get a file > PIPSIZ if write
	 * sizes do not divide PIPSIZ.
	 */

	u.u_offset = ip->i_size;
	u.u_count = min((unsigned)c, (unsigned)PIPSIZ);
	c -= u.u_count;
	writei(ip);
	prele(ip);
	if(ip->i_mode&IREAD) {
		ip->i_mode &= ~IREAD;
		wakeup((caddr_t)ip+2);
	}
	goto loop;
}

/*
 * Lock a pipe.
 * If its already locked,
 * set the WANT bit and sleep.
 */
/* KERNEL 3BBE */
plock(ip)
register struct inode *ip;
{

	while(ip->i_flag&ILOCK) {
		ip->i_flag |= IWANT;
		sleep((caddr_t)ip, PINOD);
	}
	ip->i_flag |= ILOCK;
}

/*
 * Unlock a pipe.
 * If WANT bit is on,
 * wakeup.
 * This routine is also used
 * to unlock inodes in general.
 */
/* KERNEL 3BE0 */
prele(ip)
register struct inode *ip;
{

	ip->i_flag &= ~ILOCK;
	if(ip->i_flag&IWANT) {
		ip->i_flag &= ~IWANT;
		wakeup((caddr_t)ip);
	}
}

/*
 * Character list get/put
 */
/* KERNEL 3BFC */
getc(p)
register struct clist *p;
{
	register struct cblock *bp;
	register int c, s;

	s = spl6();
	if (p->c_cc <= 0) {
		c = -1;
		p->c_cc = 0;
		p->c_cf = p->c_cl = NULL;
	} else {
		c = *p->c_cf++ & 0377;
		if (--p->c_cc<=0) {
			bp = (struct cblock *)(p->c_cf-1);
			bp = (struct cblock *) ((int)bp & ~CROUND);
			p->c_cf = NULL;
			p->c_cl = NULL;
			bp->c_next = cfreelist;
			cfreelist = bp;
		} else if (((int)p->c_cf & CROUND) == 0){
			bp = (struct cblock *)(p->c_cf);
			bp--;
			p->c_cf = bp->c_next->c_info;
			bp->c_next = cfreelist;
			cfreelist = bp;
		}
	}
	splx(s);
	return(c);
}

/* KERNEL 3C80 */
putc(c, p)
register struct clist *p;
{
	register struct cblock *bp;
	register char *cp;
	register s;

	s = spl6();
	if ((cp = p->c_cl) == NULL || p->c_cc < 0 ) {
		if ((bp = cfreelist) == NULL) {
			splx(s);
			return(-1);
		}
		cfreelist = bp->c_next;
		bp->c_next = NULL;
		p->c_cf = cp = bp->c_info;
	} else if (((int)cp & CROUND) == 0) {
		bp = (struct cblock *)cp - 1;
		if ((bp->c_next = cfreelist) == NULL) {
			splx(s);
			return(-1);
		}
		bp = bp->c_next;
		cfreelist = bp->c_next;
		bp->c_next = NULL;
		cp = bp->c_info;
	}
	*cp++ = c;
	p->c_cc++;
	p->c_cl = cp;
	splx(s);
	return(0);
}
