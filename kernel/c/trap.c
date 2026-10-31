/* trap.c -- trap and system call entry in C (kernel mutos_1216, 087A..0B3A): trap, nosys, nullsys.
 *
 * Origin:   partial
 * Source:   UNIX V7 usr/sys/sys/trap.c.  The frame of trap() (what the entry code at 030E saves), the case labels and the
 *           tail "out:" (issig/psig, setpri, qswtch, addupc, restfp) follow V7; nosys and nullsys are V7 text.  The trap types, the
 *           register frame, the system call argument fetch and the parity / random interrupt messages are Z8001 specific and
 *           MUTOS own (V7: PDP-11 traps, args fetched through fuiword from the instruction stream).  System III PDP-11
 *           uts/pdp11/os/trap.c is closer to V7 than to MUTOS in these parts; no System III feature is present.
 * Evidence: measured with tools/herkunft/herkunft.py (level abs): trap 48% against V7 (System III 32%), nosys and nullsys 100%
 *           (V7 = System III for nullsys); file similarity 46% (V7), 29% (System III).
 * Roundtrip: cc -O in the guest, per function against mutos_1216; see doc/herkunft/trap.md.
 * Deviations: trap(): see the V7 comments before each case and doc/herkunft/trap.md.  nosys keeps the unused register variable
 *           (needed for the same prologue; V7 has none).
 *
 * The entry itself (trapent 030E) is assembler.  Frame at the call of trap (r14 relative): dev 4, ident 6, then the saved register
 * frame from 8 on (u.u_ar0 = &r0): ar0[8] = user SP (18h), FCW 1Ch, segment PC 1Eh, PC 20h.  Bit 14 of the FCW = system mode
 * (if clear, USER (16) is added to dev), bit 7 = C flag (error indication like EBIT in V7), bit 11 cleared on single step.
 * Cases of dev (10..31): 10/26 parity, 11/27 parity II, 15/31 unexpected interrupt, 16 bus error signal, 17 instruction emulation
 * (F009), 18 privileged instruction (ident = opcode 7C04..06), 19 single step, 22 SYSTEM CALL, 25 segment fault (stack growth),
 * 28 nothing.
 * Data: nested = 88E0, argp = 88E2 (holds FC9E = u.u_arg), texts 88E4 "parity during ", 8920.., 8969, 8990, 8997, 89C3,
 * sysent = 8B58 (4 bytes per entry), jump table of the cases 88F4.  Floating point: savfp 03F8 / restfp 03FE (assembler). */
#include "param.h"
#include "systm.h"
#include "dir.h"
#include "user.h"
#include "proc.h"
#include "reg.h"

#define USER	16
#define EBIT	0200

int nested;
int *argp = u.u_arg;

struct blk4 {
	int	w[4];
};

/*
 * Called from the trap entry (030E) when a processor trap occurs.
 * The arguments are the words saved on the system stack
 * by the hardware and software during the trap processing.
 * dev is the kind of trap that occurred.
 * (V7 comment; MUTOS: dev, ident and the frame as described above.)
 */
/* KERNEL 087A */
trap(dev, ident, r0, r1, r2, r3, r4, r5, r6, r7, sp, xx, ps, pcseg, pc)
register unsigned ident;
{
	register i, a;
	register struct sysent *callp;
	register t;
	struct blk4 *rp;
	int tt;
	time_t syst;

	syst = u.u_stime;
	u.u_fpsaved = 0;
	if ((ps & 0x4000) == 0)
		dev |= USER;
	u.u_ar0 = &r0;
	switch (dev & 0xFF) {
	/*
	 * Trap not expected.
	 * Usually a kernel mode bus error.
	 * (V7 prints ka6, aps, pc, ps and the trap type; MUTOS prints
	 * seg, aps, pc and ps, the trap type and ident.)
	 */
	default:
		if (nested)
			for (;;)
				;
		nested++;
		printf("seg = %x\n", 0);
		printf("aps = %x\n", &ps);
		printf("pc = %x %x   ps = %x\n", pcseg, pc, ps);
		printf("trap type %x\n", dev);
		printf("ident = %x\n", ident);
		panic("trap");

	case 0+USER: /* bus error */
		i = SIGBUS;
		break;

	/*
	 * If illegal instructions are not
	 * being caught and the offending instruction
	 * is the floating point probe (V7: SETD, MUTOS: F009),
	 * the trap is ignored.
	 */
	case 1+USER: /* illegal instruction */
		pc += 2;
		if (fuword(pc-4) == 0xF009 && u.u_signal[SIGILL] == 0)
			goto out;
		i = SIGILL;
		break;

	case 2+USER: /* privileged instruction used as bpt, iot, emt (MUTOS: 7C04..06) */
		if (ident == 0x7C06)
			i = SIGTRAP;
		else if (ident == 0x7C04)
			i = SIGEMT;
		else if (ident == 0x7C05)
			i = SIGIOT;
		else
			i = SIGILL;
		break;

	case 3+USER: /* trace (V7: bpt or trace) */
		i = SIGTRAP;
		ps &= ~0x0800;
		break;

	case 6+USER: /* sys call */
		u.u_error = 0;
		ps &= ~EBIT;
		a = pc;
		callp = &sysent[ident & 077];
		if (callp == sysent) {
			sigret();
			goto out;
		}
		rp = (struct blk4 *)u.u_ar0;
		*(struct blk4 *)argp = *rp;
		u.u_dirp = (caddr_t)u.u_arg[0];
		u.u_r.r_val1 = u.u_ar0[4];
		u.u_r.r_val2 = u.u_ar0[5];
		u.u_ap = u.u_arg;
		if (save(u.u_qsav)) {
			if (u.u_error == 0)
				u.u_error = EINTR;
		} else
			(*callp->sy_call)();
		if (u.u_error) {
			ps |= EBIT;
			u.u_ar0[4] = u.u_error;
			u.u_ar0[5] = u.u_deverr;
		} else {
			u.u_ar0[4] = u.u_r.r_val1;
			u.u_ar0[5] = u.u_r.r_val2;
		}
		goto out;

	/*
	 * If the user SP is below the stack segment,
	 * grow the stack automatically.
	 * (V7: relies on the hardware restarting a half executed
	 * instruction; MUTOS: backup() and grow() with the saved SP.)
	 */
	case 9+USER: /* segmentation exception */
		a = sp;
		if (backup(u.u_ar0) == 0)
			if (grow(a))
				goto out;
		i = SIGSEG;
		break;

	/*
	 * V7: the half-hearted attempt to do something with the
	 * 11/70 parity registers.  MUTOS: message and signal / panic.
	 */
	case 10:
	case 10+USER:
		printf("%s running - segment = %x offset = %x\n", "parity during ", pcseg, pc);
		if (dev & USER)
			goto sigbus;
		panic("parity");

	case 11:
	case 11+USER:
		i = ident >> 14;
		t = (ident << 2) & 0xF600;
		printf("%s waiting - segment = %x offset = %x + ??\n", "parity during ", i, t);
		goto out;

	/*
	 * Locations 0-2 specify this style trap, since
	 * DEC hardware often generates spurious
	 * traps through location 0.  (V7 comment; MUTOS: unexpected
	 * interrupt, message with ident.)
	 */
	case 15:
	case 15+USER:
		printf("Random interrupt (ident = %x) ignored\n", ident);
		goto out;

	/*
	 * Allow process switch
	 */
	case 12+USER:
		goto out;
	}
	psignal(u.u_procp, i);
out:
	if (issig())
		psig();
	curpri = setpri(u.u_procp);
	if (runrun)
		qswtch();
	if (u.u_prof.pr_scale)
		addupc(pc, &u.u_prof, (int)(u.u_stime - syst));
	if (u.u_fpsaved)
		restfp(u.u_fparea);
	return;
sigbus:
	i = SIGBUS;
	psignal(u.u_procp, i);
	goto out;
}

/*
 * nonexistent system call-- set fatal error code.
 */
/* KERNEL 0B2A */
nosys()
{
	register i;

	u.u_error = EINVAL;
}

/*
 * Ignored system call
 */
/* KERNEL 0B38 */
nullsys()
{
}
