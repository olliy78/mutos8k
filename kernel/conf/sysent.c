/* sysent.c -- system call table.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/sys/sysent.c (numbering, row format "narg, nrarg, handler", comments).
 * Evidence: measured: kernel mutos_1216 data 8B58..8C57, 64 entries of 4 bytes (argument count byte, nrarg byte, handler);
 *           the nrarg byte is 0 in all 64 entries (V7/PDP-11 uses it for arguments passed in registers).  The argument counts
 *           and handlers of 58 rows equal V7 except nrarg.  H2 file similarity 2% only because the V7 file is 80% comment/declaration.
 *           Entry 0 is nullsys (trap.c calls sigret itself when callp == sysent).
 * Deviations: rows 31 (stty), 32 (gtty), 51 (sysacct), 52 (sysphys), 53 (syslock), 56 (mpxchan) are nosys with narg 0 in MUTOS;
 *           nrarg is 0 everywhere; the V7 declarations of the six missing handlers are omitted.  The numbering is the V7
 *           numbering (not measurably System III: no System III only call such as setpgrp (39) or utssys is present).
 */
#include "param.h"
#include "systm.h"

/*
 * This table is the switch used to transfer
 * to the appropriate routine for processing a system call.
 * Each row contains the number of arguments expected
 * and a pointer to the routine.
 */
int	alarm();
int	chdir();
int	chmod();
int	chown();
int	chroot();
int	close();
int	creat();
int	dup();
int	exec();
int	exece();
int	fork();
int	fstat();
int	ftime();
int	getgid();
int	getpid();
int	getuid();
int	gtime();
int	ioctl();
int	kill();
int	link();
int	mknod();
int	nice();
int	nosys();
int	nullsys();
int	open();
int	pause();
int	pipe();
int	profil();
int	ptrace();
int	read();
int	rexit();
int	saccess();
int	sbreak();
int	seek();
int	setgid();
int	setuid();
int	smount();
int	ssig();
int	stat();
int	stime();
int	sumount();
int	sync();
int	times();
int	umask();
int	unlink();
int	utime();
int	wait();
int	write();

struct sysent sysent[64] =
{
	0, 0, nullsys,	/*  0 = indir */
	1, 0, rexit,	/*  1 = exit */
	0, 0, fork,	/*  2 = fork */
	3, 0, read,	/*  3 = read */
	3, 0, write,	/*  4 = write */
	2, 0, open,	/*  5 = open */
	1, 0, close,	/*  6 = close */
	0, 0, wait,	/*  7 = wait */
	2, 0, creat,	/*  8 = creat */
	2, 0, link,	/*  9 = link */
	1, 0, unlink,	/* 10 = unlink */
	2, 0, exec,	/* 11 = exec */
	1, 0, chdir,	/* 12 = chdir */
	0, 0, gtime,	/* 13 = time */
	3, 0, mknod,	/* 14 = mknod */
	2, 0, chmod,	/* 15 = chmod */
	3, 0, chown,	/* 16 = chown; now 3 args */
	1, 0, sbreak,	/* 17 = break */
	2, 0, stat,	/* 18 = stat */
	4, 0, seek,	/* 19 = seek; now 3 args */
	0, 0, getpid,	/* 20 = getpid */
	3, 0, smount,	/* 21 = mount */
	1, 0, sumount,	/* 22 = umount */
	1, 0, setuid,	/* 23 = setuid */
	0, 0, getuid,	/* 24 = getuid */
	2, 0, stime,	/* 25 = stime */
	4, 0, ptrace,	/* 26 = ptrace */
	1, 0, alarm,	/* 27 = alarm */
	2, 0, fstat,	/* 28 = fstat */
	0, 0, pause,	/* 29 = pause */
	2, 0, utime,	/* 30 = utime */
	0, 0, nosys,	/* 31 = stty (nosys in MUTOS) */
	0, 0, nosys,	/* 32 = gtty (nosys in MUTOS) */
	2, 0, saccess,	/* 33 = access */
	1, 0, nice,	/* 34 = nice */
	1, 0, ftime,	/* 35 = ftime; formerly sleep */
	0, 0, sync,	/* 36 = sync */
	2, 0, kill,	/* 37 = kill */
	0, 0, nullsys,	/* 38 = switch; inoperative */
	0, 0, nullsys,	/* 39 = setpgrp (not in yet) */
	1, 0, nosys,	/* 40 = tell (obsolete) */
	2, 0, dup,	/* 41 = dup */
	0, 0, pipe,	/* 42 = pipe */
	1, 0, times,	/* 43 = times */
	4, 0, profil,	/* 44 = prof */
	0, 0, nosys,	/* 45 = unused */
	1, 0, setgid,	/* 46 = setgid */
	0, 0, getgid,	/* 47 = getgid */
	2, 0, ssig,	/* 48 = sig */
	0, 0, nosys,	/* 49 = reserved for USG */
	0, 0, nosys,	/* 50 = reserved for USG */
	0, 0, nosys,	/* 51 = turn acct off/on (nosys in MUTOS) */
	0, 0, nosys,	/* 52 = set user physical addresses (nosys in MUTOS) */
	0, 0, nosys,	/* 53 = lock user in core (nosys in MUTOS) */
	3, 0, ioctl,	/* 54 = ioctl */
	0, 0, nosys,	/* 55 = readwrite (in abeyance) */
	0, 0, nosys,	/* 56 = creat mpx comm channel (nosys in MUTOS) */
	0, 0, nosys,	/* 57 = reserved for USG */
	0, 0, nosys,	/* 58 = reserved for USG */
	3, 0, exece,	/* 59 = exece */
	1, 0, umask,	/* 60 = umask */
	1, 0, chroot,	/* 61 = chroot */
	0, 0, nosys,	/* 62 = x */
	0, 0, nosys	/* 63 = used internally */
};
