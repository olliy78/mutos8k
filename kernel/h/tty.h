/* tty.h -- tty structure and clist.
 *
 * Origin:   partial
 * Source:   struct clist and the mode/state bit names: UNIX V7 usr/sys/h/tty.h;
 *           struct tty: System III/ZEUS layout (one input queue), not the V7 layout (rawq/canq/outq).
 * Evidence: H2 file similarity 29% V7 / 7% System III.  Measured (K7d/K7e): 60 (3CH) bytes, four lines from A530 (ttyt), output buffer
 *           80 bytes per line from D2A2, mailbox entry per line from D26A (h/mbx.h); offsets from the accesses of
 *           sioopen/ttread/ttwrite/ttystart/ttyflush/ttyoutput/ttioctl:
 *   +00 t_inq (clist: c_cc 0, c_cf 2, c_cl 4)   +06 t_outq (clist)   +0C t_oproc (ttstart)
 *   +10 t_pgrp   +12 t_obuf   +14 t_dev   +18 t_erase (7F)   +19 t_kill (15H)   +1A t_flags (ECHO 8, CRMOD 10H, RAW 20H; default 518H)
 *   +1C..1F t_dnl/t_dcr/t_dtab/t_dvt (output delays)  +20 t_width +21 t_page  +22 t_intrc (03) +23 t_quitc (1C) +24 t_startc (11)
 *   +25 t_stopc (13) +26 t_eofc (1A) +27 t_brkc (FF)
 *   +28 t_state (TIMEOUT 1, WOPEN 2, ISOPEN 4, ... 10H connected, 80H exclusive, 100H output stopped, 400H stopped)
 *   +2A t_lstate (bit 0 input in progress, bit 1 output waits for a 0x80 character)  +2C t_cnt2c (lines since the last page stop),
 *   +2D t_col, +2E t_delct, +34 t_line  +36 t_ocnt  +38 t_hwp  +3A t_hwf
 *   Guessed / unresolved: +0E, +16, +30..+33 (fillers; accessed only in ttyinput/ttioctl, not yet reconstructed).
 * Deviations: whole struct tty (layout), flag values XTABS 02000 (V7: 006000; System III has no XTABS in head/sys/tty.h: the value is unattributed), the filler members, ENOTTY/EBUSY_ at the end.
 *           struct clist (V7 text; System III uses cblock pointers): pipe.c has its own identical copy; do not include both.
 */
#ifndef TTY_H
#define TTY_H
#include "types.h"
#include "mbx.h"
struct clist {
	int	c_cc;
	char	*c_cf;
	char	*c_cl;
};
struct tty {
	struct clist	t_inq;		/* 00 */
	struct clist	t_outq;		/* 06 */
	int		(*t_oproc)();	/* 0C */
	int		t_x0e;		/* 0E */
	int		t_pgrp;		/* 10 */
	char		*t_obuf;	/* 12 */
	dev_t		t_dev;		/* 14 */
	int		t_x16;		/* 16 */
	char		t_erase;	/* 18 */
	char		t_kill;		/* 19 */
	int		t_flags;	/* 1A */
	char		t_dnl;		/* 1C delay after NL (K7e: ttyoutput, case 10) */
	char		t_dcr;		/* 1D delay after CR (case 13) */
	char		t_dtab;		/* 1E tab delay (case 9); with XTABS also the column from which tabs were expanded (ttyoutput/ttyrub) */
	char		t_dvt;		/* 1F delay after VT/FF (case 11, 12) */
	char		t_width;	/* 20 line width (0 = unlimited; ttycol: 0 -> 255) */
	char		t_page;		/* 21 page length for the page stop (0 = off) */
	char		t_intrc;	/* 22 */
	char		t_quitc;	/* 23 */
	char		t_startc;	/* 24 */
	char		t_stopc;	/* 25 */
	char		t_eofc;		/* 26 end-of-file character (ttyinput) */
	char		t_brkc;		/* 27 */
	int		t_state;	/* 28 */
	int		t_lstate;	/* 2A */
	char		t_cnt2c;	/* 2C */
	char		t_col;		/* 2D current output column (ttyoutput) */
	char		t_delct;	/* 2E */
	char		t_x2f;		/* 2F */
	char		t_x30[4];	/* 30 */
	char		t_line;		/* 34 line discipline (ttioctl: linesw[t_line], 20 bytes per entry) */
	char		t_x35;		/* 35 */
	int		t_ocnt;		/* 36 */
	struct rkmbx	*t_hwp;		/* 38 */
	char		t_hwf;		/* 3A */
	char		t_x3b;		/* 3B */
};
extern struct tty ttyt[4];		/* A530 */
/* K7e: t_flags (V7 values, except XTABS) */
#define TANDEM	01
#define CBREAK	02
#define LCASE	04
#define ECHO	010
#define CRMOD	020
#define RAW	040
#define XTABS	02000
#define TIMEOUT	01
#define WOPEN	02
#define ISOPEN	04
#define CARR_ON	020
#define XCLUDE	0200
#define ENOTTY	25
#define EBUSY_	16
#endif
