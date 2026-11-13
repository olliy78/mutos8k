/*
 * Print system stuff
 */

#define mask(x) (x&0377)
#include <stdio.h>
#include <sys/types.h>
/* Differs from V7: MUTOS kernel layouts in mutosk.h instead of <sys/param.h> <sys/conf.h> <sys/tty.h> <sys/inode.h> <sys/proc.h> ... */
#include "dir.h"
#include "mutosk.h"

/* Differs from V7: own nlist (name, value) filled from the kernel's table of addresses by main(), no nlist(3) call */
struct nlist {
	char	n_name[8];
	unsigned n_value;
};

struct nlist nl[] = {
	{"_proc"},
	{"_file"},
	{"_kl11"},
	{"_nkl11"},
	{"_ipc"},
	{"_buf"},
	{"_buffers"},
	{"_bfreeli"},
	{"_swbuf1"},{"_swbuf2"},
	{"_runin"},
	{"_runout"},
	{"_u"},
	{"_lbolt"},{"_time"},{"_callout"},
	{"_rrkbuf"},
	{"_text"},
	{"_inode"},
	{"_swapdev"},{"_swplo"},
	{"_rtmbuf"},
	{""},{""},{""},{""},{""},{""},
	{"_max_pro"},
};

char	*fcore	= "/dev/kmem";	/* Differs from V7: /dev/kmem instead of /dev/mem, no fnlist */
int	fc;

int	inof;
int	txtf;
int	prcf;
int	ttyf;
int	usrf;
long	ubase;
int	filf;
int	allflg;
unsigned nlbase;
unsigned oatoi();

main(argc, argv)
register argc;
register char **argv;
{
	int a[29];
	register i;

	while (--argc && **++argv == '-') {
		while (*++*argv)
		switch (**argv) {

		case 'a':
			allflg++;
			break;

		case 'i':
			inof++;
			break;

		case 'x':
			txtf++;
			break;
		case 'p':
			prcf++;
			break;

		case 't':
			ttyf++;
			break;

		case 'u':
			if (--argc == 0)
				break;
			usrf++;
			ubase = oatoi(*++argv);
			break;

		case 'f':
			filf++;
			break;
		}
	}
	if (argc>0)
		fcore = argv[0];
	if ((fc = open(fcore, 0)) < 0) {
		printf("Can't find %s\n", fcore);
		exit(1);
	}
	lseek(fc, (long)0x23C, 0);
	read(fc, (char *)&nlbase, 2);
	lseek(fc, (long)(nlbase+2), 0);
	read(fc, (char *)a, sizeof a);
	for(i = 0; i <= 28; i++)
		nl[i].n_value = a[i];
	if (inof)
		doinode();
	if (txtf)
		dotext();
	if (ttyf)
		dotty();
	if (prcf)
		doproc();
	if (usrf)
		dousr();
	if (filf)
		dofil();
}

doinode()
{
	int pad;
	register struct inode *ip;
	struct inode xinode[NINODE];
	register int nin, loc;

	nin = 0;
	lseek(fc, (long)nl[18].n_value, 0);
	read(fc, (char *)xinode, sizeof(xinode));
	for (ip = xinode; ip < &xinode[NINODE]; ip++)
		if (ip->i_count)
			nin++;
	printf("%d active inodes\n", nin);
	printf(" LOC FLAGS  CNT DEVICE   INO   MODE NLK UID  SIZE/DEV\n");
	loc = nl[18].n_value;
	for (ip = xinode; ip < &xinode[NINODE]; ip++, loc += sizeof(xinode[0])) {
		if (ip->i_count == 0)
			continue;
		printf("%4x ", loc);
		putf(ip->i_flag&ILOCK, 'L');
		putf(ip->i_flag&IUPD, 'U');
		putf(ip->i_flag&IACC, 'A');
		putf(ip->i_flag&IMOUNT, 'M');
		putf(ip->i_flag&IWANT, 'W');
		putf(ip->i_flag&ITEXT, 'T');
		printf("%4d", ip->i_count&0377);
		printf("%3d,%3d", major(ip->i_dev), minor(ip->i_dev));
		printf("%6ld", (long)ip->i_number);
		printf("%7x", ip->i_mode);
		printf("%4d", ip->i_nlink);
		printf("%4d", ip->i_uid);
		if ((ip->i_mode&IFMT)==IFBLK || (ip->i_mode&IFMT)==IFCHR)
			printf("%6d,%3d", major(ip->i_un.i_rdev), minor(ip->i_un.i_rdev));
		else
			printf("%10ld", ip->i_size);
		printf("\n");
	}
}

putf(v, n)
{
	if (v)
		printf("%c", n);
	else
		printf(" ");
}

dotext()
{
}

doproc()
{
	struct proc xproc[NPROC];
	register struct proc *pp;
	register loc, np;

	lseek(fc, (long)nl[0].n_value, 0);
	read(fc, (char *)xproc, sizeof(xproc));
	np = 0;
	for (pp=xproc; pp < &xproc[NPROC]; pp++)
		if (pp->p_stat)
			np++;
	printf("%d processes\n", np);
	printf(" LOC S  F PY  SIG UI TI CP NI PGR  PI PPI ADD SIZ  WCH LINK TEXT CLKT\n");
	for (loc=nl[0].n_value,pp=xproc; pp<&xproc[NPROC]; pp++,loc+=sizeof(xproc[0])) {
		if (pp->p_stat==0 && allflg==0)
			continue;
		printf("%4x", loc);
		printf("%2d", pp->p_stat);
		printf("%3x", pp->p_flag);
		printf("%3x", pp->p_pri);
		printf("%5x", pp->p_sig);
		printf("%3d", pp->p_uid&0377);
		printf("%3x", pp->p_time&0377);
		printf("%3x", pp->p_cpu&0377);
		printf("%3x", pp->p_nice);
		printf("%4d", pp->p_pgrp);
		printf("%4d", pp->p_pid);
		printf("%4d", pp->p_ppid);
		printf("%4x", pp->p_addr);
		printf("%4x", pp->p_size);
		printf("%5x", pp->p_wchan);
		printf("%5x", pp->p_link);
		printf("%5x", pp->p_textp);
		printf(" %5x", pp->p_clktim);
		printf("\n");
	}
}

dotty()
{
	ttylist(3, 2, "terminals");
}

ttylist(nn, tt, name)
char *name;
{
	struct tty dh11[48];
	int n;
	register struct tty *tp;
	register char *mesg = " # RAW OUT FLGS ADDR DEL COL    STATE PGR\n";

	lseek(fc, (long)nl[nn].n_value, 0);
	read(fc, (char *)&n, sizeof(n));
	printf("%d %s\n", n, name);
	printf(mesg);
	lseek(fc, (long)nl[tt].n_value, 0);
	read(fc, (char *)dh11, sizeof(dh11));
	for (tp = dh11; tp < &dh11[n]; tp++)
		ttyprt(tp-dh11, tp);
}

ttyprt(n, atp)
struct tty *atp;
{
	register struct tty *tp;

	tp = atp;
	printf("%2d", n);
	printf("%4d", tp->t_rawq.c_cc);
	printf("%4d", tp->t_outq.c_cc);
	printf("%5x", tp->t_flags);
	printf("%5x", tp->t_addr);
	printf("%4d", tp->t_delct);
	printf("%4d ", tp->t_col);
	putf(tp->t_state&TIMEOUT, 'T');
	putf(tp->t_state&WOPEN, 'W');
	putf(tp->t_state&ISOPEN, 'O');
	putf(tp->t_state&CARR_ON, 'C');
	putf(tp->t_state&BUSY, 'B');
	putf(tp->t_state&ASLEEP, 'A');
	putf(tp->t_state&XCLUDE, 'X');
	putf(tp->t_state&HUPCLS, 'H');
	printf("%4d", tp->t_pgrp);
	printf("\n");
}

dousr()
{
	union {
		struct	user rxu;
		char	fxu[ctob(USIZE)];
	} xu;
	register struct user *up;
	register i;

	lseek(fc, ubase, 0);
	read(fc, (char *)&xu, sizeof(xu));
	up = &xu.rxu;
	printf("user structure at %lx\n", ubase);
	printf("rsav %x %x %x\n", up->u_rsav[0], up->u_rsav[7], up->u_rsav[8]);
	printf("segflg, error %d, %d\n", up->u_segflg, up->u_error);
	printf("uids %d,%d,%d,%d\n", up->u_uid,up->u_gid,up->u_ruid,up->u_rgid);
	printf("procp %x\n", up->u_procp);
	printf("base, count, offset %x %x %ld\n", up->u_base,
		up->u_count, up->u_offset);
	printf("cdir %x\n", up->u_cdir);
	printf("dbuf %.14s\n", up->u_dbuf);
	printf("dirp %x\n", up->u_dirp);
	printf("dent %d %.14s\n", up->u_dent.d_ino, up->u_dent.d_name);
	printf("pdir %x\n", up->u_pdir);
	printf("\nfile");
	for (i=0; i<10; i++)
		printf("%5x", up->u_ofile[i]);
	printf("\n    ");
	for (i=10; i<NOFILE; i++)
		printf("%5x", up->u_ofile[i]);
	printf("\nargs");
	for (i=0; i<5; i++)
		printf(" %4x", up->u_arg[i]);
	printf("\nsizes %x %x %x\n", up->u_tsize, up->u_dsize, up->u_ssize);
	printf("qsav %4x %4x %4x\n", up->u_qsav[0], up->u_qsav[7], up->u_qsav[8]);
	printf("ssav %4x %4x %4x\n", up->u_ssav[0], up->u_ssav[7], up->u_ssav[8]);
	printf("sigs");
	for (i=0; i<NSIG; i++)
		printf(" %x", up->u_signal[i]);
	printf("\ntimes %ld %ld\n", up->u_utime/50, up->u_stime/50);
	printf("ctimes %ld %ld\n", up->u_cutime/50, up->u_cstime/50);
	printf("ar0 %x\n", up->u_ar0);
	printf("\nintflg %d\n", up->u_intflg);
	printf("ttyp %x\n", up->u_ttyp);
	printf("ttydev %d,%d\n", major(up->u_ttyd), minor(up->u_ttyd));
	printf("comm %.14s\n", up->u_comm);
}

unsigned
oatoi(s)
register char *s;
{
	register unsigned v;
	register c;

	v = 0;
	while (*s) {
		c = *s++;
		v <<= 4;
		if (c >= '0' && c <= 9)
			v += c - '0';
		else if (c >= 'A' && c <= 'F')
			v += c - 'A' + 10;
		else if (c >= 'a' && c <= 'f')
			v += c - 'a' + 10;
	}
	return(v);
}

dofil()
{
	struct file xfile[NFILE];
	register struct file *fp;
	register nf, loc;

	nf = 0;
	lseek(fc, (long)nl[1].n_value, 0);
	read(fc, (char *)xfile, sizeof(xfile));
	for (fp=xfile; fp < &xfile[NFILE]; fp++)
		if (fp->f_count)
			nf++;
	printf("%d open files\n", nf);
	printf(" LOC FLG CNT INOD OFFS\n");
	for (fp=xfile,loc=nl[1].n_value; fp < &xfile[NFILE]; fp++,loc+=sizeof(xfile[0])) {
		if (fp->f_count==0)
			continue;
		printf("%4x ", loc);
		putf(fp->f_flag&FREAD, 'R');
		putf(fp->f_flag&FWRITE, 'W');
		putf(fp->f_flag&FPIPE, 'P');
		printf("%4d", mask(fp->f_count));
		printf("%5x", fp->f_inode);
		printf(" %X\n", fp->f_un.f_offset);
	}
}
