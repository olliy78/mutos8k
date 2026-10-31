/* prf.c -- console output and panic (kernel mutos_1216, 1724..18D3; putchar is at 6384 in the driver part): printf, printn,
 * panic, prdev, deverror.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/sys/prf.c (all 5 functions).  System III PDP-11 uts/os/prf.c differs (printn/deverr,
 *           different panic/printf); only printf and panic agree there.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): file 100% V7 (before the restoration), 62% System III;
 *           all 5 functions 100% against V7, strings "panic: %s\n", "%s on dev %u/%u\n", "bn=%D er=%o,%o\n" are V7.
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/prf.md.
 * Deviations: only the include list (no seg.h, conf.h) and the KERNEL markers; see doc/herkunft/prf.md.
 *
 * Data: 8A4A "0123456789ABCDEF" (printn), 8A5B "panic: %s\n" (panic), 8A66 "%s on dev %u/%u\n" (prdev), 8A77 "err"
 * (deverror), 8A7B "bn=%D er=%o,%o\n" (deverror); panicstr = CEC4 (BSS word).  printn puts its digit string into the
 * text pool in function order. */
#include "param.h"
#include "systm.h"
#include "buf.h"

/*
 * In case console is off,
 * panicstr contains argument to last
 * call to panic.
 */

char	*panicstr;

/*
 * Scaled down version of C Library printf.
 * Only %s %u %d (==%u) %o %x %D are recognized.
 * Used to print diagnostic information
 * directly on console tty.
 * Since it is not interrupt driven,
 * all system activities are pretty much
 * suspended.
 * Printf should not be used for chit-chat.
 */
/* VARARGS 1 */
/* KERNEL 1724 */
printf(fmt, x1)
register char *fmt;
unsigned x1;
{
	register c;
	register unsigned int *adx;
	char *s;

	adx = &x1;
loop:
	while((c = *fmt++) != '%') {
		if(c == '\0')
			return;
		putchar(c);
	}
	c = *fmt++;
	if(c == 'd' || c == 'u' || c == 'o' || c == 'x')
		printn((long)*adx, c=='o'? 8: (c=='x'? 16:10));
	else if(c == 's') {
		s = (char *)*adx;
		while(c = *s++)
			putchar(c);
	} else if (c == 'D') {
		printn(*(long *)adx, 10);
		adx += (sizeof(long) / sizeof(int)) - 1;
	}
	adx++;
	goto loop;
}

/*
 * Print an unsigned integer in base b.
 */
/* KERNEL 17E0 */
printn(n, b)
long n;
{
	register long a;

	if (n<0) {	/* shouldn't happen */
		putchar('-');
		n = -n;
	}
	if(a = n/b)
		printn(a, b);
	putchar("0123456789ABCDEF"[(int)(n%b)]);
}

/*
 * Panic is called on unresolvable
 * fatal errors.
 * It syncs, prints "panic: mesg" and
 * then loops.
 */
/* KERNEL 1856 */
panic(s)
char *s;
{
	panicstr = s;
	update();
	printf("panic: %s\n", s);
	for(;;)
		idle();
}

/*
 * prdev prints a warning message of the
 * form "mesg on dev x/y".
 * x and y are the major and minor parts of
 * the device argument.
 */
/* KERNEL 187A */
prdev(str, dev)
char *str;
dev_t dev;
{

	printf("%s on dev %u/%u\n", str, major(dev), minor(dev));
}

/*
 * deverr prints a diagnostic from
 * a device driver.
 * It prints the device, block number,
 * and an octal word (usually some error
 * status register) passed as argument.
 */
/* KERNEL 18A4 */
deverror(bp, o1, o2)
register struct buf *bp;
{

	prdev("err", bp->b_dev);
	printf("bn=%D er=%o,%o\n", bp->b_blkno, o1, o2);
}
