/* param.h -- tunable variables, priorities, signals, fundamental constants.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/param.h (names, order and comments); signal names SIGKILL/SIGALRM/SIGUSR1/SIGUSR2 and the
 *           Z8001 values are MUTOS (System III spells signals this way).
 * Evidence: H2 file similarity 52% V7 / 44% System III.  Measured in the kernel: NOFILE 20, BSIZE 512, NINODE 50, NFILE 50,
 *           NBUF 20, NMOUNT 5, NPROC 30 (proc A11C..A464, 0x348/0x1C), MAXUPRC 15 (fork compares with 15), NCALL 9 (callout
 *           CE58..CE8E), sleep queue 64 chains (slpque, hash (chan>>5)&63), clock 50 Hz, PZERO 25, NZERO 20, DIRSIZ 14,
 *           NSIG 17 (psignal: sig < 17; u_signal[17]), error numbers ENFILE 23 / EMFILE 24 / EBADF 9 / EPERM 1.
 *           Marked "guessed" below: not measured (taken from V7/WEGA, check before use).
 * Deviations: the tunables have MUTOS values; the click is 256 bytes (V7: 64), hence ctod; macros V7 has but the kernel does
 *           not use are not defined (SINCR, CANBSIZ, NTEXT, NCLIST, TIMEZONE, DSTFLAG, MSGBUFS, NBPW, BSLOP, USIZE, UBASE,
 *           INFSIZE, CBSIZE, CROUND, ctos, stoc, ctob, btoc, UMODE, USERMODE, INTPRI, BASEPRI); the typedefs are in types.h.
 */
#ifndef PARAM_H
#define PARAM_H
#include "types.h"
/*
 * tunable variables
 */

#define	NBUF	20		/* size of buffer cache */
#define	NINODE	50		/* number of in core inodes */
#define	NFILE	50		/* number of in core file structures */
#define	NMOUNT	5		/* number of mountable file systems */
#define	MAXMEM	64		/* max core per process (guessed) */
#define	MAXUPRC	15		/* max processes per user */
#define	SSIZE	5		/* initial stack size (guessed) */
#define	NOFILE	20		/* max open files per process */
#define	CMAPSIZ	50		/* size of core allocation area (guessed) */
#define	SMAPSIZ	50		/* size of swap allocation area (guessed) */
#define	NCALL	9		/* max simultaneous time callouts (callout CE58..CE8E, 6 bytes per entry) */
#define	NPROC	30		/* max number of processes (proc[] A11C..A464) */
#define	HZ	50		/* Ticks/second of the clock */
#define	NCARGS	5120		/* # characters in exec arglist (guessed) */

/*
 * priorities
 * probably should not be
 * altered too much
 */

#define	PSWP	0
#define	PINOD	10
#define	PRIBIO	20
#define	PZERO	25
#define	NZERO	20
#define	PPIPE	26
#define	PWAIT	30
#define	PSLEP	40
#define	PUSER	50

/*
 * signals
 * dont change
 */

#define	NSIG	17
/*
 * No more than 16 signals (1-16) because they are
 * stored in bits in a word.
 */
#define	SIGHUP	1	/* hangup */
#define	SIGINT	2	/* interrupt (rubout) */
#define	SIGQUIT	3	/* quit (FS) */
#define	SIGILL	4	/* illegal instruction (System III name) */
#define	SIGINS	4	/* illegal instruction */
#define	SIGTRAP	5	/* trace or breakpoint (System III name) */
#define	SIGTRC	5	/* trace or breakpoint */
#define	SIGIOT	6	/* iot */
#define	SIGEMT	7	/* emt */
#define	SIGFPE	8	/* floating exception (System III name) */
#define	SIGFPT	8	/* floating exception */
#define	SIGKILL	9	/* kill, uncatchable termination (System III name) */
#define	SIGKIL	9	/* kill, uncatchable termination */
#define	SIGBUS	10	/* bus error */
#define	SIGSEG	11	/* segmentation violation */
#define	SIGSYS	12	/* bad system call */
#define	SIGPIPE	13	/* end of pipe */
#define	SIGALRM	14	/* alarm clock (System III name) */
#define	SIGCLK	14	/* alarm clock */
#define	SIGTRM	15	/* Catchable termination */
#define	SIGUSR1	16	/* user defined signal 1 (System III) */
#define	SIGUSR2	17	/* user defined signal 2 (System III) */

/*
 * fundamental constants of the implementation--
 * cannot be changed easily
 */

#define	BSIZE	512		/* size of secondary block (bytes) */
#define	NINDIR	(BSIZE/sizeof(daddr_t))
#define	BMASK	0777		/* BSIZE-1 */
#define	BSHIFT	9		/* LOG2(BSIZE) */
#define	NMASK	0177		/* NINDIR-1 */
#define	NSHIFT	7		/* LOG2(NINDIR) */
#define	NODEV	(dev_t)(-1)
#define	CMASK	0		/* default mask for file creation */
#define	ROOTINO	((ino_t)2)	/* i number of all roots */
#define	SUPERB	1		/* block number of the super block (V7: ((daddr_t)1); with it ialloc grows by 2 bytes: measured) */
#define	DIRSIZ	14		/* max characters per directory */
#define	NICINOD	100		/* number of superblock inodes */
#define	NICFREE	50		/* number of superblock free blocks */
#define	ISIG	1		/* signal flag in tty (guessed) */

/*
 * Some macros for units conversion
 */
/* Core clicks to disk blocks (MUTOS: click = 256 bytes; V7: ((x+7)>>3) for 64-byte clicks) */
#define	ctod(x)		(((x)+1)>>1)

/* inumber to disk address */
#define	itod(x)	(daddr_t)((((unsigned)(x)+15)>>3))

/* inumber to disk offset */
#define	itoo(x)	(int)(((x)+15)&07)

/* major part of a device */
#define	major(x)	(int)(((unsigned)(x)>>8))

/* minor part of a device */
#define	minor(x)	(int)((x)&0377)

/* make a device number */
#define	makedev(x,y)	(dev_t)((x)<<8 | (y))
#endif
