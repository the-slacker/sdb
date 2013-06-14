#include "slacker.h"
#include "interface.h"

int parse_args(int argc, char* argv[]);

int main(int argc, char* argv[])
{
	parse_args(argc, argv);
	interface_start();
	while(1) {
		interface_refresh();
	}
	interface_stop();
	return 0;
}

int parse_args(int argc, char* argv[])
{
	return 0;
}

