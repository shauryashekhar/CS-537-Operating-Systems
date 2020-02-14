
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
8010002d:	b8 b5 2b 10 80       	mov    $0x80102bb5,%eax
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
80100046:	e8 02 3d 00 00       	call   80103d4d <acquire>

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
8010007c:	e8 31 3d 00 00       	call   80103db2 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 ad 3a 00 00       	call   80103b39 <acquiresleep>
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
801000ca:	e8 e3 3c 00 00       	call   80103db2 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 5f 3a 00 00       	call   80103b39 <acquiresleep>
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
801000ea:	68 60 66 10 80       	push   $0x80106660
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 71 66 10 80       	push   $0x80106671
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 07 3b 00 00       	call   80103c11 <initlock>
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
8010013a:	68 78 66 10 80       	push   $0x80106678
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 be 39 00 00       	call   80103b06 <initsleeplock>
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
801001a8:	e8 16 3a 00 00       	call   80103bc3 <holdingsleep>
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
801001cb:	68 7f 66 10 80       	push   $0x8010667f
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
801001e4:	e8 da 39 00 00       	call   80103bc3 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 8f 39 00 00       	call   80103b88 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 48 3b 00 00       	call   80103d4d <acquire>
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
8010024c:	e8 61 3b 00 00       	call   80103db2 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 86 66 10 80       	push   $0x80106686
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
8010028a:	e8 be 3a 00 00       	call   80103d4d <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 9b 30 00 00       	call   80103347 <myproc>
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
801002bf:	e8 27 35 00 00       	call   801037eb <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 dc 3a 00 00       	call   80103db2 <release>
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
80100331:	e8 7c 3a 00 00       	call   80103db2 <release>
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
8010035a:	e8 70 21 00 00       	call   801024cf <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 66 10 80       	push   $0x8010668d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 db 6f 10 80 	movl   $0x80106fdb,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 98 38 00 00       	call   80103c2c <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 a1 66 10 80       	push   $0x801066a1
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
8010049e:	68 a5 66 10 80       	push   $0x801066a5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 b5 39 00 00       	call   80103e74 <memmove>
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
801004d9:	e8 1b 39 00 00       	call   80103df9 <memset>
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
80100506:	e8 2f 4d 00 00       	call   8010523a <uartputc>
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
8010051f:	e8 16 4d 00 00       	call   8010523a <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 0a 4d 00 00       	call   8010523a <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 fe 4c 00 00       	call   8010523a <uartputc>
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
80100576:	0f b6 92 d0 66 10 80 	movzbl -0x7fef9930(%edx),%edx
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
801005ca:	e8 7e 37 00 00       	call   80103d4d <acquire>
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
801005f1:	e8 bc 37 00 00       	call   80103db2 <release>
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
80100638:	e8 10 37 00 00       	call   80103d4d <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 bf 66 10 80       	push   $0x801066bf
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
801006ee:	be b8 66 10 80       	mov    $0x801066b8,%esi
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
80100734:	e8 79 36 00 00       	call   80103db2 <release>
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
8010074f:	e8 f9 35 00 00       	call   80103d4d <acquire>
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
801007de:	e8 6d 31 00 00       	call   80103950 <wakeup>
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
80100873:	e8 3a 35 00 00       	call   80103db2 <release>
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
80100887:	e8 61 31 00 00       	call   801039ed <procdump>
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
80100894:	68 c8 66 10 80       	push   $0x801066c8
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 6e 33 00 00       	call   80103c11 <initlock>

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
801008de:	e8 64 2a 00 00       	call   80103347 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 11 20 00 00       	call   801028ff <begin_op>

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
80100935:	e8 3f 20 00 00       	call   80102979 <end_op>
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
8010094a:	e8 2a 20 00 00       	call   80102979 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e1 66 10 80       	push   $0x801066e1
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
80100972:	e8 83 5a 00 00       	call   801063fa <setupkvm>
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
80100a06:	e8 95 58 00 00       	call   801062a0 <allocuvm>
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
80100a38:	e8 31 57 00 00       	call   8010616e <loaduvm>
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
80100a53:	e8 21 1f 00 00       	call   80102979 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 27 58 00 00       	call   801062a0 <allocuvm>
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
80100a9d:	e8 e8 58 00 00       	call   8010638a <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 be 59 00 00       	call   8010647f <clearpteu>
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
80100ae2:	e8 b4 34 00 00       	call   80103f9b <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 a2 34 00 00       	call   80103f9b <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 c2 5a 00 00       	call   801065cd <copyout>
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
80100b66:	e8 62 5a 00 00       	call   801065cd <copyout>
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
80100ba3:	e8 b8 33 00 00       	call   80103f60 <safestrcpy>
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
80100bd1:	e8 17 54 00 00       	call   80105fed <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 ac 57 00 00       	call   8010638a <freevm>
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
80100c19:	68 ed 66 10 80       	push   $0x801066ed
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 e9 2f 00 00       	call   80103c11 <initlock>
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
80100c39:	e8 0f 31 00 00       	call   80103d4d <acquire>
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
80100c68:	e8 45 31 00 00       	call   80103db2 <release>
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
80100c7f:	e8 2e 31 00 00       	call   80103db2 <release>
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
80100c9d:	e8 ab 30 00 00       	call   80103d4d <acquire>
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
80100cba:	e8 f3 30 00 00       	call   80103db2 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 f4 66 10 80       	push   $0x801066f4
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
80100ce2:	e8 66 30 00 00       	call   80103d4d <acquire>
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
80100d03:	e8 aa 30 00 00       	call   80103db2 <release>
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
80100d13:	68 fc 66 10 80       	push   $0x801066fc
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
80100d49:	e8 64 30 00 00       	call   80103db2 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 9c 1b 00 00       	call   801028ff <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 06 1c 00 00       	call   80102979 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 eb 21 00 00       	call   80102f73 <pipeclose>
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
80100e3c:	e8 8a 22 00 00       	call   801030cb <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 06 67 10 80       	push   $0x80106706
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
80100e95:	e8 65 21 00 00       	call   80102fff <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 58 1a 00 00       	call   801028ff <begin_op>
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
80100edd:	e8 97 1a 00 00       	call   80102979 <end_op>

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
80100f10:	68 0f 67 10 80       	push   $0x8010670f
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
80100f2d:	68 15 67 10 80       	push   $0x80106715
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
80100f8a:	e8 e5 2e 00 00       	call   80103e74 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 d5 2e 00 00       	call   80103e74 <memmove>
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
80100fdf:	e8 15 2e 00 00       	call   80103df9 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 3c 1a 00 00       	call   80102a28 <log_write>
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
801010a3:	68 1f 67 10 80       	push   $0x8010671f
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
801010bf:	e8 64 19 00 00       	call   80102a28 <log_write>
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
80101170:	e8 b3 18 00 00       	call   80102a28 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 35 67 10 80       	push   $0x80106735
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
8010119a:	e8 ae 2b 00 00       	call   80103d4d <acquire>
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
801011e1:	e8 cc 2b 00 00       	call   80103db2 <release>
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
80101217:	e8 96 2b 00 00       	call   80103db2 <release>
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
8010122c:	68 48 67 10 80       	push   $0x80106748
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
80101255:	e8 1a 2c 00 00       	call   80103e74 <memmove>
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
801012c8:	e8 5b 17 00 00       	call   80102a28 <log_write>
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
801012e2:	68 58 67 10 80       	push   $0x80106758
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 6b 67 10 80       	push   $0x8010676b
801012f8:	68 e0 09 11 80       	push   $0x801109e0
801012fd:	e8 0f 29 00 00       	call   80103c11 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 72 67 10 80       	push   $0x80106772
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101321:	50                   	push   %eax
80101322:	e8 df 27 00 00       	call   80103b06 <initsleeplock>
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
8010136c:	68 d8 67 10 80       	push   $0x801067d8
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
801013df:	68 78 67 10 80       	push   $0x80106778
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 03 2a 00 00       	call   80103df9 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 23 16 00 00       	call   80102a28 <log_write>
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
80101480:	e8 ef 29 00 00       	call   80103e74 <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 9b 15 00 00       	call   80102a28 <log_write>
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
80101560:	e8 e8 27 00 00       	call   80103d4d <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101575:	e8 38 28 00 00       	call   80103db2 <release>
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
8010159a:	e8 9a 25 00 00       	call   80103b39 <acquiresleep>
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
801015b2:	68 8a 67 10 80       	push   $0x8010678a
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
80101614:	e8 5b 28 00 00       	call   80103e74 <memmove>
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
80101639:	68 90 67 10 80       	push   $0x80106790
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
80101656:	e8 68 25 00 00       	call   80103bc3 <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 17 25 00 00       	call   80103b88 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 9f 67 10 80       	push   $0x8010679f
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
80101698:	e8 9c 24 00 00       	call   80103b39 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 d2 24 00 00       	call   80103b88 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016bd:	e8 8b 26 00 00       	call   80103d4d <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d2:	e8 db 26 00 00       	call   80103db2 <release>
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
801016ea:	e8 5e 26 00 00       	call   80103d4d <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016f9:	e8 b4 26 00 00       	call   80103db2 <release>
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
8010182a:	e8 45 26 00 00       	call   80103e74 <memmove>
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
80101926:	e8 49 25 00 00       	call   80103e74 <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 f5 10 00 00       	call   80102a28 <log_write>
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
801019a9:	e8 2d 25 00 00       	call   80103edb <strncmp>
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
801019d0:	68 a7 67 10 80       	push   $0x801067a7
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 b9 67 10 80       	push   $0x801067b9
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
80101a5a:	e8 e8 18 00 00       	call   80103347 <myproc>
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
80101b92:	68 c8 67 10 80       	push   $0x801067c8
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 6a 23 00 00       	call   80103f18 <strncpy>
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
80101bd7:	68 d4 6d 10 80       	push   $0x80106dd4
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
80101ccc:	68 2b 68 10 80       	push   $0x8010682b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 34 68 10 80       	push   $0x80106834
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
80101d06:	68 46 68 10 80       	push   $0x80106846
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 fc 1e 00 00       	call   80103c11 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 20 eb 1b 80       	mov    0x801beb20,%eax
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
80101d80:	e8 c8 1f 00 00       	call   80103d4d <acquire>

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
80101dad:	e8 9e 1b 00 00       	call   80103950 <wakeup>

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
80101dcb:	e8 e2 1f 00 00       	call   80103db2 <release>
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
80101de2:	e8 cb 1f 00 00       	call   80103db2 <release>
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
80101e1a:	e8 a4 1d 00 00       	call   80103bc3 <holdingsleep>
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
80101e47:	e8 01 1f 00 00       	call   80103d4d <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 4a 68 10 80       	push   $0x8010684a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 60 68 10 80       	push   $0x80106860
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 75 68 10 80       	push   $0x80106875
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
80101ea9:	e8 3d 19 00 00       	call   801037eb <sleep>
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
80101ec3:	e8 ea 1e 00 00       	call   80103db2 <release>
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
80101f2a:	0f b6 15 80 e5 1b 80 	movzbl 0x801be580,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 94 68 10 80       	push   $0x80106894
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
80101fb6:	81 fb c8 12 1c 80    	cmp    $0x801c12c8,%ebx
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
80101fd6:	e8 1e 1e 00 00       	call   80103df9 <memset>
      }
      //cprintf("Frame Freed: %d \n", i);
      numframes--;
  }*/

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
80102005:	68 c6 68 10 80       	push   $0x801068c6
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 40 26 11 80       	push   $0x80112640
80102017:	e8 31 1d 00 00       	call   80103d4d <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 40 26 11 80       	push   $0x80112640
80102029:	e8 84 1d 00 00       	call   80103db2 <release>
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
8010206f:	68 cc 68 10 80       	push   $0x801068cc
80102074:	68 40 26 11 80       	push   $0x80112640
80102079:	e8 93 1b 00 00       	call   80103c11 <initlock>
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
801020c9:	75 4e                	jne    80102119 <kalloc+0x5e>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020cb:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
801020d1:	85 db                	test   %ebx,%ebx
801020d3:	74 09                	je     801020de <kalloc+0x23>
    kmem.freelist = r->next->next;
801020d5:	8b 03                	mov    (%ebx),%eax
801020d7:	8b 00                	mov    (%eax),%eax
801020d9:	a3 78 26 11 80       	mov    %eax,0x80112678
  
  char* ptr = (char*)r;
  //cprintf("Allocated: %x \t %x \t %x \n", PHYSTOP - V2P(ptr), PHYSTOP - (V2P(ptr) >> 12 ), (V2P(ptr) >> 12 & 0xffff));
  
  numframes++;
801020de:	a1 00 80 10 80       	mov    0x80108000,%eax
801020e3:	83 c0 01             	add    $0x1,%eax
801020e6:	a3 00 80 10 80       	mov    %eax,0x80108000
  frames[numframes] = (V2P(ptr) >> 12 & 0xffff);
801020eb:	8d 93 00 00 00 80    	lea    -0x80000000(%ebx),%edx
801020f1:	c1 ea 0c             	shr    $0xc,%edx
801020f4:	0f b7 d2             	movzwl %dx,%edx
801020f7:	89 14 85 80 ea 1a 80 	mov    %edx,-0x7fe51580(,%eax,4)
  pid[numframes] = -2;
801020fe:	c7 04 85 80 26 11 80 	movl   $0xfffffffe,-0x7feed980(,%eax,4)
80102105:	fe ff ff ff 

  //cprintf("ALLOCATED: Numframes: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
  //cprintf("0. %x %d \n", frames[0], pid[0]);
  //cprintf("64. %x %d \n", frames[64], pid[64]);
  if(kmem.use_lock)
80102109:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102110:	75 19                	jne    8010212b <kalloc+0x70>
    release(&kmem.lock);
  return (char*)r;
}
80102112:	89 d8                	mov    %ebx,%eax
80102114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102117:	c9                   	leave  
80102118:	c3                   	ret    
    acquire(&kmem.lock);
80102119:	83 ec 0c             	sub    $0xc,%esp
8010211c:	68 40 26 11 80       	push   $0x80112640
80102121:	e8 27 1c 00 00       	call   80103d4d <acquire>
80102126:	83 c4 10             	add    $0x10,%esp
80102129:	eb a0                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
8010212b:	83 ec 0c             	sub    $0xc,%esp
8010212e:	68 40 26 11 80       	push   $0x80112640
80102133:	e8 7a 1c 00 00       	call   80103db2 <release>
80102138:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010213b:	eb d5                	jmp    80102112 <kalloc+0x57>

8010213d <kalloc2>:

char*
kalloc2(int processPid)
{
8010213d:	55                   	push   %ebp
8010213e:	89 e5                	mov    %esp,%ebp
80102140:	57                   	push   %edi
80102141:	56                   	push   %esi
80102142:	53                   	push   %ebx
80102143:	83 ec 1c             	sub    $0x1c,%esp
  struct run *r, *head;
  head = kmem.freelist;
80102146:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx

  if(kmem.use_lock)
8010214c:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102153:	75 62                	jne    801021b7 <kalloc2+0x7a>
     acquire(&kmem.lock);
  int firstPass = 1;
80102155:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
8010215c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  
  repeat: 
  if(firstPass) {
8010215f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80102163:	74 64                	je     801021c9 <kalloc2+0x8c>
    r = kmem.freelist;
80102165:	8b 35 78 26 11 80    	mov    0x80112678,%esi
    firstPass = 0;
8010216b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  } else {
    r = r->next;
  }

  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
80102172:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80102178:	c1 e8 0c             	shr    $0xc,%eax
8010217b:	0f b7 d8             	movzwl %ax,%ebx
 
  int i;
  for(i = 0; i<numframes; i++) {
8010217e:	bf 00 00 00 00       	mov    $0x0,%edi
80102183:	8b 0d 00 80 10 80    	mov    0x80108000,%ecx
80102189:	39 f9                	cmp    %edi,%ecx
8010218b:	7e 19                	jle    801021a6 <kalloc2+0x69>
     if(frames[i] == (frameNumberFound - 1)) {
8010218d:	8b 04 bd 80 ea 1a 80 	mov    -0x7fe51580(,%edi,4),%eax
80102194:	8d 53 ff             	lea    -0x1(%ebx),%edx
80102197:	39 d0                	cmp    %edx,%eax
80102199:	74 32                	je     801021cd <kalloc2+0x90>
          if(pid[i] != processPid) {
             goto repeat;
	  }		  
     }
     if(frames[i] == (frameNumberFound + 1)) {
8010219b:	8d 53 01             	lea    0x1(%ebx),%edx
8010219e:	39 d0                	cmp    %edx,%eax
801021a0:	74 39                	je     801021db <kalloc2+0x9e>
         if(pid[i] != processPid) {
            goto repeat;
	 }
     }
     if(frames[i] > (frameNumberFound)) {
801021a2:	39 d8                	cmp    %ebx,%eax
801021a4:	7f 46                	jg     801021ec <kalloc2+0xaf>
801021a6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
         continue;
     }
     break;
  }
  
  numframes++;
801021a9:	83 c1 01             	add    $0x1,%ecx
801021ac:	89 0d 00 80 10 80    	mov    %ecx,0x80108000
  for(int z = i+1; z<numframes; z++) {
801021b2:	8d 47 01             	lea    0x1(%edi),%eax
801021b5:	eb 5c                	jmp    80102213 <kalloc2+0xd6>
     acquire(&kmem.lock);
801021b7:	83 ec 0c             	sub    $0xc,%esp
801021ba:	68 40 26 11 80       	push   $0x80112640
801021bf:	e8 89 1b 00 00       	call   80103d4d <acquire>
801021c4:	83 c4 10             	add    $0x10,%esp
801021c7:	eb 8c                	jmp    80102155 <kalloc2+0x18>
    r = r->next;
801021c9:	8b 36                	mov    (%esi),%esi
801021cb:	eb a5                	jmp    80102172 <kalloc2+0x35>
          if(pid[i] != processPid) {
801021cd:	8b 55 08             	mov    0x8(%ebp),%edx
801021d0:	39 14 bd 80 26 11 80 	cmp    %edx,-0x7feed980(,%edi,4)
801021d7:	74 c2                	je     8010219b <kalloc2+0x5e>
  repeat: 
801021d9:	eb 84                	jmp    8010215f <kalloc2+0x22>
         if(pid[i] != processPid) {
801021db:	8b 55 08             	mov    0x8(%ebp),%edx
801021de:	39 14 bd 80 26 11 80 	cmp    %edx,-0x7feed980(,%edi,4)
801021e5:	74 bb                	je     801021a2 <kalloc2+0x65>
  repeat: 
801021e7:	e9 73 ff ff ff       	jmp    8010215f <kalloc2+0x22>
  for(i = 0; i<numframes; i++) {
801021ec:	83 c7 01             	add    $0x1,%edi
801021ef:	eb 92                	jmp    80102183 <kalloc2+0x46>
     frames[z] = frames[z-1];
801021f1:	8d 50 ff             	lea    -0x1(%eax),%edx
801021f4:	8b 1c 95 80 ea 1a 80 	mov    -0x7fe51580(,%edx,4),%ebx
801021fb:	89 1c 85 80 ea 1a 80 	mov    %ebx,-0x7fe51580(,%eax,4)
     pid[z] = pid[z-1];
80102202:	8b 14 95 80 26 11 80 	mov    -0x7feed980(,%edx,4),%edx
80102209:	89 14 85 80 26 11 80 	mov    %edx,-0x7feed980(,%eax,4)
  for(int z = i+1; z<numframes; z++) {
80102210:	83 c0 01             	add    $0x1,%eax
80102213:	39 c1                	cmp    %eax,%ecx
80102215:	7f da                	jg     801021f1 <kalloc2+0xb4>
80102217:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  }
  frames[i] = frameNumberFound;
8010221a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010221d:	89 04 bd 80 ea 1a 80 	mov    %eax,-0x7fe51580(,%edi,4)
  pid[i] = processPid;
80102224:	8b 45 08             	mov    0x8(%ebp),%eax
80102227:	89 04 bd 80 26 11 80 	mov    %eax,-0x7feed980(,%edi,4)

  while(head->next != r) {
8010222e:	eb 02                	jmp    80102232 <kalloc2+0xf5>
      head = head->next;
80102230:	89 c3                	mov    %eax,%ebx
  while(head->next != r) {
80102232:	8b 03                	mov    (%ebx),%eax
80102234:	39 f0                	cmp    %esi,%eax
80102236:	75 f8                	jne    80102230 <kalloc2+0xf3>
  }
  head->next = r->next;
80102238:	8b 06                	mov    (%esi),%eax
8010223a:	89 03                	mov    %eax,(%ebx)

  if(!kmem.use_lock)
8010223c:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102243:	74 0a                	je     8010224f <kalloc2+0x112>
     release(&kmem.lock);
  return (char*)r;
}
80102245:	89 f0                	mov    %esi,%eax
80102247:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010224a:	5b                   	pop    %ebx
8010224b:	5e                   	pop    %esi
8010224c:	5f                   	pop    %edi
8010224d:	5d                   	pop    %ebp
8010224e:	c3                   	ret    
     release(&kmem.lock);
8010224f:	83 ec 0c             	sub    $0xc,%esp
80102252:	68 40 26 11 80       	push   $0x80112640
80102257:	e8 56 1b 00 00       	call   80103db2 <release>
8010225c:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010225f:	eb e4                	jmp    80102245 <kalloc2+0x108>

80102261 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102261:	55                   	push   %ebp
80102262:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102264:	ba 64 00 00 00       	mov    $0x64,%edx
80102269:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010226a:	a8 01                	test   $0x1,%al
8010226c:	0f 84 b5 00 00 00    	je     80102327 <kbdgetc+0xc6>
80102272:	ba 60 00 00 00       	mov    $0x60,%edx
80102277:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102278:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010227b:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102281:	74 5c                	je     801022df <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102283:	84 c0                	test   %al,%al
80102285:	78 66                	js     801022ed <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102287:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010228d:	f6 c1 40             	test   $0x40,%cl
80102290:	74 0f                	je     801022a1 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102292:	83 c8 80             	or     $0xffffff80,%eax
80102295:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102298:	83 e1 bf             	and    $0xffffffbf,%ecx
8010229b:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
801022a1:	0f b6 8a 00 6a 10 80 	movzbl -0x7fef9600(%edx),%ecx
801022a8:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
801022ae:	0f b6 82 00 69 10 80 	movzbl -0x7fef9700(%edx),%eax
801022b5:	31 c1                	xor    %eax,%ecx
801022b7:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801022bd:	89 c8                	mov    %ecx,%eax
801022bf:	83 e0 03             	and    $0x3,%eax
801022c2:	8b 04 85 e0 68 10 80 	mov    -0x7fef9720(,%eax,4),%eax
801022c9:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801022cd:	f6 c1 08             	test   $0x8,%cl
801022d0:	74 19                	je     801022eb <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801022d2:	8d 50 9f             	lea    -0x61(%eax),%edx
801022d5:	83 fa 19             	cmp    $0x19,%edx
801022d8:	77 40                	ja     8010231a <kbdgetc+0xb9>
      c += 'A' - 'a';
801022da:	83 e8 20             	sub    $0x20,%eax
801022dd:	eb 0c                	jmp    801022eb <kbdgetc+0x8a>
    shift |= E0ESC;
801022df:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
801022e6:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801022eb:	5d                   	pop    %ebp
801022ec:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801022ed:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801022f3:	f6 c1 40             	test   $0x40,%cl
801022f6:	75 05                	jne    801022fd <kbdgetc+0x9c>
801022f8:	89 c2                	mov    %eax,%edx
801022fa:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801022fd:	0f b6 82 00 6a 10 80 	movzbl -0x7fef9600(%edx),%eax
80102304:	83 c8 40             	or     $0x40,%eax
80102307:	0f b6 c0             	movzbl %al,%eax
8010230a:	f7 d0                	not    %eax
8010230c:	21 c8                	and    %ecx,%eax
8010230e:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
80102313:	b8 00 00 00 00       	mov    $0x0,%eax
80102318:	eb d1                	jmp    801022eb <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010231a:	8d 50 bf             	lea    -0x41(%eax),%edx
8010231d:	83 fa 19             	cmp    $0x19,%edx
80102320:	77 c9                	ja     801022eb <kbdgetc+0x8a>
      c += 'a' - 'A';
80102322:	83 c0 20             	add    $0x20,%eax
  return c;
80102325:	eb c4                	jmp    801022eb <kbdgetc+0x8a>
    return -1;
80102327:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010232c:	eb bd                	jmp    801022eb <kbdgetc+0x8a>

8010232e <kbdintr>:

void
kbdintr(void)
{
8010232e:	55                   	push   %ebp
8010232f:	89 e5                	mov    %esp,%ebp
80102331:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102334:	68 61 22 10 80       	push   $0x80102261
80102339:	e8 00 e4 ff ff       	call   8010073e <consoleintr>
}
8010233e:	83 c4 10             	add    $0x10,%esp
80102341:	c9                   	leave  
80102342:	c3                   	ret    

80102343 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102343:	55                   	push   %ebp
80102344:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102346:	8b 0d 80 e4 1b 80    	mov    0x801be480,%ecx
8010234c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
8010234f:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102351:	a1 80 e4 1b 80       	mov    0x801be480,%eax
80102356:	8b 40 20             	mov    0x20(%eax),%eax
}
80102359:	5d                   	pop    %ebp
8010235a:	c3                   	ret    

8010235b <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010235b:	55                   	push   %ebp
8010235c:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010235e:	ba 70 00 00 00       	mov    $0x70,%edx
80102363:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102364:	ba 71 00 00 00       	mov    $0x71,%edx
80102369:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010236a:	0f b6 c0             	movzbl %al,%eax
}
8010236d:	5d                   	pop    %ebp
8010236e:	c3                   	ret    

8010236f <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010236f:	55                   	push   %ebp
80102370:	89 e5                	mov    %esp,%ebp
80102372:	53                   	push   %ebx
80102373:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102375:	b8 00 00 00 00       	mov    $0x0,%eax
8010237a:	e8 dc ff ff ff       	call   8010235b <cmos_read>
8010237f:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102381:	b8 02 00 00 00       	mov    $0x2,%eax
80102386:	e8 d0 ff ff ff       	call   8010235b <cmos_read>
8010238b:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010238e:	b8 04 00 00 00       	mov    $0x4,%eax
80102393:	e8 c3 ff ff ff       	call   8010235b <cmos_read>
80102398:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010239b:	b8 07 00 00 00       	mov    $0x7,%eax
801023a0:	e8 b6 ff ff ff       	call   8010235b <cmos_read>
801023a5:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801023a8:	b8 08 00 00 00       	mov    $0x8,%eax
801023ad:	e8 a9 ff ff ff       	call   8010235b <cmos_read>
801023b2:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801023b5:	b8 09 00 00 00       	mov    $0x9,%eax
801023ba:	e8 9c ff ff ff       	call   8010235b <cmos_read>
801023bf:	89 43 14             	mov    %eax,0x14(%ebx)
}
801023c2:	5b                   	pop    %ebx
801023c3:	5d                   	pop    %ebp
801023c4:	c3                   	ret    

801023c5 <lapicinit>:
  if(!lapic)
801023c5:	83 3d 80 e4 1b 80 00 	cmpl   $0x0,0x801be480
801023cc:	0f 84 fb 00 00 00    	je     801024cd <lapicinit+0x108>
{
801023d2:	55                   	push   %ebp
801023d3:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801023d5:	ba 3f 01 00 00       	mov    $0x13f,%edx
801023da:	b8 3c 00 00 00       	mov    $0x3c,%eax
801023df:	e8 5f ff ff ff       	call   80102343 <lapicw>
  lapicw(TDCR, X1);
801023e4:	ba 0b 00 00 00       	mov    $0xb,%edx
801023e9:	b8 f8 00 00 00       	mov    $0xf8,%eax
801023ee:	e8 50 ff ff ff       	call   80102343 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801023f3:	ba 20 00 02 00       	mov    $0x20020,%edx
801023f8:	b8 c8 00 00 00       	mov    $0xc8,%eax
801023fd:	e8 41 ff ff ff       	call   80102343 <lapicw>
  lapicw(TICR, 10000000);
80102402:	ba 80 96 98 00       	mov    $0x989680,%edx
80102407:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010240c:	e8 32 ff ff ff       	call   80102343 <lapicw>
  lapicw(LINT0, MASKED);
80102411:	ba 00 00 01 00       	mov    $0x10000,%edx
80102416:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010241b:	e8 23 ff ff ff       	call   80102343 <lapicw>
  lapicw(LINT1, MASKED);
80102420:	ba 00 00 01 00       	mov    $0x10000,%edx
80102425:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010242a:	e8 14 ff ff ff       	call   80102343 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010242f:	a1 80 e4 1b 80       	mov    0x801be480,%eax
80102434:	8b 40 30             	mov    0x30(%eax),%eax
80102437:	c1 e8 10             	shr    $0x10,%eax
8010243a:	3c 03                	cmp    $0x3,%al
8010243c:	77 7b                	ja     801024b9 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010243e:	ba 33 00 00 00       	mov    $0x33,%edx
80102443:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102448:	e8 f6 fe ff ff       	call   80102343 <lapicw>
  lapicw(ESR, 0);
8010244d:	ba 00 00 00 00       	mov    $0x0,%edx
80102452:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102457:	e8 e7 fe ff ff       	call   80102343 <lapicw>
  lapicw(ESR, 0);
8010245c:	ba 00 00 00 00       	mov    $0x0,%edx
80102461:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102466:	e8 d8 fe ff ff       	call   80102343 <lapicw>
  lapicw(EOI, 0);
8010246b:	ba 00 00 00 00       	mov    $0x0,%edx
80102470:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102475:	e8 c9 fe ff ff       	call   80102343 <lapicw>
  lapicw(ICRHI, 0);
8010247a:	ba 00 00 00 00       	mov    $0x0,%edx
8010247f:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102484:	e8 ba fe ff ff       	call   80102343 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102489:	ba 00 85 08 00       	mov    $0x88500,%edx
8010248e:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102493:	e8 ab fe ff ff       	call   80102343 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102498:	a1 80 e4 1b 80       	mov    0x801be480,%eax
8010249d:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801024a3:	f6 c4 10             	test   $0x10,%ah
801024a6:	75 f0                	jne    80102498 <lapicinit+0xd3>
  lapicw(TPR, 0);
801024a8:	ba 00 00 00 00       	mov    $0x0,%edx
801024ad:	b8 20 00 00 00       	mov    $0x20,%eax
801024b2:	e8 8c fe ff ff       	call   80102343 <lapicw>
}
801024b7:	5d                   	pop    %ebp
801024b8:	c3                   	ret    
    lapicw(PCINT, MASKED);
801024b9:	ba 00 00 01 00       	mov    $0x10000,%edx
801024be:	b8 d0 00 00 00       	mov    $0xd0,%eax
801024c3:	e8 7b fe ff ff       	call   80102343 <lapicw>
801024c8:	e9 71 ff ff ff       	jmp    8010243e <lapicinit+0x79>
801024cd:	f3 c3                	repz ret 

801024cf <lapicid>:
{
801024cf:	55                   	push   %ebp
801024d0:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801024d2:	a1 80 e4 1b 80       	mov    0x801be480,%eax
801024d7:	85 c0                	test   %eax,%eax
801024d9:	74 08                	je     801024e3 <lapicid+0x14>
  return lapic[ID] >> 24;
801024db:	8b 40 20             	mov    0x20(%eax),%eax
801024de:	c1 e8 18             	shr    $0x18,%eax
}
801024e1:	5d                   	pop    %ebp
801024e2:	c3                   	ret    
    return 0;
801024e3:	b8 00 00 00 00       	mov    $0x0,%eax
801024e8:	eb f7                	jmp    801024e1 <lapicid+0x12>

801024ea <lapiceoi>:
  if(lapic)
801024ea:	83 3d 80 e4 1b 80 00 	cmpl   $0x0,0x801be480
801024f1:	74 14                	je     80102507 <lapiceoi+0x1d>
{
801024f3:	55                   	push   %ebp
801024f4:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801024f6:	ba 00 00 00 00       	mov    $0x0,%edx
801024fb:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102500:	e8 3e fe ff ff       	call   80102343 <lapicw>
}
80102505:	5d                   	pop    %ebp
80102506:	c3                   	ret    
80102507:	f3 c3                	repz ret 

80102509 <microdelay>:
{
80102509:	55                   	push   %ebp
8010250a:	89 e5                	mov    %esp,%ebp
}
8010250c:	5d                   	pop    %ebp
8010250d:	c3                   	ret    

8010250e <lapicstartap>:
{
8010250e:	55                   	push   %ebp
8010250f:	89 e5                	mov    %esp,%ebp
80102511:	57                   	push   %edi
80102512:	56                   	push   %esi
80102513:	53                   	push   %ebx
80102514:	8b 75 08             	mov    0x8(%ebp),%esi
80102517:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251a:	b8 0f 00 00 00       	mov    $0xf,%eax
8010251f:	ba 70 00 00 00       	mov    $0x70,%edx
80102524:	ee                   	out    %al,(%dx)
80102525:	b8 0a 00 00 00       	mov    $0xa,%eax
8010252a:	ba 71 00 00 00       	mov    $0x71,%edx
8010252f:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102530:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102537:	00 00 
  wrv[1] = addr >> 4;
80102539:	89 f8                	mov    %edi,%eax
8010253b:	c1 e8 04             	shr    $0x4,%eax
8010253e:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102544:	c1 e6 18             	shl    $0x18,%esi
80102547:	89 f2                	mov    %esi,%edx
80102549:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010254e:	e8 f0 fd ff ff       	call   80102343 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102553:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102558:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010255d:	e8 e1 fd ff ff       	call   80102343 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102562:	ba 00 85 00 00       	mov    $0x8500,%edx
80102567:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010256c:	e8 d2 fd ff ff       	call   80102343 <lapicw>
  for(i = 0; i < 2; i++){
80102571:	bb 00 00 00 00       	mov    $0x0,%ebx
80102576:	eb 21                	jmp    80102599 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102578:	89 f2                	mov    %esi,%edx
8010257a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010257f:	e8 bf fd ff ff       	call   80102343 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102584:	89 fa                	mov    %edi,%edx
80102586:	c1 ea 0c             	shr    $0xc,%edx
80102589:	80 ce 06             	or     $0x6,%dh
8010258c:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102591:	e8 ad fd ff ff       	call   80102343 <lapicw>
  for(i = 0; i < 2; i++){
80102596:	83 c3 01             	add    $0x1,%ebx
80102599:	83 fb 01             	cmp    $0x1,%ebx
8010259c:	7e da                	jle    80102578 <lapicstartap+0x6a>
}
8010259e:	5b                   	pop    %ebx
8010259f:	5e                   	pop    %esi
801025a0:	5f                   	pop    %edi
801025a1:	5d                   	pop    %ebp
801025a2:	c3                   	ret    

801025a3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801025a3:	55                   	push   %ebp
801025a4:	89 e5                	mov    %esp,%ebp
801025a6:	57                   	push   %edi
801025a7:	56                   	push   %esi
801025a8:	53                   	push   %ebx
801025a9:	83 ec 3c             	sub    $0x3c,%esp
801025ac:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801025af:	b8 0b 00 00 00       	mov    $0xb,%eax
801025b4:	e8 a2 fd ff ff       	call   8010235b <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801025b9:	83 e0 04             	and    $0x4,%eax
801025bc:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801025be:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025c1:	e8 a9 fd ff ff       	call   8010236f <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801025c6:	b8 0a 00 00 00       	mov    $0xa,%eax
801025cb:	e8 8b fd ff ff       	call   8010235b <cmos_read>
801025d0:	a8 80                	test   $0x80,%al
801025d2:	75 ea                	jne    801025be <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801025d4:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801025d7:	89 d8                	mov    %ebx,%eax
801025d9:	e8 91 fd ff ff       	call   8010236f <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801025de:	83 ec 04             	sub    $0x4,%esp
801025e1:	6a 18                	push   $0x18
801025e3:	53                   	push   %ebx
801025e4:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025e7:	50                   	push   %eax
801025e8:	e8 52 18 00 00       	call   80103e3f <memcmp>
801025ed:	83 c4 10             	add    $0x10,%esp
801025f0:	85 c0                	test   %eax,%eax
801025f2:	75 ca                	jne    801025be <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801025f4:	85 ff                	test   %edi,%edi
801025f6:	0f 85 84 00 00 00    	jne    80102680 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801025fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
801025ff:	89 d0                	mov    %edx,%eax
80102601:	c1 e8 04             	shr    $0x4,%eax
80102604:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102607:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010260a:	83 e2 0f             	and    $0xf,%edx
8010260d:	01 d0                	add    %edx,%eax
8010260f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102612:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102615:	89 d0                	mov    %edx,%eax
80102617:	c1 e8 04             	shr    $0x4,%eax
8010261a:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010261d:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102620:	83 e2 0f             	and    $0xf,%edx
80102623:	01 d0                	add    %edx,%eax
80102625:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102628:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010262b:	89 d0                	mov    %edx,%eax
8010262d:	c1 e8 04             	shr    $0x4,%eax
80102630:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102633:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102636:	83 e2 0f             	and    $0xf,%edx
80102639:	01 d0                	add    %edx,%eax
8010263b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
8010263e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102641:	89 d0                	mov    %edx,%eax
80102643:	c1 e8 04             	shr    $0x4,%eax
80102646:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102649:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010264c:	83 e2 0f             	and    $0xf,%edx
8010264f:	01 d0                	add    %edx,%eax
80102651:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102654:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102657:	89 d0                	mov    %edx,%eax
80102659:	c1 e8 04             	shr    $0x4,%eax
8010265c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010265f:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102662:	83 e2 0f             	and    $0xf,%edx
80102665:	01 d0                	add    %edx,%eax
80102667:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010266a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010266d:	89 d0                	mov    %edx,%eax
8010266f:	c1 e8 04             	shr    $0x4,%eax
80102672:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102675:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102678:	83 e2 0f             	and    $0xf,%edx
8010267b:	01 d0                	add    %edx,%eax
8010267d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102680:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102683:	89 06                	mov    %eax,(%esi)
80102685:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102688:	89 46 04             	mov    %eax,0x4(%esi)
8010268b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010268e:	89 46 08             	mov    %eax,0x8(%esi)
80102691:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102694:	89 46 0c             	mov    %eax,0xc(%esi)
80102697:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010269a:	89 46 10             	mov    %eax,0x10(%esi)
8010269d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801026a0:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801026a3:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801026aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026ad:	5b                   	pop    %ebx
801026ae:	5e                   	pop    %esi
801026af:	5f                   	pop    %edi
801026b0:	5d                   	pop    %ebp
801026b1:	c3                   	ret    

801026b2 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801026b2:	55                   	push   %ebp
801026b3:	89 e5                	mov    %esp,%ebp
801026b5:	53                   	push   %ebx
801026b6:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801026b9:	ff 35 d4 e4 1b 80    	pushl  0x801be4d4
801026bf:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801026c5:	e8 a2 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801026ca:	8b 58 5c             	mov    0x5c(%eax),%ebx
801026cd:	89 1d e8 e4 1b 80    	mov    %ebx,0x801be4e8
  for (i = 0; i < log.lh.n; i++) {
801026d3:	83 c4 10             	add    $0x10,%esp
801026d6:	ba 00 00 00 00       	mov    $0x0,%edx
801026db:	eb 0e                	jmp    801026eb <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801026dd:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801026e1:	89 0c 95 ec e4 1b 80 	mov    %ecx,-0x7fe41b14(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801026e8:	83 c2 01             	add    $0x1,%edx
801026eb:	39 d3                	cmp    %edx,%ebx
801026ed:	7f ee                	jg     801026dd <read_head+0x2b>
  }
  brelse(buf);
801026ef:	83 ec 0c             	sub    $0xc,%esp
801026f2:	50                   	push   %eax
801026f3:	e8 dd da ff ff       	call   801001d5 <brelse>
}
801026f8:	83 c4 10             	add    $0x10,%esp
801026fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026fe:	c9                   	leave  
801026ff:	c3                   	ret    

80102700 <install_trans>:
{
80102700:	55                   	push   %ebp
80102701:	89 e5                	mov    %esp,%ebp
80102703:	57                   	push   %edi
80102704:	56                   	push   %esi
80102705:	53                   	push   %ebx
80102706:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102709:	bb 00 00 00 00       	mov    $0x0,%ebx
8010270e:	eb 66                	jmp    80102776 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102710:	89 d8                	mov    %ebx,%eax
80102712:	03 05 d4 e4 1b 80    	add    0x801be4d4,%eax
80102718:	83 c0 01             	add    $0x1,%eax
8010271b:	83 ec 08             	sub    $0x8,%esp
8010271e:	50                   	push   %eax
8010271f:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
80102725:	e8 42 da ff ff       	call   8010016c <bread>
8010272a:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010272c:	83 c4 08             	add    $0x8,%esp
8010272f:	ff 34 9d ec e4 1b 80 	pushl  -0x7fe41b14(,%ebx,4)
80102736:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
8010273c:	e8 2b da ff ff       	call   8010016c <bread>
80102741:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102743:	8d 57 5c             	lea    0x5c(%edi),%edx
80102746:	8d 40 5c             	lea    0x5c(%eax),%eax
80102749:	83 c4 0c             	add    $0xc,%esp
8010274c:	68 00 02 00 00       	push   $0x200
80102751:	52                   	push   %edx
80102752:	50                   	push   %eax
80102753:	e8 1c 17 00 00       	call   80103e74 <memmove>
    bwrite(dbuf);  // write dst to disk
80102758:	89 34 24             	mov    %esi,(%esp)
8010275b:	e8 3a da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102760:	89 3c 24             	mov    %edi,(%esp)
80102763:	e8 6d da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102768:	89 34 24             	mov    %esi,(%esp)
8010276b:	e8 65 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102770:	83 c3 01             	add    $0x1,%ebx
80102773:	83 c4 10             	add    $0x10,%esp
80102776:	39 1d e8 e4 1b 80    	cmp    %ebx,0x801be4e8
8010277c:	7f 92                	jg     80102710 <install_trans+0x10>
}
8010277e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102781:	5b                   	pop    %ebx
80102782:	5e                   	pop    %esi
80102783:	5f                   	pop    %edi
80102784:	5d                   	pop    %ebp
80102785:	c3                   	ret    

80102786 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102786:	55                   	push   %ebp
80102787:	89 e5                	mov    %esp,%ebp
80102789:	53                   	push   %ebx
8010278a:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010278d:	ff 35 d4 e4 1b 80    	pushl  0x801be4d4
80102793:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
80102799:	e8 ce d9 ff ff       	call   8010016c <bread>
8010279e:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801027a0:	8b 0d e8 e4 1b 80    	mov    0x801be4e8,%ecx
801027a6:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801027a9:	83 c4 10             	add    $0x10,%esp
801027ac:	b8 00 00 00 00       	mov    $0x0,%eax
801027b1:	eb 0e                	jmp    801027c1 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801027b3:	8b 14 85 ec e4 1b 80 	mov    -0x7fe41b14(,%eax,4),%edx
801027ba:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801027be:	83 c0 01             	add    $0x1,%eax
801027c1:	39 c1                	cmp    %eax,%ecx
801027c3:	7f ee                	jg     801027b3 <write_head+0x2d>
  }
  bwrite(buf);
801027c5:	83 ec 0c             	sub    $0xc,%esp
801027c8:	53                   	push   %ebx
801027c9:	e8 cc d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
801027ce:	89 1c 24             	mov    %ebx,(%esp)
801027d1:	e8 ff d9 ff ff       	call   801001d5 <brelse>
}
801027d6:	83 c4 10             	add    $0x10,%esp
801027d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027dc:	c9                   	leave  
801027dd:	c3                   	ret    

801027de <recover_from_log>:

static void
recover_from_log(void)
{
801027de:	55                   	push   %ebp
801027df:	89 e5                	mov    %esp,%ebp
801027e1:	83 ec 08             	sub    $0x8,%esp
  read_head();
801027e4:	e8 c9 fe ff ff       	call   801026b2 <read_head>
  install_trans(); // if committed, copy from log to disk
801027e9:	e8 12 ff ff ff       	call   80102700 <install_trans>
  log.lh.n = 0;
801027ee:	c7 05 e8 e4 1b 80 00 	movl   $0x0,0x801be4e8
801027f5:	00 00 00 
  write_head(); // clear the log
801027f8:	e8 89 ff ff ff       	call   80102786 <write_head>
}
801027fd:	c9                   	leave  
801027fe:	c3                   	ret    

801027ff <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801027ff:	55                   	push   %ebp
80102800:	89 e5                	mov    %esp,%ebp
80102802:	57                   	push   %edi
80102803:	56                   	push   %esi
80102804:	53                   	push   %ebx
80102805:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102808:	bb 00 00 00 00       	mov    $0x0,%ebx
8010280d:	eb 66                	jmp    80102875 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010280f:	89 d8                	mov    %ebx,%eax
80102811:	03 05 d4 e4 1b 80    	add    0x801be4d4,%eax
80102817:	83 c0 01             	add    $0x1,%eax
8010281a:	83 ec 08             	sub    $0x8,%esp
8010281d:	50                   	push   %eax
8010281e:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
80102824:	e8 43 d9 ff ff       	call   8010016c <bread>
80102829:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010282b:	83 c4 08             	add    $0x8,%esp
8010282e:	ff 34 9d ec e4 1b 80 	pushl  -0x7fe41b14(,%ebx,4)
80102835:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
8010283b:	e8 2c d9 ff ff       	call   8010016c <bread>
80102840:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102842:	8d 50 5c             	lea    0x5c(%eax),%edx
80102845:	8d 46 5c             	lea    0x5c(%esi),%eax
80102848:	83 c4 0c             	add    $0xc,%esp
8010284b:	68 00 02 00 00       	push   $0x200
80102850:	52                   	push   %edx
80102851:	50                   	push   %eax
80102852:	e8 1d 16 00 00       	call   80103e74 <memmove>
    bwrite(to);  // write the log
80102857:	89 34 24             	mov    %esi,(%esp)
8010285a:	e8 3b d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
8010285f:	89 3c 24             	mov    %edi,(%esp)
80102862:	e8 6e d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
80102867:	89 34 24             	mov    %esi,(%esp)
8010286a:	e8 66 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010286f:	83 c3 01             	add    $0x1,%ebx
80102872:	83 c4 10             	add    $0x10,%esp
80102875:	39 1d e8 e4 1b 80    	cmp    %ebx,0x801be4e8
8010287b:	7f 92                	jg     8010280f <write_log+0x10>
  }
}
8010287d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102880:	5b                   	pop    %ebx
80102881:	5e                   	pop    %esi
80102882:	5f                   	pop    %edi
80102883:	5d                   	pop    %ebp
80102884:	c3                   	ret    

80102885 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102885:	83 3d e8 e4 1b 80 00 	cmpl   $0x0,0x801be4e8
8010288c:	7e 26                	jle    801028b4 <commit+0x2f>
{
8010288e:	55                   	push   %ebp
8010288f:	89 e5                	mov    %esp,%ebp
80102891:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102894:	e8 66 ff ff ff       	call   801027ff <write_log>
    write_head();    // Write header to disk -- the real commit
80102899:	e8 e8 fe ff ff       	call   80102786 <write_head>
    install_trans(); // Now install writes to home locations
8010289e:	e8 5d fe ff ff       	call   80102700 <install_trans>
    log.lh.n = 0;
801028a3:	c7 05 e8 e4 1b 80 00 	movl   $0x0,0x801be4e8
801028aa:	00 00 00 
    write_head();    // Erase the transaction from the log
801028ad:	e8 d4 fe ff ff       	call   80102786 <write_head>
  }
}
801028b2:	c9                   	leave  
801028b3:	c3                   	ret    
801028b4:	f3 c3                	repz ret 

801028b6 <initlog>:
{
801028b6:	55                   	push   %ebp
801028b7:	89 e5                	mov    %esp,%ebp
801028b9:	53                   	push   %ebx
801028ba:	83 ec 2c             	sub    $0x2c,%esp
801028bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801028c0:	68 00 6b 10 80       	push   $0x80106b00
801028c5:	68 a0 e4 1b 80       	push   $0x801be4a0
801028ca:	e8 42 13 00 00       	call   80103c11 <initlock>
  readsb(dev, &sb);
801028cf:	83 c4 08             	add    $0x8,%esp
801028d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801028d5:	50                   	push   %eax
801028d6:	53                   	push   %ebx
801028d7:	e8 5a e9 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
801028dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028df:	a3 d4 e4 1b 80       	mov    %eax,0x801be4d4
  log.size = sb.nlog;
801028e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028e7:	a3 d8 e4 1b 80       	mov    %eax,0x801be4d8
  log.dev = dev;
801028ec:	89 1d e4 e4 1b 80    	mov    %ebx,0x801be4e4
  recover_from_log();
801028f2:	e8 e7 fe ff ff       	call   801027de <recover_from_log>
}
801028f7:	83 c4 10             	add    $0x10,%esp
801028fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028fd:	c9                   	leave  
801028fe:	c3                   	ret    

801028ff <begin_op>:
{
801028ff:	55                   	push   %ebp
80102900:	89 e5                	mov    %esp,%ebp
80102902:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102905:	68 a0 e4 1b 80       	push   $0x801be4a0
8010290a:	e8 3e 14 00 00       	call   80103d4d <acquire>
8010290f:	83 c4 10             	add    $0x10,%esp
80102912:	eb 15                	jmp    80102929 <begin_op+0x2a>
      sleep(&log, &log.lock);
80102914:	83 ec 08             	sub    $0x8,%esp
80102917:	68 a0 e4 1b 80       	push   $0x801be4a0
8010291c:	68 a0 e4 1b 80       	push   $0x801be4a0
80102921:	e8 c5 0e 00 00       	call   801037eb <sleep>
80102926:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102929:	83 3d e0 e4 1b 80 00 	cmpl   $0x0,0x801be4e0
80102930:	75 e2                	jne    80102914 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102932:	a1 dc e4 1b 80       	mov    0x801be4dc,%eax
80102937:	83 c0 01             	add    $0x1,%eax
8010293a:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010293d:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102940:	03 15 e8 e4 1b 80    	add    0x801be4e8,%edx
80102946:	83 fa 1e             	cmp    $0x1e,%edx
80102949:	7e 17                	jle    80102962 <begin_op+0x63>
      sleep(&log, &log.lock);
8010294b:	83 ec 08             	sub    $0x8,%esp
8010294e:	68 a0 e4 1b 80       	push   $0x801be4a0
80102953:	68 a0 e4 1b 80       	push   $0x801be4a0
80102958:	e8 8e 0e 00 00       	call   801037eb <sleep>
8010295d:	83 c4 10             	add    $0x10,%esp
80102960:	eb c7                	jmp    80102929 <begin_op+0x2a>
      log.outstanding += 1;
80102962:	a3 dc e4 1b 80       	mov    %eax,0x801be4dc
      release(&log.lock);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 a0 e4 1b 80       	push   $0x801be4a0
8010296f:	e8 3e 14 00 00       	call   80103db2 <release>
}
80102974:	83 c4 10             	add    $0x10,%esp
80102977:	c9                   	leave  
80102978:	c3                   	ret    

80102979 <end_op>:
{
80102979:	55                   	push   %ebp
8010297a:	89 e5                	mov    %esp,%ebp
8010297c:	53                   	push   %ebx
8010297d:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102980:	68 a0 e4 1b 80       	push   $0x801be4a0
80102985:	e8 c3 13 00 00       	call   80103d4d <acquire>
  log.outstanding -= 1;
8010298a:	a1 dc e4 1b 80       	mov    0x801be4dc,%eax
8010298f:	83 e8 01             	sub    $0x1,%eax
80102992:	a3 dc e4 1b 80       	mov    %eax,0x801be4dc
  if(log.committing)
80102997:	8b 1d e0 e4 1b 80    	mov    0x801be4e0,%ebx
8010299d:	83 c4 10             	add    $0x10,%esp
801029a0:	85 db                	test   %ebx,%ebx
801029a2:	75 2c                	jne    801029d0 <end_op+0x57>
  if(log.outstanding == 0){
801029a4:	85 c0                	test   %eax,%eax
801029a6:	75 35                	jne    801029dd <end_op+0x64>
    log.committing = 1;
801029a8:	c7 05 e0 e4 1b 80 01 	movl   $0x1,0x801be4e0
801029af:	00 00 00 
    do_commit = 1;
801029b2:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801029b7:	83 ec 0c             	sub    $0xc,%esp
801029ba:	68 a0 e4 1b 80       	push   $0x801be4a0
801029bf:	e8 ee 13 00 00       	call   80103db2 <release>
  if(do_commit){
801029c4:	83 c4 10             	add    $0x10,%esp
801029c7:	85 db                	test   %ebx,%ebx
801029c9:	75 24                	jne    801029ef <end_op+0x76>
}
801029cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029ce:	c9                   	leave  
801029cf:	c3                   	ret    
    panic("log.committing");
801029d0:	83 ec 0c             	sub    $0xc,%esp
801029d3:	68 04 6b 10 80       	push   $0x80106b04
801029d8:	e8 6b d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
801029dd:	83 ec 0c             	sub    $0xc,%esp
801029e0:	68 a0 e4 1b 80       	push   $0x801be4a0
801029e5:	e8 66 0f 00 00       	call   80103950 <wakeup>
801029ea:	83 c4 10             	add    $0x10,%esp
801029ed:	eb c8                	jmp    801029b7 <end_op+0x3e>
    commit();
801029ef:	e8 91 fe ff ff       	call   80102885 <commit>
    acquire(&log.lock);
801029f4:	83 ec 0c             	sub    $0xc,%esp
801029f7:	68 a0 e4 1b 80       	push   $0x801be4a0
801029fc:	e8 4c 13 00 00       	call   80103d4d <acquire>
    log.committing = 0;
80102a01:	c7 05 e0 e4 1b 80 00 	movl   $0x0,0x801be4e0
80102a08:	00 00 00 
    wakeup(&log);
80102a0b:	c7 04 24 a0 e4 1b 80 	movl   $0x801be4a0,(%esp)
80102a12:	e8 39 0f 00 00       	call   80103950 <wakeup>
    release(&log.lock);
80102a17:	c7 04 24 a0 e4 1b 80 	movl   $0x801be4a0,(%esp)
80102a1e:	e8 8f 13 00 00       	call   80103db2 <release>
80102a23:	83 c4 10             	add    $0x10,%esp
}
80102a26:	eb a3                	jmp    801029cb <end_op+0x52>

80102a28 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a28:	55                   	push   %ebp
80102a29:	89 e5                	mov    %esp,%ebp
80102a2b:	53                   	push   %ebx
80102a2c:	83 ec 04             	sub    $0x4,%esp
80102a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a32:	8b 15 e8 e4 1b 80    	mov    0x801be4e8,%edx
80102a38:	83 fa 1d             	cmp    $0x1d,%edx
80102a3b:	7f 45                	jg     80102a82 <log_write+0x5a>
80102a3d:	a1 d8 e4 1b 80       	mov    0x801be4d8,%eax
80102a42:	83 e8 01             	sub    $0x1,%eax
80102a45:	39 c2                	cmp    %eax,%edx
80102a47:	7d 39                	jge    80102a82 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a49:	83 3d dc e4 1b 80 00 	cmpl   $0x0,0x801be4dc
80102a50:	7e 3d                	jle    80102a8f <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a52:	83 ec 0c             	sub    $0xc,%esp
80102a55:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a5a:	e8 ee 12 00 00       	call   80103d4d <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102a5f:	83 c4 10             	add    $0x10,%esp
80102a62:	b8 00 00 00 00       	mov    $0x0,%eax
80102a67:	8b 15 e8 e4 1b 80    	mov    0x801be4e8,%edx
80102a6d:	39 c2                	cmp    %eax,%edx
80102a6f:	7e 2b                	jle    80102a9c <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a71:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a74:	39 0c 85 ec e4 1b 80 	cmp    %ecx,-0x7fe41b14(,%eax,4)
80102a7b:	74 1f                	je     80102a9c <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102a7d:	83 c0 01             	add    $0x1,%eax
80102a80:	eb e5                	jmp    80102a67 <log_write+0x3f>
    panic("too big a transaction");
80102a82:	83 ec 0c             	sub    $0xc,%esp
80102a85:	68 13 6b 10 80       	push   $0x80106b13
80102a8a:	e8 b9 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102a8f:	83 ec 0c             	sub    $0xc,%esp
80102a92:	68 29 6b 10 80       	push   $0x80106b29
80102a97:	e8 ac d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102a9c:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a9f:	89 0c 85 ec e4 1b 80 	mov    %ecx,-0x7fe41b14(,%eax,4)
  if (i == log.lh.n)
80102aa6:	39 c2                	cmp    %eax,%edx
80102aa8:	74 18                	je     80102ac2 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102aaa:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102aad:	83 ec 0c             	sub    $0xc,%esp
80102ab0:	68 a0 e4 1b 80       	push   $0x801be4a0
80102ab5:	e8 f8 12 00 00       	call   80103db2 <release>
}
80102aba:	83 c4 10             	add    $0x10,%esp
80102abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ac0:	c9                   	leave  
80102ac1:	c3                   	ret    
    log.lh.n++;
80102ac2:	83 c2 01             	add    $0x1,%edx
80102ac5:	89 15 e8 e4 1b 80    	mov    %edx,0x801be4e8
80102acb:	eb dd                	jmp    80102aaa <log_write+0x82>

80102acd <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102acd:	55                   	push   %ebp
80102ace:	89 e5                	mov    %esp,%ebp
80102ad0:	53                   	push   %ebx
80102ad1:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102ad4:	68 8a 00 00 00       	push   $0x8a
80102ad9:	68 8c a4 10 80       	push   $0x8010a48c
80102ade:	68 00 70 00 80       	push   $0x80007000
80102ae3:	e8 8c 13 00 00       	call   80103e74 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102ae8:	83 c4 10             	add    $0x10,%esp
80102aeb:	bb a0 e5 1b 80       	mov    $0x801be5a0,%ebx
80102af0:	eb 06                	jmp    80102af8 <startothers+0x2b>
80102af2:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102af8:	69 05 20 eb 1b 80 b0 	imul   $0xb0,0x801beb20,%eax
80102aff:	00 00 00 
80102b02:	05 a0 e5 1b 80       	add    $0x801be5a0,%eax
80102b07:	39 d8                	cmp    %ebx,%eax
80102b09:	76 4c                	jbe    80102b57 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102b0b:	e8 c0 07 00 00       	call   801032d0 <mycpu>
80102b10:	39 d8                	cmp    %ebx,%eax
80102b12:	74 de                	je     80102af2 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102b14:	e8 a2 f5 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b19:	05 00 10 00 00       	add    $0x1000,%eax
80102b1e:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b23:	c7 05 f8 6f 00 80 9b 	movl   $0x80102b9b,0x80006ff8
80102b2a:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b2d:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b34:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b37:	83 ec 08             	sub    $0x8,%esp
80102b3a:	68 00 70 00 00       	push   $0x7000
80102b3f:	0f b6 03             	movzbl (%ebx),%eax
80102b42:	50                   	push   %eax
80102b43:	e8 c6 f9 ff ff       	call   8010250e <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b48:	83 c4 10             	add    $0x10,%esp
80102b4b:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b51:	85 c0                	test   %eax,%eax
80102b53:	74 f6                	je     80102b4b <startothers+0x7e>
80102b55:	eb 9b                	jmp    80102af2 <startothers+0x25>
      ;
  }
}
80102b57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b5a:	c9                   	leave  
80102b5b:	c3                   	ret    

80102b5c <mpmain>:
{
80102b5c:	55                   	push   %ebp
80102b5d:	89 e5                	mov    %esp,%ebp
80102b5f:	53                   	push   %ebx
80102b60:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102b63:	e8 c4 07 00 00       	call   8010332c <cpuid>
80102b68:	89 c3                	mov    %eax,%ebx
80102b6a:	e8 bd 07 00 00       	call   8010332c <cpuid>
80102b6f:	83 ec 04             	sub    $0x4,%esp
80102b72:	53                   	push   %ebx
80102b73:	50                   	push   %eax
80102b74:	68 44 6b 10 80       	push   $0x80106b44
80102b79:	e8 8d da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102b7e:	e8 4f 24 00 00       	call   80104fd2 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102b83:	e8 48 07 00 00       	call   801032d0 <mycpu>
80102b88:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102b8a:	b8 01 00 00 00       	mov    $0x1,%eax
80102b8f:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102b96:	e8 2b 0a 00 00       	call   801035c6 <scheduler>

80102b9b <mpenter>:
{
80102b9b:	55                   	push   %ebp
80102b9c:	89 e5                	mov    %esp,%ebp
80102b9e:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102ba1:	e8 35 34 00 00       	call   80105fdb <switchkvm>
  seginit();
80102ba6:	e8 e4 32 00 00       	call   80105e8f <seginit>
  lapicinit();
80102bab:	e8 15 f8 ff ff       	call   801023c5 <lapicinit>
  mpmain();
80102bb0:	e8 a7 ff ff ff       	call   80102b5c <mpmain>

80102bb5 <main>:
{
80102bb5:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102bb9:	83 e4 f0             	and    $0xfffffff0,%esp
80102bbc:	ff 71 fc             	pushl  -0x4(%ecx)
80102bbf:	55                   	push   %ebp
80102bc0:	89 e5                	mov    %esp,%ebp
80102bc2:	51                   	push   %ecx
80102bc3:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102bc6:	68 00 00 40 80       	push   $0x80400000
80102bcb:	68 c8 12 1c 80       	push   $0x801c12c8
80102bd0:	e8 94 f4 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102bd5:	e8 8e 38 00 00       	call   80106468 <kvmalloc>
  mpinit();        // detect other processors
80102bda:	e8 c9 01 00 00       	call   80102da8 <mpinit>
  lapicinit();     // interrupt controller
80102bdf:	e8 e1 f7 ff ff       	call   801023c5 <lapicinit>
  seginit();       // segment descriptors
80102be4:	e8 a6 32 00 00       	call   80105e8f <seginit>
  picinit();       // disable pic
80102be9:	e8 82 02 00 00       	call   80102e70 <picinit>
  ioapicinit();    // another interrupt controller
80102bee:	e8 07 f3 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102bf3:	e8 96 dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102bf8:	e8 83 26 00 00       	call   80105280 <uartinit>
  pinit();         // process table
80102bfd:	e8 b4 06 00 00       	call   801032b6 <pinit>
  tvinit();        // trap vectors
80102c02:	e8 1a 23 00 00       	call   80104f21 <tvinit>
  binit();         // buffer cache
80102c07:	e8 e8 d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c0c:	e8 02 e0 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102c11:	e8 ea f0 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102c16:	e8 b2 fe ff ff       	call   80102acd <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c1b:	83 c4 08             	add    $0x8,%esp
80102c1e:	68 00 00 00 8e       	push   $0x8e000000
80102c23:	68 00 00 40 80       	push   $0x80400000
80102c28:	e8 6e f4 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102c2d:	e8 39 07 00 00       	call   8010336b <userinit>
  mpmain();        // finish this processor's setup
80102c32:	e8 25 ff ff ff       	call   80102b5c <mpmain>

80102c37 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c37:	55                   	push   %ebp
80102c38:	89 e5                	mov    %esp,%ebp
80102c3a:	56                   	push   %esi
80102c3b:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102c41:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c46:	eb 09                	jmp    80102c51 <sum+0x1a>
    sum += addr[i];
80102c48:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102c4c:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102c4e:	83 c1 01             	add    $0x1,%ecx
80102c51:	39 d1                	cmp    %edx,%ecx
80102c53:	7c f3                	jl     80102c48 <sum+0x11>
  return sum;
}
80102c55:	89 d8                	mov    %ebx,%eax
80102c57:	5b                   	pop    %ebx
80102c58:	5e                   	pop    %esi
80102c59:	5d                   	pop    %ebp
80102c5a:	c3                   	ret    

80102c5b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c5b:	55                   	push   %ebp
80102c5c:	89 e5                	mov    %esp,%ebp
80102c5e:	56                   	push   %esi
80102c5f:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102c60:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102c66:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102c68:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102c6a:	eb 03                	jmp    80102c6f <mpsearch1+0x14>
80102c6c:	83 c3 10             	add    $0x10,%ebx
80102c6f:	39 f3                	cmp    %esi,%ebx
80102c71:	73 29                	jae    80102c9c <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102c73:	83 ec 04             	sub    $0x4,%esp
80102c76:	6a 04                	push   $0x4
80102c78:	68 58 6b 10 80       	push   $0x80106b58
80102c7d:	53                   	push   %ebx
80102c7e:	e8 bc 11 00 00       	call   80103e3f <memcmp>
80102c83:	83 c4 10             	add    $0x10,%esp
80102c86:	85 c0                	test   %eax,%eax
80102c88:	75 e2                	jne    80102c6c <mpsearch1+0x11>
80102c8a:	ba 10 00 00 00       	mov    $0x10,%edx
80102c8f:	89 d8                	mov    %ebx,%eax
80102c91:	e8 a1 ff ff ff       	call   80102c37 <sum>
80102c96:	84 c0                	test   %al,%al
80102c98:	75 d2                	jne    80102c6c <mpsearch1+0x11>
80102c9a:	eb 05                	jmp    80102ca1 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102ca1:	89 d8                	mov    %ebx,%eax
80102ca3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102ca6:	5b                   	pop    %ebx
80102ca7:	5e                   	pop    %esi
80102ca8:	5d                   	pop    %ebp
80102ca9:	c3                   	ret    

80102caa <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102caa:	55                   	push   %ebp
80102cab:	89 e5                	mov    %esp,%ebp
80102cad:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102cb0:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102cb7:	c1 e0 08             	shl    $0x8,%eax
80102cba:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102cc1:	09 d0                	or     %edx,%eax
80102cc3:	c1 e0 04             	shl    $0x4,%eax
80102cc6:	85 c0                	test   %eax,%eax
80102cc8:	74 1f                	je     80102ce9 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102cca:	ba 00 04 00 00       	mov    $0x400,%edx
80102ccf:	e8 87 ff ff ff       	call   80102c5b <mpsearch1>
80102cd4:	85 c0                	test   %eax,%eax
80102cd6:	75 0f                	jne    80102ce7 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102cd8:	ba 00 00 01 00       	mov    $0x10000,%edx
80102cdd:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ce2:	e8 74 ff ff ff       	call   80102c5b <mpsearch1>
}
80102ce7:	c9                   	leave  
80102ce8:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ce9:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102cf0:	c1 e0 08             	shl    $0x8,%eax
80102cf3:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102cfa:	09 d0                	or     %edx,%eax
80102cfc:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102cff:	2d 00 04 00 00       	sub    $0x400,%eax
80102d04:	ba 00 04 00 00       	mov    $0x400,%edx
80102d09:	e8 4d ff ff ff       	call   80102c5b <mpsearch1>
80102d0e:	85 c0                	test   %eax,%eax
80102d10:	75 d5                	jne    80102ce7 <mpsearch+0x3d>
80102d12:	eb c4                	jmp    80102cd8 <mpsearch+0x2e>

80102d14 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d14:	55                   	push   %ebp
80102d15:	89 e5                	mov    %esp,%ebp
80102d17:	57                   	push   %edi
80102d18:	56                   	push   %esi
80102d19:	53                   	push   %ebx
80102d1a:	83 ec 1c             	sub    $0x1c,%esp
80102d1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d20:	e8 85 ff ff ff       	call   80102caa <mpsearch>
80102d25:	85 c0                	test   %eax,%eax
80102d27:	74 5c                	je     80102d85 <mpconfig+0x71>
80102d29:	89 c7                	mov    %eax,%edi
80102d2b:	8b 58 04             	mov    0x4(%eax),%ebx
80102d2e:	85 db                	test   %ebx,%ebx
80102d30:	74 5a                	je     80102d8c <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d32:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d38:	83 ec 04             	sub    $0x4,%esp
80102d3b:	6a 04                	push   $0x4
80102d3d:	68 5d 6b 10 80       	push   $0x80106b5d
80102d42:	56                   	push   %esi
80102d43:	e8 f7 10 00 00       	call   80103e3f <memcmp>
80102d48:	83 c4 10             	add    $0x10,%esp
80102d4b:	85 c0                	test   %eax,%eax
80102d4d:	75 44                	jne    80102d93 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d4f:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102d56:	3c 01                	cmp    $0x1,%al
80102d58:	0f 95 c2             	setne  %dl
80102d5b:	3c 04                	cmp    $0x4,%al
80102d5d:	0f 95 c0             	setne  %al
80102d60:	84 c2                	test   %al,%dl
80102d62:	75 36                	jne    80102d9a <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102d64:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102d6b:	89 f0                	mov    %esi,%eax
80102d6d:	e8 c5 fe ff ff       	call   80102c37 <sum>
80102d72:	84 c0                	test   %al,%al
80102d74:	75 2b                	jne    80102da1 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d79:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102d7b:	89 f0                	mov    %esi,%eax
80102d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d80:	5b                   	pop    %ebx
80102d81:	5e                   	pop    %esi
80102d82:	5f                   	pop    %edi
80102d83:	5d                   	pop    %ebp
80102d84:	c3                   	ret    
    return 0;
80102d85:	be 00 00 00 00       	mov    $0x0,%esi
80102d8a:	eb ef                	jmp    80102d7b <mpconfig+0x67>
80102d8c:	be 00 00 00 00       	mov    $0x0,%esi
80102d91:	eb e8                	jmp    80102d7b <mpconfig+0x67>
    return 0;
80102d93:	be 00 00 00 00       	mov    $0x0,%esi
80102d98:	eb e1                	jmp    80102d7b <mpconfig+0x67>
    return 0;
80102d9a:	be 00 00 00 00       	mov    $0x0,%esi
80102d9f:	eb da                	jmp    80102d7b <mpconfig+0x67>
    return 0;
80102da1:	be 00 00 00 00       	mov    $0x0,%esi
80102da6:	eb d3                	jmp    80102d7b <mpconfig+0x67>

80102da8 <mpinit>:

void
mpinit(void)
{
80102da8:	55                   	push   %ebp
80102da9:	89 e5                	mov    %esp,%ebp
80102dab:	57                   	push   %edi
80102dac:	56                   	push   %esi
80102dad:	53                   	push   %ebx
80102dae:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102db1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102db4:	e8 5b ff ff ff       	call   80102d14 <mpconfig>
80102db9:	85 c0                	test   %eax,%eax
80102dbb:	74 19                	je     80102dd6 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102dbd:	8b 50 24             	mov    0x24(%eax),%edx
80102dc0:	89 15 80 e4 1b 80    	mov    %edx,0x801be480
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dc6:	8d 50 2c             	lea    0x2c(%eax),%edx
80102dc9:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102dcd:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102dcf:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dd4:	eb 34                	jmp    80102e0a <mpinit+0x62>
    panic("Expect to run on an SMP");
80102dd6:	83 ec 0c             	sub    $0xc,%esp
80102dd9:	68 62 6b 10 80       	push   $0x80106b62
80102dde:	e8 65 d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102de3:	8b 35 20 eb 1b 80    	mov    0x801beb20,%esi
80102de9:	83 fe 07             	cmp    $0x7,%esi
80102dec:	7f 19                	jg     80102e07 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102dee:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102df2:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102df8:	88 87 a0 e5 1b 80    	mov    %al,-0x7fe41a60(%edi)
        ncpu++;
80102dfe:	83 c6 01             	add    $0x1,%esi
80102e01:	89 35 20 eb 1b 80    	mov    %esi,0x801beb20
      }
      p += sizeof(struct mpproc);
80102e07:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e0a:	39 ca                	cmp    %ecx,%edx
80102e0c:	73 2b                	jae    80102e39 <mpinit+0x91>
    switch(*p){
80102e0e:	0f b6 02             	movzbl (%edx),%eax
80102e11:	3c 04                	cmp    $0x4,%al
80102e13:	77 1d                	ja     80102e32 <mpinit+0x8a>
80102e15:	0f b6 c0             	movzbl %al,%eax
80102e18:	ff 24 85 9c 6b 10 80 	jmp    *-0x7fef9464(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e1f:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e23:	a2 80 e5 1b 80       	mov    %al,0x801be580
      p += sizeof(struct mpioapic);
80102e28:	83 c2 08             	add    $0x8,%edx
      continue;
80102e2b:	eb dd                	jmp    80102e0a <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102e2d:	83 c2 08             	add    $0x8,%edx
      continue;
80102e30:	eb d8                	jmp    80102e0a <mpinit+0x62>
    default:
      ismp = 0;
80102e32:	bb 00 00 00 00       	mov    $0x0,%ebx
80102e37:	eb d1                	jmp    80102e0a <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102e39:	85 db                	test   %ebx,%ebx
80102e3b:	74 26                	je     80102e63 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e40:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e44:	74 15                	je     80102e5b <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e46:	b8 70 00 00 00       	mov    $0x70,%eax
80102e4b:	ba 22 00 00 00       	mov    $0x22,%edx
80102e50:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e51:	ba 23 00 00 00       	mov    $0x23,%edx
80102e56:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e57:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e5a:	ee                   	out    %al,(%dx)
  }
}
80102e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e5e:	5b                   	pop    %ebx
80102e5f:	5e                   	pop    %esi
80102e60:	5f                   	pop    %edi
80102e61:	5d                   	pop    %ebp
80102e62:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102e63:	83 ec 0c             	sub    $0xc,%esp
80102e66:	68 7c 6b 10 80       	push   $0x80106b7c
80102e6b:	e8 d8 d4 ff ff       	call   80100348 <panic>

80102e70 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e78:	ba 21 00 00 00       	mov    $0x21,%edx
80102e7d:	ee                   	out    %al,(%dx)
80102e7e:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e83:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e84:	5d                   	pop    %ebp
80102e85:	c3                   	ret    

80102e86 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e86:	55                   	push   %ebp
80102e87:	89 e5                	mov    %esp,%ebp
80102e89:	57                   	push   %edi
80102e8a:	56                   	push   %esi
80102e8b:	53                   	push   %ebx
80102e8c:	83 ec 0c             	sub    $0xc,%esp
80102e8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e92:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e95:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102ea1:	e8 87 dd ff ff       	call   80100c2d <filealloc>
80102ea6:	89 03                	mov    %eax,(%ebx)
80102ea8:	85 c0                	test   %eax,%eax
80102eaa:	74 16                	je     80102ec2 <pipealloc+0x3c>
80102eac:	e8 7c dd ff ff       	call   80100c2d <filealloc>
80102eb1:	89 06                	mov    %eax,(%esi)
80102eb3:	85 c0                	test   %eax,%eax
80102eb5:	74 0b                	je     80102ec2 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102eb7:	e8 ff f1 ff ff       	call   801020bb <kalloc>
80102ebc:	89 c7                	mov    %eax,%edi
80102ebe:	85 c0                	test   %eax,%eax
80102ec0:	75 35                	jne    80102ef7 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102ec2:	8b 03                	mov    (%ebx),%eax
80102ec4:	85 c0                	test   %eax,%eax
80102ec6:	74 0c                	je     80102ed4 <pipealloc+0x4e>
    fileclose(*f0);
80102ec8:	83 ec 0c             	sub    $0xc,%esp
80102ecb:	50                   	push   %eax
80102ecc:	e8 02 de ff ff       	call   80100cd3 <fileclose>
80102ed1:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102ed4:	8b 06                	mov    (%esi),%eax
80102ed6:	85 c0                	test   %eax,%eax
80102ed8:	0f 84 8b 00 00 00    	je     80102f69 <pipealloc+0xe3>
    fileclose(*f1);
80102ede:	83 ec 0c             	sub    $0xc,%esp
80102ee1:	50                   	push   %eax
80102ee2:	e8 ec dd ff ff       	call   80100cd3 <fileclose>
80102ee7:	83 c4 10             	add    $0x10,%esp
  return -1;
80102eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ef2:	5b                   	pop    %ebx
80102ef3:	5e                   	pop    %esi
80102ef4:	5f                   	pop    %edi
80102ef5:	5d                   	pop    %ebp
80102ef6:	c3                   	ret    
  p->readopen = 1;
80102ef7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102efe:	00 00 00 
  p->writeopen = 1;
80102f01:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f08:	00 00 00 
  p->nwrite = 0;
80102f0b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f12:	00 00 00 
  p->nread = 0;
80102f15:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f1c:	00 00 00 
  initlock(&p->lock, "pipe");
80102f1f:	83 ec 08             	sub    $0x8,%esp
80102f22:	68 b0 6b 10 80       	push   $0x80106bb0
80102f27:	50                   	push   %eax
80102f28:	e8 e4 0c 00 00       	call   80103c11 <initlock>
  (*f0)->type = FD_PIPE;
80102f2d:	8b 03                	mov    (%ebx),%eax
80102f2f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102f35:	8b 03                	mov    (%ebx),%eax
80102f37:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f3b:	8b 03                	mov    (%ebx),%eax
80102f3d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102f41:	8b 03                	mov    (%ebx),%eax
80102f43:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102f46:	8b 06                	mov    (%esi),%eax
80102f48:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102f4e:	8b 06                	mov    (%esi),%eax
80102f50:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102f54:	8b 06                	mov    (%esi),%eax
80102f56:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102f5a:	8b 06                	mov    (%esi),%eax
80102f5c:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102f5f:	83 c4 10             	add    $0x10,%esp
80102f62:	b8 00 00 00 00       	mov    $0x0,%eax
80102f67:	eb 86                	jmp    80102eef <pipealloc+0x69>
  return -1;
80102f69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f6e:	e9 7c ff ff ff       	jmp    80102eef <pipealloc+0x69>

80102f73 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f73:	55                   	push   %ebp
80102f74:	89 e5                	mov    %esp,%ebp
80102f76:	53                   	push   %ebx
80102f77:	83 ec 10             	sub    $0x10,%esp
80102f7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102f7d:	53                   	push   %ebx
80102f7e:	e8 ca 0d 00 00       	call   80103d4d <acquire>
  if(writable){
80102f83:	83 c4 10             	add    $0x10,%esp
80102f86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f8a:	74 3f                	je     80102fcb <pipeclose+0x58>
    p->writeopen = 0;
80102f8c:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f93:	00 00 00 
    wakeup(&p->nread);
80102f96:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f9c:	83 ec 0c             	sub    $0xc,%esp
80102f9f:	50                   	push   %eax
80102fa0:	e8 ab 09 00 00       	call   80103950 <wakeup>
80102fa5:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102fa8:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102faf:	75 09                	jne    80102fba <pipeclose+0x47>
80102fb1:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102fb8:	74 2f                	je     80102fe9 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102fba:	83 ec 0c             	sub    $0xc,%esp
80102fbd:	53                   	push   %ebx
80102fbe:	e8 ef 0d 00 00       	call   80103db2 <release>
80102fc3:	83 c4 10             	add    $0x10,%esp
}
80102fc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102fc9:	c9                   	leave  
80102fca:	c3                   	ret    
    p->readopen = 0;
80102fcb:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102fd2:	00 00 00 
    wakeup(&p->nwrite);
80102fd5:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fdb:	83 ec 0c             	sub    $0xc,%esp
80102fde:	50                   	push   %eax
80102fdf:	e8 6c 09 00 00       	call   80103950 <wakeup>
80102fe4:	83 c4 10             	add    $0x10,%esp
80102fe7:	eb bf                	jmp    80102fa8 <pipeclose+0x35>
    release(&p->lock);
80102fe9:	83 ec 0c             	sub    $0xc,%esp
80102fec:	53                   	push   %ebx
80102fed:	e8 c0 0d 00 00       	call   80103db2 <release>
    kfree((char*)p);
80102ff2:	89 1c 24             	mov    %ebx,(%esp)
80102ff5:	e8 aa ef ff ff       	call   80101fa4 <kfree>
80102ffa:	83 c4 10             	add    $0x10,%esp
80102ffd:	eb c7                	jmp    80102fc6 <pipeclose+0x53>

80102fff <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102fff:	55                   	push   %ebp
80103000:	89 e5                	mov    %esp,%ebp
80103002:	57                   	push   %edi
80103003:	56                   	push   %esi
80103004:	53                   	push   %ebx
80103005:	83 ec 18             	sub    $0x18,%esp
80103008:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010300b:	89 de                	mov    %ebx,%esi
8010300d:	53                   	push   %ebx
8010300e:	e8 3a 0d 00 00       	call   80103d4d <acquire>
  for(i = 0; i < n; i++){
80103013:	83 c4 10             	add    $0x10,%esp
80103016:	bf 00 00 00 00       	mov    $0x0,%edi
8010301b:	3b 7d 10             	cmp    0x10(%ebp),%edi
8010301e:	0f 8d 88 00 00 00    	jge    801030ac <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103024:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010302a:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103030:	05 00 02 00 00       	add    $0x200,%eax
80103035:	39 c2                	cmp    %eax,%edx
80103037:	75 51                	jne    8010308a <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80103039:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103040:	74 2f                	je     80103071 <pipewrite+0x72>
80103042:	e8 00 03 00 00       	call   80103347 <myproc>
80103047:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010304b:	75 24                	jne    80103071 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010304d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103053:	83 ec 0c             	sub    $0xc,%esp
80103056:	50                   	push   %eax
80103057:	e8 f4 08 00 00       	call   80103950 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010305c:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103062:	83 c4 08             	add    $0x8,%esp
80103065:	56                   	push   %esi
80103066:	50                   	push   %eax
80103067:	e8 7f 07 00 00       	call   801037eb <sleep>
8010306c:	83 c4 10             	add    $0x10,%esp
8010306f:	eb b3                	jmp    80103024 <pipewrite+0x25>
        release(&p->lock);
80103071:	83 ec 0c             	sub    $0xc,%esp
80103074:	53                   	push   %ebx
80103075:	e8 38 0d 00 00       	call   80103db2 <release>
        return -1;
8010307a:	83 c4 10             	add    $0x10,%esp
8010307d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103082:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103085:	5b                   	pop    %ebx
80103086:	5e                   	pop    %esi
80103087:	5f                   	pop    %edi
80103088:	5d                   	pop    %ebp
80103089:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010308a:	8d 42 01             	lea    0x1(%edx),%eax
8010308d:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103093:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103099:	8b 45 0c             	mov    0xc(%ebp),%eax
8010309c:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801030a0:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801030a4:	83 c7 01             	add    $0x1,%edi
801030a7:	e9 6f ff ff ff       	jmp    8010301b <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801030ac:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030b2:	83 ec 0c             	sub    $0xc,%esp
801030b5:	50                   	push   %eax
801030b6:	e8 95 08 00 00       	call   80103950 <wakeup>
  release(&p->lock);
801030bb:	89 1c 24             	mov    %ebx,(%esp)
801030be:	e8 ef 0c 00 00       	call   80103db2 <release>
  return n;
801030c3:	83 c4 10             	add    $0x10,%esp
801030c6:	8b 45 10             	mov    0x10(%ebp),%eax
801030c9:	eb b7                	jmp    80103082 <pipewrite+0x83>

801030cb <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801030cb:	55                   	push   %ebp
801030cc:	89 e5                	mov    %esp,%ebp
801030ce:	57                   	push   %edi
801030cf:	56                   	push   %esi
801030d0:	53                   	push   %ebx
801030d1:	83 ec 18             	sub    $0x18,%esp
801030d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801030d7:	89 df                	mov    %ebx,%edi
801030d9:	53                   	push   %ebx
801030da:	e8 6e 0c 00 00       	call   80103d4d <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801030df:	83 c4 10             	add    $0x10,%esp
801030e2:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801030e8:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801030ee:	75 3d                	jne    8010312d <piperead+0x62>
801030f0:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
801030f6:	85 f6                	test   %esi,%esi
801030f8:	74 38                	je     80103132 <piperead+0x67>
    if(myproc()->killed){
801030fa:	e8 48 02 00 00       	call   80103347 <myproc>
801030ff:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103103:	75 15                	jne    8010311a <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103105:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010310b:	83 ec 08             	sub    $0x8,%esp
8010310e:	57                   	push   %edi
8010310f:	50                   	push   %eax
80103110:	e8 d6 06 00 00       	call   801037eb <sleep>
80103115:	83 c4 10             	add    $0x10,%esp
80103118:	eb c8                	jmp    801030e2 <piperead+0x17>
      release(&p->lock);
8010311a:	83 ec 0c             	sub    $0xc,%esp
8010311d:	53                   	push   %ebx
8010311e:	e8 8f 0c 00 00       	call   80103db2 <release>
      return -1;
80103123:	83 c4 10             	add    $0x10,%esp
80103126:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010312b:	eb 50                	jmp    8010317d <piperead+0xb2>
8010312d:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103132:	3b 75 10             	cmp    0x10(%ebp),%esi
80103135:	7d 2c                	jge    80103163 <piperead+0x98>
    if(p->nread == p->nwrite)
80103137:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010313d:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103143:	74 1e                	je     80103163 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103145:	8d 50 01             	lea    0x1(%eax),%edx
80103148:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
8010314e:	25 ff 01 00 00       	and    $0x1ff,%eax
80103153:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010315b:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010315e:	83 c6 01             	add    $0x1,%esi
80103161:	eb cf                	jmp    80103132 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103163:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	50                   	push   %eax
8010316d:	e8 de 07 00 00       	call   80103950 <wakeup>
  release(&p->lock);
80103172:	89 1c 24             	mov    %ebx,(%esp)
80103175:	e8 38 0c 00 00       	call   80103db2 <release>
  return i;
8010317a:	83 c4 10             	add    $0x10,%esp
}
8010317d:	89 f0                	mov    %esi,%eax
8010317f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103182:	5b                   	pop    %ebx
80103183:	5e                   	pop    %esi
80103184:	5f                   	pop    %edi
80103185:	5d                   	pop    %ebp
80103186:	c3                   	ret    

80103187 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103187:	55                   	push   %ebp
80103188:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010318a:	ba 74 eb 1b 80       	mov    $0x801beb74,%edx
8010318f:	eb 03                	jmp    80103194 <wakeup1+0xd>
80103191:	83 c2 7c             	add    $0x7c,%edx
80103194:	81 fa 74 0a 1c 80    	cmp    $0x801c0a74,%edx
8010319a:	73 14                	jae    801031b0 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010319c:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801031a0:	75 ef                	jne    80103191 <wakeup1+0xa>
801031a2:	39 42 20             	cmp    %eax,0x20(%edx)
801031a5:	75 ea                	jne    80103191 <wakeup1+0xa>
      p->state = RUNNABLE;
801031a7:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801031ae:	eb e1                	jmp    80103191 <wakeup1+0xa>
}
801031b0:	5d                   	pop    %ebp
801031b1:	c3                   	ret    

801031b2 <allocproc>:
{
801031b2:	55                   	push   %ebp
801031b3:	89 e5                	mov    %esp,%ebp
801031b5:	53                   	push   %ebx
801031b6:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801031b9:	68 40 eb 1b 80       	push   $0x801beb40
801031be:	e8 8a 0b 00 00       	call   80103d4d <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031c3:	83 c4 10             	add    $0x10,%esp
801031c6:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
801031cb:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
801031d1:	73 0b                	jae    801031de <allocproc+0x2c>
    if(p->state == UNUSED)
801031d3:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801031d7:	74 1c                	je     801031f5 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031d9:	83 c3 7c             	add    $0x7c,%ebx
801031dc:	eb ed                	jmp    801031cb <allocproc+0x19>
  release(&ptable.lock);
801031de:	83 ec 0c             	sub    $0xc,%esp
801031e1:	68 40 eb 1b 80       	push   $0x801beb40
801031e6:	e8 c7 0b 00 00       	call   80103db2 <release>
  return 0;
801031eb:	83 c4 10             	add    $0x10,%esp
801031ee:	bb 00 00 00 00       	mov    $0x0,%ebx
801031f3:	eb 69                	jmp    8010325e <allocproc+0xac>
  p->state = EMBRYO;
801031f5:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801031fc:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103201:	8d 50 01             	lea    0x1(%eax),%edx
80103204:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
8010320a:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010320d:	83 ec 0c             	sub    $0xc,%esp
80103210:	68 40 eb 1b 80       	push   $0x801beb40
80103215:	e8 98 0b 00 00       	call   80103db2 <release>
  if((p->kstack = kalloc()) == 0){
8010321a:	e8 9c ee ff ff       	call   801020bb <kalloc>
8010321f:	89 43 08             	mov    %eax,0x8(%ebx)
80103222:	83 c4 10             	add    $0x10,%esp
80103225:	85 c0                	test   %eax,%eax
80103227:	74 3c                	je     80103265 <allocproc+0xb3>
  sp -= sizeof *p->tf;
80103229:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010322f:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103232:	c7 80 b0 0f 00 00 16 	movl   $0x80104f16,0xfb0(%eax)
80103239:	4f 10 80 
  sp -= sizeof *p->context;
8010323c:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103241:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103244:	83 ec 04             	sub    $0x4,%esp
80103247:	6a 14                	push   $0x14
80103249:	6a 00                	push   $0x0
8010324b:	50                   	push   %eax
8010324c:	e8 a8 0b 00 00       	call   80103df9 <memset>
  p->context->eip = (uint)forkret;
80103251:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103254:	c7 40 10 73 32 10 80 	movl   $0x80103273,0x10(%eax)
  return p;
8010325b:	83 c4 10             	add    $0x10,%esp
}
8010325e:	89 d8                	mov    %ebx,%eax
80103260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103263:	c9                   	leave  
80103264:	c3                   	ret    
    p->state = UNUSED;
80103265:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
8010326c:	bb 00 00 00 00       	mov    $0x0,%ebx
80103271:	eb eb                	jmp    8010325e <allocproc+0xac>

80103273 <forkret>:
{
80103273:	55                   	push   %ebp
80103274:	89 e5                	mov    %esp,%ebp
80103276:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103279:	68 40 eb 1b 80       	push   $0x801beb40
8010327e:	e8 2f 0b 00 00       	call   80103db2 <release>
  if (first) {
80103283:	83 c4 10             	add    $0x10,%esp
80103286:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010328d:	75 02                	jne    80103291 <forkret+0x1e>
}
8010328f:	c9                   	leave  
80103290:	c3                   	ret    
    first = 0;
80103291:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103298:	00 00 00 
    iinit(ROOTDEV);
8010329b:	83 ec 0c             	sub    $0xc,%esp
8010329e:	6a 01                	push   $0x1
801032a0:	e8 47 e0 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
801032a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032ac:	e8 05 f6 ff ff       	call   801028b6 <initlog>
801032b1:	83 c4 10             	add    $0x10,%esp
}
801032b4:	eb d9                	jmp    8010328f <forkret+0x1c>

801032b6 <pinit>:
{
801032b6:	55                   	push   %ebp
801032b7:	89 e5                	mov    %esp,%ebp
801032b9:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801032bc:	68 b5 6b 10 80       	push   $0x80106bb5
801032c1:	68 40 eb 1b 80       	push   $0x801beb40
801032c6:	e8 46 09 00 00       	call   80103c11 <initlock>
}
801032cb:	83 c4 10             	add    $0x10,%esp
801032ce:	c9                   	leave  
801032cf:	c3                   	ret    

801032d0 <mycpu>:
{
801032d0:	55                   	push   %ebp
801032d1:	89 e5                	mov    %esp,%ebp
801032d3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801032d6:	9c                   	pushf  
801032d7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801032d8:	f6 c4 02             	test   $0x2,%ah
801032db:	75 28                	jne    80103305 <mycpu+0x35>
  apicid = lapicid();
801032dd:	e8 ed f1 ff ff       	call   801024cf <lapicid>
  for (i = 0; i < ncpu; ++i) {
801032e2:	ba 00 00 00 00       	mov    $0x0,%edx
801032e7:	39 15 20 eb 1b 80    	cmp    %edx,0x801beb20
801032ed:	7e 23                	jle    80103312 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801032ef:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801032f5:	0f b6 89 a0 e5 1b 80 	movzbl -0x7fe41a60(%ecx),%ecx
801032fc:	39 c1                	cmp    %eax,%ecx
801032fe:	74 1f                	je     8010331f <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103300:	83 c2 01             	add    $0x1,%edx
80103303:	eb e2                	jmp    801032e7 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103305:	83 ec 0c             	sub    $0xc,%esp
80103308:	68 98 6c 10 80       	push   $0x80106c98
8010330d:	e8 36 d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103312:	83 ec 0c             	sub    $0xc,%esp
80103315:	68 bc 6b 10 80       	push   $0x80106bbc
8010331a:	e8 29 d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
8010331f:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103325:	05 a0 e5 1b 80       	add    $0x801be5a0,%eax
}
8010332a:	c9                   	leave  
8010332b:	c3                   	ret    

8010332c <cpuid>:
cpuid() {
8010332c:	55                   	push   %ebp
8010332d:	89 e5                	mov    %esp,%ebp
8010332f:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103332:	e8 99 ff ff ff       	call   801032d0 <mycpu>
80103337:	2d a0 e5 1b 80       	sub    $0x801be5a0,%eax
8010333c:	c1 f8 04             	sar    $0x4,%eax
8010333f:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103345:	c9                   	leave  
80103346:	c3                   	ret    

80103347 <myproc>:
myproc(void) {
80103347:	55                   	push   %ebp
80103348:	89 e5                	mov    %esp,%ebp
8010334a:	53                   	push   %ebx
8010334b:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010334e:	e8 1d 09 00 00       	call   80103c70 <pushcli>
  c = mycpu();
80103353:	e8 78 ff ff ff       	call   801032d0 <mycpu>
  p = c->proc;
80103358:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010335e:	e8 4a 09 00 00       	call   80103cad <popcli>
}
80103363:	89 d8                	mov    %ebx,%eax
80103365:	83 c4 04             	add    $0x4,%esp
80103368:	5b                   	pop    %ebx
80103369:	5d                   	pop    %ebp
8010336a:	c3                   	ret    

8010336b <userinit>:
{
8010336b:	55                   	push   %ebp
8010336c:	89 e5                	mov    %esp,%ebp
8010336e:	53                   	push   %ebx
8010336f:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103372:	e8 3b fe ff ff       	call   801031b2 <allocproc>
80103377:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103379:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
8010337e:	e8 77 30 00 00       	call   801063fa <setupkvm>
80103383:	89 43 04             	mov    %eax,0x4(%ebx)
80103386:	85 c0                	test   %eax,%eax
80103388:	0f 84 b7 00 00 00    	je     80103445 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010338e:	83 ec 04             	sub    $0x4,%esp
80103391:	68 2c 00 00 00       	push   $0x2c
80103396:	68 60 a4 10 80       	push   $0x8010a460
8010339b:	50                   	push   %eax
8010339c:	e8 64 2d 00 00       	call   80106105 <inituvm>
  p->sz = PGSIZE;
801033a1:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033a7:	83 c4 0c             	add    $0xc,%esp
801033aa:	6a 4c                	push   $0x4c
801033ac:	6a 00                	push   $0x0
801033ae:	ff 73 18             	pushl  0x18(%ebx)
801033b1:	e8 43 0a 00 00       	call   80103df9 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801033b6:	8b 43 18             	mov    0x18(%ebx),%eax
801033b9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801033bf:	8b 43 18             	mov    0x18(%ebx),%eax
801033c2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801033c8:	8b 43 18             	mov    0x18(%ebx),%eax
801033cb:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033cf:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801033d3:	8b 43 18             	mov    0x18(%ebx),%eax
801033d6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033da:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801033de:	8b 43 18             	mov    0x18(%ebx),%eax
801033e1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801033e8:	8b 43 18             	mov    0x18(%ebx),%eax
801033eb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801033f2:	8b 43 18             	mov    0x18(%ebx),%eax
801033f5:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801033fc:	8d 43 6c             	lea    0x6c(%ebx),%eax
801033ff:	83 c4 0c             	add    $0xc,%esp
80103402:	6a 10                	push   $0x10
80103404:	68 e5 6b 10 80       	push   $0x80106be5
80103409:	50                   	push   %eax
8010340a:	e8 51 0b 00 00       	call   80103f60 <safestrcpy>
  p->cwd = namei("/");
8010340f:	c7 04 24 ee 6b 10 80 	movl   $0x80106bee,(%esp)
80103416:	e8 c6 e7 ff ff       	call   80101be1 <namei>
8010341b:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010341e:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103425:	e8 23 09 00 00       	call   80103d4d <acquire>
  p->state = RUNNABLE;
8010342a:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103431:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103438:	e8 75 09 00 00       	call   80103db2 <release>
}
8010343d:	83 c4 10             	add    $0x10,%esp
80103440:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103443:	c9                   	leave  
80103444:	c3                   	ret    
    panic("userinit: out of memory?");
80103445:	83 ec 0c             	sub    $0xc,%esp
80103448:	68 cc 6b 10 80       	push   $0x80106bcc
8010344d:	e8 f6 ce ff ff       	call   80100348 <panic>

80103452 <growproc>:
{
80103452:	55                   	push   %ebp
80103453:	89 e5                	mov    %esp,%ebp
80103455:	56                   	push   %esi
80103456:	53                   	push   %ebx
80103457:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010345a:	e8 e8 fe ff ff       	call   80103347 <myproc>
8010345f:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103461:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103463:	85 f6                	test   %esi,%esi
80103465:	7f 21                	jg     80103488 <growproc+0x36>
  } else if(n < 0){
80103467:	85 f6                	test   %esi,%esi
80103469:	79 33                	jns    8010349e <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010346b:	83 ec 04             	sub    $0x4,%esp
8010346e:	01 c6                	add    %eax,%esi
80103470:	56                   	push   %esi
80103471:	50                   	push   %eax
80103472:	ff 73 04             	pushl  0x4(%ebx)
80103475:	e8 94 2d 00 00       	call   8010620e <deallocuvm>
8010347a:	83 c4 10             	add    $0x10,%esp
8010347d:	85 c0                	test   %eax,%eax
8010347f:	75 1d                	jne    8010349e <growproc+0x4c>
      return -1;
80103481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103486:	eb 29                	jmp    801034b1 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103488:	83 ec 04             	sub    $0x4,%esp
8010348b:	01 c6                	add    %eax,%esi
8010348d:	56                   	push   %esi
8010348e:	50                   	push   %eax
8010348f:	ff 73 04             	pushl  0x4(%ebx)
80103492:	e8 09 2e 00 00       	call   801062a0 <allocuvm>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	85 c0                	test   %eax,%eax
8010349c:	74 1a                	je     801034b8 <growproc+0x66>
  curproc->sz = sz;
8010349e:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	53                   	push   %ebx
801034a4:	e8 44 2b 00 00       	call   80105fed <switchuvm>
  return 0;
801034a9:	83 c4 10             	add    $0x10,%esp
801034ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801034b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034b4:	5b                   	pop    %ebx
801034b5:	5e                   	pop    %esi
801034b6:	5d                   	pop    %ebp
801034b7:	c3                   	ret    
      return -1;
801034b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034bd:	eb f2                	jmp    801034b1 <growproc+0x5f>

801034bf <fork>:
{
801034bf:	55                   	push   %ebp
801034c0:	89 e5                	mov    %esp,%ebp
801034c2:	57                   	push   %edi
801034c3:	56                   	push   %esi
801034c4:	53                   	push   %ebx
801034c5:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801034c8:	e8 7a fe ff ff       	call   80103347 <myproc>
801034cd:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801034cf:	e8 de fc ff ff       	call   801031b2 <allocproc>
801034d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801034d7:	85 c0                	test   %eax,%eax
801034d9:	0f 84 e0 00 00 00    	je     801035bf <fork+0x100>
801034df:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801034e1:	83 ec 08             	sub    $0x8,%esp
801034e4:	ff 33                	pushl  (%ebx)
801034e6:	ff 73 04             	pushl  0x4(%ebx)
801034e9:	e8 bd 2f 00 00       	call   801064ab <copyuvm>
801034ee:	89 47 04             	mov    %eax,0x4(%edi)
801034f1:	83 c4 10             	add    $0x10,%esp
801034f4:	85 c0                	test   %eax,%eax
801034f6:	74 2a                	je     80103522 <fork+0x63>
  np->sz = curproc->sz;
801034f8:	8b 03                	mov    (%ebx),%eax
801034fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801034fd:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801034ff:	89 c8                	mov    %ecx,%eax
80103501:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103504:	8b 73 18             	mov    0x18(%ebx),%esi
80103507:	8b 79 18             	mov    0x18(%ecx),%edi
8010350a:	b9 13 00 00 00       	mov    $0x13,%ecx
8010350f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103511:	8b 40 18             	mov    0x18(%eax),%eax
80103514:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010351b:	be 00 00 00 00       	mov    $0x0,%esi
80103520:	eb 29                	jmp    8010354b <fork+0x8c>
    kfree(np->kstack);
80103522:	83 ec 0c             	sub    $0xc,%esp
80103525:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103528:	ff 73 08             	pushl  0x8(%ebx)
8010352b:	e8 74 ea ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80103530:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103537:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010353e:	83 c4 10             	add    $0x10,%esp
80103541:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103546:	eb 6d                	jmp    801035b5 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103548:	83 c6 01             	add    $0x1,%esi
8010354b:	83 fe 0f             	cmp    $0xf,%esi
8010354e:	7f 1d                	jg     8010356d <fork+0xae>
    if(curproc->ofile[i])
80103550:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103554:	85 c0                	test   %eax,%eax
80103556:	74 f0                	je     80103548 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103558:	83 ec 0c             	sub    $0xc,%esp
8010355b:	50                   	push   %eax
8010355c:	e8 2d d7 ff ff       	call   80100c8e <filedup>
80103561:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103564:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103568:	83 c4 10             	add    $0x10,%esp
8010356b:	eb db                	jmp    80103548 <fork+0x89>
  np->cwd = idup(curproc->cwd);
8010356d:	83 ec 0c             	sub    $0xc,%esp
80103570:	ff 73 68             	pushl  0x68(%ebx)
80103573:	e8 d9 df ff ff       	call   80101551 <idup>
80103578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010357b:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010357e:	83 c3 6c             	add    $0x6c,%ebx
80103581:	8d 47 6c             	lea    0x6c(%edi),%eax
80103584:	83 c4 0c             	add    $0xc,%esp
80103587:	6a 10                	push   $0x10
80103589:	53                   	push   %ebx
8010358a:	50                   	push   %eax
8010358b:	e8 d0 09 00 00       	call   80103f60 <safestrcpy>
  pid = np->pid;
80103590:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103593:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
8010359a:	e8 ae 07 00 00       	call   80103d4d <acquire>
  np->state = RUNNABLE;
8010359f:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801035a6:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801035ad:	e8 00 08 00 00       	call   80103db2 <release>
  return pid;
801035b2:	83 c4 10             	add    $0x10,%esp
}
801035b5:	89 d8                	mov    %ebx,%eax
801035b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801035ba:	5b                   	pop    %ebx
801035bb:	5e                   	pop    %esi
801035bc:	5f                   	pop    %edi
801035bd:	5d                   	pop    %ebp
801035be:	c3                   	ret    
    return -1;
801035bf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801035c4:	eb ef                	jmp    801035b5 <fork+0xf6>

801035c6 <scheduler>:
{
801035c6:	55                   	push   %ebp
801035c7:	89 e5                	mov    %esp,%ebp
801035c9:	56                   	push   %esi
801035ca:	53                   	push   %ebx
  struct cpu *c = mycpu();
801035cb:	e8 00 fd ff ff       	call   801032d0 <mycpu>
801035d0:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801035d2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801035d9:	00 00 00 
801035dc:	eb 5a                	jmp    80103638 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035de:	83 c3 7c             	add    $0x7c,%ebx
801035e1:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
801035e7:	73 3f                	jae    80103628 <scheduler+0x62>
      if(p->state != RUNNABLE)
801035e9:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035ed:	75 ef                	jne    801035de <scheduler+0x18>
      c->proc = p;
801035ef:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801035f5:	83 ec 0c             	sub    $0xc,%esp
801035f8:	53                   	push   %ebx
801035f9:	e8 ef 29 00 00       	call   80105fed <switchuvm>
      p->state = RUNNING;
801035fe:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103605:	83 c4 08             	add    $0x8,%esp
80103608:	ff 73 1c             	pushl  0x1c(%ebx)
8010360b:	8d 46 04             	lea    0x4(%esi),%eax
8010360e:	50                   	push   %eax
8010360f:	e8 9f 09 00 00       	call   80103fb3 <swtch>
      switchkvm();
80103614:	e8 c2 29 00 00       	call   80105fdb <switchkvm>
      c->proc = 0;
80103619:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103620:	00 00 00 
80103623:	83 c4 10             	add    $0x10,%esp
80103626:	eb b6                	jmp    801035de <scheduler+0x18>
    release(&ptable.lock);
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	68 40 eb 1b 80       	push   $0x801beb40
80103630:	e8 7d 07 00 00       	call   80103db2 <release>
    sti();
80103635:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103638:	fb                   	sti    
    acquire(&ptable.lock);
80103639:	83 ec 0c             	sub    $0xc,%esp
8010363c:	68 40 eb 1b 80       	push   $0x801beb40
80103641:	e8 07 07 00 00       	call   80103d4d <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103646:	83 c4 10             	add    $0x10,%esp
80103649:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
8010364e:	eb 91                	jmp    801035e1 <scheduler+0x1b>

80103650 <sched>:
{
80103650:	55                   	push   %ebp
80103651:	89 e5                	mov    %esp,%ebp
80103653:	56                   	push   %esi
80103654:	53                   	push   %ebx
  struct proc *p = myproc();
80103655:	e8 ed fc ff ff       	call   80103347 <myproc>
8010365a:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010365c:	83 ec 0c             	sub    $0xc,%esp
8010365f:	68 40 eb 1b 80       	push   $0x801beb40
80103664:	e8 a4 06 00 00       	call   80103d0d <holding>
80103669:	83 c4 10             	add    $0x10,%esp
8010366c:	85 c0                	test   %eax,%eax
8010366e:	74 4f                	je     801036bf <sched+0x6f>
  if(mycpu()->ncli != 1)
80103670:	e8 5b fc ff ff       	call   801032d0 <mycpu>
80103675:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010367c:	75 4e                	jne    801036cc <sched+0x7c>
  if(p->state == RUNNING)
8010367e:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103682:	74 55                	je     801036d9 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103684:	9c                   	pushf  
80103685:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103686:	f6 c4 02             	test   $0x2,%ah
80103689:	75 5b                	jne    801036e6 <sched+0x96>
  intena = mycpu()->intena;
8010368b:	e8 40 fc ff ff       	call   801032d0 <mycpu>
80103690:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103696:	e8 35 fc ff ff       	call   801032d0 <mycpu>
8010369b:	83 ec 08             	sub    $0x8,%esp
8010369e:	ff 70 04             	pushl  0x4(%eax)
801036a1:	83 c3 1c             	add    $0x1c,%ebx
801036a4:	53                   	push   %ebx
801036a5:	e8 09 09 00 00       	call   80103fb3 <swtch>
  mycpu()->intena = intena;
801036aa:	e8 21 fc ff ff       	call   801032d0 <mycpu>
801036af:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801036b5:	83 c4 10             	add    $0x10,%esp
801036b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036bb:	5b                   	pop    %ebx
801036bc:	5e                   	pop    %esi
801036bd:	5d                   	pop    %ebp
801036be:	c3                   	ret    
    panic("sched ptable.lock");
801036bf:	83 ec 0c             	sub    $0xc,%esp
801036c2:	68 f0 6b 10 80       	push   $0x80106bf0
801036c7:	e8 7c cc ff ff       	call   80100348 <panic>
    panic("sched locks");
801036cc:	83 ec 0c             	sub    $0xc,%esp
801036cf:	68 02 6c 10 80       	push   $0x80106c02
801036d4:	e8 6f cc ff ff       	call   80100348 <panic>
    panic("sched running");
801036d9:	83 ec 0c             	sub    $0xc,%esp
801036dc:	68 0e 6c 10 80       	push   $0x80106c0e
801036e1:	e8 62 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801036e6:	83 ec 0c             	sub    $0xc,%esp
801036e9:	68 1c 6c 10 80       	push   $0x80106c1c
801036ee:	e8 55 cc ff ff       	call   80100348 <panic>

801036f3 <exit>:
{
801036f3:	55                   	push   %ebp
801036f4:	89 e5                	mov    %esp,%ebp
801036f6:	56                   	push   %esi
801036f7:	53                   	push   %ebx
  struct proc *curproc = myproc();
801036f8:	e8 4a fc ff ff       	call   80103347 <myproc>
  if(curproc == initproc)
801036fd:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
80103703:	74 09                	je     8010370e <exit+0x1b>
80103705:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103707:	bb 00 00 00 00       	mov    $0x0,%ebx
8010370c:	eb 10                	jmp    8010371e <exit+0x2b>
    panic("init exiting");
8010370e:	83 ec 0c             	sub    $0xc,%esp
80103711:	68 30 6c 10 80       	push   $0x80106c30
80103716:	e8 2d cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010371b:	83 c3 01             	add    $0x1,%ebx
8010371e:	83 fb 0f             	cmp    $0xf,%ebx
80103721:	7f 1e                	jg     80103741 <exit+0x4e>
    if(curproc->ofile[fd]){
80103723:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	74 f0                	je     8010371b <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010372b:	83 ec 0c             	sub    $0xc,%esp
8010372e:	50                   	push   %eax
8010372f:	e8 9f d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103734:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010373b:	00 
8010373c:	83 c4 10             	add    $0x10,%esp
8010373f:	eb da                	jmp    8010371b <exit+0x28>
  begin_op();
80103741:	e8 b9 f1 ff ff       	call   801028ff <begin_op>
  iput(curproc->cwd);
80103746:	83 ec 0c             	sub    $0xc,%esp
80103749:	ff 76 68             	pushl  0x68(%esi)
8010374c:	e8 37 df ff ff       	call   80101688 <iput>
  end_op();
80103751:	e8 23 f2 ff ff       	call   80102979 <end_op>
  curproc->cwd = 0;
80103756:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010375d:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103764:	e8 e4 05 00 00       	call   80103d4d <acquire>
  wakeup1(curproc->parent);
80103769:	8b 46 14             	mov    0x14(%esi),%eax
8010376c:	e8 16 fa ff ff       	call   80103187 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103771:	83 c4 10             	add    $0x10,%esp
80103774:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103779:	eb 03                	jmp    8010377e <exit+0x8b>
8010377b:	83 c3 7c             	add    $0x7c,%ebx
8010377e:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103784:	73 1a                	jae    801037a0 <exit+0xad>
    if(p->parent == curproc){
80103786:	39 73 14             	cmp    %esi,0x14(%ebx)
80103789:	75 f0                	jne    8010377b <exit+0x88>
      p->parent = initproc;
8010378b:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80103790:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103793:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103797:	75 e2                	jne    8010377b <exit+0x88>
        wakeup1(initproc);
80103799:	e8 e9 f9 ff ff       	call   80103187 <wakeup1>
8010379e:	eb db                	jmp    8010377b <exit+0x88>
  curproc->state = ZOMBIE;
801037a0:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801037a7:	e8 a4 fe ff ff       	call   80103650 <sched>
  panic("zombie exit");
801037ac:	83 ec 0c             	sub    $0xc,%esp
801037af:	68 3d 6c 10 80       	push   $0x80106c3d
801037b4:	e8 8f cb ff ff       	call   80100348 <panic>

801037b9 <yield>:
{
801037b9:	55                   	push   %ebp
801037ba:	89 e5                	mov    %esp,%ebp
801037bc:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801037bf:	68 40 eb 1b 80       	push   $0x801beb40
801037c4:	e8 84 05 00 00       	call   80103d4d <acquire>
  myproc()->state = RUNNABLE;
801037c9:	e8 79 fb ff ff       	call   80103347 <myproc>
801037ce:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801037d5:	e8 76 fe ff ff       	call   80103650 <sched>
  release(&ptable.lock);
801037da:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801037e1:	e8 cc 05 00 00       	call   80103db2 <release>
}
801037e6:	83 c4 10             	add    $0x10,%esp
801037e9:	c9                   	leave  
801037ea:	c3                   	ret    

801037eb <sleep>:
{
801037eb:	55                   	push   %ebp
801037ec:	89 e5                	mov    %esp,%ebp
801037ee:	56                   	push   %esi
801037ef:	53                   	push   %ebx
801037f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801037f3:	e8 4f fb ff ff       	call   80103347 <myproc>
  if(p == 0)
801037f8:	85 c0                	test   %eax,%eax
801037fa:	74 66                	je     80103862 <sleep+0x77>
801037fc:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801037fe:	85 db                	test   %ebx,%ebx
80103800:	74 6d                	je     8010386f <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103802:	81 fb 40 eb 1b 80    	cmp    $0x801beb40,%ebx
80103808:	74 18                	je     80103822 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010380a:	83 ec 0c             	sub    $0xc,%esp
8010380d:	68 40 eb 1b 80       	push   $0x801beb40
80103812:	e8 36 05 00 00       	call   80103d4d <acquire>
    release(lk);
80103817:	89 1c 24             	mov    %ebx,(%esp)
8010381a:	e8 93 05 00 00       	call   80103db2 <release>
8010381f:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103822:	8b 45 08             	mov    0x8(%ebp),%eax
80103825:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103828:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010382f:	e8 1c fe ff ff       	call   80103650 <sched>
  p->chan = 0;
80103834:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010383b:	81 fb 40 eb 1b 80    	cmp    $0x801beb40,%ebx
80103841:	74 18                	je     8010385b <sleep+0x70>
    release(&ptable.lock);
80103843:	83 ec 0c             	sub    $0xc,%esp
80103846:	68 40 eb 1b 80       	push   $0x801beb40
8010384b:	e8 62 05 00 00       	call   80103db2 <release>
    acquire(lk);
80103850:	89 1c 24             	mov    %ebx,(%esp)
80103853:	e8 f5 04 00 00       	call   80103d4d <acquire>
80103858:	83 c4 10             	add    $0x10,%esp
}
8010385b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010385e:	5b                   	pop    %ebx
8010385f:	5e                   	pop    %esi
80103860:	5d                   	pop    %ebp
80103861:	c3                   	ret    
    panic("sleep");
80103862:	83 ec 0c             	sub    $0xc,%esp
80103865:	68 49 6c 10 80       	push   $0x80106c49
8010386a:	e8 d9 ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010386f:	83 ec 0c             	sub    $0xc,%esp
80103872:	68 4f 6c 10 80       	push   $0x80106c4f
80103877:	e8 cc ca ff ff       	call   80100348 <panic>

8010387c <wait>:
{
8010387c:	55                   	push   %ebp
8010387d:	89 e5                	mov    %esp,%ebp
8010387f:	56                   	push   %esi
80103880:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103881:	e8 c1 fa ff ff       	call   80103347 <myproc>
80103886:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103888:	83 ec 0c             	sub    $0xc,%esp
8010388b:	68 40 eb 1b 80       	push   $0x801beb40
80103890:	e8 b8 04 00 00       	call   80103d4d <acquire>
80103895:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103898:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010389d:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
801038a2:	eb 5b                	jmp    801038ff <wait+0x83>
        pid = p->pid;
801038a4:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801038a7:	83 ec 0c             	sub    $0xc,%esp
801038aa:	ff 73 08             	pushl  0x8(%ebx)
801038ad:	e8 f2 e6 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
801038b2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801038b9:	83 c4 04             	add    $0x4,%esp
801038bc:	ff 73 04             	pushl  0x4(%ebx)
801038bf:	e8 c6 2a 00 00       	call   8010638a <freevm>
        p->pid = 0;
801038c4:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801038cb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038d2:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038d6:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038dd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801038e4:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801038eb:	e8 c2 04 00 00       	call   80103db2 <release>
        return pid;
801038f0:	83 c4 10             	add    $0x10,%esp
}
801038f3:	89 f0                	mov    %esi,%eax
801038f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038f8:	5b                   	pop    %ebx
801038f9:	5e                   	pop    %esi
801038fa:	5d                   	pop    %ebp
801038fb:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038fc:	83 c3 7c             	add    $0x7c,%ebx
801038ff:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103905:	73 12                	jae    80103919 <wait+0x9d>
      if(p->parent != curproc)
80103907:	39 73 14             	cmp    %esi,0x14(%ebx)
8010390a:	75 f0                	jne    801038fc <wait+0x80>
      if(p->state == ZOMBIE){
8010390c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103910:	74 92                	je     801038a4 <wait+0x28>
      havekids = 1;
80103912:	b8 01 00 00 00       	mov    $0x1,%eax
80103917:	eb e3                	jmp    801038fc <wait+0x80>
    if(!havekids || curproc->killed){
80103919:	85 c0                	test   %eax,%eax
8010391b:	74 06                	je     80103923 <wait+0xa7>
8010391d:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103921:	74 17                	je     8010393a <wait+0xbe>
      release(&ptable.lock);
80103923:	83 ec 0c             	sub    $0xc,%esp
80103926:	68 40 eb 1b 80       	push   $0x801beb40
8010392b:	e8 82 04 00 00       	call   80103db2 <release>
      return -1;
80103930:	83 c4 10             	add    $0x10,%esp
80103933:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103938:	eb b9                	jmp    801038f3 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010393a:	83 ec 08             	sub    $0x8,%esp
8010393d:	68 40 eb 1b 80       	push   $0x801beb40
80103942:	56                   	push   %esi
80103943:	e8 a3 fe ff ff       	call   801037eb <sleep>
    havekids = 0;
80103948:	83 c4 10             	add    $0x10,%esp
8010394b:	e9 48 ff ff ff       	jmp    80103898 <wait+0x1c>

80103950 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103956:	68 40 eb 1b 80       	push   $0x801beb40
8010395b:	e8 ed 03 00 00       	call   80103d4d <acquire>
  wakeup1(chan);
80103960:	8b 45 08             	mov    0x8(%ebp),%eax
80103963:	e8 1f f8 ff ff       	call   80103187 <wakeup1>
  release(&ptable.lock);
80103968:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
8010396f:	e8 3e 04 00 00       	call   80103db2 <release>
}
80103974:	83 c4 10             	add    $0x10,%esp
80103977:	c9                   	leave  
80103978:	c3                   	ret    

80103979 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103979:	55                   	push   %ebp
8010397a:	89 e5                	mov    %esp,%ebp
8010397c:	53                   	push   %ebx
8010397d:	83 ec 10             	sub    $0x10,%esp
80103980:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103983:	68 40 eb 1b 80       	push   $0x801beb40
80103988:	e8 c0 03 00 00       	call   80103d4d <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010398d:	83 c4 10             	add    $0x10,%esp
80103990:	b8 74 eb 1b 80       	mov    $0x801beb74,%eax
80103995:	3d 74 0a 1c 80       	cmp    $0x801c0a74,%eax
8010399a:	73 3a                	jae    801039d6 <kill+0x5d>
    if(p->pid == pid){
8010399c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010399f:	74 05                	je     801039a6 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039a1:	83 c0 7c             	add    $0x7c,%eax
801039a4:	eb ef                	jmp    80103995 <kill+0x1c>
      p->killed = 1;
801039a6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801039ad:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801039b1:	74 1a                	je     801039cd <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801039b3:	83 ec 0c             	sub    $0xc,%esp
801039b6:	68 40 eb 1b 80       	push   $0x801beb40
801039bb:	e8 f2 03 00 00       	call   80103db2 <release>
      return 0;
801039c0:	83 c4 10             	add    $0x10,%esp
801039c3:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039cb:	c9                   	leave  
801039cc:	c3                   	ret    
        p->state = RUNNABLE;
801039cd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801039d4:	eb dd                	jmp    801039b3 <kill+0x3a>
  release(&ptable.lock);
801039d6:	83 ec 0c             	sub    $0xc,%esp
801039d9:	68 40 eb 1b 80       	push   $0x801beb40
801039de:	e8 cf 03 00 00       	call   80103db2 <release>
  return -1;
801039e3:	83 c4 10             	add    $0x10,%esp
801039e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039eb:	eb db                	jmp    801039c8 <kill+0x4f>

801039ed <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801039ed:	55                   	push   %ebp
801039ee:	89 e5                	mov    %esp,%ebp
801039f0:	56                   	push   %esi
801039f1:	53                   	push   %ebx
801039f2:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039f5:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
801039fa:	eb 33                	jmp    80103a2f <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801039fc:	b8 60 6c 10 80       	mov    $0x80106c60,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a01:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a04:	52                   	push   %edx
80103a05:	50                   	push   %eax
80103a06:	ff 73 10             	pushl  0x10(%ebx)
80103a09:	68 64 6c 10 80       	push   $0x80106c64
80103a0e:	e8 f8 cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a13:	83 c4 10             	add    $0x10,%esp
80103a16:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a1a:	74 39                	je     80103a55 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a1c:	83 ec 0c             	sub    $0xc,%esp
80103a1f:	68 db 6f 10 80       	push   $0x80106fdb
80103a24:	e8 e2 cb ff ff       	call   8010060b <cprintf>
80103a29:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a2c:	83 c3 7c             	add    $0x7c,%ebx
80103a2f:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103a35:	73 61                	jae    80103a98 <procdump+0xab>
    if(p->state == UNUSED)
80103a37:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a3a:	85 c0                	test   %eax,%eax
80103a3c:	74 ee                	je     80103a2c <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a3e:	83 f8 05             	cmp    $0x5,%eax
80103a41:	77 b9                	ja     801039fc <procdump+0xf>
80103a43:	8b 04 85 c0 6c 10 80 	mov    -0x7fef9340(,%eax,4),%eax
80103a4a:	85 c0                	test   %eax,%eax
80103a4c:	75 b3                	jne    80103a01 <procdump+0x14>
      state = "???";
80103a4e:	b8 60 6c 10 80       	mov    $0x80106c60,%eax
80103a53:	eb ac                	jmp    80103a01 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a55:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a58:	8b 40 0c             	mov    0xc(%eax),%eax
80103a5b:	83 c0 08             	add    $0x8,%eax
80103a5e:	83 ec 08             	sub    $0x8,%esp
80103a61:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a64:	52                   	push   %edx
80103a65:	50                   	push   %eax
80103a66:	e8 c1 01 00 00       	call   80103c2c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a6b:	83 c4 10             	add    $0x10,%esp
80103a6e:	be 00 00 00 00       	mov    $0x0,%esi
80103a73:	eb 14                	jmp    80103a89 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103a75:	83 ec 08             	sub    $0x8,%esp
80103a78:	50                   	push   %eax
80103a79:	68 a1 66 10 80       	push   $0x801066a1
80103a7e:	e8 88 cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a83:	83 c6 01             	add    $0x1,%esi
80103a86:	83 c4 10             	add    $0x10,%esp
80103a89:	83 fe 09             	cmp    $0x9,%esi
80103a8c:	7f 8e                	jg     80103a1c <procdump+0x2f>
80103a8e:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a92:	85 c0                	test   %eax,%eax
80103a94:	75 df                	jne    80103a75 <procdump+0x88>
80103a96:	eb 84                	jmp    80103a1c <procdump+0x2f>
  }
}
80103a98:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a9b:	5b                   	pop    %ebx
80103a9c:	5e                   	pop    %esi
80103a9d:	5d                   	pop    %ebp
80103a9e:	c3                   	ret    

80103a9f <dump_physmem>:

int 
dump_physmem(int *userFrames, int *userPids, int nframes)
{
80103a9f:	55                   	push   %ebp
80103aa0:	89 e5                	mov    %esp,%ebp
80103aa2:	56                   	push   %esi
80103aa3:	53                   	push   %ebx
80103aa4:	8b 75 08             	mov    0x8(%ebp),%esi
80103aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103aaa:	8b 55 10             	mov    0x10(%ebp),%edx
    if(nframes < 0 || userFrames == 0 || userPids == 0){
80103aad:	89 d0                	mov    %edx,%eax
80103aaf:	c1 e8 1f             	shr    $0x1f,%eax
80103ab2:	85 f6                	test   %esi,%esi
80103ab4:	0f 94 c1             	sete   %cl
80103ab7:	08 c1                	or     %al,%cl
80103ab9:	75 3d                	jne    80103af8 <dump_physmem+0x59>
80103abb:	85 db                	test   %ebx,%ebx
80103abd:	74 40                	je     80103aff <dump_physmem+0x60>
     return -1;
    }
    //cprintf("Inside dump_physmem %d,\n",nframes);
    //int fr[numframes];
    for(int i=0; i < nframes; i++)
80103abf:	b8 00 00 00 00       	mov    $0x0,%eax
80103ac4:	eb 0d                	jmp    80103ad3 <dump_physmem+0x34>
    {
      userFrames[i] = frames[i+65];
80103ac6:	8b 0c 85 84 eb 1a 80 	mov    -0x7fe5147c(,%eax,4),%ecx
80103acd:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
    for(int i=0; i < nframes; i++)
80103ad0:	83 c0 01             	add    $0x1,%eax
80103ad3:	39 d0                	cmp    %edx,%eax
80103ad5:	7c ef                	jl     80103ac6 <dump_physmem+0x27>
      //cprintf("%d,%x,%x\n",i,userFrames[i],frames[i]);
    }
    //userFrames = fr;
    for(int i=0; i < nframes; i++)
80103ad7:	b8 00 00 00 00       	mov    $0x0,%eax
80103adc:	eb 0d                	jmp    80103aeb <dump_physmem+0x4c>
    {
      userPids[i] = pid[i+65];
80103ade:	8b 0c 85 84 27 11 80 	mov    -0x7feed87c(,%eax,4),%ecx
80103ae5:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
    for(int i=0; i < nframes; i++)
80103ae8:	83 c0 01             	add    $0x1,%eax
80103aeb:	39 d0                	cmp    %edx,%eax
80103aed:	7c ef                	jl     80103ade <dump_physmem+0x3f>
      //cprintf("%d\n", pid[i]);
    }

    return 0;
80103aef:	b8 00 00 00 00       	mov    $0x0,%eax

}
80103af4:	5b                   	pop    %ebx
80103af5:	5e                   	pop    %esi
80103af6:	5d                   	pop    %ebp
80103af7:	c3                   	ret    
     return -1;
80103af8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103afd:	eb f5                	jmp    80103af4 <dump_physmem+0x55>
80103aff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b04:	eb ee                	jmp    80103af4 <dump_physmem+0x55>

80103b06 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103b06:	55                   	push   %ebp
80103b07:	89 e5                	mov    %esp,%ebp
80103b09:	53                   	push   %ebx
80103b0a:	83 ec 0c             	sub    $0xc,%esp
80103b0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103b10:	68 d8 6c 10 80       	push   $0x80106cd8
80103b15:	8d 43 04             	lea    0x4(%ebx),%eax
80103b18:	50                   	push   %eax
80103b19:	e8 f3 00 00 00       	call   80103c11 <initlock>
  lk->name = name;
80103b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b21:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b2a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b31:	83 c4 10             	add    $0x10,%esp
80103b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b37:	c9                   	leave  
80103b38:	c3                   	ret    

80103b39 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b39:	55                   	push   %ebp
80103b3a:	89 e5                	mov    %esp,%ebp
80103b3c:	56                   	push   %esi
80103b3d:	53                   	push   %ebx
80103b3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b41:	8d 73 04             	lea    0x4(%ebx),%esi
80103b44:	83 ec 0c             	sub    $0xc,%esp
80103b47:	56                   	push   %esi
80103b48:	e8 00 02 00 00       	call   80103d4d <acquire>
  while (lk->locked) {
80103b4d:	83 c4 10             	add    $0x10,%esp
80103b50:	eb 0d                	jmp    80103b5f <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b52:	83 ec 08             	sub    $0x8,%esp
80103b55:	56                   	push   %esi
80103b56:	53                   	push   %ebx
80103b57:	e8 8f fc ff ff       	call   801037eb <sleep>
80103b5c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b5f:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b62:	75 ee                	jne    80103b52 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b64:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b6a:	e8 d8 f7 ff ff       	call   80103347 <myproc>
80103b6f:	8b 40 10             	mov    0x10(%eax),%eax
80103b72:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b75:	83 ec 0c             	sub    $0xc,%esp
80103b78:	56                   	push   %esi
80103b79:	e8 34 02 00 00       	call   80103db2 <release>
}
80103b7e:	83 c4 10             	add    $0x10,%esp
80103b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b84:	5b                   	pop    %ebx
80103b85:	5e                   	pop    %esi
80103b86:	5d                   	pop    %ebp
80103b87:	c3                   	ret    

80103b88 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b88:	55                   	push   %ebp
80103b89:	89 e5                	mov    %esp,%ebp
80103b8b:	56                   	push   %esi
80103b8c:	53                   	push   %ebx
80103b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b90:	8d 73 04             	lea    0x4(%ebx),%esi
80103b93:	83 ec 0c             	sub    $0xc,%esp
80103b96:	56                   	push   %esi
80103b97:	e8 b1 01 00 00       	call   80103d4d <acquire>
  lk->locked = 0;
80103b9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ba2:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ba9:	89 1c 24             	mov    %ebx,(%esp)
80103bac:	e8 9f fd ff ff       	call   80103950 <wakeup>
  release(&lk->lk);
80103bb1:	89 34 24             	mov    %esi,(%esp)
80103bb4:	e8 f9 01 00 00       	call   80103db2 <release>
}
80103bb9:	83 c4 10             	add    $0x10,%esp
80103bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bbf:	5b                   	pop    %ebx
80103bc0:	5e                   	pop    %esi
80103bc1:	5d                   	pop    %ebp
80103bc2:	c3                   	ret    

80103bc3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bc3:	55                   	push   %ebp
80103bc4:	89 e5                	mov    %esp,%ebp
80103bc6:	56                   	push   %esi
80103bc7:	53                   	push   %ebx
80103bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103bcb:	8d 73 04             	lea    0x4(%ebx),%esi
80103bce:	83 ec 0c             	sub    $0xc,%esp
80103bd1:	56                   	push   %esi
80103bd2:	e8 76 01 00 00       	call   80103d4d <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bd7:	83 c4 10             	add    $0x10,%esp
80103bda:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bdd:	75 17                	jne    80103bf6 <holdingsleep+0x33>
80103bdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103be4:	83 ec 0c             	sub    $0xc,%esp
80103be7:	56                   	push   %esi
80103be8:	e8 c5 01 00 00       	call   80103db2 <release>
  return r;
}
80103bed:	89 d8                	mov    %ebx,%eax
80103bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bf2:	5b                   	pop    %ebx
80103bf3:	5e                   	pop    %esi
80103bf4:	5d                   	pop    %ebp
80103bf5:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103bf6:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103bf9:	e8 49 f7 ff ff       	call   80103347 <myproc>
80103bfe:	3b 58 10             	cmp    0x10(%eax),%ebx
80103c01:	74 07                	je     80103c0a <holdingsleep+0x47>
80103c03:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c08:	eb da                	jmp    80103be4 <holdingsleep+0x21>
80103c0a:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c0f:	eb d3                	jmp    80103be4 <holdingsleep+0x21>

80103c11 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103c11:	55                   	push   %ebp
80103c12:	89 e5                	mov    %esp,%ebp
80103c14:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103c17:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c1a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c2a:	5d                   	pop    %ebp
80103c2b:	c3                   	ret    

80103c2c <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c2c:	55                   	push   %ebp
80103c2d:	89 e5                	mov    %esp,%ebp
80103c2f:	53                   	push   %ebx
80103c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c33:	8b 45 08             	mov    0x8(%ebp),%eax
80103c36:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c39:	b8 00 00 00 00       	mov    $0x0,%eax
80103c3e:	83 f8 09             	cmp    $0x9,%eax
80103c41:	7f 25                	jg     80103c68 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c43:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c49:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c4f:	77 17                	ja     80103c68 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c51:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c54:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c57:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c59:	83 c0 01             	add    $0x1,%eax
80103c5c:	eb e0                	jmp    80103c3e <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c5e:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c65:	83 c0 01             	add    $0x1,%eax
80103c68:	83 f8 09             	cmp    $0x9,%eax
80103c6b:	7e f1                	jle    80103c5e <getcallerpcs+0x32>
}
80103c6d:	5b                   	pop    %ebx
80103c6e:	5d                   	pop    %ebp
80103c6f:	c3                   	ret    

80103c70 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c70:	55                   	push   %ebp
80103c71:	89 e5                	mov    %esp,%ebp
80103c73:	53                   	push   %ebx
80103c74:	83 ec 04             	sub    $0x4,%esp
80103c77:	9c                   	pushf  
80103c78:	5b                   	pop    %ebx
  asm volatile("cli");
80103c79:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c7a:	e8 51 f6 ff ff       	call   801032d0 <mycpu>
80103c7f:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c86:	74 12                	je     80103c9a <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c88:	e8 43 f6 ff ff       	call   801032d0 <mycpu>
80103c8d:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c94:	83 c4 04             	add    $0x4,%esp
80103c97:	5b                   	pop    %ebx
80103c98:	5d                   	pop    %ebp
80103c99:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c9a:	e8 31 f6 ff ff       	call   801032d0 <mycpu>
80103c9f:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ca5:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103cab:	eb db                	jmp    80103c88 <pushcli+0x18>

80103cad <popcli>:

void
popcli(void)
{
80103cad:	55                   	push   %ebp
80103cae:	89 e5                	mov    %esp,%ebp
80103cb0:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cb3:	9c                   	pushf  
80103cb4:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cb5:	f6 c4 02             	test   $0x2,%ah
80103cb8:	75 28                	jne    80103ce2 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103cba:	e8 11 f6 ff ff       	call   801032d0 <mycpu>
80103cbf:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cc5:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cc8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103cce:	85 d2                	test   %edx,%edx
80103cd0:	78 1d                	js     80103cef <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cd2:	e8 f9 f5 ff ff       	call   801032d0 <mycpu>
80103cd7:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cde:	74 1c                	je     80103cfc <popcli+0x4f>
    sti();
}
80103ce0:	c9                   	leave  
80103ce1:	c3                   	ret    
    panic("popcli - interruptible");
80103ce2:	83 ec 0c             	sub    $0xc,%esp
80103ce5:	68 e3 6c 10 80       	push   $0x80106ce3
80103cea:	e8 59 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103cef:	83 ec 0c             	sub    $0xc,%esp
80103cf2:	68 fa 6c 10 80       	push   $0x80106cfa
80103cf7:	e8 4c c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cfc:	e8 cf f5 ff ff       	call   801032d0 <mycpu>
80103d01:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103d08:	74 d6                	je     80103ce0 <popcli+0x33>
  asm volatile("sti");
80103d0a:	fb                   	sti    
}
80103d0b:	eb d3                	jmp    80103ce0 <popcli+0x33>

80103d0d <holding>:
{
80103d0d:	55                   	push   %ebp
80103d0e:	89 e5                	mov    %esp,%ebp
80103d10:	53                   	push   %ebx
80103d11:	83 ec 04             	sub    $0x4,%esp
80103d14:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103d17:	e8 54 ff ff ff       	call   80103c70 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d1c:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d1f:	75 12                	jne    80103d33 <holding+0x26>
80103d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d26:	e8 82 ff ff ff       	call   80103cad <popcli>
}
80103d2b:	89 d8                	mov    %ebx,%eax
80103d2d:	83 c4 04             	add    $0x4,%esp
80103d30:	5b                   	pop    %ebx
80103d31:	5d                   	pop    %ebp
80103d32:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d33:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d36:	e8 95 f5 ff ff       	call   801032d0 <mycpu>
80103d3b:	39 c3                	cmp    %eax,%ebx
80103d3d:	74 07                	je     80103d46 <holding+0x39>
80103d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d44:	eb e0                	jmp    80103d26 <holding+0x19>
80103d46:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d4b:	eb d9                	jmp    80103d26 <holding+0x19>

80103d4d <acquire>:
{
80103d4d:	55                   	push   %ebp
80103d4e:	89 e5                	mov    %esp,%ebp
80103d50:	53                   	push   %ebx
80103d51:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d54:	e8 17 ff ff ff       	call   80103c70 <pushcli>
  if(holding(lk))
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	ff 75 08             	pushl  0x8(%ebp)
80103d5f:	e8 a9 ff ff ff       	call   80103d0d <holding>
80103d64:	83 c4 10             	add    $0x10,%esp
80103d67:	85 c0                	test   %eax,%eax
80103d69:	75 3a                	jne    80103da5 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d6e:	b8 01 00 00 00       	mov    $0x1,%eax
80103d73:	f0 87 02             	lock xchg %eax,(%edx)
80103d76:	85 c0                	test   %eax,%eax
80103d78:	75 f1                	jne    80103d6b <acquire+0x1e>
  __sync_synchronize();
80103d7a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d82:	e8 49 f5 ff ff       	call   801032d0 <mycpu>
80103d87:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8d:	83 c0 0c             	add    $0xc,%eax
80103d90:	83 ec 08             	sub    $0x8,%esp
80103d93:	50                   	push   %eax
80103d94:	8d 45 08             	lea    0x8(%ebp),%eax
80103d97:	50                   	push   %eax
80103d98:	e8 8f fe ff ff       	call   80103c2c <getcallerpcs>
}
80103d9d:	83 c4 10             	add    $0x10,%esp
80103da0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103da3:	c9                   	leave  
80103da4:	c3                   	ret    
    panic("acquire");
80103da5:	83 ec 0c             	sub    $0xc,%esp
80103da8:	68 01 6d 10 80       	push   $0x80106d01
80103dad:	e8 96 c5 ff ff       	call   80100348 <panic>

80103db2 <release>:
{
80103db2:	55                   	push   %ebp
80103db3:	89 e5                	mov    %esp,%ebp
80103db5:	53                   	push   %ebx
80103db6:	83 ec 10             	sub    $0x10,%esp
80103db9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103dbc:	53                   	push   %ebx
80103dbd:	e8 4b ff ff ff       	call   80103d0d <holding>
80103dc2:	83 c4 10             	add    $0x10,%esp
80103dc5:	85 c0                	test   %eax,%eax
80103dc7:	74 23                	je     80103dec <release+0x3a>
  lk->pcs[0] = 0;
80103dc9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103dd0:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dd7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ddc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103de2:	e8 c6 fe ff ff       	call   80103cad <popcli>
}
80103de7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dea:	c9                   	leave  
80103deb:	c3                   	ret    
    panic("release");
80103dec:	83 ec 0c             	sub    $0xc,%esp
80103def:	68 09 6d 10 80       	push   $0x80106d09
80103df4:	e8 4f c5 ff ff       	call   80100348 <panic>

80103df9 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103df9:	55                   	push   %ebp
80103dfa:	89 e5                	mov    %esp,%ebp
80103dfc:	57                   	push   %edi
80103dfd:	53                   	push   %ebx
80103dfe:	8b 55 08             	mov    0x8(%ebp),%edx
80103e01:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103e04:	f6 c2 03             	test   $0x3,%dl
80103e07:	75 05                	jne    80103e0e <memset+0x15>
80103e09:	f6 c1 03             	test   $0x3,%cl
80103e0c:	74 0e                	je     80103e1c <memset+0x23>
  asm volatile("cld; rep stosb" :
80103e0e:	89 d7                	mov    %edx,%edi
80103e10:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e13:	fc                   	cld    
80103e14:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103e16:	89 d0                	mov    %edx,%eax
80103e18:	5b                   	pop    %ebx
80103e19:	5f                   	pop    %edi
80103e1a:	5d                   	pop    %ebp
80103e1b:	c3                   	ret    
    c &= 0xFF;
80103e1c:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e20:	c1 e9 02             	shr    $0x2,%ecx
80103e23:	89 f8                	mov    %edi,%eax
80103e25:	c1 e0 18             	shl    $0x18,%eax
80103e28:	89 fb                	mov    %edi,%ebx
80103e2a:	c1 e3 10             	shl    $0x10,%ebx
80103e2d:	09 d8                	or     %ebx,%eax
80103e2f:	89 fb                	mov    %edi,%ebx
80103e31:	c1 e3 08             	shl    $0x8,%ebx
80103e34:	09 d8                	or     %ebx,%eax
80103e36:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103e38:	89 d7                	mov    %edx,%edi
80103e3a:	fc                   	cld    
80103e3b:	f3 ab                	rep stos %eax,%es:(%edi)
80103e3d:	eb d7                	jmp    80103e16 <memset+0x1d>

80103e3f <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e3f:	55                   	push   %ebp
80103e40:	89 e5                	mov    %esp,%ebp
80103e42:	56                   	push   %esi
80103e43:	53                   	push   %ebx
80103e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e47:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e4a:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e4d:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e50:	85 c0                	test   %eax,%eax
80103e52:	74 1c                	je     80103e70 <memcmp+0x31>
    if(*s1 != *s2)
80103e54:	0f b6 01             	movzbl (%ecx),%eax
80103e57:	0f b6 1a             	movzbl (%edx),%ebx
80103e5a:	38 d8                	cmp    %bl,%al
80103e5c:	75 0a                	jne    80103e68 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e5e:	83 c1 01             	add    $0x1,%ecx
80103e61:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e64:	89 f0                	mov    %esi,%eax
80103e66:	eb e5                	jmp    80103e4d <memcmp+0xe>
      return *s1 - *s2;
80103e68:	0f b6 c0             	movzbl %al,%eax
80103e6b:	0f b6 db             	movzbl %bl,%ebx
80103e6e:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e70:	5b                   	pop    %ebx
80103e71:	5e                   	pop    %esi
80103e72:	5d                   	pop    %ebp
80103e73:	c3                   	ret    

80103e74 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e74:	55                   	push   %ebp
80103e75:	89 e5                	mov    %esp,%ebp
80103e77:	56                   	push   %esi
80103e78:	53                   	push   %ebx
80103e79:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e7f:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e82:	39 c1                	cmp    %eax,%ecx
80103e84:	73 3a                	jae    80103ec0 <memmove+0x4c>
80103e86:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e89:	39 c3                	cmp    %eax,%ebx
80103e8b:	76 37                	jbe    80103ec4 <memmove+0x50>
    s += n;
    d += n;
80103e8d:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e90:	eb 0d                	jmp    80103e9f <memmove+0x2b>
      *--d = *--s;
80103e92:	83 eb 01             	sub    $0x1,%ebx
80103e95:	83 e9 01             	sub    $0x1,%ecx
80103e98:	0f b6 13             	movzbl (%ebx),%edx
80103e9b:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e9d:	89 f2                	mov    %esi,%edx
80103e9f:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ea2:	85 d2                	test   %edx,%edx
80103ea4:	75 ec                	jne    80103e92 <memmove+0x1e>
80103ea6:	eb 14                	jmp    80103ebc <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103ea8:	0f b6 11             	movzbl (%ecx),%edx
80103eab:	88 13                	mov    %dl,(%ebx)
80103ead:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103eb0:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103eb3:	89 f2                	mov    %esi,%edx
80103eb5:	8d 72 ff             	lea    -0x1(%edx),%esi
80103eb8:	85 d2                	test   %edx,%edx
80103eba:	75 ec                	jne    80103ea8 <memmove+0x34>

  return dst;
}
80103ebc:	5b                   	pop    %ebx
80103ebd:	5e                   	pop    %esi
80103ebe:	5d                   	pop    %ebp
80103ebf:	c3                   	ret    
80103ec0:	89 c3                	mov    %eax,%ebx
80103ec2:	eb f1                	jmp    80103eb5 <memmove+0x41>
80103ec4:	89 c3                	mov    %eax,%ebx
80103ec6:	eb ed                	jmp    80103eb5 <memmove+0x41>

80103ec8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103ec8:	55                   	push   %ebp
80103ec9:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103ecb:	ff 75 10             	pushl  0x10(%ebp)
80103ece:	ff 75 0c             	pushl  0xc(%ebp)
80103ed1:	ff 75 08             	pushl  0x8(%ebp)
80103ed4:	e8 9b ff ff ff       	call   80103e74 <memmove>
}
80103ed9:	c9                   	leave  
80103eda:	c3                   	ret    

80103edb <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103edb:	55                   	push   %ebp
80103edc:	89 e5                	mov    %esp,%ebp
80103ede:	53                   	push   %ebx
80103edf:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ee5:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103ee8:	eb 09                	jmp    80103ef3 <strncmp+0x18>
    n--, p++, q++;
80103eea:	83 e8 01             	sub    $0x1,%eax
80103eed:	83 c2 01             	add    $0x1,%edx
80103ef0:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103ef3:	85 c0                	test   %eax,%eax
80103ef5:	74 0b                	je     80103f02 <strncmp+0x27>
80103ef7:	0f b6 1a             	movzbl (%edx),%ebx
80103efa:	84 db                	test   %bl,%bl
80103efc:	74 04                	je     80103f02 <strncmp+0x27>
80103efe:	3a 19                	cmp    (%ecx),%bl
80103f00:	74 e8                	je     80103eea <strncmp+0xf>
  if(n == 0)
80103f02:	85 c0                	test   %eax,%eax
80103f04:	74 0b                	je     80103f11 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103f06:	0f b6 02             	movzbl (%edx),%eax
80103f09:	0f b6 11             	movzbl (%ecx),%edx
80103f0c:	29 d0                	sub    %edx,%eax
}
80103f0e:	5b                   	pop    %ebx
80103f0f:	5d                   	pop    %ebp
80103f10:	c3                   	ret    
    return 0;
80103f11:	b8 00 00 00 00       	mov    $0x0,%eax
80103f16:	eb f6                	jmp    80103f0e <strncmp+0x33>

80103f18 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f18:	55                   	push   %ebp
80103f19:	89 e5                	mov    %esp,%ebp
80103f1b:	57                   	push   %edi
80103f1c:	56                   	push   %esi
80103f1d:	53                   	push   %ebx
80103f1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f21:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f24:	8b 45 08             	mov    0x8(%ebp),%eax
80103f27:	eb 04                	jmp    80103f2d <strncpy+0x15>
80103f29:	89 fb                	mov    %edi,%ebx
80103f2b:	89 f0                	mov    %esi,%eax
80103f2d:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f30:	85 c9                	test   %ecx,%ecx
80103f32:	7e 1d                	jle    80103f51 <strncpy+0x39>
80103f34:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f37:	8d 70 01             	lea    0x1(%eax),%esi
80103f3a:	0f b6 1b             	movzbl (%ebx),%ebx
80103f3d:	88 18                	mov    %bl,(%eax)
80103f3f:	89 d1                	mov    %edx,%ecx
80103f41:	84 db                	test   %bl,%bl
80103f43:	75 e4                	jne    80103f29 <strncpy+0x11>
80103f45:	89 f0                	mov    %esi,%eax
80103f47:	eb 08                	jmp    80103f51 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f49:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f4c:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f4e:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f51:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f54:	85 d2                	test   %edx,%edx
80103f56:	7f f1                	jg     80103f49 <strncpy+0x31>
  return os;
}
80103f58:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5b:	5b                   	pop    %ebx
80103f5c:	5e                   	pop    %esi
80103f5d:	5f                   	pop    %edi
80103f5e:	5d                   	pop    %ebp
80103f5f:	c3                   	ret    

80103f60 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f60:	55                   	push   %ebp
80103f61:	89 e5                	mov    %esp,%ebp
80103f63:	57                   	push   %edi
80103f64:	56                   	push   %esi
80103f65:	53                   	push   %ebx
80103f66:	8b 45 08             	mov    0x8(%ebp),%eax
80103f69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f6c:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f6f:	85 d2                	test   %edx,%edx
80103f71:	7e 23                	jle    80103f96 <safestrcpy+0x36>
80103f73:	89 c1                	mov    %eax,%ecx
80103f75:	eb 04                	jmp    80103f7b <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f77:	89 fb                	mov    %edi,%ebx
80103f79:	89 f1                	mov    %esi,%ecx
80103f7b:	83 ea 01             	sub    $0x1,%edx
80103f7e:	85 d2                	test   %edx,%edx
80103f80:	7e 11                	jle    80103f93 <safestrcpy+0x33>
80103f82:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f85:	8d 71 01             	lea    0x1(%ecx),%esi
80103f88:	0f b6 1b             	movzbl (%ebx),%ebx
80103f8b:	88 19                	mov    %bl,(%ecx)
80103f8d:	84 db                	test   %bl,%bl
80103f8f:	75 e6                	jne    80103f77 <safestrcpy+0x17>
80103f91:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f93:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f96:	5b                   	pop    %ebx
80103f97:	5e                   	pop    %esi
80103f98:	5f                   	pop    %edi
80103f99:	5d                   	pop    %ebp
80103f9a:	c3                   	ret    

80103f9b <strlen>:

int
strlen(const char *s)
{
80103f9b:	55                   	push   %ebp
80103f9c:	89 e5                	mov    %esp,%ebp
80103f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80103fa6:	eb 03                	jmp    80103fab <strlen+0x10>
80103fa8:	83 c0 01             	add    $0x1,%eax
80103fab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103faf:	75 f7                	jne    80103fa8 <strlen+0xd>
    ;
  return n;
}
80103fb1:	5d                   	pop    %ebp
80103fb2:	c3                   	ret    

80103fb3 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103fb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103fb7:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fbb:	55                   	push   %ebp
  pushl %ebx
80103fbc:	53                   	push   %ebx
  pushl %esi
80103fbd:	56                   	push   %esi
  pushl %edi
80103fbe:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fbf:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fc1:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fc3:	5f                   	pop    %edi
  popl %esi
80103fc4:	5e                   	pop    %esi
  popl %ebx
80103fc5:	5b                   	pop    %ebx
  popl %ebp
80103fc6:	5d                   	pop    %ebp
  ret
80103fc7:	c3                   	ret    

80103fc8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	53                   	push   %ebx
80103fcc:	83 ec 04             	sub    $0x4,%esp
80103fcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fd2:	e8 70 f3 ff ff       	call   80103347 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fd7:	8b 00                	mov    (%eax),%eax
80103fd9:	39 d8                	cmp    %ebx,%eax
80103fdb:	76 19                	jbe    80103ff6 <fetchint+0x2e>
80103fdd:	8d 53 04             	lea    0x4(%ebx),%edx
80103fe0:	39 d0                	cmp    %edx,%eax
80103fe2:	72 19                	jb     80103ffd <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103fe4:	8b 13                	mov    (%ebx),%edx
80103fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe9:	89 10                	mov    %edx,(%eax)
  return 0;
80103feb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ff0:	83 c4 04             	add    $0x4,%esp
80103ff3:	5b                   	pop    %ebx
80103ff4:	5d                   	pop    %ebp
80103ff5:	c3                   	ret    
    return -1;
80103ff6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffb:	eb f3                	jmp    80103ff0 <fetchint+0x28>
80103ffd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104002:	eb ec                	jmp    80103ff0 <fetchint+0x28>

80104004 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104004:	55                   	push   %ebp
80104005:	89 e5                	mov    %esp,%ebp
80104007:	53                   	push   %ebx
80104008:	83 ec 04             	sub    $0x4,%esp
8010400b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010400e:	e8 34 f3 ff ff       	call   80103347 <myproc>

  if(addr >= curproc->sz)
80104013:	39 18                	cmp    %ebx,(%eax)
80104015:	76 26                	jbe    8010403d <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80104017:	8b 55 0c             	mov    0xc(%ebp),%edx
8010401a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010401c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010401e:	89 d8                	mov    %ebx,%eax
80104020:	39 d0                	cmp    %edx,%eax
80104022:	73 0e                	jae    80104032 <fetchstr+0x2e>
    if(*s == 0)
80104024:	80 38 00             	cmpb   $0x0,(%eax)
80104027:	74 05                	je     8010402e <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104029:	83 c0 01             	add    $0x1,%eax
8010402c:	eb f2                	jmp    80104020 <fetchstr+0x1c>
      return s - *pp;
8010402e:	29 d8                	sub    %ebx,%eax
80104030:	eb 05                	jmp    80104037 <fetchstr+0x33>
  }
  return -1;
80104032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104037:	83 c4 04             	add    $0x4,%esp
8010403a:	5b                   	pop    %ebx
8010403b:	5d                   	pop    %ebp
8010403c:	c3                   	ret    
    return -1;
8010403d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104042:	eb f3                	jmp    80104037 <fetchstr+0x33>

80104044 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104044:	55                   	push   %ebp
80104045:	89 e5                	mov    %esp,%ebp
80104047:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010404a:	e8 f8 f2 ff ff       	call   80103347 <myproc>
8010404f:	8b 50 18             	mov    0x18(%eax),%edx
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	c1 e0 02             	shl    $0x2,%eax
80104058:	03 42 44             	add    0x44(%edx),%eax
8010405b:	83 ec 08             	sub    $0x8,%esp
8010405e:	ff 75 0c             	pushl  0xc(%ebp)
80104061:	83 c0 04             	add    $0x4,%eax
80104064:	50                   	push   %eax
80104065:	e8 5e ff ff ff       	call   80103fc8 <fetchint>
}
8010406a:	c9                   	leave  
8010406b:	c3                   	ret    

8010406c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010406c:	55                   	push   %ebp
8010406d:	89 e5                	mov    %esp,%ebp
8010406f:	56                   	push   %esi
80104070:	53                   	push   %ebx
80104071:	83 ec 10             	sub    $0x10,%esp
80104074:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104077:	e8 cb f2 ff ff       	call   80103347 <myproc>
8010407c:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010407e:	83 ec 08             	sub    $0x8,%esp
80104081:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104084:	50                   	push   %eax
80104085:	ff 75 08             	pushl  0x8(%ebp)
80104088:	e8 b7 ff ff ff       	call   80104044 <argint>
8010408d:	83 c4 10             	add    $0x10,%esp
80104090:	85 c0                	test   %eax,%eax
80104092:	78 24                	js     801040b8 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104094:	85 db                	test   %ebx,%ebx
80104096:	78 27                	js     801040bf <argptr+0x53>
80104098:	8b 16                	mov    (%esi),%edx
8010409a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409d:	39 c2                	cmp    %eax,%edx
8010409f:	76 25                	jbe    801040c6 <argptr+0x5a>
801040a1:	01 c3                	add    %eax,%ebx
801040a3:	39 da                	cmp    %ebx,%edx
801040a5:	72 26                	jb     801040cd <argptr+0x61>
    return -1;
  *pp = (char*)i;
801040a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801040aa:	89 02                	mov    %eax,(%edx)
  return 0;
801040ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040b4:	5b                   	pop    %ebx
801040b5:	5e                   	pop    %esi
801040b6:	5d                   	pop    %ebp
801040b7:	c3                   	ret    
    return -1;
801040b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040bd:	eb f2                	jmp    801040b1 <argptr+0x45>
    return -1;
801040bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c4:	eb eb                	jmp    801040b1 <argptr+0x45>
801040c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cb:	eb e4                	jmp    801040b1 <argptr+0x45>
801040cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d2:	eb dd                	jmp    801040b1 <argptr+0x45>

801040d4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040d4:	55                   	push   %ebp
801040d5:	89 e5                	mov    %esp,%ebp
801040d7:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040da:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040dd:	50                   	push   %eax
801040de:	ff 75 08             	pushl  0x8(%ebp)
801040e1:	e8 5e ff ff ff       	call   80104044 <argint>
801040e6:	83 c4 10             	add    $0x10,%esp
801040e9:	85 c0                	test   %eax,%eax
801040eb:	78 13                	js     80104100 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801040ed:	83 ec 08             	sub    $0x8,%esp
801040f0:	ff 75 0c             	pushl  0xc(%ebp)
801040f3:	ff 75 f4             	pushl  -0xc(%ebp)
801040f6:	e8 09 ff ff ff       	call   80104004 <fetchstr>
801040fb:	83 c4 10             	add    $0x10,%esp
}
801040fe:	c9                   	leave  
801040ff:	c3                   	ret    
    return -1;
80104100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104105:	eb f7                	jmp    801040fe <argstr+0x2a>

80104107 <syscall>:
[SYS_dump_physmem]    sys_dump_physmem,
};

void
syscall(void)
{
80104107:	55                   	push   %ebp
80104108:	89 e5                	mov    %esp,%ebp
8010410a:	53                   	push   %ebx
8010410b:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010410e:	e8 34 f2 ff ff       	call   80103347 <myproc>
80104113:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104115:	8b 40 18             	mov    0x18(%eax),%eax
80104118:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010411b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010411e:	83 fa 15             	cmp    $0x15,%edx
80104121:	77 18                	ja     8010413b <syscall+0x34>
80104123:	8b 14 85 40 6d 10 80 	mov    -0x7fef92c0(,%eax,4),%edx
8010412a:	85 d2                	test   %edx,%edx
8010412c:	74 0d                	je     8010413b <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
8010412e:	ff d2                	call   *%edx
80104130:	8b 53 18             	mov    0x18(%ebx),%edx
80104133:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104139:	c9                   	leave  
8010413a:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010413b:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010413e:	50                   	push   %eax
8010413f:	52                   	push   %edx
80104140:	ff 73 10             	pushl  0x10(%ebx)
80104143:	68 11 6d 10 80       	push   $0x80106d11
80104148:	e8 be c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
8010414d:	8b 43 18             	mov    0x18(%ebx),%eax
80104150:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104157:	83 c4 10             	add    $0x10,%esp
}
8010415a:	eb da                	jmp    80104136 <syscall+0x2f>

8010415c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010415c:	55                   	push   %ebp
8010415d:	89 e5                	mov    %esp,%ebp
8010415f:	56                   	push   %esi
80104160:	53                   	push   %ebx
80104161:	83 ec 18             	sub    $0x18,%esp
80104164:	89 d6                	mov    %edx,%esi
80104166:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104168:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010416b:	52                   	push   %edx
8010416c:	50                   	push   %eax
8010416d:	e8 d2 fe ff ff       	call   80104044 <argint>
80104172:	83 c4 10             	add    $0x10,%esp
80104175:	85 c0                	test   %eax,%eax
80104177:	78 2e                	js     801041a7 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104179:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010417d:	77 2f                	ja     801041ae <argfd+0x52>
8010417f:	e8 c3 f1 ff ff       	call   80103347 <myproc>
80104184:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104187:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
8010418b:	85 c0                	test   %eax,%eax
8010418d:	74 26                	je     801041b5 <argfd+0x59>
    return -1;
  if(pfd)
8010418f:	85 f6                	test   %esi,%esi
80104191:	74 02                	je     80104195 <argfd+0x39>
    *pfd = fd;
80104193:	89 16                	mov    %edx,(%esi)
  if(pf)
80104195:	85 db                	test   %ebx,%ebx
80104197:	74 23                	je     801041bc <argfd+0x60>
    *pf = f;
80104199:	89 03                	mov    %eax,(%ebx)
  return 0;
8010419b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a3:	5b                   	pop    %ebx
801041a4:	5e                   	pop    %esi
801041a5:	5d                   	pop    %ebp
801041a6:	c3                   	ret    
    return -1;
801041a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ac:	eb f2                	jmp    801041a0 <argfd+0x44>
    return -1;
801041ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b3:	eb eb                	jmp    801041a0 <argfd+0x44>
801041b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ba:	eb e4                	jmp    801041a0 <argfd+0x44>
  return 0;
801041bc:	b8 00 00 00 00       	mov    $0x0,%eax
801041c1:	eb dd                	jmp    801041a0 <argfd+0x44>

801041c3 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041c3:	55                   	push   %ebp
801041c4:	89 e5                	mov    %esp,%ebp
801041c6:	53                   	push   %ebx
801041c7:	83 ec 04             	sub    $0x4,%esp
801041ca:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041cc:	e8 76 f1 ff ff       	call   80103347 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041d1:	ba 00 00 00 00       	mov    $0x0,%edx
801041d6:	83 fa 0f             	cmp    $0xf,%edx
801041d9:	7f 18                	jg     801041f3 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801041db:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801041e0:	74 05                	je     801041e7 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801041e2:	83 c2 01             	add    $0x1,%edx
801041e5:	eb ef                	jmp    801041d6 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801041e7:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801041eb:	89 d0                	mov    %edx,%eax
801041ed:	83 c4 04             	add    $0x4,%esp
801041f0:	5b                   	pop    %ebx
801041f1:	5d                   	pop    %ebp
801041f2:	c3                   	ret    
  return -1;
801041f3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801041f8:	eb f1                	jmp    801041eb <fdalloc+0x28>

801041fa <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801041fa:	55                   	push   %ebp
801041fb:	89 e5                	mov    %esp,%ebp
801041fd:	56                   	push   %esi
801041fe:	53                   	push   %ebx
801041ff:	83 ec 10             	sub    $0x10,%esp
80104202:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104204:	b8 20 00 00 00       	mov    $0x20,%eax
80104209:	89 c6                	mov    %eax,%esi
8010420b:	39 43 58             	cmp    %eax,0x58(%ebx)
8010420e:	76 2e                	jbe    8010423e <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104210:	6a 10                	push   $0x10
80104212:	50                   	push   %eax
80104213:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104216:	50                   	push   %eax
80104217:	53                   	push   %ebx
80104218:	e8 56 d5 ff ff       	call   80101773 <readi>
8010421d:	83 c4 10             	add    $0x10,%esp
80104220:	83 f8 10             	cmp    $0x10,%eax
80104223:	75 0c                	jne    80104231 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104225:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010422a:	75 1e                	jne    8010424a <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010422c:	8d 46 10             	lea    0x10(%esi),%eax
8010422f:	eb d8                	jmp    80104209 <isdirempty+0xf>
      panic("isdirempty: readi");
80104231:	83 ec 0c             	sub    $0xc,%esp
80104234:	68 9c 6d 10 80       	push   $0x80106d9c
80104239:	e8 0a c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
8010423e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104243:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104246:	5b                   	pop    %ebx
80104247:	5e                   	pop    %esi
80104248:	5d                   	pop    %ebp
80104249:	c3                   	ret    
      return 0;
8010424a:	b8 00 00 00 00       	mov    $0x0,%eax
8010424f:	eb f2                	jmp    80104243 <isdirempty+0x49>

80104251 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104251:	55                   	push   %ebp
80104252:	89 e5                	mov    %esp,%ebp
80104254:	57                   	push   %edi
80104255:	56                   	push   %esi
80104256:	53                   	push   %ebx
80104257:	83 ec 44             	sub    $0x44,%esp
8010425a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
8010425d:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104260:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104263:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104266:	52                   	push   %edx
80104267:	50                   	push   %eax
80104268:	e8 8c d9 ff ff       	call   80101bf9 <nameiparent>
8010426d:	89 c6                	mov    %eax,%esi
8010426f:	83 c4 10             	add    $0x10,%esp
80104272:	85 c0                	test   %eax,%eax
80104274:	0f 84 3a 01 00 00    	je     801043b4 <create+0x163>
    return 0;
  ilock(dp);
8010427a:	83 ec 0c             	sub    $0xc,%esp
8010427d:	50                   	push   %eax
8010427e:	e8 fe d2 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104283:	83 c4 0c             	add    $0xc,%esp
80104286:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104289:	50                   	push   %eax
8010428a:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010428d:	50                   	push   %eax
8010428e:	56                   	push   %esi
8010428f:	e8 1c d7 ff ff       	call   801019b0 <dirlookup>
80104294:	89 c3                	mov    %eax,%ebx
80104296:	83 c4 10             	add    $0x10,%esp
80104299:	85 c0                	test   %eax,%eax
8010429b:	74 3f                	je     801042dc <create+0x8b>
    iunlockput(dp);
8010429d:	83 ec 0c             	sub    $0xc,%esp
801042a0:	56                   	push   %esi
801042a1:	e8 82 d4 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
801042a6:	89 1c 24             	mov    %ebx,(%esp)
801042a9:	e8 d3 d2 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042ae:	83 c4 10             	add    $0x10,%esp
801042b1:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801042b6:	75 11                	jne    801042c9 <create+0x78>
801042b8:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042bd:	75 0a                	jne    801042c9 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042bf:	89 d8                	mov    %ebx,%eax
801042c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042c4:	5b                   	pop    %ebx
801042c5:	5e                   	pop    %esi
801042c6:	5f                   	pop    %edi
801042c7:	5d                   	pop    %ebp
801042c8:	c3                   	ret    
    iunlockput(ip);
801042c9:	83 ec 0c             	sub    $0xc,%esp
801042cc:	53                   	push   %ebx
801042cd:	e8 56 d4 ff ff       	call   80101728 <iunlockput>
    return 0;
801042d2:	83 c4 10             	add    $0x10,%esp
801042d5:	bb 00 00 00 00       	mov    $0x0,%ebx
801042da:	eb e3                	jmp    801042bf <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801042dc:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801042e0:	83 ec 08             	sub    $0x8,%esp
801042e3:	50                   	push   %eax
801042e4:	ff 36                	pushl  (%esi)
801042e6:	e8 93 d0 ff ff       	call   8010137e <ialloc>
801042eb:	89 c3                	mov    %eax,%ebx
801042ed:	83 c4 10             	add    $0x10,%esp
801042f0:	85 c0                	test   %eax,%eax
801042f2:	74 55                	je     80104349 <create+0xf8>
  ilock(ip);
801042f4:	83 ec 0c             	sub    $0xc,%esp
801042f7:	50                   	push   %eax
801042f8:	e8 84 d2 ff ff       	call   80101581 <ilock>
  ip->major = major;
801042fd:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104301:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104305:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104309:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
8010430f:	89 1c 24             	mov    %ebx,(%esp)
80104312:	e8 09 d1 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104317:	83 c4 10             	add    $0x10,%esp
8010431a:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010431f:	74 35                	je     80104356 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104321:	83 ec 04             	sub    $0x4,%esp
80104324:	ff 73 04             	pushl  0x4(%ebx)
80104327:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010432a:	50                   	push   %eax
8010432b:	56                   	push   %esi
8010432c:	e8 ff d7 ff ff       	call   80101b30 <dirlink>
80104331:	83 c4 10             	add    $0x10,%esp
80104334:	85 c0                	test   %eax,%eax
80104336:	78 6f                	js     801043a7 <create+0x156>
  iunlockput(dp);
80104338:	83 ec 0c             	sub    $0xc,%esp
8010433b:	56                   	push   %esi
8010433c:	e8 e7 d3 ff ff       	call   80101728 <iunlockput>
  return ip;
80104341:	83 c4 10             	add    $0x10,%esp
80104344:	e9 76 ff ff ff       	jmp    801042bf <create+0x6e>
    panic("create: ialloc");
80104349:	83 ec 0c             	sub    $0xc,%esp
8010434c:	68 ae 6d 10 80       	push   $0x80106dae
80104351:	e8 f2 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104356:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010435a:	83 c0 01             	add    $0x1,%eax
8010435d:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104361:	83 ec 0c             	sub    $0xc,%esp
80104364:	56                   	push   %esi
80104365:	e8 b6 d0 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010436a:	83 c4 0c             	add    $0xc,%esp
8010436d:	ff 73 04             	pushl  0x4(%ebx)
80104370:	68 be 6d 10 80       	push   $0x80106dbe
80104375:	53                   	push   %ebx
80104376:	e8 b5 d7 ff ff       	call   80101b30 <dirlink>
8010437b:	83 c4 10             	add    $0x10,%esp
8010437e:	85 c0                	test   %eax,%eax
80104380:	78 18                	js     8010439a <create+0x149>
80104382:	83 ec 04             	sub    $0x4,%esp
80104385:	ff 76 04             	pushl  0x4(%esi)
80104388:	68 bd 6d 10 80       	push   $0x80106dbd
8010438d:	53                   	push   %ebx
8010438e:	e8 9d d7 ff ff       	call   80101b30 <dirlink>
80104393:	83 c4 10             	add    $0x10,%esp
80104396:	85 c0                	test   %eax,%eax
80104398:	79 87                	jns    80104321 <create+0xd0>
      panic("create dots");
8010439a:	83 ec 0c             	sub    $0xc,%esp
8010439d:	68 c0 6d 10 80       	push   $0x80106dc0
801043a2:	e8 a1 bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801043a7:	83 ec 0c             	sub    $0xc,%esp
801043aa:	68 cc 6d 10 80       	push   $0x80106dcc
801043af:	e8 94 bf ff ff       	call   80100348 <panic>
    return 0;
801043b4:	89 c3                	mov    %eax,%ebx
801043b6:	e9 04 ff ff ff       	jmp    801042bf <create+0x6e>

801043bb <sys_dup>:
{
801043bb:	55                   	push   %ebp
801043bc:	89 e5                	mov    %esp,%ebp
801043be:	53                   	push   %ebx
801043bf:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043c2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043c5:	ba 00 00 00 00       	mov    $0x0,%edx
801043ca:	b8 00 00 00 00       	mov    $0x0,%eax
801043cf:	e8 88 fd ff ff       	call   8010415c <argfd>
801043d4:	85 c0                	test   %eax,%eax
801043d6:	78 23                	js     801043fb <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043db:	e8 e3 fd ff ff       	call   801041c3 <fdalloc>
801043e0:	89 c3                	mov    %eax,%ebx
801043e2:	85 c0                	test   %eax,%eax
801043e4:	78 1c                	js     80104402 <sys_dup+0x47>
  filedup(f);
801043e6:	83 ec 0c             	sub    $0xc,%esp
801043e9:	ff 75 f4             	pushl  -0xc(%ebp)
801043ec:	e8 9d c8 ff ff       	call   80100c8e <filedup>
  return fd;
801043f1:	83 c4 10             	add    $0x10,%esp
}
801043f4:	89 d8                	mov    %ebx,%eax
801043f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043f9:	c9                   	leave  
801043fa:	c3                   	ret    
    return -1;
801043fb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104400:	eb f2                	jmp    801043f4 <sys_dup+0x39>
    return -1;
80104402:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104407:	eb eb                	jmp    801043f4 <sys_dup+0x39>

80104409 <sys_read>:
{
80104409:	55                   	push   %ebp
8010440a:	89 e5                	mov    %esp,%ebp
8010440c:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010440f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104412:	ba 00 00 00 00       	mov    $0x0,%edx
80104417:	b8 00 00 00 00       	mov    $0x0,%eax
8010441c:	e8 3b fd ff ff       	call   8010415c <argfd>
80104421:	85 c0                	test   %eax,%eax
80104423:	78 43                	js     80104468 <sys_read+0x5f>
80104425:	83 ec 08             	sub    $0x8,%esp
80104428:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010442b:	50                   	push   %eax
8010442c:	6a 02                	push   $0x2
8010442e:	e8 11 fc ff ff       	call   80104044 <argint>
80104433:	83 c4 10             	add    $0x10,%esp
80104436:	85 c0                	test   %eax,%eax
80104438:	78 35                	js     8010446f <sys_read+0x66>
8010443a:	83 ec 04             	sub    $0x4,%esp
8010443d:	ff 75 f0             	pushl  -0x10(%ebp)
80104440:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104443:	50                   	push   %eax
80104444:	6a 01                	push   $0x1
80104446:	e8 21 fc ff ff       	call   8010406c <argptr>
8010444b:	83 c4 10             	add    $0x10,%esp
8010444e:	85 c0                	test   %eax,%eax
80104450:	78 24                	js     80104476 <sys_read+0x6d>
  return fileread(f, p, n);
80104452:	83 ec 04             	sub    $0x4,%esp
80104455:	ff 75 f0             	pushl  -0x10(%ebp)
80104458:	ff 75 ec             	pushl  -0x14(%ebp)
8010445b:	ff 75 f4             	pushl  -0xc(%ebp)
8010445e:	e8 74 c9 ff ff       	call   80100dd7 <fileread>
80104463:	83 c4 10             	add    $0x10,%esp
}
80104466:	c9                   	leave  
80104467:	c3                   	ret    
    return -1;
80104468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010446d:	eb f7                	jmp    80104466 <sys_read+0x5d>
8010446f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104474:	eb f0                	jmp    80104466 <sys_read+0x5d>
80104476:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010447b:	eb e9                	jmp    80104466 <sys_read+0x5d>

8010447d <sys_write>:
{
8010447d:	55                   	push   %ebp
8010447e:	89 e5                	mov    %esp,%ebp
80104480:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104483:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104486:	ba 00 00 00 00       	mov    $0x0,%edx
8010448b:	b8 00 00 00 00       	mov    $0x0,%eax
80104490:	e8 c7 fc ff ff       	call   8010415c <argfd>
80104495:	85 c0                	test   %eax,%eax
80104497:	78 43                	js     801044dc <sys_write+0x5f>
80104499:	83 ec 08             	sub    $0x8,%esp
8010449c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010449f:	50                   	push   %eax
801044a0:	6a 02                	push   $0x2
801044a2:	e8 9d fb ff ff       	call   80104044 <argint>
801044a7:	83 c4 10             	add    $0x10,%esp
801044aa:	85 c0                	test   %eax,%eax
801044ac:	78 35                	js     801044e3 <sys_write+0x66>
801044ae:	83 ec 04             	sub    $0x4,%esp
801044b1:	ff 75 f0             	pushl  -0x10(%ebp)
801044b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044b7:	50                   	push   %eax
801044b8:	6a 01                	push   $0x1
801044ba:	e8 ad fb ff ff       	call   8010406c <argptr>
801044bf:	83 c4 10             	add    $0x10,%esp
801044c2:	85 c0                	test   %eax,%eax
801044c4:	78 24                	js     801044ea <sys_write+0x6d>
  return filewrite(f, p, n);
801044c6:	83 ec 04             	sub    $0x4,%esp
801044c9:	ff 75 f0             	pushl  -0x10(%ebp)
801044cc:	ff 75 ec             	pushl  -0x14(%ebp)
801044cf:	ff 75 f4             	pushl  -0xc(%ebp)
801044d2:	e8 85 c9 ff ff       	call   80100e5c <filewrite>
801044d7:	83 c4 10             	add    $0x10,%esp
}
801044da:	c9                   	leave  
801044db:	c3                   	ret    
    return -1;
801044dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e1:	eb f7                	jmp    801044da <sys_write+0x5d>
801044e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e8:	eb f0                	jmp    801044da <sys_write+0x5d>
801044ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ef:	eb e9                	jmp    801044da <sys_write+0x5d>

801044f1 <sys_close>:
{
801044f1:	55                   	push   %ebp
801044f2:	89 e5                	mov    %esp,%ebp
801044f4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801044f7:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801044fa:	8d 55 f4             	lea    -0xc(%ebp),%edx
801044fd:	b8 00 00 00 00       	mov    $0x0,%eax
80104502:	e8 55 fc ff ff       	call   8010415c <argfd>
80104507:	85 c0                	test   %eax,%eax
80104509:	78 25                	js     80104530 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010450b:	e8 37 ee ff ff       	call   80103347 <myproc>
80104510:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104513:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010451a:	00 
  fileclose(f);
8010451b:	83 ec 0c             	sub    $0xc,%esp
8010451e:	ff 75 f0             	pushl  -0x10(%ebp)
80104521:	e8 ad c7 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104526:	83 c4 10             	add    $0x10,%esp
80104529:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010452e:	c9                   	leave  
8010452f:	c3                   	ret    
    return -1;
80104530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104535:	eb f7                	jmp    8010452e <sys_close+0x3d>

80104537 <sys_fstat>:
{
80104537:	55                   	push   %ebp
80104538:	89 e5                	mov    %esp,%ebp
8010453a:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010453d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104540:	ba 00 00 00 00       	mov    $0x0,%edx
80104545:	b8 00 00 00 00       	mov    $0x0,%eax
8010454a:	e8 0d fc ff ff       	call   8010415c <argfd>
8010454f:	85 c0                	test   %eax,%eax
80104551:	78 2a                	js     8010457d <sys_fstat+0x46>
80104553:	83 ec 04             	sub    $0x4,%esp
80104556:	6a 14                	push   $0x14
80104558:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010455b:	50                   	push   %eax
8010455c:	6a 01                	push   $0x1
8010455e:	e8 09 fb ff ff       	call   8010406c <argptr>
80104563:	83 c4 10             	add    $0x10,%esp
80104566:	85 c0                	test   %eax,%eax
80104568:	78 1a                	js     80104584 <sys_fstat+0x4d>
  return filestat(f, st);
8010456a:	83 ec 08             	sub    $0x8,%esp
8010456d:	ff 75 f0             	pushl  -0x10(%ebp)
80104570:	ff 75 f4             	pushl  -0xc(%ebp)
80104573:	e8 18 c8 ff ff       	call   80100d90 <filestat>
80104578:	83 c4 10             	add    $0x10,%esp
}
8010457b:	c9                   	leave  
8010457c:	c3                   	ret    
    return -1;
8010457d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104582:	eb f7                	jmp    8010457b <sys_fstat+0x44>
80104584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104589:	eb f0                	jmp    8010457b <sys_fstat+0x44>

8010458b <sys_link>:
{
8010458b:	55                   	push   %ebp
8010458c:	89 e5                	mov    %esp,%ebp
8010458e:	56                   	push   %esi
8010458f:	53                   	push   %ebx
80104590:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104593:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104596:	50                   	push   %eax
80104597:	6a 00                	push   $0x0
80104599:	e8 36 fb ff ff       	call   801040d4 <argstr>
8010459e:	83 c4 10             	add    $0x10,%esp
801045a1:	85 c0                	test   %eax,%eax
801045a3:	0f 88 32 01 00 00    	js     801046db <sys_link+0x150>
801045a9:	83 ec 08             	sub    $0x8,%esp
801045ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045af:	50                   	push   %eax
801045b0:	6a 01                	push   $0x1
801045b2:	e8 1d fb ff ff       	call   801040d4 <argstr>
801045b7:	83 c4 10             	add    $0x10,%esp
801045ba:	85 c0                	test   %eax,%eax
801045bc:	0f 88 20 01 00 00    	js     801046e2 <sys_link+0x157>
  begin_op();
801045c2:	e8 38 e3 ff ff       	call   801028ff <begin_op>
  if((ip = namei(old)) == 0){
801045c7:	83 ec 0c             	sub    $0xc,%esp
801045ca:	ff 75 e0             	pushl  -0x20(%ebp)
801045cd:	e8 0f d6 ff ff       	call   80101be1 <namei>
801045d2:	89 c3                	mov    %eax,%ebx
801045d4:	83 c4 10             	add    $0x10,%esp
801045d7:	85 c0                	test   %eax,%eax
801045d9:	0f 84 99 00 00 00    	je     80104678 <sys_link+0xed>
  ilock(ip);
801045df:	83 ec 0c             	sub    $0xc,%esp
801045e2:	50                   	push   %eax
801045e3:	e8 99 cf ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801045e8:	83 c4 10             	add    $0x10,%esp
801045eb:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045f0:	0f 84 8e 00 00 00    	je     80104684 <sys_link+0xf9>
  ip->nlink++;
801045f6:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045fa:	83 c0 01             	add    $0x1,%eax
801045fd:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104601:	83 ec 0c             	sub    $0xc,%esp
80104604:	53                   	push   %ebx
80104605:	e8 16 ce ff ff       	call   80101420 <iupdate>
  iunlock(ip);
8010460a:	89 1c 24             	mov    %ebx,(%esp)
8010460d:	e8 31 d0 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104612:	83 c4 08             	add    $0x8,%esp
80104615:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104618:	50                   	push   %eax
80104619:	ff 75 e4             	pushl  -0x1c(%ebp)
8010461c:	e8 d8 d5 ff ff       	call   80101bf9 <nameiparent>
80104621:	89 c6                	mov    %eax,%esi
80104623:	83 c4 10             	add    $0x10,%esp
80104626:	85 c0                	test   %eax,%eax
80104628:	74 7e                	je     801046a8 <sys_link+0x11d>
  ilock(dp);
8010462a:	83 ec 0c             	sub    $0xc,%esp
8010462d:	50                   	push   %eax
8010462e:	e8 4e cf ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104633:	83 c4 10             	add    $0x10,%esp
80104636:	8b 03                	mov    (%ebx),%eax
80104638:	39 06                	cmp    %eax,(%esi)
8010463a:	75 60                	jne    8010469c <sys_link+0x111>
8010463c:	83 ec 04             	sub    $0x4,%esp
8010463f:	ff 73 04             	pushl  0x4(%ebx)
80104642:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104645:	50                   	push   %eax
80104646:	56                   	push   %esi
80104647:	e8 e4 d4 ff ff       	call   80101b30 <dirlink>
8010464c:	83 c4 10             	add    $0x10,%esp
8010464f:	85 c0                	test   %eax,%eax
80104651:	78 49                	js     8010469c <sys_link+0x111>
  iunlockput(dp);
80104653:	83 ec 0c             	sub    $0xc,%esp
80104656:	56                   	push   %esi
80104657:	e8 cc d0 ff ff       	call   80101728 <iunlockput>
  iput(ip);
8010465c:	89 1c 24             	mov    %ebx,(%esp)
8010465f:	e8 24 d0 ff ff       	call   80101688 <iput>
  end_op();
80104664:	e8 10 e3 ff ff       	call   80102979 <end_op>
  return 0;
80104669:	83 c4 10             	add    $0x10,%esp
8010466c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104671:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104674:	5b                   	pop    %ebx
80104675:	5e                   	pop    %esi
80104676:	5d                   	pop    %ebp
80104677:	c3                   	ret    
    end_op();
80104678:	e8 fc e2 ff ff       	call   80102979 <end_op>
    return -1;
8010467d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104682:	eb ed                	jmp    80104671 <sys_link+0xe6>
    iunlockput(ip);
80104684:	83 ec 0c             	sub    $0xc,%esp
80104687:	53                   	push   %ebx
80104688:	e8 9b d0 ff ff       	call   80101728 <iunlockput>
    end_op();
8010468d:	e8 e7 e2 ff ff       	call   80102979 <end_op>
    return -1;
80104692:	83 c4 10             	add    $0x10,%esp
80104695:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010469a:	eb d5                	jmp    80104671 <sys_link+0xe6>
    iunlockput(dp);
8010469c:	83 ec 0c             	sub    $0xc,%esp
8010469f:	56                   	push   %esi
801046a0:	e8 83 d0 ff ff       	call   80101728 <iunlockput>
    goto bad;
801046a5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046a8:	83 ec 0c             	sub    $0xc,%esp
801046ab:	53                   	push   %ebx
801046ac:	e8 d0 ce ff ff       	call   80101581 <ilock>
  ip->nlink--;
801046b1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046b5:	83 e8 01             	sub    $0x1,%eax
801046b8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046bc:	89 1c 24             	mov    %ebx,(%esp)
801046bf:	e8 5c cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801046c4:	89 1c 24             	mov    %ebx,(%esp)
801046c7:	e8 5c d0 ff ff       	call   80101728 <iunlockput>
  end_op();
801046cc:	e8 a8 e2 ff ff       	call   80102979 <end_op>
  return -1;
801046d1:	83 c4 10             	add    $0x10,%esp
801046d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d9:	eb 96                	jmp    80104671 <sys_link+0xe6>
    return -1;
801046db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e0:	eb 8f                	jmp    80104671 <sys_link+0xe6>
801046e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e7:	eb 88                	jmp    80104671 <sys_link+0xe6>

801046e9 <sys_unlink>:
{
801046e9:	55                   	push   %ebp
801046ea:	89 e5                	mov    %esp,%ebp
801046ec:	57                   	push   %edi
801046ed:	56                   	push   %esi
801046ee:	53                   	push   %ebx
801046ef:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801046f2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046f5:	50                   	push   %eax
801046f6:	6a 00                	push   $0x0
801046f8:	e8 d7 f9 ff ff       	call   801040d4 <argstr>
801046fd:	83 c4 10             	add    $0x10,%esp
80104700:	85 c0                	test   %eax,%eax
80104702:	0f 88 83 01 00 00    	js     8010488b <sys_unlink+0x1a2>
  begin_op();
80104708:	e8 f2 e1 ff ff       	call   801028ff <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010470d:	83 ec 08             	sub    $0x8,%esp
80104710:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104713:	50                   	push   %eax
80104714:	ff 75 c4             	pushl  -0x3c(%ebp)
80104717:	e8 dd d4 ff ff       	call   80101bf9 <nameiparent>
8010471c:	89 c6                	mov    %eax,%esi
8010471e:	83 c4 10             	add    $0x10,%esp
80104721:	85 c0                	test   %eax,%eax
80104723:	0f 84 ed 00 00 00    	je     80104816 <sys_unlink+0x12d>
  ilock(dp);
80104729:	83 ec 0c             	sub    $0xc,%esp
8010472c:	50                   	push   %eax
8010472d:	e8 4f ce ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104732:	83 c4 08             	add    $0x8,%esp
80104735:	68 be 6d 10 80       	push   $0x80106dbe
8010473a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010473d:	50                   	push   %eax
8010473e:	e8 58 d2 ff ff       	call   8010199b <namecmp>
80104743:	83 c4 10             	add    $0x10,%esp
80104746:	85 c0                	test   %eax,%eax
80104748:	0f 84 fc 00 00 00    	je     8010484a <sys_unlink+0x161>
8010474e:	83 ec 08             	sub    $0x8,%esp
80104751:	68 bd 6d 10 80       	push   $0x80106dbd
80104756:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104759:	50                   	push   %eax
8010475a:	e8 3c d2 ff ff       	call   8010199b <namecmp>
8010475f:	83 c4 10             	add    $0x10,%esp
80104762:	85 c0                	test   %eax,%eax
80104764:	0f 84 e0 00 00 00    	je     8010484a <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010476a:	83 ec 04             	sub    $0x4,%esp
8010476d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104770:	50                   	push   %eax
80104771:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104774:	50                   	push   %eax
80104775:	56                   	push   %esi
80104776:	e8 35 d2 ff ff       	call   801019b0 <dirlookup>
8010477b:	89 c3                	mov    %eax,%ebx
8010477d:	83 c4 10             	add    $0x10,%esp
80104780:	85 c0                	test   %eax,%eax
80104782:	0f 84 c2 00 00 00    	je     8010484a <sys_unlink+0x161>
  ilock(ip);
80104788:	83 ec 0c             	sub    $0xc,%esp
8010478b:	50                   	push   %eax
8010478c:	e8 f0 cd ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104791:	83 c4 10             	add    $0x10,%esp
80104794:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104799:	0f 8e 83 00 00 00    	jle    80104822 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010479f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047a4:	0f 84 85 00 00 00    	je     8010482f <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801047aa:	83 ec 04             	sub    $0x4,%esp
801047ad:	6a 10                	push   $0x10
801047af:	6a 00                	push   $0x0
801047b1:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047b4:	57                   	push   %edi
801047b5:	e8 3f f6 ff ff       	call   80103df9 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047ba:	6a 10                	push   $0x10
801047bc:	ff 75 c0             	pushl  -0x40(%ebp)
801047bf:	57                   	push   %edi
801047c0:	56                   	push   %esi
801047c1:	e8 aa d0 ff ff       	call   80101870 <writei>
801047c6:	83 c4 20             	add    $0x20,%esp
801047c9:	83 f8 10             	cmp    $0x10,%eax
801047cc:	0f 85 90 00 00 00    	jne    80104862 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047d2:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047d7:	0f 84 92 00 00 00    	je     8010486f <sys_unlink+0x186>
  iunlockput(dp);
801047dd:	83 ec 0c             	sub    $0xc,%esp
801047e0:	56                   	push   %esi
801047e1:	e8 42 cf ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801047e6:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801047ea:	83 e8 01             	sub    $0x1,%eax
801047ed:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801047f1:	89 1c 24             	mov    %ebx,(%esp)
801047f4:	e8 27 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801047f9:	89 1c 24             	mov    %ebx,(%esp)
801047fc:	e8 27 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104801:	e8 73 e1 ff ff       	call   80102979 <end_op>
  return 0;
80104806:	83 c4 10             	add    $0x10,%esp
80104809:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010480e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104811:	5b                   	pop    %ebx
80104812:	5e                   	pop    %esi
80104813:	5f                   	pop    %edi
80104814:	5d                   	pop    %ebp
80104815:	c3                   	ret    
    end_op();
80104816:	e8 5e e1 ff ff       	call   80102979 <end_op>
    return -1;
8010481b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104820:	eb ec                	jmp    8010480e <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104822:	83 ec 0c             	sub    $0xc,%esp
80104825:	68 dc 6d 10 80       	push   $0x80106ddc
8010482a:	e8 19 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010482f:	89 d8                	mov    %ebx,%eax
80104831:	e8 c4 f9 ff ff       	call   801041fa <isdirempty>
80104836:	85 c0                	test   %eax,%eax
80104838:	0f 85 6c ff ff ff    	jne    801047aa <sys_unlink+0xc1>
    iunlockput(ip);
8010483e:	83 ec 0c             	sub    $0xc,%esp
80104841:	53                   	push   %ebx
80104842:	e8 e1 ce ff ff       	call   80101728 <iunlockput>
    goto bad;
80104847:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	56                   	push   %esi
8010484e:	e8 d5 ce ff ff       	call   80101728 <iunlockput>
  end_op();
80104853:	e8 21 e1 ff ff       	call   80102979 <end_op>
  return -1;
80104858:	83 c4 10             	add    $0x10,%esp
8010485b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104860:	eb ac                	jmp    8010480e <sys_unlink+0x125>
    panic("unlink: writei");
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	68 ee 6d 10 80       	push   $0x80106dee
8010486a:	e8 d9 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
8010486f:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104873:	83 e8 01             	sub    $0x1,%eax
80104876:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010487a:	83 ec 0c             	sub    $0xc,%esp
8010487d:	56                   	push   %esi
8010487e:	e8 9d cb ff ff       	call   80101420 <iupdate>
80104883:	83 c4 10             	add    $0x10,%esp
80104886:	e9 52 ff ff ff       	jmp    801047dd <sys_unlink+0xf4>
    return -1;
8010488b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104890:	e9 79 ff ff ff       	jmp    8010480e <sys_unlink+0x125>

80104895 <sys_open>:

int
sys_open(void)
{
80104895:	55                   	push   %ebp
80104896:	89 e5                	mov    %esp,%ebp
80104898:	57                   	push   %edi
80104899:	56                   	push   %esi
8010489a:	53                   	push   %ebx
8010489b:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010489e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048a1:	50                   	push   %eax
801048a2:	6a 00                	push   $0x0
801048a4:	e8 2b f8 ff ff       	call   801040d4 <argstr>
801048a9:	83 c4 10             	add    $0x10,%esp
801048ac:	85 c0                	test   %eax,%eax
801048ae:	0f 88 30 01 00 00    	js     801049e4 <sys_open+0x14f>
801048b4:	83 ec 08             	sub    $0x8,%esp
801048b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048ba:	50                   	push   %eax
801048bb:	6a 01                	push   $0x1
801048bd:	e8 82 f7 ff ff       	call   80104044 <argint>
801048c2:	83 c4 10             	add    $0x10,%esp
801048c5:	85 c0                	test   %eax,%eax
801048c7:	0f 88 21 01 00 00    	js     801049ee <sys_open+0x159>
    return -1;

  begin_op();
801048cd:	e8 2d e0 ff ff       	call   801028ff <begin_op>

  if(omode & O_CREATE){
801048d2:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048d6:	0f 84 84 00 00 00    	je     80104960 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801048dc:	83 ec 0c             	sub    $0xc,%esp
801048df:	6a 00                	push   $0x0
801048e1:	b9 00 00 00 00       	mov    $0x0,%ecx
801048e6:	ba 02 00 00 00       	mov    $0x2,%edx
801048eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801048ee:	e8 5e f9 ff ff       	call   80104251 <create>
801048f3:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801048f5:	83 c4 10             	add    $0x10,%esp
801048f8:	85 c0                	test   %eax,%eax
801048fa:	74 58                	je     80104954 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801048fc:	e8 2c c3 ff ff       	call   80100c2d <filealloc>
80104901:	89 c3                	mov    %eax,%ebx
80104903:	85 c0                	test   %eax,%eax
80104905:	0f 84 ae 00 00 00    	je     801049b9 <sys_open+0x124>
8010490b:	e8 b3 f8 ff ff       	call   801041c3 <fdalloc>
80104910:	89 c7                	mov    %eax,%edi
80104912:	85 c0                	test   %eax,%eax
80104914:	0f 88 9f 00 00 00    	js     801049b9 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010491a:	83 ec 0c             	sub    $0xc,%esp
8010491d:	56                   	push   %esi
8010491e:	e8 20 cd ff ff       	call   80101643 <iunlock>
  end_op();
80104923:	e8 51 e0 ff ff       	call   80102979 <end_op>

  f->type = FD_INODE;
80104928:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
8010492e:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104931:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104938:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493b:	83 c4 10             	add    $0x10,%esp
8010493e:	a8 01                	test   $0x1,%al
80104940:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104944:	a8 03                	test   $0x3,%al
80104946:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010494a:	89 f8                	mov    %edi,%eax
8010494c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010494f:	5b                   	pop    %ebx
80104950:	5e                   	pop    %esi
80104951:	5f                   	pop    %edi
80104952:	5d                   	pop    %ebp
80104953:	c3                   	ret    
      end_op();
80104954:	e8 20 e0 ff ff       	call   80102979 <end_op>
      return -1;
80104959:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010495e:	eb ea                	jmp    8010494a <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	ff 75 e4             	pushl  -0x1c(%ebp)
80104966:	e8 76 d2 ff ff       	call   80101be1 <namei>
8010496b:	89 c6                	mov    %eax,%esi
8010496d:	83 c4 10             	add    $0x10,%esp
80104970:	85 c0                	test   %eax,%eax
80104972:	74 39                	je     801049ad <sys_open+0x118>
    ilock(ip);
80104974:	83 ec 0c             	sub    $0xc,%esp
80104977:	50                   	push   %eax
80104978:	e8 04 cc ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010497d:	83 c4 10             	add    $0x10,%esp
80104980:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104985:	0f 85 71 ff ff ff    	jne    801048fc <sys_open+0x67>
8010498b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010498f:	0f 84 67 ff ff ff    	je     801048fc <sys_open+0x67>
      iunlockput(ip);
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	56                   	push   %esi
80104999:	e8 8a cd ff ff       	call   80101728 <iunlockput>
      end_op();
8010499e:	e8 d6 df ff ff       	call   80102979 <end_op>
      return -1;
801049a3:	83 c4 10             	add    $0x10,%esp
801049a6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049ab:	eb 9d                	jmp    8010494a <sys_open+0xb5>
      end_op();
801049ad:	e8 c7 df ff ff       	call   80102979 <end_op>
      return -1;
801049b2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049b7:	eb 91                	jmp    8010494a <sys_open+0xb5>
    if(f)
801049b9:	85 db                	test   %ebx,%ebx
801049bb:	74 0c                	je     801049c9 <sys_open+0x134>
      fileclose(f);
801049bd:	83 ec 0c             	sub    $0xc,%esp
801049c0:	53                   	push   %ebx
801049c1:	e8 0d c3 ff ff       	call   80100cd3 <fileclose>
801049c6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049c9:	83 ec 0c             	sub    $0xc,%esp
801049cc:	56                   	push   %esi
801049cd:	e8 56 cd ff ff       	call   80101728 <iunlockput>
    end_op();
801049d2:	e8 a2 df ff ff       	call   80102979 <end_op>
    return -1;
801049d7:	83 c4 10             	add    $0x10,%esp
801049da:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049df:	e9 66 ff ff ff       	jmp    8010494a <sys_open+0xb5>
    return -1;
801049e4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049e9:	e9 5c ff ff ff       	jmp    8010494a <sys_open+0xb5>
801049ee:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049f3:	e9 52 ff ff ff       	jmp    8010494a <sys_open+0xb5>

801049f8 <sys_mkdir>:

int
sys_mkdir(void)
{
801049f8:	55                   	push   %ebp
801049f9:	89 e5                	mov    %esp,%ebp
801049fb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801049fe:	e8 fc de ff ff       	call   801028ff <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a03:	83 ec 08             	sub    $0x8,%esp
80104a06:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a09:	50                   	push   %eax
80104a0a:	6a 00                	push   $0x0
80104a0c:	e8 c3 f6 ff ff       	call   801040d4 <argstr>
80104a11:	83 c4 10             	add    $0x10,%esp
80104a14:	85 c0                	test   %eax,%eax
80104a16:	78 36                	js     80104a4e <sys_mkdir+0x56>
80104a18:	83 ec 0c             	sub    $0xc,%esp
80104a1b:	6a 00                	push   $0x0
80104a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a22:	ba 01 00 00 00       	mov    $0x1,%edx
80104a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2a:	e8 22 f8 ff ff       	call   80104251 <create>
80104a2f:	83 c4 10             	add    $0x10,%esp
80104a32:	85 c0                	test   %eax,%eax
80104a34:	74 18                	je     80104a4e <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a36:	83 ec 0c             	sub    $0xc,%esp
80104a39:	50                   	push   %eax
80104a3a:	e8 e9 cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104a3f:	e8 35 df ff ff       	call   80102979 <end_op>
  return 0;
80104a44:	83 c4 10             	add    $0x10,%esp
80104a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a4c:	c9                   	leave  
80104a4d:	c3                   	ret    
    end_op();
80104a4e:	e8 26 df ff ff       	call   80102979 <end_op>
    return -1;
80104a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a58:	eb f2                	jmp    80104a4c <sys_mkdir+0x54>

80104a5a <sys_mknod>:

int
sys_mknod(void)
{
80104a5a:	55                   	push   %ebp
80104a5b:	89 e5                	mov    %esp,%ebp
80104a5d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a60:	e8 9a de ff ff       	call   801028ff <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a65:	83 ec 08             	sub    $0x8,%esp
80104a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a6b:	50                   	push   %eax
80104a6c:	6a 00                	push   $0x0
80104a6e:	e8 61 f6 ff ff       	call   801040d4 <argstr>
80104a73:	83 c4 10             	add    $0x10,%esp
80104a76:	85 c0                	test   %eax,%eax
80104a78:	78 62                	js     80104adc <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a7a:	83 ec 08             	sub    $0x8,%esp
80104a7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a80:	50                   	push   %eax
80104a81:	6a 01                	push   $0x1
80104a83:	e8 bc f5 ff ff       	call   80104044 <argint>
  if((argstr(0, &path)) < 0 ||
80104a88:	83 c4 10             	add    $0x10,%esp
80104a8b:	85 c0                	test   %eax,%eax
80104a8d:	78 4d                	js     80104adc <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a8f:	83 ec 08             	sub    $0x8,%esp
80104a92:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a95:	50                   	push   %eax
80104a96:	6a 02                	push   $0x2
80104a98:	e8 a7 f5 ff ff       	call   80104044 <argint>
     argint(1, &major) < 0 ||
80104a9d:	83 c4 10             	add    $0x10,%esp
80104aa0:	85 c0                	test   %eax,%eax
80104aa2:	78 38                	js     80104adc <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104aa4:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104aa8:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104aac:	83 ec 0c             	sub    $0xc,%esp
80104aaf:	50                   	push   %eax
80104ab0:	ba 03 00 00 00       	mov    $0x3,%edx
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	e8 94 f7 ff ff       	call   80104251 <create>
80104abd:	83 c4 10             	add    $0x10,%esp
80104ac0:	85 c0                	test   %eax,%eax
80104ac2:	74 18                	je     80104adc <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ac4:	83 ec 0c             	sub    $0xc,%esp
80104ac7:	50                   	push   %eax
80104ac8:	e8 5b cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104acd:	e8 a7 de ff ff       	call   80102979 <end_op>
  return 0;
80104ad2:	83 c4 10             	add    $0x10,%esp
80104ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ada:	c9                   	leave  
80104adb:	c3                   	ret    
    end_op();
80104adc:	e8 98 de ff ff       	call   80102979 <end_op>
    return -1;
80104ae1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae6:	eb f2                	jmp    80104ada <sys_mknod+0x80>

80104ae8 <sys_chdir>:

int
sys_chdir(void)
{
80104ae8:	55                   	push   %ebp
80104ae9:	89 e5                	mov    %esp,%ebp
80104aeb:	56                   	push   %esi
80104aec:	53                   	push   %ebx
80104aed:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104af0:	e8 52 e8 ff ff       	call   80103347 <myproc>
80104af5:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104af7:	e8 03 de ff ff       	call   801028ff <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104afc:	83 ec 08             	sub    $0x8,%esp
80104aff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b02:	50                   	push   %eax
80104b03:	6a 00                	push   $0x0
80104b05:	e8 ca f5 ff ff       	call   801040d4 <argstr>
80104b0a:	83 c4 10             	add    $0x10,%esp
80104b0d:	85 c0                	test   %eax,%eax
80104b0f:	78 52                	js     80104b63 <sys_chdir+0x7b>
80104b11:	83 ec 0c             	sub    $0xc,%esp
80104b14:	ff 75 f4             	pushl  -0xc(%ebp)
80104b17:	e8 c5 d0 ff ff       	call   80101be1 <namei>
80104b1c:	89 c3                	mov    %eax,%ebx
80104b1e:	83 c4 10             	add    $0x10,%esp
80104b21:	85 c0                	test   %eax,%eax
80104b23:	74 3e                	je     80104b63 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b25:	83 ec 0c             	sub    $0xc,%esp
80104b28:	50                   	push   %eax
80104b29:	e8 53 ca ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104b2e:	83 c4 10             	add    $0x10,%esp
80104b31:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b36:	75 37                	jne    80104b6f <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b38:	83 ec 0c             	sub    $0xc,%esp
80104b3b:	53                   	push   %ebx
80104b3c:	e8 02 cb ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104b41:	83 c4 04             	add    $0x4,%esp
80104b44:	ff 76 68             	pushl  0x68(%esi)
80104b47:	e8 3c cb ff ff       	call   80101688 <iput>
  end_op();
80104b4c:	e8 28 de ff ff       	call   80102979 <end_op>
  curproc->cwd = ip;
80104b51:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b54:	83 c4 10             	add    $0x10,%esp
80104b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b5f:	5b                   	pop    %ebx
80104b60:	5e                   	pop    %esi
80104b61:	5d                   	pop    %ebp
80104b62:	c3                   	ret    
    end_op();
80104b63:	e8 11 de ff ff       	call   80102979 <end_op>
    return -1;
80104b68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6d:	eb ed                	jmp    80104b5c <sys_chdir+0x74>
    iunlockput(ip);
80104b6f:	83 ec 0c             	sub    $0xc,%esp
80104b72:	53                   	push   %ebx
80104b73:	e8 b0 cb ff ff       	call   80101728 <iunlockput>
    end_op();
80104b78:	e8 fc dd ff ff       	call   80102979 <end_op>
    return -1;
80104b7d:	83 c4 10             	add    $0x10,%esp
80104b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b85:	eb d5                	jmp    80104b5c <sys_chdir+0x74>

80104b87 <sys_exec>:

int
sys_exec(void)
{
80104b87:	55                   	push   %ebp
80104b88:	89 e5                	mov    %esp,%ebp
80104b8a:	53                   	push   %ebx
80104b8b:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b94:	50                   	push   %eax
80104b95:	6a 00                	push   $0x0
80104b97:	e8 38 f5 ff ff       	call   801040d4 <argstr>
80104b9c:	83 c4 10             	add    $0x10,%esp
80104b9f:	85 c0                	test   %eax,%eax
80104ba1:	0f 88 a8 00 00 00    	js     80104c4f <sys_exec+0xc8>
80104ba7:	83 ec 08             	sub    $0x8,%esp
80104baa:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bb0:	50                   	push   %eax
80104bb1:	6a 01                	push   $0x1
80104bb3:	e8 8c f4 ff ff       	call   80104044 <argint>
80104bb8:	83 c4 10             	add    $0x10,%esp
80104bbb:	85 c0                	test   %eax,%eax
80104bbd:	0f 88 93 00 00 00    	js     80104c56 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bc3:	83 ec 04             	sub    $0x4,%esp
80104bc6:	68 80 00 00 00       	push   $0x80
80104bcb:	6a 00                	push   $0x0
80104bcd:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bd3:	50                   	push   %eax
80104bd4:	e8 20 f2 ff ff       	call   80103df9 <memset>
80104bd9:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104bdc:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104be1:	83 fb 1f             	cmp    $0x1f,%ebx
80104be4:	77 77                	ja     80104c5d <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104be6:	83 ec 08             	sub    $0x8,%esp
80104be9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104bef:	50                   	push   %eax
80104bf0:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104bf6:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104bf9:	50                   	push   %eax
80104bfa:	e8 c9 f3 ff ff       	call   80103fc8 <fetchint>
80104bff:	83 c4 10             	add    $0x10,%esp
80104c02:	85 c0                	test   %eax,%eax
80104c04:	78 5e                	js     80104c64 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104c06:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c0c:	85 c0                	test   %eax,%eax
80104c0e:	74 1d                	je     80104c2d <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104c10:	83 ec 08             	sub    $0x8,%esp
80104c13:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c1a:	52                   	push   %edx
80104c1b:	50                   	push   %eax
80104c1c:	e8 e3 f3 ff ff       	call   80104004 <fetchstr>
80104c21:	83 c4 10             	add    $0x10,%esp
80104c24:	85 c0                	test   %eax,%eax
80104c26:	78 46                	js     80104c6e <sys_exec+0xe7>
  for(i=0;; i++){
80104c28:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c2b:	eb b4                	jmp    80104be1 <sys_exec+0x5a>
      argv[i] = 0;
80104c2d:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c34:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c38:	83 ec 08             	sub    $0x8,%esp
80104c3b:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c41:	50                   	push   %eax
80104c42:	ff 75 f4             	pushl  -0xc(%ebp)
80104c45:	e8 88 bc ff ff       	call   801008d2 <exec>
80104c4a:	83 c4 10             	add    $0x10,%esp
80104c4d:	eb 1a                	jmp    80104c69 <sys_exec+0xe2>
    return -1;
80104c4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c54:	eb 13                	jmp    80104c69 <sys_exec+0xe2>
80104c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c5b:	eb 0c                	jmp    80104c69 <sys_exec+0xe2>
      return -1;
80104c5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c62:	eb 05                	jmp    80104c69 <sys_exec+0xe2>
      return -1;
80104c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c6c:	c9                   	leave  
80104c6d:	c3                   	ret    
      return -1;
80104c6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c73:	eb f4                	jmp    80104c69 <sys_exec+0xe2>

80104c75 <sys_pipe>:

int
sys_pipe(void)
{
80104c75:	55                   	push   %ebp
80104c76:	89 e5                	mov    %esp,%ebp
80104c78:	53                   	push   %ebx
80104c79:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c7c:	6a 08                	push   $0x8
80104c7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c81:	50                   	push   %eax
80104c82:	6a 00                	push   $0x0
80104c84:	e8 e3 f3 ff ff       	call   8010406c <argptr>
80104c89:	83 c4 10             	add    $0x10,%esp
80104c8c:	85 c0                	test   %eax,%eax
80104c8e:	78 77                	js     80104d07 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c90:	83 ec 08             	sub    $0x8,%esp
80104c93:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c96:	50                   	push   %eax
80104c97:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c9a:	50                   	push   %eax
80104c9b:	e8 e6 e1 ff ff       	call   80102e86 <pipealloc>
80104ca0:	83 c4 10             	add    $0x10,%esp
80104ca3:	85 c0                	test   %eax,%eax
80104ca5:	78 67                	js     80104d0e <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104caa:	e8 14 f5 ff ff       	call   801041c3 <fdalloc>
80104caf:	89 c3                	mov    %eax,%ebx
80104cb1:	85 c0                	test   %eax,%eax
80104cb3:	78 21                	js     80104cd6 <sys_pipe+0x61>
80104cb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cb8:	e8 06 f5 ff ff       	call   801041c3 <fdalloc>
80104cbd:	85 c0                	test   %eax,%eax
80104cbf:	78 15                	js     80104cd6 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc4:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc9:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104ccc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cd4:	c9                   	leave  
80104cd5:	c3                   	ret    
    if(fd0 >= 0)
80104cd6:	85 db                	test   %ebx,%ebx
80104cd8:	78 0d                	js     80104ce7 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104cda:	e8 68 e6 ff ff       	call   80103347 <myproc>
80104cdf:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104ce6:	00 
    fileclose(rf);
80104ce7:	83 ec 0c             	sub    $0xc,%esp
80104cea:	ff 75 f0             	pushl  -0x10(%ebp)
80104ced:	e8 e1 bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104cf2:	83 c4 04             	add    $0x4,%esp
80104cf5:	ff 75 ec             	pushl  -0x14(%ebp)
80104cf8:	e8 d6 bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104cfd:	83 c4 10             	add    $0x10,%esp
80104d00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d05:	eb ca                	jmp    80104cd1 <sys_pipe+0x5c>
    return -1;
80104d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d0c:	eb c3                	jmp    80104cd1 <sys_pipe+0x5c>
    return -1;
80104d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d13:	eb bc                	jmp    80104cd1 <sys_pipe+0x5c>

80104d15 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d15:	55                   	push   %ebp
80104d16:	89 e5                	mov    %esp,%ebp
80104d18:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d1b:	e8 9f e7 ff ff       	call   801034bf <fork>
}
80104d20:	c9                   	leave  
80104d21:	c3                   	ret    

80104d22 <sys_exit>:

int
sys_exit(void)
{
80104d22:	55                   	push   %ebp
80104d23:	89 e5                	mov    %esp,%ebp
80104d25:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d28:	e8 c6 e9 ff ff       	call   801036f3 <exit>
  return 0;  // not reached
}
80104d2d:	b8 00 00 00 00       	mov    $0x0,%eax
80104d32:	c9                   	leave  
80104d33:	c3                   	ret    

80104d34 <sys_wait>:

int
sys_wait(void)
{
80104d34:	55                   	push   %ebp
80104d35:	89 e5                	mov    %esp,%ebp
80104d37:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d3a:	e8 3d eb ff ff       	call   8010387c <wait>
}
80104d3f:	c9                   	leave  
80104d40:	c3                   	ret    

80104d41 <sys_kill>:

int
sys_kill(void)
{
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
80104d44:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4a:	50                   	push   %eax
80104d4b:	6a 00                	push   $0x0
80104d4d:	e8 f2 f2 ff ff       	call   80104044 <argint>
80104d52:	83 c4 10             	add    $0x10,%esp
80104d55:	85 c0                	test   %eax,%eax
80104d57:	78 10                	js     80104d69 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d59:	83 ec 0c             	sub    $0xc,%esp
80104d5c:	ff 75 f4             	pushl  -0xc(%ebp)
80104d5f:	e8 15 ec ff ff       	call   80103979 <kill>
80104d64:	83 c4 10             	add    $0x10,%esp
}
80104d67:	c9                   	leave  
80104d68:	c3                   	ret    
    return -1;
80104d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6e:	eb f7                	jmp    80104d67 <sys_kill+0x26>

80104d70 <sys_getpid>:

int
sys_getpid(void)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104d76:	e8 cc e5 ff ff       	call   80103347 <myproc>
80104d7b:	8b 40 10             	mov    0x10(%eax),%eax
}
80104d7e:	c9                   	leave  
80104d7f:	c3                   	ret    

80104d80 <sys_sbrk>:

int
sys_sbrk(void)
{
80104d80:	55                   	push   %ebp
80104d81:	89 e5                	mov    %esp,%ebp
80104d83:	53                   	push   %ebx
80104d84:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d87:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d8a:	50                   	push   %eax
80104d8b:	6a 00                	push   $0x0
80104d8d:	e8 b2 f2 ff ff       	call   80104044 <argint>
80104d92:	83 c4 10             	add    $0x10,%esp
80104d95:	85 c0                	test   %eax,%eax
80104d97:	78 27                	js     80104dc0 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104d99:	e8 a9 e5 ff ff       	call   80103347 <myproc>
80104d9e:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104da0:	83 ec 0c             	sub    $0xc,%esp
80104da3:	ff 75 f4             	pushl  -0xc(%ebp)
80104da6:	e8 a7 e6 ff ff       	call   80103452 <growproc>
80104dab:	83 c4 10             	add    $0x10,%esp
80104dae:	85 c0                	test   %eax,%eax
80104db0:	78 07                	js     80104db9 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104db2:	89 d8                	mov    %ebx,%eax
80104db4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104db7:	c9                   	leave  
80104db8:	c3                   	ret    
    return -1;
80104db9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dbe:	eb f2                	jmp    80104db2 <sys_sbrk+0x32>
    return -1;
80104dc0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dc5:	eb eb                	jmp    80104db2 <sys_sbrk+0x32>

80104dc7 <sys_sleep>:

int
sys_sleep(void)
{
80104dc7:	55                   	push   %ebp
80104dc8:	89 e5                	mov    %esp,%ebp
80104dca:	53                   	push   %ebx
80104dcb:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104dce:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd1:	50                   	push   %eax
80104dd2:	6a 00                	push   $0x0
80104dd4:	e8 6b f2 ff ff       	call   80104044 <argint>
80104dd9:	83 c4 10             	add    $0x10,%esp
80104ddc:	85 c0                	test   %eax,%eax
80104dde:	78 75                	js     80104e55 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104de0:	83 ec 0c             	sub    $0xc,%esp
80104de3:	68 80 0a 1c 80       	push   $0x801c0a80
80104de8:	e8 60 ef ff ff       	call   80103d4d <acquire>
  ticks0 = ticks;
80104ded:	8b 1d c0 12 1c 80    	mov    0x801c12c0,%ebx
  while(ticks - ticks0 < n){
80104df3:	83 c4 10             	add    $0x10,%esp
80104df6:	a1 c0 12 1c 80       	mov    0x801c12c0,%eax
80104dfb:	29 d8                	sub    %ebx,%eax
80104dfd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e00:	73 39                	jae    80104e3b <sys_sleep+0x74>
    if(myproc()->killed){
80104e02:	e8 40 e5 ff ff       	call   80103347 <myproc>
80104e07:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e0b:	75 17                	jne    80104e24 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e0d:	83 ec 08             	sub    $0x8,%esp
80104e10:	68 80 0a 1c 80       	push   $0x801c0a80
80104e15:	68 c0 12 1c 80       	push   $0x801c12c0
80104e1a:	e8 cc e9 ff ff       	call   801037eb <sleep>
80104e1f:	83 c4 10             	add    $0x10,%esp
80104e22:	eb d2                	jmp    80104df6 <sys_sleep+0x2f>
      release(&tickslock);
80104e24:	83 ec 0c             	sub    $0xc,%esp
80104e27:	68 80 0a 1c 80       	push   $0x801c0a80
80104e2c:	e8 81 ef ff ff       	call   80103db2 <release>
      return -1;
80104e31:	83 c4 10             	add    $0x10,%esp
80104e34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e39:	eb 15                	jmp    80104e50 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e3b:	83 ec 0c             	sub    $0xc,%esp
80104e3e:	68 80 0a 1c 80       	push   $0x801c0a80
80104e43:	e8 6a ef ff ff       	call   80103db2 <release>
  return 0;
80104e48:	83 c4 10             	add    $0x10,%esp
80104e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e53:	c9                   	leave  
80104e54:	c3                   	ret    
    return -1;
80104e55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e5a:	eb f4                	jmp    80104e50 <sys_sleep+0x89>

80104e5c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
80104e5f:	53                   	push   %ebx
80104e60:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e63:	68 80 0a 1c 80       	push   $0x801c0a80
80104e68:	e8 e0 ee ff ff       	call   80103d4d <acquire>
  xticks = ticks;
80104e6d:	8b 1d c0 12 1c 80    	mov    0x801c12c0,%ebx
  release(&tickslock);
80104e73:	c7 04 24 80 0a 1c 80 	movl   $0x801c0a80,(%esp)
80104e7a:	e8 33 ef ff ff       	call   80103db2 <release>
  return xticks;
}
80104e7f:	89 d8                	mov    %ebx,%eax
80104e81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e84:	c9                   	leave  
80104e85:	c3                   	ret    

80104e86 <sys_dump_physmem>:

int 
sys_dump_physmem(void)
{
80104e86:	55                   	push   %ebp
80104e87:	89 e5                	mov    %esp,%ebp
80104e89:	83 ec 1c             	sub    $0x1c,%esp
    int *frames;
    if(argptr(0, (void*)&frames, sizeof(*frames))< 0){
80104e8c:	6a 04                	push   $0x4
80104e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e91:	50                   	push   %eax
80104e92:	6a 00                	push   $0x0
80104e94:	e8 d3 f1 ff ff       	call   8010406c <argptr>
80104e99:	83 c4 10             	add    $0x10,%esp
80104e9c:	85 c0                	test   %eax,%eax
80104e9e:	78 49                	js     80104ee9 <sys_dump_physmem+0x63>
        return -1;
    }
    int *pids;
    if(argptr(1, (void*)&pids, sizeof(*pids))< 0){
80104ea0:	83 ec 04             	sub    $0x4,%esp
80104ea3:	6a 04                	push   $0x4
80104ea5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ea8:	50                   	push   %eax
80104ea9:	6a 01                	push   $0x1
80104eab:	e8 bc f1 ff ff       	call   8010406c <argptr>
80104eb0:	83 c4 10             	add    $0x10,%esp
80104eb3:	85 c0                	test   %eax,%eax
80104eb5:	78 39                	js     80104ef0 <sys_dump_physmem+0x6a>
         return -1;
    }
    int numframes = 0;
80104eb7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    if(argint(2, &numframes) < 0){
80104ebe:	83 ec 08             	sub    $0x8,%esp
80104ec1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ec4:	50                   	push   %eax
80104ec5:	6a 02                	push   $0x2
80104ec7:	e8 78 f1 ff ff       	call   80104044 <argint>
80104ecc:	83 c4 10             	add    $0x10,%esp
80104ecf:	85 c0                	test   %eax,%eax
80104ed1:	78 24                	js     80104ef7 <sys_dump_physmem+0x71>
       return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104ed3:	83 ec 04             	sub    $0x4,%esp
80104ed6:	ff 75 ec             	pushl  -0x14(%ebp)
80104ed9:	ff 75 f0             	pushl  -0x10(%ebp)
80104edc:	ff 75 f4             	pushl  -0xc(%ebp)
80104edf:	e8 bb eb ff ff       	call   80103a9f <dump_physmem>
80104ee4:	83 c4 10             	add    $0x10,%esp
}
80104ee7:	c9                   	leave  
80104ee8:	c3                   	ret    
        return -1;
80104ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eee:	eb f7                	jmp    80104ee7 <sys_dump_physmem+0x61>
         return -1;
80104ef0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef5:	eb f0                	jmp    80104ee7 <sys_dump_physmem+0x61>
       return -1;
80104ef7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104efc:	eb e9                	jmp    80104ee7 <sys_dump_physmem+0x61>

80104efe <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104efe:	1e                   	push   %ds
  pushl %es
80104eff:	06                   	push   %es
  pushl %fs
80104f00:	0f a0                	push   %fs
  pushl %gs
80104f02:	0f a8                	push   %gs
  pushal
80104f04:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f05:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f09:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f0b:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f0d:	54                   	push   %esp
  call trap
80104f0e:	e8 e3 00 00 00       	call   80104ff6 <trap>
  addl $4, %esp
80104f13:	83 c4 04             	add    $0x4,%esp

80104f16 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f16:	61                   	popa   
  popl %gs
80104f17:	0f a9                	pop    %gs
  popl %fs
80104f19:	0f a1                	pop    %fs
  popl %es
80104f1b:	07                   	pop    %es
  popl %ds
80104f1c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f1d:	83 c4 08             	add    $0x8,%esp
  iret
80104f20:	cf                   	iret   

80104f21 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f21:	55                   	push   %ebp
80104f22:	89 e5                	mov    %esp,%ebp
80104f24:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f27:	b8 00 00 00 00       	mov    $0x0,%eax
80104f2c:	eb 4a                	jmp    80104f78 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f2e:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f35:	66 89 0c c5 c0 0a 1c 	mov    %cx,-0x7fe3f540(,%eax,8)
80104f3c:	80 
80104f3d:	66 c7 04 c5 c2 0a 1c 	movw   $0x8,-0x7fe3f53e(,%eax,8)
80104f44:	80 08 00 
80104f47:	c6 04 c5 c4 0a 1c 80 	movb   $0x0,-0x7fe3f53c(,%eax,8)
80104f4e:	00 
80104f4f:	0f b6 14 c5 c5 0a 1c 	movzbl -0x7fe3f53b(,%eax,8),%edx
80104f56:	80 
80104f57:	83 e2 f0             	and    $0xfffffff0,%edx
80104f5a:	83 ca 0e             	or     $0xe,%edx
80104f5d:	83 e2 8f             	and    $0xffffff8f,%edx
80104f60:	83 ca 80             	or     $0xffffff80,%edx
80104f63:	88 14 c5 c5 0a 1c 80 	mov    %dl,-0x7fe3f53b(,%eax,8)
80104f6a:	c1 e9 10             	shr    $0x10,%ecx
80104f6d:	66 89 0c c5 c6 0a 1c 	mov    %cx,-0x7fe3f53a(,%eax,8)
80104f74:	80 
  for(i = 0; i < 256; i++)
80104f75:	83 c0 01             	add    $0x1,%eax
80104f78:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f7d:	7e af                	jle    80104f2e <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f7f:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f85:	66 89 15 c0 0c 1c 80 	mov    %dx,0x801c0cc0
80104f8c:	66 c7 05 c2 0c 1c 80 	movw   $0x8,0x801c0cc2
80104f93:	08 00 
80104f95:	c6 05 c4 0c 1c 80 00 	movb   $0x0,0x801c0cc4
80104f9c:	0f b6 05 c5 0c 1c 80 	movzbl 0x801c0cc5,%eax
80104fa3:	83 c8 0f             	or     $0xf,%eax
80104fa6:	83 e0 ef             	and    $0xffffffef,%eax
80104fa9:	83 c8 e0             	or     $0xffffffe0,%eax
80104fac:	a2 c5 0c 1c 80       	mov    %al,0x801c0cc5
80104fb1:	c1 ea 10             	shr    $0x10,%edx
80104fb4:	66 89 15 c6 0c 1c 80 	mov    %dx,0x801c0cc6

  initlock(&tickslock, "time");
80104fbb:	83 ec 08             	sub    $0x8,%esp
80104fbe:	68 fd 6d 10 80       	push   $0x80106dfd
80104fc3:	68 80 0a 1c 80       	push   $0x801c0a80
80104fc8:	e8 44 ec ff ff       	call   80103c11 <initlock>
}
80104fcd:	83 c4 10             	add    $0x10,%esp
80104fd0:	c9                   	leave  
80104fd1:	c3                   	ret    

80104fd2 <idtinit>:

void
idtinit(void)
{
80104fd2:	55                   	push   %ebp
80104fd3:	89 e5                	mov    %esp,%ebp
80104fd5:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104fd8:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104fde:	b8 c0 0a 1c 80       	mov    $0x801c0ac0,%eax
80104fe3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104fe7:	c1 e8 10             	shr    $0x10,%eax
80104fea:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104fee:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104ff1:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104ff4:	c9                   	leave  
80104ff5:	c3                   	ret    

80104ff6 <trap>:

void
trap(struct trapframe *tf)
{
80104ff6:	55                   	push   %ebp
80104ff7:	89 e5                	mov    %esp,%ebp
80104ff9:	57                   	push   %edi
80104ffa:	56                   	push   %esi
80104ffb:	53                   	push   %ebx
80104ffc:	83 ec 1c             	sub    $0x1c,%esp
80104fff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105002:	8b 43 30             	mov    0x30(%ebx),%eax
80105005:	83 f8 40             	cmp    $0x40,%eax
80105008:	74 13                	je     8010501d <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010500a:	83 e8 20             	sub    $0x20,%eax
8010500d:	83 f8 1f             	cmp    $0x1f,%eax
80105010:	0f 87 3a 01 00 00    	ja     80105150 <trap+0x15a>
80105016:	ff 24 85 a4 6e 10 80 	jmp    *-0x7fef915c(,%eax,4)
    if(myproc()->killed)
8010501d:	e8 25 e3 ff ff       	call   80103347 <myproc>
80105022:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105026:	75 1f                	jne    80105047 <trap+0x51>
    myproc()->tf = tf;
80105028:	e8 1a e3 ff ff       	call   80103347 <myproc>
8010502d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105030:	e8 d2 f0 ff ff       	call   80104107 <syscall>
    if(myproc()->killed)
80105035:	e8 0d e3 ff ff       	call   80103347 <myproc>
8010503a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010503e:	74 7e                	je     801050be <trap+0xc8>
      exit();
80105040:	e8 ae e6 ff ff       	call   801036f3 <exit>
80105045:	eb 77                	jmp    801050be <trap+0xc8>
      exit();
80105047:	e8 a7 e6 ff ff       	call   801036f3 <exit>
8010504c:	eb da                	jmp    80105028 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010504e:	e8 d9 e2 ff ff       	call   8010332c <cpuid>
80105053:	85 c0                	test   %eax,%eax
80105055:	74 6f                	je     801050c6 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105057:	e8 8e d4 ff ff       	call   801024ea <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010505c:	e8 e6 e2 ff ff       	call   80103347 <myproc>
80105061:	85 c0                	test   %eax,%eax
80105063:	74 1c                	je     80105081 <trap+0x8b>
80105065:	e8 dd e2 ff ff       	call   80103347 <myproc>
8010506a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010506e:	74 11                	je     80105081 <trap+0x8b>
80105070:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105074:	83 e0 03             	and    $0x3,%eax
80105077:	66 83 f8 03          	cmp    $0x3,%ax
8010507b:	0f 84 62 01 00 00    	je     801051e3 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105081:	e8 c1 e2 ff ff       	call   80103347 <myproc>
80105086:	85 c0                	test   %eax,%eax
80105088:	74 0f                	je     80105099 <trap+0xa3>
8010508a:	e8 b8 e2 ff ff       	call   80103347 <myproc>
8010508f:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105093:	0f 84 54 01 00 00    	je     801051ed <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105099:	e8 a9 e2 ff ff       	call   80103347 <myproc>
8010509e:	85 c0                	test   %eax,%eax
801050a0:	74 1c                	je     801050be <trap+0xc8>
801050a2:	e8 a0 e2 ff ff       	call   80103347 <myproc>
801050a7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050ab:	74 11                	je     801050be <trap+0xc8>
801050ad:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050b1:	83 e0 03             	and    $0x3,%eax
801050b4:	66 83 f8 03          	cmp    $0x3,%ax
801050b8:	0f 84 43 01 00 00    	je     80105201 <trap+0x20b>
    exit();
}
801050be:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050c1:	5b                   	pop    %ebx
801050c2:	5e                   	pop    %esi
801050c3:	5f                   	pop    %edi
801050c4:	5d                   	pop    %ebp
801050c5:	c3                   	ret    
      acquire(&tickslock);
801050c6:	83 ec 0c             	sub    $0xc,%esp
801050c9:	68 80 0a 1c 80       	push   $0x801c0a80
801050ce:	e8 7a ec ff ff       	call   80103d4d <acquire>
      ticks++;
801050d3:	83 05 c0 12 1c 80 01 	addl   $0x1,0x801c12c0
      wakeup(&ticks);
801050da:	c7 04 24 c0 12 1c 80 	movl   $0x801c12c0,(%esp)
801050e1:	e8 6a e8 ff ff       	call   80103950 <wakeup>
      release(&tickslock);
801050e6:	c7 04 24 80 0a 1c 80 	movl   $0x801c0a80,(%esp)
801050ed:	e8 c0 ec ff ff       	call   80103db2 <release>
801050f2:	83 c4 10             	add    $0x10,%esp
801050f5:	e9 5d ff ff ff       	jmp    80105057 <trap+0x61>
    ideintr();
801050fa:	e8 74 cc ff ff       	call   80101d73 <ideintr>
    lapiceoi();
801050ff:	e8 e6 d3 ff ff       	call   801024ea <lapiceoi>
    break;
80105104:	e9 53 ff ff ff       	jmp    8010505c <trap+0x66>
    kbdintr();
80105109:	e8 20 d2 ff ff       	call   8010232e <kbdintr>
    lapiceoi();
8010510e:	e8 d7 d3 ff ff       	call   801024ea <lapiceoi>
    break;
80105113:	e9 44 ff ff ff       	jmp    8010505c <trap+0x66>
    uartintr();
80105118:	e8 05 02 00 00       	call   80105322 <uartintr>
    lapiceoi();
8010511d:	e8 c8 d3 ff ff       	call   801024ea <lapiceoi>
    break;
80105122:	e9 35 ff ff ff       	jmp    8010505c <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105127:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010512a:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010512e:	e8 f9 e1 ff ff       	call   8010332c <cpuid>
80105133:	57                   	push   %edi
80105134:	0f b7 f6             	movzwl %si,%esi
80105137:	56                   	push   %esi
80105138:	50                   	push   %eax
80105139:	68 08 6e 10 80       	push   $0x80106e08
8010513e:	e8 c8 b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105143:	e8 a2 d3 ff ff       	call   801024ea <lapiceoi>
    break;
80105148:	83 c4 10             	add    $0x10,%esp
8010514b:	e9 0c ff ff ff       	jmp    8010505c <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105150:	e8 f2 e1 ff ff       	call   80103347 <myproc>
80105155:	85 c0                	test   %eax,%eax
80105157:	74 5f                	je     801051b8 <trap+0x1c2>
80105159:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010515d:	74 59                	je     801051b8 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010515f:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105162:	8b 43 38             	mov    0x38(%ebx),%eax
80105165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105168:	e8 bf e1 ff ff       	call   8010332c <cpuid>
8010516d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105170:	8b 53 34             	mov    0x34(%ebx),%edx
80105173:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105176:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105179:	e8 c9 e1 ff ff       	call   80103347 <myproc>
8010517e:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105181:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105184:	e8 be e1 ff ff       	call   80103347 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105189:	57                   	push   %edi
8010518a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010518d:	ff 75 e0             	pushl  -0x20(%ebp)
80105190:	ff 75 dc             	pushl  -0x24(%ebp)
80105193:	56                   	push   %esi
80105194:	ff 75 d8             	pushl  -0x28(%ebp)
80105197:	ff 70 10             	pushl  0x10(%eax)
8010519a:	68 60 6e 10 80       	push   $0x80106e60
8010519f:	e8 67 b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801051a4:	83 c4 20             	add    $0x20,%esp
801051a7:	e8 9b e1 ff ff       	call   80103347 <myproc>
801051ac:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801051b3:	e9 a4 fe ff ff       	jmp    8010505c <trap+0x66>
801051b8:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801051bb:	8b 73 38             	mov    0x38(%ebx),%esi
801051be:	e8 69 e1 ff ff       	call   8010332c <cpuid>
801051c3:	83 ec 0c             	sub    $0xc,%esp
801051c6:	57                   	push   %edi
801051c7:	56                   	push   %esi
801051c8:	50                   	push   %eax
801051c9:	ff 73 30             	pushl  0x30(%ebx)
801051cc:	68 2c 6e 10 80       	push   $0x80106e2c
801051d1:	e8 35 b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
801051d6:	83 c4 14             	add    $0x14,%esp
801051d9:	68 02 6e 10 80       	push   $0x80106e02
801051de:	e8 65 b1 ff ff       	call   80100348 <panic>
    exit();
801051e3:	e8 0b e5 ff ff       	call   801036f3 <exit>
801051e8:	e9 94 fe ff ff       	jmp    80105081 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801051ed:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801051f1:	0f 85 a2 fe ff ff    	jne    80105099 <trap+0xa3>
    yield();
801051f7:	e8 bd e5 ff ff       	call   801037b9 <yield>
801051fc:	e9 98 fe ff ff       	jmp    80105099 <trap+0xa3>
    exit();
80105201:	e8 ed e4 ff ff       	call   801036f3 <exit>
80105206:	e9 b3 fe ff ff       	jmp    801050be <trap+0xc8>

8010520b <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010520b:	55                   	push   %ebp
8010520c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010520e:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105215:	74 15                	je     8010522c <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105217:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010521c:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010521d:	a8 01                	test   $0x1,%al
8010521f:	74 12                	je     80105233 <uartgetc+0x28>
80105221:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105226:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105227:	0f b6 c0             	movzbl %al,%eax
}
8010522a:	5d                   	pop    %ebp
8010522b:	c3                   	ret    
    return -1;
8010522c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105231:	eb f7                	jmp    8010522a <uartgetc+0x1f>
    return -1;
80105233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105238:	eb f0                	jmp    8010522a <uartgetc+0x1f>

8010523a <uartputc>:
  if(!uart)
8010523a:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105241:	74 3b                	je     8010527e <uartputc+0x44>
{
80105243:	55                   	push   %ebp
80105244:	89 e5                	mov    %esp,%ebp
80105246:	53                   	push   %ebx
80105247:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010524a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010524f:	eb 10                	jmp    80105261 <uartputc+0x27>
    microdelay(10);
80105251:	83 ec 0c             	sub    $0xc,%esp
80105254:	6a 0a                	push   $0xa
80105256:	e8 ae d2 ff ff       	call   80102509 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010525b:	83 c3 01             	add    $0x1,%ebx
8010525e:	83 c4 10             	add    $0x10,%esp
80105261:	83 fb 7f             	cmp    $0x7f,%ebx
80105264:	7f 0a                	jg     80105270 <uartputc+0x36>
80105266:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010526b:	ec                   	in     (%dx),%al
8010526c:	a8 20                	test   $0x20,%al
8010526e:	74 e1                	je     80105251 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105270:	8b 45 08             	mov    0x8(%ebp),%eax
80105273:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105278:	ee                   	out    %al,(%dx)
}
80105279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010527c:	c9                   	leave  
8010527d:	c3                   	ret    
8010527e:	f3 c3                	repz ret 

80105280 <uartinit>:
{
80105280:	55                   	push   %ebp
80105281:	89 e5                	mov    %esp,%ebp
80105283:	56                   	push   %esi
80105284:	53                   	push   %ebx
80105285:	b9 00 00 00 00       	mov    $0x0,%ecx
8010528a:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010528f:	89 c8                	mov    %ecx,%eax
80105291:	ee                   	out    %al,(%dx)
80105292:	be fb 03 00 00       	mov    $0x3fb,%esi
80105297:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010529c:	89 f2                	mov    %esi,%edx
8010529e:	ee                   	out    %al,(%dx)
8010529f:	b8 0c 00 00 00       	mov    $0xc,%eax
801052a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052a9:	ee                   	out    %al,(%dx)
801052aa:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801052af:	89 c8                	mov    %ecx,%eax
801052b1:	89 da                	mov    %ebx,%edx
801052b3:	ee                   	out    %al,(%dx)
801052b4:	b8 03 00 00 00       	mov    $0x3,%eax
801052b9:	89 f2                	mov    %esi,%edx
801052bb:	ee                   	out    %al,(%dx)
801052bc:	ba fc 03 00 00       	mov    $0x3fc,%edx
801052c1:	89 c8                	mov    %ecx,%eax
801052c3:	ee                   	out    %al,(%dx)
801052c4:	b8 01 00 00 00       	mov    $0x1,%eax
801052c9:	89 da                	mov    %ebx,%edx
801052cb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052d1:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801052d2:	3c ff                	cmp    $0xff,%al
801052d4:	74 45                	je     8010531b <uartinit+0x9b>
  uart = 1;
801052d6:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
801052dd:	00 00 00 
801052e0:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052e5:	ec                   	in     (%dx),%al
801052e6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052eb:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801052ec:	83 ec 08             	sub    $0x8,%esp
801052ef:	6a 00                	push   $0x0
801052f1:	6a 04                	push   $0x4
801052f3:	e8 86 cc ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801052f8:	83 c4 10             	add    $0x10,%esp
801052fb:	bb 24 6f 10 80       	mov    $0x80106f24,%ebx
80105300:	eb 12                	jmp    80105314 <uartinit+0x94>
    uartputc(*p);
80105302:	83 ec 0c             	sub    $0xc,%esp
80105305:	0f be c0             	movsbl %al,%eax
80105308:	50                   	push   %eax
80105309:	e8 2c ff ff ff       	call   8010523a <uartputc>
  for(p="xv6...\n"; *p; p++)
8010530e:	83 c3 01             	add    $0x1,%ebx
80105311:	83 c4 10             	add    $0x10,%esp
80105314:	0f b6 03             	movzbl (%ebx),%eax
80105317:	84 c0                	test   %al,%al
80105319:	75 e7                	jne    80105302 <uartinit+0x82>
}
8010531b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010531e:	5b                   	pop    %ebx
8010531f:	5e                   	pop    %esi
80105320:	5d                   	pop    %ebp
80105321:	c3                   	ret    

80105322 <uartintr>:

void
uartintr(void)
{
80105322:	55                   	push   %ebp
80105323:	89 e5                	mov    %esp,%ebp
80105325:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105328:	68 0b 52 10 80       	push   $0x8010520b
8010532d:	e8 0c b4 ff ff       	call   8010073e <consoleintr>
}
80105332:	83 c4 10             	add    $0x10,%esp
80105335:	c9                   	leave  
80105336:	c3                   	ret    

80105337 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105337:	6a 00                	push   $0x0
  pushl $0
80105339:	6a 00                	push   $0x0
  jmp alltraps
8010533b:	e9 be fb ff ff       	jmp    80104efe <alltraps>

80105340 <vector1>:
.globl vector1
vector1:
  pushl $0
80105340:	6a 00                	push   $0x0
  pushl $1
80105342:	6a 01                	push   $0x1
  jmp alltraps
80105344:	e9 b5 fb ff ff       	jmp    80104efe <alltraps>

80105349 <vector2>:
.globl vector2
vector2:
  pushl $0
80105349:	6a 00                	push   $0x0
  pushl $2
8010534b:	6a 02                	push   $0x2
  jmp alltraps
8010534d:	e9 ac fb ff ff       	jmp    80104efe <alltraps>

80105352 <vector3>:
.globl vector3
vector3:
  pushl $0
80105352:	6a 00                	push   $0x0
  pushl $3
80105354:	6a 03                	push   $0x3
  jmp alltraps
80105356:	e9 a3 fb ff ff       	jmp    80104efe <alltraps>

8010535b <vector4>:
.globl vector4
vector4:
  pushl $0
8010535b:	6a 00                	push   $0x0
  pushl $4
8010535d:	6a 04                	push   $0x4
  jmp alltraps
8010535f:	e9 9a fb ff ff       	jmp    80104efe <alltraps>

80105364 <vector5>:
.globl vector5
vector5:
  pushl $0
80105364:	6a 00                	push   $0x0
  pushl $5
80105366:	6a 05                	push   $0x5
  jmp alltraps
80105368:	e9 91 fb ff ff       	jmp    80104efe <alltraps>

8010536d <vector6>:
.globl vector6
vector6:
  pushl $0
8010536d:	6a 00                	push   $0x0
  pushl $6
8010536f:	6a 06                	push   $0x6
  jmp alltraps
80105371:	e9 88 fb ff ff       	jmp    80104efe <alltraps>

80105376 <vector7>:
.globl vector7
vector7:
  pushl $0
80105376:	6a 00                	push   $0x0
  pushl $7
80105378:	6a 07                	push   $0x7
  jmp alltraps
8010537a:	e9 7f fb ff ff       	jmp    80104efe <alltraps>

8010537f <vector8>:
.globl vector8
vector8:
  pushl $8
8010537f:	6a 08                	push   $0x8
  jmp alltraps
80105381:	e9 78 fb ff ff       	jmp    80104efe <alltraps>

80105386 <vector9>:
.globl vector9
vector9:
  pushl $0
80105386:	6a 00                	push   $0x0
  pushl $9
80105388:	6a 09                	push   $0x9
  jmp alltraps
8010538a:	e9 6f fb ff ff       	jmp    80104efe <alltraps>

8010538f <vector10>:
.globl vector10
vector10:
  pushl $10
8010538f:	6a 0a                	push   $0xa
  jmp alltraps
80105391:	e9 68 fb ff ff       	jmp    80104efe <alltraps>

80105396 <vector11>:
.globl vector11
vector11:
  pushl $11
80105396:	6a 0b                	push   $0xb
  jmp alltraps
80105398:	e9 61 fb ff ff       	jmp    80104efe <alltraps>

8010539d <vector12>:
.globl vector12
vector12:
  pushl $12
8010539d:	6a 0c                	push   $0xc
  jmp alltraps
8010539f:	e9 5a fb ff ff       	jmp    80104efe <alltraps>

801053a4 <vector13>:
.globl vector13
vector13:
  pushl $13
801053a4:	6a 0d                	push   $0xd
  jmp alltraps
801053a6:	e9 53 fb ff ff       	jmp    80104efe <alltraps>

801053ab <vector14>:
.globl vector14
vector14:
  pushl $14
801053ab:	6a 0e                	push   $0xe
  jmp alltraps
801053ad:	e9 4c fb ff ff       	jmp    80104efe <alltraps>

801053b2 <vector15>:
.globl vector15
vector15:
  pushl $0
801053b2:	6a 00                	push   $0x0
  pushl $15
801053b4:	6a 0f                	push   $0xf
  jmp alltraps
801053b6:	e9 43 fb ff ff       	jmp    80104efe <alltraps>

801053bb <vector16>:
.globl vector16
vector16:
  pushl $0
801053bb:	6a 00                	push   $0x0
  pushl $16
801053bd:	6a 10                	push   $0x10
  jmp alltraps
801053bf:	e9 3a fb ff ff       	jmp    80104efe <alltraps>

801053c4 <vector17>:
.globl vector17
vector17:
  pushl $17
801053c4:	6a 11                	push   $0x11
  jmp alltraps
801053c6:	e9 33 fb ff ff       	jmp    80104efe <alltraps>

801053cb <vector18>:
.globl vector18
vector18:
  pushl $0
801053cb:	6a 00                	push   $0x0
  pushl $18
801053cd:	6a 12                	push   $0x12
  jmp alltraps
801053cf:	e9 2a fb ff ff       	jmp    80104efe <alltraps>

801053d4 <vector19>:
.globl vector19
vector19:
  pushl $0
801053d4:	6a 00                	push   $0x0
  pushl $19
801053d6:	6a 13                	push   $0x13
  jmp alltraps
801053d8:	e9 21 fb ff ff       	jmp    80104efe <alltraps>

801053dd <vector20>:
.globl vector20
vector20:
  pushl $0
801053dd:	6a 00                	push   $0x0
  pushl $20
801053df:	6a 14                	push   $0x14
  jmp alltraps
801053e1:	e9 18 fb ff ff       	jmp    80104efe <alltraps>

801053e6 <vector21>:
.globl vector21
vector21:
  pushl $0
801053e6:	6a 00                	push   $0x0
  pushl $21
801053e8:	6a 15                	push   $0x15
  jmp alltraps
801053ea:	e9 0f fb ff ff       	jmp    80104efe <alltraps>

801053ef <vector22>:
.globl vector22
vector22:
  pushl $0
801053ef:	6a 00                	push   $0x0
  pushl $22
801053f1:	6a 16                	push   $0x16
  jmp alltraps
801053f3:	e9 06 fb ff ff       	jmp    80104efe <alltraps>

801053f8 <vector23>:
.globl vector23
vector23:
  pushl $0
801053f8:	6a 00                	push   $0x0
  pushl $23
801053fa:	6a 17                	push   $0x17
  jmp alltraps
801053fc:	e9 fd fa ff ff       	jmp    80104efe <alltraps>

80105401 <vector24>:
.globl vector24
vector24:
  pushl $0
80105401:	6a 00                	push   $0x0
  pushl $24
80105403:	6a 18                	push   $0x18
  jmp alltraps
80105405:	e9 f4 fa ff ff       	jmp    80104efe <alltraps>

8010540a <vector25>:
.globl vector25
vector25:
  pushl $0
8010540a:	6a 00                	push   $0x0
  pushl $25
8010540c:	6a 19                	push   $0x19
  jmp alltraps
8010540e:	e9 eb fa ff ff       	jmp    80104efe <alltraps>

80105413 <vector26>:
.globl vector26
vector26:
  pushl $0
80105413:	6a 00                	push   $0x0
  pushl $26
80105415:	6a 1a                	push   $0x1a
  jmp alltraps
80105417:	e9 e2 fa ff ff       	jmp    80104efe <alltraps>

8010541c <vector27>:
.globl vector27
vector27:
  pushl $0
8010541c:	6a 00                	push   $0x0
  pushl $27
8010541e:	6a 1b                	push   $0x1b
  jmp alltraps
80105420:	e9 d9 fa ff ff       	jmp    80104efe <alltraps>

80105425 <vector28>:
.globl vector28
vector28:
  pushl $0
80105425:	6a 00                	push   $0x0
  pushl $28
80105427:	6a 1c                	push   $0x1c
  jmp alltraps
80105429:	e9 d0 fa ff ff       	jmp    80104efe <alltraps>

8010542e <vector29>:
.globl vector29
vector29:
  pushl $0
8010542e:	6a 00                	push   $0x0
  pushl $29
80105430:	6a 1d                	push   $0x1d
  jmp alltraps
80105432:	e9 c7 fa ff ff       	jmp    80104efe <alltraps>

80105437 <vector30>:
.globl vector30
vector30:
  pushl $0
80105437:	6a 00                	push   $0x0
  pushl $30
80105439:	6a 1e                	push   $0x1e
  jmp alltraps
8010543b:	e9 be fa ff ff       	jmp    80104efe <alltraps>

80105440 <vector31>:
.globl vector31
vector31:
  pushl $0
80105440:	6a 00                	push   $0x0
  pushl $31
80105442:	6a 1f                	push   $0x1f
  jmp alltraps
80105444:	e9 b5 fa ff ff       	jmp    80104efe <alltraps>

80105449 <vector32>:
.globl vector32
vector32:
  pushl $0
80105449:	6a 00                	push   $0x0
  pushl $32
8010544b:	6a 20                	push   $0x20
  jmp alltraps
8010544d:	e9 ac fa ff ff       	jmp    80104efe <alltraps>

80105452 <vector33>:
.globl vector33
vector33:
  pushl $0
80105452:	6a 00                	push   $0x0
  pushl $33
80105454:	6a 21                	push   $0x21
  jmp alltraps
80105456:	e9 a3 fa ff ff       	jmp    80104efe <alltraps>

8010545b <vector34>:
.globl vector34
vector34:
  pushl $0
8010545b:	6a 00                	push   $0x0
  pushl $34
8010545d:	6a 22                	push   $0x22
  jmp alltraps
8010545f:	e9 9a fa ff ff       	jmp    80104efe <alltraps>

80105464 <vector35>:
.globl vector35
vector35:
  pushl $0
80105464:	6a 00                	push   $0x0
  pushl $35
80105466:	6a 23                	push   $0x23
  jmp alltraps
80105468:	e9 91 fa ff ff       	jmp    80104efe <alltraps>

8010546d <vector36>:
.globl vector36
vector36:
  pushl $0
8010546d:	6a 00                	push   $0x0
  pushl $36
8010546f:	6a 24                	push   $0x24
  jmp alltraps
80105471:	e9 88 fa ff ff       	jmp    80104efe <alltraps>

80105476 <vector37>:
.globl vector37
vector37:
  pushl $0
80105476:	6a 00                	push   $0x0
  pushl $37
80105478:	6a 25                	push   $0x25
  jmp alltraps
8010547a:	e9 7f fa ff ff       	jmp    80104efe <alltraps>

8010547f <vector38>:
.globl vector38
vector38:
  pushl $0
8010547f:	6a 00                	push   $0x0
  pushl $38
80105481:	6a 26                	push   $0x26
  jmp alltraps
80105483:	e9 76 fa ff ff       	jmp    80104efe <alltraps>

80105488 <vector39>:
.globl vector39
vector39:
  pushl $0
80105488:	6a 00                	push   $0x0
  pushl $39
8010548a:	6a 27                	push   $0x27
  jmp alltraps
8010548c:	e9 6d fa ff ff       	jmp    80104efe <alltraps>

80105491 <vector40>:
.globl vector40
vector40:
  pushl $0
80105491:	6a 00                	push   $0x0
  pushl $40
80105493:	6a 28                	push   $0x28
  jmp alltraps
80105495:	e9 64 fa ff ff       	jmp    80104efe <alltraps>

8010549a <vector41>:
.globl vector41
vector41:
  pushl $0
8010549a:	6a 00                	push   $0x0
  pushl $41
8010549c:	6a 29                	push   $0x29
  jmp alltraps
8010549e:	e9 5b fa ff ff       	jmp    80104efe <alltraps>

801054a3 <vector42>:
.globl vector42
vector42:
  pushl $0
801054a3:	6a 00                	push   $0x0
  pushl $42
801054a5:	6a 2a                	push   $0x2a
  jmp alltraps
801054a7:	e9 52 fa ff ff       	jmp    80104efe <alltraps>

801054ac <vector43>:
.globl vector43
vector43:
  pushl $0
801054ac:	6a 00                	push   $0x0
  pushl $43
801054ae:	6a 2b                	push   $0x2b
  jmp alltraps
801054b0:	e9 49 fa ff ff       	jmp    80104efe <alltraps>

801054b5 <vector44>:
.globl vector44
vector44:
  pushl $0
801054b5:	6a 00                	push   $0x0
  pushl $44
801054b7:	6a 2c                	push   $0x2c
  jmp alltraps
801054b9:	e9 40 fa ff ff       	jmp    80104efe <alltraps>

801054be <vector45>:
.globl vector45
vector45:
  pushl $0
801054be:	6a 00                	push   $0x0
  pushl $45
801054c0:	6a 2d                	push   $0x2d
  jmp alltraps
801054c2:	e9 37 fa ff ff       	jmp    80104efe <alltraps>

801054c7 <vector46>:
.globl vector46
vector46:
  pushl $0
801054c7:	6a 00                	push   $0x0
  pushl $46
801054c9:	6a 2e                	push   $0x2e
  jmp alltraps
801054cb:	e9 2e fa ff ff       	jmp    80104efe <alltraps>

801054d0 <vector47>:
.globl vector47
vector47:
  pushl $0
801054d0:	6a 00                	push   $0x0
  pushl $47
801054d2:	6a 2f                	push   $0x2f
  jmp alltraps
801054d4:	e9 25 fa ff ff       	jmp    80104efe <alltraps>

801054d9 <vector48>:
.globl vector48
vector48:
  pushl $0
801054d9:	6a 00                	push   $0x0
  pushl $48
801054db:	6a 30                	push   $0x30
  jmp alltraps
801054dd:	e9 1c fa ff ff       	jmp    80104efe <alltraps>

801054e2 <vector49>:
.globl vector49
vector49:
  pushl $0
801054e2:	6a 00                	push   $0x0
  pushl $49
801054e4:	6a 31                	push   $0x31
  jmp alltraps
801054e6:	e9 13 fa ff ff       	jmp    80104efe <alltraps>

801054eb <vector50>:
.globl vector50
vector50:
  pushl $0
801054eb:	6a 00                	push   $0x0
  pushl $50
801054ed:	6a 32                	push   $0x32
  jmp alltraps
801054ef:	e9 0a fa ff ff       	jmp    80104efe <alltraps>

801054f4 <vector51>:
.globl vector51
vector51:
  pushl $0
801054f4:	6a 00                	push   $0x0
  pushl $51
801054f6:	6a 33                	push   $0x33
  jmp alltraps
801054f8:	e9 01 fa ff ff       	jmp    80104efe <alltraps>

801054fd <vector52>:
.globl vector52
vector52:
  pushl $0
801054fd:	6a 00                	push   $0x0
  pushl $52
801054ff:	6a 34                	push   $0x34
  jmp alltraps
80105501:	e9 f8 f9 ff ff       	jmp    80104efe <alltraps>

80105506 <vector53>:
.globl vector53
vector53:
  pushl $0
80105506:	6a 00                	push   $0x0
  pushl $53
80105508:	6a 35                	push   $0x35
  jmp alltraps
8010550a:	e9 ef f9 ff ff       	jmp    80104efe <alltraps>

8010550f <vector54>:
.globl vector54
vector54:
  pushl $0
8010550f:	6a 00                	push   $0x0
  pushl $54
80105511:	6a 36                	push   $0x36
  jmp alltraps
80105513:	e9 e6 f9 ff ff       	jmp    80104efe <alltraps>

80105518 <vector55>:
.globl vector55
vector55:
  pushl $0
80105518:	6a 00                	push   $0x0
  pushl $55
8010551a:	6a 37                	push   $0x37
  jmp alltraps
8010551c:	e9 dd f9 ff ff       	jmp    80104efe <alltraps>

80105521 <vector56>:
.globl vector56
vector56:
  pushl $0
80105521:	6a 00                	push   $0x0
  pushl $56
80105523:	6a 38                	push   $0x38
  jmp alltraps
80105525:	e9 d4 f9 ff ff       	jmp    80104efe <alltraps>

8010552a <vector57>:
.globl vector57
vector57:
  pushl $0
8010552a:	6a 00                	push   $0x0
  pushl $57
8010552c:	6a 39                	push   $0x39
  jmp alltraps
8010552e:	e9 cb f9 ff ff       	jmp    80104efe <alltraps>

80105533 <vector58>:
.globl vector58
vector58:
  pushl $0
80105533:	6a 00                	push   $0x0
  pushl $58
80105535:	6a 3a                	push   $0x3a
  jmp alltraps
80105537:	e9 c2 f9 ff ff       	jmp    80104efe <alltraps>

8010553c <vector59>:
.globl vector59
vector59:
  pushl $0
8010553c:	6a 00                	push   $0x0
  pushl $59
8010553e:	6a 3b                	push   $0x3b
  jmp alltraps
80105540:	e9 b9 f9 ff ff       	jmp    80104efe <alltraps>

80105545 <vector60>:
.globl vector60
vector60:
  pushl $0
80105545:	6a 00                	push   $0x0
  pushl $60
80105547:	6a 3c                	push   $0x3c
  jmp alltraps
80105549:	e9 b0 f9 ff ff       	jmp    80104efe <alltraps>

8010554e <vector61>:
.globl vector61
vector61:
  pushl $0
8010554e:	6a 00                	push   $0x0
  pushl $61
80105550:	6a 3d                	push   $0x3d
  jmp alltraps
80105552:	e9 a7 f9 ff ff       	jmp    80104efe <alltraps>

80105557 <vector62>:
.globl vector62
vector62:
  pushl $0
80105557:	6a 00                	push   $0x0
  pushl $62
80105559:	6a 3e                	push   $0x3e
  jmp alltraps
8010555b:	e9 9e f9 ff ff       	jmp    80104efe <alltraps>

80105560 <vector63>:
.globl vector63
vector63:
  pushl $0
80105560:	6a 00                	push   $0x0
  pushl $63
80105562:	6a 3f                	push   $0x3f
  jmp alltraps
80105564:	e9 95 f9 ff ff       	jmp    80104efe <alltraps>

80105569 <vector64>:
.globl vector64
vector64:
  pushl $0
80105569:	6a 00                	push   $0x0
  pushl $64
8010556b:	6a 40                	push   $0x40
  jmp alltraps
8010556d:	e9 8c f9 ff ff       	jmp    80104efe <alltraps>

80105572 <vector65>:
.globl vector65
vector65:
  pushl $0
80105572:	6a 00                	push   $0x0
  pushl $65
80105574:	6a 41                	push   $0x41
  jmp alltraps
80105576:	e9 83 f9 ff ff       	jmp    80104efe <alltraps>

8010557b <vector66>:
.globl vector66
vector66:
  pushl $0
8010557b:	6a 00                	push   $0x0
  pushl $66
8010557d:	6a 42                	push   $0x42
  jmp alltraps
8010557f:	e9 7a f9 ff ff       	jmp    80104efe <alltraps>

80105584 <vector67>:
.globl vector67
vector67:
  pushl $0
80105584:	6a 00                	push   $0x0
  pushl $67
80105586:	6a 43                	push   $0x43
  jmp alltraps
80105588:	e9 71 f9 ff ff       	jmp    80104efe <alltraps>

8010558d <vector68>:
.globl vector68
vector68:
  pushl $0
8010558d:	6a 00                	push   $0x0
  pushl $68
8010558f:	6a 44                	push   $0x44
  jmp alltraps
80105591:	e9 68 f9 ff ff       	jmp    80104efe <alltraps>

80105596 <vector69>:
.globl vector69
vector69:
  pushl $0
80105596:	6a 00                	push   $0x0
  pushl $69
80105598:	6a 45                	push   $0x45
  jmp alltraps
8010559a:	e9 5f f9 ff ff       	jmp    80104efe <alltraps>

8010559f <vector70>:
.globl vector70
vector70:
  pushl $0
8010559f:	6a 00                	push   $0x0
  pushl $70
801055a1:	6a 46                	push   $0x46
  jmp alltraps
801055a3:	e9 56 f9 ff ff       	jmp    80104efe <alltraps>

801055a8 <vector71>:
.globl vector71
vector71:
  pushl $0
801055a8:	6a 00                	push   $0x0
  pushl $71
801055aa:	6a 47                	push   $0x47
  jmp alltraps
801055ac:	e9 4d f9 ff ff       	jmp    80104efe <alltraps>

801055b1 <vector72>:
.globl vector72
vector72:
  pushl $0
801055b1:	6a 00                	push   $0x0
  pushl $72
801055b3:	6a 48                	push   $0x48
  jmp alltraps
801055b5:	e9 44 f9 ff ff       	jmp    80104efe <alltraps>

801055ba <vector73>:
.globl vector73
vector73:
  pushl $0
801055ba:	6a 00                	push   $0x0
  pushl $73
801055bc:	6a 49                	push   $0x49
  jmp alltraps
801055be:	e9 3b f9 ff ff       	jmp    80104efe <alltraps>

801055c3 <vector74>:
.globl vector74
vector74:
  pushl $0
801055c3:	6a 00                	push   $0x0
  pushl $74
801055c5:	6a 4a                	push   $0x4a
  jmp alltraps
801055c7:	e9 32 f9 ff ff       	jmp    80104efe <alltraps>

801055cc <vector75>:
.globl vector75
vector75:
  pushl $0
801055cc:	6a 00                	push   $0x0
  pushl $75
801055ce:	6a 4b                	push   $0x4b
  jmp alltraps
801055d0:	e9 29 f9 ff ff       	jmp    80104efe <alltraps>

801055d5 <vector76>:
.globl vector76
vector76:
  pushl $0
801055d5:	6a 00                	push   $0x0
  pushl $76
801055d7:	6a 4c                	push   $0x4c
  jmp alltraps
801055d9:	e9 20 f9 ff ff       	jmp    80104efe <alltraps>

801055de <vector77>:
.globl vector77
vector77:
  pushl $0
801055de:	6a 00                	push   $0x0
  pushl $77
801055e0:	6a 4d                	push   $0x4d
  jmp alltraps
801055e2:	e9 17 f9 ff ff       	jmp    80104efe <alltraps>

801055e7 <vector78>:
.globl vector78
vector78:
  pushl $0
801055e7:	6a 00                	push   $0x0
  pushl $78
801055e9:	6a 4e                	push   $0x4e
  jmp alltraps
801055eb:	e9 0e f9 ff ff       	jmp    80104efe <alltraps>

801055f0 <vector79>:
.globl vector79
vector79:
  pushl $0
801055f0:	6a 00                	push   $0x0
  pushl $79
801055f2:	6a 4f                	push   $0x4f
  jmp alltraps
801055f4:	e9 05 f9 ff ff       	jmp    80104efe <alltraps>

801055f9 <vector80>:
.globl vector80
vector80:
  pushl $0
801055f9:	6a 00                	push   $0x0
  pushl $80
801055fb:	6a 50                	push   $0x50
  jmp alltraps
801055fd:	e9 fc f8 ff ff       	jmp    80104efe <alltraps>

80105602 <vector81>:
.globl vector81
vector81:
  pushl $0
80105602:	6a 00                	push   $0x0
  pushl $81
80105604:	6a 51                	push   $0x51
  jmp alltraps
80105606:	e9 f3 f8 ff ff       	jmp    80104efe <alltraps>

8010560b <vector82>:
.globl vector82
vector82:
  pushl $0
8010560b:	6a 00                	push   $0x0
  pushl $82
8010560d:	6a 52                	push   $0x52
  jmp alltraps
8010560f:	e9 ea f8 ff ff       	jmp    80104efe <alltraps>

80105614 <vector83>:
.globl vector83
vector83:
  pushl $0
80105614:	6a 00                	push   $0x0
  pushl $83
80105616:	6a 53                	push   $0x53
  jmp alltraps
80105618:	e9 e1 f8 ff ff       	jmp    80104efe <alltraps>

8010561d <vector84>:
.globl vector84
vector84:
  pushl $0
8010561d:	6a 00                	push   $0x0
  pushl $84
8010561f:	6a 54                	push   $0x54
  jmp alltraps
80105621:	e9 d8 f8 ff ff       	jmp    80104efe <alltraps>

80105626 <vector85>:
.globl vector85
vector85:
  pushl $0
80105626:	6a 00                	push   $0x0
  pushl $85
80105628:	6a 55                	push   $0x55
  jmp alltraps
8010562a:	e9 cf f8 ff ff       	jmp    80104efe <alltraps>

8010562f <vector86>:
.globl vector86
vector86:
  pushl $0
8010562f:	6a 00                	push   $0x0
  pushl $86
80105631:	6a 56                	push   $0x56
  jmp alltraps
80105633:	e9 c6 f8 ff ff       	jmp    80104efe <alltraps>

80105638 <vector87>:
.globl vector87
vector87:
  pushl $0
80105638:	6a 00                	push   $0x0
  pushl $87
8010563a:	6a 57                	push   $0x57
  jmp alltraps
8010563c:	e9 bd f8 ff ff       	jmp    80104efe <alltraps>

80105641 <vector88>:
.globl vector88
vector88:
  pushl $0
80105641:	6a 00                	push   $0x0
  pushl $88
80105643:	6a 58                	push   $0x58
  jmp alltraps
80105645:	e9 b4 f8 ff ff       	jmp    80104efe <alltraps>

8010564a <vector89>:
.globl vector89
vector89:
  pushl $0
8010564a:	6a 00                	push   $0x0
  pushl $89
8010564c:	6a 59                	push   $0x59
  jmp alltraps
8010564e:	e9 ab f8 ff ff       	jmp    80104efe <alltraps>

80105653 <vector90>:
.globl vector90
vector90:
  pushl $0
80105653:	6a 00                	push   $0x0
  pushl $90
80105655:	6a 5a                	push   $0x5a
  jmp alltraps
80105657:	e9 a2 f8 ff ff       	jmp    80104efe <alltraps>

8010565c <vector91>:
.globl vector91
vector91:
  pushl $0
8010565c:	6a 00                	push   $0x0
  pushl $91
8010565e:	6a 5b                	push   $0x5b
  jmp alltraps
80105660:	e9 99 f8 ff ff       	jmp    80104efe <alltraps>

80105665 <vector92>:
.globl vector92
vector92:
  pushl $0
80105665:	6a 00                	push   $0x0
  pushl $92
80105667:	6a 5c                	push   $0x5c
  jmp alltraps
80105669:	e9 90 f8 ff ff       	jmp    80104efe <alltraps>

8010566e <vector93>:
.globl vector93
vector93:
  pushl $0
8010566e:	6a 00                	push   $0x0
  pushl $93
80105670:	6a 5d                	push   $0x5d
  jmp alltraps
80105672:	e9 87 f8 ff ff       	jmp    80104efe <alltraps>

80105677 <vector94>:
.globl vector94
vector94:
  pushl $0
80105677:	6a 00                	push   $0x0
  pushl $94
80105679:	6a 5e                	push   $0x5e
  jmp alltraps
8010567b:	e9 7e f8 ff ff       	jmp    80104efe <alltraps>

80105680 <vector95>:
.globl vector95
vector95:
  pushl $0
80105680:	6a 00                	push   $0x0
  pushl $95
80105682:	6a 5f                	push   $0x5f
  jmp alltraps
80105684:	e9 75 f8 ff ff       	jmp    80104efe <alltraps>

80105689 <vector96>:
.globl vector96
vector96:
  pushl $0
80105689:	6a 00                	push   $0x0
  pushl $96
8010568b:	6a 60                	push   $0x60
  jmp alltraps
8010568d:	e9 6c f8 ff ff       	jmp    80104efe <alltraps>

80105692 <vector97>:
.globl vector97
vector97:
  pushl $0
80105692:	6a 00                	push   $0x0
  pushl $97
80105694:	6a 61                	push   $0x61
  jmp alltraps
80105696:	e9 63 f8 ff ff       	jmp    80104efe <alltraps>

8010569b <vector98>:
.globl vector98
vector98:
  pushl $0
8010569b:	6a 00                	push   $0x0
  pushl $98
8010569d:	6a 62                	push   $0x62
  jmp alltraps
8010569f:	e9 5a f8 ff ff       	jmp    80104efe <alltraps>

801056a4 <vector99>:
.globl vector99
vector99:
  pushl $0
801056a4:	6a 00                	push   $0x0
  pushl $99
801056a6:	6a 63                	push   $0x63
  jmp alltraps
801056a8:	e9 51 f8 ff ff       	jmp    80104efe <alltraps>

801056ad <vector100>:
.globl vector100
vector100:
  pushl $0
801056ad:	6a 00                	push   $0x0
  pushl $100
801056af:	6a 64                	push   $0x64
  jmp alltraps
801056b1:	e9 48 f8 ff ff       	jmp    80104efe <alltraps>

801056b6 <vector101>:
.globl vector101
vector101:
  pushl $0
801056b6:	6a 00                	push   $0x0
  pushl $101
801056b8:	6a 65                	push   $0x65
  jmp alltraps
801056ba:	e9 3f f8 ff ff       	jmp    80104efe <alltraps>

801056bf <vector102>:
.globl vector102
vector102:
  pushl $0
801056bf:	6a 00                	push   $0x0
  pushl $102
801056c1:	6a 66                	push   $0x66
  jmp alltraps
801056c3:	e9 36 f8 ff ff       	jmp    80104efe <alltraps>

801056c8 <vector103>:
.globl vector103
vector103:
  pushl $0
801056c8:	6a 00                	push   $0x0
  pushl $103
801056ca:	6a 67                	push   $0x67
  jmp alltraps
801056cc:	e9 2d f8 ff ff       	jmp    80104efe <alltraps>

801056d1 <vector104>:
.globl vector104
vector104:
  pushl $0
801056d1:	6a 00                	push   $0x0
  pushl $104
801056d3:	6a 68                	push   $0x68
  jmp alltraps
801056d5:	e9 24 f8 ff ff       	jmp    80104efe <alltraps>

801056da <vector105>:
.globl vector105
vector105:
  pushl $0
801056da:	6a 00                	push   $0x0
  pushl $105
801056dc:	6a 69                	push   $0x69
  jmp alltraps
801056de:	e9 1b f8 ff ff       	jmp    80104efe <alltraps>

801056e3 <vector106>:
.globl vector106
vector106:
  pushl $0
801056e3:	6a 00                	push   $0x0
  pushl $106
801056e5:	6a 6a                	push   $0x6a
  jmp alltraps
801056e7:	e9 12 f8 ff ff       	jmp    80104efe <alltraps>

801056ec <vector107>:
.globl vector107
vector107:
  pushl $0
801056ec:	6a 00                	push   $0x0
  pushl $107
801056ee:	6a 6b                	push   $0x6b
  jmp alltraps
801056f0:	e9 09 f8 ff ff       	jmp    80104efe <alltraps>

801056f5 <vector108>:
.globl vector108
vector108:
  pushl $0
801056f5:	6a 00                	push   $0x0
  pushl $108
801056f7:	6a 6c                	push   $0x6c
  jmp alltraps
801056f9:	e9 00 f8 ff ff       	jmp    80104efe <alltraps>

801056fe <vector109>:
.globl vector109
vector109:
  pushl $0
801056fe:	6a 00                	push   $0x0
  pushl $109
80105700:	6a 6d                	push   $0x6d
  jmp alltraps
80105702:	e9 f7 f7 ff ff       	jmp    80104efe <alltraps>

80105707 <vector110>:
.globl vector110
vector110:
  pushl $0
80105707:	6a 00                	push   $0x0
  pushl $110
80105709:	6a 6e                	push   $0x6e
  jmp alltraps
8010570b:	e9 ee f7 ff ff       	jmp    80104efe <alltraps>

80105710 <vector111>:
.globl vector111
vector111:
  pushl $0
80105710:	6a 00                	push   $0x0
  pushl $111
80105712:	6a 6f                	push   $0x6f
  jmp alltraps
80105714:	e9 e5 f7 ff ff       	jmp    80104efe <alltraps>

80105719 <vector112>:
.globl vector112
vector112:
  pushl $0
80105719:	6a 00                	push   $0x0
  pushl $112
8010571b:	6a 70                	push   $0x70
  jmp alltraps
8010571d:	e9 dc f7 ff ff       	jmp    80104efe <alltraps>

80105722 <vector113>:
.globl vector113
vector113:
  pushl $0
80105722:	6a 00                	push   $0x0
  pushl $113
80105724:	6a 71                	push   $0x71
  jmp alltraps
80105726:	e9 d3 f7 ff ff       	jmp    80104efe <alltraps>

8010572b <vector114>:
.globl vector114
vector114:
  pushl $0
8010572b:	6a 00                	push   $0x0
  pushl $114
8010572d:	6a 72                	push   $0x72
  jmp alltraps
8010572f:	e9 ca f7 ff ff       	jmp    80104efe <alltraps>

80105734 <vector115>:
.globl vector115
vector115:
  pushl $0
80105734:	6a 00                	push   $0x0
  pushl $115
80105736:	6a 73                	push   $0x73
  jmp alltraps
80105738:	e9 c1 f7 ff ff       	jmp    80104efe <alltraps>

8010573d <vector116>:
.globl vector116
vector116:
  pushl $0
8010573d:	6a 00                	push   $0x0
  pushl $116
8010573f:	6a 74                	push   $0x74
  jmp alltraps
80105741:	e9 b8 f7 ff ff       	jmp    80104efe <alltraps>

80105746 <vector117>:
.globl vector117
vector117:
  pushl $0
80105746:	6a 00                	push   $0x0
  pushl $117
80105748:	6a 75                	push   $0x75
  jmp alltraps
8010574a:	e9 af f7 ff ff       	jmp    80104efe <alltraps>

8010574f <vector118>:
.globl vector118
vector118:
  pushl $0
8010574f:	6a 00                	push   $0x0
  pushl $118
80105751:	6a 76                	push   $0x76
  jmp alltraps
80105753:	e9 a6 f7 ff ff       	jmp    80104efe <alltraps>

80105758 <vector119>:
.globl vector119
vector119:
  pushl $0
80105758:	6a 00                	push   $0x0
  pushl $119
8010575a:	6a 77                	push   $0x77
  jmp alltraps
8010575c:	e9 9d f7 ff ff       	jmp    80104efe <alltraps>

80105761 <vector120>:
.globl vector120
vector120:
  pushl $0
80105761:	6a 00                	push   $0x0
  pushl $120
80105763:	6a 78                	push   $0x78
  jmp alltraps
80105765:	e9 94 f7 ff ff       	jmp    80104efe <alltraps>

8010576a <vector121>:
.globl vector121
vector121:
  pushl $0
8010576a:	6a 00                	push   $0x0
  pushl $121
8010576c:	6a 79                	push   $0x79
  jmp alltraps
8010576e:	e9 8b f7 ff ff       	jmp    80104efe <alltraps>

80105773 <vector122>:
.globl vector122
vector122:
  pushl $0
80105773:	6a 00                	push   $0x0
  pushl $122
80105775:	6a 7a                	push   $0x7a
  jmp alltraps
80105777:	e9 82 f7 ff ff       	jmp    80104efe <alltraps>

8010577c <vector123>:
.globl vector123
vector123:
  pushl $0
8010577c:	6a 00                	push   $0x0
  pushl $123
8010577e:	6a 7b                	push   $0x7b
  jmp alltraps
80105780:	e9 79 f7 ff ff       	jmp    80104efe <alltraps>

80105785 <vector124>:
.globl vector124
vector124:
  pushl $0
80105785:	6a 00                	push   $0x0
  pushl $124
80105787:	6a 7c                	push   $0x7c
  jmp alltraps
80105789:	e9 70 f7 ff ff       	jmp    80104efe <alltraps>

8010578e <vector125>:
.globl vector125
vector125:
  pushl $0
8010578e:	6a 00                	push   $0x0
  pushl $125
80105790:	6a 7d                	push   $0x7d
  jmp alltraps
80105792:	e9 67 f7 ff ff       	jmp    80104efe <alltraps>

80105797 <vector126>:
.globl vector126
vector126:
  pushl $0
80105797:	6a 00                	push   $0x0
  pushl $126
80105799:	6a 7e                	push   $0x7e
  jmp alltraps
8010579b:	e9 5e f7 ff ff       	jmp    80104efe <alltraps>

801057a0 <vector127>:
.globl vector127
vector127:
  pushl $0
801057a0:	6a 00                	push   $0x0
  pushl $127
801057a2:	6a 7f                	push   $0x7f
  jmp alltraps
801057a4:	e9 55 f7 ff ff       	jmp    80104efe <alltraps>

801057a9 <vector128>:
.globl vector128
vector128:
  pushl $0
801057a9:	6a 00                	push   $0x0
  pushl $128
801057ab:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801057b0:	e9 49 f7 ff ff       	jmp    80104efe <alltraps>

801057b5 <vector129>:
.globl vector129
vector129:
  pushl $0
801057b5:	6a 00                	push   $0x0
  pushl $129
801057b7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801057bc:	e9 3d f7 ff ff       	jmp    80104efe <alltraps>

801057c1 <vector130>:
.globl vector130
vector130:
  pushl $0
801057c1:	6a 00                	push   $0x0
  pushl $130
801057c3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801057c8:	e9 31 f7 ff ff       	jmp    80104efe <alltraps>

801057cd <vector131>:
.globl vector131
vector131:
  pushl $0
801057cd:	6a 00                	push   $0x0
  pushl $131
801057cf:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801057d4:	e9 25 f7 ff ff       	jmp    80104efe <alltraps>

801057d9 <vector132>:
.globl vector132
vector132:
  pushl $0
801057d9:	6a 00                	push   $0x0
  pushl $132
801057db:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801057e0:	e9 19 f7 ff ff       	jmp    80104efe <alltraps>

801057e5 <vector133>:
.globl vector133
vector133:
  pushl $0
801057e5:	6a 00                	push   $0x0
  pushl $133
801057e7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801057ec:	e9 0d f7 ff ff       	jmp    80104efe <alltraps>

801057f1 <vector134>:
.globl vector134
vector134:
  pushl $0
801057f1:	6a 00                	push   $0x0
  pushl $134
801057f3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801057f8:	e9 01 f7 ff ff       	jmp    80104efe <alltraps>

801057fd <vector135>:
.globl vector135
vector135:
  pushl $0
801057fd:	6a 00                	push   $0x0
  pushl $135
801057ff:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105804:	e9 f5 f6 ff ff       	jmp    80104efe <alltraps>

80105809 <vector136>:
.globl vector136
vector136:
  pushl $0
80105809:	6a 00                	push   $0x0
  pushl $136
8010580b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105810:	e9 e9 f6 ff ff       	jmp    80104efe <alltraps>

80105815 <vector137>:
.globl vector137
vector137:
  pushl $0
80105815:	6a 00                	push   $0x0
  pushl $137
80105817:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010581c:	e9 dd f6 ff ff       	jmp    80104efe <alltraps>

80105821 <vector138>:
.globl vector138
vector138:
  pushl $0
80105821:	6a 00                	push   $0x0
  pushl $138
80105823:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105828:	e9 d1 f6 ff ff       	jmp    80104efe <alltraps>

8010582d <vector139>:
.globl vector139
vector139:
  pushl $0
8010582d:	6a 00                	push   $0x0
  pushl $139
8010582f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105834:	e9 c5 f6 ff ff       	jmp    80104efe <alltraps>

80105839 <vector140>:
.globl vector140
vector140:
  pushl $0
80105839:	6a 00                	push   $0x0
  pushl $140
8010583b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105840:	e9 b9 f6 ff ff       	jmp    80104efe <alltraps>

80105845 <vector141>:
.globl vector141
vector141:
  pushl $0
80105845:	6a 00                	push   $0x0
  pushl $141
80105847:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010584c:	e9 ad f6 ff ff       	jmp    80104efe <alltraps>

80105851 <vector142>:
.globl vector142
vector142:
  pushl $0
80105851:	6a 00                	push   $0x0
  pushl $142
80105853:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105858:	e9 a1 f6 ff ff       	jmp    80104efe <alltraps>

8010585d <vector143>:
.globl vector143
vector143:
  pushl $0
8010585d:	6a 00                	push   $0x0
  pushl $143
8010585f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105864:	e9 95 f6 ff ff       	jmp    80104efe <alltraps>

80105869 <vector144>:
.globl vector144
vector144:
  pushl $0
80105869:	6a 00                	push   $0x0
  pushl $144
8010586b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105870:	e9 89 f6 ff ff       	jmp    80104efe <alltraps>

80105875 <vector145>:
.globl vector145
vector145:
  pushl $0
80105875:	6a 00                	push   $0x0
  pushl $145
80105877:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010587c:	e9 7d f6 ff ff       	jmp    80104efe <alltraps>

80105881 <vector146>:
.globl vector146
vector146:
  pushl $0
80105881:	6a 00                	push   $0x0
  pushl $146
80105883:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105888:	e9 71 f6 ff ff       	jmp    80104efe <alltraps>

8010588d <vector147>:
.globl vector147
vector147:
  pushl $0
8010588d:	6a 00                	push   $0x0
  pushl $147
8010588f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105894:	e9 65 f6 ff ff       	jmp    80104efe <alltraps>

80105899 <vector148>:
.globl vector148
vector148:
  pushl $0
80105899:	6a 00                	push   $0x0
  pushl $148
8010589b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801058a0:	e9 59 f6 ff ff       	jmp    80104efe <alltraps>

801058a5 <vector149>:
.globl vector149
vector149:
  pushl $0
801058a5:	6a 00                	push   $0x0
  pushl $149
801058a7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801058ac:	e9 4d f6 ff ff       	jmp    80104efe <alltraps>

801058b1 <vector150>:
.globl vector150
vector150:
  pushl $0
801058b1:	6a 00                	push   $0x0
  pushl $150
801058b3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801058b8:	e9 41 f6 ff ff       	jmp    80104efe <alltraps>

801058bd <vector151>:
.globl vector151
vector151:
  pushl $0
801058bd:	6a 00                	push   $0x0
  pushl $151
801058bf:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801058c4:	e9 35 f6 ff ff       	jmp    80104efe <alltraps>

801058c9 <vector152>:
.globl vector152
vector152:
  pushl $0
801058c9:	6a 00                	push   $0x0
  pushl $152
801058cb:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801058d0:	e9 29 f6 ff ff       	jmp    80104efe <alltraps>

801058d5 <vector153>:
.globl vector153
vector153:
  pushl $0
801058d5:	6a 00                	push   $0x0
  pushl $153
801058d7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801058dc:	e9 1d f6 ff ff       	jmp    80104efe <alltraps>

801058e1 <vector154>:
.globl vector154
vector154:
  pushl $0
801058e1:	6a 00                	push   $0x0
  pushl $154
801058e3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801058e8:	e9 11 f6 ff ff       	jmp    80104efe <alltraps>

801058ed <vector155>:
.globl vector155
vector155:
  pushl $0
801058ed:	6a 00                	push   $0x0
  pushl $155
801058ef:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801058f4:	e9 05 f6 ff ff       	jmp    80104efe <alltraps>

801058f9 <vector156>:
.globl vector156
vector156:
  pushl $0
801058f9:	6a 00                	push   $0x0
  pushl $156
801058fb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105900:	e9 f9 f5 ff ff       	jmp    80104efe <alltraps>

80105905 <vector157>:
.globl vector157
vector157:
  pushl $0
80105905:	6a 00                	push   $0x0
  pushl $157
80105907:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010590c:	e9 ed f5 ff ff       	jmp    80104efe <alltraps>

80105911 <vector158>:
.globl vector158
vector158:
  pushl $0
80105911:	6a 00                	push   $0x0
  pushl $158
80105913:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105918:	e9 e1 f5 ff ff       	jmp    80104efe <alltraps>

8010591d <vector159>:
.globl vector159
vector159:
  pushl $0
8010591d:	6a 00                	push   $0x0
  pushl $159
8010591f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105924:	e9 d5 f5 ff ff       	jmp    80104efe <alltraps>

80105929 <vector160>:
.globl vector160
vector160:
  pushl $0
80105929:	6a 00                	push   $0x0
  pushl $160
8010592b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105930:	e9 c9 f5 ff ff       	jmp    80104efe <alltraps>

80105935 <vector161>:
.globl vector161
vector161:
  pushl $0
80105935:	6a 00                	push   $0x0
  pushl $161
80105937:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010593c:	e9 bd f5 ff ff       	jmp    80104efe <alltraps>

80105941 <vector162>:
.globl vector162
vector162:
  pushl $0
80105941:	6a 00                	push   $0x0
  pushl $162
80105943:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105948:	e9 b1 f5 ff ff       	jmp    80104efe <alltraps>

8010594d <vector163>:
.globl vector163
vector163:
  pushl $0
8010594d:	6a 00                	push   $0x0
  pushl $163
8010594f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105954:	e9 a5 f5 ff ff       	jmp    80104efe <alltraps>

80105959 <vector164>:
.globl vector164
vector164:
  pushl $0
80105959:	6a 00                	push   $0x0
  pushl $164
8010595b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105960:	e9 99 f5 ff ff       	jmp    80104efe <alltraps>

80105965 <vector165>:
.globl vector165
vector165:
  pushl $0
80105965:	6a 00                	push   $0x0
  pushl $165
80105967:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010596c:	e9 8d f5 ff ff       	jmp    80104efe <alltraps>

80105971 <vector166>:
.globl vector166
vector166:
  pushl $0
80105971:	6a 00                	push   $0x0
  pushl $166
80105973:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105978:	e9 81 f5 ff ff       	jmp    80104efe <alltraps>

8010597d <vector167>:
.globl vector167
vector167:
  pushl $0
8010597d:	6a 00                	push   $0x0
  pushl $167
8010597f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105984:	e9 75 f5 ff ff       	jmp    80104efe <alltraps>

80105989 <vector168>:
.globl vector168
vector168:
  pushl $0
80105989:	6a 00                	push   $0x0
  pushl $168
8010598b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105990:	e9 69 f5 ff ff       	jmp    80104efe <alltraps>

80105995 <vector169>:
.globl vector169
vector169:
  pushl $0
80105995:	6a 00                	push   $0x0
  pushl $169
80105997:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010599c:	e9 5d f5 ff ff       	jmp    80104efe <alltraps>

801059a1 <vector170>:
.globl vector170
vector170:
  pushl $0
801059a1:	6a 00                	push   $0x0
  pushl $170
801059a3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801059a8:	e9 51 f5 ff ff       	jmp    80104efe <alltraps>

801059ad <vector171>:
.globl vector171
vector171:
  pushl $0
801059ad:	6a 00                	push   $0x0
  pushl $171
801059af:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801059b4:	e9 45 f5 ff ff       	jmp    80104efe <alltraps>

801059b9 <vector172>:
.globl vector172
vector172:
  pushl $0
801059b9:	6a 00                	push   $0x0
  pushl $172
801059bb:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801059c0:	e9 39 f5 ff ff       	jmp    80104efe <alltraps>

801059c5 <vector173>:
.globl vector173
vector173:
  pushl $0
801059c5:	6a 00                	push   $0x0
  pushl $173
801059c7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801059cc:	e9 2d f5 ff ff       	jmp    80104efe <alltraps>

801059d1 <vector174>:
.globl vector174
vector174:
  pushl $0
801059d1:	6a 00                	push   $0x0
  pushl $174
801059d3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801059d8:	e9 21 f5 ff ff       	jmp    80104efe <alltraps>

801059dd <vector175>:
.globl vector175
vector175:
  pushl $0
801059dd:	6a 00                	push   $0x0
  pushl $175
801059df:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801059e4:	e9 15 f5 ff ff       	jmp    80104efe <alltraps>

801059e9 <vector176>:
.globl vector176
vector176:
  pushl $0
801059e9:	6a 00                	push   $0x0
  pushl $176
801059eb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801059f0:	e9 09 f5 ff ff       	jmp    80104efe <alltraps>

801059f5 <vector177>:
.globl vector177
vector177:
  pushl $0
801059f5:	6a 00                	push   $0x0
  pushl $177
801059f7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801059fc:	e9 fd f4 ff ff       	jmp    80104efe <alltraps>

80105a01 <vector178>:
.globl vector178
vector178:
  pushl $0
80105a01:	6a 00                	push   $0x0
  pushl $178
80105a03:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a08:	e9 f1 f4 ff ff       	jmp    80104efe <alltraps>

80105a0d <vector179>:
.globl vector179
vector179:
  pushl $0
80105a0d:	6a 00                	push   $0x0
  pushl $179
80105a0f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a14:	e9 e5 f4 ff ff       	jmp    80104efe <alltraps>

80105a19 <vector180>:
.globl vector180
vector180:
  pushl $0
80105a19:	6a 00                	push   $0x0
  pushl $180
80105a1b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a20:	e9 d9 f4 ff ff       	jmp    80104efe <alltraps>

80105a25 <vector181>:
.globl vector181
vector181:
  pushl $0
80105a25:	6a 00                	push   $0x0
  pushl $181
80105a27:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a2c:	e9 cd f4 ff ff       	jmp    80104efe <alltraps>

80105a31 <vector182>:
.globl vector182
vector182:
  pushl $0
80105a31:	6a 00                	push   $0x0
  pushl $182
80105a33:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a38:	e9 c1 f4 ff ff       	jmp    80104efe <alltraps>

80105a3d <vector183>:
.globl vector183
vector183:
  pushl $0
80105a3d:	6a 00                	push   $0x0
  pushl $183
80105a3f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a44:	e9 b5 f4 ff ff       	jmp    80104efe <alltraps>

80105a49 <vector184>:
.globl vector184
vector184:
  pushl $0
80105a49:	6a 00                	push   $0x0
  pushl $184
80105a4b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a50:	e9 a9 f4 ff ff       	jmp    80104efe <alltraps>

80105a55 <vector185>:
.globl vector185
vector185:
  pushl $0
80105a55:	6a 00                	push   $0x0
  pushl $185
80105a57:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a5c:	e9 9d f4 ff ff       	jmp    80104efe <alltraps>

80105a61 <vector186>:
.globl vector186
vector186:
  pushl $0
80105a61:	6a 00                	push   $0x0
  pushl $186
80105a63:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a68:	e9 91 f4 ff ff       	jmp    80104efe <alltraps>

80105a6d <vector187>:
.globl vector187
vector187:
  pushl $0
80105a6d:	6a 00                	push   $0x0
  pushl $187
80105a6f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a74:	e9 85 f4 ff ff       	jmp    80104efe <alltraps>

80105a79 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a79:	6a 00                	push   $0x0
  pushl $188
80105a7b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a80:	e9 79 f4 ff ff       	jmp    80104efe <alltraps>

80105a85 <vector189>:
.globl vector189
vector189:
  pushl $0
80105a85:	6a 00                	push   $0x0
  pushl $189
80105a87:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a8c:	e9 6d f4 ff ff       	jmp    80104efe <alltraps>

80105a91 <vector190>:
.globl vector190
vector190:
  pushl $0
80105a91:	6a 00                	push   $0x0
  pushl $190
80105a93:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a98:	e9 61 f4 ff ff       	jmp    80104efe <alltraps>

80105a9d <vector191>:
.globl vector191
vector191:
  pushl $0
80105a9d:	6a 00                	push   $0x0
  pushl $191
80105a9f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105aa4:	e9 55 f4 ff ff       	jmp    80104efe <alltraps>

80105aa9 <vector192>:
.globl vector192
vector192:
  pushl $0
80105aa9:	6a 00                	push   $0x0
  pushl $192
80105aab:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105ab0:	e9 49 f4 ff ff       	jmp    80104efe <alltraps>

80105ab5 <vector193>:
.globl vector193
vector193:
  pushl $0
80105ab5:	6a 00                	push   $0x0
  pushl $193
80105ab7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105abc:	e9 3d f4 ff ff       	jmp    80104efe <alltraps>

80105ac1 <vector194>:
.globl vector194
vector194:
  pushl $0
80105ac1:	6a 00                	push   $0x0
  pushl $194
80105ac3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105ac8:	e9 31 f4 ff ff       	jmp    80104efe <alltraps>

80105acd <vector195>:
.globl vector195
vector195:
  pushl $0
80105acd:	6a 00                	push   $0x0
  pushl $195
80105acf:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105ad4:	e9 25 f4 ff ff       	jmp    80104efe <alltraps>

80105ad9 <vector196>:
.globl vector196
vector196:
  pushl $0
80105ad9:	6a 00                	push   $0x0
  pushl $196
80105adb:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105ae0:	e9 19 f4 ff ff       	jmp    80104efe <alltraps>

80105ae5 <vector197>:
.globl vector197
vector197:
  pushl $0
80105ae5:	6a 00                	push   $0x0
  pushl $197
80105ae7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105aec:	e9 0d f4 ff ff       	jmp    80104efe <alltraps>

80105af1 <vector198>:
.globl vector198
vector198:
  pushl $0
80105af1:	6a 00                	push   $0x0
  pushl $198
80105af3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105af8:	e9 01 f4 ff ff       	jmp    80104efe <alltraps>

80105afd <vector199>:
.globl vector199
vector199:
  pushl $0
80105afd:	6a 00                	push   $0x0
  pushl $199
80105aff:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b04:	e9 f5 f3 ff ff       	jmp    80104efe <alltraps>

80105b09 <vector200>:
.globl vector200
vector200:
  pushl $0
80105b09:	6a 00                	push   $0x0
  pushl $200
80105b0b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b10:	e9 e9 f3 ff ff       	jmp    80104efe <alltraps>

80105b15 <vector201>:
.globl vector201
vector201:
  pushl $0
80105b15:	6a 00                	push   $0x0
  pushl $201
80105b17:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b1c:	e9 dd f3 ff ff       	jmp    80104efe <alltraps>

80105b21 <vector202>:
.globl vector202
vector202:
  pushl $0
80105b21:	6a 00                	push   $0x0
  pushl $202
80105b23:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b28:	e9 d1 f3 ff ff       	jmp    80104efe <alltraps>

80105b2d <vector203>:
.globl vector203
vector203:
  pushl $0
80105b2d:	6a 00                	push   $0x0
  pushl $203
80105b2f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b34:	e9 c5 f3 ff ff       	jmp    80104efe <alltraps>

80105b39 <vector204>:
.globl vector204
vector204:
  pushl $0
80105b39:	6a 00                	push   $0x0
  pushl $204
80105b3b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b40:	e9 b9 f3 ff ff       	jmp    80104efe <alltraps>

80105b45 <vector205>:
.globl vector205
vector205:
  pushl $0
80105b45:	6a 00                	push   $0x0
  pushl $205
80105b47:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b4c:	e9 ad f3 ff ff       	jmp    80104efe <alltraps>

80105b51 <vector206>:
.globl vector206
vector206:
  pushl $0
80105b51:	6a 00                	push   $0x0
  pushl $206
80105b53:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b58:	e9 a1 f3 ff ff       	jmp    80104efe <alltraps>

80105b5d <vector207>:
.globl vector207
vector207:
  pushl $0
80105b5d:	6a 00                	push   $0x0
  pushl $207
80105b5f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b64:	e9 95 f3 ff ff       	jmp    80104efe <alltraps>

80105b69 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b69:	6a 00                	push   $0x0
  pushl $208
80105b6b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b70:	e9 89 f3 ff ff       	jmp    80104efe <alltraps>

80105b75 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b75:	6a 00                	push   $0x0
  pushl $209
80105b77:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b7c:	e9 7d f3 ff ff       	jmp    80104efe <alltraps>

80105b81 <vector210>:
.globl vector210
vector210:
  pushl $0
80105b81:	6a 00                	push   $0x0
  pushl $210
80105b83:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b88:	e9 71 f3 ff ff       	jmp    80104efe <alltraps>

80105b8d <vector211>:
.globl vector211
vector211:
  pushl $0
80105b8d:	6a 00                	push   $0x0
  pushl $211
80105b8f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b94:	e9 65 f3 ff ff       	jmp    80104efe <alltraps>

80105b99 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b99:	6a 00                	push   $0x0
  pushl $212
80105b9b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105ba0:	e9 59 f3 ff ff       	jmp    80104efe <alltraps>

80105ba5 <vector213>:
.globl vector213
vector213:
  pushl $0
80105ba5:	6a 00                	push   $0x0
  pushl $213
80105ba7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105bac:	e9 4d f3 ff ff       	jmp    80104efe <alltraps>

80105bb1 <vector214>:
.globl vector214
vector214:
  pushl $0
80105bb1:	6a 00                	push   $0x0
  pushl $214
80105bb3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105bb8:	e9 41 f3 ff ff       	jmp    80104efe <alltraps>

80105bbd <vector215>:
.globl vector215
vector215:
  pushl $0
80105bbd:	6a 00                	push   $0x0
  pushl $215
80105bbf:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105bc4:	e9 35 f3 ff ff       	jmp    80104efe <alltraps>

80105bc9 <vector216>:
.globl vector216
vector216:
  pushl $0
80105bc9:	6a 00                	push   $0x0
  pushl $216
80105bcb:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105bd0:	e9 29 f3 ff ff       	jmp    80104efe <alltraps>

80105bd5 <vector217>:
.globl vector217
vector217:
  pushl $0
80105bd5:	6a 00                	push   $0x0
  pushl $217
80105bd7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105bdc:	e9 1d f3 ff ff       	jmp    80104efe <alltraps>

80105be1 <vector218>:
.globl vector218
vector218:
  pushl $0
80105be1:	6a 00                	push   $0x0
  pushl $218
80105be3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105be8:	e9 11 f3 ff ff       	jmp    80104efe <alltraps>

80105bed <vector219>:
.globl vector219
vector219:
  pushl $0
80105bed:	6a 00                	push   $0x0
  pushl $219
80105bef:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105bf4:	e9 05 f3 ff ff       	jmp    80104efe <alltraps>

80105bf9 <vector220>:
.globl vector220
vector220:
  pushl $0
80105bf9:	6a 00                	push   $0x0
  pushl $220
80105bfb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c00:	e9 f9 f2 ff ff       	jmp    80104efe <alltraps>

80105c05 <vector221>:
.globl vector221
vector221:
  pushl $0
80105c05:	6a 00                	push   $0x0
  pushl $221
80105c07:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c0c:	e9 ed f2 ff ff       	jmp    80104efe <alltraps>

80105c11 <vector222>:
.globl vector222
vector222:
  pushl $0
80105c11:	6a 00                	push   $0x0
  pushl $222
80105c13:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c18:	e9 e1 f2 ff ff       	jmp    80104efe <alltraps>

80105c1d <vector223>:
.globl vector223
vector223:
  pushl $0
80105c1d:	6a 00                	push   $0x0
  pushl $223
80105c1f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c24:	e9 d5 f2 ff ff       	jmp    80104efe <alltraps>

80105c29 <vector224>:
.globl vector224
vector224:
  pushl $0
80105c29:	6a 00                	push   $0x0
  pushl $224
80105c2b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c30:	e9 c9 f2 ff ff       	jmp    80104efe <alltraps>

80105c35 <vector225>:
.globl vector225
vector225:
  pushl $0
80105c35:	6a 00                	push   $0x0
  pushl $225
80105c37:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c3c:	e9 bd f2 ff ff       	jmp    80104efe <alltraps>

80105c41 <vector226>:
.globl vector226
vector226:
  pushl $0
80105c41:	6a 00                	push   $0x0
  pushl $226
80105c43:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c48:	e9 b1 f2 ff ff       	jmp    80104efe <alltraps>

80105c4d <vector227>:
.globl vector227
vector227:
  pushl $0
80105c4d:	6a 00                	push   $0x0
  pushl $227
80105c4f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c54:	e9 a5 f2 ff ff       	jmp    80104efe <alltraps>

80105c59 <vector228>:
.globl vector228
vector228:
  pushl $0
80105c59:	6a 00                	push   $0x0
  pushl $228
80105c5b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c60:	e9 99 f2 ff ff       	jmp    80104efe <alltraps>

80105c65 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c65:	6a 00                	push   $0x0
  pushl $229
80105c67:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c6c:	e9 8d f2 ff ff       	jmp    80104efe <alltraps>

80105c71 <vector230>:
.globl vector230
vector230:
  pushl $0
80105c71:	6a 00                	push   $0x0
  pushl $230
80105c73:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c78:	e9 81 f2 ff ff       	jmp    80104efe <alltraps>

80105c7d <vector231>:
.globl vector231
vector231:
  pushl $0
80105c7d:	6a 00                	push   $0x0
  pushl $231
80105c7f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c84:	e9 75 f2 ff ff       	jmp    80104efe <alltraps>

80105c89 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c89:	6a 00                	push   $0x0
  pushl $232
80105c8b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c90:	e9 69 f2 ff ff       	jmp    80104efe <alltraps>

80105c95 <vector233>:
.globl vector233
vector233:
  pushl $0
80105c95:	6a 00                	push   $0x0
  pushl $233
80105c97:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c9c:	e9 5d f2 ff ff       	jmp    80104efe <alltraps>

80105ca1 <vector234>:
.globl vector234
vector234:
  pushl $0
80105ca1:	6a 00                	push   $0x0
  pushl $234
80105ca3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105ca8:	e9 51 f2 ff ff       	jmp    80104efe <alltraps>

80105cad <vector235>:
.globl vector235
vector235:
  pushl $0
80105cad:	6a 00                	push   $0x0
  pushl $235
80105caf:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105cb4:	e9 45 f2 ff ff       	jmp    80104efe <alltraps>

80105cb9 <vector236>:
.globl vector236
vector236:
  pushl $0
80105cb9:	6a 00                	push   $0x0
  pushl $236
80105cbb:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105cc0:	e9 39 f2 ff ff       	jmp    80104efe <alltraps>

80105cc5 <vector237>:
.globl vector237
vector237:
  pushl $0
80105cc5:	6a 00                	push   $0x0
  pushl $237
80105cc7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105ccc:	e9 2d f2 ff ff       	jmp    80104efe <alltraps>

80105cd1 <vector238>:
.globl vector238
vector238:
  pushl $0
80105cd1:	6a 00                	push   $0x0
  pushl $238
80105cd3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105cd8:	e9 21 f2 ff ff       	jmp    80104efe <alltraps>

80105cdd <vector239>:
.globl vector239
vector239:
  pushl $0
80105cdd:	6a 00                	push   $0x0
  pushl $239
80105cdf:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105ce4:	e9 15 f2 ff ff       	jmp    80104efe <alltraps>

80105ce9 <vector240>:
.globl vector240
vector240:
  pushl $0
80105ce9:	6a 00                	push   $0x0
  pushl $240
80105ceb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105cf0:	e9 09 f2 ff ff       	jmp    80104efe <alltraps>

80105cf5 <vector241>:
.globl vector241
vector241:
  pushl $0
80105cf5:	6a 00                	push   $0x0
  pushl $241
80105cf7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105cfc:	e9 fd f1 ff ff       	jmp    80104efe <alltraps>

80105d01 <vector242>:
.globl vector242
vector242:
  pushl $0
80105d01:	6a 00                	push   $0x0
  pushl $242
80105d03:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d08:	e9 f1 f1 ff ff       	jmp    80104efe <alltraps>

80105d0d <vector243>:
.globl vector243
vector243:
  pushl $0
80105d0d:	6a 00                	push   $0x0
  pushl $243
80105d0f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d14:	e9 e5 f1 ff ff       	jmp    80104efe <alltraps>

80105d19 <vector244>:
.globl vector244
vector244:
  pushl $0
80105d19:	6a 00                	push   $0x0
  pushl $244
80105d1b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d20:	e9 d9 f1 ff ff       	jmp    80104efe <alltraps>

80105d25 <vector245>:
.globl vector245
vector245:
  pushl $0
80105d25:	6a 00                	push   $0x0
  pushl $245
80105d27:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d2c:	e9 cd f1 ff ff       	jmp    80104efe <alltraps>

80105d31 <vector246>:
.globl vector246
vector246:
  pushl $0
80105d31:	6a 00                	push   $0x0
  pushl $246
80105d33:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d38:	e9 c1 f1 ff ff       	jmp    80104efe <alltraps>

80105d3d <vector247>:
.globl vector247
vector247:
  pushl $0
80105d3d:	6a 00                	push   $0x0
  pushl $247
80105d3f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d44:	e9 b5 f1 ff ff       	jmp    80104efe <alltraps>

80105d49 <vector248>:
.globl vector248
vector248:
  pushl $0
80105d49:	6a 00                	push   $0x0
  pushl $248
80105d4b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d50:	e9 a9 f1 ff ff       	jmp    80104efe <alltraps>

80105d55 <vector249>:
.globl vector249
vector249:
  pushl $0
80105d55:	6a 00                	push   $0x0
  pushl $249
80105d57:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d5c:	e9 9d f1 ff ff       	jmp    80104efe <alltraps>

80105d61 <vector250>:
.globl vector250
vector250:
  pushl $0
80105d61:	6a 00                	push   $0x0
  pushl $250
80105d63:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d68:	e9 91 f1 ff ff       	jmp    80104efe <alltraps>

80105d6d <vector251>:
.globl vector251
vector251:
  pushl $0
80105d6d:	6a 00                	push   $0x0
  pushl $251
80105d6f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d74:	e9 85 f1 ff ff       	jmp    80104efe <alltraps>

80105d79 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d79:	6a 00                	push   $0x0
  pushl $252
80105d7b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d80:	e9 79 f1 ff ff       	jmp    80104efe <alltraps>

80105d85 <vector253>:
.globl vector253
vector253:
  pushl $0
80105d85:	6a 00                	push   $0x0
  pushl $253
80105d87:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d8c:	e9 6d f1 ff ff       	jmp    80104efe <alltraps>

80105d91 <vector254>:
.globl vector254
vector254:
  pushl $0
80105d91:	6a 00                	push   $0x0
  pushl $254
80105d93:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d98:	e9 61 f1 ff ff       	jmp    80104efe <alltraps>

80105d9d <vector255>:
.globl vector255
vector255:
  pushl $0
80105d9d:	6a 00                	push   $0x0
  pushl $255
80105d9f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105da4:	e9 55 f1 ff ff       	jmp    80104efe <alltraps>

80105da9 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105da9:	55                   	push   %ebp
80105daa:	89 e5                	mov    %esp,%ebp
80105dac:	57                   	push   %edi
80105dad:	56                   	push   %esi
80105dae:	53                   	push   %ebx
80105daf:	83 ec 0c             	sub    $0xc,%esp
80105db2:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105db4:	c1 ea 16             	shr    $0x16,%edx
80105db7:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105dba:	8b 1f                	mov    (%edi),%ebx
80105dbc:	f6 c3 01             	test   $0x1,%bl
80105dbf:	74 22                	je     80105de3 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105dc1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105dc7:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105dcd:	c1 ee 0c             	shr    $0xc,%esi
80105dd0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105dd6:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105dd9:	89 d8                	mov    %ebx,%eax
80105ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dde:	5b                   	pop    %ebx
80105ddf:	5e                   	pop    %esi
80105de0:	5f                   	pop    %edi
80105de1:	5d                   	pop    %ebp
80105de2:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105de3:	85 c9                	test   %ecx,%ecx
80105de5:	74 2b                	je     80105e12 <walkpgdir+0x69>
80105de7:	e8 cf c2 ff ff       	call   801020bb <kalloc>
80105dec:	89 c3                	mov    %eax,%ebx
80105dee:	85 c0                	test   %eax,%eax
80105df0:	74 e7                	je     80105dd9 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105df2:	83 ec 04             	sub    $0x4,%esp
80105df5:	68 00 10 00 00       	push   $0x1000
80105dfa:	6a 00                	push   $0x0
80105dfc:	50                   	push   %eax
80105dfd:	e8 f7 df ff ff       	call   80103df9 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e02:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105e08:	83 c8 07             	or     $0x7,%eax
80105e0b:	89 07                	mov    %eax,(%edi)
80105e0d:	83 c4 10             	add    $0x10,%esp
80105e10:	eb bb                	jmp    80105dcd <walkpgdir+0x24>
      return 0;
80105e12:	bb 00 00 00 00       	mov    $0x0,%ebx
80105e17:	eb c0                	jmp    80105dd9 <walkpgdir+0x30>

80105e19 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105e19:	55                   	push   %ebp
80105e1a:	89 e5                	mov    %esp,%ebp
80105e1c:	57                   	push   %edi
80105e1d:	56                   	push   %esi
80105e1e:	53                   	push   %ebx
80105e1f:	83 ec 1c             	sub    $0x1c,%esp
80105e22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e25:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105e28:	89 d3                	mov    %edx,%ebx
80105e2a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105e30:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105e34:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e3a:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e3f:	89 da                	mov    %ebx,%edx
80105e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e44:	e8 60 ff ff ff       	call   80105da9 <walkpgdir>
80105e49:	85 c0                	test   %eax,%eax
80105e4b:	74 2e                	je     80105e7b <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e4d:	f6 00 01             	testb  $0x1,(%eax)
80105e50:	75 1c                	jne    80105e6e <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e52:	89 f2                	mov    %esi,%edx
80105e54:	0b 55 0c             	or     0xc(%ebp),%edx
80105e57:	83 ca 01             	or     $0x1,%edx
80105e5a:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e5c:	39 fb                	cmp    %edi,%ebx
80105e5e:	74 28                	je     80105e88 <mappages+0x6f>
      break;
    a += PGSIZE;
80105e60:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e66:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e6c:	eb cc                	jmp    80105e3a <mappages+0x21>
      panic("remap");
80105e6e:	83 ec 0c             	sub    $0xc,%esp
80105e71:	68 2c 6f 10 80       	push   $0x80106f2c
80105e76:	e8 cd a4 ff ff       	call   80100348 <panic>
      return -1;
80105e7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e83:	5b                   	pop    %ebx
80105e84:	5e                   	pop    %esi
80105e85:	5f                   	pop    %edi
80105e86:	5d                   	pop    %ebp
80105e87:	c3                   	ret    
  return 0;
80105e88:	b8 00 00 00 00       	mov    $0x0,%eax
80105e8d:	eb f1                	jmp    80105e80 <mappages+0x67>

80105e8f <seginit>:
{
80105e8f:	55                   	push   %ebp
80105e90:	89 e5                	mov    %esp,%ebp
80105e92:	53                   	push   %ebx
80105e93:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e96:	e8 91 d4 ff ff       	call   8010332c <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e9b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105ea1:	66 c7 80 18 e6 1b 80 	movw   $0xffff,-0x7fe419e8(%eax)
80105ea8:	ff ff 
80105eaa:	66 c7 80 1a e6 1b 80 	movw   $0x0,-0x7fe419e6(%eax)
80105eb1:	00 00 
80105eb3:	c6 80 1c e6 1b 80 00 	movb   $0x0,-0x7fe419e4(%eax)
80105eba:	0f b6 88 1d e6 1b 80 	movzbl -0x7fe419e3(%eax),%ecx
80105ec1:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ec4:	83 c9 1a             	or     $0x1a,%ecx
80105ec7:	83 e1 9f             	and    $0xffffff9f,%ecx
80105eca:	83 c9 80             	or     $0xffffff80,%ecx
80105ecd:	88 88 1d e6 1b 80    	mov    %cl,-0x7fe419e3(%eax)
80105ed3:	0f b6 88 1e e6 1b 80 	movzbl -0x7fe419e2(%eax),%ecx
80105eda:	83 c9 0f             	or     $0xf,%ecx
80105edd:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ee0:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ee3:	88 88 1e e6 1b 80    	mov    %cl,-0x7fe419e2(%eax)
80105ee9:	c6 80 1f e6 1b 80 00 	movb   $0x0,-0x7fe419e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ef0:	66 c7 80 20 e6 1b 80 	movw   $0xffff,-0x7fe419e0(%eax)
80105ef7:	ff ff 
80105ef9:	66 c7 80 22 e6 1b 80 	movw   $0x0,-0x7fe419de(%eax)
80105f00:	00 00 
80105f02:	c6 80 24 e6 1b 80 00 	movb   $0x0,-0x7fe419dc(%eax)
80105f09:	0f b6 88 25 e6 1b 80 	movzbl -0x7fe419db(%eax),%ecx
80105f10:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f13:	83 c9 12             	or     $0x12,%ecx
80105f16:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f19:	83 c9 80             	or     $0xffffff80,%ecx
80105f1c:	88 88 25 e6 1b 80    	mov    %cl,-0x7fe419db(%eax)
80105f22:	0f b6 88 26 e6 1b 80 	movzbl -0x7fe419da(%eax),%ecx
80105f29:	83 c9 0f             	or     $0xf,%ecx
80105f2c:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f2f:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f32:	88 88 26 e6 1b 80    	mov    %cl,-0x7fe419da(%eax)
80105f38:	c6 80 27 e6 1b 80 00 	movb   $0x0,-0x7fe419d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f3f:	66 c7 80 28 e6 1b 80 	movw   $0xffff,-0x7fe419d8(%eax)
80105f46:	ff ff 
80105f48:	66 c7 80 2a e6 1b 80 	movw   $0x0,-0x7fe419d6(%eax)
80105f4f:	00 00 
80105f51:	c6 80 2c e6 1b 80 00 	movb   $0x0,-0x7fe419d4(%eax)
80105f58:	c6 80 2d e6 1b 80 fa 	movb   $0xfa,-0x7fe419d3(%eax)
80105f5f:	0f b6 88 2e e6 1b 80 	movzbl -0x7fe419d2(%eax),%ecx
80105f66:	83 c9 0f             	or     $0xf,%ecx
80105f69:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f6c:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f6f:	88 88 2e e6 1b 80    	mov    %cl,-0x7fe419d2(%eax)
80105f75:	c6 80 2f e6 1b 80 00 	movb   $0x0,-0x7fe419d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f7c:	66 c7 80 30 e6 1b 80 	movw   $0xffff,-0x7fe419d0(%eax)
80105f83:	ff ff 
80105f85:	66 c7 80 32 e6 1b 80 	movw   $0x0,-0x7fe419ce(%eax)
80105f8c:	00 00 
80105f8e:	c6 80 34 e6 1b 80 00 	movb   $0x0,-0x7fe419cc(%eax)
80105f95:	c6 80 35 e6 1b 80 f2 	movb   $0xf2,-0x7fe419cb(%eax)
80105f9c:	0f b6 88 36 e6 1b 80 	movzbl -0x7fe419ca(%eax),%ecx
80105fa3:	83 c9 0f             	or     $0xf,%ecx
80105fa6:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fa9:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fac:	88 88 36 e6 1b 80    	mov    %cl,-0x7fe419ca(%eax)
80105fb2:	c6 80 37 e6 1b 80 00 	movb   $0x0,-0x7fe419c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105fb9:	05 10 e6 1b 80       	add    $0x801be610,%eax
  pd[0] = size-1;
80105fbe:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105fc4:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105fc8:	c1 e8 10             	shr    $0x10,%eax
80105fcb:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fcf:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105fd2:	0f 01 10             	lgdtl  (%eax)
}
80105fd5:	83 c4 14             	add    $0x14,%esp
80105fd8:	5b                   	pop    %ebx
80105fd9:	5d                   	pop    %ebp
80105fda:	c3                   	ret    

80105fdb <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105fdb:	55                   	push   %ebp
80105fdc:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105fde:	a1 c4 12 1c 80       	mov    0x801c12c4,%eax
80105fe3:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fe8:	0f 22 d8             	mov    %eax,%cr3
}
80105feb:	5d                   	pop    %ebp
80105fec:	c3                   	ret    

80105fed <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	57                   	push   %edi
80105ff1:	56                   	push   %esi
80105ff2:	53                   	push   %ebx
80105ff3:	83 ec 1c             	sub    $0x1c,%esp
80105ff6:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ff9:	85 f6                	test   %esi,%esi
80105ffb:	0f 84 dd 00 00 00    	je     801060de <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106001:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106005:	0f 84 e0 00 00 00    	je     801060eb <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010600b:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
8010600f:	0f 84 e3 00 00 00    	je     801060f8 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80106015:	e8 56 dc ff ff       	call   80103c70 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010601a:	e8 b1 d2 ff ff       	call   801032d0 <mycpu>
8010601f:	89 c3                	mov    %eax,%ebx
80106021:	e8 aa d2 ff ff       	call   801032d0 <mycpu>
80106026:	8d 78 08             	lea    0x8(%eax),%edi
80106029:	e8 a2 d2 ff ff       	call   801032d0 <mycpu>
8010602e:	83 c0 08             	add    $0x8,%eax
80106031:	c1 e8 10             	shr    $0x10,%eax
80106034:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106037:	e8 94 d2 ff ff       	call   801032d0 <mycpu>
8010603c:	83 c0 08             	add    $0x8,%eax
8010603f:	c1 e8 18             	shr    $0x18,%eax
80106042:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106049:	67 00 
8010604b:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106052:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106056:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010605c:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106063:	83 e2 f0             	and    $0xfffffff0,%edx
80106066:	83 ca 19             	or     $0x19,%edx
80106069:	83 e2 9f             	and    $0xffffff9f,%edx
8010606c:	83 ca 80             	or     $0xffffff80,%edx
8010606f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106075:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
8010607c:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106082:	e8 49 d2 ff ff       	call   801032d0 <mycpu>
80106087:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010608e:	83 e2 ef             	and    $0xffffffef,%edx
80106091:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106097:	e8 34 d2 ff ff       	call   801032d0 <mycpu>
8010609c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801060a2:	8b 5e 08             	mov    0x8(%esi),%ebx
801060a5:	e8 26 d2 ff ff       	call   801032d0 <mycpu>
801060aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060b0:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801060b3:	e8 18 d2 ff ff       	call   801032d0 <mycpu>
801060b8:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801060be:	b8 28 00 00 00       	mov    $0x28,%eax
801060c3:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801060c6:	8b 46 04             	mov    0x4(%esi),%eax
801060c9:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060ce:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060d1:	e8 d7 db ff ff       	call   80103cad <popcli>
}
801060d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060d9:	5b                   	pop    %ebx
801060da:	5e                   	pop    %esi
801060db:	5f                   	pop    %edi
801060dc:	5d                   	pop    %ebp
801060dd:	c3                   	ret    
    panic("switchuvm: no process");
801060de:	83 ec 0c             	sub    $0xc,%esp
801060e1:	68 32 6f 10 80       	push   $0x80106f32
801060e6:	e8 5d a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801060eb:	83 ec 0c             	sub    $0xc,%esp
801060ee:	68 48 6f 10 80       	push   $0x80106f48
801060f3:	e8 50 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060f8:	83 ec 0c             	sub    $0xc,%esp
801060fb:	68 5d 6f 10 80       	push   $0x80106f5d
80106100:	e8 43 a2 ff ff       	call   80100348 <panic>

80106105 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106105:	55                   	push   %ebp
80106106:	89 e5                	mov    %esp,%ebp
80106108:	56                   	push   %esi
80106109:	53                   	push   %ebx
8010610a:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010610d:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106113:	77 4c                	ja     80106161 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80106115:	e8 a1 bf ff ff       	call   801020bb <kalloc>
8010611a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010611c:	83 ec 04             	sub    $0x4,%esp
8010611f:	68 00 10 00 00       	push   $0x1000
80106124:	6a 00                	push   $0x0
80106126:	50                   	push   %eax
80106127:	e8 cd dc ff ff       	call   80103df9 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010612c:	83 c4 08             	add    $0x8,%esp
8010612f:	6a 06                	push   $0x6
80106131:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106137:	50                   	push   %eax
80106138:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010613d:	ba 00 00 00 00       	mov    $0x0,%edx
80106142:	8b 45 08             	mov    0x8(%ebp),%eax
80106145:	e8 cf fc ff ff       	call   80105e19 <mappages>
  memmove(mem, init, sz);
8010614a:	83 c4 0c             	add    $0xc,%esp
8010614d:	56                   	push   %esi
8010614e:	ff 75 0c             	pushl  0xc(%ebp)
80106151:	53                   	push   %ebx
80106152:	e8 1d dd ff ff       	call   80103e74 <memmove>
}
80106157:	83 c4 10             	add    $0x10,%esp
8010615a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010615d:	5b                   	pop    %ebx
8010615e:	5e                   	pop    %esi
8010615f:	5d                   	pop    %ebp
80106160:	c3                   	ret    
    panic("inituvm: more than a page");
80106161:	83 ec 0c             	sub    $0xc,%esp
80106164:	68 71 6f 10 80       	push   $0x80106f71
80106169:	e8 da a1 ff ff       	call   80100348 <panic>

8010616e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010616e:	55                   	push   %ebp
8010616f:	89 e5                	mov    %esp,%ebp
80106171:	57                   	push   %edi
80106172:	56                   	push   %esi
80106173:	53                   	push   %ebx
80106174:	83 ec 0c             	sub    $0xc,%esp
80106177:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010617a:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106181:	75 07                	jne    8010618a <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106183:	bb 00 00 00 00       	mov    $0x0,%ebx
80106188:	eb 3c                	jmp    801061c6 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
8010618a:	83 ec 0c             	sub    $0xc,%esp
8010618d:	68 2c 70 10 80       	push   $0x8010702c
80106192:	e8 b1 a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106197:	83 ec 0c             	sub    $0xc,%esp
8010619a:	68 8b 6f 10 80       	push   $0x80106f8b
8010619f:	e8 a4 a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801061a4:	05 00 00 00 80       	add    $0x80000000,%eax
801061a9:	56                   	push   %esi
801061aa:	89 da                	mov    %ebx,%edx
801061ac:	03 55 14             	add    0x14(%ebp),%edx
801061af:	52                   	push   %edx
801061b0:	50                   	push   %eax
801061b1:	ff 75 10             	pushl  0x10(%ebp)
801061b4:	e8 ba b5 ff ff       	call   80101773 <readi>
801061b9:	83 c4 10             	add    $0x10,%esp
801061bc:	39 f0                	cmp    %esi,%eax
801061be:	75 47                	jne    80106207 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801061c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061c6:	39 fb                	cmp    %edi,%ebx
801061c8:	73 30                	jae    801061fa <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061ca:	89 da                	mov    %ebx,%edx
801061cc:	03 55 0c             	add    0xc(%ebp),%edx
801061cf:	b9 00 00 00 00       	mov    $0x0,%ecx
801061d4:	8b 45 08             	mov    0x8(%ebp),%eax
801061d7:	e8 cd fb ff ff       	call   80105da9 <walkpgdir>
801061dc:	85 c0                	test   %eax,%eax
801061de:	74 b7                	je     80106197 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061e0:	8b 00                	mov    (%eax),%eax
801061e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061e7:	89 fe                	mov    %edi,%esi
801061e9:	29 de                	sub    %ebx,%esi
801061eb:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061f1:	76 b1                	jbe    801061a4 <loaduvm+0x36>
      n = PGSIZE;
801061f3:	be 00 10 00 00       	mov    $0x1000,%esi
801061f8:	eb aa                	jmp    801061a4 <loaduvm+0x36>
      return -1;
  }
  return 0;
801061fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106202:	5b                   	pop    %ebx
80106203:	5e                   	pop    %esi
80106204:	5f                   	pop    %edi
80106205:	5d                   	pop    %ebp
80106206:	c3                   	ret    
      return -1;
80106207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620c:	eb f1                	jmp    801061ff <loaduvm+0x91>

8010620e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010620e:	55                   	push   %ebp
8010620f:	89 e5                	mov    %esp,%ebp
80106211:	57                   	push   %edi
80106212:	56                   	push   %esi
80106213:	53                   	push   %ebx
80106214:	83 ec 0c             	sub    $0xc,%esp
80106217:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010621a:	39 7d 10             	cmp    %edi,0x10(%ebp)
8010621d:	73 11                	jae    80106230 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010621f:	8b 45 10             	mov    0x10(%ebp),%eax
80106222:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106228:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010622e:	eb 19                	jmp    80106249 <deallocuvm+0x3b>
    return oldsz;
80106230:	89 f8                	mov    %edi,%eax
80106232:	eb 64                	jmp    80106298 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106234:	c1 eb 16             	shr    $0x16,%ebx
80106237:	83 c3 01             	add    $0x1,%ebx
8010623a:	c1 e3 16             	shl    $0x16,%ebx
8010623d:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106243:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106249:	39 fb                	cmp    %edi,%ebx
8010624b:	73 48                	jae    80106295 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010624d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106252:	89 da                	mov    %ebx,%edx
80106254:	8b 45 08             	mov    0x8(%ebp),%eax
80106257:	e8 4d fb ff ff       	call   80105da9 <walkpgdir>
8010625c:	89 c6                	mov    %eax,%esi
    if(!pte)
8010625e:	85 c0                	test   %eax,%eax
80106260:	74 d2                	je     80106234 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106262:	8b 00                	mov    (%eax),%eax
80106264:	a8 01                	test   $0x1,%al
80106266:	74 db                	je     80106243 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106268:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010626d:	74 19                	je     80106288 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010626f:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106274:	83 ec 0c             	sub    $0xc,%esp
80106277:	50                   	push   %eax
80106278:	e8 27 bd ff ff       	call   80101fa4 <kfree>
      *pte = 0;
8010627d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106283:	83 c4 10             	add    $0x10,%esp
80106286:	eb bb                	jmp    80106243 <deallocuvm+0x35>
        panic("kfree");
80106288:	83 ec 0c             	sub    $0xc,%esp
8010628b:	68 c6 68 10 80       	push   $0x801068c6
80106290:	e8 b3 a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106295:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106298:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010629b:	5b                   	pop    %ebx
8010629c:	5e                   	pop    %esi
8010629d:	5f                   	pop    %edi
8010629e:	5d                   	pop    %ebp
8010629f:	c3                   	ret    

801062a0 <allocuvm>:
{
801062a0:	55                   	push   %ebp
801062a1:	89 e5                	mov    %esp,%ebp
801062a3:	57                   	push   %edi
801062a4:	56                   	push   %esi
801062a5:	53                   	push   %ebx
801062a6:	83 ec 1c             	sub    $0x1c,%esp
801062a9:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801062ac:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801062af:	85 ff                	test   %edi,%edi
801062b1:	0f 88 c1 00 00 00    	js     80106378 <allocuvm+0xd8>
  if(newsz < oldsz)
801062b7:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062ba:	72 5c                	jb     80106318 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
801062bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801062bf:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801062cb:	39 fb                	cmp    %edi,%ebx
801062cd:	0f 83 ac 00 00 00    	jae    8010637f <allocuvm+0xdf>
    mem = kalloc();
801062d3:	e8 e3 bd ff ff       	call   801020bb <kalloc>
801062d8:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801062da:	85 c0                	test   %eax,%eax
801062dc:	74 42                	je     80106320 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
801062de:	83 ec 04             	sub    $0x4,%esp
801062e1:	68 00 10 00 00       	push   $0x1000
801062e6:	6a 00                	push   $0x0
801062e8:	50                   	push   %eax
801062e9:	e8 0b db ff ff       	call   80103df9 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801062ee:	83 c4 08             	add    $0x8,%esp
801062f1:	6a 06                	push   $0x6
801062f3:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801062f9:	50                   	push   %eax
801062fa:	b9 00 10 00 00       	mov    $0x1000,%ecx
801062ff:	89 da                	mov    %ebx,%edx
80106301:	8b 45 08             	mov    0x8(%ebp),%eax
80106304:	e8 10 fb ff ff       	call   80105e19 <mappages>
80106309:	83 c4 10             	add    $0x10,%esp
8010630c:	85 c0                	test   %eax,%eax
8010630e:	78 38                	js     80106348 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
80106310:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106316:	eb b3                	jmp    801062cb <allocuvm+0x2b>
    return oldsz;
80106318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010631b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010631e:	eb 5f                	jmp    8010637f <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
80106320:	83 ec 0c             	sub    $0xc,%esp
80106323:	68 a9 6f 10 80       	push   $0x80106fa9
80106328:	e8 de a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010632d:	83 c4 0c             	add    $0xc,%esp
80106330:	ff 75 0c             	pushl  0xc(%ebp)
80106333:	57                   	push   %edi
80106334:	ff 75 08             	pushl  0x8(%ebp)
80106337:	e8 d2 fe ff ff       	call   8010620e <deallocuvm>
      return 0;
8010633c:	83 c4 10             	add    $0x10,%esp
8010633f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106346:	eb 37                	jmp    8010637f <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106348:	83 ec 0c             	sub    $0xc,%esp
8010634b:	68 c1 6f 10 80       	push   $0x80106fc1
80106350:	e8 b6 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106355:	83 c4 0c             	add    $0xc,%esp
80106358:	ff 75 0c             	pushl  0xc(%ebp)
8010635b:	57                   	push   %edi
8010635c:	ff 75 08             	pushl  0x8(%ebp)
8010635f:	e8 aa fe ff ff       	call   8010620e <deallocuvm>
      kfree(mem);
80106364:	89 34 24             	mov    %esi,(%esp)
80106367:	e8 38 bc ff ff       	call   80101fa4 <kfree>
      return 0;
8010636c:	83 c4 10             	add    $0x10,%esp
8010636f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106376:	eb 07                	jmp    8010637f <allocuvm+0xdf>
    return 0;
80106378:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010637f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106382:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106385:	5b                   	pop    %ebx
80106386:	5e                   	pop    %esi
80106387:	5f                   	pop    %edi
80106388:	5d                   	pop    %ebp
80106389:	c3                   	ret    

8010638a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010638a:	55                   	push   %ebp
8010638b:	89 e5                	mov    %esp,%ebp
8010638d:	56                   	push   %esi
8010638e:	53                   	push   %ebx
8010638f:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106392:	85 f6                	test   %esi,%esi
80106394:	74 1a                	je     801063b0 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106396:	83 ec 04             	sub    $0x4,%esp
80106399:	6a 00                	push   $0x0
8010639b:	68 00 00 00 80       	push   $0x80000000
801063a0:	56                   	push   %esi
801063a1:	e8 68 fe ff ff       	call   8010620e <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801063a6:	83 c4 10             	add    $0x10,%esp
801063a9:	bb 00 00 00 00       	mov    $0x0,%ebx
801063ae:	eb 10                	jmp    801063c0 <freevm+0x36>
    panic("freevm: no pgdir");
801063b0:	83 ec 0c             	sub    $0xc,%esp
801063b3:	68 dd 6f 10 80       	push   $0x80106fdd
801063b8:	e8 8b 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801063bd:	83 c3 01             	add    $0x1,%ebx
801063c0:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801063c6:	77 1f                	ja     801063e7 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801063c8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801063cb:	a8 01                	test   $0x1,%al
801063cd:	74 ee                	je     801063bd <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801063cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063d4:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801063d9:	83 ec 0c             	sub    $0xc,%esp
801063dc:	50                   	push   %eax
801063dd:	e8 c2 bb ff ff       	call   80101fa4 <kfree>
801063e2:	83 c4 10             	add    $0x10,%esp
801063e5:	eb d6                	jmp    801063bd <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801063e7:	83 ec 0c             	sub    $0xc,%esp
801063ea:	56                   	push   %esi
801063eb:	e8 b4 bb ff ff       	call   80101fa4 <kfree>
}
801063f0:	83 c4 10             	add    $0x10,%esp
801063f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063f6:	5b                   	pop    %ebx
801063f7:	5e                   	pop    %esi
801063f8:	5d                   	pop    %ebp
801063f9:	c3                   	ret    

801063fa <setupkvm>:
{
801063fa:	55                   	push   %ebp
801063fb:	89 e5                	mov    %esp,%ebp
801063fd:	56                   	push   %esi
801063fe:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801063ff:	e8 b7 bc ff ff       	call   801020bb <kalloc>
80106404:	89 c6                	mov    %eax,%esi
80106406:	85 c0                	test   %eax,%eax
80106408:	74 55                	je     8010645f <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
8010640a:	83 ec 04             	sub    $0x4,%esp
8010640d:	68 00 10 00 00       	push   $0x1000
80106412:	6a 00                	push   $0x0
80106414:	50                   	push   %eax
80106415:	e8 df d9 ff ff       	call   80103df9 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010641a:	83 c4 10             	add    $0x10,%esp
8010641d:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106422:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106428:	73 35                	jae    8010645f <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
8010642a:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010642d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106430:	29 c1                	sub    %eax,%ecx
80106432:	83 ec 08             	sub    $0x8,%esp
80106435:	ff 73 0c             	pushl  0xc(%ebx)
80106438:	50                   	push   %eax
80106439:	8b 13                	mov    (%ebx),%edx
8010643b:	89 f0                	mov    %esi,%eax
8010643d:	e8 d7 f9 ff ff       	call   80105e19 <mappages>
80106442:	83 c4 10             	add    $0x10,%esp
80106445:	85 c0                	test   %eax,%eax
80106447:	78 05                	js     8010644e <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106449:	83 c3 10             	add    $0x10,%ebx
8010644c:	eb d4                	jmp    80106422 <setupkvm+0x28>
      freevm(pgdir);
8010644e:	83 ec 0c             	sub    $0xc,%esp
80106451:	56                   	push   %esi
80106452:	e8 33 ff ff ff       	call   8010638a <freevm>
      return 0;
80106457:	83 c4 10             	add    $0x10,%esp
8010645a:	be 00 00 00 00       	mov    $0x0,%esi
}
8010645f:	89 f0                	mov    %esi,%eax
80106461:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106464:	5b                   	pop    %ebx
80106465:	5e                   	pop    %esi
80106466:	5d                   	pop    %ebp
80106467:	c3                   	ret    

80106468 <kvmalloc>:
{
80106468:	55                   	push   %ebp
80106469:	89 e5                	mov    %esp,%ebp
8010646b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010646e:	e8 87 ff ff ff       	call   801063fa <setupkvm>
80106473:	a3 c4 12 1c 80       	mov    %eax,0x801c12c4
  switchkvm();
80106478:	e8 5e fb ff ff       	call   80105fdb <switchkvm>
}
8010647d:	c9                   	leave  
8010647e:	c3                   	ret    

8010647f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010647f:	55                   	push   %ebp
80106480:	89 e5                	mov    %esp,%ebp
80106482:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106485:	b9 00 00 00 00       	mov    $0x0,%ecx
8010648a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010648d:	8b 45 08             	mov    0x8(%ebp),%eax
80106490:	e8 14 f9 ff ff       	call   80105da9 <walkpgdir>
  if(pte == 0)
80106495:	85 c0                	test   %eax,%eax
80106497:	74 05                	je     8010649e <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106499:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010649c:	c9                   	leave  
8010649d:	c3                   	ret    
    panic("clearpteu");
8010649e:	83 ec 0c             	sub    $0xc,%esp
801064a1:	68 ee 6f 10 80       	push   $0x80106fee
801064a6:	e8 9d 9e ff ff       	call   80100348 <panic>

801064ab <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801064ab:	55                   	push   %ebp
801064ac:	89 e5                	mov    %esp,%ebp
801064ae:	57                   	push   %edi
801064af:	56                   	push   %esi
801064b0:	53                   	push   %ebx
801064b1:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801064b4:	e8 41 ff ff ff       	call   801063fa <setupkvm>
801064b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
801064bc:	85 c0                	test   %eax,%eax
801064be:	0f 84 c4 00 00 00    	je     80106588 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801064c4:	bf 00 00 00 00       	mov    $0x0,%edi
801064c9:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801064cc:	0f 83 b6 00 00 00    	jae    80106588 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801064d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801064d5:	b9 00 00 00 00       	mov    $0x0,%ecx
801064da:	89 fa                	mov    %edi,%edx
801064dc:	8b 45 08             	mov    0x8(%ebp),%eax
801064df:	e8 c5 f8 ff ff       	call   80105da9 <walkpgdir>
801064e4:	85 c0                	test   %eax,%eax
801064e6:	74 65                	je     8010654d <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801064e8:	8b 00                	mov    (%eax),%eax
801064ea:	a8 01                	test   $0x1,%al
801064ec:	74 6c                	je     8010655a <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801064ee:	89 c6                	mov    %eax,%esi
801064f0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801064f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801064fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801064fe:	e8 b8 bb ff ff       	call   801020bb <kalloc>
80106503:	89 c3                	mov    %eax,%ebx
80106505:	85 c0                	test   %eax,%eax
80106507:	74 6a                	je     80106573 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106509:	81 c6 00 00 00 80    	add    $0x80000000,%esi
8010650f:	83 ec 04             	sub    $0x4,%esp
80106512:	68 00 10 00 00       	push   $0x1000
80106517:	56                   	push   %esi
80106518:	50                   	push   %eax
80106519:	e8 56 d9 ff ff       	call   80103e74 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010651e:	83 c4 08             	add    $0x8,%esp
80106521:	ff 75 e0             	pushl  -0x20(%ebp)
80106524:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010652a:	50                   	push   %eax
8010652b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106530:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106533:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106536:	e8 de f8 ff ff       	call   80105e19 <mappages>
8010653b:	83 c4 10             	add    $0x10,%esp
8010653e:	85 c0                	test   %eax,%eax
80106540:	78 25                	js     80106567 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106542:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106548:	e9 7c ff ff ff       	jmp    801064c9 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
8010654d:	83 ec 0c             	sub    $0xc,%esp
80106550:	68 f8 6f 10 80       	push   $0x80106ff8
80106555:	e8 ee 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
8010655a:	83 ec 0c             	sub    $0xc,%esp
8010655d:	68 12 70 10 80       	push   $0x80107012
80106562:	e8 e1 9d ff ff       	call   80100348 <panic>
      kfree(mem);
80106567:	83 ec 0c             	sub    $0xc,%esp
8010656a:	53                   	push   %ebx
8010656b:	e8 34 ba ff ff       	call   80101fa4 <kfree>
      goto bad;
80106570:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106573:	83 ec 0c             	sub    $0xc,%esp
80106576:	ff 75 dc             	pushl  -0x24(%ebp)
80106579:	e8 0c fe ff ff       	call   8010638a <freevm>
  return 0;
8010657e:	83 c4 10             	add    $0x10,%esp
80106581:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106588:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010658b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010658e:	5b                   	pop    %ebx
8010658f:	5e                   	pop    %esi
80106590:	5f                   	pop    %edi
80106591:	5d                   	pop    %ebp
80106592:	c3                   	ret    

80106593 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106593:	55                   	push   %ebp
80106594:	89 e5                	mov    %esp,%ebp
80106596:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106599:	b9 00 00 00 00       	mov    $0x0,%ecx
8010659e:	8b 55 0c             	mov    0xc(%ebp),%edx
801065a1:	8b 45 08             	mov    0x8(%ebp),%eax
801065a4:	e8 00 f8 ff ff       	call   80105da9 <walkpgdir>
  if((*pte & PTE_P) == 0)
801065a9:	8b 00                	mov    (%eax),%eax
801065ab:	a8 01                	test   $0x1,%al
801065ad:	74 10                	je     801065bf <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801065af:	a8 04                	test   $0x4,%al
801065b1:	74 13                	je     801065c6 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065b8:	05 00 00 00 80       	add    $0x80000000,%eax
}
801065bd:	c9                   	leave  
801065be:	c3                   	ret    
    return 0;
801065bf:	b8 00 00 00 00       	mov    $0x0,%eax
801065c4:	eb f7                	jmp    801065bd <uva2ka+0x2a>
    return 0;
801065c6:	b8 00 00 00 00       	mov    $0x0,%eax
801065cb:	eb f0                	jmp    801065bd <uva2ka+0x2a>

801065cd <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801065cd:	55                   	push   %ebp
801065ce:	89 e5                	mov    %esp,%ebp
801065d0:	57                   	push   %edi
801065d1:	56                   	push   %esi
801065d2:	53                   	push   %ebx
801065d3:	83 ec 0c             	sub    $0xc,%esp
801065d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801065d9:	eb 25                	jmp    80106600 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801065db:	8b 55 0c             	mov    0xc(%ebp),%edx
801065de:	29 f2                	sub    %esi,%edx
801065e0:	01 d0                	add    %edx,%eax
801065e2:	83 ec 04             	sub    $0x4,%esp
801065e5:	53                   	push   %ebx
801065e6:	ff 75 10             	pushl  0x10(%ebp)
801065e9:	50                   	push   %eax
801065ea:	e8 85 d8 ff ff       	call   80103e74 <memmove>
    len -= n;
801065ef:	29 df                	sub    %ebx,%edi
    buf += n;
801065f1:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801065f4:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801065fa:	89 45 0c             	mov    %eax,0xc(%ebp)
801065fd:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106600:	85 ff                	test   %edi,%edi
80106602:	74 2f                	je     80106633 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106604:	8b 75 0c             	mov    0xc(%ebp),%esi
80106607:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010660d:	83 ec 08             	sub    $0x8,%esp
80106610:	56                   	push   %esi
80106611:	ff 75 08             	pushl  0x8(%ebp)
80106614:	e8 7a ff ff ff       	call   80106593 <uva2ka>
    if(pa0 == 0)
80106619:	83 c4 10             	add    $0x10,%esp
8010661c:	85 c0                	test   %eax,%eax
8010661e:	74 20                	je     80106640 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106620:	89 f3                	mov    %esi,%ebx
80106622:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106625:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
8010662b:	39 df                	cmp    %ebx,%edi
8010662d:	73 ac                	jae    801065db <copyout+0xe>
      n = len;
8010662f:	89 fb                	mov    %edi,%ebx
80106631:	eb a8                	jmp    801065db <copyout+0xe>
  }
  return 0;
80106633:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106638:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010663b:	5b                   	pop    %ebx
8010663c:	5e                   	pop    %esi
8010663d:	5f                   	pop    %edi
8010663e:	5d                   	pop    %ebp
8010663f:	c3                   	ret    
      return -1;
80106640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106645:	eb f1                	jmp    80106638 <copyout+0x6b>
