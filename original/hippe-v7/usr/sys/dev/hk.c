#

/*
 * RK06/RK07 disk driver
 */

#include "../h/param.h"
#include "../h/buf.h"
#include "../h/conf.h"
#include "../h/dir.h"
#include "../h/user.h"

#define DK_N	2
#define RK07

struct device {
	int	hkcs1;	/* Control and Status register 1 */
	int	hkwc;	/* Word count register */
	int	hkba;	/* UNIBUS address register */
	int	hkda;	/* Desired address register */
	int	hkcs2;	/* Control and Status register 2*/
	int	hkds;	/* Drive Status */
	int     hker;   /* Error register 1 */
	int	hkas;	/* Attention Summary */
	int     hkdc;   /* Desired cylinder */
	int     hkuu;   /* Unused */
	int	hkdb;	/* Data buffer */
	int     hkmr1;  /* Maintenance register 1 */
	int     hkecps; /* Error correction position */
	int     hkecpat;/* Error correction pattern */
	int     hkmr2;  /* Maintenance register 2 */
	int     hkmr3;  /* Maintenance register 3 */
};

#define HKADDR  ((struct device *) 0177440)
#define	NPDISK	2
#define	NLDISK	1

#ifdef RK06
#define NSECT	20
#define NTRAC	3
#define NCYLN	411
#define CDT	0
#endif RK06

#ifdef RK07
#define NSECT	22
#define NTRAC	3
#define NCYLN	815
#define CDT	02000
#endif RK07

struct sizes {
	int	cyloff;
	daddr_t	nblocks;
} hk_sizes[8] = {
	0,	(daddr_t)NSECT*NTRAC*NCYLN,	/* whole pack */
	0,	0,
};

struct	buf	hktab;
struct	buf	hkbuf;

/* hkcs1 bits */
#define GO      01      /* Start */
#define IE      0100    /* Interrupt enable */
#define RDY     0200    /* Controller ready */
#define DI      040000  /* Drive interrupt */
#define ERRCLR  0100000 /* Combined error / Controller clear */
/* Also has functions (below) and mem adr extension */
#define PACKACK 2       /* Pack Acknowledge function */
#define RD      020     /* Read function */
#define WRT     022     /* Write function */
#define SEL     0       /* Select/Release */
#define RECAL   012     /* Recalibrate */
#define DRCLR   04      /* Drive Clear */

/* hkcs2 bits */
#define RLS     010     /* Drive release */
#define SCLR    040     /* Subsystem clear */

/* hkds bits */
#define DRA     01      /* Drive available */
#define VV      0100    /* Volume Valid */
#define DRDY    0200    /* drive ready */
#define PIP     020000  /* Positioning Operation in Progress */
#define SVAL    0100000 /* Status valid */

/* hker bits */
#define DTE     010000  /* Drive timing error */
#define OPI     020000  /* Operation incomplete */
#define DU      040000  /* Drive unsafe */

hkstrategy(bp)
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
	sz = (bp->b_bcount + 511)>>9;
	bn = bp->b_blkno;
	if((pdisk(unit) >= NPDISK) || (ldisk(unit) >= NLDISK)
	  || (bn < 0) || (bn+sz > hk_sizes[ldisk(unit)].nblocks)) {
		bp->b_flags |= B_ERROR;
		iodone(bp);
		return;
	}
	bp->av_forw = NULL;
	spl5();
	dp = &hktab;
	if(dp->b_actf == NULL)
		dp->b_actf = bp;
	else
		dp->b_actl->av_forw = bp;
	dp->b_actl = bp;
	if(dp->b_active == NULL)
		hkstart();
	spl0();
}

hkstart()
{
	register struct buf *bp;
	register int unit;
	int cn,tn,sn,dn;
	daddr_t bn;

	if((bp = hktab.b_actf) == NULL)
		return;
	hktab.b_active++;
	unit = minor(bp->b_dev);
	dn = pdisk(unit);
	bn = bp->b_blkno;
	cn = bn/(NSECT*NTRAC) + hk_sizes[ldisk(unit)].cyloff;
	sn = bn%(NSECT*NTRAC);
	tn = sn/NSECT;
	sn = sn%NSECT;
	HKADDR->hkcs1 = ERRCLR;
	HKADDR->hkcs2 = dn;
	HKADDR->hkda = (tn<<8) | sn;
	HKADDR->hkba = bp->b_un.b_addr;
	HKADDR->hkwc = -(bp->b_bcount>>1);
	HKADDR->hkcs1 = PACKACK|GO|CDT;
	while ((HKADDR->hkcs1&RDY) == 0) ;

	/* No need to check that all is OK here.  There will be an
	 * interrupt if the drive is not available (the other controller
	 * has it) or if the drive is not ready.
	 */
	HKADDR->hkdc = cn;
	HKADDR->hkcs1 = (IE|GO|CDT) | ((bp->b_xmem&03) << 8)
				| ((bp->b_flags&B_READ) ? RD : WRT) ;

#ifdef INSTRM
	dk_busy |= 1<<DK_N;
	dk_numb[DK_N] += 1;
	dk_wds[DK_N] += (bp->b_bcount>>6);
#endif INSTRM
}

hkintr()
{
	register struct buf *bp;
	register int ctr, stat;

	if(hktab.b_active == NULL)
		return;
#ifdef INSTRM
	dk_busy &= ~(1<<DK_N);
#endif INSTRM
	bp = hktab.b_actf;
	hktab.b_active = NULL;
	HKADDR->hkcs1 &= ~(ERRCLR|IE); /* Clr IE without clearing controller*/
	if(HKADDR->hkcs1 & ERRCLR) {
		if((HKADDR->hkds&SVAL) == 0) {
			HKADDR->hkcs1 = GO|CDT;   /* Get new status */
			while ((HKADDR->hkds&SVAL) == 0) ;
		}

		/* Just retry, with no limit, if drive not available */
		if ((DRA|DRDY) & ~(HKADDR->hkds)) goto retry;

		deverror(bp, HKADDR->hkcs2, HKADDR->hker);
		HKADDR->hkcs1 = ERRCLR|DRCLR|GO|CDT;
		while ((HKADDR->hkcs1&RDY) == 0) ;

		if (HKADDR->hker & (DU|DTE|OPI)) {
			HKADDR->hkcs1 = ERRCLR|RECAL|GO|CDT;
			ctr = 0;
			while ((HKADDR->hkds&PIP) && --ctr);
		}
		HKADDR->hkcs1 = ERRCLR|GO|CDT;      /* Reset controller */

		if (++hktab.b_errcnt <= 10) {
	retry:		hkstart();
			return;
		}
		bp->b_flags |= B_ERROR;
	}
	hktab.b_errcnt = 0;
	hktab.b_actf = bp->av_forw;
	bp->b_resid = 0;

	HKADDR->hkcs2 |= RLS;            /* Release drive */
	HKADDR->hkcs1 = GO | CDT;

	iodone(bp);
	hkstart();
}

hkread(dev)
{
	physio(hkstrategy, &hkbuf, dev, B_READ);
}

hkwrite(dev)
{
	physio(hkstrategy, &hkbuf, dev, B_WRITE);
}
