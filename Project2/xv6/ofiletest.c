#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
  if(argc < 2) {
    printf(1, "Arguments needed: ofiletest [number of files to be opened] [files which need to be closed separated by spaces].\n");
    exit();
  }
  int pid = getpid();
  int fd = 0;
  for(int i=0; i<atoi(argv[1]); i++) {
    char fileName[10] = {'o','f','i','l','e'};
    int currFileNameIndex = 5;
    int temp = i;
    do {
      int num = temp%10;
      fileName[currFileNameIndex] = num + '0';
      currFileNameIndex++;
      temp = temp/10;
    } while(temp != 0);
    fd = open(fileName, O_RDWR | O_CREATE);
    if(fd < 0) {
      printf(2,"File could not be opened.\n");
      exit();
    }
  }
  for(int i = 2; i < argc; i++) {
    close(atoi(argv[i])+3);
    unlink(argv[i]+3);
  }
  int openFileCount = getofilecnt(pid);
  int nextCounter = getofilenext(pid);
  printf(1, "%d %d \n", openFileCount, nextCounter);
  exit();
}
