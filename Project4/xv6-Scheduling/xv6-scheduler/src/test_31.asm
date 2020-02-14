
_test_31:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#else
# define DEBUG_PRINT(x) do {} while (0)
#endif

//char buf[10000]; // ~10KB
int workload(int n, int t) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
   8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  int i, j = 0;
   b:	bb 00 00 00 00       	mov    $0x0,%ebx
  for (i = 0; i < n; i++) {
  10:	b8 00 00 00 00       	mov    $0x0,%eax
  15:	eb 0c                	jmp    23 <workload+0x23>
    j += i * j + 1;
  17:	89 c2                	mov    %eax,%edx
  19:	0f af d3             	imul   %ebx,%edx
  1c:	8d 5c 1a 01          	lea    0x1(%edx,%ebx,1),%ebx
  for (i = 0; i < n; i++) {
  20:	83 c0 01             	add    $0x1,%eax
  23:	39 f0                	cmp    %esi,%eax
  25:	7c f0                	jl     17 <workload+0x17>
  }
  if (t > 0) sleep(t);
  27:	85 c9                	test   %ecx,%ecx
  29:	7f 07                	jg     32 <workload+0x32>

  for (i = 0; i < n; i++) {
  2b:	b8 00 00 00 00       	mov    $0x0,%eax
  30:	eb 1a                	jmp    4c <workload+0x4c>
  if (t > 0) sleep(t);
  32:	83 ec 0c             	sub    $0xc,%esp
  35:	51                   	push   %ecx
  36:	e8 cc 02 00 00       	call   307 <sleep>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb eb                	jmp    2b <workload+0x2b>
    j += i * j + 1;
  40:	89 c2                	mov    %eax,%edx
  42:	0f af d3             	imul   %ebx,%edx
  45:	8d 5c 1a 01          	lea    0x1(%edx,%ebx,1),%ebx
  for (i = 0; i < n; i++) {
  49:	83 c0 01             	add    $0x1,%eax
  4c:	39 f0                	cmp    %esi,%eax
  4e:	7c f0                	jl     40 <workload+0x40>
  }
  return j;
}
  50:	89 d8                	mov    %ebx,%eax
  52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  55:	5b                   	pop    %ebx
  56:	5e                   	pop    %esi
  57:	5d                   	pop    %ebp
  58:	c3                   	ret    

00000059 <main>:

int
main(int argc, char *argv[])
{
  59:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  5d:	83 e4 f0             	and    $0xfffffff0,%esp
  60:	ff 71 fc             	pushl  -0x4(%ecx)
  63:	55                   	push   %ebp
  64:	89 e5                	mov    %esp,%ebp
  66:	53                   	push   %ebx
  67:	51                   	push   %ecx
  int pid1 = fork2(1);
  68:	83 ec 0c             	sub    $0xc,%esp
  6b:	6a 01                	push   $0x1
  6d:	e8 bd 02 00 00       	call   32f <fork2>
  if (pid1 == 0) {
  72:	83 c4 10             	add    $0x10,%esp
  75:	85 c0                	test   %eax,%eax
  77:	74 0f                	je     88 <main+0x2f>
      printf(1, "XV6_SCHEDULER: parent\n");
      while (wait() != -1);
    }
    exit();
  } else {
    while (wait() != -1);
  79:	e8 01 02 00 00       	call   27f <wait>
  7e:	83 f8 ff             	cmp    $0xffffffff,%eax
  81:	75 f6                	jne    79 <main+0x20>
  }
  exit();
  83:	e8 ef 01 00 00       	call   277 <exit>
    workload(100, 0);
  88:	83 ec 08             	sub    $0x8,%esp
  8b:	6a 00                	push   $0x0
  8d:	6a 64                	push   $0x64
  8f:	e8 6c ff ff ff       	call   0 <workload>
    int pid2 = fork2(2);
  94:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  9b:	e8 8f 02 00 00       	call   32f <fork2>
  a0:	89 c3                	mov    %eax,%ebx
    sleep(1);
  a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a9:	e8 59 02 00 00       	call   307 <sleep>
    if (pid2 == 0) {
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	85 db                	test   %ebx,%ebx
  b3:	75 17                	jne    cc <main+0x73>
      printf(1, "XV6_SCHEDULER: child\n");
  b5:	83 ec 08             	sub    $0x8,%esp
  b8:	68 8c 06 00 00       	push   $0x68c
  bd:	6a 01                	push   $0x1
  bf:	e8 0d 03 00 00       	call   3d1 <printf>
  c4:	83 c4 10             	add    $0x10,%esp
    exit();
  c7:	e8 ab 01 00 00       	call   277 <exit>
      printf(1, "XV6_SCHEDULER: parent\n");
  cc:	83 ec 08             	sub    $0x8,%esp
  cf:	68 a2 06 00 00       	push   $0x6a2
  d4:	6a 01                	push   $0x1
  d6:	e8 f6 02 00 00       	call   3d1 <printf>
      while (wait() != -1);
  db:	83 c4 10             	add    $0x10,%esp
  de:	e8 9c 01 00 00       	call   27f <wait>
  e3:	83 f8 ff             	cmp    $0xffffffff,%eax
  e6:	75 f6                	jne    de <main+0x85>
  e8:	eb dd                	jmp    c7 <main+0x6e>

000000ea <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  ea:	55                   	push   %ebp
  eb:	89 e5                	mov    %esp,%ebp
  ed:	53                   	push   %ebx
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	89 c2                	mov    %eax,%edx
  f6:	0f b6 19             	movzbl (%ecx),%ebx
  f9:	88 1a                	mov    %bl,(%edx)
  fb:	8d 52 01             	lea    0x1(%edx),%edx
  fe:	8d 49 01             	lea    0x1(%ecx),%ecx
 101:	84 db                	test   %bl,%bl
 103:	75 f1                	jne    f6 <strcpy+0xc>
    ;
  return os;
}
 105:	5b                   	pop    %ebx
 106:	5d                   	pop    %ebp
 107:	c3                   	ret    

00000108 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 108:	55                   	push   %ebp
 109:	89 e5                	mov    %esp,%ebp
 10b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 111:	eb 06                	jmp    119 <strcmp+0x11>
    p++, q++;
 113:	83 c1 01             	add    $0x1,%ecx
 116:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 119:	0f b6 01             	movzbl (%ecx),%eax
 11c:	84 c0                	test   %al,%al
 11e:	74 04                	je     124 <strcmp+0x1c>
 120:	3a 02                	cmp    (%edx),%al
 122:	74 ef                	je     113 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 124:	0f b6 c0             	movzbl %al,%eax
 127:	0f b6 12             	movzbl (%edx),%edx
 12a:	29 d0                	sub    %edx,%eax
}
 12c:	5d                   	pop    %ebp
 12d:	c3                   	ret    

0000012e <strlen>:

uint
strlen(const char *s)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
 131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 134:	ba 00 00 00 00       	mov    $0x0,%edx
 139:	eb 03                	jmp    13e <strlen+0x10>
 13b:	83 c2 01             	add    $0x1,%edx
 13e:	89 d0                	mov    %edx,%eax
 140:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 144:	75 f5                	jne    13b <strlen+0xd>
    ;
  return n;
}
 146:	5d                   	pop    %ebp
 147:	c3                   	ret    

00000148 <memset>:

void*
memset(void *dst, int c, uint n)
{
 148:	55                   	push   %ebp
 149:	89 e5                	mov    %esp,%ebp
 14b:	57                   	push   %edi
 14c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 14f:	89 d7                	mov    %edx,%edi
 151:	8b 4d 10             	mov    0x10(%ebp),%ecx
 154:	8b 45 0c             	mov    0xc(%ebp),%eax
 157:	fc                   	cld    
 158:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 15a:	89 d0                	mov    %edx,%eax
 15c:	5f                   	pop    %edi
 15d:	5d                   	pop    %ebp
 15e:	c3                   	ret    

0000015f <strchr>:

char*
strchr(const char *s, char c)
{
 15f:	55                   	push   %ebp
 160:	89 e5                	mov    %esp,%ebp
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 169:	0f b6 10             	movzbl (%eax),%edx
 16c:	84 d2                	test   %dl,%dl
 16e:	74 09                	je     179 <strchr+0x1a>
    if(*s == c)
 170:	38 ca                	cmp    %cl,%dl
 172:	74 0a                	je     17e <strchr+0x1f>
  for(; *s; s++)
 174:	83 c0 01             	add    $0x1,%eax
 177:	eb f0                	jmp    169 <strchr+0xa>
      return (char*)s;
  return 0;
 179:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	57                   	push   %edi
 184:	56                   	push   %esi
 185:	53                   	push   %ebx
 186:	83 ec 1c             	sub    $0x1c,%esp
 189:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18c:	bb 00 00 00 00       	mov    $0x0,%ebx
 191:	8d 73 01             	lea    0x1(%ebx),%esi
 194:	3b 75 0c             	cmp    0xc(%ebp),%esi
 197:	7d 2e                	jge    1c7 <gets+0x47>
    cc = read(0, &c, 1);
 199:	83 ec 04             	sub    $0x4,%esp
 19c:	6a 01                	push   $0x1
 19e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1a1:	50                   	push   %eax
 1a2:	6a 00                	push   $0x0
 1a4:	e8 e6 00 00 00       	call   28f <read>
    if(cc < 1)
 1a9:	83 c4 10             	add    $0x10,%esp
 1ac:	85 c0                	test   %eax,%eax
 1ae:	7e 17                	jle    1c7 <gets+0x47>
      break;
    buf[i++] = c;
 1b0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1b4:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1b7:	3c 0a                	cmp    $0xa,%al
 1b9:	0f 94 c2             	sete   %dl
 1bc:	3c 0d                	cmp    $0xd,%al
 1be:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1c1:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1c3:	08 c2                	or     %al,%dl
 1c5:	74 ca                	je     191 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1c7:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1cb:	89 f8                	mov    %edi,%eax
 1cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1d0:	5b                   	pop    %ebx
 1d1:	5e                   	pop    %esi
 1d2:	5f                   	pop    %edi
 1d3:	5d                   	pop    %ebp
 1d4:	c3                   	ret    

000001d5 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	56                   	push   %esi
 1d9:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1da:	83 ec 08             	sub    $0x8,%esp
 1dd:	6a 00                	push   $0x0
 1df:	ff 75 08             	pushl  0x8(%ebp)
 1e2:	e8 d0 00 00 00       	call   2b7 <open>
  if(fd < 0)
 1e7:	83 c4 10             	add    $0x10,%esp
 1ea:	85 c0                	test   %eax,%eax
 1ec:	78 24                	js     212 <stat+0x3d>
 1ee:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1f0:	83 ec 08             	sub    $0x8,%esp
 1f3:	ff 75 0c             	pushl  0xc(%ebp)
 1f6:	50                   	push   %eax
 1f7:	e8 d3 00 00 00       	call   2cf <fstat>
 1fc:	89 c6                	mov    %eax,%esi
  close(fd);
 1fe:	89 1c 24             	mov    %ebx,(%esp)
 201:	e8 99 00 00 00       	call   29f <close>
  return r;
 206:	83 c4 10             	add    $0x10,%esp
}
 209:	89 f0                	mov    %esi,%eax
 20b:	8d 65 f8             	lea    -0x8(%ebp),%esp
 20e:	5b                   	pop    %ebx
 20f:	5e                   	pop    %esi
 210:	5d                   	pop    %ebp
 211:	c3                   	ret    
    return -1;
 212:	be ff ff ff ff       	mov    $0xffffffff,%esi
 217:	eb f0                	jmp    209 <stat+0x34>

00000219 <atoi>:

int
atoi(const char *s)
{
 219:	55                   	push   %ebp
 21a:	89 e5                	mov    %esp,%ebp
 21c:	53                   	push   %ebx
 21d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 220:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 225:	eb 10                	jmp    237 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 227:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 22a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 22d:	83 c1 01             	add    $0x1,%ecx
 230:	0f be d2             	movsbl %dl,%edx
 233:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 237:	0f b6 11             	movzbl (%ecx),%edx
 23a:	8d 5a d0             	lea    -0x30(%edx),%ebx
 23d:	80 fb 09             	cmp    $0x9,%bl
 240:	76 e5                	jbe    227 <atoi+0xe>
  return n;
}
 242:	5b                   	pop    %ebx
 243:	5d                   	pop    %ebp
 244:	c3                   	ret    

00000245 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	56                   	push   %esi
 249:	53                   	push   %ebx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 250:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 253:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 255:	eb 0d                	jmp    264 <memmove+0x1f>
    *dst++ = *src++;
 257:	0f b6 13             	movzbl (%ebx),%edx
 25a:	88 11                	mov    %dl,(%ecx)
 25c:	8d 5b 01             	lea    0x1(%ebx),%ebx
 25f:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 262:	89 f2                	mov    %esi,%edx
 264:	8d 72 ff             	lea    -0x1(%edx),%esi
 267:	85 d2                	test   %edx,%edx
 269:	7f ec                	jg     257 <memmove+0x12>
  return vdst;
}
 26b:	5b                   	pop    %ebx
 26c:	5e                   	pop    %esi
 26d:	5d                   	pop    %ebp
 26e:	c3                   	ret    

0000026f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 26f:	b8 01 00 00 00       	mov    $0x1,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <exit>:
SYSCALL(exit)
 277:	b8 02 00 00 00       	mov    $0x2,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret    

0000027f <wait>:
SYSCALL(wait)
 27f:	b8 03 00 00 00       	mov    $0x3,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <pipe>:
SYSCALL(pipe)
 287:	b8 04 00 00 00       	mov    $0x4,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <read>:
SYSCALL(read)
 28f:	b8 05 00 00 00       	mov    $0x5,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <write>:
SYSCALL(write)
 297:	b8 10 00 00 00       	mov    $0x10,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <close>:
SYSCALL(close)
 29f:	b8 15 00 00 00       	mov    $0x15,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <kill>:
SYSCALL(kill)
 2a7:	b8 06 00 00 00       	mov    $0x6,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <exec>:
SYSCALL(exec)
 2af:	b8 07 00 00 00       	mov    $0x7,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <open>:
SYSCALL(open)
 2b7:	b8 0f 00 00 00       	mov    $0xf,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <mknod>:
SYSCALL(mknod)
 2bf:	b8 11 00 00 00       	mov    $0x11,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <unlink>:
SYSCALL(unlink)
 2c7:	b8 12 00 00 00       	mov    $0x12,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <fstat>:
SYSCALL(fstat)
 2cf:	b8 08 00 00 00       	mov    $0x8,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <link>:
SYSCALL(link)
 2d7:	b8 13 00 00 00       	mov    $0x13,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <mkdir>:
SYSCALL(mkdir)
 2df:	b8 14 00 00 00       	mov    $0x14,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <chdir>:
SYSCALL(chdir)
 2e7:	b8 09 00 00 00       	mov    $0x9,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <dup>:
SYSCALL(dup)
 2ef:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <getpid>:
SYSCALL(getpid)
 2f7:	b8 0b 00 00 00       	mov    $0xb,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <sbrk>:
SYSCALL(sbrk)
 2ff:	b8 0c 00 00 00       	mov    $0xc,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <sleep>:
SYSCALL(sleep)
 307:	b8 0d 00 00 00       	mov    $0xd,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <uptime>:
SYSCALL(uptime)
 30f:	b8 0e 00 00 00       	mov    $0xe,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <setpri>:
SYSCALL(setpri)
 317:	b8 16 00 00 00       	mov    $0x16,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <getpri>:
SYSCALL(getpri)
 31f:	b8 17 00 00 00       	mov    $0x17,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <getpinfo>:
SYSCALL(getpinfo)
 327:	b8 18 00 00 00       	mov    $0x18,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <fork2>:
SYSCALL(fork2)
 32f:	b8 19 00 00 00       	mov    $0x19,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 337:	55                   	push   %ebp
 338:	89 e5                	mov    %esp,%ebp
 33a:	83 ec 1c             	sub    $0x1c,%esp
 33d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 340:	6a 01                	push   $0x1
 342:	8d 55 f4             	lea    -0xc(%ebp),%edx
 345:	52                   	push   %edx
 346:	50                   	push   %eax
 347:	e8 4b ff ff ff       	call   297 <write>
}
 34c:	83 c4 10             	add    $0x10,%esp
 34f:	c9                   	leave  
 350:	c3                   	ret    

00000351 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 351:	55                   	push   %ebp
 352:	89 e5                	mov    %esp,%ebp
 354:	57                   	push   %edi
 355:	56                   	push   %esi
 356:	53                   	push   %ebx
 357:	83 ec 2c             	sub    $0x2c,%esp
 35a:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 35c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 360:	0f 95 c3             	setne  %bl
 363:	89 d0                	mov    %edx,%eax
 365:	c1 e8 1f             	shr    $0x1f,%eax
 368:	84 c3                	test   %al,%bl
 36a:	74 10                	je     37c <printint+0x2b>
    neg = 1;
    x = -xx;
 36c:	f7 da                	neg    %edx
    neg = 1;
 36e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 375:	be 00 00 00 00       	mov    $0x0,%esi
 37a:	eb 0b                	jmp    387 <printint+0x36>
  neg = 0;
 37c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 383:	eb f0                	jmp    375 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 385:	89 c6                	mov    %eax,%esi
 387:	89 d0                	mov    %edx,%eax
 389:	ba 00 00 00 00       	mov    $0x0,%edx
 38e:	f7 f1                	div    %ecx
 390:	89 c3                	mov    %eax,%ebx
 392:	8d 46 01             	lea    0x1(%esi),%eax
 395:	0f b6 92 c0 06 00 00 	movzbl 0x6c0(%edx),%edx
 39c:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3a0:	89 da                	mov    %ebx,%edx
 3a2:	85 db                	test   %ebx,%ebx
 3a4:	75 df                	jne    385 <printint+0x34>
 3a6:	89 c3                	mov    %eax,%ebx
  if(neg)
 3a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3ac:	74 16                	je     3c4 <printint+0x73>
    buf[i++] = '-';
 3ae:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3b3:	8d 5e 02             	lea    0x2(%esi),%ebx
 3b6:	eb 0c                	jmp    3c4 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3b8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3bd:	89 f8                	mov    %edi,%eax
 3bf:	e8 73 ff ff ff       	call   337 <putc>
  while(--i >= 0)
 3c4:	83 eb 01             	sub    $0x1,%ebx
 3c7:	79 ef                	jns    3b8 <printint+0x67>
}
 3c9:	83 c4 2c             	add    $0x2c,%esp
 3cc:	5b                   	pop    %ebx
 3cd:	5e                   	pop    %esi
 3ce:	5f                   	pop    %edi
 3cf:	5d                   	pop    %ebp
 3d0:	c3                   	ret    

000003d1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3d1:	55                   	push   %ebp
 3d2:	89 e5                	mov    %esp,%ebp
 3d4:	57                   	push   %edi
 3d5:	56                   	push   %esi
 3d6:	53                   	push   %ebx
 3d7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3da:	8d 45 10             	lea    0x10(%ebp),%eax
 3dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3e0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3e5:	bb 00 00 00 00       	mov    $0x0,%ebx
 3ea:	eb 14                	jmp    400 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3ec:	89 fa                	mov    %edi,%edx
 3ee:	8b 45 08             	mov    0x8(%ebp),%eax
 3f1:	e8 41 ff ff ff       	call   337 <putc>
 3f6:	eb 05                	jmp    3fd <printf+0x2c>
      }
    } else if(state == '%'){
 3f8:	83 fe 25             	cmp    $0x25,%esi
 3fb:	74 25                	je     422 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3fd:	83 c3 01             	add    $0x1,%ebx
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 407:	84 c0                	test   %al,%al
 409:	0f 84 23 01 00 00    	je     532 <printf+0x161>
    c = fmt[i] & 0xff;
 40f:	0f be f8             	movsbl %al,%edi
 412:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 415:	85 f6                	test   %esi,%esi
 417:	75 df                	jne    3f8 <printf+0x27>
      if(c == '%'){
 419:	83 f8 25             	cmp    $0x25,%eax
 41c:	75 ce                	jne    3ec <printf+0x1b>
        state = '%';
 41e:	89 c6                	mov    %eax,%esi
 420:	eb db                	jmp    3fd <printf+0x2c>
      if(c == 'd'){
 422:	83 f8 64             	cmp    $0x64,%eax
 425:	74 49                	je     470 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 427:	83 f8 78             	cmp    $0x78,%eax
 42a:	0f 94 c1             	sete   %cl
 42d:	83 f8 70             	cmp    $0x70,%eax
 430:	0f 94 c2             	sete   %dl
 433:	08 d1                	or     %dl,%cl
 435:	75 63                	jne    49a <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 437:	83 f8 73             	cmp    $0x73,%eax
 43a:	0f 84 84 00 00 00    	je     4c4 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 440:	83 f8 63             	cmp    $0x63,%eax
 443:	0f 84 b7 00 00 00    	je     500 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 449:	83 f8 25             	cmp    $0x25,%eax
 44c:	0f 84 cc 00 00 00    	je     51e <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 452:	ba 25 00 00 00       	mov    $0x25,%edx
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	e8 d8 fe ff ff       	call   337 <putc>
        putc(fd, c);
 45f:	89 fa                	mov    %edi,%edx
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	e8 ce fe ff ff       	call   337 <putc>
      }
      state = 0;
 469:	be 00 00 00 00       	mov    $0x0,%esi
 46e:	eb 8d                	jmp    3fd <printf+0x2c>
        printint(fd, *ap, 10, 1);
 470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 473:	8b 17                	mov    (%edi),%edx
 475:	83 ec 0c             	sub    $0xc,%esp
 478:	6a 01                	push   $0x1
 47a:	b9 0a 00 00 00       	mov    $0xa,%ecx
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
 482:	e8 ca fe ff ff       	call   351 <printint>
        ap++;
 487:	83 c7 04             	add    $0x4,%edi
 48a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 48d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 490:	be 00 00 00 00       	mov    $0x0,%esi
 495:	e9 63 ff ff ff       	jmp    3fd <printf+0x2c>
        printint(fd, *ap, 16, 0);
 49a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 49d:	8b 17                	mov    (%edi),%edx
 49f:	83 ec 0c             	sub    $0xc,%esp
 4a2:	6a 00                	push   $0x0
 4a4:	b9 10 00 00 00       	mov    $0x10,%ecx
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	e8 a0 fe ff ff       	call   351 <printint>
        ap++;
 4b1:	83 c7 04             	add    $0x4,%edi
 4b4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4b7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ba:	be 00 00 00 00       	mov    $0x0,%esi
 4bf:	e9 39 ff ff ff       	jmp    3fd <printf+0x2c>
        s = (char*)*ap;
 4c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c7:	8b 30                	mov    (%eax),%esi
        ap++;
 4c9:	83 c0 04             	add    $0x4,%eax
 4cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4cf:	85 f6                	test   %esi,%esi
 4d1:	75 28                	jne    4fb <printf+0x12a>
          s = "(null)";
 4d3:	be b9 06 00 00       	mov    $0x6b9,%esi
 4d8:	8b 7d 08             	mov    0x8(%ebp),%edi
 4db:	eb 0d                	jmp    4ea <printf+0x119>
          putc(fd, *s);
 4dd:	0f be d2             	movsbl %dl,%edx
 4e0:	89 f8                	mov    %edi,%eax
 4e2:	e8 50 fe ff ff       	call   337 <putc>
          s++;
 4e7:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4ea:	0f b6 16             	movzbl (%esi),%edx
 4ed:	84 d2                	test   %dl,%dl
 4ef:	75 ec                	jne    4dd <printf+0x10c>
      state = 0;
 4f1:	be 00 00 00 00       	mov    $0x0,%esi
 4f6:	e9 02 ff ff ff       	jmp    3fd <printf+0x2c>
 4fb:	8b 7d 08             	mov    0x8(%ebp),%edi
 4fe:	eb ea                	jmp    4ea <printf+0x119>
        putc(fd, *ap);
 500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 503:	0f be 17             	movsbl (%edi),%edx
 506:	8b 45 08             	mov    0x8(%ebp),%eax
 509:	e8 29 fe ff ff       	call   337 <putc>
        ap++;
 50e:	83 c7 04             	add    $0x4,%edi
 511:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 514:	be 00 00 00 00       	mov    $0x0,%esi
 519:	e9 df fe ff ff       	jmp    3fd <printf+0x2c>
        putc(fd, c);
 51e:	89 fa                	mov    %edi,%edx
 520:	8b 45 08             	mov    0x8(%ebp),%eax
 523:	e8 0f fe ff ff       	call   337 <putc>
      state = 0;
 528:	be 00 00 00 00       	mov    $0x0,%esi
 52d:	e9 cb fe ff ff       	jmp    3fd <printf+0x2c>
    }
  }
}
 532:	8d 65 f4             	lea    -0xc(%ebp),%esp
 535:	5b                   	pop    %ebx
 536:	5e                   	pop    %esi
 537:	5f                   	pop    %edi
 538:	5d                   	pop    %ebp
 539:	c3                   	ret    

0000053a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 53a:	55                   	push   %ebp
 53b:	89 e5                	mov    %esp,%ebp
 53d:	57                   	push   %edi
 53e:	56                   	push   %esi
 53f:	53                   	push   %ebx
 540:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 543:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 546:	a1 84 09 00 00       	mov    0x984,%eax
 54b:	eb 02                	jmp    54f <free+0x15>
 54d:	89 d0                	mov    %edx,%eax
 54f:	39 c8                	cmp    %ecx,%eax
 551:	73 04                	jae    557 <free+0x1d>
 553:	39 08                	cmp    %ecx,(%eax)
 555:	77 12                	ja     569 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 557:	8b 10                	mov    (%eax),%edx
 559:	39 c2                	cmp    %eax,%edx
 55b:	77 f0                	ja     54d <free+0x13>
 55d:	39 c8                	cmp    %ecx,%eax
 55f:	72 08                	jb     569 <free+0x2f>
 561:	39 ca                	cmp    %ecx,%edx
 563:	77 04                	ja     569 <free+0x2f>
 565:	89 d0                	mov    %edx,%eax
 567:	eb e6                	jmp    54f <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 569:	8b 73 fc             	mov    -0x4(%ebx),%esi
 56c:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 56f:	8b 10                	mov    (%eax),%edx
 571:	39 d7                	cmp    %edx,%edi
 573:	74 19                	je     58e <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 575:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 578:	8b 50 04             	mov    0x4(%eax),%edx
 57b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 57e:	39 ce                	cmp    %ecx,%esi
 580:	74 1b                	je     59d <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 582:	89 08                	mov    %ecx,(%eax)
  freep = p;
 584:	a3 84 09 00 00       	mov    %eax,0x984
}
 589:	5b                   	pop    %ebx
 58a:	5e                   	pop    %esi
 58b:	5f                   	pop    %edi
 58c:	5d                   	pop    %ebp
 58d:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 58e:	03 72 04             	add    0x4(%edx),%esi
 591:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 594:	8b 10                	mov    (%eax),%edx
 596:	8b 12                	mov    (%edx),%edx
 598:	89 53 f8             	mov    %edx,-0x8(%ebx)
 59b:	eb db                	jmp    578 <free+0x3e>
    p->s.size += bp->s.size;
 59d:	03 53 fc             	add    -0x4(%ebx),%edx
 5a0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5a3:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5a6:	89 10                	mov    %edx,(%eax)
 5a8:	eb da                	jmp    584 <free+0x4a>

000005aa <morecore>:

static Header*
morecore(uint nu)
{
 5aa:	55                   	push   %ebp
 5ab:	89 e5                	mov    %esp,%ebp
 5ad:	53                   	push   %ebx
 5ae:	83 ec 04             	sub    $0x4,%esp
 5b1:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5b3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5b8:	77 05                	ja     5bf <morecore+0x15>
    nu = 4096;
 5ba:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5bf:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5c6:	83 ec 0c             	sub    $0xc,%esp
 5c9:	50                   	push   %eax
 5ca:	e8 30 fd ff ff       	call   2ff <sbrk>
  if(p == (char*)-1)
 5cf:	83 c4 10             	add    $0x10,%esp
 5d2:	83 f8 ff             	cmp    $0xffffffff,%eax
 5d5:	74 1c                	je     5f3 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5d7:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5da:	83 c0 08             	add    $0x8,%eax
 5dd:	83 ec 0c             	sub    $0xc,%esp
 5e0:	50                   	push   %eax
 5e1:	e8 54 ff ff ff       	call   53a <free>
  return freep;
 5e6:	a1 84 09 00 00       	mov    0x984,%eax
 5eb:	83 c4 10             	add    $0x10,%esp
}
 5ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5f1:	c9                   	leave  
 5f2:	c3                   	ret    
    return 0;
 5f3:	b8 00 00 00 00       	mov    $0x0,%eax
 5f8:	eb f4                	jmp    5ee <morecore+0x44>

000005fa <malloc>:

void*
malloc(uint nbytes)
{
 5fa:	55                   	push   %ebp
 5fb:	89 e5                	mov    %esp,%ebp
 5fd:	53                   	push   %ebx
 5fe:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 601:	8b 45 08             	mov    0x8(%ebp),%eax
 604:	8d 58 07             	lea    0x7(%eax),%ebx
 607:	c1 eb 03             	shr    $0x3,%ebx
 60a:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 60d:	8b 0d 84 09 00 00    	mov    0x984,%ecx
 613:	85 c9                	test   %ecx,%ecx
 615:	74 04                	je     61b <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 617:	8b 01                	mov    (%ecx),%eax
 619:	eb 4d                	jmp    668 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 61b:	c7 05 84 09 00 00 88 	movl   $0x988,0x984
 622:	09 00 00 
 625:	c7 05 88 09 00 00 88 	movl   $0x988,0x988
 62c:	09 00 00 
    base.s.size = 0;
 62f:	c7 05 8c 09 00 00 00 	movl   $0x0,0x98c
 636:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 639:	b9 88 09 00 00       	mov    $0x988,%ecx
 63e:	eb d7                	jmp    617 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 640:	39 da                	cmp    %ebx,%edx
 642:	74 1a                	je     65e <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 644:	29 da                	sub    %ebx,%edx
 646:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 649:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 64c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 64f:	89 0d 84 09 00 00    	mov    %ecx,0x984
      return (void*)(p + 1);
 655:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 658:	83 c4 04             	add    $0x4,%esp
 65b:	5b                   	pop    %ebx
 65c:	5d                   	pop    %ebp
 65d:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 65e:	8b 10                	mov    (%eax),%edx
 660:	89 11                	mov    %edx,(%ecx)
 662:	eb eb                	jmp    64f <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 664:	89 c1                	mov    %eax,%ecx
 666:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 668:	8b 50 04             	mov    0x4(%eax),%edx
 66b:	39 da                	cmp    %ebx,%edx
 66d:	73 d1                	jae    640 <malloc+0x46>
    if(p == freep)
 66f:	39 05 84 09 00 00    	cmp    %eax,0x984
 675:	75 ed                	jne    664 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 677:	89 d8                	mov    %ebx,%eax
 679:	e8 2c ff ff ff       	call   5aa <morecore>
 67e:	85 c0                	test   %eax,%eax
 680:	75 e2                	jne    664 <malloc+0x6a>
        return 0;
 682:	b8 00 00 00 00       	mov    $0x0,%eax
 687:	eb cf                	jmp    658 <malloc+0x5e>
