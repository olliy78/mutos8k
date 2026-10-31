/* dev0.c -- driver for major 0 / cdevsw[10] (kernel mutos_1216, 7E16..8760, never reached in the run): floppy disk through the mailbox.
 *
 * Origin:   none
 * Source:   none.  MUTOS own driver (floppy controller of the U880 side behind the mailbox).  No UNIX V7 or System III counterpart:
 *           V7 has no floppy driver; the nearest V7 / System III files are the tape and disk drivers tm.c / ht.c / rk.c (shape of the
 *           strategy / start / interrupt triple and of physio) and WEGA dev/fd.c (the controller's command codes and the idea of a
 *           mailbox command table are possibly related; *assumed*, not measured).  Possible relatives for AP H6: WEGA dev/fd.c (P8000),
 *           UDOS / U880 side of the A5120 (mutos_io).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): no function reaches 50% against V7 except fdsub (62% against tcommand
 *           of tm.c) and fdioctl (51% against mpxchan): both are matches on short generic patterns, not a common origin.  File
 *           similarity: V7 16% (dsort.c), System III 16% (ht.c), WEGA 18% (mt.c) / 10% (fd.c).
 * Roundtrip: not in rundlauf_soll.txt (the module is compiled WITHOUT the optimiser in the original); checked by the full build only;
 *           see doc/herkunft/dev0.md.
 * Deviations: not applicable (no origin).
 *
 * fdopen 7E16, fdclose 7E94, fdsub 7F00, fdstrategy 7F94, fdstart 7FDC, fdintr 821A, fdadj 8468, fdread 84E4, fdwrite 851C, fdphys 8554, fdioctl 85B0.
 * fdintr and fdadj have no caller in the kernel via the call map (fdintr comes from the interrupt) and were therefore not in
 * funktionen.txt; the overview (uebersicht.py) does not count them.
 * This module is compiled WITHOUT the optimiser in the kernel (all jumps JP instead of JR, body behind a `JP` at the start of the function): when
 * comparing, use the line without -O (file <name>.o), not <name>O.o.
 * Data: fdtab 8E6A (struct buf head like rktab; b_bcount 8E76 = state, b_resid 8E80 = retries), fdu D566 (16 bytes per drive, 1 drive),
 * fdmbx D558 (mailbox 14 bytes), fdbuf D540 (buffer for fdsub), rfdbuf CEAC (physio).  The table fdcmd 8D6A and the jump tables of the
 * switch statements (8D5E, 8D64, 8D78, 8D88) lie behind the tables of tty2.c. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "buf.h"
#include "conf.h"
#include "mbx.h"

struct fdu {
	char		fu_flag;	/* 00 open */
	char		fu_x1;		/* 01 */
	daddr_t		fu_blk;		/* 02 */
	unsigned	fu_x6;		/* 06 (unsigned: fdstart compares with LD R5 / XOR R4,R4) */
	int		fu_x8, fu_xa, fu_xc;
	int		fu_init;	/* 0E */
};
extern struct fdu fdu[1];		/* D566 */
extern struct rkmbx fdmbx[1];		/* D558 */
extern struct buf fdbuf, rfdbuf, fdtab;	/* D540, CEAC, 8E6A */

/* KERNEL 7E16 */
fdopen(dev, flag)
dev_t dev;
{
	register d;
	register struct rkmbx *mp;
	register struct fdu *fp;

	d = dev & 7;
	if (d >= 1 || (fp = &fdu[d])->fu_flag) {
		u.u_error = ENXIO;
		return;
	}
	if (fp->fu_init == 0) {
		mp = &fdmbx[d];
		mp->mb_stat = 1;
		fp->fu_init = 1;
	}
	fdtab.b_flags |= 0x400;
	fp->fu_flag = 1;
	fp->fu_blk = 0;
	fp->fu_x6 = 0x7FFF;
	fp->fu_x1 = 0;
}

/* KERNEL 7E94 */
fdclose(dev, flag)
register dev, flag;
{
	register struct fdu *fp;

	fp = &fdu[dev & 7];
	if (flag == 2 || ((flag & 2) && fp->fu_x1))
		fdsub(dev, 0x61, 1);
	if ((dev & 0x80) == 0)
		fdsub(dev, 0x51, 0);
	fp->fu_flag = 0;
}

/* KERNEL 7F00 */
fdsub(dev, a, b)
{
	register struct buf *bp;

	bp = &fdbuf;
	spl5();
	while (bp->b_flags & B_BUSY) {
		if (bp->b_bcount == 0 && (bp->b_flags & B_DONE))
			break;
		bp->b_flags |= B_WANTED;
		sleep(bp, PRIBIO);
	}
	bp->b_flags = B_BUSY | B_READ;
	spl0();
	bp->b_dev = dev;
	bp->b_bcount = b;
	bp->b_resid = a;
	bp->b_blkno = 0;
	fdstrategy(bp);
	if (b) {
		iowait(bp);
		if (bp->b_flags & B_WANTED)
			wakeup(bp);
		bp->b_flags &= B_ERROR;
	}
}

/* KERNEL 7F94 */
fdstrategy(bp)
register struct buf *bp;
{
	bp->av_forw = NULL;
	spl5();
	if (fdtab.av_forw == NULL)
		fdtab.av_forw = bp;
	else
		fdtab.av_back->av_forw = bp;
	fdtab.av_back = bp;
	if (fdtab.b_bcount == 0)
		fdstart();
	spl0();
}

/* fdstart: take the next request from fdtab and start it through the mailbox (fdtab.b_bcount = state: 1 seek, 2 read/write,
 * 3 controller command (fdbuf), 4 command 51H); fdtab.b_resid counts retries.  b_resid of the request carries the mailbox command
 * (25H/27H track forward/back, 0/1 read/write, otherwise the controller commands of fdsub). */
/* KERNEL 7FDC */
fdstart()
{
	register struct fdu *fp;
	register struct rkmbx *mp;
	register struct buf *bp;
	int d, x;
	long lb;

	while ((bp = fdtab.av_forw) != NULL) {
		d = bp->b_dev & 7;
		fp = &fdu[d];
		mp = &fdmbx[d];
		fp->fu_x8 = mp->mb_stat;
		fp->fu_xa = mp->mb_dir;
		fp->fu_xc = mp->mb_cnt;
		fp->fu_x1 = 0;
		if (mp->mb_stat == 0xF5 && fdtab.b_bcount == 2) {
			bp->b_resid = 0x25;
			mp->mb_cnt = 1;
			fdtab.b_bcount = 1;
			goto issue;
		}
		if (fp->fu_flag == -1 || fp->fu_x8 == 0) {
			bp->b_flags |= B_ERROR;
			goto done;
		}
		if (bp == &fdbuf) {
			if (bp->b_resid == 6)
				goto done;
			if (bp->b_resid == 0x51)
				fdtab.b_bcount = 4;
			else
				fdtab.b_bcount = 3;
			if (bp->b_resid == 0x25 || bp->b_resid == 0x27)
				mp->mb_cnt = bp->b_bcount;
			goto issue;
		}
		if (bp->b_blkno > fp->fu_x6) {
			bp->b_flags |= B_ERROR;
			bp->b_error = ENXIO;
			goto done;
		}
		if (bp->b_blkno == fp->fu_x6 && (bp->b_flags & B_READ)) {
			bp->b_resid = bp->b_bcount;
			clrbuf(bp);
			goto done;
		}
		if ((bp->b_flags & B_READ) == 0)
			fp->fu_x6 = (int)bp->b_blkno + 1;
		lb = fp->fu_blk;
		if (lb == bp->b_blkno) {
			if ((bp->b_flags & B_READ) == 0) {
				if (fdtab.b_resid)
					x = 1;
				else
					x = 1;
			} else
				x = 0;
			fdtab.b_bcount = 2;
			mp->mb_cnt = bp->b_bcount;
			mp->mb_addr = bp->b_un.b_addr;
			mp->mb_seg = bp->b_xmem & 3;
			bp->b_resid = x;
			goto issue;
		}
		fdtab.b_bcount = 1;
		if (lb < bp->b_blkno) {
			bp->b_resid = 0x25;
			mp->mb_cnt = (int)bp->b_blkno - (int)lb;
		} else {
			bp->b_resid = 0x27;
			mp->mb_cnt = (int)lb - (int)bp->b_blkno;
		}
	issue:
		mp->mb_cmd = 6;
		mp->mb_unit = d;
		mp->mb_dir = bp->b_resid;
		mp->mb_stat = 0;
		mapalloc(mp, 6);
		return;
	done:
		fdtab.av_forw = bp->av_forw;
		iodone(bp);
	}
}

/* fdintr: end of a mailbox request (interrupt; no caller in the kernel, never run) */
/* KERNEL 821A */
fdintr()
{
	register struct rkmbx *mp;
	register struct buf *bp;
	register struct fdu *fp;
	register s;
	int d;

	if ((bp = fdtab.av_forw) == NULL)
		return;
	d = bp->b_dev & 7;
	fp = &fdu[d];
	mp = &fdmbx[d];
	if (fdtab.b_bcount == 4) {
		fdtab.b_bcount = 3;
		if (mp->mb_stat == 0)
			return;
	}
	fp->fu_xa = mp->mb_dir;
	fp->fu_x8 = mp->mb_stat;
	fp->fu_xc = mp->mb_cnt;
	if ((bp->b_flags & B_READ) == 0)
		fp->fu_x1 = 1;
	s = fdtab.b_bcount;
	fdtab.b_bcount = 0;
	if (mp->mb_stat == 1)
		goto ok;
	if (mp->mb_stat == 0xF5) {
		fdadj(bp);
		if (s == 2) {
			fdtab.b_bcount = s;
			fdstart();
			return;
		}
		s = 3;
		fp->fu_xc = 0;
		mp->mb_cnt = 0;
		goto fin;
	}
	if (bp == &rfdbuf && (bp->b_flags & B_READ) && mp->mb_stat == 0xF6)
		goto ok;
	if (!(mp->mb_stat == 0xC1 && mp->mb_stat == 0xF3) && s == 2) {
		if (++fdtab.b_resid < 7) {
			fp->fu_blk++;
			goto start;
		}
		goto report;
	}
	if (fp->fu_flag && bp != &rfdbuf)
		fp->fu_flag = -1;
report:
	printf("tm%d: bn = %d %d old er = %x err stat = %x\n", d, bp->b_blkno, fp->fu_x8, mp->mb_stat & 0377);
	bp->b_flags |= B_ERROR;
	goto fin;
ok:
	switch (s) {

	case 2:
		fp->fu_blk++;
		goto fin;

	case 3:
		if (bp == &fdbuf) {
			switch (bp->b_resid) {
			case 0x25:
				fp->fu_blk -= bp->b_bcount;
				break;
			case 0x27:
				fp->fu_blk += bp->b_bcount;
				break;
			}
		}
		goto fin;

	case 1:
		fp->fu_blk = bp->b_blkno;
		goto start;

	default:
		printf("tmintr\n");
		bp->b_flags |= B_ERROR;
	}
fin:
	fdtab.b_resid = 0;
	fdtab.av_forw = bp->av_forw;
	bp->b_resid = bp->b_bcount - mp->mb_cnt;
	iodone(bp);
	if (fdtab.av_forw == 0)
		return;
start:
	fdstart();
}

/* fdadj: update the block number after a seek error.  In the kernel `mp` (R12) is NOT assigned: the function reads the R12 of its
 * caller fdintr (there: bp); rebuilt here the same way as an uninitialised register variable. */
/* KERNEL 8468 */
fdadj(bp)
register struct buf *bp;
{
	register struct rkmbx *mp;
	register struct fdu *fp;

	fp = &fdu[bp->b_dev & 7];
	if (bp == &fdbuf) {
		if (fp->fu_blk > bp->b_blkno) {
			fp->fu_blk -= mp->mb_cnt;
			fp->fu_x6 = (int)fp->fu_blk;
		} else {
			fp->fu_blk += mp->mb_cnt;
			fp->fu_x6 = (int)fp->fu_blk - 1;
		}
	} else
		fp->fu_x6 = (int)bp->b_blkno;
}

/* KERNEL 84E4 */
fdread(dev)
dev_t dev;
{
	fdphys(dev);
	if (u.u_error)
		return;
	physio(fdstrategy, &rfdbuf, dev, B_READ);
}

/* KERNEL 851C */
fdwrite(dev)
dev_t dev;
{
	fdphys(dev);
	if (u.u_error)
		return;
	physio(fdstrategy, &rfdbuf, dev, B_WRITE);
}

/* KERNEL 8554 */
fdphys(dev)
dev_t dev;
{
	register d;
	register struct fdu *fp;
	long lb;

	d = dev & 7;
	if (d >= 1) {
		u.u_error = ENXIO;
		return;
	}
	fp = &fdu[d];
	lb = u.u_offset >> 9;
	fp->fu_blk = lb;
	fp->fu_x6 = (int)lb + 1;
}

/* Mailbox commands of fdioctl 6D01 (command 0..6): read track 61H, 45H, 47H, 25H/27H track forward/back, 51H, 6 */
int fdcmd[] = { 0x61, 0x45, 0x47, 0x25, 0x27, 0x51, 6 };

/* fdioctl: 6D01 request to the controller (command code, count), 6D02 read the state */
/* KERNEL 85B0 */
fdioctl(dev, cmd, arg, flag)
dev_t dev;
caddr_t arg;
{
	register struct fdu *fp;
	register struct buf *bp;
	register n;
	int d, x;
	int lv[2];
	int info[8];

	d = dev & 7;
	fp = &fdu[d];
	bp = &fdbuf;
	switch (cmd) {

	case 0x6D01:
		if (copyin(arg, (caddr_t)lv, 4)) {
			u.u_error = EFAULT;
			return;
		}
		switch (lv[0]) {
		case 0:
			n = lv[1];
			x = 1;
			break;
		case 1:
		case 2:
			n = lv[1];
			x = 0x7FFF;
			break;
		case 3:
		case 4:
			n = 1;
			x = lv[1];
			break;
		case 5:
		case 7:
			n = 1;
			x = 1;
			break;
		default:
			u.u_error = ENXIO;
			return;
		}
		if (n <= 0 || x == 0) {
			u.u_error = ENXIO;
			return;
		}
		while (--n >= 0) {
			fdsub(dev, fdcmd[lv[0]], x);
			if ((lv[0] == 3 || lv[0] == 4) && bp->b_resid) {
				u.u_error = EIO;
				break;
			}
			if (bp->b_flags & B_ERROR)
				break;
			if (fp->fu_x8 & 0xF4)
				break;
		}
		geterror(bp);
		return;

	case 0x6D02:
		info[1] = fp->fu_xa;
		info[2] = fp->fu_x8;
		info[3] = fp->fu_xc;
		info[0] = 4;
		if (copyout((caddr_t)info, arg, 16))
			u.u_error = EFAULT;
		return;

	default:
		u.u_error = ENXIO;
	}
}
