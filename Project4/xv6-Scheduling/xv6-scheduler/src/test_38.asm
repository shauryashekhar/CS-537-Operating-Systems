
_test_38:     file format elf32-i386


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
  36:	e8 14 03 00 00       	call   34f <sleep>
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
  74:	0f 8f a9 00 00 00    	jg     123 <main+0xca>
    int pid = fork2((2 * i + 1) % 4);
  7a:	8d 74 1b 01          	lea    0x1(%ebx,%ebx,1),%esi
  7e:	89 f2                	mov    %esi,%edx
  80:	c1 fa 1f             	sar    $0x1f,%edx
  83:	c1 ea 1e             	shr    $0x1e,%edx
  86:	8d 04 16             	lea    (%esi,%edx,1),%eax
  89:	83 e0 03             	and    $0x3,%eax
  8c:	29 d0                	sub    %edx,%eax
  8e:	83 ec 0c             	sub    $0xc,%esp
  91:	50                   	push   %eax
  92:	e8 e0 02 00 00       	call   377 <fork2>
    if (pid == 0) {
  97:	83 c4 10             	add    $0x10,%esp
  9a:	85 c0                	test   %eax,%eax
  9c:	74 05                	je     a3 <main+0x4a>
  for (int i = 0; i < 13; ++i) {
  9e:	83 c3 01             	add    $0x1,%ebx
  a1:	eb ce                	jmp    71 <main+0x18>
      workload(1000 * (2 * i + 1), 100);
  a3:	83 ec 08             	sub    $0x8,%esp
  a6:	6a 64                	push   $0x64
  a8:	69 c6 e8 03 00 00    	imul   $0x3e8,%esi,%eax
  ae:	50                   	push   %eax
  af:	e8 4c ff ff ff       	call   0 <workload>
      int pid2 = fork();
  b4:	e8 fe 01 00 00       	call   2b7 <fork>
      if (pid2 == 0) {
  b9:	83 c4 10             	add    $0x10,%esp
  bc:	85 c0                	test   %eax,%eax
  be:	75 3e                	jne    fe <main+0xa5>
        int pid3 = fork2((2 * i + 1) % 2);
  c0:	b9 02 00 00 00       	mov    $0x2,%ecx
  c5:	89 f0                	mov    %esi,%eax
  c7:	99                   	cltd   
  c8:	f7 f9                	idiv   %ecx
  ca:	83 ec 0c             	sub    $0xc,%esp
  cd:	52                   	push   %edx
  ce:	e8 a4 02 00 00       	call   377 <fork2>
  d3:	89 c3                	mov    %eax,%ebx
        workload(467 * (2 * i + 1), 3 * (2 * i + 1));
  d5:	83 c4 08             	add    $0x8,%esp
  d8:	6b c6 03             	imul   $0x3,%esi,%eax
  db:	50                   	push   %eax
  dc:	69 f6 d3 01 00 00    	imul   $0x1d3,%esi,%esi
  e2:	56                   	push   %esi
  e3:	e8 18 ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  e8:	83 c4 10             	add    $0x10,%esp
  eb:	85 db                	test   %ebx,%ebx
  ed:	74 0a                	je     f9 <main+0xa0>
          while(wait() != -1);
  ef:	e8 d3 01 00 00       	call   2c7 <wait>
  f4:	83 f8 ff             	cmp    $0xffffffff,%eax
  f7:	75 f6                	jne    ef <main+0x96>
        }
        exit();
  f9:	e8 c1 01 00 00       	call   2bf <exit>
      } else {
        workload(500 * (2 * i + 1), 2 * (2 * i + 1));
  fe:	83 ec 08             	sub    $0x8,%esp
 101:	8d 04 36             	lea    (%esi,%esi,1),%eax
 104:	50                   	push   %eax
 105:	69 f6 f4 01 00 00    	imul   $0x1f4,%esi,%esi
 10b:	56                   	push   %esi
 10c:	e8 ef fe ff ff       	call   0 <workload>
        while(wait() != -1);
 111:	83 c4 10             	add    $0x10,%esp
 114:	e8 ae 01 00 00       	call   2c7 <wait>
 119:	83 f8 ff             	cmp    $0xffffffff,%eax
 11c:	75 f6                	jne    114 <main+0xbb>
        exit();
 11e:	e8 9c 01 00 00       	call   2bf <exit>
      }
    }
  }

  while(wait() != -1);
 123:	e8 9f 01 00 00       	call   2c7 <wait>
 128:	83 f8 ff             	cmp    $0xffffffff,%eax
 12b:	75 f6                	jne    123 <main+0xca>
  exit();
 12d:	e8 8d 01 00 00       	call   2bf <exit>

00000132 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	53                   	push   %ebx
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13c:	89 c2                	mov    %eax,%edx
 13e:	0f b6 19             	movzbl (%ecx),%ebx
 141:	88 1a                	mov    %bl,(%edx)
 143:	8d 52 01             	lea    0x1(%edx),%edx
 146:	8d 49 01             	lea    0x1(%ecx),%ecx
 149:	84 db                	test   %bl,%bl
 14b:	75 f1                	jne    13e <strcpy+0xc>
    ;
  return os;
}
 14d:	5b                   	pop    %ebx
 14e:	5d                   	pop    %ebp
 14f:	c3                   	ret    

00000150 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	8b 4d 08             	mov    0x8(%ebp),%ecx
 156:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 159:	eb 06                	jmp    161 <strcmp+0x11>
    p++, q++;
 15b:	83 c1 01             	add    $0x1,%ecx
 15e:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 161:	0f b6 01             	movzbl (%ecx),%eax
 164:	84 c0                	test   %al,%al
 166:	74 04                	je     16c <strcmp+0x1c>
 168:	3a 02                	cmp    (%edx),%al
 16a:	74 ef                	je     15b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 16c:	0f b6 c0             	movzbl %al,%eax
 16f:	0f b6 12             	movzbl (%edx),%edx
 172:	29 d0                	sub    %edx,%eax
}
 174:	5d                   	pop    %ebp
 175:	c3                   	ret    

00000176 <strlen>:

uint
strlen(const char *s)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 17c:	ba 00 00 00 00       	mov    $0x0,%edx
 181:	eb 03                	jmp    186 <strlen+0x10>
 183:	83 c2 01             	add    $0x1,%edx
 186:	89 d0                	mov    %edx,%eax
 188:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 18c:	75 f5                	jne    183 <strlen+0xd>
    ;
  return n;
}
 18e:	5d                   	pop    %ebp
 18f:	c3                   	ret    

00000190 <memset>:

void*
memset(void *dst, int c, uint n)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	57                   	push   %edi
 194:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 197:	89 d7                	mov    %edx,%edi
 199:	8b 4d 10             	mov    0x10(%ebp),%ecx
 19c:	8b 45 0c             	mov    0xc(%ebp),%eax
 19f:	fc                   	cld    
 1a0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1a2:	89 d0                	mov    %edx,%eax
 1a4:	5f                   	pop    %edi
 1a5:	5d                   	pop    %ebp
 1a6:	c3                   	ret    

000001a7 <strchr>:

char*
strchr(const char *s, char c)
{
 1a7:	55                   	push   %ebp
 1a8:	89 e5                	mov    %esp,%ebp
 1aa:	8b 45 08             	mov    0x8(%ebp),%eax
 1ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1b1:	0f b6 10             	movzbl (%eax),%edx
 1b4:	84 d2                	test   %dl,%dl
 1b6:	74 09                	je     1c1 <strchr+0x1a>
    if(*s == c)
 1b8:	38 ca                	cmp    %cl,%dl
 1ba:	74 0a                	je     1c6 <strchr+0x1f>
  for(; *s; s++)
 1bc:	83 c0 01             	add    $0x1,%eax
 1bf:	eb f0                	jmp    1b1 <strchr+0xa>
      return (char*)s;
  return 0;
 1c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1c6:	5d                   	pop    %ebp
 1c7:	c3                   	ret    

000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	57                   	push   %edi
 1cc:	56                   	push   %esi
 1cd:	53                   	push   %ebx
 1ce:	83 ec 1c             	sub    $0x1c,%esp
 1d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d9:	8d 73 01             	lea    0x1(%ebx),%esi
 1dc:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1df:	7d 2e                	jge    20f <gets+0x47>
    cc = read(0, &c, 1);
 1e1:	83 ec 04             	sub    $0x4,%esp
 1e4:	6a 01                	push   $0x1
 1e6:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1e9:	50                   	push   %eax
 1ea:	6a 00                	push   $0x0
 1ec:	e8 e6 00 00 00       	call   2d7 <read>
    if(cc < 1)
 1f1:	83 c4 10             	add    $0x10,%esp
 1f4:	85 c0                	test   %eax,%eax
 1f6:	7e 17                	jle    20f <gets+0x47>
      break;
    buf[i++] = c;
 1f8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1fc:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1ff:	3c 0a                	cmp    $0xa,%al
 201:	0f 94 c2             	sete   %dl
 204:	3c 0d                	cmp    $0xd,%al
 206:	0f 94 c0             	sete   %al
    buf[i++] = c;
 209:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 20b:	08 c2                	or     %al,%dl
 20d:	74 ca                	je     1d9 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 20f:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 213:	89 f8                	mov    %edi,%eax
 215:	8d 65 f4             	lea    -0xc(%ebp),%esp
 218:	5b                   	pop    %ebx
 219:	5e                   	pop    %esi
 21a:	5f                   	pop    %edi
 21b:	5d                   	pop    %ebp
 21c:	c3                   	ret    

0000021d <stat>:

int
stat(const char *n, struct stat *st)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	56                   	push   %esi
 221:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	83 ec 08             	sub    $0x8,%esp
 225:	6a 00                	push   $0x0
 227:	ff 75 08             	pushl  0x8(%ebp)
 22a:	e8 d0 00 00 00       	call   2ff <open>
  if(fd < 0)
 22f:	83 c4 10             	add    $0x10,%esp
 232:	85 c0                	test   %eax,%eax
 234:	78 24                	js     25a <stat+0x3d>
 236:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 238:	83 ec 08             	sub    $0x8,%esp
 23b:	ff 75 0c             	pushl  0xc(%ebp)
 23e:	50                   	push   %eax
 23f:	e8 d3 00 00 00       	call   317 <fstat>
 244:	89 c6                	mov    %eax,%esi
  close(fd);
 246:	89 1c 24             	mov    %ebx,(%esp)
 249:	e8 99 00 00 00       	call   2e7 <close>
  return r;
 24e:	83 c4 10             	add    $0x10,%esp
}
 251:	89 f0                	mov    %esi,%eax
 253:	8d 65 f8             	lea    -0x8(%ebp),%esp
 256:	5b                   	pop    %ebx
 257:	5e                   	pop    %esi
 258:	5d                   	pop    %ebp
 259:	c3                   	ret    
    return -1;
 25a:	be ff ff ff ff       	mov    $0xffffffff,%esi
 25f:	eb f0                	jmp    251 <stat+0x34>

00000261 <atoi>:

int
atoi(const char *s)
{
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	53                   	push   %ebx
 265:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 268:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 26d:	eb 10                	jmp    27f <atoi+0x1e>
    n = n*10 + *s++ - '0';
 26f:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 272:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 275:	83 c1 01             	add    $0x1,%ecx
 278:	0f be d2             	movsbl %dl,%edx
 27b:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 27f:	0f b6 11             	movzbl (%ecx),%edx
 282:	8d 5a d0             	lea    -0x30(%edx),%ebx
 285:	80 fb 09             	cmp    $0x9,%bl
 288:	76 e5                	jbe    26f <atoi+0xe>
  return n;
}
 28a:	5b                   	pop    %ebx
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    

0000028d <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	56                   	push   %esi
 291:	53                   	push   %ebx
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 298:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 29b:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 29d:	eb 0d                	jmp    2ac <memmove+0x1f>
    *dst++ = *src++;
 29f:	0f b6 13             	movzbl (%ebx),%edx
 2a2:	88 11                	mov    %dl,(%ecx)
 2a4:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2a7:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2aa:	89 f2                	mov    %esi,%edx
 2ac:	8d 72 ff             	lea    -0x1(%edx),%esi
 2af:	85 d2                	test   %edx,%edx
 2b1:	7f ec                	jg     29f <memmove+0x12>
  return vdst;
}
 2b3:	5b                   	pop    %ebx
 2b4:	5e                   	pop    %esi
 2b5:	5d                   	pop    %ebp
 2b6:	c3                   	ret    

000002b7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b7:	b8 01 00 00 00       	mov    $0x1,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <exit>:
SYSCALL(exit)
 2bf:	b8 02 00 00 00       	mov    $0x2,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <wait>:
SYSCALL(wait)
 2c7:	b8 03 00 00 00       	mov    $0x3,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <pipe>:
SYSCALL(pipe)
 2cf:	b8 04 00 00 00       	mov    $0x4,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <read>:
SYSCALL(read)
 2d7:	b8 05 00 00 00       	mov    $0x5,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <write>:
SYSCALL(write)
 2df:	b8 10 00 00 00       	mov    $0x10,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <close>:
SYSCALL(close)
 2e7:	b8 15 00 00 00       	mov    $0x15,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <kill>:
SYSCALL(kill)
 2ef:	b8 06 00 00 00       	mov    $0x6,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <exec>:
SYSCALL(exec)
 2f7:	b8 07 00 00 00       	mov    $0x7,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <open>:
SYSCALL(open)
 2ff:	b8 0f 00 00 00       	mov    $0xf,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <mknod>:
SYSCALL(mknod)
 307:	b8 11 00 00 00       	mov    $0x11,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <unlink>:
SYSCALL(unlink)
 30f:	b8 12 00 00 00       	mov    $0x12,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <fstat>:
SYSCALL(fstat)
 317:	b8 08 00 00 00       	mov    $0x8,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <link>:
SYSCALL(link)
 31f:	b8 13 00 00 00       	mov    $0x13,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <mkdir>:
SYSCALL(mkdir)
 327:	b8 14 00 00 00       	mov    $0x14,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <chdir>:
SYSCALL(chdir)
 32f:	b8 09 00 00 00       	mov    $0x9,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <dup>:
SYSCALL(dup)
 337:	b8 0a 00 00 00       	mov    $0xa,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <getpid>:
SYSCALL(getpid)
 33f:	b8 0b 00 00 00       	mov    $0xb,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <sbrk>:
SYSCALL(sbrk)
 347:	b8 0c 00 00 00       	mov    $0xc,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <sleep>:
SYSCALL(sleep)
 34f:	b8 0d 00 00 00       	mov    $0xd,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <uptime>:
SYSCALL(uptime)
 357:	b8 0e 00 00 00       	mov    $0xe,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <setpri>:
SYSCALL(setpri)
 35f:	b8 16 00 00 00       	mov    $0x16,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <getpri>:
SYSCALL(getpri)
 367:	b8 17 00 00 00       	mov    $0x17,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <getpinfo>:
SYSCALL(getpinfo)
 36f:	b8 18 00 00 00       	mov    $0x18,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <fork2>:
SYSCALL(fork2)
 377:	b8 19 00 00 00       	mov    $0x19,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 1c             	sub    $0x1c,%esp
 385:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 388:	6a 01                	push   $0x1
 38a:	8d 55 f4             	lea    -0xc(%ebp),%edx
 38d:	52                   	push   %edx
 38e:	50                   	push   %eax
 38f:	e8 4b ff ff ff       	call   2df <write>
}
 394:	83 c4 10             	add    $0x10,%esp
 397:	c9                   	leave  
 398:	c3                   	ret    

00000399 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 399:	55                   	push   %ebp
 39a:	89 e5                	mov    %esp,%ebp
 39c:	57                   	push   %edi
 39d:	56                   	push   %esi
 39e:	53                   	push   %ebx
 39f:	83 ec 2c             	sub    $0x2c,%esp
 3a2:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3a8:	0f 95 c3             	setne  %bl
 3ab:	89 d0                	mov    %edx,%eax
 3ad:	c1 e8 1f             	shr    $0x1f,%eax
 3b0:	84 c3                	test   %al,%bl
 3b2:	74 10                	je     3c4 <printint+0x2b>
    neg = 1;
    x = -xx;
 3b4:	f7 da                	neg    %edx
    neg = 1;
 3b6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3bd:	be 00 00 00 00       	mov    $0x0,%esi
 3c2:	eb 0b                	jmp    3cf <printint+0x36>
  neg = 0;
 3c4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3cb:	eb f0                	jmp    3bd <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3cd:	89 c6                	mov    %eax,%esi
 3cf:	89 d0                	mov    %edx,%eax
 3d1:	ba 00 00 00 00       	mov    $0x0,%edx
 3d6:	f7 f1                	div    %ecx
 3d8:	89 c3                	mov    %eax,%ebx
 3da:	8d 46 01             	lea    0x1(%esi),%eax
 3dd:	0f b6 92 dc 06 00 00 	movzbl 0x6dc(%edx),%edx
 3e4:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3e8:	89 da                	mov    %ebx,%edx
 3ea:	85 db                	test   %ebx,%ebx
 3ec:	75 df                	jne    3cd <printint+0x34>
 3ee:	89 c3                	mov    %eax,%ebx
  if(neg)
 3f0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3f4:	74 16                	je     40c <printint+0x73>
    buf[i++] = '-';
 3f6:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3fb:	8d 5e 02             	lea    0x2(%esi),%ebx
 3fe:	eb 0c                	jmp    40c <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 400:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 405:	89 f8                	mov    %edi,%eax
 407:	e8 73 ff ff ff       	call   37f <putc>
  while(--i >= 0)
 40c:	83 eb 01             	sub    $0x1,%ebx
 40f:	79 ef                	jns    400 <printint+0x67>
}
 411:	83 c4 2c             	add    $0x2c,%esp
 414:	5b                   	pop    %ebx
 415:	5e                   	pop    %esi
 416:	5f                   	pop    %edi
 417:	5d                   	pop    %ebp
 418:	c3                   	ret    

00000419 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 419:	55                   	push   %ebp
 41a:	89 e5                	mov    %esp,%ebp
 41c:	57                   	push   %edi
 41d:	56                   	push   %esi
 41e:	53                   	push   %ebx
 41f:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 422:	8d 45 10             	lea    0x10(%ebp),%eax
 425:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 428:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 42d:	bb 00 00 00 00       	mov    $0x0,%ebx
 432:	eb 14                	jmp    448 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 434:	89 fa                	mov    %edi,%edx
 436:	8b 45 08             	mov    0x8(%ebp),%eax
 439:	e8 41 ff ff ff       	call   37f <putc>
 43e:	eb 05                	jmp    445 <printf+0x2c>
      }
    } else if(state == '%'){
 440:	83 fe 25             	cmp    $0x25,%esi
 443:	74 25                	je     46a <printf+0x51>
  for(i = 0; fmt[i]; i++){
 445:	83 c3 01             	add    $0x1,%ebx
 448:	8b 45 0c             	mov    0xc(%ebp),%eax
 44b:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 44f:	84 c0                	test   %al,%al
 451:	0f 84 23 01 00 00    	je     57a <printf+0x161>
    c = fmt[i] & 0xff;
 457:	0f be f8             	movsbl %al,%edi
 45a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 45d:	85 f6                	test   %esi,%esi
 45f:	75 df                	jne    440 <printf+0x27>
      if(c == '%'){
 461:	83 f8 25             	cmp    $0x25,%eax
 464:	75 ce                	jne    434 <printf+0x1b>
        state = '%';
 466:	89 c6                	mov    %eax,%esi
 468:	eb db                	jmp    445 <printf+0x2c>
      if(c == 'd'){
 46a:	83 f8 64             	cmp    $0x64,%eax
 46d:	74 49                	je     4b8 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 46f:	83 f8 78             	cmp    $0x78,%eax
 472:	0f 94 c1             	sete   %cl
 475:	83 f8 70             	cmp    $0x70,%eax
 478:	0f 94 c2             	sete   %dl
 47b:	08 d1                	or     %dl,%cl
 47d:	75 63                	jne    4e2 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 47f:	83 f8 73             	cmp    $0x73,%eax
 482:	0f 84 84 00 00 00    	je     50c <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 488:	83 f8 63             	cmp    $0x63,%eax
 48b:	0f 84 b7 00 00 00    	je     548 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 491:	83 f8 25             	cmp    $0x25,%eax
 494:	0f 84 cc 00 00 00    	je     566 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 49a:	ba 25 00 00 00       	mov    $0x25,%edx
 49f:	8b 45 08             	mov    0x8(%ebp),%eax
 4a2:	e8 d8 fe ff ff       	call   37f <putc>
        putc(fd, c);
 4a7:	89 fa                	mov    %edi,%edx
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	e8 ce fe ff ff       	call   37f <putc>
      }
      state = 0;
 4b1:	be 00 00 00 00       	mov    $0x0,%esi
 4b6:	eb 8d                	jmp    445 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4bb:	8b 17                	mov    (%edi),%edx
 4bd:	83 ec 0c             	sub    $0xc,%esp
 4c0:	6a 01                	push   $0x1
 4c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4c7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ca:	e8 ca fe ff ff       	call   399 <printint>
        ap++;
 4cf:	83 c7 04             	add    $0x4,%edi
 4d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4d5:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4d8:	be 00 00 00 00       	mov    $0x0,%esi
 4dd:	e9 63 ff ff ff       	jmp    445 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4e5:	8b 17                	mov    (%edi),%edx
 4e7:	83 ec 0c             	sub    $0xc,%esp
 4ea:	6a 00                	push   $0x0
 4ec:	b9 10 00 00 00       	mov    $0x10,%ecx
 4f1:	8b 45 08             	mov    0x8(%ebp),%eax
 4f4:	e8 a0 fe ff ff       	call   399 <printint>
        ap++;
 4f9:	83 c7 04             	add    $0x4,%edi
 4fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4ff:	83 c4 10             	add    $0x10,%esp
      state = 0;
 502:	be 00 00 00 00       	mov    $0x0,%esi
 507:	e9 39 ff ff ff       	jmp    445 <printf+0x2c>
        s = (char*)*ap;
 50c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 50f:	8b 30                	mov    (%eax),%esi
        ap++;
 511:	83 c0 04             	add    $0x4,%eax
 514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 517:	85 f6                	test   %esi,%esi
 519:	75 28                	jne    543 <printf+0x12a>
          s = "(null)";
 51b:	be d4 06 00 00       	mov    $0x6d4,%esi
 520:	8b 7d 08             	mov    0x8(%ebp),%edi
 523:	eb 0d                	jmp    532 <printf+0x119>
          putc(fd, *s);
 525:	0f be d2             	movsbl %dl,%edx
 528:	89 f8                	mov    %edi,%eax
 52a:	e8 50 fe ff ff       	call   37f <putc>
          s++;
 52f:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 532:	0f b6 16             	movzbl (%esi),%edx
 535:	84 d2                	test   %dl,%dl
 537:	75 ec                	jne    525 <printf+0x10c>
      state = 0;
 539:	be 00 00 00 00       	mov    $0x0,%esi
 53e:	e9 02 ff ff ff       	jmp    445 <printf+0x2c>
 543:	8b 7d 08             	mov    0x8(%ebp),%edi
 546:	eb ea                	jmp    532 <printf+0x119>
        putc(fd, *ap);
 548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 54b:	0f be 17             	movsbl (%edi),%edx
 54e:	8b 45 08             	mov    0x8(%ebp),%eax
 551:	e8 29 fe ff ff       	call   37f <putc>
        ap++;
 556:	83 c7 04             	add    $0x4,%edi
 559:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 55c:	be 00 00 00 00       	mov    $0x0,%esi
 561:	e9 df fe ff ff       	jmp    445 <printf+0x2c>
        putc(fd, c);
 566:	89 fa                	mov    %edi,%edx
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	e8 0f fe ff ff       	call   37f <putc>
      state = 0;
 570:	be 00 00 00 00       	mov    $0x0,%esi
 575:	e9 cb fe ff ff       	jmp    445 <printf+0x2c>
    }
  }
}
 57a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 57d:	5b                   	pop    %ebx
 57e:	5e                   	pop    %esi
 57f:	5f                   	pop    %edi
 580:	5d                   	pop    %ebp
 581:	c3                   	ret    

00000582 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 582:	55                   	push   %ebp
 583:	89 e5                	mov    %esp,%ebp
 585:	57                   	push   %edi
 586:	56                   	push   %esi
 587:	53                   	push   %ebx
 588:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 58b:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 58e:	a1 a4 09 00 00       	mov    0x9a4,%eax
 593:	eb 02                	jmp    597 <free+0x15>
 595:	89 d0                	mov    %edx,%eax
 597:	39 c8                	cmp    %ecx,%eax
 599:	73 04                	jae    59f <free+0x1d>
 59b:	39 08                	cmp    %ecx,(%eax)
 59d:	77 12                	ja     5b1 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 59f:	8b 10                	mov    (%eax),%edx
 5a1:	39 c2                	cmp    %eax,%edx
 5a3:	77 f0                	ja     595 <free+0x13>
 5a5:	39 c8                	cmp    %ecx,%eax
 5a7:	72 08                	jb     5b1 <free+0x2f>
 5a9:	39 ca                	cmp    %ecx,%edx
 5ab:	77 04                	ja     5b1 <free+0x2f>
 5ad:	89 d0                	mov    %edx,%eax
 5af:	eb e6                	jmp    597 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5b1:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5b4:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5b7:	8b 10                	mov    (%eax),%edx
 5b9:	39 d7                	cmp    %edx,%edi
 5bb:	74 19                	je     5d6 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5bd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5c0:	8b 50 04             	mov    0x4(%eax),%edx
 5c3:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5c6:	39 ce                	cmp    %ecx,%esi
 5c8:	74 1b                	je     5e5 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ca:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5cc:	a3 a4 09 00 00       	mov    %eax,0x9a4
}
 5d1:	5b                   	pop    %ebx
 5d2:	5e                   	pop    %esi
 5d3:	5f                   	pop    %edi
 5d4:	5d                   	pop    %ebp
 5d5:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5d6:	03 72 04             	add    0x4(%edx),%esi
 5d9:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5dc:	8b 10                	mov    (%eax),%edx
 5de:	8b 12                	mov    (%edx),%edx
 5e0:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5e3:	eb db                	jmp    5c0 <free+0x3e>
    p->s.size += bp->s.size;
 5e5:	03 53 fc             	add    -0x4(%ebx),%edx
 5e8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5eb:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5ee:	89 10                	mov    %edx,(%eax)
 5f0:	eb da                	jmp    5cc <free+0x4a>

000005f2 <morecore>:

static Header*
morecore(uint nu)
{
 5f2:	55                   	push   %ebp
 5f3:	89 e5                	mov    %esp,%ebp
 5f5:	53                   	push   %ebx
 5f6:	83 ec 04             	sub    $0x4,%esp
 5f9:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5fb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 600:	77 05                	ja     607 <morecore+0x15>
    nu = 4096;
 602:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 607:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 60e:	83 ec 0c             	sub    $0xc,%esp
 611:	50                   	push   %eax
 612:	e8 30 fd ff ff       	call   347 <sbrk>
  if(p == (char*)-1)
 617:	83 c4 10             	add    $0x10,%esp
 61a:	83 f8 ff             	cmp    $0xffffffff,%eax
 61d:	74 1c                	je     63b <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 61f:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 622:	83 c0 08             	add    $0x8,%eax
 625:	83 ec 0c             	sub    $0xc,%esp
 628:	50                   	push   %eax
 629:	e8 54 ff ff ff       	call   582 <free>
  return freep;
 62e:	a1 a4 09 00 00       	mov    0x9a4,%eax
 633:	83 c4 10             	add    $0x10,%esp
}
 636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 639:	c9                   	leave  
 63a:	c3                   	ret    
    return 0;
 63b:	b8 00 00 00 00       	mov    $0x0,%eax
 640:	eb f4                	jmp    636 <morecore+0x44>

00000642 <malloc>:

void*
malloc(uint nbytes)
{
 642:	55                   	push   %ebp
 643:	89 e5                	mov    %esp,%ebp
 645:	53                   	push   %ebx
 646:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 649:	8b 45 08             	mov    0x8(%ebp),%eax
 64c:	8d 58 07             	lea    0x7(%eax),%ebx
 64f:	c1 eb 03             	shr    $0x3,%ebx
 652:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 655:	8b 0d a4 09 00 00    	mov    0x9a4,%ecx
 65b:	85 c9                	test   %ecx,%ecx
 65d:	74 04                	je     663 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 65f:	8b 01                	mov    (%ecx),%eax
 661:	eb 4d                	jmp    6b0 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 663:	c7 05 a4 09 00 00 a8 	movl   $0x9a8,0x9a4
 66a:	09 00 00 
 66d:	c7 05 a8 09 00 00 a8 	movl   $0x9a8,0x9a8
 674:	09 00 00 
    base.s.size = 0;
 677:	c7 05 ac 09 00 00 00 	movl   $0x0,0x9ac
 67e:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 681:	b9 a8 09 00 00       	mov    $0x9a8,%ecx
 686:	eb d7                	jmp    65f <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 688:	39 da                	cmp    %ebx,%edx
 68a:	74 1a                	je     6a6 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 68c:	29 da                	sub    %ebx,%edx
 68e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 691:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 694:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 697:	89 0d a4 09 00 00    	mov    %ecx,0x9a4
      return (void*)(p + 1);
 69d:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6a0:	83 c4 04             	add    $0x4,%esp
 6a3:	5b                   	pop    %ebx
 6a4:	5d                   	pop    %ebp
 6a5:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6a6:	8b 10                	mov    (%eax),%edx
 6a8:	89 11                	mov    %edx,(%ecx)
 6aa:	eb eb                	jmp    697 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ac:	89 c1                	mov    %eax,%ecx
 6ae:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6b0:	8b 50 04             	mov    0x4(%eax),%edx
 6b3:	39 da                	cmp    %ebx,%edx
 6b5:	73 d1                	jae    688 <malloc+0x46>
    if(p == freep)
 6b7:	39 05 a4 09 00 00    	cmp    %eax,0x9a4
 6bd:	75 ed                	jne    6ac <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6bf:	89 d8                	mov    %ebx,%eax
 6c1:	e8 2c ff ff ff       	call   5f2 <morecore>
 6c6:	85 c0                	test   %eax,%eax
 6c8:	75 e2                	jne    6ac <malloc+0x6a>
        return 0;
 6ca:	b8 00 00 00 00       	mov    $0x0,%eax
 6cf:	eb cf                	jmp    6a0 <malloc+0x5e>
