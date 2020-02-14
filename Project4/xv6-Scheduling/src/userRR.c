#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "pstat.h"
#include "param.h"
int main(int argc , char **argv)
{
	if(argc != 5){
	   printf(2, "Wrong number of argument\n");
	   exit();
	}
	int pid = getpid();
	//printf(2, "Setting pid :%d\n",pid);
	setpri(pid,0);
        //printf(1,"%d\n", getpri(pid));
	for(int it = 0 ; it < atoi(argv[2]); it++) {
	    int c_pid = fork2(1);
	    printf(1,"iteration : %d, c_pid %d\n",it,c_pid);
	    if(c_pid == 0) {
	       for(int i=0; i < atoi(argv[4]);i++)
	       {
		    if(exec(argv[3], argv) == -1)
		    {
			  //printf(1,"Error\n");
		    }
		    //setpri(c_pid,1);
                    //exit();
		    printf(1,"%d, %d\n",c_pid,getpri(c_pid));
		   sleep(atoi(argv[1])); 
		   setpri(c_pid,2);
	      }  
	      kill(c_pid);
	   }
        }
    for(int i=0 ;i< atoi(argv[2]); i++)
    {
	   wait();
	   //exit();
     }
    exit();
}
