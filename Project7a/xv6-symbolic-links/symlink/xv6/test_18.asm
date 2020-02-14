
_test_18:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "fcntl.h"
//#include "defs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   8:	83 ec 0c             	sub    $0xc,%esp
   b:	53                   	push   %ebx
   c:	e8 0b 03 00 00       	call   31c <strlen>
  11:	01 d8                	add    %ebx,%eax
  13:	83 c4 10             	add    $0x10,%esp
  16:	eb 03                	jmp    1b <fmtname+0x1b>
  18:	83 e8 01             	sub    $0x1,%eax
  1b:	39 d8                	cmp    %ebx,%eax
  1d:	72 05                	jb     24 <fmtname+0x24>
  1f:	80 38 2f             	cmpb   $0x2f,(%eax)
  22:	75 f4                	jne    18 <fmtname+0x18>
    ;
  p++;
  24:	8d 58 01             	lea    0x1(%eax),%ebx

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  27:	83 ec 0c             	sub    $0xc,%esp
  2a:	53                   	push   %ebx
  2b:	e8 ec 02 00 00       	call   31c <strlen>
  30:	83 c4 10             	add    $0x10,%esp
  33:	83 f8 0d             	cmp    $0xd,%eax
  36:	76 09                	jbe    41 <fmtname+0x41>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  38:	89 d8                	mov    %ebx,%eax
  3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  3d:	5b                   	pop    %ebx
  3e:	5e                   	pop    %esi
  3f:	5d                   	pop    %ebp
  40:	c3                   	ret    
  memmove(buf, p, strlen(p));
  41:	83 ec 0c             	sub    $0xc,%esp
  44:	53                   	push   %ebx
  45:	e8 d2 02 00 00       	call   31c <strlen>
  4a:	83 c4 0c             	add    $0xc,%esp
  4d:	50                   	push   %eax
  4e:	53                   	push   %ebx
  4f:	68 24 0c 00 00       	push   $0xc24
  54:	e8 da 03 00 00       	call   433 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  59:	89 1c 24             	mov    %ebx,(%esp)
  5c:	e8 bb 02 00 00       	call   31c <strlen>
  61:	89 c6                	mov    %eax,%esi
  63:	89 1c 24             	mov    %ebx,(%esp)
  66:	e8 b1 02 00 00       	call   31c <strlen>
  6b:	83 c4 0c             	add    $0xc,%esp
  6e:	ba 0e 00 00 00       	mov    $0xe,%edx
  73:	29 f2                	sub    %esi,%edx
  75:	52                   	push   %edx
  76:	6a 20                	push   $0x20
  78:	05 24 0c 00 00       	add    $0xc24,%eax
  7d:	50                   	push   %eax
  7e:	e8 b3 02 00 00       	call   336 <memset>
  return buf;
  83:	83 c4 10             	add    $0x10,%esp
  86:	bb 24 0c 00 00       	mov    $0xc24,%ebx
  8b:	eb ab                	jmp    38 <fmtname+0x38>

0000008d <ls>:

void
ls(char *path)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	57                   	push   %edi
  91:	56                   	push   %esi
  92:	53                   	push   %ebx
  93:	81 ec 54 02 00 00    	sub    $0x254,%esp
  99:	8b 75 08             	mov    0x8(%ebp),%esi
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  9c:	6a 00                	push   $0x0
  9e:	56                   	push   %esi
  9f:	e8 01 04 00 00       	call   4a5 <open>
  a4:	83 c4 10             	add    $0x10,%esp
  a7:	85 c0                	test   %eax,%eax
  a9:	78 72                	js     11d <ls+0x90>
  ab:	89 c3                	mov    %eax,%ebx
    printf(2, "SYMLINK:ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  ad:	83 ec 08             	sub    $0x8,%esp
  b0:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
  b6:	50                   	push   %eax
  b7:	53                   	push   %ebx
  b8:	e8 00 04 00 00       	call   4bd <fstat>
  bd:	83 c4 10             	add    $0x10,%esp
  c0:	85 c0                	test   %eax,%eax
  c2:	78 6e                	js     132 <ls+0xa5>
    printf(2, "SYMLINK:ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  c4:	0f b7 85 c4 fd ff ff 	movzwl -0x23c(%ebp),%eax
  cb:	0f bf f8             	movswl %ax,%edi
  ce:	66 83 f8 01          	cmp    $0x1,%ax
  d2:	74 7b                	je     14f <ls+0xc2>
  d4:	66 83 f8 02          	cmp    $0x2,%ax
  d8:	75 2f                	jne    109 <ls+0x7c>
  case T_FILE:
    printf(1, "SYMLINK:%s %d %d\n", fmtname(path), st.type, st.ino);
  da:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
  e0:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
  e6:	83 ec 0c             	sub    $0xc,%esp
  e9:	56                   	push   %esi
  ea:	e8 11 ff ff ff       	call   0 <fmtname>
  ef:	83 c4 04             	add    $0x4,%esp
  f2:	ff b5 b4 fd ff ff    	pushl  -0x24c(%ebp)
  f8:	57                   	push   %edi
  f9:	50                   	push   %eax
  fa:	68 98 08 00 00       	push   $0x898
  ff:	6a 01                	push   $0x1
 101:	e8 a1 04 00 00       	call   5a7 <printf>
    break;
 106:	83 c4 20             	add    $0x20,%esp
      }
      printf(1, "SYMLINK:%s %d %d\n", fmtname(buf), st.type, st.ino);
    }
    break;
  }
  close(fd);
 109:	83 ec 0c             	sub    $0xc,%esp
 10c:	53                   	push   %ebx
 10d:	e8 7b 03 00 00       	call   48d <close>
 112:	83 c4 10             	add    $0x10,%esp
}
 115:	8d 65 f4             	lea    -0xc(%ebp),%esp
 118:	5b                   	pop    %ebx
 119:	5e                   	pop    %esi
 11a:	5f                   	pop    %edi
 11b:	5d                   	pop    %ebp
 11c:	c3                   	ret    
    printf(2, "SYMLINK:ls: cannot open %s\n", path);
 11d:	83 ec 04             	sub    $0x4,%esp
 120:	56                   	push   %esi
 121:	68 60 08 00 00       	push   $0x860
 126:	6a 02                	push   $0x2
 128:	e8 7a 04 00 00       	call   5a7 <printf>
    return;
 12d:	83 c4 10             	add    $0x10,%esp
 130:	eb e3                	jmp    115 <ls+0x88>
    printf(2, "SYMLINK:ls: cannot stat %s\n", path);
 132:	83 ec 04             	sub    $0x4,%esp
 135:	56                   	push   %esi
 136:	68 7c 08 00 00       	push   $0x87c
 13b:	6a 02                	push   $0x2
 13d:	e8 65 04 00 00       	call   5a7 <printf>
    close(fd);
 142:	89 1c 24             	mov    %ebx,(%esp)
 145:	e8 43 03 00 00       	call   48d <close>
    return;
 14a:	83 c4 10             	add    $0x10,%esp
 14d:	eb c6                	jmp    115 <ls+0x88>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 14f:	83 ec 0c             	sub    $0xc,%esp
 152:	56                   	push   %esi
 153:	e8 c4 01 00 00       	call   31c <strlen>
 158:	83 c0 10             	add    $0x10,%eax
 15b:	83 c4 10             	add    $0x10,%esp
 15e:	3d 00 02 00 00       	cmp    $0x200,%eax
 163:	76 14                	jbe    179 <ls+0xec>
      printf(1, "SYMLINK:ls: path too long\n");
 165:	83 ec 08             	sub    $0x8,%esp
 168:	68 aa 08 00 00       	push   $0x8aa
 16d:	6a 01                	push   $0x1
 16f:	e8 33 04 00 00       	call   5a7 <printf>
      break;
 174:	83 c4 10             	add    $0x10,%esp
 177:	eb 90                	jmp    109 <ls+0x7c>
    strcpy(buf, path);
 179:	83 ec 08             	sub    $0x8,%esp
 17c:	56                   	push   %esi
 17d:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
 183:	56                   	push   %esi
 184:	e8 4f 01 00 00       	call   2d8 <strcpy>
    p = buf+strlen(buf);
 189:	89 34 24             	mov    %esi,(%esp)
 18c:	e8 8b 01 00 00       	call   31c <strlen>
 191:	01 c6                	add    %eax,%esi
    *p++ = '/';
 193:	8d 46 01             	lea    0x1(%esi),%eax
 196:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
 19c:	c6 06 2f             	movb   $0x2f,(%esi)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 19f:	83 c4 10             	add    $0x10,%esp
 1a2:	83 ec 04             	sub    $0x4,%esp
 1a5:	6a 10                	push   $0x10
 1a7:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
 1ad:	50                   	push   %eax
 1ae:	53                   	push   %ebx
 1af:	e8 c9 02 00 00       	call   47d <read>
 1b4:	83 c4 10             	add    $0x10,%esp
 1b7:	83 f8 10             	cmp    $0x10,%eax
 1ba:	0f 85 49 ff ff ff    	jne    109 <ls+0x7c>
      if(de.inum == 0)
 1c0:	66 83 bd d8 fd ff ff 	cmpw   $0x0,-0x228(%ebp)
 1c7:	00 
 1c8:	74 d8                	je     1a2 <ls+0x115>
      memmove(p, de.name, DIRSIZ);
 1ca:	83 ec 04             	sub    $0x4,%esp
 1cd:	6a 0e                	push   $0xe
 1cf:	8d 85 da fd ff ff    	lea    -0x226(%ebp),%eax
 1d5:	50                   	push   %eax
 1d6:	ff b5 b0 fd ff ff    	pushl  -0x250(%ebp)
 1dc:	e8 52 02 00 00       	call   433 <memmove>
      p[DIRSIZ] = 0;
 1e1:	c6 46 0f 00          	movb   $0x0,0xf(%esi)
      if(stat(buf, &st) < 0){
 1e5:	83 c4 08             	add    $0x8,%esp
 1e8:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 1ee:	50                   	push   %eax
 1ef:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 1f5:	50                   	push   %eax
 1f6:	e8 c8 01 00 00       	call   3c3 <stat>
 1fb:	83 c4 10             	add    $0x10,%esp
 1fe:	85 c0                	test   %eax,%eax
 200:	78 43                	js     245 <ls+0x1b8>
      printf(1, "SYMLINK:%s %d %d\n", fmtname(buf), st.type, st.ino);
 202:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 208:	0f b7 85 c4 fd ff ff 	movzwl -0x23c(%ebp),%eax
 20f:	66 89 85 b4 fd ff ff 	mov    %ax,-0x24c(%ebp)
 216:	83 ec 0c             	sub    $0xc,%esp
 219:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 21f:	50                   	push   %eax
 220:	e8 db fd ff ff       	call   0 <fmtname>
 225:	89 3c 24             	mov    %edi,(%esp)
 228:	0f bf 95 b4 fd ff ff 	movswl -0x24c(%ebp),%edx
 22f:	52                   	push   %edx
 230:	50                   	push   %eax
 231:	68 98 08 00 00       	push   $0x898
 236:	6a 01                	push   $0x1
 238:	e8 6a 03 00 00       	call   5a7 <printf>
 23d:	83 c4 20             	add    $0x20,%esp
 240:	e9 5d ff ff ff       	jmp    1a2 <ls+0x115>
        printf(1, "SYMLINK:ls: cannot stat %s\n", buf);
 245:	83 ec 04             	sub    $0x4,%esp
 248:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 24e:	50                   	push   %eax
 24f:	68 7c 08 00 00       	push   $0x87c
 254:	6a 01                	push   $0x1
 256:	e8 4c 03 00 00       	call   5a7 <printf>
        continue;
 25b:	83 c4 10             	add    $0x10,%esp
 25e:	e9 3f ff ff ff       	jmp    1a2 <ls+0x115>

00000263 <main>:

int main(int argc, char *argv[])
{
 263:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 267:	83 e4 f0             	and    $0xfffffff0,%esp
 26a:	ff 71 fc             	pushl  -0x4(%ecx)
 26d:	55                   	push   %ebp
 26e:	89 e5                	mov    %esp,%ebp
 270:	51                   	push   %ecx
 271:	83 ec 0c             	sub    $0xc,%esp
  const char *c1 = "/test18.txt";
  const char *c2 = "/test/testSYM18.txt";
  //char *c3 = "/test/SYM1.txt";

  printf(1,"SYMLINK: Symlink return = %d\n", symlink(c1, c2));
 274:	68 c5 08 00 00       	push   $0x8c5
 279:	68 d9 08 00 00       	push   $0x8d9
 27e:	e8 82 02 00 00       	call   505 <symlink>
 283:	83 c4 0c             	add    $0xc,%esp
 286:	50                   	push   %eax
 287:	68 e5 08 00 00       	push   $0x8e5
 28c:	6a 01                	push   $0x1
 28e:	e8 14 03 00 00       	call   5a7 <printf>

  ls("/test");
 293:	c7 04 24 03 09 00 00 	movl   $0x903,(%esp)
 29a:	e8 ee fd ff ff       	call   8d <ls>

  printf(1, "SYMLINK: Unlink return = %d\n", unlink(c2));
 29f:	c7 04 24 c5 08 00 00 	movl   $0x8c5,(%esp)
 2a6:	e8 0a 02 00 00       	call   4b5 <unlink>
 2ab:	83 c4 0c             	add    $0xc,%esp
 2ae:	50                   	push   %eax
 2af:	68 09 09 00 00       	push   $0x909
 2b4:	6a 01                	push   $0x1
 2b6:	e8 ec 02 00 00       	call   5a7 <printf>

  ls("/test");
 2bb:	c7 04 24 03 09 00 00 	movl   $0x903,(%esp)
 2c2:	e8 c6 fd ff ff       	call   8d <ls>
  ls(".");
 2c7:	c7 04 24 26 09 00 00 	movl   $0x926,(%esp)
 2ce:	e8 ba fd ff ff       	call   8d <ls>
  //printf(1, "SYMLINK: Namei return = %d\n", namei(c3));

  exit();
 2d3:	e8 8d 01 00 00       	call   465 <exit>

000002d8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
 2db:	53                   	push   %ebx
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2e2:	89 c2                	mov    %eax,%edx
 2e4:	0f b6 19             	movzbl (%ecx),%ebx
 2e7:	88 1a                	mov    %bl,(%edx)
 2e9:	8d 52 01             	lea    0x1(%edx),%edx
 2ec:	8d 49 01             	lea    0x1(%ecx),%ecx
 2ef:	84 db                	test   %bl,%bl
 2f1:	75 f1                	jne    2e4 <strcpy+0xc>
    ;
  return os;
}
 2f3:	5b                   	pop    %ebx
 2f4:	5d                   	pop    %ebp
 2f5:	c3                   	ret    

000002f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f6:	55                   	push   %ebp
 2f7:	89 e5                	mov    %esp,%ebp
 2f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 2ff:	eb 06                	jmp    307 <strcmp+0x11>
    p++, q++;
 301:	83 c1 01             	add    $0x1,%ecx
 304:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 307:	0f b6 01             	movzbl (%ecx),%eax
 30a:	84 c0                	test   %al,%al
 30c:	74 04                	je     312 <strcmp+0x1c>
 30e:	3a 02                	cmp    (%edx),%al
 310:	74 ef                	je     301 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 312:	0f b6 c0             	movzbl %al,%eax
 315:	0f b6 12             	movzbl (%edx),%edx
 318:	29 d0                	sub    %edx,%eax
}
 31a:	5d                   	pop    %ebp
 31b:	c3                   	ret    

0000031c <strlen>:

uint
strlen(const char *s)
{
 31c:	55                   	push   %ebp
 31d:	89 e5                	mov    %esp,%ebp
 31f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 322:	ba 00 00 00 00       	mov    $0x0,%edx
 327:	eb 03                	jmp    32c <strlen+0x10>
 329:	83 c2 01             	add    $0x1,%edx
 32c:	89 d0                	mov    %edx,%eax
 32e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 332:	75 f5                	jne    329 <strlen+0xd>
    ;
  return n;
}
 334:	5d                   	pop    %ebp
 335:	c3                   	ret    

00000336 <memset>:

void*
memset(void *dst, int c, uint n)
{
 336:	55                   	push   %ebp
 337:	89 e5                	mov    %esp,%ebp
 339:	57                   	push   %edi
 33a:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 33d:	89 d7                	mov    %edx,%edi
 33f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 342:	8b 45 0c             	mov    0xc(%ebp),%eax
 345:	fc                   	cld    
 346:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 348:	89 d0                	mov    %edx,%eax
 34a:	5f                   	pop    %edi
 34b:	5d                   	pop    %ebp
 34c:	c3                   	ret    

0000034d <strchr>:

char*
strchr(const char *s, char c)
{
 34d:	55                   	push   %ebp
 34e:	89 e5                	mov    %esp,%ebp
 350:	8b 45 08             	mov    0x8(%ebp),%eax
 353:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 357:	0f b6 10             	movzbl (%eax),%edx
 35a:	84 d2                	test   %dl,%dl
 35c:	74 09                	je     367 <strchr+0x1a>
    if(*s == c)
 35e:	38 ca                	cmp    %cl,%dl
 360:	74 0a                	je     36c <strchr+0x1f>
  for(; *s; s++)
 362:	83 c0 01             	add    $0x1,%eax
 365:	eb f0                	jmp    357 <strchr+0xa>
      return (char*)s;
  return 0;
 367:	b8 00 00 00 00       	mov    $0x0,%eax
}
 36c:	5d                   	pop    %ebp
 36d:	c3                   	ret    

0000036e <gets>:

char*
gets(char *buf, int max)
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
 371:	57                   	push   %edi
 372:	56                   	push   %esi
 373:	53                   	push   %ebx
 374:	83 ec 1c             	sub    $0x1c,%esp
 377:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 37a:	bb 00 00 00 00       	mov    $0x0,%ebx
 37f:	8d 73 01             	lea    0x1(%ebx),%esi
 382:	3b 75 0c             	cmp    0xc(%ebp),%esi
 385:	7d 2e                	jge    3b5 <gets+0x47>
    cc = read(0, &c, 1);
 387:	83 ec 04             	sub    $0x4,%esp
 38a:	6a 01                	push   $0x1
 38c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 38f:	50                   	push   %eax
 390:	6a 00                	push   $0x0
 392:	e8 e6 00 00 00       	call   47d <read>
    if(cc < 1)
 397:	83 c4 10             	add    $0x10,%esp
 39a:	85 c0                	test   %eax,%eax
 39c:	7e 17                	jle    3b5 <gets+0x47>
      break;
    buf[i++] = c;
 39e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 3a2:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 3a5:	3c 0a                	cmp    $0xa,%al
 3a7:	0f 94 c2             	sete   %dl
 3aa:	3c 0d                	cmp    $0xd,%al
 3ac:	0f 94 c0             	sete   %al
    buf[i++] = c;
 3af:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 3b1:	08 c2                	or     %al,%dl
 3b3:	74 ca                	je     37f <gets+0x11>
      break;
  }
  buf[i] = '\0';
 3b5:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 3b9:	89 f8                	mov    %edi,%eax
 3bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3be:	5b                   	pop    %ebx
 3bf:	5e                   	pop    %esi
 3c0:	5f                   	pop    %edi
 3c1:	5d                   	pop    %ebp
 3c2:	c3                   	ret    

000003c3 <stat>:

int
stat(const char *n, struct stat *st)
{
 3c3:	55                   	push   %ebp
 3c4:	89 e5                	mov    %esp,%ebp
 3c6:	56                   	push   %esi
 3c7:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c8:	83 ec 08             	sub    $0x8,%esp
 3cb:	6a 00                	push   $0x0
 3cd:	ff 75 08             	pushl  0x8(%ebp)
 3d0:	e8 d0 00 00 00       	call   4a5 <open>
  if(fd < 0)
 3d5:	83 c4 10             	add    $0x10,%esp
 3d8:	85 c0                	test   %eax,%eax
 3da:	78 24                	js     400 <stat+0x3d>
 3dc:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 3de:	83 ec 08             	sub    $0x8,%esp
 3e1:	ff 75 0c             	pushl  0xc(%ebp)
 3e4:	50                   	push   %eax
 3e5:	e8 d3 00 00 00       	call   4bd <fstat>
 3ea:	89 c6                	mov    %eax,%esi
  close(fd);
 3ec:	89 1c 24             	mov    %ebx,(%esp)
 3ef:	e8 99 00 00 00       	call   48d <close>
  return r;
 3f4:	83 c4 10             	add    $0x10,%esp
}
 3f7:	89 f0                	mov    %esi,%eax
 3f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
 3fc:	5b                   	pop    %ebx
 3fd:	5e                   	pop    %esi
 3fe:	5d                   	pop    %ebp
 3ff:	c3                   	ret    
    return -1;
 400:	be ff ff ff ff       	mov    $0xffffffff,%esi
 405:	eb f0                	jmp    3f7 <stat+0x34>

00000407 <atoi>:

int
atoi(const char *s)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
 40a:	53                   	push   %ebx
 40b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 40e:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 413:	eb 10                	jmp    425 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 415:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 418:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 41b:	83 c1 01             	add    $0x1,%ecx
 41e:	0f be d2             	movsbl %dl,%edx
 421:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 425:	0f b6 11             	movzbl (%ecx),%edx
 428:	8d 5a d0             	lea    -0x30(%edx),%ebx
 42b:	80 fb 09             	cmp    $0x9,%bl
 42e:	76 e5                	jbe    415 <atoi+0xe>
  return n;
}
 430:	5b                   	pop    %ebx
 431:	5d                   	pop    %ebp
 432:	c3                   	ret    

00000433 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	56                   	push   %esi
 437:	53                   	push   %ebx
 438:	8b 45 08             	mov    0x8(%ebp),%eax
 43b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 43e:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 441:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 443:	eb 0d                	jmp    452 <memmove+0x1f>
    *dst++ = *src++;
 445:	0f b6 13             	movzbl (%ebx),%edx
 448:	88 11                	mov    %dl,(%ecx)
 44a:	8d 5b 01             	lea    0x1(%ebx),%ebx
 44d:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 450:	89 f2                	mov    %esi,%edx
 452:	8d 72 ff             	lea    -0x1(%edx),%esi
 455:	85 d2                	test   %edx,%edx
 457:	7f ec                	jg     445 <memmove+0x12>
  return vdst;
}
 459:	5b                   	pop    %ebx
 45a:	5e                   	pop    %esi
 45b:	5d                   	pop    %ebp
 45c:	c3                   	ret    

0000045d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 45d:	b8 01 00 00 00       	mov    $0x1,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <exit>:
SYSCALL(exit)
 465:	b8 02 00 00 00       	mov    $0x2,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <wait>:
SYSCALL(wait)
 46d:	b8 03 00 00 00       	mov    $0x3,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <pipe>:
SYSCALL(pipe)
 475:	b8 04 00 00 00       	mov    $0x4,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <read>:
SYSCALL(read)
 47d:	b8 05 00 00 00       	mov    $0x5,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <write>:
SYSCALL(write)
 485:	b8 10 00 00 00       	mov    $0x10,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <close>:
SYSCALL(close)
 48d:	b8 15 00 00 00       	mov    $0x15,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <kill>:
SYSCALL(kill)
 495:	b8 06 00 00 00       	mov    $0x6,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <exec>:
SYSCALL(exec)
 49d:	b8 07 00 00 00       	mov    $0x7,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <open>:
SYSCALL(open)
 4a5:	b8 0f 00 00 00       	mov    $0xf,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <mknod>:
SYSCALL(mknod)
 4ad:	b8 11 00 00 00       	mov    $0x11,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <unlink>:
SYSCALL(unlink)
 4b5:	b8 12 00 00 00       	mov    $0x12,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <fstat>:
SYSCALL(fstat)
 4bd:	b8 08 00 00 00       	mov    $0x8,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <link>:
SYSCALL(link)
 4c5:	b8 13 00 00 00       	mov    $0x13,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <mkdir>:
SYSCALL(mkdir)
 4cd:	b8 14 00 00 00       	mov    $0x14,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <chdir>:
SYSCALL(chdir)
 4d5:	b8 09 00 00 00       	mov    $0x9,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <dup>:
SYSCALL(dup)
 4dd:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <getpid>:
SYSCALL(getpid)
 4e5:	b8 0b 00 00 00       	mov    $0xb,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <sbrk>:
SYSCALL(sbrk)
 4ed:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <sleep>:
SYSCALL(sleep)
 4f5:	b8 0d 00 00 00       	mov    $0xd,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <uptime>:
SYSCALL(uptime)
 4fd:	b8 0e 00 00 00       	mov    $0xe,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <symlink>:
SYSCALL(symlink)
 505:	b8 16 00 00 00       	mov    $0x16,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 50d:	55                   	push   %ebp
 50e:	89 e5                	mov    %esp,%ebp
 510:	83 ec 1c             	sub    $0x1c,%esp
 513:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 516:	6a 01                	push   $0x1
 518:	8d 55 f4             	lea    -0xc(%ebp),%edx
 51b:	52                   	push   %edx
 51c:	50                   	push   %eax
 51d:	e8 63 ff ff ff       	call   485 <write>
}
 522:	83 c4 10             	add    $0x10,%esp
 525:	c9                   	leave  
 526:	c3                   	ret    

00000527 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 527:	55                   	push   %ebp
 528:	89 e5                	mov    %esp,%ebp
 52a:	57                   	push   %edi
 52b:	56                   	push   %esi
 52c:	53                   	push   %ebx
 52d:	83 ec 2c             	sub    $0x2c,%esp
 530:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 532:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 536:	0f 95 c3             	setne  %bl
 539:	89 d0                	mov    %edx,%eax
 53b:	c1 e8 1f             	shr    $0x1f,%eax
 53e:	84 c3                	test   %al,%bl
 540:	74 10                	je     552 <printint+0x2b>
    neg = 1;
    x = -xx;
 542:	f7 da                	neg    %edx
    neg = 1;
 544:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 54b:	be 00 00 00 00       	mov    $0x0,%esi
 550:	eb 0b                	jmp    55d <printint+0x36>
  neg = 0;
 552:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 559:	eb f0                	jmp    54b <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 55b:	89 c6                	mov    %eax,%esi
 55d:	89 d0                	mov    %edx,%eax
 55f:	ba 00 00 00 00       	mov    $0x0,%edx
 564:	f7 f1                	div    %ecx
 566:	89 c3                	mov    %eax,%ebx
 568:	8d 46 01             	lea    0x1(%esi),%eax
 56b:	0f b6 92 30 09 00 00 	movzbl 0x930(%edx),%edx
 572:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 576:	89 da                	mov    %ebx,%edx
 578:	85 db                	test   %ebx,%ebx
 57a:	75 df                	jne    55b <printint+0x34>
 57c:	89 c3                	mov    %eax,%ebx
  if(neg)
 57e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 582:	74 16                	je     59a <printint+0x73>
    buf[i++] = '-';
 584:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 589:	8d 5e 02             	lea    0x2(%esi),%ebx
 58c:	eb 0c                	jmp    59a <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 58e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 593:	89 f8                	mov    %edi,%eax
 595:	e8 73 ff ff ff       	call   50d <putc>
  while(--i >= 0)
 59a:	83 eb 01             	sub    $0x1,%ebx
 59d:	79 ef                	jns    58e <printint+0x67>
}
 59f:	83 c4 2c             	add    $0x2c,%esp
 5a2:	5b                   	pop    %ebx
 5a3:	5e                   	pop    %esi
 5a4:	5f                   	pop    %edi
 5a5:	5d                   	pop    %ebp
 5a6:	c3                   	ret    

000005a7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	57                   	push   %edi
 5ab:	56                   	push   %esi
 5ac:	53                   	push   %ebx
 5ad:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 5b0:	8d 45 10             	lea    0x10(%ebp),%eax
 5b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 5b6:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 5bb:	bb 00 00 00 00       	mov    $0x0,%ebx
 5c0:	eb 14                	jmp    5d6 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 5c2:	89 fa                	mov    %edi,%edx
 5c4:	8b 45 08             	mov    0x8(%ebp),%eax
 5c7:	e8 41 ff ff ff       	call   50d <putc>
 5cc:	eb 05                	jmp    5d3 <printf+0x2c>
      }
    } else if(state == '%'){
 5ce:	83 fe 25             	cmp    $0x25,%esi
 5d1:	74 25                	je     5f8 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 5d3:	83 c3 01             	add    $0x1,%ebx
 5d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d9:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 5dd:	84 c0                	test   %al,%al
 5df:	0f 84 23 01 00 00    	je     708 <printf+0x161>
    c = fmt[i] & 0xff;
 5e5:	0f be f8             	movsbl %al,%edi
 5e8:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 5eb:	85 f6                	test   %esi,%esi
 5ed:	75 df                	jne    5ce <printf+0x27>
      if(c == '%'){
 5ef:	83 f8 25             	cmp    $0x25,%eax
 5f2:	75 ce                	jne    5c2 <printf+0x1b>
        state = '%';
 5f4:	89 c6                	mov    %eax,%esi
 5f6:	eb db                	jmp    5d3 <printf+0x2c>
      if(c == 'd'){
 5f8:	83 f8 64             	cmp    $0x64,%eax
 5fb:	74 49                	je     646 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 5fd:	83 f8 78             	cmp    $0x78,%eax
 600:	0f 94 c1             	sete   %cl
 603:	83 f8 70             	cmp    $0x70,%eax
 606:	0f 94 c2             	sete   %dl
 609:	08 d1                	or     %dl,%cl
 60b:	75 63                	jne    670 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 60d:	83 f8 73             	cmp    $0x73,%eax
 610:	0f 84 84 00 00 00    	je     69a <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 616:	83 f8 63             	cmp    $0x63,%eax
 619:	0f 84 b7 00 00 00    	je     6d6 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 61f:	83 f8 25             	cmp    $0x25,%eax
 622:	0f 84 cc 00 00 00    	je     6f4 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 628:	ba 25 00 00 00       	mov    $0x25,%edx
 62d:	8b 45 08             	mov    0x8(%ebp),%eax
 630:	e8 d8 fe ff ff       	call   50d <putc>
        putc(fd, c);
 635:	89 fa                	mov    %edi,%edx
 637:	8b 45 08             	mov    0x8(%ebp),%eax
 63a:	e8 ce fe ff ff       	call   50d <putc>
      }
      state = 0;
 63f:	be 00 00 00 00       	mov    $0x0,%esi
 644:	eb 8d                	jmp    5d3 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 649:	8b 17                	mov    (%edi),%edx
 64b:	83 ec 0c             	sub    $0xc,%esp
 64e:	6a 01                	push   $0x1
 650:	b9 0a 00 00 00       	mov    $0xa,%ecx
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	e8 ca fe ff ff       	call   527 <printint>
        ap++;
 65d:	83 c7 04             	add    $0x4,%edi
 660:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 663:	83 c4 10             	add    $0x10,%esp
      state = 0;
 666:	be 00 00 00 00       	mov    $0x0,%esi
 66b:	e9 63 ff ff ff       	jmp    5d3 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 673:	8b 17                	mov    (%edi),%edx
 675:	83 ec 0c             	sub    $0xc,%esp
 678:	6a 00                	push   $0x0
 67a:	b9 10 00 00 00       	mov    $0x10,%ecx
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	e8 a0 fe ff ff       	call   527 <printint>
        ap++;
 687:	83 c7 04             	add    $0x4,%edi
 68a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 68d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 690:	be 00 00 00 00       	mov    $0x0,%esi
 695:	e9 39 ff ff ff       	jmp    5d3 <printf+0x2c>
        s = (char*)*ap;
 69a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 69d:	8b 30                	mov    (%eax),%esi
        ap++;
 69f:	83 c0 04             	add    $0x4,%eax
 6a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 6a5:	85 f6                	test   %esi,%esi
 6a7:	75 28                	jne    6d1 <printf+0x12a>
          s = "(null)";
 6a9:	be 28 09 00 00       	mov    $0x928,%esi
 6ae:	8b 7d 08             	mov    0x8(%ebp),%edi
 6b1:	eb 0d                	jmp    6c0 <printf+0x119>
          putc(fd, *s);
 6b3:	0f be d2             	movsbl %dl,%edx
 6b6:	89 f8                	mov    %edi,%eax
 6b8:	e8 50 fe ff ff       	call   50d <putc>
          s++;
 6bd:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 6c0:	0f b6 16             	movzbl (%esi),%edx
 6c3:	84 d2                	test   %dl,%dl
 6c5:	75 ec                	jne    6b3 <printf+0x10c>
      state = 0;
 6c7:	be 00 00 00 00       	mov    $0x0,%esi
 6cc:	e9 02 ff ff ff       	jmp    5d3 <printf+0x2c>
 6d1:	8b 7d 08             	mov    0x8(%ebp),%edi
 6d4:	eb ea                	jmp    6c0 <printf+0x119>
        putc(fd, *ap);
 6d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6d9:	0f be 17             	movsbl (%edi),%edx
 6dc:	8b 45 08             	mov    0x8(%ebp),%eax
 6df:	e8 29 fe ff ff       	call   50d <putc>
        ap++;
 6e4:	83 c7 04             	add    $0x4,%edi
 6e7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 6ea:	be 00 00 00 00       	mov    $0x0,%esi
 6ef:	e9 df fe ff ff       	jmp    5d3 <printf+0x2c>
        putc(fd, c);
 6f4:	89 fa                	mov    %edi,%edx
 6f6:	8b 45 08             	mov    0x8(%ebp),%eax
 6f9:	e8 0f fe ff ff       	call   50d <putc>
      state = 0;
 6fe:	be 00 00 00 00       	mov    $0x0,%esi
 703:	e9 cb fe ff ff       	jmp    5d3 <printf+0x2c>
    }
  }
}
 708:	8d 65 f4             	lea    -0xc(%ebp),%esp
 70b:	5b                   	pop    %ebx
 70c:	5e                   	pop    %esi
 70d:	5f                   	pop    %edi
 70e:	5d                   	pop    %ebp
 70f:	c3                   	ret    

00000710 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 710:	55                   	push   %ebp
 711:	89 e5                	mov    %esp,%ebp
 713:	57                   	push   %edi
 714:	56                   	push   %esi
 715:	53                   	push   %ebx
 716:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 719:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71c:	a1 34 0c 00 00       	mov    0xc34,%eax
 721:	eb 02                	jmp    725 <free+0x15>
 723:	89 d0                	mov    %edx,%eax
 725:	39 c8                	cmp    %ecx,%eax
 727:	73 04                	jae    72d <free+0x1d>
 729:	39 08                	cmp    %ecx,(%eax)
 72b:	77 12                	ja     73f <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72d:	8b 10                	mov    (%eax),%edx
 72f:	39 c2                	cmp    %eax,%edx
 731:	77 f0                	ja     723 <free+0x13>
 733:	39 c8                	cmp    %ecx,%eax
 735:	72 08                	jb     73f <free+0x2f>
 737:	39 ca                	cmp    %ecx,%edx
 739:	77 04                	ja     73f <free+0x2f>
 73b:	89 d0                	mov    %edx,%eax
 73d:	eb e6                	jmp    725 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 73f:	8b 73 fc             	mov    -0x4(%ebx),%esi
 742:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 745:	8b 10                	mov    (%eax),%edx
 747:	39 d7                	cmp    %edx,%edi
 749:	74 19                	je     764 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 74b:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 74e:	8b 50 04             	mov    0x4(%eax),%edx
 751:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 754:	39 ce                	cmp    %ecx,%esi
 756:	74 1b                	je     773 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 758:	89 08                	mov    %ecx,(%eax)
  freep = p;
 75a:	a3 34 0c 00 00       	mov    %eax,0xc34
}
 75f:	5b                   	pop    %ebx
 760:	5e                   	pop    %esi
 761:	5f                   	pop    %edi
 762:	5d                   	pop    %ebp
 763:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 764:	03 72 04             	add    0x4(%edx),%esi
 767:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 76a:	8b 10                	mov    (%eax),%edx
 76c:	8b 12                	mov    (%edx),%edx
 76e:	89 53 f8             	mov    %edx,-0x8(%ebx)
 771:	eb db                	jmp    74e <free+0x3e>
    p->s.size += bp->s.size;
 773:	03 53 fc             	add    -0x4(%ebx),%edx
 776:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 779:	8b 53 f8             	mov    -0x8(%ebx),%edx
 77c:	89 10                	mov    %edx,(%eax)
 77e:	eb da                	jmp    75a <free+0x4a>

00000780 <morecore>:

static Header*
morecore(uint nu)
{
 780:	55                   	push   %ebp
 781:	89 e5                	mov    %esp,%ebp
 783:	53                   	push   %ebx
 784:	83 ec 04             	sub    $0x4,%esp
 787:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 789:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 78e:	77 05                	ja     795 <morecore+0x15>
    nu = 4096;
 790:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 795:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 79c:	83 ec 0c             	sub    $0xc,%esp
 79f:	50                   	push   %eax
 7a0:	e8 48 fd ff ff       	call   4ed <sbrk>
  if(p == (char*)-1)
 7a5:	83 c4 10             	add    $0x10,%esp
 7a8:	83 f8 ff             	cmp    $0xffffffff,%eax
 7ab:	74 1c                	je     7c9 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 7ad:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 7b0:	83 c0 08             	add    $0x8,%eax
 7b3:	83 ec 0c             	sub    $0xc,%esp
 7b6:	50                   	push   %eax
 7b7:	e8 54 ff ff ff       	call   710 <free>
  return freep;
 7bc:	a1 34 0c 00 00       	mov    0xc34,%eax
 7c1:	83 c4 10             	add    $0x10,%esp
}
 7c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 7c7:	c9                   	leave  
 7c8:	c3                   	ret    
    return 0;
 7c9:	b8 00 00 00 00       	mov    $0x0,%eax
 7ce:	eb f4                	jmp    7c4 <morecore+0x44>

000007d0 <malloc>:

void*
malloc(uint nbytes)
{
 7d0:	55                   	push   %ebp
 7d1:	89 e5                	mov    %esp,%ebp
 7d3:	53                   	push   %ebx
 7d4:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d7:	8b 45 08             	mov    0x8(%ebp),%eax
 7da:	8d 58 07             	lea    0x7(%eax),%ebx
 7dd:	c1 eb 03             	shr    $0x3,%ebx
 7e0:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 7e3:	8b 0d 34 0c 00 00    	mov    0xc34,%ecx
 7e9:	85 c9                	test   %ecx,%ecx
 7eb:	74 04                	je     7f1 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ed:	8b 01                	mov    (%ecx),%eax
 7ef:	eb 4d                	jmp    83e <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 7f1:	c7 05 34 0c 00 00 38 	movl   $0xc38,0xc34
 7f8:	0c 00 00 
 7fb:	c7 05 38 0c 00 00 38 	movl   $0xc38,0xc38
 802:	0c 00 00 
    base.s.size = 0;
 805:	c7 05 3c 0c 00 00 00 	movl   $0x0,0xc3c
 80c:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 80f:	b9 38 0c 00 00       	mov    $0xc38,%ecx
 814:	eb d7                	jmp    7ed <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 816:	39 da                	cmp    %ebx,%edx
 818:	74 1a                	je     834 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 81a:	29 da                	sub    %ebx,%edx
 81c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 81f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 822:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 825:	89 0d 34 0c 00 00    	mov    %ecx,0xc34
      return (void*)(p + 1);
 82b:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 82e:	83 c4 04             	add    $0x4,%esp
 831:	5b                   	pop    %ebx
 832:	5d                   	pop    %ebp
 833:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 834:	8b 10                	mov    (%eax),%edx
 836:	89 11                	mov    %edx,(%ecx)
 838:	eb eb                	jmp    825 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83a:	89 c1                	mov    %eax,%ecx
 83c:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 83e:	8b 50 04             	mov    0x4(%eax),%edx
 841:	39 da                	cmp    %ebx,%edx
 843:	73 d1                	jae    816 <malloc+0x46>
    if(p == freep)
 845:	39 05 34 0c 00 00    	cmp    %eax,0xc34
 84b:	75 ed                	jne    83a <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 84d:	89 d8                	mov    %ebx,%eax
 84f:	e8 2c ff ff ff       	call   780 <morecore>
 854:	85 c0                	test   %eax,%eax
 856:	75 e2                	jne    83a <malloc+0x6a>
        return 0;
 858:	b8 00 00 00 00       	mov    $0x0,%eax
 85d:	eb cf                	jmp    82e <malloc+0x5e>
