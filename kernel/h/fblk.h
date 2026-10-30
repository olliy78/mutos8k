/* fblk.h -- free-list block (UNIX V7 usr/sys/h/fblk.h, unchanged).
 * On disk the block holds an int count followed by NICFREE block numbers; in the Z8001 build daddr_t is long, so
 * df_free starts at offset 2 (the same offset the decompiled alloc.c used as "(int *)b_addr + 1"). */
#ifndef FBLK_H
#define FBLK_H
#include "param.h"
struct fblk
{
	int    	df_nfree;
	daddr_t	df_free[NICFREE];
};
#endif
