#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
//#include "defs.h"


int main(int argc, char *argv[])
{
  const char *c1 = "/test13.txt";
  const char *c2 = "/testSYM13.txt";
  const char *c3 = "/testSYM13.txt";

  printf(1,"SYMLINK: Symlink return = %d\n", symlink(c1, c2));
  printf(1,"SYMLINK: Symlink return = %d. You tried creating a symlink with an existing symlink name!\n", symlink(c1, c3));
  
   exit();
}

