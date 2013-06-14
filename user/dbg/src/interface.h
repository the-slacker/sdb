#ifndef	INTERFACE_H
	#define	INTERFACE_H

int interface_start(void);
int interface_stop(void);
int interface_refresh(void);

/* holds the ultra top most parent info (usually stdscr) */
struct winfo interface;
/* currently displayed window interface (i.e. CPU, MEMVIEW, etc) */
struct win_panel current;

/* fg := white; bg := blue */
#define COLOR_BACKGROUND	1
/* fg := blue; bg := white */
#define COLOR_HIGHLIGHT		2

#endif
