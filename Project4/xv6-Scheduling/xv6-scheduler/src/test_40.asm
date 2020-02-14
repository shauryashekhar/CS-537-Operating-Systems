
_test_40:     file format elf32-i386


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
  36:	e8 2e 03 00 00       	call   369 <sleep>
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
  66:	56                   	push   %esi
  67:	53                   	push   %ebx
  68:	51                   	push   %ecx
  69:	83 ec 0c             	sub    $0xc,%esp
  for (int i = 0; i < 15; ++i) {
  6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  71:	83 fb 0e             	cmp    $0xe,%ebx
  74:	0f 8f c3 00 00 00    	jg     13d <main+0xe4>
    int pid = fork2(i % 4);
  7a:	89 da                	mov    %ebx,%edx
  7c:	c1 fa 1f             	sar    $0x1f,%edx
  7f:	c1 ea 1e             	shr    $0x1e,%edx
  82:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  85:	83 e0 03             	and    $0x3,%eax
  88:	29 d0                	sub    %edx,%eax
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	50                   	push   %eax
  8e:	e8 fe 02 00 00       	call   391 <fork2>
    if (pid == 0) {
  93:	83 c4 10             	add    $0x10,%esp
  96:	85 c0                	test   %eax,%eax
  98:	74 05                	je     9f <main+0x46>
  for (int i = 0; i < 15; ++i) {
  9a:	83 c3 01             	add    $0x1,%ebx
  9d:	eb d2                	jmp    71 <main+0x18>
      workload(10000 * i, 100);
  9f:	83 ec 08             	sub    $0x8,%esp
  a2:	6a 64                	push   $0x64
  a4:	69 c3 10 27 00 00    	imul   $0x2710,%ebx,%eax
  aa:	50                   	push   %eax
  ab:	e8 50 ff ff ff       	call   0 <workload>
      int pid2 = fork();
  b0:	e8 1c 02 00 00       	call   2d1 <fork>
      if (pid2 == 0) {
  b5:	83 c4 10             	add    $0x10,%esp
  b8:	85 c0                	test   %eax,%eax
  ba:	75 5c                	jne    118 <main+0xbf>
        int pid3 = fork2(i % 2);
  bc:	b9 02 00 00 00       	mov    $0x2,%ecx
  c1:	89 d8                	mov    %ebx,%eax
  c3:	99                   	cltd   
  c4:	f7 f9                	idiv   %ecx
  c6:	83 ec 0c             	sub    $0xc,%esp
  c9:	52                   	push   %edx
  ca:	e8 c2 02 00 00       	call   391 <fork2>
  cf:	89 c6                	mov    %eax,%esi
        workload(4567 * i, 8 * i);
  d1:	83 c4 08             	add    $0x8,%esp
  d4:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
  db:	50                   	push   %eax
  dc:	69 c3 d7 11 00 00    	imul   $0x11d7,%ebx,%eax
  e2:	50                   	push   %eax
  e3:	e8 18 ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  e8:	83 c4 10             	add    $0x10,%esp
  eb:	85 f6                	test   %esi,%esi
  ed:	75 05                	jne    f4 <main+0x9b>
          workload(i * 1000, i * i);
          while(wait() != -1);
        }
        exit();
  ef:	e8 e5 01 00 00       	call   2d9 <exit>
          workload(i * 1000, i * i);
  f4:	83 ec 08             	sub    $0x8,%esp
  f7:	89 d8                	mov    %ebx,%eax
  f9:	0f af c3             	imul   %ebx,%eax
  fc:	50                   	push   %eax
  fd:	69 db e8 03 00 00    	imul   $0x3e8,%ebx,%ebx
 103:	53                   	push   %ebx
 104:	e8 f7 fe ff ff       	call   0 <workload>
          while(wait() != -1);
 109:	83 c4 10             	add    $0x10,%esp
 10c:	e8 d0 01 00 00       	call   2e1 <wait>
 111:	83 f8 ff             	cmp    $0xffffffff,%eax
 114:	75 f6                	jne    10c <main+0xb3>
 116:	eb d7                	jmp    ef <main+0x96>
      } else {
        workload(5000 * i, 20 * i);
 118:	83 ec 08             	sub    $0x8,%esp
 11b:	6b c3 14             	imul   $0x14,%ebx,%eax
 11e:	50                   	push   %eax
 11f:	69 db 88 13 00 00    	imul   $0x1388,%ebx,%ebx
 125:	53                   	push   %ebx
 126:	e8 d5 fe ff ff       	call   0 <workload>
        while(wait() != -1);
 12b:	83 c4 10             	add    $0x10,%esp
 12e:	e8 ae 01 00 00       	call   2e1 <wait>
 133:	83 f8 ff             	cmp    $0xffffffff,%eax
 136:	75 f6                	jne    12e <main+0xd5>
        exit();
 138:	e8 9c 01 00 00       	call   2d9 <exit>
      }
    }
  }

  while(wait() != -1);
 13d:	e8 9f 01 00 00       	call   2e1 <wait>
 142:	83 f8 ff             	cmp    $0xffffffff,%eax
 145:	75 f6                	jne    13d <main+0xe4>
  exit();
 147:	e8 8d 01 00 00       	call   2d9 <exit>

0000014c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	53                   	push   %ebx
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 156:	89 c2                	mov    %eax,%edx
 158:	0f b6 19             	movzbl (%ecx),%ebx
 15b:	88 1a                	mov    %bl,(%edx)
 15d:	8d 52 01             	lea    0x1(%edx),%edx
 160:	8d 49 01             	lea    0x1(%ecx),%ecx
 163:	84 db                	test   %bl,%bl
 165:	75 f1                	jne    158 <strcpy+0xc>
    ;
  return os;
}
 167:	5b                   	pop    %ebx
 168:	5d                   	pop    %ebp
 169:	c3                   	ret    

0000016a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16a:	55                   	push   %ebp
 16b:	89 e5                	mov    %esp,%ebp
 16d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 170:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 173:	eb 06                	jmp    17b <strcmp+0x11>
    p++, q++;
 175:	83 c1 01             	add    $0x1,%ecx
 178:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 17b:	0f b6 01             	movzbl (%ecx),%eax
 17e:	84 c0                	test   %al,%al
 180:	74 04                	je     186 <strcmp+0x1c>
 182:	3a 02                	cmp    (%edx),%al
 184:	74 ef                	je     175 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 186:	0f b6 c0             	movzbl %al,%eax
 189:	0f b6 12             	movzbl (%edx),%edx
 18c:	29 d0                	sub    %edx,%eax
}
 18e:	5d                   	pop    %ebp
 18f:	c3                   	ret    

00000190 <strlen>:

uint
strlen(const char *s)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 196:	ba 00 00 00 00       	mov    $0x0,%edx
 19b:	eb 03                	jmp    1a0 <strlen+0x10>
 19d:	83 c2 01             	add    $0x1,%edx
 1a0:	89 d0                	mov    %edx,%eax
 1a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1a6:	75 f5                	jne    19d <strlen+0xd>
    ;
  return n;
}
 1a8:	5d                   	pop    %ebp
 1a9:	c3                   	ret    

000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	55                   	push   %ebp
 1ab:	89 e5                	mov    %esp,%ebp
 1ad:	57                   	push   %edi
 1ae:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1b1:	89 d7                	mov    %edx,%edi
 1b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b9:	fc                   	cld    
 1ba:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1bc:	89 d0                	mov    %edx,%eax
 1be:	5f                   	pop    %edi
 1bf:	5d                   	pop    %ebp
 1c0:	c3                   	ret    

000001c1 <strchr>:

char*
strchr(const char *s, char c)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1cb:	0f b6 10             	movzbl (%eax),%edx
 1ce:	84 d2                	test   %dl,%dl
 1d0:	74 09                	je     1db <strchr+0x1a>
    if(*s == c)
 1d2:	38 ca                	cmp    %cl,%dl
 1d4:	74 0a                	je     1e0 <strchr+0x1f>
  for(; *s; s++)
 1d6:	83 c0 01             	add    $0x1,%eax
 1d9:	eb f0                	jmp    1cb <strchr+0xa>
      return (char*)s;
  return 0;
 1db:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1e0:	5d                   	pop    %ebp
 1e1:	c3                   	ret    

000001e2 <gets>:

char*
gets(char *buf, int max)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	57                   	push   %edi
 1e6:	56                   	push   %esi
 1e7:	53                   	push   %ebx
 1e8:	83 ec 1c             	sub    $0x1c,%esp
 1eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ee:	bb 00 00 00 00       	mov    $0x0,%ebx
 1f3:	8d 73 01             	lea    0x1(%ebx),%esi
 1f6:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1f9:	7d 2e                	jge    229 <gets+0x47>
    cc = read(0, &c, 1);
 1fb:	83 ec 04             	sub    $0x4,%esp
 1fe:	6a 01                	push   $0x1
 200:	8d 45 e7             	lea    -0x19(%ebp),%eax
 203:	50                   	push   %eax
 204:	6a 00                	push   $0x0
 206:	e8 e6 00 00 00       	call   2f1 <read>
    if(cc < 1)
 20b:	83 c4 10             	add    $0x10,%esp
 20e:	85 c0                	test   %eax,%eax
 210:	7e 17                	jle    229 <gets+0x47>
      break;
    buf[i++] = c;
 212:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 216:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 219:	3c 0a                	cmp    $0xa,%al
 21b:	0f 94 c2             	sete   %dl
 21e:	3c 0d                	cmp    $0xd,%al
 220:	0f 94 c0             	sete   %al
    buf[i++] = c;
 223:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 225:	08 c2                	or     %al,%dl
 227:	74 ca                	je     1f3 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 229:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 22d:	89 f8                	mov    %edi,%eax
 22f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 232:	5b                   	pop    %ebx
 233:	5e                   	pop    %esi
 234:	5f                   	pop    %edi
 235:	5d                   	pop    %ebp
 236:	c3                   	ret    

00000237 <stat>:

int
stat(const char *n, struct stat *st)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	56                   	push   %esi
 23b:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23c:	83 ec 08             	sub    $0x8,%esp
 23f:	6a 00                	push   $0x0
 241:	ff 75 08             	pushl  0x8(%ebp)
 244:	e8 d0 00 00 00       	call   319 <open>
  if(fd < 0)
 249:	83 c4 10             	add    $0x10,%esp
 24c:	85 c0                	test   %eax,%eax
 24e:	78 24                	js     274 <stat+0x3d>
 250:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 252:	83 ec 08             	sub    $0x8,%esp
 255:	ff 75 0c             	pushl  0xc(%ebp)
 258:	50                   	push   %eax
 259:	e8 d3 00 00 00       	call   331 <fstat>
 25e:	89 c6                	mov    %eax,%esi
  close(fd);
 260:	89 1c 24             	mov    %ebx,(%esp)
 263:	e8 99 00 00 00       	call   301 <close>
  return r;
 268:	83 c4 10             	add    $0x10,%esp
}
 26b:	89 f0                	mov    %esi,%eax
 26d:	8d 65 f8             	lea    -0x8(%ebp),%esp
 270:	5b                   	pop    %ebx
 271:	5e                   	pop    %esi
 272:	5d                   	pop    %ebp
 273:	c3                   	ret    
    return -1;
 274:	be ff ff ff ff       	mov    $0xffffffff,%esi
 279:	eb f0                	jmp    26b <stat+0x34>

0000027b <atoi>:

int
atoi(const char *s)
{
 27b:	55                   	push   %ebp
 27c:	89 e5                	mov    %esp,%ebp
 27e:	53                   	push   %ebx
 27f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 282:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 287:	eb 10                	jmp    299 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 289:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 28c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 28f:	83 c1 01             	add    $0x1,%ecx
 292:	0f be d2             	movsbl %dl,%edx
 295:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 299:	0f b6 11             	movzbl (%ecx),%edx
 29c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 29f:	80 fb 09             	cmp    $0x9,%bl
 2a2:	76 e5                	jbe    289 <atoi+0xe>
  return n;
}
 2a4:	5b                   	pop    %ebx
 2a5:	5d                   	pop    %ebp
 2a6:	c3                   	ret    

000002a7 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
 2aa:	56                   	push   %esi
 2ab:	53                   	push   %ebx
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2b2:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2b5:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2b7:	eb 0d                	jmp    2c6 <memmove+0x1f>
    *dst++ = *src++;
 2b9:	0f b6 13             	movzbl (%ebx),%edx
 2bc:	88 11                	mov    %dl,(%ecx)
 2be:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2c1:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2c4:	89 f2                	mov    %esi,%edx
 2c6:	8d 72 ff             	lea    -0x1(%edx),%esi
 2c9:	85 d2                	test   %edx,%edx
 2cb:	7f ec                	jg     2b9 <memmove+0x12>
  return vdst;
}
 2cd:	5b                   	pop    %ebx
 2ce:	5e                   	pop    %esi
 2cf:	5d                   	pop    %ebp
 2d0:	c3                   	ret    

000002d1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d1:	b8 01 00 00 00       	mov    $0x1,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <exit>:
SYSCALL(exit)
 2d9:	b8 02 00 00 00       	mov    $0x2,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <wait>:
SYSCALL(wait)
 2e1:	b8 03 00 00 00       	mov    $0x3,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <pipe>:
SYSCALL(pipe)
 2e9:	b8 04 00 00 00       	mov    $0x4,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <read>:
SYSCALL(read)
 2f1:	b8 05 00 00 00       	mov    $0x5,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <write>:
SYSCALL(write)
 2f9:	b8 10 00 00 00       	mov    $0x10,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <close>:
SYSCALL(close)
 301:	b8 15 00 00 00       	mov    $0x15,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <kill>:
SYSCALL(kill)
 309:	b8 06 00 00 00       	mov    $0x6,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <exec>:
SYSCALL(exec)
 311:	b8 07 00 00 00       	mov    $0x7,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <open>:
SYSCALL(open)
 319:	b8 0f 00 00 00       	mov    $0xf,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <mknod>:
SYSCALL(mknod)
 321:	b8 11 00 00 00       	mov    $0x11,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <unlink>:
SYSCALL(unlink)
 329:	b8 12 00 00 00       	mov    $0x12,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <fstat>:
SYSCALL(fstat)
 331:	b8 08 00 00 00       	mov    $0x8,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <link>:
SYSCALL(link)
 339:	b8 13 00 00 00       	mov    $0x13,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <mkdir>:
SYSCALL(mkdir)
 341:	b8 14 00 00 00       	mov    $0x14,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <chdir>:
SYSCALL(chdir)
 349:	b8 09 00 00 00       	mov    $0x9,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <dup>:
SYSCALL(dup)
 351:	b8 0a 00 00 00       	mov    $0xa,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <getpid>:
SYSCALL(getpid)
 359:	b8 0b 00 00 00       	mov    $0xb,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <sbrk>:
SYSCALL(sbrk)
 361:	b8 0c 00 00 00       	mov    $0xc,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <sleep>:
SYSCALL(sleep)
 369:	b8 0d 00 00 00       	mov    $0xd,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <uptime>:
SYSCALL(uptime)
 371:	b8 0e 00 00 00       	mov    $0xe,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <setpri>:
SYSCALL(setpri)
 379:	b8 16 00 00 00       	mov    $0x16,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <getpri>:
SYSCALL(getpri)
 381:	b8 17 00 00 00       	mov    $0x17,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <getpinfo>:
SYSCALL(getpinfo)
 389:	b8 18 00 00 00       	mov    $0x18,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <fork2>:
SYSCALL(fork2)
 391:	b8 19 00 00 00       	mov    $0x19,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 399:	55                   	push   %ebp
 39a:	89 e5                	mov    %esp,%ebp
 39c:	83 ec 1c             	sub    $0x1c,%esp
 39f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3a2:	6a 01                	push   $0x1
 3a4:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3a7:	52                   	push   %edx
 3a8:	50                   	push   %eax
 3a9:	e8 4b ff ff ff       	call   2f9 <write>
}
 3ae:	83 c4 10             	add    $0x10,%esp
 3b1:	c9                   	leave  
 3b2:	c3                   	ret    

000003b3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b3:	55                   	push   %ebp
 3b4:	89 e5                	mov    %esp,%ebp
 3b6:	57                   	push   %edi
 3b7:	56                   	push   %esi
 3b8:	53                   	push   %ebx
 3b9:	83 ec 2c             	sub    $0x2c,%esp
 3bc:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3c2:	0f 95 c3             	setne  %bl
 3c5:	89 d0                	mov    %edx,%eax
 3c7:	c1 e8 1f             	shr    $0x1f,%eax
 3ca:	84 c3                	test   %al,%bl
 3cc:	74 10                	je     3de <printint+0x2b>
    neg = 1;
    x = -xx;
 3ce:	f7 da                	neg    %edx
    neg = 1;
 3d0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3d7:	be 00 00 00 00       	mov    $0x0,%esi
 3dc:	eb 0b                	jmp    3e9 <printint+0x36>
  neg = 0;
 3de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3e5:	eb f0                	jmp    3d7 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3e7:	89 c6                	mov    %eax,%esi
 3e9:	89 d0                	mov    %edx,%eax
 3eb:	ba 00 00 00 00       	mov    $0x0,%edx
 3f0:	f7 f1                	div    %ecx
 3f2:	89 c3                	mov    %eax,%ebx
 3f4:	8d 46 01             	lea    0x1(%esi),%eax
 3f7:	0f b6 92 f4 06 00 00 	movzbl 0x6f4(%edx),%edx
 3fe:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 402:	89 da                	mov    %ebx,%edx
 404:	85 db                	test   %ebx,%ebx
 406:	75 df                	jne    3e7 <printint+0x34>
 408:	89 c3                	mov    %eax,%ebx
  if(neg)
 40a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 40e:	74 16                	je     426 <printint+0x73>
    buf[i++] = '-';
 410:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 415:	8d 5e 02             	lea    0x2(%esi),%ebx
 418:	eb 0c                	jmp    426 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 41a:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 41f:	89 f8                	mov    %edi,%eax
 421:	e8 73 ff ff ff       	call   399 <putc>
  while(--i >= 0)
 426:	83 eb 01             	sub    $0x1,%ebx
 429:	79 ef                	jns    41a <printint+0x67>
}
 42b:	83 c4 2c             	add    $0x2c,%esp
 42e:	5b                   	pop    %ebx
 42f:	5e                   	pop    %esi
 430:	5f                   	pop    %edi
 431:	5d                   	pop    %ebp
 432:	c3                   	ret    

00000433 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	57                   	push   %edi
 437:	56                   	push   %esi
 438:	53                   	push   %ebx
 439:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 43c:	8d 45 10             	lea    0x10(%ebp),%eax
 43f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 442:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 447:	bb 00 00 00 00       	mov    $0x0,%ebx
 44c:	eb 14                	jmp    462 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 44e:	89 fa                	mov    %edi,%edx
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	e8 41 ff ff ff       	call   399 <putc>
 458:	eb 05                	jmp    45f <printf+0x2c>
      }
    } else if(state == '%'){
 45a:	83 fe 25             	cmp    $0x25,%esi
 45d:	74 25                	je     484 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 45f:	83 c3 01             	add    $0x1,%ebx
 462:	8b 45 0c             	mov    0xc(%ebp),%eax
 465:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 469:	84 c0                	test   %al,%al
 46b:	0f 84 23 01 00 00    	je     594 <printf+0x161>
    c = fmt[i] & 0xff;
 471:	0f be f8             	movsbl %al,%edi
 474:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 477:	85 f6                	test   %esi,%esi
 479:	75 df                	jne    45a <printf+0x27>
      if(c == '%'){
 47b:	83 f8 25             	cmp    $0x25,%eax
 47e:	75 ce                	jne    44e <printf+0x1b>
        state = '%';
 480:	89 c6                	mov    %eax,%esi
 482:	eb db                	jmp    45f <printf+0x2c>
      if(c == 'd'){
 484:	83 f8 64             	cmp    $0x64,%eax
 487:	74 49                	je     4d2 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 489:	83 f8 78             	cmp    $0x78,%eax
 48c:	0f 94 c1             	sete   %cl
 48f:	83 f8 70             	cmp    $0x70,%eax
 492:	0f 94 c2             	sete   %dl
 495:	08 d1                	or     %dl,%cl
 497:	75 63                	jne    4fc <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 499:	83 f8 73             	cmp    $0x73,%eax
 49c:	0f 84 84 00 00 00    	je     526 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4a2:	83 f8 63             	cmp    $0x63,%eax
 4a5:	0f 84 b7 00 00 00    	je     562 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4ab:	83 f8 25             	cmp    $0x25,%eax
 4ae:	0f 84 cc 00 00 00    	je     580 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4b4:	ba 25 00 00 00       	mov    $0x25,%edx
 4b9:	8b 45 08             	mov    0x8(%ebp),%eax
 4bc:	e8 d8 fe ff ff       	call   399 <putc>
        putc(fd, c);
 4c1:	89 fa                	mov    %edi,%edx
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	e8 ce fe ff ff       	call   399 <putc>
      }
      state = 0;
 4cb:	be 00 00 00 00       	mov    $0x0,%esi
 4d0:	eb 8d                	jmp    45f <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4d5:	8b 17                	mov    (%edi),%edx
 4d7:	83 ec 0c             	sub    $0xc,%esp
 4da:	6a 01                	push   $0x1
 4dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	e8 ca fe ff ff       	call   3b3 <printint>
        ap++;
 4e9:	83 c7 04             	add    $0x4,%edi
 4ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4ef:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4f2:	be 00 00 00 00       	mov    $0x0,%esi
 4f7:	e9 63 ff ff ff       	jmp    45f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ff:	8b 17                	mov    (%edi),%edx
 501:	83 ec 0c             	sub    $0xc,%esp
 504:	6a 00                	push   $0x0
 506:	b9 10 00 00 00       	mov    $0x10,%ecx
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	e8 a0 fe ff ff       	call   3b3 <printint>
        ap++;
 513:	83 c7 04             	add    $0x4,%edi
 516:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 519:	83 c4 10             	add    $0x10,%esp
      state = 0;
 51c:	be 00 00 00 00       	mov    $0x0,%esi
 521:	e9 39 ff ff ff       	jmp    45f <printf+0x2c>
        s = (char*)*ap;
 526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 529:	8b 30                	mov    (%eax),%esi
        ap++;
 52b:	83 c0 04             	add    $0x4,%eax
 52e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 531:	85 f6                	test   %esi,%esi
 533:	75 28                	jne    55d <printf+0x12a>
          s = "(null)";
 535:	be ec 06 00 00       	mov    $0x6ec,%esi
 53a:	8b 7d 08             	mov    0x8(%ebp),%edi
 53d:	eb 0d                	jmp    54c <printf+0x119>
          putc(fd, *s);
 53f:	0f be d2             	movsbl %dl,%edx
 542:	89 f8                	mov    %edi,%eax
 544:	e8 50 fe ff ff       	call   399 <putc>
          s++;
 549:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 54c:	0f b6 16             	movzbl (%esi),%edx
 54f:	84 d2                	test   %dl,%dl
 551:	75 ec                	jne    53f <printf+0x10c>
      state = 0;
 553:	be 00 00 00 00       	mov    $0x0,%esi
 558:	e9 02 ff ff ff       	jmp    45f <printf+0x2c>
 55d:	8b 7d 08             	mov    0x8(%ebp),%edi
 560:	eb ea                	jmp    54c <printf+0x119>
        putc(fd, *ap);
 562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 565:	0f be 17             	movsbl (%edi),%edx
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	e8 29 fe ff ff       	call   399 <putc>
        ap++;
 570:	83 c7 04             	add    $0x4,%edi
 573:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 576:	be 00 00 00 00       	mov    $0x0,%esi
 57b:	e9 df fe ff ff       	jmp    45f <printf+0x2c>
        putc(fd, c);
 580:	89 fa                	mov    %edi,%edx
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	e8 0f fe ff ff       	call   399 <putc>
      state = 0;
 58a:	be 00 00 00 00       	mov    $0x0,%esi
 58f:	e9 cb fe ff ff       	jmp    45f <printf+0x2c>
    }
  }
}
 594:	8d 65 f4             	lea    -0xc(%ebp),%esp
 597:	5b                   	pop    %ebx
 598:	5e                   	pop    %esi
 599:	5f                   	pop    %edi
 59a:	5d                   	pop    %ebp
 59b:	c3                   	ret    

0000059c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 59c:	55                   	push   %ebp
 59d:	89 e5                	mov    %esp,%ebp
 59f:	57                   	push   %edi
 5a0:	56                   	push   %esi
 5a1:	53                   	push   %ebx
 5a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5a5:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a8:	a1 bc 09 00 00       	mov    0x9bc,%eax
 5ad:	eb 02                	jmp    5b1 <free+0x15>
 5af:	89 d0                	mov    %edx,%eax
 5b1:	39 c8                	cmp    %ecx,%eax
 5b3:	73 04                	jae    5b9 <free+0x1d>
 5b5:	39 08                	cmp    %ecx,(%eax)
 5b7:	77 12                	ja     5cb <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b9:	8b 10                	mov    (%eax),%edx
 5bb:	39 c2                	cmp    %eax,%edx
 5bd:	77 f0                	ja     5af <free+0x13>
 5bf:	39 c8                	cmp    %ecx,%eax
 5c1:	72 08                	jb     5cb <free+0x2f>
 5c3:	39 ca                	cmp    %ecx,%edx
 5c5:	77 04                	ja     5cb <free+0x2f>
 5c7:	89 d0                	mov    %edx,%eax
 5c9:	eb e6                	jmp    5b1 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5cb:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5ce:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5d1:	8b 10                	mov    (%eax),%edx
 5d3:	39 d7                	cmp    %edx,%edi
 5d5:	74 19                	je     5f0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5d7:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5da:	8b 50 04             	mov    0x4(%eax),%edx
 5dd:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5e0:	39 ce                	cmp    %ecx,%esi
 5e2:	74 1b                	je     5ff <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5e4:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5e6:	a3 bc 09 00 00       	mov    %eax,0x9bc
}
 5eb:	5b                   	pop    %ebx
 5ec:	5e                   	pop    %esi
 5ed:	5f                   	pop    %edi
 5ee:	5d                   	pop    %ebp
 5ef:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5f0:	03 72 04             	add    0x4(%edx),%esi
 5f3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5f6:	8b 10                	mov    (%eax),%edx
 5f8:	8b 12                	mov    (%edx),%edx
 5fa:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5fd:	eb db                	jmp    5da <free+0x3e>
    p->s.size += bp->s.size;
 5ff:	03 53 fc             	add    -0x4(%ebx),%edx
 602:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 605:	8b 53 f8             	mov    -0x8(%ebx),%edx
 608:	89 10                	mov    %edx,(%eax)
 60a:	eb da                	jmp    5e6 <free+0x4a>

0000060c <morecore>:

static Header*
morecore(uint nu)
{
 60c:	55                   	push   %ebp
 60d:	89 e5                	mov    %esp,%ebp
 60f:	53                   	push   %ebx
 610:	83 ec 04             	sub    $0x4,%esp
 613:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 615:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 61a:	77 05                	ja     621 <morecore+0x15>
    nu = 4096;
 61c:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 621:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 628:	83 ec 0c             	sub    $0xc,%esp
 62b:	50                   	push   %eax
 62c:	e8 30 fd ff ff       	call   361 <sbrk>
  if(p == (char*)-1)
 631:	83 c4 10             	add    $0x10,%esp
 634:	83 f8 ff             	cmp    $0xffffffff,%eax
 637:	74 1c                	je     655 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 639:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 63c:	83 c0 08             	add    $0x8,%eax
 63f:	83 ec 0c             	sub    $0xc,%esp
 642:	50                   	push   %eax
 643:	e8 54 ff ff ff       	call   59c <free>
  return freep;
 648:	a1 bc 09 00 00       	mov    0x9bc,%eax
 64d:	83 c4 10             	add    $0x10,%esp
}
 650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 653:	c9                   	leave  
 654:	c3                   	ret    
    return 0;
 655:	b8 00 00 00 00       	mov    $0x0,%eax
 65a:	eb f4                	jmp    650 <morecore+0x44>

0000065c <malloc>:

void*
malloc(uint nbytes)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	53                   	push   %ebx
 660:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	8d 58 07             	lea    0x7(%eax),%ebx
 669:	c1 eb 03             	shr    $0x3,%ebx
 66c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 66f:	8b 0d bc 09 00 00    	mov    0x9bc,%ecx
 675:	85 c9                	test   %ecx,%ecx
 677:	74 04                	je     67d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 679:	8b 01                	mov    (%ecx),%eax
 67b:	eb 4d                	jmp    6ca <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 67d:	c7 05 bc 09 00 00 c0 	movl   $0x9c0,0x9bc
 684:	09 00 00 
 687:	c7 05 c0 09 00 00 c0 	movl   $0x9c0,0x9c0
 68e:	09 00 00 
    base.s.size = 0;
 691:	c7 05 c4 09 00 00 00 	movl   $0x0,0x9c4
 698:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 69b:	b9 c0 09 00 00       	mov    $0x9c0,%ecx
 6a0:	eb d7                	jmp    679 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6a2:	39 da                	cmp    %ebx,%edx
 6a4:	74 1a                	je     6c0 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6a6:	29 da                	sub    %ebx,%edx
 6a8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6ab:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6ae:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6b1:	89 0d bc 09 00 00    	mov    %ecx,0x9bc
      return (void*)(p + 1);
 6b7:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6ba:	83 c4 04             	add    $0x4,%esp
 6bd:	5b                   	pop    %ebx
 6be:	5d                   	pop    %ebp
 6bf:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6c0:	8b 10                	mov    (%eax),%edx
 6c2:	89 11                	mov    %edx,(%ecx)
 6c4:	eb eb                	jmp    6b1 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6c6:	89 c1                	mov    %eax,%ecx
 6c8:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6ca:	8b 50 04             	mov    0x4(%eax),%edx
 6cd:	39 da                	cmp    %ebx,%edx
 6cf:	73 d1                	jae    6a2 <malloc+0x46>
    if(p == freep)
 6d1:	39 05 bc 09 00 00    	cmp    %eax,0x9bc
 6d7:	75 ed                	jne    6c6 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6d9:	89 d8                	mov    %ebx,%eax
 6db:	e8 2c ff ff ff       	call   60c <morecore>
 6e0:	85 c0                	test   %eax,%eax
 6e2:	75 e2                	jne    6c6 <malloc+0x6a>
        return 0;
 6e4:	b8 00 00 00 00       	mov    $0x0,%eax
 6e9:	eb cf                	jmp    6ba <malloc+0x5e>
