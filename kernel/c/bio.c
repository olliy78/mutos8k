/* bio.c -- buffer cache and raw I/O (kernel mutos_1216, 57D4..60C7): bread, breada, bwrite, bdwrite, bawrite, brelse, incore,
 * getblk, geteblk, iowait, notavail, iodone, clrbuf, mapalloc (5CAE), mapstart (5CF6), swap, bflush, physio, geterror.
 * binit is at 07D2 in the kernel (main.c).
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/dev/bio.c: bread, breada, bwrite, bdwrite, bawrite, brelse, incore, getblk, geteblk, iowait,
 *           notavail, iodone, clrbuf, bflush, geterror (V7 text); swap and physio are V7 functions rewritten for the Z8001.
 *           mapalloc, mapstart have no counterpart (V7 mapalloc is the UNIBUS map): MUTOS own.
 *           System III PDP-11 uts/io/bio.c: iodone has the same text (without B_MAP); breada tests "bfreelist.b_bcount>1",
 *           MUTOS tests "bfreelist.av_forw != &bfreelist" (same idea, other form).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 77% V7 / 59% System III PDP-11 (before the
 *           restoration), 17 of 19 functions above 50% against V7, the two without counterpart are mapalloc and mapstart.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/bio.md.
 * Deviations: no DISKMON statistics (the V7 #ifdef blocks are kept, the #define is removed); casts on d_tab; B_MAP/mapfree
 *           removed from iodone; breada read-ahead test; swap, physio, mapalloc, mapstart see below and doc/herkunft/bio.md.
 *
 * Data: bdevsw 8766 (strategy +4 = 876A, d_tab +6 = 876C), buf[] 8E9A, bfreelist A518 (av_forw A51E, av_back A520),
 * nblkdev 8DD0, swapdev 887E, swplo 8884, swbuf1 CE28, swbuf2 CE40 (24 bytes each), swapmap A0DC, mapq D57C (4 words),
 * mapbusy D584, usrseg 8DC0 (segment for user accesses), texts 8C76 "blkdev", 8C7D "devtab", 8C84 "IO err in swap". */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "inode.h"
#include "proc.h"
#include "buf.h"
#include "conf.h"

/* MUTOS: V7 has "#define DISKMON 1" here; the statistics are not in the kernel, the #ifdef blocks below stay as dead text */
#ifdef	DISKMON
struct {
	int	nbuf;
	long	nread;
	long	nreada;
	long	ncache;
	long	nwrite;
	long	bufcount[NBUF];
} io_info;
#endif

/*
 * swap IO headers.
 * they are filled in to point
 * at the desired IO operation.
 */
/* MUTOS: only declared here; the kernel's data definitions come from the linked data module (swbuf1 CE28, swbuf2 CE40) */
extern struct buf swbuf1;
extern struct buf swbuf2;

extern int swapmap[];
extern int mapq[4];
extern char mapbusy;
extern int usrseg;

/*
 * The following several routines allocate and free
 * buffers with various side effects.  In general the
 * arguments to an allocate routine are a device and
 * a block number, and the value is a pointer to
 * to the buffer header; the buffer is marked "busy"
 * so that no one else can touch it.  If the block was
 * already in core, no I/O need be done; if it is
 * already busy, the process waits until it becomes free.
 * The following routines allocate a buffer:
 *	getblk
 *	bread
 *	breada
 * Eventually the buffer must be released, possibly with the
 * side effect of writing it out, by using one of
 *	bwrite
 *	bdwrite
 *	bawrite
 *	brelse
 */

/*
 * Read in (if necessary) the block and return a buffer pointer.
 */
/* KERNEL 57D4 */
struct buf *
bread(dev, blkno)
dev_t dev;
daddr_t blkno;
{
	register struct buf *bp;

	bp = getblk(dev, blkno);
	if (bp->b_flags&B_DONE) {
#ifdef	DISKMON
		io_info.ncache++;
#endif
		return(bp);
	}
	bp->b_flags |= B_READ;
	bp->b_bcount = BSIZE;
	(*bdevsw[major(dev)].d_strategy)(bp);
#ifdef	DISKMON
	io_info.nread++;
#endif
	iowait(bp);
	return(bp);
}

/*
 * Read in the block, like bread, but also start I/O on the
 * read-ahead block (which is not allocated to the caller)
 */
/* KERNEL 581A */
struct buf *
breada(dev, blkno, rablkno)
dev_t dev;
daddr_t blkno, rablkno;
{
	register struct buf *bp, *rabp;

	bp = NULL;
	if (!incore(dev, blkno)) {
		bp = getblk(dev, blkno);
		if ((bp->b_flags&B_DONE) == 0) {
			bp->b_flags |= B_READ;
			bp->b_bcount = BSIZE;
			(*bdevsw[major(dev)].d_strategy)(bp);
#ifdef	DISKMON
			io_info.nread++;
#endif
		}
	}
	/* MUTOS: read-ahead only while a buffer is free; V7: "if (rablkno && !incore(dev, rablkno))" */
	if (rablkno && !incore(dev, rablkno) && bfreelist.av_forw != &bfreelist) {
		rabp = getblk(dev, rablkno);
		if (rabp->b_flags & B_DONE)
			brelse(rabp);
		else {
			rabp->b_flags |= B_READ|B_ASYNC;
			rabp->b_bcount = BSIZE;
			(*bdevsw[major(dev)].d_strategy)(rabp);
#ifdef	DISKMON
			io_info.nreada++;
#endif
		}
	}
	if(bp == NULL)
		return(bread(dev, blkno));
	iowait(bp);
	return(bp);
}

/*
 * Write the buffer, waiting for completion.
 * Then release the buffer.
 */
/* KERNEL 58F0 */
bwrite(bp)
register struct buf *bp;
{
	register flag;

	flag = bp->b_flags;
	bp->b_flags &= ~(B_READ | B_DONE | B_ERROR | B_DELWRI | B_AGE);
	bp->b_bcount = BSIZE;
#ifdef	DISKMON
	io_info.nwrite++;
#endif
	(*bdevsw[major(bp->b_dev)].d_strategy)(bp);
	if ((flag&B_ASYNC) == 0) {
		iowait(bp);
		brelse(bp);
	} else if (flag & B_DELWRI)
		bp->b_flags |= B_AGE;
	else
		geterror(bp);
}

/*
 * Release the buffer, marking it so that if it is grabbed
 * for another purpose it will be written out before being
 * given up (e.g. when writing a partial block where it is
 * assumed that another write for the same block will soon follow).
 * This can't be done for magtape, since writes must be done
 * in the same order as requested.
 */
/* KERNEL 594A */
bdwrite(bp)
register struct buf *bp;
{
	register struct buf *dp;

	dp = (struct buf *)bdevsw[major(bp->b_dev)].d_tab;	/* MUTOS: cast (d_tab is a devtab pointer) */
	if(dp->b_flags & B_TAPE)
		bawrite(bp);
	else {
		bp->b_flags |= B_DELWRI | B_DONE;
		brelse(bp);
	}
}

/*
 * Release the buffer, start I/O on it, but don't wait for completion.
 */
/* KERNEL 5984 */
bawrite(bp)
register struct buf *bp;
{

	bp->b_flags |= B_ASYNC;
	bwrite(bp);
}

/*
 * release the buffer, with no I/O implied.
 */
/* KERNEL 599A */
brelse(bp)
register struct buf *bp;
{
	register struct buf **backp;
	register s;

	if (bp->b_flags&B_WANTED)
		wakeup((caddr_t)bp);
	if (bfreelist.b_flags&B_WANTED) {
		bfreelist.b_flags &= ~B_WANTED;
		wakeup((caddr_t)&bfreelist);
	}
	if (bp->b_flags&B_ERROR)
		bp->b_dev = (dev_t)NODEV;  /* no assoc. on error */
	s = spl6();
	if(bp->b_flags & B_AGE) {
		backp = &bfreelist.av_forw;
		(*backp)->av_back = bp;
		bp->av_forw = *backp;
		*backp = bp;
		bp->av_back = &bfreelist;
	} else {
		backp = &bfreelist.av_back;
		(*backp)->av_forw = bp;
		bp->av_back = *backp;
		*backp = bp;
		bp->av_forw = &bfreelist;
	}
	bp->b_flags &= ~(B_WANTED|B_BUSY|B_ASYNC|B_AGE);
	splx(s);
}

/*
 * See if the block is associated with some buffer
 * (mainly to avoid getting hung up on a wait in breada)
 */
/* KERNEL 5A22 */
incore(dev, blkno)
dev_t dev;
daddr_t blkno;
{
	register struct buf *bp;
	register struct buf *dp;

	dp = (struct buf *)bdevsw[major(dev)].d_tab;	/* MUTOS: cast */
	for (bp=dp->b_forw; bp != dp; bp = bp->b_forw)
		if (bp->b_blkno==blkno && bp->b_dev==dev)
			return(1);
	return(0);
}

/*
 * Assign a buffer for the given block.  If the appropriate
 * block is already associated, return it; otherwise search
 * for the oldest non-busy buffer and reassign it.
 */
/* KERNEL 5A64 */
struct buf *
getblk(dev, blkno)
dev_t dev;
daddr_t blkno;
{
	register struct buf *bp;
	register struct buf *dp;
#ifdef	DISKMON
	register i;
#endif

	if(major(dev) >= nblkdev)
		panic("blkdev");

    loop:
	spl0();
	dp = (struct buf *)bdevsw[major(dev)].d_tab;	/* MUTOS: cast */
	if(dp == NULL)
		panic("devtab");
	for (bp=dp->b_forw; bp != dp; bp = bp->b_forw) {
		if (bp->b_blkno!=blkno || bp->b_dev!=dev)
			continue;
		spl6();
		if (bp->b_flags&B_BUSY) {
			bp->b_flags |= B_WANTED;
			sleep((caddr_t)bp, PRIBIO+1);
			goto loop;
		}
		spl0();
#ifdef	DISKMON
		i = 0;
		dp = bp->av_forw;
		while (dp != &bfreelist) {
			i++;
			dp = dp->av_forw;
		}
		if (i<NBUF)
			io_info.bufcount[i]++;
#endif
		notavail(bp);
		return(bp);
	}
	spl6();
	if (bfreelist.av_forw == &bfreelist) {
		bfreelist.b_flags |= B_WANTED;
		sleep((caddr_t)&bfreelist, PRIBIO+1);
		goto loop;
	}
	spl0();
	notavail(bp = bfreelist.av_forw);
	if (bp->b_flags & B_DELWRI) {
		bp->b_flags |= B_ASYNC;
		bwrite(bp);
		goto loop;
	}
	bp->b_flags = B_BUSY;
	bp->b_back->b_forw = bp->b_forw;
	bp->b_forw->b_back = bp->b_back;
	bp->b_forw = dp->b_forw;
	bp->b_back = dp;
	dp->b_forw->b_back = bp;
	dp->b_forw = bp;
	bp->b_dev = dev;
	bp->b_blkno = blkno;
	return(bp);
}

/*
 * get an empty block,
 * not assigned to any particular device
 */
/* KERNEL 5B70 */
struct buf *
geteblk()
{
	register struct buf *bp;
	register struct buf *dp;

loop:
	spl6();
	while (bfreelist.av_forw == &bfreelist) {
		bfreelist.b_flags |= B_WANTED;
		sleep((caddr_t)&bfreelist, PRIBIO+1);
	}
	spl0();
	dp = &bfreelist;
	notavail(bp = bfreelist.av_forw);
	if (bp->b_flags & B_DELWRI) {
		bp->b_flags |= B_ASYNC;
		bwrite(bp);
		goto loop;
	}
	bp->b_flags = B_BUSY;
	bp->b_back->b_forw = bp->b_forw;
	bp->b_forw->b_back = bp->b_back;
	bp->b_forw = dp->b_forw;
	bp->b_back = dp;
	dp->b_forw->b_back = bp;
	dp->b_forw = bp;
	bp->b_dev = (dev_t)NODEV;
	return(bp);
}

/*
 * Wait for I/O completion on the buffer; return errors
 * to the user.
 */
/* KERNEL 5BFC */
iowait(bp)
register struct buf *bp;
{

	spl6();
	while ((bp->b_flags&B_DONE)==0)
		sleep((caddr_t)bp, PRIBIO);
	spl0();
	geterror(bp);
}

/*
 * Unlink a buffer from the available list and mark it busy.
 * (internal interface)
 */
/* KERNEL 5C2E */
notavail(bp)
register struct buf *bp;
{
	register s;

	s = spl6();
	bp->av_back->av_forw = bp->av_forw;
	bp->av_forw->av_back = bp->av_back;
	bp->b_flags |= B_BUSY;
	splx(s);
}

/*
 * Mark I/O complete on a buffer, release it if I/O is asynchronous,
 * and wake up anyone waiting for it.
 */
/* KERNEL 5C62 */
iodone(bp)
register struct buf *bp;
{

	/* MUTOS: no UNIBUS map, so no "if(bp->b_flags&B_MAP) mapfree(bp);" (System III has the same text without it) */
	bp->b_flags |= B_DONE;
	if (bp->b_flags&B_ASYNC)
		brelse(bp);
	else {
		bp->b_flags &= ~B_WANTED;
		wakeup((caddr_t)bp);
	}
}

/*
 * Zero the core associated with a buffer.
 */
/* KERNEL 5C86 */
clrbuf(bp)
struct buf *bp;
{
	register *p;
	register c;

	p = bp->b_un.b_words;
	c = BSIZE/sizeof(int);
	do
		*p++ = 0;
	while (--c);
	bp->b_resid = 0;
}

/*
 * MUTOS: not in V7 (V7 mapalloc is the UNIBUS map).  The two functions serialize a 4-slot queue (mapq, indexed by n/2) that
 * hands buffers to the mapaddr() routine through the word at address 6; purpose assumed (map set-up for the U880 side).
 */
/* KERNEL 5CAE */
mapalloc(bp, n)
register bp, n;
{
	while (mapq[n >> 1])
		if (!mapbusy)
			mapstart();
	mapq[n >> 1] = bp;
	if (!mapbusy)
		mapstart();
}

/* KERNEL 5CF6 */
mapstart()
{
	register bp, i;

	mapbusy++;
again:
	bp = 0;
	for (i = 0; i < 4; i++)
		if (mapq[i]) {
			bp = mapq[i];
			while (*(int *)06)
				;
			*(int *)06 = bp;
			mapaddr();
			mapq[i] = 0;
		}
	if (bp)
		goto again;
	mapbusy = 0;
}

/*
 * V7 original of swap (usr/sys/dev/bio.c), not used here:
 *
 *
 *  * swap I/O
 *
 * swap(blkno, coreaddr, count, rdflg)
 * register count;
 * {
 * 	register struct buf *bp;
 * 	register tcount;
 *
 * 	bp = &swbuf1;
 * 	if(bp->b_flags & B_BUSY)
 * 		if((swbuf2.b_flags&B_WANTED) == 0)
 * 			bp = &swbuf2;
 * 	spl6();
 * 	while (bp->b_flags&B_BUSY) {
 * 		bp->b_flags |= B_WANTED;
 * 		sleep((caddr_t)bp, PSWP+1);
 * 	}
 * 	while (count) {
 * 		bp->b_flags = B_BUSY | B_PHYS | rdflg;
 * 		bp->b_dev = swapdev;
 * 		tcount = count;
 * 		if (tcount >= 01700)	(prevent byte-count wrap)
 * 			tcount = 01700;
 * 		bp->b_bcount = ctob(tcount);
 * 		bp->b_blkno = swplo+blkno;
 * 		bp->b_un.b_addr = (caddr_t)(coreaddr<<6);
 * 		bp->b_xmem = (coreaddr>>10) & 077;
 * 		(*bdevsw[major(swapdev)].d_strategy)(bp);
 * 		spl6();
 * 		while((bp->b_flags&B_DONE)==0)
 * 			sleep((caddr_t)bp, PSWP);
 * 		count -= tcount;
 * 		coreaddr += tcount;
 * 		blkno += ctod(tcount);
 * 	}
 * 	if (bp->b_flags&B_WANTED)
 * 		wakeup((caddr_t)bp);
 * 	spl0();
 * 	bp->b_flags &= ~(B_BUSY|B_WANTED);
 * 	if (bp->b_flags & B_ERROR)
 * 		panic("IO err in swap");
 * }
 */
/*
 * swap I/O.
 * MUTOS: swap(blkno, coreaddr, count, rdflg, up).  Counts are in 256-byte clicks (V7: 64 bytes) and a transfer is at most 16
 * clicks (one 4 KB buffer, V7: 01700 clicks); the core address is a segment number (<<8 for the offset, >>8 for b_xmem).  A call
 * with count >= 0x104 swaps a whole process image: the user area of 4 clicks (at up), the data part, and the part of the stack
 * segment above the saved stack pointer; the swap space then is freed by mfree() when reading.
 */
/* KERNEL 5D4A */
swap(blkno, coreaddr, count, rdflg, up)
register blkno;
int coreaddr;
register count;
int rdflg;
register struct user *up;
{
	register struct buf *bp;
	register c, t;

	if (count >= 0x104) {
		swap(blkno, ((unsigned)up + 0xFF) >> 8, 4, rdflg);
		blkno += 2;
		t = 2;
		c = up->u_tsize + up->u_dsize;
		swap(blkno, coreaddr, c, rdflg);
		c = ctod(c);
		t += c;
		blkno += c;
		c = *(int *)((char *)up + 0x104);
		c += 0x400;
		c += (int)up;
		c = *(int *)(c + 16);
		c = ((unsigned)c >> 8) & ~1;
		coreaddr += c;
		c = 0x100 - c;
		swap(blkno, coreaddr, c, rdflg);
		t += ctod(c);
		blkno += ctod(c);
		if (rdflg == B_READ)
			mfree(swapmap, t, blkno - t);
		return;
	}
	bp = &swbuf1;
	if ((bp->b_flags & B_BUSY) && (swbuf2.b_flags & B_WANTED) == 0)
		bp = &swbuf2;
	spl6();
	while (bp->b_flags & B_BUSY) {
		bp->b_flags |= B_WANTED;
		sleep((caddr_t)bp, PSWP+1);
	}
	while (count) {
		bp->b_flags = B_BUSY | B_PHYS | rdflg;
		bp->b_dev = swapdev;
		c = count;
		if (c > 16)
			c = 16;
		bp->b_bcount = c << 8;
		bp->b_blkno = (daddr_t)blkno + swplo;
		bp->b_un.b_addr = (caddr_t)(coreaddr << 8);
		bp->b_xmem = (coreaddr >> 8) & 0177;
		(*bdevsw[major(swapdev)].d_strategy)(bp);
		spl6();
		while ((bp->b_flags & B_DONE) == 0)
			sleep((caddr_t)bp, PSWP);
		count -= c;
		coreaddr += c;
		blkno += ctod(c);
	}
	if (bp->b_flags & B_WANTED)
		wakeup((caddr_t)bp);
	spl0();
	bp->b_flags &= ~(B_BUSY|B_WANTED);
	if (bp->b_flags & B_ERROR)
		panic("IO err in swap");
}

/*
 * make sure all write-behind blocks
 * on dev (or NODEV for all)
 * are flushed out.
 * (from umount and update)
 */
/* KERNEL 5F10 */
bflush(dev)
dev_t dev;
{
	register struct buf *bp;

loop:
	spl6();
	for (bp = bfreelist.av_forw; bp != &bfreelist; bp = bp->av_forw) {
		if (bp->b_flags&B_DELWRI && (dev == NODEV||dev==bp->b_dev)) {
			bp->b_flags |= B_ASYNC;
			notavail(bp);
			bwrite(bp);
			goto loop;
		}
	}
	spl0();
}


/*
 * V7 original of physio (usr/sys/dev/bio.c), not used here:
 *
 *
 *  * Raw I/O. The arguments are
 *  *	The strategy routine for the device
 *  *	A buffer, which will always be a special buffer
 *  *	  header owned exclusively by the device for this purpose
 *  *	The device number
 *  *	Read/write flag
 *  * Essentially all the work is computing physical addresses and
 *  * validating them.
 *
 * physio(strat, bp, dev, rw)
 * register struct buf *bp;
 * int (*strat)();
 * {
 * 	register unsigned base;
 * 	register int nb;
 * 	int ts;
 *
 * 	base = (unsigned)u.u_base;
 *
 * 	 * Check odd base, odd count, and address wraparound
 *
 * 	if (base&01 || u.u_count&01 || base>=base+u.u_count)
 * 		goto bad;
 * 	ts = (u.u_tsize+127) & ~0177;
 * 	if (u.u_sep)
 * 		ts = 0;
 * 	nb = (base>>6) & 01777;
 *
 * 	 * Check overlap with text. (ts and nb now
 * 	 * in 64-byte clicks)
 *
 * 	if (nb < ts)
 * 		goto bad;
 *
 * 	 * Check that transfer is either entirely in the
 * 	 * data or in the stack: that is, either
 * 	 * the end is in the data or the start is in the stack
 * 	 * (remember wraparound was already checked).
 *
 * 	if ((((base+u.u_count)>>6)&01777) >= ts+u.u_dsize
 * 	    && nb < 1024-u.u_ssize)
 * 		goto bad;
 * 	spl6();
 * 	while (bp->b_flags&B_BUSY) {
 * 		bp->b_flags |= B_WANTED;
 * 		sleep((caddr_t)bp, PRIBIO+1);
 * 	}
 * 	bp->b_flags = B_BUSY | B_PHYS | rw;
 * 	bp->b_dev = dev;
 *
 * 	 * Compute physical address by simulating
 * 	 * the segmentation hardware.
 *
 * 	ts = (u.u_sep? UDSA: UISA)->r[nb>>7] + (nb&0177);
 * 	bp->b_un.b_addr = (caddr_t)((ts<<6) + (base&077));
 * 	bp->b_xmem = (ts>>10) & 077;
 * 	bp->b_blkno = u.u_offset >> BSHIFT;
 * 	bp->b_bcount = u.u_count;
 * 	bp->b_error = 0;
 * 	u.u_procp->p_flag |= SLOCK;
 * 	(*strat)(bp);
 * 	spl6();
 * 	while ((bp->b_flags&B_DONE) == 0)
 * 		sleep((caddr_t)bp, PRIBIO);
 * 	u.u_procp->p_flag &= ~SLOCK;
 * 	if (bp->b_flags&B_WANTED)
 * 		wakeup((caddr_t)bp);
 * 	spl0();
 * 	bp->b_flags &= ~(B_BUSY|B_WANTED);
 * 	u.u_count = bp->b_resid;
 * 	geterror(bp);
 * 	return;
 *     bad:
 * 	u.u_error = EFAULT;
 * }
 */
/*
 * Raw I/O (MUTOS form): same arguments as V7.  The checks are those of V7 on the Z8001 layout (256-byte clicks, text size
 * not rounded, the stack test uses the saved stack pointer u_ar0[8]); the physical address is the user segment usrseg
 * (the device sees base and b_xmem).
 */
/* KERNEL 5F56 */
physio(strat, bp, dev, rw)
int (*strat)();
register struct buf *bp;
{
	register unsigned base;
	register nb;
	int ts;

	base = (unsigned)u.u_base;
	if ((base & 01) || (u.u_count & 0777) || u.u_count == 0 || base >= base + u.u_count)
		goto bad;
	ts = u.u_tsize;
	if (u.u_sep)
		ts = 0;
	nb = (base >> 8) & 0377;
	if (nb < ts)
		goto bad;
	if ((((base + u.u_count) >> 8) & 0377) >= ts + u.u_dsize && *(unsigned *)((char *)u.u_ar0 + 16) > (unsigned)u.u_base)
		goto bad;
	if (((u.u_count + 0377) >> 8) > 16)
		goto bad;
	spl6();
	while (bp->b_flags & B_BUSY) {
		bp->b_flags |= B_WANTED;
		sleep((caddr_t)bp, PRIBIO+1);
	}
	bp->b_flags = B_BUSY | B_PHYS | rw;
	bp->b_dev = dev;
	bp->b_un.b_addr = (caddr_t)base;
	bp->b_xmem = (usrseg >> 8) & 0377;
	bp->b_blkno = u.u_offset >> BSHIFT;
	bp->b_bcount = u.u_count;
	bp->b_error = 0;
	u.u_procp->p_flag |= SLOCK;
	(*strat)(bp);
	spl6();
	while ((bp->b_flags & B_DONE) == 0)
		sleep((caddr_t)bp, PRIBIO);
	u.u_procp->p_flag &= ~SLOCK;
	if (bp->b_flags & B_WANTED)
		wakeup((caddr_t)bp);
	spl0();
	bp->b_flags &= ~(B_BUSY|B_WANTED);
	u.u_count = bp->b_resid;
	geterror(bp);
	return;
bad:
	u.u_error = EFAULT;
}

/*
 * Pick up the device's error number and pass it to the user;
 * if there is an error but the number is 0 set a generalized
 * code.  Actually the latter is always true because devices
 * don't yet return specific errors.
 */
/* KERNEL 60A8 */
geterror(bp)
register struct buf *bp;
{

	if (bp->b_flags&B_ERROR)
		if ((u.u_error = bp->b_error)==0)
			u.u_error = EIO;
}
