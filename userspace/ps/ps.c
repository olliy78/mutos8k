#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
/* Differs from V7: this ps is not V7 ps.c (see doc/userspace/cmd_s3b4.md); MUTOS kernel layouts in mutosk.h */
#include "dir.h"
#include "mutosk.h"

#define NSYMB	28

/* Differs from V7: own nlist (name, value); the kernel's table of addresses is read from /dev/kmem in getnl() */
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

char *mem = "/dev/mem";
char *passwd = "/etc/passwd";
char *devdir = "/dev";
int core;
int pcore;
int swap;
daddr_t swplo;
long memorg;
int	ndev;
char	devc[65];
int	devl[65];
int mf;

struct user u;

char cmndbuf[4096];
char *cbfree = &cmndbuf[0];

char *names[3050];
char namebuf[1024];
char *nbfree = &namebuf[0];

int totalusage;
int totalsize;

struct INFO {
	struct  proc p;
	char    ttynam;
	int     cptime;
	int     usage;
	char    *cmnd;
	int    uid, ruid;
} info[NPROC], *lastinfo;

struct proc *max_proc;
int nproc = NPROC;

main(argc, argv)
int argc;
char *argv[];
{
	register struct INFO *ip;
	register int j;
	extern icomp();

	if((core=open("/dev/kmem",0)) < 0 || (pcore=open(mem,0)) < 0) {
		printf("cannot open %s\n",mem);
		exit(1);
	}
	getnl();
	getnames();
	lseek(core, (long)nl[19].n_value, 0);
	read(core, (char *)&nl[19].n_value, sizeof(nl[19].n_value));
	lseek(core,(long)nl[20].n_value,0);
	read(core,(char *)&swplo, sizeof(swplo));
	if(chdir(devdir) < 0){
		printf("cannot chdir to %s\n", devdir);
		exit(1);
	}
	getdev();
	lseek(core, (long)nl[0].n_value, 0);
	ip = &info[0];
	totalusage = 0;
	totalsize = 0;
	for(j = 0; j < nproc; j++) {
		read(core, (char *)&(ip->p), sizeof(struct proc));
		if(j == 0)
			memorg = ctob((long)ip->p.p_addr);
		if(ip->p.p_stat == 0) continue;
		ip->usage = ip->p.p_cpu & 0377;
		totalusage += ip->usage;
		totalsize += ip->p.p_size >> 2;
		getusr(&ip->p, ip);
		ip++;
	}
	lastinfo = ip - 1;
	qsort(info, lastinfo - info + 1, sizeof info[0], icomp);
	output(argc, argv);
}

icomp(ii1, ii2)
{
	register struct INFO *i1, *i2;

	i1= ii1;  i2 = ii2;
	if (i1->ttynam != i2->ttynam)
		return(i2->ttynam - i1->ttynam);
	if(i1->p.p_pgrp != i2->p.p_pgrp)
		return(i1->p.p_pgrp - i2->p.p_pgrp);
	return(i1->p.p_pid - i2->p.p_pid);
}

getnl()
{
	int a[29];
	unsigned w;
	register i;

	lseek(core, (long)0x23C, 0);
	read(core, (char *)&w, 2);
	lseek(core, (long)(w+2), 0);
	read(core, (char *)a, sizeof a);
	for(i = 0; i <= 28; i++)
		nl[i].n_value = a[i];
	lseek(core, (long)nl[NSYMB].n_value, 0);
	read(core, (char *)&max_proc, sizeof(max_proc));
	nproc = max_proc - (struct proc *)nl[0].n_value + 1;
}

getusr(pp, ip)
struct proc *pp;
struct INFO *ip;
{
	long stkaddr;
	long addr;
	char stbuf[512];
	long ltime;
	register nbad;
	register int *i;
	register char *cp, *cp1;
	register c, j;

	if(pp->p_flag & (SLOAD|SLOCK)) {
		stkaddr = ctob((long)pp->p_addr) + 0xFE00L;
		addr = 0xEC00L - (memorg >> 6) + (pp->p_addr << 2);
		addr += memorg;
		mf = pcore;
	} else {
		addr = ((long)pp->p_addr + swplo) << 9;
		stkaddr = addr + ctob(USIZE);
		mf = swap;
	}
	lseek(mf, addr, 0);
	read(mf, (char *)&u, sizeof u);
	ip->uid = u.u_uid;
	ip->ruid = u.u_ruid;
	ltime = u.u_utime + u.u_stime + 25;
	ip->cptime = ltime/50;
	ip->ttynam = '%';
	if(u.u_ttyp) for(j = 0; j < ndev; j++) if(devl[j] == u.u_ttyd) {
		ip->ttynam = devc[j];
		break;
	}
	if(!(pp->p_flag & (SLOAD|SLOCK))) {
		stkaddr += ((u.u_dsize+1)&~1) << 8;
		cp = (char *)u.u_ar0 - 0xFC00;
		i = (int *)(cp + (int)&u);
		j = (unsigned)i[8] >> 8;
		j &= ~1;
		c = 0xFE - j;
		stkaddr += c << 8;
	}
	lseek(mf, stkaddr, 0);
	read(mf, stbuf, 512);
	for(i = (int *)&stbuf[512]-2; i > (int *)stbuf;) {
		if(*--i == -1 || *i == 0) {
			cp = (char *)(i + 1);
			if(*cp == 0) cp++;
			nbad = 0;
			for(cp1 = cp; cp1 < &stbuf[512]; cp1++) {
				c = *cp1&0177;
				if(c == 0) *cp1 = ' ';
				else if(c < ' ' || c > 0176) {
					if(++nbad >= 5) {
						*cp1++ = ' ';
						break;
					}
					*cp1 = '?';
				} else if(c == '=') {
					*cp1 = 0;
					while(cp1 > cp && *--cp1 != ' ')
						*cp1 = 0;
					break;
				}
			}
			while(*--cp1 == ' ')
				*cp1 = 0;
			cp1 = cbfree;
			while(*cp1++ = *cp++);
			ip->cmnd = cbfree;
			cbfree = cp1;
			return(0);
		}
	}
	ip->cmnd = cbfree;
	*cbfree++ = '?'; *cbfree++ = 0;
	return(0);
}

output(argc, argv)
char *argv[];
{
	register int i, j;
	register struct INFO *ip;

	printf("tty owner     pid status      size cptime     command\n");
	printf("--- -----     --- ------      ---- ------ --- -------\n");
	if(argc == 1) {
		for(ip = lastinfo; ip >= &info[0]; ip--)
		 if(ip->p.p_pgrp == ip->p.p_pid ||
		  (ip->p.p_ppid == 1 && ip->p.p_pgrp != 0)
		      ) out1(ip, 0);
	} else {
		if(argv[1][0] == '-'){
			for(ip = &info[0]; ip <= lastinfo; ip++){
				if(ip->ttynam == argv[1][1]){
					out1(ip, 0);
					break;
				}
			}
			if(ip > lastinfo)
				printf("tty%c not found\n", argv[1][1]);
		} else for(i = 1; i < argc; i++){
			j = 0;
			for(ip = &info[0]; ip <= lastinfo; ip++)
			if(((ip->p.p_pgrp == ip->p.p_pid) ||
				(ip->p.p_ppid == 1 && ip->p.p_pgrp != 0))
				&& seq(argv[i], names[ip->ruid]))
			{	out1(ip, 0);
				j++;
			}
			if(j == 0) printf("%s not logged in\n", argv[i]);
		}
	}
}

out1(p, level)
struct INFO *p;
{
	register struct INFO *ip, *rp;

	ip = p;
	out2(ip, level);
	for(rp = &info[0]; rp <= lastinfo; rp++)
	if(rp->p.p_pid /* kludge for process 0 */
	&& rp->p.p_ppid == ip->p.p_pid /* direct descendant */
	&& rp->p.p_pgrp == ip->p.p_pgrp /* same session */
	) out1(rp, level+1);
}

out2(ip, level)
register struct INFO *ip;
{
	register int j;
	static lasttty;

	if(lasttty != ip->ttynam) {
		lasttty = ip->ttynam;
		printf("%c ", lasttty);
	} else printf("  ");
	if(level == 0) {
		printf("- ");
		puid(ip->p.p_uid);
	} else {
		printf("-");
		j = level;
		while(j--) putchar('>');
		j = level;
		while(j++ <= 8) putchar(' ');
	}
	printf("%5d ", ip->p.p_pid);
	pstatus(&ip->p);
	printf("%2dk ", ip->p.p_size >> 2);
	printf("%3d:", ip->cptime/60);
	ip->cptime %= 60;
	printf(ip->cptime < 10 ? "0%d " : "%d ", ip->cptime);
	if(ip->usage * 100 / totalusage)
		printf("%2d%% ", ip->usage * 100 / totalusage);
	else
		printf("    ");
	if(ip->p.p_pid == 0)
		printf("system scheduler ");
	else
		printf("%-.30s ", ip->cmnd);
	printf("\n");
}

gwchan(wchan)
register char *wchan;
{
	register struct nlist *trial, *guess;

	trial = &nl[NSYMB];
	for(guess = &nl[0]; guess < &nl[NSYMB]; guess++)
	if(guess->n_value > trial->n_value && guess->n_value <= wchan)
		trial = guess;
	return(trial);
}

getnames()
{
	register char *dp;
	register j, c;

	close(0);
	open(passwd, 0);
	for(;;) {
		dp = nbfree;
		c = getchar(); if(c < 'a' || c > 'z') break;
		while(c != ':') {
			*dp++ = c;
			c = getchar();
		}
		*dp++ = 0;
		while(getchar() != ':');
		j = 0;
		while((c = getchar()) >= '0' && c <= '9')
			j = j * 10 + c - '0';
		if (names[j] == 0){
			names[j] = nbfree;
			nbfree = dp;
		}
		while(getchar() != '\n');
	}
	names[0] = --dp;        /* don't print user-id 0 name */
}

seq(s1, s2)
register char *s1, *s2;
{
	while(*s1) if(*s1++ != *s2++) return(0);
	return(1);
}

puid(uid)
register int uid;
{
	if(names[uid])
		printf("%-8.8s", names[uid]);
	else
		printf("%-8d", uid);
}

pstatus(pp)
register struct proc *pp;
{
	register struct nlist *nlp;
	register char *mess;
	register i;

	switch(pp->p_stat) {
	case SSLEEP: mess = pp->p_pri ? "slp" : "SLP"; break;
	case SRUN:   mess = "RUN"; break;
	case SIDL:   mess = "idl"; break;
	case SZOMB:  mess = "zmb"; break;
	case SSTOP:  mess = "stp"; break;
	}
	printf("%s%c",mess,(pp->p_flag & (SLOAD|SLOCK)) ? '*' : ' ');
	mess = " ";
	if(pp->p_stat == SSLEEP) {
		nlp = gwchan(pp->p_wchan);
		switch(nlp - &nl[0]) {
		case 0:
			i = (pp->p_wchan - nl[0].n_value)/sizeof(*pp);
			printf(i < 10 ? "proc[0%d] ": "proc[%2d] ", i);
			return;
		case 2:
			mess = "kl11";
			break;
		case 4:
			mess = "trace";
			break;
		case 5:
			mess = "I/O";
			break;
		case 6:
			mess = "filsys";
			break;
		case 7:
			mess = "freebuf";
			break;
		case 8: case 9:
			mess = "swap";
			break;
		case 10:
			mess = "runin";
			break;
		case 11:
			mess = "runout";
			break;
		case 12:
			mess = "pause";
			break;
		case 13: case 14: case 15:
			mess = "clock";
			break;
		case 16: case 21:
			mess = "raw I/O";
			break;
		case 17:
			mess = "text";
			break;
		case 18:
			mess = "inode";
			break;
		default:
			printf("%-8x ", pp->p_wchan);
			return;
		}
	}
	printf("%-8.8s ", mess);
}

getdev()
{
	register struct direct *p;
	register i, c, f;
	char dbuf[512];
	struct stat sbuf;

	f = open(devdir, 0);
	if(f < 0) {
		printf("cannot open %s\n", devdir);
		exit(1);
	}
	c = 0;
	while((i = read(f, dbuf, 512)) > 0) {
		while(i < 512)
			dbuf[i++] = 0;
		for(p = dbuf; p < dbuf+512; p++) {
			if(p->d_ino == 0)
				continue;
			if(strcmp(p->d_name,"console")==0) {
				if(stat(p->d_name,&sbuf) < 0)
					continue;
				devc[c] = 'C';
				devl[c] = sbuf.st_rdev;
				c++;
				continue;
			}
			if(p->d_name[0] == 't' &&
			   p->d_name[1] == 't' &&
			   p->d_name[2] == 'y' &&
			   p->d_name[4] == 0 &&
			   p->d_name[3] != 0) {
				if(stat(p->d_name, &sbuf) < 0)
					continue;
				devc[c] = p->d_name[3];
				devl[c] = sbuf.st_rdev;
				c++;
				continue;
			}
		}
	}
	close(f);
	swap = open("/dev/swap", 0);
	if (swap < 0){
		printf("Cannot open /dev/swap\n");
		exit(1);
	}
	c = 0;
	while( devc[c] ) c++;
	ndev = c;
}
