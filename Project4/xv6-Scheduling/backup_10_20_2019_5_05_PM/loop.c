#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, char **argv)
{
	sleep(100);
        printf(1,"loop called\n");
	int pid = getpid();
	return pid;
}
