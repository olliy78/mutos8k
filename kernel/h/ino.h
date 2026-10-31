/* ino.h -- inode as it appears on a disk block.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/ino.h.
 * Evidence: measured; H2 file similarity 84% V7; dinode 64 bytes (di_atime +34h, mtime +38h, ctime +3Ch), used by
 *           iexpand/iupdat/ialloc/stat1.
 * Deviations: none (apart from the include guard).
 */
#ifndef INO_H
#define INO_H
/*
 * Inode structure as it appears on
 * a disk block.
 */
struct dinode
{
	unsigned short	di_mode;     	/* mode and type of file */
	short	di_nlink;    	/* number of links to file */
	short	di_uid;      	/* owner's user id */
	short	di_gid;      	/* owner's group id */
	off_t	di_size;     	/* number of bytes in file */
	char  	di_addr[40];	/* disk block addresses */
	time_t	di_atime;   	/* time last accessed */
	time_t	di_mtime;   	/* time last modified */
	time_t	di_ctime;   	/* time created */
};
#define	INOPB	8	/* 8 inodes per block */
/*
 * the 40 address bytes:
 *	39 used; 13 addresses
 *	of 3 bytes each.
 */
#endif
