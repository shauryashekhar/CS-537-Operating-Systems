
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
  19:	e8 64 05 00 00       	call   582 <malloc>
  1e:	89 c7                	mov    %eax,%edi
    int* pids = malloc(numframes * sizeof(int));
  20:	c7 04 24 90 01 00 00 	movl   $0x190,(%esp)
  27:	e8 56 05 00 00       	call   582 <malloc>
  2c:	89 c6                	mov    %eax,%esi
    int flag = dump_physmem(frames, pids, numframes);
  2e:	83 c4 0c             	add    $0xc,%esp
  31:	6a 64                	push   $0x64
  33:	50                   	push   %eax
  34:	57                   	push   %edi
  35:	e8 7d 02 00 00       	call   2b7 <dump_physmem>
  3a:	89 c3                	mov    %eax,%ebx
    
    if(flag == 0)
  3c:	83 c4 10             	add    $0x10,%esp
  3f:	85 c0                	test   %eax,%eax
  41:	74 1f                	je     62 <main+0x62>
          if(*(pids+i) > 0)
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
    }
    else// if(flag == -1)
    {
        printf(0,"error\n");
  43:	83 ec 08             	sub    $0x8,%esp
  46:	68 29 06 00 00       	push   $0x629
  4b:	6a 00                	push   $0x0
  4d:	e8 07 03 00 00       	call   359 <printf>
  52:	83 c4 10             	add    $0x10,%esp
    }
    wait();
  55:	e8 c5 01 00 00       	call   21f <wait>
    exit();
  5a:	e8 b8 01 00 00       	call   217 <exit>
        for (int i = 0; i < numframes; i++)
  5f:	83 c3 01             	add    $0x1,%ebx
  62:	83 fb 63             	cmp    $0x63,%ebx
  65:	7f ee                	jg     55 <main+0x55>
          if(*(pids+i) > 0)
  67:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  6e:	8b 14 06             	mov    (%esi,%eax,1),%edx
  71:	85 d2                	test   %edx,%edx
  73:	7e ea                	jle    5f <main+0x5f>
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  75:	52                   	push   %edx
  76:	ff 34 07             	pushl  (%edi,%eax,1)
  79:	68 14 06 00 00       	push   $0x614
  7e:	6a 00                	push   $0x0
  80:	e8 d4 02 00 00       	call   359 <printf>
  85:	83 c4 10             	add    $0x10,%esp
  88:	eb d5                	jmp    5f <main+0x5f>

0000008a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  8a:	55                   	push   %ebp
  8b:	89 e5                	mov    %esp,%ebp
  8d:	53                   	push   %ebx
  8e:	8b 45 08             	mov    0x8(%ebp),%eax
  91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  94:	89 c2                	mov    %eax,%edx
  96:	0f b6 19             	movzbl (%ecx),%ebx
  99:	88 1a                	mov    %bl,(%edx)
  9b:	8d 52 01             	lea    0x1(%edx),%edx
  9e:	8d 49 01             	lea    0x1(%ecx),%ecx
  a1:	84 db                	test   %bl,%bl
  a3:	75 f1                	jne    96 <strcpy+0xc>
    ;
  return os;
}
  a5:	5b                   	pop    %ebx
  a6:	5d                   	pop    %ebp
  a7:	c3                   	ret    

000000a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  b1:	eb 06                	jmp    b9 <strcmp+0x11>
    p++, q++;
  b3:	83 c1 01             	add    $0x1,%ecx
  b6:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  b9:	0f b6 01             	movzbl (%ecx),%eax
  bc:	84 c0                	test   %al,%al
  be:	74 04                	je     c4 <strcmp+0x1c>
  c0:	3a 02                	cmp    (%edx),%al
  c2:	74 ef                	je     b3 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  c4:	0f b6 c0             	movzbl %al,%eax
  c7:	0f b6 12             	movzbl (%edx),%edx
  ca:	29 d0                	sub    %edx,%eax
}
  cc:	5d                   	pop    %ebp
  cd:	c3                   	ret    

000000ce <strlen>:

uint
strlen(const char *s)
{
  ce:	55                   	push   %ebp
  cf:	89 e5                	mov    %esp,%ebp
  d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  d4:	ba 00 00 00 00       	mov    $0x0,%edx
  d9:	eb 03                	jmp    de <strlen+0x10>
  db:	83 c2 01             	add    $0x1,%edx
  de:	89 d0                	mov    %edx,%eax
  e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  e4:	75 f5                	jne    db <strlen+0xd>
    ;
  return n;
}
  e6:	5d                   	pop    %ebp
  e7:	c3                   	ret    

000000e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e8:	55                   	push   %ebp
  e9:	89 e5                	mov    %esp,%ebp
  eb:	57                   	push   %edi
  ec:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  ef:	89 d7                	mov    %edx,%edi
  f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  f7:	fc                   	cld    
  f8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  fa:	89 d0                	mov    %edx,%eax
  fc:	5f                   	pop    %edi
  fd:	5d                   	pop    %ebp
  fe:	c3                   	ret    

000000ff <strchr>:

char*
strchr(const char *s, char c)
{
  ff:	55                   	push   %ebp
 100:	89 e5                	mov    %esp,%ebp
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 109:	0f b6 10             	movzbl (%eax),%edx
 10c:	84 d2                	test   %dl,%dl
 10e:	74 09                	je     119 <strchr+0x1a>
    if(*s == c)
 110:	38 ca                	cmp    %cl,%dl
 112:	74 0a                	je     11e <strchr+0x1f>
  for(; *s; s++)
 114:	83 c0 01             	add    $0x1,%eax
 117:	eb f0                	jmp    109 <strchr+0xa>
      return (char*)s;
  return 0;
 119:	b8 00 00 00 00       	mov    $0x0,%eax
}
 11e:	5d                   	pop    %ebp
 11f:	c3                   	ret    

00000120 <gets>:

char*
gets(char *buf, int max)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	57                   	push   %edi
 124:	56                   	push   %esi
 125:	53                   	push   %ebx
 126:	83 ec 1c             	sub    $0x1c,%esp
 129:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12c:	bb 00 00 00 00       	mov    $0x0,%ebx
 131:	8d 73 01             	lea    0x1(%ebx),%esi
 134:	3b 75 0c             	cmp    0xc(%ebp),%esi
 137:	7d 2e                	jge    167 <gets+0x47>
    cc = read(0, &c, 1);
 139:	83 ec 04             	sub    $0x4,%esp
 13c:	6a 01                	push   $0x1
 13e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 141:	50                   	push   %eax
 142:	6a 00                	push   $0x0
 144:	e8 e6 00 00 00       	call   22f <read>
    if(cc < 1)
 149:	83 c4 10             	add    $0x10,%esp
 14c:	85 c0                	test   %eax,%eax
 14e:	7e 17                	jle    167 <gets+0x47>
      break;
    buf[i++] = c;
 150:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 154:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 157:	3c 0a                	cmp    $0xa,%al
 159:	0f 94 c2             	sete   %dl
 15c:	3c 0d                	cmp    $0xd,%al
 15e:	0f 94 c0             	sete   %al
    buf[i++] = c;
 161:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 163:	08 c2                	or     %al,%dl
 165:	74 ca                	je     131 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 167:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 16b:	89 f8                	mov    %edi,%eax
 16d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 170:	5b                   	pop    %ebx
 171:	5e                   	pop    %esi
 172:	5f                   	pop    %edi
 173:	5d                   	pop    %ebp
 174:	c3                   	ret    

00000175 <stat>:

int
stat(const char *n, struct stat *st)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	56                   	push   %esi
 179:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17a:	83 ec 08             	sub    $0x8,%esp
 17d:	6a 00                	push   $0x0
 17f:	ff 75 08             	pushl  0x8(%ebp)
 182:	e8 d0 00 00 00       	call   257 <open>
  if(fd < 0)
 187:	83 c4 10             	add    $0x10,%esp
 18a:	85 c0                	test   %eax,%eax
 18c:	78 24                	js     1b2 <stat+0x3d>
 18e:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 190:	83 ec 08             	sub    $0x8,%esp
 193:	ff 75 0c             	pushl  0xc(%ebp)
 196:	50                   	push   %eax
 197:	e8 d3 00 00 00       	call   26f <fstat>
 19c:	89 c6                	mov    %eax,%esi
  close(fd);
 19e:	89 1c 24             	mov    %ebx,(%esp)
 1a1:	e8 99 00 00 00       	call   23f <close>
  return r;
 1a6:	83 c4 10             	add    $0x10,%esp
}
 1a9:	89 f0                	mov    %esi,%eax
 1ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1ae:	5b                   	pop    %ebx
 1af:	5e                   	pop    %esi
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    
    return -1;
 1b2:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b7:	eb f0                	jmp    1a9 <stat+0x34>

000001b9 <atoi>:

int
atoi(const char *s)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	53                   	push   %ebx
 1bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1c0:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1c5:	eb 10                	jmp    1d7 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1c7:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1ca:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1cd:	83 c1 01             	add    $0x1,%ecx
 1d0:	0f be d2             	movsbl %dl,%edx
 1d3:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1d7:	0f b6 11             	movzbl (%ecx),%edx
 1da:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1dd:	80 fb 09             	cmp    $0x9,%bl
 1e0:	76 e5                	jbe    1c7 <atoi+0xe>
  return n;
}
 1e2:	5b                   	pop    %ebx
 1e3:	5d                   	pop    %ebp
 1e4:	c3                   	ret    

000001e5 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e5:	55                   	push   %ebp
 1e6:	89 e5                	mov    %esp,%ebp
 1e8:	56                   	push   %esi
 1e9:	53                   	push   %ebx
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
 1ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1f0:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1f3:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1f5:	eb 0d                	jmp    204 <memmove+0x1f>
    *dst++ = *src++;
 1f7:	0f b6 13             	movzbl (%ebx),%edx
 1fa:	88 11                	mov    %dl,(%ecx)
 1fc:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1ff:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 202:	89 f2                	mov    %esi,%edx
 204:	8d 72 ff             	lea    -0x1(%edx),%esi
 207:	85 d2                	test   %edx,%edx
 209:	7f ec                	jg     1f7 <memmove+0x12>
  return vdst;
}
 20b:	5b                   	pop    %ebx
 20c:	5e                   	pop    %esi
 20d:	5d                   	pop    %ebp
 20e:	c3                   	ret    

0000020f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 20f:	b8 01 00 00 00       	mov    $0x1,%eax
 214:	cd 40                	int    $0x40
 216:	c3                   	ret    

00000217 <exit>:
SYSCALL(exit)
 217:	b8 02 00 00 00       	mov    $0x2,%eax
 21c:	cd 40                	int    $0x40
 21e:	c3                   	ret    

0000021f <wait>:
SYSCALL(wait)
 21f:	b8 03 00 00 00       	mov    $0x3,%eax
 224:	cd 40                	int    $0x40
 226:	c3                   	ret    

00000227 <pipe>:
SYSCALL(pipe)
 227:	b8 04 00 00 00       	mov    $0x4,%eax
 22c:	cd 40                	int    $0x40
 22e:	c3                   	ret    

0000022f <read>:
SYSCALL(read)
 22f:	b8 05 00 00 00       	mov    $0x5,%eax
 234:	cd 40                	int    $0x40
 236:	c3                   	ret    

00000237 <write>:
SYSCALL(write)
 237:	b8 10 00 00 00       	mov    $0x10,%eax
 23c:	cd 40                	int    $0x40
 23e:	c3                   	ret    

0000023f <close>:
SYSCALL(close)
 23f:	b8 15 00 00 00       	mov    $0x15,%eax
 244:	cd 40                	int    $0x40
 246:	c3                   	ret    

00000247 <kill>:
SYSCALL(kill)
 247:	b8 06 00 00 00       	mov    $0x6,%eax
 24c:	cd 40                	int    $0x40
 24e:	c3                   	ret    

0000024f <exec>:
SYSCALL(exec)
 24f:	b8 07 00 00 00       	mov    $0x7,%eax
 254:	cd 40                	int    $0x40
 256:	c3                   	ret    

00000257 <open>:
SYSCALL(open)
 257:	b8 0f 00 00 00       	mov    $0xf,%eax
 25c:	cd 40                	int    $0x40
 25e:	c3                   	ret    

0000025f <mknod>:
SYSCALL(mknod)
 25f:	b8 11 00 00 00       	mov    $0x11,%eax
 264:	cd 40                	int    $0x40
 266:	c3                   	ret    

00000267 <unlink>:
SYSCALL(unlink)
 267:	b8 12 00 00 00       	mov    $0x12,%eax
 26c:	cd 40                	int    $0x40
 26e:	c3                   	ret    

0000026f <fstat>:
SYSCALL(fstat)
 26f:	b8 08 00 00 00       	mov    $0x8,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <link>:
SYSCALL(link)
 277:	b8 13 00 00 00       	mov    $0x13,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret    

0000027f <mkdir>:
SYSCALL(mkdir)
 27f:	b8 14 00 00 00       	mov    $0x14,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <chdir>:
SYSCALL(chdir)
 287:	b8 09 00 00 00       	mov    $0x9,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <dup>:
SYSCALL(dup)
 28f:	b8 0a 00 00 00       	mov    $0xa,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <getpid>:
SYSCALL(getpid)
 297:	b8 0b 00 00 00       	mov    $0xb,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <sbrk>:
SYSCALL(sbrk)
 29f:	b8 0c 00 00 00       	mov    $0xc,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <sleep>:
SYSCALL(sleep)
 2a7:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <uptime>:
SYSCALL(uptime)
 2af:	b8 0e 00 00 00       	mov    $0xe,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <dump_physmem>:
SYSCALL(dump_physmem)
 2b7:	b8 16 00 00 00       	mov    $0x16,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	83 ec 1c             	sub    $0x1c,%esp
 2c5:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c8:	6a 01                	push   $0x1
 2ca:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2cd:	52                   	push   %edx
 2ce:	50                   	push   %eax
 2cf:	e8 63 ff ff ff       	call   237 <write>
}
 2d4:	83 c4 10             	add    $0x10,%esp
 2d7:	c9                   	leave  
 2d8:	c3                   	ret    

000002d9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d9:	55                   	push   %ebp
 2da:	89 e5                	mov    %esp,%ebp
 2dc:	57                   	push   %edi
 2dd:	56                   	push   %esi
 2de:	53                   	push   %ebx
 2df:	83 ec 2c             	sub    $0x2c,%esp
 2e2:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e8:	0f 95 c3             	setne  %bl
 2eb:	89 d0                	mov    %edx,%eax
 2ed:	c1 e8 1f             	shr    $0x1f,%eax
 2f0:	84 c3                	test   %al,%bl
 2f2:	74 10                	je     304 <printint+0x2b>
    neg = 1;
    x = -xx;
 2f4:	f7 da                	neg    %edx
    neg = 1;
 2f6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2fd:	be 00 00 00 00       	mov    $0x0,%esi
 302:	eb 0b                	jmp    30f <printint+0x36>
  neg = 0;
 304:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 30b:	eb f0                	jmp    2fd <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 30d:	89 c6                	mov    %eax,%esi
 30f:	89 d0                	mov    %edx,%eax
 311:	ba 00 00 00 00       	mov    $0x0,%edx
 316:	f7 f1                	div    %ecx
 318:	89 c3                	mov    %eax,%ebx
 31a:	8d 46 01             	lea    0x1(%esi),%eax
 31d:	0f b6 92 38 06 00 00 	movzbl 0x638(%edx),%edx
 324:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 328:	89 da                	mov    %ebx,%edx
 32a:	85 db                	test   %ebx,%ebx
 32c:	75 df                	jne    30d <printint+0x34>
 32e:	89 c3                	mov    %eax,%ebx
  if(neg)
 330:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 334:	74 16                	je     34c <printint+0x73>
    buf[i++] = '-';
 336:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 33b:	8d 5e 02             	lea    0x2(%esi),%ebx
 33e:	eb 0c                	jmp    34c <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 340:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 345:	89 f8                	mov    %edi,%eax
 347:	e8 73 ff ff ff       	call   2bf <putc>
  while(--i >= 0)
 34c:	83 eb 01             	sub    $0x1,%ebx
 34f:	79 ef                	jns    340 <printint+0x67>
}
 351:	83 c4 2c             	add    $0x2c,%esp
 354:	5b                   	pop    %ebx
 355:	5e                   	pop    %esi
 356:	5f                   	pop    %edi
 357:	5d                   	pop    %ebp
 358:	c3                   	ret    

00000359 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
 35c:	57                   	push   %edi
 35d:	56                   	push   %esi
 35e:	53                   	push   %ebx
 35f:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 362:	8d 45 10             	lea    0x10(%ebp),%eax
 365:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 368:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 36d:	bb 00 00 00 00       	mov    $0x0,%ebx
 372:	eb 14                	jmp    388 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 374:	89 fa                	mov    %edi,%edx
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	e8 41 ff ff ff       	call   2bf <putc>
 37e:	eb 05                	jmp    385 <printf+0x2c>
      }
    } else if(state == '%'){
 380:	83 fe 25             	cmp    $0x25,%esi
 383:	74 25                	je     3aa <printf+0x51>
  for(i = 0; fmt[i]; i++){
 385:	83 c3 01             	add    $0x1,%ebx
 388:	8b 45 0c             	mov    0xc(%ebp),%eax
 38b:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 38f:	84 c0                	test   %al,%al
 391:	0f 84 23 01 00 00    	je     4ba <printf+0x161>
    c = fmt[i] & 0xff;
 397:	0f be f8             	movsbl %al,%edi
 39a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 39d:	85 f6                	test   %esi,%esi
 39f:	75 df                	jne    380 <printf+0x27>
      if(c == '%'){
 3a1:	83 f8 25             	cmp    $0x25,%eax
 3a4:	75 ce                	jne    374 <printf+0x1b>
        state = '%';
 3a6:	89 c6                	mov    %eax,%esi
 3a8:	eb db                	jmp    385 <printf+0x2c>
      if(c == 'd'){
 3aa:	83 f8 64             	cmp    $0x64,%eax
 3ad:	74 49                	je     3f8 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3af:	83 f8 78             	cmp    $0x78,%eax
 3b2:	0f 94 c1             	sete   %cl
 3b5:	83 f8 70             	cmp    $0x70,%eax
 3b8:	0f 94 c2             	sete   %dl
 3bb:	08 d1                	or     %dl,%cl
 3bd:	75 63                	jne    422 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3bf:	83 f8 73             	cmp    $0x73,%eax
 3c2:	0f 84 84 00 00 00    	je     44c <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c8:	83 f8 63             	cmp    $0x63,%eax
 3cb:	0f 84 b7 00 00 00    	je     488 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3d1:	83 f8 25             	cmp    $0x25,%eax
 3d4:	0f 84 cc 00 00 00    	je     4a6 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3da:	ba 25 00 00 00       	mov    $0x25,%edx
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	e8 d8 fe ff ff       	call   2bf <putc>
        putc(fd, c);
 3e7:	89 fa                	mov    %edi,%edx
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	e8 ce fe ff ff       	call   2bf <putc>
      }
      state = 0;
 3f1:	be 00 00 00 00       	mov    $0x0,%esi
 3f6:	eb 8d                	jmp    385 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3fb:	8b 17                	mov    (%edi),%edx
 3fd:	83 ec 0c             	sub    $0xc,%esp
 400:	6a 01                	push   $0x1
 402:	b9 0a 00 00 00       	mov    $0xa,%ecx
 407:	8b 45 08             	mov    0x8(%ebp),%eax
 40a:	e8 ca fe ff ff       	call   2d9 <printint>
        ap++;
 40f:	83 c7 04             	add    $0x4,%edi
 412:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 415:	83 c4 10             	add    $0x10,%esp
      state = 0;
 418:	be 00 00 00 00       	mov    $0x0,%esi
 41d:	e9 63 ff ff ff       	jmp    385 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 425:	8b 17                	mov    (%edi),%edx
 427:	83 ec 0c             	sub    $0xc,%esp
 42a:	6a 00                	push   $0x0
 42c:	b9 10 00 00 00       	mov    $0x10,%ecx
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	e8 a0 fe ff ff       	call   2d9 <printint>
        ap++;
 439:	83 c7 04             	add    $0x4,%edi
 43c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 43f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 442:	be 00 00 00 00       	mov    $0x0,%esi
 447:	e9 39 ff ff ff       	jmp    385 <printf+0x2c>
        s = (char*)*ap;
 44c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44f:	8b 30                	mov    (%eax),%esi
        ap++;
 451:	83 c0 04             	add    $0x4,%eax
 454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 457:	85 f6                	test   %esi,%esi
 459:	75 28                	jne    483 <printf+0x12a>
          s = "(null)";
 45b:	be 30 06 00 00       	mov    $0x630,%esi
 460:	8b 7d 08             	mov    0x8(%ebp),%edi
 463:	eb 0d                	jmp    472 <printf+0x119>
          putc(fd, *s);
 465:	0f be d2             	movsbl %dl,%edx
 468:	89 f8                	mov    %edi,%eax
 46a:	e8 50 fe ff ff       	call   2bf <putc>
          s++;
 46f:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 472:	0f b6 16             	movzbl (%esi),%edx
 475:	84 d2                	test   %dl,%dl
 477:	75 ec                	jne    465 <printf+0x10c>
      state = 0;
 479:	be 00 00 00 00       	mov    $0x0,%esi
 47e:	e9 02 ff ff ff       	jmp    385 <printf+0x2c>
 483:	8b 7d 08             	mov    0x8(%ebp),%edi
 486:	eb ea                	jmp    472 <printf+0x119>
        putc(fd, *ap);
 488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 48b:	0f be 17             	movsbl (%edi),%edx
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	e8 29 fe ff ff       	call   2bf <putc>
        ap++;
 496:	83 c7 04             	add    $0x4,%edi
 499:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 49c:	be 00 00 00 00       	mov    $0x0,%esi
 4a1:	e9 df fe ff ff       	jmp    385 <printf+0x2c>
        putc(fd, c);
 4a6:	89 fa                	mov    %edi,%edx
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	e8 0f fe ff ff       	call   2bf <putc>
      state = 0;
 4b0:	be 00 00 00 00       	mov    $0x0,%esi
 4b5:	e9 cb fe ff ff       	jmp    385 <printf+0x2c>
    }
  }
}
 4ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4bd:	5b                   	pop    %ebx
 4be:	5e                   	pop    %esi
 4bf:	5f                   	pop    %edi
 4c0:	5d                   	pop    %ebp
 4c1:	c3                   	ret    

000004c2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4c2:	55                   	push   %ebp
 4c3:	89 e5                	mov    %esp,%ebp
 4c5:	57                   	push   %edi
 4c6:	56                   	push   %esi
 4c7:	53                   	push   %ebx
 4c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4cb:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4ce:	a1 dc 08 00 00       	mov    0x8dc,%eax
 4d3:	eb 02                	jmp    4d7 <free+0x15>
 4d5:	89 d0                	mov    %edx,%eax
 4d7:	39 c8                	cmp    %ecx,%eax
 4d9:	73 04                	jae    4df <free+0x1d>
 4db:	39 08                	cmp    %ecx,(%eax)
 4dd:	77 12                	ja     4f1 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4df:	8b 10                	mov    (%eax),%edx
 4e1:	39 c2                	cmp    %eax,%edx
 4e3:	77 f0                	ja     4d5 <free+0x13>
 4e5:	39 c8                	cmp    %ecx,%eax
 4e7:	72 08                	jb     4f1 <free+0x2f>
 4e9:	39 ca                	cmp    %ecx,%edx
 4eb:	77 04                	ja     4f1 <free+0x2f>
 4ed:	89 d0                	mov    %edx,%eax
 4ef:	eb e6                	jmp    4d7 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4f1:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4f4:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4f7:	8b 10                	mov    (%eax),%edx
 4f9:	39 d7                	cmp    %edx,%edi
 4fb:	74 19                	je     516 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4fd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 500:	8b 50 04             	mov    0x4(%eax),%edx
 503:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 506:	39 ce                	cmp    %ecx,%esi
 508:	74 1b                	je     525 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 50a:	89 08                	mov    %ecx,(%eax)
  freep = p;
 50c:	a3 dc 08 00 00       	mov    %eax,0x8dc
}
 511:	5b                   	pop    %ebx
 512:	5e                   	pop    %esi
 513:	5f                   	pop    %edi
 514:	5d                   	pop    %ebp
 515:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 516:	03 72 04             	add    0x4(%edx),%esi
 519:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 51c:	8b 10                	mov    (%eax),%edx
 51e:	8b 12                	mov    (%edx),%edx
 520:	89 53 f8             	mov    %edx,-0x8(%ebx)
 523:	eb db                	jmp    500 <free+0x3e>
    p->s.size += bp->s.size;
 525:	03 53 fc             	add    -0x4(%ebx),%edx
 528:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 52b:	8b 53 f8             	mov    -0x8(%ebx),%edx
 52e:	89 10                	mov    %edx,(%eax)
 530:	eb da                	jmp    50c <free+0x4a>

00000532 <morecore>:

static Header*
morecore(uint nu)
{
 532:	55                   	push   %ebp
 533:	89 e5                	mov    %esp,%ebp
 535:	53                   	push   %ebx
 536:	83 ec 04             	sub    $0x4,%esp
 539:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 53b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 540:	77 05                	ja     547 <morecore+0x15>
    nu = 4096;
 542:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 547:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 54e:	83 ec 0c             	sub    $0xc,%esp
 551:	50                   	push   %eax
 552:	e8 48 fd ff ff       	call   29f <sbrk>
  if(p == (char*)-1)
 557:	83 c4 10             	add    $0x10,%esp
 55a:	83 f8 ff             	cmp    $0xffffffff,%eax
 55d:	74 1c                	je     57b <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55f:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 562:	83 c0 08             	add    $0x8,%eax
 565:	83 ec 0c             	sub    $0xc,%esp
 568:	50                   	push   %eax
 569:	e8 54 ff ff ff       	call   4c2 <free>
  return freep;
 56e:	a1 dc 08 00 00       	mov    0x8dc,%eax
 573:	83 c4 10             	add    $0x10,%esp
}
 576:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 579:	c9                   	leave  
 57a:	c3                   	ret    
    return 0;
 57b:	b8 00 00 00 00       	mov    $0x0,%eax
 580:	eb f4                	jmp    576 <morecore+0x44>

00000582 <malloc>:

void*
malloc(uint nbytes)
{
 582:	55                   	push   %ebp
 583:	89 e5                	mov    %esp,%ebp
 585:	53                   	push   %ebx
 586:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 589:	8b 45 08             	mov    0x8(%ebp),%eax
 58c:	8d 58 07             	lea    0x7(%eax),%ebx
 58f:	c1 eb 03             	shr    $0x3,%ebx
 592:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 595:	8b 0d dc 08 00 00    	mov    0x8dc,%ecx
 59b:	85 c9                	test   %ecx,%ecx
 59d:	74 04                	je     5a3 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 59f:	8b 01                	mov    (%ecx),%eax
 5a1:	eb 4d                	jmp    5f0 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5a3:	c7 05 dc 08 00 00 e0 	movl   $0x8e0,0x8dc
 5aa:	08 00 00 
 5ad:	c7 05 e0 08 00 00 e0 	movl   $0x8e0,0x8e0
 5b4:	08 00 00 
    base.s.size = 0;
 5b7:	c7 05 e4 08 00 00 00 	movl   $0x0,0x8e4
 5be:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5c1:	b9 e0 08 00 00       	mov    $0x8e0,%ecx
 5c6:	eb d7                	jmp    59f <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c8:	39 da                	cmp    %ebx,%edx
 5ca:	74 1a                	je     5e6 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5cc:	29 da                	sub    %ebx,%edx
 5ce:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5d1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5d4:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5d7:	89 0d dc 08 00 00    	mov    %ecx,0x8dc
      return (void*)(p + 1);
 5dd:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5e0:	83 c4 04             	add    $0x4,%esp
 5e3:	5b                   	pop    %ebx
 5e4:	5d                   	pop    %ebp
 5e5:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5e6:	8b 10                	mov    (%eax),%edx
 5e8:	89 11                	mov    %edx,(%ecx)
 5ea:	eb eb                	jmp    5d7 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ec:	89 c1                	mov    %eax,%ecx
 5ee:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5f0:	8b 50 04             	mov    0x4(%eax),%edx
 5f3:	39 da                	cmp    %ebx,%edx
 5f5:	73 d1                	jae    5c8 <malloc+0x46>
    if(p == freep)
 5f7:	39 05 dc 08 00 00    	cmp    %eax,0x8dc
 5fd:	75 ed                	jne    5ec <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5ff:	89 d8                	mov    %ebx,%eax
 601:	e8 2c ff ff ff       	call   532 <morecore>
 606:	85 c0                	test   %eax,%eax
 608:	75 e2                	jne    5ec <malloc+0x6a>
        return 0;
 60a:	b8 00 00 00 00       	mov    $0x0,%eax
 60f:	eb cf                	jmp    5e0 <malloc+0x5e>
