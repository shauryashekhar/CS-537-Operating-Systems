
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 64 2a 10 80       	mov    $0x80102a64,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 c0 b5 10 80       	push   $0x8010b5c0
80100046:	e8 ea 42 00 00       	call   80104335 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 c0 b5 10 80       	push   $0x8010b5c0
8010007c:	e8 19 43 00 00       	call   8010439a <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 95 40 00 00       	call   80104121 <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 c0 b5 10 80       	push   $0x8010b5c0
801000ca:	e8 cb 42 00 00       	call   8010439a <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 47 40 00 00       	call   80104121 <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 a0 6c 10 80       	push   $0x80106ca0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 b1 6c 10 80       	push   $0x80106cb1
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 ef 40 00 00       	call   801041f9 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100111:	fc 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
8010011b:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 b8 6c 10 80       	push   $0x80106cb8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 a6 3f 00 00       	call   801040ee <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 77 1c 00 00       	call   80101e0c <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 fe 3f 00 00       	call   801041ab <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 4c 1c 00 00       	call   80101e0c <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 bf 6c 10 80       	push   $0x80106cbf
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 c2 3f 00 00       	call   801041ab <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 77 3f 00 00       	call   80104170 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 30 41 00 00       	call   80104335 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 c0 b5 10 80       	push   $0x8010b5c0
8010024c:	e8 49 41 00 00       	call   8010439a <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 c6 6c 10 80       	push   $0x80106cc6
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 c3 13 00 00       	call   80101643 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028a:	e8 a6 40 00 00       	call   80104335 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 ad 30 00 00       	call   80103359 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 10 80       	push   $0x8010a520
801002ba:	68 a0 ff 10 80       	push   $0x8010ffa0
801002bf:	e8 ca 33 00 00       	call   8010368e <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 c4 40 00 00       	call   8010439a <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 a3 12 00 00       	call   80101581 <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 a0 ff 10 80    	mov    %edx,0x8010ffa0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 20 ff 10 80 	movzbl -0x7fef00e0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 10 80       	push   $0x8010a520
80100331:	e8 64 40 00 00       	call   8010439a <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 43 12 00 00       	call   80101581 <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 1f 20 00 00       	call   8010237e <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 cd 6c 10 80       	push   $0x80106ccd
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 c1 72 10 80 	movl   $0x801072c1,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 80 3e 00 00       	call   80104214 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 e1 6c 10 80       	push   $0x80106ce1
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 e5 6c 10 80       	push   $0x80106ce5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 9d 3f 00 00       	call   8010445c <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 03 3f 00 00       	call   801043e1 <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 7f 53 00 00       	call   8010588a <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 66 53 00 00       	call   8010588a <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 5a 53 00 00       	call   8010588a <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 4e 53 00 00       	call   8010588a <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 10 6d 10 80 	movzbl -0x7fef92f0(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 80 10 00 00       	call   80101643 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ca:	e8 66 3d 00 00       	call   80104335 <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 a5 10 80       	push   $0x8010a520
801005f1:	e8 a4 3d 00 00       	call   8010439a <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 80 0f 00 00       	call   80101581 <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 a5 10 80       	mov    0x8010a554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 a5 10 80       	push   $0x8010a520
80100638:	e8 f8 3c 00 00       	call   80104335 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 ff 6c 10 80       	push   $0x80106cff
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be f8 6c 10 80       	mov    $0x80106cf8,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 a5 10 80       	push   $0x8010a520
80100734:	e8 61 3c 00 00       	call   8010439a <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 e1 3b 00 00       	call   80104335 <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 a8 ff 10 80    	mov    %edx,0x8010ffa8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 20 ff 10 80    	mov    %cl,-0x7fef00e0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 a8 ff 10 80    	cmp    %eax,0x8010ffa8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007d1:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 a0 ff 10 80       	push   $0x8010ffa0
801007de:	e8 13 30 00 00       	call   801037f6 <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007fc:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010084f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 10 80       	push   $0x8010a520
80100873:	e8 22 3b 00 00       	call   8010439a <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 3c 30 00 00       	call   801038c8 <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 08 6d 10 80       	push   $0x80106d08
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 56 39 00 00       	call   801041f9 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 6c 09 11 80 ac 	movl   $0x801005ac,0x8011096c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 68 09 11 80 68 	movl   $0x80100268,0x80110968
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 b1 16 00 00       	call   80101f7e <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 76 2a 00 00       	call   80103359 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 c0 1e 00 00       	call   801027ae <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 e8 12 00 00       	call   80101be1 <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 76 0c 00 00       	call   80101581 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 57 0e 00 00       	call   80101773 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 dd 02 00 00    	je     80100c09 <exec+0x337>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 f3 0d 00 00       	call   80101728 <iunlockput>
    end_op();
80100935:	e8 ee 1e 00 00       	call   80102828 <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 d9 1e 00 00       	call   80102828 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 21 6d 10 80       	push   $0x80106d21
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 d3 60 00 00       	call   80106a4a <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 06 01 00 00    	je     80100a8b <exec+0x1b9>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 98 00 00 00    	jle    80100a4a <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 ab 0d 00 00       	call   80101773 <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 b7 00 00 00    	jne    80100a8b <exec+0x1b9>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 9c 00 00 00    	jb     80100a8b <exec+0x1b9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 90 00 00 00    	jb     80100a8b <exec+0x1b9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009fb:	83 ec 04             	sub    $0x4,%esp
801009fe:	50                   	push   %eax
801009ff:	57                   	push   %edi
80100a00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a06:	e8 e5 5e 00 00       	call   801068f0 <allocuvm>
80100a0b:	89 c7                	mov    %eax,%edi
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	85 c0                	test   %eax,%eax
80100a12:	74 77                	je     80100a8b <exec+0x1b9>
    if(ph.vaddr % PGSIZE != 0)
80100a14:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a1a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1f:	75 6a                	jne    80100a8b <exec+0x1b9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a21:	83 ec 0c             	sub    $0xc,%esp
80100a24:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a2a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a30:	53                   	push   %ebx
80100a31:	50                   	push   %eax
80100a32:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a38:	e8 81 5d 00 00       	call   801067be <loaduvm>
80100a3d:	83 c4 20             	add    $0x20,%esp
80100a40:	85 c0                	test   %eax,%eax
80100a42:	0f 89 4f ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a48:	eb 41                	jmp    80100a8b <exec+0x1b9>
  iunlockput(ip);
80100a4a:	83 ec 0c             	sub    $0xc,%esp
80100a4d:	53                   	push   %ebx
80100a4e:	e8 d5 0c 00 00       	call   80101728 <iunlockput>
  end_op();
80100a53:	e8 d0 1d 00 00       	call   80102828 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 77 5e 00 00       	call   801068f0 <allocuvm>
80100a79:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a7f:	83 c4 10             	add    $0x10,%esp
80100a82:	85 c0                	test   %eax,%eax
80100a84:	75 24                	jne    80100aaa <exec+0x1d8>
  ip = 0;
80100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a91:	85 c0                	test   %eax,%eax
80100a93:	0f 84 8b fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100a99:	83 ec 0c             	sub    $0xc,%esp
80100a9c:	50                   	push   %eax
80100a9d:	e8 38 5f 00 00       	call   801069da <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 0e 60 00 00       	call   80106acf <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	83 c4 10             	add    $0x10,%esp
80100ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100acc:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100acf:	8b 06                	mov    (%esi),%eax
80100ad1:	85 c0                	test   %eax,%eax
80100ad3:	74 4d                	je     80100b22 <exec+0x250>
    if(argc >= MAXARG)
80100ad5:	83 fb 1f             	cmp    $0x1f,%ebx
80100ad8:	0f 87 0d 01 00 00    	ja     80100beb <exec+0x319>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 9c 3a 00 00       	call   80104583 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 8a 3a 00 00       	call   80104583 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 12 61 00 00       	call   80106c1d <copyout>
80100b0b:	83 c4 20             	add    $0x20,%esp
80100b0e:	85 c0                	test   %eax,%eax
80100b10:	0f 88 df 00 00 00    	js     80100bf5 <exec+0x323>
    ustack[3+argc] = sp;
80100b16:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b1d:	83 c3 01             	add    $0x1,%ebx
80100b20:	eb a7                	jmp    80100ac9 <exec+0x1f7>
  ustack[3+argc] = 0;
80100b22:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b29:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2d:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b34:	ff ff ff 
  ustack[1] = argc;
80100b37:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b44:	89 f9                	mov    %edi,%ecx
80100b46:	29 c1                	sub    %eax,%ecx
80100b48:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b4e:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b55:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b57:	50                   	push   %eax
80100b58:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b5e:	50                   	push   %eax
80100b5f:	57                   	push   %edi
80100b60:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b66:	e8 b2 60 00 00       	call   80106c1d <copyout>
80100b6b:	83 c4 10             	add    $0x10,%esp
80100b6e:	85 c0                	test   %eax,%eax
80100b70:	0f 88 89 00 00 00    	js     80100bff <exec+0x32d>
  for(last=s=path; *s; s++)
80100b76:	8b 55 08             	mov    0x8(%ebp),%edx
80100b79:	89 d0                	mov    %edx,%eax
80100b7b:	eb 03                	jmp    80100b80 <exec+0x2ae>
80100b7d:	83 c0 01             	add    $0x1,%eax
80100b80:	0f b6 08             	movzbl (%eax),%ecx
80100b83:	84 c9                	test   %cl,%cl
80100b85:	74 0a                	je     80100b91 <exec+0x2bf>
    if(*s == '/')
80100b87:	80 f9 2f             	cmp    $0x2f,%cl
80100b8a:	75 f1                	jne    80100b7d <exec+0x2ab>
      last = s+1;
80100b8c:	8d 50 01             	lea    0x1(%eax),%edx
80100b8f:	eb ec                	jmp    80100b7d <exec+0x2ab>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b91:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100b97:	89 f0                	mov    %esi,%eax
80100b99:	83 c0 6c             	add    $0x6c,%eax
80100b9c:	83 ec 04             	sub    $0x4,%esp
80100b9f:	6a 10                	push   $0x10
80100ba1:	52                   	push   %edx
80100ba2:	50                   	push   %eax
80100ba3:	e8 a0 39 00 00       	call   80104548 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bab:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bb1:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bb4:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bba:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bbc:	8b 46 18             	mov    0x18(%esi),%eax
80100bbf:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bce:	89 34 24             	mov    %esi,(%esp)
80100bd1:	e8 67 5a 00 00       	call   8010663d <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 fc 5d 00 00       	call   801069da <freevm>
  return 0;
80100bde:	83 c4 10             	add    $0x10,%esp
80100be1:	b8 00 00 00 00       	mov    $0x0,%eax
80100be6:	e9 57 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf0:	e9 96 fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfa:	e9 8c fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 82 fe ff ff       	jmp    80100a8b <exec+0x1b9>
  return -1;
80100c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0e:	e9 2f fd ff ff       	jmp    80100942 <exec+0x70>

80100c13 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c19:	68 2d 6d 10 80       	push   $0x80106d2d
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 d1 35 00 00       	call   801041f9 <initlock>
}
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	c9                   	leave  
80100c2c:	c3                   	ret    

80100c2d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c2d:	55                   	push   %ebp
80100c2e:	89 e5                	mov    %esp,%ebp
80100c30:	53                   	push   %ebx
80100c31:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c34:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c39:	e8 f7 36 00 00       	call   80104335 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
80100c46:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100c4c:	73 29                	jae    80100c77 <filealloc+0x4a>
    if(f->ref == 0){
80100c4e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c52:	74 05                	je     80100c59 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c54:	83 c3 18             	add    $0x18,%ebx
80100c57:	eb ed                	jmp    80100c46 <filealloc+0x19>
      f->ref = 1;
80100c59:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c60:	83 ec 0c             	sub    $0xc,%esp
80100c63:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c68:	e8 2d 37 00 00       	call   8010439a <release>
      return f;
80100c6d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c70:	89 d8                	mov    %ebx,%eax
80100c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c75:	c9                   	leave  
80100c76:	c3                   	ret    
  release(&ftable.lock);
80100c77:	83 ec 0c             	sub    $0xc,%esp
80100c7a:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c7f:	e8 16 37 00 00       	call   8010439a <release>
  return 0;
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c8c:	eb e2                	jmp    80100c70 <filealloc+0x43>

80100c8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	53                   	push   %ebx
80100c92:	83 ec 10             	sub    $0x10,%esp
80100c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c98:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c9d:	e8 93 36 00 00       	call   80104335 <acquire>
  if(f->ref < 1)
80100ca2:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca5:	83 c4 10             	add    $0x10,%esp
80100ca8:	85 c0                	test   %eax,%eax
80100caa:	7e 1a                	jle    80100cc6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cac:	83 c0 01             	add    $0x1,%eax
80100caf:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cb2:	83 ec 0c             	sub    $0xc,%esp
80100cb5:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cba:	e8 db 36 00 00       	call   8010439a <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 34 6d 10 80       	push   $0x80106d34
80100cce:	e8 75 f6 ff ff       	call   80100348 <panic>

80100cd3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cd3:	55                   	push   %ebp
80100cd4:	89 e5                	mov    %esp,%ebp
80100cd6:	53                   	push   %ebx
80100cd7:	83 ec 30             	sub    $0x30,%esp
80100cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cdd:	68 c0 ff 10 80       	push   $0x8010ffc0
80100ce2:	e8 4e 36 00 00       	call   80104335 <acquire>
  if(f->ref < 1)
80100ce7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cea:	83 c4 10             	add    $0x10,%esp
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 1f                	jle    80100d10 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cf1:	83 e8 01             	sub    $0x1,%eax
80100cf4:	89 43 04             	mov    %eax,0x4(%ebx)
80100cf7:	85 c0                	test   %eax,%eax
80100cf9:	7e 22                	jle    80100d1d <fileclose+0x4a>
    release(&ftable.lock);
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d03:	e8 92 36 00 00       	call   8010439a <release>
    return;
80100d08:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d0e:	c9                   	leave  
80100d0f:	c3                   	ret    
    panic("fileclose");
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 3c 6d 10 80       	push   $0x80106d3c
80100d18:	e8 2b f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d1d:	8b 03                	mov    (%ebx),%eax
80100d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d22:	8b 43 08             	mov    0x8(%ebx),%eax
80100d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d28:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d2e:	8b 43 10             	mov    0x10(%ebx),%eax
80100d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d34:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d49:	e8 4c 36 00 00       	call   8010439a <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 4b 1a 00 00       	call   801027ae <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 b5 1a 00 00       	call   80102828 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 9a 20 00 00       	call   80102e22 <pipeclose>
80100d88:	83 c4 10             	add    $0x10,%esp
80100d8b:	e9 7b ff ff ff       	jmp    80100d0b <fileclose+0x38>

80100d90 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d90:	55                   	push   %ebp
80100d91:	89 e5                	mov    %esp,%ebp
80100d93:	53                   	push   %ebx
80100d94:	83 ec 04             	sub    $0x4,%esp
80100d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d9a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d9d:	75 31                	jne    80100dd0 <filestat+0x40>
    ilock(f->ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 73 10             	pushl  0x10(%ebx)
80100da5:	e8 d7 07 00 00       	call   80101581 <ilock>
    stati(f->ip, st);
80100daa:	83 c4 08             	add    $0x8,%esp
80100dad:	ff 75 0c             	pushl  0xc(%ebp)
80100db0:	ff 73 10             	pushl  0x10(%ebx)
80100db3:	e8 90 09 00 00       	call   80101748 <stati>
    iunlock(f->ip);
80100db8:	83 c4 04             	add    $0x4,%esp
80100dbb:	ff 73 10             	pushl  0x10(%ebx)
80100dbe:	e8 80 08 00 00       	call   80101643 <iunlock>
    return 0;
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dce:	c9                   	leave  
80100dcf:	c3                   	ret    
  return -1;
80100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dd5:	eb f4                	jmp    80100dcb <filestat+0x3b>

80100dd7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd7:	55                   	push   %ebp
80100dd8:	89 e5                	mov    %esp,%ebp
80100dda:	56                   	push   %esi
80100ddb:	53                   	push   %ebx
80100ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100ddf:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100de3:	74 70                	je     80100e55 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100de5:	8b 03                	mov    (%ebx),%eax
80100de7:	83 f8 01             	cmp    $0x1,%eax
80100dea:	74 44                	je     80100e30 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100dec:	83 f8 02             	cmp    $0x2,%eax
80100def:	75 57                	jne    80100e48 <fileread+0x71>
    ilock(f->ip);
80100df1:	83 ec 0c             	sub    $0xc,%esp
80100df4:	ff 73 10             	pushl  0x10(%ebx)
80100df7:	e8 85 07 00 00       	call   80101581 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dfc:	ff 75 10             	pushl  0x10(%ebp)
80100dff:	ff 73 14             	pushl  0x14(%ebx)
80100e02:	ff 75 0c             	pushl  0xc(%ebp)
80100e05:	ff 73 10             	pushl  0x10(%ebx)
80100e08:	e8 66 09 00 00       	call   80101773 <readi>
80100e0d:	89 c6                	mov    %eax,%esi
80100e0f:	83 c4 20             	add    $0x20,%esp
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7e 03                	jle    80100e19 <fileread+0x42>
      f->off += r;
80100e16:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 73 10             	pushl  0x10(%ebx)
80100e1f:	e8 1f 08 00 00       	call   80101643 <iunlock>
    return r;
80100e24:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e27:	89 f0                	mov    %esi,%eax
80100e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e2c:	5b                   	pop    %ebx
80100e2d:	5e                   	pop    %esi
80100e2e:	5d                   	pop    %ebp
80100e2f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e30:	83 ec 04             	sub    $0x4,%esp
80100e33:	ff 75 10             	pushl  0x10(%ebp)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 0c             	pushl  0xc(%ebx)
80100e3c:	e8 39 21 00 00       	call   80102f7a <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 46 6d 10 80       	push   $0x80106d46
80100e50:	e8 f3 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e55:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e5a:	eb cb                	jmp    80100e27 <fileread+0x50>

80100e5c <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	57                   	push   %edi
80100e60:	56                   	push   %esi
80100e61:	53                   	push   %ebx
80100e62:	83 ec 1c             	sub    $0x1c,%esp
80100e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e6c:	0f 84 c5 00 00 00    	je     80100f37 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e72:	8b 03                	mov    (%ebx),%eax
80100e74:	83 f8 01             	cmp    $0x1,%eax
80100e77:	74 10                	je     80100e89 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e79:	83 f8 02             	cmp    $0x2,%eax
80100e7c:	0f 85 a8 00 00 00    	jne    80100f2a <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e82:	bf 00 00 00 00       	mov    $0x0,%edi
80100e87:	eb 67                	jmp    80100ef0 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e89:	83 ec 04             	sub    $0x4,%esp
80100e8c:	ff 75 10             	pushl  0x10(%ebp)
80100e8f:	ff 75 0c             	pushl  0xc(%ebp)
80100e92:	ff 73 0c             	pushl  0xc(%ebx)
80100e95:	e8 14 20 00 00       	call   80102eae <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 07 19 00 00       	call   801027ae <begin_op>
      ilock(f->ip);
80100ea7:	83 ec 0c             	sub    $0xc,%esp
80100eaa:	ff 73 10             	pushl  0x10(%ebx)
80100ead:	e8 cf 06 00 00       	call   80101581 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100eb2:	89 f8                	mov    %edi,%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eba:	ff 73 14             	pushl  0x14(%ebx)
80100ebd:	50                   	push   %eax
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 aa 09 00 00       	call   80101870 <writei>
80100ec6:	89 c6                	mov    %eax,%esi
80100ec8:	83 c4 20             	add    $0x20,%esp
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	7e 03                	jle    80100ed2 <filewrite+0x76>
        f->off += r;
80100ecf:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ed2:	83 ec 0c             	sub    $0xc,%esp
80100ed5:	ff 73 10             	pushl  0x10(%ebx)
80100ed8:	e8 66 07 00 00       	call   80101643 <iunlock>
      end_op();
80100edd:	e8 46 19 00 00       	call   80102828 <end_op>

      if(r < 0)
80100ee2:	83 c4 10             	add    $0x10,%esp
80100ee5:	85 f6                	test   %esi,%esi
80100ee7:	78 31                	js     80100f1a <filewrite+0xbe>
        break;
      if(r != n1)
80100ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100eec:	75 1f                	jne    80100f0d <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eee:	01 f7                	add    %esi,%edi
    while(i < n){
80100ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ef3:	7d 25                	jge    80100f1a <filewrite+0xbe>
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 9e                	jle    80100ea2 <filewrite+0x46>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f0b:	eb 95                	jmp    80100ea2 <filewrite+0x46>
        panic("short filewrite");
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	68 4f 6d 10 80       	push   $0x80106d4f
80100f15:	e8 2e f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f1d:	75 1f                	jne    80100f3e <filewrite+0xe2>
80100f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f25:	5b                   	pop    %ebx
80100f26:	5e                   	pop    %esi
80100f27:	5f                   	pop    %edi
80100f28:	5d                   	pop    %ebp
80100f29:	c3                   	ret    
  panic("filewrite");
80100f2a:	83 ec 0c             	sub    $0xc,%esp
80100f2d:	68 55 6d 10 80       	push   $0x80106d55
80100f32:	e8 11 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3c:	eb e4                	jmp    80100f22 <filewrite+0xc6>
    return i == n ? n : -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f43:	eb dd                	jmp    80100f22 <filewrite+0xc6>

80100f45 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	57                   	push   %edi
80100f49:	56                   	push   %esi
80100f4a:	53                   	push   %ebx
80100f4b:	83 ec 0c             	sub    $0xc,%esp
80100f4e:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f50:	eb 03                	jmp    80100f55 <skipelem+0x10>
    path++;
80100f52:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f55:	0f b6 10             	movzbl (%eax),%edx
80100f58:	80 fa 2f             	cmp    $0x2f,%dl
80100f5b:	74 f5                	je     80100f52 <skipelem+0xd>
  if(*path == 0)
80100f5d:	84 d2                	test   %dl,%dl
80100f5f:	74 59                	je     80100fba <skipelem+0x75>
80100f61:	89 c3                	mov    %eax,%ebx
80100f63:	eb 03                	jmp    80100f68 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f65:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f68:	0f b6 13             	movzbl (%ebx),%edx
80100f6b:	80 fa 2f             	cmp    $0x2f,%dl
80100f6e:	0f 95 c1             	setne  %cl
80100f71:	84 d2                	test   %dl,%dl
80100f73:	0f 95 c2             	setne  %dl
80100f76:	84 d1                	test   %dl,%cl
80100f78:	75 eb                	jne    80100f65 <skipelem+0x20>
  len = path - s;
80100f7a:	89 de                	mov    %ebx,%esi
80100f7c:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f7e:	83 fe 0d             	cmp    $0xd,%esi
80100f81:	7e 11                	jle    80100f94 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f83:	83 ec 04             	sub    $0x4,%esp
80100f86:	6a 0e                	push   $0xe
80100f88:	50                   	push   %eax
80100f89:	57                   	push   %edi
80100f8a:	e8 cd 34 00 00       	call   8010445c <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 bd 34 00 00       	call   8010445c <memmove>
    name[len] = 0;
80100f9f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 03                	jmp    80100fab <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fa8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fab:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fae:	74 f8                	je     80100fa8 <skipelem+0x63>
  return path;
}
80100fb0:	89 d8                	mov    %ebx,%eax
80100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb5:	5b                   	pop    %ebx
80100fb6:	5e                   	pop    %esi
80100fb7:	5f                   	pop    %edi
80100fb8:	5d                   	pop    %ebp
80100fb9:	c3                   	ret    
    return 0;
80100fba:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fbf:	eb ef                	jmp    80100fb0 <skipelem+0x6b>

80100fc1 <bzero>:
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	53                   	push   %ebx
80100fc5:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fc8:	52                   	push   %edx
80100fc9:	50                   	push   %eax
80100fca:	e8 9d f1 ff ff       	call   8010016c <bread>
80100fcf:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fd1:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fd4:	83 c4 0c             	add    $0xc,%esp
80100fd7:	68 00 02 00 00       	push   $0x200
80100fdc:	6a 00                	push   $0x0
80100fde:	50                   	push   %eax
80100fdf:	e8 fd 33 00 00       	call   801043e1 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 eb 18 00 00       	call   801028d7 <log_write>
  brelse(bp);
80100fec:	89 1c 24             	mov    %ebx,(%esp)
80100fef:	e8 e1 f1 ff ff       	call   801001d5 <brelse>
}
80100ff4:	83 c4 10             	add    $0x10,%esp
80100ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <balloc>:
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	57                   	push   %edi
80101000:	56                   	push   %esi
80101001:	53                   	push   %ebx
80101002:	83 ec 1c             	sub    $0x1c,%esp
80101005:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101008:	be 00 00 00 00       	mov    $0x0,%esi
8010100d:	eb 14                	jmp    80101023 <balloc+0x27>
    brelse(bp);
8010100f:	83 ec 0c             	sub    $0xc,%esp
80101012:	ff 75 e4             	pushl  -0x1c(%ebp)
80101015:	e8 bb f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010101a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101020:	83 c4 10             	add    $0x10,%esp
80101023:	39 35 c0 09 11 80    	cmp    %esi,0x801109c0
80101029:	76 75                	jbe    801010a0 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010102b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101031:	85 f6                	test   %esi,%esi
80101033:	0f 49 c6             	cmovns %esi,%eax
80101036:	c1 f8 0c             	sar    $0xc,%eax
80101039:	03 05 d8 09 11 80    	add    0x801109d8,%eax
8010103f:	83 ec 08             	sub    $0x8,%esp
80101042:	50                   	push   %eax
80101043:	ff 75 d8             	pushl  -0x28(%ebp)
80101046:	e8 21 f1 ff ff       	call   8010016c <bread>
8010104b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010104e:	83 c4 10             	add    $0x10,%esp
80101051:	b8 00 00 00 00       	mov    $0x0,%eax
80101056:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010105b:	7f b2                	jg     8010100f <balloc+0x13>
8010105d:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80101060:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101063:	3b 1d c0 09 11 80    	cmp    0x801109c0,%ebx
80101069:	73 a4                	jae    8010100f <balloc+0x13>
      m = 1 << (bi % 8);
8010106b:	99                   	cltd   
8010106c:	c1 ea 1d             	shr    $0x1d,%edx
8010106f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101072:	83 e1 07             	and    $0x7,%ecx
80101075:	29 d1                	sub    %edx,%ecx
80101077:	ba 01 00 00 00       	mov    $0x1,%edx
8010107c:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010107e:	8d 48 07             	lea    0x7(%eax),%ecx
80101081:	85 c0                	test   %eax,%eax
80101083:	0f 49 c8             	cmovns %eax,%ecx
80101086:	c1 f9 03             	sar    $0x3,%ecx
80101089:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010108c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010108f:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101094:	0f b6 f9             	movzbl %cl,%edi
80101097:	85 d7                	test   %edx,%edi
80101099:	74 12                	je     801010ad <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010109b:	83 c0 01             	add    $0x1,%eax
8010109e:	eb b6                	jmp    80101056 <balloc+0x5a>
  panic("balloc: out of blocks");
801010a0:	83 ec 0c             	sub    $0xc,%esp
801010a3:	68 5f 6d 10 80       	push   $0x80106d5f
801010a8:	e8 9b f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010ad:	09 ca                	or     %ecx,%edx
801010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b2:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010b5:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010b9:	83 ec 0c             	sub    $0xc,%esp
801010bc:	89 c6                	mov    %eax,%esi
801010be:	50                   	push   %eax
801010bf:	e8 13 18 00 00       	call   801028d7 <log_write>
        brelse(bp);
801010c4:	89 34 24             	mov    %esi,(%esp)
801010c7:	e8 09 f1 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010cc:	89 da                	mov    %ebx,%edx
801010ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010d1:	e8 eb fe ff ff       	call   80100fc1 <bzero>
}
801010d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010dc:	5b                   	pop    %ebx
801010dd:	5e                   	pop    %esi
801010de:	5f                   	pop    %edi
801010df:	5d                   	pop    %ebp
801010e0:	c3                   	ret    

801010e1 <bmap>:
{
801010e1:	55                   	push   %ebp
801010e2:	89 e5                	mov    %esp,%ebp
801010e4:	57                   	push   %edi
801010e5:	56                   	push   %esi
801010e6:	53                   	push   %ebx
801010e7:	83 ec 1c             	sub    $0x1c,%esp
801010ea:	89 c6                	mov    %eax,%esi
801010ec:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801010ee:	83 fa 0b             	cmp    $0xb,%edx
801010f1:	77 17                	ja     8010110a <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
801010f3:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
801010f7:	85 db                	test   %ebx,%ebx
801010f9:	75 4a                	jne    80101145 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010fb:	8b 00                	mov    (%eax),%eax
801010fd:	e8 fa fe ff ff       	call   80100ffc <balloc>
80101102:	89 c3                	mov    %eax,%ebx
80101104:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101108:	eb 3b                	jmp    80101145 <bmap+0x64>
  bn -= NDIRECT;
8010110a:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010110d:	83 fb 7f             	cmp    $0x7f,%ebx
80101110:	77 68                	ja     8010117a <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101112:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101118:	85 c0                	test   %eax,%eax
8010111a:	74 33                	je     8010114f <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010111c:	83 ec 08             	sub    $0x8,%esp
8010111f:	50                   	push   %eax
80101120:	ff 36                	pushl  (%esi)
80101122:	e8 45 f0 ff ff       	call   8010016c <bread>
80101127:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101129:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
8010112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101130:	8b 18                	mov    (%eax),%ebx
80101132:	83 c4 10             	add    $0x10,%esp
80101135:	85 db                	test   %ebx,%ebx
80101137:	74 25                	je     8010115e <bmap+0x7d>
    brelse(bp);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	57                   	push   %edi
8010113d:	e8 93 f0 ff ff       	call   801001d5 <brelse>
    return addr;
80101142:	83 c4 10             	add    $0x10,%esp
}
80101145:	89 d8                	mov    %ebx,%eax
80101147:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114a:	5b                   	pop    %ebx
8010114b:	5e                   	pop    %esi
8010114c:	5f                   	pop    %edi
8010114d:	5d                   	pop    %ebp
8010114e:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010114f:	8b 06                	mov    (%esi),%eax
80101151:	e8 a6 fe ff ff       	call   80100ffc <balloc>
80101156:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010115c:	eb be                	jmp    8010111c <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
8010115e:	8b 06                	mov    (%esi),%eax
80101160:	e8 97 fe ff ff       	call   80100ffc <balloc>
80101165:	89 c3                	mov    %eax,%ebx
80101167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010116a:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
8010116c:	83 ec 0c             	sub    $0xc,%esp
8010116f:	57                   	push   %edi
80101170:	e8 62 17 00 00       	call   801028d7 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 75 6d 10 80       	push   $0x80106d75
80101182:	e8 c1 f1 ff ff       	call   80100348 <panic>

80101187 <iget>:
{
80101187:	55                   	push   %ebp
80101188:	89 e5                	mov    %esp,%ebp
8010118a:	57                   	push   %edi
8010118b:	56                   	push   %esi
8010118c:	53                   	push   %ebx
8010118d:	83 ec 28             	sub    $0x28,%esp
80101190:	89 c7                	mov    %eax,%edi
80101192:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101195:	68 e0 09 11 80       	push   $0x801109e0
8010119a:	e8 96 31 00 00       	call   80104335 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010119f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011a7:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
801011ac:	eb 0a                	jmp    801011b8 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ae:	85 f6                	test   %esi,%esi
801011b0:	74 3b                	je     801011ed <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011b8:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
801011be:	73 35                	jae    801011f5 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011c0:	8b 43 08             	mov    0x8(%ebx),%eax
801011c3:	85 c0                	test   %eax,%eax
801011c5:	7e e7                	jle    801011ae <iget+0x27>
801011c7:	39 3b                	cmp    %edi,(%ebx)
801011c9:	75 e3                	jne    801011ae <iget+0x27>
801011cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011ce:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011d1:	75 db                	jne    801011ae <iget+0x27>
      ip->ref++;
801011d3:	83 c0 01             	add    $0x1,%eax
801011d6:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011d9:	83 ec 0c             	sub    $0xc,%esp
801011dc:	68 e0 09 11 80       	push   $0x801109e0
801011e1:	e8 b4 31 00 00       	call   8010439a <release>
      return ip;
801011e6:	83 c4 10             	add    $0x10,%esp
801011e9:	89 de                	mov    %ebx,%esi
801011eb:	eb 32                	jmp    8010121f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ed:	85 c0                	test   %eax,%eax
801011ef:	75 c1                	jne    801011b2 <iget+0x2b>
      empty = ip;
801011f1:	89 de                	mov    %ebx,%esi
801011f3:	eb bd                	jmp    801011b2 <iget+0x2b>
  if(empty == 0)
801011f5:	85 f6                	test   %esi,%esi
801011f7:	74 30                	je     80101229 <iget+0xa2>
  ip->dev = dev;
801011f9:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011fe:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101201:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101208:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010120f:	83 ec 0c             	sub    $0xc,%esp
80101212:	68 e0 09 11 80       	push   $0x801109e0
80101217:	e8 7e 31 00 00       	call   8010439a <release>
  return ip;
8010121c:	83 c4 10             	add    $0x10,%esp
}
8010121f:	89 f0                	mov    %esi,%eax
80101221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101224:	5b                   	pop    %ebx
80101225:	5e                   	pop    %esi
80101226:	5f                   	pop    %edi
80101227:	5d                   	pop    %ebp
80101228:	c3                   	ret    
    panic("iget: no inodes");
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	68 88 6d 10 80       	push   $0x80106d88
80101231:	e8 12 f1 ff ff       	call   80100348 <panic>

80101236 <readsb>:
{
80101236:	55                   	push   %ebp
80101237:	89 e5                	mov    %esp,%ebp
80101239:	53                   	push   %ebx
8010123a:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
8010123d:	6a 01                	push   $0x1
8010123f:	ff 75 08             	pushl  0x8(%ebp)
80101242:	e8 25 ef ff ff       	call   8010016c <bread>
80101247:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101249:	8d 40 5c             	lea    0x5c(%eax),%eax
8010124c:	83 c4 0c             	add    $0xc,%esp
8010124f:	6a 1c                	push   $0x1c
80101251:	50                   	push   %eax
80101252:	ff 75 0c             	pushl  0xc(%ebp)
80101255:	e8 02 32 00 00       	call   8010445c <memmove>
  brelse(bp);
8010125a:	89 1c 24             	mov    %ebx,(%esp)
8010125d:	e8 73 ef ff ff       	call   801001d5 <brelse>
}
80101262:	83 c4 10             	add    $0x10,%esp
80101265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101268:	c9                   	leave  
80101269:	c3                   	ret    

8010126a <bfree>:
{
8010126a:	55                   	push   %ebp
8010126b:	89 e5                	mov    %esp,%ebp
8010126d:	56                   	push   %esi
8010126e:	53                   	push   %ebx
8010126f:	89 c6                	mov    %eax,%esi
80101271:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
80101273:	83 ec 08             	sub    $0x8,%esp
80101276:	68 c0 09 11 80       	push   $0x801109c0
8010127b:	50                   	push   %eax
8010127c:	e8 b5 ff ff ff       	call   80101236 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101281:	89 d8                	mov    %ebx,%eax
80101283:	c1 e8 0c             	shr    $0xc,%eax
80101286:	03 05 d8 09 11 80    	add    0x801109d8,%eax
8010128c:	83 c4 08             	add    $0x8,%esp
8010128f:	50                   	push   %eax
80101290:	56                   	push   %esi
80101291:	e8 d6 ee ff ff       	call   8010016c <bread>
80101296:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101298:	89 d9                	mov    %ebx,%ecx
8010129a:	83 e1 07             	and    $0x7,%ecx
8010129d:	b8 01 00 00 00       	mov    $0x1,%eax
801012a2:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012a4:	83 c4 10             	add    $0x10,%esp
801012a7:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012ad:	c1 fb 03             	sar    $0x3,%ebx
801012b0:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012b5:	0f b6 ca             	movzbl %dl,%ecx
801012b8:	85 c1                	test   %eax,%ecx
801012ba:	74 23                	je     801012df <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012bc:	f7 d0                	not    %eax
801012be:	21 d0                	and    %edx,%eax
801012c0:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012c4:	83 ec 0c             	sub    $0xc,%esp
801012c7:	56                   	push   %esi
801012c8:	e8 0a 16 00 00       	call   801028d7 <log_write>
  brelse(bp);
801012cd:	89 34 24             	mov    %esi,(%esp)
801012d0:	e8 00 ef ff ff       	call   801001d5 <brelse>
}
801012d5:	83 c4 10             	add    $0x10,%esp
801012d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012db:	5b                   	pop    %ebx
801012dc:	5e                   	pop    %esi
801012dd:	5d                   	pop    %ebp
801012de:	c3                   	ret    
    panic("freeing free block");
801012df:	83 ec 0c             	sub    $0xc,%esp
801012e2:	68 98 6d 10 80       	push   $0x80106d98
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 ab 6d 10 80       	push   $0x80106dab
801012f8:	68 e0 09 11 80       	push   $0x801109e0
801012fd:	e8 f7 2e 00 00       	call   801041f9 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 b2 6d 10 80       	push   $0x80106db2
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101321:	50                   	push   %eax
80101322:	e8 c7 2d 00 00       	call   801040ee <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101327:	83 c3 01             	add    $0x1,%ebx
8010132a:	83 c4 10             	add    $0x10,%esp
8010132d:	83 fb 31             	cmp    $0x31,%ebx
80101330:	7e da                	jle    8010130c <iinit+0x20>
  readsb(dev, &sb);
80101332:	83 ec 08             	sub    $0x8,%esp
80101335:	68 c0 09 11 80       	push   $0x801109c0
8010133a:	ff 75 08             	pushl  0x8(%ebp)
8010133d:	e8 f4 fe ff ff       	call   80101236 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101342:	ff 35 d8 09 11 80    	pushl  0x801109d8
80101348:	ff 35 d4 09 11 80    	pushl  0x801109d4
8010134e:	ff 35 d0 09 11 80    	pushl  0x801109d0
80101354:	ff 35 cc 09 11 80    	pushl  0x801109cc
8010135a:	ff 35 c8 09 11 80    	pushl  0x801109c8
80101360:	ff 35 c4 09 11 80    	pushl  0x801109c4
80101366:	ff 35 c0 09 11 80    	pushl  0x801109c0
8010136c:	68 18 6e 10 80       	push   $0x80106e18
80101371:	e8 95 f2 ff ff       	call   8010060b <cprintf>
}
80101376:	83 c4 30             	add    $0x30,%esp
80101379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <ialloc>:
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	57                   	push   %edi
80101382:	56                   	push   %esi
80101383:	53                   	push   %ebx
80101384:	83 ec 1c             	sub    $0x1c,%esp
80101387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010138d:	bb 01 00 00 00       	mov    $0x1,%ebx
80101392:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101395:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
8010139b:	76 3f                	jbe    801013dc <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010139d:	89 d8                	mov    %ebx,%eax
8010139f:	c1 e8 03             	shr    $0x3,%eax
801013a2:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801013a8:	83 ec 08             	sub    $0x8,%esp
801013ab:	50                   	push   %eax
801013ac:	ff 75 08             	pushl  0x8(%ebp)
801013af:	e8 b8 ed ff ff       	call   8010016c <bread>
801013b4:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013b6:	89 d8                	mov    %ebx,%eax
801013b8:	83 e0 07             	and    $0x7,%eax
801013bb:	c1 e0 06             	shl    $0x6,%eax
801013be:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013c2:	83 c4 10             	add    $0x10,%esp
801013c5:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013c9:	74 1e                	je     801013e9 <ialloc+0x6b>
    brelse(bp);
801013cb:	83 ec 0c             	sub    $0xc,%esp
801013ce:	56                   	push   %esi
801013cf:	e8 01 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013d4:	83 c3 01             	add    $0x1,%ebx
801013d7:	83 c4 10             	add    $0x10,%esp
801013da:	eb b6                	jmp    80101392 <ialloc+0x14>
  panic("ialloc: no inodes");
801013dc:	83 ec 0c             	sub    $0xc,%esp
801013df:	68 b8 6d 10 80       	push   $0x80106db8
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 eb 2f 00 00       	call   801043e1 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 d2 14 00 00       	call   801028d7 <log_write>
      brelse(bp);
80101405:	89 34 24             	mov    %esi,(%esp)
80101408:	e8 c8 ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
8010140d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	e8 6f fd ff ff       	call   80101187 <iget>
}
80101418:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010141b:	5b                   	pop    %ebx
8010141c:	5e                   	pop    %esi
8010141d:	5f                   	pop    %edi
8010141e:	5d                   	pop    %ebp
8010141f:	c3                   	ret    

80101420 <iupdate>:
{
80101420:	55                   	push   %ebp
80101421:	89 e5                	mov    %esp,%ebp
80101423:	56                   	push   %esi
80101424:	53                   	push   %ebx
80101425:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101428:	8b 43 04             	mov    0x4(%ebx),%eax
8010142b:	c1 e8 03             	shr    $0x3,%eax
8010142e:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101434:	83 ec 08             	sub    $0x8,%esp
80101437:	50                   	push   %eax
80101438:	ff 33                	pushl  (%ebx)
8010143a:	e8 2d ed ff ff       	call   8010016c <bread>
8010143f:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101441:	8b 43 04             	mov    0x4(%ebx),%eax
80101444:	83 e0 07             	and    $0x7,%eax
80101447:	c1 e0 06             	shl    $0x6,%eax
8010144a:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010144e:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101452:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101455:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101459:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010145d:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101461:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101465:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101469:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010146d:	8b 53 58             	mov    0x58(%ebx),%edx
80101470:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101473:	83 c3 5c             	add    $0x5c,%ebx
80101476:	83 c0 0c             	add    $0xc,%eax
80101479:	83 c4 0c             	add    $0xc,%esp
8010147c:	6a 34                	push   $0x34
8010147e:	53                   	push   %ebx
8010147f:	50                   	push   %eax
80101480:	e8 d7 2f 00 00       	call   8010445c <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 4a 14 00 00       	call   801028d7 <log_write>
  brelse(bp);
8010148d:	89 34 24             	mov    %esi,(%esp)
80101490:	e8 40 ed ff ff       	call   801001d5 <brelse>
}
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010149b:	5b                   	pop    %ebx
8010149c:	5e                   	pop    %esi
8010149d:	5d                   	pop    %ebp
8010149e:	c3                   	ret    

8010149f <itrunc>:
{
8010149f:	55                   	push   %ebp
801014a0:	89 e5                	mov    %esp,%ebp
801014a2:	57                   	push   %edi
801014a3:	56                   	push   %esi
801014a4:	53                   	push   %ebx
801014a5:	83 ec 1c             	sub    $0x1c,%esp
801014a8:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
801014af:	eb 03                	jmp    801014b4 <itrunc+0x15>
801014b1:	83 c3 01             	add    $0x1,%ebx
801014b4:	83 fb 0b             	cmp    $0xb,%ebx
801014b7:	7f 19                	jg     801014d2 <itrunc+0x33>
    if(ip->addrs[i]){
801014b9:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014bd:	85 d2                	test   %edx,%edx
801014bf:	74 f0                	je     801014b1 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014c1:	8b 06                	mov    (%esi),%eax
801014c3:	e8 a2 fd ff ff       	call   8010126a <bfree>
      ip->addrs[i] = 0;
801014c8:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014cf:	00 
801014d0:	eb df                	jmp    801014b1 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014d2:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014d8:	85 c0                	test   %eax,%eax
801014da:	75 1b                	jne    801014f7 <itrunc+0x58>
  ip->size = 0;
801014dc:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014e3:	83 ec 0c             	sub    $0xc,%esp
801014e6:	56                   	push   %esi
801014e7:	e8 34 ff ff ff       	call   80101420 <iupdate>
}
801014ec:	83 c4 10             	add    $0x10,%esp
801014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014f2:	5b                   	pop    %ebx
801014f3:	5e                   	pop    %esi
801014f4:	5f                   	pop    %edi
801014f5:	5d                   	pop    %ebp
801014f6:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014f7:	83 ec 08             	sub    $0x8,%esp
801014fa:	50                   	push   %eax
801014fb:	ff 36                	pushl  (%esi)
801014fd:	e8 6a ec ff ff       	call   8010016c <bread>
80101502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101505:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101508:	83 c4 10             	add    $0x10,%esp
8010150b:	bb 00 00 00 00       	mov    $0x0,%ebx
80101510:	eb 03                	jmp    80101515 <itrunc+0x76>
80101512:	83 c3 01             	add    $0x1,%ebx
80101515:	83 fb 7f             	cmp    $0x7f,%ebx
80101518:	77 10                	ja     8010152a <itrunc+0x8b>
      if(a[j])
8010151a:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010151d:	85 d2                	test   %edx,%edx
8010151f:	74 f1                	je     80101512 <itrunc+0x73>
        bfree(ip->dev, a[j]);
80101521:	8b 06                	mov    (%esi),%eax
80101523:	e8 42 fd ff ff       	call   8010126a <bfree>
80101528:	eb e8                	jmp    80101512 <itrunc+0x73>
    brelse(bp);
8010152a:	83 ec 0c             	sub    $0xc,%esp
8010152d:	ff 75 e4             	pushl  -0x1c(%ebp)
80101530:	e8 a0 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101535:	8b 06                	mov    (%esi),%eax
80101537:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010153d:	e8 28 fd ff ff       	call   8010126a <bfree>
    ip->addrs[NDIRECT] = 0;
80101542:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101549:	00 00 00 
8010154c:	83 c4 10             	add    $0x10,%esp
8010154f:	eb 8b                	jmp    801014dc <itrunc+0x3d>

80101551 <idup>:
{
80101551:	55                   	push   %ebp
80101552:	89 e5                	mov    %esp,%ebp
80101554:	53                   	push   %ebx
80101555:	83 ec 10             	sub    $0x10,%esp
80101558:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010155b:	68 e0 09 11 80       	push   $0x801109e0
80101560:	e8 d0 2d 00 00       	call   80104335 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101575:	e8 20 2e 00 00       	call   8010439a <release>
}
8010157a:	89 d8                	mov    %ebx,%eax
8010157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010157f:	c9                   	leave  
80101580:	c3                   	ret    

80101581 <ilock>:
{
80101581:	55                   	push   %ebp
80101582:	89 e5                	mov    %esp,%ebp
80101584:	56                   	push   %esi
80101585:	53                   	push   %ebx
80101586:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101589:	85 db                	test   %ebx,%ebx
8010158b:	74 22                	je     801015af <ilock+0x2e>
8010158d:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101591:	7e 1c                	jle    801015af <ilock+0x2e>
  acquiresleep(&ip->lock);
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	8d 43 0c             	lea    0xc(%ebx),%eax
80101599:	50                   	push   %eax
8010159a:	e8 82 2b 00 00       	call   80104121 <acquiresleep>
  if(ip->valid == 0){
8010159f:	83 c4 10             	add    $0x10,%esp
801015a2:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015a6:	74 14                	je     801015bc <ilock+0x3b>
}
801015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015ab:	5b                   	pop    %ebx
801015ac:	5e                   	pop    %esi
801015ad:	5d                   	pop    %ebp
801015ae:	c3                   	ret    
    panic("ilock");
801015af:	83 ec 0c             	sub    $0xc,%esp
801015b2:	68 ca 6d 10 80       	push   $0x80106dca
801015b7:	e8 8c ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015bc:	8b 43 04             	mov    0x4(%ebx),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801015c8:	83 ec 08             	sub    $0x8,%esp
801015cb:	50                   	push   %eax
801015cc:	ff 33                	pushl  (%ebx)
801015ce:	e8 99 eb ff ff       	call   8010016c <bread>
801015d3:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015d5:	8b 43 04             	mov    0x4(%ebx),%eax
801015d8:	83 e0 07             	and    $0x7,%eax
801015db:	c1 e0 06             	shl    $0x6,%eax
801015de:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015e2:	0f b7 10             	movzwl (%eax),%edx
801015e5:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015e9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015ed:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015f1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015f5:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015f9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015fd:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101601:	8b 50 08             	mov    0x8(%eax),%edx
80101604:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101607:	83 c0 0c             	add    $0xc,%eax
8010160a:	8d 53 5c             	lea    0x5c(%ebx),%edx
8010160d:	83 c4 0c             	add    $0xc,%esp
80101610:	6a 34                	push   $0x34
80101612:	50                   	push   %eax
80101613:	52                   	push   %edx
80101614:	e8 43 2e 00 00       	call   8010445c <memmove>
    brelse(bp);
80101619:	89 34 24             	mov    %esi,(%esp)
8010161c:	e8 b4 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
80101621:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101628:	83 c4 10             	add    $0x10,%esp
8010162b:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101630:	0f 85 72 ff ff ff    	jne    801015a8 <ilock+0x27>
      panic("ilock: no type");
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	68 d0 6d 10 80       	push   $0x80106dd0
8010163e:	e8 05 ed ff ff       	call   80100348 <panic>

80101643 <iunlock>:
{
80101643:	55                   	push   %ebp
80101644:	89 e5                	mov    %esp,%ebp
80101646:	56                   	push   %esi
80101647:	53                   	push   %ebx
80101648:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010164b:	85 db                	test   %ebx,%ebx
8010164d:	74 2c                	je     8010167b <iunlock+0x38>
8010164f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101652:	83 ec 0c             	sub    $0xc,%esp
80101655:	56                   	push   %esi
80101656:	e8 50 2b 00 00       	call   801041ab <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 ff 2a 00 00       	call   80104170 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 df 6d 10 80       	push   $0x80106ddf
80101683:	e8 c0 ec ff ff       	call   80100348 <panic>

80101688 <iput>:
{
80101688:	55                   	push   %ebp
80101689:	89 e5                	mov    %esp,%ebp
8010168b:	57                   	push   %edi
8010168c:	56                   	push   %esi
8010168d:	53                   	push   %ebx
8010168e:	83 ec 18             	sub    $0x18,%esp
80101691:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101694:	8d 73 0c             	lea    0xc(%ebx),%esi
80101697:	56                   	push   %esi
80101698:	e8 84 2a 00 00       	call   80104121 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 ba 2a 00 00       	call   80104170 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016bd:	e8 73 2c 00 00       	call   80104335 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d2:	e8 c3 2c 00 00       	call   8010439a <release>
}
801016d7:	83 c4 10             	add    $0x10,%esp
801016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016dd:	5b                   	pop    %ebx
801016de:	5e                   	pop    %esi
801016df:	5f                   	pop    %edi
801016e0:	5d                   	pop    %ebp
801016e1:	c3                   	ret    
    acquire(&icache.lock);
801016e2:	83 ec 0c             	sub    $0xc,%esp
801016e5:	68 e0 09 11 80       	push   $0x801109e0
801016ea:	e8 46 2c 00 00       	call   80104335 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016f9:	e8 9c 2c 00 00       	call   8010439a <release>
    if(r == 1){
801016fe:	83 c4 10             	add    $0x10,%esp
80101701:	83 ff 01             	cmp    $0x1,%edi
80101704:	75 a7                	jne    801016ad <iput+0x25>
      itrunc(ip);
80101706:	89 d8                	mov    %ebx,%eax
80101708:	e8 92 fd ff ff       	call   8010149f <itrunc>
      ip->type = 0;
8010170d:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101713:	83 ec 0c             	sub    $0xc,%esp
80101716:	53                   	push   %ebx
80101717:	e8 04 fd ff ff       	call   80101420 <iupdate>
      ip->valid = 0;
8010171c:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101723:	83 c4 10             	add    $0x10,%esp
80101726:	eb 85                	jmp    801016ad <iput+0x25>

80101728 <iunlockput>:
{
80101728:	55                   	push   %ebp
80101729:	89 e5                	mov    %esp,%ebp
8010172b:	53                   	push   %ebx
8010172c:	83 ec 10             	sub    $0x10,%esp
8010172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101732:	53                   	push   %ebx
80101733:	e8 0b ff ff ff       	call   80101643 <iunlock>
  iput(ip);
80101738:	89 1c 24             	mov    %ebx,(%esp)
8010173b:	e8 48 ff ff ff       	call   80101688 <iput>
}
80101740:	83 c4 10             	add    $0x10,%esp
80101743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101746:	c9                   	leave  
80101747:	c3                   	ret    

80101748 <stati>:
{
80101748:	55                   	push   %ebp
80101749:	89 e5                	mov    %esp,%ebp
8010174b:	8b 55 08             	mov    0x8(%ebp),%edx
8010174e:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101751:	8b 0a                	mov    (%edx),%ecx
80101753:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101756:	8b 4a 04             	mov    0x4(%edx),%ecx
80101759:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010175c:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101760:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101763:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101767:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010176b:	8b 52 58             	mov    0x58(%edx),%edx
8010176e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101771:	5d                   	pop    %ebp
80101772:	c3                   	ret    

80101773 <readi>:
{
80101773:	55                   	push   %ebp
80101774:	89 e5                	mov    %esp,%ebp
80101776:	57                   	push   %edi
80101777:	56                   	push   %esi
80101778:	53                   	push   %ebx
80101779:	83 ec 1c             	sub    $0x1c,%esp
8010177c:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010177f:	8b 45 08             	mov    0x8(%ebp),%eax
80101782:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101787:	74 2c                	je     801017b5 <readi+0x42>
  if(off > ip->size || off + n < off)
80101789:	8b 45 08             	mov    0x8(%ebp),%eax
8010178c:	8b 40 58             	mov    0x58(%eax),%eax
8010178f:	39 f8                	cmp    %edi,%eax
80101791:	0f 82 cb 00 00 00    	jb     80101862 <readi+0xef>
80101797:	89 fa                	mov    %edi,%edx
80101799:	03 55 14             	add    0x14(%ebp),%edx
8010179c:	0f 82 c7 00 00 00    	jb     80101869 <readi+0xf6>
  if(off + n > ip->size)
801017a2:	39 d0                	cmp    %edx,%eax
801017a4:	73 05                	jae    801017ab <readi+0x38>
    n = ip->size - off;
801017a6:	29 f8                	sub    %edi,%eax
801017a8:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017ab:	be 00 00 00 00       	mov    $0x0,%esi
801017b0:	e9 8f 00 00 00       	jmp    80101844 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017b5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017b9:	66 83 f8 09          	cmp    $0x9,%ax
801017bd:	0f 87 91 00 00 00    	ja     80101854 <readi+0xe1>
801017c3:	98                   	cwtl   
801017c4:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
801017cb:	85 c0                	test   %eax,%eax
801017cd:	0f 84 88 00 00 00    	je     8010185b <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017d3:	83 ec 04             	sub    $0x4,%esp
801017d6:	ff 75 14             	pushl  0x14(%ebp)
801017d9:	ff 75 0c             	pushl  0xc(%ebp)
801017dc:	ff 75 08             	pushl  0x8(%ebp)
801017df:	ff d0                	call   *%eax
801017e1:	83 c4 10             	add    $0x10,%esp
801017e4:	eb 66                	jmp    8010184c <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017e6:	89 fa                	mov    %edi,%edx
801017e8:	c1 ea 09             	shr    $0x9,%edx
801017eb:	8b 45 08             	mov    0x8(%ebp),%eax
801017ee:	e8 ee f8 ff ff       	call   801010e1 <bmap>
801017f3:	83 ec 08             	sub    $0x8,%esp
801017f6:	50                   	push   %eax
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	ff 30                	pushl  (%eax)
801017fc:	e8 6b e9 ff ff       	call   8010016c <bread>
80101801:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101803:	89 f8                	mov    %edi,%eax
80101805:	25 ff 01 00 00       	and    $0x1ff,%eax
8010180a:	bb 00 02 00 00       	mov    $0x200,%ebx
8010180f:	29 c3                	sub    %eax,%ebx
80101811:	8b 55 14             	mov    0x14(%ebp),%edx
80101814:	29 f2                	sub    %esi,%edx
80101816:	83 c4 0c             	add    $0xc,%esp
80101819:	39 d3                	cmp    %edx,%ebx
8010181b:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010181e:	53                   	push   %ebx
8010181f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101822:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101826:	50                   	push   %eax
80101827:	ff 75 0c             	pushl  0xc(%ebp)
8010182a:	e8 2d 2c 00 00       	call   8010445c <memmove>
    brelse(bp);
8010182f:	83 c4 04             	add    $0x4,%esp
80101832:	ff 75 e4             	pushl  -0x1c(%ebp)
80101835:	e8 9b e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010183a:	01 de                	add    %ebx,%esi
8010183c:	01 df                	add    %ebx,%edi
8010183e:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101841:	83 c4 10             	add    $0x10,%esp
80101844:	39 75 14             	cmp    %esi,0x14(%ebp)
80101847:	77 9d                	ja     801017e6 <readi+0x73>
  return n;
80101849:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010184c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010184f:	5b                   	pop    %ebx
80101850:	5e                   	pop    %esi
80101851:	5f                   	pop    %edi
80101852:	5d                   	pop    %ebp
80101853:	c3                   	ret    
      return -1;
80101854:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101859:	eb f1                	jmp    8010184c <readi+0xd9>
8010185b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101860:	eb ea                	jmp    8010184c <readi+0xd9>
    return -1;
80101862:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101867:	eb e3                	jmp    8010184c <readi+0xd9>
80101869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186e:	eb dc                	jmp    8010184c <readi+0xd9>

80101870 <writei>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	57                   	push   %edi
80101874:	56                   	push   %esi
80101875:	53                   	push   %ebx
80101876:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101879:	8b 45 08             	mov    0x8(%ebp),%eax
8010187c:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101881:	74 2f                	je     801018b2 <writei+0x42>
  if(off > ip->size || off + n < off)
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101889:	39 48 58             	cmp    %ecx,0x58(%eax)
8010188c:	0f 82 f4 00 00 00    	jb     80101986 <writei+0x116>
80101892:	89 c8                	mov    %ecx,%eax
80101894:	03 45 14             	add    0x14(%ebp),%eax
80101897:	0f 82 f0 00 00 00    	jb     8010198d <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
8010189d:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018a2:	0f 87 ec 00 00 00    	ja     80101994 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018a8:	be 00 00 00 00       	mov    $0x0,%esi
801018ad:	e9 94 00 00 00       	jmp    80101946 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018b2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018b6:	66 83 f8 09          	cmp    $0x9,%ax
801018ba:	0f 87 b8 00 00 00    	ja     80101978 <writei+0x108>
801018c0:	98                   	cwtl   
801018c1:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
801018c8:	85 c0                	test   %eax,%eax
801018ca:	0f 84 af 00 00 00    	je     8010197f <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018d0:	83 ec 04             	sub    $0x4,%esp
801018d3:	ff 75 14             	pushl  0x14(%ebp)
801018d6:	ff 75 0c             	pushl  0xc(%ebp)
801018d9:	ff 75 08             	pushl  0x8(%ebp)
801018dc:	ff d0                	call   *%eax
801018de:	83 c4 10             	add    $0x10,%esp
801018e1:	eb 7c                	jmp    8010195f <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018e3:	8b 55 10             	mov    0x10(%ebp),%edx
801018e6:	c1 ea 09             	shr    $0x9,%edx
801018e9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ec:	e8 f0 f7 ff ff       	call   801010e1 <bmap>
801018f1:	83 ec 08             	sub    $0x8,%esp
801018f4:	50                   	push   %eax
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	ff 30                	pushl  (%eax)
801018fa:	e8 6d e8 ff ff       	call   8010016c <bread>
801018ff:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101901:	8b 45 10             	mov    0x10(%ebp),%eax
80101904:	25 ff 01 00 00       	and    $0x1ff,%eax
80101909:	bb 00 02 00 00       	mov    $0x200,%ebx
8010190e:	29 c3                	sub    %eax,%ebx
80101910:	8b 55 14             	mov    0x14(%ebp),%edx
80101913:	29 f2                	sub    %esi,%edx
80101915:	83 c4 0c             	add    $0xc,%esp
80101918:	39 d3                	cmp    %edx,%ebx
8010191a:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010191d:	53                   	push   %ebx
8010191e:	ff 75 0c             	pushl  0xc(%ebp)
80101921:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101925:	50                   	push   %eax
80101926:	e8 31 2b 00 00       	call   8010445c <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 a4 0f 00 00       	call   801028d7 <log_write>
    brelse(bp);
80101933:	89 3c 24             	mov    %edi,(%esp)
80101936:	e8 9a e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010193b:	01 de                	add    %ebx,%esi
8010193d:	01 5d 10             	add    %ebx,0x10(%ebp)
80101940:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101943:	83 c4 10             	add    $0x10,%esp
80101946:	3b 75 14             	cmp    0x14(%ebp),%esi
80101949:	72 98                	jb     801018e3 <writei+0x73>
  if(n > 0 && off > ip->size){
8010194b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010194f:	74 0b                	je     8010195c <writei+0xec>
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101957:	39 48 58             	cmp    %ecx,0x58(%eax)
8010195a:	72 0b                	jb     80101967 <writei+0xf7>
  return n;
8010195c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010195f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101962:	5b                   	pop    %ebx
80101963:	5e                   	pop    %esi
80101964:	5f                   	pop    %edi
80101965:	5d                   	pop    %ebp
80101966:	c3                   	ret    
    ip->size = off;
80101967:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
8010196a:	83 ec 0c             	sub    $0xc,%esp
8010196d:	50                   	push   %eax
8010196e:	e8 ad fa ff ff       	call   80101420 <iupdate>
80101973:	83 c4 10             	add    $0x10,%esp
80101976:	eb e4                	jmp    8010195c <writei+0xec>
      return -1;
80101978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010197d:	eb e0                	jmp    8010195f <writei+0xef>
8010197f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101984:	eb d9                	jmp    8010195f <writei+0xef>
    return -1;
80101986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010198b:	eb d2                	jmp    8010195f <writei+0xef>
8010198d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101992:	eb cb                	jmp    8010195f <writei+0xef>
    return -1;
80101994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101999:	eb c4                	jmp    8010195f <writei+0xef>

8010199b <namecmp>:
{
8010199b:	55                   	push   %ebp
8010199c:	89 e5                	mov    %esp,%ebp
8010199e:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019a1:	6a 0e                	push   $0xe
801019a3:	ff 75 0c             	pushl  0xc(%ebp)
801019a6:	ff 75 08             	pushl  0x8(%ebp)
801019a9:	e8 15 2b 00 00       	call   801044c3 <strncmp>
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <dirlookup>:
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	57                   	push   %edi
801019b4:	56                   	push   %esi
801019b5:	53                   	push   %ebx
801019b6:	83 ec 1c             	sub    $0x1c,%esp
801019b9:	8b 75 08             	mov    0x8(%ebp),%esi
801019bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019bf:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019c4:	75 07                	jne    801019cd <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019c6:	bb 00 00 00 00       	mov    $0x0,%ebx
801019cb:	eb 1d                	jmp    801019ea <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019cd:	83 ec 0c             	sub    $0xc,%esp
801019d0:	68 e7 6d 10 80       	push   $0x80106de7
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 f9 6d 10 80       	push   $0x80106df9
801019e2:	e8 61 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019e7:	83 c3 10             	add    $0x10,%ebx
801019ea:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019ed:	76 48                	jbe    80101a37 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019ef:	6a 10                	push   $0x10
801019f1:	53                   	push   %ebx
801019f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019f5:	50                   	push   %eax
801019f6:	56                   	push   %esi
801019f7:	e8 77 fd ff ff       	call   80101773 <readi>
801019fc:	83 c4 10             	add    $0x10,%esp
801019ff:	83 f8 10             	cmp    $0x10,%eax
80101a02:	75 d6                	jne    801019da <dirlookup+0x2a>
    if(de.inum == 0)
80101a04:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a09:	74 dc                	je     801019e7 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a0b:	83 ec 08             	sub    $0x8,%esp
80101a0e:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a11:	50                   	push   %eax
80101a12:	57                   	push   %edi
80101a13:	e8 83 ff ff ff       	call   8010199b <namecmp>
80101a18:	83 c4 10             	add    $0x10,%esp
80101a1b:	85 c0                	test   %eax,%eax
80101a1d:	75 c8                	jne    801019e7 <dirlookup+0x37>
      if(poff)
80101a1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a23:	74 05                	je     80101a2a <dirlookup+0x7a>
        *poff = off;
80101a25:	8b 45 10             	mov    0x10(%ebp),%eax
80101a28:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a2a:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a2e:	8b 06                	mov    (%esi),%eax
80101a30:	e8 52 f7 ff ff       	call   80101187 <iget>
80101a35:	eb 05                	jmp    80101a3c <dirlookup+0x8c>
  return 0;
80101a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a3f:	5b                   	pop    %ebx
80101a40:	5e                   	pop    %esi
80101a41:	5f                   	pop    %edi
80101a42:	5d                   	pop    %ebp
80101a43:	c3                   	ret    

80101a44 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a44:	55                   	push   %ebp
80101a45:	89 e5                	mov    %esp,%ebp
80101a47:	57                   	push   %edi
80101a48:	56                   	push   %esi
80101a49:	53                   	push   %ebx
80101a4a:	83 ec 1c             	sub    $0x1c,%esp
80101a4d:	89 c6                	mov    %eax,%esi
80101a4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a55:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a58:	74 17                	je     80101a71 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a5a:	e8 fa 18 00 00       	call   80103359 <myproc>
80101a5f:	83 ec 0c             	sub    $0xc,%esp
80101a62:	ff 70 68             	pushl  0x68(%eax)
80101a65:	e8 e7 fa ff ff       	call   80101551 <idup>
80101a6a:	89 c3                	mov    %eax,%ebx
80101a6c:	83 c4 10             	add    $0x10,%esp
80101a6f:	eb 53                	jmp    80101ac4 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a71:	ba 01 00 00 00       	mov    $0x1,%edx
80101a76:	b8 01 00 00 00       	mov    $0x1,%eax
80101a7b:	e8 07 f7 ff ff       	call   80101187 <iget>
80101a80:	89 c3                	mov    %eax,%ebx
80101a82:	eb 40                	jmp    80101ac4 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	53                   	push   %ebx
80101a88:	e8 9b fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101a8d:	83 c4 10             	add    $0x10,%esp
80101a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a95:	89 d8                	mov    %ebx,%eax
80101a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a9a:	5b                   	pop    %ebx
80101a9b:	5e                   	pop    %esi
80101a9c:	5f                   	pop    %edi
80101a9d:	5d                   	pop    %ebp
80101a9e:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a9f:	83 ec 04             	sub    $0x4,%esp
80101aa2:	6a 00                	push   $0x0
80101aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
80101aa7:	53                   	push   %ebx
80101aa8:	e8 03 ff ff ff       	call   801019b0 <dirlookup>
80101aad:	89 c7                	mov    %eax,%edi
80101aaf:	83 c4 10             	add    $0x10,%esp
80101ab2:	85 c0                	test   %eax,%eax
80101ab4:	74 4a                	je     80101b00 <namex+0xbc>
    iunlockput(ip);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	53                   	push   %ebx
80101aba:	e8 69 fc ff ff       	call   80101728 <iunlockput>
    ip = next;
80101abf:	83 c4 10             	add    $0x10,%esp
80101ac2:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ac4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ac7:	89 f0                	mov    %esi,%eax
80101ac9:	e8 77 f4 ff ff       	call   80100f45 <skipelem>
80101ace:	89 c6                	mov    %eax,%esi
80101ad0:	85 c0                	test   %eax,%eax
80101ad2:	74 3c                	je     80101b10 <namex+0xcc>
    ilock(ip);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	53                   	push   %ebx
80101ad8:	e8 a4 fa ff ff       	call   80101581 <ilock>
    if(ip->type != T_DIR){
80101add:	83 c4 10             	add    $0x10,%esp
80101ae0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ae5:	75 9d                	jne    80101a84 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ae7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aeb:	74 b2                	je     80101a9f <namex+0x5b>
80101aed:	80 3e 00             	cmpb   $0x0,(%esi)
80101af0:	75 ad                	jne    80101a9f <namex+0x5b>
      iunlock(ip);
80101af2:	83 ec 0c             	sub    $0xc,%esp
80101af5:	53                   	push   %ebx
80101af6:	e8 48 fb ff ff       	call   80101643 <iunlock>
      return ip;
80101afb:	83 c4 10             	add    $0x10,%esp
80101afe:	eb 95                	jmp    80101a95 <namex+0x51>
      iunlockput(ip);
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	53                   	push   %ebx
80101b04:	e8 1f fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101b09:	83 c4 10             	add    $0x10,%esp
80101b0c:	89 fb                	mov    %edi,%ebx
80101b0e:	eb 85                	jmp    80101a95 <namex+0x51>
  if(nameiparent){
80101b10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b14:	0f 84 7b ff ff ff    	je     80101a95 <namex+0x51>
    iput(ip);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	53                   	push   %ebx
80101b1e:	e8 65 fb ff ff       	call   80101688 <iput>
    return 0;
80101b23:	83 c4 10             	add    $0x10,%esp
80101b26:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b2b:	e9 65 ff ff ff       	jmp    80101a95 <namex+0x51>

80101b30 <dirlink>:
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	57                   	push   %edi
80101b34:	56                   	push   %esi
80101b35:	53                   	push   %ebx
80101b36:	83 ec 20             	sub    $0x20,%esp
80101b39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b3f:	6a 00                	push   $0x0
80101b41:	57                   	push   %edi
80101b42:	53                   	push   %ebx
80101b43:	e8 68 fe ff ff       	call   801019b0 <dirlookup>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	75 2d                	jne    80101b7c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b4f:	b8 00 00 00 00       	mov    $0x0,%eax
80101b54:	89 c6                	mov    %eax,%esi
80101b56:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b59:	76 41                	jbe    80101b9c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b5b:	6a 10                	push   $0x10
80101b5d:	50                   	push   %eax
80101b5e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b61:	50                   	push   %eax
80101b62:	53                   	push   %ebx
80101b63:	e8 0b fc ff ff       	call   80101773 <readi>
80101b68:	83 c4 10             	add    $0x10,%esp
80101b6b:	83 f8 10             	cmp    $0x10,%eax
80101b6e:	75 1f                	jne    80101b8f <dirlink+0x5f>
    if(de.inum == 0)
80101b70:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b75:	74 25                	je     80101b9c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b77:	8d 46 10             	lea    0x10(%esi),%eax
80101b7a:	eb d8                	jmp    80101b54 <dirlink+0x24>
    iput(ip);
80101b7c:	83 ec 0c             	sub    $0xc,%esp
80101b7f:	50                   	push   %eax
80101b80:	e8 03 fb ff ff       	call   80101688 <iput>
    return -1;
80101b85:	83 c4 10             	add    $0x10,%esp
80101b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b8d:	eb 3d                	jmp    80101bcc <dirlink+0x9c>
      panic("dirlink read");
80101b8f:	83 ec 0c             	sub    $0xc,%esp
80101b92:	68 08 6e 10 80       	push   $0x80106e08
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 52 29 00 00       	call   80104500 <strncpy>
  de.inum = inum;
80101bae:	8b 45 10             	mov    0x10(%ebp),%eax
80101bb1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bb5:	6a 10                	push   $0x10
80101bb7:	56                   	push   %esi
80101bb8:	57                   	push   %edi
80101bb9:	53                   	push   %ebx
80101bba:	e8 b1 fc ff ff       	call   80101870 <writei>
80101bbf:	83 c4 20             	add    $0x20,%esp
80101bc2:	83 f8 10             	cmp    $0x10,%eax
80101bc5:	75 0d                	jne    80101bd4 <dirlink+0xa4>
  return 0;
80101bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bcf:	5b                   	pop    %ebx
80101bd0:	5e                   	pop    %esi
80101bd1:	5f                   	pop    %edi
80101bd2:	5d                   	pop    %ebp
80101bd3:	c3                   	ret    
    panic("dirlink");
80101bd4:	83 ec 0c             	sub    $0xc,%esp
80101bd7:	68 40 74 10 80       	push   $0x80107440
80101bdc:	e8 67 e7 ff ff       	call   80100348 <panic>

80101be1 <namei>:

struct inode*
namei(char *path)
{
80101be1:	55                   	push   %ebp
80101be2:	89 e5                	mov    %esp,%ebp
80101be4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101be7:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bea:	ba 00 00 00 00       	mov    $0x0,%edx
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	e8 4d fe ff ff       	call   80101a44 <namex>
}
80101bf7:	c9                   	leave  
80101bf8:	c3                   	ret    

80101bf9 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101bf9:	55                   	push   %ebp
80101bfa:	89 e5                	mov    %esp,%ebp
80101bfc:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c02:	ba 01 00 00 00       	mov    $0x1,%edx
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	e8 35 fe ff ff       	call   80101a44 <namex>
}
80101c0f:	c9                   	leave  
80101c10:	c3                   	ret    

80101c11 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c11:	55                   	push   %ebp
80101c12:	89 e5                	mov    %esp,%ebp
80101c14:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c16:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c1b:	ec                   	in     (%dx),%al
80101c1c:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c1e:	83 e0 c0             	and    $0xffffffc0,%eax
80101c21:	3c 40                	cmp    $0x40,%al
80101c23:	75 f1                	jne    80101c16 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c25:	85 c9                	test   %ecx,%ecx
80101c27:	74 0c                	je     80101c35 <idewait+0x24>
80101c29:	f6 c2 21             	test   $0x21,%dl
80101c2c:	75 0e                	jne    80101c3c <idewait+0x2b>
    return -1;
  return 0;
80101c2e:	b8 00 00 00 00       	mov    $0x0,%eax
80101c33:	eb 05                	jmp    80101c3a <idewait+0x29>
80101c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c3a:	5d                   	pop    %ebp
80101c3b:	c3                   	ret    
    return -1;
80101c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c41:	eb f7                	jmp    80101c3a <idewait+0x29>

80101c43 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c43:	55                   	push   %ebp
80101c44:	89 e5                	mov    %esp,%ebp
80101c46:	56                   	push   %esi
80101c47:	53                   	push   %ebx
  if(b == 0)
80101c48:	85 c0                	test   %eax,%eax
80101c4a:	74 7d                	je     80101cc9 <idestart+0x86>
80101c4c:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c4e:	8b 58 08             	mov    0x8(%eax),%ebx
80101c51:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c57:	77 7d                	ja     80101cd6 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c59:	b8 00 00 00 00       	mov    $0x0,%eax
80101c5e:	e8 ae ff ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c63:	b8 00 00 00 00       	mov    $0x0,%eax
80101c68:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c6d:	ee                   	out    %al,(%dx)
80101c6e:	b8 01 00 00 00       	mov    $0x1,%eax
80101c73:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c78:	ee                   	out    %al,(%dx)
80101c79:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c7e:	89 d8                	mov    %ebx,%eax
80101c80:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c81:	89 d8                	mov    %ebx,%eax
80101c83:	c1 f8 08             	sar    $0x8,%eax
80101c86:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c8b:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c8c:	89 d8                	mov    %ebx,%eax
80101c8e:	c1 f8 10             	sar    $0x10,%eax
80101c91:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c96:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c97:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c9b:	c1 e0 04             	shl    $0x4,%eax
80101c9e:	83 e0 10             	and    $0x10,%eax
80101ca1:	c1 fb 18             	sar    $0x18,%ebx
80101ca4:	83 e3 0f             	and    $0xf,%ebx
80101ca7:	09 d8                	or     %ebx,%eax
80101ca9:	83 c8 e0             	or     $0xffffffe0,%eax
80101cac:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cb1:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cb2:	f6 06 04             	testb  $0x4,(%esi)
80101cb5:	75 2c                	jne    80101ce3 <idestart+0xa0>
80101cb7:	b8 20 00 00 00       	mov    $0x20,%eax
80101cbc:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cc1:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cc5:	5b                   	pop    %ebx
80101cc6:	5e                   	pop    %esi
80101cc7:	5d                   	pop    %ebp
80101cc8:	c3                   	ret    
    panic("idestart");
80101cc9:	83 ec 0c             	sub    $0xc,%esp
80101ccc:	68 6b 6e 10 80       	push   $0x80106e6b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 74 6e 10 80       	push   $0x80106e74
80101cde:	e8 65 e6 ff ff       	call   80100348 <panic>
80101ce3:	b8 30 00 00 00       	mov    $0x30,%eax
80101ce8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ced:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cee:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cf1:	b9 80 00 00 00       	mov    $0x80,%ecx
80101cf6:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101cfb:	fc                   	cld    
80101cfc:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101cfe:	eb c2                	jmp    80101cc2 <idestart+0x7f>

80101d00 <ideinit>:
{
80101d00:	55                   	push   %ebp
80101d01:	89 e5                	mov    %esp,%ebp
80101d03:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d06:	68 86 6e 10 80       	push   $0x80106e86
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 e4 24 00 00       	call   801041f9 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80101d1d:	83 e8 01             	sub    $0x1,%eax
80101d20:	50                   	push   %eax
80101d21:	6a 0e                	push   $0xe
80101d23:	e8 56 02 00 00       	call   80101f7e <ioapicenable>
  idewait(0);
80101d28:	b8 00 00 00 00       	mov    $0x0,%eax
80101d2d:	e8 df fe ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d32:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d37:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d3c:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d3d:	83 c4 10             	add    $0x10,%esp
80101d40:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d45:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d4b:	7f 19                	jg     80101d66 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d4d:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d52:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d53:	84 c0                	test   %al,%al
80101d55:	75 05                	jne    80101d5c <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d57:	83 c1 01             	add    $0x1,%ecx
80101d5a:	eb e9                	jmp    80101d45 <ideinit+0x45>
      havedisk1 = 1;
80101d5c:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101d63:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d66:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d6b:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d70:	ee                   	out    %al,(%dx)
}
80101d71:	c9                   	leave  
80101d72:	c3                   	ret    

80101d73 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	57                   	push   %edi
80101d77:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	68 80 a5 10 80       	push   $0x8010a580
80101d80:	e8 b0 25 00 00       	call   80104335 <acquire>

  if((b = idequeue) == 0){
80101d85:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101d8b:	83 c4 10             	add    $0x10,%esp
80101d8e:	85 db                	test   %ebx,%ebx
80101d90:	74 48                	je     80101dda <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d92:	8b 43 58             	mov    0x58(%ebx),%eax
80101d95:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d9a:	f6 03 04             	testb  $0x4,(%ebx)
80101d9d:	74 4d                	je     80101dec <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d9f:	8b 03                	mov    (%ebx),%eax
80101da1:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101da4:	83 e0 fb             	and    $0xfffffffb,%eax
80101da7:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101da9:	83 ec 0c             	sub    $0xc,%esp
80101dac:	53                   	push   %ebx
80101dad:	e8 44 1a 00 00       	call   801037f6 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101db2:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101db7:	83 c4 10             	add    $0x10,%esp
80101dba:	85 c0                	test   %eax,%eax
80101dbc:	74 05                	je     80101dc3 <ideintr+0x50>
    idestart(idequeue);
80101dbe:	e8 80 fe ff ff       	call   80101c43 <idestart>

  release(&idelock);
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	68 80 a5 10 80       	push   $0x8010a580
80101dcb:	e8 ca 25 00 00       	call   8010439a <release>
80101dd0:	83 c4 10             	add    $0x10,%esp
}
80101dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dd6:	5b                   	pop    %ebx
80101dd7:	5f                   	pop    %edi
80101dd8:	5d                   	pop    %ebp
80101dd9:	c3                   	ret    
    release(&idelock);
80101dda:	83 ec 0c             	sub    $0xc,%esp
80101ddd:	68 80 a5 10 80       	push   $0x8010a580
80101de2:	e8 b3 25 00 00       	call   8010439a <release>
    return;
80101de7:	83 c4 10             	add    $0x10,%esp
80101dea:	eb e7                	jmp    80101dd3 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dec:	b8 01 00 00 00       	mov    $0x1,%eax
80101df1:	e8 1b fe ff ff       	call   80101c11 <idewait>
80101df6:	85 c0                	test   %eax,%eax
80101df8:	78 a5                	js     80101d9f <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101dfa:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101dfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e07:	fc                   	cld    
80101e08:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e0a:	eb 93                	jmp    80101d9f <ideintr+0x2c>

80101e0c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e0c:	55                   	push   %ebp
80101e0d:	89 e5                	mov    %esp,%ebp
80101e0f:	53                   	push   %ebx
80101e10:	83 ec 10             	sub    $0x10,%esp
80101e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e16:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e19:	50                   	push   %eax
80101e1a:	e8 8c 23 00 00       	call   801041ab <holdingsleep>
80101e1f:	83 c4 10             	add    $0x10,%esp
80101e22:	85 c0                	test   %eax,%eax
80101e24:	74 37                	je     80101e5d <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e26:	8b 03                	mov    (%ebx),%eax
80101e28:	83 e0 06             	and    $0x6,%eax
80101e2b:	83 f8 02             	cmp    $0x2,%eax
80101e2e:	74 3a                	je     80101e6a <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e30:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e34:	74 09                	je     80101e3f <iderw+0x33>
80101e36:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101e3d:	74 38                	je     80101e77 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	68 80 a5 10 80       	push   $0x8010a580
80101e47:	e8 e9 24 00 00       	call   80104335 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 8a 6e 10 80       	push   $0x80106e8a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 a0 6e 10 80       	push   $0x80106ea0
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 b5 6e 10 80       	push   $0x80106eb5
80101e7f:	e8 c4 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e84:	8d 50 58             	lea    0x58(%eax),%edx
80101e87:	8b 02                	mov    (%edx),%eax
80101e89:	85 c0                	test   %eax,%eax
80101e8b:	75 f7                	jne    80101e84 <iderw+0x78>
    ;
  *pp = b;
80101e8d:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e8f:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101e95:	75 1a                	jne    80101eb1 <iderw+0xa5>
    idestart(b);
80101e97:	89 d8                	mov    %ebx,%eax
80101e99:	e8 a5 fd ff ff       	call   80101c43 <idestart>
80101e9e:	eb 11                	jmp    80101eb1 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101ea0:	83 ec 08             	sub    $0x8,%esp
80101ea3:	68 80 a5 10 80       	push   $0x8010a580
80101ea8:	53                   	push   %ebx
80101ea9:	e8 e0 17 00 00       	call   8010368e <sleep>
80101eae:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101eb1:	8b 03                	mov    (%ebx),%eax
80101eb3:	83 e0 06             	and    $0x6,%eax
80101eb6:	83 f8 02             	cmp    $0x2,%eax
80101eb9:	75 e5                	jne    80101ea0 <iderw+0x94>
  }


  release(&idelock);
80101ebb:	83 ec 0c             	sub    $0xc,%esp
80101ebe:	68 80 a5 10 80       	push   $0x8010a580
80101ec3:	e8 d2 24 00 00       	call   8010439a <release>
}
80101ec8:	83 c4 10             	add    $0x10,%esp
80101ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ece:	c9                   	leave  
80101ecf:	c3                   	ret    

80101ed0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ed0:	55                   	push   %ebp
80101ed1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ed3:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101ed9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101edb:	a1 34 26 11 80       	mov    0x80112634,%eax
80101ee0:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ee3:	5d                   	pop    %ebp
80101ee4:	c3                   	ret    

80101ee5 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ee5:	55                   	push   %ebp
80101ee6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ee8:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101eee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ef0:	a1 34 26 11 80       	mov    0x80112634,%eax
80101ef5:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ef8:	5d                   	pop    %ebp
80101ef9:	c3                   	ret    

80101efa <ioapicinit>:

void
ioapicinit(void)
{
80101efa:	55                   	push   %ebp
80101efb:	89 e5                	mov    %esp,%ebp
80101efd:	57                   	push   %edi
80101efe:	56                   	push   %esi
80101eff:	53                   	push   %ebx
80101f00:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f03:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
80101f0a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f0d:	b8 01 00 00 00       	mov    $0x1,%eax
80101f12:	e8 b9 ff ff ff       	call   80101ed0 <ioapicread>
80101f17:	c1 e8 10             	shr    $0x10,%eax
80101f1a:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80101f22:	e8 a9 ff ff ff       	call   80101ed0 <ioapicread>
80101f27:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f2a:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 d4 6e 10 80       	push   $0x80106ed4
80101f44:	e8 c2 e6 ff ff       	call   8010060b <cprintf>
80101f49:	83 c4 10             	add    $0x10,%esp
80101f4c:	eb e7                	jmp    80101f35 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f4e:	8d 53 20             	lea    0x20(%ebx),%edx
80101f51:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f57:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f5b:	89 f0                	mov    %esi,%eax
80101f5d:	e8 83 ff ff ff       	call   80101ee5 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f62:	8d 46 01             	lea    0x1(%esi),%eax
80101f65:	ba 00 00 00 00       	mov    $0x0,%edx
80101f6a:	e8 76 ff ff ff       	call   80101ee5 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f6f:	83 c3 01             	add    $0x1,%ebx
80101f72:	39 fb                	cmp    %edi,%ebx
80101f74:	7e d8                	jle    80101f4e <ioapicinit+0x54>
  }
}
80101f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f79:	5b                   	pop    %ebx
80101f7a:	5e                   	pop    %esi
80101f7b:	5f                   	pop    %edi
80101f7c:	5d                   	pop    %ebp
80101f7d:	c3                   	ret    

80101f7e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f7e:	55                   	push   %ebp
80101f7f:	89 e5                	mov    %esp,%ebp
80101f81:	53                   	push   %ebx
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f85:	8d 50 20             	lea    0x20(%eax),%edx
80101f88:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f8c:	89 d8                	mov    %ebx,%eax
80101f8e:	e8 52 ff ff ff       	call   80101ee5 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f96:	c1 e2 18             	shl    $0x18,%edx
80101f99:	8d 43 01             	lea    0x1(%ebx),%eax
80101f9c:	e8 44 ff ff ff       	call   80101ee5 <ioapicwrite>
}
80101fa1:	5b                   	pop    %ebx
80101fa2:	5d                   	pop    %ebp
80101fa3:	c3                   	ret    

80101fa4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fa4:	55                   	push   %ebp
80101fa5:	89 e5                	mov    %esp,%ebp
80101fa7:	53                   	push   %ebx
80101fa8:	83 ec 04             	sub    $0x4,%esp
80101fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fae:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fb4:	75 4c                	jne    80102002 <kfree+0x5e>
80101fb6:	81 fb c8 71 11 80    	cmp    $0x801171c8,%ebx
80101fbc:	72 44                	jb     80102002 <kfree+0x5e>
80101fbe:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fc4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fc9:	77 37                	ja     80102002 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fcb:	83 ec 04             	sub    $0x4,%esp
80101fce:	68 00 10 00 00       	push   $0x1000
80101fd3:	6a 01                	push   $0x1
80101fd5:	53                   	push   %ebx
80101fd6:	e8 06 24 00 00       	call   801043e1 <memset>

  if(kmem.use_lock)
80101fdb:	83 c4 10             	add    $0x10,%esp
80101fde:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101fe5:	75 28                	jne    8010200f <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fe7:	a1 78 26 11 80       	mov    0x80112678,%eax
80101fec:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fee:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
80101ff4:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101ffb:	75 24                	jne    80102021 <kfree+0x7d>
    release(&kmem.lock);
}
80101ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102000:	c9                   	leave  
80102001:	c3                   	ret    
    panic("kfree");
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	68 06 6f 10 80       	push   $0x80106f06
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 40 26 11 80       	push   $0x80112640
80102017:	e8 19 23 00 00       	call   80104335 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 40 26 11 80       	push   $0x80112640
80102029:	e8 6c 23 00 00       	call   8010439a <release>
8010202e:	83 c4 10             	add    $0x10,%esp
}
80102031:	eb ca                	jmp    80101ffd <kfree+0x59>

80102033 <freerange>:
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	56                   	push   %esi
80102037:	53                   	push   %ebx
80102038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102043:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102048:	eb 0e                	jmp    80102058 <freerange+0x25>
    kfree(p);
8010204a:	83 ec 0c             	sub    $0xc,%esp
8010204d:	50                   	push   %eax
8010204e:	e8 51 ff ff ff       	call   80101fa4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102053:	83 c4 10             	add    $0x10,%esp
80102056:	89 f0                	mov    %esi,%eax
80102058:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010205e:	39 de                	cmp    %ebx,%esi
80102060:	76 e8                	jbe    8010204a <freerange+0x17>
}
80102062:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102065:	5b                   	pop    %ebx
80102066:	5e                   	pop    %esi
80102067:	5d                   	pop    %ebp
80102068:	c3                   	ret    

80102069 <kinit1>:
{
80102069:	55                   	push   %ebp
8010206a:	89 e5                	mov    %esp,%ebp
8010206c:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010206f:	68 0c 6f 10 80       	push   $0x80106f0c
80102074:	68 40 26 11 80       	push   $0x80112640
80102079:	e8 7b 21 00 00       	call   801041f9 <initlock>
  kmem.use_lock = 0;
8010207e:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102085:	00 00 00 
  freerange(vstart, vend);
80102088:	83 c4 08             	add    $0x8,%esp
8010208b:	ff 75 0c             	pushl  0xc(%ebp)
8010208e:	ff 75 08             	pushl  0x8(%ebp)
80102091:	e8 9d ff ff ff       	call   80102033 <freerange>
}
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	c9                   	leave  
8010209a:	c3                   	ret    

8010209b <kinit2>:
{
8010209b:	55                   	push   %ebp
8010209c:	89 e5                	mov    %esp,%ebp
8010209e:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	ff 75 08             	pushl  0x8(%ebp)
801020a7:	e8 87 ff ff ff       	call   80102033 <freerange>
  kmem.use_lock = 1;
801020ac:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
801020b3:	00 00 00 
}
801020b6:	83 c4 10             	add    $0x10,%esp
801020b9:	c9                   	leave  
801020ba:	c3                   	ret    

801020bb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020bb:	55                   	push   %ebp
801020bc:	89 e5                	mov    %esp,%ebp
801020be:	53                   	push   %ebx
801020bf:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020c2:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801020c9:	75 21                	jne    801020ec <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020cb:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
801020d1:	85 db                	test   %ebx,%ebx
801020d3:	74 07                	je     801020dc <kalloc+0x21>
    kmem.freelist = r->next;
801020d5:	8b 03                	mov    (%ebx),%eax
801020d7:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
801020dc:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801020e3:	75 19                	jne    801020fe <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020e5:	89 d8                	mov    %ebx,%eax
801020e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020ea:	c9                   	leave  
801020eb:	c3                   	ret    
    acquire(&kmem.lock);
801020ec:	83 ec 0c             	sub    $0xc,%esp
801020ef:	68 40 26 11 80       	push   $0x80112640
801020f4:	e8 3c 22 00 00       	call   80104335 <acquire>
801020f9:	83 c4 10             	add    $0x10,%esp
801020fc:	eb cd                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
801020fe:	83 ec 0c             	sub    $0xc,%esp
80102101:	68 40 26 11 80       	push   $0x80112640
80102106:	e8 8f 22 00 00       	call   8010439a <release>
8010210b:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010210e:	eb d5                	jmp    801020e5 <kalloc+0x2a>

80102110 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102113:	ba 64 00 00 00       	mov    $0x64,%edx
80102118:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102119:	a8 01                	test   $0x1,%al
8010211b:	0f 84 b5 00 00 00    	je     801021d6 <kbdgetc+0xc6>
80102121:	ba 60 00 00 00       	mov    $0x60,%edx
80102126:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102127:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010212a:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102130:	74 5c                	je     8010218e <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102132:	84 c0                	test   %al,%al
80102134:	78 66                	js     8010219c <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102136:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010213c:	f6 c1 40             	test   $0x40,%cl
8010213f:	74 0f                	je     80102150 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102141:	83 c8 80             	or     $0xffffff80,%eax
80102144:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102147:	83 e1 bf             	and    $0xffffffbf,%ecx
8010214a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102150:	0f b6 8a 40 70 10 80 	movzbl -0x7fef8fc0(%edx),%ecx
80102157:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
8010215d:	0f b6 82 40 6f 10 80 	movzbl -0x7fef90c0(%edx),%eax
80102164:	31 c1                	xor    %eax,%ecx
80102166:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010216c:	89 c8                	mov    %ecx,%eax
8010216e:	83 e0 03             	and    $0x3,%eax
80102171:	8b 04 85 20 6f 10 80 	mov    -0x7fef90e0(,%eax,4),%eax
80102178:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010217c:	f6 c1 08             	test   $0x8,%cl
8010217f:	74 19                	je     8010219a <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102181:	8d 50 9f             	lea    -0x61(%eax),%edx
80102184:	83 fa 19             	cmp    $0x19,%edx
80102187:	77 40                	ja     801021c9 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102189:	83 e8 20             	sub    $0x20,%eax
8010218c:	eb 0c                	jmp    8010219a <kbdgetc+0x8a>
    shift |= E0ESC;
8010218e:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
80102195:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010219a:	5d                   	pop    %ebp
8010219b:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010219c:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801021a2:	f6 c1 40             	test   $0x40,%cl
801021a5:	75 05                	jne    801021ac <kbdgetc+0x9c>
801021a7:	89 c2                	mov    %eax,%edx
801021a9:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801021ac:	0f b6 82 40 70 10 80 	movzbl -0x7fef8fc0(%edx),%eax
801021b3:	83 c8 40             	or     $0x40,%eax
801021b6:	0f b6 c0             	movzbl %al,%eax
801021b9:	f7 d0                	not    %eax
801021bb:	21 c8                	and    %ecx,%eax
801021bd:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
801021c2:	b8 00 00 00 00       	mov    $0x0,%eax
801021c7:	eb d1                	jmp    8010219a <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801021c9:	8d 50 bf             	lea    -0x41(%eax),%edx
801021cc:	83 fa 19             	cmp    $0x19,%edx
801021cf:	77 c9                	ja     8010219a <kbdgetc+0x8a>
      c += 'a' - 'A';
801021d1:	83 c0 20             	add    $0x20,%eax
  return c;
801021d4:	eb c4                	jmp    8010219a <kbdgetc+0x8a>
    return -1;
801021d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021db:	eb bd                	jmp    8010219a <kbdgetc+0x8a>

801021dd <kbdintr>:

void
kbdintr(void)
{
801021dd:	55                   	push   %ebp
801021de:	89 e5                	mov    %esp,%ebp
801021e0:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021e3:	68 10 21 10 80       	push   $0x80102110
801021e8:	e8 51 e5 ff ff       	call   8010073e <consoleintr>
}
801021ed:	83 c4 10             	add    $0x10,%esp
801021f0:	c9                   	leave  
801021f1:	c3                   	ret    

801021f2 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801021f2:	55                   	push   %ebp
801021f3:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801021f5:	8b 0d 7c 26 11 80    	mov    0x8011267c,%ecx
801021fb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801021fe:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102200:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102205:	8b 40 20             	mov    0x20(%eax),%eax
}
80102208:	5d                   	pop    %ebp
80102209:	c3                   	ret    

8010220a <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010220a:	55                   	push   %ebp
8010220b:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010220d:	ba 70 00 00 00       	mov    $0x70,%edx
80102212:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102213:	ba 71 00 00 00       	mov    $0x71,%edx
80102218:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102219:	0f b6 c0             	movzbl %al,%eax
}
8010221c:	5d                   	pop    %ebp
8010221d:	c3                   	ret    

8010221e <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010221e:	55                   	push   %ebp
8010221f:	89 e5                	mov    %esp,%ebp
80102221:	53                   	push   %ebx
80102222:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102224:	b8 00 00 00 00       	mov    $0x0,%eax
80102229:	e8 dc ff ff ff       	call   8010220a <cmos_read>
8010222e:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102230:	b8 02 00 00 00       	mov    $0x2,%eax
80102235:	e8 d0 ff ff ff       	call   8010220a <cmos_read>
8010223a:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010223d:	b8 04 00 00 00       	mov    $0x4,%eax
80102242:	e8 c3 ff ff ff       	call   8010220a <cmos_read>
80102247:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010224a:	b8 07 00 00 00       	mov    $0x7,%eax
8010224f:	e8 b6 ff ff ff       	call   8010220a <cmos_read>
80102254:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102257:	b8 08 00 00 00       	mov    $0x8,%eax
8010225c:	e8 a9 ff ff ff       	call   8010220a <cmos_read>
80102261:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102264:	b8 09 00 00 00       	mov    $0x9,%eax
80102269:	e8 9c ff ff ff       	call   8010220a <cmos_read>
8010226e:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102271:	5b                   	pop    %ebx
80102272:	5d                   	pop    %ebp
80102273:	c3                   	ret    

80102274 <lapicinit>:
  if(!lapic)
80102274:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
8010227b:	0f 84 fb 00 00 00    	je     8010237c <lapicinit+0x108>
{
80102281:	55                   	push   %ebp
80102282:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102284:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102289:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010228e:	e8 5f ff ff ff       	call   801021f2 <lapicw>
  lapicw(TDCR, X1);
80102293:	ba 0b 00 00 00       	mov    $0xb,%edx
80102298:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010229d:	e8 50 ff ff ff       	call   801021f2 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022a2:	ba 20 00 02 00       	mov    $0x20020,%edx
801022a7:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022ac:	e8 41 ff ff ff       	call   801021f2 <lapicw>
  lapicw(TICR, 10000000);
801022b1:	ba 80 96 98 00       	mov    $0x989680,%edx
801022b6:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022bb:	e8 32 ff ff ff       	call   801021f2 <lapicw>
  lapicw(LINT0, MASKED);
801022c0:	ba 00 00 01 00       	mov    $0x10000,%edx
801022c5:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022ca:	e8 23 ff ff ff       	call   801021f2 <lapicw>
  lapicw(LINT1, MASKED);
801022cf:	ba 00 00 01 00       	mov    $0x10000,%edx
801022d4:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022d9:	e8 14 ff ff ff       	call   801021f2 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801022de:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801022e3:	8b 40 30             	mov    0x30(%eax),%eax
801022e6:	c1 e8 10             	shr    $0x10,%eax
801022e9:	3c 03                	cmp    $0x3,%al
801022eb:	77 7b                	ja     80102368 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801022ed:	ba 33 00 00 00       	mov    $0x33,%edx
801022f2:	b8 dc 00 00 00       	mov    $0xdc,%eax
801022f7:	e8 f6 fe ff ff       	call   801021f2 <lapicw>
  lapicw(ESR, 0);
801022fc:	ba 00 00 00 00       	mov    $0x0,%edx
80102301:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102306:	e8 e7 fe ff ff       	call   801021f2 <lapicw>
  lapicw(ESR, 0);
8010230b:	ba 00 00 00 00       	mov    $0x0,%edx
80102310:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102315:	e8 d8 fe ff ff       	call   801021f2 <lapicw>
  lapicw(EOI, 0);
8010231a:	ba 00 00 00 00       	mov    $0x0,%edx
8010231f:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102324:	e8 c9 fe ff ff       	call   801021f2 <lapicw>
  lapicw(ICRHI, 0);
80102329:	ba 00 00 00 00       	mov    $0x0,%edx
8010232e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102333:	e8 ba fe ff ff       	call   801021f2 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102338:	ba 00 85 08 00       	mov    $0x88500,%edx
8010233d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102342:	e8 ab fe ff ff       	call   801021f2 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102347:	a1 7c 26 11 80       	mov    0x8011267c,%eax
8010234c:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102352:	f6 c4 10             	test   $0x10,%ah
80102355:	75 f0                	jne    80102347 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102357:	ba 00 00 00 00       	mov    $0x0,%edx
8010235c:	b8 20 00 00 00       	mov    $0x20,%eax
80102361:	e8 8c fe ff ff       	call   801021f2 <lapicw>
}
80102366:	5d                   	pop    %ebp
80102367:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102368:	ba 00 00 01 00       	mov    $0x10000,%edx
8010236d:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102372:	e8 7b fe ff ff       	call   801021f2 <lapicw>
80102377:	e9 71 ff ff ff       	jmp    801022ed <lapicinit+0x79>
8010237c:	f3 c3                	repz ret 

8010237e <lapicid>:
{
8010237e:	55                   	push   %ebp
8010237f:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102381:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102386:	85 c0                	test   %eax,%eax
80102388:	74 08                	je     80102392 <lapicid+0x14>
  return lapic[ID] >> 24;
8010238a:	8b 40 20             	mov    0x20(%eax),%eax
8010238d:	c1 e8 18             	shr    $0x18,%eax
}
80102390:	5d                   	pop    %ebp
80102391:	c3                   	ret    
    return 0;
80102392:	b8 00 00 00 00       	mov    $0x0,%eax
80102397:	eb f7                	jmp    80102390 <lapicid+0x12>

80102399 <lapiceoi>:
  if(lapic)
80102399:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
801023a0:	74 14                	je     801023b6 <lapiceoi+0x1d>
{
801023a2:	55                   	push   %ebp
801023a3:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801023a5:	ba 00 00 00 00       	mov    $0x0,%edx
801023aa:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023af:	e8 3e fe ff ff       	call   801021f2 <lapicw>
}
801023b4:	5d                   	pop    %ebp
801023b5:	c3                   	ret    
801023b6:	f3 c3                	repz ret 

801023b8 <microdelay>:
{
801023b8:	55                   	push   %ebp
801023b9:	89 e5                	mov    %esp,%ebp
}
801023bb:	5d                   	pop    %ebp
801023bc:	c3                   	ret    

801023bd <lapicstartap>:
{
801023bd:	55                   	push   %ebp
801023be:	89 e5                	mov    %esp,%ebp
801023c0:	57                   	push   %edi
801023c1:	56                   	push   %esi
801023c2:	53                   	push   %ebx
801023c3:	8b 75 08             	mov    0x8(%ebp),%esi
801023c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023c9:	b8 0f 00 00 00       	mov    $0xf,%eax
801023ce:	ba 70 00 00 00       	mov    $0x70,%edx
801023d3:	ee                   	out    %al,(%dx)
801023d4:	b8 0a 00 00 00       	mov    $0xa,%eax
801023d9:	ba 71 00 00 00       	mov    $0x71,%edx
801023de:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801023df:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801023e6:	00 00 
  wrv[1] = addr >> 4;
801023e8:	89 f8                	mov    %edi,%eax
801023ea:	c1 e8 04             	shr    $0x4,%eax
801023ed:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801023f3:	c1 e6 18             	shl    $0x18,%esi
801023f6:	89 f2                	mov    %esi,%edx
801023f8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023fd:	e8 f0 fd ff ff       	call   801021f2 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102402:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102407:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010240c:	e8 e1 fd ff ff       	call   801021f2 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102411:	ba 00 85 00 00       	mov    $0x8500,%edx
80102416:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010241b:	e8 d2 fd ff ff       	call   801021f2 <lapicw>
  for(i = 0; i < 2; i++){
80102420:	bb 00 00 00 00       	mov    $0x0,%ebx
80102425:	eb 21                	jmp    80102448 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102427:	89 f2                	mov    %esi,%edx
80102429:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010242e:	e8 bf fd ff ff       	call   801021f2 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102433:	89 fa                	mov    %edi,%edx
80102435:	c1 ea 0c             	shr    $0xc,%edx
80102438:	80 ce 06             	or     $0x6,%dh
8010243b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102440:	e8 ad fd ff ff       	call   801021f2 <lapicw>
  for(i = 0; i < 2; i++){
80102445:	83 c3 01             	add    $0x1,%ebx
80102448:	83 fb 01             	cmp    $0x1,%ebx
8010244b:	7e da                	jle    80102427 <lapicstartap+0x6a>
}
8010244d:	5b                   	pop    %ebx
8010244e:	5e                   	pop    %esi
8010244f:	5f                   	pop    %edi
80102450:	5d                   	pop    %ebp
80102451:	c3                   	ret    

80102452 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102452:	55                   	push   %ebp
80102453:	89 e5                	mov    %esp,%ebp
80102455:	57                   	push   %edi
80102456:	56                   	push   %esi
80102457:	53                   	push   %ebx
80102458:	83 ec 3c             	sub    $0x3c,%esp
8010245b:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010245e:	b8 0b 00 00 00       	mov    $0xb,%eax
80102463:	e8 a2 fd ff ff       	call   8010220a <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102468:	83 e0 04             	and    $0x4,%eax
8010246b:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010246d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102470:	e8 a9 fd ff ff       	call   8010221e <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102475:	b8 0a 00 00 00       	mov    $0xa,%eax
8010247a:	e8 8b fd ff ff       	call   8010220a <cmos_read>
8010247f:	a8 80                	test   $0x80,%al
80102481:	75 ea                	jne    8010246d <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102483:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102486:	89 d8                	mov    %ebx,%eax
80102488:	e8 91 fd ff ff       	call   8010221e <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010248d:	83 ec 04             	sub    $0x4,%esp
80102490:	6a 18                	push   $0x18
80102492:	53                   	push   %ebx
80102493:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102496:	50                   	push   %eax
80102497:	e8 8b 1f 00 00       	call   80104427 <memcmp>
8010249c:	83 c4 10             	add    $0x10,%esp
8010249f:	85 c0                	test   %eax,%eax
801024a1:	75 ca                	jne    8010246d <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024a3:	85 ff                	test   %edi,%edi
801024a5:	0f 85 84 00 00 00    	jne    8010252f <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
801024ae:	89 d0                	mov    %edx,%eax
801024b0:	c1 e8 04             	shr    $0x4,%eax
801024b3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024b6:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024b9:	83 e2 0f             	and    $0xf,%edx
801024bc:	01 d0                	add    %edx,%eax
801024be:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801024c4:	89 d0                	mov    %edx,%eax
801024c6:	c1 e8 04             	shr    $0x4,%eax
801024c9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024cc:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024cf:	83 e2 0f             	and    $0xf,%edx
801024d2:	01 d0                	add    %edx,%eax
801024d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801024da:	89 d0                	mov    %edx,%eax
801024dc:	c1 e8 04             	shr    $0x4,%eax
801024df:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024e2:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024e5:	83 e2 0f             	and    $0xf,%edx
801024e8:	01 d0                	add    %edx,%eax
801024ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801024ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
801024f0:	89 d0                	mov    %edx,%eax
801024f2:	c1 e8 04             	shr    $0x4,%eax
801024f5:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024f8:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024fb:	83 e2 0f             	and    $0xf,%edx
801024fe:	01 d0                	add    %edx,%eax
80102500:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102503:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102506:	89 d0                	mov    %edx,%eax
80102508:	c1 e8 04             	shr    $0x4,%eax
8010250b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010250e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102511:	83 e2 0f             	and    $0xf,%edx
80102514:	01 d0                	add    %edx,%eax
80102516:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010251c:	89 d0                	mov    %edx,%eax
8010251e:	c1 e8 04             	shr    $0x4,%eax
80102521:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102524:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102527:	83 e2 0f             	and    $0xf,%edx
8010252a:	01 d0                	add    %edx,%eax
8010252c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
8010252f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102532:	89 06                	mov    %eax,(%esi)
80102534:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102537:	89 46 04             	mov    %eax,0x4(%esi)
8010253a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010253d:	89 46 08             	mov    %eax,0x8(%esi)
80102540:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102543:	89 46 0c             	mov    %eax,0xc(%esi)
80102546:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102549:	89 46 10             	mov    %eax,0x10(%esi)
8010254c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010254f:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102552:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102559:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010255c:	5b                   	pop    %ebx
8010255d:	5e                   	pop    %esi
8010255e:	5f                   	pop    %edi
8010255f:	5d                   	pop    %ebp
80102560:	c3                   	ret    

80102561 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102561:	55                   	push   %ebp
80102562:	89 e5                	mov    %esp,%ebp
80102564:	53                   	push   %ebx
80102565:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102568:	ff 35 b4 26 11 80    	pushl  0x801126b4
8010256e:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102574:	e8 f3 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102579:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010257c:	89 1d c8 26 11 80    	mov    %ebx,0x801126c8
  for (i = 0; i < log.lh.n; i++) {
80102582:	83 c4 10             	add    $0x10,%esp
80102585:	ba 00 00 00 00       	mov    $0x0,%edx
8010258a:	eb 0e                	jmp    8010259a <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010258c:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102590:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102597:	83 c2 01             	add    $0x1,%edx
8010259a:	39 d3                	cmp    %edx,%ebx
8010259c:	7f ee                	jg     8010258c <read_head+0x2b>
  }
  brelse(buf);
8010259e:	83 ec 0c             	sub    $0xc,%esp
801025a1:	50                   	push   %eax
801025a2:	e8 2e dc ff ff       	call   801001d5 <brelse>
}
801025a7:	83 c4 10             	add    $0x10,%esp
801025aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025ad:	c9                   	leave  
801025ae:	c3                   	ret    

801025af <install_trans>:
{
801025af:	55                   	push   %ebp
801025b0:	89 e5                	mov    %esp,%ebp
801025b2:	57                   	push   %edi
801025b3:	56                   	push   %esi
801025b4:	53                   	push   %ebx
801025b5:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025b8:	bb 00 00 00 00       	mov    $0x0,%ebx
801025bd:	eb 66                	jmp    80102625 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025bf:	89 d8                	mov    %ebx,%eax
801025c1:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801025c7:	83 c0 01             	add    $0x1,%eax
801025ca:	83 ec 08             	sub    $0x8,%esp
801025cd:	50                   	push   %eax
801025ce:	ff 35 c4 26 11 80    	pushl  0x801126c4
801025d4:	e8 93 db ff ff       	call   8010016c <bread>
801025d9:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025db:	83 c4 08             	add    $0x8,%esp
801025de:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
801025e5:	ff 35 c4 26 11 80    	pushl  0x801126c4
801025eb:	e8 7c db ff ff       	call   8010016c <bread>
801025f0:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801025f2:	8d 57 5c             	lea    0x5c(%edi),%edx
801025f5:	8d 40 5c             	lea    0x5c(%eax),%eax
801025f8:	83 c4 0c             	add    $0xc,%esp
801025fb:	68 00 02 00 00       	push   $0x200
80102600:	52                   	push   %edx
80102601:	50                   	push   %eax
80102602:	e8 55 1e 00 00       	call   8010445c <memmove>
    bwrite(dbuf);  // write dst to disk
80102607:	89 34 24             	mov    %esi,(%esp)
8010260a:	e8 8b db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
8010260f:	89 3c 24             	mov    %edi,(%esp)
80102612:	e8 be db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102617:	89 34 24             	mov    %esi,(%esp)
8010261a:	e8 b6 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010261f:	83 c3 01             	add    $0x1,%ebx
80102622:	83 c4 10             	add    $0x10,%esp
80102625:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
8010262b:	7f 92                	jg     801025bf <install_trans+0x10>
}
8010262d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102630:	5b                   	pop    %ebx
80102631:	5e                   	pop    %esi
80102632:	5f                   	pop    %edi
80102633:	5d                   	pop    %ebp
80102634:	c3                   	ret    

80102635 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102635:	55                   	push   %ebp
80102636:	89 e5                	mov    %esp,%ebp
80102638:	53                   	push   %ebx
80102639:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010263c:	ff 35 b4 26 11 80    	pushl  0x801126b4
80102642:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102648:	e8 1f db ff ff       	call   8010016c <bread>
8010264d:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010264f:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
80102655:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102658:	83 c4 10             	add    $0x10,%esp
8010265b:	b8 00 00 00 00       	mov    $0x0,%eax
80102660:	eb 0e                	jmp    80102670 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102662:	8b 14 85 cc 26 11 80 	mov    -0x7feed934(,%eax,4),%edx
80102669:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010266d:	83 c0 01             	add    $0x1,%eax
80102670:	39 c1                	cmp    %eax,%ecx
80102672:	7f ee                	jg     80102662 <write_head+0x2d>
  }
  bwrite(buf);
80102674:	83 ec 0c             	sub    $0xc,%esp
80102677:	53                   	push   %ebx
80102678:	e8 1d db ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010267d:	89 1c 24             	mov    %ebx,(%esp)
80102680:	e8 50 db ff ff       	call   801001d5 <brelse>
}
80102685:	83 c4 10             	add    $0x10,%esp
80102688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010268b:	c9                   	leave  
8010268c:	c3                   	ret    

8010268d <recover_from_log>:

static void
recover_from_log(void)
{
8010268d:	55                   	push   %ebp
8010268e:	89 e5                	mov    %esp,%ebp
80102690:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102693:	e8 c9 fe ff ff       	call   80102561 <read_head>
  install_trans(); // if committed, copy from log to disk
80102698:	e8 12 ff ff ff       	call   801025af <install_trans>
  log.lh.n = 0;
8010269d:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
801026a4:	00 00 00 
  write_head(); // clear the log
801026a7:	e8 89 ff ff ff       	call   80102635 <write_head>
}
801026ac:	c9                   	leave  
801026ad:	c3                   	ret    

801026ae <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026ae:	55                   	push   %ebp
801026af:	89 e5                	mov    %esp,%ebp
801026b1:	57                   	push   %edi
801026b2:	56                   	push   %esi
801026b3:	53                   	push   %ebx
801026b4:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026b7:	bb 00 00 00 00       	mov    $0x0,%ebx
801026bc:	eb 66                	jmp    80102724 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026be:	89 d8                	mov    %ebx,%eax
801026c0:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801026c6:	83 c0 01             	add    $0x1,%eax
801026c9:	83 ec 08             	sub    $0x8,%esp
801026cc:	50                   	push   %eax
801026cd:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026d3:	e8 94 da ff ff       	call   8010016c <bread>
801026d8:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026da:	83 c4 08             	add    $0x8,%esp
801026dd:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
801026e4:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026ea:	e8 7d da ff ff       	call   8010016c <bread>
801026ef:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801026f1:	8d 50 5c             	lea    0x5c(%eax),%edx
801026f4:	8d 46 5c             	lea    0x5c(%esi),%eax
801026f7:	83 c4 0c             	add    $0xc,%esp
801026fa:	68 00 02 00 00       	push   $0x200
801026ff:	52                   	push   %edx
80102700:	50                   	push   %eax
80102701:	e8 56 1d 00 00       	call   8010445c <memmove>
    bwrite(to);  // write the log
80102706:	89 34 24             	mov    %esi,(%esp)
80102709:	e8 8c da ff ff       	call   8010019a <bwrite>
    brelse(from);
8010270e:	89 3c 24             	mov    %edi,(%esp)
80102711:	e8 bf da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102716:	89 34 24             	mov    %esi,(%esp)
80102719:	e8 b7 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010271e:	83 c3 01             	add    $0x1,%ebx
80102721:	83 c4 10             	add    $0x10,%esp
80102724:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
8010272a:	7f 92                	jg     801026be <write_log+0x10>
  }
}
8010272c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010272f:	5b                   	pop    %ebx
80102730:	5e                   	pop    %esi
80102731:	5f                   	pop    %edi
80102732:	5d                   	pop    %ebp
80102733:	c3                   	ret    

80102734 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102734:	83 3d c8 26 11 80 00 	cmpl   $0x0,0x801126c8
8010273b:	7e 26                	jle    80102763 <commit+0x2f>
{
8010273d:	55                   	push   %ebp
8010273e:	89 e5                	mov    %esp,%ebp
80102740:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102743:	e8 66 ff ff ff       	call   801026ae <write_log>
    write_head();    // Write header to disk -- the real commit
80102748:	e8 e8 fe ff ff       	call   80102635 <write_head>
    install_trans(); // Now install writes to home locations
8010274d:	e8 5d fe ff ff       	call   801025af <install_trans>
    log.lh.n = 0;
80102752:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102759:	00 00 00 
    write_head();    // Erase the transaction from the log
8010275c:	e8 d4 fe ff ff       	call   80102635 <write_head>
  }
}
80102761:	c9                   	leave  
80102762:	c3                   	ret    
80102763:	f3 c3                	repz ret 

80102765 <initlog>:
{
80102765:	55                   	push   %ebp
80102766:	89 e5                	mov    %esp,%ebp
80102768:	53                   	push   %ebx
80102769:	83 ec 2c             	sub    $0x2c,%esp
8010276c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010276f:	68 40 71 10 80       	push   $0x80107140
80102774:	68 80 26 11 80       	push   $0x80112680
80102779:	e8 7b 1a 00 00       	call   801041f9 <initlock>
  readsb(dev, &sb);
8010277e:	83 c4 08             	add    $0x8,%esp
80102781:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102784:	50                   	push   %eax
80102785:	53                   	push   %ebx
80102786:	e8 ab ea ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
8010278b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010278e:	a3 b4 26 11 80       	mov    %eax,0x801126b4
  log.size = sb.nlog;
80102793:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102796:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  log.dev = dev;
8010279b:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4
  recover_from_log();
801027a1:	e8 e7 fe ff ff       	call   8010268d <recover_from_log>
}
801027a6:	83 c4 10             	add    $0x10,%esp
801027a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ac:	c9                   	leave  
801027ad:	c3                   	ret    

801027ae <begin_op>:
{
801027ae:	55                   	push   %ebp
801027af:	89 e5                	mov    %esp,%ebp
801027b1:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027b4:	68 80 26 11 80       	push   $0x80112680
801027b9:	e8 77 1b 00 00       	call   80104335 <acquire>
801027be:	83 c4 10             	add    $0x10,%esp
801027c1:	eb 15                	jmp    801027d8 <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c3:	83 ec 08             	sub    $0x8,%esp
801027c6:	68 80 26 11 80       	push   $0x80112680
801027cb:	68 80 26 11 80       	push   $0x80112680
801027d0:	e8 b9 0e 00 00       	call   8010368e <sleep>
801027d5:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027d8:	83 3d c0 26 11 80 00 	cmpl   $0x0,0x801126c0
801027df:	75 e2                	jne    801027c3 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027e1:	a1 bc 26 11 80       	mov    0x801126bc,%eax
801027e6:	83 c0 01             	add    $0x1,%eax
801027e9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ec:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801027ef:	03 15 c8 26 11 80    	add    0x801126c8,%edx
801027f5:	83 fa 1e             	cmp    $0x1e,%edx
801027f8:	7e 17                	jle    80102811 <begin_op+0x63>
      sleep(&log, &log.lock);
801027fa:	83 ec 08             	sub    $0x8,%esp
801027fd:	68 80 26 11 80       	push   $0x80112680
80102802:	68 80 26 11 80       	push   $0x80112680
80102807:	e8 82 0e 00 00       	call   8010368e <sleep>
8010280c:	83 c4 10             	add    $0x10,%esp
8010280f:	eb c7                	jmp    801027d8 <begin_op+0x2a>
      log.outstanding += 1;
80102811:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
80102816:	83 ec 0c             	sub    $0xc,%esp
80102819:	68 80 26 11 80       	push   $0x80112680
8010281e:	e8 77 1b 00 00       	call   8010439a <release>
}
80102823:	83 c4 10             	add    $0x10,%esp
80102826:	c9                   	leave  
80102827:	c3                   	ret    

80102828 <end_op>:
{
80102828:	55                   	push   %ebp
80102829:	89 e5                	mov    %esp,%ebp
8010282b:	53                   	push   %ebx
8010282c:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
8010282f:	68 80 26 11 80       	push   $0x80112680
80102834:	e8 fc 1a 00 00       	call   80104335 <acquire>
  log.outstanding -= 1;
80102839:	a1 bc 26 11 80       	mov    0x801126bc,%eax
8010283e:	83 e8 01             	sub    $0x1,%eax
80102841:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(log.committing)
80102846:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
8010284c:	83 c4 10             	add    $0x10,%esp
8010284f:	85 db                	test   %ebx,%ebx
80102851:	75 2c                	jne    8010287f <end_op+0x57>
  if(log.outstanding == 0){
80102853:	85 c0                	test   %eax,%eax
80102855:	75 35                	jne    8010288c <end_op+0x64>
    log.committing = 1;
80102857:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
8010285e:	00 00 00 
    do_commit = 1;
80102861:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102866:	83 ec 0c             	sub    $0xc,%esp
80102869:	68 80 26 11 80       	push   $0x80112680
8010286e:	e8 27 1b 00 00       	call   8010439a <release>
  if(do_commit){
80102873:	83 c4 10             	add    $0x10,%esp
80102876:	85 db                	test   %ebx,%ebx
80102878:	75 24                	jne    8010289e <end_op+0x76>
}
8010287a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010287d:	c9                   	leave  
8010287e:	c3                   	ret    
    panic("log.committing");
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 44 71 10 80       	push   $0x80107144
80102887:	e8 bc da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 80 26 11 80       	push   $0x80112680
80102894:	e8 5d 0f 00 00       	call   801037f6 <wakeup>
80102899:	83 c4 10             	add    $0x10,%esp
8010289c:	eb c8                	jmp    80102866 <end_op+0x3e>
    commit();
8010289e:	e8 91 fe ff ff       	call   80102734 <commit>
    acquire(&log.lock);
801028a3:	83 ec 0c             	sub    $0xc,%esp
801028a6:	68 80 26 11 80       	push   $0x80112680
801028ab:	e8 85 1a 00 00       	call   80104335 <acquire>
    log.committing = 0;
801028b0:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
801028b7:	00 00 00 
    wakeup(&log);
801028ba:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028c1:	e8 30 0f 00 00       	call   801037f6 <wakeup>
    release(&log.lock);
801028c6:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028cd:	e8 c8 1a 00 00       	call   8010439a <release>
801028d2:	83 c4 10             	add    $0x10,%esp
}
801028d5:	eb a3                	jmp    8010287a <end_op+0x52>

801028d7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028d7:	55                   	push   %ebp
801028d8:	89 e5                	mov    %esp,%ebp
801028da:	53                   	push   %ebx
801028db:	83 ec 04             	sub    $0x4,%esp
801028de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801028e1:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
801028e7:	83 fa 1d             	cmp    $0x1d,%edx
801028ea:	7f 45                	jg     80102931 <log_write+0x5a>
801028ec:	a1 b8 26 11 80       	mov    0x801126b8,%eax
801028f1:	83 e8 01             	sub    $0x1,%eax
801028f4:	39 c2                	cmp    %eax,%edx
801028f6:	7d 39                	jge    80102931 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
801028f8:	83 3d bc 26 11 80 00 	cmpl   $0x0,0x801126bc
801028ff:	7e 3d                	jle    8010293e <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102901:	83 ec 0c             	sub    $0xc,%esp
80102904:	68 80 26 11 80       	push   $0x80112680
80102909:	e8 27 1a 00 00       	call   80104335 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010290e:	83 c4 10             	add    $0x10,%esp
80102911:	b8 00 00 00 00       	mov    $0x0,%eax
80102916:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
8010291c:	39 c2                	cmp    %eax,%edx
8010291e:	7e 2b                	jle    8010294b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102920:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102923:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
8010292a:	74 1f                	je     8010294b <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
8010292c:	83 c0 01             	add    $0x1,%eax
8010292f:	eb e5                	jmp    80102916 <log_write+0x3f>
    panic("too big a transaction");
80102931:	83 ec 0c             	sub    $0xc,%esp
80102934:	68 53 71 10 80       	push   $0x80107153
80102939:	e8 0a da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 69 71 10 80       	push   $0x80107169
80102946:	e8 fd d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
8010294b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010294e:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
  if (i == log.lh.n)
80102955:	39 c2                	cmp    %eax,%edx
80102957:	74 18                	je     80102971 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102959:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010295c:	83 ec 0c             	sub    $0xc,%esp
8010295f:	68 80 26 11 80       	push   $0x80112680
80102964:	e8 31 1a 00 00       	call   8010439a <release>
}
80102969:	83 c4 10             	add    $0x10,%esp
8010296c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010296f:	c9                   	leave  
80102970:	c3                   	ret    
    log.lh.n++;
80102971:	83 c2 01             	add    $0x1,%edx
80102974:	89 15 c8 26 11 80    	mov    %edx,0x801126c8
8010297a:	eb dd                	jmp    80102959 <log_write+0x82>

8010297c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010297c:	55                   	push   %ebp
8010297d:	89 e5                	mov    %esp,%ebp
8010297f:	53                   	push   %ebx
80102980:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102983:	68 8a 00 00 00       	push   $0x8a
80102988:	68 8c a4 10 80       	push   $0x8010a48c
8010298d:	68 00 70 00 80       	push   $0x80007000
80102992:	e8 c5 1a 00 00       	call   8010445c <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102997:	83 c4 10             	add    $0x10,%esp
8010299a:	bb 80 27 11 80       	mov    $0x80112780,%ebx
8010299f:	eb 06                	jmp    801029a7 <startothers+0x2b>
801029a1:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029a7:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
801029ae:	00 00 00 
801029b1:	05 80 27 11 80       	add    $0x80112780,%eax
801029b6:	39 d8                	cmp    %ebx,%eax
801029b8:	76 4c                	jbe    80102a06 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
801029ba:	e8 23 09 00 00       	call   801032e2 <mycpu>
801029bf:	39 d8                	cmp    %ebx,%eax
801029c1:	74 de                	je     801029a1 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029c3:	e8 f3 f6 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029c8:	05 00 10 00 00       	add    $0x1000,%eax
801029cd:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
801029d2:	c7 05 f8 6f 00 80 4a 	movl   $0x80102a4a,0x80006ff8
801029d9:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029dc:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
801029e3:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
801029e6:	83 ec 08             	sub    $0x8,%esp
801029e9:	68 00 70 00 00       	push   $0x7000
801029ee:	0f b6 03             	movzbl (%ebx),%eax
801029f1:	50                   	push   %eax
801029f2:	e8 c6 f9 ff ff       	call   801023bd <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801029f7:	83 c4 10             	add    $0x10,%esp
801029fa:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a00:	85 c0                	test   %eax,%eax
80102a02:	74 f6                	je     801029fa <startothers+0x7e>
80102a04:	eb 9b                	jmp    801029a1 <startothers+0x25>
      ;
  }
}
80102a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a09:	c9                   	leave  
80102a0a:	c3                   	ret    

80102a0b <mpmain>:
{
80102a0b:	55                   	push   %ebp
80102a0c:	89 e5                	mov    %esp,%ebp
80102a0e:	53                   	push   %ebx
80102a0f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a12:	e8 27 09 00 00       	call   8010333e <cpuid>
80102a17:	89 c3                	mov    %eax,%ebx
80102a19:	e8 20 09 00 00       	call   8010333e <cpuid>
80102a1e:	83 ec 04             	sub    $0x4,%esp
80102a21:	53                   	push   %ebx
80102a22:	50                   	push   %eax
80102a23:	68 84 71 10 80       	push   $0x80107184
80102a28:	e8 de db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a2d:	e8 f0 2b 00 00       	call   80105622 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a32:	e8 ab 08 00 00       	call   801032e2 <mycpu>
80102a37:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a39:	b8 01 00 00 00       	mov    $0x1,%eax
80102a3e:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a45:	e8 3e 13 00 00       	call   80103d88 <scheduler>

80102a4a <mpenter>:
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
80102a4d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a50:	e8 d6 3b 00 00       	call   8010662b <switchkvm>
  seginit();
80102a55:	e8 85 3a 00 00       	call   801064df <seginit>
  lapicinit();
80102a5a:	e8 15 f8 ff ff       	call   80102274 <lapicinit>
  mpmain();
80102a5f:	e8 a7 ff ff ff       	call   80102a0b <mpmain>

80102a64 <main>:
{
80102a64:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a68:	83 e4 f0             	and    $0xfffffff0,%esp
80102a6b:	ff 71 fc             	pushl  -0x4(%ecx)
80102a6e:	55                   	push   %ebp
80102a6f:	89 e5                	mov    %esp,%ebp
80102a71:	51                   	push   %ecx
80102a72:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a75:	68 00 00 40 80       	push   $0x80400000
80102a7a:	68 c8 71 11 80       	push   $0x801171c8
80102a7f:	e8 e5 f5 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102a84:	e8 2f 40 00 00       	call   80106ab8 <kvmalloc>
  mpinit();        // detect other processors
80102a89:	e8 c9 01 00 00       	call   80102c57 <mpinit>
  lapicinit();     // interrupt controller
80102a8e:	e8 e1 f7 ff ff       	call   80102274 <lapicinit>
  seginit();       // segment descriptors
80102a93:	e8 47 3a 00 00       	call   801064df <seginit>
  picinit();       // disable pic
80102a98:	e8 82 02 00 00       	call   80102d1f <picinit>
  ioapicinit();    // another interrupt controller
80102a9d:	e8 58 f4 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102aa2:	e8 e7 dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102aa7:	e8 24 2e 00 00       	call   801058d0 <uartinit>
  pinit();         // process table
80102aac:	e8 ef 07 00 00       	call   801032a0 <pinit>
  tvinit();        // trap vectors
80102ab1:	e8 bb 2a 00 00       	call   80105571 <tvinit>
  binit();         // buffer cache
80102ab6:	e8 39 d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102abb:	e8 53 e1 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102ac0:	e8 3b f2 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102ac5:	e8 b2 fe ff ff       	call   8010297c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102aca:	83 c4 08             	add    $0x8,%esp
80102acd:	68 00 00 00 8e       	push   $0x8e000000
80102ad2:	68 00 00 40 80       	push   $0x80400000
80102ad7:	e8 bf f5 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102adc:	e8 9c 08 00 00       	call   8010337d <userinit>
  mpmain();        // finish this processor's setup
80102ae1:	e8 25 ff ff ff       	call   80102a0b <mpmain>

80102ae6 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102ae6:	55                   	push   %ebp
80102ae7:	89 e5                	mov    %esp,%ebp
80102ae9:	56                   	push   %esi
80102aea:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102aeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102af0:	b9 00 00 00 00       	mov    $0x0,%ecx
80102af5:	eb 09                	jmp    80102b00 <sum+0x1a>
    sum += addr[i];
80102af7:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102afb:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102afd:	83 c1 01             	add    $0x1,%ecx
80102b00:	39 d1                	cmp    %edx,%ecx
80102b02:	7c f3                	jl     80102af7 <sum+0x11>
  return sum;
}
80102b04:	89 d8                	mov    %ebx,%eax
80102b06:	5b                   	pop    %ebx
80102b07:	5e                   	pop    %esi
80102b08:	5d                   	pop    %ebp
80102b09:	c3                   	ret    

80102b0a <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b0a:	55                   	push   %ebp
80102b0b:	89 e5                	mov    %esp,%ebp
80102b0d:	56                   	push   %esi
80102b0e:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102b0f:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102b15:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102b17:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b19:	eb 03                	jmp    80102b1e <mpsearch1+0x14>
80102b1b:	83 c3 10             	add    $0x10,%ebx
80102b1e:	39 f3                	cmp    %esi,%ebx
80102b20:	73 29                	jae    80102b4b <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b22:	83 ec 04             	sub    $0x4,%esp
80102b25:	6a 04                	push   $0x4
80102b27:	68 98 71 10 80       	push   $0x80107198
80102b2c:	53                   	push   %ebx
80102b2d:	e8 f5 18 00 00       	call   80104427 <memcmp>
80102b32:	83 c4 10             	add    $0x10,%esp
80102b35:	85 c0                	test   %eax,%eax
80102b37:	75 e2                	jne    80102b1b <mpsearch1+0x11>
80102b39:	ba 10 00 00 00       	mov    $0x10,%edx
80102b3e:	89 d8                	mov    %ebx,%eax
80102b40:	e8 a1 ff ff ff       	call   80102ae6 <sum>
80102b45:	84 c0                	test   %al,%al
80102b47:	75 d2                	jne    80102b1b <mpsearch1+0x11>
80102b49:	eb 05                	jmp    80102b50 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b50:	89 d8                	mov    %ebx,%eax
80102b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b55:	5b                   	pop    %ebx
80102b56:	5e                   	pop    %esi
80102b57:	5d                   	pop    %ebp
80102b58:	c3                   	ret    

80102b59 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b59:	55                   	push   %ebp
80102b5a:	89 e5                	mov    %esp,%ebp
80102b5c:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b5f:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b66:	c1 e0 08             	shl    $0x8,%eax
80102b69:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102b70:	09 d0                	or     %edx,%eax
80102b72:	c1 e0 04             	shl    $0x4,%eax
80102b75:	85 c0                	test   %eax,%eax
80102b77:	74 1f                	je     80102b98 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102b79:	ba 00 04 00 00       	mov    $0x400,%edx
80102b7e:	e8 87 ff ff ff       	call   80102b0a <mpsearch1>
80102b83:	85 c0                	test   %eax,%eax
80102b85:	75 0f                	jne    80102b96 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102b87:	ba 00 00 01 00       	mov    $0x10000,%edx
80102b8c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102b91:	e8 74 ff ff ff       	call   80102b0a <mpsearch1>
}
80102b96:	c9                   	leave  
80102b97:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102b98:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102b9f:	c1 e0 08             	shl    $0x8,%eax
80102ba2:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102ba9:	09 d0                	or     %edx,%eax
80102bab:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bae:	2d 00 04 00 00       	sub    $0x400,%eax
80102bb3:	ba 00 04 00 00       	mov    $0x400,%edx
80102bb8:	e8 4d ff ff ff       	call   80102b0a <mpsearch1>
80102bbd:	85 c0                	test   %eax,%eax
80102bbf:	75 d5                	jne    80102b96 <mpsearch+0x3d>
80102bc1:	eb c4                	jmp    80102b87 <mpsearch+0x2e>

80102bc3 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bc3:	55                   	push   %ebp
80102bc4:	89 e5                	mov    %esp,%ebp
80102bc6:	57                   	push   %edi
80102bc7:	56                   	push   %esi
80102bc8:	53                   	push   %ebx
80102bc9:	83 ec 1c             	sub    $0x1c,%esp
80102bcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102bcf:	e8 85 ff ff ff       	call   80102b59 <mpsearch>
80102bd4:	85 c0                	test   %eax,%eax
80102bd6:	74 5c                	je     80102c34 <mpconfig+0x71>
80102bd8:	89 c7                	mov    %eax,%edi
80102bda:	8b 58 04             	mov    0x4(%eax),%ebx
80102bdd:	85 db                	test   %ebx,%ebx
80102bdf:	74 5a                	je     80102c3b <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102be1:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102be7:	83 ec 04             	sub    $0x4,%esp
80102bea:	6a 04                	push   $0x4
80102bec:	68 9d 71 10 80       	push   $0x8010719d
80102bf1:	56                   	push   %esi
80102bf2:	e8 30 18 00 00       	call   80104427 <memcmp>
80102bf7:	83 c4 10             	add    $0x10,%esp
80102bfa:	85 c0                	test   %eax,%eax
80102bfc:	75 44                	jne    80102c42 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102bfe:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102c05:	3c 01                	cmp    $0x1,%al
80102c07:	0f 95 c2             	setne  %dl
80102c0a:	3c 04                	cmp    $0x4,%al
80102c0c:	0f 95 c0             	setne  %al
80102c0f:	84 c2                	test   %al,%dl
80102c11:	75 36                	jne    80102c49 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c13:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102c1a:	89 f0                	mov    %esi,%eax
80102c1c:	e8 c5 fe ff ff       	call   80102ae6 <sum>
80102c21:	84 c0                	test   %al,%al
80102c23:	75 2b                	jne    80102c50 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c28:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102c2a:	89 f0                	mov    %esi,%eax
80102c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c2f:	5b                   	pop    %ebx
80102c30:	5e                   	pop    %esi
80102c31:	5f                   	pop    %edi
80102c32:	5d                   	pop    %ebp
80102c33:	c3                   	ret    
    return 0;
80102c34:	be 00 00 00 00       	mov    $0x0,%esi
80102c39:	eb ef                	jmp    80102c2a <mpconfig+0x67>
80102c3b:	be 00 00 00 00       	mov    $0x0,%esi
80102c40:	eb e8                	jmp    80102c2a <mpconfig+0x67>
    return 0;
80102c42:	be 00 00 00 00       	mov    $0x0,%esi
80102c47:	eb e1                	jmp    80102c2a <mpconfig+0x67>
    return 0;
80102c49:	be 00 00 00 00       	mov    $0x0,%esi
80102c4e:	eb da                	jmp    80102c2a <mpconfig+0x67>
    return 0;
80102c50:	be 00 00 00 00       	mov    $0x0,%esi
80102c55:	eb d3                	jmp    80102c2a <mpconfig+0x67>

80102c57 <mpinit>:

void
mpinit(void)
{
80102c57:	55                   	push   %ebp
80102c58:	89 e5                	mov    %esp,%ebp
80102c5a:	57                   	push   %edi
80102c5b:	56                   	push   %esi
80102c5c:	53                   	push   %ebx
80102c5d:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c63:	e8 5b ff ff ff       	call   80102bc3 <mpconfig>
80102c68:	85 c0                	test   %eax,%eax
80102c6a:	74 19                	je     80102c85 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102c6c:	8b 50 24             	mov    0x24(%eax),%edx
80102c6f:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c75:	8d 50 2c             	lea    0x2c(%eax),%edx
80102c78:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102c7c:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102c7e:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c83:	eb 34                	jmp    80102cb9 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102c85:	83 ec 0c             	sub    $0xc,%esp
80102c88:	68 a2 71 10 80       	push   $0x801071a2
80102c8d:	e8 b6 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102c92:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
80102c98:	83 fe 07             	cmp    $0x7,%esi
80102c9b:	7f 19                	jg     80102cb6 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102c9d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102ca1:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102ca7:	88 87 80 27 11 80    	mov    %al,-0x7feed880(%edi)
        ncpu++;
80102cad:	83 c6 01             	add    $0x1,%esi
80102cb0:	89 35 00 2d 11 80    	mov    %esi,0x80112d00
      }
      p += sizeof(struct mpproc);
80102cb6:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cb9:	39 ca                	cmp    %ecx,%edx
80102cbb:	73 2b                	jae    80102ce8 <mpinit+0x91>
    switch(*p){
80102cbd:	0f b6 02             	movzbl (%edx),%eax
80102cc0:	3c 04                	cmp    $0x4,%al
80102cc2:	77 1d                	ja     80102ce1 <mpinit+0x8a>
80102cc4:	0f b6 c0             	movzbl %al,%eax
80102cc7:	ff 24 85 dc 71 10 80 	jmp    *-0x7fef8e24(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102cce:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cd2:	a2 60 27 11 80       	mov    %al,0x80112760
      p += sizeof(struct mpioapic);
80102cd7:	83 c2 08             	add    $0x8,%edx
      continue;
80102cda:	eb dd                	jmp    80102cb9 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102cdc:	83 c2 08             	add    $0x8,%edx
      continue;
80102cdf:	eb d8                	jmp    80102cb9 <mpinit+0x62>
    default:
      ismp = 0;
80102ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
80102ce6:	eb d1                	jmp    80102cb9 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102ce8:	85 db                	test   %ebx,%ebx
80102cea:	74 26                	je     80102d12 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102cef:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102cf3:	74 15                	je     80102d0a <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cf5:	b8 70 00 00 00       	mov    $0x70,%eax
80102cfa:	ba 22 00 00 00       	mov    $0x22,%edx
80102cff:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d00:	ba 23 00 00 00       	mov    $0x23,%edx
80102d05:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d06:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d09:	ee                   	out    %al,(%dx)
  }
}
80102d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d0d:	5b                   	pop    %ebx
80102d0e:	5e                   	pop    %esi
80102d0f:	5f                   	pop    %edi
80102d10:	5d                   	pop    %ebp
80102d11:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d12:	83 ec 0c             	sub    $0xc,%esp
80102d15:	68 bc 71 10 80       	push   $0x801071bc
80102d1a:	e8 29 d6 ff ff       	call   80100348 <panic>

80102d1f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d27:	ba 21 00 00 00       	mov    $0x21,%edx
80102d2c:	ee                   	out    %al,(%dx)
80102d2d:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d32:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d33:	5d                   	pop    %ebp
80102d34:	c3                   	ret    

80102d35 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d35:	55                   	push   %ebp
80102d36:	89 e5                	mov    %esp,%ebp
80102d38:	57                   	push   %edi
80102d39:	56                   	push   %esi
80102d3a:	53                   	push   %ebx
80102d3b:	83 ec 0c             	sub    $0xc,%esp
80102d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d41:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d44:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d4a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d50:	e8 d8 de ff ff       	call   80100c2d <filealloc>
80102d55:	89 03                	mov    %eax,(%ebx)
80102d57:	85 c0                	test   %eax,%eax
80102d59:	74 16                	je     80102d71 <pipealloc+0x3c>
80102d5b:	e8 cd de ff ff       	call   80100c2d <filealloc>
80102d60:	89 06                	mov    %eax,(%esi)
80102d62:	85 c0                	test   %eax,%eax
80102d64:	74 0b                	je     80102d71 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102d66:	e8 50 f3 ff ff       	call   801020bb <kalloc>
80102d6b:	89 c7                	mov    %eax,%edi
80102d6d:	85 c0                	test   %eax,%eax
80102d6f:	75 35                	jne    80102da6 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d71:	8b 03                	mov    (%ebx),%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	74 0c                	je     80102d83 <pipealloc+0x4e>
    fileclose(*f0);
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	50                   	push   %eax
80102d7b:	e8 53 df ff ff       	call   80100cd3 <fileclose>
80102d80:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d83:	8b 06                	mov    (%esi),%eax
80102d85:	85 c0                	test   %eax,%eax
80102d87:	0f 84 8b 00 00 00    	je     80102e18 <pipealloc+0xe3>
    fileclose(*f1);
80102d8d:	83 ec 0c             	sub    $0xc,%esp
80102d90:	50                   	push   %eax
80102d91:	e8 3d df ff ff       	call   80100cd3 <fileclose>
80102d96:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102da1:	5b                   	pop    %ebx
80102da2:	5e                   	pop    %esi
80102da3:	5f                   	pop    %edi
80102da4:	5d                   	pop    %ebp
80102da5:	c3                   	ret    
  p->readopen = 1;
80102da6:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102dad:	00 00 00 
  p->writeopen = 1;
80102db0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102db7:	00 00 00 
  p->nwrite = 0;
80102dba:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102dc1:	00 00 00 
  p->nread = 0;
80102dc4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102dcb:	00 00 00 
  initlock(&p->lock, "pipe");
80102dce:	83 ec 08             	sub    $0x8,%esp
80102dd1:	68 f0 71 10 80       	push   $0x801071f0
80102dd6:	50                   	push   %eax
80102dd7:	e8 1d 14 00 00       	call   801041f9 <initlock>
  (*f0)->type = FD_PIPE;
80102ddc:	8b 03                	mov    (%ebx),%eax
80102dde:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102de4:	8b 03                	mov    (%ebx),%eax
80102de6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102dea:	8b 03                	mov    (%ebx),%eax
80102dec:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102df0:	8b 03                	mov    (%ebx),%eax
80102df2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102df5:	8b 06                	mov    (%esi),%eax
80102df7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102dfd:	8b 06                	mov    (%esi),%eax
80102dff:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e03:	8b 06                	mov    (%esi),%eax
80102e05:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e09:	8b 06                	mov    (%esi),%eax
80102e0b:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e0e:	83 c4 10             	add    $0x10,%esp
80102e11:	b8 00 00 00 00       	mov    $0x0,%eax
80102e16:	eb 86                	jmp    80102d9e <pipealloc+0x69>
  return -1;
80102e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e1d:	e9 7c ff ff ff       	jmp    80102d9e <pipealloc+0x69>

80102e22 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e22:	55                   	push   %ebp
80102e23:	89 e5                	mov    %esp,%ebp
80102e25:	53                   	push   %ebx
80102e26:	83 ec 10             	sub    $0x10,%esp
80102e29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e2c:	53                   	push   %ebx
80102e2d:	e8 03 15 00 00       	call   80104335 <acquire>
  if(writable){
80102e32:	83 c4 10             	add    $0x10,%esp
80102e35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e39:	74 3f                	je     80102e7a <pipeclose+0x58>
    p->writeopen = 0;
80102e3b:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e42:	00 00 00 
    wakeup(&p->nread);
80102e45:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e4b:	83 ec 0c             	sub    $0xc,%esp
80102e4e:	50                   	push   %eax
80102e4f:	e8 a2 09 00 00       	call   801037f6 <wakeup>
80102e54:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e57:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e5e:	75 09                	jne    80102e69 <pipeclose+0x47>
80102e60:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e67:	74 2f                	je     80102e98 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e69:	83 ec 0c             	sub    $0xc,%esp
80102e6c:	53                   	push   %ebx
80102e6d:	e8 28 15 00 00       	call   8010439a <release>
80102e72:	83 c4 10             	add    $0x10,%esp
}
80102e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e78:	c9                   	leave  
80102e79:	c3                   	ret    
    p->readopen = 0;
80102e7a:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102e81:	00 00 00 
    wakeup(&p->nwrite);
80102e84:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e8a:	83 ec 0c             	sub    $0xc,%esp
80102e8d:	50                   	push   %eax
80102e8e:	e8 63 09 00 00       	call   801037f6 <wakeup>
80102e93:	83 c4 10             	add    $0x10,%esp
80102e96:	eb bf                	jmp    80102e57 <pipeclose+0x35>
    release(&p->lock);
80102e98:	83 ec 0c             	sub    $0xc,%esp
80102e9b:	53                   	push   %ebx
80102e9c:	e8 f9 14 00 00       	call   8010439a <release>
    kfree((char*)p);
80102ea1:	89 1c 24             	mov    %ebx,(%esp)
80102ea4:	e8 fb f0 ff ff       	call   80101fa4 <kfree>
80102ea9:	83 c4 10             	add    $0x10,%esp
80102eac:	eb c7                	jmp    80102e75 <pipeclose+0x53>

80102eae <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
80102eb1:	57                   	push   %edi
80102eb2:	56                   	push   %esi
80102eb3:	53                   	push   %ebx
80102eb4:	83 ec 18             	sub    $0x18,%esp
80102eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102eba:	89 de                	mov    %ebx,%esi
80102ebc:	53                   	push   %ebx
80102ebd:	e8 73 14 00 00       	call   80104335 <acquire>
  for(i = 0; i < n; i++){
80102ec2:	83 c4 10             	add    $0x10,%esp
80102ec5:	bf 00 00 00 00       	mov    $0x0,%edi
80102eca:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102ecd:	0f 8d 88 00 00 00    	jge    80102f5b <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ed3:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102ed9:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102edf:	05 00 02 00 00       	add    $0x200,%eax
80102ee4:	39 c2                	cmp    %eax,%edx
80102ee6:	75 51                	jne    80102f39 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102ee8:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102eef:	74 2f                	je     80102f20 <pipewrite+0x72>
80102ef1:	e8 63 04 00 00       	call   80103359 <myproc>
80102ef6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102efa:	75 24                	jne    80102f20 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102efc:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f02:	83 ec 0c             	sub    $0xc,%esp
80102f05:	50                   	push   %eax
80102f06:	e8 eb 08 00 00       	call   801037f6 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f0b:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f11:	83 c4 08             	add    $0x8,%esp
80102f14:	56                   	push   %esi
80102f15:	50                   	push   %eax
80102f16:	e8 73 07 00 00       	call   8010368e <sleep>
80102f1b:	83 c4 10             	add    $0x10,%esp
80102f1e:	eb b3                	jmp    80102ed3 <pipewrite+0x25>
        release(&p->lock);
80102f20:	83 ec 0c             	sub    $0xc,%esp
80102f23:	53                   	push   %ebx
80102f24:	e8 71 14 00 00       	call   8010439a <release>
        return -1;
80102f29:	83 c4 10             	add    $0x10,%esp
80102f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f34:	5b                   	pop    %ebx
80102f35:	5e                   	pop    %esi
80102f36:	5f                   	pop    %edi
80102f37:	5d                   	pop    %ebp
80102f38:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f39:	8d 42 01             	lea    0x1(%edx),%eax
80102f3c:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f42:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f4b:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f4f:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f53:	83 c7 01             	add    $0x1,%edi
80102f56:	e9 6f ff ff ff       	jmp    80102eca <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f5b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f61:	83 ec 0c             	sub    $0xc,%esp
80102f64:	50                   	push   %eax
80102f65:	e8 8c 08 00 00       	call   801037f6 <wakeup>
  release(&p->lock);
80102f6a:	89 1c 24             	mov    %ebx,(%esp)
80102f6d:	e8 28 14 00 00       	call   8010439a <release>
  return n;
80102f72:	83 c4 10             	add    $0x10,%esp
80102f75:	8b 45 10             	mov    0x10(%ebp),%eax
80102f78:	eb b7                	jmp    80102f31 <pipewrite+0x83>

80102f7a <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102f7a:	55                   	push   %ebp
80102f7b:	89 e5                	mov    %esp,%ebp
80102f7d:	57                   	push   %edi
80102f7e:	56                   	push   %esi
80102f7f:	53                   	push   %ebx
80102f80:	83 ec 18             	sub    $0x18,%esp
80102f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f86:	89 df                	mov    %ebx,%edi
80102f88:	53                   	push   %ebx
80102f89:	e8 a7 13 00 00       	call   80104335 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102f8e:	83 c4 10             	add    $0x10,%esp
80102f91:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102f97:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102f9d:	75 3d                	jne    80102fdc <piperead+0x62>
80102f9f:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fa5:	85 f6                	test   %esi,%esi
80102fa7:	74 38                	je     80102fe1 <piperead+0x67>
    if(myproc()->killed){
80102fa9:	e8 ab 03 00 00       	call   80103359 <myproc>
80102fae:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fb2:	75 15                	jne    80102fc9 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fb4:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	57                   	push   %edi
80102fbe:	50                   	push   %eax
80102fbf:	e8 ca 06 00 00       	call   8010368e <sleep>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	eb c8                	jmp    80102f91 <piperead+0x17>
      release(&p->lock);
80102fc9:	83 ec 0c             	sub    $0xc,%esp
80102fcc:	53                   	push   %ebx
80102fcd:	e8 c8 13 00 00       	call   8010439a <release>
      return -1;
80102fd2:	83 c4 10             	add    $0x10,%esp
80102fd5:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102fda:	eb 50                	jmp    8010302c <piperead+0xb2>
80102fdc:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102fe1:	3b 75 10             	cmp    0x10(%ebp),%esi
80102fe4:	7d 2c                	jge    80103012 <piperead+0x98>
    if(p->nread == p->nwrite)
80102fe6:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102fec:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102ff2:	74 1e                	je     80103012 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102ff4:	8d 50 01             	lea    0x1(%eax),%edx
80102ff7:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102ffd:	25 ff 01 00 00       	and    $0x1ff,%eax
80103002:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103007:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010300a:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010300d:	83 c6 01             	add    $0x1,%esi
80103010:	eb cf                	jmp    80102fe1 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103012:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103018:	83 ec 0c             	sub    $0xc,%esp
8010301b:	50                   	push   %eax
8010301c:	e8 d5 07 00 00       	call   801037f6 <wakeup>
  release(&p->lock);
80103021:	89 1c 24             	mov    %ebx,(%esp)
80103024:	e8 71 13 00 00       	call   8010439a <release>
  return i;
80103029:	83 c4 10             	add    $0x10,%esp
}
8010302c:	89 f0                	mov    %esi,%eax
8010302e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103031:	5b                   	pop    %ebx
80103032:	5e                   	pop    %esi
80103033:	5f                   	pop    %edi
80103034:	5d                   	pop    %ebp
80103035:	c3                   	ret    

80103036 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;
  int y;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103036:	ba 54 39 11 80       	mov    $0x80113954,%edx
8010303b:	e9 8c 00 00 00       	jmp    801030cc <wakeup1+0x96>
        if(ptable.queue[p->priority][y] == p->pid) {
          break;
	}
      }
      for(int k=y; k < ptable.priorityLevelCount[p->priority]; k++) {
        ptable.queue[p->priority][k] = ptable.queue[p->priority][k+1];
80103040:	8d 71 01             	lea    0x1(%ecx),%esi
80103043:	c1 e3 06             	shl    $0x6,%ebx
80103046:	8d bc 1e 0c 0b 00 00 	lea    0xb0c(%esi,%ebx,1),%edi
8010304d:	8b 3c bd 24 39 11 80 	mov    -0x7feec6dc(,%edi,4),%edi
80103054:	8d 8c 19 0c 0b 00 00 	lea    0xb0c(%ecx,%ebx,1),%ecx
8010305b:	89 3c 8d 24 39 11 80 	mov    %edi,-0x7feec6dc(,%ecx,4)
      for(int k=y; k < ptable.priorityLevelCount[p->priority]; k++) {
80103062:	89 f1                	mov    %esi,%ecx
80103064:	8b 5a 7c             	mov    0x7c(%edx),%ebx
80103067:	8b 34 9d 54 69 11 80 	mov    -0x7fee96ac(,%ebx,4),%esi
8010306e:	39 ce                	cmp    %ecx,%esi
80103070:	7f ce                	jg     80103040 <wakeup1+0xa>
      }
      //cprintf("%s woken \n", p->name);
      //ptable.priorityLevelCount[p->priority]++;
      ptable.queue[p->priority][ptable.priorityLevelCount[p->priority]] = p->pid;
80103072:	8b 4a 10             	mov    0x10(%edx),%ecx
80103075:	c1 e3 06             	shl    $0x6,%ebx
80103078:	8d 9c 1e 0c 0b 00 00 	lea    0xb0c(%esi,%ebx,1),%ebx
8010307f:	89 0c 9d 24 39 11 80 	mov    %ecx,-0x7feec6dc(,%ebx,4)
      //cprintf("Woken up. Qtail updated.\n");
      if(p->time[p->priority] != 1) {
80103086:	8b 4a 7c             	mov    0x7c(%edx),%ecx
80103089:	83 bc 8a a0 00 00 00 	cmpl   $0x1,0xa0(%edx,%ecx,4)
80103090:	01 
80103091:	74 0c                	je     8010309f <wakeup1+0x69>
          p->qtail[p->priority] = p->qtail[p->priority] + 1;     
80103093:	83 c1 20             	add    $0x20,%ecx
80103096:	8b 34 8a             	mov    (%edx,%ecx,4),%esi
80103099:	8d 5e 01             	lea    0x1(%esi),%ebx
8010309c:	89 1c 8a             	mov    %ebx,(%edx,%ecx,4)
      } 
      p->state = RUNNABLE;
8010309f:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030a6:	81 c2 b0 00 00 00    	add    $0xb0,%edx
801030ac:	81 fa 54 65 11 80    	cmp    $0x80116554,%edx
801030b2:	73 0d                	jae    801030c1 <wakeup1+0x8b>
    if(p->state == SLEEPING && p->chan == chan) {
801030b4:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801030b8:	75 ec                	jne    801030a6 <wakeup1+0x70>
801030ba:	39 42 20             	cmp    %eax,0x20(%edx)
801030bd:	75 e7                	jne    801030a6 <wakeup1+0x70>
801030bf:	eb 24                	jmp    801030e5 <wakeup1+0xaf>
    }
}
801030c1:	5b                   	pop    %ebx
801030c2:	5e                   	pop    %esi
801030c3:	5f                   	pop    %edi
801030c4:	5d                   	pop    %ebp
801030c5:	c3                   	ret    
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030c6:	81 c2 b0 00 00 00    	add    $0xb0,%edx
801030cc:	81 fa 54 65 11 80    	cmp    $0x80116554,%edx
801030d2:	73 45                	jae    80103119 <wakeup1+0xe3>
    if(p->state == SLEEPING && p->chan == chan) {
801030d4:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801030d8:	75 ec                	jne    801030c6 <wakeup1+0x90>
801030da:	39 42 20             	cmp    %eax,0x20(%edx)
801030dd:	75 e7                	jne    801030c6 <wakeup1+0x90>
{
801030df:	55                   	push   %ebp
801030e0:	89 e5                	mov    %esp,%ebp
801030e2:	57                   	push   %edi
801030e3:	56                   	push   %esi
801030e4:	53                   	push   %ebx
      for(y = 0; y < ptable.priorityLevelCount[p->priority]; y++) {
801030e5:	b9 00 00 00 00       	mov    $0x0,%ecx
801030ea:	8b 5a 7c             	mov    0x7c(%edx),%ebx
801030ed:	39 0c 9d 54 69 11 80 	cmp    %ecx,-0x7fee96ac(,%ebx,4)
801030f4:	0f 8e 6a ff ff ff    	jle    80103064 <wakeup1+0x2e>
        if(ptable.queue[p->priority][y] == p->pid) {
801030fa:	c1 e3 06             	shl    $0x6,%ebx
801030fd:	8d 9c 19 0c 0b 00 00 	lea    0xb0c(%ecx,%ebx,1),%ebx
80103104:	8b 7a 10             	mov    0x10(%edx),%edi
80103107:	39 3c 9d 24 39 11 80 	cmp    %edi,-0x7feec6dc(,%ebx,4)
8010310e:	0f 84 50 ff ff ff    	je     80103064 <wakeup1+0x2e>
      for(y = 0; y < ptable.priorityLevelCount[p->priority]; y++) {
80103114:	83 c1 01             	add    $0x1,%ecx
80103117:	eb d1                	jmp    801030ea <wakeup1+0xb4>
80103119:	c3                   	ret    

8010311a <allocproc>:
{
8010311a:	55                   	push   %ebp
8010311b:	89 e5                	mov    %esp,%ebp
8010311d:	53                   	push   %ebx
8010311e:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103121:	68 20 39 11 80       	push   $0x80113920
80103126:	e8 0a 12 00 00       	call   80104335 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010312b:	83 c4 10             	add    $0x10,%esp
8010312e:	bb 54 39 11 80       	mov    $0x80113954,%ebx
80103133:	81 fb 54 65 11 80    	cmp    $0x80116554,%ebx
80103139:	73 0e                	jae    80103149 <allocproc+0x2f>
    if(p->state == UNUSED)
8010313b:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010313f:	74 22                	je     80103163 <allocproc+0x49>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103141:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103147:	eb ea                	jmp    80103133 <allocproc+0x19>
  release(&ptable.lock);
80103149:	83 ec 0c             	sub    $0xc,%esp
8010314c:	68 20 39 11 80       	push   $0x80113920
80103151:	e8 44 12 00 00       	call   8010439a <release>
  return 0;
80103156:	83 c4 10             	add    $0x10,%esp
80103159:	bb 00 00 00 00       	mov    $0x0,%ebx
8010315e:	e9 e5 00 00 00       	jmp    80103248 <allocproc+0x12e>
  p->state = EMBRYO;
80103163:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
8010316a:	a1 14 a0 10 80       	mov    0x8010a014,%eax
8010316f:	8d 50 01             	lea    0x1(%eax),%edx
80103172:	89 15 14 a0 10 80    	mov    %edx,0x8010a014
80103178:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 39 11 80       	push   $0x80113920
80103183:	e8 12 12 00 00       	call   8010439a <release>
  if((p->kstack = kalloc()) == 0){
80103188:	e8 2e ef ff ff       	call   801020bb <kalloc>
8010318d:	89 43 08             	mov    %eax,0x8(%ebx)
80103190:	83 c4 10             	add    $0x10,%esp
80103193:	85 c0                	test   %eax,%eax
80103195:	0f 84 b4 00 00 00    	je     8010324f <allocproc+0x135>
  sp -= sizeof *p->tf;
8010319b:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801031a1:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801031a4:	c7 80 b0 0f 00 00 66 	movl   $0x80105566,0xfb0(%eax)
801031ab:	55 10 80 
  sp -= sizeof *p->context;
801031ae:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801031b3:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801031b6:	83 ec 04             	sub    $0x4,%esp
801031b9:	6a 14                	push   $0x14
801031bb:	6a 00                	push   $0x0
801031bd:	50                   	push   %eax
801031be:	e8 1e 12 00 00       	call   801043e1 <memset>
  p->context->eip = (uint)forkret;
801031c3:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031c6:	c7 40 10 5d 32 10 80 	movl   $0x8010325d,0x10(%eax)
  p->ticks[0] = 0;
801031cd:	c7 83 90 00 00 00 00 	movl   $0x0,0x90(%ebx)
801031d4:	00 00 00 
  p->ticks[1] = 0;
801031d7:	c7 83 94 00 00 00 00 	movl   $0x0,0x94(%ebx)
801031de:	00 00 00 
  p->ticks[2] = 0;
801031e1:	c7 83 98 00 00 00 00 	movl   $0x0,0x98(%ebx)
801031e8:	00 00 00 
  p->ticks[3] = 0;
801031eb:	c7 83 9c 00 00 00 00 	movl   $0x0,0x9c(%ebx)
801031f2:	00 00 00 
  p->qtail[0] = 0;
801031f5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
801031fc:	00 00 00 
  p->qtail[1] = 0;
801031ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
80103206:	00 00 00 
  p->qtail[2] = 0;
80103209:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
80103210:	00 00 00 
  p->qtail[3] = 0;
80103213:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
8010321a:	00 00 00 
  p->time[0] = 20;
8010321d:	c7 83 a0 00 00 00 14 	movl   $0x14,0xa0(%ebx)
80103224:	00 00 00 
  p->time[1] = 16;
80103227:	c7 83 a4 00 00 00 10 	movl   $0x10,0xa4(%ebx)
8010322e:	00 00 00 
  p->time[2] = 12;
80103231:	c7 83 a8 00 00 00 0c 	movl   $0xc,0xa8(%ebx)
80103238:	00 00 00 
  p->time[3] = 8;
8010323b:	c7 83 ac 00 00 00 08 	movl   $0x8,0xac(%ebx)
80103242:	00 00 00 
  return p;
80103245:	83 c4 10             	add    $0x10,%esp
}
80103248:	89 d8                	mov    %ebx,%eax
8010324a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010324d:	c9                   	leave  
8010324e:	c3                   	ret    
    p->state = UNUSED;
8010324f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103256:	bb 00 00 00 00       	mov    $0x0,%ebx
8010325b:	eb eb                	jmp    80103248 <allocproc+0x12e>

8010325d <forkret>:
{
8010325d:	55                   	push   %ebp
8010325e:	89 e5                	mov    %esp,%ebp
80103260:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103263:	68 20 39 11 80       	push   $0x80113920
80103268:	e8 2d 11 00 00       	call   8010439a <release>
  if (first) {
8010326d:	83 c4 10             	add    $0x10,%esp
80103270:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103277:	75 02                	jne    8010327b <forkret+0x1e>
}
80103279:	c9                   	leave  
8010327a:	c3                   	ret    
    first = 0;
8010327b:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103282:	00 00 00 
    iinit(ROOTDEV);
80103285:	83 ec 0c             	sub    $0xc,%esp
80103288:	6a 01                	push   $0x1
8010328a:	e8 5d e0 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
8010328f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103296:	e8 ca f4 ff ff       	call   80102765 <initlog>
8010329b:	83 c4 10             	add    $0x10,%esp
}
8010329e:	eb d9                	jmp    80103279 <forkret+0x1c>

801032a0 <pinit>:
{
801032a0:	55                   	push   %ebp
801032a1:	89 e5                	mov    %esp,%ebp
801032a3:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801032a6:	68 f5 71 10 80       	push   $0x801071f5
801032ab:	68 20 39 11 80       	push   $0x80113920
801032b0:	e8 44 0f 00 00       	call   801041f9 <initlock>
  ptable.priorityLevelCount[0] = -1;
801032b5:	c7 05 54 69 11 80 ff 	movl   $0xffffffff,0x80116954
801032bc:	ff ff ff 
  ptable.priorityLevelCount[1] = -1;
801032bf:	c7 05 58 69 11 80 ff 	movl   $0xffffffff,0x80116958
801032c6:	ff ff ff 
  ptable.priorityLevelCount[2] = -1;
801032c9:	c7 05 5c 69 11 80 ff 	movl   $0xffffffff,0x8011695c
801032d0:	ff ff ff 
  ptable.priorityLevelCount[3] = -1;
801032d3:	c7 05 60 69 11 80 ff 	movl   $0xffffffff,0x80116960
801032da:	ff ff ff 
}
801032dd:	83 c4 10             	add    $0x10,%esp
801032e0:	c9                   	leave  
801032e1:	c3                   	ret    

801032e2 <mycpu>:
{
801032e2:	55                   	push   %ebp
801032e3:	89 e5                	mov    %esp,%ebp
801032e5:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801032e8:	9c                   	pushf  
801032e9:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801032ea:	f6 c4 02             	test   $0x2,%ah
801032ed:	75 28                	jne    80103317 <mycpu+0x35>
  apicid = lapicid();
801032ef:	e8 8a f0 ff ff       	call   8010237e <lapicid>
  for (i = 0; i < ncpu; ++i) {
801032f4:	ba 00 00 00 00       	mov    $0x0,%edx
801032f9:	39 15 00 2d 11 80    	cmp    %edx,0x80112d00
801032ff:	7e 23                	jle    80103324 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103301:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103307:	0f b6 89 80 27 11 80 	movzbl -0x7feed880(%ecx),%ecx
8010330e:	39 c1                	cmp    %eax,%ecx
80103310:	74 1f                	je     80103331 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103312:	83 c2 01             	add    $0x1,%edx
80103315:	eb e2                	jmp    801032f9 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103317:	83 ec 0c             	sub    $0xc,%esp
8010331a:	68 f0 72 10 80       	push   $0x801072f0
8010331f:	e8 24 d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103324:	83 ec 0c             	sub    $0xc,%esp
80103327:	68 fc 71 10 80       	push   $0x801071fc
8010332c:	e8 17 d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
80103331:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103337:	05 80 27 11 80       	add    $0x80112780,%eax
}
8010333c:	c9                   	leave  
8010333d:	c3                   	ret    

8010333e <cpuid>:
cpuid() {
8010333e:	55                   	push   %ebp
8010333f:	89 e5                	mov    %esp,%ebp
80103341:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103344:	e8 99 ff ff ff       	call   801032e2 <mycpu>
80103349:	2d 80 27 11 80       	sub    $0x80112780,%eax
8010334e:	c1 f8 04             	sar    $0x4,%eax
80103351:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103357:	c9                   	leave  
80103358:	c3                   	ret    

80103359 <myproc>:
myproc(void) {
80103359:	55                   	push   %ebp
8010335a:	89 e5                	mov    %esp,%ebp
8010335c:	53                   	push   %ebx
8010335d:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103360:	e8 f3 0e 00 00       	call   80104258 <pushcli>
  c = mycpu();
80103365:	e8 78 ff ff ff       	call   801032e2 <mycpu>
  p = c->proc;
8010336a:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103370:	e8 20 0f 00 00       	call   80104295 <popcli>
}
80103375:	89 d8                	mov    %ebx,%eax
80103377:	83 c4 04             	add    $0x4,%esp
8010337a:	5b                   	pop    %ebx
8010337b:	5d                   	pop    %ebp
8010337c:	c3                   	ret    

8010337d <userinit>:
{
8010337d:	55                   	push   %ebp
8010337e:	89 e5                	mov    %esp,%ebp
80103380:	53                   	push   %ebx
80103381:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103384:	e8 91 fd ff ff       	call   8010311a <allocproc>
80103389:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010338b:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
80103390:	e8 b5 36 00 00       	call   80106a4a <setupkvm>
80103395:	89 43 04             	mov    %eax,0x4(%ebx)
80103398:	85 c0                	test   %eax,%eax
8010339a:	0f 84 d6 00 00 00    	je     80103476 <userinit+0xf9>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801033a0:	83 ec 04             	sub    $0x4,%esp
801033a3:	68 2c 00 00 00       	push   $0x2c
801033a8:	68 60 a4 10 80       	push   $0x8010a460
801033ad:	50                   	push   %eax
801033ae:	e8 a2 33 00 00       	call   80106755 <inituvm>
  p->sz = PGSIZE;
801033b3:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033b9:	83 c4 0c             	add    $0xc,%esp
801033bc:	6a 4c                	push   $0x4c
801033be:	6a 00                	push   $0x0
801033c0:	ff 73 18             	pushl  0x18(%ebx)
801033c3:	e8 19 10 00 00       	call   801043e1 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801033c8:	8b 43 18             	mov    0x18(%ebx),%eax
801033cb:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801033d1:	8b 43 18             	mov    0x18(%ebx),%eax
801033d4:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801033da:	8b 43 18             	mov    0x18(%ebx),%eax
801033dd:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033e1:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801033e5:	8b 43 18             	mov    0x18(%ebx),%eax
801033e8:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033ec:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801033f0:	8b 43 18             	mov    0x18(%ebx),%eax
801033f3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801033fa:	8b 43 18             	mov    0x18(%ebx),%eax
801033fd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103404:	8b 43 18             	mov    0x18(%ebx),%eax
80103407:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010340e:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103411:	83 c4 0c             	add    $0xc,%esp
80103414:	6a 10                	push   $0x10
80103416:	68 25 72 10 80       	push   $0x80107225
8010341b:	50                   	push   %eax
8010341c:	e8 27 11 00 00       	call   80104548 <safestrcpy>
  p->cwd = namei("/");
80103421:	c7 04 24 2e 72 10 80 	movl   $0x8010722e,(%esp)
80103428:	e8 b4 e7 ff ff       	call   80101be1 <namei>
8010342d:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103430:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80103437:	e8 f9 0e 00 00       	call   80104335 <acquire>
  p->state = RUNNABLE;
8010343c:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->priority = 3;
80103443:	c7 43 7c 03 00 00 00 	movl   $0x3,0x7c(%ebx)
  ptable.priorityLevelCount[3]++;
8010344a:	a1 60 69 11 80       	mov    0x80116960,%eax
8010344f:	8d 50 01             	lea    0x1(%eax),%edx
80103452:	89 15 60 69 11 80    	mov    %edx,0x80116960
  ptable.queue[3][ptable.priorityLevelCount[3]] = p->pid;
80103458:	8b 53 10             	mov    0x10(%ebx),%edx
8010345b:	89 14 85 58 68 11 80 	mov    %edx,-0x7fee97a8(,%eax,4)
  release(&ptable.lock);
80103462:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80103469:	e8 2c 0f 00 00       	call   8010439a <release>
}
8010346e:	83 c4 10             	add    $0x10,%esp
80103471:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103474:	c9                   	leave  
80103475:	c3                   	ret    
    panic("userinit: out of memory?");
80103476:	83 ec 0c             	sub    $0xc,%esp
80103479:	68 0c 72 10 80       	push   $0x8010720c
8010347e:	e8 c5 ce ff ff       	call   80100348 <panic>

80103483 <growproc>:
{
80103483:	55                   	push   %ebp
80103484:	89 e5                	mov    %esp,%ebp
80103486:	56                   	push   %esi
80103487:	53                   	push   %ebx
80103488:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010348b:	e8 c9 fe ff ff       	call   80103359 <myproc>
80103490:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103492:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103494:	85 f6                	test   %esi,%esi
80103496:	7f 21                	jg     801034b9 <growproc+0x36>
  } else if(n < 0){
80103498:	85 f6                	test   %esi,%esi
8010349a:	79 33                	jns    801034cf <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010349c:	83 ec 04             	sub    $0x4,%esp
8010349f:	01 c6                	add    %eax,%esi
801034a1:	56                   	push   %esi
801034a2:	50                   	push   %eax
801034a3:	ff 73 04             	pushl  0x4(%ebx)
801034a6:	e8 b3 33 00 00       	call   8010685e <deallocuvm>
801034ab:	83 c4 10             	add    $0x10,%esp
801034ae:	85 c0                	test   %eax,%eax
801034b0:	75 1d                	jne    801034cf <growproc+0x4c>
      return -1;
801034b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034b7:	eb 29                	jmp    801034e2 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034b9:	83 ec 04             	sub    $0x4,%esp
801034bc:	01 c6                	add    %eax,%esi
801034be:	56                   	push   %esi
801034bf:	50                   	push   %eax
801034c0:	ff 73 04             	pushl  0x4(%ebx)
801034c3:	e8 28 34 00 00       	call   801068f0 <allocuvm>
801034c8:	83 c4 10             	add    $0x10,%esp
801034cb:	85 c0                	test   %eax,%eax
801034cd:	74 1a                	je     801034e9 <growproc+0x66>
  curproc->sz = sz;
801034cf:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801034d1:	83 ec 0c             	sub    $0xc,%esp
801034d4:	53                   	push   %ebx
801034d5:	e8 63 31 00 00       	call   8010663d <switchuvm>
  return 0;
801034da:	83 c4 10             	add    $0x10,%esp
801034dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801034e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034e5:	5b                   	pop    %ebx
801034e6:	5e                   	pop    %esi
801034e7:	5d                   	pop    %ebp
801034e8:	c3                   	ret    
      return -1;
801034e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034ee:	eb f2                	jmp    801034e2 <growproc+0x5f>

801034f0 <sched>:
{
801034f0:	55                   	push   %ebp
801034f1:	89 e5                	mov    %esp,%ebp
801034f3:	56                   	push   %esi
801034f4:	53                   	push   %ebx
  struct proc *p = myproc();
801034f5:	e8 5f fe ff ff       	call   80103359 <myproc>
801034fa:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801034fc:	83 ec 0c             	sub    $0xc,%esp
801034ff:	68 20 39 11 80       	push   $0x80113920
80103504:	e8 ec 0d 00 00       	call   801042f5 <holding>
80103509:	83 c4 10             	add    $0x10,%esp
8010350c:	85 c0                	test   %eax,%eax
8010350e:	74 4f                	je     8010355f <sched+0x6f>
  if(mycpu()->ncli != 1)
80103510:	e8 cd fd ff ff       	call   801032e2 <mycpu>
80103515:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010351c:	75 4e                	jne    8010356c <sched+0x7c>
  if(p->state == RUNNING)
8010351e:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103522:	74 55                	je     80103579 <sched+0x89>
80103524:	9c                   	pushf  
80103525:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103526:	f6 c4 02             	test   $0x2,%ah
80103529:	75 5b                	jne    80103586 <sched+0x96>
  intena = mycpu()->intena;
8010352b:	e8 b2 fd ff ff       	call   801032e2 <mycpu>
80103530:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103536:	e8 a7 fd ff ff       	call   801032e2 <mycpu>
8010353b:	83 ec 08             	sub    $0x8,%esp
8010353e:	ff 70 04             	pushl  0x4(%eax)
80103541:	83 c3 1c             	add    $0x1c,%ebx
80103544:	53                   	push   %ebx
80103545:	e8 51 10 00 00       	call   8010459b <swtch>
  mycpu()->intena = intena;
8010354a:	e8 93 fd ff ff       	call   801032e2 <mycpu>
8010354f:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103555:	83 c4 10             	add    $0x10,%esp
80103558:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010355b:	5b                   	pop    %ebx
8010355c:	5e                   	pop    %esi
8010355d:	5d                   	pop    %ebp
8010355e:	c3                   	ret    
    panic("sched ptable.lock");
8010355f:	83 ec 0c             	sub    $0xc,%esp
80103562:	68 30 72 10 80       	push   $0x80107230
80103567:	e8 dc cd ff ff       	call   80100348 <panic>
    panic("sched locks");
8010356c:	83 ec 0c             	sub    $0xc,%esp
8010356f:	68 42 72 10 80       	push   $0x80107242
80103574:	e8 cf cd ff ff       	call   80100348 <panic>
    panic("sched running");
80103579:	83 ec 0c             	sub    $0xc,%esp
8010357c:	68 4e 72 10 80       	push   $0x8010724e
80103581:	e8 c2 cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103586:	83 ec 0c             	sub    $0xc,%esp
80103589:	68 5c 72 10 80       	push   $0x8010725c
8010358e:	e8 b5 cd ff ff       	call   80100348 <panic>

80103593 <exit>:
{
80103593:	55                   	push   %ebp
80103594:	89 e5                	mov    %esp,%ebp
80103596:	56                   	push   %esi
80103597:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103598:	e8 bc fd ff ff       	call   80103359 <myproc>
  if(curproc == initproc)
8010359d:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
801035a3:	74 09                	je     801035ae <exit+0x1b>
801035a5:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801035a7:	bb 00 00 00 00       	mov    $0x0,%ebx
801035ac:	eb 10                	jmp    801035be <exit+0x2b>
    panic("init exiting");
801035ae:	83 ec 0c             	sub    $0xc,%esp
801035b1:	68 70 72 10 80       	push   $0x80107270
801035b6:	e8 8d cd ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801035bb:	83 c3 01             	add    $0x1,%ebx
801035be:	83 fb 0f             	cmp    $0xf,%ebx
801035c1:	7f 1e                	jg     801035e1 <exit+0x4e>
    if(curproc->ofile[fd]){
801035c3:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801035c7:	85 c0                	test   %eax,%eax
801035c9:	74 f0                	je     801035bb <exit+0x28>
      fileclose(curproc->ofile[fd]);
801035cb:	83 ec 0c             	sub    $0xc,%esp
801035ce:	50                   	push   %eax
801035cf:	e8 ff d6 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
801035d4:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801035db:	00 
801035dc:	83 c4 10             	add    $0x10,%esp
801035df:	eb da                	jmp    801035bb <exit+0x28>
  begin_op();
801035e1:	e8 c8 f1 ff ff       	call   801027ae <begin_op>
  iput(curproc->cwd);
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	ff 76 68             	pushl  0x68(%esi)
801035ec:	e8 97 e0 ff ff       	call   80101688 <iput>
  end_op();
801035f1:	e8 32 f2 ff ff       	call   80102828 <end_op>
  curproc->cwd = 0;
801035f6:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801035fd:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80103604:	e8 2c 0d 00 00       	call   80104335 <acquire>
  wakeup1(curproc->parent);
80103609:	8b 46 14             	mov    0x14(%esi),%eax
8010360c:	e8 25 fa ff ff       	call   80103036 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103611:	83 c4 10             	add    $0x10,%esp
80103614:	bb 54 39 11 80       	mov    $0x80113954,%ebx
80103619:	eb 06                	jmp    80103621 <exit+0x8e>
8010361b:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103621:	81 fb 54 65 11 80    	cmp    $0x80116554,%ebx
80103627:	73 1a                	jae    80103643 <exit+0xb0>
    if(p->parent == curproc){
80103629:	39 73 14             	cmp    %esi,0x14(%ebx)
8010362c:	75 ed                	jne    8010361b <exit+0x88>
      p->parent = initproc;
8010362e:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80103633:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103636:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010363a:	75 df                	jne    8010361b <exit+0x88>
        wakeup1(initproc);
8010363c:	e8 f5 f9 ff ff       	call   80103036 <wakeup1>
80103641:	eb d8                	jmp    8010361b <exit+0x88>
  curproc->state = ZOMBIE;
80103643:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010364a:	e8 a1 fe ff ff       	call   801034f0 <sched>
  panic("zombie exit");
8010364f:	83 ec 0c             	sub    $0xc,%esp
80103652:	68 7d 72 10 80       	push   $0x8010727d
80103657:	e8 ec cc ff ff       	call   80100348 <panic>

8010365c <yield>:
{
8010365c:	55                   	push   %ebp
8010365d:	89 e5                	mov    %esp,%ebp
8010365f:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103662:	68 20 39 11 80       	push   $0x80113920
80103667:	e8 c9 0c 00 00       	call   80104335 <acquire>
  myproc()->state = RUNNABLE;
8010366c:	e8 e8 fc ff ff       	call   80103359 <myproc>
80103671:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103678:	e8 73 fe ff ff       	call   801034f0 <sched>
  release(&ptable.lock);
8010367d:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80103684:	e8 11 0d 00 00       	call   8010439a <release>
}
80103689:	83 c4 10             	add    $0x10,%esp
8010368c:	c9                   	leave  
8010368d:	c3                   	ret    

8010368e <sleep>:
{
8010368e:	55                   	push   %ebp
8010368f:	89 e5                	mov    %esp,%ebp
80103691:	56                   	push   %esi
80103692:	53                   	push   %ebx
80103693:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103696:	e8 be fc ff ff       	call   80103359 <myproc>
  if(p == 0)
8010369b:	85 c0                	test   %eax,%eax
8010369d:	74 66                	je     80103705 <sleep+0x77>
8010369f:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801036a1:	85 db                	test   %ebx,%ebx
801036a3:	74 6d                	je     80103712 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801036a5:	81 fb 20 39 11 80    	cmp    $0x80113920,%ebx
801036ab:	74 18                	je     801036c5 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	68 20 39 11 80       	push   $0x80113920
801036b5:	e8 7b 0c 00 00       	call   80104335 <acquire>
    release(lk);
801036ba:	89 1c 24             	mov    %ebx,(%esp)
801036bd:	e8 d8 0c 00 00       	call   8010439a <release>
801036c2:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801036cb:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801036d2:	e8 19 fe ff ff       	call   801034f0 <sched>
  p->chan = 0;
801036d7:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801036de:	81 fb 20 39 11 80    	cmp    $0x80113920,%ebx
801036e4:	74 18                	je     801036fe <sleep+0x70>
    release(&ptable.lock);
801036e6:	83 ec 0c             	sub    $0xc,%esp
801036e9:	68 20 39 11 80       	push   $0x80113920
801036ee:	e8 a7 0c 00 00       	call   8010439a <release>
    acquire(lk);
801036f3:	89 1c 24             	mov    %ebx,(%esp)
801036f6:	e8 3a 0c 00 00       	call   80104335 <acquire>
801036fb:	83 c4 10             	add    $0x10,%esp
}
801036fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103701:	5b                   	pop    %ebx
80103702:	5e                   	pop    %esi
80103703:	5d                   	pop    %ebp
80103704:	c3                   	ret    
    panic("sleep");
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	68 89 72 10 80       	push   $0x80107289
8010370d:	e8 36 cc ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	68 8f 72 10 80       	push   $0x8010728f
8010371a:	e8 29 cc ff ff       	call   80100348 <panic>

8010371f <wait>:
{
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	56                   	push   %esi
80103723:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103724:	e8 30 fc ff ff       	call   80103359 <myproc>
80103729:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010372b:	83 ec 0c             	sub    $0xc,%esp
8010372e:	68 20 39 11 80       	push   $0x80113920
80103733:	e8 fd 0b 00 00       	call   80104335 <acquire>
80103738:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010373b:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103740:	bb 54 39 11 80       	mov    $0x80113954,%ebx
80103745:	eb 5e                	jmp    801037a5 <wait+0x86>
        pid = p->pid;
80103747:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010374a:	83 ec 0c             	sub    $0xc,%esp
8010374d:	ff 73 08             	pushl  0x8(%ebx)
80103750:	e8 4f e8 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
80103755:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
8010375c:	83 c4 04             	add    $0x4,%esp
8010375f:	ff 73 04             	pushl  0x4(%ebx)
80103762:	e8 73 32 00 00       	call   801069da <freevm>
        p->pid = 0;
80103767:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010376e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103775:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103779:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103780:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103787:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
8010378e:	e8 07 0c 00 00       	call   8010439a <release>
        return pid;
80103793:	83 c4 10             	add    $0x10,%esp
}
80103796:	89 f0                	mov    %esi,%eax
80103798:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010379b:	5b                   	pop    %ebx
8010379c:	5e                   	pop    %esi
8010379d:	5d                   	pop    %ebp
8010379e:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010379f:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801037a5:	81 fb 54 65 11 80    	cmp    $0x80116554,%ebx
801037ab:	73 12                	jae    801037bf <wait+0xa0>
      if(p->parent != curproc)
801037ad:	39 73 14             	cmp    %esi,0x14(%ebx)
801037b0:	75 ed                	jne    8010379f <wait+0x80>
      if(p->state == ZOMBIE){
801037b2:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037b6:	74 8f                	je     80103747 <wait+0x28>
      havekids = 1;
801037b8:	b8 01 00 00 00       	mov    $0x1,%eax
801037bd:	eb e0                	jmp    8010379f <wait+0x80>
    if(!havekids || curproc->killed){
801037bf:	85 c0                	test   %eax,%eax
801037c1:	74 06                	je     801037c9 <wait+0xaa>
801037c3:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801037c7:	74 17                	je     801037e0 <wait+0xc1>
      release(&ptable.lock);
801037c9:	83 ec 0c             	sub    $0xc,%esp
801037cc:	68 20 39 11 80       	push   $0x80113920
801037d1:	e8 c4 0b 00 00       	call   8010439a <release>
      return -1;
801037d6:	83 c4 10             	add    $0x10,%esp
801037d9:	be ff ff ff ff       	mov    $0xffffffff,%esi
801037de:	eb b6                	jmp    80103796 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801037e0:	83 ec 08             	sub    $0x8,%esp
801037e3:	68 20 39 11 80       	push   $0x80113920
801037e8:	56                   	push   %esi
801037e9:	e8 a0 fe ff ff       	call   8010368e <sleep>
    havekids = 0;
801037ee:	83 c4 10             	add    $0x10,%esp
801037f1:	e9 45 ff ff ff       	jmp    8010373b <wait+0x1c>

801037f6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801037f6:	55                   	push   %ebp
801037f7:	89 e5                	mov    %esp,%ebp
801037f9:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801037fc:	68 20 39 11 80       	push   $0x80113920
80103801:	e8 2f 0b 00 00       	call   80104335 <acquire>
  wakeup1(chan);
80103806:	8b 45 08             	mov    0x8(%ebp),%eax
80103809:	e8 28 f8 ff ff       	call   80103036 <wakeup1>
  release(&ptable.lock);
8010380e:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80103815:	e8 80 0b 00 00       	call   8010439a <release>
}
8010381a:	83 c4 10             	add    $0x10,%esp
8010381d:	c9                   	leave  
8010381e:	c3                   	ret    

8010381f <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010381f:	55                   	push   %ebp
80103820:	89 e5                	mov    %esp,%ebp
80103822:	53                   	push   %ebx
80103823:	83 ec 10             	sub    $0x10,%esp
80103826:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103829:	68 20 39 11 80       	push   $0x80113920
8010382e:	e8 02 0b 00 00       	call   80104335 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103833:	83 c4 10             	add    $0x10,%esp
80103836:	b8 54 39 11 80       	mov    $0x80113954,%eax
8010383b:	3d 54 65 11 80       	cmp    $0x80116554,%eax
80103840:	73 6f                	jae    801038b1 <kill+0x92>
    if(p->pid == pid){
80103842:	39 58 10             	cmp    %ebx,0x10(%eax)
80103845:	74 07                	je     8010384e <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103847:	05 b0 00 00 00       	add    $0xb0,%eax
8010384c:	eb ed                	jmp    8010383b <kill+0x1c>
      p->killed = 1;
8010384e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING) {
80103855:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103859:	74 1a                	je     80103875 <kill+0x56>
        ptable.priorityLevelCount[p->priority]++;
        ptable.queue[p->priority][ptable.priorityLevelCount[p->priority]] = p->pid;
        p->state = RUNNABLE;
      }
      release(&ptable.lock);
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 20 39 11 80       	push   $0x80113920
80103863:	e8 32 0b 00 00       	call   8010439a <release>
      return 0;
80103868:	83 c4 10             	add    $0x10,%esp
8010386b:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103873:	c9                   	leave  
80103874:	c3                   	ret    
        ptable.priorityLevelCount[p->priority]++;
80103875:	8b 48 7c             	mov    0x7c(%eax),%ecx
80103878:	8d 91 0c 0c 00 00    	lea    0xc0c(%ecx),%edx
8010387e:	8b 0c 95 24 39 11 80 	mov    -0x7feec6dc(,%edx,4),%ecx
80103885:	83 c1 01             	add    $0x1,%ecx
80103888:	89 0c 95 24 39 11 80 	mov    %ecx,-0x7feec6dc(,%edx,4)
        ptable.queue[p->priority][ptable.priorityLevelCount[p->priority]] = p->pid;
8010388f:	8b 48 7c             	mov    0x7c(%eax),%ecx
80103892:	8b 58 10             	mov    0x10(%eax),%ebx
80103895:	89 ca                	mov    %ecx,%edx
80103897:	c1 e2 06             	shl    $0x6,%edx
8010389a:	03 14 8d 54 69 11 80 	add    -0x7fee96ac(,%ecx,4),%edx
801038a1:	89 1c 95 54 65 11 80 	mov    %ebx,-0x7fee9aac(,%edx,4)
        p->state = RUNNABLE;
801038a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801038af:	eb aa                	jmp    8010385b <kill+0x3c>
  release(&ptable.lock);
801038b1:	83 ec 0c             	sub    $0xc,%esp
801038b4:	68 20 39 11 80       	push   $0x80113920
801038b9:	e8 dc 0a 00 00       	call   8010439a <release>
  return -1;
801038be:	83 c4 10             	add    $0x10,%esp
801038c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038c6:	eb a8                	jmp    80103870 <kill+0x51>

801038c8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801038c8:	55                   	push   %ebp
801038c9:	89 e5                	mov    %esp,%ebp
801038cb:	56                   	push   %esi
801038cc:	53                   	push   %ebx
801038cd:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038d0:	bb 54 39 11 80       	mov    $0x80113954,%ebx
801038d5:	eb 36                	jmp    8010390d <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801038d7:	b8 a0 72 10 80       	mov    $0x801072a0,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801038dc:	8d 53 6c             	lea    0x6c(%ebx),%edx
801038df:	52                   	push   %edx
801038e0:	50                   	push   %eax
801038e1:	ff 73 10             	pushl  0x10(%ebx)
801038e4:	68 a4 72 10 80       	push   $0x801072a4
801038e9:	e8 1d cd ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
801038ee:	83 c4 10             	add    $0x10,%esp
801038f1:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801038f5:	74 3c                	je     80103933 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801038f7:	83 ec 0c             	sub    $0xc,%esp
801038fa:	68 c1 72 10 80       	push   $0x801072c1
801038ff:	e8 07 cd ff ff       	call   8010060b <cprintf>
80103904:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103907:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
8010390d:	81 fb 54 65 11 80    	cmp    $0x80116554,%ebx
80103913:	73 61                	jae    80103976 <procdump+0xae>
    if(p->state == UNUSED)
80103915:	8b 43 0c             	mov    0xc(%ebx),%eax
80103918:	85 c0                	test   %eax,%eax
8010391a:	74 eb                	je     80103907 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010391c:	83 f8 05             	cmp    $0x5,%eax
8010391f:	77 b6                	ja     801038d7 <procdump+0xf>
80103921:	8b 04 85 18 73 10 80 	mov    -0x7fef8ce8(,%eax,4),%eax
80103928:	85 c0                	test   %eax,%eax
8010392a:	75 b0                	jne    801038dc <procdump+0x14>
      state = "???";
8010392c:	b8 a0 72 10 80       	mov    $0x801072a0,%eax
80103931:	eb a9                	jmp    801038dc <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103933:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103936:	8b 40 0c             	mov    0xc(%eax),%eax
80103939:	83 c0 08             	add    $0x8,%eax
8010393c:	83 ec 08             	sub    $0x8,%esp
8010393f:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103942:	52                   	push   %edx
80103943:	50                   	push   %eax
80103944:	e8 cb 08 00 00       	call   80104214 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103949:	83 c4 10             	add    $0x10,%esp
8010394c:	be 00 00 00 00       	mov    $0x0,%esi
80103951:	eb 14                	jmp    80103967 <procdump+0x9f>
        cprintf(" %p", pc[i]);
80103953:	83 ec 08             	sub    $0x8,%esp
80103956:	50                   	push   %eax
80103957:	68 e1 6c 10 80       	push   $0x80106ce1
8010395c:	e8 aa cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103961:	83 c6 01             	add    $0x1,%esi
80103964:	83 c4 10             	add    $0x10,%esp
80103967:	83 fe 09             	cmp    $0x9,%esi
8010396a:	7f 8b                	jg     801038f7 <procdump+0x2f>
8010396c:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103970:	85 c0                	test   %eax,%eax
80103972:	75 df                	jne    80103953 <procdump+0x8b>
80103974:	eb 81                	jmp    801038f7 <procdump+0x2f>
  }
}
80103976:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103979:	5b                   	pop    %ebx
8010397a:	5e                   	pop    %esi
8010397b:	5d                   	pop    %ebp
8010397c:	c3                   	ret    

8010397d <setpri>:

int 
setpri(int PID, int pri) {
8010397d:	55                   	push   %ebp
8010397e:	89 e5                	mov    %esp,%ebp
80103980:	57                   	push   %edi
80103981:	56                   	push   %esi
80103982:	53                   	push   %ebx
80103983:	83 ec 0c             	sub    $0xc,%esp
80103986:	8b 75 08             	mov    0x8(%ebp),%esi
80103989:	8b 7d 0c             	mov    0xc(%ebp),%edi
    struct proc *p;
    int count = 0;
    //cprintf("Executing setpri\n");
    if(pri < 0 || pri > 3) {
8010398c:	83 ff 03             	cmp    $0x3,%edi
8010398f:	0f 87 20 01 00 00    	ja     80103ab5 <setpri+0x138>
    int count = 0;
80103995:	b8 00 00 00 00       	mov    $0x0,%eax
      return -1;
    }
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010399a:	bb 54 39 11 80       	mov    $0x80113954,%ebx
8010399f:	81 fb 54 65 11 80    	cmp    $0x80116554,%ebx
801039a5:	0f 83 03 01 00 00    	jae    80103aae <setpri+0x131>
        if(p->pid == PID) {
801039ab:	39 73 10             	cmp    %esi,0x10(%ebx)
801039ae:	74 0b                	je     801039bb <setpri+0x3e>

	    ptable.priorityLevelCount[prevPriority]--;
	    release(&ptable.lock);
            return 0;
        }
	count++;
801039b0:	83 c0 01             	add    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039b3:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801039b9:	eb e4                	jmp    8010399f <setpri+0x22>
            pstat.priority[count]  = pri; 
801039bb:	89 3c 85 20 2f 11 80 	mov    %edi,-0x7feed0e0(,%eax,4)
	    acquire(&ptable.lock);
801039c2:	83 ec 0c             	sub    $0xc,%esp
801039c5:	68 20 39 11 80       	push   $0x80113920
801039ca:	e8 66 09 00 00       	call   80104335 <acquire>
	    if(p->priority == pri) {
801039cf:	8b 4b 7c             	mov    0x7c(%ebx),%ecx
801039d2:	83 c4 10             	add    $0x10,%esp
801039d5:	39 f9                	cmp    %edi,%ecx
801039d7:	74 46                	je     80103a1f <setpri+0xa2>
	    p->priority = pri;
801039d9:	89 7b 7c             	mov    %edi,0x7c(%ebx)
	    p->qtail[p->priority] = p->qtail[p->priority] + 1;
801039dc:	8d 57 20             	lea    0x20(%edi),%edx
801039df:	8b 04 93             	mov    (%ebx,%edx,4),%eax
801039e2:	83 c0 01             	add    $0x1,%eax
801039e5:	89 04 93             	mov    %eax,(%ebx,%edx,4)
	    ptable.priorityLevelCount[p->priority]++;
801039e8:	8d 97 0c 0c 00 00    	lea    0xc0c(%edi),%edx
801039ee:	8b 04 95 24 39 11 80 	mov    -0x7feec6dc(,%edx,4),%eax
801039f5:	83 c0 01             	add    $0x1,%eax
801039f8:	89 04 95 24 39 11 80 	mov    %eax,-0x7feec6dc(,%edx,4)
	    ptable.queue[pri][ptable.priorityLevelCount[pri]] = p->pid;
801039ff:	8b 53 10             	mov    0x10(%ebx),%edx
80103a02:	c1 e7 06             	shl    $0x6,%edi
80103a05:	8d 84 38 0c 0b 00 00 	lea    0xb0c(%eax,%edi,1),%eax
80103a0c:	89 14 85 24 39 11 80 	mov    %edx,-0x7feec6dc(,%eax,4)
	    for(int i =0; i< ptable.priorityLevelCount[prevPriority]; i++) {
80103a13:	ba 00 00 00 00       	mov    $0x0,%edx
	    int pLoc = 0;
80103a18:	b8 00 00 00 00       	mov    $0x0,%eax
	    for(int i =0; i< ptable.priorityLevelCount[prevPriority]; i++) {
80103a1d:	eb 1a                	jmp    80103a39 <setpri+0xbc>
	       release(&ptable.lock);
80103a1f:	83 ec 0c             	sub    $0xc,%esp
80103a22:	68 20 39 11 80       	push   $0x80113920
80103a27:	e8 6e 09 00 00       	call   8010439a <release>
	       return 0;
80103a2c:	83 c4 10             	add    $0x10,%esp
80103a2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103a34:	eb 70                	jmp    80103aa6 <setpri+0x129>
	    for(int i =0; i< ptable.priorityLevelCount[prevPriority]; i++) {
80103a36:	83 c2 01             	add    $0x1,%edx
80103a39:	8b 1c 8d 54 69 11 80 	mov    -0x7fee96ac(,%ecx,4),%ebx
80103a40:	39 d3                	cmp    %edx,%ebx
80103a42:	7e 3f                	jle    80103a83 <setpri+0x106>
	        if(PID == ptable.queue[prevPriority][i]) {
80103a44:	89 cb                	mov    %ecx,%ebx
80103a46:	c1 e3 06             	shl    $0x6,%ebx
80103a49:	8d 9c 1a 0c 0b 00 00 	lea    0xb0c(%edx,%ebx,1),%ebx
80103a50:	39 34 9d 24 39 11 80 	cmp    %esi,-0x7feec6dc(,%ebx,4)
80103a57:	75 dd                	jne    80103a36 <setpri+0xb9>
	            pLoc = i;
80103a59:	89 d0                	mov    %edx,%eax
80103a5b:	eb d9                	jmp    80103a36 <setpri+0xb9>
	        ptable.queue[prevPriority][i] = ptable.queue[prevPriority][i+1];
80103a5d:	8d 50 01             	lea    0x1(%eax),%edx
80103a60:	89 ce                	mov    %ecx,%esi
80103a62:	c1 e6 06             	shl    $0x6,%esi
80103a65:	8d bc 32 0c 0b 00 00 	lea    0xb0c(%edx,%esi,1),%edi
80103a6c:	8b 3c bd 24 39 11 80 	mov    -0x7feec6dc(,%edi,4),%edi
80103a73:	8d 84 30 0c 0b 00 00 	lea    0xb0c(%eax,%esi,1),%eax
80103a7a:	89 3c 85 24 39 11 80 	mov    %edi,-0x7feec6dc(,%eax,4)
	    for(int i = pLoc; i < ptable.priorityLevelCount[prevPriority]; i++) {
80103a81:	89 d0                	mov    %edx,%eax
80103a83:	39 c3                	cmp    %eax,%ebx
80103a85:	7f d6                	jg     80103a5d <setpri+0xe0>
	    ptable.priorityLevelCount[prevPriority]--;
80103a87:	83 eb 01             	sub    $0x1,%ebx
80103a8a:	89 1c 8d 54 69 11 80 	mov    %ebx,-0x7fee96ac(,%ecx,4)
	    release(&ptable.lock);
80103a91:	83 ec 0c             	sub    $0xc,%esp
80103a94:	68 20 39 11 80       	push   $0x80113920
80103a99:	e8 fc 08 00 00       	call   8010439a <release>
            return 0;
80103a9e:	83 c4 10             	add    $0x10,%esp
80103aa1:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    return -1;
}
80103aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103aa9:	5b                   	pop    %ebx
80103aaa:	5e                   	pop    %esi
80103aab:	5f                   	pop    %edi
80103aac:	5d                   	pop    %ebp
80103aad:	c3                   	ret    
    return -1;
80103aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ab3:	eb f1                	jmp    80103aa6 <setpri+0x129>
      return -1;
80103ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103aba:	eb ea                	jmp    80103aa6 <setpri+0x129>

80103abc <getpri>:

int
getpri(int PID) {
80103abc:	55                   	push   %ebp
80103abd:	89 e5                	mov    %esp,%ebp
80103abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
    struct proc *p;
    int count = 0;
80103ac2:	ba 00 00 00 00       	mov    $0x0,%edx
    //cprintf("Executing getpri\n");
     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ac7:	b8 54 39 11 80       	mov    $0x80113954,%eax
80103acc:	3d 54 65 11 80       	cmp    $0x80116554,%eax
80103ad1:	73 18                	jae    80103aeb <getpri+0x2f>
         if(p->pid == PID) {
80103ad3:	39 48 10             	cmp    %ecx,0x10(%eax)
80103ad6:	74 0a                	je     80103ae2 <getpri+0x26>
		 return pstat.priority[count];
	 }
	 count++;
80103ad8:	83 c2 01             	add    $0x1,%edx
     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103adb:	05 b0 00 00 00       	add    $0xb0,%eax
80103ae0:	eb ea                	jmp    80103acc <getpri+0x10>
		 return pstat.priority[count];
80103ae2:	8b 04 95 20 2f 11 80 	mov    -0x7feed0e0(,%edx,4),%eax
     }
     return -1;
 }
80103ae9:	5d                   	pop    %ebp
80103aea:	c3                   	ret    
     return -1;
80103aeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103af0:	eb f7                	jmp    80103ae9 <getpri+0x2d>

80103af2 <getpinfo>:

int 
getpinfo(struct pstat *ps){
80103af2:	55                   	push   %ebp
80103af3:	89 e5                	mov    %esp,%ebp
80103af5:	57                   	push   %edi
80103af6:	56                   	push   %esi
80103af7:	53                   	push   %ebx
80103af8:	83 ec 08             	sub    $0x8,%esp
80103afb:	8b 45 08             	mov    0x8(%ebp),%eax
80103afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
	if(!ps) {
80103b01:	85 c0                	test   %eax,%eax
80103b03:	0f 84 d8 00 00 00    	je     80103be1 <getpinfo+0xef>
	 return -1;
	}
	struct proc *p;
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b09:	ba 54 39 11 80       	mov    $0x80113954,%edx
	int i = 0;
80103b0e:	b9 00 00 00 00       	mov    $0x0,%ecx
80103b13:	eb 70                	jmp    80103b85 <getpinfo+0x93>
	    ps->pid[i] = p->pid;
	    if(p->state == UNUSED || p->state == ZOMBIE || p->state == EMBRYO)
	    {
		    ps->inuse[i] = 0;
80103b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b18:	c7 04 88 00 00 00 00 	movl   $0x0,(%eax,%ecx,4)
		   }
	    else{
		    ps->inuse[i] = 1;
	    }
	    ps->priority[i] = p->priority;
80103b1f:	8b 42 7c             	mov    0x7c(%edx),%eax
80103b22:	8b 75 f0             	mov    -0x10(%ebp),%esi
80103b25:	89 84 8e 00 02 00 00 	mov    %eax,0x200(%esi,%ecx,4)
	    ps->state[i] = p->state;
80103b2c:	8b 42 0c             	mov    0xc(%edx),%eax
80103b2f:	89 84 8e 00 03 00 00 	mov    %eax,0x300(%esi,%ecx,4)
	    for(int j = 0; j< 4; j++) {
80103b36:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3b:	eb 17                	jmp    80103b54 <getpinfo+0x62>
	        ps->ticks[i][j] = p->ticks[j];
80103b3d:	8d b4 88 00 01 00 00 	lea    0x100(%eax,%ecx,4),%esi
80103b44:	8b 9c 82 90 00 00 00 	mov    0x90(%edx,%eax,4),%ebx
80103b4b:	8b 7d f0             	mov    -0x10(%ebp),%edi
80103b4e:	89 1c b7             	mov    %ebx,(%edi,%esi,4)
	    for(int j = 0; j< 4; j++) {
80103b51:	83 c0 01             	add    $0x1,%eax
80103b54:	83 f8 03             	cmp    $0x3,%eax
80103b57:	7e e4                	jle    80103b3d <getpinfo+0x4b>
	    }
	    for(int j = 0; j<4; j++) {
80103b59:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5e:	eb 17                	jmp    80103b77 <getpinfo+0x85>
		    ps->qtail[i][j] = p->qtail[j];
80103b60:	8d b4 88 00 02 00 00 	lea    0x200(%eax,%ecx,4),%esi
80103b67:	8b bc 82 80 00 00 00 	mov    0x80(%edx,%eax,4),%edi
80103b6e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80103b71:	89 3c b3             	mov    %edi,(%ebx,%esi,4)
	    for(int j = 0; j<4; j++) {
80103b74:	83 c0 01             	add    $0x1,%eax
80103b77:	83 f8 03             	cmp    $0x3,%eax
80103b7a:	7e e4                	jle    80103b60 <getpinfo+0x6e>
	    }
	    //cprintf("%d : %d : %d\n",ps->pid[i],ps->priority[i],ps->state[i]);
	    i++;
80103b7c:	83 c1 01             	add    $0x1,%ecx
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b7f:	81 c2 b0 00 00 00    	add    $0xb0,%edx
80103b85:	81 fa 54 65 11 80    	cmp    $0x80116554,%edx
80103b8b:	73 47                	jae    80103bd4 <getpinfo+0xe2>
	    ps->pid[i] = p->pid;
80103b8d:	8b 42 10             	mov    0x10(%edx),%eax
80103b90:	8b 7d f0             	mov    -0x10(%ebp),%edi
80103b93:	89 84 8f 00 01 00 00 	mov    %eax,0x100(%edi,%ecx,4)
	    if(p->state == UNUSED || p->state == ZOMBIE || p->state == EMBRYO)
80103b9a:	8b 5a 0c             	mov    0xc(%edx),%ebx
80103b9d:	85 db                	test   %ebx,%ebx
80103b9f:	0f 94 c0             	sete   %al
80103ba2:	89 c7                	mov    %eax,%edi
80103ba4:	89 5d ec             	mov    %ebx,-0x14(%ebp)
80103ba7:	83 fb 05             	cmp    $0x5,%ebx
80103baa:	0f 94 c0             	sete   %al
80103bad:	89 c6                	mov    %eax,%esi
80103baf:	89 f8                	mov    %edi,%eax
80103bb1:	89 f3                	mov    %esi,%ebx
80103bb3:	08 d8                	or     %bl,%al
80103bb5:	0f 85 5a ff ff ff    	jne    80103b15 <getpinfo+0x23>
80103bbb:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
80103bbf:	0f 84 50 ff ff ff    	je     80103b15 <getpinfo+0x23>
		    ps->inuse[i] = 1;
80103bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc8:	c7 04 88 01 00 00 00 	movl   $0x1,(%eax,%ecx,4)
80103bcf:	e9 4b ff ff ff       	jmp    80103b1f <getpinfo+0x2d>
        }
	return 0;
80103bd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bd9:	83 c4 08             	add    $0x8,%esp
80103bdc:	5b                   	pop    %ebx
80103bdd:	5e                   	pop    %esi
80103bde:	5f                   	pop    %edi
80103bdf:	5d                   	pop    %ebp
80103be0:	c3                   	ret    
	 return -1;
80103be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103be6:	eb f1                	jmp    80103bd9 <getpinfo+0xe7>

80103be8 <fork>:
{
80103be8:	55                   	push   %ebp
80103be9:	89 e5                	mov    %esp,%ebp
80103beb:	57                   	push   %edi
80103bec:	56                   	push   %esi
80103bed:	53                   	push   %ebx
80103bee:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103bf1:	e8 63 f7 ff ff       	call   80103359 <myproc>
80103bf6:	89 c7                	mov    %eax,%edi
80103bf8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if((np = allocproc()) == 0){
80103bfb:	e8 1a f5 ff ff       	call   8010311a <allocproc>
80103c00:	85 c0                	test   %eax,%eax
80103c02:	0f 84 79 01 00 00    	je     80103d81 <fork+0x199>
80103c08:	89 c3                	mov    %eax,%ebx
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103c0a:	83 ec 08             	sub    $0x8,%esp
80103c0d:	ff 37                	pushl  (%edi)
80103c0f:	ff 77 04             	pushl  0x4(%edi)
80103c12:	e8 e4 2e 00 00       	call   80106afb <copyuvm>
80103c17:	89 43 04             	mov    %eax,0x4(%ebx)
80103c1a:	83 c4 10             	add    $0x10,%esp
80103c1d:	85 c0                	test   %eax,%eax
80103c1f:	74 28                	je     80103c49 <fork+0x61>
  np->sz = curproc->sz;
80103c21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103c24:	8b 02                	mov    (%edx),%eax
80103c26:	89 03                	mov    %eax,(%ebx)
  np->parent = curproc;
80103c28:	89 53 14             	mov    %edx,0x14(%ebx)
  *np->tf = *curproc->tf;
80103c2b:	8b 72 18             	mov    0x18(%edx),%esi
80103c2e:	b9 13 00 00 00       	mov    $0x13,%ecx
80103c33:	8b 7b 18             	mov    0x18(%ebx),%edi
80103c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103c38:	8b 43 18             	mov    0x18(%ebx),%eax
80103c3b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103c42:	be 00 00 00 00       	mov    $0x0,%esi
80103c47:	eb 29                	jmp    80103c72 <fork+0x8a>
    kfree(np->kstack);
80103c49:	83 ec 0c             	sub    $0xc,%esp
80103c4c:	ff 73 08             	pushl  0x8(%ebx)
80103c4f:	e8 50 e3 ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80103c54:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103c5b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103c62:	83 c4 10             	add    $0x10,%esp
80103c65:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80103c6a:	e9 c3 00 00 00       	jmp    80103d32 <fork+0x14a>
  for(i = 0; i < NOFILE; i++)
80103c6f:	83 c6 01             	add    $0x1,%esi
80103c72:	83 fe 0f             	cmp    $0xf,%esi
80103c75:	7f 1d                	jg     80103c94 <fork+0xac>
    if(curproc->ofile[i])
80103c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c7a:	8b 44 b0 28          	mov    0x28(%eax,%esi,4),%eax
80103c7e:	85 c0                	test   %eax,%eax
80103c80:	74 ed                	je     80103c6f <fork+0x87>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103c82:	83 ec 0c             	sub    $0xc,%esp
80103c85:	50                   	push   %eax
80103c86:	e8 03 d0 ff ff       	call   80100c8e <filedup>
80103c8b:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
80103c8f:	83 c4 10             	add    $0x10,%esp
80103c92:	eb db                	jmp    80103c6f <fork+0x87>
  np->cwd = idup(curproc->cwd);
80103c94:	83 ec 0c             	sub    $0xc,%esp
80103c97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103c9a:	ff 77 68             	pushl  0x68(%edi)
80103c9d:	e8 af d8 ff ff       	call   80101551 <idup>
80103ca2:	89 43 68             	mov    %eax,0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ca5:	8d 47 6c             	lea    0x6c(%edi),%eax
80103ca8:	8d 73 6c             	lea    0x6c(%ebx),%esi
80103cab:	83 c4 0c             	add    $0xc,%esp
80103cae:	6a 10                	push   $0x10
80103cb0:	50                   	push   %eax
80103cb1:	56                   	push   %esi
80103cb2:	e8 91 08 00 00       	call   80104548 <safestrcpy>
  pid = np->pid;
80103cb7:	8b 7b 10             	mov    0x10(%ebx),%edi
  acquire(&ptable.lock);
80103cba:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80103cc1:	e8 6f 06 00 00       	call   80104335 <acquire>
  np->state = RUNNABLE;
80103cc6:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  if(!np->parent) {
80103ccd:	8b 43 14             	mov    0x14(%ebx),%eax
80103cd0:	83 c4 10             	add    $0x10,%esp
80103cd3:	85 c0                	test   %eax,%eax
80103cd5:	74 65                	je     80103d3c <fork+0x154>
       int parentPriority = np->parent->priority;
80103cd7:	8b 40 7c             	mov    0x7c(%eax),%eax
       np->priority = parentPriority;
80103cda:	89 43 7c             	mov    %eax,0x7c(%ebx)
       ptable.priorityLevelCount[parentPriority]++;
80103cdd:	8d 88 0c 0c 00 00    	lea    0xc0c(%eax),%ecx
80103ce3:	8b 14 8d 24 39 11 80 	mov    -0x7feec6dc(,%ecx,4),%edx
80103cea:	83 c2 01             	add    $0x1,%edx
80103ced:	89 14 8d 24 39 11 80 	mov    %edx,-0x7feec6dc(,%ecx,4)
       ptable.queue[parentPriority][ptable.priorityLevelCount[parentPriority]] = np->pid;
80103cf4:	8b 4b 10             	mov    0x10(%ebx),%ecx
80103cf7:	89 c6                	mov    %eax,%esi
80103cf9:	c1 e6 06             	shl    $0x6,%esi
80103cfc:	8d 94 32 0c 0b 00 00 	lea    0xb0c(%edx,%esi,1),%edx
80103d03:	89 0c 95 24 39 11 80 	mov    %ecx,-0x7feec6dc(,%edx,4)
       np->qtail[parentPriority] = np->qtail[parentPriority] + 1;
80103d0a:	83 c0 20             	add    $0x20,%eax
80103d0d:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
80103d10:	8d 51 01             	lea    0x1(%ecx),%edx
80103d13:	89 14 83             	mov    %edx,(%ebx,%eax,4)
  release(&ptable.lock);
80103d16:	83 ec 0c             	sub    $0xc,%esp
80103d19:	68 20 39 11 80       	push   $0x80113920
80103d1e:	e8 77 06 00 00       	call   8010439a <release>
  getpinfo(&pstat);
80103d23:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103d2a:	e8 c3 fd ff ff       	call   80103af2 <getpinfo>
  return pid;
80103d2f:	83 c4 10             	add    $0x10,%esp
}
80103d32:	89 f8                	mov    %edi,%eax
80103d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103d37:	5b                   	pop    %ebx
80103d38:	5e                   	pop    %esi
80103d39:	5f                   	pop    %edi
80103d3a:	5d                   	pop    %ebp
80103d3b:	c3                   	ret    
       ptable.priorityLevelCount[3]++;
80103d3c:	a1 60 69 11 80       	mov    0x80116960,%eax
80103d41:	83 c0 01             	add    $0x1,%eax
80103d44:	a3 60 69 11 80       	mov    %eax,0x80116960
       np->priority = 3;
80103d49:	c7 43 7c 03 00 00 00 	movl   $0x3,0x7c(%ebx)
       cprintf("Entered in queue %s \n", np->name);
80103d50:	83 ec 08             	sub    $0x8,%esp
80103d53:	56                   	push   %esi
80103d54:	68 ad 72 10 80       	push   $0x801072ad
80103d59:	e8 ad c8 ff ff       	call   8010060b <cprintf>
       ptable.queue[3][ptable.priorityLevelCount[3]] = np->pid;
80103d5e:	8b 53 10             	mov    0x10(%ebx),%edx
80103d61:	a1 60 69 11 80       	mov    0x80116960,%eax
80103d66:	89 14 85 54 68 11 80 	mov    %edx,-0x7fee97ac(,%eax,4)
       np->qtail[3] = np->qtail[3] + 1;
80103d6d:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80103d73:	83 c0 01             	add    $0x1,%eax
80103d76:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
80103d7c:	83 c4 10             	add    $0x10,%esp
80103d7f:	eb 95                	jmp    80103d16 <fork+0x12e>
    return -1;
80103d81:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80103d86:	eb aa                	jmp    80103d32 <fork+0x14a>

80103d88 <scheduler>:
{
80103d88:	55                   	push   %ebp
80103d89:	89 e5                	mov    %esp,%ebp
80103d8b:	57                   	push   %edi
80103d8c:	56                   	push   %esi
80103d8d:	53                   	push   %ebx
80103d8e:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
80103d91:	e8 4c f5 ff ff       	call   801032e2 <mycpu>
80103d96:	89 c7                	mov    %eax,%edi
  c->proc = 0;
80103d98:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103d9f:	00 00 00 
80103da2:	eb 74                	jmp    80103e18 <scheduler+0x90>
      if(p->state == RUNNABLE) {
80103da4:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103da8:	74 51                	je     80103dfb <scheduler+0x73>
     for(y = 0; y <= ptable.priorityLevelCount[priority]; y++) {
80103daa:	83 c2 01             	add    $0x1,%edx
80103dad:	39 14 b5 54 69 11 80 	cmp    %edx,-0x7fee96ac(,%esi,4)
80103db4:	7c 2d                	jl     80103de3 <scheduler+0x5b>
      int processToBeRunPID = ptable.queue[priority][y];
80103db6:	89 f0                	mov    %esi,%eax
80103db8:	c1 e0 06             	shl    $0x6,%eax
80103dbb:	8d 84 02 0c 0b 00 00 	lea    0xb0c(%edx,%eax,1),%eax
80103dc2:	8b 04 85 24 39 11 80 	mov    -0x7feec6dc(,%eax,4),%eax
      for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++) {
80103dc9:	bb 54 39 11 80       	mov    $0x80113954,%ebx
80103dce:	81 fb 54 65 11 80    	cmp    $0x80116554,%ebx
80103dd4:	73 ce                	jae    80103da4 <scheduler+0x1c>
        if(p->pid == processToBeRunPID) {
80103dd6:	39 43 10             	cmp    %eax,0x10(%ebx)
80103dd9:	74 c9                	je     80103da4 <scheduler+0x1c>
      for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++) {
80103ddb:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103de1:	eb eb                	jmp    80103dce <scheduler+0x46>
     int found = 0;
80103de3:	b8 00 00 00 00       	mov    $0x0,%eax
     if(found == 1) {
80103de8:	83 f8 01             	cmp    $0x1,%eax
80103deb:	74 15                	je     80103e02 <scheduler+0x7a>
   for(priority = 3; priority >=0; priority--) {
80103ded:	83 ee 01             	sub    $0x1,%esi
80103df0:	85 f6                	test   %esi,%esi
80103df2:	78 0e                	js     80103e02 <scheduler+0x7a>
     for(y = 0; y <= ptable.priorityLevelCount[priority]; y++) {
80103df4:	ba 00 00 00 00       	mov    $0x0,%edx
80103df9:	eb b2                	jmp    80103dad <scheduler+0x25>
         found = 1;
80103dfb:	b8 01 00 00 00       	mov    $0x1,%eax
80103e00:	eb e6                	jmp    80103de8 <scheduler+0x60>
   if(p->state == RUNNABLE) {
80103e02:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103e06:	74 28                	je     80103e30 <scheduler+0xa8>
   release(&ptable.lock);
80103e08:	83 ec 0c             	sub    $0xc,%esp
80103e0b:	68 20 39 11 80       	push   $0x80113920
80103e10:	e8 85 05 00 00       	call   8010439a <release>
  for(;;) {
80103e15:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103e18:	fb                   	sti    
   acquire(&ptable.lock);
80103e19:	83 ec 0c             	sub    $0xc,%esp
80103e1c:	68 20 39 11 80       	push   $0x80113920
80103e21:	e8 0f 05 00 00       	call   80104335 <acquire>
   for(priority = 3; priority >=0; priority--) {
80103e26:	83 c4 10             	add    $0x10,%esp
80103e29:	be 03 00 00 00       	mov    $0x3,%esi
80103e2e:	eb c0                	jmp    80103df0 <scheduler+0x68>
   if(p->time[p->priority] > 0) {
80103e30:	8b 43 7c             	mov    0x7c(%ebx),%eax
80103e33:	83 bc 83 a0 00 00 00 	cmpl   $0x0,0xa0(%ebx,%eax,4)
80103e3a:	00 
80103e3b:	7f 41                	jg     80103e7e <scheduler+0xf6>
   if((p->ticks[p->priority] != 0 && p->ticks[p->priority] % ticksPerPriority[p->priority] == 0 && p->time[p->priority] == 0)) {
80103e3d:	8b 4b 7c             	mov    0x7c(%ebx),%ecx
80103e40:	8b 84 8b 90 00 00 00 	mov    0x90(%ebx,%ecx,4),%eax
80103e47:	85 c0                	test   %eax,%eax
80103e49:	74 17                	je     80103e62 <scheduler+0xda>
80103e4b:	99                   	cltd   
80103e4c:	f7 3c 8d 04 a0 10 80 	idivl  -0x7fef5ffc(,%ecx,4)
80103e53:	85 d2                	test   %edx,%edx
80103e55:	75 0b                	jne    80103e62 <scheduler+0xda>
80103e57:	8b 84 8b a0 00 00 00 	mov    0xa0(%ebx,%ecx,4),%eax
80103e5e:	85 c0                	test   %eax,%eax
80103e60:	74 75                	je     80103ed7 <scheduler+0x14f>
   getpinfo(&pstat);
80103e62:	83 ec 0c             	sub    $0xc,%esp
80103e65:	68 20 2d 11 80       	push   $0x80112d20
80103e6a:	e8 83 fc ff ff       	call   80103af2 <getpinfo>
   c->proc = 0;
80103e6f:	c7 87 ac 00 00 00 00 	movl   $0x0,0xac(%edi)
80103e76:	00 00 00 
80103e79:	83 c4 10             	add    $0x10,%esp
80103e7c:	eb 8a                	jmp    80103e08 <scheduler+0x80>
     c->proc = p;
80103e7e:	89 9f ac 00 00 00    	mov    %ebx,0xac(%edi)
     switchuvm(p);
80103e84:	83 ec 0c             	sub    $0xc,%esp
80103e87:	53                   	push   %ebx
80103e88:	e8 b0 27 00 00       	call   8010663d <switchuvm>
     p->state = RUNNING;
80103e8d:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
     swtch(&(c->scheduler), p->context);
80103e94:	83 c4 08             	add    $0x8,%esp
80103e97:	ff 73 1c             	pushl  0x1c(%ebx)
80103e9a:	8d 47 04             	lea    0x4(%edi),%eax
80103e9d:	50                   	push   %eax
80103e9e:	e8 f8 06 00 00       	call   8010459b <swtch>
     switchkvm();
80103ea3:	e8 83 27 00 00       	call   8010662b <switchkvm>
     p->ticks[priority] = p->ticks[priority] + 1;
80103ea8:	8d 56 24             	lea    0x24(%esi),%edx
80103eab:	8b 04 93             	mov    (%ebx,%edx,4),%eax
80103eae:	83 c0 01             	add    $0x1,%eax
80103eb1:	89 04 93             	mov    %eax,(%ebx,%edx,4)
     p->time[p->priority] = p->time[p->priority] - 1;
80103eb4:	8b 43 7c             	mov    0x7c(%ebx),%eax
80103eb7:	83 c0 28             	add    $0x28,%eax
80103eba:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
80103ebd:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ec0:	89 14 83             	mov    %edx,(%ebx,%eax,4)
     getpinfo(&pstat);
80103ec3:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103eca:	e8 23 fc ff ff       	call   80103af2 <getpinfo>
80103ecf:	83 c4 10             	add    $0x10,%esp
80103ed2:	e9 66 ff ff ff       	jmp    80103e3d <scheduler+0xb5>
80103ed7:	89 7d e0             	mov    %edi,-0x20(%ebp)
80103eda:	eb 03                	jmp    80103edf <scheduler+0x157>
       for(a = 0; a < ptable.priorityLevelCount[priority]; a++) {
80103edc:	83 c0 01             	add    $0x1,%eax
80103edf:	8b 0c b5 54 69 11 80 	mov    -0x7fee96ac(,%esi,4),%ecx
80103ee6:	39 c1                	cmp    %eax,%ecx
80103ee8:	7e 20                	jle    80103f0a <scheduler+0x182>
             if(ptable.queue[priority][a] == p->pid) {
80103eea:	89 f2                	mov    %esi,%edx
80103eec:	c1 e2 06             	shl    $0x6,%edx
80103eef:	8d 94 10 0c 0b 00 00 	lea    0xb0c(%eax,%edx,1),%edx
80103ef6:	8b 7b 10             	mov    0x10(%ebx),%edi
80103ef9:	39 3c 95 24 39 11 80 	cmp    %edi,-0x7feec6dc(,%edx,4)
80103f00:	75 da                	jne    80103edc <scheduler+0x154>
80103f02:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80103f05:	8b 7d e0             	mov    -0x20(%ebp),%edi
80103f08:	eb 06                	jmp    80103f10 <scheduler+0x188>
80103f0a:	8b 7d e0             	mov    -0x20(%ebp),%edi
80103f0d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
       for(int z = a; z < ptable.priorityLevelCount[priority]; z++) {
80103f10:	39 c1                	cmp    %eax,%ecx
80103f12:	7e 32                	jle    80103f46 <scheduler+0x1be>
	     ptable.queue[priority][z] = ptable.queue[priority][z+1];
80103f14:	8d 58 01             	lea    0x1(%eax),%ebx
80103f17:	89 f2                	mov    %esi,%edx
80103f19:	c1 e2 06             	shl    $0x6,%edx
80103f1c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80103f1f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80103f22:	8d 94 13 0c 0b 00 00 	lea    0xb0c(%ebx,%edx,1),%edx
80103f29:	8b 14 95 24 39 11 80 	mov    -0x7feec6dc(,%edx,4),%edx
80103f30:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80103f33:	8d 84 18 0c 0b 00 00 	lea    0xb0c(%eax,%ebx,1),%eax
80103f3a:	89 14 85 24 39 11 80 	mov    %edx,-0x7feec6dc(,%eax,4)
       for(int z = a; z < ptable.priorityLevelCount[priority]; z++) {
80103f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f44:	eb ca                	jmp    80103f10 <scheduler+0x188>
80103f46:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
       ptable.queue[priority][ptable.priorityLevelCount[priority]] = p->pid;
80103f49:	8b 53 10             	mov    0x10(%ebx),%edx
80103f4c:	89 f0                	mov    %esi,%eax
80103f4e:	c1 e0 06             	shl    $0x6,%eax
80103f51:	8d 84 01 0c 0b 00 00 	lea    0xb0c(%ecx,%eax,1),%eax
80103f58:	89 14 85 24 39 11 80 	mov    %edx,-0x7feec6dc(,%eax,4)
       p->qtail[priority] = p->qtail[priority] + 1;
80103f5f:	83 c6 20             	add    $0x20,%esi
80103f62:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
80103f65:	83 c0 01             	add    $0x1,%eax
80103f68:	89 04 b3             	mov    %eax,(%ebx,%esi,4)
       p->time[p->priority] = ticksPerPriority[p->priority];
80103f6b:	8b 43 7c             	mov    0x7c(%ebx),%eax
80103f6e:	8b 14 85 04 a0 10 80 	mov    -0x7fef5ffc(,%eax,4),%edx
80103f75:	89 94 83 a0 00 00 00 	mov    %edx,0xa0(%ebx,%eax,4)
80103f7c:	e9 e1 fe ff ff       	jmp    80103e62 <scheduler+0xda>

80103f81 <fork2>:

int 
fork2(int pri)
{
80103f81:	55                   	push   %ebp
80103f82:	89 e5                	mov    %esp,%ebp
80103f84:	57                   	push   %edi
80103f85:	56                   	push   %esi
80103f86:	53                   	push   %ebx
80103f87:	83 ec 1c             	sub    $0x1c,%esp
    //cprintf("fork2:%d\n",pri);
    if(pri < 0 || pri > 3){
80103f8a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80103f8e:	0f 87 4c 01 00 00    	ja     801040e0 <fork2+0x15f>
    if(setpri(pid, pri) == -1) {
	    return -1;
    }*/
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f94:	e8 c0 f3 ff ff       	call   80103359 <myproc>
80103f99:	89 c7                	mov    %eax,%edi
80103f9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //{
  //  return -1;
  //}

  // Allocate process.
  if((np = allocproc()) == 0){
80103f9e:	e8 77 f1 ff ff       	call   8010311a <allocproc>
80103fa3:	89 c3                	mov    %eax,%ebx
80103fa5:	85 c0                	test   %eax,%eax
80103fa7:	0f 84 3a 01 00 00    	je     801040e7 <fork2+0x166>
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103fad:	83 ec 08             	sub    $0x8,%esp
80103fb0:	ff 37                	pushl  (%edi)
80103fb2:	ff 77 04             	pushl  0x4(%edi)
80103fb5:	e8 41 2b 00 00       	call   80106afb <copyuvm>
80103fba:	89 43 04             	mov    %eax,0x4(%ebx)
80103fbd:	83 c4 10             	add    $0x10,%esp
80103fc0:	85 c0                	test   %eax,%eax
80103fc2:	74 2a                	je     80103fee <fork2+0x6d>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80103fc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fc7:	8b 02                	mov    (%edx),%eax
80103fc9:	89 03                	mov    %eax,(%ebx)
  np->parent = curproc;
80103fcb:	89 53 14             	mov    %edx,0x14(%ebx)
  *np->tf = *curproc->tf;
80103fce:	8b 72 18             	mov    0x18(%edx),%esi
80103fd1:	b9 13 00 00 00       	mov    $0x13,%ecx
80103fd6:	8b 7b 18             	mov    0x18(%ebx),%edi
80103fd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103fdb:	8b 43 18             	mov    0x18(%ebx),%eax
80103fde:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103fe5:	be 00 00 00 00       	mov    $0x0,%esi
80103fea:	89 d7                	mov    %edx,%edi
80103fec:	eb 29                	jmp    80104017 <fork2+0x96>
    kfree(np->kstack);
80103fee:	83 ec 0c             	sub    $0xc,%esp
80103ff1:	ff 73 08             	pushl  0x8(%ebx)
80103ff4:	e8 ab df ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80103ff9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80104000:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80104007:	83 c4 10             	add    $0x10,%esp
8010400a:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010400f:	e9 be 00 00 00       	jmp    801040d2 <fork2+0x151>
  for(i = 0; i < NOFILE; i++)
80104014:	83 c6 01             	add    $0x1,%esi
80104017:	83 fe 0f             	cmp    $0xf,%esi
8010401a:	7f 1a                	jg     80104036 <fork2+0xb5>
    if(curproc->ofile[i])
8010401c:	8b 44 b7 28          	mov    0x28(%edi,%esi,4),%eax
80104020:	85 c0                	test   %eax,%eax
80104022:	74 f0                	je     80104014 <fork2+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104024:	83 ec 0c             	sub    $0xc,%esp
80104027:	50                   	push   %eax
80104028:	e8 61 cc ff ff       	call   80100c8e <filedup>
8010402d:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
80104031:	83 c4 10             	add    $0x10,%esp
80104034:	eb de                	jmp    80104014 <fork2+0x93>
  np->cwd = idup(curproc->cwd);
80104036:	83 ec 0c             	sub    $0xc,%esp
80104039:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010403c:	ff 77 68             	pushl  0x68(%edi)
8010403f:	e8 0d d5 ff ff       	call   80101551 <idup>
80104044:	89 43 68             	mov    %eax,0x68(%ebx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104047:	8d 47 6c             	lea    0x6c(%edi),%eax
8010404a:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010404d:	83 c4 0c             	add    $0xc,%esp
80104050:	6a 10                	push   $0x10
80104052:	50                   	push   %eax
80104053:	52                   	push   %edx
80104054:	e8 ef 04 00 00       	call   80104548 <safestrcpy>

  pid = np->pid;
80104059:	8b 73 10             	mov    0x10(%ebx),%esi

  acquire(&ptable.lock);
8010405c:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
80104063:	e8 cd 02 00 00       	call   80104335 <acquire>

  np->state = RUNNABLE;
80104068:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  np->priority = pri;
8010406f:	8b 45 08             	mov    0x8(%ebp),%eax
80104072:	89 43 7c             	mov    %eax,0x7c(%ebx)
  ptable.priorityLevelCount[pri]++;
80104075:	8d 90 0c 0c 00 00    	lea    0xc0c(%eax),%edx
8010407b:	8b 04 95 24 39 11 80 	mov    -0x7feec6dc(,%edx,4),%eax
80104082:	83 c0 01             	add    $0x1,%eax
80104085:	89 04 95 24 39 11 80 	mov    %eax,-0x7feec6dc(,%edx,4)
  ptable.queue[pri][ptable.priorityLevelCount[pri]] = np->pid;
8010408c:	8b 53 10             	mov    0x10(%ebx),%edx
8010408f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104092:	c1 e1 06             	shl    $0x6,%ecx
80104095:	8d 84 08 0c 0b 00 00 	lea    0xb0c(%eax,%ecx,1),%eax
8010409c:	89 14 85 24 39 11 80 	mov    %edx,-0x7feec6dc(,%eax,4)
  np->qtail[pri] = np->qtail[pri] + 1;
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	83 c0 20             	add    $0x20,%eax
801040a9:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
801040ac:	8d 51 01             	lea    0x1(%ecx),%edx
801040af:	89 14 83             	mov    %edx,(%ebx,%eax,4)
  release(&ptable.lock);
801040b2:	c7 04 24 20 39 11 80 	movl   $0x80113920,(%esp)
801040b9:	e8 dc 02 00 00       	call   8010439a <release>
  if(getpinfo(&pstat) == -1) {
801040be:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801040c5:	e8 28 fa ff ff       	call   80103af2 <getpinfo>
801040ca:	83 c4 10             	add    $0x10,%esp
801040cd:	83 f8 ff             	cmp    $0xffffffff,%eax
801040d0:	74 0a                	je     801040dc <fork2+0x15b>
     return -1;
  }
  return pid;
}
801040d2:	89 f0                	mov    %esi,%eax
801040d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040d7:	5b                   	pop    %ebx
801040d8:	5e                   	pop    %esi
801040d9:	5f                   	pop    %edi
801040da:	5d                   	pop    %ebp
801040db:	c3                   	ret    
     return -1;
801040dc:	89 c6                	mov    %eax,%esi
801040de:	eb f2                	jmp    801040d2 <fork2+0x151>
	    return -1;
801040e0:	be ff ff ff ff       	mov    $0xffffffff,%esi
801040e5:	eb eb                	jmp    801040d2 <fork2+0x151>
    return -1;
801040e7:	be ff ff ff ff       	mov    $0xffffffff,%esi
801040ec:	eb e4                	jmp    801040d2 <fork2+0x151>

801040ee <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801040ee:	55                   	push   %ebp
801040ef:	89 e5                	mov    %esp,%ebp
801040f1:	53                   	push   %ebx
801040f2:	83 ec 0c             	sub    $0xc,%esp
801040f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801040f8:	68 30 73 10 80       	push   $0x80107330
801040fd:	8d 43 04             	lea    0x4(%ebx),%eax
80104100:	50                   	push   %eax
80104101:	e8 f3 00 00 00       	call   801041f9 <initlock>
  lk->name = name;
80104106:	8b 45 0c             	mov    0xc(%ebp),%eax
80104109:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
8010410c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80104112:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80104119:	83 c4 10             	add    $0x10,%esp
8010411c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010411f:	c9                   	leave  
80104120:	c3                   	ret    

80104121 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104121:	55                   	push   %ebp
80104122:	89 e5                	mov    %esp,%ebp
80104124:	56                   	push   %esi
80104125:	53                   	push   %ebx
80104126:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104129:	8d 73 04             	lea    0x4(%ebx),%esi
8010412c:	83 ec 0c             	sub    $0xc,%esp
8010412f:	56                   	push   %esi
80104130:	e8 00 02 00 00       	call   80104335 <acquire>
  while (lk->locked) {
80104135:	83 c4 10             	add    $0x10,%esp
80104138:	eb 0d                	jmp    80104147 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
8010413a:	83 ec 08             	sub    $0x8,%esp
8010413d:	56                   	push   %esi
8010413e:	53                   	push   %ebx
8010413f:	e8 4a f5 ff ff       	call   8010368e <sleep>
80104144:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104147:	83 3b 00             	cmpl   $0x0,(%ebx)
8010414a:	75 ee                	jne    8010413a <acquiresleep+0x19>
  }
  lk->locked = 1;
8010414c:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104152:	e8 02 f2 ff ff       	call   80103359 <myproc>
80104157:	8b 40 10             	mov    0x10(%eax),%eax
8010415a:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
8010415d:	83 ec 0c             	sub    $0xc,%esp
80104160:	56                   	push   %esi
80104161:	e8 34 02 00 00       	call   8010439a <release>
}
80104166:	83 c4 10             	add    $0x10,%esp
80104169:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010416c:	5b                   	pop    %ebx
8010416d:	5e                   	pop    %esi
8010416e:	5d                   	pop    %ebp
8010416f:	c3                   	ret    

80104170 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104170:	55                   	push   %ebp
80104171:	89 e5                	mov    %esp,%ebp
80104173:	56                   	push   %esi
80104174:	53                   	push   %ebx
80104175:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104178:	8d 73 04             	lea    0x4(%ebx),%esi
8010417b:	83 ec 0c             	sub    $0xc,%esp
8010417e:	56                   	push   %esi
8010417f:	e8 b1 01 00 00       	call   80104335 <acquire>
  lk->locked = 0;
80104184:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010418a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104191:	89 1c 24             	mov    %ebx,(%esp)
80104194:	e8 5d f6 ff ff       	call   801037f6 <wakeup>
  release(&lk->lk);
80104199:	89 34 24             	mov    %esi,(%esp)
8010419c:	e8 f9 01 00 00       	call   8010439a <release>
}
801041a1:	83 c4 10             	add    $0x10,%esp
801041a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a7:	5b                   	pop    %ebx
801041a8:	5e                   	pop    %esi
801041a9:	5d                   	pop    %ebp
801041aa:	c3                   	ret    

801041ab <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801041ab:	55                   	push   %ebp
801041ac:	89 e5                	mov    %esp,%ebp
801041ae:	56                   	push   %esi
801041af:	53                   	push   %ebx
801041b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801041b3:	8d 73 04             	lea    0x4(%ebx),%esi
801041b6:	83 ec 0c             	sub    $0xc,%esp
801041b9:	56                   	push   %esi
801041ba:	e8 76 01 00 00       	call   80104335 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801041bf:	83 c4 10             	add    $0x10,%esp
801041c2:	83 3b 00             	cmpl   $0x0,(%ebx)
801041c5:	75 17                	jne    801041de <holdingsleep+0x33>
801041c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	56                   	push   %esi
801041d0:	e8 c5 01 00 00       	call   8010439a <release>
  return r;
}
801041d5:	89 d8                	mov    %ebx,%eax
801041d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041da:	5b                   	pop    %ebx
801041db:	5e                   	pop    %esi
801041dc:	5d                   	pop    %ebp
801041dd:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
801041de:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801041e1:	e8 73 f1 ff ff       	call   80103359 <myproc>
801041e6:	3b 58 10             	cmp    0x10(%eax),%ebx
801041e9:	74 07                	je     801041f2 <holdingsleep+0x47>
801041eb:	bb 00 00 00 00       	mov    $0x0,%ebx
801041f0:	eb da                	jmp    801041cc <holdingsleep+0x21>
801041f2:	bb 01 00 00 00       	mov    $0x1,%ebx
801041f7:	eb d3                	jmp    801041cc <holdingsleep+0x21>

801041f9 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801041f9:	55                   	push   %ebp
801041fa:	89 e5                	mov    %esp,%ebp
801041fc:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801041ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80104202:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104205:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010420b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104212:	5d                   	pop    %ebp
80104213:	c3                   	ret    

80104214 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104214:	55                   	push   %ebp
80104215:	89 e5                	mov    %esp,%ebp
80104217:	53                   	push   %ebx
80104218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80104221:	b8 00 00 00 00       	mov    $0x0,%eax
80104226:	83 f8 09             	cmp    $0x9,%eax
80104229:	7f 25                	jg     80104250 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010422b:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104231:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104237:	77 17                	ja     80104250 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104239:	8b 5a 04             	mov    0x4(%edx),%ebx
8010423c:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
8010423f:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80104241:	83 c0 01             	add    $0x1,%eax
80104244:	eb e0                	jmp    80104226 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80104246:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
8010424d:	83 c0 01             	add    $0x1,%eax
80104250:	83 f8 09             	cmp    $0x9,%eax
80104253:	7e f1                	jle    80104246 <getcallerpcs+0x32>
}
80104255:	5b                   	pop    %ebx
80104256:	5d                   	pop    %ebp
80104257:	c3                   	ret    

80104258 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104258:	55                   	push   %ebp
80104259:	89 e5                	mov    %esp,%ebp
8010425b:	53                   	push   %ebx
8010425c:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010425f:	9c                   	pushf  
80104260:	5b                   	pop    %ebx
  asm volatile("cli");
80104261:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104262:	e8 7b f0 ff ff       	call   801032e2 <mycpu>
80104267:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
8010426e:	74 12                	je     80104282 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104270:	e8 6d f0 ff ff       	call   801032e2 <mycpu>
80104275:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
8010427c:	83 c4 04             	add    $0x4,%esp
8010427f:	5b                   	pop    %ebx
80104280:	5d                   	pop    %ebp
80104281:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80104282:	e8 5b f0 ff ff       	call   801032e2 <mycpu>
80104287:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010428d:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104293:	eb db                	jmp    80104270 <pushcli+0x18>

80104295 <popcli>:

void
popcli(void)
{
80104295:	55                   	push   %ebp
80104296:	89 e5                	mov    %esp,%ebp
80104298:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010429b:	9c                   	pushf  
8010429c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010429d:	f6 c4 02             	test   $0x2,%ah
801042a0:	75 28                	jne    801042ca <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
801042a2:	e8 3b f0 ff ff       	call   801032e2 <mycpu>
801042a7:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
801042ad:	8d 51 ff             	lea    -0x1(%ecx),%edx
801042b0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801042b6:	85 d2                	test   %edx,%edx
801042b8:	78 1d                	js     801042d7 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801042ba:	e8 23 f0 ff ff       	call   801032e2 <mycpu>
801042bf:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
801042c6:	74 1c                	je     801042e4 <popcli+0x4f>
    sti();
}
801042c8:	c9                   	leave  
801042c9:	c3                   	ret    
    panic("popcli - interruptible");
801042ca:	83 ec 0c             	sub    $0xc,%esp
801042cd:	68 3b 73 10 80       	push   $0x8010733b
801042d2:	e8 71 c0 ff ff       	call   80100348 <panic>
    panic("popcli");
801042d7:	83 ec 0c             	sub    $0xc,%esp
801042da:	68 52 73 10 80       	push   $0x80107352
801042df:	e8 64 c0 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801042e4:	e8 f9 ef ff ff       	call   801032e2 <mycpu>
801042e9:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
801042f0:	74 d6                	je     801042c8 <popcli+0x33>
  asm volatile("sti");
801042f2:	fb                   	sti    
}
801042f3:	eb d3                	jmp    801042c8 <popcli+0x33>

801042f5 <holding>:
{
801042f5:	55                   	push   %ebp
801042f6:	89 e5                	mov    %esp,%ebp
801042f8:	53                   	push   %ebx
801042f9:	83 ec 04             	sub    $0x4,%esp
801042fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801042ff:	e8 54 ff ff ff       	call   80104258 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104304:	83 3b 00             	cmpl   $0x0,(%ebx)
80104307:	75 12                	jne    8010431b <holding+0x26>
80104309:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
8010430e:	e8 82 ff ff ff       	call   80104295 <popcli>
}
80104313:	89 d8                	mov    %ebx,%eax
80104315:	83 c4 04             	add    $0x4,%esp
80104318:	5b                   	pop    %ebx
80104319:	5d                   	pop    %ebp
8010431a:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
8010431b:	8b 5b 08             	mov    0x8(%ebx),%ebx
8010431e:	e8 bf ef ff ff       	call   801032e2 <mycpu>
80104323:	39 c3                	cmp    %eax,%ebx
80104325:	74 07                	je     8010432e <holding+0x39>
80104327:	bb 00 00 00 00       	mov    $0x0,%ebx
8010432c:	eb e0                	jmp    8010430e <holding+0x19>
8010432e:	bb 01 00 00 00       	mov    $0x1,%ebx
80104333:	eb d9                	jmp    8010430e <holding+0x19>

80104335 <acquire>:
{
80104335:	55                   	push   %ebp
80104336:	89 e5                	mov    %esp,%ebp
80104338:	53                   	push   %ebx
80104339:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010433c:	e8 17 ff ff ff       	call   80104258 <pushcli>
  if(holding(lk))
80104341:	83 ec 0c             	sub    $0xc,%esp
80104344:	ff 75 08             	pushl  0x8(%ebp)
80104347:	e8 a9 ff ff ff       	call   801042f5 <holding>
8010434c:	83 c4 10             	add    $0x10,%esp
8010434f:	85 c0                	test   %eax,%eax
80104351:	75 3a                	jne    8010438d <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80104353:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80104356:	b8 01 00 00 00       	mov    $0x1,%eax
8010435b:	f0 87 02             	lock xchg %eax,(%edx)
8010435e:	85 c0                	test   %eax,%eax
80104360:	75 f1                	jne    80104353 <acquire+0x1e>
  __sync_synchronize();
80104362:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104367:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010436a:	e8 73 ef ff ff       	call   801032e2 <mycpu>
8010436f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104372:	8b 45 08             	mov    0x8(%ebp),%eax
80104375:	83 c0 0c             	add    $0xc,%eax
80104378:	83 ec 08             	sub    $0x8,%esp
8010437b:	50                   	push   %eax
8010437c:	8d 45 08             	lea    0x8(%ebp),%eax
8010437f:	50                   	push   %eax
80104380:	e8 8f fe ff ff       	call   80104214 <getcallerpcs>
}
80104385:	83 c4 10             	add    $0x10,%esp
80104388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010438b:	c9                   	leave  
8010438c:	c3                   	ret    
    panic("acquire");
8010438d:	83 ec 0c             	sub    $0xc,%esp
80104390:	68 59 73 10 80       	push   $0x80107359
80104395:	e8 ae bf ff ff       	call   80100348 <panic>

8010439a <release>:
{
8010439a:	55                   	push   %ebp
8010439b:	89 e5                	mov    %esp,%ebp
8010439d:	53                   	push   %ebx
8010439e:	83 ec 10             	sub    $0x10,%esp
801043a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
801043a4:	53                   	push   %ebx
801043a5:	e8 4b ff ff ff       	call   801042f5 <holding>
801043aa:	83 c4 10             	add    $0x10,%esp
801043ad:	85 c0                	test   %eax,%eax
801043af:	74 23                	je     801043d4 <release+0x3a>
  lk->pcs[0] = 0;
801043b1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801043b8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801043bf:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801043c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
801043ca:	e8 c6 fe ff ff       	call   80104295 <popcli>
}
801043cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043d2:	c9                   	leave  
801043d3:	c3                   	ret    
    panic("release");
801043d4:	83 ec 0c             	sub    $0xc,%esp
801043d7:	68 61 73 10 80       	push   $0x80107361
801043dc:	e8 67 bf ff ff       	call   80100348 <panic>

801043e1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801043e1:	55                   	push   %ebp
801043e2:	89 e5                	mov    %esp,%ebp
801043e4:	57                   	push   %edi
801043e5:	53                   	push   %ebx
801043e6:	8b 55 08             	mov    0x8(%ebp),%edx
801043e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
801043ec:	f6 c2 03             	test   $0x3,%dl
801043ef:	75 05                	jne    801043f6 <memset+0x15>
801043f1:	f6 c1 03             	test   $0x3,%cl
801043f4:	74 0e                	je     80104404 <memset+0x23>
  asm volatile("cld; rep stosb" :
801043f6:	89 d7                	mov    %edx,%edi
801043f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801043fb:	fc                   	cld    
801043fc:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
801043fe:	89 d0                	mov    %edx,%eax
80104400:	5b                   	pop    %ebx
80104401:	5f                   	pop    %edi
80104402:	5d                   	pop    %ebp
80104403:	c3                   	ret    
    c &= 0xFF;
80104404:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104408:	c1 e9 02             	shr    $0x2,%ecx
8010440b:	89 f8                	mov    %edi,%eax
8010440d:	c1 e0 18             	shl    $0x18,%eax
80104410:	89 fb                	mov    %edi,%ebx
80104412:	c1 e3 10             	shl    $0x10,%ebx
80104415:	09 d8                	or     %ebx,%eax
80104417:	89 fb                	mov    %edi,%ebx
80104419:	c1 e3 08             	shl    $0x8,%ebx
8010441c:	09 d8                	or     %ebx,%eax
8010441e:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104420:	89 d7                	mov    %edx,%edi
80104422:	fc                   	cld    
80104423:	f3 ab                	rep stos %eax,%es:(%edi)
80104425:	eb d7                	jmp    801043fe <memset+0x1d>

80104427 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104427:	55                   	push   %ebp
80104428:	89 e5                	mov    %esp,%ebp
8010442a:	56                   	push   %esi
8010442b:	53                   	push   %ebx
8010442c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010442f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104432:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104435:	8d 70 ff             	lea    -0x1(%eax),%esi
80104438:	85 c0                	test   %eax,%eax
8010443a:	74 1c                	je     80104458 <memcmp+0x31>
    if(*s1 != *s2)
8010443c:	0f b6 01             	movzbl (%ecx),%eax
8010443f:	0f b6 1a             	movzbl (%edx),%ebx
80104442:	38 d8                	cmp    %bl,%al
80104444:	75 0a                	jne    80104450 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80104446:	83 c1 01             	add    $0x1,%ecx
80104449:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
8010444c:	89 f0                	mov    %esi,%eax
8010444e:	eb e5                	jmp    80104435 <memcmp+0xe>
      return *s1 - *s2;
80104450:	0f b6 c0             	movzbl %al,%eax
80104453:	0f b6 db             	movzbl %bl,%ebx
80104456:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104458:	5b                   	pop    %ebx
80104459:	5e                   	pop    %esi
8010445a:	5d                   	pop    %ebp
8010445b:	c3                   	ret    

8010445c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010445c:	55                   	push   %ebp
8010445d:	89 e5                	mov    %esp,%ebp
8010445f:	56                   	push   %esi
80104460:	53                   	push   %ebx
80104461:	8b 45 08             	mov    0x8(%ebp),%eax
80104464:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104467:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010446a:	39 c1                	cmp    %eax,%ecx
8010446c:	73 3a                	jae    801044a8 <memmove+0x4c>
8010446e:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80104471:	39 c3                	cmp    %eax,%ebx
80104473:	76 37                	jbe    801044ac <memmove+0x50>
    s += n;
    d += n;
80104475:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80104478:	eb 0d                	jmp    80104487 <memmove+0x2b>
      *--d = *--s;
8010447a:	83 eb 01             	sub    $0x1,%ebx
8010447d:	83 e9 01             	sub    $0x1,%ecx
80104480:	0f b6 13             	movzbl (%ebx),%edx
80104483:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80104485:	89 f2                	mov    %esi,%edx
80104487:	8d 72 ff             	lea    -0x1(%edx),%esi
8010448a:	85 d2                	test   %edx,%edx
8010448c:	75 ec                	jne    8010447a <memmove+0x1e>
8010448e:	eb 14                	jmp    801044a4 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104490:	0f b6 11             	movzbl (%ecx),%edx
80104493:	88 13                	mov    %dl,(%ebx)
80104495:	8d 5b 01             	lea    0x1(%ebx),%ebx
80104498:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
8010449b:	89 f2                	mov    %esi,%edx
8010449d:	8d 72 ff             	lea    -0x1(%edx),%esi
801044a0:	85 d2                	test   %edx,%edx
801044a2:	75 ec                	jne    80104490 <memmove+0x34>

  return dst;
}
801044a4:	5b                   	pop    %ebx
801044a5:	5e                   	pop    %esi
801044a6:	5d                   	pop    %ebp
801044a7:	c3                   	ret    
801044a8:	89 c3                	mov    %eax,%ebx
801044aa:	eb f1                	jmp    8010449d <memmove+0x41>
801044ac:	89 c3                	mov    %eax,%ebx
801044ae:	eb ed                	jmp    8010449d <memmove+0x41>

801044b0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801044b0:	55                   	push   %ebp
801044b1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801044b3:	ff 75 10             	pushl  0x10(%ebp)
801044b6:	ff 75 0c             	pushl  0xc(%ebp)
801044b9:	ff 75 08             	pushl  0x8(%ebp)
801044bc:	e8 9b ff ff ff       	call   8010445c <memmove>
}
801044c1:	c9                   	leave  
801044c2:	c3                   	ret    

801044c3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801044c3:	55                   	push   %ebp
801044c4:	89 e5                	mov    %esp,%ebp
801044c6:	53                   	push   %ebx
801044c7:	8b 55 08             	mov    0x8(%ebp),%edx
801044ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801044cd:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
801044d0:	eb 09                	jmp    801044db <strncmp+0x18>
    n--, p++, q++;
801044d2:	83 e8 01             	sub    $0x1,%eax
801044d5:	83 c2 01             	add    $0x1,%edx
801044d8:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801044db:	85 c0                	test   %eax,%eax
801044dd:	74 0b                	je     801044ea <strncmp+0x27>
801044df:	0f b6 1a             	movzbl (%edx),%ebx
801044e2:	84 db                	test   %bl,%bl
801044e4:	74 04                	je     801044ea <strncmp+0x27>
801044e6:	3a 19                	cmp    (%ecx),%bl
801044e8:	74 e8                	je     801044d2 <strncmp+0xf>
  if(n == 0)
801044ea:	85 c0                	test   %eax,%eax
801044ec:	74 0b                	je     801044f9 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
801044ee:	0f b6 02             	movzbl (%edx),%eax
801044f1:	0f b6 11             	movzbl (%ecx),%edx
801044f4:	29 d0                	sub    %edx,%eax
}
801044f6:	5b                   	pop    %ebx
801044f7:	5d                   	pop    %ebp
801044f8:	c3                   	ret    
    return 0;
801044f9:	b8 00 00 00 00       	mov    $0x0,%eax
801044fe:	eb f6                	jmp    801044f6 <strncmp+0x33>

80104500 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104500:	55                   	push   %ebp
80104501:	89 e5                	mov    %esp,%ebp
80104503:	57                   	push   %edi
80104504:	56                   	push   %esi
80104505:	53                   	push   %ebx
80104506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104509:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010450c:	8b 45 08             	mov    0x8(%ebp),%eax
8010450f:	eb 04                	jmp    80104515 <strncpy+0x15>
80104511:	89 fb                	mov    %edi,%ebx
80104513:	89 f0                	mov    %esi,%eax
80104515:	8d 51 ff             	lea    -0x1(%ecx),%edx
80104518:	85 c9                	test   %ecx,%ecx
8010451a:	7e 1d                	jle    80104539 <strncpy+0x39>
8010451c:	8d 7b 01             	lea    0x1(%ebx),%edi
8010451f:	8d 70 01             	lea    0x1(%eax),%esi
80104522:	0f b6 1b             	movzbl (%ebx),%ebx
80104525:	88 18                	mov    %bl,(%eax)
80104527:	89 d1                	mov    %edx,%ecx
80104529:	84 db                	test   %bl,%bl
8010452b:	75 e4                	jne    80104511 <strncpy+0x11>
8010452d:	89 f0                	mov    %esi,%eax
8010452f:	eb 08                	jmp    80104539 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104531:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104534:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104536:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80104539:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010453c:	85 d2                	test   %edx,%edx
8010453e:	7f f1                	jg     80104531 <strncpy+0x31>
  return os;
}
80104540:	8b 45 08             	mov    0x8(%ebp),%eax
80104543:	5b                   	pop    %ebx
80104544:	5e                   	pop    %esi
80104545:	5f                   	pop    %edi
80104546:	5d                   	pop    %ebp
80104547:	c3                   	ret    

80104548 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104548:	55                   	push   %ebp
80104549:	89 e5                	mov    %esp,%ebp
8010454b:	57                   	push   %edi
8010454c:	56                   	push   %esi
8010454d:	53                   	push   %ebx
8010454e:	8b 45 08             	mov    0x8(%ebp),%eax
80104551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104554:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104557:	85 d2                	test   %edx,%edx
80104559:	7e 23                	jle    8010457e <safestrcpy+0x36>
8010455b:	89 c1                	mov    %eax,%ecx
8010455d:	eb 04                	jmp    80104563 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010455f:	89 fb                	mov    %edi,%ebx
80104561:	89 f1                	mov    %esi,%ecx
80104563:	83 ea 01             	sub    $0x1,%edx
80104566:	85 d2                	test   %edx,%edx
80104568:	7e 11                	jle    8010457b <safestrcpy+0x33>
8010456a:	8d 7b 01             	lea    0x1(%ebx),%edi
8010456d:	8d 71 01             	lea    0x1(%ecx),%esi
80104570:	0f b6 1b             	movzbl (%ebx),%ebx
80104573:	88 19                	mov    %bl,(%ecx)
80104575:	84 db                	test   %bl,%bl
80104577:	75 e6                	jne    8010455f <safestrcpy+0x17>
80104579:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010457b:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
8010457e:	5b                   	pop    %ebx
8010457f:	5e                   	pop    %esi
80104580:	5f                   	pop    %edi
80104581:	5d                   	pop    %ebp
80104582:	c3                   	ret    

80104583 <strlen>:

int
strlen(const char *s)
{
80104583:	55                   	push   %ebp
80104584:	89 e5                	mov    %esp,%ebp
80104586:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104589:	b8 00 00 00 00       	mov    $0x0,%eax
8010458e:	eb 03                	jmp    80104593 <strlen+0x10>
80104590:	83 c0 01             	add    $0x1,%eax
80104593:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104597:	75 f7                	jne    80104590 <strlen+0xd>
    ;
  return n;
}
80104599:	5d                   	pop    %ebp
8010459a:	c3                   	ret    

8010459b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010459b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010459f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801045a3:	55                   	push   %ebp
  pushl %ebx
801045a4:	53                   	push   %ebx
  pushl %esi
801045a5:	56                   	push   %esi
  pushl %edi
801045a6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801045a7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801045a9:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801045ab:	5f                   	pop    %edi
  popl %esi
801045ac:	5e                   	pop    %esi
  popl %ebx
801045ad:	5b                   	pop    %ebx
  popl %ebp
801045ae:	5d                   	pop    %ebp
  ret
801045af:	c3                   	ret    

801045b0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801045b0:	55                   	push   %ebp
801045b1:	89 e5                	mov    %esp,%ebp
801045b3:	53                   	push   %ebx
801045b4:	83 ec 04             	sub    $0x4,%esp
801045b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801045ba:	e8 9a ed ff ff       	call   80103359 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801045bf:	8b 00                	mov    (%eax),%eax
801045c1:	39 d8                	cmp    %ebx,%eax
801045c3:	76 19                	jbe    801045de <fetchint+0x2e>
801045c5:	8d 53 04             	lea    0x4(%ebx),%edx
801045c8:	39 d0                	cmp    %edx,%eax
801045ca:	72 19                	jb     801045e5 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801045cc:	8b 13                	mov    (%ebx),%edx
801045ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801045d1:	89 10                	mov    %edx,(%eax)
  return 0;
801045d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045d8:	83 c4 04             	add    $0x4,%esp
801045db:	5b                   	pop    %ebx
801045dc:	5d                   	pop    %ebp
801045dd:	c3                   	ret    
    return -1;
801045de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e3:	eb f3                	jmp    801045d8 <fetchint+0x28>
801045e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ea:	eb ec                	jmp    801045d8 <fetchint+0x28>

801045ec <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801045ec:	55                   	push   %ebp
801045ed:	89 e5                	mov    %esp,%ebp
801045ef:	53                   	push   %ebx
801045f0:	83 ec 04             	sub    $0x4,%esp
801045f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801045f6:	e8 5e ed ff ff       	call   80103359 <myproc>

  if(addr >= curproc->sz)
801045fb:	39 18                	cmp    %ebx,(%eax)
801045fd:	76 26                	jbe    80104625 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
801045ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80104602:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104604:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104606:	89 d8                	mov    %ebx,%eax
80104608:	39 d0                	cmp    %edx,%eax
8010460a:	73 0e                	jae    8010461a <fetchstr+0x2e>
    if(*s == 0)
8010460c:	80 38 00             	cmpb   $0x0,(%eax)
8010460f:	74 05                	je     80104616 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104611:	83 c0 01             	add    $0x1,%eax
80104614:	eb f2                	jmp    80104608 <fetchstr+0x1c>
      return s - *pp;
80104616:	29 d8                	sub    %ebx,%eax
80104618:	eb 05                	jmp    8010461f <fetchstr+0x33>
  }
  return -1;
8010461a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010461f:	83 c4 04             	add    $0x4,%esp
80104622:	5b                   	pop    %ebx
80104623:	5d                   	pop    %ebp
80104624:	c3                   	ret    
    return -1;
80104625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462a:	eb f3                	jmp    8010461f <fetchstr+0x33>

8010462c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010462c:	55                   	push   %ebp
8010462d:	89 e5                	mov    %esp,%ebp
8010462f:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104632:	e8 22 ed ff ff       	call   80103359 <myproc>
80104637:	8b 50 18             	mov    0x18(%eax),%edx
8010463a:	8b 45 08             	mov    0x8(%ebp),%eax
8010463d:	c1 e0 02             	shl    $0x2,%eax
80104640:	03 42 44             	add    0x44(%edx),%eax
80104643:	83 ec 08             	sub    $0x8,%esp
80104646:	ff 75 0c             	pushl  0xc(%ebp)
80104649:	83 c0 04             	add    $0x4,%eax
8010464c:	50                   	push   %eax
8010464d:	e8 5e ff ff ff       	call   801045b0 <fetchint>
}
80104652:	c9                   	leave  
80104653:	c3                   	ret    

80104654 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104654:	55                   	push   %ebp
80104655:	89 e5                	mov    %esp,%ebp
80104657:	56                   	push   %esi
80104658:	53                   	push   %ebx
80104659:	83 ec 10             	sub    $0x10,%esp
8010465c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010465f:	e8 f5 ec ff ff       	call   80103359 <myproc>
80104664:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104666:	83 ec 08             	sub    $0x8,%esp
80104669:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010466c:	50                   	push   %eax
8010466d:	ff 75 08             	pushl  0x8(%ebp)
80104670:	e8 b7 ff ff ff       	call   8010462c <argint>
80104675:	83 c4 10             	add    $0x10,%esp
80104678:	85 c0                	test   %eax,%eax
8010467a:	78 24                	js     801046a0 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010467c:	85 db                	test   %ebx,%ebx
8010467e:	78 27                	js     801046a7 <argptr+0x53>
80104680:	8b 16                	mov    (%esi),%edx
80104682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104685:	39 c2                	cmp    %eax,%edx
80104687:	76 25                	jbe    801046ae <argptr+0x5a>
80104689:	01 c3                	add    %eax,%ebx
8010468b:	39 da                	cmp    %ebx,%edx
8010468d:	72 26                	jb     801046b5 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010468f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104692:	89 02                	mov    %eax,(%edx)
  return 0;
80104694:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104699:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010469c:	5b                   	pop    %ebx
8010469d:	5e                   	pop    %esi
8010469e:	5d                   	pop    %ebp
8010469f:	c3                   	ret    
    return -1;
801046a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a5:	eb f2                	jmp    80104699 <argptr+0x45>
    return -1;
801046a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ac:	eb eb                	jmp    80104699 <argptr+0x45>
801046ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046b3:	eb e4                	jmp    80104699 <argptr+0x45>
801046b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ba:	eb dd                	jmp    80104699 <argptr+0x45>

801046bc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801046c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801046c5:	50                   	push   %eax
801046c6:	ff 75 08             	pushl  0x8(%ebp)
801046c9:	e8 5e ff ff ff       	call   8010462c <argint>
801046ce:	83 c4 10             	add    $0x10,%esp
801046d1:	85 c0                	test   %eax,%eax
801046d3:	78 13                	js     801046e8 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801046d5:	83 ec 08             	sub    $0x8,%esp
801046d8:	ff 75 0c             	pushl  0xc(%ebp)
801046db:	ff 75 f4             	pushl  -0xc(%ebp)
801046de:	e8 09 ff ff ff       	call   801045ec <fetchstr>
801046e3:	83 c4 10             	add    $0x10,%esp
}
801046e6:	c9                   	leave  
801046e7:	c3                   	ret    
    return -1;
801046e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ed:	eb f7                	jmp    801046e6 <argstr+0x2a>

801046ef <syscall>:
[SYS_fork2]   sys_fork2,
};

void
syscall(void)
{
801046ef:	55                   	push   %ebp
801046f0:	89 e5                	mov    %esp,%ebp
801046f2:	53                   	push   %ebx
801046f3:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801046f6:	e8 5e ec ff ff       	call   80103359 <myproc>
801046fb:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801046fd:	8b 40 18             	mov    0x18(%eax),%eax
80104700:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104703:	8d 50 ff             	lea    -0x1(%eax),%edx
80104706:	83 fa 18             	cmp    $0x18,%edx
80104709:	77 18                	ja     80104723 <syscall+0x34>
8010470b:	8b 14 85 a0 73 10 80 	mov    -0x7fef8c60(,%eax,4),%edx
80104712:	85 d2                	test   %edx,%edx
80104714:	74 0d                	je     80104723 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104716:	ff d2                	call   *%edx
80104718:	8b 53 18             	mov    0x18(%ebx),%edx
8010471b:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010471e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104721:	c9                   	leave  
80104722:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104723:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104726:	50                   	push   %eax
80104727:	52                   	push   %edx
80104728:	ff 73 10             	pushl  0x10(%ebx)
8010472b:	68 69 73 10 80       	push   $0x80107369
80104730:	e8 d6 be ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104735:	8b 43 18             	mov    0x18(%ebx),%eax
80104738:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010473f:	83 c4 10             	add    $0x10,%esp
}
80104742:	eb da                	jmp    8010471e <syscall+0x2f>

80104744 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104744:	55                   	push   %ebp
80104745:	89 e5                	mov    %esp,%ebp
80104747:	56                   	push   %esi
80104748:	53                   	push   %ebx
80104749:	83 ec 18             	sub    $0x18,%esp
8010474c:	89 d6                	mov    %edx,%esi
8010474e:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104750:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104753:	52                   	push   %edx
80104754:	50                   	push   %eax
80104755:	e8 d2 fe ff ff       	call   8010462c <argint>
8010475a:	83 c4 10             	add    $0x10,%esp
8010475d:	85 c0                	test   %eax,%eax
8010475f:	78 2e                	js     8010478f <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104761:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104765:	77 2f                	ja     80104796 <argfd+0x52>
80104767:	e8 ed eb ff ff       	call   80103359 <myproc>
8010476c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010476f:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104773:	85 c0                	test   %eax,%eax
80104775:	74 26                	je     8010479d <argfd+0x59>
    return -1;
  if(pfd)
80104777:	85 f6                	test   %esi,%esi
80104779:	74 02                	je     8010477d <argfd+0x39>
    *pfd = fd;
8010477b:	89 16                	mov    %edx,(%esi)
  if(pf)
8010477d:	85 db                	test   %ebx,%ebx
8010477f:	74 23                	je     801047a4 <argfd+0x60>
    *pf = f;
80104781:	89 03                	mov    %eax,(%ebx)
  return 0;
80104783:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104788:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010478b:	5b                   	pop    %ebx
8010478c:	5e                   	pop    %esi
8010478d:	5d                   	pop    %ebp
8010478e:	c3                   	ret    
    return -1;
8010478f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104794:	eb f2                	jmp    80104788 <argfd+0x44>
    return -1;
80104796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010479b:	eb eb                	jmp    80104788 <argfd+0x44>
8010479d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a2:	eb e4                	jmp    80104788 <argfd+0x44>
  return 0;
801047a4:	b8 00 00 00 00       	mov    $0x0,%eax
801047a9:	eb dd                	jmp    80104788 <argfd+0x44>

801047ab <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801047ab:	55                   	push   %ebp
801047ac:	89 e5                	mov    %esp,%ebp
801047ae:	53                   	push   %ebx
801047af:	83 ec 04             	sub    $0x4,%esp
801047b2:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801047b4:	e8 a0 eb ff ff       	call   80103359 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801047b9:	ba 00 00 00 00       	mov    $0x0,%edx
801047be:	83 fa 0f             	cmp    $0xf,%edx
801047c1:	7f 18                	jg     801047db <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801047c3:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801047c8:	74 05                	je     801047cf <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801047ca:	83 c2 01             	add    $0x1,%edx
801047cd:	eb ef                	jmp    801047be <fdalloc+0x13>
      curproc->ofile[fd] = f;
801047cf:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801047d3:	89 d0                	mov    %edx,%eax
801047d5:	83 c4 04             	add    $0x4,%esp
801047d8:	5b                   	pop    %ebx
801047d9:	5d                   	pop    %ebp
801047da:	c3                   	ret    
  return -1;
801047db:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801047e0:	eb f1                	jmp    801047d3 <fdalloc+0x28>

801047e2 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801047e2:	55                   	push   %ebp
801047e3:	89 e5                	mov    %esp,%ebp
801047e5:	56                   	push   %esi
801047e6:	53                   	push   %ebx
801047e7:	83 ec 10             	sub    $0x10,%esp
801047ea:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801047ec:	b8 20 00 00 00       	mov    $0x20,%eax
801047f1:	89 c6                	mov    %eax,%esi
801047f3:	39 43 58             	cmp    %eax,0x58(%ebx)
801047f6:	76 2e                	jbe    80104826 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047f8:	6a 10                	push   $0x10
801047fa:	50                   	push   %eax
801047fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801047fe:	50                   	push   %eax
801047ff:	53                   	push   %ebx
80104800:	e8 6e cf ff ff       	call   80101773 <readi>
80104805:	83 c4 10             	add    $0x10,%esp
80104808:	83 f8 10             	cmp    $0x10,%eax
8010480b:	75 0c                	jne    80104819 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010480d:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104812:	75 1e                	jne    80104832 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104814:	8d 46 10             	lea    0x10(%esi),%eax
80104817:	eb d8                	jmp    801047f1 <isdirempty+0xf>
      panic("isdirempty: readi");
80104819:	83 ec 0c             	sub    $0xc,%esp
8010481c:	68 08 74 10 80       	push   $0x80107408
80104821:	e8 22 bb ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104826:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010482b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010482e:	5b                   	pop    %ebx
8010482f:	5e                   	pop    %esi
80104830:	5d                   	pop    %ebp
80104831:	c3                   	ret    
      return 0;
80104832:	b8 00 00 00 00       	mov    $0x0,%eax
80104837:	eb f2                	jmp    8010482b <isdirempty+0x49>

80104839 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104839:	55                   	push   %ebp
8010483a:	89 e5                	mov    %esp,%ebp
8010483c:	57                   	push   %edi
8010483d:	56                   	push   %esi
8010483e:	53                   	push   %ebx
8010483f:	83 ec 44             	sub    $0x44,%esp
80104842:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104845:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104848:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010484b:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010484e:	52                   	push   %edx
8010484f:	50                   	push   %eax
80104850:	e8 a4 d3 ff ff       	call   80101bf9 <nameiparent>
80104855:	89 c6                	mov    %eax,%esi
80104857:	83 c4 10             	add    $0x10,%esp
8010485a:	85 c0                	test   %eax,%eax
8010485c:	0f 84 3a 01 00 00    	je     8010499c <create+0x163>
    return 0;
  ilock(dp);
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	50                   	push   %eax
80104866:	e8 16 cd ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010486b:	83 c4 0c             	add    $0xc,%esp
8010486e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104871:	50                   	push   %eax
80104872:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104875:	50                   	push   %eax
80104876:	56                   	push   %esi
80104877:	e8 34 d1 ff ff       	call   801019b0 <dirlookup>
8010487c:	89 c3                	mov    %eax,%ebx
8010487e:	83 c4 10             	add    $0x10,%esp
80104881:	85 c0                	test   %eax,%eax
80104883:	74 3f                	je     801048c4 <create+0x8b>
    iunlockput(dp);
80104885:	83 ec 0c             	sub    $0xc,%esp
80104888:	56                   	push   %esi
80104889:	e8 9a ce ff ff       	call   80101728 <iunlockput>
    ilock(ip);
8010488e:	89 1c 24             	mov    %ebx,(%esp)
80104891:	e8 eb cc ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104896:	83 c4 10             	add    $0x10,%esp
80104899:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010489e:	75 11                	jne    801048b1 <create+0x78>
801048a0:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801048a5:	75 0a                	jne    801048b1 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801048a7:	89 d8                	mov    %ebx,%eax
801048a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048ac:	5b                   	pop    %ebx
801048ad:	5e                   	pop    %esi
801048ae:	5f                   	pop    %edi
801048af:	5d                   	pop    %ebp
801048b0:	c3                   	ret    
    iunlockput(ip);
801048b1:	83 ec 0c             	sub    $0xc,%esp
801048b4:	53                   	push   %ebx
801048b5:	e8 6e ce ff ff       	call   80101728 <iunlockput>
    return 0;
801048ba:	83 c4 10             	add    $0x10,%esp
801048bd:	bb 00 00 00 00       	mov    $0x0,%ebx
801048c2:	eb e3                	jmp    801048a7 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801048c4:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801048c8:	83 ec 08             	sub    $0x8,%esp
801048cb:	50                   	push   %eax
801048cc:	ff 36                	pushl  (%esi)
801048ce:	e8 ab ca ff ff       	call   8010137e <ialloc>
801048d3:	89 c3                	mov    %eax,%ebx
801048d5:	83 c4 10             	add    $0x10,%esp
801048d8:	85 c0                	test   %eax,%eax
801048da:	74 55                	je     80104931 <create+0xf8>
  ilock(ip);
801048dc:	83 ec 0c             	sub    $0xc,%esp
801048df:	50                   	push   %eax
801048e0:	e8 9c cc ff ff       	call   80101581 <ilock>
  ip->major = major;
801048e5:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801048e9:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801048ed:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801048f1:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801048f7:	89 1c 24             	mov    %ebx,(%esp)
801048fa:	e8 21 cb ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801048ff:	83 c4 10             	add    $0x10,%esp
80104902:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104907:	74 35                	je     8010493e <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104909:	83 ec 04             	sub    $0x4,%esp
8010490c:	ff 73 04             	pushl  0x4(%ebx)
8010490f:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104912:	50                   	push   %eax
80104913:	56                   	push   %esi
80104914:	e8 17 d2 ff ff       	call   80101b30 <dirlink>
80104919:	83 c4 10             	add    $0x10,%esp
8010491c:	85 c0                	test   %eax,%eax
8010491e:	78 6f                	js     8010498f <create+0x156>
  iunlockput(dp);
80104920:	83 ec 0c             	sub    $0xc,%esp
80104923:	56                   	push   %esi
80104924:	e8 ff cd ff ff       	call   80101728 <iunlockput>
  return ip;
80104929:	83 c4 10             	add    $0x10,%esp
8010492c:	e9 76 ff ff ff       	jmp    801048a7 <create+0x6e>
    panic("create: ialloc");
80104931:	83 ec 0c             	sub    $0xc,%esp
80104934:	68 1a 74 10 80       	push   $0x8010741a
80104939:	e8 0a ba ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010493e:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104942:	83 c0 01             	add    $0x1,%eax
80104945:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104949:	83 ec 0c             	sub    $0xc,%esp
8010494c:	56                   	push   %esi
8010494d:	e8 ce ca ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104952:	83 c4 0c             	add    $0xc,%esp
80104955:	ff 73 04             	pushl  0x4(%ebx)
80104958:	68 2a 74 10 80       	push   $0x8010742a
8010495d:	53                   	push   %ebx
8010495e:	e8 cd d1 ff ff       	call   80101b30 <dirlink>
80104963:	83 c4 10             	add    $0x10,%esp
80104966:	85 c0                	test   %eax,%eax
80104968:	78 18                	js     80104982 <create+0x149>
8010496a:	83 ec 04             	sub    $0x4,%esp
8010496d:	ff 76 04             	pushl  0x4(%esi)
80104970:	68 29 74 10 80       	push   $0x80107429
80104975:	53                   	push   %ebx
80104976:	e8 b5 d1 ff ff       	call   80101b30 <dirlink>
8010497b:	83 c4 10             	add    $0x10,%esp
8010497e:	85 c0                	test   %eax,%eax
80104980:	79 87                	jns    80104909 <create+0xd0>
      panic("create dots");
80104982:	83 ec 0c             	sub    $0xc,%esp
80104985:	68 2c 74 10 80       	push   $0x8010742c
8010498a:	e8 b9 b9 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010498f:	83 ec 0c             	sub    $0xc,%esp
80104992:	68 38 74 10 80       	push   $0x80107438
80104997:	e8 ac b9 ff ff       	call   80100348 <panic>
    return 0;
8010499c:	89 c3                	mov    %eax,%ebx
8010499e:	e9 04 ff ff ff       	jmp    801048a7 <create+0x6e>

801049a3 <sys_dup>:
{
801049a3:	55                   	push   %ebp
801049a4:	89 e5                	mov    %esp,%ebp
801049a6:	53                   	push   %ebx
801049a7:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801049aa:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801049ad:	ba 00 00 00 00       	mov    $0x0,%edx
801049b2:	b8 00 00 00 00       	mov    $0x0,%eax
801049b7:	e8 88 fd ff ff       	call   80104744 <argfd>
801049bc:	85 c0                	test   %eax,%eax
801049be:	78 23                	js     801049e3 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801049c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c3:	e8 e3 fd ff ff       	call   801047ab <fdalloc>
801049c8:	89 c3                	mov    %eax,%ebx
801049ca:	85 c0                	test   %eax,%eax
801049cc:	78 1c                	js     801049ea <sys_dup+0x47>
  filedup(f);
801049ce:	83 ec 0c             	sub    $0xc,%esp
801049d1:	ff 75 f4             	pushl  -0xc(%ebp)
801049d4:	e8 b5 c2 ff ff       	call   80100c8e <filedup>
  return fd;
801049d9:	83 c4 10             	add    $0x10,%esp
}
801049dc:	89 d8                	mov    %ebx,%eax
801049de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049e1:	c9                   	leave  
801049e2:	c3                   	ret    
    return -1;
801049e3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801049e8:	eb f2                	jmp    801049dc <sys_dup+0x39>
    return -1;
801049ea:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801049ef:	eb eb                	jmp    801049dc <sys_dup+0x39>

801049f1 <sys_read>:
{
801049f1:	55                   	push   %ebp
801049f2:	89 e5                	mov    %esp,%ebp
801049f4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801049f7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801049fa:	ba 00 00 00 00       	mov    $0x0,%edx
801049ff:	b8 00 00 00 00       	mov    $0x0,%eax
80104a04:	e8 3b fd ff ff       	call   80104744 <argfd>
80104a09:	85 c0                	test   %eax,%eax
80104a0b:	78 43                	js     80104a50 <sys_read+0x5f>
80104a0d:	83 ec 08             	sub    $0x8,%esp
80104a10:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a13:	50                   	push   %eax
80104a14:	6a 02                	push   $0x2
80104a16:	e8 11 fc ff ff       	call   8010462c <argint>
80104a1b:	83 c4 10             	add    $0x10,%esp
80104a1e:	85 c0                	test   %eax,%eax
80104a20:	78 35                	js     80104a57 <sys_read+0x66>
80104a22:	83 ec 04             	sub    $0x4,%esp
80104a25:	ff 75 f0             	pushl  -0x10(%ebp)
80104a28:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a2b:	50                   	push   %eax
80104a2c:	6a 01                	push   $0x1
80104a2e:	e8 21 fc ff ff       	call   80104654 <argptr>
80104a33:	83 c4 10             	add    $0x10,%esp
80104a36:	85 c0                	test   %eax,%eax
80104a38:	78 24                	js     80104a5e <sys_read+0x6d>
  return fileread(f, p, n);
80104a3a:	83 ec 04             	sub    $0x4,%esp
80104a3d:	ff 75 f0             	pushl  -0x10(%ebp)
80104a40:	ff 75 ec             	pushl  -0x14(%ebp)
80104a43:	ff 75 f4             	pushl  -0xc(%ebp)
80104a46:	e8 8c c3 ff ff       	call   80100dd7 <fileread>
80104a4b:	83 c4 10             	add    $0x10,%esp
}
80104a4e:	c9                   	leave  
80104a4f:	c3                   	ret    
    return -1;
80104a50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a55:	eb f7                	jmp    80104a4e <sys_read+0x5d>
80104a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a5c:	eb f0                	jmp    80104a4e <sys_read+0x5d>
80104a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a63:	eb e9                	jmp    80104a4e <sys_read+0x5d>

80104a65 <sys_write>:
{
80104a65:	55                   	push   %ebp
80104a66:	89 e5                	mov    %esp,%ebp
80104a68:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104a6b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104a6e:	ba 00 00 00 00       	mov    $0x0,%edx
80104a73:	b8 00 00 00 00       	mov    $0x0,%eax
80104a78:	e8 c7 fc ff ff       	call   80104744 <argfd>
80104a7d:	85 c0                	test   %eax,%eax
80104a7f:	78 43                	js     80104ac4 <sys_write+0x5f>
80104a81:	83 ec 08             	sub    $0x8,%esp
80104a84:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a87:	50                   	push   %eax
80104a88:	6a 02                	push   $0x2
80104a8a:	e8 9d fb ff ff       	call   8010462c <argint>
80104a8f:	83 c4 10             	add    $0x10,%esp
80104a92:	85 c0                	test   %eax,%eax
80104a94:	78 35                	js     80104acb <sys_write+0x66>
80104a96:	83 ec 04             	sub    $0x4,%esp
80104a99:	ff 75 f0             	pushl  -0x10(%ebp)
80104a9c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a9f:	50                   	push   %eax
80104aa0:	6a 01                	push   $0x1
80104aa2:	e8 ad fb ff ff       	call   80104654 <argptr>
80104aa7:	83 c4 10             	add    $0x10,%esp
80104aaa:	85 c0                	test   %eax,%eax
80104aac:	78 24                	js     80104ad2 <sys_write+0x6d>
  return filewrite(f, p, n);
80104aae:	83 ec 04             	sub    $0x4,%esp
80104ab1:	ff 75 f0             	pushl  -0x10(%ebp)
80104ab4:	ff 75 ec             	pushl  -0x14(%ebp)
80104ab7:	ff 75 f4             	pushl  -0xc(%ebp)
80104aba:	e8 9d c3 ff ff       	call   80100e5c <filewrite>
80104abf:	83 c4 10             	add    $0x10,%esp
}
80104ac2:	c9                   	leave  
80104ac3:	c3                   	ret    
    return -1;
80104ac4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ac9:	eb f7                	jmp    80104ac2 <sys_write+0x5d>
80104acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad0:	eb f0                	jmp    80104ac2 <sys_write+0x5d>
80104ad2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad7:	eb e9                	jmp    80104ac2 <sys_write+0x5d>

80104ad9 <sys_close>:
{
80104ad9:	55                   	push   %ebp
80104ada:	89 e5                	mov    %esp,%ebp
80104adc:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104adf:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104ae2:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104ae5:	b8 00 00 00 00       	mov    $0x0,%eax
80104aea:	e8 55 fc ff ff       	call   80104744 <argfd>
80104aef:	85 c0                	test   %eax,%eax
80104af1:	78 25                	js     80104b18 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104af3:	e8 61 e8 ff ff       	call   80103359 <myproc>
80104af8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104afb:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104b02:	00 
  fileclose(f);
80104b03:	83 ec 0c             	sub    $0xc,%esp
80104b06:	ff 75 f0             	pushl  -0x10(%ebp)
80104b09:	e8 c5 c1 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104b0e:	83 c4 10             	add    $0x10,%esp
80104b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b16:	c9                   	leave  
80104b17:	c3                   	ret    
    return -1;
80104b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b1d:	eb f7                	jmp    80104b16 <sys_close+0x3d>

80104b1f <sys_fstat>:
{
80104b1f:	55                   	push   %ebp
80104b20:	89 e5                	mov    %esp,%ebp
80104b22:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104b25:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104b28:	ba 00 00 00 00       	mov    $0x0,%edx
80104b2d:	b8 00 00 00 00       	mov    $0x0,%eax
80104b32:	e8 0d fc ff ff       	call   80104744 <argfd>
80104b37:	85 c0                	test   %eax,%eax
80104b39:	78 2a                	js     80104b65 <sys_fstat+0x46>
80104b3b:	83 ec 04             	sub    $0x4,%esp
80104b3e:	6a 14                	push   $0x14
80104b40:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b43:	50                   	push   %eax
80104b44:	6a 01                	push   $0x1
80104b46:	e8 09 fb ff ff       	call   80104654 <argptr>
80104b4b:	83 c4 10             	add    $0x10,%esp
80104b4e:	85 c0                	test   %eax,%eax
80104b50:	78 1a                	js     80104b6c <sys_fstat+0x4d>
  return filestat(f, st);
80104b52:	83 ec 08             	sub    $0x8,%esp
80104b55:	ff 75 f0             	pushl  -0x10(%ebp)
80104b58:	ff 75 f4             	pushl  -0xc(%ebp)
80104b5b:	e8 30 c2 ff ff       	call   80100d90 <filestat>
80104b60:	83 c4 10             	add    $0x10,%esp
}
80104b63:	c9                   	leave  
80104b64:	c3                   	ret    
    return -1;
80104b65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6a:	eb f7                	jmp    80104b63 <sys_fstat+0x44>
80104b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b71:	eb f0                	jmp    80104b63 <sys_fstat+0x44>

80104b73 <sys_link>:
{
80104b73:	55                   	push   %ebp
80104b74:	89 e5                	mov    %esp,%ebp
80104b76:	56                   	push   %esi
80104b77:	53                   	push   %ebx
80104b78:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104b7b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104b7e:	50                   	push   %eax
80104b7f:	6a 00                	push   $0x0
80104b81:	e8 36 fb ff ff       	call   801046bc <argstr>
80104b86:	83 c4 10             	add    $0x10,%esp
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	0f 88 32 01 00 00    	js     80104cc3 <sys_link+0x150>
80104b91:	83 ec 08             	sub    $0x8,%esp
80104b94:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104b97:	50                   	push   %eax
80104b98:	6a 01                	push   $0x1
80104b9a:	e8 1d fb ff ff       	call   801046bc <argstr>
80104b9f:	83 c4 10             	add    $0x10,%esp
80104ba2:	85 c0                	test   %eax,%eax
80104ba4:	0f 88 20 01 00 00    	js     80104cca <sys_link+0x157>
  begin_op();
80104baa:	e8 ff db ff ff       	call   801027ae <begin_op>
  if((ip = namei(old)) == 0){
80104baf:	83 ec 0c             	sub    $0xc,%esp
80104bb2:	ff 75 e0             	pushl  -0x20(%ebp)
80104bb5:	e8 27 d0 ff ff       	call   80101be1 <namei>
80104bba:	89 c3                	mov    %eax,%ebx
80104bbc:	83 c4 10             	add    $0x10,%esp
80104bbf:	85 c0                	test   %eax,%eax
80104bc1:	0f 84 99 00 00 00    	je     80104c60 <sys_link+0xed>
  ilock(ip);
80104bc7:	83 ec 0c             	sub    $0xc,%esp
80104bca:	50                   	push   %eax
80104bcb:	e8 b1 c9 ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
80104bd0:	83 c4 10             	add    $0x10,%esp
80104bd3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104bd8:	0f 84 8e 00 00 00    	je     80104c6c <sys_link+0xf9>
  ip->nlink++;
80104bde:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104be2:	83 c0 01             	add    $0x1,%eax
80104be5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104be9:	83 ec 0c             	sub    $0xc,%esp
80104bec:	53                   	push   %ebx
80104bed:	e8 2e c8 ff ff       	call   80101420 <iupdate>
  iunlock(ip);
80104bf2:	89 1c 24             	mov    %ebx,(%esp)
80104bf5:	e8 49 ca ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104bfa:	83 c4 08             	add    $0x8,%esp
80104bfd:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104c00:	50                   	push   %eax
80104c01:	ff 75 e4             	pushl  -0x1c(%ebp)
80104c04:	e8 f0 cf ff ff       	call   80101bf9 <nameiparent>
80104c09:	89 c6                	mov    %eax,%esi
80104c0b:	83 c4 10             	add    $0x10,%esp
80104c0e:	85 c0                	test   %eax,%eax
80104c10:	74 7e                	je     80104c90 <sys_link+0x11d>
  ilock(dp);
80104c12:	83 ec 0c             	sub    $0xc,%esp
80104c15:	50                   	push   %eax
80104c16:	e8 66 c9 ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104c1b:	83 c4 10             	add    $0x10,%esp
80104c1e:	8b 03                	mov    (%ebx),%eax
80104c20:	39 06                	cmp    %eax,(%esi)
80104c22:	75 60                	jne    80104c84 <sys_link+0x111>
80104c24:	83 ec 04             	sub    $0x4,%esp
80104c27:	ff 73 04             	pushl  0x4(%ebx)
80104c2a:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104c2d:	50                   	push   %eax
80104c2e:	56                   	push   %esi
80104c2f:	e8 fc ce ff ff       	call   80101b30 <dirlink>
80104c34:	83 c4 10             	add    $0x10,%esp
80104c37:	85 c0                	test   %eax,%eax
80104c39:	78 49                	js     80104c84 <sys_link+0x111>
  iunlockput(dp);
80104c3b:	83 ec 0c             	sub    $0xc,%esp
80104c3e:	56                   	push   %esi
80104c3f:	e8 e4 ca ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104c44:	89 1c 24             	mov    %ebx,(%esp)
80104c47:	e8 3c ca ff ff       	call   80101688 <iput>
  end_op();
80104c4c:	e8 d7 db ff ff       	call   80102828 <end_op>
  return 0;
80104c51:	83 c4 10             	add    $0x10,%esp
80104c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c59:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c5c:	5b                   	pop    %ebx
80104c5d:	5e                   	pop    %esi
80104c5e:	5d                   	pop    %ebp
80104c5f:	c3                   	ret    
    end_op();
80104c60:	e8 c3 db ff ff       	call   80102828 <end_op>
    return -1;
80104c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6a:	eb ed                	jmp    80104c59 <sys_link+0xe6>
    iunlockput(ip);
80104c6c:	83 ec 0c             	sub    $0xc,%esp
80104c6f:	53                   	push   %ebx
80104c70:	e8 b3 ca ff ff       	call   80101728 <iunlockput>
    end_op();
80104c75:	e8 ae db ff ff       	call   80102828 <end_op>
    return -1;
80104c7a:	83 c4 10             	add    $0x10,%esp
80104c7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c82:	eb d5                	jmp    80104c59 <sys_link+0xe6>
    iunlockput(dp);
80104c84:	83 ec 0c             	sub    $0xc,%esp
80104c87:	56                   	push   %esi
80104c88:	e8 9b ca ff ff       	call   80101728 <iunlockput>
    goto bad;
80104c8d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104c90:	83 ec 0c             	sub    $0xc,%esp
80104c93:	53                   	push   %ebx
80104c94:	e8 e8 c8 ff ff       	call   80101581 <ilock>
  ip->nlink--;
80104c99:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104c9d:	83 e8 01             	sub    $0x1,%eax
80104ca0:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104ca4:	89 1c 24             	mov    %ebx,(%esp)
80104ca7:	e8 74 c7 ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104cac:	89 1c 24             	mov    %ebx,(%esp)
80104caf:	e8 74 ca ff ff       	call   80101728 <iunlockput>
  end_op();
80104cb4:	e8 6f db ff ff       	call   80102828 <end_op>
  return -1;
80104cb9:	83 c4 10             	add    $0x10,%esp
80104cbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cc1:	eb 96                	jmp    80104c59 <sys_link+0xe6>
    return -1;
80104cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cc8:	eb 8f                	jmp    80104c59 <sys_link+0xe6>
80104cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ccf:	eb 88                	jmp    80104c59 <sys_link+0xe6>

80104cd1 <sys_unlink>:
{
80104cd1:	55                   	push   %ebp
80104cd2:	89 e5                	mov    %esp,%ebp
80104cd4:	57                   	push   %edi
80104cd5:	56                   	push   %esi
80104cd6:	53                   	push   %ebx
80104cd7:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104cda:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104cdd:	50                   	push   %eax
80104cde:	6a 00                	push   $0x0
80104ce0:	e8 d7 f9 ff ff       	call   801046bc <argstr>
80104ce5:	83 c4 10             	add    $0x10,%esp
80104ce8:	85 c0                	test   %eax,%eax
80104cea:	0f 88 83 01 00 00    	js     80104e73 <sys_unlink+0x1a2>
  begin_op();
80104cf0:	e8 b9 da ff ff       	call   801027ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104cf5:	83 ec 08             	sub    $0x8,%esp
80104cf8:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104cfb:	50                   	push   %eax
80104cfc:	ff 75 c4             	pushl  -0x3c(%ebp)
80104cff:	e8 f5 ce ff ff       	call   80101bf9 <nameiparent>
80104d04:	89 c6                	mov    %eax,%esi
80104d06:	83 c4 10             	add    $0x10,%esp
80104d09:	85 c0                	test   %eax,%eax
80104d0b:	0f 84 ed 00 00 00    	je     80104dfe <sys_unlink+0x12d>
  ilock(dp);
80104d11:	83 ec 0c             	sub    $0xc,%esp
80104d14:	50                   	push   %eax
80104d15:	e8 67 c8 ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104d1a:	83 c4 08             	add    $0x8,%esp
80104d1d:	68 2a 74 10 80       	push   $0x8010742a
80104d22:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d25:	50                   	push   %eax
80104d26:	e8 70 cc ff ff       	call   8010199b <namecmp>
80104d2b:	83 c4 10             	add    $0x10,%esp
80104d2e:	85 c0                	test   %eax,%eax
80104d30:	0f 84 fc 00 00 00    	je     80104e32 <sys_unlink+0x161>
80104d36:	83 ec 08             	sub    $0x8,%esp
80104d39:	68 29 74 10 80       	push   $0x80107429
80104d3e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d41:	50                   	push   %eax
80104d42:	e8 54 cc ff ff       	call   8010199b <namecmp>
80104d47:	83 c4 10             	add    $0x10,%esp
80104d4a:	85 c0                	test   %eax,%eax
80104d4c:	0f 84 e0 00 00 00    	je     80104e32 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104d52:	83 ec 04             	sub    $0x4,%esp
80104d55:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104d58:	50                   	push   %eax
80104d59:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d5c:	50                   	push   %eax
80104d5d:	56                   	push   %esi
80104d5e:	e8 4d cc ff ff       	call   801019b0 <dirlookup>
80104d63:	89 c3                	mov    %eax,%ebx
80104d65:	83 c4 10             	add    $0x10,%esp
80104d68:	85 c0                	test   %eax,%eax
80104d6a:	0f 84 c2 00 00 00    	je     80104e32 <sys_unlink+0x161>
  ilock(ip);
80104d70:	83 ec 0c             	sub    $0xc,%esp
80104d73:	50                   	push   %eax
80104d74:	e8 08 c8 ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104d79:	83 c4 10             	add    $0x10,%esp
80104d7c:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104d81:	0f 8e 83 00 00 00    	jle    80104e0a <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104d87:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104d8c:	0f 84 85 00 00 00    	je     80104e17 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104d92:	83 ec 04             	sub    $0x4,%esp
80104d95:	6a 10                	push   $0x10
80104d97:	6a 00                	push   $0x0
80104d99:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104d9c:	57                   	push   %edi
80104d9d:	e8 3f f6 ff ff       	call   801043e1 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104da2:	6a 10                	push   $0x10
80104da4:	ff 75 c0             	pushl  -0x40(%ebp)
80104da7:	57                   	push   %edi
80104da8:	56                   	push   %esi
80104da9:	e8 c2 ca ff ff       	call   80101870 <writei>
80104dae:	83 c4 20             	add    $0x20,%esp
80104db1:	83 f8 10             	cmp    $0x10,%eax
80104db4:	0f 85 90 00 00 00    	jne    80104e4a <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104dba:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104dbf:	0f 84 92 00 00 00    	je     80104e57 <sys_unlink+0x186>
  iunlockput(dp);
80104dc5:	83 ec 0c             	sub    $0xc,%esp
80104dc8:	56                   	push   %esi
80104dc9:	e8 5a c9 ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
80104dce:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104dd2:	83 e8 01             	sub    $0x1,%eax
80104dd5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104dd9:	89 1c 24             	mov    %ebx,(%esp)
80104ddc:	e8 3f c6 ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104de1:	89 1c 24             	mov    %ebx,(%esp)
80104de4:	e8 3f c9 ff ff       	call   80101728 <iunlockput>
  end_op();
80104de9:	e8 3a da ff ff       	call   80102828 <end_op>
  return 0;
80104dee:	83 c4 10             	add    $0x10,%esp
80104df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104df9:	5b                   	pop    %ebx
80104dfa:	5e                   	pop    %esi
80104dfb:	5f                   	pop    %edi
80104dfc:	5d                   	pop    %ebp
80104dfd:	c3                   	ret    
    end_op();
80104dfe:	e8 25 da ff ff       	call   80102828 <end_op>
    return -1;
80104e03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e08:	eb ec                	jmp    80104df6 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104e0a:	83 ec 0c             	sub    $0xc,%esp
80104e0d:	68 48 74 10 80       	push   $0x80107448
80104e12:	e8 31 b5 ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104e17:	89 d8                	mov    %ebx,%eax
80104e19:	e8 c4 f9 ff ff       	call   801047e2 <isdirempty>
80104e1e:	85 c0                	test   %eax,%eax
80104e20:	0f 85 6c ff ff ff    	jne    80104d92 <sys_unlink+0xc1>
    iunlockput(ip);
80104e26:	83 ec 0c             	sub    $0xc,%esp
80104e29:	53                   	push   %ebx
80104e2a:	e8 f9 c8 ff ff       	call   80101728 <iunlockput>
    goto bad;
80104e2f:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104e32:	83 ec 0c             	sub    $0xc,%esp
80104e35:	56                   	push   %esi
80104e36:	e8 ed c8 ff ff       	call   80101728 <iunlockput>
  end_op();
80104e3b:	e8 e8 d9 ff ff       	call   80102828 <end_op>
  return -1;
80104e40:	83 c4 10             	add    $0x10,%esp
80104e43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e48:	eb ac                	jmp    80104df6 <sys_unlink+0x125>
    panic("unlink: writei");
80104e4a:	83 ec 0c             	sub    $0xc,%esp
80104e4d:	68 5a 74 10 80       	push   $0x8010745a
80104e52:	e8 f1 b4 ff ff       	call   80100348 <panic>
    dp->nlink--;
80104e57:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104e5b:	83 e8 01             	sub    $0x1,%eax
80104e5e:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104e62:	83 ec 0c             	sub    $0xc,%esp
80104e65:	56                   	push   %esi
80104e66:	e8 b5 c5 ff ff       	call   80101420 <iupdate>
80104e6b:	83 c4 10             	add    $0x10,%esp
80104e6e:	e9 52 ff ff ff       	jmp    80104dc5 <sys_unlink+0xf4>
    return -1;
80104e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e78:	e9 79 ff ff ff       	jmp    80104df6 <sys_unlink+0x125>

80104e7d <sys_open>:

int
sys_open(void)
{
80104e7d:	55                   	push   %ebp
80104e7e:	89 e5                	mov    %esp,%ebp
80104e80:	57                   	push   %edi
80104e81:	56                   	push   %esi
80104e82:	53                   	push   %ebx
80104e83:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104e86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104e89:	50                   	push   %eax
80104e8a:	6a 00                	push   $0x0
80104e8c:	e8 2b f8 ff ff       	call   801046bc <argstr>
80104e91:	83 c4 10             	add    $0x10,%esp
80104e94:	85 c0                	test   %eax,%eax
80104e96:	0f 88 30 01 00 00    	js     80104fcc <sys_open+0x14f>
80104e9c:	83 ec 08             	sub    $0x8,%esp
80104e9f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104ea2:	50                   	push   %eax
80104ea3:	6a 01                	push   $0x1
80104ea5:	e8 82 f7 ff ff       	call   8010462c <argint>
80104eaa:	83 c4 10             	add    $0x10,%esp
80104ead:	85 c0                	test   %eax,%eax
80104eaf:	0f 88 21 01 00 00    	js     80104fd6 <sys_open+0x159>
    return -1;

  begin_op();
80104eb5:	e8 f4 d8 ff ff       	call   801027ae <begin_op>

  if(omode & O_CREATE){
80104eba:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104ebe:	0f 84 84 00 00 00    	je     80104f48 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104ec4:	83 ec 0c             	sub    $0xc,%esp
80104ec7:	6a 00                	push   $0x0
80104ec9:	b9 00 00 00 00       	mov    $0x0,%ecx
80104ece:	ba 02 00 00 00       	mov    $0x2,%edx
80104ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ed6:	e8 5e f9 ff ff       	call   80104839 <create>
80104edb:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104edd:	83 c4 10             	add    $0x10,%esp
80104ee0:	85 c0                	test   %eax,%eax
80104ee2:	74 58                	je     80104f3c <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104ee4:	e8 44 bd ff ff       	call   80100c2d <filealloc>
80104ee9:	89 c3                	mov    %eax,%ebx
80104eeb:	85 c0                	test   %eax,%eax
80104eed:	0f 84 ae 00 00 00    	je     80104fa1 <sys_open+0x124>
80104ef3:	e8 b3 f8 ff ff       	call   801047ab <fdalloc>
80104ef8:	89 c7                	mov    %eax,%edi
80104efa:	85 c0                	test   %eax,%eax
80104efc:	0f 88 9f 00 00 00    	js     80104fa1 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104f02:	83 ec 0c             	sub    $0xc,%esp
80104f05:	56                   	push   %esi
80104f06:	e8 38 c7 ff ff       	call   80101643 <iunlock>
  end_op();
80104f0b:	e8 18 d9 ff ff       	call   80102828 <end_op>

  f->type = FD_INODE;
80104f10:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104f16:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104f19:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	a8 01                	test   $0x1,%al
80104f28:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104f2c:	a8 03                	test   $0x3,%al
80104f2e:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104f32:	89 f8                	mov    %edi,%eax
80104f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f37:	5b                   	pop    %ebx
80104f38:	5e                   	pop    %esi
80104f39:	5f                   	pop    %edi
80104f3a:	5d                   	pop    %ebp
80104f3b:	c3                   	ret    
      end_op();
80104f3c:	e8 e7 d8 ff ff       	call   80102828 <end_op>
      return -1;
80104f41:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104f46:	eb ea                	jmp    80104f32 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104f48:	83 ec 0c             	sub    $0xc,%esp
80104f4b:	ff 75 e4             	pushl  -0x1c(%ebp)
80104f4e:	e8 8e cc ff ff       	call   80101be1 <namei>
80104f53:	89 c6                	mov    %eax,%esi
80104f55:	83 c4 10             	add    $0x10,%esp
80104f58:	85 c0                	test   %eax,%eax
80104f5a:	74 39                	je     80104f95 <sys_open+0x118>
    ilock(ip);
80104f5c:	83 ec 0c             	sub    $0xc,%esp
80104f5f:	50                   	push   %eax
80104f60:	e8 1c c6 ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104f65:	83 c4 10             	add    $0x10,%esp
80104f68:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104f6d:	0f 85 71 ff ff ff    	jne    80104ee4 <sys_open+0x67>
80104f73:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104f77:	0f 84 67 ff ff ff    	je     80104ee4 <sys_open+0x67>
      iunlockput(ip);
80104f7d:	83 ec 0c             	sub    $0xc,%esp
80104f80:	56                   	push   %esi
80104f81:	e8 a2 c7 ff ff       	call   80101728 <iunlockput>
      end_op();
80104f86:	e8 9d d8 ff ff       	call   80102828 <end_op>
      return -1;
80104f8b:	83 c4 10             	add    $0x10,%esp
80104f8e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104f93:	eb 9d                	jmp    80104f32 <sys_open+0xb5>
      end_op();
80104f95:	e8 8e d8 ff ff       	call   80102828 <end_op>
      return -1;
80104f9a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104f9f:	eb 91                	jmp    80104f32 <sys_open+0xb5>
    if(f)
80104fa1:	85 db                	test   %ebx,%ebx
80104fa3:	74 0c                	je     80104fb1 <sys_open+0x134>
      fileclose(f);
80104fa5:	83 ec 0c             	sub    $0xc,%esp
80104fa8:	53                   	push   %ebx
80104fa9:	e8 25 bd ff ff       	call   80100cd3 <fileclose>
80104fae:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104fb1:	83 ec 0c             	sub    $0xc,%esp
80104fb4:	56                   	push   %esi
80104fb5:	e8 6e c7 ff ff       	call   80101728 <iunlockput>
    end_op();
80104fba:	e8 69 d8 ff ff       	call   80102828 <end_op>
    return -1;
80104fbf:	83 c4 10             	add    $0x10,%esp
80104fc2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104fc7:	e9 66 ff ff ff       	jmp    80104f32 <sys_open+0xb5>
    return -1;
80104fcc:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104fd1:	e9 5c ff ff ff       	jmp    80104f32 <sys_open+0xb5>
80104fd6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104fdb:	e9 52 ff ff ff       	jmp    80104f32 <sys_open+0xb5>

80104fe0 <sys_mkdir>:

int
sys_mkdir(void)
{
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104fe6:	e8 c3 d7 ff ff       	call   801027ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104feb:	83 ec 08             	sub    $0x8,%esp
80104fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ff1:	50                   	push   %eax
80104ff2:	6a 00                	push   $0x0
80104ff4:	e8 c3 f6 ff ff       	call   801046bc <argstr>
80104ff9:	83 c4 10             	add    $0x10,%esp
80104ffc:	85 c0                	test   %eax,%eax
80104ffe:	78 36                	js     80105036 <sys_mkdir+0x56>
80105000:	83 ec 0c             	sub    $0xc,%esp
80105003:	6a 00                	push   $0x0
80105005:	b9 00 00 00 00       	mov    $0x0,%ecx
8010500a:	ba 01 00 00 00       	mov    $0x1,%edx
8010500f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105012:	e8 22 f8 ff ff       	call   80104839 <create>
80105017:	83 c4 10             	add    $0x10,%esp
8010501a:	85 c0                	test   %eax,%eax
8010501c:	74 18                	je     80105036 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010501e:	83 ec 0c             	sub    $0xc,%esp
80105021:	50                   	push   %eax
80105022:	e8 01 c7 ff ff       	call   80101728 <iunlockput>
  end_op();
80105027:	e8 fc d7 ff ff       	call   80102828 <end_op>
  return 0;
8010502c:	83 c4 10             	add    $0x10,%esp
8010502f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105034:	c9                   	leave  
80105035:	c3                   	ret    
    end_op();
80105036:	e8 ed d7 ff ff       	call   80102828 <end_op>
    return -1;
8010503b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105040:	eb f2                	jmp    80105034 <sys_mkdir+0x54>

80105042 <sys_mknod>:

int
sys_mknod(void)
{
80105042:	55                   	push   %ebp
80105043:	89 e5                	mov    %esp,%ebp
80105045:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105048:	e8 61 d7 ff ff       	call   801027ae <begin_op>
  if((argstr(0, &path)) < 0 ||
8010504d:	83 ec 08             	sub    $0x8,%esp
80105050:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105053:	50                   	push   %eax
80105054:	6a 00                	push   $0x0
80105056:	e8 61 f6 ff ff       	call   801046bc <argstr>
8010505b:	83 c4 10             	add    $0x10,%esp
8010505e:	85 c0                	test   %eax,%eax
80105060:	78 62                	js     801050c4 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80105062:	83 ec 08             	sub    $0x8,%esp
80105065:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105068:	50                   	push   %eax
80105069:	6a 01                	push   $0x1
8010506b:	e8 bc f5 ff ff       	call   8010462c <argint>
  if((argstr(0, &path)) < 0 ||
80105070:	83 c4 10             	add    $0x10,%esp
80105073:	85 c0                	test   %eax,%eax
80105075:	78 4d                	js     801050c4 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80105077:	83 ec 08             	sub    $0x8,%esp
8010507a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010507d:	50                   	push   %eax
8010507e:	6a 02                	push   $0x2
80105080:	e8 a7 f5 ff ff       	call   8010462c <argint>
     argint(1, &major) < 0 ||
80105085:	83 c4 10             	add    $0x10,%esp
80105088:	85 c0                	test   %eax,%eax
8010508a:	78 38                	js     801050c4 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010508c:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80105090:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80105094:	83 ec 0c             	sub    $0xc,%esp
80105097:	50                   	push   %eax
80105098:	ba 03 00 00 00       	mov    $0x3,%edx
8010509d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a0:	e8 94 f7 ff ff       	call   80104839 <create>
801050a5:	83 c4 10             	add    $0x10,%esp
801050a8:	85 c0                	test   %eax,%eax
801050aa:	74 18                	je     801050c4 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801050ac:	83 ec 0c             	sub    $0xc,%esp
801050af:	50                   	push   %eax
801050b0:	e8 73 c6 ff ff       	call   80101728 <iunlockput>
  end_op();
801050b5:	e8 6e d7 ff ff       	call   80102828 <end_op>
  return 0;
801050ba:	83 c4 10             	add    $0x10,%esp
801050bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050c2:	c9                   	leave  
801050c3:	c3                   	ret    
    end_op();
801050c4:	e8 5f d7 ff ff       	call   80102828 <end_op>
    return -1;
801050c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ce:	eb f2                	jmp    801050c2 <sys_mknod+0x80>

801050d0 <sys_chdir>:

int
sys_chdir(void)
{
801050d0:	55                   	push   %ebp
801050d1:	89 e5                	mov    %esp,%ebp
801050d3:	56                   	push   %esi
801050d4:	53                   	push   %ebx
801050d5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801050d8:	e8 7c e2 ff ff       	call   80103359 <myproc>
801050dd:	89 c6                	mov    %eax,%esi
  
  begin_op();
801050df:	e8 ca d6 ff ff       	call   801027ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801050e4:	83 ec 08             	sub    $0x8,%esp
801050e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050ea:	50                   	push   %eax
801050eb:	6a 00                	push   $0x0
801050ed:	e8 ca f5 ff ff       	call   801046bc <argstr>
801050f2:	83 c4 10             	add    $0x10,%esp
801050f5:	85 c0                	test   %eax,%eax
801050f7:	78 52                	js     8010514b <sys_chdir+0x7b>
801050f9:	83 ec 0c             	sub    $0xc,%esp
801050fc:	ff 75 f4             	pushl  -0xc(%ebp)
801050ff:	e8 dd ca ff ff       	call   80101be1 <namei>
80105104:	89 c3                	mov    %eax,%ebx
80105106:	83 c4 10             	add    $0x10,%esp
80105109:	85 c0                	test   %eax,%eax
8010510b:	74 3e                	je     8010514b <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
8010510d:	83 ec 0c             	sub    $0xc,%esp
80105110:	50                   	push   %eax
80105111:	e8 6b c4 ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80105116:	83 c4 10             	add    $0x10,%esp
80105119:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010511e:	75 37                	jne    80105157 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105120:	83 ec 0c             	sub    $0xc,%esp
80105123:	53                   	push   %ebx
80105124:	e8 1a c5 ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80105129:	83 c4 04             	add    $0x4,%esp
8010512c:	ff 76 68             	pushl  0x68(%esi)
8010512f:	e8 54 c5 ff ff       	call   80101688 <iput>
  end_op();
80105134:	e8 ef d6 ff ff       	call   80102828 <end_op>
  curproc->cwd = ip;
80105139:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010513c:	83 c4 10             	add    $0x10,%esp
8010513f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105144:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105147:	5b                   	pop    %ebx
80105148:	5e                   	pop    %esi
80105149:	5d                   	pop    %ebp
8010514a:	c3                   	ret    
    end_op();
8010514b:	e8 d8 d6 ff ff       	call   80102828 <end_op>
    return -1;
80105150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105155:	eb ed                	jmp    80105144 <sys_chdir+0x74>
    iunlockput(ip);
80105157:	83 ec 0c             	sub    $0xc,%esp
8010515a:	53                   	push   %ebx
8010515b:	e8 c8 c5 ff ff       	call   80101728 <iunlockput>
    end_op();
80105160:	e8 c3 d6 ff ff       	call   80102828 <end_op>
    return -1;
80105165:	83 c4 10             	add    $0x10,%esp
80105168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516d:	eb d5                	jmp    80105144 <sys_chdir+0x74>

8010516f <sys_exec>:

int
sys_exec(void)
{
8010516f:	55                   	push   %ebp
80105170:	89 e5                	mov    %esp,%ebp
80105172:	53                   	push   %ebx
80105173:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105179:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010517c:	50                   	push   %eax
8010517d:	6a 00                	push   $0x0
8010517f:	e8 38 f5 ff ff       	call   801046bc <argstr>
80105184:	83 c4 10             	add    $0x10,%esp
80105187:	85 c0                	test   %eax,%eax
80105189:	0f 88 a8 00 00 00    	js     80105237 <sys_exec+0xc8>
8010518f:	83 ec 08             	sub    $0x8,%esp
80105192:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105198:	50                   	push   %eax
80105199:	6a 01                	push   $0x1
8010519b:	e8 8c f4 ff ff       	call   8010462c <argint>
801051a0:	83 c4 10             	add    $0x10,%esp
801051a3:	85 c0                	test   %eax,%eax
801051a5:	0f 88 93 00 00 00    	js     8010523e <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801051ab:	83 ec 04             	sub    $0x4,%esp
801051ae:	68 80 00 00 00       	push   $0x80
801051b3:	6a 00                	push   $0x0
801051b5:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801051bb:	50                   	push   %eax
801051bc:	e8 20 f2 ff ff       	call   801043e1 <memset>
801051c1:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801051c4:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
801051c9:	83 fb 1f             	cmp    $0x1f,%ebx
801051cc:	77 77                	ja     80105245 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801051ce:	83 ec 08             	sub    $0x8,%esp
801051d1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801051d7:	50                   	push   %eax
801051d8:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
801051de:	8d 04 98             	lea    (%eax,%ebx,4),%eax
801051e1:	50                   	push   %eax
801051e2:	e8 c9 f3 ff ff       	call   801045b0 <fetchint>
801051e7:	83 c4 10             	add    $0x10,%esp
801051ea:	85 c0                	test   %eax,%eax
801051ec:	78 5e                	js     8010524c <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
801051ee:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801051f4:	85 c0                	test   %eax,%eax
801051f6:	74 1d                	je     80105215 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801051f8:	83 ec 08             	sub    $0x8,%esp
801051fb:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80105202:	52                   	push   %edx
80105203:	50                   	push   %eax
80105204:	e8 e3 f3 ff ff       	call   801045ec <fetchstr>
80105209:	83 c4 10             	add    $0x10,%esp
8010520c:	85 c0                	test   %eax,%eax
8010520e:	78 46                	js     80105256 <sys_exec+0xe7>
  for(i=0;; i++){
80105210:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105213:	eb b4                	jmp    801051c9 <sys_exec+0x5a>
      argv[i] = 0;
80105215:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
8010521c:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80105220:	83 ec 08             	sub    $0x8,%esp
80105223:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80105229:	50                   	push   %eax
8010522a:	ff 75 f4             	pushl  -0xc(%ebp)
8010522d:	e8 a0 b6 ff ff       	call   801008d2 <exec>
80105232:	83 c4 10             	add    $0x10,%esp
80105235:	eb 1a                	jmp    80105251 <sys_exec+0xe2>
    return -1;
80105237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523c:	eb 13                	jmp    80105251 <sys_exec+0xe2>
8010523e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105243:	eb 0c                	jmp    80105251 <sys_exec+0xe2>
      return -1;
80105245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524a:	eb 05                	jmp    80105251 <sys_exec+0xe2>
      return -1;
8010524c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105254:	c9                   	leave  
80105255:	c3                   	ret    
      return -1;
80105256:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010525b:	eb f4                	jmp    80105251 <sys_exec+0xe2>

8010525d <sys_pipe>:

int
sys_pipe(void)
{
8010525d:	55                   	push   %ebp
8010525e:	89 e5                	mov    %esp,%ebp
80105260:	53                   	push   %ebx
80105261:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105264:	6a 08                	push   $0x8
80105266:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105269:	50                   	push   %eax
8010526a:	6a 00                	push   $0x0
8010526c:	e8 e3 f3 ff ff       	call   80104654 <argptr>
80105271:	83 c4 10             	add    $0x10,%esp
80105274:	85 c0                	test   %eax,%eax
80105276:	78 77                	js     801052ef <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105278:	83 ec 08             	sub    $0x8,%esp
8010527b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010527e:	50                   	push   %eax
8010527f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105282:	50                   	push   %eax
80105283:	e8 ad da ff ff       	call   80102d35 <pipealloc>
80105288:	83 c4 10             	add    $0x10,%esp
8010528b:	85 c0                	test   %eax,%eax
8010528d:	78 67                	js     801052f6 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010528f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105292:	e8 14 f5 ff ff       	call   801047ab <fdalloc>
80105297:	89 c3                	mov    %eax,%ebx
80105299:	85 c0                	test   %eax,%eax
8010529b:	78 21                	js     801052be <sys_pipe+0x61>
8010529d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052a0:	e8 06 f5 ff ff       	call   801047ab <fdalloc>
801052a5:	85 c0                	test   %eax,%eax
801052a7:	78 15                	js     801052be <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
801052a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052ac:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
801052ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052b1:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801052b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052bc:	c9                   	leave  
801052bd:	c3                   	ret    
    if(fd0 >= 0)
801052be:	85 db                	test   %ebx,%ebx
801052c0:	78 0d                	js     801052cf <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
801052c2:	e8 92 e0 ff ff       	call   80103359 <myproc>
801052c7:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
801052ce:	00 
    fileclose(rf);
801052cf:	83 ec 0c             	sub    $0xc,%esp
801052d2:	ff 75 f0             	pushl  -0x10(%ebp)
801052d5:	e8 f9 b9 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
801052da:	83 c4 04             	add    $0x4,%esp
801052dd:	ff 75 ec             	pushl  -0x14(%ebp)
801052e0:	e8 ee b9 ff ff       	call   80100cd3 <fileclose>
    return -1;
801052e5:	83 c4 10             	add    $0x10,%esp
801052e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ed:	eb ca                	jmp    801052b9 <sys_pipe+0x5c>
    return -1;
801052ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f4:	eb c3                	jmp    801052b9 <sys_pipe+0x5c>
    return -1;
801052f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fb:	eb bc                	jmp    801052b9 <sys_pipe+0x5c>

801052fd <sys_fork>:
#include "memlayout.h"
#include "pstat.h"

int
sys_fork(void)
{
801052fd:	55                   	push   %ebp
801052fe:	89 e5                	mov    %esp,%ebp
80105300:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105303:	e8 e0 e8 ff ff       	call   80103be8 <fork>
}
80105308:	c9                   	leave  
80105309:	c3                   	ret    

8010530a <sys_exit>:

int
sys_exit(void)
{
8010530a:	55                   	push   %ebp
8010530b:	89 e5                	mov    %esp,%ebp
8010530d:	83 ec 08             	sub    $0x8,%esp
  exit();
80105310:	e8 7e e2 ff ff       	call   80103593 <exit>
  return 0;  // not reached
}
80105315:	b8 00 00 00 00       	mov    $0x0,%eax
8010531a:	c9                   	leave  
8010531b:	c3                   	ret    

8010531c <sys_wait>:

int
sys_wait(void)
{
8010531c:	55                   	push   %ebp
8010531d:	89 e5                	mov    %esp,%ebp
8010531f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105322:	e8 f8 e3 ff ff       	call   8010371f <wait>
}
80105327:	c9                   	leave  
80105328:	c3                   	ret    

80105329 <sys_kill>:

int
sys_kill(void)
{
80105329:	55                   	push   %ebp
8010532a:	89 e5                	mov    %esp,%ebp
8010532c:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010532f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105332:	50                   	push   %eax
80105333:	6a 00                	push   $0x0
80105335:	e8 f2 f2 ff ff       	call   8010462c <argint>
8010533a:	83 c4 10             	add    $0x10,%esp
8010533d:	85 c0                	test   %eax,%eax
8010533f:	78 10                	js     80105351 <sys_kill+0x28>
    return -1;
  return kill(pid);
80105341:	83 ec 0c             	sub    $0xc,%esp
80105344:	ff 75 f4             	pushl  -0xc(%ebp)
80105347:	e8 d3 e4 ff ff       	call   8010381f <kill>
8010534c:	83 c4 10             	add    $0x10,%esp
}
8010534f:	c9                   	leave  
80105350:	c3                   	ret    
    return -1;
80105351:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105356:	eb f7                	jmp    8010534f <sys_kill+0x26>

80105358 <sys_getpid>:

int
sys_getpid(void)
{
80105358:	55                   	push   %ebp
80105359:	89 e5                	mov    %esp,%ebp
8010535b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010535e:	e8 f6 df ff ff       	call   80103359 <myproc>
80105363:	8b 40 10             	mov    0x10(%eax),%eax
}
80105366:	c9                   	leave  
80105367:	c3                   	ret    

80105368 <sys_sbrk>:

int
sys_sbrk(void)
{
80105368:	55                   	push   %ebp
80105369:	89 e5                	mov    %esp,%ebp
8010536b:	53                   	push   %ebx
8010536c:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010536f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105372:	50                   	push   %eax
80105373:	6a 00                	push   $0x0
80105375:	e8 b2 f2 ff ff       	call   8010462c <argint>
8010537a:	83 c4 10             	add    $0x10,%esp
8010537d:	85 c0                	test   %eax,%eax
8010537f:	78 27                	js     801053a8 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105381:	e8 d3 df ff ff       	call   80103359 <myproc>
80105386:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105388:	83 ec 0c             	sub    $0xc,%esp
8010538b:	ff 75 f4             	pushl  -0xc(%ebp)
8010538e:	e8 f0 e0 ff ff       	call   80103483 <growproc>
80105393:	83 c4 10             	add    $0x10,%esp
80105396:	85 c0                	test   %eax,%eax
80105398:	78 07                	js     801053a1 <sys_sbrk+0x39>
    return -1;
  return addr;
}
8010539a:	89 d8                	mov    %ebx,%eax
8010539c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010539f:	c9                   	leave  
801053a0:	c3                   	ret    
    return -1;
801053a1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801053a6:	eb f2                	jmp    8010539a <sys_sbrk+0x32>
    return -1;
801053a8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801053ad:	eb eb                	jmp    8010539a <sys_sbrk+0x32>

801053af <sys_sleep>:

int
sys_sleep(void)
{
801053af:	55                   	push   %ebp
801053b0:	89 e5                	mov    %esp,%ebp
801053b2:	53                   	push   %ebx
801053b3:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801053b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b9:	50                   	push   %eax
801053ba:	6a 00                	push   $0x0
801053bc:	e8 6b f2 ff ff       	call   8010462c <argint>
801053c1:	83 c4 10             	add    $0x10,%esp
801053c4:	85 c0                	test   %eax,%eax
801053c6:	78 75                	js     8010543d <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
801053c8:	83 ec 0c             	sub    $0xc,%esp
801053cb:	68 80 69 11 80       	push   $0x80116980
801053d0:	e8 60 ef ff ff       	call   80104335 <acquire>
  ticks0 = ticks;
801053d5:	8b 1d c0 71 11 80    	mov    0x801171c0,%ebx
  while(ticks - ticks0 < n){
801053db:	83 c4 10             	add    $0x10,%esp
801053de:	a1 c0 71 11 80       	mov    0x801171c0,%eax
801053e3:	29 d8                	sub    %ebx,%eax
801053e5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801053e8:	73 39                	jae    80105423 <sys_sleep+0x74>
    if(myproc()->killed){
801053ea:	e8 6a df ff ff       	call   80103359 <myproc>
801053ef:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801053f3:	75 17                	jne    8010540c <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
801053f5:	83 ec 08             	sub    $0x8,%esp
801053f8:	68 80 69 11 80       	push   $0x80116980
801053fd:	68 c0 71 11 80       	push   $0x801171c0
80105402:	e8 87 e2 ff ff       	call   8010368e <sleep>
80105407:	83 c4 10             	add    $0x10,%esp
8010540a:	eb d2                	jmp    801053de <sys_sleep+0x2f>
      release(&tickslock);
8010540c:	83 ec 0c             	sub    $0xc,%esp
8010540f:	68 80 69 11 80       	push   $0x80116980
80105414:	e8 81 ef ff ff       	call   8010439a <release>
      return -1;
80105419:	83 c4 10             	add    $0x10,%esp
8010541c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105421:	eb 15                	jmp    80105438 <sys_sleep+0x89>
  }
  release(&tickslock);
80105423:	83 ec 0c             	sub    $0xc,%esp
80105426:	68 80 69 11 80       	push   $0x80116980
8010542b:	e8 6a ef ff ff       	call   8010439a <release>
  return 0;
80105430:	83 c4 10             	add    $0x10,%esp
80105433:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105438:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010543b:	c9                   	leave  
8010543c:	c3                   	ret    
    return -1;
8010543d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105442:	eb f4                	jmp    80105438 <sys_sleep+0x89>

80105444 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105444:	55                   	push   %ebp
80105445:	89 e5                	mov    %esp,%ebp
80105447:	53                   	push   %ebx
80105448:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
8010544b:	68 80 69 11 80       	push   $0x80116980
80105450:	e8 e0 ee ff ff       	call   80104335 <acquire>
  xticks = ticks;
80105455:	8b 1d c0 71 11 80    	mov    0x801171c0,%ebx
  release(&tickslock);
8010545b:	c7 04 24 80 69 11 80 	movl   $0x80116980,(%esp)
80105462:	e8 33 ef ff ff       	call   8010439a <release>
  return xticks;
}
80105467:	89 d8                	mov    %ebx,%eax
80105469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010546c:	c9                   	leave  
8010546d:	c3                   	ret    

8010546e <sys_setpri>:

int 
sys_setpri(void)
{
8010546e:	55                   	push   %ebp
8010546f:	89 e5                	mov    %esp,%ebp
80105471:	83 ec 20             	sub    $0x20,%esp
    int PID;
    int pri;
    if(argint(0, &PID) < 0)
80105474:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105477:	50                   	push   %eax
80105478:	6a 00                	push   $0x0
8010547a:	e8 ad f1 ff ff       	call   8010462c <argint>
8010547f:	83 c4 10             	add    $0x10,%esp
80105482:	85 c0                	test   %eax,%eax
80105484:	78 28                	js     801054ae <sys_setpri+0x40>
        return -1;
    if(argint(1, &pri) < 0)
80105486:	83 ec 08             	sub    $0x8,%esp
80105489:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010548c:	50                   	push   %eax
8010548d:	6a 01                	push   $0x1
8010548f:	e8 98 f1 ff ff       	call   8010462c <argint>
80105494:	83 c4 10             	add    $0x10,%esp
80105497:	85 c0                	test   %eax,%eax
80105499:	78 1a                	js     801054b5 <sys_setpri+0x47>
        return -1;
   return setpri(PID, pri); 
8010549b:	83 ec 08             	sub    $0x8,%esp
8010549e:	ff 75 f0             	pushl  -0x10(%ebp)
801054a1:	ff 75 f4             	pushl  -0xc(%ebp)
801054a4:	e8 d4 e4 ff ff       	call   8010397d <setpri>
801054a9:	83 c4 10             	add    $0x10,%esp
}
801054ac:	c9                   	leave  
801054ad:	c3                   	ret    
        return -1;
801054ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b3:	eb f7                	jmp    801054ac <sys_setpri+0x3e>
        return -1;
801054b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ba:	eb f0                	jmp    801054ac <sys_setpri+0x3e>

801054bc <sys_getpri>:

int
sys_getpri(void)
{
801054bc:	55                   	push   %ebp
801054bd:	89 e5                	mov    %esp,%ebp
801054bf:	83 ec 20             	sub    $0x20,%esp
    int PID;
    if(argint(0, &PID) < 0)
801054c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054c5:	50                   	push   %eax
801054c6:	6a 00                	push   $0x0
801054c8:	e8 5f f1 ff ff       	call   8010462c <argint>
801054cd:	83 c4 10             	add    $0x10,%esp
801054d0:	85 c0                	test   %eax,%eax
801054d2:	78 10                	js     801054e4 <sys_getpri+0x28>
        return -1;
    return getpri(PID);
801054d4:	83 ec 0c             	sub    $0xc,%esp
801054d7:	ff 75 f4             	pushl  -0xc(%ebp)
801054da:	e8 dd e5 ff ff       	call   80103abc <getpri>
801054df:	83 c4 10             	add    $0x10,%esp
}
801054e2:	c9                   	leave  
801054e3:	c3                   	ret    
        return -1;
801054e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e9:	eb f7                	jmp    801054e2 <sys_getpri+0x26>

801054eb <sys_getpinfo>:

int
sys_getpinfo()
{
801054eb:	55                   	push   %ebp
801054ec:	89 e5                	mov    %esp,%ebp
801054ee:	83 ec 1c             	sub    $0x1c,%esp
    struct pstat *ps;
    if(argptr(0, (void*)&ps, sizeof(*ps))< 0){
801054f1:	68 00 0c 00 00       	push   $0xc00
801054f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054f9:	50                   	push   %eax
801054fa:	6a 00                	push   $0x0
801054fc:	e8 53 f1 ff ff       	call   80104654 <argptr>
80105501:	83 c4 10             	add    $0x10,%esp
80105504:	85 c0                	test   %eax,%eax
80105506:	78 10                	js     80105518 <sys_getpinfo+0x2d>
        return -1;
    }
    return getpinfo(ps);
80105508:	83 ec 0c             	sub    $0xc,%esp
8010550b:	ff 75 f4             	pushl  -0xc(%ebp)
8010550e:	e8 df e5 ff ff       	call   80103af2 <getpinfo>
80105513:	83 c4 10             	add    $0x10,%esp
}
80105516:	c9                   	leave  
80105517:	c3                   	ret    
        return -1;
80105518:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551d:	eb f7                	jmp    80105516 <sys_getpinfo+0x2b>

8010551f <sys_fork2>:

int
sys_fork2()
{
8010551f:	55                   	push   %ebp
80105520:	89 e5                	mov    %esp,%ebp
80105522:	83 ec 20             	sub    $0x20,%esp
    int pri;
    if(argint(0, &pri) < 0)
80105525:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105528:	50                   	push   %eax
80105529:	6a 00                	push   $0x0
8010552b:	e8 fc f0 ff ff       	call   8010462c <argint>
80105530:	83 c4 10             	add    $0x10,%esp
80105533:	85 c0                	test   %eax,%eax
80105535:	78 10                	js     80105547 <sys_fork2+0x28>
        return -1;
    return fork2(pri);
80105537:	83 ec 0c             	sub    $0xc,%esp
8010553a:	ff 75 f4             	pushl  -0xc(%ebp)
8010553d:	e8 3f ea ff ff       	call   80103f81 <fork2>
80105542:	83 c4 10             	add    $0x10,%esp
}
80105545:	c9                   	leave  
80105546:	c3                   	ret    
        return -1;
80105547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554c:	eb f7                	jmp    80105545 <sys_fork2+0x26>

8010554e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010554e:	1e                   	push   %ds
  pushl %es
8010554f:	06                   	push   %es
  pushl %fs
80105550:	0f a0                	push   %fs
  pushl %gs
80105552:	0f a8                	push   %gs
  pushal
80105554:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105555:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105559:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010555b:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010555d:	54                   	push   %esp
  call trap
8010555e:	e8 e3 00 00 00       	call   80105646 <trap>
  addl $4, %esp
80105563:	83 c4 04             	add    $0x4,%esp

80105566 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105566:	61                   	popa   
  popl %gs
80105567:	0f a9                	pop    %gs
  popl %fs
80105569:	0f a1                	pop    %fs
  popl %es
8010556b:	07                   	pop    %es
  popl %ds
8010556c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010556d:	83 c4 08             	add    $0x8,%esp
  iret
80105570:	cf                   	iret   

80105571 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105571:	55                   	push   %ebp
80105572:	89 e5                	mov    %esp,%ebp
80105574:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80105577:	b8 00 00 00 00       	mov    $0x0,%eax
8010557c:	eb 4a                	jmp    801055c8 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010557e:	8b 0c 85 18 a0 10 80 	mov    -0x7fef5fe8(,%eax,4),%ecx
80105585:	66 89 0c c5 c0 69 11 	mov    %cx,-0x7fee9640(,%eax,8)
8010558c:	80 
8010558d:	66 c7 04 c5 c2 69 11 	movw   $0x8,-0x7fee963e(,%eax,8)
80105594:	80 08 00 
80105597:	c6 04 c5 c4 69 11 80 	movb   $0x0,-0x7fee963c(,%eax,8)
8010559e:	00 
8010559f:	0f b6 14 c5 c5 69 11 	movzbl -0x7fee963b(,%eax,8),%edx
801055a6:	80 
801055a7:	83 e2 f0             	and    $0xfffffff0,%edx
801055aa:	83 ca 0e             	or     $0xe,%edx
801055ad:	83 e2 8f             	and    $0xffffff8f,%edx
801055b0:	83 ca 80             	or     $0xffffff80,%edx
801055b3:	88 14 c5 c5 69 11 80 	mov    %dl,-0x7fee963b(,%eax,8)
801055ba:	c1 e9 10             	shr    $0x10,%ecx
801055bd:	66 89 0c c5 c6 69 11 	mov    %cx,-0x7fee963a(,%eax,8)
801055c4:	80 
  for(i = 0; i < 256; i++)
801055c5:	83 c0 01             	add    $0x1,%eax
801055c8:	3d ff 00 00 00       	cmp    $0xff,%eax
801055cd:	7e af                	jle    8010557e <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801055cf:	8b 15 18 a1 10 80    	mov    0x8010a118,%edx
801055d5:	66 89 15 c0 6b 11 80 	mov    %dx,0x80116bc0
801055dc:	66 c7 05 c2 6b 11 80 	movw   $0x8,0x80116bc2
801055e3:	08 00 
801055e5:	c6 05 c4 6b 11 80 00 	movb   $0x0,0x80116bc4
801055ec:	0f b6 05 c5 6b 11 80 	movzbl 0x80116bc5,%eax
801055f3:	83 c8 0f             	or     $0xf,%eax
801055f6:	83 e0 ef             	and    $0xffffffef,%eax
801055f9:	83 c8 e0             	or     $0xffffffe0,%eax
801055fc:	a2 c5 6b 11 80       	mov    %al,0x80116bc5
80105601:	c1 ea 10             	shr    $0x10,%edx
80105604:	66 89 15 c6 6b 11 80 	mov    %dx,0x80116bc6

  initlock(&tickslock, "time");
8010560b:	83 ec 08             	sub    $0x8,%esp
8010560e:	68 69 74 10 80       	push   $0x80107469
80105613:	68 80 69 11 80       	push   $0x80116980
80105618:	e8 dc eb ff ff       	call   801041f9 <initlock>
}
8010561d:	83 c4 10             	add    $0x10,%esp
80105620:	c9                   	leave  
80105621:	c3                   	ret    

80105622 <idtinit>:

void
idtinit(void)
{
80105622:	55                   	push   %ebp
80105623:	89 e5                	mov    %esp,%ebp
80105625:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105628:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
8010562e:	b8 c0 69 11 80       	mov    $0x801169c0,%eax
80105633:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105637:	c1 e8 10             	shr    $0x10,%eax
8010563a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010563e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105641:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105644:	c9                   	leave  
80105645:	c3                   	ret    

80105646 <trap>:

void
trap(struct trapframe *tf)
{
80105646:	55                   	push   %ebp
80105647:	89 e5                	mov    %esp,%ebp
80105649:	57                   	push   %edi
8010564a:	56                   	push   %esi
8010564b:	53                   	push   %ebx
8010564c:	83 ec 1c             	sub    $0x1c,%esp
8010564f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105652:	8b 43 30             	mov    0x30(%ebx),%eax
80105655:	83 f8 40             	cmp    $0x40,%eax
80105658:	74 13                	je     8010566d <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }
  //cprintf("%d TRAP CODE \n", tf->trapno);
  switch(tf->trapno){
8010565a:	83 e8 20             	sub    $0x20,%eax
8010565d:	83 f8 1f             	cmp    $0x1f,%eax
80105660:	0f 87 3a 01 00 00    	ja     801057a0 <trap+0x15a>
80105666:	ff 24 85 10 75 10 80 	jmp    *-0x7fef8af0(,%eax,4)
    if(myproc()->killed)
8010566d:	e8 e7 dc ff ff       	call   80103359 <myproc>
80105672:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105676:	75 1f                	jne    80105697 <trap+0x51>
    myproc()->tf = tf;
80105678:	e8 dc dc ff ff       	call   80103359 <myproc>
8010567d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105680:	e8 6a f0 ff ff       	call   801046ef <syscall>
    if(myproc()->killed)
80105685:	e8 cf dc ff ff       	call   80103359 <myproc>
8010568a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010568e:	74 7e                	je     8010570e <trap+0xc8>
      exit();
80105690:	e8 fe de ff ff       	call   80103593 <exit>
80105695:	eb 77                	jmp    8010570e <trap+0xc8>
      exit();
80105697:	e8 f7 de ff ff       	call   80103593 <exit>
8010569c:	eb da                	jmp    80105678 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010569e:	e8 9b dc ff ff       	call   8010333e <cpuid>
801056a3:	85 c0                	test   %eax,%eax
801056a5:	74 6f                	je     80105716 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801056a7:	e8 ed cc ff ff       	call   80102399 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801056ac:	e8 a8 dc ff ff       	call   80103359 <myproc>
801056b1:	85 c0                	test   %eax,%eax
801056b3:	74 1c                	je     801056d1 <trap+0x8b>
801056b5:	e8 9f dc ff ff       	call   80103359 <myproc>
801056ba:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801056be:	74 11                	je     801056d1 <trap+0x8b>
801056c0:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801056c4:	83 e0 03             	and    $0x3,%eax
801056c7:	66 83 f8 03          	cmp    $0x3,%ax
801056cb:	0f 84 62 01 00 00    	je     80105833 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801056d1:	e8 83 dc ff ff       	call   80103359 <myproc>
801056d6:	85 c0                	test   %eax,%eax
801056d8:	74 0f                	je     801056e9 <trap+0xa3>
801056da:	e8 7a dc ff ff       	call   80103359 <myproc>
801056df:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801056e3:	0f 84 54 01 00 00    	je     8010583d <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER) {
    yield();
  }
  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801056e9:	e8 6b dc ff ff       	call   80103359 <myproc>
801056ee:	85 c0                	test   %eax,%eax
801056f0:	74 1c                	je     8010570e <trap+0xc8>
801056f2:	e8 62 dc ff ff       	call   80103359 <myproc>
801056f7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801056fb:	74 11                	je     8010570e <trap+0xc8>
801056fd:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105701:	83 e0 03             	and    $0x3,%eax
80105704:	66 83 f8 03          	cmp    $0x3,%ax
80105708:	0f 84 43 01 00 00    	je     80105851 <trap+0x20b>
    exit();
}
8010570e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105711:	5b                   	pop    %ebx
80105712:	5e                   	pop    %esi
80105713:	5f                   	pop    %edi
80105714:	5d                   	pop    %ebp
80105715:	c3                   	ret    
      acquire(&tickslock);
80105716:	83 ec 0c             	sub    $0xc,%esp
80105719:	68 80 69 11 80       	push   $0x80116980
8010571e:	e8 12 ec ff ff       	call   80104335 <acquire>
      ticks++;
80105723:	83 05 c0 71 11 80 01 	addl   $0x1,0x801171c0
      wakeup(&ticks);
8010572a:	c7 04 24 c0 71 11 80 	movl   $0x801171c0,(%esp)
80105731:	e8 c0 e0 ff ff       	call   801037f6 <wakeup>
      release(&tickslock);
80105736:	c7 04 24 80 69 11 80 	movl   $0x80116980,(%esp)
8010573d:	e8 58 ec ff ff       	call   8010439a <release>
80105742:	83 c4 10             	add    $0x10,%esp
80105745:	e9 5d ff ff ff       	jmp    801056a7 <trap+0x61>
    ideintr();
8010574a:	e8 24 c6 ff ff       	call   80101d73 <ideintr>
    lapiceoi();
8010574f:	e8 45 cc ff ff       	call   80102399 <lapiceoi>
    break;
80105754:	e9 53 ff ff ff       	jmp    801056ac <trap+0x66>
    kbdintr();
80105759:	e8 7f ca ff ff       	call   801021dd <kbdintr>
    lapiceoi();
8010575e:	e8 36 cc ff ff       	call   80102399 <lapiceoi>
    break;
80105763:	e9 44 ff ff ff       	jmp    801056ac <trap+0x66>
    uartintr();
80105768:	e8 05 02 00 00       	call   80105972 <uartintr>
    lapiceoi();
8010576d:	e8 27 cc ff ff       	call   80102399 <lapiceoi>
    break;
80105772:	e9 35 ff ff ff       	jmp    801056ac <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105777:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010577a:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010577e:	e8 bb db ff ff       	call   8010333e <cpuid>
80105783:	57                   	push   %edi
80105784:	0f b7 f6             	movzwl %si,%esi
80105787:	56                   	push   %esi
80105788:	50                   	push   %eax
80105789:	68 74 74 10 80       	push   $0x80107474
8010578e:	e8 78 ae ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105793:	e8 01 cc ff ff       	call   80102399 <lapiceoi>
    break;
80105798:	83 c4 10             	add    $0x10,%esp
8010579b:	e9 0c ff ff ff       	jmp    801056ac <trap+0x66>
    if( myproc() == 0 || (tf->cs&3) == 0){
801057a0:	e8 b4 db ff ff       	call   80103359 <myproc>
801057a5:	85 c0                	test   %eax,%eax
801057a7:	74 5f                	je     80105808 <trap+0x1c2>
801057a9:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801057ad:	74 59                	je     80105808 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801057af:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801057b2:	8b 43 38             	mov    0x38(%ebx),%eax
801057b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801057b8:	e8 81 db ff ff       	call   8010333e <cpuid>
801057bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
801057c0:	8b 53 34             	mov    0x34(%ebx),%edx
801057c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
801057c6:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801057c9:	e8 8b db ff ff       	call   80103359 <myproc>
801057ce:	8d 48 6c             	lea    0x6c(%eax),%ecx
801057d1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801057d4:	e8 80 db ff ff       	call   80103359 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801057d9:	57                   	push   %edi
801057da:	ff 75 e4             	pushl  -0x1c(%ebp)
801057dd:	ff 75 e0             	pushl  -0x20(%ebp)
801057e0:	ff 75 dc             	pushl  -0x24(%ebp)
801057e3:	56                   	push   %esi
801057e4:	ff 75 d8             	pushl  -0x28(%ebp)
801057e7:	ff 70 10             	pushl  0x10(%eax)
801057ea:	68 cc 74 10 80       	push   $0x801074cc
801057ef:	e8 17 ae ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801057f4:	83 c4 20             	add    $0x20,%esp
801057f7:	e8 5d db ff ff       	call   80103359 <myproc>
801057fc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105803:	e9 a4 fe ff ff       	jmp    801056ac <trap+0x66>
80105808:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010580b:	8b 73 38             	mov    0x38(%ebx),%esi
8010580e:	e8 2b db ff ff       	call   8010333e <cpuid>
80105813:	83 ec 0c             	sub    $0xc,%esp
80105816:	57                   	push   %edi
80105817:	56                   	push   %esi
80105818:	50                   	push   %eax
80105819:	ff 73 30             	pushl  0x30(%ebx)
8010581c:	68 98 74 10 80       	push   $0x80107498
80105821:	e8 e5 ad ff ff       	call   8010060b <cprintf>
      panic("trap");
80105826:	83 c4 14             	add    $0x14,%esp
80105829:	68 6e 74 10 80       	push   $0x8010746e
8010582e:	e8 15 ab ff ff       	call   80100348 <panic>
    exit();
80105833:	e8 5b dd ff ff       	call   80103593 <exit>
80105838:	e9 94 fe ff ff       	jmp    801056d1 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010583d:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105841:	0f 85 a2 fe ff ff    	jne    801056e9 <trap+0xa3>
    yield();
80105847:	e8 10 de ff ff       	call   8010365c <yield>
8010584c:	e9 98 fe ff ff       	jmp    801056e9 <trap+0xa3>
    exit();
80105851:	e8 3d dd ff ff       	call   80103593 <exit>
80105856:	e9 b3 fe ff ff       	jmp    8010570e <trap+0xc8>

8010585b <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010585b:	55                   	push   %ebp
8010585c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010585e:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105865:	74 15                	je     8010587c <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105867:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010586c:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010586d:	a8 01                	test   $0x1,%al
8010586f:	74 12                	je     80105883 <uartgetc+0x28>
80105871:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105876:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105877:	0f b6 c0             	movzbl %al,%eax
}
8010587a:	5d                   	pop    %ebp
8010587b:	c3                   	ret    
    return -1;
8010587c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105881:	eb f7                	jmp    8010587a <uartgetc+0x1f>
    return -1;
80105883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105888:	eb f0                	jmp    8010587a <uartgetc+0x1f>

8010588a <uartputc>:
  if(!uart)
8010588a:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105891:	74 3b                	je     801058ce <uartputc+0x44>
{
80105893:	55                   	push   %ebp
80105894:	89 e5                	mov    %esp,%ebp
80105896:	53                   	push   %ebx
80105897:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010589a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010589f:	eb 10                	jmp    801058b1 <uartputc+0x27>
    microdelay(10);
801058a1:	83 ec 0c             	sub    $0xc,%esp
801058a4:	6a 0a                	push   $0xa
801058a6:	e8 0d cb ff ff       	call   801023b8 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801058ab:	83 c3 01             	add    $0x1,%ebx
801058ae:	83 c4 10             	add    $0x10,%esp
801058b1:	83 fb 7f             	cmp    $0x7f,%ebx
801058b4:	7f 0a                	jg     801058c0 <uartputc+0x36>
801058b6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801058bb:	ec                   	in     (%dx),%al
801058bc:	a8 20                	test   $0x20,%al
801058be:	74 e1                	je     801058a1 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801058c0:	8b 45 08             	mov    0x8(%ebp),%eax
801058c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
801058c8:	ee                   	out    %al,(%dx)
}
801058c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801058cc:	c9                   	leave  
801058cd:	c3                   	ret    
801058ce:	f3 c3                	repz ret 

801058d0 <uartinit>:
{
801058d0:	55                   	push   %ebp
801058d1:	89 e5                	mov    %esp,%ebp
801058d3:	56                   	push   %esi
801058d4:	53                   	push   %ebx
801058d5:	b9 00 00 00 00       	mov    $0x0,%ecx
801058da:	ba fa 03 00 00       	mov    $0x3fa,%edx
801058df:	89 c8                	mov    %ecx,%eax
801058e1:	ee                   	out    %al,(%dx)
801058e2:	be fb 03 00 00       	mov    $0x3fb,%esi
801058e7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801058ec:	89 f2                	mov    %esi,%edx
801058ee:	ee                   	out    %al,(%dx)
801058ef:	b8 0c 00 00 00       	mov    $0xc,%eax
801058f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
801058f9:	ee                   	out    %al,(%dx)
801058fa:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801058ff:	89 c8                	mov    %ecx,%eax
80105901:	89 da                	mov    %ebx,%edx
80105903:	ee                   	out    %al,(%dx)
80105904:	b8 03 00 00 00       	mov    $0x3,%eax
80105909:	89 f2                	mov    %esi,%edx
8010590b:	ee                   	out    %al,(%dx)
8010590c:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105911:	89 c8                	mov    %ecx,%eax
80105913:	ee                   	out    %al,(%dx)
80105914:	b8 01 00 00 00       	mov    $0x1,%eax
80105919:	89 da                	mov    %ebx,%edx
8010591b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010591c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105921:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105922:	3c ff                	cmp    $0xff,%al
80105924:	74 45                	je     8010596b <uartinit+0x9b>
  uart = 1;
80105926:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
8010592d:	00 00 00 
80105930:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105935:	ec                   	in     (%dx),%al
80105936:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010593b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010593c:	83 ec 08             	sub    $0x8,%esp
8010593f:	6a 00                	push   $0x0
80105941:	6a 04                	push   $0x4
80105943:	e8 36 c6 ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105948:	83 c4 10             	add    $0x10,%esp
8010594b:	bb 90 75 10 80       	mov    $0x80107590,%ebx
80105950:	eb 12                	jmp    80105964 <uartinit+0x94>
    uartputc(*p);
80105952:	83 ec 0c             	sub    $0xc,%esp
80105955:	0f be c0             	movsbl %al,%eax
80105958:	50                   	push   %eax
80105959:	e8 2c ff ff ff       	call   8010588a <uartputc>
  for(p="xv6...\n"; *p; p++)
8010595e:	83 c3 01             	add    $0x1,%ebx
80105961:	83 c4 10             	add    $0x10,%esp
80105964:	0f b6 03             	movzbl (%ebx),%eax
80105967:	84 c0                	test   %al,%al
80105969:	75 e7                	jne    80105952 <uartinit+0x82>
}
8010596b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010596e:	5b                   	pop    %ebx
8010596f:	5e                   	pop    %esi
80105970:	5d                   	pop    %ebp
80105971:	c3                   	ret    

80105972 <uartintr>:

void
uartintr(void)
{
80105972:	55                   	push   %ebp
80105973:	89 e5                	mov    %esp,%ebp
80105975:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105978:	68 5b 58 10 80       	push   $0x8010585b
8010597d:	e8 bc ad ff ff       	call   8010073e <consoleintr>
}
80105982:	83 c4 10             	add    $0x10,%esp
80105985:	c9                   	leave  
80105986:	c3                   	ret    

80105987 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105987:	6a 00                	push   $0x0
  pushl $0
80105989:	6a 00                	push   $0x0
  jmp alltraps
8010598b:	e9 be fb ff ff       	jmp    8010554e <alltraps>

80105990 <vector1>:
.globl vector1
vector1:
  pushl $0
80105990:	6a 00                	push   $0x0
  pushl $1
80105992:	6a 01                	push   $0x1
  jmp alltraps
80105994:	e9 b5 fb ff ff       	jmp    8010554e <alltraps>

80105999 <vector2>:
.globl vector2
vector2:
  pushl $0
80105999:	6a 00                	push   $0x0
  pushl $2
8010599b:	6a 02                	push   $0x2
  jmp alltraps
8010599d:	e9 ac fb ff ff       	jmp    8010554e <alltraps>

801059a2 <vector3>:
.globl vector3
vector3:
  pushl $0
801059a2:	6a 00                	push   $0x0
  pushl $3
801059a4:	6a 03                	push   $0x3
  jmp alltraps
801059a6:	e9 a3 fb ff ff       	jmp    8010554e <alltraps>

801059ab <vector4>:
.globl vector4
vector4:
  pushl $0
801059ab:	6a 00                	push   $0x0
  pushl $4
801059ad:	6a 04                	push   $0x4
  jmp alltraps
801059af:	e9 9a fb ff ff       	jmp    8010554e <alltraps>

801059b4 <vector5>:
.globl vector5
vector5:
  pushl $0
801059b4:	6a 00                	push   $0x0
  pushl $5
801059b6:	6a 05                	push   $0x5
  jmp alltraps
801059b8:	e9 91 fb ff ff       	jmp    8010554e <alltraps>

801059bd <vector6>:
.globl vector6
vector6:
  pushl $0
801059bd:	6a 00                	push   $0x0
  pushl $6
801059bf:	6a 06                	push   $0x6
  jmp alltraps
801059c1:	e9 88 fb ff ff       	jmp    8010554e <alltraps>

801059c6 <vector7>:
.globl vector7
vector7:
  pushl $0
801059c6:	6a 00                	push   $0x0
  pushl $7
801059c8:	6a 07                	push   $0x7
  jmp alltraps
801059ca:	e9 7f fb ff ff       	jmp    8010554e <alltraps>

801059cf <vector8>:
.globl vector8
vector8:
  pushl $8
801059cf:	6a 08                	push   $0x8
  jmp alltraps
801059d1:	e9 78 fb ff ff       	jmp    8010554e <alltraps>

801059d6 <vector9>:
.globl vector9
vector9:
  pushl $0
801059d6:	6a 00                	push   $0x0
  pushl $9
801059d8:	6a 09                	push   $0x9
  jmp alltraps
801059da:	e9 6f fb ff ff       	jmp    8010554e <alltraps>

801059df <vector10>:
.globl vector10
vector10:
  pushl $10
801059df:	6a 0a                	push   $0xa
  jmp alltraps
801059e1:	e9 68 fb ff ff       	jmp    8010554e <alltraps>

801059e6 <vector11>:
.globl vector11
vector11:
  pushl $11
801059e6:	6a 0b                	push   $0xb
  jmp alltraps
801059e8:	e9 61 fb ff ff       	jmp    8010554e <alltraps>

801059ed <vector12>:
.globl vector12
vector12:
  pushl $12
801059ed:	6a 0c                	push   $0xc
  jmp alltraps
801059ef:	e9 5a fb ff ff       	jmp    8010554e <alltraps>

801059f4 <vector13>:
.globl vector13
vector13:
  pushl $13
801059f4:	6a 0d                	push   $0xd
  jmp alltraps
801059f6:	e9 53 fb ff ff       	jmp    8010554e <alltraps>

801059fb <vector14>:
.globl vector14
vector14:
  pushl $14
801059fb:	6a 0e                	push   $0xe
  jmp alltraps
801059fd:	e9 4c fb ff ff       	jmp    8010554e <alltraps>

80105a02 <vector15>:
.globl vector15
vector15:
  pushl $0
80105a02:	6a 00                	push   $0x0
  pushl $15
80105a04:	6a 0f                	push   $0xf
  jmp alltraps
80105a06:	e9 43 fb ff ff       	jmp    8010554e <alltraps>

80105a0b <vector16>:
.globl vector16
vector16:
  pushl $0
80105a0b:	6a 00                	push   $0x0
  pushl $16
80105a0d:	6a 10                	push   $0x10
  jmp alltraps
80105a0f:	e9 3a fb ff ff       	jmp    8010554e <alltraps>

80105a14 <vector17>:
.globl vector17
vector17:
  pushl $17
80105a14:	6a 11                	push   $0x11
  jmp alltraps
80105a16:	e9 33 fb ff ff       	jmp    8010554e <alltraps>

80105a1b <vector18>:
.globl vector18
vector18:
  pushl $0
80105a1b:	6a 00                	push   $0x0
  pushl $18
80105a1d:	6a 12                	push   $0x12
  jmp alltraps
80105a1f:	e9 2a fb ff ff       	jmp    8010554e <alltraps>

80105a24 <vector19>:
.globl vector19
vector19:
  pushl $0
80105a24:	6a 00                	push   $0x0
  pushl $19
80105a26:	6a 13                	push   $0x13
  jmp alltraps
80105a28:	e9 21 fb ff ff       	jmp    8010554e <alltraps>

80105a2d <vector20>:
.globl vector20
vector20:
  pushl $0
80105a2d:	6a 00                	push   $0x0
  pushl $20
80105a2f:	6a 14                	push   $0x14
  jmp alltraps
80105a31:	e9 18 fb ff ff       	jmp    8010554e <alltraps>

80105a36 <vector21>:
.globl vector21
vector21:
  pushl $0
80105a36:	6a 00                	push   $0x0
  pushl $21
80105a38:	6a 15                	push   $0x15
  jmp alltraps
80105a3a:	e9 0f fb ff ff       	jmp    8010554e <alltraps>

80105a3f <vector22>:
.globl vector22
vector22:
  pushl $0
80105a3f:	6a 00                	push   $0x0
  pushl $22
80105a41:	6a 16                	push   $0x16
  jmp alltraps
80105a43:	e9 06 fb ff ff       	jmp    8010554e <alltraps>

80105a48 <vector23>:
.globl vector23
vector23:
  pushl $0
80105a48:	6a 00                	push   $0x0
  pushl $23
80105a4a:	6a 17                	push   $0x17
  jmp alltraps
80105a4c:	e9 fd fa ff ff       	jmp    8010554e <alltraps>

80105a51 <vector24>:
.globl vector24
vector24:
  pushl $0
80105a51:	6a 00                	push   $0x0
  pushl $24
80105a53:	6a 18                	push   $0x18
  jmp alltraps
80105a55:	e9 f4 fa ff ff       	jmp    8010554e <alltraps>

80105a5a <vector25>:
.globl vector25
vector25:
  pushl $0
80105a5a:	6a 00                	push   $0x0
  pushl $25
80105a5c:	6a 19                	push   $0x19
  jmp alltraps
80105a5e:	e9 eb fa ff ff       	jmp    8010554e <alltraps>

80105a63 <vector26>:
.globl vector26
vector26:
  pushl $0
80105a63:	6a 00                	push   $0x0
  pushl $26
80105a65:	6a 1a                	push   $0x1a
  jmp alltraps
80105a67:	e9 e2 fa ff ff       	jmp    8010554e <alltraps>

80105a6c <vector27>:
.globl vector27
vector27:
  pushl $0
80105a6c:	6a 00                	push   $0x0
  pushl $27
80105a6e:	6a 1b                	push   $0x1b
  jmp alltraps
80105a70:	e9 d9 fa ff ff       	jmp    8010554e <alltraps>

80105a75 <vector28>:
.globl vector28
vector28:
  pushl $0
80105a75:	6a 00                	push   $0x0
  pushl $28
80105a77:	6a 1c                	push   $0x1c
  jmp alltraps
80105a79:	e9 d0 fa ff ff       	jmp    8010554e <alltraps>

80105a7e <vector29>:
.globl vector29
vector29:
  pushl $0
80105a7e:	6a 00                	push   $0x0
  pushl $29
80105a80:	6a 1d                	push   $0x1d
  jmp alltraps
80105a82:	e9 c7 fa ff ff       	jmp    8010554e <alltraps>

80105a87 <vector30>:
.globl vector30
vector30:
  pushl $0
80105a87:	6a 00                	push   $0x0
  pushl $30
80105a89:	6a 1e                	push   $0x1e
  jmp alltraps
80105a8b:	e9 be fa ff ff       	jmp    8010554e <alltraps>

80105a90 <vector31>:
.globl vector31
vector31:
  pushl $0
80105a90:	6a 00                	push   $0x0
  pushl $31
80105a92:	6a 1f                	push   $0x1f
  jmp alltraps
80105a94:	e9 b5 fa ff ff       	jmp    8010554e <alltraps>

80105a99 <vector32>:
.globl vector32
vector32:
  pushl $0
80105a99:	6a 00                	push   $0x0
  pushl $32
80105a9b:	6a 20                	push   $0x20
  jmp alltraps
80105a9d:	e9 ac fa ff ff       	jmp    8010554e <alltraps>

80105aa2 <vector33>:
.globl vector33
vector33:
  pushl $0
80105aa2:	6a 00                	push   $0x0
  pushl $33
80105aa4:	6a 21                	push   $0x21
  jmp alltraps
80105aa6:	e9 a3 fa ff ff       	jmp    8010554e <alltraps>

80105aab <vector34>:
.globl vector34
vector34:
  pushl $0
80105aab:	6a 00                	push   $0x0
  pushl $34
80105aad:	6a 22                	push   $0x22
  jmp alltraps
80105aaf:	e9 9a fa ff ff       	jmp    8010554e <alltraps>

80105ab4 <vector35>:
.globl vector35
vector35:
  pushl $0
80105ab4:	6a 00                	push   $0x0
  pushl $35
80105ab6:	6a 23                	push   $0x23
  jmp alltraps
80105ab8:	e9 91 fa ff ff       	jmp    8010554e <alltraps>

80105abd <vector36>:
.globl vector36
vector36:
  pushl $0
80105abd:	6a 00                	push   $0x0
  pushl $36
80105abf:	6a 24                	push   $0x24
  jmp alltraps
80105ac1:	e9 88 fa ff ff       	jmp    8010554e <alltraps>

80105ac6 <vector37>:
.globl vector37
vector37:
  pushl $0
80105ac6:	6a 00                	push   $0x0
  pushl $37
80105ac8:	6a 25                	push   $0x25
  jmp alltraps
80105aca:	e9 7f fa ff ff       	jmp    8010554e <alltraps>

80105acf <vector38>:
.globl vector38
vector38:
  pushl $0
80105acf:	6a 00                	push   $0x0
  pushl $38
80105ad1:	6a 26                	push   $0x26
  jmp alltraps
80105ad3:	e9 76 fa ff ff       	jmp    8010554e <alltraps>

80105ad8 <vector39>:
.globl vector39
vector39:
  pushl $0
80105ad8:	6a 00                	push   $0x0
  pushl $39
80105ada:	6a 27                	push   $0x27
  jmp alltraps
80105adc:	e9 6d fa ff ff       	jmp    8010554e <alltraps>

80105ae1 <vector40>:
.globl vector40
vector40:
  pushl $0
80105ae1:	6a 00                	push   $0x0
  pushl $40
80105ae3:	6a 28                	push   $0x28
  jmp alltraps
80105ae5:	e9 64 fa ff ff       	jmp    8010554e <alltraps>

80105aea <vector41>:
.globl vector41
vector41:
  pushl $0
80105aea:	6a 00                	push   $0x0
  pushl $41
80105aec:	6a 29                	push   $0x29
  jmp alltraps
80105aee:	e9 5b fa ff ff       	jmp    8010554e <alltraps>

80105af3 <vector42>:
.globl vector42
vector42:
  pushl $0
80105af3:	6a 00                	push   $0x0
  pushl $42
80105af5:	6a 2a                	push   $0x2a
  jmp alltraps
80105af7:	e9 52 fa ff ff       	jmp    8010554e <alltraps>

80105afc <vector43>:
.globl vector43
vector43:
  pushl $0
80105afc:	6a 00                	push   $0x0
  pushl $43
80105afe:	6a 2b                	push   $0x2b
  jmp alltraps
80105b00:	e9 49 fa ff ff       	jmp    8010554e <alltraps>

80105b05 <vector44>:
.globl vector44
vector44:
  pushl $0
80105b05:	6a 00                	push   $0x0
  pushl $44
80105b07:	6a 2c                	push   $0x2c
  jmp alltraps
80105b09:	e9 40 fa ff ff       	jmp    8010554e <alltraps>

80105b0e <vector45>:
.globl vector45
vector45:
  pushl $0
80105b0e:	6a 00                	push   $0x0
  pushl $45
80105b10:	6a 2d                	push   $0x2d
  jmp alltraps
80105b12:	e9 37 fa ff ff       	jmp    8010554e <alltraps>

80105b17 <vector46>:
.globl vector46
vector46:
  pushl $0
80105b17:	6a 00                	push   $0x0
  pushl $46
80105b19:	6a 2e                	push   $0x2e
  jmp alltraps
80105b1b:	e9 2e fa ff ff       	jmp    8010554e <alltraps>

80105b20 <vector47>:
.globl vector47
vector47:
  pushl $0
80105b20:	6a 00                	push   $0x0
  pushl $47
80105b22:	6a 2f                	push   $0x2f
  jmp alltraps
80105b24:	e9 25 fa ff ff       	jmp    8010554e <alltraps>

80105b29 <vector48>:
.globl vector48
vector48:
  pushl $0
80105b29:	6a 00                	push   $0x0
  pushl $48
80105b2b:	6a 30                	push   $0x30
  jmp alltraps
80105b2d:	e9 1c fa ff ff       	jmp    8010554e <alltraps>

80105b32 <vector49>:
.globl vector49
vector49:
  pushl $0
80105b32:	6a 00                	push   $0x0
  pushl $49
80105b34:	6a 31                	push   $0x31
  jmp alltraps
80105b36:	e9 13 fa ff ff       	jmp    8010554e <alltraps>

80105b3b <vector50>:
.globl vector50
vector50:
  pushl $0
80105b3b:	6a 00                	push   $0x0
  pushl $50
80105b3d:	6a 32                	push   $0x32
  jmp alltraps
80105b3f:	e9 0a fa ff ff       	jmp    8010554e <alltraps>

80105b44 <vector51>:
.globl vector51
vector51:
  pushl $0
80105b44:	6a 00                	push   $0x0
  pushl $51
80105b46:	6a 33                	push   $0x33
  jmp alltraps
80105b48:	e9 01 fa ff ff       	jmp    8010554e <alltraps>

80105b4d <vector52>:
.globl vector52
vector52:
  pushl $0
80105b4d:	6a 00                	push   $0x0
  pushl $52
80105b4f:	6a 34                	push   $0x34
  jmp alltraps
80105b51:	e9 f8 f9 ff ff       	jmp    8010554e <alltraps>

80105b56 <vector53>:
.globl vector53
vector53:
  pushl $0
80105b56:	6a 00                	push   $0x0
  pushl $53
80105b58:	6a 35                	push   $0x35
  jmp alltraps
80105b5a:	e9 ef f9 ff ff       	jmp    8010554e <alltraps>

80105b5f <vector54>:
.globl vector54
vector54:
  pushl $0
80105b5f:	6a 00                	push   $0x0
  pushl $54
80105b61:	6a 36                	push   $0x36
  jmp alltraps
80105b63:	e9 e6 f9 ff ff       	jmp    8010554e <alltraps>

80105b68 <vector55>:
.globl vector55
vector55:
  pushl $0
80105b68:	6a 00                	push   $0x0
  pushl $55
80105b6a:	6a 37                	push   $0x37
  jmp alltraps
80105b6c:	e9 dd f9 ff ff       	jmp    8010554e <alltraps>

80105b71 <vector56>:
.globl vector56
vector56:
  pushl $0
80105b71:	6a 00                	push   $0x0
  pushl $56
80105b73:	6a 38                	push   $0x38
  jmp alltraps
80105b75:	e9 d4 f9 ff ff       	jmp    8010554e <alltraps>

80105b7a <vector57>:
.globl vector57
vector57:
  pushl $0
80105b7a:	6a 00                	push   $0x0
  pushl $57
80105b7c:	6a 39                	push   $0x39
  jmp alltraps
80105b7e:	e9 cb f9 ff ff       	jmp    8010554e <alltraps>

80105b83 <vector58>:
.globl vector58
vector58:
  pushl $0
80105b83:	6a 00                	push   $0x0
  pushl $58
80105b85:	6a 3a                	push   $0x3a
  jmp alltraps
80105b87:	e9 c2 f9 ff ff       	jmp    8010554e <alltraps>

80105b8c <vector59>:
.globl vector59
vector59:
  pushl $0
80105b8c:	6a 00                	push   $0x0
  pushl $59
80105b8e:	6a 3b                	push   $0x3b
  jmp alltraps
80105b90:	e9 b9 f9 ff ff       	jmp    8010554e <alltraps>

80105b95 <vector60>:
.globl vector60
vector60:
  pushl $0
80105b95:	6a 00                	push   $0x0
  pushl $60
80105b97:	6a 3c                	push   $0x3c
  jmp alltraps
80105b99:	e9 b0 f9 ff ff       	jmp    8010554e <alltraps>

80105b9e <vector61>:
.globl vector61
vector61:
  pushl $0
80105b9e:	6a 00                	push   $0x0
  pushl $61
80105ba0:	6a 3d                	push   $0x3d
  jmp alltraps
80105ba2:	e9 a7 f9 ff ff       	jmp    8010554e <alltraps>

80105ba7 <vector62>:
.globl vector62
vector62:
  pushl $0
80105ba7:	6a 00                	push   $0x0
  pushl $62
80105ba9:	6a 3e                	push   $0x3e
  jmp alltraps
80105bab:	e9 9e f9 ff ff       	jmp    8010554e <alltraps>

80105bb0 <vector63>:
.globl vector63
vector63:
  pushl $0
80105bb0:	6a 00                	push   $0x0
  pushl $63
80105bb2:	6a 3f                	push   $0x3f
  jmp alltraps
80105bb4:	e9 95 f9 ff ff       	jmp    8010554e <alltraps>

80105bb9 <vector64>:
.globl vector64
vector64:
  pushl $0
80105bb9:	6a 00                	push   $0x0
  pushl $64
80105bbb:	6a 40                	push   $0x40
  jmp alltraps
80105bbd:	e9 8c f9 ff ff       	jmp    8010554e <alltraps>

80105bc2 <vector65>:
.globl vector65
vector65:
  pushl $0
80105bc2:	6a 00                	push   $0x0
  pushl $65
80105bc4:	6a 41                	push   $0x41
  jmp alltraps
80105bc6:	e9 83 f9 ff ff       	jmp    8010554e <alltraps>

80105bcb <vector66>:
.globl vector66
vector66:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $66
80105bcd:	6a 42                	push   $0x42
  jmp alltraps
80105bcf:	e9 7a f9 ff ff       	jmp    8010554e <alltraps>

80105bd4 <vector67>:
.globl vector67
vector67:
  pushl $0
80105bd4:	6a 00                	push   $0x0
  pushl $67
80105bd6:	6a 43                	push   $0x43
  jmp alltraps
80105bd8:	e9 71 f9 ff ff       	jmp    8010554e <alltraps>

80105bdd <vector68>:
.globl vector68
vector68:
  pushl $0
80105bdd:	6a 00                	push   $0x0
  pushl $68
80105bdf:	6a 44                	push   $0x44
  jmp alltraps
80105be1:	e9 68 f9 ff ff       	jmp    8010554e <alltraps>

80105be6 <vector69>:
.globl vector69
vector69:
  pushl $0
80105be6:	6a 00                	push   $0x0
  pushl $69
80105be8:	6a 45                	push   $0x45
  jmp alltraps
80105bea:	e9 5f f9 ff ff       	jmp    8010554e <alltraps>

80105bef <vector70>:
.globl vector70
vector70:
  pushl $0
80105bef:	6a 00                	push   $0x0
  pushl $70
80105bf1:	6a 46                	push   $0x46
  jmp alltraps
80105bf3:	e9 56 f9 ff ff       	jmp    8010554e <alltraps>

80105bf8 <vector71>:
.globl vector71
vector71:
  pushl $0
80105bf8:	6a 00                	push   $0x0
  pushl $71
80105bfa:	6a 47                	push   $0x47
  jmp alltraps
80105bfc:	e9 4d f9 ff ff       	jmp    8010554e <alltraps>

80105c01 <vector72>:
.globl vector72
vector72:
  pushl $0
80105c01:	6a 00                	push   $0x0
  pushl $72
80105c03:	6a 48                	push   $0x48
  jmp alltraps
80105c05:	e9 44 f9 ff ff       	jmp    8010554e <alltraps>

80105c0a <vector73>:
.globl vector73
vector73:
  pushl $0
80105c0a:	6a 00                	push   $0x0
  pushl $73
80105c0c:	6a 49                	push   $0x49
  jmp alltraps
80105c0e:	e9 3b f9 ff ff       	jmp    8010554e <alltraps>

80105c13 <vector74>:
.globl vector74
vector74:
  pushl $0
80105c13:	6a 00                	push   $0x0
  pushl $74
80105c15:	6a 4a                	push   $0x4a
  jmp alltraps
80105c17:	e9 32 f9 ff ff       	jmp    8010554e <alltraps>

80105c1c <vector75>:
.globl vector75
vector75:
  pushl $0
80105c1c:	6a 00                	push   $0x0
  pushl $75
80105c1e:	6a 4b                	push   $0x4b
  jmp alltraps
80105c20:	e9 29 f9 ff ff       	jmp    8010554e <alltraps>

80105c25 <vector76>:
.globl vector76
vector76:
  pushl $0
80105c25:	6a 00                	push   $0x0
  pushl $76
80105c27:	6a 4c                	push   $0x4c
  jmp alltraps
80105c29:	e9 20 f9 ff ff       	jmp    8010554e <alltraps>

80105c2e <vector77>:
.globl vector77
vector77:
  pushl $0
80105c2e:	6a 00                	push   $0x0
  pushl $77
80105c30:	6a 4d                	push   $0x4d
  jmp alltraps
80105c32:	e9 17 f9 ff ff       	jmp    8010554e <alltraps>

80105c37 <vector78>:
.globl vector78
vector78:
  pushl $0
80105c37:	6a 00                	push   $0x0
  pushl $78
80105c39:	6a 4e                	push   $0x4e
  jmp alltraps
80105c3b:	e9 0e f9 ff ff       	jmp    8010554e <alltraps>

80105c40 <vector79>:
.globl vector79
vector79:
  pushl $0
80105c40:	6a 00                	push   $0x0
  pushl $79
80105c42:	6a 4f                	push   $0x4f
  jmp alltraps
80105c44:	e9 05 f9 ff ff       	jmp    8010554e <alltraps>

80105c49 <vector80>:
.globl vector80
vector80:
  pushl $0
80105c49:	6a 00                	push   $0x0
  pushl $80
80105c4b:	6a 50                	push   $0x50
  jmp alltraps
80105c4d:	e9 fc f8 ff ff       	jmp    8010554e <alltraps>

80105c52 <vector81>:
.globl vector81
vector81:
  pushl $0
80105c52:	6a 00                	push   $0x0
  pushl $81
80105c54:	6a 51                	push   $0x51
  jmp alltraps
80105c56:	e9 f3 f8 ff ff       	jmp    8010554e <alltraps>

80105c5b <vector82>:
.globl vector82
vector82:
  pushl $0
80105c5b:	6a 00                	push   $0x0
  pushl $82
80105c5d:	6a 52                	push   $0x52
  jmp alltraps
80105c5f:	e9 ea f8 ff ff       	jmp    8010554e <alltraps>

80105c64 <vector83>:
.globl vector83
vector83:
  pushl $0
80105c64:	6a 00                	push   $0x0
  pushl $83
80105c66:	6a 53                	push   $0x53
  jmp alltraps
80105c68:	e9 e1 f8 ff ff       	jmp    8010554e <alltraps>

80105c6d <vector84>:
.globl vector84
vector84:
  pushl $0
80105c6d:	6a 00                	push   $0x0
  pushl $84
80105c6f:	6a 54                	push   $0x54
  jmp alltraps
80105c71:	e9 d8 f8 ff ff       	jmp    8010554e <alltraps>

80105c76 <vector85>:
.globl vector85
vector85:
  pushl $0
80105c76:	6a 00                	push   $0x0
  pushl $85
80105c78:	6a 55                	push   $0x55
  jmp alltraps
80105c7a:	e9 cf f8 ff ff       	jmp    8010554e <alltraps>

80105c7f <vector86>:
.globl vector86
vector86:
  pushl $0
80105c7f:	6a 00                	push   $0x0
  pushl $86
80105c81:	6a 56                	push   $0x56
  jmp alltraps
80105c83:	e9 c6 f8 ff ff       	jmp    8010554e <alltraps>

80105c88 <vector87>:
.globl vector87
vector87:
  pushl $0
80105c88:	6a 00                	push   $0x0
  pushl $87
80105c8a:	6a 57                	push   $0x57
  jmp alltraps
80105c8c:	e9 bd f8 ff ff       	jmp    8010554e <alltraps>

80105c91 <vector88>:
.globl vector88
vector88:
  pushl $0
80105c91:	6a 00                	push   $0x0
  pushl $88
80105c93:	6a 58                	push   $0x58
  jmp alltraps
80105c95:	e9 b4 f8 ff ff       	jmp    8010554e <alltraps>

80105c9a <vector89>:
.globl vector89
vector89:
  pushl $0
80105c9a:	6a 00                	push   $0x0
  pushl $89
80105c9c:	6a 59                	push   $0x59
  jmp alltraps
80105c9e:	e9 ab f8 ff ff       	jmp    8010554e <alltraps>

80105ca3 <vector90>:
.globl vector90
vector90:
  pushl $0
80105ca3:	6a 00                	push   $0x0
  pushl $90
80105ca5:	6a 5a                	push   $0x5a
  jmp alltraps
80105ca7:	e9 a2 f8 ff ff       	jmp    8010554e <alltraps>

80105cac <vector91>:
.globl vector91
vector91:
  pushl $0
80105cac:	6a 00                	push   $0x0
  pushl $91
80105cae:	6a 5b                	push   $0x5b
  jmp alltraps
80105cb0:	e9 99 f8 ff ff       	jmp    8010554e <alltraps>

80105cb5 <vector92>:
.globl vector92
vector92:
  pushl $0
80105cb5:	6a 00                	push   $0x0
  pushl $92
80105cb7:	6a 5c                	push   $0x5c
  jmp alltraps
80105cb9:	e9 90 f8 ff ff       	jmp    8010554e <alltraps>

80105cbe <vector93>:
.globl vector93
vector93:
  pushl $0
80105cbe:	6a 00                	push   $0x0
  pushl $93
80105cc0:	6a 5d                	push   $0x5d
  jmp alltraps
80105cc2:	e9 87 f8 ff ff       	jmp    8010554e <alltraps>

80105cc7 <vector94>:
.globl vector94
vector94:
  pushl $0
80105cc7:	6a 00                	push   $0x0
  pushl $94
80105cc9:	6a 5e                	push   $0x5e
  jmp alltraps
80105ccb:	e9 7e f8 ff ff       	jmp    8010554e <alltraps>

80105cd0 <vector95>:
.globl vector95
vector95:
  pushl $0
80105cd0:	6a 00                	push   $0x0
  pushl $95
80105cd2:	6a 5f                	push   $0x5f
  jmp alltraps
80105cd4:	e9 75 f8 ff ff       	jmp    8010554e <alltraps>

80105cd9 <vector96>:
.globl vector96
vector96:
  pushl $0
80105cd9:	6a 00                	push   $0x0
  pushl $96
80105cdb:	6a 60                	push   $0x60
  jmp alltraps
80105cdd:	e9 6c f8 ff ff       	jmp    8010554e <alltraps>

80105ce2 <vector97>:
.globl vector97
vector97:
  pushl $0
80105ce2:	6a 00                	push   $0x0
  pushl $97
80105ce4:	6a 61                	push   $0x61
  jmp alltraps
80105ce6:	e9 63 f8 ff ff       	jmp    8010554e <alltraps>

80105ceb <vector98>:
.globl vector98
vector98:
  pushl $0
80105ceb:	6a 00                	push   $0x0
  pushl $98
80105ced:	6a 62                	push   $0x62
  jmp alltraps
80105cef:	e9 5a f8 ff ff       	jmp    8010554e <alltraps>

80105cf4 <vector99>:
.globl vector99
vector99:
  pushl $0
80105cf4:	6a 00                	push   $0x0
  pushl $99
80105cf6:	6a 63                	push   $0x63
  jmp alltraps
80105cf8:	e9 51 f8 ff ff       	jmp    8010554e <alltraps>

80105cfd <vector100>:
.globl vector100
vector100:
  pushl $0
80105cfd:	6a 00                	push   $0x0
  pushl $100
80105cff:	6a 64                	push   $0x64
  jmp alltraps
80105d01:	e9 48 f8 ff ff       	jmp    8010554e <alltraps>

80105d06 <vector101>:
.globl vector101
vector101:
  pushl $0
80105d06:	6a 00                	push   $0x0
  pushl $101
80105d08:	6a 65                	push   $0x65
  jmp alltraps
80105d0a:	e9 3f f8 ff ff       	jmp    8010554e <alltraps>

80105d0f <vector102>:
.globl vector102
vector102:
  pushl $0
80105d0f:	6a 00                	push   $0x0
  pushl $102
80105d11:	6a 66                	push   $0x66
  jmp alltraps
80105d13:	e9 36 f8 ff ff       	jmp    8010554e <alltraps>

80105d18 <vector103>:
.globl vector103
vector103:
  pushl $0
80105d18:	6a 00                	push   $0x0
  pushl $103
80105d1a:	6a 67                	push   $0x67
  jmp alltraps
80105d1c:	e9 2d f8 ff ff       	jmp    8010554e <alltraps>

80105d21 <vector104>:
.globl vector104
vector104:
  pushl $0
80105d21:	6a 00                	push   $0x0
  pushl $104
80105d23:	6a 68                	push   $0x68
  jmp alltraps
80105d25:	e9 24 f8 ff ff       	jmp    8010554e <alltraps>

80105d2a <vector105>:
.globl vector105
vector105:
  pushl $0
80105d2a:	6a 00                	push   $0x0
  pushl $105
80105d2c:	6a 69                	push   $0x69
  jmp alltraps
80105d2e:	e9 1b f8 ff ff       	jmp    8010554e <alltraps>

80105d33 <vector106>:
.globl vector106
vector106:
  pushl $0
80105d33:	6a 00                	push   $0x0
  pushl $106
80105d35:	6a 6a                	push   $0x6a
  jmp alltraps
80105d37:	e9 12 f8 ff ff       	jmp    8010554e <alltraps>

80105d3c <vector107>:
.globl vector107
vector107:
  pushl $0
80105d3c:	6a 00                	push   $0x0
  pushl $107
80105d3e:	6a 6b                	push   $0x6b
  jmp alltraps
80105d40:	e9 09 f8 ff ff       	jmp    8010554e <alltraps>

80105d45 <vector108>:
.globl vector108
vector108:
  pushl $0
80105d45:	6a 00                	push   $0x0
  pushl $108
80105d47:	6a 6c                	push   $0x6c
  jmp alltraps
80105d49:	e9 00 f8 ff ff       	jmp    8010554e <alltraps>

80105d4e <vector109>:
.globl vector109
vector109:
  pushl $0
80105d4e:	6a 00                	push   $0x0
  pushl $109
80105d50:	6a 6d                	push   $0x6d
  jmp alltraps
80105d52:	e9 f7 f7 ff ff       	jmp    8010554e <alltraps>

80105d57 <vector110>:
.globl vector110
vector110:
  pushl $0
80105d57:	6a 00                	push   $0x0
  pushl $110
80105d59:	6a 6e                	push   $0x6e
  jmp alltraps
80105d5b:	e9 ee f7 ff ff       	jmp    8010554e <alltraps>

80105d60 <vector111>:
.globl vector111
vector111:
  pushl $0
80105d60:	6a 00                	push   $0x0
  pushl $111
80105d62:	6a 6f                	push   $0x6f
  jmp alltraps
80105d64:	e9 e5 f7 ff ff       	jmp    8010554e <alltraps>

80105d69 <vector112>:
.globl vector112
vector112:
  pushl $0
80105d69:	6a 00                	push   $0x0
  pushl $112
80105d6b:	6a 70                	push   $0x70
  jmp alltraps
80105d6d:	e9 dc f7 ff ff       	jmp    8010554e <alltraps>

80105d72 <vector113>:
.globl vector113
vector113:
  pushl $0
80105d72:	6a 00                	push   $0x0
  pushl $113
80105d74:	6a 71                	push   $0x71
  jmp alltraps
80105d76:	e9 d3 f7 ff ff       	jmp    8010554e <alltraps>

80105d7b <vector114>:
.globl vector114
vector114:
  pushl $0
80105d7b:	6a 00                	push   $0x0
  pushl $114
80105d7d:	6a 72                	push   $0x72
  jmp alltraps
80105d7f:	e9 ca f7 ff ff       	jmp    8010554e <alltraps>

80105d84 <vector115>:
.globl vector115
vector115:
  pushl $0
80105d84:	6a 00                	push   $0x0
  pushl $115
80105d86:	6a 73                	push   $0x73
  jmp alltraps
80105d88:	e9 c1 f7 ff ff       	jmp    8010554e <alltraps>

80105d8d <vector116>:
.globl vector116
vector116:
  pushl $0
80105d8d:	6a 00                	push   $0x0
  pushl $116
80105d8f:	6a 74                	push   $0x74
  jmp alltraps
80105d91:	e9 b8 f7 ff ff       	jmp    8010554e <alltraps>

80105d96 <vector117>:
.globl vector117
vector117:
  pushl $0
80105d96:	6a 00                	push   $0x0
  pushl $117
80105d98:	6a 75                	push   $0x75
  jmp alltraps
80105d9a:	e9 af f7 ff ff       	jmp    8010554e <alltraps>

80105d9f <vector118>:
.globl vector118
vector118:
  pushl $0
80105d9f:	6a 00                	push   $0x0
  pushl $118
80105da1:	6a 76                	push   $0x76
  jmp alltraps
80105da3:	e9 a6 f7 ff ff       	jmp    8010554e <alltraps>

80105da8 <vector119>:
.globl vector119
vector119:
  pushl $0
80105da8:	6a 00                	push   $0x0
  pushl $119
80105daa:	6a 77                	push   $0x77
  jmp alltraps
80105dac:	e9 9d f7 ff ff       	jmp    8010554e <alltraps>

80105db1 <vector120>:
.globl vector120
vector120:
  pushl $0
80105db1:	6a 00                	push   $0x0
  pushl $120
80105db3:	6a 78                	push   $0x78
  jmp alltraps
80105db5:	e9 94 f7 ff ff       	jmp    8010554e <alltraps>

80105dba <vector121>:
.globl vector121
vector121:
  pushl $0
80105dba:	6a 00                	push   $0x0
  pushl $121
80105dbc:	6a 79                	push   $0x79
  jmp alltraps
80105dbe:	e9 8b f7 ff ff       	jmp    8010554e <alltraps>

80105dc3 <vector122>:
.globl vector122
vector122:
  pushl $0
80105dc3:	6a 00                	push   $0x0
  pushl $122
80105dc5:	6a 7a                	push   $0x7a
  jmp alltraps
80105dc7:	e9 82 f7 ff ff       	jmp    8010554e <alltraps>

80105dcc <vector123>:
.globl vector123
vector123:
  pushl $0
80105dcc:	6a 00                	push   $0x0
  pushl $123
80105dce:	6a 7b                	push   $0x7b
  jmp alltraps
80105dd0:	e9 79 f7 ff ff       	jmp    8010554e <alltraps>

80105dd5 <vector124>:
.globl vector124
vector124:
  pushl $0
80105dd5:	6a 00                	push   $0x0
  pushl $124
80105dd7:	6a 7c                	push   $0x7c
  jmp alltraps
80105dd9:	e9 70 f7 ff ff       	jmp    8010554e <alltraps>

80105dde <vector125>:
.globl vector125
vector125:
  pushl $0
80105dde:	6a 00                	push   $0x0
  pushl $125
80105de0:	6a 7d                	push   $0x7d
  jmp alltraps
80105de2:	e9 67 f7 ff ff       	jmp    8010554e <alltraps>

80105de7 <vector126>:
.globl vector126
vector126:
  pushl $0
80105de7:	6a 00                	push   $0x0
  pushl $126
80105de9:	6a 7e                	push   $0x7e
  jmp alltraps
80105deb:	e9 5e f7 ff ff       	jmp    8010554e <alltraps>

80105df0 <vector127>:
.globl vector127
vector127:
  pushl $0
80105df0:	6a 00                	push   $0x0
  pushl $127
80105df2:	6a 7f                	push   $0x7f
  jmp alltraps
80105df4:	e9 55 f7 ff ff       	jmp    8010554e <alltraps>

80105df9 <vector128>:
.globl vector128
vector128:
  pushl $0
80105df9:	6a 00                	push   $0x0
  pushl $128
80105dfb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105e00:	e9 49 f7 ff ff       	jmp    8010554e <alltraps>

80105e05 <vector129>:
.globl vector129
vector129:
  pushl $0
80105e05:	6a 00                	push   $0x0
  pushl $129
80105e07:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105e0c:	e9 3d f7 ff ff       	jmp    8010554e <alltraps>

80105e11 <vector130>:
.globl vector130
vector130:
  pushl $0
80105e11:	6a 00                	push   $0x0
  pushl $130
80105e13:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105e18:	e9 31 f7 ff ff       	jmp    8010554e <alltraps>

80105e1d <vector131>:
.globl vector131
vector131:
  pushl $0
80105e1d:	6a 00                	push   $0x0
  pushl $131
80105e1f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105e24:	e9 25 f7 ff ff       	jmp    8010554e <alltraps>

80105e29 <vector132>:
.globl vector132
vector132:
  pushl $0
80105e29:	6a 00                	push   $0x0
  pushl $132
80105e2b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105e30:	e9 19 f7 ff ff       	jmp    8010554e <alltraps>

80105e35 <vector133>:
.globl vector133
vector133:
  pushl $0
80105e35:	6a 00                	push   $0x0
  pushl $133
80105e37:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105e3c:	e9 0d f7 ff ff       	jmp    8010554e <alltraps>

80105e41 <vector134>:
.globl vector134
vector134:
  pushl $0
80105e41:	6a 00                	push   $0x0
  pushl $134
80105e43:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105e48:	e9 01 f7 ff ff       	jmp    8010554e <alltraps>

80105e4d <vector135>:
.globl vector135
vector135:
  pushl $0
80105e4d:	6a 00                	push   $0x0
  pushl $135
80105e4f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105e54:	e9 f5 f6 ff ff       	jmp    8010554e <alltraps>

80105e59 <vector136>:
.globl vector136
vector136:
  pushl $0
80105e59:	6a 00                	push   $0x0
  pushl $136
80105e5b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105e60:	e9 e9 f6 ff ff       	jmp    8010554e <alltraps>

80105e65 <vector137>:
.globl vector137
vector137:
  pushl $0
80105e65:	6a 00                	push   $0x0
  pushl $137
80105e67:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105e6c:	e9 dd f6 ff ff       	jmp    8010554e <alltraps>

80105e71 <vector138>:
.globl vector138
vector138:
  pushl $0
80105e71:	6a 00                	push   $0x0
  pushl $138
80105e73:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105e78:	e9 d1 f6 ff ff       	jmp    8010554e <alltraps>

80105e7d <vector139>:
.globl vector139
vector139:
  pushl $0
80105e7d:	6a 00                	push   $0x0
  pushl $139
80105e7f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105e84:	e9 c5 f6 ff ff       	jmp    8010554e <alltraps>

80105e89 <vector140>:
.globl vector140
vector140:
  pushl $0
80105e89:	6a 00                	push   $0x0
  pushl $140
80105e8b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105e90:	e9 b9 f6 ff ff       	jmp    8010554e <alltraps>

80105e95 <vector141>:
.globl vector141
vector141:
  pushl $0
80105e95:	6a 00                	push   $0x0
  pushl $141
80105e97:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105e9c:	e9 ad f6 ff ff       	jmp    8010554e <alltraps>

80105ea1 <vector142>:
.globl vector142
vector142:
  pushl $0
80105ea1:	6a 00                	push   $0x0
  pushl $142
80105ea3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105ea8:	e9 a1 f6 ff ff       	jmp    8010554e <alltraps>

80105ead <vector143>:
.globl vector143
vector143:
  pushl $0
80105ead:	6a 00                	push   $0x0
  pushl $143
80105eaf:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105eb4:	e9 95 f6 ff ff       	jmp    8010554e <alltraps>

80105eb9 <vector144>:
.globl vector144
vector144:
  pushl $0
80105eb9:	6a 00                	push   $0x0
  pushl $144
80105ebb:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105ec0:	e9 89 f6 ff ff       	jmp    8010554e <alltraps>

80105ec5 <vector145>:
.globl vector145
vector145:
  pushl $0
80105ec5:	6a 00                	push   $0x0
  pushl $145
80105ec7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105ecc:	e9 7d f6 ff ff       	jmp    8010554e <alltraps>

80105ed1 <vector146>:
.globl vector146
vector146:
  pushl $0
80105ed1:	6a 00                	push   $0x0
  pushl $146
80105ed3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105ed8:	e9 71 f6 ff ff       	jmp    8010554e <alltraps>

80105edd <vector147>:
.globl vector147
vector147:
  pushl $0
80105edd:	6a 00                	push   $0x0
  pushl $147
80105edf:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105ee4:	e9 65 f6 ff ff       	jmp    8010554e <alltraps>

80105ee9 <vector148>:
.globl vector148
vector148:
  pushl $0
80105ee9:	6a 00                	push   $0x0
  pushl $148
80105eeb:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105ef0:	e9 59 f6 ff ff       	jmp    8010554e <alltraps>

80105ef5 <vector149>:
.globl vector149
vector149:
  pushl $0
80105ef5:	6a 00                	push   $0x0
  pushl $149
80105ef7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105efc:	e9 4d f6 ff ff       	jmp    8010554e <alltraps>

80105f01 <vector150>:
.globl vector150
vector150:
  pushl $0
80105f01:	6a 00                	push   $0x0
  pushl $150
80105f03:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105f08:	e9 41 f6 ff ff       	jmp    8010554e <alltraps>

80105f0d <vector151>:
.globl vector151
vector151:
  pushl $0
80105f0d:	6a 00                	push   $0x0
  pushl $151
80105f0f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105f14:	e9 35 f6 ff ff       	jmp    8010554e <alltraps>

80105f19 <vector152>:
.globl vector152
vector152:
  pushl $0
80105f19:	6a 00                	push   $0x0
  pushl $152
80105f1b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105f20:	e9 29 f6 ff ff       	jmp    8010554e <alltraps>

80105f25 <vector153>:
.globl vector153
vector153:
  pushl $0
80105f25:	6a 00                	push   $0x0
  pushl $153
80105f27:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105f2c:	e9 1d f6 ff ff       	jmp    8010554e <alltraps>

80105f31 <vector154>:
.globl vector154
vector154:
  pushl $0
80105f31:	6a 00                	push   $0x0
  pushl $154
80105f33:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105f38:	e9 11 f6 ff ff       	jmp    8010554e <alltraps>

80105f3d <vector155>:
.globl vector155
vector155:
  pushl $0
80105f3d:	6a 00                	push   $0x0
  pushl $155
80105f3f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105f44:	e9 05 f6 ff ff       	jmp    8010554e <alltraps>

80105f49 <vector156>:
.globl vector156
vector156:
  pushl $0
80105f49:	6a 00                	push   $0x0
  pushl $156
80105f4b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105f50:	e9 f9 f5 ff ff       	jmp    8010554e <alltraps>

80105f55 <vector157>:
.globl vector157
vector157:
  pushl $0
80105f55:	6a 00                	push   $0x0
  pushl $157
80105f57:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105f5c:	e9 ed f5 ff ff       	jmp    8010554e <alltraps>

80105f61 <vector158>:
.globl vector158
vector158:
  pushl $0
80105f61:	6a 00                	push   $0x0
  pushl $158
80105f63:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105f68:	e9 e1 f5 ff ff       	jmp    8010554e <alltraps>

80105f6d <vector159>:
.globl vector159
vector159:
  pushl $0
80105f6d:	6a 00                	push   $0x0
  pushl $159
80105f6f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105f74:	e9 d5 f5 ff ff       	jmp    8010554e <alltraps>

80105f79 <vector160>:
.globl vector160
vector160:
  pushl $0
80105f79:	6a 00                	push   $0x0
  pushl $160
80105f7b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105f80:	e9 c9 f5 ff ff       	jmp    8010554e <alltraps>

80105f85 <vector161>:
.globl vector161
vector161:
  pushl $0
80105f85:	6a 00                	push   $0x0
  pushl $161
80105f87:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105f8c:	e9 bd f5 ff ff       	jmp    8010554e <alltraps>

80105f91 <vector162>:
.globl vector162
vector162:
  pushl $0
80105f91:	6a 00                	push   $0x0
  pushl $162
80105f93:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105f98:	e9 b1 f5 ff ff       	jmp    8010554e <alltraps>

80105f9d <vector163>:
.globl vector163
vector163:
  pushl $0
80105f9d:	6a 00                	push   $0x0
  pushl $163
80105f9f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105fa4:	e9 a5 f5 ff ff       	jmp    8010554e <alltraps>

80105fa9 <vector164>:
.globl vector164
vector164:
  pushl $0
80105fa9:	6a 00                	push   $0x0
  pushl $164
80105fab:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105fb0:	e9 99 f5 ff ff       	jmp    8010554e <alltraps>

80105fb5 <vector165>:
.globl vector165
vector165:
  pushl $0
80105fb5:	6a 00                	push   $0x0
  pushl $165
80105fb7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105fbc:	e9 8d f5 ff ff       	jmp    8010554e <alltraps>

80105fc1 <vector166>:
.globl vector166
vector166:
  pushl $0
80105fc1:	6a 00                	push   $0x0
  pushl $166
80105fc3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105fc8:	e9 81 f5 ff ff       	jmp    8010554e <alltraps>

80105fcd <vector167>:
.globl vector167
vector167:
  pushl $0
80105fcd:	6a 00                	push   $0x0
  pushl $167
80105fcf:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105fd4:	e9 75 f5 ff ff       	jmp    8010554e <alltraps>

80105fd9 <vector168>:
.globl vector168
vector168:
  pushl $0
80105fd9:	6a 00                	push   $0x0
  pushl $168
80105fdb:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105fe0:	e9 69 f5 ff ff       	jmp    8010554e <alltraps>

80105fe5 <vector169>:
.globl vector169
vector169:
  pushl $0
80105fe5:	6a 00                	push   $0x0
  pushl $169
80105fe7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105fec:	e9 5d f5 ff ff       	jmp    8010554e <alltraps>

80105ff1 <vector170>:
.globl vector170
vector170:
  pushl $0
80105ff1:	6a 00                	push   $0x0
  pushl $170
80105ff3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105ff8:	e9 51 f5 ff ff       	jmp    8010554e <alltraps>

80105ffd <vector171>:
.globl vector171
vector171:
  pushl $0
80105ffd:	6a 00                	push   $0x0
  pushl $171
80105fff:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106004:	e9 45 f5 ff ff       	jmp    8010554e <alltraps>

80106009 <vector172>:
.globl vector172
vector172:
  pushl $0
80106009:	6a 00                	push   $0x0
  pushl $172
8010600b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106010:	e9 39 f5 ff ff       	jmp    8010554e <alltraps>

80106015 <vector173>:
.globl vector173
vector173:
  pushl $0
80106015:	6a 00                	push   $0x0
  pushl $173
80106017:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010601c:	e9 2d f5 ff ff       	jmp    8010554e <alltraps>

80106021 <vector174>:
.globl vector174
vector174:
  pushl $0
80106021:	6a 00                	push   $0x0
  pushl $174
80106023:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106028:	e9 21 f5 ff ff       	jmp    8010554e <alltraps>

8010602d <vector175>:
.globl vector175
vector175:
  pushl $0
8010602d:	6a 00                	push   $0x0
  pushl $175
8010602f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106034:	e9 15 f5 ff ff       	jmp    8010554e <alltraps>

80106039 <vector176>:
.globl vector176
vector176:
  pushl $0
80106039:	6a 00                	push   $0x0
  pushl $176
8010603b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106040:	e9 09 f5 ff ff       	jmp    8010554e <alltraps>

80106045 <vector177>:
.globl vector177
vector177:
  pushl $0
80106045:	6a 00                	push   $0x0
  pushl $177
80106047:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010604c:	e9 fd f4 ff ff       	jmp    8010554e <alltraps>

80106051 <vector178>:
.globl vector178
vector178:
  pushl $0
80106051:	6a 00                	push   $0x0
  pushl $178
80106053:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106058:	e9 f1 f4 ff ff       	jmp    8010554e <alltraps>

8010605d <vector179>:
.globl vector179
vector179:
  pushl $0
8010605d:	6a 00                	push   $0x0
  pushl $179
8010605f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106064:	e9 e5 f4 ff ff       	jmp    8010554e <alltraps>

80106069 <vector180>:
.globl vector180
vector180:
  pushl $0
80106069:	6a 00                	push   $0x0
  pushl $180
8010606b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106070:	e9 d9 f4 ff ff       	jmp    8010554e <alltraps>

80106075 <vector181>:
.globl vector181
vector181:
  pushl $0
80106075:	6a 00                	push   $0x0
  pushl $181
80106077:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010607c:	e9 cd f4 ff ff       	jmp    8010554e <alltraps>

80106081 <vector182>:
.globl vector182
vector182:
  pushl $0
80106081:	6a 00                	push   $0x0
  pushl $182
80106083:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106088:	e9 c1 f4 ff ff       	jmp    8010554e <alltraps>

8010608d <vector183>:
.globl vector183
vector183:
  pushl $0
8010608d:	6a 00                	push   $0x0
  pushl $183
8010608f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106094:	e9 b5 f4 ff ff       	jmp    8010554e <alltraps>

80106099 <vector184>:
.globl vector184
vector184:
  pushl $0
80106099:	6a 00                	push   $0x0
  pushl $184
8010609b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801060a0:	e9 a9 f4 ff ff       	jmp    8010554e <alltraps>

801060a5 <vector185>:
.globl vector185
vector185:
  pushl $0
801060a5:	6a 00                	push   $0x0
  pushl $185
801060a7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801060ac:	e9 9d f4 ff ff       	jmp    8010554e <alltraps>

801060b1 <vector186>:
.globl vector186
vector186:
  pushl $0
801060b1:	6a 00                	push   $0x0
  pushl $186
801060b3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801060b8:	e9 91 f4 ff ff       	jmp    8010554e <alltraps>

801060bd <vector187>:
.globl vector187
vector187:
  pushl $0
801060bd:	6a 00                	push   $0x0
  pushl $187
801060bf:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801060c4:	e9 85 f4 ff ff       	jmp    8010554e <alltraps>

801060c9 <vector188>:
.globl vector188
vector188:
  pushl $0
801060c9:	6a 00                	push   $0x0
  pushl $188
801060cb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801060d0:	e9 79 f4 ff ff       	jmp    8010554e <alltraps>

801060d5 <vector189>:
.globl vector189
vector189:
  pushl $0
801060d5:	6a 00                	push   $0x0
  pushl $189
801060d7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801060dc:	e9 6d f4 ff ff       	jmp    8010554e <alltraps>

801060e1 <vector190>:
.globl vector190
vector190:
  pushl $0
801060e1:	6a 00                	push   $0x0
  pushl $190
801060e3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801060e8:	e9 61 f4 ff ff       	jmp    8010554e <alltraps>

801060ed <vector191>:
.globl vector191
vector191:
  pushl $0
801060ed:	6a 00                	push   $0x0
  pushl $191
801060ef:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801060f4:	e9 55 f4 ff ff       	jmp    8010554e <alltraps>

801060f9 <vector192>:
.globl vector192
vector192:
  pushl $0
801060f9:	6a 00                	push   $0x0
  pushl $192
801060fb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106100:	e9 49 f4 ff ff       	jmp    8010554e <alltraps>

80106105 <vector193>:
.globl vector193
vector193:
  pushl $0
80106105:	6a 00                	push   $0x0
  pushl $193
80106107:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010610c:	e9 3d f4 ff ff       	jmp    8010554e <alltraps>

80106111 <vector194>:
.globl vector194
vector194:
  pushl $0
80106111:	6a 00                	push   $0x0
  pushl $194
80106113:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106118:	e9 31 f4 ff ff       	jmp    8010554e <alltraps>

8010611d <vector195>:
.globl vector195
vector195:
  pushl $0
8010611d:	6a 00                	push   $0x0
  pushl $195
8010611f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106124:	e9 25 f4 ff ff       	jmp    8010554e <alltraps>

80106129 <vector196>:
.globl vector196
vector196:
  pushl $0
80106129:	6a 00                	push   $0x0
  pushl $196
8010612b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106130:	e9 19 f4 ff ff       	jmp    8010554e <alltraps>

80106135 <vector197>:
.globl vector197
vector197:
  pushl $0
80106135:	6a 00                	push   $0x0
  pushl $197
80106137:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010613c:	e9 0d f4 ff ff       	jmp    8010554e <alltraps>

80106141 <vector198>:
.globl vector198
vector198:
  pushl $0
80106141:	6a 00                	push   $0x0
  pushl $198
80106143:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106148:	e9 01 f4 ff ff       	jmp    8010554e <alltraps>

8010614d <vector199>:
.globl vector199
vector199:
  pushl $0
8010614d:	6a 00                	push   $0x0
  pushl $199
8010614f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106154:	e9 f5 f3 ff ff       	jmp    8010554e <alltraps>

80106159 <vector200>:
.globl vector200
vector200:
  pushl $0
80106159:	6a 00                	push   $0x0
  pushl $200
8010615b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106160:	e9 e9 f3 ff ff       	jmp    8010554e <alltraps>

80106165 <vector201>:
.globl vector201
vector201:
  pushl $0
80106165:	6a 00                	push   $0x0
  pushl $201
80106167:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010616c:	e9 dd f3 ff ff       	jmp    8010554e <alltraps>

80106171 <vector202>:
.globl vector202
vector202:
  pushl $0
80106171:	6a 00                	push   $0x0
  pushl $202
80106173:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106178:	e9 d1 f3 ff ff       	jmp    8010554e <alltraps>

8010617d <vector203>:
.globl vector203
vector203:
  pushl $0
8010617d:	6a 00                	push   $0x0
  pushl $203
8010617f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106184:	e9 c5 f3 ff ff       	jmp    8010554e <alltraps>

80106189 <vector204>:
.globl vector204
vector204:
  pushl $0
80106189:	6a 00                	push   $0x0
  pushl $204
8010618b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106190:	e9 b9 f3 ff ff       	jmp    8010554e <alltraps>

80106195 <vector205>:
.globl vector205
vector205:
  pushl $0
80106195:	6a 00                	push   $0x0
  pushl $205
80106197:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010619c:	e9 ad f3 ff ff       	jmp    8010554e <alltraps>

801061a1 <vector206>:
.globl vector206
vector206:
  pushl $0
801061a1:	6a 00                	push   $0x0
  pushl $206
801061a3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801061a8:	e9 a1 f3 ff ff       	jmp    8010554e <alltraps>

801061ad <vector207>:
.globl vector207
vector207:
  pushl $0
801061ad:	6a 00                	push   $0x0
  pushl $207
801061af:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801061b4:	e9 95 f3 ff ff       	jmp    8010554e <alltraps>

801061b9 <vector208>:
.globl vector208
vector208:
  pushl $0
801061b9:	6a 00                	push   $0x0
  pushl $208
801061bb:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801061c0:	e9 89 f3 ff ff       	jmp    8010554e <alltraps>

801061c5 <vector209>:
.globl vector209
vector209:
  pushl $0
801061c5:	6a 00                	push   $0x0
  pushl $209
801061c7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801061cc:	e9 7d f3 ff ff       	jmp    8010554e <alltraps>

801061d1 <vector210>:
.globl vector210
vector210:
  pushl $0
801061d1:	6a 00                	push   $0x0
  pushl $210
801061d3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801061d8:	e9 71 f3 ff ff       	jmp    8010554e <alltraps>

801061dd <vector211>:
.globl vector211
vector211:
  pushl $0
801061dd:	6a 00                	push   $0x0
  pushl $211
801061df:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801061e4:	e9 65 f3 ff ff       	jmp    8010554e <alltraps>

801061e9 <vector212>:
.globl vector212
vector212:
  pushl $0
801061e9:	6a 00                	push   $0x0
  pushl $212
801061eb:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801061f0:	e9 59 f3 ff ff       	jmp    8010554e <alltraps>

801061f5 <vector213>:
.globl vector213
vector213:
  pushl $0
801061f5:	6a 00                	push   $0x0
  pushl $213
801061f7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801061fc:	e9 4d f3 ff ff       	jmp    8010554e <alltraps>

80106201 <vector214>:
.globl vector214
vector214:
  pushl $0
80106201:	6a 00                	push   $0x0
  pushl $214
80106203:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106208:	e9 41 f3 ff ff       	jmp    8010554e <alltraps>

8010620d <vector215>:
.globl vector215
vector215:
  pushl $0
8010620d:	6a 00                	push   $0x0
  pushl $215
8010620f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106214:	e9 35 f3 ff ff       	jmp    8010554e <alltraps>

80106219 <vector216>:
.globl vector216
vector216:
  pushl $0
80106219:	6a 00                	push   $0x0
  pushl $216
8010621b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106220:	e9 29 f3 ff ff       	jmp    8010554e <alltraps>

80106225 <vector217>:
.globl vector217
vector217:
  pushl $0
80106225:	6a 00                	push   $0x0
  pushl $217
80106227:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010622c:	e9 1d f3 ff ff       	jmp    8010554e <alltraps>

80106231 <vector218>:
.globl vector218
vector218:
  pushl $0
80106231:	6a 00                	push   $0x0
  pushl $218
80106233:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106238:	e9 11 f3 ff ff       	jmp    8010554e <alltraps>

8010623d <vector219>:
.globl vector219
vector219:
  pushl $0
8010623d:	6a 00                	push   $0x0
  pushl $219
8010623f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106244:	e9 05 f3 ff ff       	jmp    8010554e <alltraps>

80106249 <vector220>:
.globl vector220
vector220:
  pushl $0
80106249:	6a 00                	push   $0x0
  pushl $220
8010624b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106250:	e9 f9 f2 ff ff       	jmp    8010554e <alltraps>

80106255 <vector221>:
.globl vector221
vector221:
  pushl $0
80106255:	6a 00                	push   $0x0
  pushl $221
80106257:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010625c:	e9 ed f2 ff ff       	jmp    8010554e <alltraps>

80106261 <vector222>:
.globl vector222
vector222:
  pushl $0
80106261:	6a 00                	push   $0x0
  pushl $222
80106263:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106268:	e9 e1 f2 ff ff       	jmp    8010554e <alltraps>

8010626d <vector223>:
.globl vector223
vector223:
  pushl $0
8010626d:	6a 00                	push   $0x0
  pushl $223
8010626f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106274:	e9 d5 f2 ff ff       	jmp    8010554e <alltraps>

80106279 <vector224>:
.globl vector224
vector224:
  pushl $0
80106279:	6a 00                	push   $0x0
  pushl $224
8010627b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106280:	e9 c9 f2 ff ff       	jmp    8010554e <alltraps>

80106285 <vector225>:
.globl vector225
vector225:
  pushl $0
80106285:	6a 00                	push   $0x0
  pushl $225
80106287:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010628c:	e9 bd f2 ff ff       	jmp    8010554e <alltraps>

80106291 <vector226>:
.globl vector226
vector226:
  pushl $0
80106291:	6a 00                	push   $0x0
  pushl $226
80106293:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106298:	e9 b1 f2 ff ff       	jmp    8010554e <alltraps>

8010629d <vector227>:
.globl vector227
vector227:
  pushl $0
8010629d:	6a 00                	push   $0x0
  pushl $227
8010629f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801062a4:	e9 a5 f2 ff ff       	jmp    8010554e <alltraps>

801062a9 <vector228>:
.globl vector228
vector228:
  pushl $0
801062a9:	6a 00                	push   $0x0
  pushl $228
801062ab:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801062b0:	e9 99 f2 ff ff       	jmp    8010554e <alltraps>

801062b5 <vector229>:
.globl vector229
vector229:
  pushl $0
801062b5:	6a 00                	push   $0x0
  pushl $229
801062b7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801062bc:	e9 8d f2 ff ff       	jmp    8010554e <alltraps>

801062c1 <vector230>:
.globl vector230
vector230:
  pushl $0
801062c1:	6a 00                	push   $0x0
  pushl $230
801062c3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801062c8:	e9 81 f2 ff ff       	jmp    8010554e <alltraps>

801062cd <vector231>:
.globl vector231
vector231:
  pushl $0
801062cd:	6a 00                	push   $0x0
  pushl $231
801062cf:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801062d4:	e9 75 f2 ff ff       	jmp    8010554e <alltraps>

801062d9 <vector232>:
.globl vector232
vector232:
  pushl $0
801062d9:	6a 00                	push   $0x0
  pushl $232
801062db:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801062e0:	e9 69 f2 ff ff       	jmp    8010554e <alltraps>

801062e5 <vector233>:
.globl vector233
vector233:
  pushl $0
801062e5:	6a 00                	push   $0x0
  pushl $233
801062e7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801062ec:	e9 5d f2 ff ff       	jmp    8010554e <alltraps>

801062f1 <vector234>:
.globl vector234
vector234:
  pushl $0
801062f1:	6a 00                	push   $0x0
  pushl $234
801062f3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801062f8:	e9 51 f2 ff ff       	jmp    8010554e <alltraps>

801062fd <vector235>:
.globl vector235
vector235:
  pushl $0
801062fd:	6a 00                	push   $0x0
  pushl $235
801062ff:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106304:	e9 45 f2 ff ff       	jmp    8010554e <alltraps>

80106309 <vector236>:
.globl vector236
vector236:
  pushl $0
80106309:	6a 00                	push   $0x0
  pushl $236
8010630b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106310:	e9 39 f2 ff ff       	jmp    8010554e <alltraps>

80106315 <vector237>:
.globl vector237
vector237:
  pushl $0
80106315:	6a 00                	push   $0x0
  pushl $237
80106317:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010631c:	e9 2d f2 ff ff       	jmp    8010554e <alltraps>

80106321 <vector238>:
.globl vector238
vector238:
  pushl $0
80106321:	6a 00                	push   $0x0
  pushl $238
80106323:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106328:	e9 21 f2 ff ff       	jmp    8010554e <alltraps>

8010632d <vector239>:
.globl vector239
vector239:
  pushl $0
8010632d:	6a 00                	push   $0x0
  pushl $239
8010632f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106334:	e9 15 f2 ff ff       	jmp    8010554e <alltraps>

80106339 <vector240>:
.globl vector240
vector240:
  pushl $0
80106339:	6a 00                	push   $0x0
  pushl $240
8010633b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106340:	e9 09 f2 ff ff       	jmp    8010554e <alltraps>

80106345 <vector241>:
.globl vector241
vector241:
  pushl $0
80106345:	6a 00                	push   $0x0
  pushl $241
80106347:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010634c:	e9 fd f1 ff ff       	jmp    8010554e <alltraps>

80106351 <vector242>:
.globl vector242
vector242:
  pushl $0
80106351:	6a 00                	push   $0x0
  pushl $242
80106353:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106358:	e9 f1 f1 ff ff       	jmp    8010554e <alltraps>

8010635d <vector243>:
.globl vector243
vector243:
  pushl $0
8010635d:	6a 00                	push   $0x0
  pushl $243
8010635f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106364:	e9 e5 f1 ff ff       	jmp    8010554e <alltraps>

80106369 <vector244>:
.globl vector244
vector244:
  pushl $0
80106369:	6a 00                	push   $0x0
  pushl $244
8010636b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106370:	e9 d9 f1 ff ff       	jmp    8010554e <alltraps>

80106375 <vector245>:
.globl vector245
vector245:
  pushl $0
80106375:	6a 00                	push   $0x0
  pushl $245
80106377:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010637c:	e9 cd f1 ff ff       	jmp    8010554e <alltraps>

80106381 <vector246>:
.globl vector246
vector246:
  pushl $0
80106381:	6a 00                	push   $0x0
  pushl $246
80106383:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106388:	e9 c1 f1 ff ff       	jmp    8010554e <alltraps>

8010638d <vector247>:
.globl vector247
vector247:
  pushl $0
8010638d:	6a 00                	push   $0x0
  pushl $247
8010638f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106394:	e9 b5 f1 ff ff       	jmp    8010554e <alltraps>

80106399 <vector248>:
.globl vector248
vector248:
  pushl $0
80106399:	6a 00                	push   $0x0
  pushl $248
8010639b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801063a0:	e9 a9 f1 ff ff       	jmp    8010554e <alltraps>

801063a5 <vector249>:
.globl vector249
vector249:
  pushl $0
801063a5:	6a 00                	push   $0x0
  pushl $249
801063a7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801063ac:	e9 9d f1 ff ff       	jmp    8010554e <alltraps>

801063b1 <vector250>:
.globl vector250
vector250:
  pushl $0
801063b1:	6a 00                	push   $0x0
  pushl $250
801063b3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801063b8:	e9 91 f1 ff ff       	jmp    8010554e <alltraps>

801063bd <vector251>:
.globl vector251
vector251:
  pushl $0
801063bd:	6a 00                	push   $0x0
  pushl $251
801063bf:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801063c4:	e9 85 f1 ff ff       	jmp    8010554e <alltraps>

801063c9 <vector252>:
.globl vector252
vector252:
  pushl $0
801063c9:	6a 00                	push   $0x0
  pushl $252
801063cb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801063d0:	e9 79 f1 ff ff       	jmp    8010554e <alltraps>

801063d5 <vector253>:
.globl vector253
vector253:
  pushl $0
801063d5:	6a 00                	push   $0x0
  pushl $253
801063d7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801063dc:	e9 6d f1 ff ff       	jmp    8010554e <alltraps>

801063e1 <vector254>:
.globl vector254
vector254:
  pushl $0
801063e1:	6a 00                	push   $0x0
  pushl $254
801063e3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801063e8:	e9 61 f1 ff ff       	jmp    8010554e <alltraps>

801063ed <vector255>:
.globl vector255
vector255:
  pushl $0
801063ed:	6a 00                	push   $0x0
  pushl $255
801063ef:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801063f4:	e9 55 f1 ff ff       	jmp    8010554e <alltraps>

801063f9 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801063f9:	55                   	push   %ebp
801063fa:	89 e5                	mov    %esp,%ebp
801063fc:	57                   	push   %edi
801063fd:	56                   	push   %esi
801063fe:	53                   	push   %ebx
801063ff:	83 ec 0c             	sub    $0xc,%esp
80106402:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106404:	c1 ea 16             	shr    $0x16,%edx
80106407:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
8010640a:	8b 1f                	mov    (%edi),%ebx
8010640c:	f6 c3 01             	test   $0x1,%bl
8010640f:	74 22                	je     80106433 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106411:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106417:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
8010641d:	c1 ee 0c             	shr    $0xc,%esi
80106420:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80106426:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80106429:	89 d8                	mov    %ebx,%eax
8010642b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010642e:	5b                   	pop    %ebx
8010642f:	5e                   	pop    %esi
80106430:	5f                   	pop    %edi
80106431:	5d                   	pop    %ebp
80106432:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106433:	85 c9                	test   %ecx,%ecx
80106435:	74 2b                	je     80106462 <walkpgdir+0x69>
80106437:	e8 7f bc ff ff       	call   801020bb <kalloc>
8010643c:	89 c3                	mov    %eax,%ebx
8010643e:	85 c0                	test   %eax,%eax
80106440:	74 e7                	je     80106429 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80106442:	83 ec 04             	sub    $0x4,%esp
80106445:	68 00 10 00 00       	push   $0x1000
8010644a:	6a 00                	push   $0x0
8010644c:	50                   	push   %eax
8010644d:	e8 8f df ff ff       	call   801043e1 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106452:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106458:	83 c8 07             	or     $0x7,%eax
8010645b:	89 07                	mov    %eax,(%edi)
8010645d:	83 c4 10             	add    $0x10,%esp
80106460:	eb bb                	jmp    8010641d <walkpgdir+0x24>
      return 0;
80106462:	bb 00 00 00 00       	mov    $0x0,%ebx
80106467:	eb c0                	jmp    80106429 <walkpgdir+0x30>

80106469 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106469:	55                   	push   %ebp
8010646a:	89 e5                	mov    %esp,%ebp
8010646c:	57                   	push   %edi
8010646d:	56                   	push   %esi
8010646e:	53                   	push   %ebx
8010646f:	83 ec 1c             	sub    $0x1c,%esp
80106472:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106475:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106478:	89 d3                	mov    %edx,%ebx
8010647a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106480:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106484:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010648a:	b9 01 00 00 00       	mov    $0x1,%ecx
8010648f:	89 da                	mov    %ebx,%edx
80106491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106494:	e8 60 ff ff ff       	call   801063f9 <walkpgdir>
80106499:	85 c0                	test   %eax,%eax
8010649b:	74 2e                	je     801064cb <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
8010649d:	f6 00 01             	testb  $0x1,(%eax)
801064a0:	75 1c                	jne    801064be <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
801064a2:	89 f2                	mov    %esi,%edx
801064a4:	0b 55 0c             	or     0xc(%ebp),%edx
801064a7:	83 ca 01             	or     $0x1,%edx
801064aa:	89 10                	mov    %edx,(%eax)
    if(a == last)
801064ac:	39 fb                	cmp    %edi,%ebx
801064ae:	74 28                	je     801064d8 <mappages+0x6f>
      break;
    a += PGSIZE;
801064b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801064b6:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801064bc:	eb cc                	jmp    8010648a <mappages+0x21>
      panic("remap");
801064be:	83 ec 0c             	sub    $0xc,%esp
801064c1:	68 98 75 10 80       	push   $0x80107598
801064c6:	e8 7d 9e ff ff       	call   80100348 <panic>
      return -1;
801064cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801064d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064d3:	5b                   	pop    %ebx
801064d4:	5e                   	pop    %esi
801064d5:	5f                   	pop    %edi
801064d6:	5d                   	pop    %ebp
801064d7:	c3                   	ret    
  return 0;
801064d8:	b8 00 00 00 00       	mov    $0x0,%eax
801064dd:	eb f1                	jmp    801064d0 <mappages+0x67>

801064df <seginit>:
{
801064df:	55                   	push   %ebp
801064e0:	89 e5                	mov    %esp,%ebp
801064e2:	53                   	push   %ebx
801064e3:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
801064e6:	e8 53 ce ff ff       	call   8010333e <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801064eb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801064f1:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
801064f8:	ff ff 
801064fa:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80106501:	00 00 
80106503:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
8010650a:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
80106511:	83 e1 f0             	and    $0xfffffff0,%ecx
80106514:	83 c9 1a             	or     $0x1a,%ecx
80106517:	83 e1 9f             	and    $0xffffff9f,%ecx
8010651a:	83 c9 80             	or     $0xffffff80,%ecx
8010651d:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
80106523:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
8010652a:	83 c9 0f             	or     $0xf,%ecx
8010652d:	83 e1 cf             	and    $0xffffffcf,%ecx
80106530:	83 c9 c0             	or     $0xffffffc0,%ecx
80106533:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
80106539:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106540:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
80106547:	ff ff 
80106549:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
80106550:	00 00 
80106552:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80106559:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
80106560:	83 e1 f0             	and    $0xfffffff0,%ecx
80106563:	83 c9 12             	or     $0x12,%ecx
80106566:	83 e1 9f             	and    $0xffffff9f,%ecx
80106569:	83 c9 80             	or     $0xffffff80,%ecx
8010656c:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80106572:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80106579:	83 c9 0f             	or     $0xf,%ecx
8010657c:	83 e1 cf             	and    $0xffffffcf,%ecx
8010657f:	83 c9 c0             	or     $0xffffffc0,%ecx
80106582:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
80106588:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010658f:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80106596:	ff ff 
80106598:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
8010659f:	00 00 
801065a1:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
801065a8:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
801065af:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
801065b6:	83 c9 0f             	or     $0xf,%ecx
801065b9:	83 e1 cf             	and    $0xffffffcf,%ecx
801065bc:	83 c9 c0             	or     $0xffffffc0,%ecx
801065bf:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
801065c5:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801065cc:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
801065d3:	ff ff 
801065d5:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
801065dc:	00 00 
801065de:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
801065e5:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
801065ec:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
801065f3:	83 c9 0f             	or     $0xf,%ecx
801065f6:	83 e1 cf             	and    $0xffffffcf,%ecx
801065f9:	83 c9 c0             	or     $0xffffffc0,%ecx
801065fc:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
80106602:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106609:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
8010660e:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106614:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106618:	c1 e8 10             	shr    $0x10,%eax
8010661b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010661f:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106622:	0f 01 10             	lgdtl  (%eax)
}
80106625:	83 c4 14             	add    $0x14,%esp
80106628:	5b                   	pop    %ebx
80106629:	5d                   	pop    %ebp
8010662a:	c3                   	ret    

8010662b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010662b:	55                   	push   %ebp
8010662c:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010662e:	a1 c4 71 11 80       	mov    0x801171c4,%eax
80106633:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106638:	0f 22 d8             	mov    %eax,%cr3
}
8010663b:	5d                   	pop    %ebp
8010663c:	c3                   	ret    

8010663d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010663d:	55                   	push   %ebp
8010663e:	89 e5                	mov    %esp,%ebp
80106640:	57                   	push   %edi
80106641:	56                   	push   %esi
80106642:	53                   	push   %ebx
80106643:	83 ec 1c             	sub    $0x1c,%esp
80106646:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106649:	85 f6                	test   %esi,%esi
8010664b:	0f 84 dd 00 00 00    	je     8010672e <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106651:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106655:	0f 84 e0 00 00 00    	je     8010673b <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010665b:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
8010665f:	0f 84 e3 00 00 00    	je     80106748 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80106665:	e8 ee db ff ff       	call   80104258 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010666a:	e8 73 cc ff ff       	call   801032e2 <mycpu>
8010666f:	89 c3                	mov    %eax,%ebx
80106671:	e8 6c cc ff ff       	call   801032e2 <mycpu>
80106676:	8d 78 08             	lea    0x8(%eax),%edi
80106679:	e8 64 cc ff ff       	call   801032e2 <mycpu>
8010667e:	83 c0 08             	add    $0x8,%eax
80106681:	c1 e8 10             	shr    $0x10,%eax
80106684:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106687:	e8 56 cc ff ff       	call   801032e2 <mycpu>
8010668c:	83 c0 08             	add    $0x8,%eax
8010668f:	c1 e8 18             	shr    $0x18,%eax
80106692:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106699:	67 00 
8010669b:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801066a2:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
801066a6:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801066ac:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
801066b3:	83 e2 f0             	and    $0xfffffff0,%edx
801066b6:	83 ca 19             	or     $0x19,%edx
801066b9:	83 e2 9f             	and    $0xffffff9f,%edx
801066bc:	83 ca 80             	or     $0xffffff80,%edx
801066bf:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801066c5:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
801066cc:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801066d2:	e8 0b cc ff ff       	call   801032e2 <mycpu>
801066d7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801066de:	83 e2 ef             	and    $0xffffffef,%edx
801066e1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801066e7:	e8 f6 cb ff ff       	call   801032e2 <mycpu>
801066ec:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801066f2:	8b 5e 08             	mov    0x8(%esi),%ebx
801066f5:	e8 e8 cb ff ff       	call   801032e2 <mycpu>
801066fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106700:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106703:	e8 da cb ff ff       	call   801032e2 <mycpu>
80106708:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010670e:	b8 28 00 00 00       	mov    $0x28,%eax
80106713:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106716:	8b 46 04             	mov    0x4(%esi),%eax
80106719:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010671e:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106721:	e8 6f db ff ff       	call   80104295 <popcli>
}
80106726:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106729:	5b                   	pop    %ebx
8010672a:	5e                   	pop    %esi
8010672b:	5f                   	pop    %edi
8010672c:	5d                   	pop    %ebp
8010672d:	c3                   	ret    
    panic("switchuvm: no process");
8010672e:	83 ec 0c             	sub    $0xc,%esp
80106731:	68 9e 75 10 80       	push   $0x8010759e
80106736:	e8 0d 9c ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010673b:	83 ec 0c             	sub    $0xc,%esp
8010673e:	68 b4 75 10 80       	push   $0x801075b4
80106743:	e8 00 9c ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106748:	83 ec 0c             	sub    $0xc,%esp
8010674b:	68 c9 75 10 80       	push   $0x801075c9
80106750:	e8 f3 9b ff ff       	call   80100348 <panic>

80106755 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106755:	55                   	push   %ebp
80106756:	89 e5                	mov    %esp,%ebp
80106758:	56                   	push   %esi
80106759:	53                   	push   %ebx
8010675a:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010675d:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106763:	77 4c                	ja     801067b1 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80106765:	e8 51 b9 ff ff       	call   801020bb <kalloc>
8010676a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010676c:	83 ec 04             	sub    $0x4,%esp
8010676f:	68 00 10 00 00       	push   $0x1000
80106774:	6a 00                	push   $0x0
80106776:	50                   	push   %eax
80106777:	e8 65 dc ff ff       	call   801043e1 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010677c:	83 c4 08             	add    $0x8,%esp
8010677f:	6a 06                	push   $0x6
80106781:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106787:	50                   	push   %eax
80106788:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010678d:	ba 00 00 00 00       	mov    $0x0,%edx
80106792:	8b 45 08             	mov    0x8(%ebp),%eax
80106795:	e8 cf fc ff ff       	call   80106469 <mappages>
  memmove(mem, init, sz);
8010679a:	83 c4 0c             	add    $0xc,%esp
8010679d:	56                   	push   %esi
8010679e:	ff 75 0c             	pushl  0xc(%ebp)
801067a1:	53                   	push   %ebx
801067a2:	e8 b5 dc ff ff       	call   8010445c <memmove>
}
801067a7:	83 c4 10             	add    $0x10,%esp
801067aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801067ad:	5b                   	pop    %ebx
801067ae:	5e                   	pop    %esi
801067af:	5d                   	pop    %ebp
801067b0:	c3                   	ret    
    panic("inituvm: more than a page");
801067b1:	83 ec 0c             	sub    $0xc,%esp
801067b4:	68 dd 75 10 80       	push   $0x801075dd
801067b9:	e8 8a 9b ff ff       	call   80100348 <panic>

801067be <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801067be:	55                   	push   %ebp
801067bf:	89 e5                	mov    %esp,%ebp
801067c1:	57                   	push   %edi
801067c2:	56                   	push   %esi
801067c3:	53                   	push   %ebx
801067c4:	83 ec 0c             	sub    $0xc,%esp
801067c7:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801067ca:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801067d1:	75 07                	jne    801067da <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801067d3:	bb 00 00 00 00       	mov    $0x0,%ebx
801067d8:	eb 3c                	jmp    80106816 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
801067da:	83 ec 0c             	sub    $0xc,%esp
801067dd:	68 98 76 10 80       	push   $0x80107698
801067e2:	e8 61 9b ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801067e7:	83 ec 0c             	sub    $0xc,%esp
801067ea:	68 f7 75 10 80       	push   $0x801075f7
801067ef:	e8 54 9b ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801067f4:	05 00 00 00 80       	add    $0x80000000,%eax
801067f9:	56                   	push   %esi
801067fa:	89 da                	mov    %ebx,%edx
801067fc:	03 55 14             	add    0x14(%ebp),%edx
801067ff:	52                   	push   %edx
80106800:	50                   	push   %eax
80106801:	ff 75 10             	pushl  0x10(%ebp)
80106804:	e8 6a af ff ff       	call   80101773 <readi>
80106809:	83 c4 10             	add    $0x10,%esp
8010680c:	39 f0                	cmp    %esi,%eax
8010680e:	75 47                	jne    80106857 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
80106810:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106816:	39 fb                	cmp    %edi,%ebx
80106818:	73 30                	jae    8010684a <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010681a:	89 da                	mov    %ebx,%edx
8010681c:	03 55 0c             	add    0xc(%ebp),%edx
8010681f:	b9 00 00 00 00       	mov    $0x0,%ecx
80106824:	8b 45 08             	mov    0x8(%ebp),%eax
80106827:	e8 cd fb ff ff       	call   801063f9 <walkpgdir>
8010682c:	85 c0                	test   %eax,%eax
8010682e:	74 b7                	je     801067e7 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
80106830:	8b 00                	mov    (%eax),%eax
80106832:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106837:	89 fe                	mov    %edi,%esi
80106839:	29 de                	sub    %ebx,%esi
8010683b:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106841:	76 b1                	jbe    801067f4 <loaduvm+0x36>
      n = PGSIZE;
80106843:	be 00 10 00 00       	mov    $0x1000,%esi
80106848:	eb aa                	jmp    801067f4 <loaduvm+0x36>
      return -1;
  }
  return 0;
8010684a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010684f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106852:	5b                   	pop    %ebx
80106853:	5e                   	pop    %esi
80106854:	5f                   	pop    %edi
80106855:	5d                   	pop    %ebp
80106856:	c3                   	ret    
      return -1;
80106857:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685c:	eb f1                	jmp    8010684f <loaduvm+0x91>

8010685e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010685e:	55                   	push   %ebp
8010685f:	89 e5                	mov    %esp,%ebp
80106861:	57                   	push   %edi
80106862:	56                   	push   %esi
80106863:	53                   	push   %ebx
80106864:	83 ec 0c             	sub    $0xc,%esp
80106867:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010686a:	39 7d 10             	cmp    %edi,0x10(%ebp)
8010686d:	73 11                	jae    80106880 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010686f:	8b 45 10             	mov    0x10(%ebp),%eax
80106872:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106878:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010687e:	eb 19                	jmp    80106899 <deallocuvm+0x3b>
    return oldsz;
80106880:	89 f8                	mov    %edi,%eax
80106882:	eb 64                	jmp    801068e8 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106884:	c1 eb 16             	shr    $0x16,%ebx
80106887:	83 c3 01             	add    $0x1,%ebx
8010688a:	c1 e3 16             	shl    $0x16,%ebx
8010688d:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106893:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106899:	39 fb                	cmp    %edi,%ebx
8010689b:	73 48                	jae    801068e5 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010689d:	b9 00 00 00 00       	mov    $0x0,%ecx
801068a2:	89 da                	mov    %ebx,%edx
801068a4:	8b 45 08             	mov    0x8(%ebp),%eax
801068a7:	e8 4d fb ff ff       	call   801063f9 <walkpgdir>
801068ac:	89 c6                	mov    %eax,%esi
    if(!pte)
801068ae:	85 c0                	test   %eax,%eax
801068b0:	74 d2                	je     80106884 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
801068b2:	8b 00                	mov    (%eax),%eax
801068b4:	a8 01                	test   $0x1,%al
801068b6:	74 db                	je     80106893 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801068b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068bd:	74 19                	je     801068d8 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
801068bf:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801068c4:	83 ec 0c             	sub    $0xc,%esp
801068c7:	50                   	push   %eax
801068c8:	e8 d7 b6 ff ff       	call   80101fa4 <kfree>
      *pte = 0;
801068cd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801068d3:	83 c4 10             	add    $0x10,%esp
801068d6:	eb bb                	jmp    80106893 <deallocuvm+0x35>
        panic("kfree");
801068d8:	83 ec 0c             	sub    $0xc,%esp
801068db:	68 06 6f 10 80       	push   $0x80106f06
801068e0:	e8 63 9a ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801068e5:	8b 45 10             	mov    0x10(%ebp),%eax
}
801068e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068eb:	5b                   	pop    %ebx
801068ec:	5e                   	pop    %esi
801068ed:	5f                   	pop    %edi
801068ee:	5d                   	pop    %ebp
801068ef:	c3                   	ret    

801068f0 <allocuvm>:
{
801068f0:	55                   	push   %ebp
801068f1:	89 e5                	mov    %esp,%ebp
801068f3:	57                   	push   %edi
801068f4:	56                   	push   %esi
801068f5:	53                   	push   %ebx
801068f6:	83 ec 1c             	sub    $0x1c,%esp
801068f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801068fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801068ff:	85 ff                	test   %edi,%edi
80106901:	0f 88 c1 00 00 00    	js     801069c8 <allocuvm+0xd8>
  if(newsz < oldsz)
80106907:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010690a:	72 5c                	jb     80106968 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
8010690c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010690f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106915:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
8010691b:	39 fb                	cmp    %edi,%ebx
8010691d:	0f 83 ac 00 00 00    	jae    801069cf <allocuvm+0xdf>
    mem = kalloc();
80106923:	e8 93 b7 ff ff       	call   801020bb <kalloc>
80106928:	89 c6                	mov    %eax,%esi
    if(mem == 0){
8010692a:	85 c0                	test   %eax,%eax
8010692c:	74 42                	je     80106970 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
8010692e:	83 ec 04             	sub    $0x4,%esp
80106931:	68 00 10 00 00       	push   $0x1000
80106936:	6a 00                	push   $0x0
80106938:	50                   	push   %eax
80106939:	e8 a3 da ff ff       	call   801043e1 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010693e:	83 c4 08             	add    $0x8,%esp
80106941:	6a 06                	push   $0x6
80106943:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106949:	50                   	push   %eax
8010694a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010694f:	89 da                	mov    %ebx,%edx
80106951:	8b 45 08             	mov    0x8(%ebp),%eax
80106954:	e8 10 fb ff ff       	call   80106469 <mappages>
80106959:	83 c4 10             	add    $0x10,%esp
8010695c:	85 c0                	test   %eax,%eax
8010695e:	78 38                	js     80106998 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
80106960:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106966:	eb b3                	jmp    8010691b <allocuvm+0x2b>
    return oldsz;
80106968:	8b 45 0c             	mov    0xc(%ebp),%eax
8010696b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010696e:	eb 5f                	jmp    801069cf <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
80106970:	83 ec 0c             	sub    $0xc,%esp
80106973:	68 15 76 10 80       	push   $0x80107615
80106978:	e8 8e 9c ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010697d:	83 c4 0c             	add    $0xc,%esp
80106980:	ff 75 0c             	pushl  0xc(%ebp)
80106983:	57                   	push   %edi
80106984:	ff 75 08             	pushl  0x8(%ebp)
80106987:	e8 d2 fe ff ff       	call   8010685e <deallocuvm>
      return 0;
8010698c:	83 c4 10             	add    $0x10,%esp
8010698f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106996:	eb 37                	jmp    801069cf <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106998:	83 ec 0c             	sub    $0xc,%esp
8010699b:	68 2d 76 10 80       	push   $0x8010762d
801069a0:	e8 66 9c ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801069a5:	83 c4 0c             	add    $0xc,%esp
801069a8:	ff 75 0c             	pushl  0xc(%ebp)
801069ab:	57                   	push   %edi
801069ac:	ff 75 08             	pushl  0x8(%ebp)
801069af:	e8 aa fe ff ff       	call   8010685e <deallocuvm>
      kfree(mem);
801069b4:	89 34 24             	mov    %esi,(%esp)
801069b7:	e8 e8 b5 ff ff       	call   80101fa4 <kfree>
      return 0;
801069bc:	83 c4 10             	add    $0x10,%esp
801069bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801069c6:	eb 07                	jmp    801069cf <allocuvm+0xdf>
    return 0;
801069c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801069cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801069d5:	5b                   	pop    %ebx
801069d6:	5e                   	pop    %esi
801069d7:	5f                   	pop    %edi
801069d8:	5d                   	pop    %ebp
801069d9:	c3                   	ret    

801069da <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801069da:	55                   	push   %ebp
801069db:	89 e5                	mov    %esp,%ebp
801069dd:	56                   	push   %esi
801069de:	53                   	push   %ebx
801069df:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801069e2:	85 f6                	test   %esi,%esi
801069e4:	74 1a                	je     80106a00 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801069e6:	83 ec 04             	sub    $0x4,%esp
801069e9:	6a 00                	push   $0x0
801069eb:	68 00 00 00 80       	push   $0x80000000
801069f0:	56                   	push   %esi
801069f1:	e8 68 fe ff ff       	call   8010685e <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801069f6:	83 c4 10             	add    $0x10,%esp
801069f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801069fe:	eb 10                	jmp    80106a10 <freevm+0x36>
    panic("freevm: no pgdir");
80106a00:	83 ec 0c             	sub    $0xc,%esp
80106a03:	68 49 76 10 80       	push   $0x80107649
80106a08:	e8 3b 99 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106a0d:	83 c3 01             	add    $0x1,%ebx
80106a10:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106a16:	77 1f                	ja     80106a37 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106a18:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106a1b:	a8 01                	test   $0x1,%al
80106a1d:	74 ee                	je     80106a0d <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106a1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106a24:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106a29:	83 ec 0c             	sub    $0xc,%esp
80106a2c:	50                   	push   %eax
80106a2d:	e8 72 b5 ff ff       	call   80101fa4 <kfree>
80106a32:	83 c4 10             	add    $0x10,%esp
80106a35:	eb d6                	jmp    80106a0d <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106a37:	83 ec 0c             	sub    $0xc,%esp
80106a3a:	56                   	push   %esi
80106a3b:	e8 64 b5 ff ff       	call   80101fa4 <kfree>
}
80106a40:	83 c4 10             	add    $0x10,%esp
80106a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106a46:	5b                   	pop    %ebx
80106a47:	5e                   	pop    %esi
80106a48:	5d                   	pop    %ebp
80106a49:	c3                   	ret    

80106a4a <setupkvm>:
{
80106a4a:	55                   	push   %ebp
80106a4b:	89 e5                	mov    %esp,%ebp
80106a4d:	56                   	push   %esi
80106a4e:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106a4f:	e8 67 b6 ff ff       	call   801020bb <kalloc>
80106a54:	89 c6                	mov    %eax,%esi
80106a56:	85 c0                	test   %eax,%eax
80106a58:	74 55                	je     80106aaf <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106a5a:	83 ec 04             	sub    $0x4,%esp
80106a5d:	68 00 10 00 00       	push   $0x1000
80106a62:	6a 00                	push   $0x0
80106a64:	50                   	push   %eax
80106a65:	e8 77 d9 ff ff       	call   801043e1 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106a6a:	83 c4 10             	add    $0x10,%esp
80106a6d:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106a72:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106a78:	73 35                	jae    80106aaf <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106a7a:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106a7d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106a80:	29 c1                	sub    %eax,%ecx
80106a82:	83 ec 08             	sub    $0x8,%esp
80106a85:	ff 73 0c             	pushl  0xc(%ebx)
80106a88:	50                   	push   %eax
80106a89:	8b 13                	mov    (%ebx),%edx
80106a8b:	89 f0                	mov    %esi,%eax
80106a8d:	e8 d7 f9 ff ff       	call   80106469 <mappages>
80106a92:	83 c4 10             	add    $0x10,%esp
80106a95:	85 c0                	test   %eax,%eax
80106a97:	78 05                	js     80106a9e <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106a99:	83 c3 10             	add    $0x10,%ebx
80106a9c:	eb d4                	jmp    80106a72 <setupkvm+0x28>
      freevm(pgdir);
80106a9e:	83 ec 0c             	sub    $0xc,%esp
80106aa1:	56                   	push   %esi
80106aa2:	e8 33 ff ff ff       	call   801069da <freevm>
      return 0;
80106aa7:	83 c4 10             	add    $0x10,%esp
80106aaa:	be 00 00 00 00       	mov    $0x0,%esi
}
80106aaf:	89 f0                	mov    %esi,%eax
80106ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106ab4:	5b                   	pop    %ebx
80106ab5:	5e                   	pop    %esi
80106ab6:	5d                   	pop    %ebp
80106ab7:	c3                   	ret    

80106ab8 <kvmalloc>:
{
80106ab8:	55                   	push   %ebp
80106ab9:	89 e5                	mov    %esp,%ebp
80106abb:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106abe:	e8 87 ff ff ff       	call   80106a4a <setupkvm>
80106ac3:	a3 c4 71 11 80       	mov    %eax,0x801171c4
  switchkvm();
80106ac8:	e8 5e fb ff ff       	call   8010662b <switchkvm>
}
80106acd:	c9                   	leave  
80106ace:	c3                   	ret    

80106acf <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106acf:	55                   	push   %ebp
80106ad0:	89 e5                	mov    %esp,%ebp
80106ad2:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106ad5:	b9 00 00 00 00       	mov    $0x0,%ecx
80106ada:	8b 55 0c             	mov    0xc(%ebp),%edx
80106add:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae0:	e8 14 f9 ff ff       	call   801063f9 <walkpgdir>
  if(pte == 0)
80106ae5:	85 c0                	test   %eax,%eax
80106ae7:	74 05                	je     80106aee <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106ae9:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106aec:	c9                   	leave  
80106aed:	c3                   	ret    
    panic("clearpteu");
80106aee:	83 ec 0c             	sub    $0xc,%esp
80106af1:	68 5a 76 10 80       	push   $0x8010765a
80106af6:	e8 4d 98 ff ff       	call   80100348 <panic>

80106afb <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106afb:	55                   	push   %ebp
80106afc:	89 e5                	mov    %esp,%ebp
80106afe:	57                   	push   %edi
80106aff:	56                   	push   %esi
80106b00:	53                   	push   %ebx
80106b01:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106b04:	e8 41 ff ff ff       	call   80106a4a <setupkvm>
80106b09:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106b0c:	85 c0                	test   %eax,%eax
80106b0e:	0f 84 c4 00 00 00    	je     80106bd8 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106b14:	bf 00 00 00 00       	mov    $0x0,%edi
80106b19:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106b1c:	0f 83 b6 00 00 00    	jae    80106bd8 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106b22:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106b25:	b9 00 00 00 00       	mov    $0x0,%ecx
80106b2a:	89 fa                	mov    %edi,%edx
80106b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2f:	e8 c5 f8 ff ff       	call   801063f9 <walkpgdir>
80106b34:	85 c0                	test   %eax,%eax
80106b36:	74 65                	je     80106b9d <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106b38:	8b 00                	mov    (%eax),%eax
80106b3a:	a8 01                	test   $0x1,%al
80106b3c:	74 6c                	je     80106baa <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106b3e:	89 c6                	mov    %eax,%esi
80106b40:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106b46:	25 ff 0f 00 00       	and    $0xfff,%eax
80106b4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106b4e:	e8 68 b5 ff ff       	call   801020bb <kalloc>
80106b53:	89 c3                	mov    %eax,%ebx
80106b55:	85 c0                	test   %eax,%eax
80106b57:	74 6a                	je     80106bc3 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106b59:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106b5f:	83 ec 04             	sub    $0x4,%esp
80106b62:	68 00 10 00 00       	push   $0x1000
80106b67:	56                   	push   %esi
80106b68:	50                   	push   %eax
80106b69:	e8 ee d8 ff ff       	call   8010445c <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106b6e:	83 c4 08             	add    $0x8,%esp
80106b71:	ff 75 e0             	pushl  -0x20(%ebp)
80106b74:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106b7a:	50                   	push   %eax
80106b7b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106b80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106b83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b86:	e8 de f8 ff ff       	call   80106469 <mappages>
80106b8b:	83 c4 10             	add    $0x10,%esp
80106b8e:	85 c0                	test   %eax,%eax
80106b90:	78 25                	js     80106bb7 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106b92:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106b98:	e9 7c ff ff ff       	jmp    80106b19 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106b9d:	83 ec 0c             	sub    $0xc,%esp
80106ba0:	68 64 76 10 80       	push   $0x80107664
80106ba5:	e8 9e 97 ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106baa:	83 ec 0c             	sub    $0xc,%esp
80106bad:	68 7e 76 10 80       	push   $0x8010767e
80106bb2:	e8 91 97 ff ff       	call   80100348 <panic>
      kfree(mem);
80106bb7:	83 ec 0c             	sub    $0xc,%esp
80106bba:	53                   	push   %ebx
80106bbb:	e8 e4 b3 ff ff       	call   80101fa4 <kfree>
      goto bad;
80106bc0:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106bc3:	83 ec 0c             	sub    $0xc,%esp
80106bc6:	ff 75 dc             	pushl  -0x24(%ebp)
80106bc9:	e8 0c fe ff ff       	call   801069da <freevm>
  return 0;
80106bce:	83 c4 10             	add    $0x10,%esp
80106bd1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106bd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bde:	5b                   	pop    %ebx
80106bdf:	5e                   	pop    %esi
80106be0:	5f                   	pop    %edi
80106be1:	5d                   	pop    %ebp
80106be2:	c3                   	ret    

80106be3 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106be3:	55                   	push   %ebp
80106be4:	89 e5                	mov    %esp,%ebp
80106be6:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106be9:	b9 00 00 00 00       	mov    $0x0,%ecx
80106bee:	8b 55 0c             	mov    0xc(%ebp),%edx
80106bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf4:	e8 00 f8 ff ff       	call   801063f9 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106bf9:	8b 00                	mov    (%eax),%eax
80106bfb:	a8 01                	test   $0x1,%al
80106bfd:	74 10                	je     80106c0f <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106bff:	a8 04                	test   $0x4,%al
80106c01:	74 13                	je     80106c16 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106c03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c08:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106c0d:	c9                   	leave  
80106c0e:	c3                   	ret    
    return 0;
80106c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80106c14:	eb f7                	jmp    80106c0d <uva2ka+0x2a>
    return 0;
80106c16:	b8 00 00 00 00       	mov    $0x0,%eax
80106c1b:	eb f0                	jmp    80106c0d <uva2ka+0x2a>

80106c1d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106c1d:	55                   	push   %ebp
80106c1e:	89 e5                	mov    %esp,%ebp
80106c20:	57                   	push   %edi
80106c21:	56                   	push   %esi
80106c22:	53                   	push   %ebx
80106c23:	83 ec 0c             	sub    $0xc,%esp
80106c26:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106c29:	eb 25                	jmp    80106c50 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106c2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c2e:	29 f2                	sub    %esi,%edx
80106c30:	01 d0                	add    %edx,%eax
80106c32:	83 ec 04             	sub    $0x4,%esp
80106c35:	53                   	push   %ebx
80106c36:	ff 75 10             	pushl  0x10(%ebp)
80106c39:	50                   	push   %eax
80106c3a:	e8 1d d8 ff ff       	call   8010445c <memmove>
    len -= n;
80106c3f:	29 df                	sub    %ebx,%edi
    buf += n;
80106c41:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106c44:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106c4a:	89 45 0c             	mov    %eax,0xc(%ebp)
80106c4d:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106c50:	85 ff                	test   %edi,%edi
80106c52:	74 2f                	je     80106c83 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106c54:	8b 75 0c             	mov    0xc(%ebp),%esi
80106c57:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106c5d:	83 ec 08             	sub    $0x8,%esp
80106c60:	56                   	push   %esi
80106c61:	ff 75 08             	pushl  0x8(%ebp)
80106c64:	e8 7a ff ff ff       	call   80106be3 <uva2ka>
    if(pa0 == 0)
80106c69:	83 c4 10             	add    $0x10,%esp
80106c6c:	85 c0                	test   %eax,%eax
80106c6e:	74 20                	je     80106c90 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106c70:	89 f3                	mov    %esi,%ebx
80106c72:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106c75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106c7b:	39 df                	cmp    %ebx,%edi
80106c7d:	73 ac                	jae    80106c2b <copyout+0xe>
      n = len;
80106c7f:	89 fb                	mov    %edi,%ebx
80106c81:	eb a8                	jmp    80106c2b <copyout+0xe>
  }
  return 0;
80106c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c8b:	5b                   	pop    %ebx
80106c8c:	5e                   	pop    %esi
80106c8d:	5f                   	pop    %edi
80106c8e:	5d                   	pop    %ebp
80106c8f:	c3                   	ret    
      return -1;
80106c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c95:	eb f1                	jmp    80106c88 <copyout+0x6b>
