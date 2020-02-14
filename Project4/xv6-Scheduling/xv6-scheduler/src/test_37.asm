
_test_37:     file format elf32-i386


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
  36:	e8 13 03 00 00       	call   34e <sleep>
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
  for (int i = 0; i < 12; ++i) {
  6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  72:	83 fb 0b             	cmp    $0xb,%ebx
  75:	0f 8f a7 00 00 00    	jg     122 <main+0xc9>
    int pid = fork2((i * i * i) % 4);
  7b:	89 df                	mov    %ebx,%edi
  7d:	0f af fb             	imul   %ebx,%edi
  80:	89 fe                	mov    %edi,%esi
  82:	0f af f3             	imul   %ebx,%esi
  85:	89 f2                	mov    %esi,%edx
  87:	c1 fa 1f             	sar    $0x1f,%edx
  8a:	c1 ea 1e             	shr    $0x1e,%edx
  8d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  90:	83 e0 03             	and    $0x3,%eax
  93:	29 d0                	sub    %edx,%eax
  95:	83 ec 0c             	sub    $0xc,%esp
  98:	50                   	push   %eax
  99:	e8 d8 02 00 00       	call   376 <fork2>
    if (pid == 0) {
  9e:	83 c4 10             	add    $0x10,%esp
  a1:	85 c0                	test   %eax,%eax
  a3:	74 05                	je     aa <main+0x51>
  for (int i = 0; i < 12; ++i) {
  a5:	83 c3 01             	add    $0x1,%ebx
  a8:	eb c8                	jmp    72 <main+0x19>
      workload(10 * i * i * i, i * i);
  aa:	6b c3 0a             	imul   $0xa,%ebx,%eax
  ad:	0f af c3             	imul   %ebx,%eax
  b0:	83 ec 08             	sub    $0x8,%esp
  b3:	57                   	push   %edi
  b4:	0f af d8             	imul   %eax,%ebx
  b7:	53                   	push   %ebx
  b8:	e8 43 ff ff ff       	call   0 <workload>
      int pid2 = fork();
  bd:	e8 f4 01 00 00       	call   2b6 <fork>
      if (pid2 == 0) {
  c2:	83 c4 10             	add    $0x10,%esp
  c5:	85 c0                	test   %eax,%eax
  c7:	75 38                	jne    101 <main+0xa8>
        int pid3 = fork2((i * i * i) % 2);
  c9:	b9 02 00 00 00       	mov    $0x2,%ecx
  ce:	89 f0                	mov    %esi,%eax
  d0:	99                   	cltd   
  d1:	f7 f9                	idiv   %ecx
  d3:	83 ec 0c             	sub    $0xc,%esp
  d6:	52                   	push   %edx
  d7:	e8 9a 02 00 00       	call   376 <fork2>
  dc:	89 c3                	mov    %eax,%ebx
        workload(67 * (i * i * i), (i * i));
  de:	83 c4 08             	add    $0x8,%esp
  e1:	57                   	push   %edi
  e2:	6b f6 43             	imul   $0x43,%esi,%esi
  e5:	56                   	push   %esi
  e6:	e8 15 ff ff ff       	call   0 <workload>
        if (pid3 != 0) {
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	85 db                	test   %ebx,%ebx
  f0:	74 0a                	je     fc <main+0xa3>
          while(wait() != -1);
  f2:	e8 cf 01 00 00       	call   2c6 <wait>
  f7:	83 f8 ff             	cmp    $0xffffffff,%eax
  fa:	75 f6                	jne    f2 <main+0x99>
        }
        exit();
  fc:	e8 bd 01 00 00       	call   2be <exit>
      } else {
        workload(5 * (i * i * i), 2 * (i * i));
 101:	83 ec 08             	sub    $0x8,%esp
 104:	01 ff                	add    %edi,%edi
 106:	57                   	push   %edi
 107:	6b f6 05             	imul   $0x5,%esi,%esi
 10a:	56                   	push   %esi
 10b:	e8 f0 fe ff ff       	call   0 <workload>
        while(wait() != -1);
 110:	83 c4 10             	add    $0x10,%esp
 113:	e8 ae 01 00 00       	call   2c6 <wait>
 118:	83 f8 ff             	cmp    $0xffffffff,%eax
 11b:	75 f6                	jne    113 <main+0xba>
        exit();
 11d:	e8 9c 01 00 00       	call   2be <exit>
      }
    }
  }

  while(wait() != -1);
 122:	e8 9f 01 00 00       	call   2c6 <wait>
 127:	83 f8 ff             	cmp    $0xffffffff,%eax
 12a:	75 f6                	jne    122 <main+0xc9>
  exit();
 12c:	e8 8d 01 00 00       	call   2be <exit>

00000131 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
 134:	53                   	push   %ebx
 135:	8b 45 08             	mov    0x8(%ebp),%eax
 138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13b:	89 c2                	mov    %eax,%edx
 13d:	0f b6 19             	movzbl (%ecx),%ebx
 140:	88 1a                	mov    %bl,(%edx)
 142:	8d 52 01             	lea    0x1(%edx),%edx
 145:	8d 49 01             	lea    0x1(%ecx),%ecx
 148:	84 db                	test   %bl,%bl
 14a:	75 f1                	jne    13d <strcpy+0xc>
    ;
  return os;
}
 14c:	5b                   	pop    %ebx
 14d:	5d                   	pop    %ebp
 14e:	c3                   	ret    

0000014f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14f:	55                   	push   %ebp
 150:	89 e5                	mov    %esp,%ebp
 152:	8b 4d 08             	mov    0x8(%ebp),%ecx
 155:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 158:	eb 06                	jmp    160 <strcmp+0x11>
    p++, q++;
 15a:	83 c1 01             	add    $0x1,%ecx
 15d:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 160:	0f b6 01             	movzbl (%ecx),%eax
 163:	84 c0                	test   %al,%al
 165:	74 04                	je     16b <strcmp+0x1c>
 167:	3a 02                	cmp    (%edx),%al
 169:	74 ef                	je     15a <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 16b:	0f b6 c0             	movzbl %al,%eax
 16e:	0f b6 12             	movzbl (%edx),%edx
 171:	29 d0                	sub    %edx,%eax
}
 173:	5d                   	pop    %ebp
 174:	c3                   	ret    

00000175 <strlen>:

uint
strlen(const char *s)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 17b:	ba 00 00 00 00       	mov    $0x0,%edx
 180:	eb 03                	jmp    185 <strlen+0x10>
 182:	83 c2 01             	add    $0x1,%edx
 185:	89 d0                	mov    %edx,%eax
 187:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 18b:	75 f5                	jne    182 <strlen+0xd>
    ;
  return n;
}
 18d:	5d                   	pop    %ebp
 18e:	c3                   	ret    

0000018f <memset>:

void*
memset(void *dst, int c, uint n)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	57                   	push   %edi
 193:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 196:	89 d7                	mov    %edx,%edi
 198:	8b 4d 10             	mov    0x10(%ebp),%ecx
 19b:	8b 45 0c             	mov    0xc(%ebp),%eax
 19e:	fc                   	cld    
 19f:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1a1:	89 d0                	mov    %edx,%eax
 1a3:	5f                   	pop    %edi
 1a4:	5d                   	pop    %ebp
 1a5:	c3                   	ret    

000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	55                   	push   %ebp
 1a7:	89 e5                	mov    %esp,%ebp
 1a9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1b0:	0f b6 10             	movzbl (%eax),%edx
 1b3:	84 d2                	test   %dl,%dl
 1b5:	74 09                	je     1c0 <strchr+0x1a>
    if(*s == c)
 1b7:	38 ca                	cmp    %cl,%dl
 1b9:	74 0a                	je     1c5 <strchr+0x1f>
  for(; *s; s++)
 1bb:	83 c0 01             	add    $0x1,%eax
 1be:	eb f0                	jmp    1b0 <strchr+0xa>
      return (char*)s;
  return 0;
 1c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1c5:	5d                   	pop    %ebp
 1c6:	c3                   	ret    

000001c7 <gets>:

char*
gets(char *buf, int max)
{
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	57                   	push   %edi
 1cb:	56                   	push   %esi
 1cc:	53                   	push   %ebx
 1cd:	83 ec 1c             	sub    $0x1c,%esp
 1d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d3:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d8:	8d 73 01             	lea    0x1(%ebx),%esi
 1db:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1de:	7d 2e                	jge    20e <gets+0x47>
    cc = read(0, &c, 1);
 1e0:	83 ec 04             	sub    $0x4,%esp
 1e3:	6a 01                	push   $0x1
 1e5:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1e8:	50                   	push   %eax
 1e9:	6a 00                	push   $0x0
 1eb:	e8 e6 00 00 00       	call   2d6 <read>
    if(cc < 1)
 1f0:	83 c4 10             	add    $0x10,%esp
 1f3:	85 c0                	test   %eax,%eax
 1f5:	7e 17                	jle    20e <gets+0x47>
      break;
    buf[i++] = c;
 1f7:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1fb:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1fe:	3c 0a                	cmp    $0xa,%al
 200:	0f 94 c2             	sete   %dl
 203:	3c 0d                	cmp    $0xd,%al
 205:	0f 94 c0             	sete   %al
    buf[i++] = c;
 208:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 20a:	08 c2                	or     %al,%dl
 20c:	74 ca                	je     1d8 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 20e:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 212:	89 f8                	mov    %edi,%eax
 214:	8d 65 f4             	lea    -0xc(%ebp),%esp
 217:	5b                   	pop    %ebx
 218:	5e                   	pop    %esi
 219:	5f                   	pop    %edi
 21a:	5d                   	pop    %ebp
 21b:	c3                   	ret    

0000021c <stat>:

int
stat(const char *n, struct stat *st)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
 21f:	56                   	push   %esi
 220:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 221:	83 ec 08             	sub    $0x8,%esp
 224:	6a 00                	push   $0x0
 226:	ff 75 08             	pushl  0x8(%ebp)
 229:	e8 d0 00 00 00       	call   2fe <open>
  if(fd < 0)
 22e:	83 c4 10             	add    $0x10,%esp
 231:	85 c0                	test   %eax,%eax
 233:	78 24                	js     259 <stat+0x3d>
 235:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 237:	83 ec 08             	sub    $0x8,%esp
 23a:	ff 75 0c             	pushl  0xc(%ebp)
 23d:	50                   	push   %eax
 23e:	e8 d3 00 00 00       	call   316 <fstat>
 243:	89 c6                	mov    %eax,%esi
  close(fd);
 245:	89 1c 24             	mov    %ebx,(%esp)
 248:	e8 99 00 00 00       	call   2e6 <close>
  return r;
 24d:	83 c4 10             	add    $0x10,%esp
}
 250:	89 f0                	mov    %esi,%eax
 252:	8d 65 f8             	lea    -0x8(%ebp),%esp
 255:	5b                   	pop    %ebx
 256:	5e                   	pop    %esi
 257:	5d                   	pop    %ebp
 258:	c3                   	ret    
    return -1;
 259:	be ff ff ff ff       	mov    $0xffffffff,%esi
 25e:	eb f0                	jmp    250 <stat+0x34>

00000260 <atoi>:

int
atoi(const char *s)
{
 260:	55                   	push   %ebp
 261:	89 e5                	mov    %esp,%ebp
 263:	53                   	push   %ebx
 264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 267:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 26c:	eb 10                	jmp    27e <atoi+0x1e>
    n = n*10 + *s++ - '0';
 26e:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 271:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 274:	83 c1 01             	add    $0x1,%ecx
 277:	0f be d2             	movsbl %dl,%edx
 27a:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 27e:	0f b6 11             	movzbl (%ecx),%edx
 281:	8d 5a d0             	lea    -0x30(%edx),%ebx
 284:	80 fb 09             	cmp    $0x9,%bl
 287:	76 e5                	jbe    26e <atoi+0xe>
  return n;
}
 289:	5b                   	pop    %ebx
 28a:	5d                   	pop    %ebp
 28b:	c3                   	ret    

0000028c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	56                   	push   %esi
 290:	53                   	push   %ebx
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 297:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 29a:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 29c:	eb 0d                	jmp    2ab <memmove+0x1f>
    *dst++ = *src++;
 29e:	0f b6 13             	movzbl (%ebx),%edx
 2a1:	88 11                	mov    %dl,(%ecx)
 2a3:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2a6:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2a9:	89 f2                	mov    %esi,%edx
 2ab:	8d 72 ff             	lea    -0x1(%edx),%esi
 2ae:	85 d2                	test   %edx,%edx
 2b0:	7f ec                	jg     29e <memmove+0x12>
  return vdst;
}
 2b2:	5b                   	pop    %ebx
 2b3:	5e                   	pop    %esi
 2b4:	5d                   	pop    %ebp
 2b5:	c3                   	ret    

000002b6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b6:	b8 01 00 00 00       	mov    $0x1,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <exit>:
SYSCALL(exit)
 2be:	b8 02 00 00 00       	mov    $0x2,%eax
 2c3:	cd 40                	int    $0x40
 2c5:	c3                   	ret    

000002c6 <wait>:
SYSCALL(wait)
 2c6:	b8 03 00 00 00       	mov    $0x3,%eax
 2cb:	cd 40                	int    $0x40
 2cd:	c3                   	ret    

000002ce <pipe>:
SYSCALL(pipe)
 2ce:	b8 04 00 00 00       	mov    $0x4,%eax
 2d3:	cd 40                	int    $0x40
 2d5:	c3                   	ret    

000002d6 <read>:
SYSCALL(read)
 2d6:	b8 05 00 00 00       	mov    $0x5,%eax
 2db:	cd 40                	int    $0x40
 2dd:	c3                   	ret    

000002de <write>:
SYSCALL(write)
 2de:	b8 10 00 00 00       	mov    $0x10,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <close>:
SYSCALL(close)
 2e6:	b8 15 00 00 00       	mov    $0x15,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <kill>:
SYSCALL(kill)
 2ee:	b8 06 00 00 00       	mov    $0x6,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <exec>:
SYSCALL(exec)
 2f6:	b8 07 00 00 00       	mov    $0x7,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <open>:
SYSCALL(open)
 2fe:	b8 0f 00 00 00       	mov    $0xf,%eax
 303:	cd 40                	int    $0x40
 305:	c3                   	ret    

00000306 <mknod>:
SYSCALL(mknod)
 306:	b8 11 00 00 00       	mov    $0x11,%eax
 30b:	cd 40                	int    $0x40
 30d:	c3                   	ret    

0000030e <unlink>:
SYSCALL(unlink)
 30e:	b8 12 00 00 00       	mov    $0x12,%eax
 313:	cd 40                	int    $0x40
 315:	c3                   	ret    

00000316 <fstat>:
SYSCALL(fstat)
 316:	b8 08 00 00 00       	mov    $0x8,%eax
 31b:	cd 40                	int    $0x40
 31d:	c3                   	ret    

0000031e <link>:
SYSCALL(link)
 31e:	b8 13 00 00 00       	mov    $0x13,%eax
 323:	cd 40                	int    $0x40
 325:	c3                   	ret    

00000326 <mkdir>:
SYSCALL(mkdir)
 326:	b8 14 00 00 00       	mov    $0x14,%eax
 32b:	cd 40                	int    $0x40
 32d:	c3                   	ret    

0000032e <chdir>:
SYSCALL(chdir)
 32e:	b8 09 00 00 00       	mov    $0x9,%eax
 333:	cd 40                	int    $0x40
 335:	c3                   	ret    

00000336 <dup>:
SYSCALL(dup)
 336:	b8 0a 00 00 00       	mov    $0xa,%eax
 33b:	cd 40                	int    $0x40
 33d:	c3                   	ret    

0000033e <getpid>:
SYSCALL(getpid)
 33e:	b8 0b 00 00 00       	mov    $0xb,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <sbrk>:
SYSCALL(sbrk)
 346:	b8 0c 00 00 00       	mov    $0xc,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <sleep>:
SYSCALL(sleep)
 34e:	b8 0d 00 00 00       	mov    $0xd,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <uptime>:
SYSCALL(uptime)
 356:	b8 0e 00 00 00       	mov    $0xe,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <setpri>:
SYSCALL(setpri)
 35e:	b8 16 00 00 00       	mov    $0x16,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <getpri>:
SYSCALL(getpri)
 366:	b8 17 00 00 00       	mov    $0x17,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <getpinfo>:
SYSCALL(getpinfo)
 36e:	b8 18 00 00 00       	mov    $0x18,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <fork2>:
SYSCALL(fork2)
 376:	b8 19 00 00 00       	mov    $0x19,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 37e:	55                   	push   %ebp
 37f:	89 e5                	mov    %esp,%ebp
 381:	83 ec 1c             	sub    $0x1c,%esp
 384:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 387:	6a 01                	push   $0x1
 389:	8d 55 f4             	lea    -0xc(%ebp),%edx
 38c:	52                   	push   %edx
 38d:	50                   	push   %eax
 38e:	e8 4b ff ff ff       	call   2de <write>
}
 393:	83 c4 10             	add    $0x10,%esp
 396:	c9                   	leave  
 397:	c3                   	ret    

00000398 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
 39b:	57                   	push   %edi
 39c:	56                   	push   %esi
 39d:	53                   	push   %ebx
 39e:	83 ec 2c             	sub    $0x2c,%esp
 3a1:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3a7:	0f 95 c3             	setne  %bl
 3aa:	89 d0                	mov    %edx,%eax
 3ac:	c1 e8 1f             	shr    $0x1f,%eax
 3af:	84 c3                	test   %al,%bl
 3b1:	74 10                	je     3c3 <printint+0x2b>
    neg = 1;
    x = -xx;
 3b3:	f7 da                	neg    %edx
    neg = 1;
 3b5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3bc:	be 00 00 00 00       	mov    $0x0,%esi
 3c1:	eb 0b                	jmp    3ce <printint+0x36>
  neg = 0;
 3c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3ca:	eb f0                	jmp    3bc <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3cc:	89 c6                	mov    %eax,%esi
 3ce:	89 d0                	mov    %edx,%eax
 3d0:	ba 00 00 00 00       	mov    $0x0,%edx
 3d5:	f7 f1                	div    %ecx
 3d7:	89 c3                	mov    %eax,%ebx
 3d9:	8d 46 01             	lea    0x1(%esi),%eax
 3dc:	0f b6 92 d8 06 00 00 	movzbl 0x6d8(%edx),%edx
 3e3:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3e7:	89 da                	mov    %ebx,%edx
 3e9:	85 db                	test   %ebx,%ebx
 3eb:	75 df                	jne    3cc <printint+0x34>
 3ed:	89 c3                	mov    %eax,%ebx
  if(neg)
 3ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3f3:	74 16                	je     40b <printint+0x73>
    buf[i++] = '-';
 3f5:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3fa:	8d 5e 02             	lea    0x2(%esi),%ebx
 3fd:	eb 0c                	jmp    40b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3ff:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 404:	89 f8                	mov    %edi,%eax
 406:	e8 73 ff ff ff       	call   37e <putc>
  while(--i >= 0)
 40b:	83 eb 01             	sub    $0x1,%ebx
 40e:	79 ef                	jns    3ff <printint+0x67>
}
 410:	83 c4 2c             	add    $0x2c,%esp
 413:	5b                   	pop    %ebx
 414:	5e                   	pop    %esi
 415:	5f                   	pop    %edi
 416:	5d                   	pop    %ebp
 417:	c3                   	ret    

00000418 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	57                   	push   %edi
 41c:	56                   	push   %esi
 41d:	53                   	push   %ebx
 41e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 421:	8d 45 10             	lea    0x10(%ebp),%eax
 424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 427:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 42c:	bb 00 00 00 00       	mov    $0x0,%ebx
 431:	eb 14                	jmp    447 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 433:	89 fa                	mov    %edi,%edx
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	e8 41 ff ff ff       	call   37e <putc>
 43d:	eb 05                	jmp    444 <printf+0x2c>
      }
    } else if(state == '%'){
 43f:	83 fe 25             	cmp    $0x25,%esi
 442:	74 25                	je     469 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 444:	83 c3 01             	add    $0x1,%ebx
 447:	8b 45 0c             	mov    0xc(%ebp),%eax
 44a:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 44e:	84 c0                	test   %al,%al
 450:	0f 84 23 01 00 00    	je     579 <printf+0x161>
    c = fmt[i] & 0xff;
 456:	0f be f8             	movsbl %al,%edi
 459:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 45c:	85 f6                	test   %esi,%esi
 45e:	75 df                	jne    43f <printf+0x27>
      if(c == '%'){
 460:	83 f8 25             	cmp    $0x25,%eax
 463:	75 ce                	jne    433 <printf+0x1b>
        state = '%';
 465:	89 c6                	mov    %eax,%esi
 467:	eb db                	jmp    444 <printf+0x2c>
      if(c == 'd'){
 469:	83 f8 64             	cmp    $0x64,%eax
 46c:	74 49                	je     4b7 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 46e:	83 f8 78             	cmp    $0x78,%eax
 471:	0f 94 c1             	sete   %cl
 474:	83 f8 70             	cmp    $0x70,%eax
 477:	0f 94 c2             	sete   %dl
 47a:	08 d1                	or     %dl,%cl
 47c:	75 63                	jne    4e1 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 47e:	83 f8 73             	cmp    $0x73,%eax
 481:	0f 84 84 00 00 00    	je     50b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 487:	83 f8 63             	cmp    $0x63,%eax
 48a:	0f 84 b7 00 00 00    	je     547 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 490:	83 f8 25             	cmp    $0x25,%eax
 493:	0f 84 cc 00 00 00    	je     565 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 499:	ba 25 00 00 00       	mov    $0x25,%edx
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	e8 d8 fe ff ff       	call   37e <putc>
        putc(fd, c);
 4a6:	89 fa                	mov    %edi,%edx
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	e8 ce fe ff ff       	call   37e <putc>
      }
      state = 0;
 4b0:	be 00 00 00 00       	mov    $0x0,%esi
 4b5:	eb 8d                	jmp    444 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ba:	8b 17                	mov    (%edi),%edx
 4bc:	83 ec 0c             	sub    $0xc,%esp
 4bf:	6a 01                	push   $0x1
 4c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	e8 ca fe ff ff       	call   398 <printint>
        ap++;
 4ce:	83 c7 04             	add    $0x4,%edi
 4d1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4d4:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4d7:	be 00 00 00 00       	mov    $0x0,%esi
 4dc:	e9 63 ff ff ff       	jmp    444 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4e4:	8b 17                	mov    (%edi),%edx
 4e6:	83 ec 0c             	sub    $0xc,%esp
 4e9:	6a 00                	push   $0x0
 4eb:	b9 10 00 00 00       	mov    $0x10,%ecx
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	e8 a0 fe ff ff       	call   398 <printint>
        ap++;
 4f8:	83 c7 04             	add    $0x4,%edi
 4fb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4fe:	83 c4 10             	add    $0x10,%esp
      state = 0;
 501:	be 00 00 00 00       	mov    $0x0,%esi
 506:	e9 39 ff ff ff       	jmp    444 <printf+0x2c>
        s = (char*)*ap;
 50b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 50e:	8b 30                	mov    (%eax),%esi
        ap++;
 510:	83 c0 04             	add    $0x4,%eax
 513:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 516:	85 f6                	test   %esi,%esi
 518:	75 28                	jne    542 <printf+0x12a>
          s = "(null)";
 51a:	be d0 06 00 00       	mov    $0x6d0,%esi
 51f:	8b 7d 08             	mov    0x8(%ebp),%edi
 522:	eb 0d                	jmp    531 <printf+0x119>
          putc(fd, *s);
 524:	0f be d2             	movsbl %dl,%edx
 527:	89 f8                	mov    %edi,%eax
 529:	e8 50 fe ff ff       	call   37e <putc>
          s++;
 52e:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 531:	0f b6 16             	movzbl (%esi),%edx
 534:	84 d2                	test   %dl,%dl
 536:	75 ec                	jne    524 <printf+0x10c>
      state = 0;
 538:	be 00 00 00 00       	mov    $0x0,%esi
 53d:	e9 02 ff ff ff       	jmp    444 <printf+0x2c>
 542:	8b 7d 08             	mov    0x8(%ebp),%edi
 545:	eb ea                	jmp    531 <printf+0x119>
        putc(fd, *ap);
 547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 54a:	0f be 17             	movsbl (%edi),%edx
 54d:	8b 45 08             	mov    0x8(%ebp),%eax
 550:	e8 29 fe ff ff       	call   37e <putc>
        ap++;
 555:	83 c7 04             	add    $0x4,%edi
 558:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 55b:	be 00 00 00 00       	mov    $0x0,%esi
 560:	e9 df fe ff ff       	jmp    444 <printf+0x2c>
        putc(fd, c);
 565:	89 fa                	mov    %edi,%edx
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	e8 0f fe ff ff       	call   37e <putc>
      state = 0;
 56f:	be 00 00 00 00       	mov    $0x0,%esi
 574:	e9 cb fe ff ff       	jmp    444 <printf+0x2c>
    }
  }
}
 579:	8d 65 f4             	lea    -0xc(%ebp),%esp
 57c:	5b                   	pop    %ebx
 57d:	5e                   	pop    %esi
 57e:	5f                   	pop    %edi
 57f:	5d                   	pop    %ebp
 580:	c3                   	ret    

00000581 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 581:	55                   	push   %ebp
 582:	89 e5                	mov    %esp,%ebp
 584:	57                   	push   %edi
 585:	56                   	push   %esi
 586:	53                   	push   %ebx
 587:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 58a:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 58d:	a1 a4 09 00 00       	mov    0x9a4,%eax
 592:	eb 02                	jmp    596 <free+0x15>
 594:	89 d0                	mov    %edx,%eax
 596:	39 c8                	cmp    %ecx,%eax
 598:	73 04                	jae    59e <free+0x1d>
 59a:	39 08                	cmp    %ecx,(%eax)
 59c:	77 12                	ja     5b0 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 59e:	8b 10                	mov    (%eax),%edx
 5a0:	39 c2                	cmp    %eax,%edx
 5a2:	77 f0                	ja     594 <free+0x13>
 5a4:	39 c8                	cmp    %ecx,%eax
 5a6:	72 08                	jb     5b0 <free+0x2f>
 5a8:	39 ca                	cmp    %ecx,%edx
 5aa:	77 04                	ja     5b0 <free+0x2f>
 5ac:	89 d0                	mov    %edx,%eax
 5ae:	eb e6                	jmp    596 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5b0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5b3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5b6:	8b 10                	mov    (%eax),%edx
 5b8:	39 d7                	cmp    %edx,%edi
 5ba:	74 19                	je     5d5 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5bc:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5bf:	8b 50 04             	mov    0x4(%eax),%edx
 5c2:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5c5:	39 ce                	cmp    %ecx,%esi
 5c7:	74 1b                	je     5e4 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5c9:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5cb:	a3 a4 09 00 00       	mov    %eax,0x9a4
}
 5d0:	5b                   	pop    %ebx
 5d1:	5e                   	pop    %esi
 5d2:	5f                   	pop    %edi
 5d3:	5d                   	pop    %ebp
 5d4:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5d5:	03 72 04             	add    0x4(%edx),%esi
 5d8:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5db:	8b 10                	mov    (%eax),%edx
 5dd:	8b 12                	mov    (%edx),%edx
 5df:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5e2:	eb db                	jmp    5bf <free+0x3e>
    p->s.size += bp->s.size;
 5e4:	03 53 fc             	add    -0x4(%ebx),%edx
 5e7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5ea:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5ed:	89 10                	mov    %edx,(%eax)
 5ef:	eb da                	jmp    5cb <free+0x4a>

000005f1 <morecore>:

static Header*
morecore(uint nu)
{
 5f1:	55                   	push   %ebp
 5f2:	89 e5                	mov    %esp,%ebp
 5f4:	53                   	push   %ebx
 5f5:	83 ec 04             	sub    $0x4,%esp
 5f8:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5fa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5ff:	77 05                	ja     606 <morecore+0x15>
    nu = 4096;
 601:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 606:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 60d:	83 ec 0c             	sub    $0xc,%esp
 610:	50                   	push   %eax
 611:	e8 30 fd ff ff       	call   346 <sbrk>
  if(p == (char*)-1)
 616:	83 c4 10             	add    $0x10,%esp
 619:	83 f8 ff             	cmp    $0xffffffff,%eax
 61c:	74 1c                	je     63a <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 61e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 621:	83 c0 08             	add    $0x8,%eax
 624:	83 ec 0c             	sub    $0xc,%esp
 627:	50                   	push   %eax
 628:	e8 54 ff ff ff       	call   581 <free>
  return freep;
 62d:	a1 a4 09 00 00       	mov    0x9a4,%eax
 632:	83 c4 10             	add    $0x10,%esp
}
 635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 638:	c9                   	leave  
 639:	c3                   	ret    
    return 0;
 63a:	b8 00 00 00 00       	mov    $0x0,%eax
 63f:	eb f4                	jmp    635 <morecore+0x44>

00000641 <malloc>:

void*
malloc(uint nbytes)
{
 641:	55                   	push   %ebp
 642:	89 e5                	mov    %esp,%ebp
 644:	53                   	push   %ebx
 645:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 648:	8b 45 08             	mov    0x8(%ebp),%eax
 64b:	8d 58 07             	lea    0x7(%eax),%ebx
 64e:	c1 eb 03             	shr    $0x3,%ebx
 651:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 654:	8b 0d a4 09 00 00    	mov    0x9a4,%ecx
 65a:	85 c9                	test   %ecx,%ecx
 65c:	74 04                	je     662 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 65e:	8b 01                	mov    (%ecx),%eax
 660:	eb 4d                	jmp    6af <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 662:	c7 05 a4 09 00 00 a8 	movl   $0x9a8,0x9a4
 669:	09 00 00 
 66c:	c7 05 a8 09 00 00 a8 	movl   $0x9a8,0x9a8
 673:	09 00 00 
    base.s.size = 0;
 676:	c7 05 ac 09 00 00 00 	movl   $0x0,0x9ac
 67d:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 680:	b9 a8 09 00 00       	mov    $0x9a8,%ecx
 685:	eb d7                	jmp    65e <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 687:	39 da                	cmp    %ebx,%edx
 689:	74 1a                	je     6a5 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 68b:	29 da                	sub    %ebx,%edx
 68d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 690:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 693:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 696:	89 0d a4 09 00 00    	mov    %ecx,0x9a4
      return (void*)(p + 1);
 69c:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 69f:	83 c4 04             	add    $0x4,%esp
 6a2:	5b                   	pop    %ebx
 6a3:	5d                   	pop    %ebp
 6a4:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6a5:	8b 10                	mov    (%eax),%edx
 6a7:	89 11                	mov    %edx,(%ecx)
 6a9:	eb eb                	jmp    696 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ab:	89 c1                	mov    %eax,%ecx
 6ad:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6af:	8b 50 04             	mov    0x4(%eax),%edx
 6b2:	39 da                	cmp    %ebx,%edx
 6b4:	73 d1                	jae    687 <malloc+0x46>
    if(p == freep)
 6b6:	39 05 a4 09 00 00    	cmp    %eax,0x9a4
 6bc:	75 ed                	jne    6ab <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6be:	89 d8                	mov    %ebx,%eax
 6c0:	e8 2c ff ff ff       	call   5f1 <morecore>
 6c5:	85 c0                	test   %eax,%eax
 6c7:	75 e2                	jne    6ab <malloc+0x6a>
        return 0;
 6c9:	b8 00 00 00 00       	mov    $0x0,%eax
 6ce:	eb cf                	jmp    69f <malloc+0x5e>
