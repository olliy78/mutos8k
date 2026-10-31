/*
 * RP04/RP05/RP06 disk driver
 */

#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/conf.h"
#include "../h/dir.h"
#include "../h/user.h"

#define	DK_N	2
#define RP06

struct	device
{
	union {
		int	w;
		char	c[2];
	} hpcs1;		/* Control and Status register 1 */
	int	hpwc;		/* Word count register */
	caddr_t	hpba;		/* UNIBUS address register */
	int	hpda;		/* Desired address register */
	union {
		int	w;
		char	c[2];
	} hpcs2;		/* Control and Status register 2*/
	int	hpds;		/* Drive Status */
	int	hper1;		/* Error register 1 */
	int	hpas;		/* Attention Summary */
	int	hpla;		/* Look ahead */
	int	hpdb;		/* Data buffer */
	int	hpmr;		/* Maintenance register */
	int	hpdt;		/* Drive type */
	int	hpsn;		/* Serial number */
	int	hpof;		/* Offset register */
	int	hpdc;		/* Desired Cylinder address register*/
	int	hpcc;		/* Current Cylinder */
	int	hper2;		/* Error register 2 */
	int	hper3;		/* Error register 3 */
	int	hpec1;		/* Burst error bit position */
	int	hpec2;		/* Burst error bit pattern */
	int	hpbae;		/* 11/70 bus extension */
	int	hpcs3;
};

#define	HPADDR	((struct device *)0176700)
#define	NPDISK	1
#define	NLDISK	1

#ifdef RP04
#define	NSECT	22
#define	NTRAC	19
#define NCYLN	411
#endif RP04

#ifdef RP05
#define	NSECT	22
#define	NTRAC	19
#define NCYLN	411
#endif RP05

#ifdef RP06
#define	NSECT	22
#define	NTRAC	19
#define NCYLN	815
#endif RP06

#define	SDIST	2
#define	RDIST	6

struct	sizes {
	int	cyloff;
	daddr_t	nblocks;
} hp_sizes[8] =
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
int	hp_offset[16] =
{
	P400, M400, P400, M400,
	P800, M800, P800, M800,
	P1200, M1200, P1200, M1200,
	0, 0, 0, 0,
};

struct	buf	hptab;
struct	buf	rhpbuf;
struct	buf	hputab[NPDISK];

#define	cylin	b_resid

hpstrategy(bp)
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
	 ||(bn < 0) || (bn+sz > hp_sizes[ldisk(unit)].nblocks)) {
		bp->b_flags |= B_ERROR;
		iodone(bp);
		return;
	}
	bp->cylin = bn/(NSECT*NTRAC) + hp_sizes[ldisk(unit)].cyloff;
	dp = &hputab[pdisk(unit)];
	spl5();
	disksort(dp, bp);
	if (dp->b_active == 0) {
		hpustart(pdisk(unit));
		if(hptab.b_active == 0)
			hpstart();
	}
	spl0();
}

hpustart(drive)
register drive;
{
	register struct buf *bp, *dp;
	daddr_t bn;
	int sn, cn, csn;

	HPADDR->hpcs2.w = drive;
	HPADDR->hpcs1.c[0] = IE;
	HPADDR->hpas = 1<<drive;

	if(drive >= NPDISK)
		return;
	dp = &hputab[drive];
	if((bp=dp->b_actf) == NULL)
		return;
	if((HPADDR->hpds & VV) == 0) {
		HPADDR->hpcs1.c[0] = IE|PRESET|GO;
		HPADDR->hpof = FMT22;
	}
	if(dp->b_active)
		goto done;
	dp->b_active++;
	if ((HPADDR->hpds & (DPR|MOL)) != (DPR|MOL))
		goto done;

	bn = bp->b_blkno;
	cn = bp->cylin;
	sn = bn%(NSECT*NTRAC);
	sn = (sn+NSECT-SDIST)%NSECT;

	if(HPADDR->hpcc != cn)
		goto search;
	csn = (HPADDR->hpla>>6) - sn + SDIST - 1;
	if(csn < 0)
		csn += NSECT;
	if(csn > NSECT-RDIST)
		goto done;

search:
	HPADDR->hpdc = cn;
	HPADDR->hpda = sn;
	HPADDR->hpcs1.c[0] = IE|SEARCH|GO;
	return;

done:
	dp->b_forw = NULL;
	if(hptab.b_actf == NULL)
		hptab.b_actf = dp; else
		hptab.b_actl->b_forw = dp;
	hptab.b_actl = dp;
}

hpstart()
{
	register struct buf *bp, *dp;
	register int unit;
	int com, dn, sn, tn, cn;
	daddr_t bn;

loop:
	if ((dp = hptab.b_actf) == NULL)
		return;
	if ((bp = dp->b_actf) == NULL) {
		hptab.b_actf = dp->b_forw;
		goto loop;
	}
	hptab.b_active++;
	unit = minor(bp->b_dev);
	dn = pdisk(unit);
	bn = bp->b_blkno;
	cn = bn/(NSECT*NTRAC) + hp_sizes[ldisk(unit)].cyloff;
	sn = bn%(NSECT*NTRAC);
	tn = sn/NSECT;
	sn = sn%NSECT;

	HPADDR->hpcs2.w = dn;
	if ((HPADDR->hpds & (DPR|MOL)) != (DPR|MOL)) {
		hptab.b_active = 0;
		hptab.b_errcnt = 0;
		dp->b_actf = bp->av_forw;
		bp->b_flags |= B_ERROR;
		iodone(bp);
		goto loop;
	}
	if(hptab.b_errcnt >= 16) {
		HPADDR->hpof = hp_offset[hptab.b_errcnt & 017] | FMT22;
		HPADDR->hpcs1.w = OFFSET|GO;
		while(HPADDR->hpds & PIP)
			;
	}
	HPADDR->hpdc = cn;
	HPADDR->hpda = (tn << 8) + sn;
	HPADDR->hpba = bp->b_un.b_addr;
#ifdef MASSBUS
	HPADDR->hpbae = bp->b_xmem;
#else
#ifdef UNIBMAP
	if(bp->b_flags&B_PHYS)
		mapalloc(bp);
#endif UNIBMAP
#endif MASSBUS
	HPADDR->hpwc = -(bp->b_bcount>>1);
	com = ((bp->b_xmem&3) << 8) | IE | GO;
	if(bp->b_flags & B_READ)
		com |= RCOM;
	else
		com |= WCOM;
	HPADDR->hpcs1.w = com;

#ifdef	INSTRM
	dk_busy |= 1<<DK_N;
	dk_numb[DK_N] += 1;
	dk_wds[DK_N] += (bp->b_count>>6);
#endif
}

hpintr()
{
	register struct buf *bp, *dp;
	register int unit;
	int as, i, j;

	as = HPADDR->hpas & 0377;
	if(hptab.b_active) {
#ifdef	INSTRM
		dk_busy &= ~(1<<DK_N);
#endif
		dp = hptab.b_actf;
		bp = dp->b_actf;
		unit = minor(bp->b_dev);
		HPADDR->hpcs2.c[0] = pdisk(unit);
		if (HPADDR->hpcs1.w & TRE) {		/* error bit */
			while((HPADDR->hpds & DRY) == 0)
				;
			if(++hptab.b_errcnt > 28 || HPADDR->hper1&WLE)
				bp->b_flags |= B_ERROR; else
				hptab.b_active = 0;
			if(hptab.b_errcnt > 27)
				deverror(bp, HPADDR->hpcs2.w, HPADDR->hper1);
			if((bp->b_flags&B_PHYS) == 0 &&
			   (HPADDR->hper1 & (DCK|ECH)) == DCK) {
				i = HPADDR->hpec1 - 1;
				j = i&017;
				i >>= 4;
				if(i >= 0 && i <256) {
#ifdef XBUF
					int w;

					w = fbword(bp->b_xaddr,i*NBPW);
					w ^= HPADDR->hpec2 << j;
					sbword(bp->b_xaddr,i*NBPW,w);
					w = fbword(bp->b_xaddr,(i+1)*NBPW);
					w ^= HPADDR->hpec2 >> (16-j);
					sbword(bp->b_xaddr,(i+1)*NBPW,w);
#else
					bp->b_un.b_words[i] ^= HPADDR->hpec2 << j;
					bp->b_un.b_words[i+1] ^= HPADDR->hpec2 >> (16-j);
#endif XBUF
				}
				hptab.b_active++;
				printf("%D ", bp->b_blkno);
				prdev("ECC", bp->b_dev);
			}
			HPADDR->hpcs1.w = TRE|IE|DCLR|GO;
			if((hptab.b_errcnt&07) == 4) {
				HPADDR->hpcs1.w = RECAL|IE|GO;
				while(HPADDR->hpds & PIP)
					;
			}
		}
		if(hptab.b_active) {
			if(hptab.b_errcnt) {
				HPADDR->hpcs1.w = RTC|GO;
				while(HPADDR->hpds & PIP)
					;
			}
			hptab.b_active = 0;
			hptab.b_errcnt = 0;
			hptab.b_actf = dp->b_forw;
			dp->b_active = 0;
			dp->b_errcnt = 0;
			dp->b_actf = bp->av_forw;
			bp->b_resid = -(HPADDR->hpwc<<1);
			iodone(bp);
			HPADDR->hpcs1.w = IE;
			if(dp->b_actf)
				hpustart(pdisk(unit));
		}
		as &= ~(1<<pdisk(unit));
	} else {
		if(as == 0)
			HPADDR->hpcs1.w = IE;
		HPADDR->hpcs1.c[1] = TRE>>8;
	}
	for(i=0; i<NPDISK; i++)
		if(as & (1<<i))
			hpustart(i);
	hpstart();
}

hpread(dev)
{

	physio(hpstrategy, &rhpbuf, dev, B_READ);
}

hpwrite(dev)
{

	physio(hpstrategy, &rhpbuf, dev, B_WRITE);
}
