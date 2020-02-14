
_test_36:     file format elf32-i386


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
  36:	e8 19 03 00 00       	call   354 <sleep>
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
  75:	0f 8f ad 00 00 00    	jg     128 <main+0xcf>
    int pid = fork2((i * i) % 4);
  7b:	89 de                	mov    %ebx,%esi
  7d:	0f af f3             	imul   %ebx,%esi
  80:	89 f2                	mov    %esi,%edx
  82:	c1 fa 1f             	sar    $0x1f,%edx
  85:	c1 ea 1e             	shr    $0x1e,%edx
  88:	8d 04 16             	lea    (%esi,%edx,1),%eax
  8b:	83 e0 03             	and    $0x3,%eax
  8e:	29 d0                	sub    %edx,%eax
  90:	83 ec 0c             	sub    $0xc,%esp
  93:	50                   	push   %eax
  94:	e8 e3 02 00 00       	call   37c <fork2>
    if (pid == 0) {
  99:	83 c4 10             	add    $0x10,%esp
  9c:	85 c0                	test   %eax,%eax
  9e:	74 05                	je     a5 <main+0x4c>
  for (int i = 0; i < 15; ++i) {
  a0:	83 c3 01             	add    $0x1,%ebx
  a3:	eb cd                	jmp    72 <main+0x19>
      workload(100 * i * i, 10);
  a5:	6b c3 64             	imul   $0x64,%ebx,%eax
  a8:	83 ec 08             	sub    $0x8,%esp
  ab:	6a 0a                	push   $0xa
  ad:	0f af c3             	imul   %ebx,%eax
  b0:	50                   	push   %eax
  b1:	e8 4a ff ff ff       	call   0 <workload>
      int pid2 = fork();
  b6:	e8 01 02 00 00       	call   2bc <fork>
      if (pid2 == 0) {
  bb:	83 c4 10             	add    $0x10,%esp
  be:	85 c0                	test   %eax,%eax
  c0:	75 3e                	jne    100 <main+0xa7>
        int pid3 = fork2((i * i) % 2);
  c2:	b9 02 00 00 00       	mov    $0x2,%ecx
  c7:	89 f0                	mov    %esi,%eax
  c9:	99                   	cltd   
  ca:	f7 f9                	idiv   %ecx
  cc:	83 ec 0c             	sub    $0xc,%esp
  cf:	52                   	push   %edx
  d0:	e8 a7 02 00 00       	call   37c <fork2>
  d5:	89 c7                	mov    %eax,%edi
        workload(456 * i * i, i * i);
  d7:	69 c3 c8 01 00 00    	imul   $0x1c8,%ebx,%eax
  dd:	83 c4 08             	add    $0x8,%esp
  e0:	56                   	push   %esi
  e1:	0f af d8             	imul   %eax,%ebx
  e4:	53                   	push   %ebx
  e5:	e8 16 ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  ea:	83 c4 10             	add    $0x10,%esp
  ed:	85 ff                	test   %edi,%edi
  ef:	74 0a                	je     fb <main+0xa2>
          while(wait() != -1);
  f1:	e8 d6 01 00 00       	call   2cc <wait>
  f6:	83 f8 ff             	cmp    $0xffffffff,%eax
  f9:	75 f6                	jne    f1 <main+0x98>
        }
        exit();
  fb:	e8 c4 01 00 00       	call   2c4 <exit>
      } else {
        workload(50 * i * i, 2 * i * i);
 100:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 103:	6b c3 32             	imul   $0x32,%ebx,%eax
 106:	83 ec 08             	sub    $0x8,%esp
 109:	0f af d3             	imul   %ebx,%edx
 10c:	52                   	push   %edx
 10d:	0f af d8             	imul   %eax,%ebx
 110:	53                   	push   %ebx
 111:	e8 ea fe ff ff       	call   0 <workload>
        while(wait() != -1);
 116:	83 c4 10             	add    $0x10,%esp
 119:	e8 ae 01 00 00       	call   2cc <wait>
 11e:	83 f8 ff             	cmp    $0xffffffff,%eax
 121:	75 f6                	jne    119 <main+0xc0>
        exit();
 123:	e8 9c 01 00 00       	call   2c4 <exit>
      }
    }
  }

  while(wait() != -1);
 128:	e8 9f 01 00 00       	call   2cc <wait>
 12d:	83 f8 ff             	cmp    $0xffffffff,%eax
 130:	75 f6                	jne    128 <main+0xcf>
  exit();
 132:	e8 8d 01 00 00       	call   2c4 <exit>

00000137 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 137:	55                   	push   %ebp
 138:	89 e5                	mov    %esp,%ebp
 13a:	53                   	push   %ebx
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 141:	89 c2                	mov    %eax,%edx
 143:	0f b6 19             	movzbl (%ecx),%ebx
 146:	88 1a                	mov    %bl,(%edx)
 148:	8d 52 01             	lea    0x1(%edx),%edx
 14b:	8d 49 01             	lea    0x1(%ecx),%ecx
 14e:	84 db                	test   %bl,%bl
 150:	75 f1                	jne    143 <strcpy+0xc>
    ;
  return os;
}
 152:	5b                   	pop    %ebx
 153:	5d                   	pop    %ebp
 154:	c3                   	ret    

00000155 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 155:	55                   	push   %ebp
 156:	89 e5                	mov    %esp,%ebp
 158:	8b 4d 08             	mov    0x8(%ebp),%ecx
 15b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 15e:	eb 06                	jmp    166 <strcmp+0x11>
    p++, q++;
 160:	83 c1 01             	add    $0x1,%ecx
 163:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 166:	0f b6 01             	movzbl (%ecx),%eax
 169:	84 c0                	test   %al,%al
 16b:	74 04                	je     171 <strcmp+0x1c>
 16d:	3a 02                	cmp    (%edx),%al
 16f:	74 ef                	je     160 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 171:	0f b6 c0             	movzbl %al,%eax
 174:	0f b6 12             	movzbl (%edx),%edx
 177:	29 d0                	sub    %edx,%eax
}
 179:	5d                   	pop    %ebp
 17a:	c3                   	ret    

0000017b <strlen>:

uint
strlen(const char *s)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 181:	ba 00 00 00 00       	mov    $0x0,%edx
 186:	eb 03                	jmp    18b <strlen+0x10>
 188:	83 c2 01             	add    $0x1,%edx
 18b:	89 d0                	mov    %edx,%eax
 18d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 191:	75 f5                	jne    188 <strlen+0xd>
    ;
  return n;
}
 193:	5d                   	pop    %ebp
 194:	c3                   	ret    

00000195 <memset>:

void*
memset(void *dst, int c, uint n)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
 198:	57                   	push   %edi
 199:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 19c:	89 d7                	mov    %edx,%edi
 19e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a4:	fc                   	cld    
 1a5:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1a7:	89 d0                	mov    %edx,%eax
 1a9:	5f                   	pop    %edi
 1aa:	5d                   	pop    %ebp
 1ab:	c3                   	ret    

000001ac <strchr>:

char*
strchr(const char *s, char c)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	8b 45 08             	mov    0x8(%ebp),%eax
 1b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1b6:	0f b6 10             	movzbl (%eax),%edx
 1b9:	84 d2                	test   %dl,%dl
 1bb:	74 09                	je     1c6 <strchr+0x1a>
    if(*s == c)
 1bd:	38 ca                	cmp    %cl,%dl
 1bf:	74 0a                	je     1cb <strchr+0x1f>
  for(; *s; s++)
 1c1:	83 c0 01             	add    $0x1,%eax
 1c4:	eb f0                	jmp    1b6 <strchr+0xa>
      return (char*)s;
  return 0;
 1c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1cb:	5d                   	pop    %ebp
 1cc:	c3                   	ret    

000001cd <gets>:

char*
gets(char *buf, int max)
{
 1cd:	55                   	push   %ebp
 1ce:	89 e5                	mov    %esp,%ebp
 1d0:	57                   	push   %edi
 1d1:	56                   	push   %esi
 1d2:	53                   	push   %ebx
 1d3:	83 ec 1c             	sub    $0x1c,%esp
 1d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d9:	bb 00 00 00 00       	mov    $0x0,%ebx
 1de:	8d 73 01             	lea    0x1(%ebx),%esi
 1e1:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1e4:	7d 2e                	jge    214 <gets+0x47>
    cc = read(0, &c, 1);
 1e6:	83 ec 04             	sub    $0x4,%esp
 1e9:	6a 01                	push   $0x1
 1eb:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1ee:	50                   	push   %eax
 1ef:	6a 00                	push   $0x0
 1f1:	e8 e6 00 00 00       	call   2dc <read>
    if(cc < 1)
 1f6:	83 c4 10             	add    $0x10,%esp
 1f9:	85 c0                	test   %eax,%eax
 1fb:	7e 17                	jle    214 <gets+0x47>
      break;
    buf[i++] = c;
 1fd:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 201:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 204:	3c 0a                	cmp    $0xa,%al
 206:	0f 94 c2             	sete   %dl
 209:	3c 0d                	cmp    $0xd,%al
 20b:	0f 94 c0             	sete   %al
    buf[i++] = c;
 20e:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 210:	08 c2                	or     %al,%dl
 212:	74 ca                	je     1de <gets+0x11>
      break;
  }
  buf[i] = '\0';
 214:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 218:	89 f8                	mov    %edi,%eax
 21a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 21d:	5b                   	pop    %ebx
 21e:	5e                   	pop    %esi
 21f:	5f                   	pop    %edi
 220:	5d                   	pop    %ebp
 221:	c3                   	ret    

00000222 <stat>:

int
stat(const char *n, struct stat *st)
{
 222:	55                   	push   %ebp
 223:	89 e5                	mov    %esp,%ebp
 225:	56                   	push   %esi
 226:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 227:	83 ec 08             	sub    $0x8,%esp
 22a:	6a 00                	push   $0x0
 22c:	ff 75 08             	pushl  0x8(%ebp)
 22f:	e8 d0 00 00 00       	call   304 <open>
  if(fd < 0)
 234:	83 c4 10             	add    $0x10,%esp
 237:	85 c0                	test   %eax,%eax
 239:	78 24                	js     25f <stat+0x3d>
 23b:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 23d:	83 ec 08             	sub    $0x8,%esp
 240:	ff 75 0c             	pushl  0xc(%ebp)
 243:	50                   	push   %eax
 244:	e8 d3 00 00 00       	call   31c <fstat>
 249:	89 c6                	mov    %eax,%esi
  close(fd);
 24b:	89 1c 24             	mov    %ebx,(%esp)
 24e:	e8 99 00 00 00       	call   2ec <close>
  return r;
 253:	83 c4 10             	add    $0x10,%esp
}
 256:	89 f0                	mov    %esi,%eax
 258:	8d 65 f8             	lea    -0x8(%ebp),%esp
 25b:	5b                   	pop    %ebx
 25c:	5e                   	pop    %esi
 25d:	5d                   	pop    %ebp
 25e:	c3                   	ret    
    return -1;
 25f:	be ff ff ff ff       	mov    $0xffffffff,%esi
 264:	eb f0                	jmp    256 <stat+0x34>

00000266 <atoi>:

int
atoi(const char *s)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	53                   	push   %ebx
 26a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 26d:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 272:	eb 10                	jmp    284 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 274:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 277:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 27a:	83 c1 01             	add    $0x1,%ecx
 27d:	0f be d2             	movsbl %dl,%edx
 280:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 284:	0f b6 11             	movzbl (%ecx),%edx
 287:	8d 5a d0             	lea    -0x30(%edx),%ebx
 28a:	80 fb 09             	cmp    $0x9,%bl
 28d:	76 e5                	jbe    274 <atoi+0xe>
  return n;
}
 28f:	5b                   	pop    %ebx
 290:	5d                   	pop    %ebp
 291:	c3                   	ret    

00000292 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp
 295:	56                   	push   %esi
 296:	53                   	push   %ebx
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 29d:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2a0:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2a2:	eb 0d                	jmp    2b1 <memmove+0x1f>
    *dst++ = *src++;
 2a4:	0f b6 13             	movzbl (%ebx),%edx
 2a7:	88 11                	mov    %dl,(%ecx)
 2a9:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2ac:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2af:	89 f2                	mov    %esi,%edx
 2b1:	8d 72 ff             	lea    -0x1(%edx),%esi
 2b4:	85 d2                	test   %edx,%edx
 2b6:	7f ec                	jg     2a4 <memmove+0x12>
  return vdst;
}
 2b8:	5b                   	pop    %ebx
 2b9:	5e                   	pop    %esi
 2ba:	5d                   	pop    %ebp
 2bb:	c3                   	ret    

000002bc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2bc:	b8 01 00 00 00       	mov    $0x1,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <exit>:
SYSCALL(exit)
 2c4:	b8 02 00 00 00       	mov    $0x2,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <wait>:
SYSCALL(wait)
 2cc:	b8 03 00 00 00       	mov    $0x3,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <pipe>:
SYSCALL(pipe)
 2d4:	b8 04 00 00 00       	mov    $0x4,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <read>:
SYSCALL(read)
 2dc:	b8 05 00 00 00       	mov    $0x5,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <write>:
SYSCALL(write)
 2e4:	b8 10 00 00 00       	mov    $0x10,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <close>:
SYSCALL(close)
 2ec:	b8 15 00 00 00       	mov    $0x15,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <kill>:
SYSCALL(kill)
 2f4:	b8 06 00 00 00       	mov    $0x6,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <exec>:
SYSCALL(exec)
 2fc:	b8 07 00 00 00       	mov    $0x7,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <open>:
SYSCALL(open)
 304:	b8 0f 00 00 00       	mov    $0xf,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <mknod>:
SYSCALL(mknod)
 30c:	b8 11 00 00 00       	mov    $0x11,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <unlink>:
SYSCALL(unlink)
 314:	b8 12 00 00 00       	mov    $0x12,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <fstat>:
SYSCALL(fstat)
 31c:	b8 08 00 00 00       	mov    $0x8,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <link>:
SYSCALL(link)
 324:	b8 13 00 00 00       	mov    $0x13,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <mkdir>:
SYSCALL(mkdir)
 32c:	b8 14 00 00 00       	mov    $0x14,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <chdir>:
SYSCALL(chdir)
 334:	b8 09 00 00 00       	mov    $0x9,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <dup>:
SYSCALL(dup)
 33c:	b8 0a 00 00 00       	mov    $0xa,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <getpid>:
SYSCALL(getpid)
 344:	b8 0b 00 00 00       	mov    $0xb,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <sbrk>:
SYSCALL(sbrk)
 34c:	b8 0c 00 00 00       	mov    $0xc,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <sleep>:
SYSCALL(sleep)
 354:	b8 0d 00 00 00       	mov    $0xd,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <uptime>:
SYSCALL(uptime)
 35c:	b8 0e 00 00 00       	mov    $0xe,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <setpri>:
SYSCALL(setpri)
 364:	b8 16 00 00 00       	mov    $0x16,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <getpri>:
SYSCALL(getpri)
 36c:	b8 17 00 00 00       	mov    $0x17,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <getpinfo>:
SYSCALL(getpinfo)
 374:	b8 18 00 00 00       	mov    $0x18,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <fork2>:
SYSCALL(fork2)
 37c:	b8 19 00 00 00       	mov    $0x19,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 384:	55                   	push   %ebp
 385:	89 e5                	mov    %esp,%ebp
 387:	83 ec 1c             	sub    $0x1c,%esp
 38a:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 38d:	6a 01                	push   $0x1
 38f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 392:	52                   	push   %edx
 393:	50                   	push   %eax
 394:	e8 4b ff ff ff       	call   2e4 <write>
}
 399:	83 c4 10             	add    $0x10,%esp
 39c:	c9                   	leave  
 39d:	c3                   	ret    

0000039e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 39e:	55                   	push   %ebp
 39f:	89 e5                	mov    %esp,%ebp
 3a1:	57                   	push   %edi
 3a2:	56                   	push   %esi
 3a3:	53                   	push   %ebx
 3a4:	83 ec 2c             	sub    $0x2c,%esp
 3a7:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3ad:	0f 95 c3             	setne  %bl
 3b0:	89 d0                	mov    %edx,%eax
 3b2:	c1 e8 1f             	shr    $0x1f,%eax
 3b5:	84 c3                	test   %al,%bl
 3b7:	74 10                	je     3c9 <printint+0x2b>
    neg = 1;
    x = -xx;
 3b9:	f7 da                	neg    %edx
    neg = 1;
 3bb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3c2:	be 00 00 00 00       	mov    $0x0,%esi
 3c7:	eb 0b                	jmp    3d4 <printint+0x36>
  neg = 0;
 3c9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3d0:	eb f0                	jmp    3c2 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3d2:	89 c6                	mov    %eax,%esi
 3d4:	89 d0                	mov    %edx,%eax
 3d6:	ba 00 00 00 00       	mov    $0x0,%edx
 3db:	f7 f1                	div    %ecx
 3dd:	89 c3                	mov    %eax,%ebx
 3df:	8d 46 01             	lea    0x1(%esi),%eax
 3e2:	0f b6 92 e0 06 00 00 	movzbl 0x6e0(%edx),%edx
 3e9:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3ed:	89 da                	mov    %ebx,%edx
 3ef:	85 db                	test   %ebx,%ebx
 3f1:	75 df                	jne    3d2 <printint+0x34>
 3f3:	89 c3                	mov    %eax,%ebx
  if(neg)
 3f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3f9:	74 16                	je     411 <printint+0x73>
    buf[i++] = '-';
 3fb:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 400:	8d 5e 02             	lea    0x2(%esi),%ebx
 403:	eb 0c                	jmp    411 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 405:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 40a:	89 f8                	mov    %edi,%eax
 40c:	e8 73 ff ff ff       	call   384 <putc>
  while(--i >= 0)
 411:	83 eb 01             	sub    $0x1,%ebx
 414:	79 ef                	jns    405 <printint+0x67>
}
 416:	83 c4 2c             	add    $0x2c,%esp
 419:	5b                   	pop    %ebx
 41a:	5e                   	pop    %esi
 41b:	5f                   	pop    %edi
 41c:	5d                   	pop    %ebp
 41d:	c3                   	ret    

0000041e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 41e:	55                   	push   %ebp
 41f:	89 e5                	mov    %esp,%ebp
 421:	57                   	push   %edi
 422:	56                   	push   %esi
 423:	53                   	push   %ebx
 424:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 427:	8d 45 10             	lea    0x10(%ebp),%eax
 42a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 42d:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 432:	bb 00 00 00 00       	mov    $0x0,%ebx
 437:	eb 14                	jmp    44d <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 439:	89 fa                	mov    %edi,%edx
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	e8 41 ff ff ff       	call   384 <putc>
 443:	eb 05                	jmp    44a <printf+0x2c>
      }
    } else if(state == '%'){
 445:	83 fe 25             	cmp    $0x25,%esi
 448:	74 25                	je     46f <printf+0x51>
  for(i = 0; fmt[i]; i++){
 44a:	83 c3 01             	add    $0x1,%ebx
 44d:	8b 45 0c             	mov    0xc(%ebp),%eax
 450:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 454:	84 c0                	test   %al,%al
 456:	0f 84 23 01 00 00    	je     57f <printf+0x161>
    c = fmt[i] & 0xff;
 45c:	0f be f8             	movsbl %al,%edi
 45f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 462:	85 f6                	test   %esi,%esi
 464:	75 df                	jne    445 <printf+0x27>
      if(c == '%'){
 466:	83 f8 25             	cmp    $0x25,%eax
 469:	75 ce                	jne    439 <printf+0x1b>
        state = '%';
 46b:	89 c6                	mov    %eax,%esi
 46d:	eb db                	jmp    44a <printf+0x2c>
      if(c == 'd'){
 46f:	83 f8 64             	cmp    $0x64,%eax
 472:	74 49                	je     4bd <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 474:	83 f8 78             	cmp    $0x78,%eax
 477:	0f 94 c1             	sete   %cl
 47a:	83 f8 70             	cmp    $0x70,%eax
 47d:	0f 94 c2             	sete   %dl
 480:	08 d1                	or     %dl,%cl
 482:	75 63                	jne    4e7 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 484:	83 f8 73             	cmp    $0x73,%eax
 487:	0f 84 84 00 00 00    	je     511 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 48d:	83 f8 63             	cmp    $0x63,%eax
 490:	0f 84 b7 00 00 00    	je     54d <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 496:	83 f8 25             	cmp    $0x25,%eax
 499:	0f 84 cc 00 00 00    	je     56b <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 49f:	ba 25 00 00 00       	mov    $0x25,%edx
 4a4:	8b 45 08             	mov    0x8(%ebp),%eax
 4a7:	e8 d8 fe ff ff       	call   384 <putc>
        putc(fd, c);
 4ac:	89 fa                	mov    %edi,%edx
 4ae:	8b 45 08             	mov    0x8(%ebp),%eax
 4b1:	e8 ce fe ff ff       	call   384 <putc>
      }
      state = 0;
 4b6:	be 00 00 00 00       	mov    $0x0,%esi
 4bb:	eb 8d                	jmp    44a <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c0:	8b 17                	mov    (%edi),%edx
 4c2:	83 ec 0c             	sub    $0xc,%esp
 4c5:	6a 01                	push   $0x1
 4c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
 4cf:	e8 ca fe ff ff       	call   39e <printint>
        ap++;
 4d4:	83 c7 04             	add    $0x4,%edi
 4d7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4da:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4dd:	be 00 00 00 00       	mov    $0x0,%esi
 4e2:	e9 63 ff ff ff       	jmp    44a <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ea:	8b 17                	mov    (%edi),%edx
 4ec:	83 ec 0c             	sub    $0xc,%esp
 4ef:	6a 00                	push   $0x0
 4f1:	b9 10 00 00 00       	mov    $0x10,%ecx
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	e8 a0 fe ff ff       	call   39e <printint>
        ap++;
 4fe:	83 c7 04             	add    $0x4,%edi
 501:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 504:	83 c4 10             	add    $0x10,%esp
      state = 0;
 507:	be 00 00 00 00       	mov    $0x0,%esi
 50c:	e9 39 ff ff ff       	jmp    44a <printf+0x2c>
        s = (char*)*ap;
 511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 514:	8b 30                	mov    (%eax),%esi
        ap++;
 516:	83 c0 04             	add    $0x4,%eax
 519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 51c:	85 f6                	test   %esi,%esi
 51e:	75 28                	jne    548 <printf+0x12a>
          s = "(null)";
 520:	be d8 06 00 00       	mov    $0x6d8,%esi
 525:	8b 7d 08             	mov    0x8(%ebp),%edi
 528:	eb 0d                	jmp    537 <printf+0x119>
          putc(fd, *s);
 52a:	0f be d2             	movsbl %dl,%edx
 52d:	89 f8                	mov    %edi,%eax
 52f:	e8 50 fe ff ff       	call   384 <putc>
          s++;
 534:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 537:	0f b6 16             	movzbl (%esi),%edx
 53a:	84 d2                	test   %dl,%dl
 53c:	75 ec                	jne    52a <printf+0x10c>
      state = 0;
 53e:	be 00 00 00 00       	mov    $0x0,%esi
 543:	e9 02 ff ff ff       	jmp    44a <printf+0x2c>
 548:	8b 7d 08             	mov    0x8(%ebp),%edi
 54b:	eb ea                	jmp    537 <printf+0x119>
        putc(fd, *ap);
 54d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 550:	0f be 17             	movsbl (%edi),%edx
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	e8 29 fe ff ff       	call   384 <putc>
        ap++;
 55b:	83 c7 04             	add    $0x4,%edi
 55e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 561:	be 00 00 00 00       	mov    $0x0,%esi
 566:	e9 df fe ff ff       	jmp    44a <printf+0x2c>
        putc(fd, c);
 56b:	89 fa                	mov    %edi,%edx
 56d:	8b 45 08             	mov    0x8(%ebp),%eax
 570:	e8 0f fe ff ff       	call   384 <putc>
      state = 0;
 575:	be 00 00 00 00       	mov    $0x0,%esi
 57a:	e9 cb fe ff ff       	jmp    44a <printf+0x2c>
    }
  }
}
 57f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 582:	5b                   	pop    %ebx
 583:	5e                   	pop    %esi
 584:	5f                   	pop    %edi
 585:	5d                   	pop    %ebp
 586:	c3                   	ret    

00000587 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 587:	55                   	push   %ebp
 588:	89 e5                	mov    %esp,%ebp
 58a:	57                   	push   %edi
 58b:	56                   	push   %esi
 58c:	53                   	push   %ebx
 58d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 590:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 593:	a1 ac 09 00 00       	mov    0x9ac,%eax
 598:	eb 02                	jmp    59c <free+0x15>
 59a:	89 d0                	mov    %edx,%eax
 59c:	39 c8                	cmp    %ecx,%eax
 59e:	73 04                	jae    5a4 <free+0x1d>
 5a0:	39 08                	cmp    %ecx,(%eax)
 5a2:	77 12                	ja     5b6 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5a4:	8b 10                	mov    (%eax),%edx
 5a6:	39 c2                	cmp    %eax,%edx
 5a8:	77 f0                	ja     59a <free+0x13>
 5aa:	39 c8                	cmp    %ecx,%eax
 5ac:	72 08                	jb     5b6 <free+0x2f>
 5ae:	39 ca                	cmp    %ecx,%edx
 5b0:	77 04                	ja     5b6 <free+0x2f>
 5b2:	89 d0                	mov    %edx,%eax
 5b4:	eb e6                	jmp    59c <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5b6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5b9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5bc:	8b 10                	mov    (%eax),%edx
 5be:	39 d7                	cmp    %edx,%edi
 5c0:	74 19                	je     5db <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5c2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5c5:	8b 50 04             	mov    0x4(%eax),%edx
 5c8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5cb:	39 ce                	cmp    %ecx,%esi
 5cd:	74 1b                	je     5ea <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5cf:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5d1:	a3 ac 09 00 00       	mov    %eax,0x9ac
}
 5d6:	5b                   	pop    %ebx
 5d7:	5e                   	pop    %esi
 5d8:	5f                   	pop    %edi
 5d9:	5d                   	pop    %ebp
 5da:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5db:	03 72 04             	add    0x4(%edx),%esi
 5de:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5e1:	8b 10                	mov    (%eax),%edx
 5e3:	8b 12                	mov    (%edx),%edx
 5e5:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5e8:	eb db                	jmp    5c5 <free+0x3e>
    p->s.size += bp->s.size;
 5ea:	03 53 fc             	add    -0x4(%ebx),%edx
 5ed:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5f0:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5f3:	89 10                	mov    %edx,(%eax)
 5f5:	eb da                	jmp    5d1 <free+0x4a>

000005f7 <morecore>:

static Header*
morecore(uint nu)
{
 5f7:	55                   	push   %ebp
 5f8:	89 e5                	mov    %esp,%ebp
 5fa:	53                   	push   %ebx
 5fb:	83 ec 04             	sub    $0x4,%esp
 5fe:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 600:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 605:	77 05                	ja     60c <morecore+0x15>
    nu = 4096;
 607:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 60c:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 613:	83 ec 0c             	sub    $0xc,%esp
 616:	50                   	push   %eax
 617:	e8 30 fd ff ff       	call   34c <sbrk>
  if(p == (char*)-1)
 61c:	83 c4 10             	add    $0x10,%esp
 61f:	83 f8 ff             	cmp    $0xffffffff,%eax
 622:	74 1c                	je     640 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 624:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 627:	83 c0 08             	add    $0x8,%eax
 62a:	83 ec 0c             	sub    $0xc,%esp
 62d:	50                   	push   %eax
 62e:	e8 54 ff ff ff       	call   587 <free>
  return freep;
 633:	a1 ac 09 00 00       	mov    0x9ac,%eax
 638:	83 c4 10             	add    $0x10,%esp
}
 63b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 63e:	c9                   	leave  
 63f:	c3                   	ret    
    return 0;
 640:	b8 00 00 00 00       	mov    $0x0,%eax
 645:	eb f4                	jmp    63b <morecore+0x44>

00000647 <malloc>:

void*
malloc(uint nbytes)
{
 647:	55                   	push   %ebp
 648:	89 e5                	mov    %esp,%ebp
 64a:	53                   	push   %ebx
 64b:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 64e:	8b 45 08             	mov    0x8(%ebp),%eax
 651:	8d 58 07             	lea    0x7(%eax),%ebx
 654:	c1 eb 03             	shr    $0x3,%ebx
 657:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 65a:	8b 0d ac 09 00 00    	mov    0x9ac,%ecx
 660:	85 c9                	test   %ecx,%ecx
 662:	74 04                	je     668 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 664:	8b 01                	mov    (%ecx),%eax
 666:	eb 4d                	jmp    6b5 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 668:	c7 05 ac 09 00 00 b0 	movl   $0x9b0,0x9ac
 66f:	09 00 00 
 672:	c7 05 b0 09 00 00 b0 	movl   $0x9b0,0x9b0
 679:	09 00 00 
    base.s.size = 0;
 67c:	c7 05 b4 09 00 00 00 	movl   $0x0,0x9b4
 683:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 686:	b9 b0 09 00 00       	mov    $0x9b0,%ecx
 68b:	eb d7                	jmp    664 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 68d:	39 da                	cmp    %ebx,%edx
 68f:	74 1a                	je     6ab <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 691:	29 da                	sub    %ebx,%edx
 693:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 696:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 699:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 69c:	89 0d ac 09 00 00    	mov    %ecx,0x9ac
      return (void*)(p + 1);
 6a2:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6a5:	83 c4 04             	add    $0x4,%esp
 6a8:	5b                   	pop    %ebx
 6a9:	5d                   	pop    %ebp
 6aa:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6ab:	8b 10                	mov    (%eax),%edx
 6ad:	89 11                	mov    %edx,(%ecx)
 6af:	eb eb                	jmp    69c <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6b1:	89 c1                	mov    %eax,%ecx
 6b3:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6b5:	8b 50 04             	mov    0x4(%eax),%edx
 6b8:	39 da                	cmp    %ebx,%edx
 6ba:	73 d1                	jae    68d <malloc+0x46>
    if(p == freep)
 6bc:	39 05 ac 09 00 00    	cmp    %eax,0x9ac
 6c2:	75 ed                	jne    6b1 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6c4:	89 d8                	mov    %ebx,%eax
 6c6:	e8 2c ff ff ff       	call   5f7 <morecore>
 6cb:	85 c0                	test   %eax,%eax
 6cd:	75 e2                	jne    6b1 <malloc+0x6a>
        return 0;
 6cf:	b8 00 00 00 00       	mov    $0x0,%eax
 6d4:	eb cf                	jmp    6a5 <malloc+0x5e>
