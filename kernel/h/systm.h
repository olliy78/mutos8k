/* systm.h -- global kernel variables and function types.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/systm.h (declarations, comments, struct sysent).
 * Evidence: H2 file similarity 49% (V7 defines the variables here, MUTOS only declares them as extern; the definitions
 *           are distributed over the modules).  Measured addresses: rootdev 887C, swapdev 887E, pipedev 8880, swplo 8884 (long),
 *           nswap 8888, proctop 8A8C, user access segment/base 8DC0, lbolt 8DCA, time 8DCC (long), nblkdev 8DD0, nchrdev 8DD2,
 *           mpid 8DD4, runin 8DD6, runout 8DD8, curpri 8DDA, runrun 8DC4, rablock 8DE4, slpque CEC6 (64 pointers).
 *           sy_nrarg: measured 0 in all 64 entries of sysent (8B58..8C57).
 * Deviations: not in MUTOS: canonb, cputype, maxmem, lks, msgbuf, regloc, icode/szicode (declared in the modules that use
 *           them), getmdev, dk_ and tk_ instrumentation variables.  Added: proctop, nodev/nulldev (V7 declares them in conf.c).
 */
#ifndef SYSTM_H
#define SYSTM_H
#include "param.h"
/*
 * Random set of variables
 * used by more than one
 * routine.
 */
extern struct inode *rootdir;	/* pointer to inode of root directory */
extern struct proc *proctop;	/* end of the process table (MUTOS) */
extern int	lbolt;		/* time of day in 60th not in time */
extern time_t	time;		/* time in sec from 1970 */

/*
 * Nblkdev is the number of entries
 * (rows) in the block switch. It is
 * set in binit/bio.c by making
 * a pass over the switch.
 * Used in bounds checking on major
 * device numbers.
 */
extern int	nblkdev;

/*
 * Number of character switch entries.
 * Set by cinit/tty.c
 */
extern int	nchrdev;

extern int	mpid;		/* generic for unique process id's */
extern char	runin;		/* scheduling flag */
extern char	runout;		/* scheduling flag */
extern char	runrun;		/* scheduling flag */
extern char	curpri;		/* more scheduling */
extern daddr_t	swplo;		/* block number of swap space */
extern int	nswap;		/* size of swap space */
extern daddr_t	rablock;	/* block to be read ahead */
extern dev_t	rootdev;	/* device of the root */
extern dev_t	swapdev;	/* swapping device */
extern dev_t	pipedev;	/* pipe device */

daddr_t	bmap();
struct inode *ialloc();
struct inode *iget();
struct inode *owner();
struct inode *maknode();
struct inode *namei();
struct buf *alloc();
struct buf *getblk();
struct buf *geteblk();
struct buf *bread();
struct buf *breada();
struct filsys *getfs();
struct file *getf();
struct file *falloc();
int	uchar();
int	nodev();
int	nulldev();

/*
 * Structure of the system-entry table
 */
extern struct sysent {
	char	sy_narg;		/* total number of arguments */
	char	sy_nrarg;		/* number of args in registers (0 in MUTOS) */
	int	(*sy_call)();		/* handler */
} sysent[];
#endif
