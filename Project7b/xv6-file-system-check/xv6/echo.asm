
_echo:     file format elf32-i386


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
  11:	83 ec 08             	sub    $0x8,%esp
  14:	8b 31                	mov    (%ecx),%esi
  16:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  for(i = 1; i < argc; i++)
  19:	b8 01 00 00 00       	mov    $0x1,%eax
  1e:	eb 1a                	jmp    3a <main+0x3a>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  20:	ba d2 05 00 00       	mov    $0x5d2,%edx
  25:	52                   	push   %edx
  26:	ff 34 87             	pushl  (%edi,%eax,4)
  29:	68 d4 05 00 00       	push   $0x5d4
  2e:	6a 01                	push   $0x1
  30:	e8 e3 02 00 00       	call   318 <printf>
  for(i = 1; i < argc; i++)
  35:	83 c4 10             	add    $0x10,%esp
  38:	89 d8                	mov    %ebx,%eax
  3a:	39 f0                	cmp    %esi,%eax
  3c:	7d 0e                	jge    4c <main+0x4c>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  3e:	8d 58 01             	lea    0x1(%eax),%ebx
  41:	39 f3                	cmp    %esi,%ebx
  43:	7d db                	jge    20 <main+0x20>
  45:	ba d0 05 00 00       	mov    $0x5d0,%edx
  4a:	eb d9                	jmp    25 <main+0x25>
  exit();
  4c:	e8 8d 01 00 00       	call   1de <exit>

00000051 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	53                   	push   %ebx
  55:	8b 45 08             	mov    0x8(%ebp),%eax
  58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5b:	89 c2                	mov    %eax,%edx
  5d:	0f b6 19             	movzbl (%ecx),%ebx
  60:	88 1a                	mov    %bl,(%edx)
  62:	8d 52 01             	lea    0x1(%edx),%edx
  65:	8d 49 01             	lea    0x1(%ecx),%ecx
  68:	84 db                	test   %bl,%bl
  6a:	75 f1                	jne    5d <strcpy+0xc>
    ;
  return os;
}
  6c:	5b                   	pop    %ebx
  6d:	5d                   	pop    %ebp
  6e:	c3                   	ret    

0000006f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  6f:	55                   	push   %ebp
  70:	89 e5                	mov    %esp,%ebp
  72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  75:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  78:	eb 06                	jmp    80 <strcmp+0x11>
    p++, q++;
  7a:	83 c1 01             	add    $0x1,%ecx
  7d:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  80:	0f b6 01             	movzbl (%ecx),%eax
  83:	84 c0                	test   %al,%al
  85:	74 04                	je     8b <strcmp+0x1c>
  87:	3a 02                	cmp    (%edx),%al
  89:	74 ef                	je     7a <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  8b:	0f b6 c0             	movzbl %al,%eax
  8e:	0f b6 12             	movzbl (%edx),%edx
  91:	29 d0                	sub    %edx,%eax
}
  93:	5d                   	pop    %ebp
  94:	c3                   	ret    

00000095 <strlen>:

uint
strlen(const char *s)
{
  95:	55                   	push   %ebp
  96:	89 e5                	mov    %esp,%ebp
  98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  9b:	ba 00 00 00 00       	mov    $0x0,%edx
  a0:	eb 03                	jmp    a5 <strlen+0x10>
  a2:	83 c2 01             	add    $0x1,%edx
  a5:	89 d0                	mov    %edx,%eax
  a7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  ab:	75 f5                	jne    a2 <strlen+0xd>
    ;
  return n;
}
  ad:	5d                   	pop    %ebp
  ae:	c3                   	ret    

000000af <memset>:

void*
memset(void *dst, int c, uint n)
{
  af:	55                   	push   %ebp
  b0:	89 e5                	mov    %esp,%ebp
  b2:	57                   	push   %edi
  b3:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  b6:	89 d7                	mov    %edx,%edi
  b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  be:	fc                   	cld    
  bf:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  c1:	89 d0                	mov    %edx,%eax
  c3:	5f                   	pop    %edi
  c4:	5d                   	pop    %ebp
  c5:	c3                   	ret    

000000c6 <strchr>:

char*
strchr(const char *s, char c)
{
  c6:	55                   	push   %ebp
  c7:	89 e5                	mov    %esp,%ebp
  c9:	8b 45 08             	mov    0x8(%ebp),%eax
  cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  d0:	0f b6 10             	movzbl (%eax),%edx
  d3:	84 d2                	test   %dl,%dl
  d5:	74 09                	je     e0 <strchr+0x1a>
    if(*s == c)
  d7:	38 ca                	cmp    %cl,%dl
  d9:	74 0a                	je     e5 <strchr+0x1f>
  for(; *s; s++)
  db:	83 c0 01             	add    $0x1,%eax
  de:	eb f0                	jmp    d0 <strchr+0xa>
      return (char*)s;
  return 0;
  e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  e5:	5d                   	pop    %ebp
  e6:	c3                   	ret    

000000e7 <gets>:

char*
gets(char *buf, int max)
{
  e7:	55                   	push   %ebp
  e8:	89 e5                	mov    %esp,%ebp
  ea:	57                   	push   %edi
  eb:	56                   	push   %esi
  ec:	53                   	push   %ebx
  ed:	83 ec 1c             	sub    $0x1c,%esp
  f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  f8:	8d 73 01             	lea    0x1(%ebx),%esi
  fb:	3b 75 0c             	cmp    0xc(%ebp),%esi
  fe:	7d 2e                	jge    12e <gets+0x47>
    cc = read(0, &c, 1);
 100:	83 ec 04             	sub    $0x4,%esp
 103:	6a 01                	push   $0x1
 105:	8d 45 e7             	lea    -0x19(%ebp),%eax
 108:	50                   	push   %eax
 109:	6a 00                	push   $0x0
 10b:	e8 e6 00 00 00       	call   1f6 <read>
    if(cc < 1)
 110:	83 c4 10             	add    $0x10,%esp
 113:	85 c0                	test   %eax,%eax
 115:	7e 17                	jle    12e <gets+0x47>
      break;
    buf[i++] = c;
 117:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 11b:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 11e:	3c 0a                	cmp    $0xa,%al
 120:	0f 94 c2             	sete   %dl
 123:	3c 0d                	cmp    $0xd,%al
 125:	0f 94 c0             	sete   %al
    buf[i++] = c;
 128:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 12a:	08 c2                	or     %al,%dl
 12c:	74 ca                	je     f8 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 12e:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 132:	89 f8                	mov    %edi,%eax
 134:	8d 65 f4             	lea    -0xc(%ebp),%esp
 137:	5b                   	pop    %ebx
 138:	5e                   	pop    %esi
 139:	5f                   	pop    %edi
 13a:	5d                   	pop    %ebp
 13b:	c3                   	ret    

0000013c <stat>:

int
stat(const char *n, struct stat *st)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	56                   	push   %esi
 140:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 141:	83 ec 08             	sub    $0x8,%esp
 144:	6a 00                	push   $0x0
 146:	ff 75 08             	pushl  0x8(%ebp)
 149:	e8 d0 00 00 00       	call   21e <open>
  if(fd < 0)
 14e:	83 c4 10             	add    $0x10,%esp
 151:	85 c0                	test   %eax,%eax
 153:	78 24                	js     179 <stat+0x3d>
 155:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 157:	83 ec 08             	sub    $0x8,%esp
 15a:	ff 75 0c             	pushl  0xc(%ebp)
 15d:	50                   	push   %eax
 15e:	e8 d3 00 00 00       	call   236 <fstat>
 163:	89 c6                	mov    %eax,%esi
  close(fd);
 165:	89 1c 24             	mov    %ebx,(%esp)
 168:	e8 99 00 00 00       	call   206 <close>
  return r;
 16d:	83 c4 10             	add    $0x10,%esp
}
 170:	89 f0                	mov    %esi,%eax
 172:	8d 65 f8             	lea    -0x8(%ebp),%esp
 175:	5b                   	pop    %ebx
 176:	5e                   	pop    %esi
 177:	5d                   	pop    %ebp
 178:	c3                   	ret    
    return -1;
 179:	be ff ff ff ff       	mov    $0xffffffff,%esi
 17e:	eb f0                	jmp    170 <stat+0x34>

00000180 <atoi>:

int
atoi(const char *s)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	53                   	push   %ebx
 184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 187:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 18c:	eb 10                	jmp    19e <atoi+0x1e>
    n = n*10 + *s++ - '0';
 18e:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 191:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 194:	83 c1 01             	add    $0x1,%ecx
 197:	0f be d2             	movsbl %dl,%edx
 19a:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 19e:	0f b6 11             	movzbl (%ecx),%edx
 1a1:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1a4:	80 fb 09             	cmp    $0x9,%bl
 1a7:	76 e5                	jbe    18e <atoi+0xe>
  return n;
}
 1a9:	5b                   	pop    %ebx
 1aa:	5d                   	pop    %ebp
 1ab:	c3                   	ret    

000001ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	56                   	push   %esi
 1b0:	53                   	push   %ebx
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1b7:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1ba:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1bc:	eb 0d                	jmp    1cb <memmove+0x1f>
    *dst++ = *src++;
 1be:	0f b6 13             	movzbl (%ebx),%edx
 1c1:	88 11                	mov    %dl,(%ecx)
 1c3:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1c6:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1c9:	89 f2                	mov    %esi,%edx
 1cb:	8d 72 ff             	lea    -0x1(%edx),%esi
 1ce:	85 d2                	test   %edx,%edx
 1d0:	7f ec                	jg     1be <memmove+0x12>
  return vdst;
}
 1d2:	5b                   	pop    %ebx
 1d3:	5e                   	pop    %esi
 1d4:	5d                   	pop    %ebp
 1d5:	c3                   	ret    

000001d6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1d6:	b8 01 00 00 00       	mov    $0x1,%eax
 1db:	cd 40                	int    $0x40
 1dd:	c3                   	ret    

000001de <exit>:
SYSCALL(exit)
 1de:	b8 02 00 00 00       	mov    $0x2,%eax
 1e3:	cd 40                	int    $0x40
 1e5:	c3                   	ret    

000001e6 <wait>:
SYSCALL(wait)
 1e6:	b8 03 00 00 00       	mov    $0x3,%eax
 1eb:	cd 40                	int    $0x40
 1ed:	c3                   	ret    

000001ee <pipe>:
SYSCALL(pipe)
 1ee:	b8 04 00 00 00       	mov    $0x4,%eax
 1f3:	cd 40                	int    $0x40
 1f5:	c3                   	ret    

000001f6 <read>:
SYSCALL(read)
 1f6:	b8 05 00 00 00       	mov    $0x5,%eax
 1fb:	cd 40                	int    $0x40
 1fd:	c3                   	ret    

000001fe <write>:
SYSCALL(write)
 1fe:	b8 10 00 00 00       	mov    $0x10,%eax
 203:	cd 40                	int    $0x40
 205:	c3                   	ret    

00000206 <close>:
SYSCALL(close)
 206:	b8 15 00 00 00       	mov    $0x15,%eax
 20b:	cd 40                	int    $0x40
 20d:	c3                   	ret    

0000020e <kill>:
SYSCALL(kill)
 20e:	b8 06 00 00 00       	mov    $0x6,%eax
 213:	cd 40                	int    $0x40
 215:	c3                   	ret    

00000216 <exec>:
SYSCALL(exec)
 216:	b8 07 00 00 00       	mov    $0x7,%eax
 21b:	cd 40                	int    $0x40
 21d:	c3                   	ret    

0000021e <open>:
SYSCALL(open)
 21e:	b8 0f 00 00 00       	mov    $0xf,%eax
 223:	cd 40                	int    $0x40
 225:	c3                   	ret    

00000226 <mknod>:
SYSCALL(mknod)
 226:	b8 11 00 00 00       	mov    $0x11,%eax
 22b:	cd 40                	int    $0x40
 22d:	c3                   	ret    

0000022e <unlink>:
SYSCALL(unlink)
 22e:	b8 12 00 00 00       	mov    $0x12,%eax
 233:	cd 40                	int    $0x40
 235:	c3                   	ret    

00000236 <fstat>:
SYSCALL(fstat)
 236:	b8 08 00 00 00       	mov    $0x8,%eax
 23b:	cd 40                	int    $0x40
 23d:	c3                   	ret    

0000023e <link>:
SYSCALL(link)
 23e:	b8 13 00 00 00       	mov    $0x13,%eax
 243:	cd 40                	int    $0x40
 245:	c3                   	ret    

00000246 <mkdir>:
SYSCALL(mkdir)
 246:	b8 14 00 00 00       	mov    $0x14,%eax
 24b:	cd 40                	int    $0x40
 24d:	c3                   	ret    

0000024e <chdir>:
SYSCALL(chdir)
 24e:	b8 09 00 00 00       	mov    $0x9,%eax
 253:	cd 40                	int    $0x40
 255:	c3                   	ret    

00000256 <dup>:
SYSCALL(dup)
 256:	b8 0a 00 00 00       	mov    $0xa,%eax
 25b:	cd 40                	int    $0x40
 25d:	c3                   	ret    

0000025e <getpid>:
SYSCALL(getpid)
 25e:	b8 0b 00 00 00       	mov    $0xb,%eax
 263:	cd 40                	int    $0x40
 265:	c3                   	ret    

00000266 <sbrk>:
SYSCALL(sbrk)
 266:	b8 0c 00 00 00       	mov    $0xc,%eax
 26b:	cd 40                	int    $0x40
 26d:	c3                   	ret    

0000026e <sleep>:
SYSCALL(sleep)
 26e:	b8 0d 00 00 00       	mov    $0xd,%eax
 273:	cd 40                	int    $0x40
 275:	c3                   	ret    

00000276 <uptime>:
SYSCALL(uptime)
 276:	b8 0e 00 00 00       	mov    $0xe,%eax
 27b:	cd 40                	int    $0x40
 27d:	c3                   	ret    

0000027e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	83 ec 1c             	sub    $0x1c,%esp
 284:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 287:	6a 01                	push   $0x1
 289:	8d 55 f4             	lea    -0xc(%ebp),%edx
 28c:	52                   	push   %edx
 28d:	50                   	push   %eax
 28e:	e8 6b ff ff ff       	call   1fe <write>
}
 293:	83 c4 10             	add    $0x10,%esp
 296:	c9                   	leave  
 297:	c3                   	ret    

00000298 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	57                   	push   %edi
 29c:	56                   	push   %esi
 29d:	53                   	push   %ebx
 29e:	83 ec 2c             	sub    $0x2c,%esp
 2a1:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2a7:	0f 95 c3             	setne  %bl
 2aa:	89 d0                	mov    %edx,%eax
 2ac:	c1 e8 1f             	shr    $0x1f,%eax
 2af:	84 c3                	test   %al,%bl
 2b1:	74 10                	je     2c3 <printint+0x2b>
    neg = 1;
    x = -xx;
 2b3:	f7 da                	neg    %edx
    neg = 1;
 2b5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2bc:	be 00 00 00 00       	mov    $0x0,%esi
 2c1:	eb 0b                	jmp    2ce <printint+0x36>
  neg = 0;
 2c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2ca:	eb f0                	jmp    2bc <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2cc:	89 c6                	mov    %eax,%esi
 2ce:	89 d0                	mov    %edx,%eax
 2d0:	ba 00 00 00 00       	mov    $0x0,%edx
 2d5:	f7 f1                	div    %ecx
 2d7:	89 c3                	mov    %eax,%ebx
 2d9:	8d 46 01             	lea    0x1(%esi),%eax
 2dc:	0f b6 92 e0 05 00 00 	movzbl 0x5e0(%edx),%edx
 2e3:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2e7:	89 da                	mov    %ebx,%edx
 2e9:	85 db                	test   %ebx,%ebx
 2eb:	75 df                	jne    2cc <printint+0x34>
 2ed:	89 c3                	mov    %eax,%ebx
  if(neg)
 2ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2f3:	74 16                	je     30b <printint+0x73>
    buf[i++] = '-';
 2f5:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2fa:	8d 5e 02             	lea    0x2(%esi),%ebx
 2fd:	eb 0c                	jmp    30b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2ff:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 304:	89 f8                	mov    %edi,%eax
 306:	e8 73 ff ff ff       	call   27e <putc>
  while(--i >= 0)
 30b:	83 eb 01             	sub    $0x1,%ebx
 30e:	79 ef                	jns    2ff <printint+0x67>
}
 310:	83 c4 2c             	add    $0x2c,%esp
 313:	5b                   	pop    %ebx
 314:	5e                   	pop    %esi
 315:	5f                   	pop    %edi
 316:	5d                   	pop    %ebp
 317:	c3                   	ret    

00000318 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 318:	55                   	push   %ebp
 319:	89 e5                	mov    %esp,%ebp
 31b:	57                   	push   %edi
 31c:	56                   	push   %esi
 31d:	53                   	push   %ebx
 31e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 321:	8d 45 10             	lea    0x10(%ebp),%eax
 324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 327:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 32c:	bb 00 00 00 00       	mov    $0x0,%ebx
 331:	eb 14                	jmp    347 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 333:	89 fa                	mov    %edi,%edx
 335:	8b 45 08             	mov    0x8(%ebp),%eax
 338:	e8 41 ff ff ff       	call   27e <putc>
 33d:	eb 05                	jmp    344 <printf+0x2c>
      }
    } else if(state == '%'){
 33f:	83 fe 25             	cmp    $0x25,%esi
 342:	74 25                	je     369 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 344:	83 c3 01             	add    $0x1,%ebx
 347:	8b 45 0c             	mov    0xc(%ebp),%eax
 34a:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 34e:	84 c0                	test   %al,%al
 350:	0f 84 23 01 00 00    	je     479 <printf+0x161>
    c = fmt[i] & 0xff;
 356:	0f be f8             	movsbl %al,%edi
 359:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 35c:	85 f6                	test   %esi,%esi
 35e:	75 df                	jne    33f <printf+0x27>
      if(c == '%'){
 360:	83 f8 25             	cmp    $0x25,%eax
 363:	75 ce                	jne    333 <printf+0x1b>
        state = '%';
 365:	89 c6                	mov    %eax,%esi
 367:	eb db                	jmp    344 <printf+0x2c>
      if(c == 'd'){
 369:	83 f8 64             	cmp    $0x64,%eax
 36c:	74 49                	je     3b7 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 36e:	83 f8 78             	cmp    $0x78,%eax
 371:	0f 94 c1             	sete   %cl
 374:	83 f8 70             	cmp    $0x70,%eax
 377:	0f 94 c2             	sete   %dl
 37a:	08 d1                	or     %dl,%cl
 37c:	75 63                	jne    3e1 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 37e:	83 f8 73             	cmp    $0x73,%eax
 381:	0f 84 84 00 00 00    	je     40b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 387:	83 f8 63             	cmp    $0x63,%eax
 38a:	0f 84 b7 00 00 00    	je     447 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 390:	83 f8 25             	cmp    $0x25,%eax
 393:	0f 84 cc 00 00 00    	je     465 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 399:	ba 25 00 00 00       	mov    $0x25,%edx
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
 3a1:	e8 d8 fe ff ff       	call   27e <putc>
        putc(fd, c);
 3a6:	89 fa                	mov    %edi,%edx
 3a8:	8b 45 08             	mov    0x8(%ebp),%eax
 3ab:	e8 ce fe ff ff       	call   27e <putc>
      }
      state = 0;
 3b0:	be 00 00 00 00       	mov    $0x0,%esi
 3b5:	eb 8d                	jmp    344 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3ba:	8b 17                	mov    (%edi),%edx
 3bc:	83 ec 0c             	sub    $0xc,%esp
 3bf:	6a 01                	push   $0x1
 3c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	e8 ca fe ff ff       	call   298 <printint>
        ap++;
 3ce:	83 c7 04             	add    $0x4,%edi
 3d1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d4:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3d7:	be 00 00 00 00       	mov    $0x0,%esi
 3dc:	e9 63 ff ff ff       	jmp    344 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e4:	8b 17                	mov    (%edi),%edx
 3e6:	83 ec 0c             	sub    $0xc,%esp
 3e9:	6a 00                	push   $0x0
 3eb:	b9 10 00 00 00       	mov    $0x10,%ecx
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	e8 a0 fe ff ff       	call   298 <printint>
        ap++;
 3f8:	83 c7 04             	add    $0x4,%edi
 3fb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fe:	83 c4 10             	add    $0x10,%esp
      state = 0;
 401:	be 00 00 00 00       	mov    $0x0,%esi
 406:	e9 39 ff ff ff       	jmp    344 <printf+0x2c>
        s = (char*)*ap;
 40b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 40e:	8b 30                	mov    (%eax),%esi
        ap++;
 410:	83 c0 04             	add    $0x4,%eax
 413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 416:	85 f6                	test   %esi,%esi
 418:	75 28                	jne    442 <printf+0x12a>
          s = "(null)";
 41a:	be d9 05 00 00       	mov    $0x5d9,%esi
 41f:	8b 7d 08             	mov    0x8(%ebp),%edi
 422:	eb 0d                	jmp    431 <printf+0x119>
          putc(fd, *s);
 424:	0f be d2             	movsbl %dl,%edx
 427:	89 f8                	mov    %edi,%eax
 429:	e8 50 fe ff ff       	call   27e <putc>
          s++;
 42e:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 431:	0f b6 16             	movzbl (%esi),%edx
 434:	84 d2                	test   %dl,%dl
 436:	75 ec                	jne    424 <printf+0x10c>
      state = 0;
 438:	be 00 00 00 00       	mov    $0x0,%esi
 43d:	e9 02 ff ff ff       	jmp    344 <printf+0x2c>
 442:	8b 7d 08             	mov    0x8(%ebp),%edi
 445:	eb ea                	jmp    431 <printf+0x119>
        putc(fd, *ap);
 447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44a:	0f be 17             	movsbl (%edi),%edx
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	e8 29 fe ff ff       	call   27e <putc>
        ap++;
 455:	83 c7 04             	add    $0x4,%edi
 458:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 45b:	be 00 00 00 00       	mov    $0x0,%esi
 460:	e9 df fe ff ff       	jmp    344 <printf+0x2c>
        putc(fd, c);
 465:	89 fa                	mov    %edi,%edx
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	e8 0f fe ff ff       	call   27e <putc>
      state = 0;
 46f:	be 00 00 00 00       	mov    $0x0,%esi
 474:	e9 cb fe ff ff       	jmp    344 <printf+0x2c>
    }
  }
}
 479:	8d 65 f4             	lea    -0xc(%ebp),%esp
 47c:	5b                   	pop    %ebx
 47d:	5e                   	pop    %esi
 47e:	5f                   	pop    %edi
 47f:	5d                   	pop    %ebp
 480:	c3                   	ret    

00000481 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 481:	55                   	push   %ebp
 482:	89 e5                	mov    %esp,%ebp
 484:	57                   	push   %edi
 485:	56                   	push   %esi
 486:	53                   	push   %ebx
 487:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 48a:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 48d:	a1 84 08 00 00       	mov    0x884,%eax
 492:	eb 02                	jmp    496 <free+0x15>
 494:	89 d0                	mov    %edx,%eax
 496:	39 c8                	cmp    %ecx,%eax
 498:	73 04                	jae    49e <free+0x1d>
 49a:	39 08                	cmp    %ecx,(%eax)
 49c:	77 12                	ja     4b0 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 49e:	8b 10                	mov    (%eax),%edx
 4a0:	39 c2                	cmp    %eax,%edx
 4a2:	77 f0                	ja     494 <free+0x13>
 4a4:	39 c8                	cmp    %ecx,%eax
 4a6:	72 08                	jb     4b0 <free+0x2f>
 4a8:	39 ca                	cmp    %ecx,%edx
 4aa:	77 04                	ja     4b0 <free+0x2f>
 4ac:	89 d0                	mov    %edx,%eax
 4ae:	eb e6                	jmp    496 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4b0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b6:	8b 10                	mov    (%eax),%edx
 4b8:	39 d7                	cmp    %edx,%edi
 4ba:	74 19                	je     4d5 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4bc:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4bf:	8b 50 04             	mov    0x4(%eax),%edx
 4c2:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c5:	39 ce                	cmp    %ecx,%esi
 4c7:	74 1b                	je     4e4 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4c9:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4cb:	a3 84 08 00 00       	mov    %eax,0x884
}
 4d0:	5b                   	pop    %ebx
 4d1:	5e                   	pop    %esi
 4d2:	5f                   	pop    %edi
 4d3:	5d                   	pop    %ebp
 4d4:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4d5:	03 72 04             	add    0x4(%edx),%esi
 4d8:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4db:	8b 10                	mov    (%eax),%edx
 4dd:	8b 12                	mov    (%edx),%edx
 4df:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4e2:	eb db                	jmp    4bf <free+0x3e>
    p->s.size += bp->s.size;
 4e4:	03 53 fc             	add    -0x4(%ebx),%edx
 4e7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4ea:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4ed:	89 10                	mov    %edx,(%eax)
 4ef:	eb da                	jmp    4cb <free+0x4a>

000004f1 <morecore>:

static Header*
morecore(uint nu)
{
 4f1:	55                   	push   %ebp
 4f2:	89 e5                	mov    %esp,%ebp
 4f4:	53                   	push   %ebx
 4f5:	83 ec 04             	sub    $0x4,%esp
 4f8:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4fa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4ff:	77 05                	ja     506 <morecore+0x15>
    nu = 4096;
 501:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 506:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 50d:	83 ec 0c             	sub    $0xc,%esp
 510:	50                   	push   %eax
 511:	e8 50 fd ff ff       	call   266 <sbrk>
  if(p == (char*)-1)
 516:	83 c4 10             	add    $0x10,%esp
 519:	83 f8 ff             	cmp    $0xffffffff,%eax
 51c:	74 1c                	je     53a <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 51e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 521:	83 c0 08             	add    $0x8,%eax
 524:	83 ec 0c             	sub    $0xc,%esp
 527:	50                   	push   %eax
 528:	e8 54 ff ff ff       	call   481 <free>
  return freep;
 52d:	a1 84 08 00 00       	mov    0x884,%eax
 532:	83 c4 10             	add    $0x10,%esp
}
 535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 538:	c9                   	leave  
 539:	c3                   	ret    
    return 0;
 53a:	b8 00 00 00 00       	mov    $0x0,%eax
 53f:	eb f4                	jmp    535 <morecore+0x44>

00000541 <malloc>:

void*
malloc(uint nbytes)
{
 541:	55                   	push   %ebp
 542:	89 e5                	mov    %esp,%ebp
 544:	53                   	push   %ebx
 545:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 548:	8b 45 08             	mov    0x8(%ebp),%eax
 54b:	8d 58 07             	lea    0x7(%eax),%ebx
 54e:	c1 eb 03             	shr    $0x3,%ebx
 551:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 554:	8b 0d 84 08 00 00    	mov    0x884,%ecx
 55a:	85 c9                	test   %ecx,%ecx
 55c:	74 04                	je     562 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55e:	8b 01                	mov    (%ecx),%eax
 560:	eb 4d                	jmp    5af <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 562:	c7 05 84 08 00 00 88 	movl   $0x888,0x884
 569:	08 00 00 
 56c:	c7 05 88 08 00 00 88 	movl   $0x888,0x888
 573:	08 00 00 
    base.s.size = 0;
 576:	c7 05 8c 08 00 00 00 	movl   $0x0,0x88c
 57d:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 580:	b9 88 08 00 00       	mov    $0x888,%ecx
 585:	eb d7                	jmp    55e <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 587:	39 da                	cmp    %ebx,%edx
 589:	74 1a                	je     5a5 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 58b:	29 da                	sub    %ebx,%edx
 58d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 590:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 593:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 596:	89 0d 84 08 00 00    	mov    %ecx,0x884
      return (void*)(p + 1);
 59c:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 59f:	83 c4 04             	add    $0x4,%esp
 5a2:	5b                   	pop    %ebx
 5a3:	5d                   	pop    %ebp
 5a4:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5a5:	8b 10                	mov    (%eax),%edx
 5a7:	89 11                	mov    %edx,(%ecx)
 5a9:	eb eb                	jmp    596 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ab:	89 c1                	mov    %eax,%ecx
 5ad:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5af:	8b 50 04             	mov    0x4(%eax),%edx
 5b2:	39 da                	cmp    %ebx,%edx
 5b4:	73 d1                	jae    587 <malloc+0x46>
    if(p == freep)
 5b6:	39 05 84 08 00 00    	cmp    %eax,0x884
 5bc:	75 ed                	jne    5ab <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5be:	89 d8                	mov    %ebx,%eax
 5c0:	e8 2c ff ff ff       	call   4f1 <morecore>
 5c5:	85 c0                	test   %eax,%eax
 5c7:	75 e2                	jne    5ab <malloc+0x6a>
        return 0;
 5c9:	b8 00 00 00 00       	mov    $0x0,%eax
 5ce:	eb cf                	jmp    59f <malloc+0x5e>
