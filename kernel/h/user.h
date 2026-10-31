/* user.h -- the user structure (u), fixed at FC00 (u plus kernel stack, USIZE 0x400 bytes), and the error codes.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/user.h (member names, order, comments, error codes).
 * Evidence: H2 file similarity 74% V7 / 62% System III.  Offsets measured from the kernel accesses (number of accesses in brackets):
 *   u_segflg 12(11) u_error 13(122) u_deverr 14(1) u_uid 16(20) u_gid 18(8) u_ruid 1A(5) u_rgid 1C(4) u_procp 1E(45)
 *   u_ap 20(33) u_r 22 (r_val1 22, r_val2 24; overlaid as long) u_base 26(24) u_count 28(41) u_offset 2A(36)
 *   u_cdir 2E(6) u_rdir 30(8) u_dbuf 32 u_dirp 40(10) u_dent 42 (d_ino 42, d_name 44) u_pdir 52(8)
 *   u_ofile 62 (index with CP #20) u_pofile 8A u_arg 9E u_tsize A8 u_dsize AA u_ssize AC u_qsav AE u_ssav C0
 *   u_signal D2 u_utime F4 u_stime F8 u_cutime FC u_cstime 100; K7c: u_ar0 104 (trap frame), u_prof 10A (scale at 110),
 *   u_sep 113, u_ex[20] 118 (header of the executed file, magic E807/E707), u_exname 140, u_start 14E, u_cmask 156 (umask),
 *   u_fpsaved 15A, u_fparea 15C..; K7d: u_ttyp 114, u_ttyd 116 (syopen/syread/sywrite/syioctl).  u_tsize/u_dsize/u_ssize are unsigned (SLL/SRL in the kernel).
 * Deviations: Z8001 layout, not the PDP-11 one: no u_fper/u_fps/u_uisa/u_uisd/u_stack; u_rsav (0..11, 9 words, deduced from
 *           u_segflg at 12), u_signal[17] (deduced from the space D2..F3) and the fillers (u_x15, u_x54, u_x106, u_x112, u_x152, u_x158)
 *           are assumed; u_fpsaved/u_fparea hold the Z8001 floating state; u_ex[] replaces struct u_exdata (magic words of the large
 *           header 40 bytes; known indexes: 0 mag, 1/2/3 tsize/dsize/bsize small header, 5 entry small, 8 entry large, 14/15/16 large);
 *           u_exname is V7 u_comm (assumed, exec copies it to u_dbuf); in V7 order u_x112 would be u_intflg and u_x152 u_acflag/u_fpflag
 *           (assumed, not measured).  Member names carry the prefix u_ (V7 cc: one name space for members and variables).
 */
#ifndef USER_H
#define USER_H
#include "param.h"
#include "dir.h"
/*
 * The user structure.
 * One allocated per process.
 * Contains all per process data
 * that doesn't need to be referenced
 * while the process is swapped.
 * The user block is USIZE*64 bytes
 * long; resides at virtual kernel
 * loc 140000; contains the system
 * stack per user; is cross referenced
 * with the proc structure for the
 * same process.
 */

struct	user
{
	label_t	u_rsav;			/* save info when exchanging stacks */	/* 000 assumed: 18 bytes */
	char	u_segflg;		/* IO flag: 0:user D; 1:system; 2:user I */	/* 012 */
	char	u_error;		/* return error code */		/* 013 */
	char	u_deverr;		/* (MUTOS; used once) */	/* 014 */
	char	u_x15;			/* filler */			/* 015 */
	short	u_uid;			/* effective user id */		/* 016 */
	short	u_gid;			/* effective group id */	/* 018 */
	short	u_ruid;			/* real user id */		/* 01A */
	short	u_rgid;			/* real group id */		/* 01C */
	struct proc *u_procp;		/* pointer to proc structure */	/* 01E */
	int	*u_ap;			/* pointer to arglist */	/* 020 */
	union {				/* syscall return values */	/* 022 */
		struct	{
			int	r_val1;
			int	r_val2;
		};
		off_t	r_off;
		time_t	r_time;
	} u_r;
	caddr_t	u_base;			/* base address for IO */	/* 026 */
	unsigned int u_count;		/* bytes remaining for IO */	/* 028 */
	off_t	u_offset;		/* offset in file for IO */	/* 02A */
	struct inode *u_cdir;		/* pointer to inode of current directory */	/* 02E */
	struct inode *u_rdir;		/* root directory of current process */	/* 030 */
	char	u_dbuf[DIRSIZ];		/* current pathname component */	/* 032 */
	caddr_t	u_dirp;			/* pathname pointer */		/* 040 */
	struct direct u_dent;		/* current directory entry */	/* 042 */
	struct inode *u_pdir;		/* inode of parent directory of dirp */	/* 052 */
	char	u_x54[14];		/* filler, no access */		/* 054 (V7: u_uisa/u_uisd) */
	struct file *u_ofile[NOFILE];	/* pointers to file structures of open files */	/* 062 */
	char	u_pofile[NOFILE];	/* per-process flags of open files */	/* 08A */
	int	u_arg[5];		/* arguments to current system call */	/* 09E */
	unsigned u_tsize;		/* text size (clicks) */	/* 0A8 */
	unsigned u_dsize;		/* data size (clicks) */	/* 0AA */
	unsigned u_ssize;		/* stack size (clicks) */	/* 0AC */
	label_t	u_qsav;			/* label variable for quits and interrupts */	/* 0AE */
	label_t	u_ssav;			/* label variable for swapping */	/* 0C0 */
	int	u_signal[NSIG];		/* disposition of signals */	/* 0D2 */
	time_t	u_utime;		/* this process user time */	/* 0F4 */
	time_t	u_stime;		/* this process system time */	/* 0F8 */
	time_t	u_cutime;		/* sum of childs' utimes */	/* 0FC */
	time_t	u_cstime;		/* sum of childs' stimes */	/* 100 */
	int	*u_ar0;			/* address of users saved R0 */	/* 104 (trap.c, sendsig) */
	char	u_x106[4];		/* no access */			/* 106 */
	struct {			/* profile arguments */		/* 10A (trap: addupc(pc, &u_prof, ticks)) */
		short	*pr_base;	/* buffer base */
		unsigned pr_size;	/* buffer size */
		unsigned pr_off;	/* pc offset */
		unsigned pr_scale;	/* pc scaling */
	} u_prof;
	char	u_x112;			/* (V7: u_intflg, assumed) */	/* 112 */
	char	u_sep;			/* flag for I and D separation */	/* 113 (exec, getxfile) */
	struct tty *u_ttyp;		/* controlling tty pointer */	/* 114 */
	dev_t	u_ttyd;			/* controlling tty dev */	/* 116 */
	int	u_ex[20];		/* header of executable file (V7: u_exdata) */	/* 118 */
	char	u_exname[14];		/* command name (V7: u_comm, assumed) */	/* 140 */
	time_t	u_start;		/* start time (fork) */		/* 14E */
	char	u_x152[4];		/* (V7: u_acflag, u_fpflag; assumed) */	/* 152..155 */
	short	u_cmask;		/* mask for file creation */	/* 156 (umask) */
	int	u_x158;			/* no access */			/* 158 */
	int	u_fpsaved;		/* FP regs saved for this proc */	/* 15A (trap, swtch, newproc: savfp(u_fparea)) */
	char	u_fparea[0x3FC - 0x15C];	/* FP area up to the kernel stack */	/* 15C.. */
};

extern struct user u;			/* FC00 */

/* u_error codes */
#define	EPERM	1
#define	ENOENT	2
#define	ESRCH	3
#define	EINTR	4
#define	EIO	5
#define	ENXIO	6
#define	E2BIG	7
#define	ENOEXEC	8
#define	EBADF	9
#define	ECHILD	10
#define	EAGAIN	11
#define	ENOMEM	12
#define	EACCES	13
#define	EFAULT	14
#define	ENOTBLK	15
#define	EBUSY	16
#define	EEXIST	17
#define	EXDEV	18
#define	ENODEV	19
#define	ENOTDIR	20
#define	EISDIR	21
#define	EINVAL	22
#define	ENFILE	23
#define	EMFILE	24
#define	ENOTTY	25
#define	ETXTBSY	26
#define	EFBIG	27
#define	ENOSPC	28
#define	ESPIPE	29
#define	EROFS	30
#define	EMLINK	31
#define	EPIPE	32
#define	EDOM	33
#define	ERANGE	34
#endif
