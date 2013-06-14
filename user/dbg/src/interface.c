#include "slacker.h"
#include "interface.h"

int start_curses(void);
int stop_curses(void);


int interface_start(void)
{
	start_curses();
	interface.win = stdscr;
	getmaxyx(stdscr,
		interface.size.y,
		interface.size.x);
	return 0;
}

int interface_stop(void)
{
	stop_curses();
	return 0;
}

int interface_refresh(void)
{
	int i,j;
	for(i = 0; i < current.size; i++) {
		struct win_group this_group = current.group[i];
		for(j = 0; j < this_group.size; j++) {
			wnoutrefresh(this_group.window[j].win);
		}
	}
	wnoutrefresh(stdscr);
	doupdate();
	return 0;
}

int start_curses(void)
{
	initscr();
	cbreak();
	noecho();
	nonl();
	intrflush(stdscr, FALSE);
	keypad(stdscr, TRUE);
	if(has_colors() == TRUE) {
		start_color();
		if(COLOR_PAIRS-1 > 9) {
			init_pair(COLOR_BACKGROUND, COLOR_WHITE, COLOR_BLUE);
			init_pair(COLOR_HIGHLIGHT, COLOR_BLUE, COLOR_WHITE);
		}
	}
	return 0;
}

int stop_curses(void)
{
	return 0;
}
