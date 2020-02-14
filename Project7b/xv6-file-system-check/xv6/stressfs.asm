
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
  2a:	68 9c 06 00 00       	push   $0x69c
  2f:	6a 01                	push   $0x1
  31:	e8 ad 03 00 00       	call   3e3 <printf>
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
  6b:	68 af 06 00 00       	push   $0x6af
  70:	6a 01                	push   $0x1
  72:	e8 6c 03 00 00       	call   3e3 <printf>

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
  c3:	68 b9 06 00 00       	push   $0x6b9
  c8:	6a 01                	push   $0x1
  ca:	e8 14 03 00 00       	call   3e3 <printf>

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

00000349 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 1c             	sub    $0x1c,%esp
 34f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 352:	6a 01                	push   $0x1
 354:	8d 55 f4             	lea    -0xc(%ebp),%edx
 357:	52                   	push   %edx
 358:	50                   	push   %eax
 359:	e8 6b ff ff ff       	call   2c9 <write>
}
 35e:	83 c4 10             	add    $0x10,%esp
 361:	c9                   	leave  
 362:	c3                   	ret    

00000363 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 363:	55                   	push   %ebp
 364:	89 e5                	mov    %esp,%ebp
 366:	57                   	push   %edi
 367:	56                   	push   %esi
 368:	53                   	push   %ebx
 369:	83 ec 2c             	sub    $0x2c,%esp
 36c:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 36e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 372:	0f 95 c3             	setne  %bl
 375:	89 d0                	mov    %edx,%eax
 377:	c1 e8 1f             	shr    $0x1f,%eax
 37a:	84 c3                	test   %al,%bl
 37c:	74 10                	je     38e <printint+0x2b>
    neg = 1;
    x = -xx;
 37e:	f7 da                	neg    %edx
    neg = 1;
 380:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 387:	be 00 00 00 00       	mov    $0x0,%esi
 38c:	eb 0b                	jmp    399 <printint+0x36>
  neg = 0;
 38e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 395:	eb f0                	jmp    387 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 397:	89 c6                	mov    %eax,%esi
 399:	89 d0                	mov    %edx,%eax
 39b:	ba 00 00 00 00       	mov    $0x0,%edx
 3a0:	f7 f1                	div    %ecx
 3a2:	89 c3                	mov    %eax,%ebx
 3a4:	8d 46 01             	lea    0x1(%esi),%eax
 3a7:	0f b6 92 c8 06 00 00 	movzbl 0x6c8(%edx),%edx
 3ae:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3b2:	89 da                	mov    %ebx,%edx
 3b4:	85 db                	test   %ebx,%ebx
 3b6:	75 df                	jne    397 <printint+0x34>
 3b8:	89 c3                	mov    %eax,%ebx
  if(neg)
 3ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3be:	74 16                	je     3d6 <printint+0x73>
    buf[i++] = '-';
 3c0:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3c5:	8d 5e 02             	lea    0x2(%esi),%ebx
 3c8:	eb 0c                	jmp    3d6 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3ca:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3cf:	89 f8                	mov    %edi,%eax
 3d1:	e8 73 ff ff ff       	call   349 <putc>
  while(--i >= 0)
 3d6:	83 eb 01             	sub    $0x1,%ebx
 3d9:	79 ef                	jns    3ca <printint+0x67>
}
 3db:	83 c4 2c             	add    $0x2c,%esp
 3de:	5b                   	pop    %ebx
 3df:	5e                   	pop    %esi
 3e0:	5f                   	pop    %edi
 3e1:	5d                   	pop    %ebp
 3e2:	c3                   	ret    

000003e3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	57                   	push   %edi
 3e7:	56                   	push   %esi
 3e8:	53                   	push   %ebx
 3e9:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3ec:	8d 45 10             	lea    0x10(%ebp),%eax
 3ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3f2:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3f7:	bb 00 00 00 00       	mov    $0x0,%ebx
 3fc:	eb 14                	jmp    412 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3fe:	89 fa                	mov    %edi,%edx
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	e8 41 ff ff ff       	call   349 <putc>
 408:	eb 05                	jmp    40f <printf+0x2c>
      }
    } else if(state == '%'){
 40a:	83 fe 25             	cmp    $0x25,%esi
 40d:	74 25                	je     434 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 40f:	83 c3 01             	add    $0x1,%ebx
 412:	8b 45 0c             	mov    0xc(%ebp),%eax
 415:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 419:	84 c0                	test   %al,%al
 41b:	0f 84 23 01 00 00    	je     544 <printf+0x161>
    c = fmt[i] & 0xff;
 421:	0f be f8             	movsbl %al,%edi
 424:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 427:	85 f6                	test   %esi,%esi
 429:	75 df                	jne    40a <printf+0x27>
      if(c == '%'){
 42b:	83 f8 25             	cmp    $0x25,%eax
 42e:	75 ce                	jne    3fe <printf+0x1b>
        state = '%';
 430:	89 c6                	mov    %eax,%esi
 432:	eb db                	jmp    40f <printf+0x2c>
      if(c == 'd'){
 434:	83 f8 64             	cmp    $0x64,%eax
 437:	74 49                	je     482 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 439:	83 f8 78             	cmp    $0x78,%eax
 43c:	0f 94 c1             	sete   %cl
 43f:	83 f8 70             	cmp    $0x70,%eax
 442:	0f 94 c2             	sete   %dl
 445:	08 d1                	or     %dl,%cl
 447:	75 63                	jne    4ac <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 449:	83 f8 73             	cmp    $0x73,%eax
 44c:	0f 84 84 00 00 00    	je     4d6 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 452:	83 f8 63             	cmp    $0x63,%eax
 455:	0f 84 b7 00 00 00    	je     512 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 45b:	83 f8 25             	cmp    $0x25,%eax
 45e:	0f 84 cc 00 00 00    	je     530 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 464:	ba 25 00 00 00       	mov    $0x25,%edx
 469:	8b 45 08             	mov    0x8(%ebp),%eax
 46c:	e8 d8 fe ff ff       	call   349 <putc>
        putc(fd, c);
 471:	89 fa                	mov    %edi,%edx
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	e8 ce fe ff ff       	call   349 <putc>
      }
      state = 0;
 47b:	be 00 00 00 00       	mov    $0x0,%esi
 480:	eb 8d                	jmp    40f <printf+0x2c>
        printint(fd, *ap, 10, 1);
 482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 485:	8b 17                	mov    (%edi),%edx
 487:	83 ec 0c             	sub    $0xc,%esp
 48a:	6a 01                	push   $0x1
 48c:	b9 0a 00 00 00       	mov    $0xa,%ecx
 491:	8b 45 08             	mov    0x8(%ebp),%eax
 494:	e8 ca fe ff ff       	call   363 <printint>
        ap++;
 499:	83 c7 04             	add    $0x4,%edi
 49c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 49f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4a2:	be 00 00 00 00       	mov    $0x0,%esi
 4a7:	e9 63 ff ff ff       	jmp    40f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4af:	8b 17                	mov    (%edi),%edx
 4b1:	83 ec 0c             	sub    $0xc,%esp
 4b4:	6a 00                	push   $0x0
 4b6:	b9 10 00 00 00       	mov    $0x10,%ecx
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	e8 a0 fe ff ff       	call   363 <printint>
        ap++;
 4c3:	83 c7 04             	add    $0x4,%edi
 4c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4c9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4cc:	be 00 00 00 00       	mov    $0x0,%esi
 4d1:	e9 39 ff ff ff       	jmp    40f <printf+0x2c>
        s = (char*)*ap;
 4d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d9:	8b 30                	mov    (%eax),%esi
        ap++;
 4db:	83 c0 04             	add    $0x4,%eax
 4de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4e1:	85 f6                	test   %esi,%esi
 4e3:	75 28                	jne    50d <printf+0x12a>
          s = "(null)";
 4e5:	be bf 06 00 00       	mov    $0x6bf,%esi
 4ea:	8b 7d 08             	mov    0x8(%ebp),%edi
 4ed:	eb 0d                	jmp    4fc <printf+0x119>
          putc(fd, *s);
 4ef:	0f be d2             	movsbl %dl,%edx
 4f2:	89 f8                	mov    %edi,%eax
 4f4:	e8 50 fe ff ff       	call   349 <putc>
          s++;
 4f9:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4fc:	0f b6 16             	movzbl (%esi),%edx
 4ff:	84 d2                	test   %dl,%dl
 501:	75 ec                	jne    4ef <printf+0x10c>
      state = 0;
 503:	be 00 00 00 00       	mov    $0x0,%esi
 508:	e9 02 ff ff ff       	jmp    40f <printf+0x2c>
 50d:	8b 7d 08             	mov    0x8(%ebp),%edi
 510:	eb ea                	jmp    4fc <printf+0x119>
        putc(fd, *ap);
 512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 515:	0f be 17             	movsbl (%edi),%edx
 518:	8b 45 08             	mov    0x8(%ebp),%eax
 51b:	e8 29 fe ff ff       	call   349 <putc>
        ap++;
 520:	83 c7 04             	add    $0x4,%edi
 523:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 526:	be 00 00 00 00       	mov    $0x0,%esi
 52b:	e9 df fe ff ff       	jmp    40f <printf+0x2c>
        putc(fd, c);
 530:	89 fa                	mov    %edi,%edx
 532:	8b 45 08             	mov    0x8(%ebp),%eax
 535:	e8 0f fe ff ff       	call   349 <putc>
      state = 0;
 53a:	be 00 00 00 00       	mov    $0x0,%esi
 53f:	e9 cb fe ff ff       	jmp    40f <printf+0x2c>
    }
  }
}
 544:	8d 65 f4             	lea    -0xc(%ebp),%esp
 547:	5b                   	pop    %ebx
 548:	5e                   	pop    %esi
 549:	5f                   	pop    %edi
 54a:	5d                   	pop    %ebp
 54b:	c3                   	ret    

0000054c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	57                   	push   %edi
 550:	56                   	push   %esi
 551:	53                   	push   %ebx
 552:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 555:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 558:	a1 68 09 00 00       	mov    0x968,%eax
 55d:	eb 02                	jmp    561 <free+0x15>
 55f:	89 d0                	mov    %edx,%eax
 561:	39 c8                	cmp    %ecx,%eax
 563:	73 04                	jae    569 <free+0x1d>
 565:	39 08                	cmp    %ecx,(%eax)
 567:	77 12                	ja     57b <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 569:	8b 10                	mov    (%eax),%edx
 56b:	39 c2                	cmp    %eax,%edx
 56d:	77 f0                	ja     55f <free+0x13>
 56f:	39 c8                	cmp    %ecx,%eax
 571:	72 08                	jb     57b <free+0x2f>
 573:	39 ca                	cmp    %ecx,%edx
 575:	77 04                	ja     57b <free+0x2f>
 577:	89 d0                	mov    %edx,%eax
 579:	eb e6                	jmp    561 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 57b:	8b 73 fc             	mov    -0x4(%ebx),%esi
 57e:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 581:	8b 10                	mov    (%eax),%edx
 583:	39 d7                	cmp    %edx,%edi
 585:	74 19                	je     5a0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 587:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 58a:	8b 50 04             	mov    0x4(%eax),%edx
 58d:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 590:	39 ce                	cmp    %ecx,%esi
 592:	74 1b                	je     5af <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 594:	89 08                	mov    %ecx,(%eax)
  freep = p;
 596:	a3 68 09 00 00       	mov    %eax,0x968
}
 59b:	5b                   	pop    %ebx
 59c:	5e                   	pop    %esi
 59d:	5f                   	pop    %edi
 59e:	5d                   	pop    %ebp
 59f:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5a0:	03 72 04             	add    0x4(%edx),%esi
 5a3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5a6:	8b 10                	mov    (%eax),%edx
 5a8:	8b 12                	mov    (%edx),%edx
 5aa:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5ad:	eb db                	jmp    58a <free+0x3e>
    p->s.size += bp->s.size;
 5af:	03 53 fc             	add    -0x4(%ebx),%edx
 5b2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5b5:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5b8:	89 10                	mov    %edx,(%eax)
 5ba:	eb da                	jmp    596 <free+0x4a>

000005bc <morecore>:

static Header*
morecore(uint nu)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	53                   	push   %ebx
 5c0:	83 ec 04             	sub    $0x4,%esp
 5c3:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5c5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5ca:	77 05                	ja     5d1 <morecore+0x15>
    nu = 4096;
 5cc:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5d1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5d8:	83 ec 0c             	sub    $0xc,%esp
 5db:	50                   	push   %eax
 5dc:	e8 50 fd ff ff       	call   331 <sbrk>
  if(p == (char*)-1)
 5e1:	83 c4 10             	add    $0x10,%esp
 5e4:	83 f8 ff             	cmp    $0xffffffff,%eax
 5e7:	74 1c                	je     605 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5e9:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5ec:	83 c0 08             	add    $0x8,%eax
 5ef:	83 ec 0c             	sub    $0xc,%esp
 5f2:	50                   	push   %eax
 5f3:	e8 54 ff ff ff       	call   54c <free>
  return freep;
 5f8:	a1 68 09 00 00       	mov    0x968,%eax
 5fd:	83 c4 10             	add    $0x10,%esp
}
 600:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 603:	c9                   	leave  
 604:	c3                   	ret    
    return 0;
 605:	b8 00 00 00 00       	mov    $0x0,%eax
 60a:	eb f4                	jmp    600 <morecore+0x44>

0000060c <malloc>:

void*
malloc(uint nbytes)
{
 60c:	55                   	push   %ebp
 60d:	89 e5                	mov    %esp,%ebp
 60f:	53                   	push   %ebx
 610:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 613:	8b 45 08             	mov    0x8(%ebp),%eax
 616:	8d 58 07             	lea    0x7(%eax),%ebx
 619:	c1 eb 03             	shr    $0x3,%ebx
 61c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 61f:	8b 0d 68 09 00 00    	mov    0x968,%ecx
 625:	85 c9                	test   %ecx,%ecx
 627:	74 04                	je     62d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 629:	8b 01                	mov    (%ecx),%eax
 62b:	eb 4d                	jmp    67a <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 62d:	c7 05 68 09 00 00 6c 	movl   $0x96c,0x968
 634:	09 00 00 
 637:	c7 05 6c 09 00 00 6c 	movl   $0x96c,0x96c
 63e:	09 00 00 
    base.s.size = 0;
 641:	c7 05 70 09 00 00 00 	movl   $0x0,0x970
 648:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 64b:	b9 6c 09 00 00       	mov    $0x96c,%ecx
 650:	eb d7                	jmp    629 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 652:	39 da                	cmp    %ebx,%edx
 654:	74 1a                	je     670 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 656:	29 da                	sub    %ebx,%edx
 658:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 65b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 65e:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 661:	89 0d 68 09 00 00    	mov    %ecx,0x968
      return (void*)(p + 1);
 667:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 66a:	83 c4 04             	add    $0x4,%esp
 66d:	5b                   	pop    %ebx
 66e:	5d                   	pop    %ebp
 66f:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 670:	8b 10                	mov    (%eax),%edx
 672:	89 11                	mov    %edx,(%ecx)
 674:	eb eb                	jmp    661 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 676:	89 c1                	mov    %eax,%ecx
 678:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 67a:	8b 50 04             	mov    0x4(%eax),%edx
 67d:	39 da                	cmp    %ebx,%edx
 67f:	73 d1                	jae    652 <malloc+0x46>
    if(p == freep)
 681:	39 05 68 09 00 00    	cmp    %eax,0x968
 687:	75 ed                	jne    676 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 689:	89 d8                	mov    %ebx,%eax
 68b:	e8 2c ff ff ff       	call   5bc <morecore>
 690:	85 c0                	test   %eax,%eax
 692:	75 e2                	jne    676 <malloc+0x6a>
        return 0;
 694:	b8 00 00 00 00       	mov    $0x0,%eax
 699:	eb cf                	jmp    66a <malloc+0x5e>
