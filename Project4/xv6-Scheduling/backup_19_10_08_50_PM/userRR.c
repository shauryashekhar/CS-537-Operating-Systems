#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
char *argvv[] = { "loop", 0 };
int main(int argc , char **argv)
{
	if(argc != 5){
	   printf(2, "Wrong number of argument\n");
	   exit();
	 }
	int pid = getpid();
	printf(2, "Setting pid :%d\n",pid);
	setpri(pid,0);
        printf(1,"%d\n", getpri(pid));
	//char *localArg[1];
	//localArg[0]= "";
	//arg[1]= "3";
	//int jc = 1;
	for(int it = 0 ; it < *argv[2]; it++) {
	    int c_pid = fork2(2);
	    if(c_pid == 0) {
	       for(int i=0; i < *argv[4];i++)
	       {
		    if(exec("loop", argvv) == -1)
		    {
			  printf(1,"Error\n");
		    }
		    setpri(c_pid,1);
		    printf(1,"%d, %d\n",c_pid,getpri(c_pid)); 
	      }  
	   }
        }   
    exit();

}
