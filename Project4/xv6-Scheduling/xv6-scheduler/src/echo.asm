
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
  20:	ba f2 05 00 00       	mov    $0x5f2,%edx
  25:	52                   	push   %edx
  26:	ff 34 87             	pushl  (%edi,%eax,4)
  29:	68 f4 05 00 00       	push   $0x5f4
  2e:	6a 01                	push   $0x1
  30:	e8 03 03 00 00       	call   338 <printf>
  for(i = 1; i < argc; i++)
  35:	83 c4 10             	add    $0x10,%esp
  38:	89 d8                	mov    %ebx,%eax
  3a:	39 f0                	cmp    %esi,%eax
  3c:	7d 0e                	jge    4c <main+0x4c>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  3e:	8d 58 01             	lea    0x1(%eax),%ebx
  41:	39 f3                	cmp    %esi,%ebx
  43:	7d db                	jge    20 <main+0x20>
  45:	ba f0 05 00 00       	mov    $0x5f0,%edx
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

0000027e <setpri>:
SYSCALL(setpri)
 27e:	b8 16 00 00 00       	mov    $0x16,%eax
 283:	cd 40                	int    $0x40
 285:	c3                   	ret    

00000286 <getpri>:
SYSCALL(getpri)
 286:	b8 17 00 00 00       	mov    $0x17,%eax
 28b:	cd 40                	int    $0x40
 28d:	c3                   	ret    

0000028e <getpinfo>:
SYSCALL(getpinfo)
 28e:	b8 18 00 00 00       	mov    $0x18,%eax
 293:	cd 40                	int    $0x40
 295:	c3                   	ret    

00000296 <fork2>:
SYSCALL(fork2)
 296:	b8 19 00 00 00       	mov    $0x19,%eax
 29b:	cd 40                	int    $0x40
 29d:	c3                   	ret    

0000029e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 29e:	55                   	push   %ebp
 29f:	89 e5                	mov    %esp,%ebp
 2a1:	83 ec 1c             	sub    $0x1c,%esp
 2a4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2a7:	6a 01                	push   $0x1
 2a9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2ac:	52                   	push   %edx
 2ad:	50                   	push   %eax
 2ae:	e8 4b ff ff ff       	call   1fe <write>
}
 2b3:	83 c4 10             	add    $0x10,%esp
 2b6:	c9                   	leave  
 2b7:	c3                   	ret    

000002b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	57                   	push   %edi
 2bc:	56                   	push   %esi
 2bd:	53                   	push   %ebx
 2be:	83 ec 2c             	sub    $0x2c,%esp
 2c1:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2c7:	0f 95 c3             	setne  %bl
 2ca:	89 d0                	mov    %edx,%eax
 2cc:	c1 e8 1f             	shr    $0x1f,%eax
 2cf:	84 c3                	test   %al,%bl
 2d1:	74 10                	je     2e3 <printint+0x2b>
    neg = 1;
    x = -xx;
 2d3:	f7 da                	neg    %edx
    neg = 1;
 2d5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2dc:	be 00 00 00 00       	mov    $0x0,%esi
 2e1:	eb 0b                	jmp    2ee <printint+0x36>
  neg = 0;
 2e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2ea:	eb f0                	jmp    2dc <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2ec:	89 c6                	mov    %eax,%esi
 2ee:	89 d0                	mov    %edx,%eax
 2f0:	ba 00 00 00 00       	mov    $0x0,%edx
 2f5:	f7 f1                	div    %ecx
 2f7:	89 c3                	mov    %eax,%ebx
 2f9:	8d 46 01             	lea    0x1(%esi),%eax
 2fc:	0f b6 92 00 06 00 00 	movzbl 0x600(%edx),%edx
 303:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 307:	89 da                	mov    %ebx,%edx
 309:	85 db                	test   %ebx,%ebx
 30b:	75 df                	jne    2ec <printint+0x34>
 30d:	89 c3                	mov    %eax,%ebx
  if(neg)
 30f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 313:	74 16                	je     32b <printint+0x73>
    buf[i++] = '-';
 315:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 31a:	8d 5e 02             	lea    0x2(%esi),%ebx
 31d:	eb 0c                	jmp    32b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 31f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 324:	89 f8                	mov    %edi,%eax
 326:	e8 73 ff ff ff       	call   29e <putc>
  while(--i >= 0)
 32b:	83 eb 01             	sub    $0x1,%ebx
 32e:	79 ef                	jns    31f <printint+0x67>
}
 330:	83 c4 2c             	add    $0x2c,%esp
 333:	5b                   	pop    %ebx
 334:	5e                   	pop    %esi
 335:	5f                   	pop    %edi
 336:	5d                   	pop    %ebp
 337:	c3                   	ret    

00000338 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 338:	55                   	push   %ebp
 339:	89 e5                	mov    %esp,%ebp
 33b:	57                   	push   %edi
 33c:	56                   	push   %esi
 33d:	53                   	push   %ebx
 33e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 341:	8d 45 10             	lea    0x10(%ebp),%eax
 344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 347:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 34c:	bb 00 00 00 00       	mov    $0x0,%ebx
 351:	eb 14                	jmp    367 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 353:	89 fa                	mov    %edi,%edx
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	e8 41 ff ff ff       	call   29e <putc>
 35d:	eb 05                	jmp    364 <printf+0x2c>
      }
    } else if(state == '%'){
 35f:	83 fe 25             	cmp    $0x25,%esi
 362:	74 25                	je     389 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 364:	83 c3 01             	add    $0x1,%ebx
 367:	8b 45 0c             	mov    0xc(%ebp),%eax
 36a:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 36e:	84 c0                	test   %al,%al
 370:	0f 84 23 01 00 00    	je     499 <printf+0x161>
    c = fmt[i] & 0xff;
 376:	0f be f8             	movsbl %al,%edi
 379:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 37c:	85 f6                	test   %esi,%esi
 37e:	75 df                	jne    35f <printf+0x27>
      if(c == '%'){
 380:	83 f8 25             	cmp    $0x25,%eax
 383:	75 ce                	jne    353 <printf+0x1b>
        state = '%';
 385:	89 c6                	mov    %eax,%esi
 387:	eb db                	jmp    364 <printf+0x2c>
      if(c == 'd'){
 389:	83 f8 64             	cmp    $0x64,%eax
 38c:	74 49                	je     3d7 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 38e:	83 f8 78             	cmp    $0x78,%eax
 391:	0f 94 c1             	sete   %cl
 394:	83 f8 70             	cmp    $0x70,%eax
 397:	0f 94 c2             	sete   %dl
 39a:	08 d1                	or     %dl,%cl
 39c:	75 63                	jne    401 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 39e:	83 f8 73             	cmp    $0x73,%eax
 3a1:	0f 84 84 00 00 00    	je     42b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3a7:	83 f8 63             	cmp    $0x63,%eax
 3aa:	0f 84 b7 00 00 00    	je     467 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3b0:	83 f8 25             	cmp    $0x25,%eax
 3b3:	0f 84 cc 00 00 00    	je     485 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3b9:	ba 25 00 00 00       	mov    $0x25,%edx
 3be:	8b 45 08             	mov    0x8(%ebp),%eax
 3c1:	e8 d8 fe ff ff       	call   29e <putc>
        putc(fd, c);
 3c6:	89 fa                	mov    %edi,%edx
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	e8 ce fe ff ff       	call   29e <putc>
      }
      state = 0;
 3d0:	be 00 00 00 00       	mov    $0x0,%esi
 3d5:	eb 8d                	jmp    364 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3da:	8b 17                	mov    (%edi),%edx
 3dc:	83 ec 0c             	sub    $0xc,%esp
 3df:	6a 01                	push   $0x1
 3e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	e8 ca fe ff ff       	call   2b8 <printint>
        ap++;
 3ee:	83 c7 04             	add    $0x4,%edi
 3f1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3f4:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3f7:	be 00 00 00 00       	mov    $0x0,%esi
 3fc:	e9 63 ff ff ff       	jmp    364 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 404:	8b 17                	mov    (%edi),%edx
 406:	83 ec 0c             	sub    $0xc,%esp
 409:	6a 00                	push   $0x0
 40b:	b9 10 00 00 00       	mov    $0x10,%ecx
 410:	8b 45 08             	mov    0x8(%ebp),%eax
 413:	e8 a0 fe ff ff       	call   2b8 <printint>
        ap++;
 418:	83 c7 04             	add    $0x4,%edi
 41b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 41e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 421:	be 00 00 00 00       	mov    $0x0,%esi
 426:	e9 39 ff ff ff       	jmp    364 <printf+0x2c>
        s = (char*)*ap;
 42b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 42e:	8b 30                	mov    (%eax),%esi
        ap++;
 430:	83 c0 04             	add    $0x4,%eax
 433:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 436:	85 f6                	test   %esi,%esi
 438:	75 28                	jne    462 <printf+0x12a>
          s = "(null)";
 43a:	be f9 05 00 00       	mov    $0x5f9,%esi
 43f:	8b 7d 08             	mov    0x8(%ebp),%edi
 442:	eb 0d                	jmp    451 <printf+0x119>
          putc(fd, *s);
 444:	0f be d2             	movsbl %dl,%edx
 447:	89 f8                	mov    %edi,%eax
 449:	e8 50 fe ff ff       	call   29e <putc>
          s++;
 44e:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 451:	0f b6 16             	movzbl (%esi),%edx
 454:	84 d2                	test   %dl,%dl
 456:	75 ec                	jne    444 <printf+0x10c>
      state = 0;
 458:	be 00 00 00 00       	mov    $0x0,%esi
 45d:	e9 02 ff ff ff       	jmp    364 <printf+0x2c>
 462:	8b 7d 08             	mov    0x8(%ebp),%edi
 465:	eb ea                	jmp    451 <printf+0x119>
        putc(fd, *ap);
 467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 46a:	0f be 17             	movsbl (%edi),%edx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	e8 29 fe ff ff       	call   29e <putc>
        ap++;
 475:	83 c7 04             	add    $0x4,%edi
 478:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 47b:	be 00 00 00 00       	mov    $0x0,%esi
 480:	e9 df fe ff ff       	jmp    364 <printf+0x2c>
        putc(fd, c);
 485:	89 fa                	mov    %edi,%edx
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	e8 0f fe ff ff       	call   29e <putc>
      state = 0;
 48f:	be 00 00 00 00       	mov    $0x0,%esi
 494:	e9 cb fe ff ff       	jmp    364 <printf+0x2c>
    }
  }
}
 499:	8d 65 f4             	lea    -0xc(%ebp),%esp
 49c:	5b                   	pop    %ebx
 49d:	5e                   	pop    %esi
 49e:	5f                   	pop    %edi
 49f:	5d                   	pop    %ebp
 4a0:	c3                   	ret    

000004a1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a1:	55                   	push   %ebp
 4a2:	89 e5                	mov    %esp,%ebp
 4a4:	57                   	push   %edi
 4a5:	56                   	push   %esi
 4a6:	53                   	push   %ebx
 4a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4aa:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4ad:	a1 a4 08 00 00       	mov    0x8a4,%eax
 4b2:	eb 02                	jmp    4b6 <free+0x15>
 4b4:	89 d0                	mov    %edx,%eax
 4b6:	39 c8                	cmp    %ecx,%eax
 4b8:	73 04                	jae    4be <free+0x1d>
 4ba:	39 08                	cmp    %ecx,(%eax)
 4bc:	77 12                	ja     4d0 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4be:	8b 10                	mov    (%eax),%edx
 4c0:	39 c2                	cmp    %eax,%edx
 4c2:	77 f0                	ja     4b4 <free+0x13>
 4c4:	39 c8                	cmp    %ecx,%eax
 4c6:	72 08                	jb     4d0 <free+0x2f>
 4c8:	39 ca                	cmp    %ecx,%edx
 4ca:	77 04                	ja     4d0 <free+0x2f>
 4cc:	89 d0                	mov    %edx,%eax
 4ce:	eb e6                	jmp    4b6 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4d3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4d6:	8b 10                	mov    (%eax),%edx
 4d8:	39 d7                	cmp    %edx,%edi
 4da:	74 19                	je     4f5 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4dc:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4df:	8b 50 04             	mov    0x4(%eax),%edx
 4e2:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4e5:	39 ce                	cmp    %ecx,%esi
 4e7:	74 1b                	je     504 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4e9:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4eb:	a3 a4 08 00 00       	mov    %eax,0x8a4
}
 4f0:	5b                   	pop    %ebx
 4f1:	5e                   	pop    %esi
 4f2:	5f                   	pop    %edi
 4f3:	5d                   	pop    %ebp
 4f4:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4f5:	03 72 04             	add    0x4(%edx),%esi
 4f8:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4fb:	8b 10                	mov    (%eax),%edx
 4fd:	8b 12                	mov    (%edx),%edx
 4ff:	89 53 f8             	mov    %edx,-0x8(%ebx)
 502:	eb db                	jmp    4df <free+0x3e>
    p->s.size += bp->s.size;
 504:	03 53 fc             	add    -0x4(%ebx),%edx
 507:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 50a:	8b 53 f8             	mov    -0x8(%ebx),%edx
 50d:	89 10                	mov    %edx,(%eax)
 50f:	eb da                	jmp    4eb <free+0x4a>

00000511 <morecore>:

static Header*
morecore(uint nu)
{
 511:	55                   	push   %ebp
 512:	89 e5                	mov    %esp,%ebp
 514:	53                   	push   %ebx
 515:	83 ec 04             	sub    $0x4,%esp
 518:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 51a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 51f:	77 05                	ja     526 <morecore+0x15>
    nu = 4096;
 521:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 526:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 52d:	83 ec 0c             	sub    $0xc,%esp
 530:	50                   	push   %eax
 531:	e8 30 fd ff ff       	call   266 <sbrk>
  if(p == (char*)-1)
 536:	83 c4 10             	add    $0x10,%esp
 539:	83 f8 ff             	cmp    $0xffffffff,%eax
 53c:	74 1c                	je     55a <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 53e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 541:	83 c0 08             	add    $0x8,%eax
 544:	83 ec 0c             	sub    $0xc,%esp
 547:	50                   	push   %eax
 548:	e8 54 ff ff ff       	call   4a1 <free>
  return freep;
 54d:	a1 a4 08 00 00       	mov    0x8a4,%eax
 552:	83 c4 10             	add    $0x10,%esp
}
 555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 558:	c9                   	leave  
 559:	c3                   	ret    
    return 0;
 55a:	b8 00 00 00 00       	mov    $0x0,%eax
 55f:	eb f4                	jmp    555 <morecore+0x44>

00000561 <malloc>:

void*
malloc(uint nbytes)
{
 561:	55                   	push   %ebp
 562:	89 e5                	mov    %esp,%ebp
 564:	53                   	push   %ebx
 565:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	8d 58 07             	lea    0x7(%eax),%ebx
 56e:	c1 eb 03             	shr    $0x3,%ebx
 571:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 574:	8b 0d a4 08 00 00    	mov    0x8a4,%ecx
 57a:	85 c9                	test   %ecx,%ecx
 57c:	74 04                	je     582 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 57e:	8b 01                	mov    (%ecx),%eax
 580:	eb 4d                	jmp    5cf <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 582:	c7 05 a4 08 00 00 a8 	movl   $0x8a8,0x8a4
 589:	08 00 00 
 58c:	c7 05 a8 08 00 00 a8 	movl   $0x8a8,0x8a8
 593:	08 00 00 
    base.s.size = 0;
 596:	c7 05 ac 08 00 00 00 	movl   $0x0,0x8ac
 59d:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5a0:	b9 a8 08 00 00       	mov    $0x8a8,%ecx
 5a5:	eb d7                	jmp    57e <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5a7:	39 da                	cmp    %ebx,%edx
 5a9:	74 1a                	je     5c5 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5ab:	29 da                	sub    %ebx,%edx
 5ad:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5b0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5b3:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5b6:	89 0d a4 08 00 00    	mov    %ecx,0x8a4
      return (void*)(p + 1);
 5bc:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5bf:	83 c4 04             	add    $0x4,%esp
 5c2:	5b                   	pop    %ebx
 5c3:	5d                   	pop    %ebp
 5c4:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5c5:	8b 10                	mov    (%eax),%edx
 5c7:	89 11                	mov    %edx,(%ecx)
 5c9:	eb eb                	jmp    5b6 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5cb:	89 c1                	mov    %eax,%ecx
 5cd:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5cf:	8b 50 04             	mov    0x4(%eax),%edx
 5d2:	39 da                	cmp    %ebx,%edx
 5d4:	73 d1                	jae    5a7 <malloc+0x46>
    if(p == freep)
 5d6:	39 05 a4 08 00 00    	cmp    %eax,0x8a4
 5dc:	75 ed                	jne    5cb <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5de:	89 d8                	mov    %ebx,%eax
 5e0:	e8 2c ff ff ff       	call   511 <morecore>
 5e5:	85 c0                	test   %eax,%eax
 5e7:	75 e2                	jne    5cb <malloc+0x6a>
        return 0;
 5e9:	b8 00 00 00 00       	mov    $0x0,%eax
 5ee:	eb cf                	jmp    5bf <malloc+0x5e>
