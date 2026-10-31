/* sys4.c -- small system calls (kernel mutos_1216, 4C14..51B2): gtime, ftime, stime, setuid, getuid, setgid, getgid,
 * getpid, sync, nice, unlink, chdir, chroot, chdirec, chmod, chown, ssig, kill, times, profil, alarm, pause, umask, utime.
 * (The K6b names were shifted by one: 5100 is alarm, not nice; nice is at 4D76.  There is no getswit here.)
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/sys4.c (all 24 functions).  System III PDP-11 uts/os/sys4.c differs (setpgrp, ulimit,
 *           utssys-style changes); not used.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 83% V7 / 58% System III PDP-11 (before the
 *           restoration), 21 of 24 functions above 50% against V7.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/sys4.md.
 * Deviations: stime also clears i_lastr of all inodes; kill scans up to proctop instead of &proc[NPROC]; ftime returns
 *           timezone 0 and no daylight saving; see doc/herkunft/sys4.md.
 *
 * Data: time = 8DCC (long), lbolt = 8DCA (tick counter). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "inode.h"
#include "file.h"
#include "reg.h"
#include "timeb.h"

/* MUTOS: Greenwich time, no daylight saving (V7 param.h: TIMEZONE (5*60), DSTFLAG 1) */
#define	TIMEZONE	0
#define	DSTFLAG	0

/*
 * Everything in this file is a routine implementing a system call.
 */

/*
 * return the current time (old-style entry)
 */
/* KERNEL 4C14 */
gtime()
{
	u.u_r.r_time = time;
}

/*
 * New time entry-- return TOD with milliseconds, timezone,
 * DST flag
 */
/* KERNEL 4C24 */
ftime()
{
	register struct a {
		struct	timeb	*tp;
	} *uap;
	struct timeb t;
	register unsigned ms;

	uap = (struct a *)u.u_ap;
	spl7();
	t.time = time;
	ms = lbolt;
	spl0();
	if (ms > HZ) {
		ms -= HZ;
		t.time++;
	}
	/* MUTOS: ms is converted to int, the kernel divides signed (V7: (1000*ms)/HZ) */
	t.millitm = (1000*(int)ms)/HZ;
	t.timezone = TIMEZONE;
	t.dstflag = DSTFLAG;
	if (copyout((caddr_t)&t, (caddr_t)uap->tp, sizeof(t)) < 0)
		u.u_error = EFAULT;
}

/*
 * Set the time
 */
/* KERNEL 4C94 */
stime()
{
	register struct a {
		time_t	time;
	} *uap;
	register struct inode *ip;

	uap = (struct a *)u.u_ap;
	if(suser()) {
		/* MUTOS: forget the release times of free inode entries (i_lastr, see iget.c) */
		for(ip = &inode[0]; ip < &inode[NINODE]; ip++)
			ip->i_un.i_lastr = 0;
		time = uap->time;
	}
}

/* KERNEL 4CC6 */
setuid()
{
	register uid;
	register struct a {
		int	uid;
	} *uap;

	uap = (struct a *)u.u_ap;
	uid = uap->uid;
	if(u.u_ruid == uid || suser()) {
		u.u_uid = uid;
		u.u_procp->p_uid = uid;
		u.u_ruid = uid;
	}
}

/* KERNEL 4CF4 */
getuid()
{

	u.u_r.r_val1 = u.u_ruid;
	u.u_r.r_val2 = u.u_uid;
}

/* KERNEL 4D0C */
setgid()
{
	register gid;
	register struct a {
		int	gid;
	} *uap;

	uap = (struct a *)u.u_ap;
	gid = uap->gid;
	if(u.u_rgid == gid || suser()) {
		u.u_gid = gid;
		u.u_rgid = gid;
	}
}

/* KERNEL 4D32 */
getgid()
{

	u.u_r.r_val1 = u.u_rgid;
	u.u_r.r_val2 = u.u_gid;
}

/* KERNEL 4D4A */
getpid()
{
	u.u_r.r_val1 = u.u_procp->p_pid;
	u.u_r.r_val2 = u.u_procp->p_ppid;
}

/* KERNEL 4D6A */
sync()
{

	update();
}

/* KERNEL 4D76 */
nice()
{
	register n;
	register struct a {
		int	niceness;
	} *uap;

	uap = (struct a *)u.u_ap;
	n = uap->niceness;
	if(n < 0 && !suser())
		n = 0;
	n += u.u_procp->p_nice;
	if(n >= 2*NZERO)
		n = 2*NZERO -1;
	if(n < 0)
		n = 0;
	u.u_procp->p_nice = n;
}

/*
 * Unlink system call.
 * Hard to avoid races here, especially
 * in unlinking directories.
 */
/* KERNEL 4DBC */
unlink()
{
	register struct inode *ip, *pp;
	struct a {
		char	*fname;
	};

	pp = namei(uchar, 2);
	if(pp == NULL)
		return;
	/*
	 * Check for unlink(".")
	 * to avoid hanging on the iget
	 */
	if (pp->i_number == u.u_dent.d_ino) {
		ip = pp;
		ip->i_count++;
	} else
		ip = iget(pp->i_dev, u.u_dent.d_ino);
	if(ip == NULL)
		goto out1;
	if((ip->i_mode&IFMT)==IFDIR && !suser())
		goto out;
	/*
	 * Don't unlink a mounted file.
	 */
	if (ip->i_dev != pp->i_dev) {
		u.u_error = EBUSY;
		goto out;
	}
	if (ip->i_flag&ITEXT)
		xrele(ip);	/* try once to free text */
	if (ip->i_flag&ITEXT && ip->i_nlink==1) {
		u.u_error = ETXTBSY;
		goto out;
	}
	u.u_offset -= sizeof(struct direct);
	u.u_base = (caddr_t)&u.u_dent;
	u.u_count = sizeof(struct direct);
	u.u_dent.d_ino = 0;
	writei(pp);
	ip->i_nlink--;
	ip->i_flag |= ICHG;

out:
	iput(ip);
out1:
	iput(pp);
}
/* KERNEL 4E84 */
chdir()
{
	chdirec(&u.u_cdir);
}

/* KERNEL 4E96 */
chroot()
{
	if (suser())
		chdirec(&u.u_rdir);
}

/* KERNEL 4EB0 */
chdirec(ipp)
register struct inode **ipp;
{
	register struct inode *ip;
	struct a {
		char	*fname;
	};

	ip = namei(uchar, 0);
	if(ip == NULL)
		return;
	if((ip->i_mode&IFMT) != IFDIR) {
		u.u_error = ENOTDIR;
		goto bad;
	}
	if(access(ip, IEXEC))
		goto bad;
	prele(ip);
	if (*ipp) {
		plock(*ipp);
		iput(*ipp);
	}
	*ipp = ip;
	return;

bad:
	iput(ip);
}

/* KERNEL 4F1C */
chmod()
{
	register struct inode *ip;
	register struct a {
		char	*fname;
		int	fmode;
	} *uap;

	uap = (struct a *)u.u_ap;
	if ((ip = owner()) == NULL)
		return;
	ip->i_mode &= ~07777;
	if (u.u_uid)
		uap->fmode &= ~ISVTX;
	ip->i_mode |= uap->fmode&07777;
	ip->i_flag |= ICHG;
	if (ip->i_flag&ITEXT && (ip->i_mode&ISVTX)==0)
		xrele(ip);
	iput(ip);
}

/* KERNEL 4F78 */
chown()
{
	register struct inode *ip;
	register struct a {
		char	*fname;
		int	uid;
		int	gid;
	} *uap;

	uap = (struct a *)u.u_ap;
	if (!suser() || (ip = owner()) == NULL)
		return;
	ip->i_uid = uap->uid;
	ip->i_gid = uap->gid;
	ip->i_flag |= ICHG;
	iput(ip);
}

/* KERNEL 4FB0 */
ssig()
{
	register a;
	struct a {
		int	signo;
		int	fun;
	} *uap;

	uap = (struct a *)u.u_ap;
	a = uap->signo;
	if(a<=0 || a>=NSIG || a==SIGKIL) {
		u.u_error = EINVAL;
		return;
	}
	u.u_r.r_val1 = u.u_signal[a];
	u.u_signal[a] = uap->fun;
	u.u_procp->p_sig &= ~(1<<(a-1));
}

/* KERNEL 501C */
kill()
{
	register struct proc *p, *q;
	register a;
	register struct a {
		int	pid;
		int	signo;
	} *uap;
	int f, priv;

	uap = (struct a *)u.u_ap;
	f = 0;
	a = uap->pid;
	priv = 0;
	if (a==-1 && u.u_uid==0) {
		priv++;
		a = 0;
	}
	q = u.u_procp;
	/* MUTOS: proctop instead of &proc[NPROC] (V7) */
	for(p = &proc[0]; p <= proctop; p++) {
		if(p->p_stat == NULL)
			continue;
		if(a != 0 && p->p_pid != a)
			continue;
		if(a==0 && ((p->p_pgrp!=q->p_pgrp&&priv==0) || p<=&proc[1]))
			continue;
		if(u.u_uid != 0 && u.u_uid != p->p_uid)
			continue;
		f++;
		psignal(p, uap->signo);
	}
	if(f == 0)
		u.u_error = ESRCH;
}

/* KERNEL 50B0 */
times()
{
	register struct a {
		time_t	(*times)[4];
	} *uap;

	uap = (struct a *)u.u_ap;
	if (copyout((caddr_t)&u.u_utime, (caddr_t)uap->times, sizeof(*uap->times)) < 0)
		u.u_error = EFAULT;
}

/* KERNEL 50D6 */
profil()
{
	register struct a {
		short	*bufbase;
		unsigned bufsize;
		unsigned pcoffset;
		unsigned pcscale;
	} *uap;

	uap = (struct a *)u.u_ap;
	u.u_prof.pr_base = uap->bufbase;
	u.u_prof.pr_size = uap->bufsize;
	u.u_prof.pr_off = uap->pcoffset;
	u.u_prof.pr_scale = uap->pcscale;
}

/*
 * alarm clock signal
 */
/* KERNEL 5100 */
alarm()
{
	register struct proc *p;
	register c;
	register struct a {
		int	deltat;
	} *uap;

	uap = (struct a *)u.u_ap;
	p = u.u_procp;
	c = p->p_clktim;
	p->p_clktim = uap->deltat;
	u.u_r.r_val1 = c;
}

/*
 * indefinite wait.
 * no one should wakeup(&u)
 */
/* KERNEL 511E */
pause()
{

	for(;;)
		sleep((caddr_t)&u, PSLEP);
}

/*
 * mode mask for creation of files
 */
/* KERNEL 5132 */
umask()
{
	register struct a {
		int	mask;
	} *uap;
	register t;

	uap = (struct a *)u.u_ap;
	t = u.u_cmask;
	u.u_cmask = uap->mask & 0777;
	u.u_r.r_val1 = t;
}

/*
 * Set IUPD and IACC times on file.
 * Can't set ICHG.
 */
/* KERNEL 5150 */
utime()
{
	register struct a {
		char	*fname;
		time_t	*tptr;
	} *uap;
	register struct inode *ip;
	time_t tv[2];

	uap = (struct a *)u.u_ap;
	if ((ip = owner()) == NULL)
		return;
	if (copyin((caddr_t)uap->tptr, (caddr_t)tv, sizeof(tv))) {
		u.u_error = EFAULT;
		return;
	}
	ip->i_flag |= IACC|IUPD|ICHG;
	iupdat(ip, &tv[0], &tv[1]);
	iput(ip);
}
