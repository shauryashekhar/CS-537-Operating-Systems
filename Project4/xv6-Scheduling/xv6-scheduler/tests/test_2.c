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
  char *args[5];
  args[0] = "userRR";
  args[1] = "5";
  args[2] = "3";
  args[3] = "loop";
  args[4] = "2";

  int c_pid = fork();
  if(c_pid == 0){
    error = exec("userRR", args);
    if( error == -1 ){
      printf(1, "XV6_SCHEDULER\t userRR either did not exist or was not callable as specifcied in assignment\n");
    }
    exit();
  }else{
    wait();
  }
    exit();
}
