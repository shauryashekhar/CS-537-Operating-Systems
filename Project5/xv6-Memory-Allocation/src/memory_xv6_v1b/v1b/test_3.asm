
_test_3:     file format elf32-i386


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
  11:	83 ec 14             	sub    $0x14,%esp
    int numframes = 1;
    int* frames = malloc(numframes * sizeof(int));
  14:	6a 04                	push   $0x4
  16:	e8 65 05 00 00       	call   580 <malloc>
  1b:	89 c7                	mov    %eax,%edi
    int* pids = malloc(numframes * sizeof(int));
  1d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  24:	e8 57 05 00 00       	call   580 <malloc>
  29:	89 c6                	mov    %eax,%esi
    int flag = dump_physmem(frames, pids, numframes);
  2b:	83 c4 0c             	add    $0xc,%esp
  2e:	6a 01                	push   $0x1
  30:	50                   	push   %eax
  31:	57                   	push   %edi
  32:	e8 7e 02 00 00       	call   2b5 <dump_physmem>
    
    if(flag == 0)
  37:	83 c4 10             	add    $0x10,%esp
  3a:	85 c0                	test   %eax,%eax
  3c:	74 1c                	je     5a <main+0x5a>
          if(*(pids+i) > 0)
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
    }
    else// if(flag == -1)
    {
        printf(0,"error\n");
  3e:	83 ec 08             	sub    $0x8,%esp
  41:	68 25 06 00 00       	push   $0x625
  46:	6a 00                	push   $0x0
  48:	e8 0a 03 00 00       	call   357 <printf>
  4d:	83 c4 10             	add    $0x10,%esp
    }
    wait();
  50:	e8 c8 01 00 00       	call   21d <wait>
    exit();
  55:	e8 bb 01 00 00       	call   215 <exit>
  5a:	89 c3                	mov    %eax,%ebx
        for (int i = 0; i < numframes; i++)
  5c:	85 db                	test   %ebx,%ebx
  5e:	7f f0                	jg     50 <main+0x50>
          if(*(pids+i) > 0)
  60:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  67:	8b 14 06             	mov    (%esi,%eax,1),%edx
  6a:	85 d2                	test   %edx,%edx
  6c:	7f 05                	jg     73 <main+0x73>
        for (int i = 0; i < numframes; i++)
  6e:	83 c3 01             	add    $0x1,%ebx
  71:	eb e9                	jmp    5c <main+0x5c>
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  73:	52                   	push   %edx
  74:	ff 34 07             	pushl  (%edi,%eax,1)
  77:	68 10 06 00 00       	push   $0x610
  7c:	6a 00                	push   $0x0
  7e:	e8 d4 02 00 00       	call   357 <printf>
  83:	83 c4 10             	add    $0x10,%esp
  86:	eb e6                	jmp    6e <main+0x6e>

00000088 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  88:	55                   	push   %ebp
  89:	89 e5                	mov    %esp,%ebp
  8b:	53                   	push   %ebx
  8c:	8b 45 08             	mov    0x8(%ebp),%eax
  8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  92:	89 c2                	mov    %eax,%edx
  94:	0f b6 19             	movzbl (%ecx),%ebx
  97:	88 1a                	mov    %bl,(%edx)
  99:	8d 52 01             	lea    0x1(%edx),%edx
  9c:	8d 49 01             	lea    0x1(%ecx),%ecx
  9f:	84 db                	test   %bl,%bl
  a1:	75 f1                	jne    94 <strcpy+0xc>
    ;
  return os;
}
  a3:	5b                   	pop    %ebx
  a4:	5d                   	pop    %ebp
  a5:	c3                   	ret    

000000a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a6:	55                   	push   %ebp
  a7:	89 e5                	mov    %esp,%ebp
  a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  af:	eb 06                	jmp    b7 <strcmp+0x11>
    p++, q++;
  b1:	83 c1 01             	add    $0x1,%ecx
  b4:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  b7:	0f b6 01             	movzbl (%ecx),%eax
  ba:	84 c0                	test   %al,%al
  bc:	74 04                	je     c2 <strcmp+0x1c>
  be:	3a 02                	cmp    (%edx),%al
  c0:	74 ef                	je     b1 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  c2:	0f b6 c0             	movzbl %al,%eax
  c5:	0f b6 12             	movzbl (%edx),%edx
  c8:	29 d0                	sub    %edx,%eax
}
  ca:	5d                   	pop    %ebp
  cb:	c3                   	ret    

000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	55                   	push   %ebp
  cd:	89 e5                	mov    %esp,%ebp
  cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  d2:	ba 00 00 00 00       	mov    $0x0,%edx
  d7:	eb 03                	jmp    dc <strlen+0x10>
  d9:	83 c2 01             	add    $0x1,%edx
  dc:	89 d0                	mov    %edx,%eax
  de:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  e2:	75 f5                	jne    d9 <strlen+0xd>
    ;
  return n;
}
  e4:	5d                   	pop    %ebp
  e5:	c3                   	ret    

000000e6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e6:	55                   	push   %ebp
  e7:	89 e5                	mov    %esp,%ebp
  e9:	57                   	push   %edi
  ea:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  ed:	89 d7                	mov    %edx,%edi
  ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  f5:	fc                   	cld    
  f6:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  f8:	89 d0                	mov    %edx,%eax
  fa:	5f                   	pop    %edi
  fb:	5d                   	pop    %ebp
  fc:	c3                   	ret    

000000fd <strchr>:

char*
strchr(const char *s, char c)
{
  fd:	55                   	push   %ebp
  fe:	89 e5                	mov    %esp,%ebp
 100:	8b 45 08             	mov    0x8(%ebp),%eax
 103:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 107:	0f b6 10             	movzbl (%eax),%edx
 10a:	84 d2                	test   %dl,%dl
 10c:	74 09                	je     117 <strchr+0x1a>
    if(*s == c)
 10e:	38 ca                	cmp    %cl,%dl
 110:	74 0a                	je     11c <strchr+0x1f>
  for(; *s; s++)
 112:	83 c0 01             	add    $0x1,%eax
 115:	eb f0                	jmp    107 <strchr+0xa>
      return (char*)s;
  return 0;
 117:	b8 00 00 00 00       	mov    $0x0,%eax
}
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    

0000011e <gets>:

char*
gets(char *buf, int max)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	57                   	push   %edi
 122:	56                   	push   %esi
 123:	53                   	push   %ebx
 124:	83 ec 1c             	sub    $0x1c,%esp
 127:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12a:	bb 00 00 00 00       	mov    $0x0,%ebx
 12f:	8d 73 01             	lea    0x1(%ebx),%esi
 132:	3b 75 0c             	cmp    0xc(%ebp),%esi
 135:	7d 2e                	jge    165 <gets+0x47>
    cc = read(0, &c, 1);
 137:	83 ec 04             	sub    $0x4,%esp
 13a:	6a 01                	push   $0x1
 13c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 13f:	50                   	push   %eax
 140:	6a 00                	push   $0x0
 142:	e8 e6 00 00 00       	call   22d <read>
    if(cc < 1)
 147:	83 c4 10             	add    $0x10,%esp
 14a:	85 c0                	test   %eax,%eax
 14c:	7e 17                	jle    165 <gets+0x47>
      break;
    buf[i++] = c;
 14e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 152:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 155:	3c 0a                	cmp    $0xa,%al
 157:	0f 94 c2             	sete   %dl
 15a:	3c 0d                	cmp    $0xd,%al
 15c:	0f 94 c0             	sete   %al
    buf[i++] = c;
 15f:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 161:	08 c2                	or     %al,%dl
 163:	74 ca                	je     12f <gets+0x11>
      break;
  }
  buf[i] = '\0';
 165:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 169:	89 f8                	mov    %edi,%eax
 16b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 16e:	5b                   	pop    %ebx
 16f:	5e                   	pop    %esi
 170:	5f                   	pop    %edi
 171:	5d                   	pop    %ebp
 172:	c3                   	ret    

00000173 <stat>:

int
stat(const char *n, struct stat *st)
{
 173:	55                   	push   %ebp
 174:	89 e5                	mov    %esp,%ebp
 176:	56                   	push   %esi
 177:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 178:	83 ec 08             	sub    $0x8,%esp
 17b:	6a 00                	push   $0x0
 17d:	ff 75 08             	pushl  0x8(%ebp)
 180:	e8 d0 00 00 00       	call   255 <open>
  if(fd < 0)
 185:	83 c4 10             	add    $0x10,%esp
 188:	85 c0                	test   %eax,%eax
 18a:	78 24                	js     1b0 <stat+0x3d>
 18c:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 18e:	83 ec 08             	sub    $0x8,%esp
 191:	ff 75 0c             	pushl  0xc(%ebp)
 194:	50                   	push   %eax
 195:	e8 d3 00 00 00       	call   26d <fstat>
 19a:	89 c6                	mov    %eax,%esi
  close(fd);
 19c:	89 1c 24             	mov    %ebx,(%esp)
 19f:	e8 99 00 00 00       	call   23d <close>
  return r;
 1a4:	83 c4 10             	add    $0x10,%esp
}
 1a7:	89 f0                	mov    %esi,%eax
 1a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1ac:	5b                   	pop    %ebx
 1ad:	5e                   	pop    %esi
 1ae:	5d                   	pop    %ebp
 1af:	c3                   	ret    
    return -1;
 1b0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b5:	eb f0                	jmp    1a7 <stat+0x34>

000001b7 <atoi>:

int
atoi(const char *s)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	53                   	push   %ebx
 1bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1be:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1c3:	eb 10                	jmp    1d5 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1c5:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1c8:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1cb:	83 c1 01             	add    $0x1,%ecx
 1ce:	0f be d2             	movsbl %dl,%edx
 1d1:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1d5:	0f b6 11             	movzbl (%ecx),%edx
 1d8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1db:	80 fb 09             	cmp    $0x9,%bl
 1de:	76 e5                	jbe    1c5 <atoi+0xe>
  return n;
}
 1e0:	5b                   	pop    %ebx
 1e1:	5d                   	pop    %ebp
 1e2:	c3                   	ret    

000001e3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e3:	55                   	push   %ebp
 1e4:	89 e5                	mov    %esp,%ebp
 1e6:	56                   	push   %esi
 1e7:	53                   	push   %ebx
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
 1eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1ee:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1f1:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1f3:	eb 0d                	jmp    202 <memmove+0x1f>
    *dst++ = *src++;
 1f5:	0f b6 13             	movzbl (%ebx),%edx
 1f8:	88 11                	mov    %dl,(%ecx)
 1fa:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1fd:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 200:	89 f2                	mov    %esi,%edx
 202:	8d 72 ff             	lea    -0x1(%edx),%esi
 205:	85 d2                	test   %edx,%edx
 207:	7f ec                	jg     1f5 <memmove+0x12>
  return vdst;
}
 209:	5b                   	pop    %ebx
 20a:	5e                   	pop    %esi
 20b:	5d                   	pop    %ebp
 20c:	c3                   	ret    

0000020d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 20d:	b8 01 00 00 00       	mov    $0x1,%eax
 212:	cd 40                	int    $0x40
 214:	c3                   	ret    

00000215 <exit>:
SYSCALL(exit)
 215:	b8 02 00 00 00       	mov    $0x2,%eax
 21a:	cd 40                	int    $0x40
 21c:	c3                   	ret    

0000021d <wait>:
SYSCALL(wait)
 21d:	b8 03 00 00 00       	mov    $0x3,%eax
 222:	cd 40                	int    $0x40
 224:	c3                   	ret    

00000225 <pipe>:
SYSCALL(pipe)
 225:	b8 04 00 00 00       	mov    $0x4,%eax
 22a:	cd 40                	int    $0x40
 22c:	c3                   	ret    

0000022d <read>:
SYSCALL(read)
 22d:	b8 05 00 00 00       	mov    $0x5,%eax
 232:	cd 40                	int    $0x40
 234:	c3                   	ret    

00000235 <write>:
SYSCALL(write)
 235:	b8 10 00 00 00       	mov    $0x10,%eax
 23a:	cd 40                	int    $0x40
 23c:	c3                   	ret    

0000023d <close>:
SYSCALL(close)
 23d:	b8 15 00 00 00       	mov    $0x15,%eax
 242:	cd 40                	int    $0x40
 244:	c3                   	ret    

00000245 <kill>:
SYSCALL(kill)
 245:	b8 06 00 00 00       	mov    $0x6,%eax
 24a:	cd 40                	int    $0x40
 24c:	c3                   	ret    

0000024d <exec>:
SYSCALL(exec)
 24d:	b8 07 00 00 00       	mov    $0x7,%eax
 252:	cd 40                	int    $0x40
 254:	c3                   	ret    

00000255 <open>:
SYSCALL(open)
 255:	b8 0f 00 00 00       	mov    $0xf,%eax
 25a:	cd 40                	int    $0x40
 25c:	c3                   	ret    

0000025d <mknod>:
SYSCALL(mknod)
 25d:	b8 11 00 00 00       	mov    $0x11,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <unlink>:
SYSCALL(unlink)
 265:	b8 12 00 00 00       	mov    $0x12,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <fstat>:
SYSCALL(fstat)
 26d:	b8 08 00 00 00       	mov    $0x8,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <link>:
SYSCALL(link)
 275:	b8 13 00 00 00       	mov    $0x13,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <mkdir>:
SYSCALL(mkdir)
 27d:	b8 14 00 00 00       	mov    $0x14,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <chdir>:
SYSCALL(chdir)
 285:	b8 09 00 00 00       	mov    $0x9,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <dup>:
SYSCALL(dup)
 28d:	b8 0a 00 00 00       	mov    $0xa,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <getpid>:
SYSCALL(getpid)
 295:	b8 0b 00 00 00       	mov    $0xb,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <sbrk>:
SYSCALL(sbrk)
 29d:	b8 0c 00 00 00       	mov    $0xc,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <sleep>:
SYSCALL(sleep)
 2a5:	b8 0d 00 00 00       	mov    $0xd,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <uptime>:
SYSCALL(uptime)
 2ad:	b8 0e 00 00 00       	mov    $0xe,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <dump_physmem>:
SYSCALL(dump_physmem)
 2b5:	b8 16 00 00 00       	mov    $0x16,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2bd:	55                   	push   %ebp
 2be:	89 e5                	mov    %esp,%ebp
 2c0:	83 ec 1c             	sub    $0x1c,%esp
 2c3:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c6:	6a 01                	push   $0x1
 2c8:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2cb:	52                   	push   %edx
 2cc:	50                   	push   %eax
 2cd:	e8 63 ff ff ff       	call   235 <write>
}
 2d2:	83 c4 10             	add    $0x10,%esp
 2d5:	c9                   	leave  
 2d6:	c3                   	ret    

000002d7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	57                   	push   %edi
 2db:	56                   	push   %esi
 2dc:	53                   	push   %ebx
 2dd:	83 ec 2c             	sub    $0x2c,%esp
 2e0:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e6:	0f 95 c3             	setne  %bl
 2e9:	89 d0                	mov    %edx,%eax
 2eb:	c1 e8 1f             	shr    $0x1f,%eax
 2ee:	84 c3                	test   %al,%bl
 2f0:	74 10                	je     302 <printint+0x2b>
    neg = 1;
    x = -xx;
 2f2:	f7 da                	neg    %edx
    neg = 1;
 2f4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2fb:	be 00 00 00 00       	mov    $0x0,%esi
 300:	eb 0b                	jmp    30d <printint+0x36>
  neg = 0;
 302:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 309:	eb f0                	jmp    2fb <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 30b:	89 c6                	mov    %eax,%esi
 30d:	89 d0                	mov    %edx,%eax
 30f:	ba 00 00 00 00       	mov    $0x0,%edx
 314:	f7 f1                	div    %ecx
 316:	89 c3                	mov    %eax,%ebx
 318:	8d 46 01             	lea    0x1(%esi),%eax
 31b:	0f b6 92 34 06 00 00 	movzbl 0x634(%edx),%edx
 322:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 326:	89 da                	mov    %ebx,%edx
 328:	85 db                	test   %ebx,%ebx
 32a:	75 df                	jne    30b <printint+0x34>
 32c:	89 c3                	mov    %eax,%ebx
  if(neg)
 32e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 332:	74 16                	je     34a <printint+0x73>
    buf[i++] = '-';
 334:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 339:	8d 5e 02             	lea    0x2(%esi),%ebx
 33c:	eb 0c                	jmp    34a <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 33e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 343:	89 f8                	mov    %edi,%eax
 345:	e8 73 ff ff ff       	call   2bd <putc>
  while(--i >= 0)
 34a:	83 eb 01             	sub    $0x1,%ebx
 34d:	79 ef                	jns    33e <printint+0x67>
}
 34f:	83 c4 2c             	add    $0x2c,%esp
 352:	5b                   	pop    %ebx
 353:	5e                   	pop    %esi
 354:	5f                   	pop    %edi
 355:	5d                   	pop    %ebp
 356:	c3                   	ret    

00000357 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 357:	55                   	push   %ebp
 358:	89 e5                	mov    %esp,%ebp
 35a:	57                   	push   %edi
 35b:	56                   	push   %esi
 35c:	53                   	push   %ebx
 35d:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 360:	8d 45 10             	lea    0x10(%ebp),%eax
 363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 366:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 36b:	bb 00 00 00 00       	mov    $0x0,%ebx
 370:	eb 14                	jmp    386 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 372:	89 fa                	mov    %edi,%edx
 374:	8b 45 08             	mov    0x8(%ebp),%eax
 377:	e8 41 ff ff ff       	call   2bd <putc>
 37c:	eb 05                	jmp    383 <printf+0x2c>
      }
    } else if(state == '%'){
 37e:	83 fe 25             	cmp    $0x25,%esi
 381:	74 25                	je     3a8 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 383:	83 c3 01             	add    $0x1,%ebx
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 38d:	84 c0                	test   %al,%al
 38f:	0f 84 23 01 00 00    	je     4b8 <printf+0x161>
    c = fmt[i] & 0xff;
 395:	0f be f8             	movsbl %al,%edi
 398:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 39b:	85 f6                	test   %esi,%esi
 39d:	75 df                	jne    37e <printf+0x27>
      if(c == '%'){
 39f:	83 f8 25             	cmp    $0x25,%eax
 3a2:	75 ce                	jne    372 <printf+0x1b>
        state = '%';
 3a4:	89 c6                	mov    %eax,%esi
 3a6:	eb db                	jmp    383 <printf+0x2c>
      if(c == 'd'){
 3a8:	83 f8 64             	cmp    $0x64,%eax
 3ab:	74 49                	je     3f6 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3ad:	83 f8 78             	cmp    $0x78,%eax
 3b0:	0f 94 c1             	sete   %cl
 3b3:	83 f8 70             	cmp    $0x70,%eax
 3b6:	0f 94 c2             	sete   %dl
 3b9:	08 d1                	or     %dl,%cl
 3bb:	75 63                	jne    420 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3bd:	83 f8 73             	cmp    $0x73,%eax
 3c0:	0f 84 84 00 00 00    	je     44a <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c6:	83 f8 63             	cmp    $0x63,%eax
 3c9:	0f 84 b7 00 00 00    	je     486 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3cf:	83 f8 25             	cmp    $0x25,%eax
 3d2:	0f 84 cc 00 00 00    	je     4a4 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3d8:	ba 25 00 00 00       	mov    $0x25,%edx
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	e8 d8 fe ff ff       	call   2bd <putc>
        putc(fd, c);
 3e5:	89 fa                	mov    %edi,%edx
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	e8 ce fe ff ff       	call   2bd <putc>
      }
      state = 0;
 3ef:	be 00 00 00 00       	mov    $0x0,%esi
 3f4:	eb 8d                	jmp    383 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f9:	8b 17                	mov    (%edi),%edx
 3fb:	83 ec 0c             	sub    $0xc,%esp
 3fe:	6a 01                	push   $0x1
 400:	b9 0a 00 00 00       	mov    $0xa,%ecx
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	e8 ca fe ff ff       	call   2d7 <printint>
        ap++;
 40d:	83 c7 04             	add    $0x4,%edi
 410:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 413:	83 c4 10             	add    $0x10,%esp
      state = 0;
 416:	be 00 00 00 00       	mov    $0x0,%esi
 41b:	e9 63 ff ff ff       	jmp    383 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 423:	8b 17                	mov    (%edi),%edx
 425:	83 ec 0c             	sub    $0xc,%esp
 428:	6a 00                	push   $0x0
 42a:	b9 10 00 00 00       	mov    $0x10,%ecx
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	e8 a0 fe ff ff       	call   2d7 <printint>
        ap++;
 437:	83 c7 04             	add    $0x4,%edi
 43a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 43d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 440:	be 00 00 00 00       	mov    $0x0,%esi
 445:	e9 39 ff ff ff       	jmp    383 <printf+0x2c>
        s = (char*)*ap;
 44a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44d:	8b 30                	mov    (%eax),%esi
        ap++;
 44f:	83 c0 04             	add    $0x4,%eax
 452:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 455:	85 f6                	test   %esi,%esi
 457:	75 28                	jne    481 <printf+0x12a>
          s = "(null)";
 459:	be 2c 06 00 00       	mov    $0x62c,%esi
 45e:	8b 7d 08             	mov    0x8(%ebp),%edi
 461:	eb 0d                	jmp    470 <printf+0x119>
          putc(fd, *s);
 463:	0f be d2             	movsbl %dl,%edx
 466:	89 f8                	mov    %edi,%eax
 468:	e8 50 fe ff ff       	call   2bd <putc>
          s++;
 46d:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 470:	0f b6 16             	movzbl (%esi),%edx
 473:	84 d2                	test   %dl,%dl
 475:	75 ec                	jne    463 <printf+0x10c>
      state = 0;
 477:	be 00 00 00 00       	mov    $0x0,%esi
 47c:	e9 02 ff ff ff       	jmp    383 <printf+0x2c>
 481:	8b 7d 08             	mov    0x8(%ebp),%edi
 484:	eb ea                	jmp    470 <printf+0x119>
        putc(fd, *ap);
 486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 489:	0f be 17             	movsbl (%edi),%edx
 48c:	8b 45 08             	mov    0x8(%ebp),%eax
 48f:	e8 29 fe ff ff       	call   2bd <putc>
        ap++;
 494:	83 c7 04             	add    $0x4,%edi
 497:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 49a:	be 00 00 00 00       	mov    $0x0,%esi
 49f:	e9 df fe ff ff       	jmp    383 <printf+0x2c>
        putc(fd, c);
 4a4:	89 fa                	mov    %edi,%edx
 4a6:	8b 45 08             	mov    0x8(%ebp),%eax
 4a9:	e8 0f fe ff ff       	call   2bd <putc>
      state = 0;
 4ae:	be 00 00 00 00       	mov    $0x0,%esi
 4b3:	e9 cb fe ff ff       	jmp    383 <printf+0x2c>
    }
  }
}
 4b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4bb:	5b                   	pop    %ebx
 4bc:	5e                   	pop    %esi
 4bd:	5f                   	pop    %edi
 4be:	5d                   	pop    %ebp
 4bf:	c3                   	ret    

000004c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	57                   	push   %edi
 4c4:	56                   	push   %esi
 4c5:	53                   	push   %ebx
 4c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4c9:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4cc:	a1 d8 08 00 00       	mov    0x8d8,%eax
 4d1:	eb 02                	jmp    4d5 <free+0x15>
 4d3:	89 d0                	mov    %edx,%eax
 4d5:	39 c8                	cmp    %ecx,%eax
 4d7:	73 04                	jae    4dd <free+0x1d>
 4d9:	39 08                	cmp    %ecx,(%eax)
 4db:	77 12                	ja     4ef <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4dd:	8b 10                	mov    (%eax),%edx
 4df:	39 c2                	cmp    %eax,%edx
 4e1:	77 f0                	ja     4d3 <free+0x13>
 4e3:	39 c8                	cmp    %ecx,%eax
 4e5:	72 08                	jb     4ef <free+0x2f>
 4e7:	39 ca                	cmp    %ecx,%edx
 4e9:	77 04                	ja     4ef <free+0x2f>
 4eb:	89 d0                	mov    %edx,%eax
 4ed:	eb e6                	jmp    4d5 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ef:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4f2:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4f5:	8b 10                	mov    (%eax),%edx
 4f7:	39 d7                	cmp    %edx,%edi
 4f9:	74 19                	je     514 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4fb:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4fe:	8b 50 04             	mov    0x4(%eax),%edx
 501:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 504:	39 ce                	cmp    %ecx,%esi
 506:	74 1b                	je     523 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 508:	89 08                	mov    %ecx,(%eax)
  freep = p;
 50a:	a3 d8 08 00 00       	mov    %eax,0x8d8
}
 50f:	5b                   	pop    %ebx
 510:	5e                   	pop    %esi
 511:	5f                   	pop    %edi
 512:	5d                   	pop    %ebp
 513:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 514:	03 72 04             	add    0x4(%edx),%esi
 517:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 51a:	8b 10                	mov    (%eax),%edx
 51c:	8b 12                	mov    (%edx),%edx
 51e:	89 53 f8             	mov    %edx,-0x8(%ebx)
 521:	eb db                	jmp    4fe <free+0x3e>
    p->s.size += bp->s.size;
 523:	03 53 fc             	add    -0x4(%ebx),%edx
 526:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 529:	8b 53 f8             	mov    -0x8(%ebx),%edx
 52c:	89 10                	mov    %edx,(%eax)
 52e:	eb da                	jmp    50a <free+0x4a>

00000530 <morecore>:

static Header*
morecore(uint nu)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	53                   	push   %ebx
 534:	83 ec 04             	sub    $0x4,%esp
 537:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 539:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 53e:	77 05                	ja     545 <morecore+0x15>
    nu = 4096;
 540:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 545:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 54c:	83 ec 0c             	sub    $0xc,%esp
 54f:	50                   	push   %eax
 550:	e8 48 fd ff ff       	call   29d <sbrk>
  if(p == (char*)-1)
 555:	83 c4 10             	add    $0x10,%esp
 558:	83 f8 ff             	cmp    $0xffffffff,%eax
 55b:	74 1c                	je     579 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55d:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 560:	83 c0 08             	add    $0x8,%eax
 563:	83 ec 0c             	sub    $0xc,%esp
 566:	50                   	push   %eax
 567:	e8 54 ff ff ff       	call   4c0 <free>
  return freep;
 56c:	a1 d8 08 00 00       	mov    0x8d8,%eax
 571:	83 c4 10             	add    $0x10,%esp
}
 574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 577:	c9                   	leave  
 578:	c3                   	ret    
    return 0;
 579:	b8 00 00 00 00       	mov    $0x0,%eax
 57e:	eb f4                	jmp    574 <morecore+0x44>

00000580 <malloc>:

void*
malloc(uint nbytes)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	53                   	push   %ebx
 584:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	8d 58 07             	lea    0x7(%eax),%ebx
 58d:	c1 eb 03             	shr    $0x3,%ebx
 590:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 593:	8b 0d d8 08 00 00    	mov    0x8d8,%ecx
 599:	85 c9                	test   %ecx,%ecx
 59b:	74 04                	je     5a1 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 59d:	8b 01                	mov    (%ecx),%eax
 59f:	eb 4d                	jmp    5ee <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5a1:	c7 05 d8 08 00 00 dc 	movl   $0x8dc,0x8d8
 5a8:	08 00 00 
 5ab:	c7 05 dc 08 00 00 dc 	movl   $0x8dc,0x8dc
 5b2:	08 00 00 
    base.s.size = 0;
 5b5:	c7 05 e0 08 00 00 00 	movl   $0x0,0x8e0
 5bc:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5bf:	b9 dc 08 00 00       	mov    $0x8dc,%ecx
 5c4:	eb d7                	jmp    59d <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c6:	39 da                	cmp    %ebx,%edx
 5c8:	74 1a                	je     5e4 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5ca:	29 da                	sub    %ebx,%edx
 5cc:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5cf:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5d2:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5d5:	89 0d d8 08 00 00    	mov    %ecx,0x8d8
      return (void*)(p + 1);
 5db:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5de:	83 c4 04             	add    $0x4,%esp
 5e1:	5b                   	pop    %ebx
 5e2:	5d                   	pop    %ebp
 5e3:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5e4:	8b 10                	mov    (%eax),%edx
 5e6:	89 11                	mov    %edx,(%ecx)
 5e8:	eb eb                	jmp    5d5 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ea:	89 c1                	mov    %eax,%ecx
 5ec:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ee:	8b 50 04             	mov    0x4(%eax),%edx
 5f1:	39 da                	cmp    %ebx,%edx
 5f3:	73 d1                	jae    5c6 <malloc+0x46>
    if(p == freep)
 5f5:	39 05 d8 08 00 00    	cmp    %eax,0x8d8
 5fb:	75 ed                	jne    5ea <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5fd:	89 d8                	mov    %ebx,%eax
 5ff:	e8 2c ff ff ff       	call   530 <morecore>
 604:	85 c0                	test   %eax,%eax
 606:	75 e2                	jne    5ea <malloc+0x6a>
        return 0;
 608:	b8 00 00 00 00       	mov    $0x0,%eax
 60d:	eb cf                	jmp    5de <malloc+0x5e>
