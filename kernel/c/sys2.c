/* sys2.c -- file system calls (kernel mutos_1216, 51B2..562C): read, write, rdwr, open, creat, open1, close,
 * seek, link, mknod, saccess.  saccess sits directly before xswap (55AE) in the kernel but belongs to sys2.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/sys2.c in the form of the TUHS collection Research/Torsten_Hippe_v7 (the closest known relative,
 *           assembled 1995 from unknown sources; "Hippe" names the collection, not the author), standard configuration of
 *           usr/sys/conf/m.h: all 11 functions with names, comments and text of the collection (open1, seek with off < 0 ->
 *           EINVAL and off = 0; doc/herkunft/fremd.md 4.1 no. 2).  System III PDP-11 uts/os/sys2.c differs (copen(mode, arg),
 *           FIFOs, f_offset).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 89% V7 / 68% System III PDP-11 (before the
 *           restoration), 11 of 11 functions above 50% against V7.  open1 has the signature and calls of the Hippe/V7 text.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/sys2.md.
 * Deviations: none in the text (the 11 functions equal the collection up to white space, measured with diff -w against the
 *           switch-resolved tree); the KERNEL address markers and the include list are MUTOS.  Before 2026-11-03 open1 was
 *           called copen (kernel_namen.md).
 *
 * Data: f_flag bits FREAD 1, FWRITE 2, FPIPE 4, FMP 030 (no offset: device); rdwr calls readp/writep for FPIPE files
 * (K6b called them openp/closep; they call readi/writei). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "inode.h"
#include "file.h"
#include "reg.h"

/*
 * read system call
 */
/* KERNEL 51B2 */
read()
{
	rdwr(FREAD);
}

/*
 * write system call
 */
/* KERNEL 51C4 */
write()
{
	rdwr(FWRITE);
}

/*
 * common code for read and write calls:
 * check permissions, set base, count, and offset,
 * and switch out to readi, writei, or pipe code.
 */
/* KERNEL 51D6 */
rdwr(mode)
register mode;
{
	register struct file *fp;
	register struct inode *ip;
	register struct a {
		int	fdes;
		char	*cbuf;
		unsigned count;
	} *uap;

	uap = (struct a *)u.u_ap;
	fp = getf(uap->fdes);
	if(fp == NULL)
		return;
	if((fp->f_flag&mode) == 0) {
		u.u_error = EBADF;
		return;
	}
	u.u_base = (caddr_t)uap->cbuf;
	u.u_count = uap->count;
	u.u_segflg = 0;
	if((fp->f_flag&FPIPE) != 0) {
		if(mode == FREAD)
			readp(fp);
		else
			writep(fp);
	} else {
		ip = fp->f_inode;
		if (fp->f_flag&FMP)
			u.u_offset = 0;
		else
			u.u_offset = fp->f_un.f_offset;
		if((ip->i_mode&(IFCHR&IFBLK)) == 0)
			plock(ip);
		if(mode == FREAD)
			readi(ip);
		else
			writei(ip);
		if((ip->i_mode&(IFCHR&IFBLK)) == 0)
			prele(ip);
		if ((fp->f_flag&FMP) == 0)
			fp->f_un.f_offset += uap->count-u.u_count;
	}
	u.u_r.r_val1 = uap->count-u.u_count;
}

/*
 * open system call
 */
/* KERNEL 52BE */
open()
{
	register struct inode *ip;
	register struct a {
		char	*fname;
		int	rwmode;
	} *uap;

	uap = (struct a *)u.u_ap;
	ip = namei(uchar, 0);
	if(ip == NULL)
		return;
	open1(ip, ++uap->rwmode, 0);
}

/*
 * creat system call
 */
/* KERNEL 52F2 */
creat()
{
	register struct inode *ip;
	register struct a {
		char	*fname;
		int	fmode;
	} *uap;

	uap = (struct a *)u.u_ap;
	ip = namei(uchar, 1);
	if(ip == NULL) {
		if(u.u_error)
			return;
		ip = maknode(uap->fmode&07777&(~ISVTX));
		if (ip==NULL)
			return;
		open1(ip, FWRITE, 2);
	} else
		open1(ip, FWRITE, 1);
}

/*
 * common code for open and creat (V7 name: open1).
 * Check permissions, allocate an open file structure,
 * and call the device open routine if any.
 */
/* KERNEL 5344 */
open1(ip, mode, trf)
register struct inode *ip;
register mode;
{
	register struct file *fp;
	int i;

	if(trf != 2) {
		if(mode&FREAD)
			access(ip, IREAD);
		if(mode&FWRITE) {
			access(ip, IWRITE);
			if((ip->i_mode&IFMT) == IFDIR)
				u.u_error = EISDIR;
		}
	}
	if(u.u_error)
		goto out;
	if(trf == 1)
		itrunc(ip);
	prele(ip);
	if ((fp = falloc()) == NULL)
		goto out;
	fp->f_flag = mode&(FREAD|FWRITE);
	fp->f_inode = ip;
	i = u.u_r.r_val1;
	openi(ip, mode&FWRITE);
	if(u.u_error == 0)
		return;
	u.u_ofile[i] = NULL;
	fp->f_count--;

out:
	iput(ip);
}

/*
 * close system call
 */
/* KERNEL 53FE */
close()
{
	register struct file *fp;
	register struct a {
		int	fdes;
	} *uap;

	uap = (struct a *)u.u_ap;
	fp = getf(uap->fdes);
	if(fp == NULL)
		return;
	u.u_ofile[uap->fdes] = NULL;
	closef(fp);
}

/*
 * seek system call
 */
/* KERNEL 542C */
seek()
{
	register struct file *fp;
	register struct a {
		int	fdes;
		off_t	off;
		int	sbase;
	} *uap;

	uap = (struct a *)u.u_ap;
	fp = getf(uap->fdes);
	if(fp == NULL)
		return;
	if(fp->f_flag&(FPIPE|FMP)) {
		u.u_error = ESPIPE;
		return;
	}
	if(uap->sbase == 1)
		uap->off += fp->f_un.f_offset;
	else if(uap->sbase == 2)
		uap->off += fp->f_inode->i_size;
	if(uap->off < 0) {
		u.u_error = EINVAL;
		uap->off = 0;
	}
	fp->f_un.f_offset = uap->off;
	u.u_r.r_off = uap->off;
}

/*
 * link system call
 */
/* KERNEL 54AA */
link()
{
	register struct inode *ip, *xp;
	register struct a {
		char	*target;
		char	*linkname;
	} *uap;

	uap = (struct a *)u.u_ap;
	ip = namei(uchar, 0);
	if(ip == NULL)
		return;
	if((ip->i_mode&IFMT)==IFDIR && !suser())
		goto out;
	/*
	 * Unlock to avoid possibly hanging the namei.
	 * Sadly, this means races. (Suppose someone
	 * deletes the file in the meantime?)
	 * Nor can it be locked again later
	 * because then there will be deadly
	 * embraces.
	 */
	prele(ip);
	u.u_dirp = (caddr_t)uap->linkname;
	xp = namei(uchar, 1);
	if(xp != NULL) {
		u.u_error = EEXIST;
		iput(xp);
		goto out;
	}
	if (u.u_error)
		goto out;
	if(u.u_pdir->i_dev != ip->i_dev) {
		iput(u.u_pdir);
		u.u_error = EXDEV;
		goto out;
	}
	wdir(ip);
	if (u.u_error==0) {
		ip->i_nlink++;
		ip->i_flag |= ICHG;
	}

out:
	iput(ip);
}

/*
 * mknod system call
 */
/* KERNEL 5556 */
mknod()
{
	register struct inode *ip;
	register struct a {
		char	*fname;
		int	fmode;
		int	dev;
	} *uap;

	uap = (struct a *)u.u_ap;
	if(suser()) {
		ip = namei(uchar, 1);
		if(ip != NULL) {
			u.u_error = EEXIST;
			goto out;
		}
	}
	if(u.u_error)
		return;
	ip = maknode(uap->fmode);
	if (ip == NULL)
		return;
	ip->i_un.i_rdev = (dev_t)uap->dev;

out:
	iput(ip);
}

/*
 * access system call
 */
/* KERNEL 55AE */
saccess()
{
	register svuid, svgid;
	register struct inode *ip;
	register struct a {
		char	*fname;
		int	fmode;
	} *uap;

	uap = (struct a *)u.u_ap;
	svuid = u.u_uid;
	svgid = u.u_gid;
	u.u_uid = u.u_ruid;
	u.u_gid = u.u_rgid;
	ip = namei(uchar, 0);
	if (ip != NULL) {
		if (uap->fmode&(IREAD>>6))
			access(ip, IREAD);
		if (uap->fmode&(IWRITE>>6))
			access(ip, IWRITE);
		if (uap->fmode&(IEXEC>>6))
			access(ip, IEXEC);
		iput(ip);
	}
	u.u_uid = svuid;
	u.u_gid = svgid;
}
