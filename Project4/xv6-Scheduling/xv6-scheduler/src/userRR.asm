
_userRR:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"
#include "pstat.h"
#include "param.h"
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
  14:	8b 59 04             	mov    0x4(%ecx),%ebx
	if(argc != 5){
  17:	83 39 05             	cmpl   $0x5,(%ecx)
  1a:	74 14                	je     30 <main+0x30>
	   printf(2, "Wrong number of argument\n");
  1c:	83 ec 08             	sub    $0x8,%esp
  1f:	68 b4 06 00 00       	push   $0x6b4
  24:	6a 02                	push   $0x2
  26:	e8 d0 03 00 00       	call   3fb <printf>
	   exit();
  2b:	e8 71 02 00 00       	call   2a1 <exit>
	}
	int pid = getpid();
  30:	e8 ec 02 00 00       	call   321 <getpid>
	//printf(2, "Setting pid :%d\n",pid);
	setpri(pid,0);
  35:	83 ec 08             	sub    $0x8,%esp
  38:	6a 00                	push   $0x0
  3a:	50                   	push   %eax
  3b:	e8 01 03 00 00       	call   341 <setpri>
        //printf(1,"%d\n", getpri(pid));
	for(int it = 0 ; it < atoi(argv[2]); it++) {
  40:	83 c4 10             	add    $0x10,%esp
  43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  4a:	eb 68                	jmp    b4 <main+0xb4>
	    int c_pid = fork2(1);
	    printf(1,"iteration : %d, c_pid %d\n",it,c_pid);
	    if(c_pid == 0) {
	       for(int i=0; i < atoi(argv[4]);i++)
	       {
		    if(exec(argv[3], argv) == -1)
  4c:	83 ec 08             	sub    $0x8,%esp
  4f:	53                   	push   %ebx
  50:	ff 73 0c             	pushl  0xc(%ebx)
  53:	e8 81 02 00 00       	call   2d9 <exec>
		    {
			  //printf(1,"Error\n");
		    }
		    //setpri(c_pid,1);
                    //exit();
		    printf(1,"%d, %d\n",c_pid,getpri(c_pid));
  58:	89 34 24             	mov    %esi,(%esp)
  5b:	e8 e9 02 00 00       	call   349 <getpri>
  60:	50                   	push   %eax
  61:	56                   	push   %esi
  62:	68 e8 06 00 00       	push   $0x6e8
  67:	6a 01                	push   $0x1
  69:	e8 8d 03 00 00       	call   3fb <printf>
		   sleep(atoi(argv[1])); 
  6e:	83 c4 14             	add    $0x14,%esp
  71:	ff 73 04             	pushl  0x4(%ebx)
  74:	e8 ca 01 00 00       	call   243 <atoi>
  79:	89 04 24             	mov    %eax,(%esp)
  7c:	e8 b0 02 00 00       	call   331 <sleep>
		   setpri(c_pid,2);
  81:	83 c4 08             	add    $0x8,%esp
  84:	6a 02                	push   $0x2
  86:	56                   	push   %esi
  87:	e8 b5 02 00 00       	call   341 <setpri>
	       for(int i=0; i < atoi(argv[4]);i++)
  8c:	83 c7 01             	add    $0x1,%edi
  8f:	83 c4 10             	add    $0x10,%esp
  92:	83 ec 0c             	sub    $0xc,%esp
  95:	ff 73 10             	pushl  0x10(%ebx)
  98:	e8 a6 01 00 00       	call   243 <atoi>
  9d:	83 c4 10             	add    $0x10,%esp
  a0:	39 f8                	cmp    %edi,%eax
  a2:	7f a8                	jg     4c <main+0x4c>
	      }  
	      kill(c_pid);
  a4:	83 ec 0c             	sub    $0xc,%esp
  a7:	56                   	push   %esi
  a8:	e8 24 02 00 00       	call   2d1 <kill>
  ad:	83 c4 10             	add    $0x10,%esp
	for(int it = 0 ; it < atoi(argv[2]); it++) {
  b0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  b4:	83 ec 0c             	sub    $0xc,%esp
  b7:	ff 73 08             	pushl  0x8(%ebx)
  ba:	e8 84 01 00 00       	call   243 <atoi>
  bf:	83 c4 10             	add    $0x10,%esp
  c2:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  c5:	7e 27                	jle    ee <main+0xee>
	    int c_pid = fork2(1);
  c7:	83 ec 0c             	sub    $0xc,%esp
  ca:	6a 01                	push   $0x1
  cc:	e8 88 02 00 00       	call   359 <fork2>
  d1:	89 c6                	mov    %eax,%esi
	    printf(1,"iteration : %d, c_pid %d\n",it,c_pid);
  d3:	50                   	push   %eax
  d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  d7:	68 ce 06 00 00       	push   $0x6ce
  dc:	6a 01                	push   $0x1
  de:	e8 18 03 00 00       	call   3fb <printf>
	    if(c_pid == 0) {
  e3:	83 c4 20             	add    $0x20,%esp
  e6:	85 f6                	test   %esi,%esi
  e8:	75 c6                	jne    b0 <main+0xb0>
	       for(int i=0; i < atoi(argv[4]);i++)
  ea:	89 f7                	mov    %esi,%edi
  ec:	eb a4                	jmp    92 <main+0x92>
	   }
        }
    for(int i=0 ;i< atoi(argv[2]); i++)
  ee:	be 00 00 00 00       	mov    $0x0,%esi
  f3:	eb 08                	jmp    fd <main+0xfd>
    {
	   wait();
  f5:	e8 af 01 00 00       	call   2a9 <wait>
    for(int i=0 ;i< atoi(argv[2]); i++)
  fa:	83 c6 01             	add    $0x1,%esi
  fd:	83 ec 0c             	sub    $0xc,%esp
 100:	ff 73 08             	pushl  0x8(%ebx)
 103:	e8 3b 01 00 00       	call   243 <atoi>
 108:	83 c4 10             	add    $0x10,%esp
 10b:	39 f0                	cmp    %esi,%eax
 10d:	7f e6                	jg     f5 <main+0xf5>
	   //exit();
     }
    exit();
 10f:	e8 8d 01 00 00       	call   2a1 <exit>

00000114 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	53                   	push   %ebx
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	89 c2                	mov    %eax,%edx
 120:	0f b6 19             	movzbl (%ecx),%ebx
 123:	88 1a                	mov    %bl,(%edx)
 125:	8d 52 01             	lea    0x1(%edx),%edx
 128:	8d 49 01             	lea    0x1(%ecx),%ecx
 12b:	84 db                	test   %bl,%bl
 12d:	75 f1                	jne    120 <strcpy+0xc>
    ;
  return os;
}
 12f:	5b                   	pop    %ebx
 130:	5d                   	pop    %ebp
 131:	c3                   	ret    

00000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	8b 4d 08             	mov    0x8(%ebp),%ecx
 138:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 13b:	eb 06                	jmp    143 <strcmp+0x11>
    p++, q++;
 13d:	83 c1 01             	add    $0x1,%ecx
 140:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 143:	0f b6 01             	movzbl (%ecx),%eax
 146:	84 c0                	test   %al,%al
 148:	74 04                	je     14e <strcmp+0x1c>
 14a:	3a 02                	cmp    (%edx),%al
 14c:	74 ef                	je     13d <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 14e:	0f b6 c0             	movzbl %al,%eax
 151:	0f b6 12             	movzbl (%edx),%edx
 154:	29 d0                	sub    %edx,%eax
}
 156:	5d                   	pop    %ebp
 157:	c3                   	ret    

00000158 <strlen>:

uint
strlen(const char *s)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 15e:	ba 00 00 00 00       	mov    $0x0,%edx
 163:	eb 03                	jmp    168 <strlen+0x10>
 165:	83 c2 01             	add    $0x1,%edx
 168:	89 d0                	mov    %edx,%eax
 16a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 16e:	75 f5                	jne    165 <strlen+0xd>
    ;
  return n;
}
 170:	5d                   	pop    %ebp
 171:	c3                   	ret    

00000172 <memset>:

void*
memset(void *dst, int c, uint n)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
 175:	57                   	push   %edi
 176:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 179:	89 d7                	mov    %edx,%edi
 17b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 17e:	8b 45 0c             	mov    0xc(%ebp),%eax
 181:	fc                   	cld    
 182:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 184:	89 d0                	mov    %edx,%eax
 186:	5f                   	pop    %edi
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    

00000189 <strchr>:

char*
strchr(const char *s, char c)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 193:	0f b6 10             	movzbl (%eax),%edx
 196:	84 d2                	test   %dl,%dl
 198:	74 09                	je     1a3 <strchr+0x1a>
    if(*s == c)
 19a:	38 ca                	cmp    %cl,%dl
 19c:	74 0a                	je     1a8 <strchr+0x1f>
  for(; *s; s++)
 19e:	83 c0 01             	add    $0x1,%eax
 1a1:	eb f0                	jmp    193 <strchr+0xa>
      return (char*)s;
  return 0;
 1a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a8:	5d                   	pop    %ebp
 1a9:	c3                   	ret    

000001aa <gets>:

char*
gets(char *buf, int max)
{
 1aa:	55                   	push   %ebp
 1ab:	89 e5                	mov    %esp,%ebp
 1ad:	57                   	push   %edi
 1ae:	56                   	push   %esi
 1af:	53                   	push   %ebx
 1b0:	83 ec 1c             	sub    $0x1c,%esp
 1b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b6:	bb 00 00 00 00       	mov    $0x0,%ebx
 1bb:	8d 73 01             	lea    0x1(%ebx),%esi
 1be:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1c1:	7d 2e                	jge    1f1 <gets+0x47>
    cc = read(0, &c, 1);
 1c3:	83 ec 04             	sub    $0x4,%esp
 1c6:	6a 01                	push   $0x1
 1c8:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1cb:	50                   	push   %eax
 1cc:	6a 00                	push   $0x0
 1ce:	e8 e6 00 00 00       	call   2b9 <read>
    if(cc < 1)
 1d3:	83 c4 10             	add    $0x10,%esp
 1d6:	85 c0                	test   %eax,%eax
 1d8:	7e 17                	jle    1f1 <gets+0x47>
      break;
    buf[i++] = c;
 1da:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1de:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1e1:	3c 0a                	cmp    $0xa,%al
 1e3:	0f 94 c2             	sete   %dl
 1e6:	3c 0d                	cmp    $0xd,%al
 1e8:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1eb:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1ed:	08 c2                	or     %al,%dl
 1ef:	74 ca                	je     1bb <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1f1:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1f5:	89 f8                	mov    %edi,%eax
 1f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1fa:	5b                   	pop    %ebx
 1fb:	5e                   	pop    %esi
 1fc:	5f                   	pop    %edi
 1fd:	5d                   	pop    %ebp
 1fe:	c3                   	ret    

000001ff <stat>:

int
stat(const char *n, struct stat *st)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	56                   	push   %esi
 203:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 204:	83 ec 08             	sub    $0x8,%esp
 207:	6a 00                	push   $0x0
 209:	ff 75 08             	pushl  0x8(%ebp)
 20c:	e8 d0 00 00 00       	call   2e1 <open>
  if(fd < 0)
 211:	83 c4 10             	add    $0x10,%esp
 214:	85 c0                	test   %eax,%eax
 216:	78 24                	js     23c <stat+0x3d>
 218:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 21a:	83 ec 08             	sub    $0x8,%esp
 21d:	ff 75 0c             	pushl  0xc(%ebp)
 220:	50                   	push   %eax
 221:	e8 d3 00 00 00       	call   2f9 <fstat>
 226:	89 c6                	mov    %eax,%esi
  close(fd);
 228:	89 1c 24             	mov    %ebx,(%esp)
 22b:	e8 99 00 00 00       	call   2c9 <close>
  return r;
 230:	83 c4 10             	add    $0x10,%esp
}
 233:	89 f0                	mov    %esi,%eax
 235:	8d 65 f8             	lea    -0x8(%ebp),%esp
 238:	5b                   	pop    %ebx
 239:	5e                   	pop    %esi
 23a:	5d                   	pop    %ebp
 23b:	c3                   	ret    
    return -1;
 23c:	be ff ff ff ff       	mov    $0xffffffff,%esi
 241:	eb f0                	jmp    233 <stat+0x34>

00000243 <atoi>:

int
atoi(const char *s)
{
 243:	55                   	push   %ebp
 244:	89 e5                	mov    %esp,%ebp
 246:	53                   	push   %ebx
 247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 24a:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 24f:	eb 10                	jmp    261 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 251:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 254:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 257:	83 c1 01             	add    $0x1,%ecx
 25a:	0f be d2             	movsbl %dl,%edx
 25d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 261:	0f b6 11             	movzbl (%ecx),%edx
 264:	8d 5a d0             	lea    -0x30(%edx),%ebx
 267:	80 fb 09             	cmp    $0x9,%bl
 26a:	76 e5                	jbe    251 <atoi+0xe>
  return n;
}
 26c:	5b                   	pop    %ebx
 26d:	5d                   	pop    %ebp
 26e:	c3                   	ret    

0000026f <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26f:	55                   	push   %ebp
 270:	89 e5                	mov    %esp,%ebp
 272:	56                   	push   %esi
 273:	53                   	push   %ebx
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 27a:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 27d:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 27f:	eb 0d                	jmp    28e <memmove+0x1f>
    *dst++ = *src++;
 281:	0f b6 13             	movzbl (%ebx),%edx
 284:	88 11                	mov    %dl,(%ecx)
 286:	8d 5b 01             	lea    0x1(%ebx),%ebx
 289:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 28c:	89 f2                	mov    %esi,%edx
 28e:	8d 72 ff             	lea    -0x1(%edx),%esi
 291:	85 d2                	test   %edx,%edx
 293:	7f ec                	jg     281 <memmove+0x12>
  return vdst;
}
 295:	5b                   	pop    %ebx
 296:	5e                   	pop    %esi
 297:	5d                   	pop    %ebp
 298:	c3                   	ret    

00000299 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 299:	b8 01 00 00 00       	mov    $0x1,%eax
 29e:	cd 40                	int    $0x40
 2a0:	c3                   	ret    

000002a1 <exit>:
SYSCALL(exit)
 2a1:	b8 02 00 00 00       	mov    $0x2,%eax
 2a6:	cd 40                	int    $0x40
 2a8:	c3                   	ret    

000002a9 <wait>:
SYSCALL(wait)
 2a9:	b8 03 00 00 00       	mov    $0x3,%eax
 2ae:	cd 40                	int    $0x40
 2b0:	c3                   	ret    

000002b1 <pipe>:
SYSCALL(pipe)
 2b1:	b8 04 00 00 00       	mov    $0x4,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret    

000002b9 <read>:
SYSCALL(read)
 2b9:	b8 05 00 00 00       	mov    $0x5,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret    

000002c1 <write>:
SYSCALL(write)
 2c1:	b8 10 00 00 00       	mov    $0x10,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <close>:
SYSCALL(close)
 2c9:	b8 15 00 00 00       	mov    $0x15,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <kill>:
SYSCALL(kill)
 2d1:	b8 06 00 00 00       	mov    $0x6,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <exec>:
SYSCALL(exec)
 2d9:	b8 07 00 00 00       	mov    $0x7,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <open>:
SYSCALL(open)
 2e1:	b8 0f 00 00 00       	mov    $0xf,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <mknod>:
SYSCALL(mknod)
 2e9:	b8 11 00 00 00       	mov    $0x11,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <unlink>:
SYSCALL(unlink)
 2f1:	b8 12 00 00 00       	mov    $0x12,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <fstat>:
SYSCALL(fstat)
 2f9:	b8 08 00 00 00       	mov    $0x8,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <link>:
SYSCALL(link)
 301:	b8 13 00 00 00       	mov    $0x13,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <mkdir>:
SYSCALL(mkdir)
 309:	b8 14 00 00 00       	mov    $0x14,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <chdir>:
SYSCALL(chdir)
 311:	b8 09 00 00 00       	mov    $0x9,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <dup>:
SYSCALL(dup)
 319:	b8 0a 00 00 00       	mov    $0xa,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <getpid>:
SYSCALL(getpid)
 321:	b8 0b 00 00 00       	mov    $0xb,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <sbrk>:
SYSCALL(sbrk)
 329:	b8 0c 00 00 00       	mov    $0xc,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <sleep>:
SYSCALL(sleep)
 331:	b8 0d 00 00 00       	mov    $0xd,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <uptime>:
SYSCALL(uptime)
 339:	b8 0e 00 00 00       	mov    $0xe,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <setpri>:
SYSCALL(setpri)
 341:	b8 16 00 00 00       	mov    $0x16,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <getpri>:
SYSCALL(getpri)
 349:	b8 17 00 00 00       	mov    $0x17,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <getpinfo>:
SYSCALL(getpinfo)
 351:	b8 18 00 00 00       	mov    $0x18,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <fork2>:
SYSCALL(fork2)
 359:	b8 19 00 00 00       	mov    $0x19,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 361:	55                   	push   %ebp
 362:	89 e5                	mov    %esp,%ebp
 364:	83 ec 1c             	sub    $0x1c,%esp
 367:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 36a:	6a 01                	push   $0x1
 36c:	8d 55 f4             	lea    -0xc(%ebp),%edx
 36f:	52                   	push   %edx
 370:	50                   	push   %eax
 371:	e8 4b ff ff ff       	call   2c1 <write>
}
 376:	83 c4 10             	add    $0x10,%esp
 379:	c9                   	leave  
 37a:	c3                   	ret    

0000037b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37b:	55                   	push   %ebp
 37c:	89 e5                	mov    %esp,%ebp
 37e:	57                   	push   %edi
 37f:	56                   	push   %esi
 380:	53                   	push   %ebx
 381:	83 ec 2c             	sub    $0x2c,%esp
 384:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 38a:	0f 95 c3             	setne  %bl
 38d:	89 d0                	mov    %edx,%eax
 38f:	c1 e8 1f             	shr    $0x1f,%eax
 392:	84 c3                	test   %al,%bl
 394:	74 10                	je     3a6 <printint+0x2b>
    neg = 1;
    x = -xx;
 396:	f7 da                	neg    %edx
    neg = 1;
 398:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 39f:	be 00 00 00 00       	mov    $0x0,%esi
 3a4:	eb 0b                	jmp    3b1 <printint+0x36>
  neg = 0;
 3a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3ad:	eb f0                	jmp    39f <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3af:	89 c6                	mov    %eax,%esi
 3b1:	89 d0                	mov    %edx,%eax
 3b3:	ba 00 00 00 00       	mov    $0x0,%edx
 3b8:	f7 f1                	div    %ecx
 3ba:	89 c3                	mov    %eax,%ebx
 3bc:	8d 46 01             	lea    0x1(%esi),%eax
 3bf:	0f b6 92 f8 06 00 00 	movzbl 0x6f8(%edx),%edx
 3c6:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3ca:	89 da                	mov    %ebx,%edx
 3cc:	85 db                	test   %ebx,%ebx
 3ce:	75 df                	jne    3af <printint+0x34>
 3d0:	89 c3                	mov    %eax,%ebx
  if(neg)
 3d2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3d6:	74 16                	je     3ee <printint+0x73>
    buf[i++] = '-';
 3d8:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3dd:	8d 5e 02             	lea    0x2(%esi),%ebx
 3e0:	eb 0c                	jmp    3ee <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3e2:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3e7:	89 f8                	mov    %edi,%eax
 3e9:	e8 73 ff ff ff       	call   361 <putc>
  while(--i >= 0)
 3ee:	83 eb 01             	sub    $0x1,%ebx
 3f1:	79 ef                	jns    3e2 <printint+0x67>
}
 3f3:	83 c4 2c             	add    $0x2c,%esp
 3f6:	5b                   	pop    %ebx
 3f7:	5e                   	pop    %esi
 3f8:	5f                   	pop    %edi
 3f9:	5d                   	pop    %ebp
 3fa:	c3                   	ret    

000003fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	57                   	push   %edi
 3ff:	56                   	push   %esi
 400:	53                   	push   %ebx
 401:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 404:	8d 45 10             	lea    0x10(%ebp),%eax
 407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 40a:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 40f:	bb 00 00 00 00       	mov    $0x0,%ebx
 414:	eb 14                	jmp    42a <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 416:	89 fa                	mov    %edi,%edx
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	e8 41 ff ff ff       	call   361 <putc>
 420:	eb 05                	jmp    427 <printf+0x2c>
      }
    } else if(state == '%'){
 422:	83 fe 25             	cmp    $0x25,%esi
 425:	74 25                	je     44c <printf+0x51>
  for(i = 0; fmt[i]; i++){
 427:	83 c3 01             	add    $0x1,%ebx
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 431:	84 c0                	test   %al,%al
 433:	0f 84 23 01 00 00    	je     55c <printf+0x161>
    c = fmt[i] & 0xff;
 439:	0f be f8             	movsbl %al,%edi
 43c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 43f:	85 f6                	test   %esi,%esi
 441:	75 df                	jne    422 <printf+0x27>
      if(c == '%'){
 443:	83 f8 25             	cmp    $0x25,%eax
 446:	75 ce                	jne    416 <printf+0x1b>
        state = '%';
 448:	89 c6                	mov    %eax,%esi
 44a:	eb db                	jmp    427 <printf+0x2c>
      if(c == 'd'){
 44c:	83 f8 64             	cmp    $0x64,%eax
 44f:	74 49                	je     49a <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 451:	83 f8 78             	cmp    $0x78,%eax
 454:	0f 94 c1             	sete   %cl
 457:	83 f8 70             	cmp    $0x70,%eax
 45a:	0f 94 c2             	sete   %dl
 45d:	08 d1                	or     %dl,%cl
 45f:	75 63                	jne    4c4 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 461:	83 f8 73             	cmp    $0x73,%eax
 464:	0f 84 84 00 00 00    	je     4ee <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 46a:	83 f8 63             	cmp    $0x63,%eax
 46d:	0f 84 b7 00 00 00    	je     52a <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 473:	83 f8 25             	cmp    $0x25,%eax
 476:	0f 84 cc 00 00 00    	je     548 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 47c:	ba 25 00 00 00       	mov    $0x25,%edx
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	e8 d8 fe ff ff       	call   361 <putc>
        putc(fd, c);
 489:	89 fa                	mov    %edi,%edx
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	e8 ce fe ff ff       	call   361 <putc>
      }
      state = 0;
 493:	be 00 00 00 00       	mov    $0x0,%esi
 498:	eb 8d                	jmp    427 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 49a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 49d:	8b 17                	mov    (%edi),%edx
 49f:	83 ec 0c             	sub    $0xc,%esp
 4a2:	6a 01                	push   $0x1
 4a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	e8 ca fe ff ff       	call   37b <printint>
        ap++;
 4b1:	83 c7 04             	add    $0x4,%edi
 4b4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4b7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ba:	be 00 00 00 00       	mov    $0x0,%esi
 4bf:	e9 63 ff ff ff       	jmp    427 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c7:	8b 17                	mov    (%edi),%edx
 4c9:	83 ec 0c             	sub    $0xc,%esp
 4cc:	6a 00                	push   $0x0
 4ce:	b9 10 00 00 00       	mov    $0x10,%ecx
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	e8 a0 fe ff ff       	call   37b <printint>
        ap++;
 4db:	83 c7 04             	add    $0x4,%edi
 4de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4e4:	be 00 00 00 00       	mov    $0x0,%esi
 4e9:	e9 39 ff ff ff       	jmp    427 <printf+0x2c>
        s = (char*)*ap;
 4ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f1:	8b 30                	mov    (%eax),%esi
        ap++;
 4f3:	83 c0 04             	add    $0x4,%eax
 4f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4f9:	85 f6                	test   %esi,%esi
 4fb:	75 28                	jne    525 <printf+0x12a>
          s = "(null)";
 4fd:	be f0 06 00 00       	mov    $0x6f0,%esi
 502:	8b 7d 08             	mov    0x8(%ebp),%edi
 505:	eb 0d                	jmp    514 <printf+0x119>
          putc(fd, *s);
 507:	0f be d2             	movsbl %dl,%edx
 50a:	89 f8                	mov    %edi,%eax
 50c:	e8 50 fe ff ff       	call   361 <putc>
          s++;
 511:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 514:	0f b6 16             	movzbl (%esi),%edx
 517:	84 d2                	test   %dl,%dl
 519:	75 ec                	jne    507 <printf+0x10c>
      state = 0;
 51b:	be 00 00 00 00       	mov    $0x0,%esi
 520:	e9 02 ff ff ff       	jmp    427 <printf+0x2c>
 525:	8b 7d 08             	mov    0x8(%ebp),%edi
 528:	eb ea                	jmp    514 <printf+0x119>
        putc(fd, *ap);
 52a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 52d:	0f be 17             	movsbl (%edi),%edx
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	e8 29 fe ff ff       	call   361 <putc>
        ap++;
 538:	83 c7 04             	add    $0x4,%edi
 53b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 53e:	be 00 00 00 00       	mov    $0x0,%esi
 543:	e9 df fe ff ff       	jmp    427 <printf+0x2c>
        putc(fd, c);
 548:	89 fa                	mov    %edi,%edx
 54a:	8b 45 08             	mov    0x8(%ebp),%eax
 54d:	e8 0f fe ff ff       	call   361 <putc>
      state = 0;
 552:	be 00 00 00 00       	mov    $0x0,%esi
 557:	e9 cb fe ff ff       	jmp    427 <printf+0x2c>
    }
  }
}
 55c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 55f:	5b                   	pop    %ebx
 560:	5e                   	pop    %esi
 561:	5f                   	pop    %edi
 562:	5d                   	pop    %ebp
 563:	c3                   	ret    

00000564 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	57                   	push   %edi
 568:	56                   	push   %esi
 569:	53                   	push   %ebx
 56a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 56d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 570:	a1 9c 09 00 00       	mov    0x99c,%eax
 575:	eb 02                	jmp    579 <free+0x15>
 577:	89 d0                	mov    %edx,%eax
 579:	39 c8                	cmp    %ecx,%eax
 57b:	73 04                	jae    581 <free+0x1d>
 57d:	39 08                	cmp    %ecx,(%eax)
 57f:	77 12                	ja     593 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 581:	8b 10                	mov    (%eax),%edx
 583:	39 c2                	cmp    %eax,%edx
 585:	77 f0                	ja     577 <free+0x13>
 587:	39 c8                	cmp    %ecx,%eax
 589:	72 08                	jb     593 <free+0x2f>
 58b:	39 ca                	cmp    %ecx,%edx
 58d:	77 04                	ja     593 <free+0x2f>
 58f:	89 d0                	mov    %edx,%eax
 591:	eb e6                	jmp    579 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 593:	8b 73 fc             	mov    -0x4(%ebx),%esi
 596:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 599:	8b 10                	mov    (%eax),%edx
 59b:	39 d7                	cmp    %edx,%edi
 59d:	74 19                	je     5b8 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 59f:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5a2:	8b 50 04             	mov    0x4(%eax),%edx
 5a5:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5a8:	39 ce                	cmp    %ecx,%esi
 5aa:	74 1b                	je     5c7 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ac:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5ae:	a3 9c 09 00 00       	mov    %eax,0x99c
}
 5b3:	5b                   	pop    %ebx
 5b4:	5e                   	pop    %esi
 5b5:	5f                   	pop    %edi
 5b6:	5d                   	pop    %ebp
 5b7:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5b8:	03 72 04             	add    0x4(%edx),%esi
 5bb:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5be:	8b 10                	mov    (%eax),%edx
 5c0:	8b 12                	mov    (%edx),%edx
 5c2:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5c5:	eb db                	jmp    5a2 <free+0x3e>
    p->s.size += bp->s.size;
 5c7:	03 53 fc             	add    -0x4(%ebx),%edx
 5ca:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5cd:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5d0:	89 10                	mov    %edx,(%eax)
 5d2:	eb da                	jmp    5ae <free+0x4a>

000005d4 <morecore>:

static Header*
morecore(uint nu)
{
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	53                   	push   %ebx
 5d8:	83 ec 04             	sub    $0x4,%esp
 5db:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5dd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5e2:	77 05                	ja     5e9 <morecore+0x15>
    nu = 4096;
 5e4:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5e9:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5f0:	83 ec 0c             	sub    $0xc,%esp
 5f3:	50                   	push   %eax
 5f4:	e8 30 fd ff ff       	call   329 <sbrk>
  if(p == (char*)-1)
 5f9:	83 c4 10             	add    $0x10,%esp
 5fc:	83 f8 ff             	cmp    $0xffffffff,%eax
 5ff:	74 1c                	je     61d <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 601:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 604:	83 c0 08             	add    $0x8,%eax
 607:	83 ec 0c             	sub    $0xc,%esp
 60a:	50                   	push   %eax
 60b:	e8 54 ff ff ff       	call   564 <free>
  return freep;
 610:	a1 9c 09 00 00       	mov    0x99c,%eax
 615:	83 c4 10             	add    $0x10,%esp
}
 618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 61b:	c9                   	leave  
 61c:	c3                   	ret    
    return 0;
 61d:	b8 00 00 00 00       	mov    $0x0,%eax
 622:	eb f4                	jmp    618 <morecore+0x44>

00000624 <malloc>:

void*
malloc(uint nbytes)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	53                   	push   %ebx
 628:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 62b:	8b 45 08             	mov    0x8(%ebp),%eax
 62e:	8d 58 07             	lea    0x7(%eax),%ebx
 631:	c1 eb 03             	shr    $0x3,%ebx
 634:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 637:	8b 0d 9c 09 00 00    	mov    0x99c,%ecx
 63d:	85 c9                	test   %ecx,%ecx
 63f:	74 04                	je     645 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 641:	8b 01                	mov    (%ecx),%eax
 643:	eb 4d                	jmp    692 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 645:	c7 05 9c 09 00 00 a0 	movl   $0x9a0,0x99c
 64c:	09 00 00 
 64f:	c7 05 a0 09 00 00 a0 	movl   $0x9a0,0x9a0
 656:	09 00 00 
    base.s.size = 0;
 659:	c7 05 a4 09 00 00 00 	movl   $0x0,0x9a4
 660:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 663:	b9 a0 09 00 00       	mov    $0x9a0,%ecx
 668:	eb d7                	jmp    641 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 66a:	39 da                	cmp    %ebx,%edx
 66c:	74 1a                	je     688 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 66e:	29 da                	sub    %ebx,%edx
 670:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 673:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 676:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 679:	89 0d 9c 09 00 00    	mov    %ecx,0x99c
      return (void*)(p + 1);
 67f:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 682:	83 c4 04             	add    $0x4,%esp
 685:	5b                   	pop    %ebx
 686:	5d                   	pop    %ebp
 687:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 688:	8b 10                	mov    (%eax),%edx
 68a:	89 11                	mov    %edx,(%ecx)
 68c:	eb eb                	jmp    679 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 68e:	89 c1                	mov    %eax,%ecx
 690:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 692:	8b 50 04             	mov    0x4(%eax),%edx
 695:	39 da                	cmp    %ebx,%edx
 697:	73 d1                	jae    66a <malloc+0x46>
    if(p == freep)
 699:	39 05 9c 09 00 00    	cmp    %eax,0x99c
 69f:	75 ed                	jne    68e <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6a1:	89 d8                	mov    %ebx,%eax
 6a3:	e8 2c ff ff ff       	call   5d4 <morecore>
 6a8:	85 c0                	test   %eax,%eax
 6aa:	75 e2                	jne    68e <malloc+0x6a>
        return 0;
 6ac:	b8 00 00 00 00       	mov    $0x0,%eax
 6b1:	eb cf                	jmp    682 <malloc+0x5e>
