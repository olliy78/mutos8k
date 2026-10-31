#include "uucp.h"

/* static char sccs[] = "@(#)gwd.c	1.1 4/11/86"; */

/*******
 *	gwd(wrkdir)	get working directory
 *
 *	return codes  0 | FAIL
 */

gwd(wrkdir)
char *wrkdir;
{
	FILE *fp;
	extern FILE *popen();
	extern int pclose();
	char *c;

	*wrkdir = '\0';
	if ((fp = popen("pwd", "r")) == NULL)
		return(FAIL);
	if (fgets(wrkdir, 100, fp) == NULL) {
		pclose(fp);
		return(FAIL);
	}
	if (*(c = wrkdir + strlen(wrkdir) - 1) == '\n')
		*c = '\0';
	pclose(fp);
	return(0);
}
