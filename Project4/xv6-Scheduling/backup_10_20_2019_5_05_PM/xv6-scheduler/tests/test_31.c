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
  int pid1 = fork2(1);
  if (pid1 == 0) {
    workload(100, 0);
    int pid2 = fork2(2);
    sleep(1);
    if (pid2 == 0) {
      printf(1, "XV6_SCHEDULER: child\n");
    } else {
      printf(1, "XV6_SCHEDULER: parent\n");
      while (wait() != -1);
    }
    exit();
  } else {
    while (wait() != -1);
  }
  exit();
}
