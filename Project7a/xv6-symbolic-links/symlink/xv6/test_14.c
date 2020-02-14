#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
//#include "defs.h"

char*
fmtname(char *path)
{
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    ;
  p++;

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}

void
ls(char *path)
{
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
    printf(2, "SYMLINK:ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    printf(2, "SYMLINK:ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  case T_FILE:
    printf(1, "SYMLINK:%s %d %d\n", fmtname(path), st.type, st.ino);
    break;

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf(1, "SYMLINK:ls: path too long\n");
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "SYMLINK:ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "SYMLINK:%s %d %d\n", fmtname(buf), st.type, st.ino);
    }
    break;
  }
  close(fd);
}

int main(int argc, char *argv[])
{
  const char *c1 = "/test/test14.txt";
  const char *c2 = "/testSYM14.txt";
  //char *c3 = "/test/SYM1.txt";

  printf(1,"SYMLINK: Symlink return = %d\n", symlink(c1, c2));

  ls("");
  //printf(1, "SYMLINK: Namei return = %d\n", namei(c3));

  exit();
}

