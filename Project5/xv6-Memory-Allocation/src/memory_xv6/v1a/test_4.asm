
_test_4:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 24             	sub    $0x24,%esp
    int numframes = 130;
    int* frames = malloc(numframes * sizeof(int));
  14:	68 08 02 00 00       	push   $0x208
  19:	e8 72 05 00 00       	call   590 <malloc>
  1e:	89 c7                	mov    %eax,%edi
    int* pids = malloc(numframes * sizeof(int));
  20:	c7 04 24 08 02 00 00 	movl   $0x208,(%esp)
  27:	e8 64 05 00 00       	call   590 <malloc>
  2c:	89 c6                	mov    %eax,%esi
    int flag = dump_physmem(frames, pids, numframes);
  2e:	83 c4 0c             	add    $0xc,%esp
  31:	68 82 00 00 00       	push   $0x82
  36:	50                   	push   %eax
  37:	57                   	push   %edi
  38:	e8 88 02 00 00       	call   2c5 <dump_physmem>
  3d:	89 c3                	mov    %eax,%ebx
    
    int pidd = fork();
  3f:	e8 d9 01 00 00       	call   21d <fork>
  44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pidd==0){
  47:	83 c4 10             	add    $0x10,%esp
  4a:	85 c0                	test   %eax,%eax
  4c:	75 04                	jne    52 <main+0x52>
	if(flag == 0)
  4e:	85 db                	test   %ebx,%ebx
  50:	74 13                	je     65 <main+0x65>
          if(*(pids+i) >-3)
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
    	}
	}
	    
	    if(pidd>0) wait();
  52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  56:	7f 39                	jg     91 <main+0x91>
    wait();
  58:	e8 d0 01 00 00       	call   22d <wait>
    exit();
  5d:	e8 c3 01 00 00       	call   225 <exit>
        for (int i = 0; i < numframes; i++)
  62:	83 c3 01             	add    $0x1,%ebx
  65:	81 fb 81 00 00 00    	cmp    $0x81,%ebx
  6b:	7f e5                	jg     52 <main+0x52>
          if(*(pids+i) >-3)
  6d:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  74:	8b 14 06             	mov    (%esi,%eax,1),%edx
  77:	83 fa fe             	cmp    $0xfffffffe,%edx
  7a:	7c e6                	jl     62 <main+0x62>
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  7c:	52                   	push   %edx
  7d:	ff 34 07             	pushl  (%edi,%eax,1)
  80:	68 20 06 00 00       	push   $0x620
  85:	6a 00                	push   $0x0
  87:	e8 db 02 00 00       	call   367 <printf>
  8c:	83 c4 10             	add    $0x10,%esp
  8f:	eb d1                	jmp    62 <main+0x62>
	    if(pidd>0) wait();
  91:	e8 97 01 00 00       	call   22d <wait>
  96:	eb c0                	jmp    58 <main+0x58>

00000098 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  98:	55                   	push   %ebp
  99:	89 e5                	mov    %esp,%ebp
  9b:	53                   	push   %ebx
  9c:	8b 45 08             	mov    0x8(%ebp),%eax
  9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a2:	89 c2                	mov    %eax,%edx
  a4:	0f b6 19             	movzbl (%ecx),%ebx
  a7:	88 1a                	mov    %bl,(%edx)
  a9:	8d 52 01             	lea    0x1(%edx),%edx
  ac:	8d 49 01             	lea    0x1(%ecx),%ecx
  af:	84 db                	test   %bl,%bl
  b1:	75 f1                	jne    a4 <strcpy+0xc>
    ;
  return os;
}
  b3:	5b                   	pop    %ebx
  b4:	5d                   	pop    %ebp
  b5:	c3                   	ret    

000000b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b6:	55                   	push   %ebp
  b7:	89 e5                	mov    %esp,%ebp
  b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  bf:	eb 06                	jmp    c7 <strcmp+0x11>
    p++, q++;
  c1:	83 c1 01             	add    $0x1,%ecx
  c4:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  c7:	0f b6 01             	movzbl (%ecx),%eax
  ca:	84 c0                	test   %al,%al
  cc:	74 04                	je     d2 <strcmp+0x1c>
  ce:	3a 02                	cmp    (%edx),%al
  d0:	74 ef                	je     c1 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  d2:	0f b6 c0             	movzbl %al,%eax
  d5:	0f b6 12             	movzbl (%edx),%edx
  d8:	29 d0                	sub    %edx,%eax
}
  da:	5d                   	pop    %ebp
  db:	c3                   	ret    

000000dc <strlen>:

uint
strlen(const char *s)
{
  dc:	55                   	push   %ebp
  dd:	89 e5                	mov    %esp,%ebp
  df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  e2:	ba 00 00 00 00       	mov    $0x0,%edx
  e7:	eb 03                	jmp    ec <strlen+0x10>
  e9:	83 c2 01             	add    $0x1,%edx
  ec:	89 d0                	mov    %edx,%eax
  ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  f2:	75 f5                	jne    e9 <strlen+0xd>
    ;
  return n;
}
  f4:	5d                   	pop    %ebp
  f5:	c3                   	ret    

000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  f9:	57                   	push   %edi
  fa:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  fd:	89 d7                	mov    %edx,%edi
  ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
 102:	8b 45 0c             	mov    0xc(%ebp),%eax
 105:	fc                   	cld    
 106:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 108:	89 d0                	mov    %edx,%eax
 10a:	5f                   	pop    %edi
 10b:	5d                   	pop    %ebp
 10c:	c3                   	ret    

0000010d <strchr>:

char*
strchr(const char *s, char c)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	8b 45 08             	mov    0x8(%ebp),%eax
 113:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 117:	0f b6 10             	movzbl (%eax),%edx
 11a:	84 d2                	test   %dl,%dl
 11c:	74 09                	je     127 <strchr+0x1a>
    if(*s == c)
 11e:	38 ca                	cmp    %cl,%dl
 120:	74 0a                	je     12c <strchr+0x1f>
  for(; *s; s++)
 122:	83 c0 01             	add    $0x1,%eax
 125:	eb f0                	jmp    117 <strchr+0xa>
      return (char*)s;
  return 0;
 127:	b8 00 00 00 00       	mov    $0x0,%eax
}
 12c:	5d                   	pop    %ebp
 12d:	c3                   	ret    

0000012e <gets>:

char*
gets(char *buf, int max)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
 131:	57                   	push   %edi
 132:	56                   	push   %esi
 133:	53                   	push   %ebx
 134:	83 ec 1c             	sub    $0x1c,%esp
 137:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13a:	bb 00 00 00 00       	mov    $0x0,%ebx
 13f:	8d 73 01             	lea    0x1(%ebx),%esi
 142:	3b 75 0c             	cmp    0xc(%ebp),%esi
 145:	7d 2e                	jge    175 <gets+0x47>
    cc = read(0, &c, 1);
 147:	83 ec 04             	sub    $0x4,%esp
 14a:	6a 01                	push   $0x1
 14c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 14f:	50                   	push   %eax
 150:	6a 00                	push   $0x0
 152:	e8 e6 00 00 00       	call   23d <read>
    if(cc < 1)
 157:	83 c4 10             	add    $0x10,%esp
 15a:	85 c0                	test   %eax,%eax
 15c:	7e 17                	jle    175 <gets+0x47>
      break;
    buf[i++] = c;
 15e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 162:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 165:	3c 0a                	cmp    $0xa,%al
 167:	0f 94 c2             	sete   %dl
 16a:	3c 0d                	cmp    $0xd,%al
 16c:	0f 94 c0             	sete   %al
    buf[i++] = c;
 16f:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 171:	08 c2                	or     %al,%dl
 173:	74 ca                	je     13f <gets+0x11>
      break;
  }
  buf[i] = '\0';
 175:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 179:	89 f8                	mov    %edi,%eax
 17b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 17e:	5b                   	pop    %ebx
 17f:	5e                   	pop    %esi
 180:	5f                   	pop    %edi
 181:	5d                   	pop    %ebp
 182:	c3                   	ret    

00000183 <stat>:

int
stat(const char *n, struct stat *st)
{
 183:	55                   	push   %ebp
 184:	89 e5                	mov    %esp,%ebp
 186:	56                   	push   %esi
 187:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 188:	83 ec 08             	sub    $0x8,%esp
 18b:	6a 00                	push   $0x0
 18d:	ff 75 08             	pushl  0x8(%ebp)
 190:	e8 d0 00 00 00       	call   265 <open>
  if(fd < 0)
 195:	83 c4 10             	add    $0x10,%esp
 198:	85 c0                	test   %eax,%eax
 19a:	78 24                	js     1c0 <stat+0x3d>
 19c:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 19e:	83 ec 08             	sub    $0x8,%esp
 1a1:	ff 75 0c             	pushl  0xc(%ebp)
 1a4:	50                   	push   %eax
 1a5:	e8 d3 00 00 00       	call   27d <fstat>
 1aa:	89 c6                	mov    %eax,%esi
  close(fd);
 1ac:	89 1c 24             	mov    %ebx,(%esp)
 1af:	e8 99 00 00 00       	call   24d <close>
  return r;
 1b4:	83 c4 10             	add    $0x10,%esp
}
 1b7:	89 f0                	mov    %esi,%eax
 1b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1bc:	5b                   	pop    %ebx
 1bd:	5e                   	pop    %esi
 1be:	5d                   	pop    %ebp
 1bf:	c3                   	ret    
    return -1;
 1c0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1c5:	eb f0                	jmp    1b7 <stat+0x34>

000001c7 <atoi>:

int
atoi(const char *s)
{
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	53                   	push   %ebx
 1cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1ce:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1d3:	eb 10                	jmp    1e5 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1d5:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1d8:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1db:	83 c1 01             	add    $0x1,%ecx
 1de:	0f be d2             	movsbl %dl,%edx
 1e1:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1e5:	0f b6 11             	movzbl (%ecx),%edx
 1e8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1eb:	80 fb 09             	cmp    $0x9,%bl
 1ee:	76 e5                	jbe    1d5 <atoi+0xe>
  return n;
}
 1f0:	5b                   	pop    %ebx
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    

000001f3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	56                   	push   %esi
 1f7:	53                   	push   %ebx
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1fe:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 201:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 203:	eb 0d                	jmp    212 <memmove+0x1f>
    *dst++ = *src++;
 205:	0f b6 13             	movzbl (%ebx),%edx
 208:	88 11                	mov    %dl,(%ecx)
 20a:	8d 5b 01             	lea    0x1(%ebx),%ebx
 20d:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 210:	89 f2                	mov    %esi,%edx
 212:	8d 72 ff             	lea    -0x1(%edx),%esi
 215:	85 d2                	test   %edx,%edx
 217:	7f ec                	jg     205 <memmove+0x12>
  return vdst;
}
 219:	5b                   	pop    %ebx
 21a:	5e                   	pop    %esi
 21b:	5d                   	pop    %ebp
 21c:	c3                   	ret    

0000021d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 21d:	b8 01 00 00 00       	mov    $0x1,%eax
 222:	cd 40                	int    $0x40
 224:	c3                   	ret    

00000225 <exit>:
SYSCALL(exit)
 225:	b8 02 00 00 00       	mov    $0x2,%eax
 22a:	cd 40                	int    $0x40
 22c:	c3                   	ret    

0000022d <wait>:
SYSCALL(wait)
 22d:	b8 03 00 00 00       	mov    $0x3,%eax
 232:	cd 40                	int    $0x40
 234:	c3                   	ret    

00000235 <pipe>:
SYSCALL(pipe)
 235:	b8 04 00 00 00       	mov    $0x4,%eax
 23a:	cd 40                	int    $0x40
 23c:	c3                   	ret    

0000023d <read>:
SYSCALL(read)
 23d:	b8 05 00 00 00       	mov    $0x5,%eax
 242:	cd 40                	int    $0x40
 244:	c3                   	ret    

00000245 <write>:
SYSCALL(write)
 245:	b8 10 00 00 00       	mov    $0x10,%eax
 24a:	cd 40                	int    $0x40
 24c:	c3                   	ret    

0000024d <close>:
SYSCALL(close)
 24d:	b8 15 00 00 00       	mov    $0x15,%eax
 252:	cd 40                	int    $0x40
 254:	c3                   	ret    

00000255 <kill>:
SYSCALL(kill)
 255:	b8 06 00 00 00       	mov    $0x6,%eax
 25a:	cd 40                	int    $0x40
 25c:	c3                   	ret    

0000025d <exec>:
SYSCALL(exec)
 25d:	b8 07 00 00 00       	mov    $0x7,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <open>:
SYSCALL(open)
 265:	b8 0f 00 00 00       	mov    $0xf,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <mknod>:
SYSCALL(mknod)
 26d:	b8 11 00 00 00       	mov    $0x11,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <unlink>:
SYSCALL(unlink)
 275:	b8 12 00 00 00       	mov    $0x12,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <fstat>:
SYSCALL(fstat)
 27d:	b8 08 00 00 00       	mov    $0x8,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <link>:
SYSCALL(link)
 285:	b8 13 00 00 00       	mov    $0x13,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <mkdir>:
SYSCALL(mkdir)
 28d:	b8 14 00 00 00       	mov    $0x14,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <chdir>:
SYSCALL(chdir)
 295:	b8 09 00 00 00       	mov    $0x9,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <dup>:
SYSCALL(dup)
 29d:	b8 0a 00 00 00       	mov    $0xa,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <getpid>:
SYSCALL(getpid)
 2a5:	b8 0b 00 00 00       	mov    $0xb,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <sbrk>:
SYSCALL(sbrk)
 2ad:	b8 0c 00 00 00       	mov    $0xc,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <sleep>:
SYSCALL(sleep)
 2b5:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <uptime>:
SYSCALL(uptime)
 2bd:	b8 0e 00 00 00       	mov    $0xe,%eax
 2c2:	cd 40                	int    $0x40
 2c4:	c3                   	ret    

000002c5 <dump_physmem>:
SYSCALL(dump_physmem)
 2c5:	b8 16 00 00 00       	mov    $0x16,%eax
 2ca:	cd 40                	int    $0x40
 2cc:	c3                   	ret    

000002cd <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	83 ec 1c             	sub    $0x1c,%esp
 2d3:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2d6:	6a 01                	push   $0x1
 2d8:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2db:	52                   	push   %edx
 2dc:	50                   	push   %eax
 2dd:	e8 63 ff ff ff       	call   245 <write>
}
 2e2:	83 c4 10             	add    $0x10,%esp
 2e5:	c9                   	leave  
 2e6:	c3                   	ret    

000002e7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	57                   	push   %edi
 2eb:	56                   	push   %esi
 2ec:	53                   	push   %ebx
 2ed:	83 ec 2c             	sub    $0x2c,%esp
 2f0:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2f6:	0f 95 c3             	setne  %bl
 2f9:	89 d0                	mov    %edx,%eax
 2fb:	c1 e8 1f             	shr    $0x1f,%eax
 2fe:	84 c3                	test   %al,%bl
 300:	74 10                	je     312 <printint+0x2b>
    neg = 1;
    x = -xx;
 302:	f7 da                	neg    %edx
    neg = 1;
 304:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 30b:	be 00 00 00 00       	mov    $0x0,%esi
 310:	eb 0b                	jmp    31d <printint+0x36>
  neg = 0;
 312:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 319:	eb f0                	jmp    30b <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 31b:	89 c6                	mov    %eax,%esi
 31d:	89 d0                	mov    %edx,%eax
 31f:	ba 00 00 00 00       	mov    $0x0,%edx
 324:	f7 f1                	div    %ecx
 326:	89 c3                	mov    %eax,%ebx
 328:	8d 46 01             	lea    0x1(%esi),%eax
 32b:	0f b6 92 3c 06 00 00 	movzbl 0x63c(%edx),%edx
 332:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 336:	89 da                	mov    %ebx,%edx
 338:	85 db                	test   %ebx,%ebx
 33a:	75 df                	jne    31b <printint+0x34>
 33c:	89 c3                	mov    %eax,%ebx
  if(neg)
 33e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 342:	74 16                	je     35a <printint+0x73>
    buf[i++] = '-';
 344:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 349:	8d 5e 02             	lea    0x2(%esi),%ebx
 34c:	eb 0c                	jmp    35a <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 34e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 353:	89 f8                	mov    %edi,%eax
 355:	e8 73 ff ff ff       	call   2cd <putc>
  while(--i >= 0)
 35a:	83 eb 01             	sub    $0x1,%ebx
 35d:	79 ef                	jns    34e <printint+0x67>
}
 35f:	83 c4 2c             	add    $0x2c,%esp
 362:	5b                   	pop    %ebx
 363:	5e                   	pop    %esi
 364:	5f                   	pop    %edi
 365:	5d                   	pop    %ebp
 366:	c3                   	ret    

00000367 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
 36a:	57                   	push   %edi
 36b:	56                   	push   %esi
 36c:	53                   	push   %ebx
 36d:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 370:	8d 45 10             	lea    0x10(%ebp),%eax
 373:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 376:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 37b:	bb 00 00 00 00       	mov    $0x0,%ebx
 380:	eb 14                	jmp    396 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 382:	89 fa                	mov    %edi,%edx
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	e8 41 ff ff ff       	call   2cd <putc>
 38c:	eb 05                	jmp    393 <printf+0x2c>
      }
    } else if(state == '%'){
 38e:	83 fe 25             	cmp    $0x25,%esi
 391:	74 25                	je     3b8 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 393:	83 c3 01             	add    $0x1,%ebx
 396:	8b 45 0c             	mov    0xc(%ebp),%eax
 399:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 39d:	84 c0                	test   %al,%al
 39f:	0f 84 23 01 00 00    	je     4c8 <printf+0x161>
    c = fmt[i] & 0xff;
 3a5:	0f be f8             	movsbl %al,%edi
 3a8:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3ab:	85 f6                	test   %esi,%esi
 3ad:	75 df                	jne    38e <printf+0x27>
      if(c == '%'){
 3af:	83 f8 25             	cmp    $0x25,%eax
 3b2:	75 ce                	jne    382 <printf+0x1b>
        state = '%';
 3b4:	89 c6                	mov    %eax,%esi
 3b6:	eb db                	jmp    393 <printf+0x2c>
      if(c == 'd'){
 3b8:	83 f8 64             	cmp    $0x64,%eax
 3bb:	74 49                	je     406 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3bd:	83 f8 78             	cmp    $0x78,%eax
 3c0:	0f 94 c1             	sete   %cl
 3c3:	83 f8 70             	cmp    $0x70,%eax
 3c6:	0f 94 c2             	sete   %dl
 3c9:	08 d1                	or     %dl,%cl
 3cb:	75 63                	jne    430 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3cd:	83 f8 73             	cmp    $0x73,%eax
 3d0:	0f 84 84 00 00 00    	je     45a <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3d6:	83 f8 63             	cmp    $0x63,%eax
 3d9:	0f 84 b7 00 00 00    	je     496 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3df:	83 f8 25             	cmp    $0x25,%eax
 3e2:	0f 84 cc 00 00 00    	je     4b4 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3e8:	ba 25 00 00 00       	mov    $0x25,%edx
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	e8 d8 fe ff ff       	call   2cd <putc>
        putc(fd, c);
 3f5:	89 fa                	mov    %edi,%edx
 3f7:	8b 45 08             	mov    0x8(%ebp),%eax
 3fa:	e8 ce fe ff ff       	call   2cd <putc>
      }
      state = 0;
 3ff:	be 00 00 00 00       	mov    $0x0,%esi
 404:	eb 8d                	jmp    393 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 409:	8b 17                	mov    (%edi),%edx
 40b:	83 ec 0c             	sub    $0xc,%esp
 40e:	6a 01                	push   $0x1
 410:	b9 0a 00 00 00       	mov    $0xa,%ecx
 415:	8b 45 08             	mov    0x8(%ebp),%eax
 418:	e8 ca fe ff ff       	call   2e7 <printint>
        ap++;
 41d:	83 c7 04             	add    $0x4,%edi
 420:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 423:	83 c4 10             	add    $0x10,%esp
      state = 0;
 426:	be 00 00 00 00       	mov    $0x0,%esi
 42b:	e9 63 ff ff ff       	jmp    393 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 433:	8b 17                	mov    (%edi),%edx
 435:	83 ec 0c             	sub    $0xc,%esp
 438:	6a 00                	push   $0x0
 43a:	b9 10 00 00 00       	mov    $0x10,%ecx
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	e8 a0 fe ff ff       	call   2e7 <printint>
        ap++;
 447:	83 c7 04             	add    $0x4,%edi
 44a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 44d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 450:	be 00 00 00 00       	mov    $0x0,%esi
 455:	e9 39 ff ff ff       	jmp    393 <printf+0x2c>
        s = (char*)*ap;
 45a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 45d:	8b 30                	mov    (%eax),%esi
        ap++;
 45f:	83 c0 04             	add    $0x4,%eax
 462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 465:	85 f6                	test   %esi,%esi
 467:	75 28                	jne    491 <printf+0x12a>
          s = "(null)";
 469:	be 35 06 00 00       	mov    $0x635,%esi
 46e:	8b 7d 08             	mov    0x8(%ebp),%edi
 471:	eb 0d                	jmp    480 <printf+0x119>
          putc(fd, *s);
 473:	0f be d2             	movsbl %dl,%edx
 476:	89 f8                	mov    %edi,%eax
 478:	e8 50 fe ff ff       	call   2cd <putc>
          s++;
 47d:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 480:	0f b6 16             	movzbl (%esi),%edx
 483:	84 d2                	test   %dl,%dl
 485:	75 ec                	jne    473 <printf+0x10c>
      state = 0;
 487:	be 00 00 00 00       	mov    $0x0,%esi
 48c:	e9 02 ff ff ff       	jmp    393 <printf+0x2c>
 491:	8b 7d 08             	mov    0x8(%ebp),%edi
 494:	eb ea                	jmp    480 <printf+0x119>
        putc(fd, *ap);
 496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 499:	0f be 17             	movsbl (%edi),%edx
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	e8 29 fe ff ff       	call   2cd <putc>
        ap++;
 4a4:	83 c7 04             	add    $0x4,%edi
 4a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4aa:	be 00 00 00 00       	mov    $0x0,%esi
 4af:	e9 df fe ff ff       	jmp    393 <printf+0x2c>
        putc(fd, c);
 4b4:	89 fa                	mov    %edi,%edx
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	e8 0f fe ff ff       	call   2cd <putc>
      state = 0;
 4be:	be 00 00 00 00       	mov    $0x0,%esi
 4c3:	e9 cb fe ff ff       	jmp    393 <printf+0x2c>
    }
  }
}
 4c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4cb:	5b                   	pop    %ebx
 4cc:	5e                   	pop    %esi
 4cd:	5f                   	pop    %edi
 4ce:	5d                   	pop    %ebp
 4cf:	c3                   	ret    

000004d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	57                   	push   %edi
 4d4:	56                   	push   %esi
 4d5:	53                   	push   %ebx
 4d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4d9:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4dc:	a1 e0 08 00 00       	mov    0x8e0,%eax
 4e1:	eb 02                	jmp    4e5 <free+0x15>
 4e3:	89 d0                	mov    %edx,%eax
 4e5:	39 c8                	cmp    %ecx,%eax
 4e7:	73 04                	jae    4ed <free+0x1d>
 4e9:	39 08                	cmp    %ecx,(%eax)
 4eb:	77 12                	ja     4ff <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4ed:	8b 10                	mov    (%eax),%edx
 4ef:	39 c2                	cmp    %eax,%edx
 4f1:	77 f0                	ja     4e3 <free+0x13>
 4f3:	39 c8                	cmp    %ecx,%eax
 4f5:	72 08                	jb     4ff <free+0x2f>
 4f7:	39 ca                	cmp    %ecx,%edx
 4f9:	77 04                	ja     4ff <free+0x2f>
 4fb:	89 d0                	mov    %edx,%eax
 4fd:	eb e6                	jmp    4e5 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ff:	8b 73 fc             	mov    -0x4(%ebx),%esi
 502:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 505:	8b 10                	mov    (%eax),%edx
 507:	39 d7                	cmp    %edx,%edi
 509:	74 19                	je     524 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 50b:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 50e:	8b 50 04             	mov    0x4(%eax),%edx
 511:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 514:	39 ce                	cmp    %ecx,%esi
 516:	74 1b                	je     533 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 518:	89 08                	mov    %ecx,(%eax)
  freep = p;
 51a:	a3 e0 08 00 00       	mov    %eax,0x8e0
}
 51f:	5b                   	pop    %ebx
 520:	5e                   	pop    %esi
 521:	5f                   	pop    %edi
 522:	5d                   	pop    %ebp
 523:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 524:	03 72 04             	add    0x4(%edx),%esi
 527:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 52a:	8b 10                	mov    (%eax),%edx
 52c:	8b 12                	mov    (%edx),%edx
 52e:	89 53 f8             	mov    %edx,-0x8(%ebx)
 531:	eb db                	jmp    50e <free+0x3e>
    p->s.size += bp->s.size;
 533:	03 53 fc             	add    -0x4(%ebx),%edx
 536:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 539:	8b 53 f8             	mov    -0x8(%ebx),%edx
 53c:	89 10                	mov    %edx,(%eax)
 53e:	eb da                	jmp    51a <free+0x4a>

00000540 <morecore>:

static Header*
morecore(uint nu)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
 543:	53                   	push   %ebx
 544:	83 ec 04             	sub    $0x4,%esp
 547:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 549:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 54e:	77 05                	ja     555 <morecore+0x15>
    nu = 4096;
 550:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 555:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 55c:	83 ec 0c             	sub    $0xc,%esp
 55f:	50                   	push   %eax
 560:	e8 48 fd ff ff       	call   2ad <sbrk>
  if(p == (char*)-1)
 565:	83 c4 10             	add    $0x10,%esp
 568:	83 f8 ff             	cmp    $0xffffffff,%eax
 56b:	74 1c                	je     589 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 56d:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 570:	83 c0 08             	add    $0x8,%eax
 573:	83 ec 0c             	sub    $0xc,%esp
 576:	50                   	push   %eax
 577:	e8 54 ff ff ff       	call   4d0 <free>
  return freep;
 57c:	a1 e0 08 00 00       	mov    0x8e0,%eax
 581:	83 c4 10             	add    $0x10,%esp
}
 584:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 587:	c9                   	leave  
 588:	c3                   	ret    
    return 0;
 589:	b8 00 00 00 00       	mov    $0x0,%eax
 58e:	eb f4                	jmp    584 <morecore+0x44>

00000590 <malloc>:

void*
malloc(uint nbytes)
{
 590:	55                   	push   %ebp
 591:	89 e5                	mov    %esp,%ebp
 593:	53                   	push   %ebx
 594:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	8d 58 07             	lea    0x7(%eax),%ebx
 59d:	c1 eb 03             	shr    $0x3,%ebx
 5a0:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5a3:	8b 0d e0 08 00 00    	mov    0x8e0,%ecx
 5a9:	85 c9                	test   %ecx,%ecx
 5ab:	74 04                	je     5b1 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ad:	8b 01                	mov    (%ecx),%eax
 5af:	eb 4d                	jmp    5fe <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5b1:	c7 05 e0 08 00 00 e4 	movl   $0x8e4,0x8e0
 5b8:	08 00 00 
 5bb:	c7 05 e4 08 00 00 e4 	movl   $0x8e4,0x8e4
 5c2:	08 00 00 
    base.s.size = 0;
 5c5:	c7 05 e8 08 00 00 00 	movl   $0x0,0x8e8
 5cc:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5cf:	b9 e4 08 00 00       	mov    $0x8e4,%ecx
 5d4:	eb d7                	jmp    5ad <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5d6:	39 da                	cmp    %ebx,%edx
 5d8:	74 1a                	je     5f4 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5da:	29 da                	sub    %ebx,%edx
 5dc:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5df:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5e2:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5e5:	89 0d e0 08 00 00    	mov    %ecx,0x8e0
      return (void*)(p + 1);
 5eb:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5ee:	83 c4 04             	add    $0x4,%esp
 5f1:	5b                   	pop    %ebx
 5f2:	5d                   	pop    %ebp
 5f3:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5f4:	8b 10                	mov    (%eax),%edx
 5f6:	89 11                	mov    %edx,(%ecx)
 5f8:	eb eb                	jmp    5e5 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5fa:	89 c1                	mov    %eax,%ecx
 5fc:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5fe:	8b 50 04             	mov    0x4(%eax),%edx
 601:	39 da                	cmp    %ebx,%edx
 603:	73 d1                	jae    5d6 <malloc+0x46>
    if(p == freep)
 605:	39 05 e0 08 00 00    	cmp    %eax,0x8e0
 60b:	75 ed                	jne    5fa <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 60d:	89 d8                	mov    %ebx,%eax
 60f:	e8 2c ff ff ff       	call   540 <morecore>
 614:	85 c0                	test   %eax,%eax
 616:	75 e2                	jne    5fa <malloc+0x6a>
        return 0;
 618:	b8 00 00 00 00       	mov    $0x0,%eax
 61d:	eb cf                	jmp    5ee <malloc+0x5e>
