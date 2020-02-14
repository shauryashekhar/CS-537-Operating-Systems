
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 1c             	sub    $0x1c,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
   9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  l = w = c = 0;
  10:	be 00 00 00 00       	mov    $0x0,%esi
  15:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  23:	83 ec 04             	sub    $0x4,%esp
  26:	68 00 02 00 00       	push   $0x200
  2b:	68 20 0a 00 00       	push   $0xa20
  30:	ff 75 08             	pushl  0x8(%ebp)
  33:	e8 d1 02 00 00       	call   309 <read>
  38:	89 c7                	mov    %eax,%edi
  3a:	83 c4 10             	add    $0x10,%esp
  3d:	85 c0                	test   %eax,%eax
  3f:	7e 54                	jle    95 <wc+0x95>
    for(i=0; i<n; i++){
  41:	bb 00 00 00 00       	mov    $0x0,%ebx
  46:	eb 22                	jmp    6a <wc+0x6a>
      c++;
      if(buf[i] == '\n')
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  48:	83 ec 08             	sub    $0x8,%esp
  4b:	0f be c0             	movsbl %al,%eax
  4e:	50                   	push   %eax
  4f:	68 ec 06 00 00       	push   $0x6ec
  54:	e8 80 01 00 00       	call   1d9 <strchr>
  59:	83 c4 10             	add    $0x10,%esp
  5c:	85 c0                	test   %eax,%eax
  5e:	74 22                	je     82 <wc+0x82>
        inword = 0;
  60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    for(i=0; i<n; i++){
  67:	83 c3 01             	add    $0x1,%ebx
  6a:	39 fb                	cmp    %edi,%ebx
  6c:	7d b5                	jge    23 <wc+0x23>
      c++;
  6e:	83 c6 01             	add    $0x1,%esi
      if(buf[i] == '\n')
  71:	0f b6 83 20 0a 00 00 	movzbl 0xa20(%ebx),%eax
  78:	3c 0a                	cmp    $0xa,%al
  7a:	75 cc                	jne    48 <wc+0x48>
        l++;
  7c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80:	eb c6                	jmp    48 <wc+0x48>
      else if(!inword){
  82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  86:	75 df                	jne    67 <wc+0x67>
        w++;
  88:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
        inword = 1;
  8c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  93:	eb d2                	jmp    67 <wc+0x67>
      }
    }
  }
  if(n < 0){
  95:	85 c0                	test   %eax,%eax
  97:	78 24                	js     bd <wc+0xbd>
    printf(1, "wc: read error\n");
    exit();
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  99:	83 ec 08             	sub    $0x8,%esp
  9c:	ff 75 0c             	pushl  0xc(%ebp)
  9f:	56                   	push   %esi
  a0:	ff 75 dc             	pushl  -0x24(%ebp)
  a3:	ff 75 e0             	pushl  -0x20(%ebp)
  a6:	68 02 07 00 00       	push   $0x702
  ab:	6a 01                	push   $0x1
  ad:	e8 81 03 00 00       	call   433 <printf>
}
  b2:	83 c4 20             	add    $0x20,%esp
  b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  b8:	5b                   	pop    %ebx
  b9:	5e                   	pop    %esi
  ba:	5f                   	pop    %edi
  bb:	5d                   	pop    %ebp
  bc:	c3                   	ret    
    printf(1, "wc: read error\n");
  bd:	83 ec 08             	sub    $0x8,%esp
  c0:	68 f2 06 00 00       	push   $0x6f2
  c5:	6a 01                	push   $0x1
  c7:	e8 67 03 00 00       	call   433 <printf>
    exit();
  cc:	e8 20 02 00 00       	call   2f1 <exit>

000000d1 <main>:

int
main(int argc, char *argv[])
{
  d1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  d5:	83 e4 f0             	and    $0xfffffff0,%esp
  d8:	ff 71 fc             	pushl  -0x4(%ecx)
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  de:	57                   	push   %edi
  df:	56                   	push   %esi
  e0:	53                   	push   %ebx
  e1:	51                   	push   %ecx
  e2:	83 ec 18             	sub    $0x18,%esp
  e5:	8b 01                	mov    (%ecx),%eax
  e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  ea:	8b 51 04             	mov    0x4(%ecx),%edx
  ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int fd, i;

  if(argc <= 1){
  f0:	83 f8 01             	cmp    $0x1,%eax
  f3:	7e 40                	jle    135 <main+0x64>
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
  f5:	bb 01 00 00 00       	mov    $0x1,%ebx
  fa:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  fd:	7d 60                	jge    15f <main+0x8e>
    if((fd = open(argv[i], 0)) < 0){
  ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
 102:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 105:	83 ec 08             	sub    $0x8,%esp
 108:	6a 00                	push   $0x0
 10a:	ff 37                	pushl  (%edi)
 10c:	e8 20 02 00 00       	call   331 <open>
 111:	89 c6                	mov    %eax,%esi
 113:	83 c4 10             	add    $0x10,%esp
 116:	85 c0                	test   %eax,%eax
 118:	78 2f                	js     149 <main+0x78>
      printf(1, "wc: cannot open %s\n", argv[i]);
      exit();
    }
    wc(fd, argv[i]);
 11a:	83 ec 08             	sub    $0x8,%esp
 11d:	ff 37                	pushl  (%edi)
 11f:	50                   	push   %eax
 120:	e8 db fe ff ff       	call   0 <wc>
    close(fd);
 125:	89 34 24             	mov    %esi,(%esp)
 128:	e8 ec 01 00 00       	call   319 <close>
  for(i = 1; i < argc; i++){
 12d:	83 c3 01             	add    $0x1,%ebx
 130:	83 c4 10             	add    $0x10,%esp
 133:	eb c5                	jmp    fa <main+0x29>
    wc(0, "");
 135:	83 ec 08             	sub    $0x8,%esp
 138:	68 01 07 00 00       	push   $0x701
 13d:	6a 00                	push   $0x0
 13f:	e8 bc fe ff ff       	call   0 <wc>
    exit();
 144:	e8 a8 01 00 00       	call   2f1 <exit>
      printf(1, "wc: cannot open %s\n", argv[i]);
 149:	83 ec 04             	sub    $0x4,%esp
 14c:	ff 37                	pushl  (%edi)
 14e:	68 0f 07 00 00       	push   $0x70f
 153:	6a 01                	push   $0x1
 155:	e8 d9 02 00 00       	call   433 <printf>
      exit();
 15a:	e8 92 01 00 00       	call   2f1 <exit>
  }
  exit();
 15f:	e8 8d 01 00 00       	call   2f1 <exit>

00000164 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	53                   	push   %ebx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16e:	89 c2                	mov    %eax,%edx
 170:	0f b6 19             	movzbl (%ecx),%ebx
 173:	88 1a                	mov    %bl,(%edx)
 175:	8d 52 01             	lea    0x1(%edx),%edx
 178:	8d 49 01             	lea    0x1(%ecx),%ecx
 17b:	84 db                	test   %bl,%bl
 17d:	75 f1                	jne    170 <strcpy+0xc>
    ;
  return os;
}
 17f:	5b                   	pop    %ebx
 180:	5d                   	pop    %ebp
 181:	c3                   	ret    

00000182 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 182:	55                   	push   %ebp
 183:	89 e5                	mov    %esp,%ebp
 185:	8b 4d 08             	mov    0x8(%ebp),%ecx
 188:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 18b:	eb 06                	jmp    193 <strcmp+0x11>
    p++, q++;
 18d:	83 c1 01             	add    $0x1,%ecx
 190:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 193:	0f b6 01             	movzbl (%ecx),%eax
 196:	84 c0                	test   %al,%al
 198:	74 04                	je     19e <strcmp+0x1c>
 19a:	3a 02                	cmp    (%edx),%al
 19c:	74 ef                	je     18d <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 19e:	0f b6 c0             	movzbl %al,%eax
 1a1:	0f b6 12             	movzbl (%edx),%edx
 1a4:	29 d0                	sub    %edx,%eax
}
 1a6:	5d                   	pop    %ebp
 1a7:	c3                   	ret    

000001a8 <strlen>:

uint
strlen(const char *s)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1ae:	ba 00 00 00 00       	mov    $0x0,%edx
 1b3:	eb 03                	jmp    1b8 <strlen+0x10>
 1b5:	83 c2 01             	add    $0x1,%edx
 1b8:	89 d0                	mov    %edx,%eax
 1ba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1be:	75 f5                	jne    1b5 <strlen+0xd>
    ;
  return n;
}
 1c0:	5d                   	pop    %ebp
 1c1:	c3                   	ret    

000001c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	57                   	push   %edi
 1c6:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1c9:	89 d7                	mov    %edx,%edi
 1cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d1:	fc                   	cld    
 1d2:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1d4:	89 d0                	mov    %edx,%eax
 1d6:	5f                   	pop    %edi
 1d7:	5d                   	pop    %ebp
 1d8:	c3                   	ret    

000001d9 <strchr>:

char*
strchr(const char *s, char c)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1e3:	0f b6 10             	movzbl (%eax),%edx
 1e6:	84 d2                	test   %dl,%dl
 1e8:	74 09                	je     1f3 <strchr+0x1a>
    if(*s == c)
 1ea:	38 ca                	cmp    %cl,%dl
 1ec:	74 0a                	je     1f8 <strchr+0x1f>
  for(; *s; s++)
 1ee:	83 c0 01             	add    $0x1,%eax
 1f1:	eb f0                	jmp    1e3 <strchr+0xa>
      return (char*)s;
  return 0;
 1f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f8:	5d                   	pop    %ebp
 1f9:	c3                   	ret    

000001fa <gets>:

char*
gets(char *buf, int max)
{
 1fa:	55                   	push   %ebp
 1fb:	89 e5                	mov    %esp,%ebp
 1fd:	57                   	push   %edi
 1fe:	56                   	push   %esi
 1ff:	53                   	push   %ebx
 200:	83 ec 1c             	sub    $0x1c,%esp
 203:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 206:	bb 00 00 00 00       	mov    $0x0,%ebx
 20b:	8d 73 01             	lea    0x1(%ebx),%esi
 20e:	3b 75 0c             	cmp    0xc(%ebp),%esi
 211:	7d 2e                	jge    241 <gets+0x47>
    cc = read(0, &c, 1);
 213:	83 ec 04             	sub    $0x4,%esp
 216:	6a 01                	push   $0x1
 218:	8d 45 e7             	lea    -0x19(%ebp),%eax
 21b:	50                   	push   %eax
 21c:	6a 00                	push   $0x0
 21e:	e8 e6 00 00 00       	call   309 <read>
    if(cc < 1)
 223:	83 c4 10             	add    $0x10,%esp
 226:	85 c0                	test   %eax,%eax
 228:	7e 17                	jle    241 <gets+0x47>
      break;
    buf[i++] = c;
 22a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 22e:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 231:	3c 0a                	cmp    $0xa,%al
 233:	0f 94 c2             	sete   %dl
 236:	3c 0d                	cmp    $0xd,%al
 238:	0f 94 c0             	sete   %al
    buf[i++] = c;
 23b:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 23d:	08 c2                	or     %al,%dl
 23f:	74 ca                	je     20b <gets+0x11>
      break;
  }
  buf[i] = '\0';
 241:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 245:	89 f8                	mov    %edi,%eax
 247:	8d 65 f4             	lea    -0xc(%ebp),%esp
 24a:	5b                   	pop    %ebx
 24b:	5e                   	pop    %esi
 24c:	5f                   	pop    %edi
 24d:	5d                   	pop    %ebp
 24e:	c3                   	ret    

0000024f <stat>:

int
stat(const char *n, struct stat *st)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	56                   	push   %esi
 253:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 254:	83 ec 08             	sub    $0x8,%esp
 257:	6a 00                	push   $0x0
 259:	ff 75 08             	pushl  0x8(%ebp)
 25c:	e8 d0 00 00 00       	call   331 <open>
  if(fd < 0)
 261:	83 c4 10             	add    $0x10,%esp
 264:	85 c0                	test   %eax,%eax
 266:	78 24                	js     28c <stat+0x3d>
 268:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 26a:	83 ec 08             	sub    $0x8,%esp
 26d:	ff 75 0c             	pushl  0xc(%ebp)
 270:	50                   	push   %eax
 271:	e8 d3 00 00 00       	call   349 <fstat>
 276:	89 c6                	mov    %eax,%esi
  close(fd);
 278:	89 1c 24             	mov    %ebx,(%esp)
 27b:	e8 99 00 00 00       	call   319 <close>
  return r;
 280:	83 c4 10             	add    $0x10,%esp
}
 283:	89 f0                	mov    %esi,%eax
 285:	8d 65 f8             	lea    -0x8(%ebp),%esp
 288:	5b                   	pop    %ebx
 289:	5e                   	pop    %esi
 28a:	5d                   	pop    %ebp
 28b:	c3                   	ret    
    return -1;
 28c:	be ff ff ff ff       	mov    $0xffffffff,%esi
 291:	eb f0                	jmp    283 <stat+0x34>

00000293 <atoi>:

int
atoi(const char *s)
{
 293:	55                   	push   %ebp
 294:	89 e5                	mov    %esp,%ebp
 296:	53                   	push   %ebx
 297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 29a:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 29f:	eb 10                	jmp    2b1 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 2a1:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 2a4:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 2a7:	83 c1 01             	add    $0x1,%ecx
 2aa:	0f be d2             	movsbl %dl,%edx
 2ad:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 2b1:	0f b6 11             	movzbl (%ecx),%edx
 2b4:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2b7:	80 fb 09             	cmp    $0x9,%bl
 2ba:	76 e5                	jbe    2a1 <atoi+0xe>
  return n;
}
 2bc:	5b                   	pop    %ebx
 2bd:	5d                   	pop    %ebp
 2be:	c3                   	ret    

000002bf <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	56                   	push   %esi
 2c3:	53                   	push   %ebx
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2ca:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2cd:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2cf:	eb 0d                	jmp    2de <memmove+0x1f>
    *dst++ = *src++;
 2d1:	0f b6 13             	movzbl (%ebx),%edx
 2d4:	88 11                	mov    %dl,(%ecx)
 2d6:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2d9:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2dc:	89 f2                	mov    %esi,%edx
 2de:	8d 72 ff             	lea    -0x1(%edx),%esi
 2e1:	85 d2                	test   %edx,%edx
 2e3:	7f ec                	jg     2d1 <memmove+0x12>
  return vdst;
}
 2e5:	5b                   	pop    %ebx
 2e6:	5e                   	pop    %esi
 2e7:	5d                   	pop    %ebp
 2e8:	c3                   	ret    

000002e9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e9:	b8 01 00 00 00       	mov    $0x1,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <exit>:
SYSCALL(exit)
 2f1:	b8 02 00 00 00       	mov    $0x2,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <wait>:
SYSCALL(wait)
 2f9:	b8 03 00 00 00       	mov    $0x3,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <pipe>:
SYSCALL(pipe)
 301:	b8 04 00 00 00       	mov    $0x4,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <read>:
SYSCALL(read)
 309:	b8 05 00 00 00       	mov    $0x5,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <write>:
SYSCALL(write)
 311:	b8 10 00 00 00       	mov    $0x10,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <close>:
SYSCALL(close)
 319:	b8 15 00 00 00       	mov    $0x15,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <kill>:
SYSCALL(kill)
 321:	b8 06 00 00 00       	mov    $0x6,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <exec>:
SYSCALL(exec)
 329:	b8 07 00 00 00       	mov    $0x7,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <open>:
SYSCALL(open)
 331:	b8 0f 00 00 00       	mov    $0xf,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <mknod>:
SYSCALL(mknod)
 339:	b8 11 00 00 00       	mov    $0x11,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <unlink>:
SYSCALL(unlink)
 341:	b8 12 00 00 00       	mov    $0x12,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <fstat>:
SYSCALL(fstat)
 349:	b8 08 00 00 00       	mov    $0x8,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <link>:
SYSCALL(link)
 351:	b8 13 00 00 00       	mov    $0x13,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <mkdir>:
SYSCALL(mkdir)
 359:	b8 14 00 00 00       	mov    $0x14,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <chdir>:
SYSCALL(chdir)
 361:	b8 09 00 00 00       	mov    $0x9,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <dup>:
SYSCALL(dup)
 369:	b8 0a 00 00 00       	mov    $0xa,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <getpid>:
SYSCALL(getpid)
 371:	b8 0b 00 00 00       	mov    $0xb,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <sbrk>:
SYSCALL(sbrk)
 379:	b8 0c 00 00 00       	mov    $0xc,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <sleep>:
SYSCALL(sleep)
 381:	b8 0d 00 00 00       	mov    $0xd,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <uptime>:
SYSCALL(uptime)
 389:	b8 0e 00 00 00       	mov    $0xe,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <dump_physmem>:
SYSCALL(dump_physmem)
 391:	b8 16 00 00 00       	mov    $0x16,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 399:	55                   	push   %ebp
 39a:	89 e5                	mov    %esp,%ebp
 39c:	83 ec 1c             	sub    $0x1c,%esp
 39f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3a2:	6a 01                	push   $0x1
 3a4:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3a7:	52                   	push   %edx
 3a8:	50                   	push   %eax
 3a9:	e8 63 ff ff ff       	call   311 <write>
}
 3ae:	83 c4 10             	add    $0x10,%esp
 3b1:	c9                   	leave  
 3b2:	c3                   	ret    

000003b3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b3:	55                   	push   %ebp
 3b4:	89 e5                	mov    %esp,%ebp
 3b6:	57                   	push   %edi
 3b7:	56                   	push   %esi
 3b8:	53                   	push   %ebx
 3b9:	83 ec 2c             	sub    $0x2c,%esp
 3bc:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3c2:	0f 95 c3             	setne  %bl
 3c5:	89 d0                	mov    %edx,%eax
 3c7:	c1 e8 1f             	shr    $0x1f,%eax
 3ca:	84 c3                	test   %al,%bl
 3cc:	74 10                	je     3de <printint+0x2b>
    neg = 1;
    x = -xx;
 3ce:	f7 da                	neg    %edx
    neg = 1;
 3d0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3d7:	be 00 00 00 00       	mov    $0x0,%esi
 3dc:	eb 0b                	jmp    3e9 <printint+0x36>
  neg = 0;
 3de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3e5:	eb f0                	jmp    3d7 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3e7:	89 c6                	mov    %eax,%esi
 3e9:	89 d0                	mov    %edx,%eax
 3eb:	ba 00 00 00 00       	mov    $0x0,%edx
 3f0:	f7 f1                	div    %ecx
 3f2:	89 c3                	mov    %eax,%ebx
 3f4:	8d 46 01             	lea    0x1(%esi),%eax
 3f7:	0f b6 92 2c 07 00 00 	movzbl 0x72c(%edx),%edx
 3fe:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 402:	89 da                	mov    %ebx,%edx
 404:	85 db                	test   %ebx,%ebx
 406:	75 df                	jne    3e7 <printint+0x34>
 408:	89 c3                	mov    %eax,%ebx
  if(neg)
 40a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 40e:	74 16                	je     426 <printint+0x73>
    buf[i++] = '-';
 410:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 415:	8d 5e 02             	lea    0x2(%esi),%ebx
 418:	eb 0c                	jmp    426 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 41a:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 41f:	89 f8                	mov    %edi,%eax
 421:	e8 73 ff ff ff       	call   399 <putc>
  while(--i >= 0)
 426:	83 eb 01             	sub    $0x1,%ebx
 429:	79 ef                	jns    41a <printint+0x67>
}
 42b:	83 c4 2c             	add    $0x2c,%esp
 42e:	5b                   	pop    %ebx
 42f:	5e                   	pop    %esi
 430:	5f                   	pop    %edi
 431:	5d                   	pop    %ebp
 432:	c3                   	ret    

00000433 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	57                   	push   %edi
 437:	56                   	push   %esi
 438:	53                   	push   %ebx
 439:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 43c:	8d 45 10             	lea    0x10(%ebp),%eax
 43f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 442:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 447:	bb 00 00 00 00       	mov    $0x0,%ebx
 44c:	eb 14                	jmp    462 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 44e:	89 fa                	mov    %edi,%edx
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	e8 41 ff ff ff       	call   399 <putc>
 458:	eb 05                	jmp    45f <printf+0x2c>
      }
    } else if(state == '%'){
 45a:	83 fe 25             	cmp    $0x25,%esi
 45d:	74 25                	je     484 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 45f:	83 c3 01             	add    $0x1,%ebx
 462:	8b 45 0c             	mov    0xc(%ebp),%eax
 465:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 469:	84 c0                	test   %al,%al
 46b:	0f 84 23 01 00 00    	je     594 <printf+0x161>
    c = fmt[i] & 0xff;
 471:	0f be f8             	movsbl %al,%edi
 474:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 477:	85 f6                	test   %esi,%esi
 479:	75 df                	jne    45a <printf+0x27>
      if(c == '%'){
 47b:	83 f8 25             	cmp    $0x25,%eax
 47e:	75 ce                	jne    44e <printf+0x1b>
        state = '%';
 480:	89 c6                	mov    %eax,%esi
 482:	eb db                	jmp    45f <printf+0x2c>
      if(c == 'd'){
 484:	83 f8 64             	cmp    $0x64,%eax
 487:	74 49                	je     4d2 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 489:	83 f8 78             	cmp    $0x78,%eax
 48c:	0f 94 c1             	sete   %cl
 48f:	83 f8 70             	cmp    $0x70,%eax
 492:	0f 94 c2             	sete   %dl
 495:	08 d1                	or     %dl,%cl
 497:	75 63                	jne    4fc <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 499:	83 f8 73             	cmp    $0x73,%eax
 49c:	0f 84 84 00 00 00    	je     526 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4a2:	83 f8 63             	cmp    $0x63,%eax
 4a5:	0f 84 b7 00 00 00    	je     562 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4ab:	83 f8 25             	cmp    $0x25,%eax
 4ae:	0f 84 cc 00 00 00    	je     580 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4b4:	ba 25 00 00 00       	mov    $0x25,%edx
 4b9:	8b 45 08             	mov    0x8(%ebp),%eax
 4bc:	e8 d8 fe ff ff       	call   399 <putc>
        putc(fd, c);
 4c1:	89 fa                	mov    %edi,%edx
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	e8 ce fe ff ff       	call   399 <putc>
      }
      state = 0;
 4cb:	be 00 00 00 00       	mov    $0x0,%esi
 4d0:	eb 8d                	jmp    45f <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4d5:	8b 17                	mov    (%edi),%edx
 4d7:	83 ec 0c             	sub    $0xc,%esp
 4da:	6a 01                	push   $0x1
 4dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	e8 ca fe ff ff       	call   3b3 <printint>
        ap++;
 4e9:	83 c7 04             	add    $0x4,%edi
 4ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4ef:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4f2:	be 00 00 00 00       	mov    $0x0,%esi
 4f7:	e9 63 ff ff ff       	jmp    45f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ff:	8b 17                	mov    (%edi),%edx
 501:	83 ec 0c             	sub    $0xc,%esp
 504:	6a 00                	push   $0x0
 506:	b9 10 00 00 00       	mov    $0x10,%ecx
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	e8 a0 fe ff ff       	call   3b3 <printint>
        ap++;
 513:	83 c7 04             	add    $0x4,%edi
 516:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 519:	83 c4 10             	add    $0x10,%esp
      state = 0;
 51c:	be 00 00 00 00       	mov    $0x0,%esi
 521:	e9 39 ff ff ff       	jmp    45f <printf+0x2c>
        s = (char*)*ap;
 526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 529:	8b 30                	mov    (%eax),%esi
        ap++;
 52b:	83 c0 04             	add    $0x4,%eax
 52e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 531:	85 f6                	test   %esi,%esi
 533:	75 28                	jne    55d <printf+0x12a>
          s = "(null)";
 535:	be 23 07 00 00       	mov    $0x723,%esi
 53a:	8b 7d 08             	mov    0x8(%ebp),%edi
 53d:	eb 0d                	jmp    54c <printf+0x119>
          putc(fd, *s);
 53f:	0f be d2             	movsbl %dl,%edx
 542:	89 f8                	mov    %edi,%eax
 544:	e8 50 fe ff ff       	call   399 <putc>
          s++;
 549:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 54c:	0f b6 16             	movzbl (%esi),%edx
 54f:	84 d2                	test   %dl,%dl
 551:	75 ec                	jne    53f <printf+0x10c>
      state = 0;
 553:	be 00 00 00 00       	mov    $0x0,%esi
 558:	e9 02 ff ff ff       	jmp    45f <printf+0x2c>
 55d:	8b 7d 08             	mov    0x8(%ebp),%edi
 560:	eb ea                	jmp    54c <printf+0x119>
        putc(fd, *ap);
 562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 565:	0f be 17             	movsbl (%edi),%edx
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	e8 29 fe ff ff       	call   399 <putc>
        ap++;
 570:	83 c7 04             	add    $0x4,%edi
 573:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 576:	be 00 00 00 00       	mov    $0x0,%esi
 57b:	e9 df fe ff ff       	jmp    45f <printf+0x2c>
        putc(fd, c);
 580:	89 fa                	mov    %edi,%edx
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	e8 0f fe ff ff       	call   399 <putc>
      state = 0;
 58a:	be 00 00 00 00       	mov    $0x0,%esi
 58f:	e9 cb fe ff ff       	jmp    45f <printf+0x2c>
    }
  }
}
 594:	8d 65 f4             	lea    -0xc(%ebp),%esp
 597:	5b                   	pop    %ebx
 598:	5e                   	pop    %esi
 599:	5f                   	pop    %edi
 59a:	5d                   	pop    %ebp
 59b:	c3                   	ret    

0000059c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 59c:	55                   	push   %ebp
 59d:	89 e5                	mov    %esp,%ebp
 59f:	57                   	push   %edi
 5a0:	56                   	push   %esi
 5a1:	53                   	push   %ebx
 5a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5a5:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a8:	a1 00 0a 00 00       	mov    0xa00,%eax
 5ad:	eb 02                	jmp    5b1 <free+0x15>
 5af:	89 d0                	mov    %edx,%eax
 5b1:	39 c8                	cmp    %ecx,%eax
 5b3:	73 04                	jae    5b9 <free+0x1d>
 5b5:	39 08                	cmp    %ecx,(%eax)
 5b7:	77 12                	ja     5cb <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b9:	8b 10                	mov    (%eax),%edx
 5bb:	39 c2                	cmp    %eax,%edx
 5bd:	77 f0                	ja     5af <free+0x13>
 5bf:	39 c8                	cmp    %ecx,%eax
 5c1:	72 08                	jb     5cb <free+0x2f>
 5c3:	39 ca                	cmp    %ecx,%edx
 5c5:	77 04                	ja     5cb <free+0x2f>
 5c7:	89 d0                	mov    %edx,%eax
 5c9:	eb e6                	jmp    5b1 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5cb:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5ce:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5d1:	8b 10                	mov    (%eax),%edx
 5d3:	39 d7                	cmp    %edx,%edi
 5d5:	74 19                	je     5f0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5d7:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5da:	8b 50 04             	mov    0x4(%eax),%edx
 5dd:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5e0:	39 ce                	cmp    %ecx,%esi
 5e2:	74 1b                	je     5ff <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5e4:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5e6:	a3 00 0a 00 00       	mov    %eax,0xa00
}
 5eb:	5b                   	pop    %ebx
 5ec:	5e                   	pop    %esi
 5ed:	5f                   	pop    %edi
 5ee:	5d                   	pop    %ebp
 5ef:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5f0:	03 72 04             	add    0x4(%edx),%esi
 5f3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5f6:	8b 10                	mov    (%eax),%edx
 5f8:	8b 12                	mov    (%edx),%edx
 5fa:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5fd:	eb db                	jmp    5da <free+0x3e>
    p->s.size += bp->s.size;
 5ff:	03 53 fc             	add    -0x4(%ebx),%edx
 602:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 605:	8b 53 f8             	mov    -0x8(%ebx),%edx
 608:	89 10                	mov    %edx,(%eax)
 60a:	eb da                	jmp    5e6 <free+0x4a>

0000060c <morecore>:

static Header*
morecore(uint nu)
{
 60c:	55                   	push   %ebp
 60d:	89 e5                	mov    %esp,%ebp
 60f:	53                   	push   %ebx
 610:	83 ec 04             	sub    $0x4,%esp
 613:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 615:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 61a:	77 05                	ja     621 <morecore+0x15>
    nu = 4096;
 61c:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 621:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 628:	83 ec 0c             	sub    $0xc,%esp
 62b:	50                   	push   %eax
 62c:	e8 48 fd ff ff       	call   379 <sbrk>
  if(p == (char*)-1)
 631:	83 c4 10             	add    $0x10,%esp
 634:	83 f8 ff             	cmp    $0xffffffff,%eax
 637:	74 1c                	je     655 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 639:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 63c:	83 c0 08             	add    $0x8,%eax
 63f:	83 ec 0c             	sub    $0xc,%esp
 642:	50                   	push   %eax
 643:	e8 54 ff ff ff       	call   59c <free>
  return freep;
 648:	a1 00 0a 00 00       	mov    0xa00,%eax
 64d:	83 c4 10             	add    $0x10,%esp
}
 650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 653:	c9                   	leave  
 654:	c3                   	ret    
    return 0;
 655:	b8 00 00 00 00       	mov    $0x0,%eax
 65a:	eb f4                	jmp    650 <morecore+0x44>

0000065c <malloc>:

void*
malloc(uint nbytes)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	53                   	push   %ebx
 660:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	8d 58 07             	lea    0x7(%eax),%ebx
 669:	c1 eb 03             	shr    $0x3,%ebx
 66c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 66f:	8b 0d 00 0a 00 00    	mov    0xa00,%ecx
 675:	85 c9                	test   %ecx,%ecx
 677:	74 04                	je     67d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 679:	8b 01                	mov    (%ecx),%eax
 67b:	eb 4d                	jmp    6ca <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 67d:	c7 05 00 0a 00 00 04 	movl   $0xa04,0xa00
 684:	0a 00 00 
 687:	c7 05 04 0a 00 00 04 	movl   $0xa04,0xa04
 68e:	0a 00 00 
    base.s.size = 0;
 691:	c7 05 08 0a 00 00 00 	movl   $0x0,0xa08
 698:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 69b:	b9 04 0a 00 00       	mov    $0xa04,%ecx
 6a0:	eb d7                	jmp    679 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6a2:	39 da                	cmp    %ebx,%edx
 6a4:	74 1a                	je     6c0 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6a6:	29 da                	sub    %ebx,%edx
 6a8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6ab:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6ae:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6b1:	89 0d 00 0a 00 00    	mov    %ecx,0xa00
      return (void*)(p + 1);
 6b7:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6ba:	83 c4 04             	add    $0x4,%esp
 6bd:	5b                   	pop    %ebx
 6be:	5d                   	pop    %ebp
 6bf:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6c0:	8b 10                	mov    (%eax),%edx
 6c2:	89 11                	mov    %edx,(%ecx)
 6c4:	eb eb                	jmp    6b1 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6c6:	89 c1                	mov    %eax,%ecx
 6c8:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6ca:	8b 50 04             	mov    0x4(%eax),%edx
 6cd:	39 da                	cmp    %ebx,%edx
 6cf:	73 d1                	jae    6a2 <malloc+0x46>
    if(p == freep)
 6d1:	39 05 00 0a 00 00    	cmp    %eax,0xa00
 6d7:	75 ed                	jne    6c6 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6d9:	89 d8                	mov    %ebx,%eax
 6db:	e8 2c ff ff ff       	call   60c <morecore>
 6e0:	85 c0                	test   %eax,%eax
 6e2:	75 e2                	jne    6c6 <malloc+0x6a>
        return 0;
 6e4:	b8 00 00 00 00       	mov    $0x0,%eax
 6e9:	eb cf                	jmp    6ba <malloc+0x5e>
