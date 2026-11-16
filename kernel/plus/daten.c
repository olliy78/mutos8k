/* daten.c -- initialised data of the kernel that has no other home (plan 47 P2.2, branch mutos-plus).
 *
 * Replaces the hand-written assembler modules dn0.s..dn3.s (extracted from mutos_1216, original addresses in the comments).
 * Link order: after conf.o/sysent.o, before bss.o -- the same place as dn0..dn3, same total size (44 bytes).
 * Values are copied byte for byte from dn*.s; references are names, not numbers.
 * K&R C for the MUTOS cc: external names are significant to 8 characters (_max_pro, _szicode, _cf_8c94 fit). */
#include "param.h"
#include "proc.h"

extern char conlog[];			/* console log ring (BSS) */

/* dn0: register index table of setregs (sys1.c) */
char regloc[8] = { 0, 1, 2, 3, 4, 5, 6, 7 };	/* 88CC */

/* dn1: end pointer of the used part of the process table = &proc[2] (a reference, not the number A154) */
struct proc *max_proc = &proc[2];		/* 8A8C */

/* dn2: first user program, copied to user address 0 by main().  Machine code of the Z8001:
 * ld r0,#10; ld r1,#0C; sc #11 (exec); jr -1; then argv: pointer 0010, 0000, and the string "/etc/init" at 0010. */
char icode[26] = {
	0x21, 0x00, 0x00, 0x10, 0x21, 0x01, 0x00, 0x0C,
	0x7F, 0x0B, 0xE8, 0xFF, 0x00, 0x10, 0x00, 0x00,
	'/', 'e', 't', 'c', '/', 'i', 'n', 'i', 't', 0
};						/* 8B32 */
int szicode = 26;				/* 8B4C */

/* dn3 */
int cf_8c94 = 4;				/* 8C94 number of terminals (nkl11 of ps/pstat via cf_nlist[3]) */
char *conptr = conlog;				/* 8C96 write pointer in the console log ring */
int nlp = 1;					/* 8C98 number of printers */
