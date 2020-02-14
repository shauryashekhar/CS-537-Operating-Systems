
_loop:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, char **argv)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 10             	sub    $0x10,%esp
	sleep(100);
  11:	6a 64                	push   $0x64
  13:	e8 39 02 00 00       	call   251 <sleep>
        printf(1,"loop called\n");
  18:	83 c4 08             	add    $0x8,%esp
  1b:	68 d4 05 00 00       	push   $0x5d4
  20:	6a 01                	push   $0x1
  22:	e8 f4 02 00 00       	call   31b <printf>
	int pid = getpid();
  27:	e8 15 02 00 00       	call   241 <getpid>
	return pid;
}
  2c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  2f:	c9                   	leave  
  30:	8d 61 fc             	lea    -0x4(%ecx),%esp
  33:	c3                   	ret    

00000034 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  34:	55                   	push   %ebp
  35:	89 e5                	mov    %esp,%ebp
  37:	53                   	push   %ebx
  38:	8b 45 08             	mov    0x8(%ebp),%eax
  3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3e:	89 c2                	mov    %eax,%edx
  40:	0f b6 19             	movzbl (%ecx),%ebx
  43:	88 1a                	mov    %bl,(%edx)
  45:	8d 52 01             	lea    0x1(%edx),%edx
  48:	8d 49 01             	lea    0x1(%ecx),%ecx
  4b:	84 db                	test   %bl,%bl
  4d:	75 f1                	jne    40 <strcpy+0xc>
    ;
  return os;
}
  4f:	5b                   	pop    %ebx
  50:	5d                   	pop    %ebp
  51:	c3                   	ret    

00000052 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  52:	55                   	push   %ebp
  53:	89 e5                	mov    %esp,%ebp
  55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  58:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  5b:	eb 06                	jmp    63 <strcmp+0x11>
    p++, q++;
  5d:	83 c1 01             	add    $0x1,%ecx
  60:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  63:	0f b6 01             	movzbl (%ecx),%eax
  66:	84 c0                	test   %al,%al
  68:	74 04                	je     6e <strcmp+0x1c>
  6a:	3a 02                	cmp    (%edx),%al
  6c:	74 ef                	je     5d <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  6e:	0f b6 c0             	movzbl %al,%eax
  71:	0f b6 12             	movzbl (%edx),%edx
  74:	29 d0                	sub    %edx,%eax
}
  76:	5d                   	pop    %ebp
  77:	c3                   	ret    

00000078 <strlen>:

uint
strlen(const char *s)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  7e:	ba 00 00 00 00       	mov    $0x0,%edx
  83:	eb 03                	jmp    88 <strlen+0x10>
  85:	83 c2 01             	add    $0x1,%edx
  88:	89 d0                	mov    %edx,%eax
  8a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8e:	75 f5                	jne    85 <strlen+0xd>
    ;
  return n;
}
  90:	5d                   	pop    %ebp
  91:	c3                   	ret    

00000092 <memset>:

void*
memset(void *dst, int c, uint n)
{
  92:	55                   	push   %ebp
  93:	89 e5                	mov    %esp,%ebp
  95:	57                   	push   %edi
  96:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  99:	89 d7                	mov    %edx,%edi
  9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  a1:	fc                   	cld    
  a2:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  a4:	89 d0                	mov    %edx,%eax
  a6:	5f                   	pop    %edi
  a7:	5d                   	pop    %ebp
  a8:	c3                   	ret    

000000a9 <strchr>:

char*
strchr(const char *s, char c)
{
  a9:	55                   	push   %ebp
  aa:	89 e5                	mov    %esp,%ebp
  ac:	8b 45 08             	mov    0x8(%ebp),%eax
  af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  b3:	0f b6 10             	movzbl (%eax),%edx
  b6:	84 d2                	test   %dl,%dl
  b8:	74 09                	je     c3 <strchr+0x1a>
    if(*s == c)
  ba:	38 ca                	cmp    %cl,%dl
  bc:	74 0a                	je     c8 <strchr+0x1f>
  for(; *s; s++)
  be:	83 c0 01             	add    $0x1,%eax
  c1:	eb f0                	jmp    b3 <strchr+0xa>
      return (char*)s;
  return 0;
  c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c8:	5d                   	pop    %ebp
  c9:	c3                   	ret    

000000ca <gets>:

char*
gets(char *buf, int max)
{
  ca:	55                   	push   %ebp
  cb:	89 e5                	mov    %esp,%ebp
  cd:	57                   	push   %edi
  ce:	56                   	push   %esi
  cf:	53                   	push   %ebx
  d0:	83 ec 1c             	sub    $0x1c,%esp
  d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  db:	8d 73 01             	lea    0x1(%ebx),%esi
  de:	3b 75 0c             	cmp    0xc(%ebp),%esi
  e1:	7d 2e                	jge    111 <gets+0x47>
    cc = read(0, &c, 1);
  e3:	83 ec 04             	sub    $0x4,%esp
  e6:	6a 01                	push   $0x1
  e8:	8d 45 e7             	lea    -0x19(%ebp),%eax
  eb:	50                   	push   %eax
  ec:	6a 00                	push   $0x0
  ee:	e8 e6 00 00 00       	call   1d9 <read>
    if(cc < 1)
  f3:	83 c4 10             	add    $0x10,%esp
  f6:	85 c0                	test   %eax,%eax
  f8:	7e 17                	jle    111 <gets+0x47>
      break;
    buf[i++] = c;
  fa:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  fe:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 101:	3c 0a                	cmp    $0xa,%al
 103:	0f 94 c2             	sete   %dl
 106:	3c 0d                	cmp    $0xd,%al
 108:	0f 94 c0             	sete   %al
    buf[i++] = c;
 10b:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 10d:	08 c2                	or     %al,%dl
 10f:	74 ca                	je     db <gets+0x11>
      break;
  }
  buf[i] = '\0';
 111:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 115:	89 f8                	mov    %edi,%eax
 117:	8d 65 f4             	lea    -0xc(%ebp),%esp
 11a:	5b                   	pop    %ebx
 11b:	5e                   	pop    %esi
 11c:	5f                   	pop    %edi
 11d:	5d                   	pop    %ebp
 11e:	c3                   	ret    

0000011f <stat>:

int
stat(const char *n, struct stat *st)
{
 11f:	55                   	push   %ebp
 120:	89 e5                	mov    %esp,%ebp
 122:	56                   	push   %esi
 123:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 124:	83 ec 08             	sub    $0x8,%esp
 127:	6a 00                	push   $0x0
 129:	ff 75 08             	pushl  0x8(%ebp)
 12c:	e8 d0 00 00 00       	call   201 <open>
  if(fd < 0)
 131:	83 c4 10             	add    $0x10,%esp
 134:	85 c0                	test   %eax,%eax
 136:	78 24                	js     15c <stat+0x3d>
 138:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 13a:	83 ec 08             	sub    $0x8,%esp
 13d:	ff 75 0c             	pushl  0xc(%ebp)
 140:	50                   	push   %eax
 141:	e8 d3 00 00 00       	call   219 <fstat>
 146:	89 c6                	mov    %eax,%esi
  close(fd);
 148:	89 1c 24             	mov    %ebx,(%esp)
 14b:	e8 99 00 00 00       	call   1e9 <close>
  return r;
 150:	83 c4 10             	add    $0x10,%esp
}
 153:	89 f0                	mov    %esi,%eax
 155:	8d 65 f8             	lea    -0x8(%ebp),%esp
 158:	5b                   	pop    %ebx
 159:	5e                   	pop    %esi
 15a:	5d                   	pop    %ebp
 15b:	c3                   	ret    
    return -1;
 15c:	be ff ff ff ff       	mov    $0xffffffff,%esi
 161:	eb f0                	jmp    153 <stat+0x34>

00000163 <atoi>:

int
atoi(const char *s)
{
 163:	55                   	push   %ebp
 164:	89 e5                	mov    %esp,%ebp
 166:	53                   	push   %ebx
 167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 16a:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 16f:	eb 10                	jmp    181 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 171:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 174:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 177:	83 c1 01             	add    $0x1,%ecx
 17a:	0f be d2             	movsbl %dl,%edx
 17d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 181:	0f b6 11             	movzbl (%ecx),%edx
 184:	8d 5a d0             	lea    -0x30(%edx),%ebx
 187:	80 fb 09             	cmp    $0x9,%bl
 18a:	76 e5                	jbe    171 <atoi+0xe>
  return n;
}
 18c:	5b                   	pop    %ebx
 18d:	5d                   	pop    %ebp
 18e:	c3                   	ret    

0000018f <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	56                   	push   %esi
 193:	53                   	push   %ebx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 19a:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 19d:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 19f:	eb 0d                	jmp    1ae <memmove+0x1f>
    *dst++ = *src++;
 1a1:	0f b6 13             	movzbl (%ebx),%edx
 1a4:	88 11                	mov    %dl,(%ecx)
 1a6:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1a9:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1ac:	89 f2                	mov    %esi,%edx
 1ae:	8d 72 ff             	lea    -0x1(%edx),%esi
 1b1:	85 d2                	test   %edx,%edx
 1b3:	7f ec                	jg     1a1 <memmove+0x12>
  return vdst;
}
 1b5:	5b                   	pop    %ebx
 1b6:	5e                   	pop    %esi
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    

000001b9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1b9:	b8 01 00 00 00       	mov    $0x1,%eax
 1be:	cd 40                	int    $0x40
 1c0:	c3                   	ret    

000001c1 <exit>:
SYSCALL(exit)
 1c1:	b8 02 00 00 00       	mov    $0x2,%eax
 1c6:	cd 40                	int    $0x40
 1c8:	c3                   	ret    

000001c9 <wait>:
SYSCALL(wait)
 1c9:	b8 03 00 00 00       	mov    $0x3,%eax
 1ce:	cd 40                	int    $0x40
 1d0:	c3                   	ret    

000001d1 <pipe>:
SYSCALL(pipe)
 1d1:	b8 04 00 00 00       	mov    $0x4,%eax
 1d6:	cd 40                	int    $0x40
 1d8:	c3                   	ret    

000001d9 <read>:
SYSCALL(read)
 1d9:	b8 05 00 00 00       	mov    $0x5,%eax
 1de:	cd 40                	int    $0x40
 1e0:	c3                   	ret    

000001e1 <write>:
SYSCALL(write)
 1e1:	b8 10 00 00 00       	mov    $0x10,%eax
 1e6:	cd 40                	int    $0x40
 1e8:	c3                   	ret    

000001e9 <close>:
SYSCALL(close)
 1e9:	b8 15 00 00 00       	mov    $0x15,%eax
 1ee:	cd 40                	int    $0x40
 1f0:	c3                   	ret    

000001f1 <kill>:
SYSCALL(kill)
 1f1:	b8 06 00 00 00       	mov    $0x6,%eax
 1f6:	cd 40                	int    $0x40
 1f8:	c3                   	ret    

000001f9 <exec>:
SYSCALL(exec)
 1f9:	b8 07 00 00 00       	mov    $0x7,%eax
 1fe:	cd 40                	int    $0x40
 200:	c3                   	ret    

00000201 <open>:
SYSCALL(open)
 201:	b8 0f 00 00 00       	mov    $0xf,%eax
 206:	cd 40                	int    $0x40
 208:	c3                   	ret    

00000209 <mknod>:
SYSCALL(mknod)
 209:	b8 11 00 00 00       	mov    $0x11,%eax
 20e:	cd 40                	int    $0x40
 210:	c3                   	ret    

00000211 <unlink>:
SYSCALL(unlink)
 211:	b8 12 00 00 00       	mov    $0x12,%eax
 216:	cd 40                	int    $0x40
 218:	c3                   	ret    

00000219 <fstat>:
SYSCALL(fstat)
 219:	b8 08 00 00 00       	mov    $0x8,%eax
 21e:	cd 40                	int    $0x40
 220:	c3                   	ret    

00000221 <link>:
SYSCALL(link)
 221:	b8 13 00 00 00       	mov    $0x13,%eax
 226:	cd 40                	int    $0x40
 228:	c3                   	ret    

00000229 <mkdir>:
SYSCALL(mkdir)
 229:	b8 14 00 00 00       	mov    $0x14,%eax
 22e:	cd 40                	int    $0x40
 230:	c3                   	ret    

00000231 <chdir>:
SYSCALL(chdir)
 231:	b8 09 00 00 00       	mov    $0x9,%eax
 236:	cd 40                	int    $0x40
 238:	c3                   	ret    

00000239 <dup>:
SYSCALL(dup)
 239:	b8 0a 00 00 00       	mov    $0xa,%eax
 23e:	cd 40                	int    $0x40
 240:	c3                   	ret    

00000241 <getpid>:
SYSCALL(getpid)
 241:	b8 0b 00 00 00       	mov    $0xb,%eax
 246:	cd 40                	int    $0x40
 248:	c3                   	ret    

00000249 <sbrk>:
SYSCALL(sbrk)
 249:	b8 0c 00 00 00       	mov    $0xc,%eax
 24e:	cd 40                	int    $0x40
 250:	c3                   	ret    

00000251 <sleep>:
SYSCALL(sleep)
 251:	b8 0d 00 00 00       	mov    $0xd,%eax
 256:	cd 40                	int    $0x40
 258:	c3                   	ret    

00000259 <uptime>:
SYSCALL(uptime)
 259:	b8 0e 00 00 00       	mov    $0xe,%eax
 25e:	cd 40                	int    $0x40
 260:	c3                   	ret    

00000261 <setpri>:
SYSCALL(setpri)
 261:	b8 16 00 00 00       	mov    $0x16,%eax
 266:	cd 40                	int    $0x40
 268:	c3                   	ret    

00000269 <getpri>:
SYSCALL(getpri)
 269:	b8 17 00 00 00       	mov    $0x17,%eax
 26e:	cd 40                	int    $0x40
 270:	c3                   	ret    

00000271 <getpinfo>:
SYSCALL(getpinfo)
 271:	b8 18 00 00 00       	mov    $0x18,%eax
 276:	cd 40                	int    $0x40
 278:	c3                   	ret    

00000279 <fork2>:
SYSCALL(fork2)
 279:	b8 19 00 00 00       	mov    $0x19,%eax
 27e:	cd 40                	int    $0x40
 280:	c3                   	ret    

00000281 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 281:	55                   	push   %ebp
 282:	89 e5                	mov    %esp,%ebp
 284:	83 ec 1c             	sub    $0x1c,%esp
 287:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 28a:	6a 01                	push   $0x1
 28c:	8d 55 f4             	lea    -0xc(%ebp),%edx
 28f:	52                   	push   %edx
 290:	50                   	push   %eax
 291:	e8 4b ff ff ff       	call   1e1 <write>
}
 296:	83 c4 10             	add    $0x10,%esp
 299:	c9                   	leave  
 29a:	c3                   	ret    

0000029b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 29b:	55                   	push   %ebp
 29c:	89 e5                	mov    %esp,%ebp
 29e:	57                   	push   %edi
 29f:	56                   	push   %esi
 2a0:	53                   	push   %ebx
 2a1:	83 ec 2c             	sub    $0x2c,%esp
 2a4:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2a6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2aa:	0f 95 c3             	setne  %bl
 2ad:	89 d0                	mov    %edx,%eax
 2af:	c1 e8 1f             	shr    $0x1f,%eax
 2b2:	84 c3                	test   %al,%bl
 2b4:	74 10                	je     2c6 <printint+0x2b>
    neg = 1;
    x = -xx;
 2b6:	f7 da                	neg    %edx
    neg = 1;
 2b8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2bf:	be 00 00 00 00       	mov    $0x0,%esi
 2c4:	eb 0b                	jmp    2d1 <printint+0x36>
  neg = 0;
 2c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2cd:	eb f0                	jmp    2bf <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2cf:	89 c6                	mov    %eax,%esi
 2d1:	89 d0                	mov    %edx,%eax
 2d3:	ba 00 00 00 00       	mov    $0x0,%edx
 2d8:	f7 f1                	div    %ecx
 2da:	89 c3                	mov    %eax,%ebx
 2dc:	8d 46 01             	lea    0x1(%esi),%eax
 2df:	0f b6 92 e8 05 00 00 	movzbl 0x5e8(%edx),%edx
 2e6:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2ea:	89 da                	mov    %ebx,%edx
 2ec:	85 db                	test   %ebx,%ebx
 2ee:	75 df                	jne    2cf <printint+0x34>
 2f0:	89 c3                	mov    %eax,%ebx
  if(neg)
 2f2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2f6:	74 16                	je     30e <printint+0x73>
    buf[i++] = '-';
 2f8:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2fd:	8d 5e 02             	lea    0x2(%esi),%ebx
 300:	eb 0c                	jmp    30e <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 302:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 307:	89 f8                	mov    %edi,%eax
 309:	e8 73 ff ff ff       	call   281 <putc>
  while(--i >= 0)
 30e:	83 eb 01             	sub    $0x1,%ebx
 311:	79 ef                	jns    302 <printint+0x67>
}
 313:	83 c4 2c             	add    $0x2c,%esp
 316:	5b                   	pop    %ebx
 317:	5e                   	pop    %esi
 318:	5f                   	pop    %edi
 319:	5d                   	pop    %ebp
 31a:	c3                   	ret    

0000031b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	57                   	push   %edi
 31f:	56                   	push   %esi
 320:	53                   	push   %ebx
 321:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 324:	8d 45 10             	lea    0x10(%ebp),%eax
 327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 32a:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 32f:	bb 00 00 00 00       	mov    $0x0,%ebx
 334:	eb 14                	jmp    34a <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 336:	89 fa                	mov    %edi,%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	e8 41 ff ff ff       	call   281 <putc>
 340:	eb 05                	jmp    347 <printf+0x2c>
      }
    } else if(state == '%'){
 342:	83 fe 25             	cmp    $0x25,%esi
 345:	74 25                	je     36c <printf+0x51>
  for(i = 0; fmt[i]; i++){
 347:	83 c3 01             	add    $0x1,%ebx
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 351:	84 c0                	test   %al,%al
 353:	0f 84 23 01 00 00    	je     47c <printf+0x161>
    c = fmt[i] & 0xff;
 359:	0f be f8             	movsbl %al,%edi
 35c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 35f:	85 f6                	test   %esi,%esi
 361:	75 df                	jne    342 <printf+0x27>
      if(c == '%'){
 363:	83 f8 25             	cmp    $0x25,%eax
 366:	75 ce                	jne    336 <printf+0x1b>
        state = '%';
 368:	89 c6                	mov    %eax,%esi
 36a:	eb db                	jmp    347 <printf+0x2c>
      if(c == 'd'){
 36c:	83 f8 64             	cmp    $0x64,%eax
 36f:	74 49                	je     3ba <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 371:	83 f8 78             	cmp    $0x78,%eax
 374:	0f 94 c1             	sete   %cl
 377:	83 f8 70             	cmp    $0x70,%eax
 37a:	0f 94 c2             	sete   %dl
 37d:	08 d1                	or     %dl,%cl
 37f:	75 63                	jne    3e4 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 381:	83 f8 73             	cmp    $0x73,%eax
 384:	0f 84 84 00 00 00    	je     40e <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 38a:	83 f8 63             	cmp    $0x63,%eax
 38d:	0f 84 b7 00 00 00    	je     44a <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 393:	83 f8 25             	cmp    $0x25,%eax
 396:	0f 84 cc 00 00 00    	je     468 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 39c:	ba 25 00 00 00       	mov    $0x25,%edx
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	e8 d8 fe ff ff       	call   281 <putc>
        putc(fd, c);
 3a9:	89 fa                	mov    %edi,%edx
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	e8 ce fe ff ff       	call   281 <putc>
      }
      state = 0;
 3b3:	be 00 00 00 00       	mov    $0x0,%esi
 3b8:	eb 8d                	jmp    347 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3bd:	8b 17                	mov    (%edi),%edx
 3bf:	83 ec 0c             	sub    $0xc,%esp
 3c2:	6a 01                	push   $0x1
 3c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	e8 ca fe ff ff       	call   29b <printint>
        ap++;
 3d1:	83 c7 04             	add    $0x4,%edi
 3d4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3da:	be 00 00 00 00       	mov    $0x0,%esi
 3df:	e9 63 ff ff ff       	jmp    347 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e7:	8b 17                	mov    (%edi),%edx
 3e9:	83 ec 0c             	sub    $0xc,%esp
 3ec:	6a 00                	push   $0x0
 3ee:	b9 10 00 00 00       	mov    $0x10,%ecx
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	e8 a0 fe ff ff       	call   29b <printint>
        ap++;
 3fb:	83 c7 04             	add    $0x4,%edi
 3fe:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 401:	83 c4 10             	add    $0x10,%esp
      state = 0;
 404:	be 00 00 00 00       	mov    $0x0,%esi
 409:	e9 39 ff ff ff       	jmp    347 <printf+0x2c>
        s = (char*)*ap;
 40e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 411:	8b 30                	mov    (%eax),%esi
        ap++;
 413:	83 c0 04             	add    $0x4,%eax
 416:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 419:	85 f6                	test   %esi,%esi
 41b:	75 28                	jne    445 <printf+0x12a>
          s = "(null)";
 41d:	be e1 05 00 00       	mov    $0x5e1,%esi
 422:	8b 7d 08             	mov    0x8(%ebp),%edi
 425:	eb 0d                	jmp    434 <printf+0x119>
          putc(fd, *s);
 427:	0f be d2             	movsbl %dl,%edx
 42a:	89 f8                	mov    %edi,%eax
 42c:	e8 50 fe ff ff       	call   281 <putc>
          s++;
 431:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 434:	0f b6 16             	movzbl (%esi),%edx
 437:	84 d2                	test   %dl,%dl
 439:	75 ec                	jne    427 <printf+0x10c>
      state = 0;
 43b:	be 00 00 00 00       	mov    $0x0,%esi
 440:	e9 02 ff ff ff       	jmp    347 <printf+0x2c>
 445:	8b 7d 08             	mov    0x8(%ebp),%edi
 448:	eb ea                	jmp    434 <printf+0x119>
        putc(fd, *ap);
 44a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44d:	0f be 17             	movsbl (%edi),%edx
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	e8 29 fe ff ff       	call   281 <putc>
        ap++;
 458:	83 c7 04             	add    $0x4,%edi
 45b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 45e:	be 00 00 00 00       	mov    $0x0,%esi
 463:	e9 df fe ff ff       	jmp    347 <printf+0x2c>
        putc(fd, c);
 468:	89 fa                	mov    %edi,%edx
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	e8 0f fe ff ff       	call   281 <putc>
      state = 0;
 472:	be 00 00 00 00       	mov    $0x0,%esi
 477:	e9 cb fe ff ff       	jmp    347 <printf+0x2c>
    }
  }
}
 47c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 47f:	5b                   	pop    %ebx
 480:	5e                   	pop    %esi
 481:	5f                   	pop    %edi
 482:	5d                   	pop    %ebp
 483:	c3                   	ret    

00000484 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
 487:	57                   	push   %edi
 488:	56                   	push   %esi
 489:	53                   	push   %ebx
 48a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 48d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 490:	a1 88 08 00 00       	mov    0x888,%eax
 495:	eb 02                	jmp    499 <free+0x15>
 497:	89 d0                	mov    %edx,%eax
 499:	39 c8                	cmp    %ecx,%eax
 49b:	73 04                	jae    4a1 <free+0x1d>
 49d:	39 08                	cmp    %ecx,(%eax)
 49f:	77 12                	ja     4b3 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4a1:	8b 10                	mov    (%eax),%edx
 4a3:	39 c2                	cmp    %eax,%edx
 4a5:	77 f0                	ja     497 <free+0x13>
 4a7:	39 c8                	cmp    %ecx,%eax
 4a9:	72 08                	jb     4b3 <free+0x2f>
 4ab:	39 ca                	cmp    %ecx,%edx
 4ad:	77 04                	ja     4b3 <free+0x2f>
 4af:	89 d0                	mov    %edx,%eax
 4b1:	eb e6                	jmp    499 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4b3:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b6:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b9:	8b 10                	mov    (%eax),%edx
 4bb:	39 d7                	cmp    %edx,%edi
 4bd:	74 19                	je     4d8 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4bf:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4c2:	8b 50 04             	mov    0x4(%eax),%edx
 4c5:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c8:	39 ce                	cmp    %ecx,%esi
 4ca:	74 1b                	je     4e7 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4cc:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4ce:	a3 88 08 00 00       	mov    %eax,0x888
}
 4d3:	5b                   	pop    %ebx
 4d4:	5e                   	pop    %esi
 4d5:	5f                   	pop    %edi
 4d6:	5d                   	pop    %ebp
 4d7:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4d8:	03 72 04             	add    0x4(%edx),%esi
 4db:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4de:	8b 10                	mov    (%eax),%edx
 4e0:	8b 12                	mov    (%edx),%edx
 4e2:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4e5:	eb db                	jmp    4c2 <free+0x3e>
    p->s.size += bp->s.size;
 4e7:	03 53 fc             	add    -0x4(%ebx),%edx
 4ea:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4ed:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4f0:	89 10                	mov    %edx,(%eax)
 4f2:	eb da                	jmp    4ce <free+0x4a>

000004f4 <morecore>:

static Header*
morecore(uint nu)
{
 4f4:	55                   	push   %ebp
 4f5:	89 e5                	mov    %esp,%ebp
 4f7:	53                   	push   %ebx
 4f8:	83 ec 04             	sub    $0x4,%esp
 4fb:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4fd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 502:	77 05                	ja     509 <morecore+0x15>
    nu = 4096;
 504:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 509:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 510:	83 ec 0c             	sub    $0xc,%esp
 513:	50                   	push   %eax
 514:	e8 30 fd ff ff       	call   249 <sbrk>
  if(p == (char*)-1)
 519:	83 c4 10             	add    $0x10,%esp
 51c:	83 f8 ff             	cmp    $0xffffffff,%eax
 51f:	74 1c                	je     53d <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 521:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 524:	83 c0 08             	add    $0x8,%eax
 527:	83 ec 0c             	sub    $0xc,%esp
 52a:	50                   	push   %eax
 52b:	e8 54 ff ff ff       	call   484 <free>
  return freep;
 530:	a1 88 08 00 00       	mov    0x888,%eax
 535:	83 c4 10             	add    $0x10,%esp
}
 538:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 53b:	c9                   	leave  
 53c:	c3                   	ret    
    return 0;
 53d:	b8 00 00 00 00       	mov    $0x0,%eax
 542:	eb f4                	jmp    538 <morecore+0x44>

00000544 <malloc>:

void*
malloc(uint nbytes)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	53                   	push   %ebx
 548:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	8d 58 07             	lea    0x7(%eax),%ebx
 551:	c1 eb 03             	shr    $0x3,%ebx
 554:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 557:	8b 0d 88 08 00 00    	mov    0x888,%ecx
 55d:	85 c9                	test   %ecx,%ecx
 55f:	74 04                	je     565 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 561:	8b 01                	mov    (%ecx),%eax
 563:	eb 4d                	jmp    5b2 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 565:	c7 05 88 08 00 00 8c 	movl   $0x88c,0x888
 56c:	08 00 00 
 56f:	c7 05 8c 08 00 00 8c 	movl   $0x88c,0x88c
 576:	08 00 00 
    base.s.size = 0;
 579:	c7 05 90 08 00 00 00 	movl   $0x0,0x890
 580:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 583:	b9 8c 08 00 00       	mov    $0x88c,%ecx
 588:	eb d7                	jmp    561 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 58a:	39 da                	cmp    %ebx,%edx
 58c:	74 1a                	je     5a8 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 58e:	29 da                	sub    %ebx,%edx
 590:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 593:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 596:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 599:	89 0d 88 08 00 00    	mov    %ecx,0x888
      return (void*)(p + 1);
 59f:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5a2:	83 c4 04             	add    $0x4,%esp
 5a5:	5b                   	pop    %ebx
 5a6:	5d                   	pop    %ebp
 5a7:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5a8:	8b 10                	mov    (%eax),%edx
 5aa:	89 11                	mov    %edx,(%ecx)
 5ac:	eb eb                	jmp    599 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ae:	89 c1                	mov    %eax,%ecx
 5b0:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5b2:	8b 50 04             	mov    0x4(%eax),%edx
 5b5:	39 da                	cmp    %ebx,%edx
 5b7:	73 d1                	jae    58a <malloc+0x46>
    if(p == freep)
 5b9:	39 05 88 08 00 00    	cmp    %eax,0x888
 5bf:	75 ed                	jne    5ae <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5c1:	89 d8                	mov    %ebx,%eax
 5c3:	e8 2c ff ff ff       	call   4f4 <morecore>
 5c8:	85 c0                	test   %eax,%eax
 5ca:	75 e2                	jne    5ae <malloc+0x6a>
        return 0;
 5cc:	b8 00 00 00 00       	mov    $0x0,%eax
 5d1:	eb cf                	jmp    5a2 <malloc+0x5e>
