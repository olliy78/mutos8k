/* mbx.h -- mailbox entry shared with the U880 side (mutos_io), 14 bytes; draft 39 sect. 11.
 *
 * Origin:   none
 * Source:   none (MUTOS specific: the A5120.16 U880 I/O processor interface).
 * Evidence: measured in rkstart (6B60), ttxfer (633A), lpxfer (690A).  The disk mailbox is fixed at D532; there is one
 *           entry per tty line from D26A (14 bytes per line), one per printer from D516.  mb_stat doubles as the
 *           "line ready" flag for tty/lp (the kernel sets 1 after issuing the request).
 * Deviations: whole file.
 */
#ifndef MBX_H
#define MBX_H
#include "types.h"
struct rkmbx {
	char		mb_cmd;		/* +00 command (0 disk, 2 printer, 4 terminal) */
	char		mb_unit;	/* +01 unit / sub device */
	char		mb_dir;		/* +02 direction (0 read, 1 write; console 81H) */
	char		mb_stat;	/* +03 status */
	int		mb_seg;		/* +04 segment */
	char		*mb_addr;	/* +06 */
	unsigned	mb_cnt;		/* +08 */
	daddr_t		mb_blk;		/* +0A */
};
#endif
