/*
 * RK03/RK05 disk driver
 */

#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/conf.h"
#include "../h/dir.h"
#include "../h/user.h"

#define DK_N	1

struct	device {
	int	rkds;
	int	rker;
	int	rkcs;
	int	rkwc;
	caddr_t	rkba;
	int	rkda;
};

#define	RKADDR	((struct device *)0177400)
#define	NPDISK	2
#define	NLDISK	1	/* no subdivision into logical disks */
#define	NRKBLK	4872

/* rkcs bits */
#define	RESET		0000000
#define	GO		0000001
#define	WCOM		0000002
#define	RCOM		0000004
#define SEEK		0000010
#define	DRESET		0000014
#define	IENABLE		0000100
#define	CRDY		0000200
#define ERROR		0100000

/* rkds bits */
#define WPS		0000040
#define	DRDY		0000200

struct	buf	rktab;
struct	buf	rrkbuf;

rkopen(dev,rw)
dev_t dev;
{
	register struct device *rp;
	int dn,status;

	dn = minor(dev);
	if(dn >= NPDISK) {
		u.u_error = ENXIO;
		return;
	}
	rp = RKADDR;
	spl5();
	while((rp->rkcs&CRDY) == 0);
	rp->rkda = dn<<13;
	status = rp->rkds;
	spl0();
	if((status&DRDY) == 0) {
		u.u_error = ENXIO;
		return;
	}
	if(rw && (status&WPS)) {
		u.u_error = EROFS;
		return;
	}
}

rkclose(dev)
dev_t dev;
{
}

rkstrategy(bp)
register struct buf *bp;
{
#ifdef UNIBMAP
	if(bp->b_flags&B_PHYS)
		mapalloc(bp);
#endif UNIBMAP
	if(bp->b_blkno >= NRKBLK){
		bp->b_flags |= B_ERROR;
		bp->b_error = ENXIO;
		iodone(bp);
		return;
	}
	bp->av_forw = (struct buf *)NULL;
	spl5();
	if(rktab.b_actf == NULL)
		rktab.b_actf = bp;
	else
		rktab.b_actl->av_forw = bp;
	rktab.b_actl = bp;
	if(rktab.b_active == NULL)
		rkstart();
	spl0();
}

rkstart()
{
	register struct buf *bp;
	register com;
	int dn, cn, sn;
	daddr_t bn;

	if((bp = rktab.b_actf) == NULL)
		return;
	rktab.b_active++;
	bn = bp->b_blkno;
	dn = minor(bp->b_dev);
	cn = bn/12;
	sn = bn%12;
	RKADDR->rkda = (dn<<13) | (cn<<4) | sn;
	RKADDR->rkba = bp->b_un.b_addr;
	RKADDR->rkwc = -(bp->b_bcount>>1);
	com = ((bp->b_xmem&3) << 4) | IENABLE | GO;
	if(bp->b_flags&B_READ)
		com |= RCOM;
	else
		com |= WCOM;
	RKADDR->rkcs = com;
#ifdef INSTRM
	dk_busy |= 1<<DK_N;
	dk_numb[DK_N] += 1;
	dk_wds[DK_N] += (bp->b_bcount>>6);
#endif INSTRM
}

rkintr()
{
	register struct buf *bp;

	if(rktab.b_active == NULL)
		return;
#ifdef INSTRM
	dk_busy &= ~(1<<DK_N);
#endif INSTRM
	bp = rktab.b_actf;
	rktab.b_active = NULL;
	if(RKADDR->rkcs&ERROR) {
		deverror(bp, RKADDR->rker, RKADDR->rkds);
		RKADDR->rkcs = RESET|GO;
		while((RKADDR->rkcs&CRDY) == 0)
			;
		if(++rktab.b_errcnt <= 10){
			rkstart();
			return;
		}
		bp->b_flags |= B_ERROR;
	}
	rktab.b_errcnt = 0;
	rktab.b_actf = bp->av_forw;
	bp->b_resid = 0;
	iodone(bp);
	rkstart();
}

rkread(dev)
dev_t dev;
{
	physio(rkstrategy, &rrkbuf, dev, B_READ);
}

rkwrite(dev)
dev_t dev;
{
	physio(rkstrategy, &rrkbuf, dev, B_WRITE);
}
