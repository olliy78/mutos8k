#include "uucp.h"
#include <signal.h>

/* static char sccs[] = "@(#)xqt.c	1.1 4/11/86"; */


/*******
 *	xuucico(rmtname)		start up uucico for rmtname
 *	char *rmtname;
 *
 *	return codes:  none
 */

xuucico(what) char *what; {
	char buf[100];
	if(fork() == 0) {
		close(0);
		close(1);
		close(2);
		open("/dev/null", 0);
		open("/dev/null", 1);
		open("/dev/null", 1);
		signal(SIGHUP, SIG_IGN);
		signal(SIGINT, SIG_IGN);
		signal(SIGQUIT, SIG_IGN);
		if(what[0] != '\0')  sprintf(buf, "-s%.7s", what);
		else buf[0] = '\0';
		execl(UUCICO, "UUCICO", "-r1", buf, NULL);
		exit(101);
	}
}

/*******
 *	xuucico(rmtname)		start up uucico for rmtname
 *	char *rmtname;
 *
 *	return codes:  none
 */

xuuxqt() {
	if(fork() == 0) {
		close(0);
		close(1);
		close(2);
		open("/dev/null", 2);
		open("/dev/null", 2);
		open("/dev/null", 2);
		signal(SIGHUP, SIG_IGN);
		signal(SIGINT, SIG_IGN);
		signal(SIGQUIT, SIG_IGN);
		execl(UUXQT, "UUXQT", NULL);
		exit(102);
	}
}

xuucp(what) char *what; {
	char buf[300];
	if(fork() == 0) {
		close(0);
		close(1);
		close(2);
		open("/dev/null", 0);
		open("/dev/null", 1);
		open("/dev/null", 1);
		signal(SIGHUP, SIG_IGN);
		signal(SIGINT, SIG_IGN);
		signal(SIGQUIT, SIG_IGN);
		sprintf(buf,"%s -r %s", UUCP, what);
		execl(SHELL, "sh", "-c", buf, NULL);
		exit(103);
	}
	sleep(15);
}
