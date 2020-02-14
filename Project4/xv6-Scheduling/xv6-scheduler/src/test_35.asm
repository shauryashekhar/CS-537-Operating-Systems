
_test_35:     file format elf32-i386


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
  36:	e8 20 03 00 00       	call   35b <sleep>
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
  for (int i = 0; i < 13; ++i) {
  6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  71:	83 fb 0c             	cmp    $0xc,%ebx
  74:	0f 8f b5 00 00 00    	jg     12f <main+0xd6>
    int pid = fork2(i % 4);
  7a:	89 da                	mov    %ebx,%edx
  7c:	c1 fa 1f             	sar    $0x1f,%edx
  7f:	c1 ea 1e             	shr    $0x1e,%edx
  82:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  85:	83 e0 03             	and    $0x3,%eax
  88:	29 d0                	sub    %edx,%eax
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	50                   	push   %eax
  8e:	e8 f0 02 00 00       	call   383 <fork2>
    if (pid == 0) {
  93:	83 c4 10             	add    $0x10,%esp
  96:	85 c0                	test   %eax,%eax
  98:	74 15                	je     af <main+0x56>
        workload(140 * i, 23 * i);
        while(wait() != -1);
        exit();
      }
    } else {
      workload(i * 77, i);
  9a:	83 ec 08             	sub    $0x8,%esp
  9d:	53                   	push   %ebx
  9e:	6b c3 4d             	imul   $0x4d,%ebx,%eax
  a1:	50                   	push   %eax
  a2:	e8 59 ff ff ff       	call   0 <workload>
  for (int i = 0; i < 13; ++i) {
  a7:	83 c3 01             	add    $0x1,%ebx
  aa:	83 c4 10             	add    $0x10,%esp
  ad:	eb c2                	jmp    71 <main+0x18>
      workload(789 * i, 100);
  af:	83 ec 08             	sub    $0x8,%esp
  b2:	6a 64                	push   $0x64
  b4:	69 c3 15 03 00 00    	imul   $0x315,%ebx,%eax
  ba:	50                   	push   %eax
  bb:	e8 40 ff ff ff       	call   0 <workload>
      int pid2 = fork();
  c0:	e8 fe 01 00 00       	call   2c3 <fork>
      if (pid2 == 0) {
  c5:	83 c4 10             	add    $0x10,%esp
  c8:	85 c0                	test   %eax,%eax
  ca:	75 3e                	jne    10a <main+0xb1>
        int pid3 = fork2(i % 2);
  cc:	b9 02 00 00 00       	mov    $0x2,%ecx
  d1:	89 d8                	mov    %ebx,%eax
  d3:	99                   	cltd   
  d4:	f7 f9                	idiv   %ecx
  d6:	83 ec 0c             	sub    $0xc,%esp
  d9:	52                   	push   %edx
  da:	e8 a4 02 00 00       	call   383 <fork2>
  df:	89 c6                	mov    %eax,%esi
        workload(678 * i, 9 * i);
  e1:	83 c4 08             	add    $0x8,%esp
  e4:	6b c3 09             	imul   $0x9,%ebx,%eax
  e7:	50                   	push   %eax
  e8:	69 db a6 02 00 00    	imul   $0x2a6,%ebx,%ebx
  ee:	53                   	push   %ebx
  ef:	e8 0c ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  f4:	83 c4 10             	add    $0x10,%esp
  f7:	85 f6                	test   %esi,%esi
  f9:	74 0a                	je     105 <main+0xac>
          while(wait() != -1);
  fb:	e8 d3 01 00 00       	call   2d3 <wait>
 100:	83 f8 ff             	cmp    $0xffffffff,%eax
 103:	75 f6                	jne    fb <main+0xa2>
        exit();
 105:	e8 c1 01 00 00       	call   2cb <exit>
        workload(140 * i, 23 * i);
 10a:	83 ec 08             	sub    $0x8,%esp
 10d:	6b c3 17             	imul   $0x17,%ebx,%eax
 110:	50                   	push   %eax
 111:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
 117:	53                   	push   %ebx
 118:	e8 e3 fe ff ff       	call   0 <workload>
        while(wait() != -1);
 11d:	83 c4 10             	add    $0x10,%esp
 120:	e8 ae 01 00 00       	call   2d3 <wait>
 125:	83 f8 ff             	cmp    $0xffffffff,%eax
 128:	75 f6                	jne    120 <main+0xc7>
        exit();
 12a:	e8 9c 01 00 00       	call   2cb <exit>
    }
  }

  while(wait() != -1);
 12f:	e8 9f 01 00 00       	call   2d3 <wait>
 134:	83 f8 ff             	cmp    $0xffffffff,%eax
 137:	75 f6                	jne    12f <main+0xd6>
  exit();
 139:	e8 8d 01 00 00       	call   2cb <exit>

0000013e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 13e:	55                   	push   %ebp
 13f:	89 e5                	mov    %esp,%ebp
 141:	53                   	push   %ebx
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 148:	89 c2                	mov    %eax,%edx
 14a:	0f b6 19             	movzbl (%ecx),%ebx
 14d:	88 1a                	mov    %bl,(%edx)
 14f:	8d 52 01             	lea    0x1(%edx),%edx
 152:	8d 49 01             	lea    0x1(%ecx),%ecx
 155:	84 db                	test   %bl,%bl
 157:	75 f1                	jne    14a <strcpy+0xc>
    ;
  return os;
}
 159:	5b                   	pop    %ebx
 15a:	5d                   	pop    %ebp
 15b:	c3                   	ret    

0000015c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
 15f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 162:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 165:	eb 06                	jmp    16d <strcmp+0x11>
    p++, q++;
 167:	83 c1 01             	add    $0x1,%ecx
 16a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 16d:	0f b6 01             	movzbl (%ecx),%eax
 170:	84 c0                	test   %al,%al
 172:	74 04                	je     178 <strcmp+0x1c>
 174:	3a 02                	cmp    (%edx),%al
 176:	74 ef                	je     167 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 178:	0f b6 c0             	movzbl %al,%eax
 17b:	0f b6 12             	movzbl (%edx),%edx
 17e:	29 d0                	sub    %edx,%eax
}
 180:	5d                   	pop    %ebp
 181:	c3                   	ret    

00000182 <strlen>:

uint
strlen(const char *s)
{
 182:	55                   	push   %ebp
 183:	89 e5                	mov    %esp,%ebp
 185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 188:	ba 00 00 00 00       	mov    $0x0,%edx
 18d:	eb 03                	jmp    192 <strlen+0x10>
 18f:	83 c2 01             	add    $0x1,%edx
 192:	89 d0                	mov    %edx,%eax
 194:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 198:	75 f5                	jne    18f <strlen+0xd>
    ;
  return n;
}
 19a:	5d                   	pop    %ebp
 19b:	c3                   	ret    

0000019c <memset>:

void*
memset(void *dst, int c, uint n)
{
 19c:	55                   	push   %ebp
 19d:	89 e5                	mov    %esp,%ebp
 19f:	57                   	push   %edi
 1a0:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1a3:	89 d7                	mov    %edx,%edi
 1a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ab:	fc                   	cld    
 1ac:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1ae:	89 d0                	mov    %edx,%eax
 1b0:	5f                   	pop    %edi
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    

000001b3 <strchr>:

char*
strchr(const char *s, char c)
{
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	8b 45 08             	mov    0x8(%ebp),%eax
 1b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1bd:	0f b6 10             	movzbl (%eax),%edx
 1c0:	84 d2                	test   %dl,%dl
 1c2:	74 09                	je     1cd <strchr+0x1a>
    if(*s == c)
 1c4:	38 ca                	cmp    %cl,%dl
 1c6:	74 0a                	je     1d2 <strchr+0x1f>
  for(; *s; s++)
 1c8:	83 c0 01             	add    $0x1,%eax
 1cb:	eb f0                	jmp    1bd <strchr+0xa>
      return (char*)s;
  return 0;
 1cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d2:	5d                   	pop    %ebp
 1d3:	c3                   	ret    

000001d4 <gets>:

char*
gets(char *buf, int max)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	57                   	push   %edi
 1d8:	56                   	push   %esi
 1d9:	53                   	push   %ebx
 1da:	83 ec 1c             	sub    $0x1c,%esp
 1dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e0:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e5:	8d 73 01             	lea    0x1(%ebx),%esi
 1e8:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1eb:	7d 2e                	jge    21b <gets+0x47>
    cc = read(0, &c, 1);
 1ed:	83 ec 04             	sub    $0x4,%esp
 1f0:	6a 01                	push   $0x1
 1f2:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1f5:	50                   	push   %eax
 1f6:	6a 00                	push   $0x0
 1f8:	e8 e6 00 00 00       	call   2e3 <read>
    if(cc < 1)
 1fd:	83 c4 10             	add    $0x10,%esp
 200:	85 c0                	test   %eax,%eax
 202:	7e 17                	jle    21b <gets+0x47>
      break;
    buf[i++] = c;
 204:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 208:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 20b:	3c 0a                	cmp    $0xa,%al
 20d:	0f 94 c2             	sete   %dl
 210:	3c 0d                	cmp    $0xd,%al
 212:	0f 94 c0             	sete   %al
    buf[i++] = c;
 215:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 217:	08 c2                	or     %al,%dl
 219:	74 ca                	je     1e5 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 21b:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 21f:	89 f8                	mov    %edi,%eax
 221:	8d 65 f4             	lea    -0xc(%ebp),%esp
 224:	5b                   	pop    %ebx
 225:	5e                   	pop    %esi
 226:	5f                   	pop    %edi
 227:	5d                   	pop    %ebp
 228:	c3                   	ret    

00000229 <stat>:

int
stat(const char *n, struct stat *st)
{
 229:	55                   	push   %ebp
 22a:	89 e5                	mov    %esp,%ebp
 22c:	56                   	push   %esi
 22d:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22e:	83 ec 08             	sub    $0x8,%esp
 231:	6a 00                	push   $0x0
 233:	ff 75 08             	pushl  0x8(%ebp)
 236:	e8 d0 00 00 00       	call   30b <open>
  if(fd < 0)
 23b:	83 c4 10             	add    $0x10,%esp
 23e:	85 c0                	test   %eax,%eax
 240:	78 24                	js     266 <stat+0x3d>
 242:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 244:	83 ec 08             	sub    $0x8,%esp
 247:	ff 75 0c             	pushl  0xc(%ebp)
 24a:	50                   	push   %eax
 24b:	e8 d3 00 00 00       	call   323 <fstat>
 250:	89 c6                	mov    %eax,%esi
  close(fd);
 252:	89 1c 24             	mov    %ebx,(%esp)
 255:	e8 99 00 00 00       	call   2f3 <close>
  return r;
 25a:	83 c4 10             	add    $0x10,%esp
}
 25d:	89 f0                	mov    %esi,%eax
 25f:	8d 65 f8             	lea    -0x8(%ebp),%esp
 262:	5b                   	pop    %ebx
 263:	5e                   	pop    %esi
 264:	5d                   	pop    %ebp
 265:	c3                   	ret    
    return -1;
 266:	be ff ff ff ff       	mov    $0xffffffff,%esi
 26b:	eb f0                	jmp    25d <stat+0x34>

0000026d <atoi>:

int
atoi(const char *s)
{
 26d:	55                   	push   %ebp
 26e:	89 e5                	mov    %esp,%ebp
 270:	53                   	push   %ebx
 271:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 274:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 279:	eb 10                	jmp    28b <atoi+0x1e>
    n = n*10 + *s++ - '0';
 27b:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 27e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 281:	83 c1 01             	add    $0x1,%ecx
 284:	0f be d2             	movsbl %dl,%edx
 287:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 28b:	0f b6 11             	movzbl (%ecx),%edx
 28e:	8d 5a d0             	lea    -0x30(%edx),%ebx
 291:	80 fb 09             	cmp    $0x9,%bl
 294:	76 e5                	jbe    27b <atoi+0xe>
  return n;
}
 296:	5b                   	pop    %ebx
 297:	5d                   	pop    %ebp
 298:	c3                   	ret    

00000299 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	56                   	push   %esi
 29d:	53                   	push   %ebx
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2a4:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2a7:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2a9:	eb 0d                	jmp    2b8 <memmove+0x1f>
    *dst++ = *src++;
 2ab:	0f b6 13             	movzbl (%ebx),%edx
 2ae:	88 11                	mov    %dl,(%ecx)
 2b0:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2b3:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2b6:	89 f2                	mov    %esi,%edx
 2b8:	8d 72 ff             	lea    -0x1(%edx),%esi
 2bb:	85 d2                	test   %edx,%edx
 2bd:	7f ec                	jg     2ab <memmove+0x12>
  return vdst;
}
 2bf:	5b                   	pop    %ebx
 2c0:	5e                   	pop    %esi
 2c1:	5d                   	pop    %ebp
 2c2:	c3                   	ret    

000002c3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c3:	b8 01 00 00 00       	mov    $0x1,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <exit>:
SYSCALL(exit)
 2cb:	b8 02 00 00 00       	mov    $0x2,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <wait>:
SYSCALL(wait)
 2d3:	b8 03 00 00 00       	mov    $0x3,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <pipe>:
SYSCALL(pipe)
 2db:	b8 04 00 00 00       	mov    $0x4,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <read>:
SYSCALL(read)
 2e3:	b8 05 00 00 00       	mov    $0x5,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <write>:
SYSCALL(write)
 2eb:	b8 10 00 00 00       	mov    $0x10,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <close>:
SYSCALL(close)
 2f3:	b8 15 00 00 00       	mov    $0x15,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <kill>:
SYSCALL(kill)
 2fb:	b8 06 00 00 00       	mov    $0x6,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <exec>:
SYSCALL(exec)
 303:	b8 07 00 00 00       	mov    $0x7,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <open>:
SYSCALL(open)
 30b:	b8 0f 00 00 00       	mov    $0xf,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <mknod>:
SYSCALL(mknod)
 313:	b8 11 00 00 00       	mov    $0x11,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <unlink>:
SYSCALL(unlink)
 31b:	b8 12 00 00 00       	mov    $0x12,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <fstat>:
SYSCALL(fstat)
 323:	b8 08 00 00 00       	mov    $0x8,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <link>:
SYSCALL(link)
 32b:	b8 13 00 00 00       	mov    $0x13,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <mkdir>:
SYSCALL(mkdir)
 333:	b8 14 00 00 00       	mov    $0x14,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <chdir>:
SYSCALL(chdir)
 33b:	b8 09 00 00 00       	mov    $0x9,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <dup>:
SYSCALL(dup)
 343:	b8 0a 00 00 00       	mov    $0xa,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <getpid>:
SYSCALL(getpid)
 34b:	b8 0b 00 00 00       	mov    $0xb,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <sbrk>:
SYSCALL(sbrk)
 353:	b8 0c 00 00 00       	mov    $0xc,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <sleep>:
SYSCALL(sleep)
 35b:	b8 0d 00 00 00       	mov    $0xd,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <uptime>:
SYSCALL(uptime)
 363:	b8 0e 00 00 00       	mov    $0xe,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <setpri>:
SYSCALL(setpri)
 36b:	b8 16 00 00 00       	mov    $0x16,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <getpri>:
SYSCALL(getpri)
 373:	b8 17 00 00 00       	mov    $0x17,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <getpinfo>:
SYSCALL(getpinfo)
 37b:	b8 18 00 00 00       	mov    $0x18,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <fork2>:
SYSCALL(fork2)
 383:	b8 19 00 00 00       	mov    $0x19,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 38b:	55                   	push   %ebp
 38c:	89 e5                	mov    %esp,%ebp
 38e:	83 ec 1c             	sub    $0x1c,%esp
 391:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 394:	6a 01                	push   $0x1
 396:	8d 55 f4             	lea    -0xc(%ebp),%edx
 399:	52                   	push   %edx
 39a:	50                   	push   %eax
 39b:	e8 4b ff ff ff       	call   2eb <write>
}
 3a0:	83 c4 10             	add    $0x10,%esp
 3a3:	c9                   	leave  
 3a4:	c3                   	ret    

000003a5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	57                   	push   %edi
 3a9:	56                   	push   %esi
 3aa:	53                   	push   %ebx
 3ab:	83 ec 2c             	sub    $0x2c,%esp
 3ae:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3b4:	0f 95 c3             	setne  %bl
 3b7:	89 d0                	mov    %edx,%eax
 3b9:	c1 e8 1f             	shr    $0x1f,%eax
 3bc:	84 c3                	test   %al,%bl
 3be:	74 10                	je     3d0 <printint+0x2b>
    neg = 1;
    x = -xx;
 3c0:	f7 da                	neg    %edx
    neg = 1;
 3c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3c9:	be 00 00 00 00       	mov    $0x0,%esi
 3ce:	eb 0b                	jmp    3db <printint+0x36>
  neg = 0;
 3d0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3d7:	eb f0                	jmp    3c9 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3d9:	89 c6                	mov    %eax,%esi
 3db:	89 d0                	mov    %edx,%eax
 3dd:	ba 00 00 00 00       	mov    $0x0,%edx
 3e2:	f7 f1                	div    %ecx
 3e4:	89 c3                	mov    %eax,%ebx
 3e6:	8d 46 01             	lea    0x1(%esi),%eax
 3e9:	0f b6 92 e8 06 00 00 	movzbl 0x6e8(%edx),%edx
 3f0:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3f4:	89 da                	mov    %ebx,%edx
 3f6:	85 db                	test   %ebx,%ebx
 3f8:	75 df                	jne    3d9 <printint+0x34>
 3fa:	89 c3                	mov    %eax,%ebx
  if(neg)
 3fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 400:	74 16                	je     418 <printint+0x73>
    buf[i++] = '-';
 402:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 407:	8d 5e 02             	lea    0x2(%esi),%ebx
 40a:	eb 0c                	jmp    418 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 40c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 411:	89 f8                	mov    %edi,%eax
 413:	e8 73 ff ff ff       	call   38b <putc>
  while(--i >= 0)
 418:	83 eb 01             	sub    $0x1,%ebx
 41b:	79 ef                	jns    40c <printint+0x67>
}
 41d:	83 c4 2c             	add    $0x2c,%esp
 420:	5b                   	pop    %ebx
 421:	5e                   	pop    %esi
 422:	5f                   	pop    %edi
 423:	5d                   	pop    %ebp
 424:	c3                   	ret    

00000425 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 425:	55                   	push   %ebp
 426:	89 e5                	mov    %esp,%ebp
 428:	57                   	push   %edi
 429:	56                   	push   %esi
 42a:	53                   	push   %ebx
 42b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 42e:	8d 45 10             	lea    0x10(%ebp),%eax
 431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 434:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 439:	bb 00 00 00 00       	mov    $0x0,%ebx
 43e:	eb 14                	jmp    454 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 440:	89 fa                	mov    %edi,%edx
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	e8 41 ff ff ff       	call   38b <putc>
 44a:	eb 05                	jmp    451 <printf+0x2c>
      }
    } else if(state == '%'){
 44c:	83 fe 25             	cmp    $0x25,%esi
 44f:	74 25                	je     476 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 451:	83 c3 01             	add    $0x1,%ebx
 454:	8b 45 0c             	mov    0xc(%ebp),%eax
 457:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 45b:	84 c0                	test   %al,%al
 45d:	0f 84 23 01 00 00    	je     586 <printf+0x161>
    c = fmt[i] & 0xff;
 463:	0f be f8             	movsbl %al,%edi
 466:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 469:	85 f6                	test   %esi,%esi
 46b:	75 df                	jne    44c <printf+0x27>
      if(c == '%'){
 46d:	83 f8 25             	cmp    $0x25,%eax
 470:	75 ce                	jne    440 <printf+0x1b>
        state = '%';
 472:	89 c6                	mov    %eax,%esi
 474:	eb db                	jmp    451 <printf+0x2c>
      if(c == 'd'){
 476:	83 f8 64             	cmp    $0x64,%eax
 479:	74 49                	je     4c4 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 47b:	83 f8 78             	cmp    $0x78,%eax
 47e:	0f 94 c1             	sete   %cl
 481:	83 f8 70             	cmp    $0x70,%eax
 484:	0f 94 c2             	sete   %dl
 487:	08 d1                	or     %dl,%cl
 489:	75 63                	jne    4ee <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 48b:	83 f8 73             	cmp    $0x73,%eax
 48e:	0f 84 84 00 00 00    	je     518 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 494:	83 f8 63             	cmp    $0x63,%eax
 497:	0f 84 b7 00 00 00    	je     554 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 49d:	83 f8 25             	cmp    $0x25,%eax
 4a0:	0f 84 cc 00 00 00    	je     572 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4a6:	ba 25 00 00 00       	mov    $0x25,%edx
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	e8 d8 fe ff ff       	call   38b <putc>
        putc(fd, c);
 4b3:	89 fa                	mov    %edi,%edx
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
 4b8:	e8 ce fe ff ff       	call   38b <putc>
      }
      state = 0;
 4bd:	be 00 00 00 00       	mov    $0x0,%esi
 4c2:	eb 8d                	jmp    451 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c7:	8b 17                	mov    (%edi),%edx
 4c9:	83 ec 0c             	sub    $0xc,%esp
 4cc:	6a 01                	push   $0x1
 4ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	e8 ca fe ff ff       	call   3a5 <printint>
        ap++;
 4db:	83 c7 04             	add    $0x4,%edi
 4de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4e4:	be 00 00 00 00       	mov    $0x0,%esi
 4e9:	e9 63 ff ff ff       	jmp    451 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f1:	8b 17                	mov    (%edi),%edx
 4f3:	83 ec 0c             	sub    $0xc,%esp
 4f6:	6a 00                	push   $0x0
 4f8:	b9 10 00 00 00       	mov    $0x10,%ecx
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
 500:	e8 a0 fe ff ff       	call   3a5 <printint>
        ap++;
 505:	83 c7 04             	add    $0x4,%edi
 508:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 50b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 50e:	be 00 00 00 00       	mov    $0x0,%esi
 513:	e9 39 ff ff ff       	jmp    451 <printf+0x2c>
        s = (char*)*ap;
 518:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51b:	8b 30                	mov    (%eax),%esi
        ap++;
 51d:	83 c0 04             	add    $0x4,%eax
 520:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 523:	85 f6                	test   %esi,%esi
 525:	75 28                	jne    54f <printf+0x12a>
          s = "(null)";
 527:	be e0 06 00 00       	mov    $0x6e0,%esi
 52c:	8b 7d 08             	mov    0x8(%ebp),%edi
 52f:	eb 0d                	jmp    53e <printf+0x119>
          putc(fd, *s);
 531:	0f be d2             	movsbl %dl,%edx
 534:	89 f8                	mov    %edi,%eax
 536:	e8 50 fe ff ff       	call   38b <putc>
          s++;
 53b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 53e:	0f b6 16             	movzbl (%esi),%edx
 541:	84 d2                	test   %dl,%dl
 543:	75 ec                	jne    531 <printf+0x10c>
      state = 0;
 545:	be 00 00 00 00       	mov    $0x0,%esi
 54a:	e9 02 ff ff ff       	jmp    451 <printf+0x2c>
 54f:	8b 7d 08             	mov    0x8(%ebp),%edi
 552:	eb ea                	jmp    53e <printf+0x119>
        putc(fd, *ap);
 554:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 557:	0f be 17             	movsbl (%edi),%edx
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	e8 29 fe ff ff       	call   38b <putc>
        ap++;
 562:	83 c7 04             	add    $0x4,%edi
 565:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 568:	be 00 00 00 00       	mov    $0x0,%esi
 56d:	e9 df fe ff ff       	jmp    451 <printf+0x2c>
        putc(fd, c);
 572:	89 fa                	mov    %edi,%edx
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	e8 0f fe ff ff       	call   38b <putc>
      state = 0;
 57c:	be 00 00 00 00       	mov    $0x0,%esi
 581:	e9 cb fe ff ff       	jmp    451 <printf+0x2c>
    }
  }
}
 586:	8d 65 f4             	lea    -0xc(%ebp),%esp
 589:	5b                   	pop    %ebx
 58a:	5e                   	pop    %esi
 58b:	5f                   	pop    %edi
 58c:	5d                   	pop    %ebp
 58d:	c3                   	ret    

0000058e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 58e:	55                   	push   %ebp
 58f:	89 e5                	mov    %esp,%ebp
 591:	57                   	push   %edi
 592:	56                   	push   %esi
 593:	53                   	push   %ebx
 594:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 597:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 59a:	a1 b0 09 00 00       	mov    0x9b0,%eax
 59f:	eb 02                	jmp    5a3 <free+0x15>
 5a1:	89 d0                	mov    %edx,%eax
 5a3:	39 c8                	cmp    %ecx,%eax
 5a5:	73 04                	jae    5ab <free+0x1d>
 5a7:	39 08                	cmp    %ecx,(%eax)
 5a9:	77 12                	ja     5bd <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5ab:	8b 10                	mov    (%eax),%edx
 5ad:	39 c2                	cmp    %eax,%edx
 5af:	77 f0                	ja     5a1 <free+0x13>
 5b1:	39 c8                	cmp    %ecx,%eax
 5b3:	72 08                	jb     5bd <free+0x2f>
 5b5:	39 ca                	cmp    %ecx,%edx
 5b7:	77 04                	ja     5bd <free+0x2f>
 5b9:	89 d0                	mov    %edx,%eax
 5bb:	eb e6                	jmp    5a3 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5bd:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5c0:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5c3:	8b 10                	mov    (%eax),%edx
 5c5:	39 d7                	cmp    %edx,%edi
 5c7:	74 19                	je     5e2 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5c9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5cc:	8b 50 04             	mov    0x4(%eax),%edx
 5cf:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5d2:	39 ce                	cmp    %ecx,%esi
 5d4:	74 1b                	je     5f1 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5d6:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5d8:	a3 b0 09 00 00       	mov    %eax,0x9b0
}
 5dd:	5b                   	pop    %ebx
 5de:	5e                   	pop    %esi
 5df:	5f                   	pop    %edi
 5e0:	5d                   	pop    %ebp
 5e1:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5e2:	03 72 04             	add    0x4(%edx),%esi
 5e5:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5e8:	8b 10                	mov    (%eax),%edx
 5ea:	8b 12                	mov    (%edx),%edx
 5ec:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5ef:	eb db                	jmp    5cc <free+0x3e>
    p->s.size += bp->s.size;
 5f1:	03 53 fc             	add    -0x4(%ebx),%edx
 5f4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5f7:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5fa:	89 10                	mov    %edx,(%eax)
 5fc:	eb da                	jmp    5d8 <free+0x4a>

000005fe <morecore>:

static Header*
morecore(uint nu)
{
 5fe:	55                   	push   %ebp
 5ff:	89 e5                	mov    %esp,%ebp
 601:	53                   	push   %ebx
 602:	83 ec 04             	sub    $0x4,%esp
 605:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 607:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 60c:	77 05                	ja     613 <morecore+0x15>
    nu = 4096;
 60e:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 613:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 61a:	83 ec 0c             	sub    $0xc,%esp
 61d:	50                   	push   %eax
 61e:	e8 30 fd ff ff       	call   353 <sbrk>
  if(p == (char*)-1)
 623:	83 c4 10             	add    $0x10,%esp
 626:	83 f8 ff             	cmp    $0xffffffff,%eax
 629:	74 1c                	je     647 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 62b:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 62e:	83 c0 08             	add    $0x8,%eax
 631:	83 ec 0c             	sub    $0xc,%esp
 634:	50                   	push   %eax
 635:	e8 54 ff ff ff       	call   58e <free>
  return freep;
 63a:	a1 b0 09 00 00       	mov    0x9b0,%eax
 63f:	83 c4 10             	add    $0x10,%esp
}
 642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 645:	c9                   	leave  
 646:	c3                   	ret    
    return 0;
 647:	b8 00 00 00 00       	mov    $0x0,%eax
 64c:	eb f4                	jmp    642 <morecore+0x44>

0000064e <malloc>:

void*
malloc(uint nbytes)
{
 64e:	55                   	push   %ebp
 64f:	89 e5                	mov    %esp,%ebp
 651:	53                   	push   %ebx
 652:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	8d 58 07             	lea    0x7(%eax),%ebx
 65b:	c1 eb 03             	shr    $0x3,%ebx
 65e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 661:	8b 0d b0 09 00 00    	mov    0x9b0,%ecx
 667:	85 c9                	test   %ecx,%ecx
 669:	74 04                	je     66f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 66b:	8b 01                	mov    (%ecx),%eax
 66d:	eb 4d                	jmp    6bc <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 66f:	c7 05 b0 09 00 00 b4 	movl   $0x9b4,0x9b0
 676:	09 00 00 
 679:	c7 05 b4 09 00 00 b4 	movl   $0x9b4,0x9b4
 680:	09 00 00 
    base.s.size = 0;
 683:	c7 05 b8 09 00 00 00 	movl   $0x0,0x9b8
 68a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 68d:	b9 b4 09 00 00       	mov    $0x9b4,%ecx
 692:	eb d7                	jmp    66b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 694:	39 da                	cmp    %ebx,%edx
 696:	74 1a                	je     6b2 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 698:	29 da                	sub    %ebx,%edx
 69a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 69d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6a0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6a3:	89 0d b0 09 00 00    	mov    %ecx,0x9b0
      return (void*)(p + 1);
 6a9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6ac:	83 c4 04             	add    $0x4,%esp
 6af:	5b                   	pop    %ebx
 6b0:	5d                   	pop    %ebp
 6b1:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6b2:	8b 10                	mov    (%eax),%edx
 6b4:	89 11                	mov    %edx,(%ecx)
 6b6:	eb eb                	jmp    6a3 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6b8:	89 c1                	mov    %eax,%ecx
 6ba:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6bc:	8b 50 04             	mov    0x4(%eax),%edx
 6bf:	39 da                	cmp    %ebx,%edx
 6c1:	73 d1                	jae    694 <malloc+0x46>
    if(p == freep)
 6c3:	39 05 b0 09 00 00    	cmp    %eax,0x9b0
 6c9:	75 ed                	jne    6b8 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6cb:	89 d8                	mov    %ebx,%eax
 6cd:	e8 2c ff ff ff       	call   5fe <morecore>
 6d2:	85 c0                	test   %eax,%eax
 6d4:	75 e2                	jne    6b8 <malloc+0x6a>
        return 0;
 6d6:	b8 00 00 00 00       	mov    $0x0,%eax
 6db:	eb cf                	jmp    6ac <malloc+0x5e>
