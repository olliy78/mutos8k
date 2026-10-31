#

#include <sys/param.h>
#include <sys/proc.h>
#include <sys/dir.h>
#include <sys/user.h>
#include <sys/tty.h>
#include <sys/stat.h>
#include <a.out.h>
#include <core.h>

char *ss_nlist = "/tmp/ss.nlist";
char *ss_names = "/tmp/ss.names";
char *ss_devices = "/tmp/ss.devices";
char *mem = "/dev/mem";
char *unfile = "/unix";
char *passwd = "/etc/passwd";
char *devdir = "/dev";
int core;
int pcore;
int swap;
daddr_t swplo;
char *getptr();
int	ndev;
char	devc[65];
int	devl[65];
int mf;

struct user u;

char cmndbuf[4096];
char *cbfree = &cmndbuf[0];

struct nlist nl[] = {
	{"_proc"},
	{"_dc11"},
	{"_kl11"},
	{"_dh11"},
	{"_dz11"},
	{"_ipc"},
	{"_buf"},
	{"_buffers"},
	{"_bfreeli"},
	{"_pc11"},
	{"_swbuf1"},{"_swbuf2"},
	{"_runin"},
	{"_runout"},
	{"_u"},
	{"_lbolt"},{"_time"},{"_callout"},
	{"_rrkbuf"},{"_rrlbuf"},{"_rrpbuf"},{"_rhpbuf"},{"_rrmbuf"},{"_rsibuf"},
	{"_text"},
	{"_inode"},
	{"_swapdev"},{"_swplo"},
	{"_max_pro"},
	{""},
};

#define NSYMB	(sizeof(nl)/sizeof(struct nlist) - 2)

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

	if((core=open(mem,0)) < 0 || (pcore=open(mem,0)) < 0) {
		printf("cannot open %s\n",mem);
		exit(1);
	}
	getnl();
	getnames();
	lseek(core, (long)nl[NSYMB-2].n_value, 0);
	read(core, (char *)&nl[NSYMB-2].n_value, sizeof(nl[NSYMB-2].n_value));
	lseek(core,(long)nl[NSYMB-1].n_value,0);
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
		if(ip->p.p_stat == 0) continue;
		ip->usage = ip->p.p_cpu & 0377;
		totalusage += ip->usage;
		totalsize += ip->p.p_size >> 5;
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
	register file;

	file = open(ss_nlist, 0);
	if(file >= 0)
		read(file, nl, sizeof nl);
	else {
		nlist(unfile, nl);
		file = creat(ss_nlist, 0444);
		write(file, nl, sizeof nl);
	}
	close( file );
	if(nl[NSYMB].n_type != 0){
		lseek(core, (long)nl[NSYMB].n_value, 0);
		read(core, (char *)&max_proc, sizeof(max_proc));
		nproc = max_proc - (struct proc *)nl[0].n_value + 1;
	}
}

long round(a,b)
long a,b;
{
	long w = ((a+b-1)/b)*b;

	return(w);
}


struct map {
	long b1, e1, f1;
	long b2, e2, f2;
} datmap;

getusr(pp, ip)
struct proc *pp;
struct INFO *ip;
{
	int nbad;
	long addr;
	register int *i;
	register char *cp, *cp1;
	int c, j;
	char stbuf[512];
	char **ap;
	long ltime;
	long txtsiz, datsiz, stksiz;
	int septxt;

	if(pp->p_flag & SLOAD) {
		addr = ctob((long)pp->p_addr);
		mf = pcore;
	} else {
		addr = (pp->p_addr+swplo)<<9;
		mf = swap;
	}
	lseek(mf, addr, 0);
	read(mf, &u, sizeof u);
	ip->uid = u.u_uid;
	ip->ruid = u.u_ruid;
	ltime = (u.u_utime) + (u.u_stime) + 30;
	ip->cptime = ltime/60;
	/* --- BTL code to get tty name --- */
	ip->ttynam = '%';
	if(u.u_ttyp) for(j = 0; j < ndev; j++) if(devl[j] == u.u_ttyd) {
		ip->ttynam = devc[j];
		break;
	}
	/* set up address maps for user pcs */
	txtsiz = ctob(u.u_tsize);
	datsiz = ctob(u.u_dsize);
	stksiz = ctob(u.u_ssize);
	septxt = u.u_sep;
	datmap.b1 = (septxt ? 0 : round(txtsiz,TXTRNDSIZ));
	datmap.e1 = datmap.b1+datsiz;
	datmap.f1 = ctob(USIZE)+addr;
	datmap.b2 = stackbas(stksiz);
	datmap.e2 = stacktop(stksiz);
	datmap.f2 = ctob(USIZE)+(datmap.e1-datmap.b1)+addr;
	addr += ctob((long)pp->p_size) - 512;
	lseek(mf, addr+512-sizeof(char **), 0);
	if (read(mf, (char *)&ap, sizeof(char *)) != sizeof(char *))
		return(1);
	if (ap) {
		char b[82];
		char *bp = b;
		while((cp=getptr(ap++)) && cp && (bp<b+80) ) {
			nbad = 0;
			while((c=getbyte(cp++)) && (bp<b+80)) {
				if (c<' ' || c>'~') {
					if (nbad++>3)
						break;
					continue;
				}
				*bp++ = c;
			}
			*bp++ = ' ';
		}
		*bp++ = 0;
		bp = b;
		cp = cbfree;
		while(*cp++ = *bp++);
		ip->cmnd = cbfree;
		cbfree = cp;
		return(0);
	}

	lseek(mf, addr, 0);
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
	register struct INFO *rp, *ip;

	ip = p;
	out2(ip, level);
	for(rp = &info[0]; rp <= lastinfo; rp++)
	if(rp->p.p_pid /* kludge for process 0 */
	&& rp->p.p_ppid == ip->p.p_pid /* direct descendant */
	&& rp->p.p_pgrp == ip->p.p_pgrp /* same session */
	) out1(rp, level+1);
}

out2(ip, level)
struct INFO *ip;
{
	int j;
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
	printf("%2dk ", ip->p.p_size >> 5);
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
char *wchan;
{
	register struct nlist *trial, *guess;

	trial = &nl[NSYMB];
	for(guess = &nl[0]; guess < &nl[NSYMB-2]; guess++)
	if(guess->n_value > trial->n_value && guess->n_value <= wchan)
		trial = guess;
	return(trial);
}

getnames()
{
	int file;
	register char *dp;
	int j, c;

	file = open(ss_names, 0);
	if(file >= 0) {
		read(file, names, sizeof names);
		read(file, namebuf, sizeof namebuf);
	} else {
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
		file = creat(ss_names, 0444);
		write(file, names, sizeof names);
		write(file, namebuf, sizeof namebuf);
	}
	close(file);
}

seq(s1, s2)
char *s1, *s2;
{
	while(*s1) if(*s1++ != *s2++) return(0);
	return(1);
}

puid(uid)
int uid;
{
	if(names[uid])
		printf("%-8.8s", names[uid]);
	else
		printf("%-8d", uid);
}

pstatus(pp)
struct proc *pp;
{
	register struct nlist *nlp;
	register char *mess;
	register i;

	switch(pp->p_stat) {
	case SSLEEP: mess = pp->p_pri > 0 ? "slp" : "SLP"; break;
	case SRUN:   mess = "RUN"; break;
	case SIDL:   mess = "idl"; break;
	case SZOMB:  mess = "zmb"; break;
	case SSTOP:  mess = "stp"; break;
	}
	printf("%s%c",mess,(pp->p_flag & SLOAD) ? '*' : ' ');
	mess = " ";
	if(pp->p_stat == SSLEEP) {
		nlp = gwchan(pp->p_wchan);
		switch(nlp - &nl[0]) {
		case 0:
			i = (pp->p_wchan - nl[0].n_value)/sizeof(*pp);
			printf(i < 10 ? "proc[0%d] ": "proc[%2d] ", i);
			return;
		case 1:
			mess = "dc11";
			break;
		case 2:
			mess = "kl11";
			break;
		case 3:
			mess = "dh11";
			break;
		case 4:
			mess = "dz11";
			break;
		case 5:
			mess = "trace";
			break;
		case 6:
			mess = "I/O";
			break;
		case 7:
			mess = "filsys";
			break;
		case 8:
			mess = "freebuf";
			break;
		case 9:
			mess = "pc11";
			break;
		case 10: case 11:
			mess = "swap";
			break;
		case 12:
			mess = "runin";
			break;
		case 13:
			mess = "runout";
			break;
		case 14:
			mess = "pause";
			break;
		case 15: case 16: case 17:
			mess = "clock";
			break;
		case 18: case 19: case 20:
		case 21: case 22: case 23:
			mess = "raw I/O";
			break;
		case 24:
			mess = "text";
			break;
		case 25:
			mess = "inode";
			break;
		default:
			printf("%-8d ", pp->p_wchan);
			return;
		}
	}
	printf("%-8.8s ", mess);
}

/* --- from ps.c for V6 to get teletype names --- */



getdev()
{
	register struct direct *p;
	register i, c;
	int f, k;
	char dbuf[512];
	struct stat sbuf;

	/* see if we have a file containing all the neat information */
	f = open(ss_devices, 0);
	if (f >= 0){
		read(f, devc, sizeof devc);
		read(f, devl, sizeof devl);
		close( f );
	} else {
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
		f = creat(ss_devices, 0444);
		write(f, devc, sizeof devc);
		write(f, devl, sizeof devl);
		close(f);
	}
	swap = open("/dev/swap", 0);
	if (swap < 0){
		printf("Cannot open /dev/swap\n");
		exit(1);
	}
	c = 0;
	while( devc[c] ) c++;
	ndev = c;
	return;
}

char *
getptr(adr)
char **adr;
{
	char *ptr;
	register char *p, *pa;
	register i;

	ptr = 0;
	pa = (char *)adr;
	p = (char *)&ptr;
	for (i=0; i<sizeof(ptr); i++)
		*p++ = getbyte(pa++);
	return(ptr);
}

getbyte(adr)
char *adr;
{
	register struct map *amap = &datmap;
	char b;
	long saddr;

	if(!within(adr, amap->b1, amap->e1)) {
		if(within(adr, amap->b2, amap->e2)) {
			saddr = (unsigned)adr + amap->f2 - amap->b2;
		} else
			return(0);
	} else
		saddr = (unsigned)adr + amap->f1 - amap->b1;
	if(lseek(mf, saddr, 0)==-1
		   || read(mf, &b, 1)<1) {
		return(0);
	}
	return((unsigned)b);
}

within(adr,lbd,ubd)
char *adr;
long lbd, ubd;
{
	return((unsigned)adr>=lbd && (unsigned)adr<ubd);
}
