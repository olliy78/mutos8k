#include "uucp.h"
#include <sys/types.h>
#include <sys/stat.h>

/* static char sccs[] = "@(#)anyread.c	1.1 4/11/86"; */

/*******
 *	anyread		check if anybody can read
 *	return 0 ok: FAIL not ok
 */

int anyread(file) char *file; {
	struct stat s;

	if (stat(file, &s) != 0)
		/* for security check a non existant file is readable */
		return(0);
	if (!(s.st_mode & ANYREAD))
		return(FAIL);
	return(0);
}
