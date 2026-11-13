/*
 * Kernel structures of MUTOS 8000 (Z8001) as ps and pstat see them in /dev/mem.
 * Differs from V7: the V7 headers have the PDP-11 layout.  This file collects the measured MUTOS layout
 * (kernel/h/proc.h, user.h, inode.h, file.h, text.h, tty.h of this repository, doc/kernel/header_belegstand.md);
 * the original ps/pstat were built against kernel headers that are not on /usr/include.
 */
#define NPROC	30
#define NINODE	50
#define NFILE	50
#define NOFILE	20
#define NSIG	17

#define USIZE	4		/* user block: 4 clicks of 256 bytes */
#define ctob(x)	((x)<<8)

struct	proc {
	char	p_stat;
	char	p_flag;
	char	p_pri;
	char	p_time;
	char	p_cpu;
	char	p_nice;
	short	p_sig;
	short	p_uid;
	short	p_pgrp;
	short	p_pid;
	short	p_ppid;
	short	p_addr;
	short	p_size;
	caddr_t	p_wchan;
	struct text *p_textp;
	struct proc *p_link;
	int	p_clktim;
};

/* stat codes */
#define	SSLEEP	1
#define	SWAIT	2
#define	SRUN	3
#define	SIDL	4
#define	SZOMB	5
#define	SSTOP	6

/* flag codes */
#define	SLOAD	01
#define	SSYS	02
#define	SLOCK	04
#define	SSWAP	010
#define	STRC	020
#define	SWTED	040
#define	SULOCK	0100

struct	user
{
	int	u_rsav[9];
	char	u_segflg;
	char	u_error;
	char	u_deverr;
	char	u_x15;
	short	u_uid;
	short	u_gid;
	short	u_ruid;
	short	u_rgid;
	struct proc *u_procp;
	int	*u_ap;
	int	u_r1;
	int	u_r2;
	caddr_t	u_base;
	unsigned int u_count;
	off_t	u_offset;
	struct inode *u_cdir;
	struct inode *u_rdir;
	char	u_dbuf[DIRSIZ];
	caddr_t	u_dirp;
	struct direct u_dent;
	struct inode *u_pdir;
	char	u_x54[14];
	struct file *u_ofile[NOFILE];
	char	u_pofile[NOFILE];
	int	u_arg[5];
	unsigned u_tsize;
	unsigned u_dsize;
	unsigned u_ssize;
	int	u_qsav[9];
	int	u_ssav[9];
	int	u_signal[NSIG];
	time_t	u_utime;
	time_t	u_stime;
	time_t	u_cutime;
	time_t	u_cstime;
	int	*u_ar0;
	char	u_x106[4];
	short	*u_prbase;
	unsigned u_prsize;
	unsigned u_proff;
	unsigned u_prscale;
	char	u_intflg;
	char	u_sep;
	struct tty *u_ttyp;
	dev_t	u_ttyd;
	int	u_ex[20];
	char	u_comm[14];
	time_t	u_start;
	char	u_x152[4];
	short	u_cmask;
	int	u_x158;
	int	u_fpsaved;
	char	u_fparea[0x400 - 0x15C];	/* Differs from kernel/h/user.h: filled up to the 0x400 bytes ps reads */
};

struct	inode
{
	char	i_flag;
	char	i_count;
	dev_t	i_dev;
	ino_t	i_number;
	unsigned short	i_mode;
	short	i_nlink;
	short	i_uid;
	short	i_gid;
	off_t	i_size;
	union {
		struct {
			daddr_t i_addr[13];
			daddr_t	i_lastr;
		};
		struct	{
			daddr_t	i_rdev;
		};
	} i_un;
};

#define	ILOCK	01
#define	IUPD	02
#define	IACC	04
#define	IMOUNT	010
#define	IWANT	020
#define	ITEXT	040
#define	IFMT	0170000
#define	IFCHR	0020000
#define	IFBLK	0060000

struct	file
{
	char	f_flag;
	char	f_count;
	struct inode *f_inode;
	union {
		off_t	f_offset;
		struct chan *f_chan;
	} f_un;
};

#define	FREAD	01
#define	FWRITE	02
#define	FPIPE	04

struct clist {
	int	c_cc;
	char	*c_cf;
	char	*c_cl;
};

struct tty {
	struct clist t_rawq;
	struct clist t_outq;
	int	(* t_oproc)();
	int	(* t_iproc)();
	short	t_pgrp;
	caddr_t	t_addr;
	dev_t	t_dev;
	char	t_ispeed;
	char	t_ospeed;
	char	t_erase;
	char	t_kill;
	short	t_flags;
	char	t_nldly;
	char	t_crdly;
	char	t_htdly;
	char	t_vtdly;
	char	t_width;
	char	t_length;
	struct clist t_ctlq;
	short	t_state;
	short	t_xstate;
	char	t_lnum;
	char	t_col;
	char	t_delct;
	char	t_char;
	struct chan *t_chan;
	caddr_t	t_linep;
	char	t_line;
	char	t_x35;
	int	t_ocnt;
	struct rkmbx *t_hwp;
	char	t_hwf;
	char	t_x3b;
};

#define	TIMEOUT	01
#define	WOPEN	02
#define	ISOPEN	04
#define	CARR_ON	020
#define	BUSY	040
#define	ASLEEP	0100
#define	XCLUDE	0200
#define	HUPCLS	01000
