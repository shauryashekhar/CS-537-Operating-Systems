
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 10             	sub    $0x10,%esp
  printf(stdout, "iput test\n");
       6:	68 a8 3b 00 00       	push   $0x3ba8
       b:	ff 35 54 5b 00 00    	pushl  0x5b54
      11:	e8 44 38 00 00       	call   385a <printf>

  if(mkdir("iputdir") < 0){
      16:	c7 04 24 3b 3b 00 00 	movl   $0x3b3b,(%esp)
      1d:	e8 66 37 00 00       	call   3788 <mkdir>
      22:	83 c4 10             	add    $0x10,%esp
      25:	85 c0                	test   %eax,%eax
      27:	78 54                	js     7d <iputtest+0x7d>
    printf(stdout, "mkdir failed\n");
    exit();
  }
  if(chdir("iputdir") < 0){
      29:	83 ec 0c             	sub    $0xc,%esp
      2c:	68 3b 3b 00 00       	push   $0x3b3b
      31:	e8 5a 37 00 00       	call   3790 <chdir>
      36:	83 c4 10             	add    $0x10,%esp
      39:	85 c0                	test   %eax,%eax
      3b:	78 58                	js     95 <iputtest+0x95>
    printf(stdout, "chdir iputdir failed\n");
    exit();
  }
  if(unlink("../iputdir") < 0){
      3d:	83 ec 0c             	sub    $0xc,%esp
      40:	68 38 3b 00 00       	push   $0x3b38
      45:	e8 26 37 00 00       	call   3770 <unlink>
      4a:	83 c4 10             	add    $0x10,%esp
      4d:	85 c0                	test   %eax,%eax
      4f:	78 5c                	js     ad <iputtest+0xad>
    printf(stdout, "unlink ../iputdir failed\n");
    exit();
  }
  if(chdir("/") < 0){
      51:	83 ec 0c             	sub    $0xc,%esp
      54:	68 5d 3b 00 00       	push   $0x3b5d
      59:	e8 32 37 00 00       	call   3790 <chdir>
      5e:	83 c4 10             	add    $0x10,%esp
      61:	85 c0                	test   %eax,%eax
      63:	78 60                	js     c5 <iputtest+0xc5>
    printf(stdout, "chdir / failed\n");
    exit();
  }
  printf(stdout, "iput test ok\n");
      65:	83 ec 08             	sub    $0x8,%esp
      68:	68 e0 3b 00 00       	push   $0x3be0
      6d:	ff 35 54 5b 00 00    	pushl  0x5b54
      73:	e8 e2 37 00 00       	call   385a <printf>
}
      78:	83 c4 10             	add    $0x10,%esp
      7b:	c9                   	leave  
      7c:	c3                   	ret    
    printf(stdout, "mkdir failed\n");
      7d:	83 ec 08             	sub    $0x8,%esp
      80:	68 14 3b 00 00       	push   $0x3b14
      85:	ff 35 54 5b 00 00    	pushl  0x5b54
      8b:	e8 ca 37 00 00       	call   385a <printf>
    exit();
      90:	e8 8b 36 00 00       	call   3720 <exit>
    printf(stdout, "chdir iputdir failed\n");
      95:	83 ec 08             	sub    $0x8,%esp
      98:	68 22 3b 00 00       	push   $0x3b22
      9d:	ff 35 54 5b 00 00    	pushl  0x5b54
      a3:	e8 b2 37 00 00       	call   385a <printf>
    exit();
      a8:	e8 73 36 00 00       	call   3720 <exit>
    printf(stdout, "unlink ../iputdir failed\n");
      ad:	83 ec 08             	sub    $0x8,%esp
      b0:	68 43 3b 00 00       	push   $0x3b43
      b5:	ff 35 54 5b 00 00    	pushl  0x5b54
      bb:	e8 9a 37 00 00       	call   385a <printf>
    exit();
      c0:	e8 5b 36 00 00       	call   3720 <exit>
    printf(stdout, "chdir / failed\n");
      c5:	83 ec 08             	sub    $0x8,%esp
      c8:	68 5f 3b 00 00       	push   $0x3b5f
      cd:	ff 35 54 5b 00 00    	pushl  0x5b54
      d3:	e8 82 37 00 00       	call   385a <printf>
    exit();
      d8:	e8 43 36 00 00       	call   3720 <exit>

000000dd <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      dd:	55                   	push   %ebp
      de:	89 e5                	mov    %esp,%ebp
      e0:	83 ec 10             	sub    $0x10,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e3:	68 6f 3b 00 00       	push   $0x3b6f
      e8:	ff 35 54 5b 00 00    	pushl  0x5b54
      ee:	e8 67 37 00 00       	call   385a <printf>

  pid = fork();
      f3:	e8 20 36 00 00       	call   3718 <fork>
  if(pid < 0){
      f8:	83 c4 10             	add    $0x10,%esp
      fb:	85 c0                	test   %eax,%eax
      fd:	78 49                	js     148 <exitiputtest+0x6b>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
      ff:	85 c0                	test   %eax,%eax
     101:	0f 85 a1 00 00 00    	jne    1a8 <exitiputtest+0xcb>
    if(mkdir("iputdir") < 0){
     107:	83 ec 0c             	sub    $0xc,%esp
     10a:	68 3b 3b 00 00       	push   $0x3b3b
     10f:	e8 74 36 00 00       	call   3788 <mkdir>
     114:	83 c4 10             	add    $0x10,%esp
     117:	85 c0                	test   %eax,%eax
     119:	78 45                	js     160 <exitiputtest+0x83>
      printf(stdout, "mkdir failed\n");
      exit();
    }
    if(chdir("iputdir") < 0){
     11b:	83 ec 0c             	sub    $0xc,%esp
     11e:	68 3b 3b 00 00       	push   $0x3b3b
     123:	e8 68 36 00 00       	call   3790 <chdir>
     128:	83 c4 10             	add    $0x10,%esp
     12b:	85 c0                	test   %eax,%eax
     12d:	78 49                	js     178 <exitiputtest+0x9b>
      printf(stdout, "child chdir failed\n");
      exit();
    }
    if(unlink("../iputdir") < 0){
     12f:	83 ec 0c             	sub    $0xc,%esp
     132:	68 38 3b 00 00       	push   $0x3b38
     137:	e8 34 36 00 00       	call   3770 <unlink>
     13c:	83 c4 10             	add    $0x10,%esp
     13f:	85 c0                	test   %eax,%eax
     141:	78 4d                	js     190 <exitiputtest+0xb3>
      printf(stdout, "unlink ../iputdir failed\n");
      exit();
    }
    exit();
     143:	e8 d8 35 00 00       	call   3720 <exit>
    printf(stdout, "fork failed\n");
     148:	83 ec 08             	sub    $0x8,%esp
     14b:	68 55 4a 00 00       	push   $0x4a55
     150:	ff 35 54 5b 00 00    	pushl  0x5b54
     156:	e8 ff 36 00 00       	call   385a <printf>
    exit();
     15b:	e8 c0 35 00 00       	call   3720 <exit>
      printf(stdout, "mkdir failed\n");
     160:	83 ec 08             	sub    $0x8,%esp
     163:	68 14 3b 00 00       	push   $0x3b14
     168:	ff 35 54 5b 00 00    	pushl  0x5b54
     16e:	e8 e7 36 00 00       	call   385a <printf>
      exit();
     173:	e8 a8 35 00 00       	call   3720 <exit>
      printf(stdout, "child chdir failed\n");
     178:	83 ec 08             	sub    $0x8,%esp
     17b:	68 7e 3b 00 00       	push   $0x3b7e
     180:	ff 35 54 5b 00 00    	pushl  0x5b54
     186:	e8 cf 36 00 00       	call   385a <printf>
      exit();
     18b:	e8 90 35 00 00       	call   3720 <exit>
      printf(stdout, "unlink ../iputdir failed\n");
     190:	83 ec 08             	sub    $0x8,%esp
     193:	68 43 3b 00 00       	push   $0x3b43
     198:	ff 35 54 5b 00 00    	pushl  0x5b54
     19e:	e8 b7 36 00 00       	call   385a <printf>
      exit();
     1a3:	e8 78 35 00 00       	call   3720 <exit>
  }
  wait();
     1a8:	e8 7b 35 00 00       	call   3728 <wait>
  printf(stdout, "exitiput test ok\n");
     1ad:	83 ec 08             	sub    $0x8,%esp
     1b0:	68 92 3b 00 00       	push   $0x3b92
     1b5:	ff 35 54 5b 00 00    	pushl  0x5b54
     1bb:	e8 9a 36 00 00       	call   385a <printf>
}
     1c0:	83 c4 10             	add    $0x10,%esp
     1c3:	c9                   	leave  
     1c4:	c3                   	ret    

000001c5 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1c5:	55                   	push   %ebp
     1c6:	89 e5                	mov    %esp,%ebp
     1c8:	83 ec 10             	sub    $0x10,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1cb:	68 a4 3b 00 00       	push   $0x3ba4
     1d0:	ff 35 54 5b 00 00    	pushl  0x5b54
     1d6:	e8 7f 36 00 00       	call   385a <printf>
  if(mkdir("oidir") < 0){
     1db:	c7 04 24 b3 3b 00 00 	movl   $0x3bb3,(%esp)
     1e2:	e8 a1 35 00 00       	call   3788 <mkdir>
     1e7:	83 c4 10             	add    $0x10,%esp
     1ea:	85 c0                	test   %eax,%eax
     1ec:	78 3b                	js     229 <openiputtest+0x64>
    printf(stdout, "mkdir oidir failed\n");
    exit();
  }
  pid = fork();
     1ee:	e8 25 35 00 00       	call   3718 <fork>
  if(pid < 0){
     1f3:	85 c0                	test   %eax,%eax
     1f5:	78 4a                	js     241 <openiputtest+0x7c>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
     1f7:	85 c0                	test   %eax,%eax
     1f9:	75 63                	jne    25e <openiputtest+0x99>
    int fd = open("oidir", O_RDWR);
     1fb:	83 ec 08             	sub    $0x8,%esp
     1fe:	6a 02                	push   $0x2
     200:	68 b3 3b 00 00       	push   $0x3bb3
     205:	e8 56 35 00 00       	call   3760 <open>
    if(fd >= 0){
     20a:	83 c4 10             	add    $0x10,%esp
     20d:	85 c0                	test   %eax,%eax
     20f:	78 48                	js     259 <openiputtest+0x94>
      printf(stdout, "open directory for write succeeded\n");
     211:	83 ec 08             	sub    $0x8,%esp
     214:	68 38 4b 00 00       	push   $0x4b38
     219:	ff 35 54 5b 00 00    	pushl  0x5b54
     21f:	e8 36 36 00 00       	call   385a <printf>
      exit();
     224:	e8 f7 34 00 00       	call   3720 <exit>
    printf(stdout, "mkdir oidir failed\n");
     229:	83 ec 08             	sub    $0x8,%esp
     22c:	68 b9 3b 00 00       	push   $0x3bb9
     231:	ff 35 54 5b 00 00    	pushl  0x5b54
     237:	e8 1e 36 00 00       	call   385a <printf>
    exit();
     23c:	e8 df 34 00 00       	call   3720 <exit>
    printf(stdout, "fork failed\n");
     241:	83 ec 08             	sub    $0x8,%esp
     244:	68 55 4a 00 00       	push   $0x4a55
     249:	ff 35 54 5b 00 00    	pushl  0x5b54
     24f:	e8 06 36 00 00       	call   385a <printf>
    exit();
     254:	e8 c7 34 00 00       	call   3720 <exit>
    }
    exit();
     259:	e8 c2 34 00 00       	call   3720 <exit>
  }
  sleep(1);
     25e:	83 ec 0c             	sub    $0xc,%esp
     261:	6a 01                	push   $0x1
     263:	e8 48 35 00 00       	call   37b0 <sleep>
  if(unlink("oidir") != 0){
     268:	c7 04 24 b3 3b 00 00 	movl   $0x3bb3,(%esp)
     26f:	e8 fc 34 00 00       	call   3770 <unlink>
     274:	83 c4 10             	add    $0x10,%esp
     277:	85 c0                	test   %eax,%eax
     279:	75 1d                	jne    298 <openiputtest+0xd3>
    printf(stdout, "unlink failed\n");
    exit();
  }
  wait();
     27b:	e8 a8 34 00 00       	call   3728 <wait>
  printf(stdout, "openiput test ok\n");
     280:	83 ec 08             	sub    $0x8,%esp
     283:	68 dc 3b 00 00       	push   $0x3bdc
     288:	ff 35 54 5b 00 00    	pushl  0x5b54
     28e:	e8 c7 35 00 00       	call   385a <printf>
}
     293:	83 c4 10             	add    $0x10,%esp
     296:	c9                   	leave  
     297:	c3                   	ret    
    printf(stdout, "unlink failed\n");
     298:	83 ec 08             	sub    $0x8,%esp
     29b:	68 cd 3b 00 00       	push   $0x3bcd
     2a0:	ff 35 54 5b 00 00    	pushl  0x5b54
     2a6:	e8 af 35 00 00       	call   385a <printf>
    exit();
     2ab:	e8 70 34 00 00       	call   3720 <exit>

000002b0 <opentest>:

// simple file system tests

void
opentest(void)
{
     2b0:	55                   	push   %ebp
     2b1:	89 e5                	mov    %esp,%ebp
     2b3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  printf(stdout, "open test\n");
     2b6:	68 ee 3b 00 00       	push   $0x3bee
     2bb:	ff 35 54 5b 00 00    	pushl  0x5b54
     2c1:	e8 94 35 00 00       	call   385a <printf>
  fd = open("echo", 0);
     2c6:	83 c4 08             	add    $0x8,%esp
     2c9:	6a 00                	push   $0x0
     2cb:	68 f9 3b 00 00       	push   $0x3bf9
     2d0:	e8 8b 34 00 00       	call   3760 <open>
  if(fd < 0){
     2d5:	83 c4 10             	add    $0x10,%esp
     2d8:	85 c0                	test   %eax,%eax
     2da:	78 37                	js     313 <opentest+0x63>
    printf(stdout, "open echo failed!\n");
    exit();
  }
  close(fd);
     2dc:	83 ec 0c             	sub    $0xc,%esp
     2df:	50                   	push   %eax
     2e0:	e8 63 34 00 00       	call   3748 <close>
  fd = open("doesnotexist", 0);
     2e5:	83 c4 08             	add    $0x8,%esp
     2e8:	6a 00                	push   $0x0
     2ea:	68 11 3c 00 00       	push   $0x3c11
     2ef:	e8 6c 34 00 00       	call   3760 <open>
  if(fd >= 0){
     2f4:	83 c4 10             	add    $0x10,%esp
     2f7:	85 c0                	test   %eax,%eax
     2f9:	79 30                	jns    32b <opentest+0x7b>
    printf(stdout, "open doesnotexist succeeded!\n");
    exit();
  }
  printf(stdout, "open test ok\n");
     2fb:	83 ec 08             	sub    $0x8,%esp
     2fe:	68 3c 3c 00 00       	push   $0x3c3c
     303:	ff 35 54 5b 00 00    	pushl  0x5b54
     309:	e8 4c 35 00 00       	call   385a <printf>
}
     30e:	83 c4 10             	add    $0x10,%esp
     311:	c9                   	leave  
     312:	c3                   	ret    
    printf(stdout, "open echo failed!\n");
     313:	83 ec 08             	sub    $0x8,%esp
     316:	68 fe 3b 00 00       	push   $0x3bfe
     31b:	ff 35 54 5b 00 00    	pushl  0x5b54
     321:	e8 34 35 00 00       	call   385a <printf>
    exit();
     326:	e8 f5 33 00 00       	call   3720 <exit>
    printf(stdout, "open doesnotexist succeeded!\n");
     32b:	83 ec 08             	sub    $0x8,%esp
     32e:	68 1e 3c 00 00       	push   $0x3c1e
     333:	ff 35 54 5b 00 00    	pushl  0x5b54
     339:	e8 1c 35 00 00       	call   385a <printf>
    exit();
     33e:	e8 dd 33 00 00       	call   3720 <exit>

00000343 <writetest>:

void
writetest(void)
{
     343:	55                   	push   %ebp
     344:	89 e5                	mov    %esp,%ebp
     346:	56                   	push   %esi
     347:	53                   	push   %ebx
  int fd;
  int i;

  printf(stdout, "small file test\n");
     348:	83 ec 08             	sub    $0x8,%esp
     34b:	68 4a 3c 00 00       	push   $0x3c4a
     350:	ff 35 54 5b 00 00    	pushl  0x5b54
     356:	e8 ff 34 00 00       	call   385a <printf>
  fd = open("small", O_CREATE|O_RDWR);
     35b:	83 c4 08             	add    $0x8,%esp
     35e:	68 02 02 00 00       	push   $0x202
     363:	68 5b 3c 00 00       	push   $0x3c5b
     368:	e8 f3 33 00 00       	call   3760 <open>
  if(fd >= 0){
     36d:	83 c4 10             	add    $0x10,%esp
     370:	85 c0                	test   %eax,%eax
     372:	78 57                	js     3cb <writetest+0x88>
     374:	89 c6                	mov    %eax,%esi
    printf(stdout, "creat small succeeded; ok\n");
     376:	83 ec 08             	sub    $0x8,%esp
     379:	68 61 3c 00 00       	push   $0x3c61
     37e:	ff 35 54 5b 00 00    	pushl  0x5b54
     384:	e8 d1 34 00 00       	call   385a <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     389:	83 c4 10             	add    $0x10,%esp
     38c:	bb 00 00 00 00       	mov    $0x0,%ebx
     391:	83 fb 63             	cmp    $0x63,%ebx
     394:	7f 7f                	jg     415 <writetest+0xd2>
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     396:	83 ec 04             	sub    $0x4,%esp
     399:	6a 0a                	push   $0xa
     39b:	68 98 3c 00 00       	push   $0x3c98
     3a0:	56                   	push   %esi
     3a1:	e8 9a 33 00 00       	call   3740 <write>
     3a6:	83 c4 10             	add    $0x10,%esp
     3a9:	83 f8 0a             	cmp    $0xa,%eax
     3ac:	75 35                	jne    3e3 <writetest+0xa0>
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     3ae:	83 ec 04             	sub    $0x4,%esp
     3b1:	6a 0a                	push   $0xa
     3b3:	68 a3 3c 00 00       	push   $0x3ca3
     3b8:	56                   	push   %esi
     3b9:	e8 82 33 00 00       	call   3740 <write>
     3be:	83 c4 10             	add    $0x10,%esp
     3c1:	83 f8 0a             	cmp    $0xa,%eax
     3c4:	75 36                	jne    3fc <writetest+0xb9>
  for(i = 0; i < 100; i++){
     3c6:	83 c3 01             	add    $0x1,%ebx
     3c9:	eb c6                	jmp    391 <writetest+0x4e>
    printf(stdout, "error: creat small failed!\n");
     3cb:	83 ec 08             	sub    $0x8,%esp
     3ce:	68 7c 3c 00 00       	push   $0x3c7c
     3d3:	ff 35 54 5b 00 00    	pushl  0x5b54
     3d9:	e8 7c 34 00 00       	call   385a <printf>
    exit();
     3de:	e8 3d 33 00 00       	call   3720 <exit>
      printf(stdout, "error: write aa %d new file failed\n", i);
     3e3:	83 ec 04             	sub    $0x4,%esp
     3e6:	53                   	push   %ebx
     3e7:	68 5c 4b 00 00       	push   $0x4b5c
     3ec:	ff 35 54 5b 00 00    	pushl  0x5b54
     3f2:	e8 63 34 00 00       	call   385a <printf>
      exit();
     3f7:	e8 24 33 00 00       	call   3720 <exit>
      printf(stdout, "error: write bb %d new file failed\n", i);
     3fc:	83 ec 04             	sub    $0x4,%esp
     3ff:	53                   	push   %ebx
     400:	68 80 4b 00 00       	push   $0x4b80
     405:	ff 35 54 5b 00 00    	pushl  0x5b54
     40b:	e8 4a 34 00 00       	call   385a <printf>
      exit();
     410:	e8 0b 33 00 00       	call   3720 <exit>
    }
  }
  printf(stdout, "writes ok\n");
     415:	83 ec 08             	sub    $0x8,%esp
     418:	68 ae 3c 00 00       	push   $0x3cae
     41d:	ff 35 54 5b 00 00    	pushl  0x5b54
     423:	e8 32 34 00 00       	call   385a <printf>
  close(fd);
     428:	89 34 24             	mov    %esi,(%esp)
     42b:	e8 18 33 00 00       	call   3748 <close>
  fd = open("small", O_RDONLY);
     430:	83 c4 08             	add    $0x8,%esp
     433:	6a 00                	push   $0x0
     435:	68 5b 3c 00 00       	push   $0x3c5b
     43a:	e8 21 33 00 00       	call   3760 <open>
     43f:	89 c3                	mov    %eax,%ebx
  if(fd >= 0){
     441:	83 c4 10             	add    $0x10,%esp
     444:	85 c0                	test   %eax,%eax
     446:	78 7b                	js     4c3 <writetest+0x180>
    printf(stdout, "open small succeeded ok\n");
     448:	83 ec 08             	sub    $0x8,%esp
     44b:	68 b9 3c 00 00       	push   $0x3cb9
     450:	ff 35 54 5b 00 00    	pushl  0x5b54
     456:	e8 ff 33 00 00       	call   385a <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     45b:	83 c4 0c             	add    $0xc,%esp
     45e:	68 d0 07 00 00       	push   $0x7d0
     463:	68 40 83 00 00       	push   $0x8340
     468:	53                   	push   %ebx
     469:	e8 ca 32 00 00       	call   3738 <read>
  if(i == 2000){
     46e:	83 c4 10             	add    $0x10,%esp
     471:	3d d0 07 00 00       	cmp    $0x7d0,%eax
     476:	75 63                	jne    4db <writetest+0x198>
    printf(stdout, "read succeeded ok\n");
     478:	83 ec 08             	sub    $0x8,%esp
     47b:	68 ed 3c 00 00       	push   $0x3ced
     480:	ff 35 54 5b 00 00    	pushl  0x5b54
     486:	e8 cf 33 00 00       	call   385a <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     48b:	89 1c 24             	mov    %ebx,(%esp)
     48e:	e8 b5 32 00 00       	call   3748 <close>

  if(unlink("small") < 0){
     493:	c7 04 24 5b 3c 00 00 	movl   $0x3c5b,(%esp)
     49a:	e8 d1 32 00 00       	call   3770 <unlink>
     49f:	83 c4 10             	add    $0x10,%esp
     4a2:	85 c0                	test   %eax,%eax
     4a4:	78 4d                	js     4f3 <writetest+0x1b0>
    printf(stdout, "unlink small failed\n");
    exit();
  }
  printf(stdout, "small file test ok\n");
     4a6:	83 ec 08             	sub    $0x8,%esp
     4a9:	68 15 3d 00 00       	push   $0x3d15
     4ae:	ff 35 54 5b 00 00    	pushl  0x5b54
     4b4:	e8 a1 33 00 00       	call   385a <printf>
}
     4b9:	83 c4 10             	add    $0x10,%esp
     4bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
     4bf:	5b                   	pop    %ebx
     4c0:	5e                   	pop    %esi
     4c1:	5d                   	pop    %ebp
     4c2:	c3                   	ret    
    printf(stdout, "error: open small failed!\n");
     4c3:	83 ec 08             	sub    $0x8,%esp
     4c6:	68 d2 3c 00 00       	push   $0x3cd2
     4cb:	ff 35 54 5b 00 00    	pushl  0x5b54
     4d1:	e8 84 33 00 00       	call   385a <printf>
    exit();
     4d6:	e8 45 32 00 00       	call   3720 <exit>
    printf(stdout, "read failed\n");
     4db:	83 ec 08             	sub    $0x8,%esp
     4de:	68 19 40 00 00       	push   $0x4019
     4e3:	ff 35 54 5b 00 00    	pushl  0x5b54
     4e9:	e8 6c 33 00 00       	call   385a <printf>
    exit();
     4ee:	e8 2d 32 00 00       	call   3720 <exit>
    printf(stdout, "unlink small failed\n");
     4f3:	83 ec 08             	sub    $0x8,%esp
     4f6:	68 00 3d 00 00       	push   $0x3d00
     4fb:	ff 35 54 5b 00 00    	pushl  0x5b54
     501:	e8 54 33 00 00       	call   385a <printf>
    exit();
     506:	e8 15 32 00 00       	call   3720 <exit>

0000050b <writetest1>:

void
writetest1(void)
{
     50b:	55                   	push   %ebp
     50c:	89 e5                	mov    %esp,%ebp
     50e:	56                   	push   %esi
     50f:	53                   	push   %ebx
  int i, fd, n;

  printf(stdout, "big files test\n");
     510:	83 ec 08             	sub    $0x8,%esp
     513:	68 29 3d 00 00       	push   $0x3d29
     518:	ff 35 54 5b 00 00    	pushl  0x5b54
     51e:	e8 37 33 00 00       	call   385a <printf>

  fd = open("big", O_CREATE|O_RDWR);
     523:	83 c4 08             	add    $0x8,%esp
     526:	68 02 02 00 00       	push   $0x202
     52b:	68 a3 3d 00 00       	push   $0x3da3
     530:	e8 2b 32 00 00       	call   3760 <open>
  if(fd < 0){
     535:	83 c4 10             	add    $0x10,%esp
     538:	85 c0                	test   %eax,%eax
     53a:	78 37                	js     573 <writetest1+0x68>
     53c:	89 c6                	mov    %eax,%esi
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     53e:	bb 00 00 00 00       	mov    $0x0,%ebx
     543:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     549:	77 59                	ja     5a4 <writetest1+0x99>
    ((int*)buf)[0] = i;
     54b:	89 1d 40 83 00 00    	mov    %ebx,0x8340
    if(write(fd, buf, 512) != 512){
     551:	83 ec 04             	sub    $0x4,%esp
     554:	68 00 02 00 00       	push   $0x200
     559:	68 40 83 00 00       	push   $0x8340
     55e:	56                   	push   %esi
     55f:	e8 dc 31 00 00       	call   3740 <write>
     564:	83 c4 10             	add    $0x10,%esp
     567:	3d 00 02 00 00       	cmp    $0x200,%eax
     56c:	75 1d                	jne    58b <writetest1+0x80>
  for(i = 0; i < MAXFILE; i++){
     56e:	83 c3 01             	add    $0x1,%ebx
     571:	eb d0                	jmp    543 <writetest1+0x38>
    printf(stdout, "error: creat big failed!\n");
     573:	83 ec 08             	sub    $0x8,%esp
     576:	68 39 3d 00 00       	push   $0x3d39
     57b:	ff 35 54 5b 00 00    	pushl  0x5b54
     581:	e8 d4 32 00 00       	call   385a <printf>
    exit();
     586:	e8 95 31 00 00       	call   3720 <exit>
      printf(stdout, "error: write big file failed\n", i);
     58b:	83 ec 04             	sub    $0x4,%esp
     58e:	53                   	push   %ebx
     58f:	68 53 3d 00 00       	push   $0x3d53
     594:	ff 35 54 5b 00 00    	pushl  0x5b54
     59a:	e8 bb 32 00 00       	call   385a <printf>
      exit();
     59f:	e8 7c 31 00 00       	call   3720 <exit>
    }
  }

  close(fd);
     5a4:	83 ec 0c             	sub    $0xc,%esp
     5a7:	56                   	push   %esi
     5a8:	e8 9b 31 00 00       	call   3748 <close>

  fd = open("big", O_RDONLY);
     5ad:	83 c4 08             	add    $0x8,%esp
     5b0:	6a 00                	push   $0x0
     5b2:	68 a3 3d 00 00       	push   $0x3da3
     5b7:	e8 a4 31 00 00       	call   3760 <open>
     5bc:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     5be:	83 c4 10             	add    $0x10,%esp
     5c1:	85 c0                	test   %eax,%eax
     5c3:	78 3c                	js     601 <writetest1+0xf6>
    printf(stdout, "error: open big failed!\n");
    exit();
  }

  n = 0;
     5c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(;;){
    i = read(fd, buf, 512);
     5ca:	83 ec 04             	sub    $0x4,%esp
     5cd:	68 00 02 00 00       	push   $0x200
     5d2:	68 40 83 00 00       	push   $0x8340
     5d7:	56                   	push   %esi
     5d8:	e8 5b 31 00 00       	call   3738 <read>
    if(i == 0){
     5dd:	83 c4 10             	add    $0x10,%esp
     5e0:	85 c0                	test   %eax,%eax
     5e2:	74 35                	je     619 <writetest1+0x10e>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     5e4:	3d 00 02 00 00       	cmp    $0x200,%eax
     5e9:	0f 85 84 00 00 00    	jne    673 <writetest1+0x168>
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
     5ef:	a1 40 83 00 00       	mov    0x8340,%eax
     5f4:	39 d8                	cmp    %ebx,%eax
     5f6:	0f 85 90 00 00 00    	jne    68c <writetest1+0x181>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
     5fc:	83 c3 01             	add    $0x1,%ebx
    i = read(fd, buf, 512);
     5ff:	eb c9                	jmp    5ca <writetest1+0xbf>
    printf(stdout, "error: open big failed!\n");
     601:	83 ec 08             	sub    $0x8,%esp
     604:	68 71 3d 00 00       	push   $0x3d71
     609:	ff 35 54 5b 00 00    	pushl  0x5b54
     60f:	e8 46 32 00 00       	call   385a <printf>
    exit();
     614:	e8 07 31 00 00       	call   3720 <exit>
      if(n == MAXFILE - 1){
     619:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     61f:	74 39                	je     65a <writetest1+0x14f>
  }
  close(fd);
     621:	83 ec 0c             	sub    $0xc,%esp
     624:	56                   	push   %esi
     625:	e8 1e 31 00 00       	call   3748 <close>
  if(unlink("big") < 0){
     62a:	c7 04 24 a3 3d 00 00 	movl   $0x3da3,(%esp)
     631:	e8 3a 31 00 00       	call   3770 <unlink>
     636:	83 c4 10             	add    $0x10,%esp
     639:	85 c0                	test   %eax,%eax
     63b:	78 66                	js     6a3 <writetest1+0x198>
    printf(stdout, "unlink big failed\n");
    exit();
  }
  printf(stdout, "big files ok\n");
     63d:	83 ec 08             	sub    $0x8,%esp
     640:	68 ca 3d 00 00       	push   $0x3dca
     645:	ff 35 54 5b 00 00    	pushl  0x5b54
     64b:	e8 0a 32 00 00       	call   385a <printf>
}
     650:	83 c4 10             	add    $0x10,%esp
     653:	8d 65 f8             	lea    -0x8(%ebp),%esp
     656:	5b                   	pop    %ebx
     657:	5e                   	pop    %esi
     658:	5d                   	pop    %ebp
     659:	c3                   	ret    
        printf(stdout, "read only %d blocks from big", n);
     65a:	83 ec 04             	sub    $0x4,%esp
     65d:	53                   	push   %ebx
     65e:	68 8a 3d 00 00       	push   $0x3d8a
     663:	ff 35 54 5b 00 00    	pushl  0x5b54
     669:	e8 ec 31 00 00       	call   385a <printf>
        exit();
     66e:	e8 ad 30 00 00       	call   3720 <exit>
      printf(stdout, "read failed %d\n", i);
     673:	83 ec 04             	sub    $0x4,%esp
     676:	50                   	push   %eax
     677:	68 a7 3d 00 00       	push   $0x3da7
     67c:	ff 35 54 5b 00 00    	pushl  0x5b54
     682:	e8 d3 31 00 00       	call   385a <printf>
      exit();
     687:	e8 94 30 00 00       	call   3720 <exit>
      printf(stdout, "read content of block %d is %d\n",
     68c:	50                   	push   %eax
     68d:	53                   	push   %ebx
     68e:	68 a4 4b 00 00       	push   $0x4ba4
     693:	ff 35 54 5b 00 00    	pushl  0x5b54
     699:	e8 bc 31 00 00       	call   385a <printf>
      exit();
     69e:	e8 7d 30 00 00       	call   3720 <exit>
    printf(stdout, "unlink big failed\n");
     6a3:	83 ec 08             	sub    $0x8,%esp
     6a6:	68 b7 3d 00 00       	push   $0x3db7
     6ab:	ff 35 54 5b 00 00    	pushl  0x5b54
     6b1:	e8 a4 31 00 00       	call   385a <printf>
    exit();
     6b6:	e8 65 30 00 00       	call   3720 <exit>

000006bb <createtest>:

void
createtest(void)
{
     6bb:	55                   	push   %ebp
     6bc:	89 e5                	mov    %esp,%ebp
     6be:	53                   	push   %ebx
     6bf:	83 ec 0c             	sub    $0xc,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     6c2:	68 c4 4b 00 00       	push   $0x4bc4
     6c7:	ff 35 54 5b 00 00    	pushl  0x5b54
     6cd:	e8 88 31 00 00       	call   385a <printf>

  name[0] = 'a';
     6d2:	c6 05 40 a3 00 00 61 	movb   $0x61,0xa340
  name[2] = '\0';
     6d9:	c6 05 42 a3 00 00 00 	movb   $0x0,0xa342
  for(i = 0; i < 52; i++){
     6e0:	83 c4 10             	add    $0x10,%esp
     6e3:	bb 00 00 00 00       	mov    $0x0,%ebx
     6e8:	eb 28                	jmp    712 <createtest+0x57>
    name[1] = '0' + i;
     6ea:	8d 43 30             	lea    0x30(%ebx),%eax
     6ed:	a2 41 a3 00 00       	mov    %al,0xa341
    fd = open(name, O_CREATE|O_RDWR);
     6f2:	83 ec 08             	sub    $0x8,%esp
     6f5:	68 02 02 00 00       	push   $0x202
     6fa:	68 40 a3 00 00       	push   $0xa340
     6ff:	e8 5c 30 00 00       	call   3760 <open>
    close(fd);
     704:	89 04 24             	mov    %eax,(%esp)
     707:	e8 3c 30 00 00       	call   3748 <close>
  for(i = 0; i < 52; i++){
     70c:	83 c3 01             	add    $0x1,%ebx
     70f:	83 c4 10             	add    $0x10,%esp
     712:	83 fb 33             	cmp    $0x33,%ebx
     715:	7e d3                	jle    6ea <createtest+0x2f>
  }
  name[0] = 'a';
     717:	c6 05 40 a3 00 00 61 	movb   $0x61,0xa340
  name[2] = '\0';
     71e:	c6 05 42 a3 00 00 00 	movb   $0x0,0xa342
  for(i = 0; i < 52; i++){
     725:	bb 00 00 00 00       	mov    $0x0,%ebx
     72a:	eb 1b                	jmp    747 <createtest+0x8c>
    name[1] = '0' + i;
     72c:	8d 43 30             	lea    0x30(%ebx),%eax
     72f:	a2 41 a3 00 00       	mov    %al,0xa341
    unlink(name);
     734:	83 ec 0c             	sub    $0xc,%esp
     737:	68 40 a3 00 00       	push   $0xa340
     73c:	e8 2f 30 00 00       	call   3770 <unlink>
  for(i = 0; i < 52; i++){
     741:	83 c3 01             	add    $0x1,%ebx
     744:	83 c4 10             	add    $0x10,%esp
     747:	83 fb 33             	cmp    $0x33,%ebx
     74a:	7e e0                	jle    72c <createtest+0x71>
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     74c:	83 ec 08             	sub    $0x8,%esp
     74f:	68 ec 4b 00 00       	push   $0x4bec
     754:	ff 35 54 5b 00 00    	pushl  0x5b54
     75a:	e8 fb 30 00 00       	call   385a <printf>
}
     75f:	83 c4 10             	add    $0x10,%esp
     762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     765:	c9                   	leave  
     766:	c3                   	ret    

00000767 <dirtest>:

void dirtest(void)
{
     767:	55                   	push   %ebp
     768:	89 e5                	mov    %esp,%ebp
     76a:	83 ec 10             	sub    $0x10,%esp
  printf(stdout, "mkdir test\n");
     76d:	68 d8 3d 00 00       	push   $0x3dd8
     772:	ff 35 54 5b 00 00    	pushl  0x5b54
     778:	e8 dd 30 00 00       	call   385a <printf>

  if(mkdir("dir0") < 0){
     77d:	c7 04 24 e4 3d 00 00 	movl   $0x3de4,(%esp)
     784:	e8 ff 2f 00 00       	call   3788 <mkdir>
     789:	83 c4 10             	add    $0x10,%esp
     78c:	85 c0                	test   %eax,%eax
     78e:	78 54                	js     7e4 <dirtest+0x7d>
    printf(stdout, "mkdir failed\n");
    exit();
  }

  if(chdir("dir0") < 0){
     790:	83 ec 0c             	sub    $0xc,%esp
     793:	68 e4 3d 00 00       	push   $0x3de4
     798:	e8 f3 2f 00 00       	call   3790 <chdir>
     79d:	83 c4 10             	add    $0x10,%esp
     7a0:	85 c0                	test   %eax,%eax
     7a2:	78 58                	js     7fc <dirtest+0x95>
    printf(stdout, "chdir dir0 failed\n");
    exit();
  }

  if(chdir("..") < 0){
     7a4:	83 ec 0c             	sub    $0xc,%esp
     7a7:	68 89 43 00 00       	push   $0x4389
     7ac:	e8 df 2f 00 00       	call   3790 <chdir>
     7b1:	83 c4 10             	add    $0x10,%esp
     7b4:	85 c0                	test   %eax,%eax
     7b6:	78 5c                	js     814 <dirtest+0xad>
    printf(stdout, "chdir .. failed\n");
    exit();
  }

  if(unlink("dir0") < 0){
     7b8:	83 ec 0c             	sub    $0xc,%esp
     7bb:	68 e4 3d 00 00       	push   $0x3de4
     7c0:	e8 ab 2f 00 00       	call   3770 <unlink>
     7c5:	83 c4 10             	add    $0x10,%esp
     7c8:	85 c0                	test   %eax,%eax
     7ca:	78 60                	js     82c <dirtest+0xc5>
    printf(stdout, "unlink dir0 failed\n");
    exit();
  }
  printf(stdout, "mkdir test ok\n");
     7cc:	83 ec 08             	sub    $0x8,%esp
     7cf:	68 21 3e 00 00       	push   $0x3e21
     7d4:	ff 35 54 5b 00 00    	pushl  0x5b54
     7da:	e8 7b 30 00 00       	call   385a <printf>
}
     7df:	83 c4 10             	add    $0x10,%esp
     7e2:	c9                   	leave  
     7e3:	c3                   	ret    
    printf(stdout, "mkdir failed\n");
     7e4:	83 ec 08             	sub    $0x8,%esp
     7e7:	68 14 3b 00 00       	push   $0x3b14
     7ec:	ff 35 54 5b 00 00    	pushl  0x5b54
     7f2:	e8 63 30 00 00       	call   385a <printf>
    exit();
     7f7:	e8 24 2f 00 00       	call   3720 <exit>
    printf(stdout, "chdir dir0 failed\n");
     7fc:	83 ec 08             	sub    $0x8,%esp
     7ff:	68 e9 3d 00 00       	push   $0x3de9
     804:	ff 35 54 5b 00 00    	pushl  0x5b54
     80a:	e8 4b 30 00 00       	call   385a <printf>
    exit();
     80f:	e8 0c 2f 00 00       	call   3720 <exit>
    printf(stdout, "chdir .. failed\n");
     814:	83 ec 08             	sub    $0x8,%esp
     817:	68 fc 3d 00 00       	push   $0x3dfc
     81c:	ff 35 54 5b 00 00    	pushl  0x5b54
     822:	e8 33 30 00 00       	call   385a <printf>
    exit();
     827:	e8 f4 2e 00 00       	call   3720 <exit>
    printf(stdout, "unlink dir0 failed\n");
     82c:	83 ec 08             	sub    $0x8,%esp
     82f:	68 0d 3e 00 00       	push   $0x3e0d
     834:	ff 35 54 5b 00 00    	pushl  0x5b54
     83a:	e8 1b 30 00 00       	call   385a <printf>
    exit();
     83f:	e8 dc 2e 00 00       	call   3720 <exit>

00000844 <exectest>:

void
exectest(void)
{
     844:	55                   	push   %ebp
     845:	89 e5                	mov    %esp,%ebp
     847:	83 ec 10             	sub    $0x10,%esp
  printf(stdout, "exec test\n");
     84a:	68 30 3e 00 00       	push   $0x3e30
     84f:	ff 35 54 5b 00 00    	pushl  0x5b54
     855:	e8 00 30 00 00       	call   385a <printf>
  if(exec("echo", echoargv) < 0){
     85a:	83 c4 08             	add    $0x8,%esp
     85d:	68 58 5b 00 00       	push   $0x5b58
     862:	68 f9 3b 00 00       	push   $0x3bf9
     867:	e8 ec 2e 00 00       	call   3758 <exec>
     86c:	83 c4 10             	add    $0x10,%esp
     86f:	85 c0                	test   %eax,%eax
     871:	78 02                	js     875 <exectest+0x31>
    printf(stdout, "exec echo failed\n");
    exit();
  }
}
     873:	c9                   	leave  
     874:	c3                   	ret    
    printf(stdout, "exec echo failed\n");
     875:	83 ec 08             	sub    $0x8,%esp
     878:	68 3b 3e 00 00       	push   $0x3e3b
     87d:	ff 35 54 5b 00 00    	pushl  0x5b54
     883:	e8 d2 2f 00 00       	call   385a <printf>
    exit();
     888:	e8 93 2e 00 00       	call   3720 <exit>

0000088d <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     88d:	55                   	push   %ebp
     88e:	89 e5                	mov    %esp,%ebp
     890:	57                   	push   %edi
     891:	56                   	push   %esi
     892:	53                   	push   %ebx
     893:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     896:	8d 45 e0             	lea    -0x20(%ebp),%eax
     899:	50                   	push   %eax
     89a:	e8 91 2e 00 00       	call   3730 <pipe>
     89f:	83 c4 10             	add    $0x10,%esp
     8a2:	85 c0                	test   %eax,%eax
     8a4:	75 74                	jne    91a <pipe1+0x8d>
     8a6:	89 c6                	mov    %eax,%esi
    printf(1, "pipe() failed\n");
    exit();
  }
  pid = fork();
     8a8:	e8 6b 2e 00 00       	call   3718 <fork>
     8ad:	89 c7                	mov    %eax,%edi
  seq = 0;
  if(pid == 0){
     8af:	85 c0                	test   %eax,%eax
     8b1:	74 7b                	je     92e <pipe1+0xa1>
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
  } else if(pid > 0){
     8b3:	85 c0                	test   %eax,%eax
     8b5:	0f 8e 5e 01 00 00    	jle    a19 <pipe1+0x18c>
    close(fds[1]);
     8bb:	83 ec 0c             	sub    $0xc,%esp
     8be:	ff 75 e4             	pushl  -0x1c(%ebp)
     8c1:	e8 82 2e 00 00       	call   3748 <close>
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     8c6:	83 c4 10             	add    $0x10,%esp
    total = 0;
     8c9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  seq = 0;
     8cc:	89 f3                	mov    %esi,%ebx
    cc = 1;
     8ce:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     8d5:	83 ec 04             	sub    $0x4,%esp
     8d8:	ff 75 d4             	pushl  -0x2c(%ebp)
     8db:	68 40 83 00 00       	push   $0x8340
     8e0:	ff 75 e0             	pushl  -0x20(%ebp)
     8e3:	e8 50 2e 00 00       	call   3738 <read>
     8e8:	83 c4 10             	add    $0x10,%esp
     8eb:	85 c0                	test   %eax,%eax
     8ed:	0f 8e e2 00 00 00    	jle    9d5 <pipe1+0x148>
      for(i = 0; i < n; i++){
     8f3:	89 f2                	mov    %esi,%edx
     8f5:	89 df                	mov    %ebx,%edi
     8f7:	39 c2                	cmp    %eax,%edx
     8f9:	0f 8d b4 00 00 00    	jge    9b3 <pipe1+0x126>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     8ff:	0f be 9a 40 83 00 00 	movsbl 0x8340(%edx),%ebx
     906:	8d 4f 01             	lea    0x1(%edi),%ecx
     909:	31 fb                	xor    %edi,%ebx
     90b:	84 db                	test   %bl,%bl
     90d:	0f 85 86 00 00 00    	jne    999 <pipe1+0x10c>
      for(i = 0; i < n; i++){
     913:	83 c2 01             	add    $0x1,%edx
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     916:	89 cf                	mov    %ecx,%edi
     918:	eb dd                	jmp    8f7 <pipe1+0x6a>
    printf(1, "pipe() failed\n");
     91a:	83 ec 08             	sub    $0x8,%esp
     91d:	68 4d 3e 00 00       	push   $0x3e4d
     922:	6a 01                	push   $0x1
     924:	e8 31 2f 00 00       	call   385a <printf>
    exit();
     929:	e8 f2 2d 00 00       	call   3720 <exit>
    close(fds[0]);
     92e:	83 ec 0c             	sub    $0xc,%esp
     931:	ff 75 e0             	pushl  -0x20(%ebp)
     934:	e8 0f 2e 00 00       	call   3748 <close>
    for(n = 0; n < 5; n++){
     939:	83 c4 10             	add    $0x10,%esp
     93c:	89 fe                	mov    %edi,%esi
  seq = 0;
     93e:	89 fb                	mov    %edi,%ebx
    for(n = 0; n < 5; n++){
     940:	eb 35                	jmp    977 <pipe1+0xea>
        buf[i] = seq++;
     942:	88 98 40 83 00 00    	mov    %bl,0x8340(%eax)
      for(i = 0; i < 1033; i++)
     948:	83 c0 01             	add    $0x1,%eax
        buf[i] = seq++;
     94b:	8d 5b 01             	lea    0x1(%ebx),%ebx
      for(i = 0; i < 1033; i++)
     94e:	3d 08 04 00 00       	cmp    $0x408,%eax
     953:	7e ed                	jle    942 <pipe1+0xb5>
      if(write(fds[1], buf, 1033) != 1033){
     955:	83 ec 04             	sub    $0x4,%esp
     958:	68 09 04 00 00       	push   $0x409
     95d:	68 40 83 00 00       	push   $0x8340
     962:	ff 75 e4             	pushl  -0x1c(%ebp)
     965:	e8 d6 2d 00 00       	call   3740 <write>
     96a:	83 c4 10             	add    $0x10,%esp
     96d:	3d 09 04 00 00       	cmp    $0x409,%eax
     972:	75 0c                	jne    980 <pipe1+0xf3>
    for(n = 0; n < 5; n++){
     974:	83 c6 01             	add    $0x1,%esi
     977:	83 fe 04             	cmp    $0x4,%esi
     97a:	7f 18                	jg     994 <pipe1+0x107>
      for(i = 0; i < 1033; i++)
     97c:	89 f8                	mov    %edi,%eax
     97e:	eb ce                	jmp    94e <pipe1+0xc1>
        printf(1, "pipe1 oops 1\n");
     980:	83 ec 08             	sub    $0x8,%esp
     983:	68 5c 3e 00 00       	push   $0x3e5c
     988:	6a 01                	push   $0x1
     98a:	e8 cb 2e 00 00       	call   385a <printf>
        exit();
     98f:	e8 8c 2d 00 00       	call   3720 <exit>
    exit();
     994:	e8 87 2d 00 00       	call   3720 <exit>
          printf(1, "pipe1 oops 2\n");
     999:	83 ec 08             	sub    $0x8,%esp
     99c:	68 6a 3e 00 00       	push   $0x3e6a
     9a1:	6a 01                	push   $0x1
     9a3:	e8 b2 2e 00 00       	call   385a <printf>
          return;
     9a8:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
}
     9ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
     9ae:	5b                   	pop    %ebx
     9af:	5e                   	pop    %esi
     9b0:	5f                   	pop    %edi
     9b1:	5d                   	pop    %ebp
     9b2:	c3                   	ret    
     9b3:	89 fb                	mov    %edi,%ebx
      total += n;
     9b5:	01 45 d0             	add    %eax,-0x30(%ebp)
      cc = cc * 2;
     9b8:	d1 65 d4             	shll   -0x2c(%ebp)
     9bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
      if(cc > sizeof(buf))
     9be:	3d 00 20 00 00       	cmp    $0x2000,%eax
     9c3:	0f 86 0c ff ff ff    	jbe    8d5 <pipe1+0x48>
        cc = sizeof(buf);
     9c9:	c7 45 d4 00 20 00 00 	movl   $0x2000,-0x2c(%ebp)
     9d0:	e9 00 ff ff ff       	jmp    8d5 <pipe1+0x48>
    if(total != 5 * 1033){
     9d5:	81 7d d0 2d 14 00 00 	cmpl   $0x142d,-0x30(%ebp)
     9dc:	75 24                	jne    a02 <pipe1+0x175>
    close(fds[0]);
     9de:	83 ec 0c             	sub    $0xc,%esp
     9e1:	ff 75 e0             	pushl  -0x20(%ebp)
     9e4:	e8 5f 2d 00 00       	call   3748 <close>
    wait();
     9e9:	e8 3a 2d 00 00       	call   3728 <wait>
  printf(1, "pipe1 ok\n");
     9ee:	83 c4 08             	add    $0x8,%esp
     9f1:	68 8f 3e 00 00       	push   $0x3e8f
     9f6:	6a 01                	push   $0x1
     9f8:	e8 5d 2e 00 00       	call   385a <printf>
     9fd:	83 c4 10             	add    $0x10,%esp
     a00:	eb a9                	jmp    9ab <pipe1+0x11e>
      printf(1, "pipe1 oops 3 total %d\n", total);
     a02:	83 ec 04             	sub    $0x4,%esp
     a05:	ff 75 d0             	pushl  -0x30(%ebp)
     a08:	68 78 3e 00 00       	push   $0x3e78
     a0d:	6a 01                	push   $0x1
     a0f:	e8 46 2e 00 00       	call   385a <printf>
      exit();
     a14:	e8 07 2d 00 00       	call   3720 <exit>
    printf(1, "fork() failed\n");
     a19:	83 ec 08             	sub    $0x8,%esp
     a1c:	68 99 3e 00 00       	push   $0x3e99
     a21:	6a 01                	push   $0x1
     a23:	e8 32 2e 00 00       	call   385a <printf>
    exit();
     a28:	e8 f3 2c 00 00       	call   3720 <exit>

00000a2d <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     a2d:	55                   	push   %ebp
     a2e:	89 e5                	mov    %esp,%ebp
     a30:	57                   	push   %edi
     a31:	56                   	push   %esi
     a32:	53                   	push   %ebx
     a33:	83 ec 24             	sub    $0x24,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     a36:	68 a8 3e 00 00       	push   $0x3ea8
     a3b:	6a 01                	push   $0x1
     a3d:	e8 18 2e 00 00       	call   385a <printf>
  pid1 = fork();
     a42:	e8 d1 2c 00 00       	call   3718 <fork>
  if(pid1 == 0)
     a47:	83 c4 10             	add    $0x10,%esp
     a4a:	85 c0                	test   %eax,%eax
     a4c:	75 02                	jne    a50 <preempt+0x23>
     a4e:	eb fe                	jmp    a4e <preempt+0x21>
     a50:	89 c7                	mov    %eax,%edi
    for(;;)
      ;

  pid2 = fork();
     a52:	e8 c1 2c 00 00       	call   3718 <fork>
     a57:	89 c6                	mov    %eax,%esi
  if(pid2 == 0)
     a59:	85 c0                	test   %eax,%eax
     a5b:	75 02                	jne    a5f <preempt+0x32>
     a5d:	eb fe                	jmp    a5d <preempt+0x30>
    for(;;)
      ;

  pipe(pfds);
     a5f:	83 ec 0c             	sub    $0xc,%esp
     a62:	8d 45 e0             	lea    -0x20(%ebp),%eax
     a65:	50                   	push   %eax
     a66:	e8 c5 2c 00 00       	call   3730 <pipe>
  pid3 = fork();
     a6b:	e8 a8 2c 00 00       	call   3718 <fork>
     a70:	89 c3                	mov    %eax,%ebx
  if(pid3 == 0){
     a72:	83 c4 10             	add    $0x10,%esp
     a75:	85 c0                	test   %eax,%eax
     a77:	75 47                	jne    ac0 <preempt+0x93>
    close(pfds[0]);
     a79:	83 ec 0c             	sub    $0xc,%esp
     a7c:	ff 75 e0             	pushl  -0x20(%ebp)
     a7f:	e8 c4 2c 00 00       	call   3748 <close>
    if(write(pfds[1], "x", 1) != 1)
     a84:	83 c4 0c             	add    $0xc,%esp
     a87:	6a 01                	push   $0x1
     a89:	68 6d 44 00 00       	push   $0x446d
     a8e:	ff 75 e4             	pushl  -0x1c(%ebp)
     a91:	e8 aa 2c 00 00       	call   3740 <write>
     a96:	83 c4 10             	add    $0x10,%esp
     a99:	83 f8 01             	cmp    $0x1,%eax
     a9c:	74 12                	je     ab0 <preempt+0x83>
      printf(1, "preempt write error");
     a9e:	83 ec 08             	sub    $0x8,%esp
     aa1:	68 b2 3e 00 00       	push   $0x3eb2
     aa6:	6a 01                	push   $0x1
     aa8:	e8 ad 2d 00 00       	call   385a <printf>
     aad:	83 c4 10             	add    $0x10,%esp
    close(pfds[1]);
     ab0:	83 ec 0c             	sub    $0xc,%esp
     ab3:	ff 75 e4             	pushl  -0x1c(%ebp)
     ab6:	e8 8d 2c 00 00       	call   3748 <close>
     abb:	83 c4 10             	add    $0x10,%esp
     abe:	eb fe                	jmp    abe <preempt+0x91>
    for(;;)
      ;
  }

  close(pfds[1]);
     ac0:	83 ec 0c             	sub    $0xc,%esp
     ac3:	ff 75 e4             	pushl  -0x1c(%ebp)
     ac6:	e8 7d 2c 00 00       	call   3748 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     acb:	83 c4 0c             	add    $0xc,%esp
     ace:	68 00 20 00 00       	push   $0x2000
     ad3:	68 40 83 00 00       	push   $0x8340
     ad8:	ff 75 e0             	pushl  -0x20(%ebp)
     adb:	e8 58 2c 00 00       	call   3738 <read>
     ae0:	83 c4 10             	add    $0x10,%esp
     ae3:	83 f8 01             	cmp    $0x1,%eax
     ae6:	74 1a                	je     b02 <preempt+0xd5>
    printf(1, "preempt read error");
     ae8:	83 ec 08             	sub    $0x8,%esp
     aeb:	68 c6 3e 00 00       	push   $0x3ec6
     af0:	6a 01                	push   $0x1
     af2:	e8 63 2d 00 00       	call   385a <printf>
    return;
     af7:	83 c4 10             	add    $0x10,%esp
  printf(1, "wait... ");
  wait();
  wait();
  wait();
  printf(1, "preempt ok\n");
}
     afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
     afd:	5b                   	pop    %ebx
     afe:	5e                   	pop    %esi
     aff:	5f                   	pop    %edi
     b00:	5d                   	pop    %ebp
     b01:	c3                   	ret    
  close(pfds[0]);
     b02:	83 ec 0c             	sub    $0xc,%esp
     b05:	ff 75 e0             	pushl  -0x20(%ebp)
     b08:	e8 3b 2c 00 00       	call   3748 <close>
  printf(1, "kill... ");
     b0d:	83 c4 08             	add    $0x8,%esp
     b10:	68 d9 3e 00 00       	push   $0x3ed9
     b15:	6a 01                	push   $0x1
     b17:	e8 3e 2d 00 00       	call   385a <printf>
  kill(pid1);
     b1c:	89 3c 24             	mov    %edi,(%esp)
     b1f:	e8 2c 2c 00 00       	call   3750 <kill>
  kill(pid2);
     b24:	89 34 24             	mov    %esi,(%esp)
     b27:	e8 24 2c 00 00       	call   3750 <kill>
  kill(pid3);
     b2c:	89 1c 24             	mov    %ebx,(%esp)
     b2f:	e8 1c 2c 00 00       	call   3750 <kill>
  printf(1, "wait... ");
     b34:	83 c4 08             	add    $0x8,%esp
     b37:	68 e2 3e 00 00       	push   $0x3ee2
     b3c:	6a 01                	push   $0x1
     b3e:	e8 17 2d 00 00       	call   385a <printf>
  wait();
     b43:	e8 e0 2b 00 00       	call   3728 <wait>
  wait();
     b48:	e8 db 2b 00 00       	call   3728 <wait>
  wait();
     b4d:	e8 d6 2b 00 00       	call   3728 <wait>
  printf(1, "preempt ok\n");
     b52:	83 c4 08             	add    $0x8,%esp
     b55:	68 eb 3e 00 00       	push   $0x3eeb
     b5a:	6a 01                	push   $0x1
     b5c:	e8 f9 2c 00 00       	call   385a <printf>
     b61:	83 c4 10             	add    $0x10,%esp
     b64:	eb 94                	jmp    afa <preempt+0xcd>

00000b66 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     b66:	55                   	push   %ebp
     b67:	89 e5                	mov    %esp,%ebp
     b69:	56                   	push   %esi
     b6a:	53                   	push   %ebx
  int i, pid;

  for(i = 0; i < 100; i++){
     b6b:	be 00 00 00 00       	mov    $0x0,%esi
     b70:	83 fe 63             	cmp    $0x63,%esi
     b73:	7f 4f                	jg     bc4 <exitwait+0x5e>
    pid = fork();
     b75:	e8 9e 2b 00 00       	call   3718 <fork>
     b7a:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
     b7c:	85 c0                	test   %eax,%eax
     b7e:	78 12                	js     b92 <exitwait+0x2c>
      printf(1, "fork failed\n");
      return;
    }
    if(pid){
     b80:	85 c0                	test   %eax,%eax
     b82:	74 3b                	je     bbf <exitwait+0x59>
      if(wait() != pid){
     b84:	e8 9f 2b 00 00       	call   3728 <wait>
     b89:	39 d8                	cmp    %ebx,%eax
     b8b:	75 1e                	jne    bab <exitwait+0x45>
  for(i = 0; i < 100; i++){
     b8d:	83 c6 01             	add    $0x1,%esi
     b90:	eb de                	jmp    b70 <exitwait+0xa>
      printf(1, "fork failed\n");
     b92:	83 ec 08             	sub    $0x8,%esp
     b95:	68 55 4a 00 00       	push   $0x4a55
     b9a:	6a 01                	push   $0x1
     b9c:	e8 b9 2c 00 00       	call   385a <printf>
      return;
     ba1:	83 c4 10             	add    $0x10,%esp
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
}
     ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
     ba7:	5b                   	pop    %ebx
     ba8:	5e                   	pop    %esi
     ba9:	5d                   	pop    %ebp
     baa:	c3                   	ret    
        printf(1, "wait wrong pid\n");
     bab:	83 ec 08             	sub    $0x8,%esp
     bae:	68 f7 3e 00 00       	push   $0x3ef7
     bb3:	6a 01                	push   $0x1
     bb5:	e8 a0 2c 00 00       	call   385a <printf>
        return;
     bba:	83 c4 10             	add    $0x10,%esp
     bbd:	eb e5                	jmp    ba4 <exitwait+0x3e>
      exit();
     bbf:	e8 5c 2b 00 00       	call   3720 <exit>
  printf(1, "exitwait ok\n");
     bc4:	83 ec 08             	sub    $0x8,%esp
     bc7:	68 07 3f 00 00       	push   $0x3f07
     bcc:	6a 01                	push   $0x1
     bce:	e8 87 2c 00 00       	call   385a <printf>
     bd3:	83 c4 10             	add    $0x10,%esp
     bd6:	eb cc                	jmp    ba4 <exitwait+0x3e>

00000bd8 <mem>:

void
mem(void)
{
     bd8:	55                   	push   %ebp
     bd9:	89 e5                	mov    %esp,%ebp
     bdb:	57                   	push   %edi
     bdc:	56                   	push   %esi
     bdd:	53                   	push   %ebx
     bde:	83 ec 14             	sub    $0x14,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     be1:	68 14 3f 00 00       	push   $0x3f14
     be6:	6a 01                	push   $0x1
     be8:	e8 6d 2c 00 00       	call   385a <printf>
  ppid = getpid();
     bed:	e8 ae 2b 00 00       	call   37a0 <getpid>
     bf2:	89 c6                	mov    %eax,%esi
  if((pid = fork()) == 0){
     bf4:	e8 1f 2b 00 00       	call   3718 <fork>
     bf9:	83 c4 10             	add    $0x10,%esp
     bfc:	85 c0                	test   %eax,%eax
     bfe:	0f 85 82 00 00 00    	jne    c86 <mem+0xae>
    m1 = 0;
     c04:	bb 00 00 00 00       	mov    $0x0,%ebx
     c09:	eb 04                	jmp    c0f <mem+0x37>
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
     c0b:	89 18                	mov    %ebx,(%eax)
      m1 = m2;
     c0d:	89 c3                	mov    %eax,%ebx
    while((m2 = malloc(10001)) != 0){
     c0f:	83 ec 0c             	sub    $0xc,%esp
     c12:	68 11 27 00 00       	push   $0x2711
     c17:	e8 67 2e 00 00       	call   3a83 <malloc>
     c1c:	83 c4 10             	add    $0x10,%esp
     c1f:	85 c0                	test   %eax,%eax
     c21:	75 e8                	jne    c0b <mem+0x33>
     c23:	eb 10                	jmp    c35 <mem+0x5d>
    }
    while(m1){
      m2 = *(char**)m1;
     c25:	8b 3b                	mov    (%ebx),%edi
      free(m1);
     c27:	83 ec 0c             	sub    $0xc,%esp
     c2a:	53                   	push   %ebx
     c2b:	e8 93 2d 00 00       	call   39c3 <free>
      m1 = m2;
     c30:	83 c4 10             	add    $0x10,%esp
     c33:	89 fb                	mov    %edi,%ebx
    while(m1){
     c35:	85 db                	test   %ebx,%ebx
     c37:	75 ec                	jne    c25 <mem+0x4d>
    }
    m1 = malloc(1024*20);
     c39:	83 ec 0c             	sub    $0xc,%esp
     c3c:	68 00 50 00 00       	push   $0x5000
     c41:	e8 3d 2e 00 00       	call   3a83 <malloc>
    if(m1 == 0){
     c46:	83 c4 10             	add    $0x10,%esp
     c49:	85 c0                	test   %eax,%eax
     c4b:	74 1d                	je     c6a <mem+0x92>
      printf(1, "couldn't allocate mem?!!\n");
      kill(ppid);
      exit();
    }
    free(m1);
     c4d:	83 ec 0c             	sub    $0xc,%esp
     c50:	50                   	push   %eax
     c51:	e8 6d 2d 00 00       	call   39c3 <free>
    printf(1, "mem ok\n");
     c56:	83 c4 08             	add    $0x8,%esp
     c59:	68 38 3f 00 00       	push   $0x3f38
     c5e:	6a 01                	push   $0x1
     c60:	e8 f5 2b 00 00       	call   385a <printf>
    exit();
     c65:	e8 b6 2a 00 00       	call   3720 <exit>
      printf(1, "couldn't allocate mem?!!\n");
     c6a:	83 ec 08             	sub    $0x8,%esp
     c6d:	68 1e 3f 00 00       	push   $0x3f1e
     c72:	6a 01                	push   $0x1
     c74:	e8 e1 2b 00 00       	call   385a <printf>
      kill(ppid);
     c79:	89 34 24             	mov    %esi,(%esp)
     c7c:	e8 cf 2a 00 00       	call   3750 <kill>
      exit();
     c81:	e8 9a 2a 00 00       	call   3720 <exit>
  } else {
    wait();
     c86:	e8 9d 2a 00 00       	call   3728 <wait>
  }
}
     c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
     c8e:	5b                   	pop    %ebx
     c8f:	5e                   	pop    %esi
     c90:	5f                   	pop    %edi
     c91:	5d                   	pop    %ebp
     c92:	c3                   	ret    

00000c93 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     c93:	55                   	push   %ebp
     c94:	89 e5                	mov    %esp,%ebp
     c96:	57                   	push   %edi
     c97:	56                   	push   %esi
     c98:	53                   	push   %ebx
     c99:	83 ec 24             	sub    $0x24,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     c9c:	68 40 3f 00 00       	push   $0x3f40
     ca1:	6a 01                	push   $0x1
     ca3:	e8 b2 2b 00 00       	call   385a <printf>

  unlink("sharedfd");
     ca8:	c7 04 24 4f 3f 00 00 	movl   $0x3f4f,(%esp)
     caf:	e8 bc 2a 00 00       	call   3770 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     cb4:	83 c4 08             	add    $0x8,%esp
     cb7:	68 02 02 00 00       	push   $0x202
     cbc:	68 4f 3f 00 00       	push   $0x3f4f
     cc1:	e8 9a 2a 00 00       	call   3760 <open>
  if(fd < 0){
     cc6:	83 c4 10             	add    $0x10,%esp
     cc9:	85 c0                	test   %eax,%eax
     ccb:	78 4d                	js     d1a <sharedfd+0x87>
     ccd:	89 c6                	mov    %eax,%esi
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
     ccf:	e8 44 2a 00 00       	call   3718 <fork>
     cd4:	89 c7                	mov    %eax,%edi
  memset(buf, pid==0?'c':'p', sizeof(buf));
     cd6:	85 c0                	test   %eax,%eax
     cd8:	75 57                	jne    d31 <sharedfd+0x9e>
     cda:	b8 63 00 00 00       	mov    $0x63,%eax
     cdf:	83 ec 04             	sub    $0x4,%esp
     ce2:	6a 0a                	push   $0xa
     ce4:	50                   	push   %eax
     ce5:	8d 45 de             	lea    -0x22(%ebp),%eax
     ce8:	50                   	push   %eax
     ce9:	e8 03 29 00 00       	call   35f1 <memset>
  for(i = 0; i < 1000; i++){
     cee:	83 c4 10             	add    $0x10,%esp
     cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
     cf6:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
     cfc:	7f 4c                	jg     d4a <sharedfd+0xb7>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     cfe:	83 ec 04             	sub    $0x4,%esp
     d01:	6a 0a                	push   $0xa
     d03:	8d 45 de             	lea    -0x22(%ebp),%eax
     d06:	50                   	push   %eax
     d07:	56                   	push   %esi
     d08:	e8 33 2a 00 00       	call   3740 <write>
     d0d:	83 c4 10             	add    $0x10,%esp
     d10:	83 f8 0a             	cmp    $0xa,%eax
     d13:	75 23                	jne    d38 <sharedfd+0xa5>
  for(i = 0; i < 1000; i++){
     d15:	83 c3 01             	add    $0x1,%ebx
     d18:	eb dc                	jmp    cf6 <sharedfd+0x63>
    printf(1, "fstests: cannot open sharedfd for writing");
     d1a:	83 ec 08             	sub    $0x8,%esp
     d1d:	68 14 4c 00 00       	push   $0x4c14
     d22:	6a 01                	push   $0x1
     d24:	e8 31 2b 00 00       	call   385a <printf>
    return;
     d29:	83 c4 10             	add    $0x10,%esp
     d2c:	e9 e4 00 00 00       	jmp    e15 <sharedfd+0x182>
  memset(buf, pid==0?'c':'p', sizeof(buf));
     d31:	b8 70 00 00 00       	mov    $0x70,%eax
     d36:	eb a7                	jmp    cdf <sharedfd+0x4c>
      printf(1, "fstests: write sharedfd failed\n");
     d38:	83 ec 08             	sub    $0x8,%esp
     d3b:	68 40 4c 00 00       	push   $0x4c40
     d40:	6a 01                	push   $0x1
     d42:	e8 13 2b 00 00       	call   385a <printf>
      break;
     d47:	83 c4 10             	add    $0x10,%esp
    }
  }
  if(pid == 0)
     d4a:	85 ff                	test   %edi,%edi
     d4c:	74 4d                	je     d9b <sharedfd+0x108>
    exit();
  else
    wait();
     d4e:	e8 d5 29 00 00       	call   3728 <wait>
  close(fd);
     d53:	83 ec 0c             	sub    $0xc,%esp
     d56:	56                   	push   %esi
     d57:	e8 ec 29 00 00       	call   3748 <close>
  fd = open("sharedfd", 0);
     d5c:	83 c4 08             	add    $0x8,%esp
     d5f:	6a 00                	push   $0x0
     d61:	68 4f 3f 00 00       	push   $0x3f4f
     d66:	e8 f5 29 00 00       	call   3760 <open>
     d6b:	89 c7                	mov    %eax,%edi
  if(fd < 0){
     d6d:	83 c4 10             	add    $0x10,%esp
     d70:	85 c0                	test   %eax,%eax
     d72:	78 2c                	js     da0 <sharedfd+0x10d>
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
     d74:	be 00 00 00 00       	mov    $0x0,%esi
     d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  while((n = read(fd, buf, sizeof(buf))) > 0){
     d7e:	83 ec 04             	sub    $0x4,%esp
     d81:	6a 0a                	push   $0xa
     d83:	8d 45 de             	lea    -0x22(%ebp),%eax
     d86:	50                   	push   %eax
     d87:	57                   	push   %edi
     d88:	e8 ab 29 00 00       	call   3738 <read>
     d8d:	83 c4 10             	add    $0x10,%esp
     d90:	85 c0                	test   %eax,%eax
     d92:	7e 41                	jle    dd5 <sharedfd+0x142>
    for(i = 0; i < sizeof(buf); i++){
     d94:	b8 00 00 00 00       	mov    $0x0,%eax
     d99:	eb 21                	jmp    dbc <sharedfd+0x129>
    exit();
     d9b:	e8 80 29 00 00       	call   3720 <exit>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     da0:	83 ec 08             	sub    $0x8,%esp
     da3:	68 60 4c 00 00       	push   $0x4c60
     da8:	6a 01                	push   $0x1
     daa:	e8 ab 2a 00 00       	call   385a <printf>
    return;
     daf:	83 c4 10             	add    $0x10,%esp
     db2:	eb 61                	jmp    e15 <sharedfd+0x182>
      if(buf[i] == 'c')
        nc++;
     db4:	83 c3 01             	add    $0x1,%ebx
     db7:	eb 12                	jmp    dcb <sharedfd+0x138>
    for(i = 0; i < sizeof(buf); i++){
     db9:	83 c0 01             	add    $0x1,%eax
     dbc:	83 f8 09             	cmp    $0x9,%eax
     dbf:	77 bd                	ja     d7e <sharedfd+0xeb>
      if(buf[i] == 'c')
     dc1:	0f b6 54 05 de       	movzbl -0x22(%ebp,%eax,1),%edx
     dc6:	80 fa 63             	cmp    $0x63,%dl
     dc9:	74 e9                	je     db4 <sharedfd+0x121>
      if(buf[i] == 'p')
     dcb:	80 fa 70             	cmp    $0x70,%dl
     dce:	75 e9                	jne    db9 <sharedfd+0x126>
        np++;
     dd0:	83 c6 01             	add    $0x1,%esi
     dd3:	eb e4                	jmp    db9 <sharedfd+0x126>
    }
  }
  close(fd);
     dd5:	83 ec 0c             	sub    $0xc,%esp
     dd8:	57                   	push   %edi
     dd9:	e8 6a 29 00 00       	call   3748 <close>
  unlink("sharedfd");
     dde:	c7 04 24 4f 3f 00 00 	movl   $0x3f4f,(%esp)
     de5:	e8 86 29 00 00       	call   3770 <unlink>
  if(nc == 10000 && np == 10000){
     dea:	83 c4 10             	add    $0x10,%esp
     ded:	81 fb 10 27 00 00    	cmp    $0x2710,%ebx
     df3:	0f 94 c2             	sete   %dl
     df6:	81 fe 10 27 00 00    	cmp    $0x2710,%esi
     dfc:	0f 94 c0             	sete   %al
     dff:	84 c2                	test   %al,%dl
     e01:	74 1a                	je     e1d <sharedfd+0x18a>
    printf(1, "sharedfd ok\n");
     e03:	83 ec 08             	sub    $0x8,%esp
     e06:	68 58 3f 00 00       	push   $0x3f58
     e0b:	6a 01                	push   $0x1
     e0d:	e8 48 2a 00 00       	call   385a <printf>
     e12:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    exit();
  }
}
     e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
     e18:	5b                   	pop    %ebx
     e19:	5e                   	pop    %esi
     e1a:	5f                   	pop    %edi
     e1b:	5d                   	pop    %ebp
     e1c:	c3                   	ret    
    printf(1, "sharedfd oops %d %d\n", nc, np);
     e1d:	56                   	push   %esi
     e1e:	53                   	push   %ebx
     e1f:	68 65 3f 00 00       	push   $0x3f65
     e24:	6a 01                	push   $0x1
     e26:	e8 2f 2a 00 00       	call   385a <printf>
    exit();
     e2b:	e8 f0 28 00 00       	call   3720 <exit>

00000e30 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
     e30:	55                   	push   %ebp
     e31:	89 e5                	mov    %esp,%ebp
     e33:	57                   	push   %edi
     e34:	56                   	push   %esi
     e35:	53                   	push   %ebx
     e36:	83 ec 34             	sub    $0x34,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
     e39:	c7 45 d8 7a 3f 00 00 	movl   $0x3f7a,-0x28(%ebp)
     e40:	c7 45 dc c3 40 00 00 	movl   $0x40c3,-0x24(%ebp)
     e47:	c7 45 e0 c7 40 00 00 	movl   $0x40c7,-0x20(%ebp)
     e4e:	c7 45 e4 7d 3f 00 00 	movl   $0x3f7d,-0x1c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
     e55:	68 80 3f 00 00       	push   $0x3f80
     e5a:	6a 01                	push   $0x1
     e5c:	e8 f9 29 00 00       	call   385a <printf>

  for(pi = 0; pi < 4; pi++){
     e61:	83 c4 10             	add    $0x10,%esp
     e64:	be 00 00 00 00       	mov    $0x0,%esi
     e69:	83 fe 03             	cmp    $0x3,%esi
     e6c:	0f 8f bd 00 00 00    	jg     f2f <fourfiles+0xff>
    fname = names[pi];
     e72:	8b 7c b5 d8          	mov    -0x28(%ebp,%esi,4),%edi
    unlink(fname);
     e76:	83 ec 0c             	sub    $0xc,%esp
     e79:	57                   	push   %edi
     e7a:	e8 f1 28 00 00       	call   3770 <unlink>

    pid = fork();
     e7f:	e8 94 28 00 00       	call   3718 <fork>
    if(pid < 0){
     e84:	83 c4 10             	add    $0x10,%esp
     e87:	85 c0                	test   %eax,%eax
     e89:	78 09                	js     e94 <fourfiles+0x64>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
     e8b:	85 c0                	test   %eax,%eax
     e8d:	74 19                	je     ea8 <fourfiles+0x78>
  for(pi = 0; pi < 4; pi++){
     e8f:	83 c6 01             	add    $0x1,%esi
     e92:	eb d5                	jmp    e69 <fourfiles+0x39>
      printf(1, "fork failed\n");
     e94:	83 ec 08             	sub    $0x8,%esp
     e97:	68 55 4a 00 00       	push   $0x4a55
     e9c:	6a 01                	push   $0x1
     e9e:	e8 b7 29 00 00       	call   385a <printf>
      exit();
     ea3:	e8 78 28 00 00       	call   3720 <exit>
     ea8:	89 c3                	mov    %eax,%ebx
      fd = open(fname, O_CREATE | O_RDWR);
     eaa:	83 ec 08             	sub    $0x8,%esp
     ead:	68 02 02 00 00       	push   $0x202
     eb2:	57                   	push   %edi
     eb3:	e8 a8 28 00 00       	call   3760 <open>
     eb8:	89 c7                	mov    %eax,%edi
      if(fd < 0){
     eba:	83 c4 10             	add    $0x10,%esp
     ebd:	85 c0                	test   %eax,%eax
     ebf:	78 1b                	js     edc <fourfiles+0xac>
        printf(1, "create failed\n");
        exit();
      }

      memset(buf, '0'+pi, 512);
     ec1:	83 ec 04             	sub    $0x4,%esp
     ec4:	68 00 02 00 00       	push   $0x200
     ec9:	83 c6 30             	add    $0x30,%esi
     ecc:	56                   	push   %esi
     ecd:	68 40 83 00 00       	push   $0x8340
     ed2:	e8 1a 27 00 00       	call   35f1 <memset>
      for(i = 0; i < 12; i++){
     ed7:	83 c4 10             	add    $0x10,%esp
     eda:	eb 34                	jmp    f10 <fourfiles+0xe0>
        printf(1, "create failed\n");
     edc:	83 ec 08             	sub    $0x8,%esp
     edf:	68 1b 42 00 00       	push   $0x421b
     ee4:	6a 01                	push   $0x1
     ee6:	e8 6f 29 00 00       	call   385a <printf>
        exit();
     eeb:	e8 30 28 00 00       	call   3720 <exit>
        if((n = write(fd, buf, 500)) != 500){
     ef0:	83 ec 04             	sub    $0x4,%esp
     ef3:	68 f4 01 00 00       	push   $0x1f4
     ef8:	68 40 83 00 00       	push   $0x8340
     efd:	57                   	push   %edi
     efe:	e8 3d 28 00 00       	call   3740 <write>
     f03:	83 c4 10             	add    $0x10,%esp
     f06:	3d f4 01 00 00       	cmp    $0x1f4,%eax
     f0b:	75 0d                	jne    f1a <fourfiles+0xea>
      for(i = 0; i < 12; i++){
     f0d:	83 c3 01             	add    $0x1,%ebx
     f10:	83 fb 0b             	cmp    $0xb,%ebx
     f13:	7e db                	jle    ef0 <fourfiles+0xc0>
          printf(1, "write failed %d\n", n);
          exit();
        }
      }
      exit();
     f15:	e8 06 28 00 00       	call   3720 <exit>
          printf(1, "write failed %d\n", n);
     f1a:	83 ec 04             	sub    $0x4,%esp
     f1d:	50                   	push   %eax
     f1e:	68 90 3f 00 00       	push   $0x3f90
     f23:	6a 01                	push   $0x1
     f25:	e8 30 29 00 00       	call   385a <printf>
          exit();
     f2a:	e8 f1 27 00 00       	call   3720 <exit>
    }
  }

  for(pi = 0; pi < 4; pi++){
     f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
     f34:	83 fb 03             	cmp    $0x3,%ebx
     f37:	7f 0a                	jg     f43 <fourfiles+0x113>
    wait();
     f39:	e8 ea 27 00 00       	call   3728 <wait>
  for(pi = 0; pi < 4; pi++){
     f3e:	83 c3 01             	add    $0x1,%ebx
     f41:	eb f1                	jmp    f34 <fourfiles+0x104>
  }

  for(i = 0; i < 2; i++){
     f43:	bb 00 00 00 00       	mov    $0x0,%ebx
     f48:	eb 75                	jmp    fbf <fourfiles+0x18f>
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
     f4a:	83 ec 08             	sub    $0x8,%esp
     f4d:	68 a1 3f 00 00       	push   $0x3fa1
     f52:	6a 01                	push   $0x1
     f54:	e8 01 29 00 00       	call   385a <printf>
          exit();
     f59:	e8 c2 27 00 00       	call   3720 <exit>
        }
      }
      total += n;
     f5e:	01 c6                	add    %eax,%esi
    while((n = read(fd, buf, sizeof(buf))) > 0){
     f60:	83 ec 04             	sub    $0x4,%esp
     f63:	68 00 20 00 00       	push   $0x2000
     f68:	68 40 83 00 00       	push   $0x8340
     f6d:	ff 75 d4             	pushl  -0x2c(%ebp)
     f70:	e8 c3 27 00 00       	call   3738 <read>
     f75:	83 c4 10             	add    $0x10,%esp
     f78:	85 c0                	test   %eax,%eax
     f7a:	7e 1c                	jle    f98 <fourfiles+0x168>
      for(j = 0; j < n; j++){
     f7c:	ba 00 00 00 00       	mov    $0x0,%edx
     f81:	39 c2                	cmp    %eax,%edx
     f83:	7d d9                	jge    f5e <fourfiles+0x12e>
        if(buf[j] != '0'+i){
     f85:	0f be ba 40 83 00 00 	movsbl 0x8340(%edx),%edi
     f8c:	8d 4b 30             	lea    0x30(%ebx),%ecx
     f8f:	39 cf                	cmp    %ecx,%edi
     f91:	75 b7                	jne    f4a <fourfiles+0x11a>
      for(j = 0; j < n; j++){
     f93:	83 c2 01             	add    $0x1,%edx
     f96:	eb e9                	jmp    f81 <fourfiles+0x151>
    }
    close(fd);
     f98:	83 ec 0c             	sub    $0xc,%esp
     f9b:	ff 75 d4             	pushl  -0x2c(%ebp)
     f9e:	e8 a5 27 00 00       	call   3748 <close>
    if(total != 12*500){
     fa3:	83 c4 10             	add    $0x10,%esp
     fa6:	81 fe 70 17 00 00    	cmp    $0x1770,%esi
     fac:	75 38                	jne    fe6 <fourfiles+0x1b6>
      printf(1, "wrong length %d\n", total);
      exit();
    }
    unlink(fname);
     fae:	83 ec 0c             	sub    $0xc,%esp
     fb1:	ff 75 d0             	pushl  -0x30(%ebp)
     fb4:	e8 b7 27 00 00       	call   3770 <unlink>
  for(i = 0; i < 2; i++){
     fb9:	83 c3 01             	add    $0x1,%ebx
     fbc:	83 c4 10             	add    $0x10,%esp
     fbf:	83 fb 01             	cmp    $0x1,%ebx
     fc2:	7f 37                	jg     ffb <fourfiles+0x1cb>
    fname = names[i];
     fc4:	8b 44 9d d8          	mov    -0x28(%ebp,%ebx,4),%eax
     fc8:	89 45 d0             	mov    %eax,-0x30(%ebp)
    fd = open(fname, 0);
     fcb:	83 ec 08             	sub    $0x8,%esp
     fce:	6a 00                	push   $0x0
     fd0:	50                   	push   %eax
     fd1:	e8 8a 27 00 00       	call   3760 <open>
     fd6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
     fd9:	83 c4 10             	add    $0x10,%esp
    total = 0;
     fdc:	be 00 00 00 00       	mov    $0x0,%esi
    while((n = read(fd, buf, sizeof(buf))) > 0){
     fe1:	e9 7a ff ff ff       	jmp    f60 <fourfiles+0x130>
      printf(1, "wrong length %d\n", total);
     fe6:	83 ec 04             	sub    $0x4,%esp
     fe9:	56                   	push   %esi
     fea:	68 ad 3f 00 00       	push   $0x3fad
     fef:	6a 01                	push   $0x1
     ff1:	e8 64 28 00 00       	call   385a <printf>
      exit();
     ff6:	e8 25 27 00 00       	call   3720 <exit>
  }

  printf(1, "fourfiles ok\n");
     ffb:	83 ec 08             	sub    $0x8,%esp
     ffe:	68 be 3f 00 00       	push   $0x3fbe
    1003:	6a 01                	push   $0x1
    1005:	e8 50 28 00 00       	call   385a <printf>
}
    100a:	83 c4 10             	add    $0x10,%esp
    100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
    1010:	5b                   	pop    %ebx
    1011:	5e                   	pop    %esi
    1012:	5f                   	pop    %edi
    1013:	5d                   	pop    %ebp
    1014:	c3                   	ret    

00001015 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1015:	55                   	push   %ebp
    1016:	89 e5                	mov    %esp,%ebp
    1018:	56                   	push   %esi
    1019:	53                   	push   %ebx
    101a:	83 ec 28             	sub    $0x28,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    101d:	68 cc 3f 00 00       	push   $0x3fcc
    1022:	6a 01                	push   $0x1
    1024:	e8 31 28 00 00       	call   385a <printf>

  for(pi = 0; pi < 4; pi++){
    1029:	83 c4 10             	add    $0x10,%esp
    102c:	be 00 00 00 00       	mov    $0x0,%esi
    1031:	83 fe 03             	cmp    $0x3,%esi
    1034:	0f 8f be 00 00 00    	jg     10f8 <createdelete+0xe3>
    pid = fork();
    103a:	e8 d9 26 00 00       	call   3718 <fork>
    103f:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
    1041:	85 c0                	test   %eax,%eax
    1043:	78 09                	js     104e <createdelete+0x39>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
    1045:	85 c0                	test   %eax,%eax
    1047:	74 19                	je     1062 <createdelete+0x4d>
  for(pi = 0; pi < 4; pi++){
    1049:	83 c6 01             	add    $0x1,%esi
    104c:	eb e3                	jmp    1031 <createdelete+0x1c>
      printf(1, "fork failed\n");
    104e:	83 ec 08             	sub    $0x8,%esp
    1051:	68 55 4a 00 00       	push   $0x4a55
    1056:	6a 01                	push   $0x1
    1058:	e8 fd 27 00 00       	call   385a <printf>
      exit();
    105d:	e8 be 26 00 00       	call   3720 <exit>
      name[0] = 'p' + pi;
    1062:	8d 46 70             	lea    0x70(%esi),%eax
    1065:	88 45 d8             	mov    %al,-0x28(%ebp)
      name[2] = '\0';
    1068:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
      for(i = 0; i < N; i++){
    106c:	eb 17                	jmp    1085 <createdelete+0x70>
        name[1] = '0' + i;
        fd = open(name, O_CREATE | O_RDWR);
        if(fd < 0){
          printf(1, "create failed\n");
    106e:	83 ec 08             	sub    $0x8,%esp
    1071:	68 1b 42 00 00       	push   $0x421b
    1076:	6a 01                	push   $0x1
    1078:	e8 dd 27 00 00       	call   385a <printf>
          exit();
    107d:	e8 9e 26 00 00       	call   3720 <exit>
      for(i = 0; i < N; i++){
    1082:	83 c3 01             	add    $0x1,%ebx
    1085:	83 fb 13             	cmp    $0x13,%ebx
    1088:	7f 69                	jg     10f3 <createdelete+0xde>
        name[1] = '0' + i;
    108a:	8d 43 30             	lea    0x30(%ebx),%eax
    108d:	88 45 d9             	mov    %al,-0x27(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    1090:	83 ec 08             	sub    $0x8,%esp
    1093:	68 02 02 00 00       	push   $0x202
    1098:	8d 45 d8             	lea    -0x28(%ebp),%eax
    109b:	50                   	push   %eax
    109c:	e8 bf 26 00 00       	call   3760 <open>
        if(fd < 0){
    10a1:	83 c4 10             	add    $0x10,%esp
    10a4:	85 c0                	test   %eax,%eax
    10a6:	78 c6                	js     106e <createdelete+0x59>
        }
        close(fd);
    10a8:	83 ec 0c             	sub    $0xc,%esp
    10ab:	50                   	push   %eax
    10ac:	e8 97 26 00 00       	call   3748 <close>
        if(i > 0 && (i % 2 ) == 0){
    10b1:	83 c4 10             	add    $0x10,%esp
    10b4:	85 db                	test   %ebx,%ebx
    10b6:	7e ca                	jle    1082 <createdelete+0x6d>
    10b8:	f6 c3 01             	test   $0x1,%bl
    10bb:	75 c5                	jne    1082 <createdelete+0x6d>
          name[1] = '0' + (i / 2);
    10bd:	89 d8                	mov    %ebx,%eax
    10bf:	c1 e8 1f             	shr    $0x1f,%eax
    10c2:	01 d8                	add    %ebx,%eax
    10c4:	d1 f8                	sar    %eax
    10c6:	83 c0 30             	add    $0x30,%eax
    10c9:	88 45 d9             	mov    %al,-0x27(%ebp)
          if(unlink(name) < 0){
    10cc:	83 ec 0c             	sub    $0xc,%esp
    10cf:	8d 45 d8             	lea    -0x28(%ebp),%eax
    10d2:	50                   	push   %eax
    10d3:	e8 98 26 00 00       	call   3770 <unlink>
    10d8:	83 c4 10             	add    $0x10,%esp
    10db:	85 c0                	test   %eax,%eax
    10dd:	79 a3                	jns    1082 <createdelete+0x6d>
            printf(1, "unlink failed\n");
    10df:	83 ec 08             	sub    $0x8,%esp
    10e2:	68 cd 3b 00 00       	push   $0x3bcd
    10e7:	6a 01                	push   $0x1
    10e9:	e8 6c 27 00 00       	call   385a <printf>
            exit();
    10ee:	e8 2d 26 00 00       	call   3720 <exit>
          }
        }
      }
      exit();
    10f3:	e8 28 26 00 00       	call   3720 <exit>
    }
  }

  for(pi = 0; pi < 4; pi++){
    10f8:	bb 00 00 00 00       	mov    $0x0,%ebx
    10fd:	eb 08                	jmp    1107 <createdelete+0xf2>
    wait();
    10ff:	e8 24 26 00 00       	call   3728 <wait>
  for(pi = 0; pi < 4; pi++){
    1104:	83 c3 01             	add    $0x1,%ebx
    1107:	83 fb 03             	cmp    $0x3,%ebx
    110a:	7e f3                	jle    10ff <createdelete+0xea>
  }

  name[0] = name[1] = name[2] = 0;
    110c:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
    1110:	c6 45 d9 00          	movb   $0x0,-0x27(%ebp)
    1114:	c6 45 d8 00          	movb   $0x0,-0x28(%ebp)
  for(i = 0; i < N; i++){
    1118:	bb 00 00 00 00       	mov    $0x0,%ebx
    111d:	e9 89 00 00 00       	jmp    11ab <createdelete+0x196>
      name[1] = '0' + i;
      fd = open(name, 0);
      if((i == 0 || i >= N/2) && fd < 0){
        printf(1, "oops createdelete %s didn't exist\n", name);
        exit();
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1122:	8d 53 ff             	lea    -0x1(%ebx),%edx
    1125:	83 fa 08             	cmp    $0x8,%edx
    1128:	76 54                	jbe    117e <createdelete+0x169>
        printf(1, "oops createdelete %s did exist\n", name);
        exit();
      }
      if(fd >= 0)
    112a:	85 c0                	test   %eax,%eax
    112c:	79 6c                	jns    119a <createdelete+0x185>
    for(pi = 0; pi < 4; pi++){
    112e:	83 c6 01             	add    $0x1,%esi
    1131:	83 fe 03             	cmp    $0x3,%esi
    1134:	7f 72                	jg     11a8 <createdelete+0x193>
      name[0] = 'p' + pi;
    1136:	8d 46 70             	lea    0x70(%esi),%eax
    1139:	88 45 d8             	mov    %al,-0x28(%ebp)
      name[1] = '0' + i;
    113c:	8d 43 30             	lea    0x30(%ebx),%eax
    113f:	88 45 d9             	mov    %al,-0x27(%ebp)
      fd = open(name, 0);
    1142:	83 ec 08             	sub    $0x8,%esp
    1145:	6a 00                	push   $0x0
    1147:	8d 45 d8             	lea    -0x28(%ebp),%eax
    114a:	50                   	push   %eax
    114b:	e8 10 26 00 00       	call   3760 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1150:	83 c4 10             	add    $0x10,%esp
    1153:	85 db                	test   %ebx,%ebx
    1155:	0f 94 c1             	sete   %cl
    1158:	83 fb 09             	cmp    $0x9,%ebx
    115b:	0f 9f c2             	setg   %dl
    115e:	08 d1                	or     %dl,%cl
    1160:	74 c0                	je     1122 <createdelete+0x10d>
    1162:	85 c0                	test   %eax,%eax
    1164:	79 bc                	jns    1122 <createdelete+0x10d>
        printf(1, "oops createdelete %s didn't exist\n", name);
    1166:	83 ec 04             	sub    $0x4,%esp
    1169:	8d 45 d8             	lea    -0x28(%ebp),%eax
    116c:	50                   	push   %eax
    116d:	68 8c 4c 00 00       	push   $0x4c8c
    1172:	6a 01                	push   $0x1
    1174:	e8 e1 26 00 00       	call   385a <printf>
        exit();
    1179:	e8 a2 25 00 00       	call   3720 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    117e:	85 c0                	test   %eax,%eax
    1180:	78 a8                	js     112a <createdelete+0x115>
        printf(1, "oops createdelete %s did exist\n", name);
    1182:	83 ec 04             	sub    $0x4,%esp
    1185:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1188:	50                   	push   %eax
    1189:	68 b0 4c 00 00       	push   $0x4cb0
    118e:	6a 01                	push   $0x1
    1190:	e8 c5 26 00 00       	call   385a <printf>
        exit();
    1195:	e8 86 25 00 00       	call   3720 <exit>
        close(fd);
    119a:	83 ec 0c             	sub    $0xc,%esp
    119d:	50                   	push   %eax
    119e:	e8 a5 25 00 00       	call   3748 <close>
    11a3:	83 c4 10             	add    $0x10,%esp
    11a6:	eb 86                	jmp    112e <createdelete+0x119>
  for(i = 0; i < N; i++){
    11a8:	83 c3 01             	add    $0x1,%ebx
    11ab:	83 fb 13             	cmp    $0x13,%ebx
    11ae:	7f 0a                	jg     11ba <createdelete+0x1a5>
    for(pi = 0; pi < 4; pi++){
    11b0:	be 00 00 00 00       	mov    $0x0,%esi
    11b5:	e9 77 ff ff ff       	jmp    1131 <createdelete+0x11c>
    }
  }

  for(i = 0; i < N; i++){
    11ba:	be 00 00 00 00       	mov    $0x0,%esi
    11bf:	eb 26                	jmp    11e7 <createdelete+0x1d2>
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + i;
    11c1:	8d 46 70             	lea    0x70(%esi),%eax
    11c4:	88 45 d8             	mov    %al,-0x28(%ebp)
      name[1] = '0' + i;
    11c7:	8d 46 30             	lea    0x30(%esi),%eax
    11ca:	88 45 d9             	mov    %al,-0x27(%ebp)
      unlink(name);
    11cd:	83 ec 0c             	sub    $0xc,%esp
    11d0:	8d 45 d8             	lea    -0x28(%ebp),%eax
    11d3:	50                   	push   %eax
    11d4:	e8 97 25 00 00       	call   3770 <unlink>
    for(pi = 0; pi < 4; pi++){
    11d9:	83 c3 01             	add    $0x1,%ebx
    11dc:	83 c4 10             	add    $0x10,%esp
    11df:	83 fb 03             	cmp    $0x3,%ebx
    11e2:	7e dd                	jle    11c1 <createdelete+0x1ac>
  for(i = 0; i < N; i++){
    11e4:	83 c6 01             	add    $0x1,%esi
    11e7:	83 fe 13             	cmp    $0x13,%esi
    11ea:	7f 07                	jg     11f3 <createdelete+0x1de>
    for(pi = 0; pi < 4; pi++){
    11ec:	bb 00 00 00 00       	mov    $0x0,%ebx
    11f1:	eb ec                	jmp    11df <createdelete+0x1ca>
    }
  }

  printf(1, "createdelete ok\n");
    11f3:	83 ec 08             	sub    $0x8,%esp
    11f6:	68 df 3f 00 00       	push   $0x3fdf
    11fb:	6a 01                	push   $0x1
    11fd:	e8 58 26 00 00       	call   385a <printf>
}
    1202:	83 c4 10             	add    $0x10,%esp
    1205:	8d 65 f8             	lea    -0x8(%ebp),%esp
    1208:	5b                   	pop    %ebx
    1209:	5e                   	pop    %esi
    120a:	5d                   	pop    %ebp
    120b:	c3                   	ret    

0000120c <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    120c:	55                   	push   %ebp
    120d:	89 e5                	mov    %esp,%ebp
    120f:	56                   	push   %esi
    1210:	53                   	push   %ebx
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1211:	83 ec 08             	sub    $0x8,%esp
    1214:	68 f0 3f 00 00       	push   $0x3ff0
    1219:	6a 01                	push   $0x1
    121b:	e8 3a 26 00 00       	call   385a <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1220:	83 c4 08             	add    $0x8,%esp
    1223:	68 02 02 00 00       	push   $0x202
    1228:	68 01 40 00 00       	push   $0x4001
    122d:	e8 2e 25 00 00       	call   3760 <open>
  if(fd < 0){
    1232:	83 c4 10             	add    $0x10,%esp
    1235:	85 c0                	test   %eax,%eax
    1237:	0f 88 f0 00 00 00    	js     132d <unlinkread+0x121>
    123d:	89 c3                	mov    %eax,%ebx
    printf(1, "create unlinkread failed\n");
    exit();
  }
  write(fd, "hello", 5);
    123f:	83 ec 04             	sub    $0x4,%esp
    1242:	6a 05                	push   $0x5
    1244:	68 26 40 00 00       	push   $0x4026
    1249:	50                   	push   %eax
    124a:	e8 f1 24 00 00       	call   3740 <write>
  close(fd);
    124f:	89 1c 24             	mov    %ebx,(%esp)
    1252:	e8 f1 24 00 00       	call   3748 <close>

  fd = open("unlinkread", O_RDWR);
    1257:	83 c4 08             	add    $0x8,%esp
    125a:	6a 02                	push   $0x2
    125c:	68 01 40 00 00       	push   $0x4001
    1261:	e8 fa 24 00 00       	call   3760 <open>
    1266:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1268:	83 c4 10             	add    $0x10,%esp
    126b:	85 c0                	test   %eax,%eax
    126d:	0f 88 ce 00 00 00    	js     1341 <unlinkread+0x135>
    printf(1, "open unlinkread failed\n");
    exit();
  }
  if(unlink("unlinkread") != 0){
    1273:	83 ec 0c             	sub    $0xc,%esp
    1276:	68 01 40 00 00       	push   $0x4001
    127b:	e8 f0 24 00 00       	call   3770 <unlink>
    1280:	83 c4 10             	add    $0x10,%esp
    1283:	85 c0                	test   %eax,%eax
    1285:	0f 85 ca 00 00 00    	jne    1355 <unlinkread+0x149>
    printf(1, "unlink unlinkread failed\n");
    exit();
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    128b:	83 ec 08             	sub    $0x8,%esp
    128e:	68 02 02 00 00       	push   $0x202
    1293:	68 01 40 00 00       	push   $0x4001
    1298:	e8 c3 24 00 00       	call   3760 <open>
    129d:	89 c6                	mov    %eax,%esi
  write(fd1, "yyy", 3);
    129f:	83 c4 0c             	add    $0xc,%esp
    12a2:	6a 03                	push   $0x3
    12a4:	68 5e 40 00 00       	push   $0x405e
    12a9:	50                   	push   %eax
    12aa:	e8 91 24 00 00       	call   3740 <write>
  close(fd1);
    12af:	89 34 24             	mov    %esi,(%esp)
    12b2:	e8 91 24 00 00       	call   3748 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    12b7:	83 c4 0c             	add    $0xc,%esp
    12ba:	68 00 20 00 00       	push   $0x2000
    12bf:	68 40 83 00 00       	push   $0x8340
    12c4:	53                   	push   %ebx
    12c5:	e8 6e 24 00 00       	call   3738 <read>
    12ca:	83 c4 10             	add    $0x10,%esp
    12cd:	83 f8 05             	cmp    $0x5,%eax
    12d0:	0f 85 93 00 00 00    	jne    1369 <unlinkread+0x15d>
    printf(1, "unlinkread read failed");
    exit();
  }
  if(buf[0] != 'h'){
    12d6:	80 3d 40 83 00 00 68 	cmpb   $0x68,0x8340
    12dd:	0f 85 9a 00 00 00    	jne    137d <unlinkread+0x171>
    printf(1, "unlinkread wrong data\n");
    exit();
  }
  if(write(fd, buf, 10) != 10){
    12e3:	83 ec 04             	sub    $0x4,%esp
    12e6:	6a 0a                	push   $0xa
    12e8:	68 40 83 00 00       	push   $0x8340
    12ed:	53                   	push   %ebx
    12ee:	e8 4d 24 00 00       	call   3740 <write>
    12f3:	83 c4 10             	add    $0x10,%esp
    12f6:	83 f8 0a             	cmp    $0xa,%eax
    12f9:	0f 85 92 00 00 00    	jne    1391 <unlinkread+0x185>
    printf(1, "unlinkread write failed\n");
    exit();
  }
  close(fd);
    12ff:	83 ec 0c             	sub    $0xc,%esp
    1302:	53                   	push   %ebx
    1303:	e8 40 24 00 00       	call   3748 <close>
  unlink("unlinkread");
    1308:	c7 04 24 01 40 00 00 	movl   $0x4001,(%esp)
    130f:	e8 5c 24 00 00       	call   3770 <unlink>
  printf(1, "unlinkread ok\n");
    1314:	83 c4 08             	add    $0x8,%esp
    1317:	68 a9 40 00 00       	push   $0x40a9
    131c:	6a 01                	push   $0x1
    131e:	e8 37 25 00 00       	call   385a <printf>
}
    1323:	83 c4 10             	add    $0x10,%esp
    1326:	8d 65 f8             	lea    -0x8(%ebp),%esp
    1329:	5b                   	pop    %ebx
    132a:	5e                   	pop    %esi
    132b:	5d                   	pop    %ebp
    132c:	c3                   	ret    
    printf(1, "create unlinkread failed\n");
    132d:	83 ec 08             	sub    $0x8,%esp
    1330:	68 0c 40 00 00       	push   $0x400c
    1335:	6a 01                	push   $0x1
    1337:	e8 1e 25 00 00       	call   385a <printf>
    exit();
    133c:	e8 df 23 00 00       	call   3720 <exit>
    printf(1, "open unlinkread failed\n");
    1341:	83 ec 08             	sub    $0x8,%esp
    1344:	68 2c 40 00 00       	push   $0x402c
    1349:	6a 01                	push   $0x1
    134b:	e8 0a 25 00 00       	call   385a <printf>
    exit();
    1350:	e8 cb 23 00 00       	call   3720 <exit>
    printf(1, "unlink unlinkread failed\n");
    1355:	83 ec 08             	sub    $0x8,%esp
    1358:	68 44 40 00 00       	push   $0x4044
    135d:	6a 01                	push   $0x1
    135f:	e8 f6 24 00 00       	call   385a <printf>
    exit();
    1364:	e8 b7 23 00 00       	call   3720 <exit>
    printf(1, "unlinkread read failed");
    1369:	83 ec 08             	sub    $0x8,%esp
    136c:	68 62 40 00 00       	push   $0x4062
    1371:	6a 01                	push   $0x1
    1373:	e8 e2 24 00 00       	call   385a <printf>
    exit();
    1378:	e8 a3 23 00 00       	call   3720 <exit>
    printf(1, "unlinkread wrong data\n");
    137d:	83 ec 08             	sub    $0x8,%esp
    1380:	68 79 40 00 00       	push   $0x4079
    1385:	6a 01                	push   $0x1
    1387:	e8 ce 24 00 00       	call   385a <printf>
    exit();
    138c:	e8 8f 23 00 00       	call   3720 <exit>
    printf(1, "unlinkread write failed\n");
    1391:	83 ec 08             	sub    $0x8,%esp
    1394:	68 90 40 00 00       	push   $0x4090
    1399:	6a 01                	push   $0x1
    139b:	e8 ba 24 00 00       	call   385a <printf>
    exit();
    13a0:	e8 7b 23 00 00       	call   3720 <exit>

000013a5 <linktest>:

void
linktest(void)
{
    13a5:	55                   	push   %ebp
    13a6:	89 e5                	mov    %esp,%ebp
    13a8:	53                   	push   %ebx
    13a9:	83 ec 0c             	sub    $0xc,%esp
  int fd;

  printf(1, "linktest\n");
    13ac:	68 b8 40 00 00       	push   $0x40b8
    13b1:	6a 01                	push   $0x1
    13b3:	e8 a2 24 00 00       	call   385a <printf>

  unlink("lf1");
    13b8:	c7 04 24 c2 40 00 00 	movl   $0x40c2,(%esp)
    13bf:	e8 ac 23 00 00       	call   3770 <unlink>
  unlink("lf2");
    13c4:	c7 04 24 c6 40 00 00 	movl   $0x40c6,(%esp)
    13cb:	e8 a0 23 00 00       	call   3770 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    13d0:	83 c4 08             	add    $0x8,%esp
    13d3:	68 02 02 00 00       	push   $0x202
    13d8:	68 c2 40 00 00       	push   $0x40c2
    13dd:	e8 7e 23 00 00       	call   3760 <open>
  if(fd < 0){
    13e2:	83 c4 10             	add    $0x10,%esp
    13e5:	85 c0                	test   %eax,%eax
    13e7:	0f 88 2a 01 00 00    	js     1517 <linktest+0x172>
    13ed:	89 c3                	mov    %eax,%ebx
    printf(1, "create lf1 failed\n");
    exit();
  }
  if(write(fd, "hello", 5) != 5){
    13ef:	83 ec 04             	sub    $0x4,%esp
    13f2:	6a 05                	push   $0x5
    13f4:	68 26 40 00 00       	push   $0x4026
    13f9:	50                   	push   %eax
    13fa:	e8 41 23 00 00       	call   3740 <write>
    13ff:	83 c4 10             	add    $0x10,%esp
    1402:	83 f8 05             	cmp    $0x5,%eax
    1405:	0f 85 20 01 00 00    	jne    152b <linktest+0x186>
    printf(1, "write lf1 failed\n");
    exit();
  }
  close(fd);
    140b:	83 ec 0c             	sub    $0xc,%esp
    140e:	53                   	push   %ebx
    140f:	e8 34 23 00 00       	call   3748 <close>

  if(link("lf1", "lf2") < 0){
    1414:	83 c4 08             	add    $0x8,%esp
    1417:	68 c6 40 00 00       	push   $0x40c6
    141c:	68 c2 40 00 00       	push   $0x40c2
    1421:	e8 5a 23 00 00       	call   3780 <link>
    1426:	83 c4 10             	add    $0x10,%esp
    1429:	85 c0                	test   %eax,%eax
    142b:	0f 88 0e 01 00 00    	js     153f <linktest+0x19a>
    printf(1, "link lf1 lf2 failed\n");
    exit();
  }
  unlink("lf1");
    1431:	83 ec 0c             	sub    $0xc,%esp
    1434:	68 c2 40 00 00       	push   $0x40c2
    1439:	e8 32 23 00 00       	call   3770 <unlink>

  if(open("lf1", 0) >= 0){
    143e:	83 c4 08             	add    $0x8,%esp
    1441:	6a 00                	push   $0x0
    1443:	68 c2 40 00 00       	push   $0x40c2
    1448:	e8 13 23 00 00       	call   3760 <open>
    144d:	83 c4 10             	add    $0x10,%esp
    1450:	85 c0                	test   %eax,%eax
    1452:	0f 89 fb 00 00 00    	jns    1553 <linktest+0x1ae>
    printf(1, "unlinked lf1 but it is still there!\n");
    exit();
  }

  fd = open("lf2", 0);
    1458:	83 ec 08             	sub    $0x8,%esp
    145b:	6a 00                	push   $0x0
    145d:	68 c6 40 00 00       	push   $0x40c6
    1462:	e8 f9 22 00 00       	call   3760 <open>
    1467:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1469:	83 c4 10             	add    $0x10,%esp
    146c:	85 c0                	test   %eax,%eax
    146e:	0f 88 f3 00 00 00    	js     1567 <linktest+0x1c2>
    printf(1, "open lf2 failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1474:	83 ec 04             	sub    $0x4,%esp
    1477:	68 00 20 00 00       	push   $0x2000
    147c:	68 40 83 00 00       	push   $0x8340
    1481:	50                   	push   %eax
    1482:	e8 b1 22 00 00       	call   3738 <read>
    1487:	83 c4 10             	add    $0x10,%esp
    148a:	83 f8 05             	cmp    $0x5,%eax
    148d:	0f 85 e8 00 00 00    	jne    157b <linktest+0x1d6>
    printf(1, "read lf2 failed\n");
    exit();
  }
  close(fd);
    1493:	83 ec 0c             	sub    $0xc,%esp
    1496:	53                   	push   %ebx
    1497:	e8 ac 22 00 00       	call   3748 <close>

  if(link("lf2", "lf2") >= 0){
    149c:	83 c4 08             	add    $0x8,%esp
    149f:	68 c6 40 00 00       	push   $0x40c6
    14a4:	68 c6 40 00 00       	push   $0x40c6
    14a9:	e8 d2 22 00 00       	call   3780 <link>
    14ae:	83 c4 10             	add    $0x10,%esp
    14b1:	85 c0                	test   %eax,%eax
    14b3:	0f 89 d6 00 00 00    	jns    158f <linktest+0x1ea>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    exit();
  }

  unlink("lf2");
    14b9:	83 ec 0c             	sub    $0xc,%esp
    14bc:	68 c6 40 00 00       	push   $0x40c6
    14c1:	e8 aa 22 00 00       	call   3770 <unlink>
  if(link("lf2", "lf1") >= 0){
    14c6:	83 c4 08             	add    $0x8,%esp
    14c9:	68 c2 40 00 00       	push   $0x40c2
    14ce:	68 c6 40 00 00       	push   $0x40c6
    14d3:	e8 a8 22 00 00       	call   3780 <link>
    14d8:	83 c4 10             	add    $0x10,%esp
    14db:	85 c0                	test   %eax,%eax
    14dd:	0f 89 c0 00 00 00    	jns    15a3 <linktest+0x1fe>
    printf(1, "link non-existant succeeded! oops\n");
    exit();
  }

  if(link(".", "lf1") >= 0){
    14e3:	83 ec 08             	sub    $0x8,%esp
    14e6:	68 c2 40 00 00       	push   $0x40c2
    14eb:	68 8a 43 00 00       	push   $0x438a
    14f0:	e8 8b 22 00 00       	call   3780 <link>
    14f5:	83 c4 10             	add    $0x10,%esp
    14f8:	85 c0                	test   %eax,%eax
    14fa:	0f 89 b7 00 00 00    	jns    15b7 <linktest+0x212>
    printf(1, "link . lf1 succeeded! oops\n");
    exit();
  }

  printf(1, "linktest ok\n");
    1500:	83 ec 08             	sub    $0x8,%esp
    1503:	68 60 41 00 00       	push   $0x4160
    1508:	6a 01                	push   $0x1
    150a:	e8 4b 23 00 00       	call   385a <printf>
}
    150f:	83 c4 10             	add    $0x10,%esp
    1512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1515:	c9                   	leave  
    1516:	c3                   	ret    
    printf(1, "create lf1 failed\n");
    1517:	83 ec 08             	sub    $0x8,%esp
    151a:	68 ca 40 00 00       	push   $0x40ca
    151f:	6a 01                	push   $0x1
    1521:	e8 34 23 00 00       	call   385a <printf>
    exit();
    1526:	e8 f5 21 00 00       	call   3720 <exit>
    printf(1, "write lf1 failed\n");
    152b:	83 ec 08             	sub    $0x8,%esp
    152e:	68 dd 40 00 00       	push   $0x40dd
    1533:	6a 01                	push   $0x1
    1535:	e8 20 23 00 00       	call   385a <printf>
    exit();
    153a:	e8 e1 21 00 00       	call   3720 <exit>
    printf(1, "link lf1 lf2 failed\n");
    153f:	83 ec 08             	sub    $0x8,%esp
    1542:	68 ef 40 00 00       	push   $0x40ef
    1547:	6a 01                	push   $0x1
    1549:	e8 0c 23 00 00       	call   385a <printf>
    exit();
    154e:	e8 cd 21 00 00       	call   3720 <exit>
    printf(1, "unlinked lf1 but it is still there!\n");
    1553:	83 ec 08             	sub    $0x8,%esp
    1556:	68 d0 4c 00 00       	push   $0x4cd0
    155b:	6a 01                	push   $0x1
    155d:	e8 f8 22 00 00       	call   385a <printf>
    exit();
    1562:	e8 b9 21 00 00       	call   3720 <exit>
    printf(1, "open lf2 failed\n");
    1567:	83 ec 08             	sub    $0x8,%esp
    156a:	68 04 41 00 00       	push   $0x4104
    156f:	6a 01                	push   $0x1
    1571:	e8 e4 22 00 00       	call   385a <printf>
    exit();
    1576:	e8 a5 21 00 00       	call   3720 <exit>
    printf(1, "read lf2 failed\n");
    157b:	83 ec 08             	sub    $0x8,%esp
    157e:	68 15 41 00 00       	push   $0x4115
    1583:	6a 01                	push   $0x1
    1585:	e8 d0 22 00 00       	call   385a <printf>
    exit();
    158a:	e8 91 21 00 00       	call   3720 <exit>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    158f:	83 ec 08             	sub    $0x8,%esp
    1592:	68 26 41 00 00       	push   $0x4126
    1597:	6a 01                	push   $0x1
    1599:	e8 bc 22 00 00       	call   385a <printf>
    exit();
    159e:	e8 7d 21 00 00       	call   3720 <exit>
    printf(1, "link non-existant succeeded! oops\n");
    15a3:	83 ec 08             	sub    $0x8,%esp
    15a6:	68 f8 4c 00 00       	push   $0x4cf8
    15ab:	6a 01                	push   $0x1
    15ad:	e8 a8 22 00 00       	call   385a <printf>
    exit();
    15b2:	e8 69 21 00 00       	call   3720 <exit>
    printf(1, "link . lf1 succeeded! oops\n");
    15b7:	83 ec 08             	sub    $0x8,%esp
    15ba:	68 44 41 00 00       	push   $0x4144
    15bf:	6a 01                	push   $0x1
    15c1:	e8 94 22 00 00       	call   385a <printf>
    exit();
    15c6:	e8 55 21 00 00       	call   3720 <exit>

000015cb <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    15cb:	55                   	push   %ebp
    15cc:	89 e5                	mov    %esp,%ebp
    15ce:	57                   	push   %edi
    15cf:	56                   	push   %esi
    15d0:	53                   	push   %ebx
    15d1:	83 ec 54             	sub    $0x54,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    15d4:	68 6d 41 00 00       	push   $0x416d
    15d9:	6a 01                	push   $0x1
    15db:	e8 7a 22 00 00       	call   385a <printf>
  file[0] = 'C';
    15e0:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    15e4:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    15e8:	83 c4 10             	add    $0x10,%esp
    15eb:	bb 00 00 00 00       	mov    $0x0,%ebx
    15f0:	eb 5e                	jmp    1650 <concreate+0x85>
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    if(pid && (i % 3) == 1){
      link("C0", file);
    } else if(pid == 0 && (i % 5) == 1){
    15f2:	85 f6                	test   %esi,%esi
    15f4:	75 22                	jne    1618 <concreate+0x4d>
    15f6:	ba 67 66 66 66       	mov    $0x66666667,%edx
    15fb:	89 d8                	mov    %ebx,%eax
    15fd:	f7 ea                	imul   %edx
    15ff:	d1 fa                	sar    %edx
    1601:	89 d8                	mov    %ebx,%eax
    1603:	c1 f8 1f             	sar    $0x1f,%eax
    1606:	29 c2                	sub    %eax,%edx
    1608:	8d 04 92             	lea    (%edx,%edx,4),%eax
    160b:	89 da                	mov    %ebx,%edx
    160d:	29 c2                	sub    %eax,%edx
    160f:	83 fa 01             	cmp    $0x1,%edx
    1612:	0f 84 9b 00 00 00    	je     16b3 <concreate+0xe8>
      link("C0", file);
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1618:	83 ec 08             	sub    $0x8,%esp
    161b:	68 02 02 00 00       	push   $0x202
    1620:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1623:	50                   	push   %eax
    1624:	e8 37 21 00 00       	call   3760 <open>
      if(fd < 0){
    1629:	83 c4 10             	add    $0x10,%esp
    162c:	85 c0                	test   %eax,%eax
    162e:	0f 88 98 00 00 00    	js     16cc <concreate+0x101>
        printf(1, "concreate create %s failed\n", file);
        exit();
      }
      close(fd);
    1634:	83 ec 0c             	sub    $0xc,%esp
    1637:	50                   	push   %eax
    1638:	e8 0b 21 00 00       	call   3748 <close>
    163d:	83 c4 10             	add    $0x10,%esp
    }
    if(pid == 0)
    1640:	85 f6                	test   %esi,%esi
    1642:	0f 84 9c 00 00 00    	je     16e4 <concreate+0x119>
      exit();
    else
      wait();
    1648:	e8 db 20 00 00       	call   3728 <wait>
  for(i = 0; i < 40; i++){
    164d:	83 c3 01             	add    $0x1,%ebx
    1650:	83 fb 27             	cmp    $0x27,%ebx
    1653:	0f 8f 90 00 00 00    	jg     16e9 <concreate+0x11e>
    file[1] = '0' + i;
    1659:	8d 43 30             	lea    0x30(%ebx),%eax
    165c:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    165f:	83 ec 0c             	sub    $0xc,%esp
    1662:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1665:	50                   	push   %eax
    1666:	e8 05 21 00 00       	call   3770 <unlink>
    pid = fork();
    166b:	e8 a8 20 00 00       	call   3718 <fork>
    1670:	89 c6                	mov    %eax,%esi
    if(pid && (i % 3) == 1){
    1672:	83 c4 10             	add    $0x10,%esp
    1675:	85 c0                	test   %eax,%eax
    1677:	0f 84 75 ff ff ff    	je     15f2 <concreate+0x27>
    167d:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1682:	89 d8                	mov    %ebx,%eax
    1684:	f7 ea                	imul   %edx
    1686:	89 d8                	mov    %ebx,%eax
    1688:	c1 f8 1f             	sar    $0x1f,%eax
    168b:	29 c2                	sub    %eax,%edx
    168d:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1690:	89 da                	mov    %ebx,%edx
    1692:	29 c2                	sub    %eax,%edx
    1694:	83 fa 01             	cmp    $0x1,%edx
    1697:	0f 85 55 ff ff ff    	jne    15f2 <concreate+0x27>
      link("C0", file);
    169d:	83 ec 08             	sub    $0x8,%esp
    16a0:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16a3:	50                   	push   %eax
    16a4:	68 7d 41 00 00       	push   $0x417d
    16a9:	e8 d2 20 00 00       	call   3780 <link>
    16ae:	83 c4 10             	add    $0x10,%esp
    16b1:	eb 8d                	jmp    1640 <concreate+0x75>
      link("C0", file);
    16b3:	83 ec 08             	sub    $0x8,%esp
    16b6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16b9:	50                   	push   %eax
    16ba:	68 7d 41 00 00       	push   $0x417d
    16bf:	e8 bc 20 00 00       	call   3780 <link>
    16c4:	83 c4 10             	add    $0x10,%esp
    16c7:	e9 74 ff ff ff       	jmp    1640 <concreate+0x75>
        printf(1, "concreate create %s failed\n", file);
    16cc:	83 ec 04             	sub    $0x4,%esp
    16cf:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16d2:	50                   	push   %eax
    16d3:	68 80 41 00 00       	push   $0x4180
    16d8:	6a 01                	push   $0x1
    16da:	e8 7b 21 00 00       	call   385a <printf>
        exit();
    16df:	e8 3c 20 00 00       	call   3720 <exit>
      exit();
    16e4:	e8 37 20 00 00       	call   3720 <exit>
  }

  memset(fa, 0, sizeof(fa));
    16e9:	83 ec 04             	sub    $0x4,%esp
    16ec:	6a 28                	push   $0x28
    16ee:	6a 00                	push   $0x0
    16f0:	8d 45 bd             	lea    -0x43(%ebp),%eax
    16f3:	50                   	push   %eax
    16f4:	e8 f8 1e 00 00       	call   35f1 <memset>
  fd = open(".", 0);
    16f9:	83 c4 08             	add    $0x8,%esp
    16fc:	6a 00                	push   $0x0
    16fe:	68 8a 43 00 00       	push   $0x438a
    1703:	e8 58 20 00 00       	call   3760 <open>
    1708:	89 c3                	mov    %eax,%ebx
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    170a:	83 c4 10             	add    $0x10,%esp
  n = 0;
    170d:	be 00 00 00 00       	mov    $0x0,%esi
  while(read(fd, &de, sizeof(de)) > 0){
    1712:	83 ec 04             	sub    $0x4,%esp
    1715:	6a 10                	push   $0x10
    1717:	8d 45 ac             	lea    -0x54(%ebp),%eax
    171a:	50                   	push   %eax
    171b:	53                   	push   %ebx
    171c:	e8 17 20 00 00       	call   3738 <read>
    1721:	83 c4 10             	add    $0x10,%esp
    1724:	85 c0                	test   %eax,%eax
    1726:	7e 60                	jle    1788 <concreate+0x1bd>
    if(de.inum == 0)
    1728:	66 83 7d ac 00       	cmpw   $0x0,-0x54(%ebp)
    172d:	74 e3                	je     1712 <concreate+0x147>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    172f:	80 7d ae 43          	cmpb   $0x43,-0x52(%ebp)
    1733:	75 dd                	jne    1712 <concreate+0x147>
    1735:	80 7d b0 00          	cmpb   $0x0,-0x50(%ebp)
    1739:	75 d7                	jne    1712 <concreate+0x147>
      i = de.name[1] - '0';
    173b:	0f be 45 af          	movsbl -0x51(%ebp),%eax
    173f:	83 e8 30             	sub    $0x30,%eax
      if(i < 0 || i >= sizeof(fa)){
    1742:	83 f8 27             	cmp    $0x27,%eax
    1745:	77 11                	ja     1758 <concreate+0x18d>
        printf(1, "concreate weird file %s\n", de.name);
        exit();
      }
      if(fa[i]){
    1747:	80 7c 05 bd 00       	cmpb   $0x0,-0x43(%ebp,%eax,1)
    174c:	75 22                	jne    1770 <concreate+0x1a5>
        printf(1, "concreate duplicate file %s\n", de.name);
        exit();
      }
      fa[i] = 1;
    174e:	c6 44 05 bd 01       	movb   $0x1,-0x43(%ebp,%eax,1)
      n++;
    1753:	83 c6 01             	add    $0x1,%esi
    1756:	eb ba                	jmp    1712 <concreate+0x147>
        printf(1, "concreate weird file %s\n", de.name);
    1758:	83 ec 04             	sub    $0x4,%esp
    175b:	8d 45 ae             	lea    -0x52(%ebp),%eax
    175e:	50                   	push   %eax
    175f:	68 9c 41 00 00       	push   $0x419c
    1764:	6a 01                	push   $0x1
    1766:	e8 ef 20 00 00       	call   385a <printf>
        exit();
    176b:	e8 b0 1f 00 00       	call   3720 <exit>
        printf(1, "concreate duplicate file %s\n", de.name);
    1770:	83 ec 04             	sub    $0x4,%esp
    1773:	8d 45 ae             	lea    -0x52(%ebp),%eax
    1776:	50                   	push   %eax
    1777:	68 b5 41 00 00       	push   $0x41b5
    177c:	6a 01                	push   $0x1
    177e:	e8 d7 20 00 00       	call   385a <printf>
        exit();
    1783:	e8 98 1f 00 00       	call   3720 <exit>
    }
  }
  close(fd);
    1788:	83 ec 0c             	sub    $0xc,%esp
    178b:	53                   	push   %ebx
    178c:	e8 b7 1f 00 00       	call   3748 <close>

  if(n != 40){
    1791:	83 c4 10             	add    $0x10,%esp
    1794:	83 fe 28             	cmp    $0x28,%esi
    1797:	75 0a                	jne    17a3 <concreate+0x1d8>
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1799:	bb 00 00 00 00       	mov    $0x0,%ebx
    179e:	e9 86 00 00 00       	jmp    1829 <concreate+0x25e>
    printf(1, "concreate not enough files in directory listing\n");
    17a3:	83 ec 08             	sub    $0x8,%esp
    17a6:	68 1c 4d 00 00       	push   $0x4d1c
    17ab:	6a 01                	push   $0x1
    17ad:	e8 a8 20 00 00       	call   385a <printf>
    exit();
    17b2:	e8 69 1f 00 00       	call   3720 <exit>
    file[1] = '0' + i;
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
    17b7:	83 ec 08             	sub    $0x8,%esp
    17ba:	68 55 4a 00 00       	push   $0x4a55
    17bf:	6a 01                	push   $0x1
    17c1:	e8 94 20 00 00       	call   385a <printf>
      exit();
    17c6:	e8 55 1f 00 00       	call   3720 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
       ((i % 3) == 1 && pid != 0)){
      close(open(file, 0));
    17cb:	83 ec 08             	sub    $0x8,%esp
    17ce:	6a 00                	push   $0x0
    17d0:	8d 7d e5             	lea    -0x1b(%ebp),%edi
    17d3:	57                   	push   %edi
    17d4:	e8 87 1f 00 00       	call   3760 <open>
    17d9:	89 04 24             	mov    %eax,(%esp)
    17dc:	e8 67 1f 00 00       	call   3748 <close>
      close(open(file, 0));
    17e1:	83 c4 08             	add    $0x8,%esp
    17e4:	6a 00                	push   $0x0
    17e6:	57                   	push   %edi
    17e7:	e8 74 1f 00 00       	call   3760 <open>
    17ec:	89 04 24             	mov    %eax,(%esp)
    17ef:	e8 54 1f 00 00       	call   3748 <close>
      close(open(file, 0));
    17f4:	83 c4 08             	add    $0x8,%esp
    17f7:	6a 00                	push   $0x0
    17f9:	57                   	push   %edi
    17fa:	e8 61 1f 00 00       	call   3760 <open>
    17ff:	89 04 24             	mov    %eax,(%esp)
    1802:	e8 41 1f 00 00       	call   3748 <close>
      close(open(file, 0));
    1807:	83 c4 08             	add    $0x8,%esp
    180a:	6a 00                	push   $0x0
    180c:	57                   	push   %edi
    180d:	e8 4e 1f 00 00       	call   3760 <open>
    1812:	89 04 24             	mov    %eax,(%esp)
    1815:	e8 2e 1f 00 00       	call   3748 <close>
    181a:	83 c4 10             	add    $0x10,%esp
      unlink(file);
      unlink(file);
      unlink(file);
      unlink(file);
    }
    if(pid == 0)
    181d:	85 f6                	test   %esi,%esi
    181f:	74 79                	je     189a <concreate+0x2cf>
      exit();
    else
      wait();
    1821:	e8 02 1f 00 00       	call   3728 <wait>
  for(i = 0; i < 40; i++){
    1826:	83 c3 01             	add    $0x1,%ebx
    1829:	83 fb 27             	cmp    $0x27,%ebx
    182c:	7f 71                	jg     189f <concreate+0x2d4>
    file[1] = '0' + i;
    182e:	8d 43 30             	lea    0x30(%ebx),%eax
    1831:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1834:	e8 df 1e 00 00       	call   3718 <fork>
    1839:	89 c6                	mov    %eax,%esi
    if(pid < 0){
    183b:	85 c0                	test   %eax,%eax
    183d:	0f 88 74 ff ff ff    	js     17b7 <concreate+0x1ec>
    if(((i % 3) == 0 && pid == 0) ||
    1843:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1848:	89 d8                	mov    %ebx,%eax
    184a:	f7 ea                	imul   %edx
    184c:	89 d8                	mov    %ebx,%eax
    184e:	c1 f8 1f             	sar    $0x1f,%eax
    1851:	29 c2                	sub    %eax,%edx
    1853:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1856:	89 da                	mov    %ebx,%edx
    1858:	29 c2                	sub    %eax,%edx
    185a:	89 d0                	mov    %edx,%eax
    185c:	09 f0                	or     %esi,%eax
    185e:	0f 84 67 ff ff ff    	je     17cb <concreate+0x200>
    1864:	83 fa 01             	cmp    $0x1,%edx
    1867:	75 08                	jne    1871 <concreate+0x2a6>
       ((i % 3) == 1 && pid != 0)){
    1869:	85 f6                	test   %esi,%esi
    186b:	0f 85 5a ff ff ff    	jne    17cb <concreate+0x200>
      unlink(file);
    1871:	83 ec 0c             	sub    $0xc,%esp
    1874:	8d 7d e5             	lea    -0x1b(%ebp),%edi
    1877:	57                   	push   %edi
    1878:	e8 f3 1e 00 00       	call   3770 <unlink>
      unlink(file);
    187d:	89 3c 24             	mov    %edi,(%esp)
    1880:	e8 eb 1e 00 00       	call   3770 <unlink>
      unlink(file);
    1885:	89 3c 24             	mov    %edi,(%esp)
    1888:	e8 e3 1e 00 00       	call   3770 <unlink>
      unlink(file);
    188d:	89 3c 24             	mov    %edi,(%esp)
    1890:	e8 db 1e 00 00       	call   3770 <unlink>
    1895:	83 c4 10             	add    $0x10,%esp
    1898:	eb 83                	jmp    181d <concreate+0x252>
      exit();
    189a:	e8 81 1e 00 00       	call   3720 <exit>
  }

  printf(1, "concreate ok\n");
    189f:	83 ec 08             	sub    $0x8,%esp
    18a2:	68 d2 41 00 00       	push   $0x41d2
    18a7:	6a 01                	push   $0x1
    18a9:	e8 ac 1f 00 00       	call   385a <printf>
}
    18ae:	83 c4 10             	add    $0x10,%esp
    18b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
    18b4:	5b                   	pop    %ebx
    18b5:	5e                   	pop    %esi
    18b6:	5f                   	pop    %edi
    18b7:	5d                   	pop    %ebp
    18b8:	c3                   	ret    

000018b9 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    18b9:	55                   	push   %ebp
    18ba:	89 e5                	mov    %esp,%ebp
    18bc:	57                   	push   %edi
    18bd:	56                   	push   %esi
    18be:	53                   	push   %ebx
    18bf:	83 ec 14             	sub    $0x14,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    18c2:	68 e0 41 00 00       	push   $0x41e0
    18c7:	6a 01                	push   $0x1
    18c9:	e8 8c 1f 00 00       	call   385a <printf>

  unlink("x");
    18ce:	c7 04 24 6d 44 00 00 	movl   $0x446d,(%esp)
    18d5:	e8 96 1e 00 00       	call   3770 <unlink>
  pid = fork();
    18da:	e8 39 1e 00 00       	call   3718 <fork>
  if(pid < 0){
    18df:	83 c4 10             	add    $0x10,%esp
    18e2:	85 c0                	test   %eax,%eax
    18e4:	78 12                	js     18f8 <linkunlink+0x3f>
    18e6:	89 c7                	mov    %eax,%edi
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
    18e8:	85 c0                	test   %eax,%eax
    18ea:	74 20                	je     190c <linkunlink+0x53>
    18ec:	bb 01 00 00 00       	mov    $0x1,%ebx
    18f1:	be 00 00 00 00       	mov    $0x0,%esi
    18f6:	eb 3b                	jmp    1933 <linkunlink+0x7a>
    printf(1, "fork failed\n");
    18f8:	83 ec 08             	sub    $0x8,%esp
    18fb:	68 55 4a 00 00       	push   $0x4a55
    1900:	6a 01                	push   $0x1
    1902:	e8 53 1f 00 00       	call   385a <printf>
    exit();
    1907:	e8 14 1e 00 00       	call   3720 <exit>
  unsigned int x = (pid ? 1 : 97);
    190c:	bb 61 00 00 00       	mov    $0x61,%ebx
    1911:	eb de                	jmp    18f1 <linkunlink+0x38>
  for(i = 0; i < 100; i++){
    x = x * 1103515245 + 12345;
    if((x % 3) == 0){
      close(open("x", O_RDWR | O_CREATE));
    1913:	83 ec 08             	sub    $0x8,%esp
    1916:	68 02 02 00 00       	push   $0x202
    191b:	68 6d 44 00 00       	push   $0x446d
    1920:	e8 3b 1e 00 00       	call   3760 <open>
    1925:	89 04 24             	mov    %eax,(%esp)
    1928:	e8 1b 1e 00 00       	call   3748 <close>
    192d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 100; i++){
    1930:	83 c6 01             	add    $0x1,%esi
    1933:	83 fe 63             	cmp    $0x63,%esi
    1936:	7f 4e                	jg     1986 <linkunlink+0xcd>
    x = x * 1103515245 + 12345;
    1938:	69 db 6d 4e c6 41    	imul   $0x41c64e6d,%ebx,%ebx
    193e:	81 c3 39 30 00 00    	add    $0x3039,%ebx
    if((x % 3) == 0){
    1944:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1949:	89 d8                	mov    %ebx,%eax
    194b:	f7 e2                	mul    %edx
    194d:	d1 ea                	shr    %edx
    194f:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1952:	89 da                	mov    %ebx,%edx
    1954:	29 c2                	sub    %eax,%edx
    1956:	74 bb                	je     1913 <linkunlink+0x5a>
    } else if((x % 3) == 1){
    1958:	83 fa 01             	cmp    $0x1,%edx
    195b:	74 12                	je     196f <linkunlink+0xb6>
      link("cat", "x");
    } else {
      unlink("x");
    195d:	83 ec 0c             	sub    $0xc,%esp
    1960:	68 6d 44 00 00       	push   $0x446d
    1965:	e8 06 1e 00 00       	call   3770 <unlink>
    196a:	83 c4 10             	add    $0x10,%esp
    196d:	eb c1                	jmp    1930 <linkunlink+0x77>
      link("cat", "x");
    196f:	83 ec 08             	sub    $0x8,%esp
    1972:	68 6d 44 00 00       	push   $0x446d
    1977:	68 f1 41 00 00       	push   $0x41f1
    197c:	e8 ff 1d 00 00       	call   3780 <link>
    1981:	83 c4 10             	add    $0x10,%esp
    1984:	eb aa                	jmp    1930 <linkunlink+0x77>
    }
  }

  if(pid)
    1986:	85 ff                	test   %edi,%edi
    1988:	74 1c                	je     19a6 <linkunlink+0xed>
    wait();
    198a:	e8 99 1d 00 00       	call   3728 <wait>
  else
    exit();

  printf(1, "linkunlink ok\n");
    198f:	83 ec 08             	sub    $0x8,%esp
    1992:	68 f5 41 00 00       	push   $0x41f5
    1997:	6a 01                	push   $0x1
    1999:	e8 bc 1e 00 00       	call   385a <printf>
}
    199e:	8d 65 f4             	lea    -0xc(%ebp),%esp
    19a1:	5b                   	pop    %ebx
    19a2:	5e                   	pop    %esi
    19a3:	5f                   	pop    %edi
    19a4:	5d                   	pop    %ebp
    19a5:	c3                   	ret    
    exit();
    19a6:	e8 75 1d 00 00       	call   3720 <exit>

000019ab <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    19ab:	55                   	push   %ebp
    19ac:	89 e5                	mov    %esp,%ebp
    19ae:	53                   	push   %ebx
    19af:	83 ec 1c             	sub    $0x1c,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    19b2:	68 04 42 00 00       	push   $0x4204
    19b7:	6a 01                	push   $0x1
    19b9:	e8 9c 1e 00 00       	call   385a <printf>
  unlink("bd");
    19be:	c7 04 24 11 42 00 00 	movl   $0x4211,(%esp)
    19c5:	e8 a6 1d 00 00       	call   3770 <unlink>

  fd = open("bd", O_CREATE);
    19ca:	83 c4 08             	add    $0x8,%esp
    19cd:	68 00 02 00 00       	push   $0x200
    19d2:	68 11 42 00 00       	push   $0x4211
    19d7:	e8 84 1d 00 00       	call   3760 <open>
  if(fd < 0){
    19dc:	83 c4 10             	add    $0x10,%esp
    19df:	85 c0                	test   %eax,%eax
    19e1:	78 65                	js     1a48 <bigdir+0x9d>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);
    19e3:	83 ec 0c             	sub    $0xc,%esp
    19e6:	50                   	push   %eax
    19e7:	e8 5c 1d 00 00       	call   3748 <close>

  for(i = 0; i < 500; i++){
    19ec:	83 c4 10             	add    $0x10,%esp
    19ef:	bb 00 00 00 00       	mov    $0x0,%ebx
    19f4:	81 fb f3 01 00 00    	cmp    $0x1f3,%ebx
    19fa:	7f 74                	jg     1a70 <bigdir+0xc5>
    name[0] = 'x';
    19fc:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1a00:	8d 43 3f             	lea    0x3f(%ebx),%eax
    1a03:	85 db                	test   %ebx,%ebx
    1a05:	0f 49 c3             	cmovns %ebx,%eax
    1a08:	c1 f8 06             	sar    $0x6,%eax
    1a0b:	83 c0 30             	add    $0x30,%eax
    1a0e:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1a11:	89 da                	mov    %ebx,%edx
    1a13:	c1 fa 1f             	sar    $0x1f,%edx
    1a16:	c1 ea 1a             	shr    $0x1a,%edx
    1a19:	8d 04 13             	lea    (%ebx,%edx,1),%eax
    1a1c:	83 e0 3f             	and    $0x3f,%eax
    1a1f:	29 d0                	sub    %edx,%eax
    1a21:	83 c0 30             	add    $0x30,%eax
    1a24:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1a27:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(link("bd", name) != 0){
    1a2b:	83 ec 08             	sub    $0x8,%esp
    1a2e:	8d 45 ee             	lea    -0x12(%ebp),%eax
    1a31:	50                   	push   %eax
    1a32:	68 11 42 00 00       	push   $0x4211
    1a37:	e8 44 1d 00 00       	call   3780 <link>
    1a3c:	83 c4 10             	add    $0x10,%esp
    1a3f:	85 c0                	test   %eax,%eax
    1a41:	75 19                	jne    1a5c <bigdir+0xb1>
  for(i = 0; i < 500; i++){
    1a43:	83 c3 01             	add    $0x1,%ebx
    1a46:	eb ac                	jmp    19f4 <bigdir+0x49>
    printf(1, "bigdir create failed\n");
    1a48:	83 ec 08             	sub    $0x8,%esp
    1a4b:	68 14 42 00 00       	push   $0x4214
    1a50:	6a 01                	push   $0x1
    1a52:	e8 03 1e 00 00       	call   385a <printf>
    exit();
    1a57:	e8 c4 1c 00 00       	call   3720 <exit>
      printf(1, "bigdir link failed\n");
    1a5c:	83 ec 08             	sub    $0x8,%esp
    1a5f:	68 2a 42 00 00       	push   $0x422a
    1a64:	6a 01                	push   $0x1
    1a66:	e8 ef 1d 00 00       	call   385a <printf>
      exit();
    1a6b:	e8 b0 1c 00 00       	call   3720 <exit>
    }
  }

  unlink("bd");
    1a70:	83 ec 0c             	sub    $0xc,%esp
    1a73:	68 11 42 00 00       	push   $0x4211
    1a78:	e8 f3 1c 00 00       	call   3770 <unlink>
  for(i = 0; i < 500; i++){
    1a7d:	83 c4 10             	add    $0x10,%esp
    1a80:	bb 00 00 00 00       	mov    $0x0,%ebx
    1a85:	81 fb f3 01 00 00    	cmp    $0x1f3,%ebx
    1a8b:	7f 5b                	jg     1ae8 <bigdir+0x13d>
    name[0] = 'x';
    1a8d:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1a91:	8d 43 3f             	lea    0x3f(%ebx),%eax
    1a94:	85 db                	test   %ebx,%ebx
    1a96:	0f 49 c3             	cmovns %ebx,%eax
    1a99:	c1 f8 06             	sar    $0x6,%eax
    1a9c:	83 c0 30             	add    $0x30,%eax
    1a9f:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1aa2:	89 da                	mov    %ebx,%edx
    1aa4:	c1 fa 1f             	sar    $0x1f,%edx
    1aa7:	c1 ea 1a             	shr    $0x1a,%edx
    1aaa:	8d 04 13             	lea    (%ebx,%edx,1),%eax
    1aad:	83 e0 3f             	and    $0x3f,%eax
    1ab0:	29 d0                	sub    %edx,%eax
    1ab2:	83 c0 30             	add    $0x30,%eax
    1ab5:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1ab8:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(unlink(name) != 0){
    1abc:	83 ec 0c             	sub    $0xc,%esp
    1abf:	8d 45 ee             	lea    -0x12(%ebp),%eax
    1ac2:	50                   	push   %eax
    1ac3:	e8 a8 1c 00 00       	call   3770 <unlink>
    1ac8:	83 c4 10             	add    $0x10,%esp
    1acb:	85 c0                	test   %eax,%eax
    1acd:	75 05                	jne    1ad4 <bigdir+0x129>
  for(i = 0; i < 500; i++){
    1acf:	83 c3 01             	add    $0x1,%ebx
    1ad2:	eb b1                	jmp    1a85 <bigdir+0xda>
      printf(1, "bigdir unlink failed");
    1ad4:	83 ec 08             	sub    $0x8,%esp
    1ad7:	68 3e 42 00 00       	push   $0x423e
    1adc:	6a 01                	push   $0x1
    1ade:	e8 77 1d 00 00       	call   385a <printf>
      exit();
    1ae3:	e8 38 1c 00 00       	call   3720 <exit>
    }
  }

  printf(1, "bigdir ok\n");
    1ae8:	83 ec 08             	sub    $0x8,%esp
    1aeb:	68 53 42 00 00       	push   $0x4253
    1af0:	6a 01                	push   $0x1
    1af2:	e8 63 1d 00 00       	call   385a <printf>
}
    1af7:	83 c4 10             	add    $0x10,%esp
    1afa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1afd:	c9                   	leave  
    1afe:	c3                   	ret    

00001aff <subdir>:

void
subdir(void)
{
    1aff:	55                   	push   %ebp
    1b00:	89 e5                	mov    %esp,%ebp
    1b02:	53                   	push   %ebx
    1b03:	83 ec 0c             	sub    $0xc,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1b06:	68 5e 42 00 00       	push   $0x425e
    1b0b:	6a 01                	push   $0x1
    1b0d:	e8 48 1d 00 00       	call   385a <printf>

  unlink("ff");
    1b12:	c7 04 24 e7 42 00 00 	movl   $0x42e7,(%esp)
    1b19:	e8 52 1c 00 00       	call   3770 <unlink>
  if(mkdir("dd") != 0){
    1b1e:	c7 04 24 84 43 00 00 	movl   $0x4384,(%esp)
    1b25:	e8 5e 1c 00 00       	call   3788 <mkdir>
    1b2a:	83 c4 10             	add    $0x10,%esp
    1b2d:	85 c0                	test   %eax,%eax
    1b2f:	0f 85 14 04 00 00    	jne    1f49 <subdir+0x44a>
    printf(1, "subdir mkdir dd failed\n");
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1b35:	83 ec 08             	sub    $0x8,%esp
    1b38:	68 02 02 00 00       	push   $0x202
    1b3d:	68 bd 42 00 00       	push   $0x42bd
    1b42:	e8 19 1c 00 00       	call   3760 <open>
    1b47:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1b49:	83 c4 10             	add    $0x10,%esp
    1b4c:	85 c0                	test   %eax,%eax
    1b4e:	0f 88 09 04 00 00    	js     1f5d <subdir+0x45e>
    printf(1, "create dd/ff failed\n");
    exit();
  }
  write(fd, "ff", 2);
    1b54:	83 ec 04             	sub    $0x4,%esp
    1b57:	6a 02                	push   $0x2
    1b59:	68 e7 42 00 00       	push   $0x42e7
    1b5e:	50                   	push   %eax
    1b5f:	e8 dc 1b 00 00       	call   3740 <write>
  close(fd);
    1b64:	89 1c 24             	mov    %ebx,(%esp)
    1b67:	e8 dc 1b 00 00       	call   3748 <close>

  if(unlink("dd") >= 0){
    1b6c:	c7 04 24 84 43 00 00 	movl   $0x4384,(%esp)
    1b73:	e8 f8 1b 00 00       	call   3770 <unlink>
    1b78:	83 c4 10             	add    $0x10,%esp
    1b7b:	85 c0                	test   %eax,%eax
    1b7d:	0f 89 ee 03 00 00    	jns    1f71 <subdir+0x472>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    exit();
  }

  if(mkdir("/dd/dd") != 0){
    1b83:	83 ec 0c             	sub    $0xc,%esp
    1b86:	68 98 42 00 00       	push   $0x4298
    1b8b:	e8 f8 1b 00 00       	call   3788 <mkdir>
    1b90:	83 c4 10             	add    $0x10,%esp
    1b93:	85 c0                	test   %eax,%eax
    1b95:	0f 85 ea 03 00 00    	jne    1f85 <subdir+0x486>
    printf(1, "subdir mkdir dd/dd failed\n");
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1b9b:	83 ec 08             	sub    $0x8,%esp
    1b9e:	68 02 02 00 00       	push   $0x202
    1ba3:	68 ba 42 00 00       	push   $0x42ba
    1ba8:	e8 b3 1b 00 00       	call   3760 <open>
    1bad:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1baf:	83 c4 10             	add    $0x10,%esp
    1bb2:	85 c0                	test   %eax,%eax
    1bb4:	0f 88 df 03 00 00    	js     1f99 <subdir+0x49a>
    printf(1, "create dd/dd/ff failed\n");
    exit();
  }
  write(fd, "FF", 2);
    1bba:	83 ec 04             	sub    $0x4,%esp
    1bbd:	6a 02                	push   $0x2
    1bbf:	68 db 42 00 00       	push   $0x42db
    1bc4:	50                   	push   %eax
    1bc5:	e8 76 1b 00 00       	call   3740 <write>
  close(fd);
    1bca:	89 1c 24             	mov    %ebx,(%esp)
    1bcd:	e8 76 1b 00 00       	call   3748 <close>

  fd = open("dd/dd/../ff", 0);
    1bd2:	83 c4 08             	add    $0x8,%esp
    1bd5:	6a 00                	push   $0x0
    1bd7:	68 de 42 00 00       	push   $0x42de
    1bdc:	e8 7f 1b 00 00       	call   3760 <open>
    1be1:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1be3:	83 c4 10             	add    $0x10,%esp
    1be6:	85 c0                	test   %eax,%eax
    1be8:	0f 88 bf 03 00 00    	js     1fad <subdir+0x4ae>
    printf(1, "open dd/dd/../ff failed\n");
    exit();
  }
  cc = read(fd, buf, sizeof(buf));
    1bee:	83 ec 04             	sub    $0x4,%esp
    1bf1:	68 00 20 00 00       	push   $0x2000
    1bf6:	68 40 83 00 00       	push   $0x8340
    1bfb:	50                   	push   %eax
    1bfc:	e8 37 1b 00 00       	call   3738 <read>
  if(cc != 2 || buf[0] != 'f'){
    1c01:	83 c4 10             	add    $0x10,%esp
    1c04:	83 f8 02             	cmp    $0x2,%eax
    1c07:	0f 85 b4 03 00 00    	jne    1fc1 <subdir+0x4c2>
    1c0d:	80 3d 40 83 00 00 66 	cmpb   $0x66,0x8340
    1c14:	0f 85 a7 03 00 00    	jne    1fc1 <subdir+0x4c2>
    printf(1, "dd/dd/../ff wrong content\n");
    exit();
  }
  close(fd);
    1c1a:	83 ec 0c             	sub    $0xc,%esp
    1c1d:	53                   	push   %ebx
    1c1e:	e8 25 1b 00 00       	call   3748 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1c23:	83 c4 08             	add    $0x8,%esp
    1c26:	68 1e 43 00 00       	push   $0x431e
    1c2b:	68 ba 42 00 00       	push   $0x42ba
    1c30:	e8 4b 1b 00 00       	call   3780 <link>
    1c35:	83 c4 10             	add    $0x10,%esp
    1c38:	85 c0                	test   %eax,%eax
    1c3a:	0f 85 95 03 00 00    	jne    1fd5 <subdir+0x4d6>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    exit();
  }

  if(unlink("dd/dd/ff") != 0){
    1c40:	83 ec 0c             	sub    $0xc,%esp
    1c43:	68 ba 42 00 00       	push   $0x42ba
    1c48:	e8 23 1b 00 00       	call   3770 <unlink>
    1c4d:	83 c4 10             	add    $0x10,%esp
    1c50:	85 c0                	test   %eax,%eax
    1c52:	0f 85 91 03 00 00    	jne    1fe9 <subdir+0x4ea>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1c58:	83 ec 08             	sub    $0x8,%esp
    1c5b:	6a 00                	push   $0x0
    1c5d:	68 ba 42 00 00       	push   $0x42ba
    1c62:	e8 f9 1a 00 00       	call   3760 <open>
    1c67:	83 c4 10             	add    $0x10,%esp
    1c6a:	85 c0                	test   %eax,%eax
    1c6c:	0f 89 8b 03 00 00    	jns    1ffd <subdir+0x4fe>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    exit();
  }

  if(chdir("dd") != 0){
    1c72:	83 ec 0c             	sub    $0xc,%esp
    1c75:	68 84 43 00 00       	push   $0x4384
    1c7a:	e8 11 1b 00 00       	call   3790 <chdir>
    1c7f:	83 c4 10             	add    $0x10,%esp
    1c82:	85 c0                	test   %eax,%eax
    1c84:	0f 85 87 03 00 00    	jne    2011 <subdir+0x512>
    printf(1, "chdir dd failed\n");
    exit();
  }
  if(chdir("dd/../../dd") != 0){
    1c8a:	83 ec 0c             	sub    $0xc,%esp
    1c8d:	68 52 43 00 00       	push   $0x4352
    1c92:	e8 f9 1a 00 00       	call   3790 <chdir>
    1c97:	83 c4 10             	add    $0x10,%esp
    1c9a:	85 c0                	test   %eax,%eax
    1c9c:	0f 85 83 03 00 00    	jne    2025 <subdir+0x526>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("dd/../../../dd") != 0){
    1ca2:	83 ec 0c             	sub    $0xc,%esp
    1ca5:	68 78 43 00 00       	push   $0x4378
    1caa:	e8 e1 1a 00 00       	call   3790 <chdir>
    1caf:	83 c4 10             	add    $0x10,%esp
    1cb2:	85 c0                	test   %eax,%eax
    1cb4:	0f 85 7f 03 00 00    	jne    2039 <subdir+0x53a>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("./..") != 0){
    1cba:	83 ec 0c             	sub    $0xc,%esp
    1cbd:	68 87 43 00 00       	push   $0x4387
    1cc2:	e8 c9 1a 00 00       	call   3790 <chdir>
    1cc7:	83 c4 10             	add    $0x10,%esp
    1cca:	85 c0                	test   %eax,%eax
    1ccc:	0f 85 7b 03 00 00    	jne    204d <subdir+0x54e>
    printf(1, "chdir ./.. failed\n");
    exit();
  }

  fd = open("dd/dd/ffff", 0);
    1cd2:	83 ec 08             	sub    $0x8,%esp
    1cd5:	6a 00                	push   $0x0
    1cd7:	68 1e 43 00 00       	push   $0x431e
    1cdc:	e8 7f 1a 00 00       	call   3760 <open>
    1ce1:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1ce3:	83 c4 10             	add    $0x10,%esp
    1ce6:	85 c0                	test   %eax,%eax
    1ce8:	0f 88 73 03 00 00    	js     2061 <subdir+0x562>
    printf(1, "open dd/dd/ffff failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    1cee:	83 ec 04             	sub    $0x4,%esp
    1cf1:	68 00 20 00 00       	push   $0x2000
    1cf6:	68 40 83 00 00       	push   $0x8340
    1cfb:	50                   	push   %eax
    1cfc:	e8 37 1a 00 00       	call   3738 <read>
    1d01:	83 c4 10             	add    $0x10,%esp
    1d04:	83 f8 02             	cmp    $0x2,%eax
    1d07:	0f 85 68 03 00 00    	jne    2075 <subdir+0x576>
    printf(1, "read dd/dd/ffff wrong len\n");
    exit();
  }
  close(fd);
    1d0d:	83 ec 0c             	sub    $0xc,%esp
    1d10:	53                   	push   %ebx
    1d11:	e8 32 1a 00 00       	call   3748 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1d16:	83 c4 08             	add    $0x8,%esp
    1d19:	6a 00                	push   $0x0
    1d1b:	68 ba 42 00 00       	push   $0x42ba
    1d20:	e8 3b 1a 00 00       	call   3760 <open>
    1d25:	83 c4 10             	add    $0x10,%esp
    1d28:	85 c0                	test   %eax,%eax
    1d2a:	0f 89 59 03 00 00    	jns    2089 <subdir+0x58a>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    exit();
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    1d30:	83 ec 08             	sub    $0x8,%esp
    1d33:	68 02 02 00 00       	push   $0x202
    1d38:	68 d2 43 00 00       	push   $0x43d2
    1d3d:	e8 1e 1a 00 00       	call   3760 <open>
    1d42:	83 c4 10             	add    $0x10,%esp
    1d45:	85 c0                	test   %eax,%eax
    1d47:	0f 89 50 03 00 00    	jns    209d <subdir+0x59e>
    printf(1, "create dd/ff/ff succeeded!\n");
    exit();
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    1d4d:	83 ec 08             	sub    $0x8,%esp
    1d50:	68 02 02 00 00       	push   $0x202
    1d55:	68 f7 43 00 00       	push   $0x43f7
    1d5a:	e8 01 1a 00 00       	call   3760 <open>
    1d5f:	83 c4 10             	add    $0x10,%esp
    1d62:	85 c0                	test   %eax,%eax
    1d64:	0f 89 47 03 00 00    	jns    20b1 <subdir+0x5b2>
    printf(1, "create dd/xx/ff succeeded!\n");
    exit();
  }
  if(open("dd", O_CREATE) >= 0){
    1d6a:	83 ec 08             	sub    $0x8,%esp
    1d6d:	68 00 02 00 00       	push   $0x200
    1d72:	68 84 43 00 00       	push   $0x4384
    1d77:	e8 e4 19 00 00       	call   3760 <open>
    1d7c:	83 c4 10             	add    $0x10,%esp
    1d7f:	85 c0                	test   %eax,%eax
    1d81:	0f 89 3e 03 00 00    	jns    20c5 <subdir+0x5c6>
    printf(1, "create dd succeeded!\n");
    exit();
  }
  if(open("dd", O_RDWR) >= 0){
    1d87:	83 ec 08             	sub    $0x8,%esp
    1d8a:	6a 02                	push   $0x2
    1d8c:	68 84 43 00 00       	push   $0x4384
    1d91:	e8 ca 19 00 00       	call   3760 <open>
    1d96:	83 c4 10             	add    $0x10,%esp
    1d99:	85 c0                	test   %eax,%eax
    1d9b:	0f 89 38 03 00 00    	jns    20d9 <subdir+0x5da>
    printf(1, "open dd rdwr succeeded!\n");
    exit();
  }
  if(open("dd", O_WRONLY) >= 0){
    1da1:	83 ec 08             	sub    $0x8,%esp
    1da4:	6a 01                	push   $0x1
    1da6:	68 84 43 00 00       	push   $0x4384
    1dab:	e8 b0 19 00 00       	call   3760 <open>
    1db0:	83 c4 10             	add    $0x10,%esp
    1db3:	85 c0                	test   %eax,%eax
    1db5:	0f 89 32 03 00 00    	jns    20ed <subdir+0x5ee>
    printf(1, "open dd wronly succeeded!\n");
    exit();
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    1dbb:	83 ec 08             	sub    $0x8,%esp
    1dbe:	68 66 44 00 00       	push   $0x4466
    1dc3:	68 d2 43 00 00       	push   $0x43d2
    1dc8:	e8 b3 19 00 00       	call   3780 <link>
    1dcd:	83 c4 10             	add    $0x10,%esp
    1dd0:	85 c0                	test   %eax,%eax
    1dd2:	0f 84 29 03 00 00    	je     2101 <subdir+0x602>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    1dd8:	83 ec 08             	sub    $0x8,%esp
    1ddb:	68 66 44 00 00       	push   $0x4466
    1de0:	68 f7 43 00 00       	push   $0x43f7
    1de5:	e8 96 19 00 00       	call   3780 <link>
    1dea:	83 c4 10             	add    $0x10,%esp
    1ded:	85 c0                	test   %eax,%eax
    1def:	0f 84 20 03 00 00    	je     2115 <subdir+0x616>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    1df5:	83 ec 08             	sub    $0x8,%esp
    1df8:	68 1e 43 00 00       	push   $0x431e
    1dfd:	68 bd 42 00 00       	push   $0x42bd
    1e02:	e8 79 19 00 00       	call   3780 <link>
    1e07:	83 c4 10             	add    $0x10,%esp
    1e0a:	85 c0                	test   %eax,%eax
    1e0c:	0f 84 17 03 00 00    	je     2129 <subdir+0x62a>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    exit();
  }
  if(mkdir("dd/ff/ff") == 0){
    1e12:	83 ec 0c             	sub    $0xc,%esp
    1e15:	68 d2 43 00 00       	push   $0x43d2
    1e1a:	e8 69 19 00 00       	call   3788 <mkdir>
    1e1f:	83 c4 10             	add    $0x10,%esp
    1e22:	85 c0                	test   %eax,%eax
    1e24:	0f 84 13 03 00 00    	je     213d <subdir+0x63e>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/xx/ff") == 0){
    1e2a:	83 ec 0c             	sub    $0xc,%esp
    1e2d:	68 f7 43 00 00       	push   $0x43f7
    1e32:	e8 51 19 00 00       	call   3788 <mkdir>
    1e37:	83 c4 10             	add    $0x10,%esp
    1e3a:	85 c0                	test   %eax,%eax
    1e3c:	0f 84 0f 03 00 00    	je     2151 <subdir+0x652>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/dd/ffff") == 0){
    1e42:	83 ec 0c             	sub    $0xc,%esp
    1e45:	68 1e 43 00 00       	push   $0x431e
    1e4a:	e8 39 19 00 00       	call   3788 <mkdir>
    1e4f:	83 c4 10             	add    $0x10,%esp
    1e52:	85 c0                	test   %eax,%eax
    1e54:	0f 84 0b 03 00 00    	je     2165 <subdir+0x666>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    exit();
  }
  if(unlink("dd/xx/ff") == 0){
    1e5a:	83 ec 0c             	sub    $0xc,%esp
    1e5d:	68 f7 43 00 00       	push   $0x43f7
    1e62:	e8 09 19 00 00       	call   3770 <unlink>
    1e67:	83 c4 10             	add    $0x10,%esp
    1e6a:	85 c0                	test   %eax,%eax
    1e6c:	0f 84 07 03 00 00    	je     2179 <subdir+0x67a>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    exit();
  }
  if(unlink("dd/ff/ff") == 0){
    1e72:	83 ec 0c             	sub    $0xc,%esp
    1e75:	68 d2 43 00 00       	push   $0x43d2
    1e7a:	e8 f1 18 00 00       	call   3770 <unlink>
    1e7f:	83 c4 10             	add    $0x10,%esp
    1e82:	85 c0                	test   %eax,%eax
    1e84:	0f 84 03 03 00 00    	je     218d <subdir+0x68e>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/ff") == 0){
    1e8a:	83 ec 0c             	sub    $0xc,%esp
    1e8d:	68 bd 42 00 00       	push   $0x42bd
    1e92:	e8 f9 18 00 00       	call   3790 <chdir>
    1e97:	83 c4 10             	add    $0x10,%esp
    1e9a:	85 c0                	test   %eax,%eax
    1e9c:	0f 84 ff 02 00 00    	je     21a1 <subdir+0x6a2>
    printf(1, "chdir dd/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/xx") == 0){
    1ea2:	83 ec 0c             	sub    $0xc,%esp
    1ea5:	68 69 44 00 00       	push   $0x4469
    1eaa:	e8 e1 18 00 00       	call   3790 <chdir>
    1eaf:	83 c4 10             	add    $0x10,%esp
    1eb2:	85 c0                	test   %eax,%eax
    1eb4:	0f 84 fb 02 00 00    	je     21b5 <subdir+0x6b6>
    printf(1, "chdir dd/xx succeeded!\n");
    exit();
  }

  if(unlink("dd/dd/ffff") != 0){
    1eba:	83 ec 0c             	sub    $0xc,%esp
    1ebd:	68 1e 43 00 00       	push   $0x431e
    1ec2:	e8 a9 18 00 00       	call   3770 <unlink>
    1ec7:	83 c4 10             	add    $0x10,%esp
    1eca:	85 c0                	test   %eax,%eax
    1ecc:	0f 85 f7 02 00 00    	jne    21c9 <subdir+0x6ca>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(unlink("dd/ff") != 0){
    1ed2:	83 ec 0c             	sub    $0xc,%esp
    1ed5:	68 bd 42 00 00       	push   $0x42bd
    1eda:	e8 91 18 00 00       	call   3770 <unlink>
    1edf:	83 c4 10             	add    $0x10,%esp
    1ee2:	85 c0                	test   %eax,%eax
    1ee4:	0f 85 f3 02 00 00    	jne    21dd <subdir+0x6de>
    printf(1, "unlink dd/ff failed\n");
    exit();
  }
  if(unlink("dd") == 0){
    1eea:	83 ec 0c             	sub    $0xc,%esp
    1eed:	68 84 43 00 00       	push   $0x4384
    1ef2:	e8 79 18 00 00       	call   3770 <unlink>
    1ef7:	83 c4 10             	add    $0x10,%esp
    1efa:	85 c0                	test   %eax,%eax
    1efc:	0f 84 ef 02 00 00    	je     21f1 <subdir+0x6f2>
    printf(1, "unlink non-empty dd succeeded!\n");
    exit();
  }
  if(unlink("dd/dd") < 0){
    1f02:	83 ec 0c             	sub    $0xc,%esp
    1f05:	68 99 42 00 00       	push   $0x4299
    1f0a:	e8 61 18 00 00       	call   3770 <unlink>
    1f0f:	83 c4 10             	add    $0x10,%esp
    1f12:	85 c0                	test   %eax,%eax
    1f14:	0f 88 eb 02 00 00    	js     2205 <subdir+0x706>
    printf(1, "unlink dd/dd failed\n");
    exit();
  }
  if(unlink("dd") < 0){
    1f1a:	83 ec 0c             	sub    $0xc,%esp
    1f1d:	68 84 43 00 00       	push   $0x4384
    1f22:	e8 49 18 00 00       	call   3770 <unlink>
    1f27:	83 c4 10             	add    $0x10,%esp
    1f2a:	85 c0                	test   %eax,%eax
    1f2c:	0f 88 e7 02 00 00    	js     2219 <subdir+0x71a>
    printf(1, "unlink dd failed\n");
    exit();
  }

  printf(1, "subdir ok\n");
    1f32:	83 ec 08             	sub    $0x8,%esp
    1f35:	68 66 45 00 00       	push   $0x4566
    1f3a:	6a 01                	push   $0x1
    1f3c:	e8 19 19 00 00       	call   385a <printf>
}
    1f41:	83 c4 10             	add    $0x10,%esp
    1f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1f47:	c9                   	leave  
    1f48:	c3                   	ret    
    printf(1, "subdir mkdir dd failed\n");
    1f49:	83 ec 08             	sub    $0x8,%esp
    1f4c:	68 6b 42 00 00       	push   $0x426b
    1f51:	6a 01                	push   $0x1
    1f53:	e8 02 19 00 00       	call   385a <printf>
    exit();
    1f58:	e8 c3 17 00 00       	call   3720 <exit>
    printf(1, "create dd/ff failed\n");
    1f5d:	83 ec 08             	sub    $0x8,%esp
    1f60:	68 83 42 00 00       	push   $0x4283
    1f65:	6a 01                	push   $0x1
    1f67:	e8 ee 18 00 00       	call   385a <printf>
    exit();
    1f6c:	e8 af 17 00 00       	call   3720 <exit>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1f71:	83 ec 08             	sub    $0x8,%esp
    1f74:	68 50 4d 00 00       	push   $0x4d50
    1f79:	6a 01                	push   $0x1
    1f7b:	e8 da 18 00 00       	call   385a <printf>
    exit();
    1f80:	e8 9b 17 00 00       	call   3720 <exit>
    printf(1, "subdir mkdir dd/dd failed\n");
    1f85:	83 ec 08             	sub    $0x8,%esp
    1f88:	68 9f 42 00 00       	push   $0x429f
    1f8d:	6a 01                	push   $0x1
    1f8f:	e8 c6 18 00 00       	call   385a <printf>
    exit();
    1f94:	e8 87 17 00 00       	call   3720 <exit>
    printf(1, "create dd/dd/ff failed\n");
    1f99:	83 ec 08             	sub    $0x8,%esp
    1f9c:	68 c3 42 00 00       	push   $0x42c3
    1fa1:	6a 01                	push   $0x1
    1fa3:	e8 b2 18 00 00       	call   385a <printf>
    exit();
    1fa8:	e8 73 17 00 00       	call   3720 <exit>
    printf(1, "open dd/dd/../ff failed\n");
    1fad:	83 ec 08             	sub    $0x8,%esp
    1fb0:	68 ea 42 00 00       	push   $0x42ea
    1fb5:	6a 01                	push   $0x1
    1fb7:	e8 9e 18 00 00       	call   385a <printf>
    exit();
    1fbc:	e8 5f 17 00 00       	call   3720 <exit>
    printf(1, "dd/dd/../ff wrong content\n");
    1fc1:	83 ec 08             	sub    $0x8,%esp
    1fc4:	68 03 43 00 00       	push   $0x4303
    1fc9:	6a 01                	push   $0x1
    1fcb:	e8 8a 18 00 00       	call   385a <printf>
    exit();
    1fd0:	e8 4b 17 00 00       	call   3720 <exit>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    1fd5:	83 ec 08             	sub    $0x8,%esp
    1fd8:	68 78 4d 00 00       	push   $0x4d78
    1fdd:	6a 01                	push   $0x1
    1fdf:	e8 76 18 00 00       	call   385a <printf>
    exit();
    1fe4:	e8 37 17 00 00       	call   3720 <exit>
    printf(1, "unlink dd/dd/ff failed\n");
    1fe9:	83 ec 08             	sub    $0x8,%esp
    1fec:	68 29 43 00 00       	push   $0x4329
    1ff1:	6a 01                	push   $0x1
    1ff3:	e8 62 18 00 00       	call   385a <printf>
    exit();
    1ff8:	e8 23 17 00 00       	call   3720 <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    1ffd:	83 ec 08             	sub    $0x8,%esp
    2000:	68 9c 4d 00 00       	push   $0x4d9c
    2005:	6a 01                	push   $0x1
    2007:	e8 4e 18 00 00       	call   385a <printf>
    exit();
    200c:	e8 0f 17 00 00       	call   3720 <exit>
    printf(1, "chdir dd failed\n");
    2011:	83 ec 08             	sub    $0x8,%esp
    2014:	68 41 43 00 00       	push   $0x4341
    2019:	6a 01                	push   $0x1
    201b:	e8 3a 18 00 00       	call   385a <printf>
    exit();
    2020:	e8 fb 16 00 00       	call   3720 <exit>
    printf(1, "chdir dd/../../dd failed\n");
    2025:	83 ec 08             	sub    $0x8,%esp
    2028:	68 5e 43 00 00       	push   $0x435e
    202d:	6a 01                	push   $0x1
    202f:	e8 26 18 00 00       	call   385a <printf>
    exit();
    2034:	e8 e7 16 00 00       	call   3720 <exit>
    printf(1, "chdir dd/../../dd failed\n");
    2039:	83 ec 08             	sub    $0x8,%esp
    203c:	68 5e 43 00 00       	push   $0x435e
    2041:	6a 01                	push   $0x1
    2043:	e8 12 18 00 00       	call   385a <printf>
    exit();
    2048:	e8 d3 16 00 00       	call   3720 <exit>
    printf(1, "chdir ./.. failed\n");
    204d:	83 ec 08             	sub    $0x8,%esp
    2050:	68 8c 43 00 00       	push   $0x438c
    2055:	6a 01                	push   $0x1
    2057:	e8 fe 17 00 00       	call   385a <printf>
    exit();
    205c:	e8 bf 16 00 00       	call   3720 <exit>
    printf(1, "open dd/dd/ffff failed\n");
    2061:	83 ec 08             	sub    $0x8,%esp
    2064:	68 9f 43 00 00       	push   $0x439f
    2069:	6a 01                	push   $0x1
    206b:	e8 ea 17 00 00       	call   385a <printf>
    exit();
    2070:	e8 ab 16 00 00       	call   3720 <exit>
    printf(1, "read dd/dd/ffff wrong len\n");
    2075:	83 ec 08             	sub    $0x8,%esp
    2078:	68 b7 43 00 00       	push   $0x43b7
    207d:	6a 01                	push   $0x1
    207f:	e8 d6 17 00 00       	call   385a <printf>
    exit();
    2084:	e8 97 16 00 00       	call   3720 <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    2089:	83 ec 08             	sub    $0x8,%esp
    208c:	68 c0 4d 00 00       	push   $0x4dc0
    2091:	6a 01                	push   $0x1
    2093:	e8 c2 17 00 00       	call   385a <printf>
    exit();
    2098:	e8 83 16 00 00       	call   3720 <exit>
    printf(1, "create dd/ff/ff succeeded!\n");
    209d:	83 ec 08             	sub    $0x8,%esp
    20a0:	68 db 43 00 00       	push   $0x43db
    20a5:	6a 01                	push   $0x1
    20a7:	e8 ae 17 00 00       	call   385a <printf>
    exit();
    20ac:	e8 6f 16 00 00       	call   3720 <exit>
    printf(1, "create dd/xx/ff succeeded!\n");
    20b1:	83 ec 08             	sub    $0x8,%esp
    20b4:	68 00 44 00 00       	push   $0x4400
    20b9:	6a 01                	push   $0x1
    20bb:	e8 9a 17 00 00       	call   385a <printf>
    exit();
    20c0:	e8 5b 16 00 00       	call   3720 <exit>
    printf(1, "create dd succeeded!\n");
    20c5:	83 ec 08             	sub    $0x8,%esp
    20c8:	68 1c 44 00 00       	push   $0x441c
    20cd:	6a 01                	push   $0x1
    20cf:	e8 86 17 00 00       	call   385a <printf>
    exit();
    20d4:	e8 47 16 00 00       	call   3720 <exit>
    printf(1, "open dd rdwr succeeded!\n");
    20d9:	83 ec 08             	sub    $0x8,%esp
    20dc:	68 32 44 00 00       	push   $0x4432
    20e1:	6a 01                	push   $0x1
    20e3:	e8 72 17 00 00       	call   385a <printf>
    exit();
    20e8:	e8 33 16 00 00       	call   3720 <exit>
    printf(1, "open dd wronly succeeded!\n");
    20ed:	83 ec 08             	sub    $0x8,%esp
    20f0:	68 4b 44 00 00       	push   $0x444b
    20f5:	6a 01                	push   $0x1
    20f7:	e8 5e 17 00 00       	call   385a <printf>
    exit();
    20fc:	e8 1f 16 00 00       	call   3720 <exit>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2101:	83 ec 08             	sub    $0x8,%esp
    2104:	68 e8 4d 00 00       	push   $0x4de8
    2109:	6a 01                	push   $0x1
    210b:	e8 4a 17 00 00       	call   385a <printf>
    exit();
    2110:	e8 0b 16 00 00       	call   3720 <exit>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    2115:	83 ec 08             	sub    $0x8,%esp
    2118:	68 0c 4e 00 00       	push   $0x4e0c
    211d:	6a 01                	push   $0x1
    211f:	e8 36 17 00 00       	call   385a <printf>
    exit();
    2124:	e8 f7 15 00 00       	call   3720 <exit>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2129:	83 ec 08             	sub    $0x8,%esp
    212c:	68 30 4e 00 00       	push   $0x4e30
    2131:	6a 01                	push   $0x1
    2133:	e8 22 17 00 00       	call   385a <printf>
    exit();
    2138:	e8 e3 15 00 00       	call   3720 <exit>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    213d:	83 ec 08             	sub    $0x8,%esp
    2140:	68 6f 44 00 00       	push   $0x446f
    2145:	6a 01                	push   $0x1
    2147:	e8 0e 17 00 00       	call   385a <printf>
    exit();
    214c:	e8 cf 15 00 00       	call   3720 <exit>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    2151:	83 ec 08             	sub    $0x8,%esp
    2154:	68 8a 44 00 00       	push   $0x448a
    2159:	6a 01                	push   $0x1
    215b:	e8 fa 16 00 00       	call   385a <printf>
    exit();
    2160:	e8 bb 15 00 00       	call   3720 <exit>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    2165:	83 ec 08             	sub    $0x8,%esp
    2168:	68 a5 44 00 00       	push   $0x44a5
    216d:	6a 01                	push   $0x1
    216f:	e8 e6 16 00 00       	call   385a <printf>
    exit();
    2174:	e8 a7 15 00 00       	call   3720 <exit>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2179:	83 ec 08             	sub    $0x8,%esp
    217c:	68 c2 44 00 00       	push   $0x44c2
    2181:	6a 01                	push   $0x1
    2183:	e8 d2 16 00 00       	call   385a <printf>
    exit();
    2188:	e8 93 15 00 00       	call   3720 <exit>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    218d:	83 ec 08             	sub    $0x8,%esp
    2190:	68 de 44 00 00       	push   $0x44de
    2195:	6a 01                	push   $0x1
    2197:	e8 be 16 00 00       	call   385a <printf>
    exit();
    219c:	e8 7f 15 00 00       	call   3720 <exit>
    printf(1, "chdir dd/ff succeeded!\n");
    21a1:	83 ec 08             	sub    $0x8,%esp
    21a4:	68 fa 44 00 00       	push   $0x44fa
    21a9:	6a 01                	push   $0x1
    21ab:	e8 aa 16 00 00       	call   385a <printf>
    exit();
    21b0:	e8 6b 15 00 00       	call   3720 <exit>
    printf(1, "chdir dd/xx succeeded!\n");
    21b5:	83 ec 08             	sub    $0x8,%esp
    21b8:	68 12 45 00 00       	push   $0x4512
    21bd:	6a 01                	push   $0x1
    21bf:	e8 96 16 00 00       	call   385a <printf>
    exit();
    21c4:	e8 57 15 00 00       	call   3720 <exit>
    printf(1, "unlink dd/dd/ff failed\n");
    21c9:	83 ec 08             	sub    $0x8,%esp
    21cc:	68 29 43 00 00       	push   $0x4329
    21d1:	6a 01                	push   $0x1
    21d3:	e8 82 16 00 00       	call   385a <printf>
    exit();
    21d8:	e8 43 15 00 00       	call   3720 <exit>
    printf(1, "unlink dd/ff failed\n");
    21dd:	83 ec 08             	sub    $0x8,%esp
    21e0:	68 2a 45 00 00       	push   $0x452a
    21e5:	6a 01                	push   $0x1
    21e7:	e8 6e 16 00 00       	call   385a <printf>
    exit();
    21ec:	e8 2f 15 00 00       	call   3720 <exit>
    printf(1, "unlink non-empty dd succeeded!\n");
    21f1:	83 ec 08             	sub    $0x8,%esp
    21f4:	68 54 4e 00 00       	push   $0x4e54
    21f9:	6a 01                	push   $0x1
    21fb:	e8 5a 16 00 00       	call   385a <printf>
    exit();
    2200:	e8 1b 15 00 00       	call   3720 <exit>
    printf(1, "unlink dd/dd failed\n");
    2205:	83 ec 08             	sub    $0x8,%esp
    2208:	68 3f 45 00 00       	push   $0x453f
    220d:	6a 01                	push   $0x1
    220f:	e8 46 16 00 00       	call   385a <printf>
    exit();
    2214:	e8 07 15 00 00       	call   3720 <exit>
    printf(1, "unlink dd failed\n");
    2219:	83 ec 08             	sub    $0x8,%esp
    221c:	68 54 45 00 00       	push   $0x4554
    2221:	6a 01                	push   $0x1
    2223:	e8 32 16 00 00       	call   385a <printf>
    exit();
    2228:	e8 f3 14 00 00       	call   3720 <exit>

0000222d <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    222d:	55                   	push   %ebp
    222e:	89 e5                	mov    %esp,%ebp
    2230:	57                   	push   %edi
    2231:	56                   	push   %esi
    2232:	53                   	push   %ebx
    2233:	83 ec 14             	sub    $0x14,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    2236:	68 71 45 00 00       	push   $0x4571
    223b:	6a 01                	push   $0x1
    223d:	e8 18 16 00 00       	call   385a <printf>

  unlink("bigwrite");
    2242:	c7 04 24 80 45 00 00 	movl   $0x4580,(%esp)
    2249:	e8 22 15 00 00       	call   3770 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    224e:	83 c4 10             	add    $0x10,%esp
    2251:	be f3 01 00 00       	mov    $0x1f3,%esi
    2256:	eb 45                	jmp    229d <bigwrite+0x70>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
    2258:	83 ec 08             	sub    $0x8,%esp
    225b:	68 89 45 00 00       	push   $0x4589
    2260:	6a 01                	push   $0x1
    2262:	e8 f3 15 00 00       	call   385a <printf>
      exit();
    2267:	e8 b4 14 00 00       	call   3720 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
    226c:	50                   	push   %eax
    226d:	56                   	push   %esi
    226e:	68 a1 45 00 00       	push   $0x45a1
    2273:	6a 01                	push   $0x1
    2275:	e8 e0 15 00 00       	call   385a <printf>
        exit();
    227a:	e8 a1 14 00 00       	call   3720 <exit>
      }
    }
    close(fd);
    227f:	83 ec 0c             	sub    $0xc,%esp
    2282:	57                   	push   %edi
    2283:	e8 c0 14 00 00       	call   3748 <close>
    unlink("bigwrite");
    2288:	c7 04 24 80 45 00 00 	movl   $0x4580,(%esp)
    228f:	e8 dc 14 00 00       	call   3770 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2294:	81 c6 d7 01 00 00    	add    $0x1d7,%esi
    229a:	83 c4 10             	add    $0x10,%esp
    229d:	81 fe ff 17 00 00    	cmp    $0x17ff,%esi
    22a3:	7f 40                	jg     22e5 <bigwrite+0xb8>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    22a5:	83 ec 08             	sub    $0x8,%esp
    22a8:	68 02 02 00 00       	push   $0x202
    22ad:	68 80 45 00 00       	push   $0x4580
    22b2:	e8 a9 14 00 00       	call   3760 <open>
    22b7:	89 c7                	mov    %eax,%edi
    if(fd < 0){
    22b9:	83 c4 10             	add    $0x10,%esp
    22bc:	85 c0                	test   %eax,%eax
    22be:	78 98                	js     2258 <bigwrite+0x2b>
    for(i = 0; i < 2; i++){
    22c0:	bb 00 00 00 00       	mov    $0x0,%ebx
    22c5:	83 fb 01             	cmp    $0x1,%ebx
    22c8:	7f b5                	jg     227f <bigwrite+0x52>
      int cc = write(fd, buf, sz);
    22ca:	83 ec 04             	sub    $0x4,%esp
    22cd:	56                   	push   %esi
    22ce:	68 40 83 00 00       	push   $0x8340
    22d3:	57                   	push   %edi
    22d4:	e8 67 14 00 00       	call   3740 <write>
      if(cc != sz){
    22d9:	83 c4 10             	add    $0x10,%esp
    22dc:	39 c6                	cmp    %eax,%esi
    22de:	75 8c                	jne    226c <bigwrite+0x3f>
    for(i = 0; i < 2; i++){
    22e0:	83 c3 01             	add    $0x1,%ebx
    22e3:	eb e0                	jmp    22c5 <bigwrite+0x98>
  }

  printf(1, "bigwrite ok\n");
    22e5:	83 ec 08             	sub    $0x8,%esp
    22e8:	68 b3 45 00 00       	push   $0x45b3
    22ed:	6a 01                	push   $0x1
    22ef:	e8 66 15 00 00       	call   385a <printf>
}
    22f4:	83 c4 10             	add    $0x10,%esp
    22f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
    22fa:	5b                   	pop    %ebx
    22fb:	5e                   	pop    %esi
    22fc:	5f                   	pop    %edi
    22fd:	5d                   	pop    %ebp
    22fe:	c3                   	ret    

000022ff <bigfile>:

void
bigfile(void)
{
    22ff:	55                   	push   %ebp
    2300:	89 e5                	mov    %esp,%ebp
    2302:	57                   	push   %edi
    2303:	56                   	push   %esi
    2304:	53                   	push   %ebx
    2305:	83 ec 14             	sub    $0x14,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2308:	68 c0 45 00 00       	push   $0x45c0
    230d:	6a 01                	push   $0x1
    230f:	e8 46 15 00 00       	call   385a <printf>

  unlink("bigfile");
    2314:	c7 04 24 dc 45 00 00 	movl   $0x45dc,(%esp)
    231b:	e8 50 14 00 00       	call   3770 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2320:	83 c4 08             	add    $0x8,%esp
    2323:	68 02 02 00 00       	push   $0x202
    2328:	68 dc 45 00 00       	push   $0x45dc
    232d:	e8 2e 14 00 00       	call   3760 <open>
  if(fd < 0){
    2332:	83 c4 10             	add    $0x10,%esp
    2335:	85 c0                	test   %eax,%eax
    2337:	78 09                	js     2342 <bigfile+0x43>
    2339:	89 c6                	mov    %eax,%esi
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    233b:	bb 00 00 00 00       	mov    $0x0,%ebx
    2340:	eb 17                	jmp    2359 <bigfile+0x5a>
    printf(1, "cannot create bigfile");
    2342:	83 ec 08             	sub    $0x8,%esp
    2345:	68 ce 45 00 00       	push   $0x45ce
    234a:	6a 01                	push   $0x1
    234c:	e8 09 15 00 00       	call   385a <printf>
    exit();
    2351:	e8 ca 13 00 00       	call   3720 <exit>
  for(i = 0; i < 20; i++){
    2356:	83 c3 01             	add    $0x1,%ebx
    2359:	83 fb 13             	cmp    $0x13,%ebx
    235c:	7f 44                	jg     23a2 <bigfile+0xa3>
    memset(buf, i, 600);
    235e:	83 ec 04             	sub    $0x4,%esp
    2361:	68 58 02 00 00       	push   $0x258
    2366:	53                   	push   %ebx
    2367:	68 40 83 00 00       	push   $0x8340
    236c:	e8 80 12 00 00       	call   35f1 <memset>
    if(write(fd, buf, 600) != 600){
    2371:	83 c4 0c             	add    $0xc,%esp
    2374:	68 58 02 00 00       	push   $0x258
    2379:	68 40 83 00 00       	push   $0x8340
    237e:	56                   	push   %esi
    237f:	e8 bc 13 00 00       	call   3740 <write>
    2384:	83 c4 10             	add    $0x10,%esp
    2387:	3d 58 02 00 00       	cmp    $0x258,%eax
    238c:	74 c8                	je     2356 <bigfile+0x57>
      printf(1, "write bigfile failed\n");
    238e:	83 ec 08             	sub    $0x8,%esp
    2391:	68 e4 45 00 00       	push   $0x45e4
    2396:	6a 01                	push   $0x1
    2398:	e8 bd 14 00 00       	call   385a <printf>
      exit();
    239d:	e8 7e 13 00 00       	call   3720 <exit>
    }
  }
  close(fd);
    23a2:	83 ec 0c             	sub    $0xc,%esp
    23a5:	56                   	push   %esi
    23a6:	e8 9d 13 00 00       	call   3748 <close>

  fd = open("bigfile", 0);
    23ab:	83 c4 08             	add    $0x8,%esp
    23ae:	6a 00                	push   $0x0
    23b0:	68 dc 45 00 00       	push   $0x45dc
    23b5:	e8 a6 13 00 00       	call   3760 <open>
    23ba:	89 c7                	mov    %eax,%edi
  if(fd < 0){
    23bc:	83 c4 10             	add    $0x10,%esp
    23bf:	85 c0                	test   %eax,%eax
    23c1:	78 55                	js     2418 <bigfile+0x119>
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
    23c3:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; ; i++){
    23c8:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(fd, buf, 300);
    23cd:	83 ec 04             	sub    $0x4,%esp
    23d0:	68 2c 01 00 00       	push   $0x12c
    23d5:	68 40 83 00 00       	push   $0x8340
    23da:	57                   	push   %edi
    23db:	e8 58 13 00 00       	call   3738 <read>
    if(cc < 0){
    23e0:	83 c4 10             	add    $0x10,%esp
    23e3:	85 c0                	test   %eax,%eax
    23e5:	78 45                	js     242c <bigfile+0x12d>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
    23e7:	85 c0                	test   %eax,%eax
    23e9:	74 7d                	je     2468 <bigfile+0x169>
      break;
    if(cc != 300){
    23eb:	3d 2c 01 00 00       	cmp    $0x12c,%eax
    23f0:	75 4e                	jne    2440 <bigfile+0x141>
      printf(1, "short read bigfile\n");
      exit();
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    23f2:	0f be 0d 40 83 00 00 	movsbl 0x8340,%ecx
    23f9:	89 da                	mov    %ebx,%edx
    23fb:	c1 ea 1f             	shr    $0x1f,%edx
    23fe:	01 da                	add    %ebx,%edx
    2400:	d1 fa                	sar    %edx
    2402:	39 d1                	cmp    %edx,%ecx
    2404:	75 4e                	jne    2454 <bigfile+0x155>
    2406:	0f be 0d 6b 84 00 00 	movsbl 0x846b,%ecx
    240d:	39 ca                	cmp    %ecx,%edx
    240f:	75 43                	jne    2454 <bigfile+0x155>
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
    2411:	01 c6                	add    %eax,%esi
  for(i = 0; ; i++){
    2413:	83 c3 01             	add    $0x1,%ebx
    cc = read(fd, buf, 300);
    2416:	eb b5                	jmp    23cd <bigfile+0xce>
    printf(1, "cannot open bigfile\n");
    2418:	83 ec 08             	sub    $0x8,%esp
    241b:	68 fa 45 00 00       	push   $0x45fa
    2420:	6a 01                	push   $0x1
    2422:	e8 33 14 00 00       	call   385a <printf>
    exit();
    2427:	e8 f4 12 00 00       	call   3720 <exit>
      printf(1, "read bigfile failed\n");
    242c:	83 ec 08             	sub    $0x8,%esp
    242f:	68 0f 46 00 00       	push   $0x460f
    2434:	6a 01                	push   $0x1
    2436:	e8 1f 14 00 00       	call   385a <printf>
      exit();
    243b:	e8 e0 12 00 00       	call   3720 <exit>
      printf(1, "short read bigfile\n");
    2440:	83 ec 08             	sub    $0x8,%esp
    2443:	68 24 46 00 00       	push   $0x4624
    2448:	6a 01                	push   $0x1
    244a:	e8 0b 14 00 00       	call   385a <printf>
      exit();
    244f:	e8 cc 12 00 00       	call   3720 <exit>
      printf(1, "read bigfile wrong data\n");
    2454:	83 ec 08             	sub    $0x8,%esp
    2457:	68 38 46 00 00       	push   $0x4638
    245c:	6a 01                	push   $0x1
    245e:	e8 f7 13 00 00       	call   385a <printf>
      exit();
    2463:	e8 b8 12 00 00       	call   3720 <exit>
  }
  close(fd);
    2468:	83 ec 0c             	sub    $0xc,%esp
    246b:	57                   	push   %edi
    246c:	e8 d7 12 00 00       	call   3748 <close>
  if(total != 20*600){
    2471:	83 c4 10             	add    $0x10,%esp
    2474:	81 fe e0 2e 00 00    	cmp    $0x2ee0,%esi
    247a:	75 27                	jne    24a3 <bigfile+0x1a4>
    printf(1, "read bigfile wrong total\n");
    exit();
  }
  unlink("bigfile");
    247c:	83 ec 0c             	sub    $0xc,%esp
    247f:	68 dc 45 00 00       	push   $0x45dc
    2484:	e8 e7 12 00 00       	call   3770 <unlink>

  printf(1, "bigfile test ok\n");
    2489:	83 c4 08             	add    $0x8,%esp
    248c:	68 6b 46 00 00       	push   $0x466b
    2491:	6a 01                	push   $0x1
    2493:	e8 c2 13 00 00       	call   385a <printf>
}
    2498:	83 c4 10             	add    $0x10,%esp
    249b:	8d 65 f4             	lea    -0xc(%ebp),%esp
    249e:	5b                   	pop    %ebx
    249f:	5e                   	pop    %esi
    24a0:	5f                   	pop    %edi
    24a1:	5d                   	pop    %ebp
    24a2:	c3                   	ret    
    printf(1, "read bigfile wrong total\n");
    24a3:	83 ec 08             	sub    $0x8,%esp
    24a6:	68 51 46 00 00       	push   $0x4651
    24ab:	6a 01                	push   $0x1
    24ad:	e8 a8 13 00 00       	call   385a <printf>
    exit();
    24b2:	e8 69 12 00 00       	call   3720 <exit>

000024b7 <fourteen>:

void
fourteen(void)
{
    24b7:	55                   	push   %ebp
    24b8:	89 e5                	mov    %esp,%ebp
    24ba:	83 ec 10             	sub    $0x10,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    24bd:	68 7c 46 00 00       	push   $0x467c
    24c2:	6a 01                	push   $0x1
    24c4:	e8 91 13 00 00       	call   385a <printf>

  if(mkdir("12345678901234") != 0){
    24c9:	c7 04 24 b7 46 00 00 	movl   $0x46b7,(%esp)
    24d0:	e8 b3 12 00 00       	call   3788 <mkdir>
    24d5:	83 c4 10             	add    $0x10,%esp
    24d8:	85 c0                	test   %eax,%eax
    24da:	0f 85 9c 00 00 00    	jne    257c <fourteen+0xc5>
    printf(1, "mkdir 12345678901234 failed\n");
    exit();
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    24e0:	83 ec 0c             	sub    $0xc,%esp
    24e3:	68 74 4e 00 00       	push   $0x4e74
    24e8:	e8 9b 12 00 00       	call   3788 <mkdir>
    24ed:	83 c4 10             	add    $0x10,%esp
    24f0:	85 c0                	test   %eax,%eax
    24f2:	0f 85 98 00 00 00    	jne    2590 <fourteen+0xd9>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    exit();
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    24f8:	83 ec 08             	sub    $0x8,%esp
    24fb:	68 00 02 00 00       	push   $0x200
    2500:	68 c4 4e 00 00       	push   $0x4ec4
    2505:	e8 56 12 00 00       	call   3760 <open>
  if(fd < 0){
    250a:	83 c4 10             	add    $0x10,%esp
    250d:	85 c0                	test   %eax,%eax
    250f:	0f 88 8f 00 00 00    	js     25a4 <fourteen+0xed>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    exit();
  }
  close(fd);
    2515:	83 ec 0c             	sub    $0xc,%esp
    2518:	50                   	push   %eax
    2519:	e8 2a 12 00 00       	call   3748 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    251e:	83 c4 08             	add    $0x8,%esp
    2521:	6a 00                	push   $0x0
    2523:	68 34 4f 00 00       	push   $0x4f34
    2528:	e8 33 12 00 00       	call   3760 <open>
  if(fd < 0){
    252d:	83 c4 10             	add    $0x10,%esp
    2530:	85 c0                	test   %eax,%eax
    2532:	0f 88 80 00 00 00    	js     25b8 <fourteen+0x101>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    exit();
  }
  close(fd);
    2538:	83 ec 0c             	sub    $0xc,%esp
    253b:	50                   	push   %eax
    253c:	e8 07 12 00 00       	call   3748 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2541:	c7 04 24 a8 46 00 00 	movl   $0x46a8,(%esp)
    2548:	e8 3b 12 00 00       	call   3788 <mkdir>
    254d:	83 c4 10             	add    $0x10,%esp
    2550:	85 c0                	test   %eax,%eax
    2552:	74 78                	je     25cc <fourteen+0x115>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    exit();
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2554:	83 ec 0c             	sub    $0xc,%esp
    2557:	68 d0 4f 00 00       	push   $0x4fd0
    255c:	e8 27 12 00 00       	call   3788 <mkdir>
    2561:	83 c4 10             	add    $0x10,%esp
    2564:	85 c0                	test   %eax,%eax
    2566:	74 78                	je     25e0 <fourteen+0x129>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    exit();
  }

  printf(1, "fourteen ok\n");
    2568:	83 ec 08             	sub    $0x8,%esp
    256b:	68 c6 46 00 00       	push   $0x46c6
    2570:	6a 01                	push   $0x1
    2572:	e8 e3 12 00 00       	call   385a <printf>
}
    2577:	83 c4 10             	add    $0x10,%esp
    257a:	c9                   	leave  
    257b:	c3                   	ret    
    printf(1, "mkdir 12345678901234 failed\n");
    257c:	83 ec 08             	sub    $0x8,%esp
    257f:	68 8b 46 00 00       	push   $0x468b
    2584:	6a 01                	push   $0x1
    2586:	e8 cf 12 00 00       	call   385a <printf>
    exit();
    258b:	e8 90 11 00 00       	call   3720 <exit>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2590:	83 ec 08             	sub    $0x8,%esp
    2593:	68 94 4e 00 00       	push   $0x4e94
    2598:	6a 01                	push   $0x1
    259a:	e8 bb 12 00 00       	call   385a <printf>
    exit();
    259f:	e8 7c 11 00 00       	call   3720 <exit>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    25a4:	83 ec 08             	sub    $0x8,%esp
    25a7:	68 f4 4e 00 00       	push   $0x4ef4
    25ac:	6a 01                	push   $0x1
    25ae:	e8 a7 12 00 00       	call   385a <printf>
    exit();
    25b3:	e8 68 11 00 00       	call   3720 <exit>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    25b8:	83 ec 08             	sub    $0x8,%esp
    25bb:	68 64 4f 00 00       	push   $0x4f64
    25c0:	6a 01                	push   $0x1
    25c2:	e8 93 12 00 00       	call   385a <printf>
    exit();
    25c7:	e8 54 11 00 00       	call   3720 <exit>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    25cc:	83 ec 08             	sub    $0x8,%esp
    25cf:	68 a0 4f 00 00       	push   $0x4fa0
    25d4:	6a 01                	push   $0x1
    25d6:	e8 7f 12 00 00       	call   385a <printf>
    exit();
    25db:	e8 40 11 00 00       	call   3720 <exit>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    25e0:	83 ec 08             	sub    $0x8,%esp
    25e3:	68 f0 4f 00 00       	push   $0x4ff0
    25e8:	6a 01                	push   $0x1
    25ea:	e8 6b 12 00 00       	call   385a <printf>
    exit();
    25ef:	e8 2c 11 00 00       	call   3720 <exit>

000025f4 <rmdot>:

void
rmdot(void)
{
    25f4:	55                   	push   %ebp
    25f5:	89 e5                	mov    %esp,%ebp
    25f7:	83 ec 10             	sub    $0x10,%esp
  printf(1, "rmdot test\n");
    25fa:	68 d3 46 00 00       	push   $0x46d3
    25ff:	6a 01                	push   $0x1
    2601:	e8 54 12 00 00       	call   385a <printf>
  if(mkdir("dots") != 0){
    2606:	c7 04 24 df 46 00 00 	movl   $0x46df,(%esp)
    260d:	e8 76 11 00 00       	call   3788 <mkdir>
    2612:	83 c4 10             	add    $0x10,%esp
    2615:	85 c0                	test   %eax,%eax
    2617:	0f 85 bc 00 00 00    	jne    26d9 <rmdot+0xe5>
    printf(1, "mkdir dots failed\n");
    exit();
  }
  if(chdir("dots") != 0){
    261d:	83 ec 0c             	sub    $0xc,%esp
    2620:	68 df 46 00 00       	push   $0x46df
    2625:	e8 66 11 00 00       	call   3790 <chdir>
    262a:	83 c4 10             	add    $0x10,%esp
    262d:	85 c0                	test   %eax,%eax
    262f:	0f 85 b8 00 00 00    	jne    26ed <rmdot+0xf9>
    printf(1, "chdir dots failed\n");
    exit();
  }
  if(unlink(".") == 0){
    2635:	83 ec 0c             	sub    $0xc,%esp
    2638:	68 8a 43 00 00       	push   $0x438a
    263d:	e8 2e 11 00 00       	call   3770 <unlink>
    2642:	83 c4 10             	add    $0x10,%esp
    2645:	85 c0                	test   %eax,%eax
    2647:	0f 84 b4 00 00 00    	je     2701 <rmdot+0x10d>
    printf(1, "rm . worked!\n");
    exit();
  }
  if(unlink("..") == 0){
    264d:	83 ec 0c             	sub    $0xc,%esp
    2650:	68 89 43 00 00       	push   $0x4389
    2655:	e8 16 11 00 00       	call   3770 <unlink>
    265a:	83 c4 10             	add    $0x10,%esp
    265d:	85 c0                	test   %eax,%eax
    265f:	0f 84 b0 00 00 00    	je     2715 <rmdot+0x121>
    printf(1, "rm .. worked!\n");
    exit();
  }
  if(chdir("/") != 0){
    2665:	83 ec 0c             	sub    $0xc,%esp
    2668:	68 5d 3b 00 00       	push   $0x3b5d
    266d:	e8 1e 11 00 00       	call   3790 <chdir>
    2672:	83 c4 10             	add    $0x10,%esp
    2675:	85 c0                	test   %eax,%eax
    2677:	0f 85 ac 00 00 00    	jne    2729 <rmdot+0x135>
    printf(1, "chdir / failed\n");
    exit();
  }
  if(unlink("dots/.") == 0){
    267d:	83 ec 0c             	sub    $0xc,%esp
    2680:	68 27 47 00 00       	push   $0x4727
    2685:	e8 e6 10 00 00       	call   3770 <unlink>
    268a:	83 c4 10             	add    $0x10,%esp
    268d:	85 c0                	test   %eax,%eax
    268f:	0f 84 a8 00 00 00    	je     273d <rmdot+0x149>
    printf(1, "unlink dots/. worked!\n");
    exit();
  }
  if(unlink("dots/..") == 0){
    2695:	83 ec 0c             	sub    $0xc,%esp
    2698:	68 45 47 00 00       	push   $0x4745
    269d:	e8 ce 10 00 00       	call   3770 <unlink>
    26a2:	83 c4 10             	add    $0x10,%esp
    26a5:	85 c0                	test   %eax,%eax
    26a7:	0f 84 a4 00 00 00    	je     2751 <rmdot+0x15d>
    printf(1, "unlink dots/.. worked!\n");
    exit();
  }
  if(unlink("dots") != 0){
    26ad:	83 ec 0c             	sub    $0xc,%esp
    26b0:	68 df 46 00 00       	push   $0x46df
    26b5:	e8 b6 10 00 00       	call   3770 <unlink>
    26ba:	83 c4 10             	add    $0x10,%esp
    26bd:	85 c0                	test   %eax,%eax
    26bf:	0f 85 a0 00 00 00    	jne    2765 <rmdot+0x171>
    printf(1, "unlink dots failed!\n");
    exit();
  }
  printf(1, "rmdot ok\n");
    26c5:	83 ec 08             	sub    $0x8,%esp
    26c8:	68 7a 47 00 00       	push   $0x477a
    26cd:	6a 01                	push   $0x1
    26cf:	e8 86 11 00 00       	call   385a <printf>
}
    26d4:	83 c4 10             	add    $0x10,%esp
    26d7:	c9                   	leave  
    26d8:	c3                   	ret    
    printf(1, "mkdir dots failed\n");
    26d9:	83 ec 08             	sub    $0x8,%esp
    26dc:	68 e4 46 00 00       	push   $0x46e4
    26e1:	6a 01                	push   $0x1
    26e3:	e8 72 11 00 00       	call   385a <printf>
    exit();
    26e8:	e8 33 10 00 00       	call   3720 <exit>
    printf(1, "chdir dots failed\n");
    26ed:	83 ec 08             	sub    $0x8,%esp
    26f0:	68 f7 46 00 00       	push   $0x46f7
    26f5:	6a 01                	push   $0x1
    26f7:	e8 5e 11 00 00       	call   385a <printf>
    exit();
    26fc:	e8 1f 10 00 00       	call   3720 <exit>
    printf(1, "rm . worked!\n");
    2701:	83 ec 08             	sub    $0x8,%esp
    2704:	68 0a 47 00 00       	push   $0x470a
    2709:	6a 01                	push   $0x1
    270b:	e8 4a 11 00 00       	call   385a <printf>
    exit();
    2710:	e8 0b 10 00 00       	call   3720 <exit>
    printf(1, "rm .. worked!\n");
    2715:	83 ec 08             	sub    $0x8,%esp
    2718:	68 18 47 00 00       	push   $0x4718
    271d:	6a 01                	push   $0x1
    271f:	e8 36 11 00 00       	call   385a <printf>
    exit();
    2724:	e8 f7 0f 00 00       	call   3720 <exit>
    printf(1, "chdir / failed\n");
    2729:	83 ec 08             	sub    $0x8,%esp
    272c:	68 5f 3b 00 00       	push   $0x3b5f
    2731:	6a 01                	push   $0x1
    2733:	e8 22 11 00 00       	call   385a <printf>
    exit();
    2738:	e8 e3 0f 00 00       	call   3720 <exit>
    printf(1, "unlink dots/. worked!\n");
    273d:	83 ec 08             	sub    $0x8,%esp
    2740:	68 2e 47 00 00       	push   $0x472e
    2745:	6a 01                	push   $0x1
    2747:	e8 0e 11 00 00       	call   385a <printf>
    exit();
    274c:	e8 cf 0f 00 00       	call   3720 <exit>
    printf(1, "unlink dots/.. worked!\n");
    2751:	83 ec 08             	sub    $0x8,%esp
    2754:	68 4d 47 00 00       	push   $0x474d
    2759:	6a 01                	push   $0x1
    275b:	e8 fa 10 00 00       	call   385a <printf>
    exit();
    2760:	e8 bb 0f 00 00       	call   3720 <exit>
    printf(1, "unlink dots failed!\n");
    2765:	83 ec 08             	sub    $0x8,%esp
    2768:	68 65 47 00 00       	push   $0x4765
    276d:	6a 01                	push   $0x1
    276f:	e8 e6 10 00 00       	call   385a <printf>
    exit();
    2774:	e8 a7 0f 00 00       	call   3720 <exit>

00002779 <dirfile>:

void
dirfile(void)
{
    2779:	55                   	push   %ebp
    277a:	89 e5                	mov    %esp,%ebp
    277c:	53                   	push   %ebx
    277d:	83 ec 0c             	sub    $0xc,%esp
  int fd;

  printf(1, "dir vs file\n");
    2780:	68 84 47 00 00       	push   $0x4784
    2785:	6a 01                	push   $0x1
    2787:	e8 ce 10 00 00       	call   385a <printf>

  fd = open("dirfile", O_CREATE);
    278c:	83 c4 08             	add    $0x8,%esp
    278f:	68 00 02 00 00       	push   $0x200
    2794:	68 91 47 00 00       	push   $0x4791
    2799:	e8 c2 0f 00 00       	call   3760 <open>
  if(fd < 0){
    279e:	83 c4 10             	add    $0x10,%esp
    27a1:	85 c0                	test   %eax,%eax
    27a3:	0f 88 22 01 00 00    	js     28cb <dirfile+0x152>
    printf(1, "create dirfile failed\n");
    exit();
  }
  close(fd);
    27a9:	83 ec 0c             	sub    $0xc,%esp
    27ac:	50                   	push   %eax
    27ad:	e8 96 0f 00 00       	call   3748 <close>
  if(chdir("dirfile") == 0){
    27b2:	c7 04 24 91 47 00 00 	movl   $0x4791,(%esp)
    27b9:	e8 d2 0f 00 00       	call   3790 <chdir>
    27be:	83 c4 10             	add    $0x10,%esp
    27c1:	85 c0                	test   %eax,%eax
    27c3:	0f 84 16 01 00 00    	je     28df <dirfile+0x166>
    printf(1, "chdir dirfile succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", 0);
    27c9:	83 ec 08             	sub    $0x8,%esp
    27cc:	6a 00                	push   $0x0
    27ce:	68 ca 47 00 00       	push   $0x47ca
    27d3:	e8 88 0f 00 00       	call   3760 <open>
  if(fd >= 0){
    27d8:	83 c4 10             	add    $0x10,%esp
    27db:	85 c0                	test   %eax,%eax
    27dd:	0f 89 10 01 00 00    	jns    28f3 <dirfile+0x17a>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", O_CREATE);
    27e3:	83 ec 08             	sub    $0x8,%esp
    27e6:	68 00 02 00 00       	push   $0x200
    27eb:	68 ca 47 00 00       	push   $0x47ca
    27f0:	e8 6b 0f 00 00       	call   3760 <open>
  if(fd >= 0){
    27f5:	83 c4 10             	add    $0x10,%esp
    27f8:	85 c0                	test   %eax,%eax
    27fa:	0f 89 07 01 00 00    	jns    2907 <dirfile+0x18e>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  if(mkdir("dirfile/xx") == 0){
    2800:	83 ec 0c             	sub    $0xc,%esp
    2803:	68 ca 47 00 00       	push   $0x47ca
    2808:	e8 7b 0f 00 00       	call   3788 <mkdir>
    280d:	83 c4 10             	add    $0x10,%esp
    2810:	85 c0                	test   %eax,%eax
    2812:	0f 84 03 01 00 00    	je     291b <dirfile+0x1a2>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile/xx") == 0){
    2818:	83 ec 0c             	sub    $0xc,%esp
    281b:	68 ca 47 00 00       	push   $0x47ca
    2820:	e8 4b 0f 00 00       	call   3770 <unlink>
    2825:	83 c4 10             	add    $0x10,%esp
    2828:	85 c0                	test   %eax,%eax
    282a:	0f 84 ff 00 00 00    	je     292f <dirfile+0x1b6>
    printf(1, "unlink dirfile/xx succeeded!\n");
    exit();
  }
  if(link("README", "dirfile/xx") == 0){
    2830:	83 ec 08             	sub    $0x8,%esp
    2833:	68 ca 47 00 00       	push   $0x47ca
    2838:	68 2e 48 00 00       	push   $0x482e
    283d:	e8 3e 0f 00 00       	call   3780 <link>
    2842:	83 c4 10             	add    $0x10,%esp
    2845:	85 c0                	test   %eax,%eax
    2847:	0f 84 f6 00 00 00    	je     2943 <dirfile+0x1ca>
    printf(1, "link to dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile") != 0){
    284d:	83 ec 0c             	sub    $0xc,%esp
    2850:	68 91 47 00 00       	push   $0x4791
    2855:	e8 16 0f 00 00       	call   3770 <unlink>
    285a:	83 c4 10             	add    $0x10,%esp
    285d:	85 c0                	test   %eax,%eax
    285f:	0f 85 f2 00 00 00    	jne    2957 <dirfile+0x1de>
    printf(1, "unlink dirfile failed!\n");
    exit();
  }

  fd = open(".", O_RDWR);
    2865:	83 ec 08             	sub    $0x8,%esp
    2868:	6a 02                	push   $0x2
    286a:	68 8a 43 00 00       	push   $0x438a
    286f:	e8 ec 0e 00 00       	call   3760 <open>
  if(fd >= 0){
    2874:	83 c4 10             	add    $0x10,%esp
    2877:	85 c0                	test   %eax,%eax
    2879:	0f 89 ec 00 00 00    	jns    296b <dirfile+0x1f2>
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
    287f:	83 ec 08             	sub    $0x8,%esp
    2882:	6a 00                	push   $0x0
    2884:	68 8a 43 00 00       	push   $0x438a
    2889:	e8 d2 0e 00 00       	call   3760 <open>
    288e:	89 c3                	mov    %eax,%ebx
  if(write(fd, "x", 1) > 0){
    2890:	83 c4 0c             	add    $0xc,%esp
    2893:	6a 01                	push   $0x1
    2895:	68 6d 44 00 00       	push   $0x446d
    289a:	50                   	push   %eax
    289b:	e8 a0 0e 00 00       	call   3740 <write>
    28a0:	83 c4 10             	add    $0x10,%esp
    28a3:	85 c0                	test   %eax,%eax
    28a5:	0f 8f d4 00 00 00    	jg     297f <dirfile+0x206>
    printf(1, "write . succeeded!\n");
    exit();
  }
  close(fd);
    28ab:	83 ec 0c             	sub    $0xc,%esp
    28ae:	53                   	push   %ebx
    28af:	e8 94 0e 00 00       	call   3748 <close>

  printf(1, "dir vs file OK\n");
    28b4:	83 c4 08             	add    $0x8,%esp
    28b7:	68 61 48 00 00       	push   $0x4861
    28bc:	6a 01                	push   $0x1
    28be:	e8 97 0f 00 00       	call   385a <printf>
}
    28c3:	83 c4 10             	add    $0x10,%esp
    28c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    28c9:	c9                   	leave  
    28ca:	c3                   	ret    
    printf(1, "create dirfile failed\n");
    28cb:	83 ec 08             	sub    $0x8,%esp
    28ce:	68 99 47 00 00       	push   $0x4799
    28d3:	6a 01                	push   $0x1
    28d5:	e8 80 0f 00 00       	call   385a <printf>
    exit();
    28da:	e8 41 0e 00 00       	call   3720 <exit>
    printf(1, "chdir dirfile succeeded!\n");
    28df:	83 ec 08             	sub    $0x8,%esp
    28e2:	68 b0 47 00 00       	push   $0x47b0
    28e7:	6a 01                	push   $0x1
    28e9:	e8 6c 0f 00 00       	call   385a <printf>
    exit();
    28ee:	e8 2d 0e 00 00       	call   3720 <exit>
    printf(1, "create dirfile/xx succeeded!\n");
    28f3:	83 ec 08             	sub    $0x8,%esp
    28f6:	68 d5 47 00 00       	push   $0x47d5
    28fb:	6a 01                	push   $0x1
    28fd:	e8 58 0f 00 00       	call   385a <printf>
    exit();
    2902:	e8 19 0e 00 00       	call   3720 <exit>
    printf(1, "create dirfile/xx succeeded!\n");
    2907:	83 ec 08             	sub    $0x8,%esp
    290a:	68 d5 47 00 00       	push   $0x47d5
    290f:	6a 01                	push   $0x1
    2911:	e8 44 0f 00 00       	call   385a <printf>
    exit();
    2916:	e8 05 0e 00 00       	call   3720 <exit>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    291b:	83 ec 08             	sub    $0x8,%esp
    291e:	68 f3 47 00 00       	push   $0x47f3
    2923:	6a 01                	push   $0x1
    2925:	e8 30 0f 00 00       	call   385a <printf>
    exit();
    292a:	e8 f1 0d 00 00       	call   3720 <exit>
    printf(1, "unlink dirfile/xx succeeded!\n");
    292f:	83 ec 08             	sub    $0x8,%esp
    2932:	68 10 48 00 00       	push   $0x4810
    2937:	6a 01                	push   $0x1
    2939:	e8 1c 0f 00 00       	call   385a <printf>
    exit();
    293e:	e8 dd 0d 00 00       	call   3720 <exit>
    printf(1, "link to dirfile/xx succeeded!\n");
    2943:	83 ec 08             	sub    $0x8,%esp
    2946:	68 24 50 00 00       	push   $0x5024
    294b:	6a 01                	push   $0x1
    294d:	e8 08 0f 00 00       	call   385a <printf>
    exit();
    2952:	e8 c9 0d 00 00       	call   3720 <exit>
    printf(1, "unlink dirfile failed!\n");
    2957:	83 ec 08             	sub    $0x8,%esp
    295a:	68 35 48 00 00       	push   $0x4835
    295f:	6a 01                	push   $0x1
    2961:	e8 f4 0e 00 00       	call   385a <printf>
    exit();
    2966:	e8 b5 0d 00 00       	call   3720 <exit>
    printf(1, "open . for writing succeeded!\n");
    296b:	83 ec 08             	sub    $0x8,%esp
    296e:	68 44 50 00 00       	push   $0x5044
    2973:	6a 01                	push   $0x1
    2975:	e8 e0 0e 00 00       	call   385a <printf>
    exit();
    297a:	e8 a1 0d 00 00       	call   3720 <exit>
    printf(1, "write . succeeded!\n");
    297f:	83 ec 08             	sub    $0x8,%esp
    2982:	68 4d 48 00 00       	push   $0x484d
    2987:	6a 01                	push   $0x1
    2989:	e8 cc 0e 00 00       	call   385a <printf>
    exit();
    298e:	e8 8d 0d 00 00       	call   3720 <exit>

00002993 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2993:	55                   	push   %ebp
    2994:	89 e5                	mov    %esp,%ebp
    2996:	53                   	push   %ebx
    2997:	83 ec 0c             	sub    $0xc,%esp
  int i, fd;

  printf(1, "empty file name\n");
    299a:	68 71 48 00 00       	push   $0x4871
    299f:	6a 01                	push   $0x1
    29a1:	e8 b4 0e 00 00       	call   385a <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    29a6:	83 c4 10             	add    $0x10,%esp
    29a9:	bb 00 00 00 00       	mov    $0x0,%ebx
    29ae:	eb 4c                	jmp    29fc <iref+0x69>
    if(mkdir("irefd") != 0){
      printf(1, "mkdir irefd failed\n");
    29b0:	83 ec 08             	sub    $0x8,%esp
    29b3:	68 88 48 00 00       	push   $0x4888
    29b8:	6a 01                	push   $0x1
    29ba:	e8 9b 0e 00 00       	call   385a <printf>
      exit();
    29bf:	e8 5c 0d 00 00       	call   3720 <exit>
    }
    if(chdir("irefd") != 0){
      printf(1, "chdir irefd failed\n");
    29c4:	83 ec 08             	sub    $0x8,%esp
    29c7:	68 9c 48 00 00       	push   $0x489c
    29cc:	6a 01                	push   $0x1
    29ce:	e8 87 0e 00 00       	call   385a <printf>
      exit();
    29d3:	e8 48 0d 00 00       	call   3720 <exit>

    mkdir("");
    link("README", "");
    fd = open("", O_CREATE);
    if(fd >= 0)
      close(fd);
    29d8:	83 ec 0c             	sub    $0xc,%esp
    29db:	50                   	push   %eax
    29dc:	e8 67 0d 00 00       	call   3748 <close>
    29e1:	83 c4 10             	add    $0x10,%esp
    29e4:	e9 80 00 00 00       	jmp    2a69 <iref+0xd6>
    fd = open("xx", O_CREATE);
    if(fd >= 0)
      close(fd);
    unlink("xx");
    29e9:	83 ec 0c             	sub    $0xc,%esp
    29ec:	68 6c 44 00 00       	push   $0x446c
    29f1:	e8 7a 0d 00 00       	call   3770 <unlink>
  for(i = 0; i < 50 + 1; i++){
    29f6:	83 c3 01             	add    $0x1,%ebx
    29f9:	83 c4 10             	add    $0x10,%esp
    29fc:	83 fb 32             	cmp    $0x32,%ebx
    29ff:	0f 8f 92 00 00 00    	jg     2a97 <iref+0x104>
    if(mkdir("irefd") != 0){
    2a05:	83 ec 0c             	sub    $0xc,%esp
    2a08:	68 82 48 00 00       	push   $0x4882
    2a0d:	e8 76 0d 00 00       	call   3788 <mkdir>
    2a12:	83 c4 10             	add    $0x10,%esp
    2a15:	85 c0                	test   %eax,%eax
    2a17:	75 97                	jne    29b0 <iref+0x1d>
    if(chdir("irefd") != 0){
    2a19:	83 ec 0c             	sub    $0xc,%esp
    2a1c:	68 82 48 00 00       	push   $0x4882
    2a21:	e8 6a 0d 00 00       	call   3790 <chdir>
    2a26:	83 c4 10             	add    $0x10,%esp
    2a29:	85 c0                	test   %eax,%eax
    2a2b:	75 97                	jne    29c4 <iref+0x31>
    mkdir("");
    2a2d:	83 ec 0c             	sub    $0xc,%esp
    2a30:	68 37 3f 00 00       	push   $0x3f37
    2a35:	e8 4e 0d 00 00       	call   3788 <mkdir>
    link("README", "");
    2a3a:	83 c4 08             	add    $0x8,%esp
    2a3d:	68 37 3f 00 00       	push   $0x3f37
    2a42:	68 2e 48 00 00       	push   $0x482e
    2a47:	e8 34 0d 00 00       	call   3780 <link>
    fd = open("", O_CREATE);
    2a4c:	83 c4 08             	add    $0x8,%esp
    2a4f:	68 00 02 00 00       	push   $0x200
    2a54:	68 37 3f 00 00       	push   $0x3f37
    2a59:	e8 02 0d 00 00       	call   3760 <open>
    if(fd >= 0)
    2a5e:	83 c4 10             	add    $0x10,%esp
    2a61:	85 c0                	test   %eax,%eax
    2a63:	0f 89 6f ff ff ff    	jns    29d8 <iref+0x45>
    fd = open("xx", O_CREATE);
    2a69:	83 ec 08             	sub    $0x8,%esp
    2a6c:	68 00 02 00 00       	push   $0x200
    2a71:	68 6c 44 00 00       	push   $0x446c
    2a76:	e8 e5 0c 00 00       	call   3760 <open>
    if(fd >= 0)
    2a7b:	83 c4 10             	add    $0x10,%esp
    2a7e:	85 c0                	test   %eax,%eax
    2a80:	0f 88 63 ff ff ff    	js     29e9 <iref+0x56>
      close(fd);
    2a86:	83 ec 0c             	sub    $0xc,%esp
    2a89:	50                   	push   %eax
    2a8a:	e8 b9 0c 00 00       	call   3748 <close>
    2a8f:	83 c4 10             	add    $0x10,%esp
    2a92:	e9 52 ff ff ff       	jmp    29e9 <iref+0x56>
  }

  chdir("/");
    2a97:	83 ec 0c             	sub    $0xc,%esp
    2a9a:	68 5d 3b 00 00       	push   $0x3b5d
    2a9f:	e8 ec 0c 00 00       	call   3790 <chdir>
  printf(1, "empty file name OK\n");
    2aa4:	83 c4 08             	add    $0x8,%esp
    2aa7:	68 b0 48 00 00       	push   $0x48b0
    2aac:	6a 01                	push   $0x1
    2aae:	e8 a7 0d 00 00       	call   385a <printf>
}
    2ab3:	83 c4 10             	add    $0x10,%esp
    2ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    2ab9:	c9                   	leave  
    2aba:	c3                   	ret    

00002abb <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2abb:	55                   	push   %ebp
    2abc:	89 e5                	mov    %esp,%ebp
    2abe:	53                   	push   %ebx
    2abf:	83 ec 0c             	sub    $0xc,%esp
  int n, pid;

  printf(1, "fork test\n");
    2ac2:	68 c4 48 00 00       	push   $0x48c4
    2ac7:	6a 01                	push   $0x1
    2ac9:	e8 8c 0d 00 00       	call   385a <printf>

  for(n=0; n<1000; n++){
    2ace:	83 c4 10             	add    $0x10,%esp
    2ad1:	bb 00 00 00 00       	mov    $0x0,%ebx
    2ad6:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
    2adc:	7f 17                	jg     2af5 <forktest+0x3a>
    pid = fork();
    2ade:	e8 35 0c 00 00       	call   3718 <fork>
    if(pid < 0)
    2ae3:	85 c0                	test   %eax,%eax
    2ae5:	78 0e                	js     2af5 <forktest+0x3a>
      break;
    if(pid == 0)
    2ae7:	85 c0                	test   %eax,%eax
    2ae9:	74 05                	je     2af0 <forktest+0x35>
  for(n=0; n<1000; n++){
    2aeb:	83 c3 01             	add    $0x1,%ebx
    2aee:	eb e6                	jmp    2ad6 <forktest+0x1b>
      exit();
    2af0:	e8 2b 0c 00 00       	call   3720 <exit>
  }

  if(n == 1000){
    2af5:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
    2afb:	74 12                	je     2b0f <forktest+0x54>
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }

  for(; n > 0; n--){
    2afd:	85 db                	test   %ebx,%ebx
    2aff:	7e 36                	jle    2b37 <forktest+0x7c>
    if(wait() < 0){
    2b01:	e8 22 0c 00 00       	call   3728 <wait>
    2b06:	85 c0                	test   %eax,%eax
    2b08:	78 19                	js     2b23 <forktest+0x68>
  for(; n > 0; n--){
    2b0a:	83 eb 01             	sub    $0x1,%ebx
    2b0d:	eb ee                	jmp    2afd <forktest+0x42>
    printf(1, "fork claimed to work 1000 times!\n");
    2b0f:	83 ec 08             	sub    $0x8,%esp
    2b12:	68 64 50 00 00       	push   $0x5064
    2b17:	6a 01                	push   $0x1
    2b19:	e8 3c 0d 00 00       	call   385a <printf>
    exit();
    2b1e:	e8 fd 0b 00 00       	call   3720 <exit>
      printf(1, "wait stopped early\n");
    2b23:	83 ec 08             	sub    $0x8,%esp
    2b26:	68 cf 48 00 00       	push   $0x48cf
    2b2b:	6a 01                	push   $0x1
    2b2d:	e8 28 0d 00 00       	call   385a <printf>
      exit();
    2b32:	e8 e9 0b 00 00       	call   3720 <exit>
    }
  }

  if(wait() != -1){
    2b37:	e8 ec 0b 00 00       	call   3728 <wait>
    2b3c:	83 f8 ff             	cmp    $0xffffffff,%eax
    2b3f:	75 17                	jne    2b58 <forktest+0x9d>
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "fork test OK\n");
    2b41:	83 ec 08             	sub    $0x8,%esp
    2b44:	68 f6 48 00 00       	push   $0x48f6
    2b49:	6a 01                	push   $0x1
    2b4b:	e8 0a 0d 00 00       	call   385a <printf>
}
    2b50:	83 c4 10             	add    $0x10,%esp
    2b53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    2b56:	c9                   	leave  
    2b57:	c3                   	ret    
    printf(1, "wait got too many\n");
    2b58:	83 ec 08             	sub    $0x8,%esp
    2b5b:	68 e3 48 00 00       	push   $0x48e3
    2b60:	6a 01                	push   $0x1
    2b62:	e8 f3 0c 00 00       	call   385a <printf>
    exit();
    2b67:	e8 b4 0b 00 00       	call   3720 <exit>

00002b6c <sbrktest>:

void
sbrktest(void)
{
    2b6c:	55                   	push   %ebp
    2b6d:	89 e5                	mov    %esp,%ebp
    2b6f:	57                   	push   %edi
    2b70:	56                   	push   %esi
    2b71:	53                   	push   %ebx
    2b72:	83 ec 54             	sub    $0x54,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    2b75:	68 04 49 00 00       	push   $0x4904
    2b7a:	ff 35 54 5b 00 00    	pushl  0x5b54
    2b80:	e8 d5 0c 00 00       	call   385a <printf>
  oldbrk = sbrk(0);
    2b85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2b8c:	e8 17 0c 00 00       	call   37a8 <sbrk>
    2b91:	89 c7                	mov    %eax,%edi

  // can one sbrk() less than a page?
  a = sbrk(0);
    2b93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2b9a:	e8 09 0c 00 00       	call   37a8 <sbrk>
    2b9f:	89 c6                	mov    %eax,%esi
  int i;
  for(i = 0; i < 5000; i++){
    2ba1:	83 c4 10             	add    $0x10,%esp
    2ba4:	bb 00 00 00 00       	mov    $0x0,%ebx
    2ba9:	81 fb 87 13 00 00    	cmp    $0x1387,%ebx
    2baf:	7f 3a                	jg     2beb <sbrktest+0x7f>
    b = sbrk(1);
    2bb1:	83 ec 0c             	sub    $0xc,%esp
    2bb4:	6a 01                	push   $0x1
    2bb6:	e8 ed 0b 00 00       	call   37a8 <sbrk>
    if(b != a){
    2bbb:	83 c4 10             	add    $0x10,%esp
    2bbe:	39 c6                	cmp    %eax,%esi
    2bc0:	75 0b                	jne    2bcd <sbrktest+0x61>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
      exit();
    }
    *b = 1;
    2bc2:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    2bc5:	8d 70 01             	lea    0x1(%eax),%esi
  for(i = 0; i < 5000; i++){
    2bc8:	83 c3 01             	add    $0x1,%ebx
    2bcb:	eb dc                	jmp    2ba9 <sbrktest+0x3d>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    2bcd:	83 ec 0c             	sub    $0xc,%esp
    2bd0:	50                   	push   %eax
    2bd1:	56                   	push   %esi
    2bd2:	53                   	push   %ebx
    2bd3:	68 0f 49 00 00       	push   $0x490f
    2bd8:	ff 35 54 5b 00 00    	pushl  0x5b54
    2bde:	e8 77 0c 00 00       	call   385a <printf>
      exit();
    2be3:	83 c4 20             	add    $0x20,%esp
    2be6:	e8 35 0b 00 00       	call   3720 <exit>
  }
  pid = fork();
    2beb:	e8 28 0b 00 00       	call   3718 <fork>
    2bf0:	89 c3                	mov    %eax,%ebx
  if(pid < 0){
    2bf2:	85 c0                	test   %eax,%eax
    2bf4:	0f 88 53 01 00 00    	js     2d4d <sbrktest+0x1e1>
    printf(stdout, "sbrk test fork failed\n");
    exit();
  }
  c = sbrk(1);
    2bfa:	83 ec 0c             	sub    $0xc,%esp
    2bfd:	6a 01                	push   $0x1
    2bff:	e8 a4 0b 00 00       	call   37a8 <sbrk>
  c = sbrk(1);
    2c04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c0b:	e8 98 0b 00 00       	call   37a8 <sbrk>
  if(c != a + 1){
    2c10:	83 c6 01             	add    $0x1,%esi
    2c13:	83 c4 10             	add    $0x10,%esp
    2c16:	39 c6                	cmp    %eax,%esi
    2c18:	0f 85 47 01 00 00    	jne    2d65 <sbrktest+0x1f9>
    printf(stdout, "sbrk test failed post-fork\n");
    exit();
  }
  if(pid == 0)
    2c1e:	85 db                	test   %ebx,%ebx
    2c20:	0f 84 57 01 00 00    	je     2d7d <sbrktest+0x211>
    exit();
  wait();
    2c26:	e8 fd 0a 00 00       	call   3728 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    2c2b:	83 ec 0c             	sub    $0xc,%esp
    2c2e:	6a 00                	push   $0x0
    2c30:	e8 73 0b 00 00       	call   37a8 <sbrk>
    2c35:	89 c3                	mov    %eax,%ebx
  amt = (BIG) - (uint)a;
    2c37:	b8 00 00 40 06       	mov    $0x6400000,%eax
    2c3c:	29 d8                	sub    %ebx,%eax
  p = sbrk(amt);
    2c3e:	89 04 24             	mov    %eax,(%esp)
    2c41:	e8 62 0b 00 00       	call   37a8 <sbrk>
  if (p != a) {
    2c46:	83 c4 10             	add    $0x10,%esp
    2c49:	39 c3                	cmp    %eax,%ebx
    2c4b:	0f 85 31 01 00 00    	jne    2d82 <sbrktest+0x216>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    exit();
  }
  lastaddr = (char*) (BIG-1);
  *lastaddr = 99;
    2c51:	c6 05 ff ff 3f 06 63 	movb   $0x63,0x63fffff

  // can one de-allocate?
  a = sbrk(0);
    2c58:	83 ec 0c             	sub    $0xc,%esp
    2c5b:	6a 00                	push   $0x0
    2c5d:	e8 46 0b 00 00       	call   37a8 <sbrk>
    2c62:	89 c3                	mov    %eax,%ebx
  c = sbrk(-4096);
    2c64:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    2c6b:	e8 38 0b 00 00       	call   37a8 <sbrk>
  if(c == (char*)0xffffffff){
    2c70:	83 c4 10             	add    $0x10,%esp
    2c73:	83 f8 ff             	cmp    $0xffffffff,%eax
    2c76:	0f 84 1e 01 00 00    	je     2d9a <sbrktest+0x22e>
    printf(stdout, "sbrk could not deallocate\n");
    exit();
  }
  c = sbrk(0);
    2c7c:	83 ec 0c             	sub    $0xc,%esp
    2c7f:	6a 00                	push   $0x0
    2c81:	e8 22 0b 00 00       	call   37a8 <sbrk>
  if(c != a - 4096){
    2c86:	8d 93 00 f0 ff ff    	lea    -0x1000(%ebx),%edx
    2c8c:	83 c4 10             	add    $0x10,%esp
    2c8f:	39 c2                	cmp    %eax,%edx
    2c91:	0f 85 1b 01 00 00    	jne    2db2 <sbrktest+0x246>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    exit();
  }

  // can one re-allocate that page?
  a = sbrk(0);
    2c97:	83 ec 0c             	sub    $0xc,%esp
    2c9a:	6a 00                	push   $0x0
    2c9c:	e8 07 0b 00 00       	call   37a8 <sbrk>
    2ca1:	89 c3                	mov    %eax,%ebx
  c = sbrk(4096);
    2ca3:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    2caa:	e8 f9 0a 00 00       	call   37a8 <sbrk>
    2caf:	89 c6                	mov    %eax,%esi
  if(c != a || sbrk(0) != a + 4096){
    2cb1:	83 c4 10             	add    $0x10,%esp
    2cb4:	39 c3                	cmp    %eax,%ebx
    2cb6:	0f 85 0d 01 00 00    	jne    2dc9 <sbrktest+0x25d>
    2cbc:	83 ec 0c             	sub    $0xc,%esp
    2cbf:	6a 00                	push   $0x0
    2cc1:	e8 e2 0a 00 00       	call   37a8 <sbrk>
    2cc6:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
    2ccc:	83 c4 10             	add    $0x10,%esp
    2ccf:	39 d0                	cmp    %edx,%eax
    2cd1:	0f 85 f2 00 00 00    	jne    2dc9 <sbrktest+0x25d>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    exit();
  }
  if(*lastaddr == 99){
    2cd7:	80 3d ff ff 3f 06 63 	cmpb   $0x63,0x63fffff
    2cde:	0f 84 fc 00 00 00    	je     2de0 <sbrktest+0x274>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    exit();
  }

  a = sbrk(0);
    2ce4:	83 ec 0c             	sub    $0xc,%esp
    2ce7:	6a 00                	push   $0x0
    2ce9:	e8 ba 0a 00 00       	call   37a8 <sbrk>
    2cee:	89 c3                	mov    %eax,%ebx
  c = sbrk(-(sbrk(0) - oldbrk));
    2cf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2cf7:	e8 ac 0a 00 00       	call   37a8 <sbrk>
    2cfc:	89 f9                	mov    %edi,%ecx
    2cfe:	29 c1                	sub    %eax,%ecx
    2d00:	89 0c 24             	mov    %ecx,(%esp)
    2d03:	e8 a0 0a 00 00       	call   37a8 <sbrk>
  if(c != a){
    2d08:	83 c4 10             	add    $0x10,%esp
    2d0b:	39 c3                	cmp    %eax,%ebx
    2d0d:	0f 85 e5 00 00 00    	jne    2df8 <sbrktest+0x28c>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2d13:	bb 00 00 00 80       	mov    $0x80000000,%ebx
    2d18:	81 fb 7f 84 1e 80    	cmp    $0x801e847f,%ebx
    2d1e:	0f 87 25 01 00 00    	ja     2e49 <sbrktest+0x2dd>
    ppid = getpid();
    2d24:	e8 77 0a 00 00       	call   37a0 <getpid>
    2d29:	89 c6                	mov    %eax,%esi
    pid = fork();
    2d2b:	e8 e8 09 00 00       	call   3718 <fork>
    if(pid < 0){
    2d30:	85 c0                	test   %eax,%eax
    2d32:	0f 88 d7 00 00 00    	js     2e0f <sbrktest+0x2a3>
      printf(stdout, "fork failed\n");
      exit();
    }
    if(pid == 0){
    2d38:	85 c0                	test   %eax,%eax
    2d3a:	0f 84 e7 00 00 00    	je     2e27 <sbrktest+0x2bb>
      printf(stdout, "oops could read %x = %x\n", a, *a);
      kill(ppid);
      exit();
    }
    wait();
    2d40:	e8 e3 09 00 00       	call   3728 <wait>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2d45:	81 c3 50 c3 00 00    	add    $0xc350,%ebx
    2d4b:	eb cb                	jmp    2d18 <sbrktest+0x1ac>
    printf(stdout, "sbrk test fork failed\n");
    2d4d:	83 ec 08             	sub    $0x8,%esp
    2d50:	68 2a 49 00 00       	push   $0x492a
    2d55:	ff 35 54 5b 00 00    	pushl  0x5b54
    2d5b:	e8 fa 0a 00 00       	call   385a <printf>
    exit();
    2d60:	e8 bb 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk test failed post-fork\n");
    2d65:	83 ec 08             	sub    $0x8,%esp
    2d68:	68 41 49 00 00       	push   $0x4941
    2d6d:	ff 35 54 5b 00 00    	pushl  0x5b54
    2d73:	e8 e2 0a 00 00       	call   385a <printf>
    exit();
    2d78:	e8 a3 09 00 00       	call   3720 <exit>
    exit();
    2d7d:	e8 9e 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    2d82:	83 ec 08             	sub    $0x8,%esp
    2d85:	68 88 50 00 00       	push   $0x5088
    2d8a:	ff 35 54 5b 00 00    	pushl  0x5b54
    2d90:	e8 c5 0a 00 00       	call   385a <printf>
    exit();
    2d95:	e8 86 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk could not deallocate\n");
    2d9a:	83 ec 08             	sub    $0x8,%esp
    2d9d:	68 5d 49 00 00       	push   $0x495d
    2da2:	ff 35 54 5b 00 00    	pushl  0x5b54
    2da8:	e8 ad 0a 00 00       	call   385a <printf>
    exit();
    2dad:	e8 6e 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    2db2:	50                   	push   %eax
    2db3:	53                   	push   %ebx
    2db4:	68 c8 50 00 00       	push   $0x50c8
    2db9:	ff 35 54 5b 00 00    	pushl  0x5b54
    2dbf:	e8 96 0a 00 00       	call   385a <printf>
    exit();
    2dc4:	e8 57 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    2dc9:	56                   	push   %esi
    2dca:	53                   	push   %ebx
    2dcb:	68 00 51 00 00       	push   $0x5100
    2dd0:	ff 35 54 5b 00 00    	pushl  0x5b54
    2dd6:	e8 7f 0a 00 00       	call   385a <printf>
    exit();
    2ddb:	e8 40 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    2de0:	83 ec 08             	sub    $0x8,%esp
    2de3:	68 28 51 00 00       	push   $0x5128
    2de8:	ff 35 54 5b 00 00    	pushl  0x5b54
    2dee:	e8 67 0a 00 00       	call   385a <printf>
    exit();
    2df3:	e8 28 09 00 00       	call   3720 <exit>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    2df8:	50                   	push   %eax
    2df9:	53                   	push   %ebx
    2dfa:	68 58 51 00 00       	push   $0x5158
    2dff:	ff 35 54 5b 00 00    	pushl  0x5b54
    2e05:	e8 50 0a 00 00       	call   385a <printf>
    exit();
    2e0a:	e8 11 09 00 00       	call   3720 <exit>
      printf(stdout, "fork failed\n");
    2e0f:	83 ec 08             	sub    $0x8,%esp
    2e12:	68 55 4a 00 00       	push   $0x4a55
    2e17:	ff 35 54 5b 00 00    	pushl  0x5b54
    2e1d:	e8 38 0a 00 00       	call   385a <printf>
      exit();
    2e22:	e8 f9 08 00 00       	call   3720 <exit>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    2e27:	0f be 03             	movsbl (%ebx),%eax
    2e2a:	50                   	push   %eax
    2e2b:	53                   	push   %ebx
    2e2c:	68 78 49 00 00       	push   $0x4978
    2e31:	ff 35 54 5b 00 00    	pushl  0x5b54
    2e37:	e8 1e 0a 00 00       	call   385a <printf>
      kill(ppid);
    2e3c:	89 34 24             	mov    %esi,(%esp)
    2e3f:	e8 0c 09 00 00       	call   3750 <kill>
      exit();
    2e44:	e8 d7 08 00 00       	call   3720 <exit>
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    2e49:	83 ec 0c             	sub    $0xc,%esp
    2e4c:	8d 45 e0             	lea    -0x20(%ebp),%eax
    2e4f:	50                   	push   %eax
    2e50:	e8 db 08 00 00       	call   3730 <pipe>
    2e55:	89 c3                	mov    %eax,%ebx
    2e57:	83 c4 10             	add    $0x10,%esp
    2e5a:	85 c0                	test   %eax,%eax
    2e5c:	75 04                	jne    2e62 <sbrktest+0x2f6>
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    2e5e:	89 c6                	mov    %eax,%esi
    2e60:	eb 57                	jmp    2eb9 <sbrktest+0x34d>
    printf(1, "pipe() failed\n");
    2e62:	83 ec 08             	sub    $0x8,%esp
    2e65:	68 4d 3e 00 00       	push   $0x3e4d
    2e6a:	6a 01                	push   $0x1
    2e6c:	e8 e9 09 00 00       	call   385a <printf>
    exit();
    2e71:	e8 aa 08 00 00       	call   3720 <exit>
    if((pids[i] = fork()) == 0){
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    2e76:	83 ec 0c             	sub    $0xc,%esp
    2e79:	6a 00                	push   $0x0
    2e7b:	e8 28 09 00 00       	call   37a8 <sbrk>
    2e80:	ba 00 00 40 06       	mov    $0x6400000,%edx
    2e85:	29 c2                	sub    %eax,%edx
    2e87:	89 14 24             	mov    %edx,(%esp)
    2e8a:	e8 19 09 00 00       	call   37a8 <sbrk>
      write(fds[1], "x", 1);
    2e8f:	83 c4 0c             	add    $0xc,%esp
    2e92:	6a 01                	push   $0x1
    2e94:	68 6d 44 00 00       	push   $0x446d
    2e99:	ff 75 e4             	pushl  -0x1c(%ebp)
    2e9c:	e8 9f 08 00 00       	call   3740 <write>
    2ea1:	83 c4 10             	add    $0x10,%esp
      // sit around until killed
      for(;;) sleep(1000);
    2ea4:	83 ec 0c             	sub    $0xc,%esp
    2ea7:	68 e8 03 00 00       	push   $0x3e8
    2eac:	e8 ff 08 00 00       	call   37b0 <sleep>
    2eb1:	83 c4 10             	add    $0x10,%esp
    2eb4:	eb ee                	jmp    2ea4 <sbrktest+0x338>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    2eb6:	83 c6 01             	add    $0x1,%esi
    2eb9:	83 fe 09             	cmp    $0x9,%esi
    2ebc:	77 28                	ja     2ee6 <sbrktest+0x37a>
    if((pids[i] = fork()) == 0){
    2ebe:	e8 55 08 00 00       	call   3718 <fork>
    2ec3:	89 44 b5 b8          	mov    %eax,-0x48(%ebp,%esi,4)
    2ec7:	85 c0                	test   %eax,%eax
    2ec9:	74 ab                	je     2e76 <sbrktest+0x30a>
    }
    if(pids[i] != -1)
    2ecb:	83 f8 ff             	cmp    $0xffffffff,%eax
    2ece:	74 e6                	je     2eb6 <sbrktest+0x34a>
      read(fds[0], &scratch, 1);
    2ed0:	83 ec 04             	sub    $0x4,%esp
    2ed3:	6a 01                	push   $0x1
    2ed5:	8d 45 b7             	lea    -0x49(%ebp),%eax
    2ed8:	50                   	push   %eax
    2ed9:	ff 75 e0             	pushl  -0x20(%ebp)
    2edc:	e8 57 08 00 00       	call   3738 <read>
    2ee1:	83 c4 10             	add    $0x10,%esp
    2ee4:	eb d0                	jmp    2eb6 <sbrktest+0x34a>
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    2ee6:	83 ec 0c             	sub    $0xc,%esp
    2ee9:	68 00 10 00 00       	push   $0x1000
    2eee:	e8 b5 08 00 00       	call   37a8 <sbrk>
    2ef3:	89 c6                	mov    %eax,%esi
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    2ef5:	83 c4 10             	add    $0x10,%esp
    2ef8:	eb 03                	jmp    2efd <sbrktest+0x391>
    2efa:	83 c3 01             	add    $0x1,%ebx
    2efd:	83 fb 09             	cmp    $0x9,%ebx
    2f00:	77 1c                	ja     2f1e <sbrktest+0x3b2>
    if(pids[i] == -1)
    2f02:	8b 44 9d b8          	mov    -0x48(%ebp,%ebx,4),%eax
    2f06:	83 f8 ff             	cmp    $0xffffffff,%eax
    2f09:	74 ef                	je     2efa <sbrktest+0x38e>
      continue;
    kill(pids[i]);
    2f0b:	83 ec 0c             	sub    $0xc,%esp
    2f0e:	50                   	push   %eax
    2f0f:	e8 3c 08 00 00       	call   3750 <kill>
    wait();
    2f14:	e8 0f 08 00 00       	call   3728 <wait>
    2f19:	83 c4 10             	add    $0x10,%esp
    2f1c:	eb dc                	jmp    2efa <sbrktest+0x38e>
  }
  if(c == (char*)0xffffffff){
    2f1e:	83 fe ff             	cmp    $0xffffffff,%esi
    2f21:	74 2f                	je     2f52 <sbrktest+0x3e6>
    printf(stdout, "failed sbrk leaked memory\n");
    exit();
  }

  if(sbrk(0) > oldbrk)
    2f23:	83 ec 0c             	sub    $0xc,%esp
    2f26:	6a 00                	push   $0x0
    2f28:	e8 7b 08 00 00       	call   37a8 <sbrk>
    2f2d:	83 c4 10             	add    $0x10,%esp
    2f30:	39 f8                	cmp    %edi,%eax
    2f32:	77 36                	ja     2f6a <sbrktest+0x3fe>
    sbrk(-(sbrk(0) - oldbrk));

  printf(stdout, "sbrk test OK\n");
    2f34:	83 ec 08             	sub    $0x8,%esp
    2f37:	68 ac 49 00 00       	push   $0x49ac
    2f3c:	ff 35 54 5b 00 00    	pushl  0x5b54
    2f42:	e8 13 09 00 00       	call   385a <printf>
}
    2f47:	83 c4 10             	add    $0x10,%esp
    2f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2f4d:	5b                   	pop    %ebx
    2f4e:	5e                   	pop    %esi
    2f4f:	5f                   	pop    %edi
    2f50:	5d                   	pop    %ebp
    2f51:	c3                   	ret    
    printf(stdout, "failed sbrk leaked memory\n");
    2f52:	83 ec 08             	sub    $0x8,%esp
    2f55:	68 91 49 00 00       	push   $0x4991
    2f5a:	ff 35 54 5b 00 00    	pushl  0x5b54
    2f60:	e8 f5 08 00 00       	call   385a <printf>
    exit();
    2f65:	e8 b6 07 00 00       	call   3720 <exit>
    sbrk(-(sbrk(0) - oldbrk));
    2f6a:	83 ec 0c             	sub    $0xc,%esp
    2f6d:	6a 00                	push   $0x0
    2f6f:	e8 34 08 00 00       	call   37a8 <sbrk>
    2f74:	29 c7                	sub    %eax,%edi
    2f76:	89 3c 24             	mov    %edi,(%esp)
    2f79:	e8 2a 08 00 00       	call   37a8 <sbrk>
    2f7e:	83 c4 10             	add    $0x10,%esp
    2f81:	eb b1                	jmp    2f34 <sbrktest+0x3c8>

00002f83 <validateint>:

void
validateint(int *p)
{
    2f83:	55                   	push   %ebp
    2f84:	89 e5                	mov    %esp,%ebp
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    2f86:	5d                   	pop    %ebp
    2f87:	c3                   	ret    

00002f88 <validatetest>:

void
validatetest(void)
{
    2f88:	55                   	push   %ebp
    2f89:	89 e5                	mov    %esp,%ebp
    2f8b:	56                   	push   %esi
    2f8c:	53                   	push   %ebx
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    2f8d:	83 ec 08             	sub    $0x8,%esp
    2f90:	68 ba 49 00 00       	push   $0x49ba
    2f95:	ff 35 54 5b 00 00    	pushl  0x5b54
    2f9b:	e8 ba 08 00 00       	call   385a <printf>
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    2fa0:	83 c4 10             	add    $0x10,%esp
    2fa3:	bb 00 00 00 00       	mov    $0x0,%ebx
    2fa8:	81 fb 00 30 11 00    	cmp    $0x113000,%ebx
    2fae:	77 69                	ja     3019 <validatetest+0x91>
    if((pid = fork()) == 0){
    2fb0:	e8 63 07 00 00       	call   3718 <fork>
    2fb5:	89 c6                	mov    %eax,%esi
    2fb7:	85 c0                	test   %eax,%eax
    2fb9:	74 41                	je     2ffc <validatetest+0x74>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
      exit();
    }
    sleep(0);
    2fbb:	83 ec 0c             	sub    $0xc,%esp
    2fbe:	6a 00                	push   $0x0
    2fc0:	e8 eb 07 00 00       	call   37b0 <sleep>
    sleep(0);
    2fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2fcc:	e8 df 07 00 00       	call   37b0 <sleep>
    kill(pid);
    2fd1:	89 34 24             	mov    %esi,(%esp)
    2fd4:	e8 77 07 00 00       	call   3750 <kill>
    wait();
    2fd9:	e8 4a 07 00 00       	call   3728 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    2fde:	83 c4 08             	add    $0x8,%esp
    2fe1:	53                   	push   %ebx
    2fe2:	68 c9 49 00 00       	push   $0x49c9
    2fe7:	e8 94 07 00 00       	call   3780 <link>
    2fec:	83 c4 10             	add    $0x10,%esp
    2fef:	83 f8 ff             	cmp    $0xffffffff,%eax
    2ff2:	75 0d                	jne    3001 <validatetest+0x79>
  for(p = 0; p <= (uint)hi; p += 4096){
    2ff4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    2ffa:	eb ac                	jmp    2fa8 <validatetest+0x20>
      exit();
    2ffc:	e8 1f 07 00 00       	call   3720 <exit>
      printf(stdout, "link should not succeed\n");
    3001:	83 ec 08             	sub    $0x8,%esp
    3004:	68 d4 49 00 00       	push   $0x49d4
    3009:	ff 35 54 5b 00 00    	pushl  0x5b54
    300f:	e8 46 08 00 00       	call   385a <printf>
      exit();
    3014:	e8 07 07 00 00       	call   3720 <exit>
    }
  }

  printf(stdout, "validate ok\n");
    3019:	83 ec 08             	sub    $0x8,%esp
    301c:	68 ed 49 00 00       	push   $0x49ed
    3021:	ff 35 54 5b 00 00    	pushl  0x5b54
    3027:	e8 2e 08 00 00       	call   385a <printf>
}
    302c:	83 c4 10             	add    $0x10,%esp
    302f:	8d 65 f8             	lea    -0x8(%ebp),%esp
    3032:	5b                   	pop    %ebx
    3033:	5e                   	pop    %esi
    3034:	5d                   	pop    %ebp
    3035:	c3                   	ret    

00003036 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    3036:	55                   	push   %ebp
    3037:	89 e5                	mov    %esp,%ebp
    3039:	83 ec 10             	sub    $0x10,%esp
  int i;

  printf(stdout, "bss test\n");
    303c:	68 fa 49 00 00       	push   $0x49fa
    3041:	ff 35 54 5b 00 00    	pushl  0x5b54
    3047:	e8 0e 08 00 00       	call   385a <printf>
  for(i = 0; i < sizeof(uninit); i++){
    304c:	83 c4 10             	add    $0x10,%esp
    304f:	b8 00 00 00 00       	mov    $0x0,%eax
    3054:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3059:	77 26                	ja     3081 <bsstest+0x4b>
    if(uninit[i] != '\0'){
    305b:	80 b8 20 5c 00 00 00 	cmpb   $0x0,0x5c20(%eax)
    3062:	75 05                	jne    3069 <bsstest+0x33>
  for(i = 0; i < sizeof(uninit); i++){
    3064:	83 c0 01             	add    $0x1,%eax
    3067:	eb eb                	jmp    3054 <bsstest+0x1e>
      printf(stdout, "bss test failed\n");
    3069:	83 ec 08             	sub    $0x8,%esp
    306c:	68 04 4a 00 00       	push   $0x4a04
    3071:	ff 35 54 5b 00 00    	pushl  0x5b54
    3077:	e8 de 07 00 00       	call   385a <printf>
      exit();
    307c:	e8 9f 06 00 00       	call   3720 <exit>
    }
  }
  printf(stdout, "bss test ok\n");
    3081:	83 ec 08             	sub    $0x8,%esp
    3084:	68 15 4a 00 00       	push   $0x4a15
    3089:	ff 35 54 5b 00 00    	pushl  0x5b54
    308f:	e8 c6 07 00 00       	call   385a <printf>
}
    3094:	83 c4 10             	add    $0x10,%esp
    3097:	c9                   	leave  
    3098:	c3                   	ret    

00003099 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    3099:	55                   	push   %ebp
    309a:	89 e5                	mov    %esp,%ebp
    309c:	83 ec 14             	sub    $0x14,%esp
  int pid, fd;

  unlink("bigarg-ok");
    309f:	68 22 4a 00 00       	push   $0x4a22
    30a4:	e8 c7 06 00 00       	call   3770 <unlink>
  pid = fork();
    30a9:	e8 6a 06 00 00       	call   3718 <fork>
  if(pid == 0){
    30ae:	83 c4 10             	add    $0x10,%esp
    30b1:	85 c0                	test   %eax,%eax
    30b3:	74 4f                	je     3104 <bigargtest+0x6b>
    exec("echo", args);
    printf(stdout, "bigarg test ok\n");
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit();
  } else if(pid < 0){
    30b5:	85 c0                	test   %eax,%eax
    30b7:	0f 88 ad 00 00 00    	js     316a <bigargtest+0xd1>
    printf(stdout, "bigargtest: fork failed\n");
    exit();
  }
  wait();
    30bd:	e8 66 06 00 00       	call   3728 <wait>
  fd = open("bigarg-ok", 0);
    30c2:	83 ec 08             	sub    $0x8,%esp
    30c5:	6a 00                	push   $0x0
    30c7:	68 22 4a 00 00       	push   $0x4a22
    30cc:	e8 8f 06 00 00       	call   3760 <open>
  if(fd < 0){
    30d1:	83 c4 10             	add    $0x10,%esp
    30d4:	85 c0                	test   %eax,%eax
    30d6:	0f 88 a6 00 00 00    	js     3182 <bigargtest+0xe9>
    printf(stdout, "bigarg test failed!\n");
    exit();
  }
  close(fd);
    30dc:	83 ec 0c             	sub    $0xc,%esp
    30df:	50                   	push   %eax
    30e0:	e8 63 06 00 00       	call   3748 <close>
  unlink("bigarg-ok");
    30e5:	c7 04 24 22 4a 00 00 	movl   $0x4a22,(%esp)
    30ec:	e8 7f 06 00 00       	call   3770 <unlink>
}
    30f1:	83 c4 10             	add    $0x10,%esp
    30f4:	c9                   	leave  
    30f5:	c3                   	ret    
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    30f6:	c7 04 85 80 5b 00 00 	movl   $0x517c,0x5b80(,%eax,4)
    30fd:	7c 51 00 00 
    for(i = 0; i < MAXARG-1; i++)
    3101:	83 c0 01             	add    $0x1,%eax
    3104:	83 f8 1e             	cmp    $0x1e,%eax
    3107:	7e ed                	jle    30f6 <bigargtest+0x5d>
    args[MAXARG-1] = 0;
    3109:	c7 05 fc 5b 00 00 00 	movl   $0x0,0x5bfc
    3110:	00 00 00 
    printf(stdout, "bigarg test\n");
    3113:	83 ec 08             	sub    $0x8,%esp
    3116:	68 2c 4a 00 00       	push   $0x4a2c
    311b:	ff 35 54 5b 00 00    	pushl  0x5b54
    3121:	e8 34 07 00 00       	call   385a <printf>
    exec("echo", args);
    3126:	83 c4 08             	add    $0x8,%esp
    3129:	68 80 5b 00 00       	push   $0x5b80
    312e:	68 f9 3b 00 00       	push   $0x3bf9
    3133:	e8 20 06 00 00       	call   3758 <exec>
    printf(stdout, "bigarg test ok\n");
    3138:	83 c4 08             	add    $0x8,%esp
    313b:	68 39 4a 00 00       	push   $0x4a39
    3140:	ff 35 54 5b 00 00    	pushl  0x5b54
    3146:	e8 0f 07 00 00       	call   385a <printf>
    fd = open("bigarg-ok", O_CREATE);
    314b:	83 c4 08             	add    $0x8,%esp
    314e:	68 00 02 00 00       	push   $0x200
    3153:	68 22 4a 00 00       	push   $0x4a22
    3158:	e8 03 06 00 00       	call   3760 <open>
    close(fd);
    315d:	89 04 24             	mov    %eax,(%esp)
    3160:	e8 e3 05 00 00       	call   3748 <close>
    exit();
    3165:	e8 b6 05 00 00       	call   3720 <exit>
    printf(stdout, "bigargtest: fork failed\n");
    316a:	83 ec 08             	sub    $0x8,%esp
    316d:	68 49 4a 00 00       	push   $0x4a49
    3172:	ff 35 54 5b 00 00    	pushl  0x5b54
    3178:	e8 dd 06 00 00       	call   385a <printf>
    exit();
    317d:	e8 9e 05 00 00       	call   3720 <exit>
    printf(stdout, "bigarg test failed!\n");
    3182:	83 ec 08             	sub    $0x8,%esp
    3185:	68 62 4a 00 00       	push   $0x4a62
    318a:	ff 35 54 5b 00 00    	pushl  0x5b54
    3190:	e8 c5 06 00 00       	call   385a <printf>
    exit();
    3195:	e8 86 05 00 00       	call   3720 <exit>

0000319a <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    319a:	55                   	push   %ebp
    319b:	89 e5                	mov    %esp,%ebp
    319d:	57                   	push   %edi
    319e:	56                   	push   %esi
    319f:	53                   	push   %ebx
    31a0:	83 ec 54             	sub    $0x54,%esp
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");
    31a3:	68 77 4a 00 00       	push   $0x4a77
    31a8:	6a 01                	push   $0x1
    31aa:	e8 ab 06 00 00       	call   385a <printf>
    31af:	83 c4 10             	add    $0x10,%esp

  for(nfiles = 0; ; nfiles++){
    31b2:	bb 00 00 00 00       	mov    $0x0,%ebx
    char name[64];
    name[0] = 'f';
    31b7:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    31bb:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    31c0:	89 d8                	mov    %ebx,%eax
    31c2:	f7 ea                	imul   %edx
    31c4:	c1 fa 06             	sar    $0x6,%edx
    31c7:	89 df                	mov    %ebx,%edi
    31c9:	c1 ff 1f             	sar    $0x1f,%edi
    31cc:	29 fa                	sub    %edi,%edx
    31ce:	8d 42 30             	lea    0x30(%edx),%eax
    31d1:	88 45 a9             	mov    %al,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    31d4:	69 d2 e8 03 00 00    	imul   $0x3e8,%edx,%edx
    31da:	89 de                	mov    %ebx,%esi
    31dc:	29 d6                	sub    %edx,%esi
    31de:	b9 1f 85 eb 51       	mov    $0x51eb851f,%ecx
    31e3:	89 f0                	mov    %esi,%eax
    31e5:	f7 e9                	imul   %ecx
    31e7:	c1 fa 05             	sar    $0x5,%edx
    31ea:	c1 fe 1f             	sar    $0x1f,%esi
    31ed:	29 f2                	sub    %esi,%edx
    31ef:	83 c2 30             	add    $0x30,%edx
    31f2:	88 55 aa             	mov    %dl,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    31f5:	89 d8                	mov    %ebx,%eax
    31f7:	f7 e9                	imul   %ecx
    31f9:	89 d1                	mov    %edx,%ecx
    31fb:	c1 f9 05             	sar    $0x5,%ecx
    31fe:	29 f9                	sub    %edi,%ecx
    3200:	6b c9 64             	imul   $0x64,%ecx,%ecx
    3203:	89 d8                	mov    %ebx,%eax
    3205:	29 c8                	sub    %ecx,%eax
    3207:	89 c1                	mov    %eax,%ecx
    3209:	be 67 66 66 66       	mov    $0x66666667,%esi
    320e:	f7 ee                	imul   %esi
    3210:	c1 fa 02             	sar    $0x2,%edx
    3213:	c1 f9 1f             	sar    $0x1f,%ecx
    3216:	29 ca                	sub    %ecx,%edx
    3218:	83 c2 30             	add    $0x30,%edx
    321b:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    321e:	89 d8                	mov    %ebx,%eax
    3220:	f7 ee                	imul   %esi
    3222:	c1 fa 02             	sar    $0x2,%edx
    3225:	29 fa                	sub    %edi,%edx
    3227:	8d 14 92             	lea    (%edx,%edx,4),%edx
    322a:	8d 04 12             	lea    (%edx,%edx,1),%eax
    322d:	89 da                	mov    %ebx,%edx
    322f:	29 c2                	sub    %eax,%edx
    3231:	83 c2 30             	add    $0x30,%edx
    3234:	88 55 ac             	mov    %dl,-0x54(%ebp)
    name[5] = '\0';
    3237:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    printf(1, "writing %s\n", name);
    323b:	83 ec 04             	sub    $0x4,%esp
    323e:	8d 75 a8             	lea    -0x58(%ebp),%esi
    3241:	56                   	push   %esi
    3242:	68 84 4a 00 00       	push   $0x4a84
    3247:	6a 01                	push   $0x1
    3249:	e8 0c 06 00 00       	call   385a <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    324e:	83 c4 08             	add    $0x8,%esp
    3251:	68 02 02 00 00       	push   $0x202
    3256:	56                   	push   %esi
    3257:	e8 04 05 00 00       	call   3760 <open>
    325c:	89 c6                	mov    %eax,%esi
    if(fd < 0){
    325e:	83 c4 10             	add    $0x10,%esp
    3261:	85 c0                	test   %eax,%eax
    3263:	79 1b                	jns    3280 <fsfull+0xe6>
      printf(1, "open %s failed\n", name);
    3265:	83 ec 04             	sub    $0x4,%esp
    3268:	8d 45 a8             	lea    -0x58(%ebp),%eax
    326b:	50                   	push   %eax
    326c:	68 90 4a 00 00       	push   $0x4a90
    3271:	6a 01                	push   $0x1
    3273:	e8 e2 05 00 00       	call   385a <printf>
      break;
    3278:	83 c4 10             	add    $0x10,%esp
    327b:	e9 e7 00 00 00       	jmp    3367 <fsfull+0x1cd>
    }
    int total = 0;
    3280:	bf 00 00 00 00       	mov    $0x0,%edi
    3285:	eb 02                	jmp    3289 <fsfull+0xef>
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
      total += cc;
    3287:	01 c7                	add    %eax,%edi
      int cc = write(fd, buf, 512);
    3289:	83 ec 04             	sub    $0x4,%esp
    328c:	68 00 02 00 00       	push   $0x200
    3291:	68 40 83 00 00       	push   $0x8340
    3296:	56                   	push   %esi
    3297:	e8 a4 04 00 00       	call   3740 <write>
      if(cc < 512)
    329c:	83 c4 10             	add    $0x10,%esp
    329f:	3d ff 01 00 00       	cmp    $0x1ff,%eax
    32a4:	7f e1                	jg     3287 <fsfull+0xed>
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    32a6:	83 ec 04             	sub    $0x4,%esp
    32a9:	57                   	push   %edi
    32aa:	68 a0 4a 00 00       	push   $0x4aa0
    32af:	6a 01                	push   $0x1
    32b1:	e8 a4 05 00 00       	call   385a <printf>
    close(fd);
    32b6:	89 34 24             	mov    %esi,(%esp)
    32b9:	e8 8a 04 00 00       	call   3748 <close>
    if(total == 0)
    32be:	83 c4 10             	add    $0x10,%esp
    32c1:	85 ff                	test   %edi,%edi
    32c3:	0f 84 9e 00 00 00    	je     3367 <fsfull+0x1cd>
  for(nfiles = 0; ; nfiles++){
    32c9:	83 c3 01             	add    $0x1,%ebx
    32cc:	e9 e6 fe ff ff       	jmp    31b7 <fsfull+0x1d>
      break;
  }

  while(nfiles >= 0){
    char name[64];
    name[0] = 'f';
    32d1:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    32d5:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    32da:	89 d8                	mov    %ebx,%eax
    32dc:	f7 ea                	imul   %edx
    32de:	c1 fa 06             	sar    $0x6,%edx
    32e1:	89 df                	mov    %ebx,%edi
    32e3:	c1 ff 1f             	sar    $0x1f,%edi
    32e6:	29 fa                	sub    %edi,%edx
    32e8:	8d 42 30             	lea    0x30(%edx),%eax
    32eb:	88 45 a9             	mov    %al,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    32ee:	69 d2 e8 03 00 00    	imul   $0x3e8,%edx,%edx
    32f4:	89 de                	mov    %ebx,%esi
    32f6:	29 d6                	sub    %edx,%esi
    32f8:	b9 1f 85 eb 51       	mov    $0x51eb851f,%ecx
    32fd:	89 f0                	mov    %esi,%eax
    32ff:	f7 e9                	imul   %ecx
    3301:	c1 fa 05             	sar    $0x5,%edx
    3304:	c1 fe 1f             	sar    $0x1f,%esi
    3307:	29 f2                	sub    %esi,%edx
    3309:	83 c2 30             	add    $0x30,%edx
    330c:	88 55 aa             	mov    %dl,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    330f:	89 d8                	mov    %ebx,%eax
    3311:	f7 e9                	imul   %ecx
    3313:	89 d1                	mov    %edx,%ecx
    3315:	c1 f9 05             	sar    $0x5,%ecx
    3318:	29 f9                	sub    %edi,%ecx
    331a:	6b c9 64             	imul   $0x64,%ecx,%ecx
    331d:	89 d8                	mov    %ebx,%eax
    331f:	29 c8                	sub    %ecx,%eax
    3321:	89 c1                	mov    %eax,%ecx
    3323:	be 67 66 66 66       	mov    $0x66666667,%esi
    3328:	f7 ee                	imul   %esi
    332a:	c1 fa 02             	sar    $0x2,%edx
    332d:	c1 f9 1f             	sar    $0x1f,%ecx
    3330:	29 ca                	sub    %ecx,%edx
    3332:	83 c2 30             	add    $0x30,%edx
    3335:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    3338:	89 d8                	mov    %ebx,%eax
    333a:	f7 ee                	imul   %esi
    333c:	c1 fa 02             	sar    $0x2,%edx
    333f:	29 fa                	sub    %edi,%edx
    3341:	8d 14 92             	lea    (%edx,%edx,4),%edx
    3344:	8d 04 12             	lea    (%edx,%edx,1),%eax
    3347:	89 da                	mov    %ebx,%edx
    3349:	29 c2                	sub    %eax,%edx
    334b:	83 c2 30             	add    $0x30,%edx
    334e:	88 55 ac             	mov    %dl,-0x54(%ebp)
    name[5] = '\0';
    3351:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    unlink(name);
    3355:	83 ec 0c             	sub    $0xc,%esp
    3358:	8d 45 a8             	lea    -0x58(%ebp),%eax
    335b:	50                   	push   %eax
    335c:	e8 0f 04 00 00       	call   3770 <unlink>
    nfiles--;
    3361:	83 eb 01             	sub    $0x1,%ebx
    3364:	83 c4 10             	add    $0x10,%esp
  while(nfiles >= 0){
    3367:	85 db                	test   %ebx,%ebx
    3369:	0f 89 62 ff ff ff    	jns    32d1 <fsfull+0x137>
  }

  printf(1, "fsfull test finished\n");
    336f:	83 ec 08             	sub    $0x8,%esp
    3372:	68 b0 4a 00 00       	push   $0x4ab0
    3377:	6a 01                	push   $0x1
    3379:	e8 dc 04 00 00       	call   385a <printf>
}
    337e:	83 c4 10             	add    $0x10,%esp
    3381:	8d 65 f4             	lea    -0xc(%ebp),%esp
    3384:	5b                   	pop    %ebx
    3385:	5e                   	pop    %esi
    3386:	5f                   	pop    %edi
    3387:	5d                   	pop    %ebp
    3388:	c3                   	ret    

00003389 <uio>:

void
uio()
{
    3389:	55                   	push   %ebp
    338a:	89 e5                	mov    %esp,%ebp
    338c:	83 ec 10             	sub    $0x10,%esp

  ushort port = 0;
  uchar val = 0;
  int pid;

  printf(1, "uio test\n");
    338f:	68 c6 4a 00 00       	push   $0x4ac6
    3394:	6a 01                	push   $0x1
    3396:	e8 bf 04 00 00       	call   385a <printf>
  pid = fork();
    339b:	e8 78 03 00 00       	call   3718 <fork>
  if(pid == 0){
    33a0:	83 c4 10             	add    $0x10,%esp
    33a3:	85 c0                	test   %eax,%eax
    33a5:	74 1d                	je     33c4 <uio+0x3b>
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    port = RTC_DATA;
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    printf(1, "uio: uio succeeded; test FAILED\n");
    exit();
  } else if(pid < 0){
    33a7:	85 c0                	test   %eax,%eax
    33a9:	78 3e                	js     33e9 <uio+0x60>
    printf (1, "fork failed\n");
    exit();
  }
  wait();
    33ab:	e8 78 03 00 00       	call   3728 <wait>
  printf(1, "uio test done\n");
    33b0:	83 ec 08             	sub    $0x8,%esp
    33b3:	68 d0 4a 00 00       	push   $0x4ad0
    33b8:	6a 01                	push   $0x1
    33ba:	e8 9b 04 00 00       	call   385a <printf>
}
    33bf:	83 c4 10             	add    $0x10,%esp
    33c2:	c9                   	leave  
    33c3:	c3                   	ret    
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    33c4:	b8 09 00 00 00       	mov    $0x9,%eax
    33c9:	ba 70 00 00 00       	mov    $0x70,%edx
    33ce:	ee                   	out    %al,(%dx)
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    33cf:	ba 71 00 00 00       	mov    $0x71,%edx
    33d4:	ec                   	in     (%dx),%al
    printf(1, "uio: uio succeeded; test FAILED\n");
    33d5:	83 ec 08             	sub    $0x8,%esp
    33d8:	68 5c 52 00 00       	push   $0x525c
    33dd:	6a 01                	push   $0x1
    33df:	e8 76 04 00 00       	call   385a <printf>
    exit();
    33e4:	e8 37 03 00 00       	call   3720 <exit>
    printf (1, "fork failed\n");
    33e9:	83 ec 08             	sub    $0x8,%esp
    33ec:	68 55 4a 00 00       	push   $0x4a55
    33f1:	6a 01                	push   $0x1
    33f3:	e8 62 04 00 00       	call   385a <printf>
    exit();
    33f8:	e8 23 03 00 00       	call   3720 <exit>

000033fd <argptest>:

void argptest()
{
    33fd:	55                   	push   %ebp
    33fe:	89 e5                	mov    %esp,%ebp
    3400:	53                   	push   %ebx
    3401:	83 ec 0c             	sub    $0xc,%esp
  int fd;
  fd = open("init", O_RDONLY);
    3404:	6a 00                	push   $0x0
    3406:	68 df 4a 00 00       	push   $0x4adf
    340b:	e8 50 03 00 00       	call   3760 <open>
  if (fd < 0) {
    3410:	83 c4 10             	add    $0x10,%esp
    3413:	85 c0                	test   %eax,%eax
    3415:	78 3a                	js     3451 <argptest+0x54>
    3417:	89 c3                	mov    %eax,%ebx
    printf(2, "open failed\n");
    exit();
  }
  read(fd, sbrk(0) - 1, -1);
    3419:	83 ec 0c             	sub    $0xc,%esp
    341c:	6a 00                	push   $0x0
    341e:	e8 85 03 00 00       	call   37a8 <sbrk>
    3423:	83 e8 01             	sub    $0x1,%eax
    3426:	83 c4 0c             	add    $0xc,%esp
    3429:	6a ff                	push   $0xffffffff
    342b:	50                   	push   %eax
    342c:	53                   	push   %ebx
    342d:	e8 06 03 00 00       	call   3738 <read>
  close(fd);
    3432:	89 1c 24             	mov    %ebx,(%esp)
    3435:	e8 0e 03 00 00       	call   3748 <close>
  printf(1, "arg test passed\n");
    343a:	83 c4 08             	add    $0x8,%esp
    343d:	68 f1 4a 00 00       	push   $0x4af1
    3442:	6a 01                	push   $0x1
    3444:	e8 11 04 00 00       	call   385a <printf>
}
    3449:	83 c4 10             	add    $0x10,%esp
    344c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    344f:	c9                   	leave  
    3450:	c3                   	ret    
    printf(2, "open failed\n");
    3451:	83 ec 08             	sub    $0x8,%esp
    3454:	68 e4 4a 00 00       	push   $0x4ae4
    3459:	6a 02                	push   $0x2
    345b:	e8 fa 03 00 00       	call   385a <printf>
    exit();
    3460:	e8 bb 02 00 00       	call   3720 <exit>

00003465 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    3465:	55                   	push   %ebp
    3466:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    3468:	69 05 50 5b 00 00 0d 	imul   $0x19660d,0x5b50,%eax
    346f:	66 19 00 
    3472:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    3477:	a3 50 5b 00 00       	mov    %eax,0x5b50
  return randstate;
}
    347c:	5d                   	pop    %ebp
    347d:	c3                   	ret    

0000347e <main>:

int
main(int argc, char *argv[])
{
    347e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    3482:	83 e4 f0             	and    $0xfffffff0,%esp
    3485:	ff 71 fc             	pushl  -0x4(%ecx)
    3488:	55                   	push   %ebp
    3489:	89 e5                	mov    %esp,%ebp
    348b:	51                   	push   %ecx
    348c:	83 ec 0c             	sub    $0xc,%esp
  printf(1, "usertests starting\n");
    348f:	68 02 4b 00 00       	push   $0x4b02
    3494:	6a 01                	push   $0x1
    3496:	e8 bf 03 00 00       	call   385a <printf>

  if(open("usertests.ran", 0) >= 0){
    349b:	83 c4 08             	add    $0x8,%esp
    349e:	6a 00                	push   $0x0
    34a0:	68 16 4b 00 00       	push   $0x4b16
    34a5:	e8 b6 02 00 00       	call   3760 <open>
    34aa:	83 c4 10             	add    $0x10,%esp
    34ad:	85 c0                	test   %eax,%eax
    34af:	78 14                	js     34c5 <main+0x47>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    34b1:	83 ec 08             	sub    $0x8,%esp
    34b4:	68 80 52 00 00       	push   $0x5280
    34b9:	6a 01                	push   $0x1
    34bb:	e8 9a 03 00 00       	call   385a <printf>
    exit();
    34c0:	e8 5b 02 00 00       	call   3720 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    34c5:	83 ec 08             	sub    $0x8,%esp
    34c8:	68 00 02 00 00       	push   $0x200
    34cd:	68 16 4b 00 00       	push   $0x4b16
    34d2:	e8 89 02 00 00       	call   3760 <open>
    34d7:	89 04 24             	mov    %eax,(%esp)
    34da:	e8 69 02 00 00       	call   3748 <close>

  argptest();
    34df:	e8 19 ff ff ff       	call   33fd <argptest>
  createdelete();
    34e4:	e8 2c db ff ff       	call   1015 <createdelete>
  linkunlink();
    34e9:	e8 cb e3 ff ff       	call   18b9 <linkunlink>
  concreate();
    34ee:	e8 d8 e0 ff ff       	call   15cb <concreate>
  fourfiles();
    34f3:	e8 38 d9 ff ff       	call   e30 <fourfiles>
  sharedfd();
    34f8:	e8 96 d7 ff ff       	call   c93 <sharedfd>

  bigargtest();
    34fd:	e8 97 fb ff ff       	call   3099 <bigargtest>
  bigwrite();
    3502:	e8 26 ed ff ff       	call   222d <bigwrite>
  bigargtest();
    3507:	e8 8d fb ff ff       	call   3099 <bigargtest>
  bsstest();
    350c:	e8 25 fb ff ff       	call   3036 <bsstest>
  sbrktest();
    3511:	e8 56 f6 ff ff       	call   2b6c <sbrktest>
  validatetest();
    3516:	e8 6d fa ff ff       	call   2f88 <validatetest>

  opentest();
    351b:	e8 90 cd ff ff       	call   2b0 <opentest>
  writetest();
    3520:	e8 1e ce ff ff       	call   343 <writetest>
  writetest1();
    3525:	e8 e1 cf ff ff       	call   50b <writetest1>
  createtest();
    352a:	e8 8c d1 ff ff       	call   6bb <createtest>

  openiputtest();
    352f:	e8 91 cc ff ff       	call   1c5 <openiputtest>
  exitiputtest();
    3534:	e8 a4 cb ff ff       	call   dd <exitiputtest>
  iputtest();
    3539:	e8 c2 ca ff ff       	call   0 <iputtest>

  mem();
    353e:	e8 95 d6 ff ff       	call   bd8 <mem>
  pipe1();
    3543:	e8 45 d3 ff ff       	call   88d <pipe1>
  preempt();
    3548:	e8 e0 d4 ff ff       	call   a2d <preempt>
  exitwait();
    354d:	e8 14 d6 ff ff       	call   b66 <exitwait>

  rmdot();
    3552:	e8 9d f0 ff ff       	call   25f4 <rmdot>
  fourteen();
    3557:	e8 5b ef ff ff       	call   24b7 <fourteen>
  bigfile();
    355c:	e8 9e ed ff ff       	call   22ff <bigfile>
  subdir();
    3561:	e8 99 e5 ff ff       	call   1aff <subdir>
  linktest();
    3566:	e8 3a de ff ff       	call   13a5 <linktest>
  unlinkread();
    356b:	e8 9c dc ff ff       	call   120c <unlinkread>
  dirfile();
    3570:	e8 04 f2 ff ff       	call   2779 <dirfile>
  iref();
    3575:	e8 19 f4 ff ff       	call   2993 <iref>
  forktest();
    357a:	e8 3c f5 ff ff       	call   2abb <forktest>
  bigdir(); // slow
    357f:	e8 27 e4 ff ff       	call   19ab <bigdir>

  uio();
    3584:	e8 00 fe ff ff       	call   3389 <uio>

  exectest();
    3589:	e8 b6 d2 ff ff       	call   844 <exectest>

  exit();
    358e:	e8 8d 01 00 00       	call   3720 <exit>

00003593 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
    3593:	55                   	push   %ebp
    3594:	89 e5                	mov    %esp,%ebp
    3596:	53                   	push   %ebx
    3597:	8b 45 08             	mov    0x8(%ebp),%eax
    359a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    359d:	89 c2                	mov    %eax,%edx
    359f:	0f b6 19             	movzbl (%ecx),%ebx
    35a2:	88 1a                	mov    %bl,(%edx)
    35a4:	8d 52 01             	lea    0x1(%edx),%edx
    35a7:	8d 49 01             	lea    0x1(%ecx),%ecx
    35aa:	84 db                	test   %bl,%bl
    35ac:	75 f1                	jne    359f <strcpy+0xc>
    ;
  return os;
}
    35ae:	5b                   	pop    %ebx
    35af:	5d                   	pop    %ebp
    35b0:	c3                   	ret    

000035b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    35b1:	55                   	push   %ebp
    35b2:	89 e5                	mov    %esp,%ebp
    35b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
    35b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    35ba:	eb 06                	jmp    35c2 <strcmp+0x11>
    p++, q++;
    35bc:	83 c1 01             	add    $0x1,%ecx
    35bf:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
    35c2:	0f b6 01             	movzbl (%ecx),%eax
    35c5:	84 c0                	test   %al,%al
    35c7:	74 04                	je     35cd <strcmp+0x1c>
    35c9:	3a 02                	cmp    (%edx),%al
    35cb:	74 ef                	je     35bc <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
    35cd:	0f b6 c0             	movzbl %al,%eax
    35d0:	0f b6 12             	movzbl (%edx),%edx
    35d3:	29 d0                	sub    %edx,%eax
}
    35d5:	5d                   	pop    %ebp
    35d6:	c3                   	ret    

000035d7 <strlen>:

uint
strlen(const char *s)
{
    35d7:	55                   	push   %ebp
    35d8:	89 e5                	mov    %esp,%ebp
    35da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    35dd:	ba 00 00 00 00       	mov    $0x0,%edx
    35e2:	eb 03                	jmp    35e7 <strlen+0x10>
    35e4:	83 c2 01             	add    $0x1,%edx
    35e7:	89 d0                	mov    %edx,%eax
    35e9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
    35ed:	75 f5                	jne    35e4 <strlen+0xd>
    ;
  return n;
}
    35ef:	5d                   	pop    %ebp
    35f0:	c3                   	ret    

000035f1 <memset>:

void*
memset(void *dst, int c, uint n)
{
    35f1:	55                   	push   %ebp
    35f2:	89 e5                	mov    %esp,%ebp
    35f4:	57                   	push   %edi
    35f5:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    35f8:	89 d7                	mov    %edx,%edi
    35fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
    35fd:	8b 45 0c             	mov    0xc(%ebp),%eax
    3600:	fc                   	cld    
    3601:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    3603:	89 d0                	mov    %edx,%eax
    3605:	5f                   	pop    %edi
    3606:	5d                   	pop    %ebp
    3607:	c3                   	ret    

00003608 <strchr>:

char*
strchr(const char *s, char c)
{
    3608:	55                   	push   %ebp
    3609:	89 e5                	mov    %esp,%ebp
    360b:	8b 45 08             	mov    0x8(%ebp),%eax
    360e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
    3612:	0f b6 10             	movzbl (%eax),%edx
    3615:	84 d2                	test   %dl,%dl
    3617:	74 09                	je     3622 <strchr+0x1a>
    if(*s == c)
    3619:	38 ca                	cmp    %cl,%dl
    361b:	74 0a                	je     3627 <strchr+0x1f>
  for(; *s; s++)
    361d:	83 c0 01             	add    $0x1,%eax
    3620:	eb f0                	jmp    3612 <strchr+0xa>
      return (char*)s;
  return 0;
    3622:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3627:	5d                   	pop    %ebp
    3628:	c3                   	ret    

00003629 <gets>:

char*
gets(char *buf, int max)
{
    3629:	55                   	push   %ebp
    362a:	89 e5                	mov    %esp,%ebp
    362c:	57                   	push   %edi
    362d:	56                   	push   %esi
    362e:	53                   	push   %ebx
    362f:	83 ec 1c             	sub    $0x1c,%esp
    3632:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3635:	bb 00 00 00 00       	mov    $0x0,%ebx
    363a:	8d 73 01             	lea    0x1(%ebx),%esi
    363d:	3b 75 0c             	cmp    0xc(%ebp),%esi
    3640:	7d 2e                	jge    3670 <gets+0x47>
    cc = read(0, &c, 1);
    3642:	83 ec 04             	sub    $0x4,%esp
    3645:	6a 01                	push   $0x1
    3647:	8d 45 e7             	lea    -0x19(%ebp),%eax
    364a:	50                   	push   %eax
    364b:	6a 00                	push   $0x0
    364d:	e8 e6 00 00 00       	call   3738 <read>
    if(cc < 1)
    3652:	83 c4 10             	add    $0x10,%esp
    3655:	85 c0                	test   %eax,%eax
    3657:	7e 17                	jle    3670 <gets+0x47>
      break;
    buf[i++] = c;
    3659:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    365d:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
    3660:	3c 0a                	cmp    $0xa,%al
    3662:	0f 94 c2             	sete   %dl
    3665:	3c 0d                	cmp    $0xd,%al
    3667:	0f 94 c0             	sete   %al
    buf[i++] = c;
    366a:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
    366c:	08 c2                	or     %al,%dl
    366e:	74 ca                	je     363a <gets+0x11>
      break;
  }
  buf[i] = '\0';
    3670:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
    3674:	89 f8                	mov    %edi,%eax
    3676:	8d 65 f4             	lea    -0xc(%ebp),%esp
    3679:	5b                   	pop    %ebx
    367a:	5e                   	pop    %esi
    367b:	5f                   	pop    %edi
    367c:	5d                   	pop    %ebp
    367d:	c3                   	ret    

0000367e <stat>:

int
stat(const char *n, struct stat *st)
{
    367e:	55                   	push   %ebp
    367f:	89 e5                	mov    %esp,%ebp
    3681:	56                   	push   %esi
    3682:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3683:	83 ec 08             	sub    $0x8,%esp
    3686:	6a 00                	push   $0x0
    3688:	ff 75 08             	pushl  0x8(%ebp)
    368b:	e8 d0 00 00 00       	call   3760 <open>
  if(fd < 0)
    3690:	83 c4 10             	add    $0x10,%esp
    3693:	85 c0                	test   %eax,%eax
    3695:	78 24                	js     36bb <stat+0x3d>
    3697:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
    3699:	83 ec 08             	sub    $0x8,%esp
    369c:	ff 75 0c             	pushl  0xc(%ebp)
    369f:	50                   	push   %eax
    36a0:	e8 d3 00 00 00       	call   3778 <fstat>
    36a5:	89 c6                	mov    %eax,%esi
  close(fd);
    36a7:	89 1c 24             	mov    %ebx,(%esp)
    36aa:	e8 99 00 00 00       	call   3748 <close>
  return r;
    36af:	83 c4 10             	add    $0x10,%esp
}
    36b2:	89 f0                	mov    %esi,%eax
    36b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
    36b7:	5b                   	pop    %ebx
    36b8:	5e                   	pop    %esi
    36b9:	5d                   	pop    %ebp
    36ba:	c3                   	ret    
    return -1;
    36bb:	be ff ff ff ff       	mov    $0xffffffff,%esi
    36c0:	eb f0                	jmp    36b2 <stat+0x34>

000036c2 <atoi>:

int
atoi(const char *s)
{
    36c2:	55                   	push   %ebp
    36c3:	89 e5                	mov    %esp,%ebp
    36c5:	53                   	push   %ebx
    36c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
    36c9:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
    36ce:	eb 10                	jmp    36e0 <atoi+0x1e>
    n = n*10 + *s++ - '0';
    36d0:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
    36d3:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
    36d6:	83 c1 01             	add    $0x1,%ecx
    36d9:	0f be d2             	movsbl %dl,%edx
    36dc:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
    36e0:	0f b6 11             	movzbl (%ecx),%edx
    36e3:	8d 5a d0             	lea    -0x30(%edx),%ebx
    36e6:	80 fb 09             	cmp    $0x9,%bl
    36e9:	76 e5                	jbe    36d0 <atoi+0xe>
  return n;
}
    36eb:	5b                   	pop    %ebx
    36ec:	5d                   	pop    %ebp
    36ed:	c3                   	ret    

000036ee <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    36ee:	55                   	push   %ebp
    36ef:	89 e5                	mov    %esp,%ebp
    36f1:	56                   	push   %esi
    36f2:	53                   	push   %ebx
    36f3:	8b 45 08             	mov    0x8(%ebp),%eax
    36f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    36f9:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
    36fc:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
    36fe:	eb 0d                	jmp    370d <memmove+0x1f>
    *dst++ = *src++;
    3700:	0f b6 13             	movzbl (%ebx),%edx
    3703:	88 11                	mov    %dl,(%ecx)
    3705:	8d 5b 01             	lea    0x1(%ebx),%ebx
    3708:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
    370b:	89 f2                	mov    %esi,%edx
    370d:	8d 72 ff             	lea    -0x1(%edx),%esi
    3710:	85 d2                	test   %edx,%edx
    3712:	7f ec                	jg     3700 <memmove+0x12>
  return vdst;
}
    3714:	5b                   	pop    %ebx
    3715:	5e                   	pop    %esi
    3716:	5d                   	pop    %ebp
    3717:	c3                   	ret    

00003718 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3718:	b8 01 00 00 00       	mov    $0x1,%eax
    371d:	cd 40                	int    $0x40
    371f:	c3                   	ret    

00003720 <exit>:
SYSCALL(exit)
    3720:	b8 02 00 00 00       	mov    $0x2,%eax
    3725:	cd 40                	int    $0x40
    3727:	c3                   	ret    

00003728 <wait>:
SYSCALL(wait)
    3728:	b8 03 00 00 00       	mov    $0x3,%eax
    372d:	cd 40                	int    $0x40
    372f:	c3                   	ret    

00003730 <pipe>:
SYSCALL(pipe)
    3730:	b8 04 00 00 00       	mov    $0x4,%eax
    3735:	cd 40                	int    $0x40
    3737:	c3                   	ret    

00003738 <read>:
SYSCALL(read)
    3738:	b8 05 00 00 00       	mov    $0x5,%eax
    373d:	cd 40                	int    $0x40
    373f:	c3                   	ret    

00003740 <write>:
SYSCALL(write)
    3740:	b8 10 00 00 00       	mov    $0x10,%eax
    3745:	cd 40                	int    $0x40
    3747:	c3                   	ret    

00003748 <close>:
SYSCALL(close)
    3748:	b8 15 00 00 00       	mov    $0x15,%eax
    374d:	cd 40                	int    $0x40
    374f:	c3                   	ret    

00003750 <kill>:
SYSCALL(kill)
    3750:	b8 06 00 00 00       	mov    $0x6,%eax
    3755:	cd 40                	int    $0x40
    3757:	c3                   	ret    

00003758 <exec>:
SYSCALL(exec)
    3758:	b8 07 00 00 00       	mov    $0x7,%eax
    375d:	cd 40                	int    $0x40
    375f:	c3                   	ret    

00003760 <open>:
SYSCALL(open)
    3760:	b8 0f 00 00 00       	mov    $0xf,%eax
    3765:	cd 40                	int    $0x40
    3767:	c3                   	ret    

00003768 <mknod>:
SYSCALL(mknod)
    3768:	b8 11 00 00 00       	mov    $0x11,%eax
    376d:	cd 40                	int    $0x40
    376f:	c3                   	ret    

00003770 <unlink>:
SYSCALL(unlink)
    3770:	b8 12 00 00 00       	mov    $0x12,%eax
    3775:	cd 40                	int    $0x40
    3777:	c3                   	ret    

00003778 <fstat>:
SYSCALL(fstat)
    3778:	b8 08 00 00 00       	mov    $0x8,%eax
    377d:	cd 40                	int    $0x40
    377f:	c3                   	ret    

00003780 <link>:
SYSCALL(link)
    3780:	b8 13 00 00 00       	mov    $0x13,%eax
    3785:	cd 40                	int    $0x40
    3787:	c3                   	ret    

00003788 <mkdir>:
SYSCALL(mkdir)
    3788:	b8 14 00 00 00       	mov    $0x14,%eax
    378d:	cd 40                	int    $0x40
    378f:	c3                   	ret    

00003790 <chdir>:
SYSCALL(chdir)
    3790:	b8 09 00 00 00       	mov    $0x9,%eax
    3795:	cd 40                	int    $0x40
    3797:	c3                   	ret    

00003798 <dup>:
SYSCALL(dup)
    3798:	b8 0a 00 00 00       	mov    $0xa,%eax
    379d:	cd 40                	int    $0x40
    379f:	c3                   	ret    

000037a0 <getpid>:
SYSCALL(getpid)
    37a0:	b8 0b 00 00 00       	mov    $0xb,%eax
    37a5:	cd 40                	int    $0x40
    37a7:	c3                   	ret    

000037a8 <sbrk>:
SYSCALL(sbrk)
    37a8:	b8 0c 00 00 00       	mov    $0xc,%eax
    37ad:	cd 40                	int    $0x40
    37af:	c3                   	ret    

000037b0 <sleep>:
SYSCALL(sleep)
    37b0:	b8 0d 00 00 00       	mov    $0xd,%eax
    37b5:	cd 40                	int    $0x40
    37b7:	c3                   	ret    

000037b8 <uptime>:
SYSCALL(uptime)
    37b8:	b8 0e 00 00 00       	mov    $0xe,%eax
    37bd:	cd 40                	int    $0x40
    37bf:	c3                   	ret    

000037c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    37c0:	55                   	push   %ebp
    37c1:	89 e5                	mov    %esp,%ebp
    37c3:	83 ec 1c             	sub    $0x1c,%esp
    37c6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
    37c9:	6a 01                	push   $0x1
    37cb:	8d 55 f4             	lea    -0xc(%ebp),%edx
    37ce:	52                   	push   %edx
    37cf:	50                   	push   %eax
    37d0:	e8 6b ff ff ff       	call   3740 <write>
}
    37d5:	83 c4 10             	add    $0x10,%esp
    37d8:	c9                   	leave  
    37d9:	c3                   	ret    

000037da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    37da:	55                   	push   %ebp
    37db:	89 e5                	mov    %esp,%ebp
    37dd:	57                   	push   %edi
    37de:	56                   	push   %esi
    37df:	53                   	push   %ebx
    37e0:	83 ec 2c             	sub    $0x2c,%esp
    37e3:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    37e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    37e9:	0f 95 c3             	setne  %bl
    37ec:	89 d0                	mov    %edx,%eax
    37ee:	c1 e8 1f             	shr    $0x1f,%eax
    37f1:	84 c3                	test   %al,%bl
    37f3:	74 10                	je     3805 <printint+0x2b>
    neg = 1;
    x = -xx;
    37f5:	f7 da                	neg    %edx
    neg = 1;
    37f7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
    37fe:	be 00 00 00 00       	mov    $0x0,%esi
    3803:	eb 0b                	jmp    3810 <printint+0x36>
  neg = 0;
    3805:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    380c:	eb f0                	jmp    37fe <printint+0x24>
  do{
    buf[i++] = digits[x % base];
    380e:	89 c6                	mov    %eax,%esi
    3810:	89 d0                	mov    %edx,%eax
    3812:	ba 00 00 00 00       	mov    $0x0,%edx
    3817:	f7 f1                	div    %ecx
    3819:	89 c3                	mov    %eax,%ebx
    381b:	8d 46 01             	lea    0x1(%esi),%eax
    381e:	0f b6 92 b4 52 00 00 	movzbl 0x52b4(%edx),%edx
    3825:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
    3829:	89 da                	mov    %ebx,%edx
    382b:	85 db                	test   %ebx,%ebx
    382d:	75 df                	jne    380e <printint+0x34>
    382f:	89 c3                	mov    %eax,%ebx
  if(neg)
    3831:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
    3835:	74 16                	je     384d <printint+0x73>
    buf[i++] = '-';
    3837:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
    383c:	8d 5e 02             	lea    0x2(%esi),%ebx
    383f:	eb 0c                	jmp    384d <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
    3841:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
    3846:	89 f8                	mov    %edi,%eax
    3848:	e8 73 ff ff ff       	call   37c0 <putc>
  while(--i >= 0)
    384d:	83 eb 01             	sub    $0x1,%ebx
    3850:	79 ef                	jns    3841 <printint+0x67>
}
    3852:	83 c4 2c             	add    $0x2c,%esp
    3855:	5b                   	pop    %ebx
    3856:	5e                   	pop    %esi
    3857:	5f                   	pop    %edi
    3858:	5d                   	pop    %ebp
    3859:	c3                   	ret    

0000385a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
    385a:	55                   	push   %ebp
    385b:	89 e5                	mov    %esp,%ebp
    385d:	57                   	push   %edi
    385e:	56                   	push   %esi
    385f:	53                   	push   %ebx
    3860:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    3863:	8d 45 10             	lea    0x10(%ebp),%eax
    3866:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
    3869:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
    386e:	bb 00 00 00 00       	mov    $0x0,%ebx
    3873:	eb 14                	jmp    3889 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
    3875:	89 fa                	mov    %edi,%edx
    3877:	8b 45 08             	mov    0x8(%ebp),%eax
    387a:	e8 41 ff ff ff       	call   37c0 <putc>
    387f:	eb 05                	jmp    3886 <printf+0x2c>
      }
    } else if(state == '%'){
    3881:	83 fe 25             	cmp    $0x25,%esi
    3884:	74 25                	je     38ab <printf+0x51>
  for(i = 0; fmt[i]; i++){
    3886:	83 c3 01             	add    $0x1,%ebx
    3889:	8b 45 0c             	mov    0xc(%ebp),%eax
    388c:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
    3890:	84 c0                	test   %al,%al
    3892:	0f 84 23 01 00 00    	je     39bb <printf+0x161>
    c = fmt[i] & 0xff;
    3898:	0f be f8             	movsbl %al,%edi
    389b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
    389e:	85 f6                	test   %esi,%esi
    38a0:	75 df                	jne    3881 <printf+0x27>
      if(c == '%'){
    38a2:	83 f8 25             	cmp    $0x25,%eax
    38a5:	75 ce                	jne    3875 <printf+0x1b>
        state = '%';
    38a7:	89 c6                	mov    %eax,%esi
    38a9:	eb db                	jmp    3886 <printf+0x2c>
      if(c == 'd'){
    38ab:	83 f8 64             	cmp    $0x64,%eax
    38ae:	74 49                	je     38f9 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
    38b0:	83 f8 78             	cmp    $0x78,%eax
    38b3:	0f 94 c1             	sete   %cl
    38b6:	83 f8 70             	cmp    $0x70,%eax
    38b9:	0f 94 c2             	sete   %dl
    38bc:	08 d1                	or     %dl,%cl
    38be:	75 63                	jne    3923 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
    38c0:	83 f8 73             	cmp    $0x73,%eax
    38c3:	0f 84 84 00 00 00    	je     394d <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    38c9:	83 f8 63             	cmp    $0x63,%eax
    38cc:	0f 84 b7 00 00 00    	je     3989 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
    38d2:	83 f8 25             	cmp    $0x25,%eax
    38d5:	0f 84 cc 00 00 00    	je     39a7 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    38db:	ba 25 00 00 00       	mov    $0x25,%edx
    38e0:	8b 45 08             	mov    0x8(%ebp),%eax
    38e3:	e8 d8 fe ff ff       	call   37c0 <putc>
        putc(fd, c);
    38e8:	89 fa                	mov    %edi,%edx
    38ea:	8b 45 08             	mov    0x8(%ebp),%eax
    38ed:	e8 ce fe ff ff       	call   37c0 <putc>
      }
      state = 0;
    38f2:	be 00 00 00 00       	mov    $0x0,%esi
    38f7:	eb 8d                	jmp    3886 <printf+0x2c>
        printint(fd, *ap, 10, 1);
    38f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    38fc:	8b 17                	mov    (%edi),%edx
    38fe:	83 ec 0c             	sub    $0xc,%esp
    3901:	6a 01                	push   $0x1
    3903:	b9 0a 00 00 00       	mov    $0xa,%ecx
    3908:	8b 45 08             	mov    0x8(%ebp),%eax
    390b:	e8 ca fe ff ff       	call   37da <printint>
        ap++;
    3910:	83 c7 04             	add    $0x4,%edi
    3913:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    3916:	83 c4 10             	add    $0x10,%esp
      state = 0;
    3919:	be 00 00 00 00       	mov    $0x0,%esi
    391e:	e9 63 ff ff ff       	jmp    3886 <printf+0x2c>
        printint(fd, *ap, 16, 0);
    3923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3926:	8b 17                	mov    (%edi),%edx
    3928:	83 ec 0c             	sub    $0xc,%esp
    392b:	6a 00                	push   $0x0
    392d:	b9 10 00 00 00       	mov    $0x10,%ecx
    3932:	8b 45 08             	mov    0x8(%ebp),%eax
    3935:	e8 a0 fe ff ff       	call   37da <printint>
        ap++;
    393a:	83 c7 04             	add    $0x4,%edi
    393d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    3940:	83 c4 10             	add    $0x10,%esp
      state = 0;
    3943:	be 00 00 00 00       	mov    $0x0,%esi
    3948:	e9 39 ff ff ff       	jmp    3886 <printf+0x2c>
        s = (char*)*ap;
    394d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3950:	8b 30                	mov    (%eax),%esi
        ap++;
    3952:	83 c0 04             	add    $0x4,%eax
    3955:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
    3958:	85 f6                	test   %esi,%esi
    395a:	75 28                	jne    3984 <printf+0x12a>
          s = "(null)";
    395c:	be ac 52 00 00       	mov    $0x52ac,%esi
    3961:	8b 7d 08             	mov    0x8(%ebp),%edi
    3964:	eb 0d                	jmp    3973 <printf+0x119>
          putc(fd, *s);
    3966:	0f be d2             	movsbl %dl,%edx
    3969:	89 f8                	mov    %edi,%eax
    396b:	e8 50 fe ff ff       	call   37c0 <putc>
          s++;
    3970:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
    3973:	0f b6 16             	movzbl (%esi),%edx
    3976:	84 d2                	test   %dl,%dl
    3978:	75 ec                	jne    3966 <printf+0x10c>
      state = 0;
    397a:	be 00 00 00 00       	mov    $0x0,%esi
    397f:	e9 02 ff ff ff       	jmp    3886 <printf+0x2c>
    3984:	8b 7d 08             	mov    0x8(%ebp),%edi
    3987:	eb ea                	jmp    3973 <printf+0x119>
        putc(fd, *ap);
    3989:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    398c:	0f be 17             	movsbl (%edi),%edx
    398f:	8b 45 08             	mov    0x8(%ebp),%eax
    3992:	e8 29 fe ff ff       	call   37c0 <putc>
        ap++;
    3997:	83 c7 04             	add    $0x4,%edi
    399a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
    399d:	be 00 00 00 00       	mov    $0x0,%esi
    39a2:	e9 df fe ff ff       	jmp    3886 <printf+0x2c>
        putc(fd, c);
    39a7:	89 fa                	mov    %edi,%edx
    39a9:	8b 45 08             	mov    0x8(%ebp),%eax
    39ac:	e8 0f fe ff ff       	call   37c0 <putc>
      state = 0;
    39b1:	be 00 00 00 00       	mov    $0x0,%esi
    39b6:	e9 cb fe ff ff       	jmp    3886 <printf+0x2c>
    }
  }
}
    39bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
    39be:	5b                   	pop    %ebx
    39bf:	5e                   	pop    %esi
    39c0:	5f                   	pop    %edi
    39c1:	5d                   	pop    %ebp
    39c2:	c3                   	ret    

000039c3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    39c3:	55                   	push   %ebp
    39c4:	89 e5                	mov    %esp,%ebp
    39c6:	57                   	push   %edi
    39c7:	56                   	push   %esi
    39c8:	53                   	push   %ebx
    39c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
    39cc:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    39cf:	a1 00 5c 00 00       	mov    0x5c00,%eax
    39d4:	eb 02                	jmp    39d8 <free+0x15>
    39d6:	89 d0                	mov    %edx,%eax
    39d8:	39 c8                	cmp    %ecx,%eax
    39da:	73 04                	jae    39e0 <free+0x1d>
    39dc:	39 08                	cmp    %ecx,(%eax)
    39de:	77 12                	ja     39f2 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    39e0:	8b 10                	mov    (%eax),%edx
    39e2:	39 c2                	cmp    %eax,%edx
    39e4:	77 f0                	ja     39d6 <free+0x13>
    39e6:	39 c8                	cmp    %ecx,%eax
    39e8:	72 08                	jb     39f2 <free+0x2f>
    39ea:	39 ca                	cmp    %ecx,%edx
    39ec:	77 04                	ja     39f2 <free+0x2f>
    39ee:	89 d0                	mov    %edx,%eax
    39f0:	eb e6                	jmp    39d8 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
    39f2:	8b 73 fc             	mov    -0x4(%ebx),%esi
    39f5:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
    39f8:	8b 10                	mov    (%eax),%edx
    39fa:	39 d7                	cmp    %edx,%edi
    39fc:	74 19                	je     3a17 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
    39fe:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
    3a01:	8b 50 04             	mov    0x4(%eax),%edx
    3a04:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    3a07:	39 ce                	cmp    %ecx,%esi
    3a09:	74 1b                	je     3a26 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
    3a0b:	89 08                	mov    %ecx,(%eax)
  freep = p;
    3a0d:	a3 00 5c 00 00       	mov    %eax,0x5c00
}
    3a12:	5b                   	pop    %ebx
    3a13:	5e                   	pop    %esi
    3a14:	5f                   	pop    %edi
    3a15:	5d                   	pop    %ebp
    3a16:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
    3a17:	03 72 04             	add    0x4(%edx),%esi
    3a1a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
    3a1d:	8b 10                	mov    (%eax),%edx
    3a1f:	8b 12                	mov    (%edx),%edx
    3a21:	89 53 f8             	mov    %edx,-0x8(%ebx)
    3a24:	eb db                	jmp    3a01 <free+0x3e>
    p->s.size += bp->s.size;
    3a26:	03 53 fc             	add    -0x4(%ebx),%edx
    3a29:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    3a2c:	8b 53 f8             	mov    -0x8(%ebx),%edx
    3a2f:	89 10                	mov    %edx,(%eax)
    3a31:	eb da                	jmp    3a0d <free+0x4a>

00003a33 <morecore>:

static Header*
morecore(uint nu)
{
    3a33:	55                   	push   %ebp
    3a34:	89 e5                	mov    %esp,%ebp
    3a36:	53                   	push   %ebx
    3a37:	83 ec 04             	sub    $0x4,%esp
    3a3a:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
    3a3c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
    3a41:	77 05                	ja     3a48 <morecore+0x15>
    nu = 4096;
    3a43:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
    3a48:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
    3a4f:	83 ec 0c             	sub    $0xc,%esp
    3a52:	50                   	push   %eax
    3a53:	e8 50 fd ff ff       	call   37a8 <sbrk>
  if(p == (char*)-1)
    3a58:	83 c4 10             	add    $0x10,%esp
    3a5b:	83 f8 ff             	cmp    $0xffffffff,%eax
    3a5e:	74 1c                	je     3a7c <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    3a60:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
    3a63:	83 c0 08             	add    $0x8,%eax
    3a66:	83 ec 0c             	sub    $0xc,%esp
    3a69:	50                   	push   %eax
    3a6a:	e8 54 ff ff ff       	call   39c3 <free>
  return freep;
    3a6f:	a1 00 5c 00 00       	mov    0x5c00,%eax
    3a74:	83 c4 10             	add    $0x10,%esp
}
    3a77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3a7a:	c9                   	leave  
    3a7b:	c3                   	ret    
    return 0;
    3a7c:	b8 00 00 00 00       	mov    $0x0,%eax
    3a81:	eb f4                	jmp    3a77 <morecore+0x44>

00003a83 <malloc>:

void*
malloc(uint nbytes)
{
    3a83:	55                   	push   %ebp
    3a84:	89 e5                	mov    %esp,%ebp
    3a86:	53                   	push   %ebx
    3a87:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    3a8a:	8b 45 08             	mov    0x8(%ebp),%eax
    3a8d:	8d 58 07             	lea    0x7(%eax),%ebx
    3a90:	c1 eb 03             	shr    $0x3,%ebx
    3a93:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
    3a96:	8b 0d 00 5c 00 00    	mov    0x5c00,%ecx
    3a9c:	85 c9                	test   %ecx,%ecx
    3a9e:	74 04                	je     3aa4 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3aa0:	8b 01                	mov    (%ecx),%eax
    3aa2:	eb 4d                	jmp    3af1 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
    3aa4:	c7 05 00 5c 00 00 04 	movl   $0x5c04,0x5c00
    3aab:	5c 00 00 
    3aae:	c7 05 04 5c 00 00 04 	movl   $0x5c04,0x5c04
    3ab5:	5c 00 00 
    base.s.size = 0;
    3ab8:	c7 05 08 5c 00 00 00 	movl   $0x0,0x5c08
    3abf:	00 00 00 
    base.s.ptr = freep = prevp = &base;
    3ac2:	b9 04 5c 00 00       	mov    $0x5c04,%ecx
    3ac7:	eb d7                	jmp    3aa0 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
    3ac9:	39 da                	cmp    %ebx,%edx
    3acb:	74 1a                	je     3ae7 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    3acd:	29 da                	sub    %ebx,%edx
    3acf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    3ad2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    3ad5:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    3ad8:	89 0d 00 5c 00 00    	mov    %ecx,0x5c00
      return (void*)(p + 1);
    3ade:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    3ae1:	83 c4 04             	add    $0x4,%esp
    3ae4:	5b                   	pop    %ebx
    3ae5:	5d                   	pop    %ebp
    3ae6:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
    3ae7:	8b 10                	mov    (%eax),%edx
    3ae9:	89 11                	mov    %edx,(%ecx)
    3aeb:	eb eb                	jmp    3ad8 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3aed:	89 c1                	mov    %eax,%ecx
    3aef:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
    3af1:	8b 50 04             	mov    0x4(%eax),%edx
    3af4:	39 da                	cmp    %ebx,%edx
    3af6:	73 d1                	jae    3ac9 <malloc+0x46>
    if(p == freep)
    3af8:	39 05 00 5c 00 00    	cmp    %eax,0x5c00
    3afe:	75 ed                	jne    3aed <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
    3b00:	89 d8                	mov    %ebx,%eax
    3b02:	e8 2c ff ff ff       	call   3a33 <morecore>
    3b07:	85 c0                	test   %eax,%eax
    3b09:	75 e2                	jne    3aed <malloc+0x6a>
        return 0;
    3b0b:	b8 00 00 00 00       	mov    $0x0,%eax
    3b10:	eb cf                	jmp    3ae1 <malloc+0x5e>
