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
  int children[15];
  
  for (int i = 0; i < 15; ++i) {
    int pid = fork2((i * i) % 3);
    if (pid == 0) {
      workload(8000000, 0);
      exit();
    }
    else children[i] = pid;
  }

  for (int i = 0; i < 2; ++i) {
    for (int j = 0; j < 15; ++j) {
      if ((j * j) % 3 == 2 - i) {
        wait();
      }
    }

    getpinfo(&st);

    for (int k = 0; k < NPROC; ++k) {
      if (st.state[k] == RUNNABLE) {
        for (int j = 0; j < 15; ++j) {
          if (st.pid[k] == children[j]) {
            if (st.ticks[k][0] != 0 || st.ticks[k][1] != 0) {
              printf(1, "XV6_SCHEDULER: Lower priority processes is running before higher ones.\n");
              exit();
            }
          }
        }
      }
    }
  }

  for (int i = 0; i < 15; ++i) {
    if ((i * i) % 3 == 0) wait();
  }

  exit();
}
