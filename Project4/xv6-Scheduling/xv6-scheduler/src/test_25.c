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

//char buf[10000]; // ~10KB
int workload(int n, int t) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
  }

  if (t > 0) sleep(t);
  for (i = 0; i < n; i++) {
    j += i * j + 1;
  }
  return j;
}

int
main(int argc, char *argv[])
{
  struct pstat st;
  int children[5];
  
  for (int i = 0; i < 5; ++i) {
    int pid = fork2(2);
    if (pid == 0) {
      workload(80000, 0);
      exit();
    } else children[i] = pid;
  }

  workload(8000000, 0);
  

  getpinfo(&st);

  int counter = 0;
  for (int i = 0; i < NPROC; ++i) {
    if (st.state[i] == RUNNABLE) {
      for (int j = 0; j < 5; ++j) {
        if (st.pid[i] == children[j]) {
          counter++;
          if (st.ticks[i][2] != 0) {
            printf(1, "XV6_SCHEDULER: Lower priority processes is running before higher ones.\n");
            exit();
          }
        }
      }
    }
  }
  if (counter != 5) {
    printf(1, "XV6_SCHEDULER: Information wrongly recorded.\n");
    exit();
  }
  for (int i = 0; i < 5; ++i) {
    wait();
  }

  exit();
}
