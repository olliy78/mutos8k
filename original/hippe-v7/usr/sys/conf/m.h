/*
 * This file contains all the defines
 * which tailor the system to the machine.
 */

/*#define _1123		/* */
/*#define _1124		/* */
/*#define _1134		/* */
#define _1140		/* */
/*#define _1160		/* */
/*#define _1144		/* */
/*#define _1145		/* */
/*#define _1170		/* */

/*#define SEPID		/* Code to set D space segmentation registers,
			 * and some other bits.
			 * rdwri.c, sig.c, subr.c ureg.c
			 */
/*#define PARITY	/* PDP-11/70 style memory parity errors.
			 * trap.c
			 */
/*#define UNIBMAP	/* PDP-11/70 style Unibus map.
			 * machdep.c, bio.c, rf.c, rk.c, tc.c, tm.c
			 */
/*#define FPP		/* FP-11 style hardware floating point
			 * m.h
			 */

/*
 * The following defines switch
 * in/out bits of code.
 */
/*#define SYSACCT	/* "acct" system call
			 * c.c, acct.c, fio.c, machdep.c, sys1.c sysent.c
			 */
/*#define SYSPHYS	/* "sysphys" system call
			 * machdep.c, sysent.c
			 * switching this on costs 192 bytes
			 */
/*#define SYSLOCK	/* "syslock" system call
			 * acct.c, sysent.c
			 * switching this on costs 40 bytes
			 */
/*#define DISKMON	/* buffer usage statistics
			 * bio.c
			 * switching this on costs 92 bytes
			 */
/*#define INSTRM	/* disk/terminal instrumentation
			 * systm.h, clock.c, various device drivers
			 */
/*#define PROFIL	/* system profiler 
			 * only supplied for the large machines!
			 * mch.c
			 */
/*#define MX		/* multiplex files
			 * c.c, nami.c, prim.c, sysent.c, dz.c, kl.c, tty.c
			 */
/*#define SGTTY		/* stty/gtty system calls. Use ioctl instead (the 
			 * C library does anyway).
			 * sysent.c, tty.c
			 * switching this on costs 138 bytes
			 */
/*#define DH11		/* Special routines for DH-11 multiplexer.
			 * prim.c
			 */

/*
 * The following defines
 * implement efficiency changes.
 */
#define PROC_MAX	/* A high-water mark on the proc table is
			 * maintained to diminish searching.
			 * proc.h, clock.c, sig.c, slp.c, sys1.c, sys4.c
			 * switching this on costs 46 bytes
			 */
#define EXIT		/* When a process dies, only scan the
			 * proc table once.
			 * sys1.c
			 * This costs you nothing!
			 */
#define LRUI		/* Allocate inodes on a least-recently-used
			 * basis.
			 * inode.h, iget.c, sys3.c, sys4.c
			 * switching this on costs (NINODE*4)+x
			 * bytes, where x is a small number
			 */

/*
 * O.K., so the flipping thing won't fit!
 * so we port stuff out of the kernel!
 */
/*#define XBUF		/* Move the i/o buffers out
			 * Taken from the Vrije system by Johan Stevenson
			 * who converted it from  Version 6 Calgary system.
			 * He also took the inodes out.... (maybe later!).
			 */

/*
 * The following section gets the defines right for machine support
 */
#ifdef _1123
#define BUP_FPP
#define BUP_23
#define DIV_FIX
#endif _1123

#ifdef _1124
/* guesswork */
#define BUP_FPP
#define BUP_23
#define DIV_FIX
#endif _1124

#ifdef _1134
#define BUP_FPP
#define BUP_M2S
#define BUP_M2D
#define BUP_SP
#endif _1134

#ifdef _1140
#endif _1140

#ifdef _1160
#define BUP_SP
#define CPU_ERR
#endif _1160

#ifdef _1144
#define DIV_FIX
#define CPU_ERR
#endif _1144

#ifdef _1145
#endif _1145

#ifdef _1170
#define CPU_ERR
#endif _1170

/*
 * Dump devices (define device and set to drive number)
 */

/*#define HTDUMP 0	/* TU16 tape	*/
#define TUDUMP	0	/* TU10 tape	*/
/*#define RKDUMP 0	/* RK05 disk	*/
/*#define RLDUMP 0	/* RL0[12] disk	*/
