#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>

/*
 * CS537 
 *
 * This program is intended to help you test your shell.
 * You can use it to test that you are correctly starting and waiting
 * for multiple processes.
 * 
 * Recommended Usage: 
 * Run multiple copies of this program simultaneously (in the background). 
 *
 * You should see the output from each intermingled 
 * (you can tell which process is which because each prints its "pid").
 *
 * You might only see the output intermingled when one of the processes 
 * goes to sleep; this is okay.  However, it is not okay if you see the
 * output of one process completely before the output of the other.
 *
 */
int main(int argc, char *argv[]) {
  int pid;
  int i;
  int j;
  int outer = 5;
  int inner = 10;
  int count = 0;
  int64_t max_usleep = 1000000;  // 1 second
  int seed;
  int64_t usec;
  int c;

  pid = getpid();
  while ((c = getopt(argc, argv, "o:i:s:r:")) != -1) {
    switch (c) {
    case 'o':
      outer = atoi(optarg);
      break;

    case 'i':
      inner = atoi(optarg);
      break;

    case 's':
      max_usleep = (int64_t)atoi(optarg);
      break;

    case 'r':
      seed = atoi(optarg);
      srand(seed);
      break;

    default:
      fprintf(stderr,
              "Usage: %s [-o <outerloops>] [-i <innerloops>]"
              " [-s <maxusecsleep>] [-r <random seed>]\n",
              argv[0]);
      exit(1);
    }
  }

  for (i = 0; i < outer; i++) {
    for (j = 0; j < inner; j++) {
      printf("%d: %d\n", pid, count);
      count++;
    }

    usec = max_usleep * ((float)rand() / (float)RAND_MAX);
    printf("%d sleeping for  %ld usec\n", pid, usec);
    if (usleep(usec) == -1) {
      perror("usleep");
    }
  }

  printf("Job completed\n");
  return 0;
}

