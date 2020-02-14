
_test_34:     file format elf32-i386


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
  36:	e8 24 03 00 00       	call   35f <sleep>
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
  for (int i = 0; i < 14; ++i) {
  6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  71:	83 fb 0d             	cmp    $0xd,%ebx
  74:	0f 8f b9 00 00 00    	jg     133 <main+0xda>
    int pid = fork2(i % 4);
  7a:	89 da                	mov    %ebx,%edx
  7c:	c1 fa 1f             	sar    $0x1f,%edx
  7f:	c1 ea 1e             	shr    $0x1e,%edx
  82:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  85:	83 e0 03             	and    $0x3,%eax
  88:	29 d0                	sub    %edx,%eax
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	50                   	push   %eax
  8e:	e8 f4 02 00 00       	call   387 <fork2>
    if (pid == 0) {
  93:	83 c4 10             	add    $0x10,%esp
  96:	85 c0                	test   %eax,%eax
  98:	74 19                	je     b3 <main+0x5a>
        workload(1929 * i, 20 * i);
        while(wait() != -1);
        exit();
      }
    } else {
      workload(i * 33, i);
  9a:	83 ec 08             	sub    $0x8,%esp
  9d:	53                   	push   %ebx
  9e:	89 d8                	mov    %ebx,%eax
  a0:	c1 e0 05             	shl    $0x5,%eax
  a3:	01 d8                	add    %ebx,%eax
  a5:	50                   	push   %eax
  a6:	e8 55 ff ff ff       	call   0 <workload>
  for (int i = 0; i < 14; ++i) {
  ab:	83 c3 01             	add    $0x1,%ebx
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	eb be                	jmp    71 <main+0x18>
      workload(23456 * i, 10);
  b3:	83 ec 08             	sub    $0x8,%esp
  b6:	6a 0a                	push   $0xa
  b8:	69 c3 a0 5b 00 00    	imul   $0x5ba0,%ebx,%eax
  be:	50                   	push   %eax
  bf:	e8 3c ff ff ff       	call   0 <workload>
      int pid2 = fork();
  c4:	e8 fe 01 00 00       	call   2c7 <fork>
      if (pid2 == 0) {
  c9:	83 c4 10             	add    $0x10,%esp
  cc:	85 c0                	test   %eax,%eax
  ce:	75 3e                	jne    10e <main+0xb5>
        int pid3 = fork2(i % 2);
  d0:	b9 02 00 00 00       	mov    $0x2,%ecx
  d5:	89 d8                	mov    %ebx,%eax
  d7:	99                   	cltd   
  d8:	f7 f9                	idiv   %ecx
  da:	83 ec 0c             	sub    $0xc,%esp
  dd:	52                   	push   %edx
  de:	e8 a4 02 00 00       	call   387 <fork2>
  e3:	89 c6                	mov    %eax,%esi
        workload(4567 * i, 89 * i);
  e5:	83 c4 08             	add    $0x8,%esp
  e8:	6b c3 59             	imul   $0x59,%ebx,%eax
  eb:	50                   	push   %eax
  ec:	69 db d7 11 00 00    	imul   $0x11d7,%ebx,%ebx
  f2:	53                   	push   %ebx
  f3:	e8 08 ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  f8:	83 c4 10             	add    $0x10,%esp
  fb:	85 f6                	test   %esi,%esi
  fd:	74 0a                	je     109 <main+0xb0>
          while(wait() != -1);
  ff:	e8 d3 01 00 00       	call   2d7 <wait>
 104:	83 f8 ff             	cmp    $0xffffffff,%eax
 107:	75 f6                	jne    ff <main+0xa6>
        exit();
 109:	e8 c1 01 00 00       	call   2cf <exit>
        workload(1929 * i, 20 * i);
 10e:	83 ec 08             	sub    $0x8,%esp
 111:	6b c3 14             	imul   $0x14,%ebx,%eax
 114:	50                   	push   %eax
 115:	69 db 89 07 00 00    	imul   $0x789,%ebx,%ebx
 11b:	53                   	push   %ebx
 11c:	e8 df fe ff ff       	call   0 <workload>
        while(wait() != -1);
 121:	83 c4 10             	add    $0x10,%esp
 124:	e8 ae 01 00 00       	call   2d7 <wait>
 129:	83 f8 ff             	cmp    $0xffffffff,%eax
 12c:	75 f6                	jne    124 <main+0xcb>
        exit();
 12e:	e8 9c 01 00 00       	call   2cf <exit>
    }
  }

  while(wait() != -1);
 133:	e8 9f 01 00 00       	call   2d7 <wait>
 138:	83 f8 ff             	cmp    $0xffffffff,%eax
 13b:	75 f6                	jne    133 <main+0xda>
  exit();
 13d:	e8 8d 01 00 00       	call   2cf <exit>

00000142 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	53                   	push   %ebx
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 14c:	89 c2                	mov    %eax,%edx
 14e:	0f b6 19             	movzbl (%ecx),%ebx
 151:	88 1a                	mov    %bl,(%edx)
 153:	8d 52 01             	lea    0x1(%edx),%edx
 156:	8d 49 01             	lea    0x1(%ecx),%ecx
 159:	84 db                	test   %bl,%bl
 15b:	75 f1                	jne    14e <strcpy+0xc>
    ;
  return os;
}
 15d:	5b                   	pop    %ebx
 15e:	5d                   	pop    %ebp
 15f:	c3                   	ret    

00000160 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	8b 4d 08             	mov    0x8(%ebp),%ecx
 166:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 169:	eb 06                	jmp    171 <strcmp+0x11>
    p++, q++;
 16b:	83 c1 01             	add    $0x1,%ecx
 16e:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 171:	0f b6 01             	movzbl (%ecx),%eax
 174:	84 c0                	test   %al,%al
 176:	74 04                	je     17c <strcmp+0x1c>
 178:	3a 02                	cmp    (%edx),%al
 17a:	74 ef                	je     16b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 17c:	0f b6 c0             	movzbl %al,%eax
 17f:	0f b6 12             	movzbl (%edx),%edx
 182:	29 d0                	sub    %edx,%eax
}
 184:	5d                   	pop    %ebp
 185:	c3                   	ret    

00000186 <strlen>:

uint
strlen(const char *s)
{
 186:	55                   	push   %ebp
 187:	89 e5                	mov    %esp,%ebp
 189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 18c:	ba 00 00 00 00       	mov    $0x0,%edx
 191:	eb 03                	jmp    196 <strlen+0x10>
 193:	83 c2 01             	add    $0x1,%edx
 196:	89 d0                	mov    %edx,%eax
 198:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 19c:	75 f5                	jne    193 <strlen+0xd>
    ;
  return n;
}
 19e:	5d                   	pop    %ebp
 19f:	c3                   	ret    

000001a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	57                   	push   %edi
 1a4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1a7:	89 d7                	mov    %edx,%edi
 1a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 1af:	fc                   	cld    
 1b0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1b2:	89 d0                	mov    %edx,%eax
 1b4:	5f                   	pop    %edi
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    

000001b7 <strchr>:

char*
strchr(const char *s, char c)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1c1:	0f b6 10             	movzbl (%eax),%edx
 1c4:	84 d2                	test   %dl,%dl
 1c6:	74 09                	je     1d1 <strchr+0x1a>
    if(*s == c)
 1c8:	38 ca                	cmp    %cl,%dl
 1ca:	74 0a                	je     1d6 <strchr+0x1f>
  for(; *s; s++)
 1cc:	83 c0 01             	add    $0x1,%eax
 1cf:	eb f0                	jmp    1c1 <strchr+0xa>
      return (char*)s;
  return 0;
 1d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d6:	5d                   	pop    %ebp
 1d7:	c3                   	ret    

000001d8 <gets>:

char*
gets(char *buf, int max)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	57                   	push   %edi
 1dc:	56                   	push   %esi
 1dd:	53                   	push   %ebx
 1de:	83 ec 1c             	sub    $0x1c,%esp
 1e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e9:	8d 73 01             	lea    0x1(%ebx),%esi
 1ec:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1ef:	7d 2e                	jge    21f <gets+0x47>
    cc = read(0, &c, 1);
 1f1:	83 ec 04             	sub    $0x4,%esp
 1f4:	6a 01                	push   $0x1
 1f6:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1f9:	50                   	push   %eax
 1fa:	6a 00                	push   $0x0
 1fc:	e8 e6 00 00 00       	call   2e7 <read>
    if(cc < 1)
 201:	83 c4 10             	add    $0x10,%esp
 204:	85 c0                	test   %eax,%eax
 206:	7e 17                	jle    21f <gets+0x47>
      break;
    buf[i++] = c;
 208:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 20c:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 20f:	3c 0a                	cmp    $0xa,%al
 211:	0f 94 c2             	sete   %dl
 214:	3c 0d                	cmp    $0xd,%al
 216:	0f 94 c0             	sete   %al
    buf[i++] = c;
 219:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 21b:	08 c2                	or     %al,%dl
 21d:	74 ca                	je     1e9 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 21f:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 223:	89 f8                	mov    %edi,%eax
 225:	8d 65 f4             	lea    -0xc(%ebp),%esp
 228:	5b                   	pop    %ebx
 229:	5e                   	pop    %esi
 22a:	5f                   	pop    %edi
 22b:	5d                   	pop    %ebp
 22c:	c3                   	ret    

0000022d <stat>:

int
stat(const char *n, struct stat *st)
{
 22d:	55                   	push   %ebp
 22e:	89 e5                	mov    %esp,%ebp
 230:	56                   	push   %esi
 231:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 232:	83 ec 08             	sub    $0x8,%esp
 235:	6a 00                	push   $0x0
 237:	ff 75 08             	pushl  0x8(%ebp)
 23a:	e8 d0 00 00 00       	call   30f <open>
  if(fd < 0)
 23f:	83 c4 10             	add    $0x10,%esp
 242:	85 c0                	test   %eax,%eax
 244:	78 24                	js     26a <stat+0x3d>
 246:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 248:	83 ec 08             	sub    $0x8,%esp
 24b:	ff 75 0c             	pushl  0xc(%ebp)
 24e:	50                   	push   %eax
 24f:	e8 d3 00 00 00       	call   327 <fstat>
 254:	89 c6                	mov    %eax,%esi
  close(fd);
 256:	89 1c 24             	mov    %ebx,(%esp)
 259:	e8 99 00 00 00       	call   2f7 <close>
  return r;
 25e:	83 c4 10             	add    $0x10,%esp
}
 261:	89 f0                	mov    %esi,%eax
 263:	8d 65 f8             	lea    -0x8(%ebp),%esp
 266:	5b                   	pop    %ebx
 267:	5e                   	pop    %esi
 268:	5d                   	pop    %ebp
 269:	c3                   	ret    
    return -1;
 26a:	be ff ff ff ff       	mov    $0xffffffff,%esi
 26f:	eb f0                	jmp    261 <stat+0x34>

00000271 <atoi>:

int
atoi(const char *s)
{
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	53                   	push   %ebx
 275:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 278:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 27d:	eb 10                	jmp    28f <atoi+0x1e>
    n = n*10 + *s++ - '0';
 27f:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 282:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 285:	83 c1 01             	add    $0x1,%ecx
 288:	0f be d2             	movsbl %dl,%edx
 28b:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 28f:	0f b6 11             	movzbl (%ecx),%edx
 292:	8d 5a d0             	lea    -0x30(%edx),%ebx
 295:	80 fb 09             	cmp    $0x9,%bl
 298:	76 e5                	jbe    27f <atoi+0xe>
  return n;
}
 29a:	5b                   	pop    %ebx
 29b:	5d                   	pop    %ebp
 29c:	c3                   	ret    

0000029d <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	56                   	push   %esi
 2a1:	53                   	push   %ebx
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
 2a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2a8:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2ab:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2ad:	eb 0d                	jmp    2bc <memmove+0x1f>
    *dst++ = *src++;
 2af:	0f b6 13             	movzbl (%ebx),%edx
 2b2:	88 11                	mov    %dl,(%ecx)
 2b4:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2b7:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2ba:	89 f2                	mov    %esi,%edx
 2bc:	8d 72 ff             	lea    -0x1(%edx),%esi
 2bf:	85 d2                	test   %edx,%edx
 2c1:	7f ec                	jg     2af <memmove+0x12>
  return vdst;
}
 2c3:	5b                   	pop    %ebx
 2c4:	5e                   	pop    %esi
 2c5:	5d                   	pop    %ebp
 2c6:	c3                   	ret    

000002c7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c7:	b8 01 00 00 00       	mov    $0x1,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <exit>:
SYSCALL(exit)
 2cf:	b8 02 00 00 00       	mov    $0x2,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <wait>:
SYSCALL(wait)
 2d7:	b8 03 00 00 00       	mov    $0x3,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <pipe>:
SYSCALL(pipe)
 2df:	b8 04 00 00 00       	mov    $0x4,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <read>:
SYSCALL(read)
 2e7:	b8 05 00 00 00       	mov    $0x5,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <write>:
SYSCALL(write)
 2ef:	b8 10 00 00 00       	mov    $0x10,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <close>:
SYSCALL(close)
 2f7:	b8 15 00 00 00       	mov    $0x15,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <kill>:
SYSCALL(kill)
 2ff:	b8 06 00 00 00       	mov    $0x6,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <exec>:
SYSCALL(exec)
 307:	b8 07 00 00 00       	mov    $0x7,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <open>:
SYSCALL(open)
 30f:	b8 0f 00 00 00       	mov    $0xf,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <mknod>:
SYSCALL(mknod)
 317:	b8 11 00 00 00       	mov    $0x11,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <unlink>:
SYSCALL(unlink)
 31f:	b8 12 00 00 00       	mov    $0x12,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <fstat>:
SYSCALL(fstat)
 327:	b8 08 00 00 00       	mov    $0x8,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <link>:
SYSCALL(link)
 32f:	b8 13 00 00 00       	mov    $0x13,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <mkdir>:
SYSCALL(mkdir)
 337:	b8 14 00 00 00       	mov    $0x14,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <chdir>:
SYSCALL(chdir)
 33f:	b8 09 00 00 00       	mov    $0x9,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <dup>:
SYSCALL(dup)
 347:	b8 0a 00 00 00       	mov    $0xa,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <getpid>:
SYSCALL(getpid)
 34f:	b8 0b 00 00 00       	mov    $0xb,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <sbrk>:
SYSCALL(sbrk)
 357:	b8 0c 00 00 00       	mov    $0xc,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <sleep>:
SYSCALL(sleep)
 35f:	b8 0d 00 00 00       	mov    $0xd,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <uptime>:
SYSCALL(uptime)
 367:	b8 0e 00 00 00       	mov    $0xe,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <setpri>:
SYSCALL(setpri)
 36f:	b8 16 00 00 00       	mov    $0x16,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <getpri>:
SYSCALL(getpri)
 377:	b8 17 00 00 00       	mov    $0x17,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <getpinfo>:
SYSCALL(getpinfo)
 37f:	b8 18 00 00 00       	mov    $0x18,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <fork2>:
SYSCALL(fork2)
 387:	b8 19 00 00 00       	mov    $0x19,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	83 ec 1c             	sub    $0x1c,%esp
 395:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 398:	6a 01                	push   $0x1
 39a:	8d 55 f4             	lea    -0xc(%ebp),%edx
 39d:	52                   	push   %edx
 39e:	50                   	push   %eax
 39f:	e8 4b ff ff ff       	call   2ef <write>
}
 3a4:	83 c4 10             	add    $0x10,%esp
 3a7:	c9                   	leave  
 3a8:	c3                   	ret    

000003a9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
 3ac:	57                   	push   %edi
 3ad:	56                   	push   %esi
 3ae:	53                   	push   %ebx
 3af:	83 ec 2c             	sub    $0x2c,%esp
 3b2:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3b8:	0f 95 c3             	setne  %bl
 3bb:	89 d0                	mov    %edx,%eax
 3bd:	c1 e8 1f             	shr    $0x1f,%eax
 3c0:	84 c3                	test   %al,%bl
 3c2:	74 10                	je     3d4 <printint+0x2b>
    neg = 1;
    x = -xx;
 3c4:	f7 da                	neg    %edx
    neg = 1;
 3c6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3cd:	be 00 00 00 00       	mov    $0x0,%esi
 3d2:	eb 0b                	jmp    3df <printint+0x36>
  neg = 0;
 3d4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3db:	eb f0                	jmp    3cd <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3dd:	89 c6                	mov    %eax,%esi
 3df:	89 d0                	mov    %edx,%eax
 3e1:	ba 00 00 00 00       	mov    $0x0,%edx
 3e6:	f7 f1                	div    %ecx
 3e8:	89 c3                	mov    %eax,%ebx
 3ea:	8d 46 01             	lea    0x1(%esi),%eax
 3ed:	0f b6 92 ec 06 00 00 	movzbl 0x6ec(%edx),%edx
 3f4:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3f8:	89 da                	mov    %ebx,%edx
 3fa:	85 db                	test   %ebx,%ebx
 3fc:	75 df                	jne    3dd <printint+0x34>
 3fe:	89 c3                	mov    %eax,%ebx
  if(neg)
 400:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 404:	74 16                	je     41c <printint+0x73>
    buf[i++] = '-';
 406:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 40b:	8d 5e 02             	lea    0x2(%esi),%ebx
 40e:	eb 0c                	jmp    41c <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 410:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 415:	89 f8                	mov    %edi,%eax
 417:	e8 73 ff ff ff       	call   38f <putc>
  while(--i >= 0)
 41c:	83 eb 01             	sub    $0x1,%ebx
 41f:	79 ef                	jns    410 <printint+0x67>
}
 421:	83 c4 2c             	add    $0x2c,%esp
 424:	5b                   	pop    %ebx
 425:	5e                   	pop    %esi
 426:	5f                   	pop    %edi
 427:	5d                   	pop    %ebp
 428:	c3                   	ret    

00000429 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 429:	55                   	push   %ebp
 42a:	89 e5                	mov    %esp,%ebp
 42c:	57                   	push   %edi
 42d:	56                   	push   %esi
 42e:	53                   	push   %ebx
 42f:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 432:	8d 45 10             	lea    0x10(%ebp),%eax
 435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 438:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 43d:	bb 00 00 00 00       	mov    $0x0,%ebx
 442:	eb 14                	jmp    458 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 444:	89 fa                	mov    %edi,%edx
 446:	8b 45 08             	mov    0x8(%ebp),%eax
 449:	e8 41 ff ff ff       	call   38f <putc>
 44e:	eb 05                	jmp    455 <printf+0x2c>
      }
    } else if(state == '%'){
 450:	83 fe 25             	cmp    $0x25,%esi
 453:	74 25                	je     47a <printf+0x51>
  for(i = 0; fmt[i]; i++){
 455:	83 c3 01             	add    $0x1,%ebx
 458:	8b 45 0c             	mov    0xc(%ebp),%eax
 45b:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 45f:	84 c0                	test   %al,%al
 461:	0f 84 23 01 00 00    	je     58a <printf+0x161>
    c = fmt[i] & 0xff;
 467:	0f be f8             	movsbl %al,%edi
 46a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 46d:	85 f6                	test   %esi,%esi
 46f:	75 df                	jne    450 <printf+0x27>
      if(c == '%'){
 471:	83 f8 25             	cmp    $0x25,%eax
 474:	75 ce                	jne    444 <printf+0x1b>
        state = '%';
 476:	89 c6                	mov    %eax,%esi
 478:	eb db                	jmp    455 <printf+0x2c>
      if(c == 'd'){
 47a:	83 f8 64             	cmp    $0x64,%eax
 47d:	74 49                	je     4c8 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 47f:	83 f8 78             	cmp    $0x78,%eax
 482:	0f 94 c1             	sete   %cl
 485:	83 f8 70             	cmp    $0x70,%eax
 488:	0f 94 c2             	sete   %dl
 48b:	08 d1                	or     %dl,%cl
 48d:	75 63                	jne    4f2 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 48f:	83 f8 73             	cmp    $0x73,%eax
 492:	0f 84 84 00 00 00    	je     51c <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 498:	83 f8 63             	cmp    $0x63,%eax
 49b:	0f 84 b7 00 00 00    	je     558 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4a1:	83 f8 25             	cmp    $0x25,%eax
 4a4:	0f 84 cc 00 00 00    	je     576 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4aa:	ba 25 00 00 00       	mov    $0x25,%edx
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
 4b2:	e8 d8 fe ff ff       	call   38f <putc>
        putc(fd, c);
 4b7:	89 fa                	mov    %edi,%edx
 4b9:	8b 45 08             	mov    0x8(%ebp),%eax
 4bc:	e8 ce fe ff ff       	call   38f <putc>
      }
      state = 0;
 4c1:	be 00 00 00 00       	mov    $0x0,%esi
 4c6:	eb 8d                	jmp    455 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4cb:	8b 17                	mov    (%edi),%edx
 4cd:	83 ec 0c             	sub    $0xc,%esp
 4d0:	6a 01                	push   $0x1
 4d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	e8 ca fe ff ff       	call   3a9 <printint>
        ap++;
 4df:	83 c7 04             	add    $0x4,%edi
 4e2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e5:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4e8:	be 00 00 00 00       	mov    $0x0,%esi
 4ed:	e9 63 ff ff ff       	jmp    455 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f5:	8b 17                	mov    (%edi),%edx
 4f7:	83 ec 0c             	sub    $0xc,%esp
 4fa:	6a 00                	push   $0x0
 4fc:	b9 10 00 00 00       	mov    $0x10,%ecx
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	e8 a0 fe ff ff       	call   3a9 <printint>
        ap++;
 509:	83 c7 04             	add    $0x4,%edi
 50c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 50f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 512:	be 00 00 00 00       	mov    $0x0,%esi
 517:	e9 39 ff ff ff       	jmp    455 <printf+0x2c>
        s = (char*)*ap;
 51c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51f:	8b 30                	mov    (%eax),%esi
        ap++;
 521:	83 c0 04             	add    $0x4,%eax
 524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 527:	85 f6                	test   %esi,%esi
 529:	75 28                	jne    553 <printf+0x12a>
          s = "(null)";
 52b:	be e4 06 00 00       	mov    $0x6e4,%esi
 530:	8b 7d 08             	mov    0x8(%ebp),%edi
 533:	eb 0d                	jmp    542 <printf+0x119>
          putc(fd, *s);
 535:	0f be d2             	movsbl %dl,%edx
 538:	89 f8                	mov    %edi,%eax
 53a:	e8 50 fe ff ff       	call   38f <putc>
          s++;
 53f:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 542:	0f b6 16             	movzbl (%esi),%edx
 545:	84 d2                	test   %dl,%dl
 547:	75 ec                	jne    535 <printf+0x10c>
      state = 0;
 549:	be 00 00 00 00       	mov    $0x0,%esi
 54e:	e9 02 ff ff ff       	jmp    455 <printf+0x2c>
 553:	8b 7d 08             	mov    0x8(%ebp),%edi
 556:	eb ea                	jmp    542 <printf+0x119>
        putc(fd, *ap);
 558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 55b:	0f be 17             	movsbl (%edi),%edx
 55e:	8b 45 08             	mov    0x8(%ebp),%eax
 561:	e8 29 fe ff ff       	call   38f <putc>
        ap++;
 566:	83 c7 04             	add    $0x4,%edi
 569:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 56c:	be 00 00 00 00       	mov    $0x0,%esi
 571:	e9 df fe ff ff       	jmp    455 <printf+0x2c>
        putc(fd, c);
 576:	89 fa                	mov    %edi,%edx
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	e8 0f fe ff ff       	call   38f <putc>
      state = 0;
 580:	be 00 00 00 00       	mov    $0x0,%esi
 585:	e9 cb fe ff ff       	jmp    455 <printf+0x2c>
    }
  }
}
 58a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 58d:	5b                   	pop    %ebx
 58e:	5e                   	pop    %esi
 58f:	5f                   	pop    %edi
 590:	5d                   	pop    %ebp
 591:	c3                   	ret    

00000592 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 592:	55                   	push   %ebp
 593:	89 e5                	mov    %esp,%ebp
 595:	57                   	push   %edi
 596:	56                   	push   %esi
 597:	53                   	push   %ebx
 598:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 59b:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 59e:	a1 b4 09 00 00       	mov    0x9b4,%eax
 5a3:	eb 02                	jmp    5a7 <free+0x15>
 5a5:	89 d0                	mov    %edx,%eax
 5a7:	39 c8                	cmp    %ecx,%eax
 5a9:	73 04                	jae    5af <free+0x1d>
 5ab:	39 08                	cmp    %ecx,(%eax)
 5ad:	77 12                	ja     5c1 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5af:	8b 10                	mov    (%eax),%edx
 5b1:	39 c2                	cmp    %eax,%edx
 5b3:	77 f0                	ja     5a5 <free+0x13>
 5b5:	39 c8                	cmp    %ecx,%eax
 5b7:	72 08                	jb     5c1 <free+0x2f>
 5b9:	39 ca                	cmp    %ecx,%edx
 5bb:	77 04                	ja     5c1 <free+0x2f>
 5bd:	89 d0                	mov    %edx,%eax
 5bf:	eb e6                	jmp    5a7 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5c1:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5c4:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5c7:	8b 10                	mov    (%eax),%edx
 5c9:	39 d7                	cmp    %edx,%edi
 5cb:	74 19                	je     5e6 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5cd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5d0:	8b 50 04             	mov    0x4(%eax),%edx
 5d3:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5d6:	39 ce                	cmp    %ecx,%esi
 5d8:	74 1b                	je     5f5 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5da:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5dc:	a3 b4 09 00 00       	mov    %eax,0x9b4
}
 5e1:	5b                   	pop    %ebx
 5e2:	5e                   	pop    %esi
 5e3:	5f                   	pop    %edi
 5e4:	5d                   	pop    %ebp
 5e5:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5e6:	03 72 04             	add    0x4(%edx),%esi
 5e9:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5ec:	8b 10                	mov    (%eax),%edx
 5ee:	8b 12                	mov    (%edx),%edx
 5f0:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5f3:	eb db                	jmp    5d0 <free+0x3e>
    p->s.size += bp->s.size;
 5f5:	03 53 fc             	add    -0x4(%ebx),%edx
 5f8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5fb:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5fe:	89 10                	mov    %edx,(%eax)
 600:	eb da                	jmp    5dc <free+0x4a>

00000602 <morecore>:

static Header*
morecore(uint nu)
{
 602:	55                   	push   %ebp
 603:	89 e5                	mov    %esp,%ebp
 605:	53                   	push   %ebx
 606:	83 ec 04             	sub    $0x4,%esp
 609:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 60b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 610:	77 05                	ja     617 <morecore+0x15>
    nu = 4096;
 612:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 617:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 61e:	83 ec 0c             	sub    $0xc,%esp
 621:	50                   	push   %eax
 622:	e8 30 fd ff ff       	call   357 <sbrk>
  if(p == (char*)-1)
 627:	83 c4 10             	add    $0x10,%esp
 62a:	83 f8 ff             	cmp    $0xffffffff,%eax
 62d:	74 1c                	je     64b <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 62f:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 632:	83 c0 08             	add    $0x8,%eax
 635:	83 ec 0c             	sub    $0xc,%esp
 638:	50                   	push   %eax
 639:	e8 54 ff ff ff       	call   592 <free>
  return freep;
 63e:	a1 b4 09 00 00       	mov    0x9b4,%eax
 643:	83 c4 10             	add    $0x10,%esp
}
 646:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 649:	c9                   	leave  
 64a:	c3                   	ret    
    return 0;
 64b:	b8 00 00 00 00       	mov    $0x0,%eax
 650:	eb f4                	jmp    646 <morecore+0x44>

00000652 <malloc>:

void*
malloc(uint nbytes)
{
 652:	55                   	push   %ebp
 653:	89 e5                	mov    %esp,%ebp
 655:	53                   	push   %ebx
 656:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 659:	8b 45 08             	mov    0x8(%ebp),%eax
 65c:	8d 58 07             	lea    0x7(%eax),%ebx
 65f:	c1 eb 03             	shr    $0x3,%ebx
 662:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 665:	8b 0d b4 09 00 00    	mov    0x9b4,%ecx
 66b:	85 c9                	test   %ecx,%ecx
 66d:	74 04                	je     673 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 66f:	8b 01                	mov    (%ecx),%eax
 671:	eb 4d                	jmp    6c0 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 673:	c7 05 b4 09 00 00 b8 	movl   $0x9b8,0x9b4
 67a:	09 00 00 
 67d:	c7 05 b8 09 00 00 b8 	movl   $0x9b8,0x9b8
 684:	09 00 00 
    base.s.size = 0;
 687:	c7 05 bc 09 00 00 00 	movl   $0x0,0x9bc
 68e:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 691:	b9 b8 09 00 00       	mov    $0x9b8,%ecx
 696:	eb d7                	jmp    66f <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 698:	39 da                	cmp    %ebx,%edx
 69a:	74 1a                	je     6b6 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 69c:	29 da                	sub    %ebx,%edx
 69e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6a1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6a4:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6a7:	89 0d b4 09 00 00    	mov    %ecx,0x9b4
      return (void*)(p + 1);
 6ad:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6b0:	83 c4 04             	add    $0x4,%esp
 6b3:	5b                   	pop    %ebx
 6b4:	5d                   	pop    %ebp
 6b5:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6b6:	8b 10                	mov    (%eax),%edx
 6b8:	89 11                	mov    %edx,(%ecx)
 6ba:	eb eb                	jmp    6a7 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6bc:	89 c1                	mov    %eax,%ecx
 6be:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6c0:	8b 50 04             	mov    0x4(%eax),%edx
 6c3:	39 da                	cmp    %ebx,%edx
 6c5:	73 d1                	jae    698 <malloc+0x46>
    if(p == freep)
 6c7:	39 05 b4 09 00 00    	cmp    %eax,0x9b4
 6cd:	75 ed                	jne    6bc <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6cf:	89 d8                	mov    %ebx,%eax
 6d1:	e8 2c ff ff ff       	call   602 <morecore>
 6d6:	85 c0                	test   %eax,%eax
 6d8:	75 e2                	jne    6bc <malloc+0x6a>
        return 0;
 6da:	b8 00 00 00 00       	mov    $0x0,%eax
 6df:	eb cf                	jmp    6b0 <malloc+0x5e>
