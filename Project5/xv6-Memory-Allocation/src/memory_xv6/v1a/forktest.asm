
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, const char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
   7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  write(fd, s, strlen(s));
   a:	53                   	push   %ebx
   b:	e8 2a 01 00 00       	call   13a <strlen>
  10:	83 c4 0c             	add    $0xc,%esp
  13:	50                   	push   %eax
  14:	53                   	push   %ebx
  15:	ff 75 08             	pushl  0x8(%ebp)
  18:	e8 86 02 00 00       	call   2a3 <write>
}
  1d:	83 c4 10             	add    $0x10,%esp
  20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  23:	c9                   	leave  
  24:	c3                   	ret    

00000025 <forktest>:

void
forktest(void)
{
  25:	55                   	push   %ebp
  26:	89 e5                	mov    %esp,%ebp
  28:	53                   	push   %ebx
  29:	83 ec 0c             	sub    $0xc,%esp
  int n, pid;

  printf(1, "fork test\n");
  2c:	68 2c 03 00 00       	push   $0x32c
  31:	6a 01                	push   $0x1
  33:	e8 c8 ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  38:	83 c4 10             	add    $0x10,%esp
  3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  40:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  46:	7f 17                	jg     5f <forktest+0x3a>
    pid = fork();
  48:	e8 2e 02 00 00       	call   27b <fork>
    if(pid < 0)
  4d:	85 c0                	test   %eax,%eax
  4f:	78 0e                	js     5f <forktest+0x3a>
      break;
    if(pid == 0)
  51:	85 c0                	test   %eax,%eax
  53:	74 05                	je     5a <forktest+0x35>
  for(n=0; n<N; n++){
  55:	83 c3 01             	add    $0x1,%ebx
  58:	eb e6                	jmp    40 <forktest+0x1b>
      exit();
  5a:	e8 24 02 00 00       	call   283 <exit>
  }

  if(n == N){
  5f:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  65:	74 12                	je     79 <forktest+0x54>
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
  67:	85 db                	test   %ebx,%ebx
  69:	7e 3b                	jle    a6 <forktest+0x81>
    if(wait() < 0){
  6b:	e8 1b 02 00 00       	call   28b <wait>
  70:	85 c0                	test   %eax,%eax
  72:	78 1e                	js     92 <forktest+0x6d>
  for(; n > 0; n--){
  74:	83 eb 01             	sub    $0x1,%ebx
  77:	eb ee                	jmp    67 <forktest+0x42>
    printf(1, "fork claimed to work N times!\n", N);
  79:	83 ec 04             	sub    $0x4,%esp
  7c:	68 e8 03 00 00       	push   $0x3e8
  81:	68 6c 03 00 00       	push   $0x36c
  86:	6a 01                	push   $0x1
  88:	e8 73 ff ff ff       	call   0 <printf>
    exit();
  8d:	e8 f1 01 00 00       	call   283 <exit>
      printf(1, "wait stopped early\n");
  92:	83 ec 08             	sub    $0x8,%esp
  95:	68 37 03 00 00       	push   $0x337
  9a:	6a 01                	push   $0x1
  9c:	e8 5f ff ff ff       	call   0 <printf>
      exit();
  a1:	e8 dd 01 00 00       	call   283 <exit>
    }
  }

  if(wait() != -1){
  a6:	e8 e0 01 00 00       	call   28b <wait>
  ab:	83 f8 ff             	cmp    $0xffffffff,%eax
  ae:	75 17                	jne    c7 <forktest+0xa2>
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "fork test OK\n");
  b0:	83 ec 08             	sub    $0x8,%esp
  b3:	68 5e 03 00 00       	push   $0x35e
  b8:	6a 01                	push   $0x1
  ba:	e8 41 ff ff ff       	call   0 <printf>
}
  bf:	83 c4 10             	add    $0x10,%esp
  c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  c5:	c9                   	leave  
  c6:	c3                   	ret    
    printf(1, "wait got too many\n");
  c7:	83 ec 08             	sub    $0x8,%esp
  ca:	68 4b 03 00 00       	push   $0x34b
  cf:	6a 01                	push   $0x1
  d1:	e8 2a ff ff ff       	call   0 <printf>
    exit();
  d6:	e8 a8 01 00 00       	call   283 <exit>

000000db <main>:

int
main(void)
{
  db:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  df:	83 e4 f0             	and    $0xfffffff0,%esp
  e2:	ff 71 fc             	pushl  -0x4(%ecx)
  e5:	55                   	push   %ebp
  e6:	89 e5                	mov    %esp,%ebp
  e8:	51                   	push   %ecx
  e9:	83 ec 04             	sub    $0x4,%esp
  forktest();
  ec:	e8 34 ff ff ff       	call   25 <forktest>
  exit();
  f1:	e8 8d 01 00 00       	call   283 <exit>

000000f6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  f9:	53                   	push   %ebx
  fa:	8b 45 08             	mov    0x8(%ebp),%eax
  fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 100:	89 c2                	mov    %eax,%edx
 102:	0f b6 19             	movzbl (%ecx),%ebx
 105:	88 1a                	mov    %bl,(%edx)
 107:	8d 52 01             	lea    0x1(%edx),%edx
 10a:	8d 49 01             	lea    0x1(%ecx),%ecx
 10d:	84 db                	test   %bl,%bl
 10f:	75 f1                	jne    102 <strcpy+0xc>
    ;
  return os;
}
 111:	5b                   	pop    %ebx
 112:	5d                   	pop    %ebp
 113:	c3                   	ret    

00000114 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11a:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 11d:	eb 06                	jmp    125 <strcmp+0x11>
    p++, q++;
 11f:	83 c1 01             	add    $0x1,%ecx
 122:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 125:	0f b6 01             	movzbl (%ecx),%eax
 128:	84 c0                	test   %al,%al
 12a:	74 04                	je     130 <strcmp+0x1c>
 12c:	3a 02                	cmp    (%edx),%al
 12e:	74 ef                	je     11f <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 130:	0f b6 c0             	movzbl %al,%eax
 133:	0f b6 12             	movzbl (%edx),%edx
 136:	29 d0                	sub    %edx,%eax
}
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    

0000013a <strlen>:

uint
strlen(const char *s)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 140:	ba 00 00 00 00       	mov    $0x0,%edx
 145:	eb 03                	jmp    14a <strlen+0x10>
 147:	83 c2 01             	add    $0x1,%edx
 14a:	89 d0                	mov    %edx,%eax
 14c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 150:	75 f5                	jne    147 <strlen+0xd>
    ;
  return n;
}
 152:	5d                   	pop    %ebp
 153:	c3                   	ret    

00000154 <memset>:

void*
memset(void *dst, int c, uint n)
{
 154:	55                   	push   %ebp
 155:	89 e5                	mov    %esp,%ebp
 157:	57                   	push   %edi
 158:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 15b:	89 d7                	mov    %edx,%edi
 15d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 160:	8b 45 0c             	mov    0xc(%ebp),%eax
 163:	fc                   	cld    
 164:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 166:	89 d0                	mov    %edx,%eax
 168:	5f                   	pop    %edi
 169:	5d                   	pop    %ebp
 16a:	c3                   	ret    

0000016b <strchr>:

char*
strchr(const char *s, char c)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 175:	0f b6 10             	movzbl (%eax),%edx
 178:	84 d2                	test   %dl,%dl
 17a:	74 09                	je     185 <strchr+0x1a>
    if(*s == c)
 17c:	38 ca                	cmp    %cl,%dl
 17e:	74 0a                	je     18a <strchr+0x1f>
  for(; *s; s++)
 180:	83 c0 01             	add    $0x1,%eax
 183:	eb f0                	jmp    175 <strchr+0xa>
      return (char*)s;
  return 0;
 185:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18a:	5d                   	pop    %ebp
 18b:	c3                   	ret    

0000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	57                   	push   %edi
 190:	56                   	push   %esi
 191:	53                   	push   %ebx
 192:	83 ec 1c             	sub    $0x1c,%esp
 195:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 198:	bb 00 00 00 00       	mov    $0x0,%ebx
 19d:	8d 73 01             	lea    0x1(%ebx),%esi
 1a0:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1a3:	7d 2e                	jge    1d3 <gets+0x47>
    cc = read(0, &c, 1);
 1a5:	83 ec 04             	sub    $0x4,%esp
 1a8:	6a 01                	push   $0x1
 1aa:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1ad:	50                   	push   %eax
 1ae:	6a 00                	push   $0x0
 1b0:	e8 e6 00 00 00       	call   29b <read>
    if(cc < 1)
 1b5:	83 c4 10             	add    $0x10,%esp
 1b8:	85 c0                	test   %eax,%eax
 1ba:	7e 17                	jle    1d3 <gets+0x47>
      break;
    buf[i++] = c;
 1bc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1c0:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1c3:	3c 0a                	cmp    $0xa,%al
 1c5:	0f 94 c2             	sete   %dl
 1c8:	3c 0d                	cmp    $0xd,%al
 1ca:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1cd:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1cf:	08 c2                	or     %al,%dl
 1d1:	74 ca                	je     19d <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1d3:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1d7:	89 f8                	mov    %edi,%eax
 1d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1dc:	5b                   	pop    %ebx
 1dd:	5e                   	pop    %esi
 1de:	5f                   	pop    %edi
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	56                   	push   %esi
 1e5:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e6:	83 ec 08             	sub    $0x8,%esp
 1e9:	6a 00                	push   $0x0
 1eb:	ff 75 08             	pushl  0x8(%ebp)
 1ee:	e8 d0 00 00 00       	call   2c3 <open>
  if(fd < 0)
 1f3:	83 c4 10             	add    $0x10,%esp
 1f6:	85 c0                	test   %eax,%eax
 1f8:	78 24                	js     21e <stat+0x3d>
 1fa:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1fc:	83 ec 08             	sub    $0x8,%esp
 1ff:	ff 75 0c             	pushl  0xc(%ebp)
 202:	50                   	push   %eax
 203:	e8 d3 00 00 00       	call   2db <fstat>
 208:	89 c6                	mov    %eax,%esi
  close(fd);
 20a:	89 1c 24             	mov    %ebx,(%esp)
 20d:	e8 99 00 00 00       	call   2ab <close>
  return r;
 212:	83 c4 10             	add    $0x10,%esp
}
 215:	89 f0                	mov    %esi,%eax
 217:	8d 65 f8             	lea    -0x8(%ebp),%esp
 21a:	5b                   	pop    %ebx
 21b:	5e                   	pop    %esi
 21c:	5d                   	pop    %ebp
 21d:	c3                   	ret    
    return -1;
 21e:	be ff ff ff ff       	mov    $0xffffffff,%esi
 223:	eb f0                	jmp    215 <stat+0x34>

00000225 <atoi>:

int
atoi(const char *s)
{
 225:	55                   	push   %ebp
 226:	89 e5                	mov    %esp,%ebp
 228:	53                   	push   %ebx
 229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 22c:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 231:	eb 10                	jmp    243 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 233:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 236:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 239:	83 c1 01             	add    $0x1,%ecx
 23c:	0f be d2             	movsbl %dl,%edx
 23f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 243:	0f b6 11             	movzbl (%ecx),%edx
 246:	8d 5a d0             	lea    -0x30(%edx),%ebx
 249:	80 fb 09             	cmp    $0x9,%bl
 24c:	76 e5                	jbe    233 <atoi+0xe>
  return n;
}
 24e:	5b                   	pop    %ebx
 24f:	5d                   	pop    %ebp
 250:	c3                   	ret    

00000251 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	56                   	push   %esi
 255:	53                   	push   %ebx
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 25c:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 25f:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 261:	eb 0d                	jmp    270 <memmove+0x1f>
    *dst++ = *src++;
 263:	0f b6 13             	movzbl (%ebx),%edx
 266:	88 11                	mov    %dl,(%ecx)
 268:	8d 5b 01             	lea    0x1(%ebx),%ebx
 26b:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 26e:	89 f2                	mov    %esi,%edx
 270:	8d 72 ff             	lea    -0x1(%edx),%esi
 273:	85 d2                	test   %edx,%edx
 275:	7f ec                	jg     263 <memmove+0x12>
  return vdst;
}
 277:	5b                   	pop    %ebx
 278:	5e                   	pop    %esi
 279:	5d                   	pop    %ebp
 27a:	c3                   	ret    

0000027b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27b:	b8 01 00 00 00       	mov    $0x1,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <exit>:
SYSCALL(exit)
 283:	b8 02 00 00 00       	mov    $0x2,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <wait>:
SYSCALL(wait)
 28b:	b8 03 00 00 00       	mov    $0x3,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <pipe>:
SYSCALL(pipe)
 293:	b8 04 00 00 00       	mov    $0x4,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <read>:
SYSCALL(read)
 29b:	b8 05 00 00 00       	mov    $0x5,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <write>:
SYSCALL(write)
 2a3:	b8 10 00 00 00       	mov    $0x10,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <close>:
SYSCALL(close)
 2ab:	b8 15 00 00 00       	mov    $0x15,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <kill>:
SYSCALL(kill)
 2b3:	b8 06 00 00 00       	mov    $0x6,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <exec>:
SYSCALL(exec)
 2bb:	b8 07 00 00 00       	mov    $0x7,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <open>:
SYSCALL(open)
 2c3:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <mknod>:
SYSCALL(mknod)
 2cb:	b8 11 00 00 00       	mov    $0x11,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <unlink>:
SYSCALL(unlink)
 2d3:	b8 12 00 00 00       	mov    $0x12,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <fstat>:
SYSCALL(fstat)
 2db:	b8 08 00 00 00       	mov    $0x8,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <link>:
SYSCALL(link)
 2e3:	b8 13 00 00 00       	mov    $0x13,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <mkdir>:
SYSCALL(mkdir)
 2eb:	b8 14 00 00 00       	mov    $0x14,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <chdir>:
SYSCALL(chdir)
 2f3:	b8 09 00 00 00       	mov    $0x9,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <dup>:
SYSCALL(dup)
 2fb:	b8 0a 00 00 00       	mov    $0xa,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <getpid>:
SYSCALL(getpid)
 303:	b8 0b 00 00 00       	mov    $0xb,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <sbrk>:
SYSCALL(sbrk)
 30b:	b8 0c 00 00 00       	mov    $0xc,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <sleep>:
SYSCALL(sleep)
 313:	b8 0d 00 00 00       	mov    $0xd,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <uptime>:
SYSCALL(uptime)
 31b:	b8 0e 00 00 00       	mov    $0xe,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <dump_physmem>:
SYSCALL(dump_physmem)
 323:	b8 16 00 00 00       	mov    $0x16,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    
