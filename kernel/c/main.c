/* main.c -- system start (kernel mutos_1216, 0674..087A): main, iinit, binit.  cinit (3D04) is behind pipe.c in the kernel,
 * see ureg.c.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/main.c (main, iinit) and usr/sys/dev/bio.c (binit, kept here by the kernel's module order;
 *           V7 has "char buffers[NBUF][BSIZE+BSLOP]" before binit in main.c).  System III PDP-11 uts/os/main.c differs
 *           (var.h, sysinfo, user area set-up) and is not used.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 79% V7 / 44% System III PDP-11 (before the
 *           restoration); main 83%, iinit 75%, binit 93% against V7 (System III 74%, 40%, 26%).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/main.md.
 * Deviations: Z8001 start-up (proc[0] has no core image: p_addr 0, p_size 0; kstub() instead of clkstart()); icode/szicode
 *           placement; binit clears b_error and uses a devtab pointer; see doc/herkunft/main.md.
 *
 * Data: proc[0] = A11C, rootdir = 8DC6, szicode = 8B4C, icode = 8B32 (the string "/etc/init" starts at 8B42), rootdev 887C,
 * text 88C6 "iinit", buffers: buf = 8E9A (24 bytes each), data buffers buffers = A628 (512 bytes each), bfreelist = A518,
 * mount[0] = A07E (m_dev, m_bufp), time = 8DCC. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "filsys.h"
#include "mount.h"
#include "map.h"
#include "proc.h"
#include "inode.h"
#include "text.h"
#include "file.h"
#include "conf.h"
#include "buf.h"

#define btoc(x)		((unsigned)((x)+255)>>8)	/* MUTOS: 256-byte click (V7: 64 bytes); not in param.h */
#define USIZE		4	/* MUTOS: 4 clicks (1 KB) user area; not in param.h */
#define RO		2	/* MUTOS: estabur protection argument, the kernel passes 2 */

extern char icode[];
extern int szicode;
extern struct inode *rootdir;
extern char buffers[NBUF][512];	/* MUTOS: defined in the data module; V7: char buffers[NBUF][BSIZE+BSLOP] */

/*
 * Initialization code.
 * Called from cold start routine as
 * soon as a stack and segmentation
 * have been established.
 * Functions:
 *	clear and free user core
 *	turn on clock
 *	hand craft 0th process
 *	call all initialization routines
 *	fork - process 0 to schedule
 *	     - process 1 execute bootstrap
 *
 * loop at low address in user mode -- /etc/init
 *	cannot be executed.
 */
/* KERNEL 0674 */
main()
{

	startup();
	/*
	 * set up system process
	 */

	proc[0].p_addr = 0;	/* MUTOS: V7 ka6->r[0] */
	proc[0].p_size = 0;	/* MUTOS: V7 USIZE */
	proc[0].p_stat = SRUN;
	proc[0].p_flag |= SLOAD|SSYS;
	proc[0].p_nice = NZERO;
	u.u_procp = &proc[0];
	u.u_cmask = CMASK;

	/*
	 * Initialize devices and
	 * set up 'known' i-nodes
	 */

	kstub();	/* MUTOS: V7 clkstart(); the Z8001 clock is started elsewhere (empty stub) */
	spl0();	/* MUTOS: not in V7 (purpose assumed: enable interrupts after the clock is started) */
	cinit();
	binit();
	iinit();
	rootdir = iget(rootdev, (ino_t)ROOTINO);
	rootdir->i_flag &= ~ILOCK;
	u.u_cdir = iget(rootdev, (ino_t)ROOTINO);
	u.u_cdir->i_flag &= ~ILOCK;
	u.u_rdir = NULL;

	/*
	 * make init process
	 * enter scheduling loop
	 * with system process
	 */

	if(newproc()) {
		expand(USIZE + (int)btoc(szicode));
		estabur((unsigned)0, btoc(szicode), (unsigned)0, 0, RO);
		copyout((caddr_t)icode, (caddr_t)0, szicode);
		/*
		 * Return goes to loc. 0 of user init
		 * code just copied out.
		 */
		return;
	}
	sched();
}

/*
 * iinit is called once (from main)
 * very early in initialization.
 * It reads the root's super block
 * and initializes the current date
 * from the last modified date.
 *
 * panic: iinit -- cannot read the super
 * block. Usually because of an IO error.
 */
/* KERNEL 0746 */
iinit()
{
	register struct buf *cp, *bp;
	register struct filsys *fp;

	(*bdevsw[major(rootdev)].d_open)(rootdev, 1);
	bp = bread(rootdev, (daddr_t)SUPERB);	/* MUTOS: cast, SUPERB is an int here (see param.h) */
	cp = geteblk();
	if(u.u_error)
		panic("iinit");
	bcopy(bp->b_un.b_addr, cp->b_un.b_addr, sizeof(struct filsys));
	brelse(bp);
	mount[0].m_bufp = cp;
	mount[0].m_dev = rootdev;
	fp = cp->b_un.b_filsys;
	fp->s_flock = 0;
	fp->s_ilock = 0;
	fp->s_ronly = 0;
	time = fp->s_time;
}

/*
 * Initialize the buffer I/O system by freeing
 * all buffers and setting all device buffer lists to empty.
 */
/* KERNEL 07D2 */
binit()
{
	register struct buf *bp;
	register struct devtab *dp;	/* MUTOS: devtab pointer (V7: struct buf *) */
	register int i;
	struct bdevsw *bdp;

	bfreelist.b_forw = bfreelist.b_back =
	    bfreelist.av_forw = bfreelist.av_back = &bfreelist;
	for (i=0; i<NBUF; i++) {
		bp = &buf[i];
		bp->b_dev = NODEV;
		bp->b_un.b_addr = buffers[i];
		bp->b_error = 0;	/* MUTOS: not in V7 */
		bp->b_back = &bfreelist;
		bp->b_forw = bfreelist.b_forw;
		bfreelist.b_forw->b_back = bp;
		bfreelist.b_forw = bp;
		bp->b_flags = B_BUSY;
		brelse(bp);
	}
	for (bdp = bdevsw; bdp->d_open; bdp++) {
		dp = bdp->d_tab;
		if(dp) {
			dp->b_forw = (struct buf *)dp;
			dp->b_back = (struct buf *)dp;
		}
		nblkdev++;
	}
}
