/* rk.c -- devices behind the mailbox and /dev/mem (kernel mutos_1216, 69CE..6D44): mmread, mmwrite (cdevsw[2]),
 * rkopen, rkclose, rkstrategy, rkstart, rkintr, rkread, rkwrite (major 4, disk replacement through the mailbox D532 to the U880 side),
 * syopen, syread, sywrite, syioctl (/dev/tty).
 *
 * Origin:   partial
 * Source:   syopen, syread, sywrite, syioctl: UNIX V7 usr/sys/dev/sys.c (V7 text; V7 calls the last one sysioctl, MUTOS syioctl).
 *           mmread, mmwrite: UNIX V7 usr/sys/dev/mem.c in Z8001 form (user segment selection through usrseg instead of the PDP-11
 *           registers UISA/UISD; the V7 text is kept as a comment).  rkstrategy, rkintr, rkread, rkwrite: skeleton of V7
 *           usr/sys/dev/rk.c (queue handling, physio calls) with a different hardware access (mailbox instead of RK11 registers);
 *           rkopen, rkclose, rkstart: MUTOS own (no counterpart).  System III PDP-11 uts/pdp11/io/rk.c and sys.c: same skeleton as V7,
 *           no System III feature present.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): syread, sywrite, syioctl 100% against V7 sys.c, syopen 79%;
 *           mmread 45%, mmwrite 41% (mem.c); rkstrategy 42%, rkintr 24% (rk.c), rkread, rkwrite 100%; rkstart 15%, rkopen 31% (noise);
 *           file similarity 51% (V7 sys.c; ref-in-mut 90%).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/rk.md.
 * Deviations: see the comments before each function; the mailbox protocol and rkstart are own.
 *
 * Data: rktab 8E82 (layout as devtab, behind it: flag "command active" 8E8E, error counter 8E98), mailbox D532 (layout below),
 * rrkbuf CE94 (buffer for physio), usrseg 8DC0, cdevsw 8796.
 * Mailbox (design 39 sect. 11): +0 command, +1 unit, +2 direction (0 = read, 1 = write), +3 status (1 = ok, C8 = unit missing),
 * +4 segment, +6 address, +8 count, +A block number (long); rkstart starts it through mapalloc(mp, 0) (5CAE). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "inode.h"
#include "proc.h"
#include "buf.h"
#include "conf.h"
#include "mbx.h"

struct rkt {
	char		rk_active;
	char		rk_errcnt;
	struct buf	*rk_forw;
	struct buf	*rk_back;
	struct buf	*rk_actf;
	struct buf	*rk_actl;
	int		rk_x;
	int		rk_busy;	/* 8E8E */
	int		rk_y[4];
	unsigned	rk_errs;	/* 8E98 */
};
extern struct rkt rktab;
extern struct buf rrkbuf;
extern int usrseg;
#define MBX	((struct rkmbx *)0xD532)

/*
 *	Memory special file
 *	minor device 0 is physical memory
 *	minor device 1 is kernel memory
 *	minor device 2 is EOF/RATHOLE
 *
 * MUTOS: V7 programs the PDP-11 segment registers (UISA->r[0] = bn and so on);
 * here usrseg selects the Z8001 segment for the user byte access: bn = offset >> 16
 * is the segment number, on = offset & 0xFFFF the offset (minor 1: segment 0).
 * V7 text of the access:
 *	bn = u.u_offset >> 6;
 *	on = u.u_offset & 077;
 *	a = UISA->r[0];
 *	d = UISD->r[0];
 *	spl7();
 *	UISA->r[0] = bn;
 *	UISD->r[0] = 077406;
 *	if(minor(dev) == 1)
 *		UISA->r[0] = (ka6-6)->r[(bn>>7)&07] + (bn & 0177);
 *	if ((c = fuibyte((caddr_t)on)) < 0)
 *		u.u_error = ENXIO;
 *	UISA->r[0] = a;
 *	UISD->r[0] = d;
 *	spl0();
 */
/* KERNEL 69CE */
mmread(dev)
dev_t dev;
{
	register c, bn, on;
	int a, d;

	if (minor(dev) == 2)
		return;
	do {
		bn = u.u_offset >> 16;
		on = u.u_offset;
		a = usrseg;
		spl7();
		usrseg = bn << 8;
		if (minor(dev) == 1)
			usrseg = 0;
		c = fubyte(on);
		if (c < 0)
			u.u_error = ENXIO;
		usrseg = a;
		spl0();
	} while (u.u_error == 0 && passc(c) >= 0);
}

/* KERNEL 6A52 */
mmwrite(dev)
dev_t dev;
{
	register c, bn, on;
	int a, d;

	if (minor(dev) == 2) {
		u.u_count = 0;
		return;
	}
	for (;;) {
		bn = u.u_offset >> 16;
		on = u.u_offset;
		c = cpass();
		if (c < 0)
			return;
		if (u.u_error)
			return;
		a = usrseg;
		spl7();
		usrseg = bn << 8;
		if (minor(dev) == 1)
			usrseg = 0;
		if (subyte(on, c) < 0)
			u.u_error = ENXIO;
		usrseg = a;
		spl0();
	}
}

/*
 * MUTOS: no V7 counterpart (V7 rk.c has no open; the driver is entered
 * through rkstrategy).  Four units.
 */
/* KERNEL 6ADA */
rkopen(dev)
dev_t dev;
{
	int d, x;

	d = minor(dev);
	if (d >= 4)
		u.u_error = ENXIO;
}

/* MUTOS: empty */
/* KERNEL 6AFE */
rkclose(dev)
dev_t dev;
{
	register i;
}

/*
 * V7 rkstrategy: map the buffer if B_PHYS (mapalloc), reject blocks
 * >= NRKBLK (4872) with B_ERROR, append to the queue (b_actf / b_actl) with
 * spl5, start the device if it is idle.  MUTOS: limit 0x260 blocks (608),
 * additionally b_error = ENXIO; the idle flag is rk_busy; no mapalloc here
 * (rkstart does it).
 */
/* KERNEL 6B06 */
rkstrategy(bp)
register struct buf *bp;
{
	if (bp->b_blkno >= 0x260L) {
		bp->b_flags |= B_ERROR;
		bp->b_error = ENXIO;
		iodone(bp);
		return;
	}
	bp->av_forw = NULL;
	spl5();
	if (rktab.rk_actf == NULL)
		rktab.rk_actf = bp;
	else
		rktab.rk_actl->av_forw = bp;
	rktab.rk_actl = bp;
	if (rktab.rk_busy == 0)
		rkstart();
	spl0();
}

/*
 * V7 rkstart computes cylinder and sector and programs the RK11 registers
 * (rkda, rkba, rkwc, rkcs).  MUTOS: fills the mailbox and hands it to the U880
 * side through mapalloc(mp, 0).  Own code.
 */
/* KERNEL 6B60 */
rkstart()
{
	register struct rkmbx *mp;
	register struct buf *bp;
	int pad[5];

	if ((bp = rktab.rk_actf) == NULL)
		return;
	mp = MBX;
	rktab.rk_busy++;
	mp->mb_cmd = 0;
	mp->mb_unit = minor(bp->b_dev);
	mp->mb_stat = 0;
	mp->mb_seg = bp->b_xmem;
	mp->mb_addr = bp->b_un.b_addr;
	mp->mb_cnt = bp->b_bcount;
	mp->mb_blk = bp->b_blkno;
	if (bp->b_flags & B_READ)
		mp->mb_dir = 0;
	else
		mp->mb_dir = 1;
	mapalloc(mp, 0);
}

/*
 * V7 rkintr: on an error bit call deverror, reset the controller, retry up
 * to 10 times, then set B_ERROR; on success advance the queue, b_resid = 0,
 * iodone, start the next one.  MUTOS: same sequence with the mailbox status
 * (1 = ok, 0xC8 = unit missing -> ENXIO) and at most 3 retries.
 */
/* KERNEL 6BCA */
rkintr()
{
	register c1, c2;
	register struct buf *bp;
	register struct rkmbx *mp;

	if (rktab.rk_busy == 0)
		return;
	mp = MBX;
	bp = rktab.rk_actf;
	rktab.rk_busy = 0;
	if (mp->mb_stat != 1) {
		if (mp->mb_stat == 0xC8) {
			bp->b_error = ENXIO;
		fail:
			bp->b_flags |= B_ERROR;
		} else {
			c1 = mp->mb_dir;
			c2 = mp->mb_stat;
			deverror(bp, c1 & 0377, c2 & 0377);
			if (++rktab.rk_errs > 3) {
				goto fail;
			}
			rkstart();
			return;
		}
	}
	rktab.rk_errs = 0;
	rktab.rk_actf = bp->av_forw;
	bp->b_resid = 0;
	iodone(bp);
	rkstart();
}

/* KERNEL 6C52 */
rkread(dev)
dev_t dev;
{
	physio(rkstrategy, &rrkbuf, dev, B_READ);
}

/* KERNEL 6C70 */
rkwrite(dev)
dev_t dev;
{
	physio(rkstrategy, &rrkbuf, dev, B_WRITE);
}

/*
 *	indirect driver for controlling tty.
 */
/* KERNEL 6C8E */
syopen(dev, flag)
{

	if(u.u_ttyp == NULL) {
		u.u_error = ENXIO;
		return;
	}
	(*cdevsw[major(u.u_ttyd)].d_open)(u.u_ttyd, flag);
}

/* KERNEL 6CC6 */
syread(dev)
{

	(*cdevsw[major(u.u_ttyd)].d_read)(u.u_ttyd);
}

/* KERNEL 6CEC */
sywrite(dev)
{

	(*cdevsw[major(u.u_ttyd)].d_write)(u.u_ttyd);
}

/* V7 name: sysioctl */
/* KERNEL 6D12 */
syioctl(dev, cmd, addr, flag)
caddr_t addr;
{

	(*cdevsw[major(u.u_ttyd)].d_ioctl)(u.u_ttyd, cmd, addr, flag);
}
