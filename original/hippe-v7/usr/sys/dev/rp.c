#
/*
 * RP02/RP03 disk driver
 */

#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/dir.h"
#include "../h/conf.h"
#include "../h/user.h"

#define	DK_N	2
#define RP03

struct device {
	int	rpds;
	int	rper;
	union {
		int	w;
		char	c;
	} rpcs;
	int	rpwc;
	char	*rpba;
	int	rpca;
	int	rpda;
};

#define RPADDR ((struct device *) 0176710)
#define	NPDISK	1
#define	NLDISK	1

#ifdef RP02
#define NSECT	10
#define NTRAC	20
#define NCYLN	406
#endif RP02

#ifdef RP03
#define NSECT	10
#define NTRAC	20
#define NCYLN	406
#endif RP03

struct sizes {
	int	cyloff;
	daddr_t	nblocks;
} rp_sizes[8] = {
	0,	(daddr_t)NSECT*NTRAC*NCYLN,	/* whole pack */
	0,	0,
};

#define	GO	01
#define	RESET	0
#define	HSEEK	014

#define	IENABLE	0100
#define	READY	0200
#define	RCOM	4
#define	WCOM	2

#define	SUFU	01000
#define	SUSU	02000
#define	SUSI	04000
#define	HNF	010000

struct	buf	rptab;
struct	buf	rrpbuf;

/*
 * Use av_back to save track+sector,
 * b_resid for cylinder.
 */
#define	trksec	av_back
#define	cylin	b_resid

rpstrategy(bp)
register struct buf *bp;
{
	register struct buf *dp;
	register int unit;
	long sz;
	daddr_t bn;

#ifdef UNIBMAP
	if(bp->b_flags&B_PHYS)
		mapalloc(bp);
#endif UNIBMAP
	unit = minor(bp->b_dev);
	sz = bp->b_bcount;
	sz = (sz+511)>>9;
	bn = bp->b_blkno;
	if((pdisk(unit) >= NPDISK) || (ldisk(unit) >= NLDISK)
	 ||(bn < 0) || (bn+sz > rp_sizes[ldisk(unit)].nblocks)) {
		bp->b_flags |= B_ERROR;
		iodone(bp);
		return;
	}
	bp->av_forw = NULL;
	spl5();
	dp = & rptab;
	if (dp->b_actf == NULL)
		dp->b_actf = bp;
	else
		dp->b_actl->av_forw = bp;
	dp->b_actl = bp;
	if (dp->b_active == NULL)
		rpstart();
	spl0();
}

rpstart()
{
	register struct buf *bp;
	register int unit;
	int com,cn,tn,sn,dn;
	daddr_t bn;


	if ((bp = rptab.b_actf) == NULL)
		return;
	rptab.b_active++;
	unit = minor(bp->b_dev);
	dn = pdisk(unit);
	bn = bp->b_blkno;
	cn = bn/(NSECT*NTRAC) + rp_sizes[ldisk(unit)].cyloff;
	sn = bn%(NSECT*NTRAC);
	tn = sn/NSECT;
	sn = sn%NSECT;
	RPADDR->rpcs.w = (dn<<8);
	RPADDR->rpda = (tn<<8) | sn;
	RPADDR->rpca = cn;
	RPADDR->rpba = bp->b_un.b_addr;
	RPADDR->rpwc = -(bp->b_bcount>>1);
	com = ((bp->b_xmem&3)<<4) | IENABLE | GO;
	if (bp->b_flags & B_READ)
		com |= RCOM; else
		com |= WCOM;
	RPADDR->rpcs.w |= com;
#ifdef INSTRM
	dk_busy |= 1<<DK_N;
	dk_numb[DK_N] += 1;
	dk_wds[DK_N] += (bp->b_bcount >> 6);
#endif INSTRM
}

rpintr()
{
	register struct buf *bp;
	register int ctr;

	if (rptab.b_active == NULL)
		return;
#ifdef INSTRM
	dk_busy &= ~(1<<DK_N);
#endif INSTRM
	bp = rptab.b_actf;
	rptab.b_active = NULL;
	if (RPADDR->rpcs.w < 0) {		/* error bit */
		deverror(bp, RPADDR->rper, RPADDR->rpds);
		if(RPADDR->rpds & (SUFU|SUSI|HNF)) {
			RPADDR->rpcs.c = HSEEK|GO;
			ctr = 0;
			while ((RPADDR->rpds&SUSU) && --ctr)
				;
		}
		RPADDR->rpcs.w = RESET|GO;
		ctr = 0;
		while ((RPADDR->rpcs.w&READY) == 0 && --ctr)
			;
		if (++rptab.b_errcnt <= 10) {
			rpstart();
			return;
		}
		bp->b_flags |= B_ERROR;
	}
	rptab.b_errcnt = 0;
	rptab.b_actf = bp->av_forw;
	bp->b_resid = 0;
	iodone(bp);
	rpstart();
}

rpread(dev)
{

	physio(rpstrategy, &rrpbuf, dev, B_READ);
}

rpwrite(dev)
{

	physio(rpstrategy, &rrpbuf, dev, B_WRITE);
}
