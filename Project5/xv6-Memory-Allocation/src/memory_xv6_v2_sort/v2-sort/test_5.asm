
_test_5:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 10             	sub    $0x10,%esp
    int numframes = -1;
    int* frames = 0;
    int* pids = malloc(numframes * sizeof(int));
  11:	6a fc                	push   $0xfffffffc
  13:	e8 2a 05 00 00       	call   542 <malloc>
    
    int flag = dump_physmem(frames, pids, numframes);
  18:	83 c4 0c             	add    $0xc,%esp
  1b:	6a ff                	push   $0xffffffff
  1d:	50                   	push   %eax
  1e:	6a 00                	push   $0x0
  20:	e8 52 02 00 00       	call   277 <dump_physmem>
    
    if(flag == 0)
  25:	83 c4 10             	add    $0x10,%esp
  28:	85 c0                	test   %eax,%eax
  2a:	75 0a                	jne    36 <main+0x36>
    }
    else// if(flag == -1)
    {
        printf(0,"error\n");
    }
    wait();
  2c:	e8 ae 01 00 00       	call   1df <wait>
    exit();
  31:	e8 a1 01 00 00       	call   1d7 <exit>
        printf(0,"error\n");
  36:	83 ec 08             	sub    $0x8,%esp
  39:	68 d4 05 00 00       	push   $0x5d4
  3e:	6a 00                	push   $0x0
  40:	e8 d4 02 00 00       	call   319 <printf>
  45:	83 c4 10             	add    $0x10,%esp
  48:	eb e2                	jmp    2c <main+0x2c>

0000004a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  4a:	55                   	push   %ebp
  4b:	89 e5                	mov    %esp,%ebp
  4d:	53                   	push   %ebx
  4e:	8b 45 08             	mov    0x8(%ebp),%eax
  51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  54:	89 c2                	mov    %eax,%edx
  56:	0f b6 19             	movzbl (%ecx),%ebx
  59:	88 1a                	mov    %bl,(%edx)
  5b:	8d 52 01             	lea    0x1(%edx),%edx
  5e:	8d 49 01             	lea    0x1(%ecx),%ecx
  61:	84 db                	test   %bl,%bl
  63:	75 f1                	jne    56 <strcpy+0xc>
    ;
  return os;
}
  65:	5b                   	pop    %ebx
  66:	5d                   	pop    %ebp
  67:	c3                   	ret    

00000068 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  71:	eb 06                	jmp    79 <strcmp+0x11>
    p++, q++;
  73:	83 c1 01             	add    $0x1,%ecx
  76:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  79:	0f b6 01             	movzbl (%ecx),%eax
  7c:	84 c0                	test   %al,%al
  7e:	74 04                	je     84 <strcmp+0x1c>
  80:	3a 02                	cmp    (%edx),%al
  82:	74 ef                	je     73 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  84:	0f b6 c0             	movzbl %al,%eax
  87:	0f b6 12             	movzbl (%edx),%edx
  8a:	29 d0                	sub    %edx,%eax
}
  8c:	5d                   	pop    %ebp
  8d:	c3                   	ret    

0000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	55                   	push   %ebp
  8f:	89 e5                	mov    %esp,%ebp
  91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  94:	ba 00 00 00 00       	mov    $0x0,%edx
  99:	eb 03                	jmp    9e <strlen+0x10>
  9b:	83 c2 01             	add    $0x1,%edx
  9e:	89 d0                	mov    %edx,%eax
  a0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  a4:	75 f5                	jne    9b <strlen+0xd>
    ;
  return n;
}
  a6:	5d                   	pop    %ebp
  a7:	c3                   	ret    

000000a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	57                   	push   %edi
  ac:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  af:	89 d7                	mov    %edx,%edi
  b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  b7:	fc                   	cld    
  b8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  ba:	89 d0                	mov    %edx,%eax
  bc:	5f                   	pop    %edi
  bd:	5d                   	pop    %ebp
  be:	c3                   	ret    

000000bf <strchr>:

char*
strchr(const char *s, char c)
{
  bf:	55                   	push   %ebp
  c0:	89 e5                	mov    %esp,%ebp
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  c9:	0f b6 10             	movzbl (%eax),%edx
  cc:	84 d2                	test   %dl,%dl
  ce:	74 09                	je     d9 <strchr+0x1a>
    if(*s == c)
  d0:	38 ca                	cmp    %cl,%dl
  d2:	74 0a                	je     de <strchr+0x1f>
  for(; *s; s++)
  d4:	83 c0 01             	add    $0x1,%eax
  d7:	eb f0                	jmp    c9 <strchr+0xa>
      return (char*)s;
  return 0;
  d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  de:	5d                   	pop    %ebp
  df:	c3                   	ret    

000000e0 <gets>:

char*
gets(char *buf, int max)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	57                   	push   %edi
  e4:	56                   	push   %esi
  e5:	53                   	push   %ebx
  e6:	83 ec 1c             	sub    $0x1c,%esp
  e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  f1:	8d 73 01             	lea    0x1(%ebx),%esi
  f4:	3b 75 0c             	cmp    0xc(%ebp),%esi
  f7:	7d 2e                	jge    127 <gets+0x47>
    cc = read(0, &c, 1);
  f9:	83 ec 04             	sub    $0x4,%esp
  fc:	6a 01                	push   $0x1
  fe:	8d 45 e7             	lea    -0x19(%ebp),%eax
 101:	50                   	push   %eax
 102:	6a 00                	push   $0x0
 104:	e8 e6 00 00 00       	call   1ef <read>
    if(cc < 1)
 109:	83 c4 10             	add    $0x10,%esp
 10c:	85 c0                	test   %eax,%eax
 10e:	7e 17                	jle    127 <gets+0x47>
      break;
    buf[i++] = c;
 110:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 114:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 117:	3c 0a                	cmp    $0xa,%al
 119:	0f 94 c2             	sete   %dl
 11c:	3c 0d                	cmp    $0xd,%al
 11e:	0f 94 c0             	sete   %al
    buf[i++] = c;
 121:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 123:	08 c2                	or     %al,%dl
 125:	74 ca                	je     f1 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 127:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 12b:	89 f8                	mov    %edi,%eax
 12d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 130:	5b                   	pop    %ebx
 131:	5e                   	pop    %esi
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <stat>:

int
stat(const char *n, struct stat *st)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	56                   	push   %esi
 139:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 13a:	83 ec 08             	sub    $0x8,%esp
 13d:	6a 00                	push   $0x0
 13f:	ff 75 08             	pushl  0x8(%ebp)
 142:	e8 d0 00 00 00       	call   217 <open>
  if(fd < 0)
 147:	83 c4 10             	add    $0x10,%esp
 14a:	85 c0                	test   %eax,%eax
 14c:	78 24                	js     172 <stat+0x3d>
 14e:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 150:	83 ec 08             	sub    $0x8,%esp
 153:	ff 75 0c             	pushl  0xc(%ebp)
 156:	50                   	push   %eax
 157:	e8 d3 00 00 00       	call   22f <fstat>
 15c:	89 c6                	mov    %eax,%esi
  close(fd);
 15e:	89 1c 24             	mov    %ebx,(%esp)
 161:	e8 99 00 00 00       	call   1ff <close>
  return r;
 166:	83 c4 10             	add    $0x10,%esp
}
 169:	89 f0                	mov    %esi,%eax
 16b:	8d 65 f8             	lea    -0x8(%ebp),%esp
 16e:	5b                   	pop    %ebx
 16f:	5e                   	pop    %esi
 170:	5d                   	pop    %ebp
 171:	c3                   	ret    
    return -1;
 172:	be ff ff ff ff       	mov    $0xffffffff,%esi
 177:	eb f0                	jmp    169 <stat+0x34>

00000179 <atoi>:

int
atoi(const char *s)
{
 179:	55                   	push   %ebp
 17a:	89 e5                	mov    %esp,%ebp
 17c:	53                   	push   %ebx
 17d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 180:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 185:	eb 10                	jmp    197 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 187:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 18a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 18d:	83 c1 01             	add    $0x1,%ecx
 190:	0f be d2             	movsbl %dl,%edx
 193:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 197:	0f b6 11             	movzbl (%ecx),%edx
 19a:	8d 5a d0             	lea    -0x30(%edx),%ebx
 19d:	80 fb 09             	cmp    $0x9,%bl
 1a0:	76 e5                	jbe    187 <atoi+0xe>
  return n;
}
 1a2:	5b                   	pop    %ebx
 1a3:	5d                   	pop    %ebp
 1a4:	c3                   	ret    

000001a5 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1a5:	55                   	push   %ebp
 1a6:	89 e5                	mov    %esp,%ebp
 1a8:	56                   	push   %esi
 1a9:	53                   	push   %ebx
 1aa:	8b 45 08             	mov    0x8(%ebp),%eax
 1ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1b0:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1b3:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1b5:	eb 0d                	jmp    1c4 <memmove+0x1f>
    *dst++ = *src++;
 1b7:	0f b6 13             	movzbl (%ebx),%edx
 1ba:	88 11                	mov    %dl,(%ecx)
 1bc:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1bf:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1c2:	89 f2                	mov    %esi,%edx
 1c4:	8d 72 ff             	lea    -0x1(%edx),%esi
 1c7:	85 d2                	test   %edx,%edx
 1c9:	7f ec                	jg     1b7 <memmove+0x12>
  return vdst;
}
 1cb:	5b                   	pop    %ebx
 1cc:	5e                   	pop    %esi
 1cd:	5d                   	pop    %ebp
 1ce:	c3                   	ret    

000001cf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1cf:	b8 01 00 00 00       	mov    $0x1,%eax
 1d4:	cd 40                	int    $0x40
 1d6:	c3                   	ret    

000001d7 <exit>:
SYSCALL(exit)
 1d7:	b8 02 00 00 00       	mov    $0x2,%eax
 1dc:	cd 40                	int    $0x40
 1de:	c3                   	ret    

000001df <wait>:
SYSCALL(wait)
 1df:	b8 03 00 00 00       	mov    $0x3,%eax
 1e4:	cd 40                	int    $0x40
 1e6:	c3                   	ret    

000001e7 <pipe>:
SYSCALL(pipe)
 1e7:	b8 04 00 00 00       	mov    $0x4,%eax
 1ec:	cd 40                	int    $0x40
 1ee:	c3                   	ret    

000001ef <read>:
SYSCALL(read)
 1ef:	b8 05 00 00 00       	mov    $0x5,%eax
 1f4:	cd 40                	int    $0x40
 1f6:	c3                   	ret    

000001f7 <write>:
SYSCALL(write)
 1f7:	b8 10 00 00 00       	mov    $0x10,%eax
 1fc:	cd 40                	int    $0x40
 1fe:	c3                   	ret    

000001ff <close>:
SYSCALL(close)
 1ff:	b8 15 00 00 00       	mov    $0x15,%eax
 204:	cd 40                	int    $0x40
 206:	c3                   	ret    

00000207 <kill>:
SYSCALL(kill)
 207:	b8 06 00 00 00       	mov    $0x6,%eax
 20c:	cd 40                	int    $0x40
 20e:	c3                   	ret    

0000020f <exec>:
SYSCALL(exec)
 20f:	b8 07 00 00 00       	mov    $0x7,%eax
 214:	cd 40                	int    $0x40
 216:	c3                   	ret    

00000217 <open>:
SYSCALL(open)
 217:	b8 0f 00 00 00       	mov    $0xf,%eax
 21c:	cd 40                	int    $0x40
 21e:	c3                   	ret    

0000021f <mknod>:
SYSCALL(mknod)
 21f:	b8 11 00 00 00       	mov    $0x11,%eax
 224:	cd 40                	int    $0x40
 226:	c3                   	ret    

00000227 <unlink>:
SYSCALL(unlink)
 227:	b8 12 00 00 00       	mov    $0x12,%eax
 22c:	cd 40                	int    $0x40
 22e:	c3                   	ret    

0000022f <fstat>:
SYSCALL(fstat)
 22f:	b8 08 00 00 00       	mov    $0x8,%eax
 234:	cd 40                	int    $0x40
 236:	c3                   	ret    

00000237 <link>:
SYSCALL(link)
 237:	b8 13 00 00 00       	mov    $0x13,%eax
 23c:	cd 40                	int    $0x40
 23e:	c3                   	ret    

0000023f <mkdir>:
SYSCALL(mkdir)
 23f:	b8 14 00 00 00       	mov    $0x14,%eax
 244:	cd 40                	int    $0x40
 246:	c3                   	ret    

00000247 <chdir>:
SYSCALL(chdir)
 247:	b8 09 00 00 00       	mov    $0x9,%eax
 24c:	cd 40                	int    $0x40
 24e:	c3                   	ret    

0000024f <dup>:
SYSCALL(dup)
 24f:	b8 0a 00 00 00       	mov    $0xa,%eax
 254:	cd 40                	int    $0x40
 256:	c3                   	ret    

00000257 <getpid>:
SYSCALL(getpid)
 257:	b8 0b 00 00 00       	mov    $0xb,%eax
 25c:	cd 40                	int    $0x40
 25e:	c3                   	ret    

0000025f <sbrk>:
SYSCALL(sbrk)
 25f:	b8 0c 00 00 00       	mov    $0xc,%eax
 264:	cd 40                	int    $0x40
 266:	c3                   	ret    

00000267 <sleep>:
SYSCALL(sleep)
 267:	b8 0d 00 00 00       	mov    $0xd,%eax
 26c:	cd 40                	int    $0x40
 26e:	c3                   	ret    

0000026f <uptime>:
SYSCALL(uptime)
 26f:	b8 0e 00 00 00       	mov    $0xe,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <dump_physmem>:
SYSCALL(dump_physmem)
 277:	b8 16 00 00 00       	mov    $0x16,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret    

0000027f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	83 ec 1c             	sub    $0x1c,%esp
 285:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 288:	6a 01                	push   $0x1
 28a:	8d 55 f4             	lea    -0xc(%ebp),%edx
 28d:	52                   	push   %edx
 28e:	50                   	push   %eax
 28f:	e8 63 ff ff ff       	call   1f7 <write>
}
 294:	83 c4 10             	add    $0x10,%esp
 297:	c9                   	leave  
 298:	c3                   	ret    

00000299 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	57                   	push   %edi
 29d:	56                   	push   %esi
 29e:	53                   	push   %ebx
 29f:	83 ec 2c             	sub    $0x2c,%esp
 2a2:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2a8:	0f 95 c3             	setne  %bl
 2ab:	89 d0                	mov    %edx,%eax
 2ad:	c1 e8 1f             	shr    $0x1f,%eax
 2b0:	84 c3                	test   %al,%bl
 2b2:	74 10                	je     2c4 <printint+0x2b>
    neg = 1;
    x = -xx;
 2b4:	f7 da                	neg    %edx
    neg = 1;
 2b6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2bd:	be 00 00 00 00       	mov    $0x0,%esi
 2c2:	eb 0b                	jmp    2cf <printint+0x36>
  neg = 0;
 2c4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2cb:	eb f0                	jmp    2bd <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2cd:	89 c6                	mov    %eax,%esi
 2cf:	89 d0                	mov    %edx,%eax
 2d1:	ba 00 00 00 00       	mov    $0x0,%edx
 2d6:	f7 f1                	div    %ecx
 2d8:	89 c3                	mov    %eax,%ebx
 2da:	8d 46 01             	lea    0x1(%esi),%eax
 2dd:	0f b6 92 e4 05 00 00 	movzbl 0x5e4(%edx),%edx
 2e4:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2e8:	89 da                	mov    %ebx,%edx
 2ea:	85 db                	test   %ebx,%ebx
 2ec:	75 df                	jne    2cd <printint+0x34>
 2ee:	89 c3                	mov    %eax,%ebx
  if(neg)
 2f0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2f4:	74 16                	je     30c <printint+0x73>
    buf[i++] = '-';
 2f6:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2fb:	8d 5e 02             	lea    0x2(%esi),%ebx
 2fe:	eb 0c                	jmp    30c <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 300:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 305:	89 f8                	mov    %edi,%eax
 307:	e8 73 ff ff ff       	call   27f <putc>
  while(--i >= 0)
 30c:	83 eb 01             	sub    $0x1,%ebx
 30f:	79 ef                	jns    300 <printint+0x67>
}
 311:	83 c4 2c             	add    $0x2c,%esp
 314:	5b                   	pop    %ebx
 315:	5e                   	pop    %esi
 316:	5f                   	pop    %edi
 317:	5d                   	pop    %ebp
 318:	c3                   	ret    

00000319 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
 31c:	57                   	push   %edi
 31d:	56                   	push   %esi
 31e:	53                   	push   %ebx
 31f:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 322:	8d 45 10             	lea    0x10(%ebp),%eax
 325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 328:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 32d:	bb 00 00 00 00       	mov    $0x0,%ebx
 332:	eb 14                	jmp    348 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 334:	89 fa                	mov    %edi,%edx
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	e8 41 ff ff ff       	call   27f <putc>
 33e:	eb 05                	jmp    345 <printf+0x2c>
      }
    } else if(state == '%'){
 340:	83 fe 25             	cmp    $0x25,%esi
 343:	74 25                	je     36a <printf+0x51>
  for(i = 0; fmt[i]; i++){
 345:	83 c3 01             	add    $0x1,%ebx
 348:	8b 45 0c             	mov    0xc(%ebp),%eax
 34b:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 34f:	84 c0                	test   %al,%al
 351:	0f 84 23 01 00 00    	je     47a <printf+0x161>
    c = fmt[i] & 0xff;
 357:	0f be f8             	movsbl %al,%edi
 35a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 35d:	85 f6                	test   %esi,%esi
 35f:	75 df                	jne    340 <printf+0x27>
      if(c == '%'){
 361:	83 f8 25             	cmp    $0x25,%eax
 364:	75 ce                	jne    334 <printf+0x1b>
        state = '%';
 366:	89 c6                	mov    %eax,%esi
 368:	eb db                	jmp    345 <printf+0x2c>
      if(c == 'd'){
 36a:	83 f8 64             	cmp    $0x64,%eax
 36d:	74 49                	je     3b8 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 36f:	83 f8 78             	cmp    $0x78,%eax
 372:	0f 94 c1             	sete   %cl
 375:	83 f8 70             	cmp    $0x70,%eax
 378:	0f 94 c2             	sete   %dl
 37b:	08 d1                	or     %dl,%cl
 37d:	75 63                	jne    3e2 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 37f:	83 f8 73             	cmp    $0x73,%eax
 382:	0f 84 84 00 00 00    	je     40c <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 388:	83 f8 63             	cmp    $0x63,%eax
 38b:	0f 84 b7 00 00 00    	je     448 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 391:	83 f8 25             	cmp    $0x25,%eax
 394:	0f 84 cc 00 00 00    	je     466 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 39a:	ba 25 00 00 00       	mov    $0x25,%edx
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	e8 d8 fe ff ff       	call   27f <putc>
        putc(fd, c);
 3a7:	89 fa                	mov    %edi,%edx
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	e8 ce fe ff ff       	call   27f <putc>
      }
      state = 0;
 3b1:	be 00 00 00 00       	mov    $0x0,%esi
 3b6:	eb 8d                	jmp    345 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3bb:	8b 17                	mov    (%edi),%edx
 3bd:	83 ec 0c             	sub    $0xc,%esp
 3c0:	6a 01                	push   $0x1
 3c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	e8 ca fe ff ff       	call   299 <printint>
        ap++;
 3cf:	83 c7 04             	add    $0x4,%edi
 3d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d5:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3d8:	be 00 00 00 00       	mov    $0x0,%esi
 3dd:	e9 63 ff ff ff       	jmp    345 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e5:	8b 17                	mov    (%edi),%edx
 3e7:	83 ec 0c             	sub    $0xc,%esp
 3ea:	6a 00                	push   $0x0
 3ec:	b9 10 00 00 00       	mov    $0x10,%ecx
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	e8 a0 fe ff ff       	call   299 <printint>
        ap++;
 3f9:	83 c7 04             	add    $0x4,%edi
 3fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3ff:	83 c4 10             	add    $0x10,%esp
      state = 0;
 402:	be 00 00 00 00       	mov    $0x0,%esi
 407:	e9 39 ff ff ff       	jmp    345 <printf+0x2c>
        s = (char*)*ap;
 40c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 40f:	8b 30                	mov    (%eax),%esi
        ap++;
 411:	83 c0 04             	add    $0x4,%eax
 414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 417:	85 f6                	test   %esi,%esi
 419:	75 28                	jne    443 <printf+0x12a>
          s = "(null)";
 41b:	be db 05 00 00       	mov    $0x5db,%esi
 420:	8b 7d 08             	mov    0x8(%ebp),%edi
 423:	eb 0d                	jmp    432 <printf+0x119>
          putc(fd, *s);
 425:	0f be d2             	movsbl %dl,%edx
 428:	89 f8                	mov    %edi,%eax
 42a:	e8 50 fe ff ff       	call   27f <putc>
          s++;
 42f:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 432:	0f b6 16             	movzbl (%esi),%edx
 435:	84 d2                	test   %dl,%dl
 437:	75 ec                	jne    425 <printf+0x10c>
      state = 0;
 439:	be 00 00 00 00       	mov    $0x0,%esi
 43e:	e9 02 ff ff ff       	jmp    345 <printf+0x2c>
 443:	8b 7d 08             	mov    0x8(%ebp),%edi
 446:	eb ea                	jmp    432 <printf+0x119>
        putc(fd, *ap);
 448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44b:	0f be 17             	movsbl (%edi),%edx
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	e8 29 fe ff ff       	call   27f <putc>
        ap++;
 456:	83 c7 04             	add    $0x4,%edi
 459:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 45c:	be 00 00 00 00       	mov    $0x0,%esi
 461:	e9 df fe ff ff       	jmp    345 <printf+0x2c>
        putc(fd, c);
 466:	89 fa                	mov    %edi,%edx
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	e8 0f fe ff ff       	call   27f <putc>
      state = 0;
 470:	be 00 00 00 00       	mov    $0x0,%esi
 475:	e9 cb fe ff ff       	jmp    345 <printf+0x2c>
    }
  }
}
 47a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 47d:	5b                   	pop    %ebx
 47e:	5e                   	pop    %esi
 47f:	5f                   	pop    %edi
 480:	5d                   	pop    %ebp
 481:	c3                   	ret    

00000482 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 482:	55                   	push   %ebp
 483:	89 e5                	mov    %esp,%ebp
 485:	57                   	push   %edi
 486:	56                   	push   %esi
 487:	53                   	push   %ebx
 488:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 48b:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 48e:	a1 7c 08 00 00       	mov    0x87c,%eax
 493:	eb 02                	jmp    497 <free+0x15>
 495:	89 d0                	mov    %edx,%eax
 497:	39 c8                	cmp    %ecx,%eax
 499:	73 04                	jae    49f <free+0x1d>
 49b:	39 08                	cmp    %ecx,(%eax)
 49d:	77 12                	ja     4b1 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 49f:	8b 10                	mov    (%eax),%edx
 4a1:	39 c2                	cmp    %eax,%edx
 4a3:	77 f0                	ja     495 <free+0x13>
 4a5:	39 c8                	cmp    %ecx,%eax
 4a7:	72 08                	jb     4b1 <free+0x2f>
 4a9:	39 ca                	cmp    %ecx,%edx
 4ab:	77 04                	ja     4b1 <free+0x2f>
 4ad:	89 d0                	mov    %edx,%eax
 4af:	eb e6                	jmp    497 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4b1:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b4:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b7:	8b 10                	mov    (%eax),%edx
 4b9:	39 d7                	cmp    %edx,%edi
 4bb:	74 19                	je     4d6 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4bd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4c0:	8b 50 04             	mov    0x4(%eax),%edx
 4c3:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c6:	39 ce                	cmp    %ecx,%esi
 4c8:	74 1b                	je     4e5 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4ca:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4cc:	a3 7c 08 00 00       	mov    %eax,0x87c
}
 4d1:	5b                   	pop    %ebx
 4d2:	5e                   	pop    %esi
 4d3:	5f                   	pop    %edi
 4d4:	5d                   	pop    %ebp
 4d5:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4d6:	03 72 04             	add    0x4(%edx),%esi
 4d9:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4dc:	8b 10                	mov    (%eax),%edx
 4de:	8b 12                	mov    (%edx),%edx
 4e0:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4e3:	eb db                	jmp    4c0 <free+0x3e>
    p->s.size += bp->s.size;
 4e5:	03 53 fc             	add    -0x4(%ebx),%edx
 4e8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4eb:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4ee:	89 10                	mov    %edx,(%eax)
 4f0:	eb da                	jmp    4cc <free+0x4a>

000004f2 <morecore>:

static Header*
morecore(uint nu)
{
 4f2:	55                   	push   %ebp
 4f3:	89 e5                	mov    %esp,%ebp
 4f5:	53                   	push   %ebx
 4f6:	83 ec 04             	sub    $0x4,%esp
 4f9:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4fb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 500:	77 05                	ja     507 <morecore+0x15>
    nu = 4096;
 502:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 507:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 50e:	83 ec 0c             	sub    $0xc,%esp
 511:	50                   	push   %eax
 512:	e8 48 fd ff ff       	call   25f <sbrk>
  if(p == (char*)-1)
 517:	83 c4 10             	add    $0x10,%esp
 51a:	83 f8 ff             	cmp    $0xffffffff,%eax
 51d:	74 1c                	je     53b <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 51f:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 522:	83 c0 08             	add    $0x8,%eax
 525:	83 ec 0c             	sub    $0xc,%esp
 528:	50                   	push   %eax
 529:	e8 54 ff ff ff       	call   482 <free>
  return freep;
 52e:	a1 7c 08 00 00       	mov    0x87c,%eax
 533:	83 c4 10             	add    $0x10,%esp
}
 536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 539:	c9                   	leave  
 53a:	c3                   	ret    
    return 0;
 53b:	b8 00 00 00 00       	mov    $0x0,%eax
 540:	eb f4                	jmp    536 <morecore+0x44>

00000542 <malloc>:

void*
malloc(uint nbytes)
{
 542:	55                   	push   %ebp
 543:	89 e5                	mov    %esp,%ebp
 545:	53                   	push   %ebx
 546:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 549:	8b 45 08             	mov    0x8(%ebp),%eax
 54c:	8d 58 07             	lea    0x7(%eax),%ebx
 54f:	c1 eb 03             	shr    $0x3,%ebx
 552:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 555:	8b 0d 7c 08 00 00    	mov    0x87c,%ecx
 55b:	85 c9                	test   %ecx,%ecx
 55d:	74 04                	je     563 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55f:	8b 01                	mov    (%ecx),%eax
 561:	eb 4d                	jmp    5b0 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 563:	c7 05 7c 08 00 00 80 	movl   $0x880,0x87c
 56a:	08 00 00 
 56d:	c7 05 80 08 00 00 80 	movl   $0x880,0x880
 574:	08 00 00 
    base.s.size = 0;
 577:	c7 05 84 08 00 00 00 	movl   $0x0,0x884
 57e:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 581:	b9 80 08 00 00       	mov    $0x880,%ecx
 586:	eb d7                	jmp    55f <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 588:	39 da                	cmp    %ebx,%edx
 58a:	74 1a                	je     5a6 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 58c:	29 da                	sub    %ebx,%edx
 58e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 591:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 594:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 597:	89 0d 7c 08 00 00    	mov    %ecx,0x87c
      return (void*)(p + 1);
 59d:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5a0:	83 c4 04             	add    $0x4,%esp
 5a3:	5b                   	pop    %ebx
 5a4:	5d                   	pop    %ebp
 5a5:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5a6:	8b 10                	mov    (%eax),%edx
 5a8:	89 11                	mov    %edx,(%ecx)
 5aa:	eb eb                	jmp    597 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ac:	89 c1                	mov    %eax,%ecx
 5ae:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5b0:	8b 50 04             	mov    0x4(%eax),%edx
 5b3:	39 da                	cmp    %ebx,%edx
 5b5:	73 d1                	jae    588 <malloc+0x46>
    if(p == freep)
 5b7:	39 05 7c 08 00 00    	cmp    %eax,0x87c
 5bd:	75 ed                	jne    5ac <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5bf:	89 d8                	mov    %ebx,%eax
 5c1:	e8 2c ff ff ff       	call   4f2 <morecore>
 5c6:	85 c0                	test   %eax,%eax
 5c8:	75 e2                	jne    5ac <malloc+0x6a>
        return 0;
 5ca:	b8 00 00 00 00       	mov    $0x0,%eax
 5cf:	eb cf                	jmp    5a0 <malloc+0x5e>
