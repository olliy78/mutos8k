/* Signal delivery test (AP H8): handler runs on the user stack built by sendsig(), returns through the
 * libc stub (signal.o) and sc #0 -> sigret().  n = signal number seen, cnt = number of deliveries,
 * where = address of a local variable of the handler (shows that the handler runs on the user stack). */
int n, cnt;
int *where;

catch(s)
int s;
{
	int loc;

	n = s;
	cnt++;
	where = &loc;
	signal(15, catch);	/* V7: the action is reset to SIG_DFL on delivery */
}

main()
{
	int i, j, pid;

	signal(15, catch);
	pid = getpid();
	i = 12345;
	j = 54321;
	kill(pid, 15);
	kill(pid, 15);
	printf("AFTER n=%d cnt=%d i=%d j=%d loc=%x\n", n, cnt, i, j, where);
	printf("SIGDONE\n");
}
