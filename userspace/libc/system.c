#include	<signal.h>

system(s)
char *s;
{
	int status;
	register int (*istat)(), (*qstat)();
	/* Differs from V7: pid and w are register variables too (R11, R10) */
	register int pid, w;

	if ((pid = fork()) == 0) {
		execl("/bin/sh", "sh", "-c", s, 0);
		_exit(127);
	}
	istat = signal(SIGINT, SIG_IGN);
	qstat = signal(SIGQUIT, SIG_IGN);
	while ((w = wait(&status)) != pid && w != -1)
		;
	if (w == -1)
		status = -1;
	signal(SIGINT, istat);
	signal(SIGQUIT, qstat);
	return(status);
}
