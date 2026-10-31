#
/*
 * Disk sorting routine.
 * Filched from Boston RK
 * driver.
 */
#include "../h/param.h"
#include "../h/buf.h"

/*
 * note the assumption that a
 * pointer is at least two bytes
 * long
 * I don't like this, and neither
 * does `lint', but ....
 */
union {
	char	byte[2];
	struct buf *ubp;
};

#define cylin	b_resid
#define sector	av_back.byte[0]
#define track	av_back.byte[1]
#define skip	b_error

#define IN	1	/* head direction */
#define OUT	0

/*
 * The arguments are:
 *	a pointer to the request to be fitted in;
 *	a pointer to the head of the queue;
 *	the current head direction;
 *	an interleave factor if a cylinder match
 *	is found.
 */
xsort(bp, p1, f, ifac)
struct buf *bp;
register struct buf *p1;
{
	register struct buf *p2;
	register int cyl, sect;

	p2 = p1->av_forw;
	cyl = bp->cylin;
	sect = bp->sector;
	while(p2){
		if(!p2->skip)
			p1 = p2;
		p2 = p2->av_forw;
	}
	for(; p2 = p1->av_forw; p1 = p2){
		if((p1->cylin <= cyl && cyl <= p2->cylin)
		|| (p1->cylin >= cyl && cyl >= p2->cylin)){
			while(cyl == p2->cylin){
				if(p2->sector > p1->sector){
					if(sect > p1->sector+ifac
					&& sect < p2->sector-ifac)
						goto out;
				}
				else if(sect > p1->sector+ifac
				     || sect < p2->sector-ifac)
						goto out;
				p1 = p2;
				if(!(p2 = p1->av_forw))
					goto out;
			}
			goto out;
		}
		else if(f){
			if(p2->cylin < p1->cylin)
				if(cyl > p1->cylin)
					goto out;
				else
					f = 0;
		}
		else if(p2->cylin > p1->cylin){
			if(cyl < p1->cylin)
				goto out;
			else
				f++;
		}
	}
out:
	bp->av_forw = p2;
	p1->av_forw = bp;
	while(p2){
		if(p2->skip)
			p2->skip--;
		p2 = p2->av_forw;
	}
}
