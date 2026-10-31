/*
 *  A rudimentary (but small) semaphore system.
 */

#include "../h/param.h"
#include "../h/dir.h"
#include "../h/user.h"

#define	SEMPRI	35	/* locking priority */

#define	NSEM	4	/* max no of semaphores (*8) */

#define	UNLOCK	0
#define	LOCK	1
#define LOCKIF	2
#define LOCKED	4

char semaphores[NSEM];

/*ARGSUSED*/
semclose(dev, flag)
dev_t dev;
{
	register n, sem;

	sem = minor(dev);
	if((n = (sem >> 3)) >= NSEM){
		u.u_error = ENXIO;
		return;
	}
	sem = 1 << (sem&07);
	semaphores[n] &= ~sem;
	wakeup(&semaphores[n]);
}

/*ARGSUSED*/
semioctl(dev, cmd, arg, flag)
dev_t dev;
caddr_t arg;
{
	register char *byte;
	register int n, sem;
	int status;

	sem = minor(dev);
	if((n = (sem >> 3)) >= NSEM){
		u.u_error = ENXIO;
		return;
	}
	byte = &semaphores[n];
	sem = 1 << (sem&07);
	spl7();
	if(*byte&sem)
		status = 1;
	else
		status = 0;
	switch(cmd){
	case UNLOCK:
		*byte &= ~sem;
		wakeup(byte);
		break;
	case LOCK:
		while(*byte&sem)
			sleep(byte, SEMPRI);
	case LOCKIF:
		*byte |= sem;
	}
	spl0();
	if(copyout((caddr_t)&status, arg, sizeof(status)))
		u.u_error = EFAULT;
}
