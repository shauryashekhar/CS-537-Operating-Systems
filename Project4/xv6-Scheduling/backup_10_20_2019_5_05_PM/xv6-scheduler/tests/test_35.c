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
  for (int i = 0; i < 13; ++i) {
    int pid = fork2(i % 4);
    if (pid == 0) {
      workload(789 * i, 100);
      int pid2 = fork();
      if (pid2 == 0) {
        int pid3 = fork2(i % 2);
        workload(678 * i, 9 * i);
        if (pid3 != 0) {
          while(wait() != -1);
        }
        exit();
      } else {
        workload(140 * i, 23 * i);
        while(wait() != -1);
        exit();
      }
    } else {
      workload(i * 77, i);
    }
  }

  while(wait() != -1);
  exit();
}
