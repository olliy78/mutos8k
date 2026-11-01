/* tty.h -- tty structure and clist.
 *
 * Origin:   partial
 * Source:   struct clist, struct tc, struct tty member names, struct ttiocb, the mode/state bit names, the limits and the ioctl codes:
 *           usr/include/sys/tty.h of the TUHS collection Research/Torsten_Hippe_v7 (assembled 1995 from unknown sources; not the author),
 *           doc/herkunft/tty2.md.  The layout up to +34 equals struct tty of that collection (doc/herkunft/fremd.md section 5); the
 *           MUTOS additions t_ocnt, t_hwp, t_hwf follow t_line.  The type is "short" where the collection has it (16 bits, like int here).
 * Evidence: H2 file similarity 29% V7 / 7% System III (before the rename).  Measured (K7d/K7e): 60 (3CH) bytes, four lines from A530 (ttyt),
 *           output buffer 80 bytes per line from D2A2, mailbox entry per line from D26A (h/mbx.h); offsets from the accesses of
 *           sioopen/ttread/ttwrite/ttystart/ttyflush/ttyoutput/ttioctl:
 *   +00 t_rawq (clist: c_cc 0, c_cf 2, c_cl 4)   +06 t_outq (clist)   +0C t_oproc (tcstart)   +0E t_iproc (unused)
 *   +10 t_pgrp   +12 t_addr (here: the output buffer of the line)   +14 t_dev   +16 t_ispeed  +17 t_ospeed
 *   +18 t_erase (7F)   +19 t_kill (15H)   +1A t_flags (ECHO 8, CRMOD 10H, RAW 20H; default 518H)
 *   +1C..1F t_nldly/t_crdly/t_htdly/t_vtdly (output delays)  +20 t_width +21 t_length (page length, 0 = off)
 *   +22 t_un: t_intrc (03) +23 t_quitc (1C) +24 t_startc (11) +25 t_stopc (13) +26 t_eofc (1A) +27 t_brkc (FF)
 *   +28 t_state (TIMEOUT 1, WOPEN 2, ISOPEN 4, CARR_ON 10H, BUSY 20H, ASLEEP 40H, XCLUDE 80H, TTSTOP 100H, TBLOCK 400H)
 *   +2A t_xstate (XPAGE 1, XPAGE1 2 = output waits for a 0x80 character, XPAGE2 4, XLITRL 8, XERASE 10H)
 *   +2C t_lnum (lines since the last page stop), +2D t_col, +2E t_delct, +2F t_char, +30 t_chan, +32 t_linep, +34 t_line
 *   +36 t_ocnt  +38 t_hwp  +3A t_hwf (MUTOS)
 * Deviations: t_obuf of earlier versions is t_addr; the MUTOS additions after t_line; the filler t_x35 / t_x3b; flag XTABS 02000 as in the
 *           collection (V7: 006000); ENOTTY / EBUSY_ at the end.  struct clist: pipe.c has its own identical copy; do not include both.
 */
#ifndef TTY_H
#define TTY_H
#include "types.h"
#include "mbx.h"
/*
 * A clist structure is the head
 * of a linked list queue of characters.
 */
struct clist {
	int	c_cc;		/* character count */
	char	*c_cf;		/* pointer to first char */
	char	*c_cl;		/* pointer to last char */
};

/*
 * Special character structure.
 * All special characters may be redefined, so
 * they are held within the tty structure.
 */
struct tc {
	char	t_intrc;	/* interrupt */
	char	t_quitc;	/* quit */
	char	t_startc;	/* start output */
	char	t_stopc;	/* stop output */
	char	t_eofc;		/* end-of-file */
	char	t_brkc;		/* input delimiter (like nl) */
};

struct tty {
	struct clist t_rawq;	/* 00 input list from device */
	struct clist t_outq;	/* 06 output list to device */
	int	(* t_oproc)();	/* 0C routine to start output */
	int	(* t_iproc)();	/* 0E routine to start input */
	short	t_pgrp;		/* 10 process group name */
	caddr_t	t_addr;		/* 12 device address (MUTOS: the output buffer of the line) */
	dev_t	t_dev;		/* 14 device number */
	char	t_ispeed;	/* 16 input speed */
	char	t_ospeed;	/* 17 output speed */
	char	t_erase;	/* 18 erase character */
	char	t_kill;		/* 19 kill character */
	short	t_flags;	/* 1A mode, settable by ioctl call */
	char	t_nldly;	/* 1C delay for newline */
	char	t_crdly;	/* 1D delay for carriage return */
	char	t_htdly;	/* 1E delay for horizontal tab (with XTABS also the column from which tabs were expanded) */
	char	t_vtdly;	/* 1F delay for vertical tab */
	char	t_width;	/* 20 max. line length for folding */
	char	t_length;	/* 21 max. screen length for paging */
	union {
		struct tc;
		struct clist t_ctlq;
	} t_un;			/* 22 */
	short	t_state;	/* 28 internal state, not visible externally */
	short	t_xstate;	/* 2A as above, for extra stuff */
	char	t_lnum;		/* 2C line number on screen */
	char	t_col;		/* 2D printing column of device */
	char	t_delct;	/* 2E number of delimiters in raw q */
	char	t_char;		/* 2F character temporary */
	struct chan *t_chan;	/* 30 destination channel (unused) */
	caddr_t	t_linep;	/* 32 aux line discipline pointer (unused) */
	char	t_line;		/* 34 line discipline (ttioccomm: linesw[t_line], 20 bytes per entry) */
	char	t_x35;		/* 35 */
	int	t_ocnt;		/* 36 MUTOS: length of the pending output */
	struct rkmbx *t_hwp;	/* 38 MUTOS: mailbox entry of the line */
	char	t_hwf;		/* 3A MUTOS */
	char	t_x3b;		/* 3B */
};
extern struct tty ttyt[4];	/* A530 */

#define	tun	tp->t_un

/*
 * structure of arg for ioctl
 */
struct	ttiocb {
	char	ioc_ispeed;
	char	ioc_ospeed;
	char	ioc_erase;
	char	ioc_kill;
	short	ioc_flags;
	char	ioc_nldly;
	char	ioc_crdly;
	char	ioc_htdly;
	char	ioc_vtdly;
	char	ioc_width;
	char	ioc_length;
};

#define	TTIPRI	28
#define	TTOPRI	29

/*
 * Default special characters.
 */
#define	CERASE	0177	/* DEL */
#define	CEOT	032	/* ^Z */
#define	CKILL	025	/* ^U */
#define	CQUIT	034	/* ^\ */
#define	CINTR	03	/* ^C */
#define	CSTOP	023	/* ^S */
#define	CSTART	021	/* ^Q */
#define	CBRK	0377	/* -1 */

/*
 * Other control characters. These
 * are not redefinable by the user.
 */
#define CPAGE	020	/* ^P - flip paging off/on for this process */
#define CRETYPE	022	/* ^R - retype current line */
#define CWORD	027	/* ^W - delete word */

#define CBELL	07	/* ^G - (ding-dong) */

/*
 * limits
 */
#define	TTHIWAT	100
#define	TTLOWAT	50
#define	TTYHOG	256

/*
 * modes
 */
#define	TANDEM	01
#define	CBREAK	02
#define	LCASE	04
#define	ECHO	010
#define	CRMOD	020
#define	RAW	040
#define	ODDP	0100
#define	EVENP	0200
#define SCOPE	0400
#define INDCTL	01000
#define XTABS	02000

/*
 * Internal state bits
 */
#define	TIMEOUT	01		/* Delay timeout in progress */
#define	WOPEN	02		/* Waiting for open to complete */
#define	ISOPEN	04		/* Device is open */
#define	FLUSH	010		/* outq has been flushed during DMA */
#define	CARR_ON	020		/* Software copy of carrier-present */
#define	BUSY	040		/* Output in progress */
#define	ASLEEP	0100		/* Wakeup when output done */
#define	XCLUDE	0200		/* exclusive-use flag against open */
#define	TTSTOP	0400		/* Output stopped by ctl-s */
#define	HUPCLS	01000		/* Hang up upon last close */
#define	TBLOCK	02000		/* tandem queue blocked */
#define	CNTLQ	0100000		/* interpret t_un as clist */

/*
 * More internal state bits (for t_xstate)
 */
#define XPAGE	01	/* output is being paged */
#define XPAGE1	02	/* set to indicate stopped at page boundary */
#define XPAGE2	04	/* set to stop ttwrite after a page is on the queue */
#define XLITRL	010	/* last character was a literal escape */
#define XERASE	020	/* erase string in progress */

/*
 * tty ioctl commands
 */
#define	TIOCGETD	(('t'<<8)|0)
#define	TIOCSETD	(('t'<<8)|1)
#define	TIOCHPCL	(('t'<<8)|2)
#define	TIOCGETP	(('t'<<8)|8)
#define	TIOCSETP	(('t'<<8)|9)
#define	TIOCSETN	(('t'<<8)|10)
#define TIOCSETA	(('t'<<8)|11)
#define TIOCGETA	(('t'<<8)|12)
#define	TIOCEXCL	(('t'<<8)|13)
#define	TIOCNXCL	(('t'<<8)|14)
#define TIOCNRD		(('t'<<8)|15)
#define	TIOCFLUSH	(('t'<<8)|16)
#define	TIOCSETC	(('t'<<8)|17)
#define	TIOCGETC	(('t'<<8)|18)
#define	DIOCGETP	(('d'<<8)|8)
#define	DIOCSETP	(('d'<<8)|9)
#define	FIOCLEX		(('f'<<8)|1)
#define	FIONCLEX	(('f'<<8)|2)

#define ENOTTY	25
#define EBUSY_	16
#endif
