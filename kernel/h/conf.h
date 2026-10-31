/* conf.h -- device switches.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/conf.h (bdevsw, cdevsw); linesw has the System III names (head/sys/conf.h: l_open .. l_output),
 *           not the V7 names; struct devtab is MUTOS specific (V7 and System III in original/ have no struct devtab: V7 uses
 *           struct buf as the head of the device queue; the name devtab/d_active/d_errcnt/d_actf/d_actl is 2BSD style, assumed).
 * Evidence: measured: bdevsw 8 bytes per entry (open, close, strategy, d_tab), table 8766; cdevsw 14 bytes per entry (open, close,
 *           read, write, ioctl, stop, tty), table 8796 (conf.c data bytes 8766..88C5 equal, K6a); linesw 20 bytes per entry
 *           (ttioctl: MULT #20; table 8868, one entry, the last three words are 0).  devtab: only as far as getblk uses it
 *           (b_forw/b_back at the same offsets as in struct buf).  H2 file similarity 55% V7 / 63% System III.
 * Deviations: bdevsw d_tab is "struct devtab *" (V7: "struct buf *" with the iobuf head cast); linesw has l_open, l_close, l_read,
 *           l_write, l_ioctl, l_input, l_output, l_x[3] (System III: l_mdmint instead of l_x[0..2];
 *           V7: l_rint, l_rend, l_meta, l_start, l_modem; V7 l_write returns char *);
 *           the switches are declared "extern struct ... name[]" separately.
 */
#ifndef CONF_H
#define CONF_H
/*
 * Declaration of block device
 * switch. Each entry (row) is
 * the only link between the
 * main unix code and the driver.
 * The initialization of the
 * device switches is in the
 * file conf.c.
 */
struct bdevsw
{
	int	(*d_open)();
	int	(*d_close)();
	int	(*d_strategy)();
	struct devtab *d_tab;
};

/*
 * Character device switch.
 */
struct cdevsw
{
	int	(*d_open)();
	int	(*d_close)();
	int	(*d_read)();
	int	(*d_write)();
	int	(*d_ioctl)();
	int	(*d_stop)();
	struct tty *d_ttys;
};

/*
 * tty line control switch (K7e: 20 bytes per entry, System III names).
 */
struct linesw
{
	int	(*l_open)();
	int	(*l_close)();
	int	(*l_read)();
	int	(*l_write)();
	int	(*l_ioctl)();
	int	(*l_input)();
	int	(*l_output)();
	int	l_x[3];
};
extern struct linesw	linesw[];
extern struct bdevsw	bdevsw[];
extern struct cdevsw	cdevsw[];

/*
 * Device table (V7: struct iobuf): head of the buffer list of a device; layout only as far as getblk uses it.
 */
struct devtab {
	char		d_active;
	char		d_errcnt;
	struct buf	*b_forw;
	struct buf	*b_back;
	struct buf	*d_actf;
	struct buf	*d_actl;
};
#endif
