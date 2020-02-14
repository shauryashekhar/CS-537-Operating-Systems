#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"


#define DDEBUG 1

#ifdef DDEBUG
# define DEBUG_PRINT(x) printf x
#else
# define DEBUG_PRINT(x) do {} while (0)
#endif


int
main(int argc, char *argv[])
{
  int error = 0;
  char *args[1];
  args[0] = "loop";

  int c_pid = fork();
  if(c_pid == 0){
    error = exec("loop", args);
    
    if( error == -1 ){
      printf(1, "XV6_SCHEDULER\t loop either did not exist or was not callable as specifcied in assignment\n");
    }
    exit();
  }else{
    //printf(1, "Sleep\n");
    //sleep(8);
  }

  
  //printf(1, "kill\n");
  kill(c_pid);
  wait();
  exit();
}
