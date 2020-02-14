
_userRR:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#else
# define DEBUG_PRINT(x) do {} while (0)
#endif

//char buf[10000]; // ~10KB
int workload(int n, int t) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
   8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  int i, j = 0;
   b:	bb 00 00 00 00       	mov    $0x0,%ebx
  for (i = 0; i < n; i++) {
  10:	b8 00 00 00 00       	mov    $0x0,%eax
  15:	eb 0c                	jmp    23 <workload+0x23>
    j += i * j + 1;
  17:	89 c2                	mov    %eax,%edx
  19:	0f af d3             	imul   %ebx,%edx
  1c:	8d 5c 1a 01          	lea    0x1(%edx,%ebx,1),%ebx
  for (i = 0; i < n; i++) {
  20:	83 c0 01             	add    $0x1,%eax
  23:	39 f0                	cmp    %esi,%eax
  25:	7c f0                	jl     17 <workload+0x17>
  }

  if (t > 0) sleep(t);
  27:	85 c9                	test   %ecx,%ecx
  29:	7f 07                	jg     32 <workload+0x32>
  for (i = 0; i < n; i++) {
  2b:	b8 00 00 00 00       	mov    $0x0,%eax
  30:	eb 1a                	jmp    4c <workload+0x4c>
  if (t > 0) sleep(t);
  32:	83 ec 0c             	sub    $0xc,%esp
  35:	51                   	push   %ecx
  36:	e8 07 04 00 00       	call   442 <sleep>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb eb                	jmp    2b <workload+0x2b>
    j += i * j + 1;
  40:	89 c2                	mov    %eax,%edx
  42:	0f af d3             	imul   %ebx,%edx
  45:	8d 5c 1a 01          	lea    0x1(%edx,%ebx,1),%ebx
  for (i = 0; i < n; i++) {
  49:	83 c0 01             	add    $0x1,%eax
  4c:	39 f0                	cmp    %esi,%eax
  4e:	7c f0                	jl     40 <workload+0x40>
  }
  return j;
}
  50:	89 d8                	mov    %ebx,%eax
  52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  55:	5b                   	pop    %ebx
  56:	5e                   	pop    %esi
  57:	5d                   	pop    %ebp
  58:	c3                   	ret    

00000059 <sleepload>:

int sleepload(int n, int t){
  59:	55                   	push   %ebp
  5a:	89 e5                	mov    %esp,%ebp
  5c:	56                   	push   %esi
  5d:	53                   	push   %ebx
  5e:	8b 75 08             	mov    0x8(%ebp),%esi
  int i;
  for(i = 0; i < n; i++){
  61:	bb 00 00 00 00       	mov    $0x0,%ebx
  66:	eb 10                	jmp    78 <sleepload+0x1f>
   // printf(1, "XV6_SCHEDULER\t Sleep\n");
    sleep(1);
  68:	83 ec 0c             	sub    $0xc,%esp
  6b:	6a 01                	push   $0x1
  6d:	e8 d0 03 00 00       	call   442 <sleep>
  for(i = 0; i < n; i++){
  72:	83 c3 01             	add    $0x1,%ebx
  75:	83 c4 10             	add    $0x10,%esp
  78:	39 f3                	cmp    %esi,%ebx
  7a:	7c ec                	jl     68 <sleepload+0xf>
  }
  return i;
}
  7c:	89 d8                	mov    %ebx,%eax
  7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  81:	5b                   	pop    %ebx
  82:	5e                   	pop    %esi
  83:	5d                   	pop    %ebp
  84:	c3                   	ret    

00000085 <main>:

int
main(int argc, char *argv[])
{
  85:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  89:	83 e4 f0             	and    $0xfffffff0,%esp
  8c:	ff 71 fc             	pushl  -0x4(%ecx)
  8f:	55                   	push   %ebp
  90:	89 e5                	mov    %esp,%ebp
  92:	57                   	push   %edi
  93:	56                   	push   %esi
  94:	53                   	push   %ebx
  95:	51                   	push   %ecx
  96:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  9c:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  a2:	50                   	push   %eax
  a3:	e8 ba 03 00 00       	call   462 <getpinfo>
  a8:	83 c4 10             	add    $0x10,%esp
  ab:	85 c0                	test   %eax,%eax
  ad:	75 27                	jne    d6 <main+0x51>

  // Push this thread to the bottom
  workload(100, 0);
  af:	83 ec 08             	sub    $0x8,%esp
  b2:	6a 00                	push   $0x0
  b4:	6a 64                	push   $0x64
  b6:	e8 45 ff ff ff       	call   0 <workload>

  int i, j, k;

  // Launch the 4 processes, but process 2 will sleep in the middle
  for (i = 0; i < 1; i++) {
  bb:	83 c4 10             	add    $0x10,%esp
  be:	bb 00 00 00 00       	mov    $0x0,%ebx
  c3:	85 db                	test   %ebx,%ebx
  c5:	7e 2f                	jle    f6 <main+0x71>
    } else {
      //setpri(c_pid, 2);
    }
  }

  for (i = 0; i < 12; i++) { 
  c7:	c7 85 e4 f3 ff ff 00 	movl   $0x0,-0xc1c(%ebp)
  ce:	00 00 00 
  d1:	e9 00 01 00 00       	jmp    1d6 <main+0x151>
  check(getpinfo(&st) == 0, "getpinfo");
  d6:	83 ec 0c             	sub    $0xc,%esp
  d9:	68 c4 07 00 00       	push   $0x7c4
  de:	6a 2d                	push   $0x2d
  e0:	68 cd 07 00 00       	push   $0x7cd
  e5:	68 ec 07 00 00       	push   $0x7ec
  ea:	6a 01                	push   $0x1
  ec:	e8 1b 04 00 00       	call   50c <printf>
  f1:	83 c4 20             	add    $0x20,%esp
  f4:	eb b9                	jmp    af <main+0x2a>
    int c_pid = fork2(2);
  f6:	83 ec 0c             	sub    $0xc,%esp
  f9:	6a 02                	push   $0x2
  fb:	e8 6a 03 00 00       	call   46a <fork2>
 100:	89 c1                	mov    %eax,%ecx
    if (c_pid == 0) {
 102:	83 c4 10             	add    $0x10,%esp
 105:	85 c0                	test   %eax,%eax
 107:	74 05                	je     10e <main+0x89>
  for (i = 0; i < 1; i++) {
 109:	83 c3 01             	add    $0x1,%ebx
 10c:	eb b5                	jmp    c3 <main+0x3e>
      if (i % 2 == 1) {
 10e:	be 02 00 00 00       	mov    $0x2,%esi
 113:	89 d8                	mov    %ebx,%eax
 115:	99                   	cltd   
 116:	f7 fe                	idiv   %esi
 118:	83 fa 01             	cmp    $0x1,%edx
 11b:	74 13                	je     130 <main+0xab>
      sleepload(200, t);
 11d:	83 ec 08             	sub    $0x8,%esp
 120:	51                   	push   %ecx
 121:	68 c8 00 00 00       	push   $0xc8
 126:	e8 2e ff ff ff       	call   59 <sleepload>
      exit();
 12b:	e8 82 02 00 00       	call   3b2 <exit>
          t = 64*5; // for this process, give up CPU for one time-slice
 130:	b9 40 01 00 00       	mov    $0x140,%ecx
 135:	eb e6                	jmp    11d <main+0x98>
    sleep(12);
    check(getpinfo(&st) == 0, "getpinfo");
 137:	83 ec 0c             	sub    $0xc,%esp
 13a:	68 c4 07 00 00       	push   $0x7c4
 13f:	6a 46                	push   $0x46
 141:	68 cd 07 00 00       	push   $0x7cd
 146:	68 ec 07 00 00       	push   $0x7ec
 14b:	6a 01                	push   $0x1
 14d:	e8 ba 03 00 00       	call   50c <printf>
 152:	83 c4 20             	add    $0x20,%esp
 155:	e9 a8 00 00 00       	jmp    202 <main+0x17d>
    
    for (j = 0; j < NPROC; j++) {
 15a:	83 c3 01             	add    $0x1,%ebx
 15d:	83 fb 3f             	cmp    $0x3f,%ebx
 160:	7f 6d                	jg     1cf <main+0x14a>
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
 162:	83 bc 9d e8 f3 ff ff 	cmpl   $0x0,-0xc18(%ebp,%ebx,4)
 169:	00 
 16a:	74 ee                	je     15a <main+0xd5>
 16c:	8b b4 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%esi
 173:	83 fe 02             	cmp    $0x2,%esi
 176:	7e e2                	jle    15a <main+0xd5>
 178:	e8 b5 02 00 00       	call   432 <getpid>
 17d:	39 c6                	cmp    %eax,%esi
 17f:	74 d9                	je     15a <main+0xd5>
	DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD\n"));
 181:	83 ec 08             	sub    $0x8,%esp
 184:	68 d6 07 00 00       	push   $0x7d6
 189:	6a 01                	push   $0x1
 18b:	e8 7c 03 00 00       	call   50c <printf>
        //DEBUG_PRINT((1, "pid: %d\n", st.pid[j]));
        for (k = 3; k >= 0; k--) {
 190:	83 c4 10             	add    $0x10,%esp
 193:	be 03 00 00 00       	mov    $0x3,%esi
 198:	85 f6                	test   %esi,%esi
 19a:	78 be                	js     15a <main+0xd5>
          DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d ticks used %d\n", k, st.ticks[j][k]));
 19c:	8d 3c 9e             	lea    (%esi,%ebx,4),%edi
 19f:	ff b4 bd e8 f7 ff ff 	pushl  -0x818(%ebp,%edi,4)
 1a6:	56                   	push   %esi
 1a7:	68 1c 08 00 00       	push   $0x81c
 1ac:	6a 01                	push   $0x1
 1ae:	e8 59 03 00 00       	call   50c <printf>
	  DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d qtail %d\n", k, st.qtail[j][k]));
 1b3:	ff b4 bd e8 fb ff ff 	pushl  -0x418(%ebp,%edi,4)
 1ba:	56                   	push   %esi
 1bb:	68 48 08 00 00       	push   $0x848
 1c0:	6a 01                	push   $0x1
 1c2:	e8 45 03 00 00       	call   50c <printf>
        for (k = 3; k >= 0; k--) {
 1c7:	83 ee 01             	sub    $0x1,%esi
 1ca:	83 c4 20             	add    $0x20,%esp
 1cd:	eb c9                	jmp    198 <main+0x113>
  for (i = 0; i < 12; i++) { 
 1cf:	83 85 e4 f3 ff ff 01 	addl   $0x1,-0xc1c(%ebp)
 1d6:	83 bd e4 f3 ff ff 0b 	cmpl   $0xb,-0xc1c(%ebp)
 1dd:	7f 2d                	jg     20c <main+0x187>
    sleep(12);
 1df:	83 ec 0c             	sub    $0xc,%esp
 1e2:	6a 0c                	push   $0xc
 1e4:	e8 59 02 00 00       	call   442 <sleep>
    check(getpinfo(&st) == 0, "getpinfo");
 1e9:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1ef:	89 04 24             	mov    %eax,(%esp)
 1f2:	e8 6b 02 00 00       	call   462 <getpinfo>
 1f7:	83 c4 10             	add    $0x10,%esp
 1fa:	85 c0                	test   %eax,%eax
 1fc:	0f 85 35 ff ff ff    	jne    137 <main+0xb2>
        for (k = 3; k >= 0; k--) {
 202:	bb 00 00 00 00       	mov    $0x0,%ebx
 207:	e9 51 ff ff ff       	jmp    15d <main+0xd8>
        }
      } 
    }
  }

  for (i = 0; i < 6; i++) {
 20c:	bb 00 00 00 00       	mov    $0x0,%ebx
 211:	eb 08                	jmp    21b <main+0x196>
    wait();
 213:	e8 a2 01 00 00       	call   3ba <wait>
  for (i = 0; i < 6; i++) {
 218:	83 c3 01             	add    $0x1,%ebx
 21b:	83 fb 05             	cmp    $0x5,%ebx
 21e:	7e f3                	jle    213 <main+0x18e>
  }

  //printf(1, "TEST PASSED");

  exit();
 220:	e8 8d 01 00 00       	call   3b2 <exit>

00000225 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 225:	55                   	push   %ebp
 226:	89 e5                	mov    %esp,%ebp
 228:	53                   	push   %ebx
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 22f:	89 c2                	mov    %eax,%edx
 231:	0f b6 19             	movzbl (%ecx),%ebx
 234:	88 1a                	mov    %bl,(%edx)
 236:	8d 52 01             	lea    0x1(%edx),%edx
 239:	8d 49 01             	lea    0x1(%ecx),%ecx
 23c:	84 db                	test   %bl,%bl
 23e:	75 f1                	jne    231 <strcpy+0xc>
    ;
  return os;
}
 240:	5b                   	pop    %ebx
 241:	5d                   	pop    %ebp
 242:	c3                   	ret    

00000243 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 243:	55                   	push   %ebp
 244:	89 e5                	mov    %esp,%ebp
 246:	8b 4d 08             	mov    0x8(%ebp),%ecx
 249:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 24c:	eb 06                	jmp    254 <strcmp+0x11>
    p++, q++;
 24e:	83 c1 01             	add    $0x1,%ecx
 251:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 254:	0f b6 01             	movzbl (%ecx),%eax
 257:	84 c0                	test   %al,%al
 259:	74 04                	je     25f <strcmp+0x1c>
 25b:	3a 02                	cmp    (%edx),%al
 25d:	74 ef                	je     24e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 25f:	0f b6 c0             	movzbl %al,%eax
 262:	0f b6 12             	movzbl (%edx),%edx
 265:	29 d0                	sub    %edx,%eax
}
 267:	5d                   	pop    %ebp
 268:	c3                   	ret    

00000269 <strlen>:

uint
strlen(const char *s)
{
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
 26c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 26f:	ba 00 00 00 00       	mov    $0x0,%edx
 274:	eb 03                	jmp    279 <strlen+0x10>
 276:	83 c2 01             	add    $0x1,%edx
 279:	89 d0                	mov    %edx,%eax
 27b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 27f:	75 f5                	jne    276 <strlen+0xd>
    ;
  return n;
}
 281:	5d                   	pop    %ebp
 282:	c3                   	ret    

00000283 <memset>:

void*
memset(void *dst, int c, uint n)
{
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	57                   	push   %edi
 287:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 28a:	89 d7                	mov    %edx,%edi
 28c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 28f:	8b 45 0c             	mov    0xc(%ebp),%eax
 292:	fc                   	cld    
 293:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 295:	89 d0                	mov    %edx,%eax
 297:	5f                   	pop    %edi
 298:	5d                   	pop    %ebp
 299:	c3                   	ret    

0000029a <strchr>:

char*
strchr(const char *s, char c)
{
 29a:	55                   	push   %ebp
 29b:	89 e5                	mov    %esp,%ebp
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 2a4:	0f b6 10             	movzbl (%eax),%edx
 2a7:	84 d2                	test   %dl,%dl
 2a9:	74 09                	je     2b4 <strchr+0x1a>
    if(*s == c)
 2ab:	38 ca                	cmp    %cl,%dl
 2ad:	74 0a                	je     2b9 <strchr+0x1f>
  for(; *s; s++)
 2af:	83 c0 01             	add    $0x1,%eax
 2b2:	eb f0                	jmp    2a4 <strchr+0xa>
      return (char*)s;
  return 0;
 2b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2b9:	5d                   	pop    %ebp
 2ba:	c3                   	ret    

000002bb <gets>:

char*
gets(char *buf, int max)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
 2be:	57                   	push   %edi
 2bf:	56                   	push   %esi
 2c0:	53                   	push   %ebx
 2c1:	83 ec 1c             	sub    $0x1c,%esp
 2c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c7:	bb 00 00 00 00       	mov    $0x0,%ebx
 2cc:	8d 73 01             	lea    0x1(%ebx),%esi
 2cf:	3b 75 0c             	cmp    0xc(%ebp),%esi
 2d2:	7d 2e                	jge    302 <gets+0x47>
    cc = read(0, &c, 1);
 2d4:	83 ec 04             	sub    $0x4,%esp
 2d7:	6a 01                	push   $0x1
 2d9:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2dc:	50                   	push   %eax
 2dd:	6a 00                	push   $0x0
 2df:	e8 e6 00 00 00       	call   3ca <read>
    if(cc < 1)
 2e4:	83 c4 10             	add    $0x10,%esp
 2e7:	85 c0                	test   %eax,%eax
 2e9:	7e 17                	jle    302 <gets+0x47>
      break;
    buf[i++] = c;
 2eb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2ef:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 2f2:	3c 0a                	cmp    $0xa,%al
 2f4:	0f 94 c2             	sete   %dl
 2f7:	3c 0d                	cmp    $0xd,%al
 2f9:	0f 94 c0             	sete   %al
    buf[i++] = c;
 2fc:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 2fe:	08 c2                	or     %al,%dl
 300:	74 ca                	je     2cc <gets+0x11>
      break;
  }
  buf[i] = '\0';
 302:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 306:	89 f8                	mov    %edi,%eax
 308:	8d 65 f4             	lea    -0xc(%ebp),%esp
 30b:	5b                   	pop    %ebx
 30c:	5e                   	pop    %esi
 30d:	5f                   	pop    %edi
 30e:	5d                   	pop    %ebp
 30f:	c3                   	ret    

00000310 <stat>:

int
stat(const char *n, struct stat *st)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	56                   	push   %esi
 314:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 315:	83 ec 08             	sub    $0x8,%esp
 318:	6a 00                	push   $0x0
 31a:	ff 75 08             	pushl  0x8(%ebp)
 31d:	e8 d0 00 00 00       	call   3f2 <open>
  if(fd < 0)
 322:	83 c4 10             	add    $0x10,%esp
 325:	85 c0                	test   %eax,%eax
 327:	78 24                	js     34d <stat+0x3d>
 329:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 32b:	83 ec 08             	sub    $0x8,%esp
 32e:	ff 75 0c             	pushl  0xc(%ebp)
 331:	50                   	push   %eax
 332:	e8 d3 00 00 00       	call   40a <fstat>
 337:	89 c6                	mov    %eax,%esi
  close(fd);
 339:	89 1c 24             	mov    %ebx,(%esp)
 33c:	e8 99 00 00 00       	call   3da <close>
  return r;
 341:	83 c4 10             	add    $0x10,%esp
}
 344:	89 f0                	mov    %esi,%eax
 346:	8d 65 f8             	lea    -0x8(%ebp),%esp
 349:	5b                   	pop    %ebx
 34a:	5e                   	pop    %esi
 34b:	5d                   	pop    %ebp
 34c:	c3                   	ret    
    return -1;
 34d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 352:	eb f0                	jmp    344 <stat+0x34>

00000354 <atoi>:

int
atoi(const char *s)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	53                   	push   %ebx
 358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 35b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 360:	eb 10                	jmp    372 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 362:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 365:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 368:	83 c1 01             	add    $0x1,%ecx
 36b:	0f be d2             	movsbl %dl,%edx
 36e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 372:	0f b6 11             	movzbl (%ecx),%edx
 375:	8d 5a d0             	lea    -0x30(%edx),%ebx
 378:	80 fb 09             	cmp    $0x9,%bl
 37b:	76 e5                	jbe    362 <atoi+0xe>
  return n;
}
 37d:	5b                   	pop    %ebx
 37e:	5d                   	pop    %ebp
 37f:	c3                   	ret    

00000380 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	56                   	push   %esi
 384:	53                   	push   %ebx
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 38b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 38e:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 390:	eb 0d                	jmp    39f <memmove+0x1f>
    *dst++ = *src++;
 392:	0f b6 13             	movzbl (%ebx),%edx
 395:	88 11                	mov    %dl,(%ecx)
 397:	8d 5b 01             	lea    0x1(%ebx),%ebx
 39a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 39d:	89 f2                	mov    %esi,%edx
 39f:	8d 72 ff             	lea    -0x1(%edx),%esi
 3a2:	85 d2                	test   %edx,%edx
 3a4:	7f ec                	jg     392 <memmove+0x12>
  return vdst;
}
 3a6:	5b                   	pop    %ebx
 3a7:	5e                   	pop    %esi
 3a8:	5d                   	pop    %ebp
 3a9:	c3                   	ret    

000003aa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3aa:	b8 01 00 00 00       	mov    $0x1,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <exit>:
SYSCALL(exit)
 3b2:	b8 02 00 00 00       	mov    $0x2,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <wait>:
SYSCALL(wait)
 3ba:	b8 03 00 00 00       	mov    $0x3,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <pipe>:
SYSCALL(pipe)
 3c2:	b8 04 00 00 00       	mov    $0x4,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <read>:
SYSCALL(read)
 3ca:	b8 05 00 00 00       	mov    $0x5,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <write>:
SYSCALL(write)
 3d2:	b8 10 00 00 00       	mov    $0x10,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <close>:
SYSCALL(close)
 3da:	b8 15 00 00 00       	mov    $0x15,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <kill>:
SYSCALL(kill)
 3e2:	b8 06 00 00 00       	mov    $0x6,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <exec>:
SYSCALL(exec)
 3ea:	b8 07 00 00 00       	mov    $0x7,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <open>:
SYSCALL(open)
 3f2:	b8 0f 00 00 00       	mov    $0xf,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <mknod>:
SYSCALL(mknod)
 3fa:	b8 11 00 00 00       	mov    $0x11,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <unlink>:
SYSCALL(unlink)
 402:	b8 12 00 00 00       	mov    $0x12,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <fstat>:
SYSCALL(fstat)
 40a:	b8 08 00 00 00       	mov    $0x8,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <link>:
SYSCALL(link)
 412:	b8 13 00 00 00       	mov    $0x13,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <mkdir>:
SYSCALL(mkdir)
 41a:	b8 14 00 00 00       	mov    $0x14,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <chdir>:
SYSCALL(chdir)
 422:	b8 09 00 00 00       	mov    $0x9,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <dup>:
SYSCALL(dup)
 42a:	b8 0a 00 00 00       	mov    $0xa,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <getpid>:
SYSCALL(getpid)
 432:	b8 0b 00 00 00       	mov    $0xb,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <sbrk>:
SYSCALL(sbrk)
 43a:	b8 0c 00 00 00       	mov    $0xc,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <sleep>:
SYSCALL(sleep)
 442:	b8 0d 00 00 00       	mov    $0xd,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <uptime>:
SYSCALL(uptime)
 44a:	b8 0e 00 00 00       	mov    $0xe,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <setpri>:
SYSCALL(setpri)
 452:	b8 16 00 00 00       	mov    $0x16,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <getpri>:
SYSCALL(getpri)
 45a:	b8 17 00 00 00       	mov    $0x17,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <getpinfo>:
SYSCALL(getpinfo)
 462:	b8 18 00 00 00       	mov    $0x18,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <fork2>:
SYSCALL(fork2)
 46a:	b8 19 00 00 00       	mov    $0x19,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 472:	55                   	push   %ebp
 473:	89 e5                	mov    %esp,%ebp
 475:	83 ec 1c             	sub    $0x1c,%esp
 478:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 47b:	6a 01                	push   $0x1
 47d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 480:	52                   	push   %edx
 481:	50                   	push   %eax
 482:	e8 4b ff ff ff       	call   3d2 <write>
}
 487:	83 c4 10             	add    $0x10,%esp
 48a:	c9                   	leave  
 48b:	c3                   	ret    

0000048c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 48c:	55                   	push   %ebp
 48d:	89 e5                	mov    %esp,%ebp
 48f:	57                   	push   %edi
 490:	56                   	push   %esi
 491:	53                   	push   %ebx
 492:	83 ec 2c             	sub    $0x2c,%esp
 495:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 497:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 49b:	0f 95 c3             	setne  %bl
 49e:	89 d0                	mov    %edx,%eax
 4a0:	c1 e8 1f             	shr    $0x1f,%eax
 4a3:	84 c3                	test   %al,%bl
 4a5:	74 10                	je     4b7 <printint+0x2b>
    neg = 1;
    x = -xx;
 4a7:	f7 da                	neg    %edx
    neg = 1;
 4a9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4b0:	be 00 00 00 00       	mov    $0x0,%esi
 4b5:	eb 0b                	jmp    4c2 <printint+0x36>
  neg = 0;
 4b7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 4be:	eb f0                	jmp    4b0 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 4c0:	89 c6                	mov    %eax,%esi
 4c2:	89 d0                	mov    %edx,%eax
 4c4:	ba 00 00 00 00       	mov    $0x0,%edx
 4c9:	f7 f1                	div    %ecx
 4cb:	89 c3                	mov    %eax,%ebx
 4cd:	8d 46 01             	lea    0x1(%esi),%eax
 4d0:	0f b6 92 74 08 00 00 	movzbl 0x874(%edx),%edx
 4d7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 4db:	89 da                	mov    %ebx,%edx
 4dd:	85 db                	test   %ebx,%ebx
 4df:	75 df                	jne    4c0 <printint+0x34>
 4e1:	89 c3                	mov    %eax,%ebx
  if(neg)
 4e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 4e7:	74 16                	je     4ff <printint+0x73>
    buf[i++] = '-';
 4e9:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 4ee:	8d 5e 02             	lea    0x2(%esi),%ebx
 4f1:	eb 0c                	jmp    4ff <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 4f3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 4f8:	89 f8                	mov    %edi,%eax
 4fa:	e8 73 ff ff ff       	call   472 <putc>
  while(--i >= 0)
 4ff:	83 eb 01             	sub    $0x1,%ebx
 502:	79 ef                	jns    4f3 <printint+0x67>
}
 504:	83 c4 2c             	add    $0x2c,%esp
 507:	5b                   	pop    %ebx
 508:	5e                   	pop    %esi
 509:	5f                   	pop    %edi
 50a:	5d                   	pop    %ebp
 50b:	c3                   	ret    

0000050c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 50c:	55                   	push   %ebp
 50d:	89 e5                	mov    %esp,%ebp
 50f:	57                   	push   %edi
 510:	56                   	push   %esi
 511:	53                   	push   %ebx
 512:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 515:	8d 45 10             	lea    0x10(%ebp),%eax
 518:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 51b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 520:	bb 00 00 00 00       	mov    $0x0,%ebx
 525:	eb 14                	jmp    53b <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 527:	89 fa                	mov    %edi,%edx
 529:	8b 45 08             	mov    0x8(%ebp),%eax
 52c:	e8 41 ff ff ff       	call   472 <putc>
 531:	eb 05                	jmp    538 <printf+0x2c>
      }
    } else if(state == '%'){
 533:	83 fe 25             	cmp    $0x25,%esi
 536:	74 25                	je     55d <printf+0x51>
  for(i = 0; fmt[i]; i++){
 538:	83 c3 01             	add    $0x1,%ebx
 53b:	8b 45 0c             	mov    0xc(%ebp),%eax
 53e:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 542:	84 c0                	test   %al,%al
 544:	0f 84 23 01 00 00    	je     66d <printf+0x161>
    c = fmt[i] & 0xff;
 54a:	0f be f8             	movsbl %al,%edi
 54d:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 550:	85 f6                	test   %esi,%esi
 552:	75 df                	jne    533 <printf+0x27>
      if(c == '%'){
 554:	83 f8 25             	cmp    $0x25,%eax
 557:	75 ce                	jne    527 <printf+0x1b>
        state = '%';
 559:	89 c6                	mov    %eax,%esi
 55b:	eb db                	jmp    538 <printf+0x2c>
      if(c == 'd'){
 55d:	83 f8 64             	cmp    $0x64,%eax
 560:	74 49                	je     5ab <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 562:	83 f8 78             	cmp    $0x78,%eax
 565:	0f 94 c1             	sete   %cl
 568:	83 f8 70             	cmp    $0x70,%eax
 56b:	0f 94 c2             	sete   %dl
 56e:	08 d1                	or     %dl,%cl
 570:	75 63                	jne    5d5 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 572:	83 f8 73             	cmp    $0x73,%eax
 575:	0f 84 84 00 00 00    	je     5ff <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 57b:	83 f8 63             	cmp    $0x63,%eax
 57e:	0f 84 b7 00 00 00    	je     63b <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 584:	83 f8 25             	cmp    $0x25,%eax
 587:	0f 84 cc 00 00 00    	je     659 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 58d:	ba 25 00 00 00       	mov    $0x25,%edx
 592:	8b 45 08             	mov    0x8(%ebp),%eax
 595:	e8 d8 fe ff ff       	call   472 <putc>
        putc(fd, c);
 59a:	89 fa                	mov    %edi,%edx
 59c:	8b 45 08             	mov    0x8(%ebp),%eax
 59f:	e8 ce fe ff ff       	call   472 <putc>
      }
      state = 0;
 5a4:	be 00 00 00 00       	mov    $0x0,%esi
 5a9:	eb 8d                	jmp    538 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 5ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5ae:	8b 17                	mov    (%edi),%edx
 5b0:	83 ec 0c             	sub    $0xc,%esp
 5b3:	6a 01                	push   $0x1
 5b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	e8 ca fe ff ff       	call   48c <printint>
        ap++;
 5c2:	83 c7 04             	add    $0x4,%edi
 5c5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5c8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5cb:	be 00 00 00 00       	mov    $0x0,%esi
 5d0:	e9 63 ff ff ff       	jmp    538 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 5d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5d8:	8b 17                	mov    (%edi),%edx
 5da:	83 ec 0c             	sub    $0xc,%esp
 5dd:	6a 00                	push   $0x0
 5df:	b9 10 00 00 00       	mov    $0x10,%ecx
 5e4:	8b 45 08             	mov    0x8(%ebp),%eax
 5e7:	e8 a0 fe ff ff       	call   48c <printint>
        ap++;
 5ec:	83 c7 04             	add    $0x4,%edi
 5ef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5f2:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5f5:	be 00 00 00 00       	mov    $0x0,%esi
 5fa:	e9 39 ff ff ff       	jmp    538 <printf+0x2c>
        s = (char*)*ap;
 5ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 602:	8b 30                	mov    (%eax),%esi
        ap++;
 604:	83 c0 04             	add    $0x4,%eax
 607:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 60a:	85 f6                	test   %esi,%esi
 60c:	75 28                	jne    636 <printf+0x12a>
          s = "(null)";
 60e:	be 6c 08 00 00       	mov    $0x86c,%esi
 613:	8b 7d 08             	mov    0x8(%ebp),%edi
 616:	eb 0d                	jmp    625 <printf+0x119>
          putc(fd, *s);
 618:	0f be d2             	movsbl %dl,%edx
 61b:	89 f8                	mov    %edi,%eax
 61d:	e8 50 fe ff ff       	call   472 <putc>
          s++;
 622:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 625:	0f b6 16             	movzbl (%esi),%edx
 628:	84 d2                	test   %dl,%dl
 62a:	75 ec                	jne    618 <printf+0x10c>
      state = 0;
 62c:	be 00 00 00 00       	mov    $0x0,%esi
 631:	e9 02 ff ff ff       	jmp    538 <printf+0x2c>
 636:	8b 7d 08             	mov    0x8(%ebp),%edi
 639:	eb ea                	jmp    625 <printf+0x119>
        putc(fd, *ap);
 63b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 63e:	0f be 17             	movsbl (%edi),%edx
 641:	8b 45 08             	mov    0x8(%ebp),%eax
 644:	e8 29 fe ff ff       	call   472 <putc>
        ap++;
 649:	83 c7 04             	add    $0x4,%edi
 64c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 64f:	be 00 00 00 00       	mov    $0x0,%esi
 654:	e9 df fe ff ff       	jmp    538 <printf+0x2c>
        putc(fd, c);
 659:	89 fa                	mov    %edi,%edx
 65b:	8b 45 08             	mov    0x8(%ebp),%eax
 65e:	e8 0f fe ff ff       	call   472 <putc>
      state = 0;
 663:	be 00 00 00 00       	mov    $0x0,%esi
 668:	e9 cb fe ff ff       	jmp    538 <printf+0x2c>
    }
  }
}
 66d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 670:	5b                   	pop    %ebx
 671:	5e                   	pop    %esi
 672:	5f                   	pop    %edi
 673:	5d                   	pop    %ebp
 674:	c3                   	ret    

00000675 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 675:	55                   	push   %ebp
 676:	89 e5                	mov    %esp,%ebp
 678:	57                   	push   %edi
 679:	56                   	push   %esi
 67a:	53                   	push   %ebx
 67b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 67e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 681:	a1 68 0b 00 00       	mov    0xb68,%eax
 686:	eb 02                	jmp    68a <free+0x15>
 688:	89 d0                	mov    %edx,%eax
 68a:	39 c8                	cmp    %ecx,%eax
 68c:	73 04                	jae    692 <free+0x1d>
 68e:	39 08                	cmp    %ecx,(%eax)
 690:	77 12                	ja     6a4 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 692:	8b 10                	mov    (%eax),%edx
 694:	39 c2                	cmp    %eax,%edx
 696:	77 f0                	ja     688 <free+0x13>
 698:	39 c8                	cmp    %ecx,%eax
 69a:	72 08                	jb     6a4 <free+0x2f>
 69c:	39 ca                	cmp    %ecx,%edx
 69e:	77 04                	ja     6a4 <free+0x2f>
 6a0:	89 d0                	mov    %edx,%eax
 6a2:	eb e6                	jmp    68a <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6a7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6aa:	8b 10                	mov    (%eax),%edx
 6ac:	39 d7                	cmp    %edx,%edi
 6ae:	74 19                	je     6c9 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6b0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6b3:	8b 50 04             	mov    0x4(%eax),%edx
 6b6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6b9:	39 ce                	cmp    %ecx,%esi
 6bb:	74 1b                	je     6d8 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6bd:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6bf:	a3 68 0b 00 00       	mov    %eax,0xb68
}
 6c4:	5b                   	pop    %ebx
 6c5:	5e                   	pop    %esi
 6c6:	5f                   	pop    %edi
 6c7:	5d                   	pop    %ebp
 6c8:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 6c9:	03 72 04             	add    0x4(%edx),%esi
 6cc:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6cf:	8b 10                	mov    (%eax),%edx
 6d1:	8b 12                	mov    (%edx),%edx
 6d3:	89 53 f8             	mov    %edx,-0x8(%ebx)
 6d6:	eb db                	jmp    6b3 <free+0x3e>
    p->s.size += bp->s.size;
 6d8:	03 53 fc             	add    -0x4(%ebx),%edx
 6db:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6de:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6e1:	89 10                	mov    %edx,(%eax)
 6e3:	eb da                	jmp    6bf <free+0x4a>

000006e5 <morecore>:

static Header*
morecore(uint nu)
{
 6e5:	55                   	push   %ebp
 6e6:	89 e5                	mov    %esp,%ebp
 6e8:	53                   	push   %ebx
 6e9:	83 ec 04             	sub    $0x4,%esp
 6ec:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 6ee:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 6f3:	77 05                	ja     6fa <morecore+0x15>
    nu = 4096;
 6f5:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 6fa:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 701:	83 ec 0c             	sub    $0xc,%esp
 704:	50                   	push   %eax
 705:	e8 30 fd ff ff       	call   43a <sbrk>
  if(p == (char*)-1)
 70a:	83 c4 10             	add    $0x10,%esp
 70d:	83 f8 ff             	cmp    $0xffffffff,%eax
 710:	74 1c                	je     72e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 712:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 715:	83 c0 08             	add    $0x8,%eax
 718:	83 ec 0c             	sub    $0xc,%esp
 71b:	50                   	push   %eax
 71c:	e8 54 ff ff ff       	call   675 <free>
  return freep;
 721:	a1 68 0b 00 00       	mov    0xb68,%eax
 726:	83 c4 10             	add    $0x10,%esp
}
 729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 72c:	c9                   	leave  
 72d:	c3                   	ret    
    return 0;
 72e:	b8 00 00 00 00       	mov    $0x0,%eax
 733:	eb f4                	jmp    729 <morecore+0x44>

00000735 <malloc>:

void*
malloc(uint nbytes)
{
 735:	55                   	push   %ebp
 736:	89 e5                	mov    %esp,%ebp
 738:	53                   	push   %ebx
 739:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73c:	8b 45 08             	mov    0x8(%ebp),%eax
 73f:	8d 58 07             	lea    0x7(%eax),%ebx
 742:	c1 eb 03             	shr    $0x3,%ebx
 745:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 748:	8b 0d 68 0b 00 00    	mov    0xb68,%ecx
 74e:	85 c9                	test   %ecx,%ecx
 750:	74 04                	je     756 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 752:	8b 01                	mov    (%ecx),%eax
 754:	eb 4d                	jmp    7a3 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 756:	c7 05 68 0b 00 00 6c 	movl   $0xb6c,0xb68
 75d:	0b 00 00 
 760:	c7 05 6c 0b 00 00 6c 	movl   $0xb6c,0xb6c
 767:	0b 00 00 
    base.s.size = 0;
 76a:	c7 05 70 0b 00 00 00 	movl   $0x0,0xb70
 771:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 774:	b9 6c 0b 00 00       	mov    $0xb6c,%ecx
 779:	eb d7                	jmp    752 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 77b:	39 da                	cmp    %ebx,%edx
 77d:	74 1a                	je     799 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 77f:	29 da                	sub    %ebx,%edx
 781:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 784:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 787:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 78a:	89 0d 68 0b 00 00    	mov    %ecx,0xb68
      return (void*)(p + 1);
 790:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 793:	83 c4 04             	add    $0x4,%esp
 796:	5b                   	pop    %ebx
 797:	5d                   	pop    %ebp
 798:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 799:	8b 10                	mov    (%eax),%edx
 79b:	89 11                	mov    %edx,(%ecx)
 79d:	eb eb                	jmp    78a <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79f:	89 c1                	mov    %eax,%ecx
 7a1:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 7a3:	8b 50 04             	mov    0x4(%eax),%edx
 7a6:	39 da                	cmp    %ebx,%edx
 7a8:	73 d1                	jae    77b <malloc+0x46>
    if(p == freep)
 7aa:	39 05 68 0b 00 00    	cmp    %eax,0xb68
 7b0:	75 ed                	jne    79f <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 7b2:	89 d8                	mov    %ebx,%eax
 7b4:	e8 2c ff ff ff       	call   6e5 <morecore>
 7b9:	85 c0                	test   %eax,%eax
 7bb:	75 e2                	jne    79f <malloc+0x6a>
        return 0;
 7bd:	b8 00 00 00 00       	mov    $0x0,%eax
 7c2:	eb cf                	jmp    793 <malloc+0x5e>
