
_test_4:     file format elf32-i386


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
		printf(1, "pipe() failed\n");
		exit();
	}*/

	int numframes = 10;
	int* frames = malloc(numframes * sizeof(int));
  14:	6a 28                	push   $0x28
  16:	e8 64 05 00 00       	call   57f <malloc>
  1b:	89 c6                	mov    %eax,%esi
	int* pids = malloc(numframes * sizeof(int));
  1d:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
  24:	e8 56 05 00 00       	call   57f <malloc>
  29:	89 c7                	mov    %eax,%edi
	//cid = fork();
	//if(cid == 0)
	//{//Child Process
		fork();
  2b:	e8 dc 01 00 00       	call   20c <fork>
		wait();
  30:	e8 e7 01 00 00       	call   21c <wait>
		int flag = dump_physmem(frames, pids, numframes);
  35:	83 c4 0c             	add    $0xc,%esp
  38:	6a 0a                	push   $0xa
  3a:	57                   	push   %edi
  3b:	56                   	push   %esi
  3c:	e8 73 02 00 00       	call   2b4 <dump_physmem>
  41:	89 c3                	mov    %eax,%ebx

		if(flag == 0)
  43:	83 c4 10             	add    $0x10,%esp
  46:	85 c0                	test   %eax,%eax
  48:	74 33                	je     7d <main+0x7d>
				//if(*(pids+i) > 0)
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
		}
		else// if(flag == -1)
		{
			printf(1,"error\n");
  4a:	83 ec 08             	sub    $0x8,%esp
  4d:	68 25 06 00 00       	push   $0x625
  52:	6a 01                	push   $0x1
  54:	e8 fd 02 00 00       	call   356 <printf>
  59:	83 c4 10             	add    $0x10,%esp
  5c:	eb 24                	jmp    82 <main+0x82>
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  5e:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  65:	ff 34 07             	pushl  (%edi,%eax,1)
  68:	ff 34 06             	pushl  (%esi,%eax,1)
  6b:	68 10 06 00 00       	push   $0x610
  70:	6a 01                	push   $0x1
  72:	e8 df 02 00 00       	call   356 <printf>
			for (int i = 0; i < numframes; i++)
  77:	83 c3 01             	add    $0x1,%ebx
  7a:	83 c4 10             	add    $0x10,%esp
  7d:	83 fb 09             	cmp    $0x9,%ebx
  80:	7e dc                	jle    5e <main+0x5e>
		{
			printf(1,"error\n");
		}
		//write(p1[1], "Y", 1);
	}*/
	exit();
  82:	e8 8d 01 00 00       	call   214 <exit>

00000087 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  87:	55                   	push   %ebp
  88:	89 e5                	mov    %esp,%ebp
  8a:	53                   	push   %ebx
  8b:	8b 45 08             	mov    0x8(%ebp),%eax
  8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  91:	89 c2                	mov    %eax,%edx
  93:	0f b6 19             	movzbl (%ecx),%ebx
  96:	88 1a                	mov    %bl,(%edx)
  98:	8d 52 01             	lea    0x1(%edx),%edx
  9b:	8d 49 01             	lea    0x1(%ecx),%ecx
  9e:	84 db                	test   %bl,%bl
  a0:	75 f1                	jne    93 <strcpy+0xc>
    ;
  return os;
}
  a2:	5b                   	pop    %ebx
  a3:	5d                   	pop    %ebp
  a4:	c3                   	ret    

000000a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a5:	55                   	push   %ebp
  a6:	89 e5                	mov    %esp,%ebp
  a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  ae:	eb 06                	jmp    b6 <strcmp+0x11>
    p++, q++;
  b0:	83 c1 01             	add    $0x1,%ecx
  b3:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  b6:	0f b6 01             	movzbl (%ecx),%eax
  b9:	84 c0                	test   %al,%al
  bb:	74 04                	je     c1 <strcmp+0x1c>
  bd:	3a 02                	cmp    (%edx),%al
  bf:	74 ef                	je     b0 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  c1:	0f b6 c0             	movzbl %al,%eax
  c4:	0f b6 12             	movzbl (%edx),%edx
  c7:	29 d0                	sub    %edx,%eax
}
  c9:	5d                   	pop    %ebp
  ca:	c3                   	ret    

000000cb <strlen>:

uint
strlen(const char *s)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  d1:	ba 00 00 00 00       	mov    $0x0,%edx
  d6:	eb 03                	jmp    db <strlen+0x10>
  d8:	83 c2 01             	add    $0x1,%edx
  db:	89 d0                	mov    %edx,%eax
  dd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  e1:	75 f5                	jne    d8 <strlen+0xd>
    ;
  return n;
}
  e3:	5d                   	pop    %ebp
  e4:	c3                   	ret    

000000e5 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e5:	55                   	push   %ebp
  e6:	89 e5                	mov    %esp,%ebp
  e8:	57                   	push   %edi
  e9:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  ec:	89 d7                	mov    %edx,%edi
  ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  f4:	fc                   	cld    
  f5:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  f7:	89 d0                	mov    %edx,%eax
  f9:	5f                   	pop    %edi
  fa:	5d                   	pop    %ebp
  fb:	c3                   	ret    

000000fc <strchr>:

char*
strchr(const char *s, char c)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 106:	0f b6 10             	movzbl (%eax),%edx
 109:	84 d2                	test   %dl,%dl
 10b:	74 09                	je     116 <strchr+0x1a>
    if(*s == c)
 10d:	38 ca                	cmp    %cl,%dl
 10f:	74 0a                	je     11b <strchr+0x1f>
  for(; *s; s++)
 111:	83 c0 01             	add    $0x1,%eax
 114:	eb f0                	jmp    106 <strchr+0xa>
      return (char*)s;
  return 0;
 116:	b8 00 00 00 00       	mov    $0x0,%eax
}
 11b:	5d                   	pop    %ebp
 11c:	c3                   	ret    

0000011d <gets>:

char*
gets(char *buf, int max)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	57                   	push   %edi
 121:	56                   	push   %esi
 122:	53                   	push   %ebx
 123:	83 ec 1c             	sub    $0x1c,%esp
 126:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 129:	bb 00 00 00 00       	mov    $0x0,%ebx
 12e:	8d 73 01             	lea    0x1(%ebx),%esi
 131:	3b 75 0c             	cmp    0xc(%ebp),%esi
 134:	7d 2e                	jge    164 <gets+0x47>
    cc = read(0, &c, 1);
 136:	83 ec 04             	sub    $0x4,%esp
 139:	6a 01                	push   $0x1
 13b:	8d 45 e7             	lea    -0x19(%ebp),%eax
 13e:	50                   	push   %eax
 13f:	6a 00                	push   $0x0
 141:	e8 e6 00 00 00       	call   22c <read>
    if(cc < 1)
 146:	83 c4 10             	add    $0x10,%esp
 149:	85 c0                	test   %eax,%eax
 14b:	7e 17                	jle    164 <gets+0x47>
      break;
    buf[i++] = c;
 14d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 151:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 154:	3c 0a                	cmp    $0xa,%al
 156:	0f 94 c2             	sete   %dl
 159:	3c 0d                	cmp    $0xd,%al
 15b:	0f 94 c0             	sete   %al
    buf[i++] = c;
 15e:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 160:	08 c2                	or     %al,%dl
 162:	74 ca                	je     12e <gets+0x11>
      break;
  }
  buf[i] = '\0';
 164:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 168:	89 f8                	mov    %edi,%eax
 16a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 16d:	5b                   	pop    %ebx
 16e:	5e                   	pop    %esi
 16f:	5f                   	pop    %edi
 170:	5d                   	pop    %ebp
 171:	c3                   	ret    

00000172 <stat>:

int
stat(const char *n, struct stat *st)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
 175:	56                   	push   %esi
 176:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 177:	83 ec 08             	sub    $0x8,%esp
 17a:	6a 00                	push   $0x0
 17c:	ff 75 08             	pushl  0x8(%ebp)
 17f:	e8 d0 00 00 00       	call   254 <open>
  if(fd < 0)
 184:	83 c4 10             	add    $0x10,%esp
 187:	85 c0                	test   %eax,%eax
 189:	78 24                	js     1af <stat+0x3d>
 18b:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 18d:	83 ec 08             	sub    $0x8,%esp
 190:	ff 75 0c             	pushl  0xc(%ebp)
 193:	50                   	push   %eax
 194:	e8 d3 00 00 00       	call   26c <fstat>
 199:	89 c6                	mov    %eax,%esi
  close(fd);
 19b:	89 1c 24             	mov    %ebx,(%esp)
 19e:	e8 99 00 00 00       	call   23c <close>
  return r;
 1a3:	83 c4 10             	add    $0x10,%esp
}
 1a6:	89 f0                	mov    %esi,%eax
 1a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1ab:	5b                   	pop    %ebx
 1ac:	5e                   	pop    %esi
 1ad:	5d                   	pop    %ebp
 1ae:	c3                   	ret    
    return -1;
 1af:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b4:	eb f0                	jmp    1a6 <stat+0x34>

000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	55                   	push   %ebp
 1b7:	89 e5                	mov    %esp,%ebp
 1b9:	53                   	push   %ebx
 1ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1bd:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1c2:	eb 10                	jmp    1d4 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1c4:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1c7:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1ca:	83 c1 01             	add    $0x1,%ecx
 1cd:	0f be d2             	movsbl %dl,%edx
 1d0:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1d4:	0f b6 11             	movzbl (%ecx),%edx
 1d7:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1da:	80 fb 09             	cmp    $0x9,%bl
 1dd:	76 e5                	jbe    1c4 <atoi+0xe>
  return n;
}
 1df:	5b                   	pop    %ebx
 1e0:	5d                   	pop    %ebp
 1e1:	c3                   	ret    

000001e2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	56                   	push   %esi
 1e6:	53                   	push   %ebx
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1ed:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1f0:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1f2:	eb 0d                	jmp    201 <memmove+0x1f>
    *dst++ = *src++;
 1f4:	0f b6 13             	movzbl (%ebx),%edx
 1f7:	88 11                	mov    %dl,(%ecx)
 1f9:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1fc:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1ff:	89 f2                	mov    %esi,%edx
 201:	8d 72 ff             	lea    -0x1(%edx),%esi
 204:	85 d2                	test   %edx,%edx
 206:	7f ec                	jg     1f4 <memmove+0x12>
  return vdst;
}
 208:	5b                   	pop    %ebx
 209:	5e                   	pop    %esi
 20a:	5d                   	pop    %ebp
 20b:	c3                   	ret    

0000020c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 20c:	b8 01 00 00 00       	mov    $0x1,%eax
 211:	cd 40                	int    $0x40
 213:	c3                   	ret    

00000214 <exit>:
SYSCALL(exit)
 214:	b8 02 00 00 00       	mov    $0x2,%eax
 219:	cd 40                	int    $0x40
 21b:	c3                   	ret    

0000021c <wait>:
SYSCALL(wait)
 21c:	b8 03 00 00 00       	mov    $0x3,%eax
 221:	cd 40                	int    $0x40
 223:	c3                   	ret    

00000224 <pipe>:
SYSCALL(pipe)
 224:	b8 04 00 00 00       	mov    $0x4,%eax
 229:	cd 40                	int    $0x40
 22b:	c3                   	ret    

0000022c <read>:
SYSCALL(read)
 22c:	b8 05 00 00 00       	mov    $0x5,%eax
 231:	cd 40                	int    $0x40
 233:	c3                   	ret    

00000234 <write>:
SYSCALL(write)
 234:	b8 10 00 00 00       	mov    $0x10,%eax
 239:	cd 40                	int    $0x40
 23b:	c3                   	ret    

0000023c <close>:
SYSCALL(close)
 23c:	b8 15 00 00 00       	mov    $0x15,%eax
 241:	cd 40                	int    $0x40
 243:	c3                   	ret    

00000244 <kill>:
SYSCALL(kill)
 244:	b8 06 00 00 00       	mov    $0x6,%eax
 249:	cd 40                	int    $0x40
 24b:	c3                   	ret    

0000024c <exec>:
SYSCALL(exec)
 24c:	b8 07 00 00 00       	mov    $0x7,%eax
 251:	cd 40                	int    $0x40
 253:	c3                   	ret    

00000254 <open>:
SYSCALL(open)
 254:	b8 0f 00 00 00       	mov    $0xf,%eax
 259:	cd 40                	int    $0x40
 25b:	c3                   	ret    

0000025c <mknod>:
SYSCALL(mknod)
 25c:	b8 11 00 00 00       	mov    $0x11,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <unlink>:
SYSCALL(unlink)
 264:	b8 12 00 00 00       	mov    $0x12,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <fstat>:
SYSCALL(fstat)
 26c:	b8 08 00 00 00       	mov    $0x8,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <link>:
SYSCALL(link)
 274:	b8 13 00 00 00       	mov    $0x13,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <mkdir>:
SYSCALL(mkdir)
 27c:	b8 14 00 00 00       	mov    $0x14,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <chdir>:
SYSCALL(chdir)
 284:	b8 09 00 00 00       	mov    $0x9,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <dup>:
SYSCALL(dup)
 28c:	b8 0a 00 00 00       	mov    $0xa,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <getpid>:
SYSCALL(getpid)
 294:	b8 0b 00 00 00       	mov    $0xb,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <sbrk>:
SYSCALL(sbrk)
 29c:	b8 0c 00 00 00       	mov    $0xc,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <sleep>:
SYSCALL(sleep)
 2a4:	b8 0d 00 00 00       	mov    $0xd,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <uptime>:
SYSCALL(uptime)
 2ac:	b8 0e 00 00 00       	mov    $0xe,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <dump_physmem>:
SYSCALL(dump_physmem)
 2b4:	b8 16 00 00 00       	mov    $0x16,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2bc:	55                   	push   %ebp
 2bd:	89 e5                	mov    %esp,%ebp
 2bf:	83 ec 1c             	sub    $0x1c,%esp
 2c2:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c5:	6a 01                	push   $0x1
 2c7:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2ca:	52                   	push   %edx
 2cb:	50                   	push   %eax
 2cc:	e8 63 ff ff ff       	call   234 <write>
}
 2d1:	83 c4 10             	add    $0x10,%esp
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d6:	55                   	push   %ebp
 2d7:	89 e5                	mov    %esp,%ebp
 2d9:	57                   	push   %edi
 2da:	56                   	push   %esi
 2db:	53                   	push   %ebx
 2dc:	83 ec 2c             	sub    $0x2c,%esp
 2df:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e5:	0f 95 c3             	setne  %bl
 2e8:	89 d0                	mov    %edx,%eax
 2ea:	c1 e8 1f             	shr    $0x1f,%eax
 2ed:	84 c3                	test   %al,%bl
 2ef:	74 10                	je     301 <printint+0x2b>
    neg = 1;
    x = -xx;
 2f1:	f7 da                	neg    %edx
    neg = 1;
 2f3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2fa:	be 00 00 00 00       	mov    $0x0,%esi
 2ff:	eb 0b                	jmp    30c <printint+0x36>
  neg = 0;
 301:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 308:	eb f0                	jmp    2fa <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 30a:	89 c6                	mov    %eax,%esi
 30c:	89 d0                	mov    %edx,%eax
 30e:	ba 00 00 00 00       	mov    $0x0,%edx
 313:	f7 f1                	div    %ecx
 315:	89 c3                	mov    %eax,%ebx
 317:	8d 46 01             	lea    0x1(%esi),%eax
 31a:	0f b6 92 34 06 00 00 	movzbl 0x634(%edx),%edx
 321:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 325:	89 da                	mov    %ebx,%edx
 327:	85 db                	test   %ebx,%ebx
 329:	75 df                	jne    30a <printint+0x34>
 32b:	89 c3                	mov    %eax,%ebx
  if(neg)
 32d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 331:	74 16                	je     349 <printint+0x73>
    buf[i++] = '-';
 333:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 338:	8d 5e 02             	lea    0x2(%esi),%ebx
 33b:	eb 0c                	jmp    349 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 33d:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 342:	89 f8                	mov    %edi,%eax
 344:	e8 73 ff ff ff       	call   2bc <putc>
  while(--i >= 0)
 349:	83 eb 01             	sub    $0x1,%ebx
 34c:	79 ef                	jns    33d <printint+0x67>
}
 34e:	83 c4 2c             	add    $0x2c,%esp
 351:	5b                   	pop    %ebx
 352:	5e                   	pop    %esi
 353:	5f                   	pop    %edi
 354:	5d                   	pop    %ebp
 355:	c3                   	ret    

00000356 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 356:	55                   	push   %ebp
 357:	89 e5                	mov    %esp,%ebp
 359:	57                   	push   %edi
 35a:	56                   	push   %esi
 35b:	53                   	push   %ebx
 35c:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 35f:	8d 45 10             	lea    0x10(%ebp),%eax
 362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 365:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 36a:	bb 00 00 00 00       	mov    $0x0,%ebx
 36f:	eb 14                	jmp    385 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 371:	89 fa                	mov    %edi,%edx
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	e8 41 ff ff ff       	call   2bc <putc>
 37b:	eb 05                	jmp    382 <printf+0x2c>
      }
    } else if(state == '%'){
 37d:	83 fe 25             	cmp    $0x25,%esi
 380:	74 25                	je     3a7 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 382:	83 c3 01             	add    $0x1,%ebx
 385:	8b 45 0c             	mov    0xc(%ebp),%eax
 388:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 38c:	84 c0                	test   %al,%al
 38e:	0f 84 23 01 00 00    	je     4b7 <printf+0x161>
    c = fmt[i] & 0xff;
 394:	0f be f8             	movsbl %al,%edi
 397:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 39a:	85 f6                	test   %esi,%esi
 39c:	75 df                	jne    37d <printf+0x27>
      if(c == '%'){
 39e:	83 f8 25             	cmp    $0x25,%eax
 3a1:	75 ce                	jne    371 <printf+0x1b>
        state = '%';
 3a3:	89 c6                	mov    %eax,%esi
 3a5:	eb db                	jmp    382 <printf+0x2c>
      if(c == 'd'){
 3a7:	83 f8 64             	cmp    $0x64,%eax
 3aa:	74 49                	je     3f5 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3ac:	83 f8 78             	cmp    $0x78,%eax
 3af:	0f 94 c1             	sete   %cl
 3b2:	83 f8 70             	cmp    $0x70,%eax
 3b5:	0f 94 c2             	sete   %dl
 3b8:	08 d1                	or     %dl,%cl
 3ba:	75 63                	jne    41f <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3bc:	83 f8 73             	cmp    $0x73,%eax
 3bf:	0f 84 84 00 00 00    	je     449 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c5:	83 f8 63             	cmp    $0x63,%eax
 3c8:	0f 84 b7 00 00 00    	je     485 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3ce:	83 f8 25             	cmp    $0x25,%eax
 3d1:	0f 84 cc 00 00 00    	je     4a3 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3d7:	ba 25 00 00 00       	mov    $0x25,%edx
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	e8 d8 fe ff ff       	call   2bc <putc>
        putc(fd, c);
 3e4:	89 fa                	mov    %edi,%edx
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	e8 ce fe ff ff       	call   2bc <putc>
      }
      state = 0;
 3ee:	be 00 00 00 00       	mov    $0x0,%esi
 3f3:	eb 8d                	jmp    382 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f8:	8b 17                	mov    (%edi),%edx
 3fa:	83 ec 0c             	sub    $0xc,%esp
 3fd:	6a 01                	push   $0x1
 3ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
 404:	8b 45 08             	mov    0x8(%ebp),%eax
 407:	e8 ca fe ff ff       	call   2d6 <printint>
        ap++;
 40c:	83 c7 04             	add    $0x4,%edi
 40f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 412:	83 c4 10             	add    $0x10,%esp
      state = 0;
 415:	be 00 00 00 00       	mov    $0x0,%esi
 41a:	e9 63 ff ff ff       	jmp    382 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 41f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 422:	8b 17                	mov    (%edi),%edx
 424:	83 ec 0c             	sub    $0xc,%esp
 427:	6a 00                	push   $0x0
 429:	b9 10 00 00 00       	mov    $0x10,%ecx
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
 431:	e8 a0 fe ff ff       	call   2d6 <printint>
        ap++;
 436:	83 c7 04             	add    $0x4,%edi
 439:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 43c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 43f:	be 00 00 00 00       	mov    $0x0,%esi
 444:	e9 39 ff ff ff       	jmp    382 <printf+0x2c>
        s = (char*)*ap;
 449:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44c:	8b 30                	mov    (%eax),%esi
        ap++;
 44e:	83 c0 04             	add    $0x4,%eax
 451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 454:	85 f6                	test   %esi,%esi
 456:	75 28                	jne    480 <printf+0x12a>
          s = "(null)";
 458:	be 2c 06 00 00       	mov    $0x62c,%esi
 45d:	8b 7d 08             	mov    0x8(%ebp),%edi
 460:	eb 0d                	jmp    46f <printf+0x119>
          putc(fd, *s);
 462:	0f be d2             	movsbl %dl,%edx
 465:	89 f8                	mov    %edi,%eax
 467:	e8 50 fe ff ff       	call   2bc <putc>
          s++;
 46c:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 46f:	0f b6 16             	movzbl (%esi),%edx
 472:	84 d2                	test   %dl,%dl
 474:	75 ec                	jne    462 <printf+0x10c>
      state = 0;
 476:	be 00 00 00 00       	mov    $0x0,%esi
 47b:	e9 02 ff ff ff       	jmp    382 <printf+0x2c>
 480:	8b 7d 08             	mov    0x8(%ebp),%edi
 483:	eb ea                	jmp    46f <printf+0x119>
        putc(fd, *ap);
 485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 488:	0f be 17             	movsbl (%edi),%edx
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	e8 29 fe ff ff       	call   2bc <putc>
        ap++;
 493:	83 c7 04             	add    $0x4,%edi
 496:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 499:	be 00 00 00 00       	mov    $0x0,%esi
 49e:	e9 df fe ff ff       	jmp    382 <printf+0x2c>
        putc(fd, c);
 4a3:	89 fa                	mov    %edi,%edx
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	e8 0f fe ff ff       	call   2bc <putc>
      state = 0;
 4ad:	be 00 00 00 00       	mov    $0x0,%esi
 4b2:	e9 cb fe ff ff       	jmp    382 <printf+0x2c>
    }
  }
}
 4b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4ba:	5b                   	pop    %ebx
 4bb:	5e                   	pop    %esi
 4bc:	5f                   	pop    %edi
 4bd:	5d                   	pop    %ebp
 4be:	c3                   	ret    

000004bf <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	57                   	push   %edi
 4c3:	56                   	push   %esi
 4c4:	53                   	push   %ebx
 4c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4c8:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4cb:	a1 d8 08 00 00       	mov    0x8d8,%eax
 4d0:	eb 02                	jmp    4d4 <free+0x15>
 4d2:	89 d0                	mov    %edx,%eax
 4d4:	39 c8                	cmp    %ecx,%eax
 4d6:	73 04                	jae    4dc <free+0x1d>
 4d8:	39 08                	cmp    %ecx,(%eax)
 4da:	77 12                	ja     4ee <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4dc:	8b 10                	mov    (%eax),%edx
 4de:	39 c2                	cmp    %eax,%edx
 4e0:	77 f0                	ja     4d2 <free+0x13>
 4e2:	39 c8                	cmp    %ecx,%eax
 4e4:	72 08                	jb     4ee <free+0x2f>
 4e6:	39 ca                	cmp    %ecx,%edx
 4e8:	77 04                	ja     4ee <free+0x2f>
 4ea:	89 d0                	mov    %edx,%eax
 4ec:	eb e6                	jmp    4d4 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ee:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4f1:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4f4:	8b 10                	mov    (%eax),%edx
 4f6:	39 d7                	cmp    %edx,%edi
 4f8:	74 19                	je     513 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4fa:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4fd:	8b 50 04             	mov    0x4(%eax),%edx
 500:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 503:	39 ce                	cmp    %ecx,%esi
 505:	74 1b                	je     522 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 507:	89 08                	mov    %ecx,(%eax)
  freep = p;
 509:	a3 d8 08 00 00       	mov    %eax,0x8d8
}
 50e:	5b                   	pop    %ebx
 50f:	5e                   	pop    %esi
 510:	5f                   	pop    %edi
 511:	5d                   	pop    %ebp
 512:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 513:	03 72 04             	add    0x4(%edx),%esi
 516:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 519:	8b 10                	mov    (%eax),%edx
 51b:	8b 12                	mov    (%edx),%edx
 51d:	89 53 f8             	mov    %edx,-0x8(%ebx)
 520:	eb db                	jmp    4fd <free+0x3e>
    p->s.size += bp->s.size;
 522:	03 53 fc             	add    -0x4(%ebx),%edx
 525:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 528:	8b 53 f8             	mov    -0x8(%ebx),%edx
 52b:	89 10                	mov    %edx,(%eax)
 52d:	eb da                	jmp    509 <free+0x4a>

0000052f <morecore>:

static Header*
morecore(uint nu)
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
 532:	53                   	push   %ebx
 533:	83 ec 04             	sub    $0x4,%esp
 536:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 538:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 53d:	77 05                	ja     544 <morecore+0x15>
    nu = 4096;
 53f:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 544:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 54b:	83 ec 0c             	sub    $0xc,%esp
 54e:	50                   	push   %eax
 54f:	e8 48 fd ff ff       	call   29c <sbrk>
  if(p == (char*)-1)
 554:	83 c4 10             	add    $0x10,%esp
 557:	83 f8 ff             	cmp    $0xffffffff,%eax
 55a:	74 1c                	je     578 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 55f:	83 c0 08             	add    $0x8,%eax
 562:	83 ec 0c             	sub    $0xc,%esp
 565:	50                   	push   %eax
 566:	e8 54 ff ff ff       	call   4bf <free>
  return freep;
 56b:	a1 d8 08 00 00       	mov    0x8d8,%eax
 570:	83 c4 10             	add    $0x10,%esp
}
 573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 576:	c9                   	leave  
 577:	c3                   	ret    
    return 0;
 578:	b8 00 00 00 00       	mov    $0x0,%eax
 57d:	eb f4                	jmp    573 <morecore+0x44>

0000057f <malloc>:

void*
malloc(uint nbytes)
{
 57f:	55                   	push   %ebp
 580:	89 e5                	mov    %esp,%ebp
 582:	53                   	push   %ebx
 583:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	8d 58 07             	lea    0x7(%eax),%ebx
 58c:	c1 eb 03             	shr    $0x3,%ebx
 58f:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 592:	8b 0d d8 08 00 00    	mov    0x8d8,%ecx
 598:	85 c9                	test   %ecx,%ecx
 59a:	74 04                	je     5a0 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 59c:	8b 01                	mov    (%ecx),%eax
 59e:	eb 4d                	jmp    5ed <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5a0:	c7 05 d8 08 00 00 dc 	movl   $0x8dc,0x8d8
 5a7:	08 00 00 
 5aa:	c7 05 dc 08 00 00 dc 	movl   $0x8dc,0x8dc
 5b1:	08 00 00 
    base.s.size = 0;
 5b4:	c7 05 e0 08 00 00 00 	movl   $0x0,0x8e0
 5bb:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5be:	b9 dc 08 00 00       	mov    $0x8dc,%ecx
 5c3:	eb d7                	jmp    59c <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c5:	39 da                	cmp    %ebx,%edx
 5c7:	74 1a                	je     5e3 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5c9:	29 da                	sub    %ebx,%edx
 5cb:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5ce:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5d1:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5d4:	89 0d d8 08 00 00    	mov    %ecx,0x8d8
      return (void*)(p + 1);
 5da:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5dd:	83 c4 04             	add    $0x4,%esp
 5e0:	5b                   	pop    %ebx
 5e1:	5d                   	pop    %ebp
 5e2:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5e3:	8b 10                	mov    (%eax),%edx
 5e5:	89 11                	mov    %edx,(%ecx)
 5e7:	eb eb                	jmp    5d4 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5e9:	89 c1                	mov    %eax,%ecx
 5eb:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ed:	8b 50 04             	mov    0x4(%eax),%edx
 5f0:	39 da                	cmp    %ebx,%edx
 5f2:	73 d1                	jae    5c5 <malloc+0x46>
    if(p == freep)
 5f4:	39 05 d8 08 00 00    	cmp    %eax,0x8d8
 5fa:	75 ed                	jne    5e9 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5fc:	89 d8                	mov    %ebx,%eax
 5fe:	e8 2c ff ff ff       	call   52f <morecore>
 603:	85 c0                	test   %eax,%eax
 605:	75 e2                	jne    5e9 <malloc+0x6a>
        return 0;
 607:	b8 00 00 00 00       	mov    $0x0,%eax
 60c:	eb cf                	jmp    5dd <malloc+0x5e>
