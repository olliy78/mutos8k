/*
 * RM02/RM03/RM04/RM05 disk driver
 */

#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/conf.h"
#include "../h/dir.h"
#include "../h/user.h"

#define	DK_N	2
#define RM05
/*#define SI_EMUL*/

struct	device
{
	union {
		int	w;
		char	c[2];
	} rmcs1;		/* Control and Status register 1 */
	int	rmwc;		/* Word count register */
	caddr_t	rmba;		/* UNIBUS address register */
	int	rmda;		/* Desired address register */
	union {
		int	w;
		char	c[2];
	} rmcs2;		/* Control and Status register 2*/
	int	rmds;		/* Drive Status */
	int	rmer1;		/* Error register 1 */
	int	rmas;		/* Attention Summary */
	int	rmla;		/* Look ahead */
	int	rmdb;		/* Data buffer */
	int	rmmr1;		/* Maintenance register 1 */
	int	rmdt;		/* Drive type */
	int	rmsn;		/* Serial number */
	int	rmof;		/* Offset register */
	int	rmdc;		/* Desired Cylinder address register*/
	int	rmhr;		/* Holding Register */
	int	rmmr2;		/* Maintenance register 2 */
	int	rmer2;		/* Error register 2 */
	int	rmec1;		/* Burst error bit position */
	int	rmec2;		/* Burst error bit pattern */
	int	rmbae;		/* 11/70 bus extension */
	int	rmcs3;
};

#define	RMADDR	((struct device *)0176700)
#define	NPDISK	1
#define	NLDISK	1

#ifdef RM02
#define NSECT	32
#define NTRAC	5
#define NCYLN	823
#endif RM02

#ifdef RM03
#define NSECT	32
#define NTRAC	5
#define NCYLN	823
#endif RM03

#ifdef RM05
#define NSECT	32
#define NTRAC	19
#define NCYLN	823
#endif RM05

#define	SDIST	2
#define	RDIST	6

struct	sizes {
	int	cyloff;
	daddr_t	nblocks;
} rm_sizes[8] =
{
	0,	(daddr_t)NSECT*NTRAC*NCYLN,	/* whole pack */
	0,	0,
};

#define	GO	01
#define	PRESET	020
#define	RTC	016
#define	OFFSET	014
#define	SEARCH	030
#define	RECAL	06
#define DCLR	010
#define	WCOM	060
#define	RCOM	070

#define	IE	0100
#define	PIP	020000
#define	DRY	0200
#define	ERR	040000
#define	TRE	040000
#define	DCK	0100000
#define	WLE	04000
#define	ECH	0100
#define VV	0100
#define	DPR	0400
#define	MOL	010000
#define FMT22	010000

#define	P400	020
#define	M400	0220
#define	P800	040
#define	M800	0240
#define	P1200	060
#define	M1200	0260
int	rm_offset[16] =
{
	P400, M400, P400, M400,
	P800, M800, P800, M800,
	P1200, M1200, P1200, M1200,
	0, 0, 0, 0,
};

struct	buf	rmtab;
struct	buf	rrmbuf;
struct	buf	rmutab[NPDISK];

#define	b_cylin	b_resid

rmstrategy(bp)
register struct buf *bp;
{
	register struct buf *dp;
	register int unit;
	long sz;
	daddr_t bn;

	unit = minor(bp->b_dev);
	sz = bp->b_bcount;
	sz = (sz+511) >> 9;
	bn = bp->b_blkno;
	if((pdisk(unit) >= NPDISK) || (ldisk(unit) >= NLDISK)
	 ||(bn < 0) || (bn+sz > rm_sizes[ldisk(unit)].nblocks)) {
		bp->b_flags |= B_ERROR;
		iodone(bp);
		return;
	}
	bp->b_cylin = bn/(NSECT*NTRAC) + rm_sizes[ldisk(unit)].cyloff;
	dp = &rmutab[pdisk(unit)];
	spl5();
	disksort(dp, bp);
	if (dp->b_active == 0) {
		rmustart(pdisk(unit));
		if(rmtab.b_active == 0)
			rmstart();
	}
	spl0();
}

rmustart(drive)
register drive;
{
	register struct buf *bp, *dp;
	daddr_t bn;
	int sn, cn, csn;

	RMADDR->rmcs2.w = drive;
	RMADDR->rmcs1.c[0] = IE;
	RMADDR->rmas = 1<<drive;

	if(drive >= NPDISK)
		return;
	dp = &rmutab[drive];
	if((bp=dp->b_actf) == NULL)
		return;
	if((RMADDR->rmds & VV) == 0) {
		RMADDR->rmcs1.c[0] = IE|PRESET|GO;
		RMADDR->rmof = FMT22;
	}
	if(dp->b_active)
		goto done;
	dp->b_active++;
	if ((RMADDR->rmds & (DPR|MOL)) != (DPR|MOL))
		goto done;

	bn = bp->b_blkno;
	cn = bp->b_cylin;
	sn = bn%(NSECT*NTRAC);
	sn = (sn+NSECT-SDIST)%NSECT;

#ifndef SI_EMUL
	if(RMADDR->rmdc != cn)
		goto search;
	csn = (RMADDR->rmla>>6) - sn + SDIST - 1;
	if(csn < 0)
		csn += NSECT;
	if(csn > NSECT-RDIST)
		goto done;
#endif SI_EMUL

search:
	RMADDR->rmdc = cn;
	RMADDR->rmda = sn;
	RMADDR->rmcs1.c[0] = IE|SEARCH|GO;
	return;

done:
	dp->b_forw = NULL;
	if(rmtab.b_actf == NULL)
		rmtab.b_actf = dp; else
		rmtab.b_actl->b_forw = dp;
	rmtab.b_actl = dp;
}

rmstart()
{
	register struct buf *bp, *dp;
	register int unit;
	int com, dn, sn, tn, cn;
	daddr_t bn;

loop:
	if ((dp = rmtab.b_actf) == NULL)
		return;
	if ((bp = dp->b_actf) == NULL) {
		rmtab.b_actf = dp->b_forw;
		goto loop;
	}
	rmtab.b_active++;
	unit = minor(bp->b_dev);
	dn = pdisk(unit);
	bn = bp->b_blkno;
	cn = bn/(NSECT*NTRAC) + rm_sizes[ldisk(unit)].cyloff;
	sn = bn%(NSECT*NTRAC);
	tn = sn/NSECT;
	sn = sn%NSECT;

	RMADDR->rmcs2.w = dn;
	if ((RMADDR->rmds & (DPR|MOL)) != (DPR|MOL)) {
		rmtab.b_active = 0;
		rmtab.b_errcnt = 0;
		dp->b_actf = bp->av_forw;
		bp->b_flags |= B_ERROR;
		iodone(bp);
		goto loop;
	}
	if(rmtab.b_errcnt >= 16) {
		RMADDR->rmof = rm_offset[rmtab.b_errcnt & 017] | FMT22;
		RMADDR->rmcs1.w = OFFSET|GO;
		while(RMADDR->rmds & PIP)
			;
	}
	RMADDR->rmdc = cn;
	RMADDR->rmda = (tn << 8) + sn;
	RMADDR->rmba = bp->b_un.b_addr;
#ifdef MASSBUS
	RMADDR->rmbae = bp->b_xmem;
#else
#ifdef UNIBMAP
	if(bp->b_flags&B_PHYS)
		mapalloc(bp);
#endif UNIBMAP
#endif MASSBUS
	RMADDR->rmwc = -(bp->b_bcount>>1);
	com = ((bp->b_xmem&3) << 8) | IE | GO;
	if(bp->b_flags & B_READ)
		com |= RCOM;
	else
		com |= WCOM;
	RMADDR->rmcs1.w = com;

#ifdef	INSTRM
	dk_busy |= 1<<DK_N;
	dk_numb[DK_N] += 1;
	dk_wds[DK_N] += (bp->b_count>>6);
#endif
}

rmintr()
{
	register struct buf *bp, *dp;
	register int unit;
	int as, i, j;

	as = RMADDR->rmas & 0377;
	if(rmtab.b_active) {
#ifdef	INSTRM
		dk_busy &= ~(1<<DK_N);
#endif
		dp = rmtab.b_actf;
		bp = dp->b_actf;
		unit = minor(bp->b_dev);
		RMADDR->rmcs2.c[0] = pdisk(unit);
		if (RMADDR->rmcs1.w & TRE) {		/* error bit */
			while((RMADDR->rmds & DRY) == 0)
				;
			if(++rmtab.b_errcnt > 28 || RMADDR->rmer1&WLE)
				bp->b_flags |= B_ERROR; else
				rmtab.b_active = 0;
			if(rmtab.b_errcnt > 27)
				deverror(bp, RMADDR->rmcs2.w, RMADDR->rmer1);
			if((bp->b_flags&B_PHYS) == 0 &&
			   (RMADDR->rmer1 & (DCK|ECH)) == DCK) {
#ifndef SI_EMUL
				i = RMADDR->rmec1 - 1;
				j = i&017;
				i >>= 4;
				if(i >= 0 && i <256) {
#ifdef XBUF
					int w;

					w = fbword(bp->b_xaddr,i*sizeof(int));
					w ^= RMADDR->rmec2 << j;
					sbword(bp->b_xaddr,i*sizeof(int),w);
					w = fbword(bp->b_xaddr,(i+1)*sizeof(int));
					w ^= RMADDR->rmec2 >> (16-j);
					sbword(bp->b_xaddr,(i+1)*sizeof(int),w);
#else
					bp->b_un.b_words[i] ^= RMADDR->rmec2 << j;
					bp->b_un.b_words[i+1] ^= RMADDR->rmec2 >> (16-j);
#endif XBUF
				}
				rmtab.b_active++;
#endif SI_EMUL
				printf("%D ", bp->b_blkno);
				prdev("ECC", bp->b_dev);
			}
			RMADDR->rmcs1.w = TRE|IE|DCLR|GO;
			if((rmtab.b_errcnt&07) == 4) {
				RMADDR->rmcs1.w = RECAL|IE|GO;
				while(RMADDR->rmds & PIP)
					;
			}
		}
		if(rmtab.b_active) {
			if(rmtab.b_errcnt) {
				RMADDR->rmcs1.w = RTC|GO;
				while(RMADDR->rmds & PIP)
					;
			}
			rmtab.b_active = 0;
			rmtab.b_errcnt = 0;
			rmtab.b_actf = dp->b_forw;
			dp->b_active = 0;
			dp->b_errcnt = 0;
			dp->b_actf = bp->av_forw;
			bp->b_resid = -(RMADDR->rmwc<<1);
			iodone(bp);
			RMADDR->rmcs1.w = IE;
			if(dp->b_actf)
				rmustart(pdisk(unit));
		}
		as &= ~(1<<pdisk(unit));
	} else {
		if(as == 0)
			RMADDR->rmcs1.w = IE;
		RMADDR->rmcs1.c[1] = TRE>>8;
	}
	for(i=0; i<NPDISK; i++)
		if(as & (1<<i))
			rmustart(i);
	rmstart();
}

rmread(dev)
{

	physio(rmstrategy, &rrmbuf, dev, B_READ);
}

rmwrite(dev)
{

	physio(rmstrategy, &rrmbuf, dev, B_WRITE);
}
