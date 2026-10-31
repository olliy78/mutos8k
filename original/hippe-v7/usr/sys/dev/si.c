#

/*
 * System Industies 9500 (SI standard) SMD driver
 * CDC 9760/9762/9766 drives
 */

#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/dir.h"
#include "../h/conf.h"
#include "../h/user.h"

#define DK_N	2
#define CDC9766

struct device {
	int	sics;
	int	siwc;
	int	sipc;
	int	sihs;
	caddr_t	siba;
	int	sier;
	int	siss;
	int	sisa;
};

#define SIADDR ((struct device *) 0176700)
#define	NPDISK	1
#define	NLDISK	1

#ifdef CDC9760
#define NSECT	32
#define NTRAC	5
#define NCYLN	411
#endif CDC9760

#ifdef CDC9762
#define NSECT	32
#define NTRAC	5
#define NCYLN	823
#endif CDC9762

#ifdef CDC9766
#define NSECT	32
#define NTRAC	19
#define NCYLN	823
#endif CDC9766

#define NSKIP	22
#define IFAC	1	/* may need tuning */

struct sizes {
	int	cyloff;
	daddr_t	nblocks;
} si_sizes[8] = {
	0,	(daddr_t)NSECT*NTRAC*NCYLN,	/* whole pack */
	0,	0,
};

#define	GO	01
#define	WCOM	2
#define	RCOM	4
#define	IENABLE	0100
#define READY	0200
#define NRSEEK	014	/* not ready to seek */

/*
 * An attempt will be made to
 * treat these errors differently.
 */
#define BSE	01000	/* bad sector error */
#define AVE	0100	/* address verification error */


/*
 * info down to `errcnt' is about
 * the drive, from `com' onwards
 * about the current request
 */
struct si {
	struct buf *ioqp;	/* */
	int	lastcyl;	/* this is the same as `cn' below */
	char	headdir;	/* */
	char	flags;		/* */
	int	errcnt;
	int	com;		/* command */
	int	hn;		/* head number */
	int	sn;		/* sector number */
	int	cn;		/* (port and) cylinder number */
	unsigned bleft;		/* bytes left (for future expansion!) */
	unsigned bpart;		/* bytes transferred */
	union {
		int	w[2];
		long	l;
	} addr;			/* memory address */
} si;

/*
 * flags for above
 */
#define DBUSY	01		/* drive busy */
#define DSEEK	02		/* drive seeking */
#define DFLIP	04		/* this request on a flipped logical disk */

struct buf sitab;
struct buf rsibuf;

/*
 * Table of combinations of strobe
 * early/late and offset plus/minus.
 * Indexed by si.errcnt, and
 * or-ed into the command register.
 */
#define NRETRY	(sizeof(siretry))

char siretry[] = {
	0, 010, 020, 040, 050, 060, 0100, 0110, 0120,
};

/*
 * this is yucky, but....
 */
union {
	char	byte[2];
	struct buf *ubp;
};

#define cylin	b_resid
#define sector	av_back.byte[0]
#define track	av_back.byte[1]
#define skip	b_error

#define IN	1		/* head direction*/
#define OUT	0

sistrategy(bp)
register struct buf *bp;
{
	register struct si *qp;
	register int unit;
	long sz, bn;
	int n;

#ifdef UNIBMAP
	if(bp->b_flags&B_PHYS)
		mapalloc(bp);
#endif UNIBMAP
	unit = minor(bp->b_dev);
	sz = bp->b_bcount;
	sz = (sz+511) >> 9;
	bn = bp->b_blkno;
	if((pdisk(unit) >= NPDISK) || (ldisk(unit) >= NLDISK)
	 ||(bn < 0) || (bn+sz > si_sizes[ldisk(unit)].nblocks)) {
		bp->b_flags |= B_ERROR;
		iodone(bp);
		return;
	}
	bp->skip = NSKIP;
	bp->cylin = bn/(NSECT*NTRAC);
	n = si_sizes[ldisk(unit)].cyloff;
	if(n < 0)
		bp->cylin = -(bp->cylin + n);
	else
		bp->cylin += n;
	bp->sector = bn%NSECT;
	bp->track = (bn%(NSECT*NTRAC))/NSECT;
	bp->av_forw = 0;
	qp = &si;
	spl5();
	if(qp->ioqp == NULL){
		qp->ioqp = bp;
		if((qp->flags&DBUSY) == 0)
			sistart();
	}
	else
		xsort(bp, qp->ioqp, qp->headdir, IFAC);
	spl0();
}

sistart()
{
	register struct buf *bp;
	register struct si *qp;
	register int unit;

	qp = &si;
	if((bp = qp->ioqp) == NULL)
		return;
	qp->flags |= DBUSY;
	unit = minor(bp->b_dev);
	if(si_sizes[ldisk(unit)].cyloff < 0)
		qp->flags |= DFLIP;
	if(bp->cylin > qp->lastcyl)
		qp->headdir = IN;
	else if(bp->cylin < qp->lastcyl)
		qp->headdir = OUT;
	qp->cn = bp->cylin;
	qp->sn = bp->sector;
	qp->hn = bp->track;
	qp->addr.w[0] = bp->b_xmem&03;
	qp->addr.w[1] = (int)bp->b_un.b_addr;
	qp->bleft = bp->b_bcount;
	if(bp->b_flags&B_READ)
		qp->com = RCOM|IENABLE|GO;
	else
		qp->com = WCOM|IENABLE|GO;
	bp->skip = 0;
	siio();
}

siio()
{
	register struct device *sp;
	register struct si *qp;
	register int n;

	sp = SIADDR;
	qp = &si;
	qp->lastcyl = qp->cn;
	if(qp->flags&DFLIP){
		if(qp->bleft < (qp->bpart = (NTRAC*NSECT*512) - (qp->sn*512)))
			qp->bpart = qp->bleft;
	}
	else
		qp->bpart = qp->bleft;
	sp->siba = (caddr_t)qp->addr.w[1];
	sp->sihs = (qp->hn << 5)|qp->sn;
	sp->sipc = qp->cn;
	sp->siwc = (qp->bpart >> 1);
	sp->sics = (qp->com)|(qp->addr.w[0] << 4)|(siretry[qp->errcnt] << 8);
#ifdef INSTRM
	dk_busy |= (1 << DK_N);
	dk_numb[DK_N] += 1;
	n = qp->bpart >> 6;
	dk_wds[DK_N] += n;
#endif INSTRM
}

siintr()
{
	register struct buf *bp;
	register struct si *qp;
	register int ctr;

	qp = &si;
	if((qp->flags&DBUSY) == 0)
		return;
#ifdef INSTRM
	dk_busy &= ~(1 << DK_N);
#endif INSTRM
	bp = qp->ioqp;
	if(SIADDR->sier < 0){
		deverror(bp, SIADDR->sier, SIADDR->sics);
		if(SIADDR->sier&BSE)
			goto done;
		if(SIADDR->sier&AVE){
			/*
			 * O.K. what magic goes here?
			 * How's about ....
			 */
#ifdef TRYAVE
			int savecn;

			prdev("ave", bp->b_dev);
			savecn = qp->cn;
			qp->cn = NCYLN;
			qp->com &= ~IENABLE;
			siio();
			ctr = 0;
			while((SIADDR->sics&READY) == 0 && --ctr)
				;
			qp->com |= IENABLE;
			qp->cn = savecn;
#else
			/*
			 * or, how's about
			 */
			ctr = 0;
			SIADDR->sisa = NCYLN;
			while((SIADDR->siss&NRSEEK) == 0 && --ctr)
				;
#endif TRYAVE
		}
		ctr = 0;
		while((SIADDR->sics&READY) == 0 && --ctr)
			;
		if(++qp->errcnt < NRETRY){
			sistart();
			return;
		}
	done:
		bp->b_flags |= B_ERROR;
		qp->bpart = qp->bleft;
	}
	if(qp->flags&DFLIP){
		/*
		 * a degenerate unsigned comparison
		 */
		if((qp->bleft -= qp->bpart) > 0){
			qp->addr.l += qp->bpart;
			qp->hn = qp->sn = 0;
			qp->cn--;
			siio();
			return;
		}
	}
	qp->flags &= ~(DBUSY|DFLIP);
	qp->errcnt = 0;
	qp->ioqp = bp->av_forw;
	bp->b_resid = 0;
	iodone(bp);
	sistart();
}

siread(dev)
{
	physio(sistrategy, &rsibuf, dev, B_READ);
}

siwrite(dev)
{
	physio(sistrategy, &rsibuf, dev, B_WRITE);
}
