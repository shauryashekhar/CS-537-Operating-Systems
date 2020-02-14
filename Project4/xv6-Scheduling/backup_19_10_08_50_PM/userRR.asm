
_userRR:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"
#include "fcntl.h"
char *argvv[] = { "loop", 0 };
int main(int argc , char **argv)
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
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 79 04             	mov    0x4(%ecx),%edi
	if(argc != 5){
  17:	83 39 05             	cmpl   $0x5,(%ecx)
  1a:	74 14                	je     30 <main+0x30>
	   printf(2, "Wrong number of argument\n");
  1c:	83 ec 08             	sub    $0x8,%esp
  1f:	68 a0 06 00 00       	push   $0x6a0
  24:	6a 02                	push   $0x2
  26:	e8 bc 03 00 00       	call   3e7 <printf>
	   exit();
  2b:	e8 5d 02 00 00       	call   28d <exit>
	 }
	int pid = getpid();
  30:	e8 d8 02 00 00       	call   30d <getpid>
  35:	89 c3                	mov    %eax,%ebx
	printf(2, "Setting pid :%d\n",pid);
  37:	83 ec 04             	sub    $0x4,%esp
  3a:	50                   	push   %eax
  3b:	68 ba 06 00 00       	push   $0x6ba
  40:	6a 02                	push   $0x2
  42:	e8 a0 03 00 00       	call   3e7 <printf>
	setpri(pid,0);
  47:	83 c4 08             	add    $0x8,%esp
  4a:	6a 00                	push   $0x0
  4c:	53                   	push   %ebx
  4d:	e8 db 02 00 00       	call   32d <setpri>
        printf(1,"%d\n", getpri(pid));
  52:	89 1c 24             	mov    %ebx,(%esp)
  55:	e8 db 02 00 00       	call   335 <getpri>
  5a:	83 c4 0c             	add    $0xc,%esp
  5d:	50                   	push   %eax
  5e:	68 db 06 00 00       	push   $0x6db
  63:	6a 01                	push   $0x1
  65:	e8 7d 03 00 00       	call   3e7 <printf>
	//char *localArg[1];
	//localArg[0]= "";
	//arg[1]= "3";
	//int jc = 1;
	for(int it = 0 ; it < *argv[2]; it++) {
  6a:	83 c4 10             	add    $0x10,%esp
  6d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  74:	eb 63                	jmp    d9 <main+0xd9>
	       {
		    if(exec("loop", argvv) == -1)
		    {
			  printf(1,"Error\n");
		    }
		    setpri(c_pid,1);
  76:	83 ec 08             	sub    $0x8,%esp
  79:	6a 01                	push   $0x1
  7b:	53                   	push   %ebx
  7c:	e8 ac 02 00 00       	call   32d <setpri>
		    printf(1,"%d, %d\n",c_pid,getpri(c_pid)); 
  81:	89 1c 24             	mov    %ebx,(%esp)
  84:	e8 ac 02 00 00       	call   335 <getpri>
  89:	50                   	push   %eax
  8a:	53                   	push   %ebx
  8b:	68 d7 06 00 00       	push   $0x6d7
  90:	6a 01                	push   $0x1
  92:	e8 50 03 00 00       	call   3e7 <printf>
	       for(int i=0; i < *argv[4];i++)
  97:	83 c6 01             	add    $0x1,%esi
  9a:	83 c4 20             	add    $0x20,%esp
  9d:	8b 47 10             	mov    0x10(%edi),%eax
  a0:	0f be 00             	movsbl (%eax),%eax
  a3:	39 f0                	cmp    %esi,%eax
  a5:	7e 2e                	jle    d5 <main+0xd5>
		    if(exec("loop", argvv) == -1)
  a7:	83 ec 08             	sub    $0x8,%esp
  aa:	68 8c 09 00 00       	push   $0x98c
  af:	68 cb 06 00 00       	push   $0x6cb
  b4:	e8 0c 02 00 00       	call   2c5 <exec>
  b9:	83 c4 10             	add    $0x10,%esp
  bc:	83 f8 ff             	cmp    $0xffffffff,%eax
  bf:	75 b5                	jne    76 <main+0x76>
			  printf(1,"Error\n");
  c1:	83 ec 08             	sub    $0x8,%esp
  c4:	68 d0 06 00 00       	push   $0x6d0
  c9:	6a 01                	push   $0x1
  cb:	e8 17 03 00 00       	call   3e7 <printf>
  d0:	83 c4 10             	add    $0x10,%esp
  d3:	eb a1                	jmp    76 <main+0x76>
	for(int it = 0 ; it < *argv[2]; it++) {
  d5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  d9:	8b 47 08             	mov    0x8(%edi),%eax
  dc:	0f be 00             	movsbl (%eax),%eax
  df:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  e2:	7e 17                	jle    fb <main+0xfb>
	    int c_pid = fork2(2);
  e4:	83 ec 0c             	sub    $0xc,%esp
  e7:	6a 02                	push   $0x2
  e9:	e8 57 02 00 00       	call   345 <fork2>
  ee:	89 c3                	mov    %eax,%ebx
	    if(c_pid == 0) {
  f0:	83 c4 10             	add    $0x10,%esp
  f3:	85 c0                	test   %eax,%eax
  f5:	75 de                	jne    d5 <main+0xd5>
	       for(int i=0; i < *argv[4];i++)
  f7:	89 c6                	mov    %eax,%esi
  f9:	eb a2                	jmp    9d <main+0x9d>
	      }  
	   }
        }   
    exit();
  fb:	e8 8d 01 00 00       	call   28d <exit>

00000100 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	53                   	push   %ebx
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10a:	89 c2                	mov    %eax,%edx
 10c:	0f b6 19             	movzbl (%ecx),%ebx
 10f:	88 1a                	mov    %bl,(%edx)
 111:	8d 52 01             	lea    0x1(%edx),%edx
 114:	8d 49 01             	lea    0x1(%ecx),%ecx
 117:	84 db                	test   %bl,%bl
 119:	75 f1                	jne    10c <strcpy+0xc>
    ;
  return os;
}
 11b:	5b                   	pop    %ebx
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    

0000011e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	8b 4d 08             	mov    0x8(%ebp),%ecx
 124:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 127:	eb 06                	jmp    12f <strcmp+0x11>
    p++, q++;
 129:	83 c1 01             	add    $0x1,%ecx
 12c:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 12f:	0f b6 01             	movzbl (%ecx),%eax
 132:	84 c0                	test   %al,%al
 134:	74 04                	je     13a <strcmp+0x1c>
 136:	3a 02                	cmp    (%edx),%al
 138:	74 ef                	je     129 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 13a:	0f b6 c0             	movzbl %al,%eax
 13d:	0f b6 12             	movzbl (%edx),%edx
 140:	29 d0                	sub    %edx,%eax
}
 142:	5d                   	pop    %ebp
 143:	c3                   	ret    

00000144 <strlen>:

uint
strlen(const char *s)
{
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
 147:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 14a:	ba 00 00 00 00       	mov    $0x0,%edx
 14f:	eb 03                	jmp    154 <strlen+0x10>
 151:	83 c2 01             	add    $0x1,%edx
 154:	89 d0                	mov    %edx,%eax
 156:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 15a:	75 f5                	jne    151 <strlen+0xd>
    ;
  return n;
}
 15c:	5d                   	pop    %ebp
 15d:	c3                   	ret    

0000015e <memset>:

void*
memset(void *dst, int c, uint n)
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	57                   	push   %edi
 162:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 165:	89 d7                	mov    %edx,%edi
 167:	8b 4d 10             	mov    0x10(%ebp),%ecx
 16a:	8b 45 0c             	mov    0xc(%ebp),%eax
 16d:	fc                   	cld    
 16e:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 170:	89 d0                	mov    %edx,%eax
 172:	5f                   	pop    %edi
 173:	5d                   	pop    %ebp
 174:	c3                   	ret    

00000175 <strchr>:

char*
strchr(const char *s, char c)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 17f:	0f b6 10             	movzbl (%eax),%edx
 182:	84 d2                	test   %dl,%dl
 184:	74 09                	je     18f <strchr+0x1a>
    if(*s == c)
 186:	38 ca                	cmp    %cl,%dl
 188:	74 0a                	je     194 <strchr+0x1f>
  for(; *s; s++)
 18a:	83 c0 01             	add    $0x1,%eax
 18d:	eb f0                	jmp    17f <strchr+0xa>
      return (char*)s;
  return 0;
 18f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 194:	5d                   	pop    %ebp
 195:	c3                   	ret    

00000196 <gets>:

char*
gets(char *buf, int max)
{
 196:	55                   	push   %ebp
 197:	89 e5                	mov    %esp,%ebp
 199:	57                   	push   %edi
 19a:	56                   	push   %esi
 19b:	53                   	push   %ebx
 19c:	83 ec 1c             	sub    $0x1c,%esp
 19f:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a2:	bb 00 00 00 00       	mov    $0x0,%ebx
 1a7:	8d 73 01             	lea    0x1(%ebx),%esi
 1aa:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1ad:	7d 2e                	jge    1dd <gets+0x47>
    cc = read(0, &c, 1);
 1af:	83 ec 04             	sub    $0x4,%esp
 1b2:	6a 01                	push   $0x1
 1b4:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1b7:	50                   	push   %eax
 1b8:	6a 00                	push   $0x0
 1ba:	e8 e6 00 00 00       	call   2a5 <read>
    if(cc < 1)
 1bf:	83 c4 10             	add    $0x10,%esp
 1c2:	85 c0                	test   %eax,%eax
 1c4:	7e 17                	jle    1dd <gets+0x47>
      break;
    buf[i++] = c;
 1c6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1ca:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1cd:	3c 0a                	cmp    $0xa,%al
 1cf:	0f 94 c2             	sete   %dl
 1d2:	3c 0d                	cmp    $0xd,%al
 1d4:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1d7:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1d9:	08 c2                	or     %al,%dl
 1db:	74 ca                	je     1a7 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1dd:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1e1:	89 f8                	mov    %edi,%eax
 1e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1e6:	5b                   	pop    %ebx
 1e7:	5e                   	pop    %esi
 1e8:	5f                   	pop    %edi
 1e9:	5d                   	pop    %ebp
 1ea:	c3                   	ret    

000001eb <stat>:

int
stat(const char *n, struct stat *st)
{
 1eb:	55                   	push   %ebp
 1ec:	89 e5                	mov    %esp,%ebp
 1ee:	56                   	push   %esi
 1ef:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	83 ec 08             	sub    $0x8,%esp
 1f3:	6a 00                	push   $0x0
 1f5:	ff 75 08             	pushl  0x8(%ebp)
 1f8:	e8 d0 00 00 00       	call   2cd <open>
  if(fd < 0)
 1fd:	83 c4 10             	add    $0x10,%esp
 200:	85 c0                	test   %eax,%eax
 202:	78 24                	js     228 <stat+0x3d>
 204:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 206:	83 ec 08             	sub    $0x8,%esp
 209:	ff 75 0c             	pushl  0xc(%ebp)
 20c:	50                   	push   %eax
 20d:	e8 d3 00 00 00       	call   2e5 <fstat>
 212:	89 c6                	mov    %eax,%esi
  close(fd);
 214:	89 1c 24             	mov    %ebx,(%esp)
 217:	e8 99 00 00 00       	call   2b5 <close>
  return r;
 21c:	83 c4 10             	add    $0x10,%esp
}
 21f:	89 f0                	mov    %esi,%eax
 221:	8d 65 f8             	lea    -0x8(%ebp),%esp
 224:	5b                   	pop    %ebx
 225:	5e                   	pop    %esi
 226:	5d                   	pop    %ebp
 227:	c3                   	ret    
    return -1;
 228:	be ff ff ff ff       	mov    $0xffffffff,%esi
 22d:	eb f0                	jmp    21f <stat+0x34>

0000022f <atoi>:

int
atoi(const char *s)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	53                   	push   %ebx
 233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 236:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 23b:	eb 10                	jmp    24d <atoi+0x1e>
    n = n*10 + *s++ - '0';
 23d:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 240:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 243:	83 c1 01             	add    $0x1,%ecx
 246:	0f be d2             	movsbl %dl,%edx
 249:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 24d:	0f b6 11             	movzbl (%ecx),%edx
 250:	8d 5a d0             	lea    -0x30(%edx),%ebx
 253:	80 fb 09             	cmp    $0x9,%bl
 256:	76 e5                	jbe    23d <atoi+0xe>
  return n;
}
 258:	5b                   	pop    %ebx
 259:	5d                   	pop    %ebp
 25a:	c3                   	ret    

0000025b <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	56                   	push   %esi
 25f:	53                   	push   %ebx
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 266:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 269:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 26b:	eb 0d                	jmp    27a <memmove+0x1f>
    *dst++ = *src++;
 26d:	0f b6 13             	movzbl (%ebx),%edx
 270:	88 11                	mov    %dl,(%ecx)
 272:	8d 5b 01             	lea    0x1(%ebx),%ebx
 275:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 278:	89 f2                	mov    %esi,%edx
 27a:	8d 72 ff             	lea    -0x1(%edx),%esi
 27d:	85 d2                	test   %edx,%edx
 27f:	7f ec                	jg     26d <memmove+0x12>
  return vdst;
}
 281:	5b                   	pop    %ebx
 282:	5e                   	pop    %esi
 283:	5d                   	pop    %ebp
 284:	c3                   	ret    

00000285 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 285:	b8 01 00 00 00       	mov    $0x1,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <exit>:
SYSCALL(exit)
 28d:	b8 02 00 00 00       	mov    $0x2,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <wait>:
SYSCALL(wait)
 295:	b8 03 00 00 00       	mov    $0x3,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <pipe>:
SYSCALL(pipe)
 29d:	b8 04 00 00 00       	mov    $0x4,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <read>:
SYSCALL(read)
 2a5:	b8 05 00 00 00       	mov    $0x5,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <write>:
SYSCALL(write)
 2ad:	b8 10 00 00 00       	mov    $0x10,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <close>:
SYSCALL(close)
 2b5:	b8 15 00 00 00       	mov    $0x15,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <kill>:
SYSCALL(kill)
 2bd:	b8 06 00 00 00       	mov    $0x6,%eax
 2c2:	cd 40                	int    $0x40
 2c4:	c3                   	ret    

000002c5 <exec>:
SYSCALL(exec)
 2c5:	b8 07 00 00 00       	mov    $0x7,%eax
 2ca:	cd 40                	int    $0x40
 2cc:	c3                   	ret    

000002cd <open>:
SYSCALL(open)
 2cd:	b8 0f 00 00 00       	mov    $0xf,%eax
 2d2:	cd 40                	int    $0x40
 2d4:	c3                   	ret    

000002d5 <mknod>:
SYSCALL(mknod)
 2d5:	b8 11 00 00 00       	mov    $0x11,%eax
 2da:	cd 40                	int    $0x40
 2dc:	c3                   	ret    

000002dd <unlink>:
SYSCALL(unlink)
 2dd:	b8 12 00 00 00       	mov    $0x12,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <fstat>:
SYSCALL(fstat)
 2e5:	b8 08 00 00 00       	mov    $0x8,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <link>:
SYSCALL(link)
 2ed:	b8 13 00 00 00       	mov    $0x13,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <mkdir>:
SYSCALL(mkdir)
 2f5:	b8 14 00 00 00       	mov    $0x14,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <chdir>:
SYSCALL(chdir)
 2fd:	b8 09 00 00 00       	mov    $0x9,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <dup>:
SYSCALL(dup)
 305:	b8 0a 00 00 00       	mov    $0xa,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <getpid>:
SYSCALL(getpid)
 30d:	b8 0b 00 00 00       	mov    $0xb,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <sbrk>:
SYSCALL(sbrk)
 315:	b8 0c 00 00 00       	mov    $0xc,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <sleep>:
SYSCALL(sleep)
 31d:	b8 0d 00 00 00       	mov    $0xd,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <uptime>:
SYSCALL(uptime)
 325:	b8 0e 00 00 00       	mov    $0xe,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <setpri>:
SYSCALL(setpri)
 32d:	b8 16 00 00 00       	mov    $0x16,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <getpri>:
SYSCALL(getpri)
 335:	b8 17 00 00 00       	mov    $0x17,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <getpinfo>:
SYSCALL(getpinfo)
 33d:	b8 18 00 00 00       	mov    $0x18,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <fork2>:
SYSCALL(fork2)
 345:	b8 19 00 00 00       	mov    $0x19,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 34d:	55                   	push   %ebp
 34e:	89 e5                	mov    %esp,%ebp
 350:	83 ec 1c             	sub    $0x1c,%esp
 353:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 356:	6a 01                	push   $0x1
 358:	8d 55 f4             	lea    -0xc(%ebp),%edx
 35b:	52                   	push   %edx
 35c:	50                   	push   %eax
 35d:	e8 4b ff ff ff       	call   2ad <write>
}
 362:	83 c4 10             	add    $0x10,%esp
 365:	c9                   	leave  
 366:	c3                   	ret    

00000367 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
 36a:	57                   	push   %edi
 36b:	56                   	push   %esi
 36c:	53                   	push   %ebx
 36d:	83 ec 2c             	sub    $0x2c,%esp
 370:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 372:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 376:	0f 95 c3             	setne  %bl
 379:	89 d0                	mov    %edx,%eax
 37b:	c1 e8 1f             	shr    $0x1f,%eax
 37e:	84 c3                	test   %al,%bl
 380:	74 10                	je     392 <printint+0x2b>
    neg = 1;
    x = -xx;
 382:	f7 da                	neg    %edx
    neg = 1;
 384:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 38b:	be 00 00 00 00       	mov    $0x0,%esi
 390:	eb 0b                	jmp    39d <printint+0x36>
  neg = 0;
 392:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 399:	eb f0                	jmp    38b <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 39b:	89 c6                	mov    %eax,%esi
 39d:	89 d0                	mov    %edx,%eax
 39f:	ba 00 00 00 00       	mov    $0x0,%edx
 3a4:	f7 f1                	div    %ecx
 3a6:	89 c3                	mov    %eax,%ebx
 3a8:	8d 46 01             	lea    0x1(%esi),%eax
 3ab:	0f b6 92 e8 06 00 00 	movzbl 0x6e8(%edx),%edx
 3b2:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3b6:	89 da                	mov    %ebx,%edx
 3b8:	85 db                	test   %ebx,%ebx
 3ba:	75 df                	jne    39b <printint+0x34>
 3bc:	89 c3                	mov    %eax,%ebx
  if(neg)
 3be:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3c2:	74 16                	je     3da <printint+0x73>
    buf[i++] = '-';
 3c4:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3c9:	8d 5e 02             	lea    0x2(%esi),%ebx
 3cc:	eb 0c                	jmp    3da <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3ce:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3d3:	89 f8                	mov    %edi,%eax
 3d5:	e8 73 ff ff ff       	call   34d <putc>
  while(--i >= 0)
 3da:	83 eb 01             	sub    $0x1,%ebx
 3dd:	79 ef                	jns    3ce <printint+0x67>
}
 3df:	83 c4 2c             	add    $0x2c,%esp
 3e2:	5b                   	pop    %ebx
 3e3:	5e                   	pop    %esi
 3e4:	5f                   	pop    %edi
 3e5:	5d                   	pop    %ebp
 3e6:	c3                   	ret    

000003e7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3e7:	55                   	push   %ebp
 3e8:	89 e5                	mov    %esp,%ebp
 3ea:	57                   	push   %edi
 3eb:	56                   	push   %esi
 3ec:	53                   	push   %ebx
 3ed:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3f0:	8d 45 10             	lea    0x10(%ebp),%eax
 3f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3f6:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3fb:	bb 00 00 00 00       	mov    $0x0,%ebx
 400:	eb 14                	jmp    416 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 402:	89 fa                	mov    %edi,%edx
 404:	8b 45 08             	mov    0x8(%ebp),%eax
 407:	e8 41 ff ff ff       	call   34d <putc>
 40c:	eb 05                	jmp    413 <printf+0x2c>
      }
    } else if(state == '%'){
 40e:	83 fe 25             	cmp    $0x25,%esi
 411:	74 25                	je     438 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 413:	83 c3 01             	add    $0x1,%ebx
 416:	8b 45 0c             	mov    0xc(%ebp),%eax
 419:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 41d:	84 c0                	test   %al,%al
 41f:	0f 84 23 01 00 00    	je     548 <printf+0x161>
    c = fmt[i] & 0xff;
 425:	0f be f8             	movsbl %al,%edi
 428:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 42b:	85 f6                	test   %esi,%esi
 42d:	75 df                	jne    40e <printf+0x27>
      if(c == '%'){
 42f:	83 f8 25             	cmp    $0x25,%eax
 432:	75 ce                	jne    402 <printf+0x1b>
        state = '%';
 434:	89 c6                	mov    %eax,%esi
 436:	eb db                	jmp    413 <printf+0x2c>
      if(c == 'd'){
 438:	83 f8 64             	cmp    $0x64,%eax
 43b:	74 49                	je     486 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 43d:	83 f8 78             	cmp    $0x78,%eax
 440:	0f 94 c1             	sete   %cl
 443:	83 f8 70             	cmp    $0x70,%eax
 446:	0f 94 c2             	sete   %dl
 449:	08 d1                	or     %dl,%cl
 44b:	75 63                	jne    4b0 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 44d:	83 f8 73             	cmp    $0x73,%eax
 450:	0f 84 84 00 00 00    	je     4da <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 456:	83 f8 63             	cmp    $0x63,%eax
 459:	0f 84 b7 00 00 00    	je     516 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 45f:	83 f8 25             	cmp    $0x25,%eax
 462:	0f 84 cc 00 00 00    	je     534 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 468:	ba 25 00 00 00       	mov    $0x25,%edx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	e8 d8 fe ff ff       	call   34d <putc>
        putc(fd, c);
 475:	89 fa                	mov    %edi,%edx
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	e8 ce fe ff ff       	call   34d <putc>
      }
      state = 0;
 47f:	be 00 00 00 00       	mov    $0x0,%esi
 484:	eb 8d                	jmp    413 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 489:	8b 17                	mov    (%edi),%edx
 48b:	83 ec 0c             	sub    $0xc,%esp
 48e:	6a 01                	push   $0x1
 490:	b9 0a 00 00 00       	mov    $0xa,%ecx
 495:	8b 45 08             	mov    0x8(%ebp),%eax
 498:	e8 ca fe ff ff       	call   367 <printint>
        ap++;
 49d:	83 c7 04             	add    $0x4,%edi
 4a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4a3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4a6:	be 00 00 00 00       	mov    $0x0,%esi
 4ab:	e9 63 ff ff ff       	jmp    413 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4b3:	8b 17                	mov    (%edi),%edx
 4b5:	83 ec 0c             	sub    $0xc,%esp
 4b8:	6a 00                	push   $0x0
 4ba:	b9 10 00 00 00       	mov    $0x10,%ecx
 4bf:	8b 45 08             	mov    0x8(%ebp),%eax
 4c2:	e8 a0 fe ff ff       	call   367 <printint>
        ap++;
 4c7:	83 c7 04             	add    $0x4,%edi
 4ca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4cd:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4d0:	be 00 00 00 00       	mov    $0x0,%esi
 4d5:	e9 39 ff ff ff       	jmp    413 <printf+0x2c>
        s = (char*)*ap;
 4da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4dd:	8b 30                	mov    (%eax),%esi
        ap++;
 4df:	83 c0 04             	add    $0x4,%eax
 4e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4e5:	85 f6                	test   %esi,%esi
 4e7:	75 28                	jne    511 <printf+0x12a>
          s = "(null)";
 4e9:	be df 06 00 00       	mov    $0x6df,%esi
 4ee:	8b 7d 08             	mov    0x8(%ebp),%edi
 4f1:	eb 0d                	jmp    500 <printf+0x119>
          putc(fd, *s);
 4f3:	0f be d2             	movsbl %dl,%edx
 4f6:	89 f8                	mov    %edi,%eax
 4f8:	e8 50 fe ff ff       	call   34d <putc>
          s++;
 4fd:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 500:	0f b6 16             	movzbl (%esi),%edx
 503:	84 d2                	test   %dl,%dl
 505:	75 ec                	jne    4f3 <printf+0x10c>
      state = 0;
 507:	be 00 00 00 00       	mov    $0x0,%esi
 50c:	e9 02 ff ff ff       	jmp    413 <printf+0x2c>
 511:	8b 7d 08             	mov    0x8(%ebp),%edi
 514:	eb ea                	jmp    500 <printf+0x119>
        putc(fd, *ap);
 516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 519:	0f be 17             	movsbl (%edi),%edx
 51c:	8b 45 08             	mov    0x8(%ebp),%eax
 51f:	e8 29 fe ff ff       	call   34d <putc>
        ap++;
 524:	83 c7 04             	add    $0x4,%edi
 527:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 52a:	be 00 00 00 00       	mov    $0x0,%esi
 52f:	e9 df fe ff ff       	jmp    413 <printf+0x2c>
        putc(fd, c);
 534:	89 fa                	mov    %edi,%edx
 536:	8b 45 08             	mov    0x8(%ebp),%eax
 539:	e8 0f fe ff ff       	call   34d <putc>
      state = 0;
 53e:	be 00 00 00 00       	mov    $0x0,%esi
 543:	e9 cb fe ff ff       	jmp    413 <printf+0x2c>
    }
  }
}
 548:	8d 65 f4             	lea    -0xc(%ebp),%esp
 54b:	5b                   	pop    %ebx
 54c:	5e                   	pop    %esi
 54d:	5f                   	pop    %edi
 54e:	5d                   	pop    %ebp
 54f:	c3                   	ret    

00000550 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	57                   	push   %edi
 554:	56                   	push   %esi
 555:	53                   	push   %ebx
 556:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 559:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 55c:	a1 94 09 00 00       	mov    0x994,%eax
 561:	eb 02                	jmp    565 <free+0x15>
 563:	89 d0                	mov    %edx,%eax
 565:	39 c8                	cmp    %ecx,%eax
 567:	73 04                	jae    56d <free+0x1d>
 569:	39 08                	cmp    %ecx,(%eax)
 56b:	77 12                	ja     57f <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 56d:	8b 10                	mov    (%eax),%edx
 56f:	39 c2                	cmp    %eax,%edx
 571:	77 f0                	ja     563 <free+0x13>
 573:	39 c8                	cmp    %ecx,%eax
 575:	72 08                	jb     57f <free+0x2f>
 577:	39 ca                	cmp    %ecx,%edx
 579:	77 04                	ja     57f <free+0x2f>
 57b:	89 d0                	mov    %edx,%eax
 57d:	eb e6                	jmp    565 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 57f:	8b 73 fc             	mov    -0x4(%ebx),%esi
 582:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 585:	8b 10                	mov    (%eax),%edx
 587:	39 d7                	cmp    %edx,%edi
 589:	74 19                	je     5a4 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 58b:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 58e:	8b 50 04             	mov    0x4(%eax),%edx
 591:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 594:	39 ce                	cmp    %ecx,%esi
 596:	74 1b                	je     5b3 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 598:	89 08                	mov    %ecx,(%eax)
  freep = p;
 59a:	a3 94 09 00 00       	mov    %eax,0x994
}
 59f:	5b                   	pop    %ebx
 5a0:	5e                   	pop    %esi
 5a1:	5f                   	pop    %edi
 5a2:	5d                   	pop    %ebp
 5a3:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5a4:	03 72 04             	add    0x4(%edx),%esi
 5a7:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5aa:	8b 10                	mov    (%eax),%edx
 5ac:	8b 12                	mov    (%edx),%edx
 5ae:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5b1:	eb db                	jmp    58e <free+0x3e>
    p->s.size += bp->s.size;
 5b3:	03 53 fc             	add    -0x4(%ebx),%edx
 5b6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5b9:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5bc:	89 10                	mov    %edx,(%eax)
 5be:	eb da                	jmp    59a <free+0x4a>

000005c0 <morecore>:

static Header*
morecore(uint nu)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	53                   	push   %ebx
 5c4:	83 ec 04             	sub    $0x4,%esp
 5c7:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5c9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5ce:	77 05                	ja     5d5 <morecore+0x15>
    nu = 4096;
 5d0:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5d5:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5dc:	83 ec 0c             	sub    $0xc,%esp
 5df:	50                   	push   %eax
 5e0:	e8 30 fd ff ff       	call   315 <sbrk>
  if(p == (char*)-1)
 5e5:	83 c4 10             	add    $0x10,%esp
 5e8:	83 f8 ff             	cmp    $0xffffffff,%eax
 5eb:	74 1c                	je     609 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5ed:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5f0:	83 c0 08             	add    $0x8,%eax
 5f3:	83 ec 0c             	sub    $0xc,%esp
 5f6:	50                   	push   %eax
 5f7:	e8 54 ff ff ff       	call   550 <free>
  return freep;
 5fc:	a1 94 09 00 00       	mov    0x994,%eax
 601:	83 c4 10             	add    $0x10,%esp
}
 604:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 607:	c9                   	leave  
 608:	c3                   	ret    
    return 0;
 609:	b8 00 00 00 00       	mov    $0x0,%eax
 60e:	eb f4                	jmp    604 <morecore+0x44>

00000610 <malloc>:

void*
malloc(uint nbytes)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	53                   	push   %ebx
 614:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	8d 58 07             	lea    0x7(%eax),%ebx
 61d:	c1 eb 03             	shr    $0x3,%ebx
 620:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 623:	8b 0d 94 09 00 00    	mov    0x994,%ecx
 629:	85 c9                	test   %ecx,%ecx
 62b:	74 04                	je     631 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 62d:	8b 01                	mov    (%ecx),%eax
 62f:	eb 4d                	jmp    67e <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 631:	c7 05 94 09 00 00 98 	movl   $0x998,0x994
 638:	09 00 00 
 63b:	c7 05 98 09 00 00 98 	movl   $0x998,0x998
 642:	09 00 00 
    base.s.size = 0;
 645:	c7 05 9c 09 00 00 00 	movl   $0x0,0x99c
 64c:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 64f:	b9 98 09 00 00       	mov    $0x998,%ecx
 654:	eb d7                	jmp    62d <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 656:	39 da                	cmp    %ebx,%edx
 658:	74 1a                	je     674 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 65a:	29 da                	sub    %ebx,%edx
 65c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 65f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 662:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 665:	89 0d 94 09 00 00    	mov    %ecx,0x994
      return (void*)(p + 1);
 66b:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 66e:	83 c4 04             	add    $0x4,%esp
 671:	5b                   	pop    %ebx
 672:	5d                   	pop    %ebp
 673:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 674:	8b 10                	mov    (%eax),%edx
 676:	89 11                	mov    %edx,(%ecx)
 678:	eb eb                	jmp    665 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 67a:	89 c1                	mov    %eax,%ecx
 67c:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 67e:	8b 50 04             	mov    0x4(%eax),%edx
 681:	39 da                	cmp    %ebx,%edx
 683:	73 d1                	jae    656 <malloc+0x46>
    if(p == freep)
 685:	39 05 94 09 00 00    	cmp    %eax,0x994
 68b:	75 ed                	jne    67a <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 68d:	89 d8                	mov    %ebx,%eax
 68f:	e8 2c ff ff ff       	call   5c0 <morecore>
 694:	85 c0                	test   %eax,%eax
 696:	75 e2                	jne    67a <malloc+0x6a>
        return 0;
 698:	b8 00 00 00 00       	mov    $0x0,%eax
 69d:	eb cf                	jmp    66e <malloc+0x5e>
