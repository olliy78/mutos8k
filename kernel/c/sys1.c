/* sys1.c -- process control (kernel mutos_1216, 41AC..4C14): exece, getxfile, setregs, rexit, exit, wait, fork, sbreak.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/sys1.c in the form of the TUHS collection Research/Torsten_Hippe_v7 (the closest known relative, assembled 1995 from unknown sources; "Hippe" names the
 *           collection, not the author), standard configuration of usr/sys/conf/m.h (PROC_MAX, EXIT, LRUI on; the other options off;
 *           tools/herkunft/ifdef_resolve.py).
 *           exece, rexit, exit (EXIT form: one loop, one wakeup(&proc[1])), wait and fork (MAX_PROC, max_proc) carry the text of the collection;
 *           getxfile, setregs and sbreak are the collection's functions rewritten for the Z8001.  exec (4198) is in sys3.c.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 64% V7 / 49% System III PDP-11 (before the
 *           restoration); exece 63%, getxfile 55%, setregs 61%, rexit 46%, exit 80%, wait 83%, fork 78%, sbreak 23% against V7.
 *           V7 text cannot be put in unchanged: the executable header, the argument frame, the process image layout and
 *           exit/wait differ (Z8001); every deviating line carries a "MUTOS:" comment, V7 comments are kept.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/sys1.md.
 * Deviations: Z8000 executable headers (magic E807 plain, E707 large, 16 or 40 bytes, held in u.u_ex[]), no overlays and no separate-I/D support,
 *           the argument frame at the top of the 64 KB data segment (u_ar0[8] instead of R6), fork sizes the swap space from the actual image,
 *           no accounting, sbreak only clears; exece is not byte-identical (1 of 389 words, c2 pattern), getxfile not (177 of 401, Z8001 header
 *           handling); see doc/herkunft/sys1.md.
 *
 * The argument frame is at the upper end of the process 64 KB segment (ucp = -nc - 2).  Magic E807 = non-segmented header
 * (16 bytes), E707 = large header (40 bytes, bit 8 set); u_ex[] is the header read in (V7: u.u_exdata).  The argument strings
 * go through 10 swap blocks (malloc(swapmap, 10)).
 * User space accessors: fubyte = 04CC (byte), fuword = 04DA (word), subyte = 0508, suword = 0514 (map K6b had them swapped).
 * Data: regloc 88CC..88D4 (8 bytes: register indexes, setregs), text 8C58 "Out of swap" (exece), no line end.
 * The names 4AD4 fork and 4BD0 sbreak are the V7 names; the markers carry the kernel address. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "text.h"
#include "map.h"
#include "inode.h"
#include "file.h"
#include "buf.h"
#include "reg.h"

#define btoc(x)		((unsigned)((x)+255)>>8)
#define ctod2(x)	(((unsigned)(x)+1)>>1)

extern char regloc[8];

/* struct xproc: V7 text, in proc.h (xp_xstat +10h, xp_utime +12h, xp_stime +16h) */

/*
 * exec system call, with and without environments.
 * MUTOS: exec itself is in sys3.c (kernel address order); the struct is declared there as well.
 */
struct execa {
	char	*fname;
	char	**argp;
	char	**envp;
};

/* KERNEL 41AC */
exece()
{
	register nc;
	register char *cp;
	register struct buf *bp;
	register struct execa *uap;
	int na, ne, ns, bno, ucp, ap, c;
	struct inode *ip;

	if ((ip = namei(uchar, 0)) == NULL)
		return;
	if(access(ip,IEXEC)
	 || ((ip->i_mode&IFMT) != IFREG)
	 || ((ip->i_mode&(IEXEC|(IEXEC>>3)|(IEXEC>>6))) == 0)) {
		u.u_error = EACCES;
		iput(ip);
		return;
	}
	bno = 0;
	bp = 0;
	/*
	 * Collect arguments on "file" in swap space.
	 */
	na = 0;
	ne = 0;
	nc = 0;
	uap = (struct execa *)u.u_ap;
	if ((bno = malloc(swapmap,(NCARGS+BSIZE-1)/BSIZE)) == 0)
		panic("Out of swap");
	if (uap->argp) for (;;) {
		ap = NULL;
		if (uap->argp) {
			ap = fuword((caddr_t)uap->argp);
			uap->argp++;
		}
		if (ap==NULL && uap->envp) {
			uap->argp = NULL;
			if ((ap = fuword((caddr_t)uap->envp)) == NULL)
				break;
			uap->envp++;
			ne++;
		}
		if (ap==NULL)
			break;
		na++;
		if(ap == -1)
			u.u_error = EFAULT;
		do {
			if (nc >= NCARGS-1)
				u.u_error = E2BIG;
			if ((c = fubyte((caddr_t)ap++)) < 0)
				u.u_error = EFAULT;
			if (u.u_error)
				goto bad;
			if ((nc&BMASK) == 0) {
				if (bp)
					bdwrite(bp);
				bp = getblk(swapdev, swplo+bno+(nc>>BSHIFT));
				cp = bp->b_un.b_addr;
			}
			nc++;
			*cp++ = c;
		} while (c>0);
	}
	if (bp)
		bdwrite(bp);
	bp = 0;
	nc = (nc + NBPW-1) & ~(NBPW-1);
	ns = (na + 3) * NBPW;
	if (getxfile(ip, nc, ns) || u.u_error)
		goto bad;

	/*
	 * copy back arglist
	 */

	ucp = -nc - NBPW;
	ap = ucp - ns;
	u.u_ar0[8] = ap;	/* MUTOS (Z8001): stack pointer of the frame (V7 R6) */
	suword((caddr_t)ap, na-ne);
	nc = 0;
	for (;;) {
		ap += NBPW;
		if (na==ne) {
			suword((caddr_t)ap, 0);
			ap += NBPW;
		}
		if (--na < 0)
			break;
		suword((caddr_t)ap, ucp);
		do {
			if ((nc&BMASK) == 0) {
				if (bp)
					brelse(bp);
				bp = bread(swapdev, swplo+bno+(nc>>BSHIFT));
				bp->b_flags |= B_AGE;
				bp->b_flags &= ~B_DELWRI;
				cp = bp->b_un.b_addr;
			}
			subyte((caddr_t)ucp++, (c = *cp++));
			nc++;
		} while(c&0377);
	}
	suword((caddr_t)ap, 0);
	suword((caddr_t)ucp, 0);
	setregs();
bad:
	if (bp)
		brelse(bp);
	if(u.u_error) {
		for(nc=0;nc < ((NCARGS+BSIZE-1)/BSIZE);nc++) {
			bp = getblk(swapdev,swplo+bno+nc);
			bp->b_flags |= B_AGE;
			bp->b_flags &= ~B_DELWRI;
			brelse(bp);
		}
	}
	mfree(swapmap, (NCARGS+BSIZE-1)/BSIZE, bno);
	iput(ip);
}

/*
 * Read in and set up memory for executed file.
 * Zero return is normal;
 * non-zero means only the text is being replaced
 * MUTOS: second argument ns = size of the argument pointer array in bytes (V7 has only nargc).
 */
/* KERNEL 44B6 */
getxfile(ip, nargc, ns)
register struct inode *ip;
{
	register unsigned ds;
	register sep;
	register unsigned ts, ss;
	register i;
	int overlay;
	long lsize;

	/*
	 * read in first few bytes
	 * of file for segment
	 * sizes:
	 * MUTOS: magic word E807 (header of 16 bytes) or E707 (large header of 40 bytes, bit 8 set);
	 * V7: ux_mag = 407/410/411/405
	 */

	u.u_base = (caddr_t)&u.u_ex[0];	/* V7: &u.u_exdata */
	u.u_count = 2;	/* MUTOS: first only the magic word, then the header of that size */
	u.u_offset = 0;
	u.u_segflg = 1;
	readi(ip);
	if (u.u_error)
		goto bad;
	if (u.u_ex[0] & 0x100)
		u.u_count = 0x28;
	else
		u.u_count = 0x10;
	u.u_offset = 0;
	u.u_segflg = 1;
	u.u_base = (caddr_t)&u.u_ex[0];
	readi(ip);
	u.u_segflg = 0;
	if (u.u_error)
		goto bad;
	if (u.u_count) {
		u.u_error = ENOEXEC;
		goto bad;
	}
	sep = 0;
	overlay = 0;
	/* MUTOS: only the plain (407-like) formats; sep stays 0 and overlay stays 0 (V7 also knows 410, 411, 405) */
	if (u.u_ex[0] == (int)0xE807) {
		lsize = (long)(unsigned)u.u_ex[2] + (unsigned)u.u_ex[1];
		u.u_ex[2] = lsize;
		if (lsize != (unsigned)u.u_ex[2]) {	/* check overflow */
			u.u_error = ENOMEM;
			goto bad;
		}
		u.u_ex[1] = 0;
	} else if (u.u_ex[0] == (int)0xE707) {
		lsize = (long)(unsigned)u.u_ex[15] + (unsigned)u.u_ex[14];
		u.u_ex[15] = lsize;
		if (lsize != (unsigned)u.u_ex[15]) {
			u.u_error = ENOMEM;
			goto bad;
		}
		u.u_ex[14] = 0;
	} else {
		u.u_error = ENOEXEC;
		goto bad;
	}
	if (u.u_ex[0] & 0x100) {
		if (u.u_ex[14] && (ip->i_flag & ITEXT) == 0 && ip->i_count != 1) {
			u.u_error = ETXTBSY;
			goto bad;
		}
	} else {
		if (u.u_ex[1] && (ip->i_flag & ITEXT) == 0 && ip->i_count != 1) {
			u.u_error = ETXTBSY;
			goto bad;
		}
	}
	/*
	 * find text and data sizes
	 * try them out for possible
	 * overflow of max sizes
	 */
	if (u.u_ex[0] & 0x100) {
		ts = btoc(u.u_ex[14]);
		lsize = (long)(unsigned)u.u_ex[15] + (unsigned)u.u_ex[16];
	} else {
		ts = btoc(u.u_ex[1]);
		lsize = (long)(unsigned)u.u_ex[2] + (unsigned)u.u_ex[3];
	}
	if (lsize != (unsigned)lsize) {
		u.u_error = ENOMEM;
		goto bad;
	}
	ds = btoc((unsigned)lsize);
	ss = btoc(nargc + ns) + 5;	/* MUTOS: V7 SSIZE + btoc(nargc), SSIZE is 5 */
	if (overlay) {
		if ((u.u_sep == 0 && btoc(ts) != btoc(u.u_tsize)) || nargc) {
			u.u_error = ENOMEM;
			goto bad;
		}
		ds = u.u_dsize;
		ss = u.u_ssize;
		sep = u.u_sep;
		xfree();
		xalloc(ip);
		if (u.u_ex[0] & 0x100)
			u.u_ar0[12] = u.u_ex[8] & ~1;
		else
			u.u_ar0[12] = u.u_ex[5] & ~1;
	} else {
		/* MUTOS: V7 "goto bad" returns overlay (0); here the return value is 1 */
		if (estabur(ts, ds, ss, sep, 2))
			return(1);

		/*
		 * allocate and clear core
		 * at this point, committed
		 * to the new image
		 */

		u.u_prof.pr_scale = 0;
		xfree();
		/* MUTOS: no expand(); the whole 256-click segment of the process is cleared (V7: i = USIZE+ds+ss; expand(i)) */
		for (i = 0x100; --i >= 0; )
			clearseg(u.u_procp->p_addr + i);
		xalloc(ip);

		/*
		 * read in data segment
		 */

		estabur(0, ds, 0, 0, 2);
		u.u_base = 0;
		if (u.u_ex[0] & 0x100) {
			u.u_offset = (unsigned)u.u_ex[14] + 0x28;
			u.u_count = u.u_ex[15];
		} else {
			u.u_offset = (unsigned)u.u_ex[1] + 16;
			u.u_count = u.u_ex[2];
		}
		readi(ip);
		/*
		 * set SUID/SGID protections, if no tracing
		 */
		if (u.u_procp->p_flag & STRC)
			psignal(u.u_procp, SIGTRC);
		else {
			if (ip->i_mode & ISUID)
				if (u.u_uid != 0) {
					u.u_uid = ip->i_uid;
					u.u_procp->p_uid = ip->i_uid;
				}
			if (ip->i_mode & ISGID)
				u.u_gid = ip->i_gid;
		}
	}
	u.u_tsize = ts;
	u.u_dsize = ds;
	u.u_ssize = ss;
	u.u_sep = sep;
	estabur(ts, ds, ss, sep, 2);
bad:
	return(overlay);
}

/*
 * Clear registers on exec
 */
/* KERNEL 47E2 */
setregs()
{
	register int *rp;
	register char *cp;
	register i;

	for (rp = &u.u_signal[0]; rp < &u.u_signal[NSIG]; rp++)
		if ((*rp & 1) == 0)
			*rp = 0;
	for (cp = &regloc[0]; cp < &regloc[8]; )	/* MUTOS: 8 entries (V7: 6) */
		u.u_ar0[*cp++] = 0;
	u.u_r.r_val1 = 0;	/* MUTOS: not in V7 */
	u.u_r.r_val2 = 0;
	if (u.u_ex[0] & 0x100)
		u.u_ar0[12] = u.u_ex[8] & ~1;
	else
		u.u_ar0[12] = u.u_ex[5] & ~1;
	for (rp = (int *)u.u_fparea; rp < (int *)&u.u_fparea[0x90]; )	/* MUTOS: V7 clears u_fps up to u_fpregs[6] */
		*rp++ = 0;
	for (i = 0; i < NOFILE; i++) {
		if (u.u_pofile[i]&EXCLOSE) {
			closef(u.u_ofile[i]);
			u.u_ofile[i] = NULL;
			u.u_pofile[i] &= ~EXCLOSE;
		}
	}
	/*
	 * Remember file name for accounting.
	 * MUTOS: no accounting; the name goes from u_exname to u_dbuf (V7: bcopy(u_dbuf, u_comm))
	 */
	bcopy((caddr_t)u.u_exname, (caddr_t)u.u_dbuf, DIRSIZ);
}

/*
 * exit system call:
 * pass back caller's arg
 */
/* KERNEL 48A6 */
rexit()
{
	register struct a {
		int	rval;
	} *uap;

	uap = (struct a *)u.u_ap;
	exit((uap->rval & 0377) << 8);
}

/*
 * Release resources.
 * Save u. area for parent to look at.
 * Enter zombie state.
 * Wake up parent and init processes,
 * and dispose of children.
 */
/* KERNEL 48C4 */
exit(rv)
{
	register i;
	register struct proc *p, *q;
	register struct file *f;

	p = u.u_procp;
	p->p_flag &= ~(STRC|SULOCK);
	p->p_clktim = 0;
	for (i = 0; i < NSIG; i++)
		u.u_signal[i] = 1;
	for (i = 0; i < NOFILE; i++) {
		f = u.u_ofile[i];
		u.u_ofile[i] = NULL;
		closef(f);
	}
	plock(u.u_cdir);
	iput(u.u_cdir);
	if (u.u_rdir) {
		plock(u.u_rdir);
		iput(u.u_rdir);
	}
	xfree();
	mfree(coremap, p->p_size, p->p_addr);
	p->p_stat = SZOMB;
	((struct xproc *)p)->xp_xstat = rv;
	((struct xproc *)p)->xp_utime = u.u_cutime + u.u_utime;
	((struct xproc *)p)->xp_stime = u.u_cstime + u.u_stime;
	for(i = 0, q = &proc[0]; q <= MAX_PROC; q++){
		if(q->p_ppid == p->p_pid){
			q->p_ppid = 1;
			if(q->p_stat == SZOMB)
				i++;
			else if(q->p_stat == SSTOP)
				setrun(q);
		}
		else if(q->p_pid == p->p_ppid){
			wakeup(q);
		}
	}
	if(i)
		wakeup(&proc[1]);
	swtch();
}

/*
 * Wait system call.
 * Search for a terminated (zombie) child,
 * finally lay it to rest, and collect its status.
 * Look also for stopped (traced) children,
 * and pass back status from them.
 */
/* KERNEL 49F6 */
wait()
{
	register f;
	register struct proc *p;

	f = 0;
loop:
	for (p = &proc[0]; p <= max_proc; p++)
		if (u.u_procp->p_pid == p->p_ppid) {
			f++;
			if (p->p_stat == SZOMB) {
				u.u_r.r_val1 = p->p_pid;
				u.u_r.r_val2 = ((struct xproc *)p)->xp_xstat;
				u.u_cutime += ((struct xproc *)p)->xp_utime;
				u.u_cstime += ((struct xproc *)p)->xp_stime;
				p->p_pid = 0;
				p->p_ppid = 0;
				p->p_pgrp = 0;
				p->p_sig = 0;
				p->p_flag = 0;
				p->p_wchan = 0;
				p->p_stat = NULL;
				if(p == max_proc){
					while((--max_proc)->p_stat == NULL)
						;
				}
				return;
			}
			if (p->p_stat == SSTOP) {
				if ((p->p_flag & SWTED) == 0) {
					p->p_flag |= SWTED;
					u.u_r.r_val1 = p->p_pid;
					u.u_r.r_val2 = (fsig(p) << 8) | 0177;
					return;
				}
				continue;
			}
		}
	if (f) {
		sleep((caddr_t)u.u_procp, PWAIT);
		goto loop;
	}
	u.u_error = ECHILD;
}

/*
 * fork system call.
 */
/* KERNEL 4AD4 */
fork()
{
	register struct proc *p1, *p2;
	register a, size;

	/*
	 * Make sure there's enough swap space for max
	 * core image, thus reducing chances of running out
	 * MUTOS: the size of the actual image (data part, the user area, the used stack) instead of ctod(MAXMEM)
	 */
	size = ctod2(u.u_dsize) + 2;
	size += ctod2(0x100 - ((unsigned)u.u_ar0[8] >> 8));
	a = malloc(swapmap, size);
	if (a == 0) {
		u.u_error = ENOMEM;
		goto out;
	}
	mfree(swapmap, size, a);
	a = 0;
	p2 = NULL;
	for (p1 = &proc[0]; p1 < &proc[NPROC]; p1++) {
		if (p1->p_stat == NULL && p2 == NULL)
			p2 = p1;
		else {
			if (p1->p_uid == u.u_uid && p1->p_stat != NULL)
				a++;
		}
	}
	/*
	 * Disallow if
	 *  No processes at all;
	 *  not su and too many procs owned; or
	 *  not su and would take last slot.
	 */
	if (p2 == NULL || (u.u_uid != 0 && (p2 == &proc[NPROC-1] || a > MAXUPRC))) {
		u.u_error = EAGAIN;
		goto out;
	}
	if(p2 > max_proc)
		max_proc = p2;
	p1 = u.u_procp;
	if (newproc()) {
		u.u_r.r_val1 = p1->p_pid;
		u.u_start = time;
		u.u_cstime = 0;
		u.u_stime = 0;
		u.u_cutime = 0;
		u.u_utime = 0;
		/* MUTOS: no u_acflag = AFORK */
		return;
	}
	u.u_r.r_val1 = p2->p_pid;
out:
	u.u_ar0[12] += NBPW;	/* MUTOS (Z8001): V7 u_ar0[R7]; the PC is word 12 of the Z8001 frame */
}

/*
 * break system call.
 *  -- bad planning: "break" is a dirty word in C.
 * MUTOS: the data segment is not moved or checked (no estabur, no expand, no stack copy): only the new size is
 * entered and the added clicks are cleared.
 */
/* KERNEL 4BD0 */
sbreak()
{
	register a, n, d;
	int x;

	n = btoc(*u.u_ap);
	d = n - u.u_dsize;
	if (d > 0) {
		a = u.u_procp->p_addr + n;
		while (d--)
			clearseg(--a);
	}
	u.u_dsize = n;
}
