/* filsys.h -- super block.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/filsys.h.
 * Evidence: H2 file similarity 94% V7 (78% System III).  Measured: s_nfree +6, s_free +8, s_ninode +D0, s_inode +D2,
 *           s_flock +19A, s_ilock +19B, s_fmod +19C, s_ronly +19D (access), s_time +19E, s_tfree +1A2, s_tinode +1A6
 *           (alloc/ialloc/ifree/getfs/update); in core daddr_t is long, so the 3-byte disk addresses are expanded.
 * Deviations: s_tfree/s_tinode ("remainder not maintained by this version of the system" in V7) are maintained by the
 *           MUTOS kernel, as in the Hippe collection and System III (see alloc.c).
 */
#ifndef FILSYS_H
#define FILSYS_H
#include "param.h"
/*
 * Structure of the super-block
 */
struct	filsys {
	unsigned short s_isize;	/* size in blocks of i-list */
	daddr_t	s_fsize;   	/* size in blocks of entire volume */
	short  	s_nfree;   	/* number of addresses in s_free */
	daddr_t	s_free[NICFREE];/* free block list */
	short  	s_ninode;  	/* number of i-nodes in s_inode */
	ino_t  	s_inode[NICINOD];/* free i-node list */
	char   	s_flock;   	/* lock during free list manipulation */
	char   	s_ilock;   	/* lock during i-list manipulation */
	char   	s_fmod;    	/* super block modified flag */
	char   	s_ronly;   	/* mounted read-only flag */
	time_t 	s_time;    	/* last super block update */
	/* remainder not maintained by this version of the system */
	daddr_t	s_tfree;   	/* total free blocks*/
	ino_t  	s_tinode;  	/* total free inodes */
	short  	s_m;       	/* interleave factor */
	short  	s_n;       	/* " " */
	char   	s_fname[6];	/* file system name */
	char   	s_fpack[6];	/* file system pack name */
};
#endif
