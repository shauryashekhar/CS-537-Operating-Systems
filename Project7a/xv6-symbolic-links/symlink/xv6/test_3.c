#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
//#include "defs.h"


int main(int argc, char *argv[])
{
  const char *c1 = "/test3.txt";
  const char *c2 = "/testSYM3.txt";
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
    int c = close(fd);
    if( c < 0 ){
      printf(1, "SYMLINK: Close of symlink Failed\n"); 
    }
  }
  
  exit();
}

