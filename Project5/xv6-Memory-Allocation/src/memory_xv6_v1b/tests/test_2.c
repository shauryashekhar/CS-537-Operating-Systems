#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    int numframes = 130;
    int* frames = malloc(numframes * sizeof(int));
    int* pids = malloc(numframes * sizeof(int));
    int flag = dump_physmem(frames, pids, numframes);
    
    int pidd = fork();
    if(pidd==0){
	if(flag == 0)
    	{
        for (int i = 0; i < numframes; i++)
          if(*(pids+i) >-3)
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
    	}
	}
	    
	    if(pidd>0) wait();
    wait();
    exit();
}
