#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
//#include "defs.h"


int main(int argc, char *argv[])
{
  const char *c1 = "/test10.txt";
  const char *c2 = "/test/testSYM10.txt";
  //char *c3 = "/test/SYM1.txt";
  char *correctString = "HELLO";
  char *buf = (char*)malloc(sizeof(char)*5);
  int s = symlink(c1, c2);
  if(s != 0){
    printf(1,"SYMLINK: Symlink creation failed and returned = %d\n", symlink(c1, c2));
    exit();
  }
  int fd;
  fd = open(c2, O_RDONLY);
  if(fd < 0){
    printf(1, "SYMLINK: Open of symlink Failed\n");
    exit();
  }else{
    read(fd, buf, sizeof(char)*5);
    for(int i = 0; i < 5; i++){
      if(buf[i] != correctString[i]){
	printf(1, "SYMLINK: Contents of original file and symlinked file do not match. Your contents = %s, Correct String = %s\n", buf, correctString);
      }
    }
  }
  
  exit();
}

