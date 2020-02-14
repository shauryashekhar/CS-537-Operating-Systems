
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   8:	83 ec 04             	sub    $0x4,%esp
   b:	68 00 02 00 00       	push   $0x200
  10:	68 c0 09 00 00       	push   $0x9c0
  15:	56                   	push   %esi
  16:	e8 84 02 00 00       	call   29f <read>
  1b:	89 c3                	mov    %eax,%ebx
  1d:	83 c4 10             	add    $0x10,%esp
  20:	85 c0                	test   %eax,%eax
  22:	7e 2b                	jle    4f <cat+0x4f>
    if (write(1, buf, n) != n) {
  24:	83 ec 04             	sub    $0x4,%esp
  27:	53                   	push   %ebx
  28:	68 c0 09 00 00       	push   $0x9c0
  2d:	6a 01                	push   $0x1
  2f:	e8 73 02 00 00       	call   2a7 <write>
  34:	83 c4 10             	add    $0x10,%esp
  37:	39 d8                	cmp    %ebx,%eax
  39:	74 cd                	je     8 <cat+0x8>
      printf(1, "cat: write error\n");
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	68 7c 06 00 00       	push   $0x67c
  43:	6a 01                	push   $0x1
  45:	e8 77 03 00 00       	call   3c1 <printf>
      exit();
  4a:	e8 38 02 00 00       	call   287 <exit>
    }
  }
  if(n < 0){
  4f:	85 c0                	test   %eax,%eax
  51:	78 07                	js     5a <cat+0x5a>
    printf(1, "cat: read error\n");
    exit();
  }
}
  53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  56:	5b                   	pop    %ebx
  57:	5e                   	pop    %esi
  58:	5d                   	pop    %ebp
  59:	c3                   	ret    
    printf(1, "cat: read error\n");
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	68 8e 06 00 00       	push   $0x68e
  62:	6a 01                	push   $0x1
  64:	e8 58 03 00 00       	call   3c1 <printf>
    exit();
  69:	e8 19 02 00 00       	call   287 <exit>

0000006e <main>:

int
main(int argc, char *argv[])
{
  6e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  72:	83 e4 f0             	and    $0xfffffff0,%esp
  75:	ff 71 fc             	pushl  -0x4(%ecx)
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	57                   	push   %edi
  7c:	56                   	push   %esi
  7d:	53                   	push   %ebx
  7e:	51                   	push   %ecx
  7f:	83 ec 18             	sub    $0x18,%esp
  82:	8b 01                	mov    (%ecx),%eax
  84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  87:	8b 51 04             	mov    0x4(%ecx),%edx
  8a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int fd, i;

  if(argc <= 1){
  8d:	83 f8 01             	cmp    $0x1,%eax
  90:	7e 3e                	jle    d0 <main+0x62>
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  92:	bb 01 00 00 00       	mov    $0x1,%ebx
  97:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  9a:	7d 59                	jge    f5 <main+0x87>
    if((fd = open(argv[i], 0)) < 0){
  9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  9f:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
  a2:	83 ec 08             	sub    $0x8,%esp
  a5:	6a 00                	push   $0x0
  a7:	ff 37                	pushl  (%edi)
  a9:	e8 19 02 00 00       	call   2c7 <open>
  ae:	89 c6                	mov    %eax,%esi
  b0:	83 c4 10             	add    $0x10,%esp
  b3:	85 c0                	test   %eax,%eax
  b5:	78 28                	js     df <main+0x71>
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  b7:	83 ec 0c             	sub    $0xc,%esp
  ba:	50                   	push   %eax
  bb:	e8 40 ff ff ff       	call   0 <cat>
    close(fd);
  c0:	89 34 24             	mov    %esi,(%esp)
  c3:	e8 e7 01 00 00       	call   2af <close>
  for(i = 1; i < argc; i++){
  c8:	83 c3 01             	add    $0x1,%ebx
  cb:	83 c4 10             	add    $0x10,%esp
  ce:	eb c7                	jmp    97 <main+0x29>
    cat(0);
  d0:	83 ec 0c             	sub    $0xc,%esp
  d3:	6a 00                	push   $0x0
  d5:	e8 26 ff ff ff       	call   0 <cat>
    exit();
  da:	e8 a8 01 00 00       	call   287 <exit>
      printf(1, "cat: cannot open %s\n", argv[i]);
  df:	83 ec 04             	sub    $0x4,%esp
  e2:	ff 37                	pushl  (%edi)
  e4:	68 9f 06 00 00       	push   $0x69f
  e9:	6a 01                	push   $0x1
  eb:	e8 d1 02 00 00       	call   3c1 <printf>
      exit();
  f0:	e8 92 01 00 00       	call   287 <exit>
  }
  exit();
  f5:	e8 8d 01 00 00       	call   287 <exit>

000000fa <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  fa:	55                   	push   %ebp
  fb:	89 e5                	mov    %esp,%ebp
  fd:	53                   	push   %ebx
  fe:	8b 45 08             	mov    0x8(%ebp),%eax
 101:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	89 c2                	mov    %eax,%edx
 106:	0f b6 19             	movzbl (%ecx),%ebx
 109:	88 1a                	mov    %bl,(%edx)
 10b:	8d 52 01             	lea    0x1(%edx),%edx
 10e:	8d 49 01             	lea    0x1(%ecx),%ecx
 111:	84 db                	test   %bl,%bl
 113:	75 f1                	jne    106 <strcpy+0xc>
    ;
  return os;
}
 115:	5b                   	pop    %ebx
 116:	5d                   	pop    %ebp
 117:	c3                   	ret    

00000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 121:	eb 06                	jmp    129 <strcmp+0x11>
    p++, q++;
 123:	83 c1 01             	add    $0x1,%ecx
 126:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 129:	0f b6 01             	movzbl (%ecx),%eax
 12c:	84 c0                	test   %al,%al
 12e:	74 04                	je     134 <strcmp+0x1c>
 130:	3a 02                	cmp    (%edx),%al
 132:	74 ef                	je     123 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 134:	0f b6 c0             	movzbl %al,%eax
 137:	0f b6 12             	movzbl (%edx),%edx
 13a:	29 d0                	sub    %edx,%eax
}
 13c:	5d                   	pop    %ebp
 13d:	c3                   	ret    

0000013e <strlen>:

uint
strlen(const char *s)
{
 13e:	55                   	push   %ebp
 13f:	89 e5                	mov    %esp,%ebp
 141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 144:	ba 00 00 00 00       	mov    $0x0,%edx
 149:	eb 03                	jmp    14e <strlen+0x10>
 14b:	83 c2 01             	add    $0x1,%edx
 14e:	89 d0                	mov    %edx,%eax
 150:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 154:	75 f5                	jne    14b <strlen+0xd>
    ;
  return n;
}
 156:	5d                   	pop    %ebp
 157:	c3                   	ret    

00000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	57                   	push   %edi
 15c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 15f:	89 d7                	mov    %edx,%edi
 161:	8b 4d 10             	mov    0x10(%ebp),%ecx
 164:	8b 45 0c             	mov    0xc(%ebp),%eax
 167:	fc                   	cld    
 168:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 16a:	89 d0                	mov    %edx,%eax
 16c:	5f                   	pop    %edi
 16d:	5d                   	pop    %ebp
 16e:	c3                   	ret    

0000016f <strchr>:

char*
strchr(const char *s, char c)
{
 16f:	55                   	push   %ebp
 170:	89 e5                	mov    %esp,%ebp
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 179:	0f b6 10             	movzbl (%eax),%edx
 17c:	84 d2                	test   %dl,%dl
 17e:	74 09                	je     189 <strchr+0x1a>
    if(*s == c)
 180:	38 ca                	cmp    %cl,%dl
 182:	74 0a                	je     18e <strchr+0x1f>
  for(; *s; s++)
 184:	83 c0 01             	add    $0x1,%eax
 187:	eb f0                	jmp    179 <strchr+0xa>
      return (char*)s;
  return 0;
 189:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18e:	5d                   	pop    %ebp
 18f:	c3                   	ret    

00000190 <gets>:

char*
gets(char *buf, int max)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	57                   	push   %edi
 194:	56                   	push   %esi
 195:	53                   	push   %ebx
 196:	83 ec 1c             	sub    $0x1c,%esp
 199:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19c:	bb 00 00 00 00       	mov    $0x0,%ebx
 1a1:	8d 73 01             	lea    0x1(%ebx),%esi
 1a4:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1a7:	7d 2e                	jge    1d7 <gets+0x47>
    cc = read(0, &c, 1);
 1a9:	83 ec 04             	sub    $0x4,%esp
 1ac:	6a 01                	push   $0x1
 1ae:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1b1:	50                   	push   %eax
 1b2:	6a 00                	push   $0x0
 1b4:	e8 e6 00 00 00       	call   29f <read>
    if(cc < 1)
 1b9:	83 c4 10             	add    $0x10,%esp
 1bc:	85 c0                	test   %eax,%eax
 1be:	7e 17                	jle    1d7 <gets+0x47>
      break;
    buf[i++] = c;
 1c0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1c4:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1c7:	3c 0a                	cmp    $0xa,%al
 1c9:	0f 94 c2             	sete   %dl
 1cc:	3c 0d                	cmp    $0xd,%al
 1ce:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1d1:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1d3:	08 c2                	or     %al,%dl
 1d5:	74 ca                	je     1a1 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1d7:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1db:	89 f8                	mov    %edi,%eax
 1dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1e0:	5b                   	pop    %ebx
 1e1:	5e                   	pop    %esi
 1e2:	5f                   	pop    %edi
 1e3:	5d                   	pop    %ebp
 1e4:	c3                   	ret    

000001e5 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e5:	55                   	push   %ebp
 1e6:	89 e5                	mov    %esp,%ebp
 1e8:	56                   	push   %esi
 1e9:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ea:	83 ec 08             	sub    $0x8,%esp
 1ed:	6a 00                	push   $0x0
 1ef:	ff 75 08             	pushl  0x8(%ebp)
 1f2:	e8 d0 00 00 00       	call   2c7 <open>
  if(fd < 0)
 1f7:	83 c4 10             	add    $0x10,%esp
 1fa:	85 c0                	test   %eax,%eax
 1fc:	78 24                	js     222 <stat+0x3d>
 1fe:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 200:	83 ec 08             	sub    $0x8,%esp
 203:	ff 75 0c             	pushl  0xc(%ebp)
 206:	50                   	push   %eax
 207:	e8 d3 00 00 00       	call   2df <fstat>
 20c:	89 c6                	mov    %eax,%esi
  close(fd);
 20e:	89 1c 24             	mov    %ebx,(%esp)
 211:	e8 99 00 00 00       	call   2af <close>
  return r;
 216:	83 c4 10             	add    $0x10,%esp
}
 219:	89 f0                	mov    %esi,%eax
 21b:	8d 65 f8             	lea    -0x8(%ebp),%esp
 21e:	5b                   	pop    %ebx
 21f:	5e                   	pop    %esi
 220:	5d                   	pop    %ebp
 221:	c3                   	ret    
    return -1;
 222:	be ff ff ff ff       	mov    $0xffffffff,%esi
 227:	eb f0                	jmp    219 <stat+0x34>

00000229 <atoi>:

int
atoi(const char *s)
{
 229:	55                   	push   %ebp
 22a:	89 e5                	mov    %esp,%ebp
 22c:	53                   	push   %ebx
 22d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 230:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 235:	eb 10                	jmp    247 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 237:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 23a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 23d:	83 c1 01             	add    $0x1,%ecx
 240:	0f be d2             	movsbl %dl,%edx
 243:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 247:	0f b6 11             	movzbl (%ecx),%edx
 24a:	8d 5a d0             	lea    -0x30(%edx),%ebx
 24d:	80 fb 09             	cmp    $0x9,%bl
 250:	76 e5                	jbe    237 <atoi+0xe>
  return n;
}
 252:	5b                   	pop    %ebx
 253:	5d                   	pop    %ebp
 254:	c3                   	ret    

00000255 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 255:	55                   	push   %ebp
 256:	89 e5                	mov    %esp,%ebp
 258:	56                   	push   %esi
 259:	53                   	push   %ebx
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 260:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 263:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 265:	eb 0d                	jmp    274 <memmove+0x1f>
    *dst++ = *src++;
 267:	0f b6 13             	movzbl (%ebx),%edx
 26a:	88 11                	mov    %dl,(%ecx)
 26c:	8d 5b 01             	lea    0x1(%ebx),%ebx
 26f:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 272:	89 f2                	mov    %esi,%edx
 274:	8d 72 ff             	lea    -0x1(%edx),%esi
 277:	85 d2                	test   %edx,%edx
 279:	7f ec                	jg     267 <memmove+0x12>
  return vdst;
}
 27b:	5b                   	pop    %ebx
 27c:	5e                   	pop    %esi
 27d:	5d                   	pop    %ebp
 27e:	c3                   	ret    

0000027f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27f:	b8 01 00 00 00       	mov    $0x1,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <exit>:
SYSCALL(exit)
 287:	b8 02 00 00 00       	mov    $0x2,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <wait>:
SYSCALL(wait)
 28f:	b8 03 00 00 00       	mov    $0x3,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <pipe>:
SYSCALL(pipe)
 297:	b8 04 00 00 00       	mov    $0x4,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <read>:
SYSCALL(read)
 29f:	b8 05 00 00 00       	mov    $0x5,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <write>:
SYSCALL(write)
 2a7:	b8 10 00 00 00       	mov    $0x10,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <close>:
SYSCALL(close)
 2af:	b8 15 00 00 00       	mov    $0x15,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <kill>:
SYSCALL(kill)
 2b7:	b8 06 00 00 00       	mov    $0x6,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <exec>:
SYSCALL(exec)
 2bf:	b8 07 00 00 00       	mov    $0x7,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <open>:
SYSCALL(open)
 2c7:	b8 0f 00 00 00       	mov    $0xf,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <mknod>:
SYSCALL(mknod)
 2cf:	b8 11 00 00 00       	mov    $0x11,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <unlink>:
SYSCALL(unlink)
 2d7:	b8 12 00 00 00       	mov    $0x12,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <fstat>:
SYSCALL(fstat)
 2df:	b8 08 00 00 00       	mov    $0x8,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <link>:
SYSCALL(link)
 2e7:	b8 13 00 00 00       	mov    $0x13,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <mkdir>:
SYSCALL(mkdir)
 2ef:	b8 14 00 00 00       	mov    $0x14,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <chdir>:
SYSCALL(chdir)
 2f7:	b8 09 00 00 00       	mov    $0x9,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <dup>:
SYSCALL(dup)
 2ff:	b8 0a 00 00 00       	mov    $0xa,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <getpid>:
SYSCALL(getpid)
 307:	b8 0b 00 00 00       	mov    $0xb,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <sbrk>:
SYSCALL(sbrk)
 30f:	b8 0c 00 00 00       	mov    $0xc,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <sleep>:
SYSCALL(sleep)
 317:	b8 0d 00 00 00       	mov    $0xd,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <uptime>:
SYSCALL(uptime)
 31f:	b8 0e 00 00 00       	mov    $0xe,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 327:	55                   	push   %ebp
 328:	89 e5                	mov    %esp,%ebp
 32a:	83 ec 1c             	sub    $0x1c,%esp
 32d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 330:	6a 01                	push   $0x1
 332:	8d 55 f4             	lea    -0xc(%ebp),%edx
 335:	52                   	push   %edx
 336:	50                   	push   %eax
 337:	e8 6b ff ff ff       	call   2a7 <write>
}
 33c:	83 c4 10             	add    $0x10,%esp
 33f:	c9                   	leave  
 340:	c3                   	ret    

00000341 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	57                   	push   %edi
 345:	56                   	push   %esi
 346:	53                   	push   %ebx
 347:	83 ec 2c             	sub    $0x2c,%esp
 34a:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 34c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 350:	0f 95 c3             	setne  %bl
 353:	89 d0                	mov    %edx,%eax
 355:	c1 e8 1f             	shr    $0x1f,%eax
 358:	84 c3                	test   %al,%bl
 35a:	74 10                	je     36c <printint+0x2b>
    neg = 1;
    x = -xx;
 35c:	f7 da                	neg    %edx
    neg = 1;
 35e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 365:	be 00 00 00 00       	mov    $0x0,%esi
 36a:	eb 0b                	jmp    377 <printint+0x36>
  neg = 0;
 36c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 373:	eb f0                	jmp    365 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 375:	89 c6                	mov    %eax,%esi
 377:	89 d0                	mov    %edx,%eax
 379:	ba 00 00 00 00       	mov    $0x0,%edx
 37e:	f7 f1                	div    %ecx
 380:	89 c3                	mov    %eax,%ebx
 382:	8d 46 01             	lea    0x1(%esi),%eax
 385:	0f b6 92 bc 06 00 00 	movzbl 0x6bc(%edx),%edx
 38c:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 390:	89 da                	mov    %ebx,%edx
 392:	85 db                	test   %ebx,%ebx
 394:	75 df                	jne    375 <printint+0x34>
 396:	89 c3                	mov    %eax,%ebx
  if(neg)
 398:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 39c:	74 16                	je     3b4 <printint+0x73>
    buf[i++] = '-';
 39e:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3a3:	8d 5e 02             	lea    0x2(%esi),%ebx
 3a6:	eb 0c                	jmp    3b4 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3a8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3ad:	89 f8                	mov    %edi,%eax
 3af:	e8 73 ff ff ff       	call   327 <putc>
  while(--i >= 0)
 3b4:	83 eb 01             	sub    $0x1,%ebx
 3b7:	79 ef                	jns    3a8 <printint+0x67>
}
 3b9:	83 c4 2c             	add    $0x2c,%esp
 3bc:	5b                   	pop    %ebx
 3bd:	5e                   	pop    %esi
 3be:	5f                   	pop    %edi
 3bf:	5d                   	pop    %ebp
 3c0:	c3                   	ret    

000003c1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3c1:	55                   	push   %ebp
 3c2:	89 e5                	mov    %esp,%ebp
 3c4:	57                   	push   %edi
 3c5:	56                   	push   %esi
 3c6:	53                   	push   %ebx
 3c7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3ca:	8d 45 10             	lea    0x10(%ebp),%eax
 3cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3d0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3d5:	bb 00 00 00 00       	mov    $0x0,%ebx
 3da:	eb 14                	jmp    3f0 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3dc:	89 fa                	mov    %edi,%edx
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
 3e1:	e8 41 ff ff ff       	call   327 <putc>
 3e6:	eb 05                	jmp    3ed <printf+0x2c>
      }
    } else if(state == '%'){
 3e8:	83 fe 25             	cmp    $0x25,%esi
 3eb:	74 25                	je     412 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3ed:	83 c3 01             	add    $0x1,%ebx
 3f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f3:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3f7:	84 c0                	test   %al,%al
 3f9:	0f 84 23 01 00 00    	je     522 <printf+0x161>
    c = fmt[i] & 0xff;
 3ff:	0f be f8             	movsbl %al,%edi
 402:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 405:	85 f6                	test   %esi,%esi
 407:	75 df                	jne    3e8 <printf+0x27>
      if(c == '%'){
 409:	83 f8 25             	cmp    $0x25,%eax
 40c:	75 ce                	jne    3dc <printf+0x1b>
        state = '%';
 40e:	89 c6                	mov    %eax,%esi
 410:	eb db                	jmp    3ed <printf+0x2c>
      if(c == 'd'){
 412:	83 f8 64             	cmp    $0x64,%eax
 415:	74 49                	je     460 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 417:	83 f8 78             	cmp    $0x78,%eax
 41a:	0f 94 c1             	sete   %cl
 41d:	83 f8 70             	cmp    $0x70,%eax
 420:	0f 94 c2             	sete   %dl
 423:	08 d1                	or     %dl,%cl
 425:	75 63                	jne    48a <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 427:	83 f8 73             	cmp    $0x73,%eax
 42a:	0f 84 84 00 00 00    	je     4b4 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 430:	83 f8 63             	cmp    $0x63,%eax
 433:	0f 84 b7 00 00 00    	je     4f0 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 439:	83 f8 25             	cmp    $0x25,%eax
 43c:	0f 84 cc 00 00 00    	je     50e <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 442:	ba 25 00 00 00       	mov    $0x25,%edx
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	e8 d8 fe ff ff       	call   327 <putc>
        putc(fd, c);
 44f:	89 fa                	mov    %edi,%edx
 451:	8b 45 08             	mov    0x8(%ebp),%eax
 454:	e8 ce fe ff ff       	call   327 <putc>
      }
      state = 0;
 459:	be 00 00 00 00       	mov    $0x0,%esi
 45e:	eb 8d                	jmp    3ed <printf+0x2c>
        printint(fd, *ap, 10, 1);
 460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 463:	8b 17                	mov    (%edi),%edx
 465:	83 ec 0c             	sub    $0xc,%esp
 468:	6a 01                	push   $0x1
 46a:	b9 0a 00 00 00       	mov    $0xa,%ecx
 46f:	8b 45 08             	mov    0x8(%ebp),%eax
 472:	e8 ca fe ff ff       	call   341 <printint>
        ap++;
 477:	83 c7 04             	add    $0x4,%edi
 47a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 47d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 480:	be 00 00 00 00       	mov    $0x0,%esi
 485:	e9 63 ff ff ff       	jmp    3ed <printf+0x2c>
        printint(fd, *ap, 16, 0);
 48a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 48d:	8b 17                	mov    (%edi),%edx
 48f:	83 ec 0c             	sub    $0xc,%esp
 492:	6a 00                	push   $0x0
 494:	b9 10 00 00 00       	mov    $0x10,%ecx
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	e8 a0 fe ff ff       	call   341 <printint>
        ap++;
 4a1:	83 c7 04             	add    $0x4,%edi
 4a4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4a7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4aa:	be 00 00 00 00       	mov    $0x0,%esi
 4af:	e9 39 ff ff ff       	jmp    3ed <printf+0x2c>
        s = (char*)*ap;
 4b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b7:	8b 30                	mov    (%eax),%esi
        ap++;
 4b9:	83 c0 04             	add    $0x4,%eax
 4bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4bf:	85 f6                	test   %esi,%esi
 4c1:	75 28                	jne    4eb <printf+0x12a>
          s = "(null)";
 4c3:	be b4 06 00 00       	mov    $0x6b4,%esi
 4c8:	8b 7d 08             	mov    0x8(%ebp),%edi
 4cb:	eb 0d                	jmp    4da <printf+0x119>
          putc(fd, *s);
 4cd:	0f be d2             	movsbl %dl,%edx
 4d0:	89 f8                	mov    %edi,%eax
 4d2:	e8 50 fe ff ff       	call   327 <putc>
          s++;
 4d7:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4da:	0f b6 16             	movzbl (%esi),%edx
 4dd:	84 d2                	test   %dl,%dl
 4df:	75 ec                	jne    4cd <printf+0x10c>
      state = 0;
 4e1:	be 00 00 00 00       	mov    $0x0,%esi
 4e6:	e9 02 ff ff ff       	jmp    3ed <printf+0x2c>
 4eb:	8b 7d 08             	mov    0x8(%ebp),%edi
 4ee:	eb ea                	jmp    4da <printf+0x119>
        putc(fd, *ap);
 4f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f3:	0f be 17             	movsbl (%edi),%edx
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	e8 29 fe ff ff       	call   327 <putc>
        ap++;
 4fe:	83 c7 04             	add    $0x4,%edi
 501:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 504:	be 00 00 00 00       	mov    $0x0,%esi
 509:	e9 df fe ff ff       	jmp    3ed <printf+0x2c>
        putc(fd, c);
 50e:	89 fa                	mov    %edi,%edx
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	e8 0f fe ff ff       	call   327 <putc>
      state = 0;
 518:	be 00 00 00 00       	mov    $0x0,%esi
 51d:	e9 cb fe ff ff       	jmp    3ed <printf+0x2c>
    }
  }
}
 522:	8d 65 f4             	lea    -0xc(%ebp),%esp
 525:	5b                   	pop    %ebx
 526:	5e                   	pop    %esi
 527:	5f                   	pop    %edi
 528:	5d                   	pop    %ebp
 529:	c3                   	ret    

0000052a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 52a:	55                   	push   %ebp
 52b:	89 e5                	mov    %esp,%ebp
 52d:	57                   	push   %edi
 52e:	56                   	push   %esi
 52f:	53                   	push   %ebx
 530:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 533:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 536:	a1 a0 09 00 00       	mov    0x9a0,%eax
 53b:	eb 02                	jmp    53f <free+0x15>
 53d:	89 d0                	mov    %edx,%eax
 53f:	39 c8                	cmp    %ecx,%eax
 541:	73 04                	jae    547 <free+0x1d>
 543:	39 08                	cmp    %ecx,(%eax)
 545:	77 12                	ja     559 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 547:	8b 10                	mov    (%eax),%edx
 549:	39 c2                	cmp    %eax,%edx
 54b:	77 f0                	ja     53d <free+0x13>
 54d:	39 c8                	cmp    %ecx,%eax
 54f:	72 08                	jb     559 <free+0x2f>
 551:	39 ca                	cmp    %ecx,%edx
 553:	77 04                	ja     559 <free+0x2f>
 555:	89 d0                	mov    %edx,%eax
 557:	eb e6                	jmp    53f <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 559:	8b 73 fc             	mov    -0x4(%ebx),%esi
 55c:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 55f:	8b 10                	mov    (%eax),%edx
 561:	39 d7                	cmp    %edx,%edi
 563:	74 19                	je     57e <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 565:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 568:	8b 50 04             	mov    0x4(%eax),%edx
 56b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 56e:	39 ce                	cmp    %ecx,%esi
 570:	74 1b                	je     58d <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 572:	89 08                	mov    %ecx,(%eax)
  freep = p;
 574:	a3 a0 09 00 00       	mov    %eax,0x9a0
}
 579:	5b                   	pop    %ebx
 57a:	5e                   	pop    %esi
 57b:	5f                   	pop    %edi
 57c:	5d                   	pop    %ebp
 57d:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 57e:	03 72 04             	add    0x4(%edx),%esi
 581:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 584:	8b 10                	mov    (%eax),%edx
 586:	8b 12                	mov    (%edx),%edx
 588:	89 53 f8             	mov    %edx,-0x8(%ebx)
 58b:	eb db                	jmp    568 <free+0x3e>
    p->s.size += bp->s.size;
 58d:	03 53 fc             	add    -0x4(%ebx),%edx
 590:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 593:	8b 53 f8             	mov    -0x8(%ebx),%edx
 596:	89 10                	mov    %edx,(%eax)
 598:	eb da                	jmp    574 <free+0x4a>

0000059a <morecore>:

static Header*
morecore(uint nu)
{
 59a:	55                   	push   %ebp
 59b:	89 e5                	mov    %esp,%ebp
 59d:	53                   	push   %ebx
 59e:	83 ec 04             	sub    $0x4,%esp
 5a1:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5a3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5a8:	77 05                	ja     5af <morecore+0x15>
    nu = 4096;
 5aa:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5af:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5b6:	83 ec 0c             	sub    $0xc,%esp
 5b9:	50                   	push   %eax
 5ba:	e8 50 fd ff ff       	call   30f <sbrk>
  if(p == (char*)-1)
 5bf:	83 c4 10             	add    $0x10,%esp
 5c2:	83 f8 ff             	cmp    $0xffffffff,%eax
 5c5:	74 1c                	je     5e3 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5c7:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5ca:	83 c0 08             	add    $0x8,%eax
 5cd:	83 ec 0c             	sub    $0xc,%esp
 5d0:	50                   	push   %eax
 5d1:	e8 54 ff ff ff       	call   52a <free>
  return freep;
 5d6:	a1 a0 09 00 00       	mov    0x9a0,%eax
 5db:	83 c4 10             	add    $0x10,%esp
}
 5de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5e1:	c9                   	leave  
 5e2:	c3                   	ret    
    return 0;
 5e3:	b8 00 00 00 00       	mov    $0x0,%eax
 5e8:	eb f4                	jmp    5de <morecore+0x44>

000005ea <malloc>:

void*
malloc(uint nbytes)
{
 5ea:	55                   	push   %ebp
 5eb:	89 e5                	mov    %esp,%ebp
 5ed:	53                   	push   %ebx
 5ee:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5f1:	8b 45 08             	mov    0x8(%ebp),%eax
 5f4:	8d 58 07             	lea    0x7(%eax),%ebx
 5f7:	c1 eb 03             	shr    $0x3,%ebx
 5fa:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5fd:	8b 0d a0 09 00 00    	mov    0x9a0,%ecx
 603:	85 c9                	test   %ecx,%ecx
 605:	74 04                	je     60b <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 607:	8b 01                	mov    (%ecx),%eax
 609:	eb 4d                	jmp    658 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 60b:	c7 05 a0 09 00 00 a4 	movl   $0x9a4,0x9a0
 612:	09 00 00 
 615:	c7 05 a4 09 00 00 a4 	movl   $0x9a4,0x9a4
 61c:	09 00 00 
    base.s.size = 0;
 61f:	c7 05 a8 09 00 00 00 	movl   $0x0,0x9a8
 626:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 629:	b9 a4 09 00 00       	mov    $0x9a4,%ecx
 62e:	eb d7                	jmp    607 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 630:	39 da                	cmp    %ebx,%edx
 632:	74 1a                	je     64e <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 634:	29 da                	sub    %ebx,%edx
 636:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 639:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 63c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 63f:	89 0d a0 09 00 00    	mov    %ecx,0x9a0
      return (void*)(p + 1);
 645:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 648:	83 c4 04             	add    $0x4,%esp
 64b:	5b                   	pop    %ebx
 64c:	5d                   	pop    %ebp
 64d:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 64e:	8b 10                	mov    (%eax),%edx
 650:	89 11                	mov    %edx,(%ecx)
 652:	eb eb                	jmp    63f <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 654:	89 c1                	mov    %eax,%ecx
 656:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 658:	8b 50 04             	mov    0x4(%eax),%edx
 65b:	39 da                	cmp    %ebx,%edx
 65d:	73 d1                	jae    630 <malloc+0x46>
    if(p == freep)
 65f:	39 05 a0 09 00 00    	cmp    %eax,0x9a0
 665:	75 ed                	jne    654 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 667:	89 d8                	mov    %ebx,%eax
 669:	e8 2c ff ff ff       	call   59a <morecore>
 66e:	85 c0                	test   %eax,%eax
 670:	75 e2                	jne    654 <malloc+0x6a>
        return 0;
 672:	b8 00 00 00 00       	mov    $0x0,%eax
 677:	eb cf                	jmp    648 <malloc+0x5e>
