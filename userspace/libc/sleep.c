#include <signal.h>
#include <setjmp.h>

static jmp_buf jmp;

sleep(n)
unsigned n;
{
	int sleepx();
	/* Differs from V7: both locals are register variables (altime R13, alsig R12) */
	register unsigned altime;
	register int (*alsig)() = SIG_DFL;

	if (n==0)
		return;
	altime = alarm(1000);	/* time to maneuver */
	if (setjmp(jmp)) {
		signal(SIGALRM, alsig);
		alarm(altime);
		return;
	}
	if (altime) {
		if (altime > n)
			altime -= n;
		else {
			n = altime;
			altime = 1;
		}
	}
	alsig = signal(SIGALRM, sleepx);
	alarm(n);
	for(;;)
		pause();
	/*NOTREACHED*/
}

static
sleepx()
{
	longjmp(jmp, 1);
}
