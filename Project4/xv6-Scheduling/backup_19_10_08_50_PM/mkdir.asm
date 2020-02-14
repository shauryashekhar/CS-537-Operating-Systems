
_mkdir:     file format elf32-i386


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
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 01                	mov    (%ecx),%eax
  16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  19:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  if(argc < 2){
  1c:	83 f8 01             	cmp    $0x1,%eax
  1f:	7e 23                	jle    44 <main+0x44>
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  21:	bb 01 00 00 00       	mov    $0x1,%ebx
  26:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  29:	7d 41                	jge    6c <main+0x6c>
    if(mkdir(argv[i]) < 0){
  2b:	8d 34 9f             	lea    (%edi,%ebx,4),%esi
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	ff 36                	pushl  (%esi)
  33:	e8 2e 02 00 00       	call   266 <mkdir>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	85 c0                	test   %eax,%eax
  3d:	78 19                	js     58 <main+0x58>
  for(i = 1; i < argc; i++){
  3f:	83 c3 01             	add    $0x1,%ebx
  42:	eb e2                	jmp    26 <main+0x26>
    printf(2, "Usage: mkdir files...\n");
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 10 06 00 00       	push   $0x610
  4c:	6a 02                	push   $0x2
  4e:	e8 05 03 00 00       	call   358 <printf>
    exit();
  53:	e8 a6 01 00 00       	call   1fe <exit>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  58:	83 ec 04             	sub    $0x4,%esp
  5b:	ff 36                	pushl  (%esi)
  5d:	68 27 06 00 00       	push   $0x627
  62:	6a 02                	push   $0x2
  64:	e8 ef 02 00 00       	call   358 <printf>
      break;
  69:	83 c4 10             	add    $0x10,%esp
    }
  }

  exit();
  6c:	e8 8d 01 00 00       	call   1fe <exit>

00000071 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  71:	55                   	push   %ebp
  72:	89 e5                	mov    %esp,%ebp
  74:	53                   	push   %ebx
  75:	8b 45 08             	mov    0x8(%ebp),%eax
  78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7b:	89 c2                	mov    %eax,%edx
  7d:	0f b6 19             	movzbl (%ecx),%ebx
  80:	88 1a                	mov    %bl,(%edx)
  82:	8d 52 01             	lea    0x1(%edx),%edx
  85:	8d 49 01             	lea    0x1(%ecx),%ecx
  88:	84 db                	test   %bl,%bl
  8a:	75 f1                	jne    7d <strcpy+0xc>
    ;
  return os;
}
  8c:	5b                   	pop    %ebx
  8d:	5d                   	pop    %ebp
  8e:	c3                   	ret    

0000008f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8f:	55                   	push   %ebp
  90:	89 e5                	mov    %esp,%ebp
  92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  95:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  98:	eb 06                	jmp    a0 <strcmp+0x11>
    p++, q++;
  9a:	83 c1 01             	add    $0x1,%ecx
  9d:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  a0:	0f b6 01             	movzbl (%ecx),%eax
  a3:	84 c0                	test   %al,%al
  a5:	74 04                	je     ab <strcmp+0x1c>
  a7:	3a 02                	cmp    (%edx),%al
  a9:	74 ef                	je     9a <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  ab:	0f b6 c0             	movzbl %al,%eax
  ae:	0f b6 12             	movzbl (%edx),%edx
  b1:	29 d0                	sub    %edx,%eax
}
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strlen>:

uint
strlen(const char *s)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  bb:	ba 00 00 00 00       	mov    $0x0,%edx
  c0:	eb 03                	jmp    c5 <strlen+0x10>
  c2:	83 c2 01             	add    $0x1,%edx
  c5:	89 d0                	mov    %edx,%eax
  c7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  cb:	75 f5                	jne    c2 <strlen+0xd>
    ;
  return n;
}
  cd:	5d                   	pop    %ebp
  ce:	c3                   	ret    

000000cf <memset>:

void*
memset(void *dst, int c, uint n)
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  d2:	57                   	push   %edi
  d3:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  d6:	89 d7                	mov    %edx,%edi
  d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  db:	8b 45 0c             	mov    0xc(%ebp),%eax
  de:	fc                   	cld    
  df:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  e1:	89 d0                	mov    %edx,%eax
  e3:	5f                   	pop    %edi
  e4:	5d                   	pop    %ebp
  e5:	c3                   	ret    

000000e6 <strchr>:

char*
strchr(const char *s, char c)
{
  e6:	55                   	push   %ebp
  e7:	89 e5                	mov    %esp,%ebp
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  f0:	0f b6 10             	movzbl (%eax),%edx
  f3:	84 d2                	test   %dl,%dl
  f5:	74 09                	je     100 <strchr+0x1a>
    if(*s == c)
  f7:	38 ca                	cmp    %cl,%dl
  f9:	74 0a                	je     105 <strchr+0x1f>
  for(; *s; s++)
  fb:	83 c0 01             	add    $0x1,%eax
  fe:	eb f0                	jmp    f0 <strchr+0xa>
      return (char*)s;
  return 0;
 100:	b8 00 00 00 00       	mov    $0x0,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <gets>:

char*
gets(char *buf, int max)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	57                   	push   %edi
 10b:	56                   	push   %esi
 10c:	53                   	push   %ebx
 10d:	83 ec 1c             	sub    $0x1c,%esp
 110:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 113:	bb 00 00 00 00       	mov    $0x0,%ebx
 118:	8d 73 01             	lea    0x1(%ebx),%esi
 11b:	3b 75 0c             	cmp    0xc(%ebp),%esi
 11e:	7d 2e                	jge    14e <gets+0x47>
    cc = read(0, &c, 1);
 120:	83 ec 04             	sub    $0x4,%esp
 123:	6a 01                	push   $0x1
 125:	8d 45 e7             	lea    -0x19(%ebp),%eax
 128:	50                   	push   %eax
 129:	6a 00                	push   $0x0
 12b:	e8 e6 00 00 00       	call   216 <read>
    if(cc < 1)
 130:	83 c4 10             	add    $0x10,%esp
 133:	85 c0                	test   %eax,%eax
 135:	7e 17                	jle    14e <gets+0x47>
      break;
    buf[i++] = c;
 137:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 13b:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 13e:	3c 0a                	cmp    $0xa,%al
 140:	0f 94 c2             	sete   %dl
 143:	3c 0d                	cmp    $0xd,%al
 145:	0f 94 c0             	sete   %al
    buf[i++] = c;
 148:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 14a:	08 c2                	or     %al,%dl
 14c:	74 ca                	je     118 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 14e:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 152:	89 f8                	mov    %edi,%eax
 154:	8d 65 f4             	lea    -0xc(%ebp),%esp
 157:	5b                   	pop    %ebx
 158:	5e                   	pop    %esi
 159:	5f                   	pop    %edi
 15a:	5d                   	pop    %ebp
 15b:	c3                   	ret    

0000015c <stat>:

int
stat(const char *n, struct stat *st)
{
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
 15f:	56                   	push   %esi
 160:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 161:	83 ec 08             	sub    $0x8,%esp
 164:	6a 00                	push   $0x0
 166:	ff 75 08             	pushl  0x8(%ebp)
 169:	e8 d0 00 00 00       	call   23e <open>
  if(fd < 0)
 16e:	83 c4 10             	add    $0x10,%esp
 171:	85 c0                	test   %eax,%eax
 173:	78 24                	js     199 <stat+0x3d>
 175:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 177:	83 ec 08             	sub    $0x8,%esp
 17a:	ff 75 0c             	pushl  0xc(%ebp)
 17d:	50                   	push   %eax
 17e:	e8 d3 00 00 00       	call   256 <fstat>
 183:	89 c6                	mov    %eax,%esi
  close(fd);
 185:	89 1c 24             	mov    %ebx,(%esp)
 188:	e8 99 00 00 00       	call   226 <close>
  return r;
 18d:	83 c4 10             	add    $0x10,%esp
}
 190:	89 f0                	mov    %esi,%eax
 192:	8d 65 f8             	lea    -0x8(%ebp),%esp
 195:	5b                   	pop    %ebx
 196:	5e                   	pop    %esi
 197:	5d                   	pop    %ebp
 198:	c3                   	ret    
    return -1;
 199:	be ff ff ff ff       	mov    $0xffffffff,%esi
 19e:	eb f0                	jmp    190 <stat+0x34>

000001a0 <atoi>:

int
atoi(const char *s)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	53                   	push   %ebx
 1a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1a7:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1ac:	eb 10                	jmp    1be <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1ae:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1b1:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1b4:	83 c1 01             	add    $0x1,%ecx
 1b7:	0f be d2             	movsbl %dl,%edx
 1ba:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1be:	0f b6 11             	movzbl (%ecx),%edx
 1c1:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1c4:	80 fb 09             	cmp    $0x9,%bl
 1c7:	76 e5                	jbe    1ae <atoi+0xe>
  return n;
}
 1c9:	5b                   	pop    %ebx
 1ca:	5d                   	pop    %ebp
 1cb:	c3                   	ret    

000001cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
 1cf:	56                   	push   %esi
 1d0:	53                   	push   %ebx
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1d7:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1da:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1dc:	eb 0d                	jmp    1eb <memmove+0x1f>
    *dst++ = *src++;
 1de:	0f b6 13             	movzbl (%ebx),%edx
 1e1:	88 11                	mov    %dl,(%ecx)
 1e3:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1e6:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1e9:	89 f2                	mov    %esi,%edx
 1eb:	8d 72 ff             	lea    -0x1(%edx),%esi
 1ee:	85 d2                	test   %edx,%edx
 1f0:	7f ec                	jg     1de <memmove+0x12>
  return vdst;
}
 1f2:	5b                   	pop    %ebx
 1f3:	5e                   	pop    %esi
 1f4:	5d                   	pop    %ebp
 1f5:	c3                   	ret    

000001f6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1f6:	b8 01 00 00 00       	mov    $0x1,%eax
 1fb:	cd 40                	int    $0x40
 1fd:	c3                   	ret    

000001fe <exit>:
SYSCALL(exit)
 1fe:	b8 02 00 00 00       	mov    $0x2,%eax
 203:	cd 40                	int    $0x40
 205:	c3                   	ret    

00000206 <wait>:
SYSCALL(wait)
 206:	b8 03 00 00 00       	mov    $0x3,%eax
 20b:	cd 40                	int    $0x40
 20d:	c3                   	ret    

0000020e <pipe>:
SYSCALL(pipe)
 20e:	b8 04 00 00 00       	mov    $0x4,%eax
 213:	cd 40                	int    $0x40
 215:	c3                   	ret    

00000216 <read>:
SYSCALL(read)
 216:	b8 05 00 00 00       	mov    $0x5,%eax
 21b:	cd 40                	int    $0x40
 21d:	c3                   	ret    

0000021e <write>:
SYSCALL(write)
 21e:	b8 10 00 00 00       	mov    $0x10,%eax
 223:	cd 40                	int    $0x40
 225:	c3                   	ret    

00000226 <close>:
SYSCALL(close)
 226:	b8 15 00 00 00       	mov    $0x15,%eax
 22b:	cd 40                	int    $0x40
 22d:	c3                   	ret    

0000022e <kill>:
SYSCALL(kill)
 22e:	b8 06 00 00 00       	mov    $0x6,%eax
 233:	cd 40                	int    $0x40
 235:	c3                   	ret    

00000236 <exec>:
SYSCALL(exec)
 236:	b8 07 00 00 00       	mov    $0x7,%eax
 23b:	cd 40                	int    $0x40
 23d:	c3                   	ret    

0000023e <open>:
SYSCALL(open)
 23e:	b8 0f 00 00 00       	mov    $0xf,%eax
 243:	cd 40                	int    $0x40
 245:	c3                   	ret    

00000246 <mknod>:
SYSCALL(mknod)
 246:	b8 11 00 00 00       	mov    $0x11,%eax
 24b:	cd 40                	int    $0x40
 24d:	c3                   	ret    

0000024e <unlink>:
SYSCALL(unlink)
 24e:	b8 12 00 00 00       	mov    $0x12,%eax
 253:	cd 40                	int    $0x40
 255:	c3                   	ret    

00000256 <fstat>:
SYSCALL(fstat)
 256:	b8 08 00 00 00       	mov    $0x8,%eax
 25b:	cd 40                	int    $0x40
 25d:	c3                   	ret    

0000025e <link>:
SYSCALL(link)
 25e:	b8 13 00 00 00       	mov    $0x13,%eax
 263:	cd 40                	int    $0x40
 265:	c3                   	ret    

00000266 <mkdir>:
SYSCALL(mkdir)
 266:	b8 14 00 00 00       	mov    $0x14,%eax
 26b:	cd 40                	int    $0x40
 26d:	c3                   	ret    

0000026e <chdir>:
SYSCALL(chdir)
 26e:	b8 09 00 00 00       	mov    $0x9,%eax
 273:	cd 40                	int    $0x40
 275:	c3                   	ret    

00000276 <dup>:
SYSCALL(dup)
 276:	b8 0a 00 00 00       	mov    $0xa,%eax
 27b:	cd 40                	int    $0x40
 27d:	c3                   	ret    

0000027e <getpid>:
SYSCALL(getpid)
 27e:	b8 0b 00 00 00       	mov    $0xb,%eax
 283:	cd 40                	int    $0x40
 285:	c3                   	ret    

00000286 <sbrk>:
SYSCALL(sbrk)
 286:	b8 0c 00 00 00       	mov    $0xc,%eax
 28b:	cd 40                	int    $0x40
 28d:	c3                   	ret    

0000028e <sleep>:
SYSCALL(sleep)
 28e:	b8 0d 00 00 00       	mov    $0xd,%eax
 293:	cd 40                	int    $0x40
 295:	c3                   	ret    

00000296 <uptime>:
SYSCALL(uptime)
 296:	b8 0e 00 00 00       	mov    $0xe,%eax
 29b:	cd 40                	int    $0x40
 29d:	c3                   	ret    

0000029e <setpri>:
SYSCALL(setpri)
 29e:	b8 16 00 00 00       	mov    $0x16,%eax
 2a3:	cd 40                	int    $0x40
 2a5:	c3                   	ret    

000002a6 <getpri>:
SYSCALL(getpri)
 2a6:	b8 17 00 00 00       	mov    $0x17,%eax
 2ab:	cd 40                	int    $0x40
 2ad:	c3                   	ret    

000002ae <getpinfo>:
SYSCALL(getpinfo)
 2ae:	b8 18 00 00 00       	mov    $0x18,%eax
 2b3:	cd 40                	int    $0x40
 2b5:	c3                   	ret    

000002b6 <fork2>:
SYSCALL(fork2)
 2b6:	b8 19 00 00 00       	mov    $0x19,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
 2c1:	83 ec 1c             	sub    $0x1c,%esp
 2c4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c7:	6a 01                	push   $0x1
 2c9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2cc:	52                   	push   %edx
 2cd:	50                   	push   %eax
 2ce:	e8 4b ff ff ff       	call   21e <write>
}
 2d3:	83 c4 10             	add    $0x10,%esp
 2d6:	c9                   	leave  
 2d7:	c3                   	ret    

000002d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
 2db:	57                   	push   %edi
 2dc:	56                   	push   %esi
 2dd:	53                   	push   %ebx
 2de:	83 ec 2c             	sub    $0x2c,%esp
 2e1:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e7:	0f 95 c3             	setne  %bl
 2ea:	89 d0                	mov    %edx,%eax
 2ec:	c1 e8 1f             	shr    $0x1f,%eax
 2ef:	84 c3                	test   %al,%bl
 2f1:	74 10                	je     303 <printint+0x2b>
    neg = 1;
    x = -xx;
 2f3:	f7 da                	neg    %edx
    neg = 1;
 2f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2fc:	be 00 00 00 00       	mov    $0x0,%esi
 301:	eb 0b                	jmp    30e <printint+0x36>
  neg = 0;
 303:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 30a:	eb f0                	jmp    2fc <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 30c:	89 c6                	mov    %eax,%esi
 30e:	89 d0                	mov    %edx,%eax
 310:	ba 00 00 00 00       	mov    $0x0,%edx
 315:	f7 f1                	div    %ecx
 317:	89 c3                	mov    %eax,%ebx
 319:	8d 46 01             	lea    0x1(%esi),%eax
 31c:	0f b6 92 4c 06 00 00 	movzbl 0x64c(%edx),%edx
 323:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 327:	89 da                	mov    %ebx,%edx
 329:	85 db                	test   %ebx,%ebx
 32b:	75 df                	jne    30c <printint+0x34>
 32d:	89 c3                	mov    %eax,%ebx
  if(neg)
 32f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 333:	74 16                	je     34b <printint+0x73>
    buf[i++] = '-';
 335:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 33a:	8d 5e 02             	lea    0x2(%esi),%ebx
 33d:	eb 0c                	jmp    34b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 33f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 344:	89 f8                	mov    %edi,%eax
 346:	e8 73 ff ff ff       	call   2be <putc>
  while(--i >= 0)
 34b:	83 eb 01             	sub    $0x1,%ebx
 34e:	79 ef                	jns    33f <printint+0x67>
}
 350:	83 c4 2c             	add    $0x2c,%esp
 353:	5b                   	pop    %ebx
 354:	5e                   	pop    %esi
 355:	5f                   	pop    %edi
 356:	5d                   	pop    %ebp
 357:	c3                   	ret    

00000358 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	57                   	push   %edi
 35c:	56                   	push   %esi
 35d:	53                   	push   %ebx
 35e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 361:	8d 45 10             	lea    0x10(%ebp),%eax
 364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 367:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 36c:	bb 00 00 00 00       	mov    $0x0,%ebx
 371:	eb 14                	jmp    387 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 373:	89 fa                	mov    %edi,%edx
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	e8 41 ff ff ff       	call   2be <putc>
 37d:	eb 05                	jmp    384 <printf+0x2c>
      }
    } else if(state == '%'){
 37f:	83 fe 25             	cmp    $0x25,%esi
 382:	74 25                	je     3a9 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 384:	83 c3 01             	add    $0x1,%ebx
 387:	8b 45 0c             	mov    0xc(%ebp),%eax
 38a:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 38e:	84 c0                	test   %al,%al
 390:	0f 84 23 01 00 00    	je     4b9 <printf+0x161>
    c = fmt[i] & 0xff;
 396:	0f be f8             	movsbl %al,%edi
 399:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 39c:	85 f6                	test   %esi,%esi
 39e:	75 df                	jne    37f <printf+0x27>
      if(c == '%'){
 3a0:	83 f8 25             	cmp    $0x25,%eax
 3a3:	75 ce                	jne    373 <printf+0x1b>
        state = '%';
 3a5:	89 c6                	mov    %eax,%esi
 3a7:	eb db                	jmp    384 <printf+0x2c>
      if(c == 'd'){
 3a9:	83 f8 64             	cmp    $0x64,%eax
 3ac:	74 49                	je     3f7 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3ae:	83 f8 78             	cmp    $0x78,%eax
 3b1:	0f 94 c1             	sete   %cl
 3b4:	83 f8 70             	cmp    $0x70,%eax
 3b7:	0f 94 c2             	sete   %dl
 3ba:	08 d1                	or     %dl,%cl
 3bc:	75 63                	jne    421 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3be:	83 f8 73             	cmp    $0x73,%eax
 3c1:	0f 84 84 00 00 00    	je     44b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c7:	83 f8 63             	cmp    $0x63,%eax
 3ca:	0f 84 b7 00 00 00    	je     487 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3d0:	83 f8 25             	cmp    $0x25,%eax
 3d3:	0f 84 cc 00 00 00    	je     4a5 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3d9:	ba 25 00 00 00       	mov    $0x25,%edx
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
 3e1:	e8 d8 fe ff ff       	call   2be <putc>
        putc(fd, c);
 3e6:	89 fa                	mov    %edi,%edx
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
 3eb:	e8 ce fe ff ff       	call   2be <putc>
      }
      state = 0;
 3f0:	be 00 00 00 00       	mov    $0x0,%esi
 3f5:	eb 8d                	jmp    384 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3fa:	8b 17                	mov    (%edi),%edx
 3fc:	83 ec 0c             	sub    $0xc,%esp
 3ff:	6a 01                	push   $0x1
 401:	b9 0a 00 00 00       	mov    $0xa,%ecx
 406:	8b 45 08             	mov    0x8(%ebp),%eax
 409:	e8 ca fe ff ff       	call   2d8 <printint>
        ap++;
 40e:	83 c7 04             	add    $0x4,%edi
 411:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 414:	83 c4 10             	add    $0x10,%esp
      state = 0;
 417:	be 00 00 00 00       	mov    $0x0,%esi
 41c:	e9 63 ff ff ff       	jmp    384 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 424:	8b 17                	mov    (%edi),%edx
 426:	83 ec 0c             	sub    $0xc,%esp
 429:	6a 00                	push   $0x0
 42b:	b9 10 00 00 00       	mov    $0x10,%ecx
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	e8 a0 fe ff ff       	call   2d8 <printint>
        ap++;
 438:	83 c7 04             	add    $0x4,%edi
 43b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 43e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 441:	be 00 00 00 00       	mov    $0x0,%esi
 446:	e9 39 ff ff ff       	jmp    384 <printf+0x2c>
        s = (char*)*ap;
 44b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44e:	8b 30                	mov    (%eax),%esi
        ap++;
 450:	83 c0 04             	add    $0x4,%eax
 453:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 456:	85 f6                	test   %esi,%esi
 458:	75 28                	jne    482 <printf+0x12a>
          s = "(null)";
 45a:	be 43 06 00 00       	mov    $0x643,%esi
 45f:	8b 7d 08             	mov    0x8(%ebp),%edi
 462:	eb 0d                	jmp    471 <printf+0x119>
          putc(fd, *s);
 464:	0f be d2             	movsbl %dl,%edx
 467:	89 f8                	mov    %edi,%eax
 469:	e8 50 fe ff ff       	call   2be <putc>
          s++;
 46e:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 471:	0f b6 16             	movzbl (%esi),%edx
 474:	84 d2                	test   %dl,%dl
 476:	75 ec                	jne    464 <printf+0x10c>
      state = 0;
 478:	be 00 00 00 00       	mov    $0x0,%esi
 47d:	e9 02 ff ff ff       	jmp    384 <printf+0x2c>
 482:	8b 7d 08             	mov    0x8(%ebp),%edi
 485:	eb ea                	jmp    471 <printf+0x119>
        putc(fd, *ap);
 487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 48a:	0f be 17             	movsbl (%edi),%edx
 48d:	8b 45 08             	mov    0x8(%ebp),%eax
 490:	e8 29 fe ff ff       	call   2be <putc>
        ap++;
 495:	83 c7 04             	add    $0x4,%edi
 498:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 49b:	be 00 00 00 00       	mov    $0x0,%esi
 4a0:	e9 df fe ff ff       	jmp    384 <printf+0x2c>
        putc(fd, c);
 4a5:	89 fa                	mov    %edi,%edx
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	e8 0f fe ff ff       	call   2be <putc>
      state = 0;
 4af:	be 00 00 00 00       	mov    $0x0,%esi
 4b4:	e9 cb fe ff ff       	jmp    384 <printf+0x2c>
    }
  }
}
 4b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4bc:	5b                   	pop    %ebx
 4bd:	5e                   	pop    %esi
 4be:	5f                   	pop    %edi
 4bf:	5d                   	pop    %ebp
 4c0:	c3                   	ret    

000004c1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4c1:	55                   	push   %ebp
 4c2:	89 e5                	mov    %esp,%ebp
 4c4:	57                   	push   %edi
 4c5:	56                   	push   %esi
 4c6:	53                   	push   %ebx
 4c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4ca:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4cd:	a1 f0 08 00 00       	mov    0x8f0,%eax
 4d2:	eb 02                	jmp    4d6 <free+0x15>
 4d4:	89 d0                	mov    %edx,%eax
 4d6:	39 c8                	cmp    %ecx,%eax
 4d8:	73 04                	jae    4de <free+0x1d>
 4da:	39 08                	cmp    %ecx,(%eax)
 4dc:	77 12                	ja     4f0 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4de:	8b 10                	mov    (%eax),%edx
 4e0:	39 c2                	cmp    %eax,%edx
 4e2:	77 f0                	ja     4d4 <free+0x13>
 4e4:	39 c8                	cmp    %ecx,%eax
 4e6:	72 08                	jb     4f0 <free+0x2f>
 4e8:	39 ca                	cmp    %ecx,%edx
 4ea:	77 04                	ja     4f0 <free+0x2f>
 4ec:	89 d0                	mov    %edx,%eax
 4ee:	eb e6                	jmp    4d6 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4f0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4f3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4f6:	8b 10                	mov    (%eax),%edx
 4f8:	39 d7                	cmp    %edx,%edi
 4fa:	74 19                	je     515 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4fc:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4ff:	8b 50 04             	mov    0x4(%eax),%edx
 502:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 505:	39 ce                	cmp    %ecx,%esi
 507:	74 1b                	je     524 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 509:	89 08                	mov    %ecx,(%eax)
  freep = p;
 50b:	a3 f0 08 00 00       	mov    %eax,0x8f0
}
 510:	5b                   	pop    %ebx
 511:	5e                   	pop    %esi
 512:	5f                   	pop    %edi
 513:	5d                   	pop    %ebp
 514:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 515:	03 72 04             	add    0x4(%edx),%esi
 518:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 51b:	8b 10                	mov    (%eax),%edx
 51d:	8b 12                	mov    (%edx),%edx
 51f:	89 53 f8             	mov    %edx,-0x8(%ebx)
 522:	eb db                	jmp    4ff <free+0x3e>
    p->s.size += bp->s.size;
 524:	03 53 fc             	add    -0x4(%ebx),%edx
 527:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 52a:	8b 53 f8             	mov    -0x8(%ebx),%edx
 52d:	89 10                	mov    %edx,(%eax)
 52f:	eb da                	jmp    50b <free+0x4a>

00000531 <morecore>:

static Header*
morecore(uint nu)
{
 531:	55                   	push   %ebp
 532:	89 e5                	mov    %esp,%ebp
 534:	53                   	push   %ebx
 535:	83 ec 04             	sub    $0x4,%esp
 538:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 53a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 53f:	77 05                	ja     546 <morecore+0x15>
    nu = 4096;
 541:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 546:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 54d:	83 ec 0c             	sub    $0xc,%esp
 550:	50                   	push   %eax
 551:	e8 30 fd ff ff       	call   286 <sbrk>
  if(p == (char*)-1)
 556:	83 c4 10             	add    $0x10,%esp
 559:	83 f8 ff             	cmp    $0xffffffff,%eax
 55c:	74 1c                	je     57a <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 561:	83 c0 08             	add    $0x8,%eax
 564:	83 ec 0c             	sub    $0xc,%esp
 567:	50                   	push   %eax
 568:	e8 54 ff ff ff       	call   4c1 <free>
  return freep;
 56d:	a1 f0 08 00 00       	mov    0x8f0,%eax
 572:	83 c4 10             	add    $0x10,%esp
}
 575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 578:	c9                   	leave  
 579:	c3                   	ret    
    return 0;
 57a:	b8 00 00 00 00       	mov    $0x0,%eax
 57f:	eb f4                	jmp    575 <morecore+0x44>

00000581 <malloc>:

void*
malloc(uint nbytes)
{
 581:	55                   	push   %ebp
 582:	89 e5                	mov    %esp,%ebp
 584:	53                   	push   %ebx
 585:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 588:	8b 45 08             	mov    0x8(%ebp),%eax
 58b:	8d 58 07             	lea    0x7(%eax),%ebx
 58e:	c1 eb 03             	shr    $0x3,%ebx
 591:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 594:	8b 0d f0 08 00 00    	mov    0x8f0,%ecx
 59a:	85 c9                	test   %ecx,%ecx
 59c:	74 04                	je     5a2 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 59e:	8b 01                	mov    (%ecx),%eax
 5a0:	eb 4d                	jmp    5ef <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5a2:	c7 05 f0 08 00 00 f4 	movl   $0x8f4,0x8f0
 5a9:	08 00 00 
 5ac:	c7 05 f4 08 00 00 f4 	movl   $0x8f4,0x8f4
 5b3:	08 00 00 
    base.s.size = 0;
 5b6:	c7 05 f8 08 00 00 00 	movl   $0x0,0x8f8
 5bd:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5c0:	b9 f4 08 00 00       	mov    $0x8f4,%ecx
 5c5:	eb d7                	jmp    59e <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c7:	39 da                	cmp    %ebx,%edx
 5c9:	74 1a                	je     5e5 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5cb:	29 da                	sub    %ebx,%edx
 5cd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5d0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5d3:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5d6:	89 0d f0 08 00 00    	mov    %ecx,0x8f0
      return (void*)(p + 1);
 5dc:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5df:	83 c4 04             	add    $0x4,%esp
 5e2:	5b                   	pop    %ebx
 5e3:	5d                   	pop    %ebp
 5e4:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5e5:	8b 10                	mov    (%eax),%edx
 5e7:	89 11                	mov    %edx,(%ecx)
 5e9:	eb eb                	jmp    5d6 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5eb:	89 c1                	mov    %eax,%ecx
 5ed:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ef:	8b 50 04             	mov    0x4(%eax),%edx
 5f2:	39 da                	cmp    %ebx,%edx
 5f4:	73 d1                	jae    5c7 <malloc+0x46>
    if(p == freep)
 5f6:	39 05 f0 08 00 00    	cmp    %eax,0x8f0
 5fc:	75 ed                	jne    5eb <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5fe:	89 d8                	mov    %ebx,%eax
 600:	e8 2c ff ff ff       	call   531 <morecore>
 605:	85 c0                	test   %eax,%eax
 607:	75 e2                	jne    5eb <malloc+0x6a>
        return 0;
 609:	b8 00 00 00 00       	mov    $0x0,%eax
 60e:	eb cf                	jmp    5df <malloc+0x5e>
