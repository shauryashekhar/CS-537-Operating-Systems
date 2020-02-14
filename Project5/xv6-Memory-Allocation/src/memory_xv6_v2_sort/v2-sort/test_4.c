#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
	//int cid;
	/*int p[2] = {0,0};
	int p1[2] = {0,0};
	char buf[16];
	if(pipe(p) != 0 || pipe(p1) != 0){
		printf(1, "pipe() failed\n");
		exit();
	}*/

	int numframes = 10;
	int* frames = malloc(numframes * sizeof(int));
	int* pids = malloc(numframes * sizeof(int));
	//cid = fork();
	//if(cid == 0)
	//{//Child Process
		fork();
		wait();
		int flag = dump_physmem(frames, pids, numframes);

		if(flag == 0)
		{
			for (int i = 0; i < numframes; i++)
				//if(*(pids+i) > 0)
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
		}
		else// if(flag == -1)
		{
			printf(1,"error\n");
		}

		/*write(p[1], "Y", 1);
		read(p1[0], buf, 1);
		close(p[0]);
		close(p[1]);
		close(p1[0]);
		close(p1[1]);*/
		//exit();
		
	//}
	/*else

	{
		//read(p[0], buf, 1);
		wait();
		int flag2 = dump_physmem(frames, pids, numframes);

		if(flag2 == 0)
		{     
			for (int i = 0; i < numframes; i++)
				//if(*(pids+i) > 0)
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
		}   
		else// if(flag == -1)
		{
			printf(1,"error\n");
		}
		//write(p1[1], "Y", 1);
	}*/
	exit();
}
