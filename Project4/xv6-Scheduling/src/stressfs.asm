
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	81 ec 24 02 00 00    	sub    $0x224,%esp
  int fd, i;
  char path[] = "stressfs0";
  16:	c7 45 de 73 74 72 65 	movl   $0x65727473,-0x22(%ebp)
  1d:	c7 45 e2 73 73 66 73 	movl   $0x73667373,-0x1e(%ebp)
  24:	66 c7 45 e6 30 00    	movw   $0x30,-0x1a(%ebp)
  char data[512];

  printf(1, "stressfs starting\n");
  2a:	68 bc 06 00 00       	push   $0x6bc
  2f:	6a 01                	push   $0x1
  31:	e8 cd 03 00 00       	call   403 <printf>
  memset(data, 'a', sizeof(data));
  36:	83 c4 0c             	add    $0xc,%esp
  39:	68 00 02 00 00       	push   $0x200
  3e:	6a 61                	push   $0x61
  40:	8d 85 de fd ff ff    	lea    -0x222(%ebp),%eax
  46:	50                   	push   %eax
  47:	e8 2e 01 00 00       	call   17a <memset>

  for(i = 0; i < 4; i++)
  4c:	83 c4 10             	add    $0x10,%esp
  4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  54:	83 fb 03             	cmp    $0x3,%ebx
  57:	7f 0e                	jg     67 <main+0x67>
    if(fork() > 0)
  59:	e8 43 02 00 00       	call   2a1 <fork>
  5e:	85 c0                	test   %eax,%eax
  60:	7f 05                	jg     67 <main+0x67>
  for(i = 0; i < 4; i++)
  62:	83 c3 01             	add    $0x1,%ebx
  65:	eb ed                	jmp    54 <main+0x54>
      break;

  printf(1, "write %d\n", i);
  67:	83 ec 04             	sub    $0x4,%esp
  6a:	53                   	push   %ebx
  6b:	68 cf 06 00 00       	push   $0x6cf
  70:	6a 01                	push   $0x1
  72:	e8 8c 03 00 00       	call   403 <printf>

  path[8] += i;
  77:	00 5d e6             	add    %bl,-0x1a(%ebp)
  fd = open(path, O_CREATE | O_RDWR);
  7a:	83 c4 08             	add    $0x8,%esp
  7d:	68 02 02 00 00       	push   $0x202
  82:	8d 45 de             	lea    -0x22(%ebp),%eax
  85:	50                   	push   %eax
  86:	e8 5e 02 00 00       	call   2e9 <open>
  8b:	89 c6                	mov    %eax,%esi
  for(i = 0; i < 20; i++)
  8d:	83 c4 10             	add    $0x10,%esp
  90:	bb 00 00 00 00       	mov    $0x0,%ebx
  95:	eb 1b                	jmp    b2 <main+0xb2>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  97:	83 ec 04             	sub    $0x4,%esp
  9a:	68 00 02 00 00       	push   $0x200
  9f:	8d 85 de fd ff ff    	lea    -0x222(%ebp),%eax
  a5:	50                   	push   %eax
  a6:	56                   	push   %esi
  a7:	e8 1d 02 00 00       	call   2c9 <write>
  for(i = 0; i < 20; i++)
  ac:	83 c3 01             	add    $0x1,%ebx
  af:	83 c4 10             	add    $0x10,%esp
  b2:	83 fb 13             	cmp    $0x13,%ebx
  b5:	7e e0                	jle    97 <main+0x97>
  close(fd);
  b7:	83 ec 0c             	sub    $0xc,%esp
  ba:	56                   	push   %esi
  bb:	e8 11 02 00 00       	call   2d1 <close>

  printf(1, "read\n");
  c0:	83 c4 08             	add    $0x8,%esp
  c3:	68 d9 06 00 00       	push   $0x6d9
  c8:	6a 01                	push   $0x1
  ca:	e8 34 03 00 00       	call   403 <printf>

  fd = open(path, O_RDONLY);
  cf:	83 c4 08             	add    $0x8,%esp
  d2:	6a 00                	push   $0x0
  d4:	8d 45 de             	lea    -0x22(%ebp),%eax
  d7:	50                   	push   %eax
  d8:	e8 0c 02 00 00       	call   2e9 <open>
  dd:	89 c6                	mov    %eax,%esi
  for (i = 0; i < 20; i++)
  df:	83 c4 10             	add    $0x10,%esp
  e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  e7:	eb 1b                	jmp    104 <main+0x104>
    read(fd, data, sizeof(data));
  e9:	83 ec 04             	sub    $0x4,%esp
  ec:	68 00 02 00 00       	push   $0x200
  f1:	8d 85 de fd ff ff    	lea    -0x222(%ebp),%eax
  f7:	50                   	push   %eax
  f8:	56                   	push   %esi
  f9:	e8 c3 01 00 00       	call   2c1 <read>
  for (i = 0; i < 20; i++)
  fe:	83 c3 01             	add    $0x1,%ebx
 101:	83 c4 10             	add    $0x10,%esp
 104:	83 fb 13             	cmp    $0x13,%ebx
 107:	7e e0                	jle    e9 <main+0xe9>
  close(fd);
 109:	83 ec 0c             	sub    $0xc,%esp
 10c:	56                   	push   %esi
 10d:	e8 bf 01 00 00       	call   2d1 <close>

  wait();
 112:	e8 9a 01 00 00       	call   2b1 <wait>

  exit();
 117:	e8 8d 01 00 00       	call   2a9 <exit>

0000011c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	53                   	push   %ebx
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 126:	89 c2                	mov    %eax,%edx
 128:	0f b6 19             	movzbl (%ecx),%ebx
 12b:	88 1a                	mov    %bl,(%edx)
 12d:	8d 52 01             	lea    0x1(%edx),%edx
 130:	8d 49 01             	lea    0x1(%ecx),%ecx
 133:	84 db                	test   %bl,%bl
 135:	75 f1                	jne    128 <strcpy+0xc>
    ;
  return os;
}
 137:	5b                   	pop    %ebx
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    

0000013a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 140:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 143:	eb 06                	jmp    14b <strcmp+0x11>
    p++, q++;
 145:	83 c1 01             	add    $0x1,%ecx
 148:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 14b:	0f b6 01             	movzbl (%ecx),%eax
 14e:	84 c0                	test   %al,%al
 150:	74 04                	je     156 <strcmp+0x1c>
 152:	3a 02                	cmp    (%edx),%al
 154:	74 ef                	je     145 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 156:	0f b6 c0             	movzbl %al,%eax
 159:	0f b6 12             	movzbl (%edx),%edx
 15c:	29 d0                	sub    %edx,%eax
}
 15e:	5d                   	pop    %ebp
 15f:	c3                   	ret    

00000160 <strlen>:

uint
strlen(const char *s)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 166:	ba 00 00 00 00       	mov    $0x0,%edx
 16b:	eb 03                	jmp    170 <strlen+0x10>
 16d:	83 c2 01             	add    $0x1,%edx
 170:	89 d0                	mov    %edx,%eax
 172:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 176:	75 f5                	jne    16d <strlen+0xd>
    ;
  return n;
}
 178:	5d                   	pop    %ebp
 179:	c3                   	ret    

0000017a <memset>:

void*
memset(void *dst, int c, uint n)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	57                   	push   %edi
 17e:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 181:	89 d7                	mov    %edx,%edi
 183:	8b 4d 10             	mov    0x10(%ebp),%ecx
 186:	8b 45 0c             	mov    0xc(%ebp),%eax
 189:	fc                   	cld    
 18a:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 18c:	89 d0                	mov    %edx,%eax
 18e:	5f                   	pop    %edi
 18f:	5d                   	pop    %ebp
 190:	c3                   	ret    

00000191 <strchr>:

char*
strchr(const char *s, char c)
{
 191:	55                   	push   %ebp
 192:	89 e5                	mov    %esp,%ebp
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 19b:	0f b6 10             	movzbl (%eax),%edx
 19e:	84 d2                	test   %dl,%dl
 1a0:	74 09                	je     1ab <strchr+0x1a>
    if(*s == c)
 1a2:	38 ca                	cmp    %cl,%dl
 1a4:	74 0a                	je     1b0 <strchr+0x1f>
  for(; *s; s++)
 1a6:	83 c0 01             	add    $0x1,%eax
 1a9:	eb f0                	jmp    19b <strchr+0xa>
      return (char*)s;
  return 0;
 1ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    

000001b2 <gets>:

char*
gets(char *buf, int max)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	57                   	push   %edi
 1b6:	56                   	push   %esi
 1b7:	53                   	push   %ebx
 1b8:	83 ec 1c             	sub    $0x1c,%esp
 1bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1be:	bb 00 00 00 00       	mov    $0x0,%ebx
 1c3:	8d 73 01             	lea    0x1(%ebx),%esi
 1c6:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1c9:	7d 2e                	jge    1f9 <gets+0x47>
    cc = read(0, &c, 1);
 1cb:	83 ec 04             	sub    $0x4,%esp
 1ce:	6a 01                	push   $0x1
 1d0:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1d3:	50                   	push   %eax
 1d4:	6a 00                	push   $0x0
 1d6:	e8 e6 00 00 00       	call   2c1 <read>
    if(cc < 1)
 1db:	83 c4 10             	add    $0x10,%esp
 1de:	85 c0                	test   %eax,%eax
 1e0:	7e 17                	jle    1f9 <gets+0x47>
      break;
    buf[i++] = c;
 1e2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1e6:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1e9:	3c 0a                	cmp    $0xa,%al
 1eb:	0f 94 c2             	sete   %dl
 1ee:	3c 0d                	cmp    $0xd,%al
 1f0:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1f3:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1f5:	08 c2                	or     %al,%dl
 1f7:	74 ca                	je     1c3 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1f9:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1fd:	89 f8                	mov    %edi,%eax
 1ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
 202:	5b                   	pop    %ebx
 203:	5e                   	pop    %esi
 204:	5f                   	pop    %edi
 205:	5d                   	pop    %ebp
 206:	c3                   	ret    

00000207 <stat>:

int
stat(const char *n, struct stat *st)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	56                   	push   %esi
 20b:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	83 ec 08             	sub    $0x8,%esp
 20f:	6a 00                	push   $0x0
 211:	ff 75 08             	pushl  0x8(%ebp)
 214:	e8 d0 00 00 00       	call   2e9 <open>
  if(fd < 0)
 219:	83 c4 10             	add    $0x10,%esp
 21c:	85 c0                	test   %eax,%eax
 21e:	78 24                	js     244 <stat+0x3d>
 220:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 222:	83 ec 08             	sub    $0x8,%esp
 225:	ff 75 0c             	pushl  0xc(%ebp)
 228:	50                   	push   %eax
 229:	e8 d3 00 00 00       	call   301 <fstat>
 22e:	89 c6                	mov    %eax,%esi
  close(fd);
 230:	89 1c 24             	mov    %ebx,(%esp)
 233:	e8 99 00 00 00       	call   2d1 <close>
  return r;
 238:	83 c4 10             	add    $0x10,%esp
}
 23b:	89 f0                	mov    %esi,%eax
 23d:	8d 65 f8             	lea    -0x8(%ebp),%esp
 240:	5b                   	pop    %ebx
 241:	5e                   	pop    %esi
 242:	5d                   	pop    %ebp
 243:	c3                   	ret    
    return -1;
 244:	be ff ff ff ff       	mov    $0xffffffff,%esi
 249:	eb f0                	jmp    23b <stat+0x34>

0000024b <atoi>:

int
atoi(const char *s)
{
 24b:	55                   	push   %ebp
 24c:	89 e5                	mov    %esp,%ebp
 24e:	53                   	push   %ebx
 24f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 252:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 257:	eb 10                	jmp    269 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 259:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 25c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 25f:	83 c1 01             	add    $0x1,%ecx
 262:	0f be d2             	movsbl %dl,%edx
 265:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 269:	0f b6 11             	movzbl (%ecx),%edx
 26c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 26f:	80 fb 09             	cmp    $0x9,%bl
 272:	76 e5                	jbe    259 <atoi+0xe>
  return n;
}
 274:	5b                   	pop    %ebx
 275:	5d                   	pop    %ebp
 276:	c3                   	ret    

00000277 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	56                   	push   %esi
 27b:	53                   	push   %ebx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 282:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 285:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 287:	eb 0d                	jmp    296 <memmove+0x1f>
    *dst++ = *src++;
 289:	0f b6 13             	movzbl (%ebx),%edx
 28c:	88 11                	mov    %dl,(%ecx)
 28e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 291:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 294:	89 f2                	mov    %esi,%edx
 296:	8d 72 ff             	lea    -0x1(%edx),%esi
 299:	85 d2                	test   %edx,%edx
 29b:	7f ec                	jg     289 <memmove+0x12>
  return vdst;
}
 29d:	5b                   	pop    %ebx
 29e:	5e                   	pop    %esi
 29f:	5d                   	pop    %ebp
 2a0:	c3                   	ret    

000002a1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a1:	b8 01 00 00 00       	mov    $0x1,%eax
 2a6:	cd 40                	int    $0x40
 2a8:	c3                   	ret    

000002a9 <exit>:
SYSCALL(exit)
 2a9:	b8 02 00 00 00       	mov    $0x2,%eax
 2ae:	cd 40                	int    $0x40
 2b0:	c3                   	ret    

000002b1 <wait>:
SYSCALL(wait)
 2b1:	b8 03 00 00 00       	mov    $0x3,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret    

000002b9 <pipe>:
SYSCALL(pipe)
 2b9:	b8 04 00 00 00       	mov    $0x4,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret    

000002c1 <read>:
SYSCALL(read)
 2c1:	b8 05 00 00 00       	mov    $0x5,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <write>:
SYSCALL(write)
 2c9:	b8 10 00 00 00       	mov    $0x10,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <close>:
SYSCALL(close)
 2d1:	b8 15 00 00 00       	mov    $0x15,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <kill>:
SYSCALL(kill)
 2d9:	b8 06 00 00 00       	mov    $0x6,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <exec>:
SYSCALL(exec)
 2e1:	b8 07 00 00 00       	mov    $0x7,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <open>:
SYSCALL(open)
 2e9:	b8 0f 00 00 00       	mov    $0xf,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <mknod>:
SYSCALL(mknod)
 2f1:	b8 11 00 00 00       	mov    $0x11,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <unlink>:
SYSCALL(unlink)
 2f9:	b8 12 00 00 00       	mov    $0x12,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <fstat>:
SYSCALL(fstat)
 301:	b8 08 00 00 00       	mov    $0x8,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <link>:
SYSCALL(link)
 309:	b8 13 00 00 00       	mov    $0x13,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <mkdir>:
SYSCALL(mkdir)
 311:	b8 14 00 00 00       	mov    $0x14,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <chdir>:
SYSCALL(chdir)
 319:	b8 09 00 00 00       	mov    $0x9,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <dup>:
SYSCALL(dup)
 321:	b8 0a 00 00 00       	mov    $0xa,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <getpid>:
SYSCALL(getpid)
 329:	b8 0b 00 00 00       	mov    $0xb,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <sbrk>:
SYSCALL(sbrk)
 331:	b8 0c 00 00 00       	mov    $0xc,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <sleep>:
SYSCALL(sleep)
 339:	b8 0d 00 00 00       	mov    $0xd,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <uptime>:
SYSCALL(uptime)
 341:	b8 0e 00 00 00       	mov    $0xe,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <setpri>:
SYSCALL(setpri)
 349:	b8 16 00 00 00       	mov    $0x16,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <getpri>:
SYSCALL(getpri)
 351:	b8 17 00 00 00       	mov    $0x17,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <getpinfo>:
SYSCALL(getpinfo)
 359:	b8 18 00 00 00       	mov    $0x18,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <fork2>:
SYSCALL(fork2)
 361:	b8 19 00 00 00       	mov    $0x19,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 369:	55                   	push   %ebp
 36a:	89 e5                	mov    %esp,%ebp
 36c:	83 ec 1c             	sub    $0x1c,%esp
 36f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 372:	6a 01                	push   $0x1
 374:	8d 55 f4             	lea    -0xc(%ebp),%edx
 377:	52                   	push   %edx
 378:	50                   	push   %eax
 379:	e8 4b ff ff ff       	call   2c9 <write>
}
 37e:	83 c4 10             	add    $0x10,%esp
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	57                   	push   %edi
 387:	56                   	push   %esi
 388:	53                   	push   %ebx
 389:	83 ec 2c             	sub    $0x2c,%esp
 38c:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 38e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 392:	0f 95 c3             	setne  %bl
 395:	89 d0                	mov    %edx,%eax
 397:	c1 e8 1f             	shr    $0x1f,%eax
 39a:	84 c3                	test   %al,%bl
 39c:	74 10                	je     3ae <printint+0x2b>
    neg = 1;
    x = -xx;
 39e:	f7 da                	neg    %edx
    neg = 1;
 3a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3a7:	be 00 00 00 00       	mov    $0x0,%esi
 3ac:	eb 0b                	jmp    3b9 <printint+0x36>
  neg = 0;
 3ae:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3b5:	eb f0                	jmp    3a7 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3b7:	89 c6                	mov    %eax,%esi
 3b9:	89 d0                	mov    %edx,%eax
 3bb:	ba 00 00 00 00       	mov    $0x0,%edx
 3c0:	f7 f1                	div    %ecx
 3c2:	89 c3                	mov    %eax,%ebx
 3c4:	8d 46 01             	lea    0x1(%esi),%eax
 3c7:	0f b6 92 e8 06 00 00 	movzbl 0x6e8(%edx),%edx
 3ce:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3d2:	89 da                	mov    %ebx,%edx
 3d4:	85 db                	test   %ebx,%ebx
 3d6:	75 df                	jne    3b7 <printint+0x34>
 3d8:	89 c3                	mov    %eax,%ebx
  if(neg)
 3da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3de:	74 16                	je     3f6 <printint+0x73>
    buf[i++] = '-';
 3e0:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3e5:	8d 5e 02             	lea    0x2(%esi),%ebx
 3e8:	eb 0c                	jmp    3f6 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3ea:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3ef:	89 f8                	mov    %edi,%eax
 3f1:	e8 73 ff ff ff       	call   369 <putc>
  while(--i >= 0)
 3f6:	83 eb 01             	sub    $0x1,%ebx
 3f9:	79 ef                	jns    3ea <printint+0x67>
}
 3fb:	83 c4 2c             	add    $0x2c,%esp
 3fe:	5b                   	pop    %ebx
 3ff:	5e                   	pop    %esi
 400:	5f                   	pop    %edi
 401:	5d                   	pop    %ebp
 402:	c3                   	ret    

00000403 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 403:	55                   	push   %ebp
 404:	89 e5                	mov    %esp,%ebp
 406:	57                   	push   %edi
 407:	56                   	push   %esi
 408:	53                   	push   %ebx
 409:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 40c:	8d 45 10             	lea    0x10(%ebp),%eax
 40f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 412:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 417:	bb 00 00 00 00       	mov    $0x0,%ebx
 41c:	eb 14                	jmp    432 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 41e:	89 fa                	mov    %edi,%edx
 420:	8b 45 08             	mov    0x8(%ebp),%eax
 423:	e8 41 ff ff ff       	call   369 <putc>
 428:	eb 05                	jmp    42f <printf+0x2c>
      }
    } else if(state == '%'){
 42a:	83 fe 25             	cmp    $0x25,%esi
 42d:	74 25                	je     454 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 42f:	83 c3 01             	add    $0x1,%ebx
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 439:	84 c0                	test   %al,%al
 43b:	0f 84 23 01 00 00    	je     564 <printf+0x161>
    c = fmt[i] & 0xff;
 441:	0f be f8             	movsbl %al,%edi
 444:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 447:	85 f6                	test   %esi,%esi
 449:	75 df                	jne    42a <printf+0x27>
      if(c == '%'){
 44b:	83 f8 25             	cmp    $0x25,%eax
 44e:	75 ce                	jne    41e <printf+0x1b>
        state = '%';
 450:	89 c6                	mov    %eax,%esi
 452:	eb db                	jmp    42f <printf+0x2c>
      if(c == 'd'){
 454:	83 f8 64             	cmp    $0x64,%eax
 457:	74 49                	je     4a2 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 459:	83 f8 78             	cmp    $0x78,%eax
 45c:	0f 94 c1             	sete   %cl
 45f:	83 f8 70             	cmp    $0x70,%eax
 462:	0f 94 c2             	sete   %dl
 465:	08 d1                	or     %dl,%cl
 467:	75 63                	jne    4cc <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 469:	83 f8 73             	cmp    $0x73,%eax
 46c:	0f 84 84 00 00 00    	je     4f6 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 472:	83 f8 63             	cmp    $0x63,%eax
 475:	0f 84 b7 00 00 00    	je     532 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 47b:	83 f8 25             	cmp    $0x25,%eax
 47e:	0f 84 cc 00 00 00    	je     550 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 484:	ba 25 00 00 00       	mov    $0x25,%edx
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	e8 d8 fe ff ff       	call   369 <putc>
        putc(fd, c);
 491:	89 fa                	mov    %edi,%edx
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	e8 ce fe ff ff       	call   369 <putc>
      }
      state = 0;
 49b:	be 00 00 00 00       	mov    $0x0,%esi
 4a0:	eb 8d                	jmp    42f <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4a5:	8b 17                	mov    (%edi),%edx
 4a7:	83 ec 0c             	sub    $0xc,%esp
 4aa:	6a 01                	push   $0x1
 4ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4b1:	8b 45 08             	mov    0x8(%ebp),%eax
 4b4:	e8 ca fe ff ff       	call   383 <printint>
        ap++;
 4b9:	83 c7 04             	add    $0x4,%edi
 4bc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4bf:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4c2:	be 00 00 00 00       	mov    $0x0,%esi
 4c7:	e9 63 ff ff ff       	jmp    42f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4cf:	8b 17                	mov    (%edi),%edx
 4d1:	83 ec 0c             	sub    $0xc,%esp
 4d4:	6a 00                	push   $0x0
 4d6:	b9 10 00 00 00       	mov    $0x10,%ecx
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	e8 a0 fe ff ff       	call   383 <printint>
        ap++;
 4e3:	83 c7 04             	add    $0x4,%edi
 4e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ec:	be 00 00 00 00       	mov    $0x0,%esi
 4f1:	e9 39 ff ff ff       	jmp    42f <printf+0x2c>
        s = (char*)*ap;
 4f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f9:	8b 30                	mov    (%eax),%esi
        ap++;
 4fb:	83 c0 04             	add    $0x4,%eax
 4fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 501:	85 f6                	test   %esi,%esi
 503:	75 28                	jne    52d <printf+0x12a>
          s = "(null)";
 505:	be df 06 00 00       	mov    $0x6df,%esi
 50a:	8b 7d 08             	mov    0x8(%ebp),%edi
 50d:	eb 0d                	jmp    51c <printf+0x119>
          putc(fd, *s);
 50f:	0f be d2             	movsbl %dl,%edx
 512:	89 f8                	mov    %edi,%eax
 514:	e8 50 fe ff ff       	call   369 <putc>
          s++;
 519:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 51c:	0f b6 16             	movzbl (%esi),%edx
 51f:	84 d2                	test   %dl,%dl
 521:	75 ec                	jne    50f <printf+0x10c>
      state = 0;
 523:	be 00 00 00 00       	mov    $0x0,%esi
 528:	e9 02 ff ff ff       	jmp    42f <printf+0x2c>
 52d:	8b 7d 08             	mov    0x8(%ebp),%edi
 530:	eb ea                	jmp    51c <printf+0x119>
        putc(fd, *ap);
 532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 535:	0f be 17             	movsbl (%edi),%edx
 538:	8b 45 08             	mov    0x8(%ebp),%eax
 53b:	e8 29 fe ff ff       	call   369 <putc>
        ap++;
 540:	83 c7 04             	add    $0x4,%edi
 543:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 546:	be 00 00 00 00       	mov    $0x0,%esi
 54b:	e9 df fe ff ff       	jmp    42f <printf+0x2c>
        putc(fd, c);
 550:	89 fa                	mov    %edi,%edx
 552:	8b 45 08             	mov    0x8(%ebp),%eax
 555:	e8 0f fe ff ff       	call   369 <putc>
      state = 0;
 55a:	be 00 00 00 00       	mov    $0x0,%esi
 55f:	e9 cb fe ff ff       	jmp    42f <printf+0x2c>
    }
  }
}
 564:	8d 65 f4             	lea    -0xc(%ebp),%esp
 567:	5b                   	pop    %ebx
 568:	5e                   	pop    %esi
 569:	5f                   	pop    %edi
 56a:	5d                   	pop    %ebp
 56b:	c3                   	ret    

0000056c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 56c:	55                   	push   %ebp
 56d:	89 e5                	mov    %esp,%ebp
 56f:	57                   	push   %edi
 570:	56                   	push   %esi
 571:	53                   	push   %ebx
 572:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 575:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 578:	a1 88 09 00 00       	mov    0x988,%eax
 57d:	eb 02                	jmp    581 <free+0x15>
 57f:	89 d0                	mov    %edx,%eax
 581:	39 c8                	cmp    %ecx,%eax
 583:	73 04                	jae    589 <free+0x1d>
 585:	39 08                	cmp    %ecx,(%eax)
 587:	77 12                	ja     59b <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 589:	8b 10                	mov    (%eax),%edx
 58b:	39 c2                	cmp    %eax,%edx
 58d:	77 f0                	ja     57f <free+0x13>
 58f:	39 c8                	cmp    %ecx,%eax
 591:	72 08                	jb     59b <free+0x2f>
 593:	39 ca                	cmp    %ecx,%edx
 595:	77 04                	ja     59b <free+0x2f>
 597:	89 d0                	mov    %edx,%eax
 599:	eb e6                	jmp    581 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 59b:	8b 73 fc             	mov    -0x4(%ebx),%esi
 59e:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5a1:	8b 10                	mov    (%eax),%edx
 5a3:	39 d7                	cmp    %edx,%edi
 5a5:	74 19                	je     5c0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5a7:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5aa:	8b 50 04             	mov    0x4(%eax),%edx
 5ad:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5b0:	39 ce                	cmp    %ecx,%esi
 5b2:	74 1b                	je     5cf <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5b4:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5b6:	a3 88 09 00 00       	mov    %eax,0x988
}
 5bb:	5b                   	pop    %ebx
 5bc:	5e                   	pop    %esi
 5bd:	5f                   	pop    %edi
 5be:	5d                   	pop    %ebp
 5bf:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5c0:	03 72 04             	add    0x4(%edx),%esi
 5c3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5c6:	8b 10                	mov    (%eax),%edx
 5c8:	8b 12                	mov    (%edx),%edx
 5ca:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5cd:	eb db                	jmp    5aa <free+0x3e>
    p->s.size += bp->s.size;
 5cf:	03 53 fc             	add    -0x4(%ebx),%edx
 5d2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5d5:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5d8:	89 10                	mov    %edx,(%eax)
 5da:	eb da                	jmp    5b6 <free+0x4a>

000005dc <morecore>:

static Header*
morecore(uint nu)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	53                   	push   %ebx
 5e0:	83 ec 04             	sub    $0x4,%esp
 5e3:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5e5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5ea:	77 05                	ja     5f1 <morecore+0x15>
    nu = 4096;
 5ec:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5f1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5f8:	83 ec 0c             	sub    $0xc,%esp
 5fb:	50                   	push   %eax
 5fc:	e8 30 fd ff ff       	call   331 <sbrk>
  if(p == (char*)-1)
 601:	83 c4 10             	add    $0x10,%esp
 604:	83 f8 ff             	cmp    $0xffffffff,%eax
 607:	74 1c                	je     625 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 609:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 60c:	83 c0 08             	add    $0x8,%eax
 60f:	83 ec 0c             	sub    $0xc,%esp
 612:	50                   	push   %eax
 613:	e8 54 ff ff ff       	call   56c <free>
  return freep;
 618:	a1 88 09 00 00       	mov    0x988,%eax
 61d:	83 c4 10             	add    $0x10,%esp
}
 620:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 623:	c9                   	leave  
 624:	c3                   	ret    
    return 0;
 625:	b8 00 00 00 00       	mov    $0x0,%eax
 62a:	eb f4                	jmp    620 <morecore+0x44>

0000062c <malloc>:

void*
malloc(uint nbytes)
{
 62c:	55                   	push   %ebp
 62d:	89 e5                	mov    %esp,%ebp
 62f:	53                   	push   %ebx
 630:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 633:	8b 45 08             	mov    0x8(%ebp),%eax
 636:	8d 58 07             	lea    0x7(%eax),%ebx
 639:	c1 eb 03             	shr    $0x3,%ebx
 63c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 63f:	8b 0d 88 09 00 00    	mov    0x988,%ecx
 645:	85 c9                	test   %ecx,%ecx
 647:	74 04                	je     64d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 649:	8b 01                	mov    (%ecx),%eax
 64b:	eb 4d                	jmp    69a <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 64d:	c7 05 88 09 00 00 8c 	movl   $0x98c,0x988
 654:	09 00 00 
 657:	c7 05 8c 09 00 00 8c 	movl   $0x98c,0x98c
 65e:	09 00 00 
    base.s.size = 0;
 661:	c7 05 90 09 00 00 00 	movl   $0x0,0x990
 668:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 66b:	b9 8c 09 00 00       	mov    $0x98c,%ecx
 670:	eb d7                	jmp    649 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 672:	39 da                	cmp    %ebx,%edx
 674:	74 1a                	je     690 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 676:	29 da                	sub    %ebx,%edx
 678:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 67b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 67e:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 681:	89 0d 88 09 00 00    	mov    %ecx,0x988
      return (void*)(p + 1);
 687:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 68a:	83 c4 04             	add    $0x4,%esp
 68d:	5b                   	pop    %ebx
 68e:	5d                   	pop    %ebp
 68f:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 690:	8b 10                	mov    (%eax),%edx
 692:	89 11                	mov    %edx,(%ecx)
 694:	eb eb                	jmp    681 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 696:	89 c1                	mov    %eax,%ecx
 698:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 69a:	8b 50 04             	mov    0x4(%eax),%edx
 69d:	39 da                	cmp    %ebx,%edx
 69f:	73 d1                	jae    672 <malloc+0x46>
    if(p == freep)
 6a1:	39 05 88 09 00 00    	cmp    %eax,0x988
 6a7:	75 ed                	jne    696 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6a9:	89 d8                	mov    %ebx,%eax
 6ab:	e8 2c ff ff ff       	call   5dc <morecore>
 6b0:	85 c0                	test   %eax,%eax
 6b2:	75 e2                	jne    696 <malloc+0x6a>
        return 0;
 6b4:	b8 00 00 00 00       	mov    $0x0,%eax
 6b9:	eb cf                	jmp    68a <malloc+0x5e>
