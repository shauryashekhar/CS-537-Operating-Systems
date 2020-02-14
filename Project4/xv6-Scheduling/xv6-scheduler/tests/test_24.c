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

int sleepload(int n, int t){
  int i;
  for(i = 0; i < n; i++){
    //printf(1, "Sleep\n");
    sleep(1);
  }
  return i;
}

int
main(int argc, char *argv[])
{
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");

  // Push this thread to the bottom
  workload(100, 0);

  int i, j, k;
  int c_pid[10];
  // Launch the 4 processes, but process 2 will sleep in the middle
  for (i = 0; i < 10; i++) {
    c_pid[i] = fork2(2);
    int t = 0;
    // Child
    if (c_pid[i] == 0) {
      if (i % 2 == 1) {
          t = 64*5; // for this process, give up CPU for one time-slice
      }
      sleepload(200, t);
      exit();
    } else {
      //setpri(c_pid, 2);
    }
  }

  for (i = 0; i < 6; i++) { 
    sleep(12);
    check(getpinfo(&st) == 0, "getpinfo");
    
    for (j = 0; j < NPROC; j++) {
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
	if( st.pid[j] == c_pid[0]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 1\n"));
        } else if(st.pid[j] == c_pid[1]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 2\n"));
        } else if(st.pid[j] == c_pid[2]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 3\n"));
        } else if(st.pid[j] == c_pid[3]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 4\n"));
        } else if(st.pid[j] == c_pid[4]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 5\n"));
        } else if(st.pid[j] == c_pid[5]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 6\n"));
        } else if(st.pid[j] == c_pid[6]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 7\n"));
        } else if(st.pid[j] == c_pid[7]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 8\n"));
        } else if(st.pid[j] == c_pid[8]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 9\n"));
        } else if(st.pid[j] == c_pid[9]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 10\n"));
        }
        //DEBUG_PRINT((1, "pid: %d\n", st.pid[j]));
        for (k = 3; k >= 0; k--) {
          DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d ticks used %d\n", k, st.ticks[j][k]));
	  DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d qtail %d\n", k, st.qtail[j][k]));
        }
      } 
    }
  }

  for (i = 0; i < 10; i++) {
    wait();
  }

  //printf(1, "TEST PASSED");

  exit();
}
