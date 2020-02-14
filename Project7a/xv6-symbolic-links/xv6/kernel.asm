
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
8010002d:	b8 8e 2b 10 80       	mov    $0x80102b8e,%eax
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
80100046:	e8 74 3c 00 00       	call   80103cbf <acquire>

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
8010007c:	e8 a3 3c 00 00       	call   80103d24 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 1f 3a 00 00       	call   80103aab <acquiresleep>
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
801000ca:	e8 55 3c 00 00       	call   80103d24 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 d1 39 00 00       	call   80103aab <acquiresleep>
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
801000ea:	68 00 66 10 80       	push   $0x80106600
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 11 66 10 80       	push   $0x80106611
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 79 3a 00 00       	call   80103b83 <initlock>
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
8010013a:	68 18 66 10 80       	push   $0x80106618
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 30 39 00 00       	call   80103a78 <initsleeplock>
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
80100190:	e8 a1 1d 00 00       	call   80101f36 <iderw>
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
801001a8:	e8 88 39 00 00       	call   80103b35 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 76 1d 00 00       	call   80101f36 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 1f 66 10 80       	push   $0x8010661f
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
801001e4:	e8 4c 39 00 00       	call   80103b35 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 01 39 00 00       	call   80103afa <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 ba 3a 00 00       	call   80103cbf <acquire>
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
8010024c:	e8 d3 3a 00 00       	call   80103d24 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 26 66 10 80       	push   $0x80106626
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
8010028a:	e8 30 3a 00 00       	call   80103cbf <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 74 30 00 00       	call   80103320 <myproc>
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
801002bf:	e8 00 35 00 00       	call   801037c4 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 4e 3a 00 00       	call   80103d24 <release>
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
80100331:	e8 ee 39 00 00       	call   80103d24 <release>
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
8010035a:	e8 49 21 00 00       	call   801024a8 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 2d 66 10 80       	push   $0x8010662d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 9f 6f 10 80 	movl   $0x80106f9f,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 0a 38 00 00       	call   80103b9e <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 41 66 10 80       	push   $0x80106641
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
8010049e:	68 45 66 10 80       	push   $0x80106645
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 27 39 00 00       	call   80103de6 <memmove>
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
801004d9:	e8 8d 38 00 00       	call   80103d6b <memset>
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
80100506:	e8 e3 4c 00 00       	call   801051ee <uartputc>
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
8010051f:	e8 ca 4c 00 00       	call   801051ee <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 be 4c 00 00       	call   801051ee <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 b2 4c 00 00       	call   801051ee <uartputc>
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
80100576:	0f b6 92 70 66 10 80 	movzbl -0x7fef9990(%edx),%edx
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
801005ca:	e8 f0 36 00 00       	call   80103cbf <acquire>
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
801005f1:	e8 2e 37 00 00       	call   80103d24 <release>
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
80100638:	e8 82 36 00 00       	call   80103cbf <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 5f 66 10 80       	push   $0x8010665f
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
801006ee:	be 58 66 10 80       	mov    $0x80106658,%esi
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
80100734:	e8 eb 35 00 00       	call   80103d24 <release>
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
8010074f:	e8 6b 35 00 00       	call   80103cbf <acquire>
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
801007de:	e8 46 31 00 00       	call   80103929 <wakeup>
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
80100873:	e8 ac 34 00 00       	call   80103d24 <release>
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
80100887:	e8 3a 31 00 00       	call   801039c6 <procdump>
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
80100894:	68 68 66 10 80       	push   $0x80106668
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 e0 32 00 00       	call   80103b83 <initlock>

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
801008c8:	e8 db 17 00 00       	call   801020a8 <ioapicenable>
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
801008de:	e8 3d 2a 00 00       	call   80103320 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 ea 1f 00 00       	call   801028d8 <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 06 14 00 00       	call   80101cff <namei>
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
80100935:	e8 18 20 00 00       	call   80102952 <end_op>
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
8010094a:	e8 03 20 00 00       	call   80102952 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 81 66 10 80       	push   $0x80106681
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
80100972:	e8 37 5a 00 00       	call   801063ae <setupkvm>
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
80100a06:	e8 49 58 00 00       	call   80106254 <allocuvm>
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
80100a38:	e8 e5 56 00 00       	call   80106122 <loaduvm>
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
80100a53:	e8 fa 1e 00 00       	call   80102952 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 db 57 00 00       	call   80106254 <allocuvm>
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
80100a9d:	e8 9c 58 00 00       	call   8010633e <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 72 59 00 00       	call   80106433 <clearpteu>
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
80100ae2:	e8 26 34 00 00       	call   80103f0d <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 14 34 00 00       	call   80103f0d <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 76 5a 00 00       	call   80106581 <copyout>
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
80100b66:	e8 16 5a 00 00       	call   80106581 <copyout>
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
80100ba3:	e8 2a 33 00 00       	call   80103ed2 <safestrcpy>
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
80100bd1:	e8 cb 53 00 00       	call   80105fa1 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 60 57 00 00       	call   8010633e <freevm>
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
80100c19:	68 8d 66 10 80       	push   $0x8010668d
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 5b 2f 00 00       	call   80103b83 <initlock>
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
80100c39:	e8 81 30 00 00       	call   80103cbf <acquire>
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
80100c68:	e8 b7 30 00 00       	call   80103d24 <release>
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
80100c7f:	e8 a0 30 00 00       	call   80103d24 <release>
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
80100c9d:	e8 1d 30 00 00       	call   80103cbf <acquire>
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
80100cba:	e8 65 30 00 00       	call   80103d24 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 94 66 10 80       	push   $0x80106694
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
80100ce2:	e8 d8 2f 00 00       	call   80103cbf <acquire>
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
80100d03:	e8 1c 30 00 00       	call   80103d24 <release>
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
80100d13:	68 9c 66 10 80       	push   $0x8010669c
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
80100d49:	e8 d6 2f 00 00       	call   80103d24 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 75 1b 00 00       	call   801028d8 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 df 1b 00 00       	call   80102952 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 c4 21 00 00       	call   80102f4c <pipeclose>
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
80100e3c:	e8 63 22 00 00       	call   801030a4 <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 a6 66 10 80       	push   $0x801066a6
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
80100e95:	e8 3e 21 00 00       	call   80102fd8 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 31 1a 00 00       	call   801028d8 <begin_op>
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
80100edd:	e8 70 1a 00 00       	call   80102952 <end_op>

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
80100f10:	68 af 66 10 80       	push   $0x801066af
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
80100f2d:	68 b5 66 10 80       	push   $0x801066b5
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
80100f8a:	e8 57 2e 00 00       	call   80103de6 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 47 2e 00 00       	call   80103de6 <memmove>
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
80100fdf:	e8 87 2d 00 00       	call   80103d6b <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 15 1a 00 00       	call   80102a01 <log_write>
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
801010a3:	68 bf 66 10 80       	push   $0x801066bf
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
801010bf:	e8 3d 19 00 00       	call   80102a01 <log_write>
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
80101170:	e8 8c 18 00 00       	call   80102a01 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 d5 66 10 80       	push   $0x801066d5
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
8010119a:	e8 20 2b 00 00       	call   80103cbf <acquire>
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
801011e1:	e8 3e 2b 00 00       	call   80103d24 <release>
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
80101217:	e8 08 2b 00 00       	call   80103d24 <release>
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
8010122c:	68 e8 66 10 80       	push   $0x801066e8
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
80101255:	e8 8c 2b 00 00       	call   80103de6 <memmove>
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
801012c8:	e8 34 17 00 00       	call   80102a01 <log_write>
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
801012e2:	68 f8 66 10 80       	push   $0x801066f8
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 0b 67 10 80       	push   $0x8010670b
801012f8:	68 e0 09 11 80       	push   $0x801109e0
801012fd:	e8 81 28 00 00       	call   80103b83 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 12 67 10 80       	push   $0x80106712
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101321:	50                   	push   %eax
80101322:	e8 51 27 00 00       	call   80103a78 <initsleeplock>
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
8010136c:	68 78 67 10 80       	push   $0x80106778
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
801013df:	68 18 67 10 80       	push   $0x80106718
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 75 29 00 00       	call   80103d6b <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 fc 15 00 00       	call   80102a01 <log_write>
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
80101480:	e8 61 29 00 00       	call   80103de6 <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 74 15 00 00       	call   80102a01 <log_write>
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
80101560:	e8 5a 27 00 00       	call   80103cbf <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101575:	e8 aa 27 00 00       	call   80103d24 <release>
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
8010159a:	e8 0c 25 00 00       	call   80103aab <acquiresleep>
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
801015b2:	68 2a 67 10 80       	push   $0x8010672a
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
80101614:	e8 cd 27 00 00       	call   80103de6 <memmove>
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
80101639:	68 30 67 10 80       	push   $0x80106730
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
80101656:	e8 da 24 00 00       	call   80103b35 <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 89 24 00 00       	call   80103afa <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 3f 67 10 80       	push   $0x8010673f
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
80101698:	e8 0e 24 00 00       	call   80103aab <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 44 24 00 00       	call   80103afa <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016bd:	e8 fd 25 00 00       	call   80103cbf <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d2:	e8 4d 26 00 00       	call   80103d24 <release>
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
801016ea:	e8 d0 25 00 00       	call   80103cbf <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016f9:	e8 26 26 00 00       	call   80103d24 <release>
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
8010182a:	e8 b7 25 00 00       	call   80103de6 <memmove>
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
80101926:	e8 bb 24 00 00       	call   80103de6 <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 ce 10 00 00       	call   80102a01 <log_write>
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
801019a9:	e8 9f 24 00 00       	call   80103e4d <strncmp>
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
801019d0:	68 47 67 10 80       	push   $0x80106747
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 59 67 10 80       	push   $0x80106759
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
namex(char *path, int nameiparent, char *name, struct inode *prev, int loopCount, int noDeRef)
{
80101a44:	55                   	push   %ebp
80101a45:	89 e5                	mov    %esp,%ebp
80101a47:	57                   	push   %edi
80101a48:	56                   	push   %esi
80101a49:	53                   	push   %ebx
80101a4a:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
80101a50:	89 c7                	mov    %eax,%edi
80101a52:	89 95 e0 fd ff ff    	mov    %edx,-0x220(%ebp)
80101a58:	89 8d e4 fd ff ff    	mov    %ecx,-0x21c(%ebp)
80101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  struct inode *ip, *next;
  char buf[512];

  if(loopCount > 16) {
80101a61:	83 7d 0c 10          	cmpl   $0x10,0xc(%ebp)
80101a65:	0f 8f dc 01 00 00    	jg     80101c47 <namex+0x203>
	return 0;
  }

  if(*path == '/') {
80101a6b:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101a6e:	74 17                	je     80101a87 <namex+0x43>
    ip = iget(ROOTDEV, ROOTINO);
  } else if (prev) {
80101a70:	85 c0                	test   %eax,%eax
80101a72:	74 29                	je     80101a9d <namex+0x59>
	ip = idup(prev);
80101a74:	83 ec 0c             	sub    $0xc,%esp
80101a77:	50                   	push   %eax
80101a78:	e8 d4 fa ff ff       	call   80101551 <idup>
80101a7d:	89 c3                	mov    %eax,%ebx
80101a7f:	83 c4 10             	add    $0x10,%esp
80101a82:	e9 a0 00 00 00       	jmp    80101b27 <namex+0xe3>
    ip = iget(ROOTDEV, ROOTINO);
80101a87:	ba 01 00 00 00       	mov    $0x1,%edx
80101a8c:	b8 01 00 00 00       	mov    $0x1,%eax
80101a91:	e8 f1 f6 ff ff       	call   80101187 <iget>
80101a96:	89 c3                	mov    %eax,%ebx
80101a98:	e9 8a 00 00 00       	jmp    80101b27 <namex+0xe3>
  }  else {
    ip = idup(myproc()->cwd);
80101a9d:	e8 7e 18 00 00       	call   80103320 <myproc>
80101aa2:	83 ec 0c             	sub    $0xc,%esp
80101aa5:	ff 70 68             	pushl  0x68(%eax)
80101aa8:	e8 a4 fa ff ff       	call   80101551 <idup>
80101aad:	89 c3                	mov    %eax,%ebx
80101aaf:	83 c4 10             	add    $0x10,%esp
80101ab2:	eb 73                	jmp    80101b27 <namex+0xe3>
  }

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101ab4:	83 ec 0c             	sub    $0xc,%esp
80101ab7:	53                   	push   %ebx
80101ab8:	e8 6b fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101abd:	83 c4 10             	add    $0x10,%esp
80101ac0:	bb 00 00 00 00       	mov    $0x0,%ebx
80101ac5:	e9 60 01 00 00       	jmp    80101c2a <namex+0x1e6>
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
80101aca:	83 ec 0c             	sub    $0xc,%esp
80101acd:	53                   	push   %ebx
80101ace:	e8 70 fb ff ff       	call   80101643 <iunlock>
      return ip;
80101ad3:	83 c4 10             	add    $0x10,%esp
80101ad6:	e9 4f 01 00 00       	jmp    80101c2a <namex+0x1e6>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
80101adb:	83 ec 0c             	sub    $0xc,%esp
80101ade:	53                   	push   %ebx
80101adf:	e8 44 fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	89 f3                	mov    %esi,%ebx
80101ae9:	e9 3c 01 00 00       	jmp    80101c2a <namex+0x1e6>
    }
    if(noDeRef) {
	iunlockput(ip);
    } else {
	iunlock(ip);
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	53                   	push   %ebx
80101af2:	e8 4c fb ff ff       	call   80101643 <iunlock>

	ilock(next);
80101af7:	89 34 24             	mov    %esi,(%esp)
80101afa:	e8 82 fa ff ff       	call   80101581 <ilock>
	if(next->type == T_SYM) {
80101aff:	83 c4 10             	add    $0x10,%esp
80101b02:	66 83 7e 50 04       	cmpw   $0x4,0x50(%esi)
80101b07:	0f 84 92 00 00 00    	je     80101b9f <namex+0x15b>
		}
		buf[next->size] = 0;
		iunlock(next);
		next = namex(buf, 0, name, ip, loopCount++, 0);
	} else {
		iunlock(next);
80101b0d:	83 ec 0c             	sub    $0xc,%esp
80101b10:	56                   	push   %esi
80101b11:	e8 2d fb ff ff       	call   80101643 <iunlock>
80101b16:	83 c4 10             	add    $0x10,%esp
	}
	iput(ip);
80101b19:	83 ec 0c             	sub    $0xc,%esp
80101b1c:	53                   	push   %ebx
80101b1d:	e8 66 fb ff ff       	call   80101688 <iput>
80101b22:	83 c4 10             	add    $0x10,%esp
80101b25:	89 f3                	mov    %esi,%ebx
  while((path = skipelem(path, name)) != 0){
80101b27:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
80101b2d:	89 f8                	mov    %edi,%eax
80101b2f:	e8 11 f4 ff ff       	call   80100f45 <skipelem>
80101b34:	89 c7                	mov    %eax,%edi
80101b36:	85 c0                	test   %eax,%eax
80101b38:	0f 84 e3 00 00 00    	je     80101c21 <namex+0x1dd>
    ilock(ip);
80101b3e:	83 ec 0c             	sub    $0xc,%esp
80101b41:	53                   	push   %ebx
80101b42:	e8 3a fa ff ff       	call   80101581 <ilock>
    if(ip->type != T_DIR){
80101b47:	83 c4 10             	add    $0x10,%esp
80101b4a:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101b4f:	0f 85 5f ff ff ff    	jne    80101ab4 <namex+0x70>
    if(nameiparent && *path == '\0'){
80101b55:	83 bd e0 fd ff ff 00 	cmpl   $0x0,-0x220(%ebp)
80101b5c:	74 09                	je     80101b67 <namex+0x123>
80101b5e:	80 3f 00             	cmpb   $0x0,(%edi)
80101b61:	0f 84 63 ff ff ff    	je     80101aca <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
80101b67:	83 ec 04             	sub    $0x4,%esp
80101b6a:	6a 00                	push   $0x0
80101b6c:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
80101b72:	53                   	push   %ebx
80101b73:	e8 38 fe ff ff       	call   801019b0 <dirlookup>
80101b78:	89 c6                	mov    %eax,%esi
80101b7a:	83 c4 10             	add    $0x10,%esp
80101b7d:	85 c0                	test   %eax,%eax
80101b7f:	0f 84 56 ff ff ff    	je     80101adb <namex+0x97>
    if(noDeRef) {
80101b85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101b89:	0f 84 5f ff ff ff    	je     80101aee <namex+0xaa>
	iunlockput(ip);
80101b8f:	83 ec 0c             	sub    $0xc,%esp
80101b92:	53                   	push   %ebx
80101b93:	e8 90 fb ff ff       	call   80101728 <iunlockput>
80101b98:	83 c4 10             	add    $0x10,%esp
    if((next = dirlookup(ip, name, 0)) == 0){
80101b9b:	89 f3                	mov    %esi,%ebx
80101b9d:	eb 88                	jmp    80101b27 <namex+0xe3>
		if(readi(next, buf, 0, sizeof(buf)) != next->size) {
80101b9f:	68 00 02 00 00       	push   $0x200
80101ba4:	6a 00                	push   $0x0
80101ba6:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
80101bac:	50                   	push   %eax
80101bad:	56                   	push   %esi
80101bae:	e8 c0 fb ff ff       	call   80101773 <readi>
80101bb3:	8b 56 58             	mov    0x58(%esi),%edx
80101bb6:	83 c4 10             	add    $0x10,%esp
80101bb9:	39 d0                	cmp    %edx,%eax
80101bbb:	75 51                	jne    80101c0e <namex+0x1ca>
		buf[next->size] = 0;
80101bbd:	c6 84 15 e8 fd ff ff 	movb   $0x0,-0x218(%ebp,%edx,1)
80101bc4:	00 
		iunlock(next);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	56                   	push   %esi
80101bc9:	e8 75 fa ff ff       	call   80101643 <iunlock>
		next = namex(buf, 0, name, ip, loopCount++, 0);
80101bce:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bd1:	83 c0 01             	add    $0x1,%eax
80101bd4:	89 85 dc fd ff ff    	mov    %eax,-0x224(%ebp)
80101bda:	83 c4 0c             	add    $0xc,%esp
80101bdd:	6a 00                	push   $0x0
80101bdf:	ff 75 0c             	pushl  0xc(%ebp)
80101be2:	53                   	push   %ebx
80101be3:	8b 8d e4 fd ff ff    	mov    -0x21c(%ebp),%ecx
80101be9:	ba 00 00 00 00       	mov    $0x0,%edx
80101bee:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
80101bf4:	89 f0                	mov    %esi,%eax
80101bf6:	e8 49 fe ff ff       	call   80101a44 <namex>
80101bfb:	89 c6                	mov    %eax,%esi
80101bfd:	83 c4 10             	add    $0x10,%esp
80101c00:	8b 85 dc fd ff ff    	mov    -0x224(%ebp),%eax
80101c06:	89 45 0c             	mov    %eax,0xc(%ebp)
80101c09:	e9 0b ff ff ff       	jmp    80101b19 <namex+0xd5>
			iunlockput(ip);
80101c0e:	83 ec 0c             	sub    $0xc,%esp
80101c11:	53                   	push   %ebx
80101c12:	e8 11 fb ff ff       	call   80101728 <iunlockput>
			return 0;
80101c17:	83 c4 10             	add    $0x10,%esp
80101c1a:	bb 00 00 00 00       	mov    $0x0,%ebx
80101c1f:	eb 09                	jmp    80101c2a <namex+0x1e6>
    }
    //iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101c21:	83 bd e0 fd ff ff 00 	cmpl   $0x0,-0x220(%ebp)
80101c28:	75 0a                	jne    80101c34 <namex+0x1f0>
    iput(ip);
    return 0;
  }
  return ip;
}
80101c2a:	89 d8                	mov    %ebx,%eax
80101c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c2f:	5b                   	pop    %ebx
80101c30:	5e                   	pop    %esi
80101c31:	5f                   	pop    %edi
80101c32:	5d                   	pop    %ebp
80101c33:	c3                   	ret    
    iput(ip);
80101c34:	83 ec 0c             	sub    $0xc,%esp
80101c37:	53                   	push   %ebx
80101c38:	e8 4b fa ff ff       	call   80101688 <iput>
    return 0;
80101c3d:	83 c4 10             	add    $0x10,%esp
80101c40:	bb 00 00 00 00       	mov    $0x0,%ebx
80101c45:	eb e3                	jmp    80101c2a <namex+0x1e6>
	return 0;
80101c47:	bb 00 00 00 00       	mov    $0x0,%ebx
80101c4c:	eb dc                	jmp    80101c2a <namex+0x1e6>

80101c4e <dirlink>:
{
80101c4e:	55                   	push   %ebp
80101c4f:	89 e5                	mov    %esp,%ebp
80101c51:	57                   	push   %edi
80101c52:	56                   	push   %esi
80101c53:	53                   	push   %ebx
80101c54:	83 ec 20             	sub    $0x20,%esp
80101c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101c5a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101c5d:	6a 00                	push   $0x0
80101c5f:	57                   	push   %edi
80101c60:	53                   	push   %ebx
80101c61:	e8 4a fd ff ff       	call   801019b0 <dirlookup>
80101c66:	83 c4 10             	add    $0x10,%esp
80101c69:	85 c0                	test   %eax,%eax
80101c6b:	75 2d                	jne    80101c9a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80101c72:	89 c6                	mov    %eax,%esi
80101c74:	39 43 58             	cmp    %eax,0x58(%ebx)
80101c77:	76 41                	jbe    80101cba <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101c79:	6a 10                	push   $0x10
80101c7b:	50                   	push   %eax
80101c7c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101c7f:	50                   	push   %eax
80101c80:	53                   	push   %ebx
80101c81:	e8 ed fa ff ff       	call   80101773 <readi>
80101c86:	83 c4 10             	add    $0x10,%esp
80101c89:	83 f8 10             	cmp    $0x10,%eax
80101c8c:	75 1f                	jne    80101cad <dirlink+0x5f>
    if(de.inum == 0)
80101c8e:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101c93:	74 25                	je     80101cba <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101c95:	8d 46 10             	lea    0x10(%esi),%eax
80101c98:	eb d8                	jmp    80101c72 <dirlink+0x24>
    iput(ip);
80101c9a:	83 ec 0c             	sub    $0xc,%esp
80101c9d:	50                   	push   %eax
80101c9e:	e8 e5 f9 ff ff       	call   80101688 <iput>
    return -1;
80101ca3:	83 c4 10             	add    $0x10,%esp
80101ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cab:	eb 3d                	jmp    80101cea <dirlink+0x9c>
      panic("dirlink read");
80101cad:	83 ec 0c             	sub    $0xc,%esp
80101cb0:	68 68 67 10 80       	push   $0x80106768
80101cb5:	e8 8e e6 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101cba:	83 ec 04             	sub    $0x4,%esp
80101cbd:	6a 0e                	push   $0xe
80101cbf:	57                   	push   %edi
80101cc0:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101cc3:	8d 45 da             	lea    -0x26(%ebp),%eax
80101cc6:	50                   	push   %eax
80101cc7:	e8 be 21 00 00       	call   80103e8a <strncpy>
  de.inum = inum;
80101ccc:	8b 45 10             	mov    0x10(%ebp),%eax
80101ccf:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101cd3:	6a 10                	push   $0x10
80101cd5:	56                   	push   %esi
80101cd6:	57                   	push   %edi
80101cd7:	53                   	push   %ebx
80101cd8:	e8 93 fb ff ff       	call   80101870 <writei>
80101cdd:	83 c4 20             	add    $0x20,%esp
80101ce0:	83 f8 10             	cmp    $0x10,%eax
80101ce3:	75 0d                	jne    80101cf2 <dirlink+0xa4>
  return 0;
80101ce5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ced:	5b                   	pop    %ebx
80101cee:	5e                   	pop    %esi
80101cef:	5f                   	pop    %edi
80101cf0:	5d                   	pop    %ebp
80101cf1:	c3                   	ret    
    panic("dirlink");
80101cf2:	83 ec 0c             	sub    $0xc,%esp
80101cf5:	68 74 6d 10 80       	push   $0x80106d74
80101cfa:	e8 49 e6 ff ff       	call   80100348 <panic>

80101cff <namei>:

struct inode*
namei(char *path)
{
80101cff:	55                   	push   %ebp
80101d00:	89 e5                	mov    %esp,%ebp
80101d02:	83 ec 1c             	sub    $0x1c,%esp
  char name[DIRSIZ];
  return namex(path, 0, name, 0, 0, 0);
80101d05:	6a 00                	push   $0x0
80101d07:	6a 00                	push   $0x0
80101d09:	6a 00                	push   $0x0
80101d0b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101d0e:	ba 00 00 00 00       	mov    $0x0,%edx
80101d13:	8b 45 08             	mov    0x8(%ebp),%eax
80101d16:	e8 29 fd ff ff       	call   80101a44 <namex>
}
80101d1b:	c9                   	leave  
80101d1c:	c3                   	ret    

80101d1d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101d1d:	55                   	push   %ebp
80101d1e:	89 e5                	mov    %esp,%ebp
80101d20:	83 ec 0c             	sub    $0xc,%esp
  return namex(path, 1, name, 0, 0, 0);
80101d23:	6a 00                	push   $0x0
80101d25:	6a 00                	push   $0x0
80101d27:	6a 00                	push   $0x0
80101d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101d2c:	ba 01 00 00 00       	mov    $0x1,%edx
80101d31:	8b 45 08             	mov    0x8(%ebp),%eax
80101d34:	e8 0b fd ff ff       	call   80101a44 <namex>
}
80101d39:	c9                   	leave  
80101d3a:	c3                   	ret    

80101d3b <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101d3b:	55                   	push   %ebp
80101d3c:	89 e5                	mov    %esp,%ebp
80101d3e:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d40:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d45:	ec                   	in     (%dx),%al
80101d46:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101d48:	83 e0 c0             	and    $0xffffffc0,%eax
80101d4b:	3c 40                	cmp    $0x40,%al
80101d4d:	75 f1                	jne    80101d40 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101d4f:	85 c9                	test   %ecx,%ecx
80101d51:	74 0c                	je     80101d5f <idewait+0x24>
80101d53:	f6 c2 21             	test   $0x21,%dl
80101d56:	75 0e                	jne    80101d66 <idewait+0x2b>
    return -1;
  return 0;
80101d58:	b8 00 00 00 00       	mov    $0x0,%eax
80101d5d:	eb 05                	jmp    80101d64 <idewait+0x29>
80101d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101d64:	5d                   	pop    %ebp
80101d65:	c3                   	ret    
    return -1;
80101d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d6b:	eb f7                	jmp    80101d64 <idewait+0x29>

80101d6d <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101d6d:	55                   	push   %ebp
80101d6e:	89 e5                	mov    %esp,%ebp
80101d70:	56                   	push   %esi
80101d71:	53                   	push   %ebx
  if(b == 0)
80101d72:	85 c0                	test   %eax,%eax
80101d74:	74 7d                	je     80101df3 <idestart+0x86>
80101d76:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101d78:	8b 58 08             	mov    0x8(%eax),%ebx
80101d7b:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101d81:	77 7d                	ja     80101e00 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101d83:	b8 00 00 00 00       	mov    $0x0,%eax
80101d88:	e8 ae ff ff ff       	call   80101d3b <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d8d:	b8 00 00 00 00       	mov    $0x0,%eax
80101d92:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101d97:	ee                   	out    %al,(%dx)
80101d98:	b8 01 00 00 00       	mov    $0x1,%eax
80101d9d:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101da2:	ee                   	out    %al,(%dx)
80101da3:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101da8:	89 d8                	mov    %ebx,%eax
80101daa:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101dab:	89 d8                	mov    %ebx,%eax
80101dad:	c1 f8 08             	sar    $0x8,%eax
80101db0:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101db5:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101db6:	89 d8                	mov    %ebx,%eax
80101db8:	c1 f8 10             	sar    $0x10,%eax
80101dbb:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101dc0:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101dc1:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101dc5:	c1 e0 04             	shl    $0x4,%eax
80101dc8:	83 e0 10             	and    $0x10,%eax
80101dcb:	c1 fb 18             	sar    $0x18,%ebx
80101dce:	83 e3 0f             	and    $0xf,%ebx
80101dd1:	09 d8                	or     %ebx,%eax
80101dd3:	83 c8 e0             	or     $0xffffffe0,%eax
80101dd6:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101ddb:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101ddc:	f6 06 04             	testb  $0x4,(%esi)
80101ddf:	75 2c                	jne    80101e0d <idestart+0xa0>
80101de1:	b8 20 00 00 00       	mov    $0x20,%eax
80101de6:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101deb:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101dec:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101def:	5b                   	pop    %ebx
80101df0:	5e                   	pop    %esi
80101df1:	5d                   	pop    %ebp
80101df2:	c3                   	ret    
    panic("idestart");
80101df3:	83 ec 0c             	sub    $0xc,%esp
80101df6:	68 cb 67 10 80       	push   $0x801067cb
80101dfb:	e8 48 e5 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101e00:	83 ec 0c             	sub    $0xc,%esp
80101e03:	68 d4 67 10 80       	push   $0x801067d4
80101e08:	e8 3b e5 ff ff       	call   80100348 <panic>
80101e0d:	b8 30 00 00 00       	mov    $0x30,%eax
80101e12:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e17:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101e18:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101e1b:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e20:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e25:	fc                   	cld    
80101e26:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101e28:	eb c2                	jmp    80101dec <idestart+0x7f>

80101e2a <ideinit>:
{
80101e2a:	55                   	push   %ebp
80101e2b:	89 e5                	mov    %esp,%ebp
80101e2d:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101e30:	68 e6 67 10 80       	push   $0x801067e6
80101e35:	68 80 a5 10 80       	push   $0x8010a580
80101e3a:	e8 44 1d 00 00       	call   80103b83 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101e3f:	83 c4 08             	add    $0x8,%esp
80101e42:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80101e47:	83 e8 01             	sub    $0x1,%eax
80101e4a:	50                   	push   %eax
80101e4b:	6a 0e                	push   $0xe
80101e4d:	e8 56 02 00 00       	call   801020a8 <ioapicenable>
  idewait(0);
80101e52:	b8 00 00 00 00       	mov    $0x0,%eax
80101e57:	e8 df fe ff ff       	call   80101d3b <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e5c:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101e61:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e66:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101e67:	83 c4 10             	add    $0x10,%esp
80101e6a:	b9 00 00 00 00       	mov    $0x0,%ecx
80101e6f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101e75:	7f 19                	jg     80101e90 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e77:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e7c:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101e7d:	84 c0                	test   %al,%al
80101e7f:	75 05                	jne    80101e86 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101e81:	83 c1 01             	add    $0x1,%ecx
80101e84:	eb e9                	jmp    80101e6f <ideinit+0x45>
      havedisk1 = 1;
80101e86:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101e8d:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e90:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101e95:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e9a:	ee                   	out    %al,(%dx)
}
80101e9b:	c9                   	leave  
80101e9c:	c3                   	ret    

80101e9d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101e9d:	55                   	push   %ebp
80101e9e:	89 e5                	mov    %esp,%ebp
80101ea0:	57                   	push   %edi
80101ea1:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101ea2:	83 ec 0c             	sub    $0xc,%esp
80101ea5:	68 80 a5 10 80       	push   $0x8010a580
80101eaa:	e8 10 1e 00 00       	call   80103cbf <acquire>

  if((b = idequeue) == 0){
80101eaf:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101eb5:	83 c4 10             	add    $0x10,%esp
80101eb8:	85 db                	test   %ebx,%ebx
80101eba:	74 48                	je     80101f04 <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101ebc:	8b 43 58             	mov    0x58(%ebx),%eax
80101ebf:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101ec4:	f6 03 04             	testb  $0x4,(%ebx)
80101ec7:	74 4d                	je     80101f16 <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101ec9:	8b 03                	mov    (%ebx),%eax
80101ecb:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101ece:	83 e0 fb             	and    $0xfffffffb,%eax
80101ed1:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101ed3:	83 ec 0c             	sub    $0xc,%esp
80101ed6:	53                   	push   %ebx
80101ed7:	e8 4d 1a 00 00       	call   80103929 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101edc:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101ee1:	83 c4 10             	add    $0x10,%esp
80101ee4:	85 c0                	test   %eax,%eax
80101ee6:	74 05                	je     80101eed <ideintr+0x50>
    idestart(idequeue);
80101ee8:	e8 80 fe ff ff       	call   80101d6d <idestart>

  release(&idelock);
80101eed:	83 ec 0c             	sub    $0xc,%esp
80101ef0:	68 80 a5 10 80       	push   $0x8010a580
80101ef5:	e8 2a 1e 00 00       	call   80103d24 <release>
80101efa:	83 c4 10             	add    $0x10,%esp
}
80101efd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101f00:	5b                   	pop    %ebx
80101f01:	5f                   	pop    %edi
80101f02:	5d                   	pop    %ebp
80101f03:	c3                   	ret    
    release(&idelock);
80101f04:	83 ec 0c             	sub    $0xc,%esp
80101f07:	68 80 a5 10 80       	push   $0x8010a580
80101f0c:	e8 13 1e 00 00       	call   80103d24 <release>
    return;
80101f11:	83 c4 10             	add    $0x10,%esp
80101f14:	eb e7                	jmp    80101efd <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101f16:	b8 01 00 00 00       	mov    $0x1,%eax
80101f1b:	e8 1b fe ff ff       	call   80101d3b <idewait>
80101f20:	85 c0                	test   %eax,%eax
80101f22:	78 a5                	js     80101ec9 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101f24:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101f27:	b9 80 00 00 00       	mov    $0x80,%ecx
80101f2c:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101f31:	fc                   	cld    
80101f32:	f3 6d                	rep insl (%dx),%es:(%edi)
80101f34:	eb 93                	jmp    80101ec9 <ideintr+0x2c>

80101f36 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101f36:	55                   	push   %ebp
80101f37:	89 e5                	mov    %esp,%ebp
80101f39:	53                   	push   %ebx
80101f3a:	83 ec 10             	sub    $0x10,%esp
80101f3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101f40:	8d 43 0c             	lea    0xc(%ebx),%eax
80101f43:	50                   	push   %eax
80101f44:	e8 ec 1b 00 00       	call   80103b35 <holdingsleep>
80101f49:	83 c4 10             	add    $0x10,%esp
80101f4c:	85 c0                	test   %eax,%eax
80101f4e:	74 37                	je     80101f87 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101f50:	8b 03                	mov    (%ebx),%eax
80101f52:	83 e0 06             	and    $0x6,%eax
80101f55:	83 f8 02             	cmp    $0x2,%eax
80101f58:	74 3a                	je     80101f94 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101f5a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101f5e:	74 09                	je     80101f69 <iderw+0x33>
80101f60:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101f67:	74 38                	je     80101fa1 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101f69:	83 ec 0c             	sub    $0xc,%esp
80101f6c:	68 80 a5 10 80       	push   $0x8010a580
80101f71:	e8 49 1d 00 00       	call   80103cbf <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101f76:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101f7d:	83 c4 10             	add    $0x10,%esp
80101f80:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101f85:	eb 2a                	jmp    80101fb1 <iderw+0x7b>
    panic("iderw: buf not locked");
80101f87:	83 ec 0c             	sub    $0xc,%esp
80101f8a:	68 ea 67 10 80       	push   $0x801067ea
80101f8f:	e8 b4 e3 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101f94:	83 ec 0c             	sub    $0xc,%esp
80101f97:	68 00 68 10 80       	push   $0x80106800
80101f9c:	e8 a7 e3 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101fa1:	83 ec 0c             	sub    $0xc,%esp
80101fa4:	68 15 68 10 80       	push   $0x80106815
80101fa9:	e8 9a e3 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101fae:	8d 50 58             	lea    0x58(%eax),%edx
80101fb1:	8b 02                	mov    (%edx),%eax
80101fb3:	85 c0                	test   %eax,%eax
80101fb5:	75 f7                	jne    80101fae <iderw+0x78>
    ;
  *pp = b;
80101fb7:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101fb9:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101fbf:	75 1a                	jne    80101fdb <iderw+0xa5>
    idestart(b);
80101fc1:	89 d8                	mov    %ebx,%eax
80101fc3:	e8 a5 fd ff ff       	call   80101d6d <idestart>
80101fc8:	eb 11                	jmp    80101fdb <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101fca:	83 ec 08             	sub    $0x8,%esp
80101fcd:	68 80 a5 10 80       	push   $0x8010a580
80101fd2:	53                   	push   %ebx
80101fd3:	e8 ec 17 00 00       	call   801037c4 <sleep>
80101fd8:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101fdb:	8b 03                	mov    (%ebx),%eax
80101fdd:	83 e0 06             	and    $0x6,%eax
80101fe0:	83 f8 02             	cmp    $0x2,%eax
80101fe3:	75 e5                	jne    80101fca <iderw+0x94>
  }


  release(&idelock);
80101fe5:	83 ec 0c             	sub    $0xc,%esp
80101fe8:	68 80 a5 10 80       	push   $0x8010a580
80101fed:	e8 32 1d 00 00       	call   80103d24 <release>
}
80101ff2:	83 c4 10             	add    $0x10,%esp
80101ff5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ff8:	c9                   	leave  
80101ff9:	c3                   	ret    

80101ffa <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ffa:	55                   	push   %ebp
80101ffb:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ffd:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80102003:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80102005:	a1 34 26 11 80       	mov    0x80112634,%eax
8010200a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010200d:	5d                   	pop    %ebp
8010200e:	c3                   	ret    

8010200f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010200f:	55                   	push   %ebp
80102010:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102012:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102018:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
8010201a:	a1 34 26 11 80       	mov    0x80112634,%eax
8010201f:	89 50 10             	mov    %edx,0x10(%eax)
}
80102022:	5d                   	pop    %ebp
80102023:	c3                   	ret    

80102024 <ioapicinit>:

void
ioapicinit(void)
{
80102024:	55                   	push   %ebp
80102025:	89 e5                	mov    %esp,%ebp
80102027:	57                   	push   %edi
80102028:	56                   	push   %esi
80102029:	53                   	push   %ebx
8010202a:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010202d:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
80102034:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102037:	b8 01 00 00 00       	mov    $0x1,%eax
8010203c:	e8 b9 ff ff ff       	call   80101ffa <ioapicread>
80102041:	c1 e8 10             	shr    $0x10,%eax
80102044:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80102047:	b8 00 00 00 00       	mov    $0x0,%eax
8010204c:	e8 a9 ff ff ff       	call   80101ffa <ioapicread>
80102051:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102054:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
8010205b:	39 c2                	cmp    %eax,%edx
8010205d:	75 07                	jne    80102066 <ioapicinit+0x42>
{
8010205f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102064:	eb 36                	jmp    8010209c <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102066:	83 ec 0c             	sub    $0xc,%esp
80102069:	68 34 68 10 80       	push   $0x80106834
8010206e:	e8 98 e5 ff ff       	call   8010060b <cprintf>
80102073:	83 c4 10             	add    $0x10,%esp
80102076:	eb e7                	jmp    8010205f <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102078:	8d 53 20             	lea    0x20(%ebx),%edx
8010207b:	81 ca 00 00 01 00    	or     $0x10000,%edx
80102081:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80102085:	89 f0                	mov    %esi,%eax
80102087:	e8 83 ff ff ff       	call   8010200f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010208c:	8d 46 01             	lea    0x1(%esi),%eax
8010208f:	ba 00 00 00 00       	mov    $0x0,%edx
80102094:	e8 76 ff ff ff       	call   8010200f <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80102099:	83 c3 01             	add    $0x1,%ebx
8010209c:	39 fb                	cmp    %edi,%ebx
8010209e:	7e d8                	jle    80102078 <ioapicinit+0x54>
  }
}
801020a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020a3:	5b                   	pop    %ebx
801020a4:	5e                   	pop    %esi
801020a5:	5f                   	pop    %edi
801020a6:	5d                   	pop    %ebp
801020a7:	c3                   	ret    

801020a8 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801020a8:	55                   	push   %ebp
801020a9:	89 e5                	mov    %esp,%ebp
801020ab:	53                   	push   %ebx
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801020af:	8d 50 20             	lea    0x20(%eax),%edx
801020b2:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
801020b6:	89 d8                	mov    %ebx,%eax
801020b8:	e8 52 ff ff ff       	call   8010200f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801020bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801020c0:	c1 e2 18             	shl    $0x18,%edx
801020c3:	8d 43 01             	lea    0x1(%ebx),%eax
801020c6:	e8 44 ff ff ff       	call   8010200f <ioapicwrite>
}
801020cb:	5b                   	pop    %ebx
801020cc:	5d                   	pop    %ebp
801020cd:	c3                   	ret    

801020ce <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801020ce:	55                   	push   %ebp
801020cf:	89 e5                	mov    %esp,%ebp
801020d1:	53                   	push   %ebx
801020d2:	83 ec 04             	sub    $0x4,%esp
801020d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801020d8:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801020de:	75 4c                	jne    8010212c <kfree+0x5e>
801020e0:	81 fb a8 54 11 80    	cmp    $0x801154a8,%ebx
801020e6:	72 44                	jb     8010212c <kfree+0x5e>
801020e8:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801020ee:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801020f3:	77 37                	ja     8010212c <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801020f5:	83 ec 04             	sub    $0x4,%esp
801020f8:	68 00 10 00 00       	push   $0x1000
801020fd:	6a 01                	push   $0x1
801020ff:	53                   	push   %ebx
80102100:	e8 66 1c 00 00       	call   80103d6b <memset>

  if(kmem.use_lock)
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010210f:	75 28                	jne    80102139 <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102111:	a1 78 26 11 80       	mov    0x80112678,%eax
80102116:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102118:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
8010211e:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102125:	75 24                	jne    8010214b <kfree+0x7d>
    release(&kmem.lock);
}
80102127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010212a:	c9                   	leave  
8010212b:	c3                   	ret    
    panic("kfree");
8010212c:	83 ec 0c             	sub    $0xc,%esp
8010212f:	68 66 68 10 80       	push   $0x80106866
80102134:	e8 0f e2 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102139:	83 ec 0c             	sub    $0xc,%esp
8010213c:	68 40 26 11 80       	push   $0x80112640
80102141:	e8 79 1b 00 00       	call   80103cbf <acquire>
80102146:	83 c4 10             	add    $0x10,%esp
80102149:	eb c6                	jmp    80102111 <kfree+0x43>
    release(&kmem.lock);
8010214b:	83 ec 0c             	sub    $0xc,%esp
8010214e:	68 40 26 11 80       	push   $0x80112640
80102153:	e8 cc 1b 00 00       	call   80103d24 <release>
80102158:	83 c4 10             	add    $0x10,%esp
}
8010215b:	eb ca                	jmp    80102127 <kfree+0x59>

8010215d <freerange>:
{
8010215d:	55                   	push   %ebp
8010215e:	89 e5                	mov    %esp,%ebp
80102160:	56                   	push   %esi
80102161:	53                   	push   %ebx
80102162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102165:	8b 45 08             	mov    0x8(%ebp),%eax
80102168:	05 ff 0f 00 00       	add    $0xfff,%eax
8010216d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102172:	eb 0e                	jmp    80102182 <freerange+0x25>
    kfree(p);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	50                   	push   %eax
80102178:	e8 51 ff ff ff       	call   801020ce <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010217d:	83 c4 10             	add    $0x10,%esp
80102180:	89 f0                	mov    %esi,%eax
80102182:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80102188:	39 de                	cmp    %ebx,%esi
8010218a:	76 e8                	jbe    80102174 <freerange+0x17>
}
8010218c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010218f:	5b                   	pop    %ebx
80102190:	5e                   	pop    %esi
80102191:	5d                   	pop    %ebp
80102192:	c3                   	ret    

80102193 <kinit1>:
{
80102193:	55                   	push   %ebp
80102194:	89 e5                	mov    %esp,%ebp
80102196:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80102199:	68 6c 68 10 80       	push   $0x8010686c
8010219e:	68 40 26 11 80       	push   $0x80112640
801021a3:	e8 db 19 00 00       	call   80103b83 <initlock>
  kmem.use_lock = 0;
801021a8:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
801021af:	00 00 00 
  freerange(vstart, vend);
801021b2:	83 c4 08             	add    $0x8,%esp
801021b5:	ff 75 0c             	pushl  0xc(%ebp)
801021b8:	ff 75 08             	pushl  0x8(%ebp)
801021bb:	e8 9d ff ff ff       	call   8010215d <freerange>
}
801021c0:	83 c4 10             	add    $0x10,%esp
801021c3:	c9                   	leave  
801021c4:	c3                   	ret    

801021c5 <kinit2>:
{
801021c5:	55                   	push   %ebp
801021c6:	89 e5                	mov    %esp,%ebp
801021c8:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801021cb:	ff 75 0c             	pushl  0xc(%ebp)
801021ce:	ff 75 08             	pushl  0x8(%ebp)
801021d1:	e8 87 ff ff ff       	call   8010215d <freerange>
  kmem.use_lock = 1;
801021d6:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
801021dd:	00 00 00 
}
801021e0:	83 c4 10             	add    $0x10,%esp
801021e3:	c9                   	leave  
801021e4:	c3                   	ret    

801021e5 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801021e5:	55                   	push   %ebp
801021e6:	89 e5                	mov    %esp,%ebp
801021e8:	53                   	push   %ebx
801021e9:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801021ec:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801021f3:	75 21                	jne    80102216 <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801021f5:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
801021fb:	85 db                	test   %ebx,%ebx
801021fd:	74 07                	je     80102206 <kalloc+0x21>
    kmem.freelist = r->next;
801021ff:	8b 03                	mov    (%ebx),%eax
80102201:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
80102206:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010220d:	75 19                	jne    80102228 <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
8010220f:	89 d8                	mov    %ebx,%eax
80102211:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102214:	c9                   	leave  
80102215:	c3                   	ret    
    acquire(&kmem.lock);
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 40 26 11 80       	push   $0x80112640
8010221e:	e8 9c 1a 00 00       	call   80103cbf <acquire>
80102223:	83 c4 10             	add    $0x10,%esp
80102226:	eb cd                	jmp    801021f5 <kalloc+0x10>
    release(&kmem.lock);
80102228:	83 ec 0c             	sub    $0xc,%esp
8010222b:	68 40 26 11 80       	push   $0x80112640
80102230:	e8 ef 1a 00 00       	call   80103d24 <release>
80102235:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102238:	eb d5                	jmp    8010220f <kalloc+0x2a>

8010223a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010223a:	55                   	push   %ebp
8010223b:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010223d:	ba 64 00 00 00       	mov    $0x64,%edx
80102242:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102243:	a8 01                	test   $0x1,%al
80102245:	0f 84 b5 00 00 00    	je     80102300 <kbdgetc+0xc6>
8010224b:	ba 60 00 00 00       	mov    $0x60,%edx
80102250:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102251:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
80102254:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
8010225a:	74 5c                	je     801022b8 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
8010225c:	84 c0                	test   %al,%al
8010225e:	78 66                	js     801022c6 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102260:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102266:	f6 c1 40             	test   $0x40,%cl
80102269:	74 0f                	je     8010227a <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010226b:	83 c8 80             	or     $0xffffff80,%eax
8010226e:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102271:	83 e1 bf             	and    $0xffffffbf,%ecx
80102274:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
8010227a:	0f b6 8a a0 69 10 80 	movzbl -0x7fef9660(%edx),%ecx
80102281:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
80102287:	0f b6 82 a0 68 10 80 	movzbl -0x7fef9760(%edx),%eax
8010228e:	31 c1                	xor    %eax,%ecx
80102290:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102296:	89 c8                	mov    %ecx,%eax
80102298:	83 e0 03             	and    $0x3,%eax
8010229b:	8b 04 85 80 68 10 80 	mov    -0x7fef9780(,%eax,4),%eax
801022a2:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801022a6:	f6 c1 08             	test   $0x8,%cl
801022a9:	74 19                	je     801022c4 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801022ab:	8d 50 9f             	lea    -0x61(%eax),%edx
801022ae:	83 fa 19             	cmp    $0x19,%edx
801022b1:	77 40                	ja     801022f3 <kbdgetc+0xb9>
      c += 'A' - 'a';
801022b3:	83 e8 20             	sub    $0x20,%eax
801022b6:	eb 0c                	jmp    801022c4 <kbdgetc+0x8a>
    shift |= E0ESC;
801022b8:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
801022bf:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801022c4:	5d                   	pop    %ebp
801022c5:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801022c6:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801022cc:	f6 c1 40             	test   $0x40,%cl
801022cf:	75 05                	jne    801022d6 <kbdgetc+0x9c>
801022d1:	89 c2                	mov    %eax,%edx
801022d3:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801022d6:	0f b6 82 a0 69 10 80 	movzbl -0x7fef9660(%edx),%eax
801022dd:	83 c8 40             	or     $0x40,%eax
801022e0:	0f b6 c0             	movzbl %al,%eax
801022e3:	f7 d0                	not    %eax
801022e5:	21 c8                	and    %ecx,%eax
801022e7:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
801022ec:	b8 00 00 00 00       	mov    $0x0,%eax
801022f1:	eb d1                	jmp    801022c4 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801022f3:	8d 50 bf             	lea    -0x41(%eax),%edx
801022f6:	83 fa 19             	cmp    $0x19,%edx
801022f9:	77 c9                	ja     801022c4 <kbdgetc+0x8a>
      c += 'a' - 'A';
801022fb:	83 c0 20             	add    $0x20,%eax
  return c;
801022fe:	eb c4                	jmp    801022c4 <kbdgetc+0x8a>
    return -1;
80102300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102305:	eb bd                	jmp    801022c4 <kbdgetc+0x8a>

80102307 <kbdintr>:

void
kbdintr(void)
{
80102307:	55                   	push   %ebp
80102308:	89 e5                	mov    %esp,%ebp
8010230a:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010230d:	68 3a 22 10 80       	push   $0x8010223a
80102312:	e8 27 e4 ff ff       	call   8010073e <consoleintr>
}
80102317:	83 c4 10             	add    $0x10,%esp
8010231a:	c9                   	leave  
8010231b:	c3                   	ret    

8010231c <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010231c:	55                   	push   %ebp
8010231d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010231f:	8b 0d 7c 26 11 80    	mov    0x8011267c,%ecx
80102325:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102328:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010232a:	a1 7c 26 11 80       	mov    0x8011267c,%eax
8010232f:	8b 40 20             	mov    0x20(%eax),%eax
}
80102332:	5d                   	pop    %ebp
80102333:	c3                   	ret    

80102334 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80102334:	55                   	push   %ebp
80102335:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102337:	ba 70 00 00 00       	mov    $0x70,%edx
8010233c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010233d:	ba 71 00 00 00       	mov    $0x71,%edx
80102342:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102343:	0f b6 c0             	movzbl %al,%eax
}
80102346:	5d                   	pop    %ebp
80102347:	c3                   	ret    

80102348 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	53                   	push   %ebx
8010234c:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
8010234e:	b8 00 00 00 00       	mov    $0x0,%eax
80102353:	e8 dc ff ff ff       	call   80102334 <cmos_read>
80102358:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
8010235a:	b8 02 00 00 00       	mov    $0x2,%eax
8010235f:	e8 d0 ff ff ff       	call   80102334 <cmos_read>
80102364:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102367:	b8 04 00 00 00       	mov    $0x4,%eax
8010236c:	e8 c3 ff ff ff       	call   80102334 <cmos_read>
80102371:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
80102374:	b8 07 00 00 00       	mov    $0x7,%eax
80102379:	e8 b6 ff ff ff       	call   80102334 <cmos_read>
8010237e:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102381:	b8 08 00 00 00       	mov    $0x8,%eax
80102386:	e8 a9 ff ff ff       	call   80102334 <cmos_read>
8010238b:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
8010238e:	b8 09 00 00 00       	mov    $0x9,%eax
80102393:	e8 9c ff ff ff       	call   80102334 <cmos_read>
80102398:	89 43 14             	mov    %eax,0x14(%ebx)
}
8010239b:	5b                   	pop    %ebx
8010239c:	5d                   	pop    %ebp
8010239d:	c3                   	ret    

8010239e <lapicinit>:
  if(!lapic)
8010239e:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
801023a5:	0f 84 fb 00 00 00    	je     801024a6 <lapicinit+0x108>
{
801023ab:	55                   	push   %ebp
801023ac:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801023ae:	ba 3f 01 00 00       	mov    $0x13f,%edx
801023b3:	b8 3c 00 00 00       	mov    $0x3c,%eax
801023b8:	e8 5f ff ff ff       	call   8010231c <lapicw>
  lapicw(TDCR, X1);
801023bd:	ba 0b 00 00 00       	mov    $0xb,%edx
801023c2:	b8 f8 00 00 00       	mov    $0xf8,%eax
801023c7:	e8 50 ff ff ff       	call   8010231c <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801023cc:	ba 20 00 02 00       	mov    $0x20020,%edx
801023d1:	b8 c8 00 00 00       	mov    $0xc8,%eax
801023d6:	e8 41 ff ff ff       	call   8010231c <lapicw>
  lapicw(TICR, 10000000);
801023db:	ba 80 96 98 00       	mov    $0x989680,%edx
801023e0:	b8 e0 00 00 00       	mov    $0xe0,%eax
801023e5:	e8 32 ff ff ff       	call   8010231c <lapicw>
  lapicw(LINT0, MASKED);
801023ea:	ba 00 00 01 00       	mov    $0x10000,%edx
801023ef:	b8 d4 00 00 00       	mov    $0xd4,%eax
801023f4:	e8 23 ff ff ff       	call   8010231c <lapicw>
  lapicw(LINT1, MASKED);
801023f9:	ba 00 00 01 00       	mov    $0x10000,%edx
801023fe:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102403:	e8 14 ff ff ff       	call   8010231c <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102408:	a1 7c 26 11 80       	mov    0x8011267c,%eax
8010240d:	8b 40 30             	mov    0x30(%eax),%eax
80102410:	c1 e8 10             	shr    $0x10,%eax
80102413:	3c 03                	cmp    $0x3,%al
80102415:	77 7b                	ja     80102492 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102417:	ba 33 00 00 00       	mov    $0x33,%edx
8010241c:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102421:	e8 f6 fe ff ff       	call   8010231c <lapicw>
  lapicw(ESR, 0);
80102426:	ba 00 00 00 00       	mov    $0x0,%edx
8010242b:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102430:	e8 e7 fe ff ff       	call   8010231c <lapicw>
  lapicw(ESR, 0);
80102435:	ba 00 00 00 00       	mov    $0x0,%edx
8010243a:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010243f:	e8 d8 fe ff ff       	call   8010231c <lapicw>
  lapicw(EOI, 0);
80102444:	ba 00 00 00 00       	mov    $0x0,%edx
80102449:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010244e:	e8 c9 fe ff ff       	call   8010231c <lapicw>
  lapicw(ICRHI, 0);
80102453:	ba 00 00 00 00       	mov    $0x0,%edx
80102458:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010245d:	e8 ba fe ff ff       	call   8010231c <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102462:	ba 00 85 08 00       	mov    $0x88500,%edx
80102467:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010246c:	e8 ab fe ff ff       	call   8010231c <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102471:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102476:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
8010247c:	f6 c4 10             	test   $0x10,%ah
8010247f:	75 f0                	jne    80102471 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102481:	ba 00 00 00 00       	mov    $0x0,%edx
80102486:	b8 20 00 00 00       	mov    $0x20,%eax
8010248b:	e8 8c fe ff ff       	call   8010231c <lapicw>
}
80102490:	5d                   	pop    %ebp
80102491:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102492:	ba 00 00 01 00       	mov    $0x10000,%edx
80102497:	b8 d0 00 00 00       	mov    $0xd0,%eax
8010249c:	e8 7b fe ff ff       	call   8010231c <lapicw>
801024a1:	e9 71 ff ff ff       	jmp    80102417 <lapicinit+0x79>
801024a6:	f3 c3                	repz ret 

801024a8 <lapicid>:
{
801024a8:	55                   	push   %ebp
801024a9:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801024ab:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801024b0:	85 c0                	test   %eax,%eax
801024b2:	74 08                	je     801024bc <lapicid+0x14>
  return lapic[ID] >> 24;
801024b4:	8b 40 20             	mov    0x20(%eax),%eax
801024b7:	c1 e8 18             	shr    $0x18,%eax
}
801024ba:	5d                   	pop    %ebp
801024bb:	c3                   	ret    
    return 0;
801024bc:	b8 00 00 00 00       	mov    $0x0,%eax
801024c1:	eb f7                	jmp    801024ba <lapicid+0x12>

801024c3 <lapiceoi>:
  if(lapic)
801024c3:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
801024ca:	74 14                	je     801024e0 <lapiceoi+0x1d>
{
801024cc:	55                   	push   %ebp
801024cd:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801024cf:	ba 00 00 00 00       	mov    $0x0,%edx
801024d4:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024d9:	e8 3e fe ff ff       	call   8010231c <lapicw>
}
801024de:	5d                   	pop    %ebp
801024df:	c3                   	ret    
801024e0:	f3 c3                	repz ret 

801024e2 <microdelay>:
{
801024e2:	55                   	push   %ebp
801024e3:	89 e5                	mov    %esp,%ebp
}
801024e5:	5d                   	pop    %ebp
801024e6:	c3                   	ret    

801024e7 <lapicstartap>:
{
801024e7:	55                   	push   %ebp
801024e8:	89 e5                	mov    %esp,%ebp
801024ea:	57                   	push   %edi
801024eb:	56                   	push   %esi
801024ec:	53                   	push   %ebx
801024ed:	8b 75 08             	mov    0x8(%ebp),%esi
801024f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024f3:	b8 0f 00 00 00       	mov    $0xf,%eax
801024f8:	ba 70 00 00 00       	mov    $0x70,%edx
801024fd:	ee                   	out    %al,(%dx)
801024fe:	b8 0a 00 00 00       	mov    $0xa,%eax
80102503:	ba 71 00 00 00       	mov    $0x71,%edx
80102508:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102509:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102510:	00 00 
  wrv[1] = addr >> 4;
80102512:	89 f8                	mov    %edi,%eax
80102514:	c1 e8 04             	shr    $0x4,%eax
80102517:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
8010251d:	c1 e6 18             	shl    $0x18,%esi
80102520:	89 f2                	mov    %esi,%edx
80102522:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102527:	e8 f0 fd ff ff       	call   8010231c <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010252c:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102531:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102536:	e8 e1 fd ff ff       	call   8010231c <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
8010253b:	ba 00 85 00 00       	mov    $0x8500,%edx
80102540:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102545:	e8 d2 fd ff ff       	call   8010231c <lapicw>
  for(i = 0; i < 2; i++){
8010254a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010254f:	eb 21                	jmp    80102572 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102551:	89 f2                	mov    %esi,%edx
80102553:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102558:	e8 bf fd ff ff       	call   8010231c <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010255d:	89 fa                	mov    %edi,%edx
8010255f:	c1 ea 0c             	shr    $0xc,%edx
80102562:	80 ce 06             	or     $0x6,%dh
80102565:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010256a:	e8 ad fd ff ff       	call   8010231c <lapicw>
  for(i = 0; i < 2; i++){
8010256f:	83 c3 01             	add    $0x1,%ebx
80102572:	83 fb 01             	cmp    $0x1,%ebx
80102575:	7e da                	jle    80102551 <lapicstartap+0x6a>
}
80102577:	5b                   	pop    %ebx
80102578:	5e                   	pop    %esi
80102579:	5f                   	pop    %edi
8010257a:	5d                   	pop    %ebp
8010257b:	c3                   	ret    

8010257c <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	57                   	push   %edi
80102580:	56                   	push   %esi
80102581:	53                   	push   %ebx
80102582:	83 ec 3c             	sub    $0x3c,%esp
80102585:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102588:	b8 0b 00 00 00       	mov    $0xb,%eax
8010258d:	e8 a2 fd ff ff       	call   80102334 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102592:	83 e0 04             	and    $0x4,%eax
80102595:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102597:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010259a:	e8 a9 fd ff ff       	call   80102348 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010259f:	b8 0a 00 00 00       	mov    $0xa,%eax
801025a4:	e8 8b fd ff ff       	call   80102334 <cmos_read>
801025a9:	a8 80                	test   $0x80,%al
801025ab:	75 ea                	jne    80102597 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801025ad:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801025b0:	89 d8                	mov    %ebx,%eax
801025b2:	e8 91 fd ff ff       	call   80102348 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801025b7:	83 ec 04             	sub    $0x4,%esp
801025ba:	6a 18                	push   $0x18
801025bc:	53                   	push   %ebx
801025bd:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025c0:	50                   	push   %eax
801025c1:	e8 eb 17 00 00       	call   80103db1 <memcmp>
801025c6:	83 c4 10             	add    $0x10,%esp
801025c9:	85 c0                	test   %eax,%eax
801025cb:	75 ca                	jne    80102597 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801025cd:	85 ff                	test   %edi,%edi
801025cf:	0f 85 84 00 00 00    	jne    80102659 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801025d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
801025d8:	89 d0                	mov    %edx,%eax
801025da:	c1 e8 04             	shr    $0x4,%eax
801025dd:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025e0:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025e3:	83 e2 0f             	and    $0xf,%edx
801025e6:	01 d0                	add    %edx,%eax
801025e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801025eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801025ee:	89 d0                	mov    %edx,%eax
801025f0:	c1 e8 04             	shr    $0x4,%eax
801025f3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025f6:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025f9:	83 e2 0f             	and    $0xf,%edx
801025fc:	01 d0                	add    %edx,%eax
801025fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102601:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102604:	89 d0                	mov    %edx,%eax
80102606:	c1 e8 04             	shr    $0x4,%eax
80102609:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010260c:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010260f:	83 e2 0f             	and    $0xf,%edx
80102612:	01 d0                	add    %edx,%eax
80102614:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102617:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010261a:	89 d0                	mov    %edx,%eax
8010261c:	c1 e8 04             	shr    $0x4,%eax
8010261f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102622:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102625:	83 e2 0f             	and    $0xf,%edx
80102628:	01 d0                	add    %edx,%eax
8010262a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010262d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102630:	89 d0                	mov    %edx,%eax
80102632:	c1 e8 04             	shr    $0x4,%eax
80102635:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102638:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010263b:	83 e2 0f             	and    $0xf,%edx
8010263e:	01 d0                	add    %edx,%eax
80102640:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102646:	89 d0                	mov    %edx,%eax
80102648:	c1 e8 04             	shr    $0x4,%eax
8010264b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010264e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102651:	83 e2 0f             	and    $0xf,%edx
80102654:	01 d0                	add    %edx,%eax
80102656:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102659:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010265c:	89 06                	mov    %eax,(%esi)
8010265e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102661:	89 46 04             	mov    %eax,0x4(%esi)
80102664:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102667:	89 46 08             	mov    %eax,0x8(%esi)
8010266a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010266d:	89 46 0c             	mov    %eax,0xc(%esi)
80102670:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102673:	89 46 10             	mov    %eax,0x10(%esi)
80102676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102679:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
8010267c:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102683:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102686:	5b                   	pop    %ebx
80102687:	5e                   	pop    %esi
80102688:	5f                   	pop    %edi
80102689:	5d                   	pop    %ebp
8010268a:	c3                   	ret    

8010268b <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010268b:	55                   	push   %ebp
8010268c:	89 e5                	mov    %esp,%ebp
8010268e:	53                   	push   %ebx
8010268f:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102692:	ff 35 b4 26 11 80    	pushl  0x801126b4
80102698:	ff 35 c4 26 11 80    	pushl  0x801126c4
8010269e:	e8 c9 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801026a3:	8b 58 5c             	mov    0x5c(%eax),%ebx
801026a6:	89 1d c8 26 11 80    	mov    %ebx,0x801126c8
  for (i = 0; i < log.lh.n; i++) {
801026ac:	83 c4 10             	add    $0x10,%esp
801026af:	ba 00 00 00 00       	mov    $0x0,%edx
801026b4:	eb 0e                	jmp    801026c4 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801026b6:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801026ba:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801026c1:	83 c2 01             	add    $0x1,%edx
801026c4:	39 d3                	cmp    %edx,%ebx
801026c6:	7f ee                	jg     801026b6 <read_head+0x2b>
  }
  brelse(buf);
801026c8:	83 ec 0c             	sub    $0xc,%esp
801026cb:	50                   	push   %eax
801026cc:	e8 04 db ff ff       	call   801001d5 <brelse>
}
801026d1:	83 c4 10             	add    $0x10,%esp
801026d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026d7:	c9                   	leave  
801026d8:	c3                   	ret    

801026d9 <install_trans>:
{
801026d9:	55                   	push   %ebp
801026da:	89 e5                	mov    %esp,%ebp
801026dc:	57                   	push   %edi
801026dd:	56                   	push   %esi
801026de:	53                   	push   %ebx
801026df:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801026e2:	bb 00 00 00 00       	mov    $0x0,%ebx
801026e7:	eb 66                	jmp    8010274f <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801026e9:	89 d8                	mov    %ebx,%eax
801026eb:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801026f1:	83 c0 01             	add    $0x1,%eax
801026f4:	83 ec 08             	sub    $0x8,%esp
801026f7:	50                   	push   %eax
801026f8:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026fe:	e8 69 da ff ff       	call   8010016c <bread>
80102703:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102705:	83 c4 08             	add    $0x8,%esp
80102708:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
8010270f:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102715:	e8 52 da ff ff       	call   8010016c <bread>
8010271a:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010271c:	8d 57 5c             	lea    0x5c(%edi),%edx
8010271f:	8d 40 5c             	lea    0x5c(%eax),%eax
80102722:	83 c4 0c             	add    $0xc,%esp
80102725:	68 00 02 00 00       	push   $0x200
8010272a:	52                   	push   %edx
8010272b:	50                   	push   %eax
8010272c:	e8 b5 16 00 00       	call   80103de6 <memmove>
    bwrite(dbuf);  // write dst to disk
80102731:	89 34 24             	mov    %esi,(%esp)
80102734:	e8 61 da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102739:	89 3c 24             	mov    %edi,(%esp)
8010273c:	e8 94 da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102741:	89 34 24             	mov    %esi,(%esp)
80102744:	e8 8c da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102749:	83 c3 01             	add    $0x1,%ebx
8010274c:	83 c4 10             	add    $0x10,%esp
8010274f:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
80102755:	7f 92                	jg     801026e9 <install_trans+0x10>
}
80102757:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010275a:	5b                   	pop    %ebx
8010275b:	5e                   	pop    %esi
8010275c:	5f                   	pop    %edi
8010275d:	5d                   	pop    %ebp
8010275e:	c3                   	ret    

8010275f <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010275f:	55                   	push   %ebp
80102760:	89 e5                	mov    %esp,%ebp
80102762:	53                   	push   %ebx
80102763:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102766:	ff 35 b4 26 11 80    	pushl  0x801126b4
8010276c:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102772:	e8 f5 d9 ff ff       	call   8010016c <bread>
80102777:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102779:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
8010277f:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102782:	83 c4 10             	add    $0x10,%esp
80102785:	b8 00 00 00 00       	mov    $0x0,%eax
8010278a:	eb 0e                	jmp    8010279a <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
8010278c:	8b 14 85 cc 26 11 80 	mov    -0x7feed934(,%eax,4),%edx
80102793:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102797:	83 c0 01             	add    $0x1,%eax
8010279a:	39 c1                	cmp    %eax,%ecx
8010279c:	7f ee                	jg     8010278c <write_head+0x2d>
  }
  bwrite(buf);
8010279e:	83 ec 0c             	sub    $0xc,%esp
801027a1:	53                   	push   %ebx
801027a2:	e8 f3 d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
801027a7:	89 1c 24             	mov    %ebx,(%esp)
801027aa:	e8 26 da ff ff       	call   801001d5 <brelse>
}
801027af:	83 c4 10             	add    $0x10,%esp
801027b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027b5:	c9                   	leave  
801027b6:	c3                   	ret    

801027b7 <recover_from_log>:

static void
recover_from_log(void)
{
801027b7:	55                   	push   %ebp
801027b8:	89 e5                	mov    %esp,%ebp
801027ba:	83 ec 08             	sub    $0x8,%esp
  read_head();
801027bd:	e8 c9 fe ff ff       	call   8010268b <read_head>
  install_trans(); // if committed, copy from log to disk
801027c2:	e8 12 ff ff ff       	call   801026d9 <install_trans>
  log.lh.n = 0;
801027c7:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
801027ce:	00 00 00 
  write_head(); // clear the log
801027d1:	e8 89 ff ff ff       	call   8010275f <write_head>
}
801027d6:	c9                   	leave  
801027d7:	c3                   	ret    

801027d8 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801027d8:	55                   	push   %ebp
801027d9:	89 e5                	mov    %esp,%ebp
801027db:	57                   	push   %edi
801027dc:	56                   	push   %esi
801027dd:	53                   	push   %ebx
801027de:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801027e1:	bb 00 00 00 00       	mov    $0x0,%ebx
801027e6:	eb 66                	jmp    8010284e <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801027e8:	89 d8                	mov    %ebx,%eax
801027ea:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801027f0:	83 c0 01             	add    $0x1,%eax
801027f3:	83 ec 08             	sub    $0x8,%esp
801027f6:	50                   	push   %eax
801027f7:	ff 35 c4 26 11 80    	pushl  0x801126c4
801027fd:	e8 6a d9 ff ff       	call   8010016c <bread>
80102802:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102804:	83 c4 08             	add    $0x8,%esp
80102807:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
8010280e:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102814:	e8 53 d9 ff ff       	call   8010016c <bread>
80102819:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010281b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010281e:	8d 46 5c             	lea    0x5c(%esi),%eax
80102821:	83 c4 0c             	add    $0xc,%esp
80102824:	68 00 02 00 00       	push   $0x200
80102829:	52                   	push   %edx
8010282a:	50                   	push   %eax
8010282b:	e8 b6 15 00 00       	call   80103de6 <memmove>
    bwrite(to);  // write the log
80102830:	89 34 24             	mov    %esi,(%esp)
80102833:	e8 62 d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
80102838:	89 3c 24             	mov    %edi,(%esp)
8010283b:	e8 95 d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
80102840:	89 34 24             	mov    %esi,(%esp)
80102843:	e8 8d d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102848:	83 c3 01             	add    $0x1,%ebx
8010284b:	83 c4 10             	add    $0x10,%esp
8010284e:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
80102854:	7f 92                	jg     801027e8 <write_log+0x10>
  }
}
80102856:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102859:	5b                   	pop    %ebx
8010285a:	5e                   	pop    %esi
8010285b:	5f                   	pop    %edi
8010285c:	5d                   	pop    %ebp
8010285d:	c3                   	ret    

8010285e <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
8010285e:	83 3d c8 26 11 80 00 	cmpl   $0x0,0x801126c8
80102865:	7e 26                	jle    8010288d <commit+0x2f>
{
80102867:	55                   	push   %ebp
80102868:	89 e5                	mov    %esp,%ebp
8010286a:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010286d:	e8 66 ff ff ff       	call   801027d8 <write_log>
    write_head();    // Write header to disk -- the real commit
80102872:	e8 e8 fe ff ff       	call   8010275f <write_head>
    install_trans(); // Now install writes to home locations
80102877:	e8 5d fe ff ff       	call   801026d9 <install_trans>
    log.lh.n = 0;
8010287c:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102883:	00 00 00 
    write_head();    // Erase the transaction from the log
80102886:	e8 d4 fe ff ff       	call   8010275f <write_head>
  }
}
8010288b:	c9                   	leave  
8010288c:	c3                   	ret    
8010288d:	f3 c3                	repz ret 

8010288f <initlog>:
{
8010288f:	55                   	push   %ebp
80102890:	89 e5                	mov    %esp,%ebp
80102892:	53                   	push   %ebx
80102893:	83 ec 2c             	sub    $0x2c,%esp
80102896:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102899:	68 a0 6a 10 80       	push   $0x80106aa0
8010289e:	68 80 26 11 80       	push   $0x80112680
801028a3:	e8 db 12 00 00       	call   80103b83 <initlock>
  readsb(dev, &sb);
801028a8:	83 c4 08             	add    $0x8,%esp
801028ab:	8d 45 dc             	lea    -0x24(%ebp),%eax
801028ae:	50                   	push   %eax
801028af:	53                   	push   %ebx
801028b0:	e8 81 e9 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
801028b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028b8:	a3 b4 26 11 80       	mov    %eax,0x801126b4
  log.size = sb.nlog;
801028bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028c0:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  log.dev = dev;
801028c5:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4
  recover_from_log();
801028cb:	e8 e7 fe ff ff       	call   801027b7 <recover_from_log>
}
801028d0:	83 c4 10             	add    $0x10,%esp
801028d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028d6:	c9                   	leave  
801028d7:	c3                   	ret    

801028d8 <begin_op>:
{
801028d8:	55                   	push   %ebp
801028d9:	89 e5                	mov    %esp,%ebp
801028db:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801028de:	68 80 26 11 80       	push   $0x80112680
801028e3:	e8 d7 13 00 00       	call   80103cbf <acquire>
801028e8:	83 c4 10             	add    $0x10,%esp
801028eb:	eb 15                	jmp    80102902 <begin_op+0x2a>
      sleep(&log, &log.lock);
801028ed:	83 ec 08             	sub    $0x8,%esp
801028f0:	68 80 26 11 80       	push   $0x80112680
801028f5:	68 80 26 11 80       	push   $0x80112680
801028fa:	e8 c5 0e 00 00       	call   801037c4 <sleep>
801028ff:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102902:	83 3d c0 26 11 80 00 	cmpl   $0x0,0x801126c0
80102909:	75 e2                	jne    801028ed <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010290b:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102910:	83 c0 01             	add    $0x1,%eax
80102913:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102916:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102919:	03 15 c8 26 11 80    	add    0x801126c8,%edx
8010291f:	83 fa 1e             	cmp    $0x1e,%edx
80102922:	7e 17                	jle    8010293b <begin_op+0x63>
      sleep(&log, &log.lock);
80102924:	83 ec 08             	sub    $0x8,%esp
80102927:	68 80 26 11 80       	push   $0x80112680
8010292c:	68 80 26 11 80       	push   $0x80112680
80102931:	e8 8e 0e 00 00       	call   801037c4 <sleep>
80102936:	83 c4 10             	add    $0x10,%esp
80102939:	eb c7                	jmp    80102902 <begin_op+0x2a>
      log.outstanding += 1;
8010293b:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
80102940:	83 ec 0c             	sub    $0xc,%esp
80102943:	68 80 26 11 80       	push   $0x80112680
80102948:	e8 d7 13 00 00       	call   80103d24 <release>
}
8010294d:	83 c4 10             	add    $0x10,%esp
80102950:	c9                   	leave  
80102951:	c3                   	ret    

80102952 <end_op>:
{
80102952:	55                   	push   %ebp
80102953:	89 e5                	mov    %esp,%ebp
80102955:	53                   	push   %ebx
80102956:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102959:	68 80 26 11 80       	push   $0x80112680
8010295e:	e8 5c 13 00 00       	call   80103cbf <acquire>
  log.outstanding -= 1;
80102963:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102968:	83 e8 01             	sub    $0x1,%eax
8010296b:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(log.committing)
80102970:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
80102976:	83 c4 10             	add    $0x10,%esp
80102979:	85 db                	test   %ebx,%ebx
8010297b:	75 2c                	jne    801029a9 <end_op+0x57>
  if(log.outstanding == 0){
8010297d:	85 c0                	test   %eax,%eax
8010297f:	75 35                	jne    801029b6 <end_op+0x64>
    log.committing = 1;
80102981:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
80102988:	00 00 00 
    do_commit = 1;
8010298b:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102990:	83 ec 0c             	sub    $0xc,%esp
80102993:	68 80 26 11 80       	push   $0x80112680
80102998:	e8 87 13 00 00       	call   80103d24 <release>
  if(do_commit){
8010299d:	83 c4 10             	add    $0x10,%esp
801029a0:	85 db                	test   %ebx,%ebx
801029a2:	75 24                	jne    801029c8 <end_op+0x76>
}
801029a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029a7:	c9                   	leave  
801029a8:	c3                   	ret    
    panic("log.committing");
801029a9:	83 ec 0c             	sub    $0xc,%esp
801029ac:	68 a4 6a 10 80       	push   $0x80106aa4
801029b1:	e8 92 d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
801029b6:	83 ec 0c             	sub    $0xc,%esp
801029b9:	68 80 26 11 80       	push   $0x80112680
801029be:	e8 66 0f 00 00       	call   80103929 <wakeup>
801029c3:	83 c4 10             	add    $0x10,%esp
801029c6:	eb c8                	jmp    80102990 <end_op+0x3e>
    commit();
801029c8:	e8 91 fe ff ff       	call   8010285e <commit>
    acquire(&log.lock);
801029cd:	83 ec 0c             	sub    $0xc,%esp
801029d0:	68 80 26 11 80       	push   $0x80112680
801029d5:	e8 e5 12 00 00       	call   80103cbf <acquire>
    log.committing = 0;
801029da:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
801029e1:	00 00 00 
    wakeup(&log);
801029e4:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801029eb:	e8 39 0f 00 00       	call   80103929 <wakeup>
    release(&log.lock);
801029f0:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801029f7:	e8 28 13 00 00       	call   80103d24 <release>
801029fc:	83 c4 10             	add    $0x10,%esp
}
801029ff:	eb a3                	jmp    801029a4 <end_op+0x52>

80102a01 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a01:	55                   	push   %ebp
80102a02:	89 e5                	mov    %esp,%ebp
80102a04:	53                   	push   %ebx
80102a05:	83 ec 04             	sub    $0x4,%esp
80102a08:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a0b:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102a11:	83 fa 1d             	cmp    $0x1d,%edx
80102a14:	7f 45                	jg     80102a5b <log_write+0x5a>
80102a16:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102a1b:	83 e8 01             	sub    $0x1,%eax
80102a1e:	39 c2                	cmp    %eax,%edx
80102a20:	7d 39                	jge    80102a5b <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a22:	83 3d bc 26 11 80 00 	cmpl   $0x0,0x801126bc
80102a29:	7e 3d                	jle    80102a68 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a2b:	83 ec 0c             	sub    $0xc,%esp
80102a2e:	68 80 26 11 80       	push   $0x80112680
80102a33:	e8 87 12 00 00       	call   80103cbf <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102a38:	83 c4 10             	add    $0x10,%esp
80102a3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102a40:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102a46:	39 c2                	cmp    %eax,%edx
80102a48:	7e 2b                	jle    80102a75 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a4a:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a4d:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
80102a54:	74 1f                	je     80102a75 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102a56:	83 c0 01             	add    $0x1,%eax
80102a59:	eb e5                	jmp    80102a40 <log_write+0x3f>
    panic("too big a transaction");
80102a5b:	83 ec 0c             	sub    $0xc,%esp
80102a5e:	68 b3 6a 10 80       	push   $0x80106ab3
80102a63:	e8 e0 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102a68:	83 ec 0c             	sub    $0xc,%esp
80102a6b:	68 c9 6a 10 80       	push   $0x80106ac9
80102a70:	e8 d3 d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102a75:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a78:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
  if (i == log.lh.n)
80102a7f:	39 c2                	cmp    %eax,%edx
80102a81:	74 18                	je     80102a9b <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102a83:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102a86:	83 ec 0c             	sub    $0xc,%esp
80102a89:	68 80 26 11 80       	push   $0x80112680
80102a8e:	e8 91 12 00 00       	call   80103d24 <release>
}
80102a93:	83 c4 10             	add    $0x10,%esp
80102a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a99:	c9                   	leave  
80102a9a:	c3                   	ret    
    log.lh.n++;
80102a9b:	83 c2 01             	add    $0x1,%edx
80102a9e:	89 15 c8 26 11 80    	mov    %edx,0x801126c8
80102aa4:	eb dd                	jmp    80102a83 <log_write+0x82>

80102aa6 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102aa6:	55                   	push   %ebp
80102aa7:	89 e5                	mov    %esp,%ebp
80102aa9:	53                   	push   %ebx
80102aaa:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102aad:	68 8a 00 00 00       	push   $0x8a
80102ab2:	68 8c a4 10 80       	push   $0x8010a48c
80102ab7:	68 00 70 00 80       	push   $0x80007000
80102abc:	e8 25 13 00 00       	call   80103de6 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102ac1:	83 c4 10             	add    $0x10,%esp
80102ac4:	bb 80 27 11 80       	mov    $0x80112780,%ebx
80102ac9:	eb 06                	jmp    80102ad1 <startothers+0x2b>
80102acb:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102ad1:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
80102ad8:	00 00 00 
80102adb:	05 80 27 11 80       	add    $0x80112780,%eax
80102ae0:	39 d8                	cmp    %ebx,%eax
80102ae2:	76 4c                	jbe    80102b30 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102ae4:	e8 c0 07 00 00       	call   801032a9 <mycpu>
80102ae9:	39 d8                	cmp    %ebx,%eax
80102aeb:	74 de                	je     80102acb <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102aed:	e8 f3 f6 ff ff       	call   801021e5 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102af2:	05 00 10 00 00       	add    $0x1000,%eax
80102af7:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102afc:	c7 05 f8 6f 00 80 74 	movl   $0x80102b74,0x80006ff8
80102b03:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b06:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b0d:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b10:	83 ec 08             	sub    $0x8,%esp
80102b13:	68 00 70 00 00       	push   $0x7000
80102b18:	0f b6 03             	movzbl (%ebx),%eax
80102b1b:	50                   	push   %eax
80102b1c:	e8 c6 f9 ff ff       	call   801024e7 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b21:	83 c4 10             	add    $0x10,%esp
80102b24:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b2a:	85 c0                	test   %eax,%eax
80102b2c:	74 f6                	je     80102b24 <startothers+0x7e>
80102b2e:	eb 9b                	jmp    80102acb <startothers+0x25>
      ;
  }
}
80102b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b33:	c9                   	leave  
80102b34:	c3                   	ret    

80102b35 <mpmain>:
{
80102b35:	55                   	push   %ebp
80102b36:	89 e5                	mov    %esp,%ebp
80102b38:	53                   	push   %ebx
80102b39:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102b3c:	e8 c4 07 00 00       	call   80103305 <cpuid>
80102b41:	89 c3                	mov    %eax,%ebx
80102b43:	e8 bd 07 00 00       	call   80103305 <cpuid>
80102b48:	83 ec 04             	sub    $0x4,%esp
80102b4b:	53                   	push   %ebx
80102b4c:	50                   	push   %eax
80102b4d:	68 e4 6a 10 80       	push   $0x80106ae4
80102b52:	e8 b4 da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102b57:	e8 2a 24 00 00       	call   80104f86 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102b5c:	e8 48 07 00 00       	call   801032a9 <mycpu>
80102b61:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102b63:	b8 01 00 00 00       	mov    $0x1,%eax
80102b68:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102b6f:	e8 2b 0a 00 00       	call   8010359f <scheduler>

80102b74 <mpenter>:
{
80102b74:	55                   	push   %ebp
80102b75:	89 e5                	mov    %esp,%ebp
80102b77:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b7a:	e8 10 34 00 00       	call   80105f8f <switchkvm>
  seginit();
80102b7f:	e8 bf 32 00 00       	call   80105e43 <seginit>
  lapicinit();
80102b84:	e8 15 f8 ff ff       	call   8010239e <lapicinit>
  mpmain();
80102b89:	e8 a7 ff ff ff       	call   80102b35 <mpmain>

80102b8e <main>:
{
80102b8e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102b92:	83 e4 f0             	and    $0xfffffff0,%esp
80102b95:	ff 71 fc             	pushl  -0x4(%ecx)
80102b98:	55                   	push   %ebp
80102b99:	89 e5                	mov    %esp,%ebp
80102b9b:	51                   	push   %ecx
80102b9c:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b9f:	68 00 00 40 80       	push   $0x80400000
80102ba4:	68 a8 54 11 80       	push   $0x801154a8
80102ba9:	e8 e5 f5 ff ff       	call   80102193 <kinit1>
  kvmalloc();      // kernel page table
80102bae:	e8 69 38 00 00       	call   8010641c <kvmalloc>
  mpinit();        // detect other processors
80102bb3:	e8 c9 01 00 00       	call   80102d81 <mpinit>
  lapicinit();     // interrupt controller
80102bb8:	e8 e1 f7 ff ff       	call   8010239e <lapicinit>
  seginit();       // segment descriptors
80102bbd:	e8 81 32 00 00       	call   80105e43 <seginit>
  picinit();       // disable pic
80102bc2:	e8 82 02 00 00       	call   80102e49 <picinit>
  ioapicinit();    // another interrupt controller
80102bc7:	e8 58 f4 ff ff       	call   80102024 <ioapicinit>
  consoleinit();   // console hardware
80102bcc:	e8 bd dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102bd1:	e8 5e 26 00 00       	call   80105234 <uartinit>
  pinit();         // process table
80102bd6:	e8 b4 06 00 00       	call   8010328f <pinit>
  tvinit();        // trap vectors
80102bdb:	e8 f5 22 00 00       	call   80104ed5 <tvinit>
  binit();         // buffer cache
80102be0:	e8 0f d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102be5:	e8 29 e0 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102bea:	e8 3b f2 ff ff       	call   80101e2a <ideinit>
  startothers();   // start other processors
80102bef:	e8 b2 fe ff ff       	call   80102aa6 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102bf4:	83 c4 08             	add    $0x8,%esp
80102bf7:	68 00 00 00 8e       	push   $0x8e000000
80102bfc:	68 00 00 40 80       	push   $0x80400000
80102c01:	e8 bf f5 ff ff       	call   801021c5 <kinit2>
  userinit();      // first user process
80102c06:	e8 39 07 00 00       	call   80103344 <userinit>
  mpmain();        // finish this processor's setup
80102c0b:	e8 25 ff ff ff       	call   80102b35 <mpmain>

80102c10 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c10:	55                   	push   %ebp
80102c11:	89 e5                	mov    %esp,%ebp
80102c13:	56                   	push   %esi
80102c14:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102c15:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102c1a:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c1f:	eb 09                	jmp    80102c2a <sum+0x1a>
    sum += addr[i];
80102c21:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102c25:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102c27:	83 c1 01             	add    $0x1,%ecx
80102c2a:	39 d1                	cmp    %edx,%ecx
80102c2c:	7c f3                	jl     80102c21 <sum+0x11>
  return sum;
}
80102c2e:	89 d8                	mov    %ebx,%eax
80102c30:	5b                   	pop    %ebx
80102c31:	5e                   	pop    %esi
80102c32:	5d                   	pop    %ebp
80102c33:	c3                   	ret    

80102c34 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c34:	55                   	push   %ebp
80102c35:	89 e5                	mov    %esp,%ebp
80102c37:	56                   	push   %esi
80102c38:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102c39:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102c3f:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102c41:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102c43:	eb 03                	jmp    80102c48 <mpsearch1+0x14>
80102c45:	83 c3 10             	add    $0x10,%ebx
80102c48:	39 f3                	cmp    %esi,%ebx
80102c4a:	73 29                	jae    80102c75 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102c4c:	83 ec 04             	sub    $0x4,%esp
80102c4f:	6a 04                	push   $0x4
80102c51:	68 f8 6a 10 80       	push   $0x80106af8
80102c56:	53                   	push   %ebx
80102c57:	e8 55 11 00 00       	call   80103db1 <memcmp>
80102c5c:	83 c4 10             	add    $0x10,%esp
80102c5f:	85 c0                	test   %eax,%eax
80102c61:	75 e2                	jne    80102c45 <mpsearch1+0x11>
80102c63:	ba 10 00 00 00       	mov    $0x10,%edx
80102c68:	89 d8                	mov    %ebx,%eax
80102c6a:	e8 a1 ff ff ff       	call   80102c10 <sum>
80102c6f:	84 c0                	test   %al,%al
80102c71:	75 d2                	jne    80102c45 <mpsearch1+0x11>
80102c73:	eb 05                	jmp    80102c7a <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102c75:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102c7a:	89 d8                	mov    %ebx,%eax
80102c7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102c7f:	5b                   	pop    %ebx
80102c80:	5e                   	pop    %esi
80102c81:	5d                   	pop    %ebp
80102c82:	c3                   	ret    

80102c83 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102c83:	55                   	push   %ebp
80102c84:	89 e5                	mov    %esp,%ebp
80102c86:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c89:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c90:	c1 e0 08             	shl    $0x8,%eax
80102c93:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c9a:	09 d0                	or     %edx,%eax
80102c9c:	c1 e0 04             	shl    $0x4,%eax
80102c9f:	85 c0                	test   %eax,%eax
80102ca1:	74 1f                	je     80102cc2 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102ca3:	ba 00 04 00 00       	mov    $0x400,%edx
80102ca8:	e8 87 ff ff ff       	call   80102c34 <mpsearch1>
80102cad:	85 c0                	test   %eax,%eax
80102caf:	75 0f                	jne    80102cc0 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102cb1:	ba 00 00 01 00       	mov    $0x10000,%edx
80102cb6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102cbb:	e8 74 ff ff ff       	call   80102c34 <mpsearch1>
}
80102cc0:	c9                   	leave  
80102cc1:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102cc2:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102cc9:	c1 e0 08             	shl    $0x8,%eax
80102ccc:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102cd3:	09 d0                	or     %edx,%eax
80102cd5:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102cd8:	2d 00 04 00 00       	sub    $0x400,%eax
80102cdd:	ba 00 04 00 00       	mov    $0x400,%edx
80102ce2:	e8 4d ff ff ff       	call   80102c34 <mpsearch1>
80102ce7:	85 c0                	test   %eax,%eax
80102ce9:	75 d5                	jne    80102cc0 <mpsearch+0x3d>
80102ceb:	eb c4                	jmp    80102cb1 <mpsearch+0x2e>

80102ced <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102ced:	55                   	push   %ebp
80102cee:	89 e5                	mov    %esp,%ebp
80102cf0:	57                   	push   %edi
80102cf1:	56                   	push   %esi
80102cf2:	53                   	push   %ebx
80102cf3:	83 ec 1c             	sub    $0x1c,%esp
80102cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102cf9:	e8 85 ff ff ff       	call   80102c83 <mpsearch>
80102cfe:	85 c0                	test   %eax,%eax
80102d00:	74 5c                	je     80102d5e <mpconfig+0x71>
80102d02:	89 c7                	mov    %eax,%edi
80102d04:	8b 58 04             	mov    0x4(%eax),%ebx
80102d07:	85 db                	test   %ebx,%ebx
80102d09:	74 5a                	je     80102d65 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d0b:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d11:	83 ec 04             	sub    $0x4,%esp
80102d14:	6a 04                	push   $0x4
80102d16:	68 fd 6a 10 80       	push   $0x80106afd
80102d1b:	56                   	push   %esi
80102d1c:	e8 90 10 00 00       	call   80103db1 <memcmp>
80102d21:	83 c4 10             	add    $0x10,%esp
80102d24:	85 c0                	test   %eax,%eax
80102d26:	75 44                	jne    80102d6c <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d28:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102d2f:	3c 01                	cmp    $0x1,%al
80102d31:	0f 95 c2             	setne  %dl
80102d34:	3c 04                	cmp    $0x4,%al
80102d36:	0f 95 c0             	setne  %al
80102d39:	84 c2                	test   %al,%dl
80102d3b:	75 36                	jne    80102d73 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102d3d:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102d44:	89 f0                	mov    %esi,%eax
80102d46:	e8 c5 fe ff ff       	call   80102c10 <sum>
80102d4b:	84 c0                	test   %al,%al
80102d4d:	75 2b                	jne    80102d7a <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102d4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d52:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102d54:	89 f0                	mov    %esi,%eax
80102d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d59:	5b                   	pop    %ebx
80102d5a:	5e                   	pop    %esi
80102d5b:	5f                   	pop    %edi
80102d5c:	5d                   	pop    %ebp
80102d5d:	c3                   	ret    
    return 0;
80102d5e:	be 00 00 00 00       	mov    $0x0,%esi
80102d63:	eb ef                	jmp    80102d54 <mpconfig+0x67>
80102d65:	be 00 00 00 00       	mov    $0x0,%esi
80102d6a:	eb e8                	jmp    80102d54 <mpconfig+0x67>
    return 0;
80102d6c:	be 00 00 00 00       	mov    $0x0,%esi
80102d71:	eb e1                	jmp    80102d54 <mpconfig+0x67>
    return 0;
80102d73:	be 00 00 00 00       	mov    $0x0,%esi
80102d78:	eb da                	jmp    80102d54 <mpconfig+0x67>
    return 0;
80102d7a:	be 00 00 00 00       	mov    $0x0,%esi
80102d7f:	eb d3                	jmp    80102d54 <mpconfig+0x67>

80102d81 <mpinit>:

void
mpinit(void)
{
80102d81:	55                   	push   %ebp
80102d82:	89 e5                	mov    %esp,%ebp
80102d84:	57                   	push   %edi
80102d85:	56                   	push   %esi
80102d86:	53                   	push   %ebx
80102d87:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102d8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102d8d:	e8 5b ff ff ff       	call   80102ced <mpconfig>
80102d92:	85 c0                	test   %eax,%eax
80102d94:	74 19                	je     80102daf <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d96:	8b 50 24             	mov    0x24(%eax),%edx
80102d99:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d9f:	8d 50 2c             	lea    0x2c(%eax),%edx
80102da2:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102da6:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dad:	eb 34                	jmp    80102de3 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102daf:	83 ec 0c             	sub    $0xc,%esp
80102db2:	68 02 6b 10 80       	push   $0x80106b02
80102db7:	e8 8c d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102dbc:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
80102dc2:	83 fe 07             	cmp    $0x7,%esi
80102dc5:	7f 19                	jg     80102de0 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102dc7:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102dcb:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102dd1:	88 87 80 27 11 80    	mov    %al,-0x7feed880(%edi)
        ncpu++;
80102dd7:	83 c6 01             	add    $0x1,%esi
80102dda:	89 35 00 2d 11 80    	mov    %esi,0x80112d00
      }
      p += sizeof(struct mpproc);
80102de0:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102de3:	39 ca                	cmp    %ecx,%edx
80102de5:	73 2b                	jae    80102e12 <mpinit+0x91>
    switch(*p){
80102de7:	0f b6 02             	movzbl (%edx),%eax
80102dea:	3c 04                	cmp    $0x4,%al
80102dec:	77 1d                	ja     80102e0b <mpinit+0x8a>
80102dee:	0f b6 c0             	movzbl %al,%eax
80102df1:	ff 24 85 3c 6b 10 80 	jmp    *-0x7fef94c4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102df8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102dfc:	a2 60 27 11 80       	mov    %al,0x80112760
      p += sizeof(struct mpioapic);
80102e01:	83 c2 08             	add    $0x8,%edx
      continue;
80102e04:	eb dd                	jmp    80102de3 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102e06:	83 c2 08             	add    $0x8,%edx
      continue;
80102e09:	eb d8                	jmp    80102de3 <mpinit+0x62>
    default:
      ismp = 0;
80102e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
80102e10:	eb d1                	jmp    80102de3 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102e12:	85 db                	test   %ebx,%ebx
80102e14:	74 26                	je     80102e3c <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e19:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e1d:	74 15                	je     80102e34 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e1f:	b8 70 00 00 00       	mov    $0x70,%eax
80102e24:	ba 22 00 00 00       	mov    $0x22,%edx
80102e29:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e2a:	ba 23 00 00 00       	mov    $0x23,%edx
80102e2f:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e30:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e33:	ee                   	out    %al,(%dx)
  }
}
80102e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e37:	5b                   	pop    %ebx
80102e38:	5e                   	pop    %esi
80102e39:	5f                   	pop    %edi
80102e3a:	5d                   	pop    %ebp
80102e3b:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102e3c:	83 ec 0c             	sub    $0xc,%esp
80102e3f:	68 1c 6b 10 80       	push   $0x80106b1c
80102e44:	e8 ff d4 ff ff       	call   80100348 <panic>

80102e49 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102e49:	55                   	push   %ebp
80102e4a:	89 e5                	mov    %esp,%ebp
80102e4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e51:	ba 21 00 00 00       	mov    $0x21,%edx
80102e56:	ee                   	out    %al,(%dx)
80102e57:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e5c:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e5d:	5d                   	pop    %ebp
80102e5e:	c3                   	ret    

80102e5f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e5f:	55                   	push   %ebp
80102e60:	89 e5                	mov    %esp,%ebp
80102e62:	57                   	push   %edi
80102e63:	56                   	push   %esi
80102e64:	53                   	push   %ebx
80102e65:	83 ec 0c             	sub    $0xc,%esp
80102e68:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e6e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102e7a:	e8 ae dd ff ff       	call   80100c2d <filealloc>
80102e7f:	89 03                	mov    %eax,(%ebx)
80102e81:	85 c0                	test   %eax,%eax
80102e83:	74 16                	je     80102e9b <pipealloc+0x3c>
80102e85:	e8 a3 dd ff ff       	call   80100c2d <filealloc>
80102e8a:	89 06                	mov    %eax,(%esi)
80102e8c:	85 c0                	test   %eax,%eax
80102e8e:	74 0b                	je     80102e9b <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102e90:	e8 50 f3 ff ff       	call   801021e5 <kalloc>
80102e95:	89 c7                	mov    %eax,%edi
80102e97:	85 c0                	test   %eax,%eax
80102e99:	75 35                	jne    80102ed0 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102e9b:	8b 03                	mov    (%ebx),%eax
80102e9d:	85 c0                	test   %eax,%eax
80102e9f:	74 0c                	je     80102ead <pipealloc+0x4e>
    fileclose(*f0);
80102ea1:	83 ec 0c             	sub    $0xc,%esp
80102ea4:	50                   	push   %eax
80102ea5:	e8 29 de ff ff       	call   80100cd3 <fileclose>
80102eaa:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102ead:	8b 06                	mov    (%esi),%eax
80102eaf:	85 c0                	test   %eax,%eax
80102eb1:	0f 84 8b 00 00 00    	je     80102f42 <pipealloc+0xe3>
    fileclose(*f1);
80102eb7:	83 ec 0c             	sub    $0xc,%esp
80102eba:	50                   	push   %eax
80102ebb:	e8 13 de ff ff       	call   80100cd3 <fileclose>
80102ec0:	83 c4 10             	add    $0x10,%esp
  return -1;
80102ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ecb:	5b                   	pop    %ebx
80102ecc:	5e                   	pop    %esi
80102ecd:	5f                   	pop    %edi
80102ece:	5d                   	pop    %ebp
80102ecf:	c3                   	ret    
  p->readopen = 1;
80102ed0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102ed7:	00 00 00 
  p->writeopen = 1;
80102eda:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102ee1:	00 00 00 
  p->nwrite = 0;
80102ee4:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102eeb:	00 00 00 
  p->nread = 0;
80102eee:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102ef5:	00 00 00 
  initlock(&p->lock, "pipe");
80102ef8:	83 ec 08             	sub    $0x8,%esp
80102efb:	68 50 6b 10 80       	push   $0x80106b50
80102f00:	50                   	push   %eax
80102f01:	e8 7d 0c 00 00       	call   80103b83 <initlock>
  (*f0)->type = FD_PIPE;
80102f06:	8b 03                	mov    (%ebx),%eax
80102f08:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102f0e:	8b 03                	mov    (%ebx),%eax
80102f10:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f14:	8b 03                	mov    (%ebx),%eax
80102f16:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102f1a:	8b 03                	mov    (%ebx),%eax
80102f1c:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102f1f:	8b 06                	mov    (%esi),%eax
80102f21:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102f27:	8b 06                	mov    (%esi),%eax
80102f29:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102f2d:	8b 06                	mov    (%esi),%eax
80102f2f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102f33:	8b 06                	mov    (%esi),%eax
80102f35:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102f38:	83 c4 10             	add    $0x10,%esp
80102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102f40:	eb 86                	jmp    80102ec8 <pipealloc+0x69>
  return -1;
80102f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f47:	e9 7c ff ff ff       	jmp    80102ec8 <pipealloc+0x69>

80102f4c <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f4c:	55                   	push   %ebp
80102f4d:	89 e5                	mov    %esp,%ebp
80102f4f:	53                   	push   %ebx
80102f50:	83 ec 10             	sub    $0x10,%esp
80102f53:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102f56:	53                   	push   %ebx
80102f57:	e8 63 0d 00 00       	call   80103cbf <acquire>
  if(writable){
80102f5c:	83 c4 10             	add    $0x10,%esp
80102f5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f63:	74 3f                	je     80102fa4 <pipeclose+0x58>
    p->writeopen = 0;
80102f65:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f6c:	00 00 00 
    wakeup(&p->nread);
80102f6f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f75:	83 ec 0c             	sub    $0xc,%esp
80102f78:	50                   	push   %eax
80102f79:	e8 ab 09 00 00       	call   80103929 <wakeup>
80102f7e:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f81:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f88:	75 09                	jne    80102f93 <pipeclose+0x47>
80102f8a:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f91:	74 2f                	je     80102fc2 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102f93:	83 ec 0c             	sub    $0xc,%esp
80102f96:	53                   	push   %ebx
80102f97:	e8 88 0d 00 00       	call   80103d24 <release>
80102f9c:	83 c4 10             	add    $0x10,%esp
}
80102f9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102fa2:	c9                   	leave  
80102fa3:	c3                   	ret    
    p->readopen = 0;
80102fa4:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102fab:	00 00 00 
    wakeup(&p->nwrite);
80102fae:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fb4:	83 ec 0c             	sub    $0xc,%esp
80102fb7:	50                   	push   %eax
80102fb8:	e8 6c 09 00 00       	call   80103929 <wakeup>
80102fbd:	83 c4 10             	add    $0x10,%esp
80102fc0:	eb bf                	jmp    80102f81 <pipeclose+0x35>
    release(&p->lock);
80102fc2:	83 ec 0c             	sub    $0xc,%esp
80102fc5:	53                   	push   %ebx
80102fc6:	e8 59 0d 00 00       	call   80103d24 <release>
    kfree((char*)p);
80102fcb:	89 1c 24             	mov    %ebx,(%esp)
80102fce:	e8 fb f0 ff ff       	call   801020ce <kfree>
80102fd3:	83 c4 10             	add    $0x10,%esp
80102fd6:	eb c7                	jmp    80102f9f <pipeclose+0x53>

80102fd8 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102fd8:	55                   	push   %ebp
80102fd9:	89 e5                	mov    %esp,%ebp
80102fdb:	57                   	push   %edi
80102fdc:	56                   	push   %esi
80102fdd:	53                   	push   %ebx
80102fde:	83 ec 18             	sub    $0x18,%esp
80102fe1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102fe4:	89 de                	mov    %ebx,%esi
80102fe6:	53                   	push   %ebx
80102fe7:	e8 d3 0c 00 00       	call   80103cbf <acquire>
  for(i = 0; i < n; i++){
80102fec:	83 c4 10             	add    $0x10,%esp
80102fef:	bf 00 00 00 00       	mov    $0x0,%edi
80102ff4:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102ff7:	0f 8d 88 00 00 00    	jge    80103085 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ffd:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103003:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103009:	05 00 02 00 00       	add    $0x200,%eax
8010300e:	39 c2                	cmp    %eax,%edx
80103010:	75 51                	jne    80103063 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80103012:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103019:	74 2f                	je     8010304a <pipewrite+0x72>
8010301b:	e8 00 03 00 00       	call   80103320 <myproc>
80103020:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103024:	75 24                	jne    8010304a <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103026:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010302c:	83 ec 0c             	sub    $0xc,%esp
8010302f:	50                   	push   %eax
80103030:	e8 f4 08 00 00       	call   80103929 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103035:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010303b:	83 c4 08             	add    $0x8,%esp
8010303e:	56                   	push   %esi
8010303f:	50                   	push   %eax
80103040:	e8 7f 07 00 00       	call   801037c4 <sleep>
80103045:	83 c4 10             	add    $0x10,%esp
80103048:	eb b3                	jmp    80102ffd <pipewrite+0x25>
        release(&p->lock);
8010304a:	83 ec 0c             	sub    $0xc,%esp
8010304d:	53                   	push   %ebx
8010304e:	e8 d1 0c 00 00       	call   80103d24 <release>
        return -1;
80103053:	83 c4 10             	add    $0x10,%esp
80103056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
8010305b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010305e:	5b                   	pop    %ebx
8010305f:	5e                   	pop    %esi
80103060:	5f                   	pop    %edi
80103061:	5d                   	pop    %ebp
80103062:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103063:	8d 42 01             	lea    0x1(%edx),%eax
80103066:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
8010306c:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103072:	8b 45 0c             	mov    0xc(%ebp),%eax
80103075:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80103079:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
8010307d:	83 c7 01             	add    $0x1,%edi
80103080:	e9 6f ff ff ff       	jmp    80102ff4 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103085:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010308b:	83 ec 0c             	sub    $0xc,%esp
8010308e:	50                   	push   %eax
8010308f:	e8 95 08 00 00       	call   80103929 <wakeup>
  release(&p->lock);
80103094:	89 1c 24             	mov    %ebx,(%esp)
80103097:	e8 88 0c 00 00       	call   80103d24 <release>
  return n;
8010309c:	83 c4 10             	add    $0x10,%esp
8010309f:	8b 45 10             	mov    0x10(%ebp),%eax
801030a2:	eb b7                	jmp    8010305b <pipewrite+0x83>

801030a4 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801030a4:	55                   	push   %ebp
801030a5:	89 e5                	mov    %esp,%ebp
801030a7:	57                   	push   %edi
801030a8:	56                   	push   %esi
801030a9:	53                   	push   %ebx
801030aa:	83 ec 18             	sub    $0x18,%esp
801030ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801030b0:	89 df                	mov    %ebx,%edi
801030b2:	53                   	push   %ebx
801030b3:	e8 07 0c 00 00       	call   80103cbf <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801030b8:	83 c4 10             	add    $0x10,%esp
801030bb:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801030c1:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801030c7:	75 3d                	jne    80103106 <piperead+0x62>
801030c9:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
801030cf:	85 f6                	test   %esi,%esi
801030d1:	74 38                	je     8010310b <piperead+0x67>
    if(myproc()->killed){
801030d3:	e8 48 02 00 00       	call   80103320 <myproc>
801030d8:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801030dc:	75 15                	jne    801030f3 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801030de:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030e4:	83 ec 08             	sub    $0x8,%esp
801030e7:	57                   	push   %edi
801030e8:	50                   	push   %eax
801030e9:	e8 d6 06 00 00       	call   801037c4 <sleep>
801030ee:	83 c4 10             	add    $0x10,%esp
801030f1:	eb c8                	jmp    801030bb <piperead+0x17>
      release(&p->lock);
801030f3:	83 ec 0c             	sub    $0xc,%esp
801030f6:	53                   	push   %ebx
801030f7:	e8 28 0c 00 00       	call   80103d24 <release>
      return -1;
801030fc:	83 c4 10             	add    $0x10,%esp
801030ff:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103104:	eb 50                	jmp    80103156 <piperead+0xb2>
80103106:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010310b:	3b 75 10             	cmp    0x10(%ebp),%esi
8010310e:	7d 2c                	jge    8010313c <piperead+0x98>
    if(p->nread == p->nwrite)
80103110:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103116:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
8010311c:	74 1e                	je     8010313c <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010311e:	8d 50 01             	lea    0x1(%eax),%edx
80103121:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103127:	25 ff 01 00 00       	and    $0x1ff,%eax
8010312c:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103131:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103134:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103137:	83 c6 01             	add    $0x1,%esi
8010313a:	eb cf                	jmp    8010310b <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010313c:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103142:	83 ec 0c             	sub    $0xc,%esp
80103145:	50                   	push   %eax
80103146:	e8 de 07 00 00       	call   80103929 <wakeup>
  release(&p->lock);
8010314b:	89 1c 24             	mov    %ebx,(%esp)
8010314e:	e8 d1 0b 00 00       	call   80103d24 <release>
  return i;
80103153:	83 c4 10             	add    $0x10,%esp
}
80103156:	89 f0                	mov    %esi,%eax
80103158:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010315b:	5b                   	pop    %ebx
8010315c:	5e                   	pop    %esi
8010315d:	5f                   	pop    %edi
8010315e:	5d                   	pop    %ebp
8010315f:	c3                   	ret    

80103160 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103160:	55                   	push   %ebp
80103161:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103163:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103168:	eb 03                	jmp    8010316d <wakeup1+0xd>
8010316a:	83 c2 7c             	add    $0x7c,%edx
8010316d:	81 fa 54 4c 11 80    	cmp    $0x80114c54,%edx
80103173:	73 14                	jae    80103189 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80103175:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103179:	75 ef                	jne    8010316a <wakeup1+0xa>
8010317b:	39 42 20             	cmp    %eax,0x20(%edx)
8010317e:	75 ea                	jne    8010316a <wakeup1+0xa>
      p->state = RUNNABLE;
80103180:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103187:	eb e1                	jmp    8010316a <wakeup1+0xa>
}
80103189:	5d                   	pop    %ebp
8010318a:	c3                   	ret    

8010318b <allocproc>:
{
8010318b:	55                   	push   %ebp
8010318c:	89 e5                	mov    %esp,%ebp
8010318e:	53                   	push   %ebx
8010318f:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103192:	68 20 2d 11 80       	push   $0x80112d20
80103197:	e8 23 0b 00 00       	call   80103cbf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010319c:	83 c4 10             	add    $0x10,%esp
8010319f:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801031a4:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
801031aa:	73 0b                	jae    801031b7 <allocproc+0x2c>
    if(p->state == UNUSED)
801031ac:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801031b0:	74 1c                	je     801031ce <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031b2:	83 c3 7c             	add    $0x7c,%ebx
801031b5:	eb ed                	jmp    801031a4 <allocproc+0x19>
  release(&ptable.lock);
801031b7:	83 ec 0c             	sub    $0xc,%esp
801031ba:	68 20 2d 11 80       	push   $0x80112d20
801031bf:	e8 60 0b 00 00       	call   80103d24 <release>
  return 0;
801031c4:	83 c4 10             	add    $0x10,%esp
801031c7:	bb 00 00 00 00       	mov    $0x0,%ebx
801031cc:	eb 69                	jmp    80103237 <allocproc+0xac>
  p->state = EMBRYO;
801031ce:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801031d5:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801031da:	8d 50 01             	lea    0x1(%eax),%edx
801031dd:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801031e3:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801031e6:	83 ec 0c             	sub    $0xc,%esp
801031e9:	68 20 2d 11 80       	push   $0x80112d20
801031ee:	e8 31 0b 00 00       	call   80103d24 <release>
  if((p->kstack = kalloc()) == 0){
801031f3:	e8 ed ef ff ff       	call   801021e5 <kalloc>
801031f8:	89 43 08             	mov    %eax,0x8(%ebx)
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 3c                	je     8010323e <allocproc+0xb3>
  sp -= sizeof *p->tf;
80103202:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103208:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010320b:	c7 80 b0 0f 00 00 ca 	movl   $0x80104eca,0xfb0(%eax)
80103212:	4e 10 80 
  sp -= sizeof *p->context;
80103215:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010321a:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010321d:	83 ec 04             	sub    $0x4,%esp
80103220:	6a 14                	push   $0x14
80103222:	6a 00                	push   $0x0
80103224:	50                   	push   %eax
80103225:	e8 41 0b 00 00       	call   80103d6b <memset>
  p->context->eip = (uint)forkret;
8010322a:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010322d:	c7 40 10 4c 32 10 80 	movl   $0x8010324c,0x10(%eax)
  return p;
80103234:	83 c4 10             	add    $0x10,%esp
}
80103237:	89 d8                	mov    %ebx,%eax
80103239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010323c:	c9                   	leave  
8010323d:	c3                   	ret    
    p->state = UNUSED;
8010323e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103245:	bb 00 00 00 00       	mov    $0x0,%ebx
8010324a:	eb eb                	jmp    80103237 <allocproc+0xac>

8010324c <forkret>:
{
8010324c:	55                   	push   %ebp
8010324d:	89 e5                	mov    %esp,%ebp
8010324f:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103252:	68 20 2d 11 80       	push   $0x80112d20
80103257:	e8 c8 0a 00 00       	call   80103d24 <release>
  if (first) {
8010325c:	83 c4 10             	add    $0x10,%esp
8010325f:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103266:	75 02                	jne    8010326a <forkret+0x1e>
}
80103268:	c9                   	leave  
80103269:	c3                   	ret    
    first = 0;
8010326a:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103271:	00 00 00 
    iinit(ROOTDEV);
80103274:	83 ec 0c             	sub    $0xc,%esp
80103277:	6a 01                	push   $0x1
80103279:	e8 6e e0 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
8010327e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103285:	e8 05 f6 ff ff       	call   8010288f <initlog>
8010328a:	83 c4 10             	add    $0x10,%esp
}
8010328d:	eb d9                	jmp    80103268 <forkret+0x1c>

8010328f <pinit>:
{
8010328f:	55                   	push   %ebp
80103290:	89 e5                	mov    %esp,%ebp
80103292:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103295:	68 55 6b 10 80       	push   $0x80106b55
8010329a:	68 20 2d 11 80       	push   $0x80112d20
8010329f:	e8 df 08 00 00       	call   80103b83 <initlock>
}
801032a4:	83 c4 10             	add    $0x10,%esp
801032a7:	c9                   	leave  
801032a8:	c3                   	ret    

801032a9 <mycpu>:
{
801032a9:	55                   	push   %ebp
801032aa:	89 e5                	mov    %esp,%ebp
801032ac:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801032af:	9c                   	pushf  
801032b0:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801032b1:	f6 c4 02             	test   $0x2,%ah
801032b4:	75 28                	jne    801032de <mycpu+0x35>
  apicid = lapicid();
801032b6:	e8 ed f1 ff ff       	call   801024a8 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801032bb:	ba 00 00 00 00       	mov    $0x0,%edx
801032c0:	39 15 00 2d 11 80    	cmp    %edx,0x80112d00
801032c6:	7e 23                	jle    801032eb <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801032c8:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801032ce:	0f b6 89 80 27 11 80 	movzbl -0x7feed880(%ecx),%ecx
801032d5:	39 c1                	cmp    %eax,%ecx
801032d7:	74 1f                	je     801032f8 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801032d9:	83 c2 01             	add    $0x1,%edx
801032dc:	eb e2                	jmp    801032c0 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801032de:	83 ec 0c             	sub    $0xc,%esp
801032e1:	68 38 6c 10 80       	push   $0x80106c38
801032e6:	e8 5d d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
801032eb:	83 ec 0c             	sub    $0xc,%esp
801032ee:	68 5c 6b 10 80       	push   $0x80106b5c
801032f3:	e8 50 d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
801032f8:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801032fe:	05 80 27 11 80       	add    $0x80112780,%eax
}
80103303:	c9                   	leave  
80103304:	c3                   	ret    

80103305 <cpuid>:
cpuid() {
80103305:	55                   	push   %ebp
80103306:	89 e5                	mov    %esp,%ebp
80103308:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010330b:	e8 99 ff ff ff       	call   801032a9 <mycpu>
80103310:	2d 80 27 11 80       	sub    $0x80112780,%eax
80103315:	c1 f8 04             	sar    $0x4,%eax
80103318:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010331e:	c9                   	leave  
8010331f:	c3                   	ret    

80103320 <myproc>:
myproc(void) {
80103320:	55                   	push   %ebp
80103321:	89 e5                	mov    %esp,%ebp
80103323:	53                   	push   %ebx
80103324:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103327:	e8 b6 08 00 00       	call   80103be2 <pushcli>
  c = mycpu();
8010332c:	e8 78 ff ff ff       	call   801032a9 <mycpu>
  p = c->proc;
80103331:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103337:	e8 e3 08 00 00       	call   80103c1f <popcli>
}
8010333c:	89 d8                	mov    %ebx,%eax
8010333e:	83 c4 04             	add    $0x4,%esp
80103341:	5b                   	pop    %ebx
80103342:	5d                   	pop    %ebp
80103343:	c3                   	ret    

80103344 <userinit>:
{
80103344:	55                   	push   %ebp
80103345:	89 e5                	mov    %esp,%ebp
80103347:	53                   	push   %ebx
80103348:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
8010334b:	e8 3b fe ff ff       	call   8010318b <allocproc>
80103350:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103352:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
80103357:	e8 52 30 00 00       	call   801063ae <setupkvm>
8010335c:	89 43 04             	mov    %eax,0x4(%ebx)
8010335f:	85 c0                	test   %eax,%eax
80103361:	0f 84 b7 00 00 00    	je     8010341e <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103367:	83 ec 04             	sub    $0x4,%esp
8010336a:	68 2c 00 00 00       	push   $0x2c
8010336f:	68 60 a4 10 80       	push   $0x8010a460
80103374:	50                   	push   %eax
80103375:	e8 3f 2d 00 00       	call   801060b9 <inituvm>
  p->sz = PGSIZE;
8010337a:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103380:	83 c4 0c             	add    $0xc,%esp
80103383:	6a 4c                	push   $0x4c
80103385:	6a 00                	push   $0x0
80103387:	ff 73 18             	pushl  0x18(%ebx)
8010338a:	e8 dc 09 00 00       	call   80103d6b <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010338f:	8b 43 18             	mov    0x18(%ebx),%eax
80103392:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103398:	8b 43 18             	mov    0x18(%ebx),%eax
8010339b:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801033a1:	8b 43 18             	mov    0x18(%ebx),%eax
801033a4:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033a8:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801033ac:	8b 43 18             	mov    0x18(%ebx),%eax
801033af:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033b3:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801033b7:	8b 43 18             	mov    0x18(%ebx),%eax
801033ba:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801033c1:	8b 43 18             	mov    0x18(%ebx),%eax
801033c4:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801033cb:	8b 43 18             	mov    0x18(%ebx),%eax
801033ce:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801033d5:	8d 43 6c             	lea    0x6c(%ebx),%eax
801033d8:	83 c4 0c             	add    $0xc,%esp
801033db:	6a 10                	push   $0x10
801033dd:	68 85 6b 10 80       	push   $0x80106b85
801033e2:	50                   	push   %eax
801033e3:	e8 ea 0a 00 00       	call   80103ed2 <safestrcpy>
  p->cwd = namei("/");
801033e8:	c7 04 24 8e 6b 10 80 	movl   $0x80106b8e,(%esp)
801033ef:	e8 0b e9 ff ff       	call   80101cff <namei>
801033f4:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801033f7:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801033fe:	e8 bc 08 00 00       	call   80103cbf <acquire>
  p->state = RUNNABLE;
80103403:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010340a:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103411:	e8 0e 09 00 00       	call   80103d24 <release>
}
80103416:	83 c4 10             	add    $0x10,%esp
80103419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010341c:	c9                   	leave  
8010341d:	c3                   	ret    
    panic("userinit: out of memory?");
8010341e:	83 ec 0c             	sub    $0xc,%esp
80103421:	68 6c 6b 10 80       	push   $0x80106b6c
80103426:	e8 1d cf ff ff       	call   80100348 <panic>

8010342b <growproc>:
{
8010342b:	55                   	push   %ebp
8010342c:	89 e5                	mov    %esp,%ebp
8010342e:	56                   	push   %esi
8010342f:	53                   	push   %ebx
80103430:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103433:	e8 e8 fe ff ff       	call   80103320 <myproc>
80103438:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
8010343a:	8b 00                	mov    (%eax),%eax
  if(n > 0){
8010343c:	85 f6                	test   %esi,%esi
8010343e:	7f 21                	jg     80103461 <growproc+0x36>
  } else if(n < 0){
80103440:	85 f6                	test   %esi,%esi
80103442:	79 33                	jns    80103477 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103444:	83 ec 04             	sub    $0x4,%esp
80103447:	01 c6                	add    %eax,%esi
80103449:	56                   	push   %esi
8010344a:	50                   	push   %eax
8010344b:	ff 73 04             	pushl  0x4(%ebx)
8010344e:	e8 6f 2d 00 00       	call   801061c2 <deallocuvm>
80103453:	83 c4 10             	add    $0x10,%esp
80103456:	85 c0                	test   %eax,%eax
80103458:	75 1d                	jne    80103477 <growproc+0x4c>
      return -1;
8010345a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010345f:	eb 29                	jmp    8010348a <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103461:	83 ec 04             	sub    $0x4,%esp
80103464:	01 c6                	add    %eax,%esi
80103466:	56                   	push   %esi
80103467:	50                   	push   %eax
80103468:	ff 73 04             	pushl  0x4(%ebx)
8010346b:	e8 e4 2d 00 00       	call   80106254 <allocuvm>
80103470:	83 c4 10             	add    $0x10,%esp
80103473:	85 c0                	test   %eax,%eax
80103475:	74 1a                	je     80103491 <growproc+0x66>
  curproc->sz = sz;
80103477:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103479:	83 ec 0c             	sub    $0xc,%esp
8010347c:	53                   	push   %ebx
8010347d:	e8 1f 2b 00 00       	call   80105fa1 <switchuvm>
  return 0;
80103482:	83 c4 10             	add    $0x10,%esp
80103485:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010348a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010348d:	5b                   	pop    %ebx
8010348e:	5e                   	pop    %esi
8010348f:	5d                   	pop    %ebp
80103490:	c3                   	ret    
      return -1;
80103491:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103496:	eb f2                	jmp    8010348a <growproc+0x5f>

80103498 <fork>:
{
80103498:	55                   	push   %ebp
80103499:	89 e5                	mov    %esp,%ebp
8010349b:	57                   	push   %edi
8010349c:	56                   	push   %esi
8010349d:	53                   	push   %ebx
8010349e:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801034a1:	e8 7a fe ff ff       	call   80103320 <myproc>
801034a6:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801034a8:	e8 de fc ff ff       	call   8010318b <allocproc>
801034ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801034b0:	85 c0                	test   %eax,%eax
801034b2:	0f 84 e0 00 00 00    	je     80103598 <fork+0x100>
801034b8:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	ff 33                	pushl  (%ebx)
801034bf:	ff 73 04             	pushl  0x4(%ebx)
801034c2:	e8 98 2f 00 00       	call   8010645f <copyuvm>
801034c7:	89 47 04             	mov    %eax,0x4(%edi)
801034ca:	83 c4 10             	add    $0x10,%esp
801034cd:	85 c0                	test   %eax,%eax
801034cf:	74 2a                	je     801034fb <fork+0x63>
  np->sz = curproc->sz;
801034d1:	8b 03                	mov    (%ebx),%eax
801034d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801034d6:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801034d8:	89 c8                	mov    %ecx,%eax
801034da:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801034dd:	8b 73 18             	mov    0x18(%ebx),%esi
801034e0:	8b 79 18             	mov    0x18(%ecx),%edi
801034e3:	b9 13 00 00 00       	mov    $0x13,%ecx
801034e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801034ea:	8b 40 18             	mov    0x18(%eax),%eax
801034ed:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801034f4:	be 00 00 00 00       	mov    $0x0,%esi
801034f9:	eb 29                	jmp    80103524 <fork+0x8c>
    kfree(np->kstack);
801034fb:	83 ec 0c             	sub    $0xc,%esp
801034fe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103501:	ff 73 08             	pushl  0x8(%ebx)
80103504:	e8 c5 eb ff ff       	call   801020ce <kfree>
    np->kstack = 0;
80103509:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103510:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103517:	83 c4 10             	add    $0x10,%esp
8010351a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010351f:	eb 6d                	jmp    8010358e <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103521:	83 c6 01             	add    $0x1,%esi
80103524:	83 fe 0f             	cmp    $0xf,%esi
80103527:	7f 1d                	jg     80103546 <fork+0xae>
    if(curproc->ofile[i])
80103529:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010352d:	85 c0                	test   %eax,%eax
8010352f:	74 f0                	je     80103521 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103531:	83 ec 0c             	sub    $0xc,%esp
80103534:	50                   	push   %eax
80103535:	e8 54 d7 ff ff       	call   80100c8e <filedup>
8010353a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010353d:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103541:	83 c4 10             	add    $0x10,%esp
80103544:	eb db                	jmp    80103521 <fork+0x89>
  np->cwd = idup(curproc->cwd);
80103546:	83 ec 0c             	sub    $0xc,%esp
80103549:	ff 73 68             	pushl  0x68(%ebx)
8010354c:	e8 00 e0 ff ff       	call   80101551 <idup>
80103551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103554:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103557:	83 c3 6c             	add    $0x6c,%ebx
8010355a:	8d 47 6c             	lea    0x6c(%edi),%eax
8010355d:	83 c4 0c             	add    $0xc,%esp
80103560:	6a 10                	push   $0x10
80103562:	53                   	push   %ebx
80103563:	50                   	push   %eax
80103564:	e8 69 09 00 00       	call   80103ed2 <safestrcpy>
  pid = np->pid;
80103569:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010356c:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103573:	e8 47 07 00 00       	call   80103cbf <acquire>
  np->state = RUNNABLE;
80103578:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
8010357f:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103586:	e8 99 07 00 00       	call   80103d24 <release>
  return pid;
8010358b:	83 c4 10             	add    $0x10,%esp
}
8010358e:	89 d8                	mov    %ebx,%eax
80103590:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103593:	5b                   	pop    %ebx
80103594:	5e                   	pop    %esi
80103595:	5f                   	pop    %edi
80103596:	5d                   	pop    %ebp
80103597:	c3                   	ret    
    return -1;
80103598:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010359d:	eb ef                	jmp    8010358e <fork+0xf6>

8010359f <scheduler>:
{
8010359f:	55                   	push   %ebp
801035a0:	89 e5                	mov    %esp,%ebp
801035a2:	56                   	push   %esi
801035a3:	53                   	push   %ebx
  struct cpu *c = mycpu();
801035a4:	e8 00 fd ff ff       	call   801032a9 <mycpu>
801035a9:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801035ab:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801035b2:	00 00 00 
801035b5:	eb 5a                	jmp    80103611 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035b7:	83 c3 7c             	add    $0x7c,%ebx
801035ba:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
801035c0:	73 3f                	jae    80103601 <scheduler+0x62>
      if(p->state != RUNNABLE)
801035c2:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035c6:	75 ef                	jne    801035b7 <scheduler+0x18>
      c->proc = p;
801035c8:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801035ce:	83 ec 0c             	sub    $0xc,%esp
801035d1:	53                   	push   %ebx
801035d2:	e8 ca 29 00 00       	call   80105fa1 <switchuvm>
      p->state = RUNNING;
801035d7:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801035de:	83 c4 08             	add    $0x8,%esp
801035e1:	ff 73 1c             	pushl  0x1c(%ebx)
801035e4:	8d 46 04             	lea    0x4(%esi),%eax
801035e7:	50                   	push   %eax
801035e8:	e8 38 09 00 00       	call   80103f25 <swtch>
      switchkvm();
801035ed:	e8 9d 29 00 00       	call   80105f8f <switchkvm>
      c->proc = 0;
801035f2:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035f9:	00 00 00 
801035fc:	83 c4 10             	add    $0x10,%esp
801035ff:	eb b6                	jmp    801035b7 <scheduler+0x18>
    release(&ptable.lock);
80103601:	83 ec 0c             	sub    $0xc,%esp
80103604:	68 20 2d 11 80       	push   $0x80112d20
80103609:	e8 16 07 00 00       	call   80103d24 <release>
    sti();
8010360e:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103611:	fb                   	sti    
    acquire(&ptable.lock);
80103612:	83 ec 0c             	sub    $0xc,%esp
80103615:	68 20 2d 11 80       	push   $0x80112d20
8010361a:	e8 a0 06 00 00       	call   80103cbf <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010361f:	83 c4 10             	add    $0x10,%esp
80103622:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103627:	eb 91                	jmp    801035ba <scheduler+0x1b>

80103629 <sched>:
{
80103629:	55                   	push   %ebp
8010362a:	89 e5                	mov    %esp,%ebp
8010362c:	56                   	push   %esi
8010362d:	53                   	push   %ebx
  struct proc *p = myproc();
8010362e:	e8 ed fc ff ff       	call   80103320 <myproc>
80103633:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 20 2d 11 80       	push   $0x80112d20
8010363d:	e8 3d 06 00 00       	call   80103c7f <holding>
80103642:	83 c4 10             	add    $0x10,%esp
80103645:	85 c0                	test   %eax,%eax
80103647:	74 4f                	je     80103698 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103649:	e8 5b fc ff ff       	call   801032a9 <mycpu>
8010364e:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103655:	75 4e                	jne    801036a5 <sched+0x7c>
  if(p->state == RUNNING)
80103657:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010365b:	74 55                	je     801036b2 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010365d:	9c                   	pushf  
8010365e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010365f:	f6 c4 02             	test   $0x2,%ah
80103662:	75 5b                	jne    801036bf <sched+0x96>
  intena = mycpu()->intena;
80103664:	e8 40 fc ff ff       	call   801032a9 <mycpu>
80103669:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010366f:	e8 35 fc ff ff       	call   801032a9 <mycpu>
80103674:	83 ec 08             	sub    $0x8,%esp
80103677:	ff 70 04             	pushl  0x4(%eax)
8010367a:	83 c3 1c             	add    $0x1c,%ebx
8010367d:	53                   	push   %ebx
8010367e:	e8 a2 08 00 00       	call   80103f25 <swtch>
  mycpu()->intena = intena;
80103683:	e8 21 fc ff ff       	call   801032a9 <mycpu>
80103688:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010368e:	83 c4 10             	add    $0x10,%esp
80103691:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103694:	5b                   	pop    %ebx
80103695:	5e                   	pop    %esi
80103696:	5d                   	pop    %ebp
80103697:	c3                   	ret    
    panic("sched ptable.lock");
80103698:	83 ec 0c             	sub    $0xc,%esp
8010369b:	68 90 6b 10 80       	push   $0x80106b90
801036a0:	e8 a3 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
801036a5:	83 ec 0c             	sub    $0xc,%esp
801036a8:	68 a2 6b 10 80       	push   $0x80106ba2
801036ad:	e8 96 cc ff ff       	call   80100348 <panic>
    panic("sched running");
801036b2:	83 ec 0c             	sub    $0xc,%esp
801036b5:	68 ae 6b 10 80       	push   $0x80106bae
801036ba:	e8 89 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801036bf:	83 ec 0c             	sub    $0xc,%esp
801036c2:	68 bc 6b 10 80       	push   $0x80106bbc
801036c7:	e8 7c cc ff ff       	call   80100348 <panic>

801036cc <exit>:
{
801036cc:	55                   	push   %ebp
801036cd:	89 e5                	mov    %esp,%ebp
801036cf:	56                   	push   %esi
801036d0:	53                   	push   %ebx
  struct proc *curproc = myproc();
801036d1:	e8 4a fc ff ff       	call   80103320 <myproc>
  if(curproc == initproc)
801036d6:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
801036dc:	74 09                	je     801036e7 <exit+0x1b>
801036de:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801036e0:	bb 00 00 00 00       	mov    $0x0,%ebx
801036e5:	eb 10                	jmp    801036f7 <exit+0x2b>
    panic("init exiting");
801036e7:	83 ec 0c             	sub    $0xc,%esp
801036ea:	68 d0 6b 10 80       	push   $0x80106bd0
801036ef:	e8 54 cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801036f4:	83 c3 01             	add    $0x1,%ebx
801036f7:	83 fb 0f             	cmp    $0xf,%ebx
801036fa:	7f 1e                	jg     8010371a <exit+0x4e>
    if(curproc->ofile[fd]){
801036fc:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103700:	85 c0                	test   %eax,%eax
80103702:	74 f0                	je     801036f4 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103704:	83 ec 0c             	sub    $0xc,%esp
80103707:	50                   	push   %eax
80103708:	e8 c6 d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
8010370d:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103714:	00 
80103715:	83 c4 10             	add    $0x10,%esp
80103718:	eb da                	jmp    801036f4 <exit+0x28>
  begin_op();
8010371a:	e8 b9 f1 ff ff       	call   801028d8 <begin_op>
  iput(curproc->cwd);
8010371f:	83 ec 0c             	sub    $0xc,%esp
80103722:	ff 76 68             	pushl  0x68(%esi)
80103725:	e8 5e df ff ff       	call   80101688 <iput>
  end_op();
8010372a:	e8 23 f2 ff ff       	call   80102952 <end_op>
  curproc->cwd = 0;
8010372f:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103736:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010373d:	e8 7d 05 00 00       	call   80103cbf <acquire>
  wakeup1(curproc->parent);
80103742:	8b 46 14             	mov    0x14(%esi),%eax
80103745:	e8 16 fa ff ff       	call   80103160 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010374a:	83 c4 10             	add    $0x10,%esp
8010374d:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103752:	eb 03                	jmp    80103757 <exit+0x8b>
80103754:	83 c3 7c             	add    $0x7c,%ebx
80103757:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
8010375d:	73 1a                	jae    80103779 <exit+0xad>
    if(p->parent == curproc){
8010375f:	39 73 14             	cmp    %esi,0x14(%ebx)
80103762:	75 f0                	jne    80103754 <exit+0x88>
      p->parent = initproc;
80103764:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80103769:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010376c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103770:	75 e2                	jne    80103754 <exit+0x88>
        wakeup1(initproc);
80103772:	e8 e9 f9 ff ff       	call   80103160 <wakeup1>
80103777:	eb db                	jmp    80103754 <exit+0x88>
  curproc->state = ZOMBIE;
80103779:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103780:	e8 a4 fe ff ff       	call   80103629 <sched>
  panic("zombie exit");
80103785:	83 ec 0c             	sub    $0xc,%esp
80103788:	68 dd 6b 10 80       	push   $0x80106bdd
8010378d:	e8 b6 cb ff ff       	call   80100348 <panic>

80103792 <yield>:
{
80103792:	55                   	push   %ebp
80103793:	89 e5                	mov    %esp,%ebp
80103795:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103798:	68 20 2d 11 80       	push   $0x80112d20
8010379d:	e8 1d 05 00 00       	call   80103cbf <acquire>
  myproc()->state = RUNNABLE;
801037a2:	e8 79 fb ff ff       	call   80103320 <myproc>
801037a7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801037ae:	e8 76 fe ff ff       	call   80103629 <sched>
  release(&ptable.lock);
801037b3:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037ba:	e8 65 05 00 00       	call   80103d24 <release>
}
801037bf:	83 c4 10             	add    $0x10,%esp
801037c2:	c9                   	leave  
801037c3:	c3                   	ret    

801037c4 <sleep>:
{
801037c4:	55                   	push   %ebp
801037c5:	89 e5                	mov    %esp,%ebp
801037c7:	56                   	push   %esi
801037c8:	53                   	push   %ebx
801037c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801037cc:	e8 4f fb ff ff       	call   80103320 <myproc>
  if(p == 0)
801037d1:	85 c0                	test   %eax,%eax
801037d3:	74 66                	je     8010383b <sleep+0x77>
801037d5:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801037d7:	85 db                	test   %ebx,%ebx
801037d9:	74 6d                	je     80103848 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801037db:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
801037e1:	74 18                	je     801037fb <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801037e3:	83 ec 0c             	sub    $0xc,%esp
801037e6:	68 20 2d 11 80       	push   $0x80112d20
801037eb:	e8 cf 04 00 00       	call   80103cbf <acquire>
    release(lk);
801037f0:	89 1c 24             	mov    %ebx,(%esp)
801037f3:	e8 2c 05 00 00       	call   80103d24 <release>
801037f8:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801037fb:	8b 45 08             	mov    0x8(%ebp),%eax
801037fe:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103801:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103808:	e8 1c fe ff ff       	call   80103629 <sched>
  p->chan = 0;
8010380d:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103814:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
8010381a:	74 18                	je     80103834 <sleep+0x70>
    release(&ptable.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 20 2d 11 80       	push   $0x80112d20
80103824:	e8 fb 04 00 00       	call   80103d24 <release>
    acquire(lk);
80103829:	89 1c 24             	mov    %ebx,(%esp)
8010382c:	e8 8e 04 00 00       	call   80103cbf <acquire>
80103831:	83 c4 10             	add    $0x10,%esp
}
80103834:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103837:	5b                   	pop    %ebx
80103838:	5e                   	pop    %esi
80103839:	5d                   	pop    %ebp
8010383a:	c3                   	ret    
    panic("sleep");
8010383b:	83 ec 0c             	sub    $0xc,%esp
8010383e:	68 e9 6b 10 80       	push   $0x80106be9
80103843:	e8 00 cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103848:	83 ec 0c             	sub    $0xc,%esp
8010384b:	68 ef 6b 10 80       	push   $0x80106bef
80103850:	e8 f3 ca ff ff       	call   80100348 <panic>

80103855 <wait>:
{
80103855:	55                   	push   %ebp
80103856:	89 e5                	mov    %esp,%ebp
80103858:	56                   	push   %esi
80103859:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010385a:	e8 c1 fa ff ff       	call   80103320 <myproc>
8010385f:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103861:	83 ec 0c             	sub    $0xc,%esp
80103864:	68 20 2d 11 80       	push   $0x80112d20
80103869:	e8 51 04 00 00       	call   80103cbf <acquire>
8010386e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103871:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103876:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010387b:	eb 5b                	jmp    801038d8 <wait+0x83>
        pid = p->pid;
8010387d:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103880:	83 ec 0c             	sub    $0xc,%esp
80103883:	ff 73 08             	pushl  0x8(%ebx)
80103886:	e8 43 e8 ff ff       	call   801020ce <kfree>
        p->kstack = 0;
8010388b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103892:	83 c4 04             	add    $0x4,%esp
80103895:	ff 73 04             	pushl  0x4(%ebx)
80103898:	e8 a1 2a 00 00       	call   8010633e <freevm>
        p->pid = 0;
8010389d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801038a4:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038ab:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038af:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038b6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801038bd:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038c4:	e8 5b 04 00 00       	call   80103d24 <release>
        return pid;
801038c9:	83 c4 10             	add    $0x10,%esp
}
801038cc:	89 f0                	mov    %esi,%eax
801038ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038d1:	5b                   	pop    %ebx
801038d2:	5e                   	pop    %esi
801038d3:	5d                   	pop    %ebp
801038d4:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038d5:	83 c3 7c             	add    $0x7c,%ebx
801038d8:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
801038de:	73 12                	jae    801038f2 <wait+0x9d>
      if(p->parent != curproc)
801038e0:	39 73 14             	cmp    %esi,0x14(%ebx)
801038e3:	75 f0                	jne    801038d5 <wait+0x80>
      if(p->state == ZOMBIE){
801038e5:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801038e9:	74 92                	je     8010387d <wait+0x28>
      havekids = 1;
801038eb:	b8 01 00 00 00       	mov    $0x1,%eax
801038f0:	eb e3                	jmp    801038d5 <wait+0x80>
    if(!havekids || curproc->killed){
801038f2:	85 c0                	test   %eax,%eax
801038f4:	74 06                	je     801038fc <wait+0xa7>
801038f6:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801038fa:	74 17                	je     80103913 <wait+0xbe>
      release(&ptable.lock);
801038fc:	83 ec 0c             	sub    $0xc,%esp
801038ff:	68 20 2d 11 80       	push   $0x80112d20
80103904:	e8 1b 04 00 00       	call   80103d24 <release>
      return -1;
80103909:	83 c4 10             	add    $0x10,%esp
8010390c:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103911:	eb b9                	jmp    801038cc <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103913:	83 ec 08             	sub    $0x8,%esp
80103916:	68 20 2d 11 80       	push   $0x80112d20
8010391b:	56                   	push   %esi
8010391c:	e8 a3 fe ff ff       	call   801037c4 <sleep>
    havekids = 0;
80103921:	83 c4 10             	add    $0x10,%esp
80103924:	e9 48 ff ff ff       	jmp    80103871 <wait+0x1c>

80103929 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103929:	55                   	push   %ebp
8010392a:	89 e5                	mov    %esp,%ebp
8010392c:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010392f:	68 20 2d 11 80       	push   $0x80112d20
80103934:	e8 86 03 00 00       	call   80103cbf <acquire>
  wakeup1(chan);
80103939:	8b 45 08             	mov    0x8(%ebp),%eax
8010393c:	e8 1f f8 ff ff       	call   80103160 <wakeup1>
  release(&ptable.lock);
80103941:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103948:	e8 d7 03 00 00       	call   80103d24 <release>
}
8010394d:	83 c4 10             	add    $0x10,%esp
80103950:	c9                   	leave  
80103951:	c3                   	ret    

80103952 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
80103955:	53                   	push   %ebx
80103956:	83 ec 10             	sub    $0x10,%esp
80103959:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010395c:	68 20 2d 11 80       	push   $0x80112d20
80103961:	e8 59 03 00 00       	call   80103cbf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103966:	83 c4 10             	add    $0x10,%esp
80103969:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
8010396e:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103973:	73 3a                	jae    801039af <kill+0x5d>
    if(p->pid == pid){
80103975:	39 58 10             	cmp    %ebx,0x10(%eax)
80103978:	74 05                	je     8010397f <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010397a:	83 c0 7c             	add    $0x7c,%eax
8010397d:	eb ef                	jmp    8010396e <kill+0x1c>
      p->killed = 1;
8010397f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103986:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010398a:	74 1a                	je     801039a6 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
8010398c:	83 ec 0c             	sub    $0xc,%esp
8010398f:	68 20 2d 11 80       	push   $0x80112d20
80103994:	e8 8b 03 00 00       	call   80103d24 <release>
      return 0;
80103999:	83 c4 10             	add    $0x10,%esp
8010399c:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039a4:	c9                   	leave  
801039a5:	c3                   	ret    
        p->state = RUNNABLE;
801039a6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801039ad:	eb dd                	jmp    8010398c <kill+0x3a>
  release(&ptable.lock);
801039af:	83 ec 0c             	sub    $0xc,%esp
801039b2:	68 20 2d 11 80       	push   $0x80112d20
801039b7:	e8 68 03 00 00       	call   80103d24 <release>
  return -1;
801039bc:	83 c4 10             	add    $0x10,%esp
801039bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039c4:	eb db                	jmp    801039a1 <kill+0x4f>

801039c6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801039c6:	55                   	push   %ebp
801039c7:	89 e5                	mov    %esp,%ebp
801039c9:	56                   	push   %esi
801039ca:	53                   	push   %ebx
801039cb:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ce:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801039d3:	eb 33                	jmp    80103a08 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801039d5:	b8 00 6c 10 80       	mov    $0x80106c00,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801039da:	8d 53 6c             	lea    0x6c(%ebx),%edx
801039dd:	52                   	push   %edx
801039de:	50                   	push   %eax
801039df:	ff 73 10             	pushl  0x10(%ebx)
801039e2:	68 04 6c 10 80       	push   $0x80106c04
801039e7:	e8 1f cc ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
801039ec:	83 c4 10             	add    $0x10,%esp
801039ef:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801039f3:	74 39                	je     80103a2e <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801039f5:	83 ec 0c             	sub    $0xc,%esp
801039f8:	68 9f 6f 10 80       	push   $0x80106f9f
801039fd:	e8 09 cc ff ff       	call   8010060b <cprintf>
80103a02:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a05:	83 c3 7c             	add    $0x7c,%ebx
80103a08:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
80103a0e:	73 61                	jae    80103a71 <procdump+0xab>
    if(p->state == UNUSED)
80103a10:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a13:	85 c0                	test   %eax,%eax
80103a15:	74 ee                	je     80103a05 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a17:	83 f8 05             	cmp    $0x5,%eax
80103a1a:	77 b9                	ja     801039d5 <procdump+0xf>
80103a1c:	8b 04 85 60 6c 10 80 	mov    -0x7fef93a0(,%eax,4),%eax
80103a23:	85 c0                	test   %eax,%eax
80103a25:	75 b3                	jne    801039da <procdump+0x14>
      state = "???";
80103a27:	b8 00 6c 10 80       	mov    $0x80106c00,%eax
80103a2c:	eb ac                	jmp    801039da <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a2e:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a31:	8b 40 0c             	mov    0xc(%eax),%eax
80103a34:	83 c0 08             	add    $0x8,%eax
80103a37:	83 ec 08             	sub    $0x8,%esp
80103a3a:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a3d:	52                   	push   %edx
80103a3e:	50                   	push   %eax
80103a3f:	e8 5a 01 00 00       	call   80103b9e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a44:	83 c4 10             	add    $0x10,%esp
80103a47:	be 00 00 00 00       	mov    $0x0,%esi
80103a4c:	eb 14                	jmp    80103a62 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103a4e:	83 ec 08             	sub    $0x8,%esp
80103a51:	50                   	push   %eax
80103a52:	68 41 66 10 80       	push   $0x80106641
80103a57:	e8 af cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a5c:	83 c6 01             	add    $0x1,%esi
80103a5f:	83 c4 10             	add    $0x10,%esp
80103a62:	83 fe 09             	cmp    $0x9,%esi
80103a65:	7f 8e                	jg     801039f5 <procdump+0x2f>
80103a67:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a6b:	85 c0                	test   %eax,%eax
80103a6d:	75 df                	jne    80103a4e <procdump+0x88>
80103a6f:	eb 84                	jmp    801039f5 <procdump+0x2f>
  }
}
80103a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a74:	5b                   	pop    %ebx
80103a75:	5e                   	pop    %esi
80103a76:	5d                   	pop    %ebp
80103a77:	c3                   	ret    

80103a78 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103a78:	55                   	push   %ebp
80103a79:	89 e5                	mov    %esp,%ebp
80103a7b:	53                   	push   %ebx
80103a7c:	83 ec 0c             	sub    $0xc,%esp
80103a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a82:	68 78 6c 10 80       	push   $0x80106c78
80103a87:	8d 43 04             	lea    0x4(%ebx),%eax
80103a8a:	50                   	push   %eax
80103a8b:	e8 f3 00 00 00       	call   80103b83 <initlock>
  lk->name = name;
80103a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a93:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a96:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a9c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103aa3:	83 c4 10             	add    $0x10,%esp
80103aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103aa9:	c9                   	leave  
80103aaa:	c3                   	ret    

80103aab <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103aab:	55                   	push   %ebp
80103aac:	89 e5                	mov    %esp,%ebp
80103aae:	56                   	push   %esi
80103aaf:	53                   	push   %ebx
80103ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103ab3:	8d 73 04             	lea    0x4(%ebx),%esi
80103ab6:	83 ec 0c             	sub    $0xc,%esp
80103ab9:	56                   	push   %esi
80103aba:	e8 00 02 00 00       	call   80103cbf <acquire>
  while (lk->locked) {
80103abf:	83 c4 10             	add    $0x10,%esp
80103ac2:	eb 0d                	jmp    80103ad1 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103ac4:	83 ec 08             	sub    $0x8,%esp
80103ac7:	56                   	push   %esi
80103ac8:	53                   	push   %ebx
80103ac9:	e8 f6 fc ff ff       	call   801037c4 <sleep>
80103ace:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103ad1:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ad4:	75 ee                	jne    80103ac4 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103ad6:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103adc:	e8 3f f8 ff ff       	call   80103320 <myproc>
80103ae1:	8b 40 10             	mov    0x10(%eax),%eax
80103ae4:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103ae7:	83 ec 0c             	sub    $0xc,%esp
80103aea:	56                   	push   %esi
80103aeb:	e8 34 02 00 00       	call   80103d24 <release>
}
80103af0:	83 c4 10             	add    $0x10,%esp
80103af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103af6:	5b                   	pop    %ebx
80103af7:	5e                   	pop    %esi
80103af8:	5d                   	pop    %ebp
80103af9:	c3                   	ret    

80103afa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103afa:	55                   	push   %ebp
80103afb:	89 e5                	mov    %esp,%ebp
80103afd:	56                   	push   %esi
80103afe:	53                   	push   %ebx
80103aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b02:	8d 73 04             	lea    0x4(%ebx),%esi
80103b05:	83 ec 0c             	sub    $0xc,%esp
80103b08:	56                   	push   %esi
80103b09:	e8 b1 01 00 00       	call   80103cbf <acquire>
  lk->locked = 0;
80103b0e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b14:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103b1b:	89 1c 24             	mov    %ebx,(%esp)
80103b1e:	e8 06 fe ff ff       	call   80103929 <wakeup>
  release(&lk->lk);
80103b23:	89 34 24             	mov    %esi,(%esp)
80103b26:	e8 f9 01 00 00       	call   80103d24 <release>
}
80103b2b:	83 c4 10             	add    $0x10,%esp
80103b2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b31:	5b                   	pop    %ebx
80103b32:	5e                   	pop    %esi
80103b33:	5d                   	pop    %ebp
80103b34:	c3                   	ret    

80103b35 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103b35:	55                   	push   %ebp
80103b36:	89 e5                	mov    %esp,%ebp
80103b38:	56                   	push   %esi
80103b39:	53                   	push   %ebx
80103b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103b3d:	8d 73 04             	lea    0x4(%ebx),%esi
80103b40:	83 ec 0c             	sub    $0xc,%esp
80103b43:	56                   	push   %esi
80103b44:	e8 76 01 00 00       	call   80103cbf <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103b49:	83 c4 10             	add    $0x10,%esp
80103b4c:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b4f:	75 17                	jne    80103b68 <holdingsleep+0x33>
80103b51:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103b56:	83 ec 0c             	sub    $0xc,%esp
80103b59:	56                   	push   %esi
80103b5a:	e8 c5 01 00 00       	call   80103d24 <release>
  return r;
}
80103b5f:	89 d8                	mov    %ebx,%eax
80103b61:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b64:	5b                   	pop    %ebx
80103b65:	5e                   	pop    %esi
80103b66:	5d                   	pop    %ebp
80103b67:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103b68:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103b6b:	e8 b0 f7 ff ff       	call   80103320 <myproc>
80103b70:	3b 58 10             	cmp    0x10(%eax),%ebx
80103b73:	74 07                	je     80103b7c <holdingsleep+0x47>
80103b75:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b7a:	eb da                	jmp    80103b56 <holdingsleep+0x21>
80103b7c:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b81:	eb d3                	jmp    80103b56 <holdingsleep+0x21>

80103b83 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b83:	55                   	push   %ebp
80103b84:	89 e5                	mov    %esp,%ebp
80103b86:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b89:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b8c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b9c:	5d                   	pop    %ebp
80103b9d:	c3                   	ret    

80103b9e <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b9e:	55                   	push   %ebp
80103b9f:	89 e5                	mov    %esp,%ebp
80103ba1:	53                   	push   %ebx
80103ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba8:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103bab:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb0:	83 f8 09             	cmp    $0x9,%eax
80103bb3:	7f 25                	jg     80103bda <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103bb5:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103bbb:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103bc1:	77 17                	ja     80103bda <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103bc3:	8b 5a 04             	mov    0x4(%edx),%ebx
80103bc6:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103bc9:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103bcb:	83 c0 01             	add    $0x1,%eax
80103bce:	eb e0                	jmp    80103bb0 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103bd0:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103bd7:	83 c0 01             	add    $0x1,%eax
80103bda:	83 f8 09             	cmp    $0x9,%eax
80103bdd:	7e f1                	jle    80103bd0 <getcallerpcs+0x32>
}
80103bdf:	5b                   	pop    %ebx
80103be0:	5d                   	pop    %ebp
80103be1:	c3                   	ret    

80103be2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103be2:	55                   	push   %ebp
80103be3:	89 e5                	mov    %esp,%ebp
80103be5:	53                   	push   %ebx
80103be6:	83 ec 04             	sub    $0x4,%esp
80103be9:	9c                   	pushf  
80103bea:	5b                   	pop    %ebx
  asm volatile("cli");
80103beb:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103bec:	e8 b8 f6 ff ff       	call   801032a9 <mycpu>
80103bf1:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bf8:	74 12                	je     80103c0c <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103bfa:	e8 aa f6 ff ff       	call   801032a9 <mycpu>
80103bff:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c06:	83 c4 04             	add    $0x4,%esp
80103c09:	5b                   	pop    %ebx
80103c0a:	5d                   	pop    %ebp
80103c0b:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c0c:	e8 98 f6 ff ff       	call   801032a9 <mycpu>
80103c11:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103c17:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103c1d:	eb db                	jmp    80103bfa <pushcli+0x18>

80103c1f <popcli>:

void
popcli(void)
{
80103c1f:	55                   	push   %ebp
80103c20:	89 e5                	mov    %esp,%ebp
80103c22:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c25:	9c                   	pushf  
80103c26:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c27:	f6 c4 02             	test   $0x2,%ah
80103c2a:	75 28                	jne    80103c54 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103c2c:	e8 78 f6 ff ff       	call   801032a9 <mycpu>
80103c31:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103c37:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103c3a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103c40:	85 d2                	test   %edx,%edx
80103c42:	78 1d                	js     80103c61 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c44:	e8 60 f6 ff ff       	call   801032a9 <mycpu>
80103c49:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c50:	74 1c                	je     80103c6e <popcli+0x4f>
    sti();
}
80103c52:	c9                   	leave  
80103c53:	c3                   	ret    
    panic("popcli - interruptible");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 83 6c 10 80       	push   $0x80106c83
80103c5c:	e8 e7 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103c61:	83 ec 0c             	sub    $0xc,%esp
80103c64:	68 9a 6c 10 80       	push   $0x80106c9a
80103c69:	e8 da c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c6e:	e8 36 f6 ff ff       	call   801032a9 <mycpu>
80103c73:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c7a:	74 d6                	je     80103c52 <popcli+0x33>
  asm volatile("sti");
80103c7c:	fb                   	sti    
}
80103c7d:	eb d3                	jmp    80103c52 <popcli+0x33>

80103c7f <holding>:
{
80103c7f:	55                   	push   %ebp
80103c80:	89 e5                	mov    %esp,%ebp
80103c82:	53                   	push   %ebx
80103c83:	83 ec 04             	sub    $0x4,%esp
80103c86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c89:	e8 54 ff ff ff       	call   80103be2 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c8e:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c91:	75 12                	jne    80103ca5 <holding+0x26>
80103c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c98:	e8 82 ff ff ff       	call   80103c1f <popcli>
}
80103c9d:	89 d8                	mov    %ebx,%eax
80103c9f:	83 c4 04             	add    $0x4,%esp
80103ca2:	5b                   	pop    %ebx
80103ca3:	5d                   	pop    %ebp
80103ca4:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103ca5:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103ca8:	e8 fc f5 ff ff       	call   801032a9 <mycpu>
80103cad:	39 c3                	cmp    %eax,%ebx
80103caf:	74 07                	je     80103cb8 <holding+0x39>
80103cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cb6:	eb e0                	jmp    80103c98 <holding+0x19>
80103cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cbd:	eb d9                	jmp    80103c98 <holding+0x19>

80103cbf <acquire>:
{
80103cbf:	55                   	push   %ebp
80103cc0:	89 e5                	mov    %esp,%ebp
80103cc2:	53                   	push   %ebx
80103cc3:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103cc6:	e8 17 ff ff ff       	call   80103be2 <pushcli>
  if(holding(lk))
80103ccb:	83 ec 0c             	sub    $0xc,%esp
80103cce:	ff 75 08             	pushl  0x8(%ebp)
80103cd1:	e8 a9 ff ff ff       	call   80103c7f <holding>
80103cd6:	83 c4 10             	add    $0x10,%esp
80103cd9:	85 c0                	test   %eax,%eax
80103cdb:	75 3a                	jne    80103d17 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103ce0:	b8 01 00 00 00       	mov    $0x1,%eax
80103ce5:	f0 87 02             	lock xchg %eax,(%edx)
80103ce8:	85 c0                	test   %eax,%eax
80103cea:	75 f1                	jne    80103cdd <acquire+0x1e>
  __sync_synchronize();
80103cec:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103cf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103cf4:	e8 b0 f5 ff ff       	call   801032a9 <mycpu>
80103cf9:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103cff:	83 c0 0c             	add    $0xc,%eax
80103d02:	83 ec 08             	sub    $0x8,%esp
80103d05:	50                   	push   %eax
80103d06:	8d 45 08             	lea    0x8(%ebp),%eax
80103d09:	50                   	push   %eax
80103d0a:	e8 8f fe ff ff       	call   80103b9e <getcallerpcs>
}
80103d0f:	83 c4 10             	add    $0x10,%esp
80103d12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d15:	c9                   	leave  
80103d16:	c3                   	ret    
    panic("acquire");
80103d17:	83 ec 0c             	sub    $0xc,%esp
80103d1a:	68 a1 6c 10 80       	push   $0x80106ca1
80103d1f:	e8 24 c6 ff ff       	call   80100348 <panic>

80103d24 <release>:
{
80103d24:	55                   	push   %ebp
80103d25:	89 e5                	mov    %esp,%ebp
80103d27:	53                   	push   %ebx
80103d28:	83 ec 10             	sub    $0x10,%esp
80103d2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103d2e:	53                   	push   %ebx
80103d2f:	e8 4b ff ff ff       	call   80103c7f <holding>
80103d34:	83 c4 10             	add    $0x10,%esp
80103d37:	85 c0                	test   %eax,%eax
80103d39:	74 23                	je     80103d5e <release+0x3a>
  lk->pcs[0] = 0;
80103d3b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103d42:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103d49:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103d4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103d54:	e8 c6 fe ff ff       	call   80103c1f <popcli>
}
80103d59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d5c:	c9                   	leave  
80103d5d:	c3                   	ret    
    panic("release");
80103d5e:	83 ec 0c             	sub    $0xc,%esp
80103d61:	68 a9 6c 10 80       	push   $0x80106ca9
80103d66:	e8 dd c5 ff ff       	call   80100348 <panic>

80103d6b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103d6b:	55                   	push   %ebp
80103d6c:	89 e5                	mov    %esp,%ebp
80103d6e:	57                   	push   %edi
80103d6f:	53                   	push   %ebx
80103d70:	8b 55 08             	mov    0x8(%ebp),%edx
80103d73:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103d76:	f6 c2 03             	test   $0x3,%dl
80103d79:	75 05                	jne    80103d80 <memset+0x15>
80103d7b:	f6 c1 03             	test   $0x3,%cl
80103d7e:	74 0e                	je     80103d8e <memset+0x23>
  asm volatile("cld; rep stosb" :
80103d80:	89 d7                	mov    %edx,%edi
80103d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d85:	fc                   	cld    
80103d86:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103d88:	89 d0                	mov    %edx,%eax
80103d8a:	5b                   	pop    %ebx
80103d8b:	5f                   	pop    %edi
80103d8c:	5d                   	pop    %ebp
80103d8d:	c3                   	ret    
    c &= 0xFF;
80103d8e:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103d92:	c1 e9 02             	shr    $0x2,%ecx
80103d95:	89 f8                	mov    %edi,%eax
80103d97:	c1 e0 18             	shl    $0x18,%eax
80103d9a:	89 fb                	mov    %edi,%ebx
80103d9c:	c1 e3 10             	shl    $0x10,%ebx
80103d9f:	09 d8                	or     %ebx,%eax
80103da1:	89 fb                	mov    %edi,%ebx
80103da3:	c1 e3 08             	shl    $0x8,%ebx
80103da6:	09 d8                	or     %ebx,%eax
80103da8:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103daa:	89 d7                	mov    %edx,%edi
80103dac:	fc                   	cld    
80103dad:	f3 ab                	rep stos %eax,%es:(%edi)
80103daf:	eb d7                	jmp    80103d88 <memset+0x1d>

80103db1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	56                   	push   %esi
80103db5:	53                   	push   %ebx
80103db6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103db9:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dbc:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103dbf:	8d 70 ff             	lea    -0x1(%eax),%esi
80103dc2:	85 c0                	test   %eax,%eax
80103dc4:	74 1c                	je     80103de2 <memcmp+0x31>
    if(*s1 != *s2)
80103dc6:	0f b6 01             	movzbl (%ecx),%eax
80103dc9:	0f b6 1a             	movzbl (%edx),%ebx
80103dcc:	38 d8                	cmp    %bl,%al
80103dce:	75 0a                	jne    80103dda <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103dd0:	83 c1 01             	add    $0x1,%ecx
80103dd3:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103dd6:	89 f0                	mov    %esi,%eax
80103dd8:	eb e5                	jmp    80103dbf <memcmp+0xe>
      return *s1 - *s2;
80103dda:	0f b6 c0             	movzbl %al,%eax
80103ddd:	0f b6 db             	movzbl %bl,%ebx
80103de0:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103de2:	5b                   	pop    %ebx
80103de3:	5e                   	pop    %esi
80103de4:	5d                   	pop    %ebp
80103de5:	c3                   	ret    

80103de6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103de6:	55                   	push   %ebp
80103de7:	89 e5                	mov    %esp,%ebp
80103de9:	56                   	push   %esi
80103dea:	53                   	push   %ebx
80103deb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103df1:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103df4:	39 c1                	cmp    %eax,%ecx
80103df6:	73 3a                	jae    80103e32 <memmove+0x4c>
80103df8:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103dfb:	39 c3                	cmp    %eax,%ebx
80103dfd:	76 37                	jbe    80103e36 <memmove+0x50>
    s += n;
    d += n;
80103dff:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e02:	eb 0d                	jmp    80103e11 <memmove+0x2b>
      *--d = *--s;
80103e04:	83 eb 01             	sub    $0x1,%ebx
80103e07:	83 e9 01             	sub    $0x1,%ecx
80103e0a:	0f b6 13             	movzbl (%ebx),%edx
80103e0d:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e0f:	89 f2                	mov    %esi,%edx
80103e11:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e14:	85 d2                	test   %edx,%edx
80103e16:	75 ec                	jne    80103e04 <memmove+0x1e>
80103e18:	eb 14                	jmp    80103e2e <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103e1a:	0f b6 11             	movzbl (%ecx),%edx
80103e1d:	88 13                	mov    %dl,(%ebx)
80103e1f:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103e22:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103e25:	89 f2                	mov    %esi,%edx
80103e27:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e2a:	85 d2                	test   %edx,%edx
80103e2c:	75 ec                	jne    80103e1a <memmove+0x34>

  return dst;
}
80103e2e:	5b                   	pop    %ebx
80103e2f:	5e                   	pop    %esi
80103e30:	5d                   	pop    %ebp
80103e31:	c3                   	ret    
80103e32:	89 c3                	mov    %eax,%ebx
80103e34:	eb f1                	jmp    80103e27 <memmove+0x41>
80103e36:	89 c3                	mov    %eax,%ebx
80103e38:	eb ed                	jmp    80103e27 <memmove+0x41>

80103e3a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103e3a:	55                   	push   %ebp
80103e3b:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103e3d:	ff 75 10             	pushl  0x10(%ebp)
80103e40:	ff 75 0c             	pushl  0xc(%ebp)
80103e43:	ff 75 08             	pushl  0x8(%ebp)
80103e46:	e8 9b ff ff ff       	call   80103de6 <memmove>
}
80103e4b:	c9                   	leave  
80103e4c:	c3                   	ret    

80103e4d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103e4d:	55                   	push   %ebp
80103e4e:	89 e5                	mov    %esp,%ebp
80103e50:	53                   	push   %ebx
80103e51:	8b 55 08             	mov    0x8(%ebp),%edx
80103e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e57:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103e5a:	eb 09                	jmp    80103e65 <strncmp+0x18>
    n--, p++, q++;
80103e5c:	83 e8 01             	sub    $0x1,%eax
80103e5f:	83 c2 01             	add    $0x1,%edx
80103e62:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103e65:	85 c0                	test   %eax,%eax
80103e67:	74 0b                	je     80103e74 <strncmp+0x27>
80103e69:	0f b6 1a             	movzbl (%edx),%ebx
80103e6c:	84 db                	test   %bl,%bl
80103e6e:	74 04                	je     80103e74 <strncmp+0x27>
80103e70:	3a 19                	cmp    (%ecx),%bl
80103e72:	74 e8                	je     80103e5c <strncmp+0xf>
  if(n == 0)
80103e74:	85 c0                	test   %eax,%eax
80103e76:	74 0b                	je     80103e83 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103e78:	0f b6 02             	movzbl (%edx),%eax
80103e7b:	0f b6 11             	movzbl (%ecx),%edx
80103e7e:	29 d0                	sub    %edx,%eax
}
80103e80:	5b                   	pop    %ebx
80103e81:	5d                   	pop    %ebp
80103e82:	c3                   	ret    
    return 0;
80103e83:	b8 00 00 00 00       	mov    $0x0,%eax
80103e88:	eb f6                	jmp    80103e80 <strncmp+0x33>

80103e8a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103e8a:	55                   	push   %ebp
80103e8b:	89 e5                	mov    %esp,%ebp
80103e8d:	57                   	push   %edi
80103e8e:	56                   	push   %esi
80103e8f:	53                   	push   %ebx
80103e90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e93:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103e96:	8b 45 08             	mov    0x8(%ebp),%eax
80103e99:	eb 04                	jmp    80103e9f <strncpy+0x15>
80103e9b:	89 fb                	mov    %edi,%ebx
80103e9d:	89 f0                	mov    %esi,%eax
80103e9f:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ea2:	85 c9                	test   %ecx,%ecx
80103ea4:	7e 1d                	jle    80103ec3 <strncpy+0x39>
80103ea6:	8d 7b 01             	lea    0x1(%ebx),%edi
80103ea9:	8d 70 01             	lea    0x1(%eax),%esi
80103eac:	0f b6 1b             	movzbl (%ebx),%ebx
80103eaf:	88 18                	mov    %bl,(%eax)
80103eb1:	89 d1                	mov    %edx,%ecx
80103eb3:	84 db                	test   %bl,%bl
80103eb5:	75 e4                	jne    80103e9b <strncpy+0x11>
80103eb7:	89 f0                	mov    %esi,%eax
80103eb9:	eb 08                	jmp    80103ec3 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103ebb:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103ebe:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103ec0:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103ec3:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103ec6:	85 d2                	test   %edx,%edx
80103ec8:	7f f1                	jg     80103ebb <strncpy+0x31>
  return os;
}
80103eca:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecd:	5b                   	pop    %ebx
80103ece:	5e                   	pop    %esi
80103ecf:	5f                   	pop    %edi
80103ed0:	5d                   	pop    %ebp
80103ed1:	c3                   	ret    

80103ed2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103ed2:	55                   	push   %ebp
80103ed3:	89 e5                	mov    %esp,%ebp
80103ed5:	57                   	push   %edi
80103ed6:	56                   	push   %esi
80103ed7:	53                   	push   %ebx
80103ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80103edb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103ede:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103ee1:	85 d2                	test   %edx,%edx
80103ee3:	7e 23                	jle    80103f08 <safestrcpy+0x36>
80103ee5:	89 c1                	mov    %eax,%ecx
80103ee7:	eb 04                	jmp    80103eed <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103ee9:	89 fb                	mov    %edi,%ebx
80103eeb:	89 f1                	mov    %esi,%ecx
80103eed:	83 ea 01             	sub    $0x1,%edx
80103ef0:	85 d2                	test   %edx,%edx
80103ef2:	7e 11                	jle    80103f05 <safestrcpy+0x33>
80103ef4:	8d 7b 01             	lea    0x1(%ebx),%edi
80103ef7:	8d 71 01             	lea    0x1(%ecx),%esi
80103efa:	0f b6 1b             	movzbl (%ebx),%ebx
80103efd:	88 19                	mov    %bl,(%ecx)
80103eff:	84 db                	test   %bl,%bl
80103f01:	75 e6                	jne    80103ee9 <safestrcpy+0x17>
80103f03:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f05:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f08:	5b                   	pop    %ebx
80103f09:	5e                   	pop    %esi
80103f0a:	5f                   	pop    %edi
80103f0b:	5d                   	pop    %ebp
80103f0c:	c3                   	ret    

80103f0d <strlen>:

int
strlen(const char *s)
{
80103f0d:	55                   	push   %ebp
80103f0e:	89 e5                	mov    %esp,%ebp
80103f10:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103f13:	b8 00 00 00 00       	mov    $0x0,%eax
80103f18:	eb 03                	jmp    80103f1d <strlen+0x10>
80103f1a:	83 c0 01             	add    $0x1,%eax
80103f1d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103f21:	75 f7                	jne    80103f1a <strlen+0xd>
    ;
  return n;
}
80103f23:	5d                   	pop    %ebp
80103f24:	c3                   	ret    

80103f25 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103f25:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103f29:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103f2d:	55                   	push   %ebp
  pushl %ebx
80103f2e:	53                   	push   %ebx
  pushl %esi
80103f2f:	56                   	push   %esi
  pushl %edi
80103f30:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103f31:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103f33:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103f35:	5f                   	pop    %edi
  popl %esi
80103f36:	5e                   	pop    %esi
  popl %ebx
80103f37:	5b                   	pop    %ebx
  popl %ebp
80103f38:	5d                   	pop    %ebp
  ret
80103f39:	c3                   	ret    

80103f3a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103f3a:	55                   	push   %ebp
80103f3b:	89 e5                	mov    %esp,%ebp
80103f3d:	53                   	push   %ebx
80103f3e:	83 ec 04             	sub    $0x4,%esp
80103f41:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103f44:	e8 d7 f3 ff ff       	call   80103320 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103f49:	8b 00                	mov    (%eax),%eax
80103f4b:	39 d8                	cmp    %ebx,%eax
80103f4d:	76 19                	jbe    80103f68 <fetchint+0x2e>
80103f4f:	8d 53 04             	lea    0x4(%ebx),%edx
80103f52:	39 d0                	cmp    %edx,%eax
80103f54:	72 19                	jb     80103f6f <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103f56:	8b 13                	mov    (%ebx),%edx
80103f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f5b:	89 10                	mov    %edx,(%eax)
  return 0;
80103f5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f62:	83 c4 04             	add    $0x4,%esp
80103f65:	5b                   	pop    %ebx
80103f66:	5d                   	pop    %ebp
80103f67:	c3                   	ret    
    return -1;
80103f68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f6d:	eb f3                	jmp    80103f62 <fetchint+0x28>
80103f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f74:	eb ec                	jmp    80103f62 <fetchint+0x28>

80103f76 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103f76:	55                   	push   %ebp
80103f77:	89 e5                	mov    %esp,%ebp
80103f79:	53                   	push   %ebx
80103f7a:	83 ec 04             	sub    $0x4,%esp
80103f7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f80:	e8 9b f3 ff ff       	call   80103320 <myproc>

  if(addr >= curproc->sz)
80103f85:	39 18                	cmp    %ebx,(%eax)
80103f87:	76 26                	jbe    80103faf <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103f89:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f8c:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f8e:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103f90:	89 d8                	mov    %ebx,%eax
80103f92:	39 d0                	cmp    %edx,%eax
80103f94:	73 0e                	jae    80103fa4 <fetchstr+0x2e>
    if(*s == 0)
80103f96:	80 38 00             	cmpb   $0x0,(%eax)
80103f99:	74 05                	je     80103fa0 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103f9b:	83 c0 01             	add    $0x1,%eax
80103f9e:	eb f2                	jmp    80103f92 <fetchstr+0x1c>
      return s - *pp;
80103fa0:	29 d8                	sub    %ebx,%eax
80103fa2:	eb 05                	jmp    80103fa9 <fetchstr+0x33>
  }
  return -1;
80103fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fa9:	83 c4 04             	add    $0x4,%esp
80103fac:	5b                   	pop    %ebx
80103fad:	5d                   	pop    %ebp
80103fae:	c3                   	ret    
    return -1;
80103faf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fb4:	eb f3                	jmp    80103fa9 <fetchstr+0x33>

80103fb6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103fb6:	55                   	push   %ebp
80103fb7:	89 e5                	mov    %esp,%ebp
80103fb9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103fbc:	e8 5f f3 ff ff       	call   80103320 <myproc>
80103fc1:	8b 50 18             	mov    0x18(%eax),%edx
80103fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc7:	c1 e0 02             	shl    $0x2,%eax
80103fca:	03 42 44             	add    0x44(%edx),%eax
80103fcd:	83 ec 08             	sub    $0x8,%esp
80103fd0:	ff 75 0c             	pushl  0xc(%ebp)
80103fd3:	83 c0 04             	add    $0x4,%eax
80103fd6:	50                   	push   %eax
80103fd7:	e8 5e ff ff ff       	call   80103f3a <fetchint>
}
80103fdc:	c9                   	leave  
80103fdd:	c3                   	ret    

80103fde <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103fde:	55                   	push   %ebp
80103fdf:	89 e5                	mov    %esp,%ebp
80103fe1:	56                   	push   %esi
80103fe2:	53                   	push   %ebx
80103fe3:	83 ec 10             	sub    $0x10,%esp
80103fe6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103fe9:	e8 32 f3 ff ff       	call   80103320 <myproc>
80103fee:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103ff0:	83 ec 08             	sub    $0x8,%esp
80103ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103ff6:	50                   	push   %eax
80103ff7:	ff 75 08             	pushl  0x8(%ebp)
80103ffa:	e8 b7 ff ff ff       	call   80103fb6 <argint>
80103fff:	83 c4 10             	add    $0x10,%esp
80104002:	85 c0                	test   %eax,%eax
80104004:	78 24                	js     8010402a <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104006:	85 db                	test   %ebx,%ebx
80104008:	78 27                	js     80104031 <argptr+0x53>
8010400a:	8b 16                	mov    (%esi),%edx
8010400c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400f:	39 c2                	cmp    %eax,%edx
80104011:	76 25                	jbe    80104038 <argptr+0x5a>
80104013:	01 c3                	add    %eax,%ebx
80104015:	39 da                	cmp    %ebx,%edx
80104017:	72 26                	jb     8010403f <argptr+0x61>
    return -1;
  *pp = (char*)i;
80104019:	8b 55 0c             	mov    0xc(%ebp),%edx
8010401c:	89 02                	mov    %eax,(%edx)
  return 0;
8010401e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104023:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104026:	5b                   	pop    %ebx
80104027:	5e                   	pop    %esi
80104028:	5d                   	pop    %ebp
80104029:	c3                   	ret    
    return -1;
8010402a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010402f:	eb f2                	jmp    80104023 <argptr+0x45>
    return -1;
80104031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104036:	eb eb                	jmp    80104023 <argptr+0x45>
80104038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010403d:	eb e4                	jmp    80104023 <argptr+0x45>
8010403f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104044:	eb dd                	jmp    80104023 <argptr+0x45>

80104046 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104046:	55                   	push   %ebp
80104047:	89 e5                	mov    %esp,%ebp
80104049:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010404c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010404f:	50                   	push   %eax
80104050:	ff 75 08             	pushl  0x8(%ebp)
80104053:	e8 5e ff ff ff       	call   80103fb6 <argint>
80104058:	83 c4 10             	add    $0x10,%esp
8010405b:	85 c0                	test   %eax,%eax
8010405d:	78 13                	js     80104072 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
8010405f:	83 ec 08             	sub    $0x8,%esp
80104062:	ff 75 0c             	pushl  0xc(%ebp)
80104065:	ff 75 f4             	pushl  -0xc(%ebp)
80104068:	e8 09 ff ff ff       	call   80103f76 <fetchstr>
8010406d:	83 c4 10             	add    $0x10,%esp
}
80104070:	c9                   	leave  
80104071:	c3                   	ret    
    return -1;
80104072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104077:	eb f7                	jmp    80104070 <argstr+0x2a>

80104079 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80104079:	55                   	push   %ebp
8010407a:	89 e5                	mov    %esp,%ebp
8010407c:	53                   	push   %ebx
8010407d:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104080:	e8 9b f2 ff ff       	call   80103320 <myproc>
80104085:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104087:	8b 40 18             	mov    0x18(%eax),%eax
8010408a:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010408d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104090:	83 fa 15             	cmp    $0x15,%edx
80104093:	77 18                	ja     801040ad <syscall+0x34>
80104095:	8b 14 85 e0 6c 10 80 	mov    -0x7fef9320(,%eax,4),%edx
8010409c:	85 d2                	test   %edx,%edx
8010409e:	74 0d                	je     801040ad <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
801040a0:	ff d2                	call   *%edx
801040a2:	8b 53 18             	mov    0x18(%ebx),%edx
801040a5:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
801040a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040ab:	c9                   	leave  
801040ac:	c3                   	ret    
            curproc->pid, curproc->name, num);
801040ad:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
801040b0:	50                   	push   %eax
801040b1:	52                   	push   %edx
801040b2:	ff 73 10             	pushl  0x10(%ebx)
801040b5:	68 b1 6c 10 80       	push   $0x80106cb1
801040ba:	e8 4c c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
801040bf:	8b 43 18             	mov    0x18(%ebx),%eax
801040c2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
801040c9:	83 c4 10             	add    $0x10,%esp
}
801040cc:	eb da                	jmp    801040a8 <syscall+0x2f>

801040ce <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801040ce:	55                   	push   %ebp
801040cf:	89 e5                	mov    %esp,%ebp
801040d1:	56                   	push   %esi
801040d2:	53                   	push   %ebx
801040d3:	83 ec 18             	sub    $0x18,%esp
801040d6:	89 d6                	mov    %edx,%esi
801040d8:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801040da:	8d 55 f4             	lea    -0xc(%ebp),%edx
801040dd:	52                   	push   %edx
801040de:	50                   	push   %eax
801040df:	e8 d2 fe ff ff       	call   80103fb6 <argint>
801040e4:	83 c4 10             	add    $0x10,%esp
801040e7:	85 c0                	test   %eax,%eax
801040e9:	78 2e                	js     80104119 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801040eb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040ef:	77 2f                	ja     80104120 <argfd+0x52>
801040f1:	e8 2a f2 ff ff       	call   80103320 <myproc>
801040f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040f9:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801040fd:	85 c0                	test   %eax,%eax
801040ff:	74 26                	je     80104127 <argfd+0x59>
    return -1;
  if(pfd)
80104101:	85 f6                	test   %esi,%esi
80104103:	74 02                	je     80104107 <argfd+0x39>
    *pfd = fd;
80104105:	89 16                	mov    %edx,(%esi)
  if(pf)
80104107:	85 db                	test   %ebx,%ebx
80104109:	74 23                	je     8010412e <argfd+0x60>
    *pf = f;
8010410b:	89 03                	mov    %eax,(%ebx)
  return 0;
8010410d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104112:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104115:	5b                   	pop    %ebx
80104116:	5e                   	pop    %esi
80104117:	5d                   	pop    %ebp
80104118:	c3                   	ret    
    return -1;
80104119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010411e:	eb f2                	jmp    80104112 <argfd+0x44>
    return -1;
80104120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104125:	eb eb                	jmp    80104112 <argfd+0x44>
80104127:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010412c:	eb e4                	jmp    80104112 <argfd+0x44>
  return 0;
8010412e:	b8 00 00 00 00       	mov    $0x0,%eax
80104133:	eb dd                	jmp    80104112 <argfd+0x44>

80104135 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104135:	55                   	push   %ebp
80104136:	89 e5                	mov    %esp,%ebp
80104138:	53                   	push   %ebx
80104139:	83 ec 04             	sub    $0x4,%esp
8010413c:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
8010413e:	e8 dd f1 ff ff       	call   80103320 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104143:	ba 00 00 00 00       	mov    $0x0,%edx
80104148:	83 fa 0f             	cmp    $0xf,%edx
8010414b:	7f 18                	jg     80104165 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
8010414d:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104152:	74 05                	je     80104159 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104154:	83 c2 01             	add    $0x1,%edx
80104157:	eb ef                	jmp    80104148 <fdalloc+0x13>
      curproc->ofile[fd] = f;
80104159:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
8010415d:	89 d0                	mov    %edx,%eax
8010415f:	83 c4 04             	add    $0x4,%esp
80104162:	5b                   	pop    %ebx
80104163:	5d                   	pop    %ebp
80104164:	c3                   	ret    
  return -1;
80104165:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010416a:	eb f1                	jmp    8010415d <fdalloc+0x28>

8010416c <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010416c:	55                   	push   %ebp
8010416d:	89 e5                	mov    %esp,%ebp
8010416f:	56                   	push   %esi
80104170:	53                   	push   %ebx
80104171:	83 ec 10             	sub    $0x10,%esp
80104174:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104176:	b8 20 00 00 00       	mov    $0x20,%eax
8010417b:	89 c6                	mov    %eax,%esi
8010417d:	39 43 58             	cmp    %eax,0x58(%ebx)
80104180:	76 2e                	jbe    801041b0 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104182:	6a 10                	push   $0x10
80104184:	50                   	push   %eax
80104185:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104188:	50                   	push   %eax
80104189:	53                   	push   %ebx
8010418a:	e8 e4 d5 ff ff       	call   80101773 <readi>
8010418f:	83 c4 10             	add    $0x10,%esp
80104192:	83 f8 10             	cmp    $0x10,%eax
80104195:	75 0c                	jne    801041a3 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104197:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010419c:	75 1e                	jne    801041bc <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010419e:	8d 46 10             	lea    0x10(%esi),%eax
801041a1:	eb d8                	jmp    8010417b <isdirempty+0xf>
      panic("isdirempty: readi");
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	68 3c 6d 10 80       	push   $0x80106d3c
801041ab:	e8 98 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801041b0:	b8 01 00 00 00       	mov    $0x1,%eax
}
801041b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041b8:	5b                   	pop    %ebx
801041b9:	5e                   	pop    %esi
801041ba:	5d                   	pop    %ebp
801041bb:	c3                   	ret    
      return 0;
801041bc:	b8 00 00 00 00       	mov    $0x0,%eax
801041c1:	eb f2                	jmp    801041b5 <isdirempty+0x49>

801041c3 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801041c3:	55                   	push   %ebp
801041c4:	89 e5                	mov    %esp,%ebp
801041c6:	57                   	push   %edi
801041c7:	56                   	push   %esi
801041c8:	53                   	push   %ebx
801041c9:	83 ec 44             	sub    $0x44,%esp
801041cc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
801041cf:	89 4d c0             	mov    %ecx,-0x40(%ebp)
801041d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];
  if((dp = nameiparent(path, name)) == 0)
801041d5:	8d 55 d6             	lea    -0x2a(%ebp),%edx
801041d8:	52                   	push   %edx
801041d9:	50                   	push   %eax
801041da:	e8 3e db ff ff       	call   80101d1d <nameiparent>
801041df:	89 c6                	mov    %eax,%esi
801041e1:	83 c4 10             	add    $0x10,%esp
801041e4:	85 c0                	test   %eax,%eax
801041e6:	0f 84 2c 01 00 00    	je     80104318 <create+0x155>
    return 0;
  ilock(dp);
801041ec:	83 ec 0c             	sub    $0xc,%esp
801041ef:	50                   	push   %eax
801041f0:	e8 8c d3 ff ff       	call   80101581 <ilock>
  if((ip = dirlookup(dp, name, &off)) != 0){
801041f5:	83 c4 0c             	add    $0xc,%esp
801041f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801041fb:	50                   	push   %eax
801041fc:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801041ff:	50                   	push   %eax
80104200:	56                   	push   %esi
80104201:	e8 aa d7 ff ff       	call   801019b0 <dirlookup>
80104206:	89 c3                	mov    %eax,%ebx
80104208:	83 c4 10             	add    $0x10,%esp
8010420b:	85 c0                	test   %eax,%eax
8010420d:	74 34                	je     80104243 <create+0x80>
    iunlockput(dp);
8010420f:	83 ec 0c             	sub    $0xc,%esp
80104212:	56                   	push   %esi
80104213:	e8 10 d5 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
80104218:	89 1c 24             	mov    %ebx,(%esp)
8010421b:	e8 61 d3 ff ff       	call   80101581 <ilock>
    if((type == T_FILE || T_SYM) && (ip->type == T_FILE || T_SYM)) {
	cprintf("Inside for %s and type is %d \n", name, ip->type);
80104220:	83 c4 0c             	add    $0xc,%esp
80104223:	0f bf 43 50          	movswl 0x50(%ebx),%eax
80104227:	50                   	push   %eax
80104228:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010422b:	50                   	push   %eax
8010422c:	68 a0 6d 10 80       	push   $0x80106da0
80104231:	e8 d5 c3 ff ff       	call   8010060b <cprintf>
     	return ip;
80104236:	83 c4 10             	add    $0x10,%esp
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);
  return ip;
}
80104239:	89 d8                	mov    %ebx,%eax
8010423b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010423e:	5b                   	pop    %ebx
8010423f:	5e                   	pop    %esi
80104240:	5f                   	pop    %edi
80104241:	5d                   	pop    %ebp
80104242:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104243:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104247:	83 ec 08             	sub    $0x8,%esp
8010424a:	50                   	push   %eax
8010424b:	ff 36                	pushl  (%esi)
8010424d:	e8 2c d1 ff ff       	call   8010137e <ialloc>
80104252:	89 c3                	mov    %eax,%ebx
80104254:	83 c4 10             	add    $0x10,%esp
80104257:	85 c0                	test   %eax,%eax
80104259:	74 52                	je     801042ad <create+0xea>
  ilock(ip);
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	50                   	push   %eax
8010425f:	e8 1d d3 ff ff       	call   80101581 <ilock>
  ip->major = major;
80104264:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104268:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010426c:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104270:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104276:	89 1c 24             	mov    %ebx,(%esp)
80104279:	e8 a2 d1 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010427e:	83 c4 10             	add    $0x10,%esp
80104281:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104286:	74 32                	je     801042ba <create+0xf7>
  if(dirlink(dp, name, ip->inum) < 0)
80104288:	83 ec 04             	sub    $0x4,%esp
8010428b:	ff 73 04             	pushl  0x4(%ebx)
8010428e:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104291:	50                   	push   %eax
80104292:	56                   	push   %esi
80104293:	e8 b6 d9 ff ff       	call   80101c4e <dirlink>
80104298:	83 c4 10             	add    $0x10,%esp
8010429b:	85 c0                	test   %eax,%eax
8010429d:	78 6c                	js     8010430b <create+0x148>
  iunlockput(dp);
8010429f:	83 ec 0c             	sub    $0xc,%esp
801042a2:	56                   	push   %esi
801042a3:	e8 80 d4 ff ff       	call   80101728 <iunlockput>
  return ip;
801042a8:	83 c4 10             	add    $0x10,%esp
801042ab:	eb 8c                	jmp    80104239 <create+0x76>
    panic("create: ialloc");
801042ad:	83 ec 0c             	sub    $0xc,%esp
801042b0:	68 4e 6d 10 80       	push   $0x80106d4e
801042b5:	e8 8e c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
801042ba:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801042be:	83 c0 01             	add    $0x1,%eax
801042c1:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801042c5:	83 ec 0c             	sub    $0xc,%esp
801042c8:	56                   	push   %esi
801042c9:	e8 52 d1 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801042ce:	83 c4 0c             	add    $0xc,%esp
801042d1:	ff 73 04             	pushl  0x4(%ebx)
801042d4:	68 5e 6d 10 80       	push   $0x80106d5e
801042d9:	53                   	push   %ebx
801042da:	e8 6f d9 ff ff       	call   80101c4e <dirlink>
801042df:	83 c4 10             	add    $0x10,%esp
801042e2:	85 c0                	test   %eax,%eax
801042e4:	78 18                	js     801042fe <create+0x13b>
801042e6:	83 ec 04             	sub    $0x4,%esp
801042e9:	ff 76 04             	pushl  0x4(%esi)
801042ec:	68 5d 6d 10 80       	push   $0x80106d5d
801042f1:	53                   	push   %ebx
801042f2:	e8 57 d9 ff ff       	call   80101c4e <dirlink>
801042f7:	83 c4 10             	add    $0x10,%esp
801042fa:	85 c0                	test   %eax,%eax
801042fc:	79 8a                	jns    80104288 <create+0xc5>
      panic("create dots");
801042fe:	83 ec 0c             	sub    $0xc,%esp
80104301:	68 60 6d 10 80       	push   $0x80106d60
80104306:	e8 3d c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010430b:	83 ec 0c             	sub    $0xc,%esp
8010430e:	68 6c 6d 10 80       	push   $0x80106d6c
80104313:	e8 30 c0 ff ff       	call   80100348 <panic>
    return 0;
80104318:	89 c3                	mov    %eax,%ebx
8010431a:	e9 1a ff ff ff       	jmp    80104239 <create+0x76>

8010431f <sys_dup>:
{
8010431f:	55                   	push   %ebp
80104320:	89 e5                	mov    %esp,%ebp
80104322:	53                   	push   %ebx
80104323:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104326:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104329:	ba 00 00 00 00       	mov    $0x0,%edx
8010432e:	b8 00 00 00 00       	mov    $0x0,%eax
80104333:	e8 96 fd ff ff       	call   801040ce <argfd>
80104338:	85 c0                	test   %eax,%eax
8010433a:	78 23                	js     8010435f <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
8010433c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433f:	e8 f1 fd ff ff       	call   80104135 <fdalloc>
80104344:	89 c3                	mov    %eax,%ebx
80104346:	85 c0                	test   %eax,%eax
80104348:	78 1c                	js     80104366 <sys_dup+0x47>
  filedup(f);
8010434a:	83 ec 0c             	sub    $0xc,%esp
8010434d:	ff 75 f4             	pushl  -0xc(%ebp)
80104350:	e8 39 c9 ff ff       	call   80100c8e <filedup>
  return fd;
80104355:	83 c4 10             	add    $0x10,%esp
}
80104358:	89 d8                	mov    %ebx,%eax
8010435a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010435d:	c9                   	leave  
8010435e:	c3                   	ret    
    return -1;
8010435f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104364:	eb f2                	jmp    80104358 <sys_dup+0x39>
    return -1;
80104366:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010436b:	eb eb                	jmp    80104358 <sys_dup+0x39>

8010436d <sys_read>:
{
8010436d:	55                   	push   %ebp
8010436e:	89 e5                	mov    %esp,%ebp
80104370:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104373:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104376:	ba 00 00 00 00       	mov    $0x0,%edx
8010437b:	b8 00 00 00 00       	mov    $0x0,%eax
80104380:	e8 49 fd ff ff       	call   801040ce <argfd>
80104385:	85 c0                	test   %eax,%eax
80104387:	78 43                	js     801043cc <sys_read+0x5f>
80104389:	83 ec 08             	sub    $0x8,%esp
8010438c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010438f:	50                   	push   %eax
80104390:	6a 02                	push   $0x2
80104392:	e8 1f fc ff ff       	call   80103fb6 <argint>
80104397:	83 c4 10             	add    $0x10,%esp
8010439a:	85 c0                	test   %eax,%eax
8010439c:	78 35                	js     801043d3 <sys_read+0x66>
8010439e:	83 ec 04             	sub    $0x4,%esp
801043a1:	ff 75 f0             	pushl  -0x10(%ebp)
801043a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043a7:	50                   	push   %eax
801043a8:	6a 01                	push   $0x1
801043aa:	e8 2f fc ff ff       	call   80103fde <argptr>
801043af:	83 c4 10             	add    $0x10,%esp
801043b2:	85 c0                	test   %eax,%eax
801043b4:	78 24                	js     801043da <sys_read+0x6d>
  return fileread(f, p, n);
801043b6:	83 ec 04             	sub    $0x4,%esp
801043b9:	ff 75 f0             	pushl  -0x10(%ebp)
801043bc:	ff 75 ec             	pushl  -0x14(%ebp)
801043bf:	ff 75 f4             	pushl  -0xc(%ebp)
801043c2:	e8 10 ca ff ff       	call   80100dd7 <fileread>
801043c7:	83 c4 10             	add    $0x10,%esp
}
801043ca:	c9                   	leave  
801043cb:	c3                   	ret    
    return -1;
801043cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d1:	eb f7                	jmp    801043ca <sys_read+0x5d>
801043d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d8:	eb f0                	jmp    801043ca <sys_read+0x5d>
801043da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043df:	eb e9                	jmp    801043ca <sys_read+0x5d>

801043e1 <sys_write>:
{
801043e1:	55                   	push   %ebp
801043e2:	89 e5                	mov    %esp,%ebp
801043e4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043e7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043ea:	ba 00 00 00 00       	mov    $0x0,%edx
801043ef:	b8 00 00 00 00       	mov    $0x0,%eax
801043f4:	e8 d5 fc ff ff       	call   801040ce <argfd>
801043f9:	85 c0                	test   %eax,%eax
801043fb:	78 43                	js     80104440 <sys_write+0x5f>
801043fd:	83 ec 08             	sub    $0x8,%esp
80104400:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104403:	50                   	push   %eax
80104404:	6a 02                	push   $0x2
80104406:	e8 ab fb ff ff       	call   80103fb6 <argint>
8010440b:	83 c4 10             	add    $0x10,%esp
8010440e:	85 c0                	test   %eax,%eax
80104410:	78 35                	js     80104447 <sys_write+0x66>
80104412:	83 ec 04             	sub    $0x4,%esp
80104415:	ff 75 f0             	pushl  -0x10(%ebp)
80104418:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010441b:	50                   	push   %eax
8010441c:	6a 01                	push   $0x1
8010441e:	e8 bb fb ff ff       	call   80103fde <argptr>
80104423:	83 c4 10             	add    $0x10,%esp
80104426:	85 c0                	test   %eax,%eax
80104428:	78 24                	js     8010444e <sys_write+0x6d>
  return filewrite(f, p, n);
8010442a:	83 ec 04             	sub    $0x4,%esp
8010442d:	ff 75 f0             	pushl  -0x10(%ebp)
80104430:	ff 75 ec             	pushl  -0x14(%ebp)
80104433:	ff 75 f4             	pushl  -0xc(%ebp)
80104436:	e8 21 ca ff ff       	call   80100e5c <filewrite>
8010443b:	83 c4 10             	add    $0x10,%esp
}
8010443e:	c9                   	leave  
8010443f:	c3                   	ret    
    return -1;
80104440:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104445:	eb f7                	jmp    8010443e <sys_write+0x5d>
80104447:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010444c:	eb f0                	jmp    8010443e <sys_write+0x5d>
8010444e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104453:	eb e9                	jmp    8010443e <sys_write+0x5d>

80104455 <sys_close>:
{
80104455:	55                   	push   %ebp
80104456:	89 e5                	mov    %esp,%ebp
80104458:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
8010445b:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010445e:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104461:	b8 00 00 00 00       	mov    $0x0,%eax
80104466:	e8 63 fc ff ff       	call   801040ce <argfd>
8010446b:	85 c0                	test   %eax,%eax
8010446d:	78 25                	js     80104494 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010446f:	e8 ac ee ff ff       	call   80103320 <myproc>
80104474:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104477:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010447e:	00 
  fileclose(f);
8010447f:	83 ec 0c             	sub    $0xc,%esp
80104482:	ff 75 f0             	pushl  -0x10(%ebp)
80104485:	e8 49 c8 ff ff       	call   80100cd3 <fileclose>
  return 0;
8010448a:	83 c4 10             	add    $0x10,%esp
8010448d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104492:	c9                   	leave  
80104493:	c3                   	ret    
    return -1;
80104494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104499:	eb f7                	jmp    80104492 <sys_close+0x3d>

8010449b <sys_fstat>:
{
8010449b:	55                   	push   %ebp
8010449c:	89 e5                	mov    %esp,%ebp
8010449e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801044a1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044a4:	ba 00 00 00 00       	mov    $0x0,%edx
801044a9:	b8 00 00 00 00       	mov    $0x0,%eax
801044ae:	e8 1b fc ff ff       	call   801040ce <argfd>
801044b3:	85 c0                	test   %eax,%eax
801044b5:	78 2a                	js     801044e1 <sys_fstat+0x46>
801044b7:	83 ec 04             	sub    $0x4,%esp
801044ba:	6a 14                	push   $0x14
801044bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044bf:	50                   	push   %eax
801044c0:	6a 01                	push   $0x1
801044c2:	e8 17 fb ff ff       	call   80103fde <argptr>
801044c7:	83 c4 10             	add    $0x10,%esp
801044ca:	85 c0                	test   %eax,%eax
801044cc:	78 1a                	js     801044e8 <sys_fstat+0x4d>
  return filestat(f, st);
801044ce:	83 ec 08             	sub    $0x8,%esp
801044d1:	ff 75 f0             	pushl  -0x10(%ebp)
801044d4:	ff 75 f4             	pushl  -0xc(%ebp)
801044d7:	e8 b4 c8 ff ff       	call   80100d90 <filestat>
801044dc:	83 c4 10             	add    $0x10,%esp
}
801044df:	c9                   	leave  
801044e0:	c3                   	ret    
    return -1;
801044e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e6:	eb f7                	jmp    801044df <sys_fstat+0x44>
801044e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ed:	eb f0                	jmp    801044df <sys_fstat+0x44>

801044ef <sys_link>:
{
801044ef:	55                   	push   %ebp
801044f0:	89 e5                	mov    %esp,%ebp
801044f2:	56                   	push   %esi
801044f3:	53                   	push   %ebx
801044f4:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801044f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044fa:	50                   	push   %eax
801044fb:	6a 00                	push   $0x0
801044fd:	e8 44 fb ff ff       	call   80104046 <argstr>
80104502:	83 c4 10             	add    $0x10,%esp
80104505:	85 c0                	test   %eax,%eax
80104507:	0f 88 32 01 00 00    	js     8010463f <sys_link+0x150>
8010450d:	83 ec 08             	sub    $0x8,%esp
80104510:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104513:	50                   	push   %eax
80104514:	6a 01                	push   $0x1
80104516:	e8 2b fb ff ff       	call   80104046 <argstr>
8010451b:	83 c4 10             	add    $0x10,%esp
8010451e:	85 c0                	test   %eax,%eax
80104520:	0f 88 20 01 00 00    	js     80104646 <sys_link+0x157>
  begin_op();
80104526:	e8 ad e3 ff ff       	call   801028d8 <begin_op>
  if((ip = namei(old)) == 0){
8010452b:	83 ec 0c             	sub    $0xc,%esp
8010452e:	ff 75 e0             	pushl  -0x20(%ebp)
80104531:	e8 c9 d7 ff ff       	call   80101cff <namei>
80104536:	89 c3                	mov    %eax,%ebx
80104538:	83 c4 10             	add    $0x10,%esp
8010453b:	85 c0                	test   %eax,%eax
8010453d:	0f 84 99 00 00 00    	je     801045dc <sys_link+0xed>
  ilock(ip);
80104543:	83 ec 0c             	sub    $0xc,%esp
80104546:	50                   	push   %eax
80104547:	e8 35 d0 ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
8010454c:	83 c4 10             	add    $0x10,%esp
8010454f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104554:	0f 84 8e 00 00 00    	je     801045e8 <sys_link+0xf9>
  ip->nlink++;
8010455a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010455e:	83 c0 01             	add    $0x1,%eax
80104561:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104565:	83 ec 0c             	sub    $0xc,%esp
80104568:	53                   	push   %ebx
80104569:	e8 b2 ce ff ff       	call   80101420 <iupdate>
  iunlock(ip);
8010456e:	89 1c 24             	mov    %ebx,(%esp)
80104571:	e8 cd d0 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104576:	83 c4 08             	add    $0x8,%esp
80104579:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010457c:	50                   	push   %eax
8010457d:	ff 75 e4             	pushl  -0x1c(%ebp)
80104580:	e8 98 d7 ff ff       	call   80101d1d <nameiparent>
80104585:	89 c6                	mov    %eax,%esi
80104587:	83 c4 10             	add    $0x10,%esp
8010458a:	85 c0                	test   %eax,%eax
8010458c:	74 7e                	je     8010460c <sys_link+0x11d>
  ilock(dp);
8010458e:	83 ec 0c             	sub    $0xc,%esp
80104591:	50                   	push   %eax
80104592:	e8 ea cf ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104597:	83 c4 10             	add    $0x10,%esp
8010459a:	8b 03                	mov    (%ebx),%eax
8010459c:	39 06                	cmp    %eax,(%esi)
8010459e:	75 60                	jne    80104600 <sys_link+0x111>
801045a0:	83 ec 04             	sub    $0x4,%esp
801045a3:	ff 73 04             	pushl  0x4(%ebx)
801045a6:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045a9:	50                   	push   %eax
801045aa:	56                   	push   %esi
801045ab:	e8 9e d6 ff ff       	call   80101c4e <dirlink>
801045b0:	83 c4 10             	add    $0x10,%esp
801045b3:	85 c0                	test   %eax,%eax
801045b5:	78 49                	js     80104600 <sys_link+0x111>
  iunlockput(dp);
801045b7:	83 ec 0c             	sub    $0xc,%esp
801045ba:	56                   	push   %esi
801045bb:	e8 68 d1 ff ff       	call   80101728 <iunlockput>
  iput(ip);
801045c0:	89 1c 24             	mov    %ebx,(%esp)
801045c3:	e8 c0 d0 ff ff       	call   80101688 <iput>
  end_op();
801045c8:	e8 85 e3 ff ff       	call   80102952 <end_op>
  return 0;
801045cd:	83 c4 10             	add    $0x10,%esp
801045d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801045d8:	5b                   	pop    %ebx
801045d9:	5e                   	pop    %esi
801045da:	5d                   	pop    %ebp
801045db:	c3                   	ret    
    end_op();
801045dc:	e8 71 e3 ff ff       	call   80102952 <end_op>
    return -1;
801045e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e6:	eb ed                	jmp    801045d5 <sys_link+0xe6>
    iunlockput(ip);
801045e8:	83 ec 0c             	sub    $0xc,%esp
801045eb:	53                   	push   %ebx
801045ec:	e8 37 d1 ff ff       	call   80101728 <iunlockput>
    end_op();
801045f1:	e8 5c e3 ff ff       	call   80102952 <end_op>
    return -1;
801045f6:	83 c4 10             	add    $0x10,%esp
801045f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fe:	eb d5                	jmp    801045d5 <sys_link+0xe6>
    iunlockput(dp);
80104600:	83 ec 0c             	sub    $0xc,%esp
80104603:	56                   	push   %esi
80104604:	e8 1f d1 ff ff       	call   80101728 <iunlockput>
    goto bad;
80104609:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010460c:	83 ec 0c             	sub    $0xc,%esp
8010460f:	53                   	push   %ebx
80104610:	e8 6c cf ff ff       	call   80101581 <ilock>
  ip->nlink--;
80104615:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104619:	83 e8 01             	sub    $0x1,%eax
8010461c:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104620:	89 1c 24             	mov    %ebx,(%esp)
80104623:	e8 f8 cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104628:	89 1c 24             	mov    %ebx,(%esp)
8010462b:	e8 f8 d0 ff ff       	call   80101728 <iunlockput>
  end_op();
80104630:	e8 1d e3 ff ff       	call   80102952 <end_op>
  return -1;
80104635:	83 c4 10             	add    $0x10,%esp
80104638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010463d:	eb 96                	jmp    801045d5 <sys_link+0xe6>
    return -1;
8010463f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104644:	eb 8f                	jmp    801045d5 <sys_link+0xe6>
80104646:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464b:	eb 88                	jmp    801045d5 <sys_link+0xe6>

8010464d <sys_unlink>:
{
8010464d:	55                   	push   %ebp
8010464e:	89 e5                	mov    %esp,%ebp
80104650:	57                   	push   %edi
80104651:	56                   	push   %esi
80104652:	53                   	push   %ebx
80104653:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104656:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104659:	50                   	push   %eax
8010465a:	6a 00                	push   $0x0
8010465c:	e8 e5 f9 ff ff       	call   80104046 <argstr>
80104661:	83 c4 10             	add    $0x10,%esp
80104664:	85 c0                	test   %eax,%eax
80104666:	0f 88 83 01 00 00    	js     801047ef <sys_unlink+0x1a2>
  begin_op();
8010466c:	e8 67 e2 ff ff       	call   801028d8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104671:	83 ec 08             	sub    $0x8,%esp
80104674:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104677:	50                   	push   %eax
80104678:	ff 75 c4             	pushl  -0x3c(%ebp)
8010467b:	e8 9d d6 ff ff       	call   80101d1d <nameiparent>
80104680:	89 c6                	mov    %eax,%esi
80104682:	83 c4 10             	add    $0x10,%esp
80104685:	85 c0                	test   %eax,%eax
80104687:	0f 84 ed 00 00 00    	je     8010477a <sys_unlink+0x12d>
  ilock(dp);
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	50                   	push   %eax
80104691:	e8 eb ce ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104696:	83 c4 08             	add    $0x8,%esp
80104699:	68 5e 6d 10 80       	push   $0x80106d5e
8010469e:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046a1:	50                   	push   %eax
801046a2:	e8 f4 d2 ff ff       	call   8010199b <namecmp>
801046a7:	83 c4 10             	add    $0x10,%esp
801046aa:	85 c0                	test   %eax,%eax
801046ac:	0f 84 fc 00 00 00    	je     801047ae <sys_unlink+0x161>
801046b2:	83 ec 08             	sub    $0x8,%esp
801046b5:	68 5d 6d 10 80       	push   $0x80106d5d
801046ba:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046bd:	50                   	push   %eax
801046be:	e8 d8 d2 ff ff       	call   8010199b <namecmp>
801046c3:	83 c4 10             	add    $0x10,%esp
801046c6:	85 c0                	test   %eax,%eax
801046c8:	0f 84 e0 00 00 00    	je     801047ae <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
801046ce:	83 ec 04             	sub    $0x4,%esp
801046d1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801046d4:	50                   	push   %eax
801046d5:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046d8:	50                   	push   %eax
801046d9:	56                   	push   %esi
801046da:	e8 d1 d2 ff ff       	call   801019b0 <dirlookup>
801046df:	89 c3                	mov    %eax,%ebx
801046e1:	83 c4 10             	add    $0x10,%esp
801046e4:	85 c0                	test   %eax,%eax
801046e6:	0f 84 c2 00 00 00    	je     801047ae <sys_unlink+0x161>
  ilock(ip);
801046ec:	83 ec 0c             	sub    $0xc,%esp
801046ef:	50                   	push   %eax
801046f0:	e8 8c ce ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
801046f5:	83 c4 10             	add    $0x10,%esp
801046f8:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801046fd:	0f 8e 83 00 00 00    	jle    80104786 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104703:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104708:	0f 84 85 00 00 00    	je     80104793 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
8010470e:	83 ec 04             	sub    $0x4,%esp
80104711:	6a 10                	push   $0x10
80104713:	6a 00                	push   $0x0
80104715:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104718:	57                   	push   %edi
80104719:	e8 4d f6 ff ff       	call   80103d6b <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010471e:	6a 10                	push   $0x10
80104720:	ff 75 c0             	pushl  -0x40(%ebp)
80104723:	57                   	push   %edi
80104724:	56                   	push   %esi
80104725:	e8 46 d1 ff ff       	call   80101870 <writei>
8010472a:	83 c4 20             	add    $0x20,%esp
8010472d:	83 f8 10             	cmp    $0x10,%eax
80104730:	0f 85 90 00 00 00    	jne    801047c6 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104736:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010473b:	0f 84 92 00 00 00    	je     801047d3 <sys_unlink+0x186>
  iunlockput(dp);
80104741:	83 ec 0c             	sub    $0xc,%esp
80104744:	56                   	push   %esi
80104745:	e8 de cf ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
8010474a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010474e:	83 e8 01             	sub    $0x1,%eax
80104751:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104755:	89 1c 24             	mov    %ebx,(%esp)
80104758:	e8 c3 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010475d:	89 1c 24             	mov    %ebx,(%esp)
80104760:	e8 c3 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104765:	e8 e8 e1 ff ff       	call   80102952 <end_op>
  return 0;
8010476a:	83 c4 10             	add    $0x10,%esp
8010476d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104772:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104775:	5b                   	pop    %ebx
80104776:	5e                   	pop    %esi
80104777:	5f                   	pop    %edi
80104778:	5d                   	pop    %ebp
80104779:	c3                   	ret    
    end_op();
8010477a:	e8 d3 e1 ff ff       	call   80102952 <end_op>
    return -1;
8010477f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104784:	eb ec                	jmp    80104772 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104786:	83 ec 0c             	sub    $0xc,%esp
80104789:	68 7c 6d 10 80       	push   $0x80106d7c
8010478e:	e8 b5 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104793:	89 d8                	mov    %ebx,%eax
80104795:	e8 d2 f9 ff ff       	call   8010416c <isdirempty>
8010479a:	85 c0                	test   %eax,%eax
8010479c:	0f 85 6c ff ff ff    	jne    8010470e <sys_unlink+0xc1>
    iunlockput(ip);
801047a2:	83 ec 0c             	sub    $0xc,%esp
801047a5:	53                   	push   %ebx
801047a6:	e8 7d cf ff ff       	call   80101728 <iunlockput>
    goto bad;
801047ab:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	56                   	push   %esi
801047b2:	e8 71 cf ff ff       	call   80101728 <iunlockput>
  end_op();
801047b7:	e8 96 e1 ff ff       	call   80102952 <end_op>
  return -1;
801047bc:	83 c4 10             	add    $0x10,%esp
801047bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c4:	eb ac                	jmp    80104772 <sys_unlink+0x125>
    panic("unlink: writei");
801047c6:	83 ec 0c             	sub    $0xc,%esp
801047c9:	68 8e 6d 10 80       	push   $0x80106d8e
801047ce:	e8 75 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
801047d3:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801047d7:	83 e8 01             	sub    $0x1,%eax
801047da:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801047de:	83 ec 0c             	sub    $0xc,%esp
801047e1:	56                   	push   %esi
801047e2:	e8 39 cc ff ff       	call   80101420 <iupdate>
801047e7:	83 c4 10             	add    $0x10,%esp
801047ea:	e9 52 ff ff ff       	jmp    80104741 <sys_unlink+0xf4>
    return -1;
801047ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f4:	e9 79 ff ff ff       	jmp    80104772 <sys_unlink+0x125>

801047f9 <sys_open>:

int
sys_open(void)
{
801047f9:	55                   	push   %ebp
801047fa:	89 e5                	mov    %esp,%ebp
801047fc:	57                   	push   %edi
801047fd:	56                   	push   %esi
801047fe:	53                   	push   %ebx
801047ff:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104802:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104805:	50                   	push   %eax
80104806:	6a 00                	push   $0x0
80104808:	e8 39 f8 ff ff       	call   80104046 <argstr>
8010480d:	83 c4 10             	add    $0x10,%esp
80104810:	85 c0                	test   %eax,%eax
80104812:	0f 88 4f 01 00 00    	js     80104967 <sys_open+0x16e>
80104818:	83 ec 08             	sub    $0x8,%esp
8010481b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010481e:	50                   	push   %eax
8010481f:	6a 01                	push   $0x1
80104821:	e8 90 f7 ff ff       	call   80103fb6 <argint>
80104826:	83 c4 10             	add    $0x10,%esp
80104829:	85 c0                	test   %eax,%eax
8010482b:	0f 88 3d 01 00 00    	js     8010496e <sys_open+0x175>
    return -1;

  begin_op();
80104831:	e8 a2 e0 ff ff       	call   801028d8 <begin_op>
  
symlinkRepeat: 
  if(omode & O_CREATE){
80104836:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
8010483a:	75 53                	jne    8010488f <sys_open+0x96>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
8010483c:	83 ec 0c             	sub    $0xc,%esp
8010483f:	ff 75 e4             	pushl  -0x1c(%ebp)
80104842:	e8 b8 d4 ff ff       	call   80101cff <namei>
80104847:	89 c3                	mov    %eax,%ebx
80104849:	83 c4 10             	add    $0x10,%esp
8010484c:	85 c0                	test   %eax,%eax
8010484e:	0f 84 bb 00 00 00    	je     8010490f <sys_open+0x116>
      end_op();
      return -1;
    }
    ilock(ip);
80104854:	83 ec 0c             	sub    $0xc,%esp
80104857:	50                   	push   %eax
80104858:	e8 24 cd ff ff       	call   80101581 <ilock>
    if(ip->type == T_SYM) {
8010485d:	0f b7 43 50          	movzwl 0x50(%ebx),%eax
80104861:	83 c4 10             	add    $0x10,%esp
80104864:	66 83 f8 04          	cmp    $0x4,%ax
80104868:	0f 85 ad 00 00 00    	jne    8010491b <sys_open+0x122>
	safestrcpy(path, (char *)ip->addrs, 512);
8010486e:	8d 43 5c             	lea    0x5c(%ebx),%eax
80104871:	83 ec 04             	sub    $0x4,%esp
80104874:	68 00 02 00 00       	push   $0x200
80104879:	50                   	push   %eax
8010487a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010487d:	e8 50 f6 ff ff       	call   80103ed2 <safestrcpy>
	iunlock(ip);
80104882:	89 1c 24             	mov    %ebx,(%esp)
80104885:	e8 b9 cd ff ff       	call   80101643 <iunlock>
	goto symlinkRepeat;
8010488a:	83 c4 10             	add    $0x10,%esp
8010488d:	eb a7                	jmp    80104836 <sys_open+0x3d>
    ip = create(path, T_FILE, 0, 0);
8010488f:	83 ec 0c             	sub    $0xc,%esp
80104892:	6a 00                	push   $0x0
80104894:	b9 00 00 00 00       	mov    $0x0,%ecx
80104899:	ba 02 00 00 00       	mov    $0x2,%edx
8010489e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801048a1:	e8 1d f9 ff ff       	call   801041c3 <create>
801048a6:	89 c3                	mov    %eax,%ebx
    if(ip == 0){
801048a8:	83 c4 10             	add    $0x10,%esp
801048ab:	85 c0                	test   %eax,%eax
801048ad:	74 54                	je     80104903 <sys_open+0x10a>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801048af:	e8 79 c3 ff ff       	call   80100c2d <filealloc>
801048b4:	89 c6                	mov    %eax,%esi
801048b6:	85 c0                	test   %eax,%eax
801048b8:	0f 84 81 00 00 00    	je     8010493f <sys_open+0x146>
801048be:	e8 72 f8 ff ff       	call   80104135 <fdalloc>
801048c3:	89 c7                	mov    %eax,%edi
801048c5:	85 c0                	test   %eax,%eax
801048c7:	78 76                	js     8010493f <sys_open+0x146>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801048c9:	83 ec 0c             	sub    $0xc,%esp
801048cc:	53                   	push   %ebx
801048cd:	e8 71 cd ff ff       	call   80101643 <iunlock>
  end_op();
801048d2:	e8 7b e0 ff ff       	call   80102952 <end_op>

  f->type = FD_INODE;
801048d7:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
801048dd:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
801048e0:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
801048e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ea:	83 c4 10             	add    $0x10,%esp
801048ed:	a8 01                	test   $0x1,%al
801048ef:	0f 94 46 08          	sete   0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801048f3:	a8 03                	test   $0x3,%al
801048f5:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
}
801048f9:	89 f8                	mov    %edi,%eax
801048fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048fe:	5b                   	pop    %ebx
801048ff:	5e                   	pop    %esi
80104900:	5f                   	pop    %edi
80104901:	5d                   	pop    %ebp
80104902:	c3                   	ret    
      end_op();
80104903:	e8 4a e0 ff ff       	call   80102952 <end_op>
      return -1;
80104908:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010490d:	eb ea                	jmp    801048f9 <sys_open+0x100>
      end_op();
8010490f:	e8 3e e0 ff ff       	call   80102952 <end_op>
      return -1;
80104914:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104919:	eb de                	jmp    801048f9 <sys_open+0x100>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010491b:	66 83 f8 01          	cmp    $0x1,%ax
8010491f:	75 8e                	jne    801048af <sys_open+0xb6>
80104921:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104925:	74 88                	je     801048af <sys_open+0xb6>
      iunlockput(ip);
80104927:	83 ec 0c             	sub    $0xc,%esp
8010492a:	53                   	push   %ebx
8010492b:	e8 f8 cd ff ff       	call   80101728 <iunlockput>
      end_op();
80104930:	e8 1d e0 ff ff       	call   80102952 <end_op>
      return -1;
80104935:	83 c4 10             	add    $0x10,%esp
80104938:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010493d:	eb ba                	jmp    801048f9 <sys_open+0x100>
    if(f)
8010493f:	85 f6                	test   %esi,%esi
80104941:	74 0c                	je     8010494f <sys_open+0x156>
      fileclose(f);
80104943:	83 ec 0c             	sub    $0xc,%esp
80104946:	56                   	push   %esi
80104947:	e8 87 c3 ff ff       	call   80100cd3 <fileclose>
8010494c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010494f:	83 ec 0c             	sub    $0xc,%esp
80104952:	53                   	push   %ebx
80104953:	e8 d0 cd ff ff       	call   80101728 <iunlockput>
    end_op();
80104958:	e8 f5 df ff ff       	call   80102952 <end_op>
    return -1;
8010495d:	83 c4 10             	add    $0x10,%esp
80104960:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104965:	eb 92                	jmp    801048f9 <sys_open+0x100>
    return -1;
80104967:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010496c:	eb 8b                	jmp    801048f9 <sys_open+0x100>
8010496e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104973:	eb 84                	jmp    801048f9 <sys_open+0x100>

80104975 <sys_mkdir>:

int
sys_mkdir(void)
{
80104975:	55                   	push   %ebp
80104976:	89 e5                	mov    %esp,%ebp
80104978:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010497b:	e8 58 df ff ff       	call   801028d8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104980:	83 ec 08             	sub    $0x8,%esp
80104983:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104986:	50                   	push   %eax
80104987:	6a 00                	push   $0x0
80104989:	e8 b8 f6 ff ff       	call   80104046 <argstr>
8010498e:	83 c4 10             	add    $0x10,%esp
80104991:	85 c0                	test   %eax,%eax
80104993:	78 36                	js     801049cb <sys_mkdir+0x56>
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	6a 00                	push   $0x0
8010499a:	b9 00 00 00 00       	mov    $0x0,%ecx
8010499f:	ba 01 00 00 00       	mov    $0x1,%edx
801049a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a7:	e8 17 f8 ff ff       	call   801041c3 <create>
801049ac:	83 c4 10             	add    $0x10,%esp
801049af:	85 c0                	test   %eax,%eax
801049b1:	74 18                	je     801049cb <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049b3:	83 ec 0c             	sub    $0xc,%esp
801049b6:	50                   	push   %eax
801049b7:	e8 6c cd ff ff       	call   80101728 <iunlockput>
  end_op();
801049bc:	e8 91 df ff ff       	call   80102952 <end_op>
  return 0;
801049c1:	83 c4 10             	add    $0x10,%esp
801049c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049c9:	c9                   	leave  
801049ca:	c3                   	ret    
    end_op();
801049cb:	e8 82 df ff ff       	call   80102952 <end_op>
    return -1;
801049d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049d5:	eb f2                	jmp    801049c9 <sys_mkdir+0x54>

801049d7 <sys_mknod>:

int
sys_mknod(void)
{
801049d7:	55                   	push   %ebp
801049d8:	89 e5                	mov    %esp,%ebp
801049da:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801049dd:	e8 f6 de ff ff       	call   801028d8 <begin_op>
  if((argstr(0, &path)) < 0 ||
801049e2:	83 ec 08             	sub    $0x8,%esp
801049e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049e8:	50                   	push   %eax
801049e9:	6a 00                	push   $0x0
801049eb:	e8 56 f6 ff ff       	call   80104046 <argstr>
801049f0:	83 c4 10             	add    $0x10,%esp
801049f3:	85 c0                	test   %eax,%eax
801049f5:	78 62                	js     80104a59 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
801049f7:	83 ec 08             	sub    $0x8,%esp
801049fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801049fd:	50                   	push   %eax
801049fe:	6a 01                	push   $0x1
80104a00:	e8 b1 f5 ff ff       	call   80103fb6 <argint>
  if((argstr(0, &path)) < 0 ||
80104a05:	83 c4 10             	add    $0x10,%esp
80104a08:	85 c0                	test   %eax,%eax
80104a0a:	78 4d                	js     80104a59 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a0c:	83 ec 08             	sub    $0x8,%esp
80104a0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a12:	50                   	push   %eax
80104a13:	6a 02                	push   $0x2
80104a15:	e8 9c f5 ff ff       	call   80103fb6 <argint>
     argint(1, &major) < 0 ||
80104a1a:	83 c4 10             	add    $0x10,%esp
80104a1d:	85 c0                	test   %eax,%eax
80104a1f:	78 38                	js     80104a59 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104a21:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104a25:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104a29:	83 ec 0c             	sub    $0xc,%esp
80104a2c:	50                   	push   %eax
80104a2d:	ba 03 00 00 00       	mov    $0x3,%edx
80104a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a35:	e8 89 f7 ff ff       	call   801041c3 <create>
80104a3a:	83 c4 10             	add    $0x10,%esp
80104a3d:	85 c0                	test   %eax,%eax
80104a3f:	74 18                	je     80104a59 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a41:	83 ec 0c             	sub    $0xc,%esp
80104a44:	50                   	push   %eax
80104a45:	e8 de cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104a4a:	e8 03 df ff ff       	call   80102952 <end_op>
  return 0;
80104a4f:	83 c4 10             	add    $0x10,%esp
80104a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a57:	c9                   	leave  
80104a58:	c3                   	ret    
    end_op();
80104a59:	e8 f4 de ff ff       	call   80102952 <end_op>
    return -1;
80104a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a63:	eb f2                	jmp    80104a57 <sys_mknod+0x80>

80104a65 <sys_chdir>:

int
sys_chdir(void)
{
80104a65:	55                   	push   %ebp
80104a66:	89 e5                	mov    %esp,%ebp
80104a68:	56                   	push   %esi
80104a69:	53                   	push   %ebx
80104a6a:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a6d:	e8 ae e8 ff ff       	call   80103320 <myproc>
80104a72:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104a74:	e8 5f de ff ff       	call   801028d8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a79:	83 ec 08             	sub    $0x8,%esp
80104a7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a7f:	50                   	push   %eax
80104a80:	6a 00                	push   $0x0
80104a82:	e8 bf f5 ff ff       	call   80104046 <argstr>
80104a87:	83 c4 10             	add    $0x10,%esp
80104a8a:	85 c0                	test   %eax,%eax
80104a8c:	78 52                	js     80104ae0 <sys_chdir+0x7b>
80104a8e:	83 ec 0c             	sub    $0xc,%esp
80104a91:	ff 75 f4             	pushl  -0xc(%ebp)
80104a94:	e8 66 d2 ff ff       	call   80101cff <namei>
80104a99:	89 c3                	mov    %eax,%ebx
80104a9b:	83 c4 10             	add    $0x10,%esp
80104a9e:	85 c0                	test   %eax,%eax
80104aa0:	74 3e                	je     80104ae0 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104aa2:	83 ec 0c             	sub    $0xc,%esp
80104aa5:	50                   	push   %eax
80104aa6:	e8 d6 ca ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104aab:	83 c4 10             	add    $0x10,%esp
80104aae:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104ab3:	75 37                	jne    80104aec <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104ab5:	83 ec 0c             	sub    $0xc,%esp
80104ab8:	53                   	push   %ebx
80104ab9:	e8 85 cb ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104abe:	83 c4 04             	add    $0x4,%esp
80104ac1:	ff 76 68             	pushl  0x68(%esi)
80104ac4:	e8 bf cb ff ff       	call   80101688 <iput>
  end_op();
80104ac9:	e8 84 de ff ff       	call   80102952 <end_op>
  curproc->cwd = ip;
80104ace:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104ad1:	83 c4 10             	add    $0x10,%esp
80104ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104adc:	5b                   	pop    %ebx
80104add:	5e                   	pop    %esi
80104ade:	5d                   	pop    %ebp
80104adf:	c3                   	ret    
    end_op();
80104ae0:	e8 6d de ff ff       	call   80102952 <end_op>
    return -1;
80104ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aea:	eb ed                	jmp    80104ad9 <sys_chdir+0x74>
    iunlockput(ip);
80104aec:	83 ec 0c             	sub    $0xc,%esp
80104aef:	53                   	push   %ebx
80104af0:	e8 33 cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104af5:	e8 58 de ff ff       	call   80102952 <end_op>
    return -1;
80104afa:	83 c4 10             	add    $0x10,%esp
80104afd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b02:	eb d5                	jmp    80104ad9 <sys_chdir+0x74>

80104b04 <sys_exec>:

int
sys_exec(void)
{
80104b04:	55                   	push   %ebp
80104b05:	89 e5                	mov    %esp,%ebp
80104b07:	53                   	push   %ebx
80104b08:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b11:	50                   	push   %eax
80104b12:	6a 00                	push   $0x0
80104b14:	e8 2d f5 ff ff       	call   80104046 <argstr>
80104b19:	83 c4 10             	add    $0x10,%esp
80104b1c:	85 c0                	test   %eax,%eax
80104b1e:	0f 88 a8 00 00 00    	js     80104bcc <sys_exec+0xc8>
80104b24:	83 ec 08             	sub    $0x8,%esp
80104b27:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104b2d:	50                   	push   %eax
80104b2e:	6a 01                	push   $0x1
80104b30:	e8 81 f4 ff ff       	call   80103fb6 <argint>
80104b35:	83 c4 10             	add    $0x10,%esp
80104b38:	85 c0                	test   %eax,%eax
80104b3a:	0f 88 93 00 00 00    	js     80104bd3 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104b40:	83 ec 04             	sub    $0x4,%esp
80104b43:	68 80 00 00 00       	push   $0x80
80104b48:	6a 00                	push   $0x0
80104b4a:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b50:	50                   	push   %eax
80104b51:	e8 15 f2 ff ff       	call   80103d6b <memset>
80104b56:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104b59:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104b5e:	83 fb 1f             	cmp    $0x1f,%ebx
80104b61:	77 77                	ja     80104bda <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b63:	83 ec 08             	sub    $0x8,%esp
80104b66:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b6c:	50                   	push   %eax
80104b6d:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b73:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b76:	50                   	push   %eax
80104b77:	e8 be f3 ff ff       	call   80103f3a <fetchint>
80104b7c:	83 c4 10             	add    $0x10,%esp
80104b7f:	85 c0                	test   %eax,%eax
80104b81:	78 5e                	js     80104be1 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104b83:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	74 1d                	je     80104baa <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104b8d:	83 ec 08             	sub    $0x8,%esp
80104b90:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b97:	52                   	push   %edx
80104b98:	50                   	push   %eax
80104b99:	e8 d8 f3 ff ff       	call   80103f76 <fetchstr>
80104b9e:	83 c4 10             	add    $0x10,%esp
80104ba1:	85 c0                	test   %eax,%eax
80104ba3:	78 46                	js     80104beb <sys_exec+0xe7>
  for(i=0;; i++){
80104ba5:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104ba8:	eb b4                	jmp    80104b5e <sys_exec+0x5a>
      argv[i] = 0;
80104baa:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104bb1:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104bb5:	83 ec 08             	sub    $0x8,%esp
80104bb8:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bbe:	50                   	push   %eax
80104bbf:	ff 75 f4             	pushl  -0xc(%ebp)
80104bc2:	e8 0b bd ff ff       	call   801008d2 <exec>
80104bc7:	83 c4 10             	add    $0x10,%esp
80104bca:	eb 1a                	jmp    80104be6 <sys_exec+0xe2>
    return -1;
80104bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bd1:	eb 13                	jmp    80104be6 <sys_exec+0xe2>
80104bd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bd8:	eb 0c                	jmp    80104be6 <sys_exec+0xe2>
      return -1;
80104bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bdf:	eb 05                	jmp    80104be6 <sys_exec+0xe2>
      return -1;
80104be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104be6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104be9:	c9                   	leave  
80104bea:	c3                   	ret    
      return -1;
80104beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf0:	eb f4                	jmp    80104be6 <sys_exec+0xe2>

80104bf2 <sys_pipe>:

int
sys_pipe(void)
{
80104bf2:	55                   	push   %ebp
80104bf3:	89 e5                	mov    %esp,%ebp
80104bf5:	53                   	push   %ebx
80104bf6:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104bf9:	6a 08                	push   $0x8
80104bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bfe:	50                   	push   %eax
80104bff:	6a 00                	push   $0x0
80104c01:	e8 d8 f3 ff ff       	call   80103fde <argptr>
80104c06:	83 c4 10             	add    $0x10,%esp
80104c09:	85 c0                	test   %eax,%eax
80104c0b:	78 77                	js     80104c84 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c0d:	83 ec 08             	sub    $0x8,%esp
80104c10:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c13:	50                   	push   %eax
80104c14:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c17:	50                   	push   %eax
80104c18:	e8 42 e2 ff ff       	call   80102e5f <pipealloc>
80104c1d:	83 c4 10             	add    $0x10,%esp
80104c20:	85 c0                	test   %eax,%eax
80104c22:	78 67                	js     80104c8b <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c27:	e8 09 f5 ff ff       	call   80104135 <fdalloc>
80104c2c:	89 c3                	mov    %eax,%ebx
80104c2e:	85 c0                	test   %eax,%eax
80104c30:	78 21                	js     80104c53 <sys_pipe+0x61>
80104c32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c35:	e8 fb f4 ff ff       	call   80104135 <fdalloc>
80104c3a:	85 c0                	test   %eax,%eax
80104c3c:	78 15                	js     80104c53 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c41:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104c43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c46:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c51:	c9                   	leave  
80104c52:	c3                   	ret    
    if(fd0 >= 0)
80104c53:	85 db                	test   %ebx,%ebx
80104c55:	78 0d                	js     80104c64 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104c57:	e8 c4 e6 ff ff       	call   80103320 <myproc>
80104c5c:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104c63:	00 
    fileclose(rf);
80104c64:	83 ec 0c             	sub    $0xc,%esp
80104c67:	ff 75 f0             	pushl  -0x10(%ebp)
80104c6a:	e8 64 c0 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104c6f:	83 c4 04             	add    $0x4,%esp
80104c72:	ff 75 ec             	pushl  -0x14(%ebp)
80104c75:	e8 59 c0 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104c7a:	83 c4 10             	add    $0x10,%esp
80104c7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c82:	eb ca                	jmp    80104c4e <sys_pipe+0x5c>
    return -1;
80104c84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c89:	eb c3                	jmp    80104c4e <sys_pipe+0x5c>
    return -1;
80104c8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c90:	eb bc                	jmp    80104c4e <sys_pipe+0x5c>

80104c92 <sys_symlink>:

int sys_symlink(void) {
80104c92:	55                   	push   %ebp
80104c93:	89 e5                	mov    %esp,%ebp
80104c95:	53                   	push   %ebx
80104c96:	83 ec 1c             	sub    $0x1c,%esp
	char *target, *link_name;
	struct inode *ip;

	if(argstr(0, &target) < 0 || argstr(1, &link_name) < 0) {
80104c99:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c9c:	50                   	push   %eax
80104c9d:	6a 00                	push   $0x0
80104c9f:	e8 a2 f3 ff ff       	call   80104046 <argstr>
80104ca4:	83 c4 10             	add    $0x10,%esp
80104ca7:	85 c0                	test   %eax,%eax
80104ca9:	0f 88 84 00 00 00    	js     80104d33 <sys_symlink+0xa1>
80104caf:	83 ec 08             	sub    $0x8,%esp
80104cb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cb5:	50                   	push   %eax
80104cb6:	6a 01                	push   $0x1
80104cb8:	e8 89 f3 ff ff       	call   80104046 <argstr>
80104cbd:	83 c4 10             	add    $0x10,%esp
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	78 76                	js     80104d3a <sys_symlink+0xa8>
		return -1;
	}
	begin_op();
80104cc4:	e8 0f dc ff ff       	call   801028d8 <begin_op>

	if((ip = create(link_name, T_SYM, 0, 0)) == 0) {
80104cc9:	83 ec 0c             	sub    $0xc,%esp
80104ccc:	6a 00                	push   $0x0
80104cce:	b9 00 00 00 00       	mov    $0x0,%ecx
80104cd3:	ba 04 00 00 00       	mov    $0x4,%edx
80104cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cdb:	e8 e3 f4 ff ff       	call   801041c3 <create>
80104ce0:	89 c3                	mov    %eax,%ebx
80104ce2:	83 c4 10             	add    $0x10,%esp
80104ce5:	85 c0                	test   %eax,%eax
80104ce7:	74 32                	je     80104d1b <sys_symlink+0x89>
		iunlockput(ip);
		end_op();
		return -1;
	}

	writei(ip, target, 0 , strlen(target));
80104ce9:	83 ec 0c             	sub    $0xc,%esp
80104cec:	ff 75 f4             	pushl  -0xc(%ebp)
80104cef:	e8 19 f2 ff ff       	call   80103f0d <strlen>
80104cf4:	50                   	push   %eax
80104cf5:	6a 00                	push   $0x0
80104cf7:	ff 75 f4             	pushl  -0xc(%ebp)
80104cfa:	53                   	push   %ebx
80104cfb:	e8 70 cb ff ff       	call   80101870 <writei>
	iunlockput(ip);
80104d00:	83 c4 14             	add    $0x14,%esp
80104d03:	53                   	push   %ebx
80104d04:	e8 1f ca ff ff       	call   80101728 <iunlockput>
	end_op();
80104d09:	e8 44 dc ff ff       	call   80102952 <end_op>
	return 0;
80104d0e:	83 c4 10             	add    $0x10,%esp
80104d11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d19:	c9                   	leave  
80104d1a:	c3                   	ret    
		iunlockput(ip);
80104d1b:	83 ec 0c             	sub    $0xc,%esp
80104d1e:	50                   	push   %eax
80104d1f:	e8 04 ca ff ff       	call   80101728 <iunlockput>
		end_op();
80104d24:	e8 29 dc ff ff       	call   80102952 <end_op>
		return -1;
80104d29:	83 c4 10             	add    $0x10,%esp
80104d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d31:	eb e3                	jmp    80104d16 <sys_symlink+0x84>
		return -1;
80104d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d38:	eb dc                	jmp    80104d16 <sys_symlink+0x84>
80104d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3f:	eb d5                	jmp    80104d16 <sys_symlink+0x84>

80104d41 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
80104d44:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d47:	e8 4c e7 ff ff       	call   80103498 <fork>
}
80104d4c:	c9                   	leave  
80104d4d:	c3                   	ret    

80104d4e <sys_exit>:

int
sys_exit(void)
{
80104d4e:	55                   	push   %ebp
80104d4f:	89 e5                	mov    %esp,%ebp
80104d51:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d54:	e8 73 e9 ff ff       	call   801036cc <exit>
  return 0;  // not reached
}
80104d59:	b8 00 00 00 00       	mov    $0x0,%eax
80104d5e:	c9                   	leave  
80104d5f:	c3                   	ret    

80104d60 <sys_wait>:

int
sys_wait(void)
{
80104d60:	55                   	push   %ebp
80104d61:	89 e5                	mov    %esp,%ebp
80104d63:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d66:	e8 ea ea ff ff       	call   80103855 <wait>
}
80104d6b:	c9                   	leave  
80104d6c:	c3                   	ret    

80104d6d <sys_kill>:

int
sys_kill(void)
{
80104d6d:	55                   	push   %ebp
80104d6e:	89 e5                	mov    %esp,%ebp
80104d70:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d73:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d76:	50                   	push   %eax
80104d77:	6a 00                	push   $0x0
80104d79:	e8 38 f2 ff ff       	call   80103fb6 <argint>
80104d7e:	83 c4 10             	add    $0x10,%esp
80104d81:	85 c0                	test   %eax,%eax
80104d83:	78 10                	js     80104d95 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d85:	83 ec 0c             	sub    $0xc,%esp
80104d88:	ff 75 f4             	pushl  -0xc(%ebp)
80104d8b:	e8 c2 eb ff ff       	call   80103952 <kill>
80104d90:	83 c4 10             	add    $0x10,%esp
}
80104d93:	c9                   	leave  
80104d94:	c3                   	ret    
    return -1;
80104d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d9a:	eb f7                	jmp    80104d93 <sys_kill+0x26>

80104d9c <sys_getpid>:

int
sys_getpid(void)
{
80104d9c:	55                   	push   %ebp
80104d9d:	89 e5                	mov    %esp,%ebp
80104d9f:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104da2:	e8 79 e5 ff ff       	call   80103320 <myproc>
80104da7:	8b 40 10             	mov    0x10(%eax),%eax
}
80104daa:	c9                   	leave  
80104dab:	c3                   	ret    

80104dac <sys_sbrk>:

int
sys_sbrk(void)
{
80104dac:	55                   	push   %ebp
80104dad:	89 e5                	mov    %esp,%ebp
80104daf:	53                   	push   %ebx
80104db0:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104db3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104db6:	50                   	push   %eax
80104db7:	6a 00                	push   $0x0
80104db9:	e8 f8 f1 ff ff       	call   80103fb6 <argint>
80104dbe:	83 c4 10             	add    $0x10,%esp
80104dc1:	85 c0                	test   %eax,%eax
80104dc3:	78 27                	js     80104dec <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104dc5:	e8 56 e5 ff ff       	call   80103320 <myproc>
80104dca:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104dcc:	83 ec 0c             	sub    $0xc,%esp
80104dcf:	ff 75 f4             	pushl  -0xc(%ebp)
80104dd2:	e8 54 e6 ff ff       	call   8010342b <growproc>
80104dd7:	83 c4 10             	add    $0x10,%esp
80104dda:	85 c0                	test   %eax,%eax
80104ddc:	78 07                	js     80104de5 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104dde:	89 d8                	mov    %ebx,%eax
80104de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104de3:	c9                   	leave  
80104de4:	c3                   	ret    
    return -1;
80104de5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dea:	eb f2                	jmp    80104dde <sys_sbrk+0x32>
    return -1;
80104dec:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104df1:	eb eb                	jmp    80104dde <sys_sbrk+0x32>

80104df3 <sys_sleep>:

int
sys_sleep(void)
{
80104df3:	55                   	push   %ebp
80104df4:	89 e5                	mov    %esp,%ebp
80104df6:	53                   	push   %ebx
80104df7:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104dfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dfd:	50                   	push   %eax
80104dfe:	6a 00                	push   $0x0
80104e00:	e8 b1 f1 ff ff       	call   80103fb6 <argint>
80104e05:	83 c4 10             	add    $0x10,%esp
80104e08:	85 c0                	test   %eax,%eax
80104e0a:	78 75                	js     80104e81 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e0c:	83 ec 0c             	sub    $0xc,%esp
80104e0f:	68 60 4c 11 80       	push   $0x80114c60
80104e14:	e8 a6 ee ff ff       	call   80103cbf <acquire>
  ticks0 = ticks;
80104e19:	8b 1d a0 54 11 80    	mov    0x801154a0,%ebx
  while(ticks - ticks0 < n){
80104e1f:	83 c4 10             	add    $0x10,%esp
80104e22:	a1 a0 54 11 80       	mov    0x801154a0,%eax
80104e27:	29 d8                	sub    %ebx,%eax
80104e29:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e2c:	73 39                	jae    80104e67 <sys_sleep+0x74>
    if(myproc()->killed){
80104e2e:	e8 ed e4 ff ff       	call   80103320 <myproc>
80104e33:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e37:	75 17                	jne    80104e50 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e39:	83 ec 08             	sub    $0x8,%esp
80104e3c:	68 60 4c 11 80       	push   $0x80114c60
80104e41:	68 a0 54 11 80       	push   $0x801154a0
80104e46:	e8 79 e9 ff ff       	call   801037c4 <sleep>
80104e4b:	83 c4 10             	add    $0x10,%esp
80104e4e:	eb d2                	jmp    80104e22 <sys_sleep+0x2f>
      release(&tickslock);
80104e50:	83 ec 0c             	sub    $0xc,%esp
80104e53:	68 60 4c 11 80       	push   $0x80114c60
80104e58:	e8 c7 ee ff ff       	call   80103d24 <release>
      return -1;
80104e5d:	83 c4 10             	add    $0x10,%esp
80104e60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e65:	eb 15                	jmp    80104e7c <sys_sleep+0x89>
  }
  release(&tickslock);
80104e67:	83 ec 0c             	sub    $0xc,%esp
80104e6a:	68 60 4c 11 80       	push   $0x80114c60
80104e6f:	e8 b0 ee ff ff       	call   80103d24 <release>
  return 0;
80104e74:	83 c4 10             	add    $0x10,%esp
80104e77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e7f:	c9                   	leave  
80104e80:	c3                   	ret    
    return -1;
80104e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e86:	eb f4                	jmp    80104e7c <sys_sleep+0x89>

80104e88 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e88:	55                   	push   %ebp
80104e89:	89 e5                	mov    %esp,%ebp
80104e8b:	53                   	push   %ebx
80104e8c:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e8f:	68 60 4c 11 80       	push   $0x80114c60
80104e94:	e8 26 ee ff ff       	call   80103cbf <acquire>
  xticks = ticks;
80104e99:	8b 1d a0 54 11 80    	mov    0x801154a0,%ebx
  release(&tickslock);
80104e9f:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80104ea6:	e8 79 ee ff ff       	call   80103d24 <release>
  return xticks;
}
80104eab:	89 d8                	mov    %ebx,%eax
80104ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104eb0:	c9                   	leave  
80104eb1:	c3                   	ret    

80104eb2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104eb2:	1e                   	push   %ds
  pushl %es
80104eb3:	06                   	push   %es
  pushl %fs
80104eb4:	0f a0                	push   %fs
  pushl %gs
80104eb6:	0f a8                	push   %gs
  pushal
80104eb8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104eb9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104ebd:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104ebf:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104ec1:	54                   	push   %esp
  call trap
80104ec2:	e8 e3 00 00 00       	call   80104faa <trap>
  addl $4, %esp
80104ec7:	83 c4 04             	add    $0x4,%esp

80104eca <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104eca:	61                   	popa   
  popl %gs
80104ecb:	0f a9                	pop    %gs
  popl %fs
80104ecd:	0f a1                	pop    %fs
  popl %es
80104ecf:	07                   	pop    %es
  popl %ds
80104ed0:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104ed1:	83 c4 08             	add    $0x8,%esp
  iret
80104ed4:	cf                   	iret   

80104ed5 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104ed5:	55                   	push   %ebp
80104ed6:	89 e5                	mov    %esp,%ebp
80104ed8:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104edb:	b8 00 00 00 00       	mov    $0x0,%eax
80104ee0:	eb 4a                	jmp    80104f2c <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104ee2:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104ee9:	66 89 0c c5 a0 4c 11 	mov    %cx,-0x7feeb360(,%eax,8)
80104ef0:	80 
80104ef1:	66 c7 04 c5 a2 4c 11 	movw   $0x8,-0x7feeb35e(,%eax,8)
80104ef8:	80 08 00 
80104efb:	c6 04 c5 a4 4c 11 80 	movb   $0x0,-0x7feeb35c(,%eax,8)
80104f02:	00 
80104f03:	0f b6 14 c5 a5 4c 11 	movzbl -0x7feeb35b(,%eax,8),%edx
80104f0a:	80 
80104f0b:	83 e2 f0             	and    $0xfffffff0,%edx
80104f0e:	83 ca 0e             	or     $0xe,%edx
80104f11:	83 e2 8f             	and    $0xffffff8f,%edx
80104f14:	83 ca 80             	or     $0xffffff80,%edx
80104f17:	88 14 c5 a5 4c 11 80 	mov    %dl,-0x7feeb35b(,%eax,8)
80104f1e:	c1 e9 10             	shr    $0x10,%ecx
80104f21:	66 89 0c c5 a6 4c 11 	mov    %cx,-0x7feeb35a(,%eax,8)
80104f28:	80 
  for(i = 0; i < 256; i++)
80104f29:	83 c0 01             	add    $0x1,%eax
80104f2c:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f31:	7e af                	jle    80104ee2 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f33:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f39:	66 89 15 a0 4e 11 80 	mov    %dx,0x80114ea0
80104f40:	66 c7 05 a2 4e 11 80 	movw   $0x8,0x80114ea2
80104f47:	08 00 
80104f49:	c6 05 a4 4e 11 80 00 	movb   $0x0,0x80114ea4
80104f50:	0f b6 05 a5 4e 11 80 	movzbl 0x80114ea5,%eax
80104f57:	83 c8 0f             	or     $0xf,%eax
80104f5a:	83 e0 ef             	and    $0xffffffef,%eax
80104f5d:	83 c8 e0             	or     $0xffffffe0,%eax
80104f60:	a2 a5 4e 11 80       	mov    %al,0x80114ea5
80104f65:	c1 ea 10             	shr    $0x10,%edx
80104f68:	66 89 15 a6 4e 11 80 	mov    %dx,0x80114ea6

  initlock(&tickslock, "time");
80104f6f:	83 ec 08             	sub    $0x8,%esp
80104f72:	68 bf 6d 10 80       	push   $0x80106dbf
80104f77:	68 60 4c 11 80       	push   $0x80114c60
80104f7c:	e8 02 ec ff ff       	call   80103b83 <initlock>
}
80104f81:	83 c4 10             	add    $0x10,%esp
80104f84:	c9                   	leave  
80104f85:	c3                   	ret    

80104f86 <idtinit>:

void
idtinit(void)
{
80104f86:	55                   	push   %ebp
80104f87:	89 e5                	mov    %esp,%ebp
80104f89:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104f8c:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104f92:	b8 a0 4c 11 80       	mov    $0x80114ca0,%eax
80104f97:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104f9b:	c1 e8 10             	shr    $0x10,%eax
80104f9e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104fa2:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104fa5:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104fa8:	c9                   	leave  
80104fa9:	c3                   	ret    

80104faa <trap>:

void
trap(struct trapframe *tf)
{
80104faa:	55                   	push   %ebp
80104fab:	89 e5                	mov    %esp,%ebp
80104fad:	57                   	push   %edi
80104fae:	56                   	push   %esi
80104faf:	53                   	push   %ebx
80104fb0:	83 ec 1c             	sub    $0x1c,%esp
80104fb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104fb6:	8b 43 30             	mov    0x30(%ebx),%eax
80104fb9:	83 f8 40             	cmp    $0x40,%eax
80104fbc:	74 13                	je     80104fd1 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104fbe:	83 e8 20             	sub    $0x20,%eax
80104fc1:	83 f8 1f             	cmp    $0x1f,%eax
80104fc4:	0f 87 3a 01 00 00    	ja     80105104 <trap+0x15a>
80104fca:	ff 24 85 68 6e 10 80 	jmp    *-0x7fef9198(,%eax,4)
    if(myproc()->killed)
80104fd1:	e8 4a e3 ff ff       	call   80103320 <myproc>
80104fd6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fda:	75 1f                	jne    80104ffb <trap+0x51>
    myproc()->tf = tf;
80104fdc:	e8 3f e3 ff ff       	call   80103320 <myproc>
80104fe1:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104fe4:	e8 90 f0 ff ff       	call   80104079 <syscall>
    if(myproc()->killed)
80104fe9:	e8 32 e3 ff ff       	call   80103320 <myproc>
80104fee:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ff2:	74 7e                	je     80105072 <trap+0xc8>
      exit();
80104ff4:	e8 d3 e6 ff ff       	call   801036cc <exit>
80104ff9:	eb 77                	jmp    80105072 <trap+0xc8>
      exit();
80104ffb:	e8 cc e6 ff ff       	call   801036cc <exit>
80105000:	eb da                	jmp    80104fdc <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105002:	e8 fe e2 ff ff       	call   80103305 <cpuid>
80105007:	85 c0                	test   %eax,%eax
80105009:	74 6f                	je     8010507a <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
8010500b:	e8 b3 d4 ff ff       	call   801024c3 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105010:	e8 0b e3 ff ff       	call   80103320 <myproc>
80105015:	85 c0                	test   %eax,%eax
80105017:	74 1c                	je     80105035 <trap+0x8b>
80105019:	e8 02 e3 ff ff       	call   80103320 <myproc>
8010501e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105022:	74 11                	je     80105035 <trap+0x8b>
80105024:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105028:	83 e0 03             	and    $0x3,%eax
8010502b:	66 83 f8 03          	cmp    $0x3,%ax
8010502f:	0f 84 62 01 00 00    	je     80105197 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105035:	e8 e6 e2 ff ff       	call   80103320 <myproc>
8010503a:	85 c0                	test   %eax,%eax
8010503c:	74 0f                	je     8010504d <trap+0xa3>
8010503e:	e8 dd e2 ff ff       	call   80103320 <myproc>
80105043:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105047:	0f 84 54 01 00 00    	je     801051a1 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010504d:	e8 ce e2 ff ff       	call   80103320 <myproc>
80105052:	85 c0                	test   %eax,%eax
80105054:	74 1c                	je     80105072 <trap+0xc8>
80105056:	e8 c5 e2 ff ff       	call   80103320 <myproc>
8010505b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010505f:	74 11                	je     80105072 <trap+0xc8>
80105061:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105065:	83 e0 03             	and    $0x3,%eax
80105068:	66 83 f8 03          	cmp    $0x3,%ax
8010506c:	0f 84 43 01 00 00    	je     801051b5 <trap+0x20b>
    exit();
}
80105072:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105075:	5b                   	pop    %ebx
80105076:	5e                   	pop    %esi
80105077:	5f                   	pop    %edi
80105078:	5d                   	pop    %ebp
80105079:	c3                   	ret    
      acquire(&tickslock);
8010507a:	83 ec 0c             	sub    $0xc,%esp
8010507d:	68 60 4c 11 80       	push   $0x80114c60
80105082:	e8 38 ec ff ff       	call   80103cbf <acquire>
      ticks++;
80105087:	83 05 a0 54 11 80 01 	addl   $0x1,0x801154a0
      wakeup(&ticks);
8010508e:	c7 04 24 a0 54 11 80 	movl   $0x801154a0,(%esp)
80105095:	e8 8f e8 ff ff       	call   80103929 <wakeup>
      release(&tickslock);
8010509a:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
801050a1:	e8 7e ec ff ff       	call   80103d24 <release>
801050a6:	83 c4 10             	add    $0x10,%esp
801050a9:	e9 5d ff ff ff       	jmp    8010500b <trap+0x61>
    ideintr();
801050ae:	e8 ea cd ff ff       	call   80101e9d <ideintr>
    lapiceoi();
801050b3:	e8 0b d4 ff ff       	call   801024c3 <lapiceoi>
    break;
801050b8:	e9 53 ff ff ff       	jmp    80105010 <trap+0x66>
    kbdintr();
801050bd:	e8 45 d2 ff ff       	call   80102307 <kbdintr>
    lapiceoi();
801050c2:	e8 fc d3 ff ff       	call   801024c3 <lapiceoi>
    break;
801050c7:	e9 44 ff ff ff       	jmp    80105010 <trap+0x66>
    uartintr();
801050cc:	e8 05 02 00 00       	call   801052d6 <uartintr>
    lapiceoi();
801050d1:	e8 ed d3 ff ff       	call   801024c3 <lapiceoi>
    break;
801050d6:	e9 35 ff ff ff       	jmp    80105010 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050db:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801050de:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050e2:	e8 1e e2 ff ff       	call   80103305 <cpuid>
801050e7:	57                   	push   %edi
801050e8:	0f b7 f6             	movzwl %si,%esi
801050eb:	56                   	push   %esi
801050ec:	50                   	push   %eax
801050ed:	68 cc 6d 10 80       	push   $0x80106dcc
801050f2:	e8 14 b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
801050f7:	e8 c7 d3 ff ff       	call   801024c3 <lapiceoi>
    break;
801050fc:	83 c4 10             	add    $0x10,%esp
801050ff:	e9 0c ff ff ff       	jmp    80105010 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105104:	e8 17 e2 ff ff       	call   80103320 <myproc>
80105109:	85 c0                	test   %eax,%eax
8010510b:	74 5f                	je     8010516c <trap+0x1c2>
8010510d:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105111:	74 59                	je     8010516c <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105113:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105116:	8b 43 38             	mov    0x38(%ebx),%eax
80105119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010511c:	e8 e4 e1 ff ff       	call   80103305 <cpuid>
80105121:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105124:	8b 53 34             	mov    0x34(%ebx),%edx
80105127:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010512a:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
8010512d:	e8 ee e1 ff ff       	call   80103320 <myproc>
80105132:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105135:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105138:	e8 e3 e1 ff ff       	call   80103320 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010513d:	57                   	push   %edi
8010513e:	ff 75 e4             	pushl  -0x1c(%ebp)
80105141:	ff 75 e0             	pushl  -0x20(%ebp)
80105144:	ff 75 dc             	pushl  -0x24(%ebp)
80105147:	56                   	push   %esi
80105148:	ff 75 d8             	pushl  -0x28(%ebp)
8010514b:	ff 70 10             	pushl  0x10(%eax)
8010514e:	68 24 6e 10 80       	push   $0x80106e24
80105153:	e8 b3 b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105158:	83 c4 20             	add    $0x20,%esp
8010515b:	e8 c0 e1 ff ff       	call   80103320 <myproc>
80105160:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105167:	e9 a4 fe ff ff       	jmp    80105010 <trap+0x66>
8010516c:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010516f:	8b 73 38             	mov    0x38(%ebx),%esi
80105172:	e8 8e e1 ff ff       	call   80103305 <cpuid>
80105177:	83 ec 0c             	sub    $0xc,%esp
8010517a:	57                   	push   %edi
8010517b:	56                   	push   %esi
8010517c:	50                   	push   %eax
8010517d:	ff 73 30             	pushl  0x30(%ebx)
80105180:	68 f0 6d 10 80       	push   $0x80106df0
80105185:	e8 81 b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
8010518a:	83 c4 14             	add    $0x14,%esp
8010518d:	68 c4 6d 10 80       	push   $0x80106dc4
80105192:	e8 b1 b1 ff ff       	call   80100348 <panic>
    exit();
80105197:	e8 30 e5 ff ff       	call   801036cc <exit>
8010519c:	e9 94 fe ff ff       	jmp    80105035 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801051a1:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801051a5:	0f 85 a2 fe ff ff    	jne    8010504d <trap+0xa3>
    yield();
801051ab:	e8 e2 e5 ff ff       	call   80103792 <yield>
801051b0:	e9 98 fe ff ff       	jmp    8010504d <trap+0xa3>
    exit();
801051b5:	e8 12 e5 ff ff       	call   801036cc <exit>
801051ba:	e9 b3 fe ff ff       	jmp    80105072 <trap+0xc8>

801051bf <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801051bf:	55                   	push   %ebp
801051c0:	89 e5                	mov    %esp,%ebp
  if(!uart)
801051c2:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051c9:	74 15                	je     801051e0 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051cb:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051d0:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051d1:	a8 01                	test   $0x1,%al
801051d3:	74 12                	je     801051e7 <uartgetc+0x28>
801051d5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051da:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801051db:	0f b6 c0             	movzbl %al,%eax
}
801051de:	5d                   	pop    %ebp
801051df:	c3                   	ret    
    return -1;
801051e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e5:	eb f7                	jmp    801051de <uartgetc+0x1f>
    return -1;
801051e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ec:	eb f0                	jmp    801051de <uartgetc+0x1f>

801051ee <uartputc>:
  if(!uart)
801051ee:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051f5:	74 3b                	je     80105232 <uartputc+0x44>
{
801051f7:	55                   	push   %ebp
801051f8:	89 e5                	mov    %esp,%ebp
801051fa:	53                   	push   %ebx
801051fb:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051fe:	bb 00 00 00 00       	mov    $0x0,%ebx
80105203:	eb 10                	jmp    80105215 <uartputc+0x27>
    microdelay(10);
80105205:	83 ec 0c             	sub    $0xc,%esp
80105208:	6a 0a                	push   $0xa
8010520a:	e8 d3 d2 ff ff       	call   801024e2 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010520f:	83 c3 01             	add    $0x1,%ebx
80105212:	83 c4 10             	add    $0x10,%esp
80105215:	83 fb 7f             	cmp    $0x7f,%ebx
80105218:	7f 0a                	jg     80105224 <uartputc+0x36>
8010521a:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010521f:	ec                   	in     (%dx),%al
80105220:	a8 20                	test   $0x20,%al
80105222:	74 e1                	je     80105205 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105224:	8b 45 08             	mov    0x8(%ebp),%eax
80105227:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010522c:	ee                   	out    %al,(%dx)
}
8010522d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105230:	c9                   	leave  
80105231:	c3                   	ret    
80105232:	f3 c3                	repz ret 

80105234 <uartinit>:
{
80105234:	55                   	push   %ebp
80105235:	89 e5                	mov    %esp,%ebp
80105237:	56                   	push   %esi
80105238:	53                   	push   %ebx
80105239:	b9 00 00 00 00       	mov    $0x0,%ecx
8010523e:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105243:	89 c8                	mov    %ecx,%eax
80105245:	ee                   	out    %al,(%dx)
80105246:	be fb 03 00 00       	mov    $0x3fb,%esi
8010524b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105250:	89 f2                	mov    %esi,%edx
80105252:	ee                   	out    %al,(%dx)
80105253:	b8 0c 00 00 00       	mov    $0xc,%eax
80105258:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010525d:	ee                   	out    %al,(%dx)
8010525e:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105263:	89 c8                	mov    %ecx,%eax
80105265:	89 da                	mov    %ebx,%edx
80105267:	ee                   	out    %al,(%dx)
80105268:	b8 03 00 00 00       	mov    $0x3,%eax
8010526d:	89 f2                	mov    %esi,%edx
8010526f:	ee                   	out    %al,(%dx)
80105270:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105275:	89 c8                	mov    %ecx,%eax
80105277:	ee                   	out    %al,(%dx)
80105278:	b8 01 00 00 00       	mov    $0x1,%eax
8010527d:	89 da                	mov    %ebx,%edx
8010527f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105280:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105285:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105286:	3c ff                	cmp    $0xff,%al
80105288:	74 45                	je     801052cf <uartinit+0x9b>
  uart = 1;
8010528a:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105291:	00 00 00 
80105294:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105299:	ec                   	in     (%dx),%al
8010529a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010529f:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801052a0:	83 ec 08             	sub    $0x8,%esp
801052a3:	6a 00                	push   $0x0
801052a5:	6a 04                	push   $0x4
801052a7:	e8 fc cd ff ff       	call   801020a8 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801052ac:	83 c4 10             	add    $0x10,%esp
801052af:	bb e8 6e 10 80       	mov    $0x80106ee8,%ebx
801052b4:	eb 12                	jmp    801052c8 <uartinit+0x94>
    uartputc(*p);
801052b6:	83 ec 0c             	sub    $0xc,%esp
801052b9:	0f be c0             	movsbl %al,%eax
801052bc:	50                   	push   %eax
801052bd:	e8 2c ff ff ff       	call   801051ee <uartputc>
  for(p="xv6...\n"; *p; p++)
801052c2:	83 c3 01             	add    $0x1,%ebx
801052c5:	83 c4 10             	add    $0x10,%esp
801052c8:	0f b6 03             	movzbl (%ebx),%eax
801052cb:	84 c0                	test   %al,%al
801052cd:	75 e7                	jne    801052b6 <uartinit+0x82>
}
801052cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052d2:	5b                   	pop    %ebx
801052d3:	5e                   	pop    %esi
801052d4:	5d                   	pop    %ebp
801052d5:	c3                   	ret    

801052d6 <uartintr>:

void
uartintr(void)
{
801052d6:	55                   	push   %ebp
801052d7:	89 e5                	mov    %esp,%ebp
801052d9:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801052dc:	68 bf 51 10 80       	push   $0x801051bf
801052e1:	e8 58 b4 ff ff       	call   8010073e <consoleintr>
}
801052e6:	83 c4 10             	add    $0x10,%esp
801052e9:	c9                   	leave  
801052ea:	c3                   	ret    

801052eb <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801052eb:	6a 00                	push   $0x0
  pushl $0
801052ed:	6a 00                	push   $0x0
  jmp alltraps
801052ef:	e9 be fb ff ff       	jmp    80104eb2 <alltraps>

801052f4 <vector1>:
.globl vector1
vector1:
  pushl $0
801052f4:	6a 00                	push   $0x0
  pushl $1
801052f6:	6a 01                	push   $0x1
  jmp alltraps
801052f8:	e9 b5 fb ff ff       	jmp    80104eb2 <alltraps>

801052fd <vector2>:
.globl vector2
vector2:
  pushl $0
801052fd:	6a 00                	push   $0x0
  pushl $2
801052ff:	6a 02                	push   $0x2
  jmp alltraps
80105301:	e9 ac fb ff ff       	jmp    80104eb2 <alltraps>

80105306 <vector3>:
.globl vector3
vector3:
  pushl $0
80105306:	6a 00                	push   $0x0
  pushl $3
80105308:	6a 03                	push   $0x3
  jmp alltraps
8010530a:	e9 a3 fb ff ff       	jmp    80104eb2 <alltraps>

8010530f <vector4>:
.globl vector4
vector4:
  pushl $0
8010530f:	6a 00                	push   $0x0
  pushl $4
80105311:	6a 04                	push   $0x4
  jmp alltraps
80105313:	e9 9a fb ff ff       	jmp    80104eb2 <alltraps>

80105318 <vector5>:
.globl vector5
vector5:
  pushl $0
80105318:	6a 00                	push   $0x0
  pushl $5
8010531a:	6a 05                	push   $0x5
  jmp alltraps
8010531c:	e9 91 fb ff ff       	jmp    80104eb2 <alltraps>

80105321 <vector6>:
.globl vector6
vector6:
  pushl $0
80105321:	6a 00                	push   $0x0
  pushl $6
80105323:	6a 06                	push   $0x6
  jmp alltraps
80105325:	e9 88 fb ff ff       	jmp    80104eb2 <alltraps>

8010532a <vector7>:
.globl vector7
vector7:
  pushl $0
8010532a:	6a 00                	push   $0x0
  pushl $7
8010532c:	6a 07                	push   $0x7
  jmp alltraps
8010532e:	e9 7f fb ff ff       	jmp    80104eb2 <alltraps>

80105333 <vector8>:
.globl vector8
vector8:
  pushl $8
80105333:	6a 08                	push   $0x8
  jmp alltraps
80105335:	e9 78 fb ff ff       	jmp    80104eb2 <alltraps>

8010533a <vector9>:
.globl vector9
vector9:
  pushl $0
8010533a:	6a 00                	push   $0x0
  pushl $9
8010533c:	6a 09                	push   $0x9
  jmp alltraps
8010533e:	e9 6f fb ff ff       	jmp    80104eb2 <alltraps>

80105343 <vector10>:
.globl vector10
vector10:
  pushl $10
80105343:	6a 0a                	push   $0xa
  jmp alltraps
80105345:	e9 68 fb ff ff       	jmp    80104eb2 <alltraps>

8010534a <vector11>:
.globl vector11
vector11:
  pushl $11
8010534a:	6a 0b                	push   $0xb
  jmp alltraps
8010534c:	e9 61 fb ff ff       	jmp    80104eb2 <alltraps>

80105351 <vector12>:
.globl vector12
vector12:
  pushl $12
80105351:	6a 0c                	push   $0xc
  jmp alltraps
80105353:	e9 5a fb ff ff       	jmp    80104eb2 <alltraps>

80105358 <vector13>:
.globl vector13
vector13:
  pushl $13
80105358:	6a 0d                	push   $0xd
  jmp alltraps
8010535a:	e9 53 fb ff ff       	jmp    80104eb2 <alltraps>

8010535f <vector14>:
.globl vector14
vector14:
  pushl $14
8010535f:	6a 0e                	push   $0xe
  jmp alltraps
80105361:	e9 4c fb ff ff       	jmp    80104eb2 <alltraps>

80105366 <vector15>:
.globl vector15
vector15:
  pushl $0
80105366:	6a 00                	push   $0x0
  pushl $15
80105368:	6a 0f                	push   $0xf
  jmp alltraps
8010536a:	e9 43 fb ff ff       	jmp    80104eb2 <alltraps>

8010536f <vector16>:
.globl vector16
vector16:
  pushl $0
8010536f:	6a 00                	push   $0x0
  pushl $16
80105371:	6a 10                	push   $0x10
  jmp alltraps
80105373:	e9 3a fb ff ff       	jmp    80104eb2 <alltraps>

80105378 <vector17>:
.globl vector17
vector17:
  pushl $17
80105378:	6a 11                	push   $0x11
  jmp alltraps
8010537a:	e9 33 fb ff ff       	jmp    80104eb2 <alltraps>

8010537f <vector18>:
.globl vector18
vector18:
  pushl $0
8010537f:	6a 00                	push   $0x0
  pushl $18
80105381:	6a 12                	push   $0x12
  jmp alltraps
80105383:	e9 2a fb ff ff       	jmp    80104eb2 <alltraps>

80105388 <vector19>:
.globl vector19
vector19:
  pushl $0
80105388:	6a 00                	push   $0x0
  pushl $19
8010538a:	6a 13                	push   $0x13
  jmp alltraps
8010538c:	e9 21 fb ff ff       	jmp    80104eb2 <alltraps>

80105391 <vector20>:
.globl vector20
vector20:
  pushl $0
80105391:	6a 00                	push   $0x0
  pushl $20
80105393:	6a 14                	push   $0x14
  jmp alltraps
80105395:	e9 18 fb ff ff       	jmp    80104eb2 <alltraps>

8010539a <vector21>:
.globl vector21
vector21:
  pushl $0
8010539a:	6a 00                	push   $0x0
  pushl $21
8010539c:	6a 15                	push   $0x15
  jmp alltraps
8010539e:	e9 0f fb ff ff       	jmp    80104eb2 <alltraps>

801053a3 <vector22>:
.globl vector22
vector22:
  pushl $0
801053a3:	6a 00                	push   $0x0
  pushl $22
801053a5:	6a 16                	push   $0x16
  jmp alltraps
801053a7:	e9 06 fb ff ff       	jmp    80104eb2 <alltraps>

801053ac <vector23>:
.globl vector23
vector23:
  pushl $0
801053ac:	6a 00                	push   $0x0
  pushl $23
801053ae:	6a 17                	push   $0x17
  jmp alltraps
801053b0:	e9 fd fa ff ff       	jmp    80104eb2 <alltraps>

801053b5 <vector24>:
.globl vector24
vector24:
  pushl $0
801053b5:	6a 00                	push   $0x0
  pushl $24
801053b7:	6a 18                	push   $0x18
  jmp alltraps
801053b9:	e9 f4 fa ff ff       	jmp    80104eb2 <alltraps>

801053be <vector25>:
.globl vector25
vector25:
  pushl $0
801053be:	6a 00                	push   $0x0
  pushl $25
801053c0:	6a 19                	push   $0x19
  jmp alltraps
801053c2:	e9 eb fa ff ff       	jmp    80104eb2 <alltraps>

801053c7 <vector26>:
.globl vector26
vector26:
  pushl $0
801053c7:	6a 00                	push   $0x0
  pushl $26
801053c9:	6a 1a                	push   $0x1a
  jmp alltraps
801053cb:	e9 e2 fa ff ff       	jmp    80104eb2 <alltraps>

801053d0 <vector27>:
.globl vector27
vector27:
  pushl $0
801053d0:	6a 00                	push   $0x0
  pushl $27
801053d2:	6a 1b                	push   $0x1b
  jmp alltraps
801053d4:	e9 d9 fa ff ff       	jmp    80104eb2 <alltraps>

801053d9 <vector28>:
.globl vector28
vector28:
  pushl $0
801053d9:	6a 00                	push   $0x0
  pushl $28
801053db:	6a 1c                	push   $0x1c
  jmp alltraps
801053dd:	e9 d0 fa ff ff       	jmp    80104eb2 <alltraps>

801053e2 <vector29>:
.globl vector29
vector29:
  pushl $0
801053e2:	6a 00                	push   $0x0
  pushl $29
801053e4:	6a 1d                	push   $0x1d
  jmp alltraps
801053e6:	e9 c7 fa ff ff       	jmp    80104eb2 <alltraps>

801053eb <vector30>:
.globl vector30
vector30:
  pushl $0
801053eb:	6a 00                	push   $0x0
  pushl $30
801053ed:	6a 1e                	push   $0x1e
  jmp alltraps
801053ef:	e9 be fa ff ff       	jmp    80104eb2 <alltraps>

801053f4 <vector31>:
.globl vector31
vector31:
  pushl $0
801053f4:	6a 00                	push   $0x0
  pushl $31
801053f6:	6a 1f                	push   $0x1f
  jmp alltraps
801053f8:	e9 b5 fa ff ff       	jmp    80104eb2 <alltraps>

801053fd <vector32>:
.globl vector32
vector32:
  pushl $0
801053fd:	6a 00                	push   $0x0
  pushl $32
801053ff:	6a 20                	push   $0x20
  jmp alltraps
80105401:	e9 ac fa ff ff       	jmp    80104eb2 <alltraps>

80105406 <vector33>:
.globl vector33
vector33:
  pushl $0
80105406:	6a 00                	push   $0x0
  pushl $33
80105408:	6a 21                	push   $0x21
  jmp alltraps
8010540a:	e9 a3 fa ff ff       	jmp    80104eb2 <alltraps>

8010540f <vector34>:
.globl vector34
vector34:
  pushl $0
8010540f:	6a 00                	push   $0x0
  pushl $34
80105411:	6a 22                	push   $0x22
  jmp alltraps
80105413:	e9 9a fa ff ff       	jmp    80104eb2 <alltraps>

80105418 <vector35>:
.globl vector35
vector35:
  pushl $0
80105418:	6a 00                	push   $0x0
  pushl $35
8010541a:	6a 23                	push   $0x23
  jmp alltraps
8010541c:	e9 91 fa ff ff       	jmp    80104eb2 <alltraps>

80105421 <vector36>:
.globl vector36
vector36:
  pushl $0
80105421:	6a 00                	push   $0x0
  pushl $36
80105423:	6a 24                	push   $0x24
  jmp alltraps
80105425:	e9 88 fa ff ff       	jmp    80104eb2 <alltraps>

8010542a <vector37>:
.globl vector37
vector37:
  pushl $0
8010542a:	6a 00                	push   $0x0
  pushl $37
8010542c:	6a 25                	push   $0x25
  jmp alltraps
8010542e:	e9 7f fa ff ff       	jmp    80104eb2 <alltraps>

80105433 <vector38>:
.globl vector38
vector38:
  pushl $0
80105433:	6a 00                	push   $0x0
  pushl $38
80105435:	6a 26                	push   $0x26
  jmp alltraps
80105437:	e9 76 fa ff ff       	jmp    80104eb2 <alltraps>

8010543c <vector39>:
.globl vector39
vector39:
  pushl $0
8010543c:	6a 00                	push   $0x0
  pushl $39
8010543e:	6a 27                	push   $0x27
  jmp alltraps
80105440:	e9 6d fa ff ff       	jmp    80104eb2 <alltraps>

80105445 <vector40>:
.globl vector40
vector40:
  pushl $0
80105445:	6a 00                	push   $0x0
  pushl $40
80105447:	6a 28                	push   $0x28
  jmp alltraps
80105449:	e9 64 fa ff ff       	jmp    80104eb2 <alltraps>

8010544e <vector41>:
.globl vector41
vector41:
  pushl $0
8010544e:	6a 00                	push   $0x0
  pushl $41
80105450:	6a 29                	push   $0x29
  jmp alltraps
80105452:	e9 5b fa ff ff       	jmp    80104eb2 <alltraps>

80105457 <vector42>:
.globl vector42
vector42:
  pushl $0
80105457:	6a 00                	push   $0x0
  pushl $42
80105459:	6a 2a                	push   $0x2a
  jmp alltraps
8010545b:	e9 52 fa ff ff       	jmp    80104eb2 <alltraps>

80105460 <vector43>:
.globl vector43
vector43:
  pushl $0
80105460:	6a 00                	push   $0x0
  pushl $43
80105462:	6a 2b                	push   $0x2b
  jmp alltraps
80105464:	e9 49 fa ff ff       	jmp    80104eb2 <alltraps>

80105469 <vector44>:
.globl vector44
vector44:
  pushl $0
80105469:	6a 00                	push   $0x0
  pushl $44
8010546b:	6a 2c                	push   $0x2c
  jmp alltraps
8010546d:	e9 40 fa ff ff       	jmp    80104eb2 <alltraps>

80105472 <vector45>:
.globl vector45
vector45:
  pushl $0
80105472:	6a 00                	push   $0x0
  pushl $45
80105474:	6a 2d                	push   $0x2d
  jmp alltraps
80105476:	e9 37 fa ff ff       	jmp    80104eb2 <alltraps>

8010547b <vector46>:
.globl vector46
vector46:
  pushl $0
8010547b:	6a 00                	push   $0x0
  pushl $46
8010547d:	6a 2e                	push   $0x2e
  jmp alltraps
8010547f:	e9 2e fa ff ff       	jmp    80104eb2 <alltraps>

80105484 <vector47>:
.globl vector47
vector47:
  pushl $0
80105484:	6a 00                	push   $0x0
  pushl $47
80105486:	6a 2f                	push   $0x2f
  jmp alltraps
80105488:	e9 25 fa ff ff       	jmp    80104eb2 <alltraps>

8010548d <vector48>:
.globl vector48
vector48:
  pushl $0
8010548d:	6a 00                	push   $0x0
  pushl $48
8010548f:	6a 30                	push   $0x30
  jmp alltraps
80105491:	e9 1c fa ff ff       	jmp    80104eb2 <alltraps>

80105496 <vector49>:
.globl vector49
vector49:
  pushl $0
80105496:	6a 00                	push   $0x0
  pushl $49
80105498:	6a 31                	push   $0x31
  jmp alltraps
8010549a:	e9 13 fa ff ff       	jmp    80104eb2 <alltraps>

8010549f <vector50>:
.globl vector50
vector50:
  pushl $0
8010549f:	6a 00                	push   $0x0
  pushl $50
801054a1:	6a 32                	push   $0x32
  jmp alltraps
801054a3:	e9 0a fa ff ff       	jmp    80104eb2 <alltraps>

801054a8 <vector51>:
.globl vector51
vector51:
  pushl $0
801054a8:	6a 00                	push   $0x0
  pushl $51
801054aa:	6a 33                	push   $0x33
  jmp alltraps
801054ac:	e9 01 fa ff ff       	jmp    80104eb2 <alltraps>

801054b1 <vector52>:
.globl vector52
vector52:
  pushl $0
801054b1:	6a 00                	push   $0x0
  pushl $52
801054b3:	6a 34                	push   $0x34
  jmp alltraps
801054b5:	e9 f8 f9 ff ff       	jmp    80104eb2 <alltraps>

801054ba <vector53>:
.globl vector53
vector53:
  pushl $0
801054ba:	6a 00                	push   $0x0
  pushl $53
801054bc:	6a 35                	push   $0x35
  jmp alltraps
801054be:	e9 ef f9 ff ff       	jmp    80104eb2 <alltraps>

801054c3 <vector54>:
.globl vector54
vector54:
  pushl $0
801054c3:	6a 00                	push   $0x0
  pushl $54
801054c5:	6a 36                	push   $0x36
  jmp alltraps
801054c7:	e9 e6 f9 ff ff       	jmp    80104eb2 <alltraps>

801054cc <vector55>:
.globl vector55
vector55:
  pushl $0
801054cc:	6a 00                	push   $0x0
  pushl $55
801054ce:	6a 37                	push   $0x37
  jmp alltraps
801054d0:	e9 dd f9 ff ff       	jmp    80104eb2 <alltraps>

801054d5 <vector56>:
.globl vector56
vector56:
  pushl $0
801054d5:	6a 00                	push   $0x0
  pushl $56
801054d7:	6a 38                	push   $0x38
  jmp alltraps
801054d9:	e9 d4 f9 ff ff       	jmp    80104eb2 <alltraps>

801054de <vector57>:
.globl vector57
vector57:
  pushl $0
801054de:	6a 00                	push   $0x0
  pushl $57
801054e0:	6a 39                	push   $0x39
  jmp alltraps
801054e2:	e9 cb f9 ff ff       	jmp    80104eb2 <alltraps>

801054e7 <vector58>:
.globl vector58
vector58:
  pushl $0
801054e7:	6a 00                	push   $0x0
  pushl $58
801054e9:	6a 3a                	push   $0x3a
  jmp alltraps
801054eb:	e9 c2 f9 ff ff       	jmp    80104eb2 <alltraps>

801054f0 <vector59>:
.globl vector59
vector59:
  pushl $0
801054f0:	6a 00                	push   $0x0
  pushl $59
801054f2:	6a 3b                	push   $0x3b
  jmp alltraps
801054f4:	e9 b9 f9 ff ff       	jmp    80104eb2 <alltraps>

801054f9 <vector60>:
.globl vector60
vector60:
  pushl $0
801054f9:	6a 00                	push   $0x0
  pushl $60
801054fb:	6a 3c                	push   $0x3c
  jmp alltraps
801054fd:	e9 b0 f9 ff ff       	jmp    80104eb2 <alltraps>

80105502 <vector61>:
.globl vector61
vector61:
  pushl $0
80105502:	6a 00                	push   $0x0
  pushl $61
80105504:	6a 3d                	push   $0x3d
  jmp alltraps
80105506:	e9 a7 f9 ff ff       	jmp    80104eb2 <alltraps>

8010550b <vector62>:
.globl vector62
vector62:
  pushl $0
8010550b:	6a 00                	push   $0x0
  pushl $62
8010550d:	6a 3e                	push   $0x3e
  jmp alltraps
8010550f:	e9 9e f9 ff ff       	jmp    80104eb2 <alltraps>

80105514 <vector63>:
.globl vector63
vector63:
  pushl $0
80105514:	6a 00                	push   $0x0
  pushl $63
80105516:	6a 3f                	push   $0x3f
  jmp alltraps
80105518:	e9 95 f9 ff ff       	jmp    80104eb2 <alltraps>

8010551d <vector64>:
.globl vector64
vector64:
  pushl $0
8010551d:	6a 00                	push   $0x0
  pushl $64
8010551f:	6a 40                	push   $0x40
  jmp alltraps
80105521:	e9 8c f9 ff ff       	jmp    80104eb2 <alltraps>

80105526 <vector65>:
.globl vector65
vector65:
  pushl $0
80105526:	6a 00                	push   $0x0
  pushl $65
80105528:	6a 41                	push   $0x41
  jmp alltraps
8010552a:	e9 83 f9 ff ff       	jmp    80104eb2 <alltraps>

8010552f <vector66>:
.globl vector66
vector66:
  pushl $0
8010552f:	6a 00                	push   $0x0
  pushl $66
80105531:	6a 42                	push   $0x42
  jmp alltraps
80105533:	e9 7a f9 ff ff       	jmp    80104eb2 <alltraps>

80105538 <vector67>:
.globl vector67
vector67:
  pushl $0
80105538:	6a 00                	push   $0x0
  pushl $67
8010553a:	6a 43                	push   $0x43
  jmp alltraps
8010553c:	e9 71 f9 ff ff       	jmp    80104eb2 <alltraps>

80105541 <vector68>:
.globl vector68
vector68:
  pushl $0
80105541:	6a 00                	push   $0x0
  pushl $68
80105543:	6a 44                	push   $0x44
  jmp alltraps
80105545:	e9 68 f9 ff ff       	jmp    80104eb2 <alltraps>

8010554a <vector69>:
.globl vector69
vector69:
  pushl $0
8010554a:	6a 00                	push   $0x0
  pushl $69
8010554c:	6a 45                	push   $0x45
  jmp alltraps
8010554e:	e9 5f f9 ff ff       	jmp    80104eb2 <alltraps>

80105553 <vector70>:
.globl vector70
vector70:
  pushl $0
80105553:	6a 00                	push   $0x0
  pushl $70
80105555:	6a 46                	push   $0x46
  jmp alltraps
80105557:	e9 56 f9 ff ff       	jmp    80104eb2 <alltraps>

8010555c <vector71>:
.globl vector71
vector71:
  pushl $0
8010555c:	6a 00                	push   $0x0
  pushl $71
8010555e:	6a 47                	push   $0x47
  jmp alltraps
80105560:	e9 4d f9 ff ff       	jmp    80104eb2 <alltraps>

80105565 <vector72>:
.globl vector72
vector72:
  pushl $0
80105565:	6a 00                	push   $0x0
  pushl $72
80105567:	6a 48                	push   $0x48
  jmp alltraps
80105569:	e9 44 f9 ff ff       	jmp    80104eb2 <alltraps>

8010556e <vector73>:
.globl vector73
vector73:
  pushl $0
8010556e:	6a 00                	push   $0x0
  pushl $73
80105570:	6a 49                	push   $0x49
  jmp alltraps
80105572:	e9 3b f9 ff ff       	jmp    80104eb2 <alltraps>

80105577 <vector74>:
.globl vector74
vector74:
  pushl $0
80105577:	6a 00                	push   $0x0
  pushl $74
80105579:	6a 4a                	push   $0x4a
  jmp alltraps
8010557b:	e9 32 f9 ff ff       	jmp    80104eb2 <alltraps>

80105580 <vector75>:
.globl vector75
vector75:
  pushl $0
80105580:	6a 00                	push   $0x0
  pushl $75
80105582:	6a 4b                	push   $0x4b
  jmp alltraps
80105584:	e9 29 f9 ff ff       	jmp    80104eb2 <alltraps>

80105589 <vector76>:
.globl vector76
vector76:
  pushl $0
80105589:	6a 00                	push   $0x0
  pushl $76
8010558b:	6a 4c                	push   $0x4c
  jmp alltraps
8010558d:	e9 20 f9 ff ff       	jmp    80104eb2 <alltraps>

80105592 <vector77>:
.globl vector77
vector77:
  pushl $0
80105592:	6a 00                	push   $0x0
  pushl $77
80105594:	6a 4d                	push   $0x4d
  jmp alltraps
80105596:	e9 17 f9 ff ff       	jmp    80104eb2 <alltraps>

8010559b <vector78>:
.globl vector78
vector78:
  pushl $0
8010559b:	6a 00                	push   $0x0
  pushl $78
8010559d:	6a 4e                	push   $0x4e
  jmp alltraps
8010559f:	e9 0e f9 ff ff       	jmp    80104eb2 <alltraps>

801055a4 <vector79>:
.globl vector79
vector79:
  pushl $0
801055a4:	6a 00                	push   $0x0
  pushl $79
801055a6:	6a 4f                	push   $0x4f
  jmp alltraps
801055a8:	e9 05 f9 ff ff       	jmp    80104eb2 <alltraps>

801055ad <vector80>:
.globl vector80
vector80:
  pushl $0
801055ad:	6a 00                	push   $0x0
  pushl $80
801055af:	6a 50                	push   $0x50
  jmp alltraps
801055b1:	e9 fc f8 ff ff       	jmp    80104eb2 <alltraps>

801055b6 <vector81>:
.globl vector81
vector81:
  pushl $0
801055b6:	6a 00                	push   $0x0
  pushl $81
801055b8:	6a 51                	push   $0x51
  jmp alltraps
801055ba:	e9 f3 f8 ff ff       	jmp    80104eb2 <alltraps>

801055bf <vector82>:
.globl vector82
vector82:
  pushl $0
801055bf:	6a 00                	push   $0x0
  pushl $82
801055c1:	6a 52                	push   $0x52
  jmp alltraps
801055c3:	e9 ea f8 ff ff       	jmp    80104eb2 <alltraps>

801055c8 <vector83>:
.globl vector83
vector83:
  pushl $0
801055c8:	6a 00                	push   $0x0
  pushl $83
801055ca:	6a 53                	push   $0x53
  jmp alltraps
801055cc:	e9 e1 f8 ff ff       	jmp    80104eb2 <alltraps>

801055d1 <vector84>:
.globl vector84
vector84:
  pushl $0
801055d1:	6a 00                	push   $0x0
  pushl $84
801055d3:	6a 54                	push   $0x54
  jmp alltraps
801055d5:	e9 d8 f8 ff ff       	jmp    80104eb2 <alltraps>

801055da <vector85>:
.globl vector85
vector85:
  pushl $0
801055da:	6a 00                	push   $0x0
  pushl $85
801055dc:	6a 55                	push   $0x55
  jmp alltraps
801055de:	e9 cf f8 ff ff       	jmp    80104eb2 <alltraps>

801055e3 <vector86>:
.globl vector86
vector86:
  pushl $0
801055e3:	6a 00                	push   $0x0
  pushl $86
801055e5:	6a 56                	push   $0x56
  jmp alltraps
801055e7:	e9 c6 f8 ff ff       	jmp    80104eb2 <alltraps>

801055ec <vector87>:
.globl vector87
vector87:
  pushl $0
801055ec:	6a 00                	push   $0x0
  pushl $87
801055ee:	6a 57                	push   $0x57
  jmp alltraps
801055f0:	e9 bd f8 ff ff       	jmp    80104eb2 <alltraps>

801055f5 <vector88>:
.globl vector88
vector88:
  pushl $0
801055f5:	6a 00                	push   $0x0
  pushl $88
801055f7:	6a 58                	push   $0x58
  jmp alltraps
801055f9:	e9 b4 f8 ff ff       	jmp    80104eb2 <alltraps>

801055fe <vector89>:
.globl vector89
vector89:
  pushl $0
801055fe:	6a 00                	push   $0x0
  pushl $89
80105600:	6a 59                	push   $0x59
  jmp alltraps
80105602:	e9 ab f8 ff ff       	jmp    80104eb2 <alltraps>

80105607 <vector90>:
.globl vector90
vector90:
  pushl $0
80105607:	6a 00                	push   $0x0
  pushl $90
80105609:	6a 5a                	push   $0x5a
  jmp alltraps
8010560b:	e9 a2 f8 ff ff       	jmp    80104eb2 <alltraps>

80105610 <vector91>:
.globl vector91
vector91:
  pushl $0
80105610:	6a 00                	push   $0x0
  pushl $91
80105612:	6a 5b                	push   $0x5b
  jmp alltraps
80105614:	e9 99 f8 ff ff       	jmp    80104eb2 <alltraps>

80105619 <vector92>:
.globl vector92
vector92:
  pushl $0
80105619:	6a 00                	push   $0x0
  pushl $92
8010561b:	6a 5c                	push   $0x5c
  jmp alltraps
8010561d:	e9 90 f8 ff ff       	jmp    80104eb2 <alltraps>

80105622 <vector93>:
.globl vector93
vector93:
  pushl $0
80105622:	6a 00                	push   $0x0
  pushl $93
80105624:	6a 5d                	push   $0x5d
  jmp alltraps
80105626:	e9 87 f8 ff ff       	jmp    80104eb2 <alltraps>

8010562b <vector94>:
.globl vector94
vector94:
  pushl $0
8010562b:	6a 00                	push   $0x0
  pushl $94
8010562d:	6a 5e                	push   $0x5e
  jmp alltraps
8010562f:	e9 7e f8 ff ff       	jmp    80104eb2 <alltraps>

80105634 <vector95>:
.globl vector95
vector95:
  pushl $0
80105634:	6a 00                	push   $0x0
  pushl $95
80105636:	6a 5f                	push   $0x5f
  jmp alltraps
80105638:	e9 75 f8 ff ff       	jmp    80104eb2 <alltraps>

8010563d <vector96>:
.globl vector96
vector96:
  pushl $0
8010563d:	6a 00                	push   $0x0
  pushl $96
8010563f:	6a 60                	push   $0x60
  jmp alltraps
80105641:	e9 6c f8 ff ff       	jmp    80104eb2 <alltraps>

80105646 <vector97>:
.globl vector97
vector97:
  pushl $0
80105646:	6a 00                	push   $0x0
  pushl $97
80105648:	6a 61                	push   $0x61
  jmp alltraps
8010564a:	e9 63 f8 ff ff       	jmp    80104eb2 <alltraps>

8010564f <vector98>:
.globl vector98
vector98:
  pushl $0
8010564f:	6a 00                	push   $0x0
  pushl $98
80105651:	6a 62                	push   $0x62
  jmp alltraps
80105653:	e9 5a f8 ff ff       	jmp    80104eb2 <alltraps>

80105658 <vector99>:
.globl vector99
vector99:
  pushl $0
80105658:	6a 00                	push   $0x0
  pushl $99
8010565a:	6a 63                	push   $0x63
  jmp alltraps
8010565c:	e9 51 f8 ff ff       	jmp    80104eb2 <alltraps>

80105661 <vector100>:
.globl vector100
vector100:
  pushl $0
80105661:	6a 00                	push   $0x0
  pushl $100
80105663:	6a 64                	push   $0x64
  jmp alltraps
80105665:	e9 48 f8 ff ff       	jmp    80104eb2 <alltraps>

8010566a <vector101>:
.globl vector101
vector101:
  pushl $0
8010566a:	6a 00                	push   $0x0
  pushl $101
8010566c:	6a 65                	push   $0x65
  jmp alltraps
8010566e:	e9 3f f8 ff ff       	jmp    80104eb2 <alltraps>

80105673 <vector102>:
.globl vector102
vector102:
  pushl $0
80105673:	6a 00                	push   $0x0
  pushl $102
80105675:	6a 66                	push   $0x66
  jmp alltraps
80105677:	e9 36 f8 ff ff       	jmp    80104eb2 <alltraps>

8010567c <vector103>:
.globl vector103
vector103:
  pushl $0
8010567c:	6a 00                	push   $0x0
  pushl $103
8010567e:	6a 67                	push   $0x67
  jmp alltraps
80105680:	e9 2d f8 ff ff       	jmp    80104eb2 <alltraps>

80105685 <vector104>:
.globl vector104
vector104:
  pushl $0
80105685:	6a 00                	push   $0x0
  pushl $104
80105687:	6a 68                	push   $0x68
  jmp alltraps
80105689:	e9 24 f8 ff ff       	jmp    80104eb2 <alltraps>

8010568e <vector105>:
.globl vector105
vector105:
  pushl $0
8010568e:	6a 00                	push   $0x0
  pushl $105
80105690:	6a 69                	push   $0x69
  jmp alltraps
80105692:	e9 1b f8 ff ff       	jmp    80104eb2 <alltraps>

80105697 <vector106>:
.globl vector106
vector106:
  pushl $0
80105697:	6a 00                	push   $0x0
  pushl $106
80105699:	6a 6a                	push   $0x6a
  jmp alltraps
8010569b:	e9 12 f8 ff ff       	jmp    80104eb2 <alltraps>

801056a0 <vector107>:
.globl vector107
vector107:
  pushl $0
801056a0:	6a 00                	push   $0x0
  pushl $107
801056a2:	6a 6b                	push   $0x6b
  jmp alltraps
801056a4:	e9 09 f8 ff ff       	jmp    80104eb2 <alltraps>

801056a9 <vector108>:
.globl vector108
vector108:
  pushl $0
801056a9:	6a 00                	push   $0x0
  pushl $108
801056ab:	6a 6c                	push   $0x6c
  jmp alltraps
801056ad:	e9 00 f8 ff ff       	jmp    80104eb2 <alltraps>

801056b2 <vector109>:
.globl vector109
vector109:
  pushl $0
801056b2:	6a 00                	push   $0x0
  pushl $109
801056b4:	6a 6d                	push   $0x6d
  jmp alltraps
801056b6:	e9 f7 f7 ff ff       	jmp    80104eb2 <alltraps>

801056bb <vector110>:
.globl vector110
vector110:
  pushl $0
801056bb:	6a 00                	push   $0x0
  pushl $110
801056bd:	6a 6e                	push   $0x6e
  jmp alltraps
801056bf:	e9 ee f7 ff ff       	jmp    80104eb2 <alltraps>

801056c4 <vector111>:
.globl vector111
vector111:
  pushl $0
801056c4:	6a 00                	push   $0x0
  pushl $111
801056c6:	6a 6f                	push   $0x6f
  jmp alltraps
801056c8:	e9 e5 f7 ff ff       	jmp    80104eb2 <alltraps>

801056cd <vector112>:
.globl vector112
vector112:
  pushl $0
801056cd:	6a 00                	push   $0x0
  pushl $112
801056cf:	6a 70                	push   $0x70
  jmp alltraps
801056d1:	e9 dc f7 ff ff       	jmp    80104eb2 <alltraps>

801056d6 <vector113>:
.globl vector113
vector113:
  pushl $0
801056d6:	6a 00                	push   $0x0
  pushl $113
801056d8:	6a 71                	push   $0x71
  jmp alltraps
801056da:	e9 d3 f7 ff ff       	jmp    80104eb2 <alltraps>

801056df <vector114>:
.globl vector114
vector114:
  pushl $0
801056df:	6a 00                	push   $0x0
  pushl $114
801056e1:	6a 72                	push   $0x72
  jmp alltraps
801056e3:	e9 ca f7 ff ff       	jmp    80104eb2 <alltraps>

801056e8 <vector115>:
.globl vector115
vector115:
  pushl $0
801056e8:	6a 00                	push   $0x0
  pushl $115
801056ea:	6a 73                	push   $0x73
  jmp alltraps
801056ec:	e9 c1 f7 ff ff       	jmp    80104eb2 <alltraps>

801056f1 <vector116>:
.globl vector116
vector116:
  pushl $0
801056f1:	6a 00                	push   $0x0
  pushl $116
801056f3:	6a 74                	push   $0x74
  jmp alltraps
801056f5:	e9 b8 f7 ff ff       	jmp    80104eb2 <alltraps>

801056fa <vector117>:
.globl vector117
vector117:
  pushl $0
801056fa:	6a 00                	push   $0x0
  pushl $117
801056fc:	6a 75                	push   $0x75
  jmp alltraps
801056fe:	e9 af f7 ff ff       	jmp    80104eb2 <alltraps>

80105703 <vector118>:
.globl vector118
vector118:
  pushl $0
80105703:	6a 00                	push   $0x0
  pushl $118
80105705:	6a 76                	push   $0x76
  jmp alltraps
80105707:	e9 a6 f7 ff ff       	jmp    80104eb2 <alltraps>

8010570c <vector119>:
.globl vector119
vector119:
  pushl $0
8010570c:	6a 00                	push   $0x0
  pushl $119
8010570e:	6a 77                	push   $0x77
  jmp alltraps
80105710:	e9 9d f7 ff ff       	jmp    80104eb2 <alltraps>

80105715 <vector120>:
.globl vector120
vector120:
  pushl $0
80105715:	6a 00                	push   $0x0
  pushl $120
80105717:	6a 78                	push   $0x78
  jmp alltraps
80105719:	e9 94 f7 ff ff       	jmp    80104eb2 <alltraps>

8010571e <vector121>:
.globl vector121
vector121:
  pushl $0
8010571e:	6a 00                	push   $0x0
  pushl $121
80105720:	6a 79                	push   $0x79
  jmp alltraps
80105722:	e9 8b f7 ff ff       	jmp    80104eb2 <alltraps>

80105727 <vector122>:
.globl vector122
vector122:
  pushl $0
80105727:	6a 00                	push   $0x0
  pushl $122
80105729:	6a 7a                	push   $0x7a
  jmp alltraps
8010572b:	e9 82 f7 ff ff       	jmp    80104eb2 <alltraps>

80105730 <vector123>:
.globl vector123
vector123:
  pushl $0
80105730:	6a 00                	push   $0x0
  pushl $123
80105732:	6a 7b                	push   $0x7b
  jmp alltraps
80105734:	e9 79 f7 ff ff       	jmp    80104eb2 <alltraps>

80105739 <vector124>:
.globl vector124
vector124:
  pushl $0
80105739:	6a 00                	push   $0x0
  pushl $124
8010573b:	6a 7c                	push   $0x7c
  jmp alltraps
8010573d:	e9 70 f7 ff ff       	jmp    80104eb2 <alltraps>

80105742 <vector125>:
.globl vector125
vector125:
  pushl $0
80105742:	6a 00                	push   $0x0
  pushl $125
80105744:	6a 7d                	push   $0x7d
  jmp alltraps
80105746:	e9 67 f7 ff ff       	jmp    80104eb2 <alltraps>

8010574b <vector126>:
.globl vector126
vector126:
  pushl $0
8010574b:	6a 00                	push   $0x0
  pushl $126
8010574d:	6a 7e                	push   $0x7e
  jmp alltraps
8010574f:	e9 5e f7 ff ff       	jmp    80104eb2 <alltraps>

80105754 <vector127>:
.globl vector127
vector127:
  pushl $0
80105754:	6a 00                	push   $0x0
  pushl $127
80105756:	6a 7f                	push   $0x7f
  jmp alltraps
80105758:	e9 55 f7 ff ff       	jmp    80104eb2 <alltraps>

8010575d <vector128>:
.globl vector128
vector128:
  pushl $0
8010575d:	6a 00                	push   $0x0
  pushl $128
8010575f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105764:	e9 49 f7 ff ff       	jmp    80104eb2 <alltraps>

80105769 <vector129>:
.globl vector129
vector129:
  pushl $0
80105769:	6a 00                	push   $0x0
  pushl $129
8010576b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105770:	e9 3d f7 ff ff       	jmp    80104eb2 <alltraps>

80105775 <vector130>:
.globl vector130
vector130:
  pushl $0
80105775:	6a 00                	push   $0x0
  pushl $130
80105777:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010577c:	e9 31 f7 ff ff       	jmp    80104eb2 <alltraps>

80105781 <vector131>:
.globl vector131
vector131:
  pushl $0
80105781:	6a 00                	push   $0x0
  pushl $131
80105783:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105788:	e9 25 f7 ff ff       	jmp    80104eb2 <alltraps>

8010578d <vector132>:
.globl vector132
vector132:
  pushl $0
8010578d:	6a 00                	push   $0x0
  pushl $132
8010578f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105794:	e9 19 f7 ff ff       	jmp    80104eb2 <alltraps>

80105799 <vector133>:
.globl vector133
vector133:
  pushl $0
80105799:	6a 00                	push   $0x0
  pushl $133
8010579b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801057a0:	e9 0d f7 ff ff       	jmp    80104eb2 <alltraps>

801057a5 <vector134>:
.globl vector134
vector134:
  pushl $0
801057a5:	6a 00                	push   $0x0
  pushl $134
801057a7:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801057ac:	e9 01 f7 ff ff       	jmp    80104eb2 <alltraps>

801057b1 <vector135>:
.globl vector135
vector135:
  pushl $0
801057b1:	6a 00                	push   $0x0
  pushl $135
801057b3:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057b8:	e9 f5 f6 ff ff       	jmp    80104eb2 <alltraps>

801057bd <vector136>:
.globl vector136
vector136:
  pushl $0
801057bd:	6a 00                	push   $0x0
  pushl $136
801057bf:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057c4:	e9 e9 f6 ff ff       	jmp    80104eb2 <alltraps>

801057c9 <vector137>:
.globl vector137
vector137:
  pushl $0
801057c9:	6a 00                	push   $0x0
  pushl $137
801057cb:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057d0:	e9 dd f6 ff ff       	jmp    80104eb2 <alltraps>

801057d5 <vector138>:
.globl vector138
vector138:
  pushl $0
801057d5:	6a 00                	push   $0x0
  pushl $138
801057d7:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801057dc:	e9 d1 f6 ff ff       	jmp    80104eb2 <alltraps>

801057e1 <vector139>:
.globl vector139
vector139:
  pushl $0
801057e1:	6a 00                	push   $0x0
  pushl $139
801057e3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801057e8:	e9 c5 f6 ff ff       	jmp    80104eb2 <alltraps>

801057ed <vector140>:
.globl vector140
vector140:
  pushl $0
801057ed:	6a 00                	push   $0x0
  pushl $140
801057ef:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801057f4:	e9 b9 f6 ff ff       	jmp    80104eb2 <alltraps>

801057f9 <vector141>:
.globl vector141
vector141:
  pushl $0
801057f9:	6a 00                	push   $0x0
  pushl $141
801057fb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105800:	e9 ad f6 ff ff       	jmp    80104eb2 <alltraps>

80105805 <vector142>:
.globl vector142
vector142:
  pushl $0
80105805:	6a 00                	push   $0x0
  pushl $142
80105807:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010580c:	e9 a1 f6 ff ff       	jmp    80104eb2 <alltraps>

80105811 <vector143>:
.globl vector143
vector143:
  pushl $0
80105811:	6a 00                	push   $0x0
  pushl $143
80105813:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105818:	e9 95 f6 ff ff       	jmp    80104eb2 <alltraps>

8010581d <vector144>:
.globl vector144
vector144:
  pushl $0
8010581d:	6a 00                	push   $0x0
  pushl $144
8010581f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105824:	e9 89 f6 ff ff       	jmp    80104eb2 <alltraps>

80105829 <vector145>:
.globl vector145
vector145:
  pushl $0
80105829:	6a 00                	push   $0x0
  pushl $145
8010582b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105830:	e9 7d f6 ff ff       	jmp    80104eb2 <alltraps>

80105835 <vector146>:
.globl vector146
vector146:
  pushl $0
80105835:	6a 00                	push   $0x0
  pushl $146
80105837:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010583c:	e9 71 f6 ff ff       	jmp    80104eb2 <alltraps>

80105841 <vector147>:
.globl vector147
vector147:
  pushl $0
80105841:	6a 00                	push   $0x0
  pushl $147
80105843:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105848:	e9 65 f6 ff ff       	jmp    80104eb2 <alltraps>

8010584d <vector148>:
.globl vector148
vector148:
  pushl $0
8010584d:	6a 00                	push   $0x0
  pushl $148
8010584f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105854:	e9 59 f6 ff ff       	jmp    80104eb2 <alltraps>

80105859 <vector149>:
.globl vector149
vector149:
  pushl $0
80105859:	6a 00                	push   $0x0
  pushl $149
8010585b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105860:	e9 4d f6 ff ff       	jmp    80104eb2 <alltraps>

80105865 <vector150>:
.globl vector150
vector150:
  pushl $0
80105865:	6a 00                	push   $0x0
  pushl $150
80105867:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010586c:	e9 41 f6 ff ff       	jmp    80104eb2 <alltraps>

80105871 <vector151>:
.globl vector151
vector151:
  pushl $0
80105871:	6a 00                	push   $0x0
  pushl $151
80105873:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105878:	e9 35 f6 ff ff       	jmp    80104eb2 <alltraps>

8010587d <vector152>:
.globl vector152
vector152:
  pushl $0
8010587d:	6a 00                	push   $0x0
  pushl $152
8010587f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105884:	e9 29 f6 ff ff       	jmp    80104eb2 <alltraps>

80105889 <vector153>:
.globl vector153
vector153:
  pushl $0
80105889:	6a 00                	push   $0x0
  pushl $153
8010588b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105890:	e9 1d f6 ff ff       	jmp    80104eb2 <alltraps>

80105895 <vector154>:
.globl vector154
vector154:
  pushl $0
80105895:	6a 00                	push   $0x0
  pushl $154
80105897:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010589c:	e9 11 f6 ff ff       	jmp    80104eb2 <alltraps>

801058a1 <vector155>:
.globl vector155
vector155:
  pushl $0
801058a1:	6a 00                	push   $0x0
  pushl $155
801058a3:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801058a8:	e9 05 f6 ff ff       	jmp    80104eb2 <alltraps>

801058ad <vector156>:
.globl vector156
vector156:
  pushl $0
801058ad:	6a 00                	push   $0x0
  pushl $156
801058af:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801058b4:	e9 f9 f5 ff ff       	jmp    80104eb2 <alltraps>

801058b9 <vector157>:
.globl vector157
vector157:
  pushl $0
801058b9:	6a 00                	push   $0x0
  pushl $157
801058bb:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058c0:	e9 ed f5 ff ff       	jmp    80104eb2 <alltraps>

801058c5 <vector158>:
.globl vector158
vector158:
  pushl $0
801058c5:	6a 00                	push   $0x0
  pushl $158
801058c7:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058cc:	e9 e1 f5 ff ff       	jmp    80104eb2 <alltraps>

801058d1 <vector159>:
.globl vector159
vector159:
  pushl $0
801058d1:	6a 00                	push   $0x0
  pushl $159
801058d3:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801058d8:	e9 d5 f5 ff ff       	jmp    80104eb2 <alltraps>

801058dd <vector160>:
.globl vector160
vector160:
  pushl $0
801058dd:	6a 00                	push   $0x0
  pushl $160
801058df:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801058e4:	e9 c9 f5 ff ff       	jmp    80104eb2 <alltraps>

801058e9 <vector161>:
.globl vector161
vector161:
  pushl $0
801058e9:	6a 00                	push   $0x0
  pushl $161
801058eb:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801058f0:	e9 bd f5 ff ff       	jmp    80104eb2 <alltraps>

801058f5 <vector162>:
.globl vector162
vector162:
  pushl $0
801058f5:	6a 00                	push   $0x0
  pushl $162
801058f7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801058fc:	e9 b1 f5 ff ff       	jmp    80104eb2 <alltraps>

80105901 <vector163>:
.globl vector163
vector163:
  pushl $0
80105901:	6a 00                	push   $0x0
  pushl $163
80105903:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105908:	e9 a5 f5 ff ff       	jmp    80104eb2 <alltraps>

8010590d <vector164>:
.globl vector164
vector164:
  pushl $0
8010590d:	6a 00                	push   $0x0
  pushl $164
8010590f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105914:	e9 99 f5 ff ff       	jmp    80104eb2 <alltraps>

80105919 <vector165>:
.globl vector165
vector165:
  pushl $0
80105919:	6a 00                	push   $0x0
  pushl $165
8010591b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105920:	e9 8d f5 ff ff       	jmp    80104eb2 <alltraps>

80105925 <vector166>:
.globl vector166
vector166:
  pushl $0
80105925:	6a 00                	push   $0x0
  pushl $166
80105927:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010592c:	e9 81 f5 ff ff       	jmp    80104eb2 <alltraps>

80105931 <vector167>:
.globl vector167
vector167:
  pushl $0
80105931:	6a 00                	push   $0x0
  pushl $167
80105933:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105938:	e9 75 f5 ff ff       	jmp    80104eb2 <alltraps>

8010593d <vector168>:
.globl vector168
vector168:
  pushl $0
8010593d:	6a 00                	push   $0x0
  pushl $168
8010593f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105944:	e9 69 f5 ff ff       	jmp    80104eb2 <alltraps>

80105949 <vector169>:
.globl vector169
vector169:
  pushl $0
80105949:	6a 00                	push   $0x0
  pushl $169
8010594b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105950:	e9 5d f5 ff ff       	jmp    80104eb2 <alltraps>

80105955 <vector170>:
.globl vector170
vector170:
  pushl $0
80105955:	6a 00                	push   $0x0
  pushl $170
80105957:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010595c:	e9 51 f5 ff ff       	jmp    80104eb2 <alltraps>

80105961 <vector171>:
.globl vector171
vector171:
  pushl $0
80105961:	6a 00                	push   $0x0
  pushl $171
80105963:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105968:	e9 45 f5 ff ff       	jmp    80104eb2 <alltraps>

8010596d <vector172>:
.globl vector172
vector172:
  pushl $0
8010596d:	6a 00                	push   $0x0
  pushl $172
8010596f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105974:	e9 39 f5 ff ff       	jmp    80104eb2 <alltraps>

80105979 <vector173>:
.globl vector173
vector173:
  pushl $0
80105979:	6a 00                	push   $0x0
  pushl $173
8010597b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105980:	e9 2d f5 ff ff       	jmp    80104eb2 <alltraps>

80105985 <vector174>:
.globl vector174
vector174:
  pushl $0
80105985:	6a 00                	push   $0x0
  pushl $174
80105987:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010598c:	e9 21 f5 ff ff       	jmp    80104eb2 <alltraps>

80105991 <vector175>:
.globl vector175
vector175:
  pushl $0
80105991:	6a 00                	push   $0x0
  pushl $175
80105993:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105998:	e9 15 f5 ff ff       	jmp    80104eb2 <alltraps>

8010599d <vector176>:
.globl vector176
vector176:
  pushl $0
8010599d:	6a 00                	push   $0x0
  pushl $176
8010599f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801059a4:	e9 09 f5 ff ff       	jmp    80104eb2 <alltraps>

801059a9 <vector177>:
.globl vector177
vector177:
  pushl $0
801059a9:	6a 00                	push   $0x0
  pushl $177
801059ab:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801059b0:	e9 fd f4 ff ff       	jmp    80104eb2 <alltraps>

801059b5 <vector178>:
.globl vector178
vector178:
  pushl $0
801059b5:	6a 00                	push   $0x0
  pushl $178
801059b7:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801059bc:	e9 f1 f4 ff ff       	jmp    80104eb2 <alltraps>

801059c1 <vector179>:
.globl vector179
vector179:
  pushl $0
801059c1:	6a 00                	push   $0x0
  pushl $179
801059c3:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059c8:	e9 e5 f4 ff ff       	jmp    80104eb2 <alltraps>

801059cd <vector180>:
.globl vector180
vector180:
  pushl $0
801059cd:	6a 00                	push   $0x0
  pushl $180
801059cf:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801059d4:	e9 d9 f4 ff ff       	jmp    80104eb2 <alltraps>

801059d9 <vector181>:
.globl vector181
vector181:
  pushl $0
801059d9:	6a 00                	push   $0x0
  pushl $181
801059db:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801059e0:	e9 cd f4 ff ff       	jmp    80104eb2 <alltraps>

801059e5 <vector182>:
.globl vector182
vector182:
  pushl $0
801059e5:	6a 00                	push   $0x0
  pushl $182
801059e7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801059ec:	e9 c1 f4 ff ff       	jmp    80104eb2 <alltraps>

801059f1 <vector183>:
.globl vector183
vector183:
  pushl $0
801059f1:	6a 00                	push   $0x0
  pushl $183
801059f3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801059f8:	e9 b5 f4 ff ff       	jmp    80104eb2 <alltraps>

801059fd <vector184>:
.globl vector184
vector184:
  pushl $0
801059fd:	6a 00                	push   $0x0
  pushl $184
801059ff:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a04:	e9 a9 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a09 <vector185>:
.globl vector185
vector185:
  pushl $0
80105a09:	6a 00                	push   $0x0
  pushl $185
80105a0b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a10:	e9 9d f4 ff ff       	jmp    80104eb2 <alltraps>

80105a15 <vector186>:
.globl vector186
vector186:
  pushl $0
80105a15:	6a 00                	push   $0x0
  pushl $186
80105a17:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a1c:	e9 91 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a21 <vector187>:
.globl vector187
vector187:
  pushl $0
80105a21:	6a 00                	push   $0x0
  pushl $187
80105a23:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a28:	e9 85 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a2d <vector188>:
.globl vector188
vector188:
  pushl $0
80105a2d:	6a 00                	push   $0x0
  pushl $188
80105a2f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a34:	e9 79 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a39 <vector189>:
.globl vector189
vector189:
  pushl $0
80105a39:	6a 00                	push   $0x0
  pushl $189
80105a3b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a40:	e9 6d f4 ff ff       	jmp    80104eb2 <alltraps>

80105a45 <vector190>:
.globl vector190
vector190:
  pushl $0
80105a45:	6a 00                	push   $0x0
  pushl $190
80105a47:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a4c:	e9 61 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a51 <vector191>:
.globl vector191
vector191:
  pushl $0
80105a51:	6a 00                	push   $0x0
  pushl $191
80105a53:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a58:	e9 55 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a5d <vector192>:
.globl vector192
vector192:
  pushl $0
80105a5d:	6a 00                	push   $0x0
  pushl $192
80105a5f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a64:	e9 49 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a69 <vector193>:
.globl vector193
vector193:
  pushl $0
80105a69:	6a 00                	push   $0x0
  pushl $193
80105a6b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a70:	e9 3d f4 ff ff       	jmp    80104eb2 <alltraps>

80105a75 <vector194>:
.globl vector194
vector194:
  pushl $0
80105a75:	6a 00                	push   $0x0
  pushl $194
80105a77:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105a7c:	e9 31 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a81 <vector195>:
.globl vector195
vector195:
  pushl $0
80105a81:	6a 00                	push   $0x0
  pushl $195
80105a83:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105a88:	e9 25 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a8d <vector196>:
.globl vector196
vector196:
  pushl $0
80105a8d:	6a 00                	push   $0x0
  pushl $196
80105a8f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105a94:	e9 19 f4 ff ff       	jmp    80104eb2 <alltraps>

80105a99 <vector197>:
.globl vector197
vector197:
  pushl $0
80105a99:	6a 00                	push   $0x0
  pushl $197
80105a9b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105aa0:	e9 0d f4 ff ff       	jmp    80104eb2 <alltraps>

80105aa5 <vector198>:
.globl vector198
vector198:
  pushl $0
80105aa5:	6a 00                	push   $0x0
  pushl $198
80105aa7:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105aac:	e9 01 f4 ff ff       	jmp    80104eb2 <alltraps>

80105ab1 <vector199>:
.globl vector199
vector199:
  pushl $0
80105ab1:	6a 00                	push   $0x0
  pushl $199
80105ab3:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105ab8:	e9 f5 f3 ff ff       	jmp    80104eb2 <alltraps>

80105abd <vector200>:
.globl vector200
vector200:
  pushl $0
80105abd:	6a 00                	push   $0x0
  pushl $200
80105abf:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105ac4:	e9 e9 f3 ff ff       	jmp    80104eb2 <alltraps>

80105ac9 <vector201>:
.globl vector201
vector201:
  pushl $0
80105ac9:	6a 00                	push   $0x0
  pushl $201
80105acb:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105ad0:	e9 dd f3 ff ff       	jmp    80104eb2 <alltraps>

80105ad5 <vector202>:
.globl vector202
vector202:
  pushl $0
80105ad5:	6a 00                	push   $0x0
  pushl $202
80105ad7:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105adc:	e9 d1 f3 ff ff       	jmp    80104eb2 <alltraps>

80105ae1 <vector203>:
.globl vector203
vector203:
  pushl $0
80105ae1:	6a 00                	push   $0x0
  pushl $203
80105ae3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105ae8:	e9 c5 f3 ff ff       	jmp    80104eb2 <alltraps>

80105aed <vector204>:
.globl vector204
vector204:
  pushl $0
80105aed:	6a 00                	push   $0x0
  pushl $204
80105aef:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105af4:	e9 b9 f3 ff ff       	jmp    80104eb2 <alltraps>

80105af9 <vector205>:
.globl vector205
vector205:
  pushl $0
80105af9:	6a 00                	push   $0x0
  pushl $205
80105afb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b00:	e9 ad f3 ff ff       	jmp    80104eb2 <alltraps>

80105b05 <vector206>:
.globl vector206
vector206:
  pushl $0
80105b05:	6a 00                	push   $0x0
  pushl $206
80105b07:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b0c:	e9 a1 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b11 <vector207>:
.globl vector207
vector207:
  pushl $0
80105b11:	6a 00                	push   $0x0
  pushl $207
80105b13:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b18:	e9 95 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b1d <vector208>:
.globl vector208
vector208:
  pushl $0
80105b1d:	6a 00                	push   $0x0
  pushl $208
80105b1f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b24:	e9 89 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b29 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b29:	6a 00                	push   $0x0
  pushl $209
80105b2b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b30:	e9 7d f3 ff ff       	jmp    80104eb2 <alltraps>

80105b35 <vector210>:
.globl vector210
vector210:
  pushl $0
80105b35:	6a 00                	push   $0x0
  pushl $210
80105b37:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b3c:	e9 71 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b41 <vector211>:
.globl vector211
vector211:
  pushl $0
80105b41:	6a 00                	push   $0x0
  pushl $211
80105b43:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b48:	e9 65 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b4d <vector212>:
.globl vector212
vector212:
  pushl $0
80105b4d:	6a 00                	push   $0x0
  pushl $212
80105b4f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b54:	e9 59 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b59 <vector213>:
.globl vector213
vector213:
  pushl $0
80105b59:	6a 00                	push   $0x0
  pushl $213
80105b5b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b60:	e9 4d f3 ff ff       	jmp    80104eb2 <alltraps>

80105b65 <vector214>:
.globl vector214
vector214:
  pushl $0
80105b65:	6a 00                	push   $0x0
  pushl $214
80105b67:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b6c:	e9 41 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b71 <vector215>:
.globl vector215
vector215:
  pushl $0
80105b71:	6a 00                	push   $0x0
  pushl $215
80105b73:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105b78:	e9 35 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b7d <vector216>:
.globl vector216
vector216:
  pushl $0
80105b7d:	6a 00                	push   $0x0
  pushl $216
80105b7f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105b84:	e9 29 f3 ff ff       	jmp    80104eb2 <alltraps>

80105b89 <vector217>:
.globl vector217
vector217:
  pushl $0
80105b89:	6a 00                	push   $0x0
  pushl $217
80105b8b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105b90:	e9 1d f3 ff ff       	jmp    80104eb2 <alltraps>

80105b95 <vector218>:
.globl vector218
vector218:
  pushl $0
80105b95:	6a 00                	push   $0x0
  pushl $218
80105b97:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105b9c:	e9 11 f3 ff ff       	jmp    80104eb2 <alltraps>

80105ba1 <vector219>:
.globl vector219
vector219:
  pushl $0
80105ba1:	6a 00                	push   $0x0
  pushl $219
80105ba3:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105ba8:	e9 05 f3 ff ff       	jmp    80104eb2 <alltraps>

80105bad <vector220>:
.globl vector220
vector220:
  pushl $0
80105bad:	6a 00                	push   $0x0
  pushl $220
80105baf:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105bb4:	e9 f9 f2 ff ff       	jmp    80104eb2 <alltraps>

80105bb9 <vector221>:
.globl vector221
vector221:
  pushl $0
80105bb9:	6a 00                	push   $0x0
  pushl $221
80105bbb:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105bc0:	e9 ed f2 ff ff       	jmp    80104eb2 <alltraps>

80105bc5 <vector222>:
.globl vector222
vector222:
  pushl $0
80105bc5:	6a 00                	push   $0x0
  pushl $222
80105bc7:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105bcc:	e9 e1 f2 ff ff       	jmp    80104eb2 <alltraps>

80105bd1 <vector223>:
.globl vector223
vector223:
  pushl $0
80105bd1:	6a 00                	push   $0x0
  pushl $223
80105bd3:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105bd8:	e9 d5 f2 ff ff       	jmp    80104eb2 <alltraps>

80105bdd <vector224>:
.globl vector224
vector224:
  pushl $0
80105bdd:	6a 00                	push   $0x0
  pushl $224
80105bdf:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105be4:	e9 c9 f2 ff ff       	jmp    80104eb2 <alltraps>

80105be9 <vector225>:
.globl vector225
vector225:
  pushl $0
80105be9:	6a 00                	push   $0x0
  pushl $225
80105beb:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105bf0:	e9 bd f2 ff ff       	jmp    80104eb2 <alltraps>

80105bf5 <vector226>:
.globl vector226
vector226:
  pushl $0
80105bf5:	6a 00                	push   $0x0
  pushl $226
80105bf7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105bfc:	e9 b1 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c01 <vector227>:
.globl vector227
vector227:
  pushl $0
80105c01:	6a 00                	push   $0x0
  pushl $227
80105c03:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c08:	e9 a5 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c0d <vector228>:
.globl vector228
vector228:
  pushl $0
80105c0d:	6a 00                	push   $0x0
  pushl $228
80105c0f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c14:	e9 99 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c19 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c19:	6a 00                	push   $0x0
  pushl $229
80105c1b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c20:	e9 8d f2 ff ff       	jmp    80104eb2 <alltraps>

80105c25 <vector230>:
.globl vector230
vector230:
  pushl $0
80105c25:	6a 00                	push   $0x0
  pushl $230
80105c27:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c2c:	e9 81 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c31 <vector231>:
.globl vector231
vector231:
  pushl $0
80105c31:	6a 00                	push   $0x0
  pushl $231
80105c33:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c38:	e9 75 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c3d <vector232>:
.globl vector232
vector232:
  pushl $0
80105c3d:	6a 00                	push   $0x0
  pushl $232
80105c3f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c44:	e9 69 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c49 <vector233>:
.globl vector233
vector233:
  pushl $0
80105c49:	6a 00                	push   $0x0
  pushl $233
80105c4b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c50:	e9 5d f2 ff ff       	jmp    80104eb2 <alltraps>

80105c55 <vector234>:
.globl vector234
vector234:
  pushl $0
80105c55:	6a 00                	push   $0x0
  pushl $234
80105c57:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c5c:	e9 51 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c61 <vector235>:
.globl vector235
vector235:
  pushl $0
80105c61:	6a 00                	push   $0x0
  pushl $235
80105c63:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c68:	e9 45 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c6d <vector236>:
.globl vector236
vector236:
  pushl $0
80105c6d:	6a 00                	push   $0x0
  pushl $236
80105c6f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105c74:	e9 39 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c79 <vector237>:
.globl vector237
vector237:
  pushl $0
80105c79:	6a 00                	push   $0x0
  pushl $237
80105c7b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105c80:	e9 2d f2 ff ff       	jmp    80104eb2 <alltraps>

80105c85 <vector238>:
.globl vector238
vector238:
  pushl $0
80105c85:	6a 00                	push   $0x0
  pushl $238
80105c87:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105c8c:	e9 21 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c91 <vector239>:
.globl vector239
vector239:
  pushl $0
80105c91:	6a 00                	push   $0x0
  pushl $239
80105c93:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105c98:	e9 15 f2 ff ff       	jmp    80104eb2 <alltraps>

80105c9d <vector240>:
.globl vector240
vector240:
  pushl $0
80105c9d:	6a 00                	push   $0x0
  pushl $240
80105c9f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105ca4:	e9 09 f2 ff ff       	jmp    80104eb2 <alltraps>

80105ca9 <vector241>:
.globl vector241
vector241:
  pushl $0
80105ca9:	6a 00                	push   $0x0
  pushl $241
80105cab:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105cb0:	e9 fd f1 ff ff       	jmp    80104eb2 <alltraps>

80105cb5 <vector242>:
.globl vector242
vector242:
  pushl $0
80105cb5:	6a 00                	push   $0x0
  pushl $242
80105cb7:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105cbc:	e9 f1 f1 ff ff       	jmp    80104eb2 <alltraps>

80105cc1 <vector243>:
.globl vector243
vector243:
  pushl $0
80105cc1:	6a 00                	push   $0x0
  pushl $243
80105cc3:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cc8:	e9 e5 f1 ff ff       	jmp    80104eb2 <alltraps>

80105ccd <vector244>:
.globl vector244
vector244:
  pushl $0
80105ccd:	6a 00                	push   $0x0
  pushl $244
80105ccf:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105cd4:	e9 d9 f1 ff ff       	jmp    80104eb2 <alltraps>

80105cd9 <vector245>:
.globl vector245
vector245:
  pushl $0
80105cd9:	6a 00                	push   $0x0
  pushl $245
80105cdb:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105ce0:	e9 cd f1 ff ff       	jmp    80104eb2 <alltraps>

80105ce5 <vector246>:
.globl vector246
vector246:
  pushl $0
80105ce5:	6a 00                	push   $0x0
  pushl $246
80105ce7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105cec:	e9 c1 f1 ff ff       	jmp    80104eb2 <alltraps>

80105cf1 <vector247>:
.globl vector247
vector247:
  pushl $0
80105cf1:	6a 00                	push   $0x0
  pushl $247
80105cf3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105cf8:	e9 b5 f1 ff ff       	jmp    80104eb2 <alltraps>

80105cfd <vector248>:
.globl vector248
vector248:
  pushl $0
80105cfd:	6a 00                	push   $0x0
  pushl $248
80105cff:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d04:	e9 a9 f1 ff ff       	jmp    80104eb2 <alltraps>

80105d09 <vector249>:
.globl vector249
vector249:
  pushl $0
80105d09:	6a 00                	push   $0x0
  pushl $249
80105d0b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d10:	e9 9d f1 ff ff       	jmp    80104eb2 <alltraps>

80105d15 <vector250>:
.globl vector250
vector250:
  pushl $0
80105d15:	6a 00                	push   $0x0
  pushl $250
80105d17:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d1c:	e9 91 f1 ff ff       	jmp    80104eb2 <alltraps>

80105d21 <vector251>:
.globl vector251
vector251:
  pushl $0
80105d21:	6a 00                	push   $0x0
  pushl $251
80105d23:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d28:	e9 85 f1 ff ff       	jmp    80104eb2 <alltraps>

80105d2d <vector252>:
.globl vector252
vector252:
  pushl $0
80105d2d:	6a 00                	push   $0x0
  pushl $252
80105d2f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d34:	e9 79 f1 ff ff       	jmp    80104eb2 <alltraps>

80105d39 <vector253>:
.globl vector253
vector253:
  pushl $0
80105d39:	6a 00                	push   $0x0
  pushl $253
80105d3b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d40:	e9 6d f1 ff ff       	jmp    80104eb2 <alltraps>

80105d45 <vector254>:
.globl vector254
vector254:
  pushl $0
80105d45:	6a 00                	push   $0x0
  pushl $254
80105d47:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d4c:	e9 61 f1 ff ff       	jmp    80104eb2 <alltraps>

80105d51 <vector255>:
.globl vector255
vector255:
  pushl $0
80105d51:	6a 00                	push   $0x0
  pushl $255
80105d53:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d58:	e9 55 f1 ff ff       	jmp    80104eb2 <alltraps>

80105d5d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d5d:	55                   	push   %ebp
80105d5e:	89 e5                	mov    %esp,%ebp
80105d60:	57                   	push   %edi
80105d61:	56                   	push   %esi
80105d62:	53                   	push   %ebx
80105d63:	83 ec 0c             	sub    $0xc,%esp
80105d66:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d68:	c1 ea 16             	shr    $0x16,%edx
80105d6b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d6e:	8b 1f                	mov    (%edi),%ebx
80105d70:	f6 c3 01             	test   $0x1,%bl
80105d73:	74 22                	je     80105d97 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105d75:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105d7b:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105d81:	c1 ee 0c             	shr    $0xc,%esi
80105d84:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105d8a:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105d8d:	89 d8                	mov    %ebx,%eax
80105d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d92:	5b                   	pop    %ebx
80105d93:	5e                   	pop    %esi
80105d94:	5f                   	pop    %edi
80105d95:	5d                   	pop    %ebp
80105d96:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105d97:	85 c9                	test   %ecx,%ecx
80105d99:	74 2b                	je     80105dc6 <walkpgdir+0x69>
80105d9b:	e8 45 c4 ff ff       	call   801021e5 <kalloc>
80105da0:	89 c3                	mov    %eax,%ebx
80105da2:	85 c0                	test   %eax,%eax
80105da4:	74 e7                	je     80105d8d <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105da6:	83 ec 04             	sub    $0x4,%esp
80105da9:	68 00 10 00 00       	push   $0x1000
80105dae:	6a 00                	push   $0x0
80105db0:	50                   	push   %eax
80105db1:	e8 b5 df ff ff       	call   80103d6b <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105db6:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105dbc:	83 c8 07             	or     $0x7,%eax
80105dbf:	89 07                	mov    %eax,(%edi)
80105dc1:	83 c4 10             	add    $0x10,%esp
80105dc4:	eb bb                	jmp    80105d81 <walkpgdir+0x24>
      return 0;
80105dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
80105dcb:	eb c0                	jmp    80105d8d <walkpgdir+0x30>

80105dcd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105dcd:	55                   	push   %ebp
80105dce:	89 e5                	mov    %esp,%ebp
80105dd0:	57                   	push   %edi
80105dd1:	56                   	push   %esi
80105dd2:	53                   	push   %ebx
80105dd3:	83 ec 1c             	sub    $0x1c,%esp
80105dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105dd9:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ddc:	89 d3                	mov    %edx,%ebx
80105dde:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105de4:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105de8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105dee:	b9 01 00 00 00       	mov    $0x1,%ecx
80105df3:	89 da                	mov    %ebx,%edx
80105df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105df8:	e8 60 ff ff ff       	call   80105d5d <walkpgdir>
80105dfd:	85 c0                	test   %eax,%eax
80105dff:	74 2e                	je     80105e2f <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e01:	f6 00 01             	testb  $0x1,(%eax)
80105e04:	75 1c                	jne    80105e22 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e06:	89 f2                	mov    %esi,%edx
80105e08:	0b 55 0c             	or     0xc(%ebp),%edx
80105e0b:	83 ca 01             	or     $0x1,%edx
80105e0e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e10:	39 fb                	cmp    %edi,%ebx
80105e12:	74 28                	je     80105e3c <mappages+0x6f>
      break;
    a += PGSIZE;
80105e14:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e1a:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e20:	eb cc                	jmp    80105dee <mappages+0x21>
      panic("remap");
80105e22:	83 ec 0c             	sub    $0xc,%esp
80105e25:	68 f0 6e 10 80       	push   $0x80106ef0
80105e2a:	e8 19 a5 ff ff       	call   80100348 <panic>
      return -1;
80105e2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e37:	5b                   	pop    %ebx
80105e38:	5e                   	pop    %esi
80105e39:	5f                   	pop    %edi
80105e3a:	5d                   	pop    %ebp
80105e3b:	c3                   	ret    
  return 0;
80105e3c:	b8 00 00 00 00       	mov    $0x0,%eax
80105e41:	eb f1                	jmp    80105e34 <mappages+0x67>

80105e43 <seginit>:
{
80105e43:	55                   	push   %ebp
80105e44:	89 e5                	mov    %esp,%ebp
80105e46:	53                   	push   %ebx
80105e47:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e4a:	e8 b6 d4 ff ff       	call   80103305 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e4f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e55:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
80105e5c:	ff ff 
80105e5e:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80105e65:	00 00 
80105e67:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
80105e6e:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
80105e75:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e78:	83 c9 1a             	or     $0x1a,%ecx
80105e7b:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e7e:	83 c9 80             	or     $0xffffff80,%ecx
80105e81:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
80105e87:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
80105e8e:	83 c9 0f             	or     $0xf,%ecx
80105e91:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e94:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e97:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
80105e9d:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ea4:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
80105eab:	ff ff 
80105ead:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
80105eb4:	00 00 
80105eb6:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80105ebd:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
80105ec4:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ec7:	83 c9 12             	or     $0x12,%ecx
80105eca:	83 e1 9f             	and    $0xffffff9f,%ecx
80105ecd:	83 c9 80             	or     $0xffffff80,%ecx
80105ed0:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80105ed6:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80105edd:	83 c9 0f             	or     $0xf,%ecx
80105ee0:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ee3:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ee6:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
80105eec:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105ef3:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80105efa:	ff ff 
80105efc:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
80105f03:	00 00 
80105f05:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
80105f0c:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
80105f13:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
80105f1a:	83 c9 0f             	or     $0xf,%ecx
80105f1d:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f20:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f23:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
80105f29:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f30:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
80105f37:	ff ff 
80105f39:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
80105f40:	00 00 
80105f42:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
80105f49:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
80105f50:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
80105f57:	83 c9 0f             	or     $0xf,%ecx
80105f5a:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f5d:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f60:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
80105f66:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105f6d:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
80105f72:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105f78:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105f7c:	c1 e8 10             	shr    $0x10,%eax
80105f7f:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105f83:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105f86:	0f 01 10             	lgdtl  (%eax)
}
80105f89:	83 c4 14             	add    $0x14,%esp
80105f8c:	5b                   	pop    %ebx
80105f8d:	5d                   	pop    %ebp
80105f8e:	c3                   	ret    

80105f8f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105f8f:	55                   	push   %ebp
80105f90:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105f92:	a1 a4 54 11 80       	mov    0x801154a4,%eax
80105f97:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f9c:	0f 22 d8             	mov    %eax,%cr3
}
80105f9f:	5d                   	pop    %ebp
80105fa0:	c3                   	ret    

80105fa1 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fa1:	55                   	push   %ebp
80105fa2:	89 e5                	mov    %esp,%ebp
80105fa4:	57                   	push   %edi
80105fa5:	56                   	push   %esi
80105fa6:	53                   	push   %ebx
80105fa7:	83 ec 1c             	sub    $0x1c,%esp
80105faa:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105fad:	85 f6                	test   %esi,%esi
80105faf:	0f 84 dd 00 00 00    	je     80106092 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105fb5:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105fb9:	0f 84 e0 00 00 00    	je     8010609f <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105fbf:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105fc3:	0f 84 e3 00 00 00    	je     801060ac <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105fc9:	e8 14 dc ff ff       	call   80103be2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105fce:	e8 d6 d2 ff ff       	call   801032a9 <mycpu>
80105fd3:	89 c3                	mov    %eax,%ebx
80105fd5:	e8 cf d2 ff ff       	call   801032a9 <mycpu>
80105fda:	8d 78 08             	lea    0x8(%eax),%edi
80105fdd:	e8 c7 d2 ff ff       	call   801032a9 <mycpu>
80105fe2:	83 c0 08             	add    $0x8,%eax
80105fe5:	c1 e8 10             	shr    $0x10,%eax
80105fe8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105feb:	e8 b9 d2 ff ff       	call   801032a9 <mycpu>
80105ff0:	83 c0 08             	add    $0x8,%eax
80105ff3:	c1 e8 18             	shr    $0x18,%eax
80105ff6:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105ffd:	67 00 
80105fff:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106006:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010600a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106010:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106017:	83 e2 f0             	and    $0xfffffff0,%edx
8010601a:	83 ca 19             	or     $0x19,%edx
8010601d:	83 e2 9f             	and    $0xffffff9f,%edx
80106020:	83 ca 80             	or     $0xffffff80,%edx
80106023:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106029:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106030:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106036:	e8 6e d2 ff ff       	call   801032a9 <mycpu>
8010603b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106042:	83 e2 ef             	and    $0xffffffef,%edx
80106045:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010604b:	e8 59 d2 ff ff       	call   801032a9 <mycpu>
80106050:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106056:	8b 5e 08             	mov    0x8(%esi),%ebx
80106059:	e8 4b d2 ff ff       	call   801032a9 <mycpu>
8010605e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106064:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106067:	e8 3d d2 ff ff       	call   801032a9 <mycpu>
8010606c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106072:	b8 28 00 00 00       	mov    $0x28,%eax
80106077:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010607a:	8b 46 04             	mov    0x4(%esi),%eax
8010607d:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106082:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106085:	e8 95 db ff ff       	call   80103c1f <popcli>
}
8010608a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010608d:	5b                   	pop    %ebx
8010608e:	5e                   	pop    %esi
8010608f:	5f                   	pop    %edi
80106090:	5d                   	pop    %ebp
80106091:	c3                   	ret    
    panic("switchuvm: no process");
80106092:	83 ec 0c             	sub    $0xc,%esp
80106095:	68 f6 6e 10 80       	push   $0x80106ef6
8010609a:	e8 a9 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010609f:	83 ec 0c             	sub    $0xc,%esp
801060a2:	68 0c 6f 10 80       	push   $0x80106f0c
801060a7:	e8 9c a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060ac:	83 ec 0c             	sub    $0xc,%esp
801060af:	68 21 6f 10 80       	push   $0x80106f21
801060b4:	e8 8f a2 ff ff       	call   80100348 <panic>

801060b9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801060b9:	55                   	push   %ebp
801060ba:	89 e5                	mov    %esp,%ebp
801060bc:	56                   	push   %esi
801060bd:	53                   	push   %ebx
801060be:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801060c1:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060c7:	77 4c                	ja     80106115 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
801060c9:	e8 17 c1 ff ff       	call   801021e5 <kalloc>
801060ce:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801060d0:	83 ec 04             	sub    $0x4,%esp
801060d3:	68 00 10 00 00       	push   $0x1000
801060d8:	6a 00                	push   $0x0
801060da:	50                   	push   %eax
801060db:	e8 8b dc ff ff       	call   80103d6b <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801060e0:	83 c4 08             	add    $0x8,%esp
801060e3:	6a 06                	push   $0x6
801060e5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801060eb:	50                   	push   %eax
801060ec:	b9 00 10 00 00       	mov    $0x1000,%ecx
801060f1:	ba 00 00 00 00       	mov    $0x0,%edx
801060f6:	8b 45 08             	mov    0x8(%ebp),%eax
801060f9:	e8 cf fc ff ff       	call   80105dcd <mappages>
  memmove(mem, init, sz);
801060fe:	83 c4 0c             	add    $0xc,%esp
80106101:	56                   	push   %esi
80106102:	ff 75 0c             	pushl  0xc(%ebp)
80106105:	53                   	push   %ebx
80106106:	e8 db dc ff ff       	call   80103de6 <memmove>
}
8010610b:	83 c4 10             	add    $0x10,%esp
8010610e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106111:	5b                   	pop    %ebx
80106112:	5e                   	pop    %esi
80106113:	5d                   	pop    %ebp
80106114:	c3                   	ret    
    panic("inituvm: more than a page");
80106115:	83 ec 0c             	sub    $0xc,%esp
80106118:	68 35 6f 10 80       	push   $0x80106f35
8010611d:	e8 26 a2 ff ff       	call   80100348 <panic>

80106122 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106122:	55                   	push   %ebp
80106123:	89 e5                	mov    %esp,%ebp
80106125:	57                   	push   %edi
80106126:	56                   	push   %esi
80106127:	53                   	push   %ebx
80106128:	83 ec 0c             	sub    $0xc,%esp
8010612b:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010612e:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106135:	75 07                	jne    8010613e <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106137:	bb 00 00 00 00       	mov    $0x0,%ebx
8010613c:	eb 3c                	jmp    8010617a <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
8010613e:	83 ec 0c             	sub    $0xc,%esp
80106141:	68 f0 6f 10 80       	push   $0x80106ff0
80106146:	e8 fd a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010614b:	83 ec 0c             	sub    $0xc,%esp
8010614e:	68 4f 6f 10 80       	push   $0x80106f4f
80106153:	e8 f0 a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106158:	05 00 00 00 80       	add    $0x80000000,%eax
8010615d:	56                   	push   %esi
8010615e:	89 da                	mov    %ebx,%edx
80106160:	03 55 14             	add    0x14(%ebp),%edx
80106163:	52                   	push   %edx
80106164:	50                   	push   %eax
80106165:	ff 75 10             	pushl  0x10(%ebp)
80106168:	e8 06 b6 ff ff       	call   80101773 <readi>
8010616d:	83 c4 10             	add    $0x10,%esp
80106170:	39 f0                	cmp    %esi,%eax
80106172:	75 47                	jne    801061bb <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
80106174:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010617a:	39 fb                	cmp    %edi,%ebx
8010617c:	73 30                	jae    801061ae <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010617e:	89 da                	mov    %ebx,%edx
80106180:	03 55 0c             	add    0xc(%ebp),%edx
80106183:	b9 00 00 00 00       	mov    $0x0,%ecx
80106188:	8b 45 08             	mov    0x8(%ebp),%eax
8010618b:	e8 cd fb ff ff       	call   80105d5d <walkpgdir>
80106190:	85 c0                	test   %eax,%eax
80106192:	74 b7                	je     8010614b <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
80106194:	8b 00                	mov    (%eax),%eax
80106196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010619b:	89 fe                	mov    %edi,%esi
8010619d:	29 de                	sub    %ebx,%esi
8010619f:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061a5:	76 b1                	jbe    80106158 <loaduvm+0x36>
      n = PGSIZE;
801061a7:	be 00 10 00 00       	mov    $0x1000,%esi
801061ac:	eb aa                	jmp    80106158 <loaduvm+0x36>
      return -1;
  }
  return 0;
801061ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061b6:	5b                   	pop    %ebx
801061b7:	5e                   	pop    %esi
801061b8:	5f                   	pop    %edi
801061b9:	5d                   	pop    %ebp
801061ba:	c3                   	ret    
      return -1;
801061bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c0:	eb f1                	jmp    801061b3 <loaduvm+0x91>

801061c2 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801061c2:	55                   	push   %ebp
801061c3:	89 e5                	mov    %esp,%ebp
801061c5:	57                   	push   %edi
801061c6:	56                   	push   %esi
801061c7:	53                   	push   %ebx
801061c8:	83 ec 0c             	sub    $0xc,%esp
801061cb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801061ce:	39 7d 10             	cmp    %edi,0x10(%ebp)
801061d1:	73 11                	jae    801061e4 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801061d3:	8b 45 10             	mov    0x10(%ebp),%eax
801061d6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801061dc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801061e2:	eb 19                	jmp    801061fd <deallocuvm+0x3b>
    return oldsz;
801061e4:	89 f8                	mov    %edi,%eax
801061e6:	eb 64                	jmp    8010624c <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801061e8:	c1 eb 16             	shr    $0x16,%ebx
801061eb:	83 c3 01             	add    $0x1,%ebx
801061ee:	c1 e3 16             	shl    $0x16,%ebx
801061f1:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801061f7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061fd:	39 fb                	cmp    %edi,%ebx
801061ff:	73 48                	jae    80106249 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106201:	b9 00 00 00 00       	mov    $0x0,%ecx
80106206:	89 da                	mov    %ebx,%edx
80106208:	8b 45 08             	mov    0x8(%ebp),%eax
8010620b:	e8 4d fb ff ff       	call   80105d5d <walkpgdir>
80106210:	89 c6                	mov    %eax,%esi
    if(!pte)
80106212:	85 c0                	test   %eax,%eax
80106214:	74 d2                	je     801061e8 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106216:	8b 00                	mov    (%eax),%eax
80106218:	a8 01                	test   $0x1,%al
8010621a:	74 db                	je     801061f7 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010621c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106221:	74 19                	je     8010623c <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106223:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106228:	83 ec 0c             	sub    $0xc,%esp
8010622b:	50                   	push   %eax
8010622c:	e8 9d be ff ff       	call   801020ce <kfree>
      *pte = 0;
80106231:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106237:	83 c4 10             	add    $0x10,%esp
8010623a:	eb bb                	jmp    801061f7 <deallocuvm+0x35>
        panic("kfree");
8010623c:	83 ec 0c             	sub    $0xc,%esp
8010623f:	68 66 68 10 80       	push   $0x80106866
80106244:	e8 ff a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106249:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010624c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010624f:	5b                   	pop    %ebx
80106250:	5e                   	pop    %esi
80106251:	5f                   	pop    %edi
80106252:	5d                   	pop    %ebp
80106253:	c3                   	ret    

80106254 <allocuvm>:
{
80106254:	55                   	push   %ebp
80106255:	89 e5                	mov    %esp,%ebp
80106257:	57                   	push   %edi
80106258:	56                   	push   %esi
80106259:	53                   	push   %ebx
8010625a:	83 ec 1c             	sub    $0x1c,%esp
8010625d:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106260:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106263:	85 ff                	test   %edi,%edi
80106265:	0f 88 c1 00 00 00    	js     8010632c <allocuvm+0xd8>
  if(newsz < oldsz)
8010626b:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010626e:	72 5c                	jb     801062cc <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106270:	8b 45 0c             	mov    0xc(%ebp),%eax
80106273:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106279:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
8010627f:	39 fb                	cmp    %edi,%ebx
80106281:	0f 83 ac 00 00 00    	jae    80106333 <allocuvm+0xdf>
    mem = kalloc();
80106287:	e8 59 bf ff ff       	call   801021e5 <kalloc>
8010628c:	89 c6                	mov    %eax,%esi
    if(mem == 0){
8010628e:	85 c0                	test   %eax,%eax
80106290:	74 42                	je     801062d4 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
80106292:	83 ec 04             	sub    $0x4,%esp
80106295:	68 00 10 00 00       	push   $0x1000
8010629a:	6a 00                	push   $0x0
8010629c:	50                   	push   %eax
8010629d:	e8 c9 da ff ff       	call   80103d6b <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801062a2:	83 c4 08             	add    $0x8,%esp
801062a5:	6a 06                	push   $0x6
801062a7:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801062ad:	50                   	push   %eax
801062ae:	b9 00 10 00 00       	mov    $0x1000,%ecx
801062b3:	89 da                	mov    %ebx,%edx
801062b5:	8b 45 08             	mov    0x8(%ebp),%eax
801062b8:	e8 10 fb ff ff       	call   80105dcd <mappages>
801062bd:	83 c4 10             	add    $0x10,%esp
801062c0:	85 c0                	test   %eax,%eax
801062c2:	78 38                	js     801062fc <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801062c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062ca:	eb b3                	jmp    8010627f <allocuvm+0x2b>
    return oldsz;
801062cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801062cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801062d2:	eb 5f                	jmp    80106333 <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801062d4:	83 ec 0c             	sub    $0xc,%esp
801062d7:	68 6d 6f 10 80       	push   $0x80106f6d
801062dc:	e8 2a a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801062e1:	83 c4 0c             	add    $0xc,%esp
801062e4:	ff 75 0c             	pushl  0xc(%ebp)
801062e7:	57                   	push   %edi
801062e8:	ff 75 08             	pushl  0x8(%ebp)
801062eb:	e8 d2 fe ff ff       	call   801061c2 <deallocuvm>
      return 0;
801062f0:	83 c4 10             	add    $0x10,%esp
801062f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801062fa:	eb 37                	jmp    80106333 <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
801062fc:	83 ec 0c             	sub    $0xc,%esp
801062ff:	68 85 6f 10 80       	push   $0x80106f85
80106304:	e8 02 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106309:	83 c4 0c             	add    $0xc,%esp
8010630c:	ff 75 0c             	pushl  0xc(%ebp)
8010630f:	57                   	push   %edi
80106310:	ff 75 08             	pushl  0x8(%ebp)
80106313:	e8 aa fe ff ff       	call   801061c2 <deallocuvm>
      kfree(mem);
80106318:	89 34 24             	mov    %esi,(%esp)
8010631b:	e8 ae bd ff ff       	call   801020ce <kfree>
      return 0;
80106320:	83 c4 10             	add    $0x10,%esp
80106323:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010632a:	eb 07                	jmp    80106333 <allocuvm+0xdf>
    return 0;
8010632c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106333:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106336:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106339:	5b                   	pop    %ebx
8010633a:	5e                   	pop    %esi
8010633b:	5f                   	pop    %edi
8010633c:	5d                   	pop    %ebp
8010633d:	c3                   	ret    

8010633e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010633e:	55                   	push   %ebp
8010633f:	89 e5                	mov    %esp,%ebp
80106341:	56                   	push   %esi
80106342:	53                   	push   %ebx
80106343:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106346:	85 f6                	test   %esi,%esi
80106348:	74 1a                	je     80106364 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010634a:	83 ec 04             	sub    $0x4,%esp
8010634d:	6a 00                	push   $0x0
8010634f:	68 00 00 00 80       	push   $0x80000000
80106354:	56                   	push   %esi
80106355:	e8 68 fe ff ff       	call   801061c2 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010635a:	83 c4 10             	add    $0x10,%esp
8010635d:	bb 00 00 00 00       	mov    $0x0,%ebx
80106362:	eb 10                	jmp    80106374 <freevm+0x36>
    panic("freevm: no pgdir");
80106364:	83 ec 0c             	sub    $0xc,%esp
80106367:	68 a1 6f 10 80       	push   $0x80106fa1
8010636c:	e8 d7 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106371:	83 c3 01             	add    $0x1,%ebx
80106374:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
8010637a:	77 1f                	ja     8010639b <freevm+0x5d>
    if(pgdir[i] & PTE_P){
8010637c:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
8010637f:	a8 01                	test   $0x1,%al
80106381:	74 ee                	je     80106371 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106383:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106388:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010638d:	83 ec 0c             	sub    $0xc,%esp
80106390:	50                   	push   %eax
80106391:	e8 38 bd ff ff       	call   801020ce <kfree>
80106396:	83 c4 10             	add    $0x10,%esp
80106399:	eb d6                	jmp    80106371 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
8010639b:	83 ec 0c             	sub    $0xc,%esp
8010639e:	56                   	push   %esi
8010639f:	e8 2a bd ff ff       	call   801020ce <kfree>
}
801063a4:	83 c4 10             	add    $0x10,%esp
801063a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063aa:	5b                   	pop    %ebx
801063ab:	5e                   	pop    %esi
801063ac:	5d                   	pop    %ebp
801063ad:	c3                   	ret    

801063ae <setupkvm>:
{
801063ae:	55                   	push   %ebp
801063af:	89 e5                	mov    %esp,%ebp
801063b1:	56                   	push   %esi
801063b2:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801063b3:	e8 2d be ff ff       	call   801021e5 <kalloc>
801063b8:	89 c6                	mov    %eax,%esi
801063ba:	85 c0                	test   %eax,%eax
801063bc:	74 55                	je     80106413 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801063be:	83 ec 04             	sub    $0x4,%esp
801063c1:	68 00 10 00 00       	push   $0x1000
801063c6:	6a 00                	push   $0x0
801063c8:	50                   	push   %eax
801063c9:	e8 9d d9 ff ff       	call   80103d6b <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801063ce:	83 c4 10             	add    $0x10,%esp
801063d1:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801063d6:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801063dc:	73 35                	jae    80106413 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801063de:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801063e1:	8b 4b 08             	mov    0x8(%ebx),%ecx
801063e4:	29 c1                	sub    %eax,%ecx
801063e6:	83 ec 08             	sub    $0x8,%esp
801063e9:	ff 73 0c             	pushl  0xc(%ebx)
801063ec:	50                   	push   %eax
801063ed:	8b 13                	mov    (%ebx),%edx
801063ef:	89 f0                	mov    %esi,%eax
801063f1:	e8 d7 f9 ff ff       	call   80105dcd <mappages>
801063f6:	83 c4 10             	add    $0x10,%esp
801063f9:	85 c0                	test   %eax,%eax
801063fb:	78 05                	js     80106402 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801063fd:	83 c3 10             	add    $0x10,%ebx
80106400:	eb d4                	jmp    801063d6 <setupkvm+0x28>
      freevm(pgdir);
80106402:	83 ec 0c             	sub    $0xc,%esp
80106405:	56                   	push   %esi
80106406:	e8 33 ff ff ff       	call   8010633e <freevm>
      return 0;
8010640b:	83 c4 10             	add    $0x10,%esp
8010640e:	be 00 00 00 00       	mov    $0x0,%esi
}
80106413:	89 f0                	mov    %esi,%eax
80106415:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106418:	5b                   	pop    %ebx
80106419:	5e                   	pop    %esi
8010641a:	5d                   	pop    %ebp
8010641b:	c3                   	ret    

8010641c <kvmalloc>:
{
8010641c:	55                   	push   %ebp
8010641d:	89 e5                	mov    %esp,%ebp
8010641f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106422:	e8 87 ff ff ff       	call   801063ae <setupkvm>
80106427:	a3 a4 54 11 80       	mov    %eax,0x801154a4
  switchkvm();
8010642c:	e8 5e fb ff ff       	call   80105f8f <switchkvm>
}
80106431:	c9                   	leave  
80106432:	c3                   	ret    

80106433 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106433:	55                   	push   %ebp
80106434:	89 e5                	mov    %esp,%ebp
80106436:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106439:	b9 00 00 00 00       	mov    $0x0,%ecx
8010643e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106441:	8b 45 08             	mov    0x8(%ebp),%eax
80106444:	e8 14 f9 ff ff       	call   80105d5d <walkpgdir>
  if(pte == 0)
80106449:	85 c0                	test   %eax,%eax
8010644b:	74 05                	je     80106452 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010644d:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106450:	c9                   	leave  
80106451:	c3                   	ret    
    panic("clearpteu");
80106452:	83 ec 0c             	sub    $0xc,%esp
80106455:	68 b2 6f 10 80       	push   $0x80106fb2
8010645a:	e8 e9 9e ff ff       	call   80100348 <panic>

8010645f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010645f:	55                   	push   %ebp
80106460:	89 e5                	mov    %esp,%ebp
80106462:	57                   	push   %edi
80106463:	56                   	push   %esi
80106464:	53                   	push   %ebx
80106465:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106468:	e8 41 ff ff ff       	call   801063ae <setupkvm>
8010646d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106470:	85 c0                	test   %eax,%eax
80106472:	0f 84 c4 00 00 00    	je     8010653c <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106478:	bf 00 00 00 00       	mov    $0x0,%edi
8010647d:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106480:	0f 83 b6 00 00 00    	jae    8010653c <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106486:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106489:	b9 00 00 00 00       	mov    $0x0,%ecx
8010648e:	89 fa                	mov    %edi,%edx
80106490:	8b 45 08             	mov    0x8(%ebp),%eax
80106493:	e8 c5 f8 ff ff       	call   80105d5d <walkpgdir>
80106498:	85 c0                	test   %eax,%eax
8010649a:	74 65                	je     80106501 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
8010649c:	8b 00                	mov    (%eax),%eax
8010649e:	a8 01                	test   $0x1,%al
801064a0:	74 6c                	je     8010650e <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801064a2:	89 c6                	mov    %eax,%esi
801064a4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801064aa:	25 ff 0f 00 00       	and    $0xfff,%eax
801064af:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801064b2:	e8 2e bd ff ff       	call   801021e5 <kalloc>
801064b7:	89 c3                	mov    %eax,%ebx
801064b9:	85 c0                	test   %eax,%eax
801064bb:	74 6a                	je     80106527 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801064bd:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801064c3:	83 ec 04             	sub    $0x4,%esp
801064c6:	68 00 10 00 00       	push   $0x1000
801064cb:	56                   	push   %esi
801064cc:	50                   	push   %eax
801064cd:	e8 14 d9 ff ff       	call   80103de6 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801064d2:	83 c4 08             	add    $0x8,%esp
801064d5:	ff 75 e0             	pushl  -0x20(%ebp)
801064d8:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801064de:	50                   	push   %eax
801064df:	b9 00 10 00 00       	mov    $0x1000,%ecx
801064e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064ea:	e8 de f8 ff ff       	call   80105dcd <mappages>
801064ef:	83 c4 10             	add    $0x10,%esp
801064f2:	85 c0                	test   %eax,%eax
801064f4:	78 25                	js     8010651b <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801064f6:	81 c7 00 10 00 00    	add    $0x1000,%edi
801064fc:	e9 7c ff ff ff       	jmp    8010647d <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106501:	83 ec 0c             	sub    $0xc,%esp
80106504:	68 bc 6f 10 80       	push   $0x80106fbc
80106509:	e8 3a 9e ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
8010650e:	83 ec 0c             	sub    $0xc,%esp
80106511:	68 d6 6f 10 80       	push   $0x80106fd6
80106516:	e8 2d 9e ff ff       	call   80100348 <panic>
      kfree(mem);
8010651b:	83 ec 0c             	sub    $0xc,%esp
8010651e:	53                   	push   %ebx
8010651f:	e8 aa bb ff ff       	call   801020ce <kfree>
      goto bad;
80106524:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106527:	83 ec 0c             	sub    $0xc,%esp
8010652a:	ff 75 dc             	pushl  -0x24(%ebp)
8010652d:	e8 0c fe ff ff       	call   8010633e <freevm>
  return 0;
80106532:	83 c4 10             	add    $0x10,%esp
80106535:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010653c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010653f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106542:	5b                   	pop    %ebx
80106543:	5e                   	pop    %esi
80106544:	5f                   	pop    %edi
80106545:	5d                   	pop    %ebp
80106546:	c3                   	ret    

80106547 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106547:	55                   	push   %ebp
80106548:	89 e5                	mov    %esp,%ebp
8010654a:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010654d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106552:	8b 55 0c             	mov    0xc(%ebp),%edx
80106555:	8b 45 08             	mov    0x8(%ebp),%eax
80106558:	e8 00 f8 ff ff       	call   80105d5d <walkpgdir>
  if((*pte & PTE_P) == 0)
8010655d:	8b 00                	mov    (%eax),%eax
8010655f:	a8 01                	test   $0x1,%al
80106561:	74 10                	je     80106573 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106563:	a8 04                	test   $0x4,%al
80106565:	74 13                	je     8010657a <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106567:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010656c:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106571:	c9                   	leave  
80106572:	c3                   	ret    
    return 0;
80106573:	b8 00 00 00 00       	mov    $0x0,%eax
80106578:	eb f7                	jmp    80106571 <uva2ka+0x2a>
    return 0;
8010657a:	b8 00 00 00 00       	mov    $0x0,%eax
8010657f:	eb f0                	jmp    80106571 <uva2ka+0x2a>

80106581 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106581:	55                   	push   %ebp
80106582:	89 e5                	mov    %esp,%ebp
80106584:	57                   	push   %edi
80106585:	56                   	push   %esi
80106586:	53                   	push   %ebx
80106587:	83 ec 0c             	sub    $0xc,%esp
8010658a:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010658d:	eb 25                	jmp    801065b4 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010658f:	8b 55 0c             	mov    0xc(%ebp),%edx
80106592:	29 f2                	sub    %esi,%edx
80106594:	01 d0                	add    %edx,%eax
80106596:	83 ec 04             	sub    $0x4,%esp
80106599:	53                   	push   %ebx
8010659a:	ff 75 10             	pushl  0x10(%ebp)
8010659d:	50                   	push   %eax
8010659e:	e8 43 d8 ff ff       	call   80103de6 <memmove>
    len -= n;
801065a3:	29 df                	sub    %ebx,%edi
    buf += n;
801065a5:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801065a8:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801065ae:	89 45 0c             	mov    %eax,0xc(%ebp)
801065b1:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801065b4:	85 ff                	test   %edi,%edi
801065b6:	74 2f                	je     801065e7 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801065b8:	8b 75 0c             	mov    0xc(%ebp),%esi
801065bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801065c1:	83 ec 08             	sub    $0x8,%esp
801065c4:	56                   	push   %esi
801065c5:	ff 75 08             	pushl  0x8(%ebp)
801065c8:	e8 7a ff ff ff       	call   80106547 <uva2ka>
    if(pa0 == 0)
801065cd:	83 c4 10             	add    $0x10,%esp
801065d0:	85 c0                	test   %eax,%eax
801065d2:	74 20                	je     801065f4 <copyout+0x73>
    n = PGSIZE - (va - va0);
801065d4:	89 f3                	mov    %esi,%ebx
801065d6:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801065d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801065df:	39 df                	cmp    %ebx,%edi
801065e1:	73 ac                	jae    8010658f <copyout+0xe>
      n = len;
801065e3:	89 fb                	mov    %edi,%ebx
801065e5:	eb a8                	jmp    8010658f <copyout+0xe>
  }
  return 0;
801065e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065ef:	5b                   	pop    %ebx
801065f0:	5e                   	pop    %esi
801065f1:	5f                   	pop    %edi
801065f2:	5d                   	pop    %ebp
801065f3:	c3                   	ret    
      return -1;
801065f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f9:	eb f1                	jmp    801065ec <copyout+0x6b>
