/* proc.h -- process table entry.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/proc.h (struct proc, stat and flag codes, struct xproc).
 * Evidence: H2 file similarity 75% V7.  Measured (run/dump): all members up to p_wchan and p_link; 28 bytes per entry from
 *           A11C, end pointer proctop 8A8C; p_sig is ONE word at +06 (psignal), p_uid +08, p_pgrp +0A (newproc/wait) --
 *           this corrects kernel_namen.md.  p_textp (+16) and p_clktim (+1A): V7/WEGA order, assumed.
 * Deviations: struct xproc (V7 text) is not used by name in the kernel (sys1.c declares its own copy); the Zombie
 *           layout at +10 (exit status) and +12 (utime, long) fits it.  slpque[] is declared here (MUTOS places the
 *           sleep queues in slp.c); the proc table is declared "proc[]" (defined elsewhere), V7 likewise.
 */
#ifndef PROC_H
#define PROC_H
#include "types.h"
/*
 * One structure allocated per active
 * process. It contains all data needed
 * about the process while the
 * process may be swapped out.
 * Other per process data (user.h)
 * is swapped with the process.
 */
struct	proc {
	char	p_stat;		/* +00 */
	char	p_flag;		/* +01 */
	char	p_pri;		/* priority, negative is high */	/* +02 */
	char	p_time;		/* resident time for scheduling */	/* +03 */
	char	p_cpu;		/* cpu usage for scheduling */		/* +04 */
	char	p_nice;		/* nice for cpu usage */		/* +05 */
	short	p_sig;		/* signals pending to this process */	/* +06 (psignal: sig < 17, 1<<(sig-1)) */
	short	p_uid;		/* user id, used to direct tty signals */	/* +08 (newproc copies +08 and +0A from the parent) */
	short	p_pgrp;		/* name of process group leader */	/* +0A */
	short	p_pid;		/* unique process id */			/* +0C */
	short	p_ppid;		/* process id of parent */		/* +0E */
	short	p_addr;		/* address of swappable image */	/* +10 (zombie: exit status) */
	short	p_size;		/* size of swappable image (clicks) */	/* +12 (zombie: xp_utime, long) */
	caddr_t p_wchan;	/* event process is awaiting */		/* +14 */
	struct text *p_textp;	/* pointer to text structure */		/* +16 */
	struct proc *p_link;	/* linked list of running processes */	/* +18 */
	int	p_clktim;	/* time to alarm clock signal */	/* +1A */
};

extern struct proc proc[];	/* the proc table itself */
extern struct proc *runq;	/* head of linked list of running processes */
extern struct proc *slpque[];	/* sleep queues (MUTOS: 64 hash chains, slp.c) */

/* stat codes */
#define	SSLEEP	1		/* awaiting an event */
#define	SWAIT	2		/* (abandoned state) */
#define	SRUN	3		/* running */
#define	SIDL	4		/* intermediate state in process creation */
#define	SZOMB	5		/* intermediate state in process termination */
#define	SSTOP	6		/* process being traced */

/* flag codes */
#define	SLOAD	01		/* in core */
#define	SSYS	02		/* scheduling process */
#define	SLOCK	04		/* process cannot be swapped */
#define	SSWAP	010		/* process is being swapped out */
#define	STRC	020		/* process is being traced */
#define	SWTED	040		/* another tracing flag */
#define	SULOCK	0100		/* user settable lock in core */

/*
 * parallel proc structure
 * to replace part with times
 * to be passed to parent process
 * in ZOMBIE state.
 */
struct	xproc {
	char	xp_stat;
	char	xp_flag;
	char	xp_pri;		/* priority, negative is high */
	char	xp_time;	/* resident time for scheduling */
	char	xp_cpu;		/* cpu usage for scheduling */
	char	xp_nice;	/* nice for cpu usage */
	short	xp_sig;		/* signals pending to this process */
	short	xp_uid;		/* user id, used to direct tty signals */
	short	xp_pgrp;	/* name of process group leader */
	short	xp_pid;		/* unique process id */
	short	xp_ppid;	/* process id of parent */
	short	xp_xstat;	/* Exit status for wait */
	time_t	xp_utime;	/* user time, this proc */
	time_t	xp_stime;	/* system time, this proc */
};
#endif
