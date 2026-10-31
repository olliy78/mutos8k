/* dir.h -- directory entry.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/dir.h.
 * Evidence: measured; identical text apart from the include and the guard; 16 bytes (u_dent: d_ino 42, d_name 44 in struct user).
 * Deviations: includes param.h for DIRSIZ (V7 code includes param.h before dir.h).
 */
#ifndef DIR_H
#define DIR_H
#include "param.h"
#ifndef	DIRSIZ
#define	DIRSIZ	14
#endif
struct	direct
{
	ino_t	d_ino;
	char	d_name[DIRSIZ];
};
#endif
