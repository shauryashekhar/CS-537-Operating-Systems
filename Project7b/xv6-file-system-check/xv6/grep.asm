
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	8b 75 08             	mov    0x8(%ebp),%esi
   c:	8b 7d 0c             	mov    0xc(%ebp),%edi
   f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
  12:	83 ec 08             	sub    $0x8,%esp
  15:	53                   	push   %ebx
  16:	57                   	push   %edi
  17:	e8 2c 00 00 00       	call   48 <matchhere>
  1c:	83 c4 10             	add    $0x10,%esp
  1f:	85 c0                	test   %eax,%eax
  21:	75 18                	jne    3b <matchstar+0x3b>
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  23:	0f b6 13             	movzbl (%ebx),%edx
  26:	84 d2                	test   %dl,%dl
  28:	74 16                	je     40 <matchstar+0x40>
  2a:	83 c3 01             	add    $0x1,%ebx
  2d:	0f be d2             	movsbl %dl,%edx
  30:	39 f2                	cmp    %esi,%edx
  32:	74 de                	je     12 <matchstar+0x12>
  34:	83 fe 2e             	cmp    $0x2e,%esi
  37:	74 d9                	je     12 <matchstar+0x12>
  39:	eb 05                	jmp    40 <matchstar+0x40>
      return 1;
  3b:	b8 01 00 00 00       	mov    $0x1,%eax
  return 0;
}
  40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  43:	5b                   	pop    %ebx
  44:	5e                   	pop    %esi
  45:	5f                   	pop    %edi
  46:	5d                   	pop    %ebp
  47:	c3                   	ret    

00000048 <matchhere>:
{
  48:	55                   	push   %ebp
  49:	89 e5                	mov    %esp,%ebp
  4b:	83 ec 08             	sub    $0x8,%esp
  4e:	8b 55 08             	mov    0x8(%ebp),%edx
  if(re[0] == '\0')
  51:	0f b6 02             	movzbl (%edx),%eax
  54:	84 c0                	test   %al,%al
  56:	74 68                	je     c0 <matchhere+0x78>
  if(re[1] == '*')
  58:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  5c:	80 f9 2a             	cmp    $0x2a,%cl
  5f:	74 1d                	je     7e <matchhere+0x36>
  if(re[0] == '$' && re[1] == '\0')
  61:	3c 24                	cmp    $0x24,%al
  63:	74 31                	je     96 <matchhere+0x4e>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  68:	0f b6 09             	movzbl (%ecx),%ecx
  6b:	84 c9                	test   %cl,%cl
  6d:	74 58                	je     c7 <matchhere+0x7f>
  6f:	3c 2e                	cmp    $0x2e,%al
  71:	74 35                	je     a8 <matchhere+0x60>
  73:	38 c8                	cmp    %cl,%al
  75:	74 31                	je     a8 <matchhere+0x60>
  return 0;
  77:	b8 00 00 00 00       	mov    $0x0,%eax
  7c:	eb 47                	jmp    c5 <matchhere+0x7d>
    return matchstar(re[0], re+2, text);
  7e:	83 ec 04             	sub    $0x4,%esp
  81:	ff 75 0c             	pushl  0xc(%ebp)
  84:	83 c2 02             	add    $0x2,%edx
  87:	52                   	push   %edx
  88:	0f be c0             	movsbl %al,%eax
  8b:	50                   	push   %eax
  8c:	e8 6f ff ff ff       	call   0 <matchstar>
  91:	83 c4 10             	add    $0x10,%esp
  94:	eb 2f                	jmp    c5 <matchhere+0x7d>
  if(re[0] == '$' && re[1] == '\0')
  96:	84 c9                	test   %cl,%cl
  98:	75 cb                	jne    65 <matchhere+0x1d>
    return *text == '\0';
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	80 38 00             	cmpb   $0x0,(%eax)
  a0:	0f 94 c0             	sete   %al
  a3:	0f b6 c0             	movzbl %al,%eax
  a6:	eb 1d                	jmp    c5 <matchhere+0x7d>
    return matchhere(re+1, text+1);
  a8:	83 ec 08             	sub    $0x8,%esp
  ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  ae:	83 c0 01             	add    $0x1,%eax
  b1:	50                   	push   %eax
  b2:	83 c2 01             	add    $0x1,%edx
  b5:	52                   	push   %edx
  b6:	e8 8d ff ff ff       	call   48 <matchhere>
  bb:	83 c4 10             	add    $0x10,%esp
  be:	eb 05                	jmp    c5 <matchhere+0x7d>
    return 1;
  c0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  c5:	c9                   	leave  
  c6:	c3                   	ret    
  return 0;
  c7:	b8 00 00 00 00       	mov    $0x0,%eax
  cc:	eb f7                	jmp    c5 <matchhere+0x7d>

000000ce <match>:
{
  ce:	55                   	push   %ebp
  cf:	89 e5                	mov    %esp,%ebp
  d1:	56                   	push   %esi
  d2:	53                   	push   %ebx
  d3:	8b 75 08             	mov    0x8(%ebp),%esi
  d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(re[0] == '^')
  d9:	80 3e 5e             	cmpb   $0x5e,(%esi)
  dc:	75 14                	jne    f2 <match+0x24>
    return matchhere(re+1, text);
  de:	83 ec 08             	sub    $0x8,%esp
  e1:	53                   	push   %ebx
  e2:	83 c6 01             	add    $0x1,%esi
  e5:	56                   	push   %esi
  e6:	e8 5d ff ff ff       	call   48 <matchhere>
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	eb 22                	jmp    112 <match+0x44>
  }while(*text++ != '\0');
  f0:	89 d3                	mov    %edx,%ebx
    if(matchhere(re, text))
  f2:	83 ec 08             	sub    $0x8,%esp
  f5:	53                   	push   %ebx
  f6:	56                   	push   %esi
  f7:	e8 4c ff ff ff       	call   48 <matchhere>
  fc:	83 c4 10             	add    $0x10,%esp
  ff:	85 c0                	test   %eax,%eax
 101:	75 0a                	jne    10d <match+0x3f>
  }while(*text++ != '\0');
 103:	8d 53 01             	lea    0x1(%ebx),%edx
 106:	80 3b 00             	cmpb   $0x0,(%ebx)
 109:	75 e5                	jne    f0 <match+0x22>
 10b:	eb 05                	jmp    112 <match+0x44>
      return 1;
 10d:	b8 01 00 00 00       	mov    $0x1,%eax
}
 112:	8d 65 f8             	lea    -0x8(%ebp),%esp
 115:	5b                   	pop    %ebx
 116:	5e                   	pop    %esi
 117:	5d                   	pop    %ebp
 118:	c3                   	ret    

00000119 <grep>:
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	57                   	push   %edi
 11d:	56                   	push   %esi
 11e:	53                   	push   %ebx
 11f:	83 ec 0c             	sub    $0xc,%esp
  m = 0;
 122:	bf 00 00 00 00       	mov    $0x0,%edi
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 127:	eb 52                	jmp    17b <grep+0x62>
      p = q+1;
 129:	8d 73 01             	lea    0x1(%ebx),%esi
    while((q = strchr(p, '\n')) != 0){
 12c:	83 ec 08             	sub    $0x8,%esp
 12f:	6a 0a                	push   $0xa
 131:	56                   	push   %esi
 132:	e8 c9 01 00 00       	call   300 <strchr>
 137:	89 c3                	mov    %eax,%ebx
 139:	83 c4 10             	add    $0x10,%esp
 13c:	85 c0                	test   %eax,%eax
 13e:	74 2f                	je     16f <grep+0x56>
      *q = 0;
 140:	c6 03 00             	movb   $0x0,(%ebx)
      if(match(pattern, p)){
 143:	83 ec 08             	sub    $0x8,%esp
 146:	56                   	push   %esi
 147:	ff 75 08             	pushl  0x8(%ebp)
 14a:	e8 7f ff ff ff       	call   ce <match>
 14f:	83 c4 10             	add    $0x10,%esp
 152:	85 c0                	test   %eax,%eax
 154:	74 d3                	je     129 <grep+0x10>
        *q = '\n';
 156:	c6 03 0a             	movb   $0xa,(%ebx)
        write(1, p, q+1 - p);
 159:	8d 43 01             	lea    0x1(%ebx),%eax
 15c:	83 ec 04             	sub    $0x4,%esp
 15f:	29 f0                	sub    %esi,%eax
 161:	50                   	push   %eax
 162:	56                   	push   %esi
 163:	6a 01                	push   $0x1
 165:	e8 ce 02 00 00       	call   438 <write>
 16a:	83 c4 10             	add    $0x10,%esp
 16d:	eb ba                	jmp    129 <grep+0x10>
    if(p == buf)
 16f:	81 fe c0 0b 00 00    	cmp    $0xbc0,%esi
 175:	74 52                	je     1c9 <grep+0xb0>
    if(m > 0){
 177:	85 ff                	test   %edi,%edi
 179:	7f 31                	jg     1ac <grep+0x93>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 17b:	b8 ff 03 00 00       	mov    $0x3ff,%eax
 180:	29 f8                	sub    %edi,%eax
 182:	8d 97 c0 0b 00 00    	lea    0xbc0(%edi),%edx
 188:	83 ec 04             	sub    $0x4,%esp
 18b:	50                   	push   %eax
 18c:	52                   	push   %edx
 18d:	ff 75 0c             	pushl  0xc(%ebp)
 190:	e8 9b 02 00 00       	call   430 <read>
 195:	83 c4 10             	add    $0x10,%esp
 198:	85 c0                	test   %eax,%eax
 19a:	7e 34                	jle    1d0 <grep+0xb7>
    m += n;
 19c:	01 c7                	add    %eax,%edi
    buf[m] = '\0';
 19e:	c6 87 c0 0b 00 00 00 	movb   $0x0,0xbc0(%edi)
    p = buf;
 1a5:	be c0 0b 00 00       	mov    $0xbc0,%esi
    while((q = strchr(p, '\n')) != 0){
 1aa:	eb 80                	jmp    12c <grep+0x13>
      m -= p - buf;
 1ac:	89 f0                	mov    %esi,%eax
 1ae:	2d c0 0b 00 00       	sub    $0xbc0,%eax
 1b3:	29 c7                	sub    %eax,%edi
      memmove(buf, p, m);
 1b5:	83 ec 04             	sub    $0x4,%esp
 1b8:	57                   	push   %edi
 1b9:	56                   	push   %esi
 1ba:	68 c0 0b 00 00       	push   $0xbc0
 1bf:	e8 22 02 00 00       	call   3e6 <memmove>
 1c4:	83 c4 10             	add    $0x10,%esp
 1c7:	eb b2                	jmp    17b <grep+0x62>
      m = 0;
 1c9:	bf 00 00 00 00       	mov    $0x0,%edi
 1ce:	eb ab                	jmp    17b <grep+0x62>
}
 1d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1d3:	5b                   	pop    %ebx
 1d4:	5e                   	pop    %esi
 1d5:	5f                   	pop    %edi
 1d6:	5d                   	pop    %ebp
 1d7:	c3                   	ret    

000001d8 <main>:
{
 1d8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1dc:	83 e4 f0             	and    $0xfffffff0,%esp
 1df:	ff 71 fc             	pushl  -0x4(%ecx)
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	57                   	push   %edi
 1e6:	56                   	push   %esi
 1e7:	53                   	push   %ebx
 1e8:	51                   	push   %ecx
 1e9:	83 ec 18             	sub    $0x18,%esp
 1ec:	8b 01                	mov    (%ecx),%eax
 1ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 1f1:	8b 51 04             	mov    0x4(%ecx),%edx
 1f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(argc <= 1){
 1f7:	83 f8 01             	cmp    $0x1,%eax
 1fa:	7e 50                	jle    24c <main+0x74>
  pattern = argv[1];
 1fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1ff:	8b 40 04             	mov    0x4(%eax),%eax
 202:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if(argc <= 2){
 205:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
 209:	7e 55                	jle    260 <main+0x88>
  for(i = 2; i < argc; i++){
 20b:	bb 02 00 00 00       	mov    $0x2,%ebx
 210:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
 213:	7d 71                	jge    286 <main+0xae>
    if((fd = open(argv[i], 0)) < 0){
 215:	8b 45 e0             	mov    -0x20(%ebp),%eax
 218:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 21b:	83 ec 08             	sub    $0x8,%esp
 21e:	6a 00                	push   $0x0
 220:	ff 37                	pushl  (%edi)
 222:	e8 31 02 00 00       	call   458 <open>
 227:	89 c6                	mov    %eax,%esi
 229:	83 c4 10             	add    $0x10,%esp
 22c:	85 c0                	test   %eax,%eax
 22e:	78 40                	js     270 <main+0x98>
    grep(pattern, fd);
 230:	83 ec 08             	sub    $0x8,%esp
 233:	50                   	push   %eax
 234:	ff 75 dc             	pushl  -0x24(%ebp)
 237:	e8 dd fe ff ff       	call   119 <grep>
    close(fd);
 23c:	89 34 24             	mov    %esi,(%esp)
 23f:	e8 fc 01 00 00       	call   440 <close>
  for(i = 2; i < argc; i++){
 244:	83 c3 01             	add    $0x1,%ebx
 247:	83 c4 10             	add    $0x10,%esp
 24a:	eb c4                	jmp    210 <main+0x38>
    printf(2, "usage: grep pattern [file ...]\n");
 24c:	83 ec 08             	sub    $0x8,%esp
 24f:	68 0c 08 00 00       	push   $0x80c
 254:	6a 02                	push   $0x2
 256:	e8 f7 02 00 00       	call   552 <printf>
    exit();
 25b:	e8 b8 01 00 00       	call   418 <exit>
    grep(pattern, 0);
 260:	83 ec 08             	sub    $0x8,%esp
 263:	6a 00                	push   $0x0
 265:	50                   	push   %eax
 266:	e8 ae fe ff ff       	call   119 <grep>
    exit();
 26b:	e8 a8 01 00 00       	call   418 <exit>
      printf(1, "grep: cannot open %s\n", argv[i]);
 270:	83 ec 04             	sub    $0x4,%esp
 273:	ff 37                	pushl  (%edi)
 275:	68 2c 08 00 00       	push   $0x82c
 27a:	6a 01                	push   $0x1
 27c:	e8 d1 02 00 00       	call   552 <printf>
      exit();
 281:	e8 92 01 00 00       	call   418 <exit>
  exit();
 286:	e8 8d 01 00 00       	call   418 <exit>

0000028b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 28b:	55                   	push   %ebp
 28c:	89 e5                	mov    %esp,%ebp
 28e:	53                   	push   %ebx
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 295:	89 c2                	mov    %eax,%edx
 297:	0f b6 19             	movzbl (%ecx),%ebx
 29a:	88 1a                	mov    %bl,(%edx)
 29c:	8d 52 01             	lea    0x1(%edx),%edx
 29f:	8d 49 01             	lea    0x1(%ecx),%ecx
 2a2:	84 db                	test   %bl,%bl
 2a4:	75 f1                	jne    297 <strcpy+0xc>
    ;
  return os;
}
 2a6:	5b                   	pop    %ebx
 2a7:	5d                   	pop    %ebp
 2a8:	c3                   	ret    

000002a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a9:	55                   	push   %ebp
 2aa:	89 e5                	mov    %esp,%ebp
 2ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2af:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 2b2:	eb 06                	jmp    2ba <strcmp+0x11>
    p++, q++;
 2b4:	83 c1 01             	add    $0x1,%ecx
 2b7:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 2ba:	0f b6 01             	movzbl (%ecx),%eax
 2bd:	84 c0                	test   %al,%al
 2bf:	74 04                	je     2c5 <strcmp+0x1c>
 2c1:	3a 02                	cmp    (%edx),%al
 2c3:	74 ef                	je     2b4 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 2c5:	0f b6 c0             	movzbl %al,%eax
 2c8:	0f b6 12             	movzbl (%edx),%edx
 2cb:	29 d0                	sub    %edx,%eax
}
 2cd:	5d                   	pop    %ebp
 2ce:	c3                   	ret    

000002cf <strlen>:

uint
strlen(const char *s)
{
 2cf:	55                   	push   %ebp
 2d0:	89 e5                	mov    %esp,%ebp
 2d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 2d5:	ba 00 00 00 00       	mov    $0x0,%edx
 2da:	eb 03                	jmp    2df <strlen+0x10>
 2dc:	83 c2 01             	add    $0x1,%edx
 2df:	89 d0                	mov    %edx,%eax
 2e1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 2e5:	75 f5                	jne    2dc <strlen+0xd>
    ;
  return n;
}
 2e7:	5d                   	pop    %ebp
 2e8:	c3                   	ret    

000002e9 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	57                   	push   %edi
 2ed:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 2f0:	89 d7                	mov    %edx,%edi
 2f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f8:	fc                   	cld    
 2f9:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2fb:	89 d0                	mov    %edx,%eax
 2fd:	5f                   	pop    %edi
 2fe:	5d                   	pop    %ebp
 2ff:	c3                   	ret    

00000300 <strchr>:

char*
strchr(const char *s, char c)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 30a:	0f b6 10             	movzbl (%eax),%edx
 30d:	84 d2                	test   %dl,%dl
 30f:	74 09                	je     31a <strchr+0x1a>
    if(*s == c)
 311:	38 ca                	cmp    %cl,%dl
 313:	74 0a                	je     31f <strchr+0x1f>
  for(; *s; s++)
 315:	83 c0 01             	add    $0x1,%eax
 318:	eb f0                	jmp    30a <strchr+0xa>
      return (char*)s;
  return 0;
 31a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 31f:	5d                   	pop    %ebp
 320:	c3                   	ret    

00000321 <gets>:

char*
gets(char *buf, int max)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
 324:	57                   	push   %edi
 325:	56                   	push   %esi
 326:	53                   	push   %ebx
 327:	83 ec 1c             	sub    $0x1c,%esp
 32a:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32d:	bb 00 00 00 00       	mov    $0x0,%ebx
 332:	8d 73 01             	lea    0x1(%ebx),%esi
 335:	3b 75 0c             	cmp    0xc(%ebp),%esi
 338:	7d 2e                	jge    368 <gets+0x47>
    cc = read(0, &c, 1);
 33a:	83 ec 04             	sub    $0x4,%esp
 33d:	6a 01                	push   $0x1
 33f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 342:	50                   	push   %eax
 343:	6a 00                	push   $0x0
 345:	e8 e6 00 00 00       	call   430 <read>
    if(cc < 1)
 34a:	83 c4 10             	add    $0x10,%esp
 34d:	85 c0                	test   %eax,%eax
 34f:	7e 17                	jle    368 <gets+0x47>
      break;
    buf[i++] = c;
 351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 355:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 358:	3c 0a                	cmp    $0xa,%al
 35a:	0f 94 c2             	sete   %dl
 35d:	3c 0d                	cmp    $0xd,%al
 35f:	0f 94 c0             	sete   %al
    buf[i++] = c;
 362:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 364:	08 c2                	or     %al,%dl
 366:	74 ca                	je     332 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 368:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 36c:	89 f8                	mov    %edi,%eax
 36e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 371:	5b                   	pop    %ebx
 372:	5e                   	pop    %esi
 373:	5f                   	pop    %edi
 374:	5d                   	pop    %ebp
 375:	c3                   	ret    

00000376 <stat>:

int
stat(const char *n, struct stat *st)
{
 376:	55                   	push   %ebp
 377:	89 e5                	mov    %esp,%ebp
 379:	56                   	push   %esi
 37a:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 37b:	83 ec 08             	sub    $0x8,%esp
 37e:	6a 00                	push   $0x0
 380:	ff 75 08             	pushl  0x8(%ebp)
 383:	e8 d0 00 00 00       	call   458 <open>
  if(fd < 0)
 388:	83 c4 10             	add    $0x10,%esp
 38b:	85 c0                	test   %eax,%eax
 38d:	78 24                	js     3b3 <stat+0x3d>
 38f:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 391:	83 ec 08             	sub    $0x8,%esp
 394:	ff 75 0c             	pushl  0xc(%ebp)
 397:	50                   	push   %eax
 398:	e8 d3 00 00 00       	call   470 <fstat>
 39d:	89 c6                	mov    %eax,%esi
  close(fd);
 39f:	89 1c 24             	mov    %ebx,(%esp)
 3a2:	e8 99 00 00 00       	call   440 <close>
  return r;
 3a7:	83 c4 10             	add    $0x10,%esp
}
 3aa:	89 f0                	mov    %esi,%eax
 3ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
 3af:	5b                   	pop    %ebx
 3b0:	5e                   	pop    %esi
 3b1:	5d                   	pop    %ebp
 3b2:	c3                   	ret    
    return -1;
 3b3:	be ff ff ff ff       	mov    $0xffffffff,%esi
 3b8:	eb f0                	jmp    3aa <stat+0x34>

000003ba <atoi>:

int
atoi(const char *s)
{
 3ba:	55                   	push   %ebp
 3bb:	89 e5                	mov    %esp,%ebp
 3bd:	53                   	push   %ebx
 3be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 3c1:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 3c6:	eb 10                	jmp    3d8 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 3c8:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 3cb:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 3ce:	83 c1 01             	add    $0x1,%ecx
 3d1:	0f be d2             	movsbl %dl,%edx
 3d4:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 3d8:	0f b6 11             	movzbl (%ecx),%edx
 3db:	8d 5a d0             	lea    -0x30(%edx),%ebx
 3de:	80 fb 09             	cmp    $0x9,%bl
 3e1:	76 e5                	jbe    3c8 <atoi+0xe>
  return n;
}
 3e3:	5b                   	pop    %ebx
 3e4:	5d                   	pop    %ebp
 3e5:	c3                   	ret    

000003e6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3e6:	55                   	push   %ebp
 3e7:	89 e5                	mov    %esp,%ebp
 3e9:	56                   	push   %esi
 3ea:	53                   	push   %ebx
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 3f1:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 3f4:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 3f6:	eb 0d                	jmp    405 <memmove+0x1f>
    *dst++ = *src++;
 3f8:	0f b6 13             	movzbl (%ebx),%edx
 3fb:	88 11                	mov    %dl,(%ecx)
 3fd:	8d 5b 01             	lea    0x1(%ebx),%ebx
 400:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 403:	89 f2                	mov    %esi,%edx
 405:	8d 72 ff             	lea    -0x1(%edx),%esi
 408:	85 d2                	test   %edx,%edx
 40a:	7f ec                	jg     3f8 <memmove+0x12>
  return vdst;
}
 40c:	5b                   	pop    %ebx
 40d:	5e                   	pop    %esi
 40e:	5d                   	pop    %ebp
 40f:	c3                   	ret    

00000410 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 410:	b8 01 00 00 00       	mov    $0x1,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <exit>:
SYSCALL(exit)
 418:	b8 02 00 00 00       	mov    $0x2,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <wait>:
SYSCALL(wait)
 420:	b8 03 00 00 00       	mov    $0x3,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <pipe>:
SYSCALL(pipe)
 428:	b8 04 00 00 00       	mov    $0x4,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <read>:
SYSCALL(read)
 430:	b8 05 00 00 00       	mov    $0x5,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <write>:
SYSCALL(write)
 438:	b8 10 00 00 00       	mov    $0x10,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <close>:
SYSCALL(close)
 440:	b8 15 00 00 00       	mov    $0x15,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <kill>:
SYSCALL(kill)
 448:	b8 06 00 00 00       	mov    $0x6,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <exec>:
SYSCALL(exec)
 450:	b8 07 00 00 00       	mov    $0x7,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <open>:
SYSCALL(open)
 458:	b8 0f 00 00 00       	mov    $0xf,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <mknod>:
SYSCALL(mknod)
 460:	b8 11 00 00 00       	mov    $0x11,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <unlink>:
SYSCALL(unlink)
 468:	b8 12 00 00 00       	mov    $0x12,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <fstat>:
SYSCALL(fstat)
 470:	b8 08 00 00 00       	mov    $0x8,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <link>:
SYSCALL(link)
 478:	b8 13 00 00 00       	mov    $0x13,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <mkdir>:
SYSCALL(mkdir)
 480:	b8 14 00 00 00       	mov    $0x14,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <chdir>:
SYSCALL(chdir)
 488:	b8 09 00 00 00       	mov    $0x9,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <dup>:
SYSCALL(dup)
 490:	b8 0a 00 00 00       	mov    $0xa,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <getpid>:
SYSCALL(getpid)
 498:	b8 0b 00 00 00       	mov    $0xb,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <sbrk>:
SYSCALL(sbrk)
 4a0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <sleep>:
SYSCALL(sleep)
 4a8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <uptime>:
SYSCALL(uptime)
 4b0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
 4bb:	83 ec 1c             	sub    $0x1c,%esp
 4be:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 4c1:	6a 01                	push   $0x1
 4c3:	8d 55 f4             	lea    -0xc(%ebp),%edx
 4c6:	52                   	push   %edx
 4c7:	50                   	push   %eax
 4c8:	e8 6b ff ff ff       	call   438 <write>
}
 4cd:	83 c4 10             	add    $0x10,%esp
 4d0:	c9                   	leave  
 4d1:	c3                   	ret    

000004d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d2:	55                   	push   %ebp
 4d3:	89 e5                	mov    %esp,%ebp
 4d5:	57                   	push   %edi
 4d6:	56                   	push   %esi
 4d7:	53                   	push   %ebx
 4d8:	83 ec 2c             	sub    $0x2c,%esp
 4db:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 4e1:	0f 95 c3             	setne  %bl
 4e4:	89 d0                	mov    %edx,%eax
 4e6:	c1 e8 1f             	shr    $0x1f,%eax
 4e9:	84 c3                	test   %al,%bl
 4eb:	74 10                	je     4fd <printint+0x2b>
    neg = 1;
    x = -xx;
 4ed:	f7 da                	neg    %edx
    neg = 1;
 4ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4f6:	be 00 00 00 00       	mov    $0x0,%esi
 4fb:	eb 0b                	jmp    508 <printint+0x36>
  neg = 0;
 4fd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 504:	eb f0                	jmp    4f6 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 506:	89 c6                	mov    %eax,%esi
 508:	89 d0                	mov    %edx,%eax
 50a:	ba 00 00 00 00       	mov    $0x0,%edx
 50f:	f7 f1                	div    %ecx
 511:	89 c3                	mov    %eax,%ebx
 513:	8d 46 01             	lea    0x1(%esi),%eax
 516:	0f b6 92 4c 08 00 00 	movzbl 0x84c(%edx),%edx
 51d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 521:	89 da                	mov    %ebx,%edx
 523:	85 db                	test   %ebx,%ebx
 525:	75 df                	jne    506 <printint+0x34>
 527:	89 c3                	mov    %eax,%ebx
  if(neg)
 529:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 52d:	74 16                	je     545 <printint+0x73>
    buf[i++] = '-';
 52f:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 534:	8d 5e 02             	lea    0x2(%esi),%ebx
 537:	eb 0c                	jmp    545 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 539:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 53e:	89 f8                	mov    %edi,%eax
 540:	e8 73 ff ff ff       	call   4b8 <putc>
  while(--i >= 0)
 545:	83 eb 01             	sub    $0x1,%ebx
 548:	79 ef                	jns    539 <printint+0x67>
}
 54a:	83 c4 2c             	add    $0x2c,%esp
 54d:	5b                   	pop    %ebx
 54e:	5e                   	pop    %esi
 54f:	5f                   	pop    %edi
 550:	5d                   	pop    %ebp
 551:	c3                   	ret    

00000552 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 552:	55                   	push   %ebp
 553:	89 e5                	mov    %esp,%ebp
 555:	57                   	push   %edi
 556:	56                   	push   %esi
 557:	53                   	push   %ebx
 558:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 55b:	8d 45 10             	lea    0x10(%ebp),%eax
 55e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 561:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 566:	bb 00 00 00 00       	mov    $0x0,%ebx
 56b:	eb 14                	jmp    581 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 56d:	89 fa                	mov    %edi,%edx
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	e8 41 ff ff ff       	call   4b8 <putc>
 577:	eb 05                	jmp    57e <printf+0x2c>
      }
    } else if(state == '%'){
 579:	83 fe 25             	cmp    $0x25,%esi
 57c:	74 25                	je     5a3 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 57e:	83 c3 01             	add    $0x1,%ebx
 581:	8b 45 0c             	mov    0xc(%ebp),%eax
 584:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 588:	84 c0                	test   %al,%al
 58a:	0f 84 23 01 00 00    	je     6b3 <printf+0x161>
    c = fmt[i] & 0xff;
 590:	0f be f8             	movsbl %al,%edi
 593:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 596:	85 f6                	test   %esi,%esi
 598:	75 df                	jne    579 <printf+0x27>
      if(c == '%'){
 59a:	83 f8 25             	cmp    $0x25,%eax
 59d:	75 ce                	jne    56d <printf+0x1b>
        state = '%';
 59f:	89 c6                	mov    %eax,%esi
 5a1:	eb db                	jmp    57e <printf+0x2c>
      if(c == 'd'){
 5a3:	83 f8 64             	cmp    $0x64,%eax
 5a6:	74 49                	je     5f1 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 5a8:	83 f8 78             	cmp    $0x78,%eax
 5ab:	0f 94 c1             	sete   %cl
 5ae:	83 f8 70             	cmp    $0x70,%eax
 5b1:	0f 94 c2             	sete   %dl
 5b4:	08 d1                	or     %dl,%cl
 5b6:	75 63                	jne    61b <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 5b8:	83 f8 73             	cmp    $0x73,%eax
 5bb:	0f 84 84 00 00 00    	je     645 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c1:	83 f8 63             	cmp    $0x63,%eax
 5c4:	0f 84 b7 00 00 00    	je     681 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 5ca:	83 f8 25             	cmp    $0x25,%eax
 5cd:	0f 84 cc 00 00 00    	je     69f <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d3:	ba 25 00 00 00       	mov    $0x25,%edx
 5d8:	8b 45 08             	mov    0x8(%ebp),%eax
 5db:	e8 d8 fe ff ff       	call   4b8 <putc>
        putc(fd, c);
 5e0:	89 fa                	mov    %edi,%edx
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	e8 ce fe ff ff       	call   4b8 <putc>
      }
      state = 0;
 5ea:	be 00 00 00 00       	mov    $0x0,%esi
 5ef:	eb 8d                	jmp    57e <printf+0x2c>
        printint(fd, *ap, 10, 1);
 5f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5f4:	8b 17                	mov    (%edi),%edx
 5f6:	83 ec 0c             	sub    $0xc,%esp
 5f9:	6a 01                	push   $0x1
 5fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
 600:	8b 45 08             	mov    0x8(%ebp),%eax
 603:	e8 ca fe ff ff       	call   4d2 <printint>
        ap++;
 608:	83 c7 04             	add    $0x4,%edi
 60b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 60e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 611:	be 00 00 00 00       	mov    $0x0,%esi
 616:	e9 63 ff ff ff       	jmp    57e <printf+0x2c>
        printint(fd, *ap, 16, 0);
 61b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 61e:	8b 17                	mov    (%edi),%edx
 620:	83 ec 0c             	sub    $0xc,%esp
 623:	6a 00                	push   $0x0
 625:	b9 10 00 00 00       	mov    $0x10,%ecx
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
 62d:	e8 a0 fe ff ff       	call   4d2 <printint>
        ap++;
 632:	83 c7 04             	add    $0x4,%edi
 635:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 638:	83 c4 10             	add    $0x10,%esp
      state = 0;
 63b:	be 00 00 00 00       	mov    $0x0,%esi
 640:	e9 39 ff ff ff       	jmp    57e <printf+0x2c>
        s = (char*)*ap;
 645:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 648:	8b 30                	mov    (%eax),%esi
        ap++;
 64a:	83 c0 04             	add    $0x4,%eax
 64d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 650:	85 f6                	test   %esi,%esi
 652:	75 28                	jne    67c <printf+0x12a>
          s = "(null)";
 654:	be 42 08 00 00       	mov    $0x842,%esi
 659:	8b 7d 08             	mov    0x8(%ebp),%edi
 65c:	eb 0d                	jmp    66b <printf+0x119>
          putc(fd, *s);
 65e:	0f be d2             	movsbl %dl,%edx
 661:	89 f8                	mov    %edi,%eax
 663:	e8 50 fe ff ff       	call   4b8 <putc>
          s++;
 668:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 66b:	0f b6 16             	movzbl (%esi),%edx
 66e:	84 d2                	test   %dl,%dl
 670:	75 ec                	jne    65e <printf+0x10c>
      state = 0;
 672:	be 00 00 00 00       	mov    $0x0,%esi
 677:	e9 02 ff ff ff       	jmp    57e <printf+0x2c>
 67c:	8b 7d 08             	mov    0x8(%ebp),%edi
 67f:	eb ea                	jmp    66b <printf+0x119>
        putc(fd, *ap);
 681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 684:	0f be 17             	movsbl (%edi),%edx
 687:	8b 45 08             	mov    0x8(%ebp),%eax
 68a:	e8 29 fe ff ff       	call   4b8 <putc>
        ap++;
 68f:	83 c7 04             	add    $0x4,%edi
 692:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 695:	be 00 00 00 00       	mov    $0x0,%esi
 69a:	e9 df fe ff ff       	jmp    57e <printf+0x2c>
        putc(fd, c);
 69f:	89 fa                	mov    %edi,%edx
 6a1:	8b 45 08             	mov    0x8(%ebp),%eax
 6a4:	e8 0f fe ff ff       	call   4b8 <putc>
      state = 0;
 6a9:	be 00 00 00 00       	mov    $0x0,%esi
 6ae:	e9 cb fe ff ff       	jmp    57e <printf+0x2c>
    }
  }
}
 6b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6b6:	5b                   	pop    %ebx
 6b7:	5e                   	pop    %esi
 6b8:	5f                   	pop    %edi
 6b9:	5d                   	pop    %ebp
 6ba:	c3                   	ret    

000006bb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6bb:	55                   	push   %ebp
 6bc:	89 e5                	mov    %esp,%ebp
 6be:	57                   	push   %edi
 6bf:	56                   	push   %esi
 6c0:	53                   	push   %ebx
 6c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c4:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c7:	a1 a0 0b 00 00       	mov    0xba0,%eax
 6cc:	eb 02                	jmp    6d0 <free+0x15>
 6ce:	89 d0                	mov    %edx,%eax
 6d0:	39 c8                	cmp    %ecx,%eax
 6d2:	73 04                	jae    6d8 <free+0x1d>
 6d4:	39 08                	cmp    %ecx,(%eax)
 6d6:	77 12                	ja     6ea <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d8:	8b 10                	mov    (%eax),%edx
 6da:	39 c2                	cmp    %eax,%edx
 6dc:	77 f0                	ja     6ce <free+0x13>
 6de:	39 c8                	cmp    %ecx,%eax
 6e0:	72 08                	jb     6ea <free+0x2f>
 6e2:	39 ca                	cmp    %ecx,%edx
 6e4:	77 04                	ja     6ea <free+0x2f>
 6e6:	89 d0                	mov    %edx,%eax
 6e8:	eb e6                	jmp    6d0 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ea:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6ed:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6f0:	8b 10                	mov    (%eax),%edx
 6f2:	39 d7                	cmp    %edx,%edi
 6f4:	74 19                	je     70f <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6f6:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6f9:	8b 50 04             	mov    0x4(%eax),%edx
 6fc:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6ff:	39 ce                	cmp    %ecx,%esi
 701:	74 1b                	je     71e <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 703:	89 08                	mov    %ecx,(%eax)
  freep = p;
 705:	a3 a0 0b 00 00       	mov    %eax,0xba0
}
 70a:	5b                   	pop    %ebx
 70b:	5e                   	pop    %esi
 70c:	5f                   	pop    %edi
 70d:	5d                   	pop    %ebp
 70e:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 70f:	03 72 04             	add    0x4(%edx),%esi
 712:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 715:	8b 10                	mov    (%eax),%edx
 717:	8b 12                	mov    (%edx),%edx
 719:	89 53 f8             	mov    %edx,-0x8(%ebx)
 71c:	eb db                	jmp    6f9 <free+0x3e>
    p->s.size += bp->s.size;
 71e:	03 53 fc             	add    -0x4(%ebx),%edx
 721:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 724:	8b 53 f8             	mov    -0x8(%ebx),%edx
 727:	89 10                	mov    %edx,(%eax)
 729:	eb da                	jmp    705 <free+0x4a>

0000072b <morecore>:

static Header*
morecore(uint nu)
{
 72b:	55                   	push   %ebp
 72c:	89 e5                	mov    %esp,%ebp
 72e:	53                   	push   %ebx
 72f:	83 ec 04             	sub    $0x4,%esp
 732:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 734:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 739:	77 05                	ja     740 <morecore+0x15>
    nu = 4096;
 73b:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 740:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 747:	83 ec 0c             	sub    $0xc,%esp
 74a:	50                   	push   %eax
 74b:	e8 50 fd ff ff       	call   4a0 <sbrk>
  if(p == (char*)-1)
 750:	83 c4 10             	add    $0x10,%esp
 753:	83 f8 ff             	cmp    $0xffffffff,%eax
 756:	74 1c                	je     774 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 758:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 75b:	83 c0 08             	add    $0x8,%eax
 75e:	83 ec 0c             	sub    $0xc,%esp
 761:	50                   	push   %eax
 762:	e8 54 ff ff ff       	call   6bb <free>
  return freep;
 767:	a1 a0 0b 00 00       	mov    0xba0,%eax
 76c:	83 c4 10             	add    $0x10,%esp
}
 76f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 772:	c9                   	leave  
 773:	c3                   	ret    
    return 0;
 774:	b8 00 00 00 00       	mov    $0x0,%eax
 779:	eb f4                	jmp    76f <morecore+0x44>

0000077b <malloc>:

void*
malloc(uint nbytes)
{
 77b:	55                   	push   %ebp
 77c:	89 e5                	mov    %esp,%ebp
 77e:	53                   	push   %ebx
 77f:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 782:	8b 45 08             	mov    0x8(%ebp),%eax
 785:	8d 58 07             	lea    0x7(%eax),%ebx
 788:	c1 eb 03             	shr    $0x3,%ebx
 78b:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 78e:	8b 0d a0 0b 00 00    	mov    0xba0,%ecx
 794:	85 c9                	test   %ecx,%ecx
 796:	74 04                	je     79c <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 798:	8b 01                	mov    (%ecx),%eax
 79a:	eb 4d                	jmp    7e9 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 79c:	c7 05 a0 0b 00 00 a4 	movl   $0xba4,0xba0
 7a3:	0b 00 00 
 7a6:	c7 05 a4 0b 00 00 a4 	movl   $0xba4,0xba4
 7ad:	0b 00 00 
    base.s.size = 0;
 7b0:	c7 05 a8 0b 00 00 00 	movl   $0x0,0xba8
 7b7:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 7ba:	b9 a4 0b 00 00       	mov    $0xba4,%ecx
 7bf:	eb d7                	jmp    798 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 7c1:	39 da                	cmp    %ebx,%edx
 7c3:	74 1a                	je     7df <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 7c5:	29 da                	sub    %ebx,%edx
 7c7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ca:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 7cd:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 7d0:	89 0d a0 0b 00 00    	mov    %ecx,0xba0
      return (void*)(p + 1);
 7d6:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d9:	83 c4 04             	add    $0x4,%esp
 7dc:	5b                   	pop    %ebx
 7dd:	5d                   	pop    %ebp
 7de:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 7df:	8b 10                	mov    (%eax),%edx
 7e1:	89 11                	mov    %edx,(%ecx)
 7e3:	eb eb                	jmp    7d0 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e5:	89 c1                	mov    %eax,%ecx
 7e7:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 7e9:	8b 50 04             	mov    0x4(%eax),%edx
 7ec:	39 da                	cmp    %ebx,%edx
 7ee:	73 d1                	jae    7c1 <malloc+0x46>
    if(p == freep)
 7f0:	39 05 a0 0b 00 00    	cmp    %eax,0xba0
 7f6:	75 ed                	jne    7e5 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 7f8:	89 d8                	mov    %ebx,%eax
 7fa:	e8 2c ff ff ff       	call   72b <morecore>
 7ff:	85 c0                	test   %eax,%eax
 801:	75 e2                	jne    7e5 <malloc+0x6a>
        return 0;
 803:	b8 00 00 00 00       	mov    $0x0,%eax
 808:	eb cf                	jmp    7d9 <malloc+0x5e>
