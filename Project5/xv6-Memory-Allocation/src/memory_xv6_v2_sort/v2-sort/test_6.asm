
_test_6:     file format elf32-i386


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
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
    int numframes = -1;
    int* frames = malloc(numframes * sizeof(int));
   f:	83 ec 0c             	sub    $0xc,%esp
  12:	6a fc                	push   $0xfffffffc
  14:	e8 37 05 00 00       	call   550 <malloc>
  19:	89 c3                	mov    %eax,%ebx
    int* pids = malloc(numframes * sizeof(int));
  1b:	c7 04 24 fc ff ff ff 	movl   $0xfffffffc,(%esp)
  22:	e8 29 05 00 00       	call   550 <malloc>
    
    int flag = dump_physmem(frames, pids, numframes);
  27:	83 c4 0c             	add    $0xc,%esp
  2a:	6a ff                	push   $0xffffffff
  2c:	50                   	push   %eax
  2d:	53                   	push   %ebx
  2e:	e8 52 02 00 00       	call   285 <dump_physmem>
    
    if(flag == 0)
  33:	83 c4 10             	add    $0x10,%esp
  36:	85 c0                	test   %eax,%eax
  38:	75 0a                	jne    44 <main+0x44>
    }
    else// if(flag == -1)
    {
        printf(0,"error\n");
    }
    wait();
  3a:	e8 ae 01 00 00       	call   1ed <wait>
    exit();
  3f:	e8 a1 01 00 00       	call   1e5 <exit>
        printf(0,"error\n");
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 e0 05 00 00       	push   $0x5e0
  4c:	6a 00                	push   $0x0
  4e:	e8 d4 02 00 00       	call   327 <printf>
  53:	83 c4 10             	add    $0x10,%esp
  56:	eb e2                	jmp    3a <main+0x3a>

00000058 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  58:	55                   	push   %ebp
  59:	89 e5                	mov    %esp,%ebp
  5b:	53                   	push   %ebx
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  62:	89 c2                	mov    %eax,%edx
  64:	0f b6 19             	movzbl (%ecx),%ebx
  67:	88 1a                	mov    %bl,(%edx)
  69:	8d 52 01             	lea    0x1(%edx),%edx
  6c:	8d 49 01             	lea    0x1(%ecx),%ecx
  6f:	84 db                	test   %bl,%bl
  71:	75 f1                	jne    64 <strcpy+0xc>
    ;
  return os;
}
  73:	5b                   	pop    %ebx
  74:	5d                   	pop    %ebp
  75:	c3                   	ret    

00000076 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  7f:	eb 06                	jmp    87 <strcmp+0x11>
    p++, q++;
  81:	83 c1 01             	add    $0x1,%ecx
  84:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  87:	0f b6 01             	movzbl (%ecx),%eax
  8a:	84 c0                	test   %al,%al
  8c:	74 04                	je     92 <strcmp+0x1c>
  8e:	3a 02                	cmp    (%edx),%al
  90:	74 ef                	je     81 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  92:	0f b6 c0             	movzbl %al,%eax
  95:	0f b6 12             	movzbl (%edx),%edx
  98:	29 d0                	sub    %edx,%eax
}
  9a:	5d                   	pop    %ebp
  9b:	c3                   	ret    

0000009c <strlen>:

uint
strlen(const char *s)
{
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  a2:	ba 00 00 00 00       	mov    $0x0,%edx
  a7:	eb 03                	jmp    ac <strlen+0x10>
  a9:	83 c2 01             	add    $0x1,%edx
  ac:	89 d0                	mov    %edx,%eax
  ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  b2:	75 f5                	jne    a9 <strlen+0xd>
    ;
  return n;
}
  b4:	5d                   	pop    %ebp
  b5:	c3                   	ret    

000000b6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b6:	55                   	push   %ebp
  b7:	89 e5                	mov    %esp,%ebp
  b9:	57                   	push   %edi
  ba:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  bd:	89 d7                	mov    %edx,%edi
  bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  c5:	fc                   	cld    
  c6:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  c8:	89 d0                	mov    %edx,%eax
  ca:	5f                   	pop    %edi
  cb:	5d                   	pop    %ebp
  cc:	c3                   	ret    

000000cd <strchr>:

char*
strchr(const char *s, char c)
{
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	8b 45 08             	mov    0x8(%ebp),%eax
  d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  d7:	0f b6 10             	movzbl (%eax),%edx
  da:	84 d2                	test   %dl,%dl
  dc:	74 09                	je     e7 <strchr+0x1a>
    if(*s == c)
  de:	38 ca                	cmp    %cl,%dl
  e0:	74 0a                	je     ec <strchr+0x1f>
  for(; *s; s++)
  e2:	83 c0 01             	add    $0x1,%eax
  e5:	eb f0                	jmp    d7 <strchr+0xa>
      return (char*)s;
  return 0;
  e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  ec:	5d                   	pop    %ebp
  ed:	c3                   	ret    

000000ee <gets>:

char*
gets(char *buf, int max)
{
  ee:	55                   	push   %ebp
  ef:	89 e5                	mov    %esp,%ebp
  f1:	57                   	push   %edi
  f2:	56                   	push   %esi
  f3:	53                   	push   %ebx
  f4:	83 ec 1c             	sub    $0x1c,%esp
  f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  ff:	8d 73 01             	lea    0x1(%ebx),%esi
 102:	3b 75 0c             	cmp    0xc(%ebp),%esi
 105:	7d 2e                	jge    135 <gets+0x47>
    cc = read(0, &c, 1);
 107:	83 ec 04             	sub    $0x4,%esp
 10a:	6a 01                	push   $0x1
 10c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 10f:	50                   	push   %eax
 110:	6a 00                	push   $0x0
 112:	e8 e6 00 00 00       	call   1fd <read>
    if(cc < 1)
 117:	83 c4 10             	add    $0x10,%esp
 11a:	85 c0                	test   %eax,%eax
 11c:	7e 17                	jle    135 <gets+0x47>
      break;
    buf[i++] = c;
 11e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 122:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 125:	3c 0a                	cmp    $0xa,%al
 127:	0f 94 c2             	sete   %dl
 12a:	3c 0d                	cmp    $0xd,%al
 12c:	0f 94 c0             	sete   %al
    buf[i++] = c;
 12f:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 131:	08 c2                	or     %al,%dl
 133:	74 ca                	je     ff <gets+0x11>
      break;
  }
  buf[i] = '\0';
 135:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 139:	89 f8                	mov    %edi,%eax
 13b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 13e:	5b                   	pop    %ebx
 13f:	5e                   	pop    %esi
 140:	5f                   	pop    %edi
 141:	5d                   	pop    %ebp
 142:	c3                   	ret    

00000143 <stat>:

int
stat(const char *n, struct stat *st)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	56                   	push   %esi
 147:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 148:	83 ec 08             	sub    $0x8,%esp
 14b:	6a 00                	push   $0x0
 14d:	ff 75 08             	pushl  0x8(%ebp)
 150:	e8 d0 00 00 00       	call   225 <open>
  if(fd < 0)
 155:	83 c4 10             	add    $0x10,%esp
 158:	85 c0                	test   %eax,%eax
 15a:	78 24                	js     180 <stat+0x3d>
 15c:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 15e:	83 ec 08             	sub    $0x8,%esp
 161:	ff 75 0c             	pushl  0xc(%ebp)
 164:	50                   	push   %eax
 165:	e8 d3 00 00 00       	call   23d <fstat>
 16a:	89 c6                	mov    %eax,%esi
  close(fd);
 16c:	89 1c 24             	mov    %ebx,(%esp)
 16f:	e8 99 00 00 00       	call   20d <close>
  return r;
 174:	83 c4 10             	add    $0x10,%esp
}
 177:	89 f0                	mov    %esi,%eax
 179:	8d 65 f8             	lea    -0x8(%ebp),%esp
 17c:	5b                   	pop    %ebx
 17d:	5e                   	pop    %esi
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    
    return -1;
 180:	be ff ff ff ff       	mov    $0xffffffff,%esi
 185:	eb f0                	jmp    177 <stat+0x34>

00000187 <atoi>:

int
atoi(const char *s)
{
 187:	55                   	push   %ebp
 188:	89 e5                	mov    %esp,%ebp
 18a:	53                   	push   %ebx
 18b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 18e:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 193:	eb 10                	jmp    1a5 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 195:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 198:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 19b:	83 c1 01             	add    $0x1,%ecx
 19e:	0f be d2             	movsbl %dl,%edx
 1a1:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1a5:	0f b6 11             	movzbl (%ecx),%edx
 1a8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1ab:	80 fb 09             	cmp    $0x9,%bl
 1ae:	76 e5                	jbe    195 <atoi+0xe>
  return n;
}
 1b0:	5b                   	pop    %ebx
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    

000001b3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	56                   	push   %esi
 1b7:	53                   	push   %ebx
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1be:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1c1:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1c3:	eb 0d                	jmp    1d2 <memmove+0x1f>
    *dst++ = *src++;
 1c5:	0f b6 13             	movzbl (%ebx),%edx
 1c8:	88 11                	mov    %dl,(%ecx)
 1ca:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1cd:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1d0:	89 f2                	mov    %esi,%edx
 1d2:	8d 72 ff             	lea    -0x1(%edx),%esi
 1d5:	85 d2                	test   %edx,%edx
 1d7:	7f ec                	jg     1c5 <memmove+0x12>
  return vdst;
}
 1d9:	5b                   	pop    %ebx
 1da:	5e                   	pop    %esi
 1db:	5d                   	pop    %ebp
 1dc:	c3                   	ret    

000001dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1dd:	b8 01 00 00 00       	mov    $0x1,%eax
 1e2:	cd 40                	int    $0x40
 1e4:	c3                   	ret    

000001e5 <exit>:
SYSCALL(exit)
 1e5:	b8 02 00 00 00       	mov    $0x2,%eax
 1ea:	cd 40                	int    $0x40
 1ec:	c3                   	ret    

000001ed <wait>:
SYSCALL(wait)
 1ed:	b8 03 00 00 00       	mov    $0x3,%eax
 1f2:	cd 40                	int    $0x40
 1f4:	c3                   	ret    

000001f5 <pipe>:
SYSCALL(pipe)
 1f5:	b8 04 00 00 00       	mov    $0x4,%eax
 1fa:	cd 40                	int    $0x40
 1fc:	c3                   	ret    

000001fd <read>:
SYSCALL(read)
 1fd:	b8 05 00 00 00       	mov    $0x5,%eax
 202:	cd 40                	int    $0x40
 204:	c3                   	ret    

00000205 <write>:
SYSCALL(write)
 205:	b8 10 00 00 00       	mov    $0x10,%eax
 20a:	cd 40                	int    $0x40
 20c:	c3                   	ret    

0000020d <close>:
SYSCALL(close)
 20d:	b8 15 00 00 00       	mov    $0x15,%eax
 212:	cd 40                	int    $0x40
 214:	c3                   	ret    

00000215 <kill>:
SYSCALL(kill)
 215:	b8 06 00 00 00       	mov    $0x6,%eax
 21a:	cd 40                	int    $0x40
 21c:	c3                   	ret    

0000021d <exec>:
SYSCALL(exec)
 21d:	b8 07 00 00 00       	mov    $0x7,%eax
 222:	cd 40                	int    $0x40
 224:	c3                   	ret    

00000225 <open>:
SYSCALL(open)
 225:	b8 0f 00 00 00       	mov    $0xf,%eax
 22a:	cd 40                	int    $0x40
 22c:	c3                   	ret    

0000022d <mknod>:
SYSCALL(mknod)
 22d:	b8 11 00 00 00       	mov    $0x11,%eax
 232:	cd 40                	int    $0x40
 234:	c3                   	ret    

00000235 <unlink>:
SYSCALL(unlink)
 235:	b8 12 00 00 00       	mov    $0x12,%eax
 23a:	cd 40                	int    $0x40
 23c:	c3                   	ret    

0000023d <fstat>:
SYSCALL(fstat)
 23d:	b8 08 00 00 00       	mov    $0x8,%eax
 242:	cd 40                	int    $0x40
 244:	c3                   	ret    

00000245 <link>:
SYSCALL(link)
 245:	b8 13 00 00 00       	mov    $0x13,%eax
 24a:	cd 40                	int    $0x40
 24c:	c3                   	ret    

0000024d <mkdir>:
SYSCALL(mkdir)
 24d:	b8 14 00 00 00       	mov    $0x14,%eax
 252:	cd 40                	int    $0x40
 254:	c3                   	ret    

00000255 <chdir>:
SYSCALL(chdir)
 255:	b8 09 00 00 00       	mov    $0x9,%eax
 25a:	cd 40                	int    $0x40
 25c:	c3                   	ret    

0000025d <dup>:
SYSCALL(dup)
 25d:	b8 0a 00 00 00       	mov    $0xa,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <getpid>:
SYSCALL(getpid)
 265:	b8 0b 00 00 00       	mov    $0xb,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <sbrk>:
SYSCALL(sbrk)
 26d:	b8 0c 00 00 00       	mov    $0xc,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <sleep>:
SYSCALL(sleep)
 275:	b8 0d 00 00 00       	mov    $0xd,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <uptime>:
SYSCALL(uptime)
 27d:	b8 0e 00 00 00       	mov    $0xe,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <dump_physmem>:
SYSCALL(dump_physmem)
 285:	b8 16 00 00 00       	mov    $0x16,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 1c             	sub    $0x1c,%esp
 293:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 296:	6a 01                	push   $0x1
 298:	8d 55 f4             	lea    -0xc(%ebp),%edx
 29b:	52                   	push   %edx
 29c:	50                   	push   %eax
 29d:	e8 63 ff ff ff       	call   205 <write>
}
 2a2:	83 c4 10             	add    $0x10,%esp
 2a5:	c9                   	leave  
 2a6:	c3                   	ret    

000002a7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
 2aa:	57                   	push   %edi
 2ab:	56                   	push   %esi
 2ac:	53                   	push   %ebx
 2ad:	83 ec 2c             	sub    $0x2c,%esp
 2b0:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2b6:	0f 95 c3             	setne  %bl
 2b9:	89 d0                	mov    %edx,%eax
 2bb:	c1 e8 1f             	shr    $0x1f,%eax
 2be:	84 c3                	test   %al,%bl
 2c0:	74 10                	je     2d2 <printint+0x2b>
    neg = 1;
    x = -xx;
 2c2:	f7 da                	neg    %edx
    neg = 1;
 2c4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2cb:	be 00 00 00 00       	mov    $0x0,%esi
 2d0:	eb 0b                	jmp    2dd <printint+0x36>
  neg = 0;
 2d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2d9:	eb f0                	jmp    2cb <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2db:	89 c6                	mov    %eax,%esi
 2dd:	89 d0                	mov    %edx,%eax
 2df:	ba 00 00 00 00       	mov    $0x0,%edx
 2e4:	f7 f1                	div    %ecx
 2e6:	89 c3                	mov    %eax,%ebx
 2e8:	8d 46 01             	lea    0x1(%esi),%eax
 2eb:	0f b6 92 f0 05 00 00 	movzbl 0x5f0(%edx),%edx
 2f2:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2f6:	89 da                	mov    %ebx,%edx
 2f8:	85 db                	test   %ebx,%ebx
 2fa:	75 df                	jne    2db <printint+0x34>
 2fc:	89 c3                	mov    %eax,%ebx
  if(neg)
 2fe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 302:	74 16                	je     31a <printint+0x73>
    buf[i++] = '-';
 304:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 309:	8d 5e 02             	lea    0x2(%esi),%ebx
 30c:	eb 0c                	jmp    31a <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 30e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 313:	89 f8                	mov    %edi,%eax
 315:	e8 73 ff ff ff       	call   28d <putc>
  while(--i >= 0)
 31a:	83 eb 01             	sub    $0x1,%ebx
 31d:	79 ef                	jns    30e <printint+0x67>
}
 31f:	83 c4 2c             	add    $0x2c,%esp
 322:	5b                   	pop    %ebx
 323:	5e                   	pop    %esi
 324:	5f                   	pop    %edi
 325:	5d                   	pop    %ebp
 326:	c3                   	ret    

00000327 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 327:	55                   	push   %ebp
 328:	89 e5                	mov    %esp,%ebp
 32a:	57                   	push   %edi
 32b:	56                   	push   %esi
 32c:	53                   	push   %ebx
 32d:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 330:	8d 45 10             	lea    0x10(%ebp),%eax
 333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 336:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 33b:	bb 00 00 00 00       	mov    $0x0,%ebx
 340:	eb 14                	jmp    356 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 342:	89 fa                	mov    %edi,%edx
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	e8 41 ff ff ff       	call   28d <putc>
 34c:	eb 05                	jmp    353 <printf+0x2c>
      }
    } else if(state == '%'){
 34e:	83 fe 25             	cmp    $0x25,%esi
 351:	74 25                	je     378 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 353:	83 c3 01             	add    $0x1,%ebx
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 35d:	84 c0                	test   %al,%al
 35f:	0f 84 23 01 00 00    	je     488 <printf+0x161>
    c = fmt[i] & 0xff;
 365:	0f be f8             	movsbl %al,%edi
 368:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 36b:	85 f6                	test   %esi,%esi
 36d:	75 df                	jne    34e <printf+0x27>
      if(c == '%'){
 36f:	83 f8 25             	cmp    $0x25,%eax
 372:	75 ce                	jne    342 <printf+0x1b>
        state = '%';
 374:	89 c6                	mov    %eax,%esi
 376:	eb db                	jmp    353 <printf+0x2c>
      if(c == 'd'){
 378:	83 f8 64             	cmp    $0x64,%eax
 37b:	74 49                	je     3c6 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 37d:	83 f8 78             	cmp    $0x78,%eax
 380:	0f 94 c1             	sete   %cl
 383:	83 f8 70             	cmp    $0x70,%eax
 386:	0f 94 c2             	sete   %dl
 389:	08 d1                	or     %dl,%cl
 38b:	75 63                	jne    3f0 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 38d:	83 f8 73             	cmp    $0x73,%eax
 390:	0f 84 84 00 00 00    	je     41a <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 396:	83 f8 63             	cmp    $0x63,%eax
 399:	0f 84 b7 00 00 00    	je     456 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 39f:	83 f8 25             	cmp    $0x25,%eax
 3a2:	0f 84 cc 00 00 00    	je     474 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3a8:	ba 25 00 00 00       	mov    $0x25,%edx
 3ad:	8b 45 08             	mov    0x8(%ebp),%eax
 3b0:	e8 d8 fe ff ff       	call   28d <putc>
        putc(fd, c);
 3b5:	89 fa                	mov    %edi,%edx
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	e8 ce fe ff ff       	call   28d <putc>
      }
      state = 0;
 3bf:	be 00 00 00 00       	mov    $0x0,%esi
 3c4:	eb 8d                	jmp    353 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3c9:	8b 17                	mov    (%edi),%edx
 3cb:	83 ec 0c             	sub    $0xc,%esp
 3ce:	6a 01                	push   $0x1
 3d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	e8 ca fe ff ff       	call   2a7 <printint>
        ap++;
 3dd:	83 c7 04             	add    $0x4,%edi
 3e0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3e3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3e6:	be 00 00 00 00       	mov    $0x0,%esi
 3eb:	e9 63 ff ff ff       	jmp    353 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f3:	8b 17                	mov    (%edi),%edx
 3f5:	83 ec 0c             	sub    $0xc,%esp
 3f8:	6a 00                	push   $0x0
 3fa:	b9 10 00 00 00       	mov    $0x10,%ecx
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	e8 a0 fe ff ff       	call   2a7 <printint>
        ap++;
 407:	83 c7 04             	add    $0x4,%edi
 40a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 40d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 410:	be 00 00 00 00       	mov    $0x0,%esi
 415:	e9 39 ff ff ff       	jmp    353 <printf+0x2c>
        s = (char*)*ap;
 41a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 41d:	8b 30                	mov    (%eax),%esi
        ap++;
 41f:	83 c0 04             	add    $0x4,%eax
 422:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 425:	85 f6                	test   %esi,%esi
 427:	75 28                	jne    451 <printf+0x12a>
          s = "(null)";
 429:	be e7 05 00 00       	mov    $0x5e7,%esi
 42e:	8b 7d 08             	mov    0x8(%ebp),%edi
 431:	eb 0d                	jmp    440 <printf+0x119>
          putc(fd, *s);
 433:	0f be d2             	movsbl %dl,%edx
 436:	89 f8                	mov    %edi,%eax
 438:	e8 50 fe ff ff       	call   28d <putc>
          s++;
 43d:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 440:	0f b6 16             	movzbl (%esi),%edx
 443:	84 d2                	test   %dl,%dl
 445:	75 ec                	jne    433 <printf+0x10c>
      state = 0;
 447:	be 00 00 00 00       	mov    $0x0,%esi
 44c:	e9 02 ff ff ff       	jmp    353 <printf+0x2c>
 451:	8b 7d 08             	mov    0x8(%ebp),%edi
 454:	eb ea                	jmp    440 <printf+0x119>
        putc(fd, *ap);
 456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 459:	0f be 17             	movsbl (%edi),%edx
 45c:	8b 45 08             	mov    0x8(%ebp),%eax
 45f:	e8 29 fe ff ff       	call   28d <putc>
        ap++;
 464:	83 c7 04             	add    $0x4,%edi
 467:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 46a:	be 00 00 00 00       	mov    $0x0,%esi
 46f:	e9 df fe ff ff       	jmp    353 <printf+0x2c>
        putc(fd, c);
 474:	89 fa                	mov    %edi,%edx
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	e8 0f fe ff ff       	call   28d <putc>
      state = 0;
 47e:	be 00 00 00 00       	mov    $0x0,%esi
 483:	e9 cb fe ff ff       	jmp    353 <printf+0x2c>
    }
  }
}
 488:	8d 65 f4             	lea    -0xc(%ebp),%esp
 48b:	5b                   	pop    %ebx
 48c:	5e                   	pop    %esi
 48d:	5f                   	pop    %edi
 48e:	5d                   	pop    %ebp
 48f:	c3                   	ret    

00000490 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	57                   	push   %edi
 494:	56                   	push   %esi
 495:	53                   	push   %ebx
 496:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 499:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 49c:	a1 8c 08 00 00       	mov    0x88c,%eax
 4a1:	eb 02                	jmp    4a5 <free+0x15>
 4a3:	89 d0                	mov    %edx,%eax
 4a5:	39 c8                	cmp    %ecx,%eax
 4a7:	73 04                	jae    4ad <free+0x1d>
 4a9:	39 08                	cmp    %ecx,(%eax)
 4ab:	77 12                	ja     4bf <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4ad:	8b 10                	mov    (%eax),%edx
 4af:	39 c2                	cmp    %eax,%edx
 4b1:	77 f0                	ja     4a3 <free+0x13>
 4b3:	39 c8                	cmp    %ecx,%eax
 4b5:	72 08                	jb     4bf <free+0x2f>
 4b7:	39 ca                	cmp    %ecx,%edx
 4b9:	77 04                	ja     4bf <free+0x2f>
 4bb:	89 d0                	mov    %edx,%eax
 4bd:	eb e6                	jmp    4a5 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4bf:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4c2:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4c5:	8b 10                	mov    (%eax),%edx
 4c7:	39 d7                	cmp    %edx,%edi
 4c9:	74 19                	je     4e4 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4cb:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4ce:	8b 50 04             	mov    0x4(%eax),%edx
 4d1:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4d4:	39 ce                	cmp    %ecx,%esi
 4d6:	74 1b                	je     4f3 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4d8:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4da:	a3 8c 08 00 00       	mov    %eax,0x88c
}
 4df:	5b                   	pop    %ebx
 4e0:	5e                   	pop    %esi
 4e1:	5f                   	pop    %edi
 4e2:	5d                   	pop    %ebp
 4e3:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4e4:	03 72 04             	add    0x4(%edx),%esi
 4e7:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4ea:	8b 10                	mov    (%eax),%edx
 4ec:	8b 12                	mov    (%edx),%edx
 4ee:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4f1:	eb db                	jmp    4ce <free+0x3e>
    p->s.size += bp->s.size;
 4f3:	03 53 fc             	add    -0x4(%ebx),%edx
 4f6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4f9:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4fc:	89 10                	mov    %edx,(%eax)
 4fe:	eb da                	jmp    4da <free+0x4a>

00000500 <morecore>:

static Header*
morecore(uint nu)
{
 500:	55                   	push   %ebp
 501:	89 e5                	mov    %esp,%ebp
 503:	53                   	push   %ebx
 504:	83 ec 04             	sub    $0x4,%esp
 507:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 509:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 50e:	77 05                	ja     515 <morecore+0x15>
    nu = 4096;
 510:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 515:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 51c:	83 ec 0c             	sub    $0xc,%esp
 51f:	50                   	push   %eax
 520:	e8 48 fd ff ff       	call   26d <sbrk>
  if(p == (char*)-1)
 525:	83 c4 10             	add    $0x10,%esp
 528:	83 f8 ff             	cmp    $0xffffffff,%eax
 52b:	74 1c                	je     549 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 52d:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 530:	83 c0 08             	add    $0x8,%eax
 533:	83 ec 0c             	sub    $0xc,%esp
 536:	50                   	push   %eax
 537:	e8 54 ff ff ff       	call   490 <free>
  return freep;
 53c:	a1 8c 08 00 00       	mov    0x88c,%eax
 541:	83 c4 10             	add    $0x10,%esp
}
 544:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 547:	c9                   	leave  
 548:	c3                   	ret    
    return 0;
 549:	b8 00 00 00 00       	mov    $0x0,%eax
 54e:	eb f4                	jmp    544 <morecore+0x44>

00000550 <malloc>:

void*
malloc(uint nbytes)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	53                   	push   %ebx
 554:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	8d 58 07             	lea    0x7(%eax),%ebx
 55d:	c1 eb 03             	shr    $0x3,%ebx
 560:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 563:	8b 0d 8c 08 00 00    	mov    0x88c,%ecx
 569:	85 c9                	test   %ecx,%ecx
 56b:	74 04                	je     571 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 56d:	8b 01                	mov    (%ecx),%eax
 56f:	eb 4d                	jmp    5be <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 571:	c7 05 8c 08 00 00 90 	movl   $0x890,0x88c
 578:	08 00 00 
 57b:	c7 05 90 08 00 00 90 	movl   $0x890,0x890
 582:	08 00 00 
    base.s.size = 0;
 585:	c7 05 94 08 00 00 00 	movl   $0x0,0x894
 58c:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 58f:	b9 90 08 00 00       	mov    $0x890,%ecx
 594:	eb d7                	jmp    56d <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 596:	39 da                	cmp    %ebx,%edx
 598:	74 1a                	je     5b4 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 59a:	29 da                	sub    %ebx,%edx
 59c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 59f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5a2:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5a5:	89 0d 8c 08 00 00    	mov    %ecx,0x88c
      return (void*)(p + 1);
 5ab:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5ae:	83 c4 04             	add    $0x4,%esp
 5b1:	5b                   	pop    %ebx
 5b2:	5d                   	pop    %ebp
 5b3:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5b4:	8b 10                	mov    (%eax),%edx
 5b6:	89 11                	mov    %edx,(%ecx)
 5b8:	eb eb                	jmp    5a5 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ba:	89 c1                	mov    %eax,%ecx
 5bc:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5be:	8b 50 04             	mov    0x4(%eax),%edx
 5c1:	39 da                	cmp    %ebx,%edx
 5c3:	73 d1                	jae    596 <malloc+0x46>
    if(p == freep)
 5c5:	39 05 8c 08 00 00    	cmp    %eax,0x88c
 5cb:	75 ed                	jne    5ba <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5cd:	89 d8                	mov    %ebx,%eax
 5cf:	e8 2c ff ff ff       	call   500 <morecore>
 5d4:	85 c0                	test   %eax,%eax
 5d6:	75 e2                	jne    5ba <malloc+0x6a>
        return 0;
 5d8:	b8 00 00 00 00       	mov    $0x0,%eax
 5dd:	eb cf                	jmp    5ae <malloc+0x5e>
