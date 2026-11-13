/*
 * convert -- convert a file system between the byte order of the MUTOS 8000 (Z8000, big endian)
 * and the PDP-11 V7 order (every 16-bit word byte-swapped, 3-byte block addresses with a swapped
 * low word).  "to" converts a MUTOS file system to the PDP-11 form, "from" the other way round.
 *
 * NOT a V7 program: no source exists in the V7 trees of this repository.  Reconstructed from the
 * listing, the map and the strings of the original binary (doc/userspace/cmd_s3b5.md); the function
 * names, the variable names and the comments are ours.
 */
#include <stdio.h>
/* Differs from V7 programs: "x.h" instead of <sys/x.h> (the headers lie flat on /mnt) */
#include "param.h"
#include "ino.h"
#include "filsys.h"
#include "fblk.h"
#include "dir.h"

long	blkno	= 1;
char	seekerr[] = "seek error %s  0x%06X\n";
char	rderr[] = "read error %s  0x%04x\n";
char	wrerr[] = "write error %s 0x%04x\n";
char	blkname[] = "block :";
char	inoname[] = "inode :";

long	curr;
int	fd;
int	mode;		/* 0 = "to" (swap after use), 1 = "from" (swap before use) */
unsigned	inum;
struct	dinode	ino;
struct	filsys	sblock;
char	sbpad[BSIZE-sizeof(struct filsys)];
struct	direct	dbuf[BSIZE/sizeof(struct direct)];

long	l3tol();

main(argc, argv)
char **argv;
{
	if (argc != 3)
		goto usage;
	if (strcmp("to", argv[2]) == 0)
		mode = 0;
	else if (strcmp("from", argv[2]) == 0)
		mode = 1;
	else {
usage:
		printf("usage : convert block_special_file 'to'/'from'\n");
		exit(1);
	}
	if ((fd = open(argv[1], 2)) == -1) {
		printf("can't open %s\n", argv[1]);
		exit(1);
	}
	sync();
	blk(&sblock, 0);
	if (mode == 1)
		swabsb();
	inum = sblock.s_isize - 2;
	inum <<= 3;
	curr = sblock.s_free[0];
	if (mode == 0)
		swabsb();
	for (;;) {
		blk(&sblock, 1);
		if (curr == 0)
			break;
		blkno = curr;
		blk(&sblock, 0);
		if (mode == 1)
			swab(&sblock, 512);
		curr = ((struct fblk *)&sblock)->df_free[0];
		if (mode == 0)
			swab(&sblock, 512);
	}
	while (inum != 0) {
		rdino(0);
		if (mode == 1)
			swabino();
		if (ino.di_mode) {
			if (ino.di_mode & 040000)
				convdir();
			if (mode == 0)
				swabino();
			rdino(1);
		}
		inum--;
	}
	sync();
	exit(0);
}

/* read (rw == 0) or write block blkno from/to buf */
blk(buf, rw)
register char *buf;
{
	long off;

	off = blkno << 9;
	if (lseek(fd, off, 0) < 0) {
		printf(seekerr, blkname, off);
		exit(1);
	}
	if (rw == 0) {
		if (read(fd, buf, 512) != 512) {
			printf(rderr, blkname, (int)blkno);
			exit(1);
		}
	} else {
		if (write(fd, buf, 512) != 512) {
			printf(wrerr, blkname, (int)blkno);
			exit(1);
		}
	}
}

/* swap the bytes of the super block fields (not the free lists) */
swabsb()
{
	register char *a, *b;

	a = (char *)&sblock;
	b = (char *)&sblock.s_flock;
	swab(a, b - a);
	a = (char *)&sblock.s_time;
	b = sblock.s_fname;
	swab(a, b - a);
}

/* read (rw == 0) or write inode inum into/from ino */
rdino(rw)
{
	long off;

	off = inum + 15;
	off <<= 6;
	if (lseek(fd, off, 0) < 0) {
		printf(seekerr, inoname, off);
		exit(1);
	}
	if (rw == 0) {
		if (read(fd, &ino, 64) != 64) {
			printf(rderr, inoname, inum);
			exit(1);
		}
	} else {
		if (write(fd, &ino, 64) != 64) {
			printf(wrerr, inoname, inum);
			exit(1);
		}
	}
}

/* swap the inode and the (single and double) indirect blocks it points to */
swabino()
{
	register char *a, *b;
	long ind;
	long *lp;

	a = (char *)&ino;
	b = ino.di_addr;
	swab(a, b - a);
	if (mode == 0) {
		ind = l3tol(&ino.di_addr[33]);
		blkno = l3tol(&ino.di_addr[30]);
	}
	while (b < &ino.di_addr[36]) {
		swab(++b, 2);
		b += 2;
	}
	if (mode == 1) {
		ind = l3tol(&ino.di_addr[33]);
		blkno = l3tol(&ino.di_addr[30]);
	}
	if (blkno != 0) {
		blk(&sblock, 0);
		swab(&sblock, 512);
		blk(&sblock, 1);
	}
	if (ind != 0) {
		blkno = ind;
		blk(dbuf, 0);
		if (mode == 1)
			swab(dbuf, 512);
		for (lp = (long *)dbuf; lp < (long *)&dbuf[32]; lp++) {
			blkno = *lp;
			if (blkno != 0) {
				blk(&sblock, 0);
				swab(&sblock, 512);
				blk(&sblock, 1);
			}
		}
		if (mode == 0)
			swab(dbuf, 512);
		blkno = ind;
		blk(dbuf, 1);
	}
	a = (char *)&ino.di_atime;
	b = (char *)&ino + sizeof ino;
	swab(a, b - a);
}

/* swap the inode numbers in the entries of a directory */
convdir()
{
	register char *cp;
	register struct direct *dp;
	register long *lp;
	long ind;

	for (cp = ino.di_addr; cp < &ino.di_addr[30]; cp += 3) {
		blkno = l3tol(cp);
		if (blkno != 0) {
			blk(dbuf, 0);
			for (dp = dbuf; dp < &dbuf[32]; dp++)
				swab(dp, 2);
			blk(dbuf, 1);
		}
	}
	ind = l3tol(cp);
	if (ind != 0) {
		blkno = ind;
		blk(&sblock, 0);
		for (lp = (long *)&sblock; lp < (long *)dbuf; lp++) {
			if (*lp != 0) {
				if (mode == 1)
					swab(lp, 4);
				blkno = *lp;
				if (mode == 0)
					swab(lp, 4);
				blk(dbuf, 0);
				for (dp = dbuf; dp < &dbuf[32]; dp++)
					swab(dp, 2);
				blk(dbuf, 1);
			}
		}
		blkno = ind;
		blk(&sblock, 1);
	}
}

/* swap the two bytes of n/2 words at p */
swab(p, n)
register char *p;
register n;
{
	register t;

	n >>= 1;
	while (--n >= 0) {
		t = *p;
		*p = p[1];
		p++;
		*p++ = t;
	}
}

/* 3-byte block address of a PDP-11 inode: high byte, then the low word (here in native order) */
long
l3tol(p)
register char *p;
{
	register c;
	register char *q;
	int w;

	q = (char *)&w;
	c = *p++ & 0377;
	*q++ = *p++;
	*q = *p;
	return ((long)c << 16) + (unsigned)w;
}
