/* types.h -- basic types of the MUTOS kernel (non-segmented U8002-style kernel: int = pointer = 16 bits).
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/h/param.h (typedef block: daddr_t, caddr_t, ino_t, time_t, label_t, dev_t, off_t);
 *           cnt_t is from UNIX System III (head/sys/types.h) and is currently unused.
 * Evidence: measured widths: dev_t int, daddr_t long, ino_t unsigned, time_t/off_t long, pointers 16 bits;
 *           label_t = 9 words (u_segflg at u+12h, struct user).  H2 file similarity 29% (V7 keeps the types in param.h).
 * Deviations: V7 puts the typedefs in param.h; MUTOS has a separate types.h (so that headers can include it alone).
 *           label_t is int[9] (V7/PDP-11: int[6], regs 2-7).  physadr is not defined (no device registers in this kernel).
 *           NULL is defined here (V7: param.h).
 */
#ifndef TYPES_H
#define TYPES_H
typedef	long       	daddr_t;  	/* disk address */
typedef	char *     	caddr_t;  	/* core address */
typedef	unsigned int	ino_t;     	/* i-node number */
typedef	long       	time_t;   	/* a time */
typedef	int        	label_t[9]; 	/* program status; 9 words (measured, u_segflg at u+12h) */
typedef	int        	dev_t;    	/* device code */
typedef	long       	off_t;    	/* offset in file */
typedef	char		cnt_t;		/* reference count (System III; unused) */
#define	NULL	0
#endif
