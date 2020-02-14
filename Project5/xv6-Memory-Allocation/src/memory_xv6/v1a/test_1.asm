
_test_1:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 14             	sub    $0x14,%esp
    int numframes = 100;
    int* frames = malloc(numframes * sizeof(int));
  14:	68 90 01 00 00       	push   $0x190
  19:	e8 5f 05 00 00       	call   57d <malloc>
  1e:	89 c6                	mov    %eax,%esi
    int* pids = malloc(numframes * sizeof(int));
  20:	c7 04 24 90 01 00 00 	movl   $0x190,(%esp)
  27:	e8 51 05 00 00       	call   57d <malloc>
  2c:	89 c7                	mov    %eax,%edi
    int flag = dump_physmem(frames, pids, numframes);
  2e:	83 c4 0c             	add    $0xc,%esp
  31:	6a 64                	push   $0x64
  33:	50                   	push   %eax
  34:	56                   	push   %esi
  35:	e8 78 02 00 00       	call   2b2 <dump_physmem>
  3a:	89 c3                	mov    %eax,%ebx
    
    if(flag == 0)
  3c:	83 c4 10             	add    $0x10,%esp
  3f:	85 c0                	test   %eax,%eax
  41:	74 33                	je     76 <main+0x76>
          
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
    }
    else// if(flag == -1)
    {
        printf(0,"error\n");
  43:	83 ec 08             	sub    $0x8,%esp
  46:	68 21 06 00 00       	push   $0x621
  4b:	6a 00                	push   $0x0
  4d:	e8 02 03 00 00       	call   354 <printf>
  52:	83 c4 10             	add    $0x10,%esp
  55:	eb 24                	jmp    7b <main+0x7b>
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  57:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  5e:	ff 34 07             	pushl  (%edi,%eax,1)
  61:	ff 34 06             	pushl  (%esi,%eax,1)
  64:	68 0c 06 00 00       	push   $0x60c
  69:	6a 00                	push   $0x0
  6b:	e8 e4 02 00 00       	call   354 <printf>
        for (int i = 0; i < numframes; i++)
  70:	83 c3 01             	add    $0x1,%ebx
  73:	83 c4 10             	add    $0x10,%esp
  76:	83 fb 63             	cmp    $0x63,%ebx
  79:	7e dc                	jle    57 <main+0x57>
    }
    wait();
  7b:	e8 9a 01 00 00       	call   21a <wait>
    exit();
  80:	e8 8d 01 00 00       	call   212 <exit>

00000085 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  85:	55                   	push   %ebp
  86:	89 e5                	mov    %esp,%ebp
  88:	53                   	push   %ebx
  89:	8b 45 08             	mov    0x8(%ebp),%eax
  8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8f:	89 c2                	mov    %eax,%edx
  91:	0f b6 19             	movzbl (%ecx),%ebx
  94:	88 1a                	mov    %bl,(%edx)
  96:	8d 52 01             	lea    0x1(%edx),%edx
  99:	8d 49 01             	lea    0x1(%ecx),%ecx
  9c:	84 db                	test   %bl,%bl
  9e:	75 f1                	jne    91 <strcpy+0xc>
    ;
  return os;
}
  a0:	5b                   	pop    %ebx
  a1:	5d                   	pop    %ebp
  a2:	c3                   	ret    

000000a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a3:	55                   	push   %ebp
  a4:	89 e5                	mov    %esp,%ebp
  a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  ac:	eb 06                	jmp    b4 <strcmp+0x11>
    p++, q++;
  ae:	83 c1 01             	add    $0x1,%ecx
  b1:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  b4:	0f b6 01             	movzbl (%ecx),%eax
  b7:	84 c0                	test   %al,%al
  b9:	74 04                	je     bf <strcmp+0x1c>
  bb:	3a 02                	cmp    (%edx),%al
  bd:	74 ef                	je     ae <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  bf:	0f b6 c0             	movzbl %al,%eax
  c2:	0f b6 12             	movzbl (%edx),%edx
  c5:	29 d0                	sub    %edx,%eax
}
  c7:	5d                   	pop    %ebp
  c8:	c3                   	ret    

000000c9 <strlen>:

uint
strlen(const char *s)
{
  c9:	55                   	push   %ebp
  ca:	89 e5                	mov    %esp,%ebp
  cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  cf:	ba 00 00 00 00       	mov    $0x0,%edx
  d4:	eb 03                	jmp    d9 <strlen+0x10>
  d6:	83 c2 01             	add    $0x1,%edx
  d9:	89 d0                	mov    %edx,%eax
  db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  df:	75 f5                	jne    d6 <strlen+0xd>
    ;
  return n;
}
  e1:	5d                   	pop    %ebp
  e2:	c3                   	ret    

000000e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	57                   	push   %edi
  e7:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  ea:	89 d7                	mov    %edx,%edi
  ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  f2:	fc                   	cld    
  f3:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  f5:	89 d0                	mov    %edx,%eax
  f7:	5f                   	pop    %edi
  f8:	5d                   	pop    %ebp
  f9:	c3                   	ret    

000000fa <strchr>:

char*
strchr(const char *s, char c)
{
  fa:	55                   	push   %ebp
  fb:	89 e5                	mov    %esp,%ebp
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 104:	0f b6 10             	movzbl (%eax),%edx
 107:	84 d2                	test   %dl,%dl
 109:	74 09                	je     114 <strchr+0x1a>
    if(*s == c)
 10b:	38 ca                	cmp    %cl,%dl
 10d:	74 0a                	je     119 <strchr+0x1f>
  for(; *s; s++)
 10f:	83 c0 01             	add    $0x1,%eax
 112:	eb f0                	jmp    104 <strchr+0xa>
      return (char*)s;
  return 0;
 114:	b8 00 00 00 00       	mov    $0x0,%eax
}
 119:	5d                   	pop    %ebp
 11a:	c3                   	ret    

0000011b <gets>:

char*
gets(char *buf, int max)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
 11e:	57                   	push   %edi
 11f:	56                   	push   %esi
 120:	53                   	push   %ebx
 121:	83 ec 1c             	sub    $0x1c,%esp
 124:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 127:	bb 00 00 00 00       	mov    $0x0,%ebx
 12c:	8d 73 01             	lea    0x1(%ebx),%esi
 12f:	3b 75 0c             	cmp    0xc(%ebp),%esi
 132:	7d 2e                	jge    162 <gets+0x47>
    cc = read(0, &c, 1);
 134:	83 ec 04             	sub    $0x4,%esp
 137:	6a 01                	push   $0x1
 139:	8d 45 e7             	lea    -0x19(%ebp),%eax
 13c:	50                   	push   %eax
 13d:	6a 00                	push   $0x0
 13f:	e8 e6 00 00 00       	call   22a <read>
    if(cc < 1)
 144:	83 c4 10             	add    $0x10,%esp
 147:	85 c0                	test   %eax,%eax
 149:	7e 17                	jle    162 <gets+0x47>
      break;
    buf[i++] = c;
 14b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 14f:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 152:	3c 0a                	cmp    $0xa,%al
 154:	0f 94 c2             	sete   %dl
 157:	3c 0d                	cmp    $0xd,%al
 159:	0f 94 c0             	sete   %al
    buf[i++] = c;
 15c:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 15e:	08 c2                	or     %al,%dl
 160:	74 ca                	je     12c <gets+0x11>
      break;
  }
  buf[i] = '\0';
 162:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 166:	89 f8                	mov    %edi,%eax
 168:	8d 65 f4             	lea    -0xc(%ebp),%esp
 16b:	5b                   	pop    %ebx
 16c:	5e                   	pop    %esi
 16d:	5f                   	pop    %edi
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret    

00000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	56                   	push   %esi
 174:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 175:	83 ec 08             	sub    $0x8,%esp
 178:	6a 00                	push   $0x0
 17a:	ff 75 08             	pushl  0x8(%ebp)
 17d:	e8 d0 00 00 00       	call   252 <open>
  if(fd < 0)
 182:	83 c4 10             	add    $0x10,%esp
 185:	85 c0                	test   %eax,%eax
 187:	78 24                	js     1ad <stat+0x3d>
 189:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 18b:	83 ec 08             	sub    $0x8,%esp
 18e:	ff 75 0c             	pushl  0xc(%ebp)
 191:	50                   	push   %eax
 192:	e8 d3 00 00 00       	call   26a <fstat>
 197:	89 c6                	mov    %eax,%esi
  close(fd);
 199:	89 1c 24             	mov    %ebx,(%esp)
 19c:	e8 99 00 00 00       	call   23a <close>
  return r;
 1a1:	83 c4 10             	add    $0x10,%esp
}
 1a4:	89 f0                	mov    %esi,%eax
 1a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1a9:	5b                   	pop    %ebx
 1aa:	5e                   	pop    %esi
 1ab:	5d                   	pop    %ebp
 1ac:	c3                   	ret    
    return -1;
 1ad:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b2:	eb f0                	jmp    1a4 <stat+0x34>

000001b4 <atoi>:

int
atoi(const char *s)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	53                   	push   %ebx
 1b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1bb:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1c0:	eb 10                	jmp    1d2 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1c2:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1c5:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1c8:	83 c1 01             	add    $0x1,%ecx
 1cb:	0f be d2             	movsbl %dl,%edx
 1ce:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1d2:	0f b6 11             	movzbl (%ecx),%edx
 1d5:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1d8:	80 fb 09             	cmp    $0x9,%bl
 1db:	76 e5                	jbe    1c2 <atoi+0xe>
  return n;
}
 1dd:	5b                   	pop    %ebx
 1de:	5d                   	pop    %ebp
 1df:	c3                   	ret    

000001e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	56                   	push   %esi
 1e4:	53                   	push   %ebx
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1eb:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1ee:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1f0:	eb 0d                	jmp    1ff <memmove+0x1f>
    *dst++ = *src++;
 1f2:	0f b6 13             	movzbl (%ebx),%edx
 1f5:	88 11                	mov    %dl,(%ecx)
 1f7:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1fa:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1fd:	89 f2                	mov    %esi,%edx
 1ff:	8d 72 ff             	lea    -0x1(%edx),%esi
 202:	85 d2                	test   %edx,%edx
 204:	7f ec                	jg     1f2 <memmove+0x12>
  return vdst;
}
 206:	5b                   	pop    %ebx
 207:	5e                   	pop    %esi
 208:	5d                   	pop    %ebp
 209:	c3                   	ret    

0000020a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 20a:	b8 01 00 00 00       	mov    $0x1,%eax
 20f:	cd 40                	int    $0x40
 211:	c3                   	ret    

00000212 <exit>:
SYSCALL(exit)
 212:	b8 02 00 00 00       	mov    $0x2,%eax
 217:	cd 40                	int    $0x40
 219:	c3                   	ret    

0000021a <wait>:
SYSCALL(wait)
 21a:	b8 03 00 00 00       	mov    $0x3,%eax
 21f:	cd 40                	int    $0x40
 221:	c3                   	ret    

00000222 <pipe>:
SYSCALL(pipe)
 222:	b8 04 00 00 00       	mov    $0x4,%eax
 227:	cd 40                	int    $0x40
 229:	c3                   	ret    

0000022a <read>:
SYSCALL(read)
 22a:	b8 05 00 00 00       	mov    $0x5,%eax
 22f:	cd 40                	int    $0x40
 231:	c3                   	ret    

00000232 <write>:
SYSCALL(write)
 232:	b8 10 00 00 00       	mov    $0x10,%eax
 237:	cd 40                	int    $0x40
 239:	c3                   	ret    

0000023a <close>:
SYSCALL(close)
 23a:	b8 15 00 00 00       	mov    $0x15,%eax
 23f:	cd 40                	int    $0x40
 241:	c3                   	ret    

00000242 <kill>:
SYSCALL(kill)
 242:	b8 06 00 00 00       	mov    $0x6,%eax
 247:	cd 40                	int    $0x40
 249:	c3                   	ret    

0000024a <exec>:
SYSCALL(exec)
 24a:	b8 07 00 00 00       	mov    $0x7,%eax
 24f:	cd 40                	int    $0x40
 251:	c3                   	ret    

00000252 <open>:
SYSCALL(open)
 252:	b8 0f 00 00 00       	mov    $0xf,%eax
 257:	cd 40                	int    $0x40
 259:	c3                   	ret    

0000025a <mknod>:
SYSCALL(mknod)
 25a:	b8 11 00 00 00       	mov    $0x11,%eax
 25f:	cd 40                	int    $0x40
 261:	c3                   	ret    

00000262 <unlink>:
SYSCALL(unlink)
 262:	b8 12 00 00 00       	mov    $0x12,%eax
 267:	cd 40                	int    $0x40
 269:	c3                   	ret    

0000026a <fstat>:
SYSCALL(fstat)
 26a:	b8 08 00 00 00       	mov    $0x8,%eax
 26f:	cd 40                	int    $0x40
 271:	c3                   	ret    

00000272 <link>:
SYSCALL(link)
 272:	b8 13 00 00 00       	mov    $0x13,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <mkdir>:
SYSCALL(mkdir)
 27a:	b8 14 00 00 00       	mov    $0x14,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <chdir>:
SYSCALL(chdir)
 282:	b8 09 00 00 00       	mov    $0x9,%eax
 287:	cd 40                	int    $0x40
 289:	c3                   	ret    

0000028a <dup>:
SYSCALL(dup)
 28a:	b8 0a 00 00 00       	mov    $0xa,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <getpid>:
SYSCALL(getpid)
 292:	b8 0b 00 00 00       	mov    $0xb,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <sbrk>:
SYSCALL(sbrk)
 29a:	b8 0c 00 00 00       	mov    $0xc,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <sleep>:
SYSCALL(sleep)
 2a2:	b8 0d 00 00 00       	mov    $0xd,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <uptime>:
SYSCALL(uptime)
 2aa:	b8 0e 00 00 00       	mov    $0xe,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <dump_physmem>:
SYSCALL(dump_physmem)
 2b2:	b8 16 00 00 00       	mov    $0x16,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2ba:	55                   	push   %ebp
 2bb:	89 e5                	mov    %esp,%ebp
 2bd:	83 ec 1c             	sub    $0x1c,%esp
 2c0:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c3:	6a 01                	push   $0x1
 2c5:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2c8:	52                   	push   %edx
 2c9:	50                   	push   %eax
 2ca:	e8 63 ff ff ff       	call   232 <write>
}
 2cf:	83 c4 10             	add    $0x10,%esp
 2d2:	c9                   	leave  
 2d3:	c3                   	ret    

000002d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
 2d7:	57                   	push   %edi
 2d8:	56                   	push   %esi
 2d9:	53                   	push   %ebx
 2da:	83 ec 2c             	sub    $0x2c,%esp
 2dd:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e3:	0f 95 c3             	setne  %bl
 2e6:	89 d0                	mov    %edx,%eax
 2e8:	c1 e8 1f             	shr    $0x1f,%eax
 2eb:	84 c3                	test   %al,%bl
 2ed:	74 10                	je     2ff <printint+0x2b>
    neg = 1;
    x = -xx;
 2ef:	f7 da                	neg    %edx
    neg = 1;
 2f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2f8:	be 00 00 00 00       	mov    $0x0,%esi
 2fd:	eb 0b                	jmp    30a <printint+0x36>
  neg = 0;
 2ff:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 306:	eb f0                	jmp    2f8 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 308:	89 c6                	mov    %eax,%esi
 30a:	89 d0                	mov    %edx,%eax
 30c:	ba 00 00 00 00       	mov    $0x0,%edx
 311:	f7 f1                	div    %ecx
 313:	89 c3                	mov    %eax,%ebx
 315:	8d 46 01             	lea    0x1(%esi),%eax
 318:	0f b6 92 30 06 00 00 	movzbl 0x630(%edx),%edx
 31f:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 323:	89 da                	mov    %ebx,%edx
 325:	85 db                	test   %ebx,%ebx
 327:	75 df                	jne    308 <printint+0x34>
 329:	89 c3                	mov    %eax,%ebx
  if(neg)
 32b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 32f:	74 16                	je     347 <printint+0x73>
    buf[i++] = '-';
 331:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 336:	8d 5e 02             	lea    0x2(%esi),%ebx
 339:	eb 0c                	jmp    347 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 33b:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 340:	89 f8                	mov    %edi,%eax
 342:	e8 73 ff ff ff       	call   2ba <putc>
  while(--i >= 0)
 347:	83 eb 01             	sub    $0x1,%ebx
 34a:	79 ef                	jns    33b <printint+0x67>
}
 34c:	83 c4 2c             	add    $0x2c,%esp
 34f:	5b                   	pop    %ebx
 350:	5e                   	pop    %esi
 351:	5f                   	pop    %edi
 352:	5d                   	pop    %ebp
 353:	c3                   	ret    

00000354 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	57                   	push   %edi
 358:	56                   	push   %esi
 359:	53                   	push   %ebx
 35a:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 35d:	8d 45 10             	lea    0x10(%ebp),%eax
 360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 363:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 368:	bb 00 00 00 00       	mov    $0x0,%ebx
 36d:	eb 14                	jmp    383 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 36f:	89 fa                	mov    %edi,%edx
 371:	8b 45 08             	mov    0x8(%ebp),%eax
 374:	e8 41 ff ff ff       	call   2ba <putc>
 379:	eb 05                	jmp    380 <printf+0x2c>
      }
    } else if(state == '%'){
 37b:	83 fe 25             	cmp    $0x25,%esi
 37e:	74 25                	je     3a5 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 380:	83 c3 01             	add    $0x1,%ebx
 383:	8b 45 0c             	mov    0xc(%ebp),%eax
 386:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 38a:	84 c0                	test   %al,%al
 38c:	0f 84 23 01 00 00    	je     4b5 <printf+0x161>
    c = fmt[i] & 0xff;
 392:	0f be f8             	movsbl %al,%edi
 395:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 398:	85 f6                	test   %esi,%esi
 39a:	75 df                	jne    37b <printf+0x27>
      if(c == '%'){
 39c:	83 f8 25             	cmp    $0x25,%eax
 39f:	75 ce                	jne    36f <printf+0x1b>
        state = '%';
 3a1:	89 c6                	mov    %eax,%esi
 3a3:	eb db                	jmp    380 <printf+0x2c>
      if(c == 'd'){
 3a5:	83 f8 64             	cmp    $0x64,%eax
 3a8:	74 49                	je     3f3 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3aa:	83 f8 78             	cmp    $0x78,%eax
 3ad:	0f 94 c1             	sete   %cl
 3b0:	83 f8 70             	cmp    $0x70,%eax
 3b3:	0f 94 c2             	sete   %dl
 3b6:	08 d1                	or     %dl,%cl
 3b8:	75 63                	jne    41d <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3ba:	83 f8 73             	cmp    $0x73,%eax
 3bd:	0f 84 84 00 00 00    	je     447 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c3:	83 f8 63             	cmp    $0x63,%eax
 3c6:	0f 84 b7 00 00 00    	je     483 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3cc:	83 f8 25             	cmp    $0x25,%eax
 3cf:	0f 84 cc 00 00 00    	je     4a1 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3d5:	ba 25 00 00 00       	mov    $0x25,%edx
 3da:	8b 45 08             	mov    0x8(%ebp),%eax
 3dd:	e8 d8 fe ff ff       	call   2ba <putc>
        putc(fd, c);
 3e2:	89 fa                	mov    %edi,%edx
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	e8 ce fe ff ff       	call   2ba <putc>
      }
      state = 0;
 3ec:	be 00 00 00 00       	mov    $0x0,%esi
 3f1:	eb 8d                	jmp    380 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f6:	8b 17                	mov    (%edi),%edx
 3f8:	83 ec 0c             	sub    $0xc,%esp
 3fb:	6a 01                	push   $0x1
 3fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
 402:	8b 45 08             	mov    0x8(%ebp),%eax
 405:	e8 ca fe ff ff       	call   2d4 <printint>
        ap++;
 40a:	83 c7 04             	add    $0x4,%edi
 40d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 410:	83 c4 10             	add    $0x10,%esp
      state = 0;
 413:	be 00 00 00 00       	mov    $0x0,%esi
 418:	e9 63 ff ff ff       	jmp    380 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 41d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 420:	8b 17                	mov    (%edi),%edx
 422:	83 ec 0c             	sub    $0xc,%esp
 425:	6a 00                	push   $0x0
 427:	b9 10 00 00 00       	mov    $0x10,%ecx
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	e8 a0 fe ff ff       	call   2d4 <printint>
        ap++;
 434:	83 c7 04             	add    $0x4,%edi
 437:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 43a:	83 c4 10             	add    $0x10,%esp
      state = 0;
 43d:	be 00 00 00 00       	mov    $0x0,%esi
 442:	e9 39 ff ff ff       	jmp    380 <printf+0x2c>
        s = (char*)*ap;
 447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44a:	8b 30                	mov    (%eax),%esi
        ap++;
 44c:	83 c0 04             	add    $0x4,%eax
 44f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 452:	85 f6                	test   %esi,%esi
 454:	75 28                	jne    47e <printf+0x12a>
          s = "(null)";
 456:	be 28 06 00 00       	mov    $0x628,%esi
 45b:	8b 7d 08             	mov    0x8(%ebp),%edi
 45e:	eb 0d                	jmp    46d <printf+0x119>
          putc(fd, *s);
 460:	0f be d2             	movsbl %dl,%edx
 463:	89 f8                	mov    %edi,%eax
 465:	e8 50 fe ff ff       	call   2ba <putc>
          s++;
 46a:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 46d:	0f b6 16             	movzbl (%esi),%edx
 470:	84 d2                	test   %dl,%dl
 472:	75 ec                	jne    460 <printf+0x10c>
      state = 0;
 474:	be 00 00 00 00       	mov    $0x0,%esi
 479:	e9 02 ff ff ff       	jmp    380 <printf+0x2c>
 47e:	8b 7d 08             	mov    0x8(%ebp),%edi
 481:	eb ea                	jmp    46d <printf+0x119>
        putc(fd, *ap);
 483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 486:	0f be 17             	movsbl (%edi),%edx
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	e8 29 fe ff ff       	call   2ba <putc>
        ap++;
 491:	83 c7 04             	add    $0x4,%edi
 494:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 497:	be 00 00 00 00       	mov    $0x0,%esi
 49c:	e9 df fe ff ff       	jmp    380 <printf+0x2c>
        putc(fd, c);
 4a1:	89 fa                	mov    %edi,%edx
 4a3:	8b 45 08             	mov    0x8(%ebp),%eax
 4a6:	e8 0f fe ff ff       	call   2ba <putc>
      state = 0;
 4ab:	be 00 00 00 00       	mov    $0x0,%esi
 4b0:	e9 cb fe ff ff       	jmp    380 <printf+0x2c>
    }
  }
}
 4b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4b8:	5b                   	pop    %ebx
 4b9:	5e                   	pop    %esi
 4ba:	5f                   	pop    %edi
 4bb:	5d                   	pop    %ebp
 4bc:	c3                   	ret    

000004bd <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4bd:	55                   	push   %ebp
 4be:	89 e5                	mov    %esp,%ebp
 4c0:	57                   	push   %edi
 4c1:	56                   	push   %esi
 4c2:	53                   	push   %ebx
 4c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4c6:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4c9:	a1 d4 08 00 00       	mov    0x8d4,%eax
 4ce:	eb 02                	jmp    4d2 <free+0x15>
 4d0:	89 d0                	mov    %edx,%eax
 4d2:	39 c8                	cmp    %ecx,%eax
 4d4:	73 04                	jae    4da <free+0x1d>
 4d6:	39 08                	cmp    %ecx,(%eax)
 4d8:	77 12                	ja     4ec <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4da:	8b 10                	mov    (%eax),%edx
 4dc:	39 c2                	cmp    %eax,%edx
 4de:	77 f0                	ja     4d0 <free+0x13>
 4e0:	39 c8                	cmp    %ecx,%eax
 4e2:	72 08                	jb     4ec <free+0x2f>
 4e4:	39 ca                	cmp    %ecx,%edx
 4e6:	77 04                	ja     4ec <free+0x2f>
 4e8:	89 d0                	mov    %edx,%eax
 4ea:	eb e6                	jmp    4d2 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ec:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4ef:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4f2:	8b 10                	mov    (%eax),%edx
 4f4:	39 d7                	cmp    %edx,%edi
 4f6:	74 19                	je     511 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4f8:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4fb:	8b 50 04             	mov    0x4(%eax),%edx
 4fe:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 501:	39 ce                	cmp    %ecx,%esi
 503:	74 1b                	je     520 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 505:	89 08                	mov    %ecx,(%eax)
  freep = p;
 507:	a3 d4 08 00 00       	mov    %eax,0x8d4
}
 50c:	5b                   	pop    %ebx
 50d:	5e                   	pop    %esi
 50e:	5f                   	pop    %edi
 50f:	5d                   	pop    %ebp
 510:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 511:	03 72 04             	add    0x4(%edx),%esi
 514:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 517:	8b 10                	mov    (%eax),%edx
 519:	8b 12                	mov    (%edx),%edx
 51b:	89 53 f8             	mov    %edx,-0x8(%ebx)
 51e:	eb db                	jmp    4fb <free+0x3e>
    p->s.size += bp->s.size;
 520:	03 53 fc             	add    -0x4(%ebx),%edx
 523:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 526:	8b 53 f8             	mov    -0x8(%ebx),%edx
 529:	89 10                	mov    %edx,(%eax)
 52b:	eb da                	jmp    507 <free+0x4a>

0000052d <morecore>:

static Header*
morecore(uint nu)
{
 52d:	55                   	push   %ebp
 52e:	89 e5                	mov    %esp,%ebp
 530:	53                   	push   %ebx
 531:	83 ec 04             	sub    $0x4,%esp
 534:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 536:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 53b:	77 05                	ja     542 <morecore+0x15>
    nu = 4096;
 53d:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 542:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 549:	83 ec 0c             	sub    $0xc,%esp
 54c:	50                   	push   %eax
 54d:	e8 48 fd ff ff       	call   29a <sbrk>
  if(p == (char*)-1)
 552:	83 c4 10             	add    $0x10,%esp
 555:	83 f8 ff             	cmp    $0xffffffff,%eax
 558:	74 1c                	je     576 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55a:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 55d:	83 c0 08             	add    $0x8,%eax
 560:	83 ec 0c             	sub    $0xc,%esp
 563:	50                   	push   %eax
 564:	e8 54 ff ff ff       	call   4bd <free>
  return freep;
 569:	a1 d4 08 00 00       	mov    0x8d4,%eax
 56e:	83 c4 10             	add    $0x10,%esp
}
 571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 574:	c9                   	leave  
 575:	c3                   	ret    
    return 0;
 576:	b8 00 00 00 00       	mov    $0x0,%eax
 57b:	eb f4                	jmp    571 <morecore+0x44>

0000057d <malloc>:

void*
malloc(uint nbytes)
{
 57d:	55                   	push   %ebp
 57e:	89 e5                	mov    %esp,%ebp
 580:	53                   	push   %ebx
 581:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	8d 58 07             	lea    0x7(%eax),%ebx
 58a:	c1 eb 03             	shr    $0x3,%ebx
 58d:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 590:	8b 0d d4 08 00 00    	mov    0x8d4,%ecx
 596:	85 c9                	test   %ecx,%ecx
 598:	74 04                	je     59e <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 59a:	8b 01                	mov    (%ecx),%eax
 59c:	eb 4d                	jmp    5eb <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 59e:	c7 05 d4 08 00 00 d8 	movl   $0x8d8,0x8d4
 5a5:	08 00 00 
 5a8:	c7 05 d8 08 00 00 d8 	movl   $0x8d8,0x8d8
 5af:	08 00 00 
    base.s.size = 0;
 5b2:	c7 05 dc 08 00 00 00 	movl   $0x0,0x8dc
 5b9:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5bc:	b9 d8 08 00 00       	mov    $0x8d8,%ecx
 5c1:	eb d7                	jmp    59a <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c3:	39 da                	cmp    %ebx,%edx
 5c5:	74 1a                	je     5e1 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5c7:	29 da                	sub    %ebx,%edx
 5c9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5cc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5cf:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5d2:	89 0d d4 08 00 00    	mov    %ecx,0x8d4
      return (void*)(p + 1);
 5d8:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5db:	83 c4 04             	add    $0x4,%esp
 5de:	5b                   	pop    %ebx
 5df:	5d                   	pop    %ebp
 5e0:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5e1:	8b 10                	mov    (%eax),%edx
 5e3:	89 11                	mov    %edx,(%ecx)
 5e5:	eb eb                	jmp    5d2 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5e7:	89 c1                	mov    %eax,%ecx
 5e9:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5eb:	8b 50 04             	mov    0x4(%eax),%edx
 5ee:	39 da                	cmp    %ebx,%edx
 5f0:	73 d1                	jae    5c3 <malloc+0x46>
    if(p == freep)
 5f2:	39 05 d4 08 00 00    	cmp    %eax,0x8d4
 5f8:	75 ed                	jne    5e7 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5fa:	89 d8                	mov    %ebx,%eax
 5fc:	e8 2c ff ff ff       	call   52d <morecore>
 601:	85 c0                	test   %eax,%eax
 603:	75 e2                	jne    5e7 <malloc+0x6a>
        return 0;
 605:	b8 00 00 00 00       	mov    $0x0,%eax
 60a:	eb cf                	jmp    5db <malloc+0x5e>
