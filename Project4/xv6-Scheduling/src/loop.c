#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, char **argv)
{
	sleep(10);
	int pid = getpid();
	printf(1,"loop called, pid %d\n",pid);
        exit();
	return pid;
}
