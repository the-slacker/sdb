#ifndef	SLACKER_H
	#define	SLACKER_H

/* stdc includes */
#include <stdlib.h>
#include <stdio.h>

/* outside library includes */
#include <ncurses.h>

/****************************************/
/*		STRUCTURES		*/
/****************************************/

/*		struct coords
 * defines integers 'x' and 'y' for various uses
 *
 * x		- x coordinate
 * y		- y coordinate
 */
struct coords {
	int x,y;
};

/*		struct winfo
 * holds information regarding a curses window such as:
 *
 * win		- WINDOW* of this window
 * dim		- dimensions
 * size		- size
 */
struct winfo {
	WINDOW* win;
	struct coords dim;
	struct coords size;
};

/*		struct win_group
 * groups subwindows of a greater window (or some other
 * purpose) into a single array, with count of windows in
 * array.
 *
 * background	-parent window of 'win' array
 * win		-array of [sub]windows
 * size		-size of the 'win' array
 */
struct win_group {
	struct winfo background;
	struct winfo* window;
	unsigned int size;
};

/*		struct win_panel
 * a panel of windows (a grouping of a group, like the CPU
 * window, etc etc etc) and its parent window used as its
 * background (from where the group of windows are derived)
 *
 * background	-parent window of 'group' array
 * group	-array of groups of windows
 * size		-size of the 'group' array
 */
struct win_panel {
	struct winfo background;
	struct win_group* group;
	unsigned int size;
};

#endif
