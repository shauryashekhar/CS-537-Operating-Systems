
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

0000025b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 1c             	sub    $0x1c,%esp
 261:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 264:	6a 01                	push   $0x1
 266:	8d 55 f4             	lea    -0xc(%ebp),%edx
 269:	52                   	push   %edx
 26a:	50                   	push   %eax
 26b:	e8 6b ff ff ff       	call   1db <write>
}
 270:	83 c4 10             	add    $0x10,%esp
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	57                   	push   %edi
 279:	56                   	push   %esi
 27a:	53                   	push   %ebx
 27b:	83 ec 2c             	sub    $0x2c,%esp
 27e:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 280:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 284:	0f 95 c3             	setne  %bl
 287:	89 d0                	mov    %edx,%eax
 289:	c1 e8 1f             	shr    $0x1f,%eax
 28c:	84 c3                	test   %al,%bl
 28e:	74 10                	je     2a0 <printint+0x2b>
    neg = 1;
    x = -xx;
 290:	f7 da                	neg    %edx
    neg = 1;
 292:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 299:	be 00 00 00 00       	mov    $0x0,%esi
 29e:	eb 0b                	jmp    2ab <printint+0x36>
  neg = 0;
 2a0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2a7:	eb f0                	jmp    299 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2a9:	89 c6                	mov    %eax,%esi
 2ab:	89 d0                	mov    %edx,%eax
 2ad:	ba 00 00 00 00       	mov    $0x0,%edx
 2b2:	f7 f1                	div    %ecx
 2b4:	89 c3                	mov    %eax,%ebx
 2b6:	8d 46 01             	lea    0x1(%esi),%eax
 2b9:	0f b6 92 b8 05 00 00 	movzbl 0x5b8(%edx),%edx
 2c0:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2c4:	89 da                	mov    %ebx,%edx
 2c6:	85 db                	test   %ebx,%ebx
 2c8:	75 df                	jne    2a9 <printint+0x34>
 2ca:	89 c3                	mov    %eax,%ebx
  if(neg)
 2cc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2d0:	74 16                	je     2e8 <printint+0x73>
    buf[i++] = '-';
 2d2:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2d7:	8d 5e 02             	lea    0x2(%esi),%ebx
 2da:	eb 0c                	jmp    2e8 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2dc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 2e1:	89 f8                	mov    %edi,%eax
 2e3:	e8 73 ff ff ff       	call   25b <putc>
  while(--i >= 0)
 2e8:	83 eb 01             	sub    $0x1,%ebx
 2eb:	79 ef                	jns    2dc <printint+0x67>
}
 2ed:	83 c4 2c             	add    $0x2c,%esp
 2f0:	5b                   	pop    %ebx
 2f1:	5e                   	pop    %esi
 2f2:	5f                   	pop    %edi
 2f3:	5d                   	pop    %ebp
 2f4:	c3                   	ret    

000002f5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 2f5:	55                   	push   %ebp
 2f6:	89 e5                	mov    %esp,%ebp
 2f8:	57                   	push   %edi
 2f9:	56                   	push   %esi
 2fa:	53                   	push   %ebx
 2fb:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 2fe:	8d 45 10             	lea    0x10(%ebp),%eax
 301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 304:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 309:	bb 00 00 00 00       	mov    $0x0,%ebx
 30e:	eb 14                	jmp    324 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 310:	89 fa                	mov    %edi,%edx
 312:	8b 45 08             	mov    0x8(%ebp),%eax
 315:	e8 41 ff ff ff       	call   25b <putc>
 31a:	eb 05                	jmp    321 <printf+0x2c>
      }
    } else if(state == '%'){
 31c:	83 fe 25             	cmp    $0x25,%esi
 31f:	74 25                	je     346 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 321:	83 c3 01             	add    $0x1,%ebx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 32b:	84 c0                	test   %al,%al
 32d:	0f 84 23 01 00 00    	je     456 <printf+0x161>
    c = fmt[i] & 0xff;
 333:	0f be f8             	movsbl %al,%edi
 336:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 339:	85 f6                	test   %esi,%esi
 33b:	75 df                	jne    31c <printf+0x27>
      if(c == '%'){
 33d:	83 f8 25             	cmp    $0x25,%eax
 340:	75 ce                	jne    310 <printf+0x1b>
        state = '%';
 342:	89 c6                	mov    %eax,%esi
 344:	eb db                	jmp    321 <printf+0x2c>
      if(c == 'd'){
 346:	83 f8 64             	cmp    $0x64,%eax
 349:	74 49                	je     394 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 34b:	83 f8 78             	cmp    $0x78,%eax
 34e:	0f 94 c1             	sete   %cl
 351:	83 f8 70             	cmp    $0x70,%eax
 354:	0f 94 c2             	sete   %dl
 357:	08 d1                	or     %dl,%cl
 359:	75 63                	jne    3be <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 35b:	83 f8 73             	cmp    $0x73,%eax
 35e:	0f 84 84 00 00 00    	je     3e8 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 364:	83 f8 63             	cmp    $0x63,%eax
 367:	0f 84 b7 00 00 00    	je     424 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 36d:	83 f8 25             	cmp    $0x25,%eax
 370:	0f 84 cc 00 00 00    	je     442 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 376:	ba 25 00 00 00       	mov    $0x25,%edx
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	e8 d8 fe ff ff       	call   25b <putc>
        putc(fd, c);
 383:	89 fa                	mov    %edi,%edx
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	e8 ce fe ff ff       	call   25b <putc>
      }
      state = 0;
 38d:	be 00 00 00 00       	mov    $0x0,%esi
 392:	eb 8d                	jmp    321 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 397:	8b 17                	mov    (%edi),%edx
 399:	83 ec 0c             	sub    $0xc,%esp
 39c:	6a 01                	push   $0x1
 39e:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3a3:	8b 45 08             	mov    0x8(%ebp),%eax
 3a6:	e8 ca fe ff ff       	call   275 <printint>
        ap++;
 3ab:	83 c7 04             	add    $0x4,%edi
 3ae:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3b1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3b4:	be 00 00 00 00       	mov    $0x0,%esi
 3b9:	e9 63 ff ff ff       	jmp    321 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3c1:	8b 17                	mov    (%edi),%edx
 3c3:	83 ec 0c             	sub    $0xc,%esp
 3c6:	6a 00                	push   $0x0
 3c8:	b9 10 00 00 00       	mov    $0x10,%ecx
 3cd:	8b 45 08             	mov    0x8(%ebp),%eax
 3d0:	e8 a0 fe ff ff       	call   275 <printint>
        ap++;
 3d5:	83 c7 04             	add    $0x4,%edi
 3d8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3db:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3de:	be 00 00 00 00       	mov    $0x0,%esi
 3e3:	e9 39 ff ff ff       	jmp    321 <printf+0x2c>
        s = (char*)*ap;
 3e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3eb:	8b 30                	mov    (%eax),%esi
        ap++;
 3ed:	83 c0 04             	add    $0x4,%eax
 3f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 3f3:	85 f6                	test   %esi,%esi
 3f5:	75 28                	jne    41f <printf+0x12a>
          s = "(null)";
 3f7:	be b0 05 00 00       	mov    $0x5b0,%esi
 3fc:	8b 7d 08             	mov    0x8(%ebp),%edi
 3ff:	eb 0d                	jmp    40e <printf+0x119>
          putc(fd, *s);
 401:	0f be d2             	movsbl %dl,%edx
 404:	89 f8                	mov    %edi,%eax
 406:	e8 50 fe ff ff       	call   25b <putc>
          s++;
 40b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 40e:	0f b6 16             	movzbl (%esi),%edx
 411:	84 d2                	test   %dl,%dl
 413:	75 ec                	jne    401 <printf+0x10c>
      state = 0;
 415:	be 00 00 00 00       	mov    $0x0,%esi
 41a:	e9 02 ff ff ff       	jmp    321 <printf+0x2c>
 41f:	8b 7d 08             	mov    0x8(%ebp),%edi
 422:	eb ea                	jmp    40e <printf+0x119>
        putc(fd, *ap);
 424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 427:	0f be 17             	movsbl (%edi),%edx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	e8 29 fe ff ff       	call   25b <putc>
        ap++;
 432:	83 c7 04             	add    $0x4,%edi
 435:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 438:	be 00 00 00 00       	mov    $0x0,%esi
 43d:	e9 df fe ff ff       	jmp    321 <printf+0x2c>
        putc(fd, c);
 442:	89 fa                	mov    %edi,%edx
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	e8 0f fe ff ff       	call   25b <putc>
      state = 0;
 44c:	be 00 00 00 00       	mov    $0x0,%esi
 451:	e9 cb fe ff ff       	jmp    321 <printf+0x2c>
    }
  }
}
 456:	8d 65 f4             	lea    -0xc(%ebp),%esp
 459:	5b                   	pop    %ebx
 45a:	5e                   	pop    %esi
 45b:	5f                   	pop    %edi
 45c:	5d                   	pop    %ebp
 45d:	c3                   	ret    

0000045e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 45e:	55                   	push   %ebp
 45f:	89 e5                	mov    %esp,%ebp
 461:	57                   	push   %edi
 462:	56                   	push   %esi
 463:	53                   	push   %ebx
 464:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 467:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 46a:	a1 50 08 00 00       	mov    0x850,%eax
 46f:	eb 02                	jmp    473 <free+0x15>
 471:	89 d0                	mov    %edx,%eax
 473:	39 c8                	cmp    %ecx,%eax
 475:	73 04                	jae    47b <free+0x1d>
 477:	39 08                	cmp    %ecx,(%eax)
 479:	77 12                	ja     48d <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 47b:	8b 10                	mov    (%eax),%edx
 47d:	39 c2                	cmp    %eax,%edx
 47f:	77 f0                	ja     471 <free+0x13>
 481:	39 c8                	cmp    %ecx,%eax
 483:	72 08                	jb     48d <free+0x2f>
 485:	39 ca                	cmp    %ecx,%edx
 487:	77 04                	ja     48d <free+0x2f>
 489:	89 d0                	mov    %edx,%eax
 48b:	eb e6                	jmp    473 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 48d:	8b 73 fc             	mov    -0x4(%ebx),%esi
 490:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 493:	8b 10                	mov    (%eax),%edx
 495:	39 d7                	cmp    %edx,%edi
 497:	74 19                	je     4b2 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 499:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 49c:	8b 50 04             	mov    0x4(%eax),%edx
 49f:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4a2:	39 ce                	cmp    %ecx,%esi
 4a4:	74 1b                	je     4c1 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4a6:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4a8:	a3 50 08 00 00       	mov    %eax,0x850
}
 4ad:	5b                   	pop    %ebx
 4ae:	5e                   	pop    %esi
 4af:	5f                   	pop    %edi
 4b0:	5d                   	pop    %ebp
 4b1:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4b2:	03 72 04             	add    0x4(%edx),%esi
 4b5:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4b8:	8b 10                	mov    (%eax),%edx
 4ba:	8b 12                	mov    (%edx),%edx
 4bc:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4bf:	eb db                	jmp    49c <free+0x3e>
    p->s.size += bp->s.size;
 4c1:	03 53 fc             	add    -0x4(%ebx),%edx
 4c4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4c7:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4ca:	89 10                	mov    %edx,(%eax)
 4cc:	eb da                	jmp    4a8 <free+0x4a>

000004ce <morecore>:

static Header*
morecore(uint nu)
{
 4ce:	55                   	push   %ebp
 4cf:	89 e5                	mov    %esp,%ebp
 4d1:	53                   	push   %ebx
 4d2:	83 ec 04             	sub    $0x4,%esp
 4d5:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4d7:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4dc:	77 05                	ja     4e3 <morecore+0x15>
    nu = 4096;
 4de:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 4e3:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 4ea:	83 ec 0c             	sub    $0xc,%esp
 4ed:	50                   	push   %eax
 4ee:	e8 50 fd ff ff       	call   243 <sbrk>
  if(p == (char*)-1)
 4f3:	83 c4 10             	add    $0x10,%esp
 4f6:	83 f8 ff             	cmp    $0xffffffff,%eax
 4f9:	74 1c                	je     517 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 4fb:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 4fe:	83 c0 08             	add    $0x8,%eax
 501:	83 ec 0c             	sub    $0xc,%esp
 504:	50                   	push   %eax
 505:	e8 54 ff ff ff       	call   45e <free>
  return freep;
 50a:	a1 50 08 00 00       	mov    0x850,%eax
 50f:	83 c4 10             	add    $0x10,%esp
}
 512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 515:	c9                   	leave  
 516:	c3                   	ret    
    return 0;
 517:	b8 00 00 00 00       	mov    $0x0,%eax
 51c:	eb f4                	jmp    512 <morecore+0x44>

0000051e <malloc>:

void*
malloc(uint nbytes)
{
 51e:	55                   	push   %ebp
 51f:	89 e5                	mov    %esp,%ebp
 521:	53                   	push   %ebx
 522:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 525:	8b 45 08             	mov    0x8(%ebp),%eax
 528:	8d 58 07             	lea    0x7(%eax),%ebx
 52b:	c1 eb 03             	shr    $0x3,%ebx
 52e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 531:	8b 0d 50 08 00 00    	mov    0x850,%ecx
 537:	85 c9                	test   %ecx,%ecx
 539:	74 04                	je     53f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 53b:	8b 01                	mov    (%ecx),%eax
 53d:	eb 4d                	jmp    58c <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 53f:	c7 05 50 08 00 00 54 	movl   $0x854,0x850
 546:	08 00 00 
 549:	c7 05 54 08 00 00 54 	movl   $0x854,0x854
 550:	08 00 00 
    base.s.size = 0;
 553:	c7 05 58 08 00 00 00 	movl   $0x0,0x858
 55a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 55d:	b9 54 08 00 00       	mov    $0x854,%ecx
 562:	eb d7                	jmp    53b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 564:	39 da                	cmp    %ebx,%edx
 566:	74 1a                	je     582 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 568:	29 da                	sub    %ebx,%edx
 56a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 56d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 570:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 573:	89 0d 50 08 00 00    	mov    %ecx,0x850
      return (void*)(p + 1);
 579:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 57c:	83 c4 04             	add    $0x4,%esp
 57f:	5b                   	pop    %ebx
 580:	5d                   	pop    %ebp
 581:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 582:	8b 10                	mov    (%eax),%edx
 584:	89 11                	mov    %edx,(%ecx)
 586:	eb eb                	jmp    573 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 588:	89 c1                	mov    %eax,%ecx
 58a:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 58c:	8b 50 04             	mov    0x4(%eax),%edx
 58f:	39 da                	cmp    %ebx,%edx
 591:	73 d1                	jae    564 <malloc+0x46>
    if(p == freep)
 593:	39 05 50 08 00 00    	cmp    %eax,0x850
 599:	75 ed                	jne    588 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 59b:	89 d8                	mov    %ebx,%eax
 59d:	e8 2c ff ff ff       	call   4ce <morecore>
 5a2:	85 c0                	test   %eax,%eax
 5a4:	75 e2                	jne    588 <malloc+0x6a>
        return 0;
 5a6:	b8 00 00 00 00       	mov    $0x0,%eax
 5ab:	eb cf                	jmp    57c <malloc+0x5e>
