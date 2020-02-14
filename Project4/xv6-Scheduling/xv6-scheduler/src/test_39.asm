
_test_39:     file format elf32-i386


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
  36:	e8 37 03 00 00       	call   372 <sleep>
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
  66:	57                   	push   %edi
  67:	56                   	push   %esi
  68:	53                   	push   %ebx
  69:	51                   	push   %ecx
  6a:	83 ec 08             	sub    $0x8,%esp
  for (int i = 0; i < 15; ++i) {
  6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  72:	83 fb 0e             	cmp    $0xe,%ebx
  75:	0f 8f cb 00 00 00    	jg     146 <main+0xed>
    int pid = fork2((i * i + i) % 4);
  7b:	8d 7b 01             	lea    0x1(%ebx),%edi
  7e:	89 fe                	mov    %edi,%esi
  80:	0f af f3             	imul   %ebx,%esi
  83:	89 f2                	mov    %esi,%edx
  85:	c1 fa 1f             	sar    $0x1f,%edx
  88:	c1 ea 1e             	shr    $0x1e,%edx
  8b:	8d 04 16             	lea    (%esi,%edx,1),%eax
  8e:	83 e0 03             	and    $0x3,%eax
  91:	29 d0                	sub    %edx,%eax
  93:	83 ec 0c             	sub    $0xc,%esp
  96:	50                   	push   %eax
  97:	e8 fe 02 00 00       	call   39a <fork2>
    if (pid == 0) {
  9c:	83 c4 10             	add    $0x10,%esp
  9f:	85 c0                	test   %eax,%eax
  a1:	74 17                	je     ba <main+0x61>
        workload(5000 * (i * i + i), 20 * i);
        while(wait() != -1);
        exit();
      }
    } else {
      workload(i * 10, i);
  a3:	83 ec 08             	sub    $0x8,%esp
  a6:	53                   	push   %ebx
  a7:	8d 14 9b             	lea    (%ebx,%ebx,4),%edx
  aa:	8d 04 12             	lea    (%edx,%edx,1),%eax
  ad:	50                   	push   %eax
  ae:	e8 4d ff ff ff       	call   0 <workload>
  for (int i = 0; i < 15; ++i) {
  b3:	83 c4 10             	add    $0x10,%esp
  b6:	89 fb                	mov    %edi,%ebx
  b8:	eb b8                	jmp    72 <main+0x19>
      workload(10000 * i, 100);
  ba:	83 ec 08             	sub    $0x8,%esp
  bd:	6a 64                	push   $0x64
  bf:	69 c3 10 27 00 00    	imul   $0x2710,%ebx,%eax
  c5:	50                   	push   %eax
  c6:	e8 35 ff ff ff       	call   0 <workload>
      int pid2 = fork();
  cb:	e8 0a 02 00 00       	call   2da <fork>
  d0:	89 c7                	mov    %eax,%edi
      workload(10 * (i * i + i), (i * i + i));
  d2:	83 c4 08             	add    $0x8,%esp
  d5:	56                   	push   %esi
  d6:	6b c6 0a             	imul   $0xa,%esi,%eax
  d9:	50                   	push   %eax
  da:	e8 21 ff ff ff       	call   0 <workload>
      if (pid2 == 0) {
  df:	83 c4 10             	add    $0x10,%esp
  e2:	85 ff                	test   %edi,%edi
  e4:	75 3b                	jne    121 <main+0xc8>
        int pid3 = fork2((i * i + i) % 2);
  e6:	b9 02 00 00 00       	mov    $0x2,%ecx
  eb:	89 f0                	mov    %esi,%eax
  ed:	99                   	cltd   
  ee:	f7 f9                	idiv   %ecx
  f0:	83 ec 0c             	sub    $0xc,%esp
  f3:	52                   	push   %edx
  f4:	e8 a1 02 00 00       	call   39a <fork2>
  f9:	89 c7                	mov    %eax,%edi
        workload(4567 * i, (i * i + i));
  fb:	83 c4 08             	add    $0x8,%esp
  fe:	56                   	push   %esi
  ff:	69 db d7 11 00 00    	imul   $0x11d7,%ebx,%ebx
 105:	53                   	push   %ebx
 106:	e8 f5 fe ff ff       	call   0 <workload>
        if (pid3 != 0) {
 10b:	83 c4 10             	add    $0x10,%esp
 10e:	85 ff                	test   %edi,%edi
 110:	74 0a                	je     11c <main+0xc3>
          while(wait() != -1);
 112:	e8 d3 01 00 00       	call   2ea <wait>
 117:	83 f8 ff             	cmp    $0xffffffff,%eax
 11a:	75 f6                	jne    112 <main+0xb9>
        exit();
 11c:	e8 c1 01 00 00       	call   2e2 <exit>
        workload(5000 * (i * i + i), 20 * i);
 121:	83 ec 08             	sub    $0x8,%esp
 124:	6b db 14             	imul   $0x14,%ebx,%ebx
 127:	53                   	push   %ebx
 128:	69 f6 88 13 00 00    	imul   $0x1388,%esi,%esi
 12e:	56                   	push   %esi
 12f:	e8 cc fe ff ff       	call   0 <workload>
        while(wait() != -1);
 134:	83 c4 10             	add    $0x10,%esp
 137:	e8 ae 01 00 00       	call   2ea <wait>
 13c:	83 f8 ff             	cmp    $0xffffffff,%eax
 13f:	75 f6                	jne    137 <main+0xde>
        exit();
 141:	e8 9c 01 00 00       	call   2e2 <exit>
    }
  }

  while(wait() != -1);
 146:	e8 9f 01 00 00       	call   2ea <wait>
 14b:	83 f8 ff             	cmp    $0xffffffff,%eax
 14e:	75 f6                	jne    146 <main+0xed>
  exit();
 150:	e8 8d 01 00 00       	call   2e2 <exit>

00000155 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 155:	55                   	push   %ebp
 156:	89 e5                	mov    %esp,%ebp
 158:	53                   	push   %ebx
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 15f:	89 c2                	mov    %eax,%edx
 161:	0f b6 19             	movzbl (%ecx),%ebx
 164:	88 1a                	mov    %bl,(%edx)
 166:	8d 52 01             	lea    0x1(%edx),%edx
 169:	8d 49 01             	lea    0x1(%ecx),%ecx
 16c:	84 db                	test   %bl,%bl
 16e:	75 f1                	jne    161 <strcpy+0xc>
    ;
  return os;
}
 170:	5b                   	pop    %ebx
 171:	5d                   	pop    %ebp
 172:	c3                   	ret    

00000173 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 173:	55                   	push   %ebp
 174:	89 e5                	mov    %esp,%ebp
 176:	8b 4d 08             	mov    0x8(%ebp),%ecx
 179:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 17c:	eb 06                	jmp    184 <strcmp+0x11>
    p++, q++;
 17e:	83 c1 01             	add    $0x1,%ecx
 181:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 184:	0f b6 01             	movzbl (%ecx),%eax
 187:	84 c0                	test   %al,%al
 189:	74 04                	je     18f <strcmp+0x1c>
 18b:	3a 02                	cmp    (%edx),%al
 18d:	74 ef                	je     17e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 18f:	0f b6 c0             	movzbl %al,%eax
 192:	0f b6 12             	movzbl (%edx),%edx
 195:	29 d0                	sub    %edx,%eax
}
 197:	5d                   	pop    %ebp
 198:	c3                   	ret    

00000199 <strlen>:

uint
strlen(const char *s)
{
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 19f:	ba 00 00 00 00       	mov    $0x0,%edx
 1a4:	eb 03                	jmp    1a9 <strlen+0x10>
 1a6:	83 c2 01             	add    $0x1,%edx
 1a9:	89 d0                	mov    %edx,%eax
 1ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1af:	75 f5                	jne    1a6 <strlen+0xd>
    ;
  return n;
}
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    

000001b3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	57                   	push   %edi
 1b7:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1ba:	89 d7                	mov    %edx,%edi
 1bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c2:	fc                   	cld    
 1c3:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1c5:	89 d0                	mov    %edx,%eax
 1c7:	5f                   	pop    %edi
 1c8:	5d                   	pop    %ebp
 1c9:	c3                   	ret    

000001ca <strchr>:

char*
strchr(const char *s, char c)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1d4:	0f b6 10             	movzbl (%eax),%edx
 1d7:	84 d2                	test   %dl,%dl
 1d9:	74 09                	je     1e4 <strchr+0x1a>
    if(*s == c)
 1db:	38 ca                	cmp    %cl,%dl
 1dd:	74 0a                	je     1e9 <strchr+0x1f>
  for(; *s; s++)
 1df:	83 c0 01             	add    $0x1,%eax
 1e2:	eb f0                	jmp    1d4 <strchr+0xa>
      return (char*)s;
  return 0;
 1e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1e9:	5d                   	pop    %ebp
 1ea:	c3                   	ret    

000001eb <gets>:

char*
gets(char *buf, int max)
{
 1eb:	55                   	push   %ebp
 1ec:	89 e5                	mov    %esp,%ebp
 1ee:	57                   	push   %edi
 1ef:	56                   	push   %esi
 1f0:	53                   	push   %ebx
 1f1:	83 ec 1c             	sub    $0x1c,%esp
 1f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f7:	bb 00 00 00 00       	mov    $0x0,%ebx
 1fc:	8d 73 01             	lea    0x1(%ebx),%esi
 1ff:	3b 75 0c             	cmp    0xc(%ebp),%esi
 202:	7d 2e                	jge    232 <gets+0x47>
    cc = read(0, &c, 1);
 204:	83 ec 04             	sub    $0x4,%esp
 207:	6a 01                	push   $0x1
 209:	8d 45 e7             	lea    -0x19(%ebp),%eax
 20c:	50                   	push   %eax
 20d:	6a 00                	push   $0x0
 20f:	e8 e6 00 00 00       	call   2fa <read>
    if(cc < 1)
 214:	83 c4 10             	add    $0x10,%esp
 217:	85 c0                	test   %eax,%eax
 219:	7e 17                	jle    232 <gets+0x47>
      break;
    buf[i++] = c;
 21b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 21f:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 222:	3c 0a                	cmp    $0xa,%al
 224:	0f 94 c2             	sete   %dl
 227:	3c 0d                	cmp    $0xd,%al
 229:	0f 94 c0             	sete   %al
    buf[i++] = c;
 22c:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 22e:	08 c2                	or     %al,%dl
 230:	74 ca                	je     1fc <gets+0x11>
      break;
  }
  buf[i] = '\0';
 232:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 236:	89 f8                	mov    %edi,%eax
 238:	8d 65 f4             	lea    -0xc(%ebp),%esp
 23b:	5b                   	pop    %ebx
 23c:	5e                   	pop    %esi
 23d:	5f                   	pop    %edi
 23e:	5d                   	pop    %ebp
 23f:	c3                   	ret    

00000240 <stat>:

int
stat(const char *n, struct stat *st)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	56                   	push   %esi
 244:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 245:	83 ec 08             	sub    $0x8,%esp
 248:	6a 00                	push   $0x0
 24a:	ff 75 08             	pushl  0x8(%ebp)
 24d:	e8 d0 00 00 00       	call   322 <open>
  if(fd < 0)
 252:	83 c4 10             	add    $0x10,%esp
 255:	85 c0                	test   %eax,%eax
 257:	78 24                	js     27d <stat+0x3d>
 259:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 25b:	83 ec 08             	sub    $0x8,%esp
 25e:	ff 75 0c             	pushl  0xc(%ebp)
 261:	50                   	push   %eax
 262:	e8 d3 00 00 00       	call   33a <fstat>
 267:	89 c6                	mov    %eax,%esi
  close(fd);
 269:	89 1c 24             	mov    %ebx,(%esp)
 26c:	e8 99 00 00 00       	call   30a <close>
  return r;
 271:	83 c4 10             	add    $0x10,%esp
}
 274:	89 f0                	mov    %esi,%eax
 276:	8d 65 f8             	lea    -0x8(%ebp),%esp
 279:	5b                   	pop    %ebx
 27a:	5e                   	pop    %esi
 27b:	5d                   	pop    %ebp
 27c:	c3                   	ret    
    return -1;
 27d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 282:	eb f0                	jmp    274 <stat+0x34>

00000284 <atoi>:

int
atoi(const char *s)
{
 284:	55                   	push   %ebp
 285:	89 e5                	mov    %esp,%ebp
 287:	53                   	push   %ebx
 288:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 28b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 290:	eb 10                	jmp    2a2 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 292:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 295:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 298:	83 c1 01             	add    $0x1,%ecx
 29b:	0f be d2             	movsbl %dl,%edx
 29e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 2a2:	0f b6 11             	movzbl (%ecx),%edx
 2a5:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2a8:	80 fb 09             	cmp    $0x9,%bl
 2ab:	76 e5                	jbe    292 <atoi+0xe>
  return n;
}
 2ad:	5b                   	pop    %ebx
 2ae:	5d                   	pop    %ebp
 2af:	c3                   	ret    

000002b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	56                   	push   %esi
 2b4:	53                   	push   %ebx
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2bb:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2be:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2c0:	eb 0d                	jmp    2cf <memmove+0x1f>
    *dst++ = *src++;
 2c2:	0f b6 13             	movzbl (%ebx),%edx
 2c5:	88 11                	mov    %dl,(%ecx)
 2c7:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2ca:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2cd:	89 f2                	mov    %esi,%edx
 2cf:	8d 72 ff             	lea    -0x1(%edx),%esi
 2d2:	85 d2                	test   %edx,%edx
 2d4:	7f ec                	jg     2c2 <memmove+0x12>
  return vdst;
}
 2d6:	5b                   	pop    %ebx
 2d7:	5e                   	pop    %esi
 2d8:	5d                   	pop    %ebp
 2d9:	c3                   	ret    

000002da <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2da:	b8 01 00 00 00       	mov    $0x1,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <exit>:
SYSCALL(exit)
 2e2:	b8 02 00 00 00       	mov    $0x2,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <wait>:
SYSCALL(wait)
 2ea:	b8 03 00 00 00       	mov    $0x3,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <pipe>:
SYSCALL(pipe)
 2f2:	b8 04 00 00 00       	mov    $0x4,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <read>:
SYSCALL(read)
 2fa:	b8 05 00 00 00       	mov    $0x5,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <write>:
SYSCALL(write)
 302:	b8 10 00 00 00       	mov    $0x10,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <close>:
SYSCALL(close)
 30a:	b8 15 00 00 00       	mov    $0x15,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <kill>:
SYSCALL(kill)
 312:	b8 06 00 00 00       	mov    $0x6,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <exec>:
SYSCALL(exec)
 31a:	b8 07 00 00 00       	mov    $0x7,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <open>:
SYSCALL(open)
 322:	b8 0f 00 00 00       	mov    $0xf,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <mknod>:
SYSCALL(mknod)
 32a:	b8 11 00 00 00       	mov    $0x11,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <unlink>:
SYSCALL(unlink)
 332:	b8 12 00 00 00       	mov    $0x12,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <fstat>:
SYSCALL(fstat)
 33a:	b8 08 00 00 00       	mov    $0x8,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <link>:
SYSCALL(link)
 342:	b8 13 00 00 00       	mov    $0x13,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <mkdir>:
SYSCALL(mkdir)
 34a:	b8 14 00 00 00       	mov    $0x14,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <chdir>:
SYSCALL(chdir)
 352:	b8 09 00 00 00       	mov    $0x9,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <dup>:
SYSCALL(dup)
 35a:	b8 0a 00 00 00       	mov    $0xa,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <getpid>:
SYSCALL(getpid)
 362:	b8 0b 00 00 00       	mov    $0xb,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <sbrk>:
SYSCALL(sbrk)
 36a:	b8 0c 00 00 00       	mov    $0xc,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <sleep>:
SYSCALL(sleep)
 372:	b8 0d 00 00 00       	mov    $0xd,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <uptime>:
SYSCALL(uptime)
 37a:	b8 0e 00 00 00       	mov    $0xe,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <setpri>:
SYSCALL(setpri)
 382:	b8 16 00 00 00       	mov    $0x16,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <getpri>:
SYSCALL(getpri)
 38a:	b8 17 00 00 00       	mov    $0x17,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <getpinfo>:
SYSCALL(getpinfo)
 392:	b8 18 00 00 00       	mov    $0x18,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <fork2>:
SYSCALL(fork2)
 39a:	b8 19 00 00 00       	mov    $0x19,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a2:	55                   	push   %ebp
 3a3:	89 e5                	mov    %esp,%ebp
 3a5:	83 ec 1c             	sub    $0x1c,%esp
 3a8:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3ab:	6a 01                	push   $0x1
 3ad:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3b0:	52                   	push   %edx
 3b1:	50                   	push   %eax
 3b2:	e8 4b ff ff ff       	call   302 <write>
}
 3b7:	83 c4 10             	add    $0x10,%esp
 3ba:	c9                   	leave  
 3bb:	c3                   	ret    

000003bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3bc:	55                   	push   %ebp
 3bd:	89 e5                	mov    %esp,%ebp
 3bf:	57                   	push   %edi
 3c0:	56                   	push   %esi
 3c1:	53                   	push   %ebx
 3c2:	83 ec 2c             	sub    $0x2c,%esp
 3c5:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3cb:	0f 95 c3             	setne  %bl
 3ce:	89 d0                	mov    %edx,%eax
 3d0:	c1 e8 1f             	shr    $0x1f,%eax
 3d3:	84 c3                	test   %al,%bl
 3d5:	74 10                	je     3e7 <printint+0x2b>
    neg = 1;
    x = -xx;
 3d7:	f7 da                	neg    %edx
    neg = 1;
 3d9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3e0:	be 00 00 00 00       	mov    $0x0,%esi
 3e5:	eb 0b                	jmp    3f2 <printint+0x36>
  neg = 0;
 3e7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3ee:	eb f0                	jmp    3e0 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3f0:	89 c6                	mov    %eax,%esi
 3f2:	89 d0                	mov    %edx,%eax
 3f4:	ba 00 00 00 00       	mov    $0x0,%edx
 3f9:	f7 f1                	div    %ecx
 3fb:	89 c3                	mov    %eax,%ebx
 3fd:	8d 46 01             	lea    0x1(%esi),%eax
 400:	0f b6 92 fc 06 00 00 	movzbl 0x6fc(%edx),%edx
 407:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 40b:	89 da                	mov    %ebx,%edx
 40d:	85 db                	test   %ebx,%ebx
 40f:	75 df                	jne    3f0 <printint+0x34>
 411:	89 c3                	mov    %eax,%ebx
  if(neg)
 413:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 417:	74 16                	je     42f <printint+0x73>
    buf[i++] = '-';
 419:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 41e:	8d 5e 02             	lea    0x2(%esi),%ebx
 421:	eb 0c                	jmp    42f <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 423:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 428:	89 f8                	mov    %edi,%eax
 42a:	e8 73 ff ff ff       	call   3a2 <putc>
  while(--i >= 0)
 42f:	83 eb 01             	sub    $0x1,%ebx
 432:	79 ef                	jns    423 <printint+0x67>
}
 434:	83 c4 2c             	add    $0x2c,%esp
 437:	5b                   	pop    %ebx
 438:	5e                   	pop    %esi
 439:	5f                   	pop    %edi
 43a:	5d                   	pop    %ebp
 43b:	c3                   	ret    

0000043c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
 43f:	57                   	push   %edi
 440:	56                   	push   %esi
 441:	53                   	push   %ebx
 442:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 445:	8d 45 10             	lea    0x10(%ebp),%eax
 448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 44b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 450:	bb 00 00 00 00       	mov    $0x0,%ebx
 455:	eb 14                	jmp    46b <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 457:	89 fa                	mov    %edi,%edx
 459:	8b 45 08             	mov    0x8(%ebp),%eax
 45c:	e8 41 ff ff ff       	call   3a2 <putc>
 461:	eb 05                	jmp    468 <printf+0x2c>
      }
    } else if(state == '%'){
 463:	83 fe 25             	cmp    $0x25,%esi
 466:	74 25                	je     48d <printf+0x51>
  for(i = 0; fmt[i]; i++){
 468:	83 c3 01             	add    $0x1,%ebx
 46b:	8b 45 0c             	mov    0xc(%ebp),%eax
 46e:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 472:	84 c0                	test   %al,%al
 474:	0f 84 23 01 00 00    	je     59d <printf+0x161>
    c = fmt[i] & 0xff;
 47a:	0f be f8             	movsbl %al,%edi
 47d:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 480:	85 f6                	test   %esi,%esi
 482:	75 df                	jne    463 <printf+0x27>
      if(c == '%'){
 484:	83 f8 25             	cmp    $0x25,%eax
 487:	75 ce                	jne    457 <printf+0x1b>
        state = '%';
 489:	89 c6                	mov    %eax,%esi
 48b:	eb db                	jmp    468 <printf+0x2c>
      if(c == 'd'){
 48d:	83 f8 64             	cmp    $0x64,%eax
 490:	74 49                	je     4db <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 492:	83 f8 78             	cmp    $0x78,%eax
 495:	0f 94 c1             	sete   %cl
 498:	83 f8 70             	cmp    $0x70,%eax
 49b:	0f 94 c2             	sete   %dl
 49e:	08 d1                	or     %dl,%cl
 4a0:	75 63                	jne    505 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4a2:	83 f8 73             	cmp    $0x73,%eax
 4a5:	0f 84 84 00 00 00    	je     52f <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4ab:	83 f8 63             	cmp    $0x63,%eax
 4ae:	0f 84 b7 00 00 00    	je     56b <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4b4:	83 f8 25             	cmp    $0x25,%eax
 4b7:	0f 84 cc 00 00 00    	je     589 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4bd:	ba 25 00 00 00       	mov    $0x25,%edx
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	e8 d8 fe ff ff       	call   3a2 <putc>
        putc(fd, c);
 4ca:	89 fa                	mov    %edi,%edx
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
 4cf:	e8 ce fe ff ff       	call   3a2 <putc>
      }
      state = 0;
 4d4:	be 00 00 00 00       	mov    $0x0,%esi
 4d9:	eb 8d                	jmp    468 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4de:	8b 17                	mov    (%edi),%edx
 4e0:	83 ec 0c             	sub    $0xc,%esp
 4e3:	6a 01                	push   $0x1
 4e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4ea:	8b 45 08             	mov    0x8(%ebp),%eax
 4ed:	e8 ca fe ff ff       	call   3bc <printint>
        ap++;
 4f2:	83 c7 04             	add    $0x4,%edi
 4f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4f8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4fb:	be 00 00 00 00       	mov    $0x0,%esi
 500:	e9 63 ff ff ff       	jmp    468 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 508:	8b 17                	mov    (%edi),%edx
 50a:	83 ec 0c             	sub    $0xc,%esp
 50d:	6a 00                	push   $0x0
 50f:	b9 10 00 00 00       	mov    $0x10,%ecx
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	e8 a0 fe ff ff       	call   3bc <printint>
        ap++;
 51c:	83 c7 04             	add    $0x4,%edi
 51f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 522:	83 c4 10             	add    $0x10,%esp
      state = 0;
 525:	be 00 00 00 00       	mov    $0x0,%esi
 52a:	e9 39 ff ff ff       	jmp    468 <printf+0x2c>
        s = (char*)*ap;
 52f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 532:	8b 30                	mov    (%eax),%esi
        ap++;
 534:	83 c0 04             	add    $0x4,%eax
 537:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 53a:	85 f6                	test   %esi,%esi
 53c:	75 28                	jne    566 <printf+0x12a>
          s = "(null)";
 53e:	be f4 06 00 00       	mov    $0x6f4,%esi
 543:	8b 7d 08             	mov    0x8(%ebp),%edi
 546:	eb 0d                	jmp    555 <printf+0x119>
          putc(fd, *s);
 548:	0f be d2             	movsbl %dl,%edx
 54b:	89 f8                	mov    %edi,%eax
 54d:	e8 50 fe ff ff       	call   3a2 <putc>
          s++;
 552:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 555:	0f b6 16             	movzbl (%esi),%edx
 558:	84 d2                	test   %dl,%dl
 55a:	75 ec                	jne    548 <printf+0x10c>
      state = 0;
 55c:	be 00 00 00 00       	mov    $0x0,%esi
 561:	e9 02 ff ff ff       	jmp    468 <printf+0x2c>
 566:	8b 7d 08             	mov    0x8(%ebp),%edi
 569:	eb ea                	jmp    555 <printf+0x119>
        putc(fd, *ap);
 56b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 56e:	0f be 17             	movsbl (%edi),%edx
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	e8 29 fe ff ff       	call   3a2 <putc>
        ap++;
 579:	83 c7 04             	add    $0x4,%edi
 57c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 57f:	be 00 00 00 00       	mov    $0x0,%esi
 584:	e9 df fe ff ff       	jmp    468 <printf+0x2c>
        putc(fd, c);
 589:	89 fa                	mov    %edi,%edx
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	e8 0f fe ff ff       	call   3a2 <putc>
      state = 0;
 593:	be 00 00 00 00       	mov    $0x0,%esi
 598:	e9 cb fe ff ff       	jmp    468 <printf+0x2c>
    }
  }
}
 59d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5a0:	5b                   	pop    %ebx
 5a1:	5e                   	pop    %esi
 5a2:	5f                   	pop    %edi
 5a3:	5d                   	pop    %ebp
 5a4:	c3                   	ret    

000005a5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a5:	55                   	push   %ebp
 5a6:	89 e5                	mov    %esp,%ebp
 5a8:	57                   	push   %edi
 5a9:	56                   	push   %esi
 5aa:	53                   	push   %ebx
 5ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ae:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b1:	a1 c8 09 00 00       	mov    0x9c8,%eax
 5b6:	eb 02                	jmp    5ba <free+0x15>
 5b8:	89 d0                	mov    %edx,%eax
 5ba:	39 c8                	cmp    %ecx,%eax
 5bc:	73 04                	jae    5c2 <free+0x1d>
 5be:	39 08                	cmp    %ecx,(%eax)
 5c0:	77 12                	ja     5d4 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c2:	8b 10                	mov    (%eax),%edx
 5c4:	39 c2                	cmp    %eax,%edx
 5c6:	77 f0                	ja     5b8 <free+0x13>
 5c8:	39 c8                	cmp    %ecx,%eax
 5ca:	72 08                	jb     5d4 <free+0x2f>
 5cc:	39 ca                	cmp    %ecx,%edx
 5ce:	77 04                	ja     5d4 <free+0x2f>
 5d0:	89 d0                	mov    %edx,%eax
 5d2:	eb e6                	jmp    5ba <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5d4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5d7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5da:	8b 10                	mov    (%eax),%edx
 5dc:	39 d7                	cmp    %edx,%edi
 5de:	74 19                	je     5f9 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5e0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5e3:	8b 50 04             	mov    0x4(%eax),%edx
 5e6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5e9:	39 ce                	cmp    %ecx,%esi
 5eb:	74 1b                	je     608 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ed:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5ef:	a3 c8 09 00 00       	mov    %eax,0x9c8
}
 5f4:	5b                   	pop    %ebx
 5f5:	5e                   	pop    %esi
 5f6:	5f                   	pop    %edi
 5f7:	5d                   	pop    %ebp
 5f8:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5f9:	03 72 04             	add    0x4(%edx),%esi
 5fc:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5ff:	8b 10                	mov    (%eax),%edx
 601:	8b 12                	mov    (%edx),%edx
 603:	89 53 f8             	mov    %edx,-0x8(%ebx)
 606:	eb db                	jmp    5e3 <free+0x3e>
    p->s.size += bp->s.size;
 608:	03 53 fc             	add    -0x4(%ebx),%edx
 60b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 60e:	8b 53 f8             	mov    -0x8(%ebx),%edx
 611:	89 10                	mov    %edx,(%eax)
 613:	eb da                	jmp    5ef <free+0x4a>

00000615 <morecore>:

static Header*
morecore(uint nu)
{
 615:	55                   	push   %ebp
 616:	89 e5                	mov    %esp,%ebp
 618:	53                   	push   %ebx
 619:	83 ec 04             	sub    $0x4,%esp
 61c:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 61e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 623:	77 05                	ja     62a <morecore+0x15>
    nu = 4096;
 625:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 62a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 631:	83 ec 0c             	sub    $0xc,%esp
 634:	50                   	push   %eax
 635:	e8 30 fd ff ff       	call   36a <sbrk>
  if(p == (char*)-1)
 63a:	83 c4 10             	add    $0x10,%esp
 63d:	83 f8 ff             	cmp    $0xffffffff,%eax
 640:	74 1c                	je     65e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 642:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 645:	83 c0 08             	add    $0x8,%eax
 648:	83 ec 0c             	sub    $0xc,%esp
 64b:	50                   	push   %eax
 64c:	e8 54 ff ff ff       	call   5a5 <free>
  return freep;
 651:	a1 c8 09 00 00       	mov    0x9c8,%eax
 656:	83 c4 10             	add    $0x10,%esp
}
 659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 65c:	c9                   	leave  
 65d:	c3                   	ret    
    return 0;
 65e:	b8 00 00 00 00       	mov    $0x0,%eax
 663:	eb f4                	jmp    659 <morecore+0x44>

00000665 <malloc>:

void*
malloc(uint nbytes)
{
 665:	55                   	push   %ebp
 666:	89 e5                	mov    %esp,%ebp
 668:	53                   	push   %ebx
 669:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 66c:	8b 45 08             	mov    0x8(%ebp),%eax
 66f:	8d 58 07             	lea    0x7(%eax),%ebx
 672:	c1 eb 03             	shr    $0x3,%ebx
 675:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 678:	8b 0d c8 09 00 00    	mov    0x9c8,%ecx
 67e:	85 c9                	test   %ecx,%ecx
 680:	74 04                	je     686 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 682:	8b 01                	mov    (%ecx),%eax
 684:	eb 4d                	jmp    6d3 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 686:	c7 05 c8 09 00 00 cc 	movl   $0x9cc,0x9c8
 68d:	09 00 00 
 690:	c7 05 cc 09 00 00 cc 	movl   $0x9cc,0x9cc
 697:	09 00 00 
    base.s.size = 0;
 69a:	c7 05 d0 09 00 00 00 	movl   $0x0,0x9d0
 6a1:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 6a4:	b9 cc 09 00 00       	mov    $0x9cc,%ecx
 6a9:	eb d7                	jmp    682 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6ab:	39 da                	cmp    %ebx,%edx
 6ad:	74 1a                	je     6c9 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6af:	29 da                	sub    %ebx,%edx
 6b1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6b4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6b7:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6ba:	89 0d c8 09 00 00    	mov    %ecx,0x9c8
      return (void*)(p + 1);
 6c0:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6c3:	83 c4 04             	add    $0x4,%esp
 6c6:	5b                   	pop    %ebx
 6c7:	5d                   	pop    %ebp
 6c8:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6c9:	8b 10                	mov    (%eax),%edx
 6cb:	89 11                	mov    %edx,(%ecx)
 6cd:	eb eb                	jmp    6ba <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6cf:	89 c1                	mov    %eax,%ecx
 6d1:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6d3:	8b 50 04             	mov    0x4(%eax),%edx
 6d6:	39 da                	cmp    %ebx,%edx
 6d8:	73 d1                	jae    6ab <malloc+0x46>
    if(p == freep)
 6da:	39 05 c8 09 00 00    	cmp    %eax,0x9c8
 6e0:	75 ed                	jne    6cf <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6e2:	89 d8                	mov    %ebx,%eax
 6e4:	e8 2c ff ff ff       	call   615 <morecore>
 6e9:	85 c0                	test   %eax,%eax
 6eb:	75 e2                	jne    6cf <malloc+0x6a>
        return 0;
 6ed:	b8 00 00 00 00       	mov    $0x0,%eax
 6f2:	eb cf                	jmp    6c3 <malloc+0x5e>
