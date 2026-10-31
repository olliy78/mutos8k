/* text.h -- text table entry (pure procedures).
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/text.h.
 * Evidence: H2 file similarity 78%; members and flags as in V7.  UNMEASURED beyond x_daddr 0, x_caddr 2, x_size 4,
 *           x_iptr 6, x_count 8, x_ccount 9, x_flag 0A (swapin/sched): in MUTOS xlock/xunlock/xccdec/xumount/xrele are
 *           stubs (8 bytes, only csv/cret) and there is no text table; p_textp stays in struct proc.
 * Deviations: none in the text; the structure is only used by xalloc/xfree.
 */
#ifndef TEXT_H
#define TEXT_H
/*
 * Text structure.
 * One allocated per pure
 * procedure on swap device.
 * Manipulated by text.c
 */
struct text
{
	short	x_daddr;	/* disk address of segment (relative to swplo) */
	short	x_caddr;	/* core address, if loaded */
	short	x_size;		/* size (clicks) */
	struct inode *x_iptr;	/* inode of prototype */
	char	x_count;	/* reference count */
	char	x_ccount;	/* number of loaded references */
	char	x_flag;		/* traced, written flags */
};

extern struct text text[];

#define	XTRC	01		/* Text may be written, exclusive use */
#define	XWRIT	02		/* Text written into, must swap out */
#define	XLOAD	04		/* Currently being read from file */
#define	XLOCK	010		/* Being swapped in or out */
#define	XWANT	020		/* Wanted for swapping */
#endif
