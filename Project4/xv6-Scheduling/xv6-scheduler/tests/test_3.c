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

  int i;

  for (i = 0; i < 1; i++) {
    int c_pid = fork();
   
    // Child
    if (c_pid == 0) {
      exit();
    } else {
      int pri = getpri(c_pid);
      int new_pri;
      if(pri == 1){
	setpri(c_pid, 2);
      }else{
	setpri(c_pid, 1);
      }
      new_pri = getpri(c_pid);
      
      if( new_pri != pri && (new_pri >= 0 && new_pri <=3)){
	printf(1, "XV6_SCHEDULER\t SUCCESS\n");
      }else if (new_pri == pri){
	printf(1, "XV6_SCHEDULER\t setpri() FAILED\n");
    }

    }
  }

  for (i = 0; i < 1; i++) {

    wait();
  }


  exit();
}
