
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
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

  if(argc < 2){
  19:	83 fe 01             	cmp    $0x1,%esi
  1c:	7e 07                	jle    25 <main+0x25>
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  1e:	bb 01 00 00 00       	mov    $0x1,%ebx
  23:	eb 2d                	jmp    52 <main+0x52>
    printf(2, "usage: kill pid...\n");
  25:	83 ec 08             	sub    $0x8,%esp
  28:	68 e4 05 00 00       	push   $0x5e4
  2d:	6a 02                	push   $0x2
  2f:	e8 f6 02 00 00       	call   32a <printf>
    exit();
  34:	e8 af 01 00 00       	call   1e8 <exit>
    kill(atoi(argv[i]));
  39:	83 ec 0c             	sub    $0xc,%esp
  3c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  3f:	e8 46 01 00 00       	call   18a <atoi>
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 cc 01 00 00       	call   218 <kill>
  for(i=1; i<argc; i++)
  4c:	83 c3 01             	add    $0x1,%ebx
  4f:	83 c4 10             	add    $0x10,%esp
  52:	39 f3                	cmp    %esi,%ebx
  54:	7c e3                	jl     39 <main+0x39>
  exit();
  56:	e8 8d 01 00 00       	call   1e8 <exit>

0000005b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  5b:	55                   	push   %ebp
  5c:	89 e5                	mov    %esp,%ebp
  5e:	53                   	push   %ebx
  5f:	8b 45 08             	mov    0x8(%ebp),%eax
  62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  65:	89 c2                	mov    %eax,%edx
  67:	0f b6 19             	movzbl (%ecx),%ebx
  6a:	88 1a                	mov    %bl,(%edx)
  6c:	8d 52 01             	lea    0x1(%edx),%edx
  6f:	8d 49 01             	lea    0x1(%ecx),%ecx
  72:	84 db                	test   %bl,%bl
  74:	75 f1                	jne    67 <strcpy+0xc>
    ;
  return os;
}
  76:	5b                   	pop    %ebx
  77:	5d                   	pop    %ebp
  78:	c3                   	ret    

00000079 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  82:	eb 06                	jmp    8a <strcmp+0x11>
    p++, q++;
  84:	83 c1 01             	add    $0x1,%ecx
  87:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  8a:	0f b6 01             	movzbl (%ecx),%eax
  8d:	84 c0                	test   %al,%al
  8f:	74 04                	je     95 <strcmp+0x1c>
  91:	3a 02                	cmp    (%edx),%al
  93:	74 ef                	je     84 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  95:	0f b6 c0             	movzbl %al,%eax
  98:	0f b6 12             	movzbl (%edx),%edx
  9b:	29 d0                	sub    %edx,%eax
}
  9d:	5d                   	pop    %ebp
  9e:	c3                   	ret    

0000009f <strlen>:

uint
strlen(const char *s)
{
  9f:	55                   	push   %ebp
  a0:	89 e5                	mov    %esp,%ebp
  a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  a5:	ba 00 00 00 00       	mov    $0x0,%edx
  aa:	eb 03                	jmp    af <strlen+0x10>
  ac:	83 c2 01             	add    $0x1,%edx
  af:	89 d0                	mov    %edx,%eax
  b1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  b5:	75 f5                	jne    ac <strlen+0xd>
    ;
  return n;
}
  b7:	5d                   	pop    %ebp
  b8:	c3                   	ret    

000000b9 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b9:	55                   	push   %ebp
  ba:	89 e5                	mov    %esp,%ebp
  bc:	57                   	push   %edi
  bd:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  c0:	89 d7                	mov    %edx,%edi
  c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  c8:	fc                   	cld    
  c9:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  cb:	89 d0                	mov    %edx,%eax
  cd:	5f                   	pop    %edi
  ce:	5d                   	pop    %ebp
  cf:	c3                   	ret    

000000d0 <strchr>:

char*
strchr(const char *s, char c)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  da:	0f b6 10             	movzbl (%eax),%edx
  dd:	84 d2                	test   %dl,%dl
  df:	74 09                	je     ea <strchr+0x1a>
    if(*s == c)
  e1:	38 ca                	cmp    %cl,%dl
  e3:	74 0a                	je     ef <strchr+0x1f>
  for(; *s; s++)
  e5:	83 c0 01             	add    $0x1,%eax
  e8:	eb f0                	jmp    da <strchr+0xa>
      return (char*)s;
  return 0;
  ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  ef:	5d                   	pop    %ebp
  f0:	c3                   	ret    

000000f1 <gets>:

char*
gets(char *buf, int max)
{
  f1:	55                   	push   %ebp
  f2:	89 e5                	mov    %esp,%ebp
  f4:	57                   	push   %edi
  f5:	56                   	push   %esi
  f6:	53                   	push   %ebx
  f7:	83 ec 1c             	sub    $0x1c,%esp
  fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fd:	bb 00 00 00 00       	mov    $0x0,%ebx
 102:	8d 73 01             	lea    0x1(%ebx),%esi
 105:	3b 75 0c             	cmp    0xc(%ebp),%esi
 108:	7d 2e                	jge    138 <gets+0x47>
    cc = read(0, &c, 1);
 10a:	83 ec 04             	sub    $0x4,%esp
 10d:	6a 01                	push   $0x1
 10f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 112:	50                   	push   %eax
 113:	6a 00                	push   $0x0
 115:	e8 e6 00 00 00       	call   200 <read>
    if(cc < 1)
 11a:	83 c4 10             	add    $0x10,%esp
 11d:	85 c0                	test   %eax,%eax
 11f:	7e 17                	jle    138 <gets+0x47>
      break;
    buf[i++] = c;
 121:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 125:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 128:	3c 0a                	cmp    $0xa,%al
 12a:	0f 94 c2             	sete   %dl
 12d:	3c 0d                	cmp    $0xd,%al
 12f:	0f 94 c0             	sete   %al
    buf[i++] = c;
 132:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 134:	08 c2                	or     %al,%dl
 136:	74 ca                	je     102 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 138:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 13c:	89 f8                	mov    %edi,%eax
 13e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 141:	5b                   	pop    %ebx
 142:	5e                   	pop    %esi
 143:	5f                   	pop    %edi
 144:	5d                   	pop    %ebp
 145:	c3                   	ret    

00000146 <stat>:

int
stat(const char *n, struct stat *st)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
 149:	56                   	push   %esi
 14a:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 14b:	83 ec 08             	sub    $0x8,%esp
 14e:	6a 00                	push   $0x0
 150:	ff 75 08             	pushl  0x8(%ebp)
 153:	e8 d0 00 00 00       	call   228 <open>
  if(fd < 0)
 158:	83 c4 10             	add    $0x10,%esp
 15b:	85 c0                	test   %eax,%eax
 15d:	78 24                	js     183 <stat+0x3d>
 15f:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 161:	83 ec 08             	sub    $0x8,%esp
 164:	ff 75 0c             	pushl  0xc(%ebp)
 167:	50                   	push   %eax
 168:	e8 d3 00 00 00       	call   240 <fstat>
 16d:	89 c6                	mov    %eax,%esi
  close(fd);
 16f:	89 1c 24             	mov    %ebx,(%esp)
 172:	e8 99 00 00 00       	call   210 <close>
  return r;
 177:	83 c4 10             	add    $0x10,%esp
}
 17a:	89 f0                	mov    %esi,%eax
 17c:	8d 65 f8             	lea    -0x8(%ebp),%esp
 17f:	5b                   	pop    %ebx
 180:	5e                   	pop    %esi
 181:	5d                   	pop    %ebp
 182:	c3                   	ret    
    return -1;
 183:	be ff ff ff ff       	mov    $0xffffffff,%esi
 188:	eb f0                	jmp    17a <stat+0x34>

0000018a <atoi>:

int
atoi(const char *s)
{
 18a:	55                   	push   %ebp
 18b:	89 e5                	mov    %esp,%ebp
 18d:	53                   	push   %ebx
 18e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 191:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 196:	eb 10                	jmp    1a8 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 198:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 19b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 19e:	83 c1 01             	add    $0x1,%ecx
 1a1:	0f be d2             	movsbl %dl,%edx
 1a4:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1a8:	0f b6 11             	movzbl (%ecx),%edx
 1ab:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1ae:	80 fb 09             	cmp    $0x9,%bl
 1b1:	76 e5                	jbe    198 <atoi+0xe>
  return n;
}
 1b3:	5b                   	pop    %ebx
 1b4:	5d                   	pop    %ebp
 1b5:	c3                   	ret    

000001b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b6:	55                   	push   %ebp
 1b7:	89 e5                	mov    %esp,%ebp
 1b9:	56                   	push   %esi
 1ba:	53                   	push   %ebx
 1bb:	8b 45 08             	mov    0x8(%ebp),%eax
 1be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1c1:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1c4:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1c6:	eb 0d                	jmp    1d5 <memmove+0x1f>
    *dst++ = *src++;
 1c8:	0f b6 13             	movzbl (%ebx),%edx
 1cb:	88 11                	mov    %dl,(%ecx)
 1cd:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1d0:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1d3:	89 f2                	mov    %esi,%edx
 1d5:	8d 72 ff             	lea    -0x1(%edx),%esi
 1d8:	85 d2                	test   %edx,%edx
 1da:	7f ec                	jg     1c8 <memmove+0x12>
  return vdst;
}
 1dc:	5b                   	pop    %ebx
 1dd:	5e                   	pop    %esi
 1de:	5d                   	pop    %ebp
 1df:	c3                   	ret    

000001e0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e0:	b8 01 00 00 00       	mov    $0x1,%eax
 1e5:	cd 40                	int    $0x40
 1e7:	c3                   	ret    

000001e8 <exit>:
SYSCALL(exit)
 1e8:	b8 02 00 00 00       	mov    $0x2,%eax
 1ed:	cd 40                	int    $0x40
 1ef:	c3                   	ret    

000001f0 <wait>:
SYSCALL(wait)
 1f0:	b8 03 00 00 00       	mov    $0x3,%eax
 1f5:	cd 40                	int    $0x40
 1f7:	c3                   	ret    

000001f8 <pipe>:
SYSCALL(pipe)
 1f8:	b8 04 00 00 00       	mov    $0x4,%eax
 1fd:	cd 40                	int    $0x40
 1ff:	c3                   	ret    

00000200 <read>:
SYSCALL(read)
 200:	b8 05 00 00 00       	mov    $0x5,%eax
 205:	cd 40                	int    $0x40
 207:	c3                   	ret    

00000208 <write>:
SYSCALL(write)
 208:	b8 10 00 00 00       	mov    $0x10,%eax
 20d:	cd 40                	int    $0x40
 20f:	c3                   	ret    

00000210 <close>:
SYSCALL(close)
 210:	b8 15 00 00 00       	mov    $0x15,%eax
 215:	cd 40                	int    $0x40
 217:	c3                   	ret    

00000218 <kill>:
SYSCALL(kill)
 218:	b8 06 00 00 00       	mov    $0x6,%eax
 21d:	cd 40                	int    $0x40
 21f:	c3                   	ret    

00000220 <exec>:
SYSCALL(exec)
 220:	b8 07 00 00 00       	mov    $0x7,%eax
 225:	cd 40                	int    $0x40
 227:	c3                   	ret    

00000228 <open>:
SYSCALL(open)
 228:	b8 0f 00 00 00       	mov    $0xf,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <mknod>:
SYSCALL(mknod)
 230:	b8 11 00 00 00       	mov    $0x11,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <unlink>:
SYSCALL(unlink)
 238:	b8 12 00 00 00       	mov    $0x12,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <fstat>:
SYSCALL(fstat)
 240:	b8 08 00 00 00       	mov    $0x8,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <link>:
SYSCALL(link)
 248:	b8 13 00 00 00       	mov    $0x13,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <mkdir>:
SYSCALL(mkdir)
 250:	b8 14 00 00 00       	mov    $0x14,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <chdir>:
SYSCALL(chdir)
 258:	b8 09 00 00 00       	mov    $0x9,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <dup>:
SYSCALL(dup)
 260:	b8 0a 00 00 00       	mov    $0xa,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <getpid>:
SYSCALL(getpid)
 268:	b8 0b 00 00 00       	mov    $0xb,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <sbrk>:
SYSCALL(sbrk)
 270:	b8 0c 00 00 00       	mov    $0xc,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <sleep>:
SYSCALL(sleep)
 278:	b8 0d 00 00 00       	mov    $0xd,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <uptime>:
SYSCALL(uptime)
 280:	b8 0e 00 00 00       	mov    $0xe,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <dump_physmem>:
SYSCALL(dump_physmem)
 288:	b8 16 00 00 00       	mov    $0x16,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	83 ec 1c             	sub    $0x1c,%esp
 296:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 299:	6a 01                	push   $0x1
 29b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 29e:	52                   	push   %edx
 29f:	50                   	push   %eax
 2a0:	e8 63 ff ff ff       	call   208 <write>
}
 2a5:	83 c4 10             	add    $0x10,%esp
 2a8:	c9                   	leave  
 2a9:	c3                   	ret    

000002aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2aa:	55                   	push   %ebp
 2ab:	89 e5                	mov    %esp,%ebp
 2ad:	57                   	push   %edi
 2ae:	56                   	push   %esi
 2af:	53                   	push   %ebx
 2b0:	83 ec 2c             	sub    $0x2c,%esp
 2b3:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2b5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2b9:	0f 95 c3             	setne  %bl
 2bc:	89 d0                	mov    %edx,%eax
 2be:	c1 e8 1f             	shr    $0x1f,%eax
 2c1:	84 c3                	test   %al,%bl
 2c3:	74 10                	je     2d5 <printint+0x2b>
    neg = 1;
    x = -xx;
 2c5:	f7 da                	neg    %edx
    neg = 1;
 2c7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2ce:	be 00 00 00 00       	mov    $0x0,%esi
 2d3:	eb 0b                	jmp    2e0 <printint+0x36>
  neg = 0;
 2d5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2dc:	eb f0                	jmp    2ce <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2de:	89 c6                	mov    %eax,%esi
 2e0:	89 d0                	mov    %edx,%eax
 2e2:	ba 00 00 00 00       	mov    $0x0,%edx
 2e7:	f7 f1                	div    %ecx
 2e9:	89 c3                	mov    %eax,%ebx
 2eb:	8d 46 01             	lea    0x1(%esi),%eax
 2ee:	0f b6 92 00 06 00 00 	movzbl 0x600(%edx),%edx
 2f5:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2f9:	89 da                	mov    %ebx,%edx
 2fb:	85 db                	test   %ebx,%ebx
 2fd:	75 df                	jne    2de <printint+0x34>
 2ff:	89 c3                	mov    %eax,%ebx
  if(neg)
 301:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 305:	74 16                	je     31d <printint+0x73>
    buf[i++] = '-';
 307:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 30c:	8d 5e 02             	lea    0x2(%esi),%ebx
 30f:	eb 0c                	jmp    31d <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 311:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 316:	89 f8                	mov    %edi,%eax
 318:	e8 73 ff ff ff       	call   290 <putc>
  while(--i >= 0)
 31d:	83 eb 01             	sub    $0x1,%ebx
 320:	79 ef                	jns    311 <printint+0x67>
}
 322:	83 c4 2c             	add    $0x2c,%esp
 325:	5b                   	pop    %ebx
 326:	5e                   	pop    %esi
 327:	5f                   	pop    %edi
 328:	5d                   	pop    %ebp
 329:	c3                   	ret    

0000032a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 32a:	55                   	push   %ebp
 32b:	89 e5                	mov    %esp,%ebp
 32d:	57                   	push   %edi
 32e:	56                   	push   %esi
 32f:	53                   	push   %ebx
 330:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 333:	8d 45 10             	lea    0x10(%ebp),%eax
 336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 339:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 33e:	bb 00 00 00 00       	mov    $0x0,%ebx
 343:	eb 14                	jmp    359 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 345:	89 fa                	mov    %edi,%edx
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	e8 41 ff ff ff       	call   290 <putc>
 34f:	eb 05                	jmp    356 <printf+0x2c>
      }
    } else if(state == '%'){
 351:	83 fe 25             	cmp    $0x25,%esi
 354:	74 25                	je     37b <printf+0x51>
  for(i = 0; fmt[i]; i++){
 356:	83 c3 01             	add    $0x1,%ebx
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 360:	84 c0                	test   %al,%al
 362:	0f 84 23 01 00 00    	je     48b <printf+0x161>
    c = fmt[i] & 0xff;
 368:	0f be f8             	movsbl %al,%edi
 36b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 36e:	85 f6                	test   %esi,%esi
 370:	75 df                	jne    351 <printf+0x27>
      if(c == '%'){
 372:	83 f8 25             	cmp    $0x25,%eax
 375:	75 ce                	jne    345 <printf+0x1b>
        state = '%';
 377:	89 c6                	mov    %eax,%esi
 379:	eb db                	jmp    356 <printf+0x2c>
      if(c == 'd'){
 37b:	83 f8 64             	cmp    $0x64,%eax
 37e:	74 49                	je     3c9 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 380:	83 f8 78             	cmp    $0x78,%eax
 383:	0f 94 c1             	sete   %cl
 386:	83 f8 70             	cmp    $0x70,%eax
 389:	0f 94 c2             	sete   %dl
 38c:	08 d1                	or     %dl,%cl
 38e:	75 63                	jne    3f3 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 390:	83 f8 73             	cmp    $0x73,%eax
 393:	0f 84 84 00 00 00    	je     41d <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 399:	83 f8 63             	cmp    $0x63,%eax
 39c:	0f 84 b7 00 00 00    	je     459 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3a2:	83 f8 25             	cmp    $0x25,%eax
 3a5:	0f 84 cc 00 00 00    	je     477 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3ab:	ba 25 00 00 00       	mov    $0x25,%edx
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	e8 d8 fe ff ff       	call   290 <putc>
        putc(fd, c);
 3b8:	89 fa                	mov    %edi,%edx
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	e8 ce fe ff ff       	call   290 <putc>
      }
      state = 0;
 3c2:	be 00 00 00 00       	mov    $0x0,%esi
 3c7:	eb 8d                	jmp    356 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3cc:	8b 17                	mov    (%edi),%edx
 3ce:	83 ec 0c             	sub    $0xc,%esp
 3d1:	6a 01                	push   $0x1
 3d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	e8 ca fe ff ff       	call   2aa <printint>
        ap++;
 3e0:	83 c7 04             	add    $0x4,%edi
 3e3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3e6:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3e9:	be 00 00 00 00       	mov    $0x0,%esi
 3ee:	e9 63 ff ff ff       	jmp    356 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f6:	8b 17                	mov    (%edi),%edx
 3f8:	83 ec 0c             	sub    $0xc,%esp
 3fb:	6a 00                	push   $0x0
 3fd:	b9 10 00 00 00       	mov    $0x10,%ecx
 402:	8b 45 08             	mov    0x8(%ebp),%eax
 405:	e8 a0 fe ff ff       	call   2aa <printint>
        ap++;
 40a:	83 c7 04             	add    $0x4,%edi
 40d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 410:	83 c4 10             	add    $0x10,%esp
      state = 0;
 413:	be 00 00 00 00       	mov    $0x0,%esi
 418:	e9 39 ff ff ff       	jmp    356 <printf+0x2c>
        s = (char*)*ap;
 41d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 420:	8b 30                	mov    (%eax),%esi
        ap++;
 422:	83 c0 04             	add    $0x4,%eax
 425:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 428:	85 f6                	test   %esi,%esi
 42a:	75 28                	jne    454 <printf+0x12a>
          s = "(null)";
 42c:	be f8 05 00 00       	mov    $0x5f8,%esi
 431:	8b 7d 08             	mov    0x8(%ebp),%edi
 434:	eb 0d                	jmp    443 <printf+0x119>
          putc(fd, *s);
 436:	0f be d2             	movsbl %dl,%edx
 439:	89 f8                	mov    %edi,%eax
 43b:	e8 50 fe ff ff       	call   290 <putc>
          s++;
 440:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 443:	0f b6 16             	movzbl (%esi),%edx
 446:	84 d2                	test   %dl,%dl
 448:	75 ec                	jne    436 <printf+0x10c>
      state = 0;
 44a:	be 00 00 00 00       	mov    $0x0,%esi
 44f:	e9 02 ff ff ff       	jmp    356 <printf+0x2c>
 454:	8b 7d 08             	mov    0x8(%ebp),%edi
 457:	eb ea                	jmp    443 <printf+0x119>
        putc(fd, *ap);
 459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 45c:	0f be 17             	movsbl (%edi),%edx
 45f:	8b 45 08             	mov    0x8(%ebp),%eax
 462:	e8 29 fe ff ff       	call   290 <putc>
        ap++;
 467:	83 c7 04             	add    $0x4,%edi
 46a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 46d:	be 00 00 00 00       	mov    $0x0,%esi
 472:	e9 df fe ff ff       	jmp    356 <printf+0x2c>
        putc(fd, c);
 477:	89 fa                	mov    %edi,%edx
 479:	8b 45 08             	mov    0x8(%ebp),%eax
 47c:	e8 0f fe ff ff       	call   290 <putc>
      state = 0;
 481:	be 00 00 00 00       	mov    $0x0,%esi
 486:	e9 cb fe ff ff       	jmp    356 <printf+0x2c>
    }
  }
}
 48b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 48e:	5b                   	pop    %ebx
 48f:	5e                   	pop    %esi
 490:	5f                   	pop    %edi
 491:	5d                   	pop    %ebp
 492:	c3                   	ret    

00000493 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 493:	55                   	push   %ebp
 494:	89 e5                	mov    %esp,%ebp
 496:	57                   	push   %edi
 497:	56                   	push   %esi
 498:	53                   	push   %ebx
 499:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 49c:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 49f:	a1 a4 08 00 00       	mov    0x8a4,%eax
 4a4:	eb 02                	jmp    4a8 <free+0x15>
 4a6:	89 d0                	mov    %edx,%eax
 4a8:	39 c8                	cmp    %ecx,%eax
 4aa:	73 04                	jae    4b0 <free+0x1d>
 4ac:	39 08                	cmp    %ecx,(%eax)
 4ae:	77 12                	ja     4c2 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4b0:	8b 10                	mov    (%eax),%edx
 4b2:	39 c2                	cmp    %eax,%edx
 4b4:	77 f0                	ja     4a6 <free+0x13>
 4b6:	39 c8                	cmp    %ecx,%eax
 4b8:	72 08                	jb     4c2 <free+0x2f>
 4ba:	39 ca                	cmp    %ecx,%edx
 4bc:	77 04                	ja     4c2 <free+0x2f>
 4be:	89 d0                	mov    %edx,%eax
 4c0:	eb e6                	jmp    4a8 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4c2:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4c5:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4c8:	8b 10                	mov    (%eax),%edx
 4ca:	39 d7                	cmp    %edx,%edi
 4cc:	74 19                	je     4e7 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4ce:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4d1:	8b 50 04             	mov    0x4(%eax),%edx
 4d4:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4d7:	39 ce                	cmp    %ecx,%esi
 4d9:	74 1b                	je     4f6 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4db:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4dd:	a3 a4 08 00 00       	mov    %eax,0x8a4
}
 4e2:	5b                   	pop    %ebx
 4e3:	5e                   	pop    %esi
 4e4:	5f                   	pop    %edi
 4e5:	5d                   	pop    %ebp
 4e6:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4e7:	03 72 04             	add    0x4(%edx),%esi
 4ea:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4ed:	8b 10                	mov    (%eax),%edx
 4ef:	8b 12                	mov    (%edx),%edx
 4f1:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4f4:	eb db                	jmp    4d1 <free+0x3e>
    p->s.size += bp->s.size;
 4f6:	03 53 fc             	add    -0x4(%ebx),%edx
 4f9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4fc:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4ff:	89 10                	mov    %edx,(%eax)
 501:	eb da                	jmp    4dd <free+0x4a>

00000503 <morecore>:

static Header*
morecore(uint nu)
{
 503:	55                   	push   %ebp
 504:	89 e5                	mov    %esp,%ebp
 506:	53                   	push   %ebx
 507:	83 ec 04             	sub    $0x4,%esp
 50a:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 50c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 511:	77 05                	ja     518 <morecore+0x15>
    nu = 4096;
 513:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 518:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 51f:	83 ec 0c             	sub    $0xc,%esp
 522:	50                   	push   %eax
 523:	e8 48 fd ff ff       	call   270 <sbrk>
  if(p == (char*)-1)
 528:	83 c4 10             	add    $0x10,%esp
 52b:	83 f8 ff             	cmp    $0xffffffff,%eax
 52e:	74 1c                	je     54c <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 530:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 533:	83 c0 08             	add    $0x8,%eax
 536:	83 ec 0c             	sub    $0xc,%esp
 539:	50                   	push   %eax
 53a:	e8 54 ff ff ff       	call   493 <free>
  return freep;
 53f:	a1 a4 08 00 00       	mov    0x8a4,%eax
 544:	83 c4 10             	add    $0x10,%esp
}
 547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 54a:	c9                   	leave  
 54b:	c3                   	ret    
    return 0;
 54c:	b8 00 00 00 00       	mov    $0x0,%eax
 551:	eb f4                	jmp    547 <morecore+0x44>

00000553 <malloc>:

void*
malloc(uint nbytes)
{
 553:	55                   	push   %ebp
 554:	89 e5                	mov    %esp,%ebp
 556:	53                   	push   %ebx
 557:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	8d 58 07             	lea    0x7(%eax),%ebx
 560:	c1 eb 03             	shr    $0x3,%ebx
 563:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 566:	8b 0d a4 08 00 00    	mov    0x8a4,%ecx
 56c:	85 c9                	test   %ecx,%ecx
 56e:	74 04                	je     574 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 570:	8b 01                	mov    (%ecx),%eax
 572:	eb 4d                	jmp    5c1 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 574:	c7 05 a4 08 00 00 a8 	movl   $0x8a8,0x8a4
 57b:	08 00 00 
 57e:	c7 05 a8 08 00 00 a8 	movl   $0x8a8,0x8a8
 585:	08 00 00 
    base.s.size = 0;
 588:	c7 05 ac 08 00 00 00 	movl   $0x0,0x8ac
 58f:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 592:	b9 a8 08 00 00       	mov    $0x8a8,%ecx
 597:	eb d7                	jmp    570 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 599:	39 da                	cmp    %ebx,%edx
 59b:	74 1a                	je     5b7 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 59d:	29 da                	sub    %ebx,%edx
 59f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5a2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5a5:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5a8:	89 0d a4 08 00 00    	mov    %ecx,0x8a4
      return (void*)(p + 1);
 5ae:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5b1:	83 c4 04             	add    $0x4,%esp
 5b4:	5b                   	pop    %ebx
 5b5:	5d                   	pop    %ebp
 5b6:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5b7:	8b 10                	mov    (%eax),%edx
 5b9:	89 11                	mov    %edx,(%ecx)
 5bb:	eb eb                	jmp    5a8 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5bd:	89 c1                	mov    %eax,%ecx
 5bf:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5c1:	8b 50 04             	mov    0x4(%eax),%edx
 5c4:	39 da                	cmp    %ebx,%edx
 5c6:	73 d1                	jae    599 <malloc+0x46>
    if(p == freep)
 5c8:	39 05 a4 08 00 00    	cmp    %eax,0x8a4
 5ce:	75 ed                	jne    5bd <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5d0:	89 d8                	mov    %ebx,%eax
 5d2:	e8 2c ff ff ff       	call   503 <morecore>
 5d7:	85 c0                	test   %eax,%eax
 5d9:	75 e2                	jne    5bd <malloc+0x6a>
        return 0;
 5db:	b8 00 00 00 00       	mov    $0x0,%eax
 5e0:	eb cf                	jmp    5b1 <malloc+0x5e>
