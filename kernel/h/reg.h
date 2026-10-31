/* reg.h -- register names for the trap frame.
 *
 * Origin:   none
 * Source:   none.  V7 reg.h gives the PDP-11 locations of the saved user registers relative to R0 (u.u_ar0[R0] ...);
 *           the Z8000 register numbers below are placeholders for later modules (trap.c, sig.c).
 * Evidence: H2 found no common fingerprint with V7 (different CPU).  UNMEASURED: the layout of the trap frame
 *           (trapent 030E) is not resolved; sig.c uses u_ar0[10] (PS) and u_ar0[12] (PC) as raw indexes.
 * Deviations: whole file.
 */
#ifndef REG_H
#define REG_H
#define R0	0
#define R1	1
#define R2	2
#define R3	3
#define R4	4
#define R5	5
#define R6	6
#define R7	7
#define R8	8
#define R9	9
#define R10	10
#define R11	11
#define R12	12
#define R13	13
#define R14	14
#define R15	15
#endif
