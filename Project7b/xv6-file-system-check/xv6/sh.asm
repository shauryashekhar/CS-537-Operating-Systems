
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <getcmd>:
  exit();
}

int
getcmd(char *buf, int nbuf)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 5d 08             	mov    0x8(%ebp),%ebx
   8:	8b 75 0c             	mov    0xc(%ebp),%esi
  printf(2, "$ ");
   b:	83 ec 08             	sub    $0x8,%esp
   e:	68 40 0f 00 00       	push   $0xf40
  13:	6a 02                	push   $0x2
  15:	e8 6e 0c 00 00       	call   c88 <printf>
  memset(buf, 0, nbuf);
  1a:	83 c4 0c             	add    $0xc,%esp
  1d:	56                   	push   %esi
  1e:	6a 00                	push   $0x0
  20:	53                   	push   %ebx
  21:	e8 f9 09 00 00       	call   a1f <memset>
  gets(buf, nbuf);
  26:	83 c4 08             	add    $0x8,%esp
  29:	56                   	push   %esi
  2a:	53                   	push   %ebx
  2b:	e8 27 0a 00 00       	call   a57 <gets>
  if(buf[0] == 0) // EOF
  30:	83 c4 10             	add    $0x10,%esp
  33:	80 3b 00             	cmpb   $0x0,(%ebx)
  36:	74 0c                	je     44 <getcmd+0x44>
    return -1;
  return 0;
  38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  40:	5b                   	pop    %ebx
  41:	5e                   	pop    %esi
  42:	5d                   	pop    %ebp
  43:	c3                   	ret    
    return -1;
  44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  49:	eb f2                	jmp    3d <getcmd+0x3d>

0000004b <panic>:
  exit();
}

void
panic(char *s)
{
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	83 ec 0c             	sub    $0xc,%esp
  printf(2, "%s\n", s);
  51:	ff 75 08             	pushl  0x8(%ebp)
  54:	68 dd 0f 00 00       	push   $0xfdd
  59:	6a 02                	push   $0x2
  5b:	e8 28 0c 00 00       	call   c88 <printf>
  exit();
  60:	e8 e9 0a 00 00       	call   b4e <exit>

00000065 <fork1>:
}

int
fork1(void)
{
  65:	55                   	push   %ebp
  66:	89 e5                	mov    %esp,%ebp
  68:	83 ec 08             	sub    $0x8,%esp
  int pid;

  pid = fork();
  6b:	e8 d6 0a 00 00       	call   b46 <fork>
  if(pid == -1)
  70:	83 f8 ff             	cmp    $0xffffffff,%eax
  73:	74 02                	je     77 <fork1+0x12>
    panic("fork");
  return pid;
}
  75:	c9                   	leave  
  76:	c3                   	ret    
    panic("fork");
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	68 43 0f 00 00       	push   $0xf43
  7f:	e8 c7 ff ff ff       	call   4b <panic>

00000084 <runcmd>:
{
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	53                   	push   %ebx
  88:	83 ec 14             	sub    $0x14,%esp
  8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(cmd == 0)
  8e:	85 db                	test   %ebx,%ebx
  90:	74 0e                	je     a0 <runcmd+0x1c>
  switch(cmd->type){
  92:	8b 03                	mov    (%ebx),%eax
  94:	83 f8 05             	cmp    $0x5,%eax
  97:	77 0c                	ja     a5 <runcmd+0x21>
  99:	ff 24 85 f8 0f 00 00 	jmp    *0xff8(,%eax,4)
    exit();
  a0:	e8 a9 0a 00 00       	call   b4e <exit>
    panic("runcmd");
  a5:	83 ec 0c             	sub    $0xc,%esp
  a8:	68 48 0f 00 00       	push   $0xf48
  ad:	e8 99 ff ff ff       	call   4b <panic>
    if(ecmd->argv[0] == 0)
  b2:	8b 43 04             	mov    0x4(%ebx),%eax
  b5:	85 c0                	test   %eax,%eax
  b7:	74 27                	je     e0 <runcmd+0x5c>
    exec(ecmd->argv[0], ecmd->argv);
  b9:	8d 53 04             	lea    0x4(%ebx),%edx
  bc:	83 ec 08             	sub    $0x8,%esp
  bf:	52                   	push   %edx
  c0:	50                   	push   %eax
  c1:	e8 c0 0a 00 00       	call   b86 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
  c6:	83 c4 0c             	add    $0xc,%esp
  c9:	ff 73 04             	pushl  0x4(%ebx)
  cc:	68 4f 0f 00 00       	push   $0xf4f
  d1:	6a 02                	push   $0x2
  d3:	e8 b0 0b 00 00       	call   c88 <printf>
    break;
  d8:	83 c4 10             	add    $0x10,%esp
  db:	e9 3a 01 00 00       	jmp    21a <runcmd+0x196>
      exit();
  e0:	e8 69 0a 00 00       	call   b4e <exit>
    close(rcmd->fd);
  e5:	83 ec 0c             	sub    $0xc,%esp
  e8:	ff 73 14             	pushl  0x14(%ebx)
  eb:	e8 86 0a 00 00       	call   b76 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
  f0:	83 c4 08             	add    $0x8,%esp
  f3:	ff 73 10             	pushl  0x10(%ebx)
  f6:	ff 73 08             	pushl  0x8(%ebx)
  f9:	e8 90 0a 00 00       	call   b8e <open>
  fe:	83 c4 10             	add    $0x10,%esp
 101:	85 c0                	test   %eax,%eax
 103:	79 17                	jns    11c <runcmd+0x98>
      printf(2, "open %s failed\n", rcmd->file);
 105:	83 ec 04             	sub    $0x4,%esp
 108:	ff 73 08             	pushl  0x8(%ebx)
 10b:	68 5f 0f 00 00       	push   $0xf5f
 110:	6a 02                	push   $0x2
 112:	e8 71 0b 00 00       	call   c88 <printf>
      exit();
 117:	e8 32 0a 00 00       	call   b4e <exit>
    runcmd(rcmd->cmd);
 11c:	83 ec 0c             	sub    $0xc,%esp
 11f:	ff 73 04             	pushl  0x4(%ebx)
 122:	e8 5d ff ff ff       	call   84 <runcmd>
    if(fork1() == 0)
 127:	e8 39 ff ff ff       	call   65 <fork1>
 12c:	85 c0                	test   %eax,%eax
 12e:	74 10                	je     140 <runcmd+0xbc>
    wait();
 130:	e8 21 0a 00 00       	call   b56 <wait>
    runcmd(lcmd->right);
 135:	83 ec 0c             	sub    $0xc,%esp
 138:	ff 73 08             	pushl  0x8(%ebx)
 13b:	e8 44 ff ff ff       	call   84 <runcmd>
      runcmd(lcmd->left);
 140:	83 ec 0c             	sub    $0xc,%esp
 143:	ff 73 04             	pushl  0x4(%ebx)
 146:	e8 39 ff ff ff       	call   84 <runcmd>
    if(pipe(p) < 0)
 14b:	83 ec 0c             	sub    $0xc,%esp
 14e:	8d 45 f0             	lea    -0x10(%ebp),%eax
 151:	50                   	push   %eax
 152:	e8 07 0a 00 00       	call   b5e <pipe>
 157:	83 c4 10             	add    $0x10,%esp
 15a:	85 c0                	test   %eax,%eax
 15c:	78 3a                	js     198 <runcmd+0x114>
    if(fork1() == 0){
 15e:	e8 02 ff ff ff       	call   65 <fork1>
 163:	85 c0                	test   %eax,%eax
 165:	74 3e                	je     1a5 <runcmd+0x121>
    if(fork1() == 0){
 167:	e8 f9 fe ff ff       	call   65 <fork1>
 16c:	85 c0                	test   %eax,%eax
 16e:	74 6b                	je     1db <runcmd+0x157>
    close(p[0]);
 170:	83 ec 0c             	sub    $0xc,%esp
 173:	ff 75 f0             	pushl  -0x10(%ebp)
 176:	e8 fb 09 00 00       	call   b76 <close>
    close(p[1]);
 17b:	83 c4 04             	add    $0x4,%esp
 17e:	ff 75 f4             	pushl  -0xc(%ebp)
 181:	e8 f0 09 00 00       	call   b76 <close>
    wait();
 186:	e8 cb 09 00 00       	call   b56 <wait>
    wait();
 18b:	e8 c6 09 00 00       	call   b56 <wait>
    break;
 190:	83 c4 10             	add    $0x10,%esp
 193:	e9 82 00 00 00       	jmp    21a <runcmd+0x196>
      panic("pipe");
 198:	83 ec 0c             	sub    $0xc,%esp
 19b:	68 6f 0f 00 00       	push   $0xf6f
 1a0:	e8 a6 fe ff ff       	call   4b <panic>
      close(1);
 1a5:	83 ec 0c             	sub    $0xc,%esp
 1a8:	6a 01                	push   $0x1
 1aa:	e8 c7 09 00 00       	call   b76 <close>
      dup(p[1]);
 1af:	83 c4 04             	add    $0x4,%esp
 1b2:	ff 75 f4             	pushl  -0xc(%ebp)
 1b5:	e8 0c 0a 00 00       	call   bc6 <dup>
      close(p[0]);
 1ba:	83 c4 04             	add    $0x4,%esp
 1bd:	ff 75 f0             	pushl  -0x10(%ebp)
 1c0:	e8 b1 09 00 00       	call   b76 <close>
      close(p[1]);
 1c5:	83 c4 04             	add    $0x4,%esp
 1c8:	ff 75 f4             	pushl  -0xc(%ebp)
 1cb:	e8 a6 09 00 00       	call   b76 <close>
      runcmd(pcmd->left);
 1d0:	83 c4 04             	add    $0x4,%esp
 1d3:	ff 73 04             	pushl  0x4(%ebx)
 1d6:	e8 a9 fe ff ff       	call   84 <runcmd>
      close(0);
 1db:	83 ec 0c             	sub    $0xc,%esp
 1de:	6a 00                	push   $0x0
 1e0:	e8 91 09 00 00       	call   b76 <close>
      dup(p[0]);
 1e5:	83 c4 04             	add    $0x4,%esp
 1e8:	ff 75 f0             	pushl  -0x10(%ebp)
 1eb:	e8 d6 09 00 00       	call   bc6 <dup>
      close(p[0]);
 1f0:	83 c4 04             	add    $0x4,%esp
 1f3:	ff 75 f0             	pushl  -0x10(%ebp)
 1f6:	e8 7b 09 00 00       	call   b76 <close>
      close(p[1]);
 1fb:	83 c4 04             	add    $0x4,%esp
 1fe:	ff 75 f4             	pushl  -0xc(%ebp)
 201:	e8 70 09 00 00       	call   b76 <close>
      runcmd(pcmd->right);
 206:	83 c4 04             	add    $0x4,%esp
 209:	ff 73 08             	pushl  0x8(%ebx)
 20c:	e8 73 fe ff ff       	call   84 <runcmd>
    if(fork1() == 0)
 211:	e8 4f fe ff ff       	call   65 <fork1>
 216:	85 c0                	test   %eax,%eax
 218:	74 05                	je     21f <runcmd+0x19b>
  exit();
 21a:	e8 2f 09 00 00       	call   b4e <exit>
      runcmd(bcmd->cmd);
 21f:	83 ec 0c             	sub    $0xc,%esp
 222:	ff 73 04             	pushl  0x4(%ebx)
 225:	e8 5a fe ff ff       	call   84 <runcmd>

0000022a <execcmd>:

// Constructors

struct cmd*
execcmd(void)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	53                   	push   %ebx
 22e:	83 ec 10             	sub    $0x10,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 231:	6a 54                	push   $0x54
 233:	e8 79 0c 00 00       	call   eb1 <malloc>
 238:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 23a:	83 c4 0c             	add    $0xc,%esp
 23d:	6a 54                	push   $0x54
 23f:	6a 00                	push   $0x0
 241:	50                   	push   %eax
 242:	e8 d8 07 00 00       	call   a1f <memset>
  cmd->type = EXEC;
 247:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  return (struct cmd*)cmd;
}
 24d:	89 d8                	mov    %ebx,%eax
 24f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 252:	c9                   	leave  
 253:	c3                   	ret    

00000254 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
 254:	55                   	push   %ebp
 255:	89 e5                	mov    %esp,%ebp
 257:	53                   	push   %ebx
 258:	83 ec 10             	sub    $0x10,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
 25b:	6a 18                	push   $0x18
 25d:	e8 4f 0c 00 00       	call   eb1 <malloc>
 262:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 264:	83 c4 0c             	add    $0xc,%esp
 267:	6a 18                	push   $0x18
 269:	6a 00                	push   $0x0
 26b:	50                   	push   %eax
 26c:	e8 ae 07 00 00       	call   a1f <memset>
  cmd->type = REDIR;
 271:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  cmd->cmd = subcmd;
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->file = file;
 27d:	8b 45 0c             	mov    0xc(%ebp),%eax
 280:	89 43 08             	mov    %eax,0x8(%ebx)
  cmd->efile = efile;
 283:	8b 45 10             	mov    0x10(%ebp),%eax
 286:	89 43 0c             	mov    %eax,0xc(%ebx)
  cmd->mode = mode;
 289:	8b 45 14             	mov    0x14(%ebp),%eax
 28c:	89 43 10             	mov    %eax,0x10(%ebx)
  cmd->fd = fd;
 28f:	8b 45 18             	mov    0x18(%ebp),%eax
 292:	89 43 14             	mov    %eax,0x14(%ebx)
  return (struct cmd*)cmd;
}
 295:	89 d8                	mov    %ebx,%eax
 297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	53                   	push   %ebx
 2a0:	83 ec 10             	sub    $0x10,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
 2a3:	6a 0c                	push   $0xc
 2a5:	e8 07 0c 00 00       	call   eb1 <malloc>
 2aa:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 2ac:	83 c4 0c             	add    $0xc,%esp
 2af:	6a 0c                	push   $0xc
 2b1:	6a 00                	push   $0x0
 2b3:	50                   	push   %eax
 2b4:	e8 66 07 00 00       	call   a1f <memset>
  cmd->type = PIPE;
 2b9:	c7 03 03 00 00 00    	movl   $0x3,(%ebx)
  cmd->left = left;
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
 2c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c8:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
 2cb:	89 d8                	mov    %ebx,%eax
 2cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2d0:	c9                   	leave  
 2d1:	c3                   	ret    

000002d2 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
 2d2:	55                   	push   %ebp
 2d3:	89 e5                	mov    %esp,%ebp
 2d5:	53                   	push   %ebx
 2d6:	83 ec 10             	sub    $0x10,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 2d9:	6a 0c                	push   $0xc
 2db:	e8 d1 0b 00 00       	call   eb1 <malloc>
 2e0:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 2e2:	83 c4 0c             	add    $0xc,%esp
 2e5:	6a 0c                	push   $0xc
 2e7:	6a 00                	push   $0x0
 2e9:	50                   	push   %eax
 2ea:	e8 30 07 00 00       	call   a1f <memset>
  cmd->type = LIST;
 2ef:	c7 03 04 00 00 00    	movl   $0x4,(%ebx)
  cmd->left = left;
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
 2fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fe:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
 301:	89 d8                	mov    %ebx,%eax
 303:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 306:	c9                   	leave  
 307:	c3                   	ret    

00000308 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
 308:	55                   	push   %ebp
 309:	89 e5                	mov    %esp,%ebp
 30b:	53                   	push   %ebx
 30c:	83 ec 10             	sub    $0x10,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
 30f:	6a 08                	push   $0x8
 311:	e8 9b 0b 00 00       	call   eb1 <malloc>
 316:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
 318:	83 c4 0c             	add    $0xc,%esp
 31b:	6a 08                	push   $0x8
 31d:	6a 00                	push   $0x0
 31f:	50                   	push   %eax
 320:	e8 fa 06 00 00       	call   a1f <memset>
  cmd->type = BACK;
 325:	c7 03 05 00 00 00    	movl   $0x5,(%ebx)
  cmd->cmd = subcmd;
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	89 43 04             	mov    %eax,0x4(%ebx)
  return (struct cmd*)cmd;
}
 331:	89 d8                	mov    %ebx,%eax
 333:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 336:	c9                   	leave  
 337:	c3                   	ret    

00000338 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
 338:	55                   	push   %ebp
 339:	89 e5                	mov    %esp,%ebp
 33b:	57                   	push   %edi
 33c:	56                   	push   %esi
 33d:	53                   	push   %ebx
 33e:	83 ec 0c             	sub    $0xc,%esp
 341:	8b 75 0c             	mov    0xc(%ebp),%esi
 344:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *s;
  int ret;

  s = *ps;
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	8b 18                	mov    (%eax),%ebx
  while(s < es && strchr(whitespace, *s))
 34c:	eb 03                	jmp    351 <gettoken+0x19>
    s++;
 34e:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
 351:	39 f3                	cmp    %esi,%ebx
 353:	73 18                	jae    36d <gettoken+0x35>
 355:	83 ec 08             	sub    $0x8,%esp
 358:	0f be 03             	movsbl (%ebx),%eax
 35b:	50                   	push   %eax
 35c:	68 ac 15 00 00       	push   $0x15ac
 361:	e8 d0 06 00 00       	call   a36 <strchr>
 366:	83 c4 10             	add    $0x10,%esp
 369:	85 c0                	test   %eax,%eax
 36b:	75 e1                	jne    34e <gettoken+0x16>
  if(q)
 36d:	85 ff                	test   %edi,%edi
 36f:	74 02                	je     373 <gettoken+0x3b>
    *q = s;
 371:	89 1f                	mov    %ebx,(%edi)
  ret = *s;
 373:	0f b6 03             	movzbl (%ebx),%eax
 376:	0f be f8             	movsbl %al,%edi
  switch(*s){
 379:	3c 29                	cmp    $0x29,%al
 37b:	7f 25                	jg     3a2 <gettoken+0x6a>
 37d:	3c 28                	cmp    $0x28,%al
 37f:	7d 1c                	jge    39d <gettoken+0x65>
 381:	84 c0                	test   %al,%al
 383:	75 14                	jne    399 <gettoken+0x61>
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
 385:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 389:	0f 84 99 00 00 00    	je     428 <gettoken+0xf0>
    *eq = s;
 38f:	8b 45 14             	mov    0x14(%ebp),%eax
 392:	89 18                	mov    %ebx,(%eax)
 394:	e9 8f 00 00 00       	jmp    428 <gettoken+0xf0>
  switch(*s){
 399:	3c 26                	cmp    $0x26,%al
 39b:	75 36                	jne    3d3 <gettoken+0x9b>
    s++;
 39d:	83 c3 01             	add    $0x1,%ebx
    break;
 3a0:	eb e3                	jmp    385 <gettoken+0x4d>
  switch(*s){
 3a2:	3c 3e                	cmp    $0x3e,%al
 3a4:	74 13                	je     3b9 <gettoken+0x81>
 3a6:	3c 3e                	cmp    $0x3e,%al
 3a8:	7f 09                	jg     3b3 <gettoken+0x7b>
 3aa:	83 e8 3b             	sub    $0x3b,%eax
 3ad:	3c 01                	cmp    $0x1,%al
 3af:	77 22                	ja     3d3 <gettoken+0x9b>
 3b1:	eb ea                	jmp    39d <gettoken+0x65>
 3b3:	3c 7c                	cmp    $0x7c,%al
 3b5:	75 1c                	jne    3d3 <gettoken+0x9b>
 3b7:	eb e4                	jmp    39d <gettoken+0x65>
    s++;
 3b9:	8d 43 01             	lea    0x1(%ebx),%eax
    if(*s == '>'){
 3bc:	80 7b 01 3e          	cmpb   $0x3e,0x1(%ebx)
 3c0:	74 04                	je     3c6 <gettoken+0x8e>
    s++;
 3c2:	89 c3                	mov    %eax,%ebx
 3c4:	eb bf                	jmp    385 <gettoken+0x4d>
      s++;
 3c6:	83 c3 02             	add    $0x2,%ebx
      ret = '+';
 3c9:	bf 2b 00 00 00       	mov    $0x2b,%edi
 3ce:	eb b5                	jmp    385 <gettoken+0x4d>
      s++;
 3d0:	83 c3 01             	add    $0x1,%ebx
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
 3d3:	39 f3                	cmp    %esi,%ebx
 3d5:	73 3a                	jae    411 <gettoken+0xd9>
 3d7:	83 ec 08             	sub    $0x8,%esp
 3da:	0f be 03             	movsbl (%ebx),%eax
 3dd:	50                   	push   %eax
 3de:	68 ac 15 00 00       	push   $0x15ac
 3e3:	e8 4e 06 00 00       	call   a36 <strchr>
 3e8:	83 c4 10             	add    $0x10,%esp
 3eb:	85 c0                	test   %eax,%eax
 3ed:	75 2c                	jne    41b <gettoken+0xe3>
 3ef:	83 ec 08             	sub    $0x8,%esp
 3f2:	0f be 03             	movsbl (%ebx),%eax
 3f5:	50                   	push   %eax
 3f6:	68 a4 15 00 00       	push   $0x15a4
 3fb:	e8 36 06 00 00       	call   a36 <strchr>
 400:	83 c4 10             	add    $0x10,%esp
 403:	85 c0                	test   %eax,%eax
 405:	74 c9                	je     3d0 <gettoken+0x98>
    ret = 'a';
 407:	bf 61 00 00 00       	mov    $0x61,%edi
 40c:	e9 74 ff ff ff       	jmp    385 <gettoken+0x4d>
 411:	bf 61 00 00 00       	mov    $0x61,%edi
 416:	e9 6a ff ff ff       	jmp    385 <gettoken+0x4d>
 41b:	bf 61 00 00 00       	mov    $0x61,%edi
 420:	e9 60 ff ff ff       	jmp    385 <gettoken+0x4d>

  while(s < es && strchr(whitespace, *s))
    s++;
 425:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
 428:	39 f3                	cmp    %esi,%ebx
 42a:	73 18                	jae    444 <gettoken+0x10c>
 42c:	83 ec 08             	sub    $0x8,%esp
 42f:	0f be 03             	movsbl (%ebx),%eax
 432:	50                   	push   %eax
 433:	68 ac 15 00 00       	push   $0x15ac
 438:	e8 f9 05 00 00       	call   a36 <strchr>
 43d:	83 c4 10             	add    $0x10,%esp
 440:	85 c0                	test   %eax,%eax
 442:	75 e1                	jne    425 <gettoken+0xed>
  *ps = s;
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	89 18                	mov    %ebx,(%eax)
  return ret;
}
 449:	89 f8                	mov    %edi,%eax
 44b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 44e:	5b                   	pop    %ebx
 44f:	5e                   	pop    %esi
 450:	5f                   	pop    %edi
 451:	5d                   	pop    %ebp
 452:	c3                   	ret    

00000453 <peek>:

int
peek(char **ps, char *es, char *toks)
{
 453:	55                   	push   %ebp
 454:	89 e5                	mov    %esp,%ebp
 456:	57                   	push   %edi
 457:	56                   	push   %esi
 458:	53                   	push   %ebx
 459:	83 ec 0c             	sub    $0xc,%esp
 45c:	8b 7d 08             	mov    0x8(%ebp),%edi
 45f:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *s;

  s = *ps;
 462:	8b 1f                	mov    (%edi),%ebx
  while(s < es && strchr(whitespace, *s))
 464:	eb 03                	jmp    469 <peek+0x16>
    s++;
 466:	83 c3 01             	add    $0x1,%ebx
  while(s < es && strchr(whitespace, *s))
 469:	39 f3                	cmp    %esi,%ebx
 46b:	73 18                	jae    485 <peek+0x32>
 46d:	83 ec 08             	sub    $0x8,%esp
 470:	0f be 03             	movsbl (%ebx),%eax
 473:	50                   	push   %eax
 474:	68 ac 15 00 00       	push   $0x15ac
 479:	e8 b8 05 00 00       	call   a36 <strchr>
 47e:	83 c4 10             	add    $0x10,%esp
 481:	85 c0                	test   %eax,%eax
 483:	75 e1                	jne    466 <peek+0x13>
  *ps = s;
 485:	89 1f                	mov    %ebx,(%edi)
  return *s && strchr(toks, *s);
 487:	0f b6 03             	movzbl (%ebx),%eax
 48a:	84 c0                	test   %al,%al
 48c:	75 0d                	jne    49b <peek+0x48>
 48e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 493:	8d 65 f4             	lea    -0xc(%ebp),%esp
 496:	5b                   	pop    %ebx
 497:	5e                   	pop    %esi
 498:	5f                   	pop    %edi
 499:	5d                   	pop    %ebp
 49a:	c3                   	ret    
  return *s && strchr(toks, *s);
 49b:	83 ec 08             	sub    $0x8,%esp
 49e:	0f be c0             	movsbl %al,%eax
 4a1:	50                   	push   %eax
 4a2:	ff 75 10             	pushl  0x10(%ebp)
 4a5:	e8 8c 05 00 00       	call   a36 <strchr>
 4aa:	83 c4 10             	add    $0x10,%esp
 4ad:	85 c0                	test   %eax,%eax
 4af:	74 07                	je     4b8 <peek+0x65>
 4b1:	b8 01 00 00 00       	mov    $0x1,%eax
 4b6:	eb db                	jmp    493 <peek+0x40>
 4b8:	b8 00 00 00 00       	mov    $0x0,%eax
 4bd:	eb d4                	jmp    493 <peek+0x40>

000004bf <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	57                   	push   %edi
 4c3:	56                   	push   %esi
 4c4:	53                   	push   %ebx
 4c5:	83 ec 1c             	sub    $0x1c,%esp
 4c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
 4cb:	8b 75 10             	mov    0x10(%ebp),%esi
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
 4ce:	eb 28                	jmp    4f8 <parseredirs+0x39>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
      panic("missing file for redirection");
 4d0:	83 ec 0c             	sub    $0xc,%esp
 4d3:	68 74 0f 00 00       	push   $0xf74
 4d8:	e8 6e fb ff ff       	call   4b <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
 4dd:	83 ec 0c             	sub    $0xc,%esp
 4e0:	6a 00                	push   $0x0
 4e2:	6a 00                	push   $0x0
 4e4:	ff 75 e0             	pushl  -0x20(%ebp)
 4e7:	ff 75 e4             	pushl  -0x1c(%ebp)
 4ea:	ff 75 08             	pushl  0x8(%ebp)
 4ed:	e8 62 fd ff ff       	call   254 <redircmd>
 4f2:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 4f5:	83 c4 20             	add    $0x20,%esp
  while(peek(ps, es, "<>")){
 4f8:	83 ec 04             	sub    $0x4,%esp
 4fb:	68 91 0f 00 00       	push   $0xf91
 500:	56                   	push   %esi
 501:	57                   	push   %edi
 502:	e8 4c ff ff ff       	call   453 <peek>
 507:	83 c4 10             	add    $0x10,%esp
 50a:	85 c0                	test   %eax,%eax
 50c:	74 76                	je     584 <parseredirs+0xc5>
    tok = gettoken(ps, es, 0, 0);
 50e:	6a 00                	push   $0x0
 510:	6a 00                	push   $0x0
 512:	56                   	push   %esi
 513:	57                   	push   %edi
 514:	e8 1f fe ff ff       	call   338 <gettoken>
 519:	89 c3                	mov    %eax,%ebx
    if(gettoken(ps, es, &q, &eq) != 'a')
 51b:	8d 45 e0             	lea    -0x20(%ebp),%eax
 51e:	50                   	push   %eax
 51f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 522:	50                   	push   %eax
 523:	56                   	push   %esi
 524:	57                   	push   %edi
 525:	e8 0e fe ff ff       	call   338 <gettoken>
 52a:	83 c4 20             	add    $0x20,%esp
 52d:	83 f8 61             	cmp    $0x61,%eax
 530:	75 9e                	jne    4d0 <parseredirs+0x11>
    switch(tok){
 532:	83 fb 3c             	cmp    $0x3c,%ebx
 535:	74 a6                	je     4dd <parseredirs+0x1e>
 537:	83 fb 3e             	cmp    $0x3e,%ebx
 53a:	74 25                	je     561 <parseredirs+0xa2>
 53c:	83 fb 2b             	cmp    $0x2b,%ebx
 53f:	75 b7                	jne    4f8 <parseredirs+0x39>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
 541:	83 ec 0c             	sub    $0xc,%esp
 544:	6a 01                	push   $0x1
 546:	68 01 02 00 00       	push   $0x201
 54b:	ff 75 e0             	pushl  -0x20(%ebp)
 54e:	ff 75 e4             	pushl  -0x1c(%ebp)
 551:	ff 75 08             	pushl  0x8(%ebp)
 554:	e8 fb fc ff ff       	call   254 <redircmd>
 559:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 55c:	83 c4 20             	add    $0x20,%esp
 55f:	eb 97                	jmp    4f8 <parseredirs+0x39>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
 561:	83 ec 0c             	sub    $0xc,%esp
 564:	6a 01                	push   $0x1
 566:	68 01 02 00 00       	push   $0x201
 56b:	ff 75 e0             	pushl  -0x20(%ebp)
 56e:	ff 75 e4             	pushl  -0x1c(%ebp)
 571:	ff 75 08             	pushl  0x8(%ebp)
 574:	e8 db fc ff ff       	call   254 <redircmd>
 579:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
 57c:	83 c4 20             	add    $0x20,%esp
 57f:	e9 74 ff ff ff       	jmp    4f8 <parseredirs+0x39>
    }
  }
  return cmd;
}
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	8d 65 f4             	lea    -0xc(%ebp),%esp
 58a:	5b                   	pop    %ebx
 58b:	5e                   	pop    %esi
 58c:	5f                   	pop    %edi
 58d:	5d                   	pop    %ebp
 58e:	c3                   	ret    

0000058f <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
 58f:	55                   	push   %ebp
 590:	89 e5                	mov    %esp,%ebp
 592:	57                   	push   %edi
 593:	56                   	push   %esi
 594:	53                   	push   %ebx
 595:	83 ec 30             	sub    $0x30,%esp
 598:	8b 75 08             	mov    0x8(%ebp),%esi
 59b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
 59e:	68 94 0f 00 00       	push   $0xf94
 5a3:	57                   	push   %edi
 5a4:	56                   	push   %esi
 5a5:	e8 a9 fe ff ff       	call   453 <peek>
 5aa:	83 c4 10             	add    $0x10,%esp
 5ad:	85 c0                	test   %eax,%eax
 5af:	75 7a                	jne    62b <parseexec+0x9c>
 5b1:	89 c3                	mov    %eax,%ebx
    return parseblock(ps, es);

  ret = execcmd();
 5b3:	e8 72 fc ff ff       	call   22a <execcmd>
 5b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
 5bb:	83 ec 04             	sub    $0x4,%esp
 5be:	57                   	push   %edi
 5bf:	56                   	push   %esi
 5c0:	50                   	push   %eax
 5c1:	e8 f9 fe ff ff       	call   4bf <parseredirs>
 5c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  while(!peek(ps, es, "|)&;")){
 5c9:	83 c4 10             	add    $0x10,%esp
 5cc:	83 ec 04             	sub    $0x4,%esp
 5cf:	68 ab 0f 00 00       	push   $0xfab
 5d4:	57                   	push   %edi
 5d5:	56                   	push   %esi
 5d6:	e8 78 fe ff ff       	call   453 <peek>
 5db:	83 c4 10             	add    $0x10,%esp
 5de:	85 c0                	test   %eax,%eax
 5e0:	75 7e                	jne    660 <parseexec+0xd1>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
 5e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
 5e5:	50                   	push   %eax
 5e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 5e9:	50                   	push   %eax
 5ea:	57                   	push   %edi
 5eb:	56                   	push   %esi
 5ec:	e8 47 fd ff ff       	call   338 <gettoken>
 5f1:	83 c4 10             	add    $0x10,%esp
 5f4:	85 c0                	test   %eax,%eax
 5f6:	74 68                	je     660 <parseexec+0xd1>
      break;
    if(tok != 'a')
 5f8:	83 f8 61             	cmp    $0x61,%eax
 5fb:	75 49                	jne    646 <parseexec+0xb7>
      panic("syntax");
    cmd->argv[argc] = q;
 5fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 600:	8b 55 d0             	mov    -0x30(%ebp),%edx
 603:	89 44 9a 04          	mov    %eax,0x4(%edx,%ebx,4)
    cmd->eargv[argc] = eq;
 607:	8b 45 e0             	mov    -0x20(%ebp),%eax
 60a:	89 44 9a 2c          	mov    %eax,0x2c(%edx,%ebx,4)
    argc++;
 60e:	83 c3 01             	add    $0x1,%ebx
    if(argc >= MAXARGS)
 611:	83 fb 09             	cmp    $0x9,%ebx
 614:	7f 3d                	jg     653 <parseexec+0xc4>
      panic("too many args");
    ret = parseredirs(ret, ps, es);
 616:	83 ec 04             	sub    $0x4,%esp
 619:	57                   	push   %edi
 61a:	56                   	push   %esi
 61b:	ff 75 d4             	pushl  -0x2c(%ebp)
 61e:	e8 9c fe ff ff       	call   4bf <parseredirs>
 623:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 626:	83 c4 10             	add    $0x10,%esp
 629:	eb a1                	jmp    5cc <parseexec+0x3d>
    return parseblock(ps, es);
 62b:	83 ec 08             	sub    $0x8,%esp
 62e:	57                   	push   %edi
 62f:	56                   	push   %esi
 630:	e8 2f 01 00 00       	call   764 <parseblock>
 635:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 638:	83 c4 10             	add    $0x10,%esp
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
 63b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 63e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 641:	5b                   	pop    %ebx
 642:	5e                   	pop    %esi
 643:	5f                   	pop    %edi
 644:	5d                   	pop    %ebp
 645:	c3                   	ret    
      panic("syntax");
 646:	83 ec 0c             	sub    $0xc,%esp
 649:	68 96 0f 00 00       	push   $0xf96
 64e:	e8 f8 f9 ff ff       	call   4b <panic>
      panic("too many args");
 653:	83 ec 0c             	sub    $0xc,%esp
 656:	68 9d 0f 00 00       	push   $0xf9d
 65b:	e8 eb f9 ff ff       	call   4b <panic>
  cmd->argv[argc] = 0;
 660:	8b 45 d0             	mov    -0x30(%ebp),%eax
 663:	c7 44 98 04 00 00 00 	movl   $0x0,0x4(%eax,%ebx,4)
 66a:	00 
  cmd->eargv[argc] = 0;
 66b:	c7 44 98 2c 00 00 00 	movl   $0x0,0x2c(%eax,%ebx,4)
 672:	00 
  return ret;
 673:	eb c6                	jmp    63b <parseexec+0xac>

00000675 <parsepipe>:
{
 675:	55                   	push   %ebp
 676:	89 e5                	mov    %esp,%ebp
 678:	57                   	push   %edi
 679:	56                   	push   %esi
 67a:	53                   	push   %ebx
 67b:	83 ec 14             	sub    $0x14,%esp
 67e:	8b 5d 08             	mov    0x8(%ebp),%ebx
 681:	8b 75 0c             	mov    0xc(%ebp),%esi
  cmd = parseexec(ps, es);
 684:	56                   	push   %esi
 685:	53                   	push   %ebx
 686:	e8 04 ff ff ff       	call   58f <parseexec>
 68b:	89 c7                	mov    %eax,%edi
  if(peek(ps, es, "|")){
 68d:	83 c4 0c             	add    $0xc,%esp
 690:	68 b0 0f 00 00       	push   $0xfb0
 695:	56                   	push   %esi
 696:	53                   	push   %ebx
 697:	e8 b7 fd ff ff       	call   453 <peek>
 69c:	83 c4 10             	add    $0x10,%esp
 69f:	85 c0                	test   %eax,%eax
 6a1:	75 0a                	jne    6ad <parsepipe+0x38>
}
 6a3:	89 f8                	mov    %edi,%eax
 6a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6a8:	5b                   	pop    %ebx
 6a9:	5e                   	pop    %esi
 6aa:	5f                   	pop    %edi
 6ab:	5d                   	pop    %ebp
 6ac:	c3                   	ret    
    gettoken(ps, es, 0, 0);
 6ad:	6a 00                	push   $0x0
 6af:	6a 00                	push   $0x0
 6b1:	56                   	push   %esi
 6b2:	53                   	push   %ebx
 6b3:	e8 80 fc ff ff       	call   338 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
 6b8:	83 c4 08             	add    $0x8,%esp
 6bb:	56                   	push   %esi
 6bc:	53                   	push   %ebx
 6bd:	e8 b3 ff ff ff       	call   675 <parsepipe>
 6c2:	83 c4 08             	add    $0x8,%esp
 6c5:	50                   	push   %eax
 6c6:	57                   	push   %edi
 6c7:	e8 d0 fb ff ff       	call   29c <pipecmd>
 6cc:	89 c7                	mov    %eax,%edi
 6ce:	83 c4 10             	add    $0x10,%esp
  return cmd;
 6d1:	eb d0                	jmp    6a3 <parsepipe+0x2e>

000006d3 <parseline>:
{
 6d3:	55                   	push   %ebp
 6d4:	89 e5                	mov    %esp,%ebp
 6d6:	57                   	push   %edi
 6d7:	56                   	push   %esi
 6d8:	53                   	push   %ebx
 6d9:	83 ec 14             	sub    $0x14,%esp
 6dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
 6df:	8b 75 0c             	mov    0xc(%ebp),%esi
  cmd = parsepipe(ps, es);
 6e2:	56                   	push   %esi
 6e3:	53                   	push   %ebx
 6e4:	e8 8c ff ff ff       	call   675 <parsepipe>
 6e9:	89 c7                	mov    %eax,%edi
  while(peek(ps, es, "&")){
 6eb:	83 c4 10             	add    $0x10,%esp
 6ee:	eb 18                	jmp    708 <parseline+0x35>
    gettoken(ps, es, 0, 0);
 6f0:	6a 00                	push   $0x0
 6f2:	6a 00                	push   $0x0
 6f4:	56                   	push   %esi
 6f5:	53                   	push   %ebx
 6f6:	e8 3d fc ff ff       	call   338 <gettoken>
    cmd = backcmd(cmd);
 6fb:	89 3c 24             	mov    %edi,(%esp)
 6fe:	e8 05 fc ff ff       	call   308 <backcmd>
 703:	89 c7                	mov    %eax,%edi
 705:	83 c4 10             	add    $0x10,%esp
  while(peek(ps, es, "&")){
 708:	83 ec 04             	sub    $0x4,%esp
 70b:	68 b2 0f 00 00       	push   $0xfb2
 710:	56                   	push   %esi
 711:	53                   	push   %ebx
 712:	e8 3c fd ff ff       	call   453 <peek>
 717:	83 c4 10             	add    $0x10,%esp
 71a:	85 c0                	test   %eax,%eax
 71c:	75 d2                	jne    6f0 <parseline+0x1d>
  if(peek(ps, es, ";")){
 71e:	83 ec 04             	sub    $0x4,%esp
 721:	68 ae 0f 00 00       	push   $0xfae
 726:	56                   	push   %esi
 727:	53                   	push   %ebx
 728:	e8 26 fd ff ff       	call   453 <peek>
 72d:	83 c4 10             	add    $0x10,%esp
 730:	85 c0                	test   %eax,%eax
 732:	75 0a                	jne    73e <parseline+0x6b>
}
 734:	89 f8                	mov    %edi,%eax
 736:	8d 65 f4             	lea    -0xc(%ebp),%esp
 739:	5b                   	pop    %ebx
 73a:	5e                   	pop    %esi
 73b:	5f                   	pop    %edi
 73c:	5d                   	pop    %ebp
 73d:	c3                   	ret    
    gettoken(ps, es, 0, 0);
 73e:	6a 00                	push   $0x0
 740:	6a 00                	push   $0x0
 742:	56                   	push   %esi
 743:	53                   	push   %ebx
 744:	e8 ef fb ff ff       	call   338 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
 749:	83 c4 08             	add    $0x8,%esp
 74c:	56                   	push   %esi
 74d:	53                   	push   %ebx
 74e:	e8 80 ff ff ff       	call   6d3 <parseline>
 753:	83 c4 08             	add    $0x8,%esp
 756:	50                   	push   %eax
 757:	57                   	push   %edi
 758:	e8 75 fb ff ff       	call   2d2 <listcmd>
 75d:	89 c7                	mov    %eax,%edi
 75f:	83 c4 10             	add    $0x10,%esp
  return cmd;
 762:	eb d0                	jmp    734 <parseline+0x61>

00000764 <parseblock>:
{
 764:	55                   	push   %ebp
 765:	89 e5                	mov    %esp,%ebp
 767:	57                   	push   %edi
 768:	56                   	push   %esi
 769:	53                   	push   %ebx
 76a:	83 ec 10             	sub    $0x10,%esp
 76d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 770:	8b 75 0c             	mov    0xc(%ebp),%esi
  if(!peek(ps, es, "("))
 773:	68 94 0f 00 00       	push   $0xf94
 778:	56                   	push   %esi
 779:	53                   	push   %ebx
 77a:	e8 d4 fc ff ff       	call   453 <peek>
 77f:	83 c4 10             	add    $0x10,%esp
 782:	85 c0                	test   %eax,%eax
 784:	74 4b                	je     7d1 <parseblock+0x6d>
  gettoken(ps, es, 0, 0);
 786:	6a 00                	push   $0x0
 788:	6a 00                	push   $0x0
 78a:	56                   	push   %esi
 78b:	53                   	push   %ebx
 78c:	e8 a7 fb ff ff       	call   338 <gettoken>
  cmd = parseline(ps, es);
 791:	83 c4 08             	add    $0x8,%esp
 794:	56                   	push   %esi
 795:	53                   	push   %ebx
 796:	e8 38 ff ff ff       	call   6d3 <parseline>
 79b:	89 c7                	mov    %eax,%edi
  if(!peek(ps, es, ")"))
 79d:	83 c4 0c             	add    $0xc,%esp
 7a0:	68 d0 0f 00 00       	push   $0xfd0
 7a5:	56                   	push   %esi
 7a6:	53                   	push   %ebx
 7a7:	e8 a7 fc ff ff       	call   453 <peek>
 7ac:	83 c4 10             	add    $0x10,%esp
 7af:	85 c0                	test   %eax,%eax
 7b1:	74 2b                	je     7de <parseblock+0x7a>
  gettoken(ps, es, 0, 0);
 7b3:	6a 00                	push   $0x0
 7b5:	6a 00                	push   $0x0
 7b7:	56                   	push   %esi
 7b8:	53                   	push   %ebx
 7b9:	e8 7a fb ff ff       	call   338 <gettoken>
  cmd = parseredirs(cmd, ps, es);
 7be:	83 c4 0c             	add    $0xc,%esp
 7c1:	56                   	push   %esi
 7c2:	53                   	push   %ebx
 7c3:	57                   	push   %edi
 7c4:	e8 f6 fc ff ff       	call   4bf <parseredirs>
}
 7c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 7cc:	5b                   	pop    %ebx
 7cd:	5e                   	pop    %esi
 7ce:	5f                   	pop    %edi
 7cf:	5d                   	pop    %ebp
 7d0:	c3                   	ret    
    panic("parseblock");
 7d1:	83 ec 0c             	sub    $0xc,%esp
 7d4:	68 b4 0f 00 00       	push   $0xfb4
 7d9:	e8 6d f8 ff ff       	call   4b <panic>
    panic("syntax - missing )");
 7de:	83 ec 0c             	sub    $0xc,%esp
 7e1:	68 bf 0f 00 00       	push   $0xfbf
 7e6:	e8 60 f8 ff ff       	call   4b <panic>

000007eb <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
 7eb:	55                   	push   %ebp
 7ec:	89 e5                	mov    %esp,%ebp
 7ee:	53                   	push   %ebx
 7ef:	83 ec 04             	sub    $0x4,%esp
 7f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
 7f5:	85 db                	test   %ebx,%ebx
 7f7:	74 1f                	je     818 <nulterminate+0x2d>
    return 0;

  switch(cmd->type){
 7f9:	8b 03                	mov    (%ebx),%eax
 7fb:	83 f8 05             	cmp    $0x5,%eax
 7fe:	77 18                	ja     818 <nulterminate+0x2d>
 800:	ff 24 85 10 10 00 00 	jmp    *0x1010(,%eax,4)
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
      *ecmd->eargv[i] = 0;
 807:	8b 54 83 2c          	mov    0x2c(%ebx,%eax,4),%edx
 80b:	c6 02 00             	movb   $0x0,(%edx)
    for(i=0; ecmd->argv[i]; i++)
 80e:	83 c0 01             	add    $0x1,%eax
 811:	83 7c 83 04 00       	cmpl   $0x0,0x4(%ebx,%eax,4)
 816:	75 ef                	jne    807 <nulterminate+0x1c>
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
 818:	89 d8                	mov    %ebx,%eax
 81a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 81d:	c9                   	leave  
 81e:	c3                   	ret    
    for(i=0; ecmd->argv[i]; i++)
 81f:	b8 00 00 00 00       	mov    $0x0,%eax
 824:	eb eb                	jmp    811 <nulterminate+0x26>
    nulterminate(rcmd->cmd);
 826:	83 ec 0c             	sub    $0xc,%esp
 829:	ff 73 04             	pushl  0x4(%ebx)
 82c:	e8 ba ff ff ff       	call   7eb <nulterminate>
    *rcmd->efile = 0;
 831:	8b 43 0c             	mov    0xc(%ebx),%eax
 834:	c6 00 00             	movb   $0x0,(%eax)
    break;
 837:	83 c4 10             	add    $0x10,%esp
 83a:	eb dc                	jmp    818 <nulterminate+0x2d>
    nulterminate(pcmd->left);
 83c:	83 ec 0c             	sub    $0xc,%esp
 83f:	ff 73 04             	pushl  0x4(%ebx)
 842:	e8 a4 ff ff ff       	call   7eb <nulterminate>
    nulterminate(pcmd->right);
 847:	83 c4 04             	add    $0x4,%esp
 84a:	ff 73 08             	pushl  0x8(%ebx)
 84d:	e8 99 ff ff ff       	call   7eb <nulterminate>
    break;
 852:	83 c4 10             	add    $0x10,%esp
 855:	eb c1                	jmp    818 <nulterminate+0x2d>
    nulterminate(lcmd->left);
 857:	83 ec 0c             	sub    $0xc,%esp
 85a:	ff 73 04             	pushl  0x4(%ebx)
 85d:	e8 89 ff ff ff       	call   7eb <nulterminate>
    nulterminate(lcmd->right);
 862:	83 c4 04             	add    $0x4,%esp
 865:	ff 73 08             	pushl  0x8(%ebx)
 868:	e8 7e ff ff ff       	call   7eb <nulterminate>
    break;
 86d:	83 c4 10             	add    $0x10,%esp
 870:	eb a6                	jmp    818 <nulterminate+0x2d>
    nulterminate(bcmd->cmd);
 872:	83 ec 0c             	sub    $0xc,%esp
 875:	ff 73 04             	pushl  0x4(%ebx)
 878:	e8 6e ff ff ff       	call   7eb <nulterminate>
    break;
 87d:	83 c4 10             	add    $0x10,%esp
 880:	eb 96                	jmp    818 <nulterminate+0x2d>

00000882 <parsecmd>:
{
 882:	55                   	push   %ebp
 883:	89 e5                	mov    %esp,%ebp
 885:	56                   	push   %esi
 886:	53                   	push   %ebx
  es = s + strlen(s);
 887:	8b 5d 08             	mov    0x8(%ebp),%ebx
 88a:	83 ec 0c             	sub    $0xc,%esp
 88d:	53                   	push   %ebx
 88e:	e8 72 01 00 00       	call   a05 <strlen>
 893:	01 c3                	add    %eax,%ebx
  cmd = parseline(&s, es);
 895:	83 c4 08             	add    $0x8,%esp
 898:	53                   	push   %ebx
 899:	8d 45 08             	lea    0x8(%ebp),%eax
 89c:	50                   	push   %eax
 89d:	e8 31 fe ff ff       	call   6d3 <parseline>
 8a2:	89 c6                	mov    %eax,%esi
  peek(&s, es, "");
 8a4:	83 c4 0c             	add    $0xc,%esp
 8a7:	68 5e 0f 00 00       	push   $0xf5e
 8ac:	53                   	push   %ebx
 8ad:	8d 45 08             	lea    0x8(%ebp),%eax
 8b0:	50                   	push   %eax
 8b1:	e8 9d fb ff ff       	call   453 <peek>
  if(s != es){
 8b6:	8b 45 08             	mov    0x8(%ebp),%eax
 8b9:	83 c4 10             	add    $0x10,%esp
 8bc:	39 d8                	cmp    %ebx,%eax
 8be:	75 12                	jne    8d2 <parsecmd+0x50>
  nulterminate(cmd);
 8c0:	83 ec 0c             	sub    $0xc,%esp
 8c3:	56                   	push   %esi
 8c4:	e8 22 ff ff ff       	call   7eb <nulterminate>
}
 8c9:	89 f0                	mov    %esi,%eax
 8cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
 8ce:	5b                   	pop    %ebx
 8cf:	5e                   	pop    %esi
 8d0:	5d                   	pop    %ebp
 8d1:	c3                   	ret    
    printf(2, "leftovers: %s\n", s);
 8d2:	83 ec 04             	sub    $0x4,%esp
 8d5:	50                   	push   %eax
 8d6:	68 d2 0f 00 00       	push   $0xfd2
 8db:	6a 02                	push   $0x2
 8dd:	e8 a6 03 00 00       	call   c88 <printf>
    panic("syntax");
 8e2:	c7 04 24 96 0f 00 00 	movl   $0xf96,(%esp)
 8e9:	e8 5d f7 ff ff       	call   4b <panic>

000008ee <main>:
{
 8ee:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 8f2:	83 e4 f0             	and    $0xfffffff0,%esp
 8f5:	ff 71 fc             	pushl  -0x4(%ecx)
 8f8:	55                   	push   %ebp
 8f9:	89 e5                	mov    %esp,%ebp
 8fb:	51                   	push   %ecx
 8fc:	83 ec 04             	sub    $0x4,%esp
  while((fd = open("console", O_RDWR)) >= 0){
 8ff:	83 ec 08             	sub    $0x8,%esp
 902:	6a 02                	push   $0x2
 904:	68 e1 0f 00 00       	push   $0xfe1
 909:	e8 80 02 00 00       	call   b8e <open>
 90e:	83 c4 10             	add    $0x10,%esp
 911:	85 c0                	test   %eax,%eax
 913:	78 21                	js     936 <main+0x48>
    if(fd >= 3){
 915:	83 f8 02             	cmp    $0x2,%eax
 918:	7e e5                	jle    8ff <main+0x11>
      close(fd);
 91a:	83 ec 0c             	sub    $0xc,%esp
 91d:	50                   	push   %eax
 91e:	e8 53 02 00 00       	call   b76 <close>
      break;
 923:	83 c4 10             	add    $0x10,%esp
 926:	eb 0e                	jmp    936 <main+0x48>
    if(fork1() == 0)
 928:	e8 38 f7 ff ff       	call   65 <fork1>
 92d:	85 c0                	test   %eax,%eax
 92f:	74 76                	je     9a7 <main+0xb9>
    wait();
 931:	e8 20 02 00 00       	call   b56 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
 936:	83 ec 08             	sub    $0x8,%esp
 939:	6a 64                	push   $0x64
 93b:	68 c0 15 00 00       	push   $0x15c0
 940:	e8 bb f6 ff ff       	call   0 <getcmd>
 945:	83 c4 10             	add    $0x10,%esp
 948:	85 c0                	test   %eax,%eax
 94a:	78 70                	js     9bc <main+0xce>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
 94c:	80 3d c0 15 00 00 63 	cmpb   $0x63,0x15c0
 953:	75 d3                	jne    928 <main+0x3a>
 955:	80 3d c1 15 00 00 64 	cmpb   $0x64,0x15c1
 95c:	75 ca                	jne    928 <main+0x3a>
 95e:	80 3d c2 15 00 00 20 	cmpb   $0x20,0x15c2
 965:	75 c1                	jne    928 <main+0x3a>
      buf[strlen(buf)-1] = 0;  // chop \n
 967:	83 ec 0c             	sub    $0xc,%esp
 96a:	68 c0 15 00 00       	push   $0x15c0
 96f:	e8 91 00 00 00       	call   a05 <strlen>
 974:	c6 80 bf 15 00 00 00 	movb   $0x0,0x15bf(%eax)
      if(chdir(buf+3) < 0)
 97b:	c7 04 24 c3 15 00 00 	movl   $0x15c3,(%esp)
 982:	e8 37 02 00 00       	call   bbe <chdir>
 987:	83 c4 10             	add    $0x10,%esp
 98a:	85 c0                	test   %eax,%eax
 98c:	79 a8                	jns    936 <main+0x48>
        printf(2, "cannot cd %s\n", buf+3);
 98e:	83 ec 04             	sub    $0x4,%esp
 991:	68 c3 15 00 00       	push   $0x15c3
 996:	68 e9 0f 00 00       	push   $0xfe9
 99b:	6a 02                	push   $0x2
 99d:	e8 e6 02 00 00       	call   c88 <printf>
 9a2:	83 c4 10             	add    $0x10,%esp
      continue;
 9a5:	eb 8f                	jmp    936 <main+0x48>
      runcmd(parsecmd(buf));
 9a7:	83 ec 0c             	sub    $0xc,%esp
 9aa:	68 c0 15 00 00       	push   $0x15c0
 9af:	e8 ce fe ff ff       	call   882 <parsecmd>
 9b4:	89 04 24             	mov    %eax,(%esp)
 9b7:	e8 c8 f6 ff ff       	call   84 <runcmd>
  exit();
 9bc:	e8 8d 01 00 00       	call   b4e <exit>

000009c1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 9c1:	55                   	push   %ebp
 9c2:	89 e5                	mov    %esp,%ebp
 9c4:	53                   	push   %ebx
 9c5:	8b 45 08             	mov    0x8(%ebp),%eax
 9c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 9cb:	89 c2                	mov    %eax,%edx
 9cd:	0f b6 19             	movzbl (%ecx),%ebx
 9d0:	88 1a                	mov    %bl,(%edx)
 9d2:	8d 52 01             	lea    0x1(%edx),%edx
 9d5:	8d 49 01             	lea    0x1(%ecx),%ecx
 9d8:	84 db                	test   %bl,%bl
 9da:	75 f1                	jne    9cd <strcpy+0xc>
    ;
  return os;
}
 9dc:	5b                   	pop    %ebx
 9dd:	5d                   	pop    %ebp
 9de:	c3                   	ret    

000009df <strcmp>:

int
strcmp(const char *p, const char *q)
{
 9df:	55                   	push   %ebp
 9e0:	89 e5                	mov    %esp,%ebp
 9e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 9e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 9e8:	eb 06                	jmp    9f0 <strcmp+0x11>
    p++, q++;
 9ea:	83 c1 01             	add    $0x1,%ecx
 9ed:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 9f0:	0f b6 01             	movzbl (%ecx),%eax
 9f3:	84 c0                	test   %al,%al
 9f5:	74 04                	je     9fb <strcmp+0x1c>
 9f7:	3a 02                	cmp    (%edx),%al
 9f9:	74 ef                	je     9ea <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 9fb:	0f b6 c0             	movzbl %al,%eax
 9fe:	0f b6 12             	movzbl (%edx),%edx
 a01:	29 d0                	sub    %edx,%eax
}
 a03:	5d                   	pop    %ebp
 a04:	c3                   	ret    

00000a05 <strlen>:

uint
strlen(const char *s)
{
 a05:	55                   	push   %ebp
 a06:	89 e5                	mov    %esp,%ebp
 a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 a0b:	ba 00 00 00 00       	mov    $0x0,%edx
 a10:	eb 03                	jmp    a15 <strlen+0x10>
 a12:	83 c2 01             	add    $0x1,%edx
 a15:	89 d0                	mov    %edx,%eax
 a17:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 a1b:	75 f5                	jne    a12 <strlen+0xd>
    ;
  return n;
}
 a1d:	5d                   	pop    %ebp
 a1e:	c3                   	ret    

00000a1f <memset>:

void*
memset(void *dst, int c, uint n)
{
 a1f:	55                   	push   %ebp
 a20:	89 e5                	mov    %esp,%ebp
 a22:	57                   	push   %edi
 a23:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 a26:	89 d7                	mov    %edx,%edi
 a28:	8b 4d 10             	mov    0x10(%ebp),%ecx
 a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
 a2e:	fc                   	cld    
 a2f:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 a31:	89 d0                	mov    %edx,%eax
 a33:	5f                   	pop    %edi
 a34:	5d                   	pop    %ebp
 a35:	c3                   	ret    

00000a36 <strchr>:

char*
strchr(const char *s, char c)
{
 a36:	55                   	push   %ebp
 a37:	89 e5                	mov    %esp,%ebp
 a39:	8b 45 08             	mov    0x8(%ebp),%eax
 a3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 a40:	0f b6 10             	movzbl (%eax),%edx
 a43:	84 d2                	test   %dl,%dl
 a45:	74 09                	je     a50 <strchr+0x1a>
    if(*s == c)
 a47:	38 ca                	cmp    %cl,%dl
 a49:	74 0a                	je     a55 <strchr+0x1f>
  for(; *s; s++)
 a4b:	83 c0 01             	add    $0x1,%eax
 a4e:	eb f0                	jmp    a40 <strchr+0xa>
      return (char*)s;
  return 0;
 a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
 a55:	5d                   	pop    %ebp
 a56:	c3                   	ret    

00000a57 <gets>:

char*
gets(char *buf, int max)
{
 a57:	55                   	push   %ebp
 a58:	89 e5                	mov    %esp,%ebp
 a5a:	57                   	push   %edi
 a5b:	56                   	push   %esi
 a5c:	53                   	push   %ebx
 a5d:	83 ec 1c             	sub    $0x1c,%esp
 a60:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 a63:	bb 00 00 00 00       	mov    $0x0,%ebx
 a68:	8d 73 01             	lea    0x1(%ebx),%esi
 a6b:	3b 75 0c             	cmp    0xc(%ebp),%esi
 a6e:	7d 2e                	jge    a9e <gets+0x47>
    cc = read(0, &c, 1);
 a70:	83 ec 04             	sub    $0x4,%esp
 a73:	6a 01                	push   $0x1
 a75:	8d 45 e7             	lea    -0x19(%ebp),%eax
 a78:	50                   	push   %eax
 a79:	6a 00                	push   $0x0
 a7b:	e8 e6 00 00 00       	call   b66 <read>
    if(cc < 1)
 a80:	83 c4 10             	add    $0x10,%esp
 a83:	85 c0                	test   %eax,%eax
 a85:	7e 17                	jle    a9e <gets+0x47>
      break;
    buf[i++] = c;
 a87:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 a8b:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 a8e:	3c 0a                	cmp    $0xa,%al
 a90:	0f 94 c2             	sete   %dl
 a93:	3c 0d                	cmp    $0xd,%al
 a95:	0f 94 c0             	sete   %al
    buf[i++] = c;
 a98:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 a9a:	08 c2                	or     %al,%dl
 a9c:	74 ca                	je     a68 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 a9e:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 aa2:	89 f8                	mov    %edi,%eax
 aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
 aa7:	5b                   	pop    %ebx
 aa8:	5e                   	pop    %esi
 aa9:	5f                   	pop    %edi
 aaa:	5d                   	pop    %ebp
 aab:	c3                   	ret    

00000aac <stat>:

int
stat(const char *n, struct stat *st)
{
 aac:	55                   	push   %ebp
 aad:	89 e5                	mov    %esp,%ebp
 aaf:	56                   	push   %esi
 ab0:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 ab1:	83 ec 08             	sub    $0x8,%esp
 ab4:	6a 00                	push   $0x0
 ab6:	ff 75 08             	pushl  0x8(%ebp)
 ab9:	e8 d0 00 00 00       	call   b8e <open>
  if(fd < 0)
 abe:	83 c4 10             	add    $0x10,%esp
 ac1:	85 c0                	test   %eax,%eax
 ac3:	78 24                	js     ae9 <stat+0x3d>
 ac5:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 ac7:	83 ec 08             	sub    $0x8,%esp
 aca:	ff 75 0c             	pushl  0xc(%ebp)
 acd:	50                   	push   %eax
 ace:	e8 d3 00 00 00       	call   ba6 <fstat>
 ad3:	89 c6                	mov    %eax,%esi
  close(fd);
 ad5:	89 1c 24             	mov    %ebx,(%esp)
 ad8:	e8 99 00 00 00       	call   b76 <close>
  return r;
 add:	83 c4 10             	add    $0x10,%esp
}
 ae0:	89 f0                	mov    %esi,%eax
 ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
 ae5:	5b                   	pop    %ebx
 ae6:	5e                   	pop    %esi
 ae7:	5d                   	pop    %ebp
 ae8:	c3                   	ret    
    return -1;
 ae9:	be ff ff ff ff       	mov    $0xffffffff,%esi
 aee:	eb f0                	jmp    ae0 <stat+0x34>

00000af0 <atoi>:

int
atoi(const char *s)
{
 af0:	55                   	push   %ebp
 af1:	89 e5                	mov    %esp,%ebp
 af3:	53                   	push   %ebx
 af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 af7:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 afc:	eb 10                	jmp    b0e <atoi+0x1e>
    n = n*10 + *s++ - '0';
 afe:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 b01:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 b04:	83 c1 01             	add    $0x1,%ecx
 b07:	0f be d2             	movsbl %dl,%edx
 b0a:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 b0e:	0f b6 11             	movzbl (%ecx),%edx
 b11:	8d 5a d0             	lea    -0x30(%edx),%ebx
 b14:	80 fb 09             	cmp    $0x9,%bl
 b17:	76 e5                	jbe    afe <atoi+0xe>
  return n;
}
 b19:	5b                   	pop    %ebx
 b1a:	5d                   	pop    %ebp
 b1b:	c3                   	ret    

00000b1c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 b1c:	55                   	push   %ebp
 b1d:	89 e5                	mov    %esp,%ebp
 b1f:	56                   	push   %esi
 b20:	53                   	push   %ebx
 b21:	8b 45 08             	mov    0x8(%ebp),%eax
 b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 b27:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 b2a:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 b2c:	eb 0d                	jmp    b3b <memmove+0x1f>
    *dst++ = *src++;
 b2e:	0f b6 13             	movzbl (%ebx),%edx
 b31:	88 11                	mov    %dl,(%ecx)
 b33:	8d 5b 01             	lea    0x1(%ebx),%ebx
 b36:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 b39:	89 f2                	mov    %esi,%edx
 b3b:	8d 72 ff             	lea    -0x1(%edx),%esi
 b3e:	85 d2                	test   %edx,%edx
 b40:	7f ec                	jg     b2e <memmove+0x12>
  return vdst;
}
 b42:	5b                   	pop    %ebx
 b43:	5e                   	pop    %esi
 b44:	5d                   	pop    %ebp
 b45:	c3                   	ret    

00000b46 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 b46:	b8 01 00 00 00       	mov    $0x1,%eax
 b4b:	cd 40                	int    $0x40
 b4d:	c3                   	ret    

00000b4e <exit>:
SYSCALL(exit)
 b4e:	b8 02 00 00 00       	mov    $0x2,%eax
 b53:	cd 40                	int    $0x40
 b55:	c3                   	ret    

00000b56 <wait>:
SYSCALL(wait)
 b56:	b8 03 00 00 00       	mov    $0x3,%eax
 b5b:	cd 40                	int    $0x40
 b5d:	c3                   	ret    

00000b5e <pipe>:
SYSCALL(pipe)
 b5e:	b8 04 00 00 00       	mov    $0x4,%eax
 b63:	cd 40                	int    $0x40
 b65:	c3                   	ret    

00000b66 <read>:
SYSCALL(read)
 b66:	b8 05 00 00 00       	mov    $0x5,%eax
 b6b:	cd 40                	int    $0x40
 b6d:	c3                   	ret    

00000b6e <write>:
SYSCALL(write)
 b6e:	b8 10 00 00 00       	mov    $0x10,%eax
 b73:	cd 40                	int    $0x40
 b75:	c3                   	ret    

00000b76 <close>:
SYSCALL(close)
 b76:	b8 15 00 00 00       	mov    $0x15,%eax
 b7b:	cd 40                	int    $0x40
 b7d:	c3                   	ret    

00000b7e <kill>:
SYSCALL(kill)
 b7e:	b8 06 00 00 00       	mov    $0x6,%eax
 b83:	cd 40                	int    $0x40
 b85:	c3                   	ret    

00000b86 <exec>:
SYSCALL(exec)
 b86:	b8 07 00 00 00       	mov    $0x7,%eax
 b8b:	cd 40                	int    $0x40
 b8d:	c3                   	ret    

00000b8e <open>:
SYSCALL(open)
 b8e:	b8 0f 00 00 00       	mov    $0xf,%eax
 b93:	cd 40                	int    $0x40
 b95:	c3                   	ret    

00000b96 <mknod>:
SYSCALL(mknod)
 b96:	b8 11 00 00 00       	mov    $0x11,%eax
 b9b:	cd 40                	int    $0x40
 b9d:	c3                   	ret    

00000b9e <unlink>:
SYSCALL(unlink)
 b9e:	b8 12 00 00 00       	mov    $0x12,%eax
 ba3:	cd 40                	int    $0x40
 ba5:	c3                   	ret    

00000ba6 <fstat>:
SYSCALL(fstat)
 ba6:	b8 08 00 00 00       	mov    $0x8,%eax
 bab:	cd 40                	int    $0x40
 bad:	c3                   	ret    

00000bae <link>:
SYSCALL(link)
 bae:	b8 13 00 00 00       	mov    $0x13,%eax
 bb3:	cd 40                	int    $0x40
 bb5:	c3                   	ret    

00000bb6 <mkdir>:
SYSCALL(mkdir)
 bb6:	b8 14 00 00 00       	mov    $0x14,%eax
 bbb:	cd 40                	int    $0x40
 bbd:	c3                   	ret    

00000bbe <chdir>:
SYSCALL(chdir)
 bbe:	b8 09 00 00 00       	mov    $0x9,%eax
 bc3:	cd 40                	int    $0x40
 bc5:	c3                   	ret    

00000bc6 <dup>:
SYSCALL(dup)
 bc6:	b8 0a 00 00 00       	mov    $0xa,%eax
 bcb:	cd 40                	int    $0x40
 bcd:	c3                   	ret    

00000bce <getpid>:
SYSCALL(getpid)
 bce:	b8 0b 00 00 00       	mov    $0xb,%eax
 bd3:	cd 40                	int    $0x40
 bd5:	c3                   	ret    

00000bd6 <sbrk>:
SYSCALL(sbrk)
 bd6:	b8 0c 00 00 00       	mov    $0xc,%eax
 bdb:	cd 40                	int    $0x40
 bdd:	c3                   	ret    

00000bde <sleep>:
SYSCALL(sleep)
 bde:	b8 0d 00 00 00       	mov    $0xd,%eax
 be3:	cd 40                	int    $0x40
 be5:	c3                   	ret    

00000be6 <uptime>:
SYSCALL(uptime)
 be6:	b8 0e 00 00 00       	mov    $0xe,%eax
 beb:	cd 40                	int    $0x40
 bed:	c3                   	ret    

00000bee <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 bee:	55                   	push   %ebp
 bef:	89 e5                	mov    %esp,%ebp
 bf1:	83 ec 1c             	sub    $0x1c,%esp
 bf4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 bf7:	6a 01                	push   $0x1
 bf9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 bfc:	52                   	push   %edx
 bfd:	50                   	push   %eax
 bfe:	e8 6b ff ff ff       	call   b6e <write>
}
 c03:	83 c4 10             	add    $0x10,%esp
 c06:	c9                   	leave  
 c07:	c3                   	ret    

00000c08 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 c08:	55                   	push   %ebp
 c09:	89 e5                	mov    %esp,%ebp
 c0b:	57                   	push   %edi
 c0c:	56                   	push   %esi
 c0d:	53                   	push   %ebx
 c0e:	83 ec 2c             	sub    $0x2c,%esp
 c11:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 c13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 c17:	0f 95 c3             	setne  %bl
 c1a:	89 d0                	mov    %edx,%eax
 c1c:	c1 e8 1f             	shr    $0x1f,%eax
 c1f:	84 c3                	test   %al,%bl
 c21:	74 10                	je     c33 <printint+0x2b>
    neg = 1;
    x = -xx;
 c23:	f7 da                	neg    %edx
    neg = 1;
 c25:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 c2c:	be 00 00 00 00       	mov    $0x0,%esi
 c31:	eb 0b                	jmp    c3e <printint+0x36>
  neg = 0;
 c33:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 c3a:	eb f0                	jmp    c2c <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 c3c:	89 c6                	mov    %eax,%esi
 c3e:	89 d0                	mov    %edx,%eax
 c40:	ba 00 00 00 00       	mov    $0x0,%edx
 c45:	f7 f1                	div    %ecx
 c47:	89 c3                	mov    %eax,%ebx
 c49:	8d 46 01             	lea    0x1(%esi),%eax
 c4c:	0f b6 92 30 10 00 00 	movzbl 0x1030(%edx),%edx
 c53:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 c57:	89 da                	mov    %ebx,%edx
 c59:	85 db                	test   %ebx,%ebx
 c5b:	75 df                	jne    c3c <printint+0x34>
 c5d:	89 c3                	mov    %eax,%ebx
  if(neg)
 c5f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 c63:	74 16                	je     c7b <printint+0x73>
    buf[i++] = '-';
 c65:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 c6a:	8d 5e 02             	lea    0x2(%esi),%ebx
 c6d:	eb 0c                	jmp    c7b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 c6f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 c74:	89 f8                	mov    %edi,%eax
 c76:	e8 73 ff ff ff       	call   bee <putc>
  while(--i >= 0)
 c7b:	83 eb 01             	sub    $0x1,%ebx
 c7e:	79 ef                	jns    c6f <printint+0x67>
}
 c80:	83 c4 2c             	add    $0x2c,%esp
 c83:	5b                   	pop    %ebx
 c84:	5e                   	pop    %esi
 c85:	5f                   	pop    %edi
 c86:	5d                   	pop    %ebp
 c87:	c3                   	ret    

00000c88 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 c88:	55                   	push   %ebp
 c89:	89 e5                	mov    %esp,%ebp
 c8b:	57                   	push   %edi
 c8c:	56                   	push   %esi
 c8d:	53                   	push   %ebx
 c8e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 c91:	8d 45 10             	lea    0x10(%ebp),%eax
 c94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 c97:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
 ca1:	eb 14                	jmp    cb7 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 ca3:	89 fa                	mov    %edi,%edx
 ca5:	8b 45 08             	mov    0x8(%ebp),%eax
 ca8:	e8 41 ff ff ff       	call   bee <putc>
 cad:	eb 05                	jmp    cb4 <printf+0x2c>
      }
    } else if(state == '%'){
 caf:	83 fe 25             	cmp    $0x25,%esi
 cb2:	74 25                	je     cd9 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 cb4:	83 c3 01             	add    $0x1,%ebx
 cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
 cba:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 cbe:	84 c0                	test   %al,%al
 cc0:	0f 84 23 01 00 00    	je     de9 <printf+0x161>
    c = fmt[i] & 0xff;
 cc6:	0f be f8             	movsbl %al,%edi
 cc9:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 ccc:	85 f6                	test   %esi,%esi
 cce:	75 df                	jne    caf <printf+0x27>
      if(c == '%'){
 cd0:	83 f8 25             	cmp    $0x25,%eax
 cd3:	75 ce                	jne    ca3 <printf+0x1b>
        state = '%';
 cd5:	89 c6                	mov    %eax,%esi
 cd7:	eb db                	jmp    cb4 <printf+0x2c>
      if(c == 'd'){
 cd9:	83 f8 64             	cmp    $0x64,%eax
 cdc:	74 49                	je     d27 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 cde:	83 f8 78             	cmp    $0x78,%eax
 ce1:	0f 94 c1             	sete   %cl
 ce4:	83 f8 70             	cmp    $0x70,%eax
 ce7:	0f 94 c2             	sete   %dl
 cea:	08 d1                	or     %dl,%cl
 cec:	75 63                	jne    d51 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 cee:	83 f8 73             	cmp    $0x73,%eax
 cf1:	0f 84 84 00 00 00    	je     d7b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 cf7:	83 f8 63             	cmp    $0x63,%eax
 cfa:	0f 84 b7 00 00 00    	je     db7 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 d00:	83 f8 25             	cmp    $0x25,%eax
 d03:	0f 84 cc 00 00 00    	je     dd5 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 d09:	ba 25 00 00 00       	mov    $0x25,%edx
 d0e:	8b 45 08             	mov    0x8(%ebp),%eax
 d11:	e8 d8 fe ff ff       	call   bee <putc>
        putc(fd, c);
 d16:	89 fa                	mov    %edi,%edx
 d18:	8b 45 08             	mov    0x8(%ebp),%eax
 d1b:	e8 ce fe ff ff       	call   bee <putc>
      }
      state = 0;
 d20:	be 00 00 00 00       	mov    $0x0,%esi
 d25:	eb 8d                	jmp    cb4 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 d27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 d2a:	8b 17                	mov    (%edi),%edx
 d2c:	83 ec 0c             	sub    $0xc,%esp
 d2f:	6a 01                	push   $0x1
 d31:	b9 0a 00 00 00       	mov    $0xa,%ecx
 d36:	8b 45 08             	mov    0x8(%ebp),%eax
 d39:	e8 ca fe ff ff       	call   c08 <printint>
        ap++;
 d3e:	83 c7 04             	add    $0x4,%edi
 d41:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 d44:	83 c4 10             	add    $0x10,%esp
      state = 0;
 d47:	be 00 00 00 00       	mov    $0x0,%esi
 d4c:	e9 63 ff ff ff       	jmp    cb4 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 d51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 d54:	8b 17                	mov    (%edi),%edx
 d56:	83 ec 0c             	sub    $0xc,%esp
 d59:	6a 00                	push   $0x0
 d5b:	b9 10 00 00 00       	mov    $0x10,%ecx
 d60:	8b 45 08             	mov    0x8(%ebp),%eax
 d63:	e8 a0 fe ff ff       	call   c08 <printint>
        ap++;
 d68:	83 c7 04             	add    $0x4,%edi
 d6b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 d6e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 d71:	be 00 00 00 00       	mov    $0x0,%esi
 d76:	e9 39 ff ff ff       	jmp    cb4 <printf+0x2c>
        s = (char*)*ap;
 d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 d7e:	8b 30                	mov    (%eax),%esi
        ap++;
 d80:	83 c0 04             	add    $0x4,%eax
 d83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 d86:	85 f6                	test   %esi,%esi
 d88:	75 28                	jne    db2 <printf+0x12a>
          s = "(null)";
 d8a:	be 28 10 00 00       	mov    $0x1028,%esi
 d8f:	8b 7d 08             	mov    0x8(%ebp),%edi
 d92:	eb 0d                	jmp    da1 <printf+0x119>
          putc(fd, *s);
 d94:	0f be d2             	movsbl %dl,%edx
 d97:	89 f8                	mov    %edi,%eax
 d99:	e8 50 fe ff ff       	call   bee <putc>
          s++;
 d9e:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 da1:	0f b6 16             	movzbl (%esi),%edx
 da4:	84 d2                	test   %dl,%dl
 da6:	75 ec                	jne    d94 <printf+0x10c>
      state = 0;
 da8:	be 00 00 00 00       	mov    $0x0,%esi
 dad:	e9 02 ff ff ff       	jmp    cb4 <printf+0x2c>
 db2:	8b 7d 08             	mov    0x8(%ebp),%edi
 db5:	eb ea                	jmp    da1 <printf+0x119>
        putc(fd, *ap);
 db7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 dba:	0f be 17             	movsbl (%edi),%edx
 dbd:	8b 45 08             	mov    0x8(%ebp),%eax
 dc0:	e8 29 fe ff ff       	call   bee <putc>
        ap++;
 dc5:	83 c7 04             	add    $0x4,%edi
 dc8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 dcb:	be 00 00 00 00       	mov    $0x0,%esi
 dd0:	e9 df fe ff ff       	jmp    cb4 <printf+0x2c>
        putc(fd, c);
 dd5:	89 fa                	mov    %edi,%edx
 dd7:	8b 45 08             	mov    0x8(%ebp),%eax
 dda:	e8 0f fe ff ff       	call   bee <putc>
      state = 0;
 ddf:	be 00 00 00 00       	mov    $0x0,%esi
 de4:	e9 cb fe ff ff       	jmp    cb4 <printf+0x2c>
    }
  }
}
 de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 dec:	5b                   	pop    %ebx
 ded:	5e                   	pop    %esi
 dee:	5f                   	pop    %edi
 def:	5d                   	pop    %ebp
 df0:	c3                   	ret    

00000df1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 df1:	55                   	push   %ebp
 df2:	89 e5                	mov    %esp,%ebp
 df4:	57                   	push   %edi
 df5:	56                   	push   %esi
 df6:	53                   	push   %ebx
 df7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 dfa:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dfd:	a1 24 16 00 00       	mov    0x1624,%eax
 e02:	eb 02                	jmp    e06 <free+0x15>
 e04:	89 d0                	mov    %edx,%eax
 e06:	39 c8                	cmp    %ecx,%eax
 e08:	73 04                	jae    e0e <free+0x1d>
 e0a:	39 08                	cmp    %ecx,(%eax)
 e0c:	77 12                	ja     e20 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e0e:	8b 10                	mov    (%eax),%edx
 e10:	39 c2                	cmp    %eax,%edx
 e12:	77 f0                	ja     e04 <free+0x13>
 e14:	39 c8                	cmp    %ecx,%eax
 e16:	72 08                	jb     e20 <free+0x2f>
 e18:	39 ca                	cmp    %ecx,%edx
 e1a:	77 04                	ja     e20 <free+0x2f>
 e1c:	89 d0                	mov    %edx,%eax
 e1e:	eb e6                	jmp    e06 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 e20:	8b 73 fc             	mov    -0x4(%ebx),%esi
 e23:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 e26:	8b 10                	mov    (%eax),%edx
 e28:	39 d7                	cmp    %edx,%edi
 e2a:	74 19                	je     e45 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 e2c:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 e2f:	8b 50 04             	mov    0x4(%eax),%edx
 e32:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 e35:	39 ce                	cmp    %ecx,%esi
 e37:	74 1b                	je     e54 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 e39:	89 08                	mov    %ecx,(%eax)
  freep = p;
 e3b:	a3 24 16 00 00       	mov    %eax,0x1624
}
 e40:	5b                   	pop    %ebx
 e41:	5e                   	pop    %esi
 e42:	5f                   	pop    %edi
 e43:	5d                   	pop    %ebp
 e44:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 e45:	03 72 04             	add    0x4(%edx),%esi
 e48:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 e4b:	8b 10                	mov    (%eax),%edx
 e4d:	8b 12                	mov    (%edx),%edx
 e4f:	89 53 f8             	mov    %edx,-0x8(%ebx)
 e52:	eb db                	jmp    e2f <free+0x3e>
    p->s.size += bp->s.size;
 e54:	03 53 fc             	add    -0x4(%ebx),%edx
 e57:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 e5a:	8b 53 f8             	mov    -0x8(%ebx),%edx
 e5d:	89 10                	mov    %edx,(%eax)
 e5f:	eb da                	jmp    e3b <free+0x4a>

00000e61 <morecore>:

static Header*
morecore(uint nu)
{
 e61:	55                   	push   %ebp
 e62:	89 e5                	mov    %esp,%ebp
 e64:	53                   	push   %ebx
 e65:	83 ec 04             	sub    $0x4,%esp
 e68:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 e6a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 e6f:	77 05                	ja     e76 <morecore+0x15>
    nu = 4096;
 e71:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 e76:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 e7d:	83 ec 0c             	sub    $0xc,%esp
 e80:	50                   	push   %eax
 e81:	e8 50 fd ff ff       	call   bd6 <sbrk>
  if(p == (char*)-1)
 e86:	83 c4 10             	add    $0x10,%esp
 e89:	83 f8 ff             	cmp    $0xffffffff,%eax
 e8c:	74 1c                	je     eaa <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 e8e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 e91:	83 c0 08             	add    $0x8,%eax
 e94:	83 ec 0c             	sub    $0xc,%esp
 e97:	50                   	push   %eax
 e98:	e8 54 ff ff ff       	call   df1 <free>
  return freep;
 e9d:	a1 24 16 00 00       	mov    0x1624,%eax
 ea2:	83 c4 10             	add    $0x10,%esp
}
 ea5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 ea8:	c9                   	leave  
 ea9:	c3                   	ret    
    return 0;
 eaa:	b8 00 00 00 00       	mov    $0x0,%eax
 eaf:	eb f4                	jmp    ea5 <morecore+0x44>

00000eb1 <malloc>:

void*
malloc(uint nbytes)
{
 eb1:	55                   	push   %ebp
 eb2:	89 e5                	mov    %esp,%ebp
 eb4:	53                   	push   %ebx
 eb5:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 eb8:	8b 45 08             	mov    0x8(%ebp),%eax
 ebb:	8d 58 07             	lea    0x7(%eax),%ebx
 ebe:	c1 eb 03             	shr    $0x3,%ebx
 ec1:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 ec4:	8b 0d 24 16 00 00    	mov    0x1624,%ecx
 eca:	85 c9                	test   %ecx,%ecx
 ecc:	74 04                	je     ed2 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ece:	8b 01                	mov    (%ecx),%eax
 ed0:	eb 4d                	jmp    f1f <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 ed2:	c7 05 24 16 00 00 28 	movl   $0x1628,0x1624
 ed9:	16 00 00 
 edc:	c7 05 28 16 00 00 28 	movl   $0x1628,0x1628
 ee3:	16 00 00 
    base.s.size = 0;
 ee6:	c7 05 2c 16 00 00 00 	movl   $0x0,0x162c
 eed:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 ef0:	b9 28 16 00 00       	mov    $0x1628,%ecx
 ef5:	eb d7                	jmp    ece <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 ef7:	39 da                	cmp    %ebx,%edx
 ef9:	74 1a                	je     f15 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 efb:	29 da                	sub    %ebx,%edx
 efd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 f00:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 f03:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 f06:	89 0d 24 16 00 00    	mov    %ecx,0x1624
      return (void*)(p + 1);
 f0c:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f0f:	83 c4 04             	add    $0x4,%esp
 f12:	5b                   	pop    %ebx
 f13:	5d                   	pop    %ebp
 f14:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 f15:	8b 10                	mov    (%eax),%edx
 f17:	89 11                	mov    %edx,(%ecx)
 f19:	eb eb                	jmp    f06 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f1b:	89 c1                	mov    %eax,%ecx
 f1d:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 f1f:	8b 50 04             	mov    0x4(%eax),%edx
 f22:	39 da                	cmp    %ebx,%edx
 f24:	73 d1                	jae    ef7 <malloc+0x46>
    if(p == freep)
 f26:	39 05 24 16 00 00    	cmp    %eax,0x1624
 f2c:	75 ed                	jne    f1b <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 f2e:	89 d8                	mov    %ebx,%eax
 f30:	e8 2c ff ff ff       	call   e61 <morecore>
 f35:	85 c0                	test   %eax,%eax
 f37:	75 e2                	jne    f1b <malloc+0x6a>
        return 0;
 f39:	b8 00 00 00 00       	mov    $0x0,%eax
 f3e:	eb cf                	jmp    f0f <malloc+0x5e>
