/* sig.c -- signals and process tracing (kernel mutos_1216, 0B3A..1122): signal, psignal, issig, stop, psig, fsig,
 * core, grow, ptrace, procxmt.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/sig.c (all 10 functions; grow() is an empty stub here, core() and procxmt() are
 *           adapted to the Z8001 memory model).  System III pdp11 uts/os/sig.c is less similar.
 *           Closest known relative: TUHS collection Research/Torsten_Hippe_v7 (assembled 1995 from unknown sources; not the
 *           author) - matches proctop (PROC_MAX) in signal / stop / ptrace (fremd.md 4.1 no. 9).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs).  H2, before the restoration: module 82% against V7 (10 of 10
 *           functions >= 50%), 73% against System III PDP-11 (issig, fsig, psignal 100% against V7).  After it:
 *           file 82% V7 / 70% System III.  Same string ("core").
 * Roundtrip: cc -O in the guest, per function against mutos_1216: 10 of 10 byte-identical.  Details: doc/herkunft/sig.md
 * Deviations: proctop instead of &proc[NPROC]; ip_addr is an int (16-bit user addresses); arguments of ptrace in
 *           another order; core() writes the u area and the data+stack segment of the Z8001 layout; procxmt without
 *           the separate I/D requests and with the Z8001 register map; grow() empty; see doc/herkunft/sig.md.
 *
 * NSIG 17: signal n in 1..16 (bit n-1 in the word p_sig), u_signal[17] at u+D2.  core() is at 0D56 in the kernel (behind
 * fsig).  Data: ipc (V7 struct ipc) = A620: ip_lock A620, ip_req A622, ip_addr A624, ip_data A626; text 8A10 "core".
 * Earlier notes (K6b) called 0F12 `core` -- it is procxmt (counterpart of ptrace); core itself is 0D56.
 * Assembler: savfp (03F8) / restfp (03FE) are in mch.s. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "text.h"
#include "inode.h"
#include "reg.h"

/*
 * Priority for tracing
 */
#define	IPCPRI	PZERO

extern char regloc[];

/*
 * Tracing variables.
 * Used to pass trace command from
 * parent to child being traced.
 * This data base cannot be
 * shared and is locked
 * per user.
 */
struct ipc {
	int	ip_lock;
	int	ip_req;
	int	ip_addr;	/* MUTOS: int (V7: int *), user addresses are 16 bit */
	int	ip_data;
} ipc;

/*
 * Send the specified signal to
 * all processes with 'pgrp' as
 * process group.
 * Called by tty.c for quits and
 * interrupts.
 */
/* KERNEL 0B3A */
signal(pgrp, sig)
register pgrp;
{
	register struct proc *p;

	if(pgrp == 0)
		return;
	for(p = &proc[0]; p <= proctop; p++)	/* MUTOS: proctop (V7: p < &proc[NPROC]) */
		if(p->p_pgrp == pgrp)
			psignal(p, sig);
}

/*
 * Send the specified signal to
 * the specified process.
 */
/* KERNEL 0B6E */
psignal(p, sig)
register struct proc *p;
register sig;
{

	if((unsigned)sig >= NSIG)
		return;
	if(sig)
		p->p_sig |= 1<<(sig-1);
	if(p->p_pri > PUSER)
		p->p_pri = PUSER;
	if(p->p_stat == SSLEEP && p->p_pri > PZERO)
		setrun(p);
}

/*
 * Returns true if the current
 * process has a signal to process.
 * This is asked at least once
 * each time a process enters the
 * system.
 * A signal does not do anything
 * directly to a process; it sets
 * a flag that asks the process to
 * do something to itself.
 */
/* KERNEL 0BC8 */
issig()
{
	register n;
	register struct proc *p;

	p = u.u_procp;
	while(p->p_sig) {
		n = fsig(p);
		if((u.u_signal[n]&1) == 0 || (p->p_flag&STRC))
			return(n);
		p->p_sig &= ~(1<<(n-1));
	}
	return(0);
}

/*
 * Enter the tracing STOP state.
 * In this state, the parent is
 * informed and the process is able to
 * receive commands from the parent.
 */
/* KERNEL 0C18 */
stop()
{
	register struct proc *pp, *cp;

loop:
	cp = u.u_procp;
	if(cp->p_ppid != 1)
	for (pp = &proc[0]; pp <= proctop; pp++)	/* MUTOS: proctop */
		if (pp->p_pid == cp->p_ppid) {
			wakeup((caddr_t)pp);
			cp->p_stat = SSTOP;
			swtch();
			if ((cp->p_flag&STRC)==0 || procxmt())
				return;
			goto loop;
		}
	exit(fsig(u.u_procp));
}

/*
 * Perform the action specified by
 * the current signal.
 * The usual sequence is:
 *	if(issig())
 *		psig();
 */
/* KERNEL 0C7C */
psig()
{
	register n, p;
	register struct proc *rp;

	rp = u.u_procp;
	if (u.u_fpsaved==0) {
		savfp(u.u_fparea);	/* MUTOS: V7 savfp(&u.u_fps) */
		u.u_fpsaved = 1;
	}
	if (rp->p_flag&STRC)
		stop();
	n = fsig(rp);
	if (n==0)
		return;
	rp->p_sig &= ~(1<<(n-1));
	if((p=u.u_signal[n]) != 0) {
		u.u_error = 0;
		if(n != SIGINS && n != SIGTRC)
			u.u_signal[n] = 0;
		sendsig((caddr_t)p, n);
		return;
	}
	switch(n) {

	case SIGQUIT:
	case SIGINS:
	case SIGTRC:
	case SIGIOT:
	case SIGEMT:
	case SIGFPT:
	case SIGBUS:
	case SIGSEG:
	case SIGSYS:
		if(core())
			n += 0200;
	}
	exit(n);
}

/*
 * find the signal in bit-position
 * representation in p_sig.
 */
/* KERNEL 0D2C */
fsig(p)
struct proc *p;
{
	register n, i;

	n = p->p_sig;
	for(i=1; i<NSIG; i++) {
		if(n & 1)
			return(i);
		n >>= 1;
	}
	return(0);
}

/*
 * Create a core image on the file "core"
 * If you are looking for protection glitches,
 * there are probably a wealth of them here
 * when this occurs to a suid command.
 *
 * It writes USIZE block of the
 * user.h area followed by the entire
 * data+stack segments.
 */
/* KERNEL 0D56 */
core()
{
	register struct inode *ip;
	register s;	/* MUTOS: int (V7: unsigned) */
	/* MUTOS: no schar(); namei() is given uchar() (pipe.c), V7: "extern schar();" */

	u.u_error = 0;
	u.u_dirp = "core";
	ip = namei(uchar, 1);
	if(ip == NULL) {
		if(u.u_error)
			return(0);
		ip = maknode(0666);
		if (ip==NULL)
			return(0);
	}
	if(!access(ip, IWRITE) &&
	   (ip->i_mode&IFMT) == IFREG &&
	   u.u_uid == u.u_ruid) {
		itrunc(ip);
		u.u_offset = 0;
		u.u_base = (caddr_t)&u;
		u.u_count = 0x400;	/* MUTOS: ctob(USIZE) of V7 = the 0x400 byte u area */
		u.u_segflg = 1;
		writei(ip);
		/* MUTOS (Z8001): data size from u_dsize, stack segment from the saved SP (u_ar0[8]); V7 computes
		 * s = u.u_procp->p_size - USIZE and calls estabur((unsigned)0, s, (unsigned)0, 0, RO) */
		u.u_base = 0;
		u.u_count = u.u_dsize << 8;
		u.u_segflg = 0;
		writei(ip);
		s = u.u_ar0[8] & 0xFF00;
		u.u_base = (caddr_t)s;
		u.u_count = 0 - s;
		writei(ip);
	}
	iput(ip);
	return(u.u_error==0);
}

/*
 * grow the stack to include the SP
 * true return if successful.
 */
/* KERNEL 0E38 */
grow()
{
	register i;
	/* MUTOS: the Z8001 kernel does not grow the stack segment; V7 body (grow(sp), estabur, expand, copyseg,
	 * clearseg) is absent, the function only returns 0 */

	return(0);
}

/*
 * sys-trace system call.
 */
/* KERNEL 0E42 */
ptrace()
{
	register struct proc *p;
	register struct a {
		int	req;	/* MUTOS: order req,pid,addr,data (V7: data,pid,addr,req) */
		int	pid;
		int	addr;	/* MUTOS: int (V7: int *) */
		int	data;
	} *uap;

	uap = (struct a *)u.u_ap;
	if (uap->req <= 0) {
		u.u_procp->p_flag |= STRC;
		return;
	}
	for (p=proc; p <= proctop; p++)	/* MUTOS: proctop (V7: p < &proc[NPROC]) */
		if (p->p_stat==SSTOP
		 && p->p_pid==uap->pid
		 && p->p_ppid==u.u_procp->p_pid)
			goto found;
	u.u_error = ESRCH;
	return;

    found:
	while (ipc.ip_lock)
		sleep((caddr_t)&ipc, IPCPRI);
	ipc.ip_lock = p->p_pid;
	ipc.ip_data = uap->data;
	ipc.ip_addr = uap->addr;
	ipc.ip_req = uap->req;
	p->p_flag &= ~SWTED;
	setrun(p);
	while (ipc.ip_req > 0)
		sleep((caddr_t)&ipc, IPCPRI);
	u.u_r.r_val1 = ipc.ip_data;
	if (ipc.ip_req < 0)
		u.u_error = EIO;
	ipc.ip_lock = 0;
	wakeup((caddr_t)&ipc);
}

/*
 * Code that the child process
 * executes to implement the command
 * of the parent process in tracing.
 */
/* KERNEL 0F12 */
procxmt()
{
	register int i;
	register *p;
	register struct text *xp;

	if (ipc.ip_lock != u.u_procp->p_pid)
		return(0);
	i = ipc.ip_req;
	ipc.ip_req = 0;
	wakeup((caddr_t)&ipc);
	switch (i) {

	/* read user I */
	/* MUTOS: no separate I and D space; requests 1 and 2 are the same (V7: fuibyte/fuiword for 1) */
	case 1:
	/* read user D */
	case 2:
		if (fubyte((caddr_t)ipc.ip_addr) == -1)
			goto error;
		ipc.ip_data = fuword((caddr_t)ipc.ip_addr);
		break;

	/* read u */
	case 3:
		i = (int)ipc.ip_addr;
		if (i<0 || i >= 0x400)	/* MUTOS: ctob(USIZE) = 0x400 */
			goto error;
		ipc.ip_data = ((int *)&u)[i>>1];	/* MUTOS: V7 ((physadr)&u)->r[i>>1] */
		break;

	/* write user I */
	/* Must set up to allow writing */
	case 4:
		/*
		 * If text, must assure exclusive use
		 */
		if (xp = u.u_procp->p_textp) {
			if (xp->x_count!=1 || xp->x_iptr->i_mode&ISVTX)
				goto error;
			xp->x_iptr->i_flag &= ~ITEXT;
		}
		estabur(u.u_tsize, u.u_dsize, u.u_ssize, u.u_sep, 6);	/* MUTOS: V7 RW; suword (V7 suiword) */
		i = suword((caddr_t)ipc.ip_addr, 0);
		suword((caddr_t)ipc.ip_addr, ipc.ip_data);
		estabur(u.u_tsize, u.u_dsize, u.u_ssize, u.u_sep, 2);	/* MUTOS: V7 RO */
		if (i<0)
			goto error;
		if (xp)
			xp->x_flag |= XWRIT;
		break;

	/* write user D */
	case 5:
		if (suword((caddr_t)ipc.ip_addr, 0) < 0)
			goto error;
		suword((caddr_t)ipc.ip_addr, ipc.ip_data);
		break;

	/* write u */
	case 6:
		i = (int)ipc.ip_addr;
		p = (int *)&((int *)&u)[i>>1];	/* MUTOS: V7 &((physadr)&u)->r[i>>1] */
		/* the floating point save area (V7: u_fps .. u_fpregs[6]); MUTOS: u_fparea, 0x90 bytes */
		if (p >= (int *)u.u_fparea && p < (int *)&u.u_fparea[0x90])
			goto ok;
		/* MUTOS (Z8001): 16 registers via regloc[], status word at u_ar0[10] (V7: 8 registers, RPS) */
		for (i=0; i<16; i++)
			if (p == &u.u_ar0[regloc[i]])
				goto ok;
		if (p == &u.u_ar0[10]) {
			ipc.ip_data &= ~0x4800;	/* MUTOS: Z8001 FCW bits (V7: |= 0170000 "assure user space", &= ~0340 "priority 0") */
			ipc.ip_data |= 0x1000;
			goto ok;
		}
		goto error;

	ok:
		*p = ipc.ip_data;
		break;

	/* set signal and continue */
	/*  one version causes a trace-trap */
	case 9:
		u.u_ar0[10] |= 0x800;	/* MUTOS: V7 u_ar0[RPS] |= TBIT */
	case 7:
		if ((int)ipc.ip_addr != 1)
			u.u_ar0[12] = ipc.ip_addr;	/* MUTOS: V7 u_ar0[PC] */
		u.u_procp->p_sig = 0;
		if (ipc.ip_data)
			psignal(u.u_procp, ipc.ip_data);
		return(1);

	/* force exit */
	case 8:
		exit(fsig(u.u_procp));

	default:
	error:
		ipc.ip_req = -1;
	}
	return(0);
}
