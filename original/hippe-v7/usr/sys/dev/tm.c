#

/*
 * TM tape driver
 */

#include "../h/param.h"
#include "../h/buf.h"
#include "../h/dir.h"
#include "../h/conf.h"
#include "../h/file.h"
#include "../h/user.h"

#define	TMADDR ((struct device *)0172520)
#define NTM	2
#define REMOTE

/* tmer bits */
#define	TUR	0000001
#define	WL	0000004
#define NXM	0000200
#define RLE	0001000
#define EOT	0002000
#define	EOF	0040000
#define ILC	0100000
#define	HARD	(ILC|EOT|NXM)

#define	NOP	0000100
/* tmcs bits */
#define	GO	0000001
#define	RCOM	0000002
#define	WCOM	0000004
#define	WEOF	0000006
#define	SFORW	0000010
#define	SREV	0000012
#define	WIRG	0000014
#define	REW	0000016
#define	IENABLE	0000100
#define	CRDY	0000200
#ifdef REMOTE
#define DENS(unit)	((unit)&0100 ? 0020000 : 0060000)
#else
#define	DENS(unit)	0060000
#endif REMOTE
#define ERROR	0100000

/* tmrd bits */
#define GAPSD	010000

#define	SSEEK	1
#define	SIO	2
#define	SCOM	3

struct device {
	int	tmer;
	int	tmcs;
	int	tmbc;
	char	*tmba;
	int	tmdb;
	int	tmrd;
};

struct	buf	tmtab;
struct	buf	ctmbuf;
struct	buf	rtmbuf;

char	t_flags[NTM];
char	t_openf[NTM];
daddr_t	t_blkno[NTM];
daddr_t	t_nxrec[NTM];

#define T_WRITTEN 1

tmopen(dev,rw)
{
	register unit, status;

	unit = minor(dev) & 077;
	if((unit >= NTM) || t_openf[unit]) {
		u.u_error = ENXIO;
		return;
	}
	t_blkno[unit] = 0;
	t_nxrec[unit] = 65535;
	t_flags[unit] = 0;

	tmtab.b_flags |= B_TAPE;
	status = tcommand(dev, NOP);
	if((status&TUR)==0) {
		u.u_error = ENXIO;
		return;
	}
	if(rw && (status&WL)) {
		u.u_error = EROFS;
		return;
	}
	t_openf[unit]++;
}

tmclose(dev, flag)
dev_t dev;
int flag;
{

	if( flag == FWRITE ||
	((flag&FWRITE) && (t_flags[minor(dev)&077]&T_WRITTEN))) {
		tcommand(dev, WEOF);
		tcommand(dev, WEOF);
		tcommand(dev, SREV);
	}
	if((minor(dev)&0200) == 0)
		tcommand(dev, REW);
	t_openf[minor(dev)&077] = 0;
}

tcommand(dev, com)
{
	register struct buf *bp;

	bp = &ctmbuf;
	spl5();
	while(bp->b_flags&B_BUSY) {
		bp->b_flags |= B_WANTED;
		sleep((caddr_t)bp, PRIBIO);
	}
	bp->b_flags = B_BUSY|B_READ;
	spl0();
	bp->b_dev = dev;
	bp->b_resid = com;
	bp->b_blkno = 0;
	tmstrategy(bp);
	iowait(bp);
	if(bp->b_flags&B_WANTED)
		wakeup((caddr_t)bp);
	bp->b_flags = 0;
	return(bp->b_resid);
}

tmstrategy(bp)
register struct buf *bp;
{
	register daddr_t *p;

#ifdef UNIBMAP
	if(bp->b_flags&B_PHYS)
		mapalloc(bp);
#endif UNIBMAP
	if(bp != &ctmbuf) {
		p = &t_nxrec[minor(bp->b_dev)&077];
		if(*p <= bp->b_blkno) {
			if(*p < bp->b_blkno) {
				bp->b_flags |= B_ERROR;
				iodone(bp);
				return;
			}
			if(bp->b_flags&B_READ) {
				clrbuf(bp);
				bp->b_resid = 0;
				iodone(bp);
				return;
			}
		}
		if((bp->b_flags&B_READ) == 0) {
			t_flags[minor(bp->b_dev)&077] |= T_WRITTEN;
			*p = bp->b_blkno+1;
		}
	}
	bp->av_forw = 0;
	spl5();
	if(tmtab.b_actf == NULL)
		tmtab.b_actf = bp;
	else
		tmtab.b_actl->av_forw = bp;
	tmtab.b_actl = bp;
	if(tmtab.b_active == NULL)
		tmstart();
	spl0();
}

tmstart()
{
	register struct buf *bp;
	register int com;
	int unit;
	register daddr_t *blkno;

    loop:
	if((bp = tmtab.b_actf) == 0)
		return;
	unit = minor(bp->b_dev)&077;
	blkno = &t_blkno[unit];
	if(t_openf[unit] < 0 || (TMADDR->tmcs & CRDY) == NULL) {
		bp->b_flags |= B_ERROR;
		goto next;
	}
	if(bp == &ctmbuf) {
		if(bp->b_resid == NOP) {
			bp->b_resid = TMADDR->tmer;
			goto next;
		}
		tmtab.b_active = SCOM;
		TMADDR->tmcs = bp->b_resid|GO|(unit<<8)|IENABLE
				|DENS(minor(bp->b_dev));
		return;
	}
	com = (unit<<8)|((bp->b_xmem&03)<<4)|IENABLE|DENS(minor(bp->b_dev));
	if(*blkno != bp->b_blkno) {
		tmtab.b_active = SSEEK;
		if(*blkno < bp->b_blkno) {
			com |= SFORW|GO;
			TMADDR->tmbc = *blkno - bp->b_blkno;
		} else {
			if(bp->b_blkno == 0)
				com |= REW|GO;
			else {
				com |= SREV|GO;
				TMADDR->tmbc = bp->b_blkno - *blkno;
			}
		}
		TMADDR->tmcs = com;
		return;
	}
	tmtab.b_active = SIO;
	TMADDR->tmbc = -bp->b_bcount;
	TMADDR->tmba = bp->b_un.b_addr;
	TMADDR->tmcs = com | ((bp->b_flags&B_READ)? RCOM|GO:
	    ((tmtab.b_errcnt)? WIRG|GO: WCOM|GO));
	return;

next:
	tmtab.b_actf = bp->av_forw;
	iodone(bp);
	goto loop;
}

tmintr()
{
	register struct buf *bp;
	register int unit;
	int	state;

	if((bp = tmtab.b_actf) == NULL)
		return;
	unit = minor(bp->b_dev)&077;
	state = tmtab.b_active;
	tmtab.b_active = 0;
	if(TMADDR->tmcs&ERROR) {
		while(TMADDR->tmrd & GAPSD) ; /* wait for gap shutdown */
		if(TMADDR->tmer&EOF) {
			t_nxrec[unit] = bp->b_blkno;
			state = SCOM;
			TMADDR->tmbc = -bp->b_bcount;
			goto out;
		}
		if((TMADDR->tmer&HARD) == 0 && TMADDR->tmer&RLE) {
			state = SIO;
			goto out;
		}
		if((TMADDR->tmer&(HARD|EOF)) == NULL && state==SIO) {
			if(++tmtab.b_errcnt < 2) {
				t_blkno[unit]++;
				tmtab.b_active = 0;
				tmstart();
				return;
			}
		} else
			if(t_openf[unit]>0 && bp!=&rtmbuf &&
				(TMADDR->tmer&EOF)==0 ) {
				t_openf[unit] = -1;
				deverror(bp, TMADDR->tmer, 0);
			}
		bp->b_flags |= B_ERROR;
		state = SIO;
	}
out:
	switch ( state ) {
	case SIO:
		t_blkno[unit] += (bp->b_bcount>>BSHIFT);
	case SCOM:
		tmtab.b_errcnt = 0;
		tmtab.b_actf = bp->av_forw;
		bp->b_resid = -TMADDR->tmbc;
		iodone(bp);
		break;
	case SSEEK:
		t_blkno[unit] = bp->b_blkno;
		break;
	default:
		return;
	}
	tmstart();
}

tmread(dev)
{
	tmphys(dev);
	physio(tmstrategy, &rtmbuf, dev, B_READ);
}

tmwrite(dev)
{
	tmphys(dev);
	physio(tmstrategy, &rtmbuf, dev, B_WRITE);
}

tmphys(dev)
{
	register unit;
	daddr_t a;

	unit = minor(dev) & 077;
	if(unit < NTM) {
		a = u.u_offset >> BSHIFT;
		t_blkno[unit] = a;
		t_nxrec[unit] = a+1;
	}
}
