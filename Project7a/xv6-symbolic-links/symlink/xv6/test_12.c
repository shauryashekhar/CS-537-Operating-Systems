#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
//#include "defs.h"


int main(int argc, char *argv[])
{
  const char *c1 = "/test12.txt";
  const char *c2 = "/test/testSYM12.txt";
  //char *c3 = "/test/SYM1.txt";
  const char *correctString = "HELLO!";
  char *buf = (char*)malloc(sizeof(char)*6);
  char *buf2 = (char*)malloc(sizeof(char)*5);
  int s = symlink(c1, c2);
  if(s != 0){
    printf(1,"SYMLINK: Symlink creation failed and returned = %d\n", symlink(c1, c2));
    exit();
  }
  int fd;
  fd = open(c2, O_RDWR);
  if(fd < 0){
    printf(1, "SYMLINK: Open of symlink Failed\n");
    exit();
  }else{
    read(fd, buf2, sizeof(char)*5);
    close(fd);
    fd = open(c2, O_RDWR);
    write(fd, correctString, sizeof(char)*6);
    close(fd);
    fd = open(c2, O_RDWR);
    read(fd, buf, sizeof(char)*6);
    for(int i = 0; i < 6; i++){
      if(buf[i] != correctString[i]){
	printf(1, "SYMLINK: Contents of file wasn't correctly updated. Your old contents = %s, Your new contents = %s, Correct Contents = %s\n",buf2, buf, correctString);
      }
    }
  }
  
  exit();
}

