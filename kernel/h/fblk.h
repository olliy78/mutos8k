/* fblk.h -- free-list block.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/fblk.h.
 * Evidence: text identical (AP H3, alloc); on disk the block holds an int count followed by NICFREE block numbers.
 * Deviations: none in the text.  In the Z8001 build daddr_t is long, so df_free starts at offset 2 (the same offset
 *           the decompiled alloc.c used as "(int *)b_addr + 1"; round trip: same object code).
 */
#ifndef FBLK_H
#define FBLK_H
#include "param.h"
struct fblk
{
	int    	df_nfree;
	daddr_t	df_free[NICFREE];
};
#endif
