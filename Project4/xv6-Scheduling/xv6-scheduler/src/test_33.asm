
_test_33:     file format elf32-i386


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
  36:	e8 27 03 00 00       	call   362 <sleep>
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
  74:	0f 8f bc 00 00 00    	jg     136 <main+0xdd>
    int pid = fork2(i % 4);
  7a:	89 da                	mov    %ebx,%edx
  7c:	c1 fa 1f             	sar    $0x1f,%edx
  7f:	c1 ea 1e             	shr    $0x1e,%edx
  82:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  85:	83 e0 03             	and    $0x3,%eax
  88:	29 d0                	sub    %edx,%eax
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	50                   	push   %eax
  8e:	e8 f7 02 00 00       	call   38a <fork2>
    if (pid == 0) {
  93:	83 c4 10             	add    $0x10,%esp
  96:	85 c0                	test   %eax,%eax
  98:	74 18                	je     b2 <main+0x59>
        workload(5000 * i, 20 * i);
        while(wait() != -1);
        exit();
      }
    } else {
      workload(i * 10, i);
  9a:	83 ec 08             	sub    $0x8,%esp
  9d:	53                   	push   %ebx
  9e:	8d 14 9b             	lea    (%ebx,%ebx,4),%edx
  a1:	8d 04 12             	lea    (%edx,%edx,1),%eax
  a4:	50                   	push   %eax
  a5:	e8 56 ff ff ff       	call   0 <workload>
  for (int i = 0; i < 15; ++i) {
  aa:	83 c3 01             	add    $0x1,%ebx
  ad:	83 c4 10             	add    $0x10,%esp
  b0:	eb bf                	jmp    71 <main+0x18>
      workload(10000 * i, 100);
  b2:	83 ec 08             	sub    $0x8,%esp
  b5:	6a 64                	push   $0x64
  b7:	69 c3 10 27 00 00    	imul   $0x2710,%ebx,%eax
  bd:	50                   	push   %eax
  be:	e8 3d ff ff ff       	call   0 <workload>
      int pid2 = fork();
  c3:	e8 02 02 00 00       	call   2ca <fork>
      if (pid2 == 0) {
  c8:	83 c4 10             	add    $0x10,%esp
  cb:	85 c0                	test   %eax,%eax
  cd:	75 42                	jne    111 <main+0xb8>
        int pid3 = fork2(i % 2);
  cf:	b9 02 00 00 00       	mov    $0x2,%ecx
  d4:	89 d8                	mov    %ebx,%eax
  d6:	99                   	cltd   
  d7:	f7 f9                	idiv   %ecx
  d9:	83 ec 0c             	sub    $0xc,%esp
  dc:	52                   	push   %edx
  dd:	e8 a8 02 00 00       	call   38a <fork2>
  e2:	89 c6                	mov    %eax,%esi
        workload(4567 * i, 8 * i);
  e4:	83 c4 08             	add    $0x8,%esp
  e7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
  ee:	50                   	push   %eax
  ef:	69 db d7 11 00 00    	imul   $0x11d7,%ebx,%ebx
  f5:	53                   	push   %ebx
  f6:	e8 05 ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  fb:	83 c4 10             	add    $0x10,%esp
  fe:	85 f6                	test   %esi,%esi
 100:	74 0a                	je     10c <main+0xb3>
          while(wait() != -1);
 102:	e8 d3 01 00 00       	call   2da <wait>
 107:	83 f8 ff             	cmp    $0xffffffff,%eax
 10a:	75 f6                	jne    102 <main+0xa9>
        exit();
 10c:	e8 c1 01 00 00       	call   2d2 <exit>
        workload(5000 * i, 20 * i);
 111:	83 ec 08             	sub    $0x8,%esp
 114:	6b c3 14             	imul   $0x14,%ebx,%eax
 117:	50                   	push   %eax
 118:	69 db 88 13 00 00    	imul   $0x1388,%ebx,%ebx
 11e:	53                   	push   %ebx
 11f:	e8 dc fe ff ff       	call   0 <workload>
        while(wait() != -1);
 124:	83 c4 10             	add    $0x10,%esp
 127:	e8 ae 01 00 00       	call   2da <wait>
 12c:	83 f8 ff             	cmp    $0xffffffff,%eax
 12f:	75 f6                	jne    127 <main+0xce>
        exit();
 131:	e8 9c 01 00 00       	call   2d2 <exit>
    }
  }

  while(wait() != -1);
 136:	e8 9f 01 00 00       	call   2da <wait>
 13b:	83 f8 ff             	cmp    $0xffffffff,%eax
 13e:	75 f6                	jne    136 <main+0xdd>
  exit();
 140:	e8 8d 01 00 00       	call   2d2 <exit>

00000145 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	53                   	push   %ebx
 149:	8b 45 08             	mov    0x8(%ebp),%eax
 14c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 14f:	89 c2                	mov    %eax,%edx
 151:	0f b6 19             	movzbl (%ecx),%ebx
 154:	88 1a                	mov    %bl,(%edx)
 156:	8d 52 01             	lea    0x1(%edx),%edx
 159:	8d 49 01             	lea    0x1(%ecx),%ecx
 15c:	84 db                	test   %bl,%bl
 15e:	75 f1                	jne    151 <strcpy+0xc>
    ;
  return os;
}
 160:	5b                   	pop    %ebx
 161:	5d                   	pop    %ebp
 162:	c3                   	ret    

00000163 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 163:	55                   	push   %ebp
 164:	89 e5                	mov    %esp,%ebp
 166:	8b 4d 08             	mov    0x8(%ebp),%ecx
 169:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 16c:	eb 06                	jmp    174 <strcmp+0x11>
    p++, q++;
 16e:	83 c1 01             	add    $0x1,%ecx
 171:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 174:	0f b6 01             	movzbl (%ecx),%eax
 177:	84 c0                	test   %al,%al
 179:	74 04                	je     17f <strcmp+0x1c>
 17b:	3a 02                	cmp    (%edx),%al
 17d:	74 ef                	je     16e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 17f:	0f b6 c0             	movzbl %al,%eax
 182:	0f b6 12             	movzbl (%edx),%edx
 185:	29 d0                	sub    %edx,%eax
}
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    

00000189 <strlen>:

uint
strlen(const char *s)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 18f:	ba 00 00 00 00       	mov    $0x0,%edx
 194:	eb 03                	jmp    199 <strlen+0x10>
 196:	83 c2 01             	add    $0x1,%edx
 199:	89 d0                	mov    %edx,%eax
 19b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 19f:	75 f5                	jne    196 <strlen+0xd>
    ;
  return n;
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	57                   	push   %edi
 1a7:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1aa:	89 d7                	mov    %edx,%edi
 1ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1af:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b2:	fc                   	cld    
 1b3:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1b5:	89 d0                	mov    %edx,%eax
 1b7:	5f                   	pop    %edi
 1b8:	5d                   	pop    %ebp
 1b9:	c3                   	ret    

000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	55                   	push   %ebp
 1bb:	89 e5                	mov    %esp,%ebp
 1bd:	8b 45 08             	mov    0x8(%ebp),%eax
 1c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1c4:	0f b6 10             	movzbl (%eax),%edx
 1c7:	84 d2                	test   %dl,%dl
 1c9:	74 09                	je     1d4 <strchr+0x1a>
    if(*s == c)
 1cb:	38 ca                	cmp    %cl,%dl
 1cd:	74 0a                	je     1d9 <strchr+0x1f>
  for(; *s; s++)
 1cf:	83 c0 01             	add    $0x1,%eax
 1d2:	eb f0                	jmp    1c4 <strchr+0xa>
      return (char*)s;
  return 0;
 1d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d9:	5d                   	pop    %ebp
 1da:	c3                   	ret    

000001db <gets>:

char*
gets(char *buf, int max)
{
 1db:	55                   	push   %ebp
 1dc:	89 e5                	mov    %esp,%ebp
 1de:	57                   	push   %edi
 1df:	56                   	push   %esi
 1e0:	53                   	push   %ebx
 1e1:	83 ec 1c             	sub    $0x1c,%esp
 1e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e7:	bb 00 00 00 00       	mov    $0x0,%ebx
 1ec:	8d 73 01             	lea    0x1(%ebx),%esi
 1ef:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1f2:	7d 2e                	jge    222 <gets+0x47>
    cc = read(0, &c, 1);
 1f4:	83 ec 04             	sub    $0x4,%esp
 1f7:	6a 01                	push   $0x1
 1f9:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1fc:	50                   	push   %eax
 1fd:	6a 00                	push   $0x0
 1ff:	e8 e6 00 00 00       	call   2ea <read>
    if(cc < 1)
 204:	83 c4 10             	add    $0x10,%esp
 207:	85 c0                	test   %eax,%eax
 209:	7e 17                	jle    222 <gets+0x47>
      break;
    buf[i++] = c;
 20b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 20f:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 212:	3c 0a                	cmp    $0xa,%al
 214:	0f 94 c2             	sete   %dl
 217:	3c 0d                	cmp    $0xd,%al
 219:	0f 94 c0             	sete   %al
    buf[i++] = c;
 21c:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 21e:	08 c2                	or     %al,%dl
 220:	74 ca                	je     1ec <gets+0x11>
      break;
  }
  buf[i] = '\0';
 222:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 226:	89 f8                	mov    %edi,%eax
 228:	8d 65 f4             	lea    -0xc(%ebp),%esp
 22b:	5b                   	pop    %ebx
 22c:	5e                   	pop    %esi
 22d:	5f                   	pop    %edi
 22e:	5d                   	pop    %ebp
 22f:	c3                   	ret    

00000230 <stat>:

int
stat(const char *n, struct stat *st)
{
 230:	55                   	push   %ebp
 231:	89 e5                	mov    %esp,%ebp
 233:	56                   	push   %esi
 234:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 235:	83 ec 08             	sub    $0x8,%esp
 238:	6a 00                	push   $0x0
 23a:	ff 75 08             	pushl  0x8(%ebp)
 23d:	e8 d0 00 00 00       	call   312 <open>
  if(fd < 0)
 242:	83 c4 10             	add    $0x10,%esp
 245:	85 c0                	test   %eax,%eax
 247:	78 24                	js     26d <stat+0x3d>
 249:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 24b:	83 ec 08             	sub    $0x8,%esp
 24e:	ff 75 0c             	pushl  0xc(%ebp)
 251:	50                   	push   %eax
 252:	e8 d3 00 00 00       	call   32a <fstat>
 257:	89 c6                	mov    %eax,%esi
  close(fd);
 259:	89 1c 24             	mov    %ebx,(%esp)
 25c:	e8 99 00 00 00       	call   2fa <close>
  return r;
 261:	83 c4 10             	add    $0x10,%esp
}
 264:	89 f0                	mov    %esi,%eax
 266:	8d 65 f8             	lea    -0x8(%ebp),%esp
 269:	5b                   	pop    %ebx
 26a:	5e                   	pop    %esi
 26b:	5d                   	pop    %ebp
 26c:	c3                   	ret    
    return -1;
 26d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 272:	eb f0                	jmp    264 <stat+0x34>

00000274 <atoi>:

int
atoi(const char *s)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	53                   	push   %ebx
 278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 27b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 280:	eb 10                	jmp    292 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 282:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 285:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 288:	83 c1 01             	add    $0x1,%ecx
 28b:	0f be d2             	movsbl %dl,%edx
 28e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 292:	0f b6 11             	movzbl (%ecx),%edx
 295:	8d 5a d0             	lea    -0x30(%edx),%ebx
 298:	80 fb 09             	cmp    $0x9,%bl
 29b:	76 e5                	jbe    282 <atoi+0xe>
  return n;
}
 29d:	5b                   	pop    %ebx
 29e:	5d                   	pop    %ebp
 29f:	c3                   	ret    

000002a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	56                   	push   %esi
 2a4:	53                   	push   %ebx
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2ab:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2ae:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2b0:	eb 0d                	jmp    2bf <memmove+0x1f>
    *dst++ = *src++;
 2b2:	0f b6 13             	movzbl (%ebx),%edx
 2b5:	88 11                	mov    %dl,(%ecx)
 2b7:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2ba:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2bd:	89 f2                	mov    %esi,%edx
 2bf:	8d 72 ff             	lea    -0x1(%edx),%esi
 2c2:	85 d2                	test   %edx,%edx
 2c4:	7f ec                	jg     2b2 <memmove+0x12>
  return vdst;
}
 2c6:	5b                   	pop    %ebx
 2c7:	5e                   	pop    %esi
 2c8:	5d                   	pop    %ebp
 2c9:	c3                   	ret    

000002ca <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2ca:	b8 01 00 00 00       	mov    $0x1,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <exit>:
SYSCALL(exit)
 2d2:	b8 02 00 00 00       	mov    $0x2,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <wait>:
SYSCALL(wait)
 2da:	b8 03 00 00 00       	mov    $0x3,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <pipe>:
SYSCALL(pipe)
 2e2:	b8 04 00 00 00       	mov    $0x4,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <read>:
SYSCALL(read)
 2ea:	b8 05 00 00 00       	mov    $0x5,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <write>:
SYSCALL(write)
 2f2:	b8 10 00 00 00       	mov    $0x10,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <close>:
SYSCALL(close)
 2fa:	b8 15 00 00 00       	mov    $0x15,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <kill>:
SYSCALL(kill)
 302:	b8 06 00 00 00       	mov    $0x6,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <exec>:
SYSCALL(exec)
 30a:	b8 07 00 00 00       	mov    $0x7,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <open>:
SYSCALL(open)
 312:	b8 0f 00 00 00       	mov    $0xf,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <mknod>:
SYSCALL(mknod)
 31a:	b8 11 00 00 00       	mov    $0x11,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <unlink>:
SYSCALL(unlink)
 322:	b8 12 00 00 00       	mov    $0x12,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <fstat>:
SYSCALL(fstat)
 32a:	b8 08 00 00 00       	mov    $0x8,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <link>:
SYSCALL(link)
 332:	b8 13 00 00 00       	mov    $0x13,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <mkdir>:
SYSCALL(mkdir)
 33a:	b8 14 00 00 00       	mov    $0x14,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <chdir>:
SYSCALL(chdir)
 342:	b8 09 00 00 00       	mov    $0x9,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <dup>:
SYSCALL(dup)
 34a:	b8 0a 00 00 00       	mov    $0xa,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <getpid>:
SYSCALL(getpid)
 352:	b8 0b 00 00 00       	mov    $0xb,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <sbrk>:
SYSCALL(sbrk)
 35a:	b8 0c 00 00 00       	mov    $0xc,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <sleep>:
SYSCALL(sleep)
 362:	b8 0d 00 00 00       	mov    $0xd,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <uptime>:
SYSCALL(uptime)
 36a:	b8 0e 00 00 00       	mov    $0xe,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <setpri>:
SYSCALL(setpri)
 372:	b8 16 00 00 00       	mov    $0x16,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <getpri>:
SYSCALL(getpri)
 37a:	b8 17 00 00 00       	mov    $0x17,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <getpinfo>:
SYSCALL(getpinfo)
 382:	b8 18 00 00 00       	mov    $0x18,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <fork2>:
SYSCALL(fork2)
 38a:	b8 19 00 00 00       	mov    $0x19,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 392:	55                   	push   %ebp
 393:	89 e5                	mov    %esp,%ebp
 395:	83 ec 1c             	sub    $0x1c,%esp
 398:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 39b:	6a 01                	push   $0x1
 39d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3a0:	52                   	push   %edx
 3a1:	50                   	push   %eax
 3a2:	e8 4b ff ff ff       	call   2f2 <write>
}
 3a7:	83 c4 10             	add    $0x10,%esp
 3aa:	c9                   	leave  
 3ab:	c3                   	ret    

000003ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
 3af:	57                   	push   %edi
 3b0:	56                   	push   %esi
 3b1:	53                   	push   %ebx
 3b2:	83 ec 2c             	sub    $0x2c,%esp
 3b5:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3bb:	0f 95 c3             	setne  %bl
 3be:	89 d0                	mov    %edx,%eax
 3c0:	c1 e8 1f             	shr    $0x1f,%eax
 3c3:	84 c3                	test   %al,%bl
 3c5:	74 10                	je     3d7 <printint+0x2b>
    neg = 1;
    x = -xx;
 3c7:	f7 da                	neg    %edx
    neg = 1;
 3c9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3d0:	be 00 00 00 00       	mov    $0x0,%esi
 3d5:	eb 0b                	jmp    3e2 <printint+0x36>
  neg = 0;
 3d7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3de:	eb f0                	jmp    3d0 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3e0:	89 c6                	mov    %eax,%esi
 3e2:	89 d0                	mov    %edx,%eax
 3e4:	ba 00 00 00 00       	mov    $0x0,%edx
 3e9:	f7 f1                	div    %ecx
 3eb:	89 c3                	mov    %eax,%ebx
 3ed:	8d 46 01             	lea    0x1(%esi),%eax
 3f0:	0f b6 92 ec 06 00 00 	movzbl 0x6ec(%edx),%edx
 3f7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3fb:	89 da                	mov    %ebx,%edx
 3fd:	85 db                	test   %ebx,%ebx
 3ff:	75 df                	jne    3e0 <printint+0x34>
 401:	89 c3                	mov    %eax,%ebx
  if(neg)
 403:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 407:	74 16                	je     41f <printint+0x73>
    buf[i++] = '-';
 409:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 40e:	8d 5e 02             	lea    0x2(%esi),%ebx
 411:	eb 0c                	jmp    41f <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 413:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 418:	89 f8                	mov    %edi,%eax
 41a:	e8 73 ff ff ff       	call   392 <putc>
  while(--i >= 0)
 41f:	83 eb 01             	sub    $0x1,%ebx
 422:	79 ef                	jns    413 <printint+0x67>
}
 424:	83 c4 2c             	add    $0x2c,%esp
 427:	5b                   	pop    %ebx
 428:	5e                   	pop    %esi
 429:	5f                   	pop    %edi
 42a:	5d                   	pop    %ebp
 42b:	c3                   	ret    

0000042c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	57                   	push   %edi
 430:	56                   	push   %esi
 431:	53                   	push   %ebx
 432:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 435:	8d 45 10             	lea    0x10(%ebp),%eax
 438:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 43b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 440:	bb 00 00 00 00       	mov    $0x0,%ebx
 445:	eb 14                	jmp    45b <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 447:	89 fa                	mov    %edi,%edx
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	e8 41 ff ff ff       	call   392 <putc>
 451:	eb 05                	jmp    458 <printf+0x2c>
      }
    } else if(state == '%'){
 453:	83 fe 25             	cmp    $0x25,%esi
 456:	74 25                	je     47d <printf+0x51>
  for(i = 0; fmt[i]; i++){
 458:	83 c3 01             	add    $0x1,%ebx
 45b:	8b 45 0c             	mov    0xc(%ebp),%eax
 45e:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 462:	84 c0                	test   %al,%al
 464:	0f 84 23 01 00 00    	je     58d <printf+0x161>
    c = fmt[i] & 0xff;
 46a:	0f be f8             	movsbl %al,%edi
 46d:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 470:	85 f6                	test   %esi,%esi
 472:	75 df                	jne    453 <printf+0x27>
      if(c == '%'){
 474:	83 f8 25             	cmp    $0x25,%eax
 477:	75 ce                	jne    447 <printf+0x1b>
        state = '%';
 479:	89 c6                	mov    %eax,%esi
 47b:	eb db                	jmp    458 <printf+0x2c>
      if(c == 'd'){
 47d:	83 f8 64             	cmp    $0x64,%eax
 480:	74 49                	je     4cb <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 482:	83 f8 78             	cmp    $0x78,%eax
 485:	0f 94 c1             	sete   %cl
 488:	83 f8 70             	cmp    $0x70,%eax
 48b:	0f 94 c2             	sete   %dl
 48e:	08 d1                	or     %dl,%cl
 490:	75 63                	jne    4f5 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 492:	83 f8 73             	cmp    $0x73,%eax
 495:	0f 84 84 00 00 00    	je     51f <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 49b:	83 f8 63             	cmp    $0x63,%eax
 49e:	0f 84 b7 00 00 00    	je     55b <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4a4:	83 f8 25             	cmp    $0x25,%eax
 4a7:	0f 84 cc 00 00 00    	je     579 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4ad:	ba 25 00 00 00       	mov    $0x25,%edx
 4b2:	8b 45 08             	mov    0x8(%ebp),%eax
 4b5:	e8 d8 fe ff ff       	call   392 <putc>
        putc(fd, c);
 4ba:	89 fa                	mov    %edi,%edx
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	e8 ce fe ff ff       	call   392 <putc>
      }
      state = 0;
 4c4:	be 00 00 00 00       	mov    $0x0,%esi
 4c9:	eb 8d                	jmp    458 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ce:	8b 17                	mov    (%edi),%edx
 4d0:	83 ec 0c             	sub    $0xc,%esp
 4d3:	6a 01                	push   $0x1
 4d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	e8 ca fe ff ff       	call   3ac <printint>
        ap++;
 4e2:	83 c7 04             	add    $0x4,%edi
 4e5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4eb:	be 00 00 00 00       	mov    $0x0,%esi
 4f0:	e9 63 ff ff ff       	jmp    458 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f8:	8b 17                	mov    (%edi),%edx
 4fa:	83 ec 0c             	sub    $0xc,%esp
 4fd:	6a 00                	push   $0x0
 4ff:	b9 10 00 00 00       	mov    $0x10,%ecx
 504:	8b 45 08             	mov    0x8(%ebp),%eax
 507:	e8 a0 fe ff ff       	call   3ac <printint>
        ap++;
 50c:	83 c7 04             	add    $0x4,%edi
 50f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 512:	83 c4 10             	add    $0x10,%esp
      state = 0;
 515:	be 00 00 00 00       	mov    $0x0,%esi
 51a:	e9 39 ff ff ff       	jmp    458 <printf+0x2c>
        s = (char*)*ap;
 51f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 522:	8b 30                	mov    (%eax),%esi
        ap++;
 524:	83 c0 04             	add    $0x4,%eax
 527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 52a:	85 f6                	test   %esi,%esi
 52c:	75 28                	jne    556 <printf+0x12a>
          s = "(null)";
 52e:	be e4 06 00 00       	mov    $0x6e4,%esi
 533:	8b 7d 08             	mov    0x8(%ebp),%edi
 536:	eb 0d                	jmp    545 <printf+0x119>
          putc(fd, *s);
 538:	0f be d2             	movsbl %dl,%edx
 53b:	89 f8                	mov    %edi,%eax
 53d:	e8 50 fe ff ff       	call   392 <putc>
          s++;
 542:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 545:	0f b6 16             	movzbl (%esi),%edx
 548:	84 d2                	test   %dl,%dl
 54a:	75 ec                	jne    538 <printf+0x10c>
      state = 0;
 54c:	be 00 00 00 00       	mov    $0x0,%esi
 551:	e9 02 ff ff ff       	jmp    458 <printf+0x2c>
 556:	8b 7d 08             	mov    0x8(%ebp),%edi
 559:	eb ea                	jmp    545 <printf+0x119>
        putc(fd, *ap);
 55b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 55e:	0f be 17             	movsbl (%edi),%edx
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	e8 29 fe ff ff       	call   392 <putc>
        ap++;
 569:	83 c7 04             	add    $0x4,%edi
 56c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 56f:	be 00 00 00 00       	mov    $0x0,%esi
 574:	e9 df fe ff ff       	jmp    458 <printf+0x2c>
        putc(fd, c);
 579:	89 fa                	mov    %edi,%edx
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	e8 0f fe ff ff       	call   392 <putc>
      state = 0;
 583:	be 00 00 00 00       	mov    $0x0,%esi
 588:	e9 cb fe ff ff       	jmp    458 <printf+0x2c>
    }
  }
}
 58d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 590:	5b                   	pop    %ebx
 591:	5e                   	pop    %esi
 592:	5f                   	pop    %edi
 593:	5d                   	pop    %ebp
 594:	c3                   	ret    

00000595 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 595:	55                   	push   %ebp
 596:	89 e5                	mov    %esp,%ebp
 598:	57                   	push   %edi
 599:	56                   	push   %esi
 59a:	53                   	push   %ebx
 59b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 59e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a1:	a1 b4 09 00 00       	mov    0x9b4,%eax
 5a6:	eb 02                	jmp    5aa <free+0x15>
 5a8:	89 d0                	mov    %edx,%eax
 5aa:	39 c8                	cmp    %ecx,%eax
 5ac:	73 04                	jae    5b2 <free+0x1d>
 5ae:	39 08                	cmp    %ecx,(%eax)
 5b0:	77 12                	ja     5c4 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b2:	8b 10                	mov    (%eax),%edx
 5b4:	39 c2                	cmp    %eax,%edx
 5b6:	77 f0                	ja     5a8 <free+0x13>
 5b8:	39 c8                	cmp    %ecx,%eax
 5ba:	72 08                	jb     5c4 <free+0x2f>
 5bc:	39 ca                	cmp    %ecx,%edx
 5be:	77 04                	ja     5c4 <free+0x2f>
 5c0:	89 d0                	mov    %edx,%eax
 5c2:	eb e6                	jmp    5aa <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5c4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5c7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5ca:	8b 10                	mov    (%eax),%edx
 5cc:	39 d7                	cmp    %edx,%edi
 5ce:	74 19                	je     5e9 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5d0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5d3:	8b 50 04             	mov    0x4(%eax),%edx
 5d6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5d9:	39 ce                	cmp    %ecx,%esi
 5db:	74 1b                	je     5f8 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5dd:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5df:	a3 b4 09 00 00       	mov    %eax,0x9b4
}
 5e4:	5b                   	pop    %ebx
 5e5:	5e                   	pop    %esi
 5e6:	5f                   	pop    %edi
 5e7:	5d                   	pop    %ebp
 5e8:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5e9:	03 72 04             	add    0x4(%edx),%esi
 5ec:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5ef:	8b 10                	mov    (%eax),%edx
 5f1:	8b 12                	mov    (%edx),%edx
 5f3:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5f6:	eb db                	jmp    5d3 <free+0x3e>
    p->s.size += bp->s.size;
 5f8:	03 53 fc             	add    -0x4(%ebx),%edx
 5fb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5fe:	8b 53 f8             	mov    -0x8(%ebx),%edx
 601:	89 10                	mov    %edx,(%eax)
 603:	eb da                	jmp    5df <free+0x4a>

00000605 <morecore>:

static Header*
morecore(uint nu)
{
 605:	55                   	push   %ebp
 606:	89 e5                	mov    %esp,%ebp
 608:	53                   	push   %ebx
 609:	83 ec 04             	sub    $0x4,%esp
 60c:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 60e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 613:	77 05                	ja     61a <morecore+0x15>
    nu = 4096;
 615:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 61a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 621:	83 ec 0c             	sub    $0xc,%esp
 624:	50                   	push   %eax
 625:	e8 30 fd ff ff       	call   35a <sbrk>
  if(p == (char*)-1)
 62a:	83 c4 10             	add    $0x10,%esp
 62d:	83 f8 ff             	cmp    $0xffffffff,%eax
 630:	74 1c                	je     64e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 632:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 635:	83 c0 08             	add    $0x8,%eax
 638:	83 ec 0c             	sub    $0xc,%esp
 63b:	50                   	push   %eax
 63c:	e8 54 ff ff ff       	call   595 <free>
  return freep;
 641:	a1 b4 09 00 00       	mov    0x9b4,%eax
 646:	83 c4 10             	add    $0x10,%esp
}
 649:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 64c:	c9                   	leave  
 64d:	c3                   	ret    
    return 0;
 64e:	b8 00 00 00 00       	mov    $0x0,%eax
 653:	eb f4                	jmp    649 <morecore+0x44>

00000655 <malloc>:

void*
malloc(uint nbytes)
{
 655:	55                   	push   %ebp
 656:	89 e5                	mov    %esp,%ebp
 658:	53                   	push   %ebx
 659:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	8d 58 07             	lea    0x7(%eax),%ebx
 662:	c1 eb 03             	shr    $0x3,%ebx
 665:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 668:	8b 0d b4 09 00 00    	mov    0x9b4,%ecx
 66e:	85 c9                	test   %ecx,%ecx
 670:	74 04                	je     676 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 672:	8b 01                	mov    (%ecx),%eax
 674:	eb 4d                	jmp    6c3 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 676:	c7 05 b4 09 00 00 b8 	movl   $0x9b8,0x9b4
 67d:	09 00 00 
 680:	c7 05 b8 09 00 00 b8 	movl   $0x9b8,0x9b8
 687:	09 00 00 
    base.s.size = 0;
 68a:	c7 05 bc 09 00 00 00 	movl   $0x0,0x9bc
 691:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 694:	b9 b8 09 00 00       	mov    $0x9b8,%ecx
 699:	eb d7                	jmp    672 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 69b:	39 da                	cmp    %ebx,%edx
 69d:	74 1a                	je     6b9 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 69f:	29 da                	sub    %ebx,%edx
 6a1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6a4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6a7:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6aa:	89 0d b4 09 00 00    	mov    %ecx,0x9b4
      return (void*)(p + 1);
 6b0:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6b3:	83 c4 04             	add    $0x4,%esp
 6b6:	5b                   	pop    %ebx
 6b7:	5d                   	pop    %ebp
 6b8:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6b9:	8b 10                	mov    (%eax),%edx
 6bb:	89 11                	mov    %edx,(%ecx)
 6bd:	eb eb                	jmp    6aa <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6bf:	89 c1                	mov    %eax,%ecx
 6c1:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6c3:	8b 50 04             	mov    0x4(%eax),%edx
 6c6:	39 da                	cmp    %ebx,%edx
 6c8:	73 d1                	jae    69b <malloc+0x46>
    if(p == freep)
 6ca:	39 05 b4 09 00 00    	cmp    %eax,0x9b4
 6d0:	75 ed                	jne    6bf <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6d2:	89 d8                	mov    %ebx,%eax
 6d4:	e8 2c ff ff ff       	call   605 <morecore>
 6d9:	85 c0                	test   %eax,%eax
 6db:	75 e2                	jne    6bf <malloc+0x6a>
        return 0;
 6dd:	b8 00 00 00 00       	mov    $0x0,%eax
 6e2:	eb cf                	jmp    6b3 <malloc+0x5e>
