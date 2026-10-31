/* lp.c -- line printer (cdevsw[7]; kernel mutos_1216, 6444..6970): lpopen, lpclose, lpwrite, lpcanon, lpoutput, lpintr, lpxfer.
 *
 * Origin:   partial
 * Source:   Closest template for the line preparation (lpopen / lpwrite / lpcanon, flag bits OPEN / CAP / NOCR / ASLP, columns
 *           ind / col / ccc / mcc / mlc / line, form feed handling): lp.c of the TUHS collection Research/Torsten_Hippe_v7 (assembled
 *           1995 from unknown sources; not the author) and of the Nijmegen variant (lpopen with LPMAX, lp_cnt, col = 80, line = 66);
 *           UNIX System III PDP-11 uts/pdp11/io/lp.c is the same family but lacks these constants (doc/herkunft/mailbox_treiber.md).
 *           UNIX V7 (Spencer tape) contains NO lp.c in usr/sys/dev (measured: `ls original/unix-v7/usr/sys/dev`).  The output path
 *           (mailbox command 2 to the U880 side, lpxfer) and the transmit buffer are MUTOS own.  WEGA dev/lp.c is measurably unrelated (10%).
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): lpopen 25%, lpwrite 29%, lpcanon 32% (against System III lpoutput)
 *           and the rest under 15% against System III; against V7 all functions under 15%; file similarity System III 23%, V7 11%.
 * Roundtrip: cc -O in the guest, per function against mutos_1216 (module is in rundlauf_soll.txt as it stands today);
 *           see doc/herkunft/lp.md.
 * Deviations: text renamed and restructured against the templates (token similarity 25..32% only); output path mailbox based.
 *
 * Two printers (lpt, D3E2, 26 bytes per entry), count nlp = 8C98, buffer lpbuf D416 (128 bytes per printer), mailbox entries lpmbx D516 (14 bytes).
 * The structure follows the classic lp.c (see above), but the output goes through the mailbox (command 2) to the U880 side.
 * 6432 (set tty flag) is in dev1, here ttyinit. */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "mbx.h"
#include "tty.h"

struct lp {
	struct clist	l_outq;		/* 00 */
	char		l_flag;		/* 06: 04H raw, 08H open, 10H capitals only, 20H no CR, 40H sleeping, 80H output running */
	char		l_ind;		/* 07 */
	int		l_ccc;		/* 08 */
	int		l_col;		/* 0A */
	int		l_line;		/* 0C */
	int		l_mlc;		/* 0E */
	int		l_mcc;		/* 10 */
	int		l_ocnt;		/* 12 */
	char		*l_obuf;	/* 14 */
	struct rkmbx	*l_mbx;		/* 16 */
	char		l_err;		/* 18 */
	char		l_x19;
};
extern struct lp lpt[2];		/* D3E2 */
extern char lpbuf[2][128];		/* D416 */
extern struct rkmbx lpmbx[2];		/* D516 */
extern int nlp;				/* 8C98 */
#define PRILP	33

/* KERNEL 6444 */
lpopen(dev)
dev_t dev;
{
	register d;
	register struct lp *lp;

	d = dev & 3;
	if (d >= nlp || d >= 2 || (lp = &lpt[d])->l_flag) {
		u.u_error = EIO;
		return;
	}
	lp->l_flag = (dev & 0x3F) | 8;
	lp->l_ind = 4;
	lp->l_mcc = 0x84;
	lp->l_mlc = 0x42;
	lp->l_obuf = lpbuf[d];
	lp->l_mbx = &lpmbx[d];
	lp->l_err = 0;
	if ((lp->l_flag & 4) == 0)
		lpcanon(d, 12);
}

/* KERNEL 64DA */
lpclose(dev)
dev_t dev;
{
	register d;
	register struct lp *lp;

	d = dev & 3;
	lp = &lpt[d];
	if ((lp->l_flag & 4) == 0)
		lpcanon(d, 12);
	else
		lp->l_line = 0;
	spl4();
	if ((lp->l_flag & 0x80) == 0x80) {
		lp->l_flag |= 0x40;
		sleep(lp, PRILP);
	} else {
		lpoutput(d);
		lp->l_flag |= 0x80;
	}
	if ((lp->l_flag & 0x80) == 0x80) {
		lp->l_flag |= 0x40;
		sleep(lp, PRILP);
	}
	spl0();
	lp->l_flag = 0;
}

/* KERNEL 6570 */
lpwrite(dev)
dev_t dev;
{
	register d, c;
	register struct lp *lp;

	d = dev & 3;
	lp = &lpt[d];
loop:
	if (u.u_count == 0)
		goto done;
	spl4();
	goto chk;
start:
	lp->l_flag |= 0x80;
	lpoutput(d);
chk:
	if (lp->l_outq.c_cc > 0x82) {
		if ((lp->l_flag & 0x80) == 0)
			goto start;
		lp->l_flag |= 0x40;
		sleep(lp, PRILP);
		if (u.u_error == 0)
			goto chk;
		u.u_count += lp->l_outq.c_cc + lp->l_ocnt;
		while (getc(lp) >= 0)
			;
		return;
	}
	spl0();
	c = fubyte(u.u_base++);
	if (c >= 0) {
		u.u_count--;
		spl4();
		lpcanon(d, c);
		spl0();
		goto loop;
	}
	u.u_error = EFAULT;
done:
	spl4();
	if ((lp->l_flag & 0x80) == 0x80) {
		lp->l_flag |= 0x40;
		sleep(lp, PRILP);
	}
	if ((lp->l_flag & 0x80) == 0 && lp->l_outq.c_cc) {
		lpoutput(d);
		lp->l_flag |= 0x80;
	}
	spl0();
}

/* KERNEL 6668 */
lpcanon(dev, c)
register dev, c;
{
	register struct lp *lp;

	lp = &lpt[dev];
	if (lp->l_flag & 0x10) {
		if (c >= 'a' && c <= 'z')
			c += 'A' - 'a';
		else switch (c) {
		case '{':
			c = '(';
			goto esc;
		case '}':
			c = ')';
			goto esc;
		case '`':
			c = '\'';
			goto esc;
		case '|':
			c = '!';
			goto esc;
		case '~':
			c = '^';
		esc:
			lpcanon(dev, c);
			lp->l_ccc--;
			c = '-';
		}
	}
	if (lp->l_flag & 4) {
		if (c == '\n' || c == '\f') {
			putc(c, lp);
			c = '\r';
		}
		putc(c, lp);
		return;
	}
	switch (c) {
	case ' ':
		lp->l_ccc++;
		return;
	case '\t':
		lp->l_ccc = ((lp->l_ccc + 8 - lp->l_ind) & ~7) + lp->l_ind;
		return;
	case '\n':
		lp->l_line++;
		if (lp->l_line >= lp->l_mlc)
			c = '\f';
	case '\f':
		lp->l_col = 0;
		if (lp->l_line) {
			putc(c, lp);
			if (c == '\f')
				lp->l_line = 0;
		}
	case '\r':
		putc('\r', lp);
		lp->l_ccc = lp->l_ind;
		return;
	case 010:
		if (lp->l_ccc > lp->l_ind)
			lp->l_ccc--;
		return;
	default:
		if (lp->l_ccc < lp->l_col) {
			if ((lp->l_flag & 0x20) == 0) {
				putc('\r', lp);
				lp->l_col = 0;
			} else {
				lp->l_ccc++;
				return;
			}
		}
		if (lp->l_ccc < lp->l_mcc) {
			while (lp->l_ccc > lp->l_col) {
				putc(' ', lp);
				lp->l_col++;
			}
			putc(c, lp);
			lp->l_col++;
		}
		lp->l_ccc++;
	}
}

/* KERNEL 680E */
lpoutput(dev)
register dev;
{
	register struct lp *lp;
	register c, n;
	register char *cp;

	lp = &lpt[dev];
	cp = lp->l_obuf;
	n = 0;
	while (n < 0x80) {
		if ((c = getc(lp)) < 0)
			break;
		*cp++ = c;
		if ((n++ > 40 || (lp->l_flag & 4)) && c == '\r')
			break;
	}
	if ((lp->l_ocnt = n) > 0)
		lpxfer(dev);
}

/* KERNEL 6874 */
lpintr(dev)
register dev;
{
	register struct rkmbx *mp;
	register struct lp *lp;
	register x;
	register char *cp;
	int s, e;

	lp = &lpt[dev];
	if ((lp->l_flag & 0x80) == 0)
		return;
	mp = lp->l_mbx;
	cp = lp->l_obuf;
	if (mp->mb_stat != 1) {
		e = mp->mb_dir;
		s = mp->mb_stat;
		if (++lp->l_err <= 10) {
			lpxfer(dev);
			return;
		}
		{
			u.u_error = EIO;
fl:
			lp->l_flag &= ~0x80;
clr:
			lp->l_err = 0;
			if (lp->l_flag & 0x40) {
				lp->l_flag &= ~0x40;
				wakeup(lp);
			}
		}
		return;
	}
	if (lp->l_outq.c_cc > 0) {
		lpoutput(dev);
		goto clr;
	}
	goto fl;
}

/* KERNEL 690A */
lpxfer(dev)
{
	register struct rkmbx *mp;
	register struct lp *lp;

	lp = &lpt[dev];
	mp = lp->l_mbx;
	mp->mb_cmd = 2;
	mp->mb_unit = dev;
	mp->mb_stat = 0;
	mp->mb_seg = 0;
	mp->mb_addr = lp->l_obuf;
	mp->mb_cnt = lp->l_ocnt;
	mp->mb_dir = 1;
	mapalloc(mp, 2);
}
