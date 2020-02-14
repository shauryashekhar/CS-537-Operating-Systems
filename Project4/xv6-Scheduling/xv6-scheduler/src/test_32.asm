
_test_32:     file format elf32-i386


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
  36:	e8 f0 02 00 00       	call   32b <sleep>
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
  6d:	e8 e1 02 00 00       	call   353 <fork2>
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
  79:	e8 25 02 00 00       	call   2a3 <wait>
  7e:	83 f8 ff             	cmp    $0xffffffff,%eax
  81:	75 f6                	jne    79 <main+0x20>
  }
  exit();
  83:	e8 13 02 00 00       	call   29b <exit>
    workload(100, 0);
  88:	83 ec 08             	sub    $0x8,%esp
  8b:	6a 00                	push   $0x0
  8d:	6a 64                	push   $0x64
  8f:	e8 6c ff ff ff       	call   0 <workload>
    int pid2 = fork2(0);
  94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  9b:	e8 b3 02 00 00       	call   353 <fork2>
  a0:	89 c3                	mov    %eax,%ebx
    if (pid2 != 0) {
  a2:	83 c4 10             	add    $0x10,%esp
  a5:	85 c0                	test   %eax,%eax
  a7:	75 28                	jne    d1 <main+0x78>
    sleep(1);
  a9:	83 ec 0c             	sub    $0xc,%esp
  ac:	6a 01                	push   $0x1
  ae:	e8 78 02 00 00       	call   32b <sleep>
    if (pid2 == 0) {
  b3:	83 c4 10             	add    $0x10,%esp
  b6:	85 db                	test   %ebx,%ebx
  b8:	75 36                	jne    f0 <main+0x97>
      printf(1, "XV6_SCHEDULER: child\n");
  ba:	83 ec 08             	sub    $0x8,%esp
  bd:	68 b0 06 00 00       	push   $0x6b0
  c2:	6a 01                	push   $0x1
  c4:	e8 2c 03 00 00       	call   3f5 <printf>
  c9:	83 c4 10             	add    $0x10,%esp
    exit();
  cc:	e8 ca 01 00 00       	call   29b <exit>
      workload(200, 0);
  d1:	83 ec 08             	sub    $0x8,%esp
  d4:	6a 00                	push   $0x0
  d6:	68 c8 00 00 00       	push   $0xc8
  db:	e8 20 ff ff ff       	call   0 <workload>
      setpri(pid2, 2);
  e0:	83 c4 08             	add    $0x8,%esp
  e3:	6a 02                	push   $0x2
  e5:	53                   	push   %ebx
  e6:	e8 50 02 00 00       	call   33b <setpri>
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	eb b9                	jmp    a9 <main+0x50>
      printf(1, "XV6_SCHEDULER: parent\n");
  f0:	83 ec 08             	sub    $0x8,%esp
  f3:	68 c6 06 00 00       	push   $0x6c6
  f8:	6a 01                	push   $0x1
  fa:	e8 f6 02 00 00       	call   3f5 <printf>
      while (wait() != -1);
  ff:	83 c4 10             	add    $0x10,%esp
 102:	e8 9c 01 00 00       	call   2a3 <wait>
 107:	83 f8 ff             	cmp    $0xffffffff,%eax
 10a:	75 f6                	jne    102 <main+0xa9>
 10c:	eb be                	jmp    cc <main+0x73>

0000010e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
 111:	53                   	push   %ebx
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	89 c2                	mov    %eax,%edx
 11a:	0f b6 19             	movzbl (%ecx),%ebx
 11d:	88 1a                	mov    %bl,(%edx)
 11f:	8d 52 01             	lea    0x1(%edx),%edx
 122:	8d 49 01             	lea    0x1(%ecx),%ecx
 125:	84 db                	test   %bl,%bl
 127:	75 f1                	jne    11a <strcpy+0xc>
    ;
  return os;
}
 129:	5b                   	pop    %ebx
 12a:	5d                   	pop    %ebp
 12b:	c3                   	ret    

0000012c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 132:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 135:	eb 06                	jmp    13d <strcmp+0x11>
    p++, q++;
 137:	83 c1 01             	add    $0x1,%ecx
 13a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 13d:	0f b6 01             	movzbl (%ecx),%eax
 140:	84 c0                	test   %al,%al
 142:	74 04                	je     148 <strcmp+0x1c>
 144:	3a 02                	cmp    (%edx),%al
 146:	74 ef                	je     137 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 148:	0f b6 c0             	movzbl %al,%eax
 14b:	0f b6 12             	movzbl (%edx),%edx
 14e:	29 d0                	sub    %edx,%eax
}
 150:	5d                   	pop    %ebp
 151:	c3                   	ret    

00000152 <strlen>:

uint
strlen(const char *s)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
 155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 158:	ba 00 00 00 00       	mov    $0x0,%edx
 15d:	eb 03                	jmp    162 <strlen+0x10>
 15f:	83 c2 01             	add    $0x1,%edx
 162:	89 d0                	mov    %edx,%eax
 164:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 168:	75 f5                	jne    15f <strlen+0xd>
    ;
  return n;
}
 16a:	5d                   	pop    %ebp
 16b:	c3                   	ret    

0000016c <memset>:

void*
memset(void *dst, int c, uint n)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	57                   	push   %edi
 170:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 173:	89 d7                	mov    %edx,%edi
 175:	8b 4d 10             	mov    0x10(%ebp),%ecx
 178:	8b 45 0c             	mov    0xc(%ebp),%eax
 17b:	fc                   	cld    
 17c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 17e:	89 d0                	mov    %edx,%eax
 180:	5f                   	pop    %edi
 181:	5d                   	pop    %ebp
 182:	c3                   	ret    

00000183 <strchr>:

char*
strchr(const char *s, char c)
{
 183:	55                   	push   %ebp
 184:	89 e5                	mov    %esp,%ebp
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 18d:	0f b6 10             	movzbl (%eax),%edx
 190:	84 d2                	test   %dl,%dl
 192:	74 09                	je     19d <strchr+0x1a>
    if(*s == c)
 194:	38 ca                	cmp    %cl,%dl
 196:	74 0a                	je     1a2 <strchr+0x1f>
  for(; *s; s++)
 198:	83 c0 01             	add    $0x1,%eax
 19b:	eb f0                	jmp    18d <strchr+0xa>
      return (char*)s;
  return 0;
 19d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a2:	5d                   	pop    %ebp
 1a3:	c3                   	ret    

000001a4 <gets>:

char*
gets(char *buf, int max)
{
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	57                   	push   %edi
 1a8:	56                   	push   %esi
 1a9:	53                   	push   %ebx
 1aa:	83 ec 1c             	sub    $0x1c,%esp
 1ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b0:	bb 00 00 00 00       	mov    $0x0,%ebx
 1b5:	8d 73 01             	lea    0x1(%ebx),%esi
 1b8:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1bb:	7d 2e                	jge    1eb <gets+0x47>
    cc = read(0, &c, 1);
 1bd:	83 ec 04             	sub    $0x4,%esp
 1c0:	6a 01                	push   $0x1
 1c2:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1c5:	50                   	push   %eax
 1c6:	6a 00                	push   $0x0
 1c8:	e8 e6 00 00 00       	call   2b3 <read>
    if(cc < 1)
 1cd:	83 c4 10             	add    $0x10,%esp
 1d0:	85 c0                	test   %eax,%eax
 1d2:	7e 17                	jle    1eb <gets+0x47>
      break;
    buf[i++] = c;
 1d4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1d8:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1db:	3c 0a                	cmp    $0xa,%al
 1dd:	0f 94 c2             	sete   %dl
 1e0:	3c 0d                	cmp    $0xd,%al
 1e2:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1e5:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1e7:	08 c2                	or     %al,%dl
 1e9:	74 ca                	je     1b5 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1eb:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1ef:	89 f8                	mov    %edi,%eax
 1f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1f4:	5b                   	pop    %ebx
 1f5:	5e                   	pop    %esi
 1f6:	5f                   	pop    %edi
 1f7:	5d                   	pop    %ebp
 1f8:	c3                   	ret    

000001f9 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	56                   	push   %esi
 1fd:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fe:	83 ec 08             	sub    $0x8,%esp
 201:	6a 00                	push   $0x0
 203:	ff 75 08             	pushl  0x8(%ebp)
 206:	e8 d0 00 00 00       	call   2db <open>
  if(fd < 0)
 20b:	83 c4 10             	add    $0x10,%esp
 20e:	85 c0                	test   %eax,%eax
 210:	78 24                	js     236 <stat+0x3d>
 212:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 214:	83 ec 08             	sub    $0x8,%esp
 217:	ff 75 0c             	pushl  0xc(%ebp)
 21a:	50                   	push   %eax
 21b:	e8 d3 00 00 00       	call   2f3 <fstat>
 220:	89 c6                	mov    %eax,%esi
  close(fd);
 222:	89 1c 24             	mov    %ebx,(%esp)
 225:	e8 99 00 00 00       	call   2c3 <close>
  return r;
 22a:	83 c4 10             	add    $0x10,%esp
}
 22d:	89 f0                	mov    %esi,%eax
 22f:	8d 65 f8             	lea    -0x8(%ebp),%esp
 232:	5b                   	pop    %ebx
 233:	5e                   	pop    %esi
 234:	5d                   	pop    %ebp
 235:	c3                   	ret    
    return -1;
 236:	be ff ff ff ff       	mov    $0xffffffff,%esi
 23b:	eb f0                	jmp    22d <stat+0x34>

0000023d <atoi>:

int
atoi(const char *s)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
 240:	53                   	push   %ebx
 241:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 244:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 249:	eb 10                	jmp    25b <atoi+0x1e>
    n = n*10 + *s++ - '0';
 24b:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 24e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 251:	83 c1 01             	add    $0x1,%ecx
 254:	0f be d2             	movsbl %dl,%edx
 257:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 25b:	0f b6 11             	movzbl (%ecx),%edx
 25e:	8d 5a d0             	lea    -0x30(%edx),%ebx
 261:	80 fb 09             	cmp    $0x9,%bl
 264:	76 e5                	jbe    24b <atoi+0xe>
  return n;
}
 266:	5b                   	pop    %ebx
 267:	5d                   	pop    %ebp
 268:	c3                   	ret    

00000269 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
 26c:	56                   	push   %esi
 26d:	53                   	push   %ebx
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
 271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 274:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 277:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 279:	eb 0d                	jmp    288 <memmove+0x1f>
    *dst++ = *src++;
 27b:	0f b6 13             	movzbl (%ebx),%edx
 27e:	88 11                	mov    %dl,(%ecx)
 280:	8d 5b 01             	lea    0x1(%ebx),%ebx
 283:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 286:	89 f2                	mov    %esi,%edx
 288:	8d 72 ff             	lea    -0x1(%edx),%esi
 28b:	85 d2                	test   %edx,%edx
 28d:	7f ec                	jg     27b <memmove+0x12>
  return vdst;
}
 28f:	5b                   	pop    %ebx
 290:	5e                   	pop    %esi
 291:	5d                   	pop    %ebp
 292:	c3                   	ret    

00000293 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 293:	b8 01 00 00 00       	mov    $0x1,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <exit>:
SYSCALL(exit)
 29b:	b8 02 00 00 00       	mov    $0x2,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <wait>:
SYSCALL(wait)
 2a3:	b8 03 00 00 00       	mov    $0x3,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <pipe>:
SYSCALL(pipe)
 2ab:	b8 04 00 00 00       	mov    $0x4,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <read>:
SYSCALL(read)
 2b3:	b8 05 00 00 00       	mov    $0x5,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <write>:
SYSCALL(write)
 2bb:	b8 10 00 00 00       	mov    $0x10,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <close>:
SYSCALL(close)
 2c3:	b8 15 00 00 00       	mov    $0x15,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <kill>:
SYSCALL(kill)
 2cb:	b8 06 00 00 00       	mov    $0x6,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <exec>:
SYSCALL(exec)
 2d3:	b8 07 00 00 00       	mov    $0x7,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <open>:
SYSCALL(open)
 2db:	b8 0f 00 00 00       	mov    $0xf,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <mknod>:
SYSCALL(mknod)
 2e3:	b8 11 00 00 00       	mov    $0x11,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <unlink>:
SYSCALL(unlink)
 2eb:	b8 12 00 00 00       	mov    $0x12,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <fstat>:
SYSCALL(fstat)
 2f3:	b8 08 00 00 00       	mov    $0x8,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <link>:
SYSCALL(link)
 2fb:	b8 13 00 00 00       	mov    $0x13,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <mkdir>:
SYSCALL(mkdir)
 303:	b8 14 00 00 00       	mov    $0x14,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <chdir>:
SYSCALL(chdir)
 30b:	b8 09 00 00 00       	mov    $0x9,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <dup>:
SYSCALL(dup)
 313:	b8 0a 00 00 00       	mov    $0xa,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <getpid>:
SYSCALL(getpid)
 31b:	b8 0b 00 00 00       	mov    $0xb,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <sbrk>:
SYSCALL(sbrk)
 323:	b8 0c 00 00 00       	mov    $0xc,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <sleep>:
SYSCALL(sleep)
 32b:	b8 0d 00 00 00       	mov    $0xd,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <uptime>:
SYSCALL(uptime)
 333:	b8 0e 00 00 00       	mov    $0xe,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <setpri>:
SYSCALL(setpri)
 33b:	b8 16 00 00 00       	mov    $0x16,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <getpri>:
SYSCALL(getpri)
 343:	b8 17 00 00 00       	mov    $0x17,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <getpinfo>:
SYSCALL(getpinfo)
 34b:	b8 18 00 00 00       	mov    $0x18,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <fork2>:
SYSCALL(fork2)
 353:	b8 19 00 00 00       	mov    $0x19,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 35b:	55                   	push   %ebp
 35c:	89 e5                	mov    %esp,%ebp
 35e:	83 ec 1c             	sub    $0x1c,%esp
 361:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 364:	6a 01                	push   $0x1
 366:	8d 55 f4             	lea    -0xc(%ebp),%edx
 369:	52                   	push   %edx
 36a:	50                   	push   %eax
 36b:	e8 4b ff ff ff       	call   2bb <write>
}
 370:	83 c4 10             	add    $0x10,%esp
 373:	c9                   	leave  
 374:	c3                   	ret    

00000375 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 375:	55                   	push   %ebp
 376:	89 e5                	mov    %esp,%ebp
 378:	57                   	push   %edi
 379:	56                   	push   %esi
 37a:	53                   	push   %ebx
 37b:	83 ec 2c             	sub    $0x2c,%esp
 37e:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 380:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 384:	0f 95 c3             	setne  %bl
 387:	89 d0                	mov    %edx,%eax
 389:	c1 e8 1f             	shr    $0x1f,%eax
 38c:	84 c3                	test   %al,%bl
 38e:	74 10                	je     3a0 <printint+0x2b>
    neg = 1;
    x = -xx;
 390:	f7 da                	neg    %edx
    neg = 1;
 392:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 399:	be 00 00 00 00       	mov    $0x0,%esi
 39e:	eb 0b                	jmp    3ab <printint+0x36>
  neg = 0;
 3a0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3a7:	eb f0                	jmp    399 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3a9:	89 c6                	mov    %eax,%esi
 3ab:	89 d0                	mov    %edx,%eax
 3ad:	ba 00 00 00 00       	mov    $0x0,%edx
 3b2:	f7 f1                	div    %ecx
 3b4:	89 c3                	mov    %eax,%ebx
 3b6:	8d 46 01             	lea    0x1(%esi),%eax
 3b9:	0f b6 92 e4 06 00 00 	movzbl 0x6e4(%edx),%edx
 3c0:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3c4:	89 da                	mov    %ebx,%edx
 3c6:	85 db                	test   %ebx,%ebx
 3c8:	75 df                	jne    3a9 <printint+0x34>
 3ca:	89 c3                	mov    %eax,%ebx
  if(neg)
 3cc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3d0:	74 16                	je     3e8 <printint+0x73>
    buf[i++] = '-';
 3d2:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3d7:	8d 5e 02             	lea    0x2(%esi),%ebx
 3da:	eb 0c                	jmp    3e8 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3dc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3e1:	89 f8                	mov    %edi,%eax
 3e3:	e8 73 ff ff ff       	call   35b <putc>
  while(--i >= 0)
 3e8:	83 eb 01             	sub    $0x1,%ebx
 3eb:	79 ef                	jns    3dc <printint+0x67>
}
 3ed:	83 c4 2c             	add    $0x2c,%esp
 3f0:	5b                   	pop    %ebx
 3f1:	5e                   	pop    %esi
 3f2:	5f                   	pop    %edi
 3f3:	5d                   	pop    %ebp
 3f4:	c3                   	ret    

000003f5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	57                   	push   %edi
 3f9:	56                   	push   %esi
 3fa:	53                   	push   %ebx
 3fb:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3fe:	8d 45 10             	lea    0x10(%ebp),%eax
 401:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 404:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 409:	bb 00 00 00 00       	mov    $0x0,%ebx
 40e:	eb 14                	jmp    424 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 410:	89 fa                	mov    %edi,%edx
 412:	8b 45 08             	mov    0x8(%ebp),%eax
 415:	e8 41 ff ff ff       	call   35b <putc>
 41a:	eb 05                	jmp    421 <printf+0x2c>
      }
    } else if(state == '%'){
 41c:	83 fe 25             	cmp    $0x25,%esi
 41f:	74 25                	je     446 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 421:	83 c3 01             	add    $0x1,%ebx
 424:	8b 45 0c             	mov    0xc(%ebp),%eax
 427:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 42b:	84 c0                	test   %al,%al
 42d:	0f 84 23 01 00 00    	je     556 <printf+0x161>
    c = fmt[i] & 0xff;
 433:	0f be f8             	movsbl %al,%edi
 436:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 439:	85 f6                	test   %esi,%esi
 43b:	75 df                	jne    41c <printf+0x27>
      if(c == '%'){
 43d:	83 f8 25             	cmp    $0x25,%eax
 440:	75 ce                	jne    410 <printf+0x1b>
        state = '%';
 442:	89 c6                	mov    %eax,%esi
 444:	eb db                	jmp    421 <printf+0x2c>
      if(c == 'd'){
 446:	83 f8 64             	cmp    $0x64,%eax
 449:	74 49                	je     494 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 44b:	83 f8 78             	cmp    $0x78,%eax
 44e:	0f 94 c1             	sete   %cl
 451:	83 f8 70             	cmp    $0x70,%eax
 454:	0f 94 c2             	sete   %dl
 457:	08 d1                	or     %dl,%cl
 459:	75 63                	jne    4be <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 45b:	83 f8 73             	cmp    $0x73,%eax
 45e:	0f 84 84 00 00 00    	je     4e8 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 464:	83 f8 63             	cmp    $0x63,%eax
 467:	0f 84 b7 00 00 00    	je     524 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 46d:	83 f8 25             	cmp    $0x25,%eax
 470:	0f 84 cc 00 00 00    	je     542 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 476:	ba 25 00 00 00       	mov    $0x25,%edx
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	e8 d8 fe ff ff       	call   35b <putc>
        putc(fd, c);
 483:	89 fa                	mov    %edi,%edx
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	e8 ce fe ff ff       	call   35b <putc>
      }
      state = 0;
 48d:	be 00 00 00 00       	mov    $0x0,%esi
 492:	eb 8d                	jmp    421 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 497:	8b 17                	mov    (%edi),%edx
 499:	83 ec 0c             	sub    $0xc,%esp
 49c:	6a 01                	push   $0x1
 49e:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4a3:	8b 45 08             	mov    0x8(%ebp),%eax
 4a6:	e8 ca fe ff ff       	call   375 <printint>
        ap++;
 4ab:	83 c7 04             	add    $0x4,%edi
 4ae:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4b1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4b4:	be 00 00 00 00       	mov    $0x0,%esi
 4b9:	e9 63 ff ff ff       	jmp    421 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c1:	8b 17                	mov    (%edi),%edx
 4c3:	83 ec 0c             	sub    $0xc,%esp
 4c6:	6a 00                	push   $0x0
 4c8:	b9 10 00 00 00       	mov    $0x10,%ecx
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	e8 a0 fe ff ff       	call   375 <printint>
        ap++;
 4d5:	83 c7 04             	add    $0x4,%edi
 4d8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4db:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4de:	be 00 00 00 00       	mov    $0x0,%esi
 4e3:	e9 39 ff ff ff       	jmp    421 <printf+0x2c>
        s = (char*)*ap;
 4e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4eb:	8b 30                	mov    (%eax),%esi
        ap++;
 4ed:	83 c0 04             	add    $0x4,%eax
 4f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4f3:	85 f6                	test   %esi,%esi
 4f5:	75 28                	jne    51f <printf+0x12a>
          s = "(null)";
 4f7:	be dd 06 00 00       	mov    $0x6dd,%esi
 4fc:	8b 7d 08             	mov    0x8(%ebp),%edi
 4ff:	eb 0d                	jmp    50e <printf+0x119>
          putc(fd, *s);
 501:	0f be d2             	movsbl %dl,%edx
 504:	89 f8                	mov    %edi,%eax
 506:	e8 50 fe ff ff       	call   35b <putc>
          s++;
 50b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 50e:	0f b6 16             	movzbl (%esi),%edx
 511:	84 d2                	test   %dl,%dl
 513:	75 ec                	jne    501 <printf+0x10c>
      state = 0;
 515:	be 00 00 00 00       	mov    $0x0,%esi
 51a:	e9 02 ff ff ff       	jmp    421 <printf+0x2c>
 51f:	8b 7d 08             	mov    0x8(%ebp),%edi
 522:	eb ea                	jmp    50e <printf+0x119>
        putc(fd, *ap);
 524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 527:	0f be 17             	movsbl (%edi),%edx
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	e8 29 fe ff ff       	call   35b <putc>
        ap++;
 532:	83 c7 04             	add    $0x4,%edi
 535:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 538:	be 00 00 00 00       	mov    $0x0,%esi
 53d:	e9 df fe ff ff       	jmp    421 <printf+0x2c>
        putc(fd, c);
 542:	89 fa                	mov    %edi,%edx
 544:	8b 45 08             	mov    0x8(%ebp),%eax
 547:	e8 0f fe ff ff       	call   35b <putc>
      state = 0;
 54c:	be 00 00 00 00       	mov    $0x0,%esi
 551:	e9 cb fe ff ff       	jmp    421 <printf+0x2c>
    }
  }
}
 556:	8d 65 f4             	lea    -0xc(%ebp),%esp
 559:	5b                   	pop    %ebx
 55a:	5e                   	pop    %esi
 55b:	5f                   	pop    %edi
 55c:	5d                   	pop    %ebp
 55d:	c3                   	ret    

0000055e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 55e:	55                   	push   %ebp
 55f:	89 e5                	mov    %esp,%ebp
 561:	57                   	push   %edi
 562:	56                   	push   %esi
 563:	53                   	push   %ebx
 564:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 567:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 56a:	a1 a8 09 00 00       	mov    0x9a8,%eax
 56f:	eb 02                	jmp    573 <free+0x15>
 571:	89 d0                	mov    %edx,%eax
 573:	39 c8                	cmp    %ecx,%eax
 575:	73 04                	jae    57b <free+0x1d>
 577:	39 08                	cmp    %ecx,(%eax)
 579:	77 12                	ja     58d <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 57b:	8b 10                	mov    (%eax),%edx
 57d:	39 c2                	cmp    %eax,%edx
 57f:	77 f0                	ja     571 <free+0x13>
 581:	39 c8                	cmp    %ecx,%eax
 583:	72 08                	jb     58d <free+0x2f>
 585:	39 ca                	cmp    %ecx,%edx
 587:	77 04                	ja     58d <free+0x2f>
 589:	89 d0                	mov    %edx,%eax
 58b:	eb e6                	jmp    573 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 58d:	8b 73 fc             	mov    -0x4(%ebx),%esi
 590:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 593:	8b 10                	mov    (%eax),%edx
 595:	39 d7                	cmp    %edx,%edi
 597:	74 19                	je     5b2 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 599:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 59c:	8b 50 04             	mov    0x4(%eax),%edx
 59f:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5a2:	39 ce                	cmp    %ecx,%esi
 5a4:	74 1b                	je     5c1 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5a6:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5a8:	a3 a8 09 00 00       	mov    %eax,0x9a8
}
 5ad:	5b                   	pop    %ebx
 5ae:	5e                   	pop    %esi
 5af:	5f                   	pop    %edi
 5b0:	5d                   	pop    %ebp
 5b1:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5b2:	03 72 04             	add    0x4(%edx),%esi
 5b5:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5b8:	8b 10                	mov    (%eax),%edx
 5ba:	8b 12                	mov    (%edx),%edx
 5bc:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5bf:	eb db                	jmp    59c <free+0x3e>
    p->s.size += bp->s.size;
 5c1:	03 53 fc             	add    -0x4(%ebx),%edx
 5c4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5c7:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5ca:	89 10                	mov    %edx,(%eax)
 5cc:	eb da                	jmp    5a8 <free+0x4a>

000005ce <morecore>:

static Header*
morecore(uint nu)
{
 5ce:	55                   	push   %ebp
 5cf:	89 e5                	mov    %esp,%ebp
 5d1:	53                   	push   %ebx
 5d2:	83 ec 04             	sub    $0x4,%esp
 5d5:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5d7:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5dc:	77 05                	ja     5e3 <morecore+0x15>
    nu = 4096;
 5de:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5e3:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5ea:	83 ec 0c             	sub    $0xc,%esp
 5ed:	50                   	push   %eax
 5ee:	e8 30 fd ff ff       	call   323 <sbrk>
  if(p == (char*)-1)
 5f3:	83 c4 10             	add    $0x10,%esp
 5f6:	83 f8 ff             	cmp    $0xffffffff,%eax
 5f9:	74 1c                	je     617 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5fb:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5fe:	83 c0 08             	add    $0x8,%eax
 601:	83 ec 0c             	sub    $0xc,%esp
 604:	50                   	push   %eax
 605:	e8 54 ff ff ff       	call   55e <free>
  return freep;
 60a:	a1 a8 09 00 00       	mov    0x9a8,%eax
 60f:	83 c4 10             	add    $0x10,%esp
}
 612:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 615:	c9                   	leave  
 616:	c3                   	ret    
    return 0;
 617:	b8 00 00 00 00       	mov    $0x0,%eax
 61c:	eb f4                	jmp    612 <morecore+0x44>

0000061e <malloc>:

void*
malloc(uint nbytes)
{
 61e:	55                   	push   %ebp
 61f:	89 e5                	mov    %esp,%ebp
 621:	53                   	push   %ebx
 622:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 625:	8b 45 08             	mov    0x8(%ebp),%eax
 628:	8d 58 07             	lea    0x7(%eax),%ebx
 62b:	c1 eb 03             	shr    $0x3,%ebx
 62e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 631:	8b 0d a8 09 00 00    	mov    0x9a8,%ecx
 637:	85 c9                	test   %ecx,%ecx
 639:	74 04                	je     63f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 63b:	8b 01                	mov    (%ecx),%eax
 63d:	eb 4d                	jmp    68c <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 63f:	c7 05 a8 09 00 00 ac 	movl   $0x9ac,0x9a8
 646:	09 00 00 
 649:	c7 05 ac 09 00 00 ac 	movl   $0x9ac,0x9ac
 650:	09 00 00 
    base.s.size = 0;
 653:	c7 05 b0 09 00 00 00 	movl   $0x0,0x9b0
 65a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 65d:	b9 ac 09 00 00       	mov    $0x9ac,%ecx
 662:	eb d7                	jmp    63b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 664:	39 da                	cmp    %ebx,%edx
 666:	74 1a                	je     682 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 668:	29 da                	sub    %ebx,%edx
 66a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 66d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 670:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 673:	89 0d a8 09 00 00    	mov    %ecx,0x9a8
      return (void*)(p + 1);
 679:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 67c:	83 c4 04             	add    $0x4,%esp
 67f:	5b                   	pop    %ebx
 680:	5d                   	pop    %ebp
 681:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 682:	8b 10                	mov    (%eax),%edx
 684:	89 11                	mov    %edx,(%ecx)
 686:	eb eb                	jmp    673 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 688:	89 c1                	mov    %eax,%ecx
 68a:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 68c:	8b 50 04             	mov    0x4(%eax),%edx
 68f:	39 da                	cmp    %ebx,%edx
 691:	73 d1                	jae    664 <malloc+0x46>
    if(p == freep)
 693:	39 05 a8 09 00 00    	cmp    %eax,0x9a8
 699:	75 ed                	jne    688 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 69b:	89 d8                	mov    %ebx,%eax
 69d:	e8 2c ff ff ff       	call   5ce <morecore>
 6a2:	85 c0                	test   %eax,%eax
 6a4:	75 e2                	jne    688 <malloc+0x6a>
        return 0;
 6a6:	b8 00 00 00 00       	mov    $0x0,%eax
 6ab:	eb cf                	jmp    67c <malloc+0x5e>
