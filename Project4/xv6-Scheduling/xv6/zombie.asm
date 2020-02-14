
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  if(fork() > 0)
  11:	e8 9d 01 00 00       	call   1b3 <fork>
  16:	85 c0                	test   %eax,%eax
  18:	7f 05                	jg     1f <main+0x1f>
    sleep(5);  // Let child exit before parent.
  exit();
  1a:	e8 9c 01 00 00       	call   1bb <exit>
    sleep(5);  // Let child exit before parent.
  1f:	83 ec 0c             	sub    $0xc,%esp
  22:	6a 05                	push   $0x5
  24:	e8 22 02 00 00       	call   24b <sleep>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	eb ec                	jmp    1a <main+0x1a>

0000002e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  2e:	55                   	push   %ebp
  2f:	89 e5                	mov    %esp,%ebp
  31:	53                   	push   %ebx
  32:	8b 45 08             	mov    0x8(%ebp),%eax
  35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  38:	89 c2                	mov    %eax,%edx
  3a:	0f b6 19             	movzbl (%ecx),%ebx
  3d:	88 1a                	mov    %bl,(%edx)
  3f:	8d 52 01             	lea    0x1(%edx),%edx
  42:	8d 49 01             	lea    0x1(%ecx),%ecx
  45:	84 db                	test   %bl,%bl
  47:	75 f1                	jne    3a <strcpy+0xc>
    ;
  return os;
}
  49:	5b                   	pop    %ebx
  4a:	5d                   	pop    %ebp
  4b:	c3                   	ret    

0000004c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  52:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  55:	eb 06                	jmp    5d <strcmp+0x11>
    p++, q++;
  57:	83 c1 01             	add    $0x1,%ecx
  5a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  5d:	0f b6 01             	movzbl (%ecx),%eax
  60:	84 c0                	test   %al,%al
  62:	74 04                	je     68 <strcmp+0x1c>
  64:	3a 02                	cmp    (%edx),%al
  66:	74 ef                	je     57 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  68:	0f b6 c0             	movzbl %al,%eax
  6b:	0f b6 12             	movzbl (%edx),%edx
  6e:	29 d0                	sub    %edx,%eax
}
  70:	5d                   	pop    %ebp
  71:	c3                   	ret    

00000072 <strlen>:

uint
strlen(const char *s)
{
  72:	55                   	push   %ebp
  73:	89 e5                	mov    %esp,%ebp
  75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  78:	ba 00 00 00 00       	mov    $0x0,%edx
  7d:	eb 03                	jmp    82 <strlen+0x10>
  7f:	83 c2 01             	add    $0x1,%edx
  82:	89 d0                	mov    %edx,%eax
  84:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  88:	75 f5                	jne    7f <strlen+0xd>
    ;
  return n;
}
  8a:	5d                   	pop    %ebp
  8b:	c3                   	ret    

0000008c <memset>:

void*
memset(void *dst, int c, uint n)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	57                   	push   %edi
  90:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  93:	89 d7                	mov    %edx,%edi
  95:	8b 4d 10             	mov    0x10(%ebp),%ecx
  98:	8b 45 0c             	mov    0xc(%ebp),%eax
  9b:	fc                   	cld    
  9c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  9e:	89 d0                	mov    %edx,%eax
  a0:	5f                   	pop    %edi
  a1:	5d                   	pop    %ebp
  a2:	c3                   	ret    

000000a3 <strchr>:

char*
strchr(const char *s, char c)
{
  a3:	55                   	push   %ebp
  a4:	89 e5                	mov    %esp,%ebp
  a6:	8b 45 08             	mov    0x8(%ebp),%eax
  a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  ad:	0f b6 10             	movzbl (%eax),%edx
  b0:	84 d2                	test   %dl,%dl
  b2:	74 09                	je     bd <strchr+0x1a>
    if(*s == c)
  b4:	38 ca                	cmp    %cl,%dl
  b6:	74 0a                	je     c2 <strchr+0x1f>
  for(; *s; s++)
  b8:	83 c0 01             	add    $0x1,%eax
  bb:	eb f0                	jmp    ad <strchr+0xa>
      return (char*)s;
  return 0;
  bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c2:	5d                   	pop    %ebp
  c3:	c3                   	ret    

000000c4 <gets>:

char*
gets(char *buf, int max)
{
  c4:	55                   	push   %ebp
  c5:	89 e5                	mov    %esp,%ebp
  c7:	57                   	push   %edi
  c8:	56                   	push   %esi
  c9:	53                   	push   %ebx
  ca:	83 ec 1c             	sub    $0x1c,%esp
  cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  d5:	8d 73 01             	lea    0x1(%ebx),%esi
  d8:	3b 75 0c             	cmp    0xc(%ebp),%esi
  db:	7d 2e                	jge    10b <gets+0x47>
    cc = read(0, &c, 1);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	6a 01                	push   $0x1
  e2:	8d 45 e7             	lea    -0x19(%ebp),%eax
  e5:	50                   	push   %eax
  e6:	6a 00                	push   $0x0
  e8:	e8 e6 00 00 00       	call   1d3 <read>
    if(cc < 1)
  ed:	83 c4 10             	add    $0x10,%esp
  f0:	85 c0                	test   %eax,%eax
  f2:	7e 17                	jle    10b <gets+0x47>
      break;
    buf[i++] = c;
  f4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  f8:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  fb:	3c 0a                	cmp    $0xa,%al
  fd:	0f 94 c2             	sete   %dl
 100:	3c 0d                	cmp    $0xd,%al
 102:	0f 94 c0             	sete   %al
    buf[i++] = c;
 105:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 107:	08 c2                	or     %al,%dl
 109:	74 ca                	je     d5 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 10b:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 10f:	89 f8                	mov    %edi,%eax
 111:	8d 65 f4             	lea    -0xc(%ebp),%esp
 114:	5b                   	pop    %ebx
 115:	5e                   	pop    %esi
 116:	5f                   	pop    %edi
 117:	5d                   	pop    %ebp
 118:	c3                   	ret    

00000119 <stat>:

int
stat(const char *n, struct stat *st)
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	56                   	push   %esi
 11d:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 11e:	83 ec 08             	sub    $0x8,%esp
 121:	6a 00                	push   $0x0
 123:	ff 75 08             	pushl  0x8(%ebp)
 126:	e8 d0 00 00 00       	call   1fb <open>
  if(fd < 0)
 12b:	83 c4 10             	add    $0x10,%esp
 12e:	85 c0                	test   %eax,%eax
 130:	78 24                	js     156 <stat+0x3d>
 132:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 134:	83 ec 08             	sub    $0x8,%esp
 137:	ff 75 0c             	pushl  0xc(%ebp)
 13a:	50                   	push   %eax
 13b:	e8 d3 00 00 00       	call   213 <fstat>
 140:	89 c6                	mov    %eax,%esi
  close(fd);
 142:	89 1c 24             	mov    %ebx,(%esp)
 145:	e8 99 00 00 00       	call   1e3 <close>
  return r;
 14a:	83 c4 10             	add    $0x10,%esp
}
 14d:	89 f0                	mov    %esi,%eax
 14f:	8d 65 f8             	lea    -0x8(%ebp),%esp
 152:	5b                   	pop    %ebx
 153:	5e                   	pop    %esi
 154:	5d                   	pop    %ebp
 155:	c3                   	ret    
    return -1;
 156:	be ff ff ff ff       	mov    $0xffffffff,%esi
 15b:	eb f0                	jmp    14d <stat+0x34>

0000015d <atoi>:

int
atoi(const char *s)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	53                   	push   %ebx
 161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 164:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 169:	eb 10                	jmp    17b <atoi+0x1e>
    n = n*10 + *s++ - '0';
 16b:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 16e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 171:	83 c1 01             	add    $0x1,%ecx
 174:	0f be d2             	movsbl %dl,%edx
 177:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 17b:	0f b6 11             	movzbl (%ecx),%edx
 17e:	8d 5a d0             	lea    -0x30(%edx),%ebx
 181:	80 fb 09             	cmp    $0x9,%bl
 184:	76 e5                	jbe    16b <atoi+0xe>
  return n;
}
 186:	5b                   	pop    %ebx
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    

00000189 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	56                   	push   %esi
 18d:	53                   	push   %ebx
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 194:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 197:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 199:	eb 0d                	jmp    1a8 <memmove+0x1f>
    *dst++ = *src++;
 19b:	0f b6 13             	movzbl (%ebx),%edx
 19e:	88 11                	mov    %dl,(%ecx)
 1a0:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1a3:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1a6:	89 f2                	mov    %esi,%edx
 1a8:	8d 72 ff             	lea    -0x1(%edx),%esi
 1ab:	85 d2                	test   %edx,%edx
 1ad:	7f ec                	jg     19b <memmove+0x12>
  return vdst;
}
 1af:	5b                   	pop    %ebx
 1b0:	5e                   	pop    %esi
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    

000001b3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1b3:	b8 01 00 00 00       	mov    $0x1,%eax
 1b8:	cd 40                	int    $0x40
 1ba:	c3                   	ret    

000001bb <exit>:
SYSCALL(exit)
 1bb:	b8 02 00 00 00       	mov    $0x2,%eax
 1c0:	cd 40                	int    $0x40
 1c2:	c3                   	ret    

000001c3 <wait>:
SYSCALL(wait)
 1c3:	b8 03 00 00 00       	mov    $0x3,%eax
 1c8:	cd 40                	int    $0x40
 1ca:	c3                   	ret    

000001cb <pipe>:
SYSCALL(pipe)
 1cb:	b8 04 00 00 00       	mov    $0x4,%eax
 1d0:	cd 40                	int    $0x40
 1d2:	c3                   	ret    

000001d3 <read>:
SYSCALL(read)
 1d3:	b8 05 00 00 00       	mov    $0x5,%eax
 1d8:	cd 40                	int    $0x40
 1da:	c3                   	ret    

000001db <write>:
SYSCALL(write)
 1db:	b8 10 00 00 00       	mov    $0x10,%eax
 1e0:	cd 40                	int    $0x40
 1e2:	c3                   	ret    

000001e3 <close>:
SYSCALL(close)
 1e3:	b8 15 00 00 00       	mov    $0x15,%eax
 1e8:	cd 40                	int    $0x40
 1ea:	c3                   	ret    

000001eb <kill>:
SYSCALL(kill)
 1eb:	b8 06 00 00 00       	mov    $0x6,%eax
 1f0:	cd 40                	int    $0x40
 1f2:	c3                   	ret    

000001f3 <exec>:
SYSCALL(exec)
 1f3:	b8 07 00 00 00       	mov    $0x7,%eax
 1f8:	cd 40                	int    $0x40
 1fa:	c3                   	ret    

000001fb <open>:
SYSCALL(open)
 1fb:	b8 0f 00 00 00       	mov    $0xf,%eax
 200:	cd 40                	int    $0x40
 202:	c3                   	ret    

00000203 <mknod>:
SYSCALL(mknod)
 203:	b8 11 00 00 00       	mov    $0x11,%eax
 208:	cd 40                	int    $0x40
 20a:	c3                   	ret    

0000020b <unlink>:
SYSCALL(unlink)
 20b:	b8 12 00 00 00       	mov    $0x12,%eax
 210:	cd 40                	int    $0x40
 212:	c3                   	ret    

00000213 <fstat>:
SYSCALL(fstat)
 213:	b8 08 00 00 00       	mov    $0x8,%eax
 218:	cd 40                	int    $0x40
 21a:	c3                   	ret    

0000021b <link>:
SYSCALL(link)
 21b:	b8 13 00 00 00       	mov    $0x13,%eax
 220:	cd 40                	int    $0x40
 222:	c3                   	ret    

00000223 <mkdir>:
SYSCALL(mkdir)
 223:	b8 14 00 00 00       	mov    $0x14,%eax
 228:	cd 40                	int    $0x40
 22a:	c3                   	ret    

0000022b <chdir>:
SYSCALL(chdir)
 22b:	b8 09 00 00 00       	mov    $0x9,%eax
 230:	cd 40                	int    $0x40
 232:	c3                   	ret    

00000233 <dup>:
SYSCALL(dup)
 233:	b8 0a 00 00 00       	mov    $0xa,%eax
 238:	cd 40                	int    $0x40
 23a:	c3                   	ret    

0000023b <getpid>:
SYSCALL(getpid)
 23b:	b8 0b 00 00 00       	mov    $0xb,%eax
 240:	cd 40                	int    $0x40
 242:	c3                   	ret    

00000243 <sbrk>:
SYSCALL(sbrk)
 243:	b8 0c 00 00 00       	mov    $0xc,%eax
 248:	cd 40                	int    $0x40
 24a:	c3                   	ret    

0000024b <sleep>:
SYSCALL(sleep)
 24b:	b8 0d 00 00 00       	mov    $0xd,%eax
 250:	cd 40                	int    $0x40
 252:	c3                   	ret    

00000253 <uptime>:
SYSCALL(uptime)
 253:	b8 0e 00 00 00       	mov    $0xe,%eax
 258:	cd 40                	int    $0x40
 25a:	c3                   	ret    

0000025b <setpri>:
SYSCALL(setpri)
 25b:	b8 16 00 00 00       	mov    $0x16,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <getpri>:
SYSCALL(getpri)
 263:	b8 17 00 00 00       	mov    $0x17,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <getpinfo>:
SYSCALL(getpinfo)
 26b:	b8 18 00 00 00       	mov    $0x18,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <fork2>:
SYSCALL(fork2)
 273:	b8 19 00 00 00       	mov    $0x19,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 27b:	55                   	push   %ebp
 27c:	89 e5                	mov    %esp,%ebp
 27e:	83 ec 1c             	sub    $0x1c,%esp
 281:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 284:	6a 01                	push   $0x1
 286:	8d 55 f4             	lea    -0xc(%ebp),%edx
 289:	52                   	push   %edx
 28a:	50                   	push   %eax
 28b:	e8 4b ff ff ff       	call   1db <write>
}
 290:	83 c4 10             	add    $0x10,%esp
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	57                   	push   %edi
 299:	56                   	push   %esi
 29a:	53                   	push   %ebx
 29b:	83 ec 2c             	sub    $0x2c,%esp
 29e:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2a4:	0f 95 c3             	setne  %bl
 2a7:	89 d0                	mov    %edx,%eax
 2a9:	c1 e8 1f             	shr    $0x1f,%eax
 2ac:	84 c3                	test   %al,%bl
 2ae:	74 10                	je     2c0 <printint+0x2b>
    neg = 1;
    x = -xx;
 2b0:	f7 da                	neg    %edx
    neg = 1;
 2b2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2b9:	be 00 00 00 00       	mov    $0x0,%esi
 2be:	eb 0b                	jmp    2cb <printint+0x36>
  neg = 0;
 2c0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2c7:	eb f0                	jmp    2b9 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2c9:	89 c6                	mov    %eax,%esi
 2cb:	89 d0                	mov    %edx,%eax
 2cd:	ba 00 00 00 00       	mov    $0x0,%edx
 2d2:	f7 f1                	div    %ecx
 2d4:	89 c3                	mov    %eax,%ebx
 2d6:	8d 46 01             	lea    0x1(%esi),%eax
 2d9:	0f b6 92 d8 05 00 00 	movzbl 0x5d8(%edx),%edx
 2e0:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2e4:	89 da                	mov    %ebx,%edx
 2e6:	85 db                	test   %ebx,%ebx
 2e8:	75 df                	jne    2c9 <printint+0x34>
 2ea:	89 c3                	mov    %eax,%ebx
  if(neg)
 2ec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2f0:	74 16                	je     308 <printint+0x73>
    buf[i++] = '-';
 2f2:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2f7:	8d 5e 02             	lea    0x2(%esi),%ebx
 2fa:	eb 0c                	jmp    308 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2fc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 301:	89 f8                	mov    %edi,%eax
 303:	e8 73 ff ff ff       	call   27b <putc>
  while(--i >= 0)
 308:	83 eb 01             	sub    $0x1,%ebx
 30b:	79 ef                	jns    2fc <printint+0x67>
}
 30d:	83 c4 2c             	add    $0x2c,%esp
 310:	5b                   	pop    %ebx
 311:	5e                   	pop    %esi
 312:	5f                   	pop    %edi
 313:	5d                   	pop    %ebp
 314:	c3                   	ret    

00000315 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 315:	55                   	push   %ebp
 316:	89 e5                	mov    %esp,%ebp
 318:	57                   	push   %edi
 319:	56                   	push   %esi
 31a:	53                   	push   %ebx
 31b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 31e:	8d 45 10             	lea    0x10(%ebp),%eax
 321:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 324:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 329:	bb 00 00 00 00       	mov    $0x0,%ebx
 32e:	eb 14                	jmp    344 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 330:	89 fa                	mov    %edi,%edx
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	e8 41 ff ff ff       	call   27b <putc>
 33a:	eb 05                	jmp    341 <printf+0x2c>
      }
    } else if(state == '%'){
 33c:	83 fe 25             	cmp    $0x25,%esi
 33f:	74 25                	je     366 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 341:	83 c3 01             	add    $0x1,%ebx
 344:	8b 45 0c             	mov    0xc(%ebp),%eax
 347:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 34b:	84 c0                	test   %al,%al
 34d:	0f 84 23 01 00 00    	je     476 <printf+0x161>
    c = fmt[i] & 0xff;
 353:	0f be f8             	movsbl %al,%edi
 356:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 359:	85 f6                	test   %esi,%esi
 35b:	75 df                	jne    33c <printf+0x27>
      if(c == '%'){
 35d:	83 f8 25             	cmp    $0x25,%eax
 360:	75 ce                	jne    330 <printf+0x1b>
        state = '%';
 362:	89 c6                	mov    %eax,%esi
 364:	eb db                	jmp    341 <printf+0x2c>
      if(c == 'd'){
 366:	83 f8 64             	cmp    $0x64,%eax
 369:	74 49                	je     3b4 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 36b:	83 f8 78             	cmp    $0x78,%eax
 36e:	0f 94 c1             	sete   %cl
 371:	83 f8 70             	cmp    $0x70,%eax
 374:	0f 94 c2             	sete   %dl
 377:	08 d1                	or     %dl,%cl
 379:	75 63                	jne    3de <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 37b:	83 f8 73             	cmp    $0x73,%eax
 37e:	0f 84 84 00 00 00    	je     408 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 384:	83 f8 63             	cmp    $0x63,%eax
 387:	0f 84 b7 00 00 00    	je     444 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 38d:	83 f8 25             	cmp    $0x25,%eax
 390:	0f 84 cc 00 00 00    	je     462 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 396:	ba 25 00 00 00       	mov    $0x25,%edx
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	e8 d8 fe ff ff       	call   27b <putc>
        putc(fd, c);
 3a3:	89 fa                	mov    %edi,%edx
 3a5:	8b 45 08             	mov    0x8(%ebp),%eax
 3a8:	e8 ce fe ff ff       	call   27b <putc>
      }
      state = 0;
 3ad:	be 00 00 00 00       	mov    $0x0,%esi
 3b2:	eb 8d                	jmp    341 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3b7:	8b 17                	mov    (%edi),%edx
 3b9:	83 ec 0c             	sub    $0xc,%esp
 3bc:	6a 01                	push   $0x1
 3be:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	e8 ca fe ff ff       	call   295 <printint>
        ap++;
 3cb:	83 c7 04             	add    $0x4,%edi
 3ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3d4:	be 00 00 00 00       	mov    $0x0,%esi
 3d9:	e9 63 ff ff ff       	jmp    341 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e1:	8b 17                	mov    (%edi),%edx
 3e3:	83 ec 0c             	sub    $0xc,%esp
 3e6:	6a 00                	push   $0x0
 3e8:	b9 10 00 00 00       	mov    $0x10,%ecx
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	e8 a0 fe ff ff       	call   295 <printint>
        ap++;
 3f5:	83 c7 04             	add    $0x4,%edi
 3f8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fb:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3fe:	be 00 00 00 00       	mov    $0x0,%esi
 403:	e9 39 ff ff ff       	jmp    341 <printf+0x2c>
        s = (char*)*ap;
 408:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 40b:	8b 30                	mov    (%eax),%esi
        ap++;
 40d:	83 c0 04             	add    $0x4,%eax
 410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 413:	85 f6                	test   %esi,%esi
 415:	75 28                	jne    43f <printf+0x12a>
          s = "(null)";
 417:	be d0 05 00 00       	mov    $0x5d0,%esi
 41c:	8b 7d 08             	mov    0x8(%ebp),%edi
 41f:	eb 0d                	jmp    42e <printf+0x119>
          putc(fd, *s);
 421:	0f be d2             	movsbl %dl,%edx
 424:	89 f8                	mov    %edi,%eax
 426:	e8 50 fe ff ff       	call   27b <putc>
          s++;
 42b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 42e:	0f b6 16             	movzbl (%esi),%edx
 431:	84 d2                	test   %dl,%dl
 433:	75 ec                	jne    421 <printf+0x10c>
      state = 0;
 435:	be 00 00 00 00       	mov    $0x0,%esi
 43a:	e9 02 ff ff ff       	jmp    341 <printf+0x2c>
 43f:	8b 7d 08             	mov    0x8(%ebp),%edi
 442:	eb ea                	jmp    42e <printf+0x119>
        putc(fd, *ap);
 444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 447:	0f be 17             	movsbl (%edi),%edx
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
 44d:	e8 29 fe ff ff       	call   27b <putc>
        ap++;
 452:	83 c7 04             	add    $0x4,%edi
 455:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 458:	be 00 00 00 00       	mov    $0x0,%esi
 45d:	e9 df fe ff ff       	jmp    341 <printf+0x2c>
        putc(fd, c);
 462:	89 fa                	mov    %edi,%edx
 464:	8b 45 08             	mov    0x8(%ebp),%eax
 467:	e8 0f fe ff ff       	call   27b <putc>
      state = 0;
 46c:	be 00 00 00 00       	mov    $0x0,%esi
 471:	e9 cb fe ff ff       	jmp    341 <printf+0x2c>
    }
  }
}
 476:	8d 65 f4             	lea    -0xc(%ebp),%esp
 479:	5b                   	pop    %ebx
 47a:	5e                   	pop    %esi
 47b:	5f                   	pop    %edi
 47c:	5d                   	pop    %ebp
 47d:	c3                   	ret    

0000047e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 47e:	55                   	push   %ebp
 47f:	89 e5                	mov    %esp,%ebp
 481:	57                   	push   %edi
 482:	56                   	push   %esi
 483:	53                   	push   %ebx
 484:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 487:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 48a:	a1 70 08 00 00       	mov    0x870,%eax
 48f:	eb 02                	jmp    493 <free+0x15>
 491:	89 d0                	mov    %edx,%eax
 493:	39 c8                	cmp    %ecx,%eax
 495:	73 04                	jae    49b <free+0x1d>
 497:	39 08                	cmp    %ecx,(%eax)
 499:	77 12                	ja     4ad <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 49b:	8b 10                	mov    (%eax),%edx
 49d:	39 c2                	cmp    %eax,%edx
 49f:	77 f0                	ja     491 <free+0x13>
 4a1:	39 c8                	cmp    %ecx,%eax
 4a3:	72 08                	jb     4ad <free+0x2f>
 4a5:	39 ca                	cmp    %ecx,%edx
 4a7:	77 04                	ja     4ad <free+0x2f>
 4a9:	89 d0                	mov    %edx,%eax
 4ab:	eb e6                	jmp    493 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ad:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b0:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b3:	8b 10                	mov    (%eax),%edx
 4b5:	39 d7                	cmp    %edx,%edi
 4b7:	74 19                	je     4d2 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4b9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4bc:	8b 50 04             	mov    0x4(%eax),%edx
 4bf:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c2:	39 ce                	cmp    %ecx,%esi
 4c4:	74 1b                	je     4e1 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4c6:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4c8:	a3 70 08 00 00       	mov    %eax,0x870
}
 4cd:	5b                   	pop    %ebx
 4ce:	5e                   	pop    %esi
 4cf:	5f                   	pop    %edi
 4d0:	5d                   	pop    %ebp
 4d1:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4d2:	03 72 04             	add    0x4(%edx),%esi
 4d5:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4d8:	8b 10                	mov    (%eax),%edx
 4da:	8b 12                	mov    (%edx),%edx
 4dc:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4df:	eb db                	jmp    4bc <free+0x3e>
    p->s.size += bp->s.size;
 4e1:	03 53 fc             	add    -0x4(%ebx),%edx
 4e4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4e7:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4ea:	89 10                	mov    %edx,(%eax)
 4ec:	eb da                	jmp    4c8 <free+0x4a>

000004ee <morecore>:

static Header*
morecore(uint nu)
{
 4ee:	55                   	push   %ebp
 4ef:	89 e5                	mov    %esp,%ebp
 4f1:	53                   	push   %ebx
 4f2:	83 ec 04             	sub    $0x4,%esp
 4f5:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4f7:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4fc:	77 05                	ja     503 <morecore+0x15>
    nu = 4096;
 4fe:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 503:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 50a:	83 ec 0c             	sub    $0xc,%esp
 50d:	50                   	push   %eax
 50e:	e8 30 fd ff ff       	call   243 <sbrk>
  if(p == (char*)-1)
 513:	83 c4 10             	add    $0x10,%esp
 516:	83 f8 ff             	cmp    $0xffffffff,%eax
 519:	74 1c                	je     537 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 51b:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 51e:	83 c0 08             	add    $0x8,%eax
 521:	83 ec 0c             	sub    $0xc,%esp
 524:	50                   	push   %eax
 525:	e8 54 ff ff ff       	call   47e <free>
  return freep;
 52a:	a1 70 08 00 00       	mov    0x870,%eax
 52f:	83 c4 10             	add    $0x10,%esp
}
 532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 535:	c9                   	leave  
 536:	c3                   	ret    
    return 0;
 537:	b8 00 00 00 00       	mov    $0x0,%eax
 53c:	eb f4                	jmp    532 <morecore+0x44>

0000053e <malloc>:

void*
malloc(uint nbytes)
{
 53e:	55                   	push   %ebp
 53f:	89 e5                	mov    %esp,%ebp
 541:	53                   	push   %ebx
 542:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	8d 58 07             	lea    0x7(%eax),%ebx
 54b:	c1 eb 03             	shr    $0x3,%ebx
 54e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 551:	8b 0d 70 08 00 00    	mov    0x870,%ecx
 557:	85 c9                	test   %ecx,%ecx
 559:	74 04                	je     55f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55b:	8b 01                	mov    (%ecx),%eax
 55d:	eb 4d                	jmp    5ac <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 55f:	c7 05 70 08 00 00 74 	movl   $0x874,0x870
 566:	08 00 00 
 569:	c7 05 74 08 00 00 74 	movl   $0x874,0x874
 570:	08 00 00 
    base.s.size = 0;
 573:	c7 05 78 08 00 00 00 	movl   $0x0,0x878
 57a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 57d:	b9 74 08 00 00       	mov    $0x874,%ecx
 582:	eb d7                	jmp    55b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 584:	39 da                	cmp    %ebx,%edx
 586:	74 1a                	je     5a2 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 588:	29 da                	sub    %ebx,%edx
 58a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 58d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 590:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 593:	89 0d 70 08 00 00    	mov    %ecx,0x870
      return (void*)(p + 1);
 599:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 59c:	83 c4 04             	add    $0x4,%esp
 59f:	5b                   	pop    %ebx
 5a0:	5d                   	pop    %ebp
 5a1:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5a2:	8b 10                	mov    (%eax),%edx
 5a4:	89 11                	mov    %edx,(%ecx)
 5a6:	eb eb                	jmp    593 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5a8:	89 c1                	mov    %eax,%ecx
 5aa:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ac:	8b 50 04             	mov    0x4(%eax),%edx
 5af:	39 da                	cmp    %ebx,%edx
 5b1:	73 d1                	jae    584 <malloc+0x46>
    if(p == freep)
 5b3:	39 05 70 08 00 00    	cmp    %eax,0x870
 5b9:	75 ed                	jne    5a8 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5bb:	89 d8                	mov    %ebx,%eax
 5bd:	e8 2c ff ff ff       	call   4ee <morecore>
 5c2:	85 c0                	test   %eax,%eax
 5c4:	75 e2                	jne    5a8 <malloc+0x6a>
        return 0;
 5c6:	b8 00 00 00 00       	mov    $0x0,%eax
 5cb:	eb cf                	jmp    59c <malloc+0x5e>
