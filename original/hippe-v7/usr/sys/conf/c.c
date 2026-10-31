#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/tty.h"
#include "../h/conf.h"
#include "../h/proc.h"
#include "../h/text.h"
#include "../h/dir.h"
#include "../h/user.h"
#include "../h/file.h"
#include "../h/inode.h"
#include "../h/filsys.h"
#include "../h/mount.h"
#include "../h/map.h"
#ifdef	SYSACCT
#include "../h/acct.h"
#endif

int nulldev();
int nodev();
int tmopen(), tmclose(), tmstrategy();
struct buf tmtab;
int rlopen(), rlclose(), rlstrategy();
struct buf rltab;
struct bdevsw	bdevsw[] = {
	tmopen,  tmclose, tmstrategy, &tmtab, 	/*  0 = tm */
	nodev,   nodev,   nodev,      0,	/*  1 = tc */
	nodev,   nodev,   nodev,      0,	/*  2 = rp|hp|rm|hk|si */
	rlopen,  rlclose, rlstrategy, &rltab,	/*  3 = rl */
	0
};

int klopen(), klclose(), klread(), klwrite(), klioctl();
int syopen(), syread(), sywrite(), sysioctl();
int mmread(), mmwrite();
int tmread(), tmwrite();
int rlread(), rlwrite();

struct cdevsw	cdevsw[] = {
klopen,  klclose, klread,  klwrite, klioctl, nulldev,    0,	/*  0 = console */
syopen,  nulldev, syread,  sywrite, sysioctl,nulldev,    0,	/*  1 = tty */
nulldev, nulldev, mmread,  mmwrite, nodev,   nulldev,    0,	/*  2 = mem */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  3 = sem */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  4 = pc */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  5 = lp */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  6 = dc */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  7 = dj|dh|dz */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  8 = dp|du */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/*  9 = dn */
tmopen,  tmclose, tmread,  tmwrite, nodev,   nulldev,    0,	/* 10 = tm */
nodev,   nodev,   nodev,   nodev,   nodev,   nulldev,    0,	/* 11 = rp|hp|rm|hk|si */
rlopen,  rlclose, rlread,  rlwrite, nodev,   nulldev,    0,	/* 12 = rl */
	0
};

int ttyopen(), ttyclose(), ttread(), ttwrite(), ttyinput(), ttstart();
struct linesw	linesw[] = {
	ttyopen, nulldev, ttread, ttwrite, nodev,   ttyinput, ttstart, /* 0 */
	0
};

int rootdev = makedev(3, 0);
int swapdev = makedev(3, 0);
int pipedev = makedev(3, 0);
int nldisp  = 1;
daddr_t swplo = 18000;
int     nswap = 2480;

struct buf buf[NBUF];
struct inode inode[NINODE];
struct file file[NFILE];
struct mount mount[NMOUNT];
struct map coremap[MAPSIZ+1];
struct map swapmap[MAPSIZ+1];
struct proc proc[NPROC];
struct text text[NTEXT];
struct buf bfreelist;

#ifdef SYSACCT
struct acct acctbuf;
struct inode *acctp;
#endif SYSACCT

#ifdef MX
int mpxchan();
int (*ldmpx)() = mpxchan;
#endif MX
