/*
 * set teletype modes
 *
 * MUTOS 8000 /bin/stty.  NOT the V7 stty (original/unix-v7/usr/src/cmd/stty.c), but the same program
 * structure (main with an if chain, eq(), prmodes(), delay(), prspeed()) extended for the MUTOS
 * <sgtty.h> (struct sgttyb with nl/cr/ht/vt delay bytes, width, length; SCOPE, INDCTL, TANDEM, XTABS;
 * ioctl TIOCGETA/TIOCSETA instead of gtty/stty).  Measured deviations from V7 (doc/userspace/stty.md):
 *   S1  modes[] has no delay entries and no 33/37/05/tn/ti short names; "crmod" replaces V7 "nl"
 *       ("-nl" == CRMOD set); new: scope, indctl, tandem (and their - forms)
 *   S2  delays and terminal types are an if chain in main(), not table entries:
 *       nl0..nl2 cr0..cr2 tab0 tab1 ff0 ff1 (bs0 bs1 nl3 cr3 tab2: "%s - no effect")
 *       width/length/nl/cr/ht/vt take a number (atoi); dac ban tek sat set speed, size, flags;
 *       tty33 tty37 vt05 tn300 ti700 set delays
 *   S3  ek sets erase DEL and kill ^U (V7 '#', '@')
 *   S4  the mode word is read/written with ioctl(1, TIOCGETA/TIOCSETA, &mode)
 *   S5  prmodes(): "crmod " (V7 "-nl "), erase DEL text, scope/indctl/tandem, delay lines in
 *       "%s\t%d\n" form (nldly crdly htdly vtdly, width length)
 * The unknown delay constants are the measured byte values of the binary (no macro names exist).
 * Comparison reference: Hippe collection (TUHS) bin/stty (PDP-11 binary, same strings).
 */

#include <stdio.h>
#include <sgtty.h>

struct
{
	char	*string;
	int	speed;
} speeds[] = {
	"0",	B0,
	"50",	B50,
	"75",	B75,
	"110",	B110,
	"134",	B134,
	"134.5",B134,
	"150",	B150,
	"200",	B200,
	"300",	B300,
	"600",	B600,
	"1200",	B1200,
	"1800",	B1800,
	"2400",	B2400,
	"4800",	B4800,
	"9600",	B9600,
	"exta",	EXTA,
	"extb",	EXTB,
	0,
};
struct
{
	char	*string;
	int	set;
	int	reset;
} modes[] = {
	"even",
	EVENP, 0,

	"-even",
	0, EVENP,

	"odd",
	ODDP, 0,

	"-odd",
	0, ODDP,

	"raw",
	RAW, 0,

	"-raw",
	0, RAW,

	"cooked",
	0, RAW,

	"crmod",
	CRMOD, 0,

	"-crmod",
	0, CRMOD,

	"echo",
	ECHO, 0,

	"-echo",
	0, ECHO,

	"LCASE",
	LCASE, 0,

	"lcase",
	LCASE, 0,

	"-LCASE",
	0, LCASE,

	"-lcase",
	0, LCASE,

	"-tabs",
	XTABS, 0,

	"tabs",
	0, XTABS,

	"cbreak",
	CBREAK, 0,

	"-cbreak",
	0, CBREAK,

	"scope",
	SCOPE, 0,

	"-scope",
	0, SCOPE,

	"indctl",
	INDCTL, 0,

	"-indctl",
	0, INDCTL,

	"tandem",
	TANDEM, 0,

	"-tandem",
	0, TANDEM,

	0,
	};

char	*arg;
struct sgttyb mode;

main(argc, argv)
char	*argv[];
{
	int i;

	ioctl(1, TIOCGETA, &mode);
	if(argc == 1) {
		prmodes();
		exit(0);
	}
	while(--argc > 0) {

		arg = *++argv;
		if (eq("ek")){
			mode.sg_erase = '\177';
			mode.sg_kill = '\25';
		}
		if (eq("erase")) {
			if (**++argv == '^')
				mode.sg_erase = (*argv)[1] & 037;
			else
				mode.sg_erase = **argv;
			argc--;
		}
		if (eq("kill")) {
			if (**++argv == '^')
				mode.sg_kill = (*argv)[1] & 037;
			else
				mode.sg_kill = **argv;
			argc--;
		}
		if (eq("gspeed")) {
			mode.sg_ispeed = B300;
			mode.sg_ospeed = B9600;
		}
		if (eq("nl0"))
			mode.sg_nldly = 0;
		if (eq("nl1"))
			mode.sg_nldly = 6;
		if (eq("nl2"))
			mode.sg_nldly = 6;
		if (eq("cr0"))
			mode.sg_crdly = 0;
		if (eq("cr1"))
			mode.sg_crdly = 5;
		if (eq("cr2"))
			mode.sg_crdly = 10;
		if (eq("tab0")) {
			mode.sg_htdly = 0;
			mode.sg_flags &= ~XTABS;
		}
		if (eq("tab1"))
			mode.sg_htdly = 5;
		if (eq("ff0"))
			mode.sg_vtdly = 0;
		if (eq("ff1"))
			mode.sg_vtdly = 0261;
		if (eq("bs0") || eq("bs1") || eq("nl3") || eq("cr3") || eq("tab2"))
			fprintf(stderr, "%s - no effect\n", *argv);
		if (eq("hup")) {
			ioctl(1, TIOCHPCL, NULL);
		}
		if (eq("width")) {
			mode.sg_width = atoi(*++argv);
			argc--;
		}
		if (eq("length")) {
			mode.sg_length = atoi(*++argv);
			argc--;
		}
		if (eq("nl")) {
			mode.sg_nldly = atoi(*++argv);
			argc--;
		}
		if (eq("cr")) {
			mode.sg_crdly = atoi(*++argv);
			argc--;
		}
		if (eq("ht")) {
			mode.sg_htdly = atoi(*++argv);
			argc--;
		}
		if (eq("vt")) {
			mode.sg_vtdly = atoi(*++argv);
			mode.sg_flags &= ~XTABS;
			argc--;
		}
		if (eq("dac")) {
			mode.sg_ispeed = mode.sg_ospeed = B4800;
			mode.sg_length = 24;
			mode.sg_width = 80;
			mode.sg_flags = ANYP+CRMOD+ECHO+XTABS+SCOPE;
		}
		if (eq("ban")) {
			mode.sg_ispeed = mode.sg_ospeed = B9600;
			mode.sg_length = 24;
			mode.sg_width = 80;
			mode.sg_flags = CRMOD+ECHO+XTABS+SCOPE;
		}
		if (eq("tek")) {
			mode.sg_ispeed = mode.sg_ospeed = B9600;
			mode.sg_length = 30;
			mode.sg_width = 72;
			mode.sg_flags = ANYP+CRMOD+ECHO+XTABS;
		}
		if (eq("sat")) {
			mode.sg_ispeed = mode.sg_ospeed = B9600;
			mode.sg_length = 0;
			mode.sg_width = 0;
			mode.sg_flags = ANYP+CRMOD+ECHO+XTABS+LCASE;
		}
		if (eq("tty33"))
			mode.sg_crdly = 5;
		if (eq("tty37")) {
			mode.sg_nldly = 6;
			mode.sg_crdly = 10;
			mode.sg_htdly = 5;
			mode.sg_vtdly = 0261;
			mode.sg_flags &= ~XTABS;
		}
		if (eq("vt05"))
			mode.sg_nldly = 6;
		if (eq("tn300"))
			mode.sg_crdly = 5;
		if (eq("ti700"))
			mode.sg_crdly = 10;
		else
		for(i=0; speeds[i].string; i++)
			if(eq(speeds[i].string))
				mode.sg_ispeed = mode.sg_ospeed = speeds[i].speed;
		for(i=0; modes[i].string; i++)
			if(eq(modes[i].string)) {
				mode.sg_flags &= ~modes[i].reset;
				mode.sg_flags |= modes[i].set;
			}
		if(arg)
			fprintf(stderr,"unknown mode: %s\n", arg);
	}
	ioctl(1, TIOCSETA, &mode);
}

eq(string)
char *string;
{
	int i;

	if(!arg)
		return(0);
	i = 0;
loop:
	if(arg[i] != string[i])
		return(0);
	if(arg[i++] != '\0')
		goto loop;
	arg = 0;
	return(1);
}

prmodes()
{
	register m;

	if(mode.sg_ispeed != mode.sg_ospeed) {
		prspeed("input speed  ", mode.sg_ispeed);
		prspeed("output speed ", mode.sg_ospeed);
	} else
		prspeed("speed ", mode.sg_ispeed);
	if (mode.sg_erase < ' ')
		fprintf(stderr, "erase = '^%c'; ", '@' + mode.sg_erase);
	else if (mode.sg_erase == 0177)
		fprintf(stderr, "erase = DEL; ");
	else
		fprintf(stderr, "erase = '%c'; ", mode.sg_erase);
	if (mode.sg_kill < ' ')
		fprintf(stderr, "kill = '^%c'\n", '@' + mode.sg_kill);
	else
		fprintf(stderr, "kill = '%c'\n", mode.sg_kill);
	m = mode.sg_flags;
	if(m & EVENP)	fprintf(stderr,"even ");
	if(m & ODDP)	fprintf(stderr,"odd ");
	if(m & RAW)	fprintf(stderr,"raw ");
	if(m & CRMOD)	fprintf(stderr,"crmod ");
	if(m & ECHO)	fprintf(stderr,"echo ");
	if(m & LCASE)	fprintf(stderr,"lcase ");
	if(m & XTABS)	fprintf(stderr,"-tabs ");
	if (m & CBREAK)	fprintf(stderr,"cbreak ");
	if (m & SCOPE)	fprintf(stderr,"scope ");
	if (m & INDCTL)	fprintf(stderr,"indctl ");
	if (m & TANDEM)	fprintf(stderr,"tandem ");
	fprintf(stderr,"\n");
	delay(mode.sg_nldly, "nldly");
	delay(mode.sg_crdly, "crdly");
	delay(mode.sg_htdly, "htdly");
	delay(mode.sg_vtdly, "vtdly");
	fprintf(stderr,"\n");
	delay(mode.sg_width, "width");
	delay(mode.sg_length, "length");
	fprintf(stderr,"\n");
}

delay(m, s)
char *s;
{

	if(m)
		fprintf(stderr,"%s\t%d\n", s, m);
}

int	speed[] = {
	0,50,75,110,134,150,200,300,600,1200,1800,2400,4800,9600,0,0
};

prspeed(c, s)
char *c;
{

	fprintf(stderr,"%s%d baud\n", c, speed[s]);
}
