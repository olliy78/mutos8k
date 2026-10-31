/* buf.h -- buffer header.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/buf.h (struct buf with the b_un union, flag values, driver queue redeclarations).
 * Evidence: measured; H2 file similarity 71% (flat form, before AP H4), field order and names identical to V7;
 *           layout checked against the kernel (24 bytes, 20 entries at 8E9A, data at A628+512*i, doc/kernel/header_belegstand.md).
 * Deviations: B_PBUSY/B_PACK (Datakit) and the driver queue redeclarations b_actf/b_actl/b_active/b_errcnt of V7 are
 *           not defined (devtab in conf.h uses d_actf/d_actl/d_active/d_errcnt); b_error is at +15 and b_xmem at +14 (measured in geterror/physio); the buffer pool is
 *           "buf[NBUF]" instead of "buf[]".  All pointers are 16 bits wide, so the b_un union has the V7 size.
 *
 * Measured: 24 bytes, 20 entries from 8E9A, data A628+512*i.  b_resid at +16h (readi: BSIZE - b_resid).
 */
#ifndef BUF_H
#define BUF_H
#include "types.h"
/*
 * Each buffer in the pool is usually doubly linked into 2 lists:
 * the device with which it is currently associated (always)
 * and also on a list of blocks available for allocation
 * for other use (usually).
 * The latter list is kept in last-used order, and the two
 * lists are doubly linked to make it easy to remove
 * a buffer from one list when it was found by
 * looking through the other.
 * A buffer is on the available list, and is liable
 * to be reassigned to another disk block, if and only
 * if it is not marked BUSY.  When a buffer is busy, the
 * available-list pointers can be used for other purposes.
 * Most drivers use the forward ptr as a link in their I/O
 * active queue.
 * A buffer header contains all the information required
 * to perform I/O.
 * Most of the routines which manipulate these things
 * are in bio.c.
 */
struct buf
{
	int	b_flags;		/* see defines below */		/* +00 */
	struct	buf *b_forw;		/* headed by d_tab of conf.c */	/* +02 */
	struct	buf *b_back;		/*  "  */			/* +04 */
	struct	buf *av_forw;		/* position on free list, */	/* +06 */
	struct	buf *av_back;		/*     if not BUSY*/		/* +08 */
	dev_t	b_dev;			/* major+minor device name */	/* +0A */
	unsigned b_bcount;		/* transfer count */		/* +0C */
	union {								/* +0E */
	    caddr_t b_addr;		/* low order core address */
	    int	*b_words;		/* words for clearing */
	    struct filsys *b_filsys;	/* superblocks */
	    struct dinode *b_dino;	/* ilist */
	    daddr_t *b_daddr;		/* indirect block */
	} b_un;
	daddr_t	b_blkno;		/* block # on device */		/* +10 */
	char	b_xmem;			/* high order core address */	/* +14 (physio/swap: segment byte of b_addr) */
	char	b_error;		/* returned after I/O */	/* +15 (geterror: 15(bp)) */
	unsigned int b_resid;		/* words not transferred after error */	/* +16 */
};

extern struct buf buf[NBUF];		/* The buffer pool itself */
extern struct buf bfreelist;		/* head of available list; A518 */

/*
 * These flags are kept in b_flags.
 */
#define	B_WRITE	0	/* non-read pseudo-flag */
#define	B_READ	01	/* read when I/O occurs */
#define	B_DONE	02	/* transaction finished */
#define	B_ERROR	04	/* transaction aborted */
#define	B_BUSY	010	/* not on av_forw/back list */
#define	B_PHYS	020	/* Physical IO potentially using UNIBUS map */
#define	B_MAP	040	/* This block has the UNIBUS map allocated */
#define	B_WANTED 0100	/* issue wakeup when BUSY goes off */
#define	B_AGE	0200	/* delayed write for correct aging */
#define	B_ASYNC	0400	/* don't wait for I/O completion */
#define	B_DELWRI 01000	/* don't write till block leaves available list */
#define	B_TAPE 02000	/* this is a magtape (no bdwrite) */
#endif
