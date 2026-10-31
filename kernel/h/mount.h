/* mount.h -- mount table entry.
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/mount.h.
 * Evidence: measured; same members in the same order (H2 file similarity 63%, the rest is comments); layout 6 bytes,
 *           5 entries from A07E (iget searches m_inodp).
 * Deviations: the table is only declared here (extern, NMOUNT entries defined in a .c file) instead of defined in the header.
 */
#ifndef MOUNT_H
#define MOUNT_H
/*
 * Mount structure.
 * One allocated on every mount.
 * Used to find the super block.
 */
struct	mount
{
	dev_t	m_dev;		/* device mounted */			/* +0 */
	struct buf *m_bufp;	/* pointer to superblock */		/* +2 */
	struct inode *m_inodp;	/* pointer to mounted on inode */	/* +4 */
};
extern struct mount mount[];
#endif
