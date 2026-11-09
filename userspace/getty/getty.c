#
/*
 * getty -- adapt to terminal speed on dialup, and call login
 *
 * MUTOS 8000 /etc/getty.  NOT the V7 getty (original/unix-v7/usr/src/cmd/getty.c): the binary has the
 * extended struct sgttyb (/usr/include/sgtty.h: nl/cr/ht/vt delays, width, length), TIOCSETA, a
 * per-table width/length and the '[' ... ']' erase echo.  Measured deviations from V7:
 *   G1  tchars: ^C interrupt, ^Z end-of-file (V7: DEL, ^D); ERASE DEL, KILL ^U, EOT ^Z
 *   G2  struct tab has six more chars (nldly, crdly, htdly, vtdly, width, length)
 *   G3  default table name '-' (V7: '0'); no 'case 3' speed adaptation
 *   G4  itab has two entries only: '2' (80x24) and 'w' (64x16), both 9600 baud, message "\n\rlogin: "
 *   G5  getname(): erase echoes the removed character between '[' and ']', BEL at an empty line
 *   G6  tmode is set with ioctl(0, TIOCSETA, ...) instead of ioctl(TIOCSETP)/stty
 * Comparison reference: Hippe collection (TUHS) getty.c.old -- large agreement apart from the table.
 */
#include <sgtty.h>
#include <signal.h>

#define ERASE	'\177'
#define KILL	'\25'
#define EOT	'\32'

struct sgttyb tmode;

struct tchars tchars = {
	'\3',		/* ^C - interrupt */
	'\034',		/* ^\ - quit */
	'\021',		/* ^Q - start output */
	'\023',		/* ^S - stop output */
	'\32',		/* ^Z - end-of-file */
	'\377'		/* -1 - input delimeter */
};

struct tab {
	char	tname;		/* this table name */
	char	nname;		/* successor table name */
	int	iflags;		/* initial flags */
	int	fflags;		/* final flags */
	int	ispeed;		/* input speed */
	int	ospeed;		/* output speed */
	char	nldly;		/* delay for nl */
	char	crdly;		/* delay for cr */
	char	htdly;		/* delay for ht */
	char	vtdly;		/* delay for vt */
	char	width;		/* screen width for vdu */
	char	length;		/* screen length for vdu */
	char	*message;	/* login message */
} itab[] = {

	/*
	 * table '2' -- 80x24 terminal, 9600 baud (first entry = default
	 * when the requested table name is not found)
	 */
	'2', '2',
	ANYP+RAW, CRMOD+ECHO+XTABS+SCOPE+ANYP,
	B9600, B9600,
	0, 0, 0, 0,
	80, 24,
	"\n\rlogin: ",

	/*
	 * table 'w' -- 64x16 terminal, 9600 baud
	 */
	'w', 'w',
	ANYP+RAW, CRMOD+ECHO+XTABS+SCOPE+ANYP,
	B9600, B9600,
	0, 0, 0, 0,
	64, 16,
	"\n\rlogin: ",
};

#define	NITAB	sizeof itab/sizeof itab[0]

char	name[16];
int	crmod;
int	upper;
int	lower;

char partab[] = {
	0001,0201,0201,0001,0201,0001,0001,0201,
	0202,0004,0003,0205,0005,0206,0201,0001,
	0201,0001,0001,0201,0001,0201,0201,0001,
	0001,0201,0201,0001,0201,0001,0001,0201,
	0200,0000,0000,0200,0000,0200,0200,0000,
	0000,0200,0200,0000,0200,0000,0000,0200,
	0000,0200,0200,0000,0200,0000,0000,0200,
	0200,0000,0000,0200,0000,0200,0200,0000,
	0200,0000,0000,0200,0000,0200,0200,0000,
	0000,0200,0200,0000,0200,0000,0000,0200,
	0000,0200,0200,0000,0200,0000,0000,0200,
	0200,0000,0000,0200,0000,0200,0200,0000,
	0000,0200,0200,0000,0200,0000,0000,0200,
	0200,0000,0000,0200,0000,0200,0200,0000,
	0200,0000,0000,0200,0000,0200,0200,0000,
	0000,0200,0200,0000,0200,0000,0000,0201
};

main(argc, argv)
char **argv;
{
	register struct tab *tabp;
	int tname;

	tname = '-';
	if(argc > 1)
		tname = argv[1][0];
	for(; ; ){
		for(tabp = itab; tabp < &itab[NITAB]; tabp++)
			if(tabp->tname == tname)
				break;
		if(tabp >= &itab[NITAB])
			tabp = itab;
		tmode.sg_flags = tabp->iflags;
		tmode.sg_ispeed = tabp->ispeed;
		tmode.sg_ospeed = tabp->ospeed;
		tmode.sg_nldly = tabp->nldly;
		tmode.sg_crdly = tabp->crdly;
		tmode.sg_htdly = tabp->htdly;
		tmode.sg_vtdly = tabp->vtdly;
		ioctl(0, TIOCSETA, &tmode);
		ioctl(0, TIOCSETC, &tchars);
		puts(tabp->message);
		if(getname()){
			tmode.sg_erase = ERASE;
			tmode.sg_kill = KILL;
			tmode.sg_flags = tabp->fflags;
			tmode.sg_width = tabp->width;
			tmode.sg_length = tabp->length;
			if(crmod)
				tmode.sg_flags |= CRMOD;
			if(upper)
				tmode.sg_flags |= LCASE;
			if(lower)
				tmode.sg_flags &= ~LCASE;
			ioctl(0, TIOCSETA, &tmode);
			putchr('\n');
			execl("/bin/login", "login", name, 0);
			exit(1);
		}
		tname = tabp->nname;
	}
}

getname()
{
	register char *np;
	register c;
	char cs;
	int xerase = 0;

	crmod = 0;
	upper = 0;
	lower = 0;
	np = name;
	for(; ; ){
		if(read(0, &cs, 1) <= 0)
			exit(0);
		c = cs&0177;
		if(xerase && (c != ERASE)){
			putchr(']');
			xerase = 0;
		}
		if(c == 0)
			return(0);
		if(c == EOT)
			exit(1);
		if(c == '\r' || c == '\n' || np >= &name[16])
			break;
		putchr(cs);
		if(c >= 'a' && c <= 'z')
			lower++;
		else if(c >= 'A' && c <= 'Z'){
			upper++;
			c += 'a'-'A';
		}
		else if(c == ERASE){
			if(np > name){
				if(xerase == 0){
					xerase++;
					putchr('[');
				}
				putchr(*--np);
			}
			else
				putchr('\07');
			continue;
		}
		else if(c == KILL){
			putchr('\r');
			putchr('\n');
			np = name;
			continue;
		}
		else if(c == ' ')
			c = '_';
		*np++ = c;
	}
	*np = 0;
	if(c == '\r')
		crmod++;
	return(1);
}

puts(as)
char *as;
{
	register char *s;

	s = as;
	while(*s)
		putchr(*s++);
}

putchr(cc)
{
	char c;
	c = cc;
	c |= partab[c&0177] & 0200;
	write(1, &c, 1);
}
