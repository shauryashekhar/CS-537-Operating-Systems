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
  int c_pid[2];
  c_pid[0] = -1;
  c_pid[1] = -1;
  int c_pri[2];
  int c_newpri[2];
  c_newpri[0] = -1;
  c_newpri[1] = -1;
  c_pri[0] = 0;
  c_pri[1] = 1;
  for (i = 0; i < 2; i++) {
    c_pid[i] = fork2(c_pri[i]);
   
    // Child
    if (c_pid[i] == 0) {
      exit();
    } else {
      getpinfo(&st);
      for(int j = 0; j < NPROC; j++){
	if(st.pid[j] == c_pid[0]){
	  c_newpri[0] = st.priority[j]; 
	} else if(st.pid[j] == c_pid[1]){
	  c_newpri[1] = st.priority[j];
	}
      }
    }
  }

  if(c_newpri[0] == c_pri[0] && c_newpri[1] == c_pri[1]){
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  }else{
    printf(1, "XV6_SCHEDULER\t getpinfo FAILED to properly udpate process info\n");
  }
  
  for (i = 0; i < 2; i++) {
    wait();
  }


  exit();
}
