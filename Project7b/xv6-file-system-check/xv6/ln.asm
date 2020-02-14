
_ln:     file format elf32-i386


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
   f:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  12:	83 39 03             	cmpl   $0x3,(%ecx)
  15:	74 14                	je     2b <main+0x2b>
    printf(2, "Usage: ln old new\n");
  17:	83 ec 08             	sub    $0x8,%esp
  1a:	68 dc 05 00 00       	push   $0x5dc
  1f:	6a 02                	push   $0x2
  21:	e8 fd 02 00 00       	call   323 <printf>
    exit();
  26:	e8 be 01 00 00       	call   1e9 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	ff 73 08             	pushl  0x8(%ebx)
  31:	ff 73 04             	pushl  0x4(%ebx)
  34:	e8 10 02 00 00       	call   249 <link>
  39:	83 c4 10             	add    $0x10,%esp
  3c:	85 c0                	test   %eax,%eax
  3e:	78 05                	js     45 <main+0x45>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  40:	e8 a4 01 00 00       	call   1e9 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  45:	ff 73 08             	pushl  0x8(%ebx)
  48:	ff 73 04             	pushl  0x4(%ebx)
  4b:	68 ef 05 00 00       	push   $0x5ef
  50:	6a 02                	push   $0x2
  52:	e8 cc 02 00 00       	call   323 <printf>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	eb e4                	jmp    40 <main+0x40>

0000005c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  5c:	55                   	push   %ebp
  5d:	89 e5                	mov    %esp,%ebp
  5f:	53                   	push   %ebx
  60:	8b 45 08             	mov    0x8(%ebp),%eax
  63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	89 c2                	mov    %eax,%edx
  68:	0f b6 19             	movzbl (%ecx),%ebx
  6b:	88 1a                	mov    %bl,(%edx)
  6d:	8d 52 01             	lea    0x1(%edx),%edx
  70:	8d 49 01             	lea    0x1(%ecx),%ecx
  73:	84 db                	test   %bl,%bl
  75:	75 f1                	jne    68 <strcpy+0xc>
    ;
  return os;
}
  77:	5b                   	pop    %ebx
  78:	5d                   	pop    %ebp
  79:	c3                   	ret    

0000007a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7a:	55                   	push   %ebp
  7b:	89 e5                	mov    %esp,%ebp
  7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  83:	eb 06                	jmp    8b <strcmp+0x11>
    p++, q++;
  85:	83 c1 01             	add    $0x1,%ecx
  88:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  8b:	0f b6 01             	movzbl (%ecx),%eax
  8e:	84 c0                	test   %al,%al
  90:	74 04                	je     96 <strcmp+0x1c>
  92:	3a 02                	cmp    (%edx),%al
  94:	74 ef                	je     85 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  96:	0f b6 c0             	movzbl %al,%eax
  99:	0f b6 12             	movzbl (%edx),%edx
  9c:	29 d0                	sub    %edx,%eax
}
  9e:	5d                   	pop    %ebp
  9f:	c3                   	ret    

000000a0 <strlen>:

uint
strlen(const char *s)
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  a6:	ba 00 00 00 00       	mov    $0x0,%edx
  ab:	eb 03                	jmp    b0 <strlen+0x10>
  ad:	83 c2 01             	add    $0x1,%edx
  b0:	89 d0                	mov    %edx,%eax
  b2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  b6:	75 f5                	jne    ad <strlen+0xd>
    ;
  return n;
}
  b8:	5d                   	pop    %ebp
  b9:	c3                   	ret    

000000ba <memset>:

void*
memset(void *dst, int c, uint n)
{
  ba:	55                   	push   %ebp
  bb:	89 e5                	mov    %esp,%ebp
  bd:	57                   	push   %edi
  be:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  c1:	89 d7                	mov    %edx,%edi
  c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  c9:	fc                   	cld    
  ca:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  cc:	89 d0                	mov    %edx,%eax
  ce:	5f                   	pop    %edi
  cf:	5d                   	pop    %ebp
  d0:	c3                   	ret    

000000d1 <strchr>:

char*
strchr(const char *s, char c)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  db:	0f b6 10             	movzbl (%eax),%edx
  de:	84 d2                	test   %dl,%dl
  e0:	74 09                	je     eb <strchr+0x1a>
    if(*s == c)
  e2:	38 ca                	cmp    %cl,%dl
  e4:	74 0a                	je     f0 <strchr+0x1f>
  for(; *s; s++)
  e6:	83 c0 01             	add    $0x1,%eax
  e9:	eb f0                	jmp    db <strchr+0xa>
      return (char*)s;
  return 0;
  eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  f0:	5d                   	pop    %ebp
  f1:	c3                   	ret    

000000f2 <gets>:

char*
gets(char *buf, int max)
{
  f2:	55                   	push   %ebp
  f3:	89 e5                	mov    %esp,%ebp
  f5:	57                   	push   %edi
  f6:	56                   	push   %esi
  f7:	53                   	push   %ebx
  f8:	83 ec 1c             	sub    $0x1c,%esp
  fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fe:	bb 00 00 00 00       	mov    $0x0,%ebx
 103:	8d 73 01             	lea    0x1(%ebx),%esi
 106:	3b 75 0c             	cmp    0xc(%ebp),%esi
 109:	7d 2e                	jge    139 <gets+0x47>
    cc = read(0, &c, 1);
 10b:	83 ec 04             	sub    $0x4,%esp
 10e:	6a 01                	push   $0x1
 110:	8d 45 e7             	lea    -0x19(%ebp),%eax
 113:	50                   	push   %eax
 114:	6a 00                	push   $0x0
 116:	e8 e6 00 00 00       	call   201 <read>
    if(cc < 1)
 11b:	83 c4 10             	add    $0x10,%esp
 11e:	85 c0                	test   %eax,%eax
 120:	7e 17                	jle    139 <gets+0x47>
      break;
    buf[i++] = c;
 122:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 126:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 129:	3c 0a                	cmp    $0xa,%al
 12b:	0f 94 c2             	sete   %dl
 12e:	3c 0d                	cmp    $0xd,%al
 130:	0f 94 c0             	sete   %al
    buf[i++] = c;
 133:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 135:	08 c2                	or     %al,%dl
 137:	74 ca                	je     103 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 139:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 13d:	89 f8                	mov    %edi,%eax
 13f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 142:	5b                   	pop    %ebx
 143:	5e                   	pop    %esi
 144:	5f                   	pop    %edi
 145:	5d                   	pop    %ebp
 146:	c3                   	ret    

00000147 <stat>:

int
stat(const char *n, struct stat *st)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	56                   	push   %esi
 14b:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 14c:	83 ec 08             	sub    $0x8,%esp
 14f:	6a 00                	push   $0x0
 151:	ff 75 08             	pushl  0x8(%ebp)
 154:	e8 d0 00 00 00       	call   229 <open>
  if(fd < 0)
 159:	83 c4 10             	add    $0x10,%esp
 15c:	85 c0                	test   %eax,%eax
 15e:	78 24                	js     184 <stat+0x3d>
 160:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 162:	83 ec 08             	sub    $0x8,%esp
 165:	ff 75 0c             	pushl  0xc(%ebp)
 168:	50                   	push   %eax
 169:	e8 d3 00 00 00       	call   241 <fstat>
 16e:	89 c6                	mov    %eax,%esi
  close(fd);
 170:	89 1c 24             	mov    %ebx,(%esp)
 173:	e8 99 00 00 00       	call   211 <close>
  return r;
 178:	83 c4 10             	add    $0x10,%esp
}
 17b:	89 f0                	mov    %esi,%eax
 17d:	8d 65 f8             	lea    -0x8(%ebp),%esp
 180:	5b                   	pop    %ebx
 181:	5e                   	pop    %esi
 182:	5d                   	pop    %ebp
 183:	c3                   	ret    
    return -1;
 184:	be ff ff ff ff       	mov    $0xffffffff,%esi
 189:	eb f0                	jmp    17b <stat+0x34>

0000018b <atoi>:

int
atoi(const char *s)
{
 18b:	55                   	push   %ebp
 18c:	89 e5                	mov    %esp,%ebp
 18e:	53                   	push   %ebx
 18f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 192:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 197:	eb 10                	jmp    1a9 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 199:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 19c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 19f:	83 c1 01             	add    $0x1,%ecx
 1a2:	0f be d2             	movsbl %dl,%edx
 1a5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1a9:	0f b6 11             	movzbl (%ecx),%edx
 1ac:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1af:	80 fb 09             	cmp    $0x9,%bl
 1b2:	76 e5                	jbe    199 <atoi+0xe>
  return n;
}
 1b4:	5b                   	pop    %ebx
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    

000001b7 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	56                   	push   %esi
 1bb:	53                   	push   %ebx
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1c2:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1c5:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1c7:	eb 0d                	jmp    1d6 <memmove+0x1f>
    *dst++ = *src++;
 1c9:	0f b6 13             	movzbl (%ebx),%edx
 1cc:	88 11                	mov    %dl,(%ecx)
 1ce:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1d1:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1d4:	89 f2                	mov    %esi,%edx
 1d6:	8d 72 ff             	lea    -0x1(%edx),%esi
 1d9:	85 d2                	test   %edx,%edx
 1db:	7f ec                	jg     1c9 <memmove+0x12>
  return vdst;
}
 1dd:	5b                   	pop    %ebx
 1de:	5e                   	pop    %esi
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e1:	b8 01 00 00 00       	mov    $0x1,%eax
 1e6:	cd 40                	int    $0x40
 1e8:	c3                   	ret    

000001e9 <exit>:
SYSCALL(exit)
 1e9:	b8 02 00 00 00       	mov    $0x2,%eax
 1ee:	cd 40                	int    $0x40
 1f0:	c3                   	ret    

000001f1 <wait>:
SYSCALL(wait)
 1f1:	b8 03 00 00 00       	mov    $0x3,%eax
 1f6:	cd 40                	int    $0x40
 1f8:	c3                   	ret    

000001f9 <pipe>:
SYSCALL(pipe)
 1f9:	b8 04 00 00 00       	mov    $0x4,%eax
 1fe:	cd 40                	int    $0x40
 200:	c3                   	ret    

00000201 <read>:
SYSCALL(read)
 201:	b8 05 00 00 00       	mov    $0x5,%eax
 206:	cd 40                	int    $0x40
 208:	c3                   	ret    

00000209 <write>:
SYSCALL(write)
 209:	b8 10 00 00 00       	mov    $0x10,%eax
 20e:	cd 40                	int    $0x40
 210:	c3                   	ret    

00000211 <close>:
SYSCALL(close)
 211:	b8 15 00 00 00       	mov    $0x15,%eax
 216:	cd 40                	int    $0x40
 218:	c3                   	ret    

00000219 <kill>:
SYSCALL(kill)
 219:	b8 06 00 00 00       	mov    $0x6,%eax
 21e:	cd 40                	int    $0x40
 220:	c3                   	ret    

00000221 <exec>:
SYSCALL(exec)
 221:	b8 07 00 00 00       	mov    $0x7,%eax
 226:	cd 40                	int    $0x40
 228:	c3                   	ret    

00000229 <open>:
SYSCALL(open)
 229:	b8 0f 00 00 00       	mov    $0xf,%eax
 22e:	cd 40                	int    $0x40
 230:	c3                   	ret    

00000231 <mknod>:
SYSCALL(mknod)
 231:	b8 11 00 00 00       	mov    $0x11,%eax
 236:	cd 40                	int    $0x40
 238:	c3                   	ret    

00000239 <unlink>:
SYSCALL(unlink)
 239:	b8 12 00 00 00       	mov    $0x12,%eax
 23e:	cd 40                	int    $0x40
 240:	c3                   	ret    

00000241 <fstat>:
SYSCALL(fstat)
 241:	b8 08 00 00 00       	mov    $0x8,%eax
 246:	cd 40                	int    $0x40
 248:	c3                   	ret    

00000249 <link>:
SYSCALL(link)
 249:	b8 13 00 00 00       	mov    $0x13,%eax
 24e:	cd 40                	int    $0x40
 250:	c3                   	ret    

00000251 <mkdir>:
SYSCALL(mkdir)
 251:	b8 14 00 00 00       	mov    $0x14,%eax
 256:	cd 40                	int    $0x40
 258:	c3                   	ret    

00000259 <chdir>:
SYSCALL(chdir)
 259:	b8 09 00 00 00       	mov    $0x9,%eax
 25e:	cd 40                	int    $0x40
 260:	c3                   	ret    

00000261 <dup>:
SYSCALL(dup)
 261:	b8 0a 00 00 00       	mov    $0xa,%eax
 266:	cd 40                	int    $0x40
 268:	c3                   	ret    

00000269 <getpid>:
SYSCALL(getpid)
 269:	b8 0b 00 00 00       	mov    $0xb,%eax
 26e:	cd 40                	int    $0x40
 270:	c3                   	ret    

00000271 <sbrk>:
SYSCALL(sbrk)
 271:	b8 0c 00 00 00       	mov    $0xc,%eax
 276:	cd 40                	int    $0x40
 278:	c3                   	ret    

00000279 <sleep>:
SYSCALL(sleep)
 279:	b8 0d 00 00 00       	mov    $0xd,%eax
 27e:	cd 40                	int    $0x40
 280:	c3                   	ret    

00000281 <uptime>:
SYSCALL(uptime)
 281:	b8 0e 00 00 00       	mov    $0xe,%eax
 286:	cd 40                	int    $0x40
 288:	c3                   	ret    

00000289 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 1c             	sub    $0x1c,%esp
 28f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 292:	6a 01                	push   $0x1
 294:	8d 55 f4             	lea    -0xc(%ebp),%edx
 297:	52                   	push   %edx
 298:	50                   	push   %eax
 299:	e8 6b ff ff ff       	call   209 <write>
}
 29e:	83 c4 10             	add    $0x10,%esp
 2a1:	c9                   	leave  
 2a2:	c3                   	ret    

000002a3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	57                   	push   %edi
 2a7:	56                   	push   %esi
 2a8:	53                   	push   %ebx
 2a9:	83 ec 2c             	sub    $0x2c,%esp
 2ac:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2b2:	0f 95 c3             	setne  %bl
 2b5:	89 d0                	mov    %edx,%eax
 2b7:	c1 e8 1f             	shr    $0x1f,%eax
 2ba:	84 c3                	test   %al,%bl
 2bc:	74 10                	je     2ce <printint+0x2b>
    neg = 1;
    x = -xx;
 2be:	f7 da                	neg    %edx
    neg = 1;
 2c0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2c7:	be 00 00 00 00       	mov    $0x0,%esi
 2cc:	eb 0b                	jmp    2d9 <printint+0x36>
  neg = 0;
 2ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2d5:	eb f0                	jmp    2c7 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2d7:	89 c6                	mov    %eax,%esi
 2d9:	89 d0                	mov    %edx,%eax
 2db:	ba 00 00 00 00       	mov    $0x0,%edx
 2e0:	f7 f1                	div    %ecx
 2e2:	89 c3                	mov    %eax,%ebx
 2e4:	8d 46 01             	lea    0x1(%esi),%eax
 2e7:	0f b6 92 0c 06 00 00 	movzbl 0x60c(%edx),%edx
 2ee:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2f2:	89 da                	mov    %ebx,%edx
 2f4:	85 db                	test   %ebx,%ebx
 2f6:	75 df                	jne    2d7 <printint+0x34>
 2f8:	89 c3                	mov    %eax,%ebx
  if(neg)
 2fa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2fe:	74 16                	je     316 <printint+0x73>
    buf[i++] = '-';
 300:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 305:	8d 5e 02             	lea    0x2(%esi),%ebx
 308:	eb 0c                	jmp    316 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 30a:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 30f:	89 f8                	mov    %edi,%eax
 311:	e8 73 ff ff ff       	call   289 <putc>
  while(--i >= 0)
 316:	83 eb 01             	sub    $0x1,%ebx
 319:	79 ef                	jns    30a <printint+0x67>
}
 31b:	83 c4 2c             	add    $0x2c,%esp
 31e:	5b                   	pop    %ebx
 31f:	5e                   	pop    %esi
 320:	5f                   	pop    %edi
 321:	5d                   	pop    %ebp
 322:	c3                   	ret    

00000323 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 323:	55                   	push   %ebp
 324:	89 e5                	mov    %esp,%ebp
 326:	57                   	push   %edi
 327:	56                   	push   %esi
 328:	53                   	push   %ebx
 329:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 32c:	8d 45 10             	lea    0x10(%ebp),%eax
 32f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 332:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 337:	bb 00 00 00 00       	mov    $0x0,%ebx
 33c:	eb 14                	jmp    352 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 33e:	89 fa                	mov    %edi,%edx
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	e8 41 ff ff ff       	call   289 <putc>
 348:	eb 05                	jmp    34f <printf+0x2c>
      }
    } else if(state == '%'){
 34a:	83 fe 25             	cmp    $0x25,%esi
 34d:	74 25                	je     374 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 34f:	83 c3 01             	add    $0x1,%ebx
 352:	8b 45 0c             	mov    0xc(%ebp),%eax
 355:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 359:	84 c0                	test   %al,%al
 35b:	0f 84 23 01 00 00    	je     484 <printf+0x161>
    c = fmt[i] & 0xff;
 361:	0f be f8             	movsbl %al,%edi
 364:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 367:	85 f6                	test   %esi,%esi
 369:	75 df                	jne    34a <printf+0x27>
      if(c == '%'){
 36b:	83 f8 25             	cmp    $0x25,%eax
 36e:	75 ce                	jne    33e <printf+0x1b>
        state = '%';
 370:	89 c6                	mov    %eax,%esi
 372:	eb db                	jmp    34f <printf+0x2c>
      if(c == 'd'){
 374:	83 f8 64             	cmp    $0x64,%eax
 377:	74 49                	je     3c2 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 379:	83 f8 78             	cmp    $0x78,%eax
 37c:	0f 94 c1             	sete   %cl
 37f:	83 f8 70             	cmp    $0x70,%eax
 382:	0f 94 c2             	sete   %dl
 385:	08 d1                	or     %dl,%cl
 387:	75 63                	jne    3ec <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 389:	83 f8 73             	cmp    $0x73,%eax
 38c:	0f 84 84 00 00 00    	je     416 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 392:	83 f8 63             	cmp    $0x63,%eax
 395:	0f 84 b7 00 00 00    	je     452 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 39b:	83 f8 25             	cmp    $0x25,%eax
 39e:	0f 84 cc 00 00 00    	je     470 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3a4:	ba 25 00 00 00       	mov    $0x25,%edx
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	e8 d8 fe ff ff       	call   289 <putc>
        putc(fd, c);
 3b1:	89 fa                	mov    %edi,%edx
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	e8 ce fe ff ff       	call   289 <putc>
      }
      state = 0;
 3bb:	be 00 00 00 00       	mov    $0x0,%esi
 3c0:	eb 8d                	jmp    34f <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3c5:	8b 17                	mov    (%edi),%edx
 3c7:	83 ec 0c             	sub    $0xc,%esp
 3ca:	6a 01                	push   $0x1
 3cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	e8 ca fe ff ff       	call   2a3 <printint>
        ap++;
 3d9:	83 c7 04             	add    $0x4,%edi
 3dc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3df:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3e2:	be 00 00 00 00       	mov    $0x0,%esi
 3e7:	e9 63 ff ff ff       	jmp    34f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3ef:	8b 17                	mov    (%edi),%edx
 3f1:	83 ec 0c             	sub    $0xc,%esp
 3f4:	6a 00                	push   $0x0
 3f6:	b9 10 00 00 00       	mov    $0x10,%ecx
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	e8 a0 fe ff ff       	call   2a3 <printint>
        ap++;
 403:	83 c7 04             	add    $0x4,%edi
 406:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 409:	83 c4 10             	add    $0x10,%esp
      state = 0;
 40c:	be 00 00 00 00       	mov    $0x0,%esi
 411:	e9 39 ff ff ff       	jmp    34f <printf+0x2c>
        s = (char*)*ap;
 416:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 419:	8b 30                	mov    (%eax),%esi
        ap++;
 41b:	83 c0 04             	add    $0x4,%eax
 41e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 421:	85 f6                	test   %esi,%esi
 423:	75 28                	jne    44d <printf+0x12a>
          s = "(null)";
 425:	be 03 06 00 00       	mov    $0x603,%esi
 42a:	8b 7d 08             	mov    0x8(%ebp),%edi
 42d:	eb 0d                	jmp    43c <printf+0x119>
          putc(fd, *s);
 42f:	0f be d2             	movsbl %dl,%edx
 432:	89 f8                	mov    %edi,%eax
 434:	e8 50 fe ff ff       	call   289 <putc>
          s++;
 439:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 43c:	0f b6 16             	movzbl (%esi),%edx
 43f:	84 d2                	test   %dl,%dl
 441:	75 ec                	jne    42f <printf+0x10c>
      state = 0;
 443:	be 00 00 00 00       	mov    $0x0,%esi
 448:	e9 02 ff ff ff       	jmp    34f <printf+0x2c>
 44d:	8b 7d 08             	mov    0x8(%ebp),%edi
 450:	eb ea                	jmp    43c <printf+0x119>
        putc(fd, *ap);
 452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 455:	0f be 17             	movsbl (%edi),%edx
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	e8 29 fe ff ff       	call   289 <putc>
        ap++;
 460:	83 c7 04             	add    $0x4,%edi
 463:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 466:	be 00 00 00 00       	mov    $0x0,%esi
 46b:	e9 df fe ff ff       	jmp    34f <printf+0x2c>
        putc(fd, c);
 470:	89 fa                	mov    %edi,%edx
 472:	8b 45 08             	mov    0x8(%ebp),%eax
 475:	e8 0f fe ff ff       	call   289 <putc>
      state = 0;
 47a:	be 00 00 00 00       	mov    $0x0,%esi
 47f:	e9 cb fe ff ff       	jmp    34f <printf+0x2c>
    }
  }
}
 484:	8d 65 f4             	lea    -0xc(%ebp),%esp
 487:	5b                   	pop    %ebx
 488:	5e                   	pop    %esi
 489:	5f                   	pop    %edi
 48a:	5d                   	pop    %ebp
 48b:	c3                   	ret    

0000048c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 48c:	55                   	push   %ebp
 48d:	89 e5                	mov    %esp,%ebp
 48f:	57                   	push   %edi
 490:	56                   	push   %esi
 491:	53                   	push   %ebx
 492:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 495:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 498:	a1 a8 08 00 00       	mov    0x8a8,%eax
 49d:	eb 02                	jmp    4a1 <free+0x15>
 49f:	89 d0                	mov    %edx,%eax
 4a1:	39 c8                	cmp    %ecx,%eax
 4a3:	73 04                	jae    4a9 <free+0x1d>
 4a5:	39 08                	cmp    %ecx,(%eax)
 4a7:	77 12                	ja     4bb <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4a9:	8b 10                	mov    (%eax),%edx
 4ab:	39 c2                	cmp    %eax,%edx
 4ad:	77 f0                	ja     49f <free+0x13>
 4af:	39 c8                	cmp    %ecx,%eax
 4b1:	72 08                	jb     4bb <free+0x2f>
 4b3:	39 ca                	cmp    %ecx,%edx
 4b5:	77 04                	ja     4bb <free+0x2f>
 4b7:	89 d0                	mov    %edx,%eax
 4b9:	eb e6                	jmp    4a1 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4bb:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4be:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4c1:	8b 10                	mov    (%eax),%edx
 4c3:	39 d7                	cmp    %edx,%edi
 4c5:	74 19                	je     4e0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4c7:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4ca:	8b 50 04             	mov    0x4(%eax),%edx
 4cd:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4d0:	39 ce                	cmp    %ecx,%esi
 4d2:	74 1b                	je     4ef <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4d4:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4d6:	a3 a8 08 00 00       	mov    %eax,0x8a8
}
 4db:	5b                   	pop    %ebx
 4dc:	5e                   	pop    %esi
 4dd:	5f                   	pop    %edi
 4de:	5d                   	pop    %ebp
 4df:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4e0:	03 72 04             	add    0x4(%edx),%esi
 4e3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4e6:	8b 10                	mov    (%eax),%edx
 4e8:	8b 12                	mov    (%edx),%edx
 4ea:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4ed:	eb db                	jmp    4ca <free+0x3e>
    p->s.size += bp->s.size;
 4ef:	03 53 fc             	add    -0x4(%ebx),%edx
 4f2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4f5:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4f8:	89 10                	mov    %edx,(%eax)
 4fa:	eb da                	jmp    4d6 <free+0x4a>

000004fc <morecore>:

static Header*
morecore(uint nu)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	53                   	push   %ebx
 500:	83 ec 04             	sub    $0x4,%esp
 503:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 505:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 50a:	77 05                	ja     511 <morecore+0x15>
    nu = 4096;
 50c:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 511:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 518:	83 ec 0c             	sub    $0xc,%esp
 51b:	50                   	push   %eax
 51c:	e8 50 fd ff ff       	call   271 <sbrk>
  if(p == (char*)-1)
 521:	83 c4 10             	add    $0x10,%esp
 524:	83 f8 ff             	cmp    $0xffffffff,%eax
 527:	74 1c                	je     545 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 529:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 52c:	83 c0 08             	add    $0x8,%eax
 52f:	83 ec 0c             	sub    $0xc,%esp
 532:	50                   	push   %eax
 533:	e8 54 ff ff ff       	call   48c <free>
  return freep;
 538:	a1 a8 08 00 00       	mov    0x8a8,%eax
 53d:	83 c4 10             	add    $0x10,%esp
}
 540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 543:	c9                   	leave  
 544:	c3                   	ret    
    return 0;
 545:	b8 00 00 00 00       	mov    $0x0,%eax
 54a:	eb f4                	jmp    540 <morecore+0x44>

0000054c <malloc>:

void*
malloc(uint nbytes)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	53                   	push   %ebx
 550:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	8d 58 07             	lea    0x7(%eax),%ebx
 559:	c1 eb 03             	shr    $0x3,%ebx
 55c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 55f:	8b 0d a8 08 00 00    	mov    0x8a8,%ecx
 565:	85 c9                	test   %ecx,%ecx
 567:	74 04                	je     56d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 569:	8b 01                	mov    (%ecx),%eax
 56b:	eb 4d                	jmp    5ba <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 56d:	c7 05 a8 08 00 00 ac 	movl   $0x8ac,0x8a8
 574:	08 00 00 
 577:	c7 05 ac 08 00 00 ac 	movl   $0x8ac,0x8ac
 57e:	08 00 00 
    base.s.size = 0;
 581:	c7 05 b0 08 00 00 00 	movl   $0x0,0x8b0
 588:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 58b:	b9 ac 08 00 00       	mov    $0x8ac,%ecx
 590:	eb d7                	jmp    569 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 592:	39 da                	cmp    %ebx,%edx
 594:	74 1a                	je     5b0 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 596:	29 da                	sub    %ebx,%edx
 598:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 59b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 59e:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5a1:	89 0d a8 08 00 00    	mov    %ecx,0x8a8
      return (void*)(p + 1);
 5a7:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5aa:	83 c4 04             	add    $0x4,%esp
 5ad:	5b                   	pop    %ebx
 5ae:	5d                   	pop    %ebp
 5af:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5b0:	8b 10                	mov    (%eax),%edx
 5b2:	89 11                	mov    %edx,(%ecx)
 5b4:	eb eb                	jmp    5a1 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5b6:	89 c1                	mov    %eax,%ecx
 5b8:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ba:	8b 50 04             	mov    0x4(%eax),%edx
 5bd:	39 da                	cmp    %ebx,%edx
 5bf:	73 d1                	jae    592 <malloc+0x46>
    if(p == freep)
 5c1:	39 05 a8 08 00 00    	cmp    %eax,0x8a8
 5c7:	75 ed                	jne    5b6 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5c9:	89 d8                	mov    %ebx,%eax
 5cb:	e8 2c ff ff ff       	call   4fc <morecore>
 5d0:	85 c0                	test   %eax,%eax
 5d2:	75 e2                	jne    5b6 <malloc+0x6a>
        return 0;
 5d4:	b8 00 00 00 00       	mov    $0x0,%eax
 5d9:	eb cf                	jmp    5aa <malloc+0x5e>
