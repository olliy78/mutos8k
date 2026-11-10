#include <stdio.h>
/* Differs from V7: "x.h" instead of <sys/x.h> (the MUTOS /usr/include lacks these headers; they lie flat on /mnt, -I/mnt has no subdirectories) */
#include "param.h"
#include "filsys.h"
#include "fblk.h"

daddr_t	blkno	= 1;
char	*dargv[] = {
	0,
	/* Differs from V7: /dev/rk0, /dev/rk1 (MUTOS devices) instead of /dev/rp0, /dev/rp3 */
	"/dev/rk0",
	"/dev/rk1",
	0
};


struct	filsys sblock;
/* Differs from V7: the original's sblock is 512 B (BSS 72 B larger than sizeof(struct filsys) = 440 B); padded as in dcheck */
char	sbpad[BSIZE-sizeof(struct filsys)];

int	fi;
daddr_t	alloc();

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
	bread(1L, (char *)&sblock, BSIZE);	/* Differs from V7: BSIZE instead of sizeof(sblock) */
	i = 0;
	while(alloc())
		i++;
	printf("%s %D\n", file, i);
	close(fi);
}

daddr_t
alloc()
{
	int i;
	daddr_t b;
	/* Differs from V7: the original's buf takes 512 B (frame 0x206), padded in front of buf */
	char bpad[BSIZE-sizeof(struct fblk)];
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
		bread(b, (char *)&buf, BSIZE);	/* Differs from V7: BSIZE instead of sizeof(buf) */
		blkno = b;
		sblock.s_nfree = buf.df_nfree;
		for(i=0; i<NICFREE; i++)
			sblock.s_free[i] = buf.df_free[i];
	}
	return(b);
}

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
