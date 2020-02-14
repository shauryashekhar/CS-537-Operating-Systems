
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
	sleep(10);
  11:	6a 0a                	push   $0xa
  13:	e8 37 02 00 00       	call   24f <sleep>
	int pid = getpid();
  18:	e8 22 02 00 00       	call   23f <getpid>
	printf(1,"loop called, pid %d\n",pid);
  1d:	83 c4 0c             	add    $0xc,%esp
  20:	50                   	push   %eax
  21:	68 d4 05 00 00       	push   $0x5d4
  26:	6a 01                	push   $0x1
  28:	e8 ec 02 00 00       	call   319 <printf>
        exit();
  2d:	e8 8d 01 00 00       	call   1bf <exit>

00000032 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  32:	55                   	push   %ebp
  33:	89 e5                	mov    %esp,%ebp
  35:	53                   	push   %ebx
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3c:	89 c2                	mov    %eax,%edx
  3e:	0f b6 19             	movzbl (%ecx),%ebx
  41:	88 1a                	mov    %bl,(%edx)
  43:	8d 52 01             	lea    0x1(%edx),%edx
  46:	8d 49 01             	lea    0x1(%ecx),%ecx
  49:	84 db                	test   %bl,%bl
  4b:	75 f1                	jne    3e <strcpy+0xc>
    ;
  return os;
}
  4d:	5b                   	pop    %ebx
  4e:	5d                   	pop    %ebp
  4f:	c3                   	ret    

00000050 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  50:	55                   	push   %ebp
  51:	89 e5                	mov    %esp,%ebp
  53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  56:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  59:	eb 06                	jmp    61 <strcmp+0x11>
    p++, q++;
  5b:	83 c1 01             	add    $0x1,%ecx
  5e:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  61:	0f b6 01             	movzbl (%ecx),%eax
  64:	84 c0                	test   %al,%al
  66:	74 04                	je     6c <strcmp+0x1c>
  68:	3a 02                	cmp    (%edx),%al
  6a:	74 ef                	je     5b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  6c:	0f b6 c0             	movzbl %al,%eax
  6f:	0f b6 12             	movzbl (%edx),%edx
  72:	29 d0                	sub    %edx,%eax
}
  74:	5d                   	pop    %ebp
  75:	c3                   	ret    

00000076 <strlen>:

uint
strlen(const char *s)
{
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  7c:	ba 00 00 00 00       	mov    $0x0,%edx
  81:	eb 03                	jmp    86 <strlen+0x10>
  83:	83 c2 01             	add    $0x1,%edx
  86:	89 d0                	mov    %edx,%eax
  88:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8c:	75 f5                	jne    83 <strlen+0xd>
    ;
  return n;
}
  8e:	5d                   	pop    %ebp
  8f:	c3                   	ret    

00000090 <memset>:

void*
memset(void *dst, int c, uint n)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  97:	89 d7                	mov    %edx,%edi
  99:	8b 4d 10             	mov    0x10(%ebp),%ecx
  9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  9f:	fc                   	cld    
  a0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  a2:	89 d0                	mov    %edx,%eax
  a4:	5f                   	pop    %edi
  a5:	5d                   	pop    %ebp
  a6:	c3                   	ret    

000000a7 <strchr>:

char*
strchr(const char *s, char c)
{
  a7:	55                   	push   %ebp
  a8:	89 e5                	mov    %esp,%ebp
  aa:	8b 45 08             	mov    0x8(%ebp),%eax
  ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  b1:	0f b6 10             	movzbl (%eax),%edx
  b4:	84 d2                	test   %dl,%dl
  b6:	74 09                	je     c1 <strchr+0x1a>
    if(*s == c)
  b8:	38 ca                	cmp    %cl,%dl
  ba:	74 0a                	je     c6 <strchr+0x1f>
  for(; *s; s++)
  bc:	83 c0 01             	add    $0x1,%eax
  bf:	eb f0                	jmp    b1 <strchr+0xa>
      return (char*)s;
  return 0;
  c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c6:	5d                   	pop    %ebp
  c7:	c3                   	ret    

000000c8 <gets>:

char*
gets(char *buf, int max)
{
  c8:	55                   	push   %ebp
  c9:	89 e5                	mov    %esp,%ebp
  cb:	57                   	push   %edi
  cc:	56                   	push   %esi
  cd:	53                   	push   %ebx
  ce:	83 ec 1c             	sub    $0x1c,%esp
  d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  d9:	8d 73 01             	lea    0x1(%ebx),%esi
  dc:	3b 75 0c             	cmp    0xc(%ebp),%esi
  df:	7d 2e                	jge    10f <gets+0x47>
    cc = read(0, &c, 1);
  e1:	83 ec 04             	sub    $0x4,%esp
  e4:	6a 01                	push   $0x1
  e6:	8d 45 e7             	lea    -0x19(%ebp),%eax
  e9:	50                   	push   %eax
  ea:	6a 00                	push   $0x0
  ec:	e8 e6 00 00 00       	call   1d7 <read>
    if(cc < 1)
  f1:	83 c4 10             	add    $0x10,%esp
  f4:	85 c0                	test   %eax,%eax
  f6:	7e 17                	jle    10f <gets+0x47>
      break;
    buf[i++] = c;
  f8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  fc:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  ff:	3c 0a                	cmp    $0xa,%al
 101:	0f 94 c2             	sete   %dl
 104:	3c 0d                	cmp    $0xd,%al
 106:	0f 94 c0             	sete   %al
    buf[i++] = c;
 109:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 10b:	08 c2                	or     %al,%dl
 10d:	74 ca                	je     d9 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 10f:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 113:	89 f8                	mov    %edi,%eax
 115:	8d 65 f4             	lea    -0xc(%ebp),%esp
 118:	5b                   	pop    %ebx
 119:	5e                   	pop    %esi
 11a:	5f                   	pop    %edi
 11b:	5d                   	pop    %ebp
 11c:	c3                   	ret    

0000011d <stat>:

int
stat(const char *n, struct stat *st)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	56                   	push   %esi
 121:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 122:	83 ec 08             	sub    $0x8,%esp
 125:	6a 00                	push   $0x0
 127:	ff 75 08             	pushl  0x8(%ebp)
 12a:	e8 d0 00 00 00       	call   1ff <open>
  if(fd < 0)
 12f:	83 c4 10             	add    $0x10,%esp
 132:	85 c0                	test   %eax,%eax
 134:	78 24                	js     15a <stat+0x3d>
 136:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 138:	83 ec 08             	sub    $0x8,%esp
 13b:	ff 75 0c             	pushl  0xc(%ebp)
 13e:	50                   	push   %eax
 13f:	e8 d3 00 00 00       	call   217 <fstat>
 144:	89 c6                	mov    %eax,%esi
  close(fd);
 146:	89 1c 24             	mov    %ebx,(%esp)
 149:	e8 99 00 00 00       	call   1e7 <close>
  return r;
 14e:	83 c4 10             	add    $0x10,%esp
}
 151:	89 f0                	mov    %esi,%eax
 153:	8d 65 f8             	lea    -0x8(%ebp),%esp
 156:	5b                   	pop    %ebx
 157:	5e                   	pop    %esi
 158:	5d                   	pop    %ebp
 159:	c3                   	ret    
    return -1;
 15a:	be ff ff ff ff       	mov    $0xffffffff,%esi
 15f:	eb f0                	jmp    151 <stat+0x34>

00000161 <atoi>:

int
atoi(const char *s)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	53                   	push   %ebx
 165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 168:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 16d:	eb 10                	jmp    17f <atoi+0x1e>
    n = n*10 + *s++ - '0';
 16f:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 172:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 175:	83 c1 01             	add    $0x1,%ecx
 178:	0f be d2             	movsbl %dl,%edx
 17b:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 17f:	0f b6 11             	movzbl (%ecx),%edx
 182:	8d 5a d0             	lea    -0x30(%edx),%ebx
 185:	80 fb 09             	cmp    $0x9,%bl
 188:	76 e5                	jbe    16f <atoi+0xe>
  return n;
}
 18a:	5b                   	pop    %ebx
 18b:	5d                   	pop    %ebp
 18c:	c3                   	ret    

0000018d <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 18d:	55                   	push   %ebp
 18e:	89 e5                	mov    %esp,%ebp
 190:	56                   	push   %esi
 191:	53                   	push   %ebx
 192:	8b 45 08             	mov    0x8(%ebp),%eax
 195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 198:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 19b:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 19d:	eb 0d                	jmp    1ac <memmove+0x1f>
    *dst++ = *src++;
 19f:	0f b6 13             	movzbl (%ebx),%edx
 1a2:	88 11                	mov    %dl,(%ecx)
 1a4:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1a7:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1aa:	89 f2                	mov    %esi,%edx
 1ac:	8d 72 ff             	lea    -0x1(%edx),%esi
 1af:	85 d2                	test   %edx,%edx
 1b1:	7f ec                	jg     19f <memmove+0x12>
  return vdst;
}
 1b3:	5b                   	pop    %ebx
 1b4:	5e                   	pop    %esi
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    

000001b7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1b7:	b8 01 00 00 00       	mov    $0x1,%eax
 1bc:	cd 40                	int    $0x40
 1be:	c3                   	ret    

000001bf <exit>:
SYSCALL(exit)
 1bf:	b8 02 00 00 00       	mov    $0x2,%eax
 1c4:	cd 40                	int    $0x40
 1c6:	c3                   	ret    

000001c7 <wait>:
SYSCALL(wait)
 1c7:	b8 03 00 00 00       	mov    $0x3,%eax
 1cc:	cd 40                	int    $0x40
 1ce:	c3                   	ret    

000001cf <pipe>:
SYSCALL(pipe)
 1cf:	b8 04 00 00 00       	mov    $0x4,%eax
 1d4:	cd 40                	int    $0x40
 1d6:	c3                   	ret    

000001d7 <read>:
SYSCALL(read)
 1d7:	b8 05 00 00 00       	mov    $0x5,%eax
 1dc:	cd 40                	int    $0x40
 1de:	c3                   	ret    

000001df <write>:
SYSCALL(write)
 1df:	b8 10 00 00 00       	mov    $0x10,%eax
 1e4:	cd 40                	int    $0x40
 1e6:	c3                   	ret    

000001e7 <close>:
SYSCALL(close)
 1e7:	b8 15 00 00 00       	mov    $0x15,%eax
 1ec:	cd 40                	int    $0x40
 1ee:	c3                   	ret    

000001ef <kill>:
SYSCALL(kill)
 1ef:	b8 06 00 00 00       	mov    $0x6,%eax
 1f4:	cd 40                	int    $0x40
 1f6:	c3                   	ret    

000001f7 <exec>:
SYSCALL(exec)
 1f7:	b8 07 00 00 00       	mov    $0x7,%eax
 1fc:	cd 40                	int    $0x40
 1fe:	c3                   	ret    

000001ff <open>:
SYSCALL(open)
 1ff:	b8 0f 00 00 00       	mov    $0xf,%eax
 204:	cd 40                	int    $0x40
 206:	c3                   	ret    

00000207 <mknod>:
SYSCALL(mknod)
 207:	b8 11 00 00 00       	mov    $0x11,%eax
 20c:	cd 40                	int    $0x40
 20e:	c3                   	ret    

0000020f <unlink>:
SYSCALL(unlink)
 20f:	b8 12 00 00 00       	mov    $0x12,%eax
 214:	cd 40                	int    $0x40
 216:	c3                   	ret    

00000217 <fstat>:
SYSCALL(fstat)
 217:	b8 08 00 00 00       	mov    $0x8,%eax
 21c:	cd 40                	int    $0x40
 21e:	c3                   	ret    

0000021f <link>:
SYSCALL(link)
 21f:	b8 13 00 00 00       	mov    $0x13,%eax
 224:	cd 40                	int    $0x40
 226:	c3                   	ret    

00000227 <mkdir>:
SYSCALL(mkdir)
 227:	b8 14 00 00 00       	mov    $0x14,%eax
 22c:	cd 40                	int    $0x40
 22e:	c3                   	ret    

0000022f <chdir>:
SYSCALL(chdir)
 22f:	b8 09 00 00 00       	mov    $0x9,%eax
 234:	cd 40                	int    $0x40
 236:	c3                   	ret    

00000237 <dup>:
SYSCALL(dup)
 237:	b8 0a 00 00 00       	mov    $0xa,%eax
 23c:	cd 40                	int    $0x40
 23e:	c3                   	ret    

0000023f <getpid>:
SYSCALL(getpid)
 23f:	b8 0b 00 00 00       	mov    $0xb,%eax
 244:	cd 40                	int    $0x40
 246:	c3                   	ret    

00000247 <sbrk>:
SYSCALL(sbrk)
 247:	b8 0c 00 00 00       	mov    $0xc,%eax
 24c:	cd 40                	int    $0x40
 24e:	c3                   	ret    

0000024f <sleep>:
SYSCALL(sleep)
 24f:	b8 0d 00 00 00       	mov    $0xd,%eax
 254:	cd 40                	int    $0x40
 256:	c3                   	ret    

00000257 <uptime>:
SYSCALL(uptime)
 257:	b8 0e 00 00 00       	mov    $0xe,%eax
 25c:	cd 40                	int    $0x40
 25e:	c3                   	ret    

0000025f <setpri>:
SYSCALL(setpri)
 25f:	b8 16 00 00 00       	mov    $0x16,%eax
 264:	cd 40                	int    $0x40
 266:	c3                   	ret    

00000267 <getpri>:
SYSCALL(getpri)
 267:	b8 17 00 00 00       	mov    $0x17,%eax
 26c:	cd 40                	int    $0x40
 26e:	c3                   	ret    

0000026f <getpinfo>:
SYSCALL(getpinfo)
 26f:	b8 18 00 00 00       	mov    $0x18,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <fork2>:
SYSCALL(fork2)
 277:	b8 19 00 00 00       	mov    $0x19,%eax
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
 28f:	e8 4b ff ff ff       	call   1df <write>
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
 2dd:	0f b6 92 f0 05 00 00 	movzbl 0x5f0(%edx),%edx
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
 41b:	be e9 05 00 00       	mov    $0x5e9,%esi
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
 48e:	a1 88 08 00 00       	mov    0x888,%eax
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
 4cc:	a3 88 08 00 00       	mov    %eax,0x888
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
 512:	e8 30 fd ff ff       	call   247 <sbrk>
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
 52e:	a1 88 08 00 00       	mov    0x888,%eax
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
 555:	8b 0d 88 08 00 00    	mov    0x888,%ecx
 55b:	85 c9                	test   %ecx,%ecx
 55d:	74 04                	je     563 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55f:	8b 01                	mov    (%ecx),%eax
 561:	eb 4d                	jmp    5b0 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 563:	c7 05 88 08 00 00 8c 	movl   $0x88c,0x888
 56a:	08 00 00 
 56d:	c7 05 8c 08 00 00 8c 	movl   $0x88c,0x88c
 574:	08 00 00 
    base.s.size = 0;
 577:	c7 05 90 08 00 00 00 	movl   $0x0,0x890
 57e:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 581:	b9 8c 08 00 00       	mov    $0x88c,%ecx
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
 597:	89 0d 88 08 00 00    	mov    %ecx,0x888
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
 5b7:	39 05 88 08 00 00    	cmp    %eax,0x888
 5bd:	75 ed                	jne    5ac <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5bf:	89 d8                	mov    %ebx,%eax
 5c1:	e8 2c ff ff ff       	call   4f2 <morecore>
 5c6:	85 c0                	test   %eax,%eax
 5c8:	75 e2                	jne    5ac <malloc+0x6a>
        return 0;
 5ca:	b8 00 00 00 00       	mov    $0x0,%eax
 5cf:	eb cf                	jmp    5a0 <malloc+0x5e>
