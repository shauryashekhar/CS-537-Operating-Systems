#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

#define check(exp, msg) if(exp) {} else {\
  printf(1, "%s:%d check (" #exp ") failed: %s\n", __FILE__, __LINE__, msg);\
  ;}

#define DDEBUG 1

#ifdef DDEBUG
# define DEBUG_PRINT(x) printf x
#else
# define DEBUG_PRINT(x) do {} while (0)
#endif


int
main(int argc, char *argv[])
{
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");

  int pret;

  int c_pid = fork();
  if(c_pid == 0){
    exit();
  }else{
    pret = setpri(c_pid, -1);
    
    if( pret == -1){
      printf(1, "XV6_SCHEDULER\t SUCCESS\n");
    } else{
      printf(1, "XV6_SCHEDULER\t setpri FAILED to return the correct error return code\n");
      exit();
    }
  }

  wait();
  
  exit();
}
