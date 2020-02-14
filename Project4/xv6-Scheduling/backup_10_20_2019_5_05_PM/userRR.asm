
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
  36:	e8 de 03 00 00       	call   419 <sleep>
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

00000059 <main>:

int
main(int argc, char *argv[])
{
  59:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  5d:	83 e4 f0             	and    $0xfffffff0,%esp
  60:	ff 71 fc             	pushl  -0x4(%ecx)
  63:	55                   	push   %ebp
  64:	89 e5                	mov    %esp,%ebp
  66:	57                   	push   %edi
  67:	56                   	push   %esi
  68:	53                   	push   %ebx
  69:	51                   	push   %ecx
  6a:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  70:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  76:	50                   	push   %eax
  77:	e8 bd 03 00 00       	call   439 <getpinfo>
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	85 c0                	test   %eax,%eax
  81:	75 2a                	jne    ad <main+0x54>

  // Push this thread to the bottom
  workload(80000000, 0);
  83:	83 ec 08             	sub    $0x8,%esp
  86:	6a 00                	push   $0x0
  88:	68 00 b4 c4 04       	push   $0x4c4b400
  8d:	e8 6e ff ff ff       	call   0 <workload>

  int i, j, k;

  // Launch the 4 processes, but process 2 will sleep in the middle
  for (i = 0; i < 1; i++) {
  92:	83 c4 10             	add    $0x10,%esp
  95:	bb 00 00 00 00       	mov    $0x0,%ebx
  9a:	85 db                	test   %ebx,%ebx
  9c:	7e 2f                	jle    cd <main+0x74>
    } else {
      //setpri(c_pid, 2);
    }
  }

  for (i = 0; i < 12; i++) { 
  9e:	c7 85 e4 f3 ff ff 00 	movl   $0x0,-0xc1c(%ebp)
  a5:	00 00 00 
  a8:	e9 00 01 00 00       	jmp    1ad <main+0x154>
  check(getpinfo(&st) == 0, "getpinfo");
  ad:	83 ec 0c             	sub    $0xc,%esp
  b0:	68 9c 07 00 00       	push   $0x79c
  b5:	6a 24                	push   $0x24
  b7:	68 a5 07 00 00       	push   $0x7a5
  bc:	68 c4 07 00 00       	push   $0x7c4
  c1:	6a 01                	push   $0x1
  c3:	e8 1b 04 00 00       	call   4e3 <printf>
  c8:	83 c4 20             	add    $0x20,%esp
  cb:	eb b6                	jmp    83 <main+0x2a>
    int c_pid = fork2(2);
  cd:	83 ec 0c             	sub    $0xc,%esp
  d0:	6a 02                	push   $0x2
  d2:	e8 6a 03 00 00       	call   441 <fork2>
  d7:	89 c1                	mov    %eax,%ecx
    if (c_pid == 0) {
  d9:	83 c4 10             	add    $0x10,%esp
  dc:	85 c0                	test   %eax,%eax
  de:	74 05                	je     e5 <main+0x8c>
  for (i = 0; i < 1; i++) {
  e0:	83 c3 01             	add    $0x1,%ebx
  e3:	eb b5                	jmp    9a <main+0x41>
      if (i % 2 == 1) {
  e5:	be 02 00 00 00       	mov    $0x2,%esi
  ea:	89 d8                	mov    %ebx,%eax
  ec:	99                   	cltd   
  ed:	f7 fe                	idiv   %esi
  ef:	83 fa 01             	cmp    $0x1,%edx
  f2:	74 13                	je     107 <main+0xae>
      workload(300000000, t);
  f4:	83 ec 08             	sub    $0x8,%esp
  f7:	51                   	push   %ecx
  f8:	68 00 a3 e1 11       	push   $0x11e1a300
  fd:	e8 fe fe ff ff       	call   0 <workload>
      exit();
 102:	e8 82 02 00 00       	call   389 <exit>
          t = 64*5; // for this process, give up CPU for one time-slice
 107:	b9 40 01 00 00       	mov    $0x140,%ecx
 10c:	eb e6                	jmp    f4 <main+0x9b>
    sleep(12);
    check(getpinfo(&st) == 0, "getpinfo");
 10e:	83 ec 0c             	sub    $0xc,%esp
 111:	68 9c 07 00 00       	push   $0x79c
 116:	6a 3d                	push   $0x3d
 118:	68 a5 07 00 00       	push   $0x7a5
 11d:	68 c4 07 00 00       	push   $0x7c4
 122:	6a 01                	push   $0x1
 124:	e8 ba 03 00 00       	call   4e3 <printf>
 129:	83 c4 20             	add    $0x20,%esp
 12c:	e9 a8 00 00 00       	jmp    1d9 <main+0x180>
    
    for (j = 0; j < NPROC; j++) {
 131:	83 c3 01             	add    $0x1,%ebx
 134:	83 fb 3f             	cmp    $0x3f,%ebx
 137:	7f 6d                	jg     1a6 <main+0x14d>
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
 139:	83 bc 9d e8 f3 ff ff 	cmpl   $0x0,-0xc18(%ebp,%ebx,4)
 140:	00 
 141:	74 ee                	je     131 <main+0xd8>
 143:	8b b4 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%esi
 14a:	83 fe 02             	cmp    $0x2,%esi
 14d:	7e e2                	jle    131 <main+0xd8>
 14f:	e8 b5 02 00 00       	call   409 <getpid>
 154:	39 c6                	cmp    %eax,%esi
 156:	74 d9                	je     131 <main+0xd8>
	DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD\n"));
 158:	83 ec 08             	sub    $0x8,%esp
 15b:	68 ae 07 00 00       	push   $0x7ae
 160:	6a 01                	push   $0x1
 162:	e8 7c 03 00 00       	call   4e3 <printf>
        //DEBUG_PRINT((1, "pid: %d\n", st.pid[j]));
        for (k = 3; k >= 0; k--) {
 167:	83 c4 10             	add    $0x10,%esp
 16a:	be 03 00 00 00       	mov    $0x3,%esi
 16f:	85 f6                	test   %esi,%esi
 171:	78 be                	js     131 <main+0xd8>
          DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d ticks used %d\n", k, st.ticks[j][k]));
 173:	8d 3c 9e             	lea    (%esi,%ebx,4),%edi
 176:	ff b4 bd e8 f7 ff ff 	pushl  -0x818(%ebp,%edi,4)
 17d:	56                   	push   %esi
 17e:	68 f4 07 00 00       	push   $0x7f4
 183:	6a 01                	push   $0x1
 185:	e8 59 03 00 00       	call   4e3 <printf>
	  DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d qtail %d\n", k, st.qtail[j][k]));
 18a:	ff b4 bd e8 fb ff ff 	pushl  -0x418(%ebp,%edi,4)
 191:	56                   	push   %esi
 192:	68 20 08 00 00       	push   $0x820
 197:	6a 01                	push   $0x1
 199:	e8 45 03 00 00       	call   4e3 <printf>
        for (k = 3; k >= 0; k--) {
 19e:	83 ee 01             	sub    $0x1,%esi
 1a1:	83 c4 20             	add    $0x20,%esp
 1a4:	eb c9                	jmp    16f <main+0x116>
  for (i = 0; i < 12; i++) { 
 1a6:	83 85 e4 f3 ff ff 01 	addl   $0x1,-0xc1c(%ebp)
 1ad:	83 bd e4 f3 ff ff 0b 	cmpl   $0xb,-0xc1c(%ebp)
 1b4:	7f 2d                	jg     1e3 <main+0x18a>
    sleep(12);
 1b6:	83 ec 0c             	sub    $0xc,%esp
 1b9:	6a 0c                	push   $0xc
 1bb:	e8 59 02 00 00       	call   419 <sleep>
    check(getpinfo(&st) == 0, "getpinfo");
 1c0:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1c6:	89 04 24             	mov    %eax,(%esp)
 1c9:	e8 6b 02 00 00       	call   439 <getpinfo>
 1ce:	83 c4 10             	add    $0x10,%esp
 1d1:	85 c0                	test   %eax,%eax
 1d3:	0f 85 35 ff ff ff    	jne    10e <main+0xb5>
        for (k = 3; k >= 0; k--) {
 1d9:	bb 00 00 00 00       	mov    $0x0,%ebx
 1de:	e9 51 ff ff ff       	jmp    134 <main+0xdb>
        }
      } 
    }
  }

  for (i = 0; i < 6; i++) {
 1e3:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e8:	eb 08                	jmp    1f2 <main+0x199>
    wait();
 1ea:	e8 a2 01 00 00       	call   391 <wait>
  for (i = 0; i < 6; i++) {
 1ef:	83 c3 01             	add    $0x1,%ebx
 1f2:	83 fb 05             	cmp    $0x5,%ebx
 1f5:	7e f3                	jle    1ea <main+0x191>
  }

  //printf(1, "TEST PASSED");

  exit();
 1f7:	e8 8d 01 00 00       	call   389 <exit>

000001fc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	53                   	push   %ebx
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 206:	89 c2                	mov    %eax,%edx
 208:	0f b6 19             	movzbl (%ecx),%ebx
 20b:	88 1a                	mov    %bl,(%edx)
 20d:	8d 52 01             	lea    0x1(%edx),%edx
 210:	8d 49 01             	lea    0x1(%ecx),%ecx
 213:	84 db                	test   %bl,%bl
 215:	75 f1                	jne    208 <strcpy+0xc>
    ;
  return os;
}
 217:	5b                   	pop    %ebx
 218:	5d                   	pop    %ebp
 219:	c3                   	ret    

0000021a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
 21d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 220:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 223:	eb 06                	jmp    22b <strcmp+0x11>
    p++, q++;
 225:	83 c1 01             	add    $0x1,%ecx
 228:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 22b:	0f b6 01             	movzbl (%ecx),%eax
 22e:	84 c0                	test   %al,%al
 230:	74 04                	je     236 <strcmp+0x1c>
 232:	3a 02                	cmp    (%edx),%al
 234:	74 ef                	je     225 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 236:	0f b6 c0             	movzbl %al,%eax
 239:	0f b6 12             	movzbl (%edx),%edx
 23c:	29 d0                	sub    %edx,%eax
}
 23e:	5d                   	pop    %ebp
 23f:	c3                   	ret    

00000240 <strlen>:

uint
strlen(const char *s)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 246:	ba 00 00 00 00       	mov    $0x0,%edx
 24b:	eb 03                	jmp    250 <strlen+0x10>
 24d:	83 c2 01             	add    $0x1,%edx
 250:	89 d0                	mov    %edx,%eax
 252:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 256:	75 f5                	jne    24d <strlen+0xd>
    ;
  return n;
}
 258:	5d                   	pop    %ebp
 259:	c3                   	ret    

0000025a <memset>:

void*
memset(void *dst, int c, uint n)
{
 25a:	55                   	push   %ebp
 25b:	89 e5                	mov    %esp,%ebp
 25d:	57                   	push   %edi
 25e:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 261:	89 d7                	mov    %edx,%edi
 263:	8b 4d 10             	mov    0x10(%ebp),%ecx
 266:	8b 45 0c             	mov    0xc(%ebp),%eax
 269:	fc                   	cld    
 26a:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 26c:	89 d0                	mov    %edx,%eax
 26e:	5f                   	pop    %edi
 26f:	5d                   	pop    %ebp
 270:	c3                   	ret    

00000271 <strchr>:

char*
strchr(const char *s, char c)
{
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 27b:	0f b6 10             	movzbl (%eax),%edx
 27e:	84 d2                	test   %dl,%dl
 280:	74 09                	je     28b <strchr+0x1a>
    if(*s == c)
 282:	38 ca                	cmp    %cl,%dl
 284:	74 0a                	je     290 <strchr+0x1f>
  for(; *s; s++)
 286:	83 c0 01             	add    $0x1,%eax
 289:	eb f0                	jmp    27b <strchr+0xa>
      return (char*)s;
  return 0;
 28b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 290:	5d                   	pop    %ebp
 291:	c3                   	ret    

00000292 <gets>:

char*
gets(char *buf, int max)
{
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp
 295:	57                   	push   %edi
 296:	56                   	push   %esi
 297:	53                   	push   %ebx
 298:	83 ec 1c             	sub    $0x1c,%esp
 29b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 29e:	bb 00 00 00 00       	mov    $0x0,%ebx
 2a3:	8d 73 01             	lea    0x1(%ebx),%esi
 2a6:	3b 75 0c             	cmp    0xc(%ebp),%esi
 2a9:	7d 2e                	jge    2d9 <gets+0x47>
    cc = read(0, &c, 1);
 2ab:	83 ec 04             	sub    $0x4,%esp
 2ae:	6a 01                	push   $0x1
 2b0:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2b3:	50                   	push   %eax
 2b4:	6a 00                	push   $0x0
 2b6:	e8 e6 00 00 00       	call   3a1 <read>
    if(cc < 1)
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	85 c0                	test   %eax,%eax
 2c0:	7e 17                	jle    2d9 <gets+0x47>
      break;
    buf[i++] = c;
 2c2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2c6:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 2c9:	3c 0a                	cmp    $0xa,%al
 2cb:	0f 94 c2             	sete   %dl
 2ce:	3c 0d                	cmp    $0xd,%al
 2d0:	0f 94 c0             	sete   %al
    buf[i++] = c;
 2d3:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 2d5:	08 c2                	or     %al,%dl
 2d7:	74 ca                	je     2a3 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 2d9:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 2dd:	89 f8                	mov    %edi,%eax
 2df:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2e2:	5b                   	pop    %ebx
 2e3:	5e                   	pop    %esi
 2e4:	5f                   	pop    %edi
 2e5:	5d                   	pop    %ebp
 2e6:	c3                   	ret    

000002e7 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	56                   	push   %esi
 2eb:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ec:	83 ec 08             	sub    $0x8,%esp
 2ef:	6a 00                	push   $0x0
 2f1:	ff 75 08             	pushl  0x8(%ebp)
 2f4:	e8 d0 00 00 00       	call   3c9 <open>
  if(fd < 0)
 2f9:	83 c4 10             	add    $0x10,%esp
 2fc:	85 c0                	test   %eax,%eax
 2fe:	78 24                	js     324 <stat+0x3d>
 300:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 302:	83 ec 08             	sub    $0x8,%esp
 305:	ff 75 0c             	pushl  0xc(%ebp)
 308:	50                   	push   %eax
 309:	e8 d3 00 00 00       	call   3e1 <fstat>
 30e:	89 c6                	mov    %eax,%esi
  close(fd);
 310:	89 1c 24             	mov    %ebx,(%esp)
 313:	e8 99 00 00 00       	call   3b1 <close>
  return r;
 318:	83 c4 10             	add    $0x10,%esp
}
 31b:	89 f0                	mov    %esi,%eax
 31d:	8d 65 f8             	lea    -0x8(%ebp),%esp
 320:	5b                   	pop    %ebx
 321:	5e                   	pop    %esi
 322:	5d                   	pop    %ebp
 323:	c3                   	ret    
    return -1;
 324:	be ff ff ff ff       	mov    $0xffffffff,%esi
 329:	eb f0                	jmp    31b <stat+0x34>

0000032b <atoi>:

int
atoi(const char *s)
{
 32b:	55                   	push   %ebp
 32c:	89 e5                	mov    %esp,%ebp
 32e:	53                   	push   %ebx
 32f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 332:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 337:	eb 10                	jmp    349 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 339:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 33c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 33f:	83 c1 01             	add    $0x1,%ecx
 342:	0f be d2             	movsbl %dl,%edx
 345:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 349:	0f b6 11             	movzbl (%ecx),%edx
 34c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 34f:	80 fb 09             	cmp    $0x9,%bl
 352:	76 e5                	jbe    339 <atoi+0xe>
  return n;
}
 354:	5b                   	pop    %ebx
 355:	5d                   	pop    %ebp
 356:	c3                   	ret    

00000357 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 357:	55                   	push   %ebp
 358:	89 e5                	mov    %esp,%ebp
 35a:	56                   	push   %esi
 35b:	53                   	push   %ebx
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 362:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 365:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 367:	eb 0d                	jmp    376 <memmove+0x1f>
    *dst++ = *src++;
 369:	0f b6 13             	movzbl (%ebx),%edx
 36c:	88 11                	mov    %dl,(%ecx)
 36e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 371:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 374:	89 f2                	mov    %esi,%edx
 376:	8d 72 ff             	lea    -0x1(%edx),%esi
 379:	85 d2                	test   %edx,%edx
 37b:	7f ec                	jg     369 <memmove+0x12>
  return vdst;
}
 37d:	5b                   	pop    %ebx
 37e:	5e                   	pop    %esi
 37f:	5d                   	pop    %ebp
 380:	c3                   	ret    

00000381 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 381:	b8 01 00 00 00       	mov    $0x1,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <exit>:
SYSCALL(exit)
 389:	b8 02 00 00 00       	mov    $0x2,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <wait>:
SYSCALL(wait)
 391:	b8 03 00 00 00       	mov    $0x3,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <pipe>:
SYSCALL(pipe)
 399:	b8 04 00 00 00       	mov    $0x4,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret    

000003a1 <read>:
SYSCALL(read)
 3a1:	b8 05 00 00 00       	mov    $0x5,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <write>:
SYSCALL(write)
 3a9:	b8 10 00 00 00       	mov    $0x10,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <close>:
SYSCALL(close)
 3b1:	b8 15 00 00 00       	mov    $0x15,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <kill>:
SYSCALL(kill)
 3b9:	b8 06 00 00 00       	mov    $0x6,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <exec>:
SYSCALL(exec)
 3c1:	b8 07 00 00 00       	mov    $0x7,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <open>:
SYSCALL(open)
 3c9:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <mknod>:
SYSCALL(mknod)
 3d1:	b8 11 00 00 00       	mov    $0x11,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret    

000003d9 <unlink>:
SYSCALL(unlink)
 3d9:	b8 12 00 00 00       	mov    $0x12,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret    

000003e1 <fstat>:
SYSCALL(fstat)
 3e1:	b8 08 00 00 00       	mov    $0x8,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <link>:
SYSCALL(link)
 3e9:	b8 13 00 00 00       	mov    $0x13,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <mkdir>:
SYSCALL(mkdir)
 3f1:	b8 14 00 00 00       	mov    $0x14,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <chdir>:
SYSCALL(chdir)
 3f9:	b8 09 00 00 00       	mov    $0x9,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <dup>:
SYSCALL(dup)
 401:	b8 0a 00 00 00       	mov    $0xa,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <getpid>:
SYSCALL(getpid)
 409:	b8 0b 00 00 00       	mov    $0xb,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret    

00000411 <sbrk>:
SYSCALL(sbrk)
 411:	b8 0c 00 00 00       	mov    $0xc,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret    

00000419 <sleep>:
SYSCALL(sleep)
 419:	b8 0d 00 00 00       	mov    $0xd,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <uptime>:
SYSCALL(uptime)
 421:	b8 0e 00 00 00       	mov    $0xe,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret    

00000429 <setpri>:
SYSCALL(setpri)
 429:	b8 16 00 00 00       	mov    $0x16,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret    

00000431 <getpri>:
SYSCALL(getpri)
 431:	b8 17 00 00 00       	mov    $0x17,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <getpinfo>:
SYSCALL(getpinfo)
 439:	b8 18 00 00 00       	mov    $0x18,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <fork2>:
SYSCALL(fork2)
 441:	b8 19 00 00 00       	mov    $0x19,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 449:	55                   	push   %ebp
 44a:	89 e5                	mov    %esp,%ebp
 44c:	83 ec 1c             	sub    $0x1c,%esp
 44f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 452:	6a 01                	push   $0x1
 454:	8d 55 f4             	lea    -0xc(%ebp),%edx
 457:	52                   	push   %edx
 458:	50                   	push   %eax
 459:	e8 4b ff ff ff       	call   3a9 <write>
}
 45e:	83 c4 10             	add    $0x10,%esp
 461:	c9                   	leave  
 462:	c3                   	ret    

00000463 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 463:	55                   	push   %ebp
 464:	89 e5                	mov    %esp,%ebp
 466:	57                   	push   %edi
 467:	56                   	push   %esi
 468:	53                   	push   %ebx
 469:	83 ec 2c             	sub    $0x2c,%esp
 46c:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 472:	0f 95 c3             	setne  %bl
 475:	89 d0                	mov    %edx,%eax
 477:	c1 e8 1f             	shr    $0x1f,%eax
 47a:	84 c3                	test   %al,%bl
 47c:	74 10                	je     48e <printint+0x2b>
    neg = 1;
    x = -xx;
 47e:	f7 da                	neg    %edx
    neg = 1;
 480:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 487:	be 00 00 00 00       	mov    $0x0,%esi
 48c:	eb 0b                	jmp    499 <printint+0x36>
  neg = 0;
 48e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 495:	eb f0                	jmp    487 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 497:	89 c6                	mov    %eax,%esi
 499:	89 d0                	mov    %edx,%eax
 49b:	ba 00 00 00 00       	mov    $0x0,%edx
 4a0:	f7 f1                	div    %ecx
 4a2:	89 c3                	mov    %eax,%ebx
 4a4:	8d 46 01             	lea    0x1(%esi),%eax
 4a7:	0f b6 92 4c 08 00 00 	movzbl 0x84c(%edx),%edx
 4ae:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 4b2:	89 da                	mov    %ebx,%edx
 4b4:	85 db                	test   %ebx,%ebx
 4b6:	75 df                	jne    497 <printint+0x34>
 4b8:	89 c3                	mov    %eax,%ebx
  if(neg)
 4ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 4be:	74 16                	je     4d6 <printint+0x73>
    buf[i++] = '-';
 4c0:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 4c5:	8d 5e 02             	lea    0x2(%esi),%ebx
 4c8:	eb 0c                	jmp    4d6 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 4ca:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 4cf:	89 f8                	mov    %edi,%eax
 4d1:	e8 73 ff ff ff       	call   449 <putc>
  while(--i >= 0)
 4d6:	83 eb 01             	sub    $0x1,%ebx
 4d9:	79 ef                	jns    4ca <printint+0x67>
}
 4db:	83 c4 2c             	add    $0x2c,%esp
 4de:	5b                   	pop    %ebx
 4df:	5e                   	pop    %esi
 4e0:	5f                   	pop    %edi
 4e1:	5d                   	pop    %ebp
 4e2:	c3                   	ret    

000004e3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4e3:	55                   	push   %ebp
 4e4:	89 e5                	mov    %esp,%ebp
 4e6:	57                   	push   %edi
 4e7:	56                   	push   %esi
 4e8:	53                   	push   %ebx
 4e9:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 4ec:	8d 45 10             	lea    0x10(%ebp),%eax
 4ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 4f2:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 4f7:	bb 00 00 00 00       	mov    $0x0,%ebx
 4fc:	eb 14                	jmp    512 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 4fe:	89 fa                	mov    %edi,%edx
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	e8 41 ff ff ff       	call   449 <putc>
 508:	eb 05                	jmp    50f <printf+0x2c>
      }
    } else if(state == '%'){
 50a:	83 fe 25             	cmp    $0x25,%esi
 50d:	74 25                	je     534 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 50f:	83 c3 01             	add    $0x1,%ebx
 512:	8b 45 0c             	mov    0xc(%ebp),%eax
 515:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 519:	84 c0                	test   %al,%al
 51b:	0f 84 23 01 00 00    	je     644 <printf+0x161>
    c = fmt[i] & 0xff;
 521:	0f be f8             	movsbl %al,%edi
 524:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 527:	85 f6                	test   %esi,%esi
 529:	75 df                	jne    50a <printf+0x27>
      if(c == '%'){
 52b:	83 f8 25             	cmp    $0x25,%eax
 52e:	75 ce                	jne    4fe <printf+0x1b>
        state = '%';
 530:	89 c6                	mov    %eax,%esi
 532:	eb db                	jmp    50f <printf+0x2c>
      if(c == 'd'){
 534:	83 f8 64             	cmp    $0x64,%eax
 537:	74 49                	je     582 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 539:	83 f8 78             	cmp    $0x78,%eax
 53c:	0f 94 c1             	sete   %cl
 53f:	83 f8 70             	cmp    $0x70,%eax
 542:	0f 94 c2             	sete   %dl
 545:	08 d1                	or     %dl,%cl
 547:	75 63                	jne    5ac <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 549:	83 f8 73             	cmp    $0x73,%eax
 54c:	0f 84 84 00 00 00    	je     5d6 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 552:	83 f8 63             	cmp    $0x63,%eax
 555:	0f 84 b7 00 00 00    	je     612 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 55b:	83 f8 25             	cmp    $0x25,%eax
 55e:	0f 84 cc 00 00 00    	je     630 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 564:	ba 25 00 00 00       	mov    $0x25,%edx
 569:	8b 45 08             	mov    0x8(%ebp),%eax
 56c:	e8 d8 fe ff ff       	call   449 <putc>
        putc(fd, c);
 571:	89 fa                	mov    %edi,%edx
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	e8 ce fe ff ff       	call   449 <putc>
      }
      state = 0;
 57b:	be 00 00 00 00       	mov    $0x0,%esi
 580:	eb 8d                	jmp    50f <printf+0x2c>
        printint(fd, *ap, 10, 1);
 582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 585:	8b 17                	mov    (%edi),%edx
 587:	83 ec 0c             	sub    $0xc,%esp
 58a:	6a 01                	push   $0x1
 58c:	b9 0a 00 00 00       	mov    $0xa,%ecx
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	e8 ca fe ff ff       	call   463 <printint>
        ap++;
 599:	83 c7 04             	add    $0x4,%edi
 59c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 59f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5a2:	be 00 00 00 00       	mov    $0x0,%esi
 5a7:	e9 63 ff ff ff       	jmp    50f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 5ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5af:	8b 17                	mov    (%edi),%edx
 5b1:	83 ec 0c             	sub    $0xc,%esp
 5b4:	6a 00                	push   $0x0
 5b6:	b9 10 00 00 00       	mov    $0x10,%ecx
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	e8 a0 fe ff ff       	call   463 <printint>
        ap++;
 5c3:	83 c7 04             	add    $0x4,%edi
 5c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5c9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5cc:	be 00 00 00 00       	mov    $0x0,%esi
 5d1:	e9 39 ff ff ff       	jmp    50f <printf+0x2c>
        s = (char*)*ap;
 5d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d9:	8b 30                	mov    (%eax),%esi
        ap++;
 5db:	83 c0 04             	add    $0x4,%eax
 5de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 5e1:	85 f6                	test   %esi,%esi
 5e3:	75 28                	jne    60d <printf+0x12a>
          s = "(null)";
 5e5:	be 44 08 00 00       	mov    $0x844,%esi
 5ea:	8b 7d 08             	mov    0x8(%ebp),%edi
 5ed:	eb 0d                	jmp    5fc <printf+0x119>
          putc(fd, *s);
 5ef:	0f be d2             	movsbl %dl,%edx
 5f2:	89 f8                	mov    %edi,%eax
 5f4:	e8 50 fe ff ff       	call   449 <putc>
          s++;
 5f9:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 5fc:	0f b6 16             	movzbl (%esi),%edx
 5ff:	84 d2                	test   %dl,%dl
 601:	75 ec                	jne    5ef <printf+0x10c>
      state = 0;
 603:	be 00 00 00 00       	mov    $0x0,%esi
 608:	e9 02 ff ff ff       	jmp    50f <printf+0x2c>
 60d:	8b 7d 08             	mov    0x8(%ebp),%edi
 610:	eb ea                	jmp    5fc <printf+0x119>
        putc(fd, *ap);
 612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 615:	0f be 17             	movsbl (%edi),%edx
 618:	8b 45 08             	mov    0x8(%ebp),%eax
 61b:	e8 29 fe ff ff       	call   449 <putc>
        ap++;
 620:	83 c7 04             	add    $0x4,%edi
 623:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 626:	be 00 00 00 00       	mov    $0x0,%esi
 62b:	e9 df fe ff ff       	jmp    50f <printf+0x2c>
        putc(fd, c);
 630:	89 fa                	mov    %edi,%edx
 632:	8b 45 08             	mov    0x8(%ebp),%eax
 635:	e8 0f fe ff ff       	call   449 <putc>
      state = 0;
 63a:	be 00 00 00 00       	mov    $0x0,%esi
 63f:	e9 cb fe ff ff       	jmp    50f <printf+0x2c>
    }
  }
}
 644:	8d 65 f4             	lea    -0xc(%ebp),%esp
 647:	5b                   	pop    %ebx
 648:	5e                   	pop    %esi
 649:	5f                   	pop    %edi
 64a:	5d                   	pop    %ebp
 64b:	c3                   	ret    

0000064c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
 64f:	57                   	push   %edi
 650:	56                   	push   %esi
 651:	53                   	push   %ebx
 652:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 655:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 658:	a1 18 0b 00 00       	mov    0xb18,%eax
 65d:	eb 02                	jmp    661 <free+0x15>
 65f:	89 d0                	mov    %edx,%eax
 661:	39 c8                	cmp    %ecx,%eax
 663:	73 04                	jae    669 <free+0x1d>
 665:	39 08                	cmp    %ecx,(%eax)
 667:	77 12                	ja     67b <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 669:	8b 10                	mov    (%eax),%edx
 66b:	39 c2                	cmp    %eax,%edx
 66d:	77 f0                	ja     65f <free+0x13>
 66f:	39 c8                	cmp    %ecx,%eax
 671:	72 08                	jb     67b <free+0x2f>
 673:	39 ca                	cmp    %ecx,%edx
 675:	77 04                	ja     67b <free+0x2f>
 677:	89 d0                	mov    %edx,%eax
 679:	eb e6                	jmp    661 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 67b:	8b 73 fc             	mov    -0x4(%ebx),%esi
 67e:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 681:	8b 10                	mov    (%eax),%edx
 683:	39 d7                	cmp    %edx,%edi
 685:	74 19                	je     6a0 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 687:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 68a:	8b 50 04             	mov    0x4(%eax),%edx
 68d:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 690:	39 ce                	cmp    %ecx,%esi
 692:	74 1b                	je     6af <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 694:	89 08                	mov    %ecx,(%eax)
  freep = p;
 696:	a3 18 0b 00 00       	mov    %eax,0xb18
}
 69b:	5b                   	pop    %ebx
 69c:	5e                   	pop    %esi
 69d:	5f                   	pop    %edi
 69e:	5d                   	pop    %ebp
 69f:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 6a0:	03 72 04             	add    0x4(%edx),%esi
 6a3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a6:	8b 10                	mov    (%eax),%edx
 6a8:	8b 12                	mov    (%edx),%edx
 6aa:	89 53 f8             	mov    %edx,-0x8(%ebx)
 6ad:	eb db                	jmp    68a <free+0x3e>
    p->s.size += bp->s.size;
 6af:	03 53 fc             	add    -0x4(%ebx),%edx
 6b2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b5:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6b8:	89 10                	mov    %edx,(%eax)
 6ba:	eb da                	jmp    696 <free+0x4a>

000006bc <morecore>:

static Header*
morecore(uint nu)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	53                   	push   %ebx
 6c0:	83 ec 04             	sub    $0x4,%esp
 6c3:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 6c5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 6ca:	77 05                	ja     6d1 <morecore+0x15>
    nu = 4096;
 6cc:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 6d1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 6d8:	83 ec 0c             	sub    $0xc,%esp
 6db:	50                   	push   %eax
 6dc:	e8 30 fd ff ff       	call   411 <sbrk>
  if(p == (char*)-1)
 6e1:	83 c4 10             	add    $0x10,%esp
 6e4:	83 f8 ff             	cmp    $0xffffffff,%eax
 6e7:	74 1c                	je     705 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 6e9:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 6ec:	83 c0 08             	add    $0x8,%eax
 6ef:	83 ec 0c             	sub    $0xc,%esp
 6f2:	50                   	push   %eax
 6f3:	e8 54 ff ff ff       	call   64c <free>
  return freep;
 6f8:	a1 18 0b 00 00       	mov    0xb18,%eax
 6fd:	83 c4 10             	add    $0x10,%esp
}
 700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 703:	c9                   	leave  
 704:	c3                   	ret    
    return 0;
 705:	b8 00 00 00 00       	mov    $0x0,%eax
 70a:	eb f4                	jmp    700 <morecore+0x44>

0000070c <malloc>:

void*
malloc(uint nbytes)
{
 70c:	55                   	push   %ebp
 70d:	89 e5                	mov    %esp,%ebp
 70f:	53                   	push   %ebx
 710:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 713:	8b 45 08             	mov    0x8(%ebp),%eax
 716:	8d 58 07             	lea    0x7(%eax),%ebx
 719:	c1 eb 03             	shr    $0x3,%ebx
 71c:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 71f:	8b 0d 18 0b 00 00    	mov    0xb18,%ecx
 725:	85 c9                	test   %ecx,%ecx
 727:	74 04                	je     72d <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 729:	8b 01                	mov    (%ecx),%eax
 72b:	eb 4d                	jmp    77a <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 72d:	c7 05 18 0b 00 00 1c 	movl   $0xb1c,0xb18
 734:	0b 00 00 
 737:	c7 05 1c 0b 00 00 1c 	movl   $0xb1c,0xb1c
 73e:	0b 00 00 
    base.s.size = 0;
 741:	c7 05 20 0b 00 00 00 	movl   $0x0,0xb20
 748:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 74b:	b9 1c 0b 00 00       	mov    $0xb1c,%ecx
 750:	eb d7                	jmp    729 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 752:	39 da                	cmp    %ebx,%edx
 754:	74 1a                	je     770 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 756:	29 da                	sub    %ebx,%edx
 758:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 75b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 75e:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 761:	89 0d 18 0b 00 00    	mov    %ecx,0xb18
      return (void*)(p + 1);
 767:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 76a:	83 c4 04             	add    $0x4,%esp
 76d:	5b                   	pop    %ebx
 76e:	5d                   	pop    %ebp
 76f:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 770:	8b 10                	mov    (%eax),%edx
 772:	89 11                	mov    %edx,(%ecx)
 774:	eb eb                	jmp    761 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 776:	89 c1                	mov    %eax,%ecx
 778:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 77a:	8b 50 04             	mov    0x4(%eax),%edx
 77d:	39 da                	cmp    %ebx,%edx
 77f:	73 d1                	jae    752 <malloc+0x46>
    if(p == freep)
 781:	39 05 18 0b 00 00    	cmp    %eax,0xb18
 787:	75 ed                	jne    776 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 789:	89 d8                	mov    %ebx,%eax
 78b:	e8 2c ff ff ff       	call   6bc <morecore>
 790:	85 c0                	test   %eax,%eax
 792:	75 e2                	jne    776 <malloc+0x6a>
        return 0;
 794:	b8 00 00 00 00       	mov    $0x0,%eax
 799:	eb cf                	jmp    76a <malloc+0x5e>
