
_rm:     file format elf32-i386


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
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  21:	bb 01 00 00 00       	mov    $0x1,%ebx
  26:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  29:	7d 41                	jge    6c <main+0x6c>
    if(unlink(argv[i]) < 0){
  2b:	8d 34 9f             	lea    (%edi,%ebx,4),%esi
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	ff 36                	pushl  (%esi)
  33:	e8 16 02 00 00       	call   24e <unlink>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	85 c0                	test   %eax,%eax
  3d:	78 19                	js     58 <main+0x58>
  for(i = 1; i < argc; i++){
  3f:	83 c3 01             	add    $0x1,%ebx
  42:	eb e2                	jmp    26 <main+0x26>
    printf(2, "Usage: rm files...\n");
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 f8 05 00 00       	push   $0x5f8
  4c:	6a 02                	push   $0x2
  4e:	e8 ed 02 00 00       	call   340 <printf>
    exit();
  53:	e8 a6 01 00 00       	call   1fe <exit>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  58:	83 ec 04             	sub    $0x4,%esp
  5b:	ff 36                	pushl  (%esi)
  5d:	68 0c 06 00 00       	push   $0x60c
  62:	6a 02                	push   $0x2
  64:	e8 d7 02 00 00       	call   340 <printf>
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

0000029e <symlink>:
SYSCALL(symlink)
 29e:	b8 16 00 00 00       	mov    $0x16,%eax
 2a3:	cd 40                	int    $0x40
 2a5:	c3                   	ret    

000002a6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2a6:	55                   	push   %ebp
 2a7:	89 e5                	mov    %esp,%ebp
 2a9:	83 ec 1c             	sub    $0x1c,%esp
 2ac:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2af:	6a 01                	push   $0x1
 2b1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2b4:	52                   	push   %edx
 2b5:	50                   	push   %eax
 2b6:	e8 63 ff ff ff       	call   21e <write>
}
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	c9                   	leave  
 2bf:	c3                   	ret    

000002c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	57                   	push   %edi
 2c4:	56                   	push   %esi
 2c5:	53                   	push   %ebx
 2c6:	83 ec 2c             	sub    $0x2c,%esp
 2c9:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2cb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2cf:	0f 95 c3             	setne  %bl
 2d2:	89 d0                	mov    %edx,%eax
 2d4:	c1 e8 1f             	shr    $0x1f,%eax
 2d7:	84 c3                	test   %al,%bl
 2d9:	74 10                	je     2eb <printint+0x2b>
    neg = 1;
    x = -xx;
 2db:	f7 da                	neg    %edx
    neg = 1;
 2dd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2e4:	be 00 00 00 00       	mov    $0x0,%esi
 2e9:	eb 0b                	jmp    2f6 <printint+0x36>
  neg = 0;
 2eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2f2:	eb f0                	jmp    2e4 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2f4:	89 c6                	mov    %eax,%esi
 2f6:	89 d0                	mov    %edx,%eax
 2f8:	ba 00 00 00 00       	mov    $0x0,%edx
 2fd:	f7 f1                	div    %ecx
 2ff:	89 c3                	mov    %eax,%ebx
 301:	8d 46 01             	lea    0x1(%esi),%eax
 304:	0f b6 92 2c 06 00 00 	movzbl 0x62c(%edx),%edx
 30b:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 30f:	89 da                	mov    %ebx,%edx
 311:	85 db                	test   %ebx,%ebx
 313:	75 df                	jne    2f4 <printint+0x34>
 315:	89 c3                	mov    %eax,%ebx
  if(neg)
 317:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 31b:	74 16                	je     333 <printint+0x73>
    buf[i++] = '-';
 31d:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 322:	8d 5e 02             	lea    0x2(%esi),%ebx
 325:	eb 0c                	jmp    333 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 327:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 32c:	89 f8                	mov    %edi,%eax
 32e:	e8 73 ff ff ff       	call   2a6 <putc>
  while(--i >= 0)
 333:	83 eb 01             	sub    $0x1,%ebx
 336:	79 ef                	jns    327 <printint+0x67>
}
 338:	83 c4 2c             	add    $0x2c,%esp
 33b:	5b                   	pop    %ebx
 33c:	5e                   	pop    %esi
 33d:	5f                   	pop    %edi
 33e:	5d                   	pop    %ebp
 33f:	c3                   	ret    

00000340 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	57                   	push   %edi
 344:	56                   	push   %esi
 345:	53                   	push   %ebx
 346:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 349:	8d 45 10             	lea    0x10(%ebp),%eax
 34c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 34f:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 354:	bb 00 00 00 00       	mov    $0x0,%ebx
 359:	eb 14                	jmp    36f <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 35b:	89 fa                	mov    %edi,%edx
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	e8 41 ff ff ff       	call   2a6 <putc>
 365:	eb 05                	jmp    36c <printf+0x2c>
      }
    } else if(state == '%'){
 367:	83 fe 25             	cmp    $0x25,%esi
 36a:	74 25                	je     391 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 36c:	83 c3 01             	add    $0x1,%ebx
 36f:	8b 45 0c             	mov    0xc(%ebp),%eax
 372:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 376:	84 c0                	test   %al,%al
 378:	0f 84 23 01 00 00    	je     4a1 <printf+0x161>
    c = fmt[i] & 0xff;
 37e:	0f be f8             	movsbl %al,%edi
 381:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 384:	85 f6                	test   %esi,%esi
 386:	75 df                	jne    367 <printf+0x27>
      if(c == '%'){
 388:	83 f8 25             	cmp    $0x25,%eax
 38b:	75 ce                	jne    35b <printf+0x1b>
        state = '%';
 38d:	89 c6                	mov    %eax,%esi
 38f:	eb db                	jmp    36c <printf+0x2c>
      if(c == 'd'){
 391:	83 f8 64             	cmp    $0x64,%eax
 394:	74 49                	je     3df <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 396:	83 f8 78             	cmp    $0x78,%eax
 399:	0f 94 c1             	sete   %cl
 39c:	83 f8 70             	cmp    $0x70,%eax
 39f:	0f 94 c2             	sete   %dl
 3a2:	08 d1                	or     %dl,%cl
 3a4:	75 63                	jne    409 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3a6:	83 f8 73             	cmp    $0x73,%eax
 3a9:	0f 84 84 00 00 00    	je     433 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3af:	83 f8 63             	cmp    $0x63,%eax
 3b2:	0f 84 b7 00 00 00    	je     46f <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3b8:	83 f8 25             	cmp    $0x25,%eax
 3bb:	0f 84 cc 00 00 00    	je     48d <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3c1:	ba 25 00 00 00       	mov    $0x25,%edx
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	e8 d8 fe ff ff       	call   2a6 <putc>
        putc(fd, c);
 3ce:	89 fa                	mov    %edi,%edx
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	e8 ce fe ff ff       	call   2a6 <putc>
      }
      state = 0;
 3d8:	be 00 00 00 00       	mov    $0x0,%esi
 3dd:	eb 8d                	jmp    36c <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e2:	8b 17                	mov    (%edi),%edx
 3e4:	83 ec 0c             	sub    $0xc,%esp
 3e7:	6a 01                	push   $0x1
 3e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3ee:	8b 45 08             	mov    0x8(%ebp),%eax
 3f1:	e8 ca fe ff ff       	call   2c0 <printint>
        ap++;
 3f6:	83 c7 04             	add    $0x4,%edi
 3f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fc:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3ff:	be 00 00 00 00       	mov    $0x0,%esi
 404:	e9 63 ff ff ff       	jmp    36c <printf+0x2c>
        printint(fd, *ap, 16, 0);
 409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 40c:	8b 17                	mov    (%edi),%edx
 40e:	83 ec 0c             	sub    $0xc,%esp
 411:	6a 00                	push   $0x0
 413:	b9 10 00 00 00       	mov    $0x10,%ecx
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	e8 a0 fe ff ff       	call   2c0 <printint>
        ap++;
 420:	83 c7 04             	add    $0x4,%edi
 423:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 426:	83 c4 10             	add    $0x10,%esp
      state = 0;
 429:	be 00 00 00 00       	mov    $0x0,%esi
 42e:	e9 39 ff ff ff       	jmp    36c <printf+0x2c>
        s = (char*)*ap;
 433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 436:	8b 30                	mov    (%eax),%esi
        ap++;
 438:	83 c0 04             	add    $0x4,%eax
 43b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 43e:	85 f6                	test   %esi,%esi
 440:	75 28                	jne    46a <printf+0x12a>
          s = "(null)";
 442:	be 25 06 00 00       	mov    $0x625,%esi
 447:	8b 7d 08             	mov    0x8(%ebp),%edi
 44a:	eb 0d                	jmp    459 <printf+0x119>
          putc(fd, *s);
 44c:	0f be d2             	movsbl %dl,%edx
 44f:	89 f8                	mov    %edi,%eax
 451:	e8 50 fe ff ff       	call   2a6 <putc>
          s++;
 456:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 459:	0f b6 16             	movzbl (%esi),%edx
 45c:	84 d2                	test   %dl,%dl
 45e:	75 ec                	jne    44c <printf+0x10c>
      state = 0;
 460:	be 00 00 00 00       	mov    $0x0,%esi
 465:	e9 02 ff ff ff       	jmp    36c <printf+0x2c>
 46a:	8b 7d 08             	mov    0x8(%ebp),%edi
 46d:	eb ea                	jmp    459 <printf+0x119>
        putc(fd, *ap);
 46f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 472:	0f be 17             	movsbl (%edi),%edx
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	e8 29 fe ff ff       	call   2a6 <putc>
        ap++;
 47d:	83 c7 04             	add    $0x4,%edi
 480:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 483:	be 00 00 00 00       	mov    $0x0,%esi
 488:	e9 df fe ff ff       	jmp    36c <printf+0x2c>
        putc(fd, c);
 48d:	89 fa                	mov    %edi,%edx
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	e8 0f fe ff ff       	call   2a6 <putc>
      state = 0;
 497:	be 00 00 00 00       	mov    $0x0,%esi
 49c:	e9 cb fe ff ff       	jmp    36c <printf+0x2c>
    }
  }
}
 4a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4a4:	5b                   	pop    %ebx
 4a5:	5e                   	pop    %esi
 4a6:	5f                   	pop    %edi
 4a7:	5d                   	pop    %ebp
 4a8:	c3                   	ret    

000004a9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a9:	55                   	push   %ebp
 4aa:	89 e5                	mov    %esp,%ebp
 4ac:	57                   	push   %edi
 4ad:	56                   	push   %esi
 4ae:	53                   	push   %ebx
 4af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4b2:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b5:	a1 d0 08 00 00       	mov    0x8d0,%eax
 4ba:	eb 02                	jmp    4be <free+0x15>
 4bc:	89 d0                	mov    %edx,%eax
 4be:	39 c8                	cmp    %ecx,%eax
 4c0:	73 04                	jae    4c6 <free+0x1d>
 4c2:	39 08                	cmp    %ecx,(%eax)
 4c4:	77 12                	ja     4d8 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4c6:	8b 10                	mov    (%eax),%edx
 4c8:	39 c2                	cmp    %eax,%edx
 4ca:	77 f0                	ja     4bc <free+0x13>
 4cc:	39 c8                	cmp    %ecx,%eax
 4ce:	72 08                	jb     4d8 <free+0x2f>
 4d0:	39 ca                	cmp    %ecx,%edx
 4d2:	77 04                	ja     4d8 <free+0x2f>
 4d4:	89 d0                	mov    %edx,%eax
 4d6:	eb e6                	jmp    4be <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d8:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4db:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4de:	8b 10                	mov    (%eax),%edx
 4e0:	39 d7                	cmp    %edx,%edi
 4e2:	74 19                	je     4fd <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4e4:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4e7:	8b 50 04             	mov    0x4(%eax),%edx
 4ea:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4ed:	39 ce                	cmp    %ecx,%esi
 4ef:	74 1b                	je     50c <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4f1:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4f3:	a3 d0 08 00 00       	mov    %eax,0x8d0
}
 4f8:	5b                   	pop    %ebx
 4f9:	5e                   	pop    %esi
 4fa:	5f                   	pop    %edi
 4fb:	5d                   	pop    %ebp
 4fc:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4fd:	03 72 04             	add    0x4(%edx),%esi
 500:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 503:	8b 10                	mov    (%eax),%edx
 505:	8b 12                	mov    (%edx),%edx
 507:	89 53 f8             	mov    %edx,-0x8(%ebx)
 50a:	eb db                	jmp    4e7 <free+0x3e>
    p->s.size += bp->s.size;
 50c:	03 53 fc             	add    -0x4(%ebx),%edx
 50f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 512:	8b 53 f8             	mov    -0x8(%ebx),%edx
 515:	89 10                	mov    %edx,(%eax)
 517:	eb da                	jmp    4f3 <free+0x4a>

00000519 <morecore>:

static Header*
morecore(uint nu)
{
 519:	55                   	push   %ebp
 51a:	89 e5                	mov    %esp,%ebp
 51c:	53                   	push   %ebx
 51d:	83 ec 04             	sub    $0x4,%esp
 520:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 522:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 527:	77 05                	ja     52e <morecore+0x15>
    nu = 4096;
 529:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 52e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 535:	83 ec 0c             	sub    $0xc,%esp
 538:	50                   	push   %eax
 539:	e8 48 fd ff ff       	call   286 <sbrk>
  if(p == (char*)-1)
 53e:	83 c4 10             	add    $0x10,%esp
 541:	83 f8 ff             	cmp    $0xffffffff,%eax
 544:	74 1c                	je     562 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 546:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 549:	83 c0 08             	add    $0x8,%eax
 54c:	83 ec 0c             	sub    $0xc,%esp
 54f:	50                   	push   %eax
 550:	e8 54 ff ff ff       	call   4a9 <free>
  return freep;
 555:	a1 d0 08 00 00       	mov    0x8d0,%eax
 55a:	83 c4 10             	add    $0x10,%esp
}
 55d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 560:	c9                   	leave  
 561:	c3                   	ret    
    return 0;
 562:	b8 00 00 00 00       	mov    $0x0,%eax
 567:	eb f4                	jmp    55d <morecore+0x44>

00000569 <malloc>:

void*
malloc(uint nbytes)
{
 569:	55                   	push   %ebp
 56a:	89 e5                	mov    %esp,%ebp
 56c:	53                   	push   %ebx
 56d:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	8d 58 07             	lea    0x7(%eax),%ebx
 576:	c1 eb 03             	shr    $0x3,%ebx
 579:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 57c:	8b 0d d0 08 00 00    	mov    0x8d0,%ecx
 582:	85 c9                	test   %ecx,%ecx
 584:	74 04                	je     58a <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 586:	8b 01                	mov    (%ecx),%eax
 588:	eb 4d                	jmp    5d7 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 58a:	c7 05 d0 08 00 00 d4 	movl   $0x8d4,0x8d0
 591:	08 00 00 
 594:	c7 05 d4 08 00 00 d4 	movl   $0x8d4,0x8d4
 59b:	08 00 00 
    base.s.size = 0;
 59e:	c7 05 d8 08 00 00 00 	movl   $0x0,0x8d8
 5a5:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5a8:	b9 d4 08 00 00       	mov    $0x8d4,%ecx
 5ad:	eb d7                	jmp    586 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5af:	39 da                	cmp    %ebx,%edx
 5b1:	74 1a                	je     5cd <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5b3:	29 da                	sub    %ebx,%edx
 5b5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5b8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5bb:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5be:	89 0d d0 08 00 00    	mov    %ecx,0x8d0
      return (void*)(p + 1);
 5c4:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5c7:	83 c4 04             	add    $0x4,%esp
 5ca:	5b                   	pop    %ebx
 5cb:	5d                   	pop    %ebp
 5cc:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5cd:	8b 10                	mov    (%eax),%edx
 5cf:	89 11                	mov    %edx,(%ecx)
 5d1:	eb eb                	jmp    5be <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5d3:	89 c1                	mov    %eax,%ecx
 5d5:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5d7:	8b 50 04             	mov    0x4(%eax),%edx
 5da:	39 da                	cmp    %ebx,%edx
 5dc:	73 d1                	jae    5af <malloc+0x46>
    if(p == freep)
 5de:	39 05 d0 08 00 00    	cmp    %eax,0x8d0
 5e4:	75 ed                	jne    5d3 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5e6:	89 d8                	mov    %ebx,%eax
 5e8:	e8 2c ff ff ff       	call   519 <morecore>
 5ed:	85 c0                	test   %eax,%eax
 5ef:	75 e2                	jne    5d3 <malloc+0x6a>
        return 0;
 5f1:	b8 00 00 00 00       	mov    $0x0,%eax
 5f6:	eb cf                	jmp    5c7 <malloc+0x5e>
