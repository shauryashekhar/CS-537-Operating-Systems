
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 02                	push   $0x2
  14:	68 80 06 00 00       	push   $0x680
  19:	e8 8e 02 00 00       	call   2ac <open>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	78 1b                	js     40 <main+0x40>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  25:	83 ec 0c             	sub    $0xc,%esp
  28:	6a 00                	push   $0x0
  2a:	e8 b5 02 00 00       	call   2e4 <dup>
  dup(0);  // stderr
  2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  36:	e8 a9 02 00 00       	call   2e4 <dup>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb 58                	jmp    98 <main+0x98>
    mknod("console", 1, 1);
  40:	83 ec 04             	sub    $0x4,%esp
  43:	6a 01                	push   $0x1
  45:	6a 01                	push   $0x1
  47:	68 80 06 00 00       	push   $0x680
  4c:	e8 63 02 00 00       	call   2b4 <mknod>
    open("console", O_RDWR);
  51:	83 c4 08             	add    $0x8,%esp
  54:	6a 02                	push   $0x2
  56:	68 80 06 00 00       	push   $0x680
  5b:	e8 4c 02 00 00       	call   2ac <open>
  60:	83 c4 10             	add    $0x10,%esp
  63:	eb c0                	jmp    25 <main+0x25>

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 9b 06 00 00       	push   $0x69b
  6d:	6a 01                	push   $0x1
  6f:	e8 52 03 00 00       	call   3c6 <printf>
      exit();
  74:	e8 f3 01 00 00       	call   26c <exit>
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 c7 06 00 00       	push   $0x6c7
  81:	6a 01                	push   $0x1
  83:	e8 3e 03 00 00       	call   3c6 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  8b:	e8 e4 01 00 00       	call   274 <wait>
  90:	85 c0                	test   %eax,%eax
  92:	78 04                	js     98 <main+0x98>
  94:	39 c3                	cmp    %eax,%ebx
  96:	75 e1                	jne    79 <main+0x79>
    printf(1, "init: starting sh\n");
  98:	83 ec 08             	sub    $0x8,%esp
  9b:	68 88 06 00 00       	push   $0x688
  a0:	6a 01                	push   $0x1
  a2:	e8 1f 03 00 00       	call   3c6 <printf>
    pid = fork();
  a7:	e8 b8 01 00 00       	call   264 <fork>
  ac:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	85 c0                	test   %eax,%eax
  b3:	78 b0                	js     65 <main+0x65>
    if(pid == 0){
  b5:	85 c0                	test   %eax,%eax
  b7:	75 d2                	jne    8b <main+0x8b>
      exec("sh", argv);
  b9:	83 ec 08             	sub    $0x8,%esp
  bc:	68 74 09 00 00       	push   $0x974
  c1:	68 ae 06 00 00       	push   $0x6ae
  c6:	e8 d9 01 00 00       	call   2a4 <exec>
      printf(1, "init: exec sh failed\n");
  cb:	83 c4 08             	add    $0x8,%esp
  ce:	68 b1 06 00 00       	push   $0x6b1
  d3:	6a 01                	push   $0x1
  d5:	e8 ec 02 00 00       	call   3c6 <printf>
      exit();
  da:	e8 8d 01 00 00       	call   26c <exit>

000000df <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  df:	55                   	push   %ebp
  e0:	89 e5                	mov    %esp,%ebp
  e2:	53                   	push   %ebx
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e9:	89 c2                	mov    %eax,%edx
  eb:	0f b6 19             	movzbl (%ecx),%ebx
  ee:	88 1a                	mov    %bl,(%edx)
  f0:	8d 52 01             	lea    0x1(%edx),%edx
  f3:	8d 49 01             	lea    0x1(%ecx),%ecx
  f6:	84 db                	test   %bl,%bl
  f8:	75 f1                	jne    eb <strcpy+0xc>
    ;
  return os;
}
  fa:	5b                   	pop    %ebx
  fb:	5d                   	pop    %ebp
  fc:	c3                   	ret    

000000fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fd:	55                   	push   %ebp
  fe:	89 e5                	mov    %esp,%ebp
 100:	8b 4d 08             	mov    0x8(%ebp),%ecx
 103:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 106:	eb 06                	jmp    10e <strcmp+0x11>
    p++, q++;
 108:	83 c1 01             	add    $0x1,%ecx
 10b:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 10e:	0f b6 01             	movzbl (%ecx),%eax
 111:	84 c0                	test   %al,%al
 113:	74 04                	je     119 <strcmp+0x1c>
 115:	3a 02                	cmp    (%edx),%al
 117:	74 ef                	je     108 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 119:	0f b6 c0             	movzbl %al,%eax
 11c:	0f b6 12             	movzbl (%edx),%edx
 11f:	29 d0                	sub    %edx,%eax
}
 121:	5d                   	pop    %ebp
 122:	c3                   	ret    

00000123 <strlen>:

uint
strlen(const char *s)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 129:	ba 00 00 00 00       	mov    $0x0,%edx
 12e:	eb 03                	jmp    133 <strlen+0x10>
 130:	83 c2 01             	add    $0x1,%edx
 133:	89 d0                	mov    %edx,%eax
 135:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 139:	75 f5                	jne    130 <strlen+0xd>
    ;
  return n;
}
 13b:	5d                   	pop    %ebp
 13c:	c3                   	ret    

0000013d <memset>:

void*
memset(void *dst, int c, uint n)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	57                   	push   %edi
 141:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 144:	89 d7                	mov    %edx,%edi
 146:	8b 4d 10             	mov    0x10(%ebp),%ecx
 149:	8b 45 0c             	mov    0xc(%ebp),%eax
 14c:	fc                   	cld    
 14d:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 14f:	89 d0                	mov    %edx,%eax
 151:	5f                   	pop    %edi
 152:	5d                   	pop    %ebp
 153:	c3                   	ret    

00000154 <strchr>:

char*
strchr(const char *s, char c)
{
 154:	55                   	push   %ebp
 155:	89 e5                	mov    %esp,%ebp
 157:	8b 45 08             	mov    0x8(%ebp),%eax
 15a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 15e:	0f b6 10             	movzbl (%eax),%edx
 161:	84 d2                	test   %dl,%dl
 163:	74 09                	je     16e <strchr+0x1a>
    if(*s == c)
 165:	38 ca                	cmp    %cl,%dl
 167:	74 0a                	je     173 <strchr+0x1f>
  for(; *s; s++)
 169:	83 c0 01             	add    $0x1,%eax
 16c:	eb f0                	jmp    15e <strchr+0xa>
      return (char*)s;
  return 0;
 16e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 173:	5d                   	pop    %ebp
 174:	c3                   	ret    

00000175 <gets>:

char*
gets(char *buf, int max)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	57                   	push   %edi
 179:	56                   	push   %esi
 17a:	53                   	push   %ebx
 17b:	83 ec 1c             	sub    $0x1c,%esp
 17e:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 181:	bb 00 00 00 00       	mov    $0x0,%ebx
 186:	8d 73 01             	lea    0x1(%ebx),%esi
 189:	3b 75 0c             	cmp    0xc(%ebp),%esi
 18c:	7d 2e                	jge    1bc <gets+0x47>
    cc = read(0, &c, 1);
 18e:	83 ec 04             	sub    $0x4,%esp
 191:	6a 01                	push   $0x1
 193:	8d 45 e7             	lea    -0x19(%ebp),%eax
 196:	50                   	push   %eax
 197:	6a 00                	push   $0x0
 199:	e8 e6 00 00 00       	call   284 <read>
    if(cc < 1)
 19e:	83 c4 10             	add    $0x10,%esp
 1a1:	85 c0                	test   %eax,%eax
 1a3:	7e 17                	jle    1bc <gets+0x47>
      break;
    buf[i++] = c;
 1a5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a9:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1ac:	3c 0a                	cmp    $0xa,%al
 1ae:	0f 94 c2             	sete   %dl
 1b1:	3c 0d                	cmp    $0xd,%al
 1b3:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1b6:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1b8:	08 c2                	or     %al,%dl
 1ba:	74 ca                	je     186 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1bc:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1c0:	89 f8                	mov    %edi,%eax
 1c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1c5:	5b                   	pop    %ebx
 1c6:	5e                   	pop    %esi
 1c7:	5f                   	pop    %edi
 1c8:	5d                   	pop    %ebp
 1c9:	c3                   	ret    

000001ca <stat>:

int
stat(const char *n, struct stat *st)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	56                   	push   %esi
 1ce:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cf:	83 ec 08             	sub    $0x8,%esp
 1d2:	6a 00                	push   $0x0
 1d4:	ff 75 08             	pushl  0x8(%ebp)
 1d7:	e8 d0 00 00 00       	call   2ac <open>
  if(fd < 0)
 1dc:	83 c4 10             	add    $0x10,%esp
 1df:	85 c0                	test   %eax,%eax
 1e1:	78 24                	js     207 <stat+0x3d>
 1e3:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1e5:	83 ec 08             	sub    $0x8,%esp
 1e8:	ff 75 0c             	pushl  0xc(%ebp)
 1eb:	50                   	push   %eax
 1ec:	e8 d3 00 00 00       	call   2c4 <fstat>
 1f1:	89 c6                	mov    %eax,%esi
  close(fd);
 1f3:	89 1c 24             	mov    %ebx,(%esp)
 1f6:	e8 99 00 00 00       	call   294 <close>
  return r;
 1fb:	83 c4 10             	add    $0x10,%esp
}
 1fe:	89 f0                	mov    %esi,%eax
 200:	8d 65 f8             	lea    -0x8(%ebp),%esp
 203:	5b                   	pop    %ebx
 204:	5e                   	pop    %esi
 205:	5d                   	pop    %ebp
 206:	c3                   	ret    
    return -1;
 207:	be ff ff ff ff       	mov    $0xffffffff,%esi
 20c:	eb f0                	jmp    1fe <stat+0x34>

0000020e <atoi>:

int
atoi(const char *s)
{
 20e:	55                   	push   %ebp
 20f:	89 e5                	mov    %esp,%ebp
 211:	53                   	push   %ebx
 212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 215:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 21a:	eb 10                	jmp    22c <atoi+0x1e>
    n = n*10 + *s++ - '0';
 21c:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 21f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 222:	83 c1 01             	add    $0x1,%ecx
 225:	0f be d2             	movsbl %dl,%edx
 228:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 22c:	0f b6 11             	movzbl (%ecx),%edx
 22f:	8d 5a d0             	lea    -0x30(%edx),%ebx
 232:	80 fb 09             	cmp    $0x9,%bl
 235:	76 e5                	jbe    21c <atoi+0xe>
  return n;
}
 237:	5b                   	pop    %ebx
 238:	5d                   	pop    %ebp
 239:	c3                   	ret    

0000023a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	56                   	push   %esi
 23e:	53                   	push   %ebx
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
 242:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 245:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 248:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 24a:	eb 0d                	jmp    259 <memmove+0x1f>
    *dst++ = *src++;
 24c:	0f b6 13             	movzbl (%ebx),%edx
 24f:	88 11                	mov    %dl,(%ecx)
 251:	8d 5b 01             	lea    0x1(%ebx),%ebx
 254:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 257:	89 f2                	mov    %esi,%edx
 259:	8d 72 ff             	lea    -0x1(%edx),%esi
 25c:	85 d2                	test   %edx,%edx
 25e:	7f ec                	jg     24c <memmove+0x12>
  return vdst;
}
 260:	5b                   	pop    %ebx
 261:	5e                   	pop    %esi
 262:	5d                   	pop    %ebp
 263:	c3                   	ret    

00000264 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 264:	b8 01 00 00 00       	mov    $0x1,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <exit>:
SYSCALL(exit)
 26c:	b8 02 00 00 00       	mov    $0x2,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <wait>:
SYSCALL(wait)
 274:	b8 03 00 00 00       	mov    $0x3,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <pipe>:
SYSCALL(pipe)
 27c:	b8 04 00 00 00       	mov    $0x4,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <read>:
SYSCALL(read)
 284:	b8 05 00 00 00       	mov    $0x5,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <write>:
SYSCALL(write)
 28c:	b8 10 00 00 00       	mov    $0x10,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <close>:
SYSCALL(close)
 294:	b8 15 00 00 00       	mov    $0x15,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <kill>:
SYSCALL(kill)
 29c:	b8 06 00 00 00       	mov    $0x6,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <exec>:
SYSCALL(exec)
 2a4:	b8 07 00 00 00       	mov    $0x7,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <open>:
SYSCALL(open)
 2ac:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <mknod>:
SYSCALL(mknod)
 2b4:	b8 11 00 00 00       	mov    $0x11,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <unlink>:
SYSCALL(unlink)
 2bc:	b8 12 00 00 00       	mov    $0x12,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <fstat>:
SYSCALL(fstat)
 2c4:	b8 08 00 00 00       	mov    $0x8,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <link>:
SYSCALL(link)
 2cc:	b8 13 00 00 00       	mov    $0x13,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <mkdir>:
SYSCALL(mkdir)
 2d4:	b8 14 00 00 00       	mov    $0x14,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <chdir>:
SYSCALL(chdir)
 2dc:	b8 09 00 00 00       	mov    $0x9,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <dup>:
SYSCALL(dup)
 2e4:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <getpid>:
SYSCALL(getpid)
 2ec:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <sbrk>:
SYSCALL(sbrk)
 2f4:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <sleep>:
SYSCALL(sleep)
 2fc:	b8 0d 00 00 00       	mov    $0xd,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <uptime>:
SYSCALL(uptime)
 304:	b8 0e 00 00 00       	mov    $0xe,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <setpri>:
SYSCALL(setpri)
 30c:	b8 16 00 00 00       	mov    $0x16,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <getpri>:
SYSCALL(getpri)
 314:	b8 17 00 00 00       	mov    $0x17,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <getpinfo>:
SYSCALL(getpinfo)
 31c:	b8 18 00 00 00       	mov    $0x18,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <fork2>:
SYSCALL(fork2)
 324:	b8 19 00 00 00       	mov    $0x19,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 32c:	55                   	push   %ebp
 32d:	89 e5                	mov    %esp,%ebp
 32f:	83 ec 1c             	sub    $0x1c,%esp
 332:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 335:	6a 01                	push   $0x1
 337:	8d 55 f4             	lea    -0xc(%ebp),%edx
 33a:	52                   	push   %edx
 33b:	50                   	push   %eax
 33c:	e8 4b ff ff ff       	call   28c <write>
}
 341:	83 c4 10             	add    $0x10,%esp
 344:	c9                   	leave  
 345:	c3                   	ret    

00000346 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 346:	55                   	push   %ebp
 347:	89 e5                	mov    %esp,%ebp
 349:	57                   	push   %edi
 34a:	56                   	push   %esi
 34b:	53                   	push   %ebx
 34c:	83 ec 2c             	sub    $0x2c,%esp
 34f:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 351:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 355:	0f 95 c3             	setne  %bl
 358:	89 d0                	mov    %edx,%eax
 35a:	c1 e8 1f             	shr    $0x1f,%eax
 35d:	84 c3                	test   %al,%bl
 35f:	74 10                	je     371 <printint+0x2b>
    neg = 1;
    x = -xx;
 361:	f7 da                	neg    %edx
    neg = 1;
 363:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 36a:	be 00 00 00 00       	mov    $0x0,%esi
 36f:	eb 0b                	jmp    37c <printint+0x36>
  neg = 0;
 371:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 378:	eb f0                	jmp    36a <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 37a:	89 c6                	mov    %eax,%esi
 37c:	89 d0                	mov    %edx,%eax
 37e:	ba 00 00 00 00       	mov    $0x0,%edx
 383:	f7 f1                	div    %ecx
 385:	89 c3                	mov    %eax,%ebx
 387:	8d 46 01             	lea    0x1(%esi),%eax
 38a:	0f b6 92 d8 06 00 00 	movzbl 0x6d8(%edx),%edx
 391:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 395:	89 da                	mov    %ebx,%edx
 397:	85 db                	test   %ebx,%ebx
 399:	75 df                	jne    37a <printint+0x34>
 39b:	89 c3                	mov    %eax,%ebx
  if(neg)
 39d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3a1:	74 16                	je     3b9 <printint+0x73>
    buf[i++] = '-';
 3a3:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3a8:	8d 5e 02             	lea    0x2(%esi),%ebx
 3ab:	eb 0c                	jmp    3b9 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3ad:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3b2:	89 f8                	mov    %edi,%eax
 3b4:	e8 73 ff ff ff       	call   32c <putc>
  while(--i >= 0)
 3b9:	83 eb 01             	sub    $0x1,%ebx
 3bc:	79 ef                	jns    3ad <printint+0x67>
}
 3be:	83 c4 2c             	add    $0x2c,%esp
 3c1:	5b                   	pop    %ebx
 3c2:	5e                   	pop    %esi
 3c3:	5f                   	pop    %edi
 3c4:	5d                   	pop    %ebp
 3c5:	c3                   	ret    

000003c6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3c6:	55                   	push   %ebp
 3c7:	89 e5                	mov    %esp,%ebp
 3c9:	57                   	push   %edi
 3ca:	56                   	push   %esi
 3cb:	53                   	push   %ebx
 3cc:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3cf:	8d 45 10             	lea    0x10(%ebp),%eax
 3d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3d5:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3da:	bb 00 00 00 00       	mov    $0x0,%ebx
 3df:	eb 14                	jmp    3f5 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3e1:	89 fa                	mov    %edi,%edx
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	e8 41 ff ff ff       	call   32c <putc>
 3eb:	eb 05                	jmp    3f2 <printf+0x2c>
      }
    } else if(state == '%'){
 3ed:	83 fe 25             	cmp    $0x25,%esi
 3f0:	74 25                	je     417 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3f2:	83 c3 01             	add    $0x1,%ebx
 3f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f8:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3fc:	84 c0                	test   %al,%al
 3fe:	0f 84 23 01 00 00    	je     527 <printf+0x161>
    c = fmt[i] & 0xff;
 404:	0f be f8             	movsbl %al,%edi
 407:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 40a:	85 f6                	test   %esi,%esi
 40c:	75 df                	jne    3ed <printf+0x27>
      if(c == '%'){
 40e:	83 f8 25             	cmp    $0x25,%eax
 411:	75 ce                	jne    3e1 <printf+0x1b>
        state = '%';
 413:	89 c6                	mov    %eax,%esi
 415:	eb db                	jmp    3f2 <printf+0x2c>
      if(c == 'd'){
 417:	83 f8 64             	cmp    $0x64,%eax
 41a:	74 49                	je     465 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 41c:	83 f8 78             	cmp    $0x78,%eax
 41f:	0f 94 c1             	sete   %cl
 422:	83 f8 70             	cmp    $0x70,%eax
 425:	0f 94 c2             	sete   %dl
 428:	08 d1                	or     %dl,%cl
 42a:	75 63                	jne    48f <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 42c:	83 f8 73             	cmp    $0x73,%eax
 42f:	0f 84 84 00 00 00    	je     4b9 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 435:	83 f8 63             	cmp    $0x63,%eax
 438:	0f 84 b7 00 00 00    	je     4f5 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 43e:	83 f8 25             	cmp    $0x25,%eax
 441:	0f 84 cc 00 00 00    	je     513 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 447:	ba 25 00 00 00       	mov    $0x25,%edx
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	e8 d8 fe ff ff       	call   32c <putc>
        putc(fd, c);
 454:	89 fa                	mov    %edi,%edx
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	e8 ce fe ff ff       	call   32c <putc>
      }
      state = 0;
 45e:	be 00 00 00 00       	mov    $0x0,%esi
 463:	eb 8d                	jmp    3f2 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 468:	8b 17                	mov    (%edi),%edx
 46a:	83 ec 0c             	sub    $0xc,%esp
 46d:	6a 01                	push   $0x1
 46f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	e8 ca fe ff ff       	call   346 <printint>
        ap++;
 47c:	83 c7 04             	add    $0x4,%edi
 47f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 482:	83 c4 10             	add    $0x10,%esp
      state = 0;
 485:	be 00 00 00 00       	mov    $0x0,%esi
 48a:	e9 63 ff ff ff       	jmp    3f2 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 48f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 492:	8b 17                	mov    (%edi),%edx
 494:	83 ec 0c             	sub    $0xc,%esp
 497:	6a 00                	push   $0x0
 499:	b9 10 00 00 00       	mov    $0x10,%ecx
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	e8 a0 fe ff ff       	call   346 <printint>
        ap++;
 4a6:	83 c7 04             	add    $0x4,%edi
 4a9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4ac:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4af:	be 00 00 00 00       	mov    $0x0,%esi
 4b4:	e9 39 ff ff ff       	jmp    3f2 <printf+0x2c>
        s = (char*)*ap;
 4b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4bc:	8b 30                	mov    (%eax),%esi
        ap++;
 4be:	83 c0 04             	add    $0x4,%eax
 4c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4c4:	85 f6                	test   %esi,%esi
 4c6:	75 28                	jne    4f0 <printf+0x12a>
          s = "(null)";
 4c8:	be d0 06 00 00       	mov    $0x6d0,%esi
 4cd:	8b 7d 08             	mov    0x8(%ebp),%edi
 4d0:	eb 0d                	jmp    4df <printf+0x119>
          putc(fd, *s);
 4d2:	0f be d2             	movsbl %dl,%edx
 4d5:	89 f8                	mov    %edi,%eax
 4d7:	e8 50 fe ff ff       	call   32c <putc>
          s++;
 4dc:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4df:	0f b6 16             	movzbl (%esi),%edx
 4e2:	84 d2                	test   %dl,%dl
 4e4:	75 ec                	jne    4d2 <printf+0x10c>
      state = 0;
 4e6:	be 00 00 00 00       	mov    $0x0,%esi
 4eb:	e9 02 ff ff ff       	jmp    3f2 <printf+0x2c>
 4f0:	8b 7d 08             	mov    0x8(%ebp),%edi
 4f3:	eb ea                	jmp    4df <printf+0x119>
        putc(fd, *ap);
 4f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f8:	0f be 17             	movsbl (%edi),%edx
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	e8 29 fe ff ff       	call   32c <putc>
        ap++;
 503:	83 c7 04             	add    $0x4,%edi
 506:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 509:	be 00 00 00 00       	mov    $0x0,%esi
 50e:	e9 df fe ff ff       	jmp    3f2 <printf+0x2c>
        putc(fd, c);
 513:	89 fa                	mov    %edi,%edx
 515:	8b 45 08             	mov    0x8(%ebp),%eax
 518:	e8 0f fe ff ff       	call   32c <putc>
      state = 0;
 51d:	be 00 00 00 00       	mov    $0x0,%esi
 522:	e9 cb fe ff ff       	jmp    3f2 <printf+0x2c>
    }
  }
}
 527:	8d 65 f4             	lea    -0xc(%ebp),%esp
 52a:	5b                   	pop    %ebx
 52b:	5e                   	pop    %esi
 52c:	5f                   	pop    %edi
 52d:	5d                   	pop    %ebp
 52e:	c3                   	ret    

0000052f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
 532:	57                   	push   %edi
 533:	56                   	push   %esi
 534:	53                   	push   %ebx
 535:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 538:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 53b:	a1 7c 09 00 00       	mov    0x97c,%eax
 540:	eb 02                	jmp    544 <free+0x15>
 542:	89 d0                	mov    %edx,%eax
 544:	39 c8                	cmp    %ecx,%eax
 546:	73 04                	jae    54c <free+0x1d>
 548:	39 08                	cmp    %ecx,(%eax)
 54a:	77 12                	ja     55e <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 54c:	8b 10                	mov    (%eax),%edx
 54e:	39 c2                	cmp    %eax,%edx
 550:	77 f0                	ja     542 <free+0x13>
 552:	39 c8                	cmp    %ecx,%eax
 554:	72 08                	jb     55e <free+0x2f>
 556:	39 ca                	cmp    %ecx,%edx
 558:	77 04                	ja     55e <free+0x2f>
 55a:	89 d0                	mov    %edx,%eax
 55c:	eb e6                	jmp    544 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 55e:	8b 73 fc             	mov    -0x4(%ebx),%esi
 561:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 564:	8b 10                	mov    (%eax),%edx
 566:	39 d7                	cmp    %edx,%edi
 568:	74 19                	je     583 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 56a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 56d:	8b 50 04             	mov    0x4(%eax),%edx
 570:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 573:	39 ce                	cmp    %ecx,%esi
 575:	74 1b                	je     592 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 577:	89 08                	mov    %ecx,(%eax)
  freep = p;
 579:	a3 7c 09 00 00       	mov    %eax,0x97c
}
 57e:	5b                   	pop    %ebx
 57f:	5e                   	pop    %esi
 580:	5f                   	pop    %edi
 581:	5d                   	pop    %ebp
 582:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 583:	03 72 04             	add    0x4(%edx),%esi
 586:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 589:	8b 10                	mov    (%eax),%edx
 58b:	8b 12                	mov    (%edx),%edx
 58d:	89 53 f8             	mov    %edx,-0x8(%ebx)
 590:	eb db                	jmp    56d <free+0x3e>
    p->s.size += bp->s.size;
 592:	03 53 fc             	add    -0x4(%ebx),%edx
 595:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 598:	8b 53 f8             	mov    -0x8(%ebx),%edx
 59b:	89 10                	mov    %edx,(%eax)
 59d:	eb da                	jmp    579 <free+0x4a>

0000059f <morecore>:

static Header*
morecore(uint nu)
{
 59f:	55                   	push   %ebp
 5a0:	89 e5                	mov    %esp,%ebp
 5a2:	53                   	push   %ebx
 5a3:	83 ec 04             	sub    $0x4,%esp
 5a6:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5a8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5ad:	77 05                	ja     5b4 <morecore+0x15>
    nu = 4096;
 5af:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5b4:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5bb:	83 ec 0c             	sub    $0xc,%esp
 5be:	50                   	push   %eax
 5bf:	e8 30 fd ff ff       	call   2f4 <sbrk>
  if(p == (char*)-1)
 5c4:	83 c4 10             	add    $0x10,%esp
 5c7:	83 f8 ff             	cmp    $0xffffffff,%eax
 5ca:	74 1c                	je     5e8 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5cc:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5cf:	83 c0 08             	add    $0x8,%eax
 5d2:	83 ec 0c             	sub    $0xc,%esp
 5d5:	50                   	push   %eax
 5d6:	e8 54 ff ff ff       	call   52f <free>
  return freep;
 5db:	a1 7c 09 00 00       	mov    0x97c,%eax
 5e0:	83 c4 10             	add    $0x10,%esp
}
 5e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5e6:	c9                   	leave  
 5e7:	c3                   	ret    
    return 0;
 5e8:	b8 00 00 00 00       	mov    $0x0,%eax
 5ed:	eb f4                	jmp    5e3 <morecore+0x44>

000005ef <malloc>:

void*
malloc(uint nbytes)
{
 5ef:	55                   	push   %ebp
 5f0:	89 e5                	mov    %esp,%ebp
 5f2:	53                   	push   %ebx
 5f3:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	8d 58 07             	lea    0x7(%eax),%ebx
 5fc:	c1 eb 03             	shr    $0x3,%ebx
 5ff:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 602:	8b 0d 7c 09 00 00    	mov    0x97c,%ecx
 608:	85 c9                	test   %ecx,%ecx
 60a:	74 04                	je     610 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 60c:	8b 01                	mov    (%ecx),%eax
 60e:	eb 4d                	jmp    65d <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 610:	c7 05 7c 09 00 00 80 	movl   $0x980,0x97c
 617:	09 00 00 
 61a:	c7 05 80 09 00 00 80 	movl   $0x980,0x980
 621:	09 00 00 
    base.s.size = 0;
 624:	c7 05 84 09 00 00 00 	movl   $0x0,0x984
 62b:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 62e:	b9 80 09 00 00       	mov    $0x980,%ecx
 633:	eb d7                	jmp    60c <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 635:	39 da                	cmp    %ebx,%edx
 637:	74 1a                	je     653 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 639:	29 da                	sub    %ebx,%edx
 63b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 63e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 641:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 644:	89 0d 7c 09 00 00    	mov    %ecx,0x97c
      return (void*)(p + 1);
 64a:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 64d:	83 c4 04             	add    $0x4,%esp
 650:	5b                   	pop    %ebx
 651:	5d                   	pop    %ebp
 652:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 653:	8b 10                	mov    (%eax),%edx
 655:	89 11                	mov    %edx,(%ecx)
 657:	eb eb                	jmp    644 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 659:	89 c1                	mov    %eax,%ecx
 65b:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 65d:	8b 50 04             	mov    0x4(%eax),%edx
 660:	39 da                	cmp    %ebx,%edx
 662:	73 d1                	jae    635 <malloc+0x46>
    if(p == freep)
 664:	39 05 7c 09 00 00    	cmp    %eax,0x97c
 66a:	75 ed                	jne    659 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 66c:	89 d8                	mov    %ebx,%eax
 66e:	e8 2c ff ff ff       	call   59f <morecore>
 673:	85 c0                	test   %eax,%eax
 675:	75 e2                	jne    659 <malloc+0x6a>
        return 0;
 677:	b8 00 00 00 00       	mov    $0x0,%eax
 67c:	eb cf                	jmp    64d <malloc+0x5e>
