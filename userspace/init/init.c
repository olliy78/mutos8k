/*
 * /etc/init of MUTOS 8000 -- reconstructed source.
 *
 * Origin (plan 42): UNIX V7 init.c (original/unix-v7/usr/src/cmd/init.c), function for function in V7 order.
 * Five deviations of the MUTOS binary against V7 are measured in the listing (doc/userspace/init.md) and marked
 * "MUTOS" below; for each, the V7 text is quoted in a comment.  The strings "/bin/login" and "single user " also
 * occur in the init of the Hippe collection (TUHS, PDP-11 binary; large agreement of the strings; its source is
 * not available), so the changes may stem from a V7 derivative rather than from MUTOS itself (assumption).
 *
 * Build:  cc -O -s init.c  (MUTOS cc); the own code (0030-065E) agrees with the original binary instruction for
 * instruction, byte for byte up to the address operands, if the three c2 differences of doc/userspace/init.md
 * (R1-R3) are taken into account.  Run:  python3 -I tools/userspace/pipeline.py alles init --c2emu
 */
#include <signal.h>
#include <sys/types.h>
#include <utmp.h>
#include <setjmp.h>

#define	TABSIZ	100
#define	ALL	p = &itab[0]; p < &itab[TABSIZ]; p++
#define	EVER	;;

char	shell[]	= "/bin/sh";
char	getty[]	 = "/etc/getty";
char	minus[]	= "-";
char	runc[]	= "/etc/rc";
char	ifile[]	= "/etc/ttys";
char	utmp[]	= "/etc/utmp";
char	wtmpf[]	= "/usr/adm/wtmp";
char	ctty[]	= "/dev/console";
char	dev[]	= "/dev/";
char	login[]	= "/bin/login";	/* MUTOS: new string, sits behind dev[] in the data segment (name assumed) */

struct utmp wtmp;
struct
{
	char	line[8];
	char	comn;
	char	flag;
} line;
struct	tab
{
	char	line[8];
	char	comn;
	int	pid;
} itab[TABSIZ];

int	fi;
char	tty[20];
jmp_buf	sjbuf;

main()
{
	int reset();
	int merge();

	setjmp(sjbuf);
	signal(SIGHUP, reset);
	/*
	 * MUTOS: SIGTERM re-reads /etc/ttys like SIGINT; the creat of /etc/utmp moved from merge() into the loop.
	 * V7:	setjmp(sjbuf);
	 *	signal(SIGHUP, reset);
	 *	for(EVER) {
	 *		shutdown();
	 *		single();
	 *		runcom();
	 *		merge();
	 *		multiple();
	 *	}
	 */
	signal(SIGTERM, merge);
	for(EVER) {
		shutdown();
		single();
		runcom();
		close(creat(utmp, 0644));
		merge();
		multiple();
	}
}

shutdown()
{
	register i;
	register struct tab *p;

	signal(SIGINT, SIG_IGN);
	for(ALL)
		term(p);
	signal(SIGALRM, reset);
	alarm(60);
	for(i=0; i<5; i++)
		kill(-1, SIGKILL);
	while(wait((int *)0) != -1)
		;
	alarm(0);
	signal(SIGALRM, SIG_DFL);
	for(i=0; i<10; i++)
		close(i);
}

single()
{
	register pid;

	pid = fork();
	if(pid == 0) {
/*
		alarm(300);
*/
		signal(SIGHUP, SIG_DFL);
		signal(SIGINT, SIG_DFL);
		signal(SIGALRM, SIG_DFL);
		open(ctty, 2);
		dup(0);
		dup(0);
		/* MUTOS: announce single user mode and try /bin/login first; V7 goes straight to the execl(shell, ...) below */
		printf("single user ");
		execl(login, login, (char *)0);
		execl(shell, minus, (char *)0);
		exit(0);
	}
	while(wait((int *)0) != pid)
		;
}

runcom()
{
	register pid;

	pid = fork();
	if(pid == 0) {
		open("/", 0);
		dup(0);
		dup(0);
		execl(shell, shell, runc, (char *)0);
		exit(0);
	}
	while(wait((int *)0) != pid)
		;
}

multiple()
{
	register struct tab *p;
	register pid;

	for(EVER) {
		pid = wait((int *)0);
		if(pid == -1)
			continue;	/* MUTOS; V7: return; */
		for(ALL)
			if(p->pid == pid || p->pid == -1) {
				rmut(p);
				dfork(p);
			}
	}
}

term(p)
register struct tab *p;
{

	if(p->pid != 0) {
		rmut(p);
		kill(p->pid, SIGKILL);
	}
	p->pid = 0;
	p->line[0] = 0;
}

rline()
{
	register c, i;

	c = get();
	if(c < 0)
		return(0);
	if(c == 0)
		goto bad;
	line.flag = c;
	c = get();
	if(c <= 0)
		goto bad;
	line.comn = c;
	for(i=0; i<8; i++)
		line.line[i] = 0;
	for(i=0; i<7; i++) {
		c = get();
		if(c <= 0)
			break;
		line.line[i] = c;
	}
	while(c > 0)
		c = get();
	maktty(line.line);
	if(access(tty, 06) < 0)
		goto bad;
	return(1);

bad:
	line.flag = '0';
	return(1);
}

maktty(lin)
char *lin;
{
	register i, j;

	for(i=0; dev[i]; i++)
		tty[i] = dev[i];
	for(j=0; lin[j]; j++) {
		tty[i] = lin[j];
		i++;
	}
	tty[i] = 0;
}

get()
{
	char b;

	if(read(fi, &b, 1) != 1)
		return(-1);
	if(b == '\n')
		return(0);
	return(b);
}

merge()
{
	register struct tab *p, *q;
	register i;

	/* MUTOS: V7 starts merge() with close(creat(utmp, 0644)); and installs only signal(SIGINT, merge); */
	signal(SIGINT, merge);
	signal(SIGTERM, merge);
	fi = open(ifile, 0);
	if(fi < 0)
		return;
	q = &itab[0];
	while(rline()) {
		if(line.flag == '0')
			continue;
		for(ALL) {
			if(p->line[0] != 0)
			for(i=0; i<8; i++)
				if(p->line[i] != line.line[i])
					goto contin;
			if(p >= q) {
				i = p->pid;
				p->pid = q->pid;
				q->pid = i;
				for(i=0; i<8; i++)
					p->line[i] = q->line[i];
				p->comn = q->comn;
				for(i=0; i<8; i++)
					q->line[i] = line.line[i];
				q->comn = line.comn;
				q++;
			}
			break;
		contin:
			;
		}
	}
	close(fi);
	for(; q < &itab[TABSIZ]; q++)
		term(q);
	for(ALL)
		if(p->line[0] != 0 && p->pid == 0)
			dfork(p);
}

dfork(p)
struct tab *p;
{
	register pid;

	pid = fork();
	if(pid == 0) {
		signal(SIGHUP, SIG_DFL);
		signal(SIGINT, SIG_DFL);
		maktty(p->line);
		chown(tty, 0, 0);
		chmod(tty, 0622);
		open(tty, 2);
		dup(0);
		dup(0);
		tty[0] = p->comn;
		tty[1] = 0;
		execl(getty, minus, tty, (char *)0);
		exit(0);
	}
	p->pid = pid;
}

rmut(p)
register struct tab *p;
{
	register i, f;

	f = open(utmp, 2);
	if(f >= 0) {
		while(read(f, (char *)&wtmp, sizeof(wtmp)) == sizeof(wtmp)) {
			for(i=0; i<8; i++)
				if(wtmp.ut_line[i] != p->line[i])
					goto contin;
			lseek(f, -(long)sizeof(wtmp), 1);
			for(i=0; i<8; i++)
				wtmp.ut_name[i] = 0;
			time(&wtmp.ut_time);
			write(f, (char *)&wtmp, sizeof(wtmp));
		contin:;
		}
		close(f);
	}
	f = open(wtmpf, 1);
	if (f >= 0) {
		for(i=0; i<8; i++) {
			wtmp.ut_name[i] = 0;
			wtmp.ut_line[i] = p->line[i];
		}
		time(&wtmp.ut_time);
		lseek(f, (long)0, 2);
		write(f, (char *)&wtmp, sizeof(wtmp));
		close(f);
	}
}

reset()
{
	longjmp(sjbuf, 1);
}
