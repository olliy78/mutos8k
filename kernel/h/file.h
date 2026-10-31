/* file.h -- open file table entry.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/file.h (struct file with the f_un union, flags).
 * Evidence: measured; H2 file similarity 47% (before AP H4: f_off and a #define f_offset instead of f_un.f_offset);
 *           layout checked against the kernel: 8 bytes, table 9EEE..A07E (50 entries); f_flag +0, f_count +1,
 *           f_offset +4 (long); closef passes the word at +4 as third parameter to close (f_chan, V7 multiplexor).
 * Deviations: f_inode (+2) not individually read in the kernel (V7 order); the table is declared "file[]" only (defined in a .c file).
 */
#ifndef FILE_H
#define FILE_H
#include "types.h"
/*
 * One file structure is allocated
 * for each open/creat/pipe call.
 * Main use is to hold the read/write
 * pointer associated with each open
 * file.
 */
struct	file
{
	char	f_flag;			/* +0 */
	char	f_count;	/* reference count */	/* +1 */
	struct inode *f_inode;	/* pointer to inode structure */	/* +2 */
	union {								/* +4 */
		off_t	f_offset;	/* read/write character pointer */
		struct chan *f_chan;	/* mpx channel pointer */
	} f_un;
};

extern struct file file[];	/* The file table itself */

/* flags */
#define	FREAD	01
#define	FWRITE	02
#define	FPIPE	04
#define FMPX	010
#define	FMPY	020
#define	FMP	030
#define	FKERNEL	040
#endif
