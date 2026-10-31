/* malloc.c -- core and swap map allocation (kernel mutos_1216, 2DF0..2F48): malloc, mfree.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/malloc.c (both functions; System III PDP-11 uts/os/malloc.c has the same text as V7,
 *           so V7 = System III here).
 *           Closest known relative: TUHS collection Research/Torsten_Hippe_v7 (assembled 1995 from unknown sources; not the
 *           author) - matches the map limit with panic("map overflow") (MAPSIZ = NPROC/2 = 15 entries; doc/herkunft/fremd.md
 *           4.1 no. 1).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 83% V7 and 83% System III, malloc 71%, mfree 91%
 *           before the restoration.  Same call graph (wakeup on runin when freeing core).  The only parts that are in
 *           neither source are the two map-size checks (see Deviations).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/malloc.md.
 * Deviations: MUTOS limits a map to 15 entries plus the end mark: malloc stops the search at bp - mp >= 15, mfree
 *           panics "map overflow\n" when it would insert a 16th entry (not in V7, not in System III PDP-11/VAX; this is the
 *           map limit of the Hippe collection, see above).  The V7 comments are kept.  See doc/herkunft/malloc.md.
 *
 * Data: coremap = A09C, swapmap = A0DC (16 entries each), runin = 8DD6, text 8AE4 "map overflow\n".
 * An entry is {m_size, m_addr}, 4 bytes. */
#include "param.h"
#include "systm.h"
#include "map.h"

/*
 * Allocate 'size' units from the given
 * map. Return the base of the allocated
 * space.
 * In a map, the addresses are increasing and the
 * list is terminated by a 0 size.
 * The core map unit is 64 bytes; the swap map unit
 * is 512 bytes.
 * Algorithm is first-fit.
 */
/* KERNEL 2DF0 */
malloc(mp, size)
struct map *mp;
{
	register unsigned int a;
	register struct map *bp;

	for (bp=mp; bp->m_size; bp++) {
		/* MUTOS: map holds at most 15 entries (not in V7) */
		if (bp - mp >= 15)
			break;
		if (bp->m_size >= size) {
			a = bp->m_addr;
			bp->m_addr += size;
			if ((bp->m_size -= size) == 0) {
				do {
					bp++;
					(bp-1)->m_addr = bp->m_addr;
				} while ((bp-1)->m_size = bp->m_size);
			}
			return(a);
		}
	}
	return(0);
}

/*
 * Free the previously allocated space aa
 * of size units into the specified map.
 * Sort aa into map and combine on
 * one or both ends if possible.
 */
/* KERNEL 2E5A */
mfree(mp, size, a)
struct map *mp;
register int a;
{
	register struct map *bp;
	register unsigned int t;

	if ((bp = mp)==coremap && runin) {
		runin = 0;
		wakeup((caddr_t)&runin);	/* Wake scheduler when freeing core */
	}
	for (; bp->m_addr<=a && bp->m_size!=0; bp++);
	if (bp>mp && (bp-1)->m_addr+(bp-1)->m_size == a) {
		(bp-1)->m_size += size;
		if (a+size == bp->m_addr) {
			(bp-1)->m_size += bp->m_size;
			while (bp->m_size) {
				bp++;
				(bp-1)->m_addr = bp->m_addr;
				(bp-1)->m_size = bp->m_size;
			}
		}
	} else {
		if (a+size == bp->m_addr && bp->m_size) {
			bp->m_addr -= size;
			bp->m_size += size;
		} else if (size) {
			do {
				/* MUTOS: map holds at most 15 entries (not in V7) */
				if (bp - mp > 15)
					panic("map overflow\n");
				t = bp->m_addr;
				bp->m_addr = a;
				a = t;
				t = bp->m_size;
				bp->m_size = size;
				bp++;
			} while (size = t);
		}
	}
}
