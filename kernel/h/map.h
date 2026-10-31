/* map.h -- resource map entry (core and swap allocation, malloc/mfree).
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/map.h.
 * Evidence: assumed from the structure of malloc (2DF0, first fit with m_size/m_addr); not measured at the member level.
 *           H2 file similarity only 28% because V7 defines the two tables here, MUTOS declares them.
 * Deviations: coremap/swapmap are only declared (extern); the definitions (with CMAPSIZ/SMAPSIZ entries) are in a .c file.
 */
#ifndef MAP_H
#define MAP_H
struct map
{
	short	m_size;
	unsigned short m_addr;
};

extern struct map coremap[];	/* space for core allocation */
extern struct map swapmap[];	/* space for swap allocation */
#endif
