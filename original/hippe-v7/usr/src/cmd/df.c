#include <stdio.h>
#include <sys/param.h>
#include <sys/filsys.h>
#include <sys/fblk.h>

#define FREEMAINT

daddr_t	blkno	= 1;
char	*dargv[] = {
	0,
	"/dev/rp0",
	"/dev/rp3",
	0
};


struct	filsys sblock;

int	fi;
#ifndef FREEMAINT
daddr_t	alloc();
#endif FREEMAINT

main(argc, argv)
char **argv;
{
	int i;

	if(argc <= 1) {
		for(argc = 1; dargv[argc]; argc++);
		argv = dargv;
	}

	for(i=1; i<argc; i++) {
		dfree(argv[i]);
	}
}

dfree(file)
char *file;
{
	daddr_t i;

	fi = open(file, 0);
	if(fi < 0) {
		fprintf(stderr,"cannot open %s\n", file);
		return;
	}
	sync();
	bread(1L, (char *)&sblock, sizeof(sblock));
#ifdef FREEMAINT
	i = sblock.s_tfree;
#else
	i = 0;
	while(alloc())
		i++;
#endif FREEMAINT
	printf("%s %D\n", file, i);
	close(fi);
}

#ifndef FREEMAINT
daddr_t
alloc()
{
	int i;
	daddr_t b;
	struct fblk buf;

	i = --sblock.s_nfree;
	if(i<0 || i>=NICFREE) {
		printf("bad free count, b=%D\n", blkno);
		return(0);
	}
	b = sblock.s_free[i];
	if(b == 0)
		return(0);
	if(b<sblock.s_isize || b>=sblock.s_fsize) {
		printf("bad free block (%D)\n", b);
		return(0);
	}
	if(sblock.s_nfree <= 0) {
		bread(b, (char *)&buf, sizeof(buf));
		blkno = b;
		sblock.s_nfree = buf.df_nfree;
		for(i=0; i<NICFREE; i++)
			sblock.s_free[i] = buf.df_free[i];
	}
	return(b);
}
#endif FREEMAINT

bread(bno, buf, cnt)
daddr_t bno;
char *buf;
{
	int n;
	extern errno;

	lseek(fi, bno<<BSHIFT, 0);
	if((n=read(fi, buf, cnt)) != cnt) {
		printf("read error %D\n", bno);
		printf("count = %d; errno = %d\n", n, errno);
		exit(0);
	}
}
