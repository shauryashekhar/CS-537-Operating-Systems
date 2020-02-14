
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
8010002d:	b8 46 2c 10 80       	mov    $0x80102c46,%eax
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
80100046:	e8 cd 3d 00 00       	call   80103e18 <acquire>

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
8010007c:	e8 fc 3d 00 00       	call   80103e7d <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 78 3b 00 00       	call   80103c04 <acquiresleep>
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
801000ca:	e8 ae 3d 00 00       	call   80103e7d <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 2a 3b 00 00       	call   80103c04 <acquiresleep>
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
801000ea:	68 20 67 10 80       	push   $0x80106720
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 31 67 10 80       	push   $0x80106731
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 d2 3b 00 00       	call   80103cdc <initlock>
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
8010013a:	68 38 67 10 80       	push   $0x80106738
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 89 3a 00 00       	call   80103bd1 <initsleeplock>
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
801001a8:	e8 e1 3a 00 00       	call   80103c8e <holdingsleep>
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
801001cb:	68 3f 67 10 80       	push   $0x8010673f
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
801001e4:	e8 a5 3a 00 00       	call   80103c8e <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 5a 3a 00 00       	call   80103c53 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 13 3c 00 00       	call   80103e18 <acquire>
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
8010024c:	e8 2c 3c 00 00       	call   80103e7d <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 46 67 10 80       	push   $0x80106746
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
8010028a:	e8 89 3b 00 00       	call   80103e18 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 5c 31 00 00       	call   80103408 <myproc>
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
801002bf:	e8 f2 35 00 00       	call   801038b6 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 a7 3b 00 00       	call   80103e7d <release>
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
80100331:	e8 47 3b 00 00       	call   80103e7d <release>
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
8010035a:	e8 01 22 00 00       	call   80102560 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 4d 67 10 80       	push   $0x8010674d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 1b 71 10 80 	movl   $0x8010711b,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 63 39 00 00       	call   80103cf7 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 61 67 10 80       	push   $0x80106761
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
8010049e:	68 65 67 10 80       	push   $0x80106765
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 80 3a 00 00       	call   80103f3f <memmove>
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
801004d9:	e8 e6 39 00 00       	call   80103ec4 <memset>
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
80100506:	e8 fa 4d 00 00       	call   80105305 <uartputc>
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
8010051f:	e8 e1 4d 00 00       	call   80105305 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 d5 4d 00 00       	call   80105305 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 c9 4d 00 00       	call   80105305 <uartputc>
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
80100576:	0f b6 92 90 67 10 80 	movzbl -0x7fef9870(%edx),%edx
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
801005ca:	e8 49 38 00 00       	call   80103e18 <acquire>
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
801005f1:	e8 87 38 00 00       	call   80103e7d <release>
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
80100638:	e8 db 37 00 00       	call   80103e18 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 7f 67 10 80       	push   $0x8010677f
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
801006ee:	be 78 67 10 80       	mov    $0x80106778,%esi
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
80100734:	e8 44 37 00 00       	call   80103e7d <release>
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
8010074f:	e8 c4 36 00 00       	call   80103e18 <acquire>
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
801007de:	e8 38 32 00 00       	call   80103a1b <wakeup>
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
80100873:	e8 05 36 00 00       	call   80103e7d <release>
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
80100887:	e8 2c 32 00 00       	call   80103ab8 <procdump>
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
80100894:	68 88 67 10 80       	push   $0x80106788
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 39 34 00 00       	call   80103cdc <initlock>

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
801008de:	e8 25 2b 00 00       	call   80103408 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 a2 20 00 00       	call   80102990 <begin_op>

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
80100935:	e8 d0 20 00 00       	call   80102a0a <end_op>
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
8010094a:	e8 bb 20 00 00       	call   80102a0a <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 a1 67 10 80       	push   $0x801067a1
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
80100972:	e8 4e 5b 00 00       	call   801064c5 <setupkvm>
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
80100a06:	e8 60 59 00 00       	call   8010636b <allocuvm>
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
80100a38:	e8 fc 57 00 00       	call   80106239 <loaduvm>
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
80100a53:	e8 b2 1f 00 00       	call   80102a0a <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 f2 58 00 00       	call   8010636b <allocuvm>
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
80100a9d:	e8 b3 59 00 00       	call   80106455 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 89 5a 00 00       	call   8010654a <clearpteu>
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
80100ae2:	e8 7f 35 00 00       	call   80104066 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 6d 35 00 00       	call   80104066 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 8d 5b 00 00       	call   80106698 <copyout>
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
80100b66:	e8 2d 5b 00 00       	call   80106698 <copyout>
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
80100ba3:	e8 83 34 00 00       	call   8010402b <safestrcpy>
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
80100bd1:	e8 e2 54 00 00       	call   801060b8 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 77 58 00 00       	call   80106455 <freevm>
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
80100c19:	68 ad 67 10 80       	push   $0x801067ad
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 b4 30 00 00       	call   80103cdc <initlock>
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
80100c39:	e8 da 31 00 00       	call   80103e18 <acquire>
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
80100c68:	e8 10 32 00 00       	call   80103e7d <release>
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
80100c7f:	e8 f9 31 00 00       	call   80103e7d <release>
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
80100c9d:	e8 76 31 00 00       	call   80103e18 <acquire>
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
80100cba:	e8 be 31 00 00       	call   80103e7d <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 b4 67 10 80       	push   $0x801067b4
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
80100ce2:	e8 31 31 00 00       	call   80103e18 <acquire>
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
80100d03:	e8 75 31 00 00       	call   80103e7d <release>
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
80100d13:	68 bc 67 10 80       	push   $0x801067bc
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
80100d49:	e8 2f 31 00 00       	call   80103e7d <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 2d 1c 00 00       	call   80102990 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 97 1c 00 00       	call   80102a0a <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 7c 22 00 00       	call   80103004 <pipeclose>
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
80100e3c:	e8 1b 23 00 00       	call   8010315c <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 c6 67 10 80       	push   $0x801067c6
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
80100e95:	e8 f6 21 00 00       	call   80103090 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 e9 1a 00 00       	call   80102990 <begin_op>
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
80100edd:	e8 28 1b 00 00       	call   80102a0a <end_op>

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
80100f10:	68 cf 67 10 80       	push   $0x801067cf
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
80100f2d:	68 d5 67 10 80       	push   $0x801067d5
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
80100f8a:	e8 b0 2f 00 00       	call   80103f3f <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 a0 2f 00 00       	call   80103f3f <memmove>
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
80100fdf:	e8 e0 2e 00 00       	call   80103ec4 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 cd 1a 00 00       	call   80102ab9 <log_write>
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
801010a3:	68 df 67 10 80       	push   $0x801067df
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
801010bf:	e8 f5 19 00 00       	call   80102ab9 <log_write>
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
80101170:	e8 44 19 00 00       	call   80102ab9 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 f5 67 10 80       	push   $0x801067f5
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
8010119a:	e8 79 2c 00 00       	call   80103e18 <acquire>
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
801011e1:	e8 97 2c 00 00       	call   80103e7d <release>
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
80101217:	e8 61 2c 00 00       	call   80103e7d <release>
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
8010122c:	68 08 68 10 80       	push   $0x80106808
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
80101255:	e8 e5 2c 00 00       	call   80103f3f <memmove>
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
801012c8:	e8 ec 17 00 00       	call   80102ab9 <log_write>
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
801012e2:	68 18 68 10 80       	push   $0x80106818
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 2b 68 10 80       	push   $0x8010682b
801012f8:	68 e0 09 11 80       	push   $0x801109e0
801012fd:	e8 da 29 00 00       	call   80103cdc <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 32 68 10 80       	push   $0x80106832
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101321:	50                   	push   %eax
80101322:	e8 aa 28 00 00       	call   80103bd1 <initsleeplock>
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
8010136c:	68 98 68 10 80       	push   $0x80106898
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
801013df:	68 38 68 10 80       	push   $0x80106838
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 ce 2a 00 00       	call   80103ec4 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 b4 16 00 00       	call   80102ab9 <log_write>
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
80101480:	e8 ba 2a 00 00       	call   80103f3f <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 2c 16 00 00       	call   80102ab9 <log_write>
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
80101560:	e8 b3 28 00 00       	call   80103e18 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101575:	e8 03 29 00 00       	call   80103e7d <release>
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
8010159a:	e8 65 26 00 00       	call   80103c04 <acquiresleep>
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
801015b2:	68 4a 68 10 80       	push   $0x8010684a
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
80101614:	e8 26 29 00 00       	call   80103f3f <memmove>
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
80101639:	68 50 68 10 80       	push   $0x80106850
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
80101656:	e8 33 26 00 00       	call   80103c8e <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 e2 25 00 00       	call   80103c53 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 5f 68 10 80       	push   $0x8010685f
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
80101698:	e8 67 25 00 00       	call   80103c04 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 9d 25 00 00       	call   80103c53 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016bd:	e8 56 27 00 00       	call   80103e18 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d2:	e8 a6 27 00 00       	call   80103e7d <release>
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
801016ea:	e8 29 27 00 00       	call   80103e18 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016f9:	e8 7f 27 00 00       	call   80103e7d <release>
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
8010182a:	e8 10 27 00 00       	call   80103f3f <memmove>
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
80101926:	e8 14 26 00 00       	call   80103f3f <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 86 11 00 00       	call   80102ab9 <log_write>
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
801019a9:	e8 f8 25 00 00       	call   80103fa6 <strncmp>
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
801019d0:	68 67 68 10 80       	push   $0x80106867
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 79 68 10 80       	push   $0x80106879
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
80101a5a:	e8 a9 19 00 00       	call   80103408 <myproc>
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
80101b92:	68 88 68 10 80       	push   $0x80106888
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 35 24 00 00       	call   80103fe3 <strncpy>
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
80101bd7:	68 14 6f 10 80       	push   $0x80106f14
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
80101ccc:	68 eb 68 10 80       	push   $0x801068eb
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 f4 68 10 80       	push   $0x801068f4
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
80101d06:	68 06 69 10 80       	push   $0x80106906
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 c7 1f 00 00       	call   80103cdc <initlock>
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
80101d80:	e8 93 20 00 00       	call   80103e18 <acquire>

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
80101dad:	e8 69 1c 00 00       	call   80103a1b <wakeup>

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
80101dcb:	e8 ad 20 00 00       	call   80103e7d <release>
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
80101de2:	e8 96 20 00 00       	call   80103e7d <release>
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
80101e1a:	e8 6f 1e 00 00       	call   80103c8e <holdingsleep>
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
80101e47:	e8 cc 1f 00 00       	call   80103e18 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 0a 69 10 80       	push   $0x8010690a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 20 69 10 80       	push   $0x80106920
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 35 69 10 80       	push   $0x80106935
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
80101ea9:	e8 08 1a 00 00       	call   801038b6 <sleep>
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
80101ec3:	e8 b5 1f 00 00       	call   80103e7d <release>
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
80101f3f:	68 54 69 10 80       	push   $0x80106954
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
80101fd6:	e8 e9 1e 00 00       	call   80103ec4 <memset>
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
80102005:	68 86 69 10 80       	push   $0x80106986
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 40 26 11 80       	push   $0x80112640
80102017:	e8 fc 1d 00 00       	call   80103e18 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 40 26 11 80       	push   $0x80112640
80102029:	e8 4f 1e 00 00       	call   80103e7d <release>
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
8010206f:	68 8c 69 10 80       	push   $0x8010698c
80102074:	68 40 26 11 80       	push   $0x80112640
80102079:	e8 5e 1c 00 00       	call   80103cdc <initlock>
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

  //cprintf("ALLOCATED KALLOC: Numframes: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
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
80102121:	e8 f2 1c 00 00       	call   80103e18 <acquire>
80102126:	83 c4 10             	add    $0x10,%esp
80102129:	eb a0                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
8010212b:	83 ec 0c             	sub    $0xc,%esp
8010212e:	68 40 26 11 80       	push   $0x80112640
80102133:	e8 45 1d 00 00       	call   80103e7d <release>
80102138:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010213b:	eb d5                	jmp    80102112 <kalloc+0x57>

8010213d <kalloc1a>:


char*
kalloc1a(int processPid)
{
8010213d:	55                   	push   %ebp
8010213e:	89 e5                	mov    %esp,%ebp
80102140:	56                   	push   %esi
80102141:	53                   	push   %ebx
80102142:	8b 75 08             	mov    0x8(%ebp),%esi
  struct run *r;

  if(kmem.use_lock)
80102145:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010214c:	75 5c                	jne    801021aa <kalloc1a+0x6d>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010214e:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
80102154:	85 db                	test   %ebx,%ebx
80102156:	74 09                	je     80102161 <kalloc1a+0x24>
    kmem.freelist = r->next->next;
80102158:	8b 03                	mov    (%ebx),%eax
8010215a:	8b 00                	mov    (%eax),%eax
8010215c:	a3 78 26 11 80       	mov    %eax,0x80112678

  char* ptr = (char*)r;
  //cprintf("Allocated KALLOC1A: %x \t %x \t %x \n", PHYSTOP - V2P(ptr), PHYSTOP - (V2P(ptr) >> 12 ), (V2P(ptr) >> 12 & 0xffff));
  //int i;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
80102161:	8d 93 00 00 00 80    	lea    -0x80000000(%ebx),%edx
80102167:	c1 ea 0c             	shr    $0xc,%edx
8010216a:	0f b7 d2             	movzwl %dx,%edx
  for(int z = i+1; z<numframes; z++) {
	frames[z] = frames[z-1];
	pid[z] = pid[z-1];
  } */
  
  numframes++;
8010216d:	a1 00 80 10 80       	mov    0x80108000,%eax
80102172:	83 c0 01             	add    $0x1,%eax
80102175:	a3 00 80 10 80       	mov    %eax,0x80108000
  frames[numframes] = frameNumberFound;
8010217a:	89 14 85 80 ea 1a 80 	mov    %edx,-0x7fe51580(,%eax,4)
  pid[numframes] = processPid;
80102181:	89 34 85 80 26 11 80 	mov    %esi,-0x7feed980(,%eax,4)

  cprintf("ALLOCATED KALLOC1A: Numframes: %d, i: not there currently , frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
80102188:	56                   	push   %esi
80102189:	52                   	push   %edx
8010218a:	50                   	push   %eax
8010218b:	68 94 69 10 80       	push   $0x80106994
80102190:	e8 76 e4 ff ff       	call   8010060b <cprintf>
  //cprintf("0. %x %d \n", frames[0], pid[0]);
  //cprintf("64. %x %d \n", frames[64], pid[64]);
  if(kmem.use_lock)
80102195:	83 c4 10             	add    $0x10,%esp
80102198:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010219f:	75 1b                	jne    801021bc <kalloc1a+0x7f>
    release(&kmem.lock);
  return (char*)r;
}
801021a1:	89 d8                	mov    %ebx,%eax
801021a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801021a6:	5b                   	pop    %ebx
801021a7:	5e                   	pop    %esi
801021a8:	5d                   	pop    %ebp
801021a9:	c3                   	ret    
    acquire(&kmem.lock);
801021aa:	83 ec 0c             	sub    $0xc,%esp
801021ad:	68 40 26 11 80       	push   $0x80112640
801021b2:	e8 61 1c 00 00       	call   80103e18 <acquire>
801021b7:	83 c4 10             	add    $0x10,%esp
801021ba:	eb 92                	jmp    8010214e <kalloc1a+0x11>
    release(&kmem.lock);
801021bc:	83 ec 0c             	sub    $0xc,%esp
801021bf:	68 40 26 11 80       	push   $0x80112640
801021c4:	e8 b4 1c 00 00       	call   80103e7d <release>
801021c9:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801021cc:	eb d3                	jmp    801021a1 <kalloc1a+0x64>

801021ce <kalloc2>:

char*
kalloc2(int processPid)
{
801021ce:	55                   	push   %ebp
801021cf:	89 e5                	mov    %esp,%ebp
801021d1:	57                   	push   %edi
801021d2:	56                   	push   %esi
801021d3:	53                   	push   %ebx
801021d4:	83 ec 1c             	sub    $0x1c,%esp
  struct run *r, *head;
  head = kmem.freelist;
801021d7:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx

  if(kmem.use_lock)
801021dd:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801021e4:	75 62                	jne    80102248 <kalloc2+0x7a>
     acquire(&kmem.lock);
  int firstPass = 1;
801021e6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
801021ed:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  
  repeat: 
  if(firstPass) {
801021f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801021f4:	74 64                	je     8010225a <kalloc2+0x8c>
    r = kmem.freelist;
801021f6:	8b 35 78 26 11 80    	mov    0x80112678,%esi
    firstPass = 0;
801021fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  } else {
    r = r->next;
  }

  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
80102203:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80102209:	c1 e8 0c             	shr    $0xc,%eax
8010220c:	0f b7 d8             	movzwl %ax,%ebx
 
  int i;
  for(i = 0; i<numframes; i++) {
8010220f:	bf 00 00 00 00       	mov    $0x0,%edi
80102214:	8b 0d 00 80 10 80    	mov    0x80108000,%ecx
8010221a:	39 f9                	cmp    %edi,%ecx
8010221c:	7e 19                	jle    80102237 <kalloc2+0x69>
     if(frames[i] == (frameNumberFound - 1)) {
8010221e:	8b 04 bd 80 ea 1a 80 	mov    -0x7fe51580(,%edi,4),%eax
80102225:	8d 53 ff             	lea    -0x1(%ebx),%edx
80102228:	39 d0                	cmp    %edx,%eax
8010222a:	74 32                	je     8010225e <kalloc2+0x90>
          if(pid[i] != processPid) {
             goto repeat;
	  }		  
     }
     if(frames[i] == (frameNumberFound + 1)) {
8010222c:	8d 53 01             	lea    0x1(%ebx),%edx
8010222f:	39 d0                	cmp    %edx,%eax
80102231:	74 39                	je     8010226c <kalloc2+0x9e>
         if(pid[i] != processPid) {
            goto repeat;
	 }
     }
     if(frames[i] > (frameNumberFound)) {
80102233:	39 d8                	cmp    %ebx,%eax
80102235:	7f 46                	jg     8010227d <kalloc2+0xaf>
80102237:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
         continue;
     }
     break;
  }
  
  numframes++;
8010223a:	83 c1 01             	add    $0x1,%ecx
8010223d:	89 0d 00 80 10 80    	mov    %ecx,0x80108000
  for(int z = i+1; z<numframes; z++) {
80102243:	8d 47 01             	lea    0x1(%edi),%eax
80102246:	eb 5c                	jmp    801022a4 <kalloc2+0xd6>
     acquire(&kmem.lock);
80102248:	83 ec 0c             	sub    $0xc,%esp
8010224b:	68 40 26 11 80       	push   $0x80112640
80102250:	e8 c3 1b 00 00       	call   80103e18 <acquire>
80102255:	83 c4 10             	add    $0x10,%esp
80102258:	eb 8c                	jmp    801021e6 <kalloc2+0x18>
    r = r->next;
8010225a:	8b 36                	mov    (%esi),%esi
8010225c:	eb a5                	jmp    80102203 <kalloc2+0x35>
          if(pid[i] != processPid) {
8010225e:	8b 55 08             	mov    0x8(%ebp),%edx
80102261:	39 14 bd 80 26 11 80 	cmp    %edx,-0x7feed980(,%edi,4)
80102268:	74 c2                	je     8010222c <kalloc2+0x5e>
  repeat: 
8010226a:	eb 84                	jmp    801021f0 <kalloc2+0x22>
         if(pid[i] != processPid) {
8010226c:	8b 55 08             	mov    0x8(%ebp),%edx
8010226f:	39 14 bd 80 26 11 80 	cmp    %edx,-0x7feed980(,%edi,4)
80102276:	74 bb                	je     80102233 <kalloc2+0x65>
  repeat: 
80102278:	e9 73 ff ff ff       	jmp    801021f0 <kalloc2+0x22>
  for(i = 0; i<numframes; i++) {
8010227d:	83 c7 01             	add    $0x1,%edi
80102280:	eb 92                	jmp    80102214 <kalloc2+0x46>
     frames[z] = frames[z-1];
80102282:	8d 50 ff             	lea    -0x1(%eax),%edx
80102285:	8b 1c 95 80 ea 1a 80 	mov    -0x7fe51580(,%edx,4),%ebx
8010228c:	89 1c 85 80 ea 1a 80 	mov    %ebx,-0x7fe51580(,%eax,4)
     pid[z] = pid[z-1];
80102293:	8b 14 95 80 26 11 80 	mov    -0x7feed980(,%edx,4),%edx
8010229a:	89 14 85 80 26 11 80 	mov    %edx,-0x7feed980(,%eax,4)
  for(int z = i+1; z<numframes; z++) {
801022a1:	83 c0 01             	add    $0x1,%eax
801022a4:	39 c1                	cmp    %eax,%ecx
801022a6:	7f da                	jg     80102282 <kalloc2+0xb4>
801022a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  }
  frames[i] = frameNumberFound;
801022ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801022ae:	89 04 bd 80 ea 1a 80 	mov    %eax,-0x7fe51580(,%edi,4)
  pid[i] = processPid;
801022b5:	8b 45 08             	mov    0x8(%ebp),%eax
801022b8:	89 04 bd 80 26 11 80 	mov    %eax,-0x7feed980(,%edi,4)

  while(head->next != r) {
801022bf:	eb 02                	jmp    801022c3 <kalloc2+0xf5>
      head = head->next;
801022c1:	89 c3                	mov    %eax,%ebx
  while(head->next != r) {
801022c3:	8b 03                	mov    (%ebx),%eax
801022c5:	39 f0                	cmp    %esi,%eax
801022c7:	75 f8                	jne    801022c1 <kalloc2+0xf3>
  }
  head->next = r->next;
801022c9:	8b 06                	mov    (%esi),%eax
801022cb:	89 03                	mov    %eax,(%ebx)

  if(!kmem.use_lock)
801022cd:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801022d4:	74 0a                	je     801022e0 <kalloc2+0x112>
     release(&kmem.lock);
  return (char*)r;
}
801022d6:	89 f0                	mov    %esi,%eax
801022d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022db:	5b                   	pop    %ebx
801022dc:	5e                   	pop    %esi
801022dd:	5f                   	pop    %edi
801022de:	5d                   	pop    %ebp
801022df:	c3                   	ret    
     release(&kmem.lock);
801022e0:	83 ec 0c             	sub    $0xc,%esp
801022e3:	68 40 26 11 80       	push   $0x80112640
801022e8:	e8 90 1b 00 00       	call   80103e7d <release>
801022ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801022f0:	eb e4                	jmp    801022d6 <kalloc2+0x108>

801022f2 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801022f2:	55                   	push   %ebp
801022f3:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022f5:	ba 64 00 00 00       	mov    $0x64,%edx
801022fa:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022fb:	a8 01                	test   $0x1,%al
801022fd:	0f 84 b5 00 00 00    	je     801023b8 <kbdgetc+0xc6>
80102303:	ba 60 00 00 00       	mov    $0x60,%edx
80102308:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102309:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010230c:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102312:	74 5c                	je     80102370 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102314:	84 c0                	test   %al,%al
80102316:	78 66                	js     8010237e <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102318:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010231e:	f6 c1 40             	test   $0x40,%cl
80102321:	74 0f                	je     80102332 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102323:	83 c8 80             	or     $0xffffff80,%eax
80102326:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102329:	83 e1 bf             	and    $0xffffffbf,%ecx
8010232c:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102332:	0f b6 8a 40 6b 10 80 	movzbl -0x7fef94c0(%edx),%ecx
80102339:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
8010233f:	0f b6 82 40 6a 10 80 	movzbl -0x7fef95c0(%edx),%eax
80102346:	31 c1                	xor    %eax,%ecx
80102348:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010234e:	89 c8                	mov    %ecx,%eax
80102350:	83 e0 03             	and    $0x3,%eax
80102353:	8b 04 85 20 6a 10 80 	mov    -0x7fef95e0(,%eax,4),%eax
8010235a:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010235e:	f6 c1 08             	test   $0x8,%cl
80102361:	74 19                	je     8010237c <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102363:	8d 50 9f             	lea    -0x61(%eax),%edx
80102366:	83 fa 19             	cmp    $0x19,%edx
80102369:	77 40                	ja     801023ab <kbdgetc+0xb9>
      c += 'A' - 'a';
8010236b:	83 e8 20             	sub    $0x20,%eax
8010236e:	eb 0c                	jmp    8010237c <kbdgetc+0x8a>
    shift |= E0ESC;
80102370:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
80102377:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010237c:	5d                   	pop    %ebp
8010237d:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010237e:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102384:	f6 c1 40             	test   $0x40,%cl
80102387:	75 05                	jne    8010238e <kbdgetc+0x9c>
80102389:	89 c2                	mov    %eax,%edx
8010238b:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
8010238e:	0f b6 82 40 6b 10 80 	movzbl -0x7fef94c0(%edx),%eax
80102395:	83 c8 40             	or     $0x40,%eax
80102398:	0f b6 c0             	movzbl %al,%eax
8010239b:	f7 d0                	not    %eax
8010239d:	21 c8                	and    %ecx,%eax
8010239f:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
801023a4:	b8 00 00 00 00       	mov    $0x0,%eax
801023a9:	eb d1                	jmp    8010237c <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801023ab:	8d 50 bf             	lea    -0x41(%eax),%edx
801023ae:	83 fa 19             	cmp    $0x19,%edx
801023b1:	77 c9                	ja     8010237c <kbdgetc+0x8a>
      c += 'a' - 'A';
801023b3:	83 c0 20             	add    $0x20,%eax
  return c;
801023b6:	eb c4                	jmp    8010237c <kbdgetc+0x8a>
    return -1;
801023b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023bd:	eb bd                	jmp    8010237c <kbdgetc+0x8a>

801023bf <kbdintr>:

void
kbdintr(void)
{
801023bf:	55                   	push   %ebp
801023c0:	89 e5                	mov    %esp,%ebp
801023c2:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801023c5:	68 f2 22 10 80       	push   $0x801022f2
801023ca:	e8 6f e3 ff ff       	call   8010073e <consoleintr>
}
801023cf:	83 c4 10             	add    $0x10,%esp
801023d2:	c9                   	leave  
801023d3:	c3                   	ret    

801023d4 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801023d4:	55                   	push   %ebp
801023d5:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801023d7:	8b 0d 80 e4 1b 80    	mov    0x801be480,%ecx
801023dd:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801023e0:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023e2:	a1 80 e4 1b 80       	mov    0x801be480,%eax
801023e7:	8b 40 20             	mov    0x20(%eax),%eax
}
801023ea:	5d                   	pop    %ebp
801023eb:	c3                   	ret    

801023ec <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801023ec:	55                   	push   %ebp
801023ed:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023ef:	ba 70 00 00 00       	mov    $0x70,%edx
801023f4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023f5:	ba 71 00 00 00       	mov    $0x71,%edx
801023fa:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801023fb:	0f b6 c0             	movzbl %al,%eax
}
801023fe:	5d                   	pop    %ebp
801023ff:	c3                   	ret    

80102400 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102400:	55                   	push   %ebp
80102401:	89 e5                	mov    %esp,%ebp
80102403:	53                   	push   %ebx
80102404:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102406:	b8 00 00 00 00       	mov    $0x0,%eax
8010240b:	e8 dc ff ff ff       	call   801023ec <cmos_read>
80102410:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102412:	b8 02 00 00 00       	mov    $0x2,%eax
80102417:	e8 d0 ff ff ff       	call   801023ec <cmos_read>
8010241c:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010241f:	b8 04 00 00 00       	mov    $0x4,%eax
80102424:	e8 c3 ff ff ff       	call   801023ec <cmos_read>
80102429:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010242c:	b8 07 00 00 00       	mov    $0x7,%eax
80102431:	e8 b6 ff ff ff       	call   801023ec <cmos_read>
80102436:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102439:	b8 08 00 00 00       	mov    $0x8,%eax
8010243e:	e8 a9 ff ff ff       	call   801023ec <cmos_read>
80102443:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102446:	b8 09 00 00 00       	mov    $0x9,%eax
8010244b:	e8 9c ff ff ff       	call   801023ec <cmos_read>
80102450:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102453:	5b                   	pop    %ebx
80102454:	5d                   	pop    %ebp
80102455:	c3                   	ret    

80102456 <lapicinit>:
  if(!lapic)
80102456:	83 3d 80 e4 1b 80 00 	cmpl   $0x0,0x801be480
8010245d:	0f 84 fb 00 00 00    	je     8010255e <lapicinit+0x108>
{
80102463:	55                   	push   %ebp
80102464:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102466:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010246b:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102470:	e8 5f ff ff ff       	call   801023d4 <lapicw>
  lapicw(TDCR, X1);
80102475:	ba 0b 00 00 00       	mov    $0xb,%edx
8010247a:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010247f:	e8 50 ff ff ff       	call   801023d4 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102484:	ba 20 00 02 00       	mov    $0x20020,%edx
80102489:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010248e:	e8 41 ff ff ff       	call   801023d4 <lapicw>
  lapicw(TICR, 10000000);
80102493:	ba 80 96 98 00       	mov    $0x989680,%edx
80102498:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010249d:	e8 32 ff ff ff       	call   801023d4 <lapicw>
  lapicw(LINT0, MASKED);
801024a2:	ba 00 00 01 00       	mov    $0x10000,%edx
801024a7:	b8 d4 00 00 00       	mov    $0xd4,%eax
801024ac:	e8 23 ff ff ff       	call   801023d4 <lapicw>
  lapicw(LINT1, MASKED);
801024b1:	ba 00 00 01 00       	mov    $0x10000,%edx
801024b6:	b8 d8 00 00 00       	mov    $0xd8,%eax
801024bb:	e8 14 ff ff ff       	call   801023d4 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801024c0:	a1 80 e4 1b 80       	mov    0x801be480,%eax
801024c5:	8b 40 30             	mov    0x30(%eax),%eax
801024c8:	c1 e8 10             	shr    $0x10,%eax
801024cb:	3c 03                	cmp    $0x3,%al
801024cd:	77 7b                	ja     8010254a <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801024cf:	ba 33 00 00 00       	mov    $0x33,%edx
801024d4:	b8 dc 00 00 00       	mov    $0xdc,%eax
801024d9:	e8 f6 fe ff ff       	call   801023d4 <lapicw>
  lapicw(ESR, 0);
801024de:	ba 00 00 00 00       	mov    $0x0,%edx
801024e3:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024e8:	e8 e7 fe ff ff       	call   801023d4 <lapicw>
  lapicw(ESR, 0);
801024ed:	ba 00 00 00 00       	mov    $0x0,%edx
801024f2:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024f7:	e8 d8 fe ff ff       	call   801023d4 <lapicw>
  lapicw(EOI, 0);
801024fc:	ba 00 00 00 00       	mov    $0x0,%edx
80102501:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102506:	e8 c9 fe ff ff       	call   801023d4 <lapicw>
  lapicw(ICRHI, 0);
8010250b:	ba 00 00 00 00       	mov    $0x0,%edx
80102510:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102515:	e8 ba fe ff ff       	call   801023d4 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010251a:	ba 00 85 08 00       	mov    $0x88500,%edx
8010251f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102524:	e8 ab fe ff ff       	call   801023d4 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102529:	a1 80 e4 1b 80       	mov    0x801be480,%eax
8010252e:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102534:	f6 c4 10             	test   $0x10,%ah
80102537:	75 f0                	jne    80102529 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102539:	ba 00 00 00 00       	mov    $0x0,%edx
8010253e:	b8 20 00 00 00       	mov    $0x20,%eax
80102543:	e8 8c fe ff ff       	call   801023d4 <lapicw>
}
80102548:	5d                   	pop    %ebp
80102549:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010254a:	ba 00 00 01 00       	mov    $0x10000,%edx
8010254f:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102554:	e8 7b fe ff ff       	call   801023d4 <lapicw>
80102559:	e9 71 ff ff ff       	jmp    801024cf <lapicinit+0x79>
8010255e:	f3 c3                	repz ret 

80102560 <lapicid>:
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102563:	a1 80 e4 1b 80       	mov    0x801be480,%eax
80102568:	85 c0                	test   %eax,%eax
8010256a:	74 08                	je     80102574 <lapicid+0x14>
  return lapic[ID] >> 24;
8010256c:	8b 40 20             	mov    0x20(%eax),%eax
8010256f:	c1 e8 18             	shr    $0x18,%eax
}
80102572:	5d                   	pop    %ebp
80102573:	c3                   	ret    
    return 0;
80102574:	b8 00 00 00 00       	mov    $0x0,%eax
80102579:	eb f7                	jmp    80102572 <lapicid+0x12>

8010257b <lapiceoi>:
  if(lapic)
8010257b:	83 3d 80 e4 1b 80 00 	cmpl   $0x0,0x801be480
80102582:	74 14                	je     80102598 <lapiceoi+0x1d>
{
80102584:	55                   	push   %ebp
80102585:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102587:	ba 00 00 00 00       	mov    $0x0,%edx
8010258c:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102591:	e8 3e fe ff ff       	call   801023d4 <lapicw>
}
80102596:	5d                   	pop    %ebp
80102597:	c3                   	ret    
80102598:	f3 c3                	repz ret 

8010259a <microdelay>:
{
8010259a:	55                   	push   %ebp
8010259b:	89 e5                	mov    %esp,%ebp
}
8010259d:	5d                   	pop    %ebp
8010259e:	c3                   	ret    

8010259f <lapicstartap>:
{
8010259f:	55                   	push   %ebp
801025a0:	89 e5                	mov    %esp,%ebp
801025a2:	57                   	push   %edi
801025a3:	56                   	push   %esi
801025a4:	53                   	push   %ebx
801025a5:	8b 75 08             	mov    0x8(%ebp),%esi
801025a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ab:	b8 0f 00 00 00       	mov    $0xf,%eax
801025b0:	ba 70 00 00 00       	mov    $0x70,%edx
801025b5:	ee                   	out    %al,(%dx)
801025b6:	b8 0a 00 00 00       	mov    $0xa,%eax
801025bb:	ba 71 00 00 00       	mov    $0x71,%edx
801025c0:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801025c1:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801025c8:	00 00 
  wrv[1] = addr >> 4;
801025ca:	89 f8                	mov    %edi,%eax
801025cc:	c1 e8 04             	shr    $0x4,%eax
801025cf:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801025d5:	c1 e6 18             	shl    $0x18,%esi
801025d8:	89 f2                	mov    %esi,%edx
801025da:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025df:	e8 f0 fd ff ff       	call   801023d4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801025e4:	ba 00 c5 00 00       	mov    $0xc500,%edx
801025e9:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025ee:	e8 e1 fd ff ff       	call   801023d4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801025f3:	ba 00 85 00 00       	mov    $0x8500,%edx
801025f8:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025fd:	e8 d2 fd ff ff       	call   801023d4 <lapicw>
  for(i = 0; i < 2; i++){
80102602:	bb 00 00 00 00       	mov    $0x0,%ebx
80102607:	eb 21                	jmp    8010262a <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102609:	89 f2                	mov    %esi,%edx
8010260b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102610:	e8 bf fd ff ff       	call   801023d4 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102615:	89 fa                	mov    %edi,%edx
80102617:	c1 ea 0c             	shr    $0xc,%edx
8010261a:	80 ce 06             	or     $0x6,%dh
8010261d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102622:	e8 ad fd ff ff       	call   801023d4 <lapicw>
  for(i = 0; i < 2; i++){
80102627:	83 c3 01             	add    $0x1,%ebx
8010262a:	83 fb 01             	cmp    $0x1,%ebx
8010262d:	7e da                	jle    80102609 <lapicstartap+0x6a>
}
8010262f:	5b                   	pop    %ebx
80102630:	5e                   	pop    %esi
80102631:	5f                   	pop    %edi
80102632:	5d                   	pop    %ebp
80102633:	c3                   	ret    

80102634 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102634:	55                   	push   %ebp
80102635:	89 e5                	mov    %esp,%ebp
80102637:	57                   	push   %edi
80102638:	56                   	push   %esi
80102639:	53                   	push   %ebx
8010263a:	83 ec 3c             	sub    $0x3c,%esp
8010263d:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102640:	b8 0b 00 00 00       	mov    $0xb,%eax
80102645:	e8 a2 fd ff ff       	call   801023ec <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010264a:	83 e0 04             	and    $0x4,%eax
8010264d:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010264f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102652:	e8 a9 fd ff ff       	call   80102400 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102657:	b8 0a 00 00 00       	mov    $0xa,%eax
8010265c:	e8 8b fd ff ff       	call   801023ec <cmos_read>
80102661:	a8 80                	test   $0x80,%al
80102663:	75 ea                	jne    8010264f <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102665:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102668:	89 d8                	mov    %ebx,%eax
8010266a:	e8 91 fd ff ff       	call   80102400 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010266f:	83 ec 04             	sub    $0x4,%esp
80102672:	6a 18                	push   $0x18
80102674:	53                   	push   %ebx
80102675:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102678:	50                   	push   %eax
80102679:	e8 8c 18 00 00       	call   80103f0a <memcmp>
8010267e:	83 c4 10             	add    $0x10,%esp
80102681:	85 c0                	test   %eax,%eax
80102683:	75 ca                	jne    8010264f <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102685:	85 ff                	test   %edi,%edi
80102687:	0f 85 84 00 00 00    	jne    80102711 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010268d:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102690:	89 d0                	mov    %edx,%eax
80102692:	c1 e8 04             	shr    $0x4,%eax
80102695:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102698:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010269b:	83 e2 0f             	and    $0xf,%edx
8010269e:	01 d0                	add    %edx,%eax
801026a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801026a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801026a6:	89 d0                	mov    %edx,%eax
801026a8:	c1 e8 04             	shr    $0x4,%eax
801026ab:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026ae:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026b1:	83 e2 0f             	and    $0xf,%edx
801026b4:	01 d0                	add    %edx,%eax
801026b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801026b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801026bc:	89 d0                	mov    %edx,%eax
801026be:	c1 e8 04             	shr    $0x4,%eax
801026c1:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026c4:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026c7:	83 e2 0f             	and    $0xf,%edx
801026ca:	01 d0                	add    %edx,%eax
801026cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801026cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
801026d2:	89 d0                	mov    %edx,%eax
801026d4:	c1 e8 04             	shr    $0x4,%eax
801026d7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026da:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026dd:	83 e2 0f             	and    $0xf,%edx
801026e0:	01 d0                	add    %edx,%eax
801026e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801026e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801026e8:	89 d0                	mov    %edx,%eax
801026ea:	c1 e8 04             	shr    $0x4,%eax
801026ed:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026f0:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026f3:	83 e2 0f             	and    $0xf,%edx
801026f6:	01 d0                	add    %edx,%eax
801026f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801026fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801026fe:	89 d0                	mov    %edx,%eax
80102700:	c1 e8 04             	shr    $0x4,%eax
80102703:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102706:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102709:	83 e2 0f             	and    $0xf,%edx
8010270c:	01 d0                	add    %edx,%eax
8010270e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102711:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102714:	89 06                	mov    %eax,(%esi)
80102716:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102719:	89 46 04             	mov    %eax,0x4(%esi)
8010271c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010271f:	89 46 08             	mov    %eax,0x8(%esi)
80102722:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102725:	89 46 0c             	mov    %eax,0xc(%esi)
80102728:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010272b:	89 46 10             	mov    %eax,0x10(%esi)
8010272e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102731:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102734:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010273b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010273e:	5b                   	pop    %ebx
8010273f:	5e                   	pop    %esi
80102740:	5f                   	pop    %edi
80102741:	5d                   	pop    %ebp
80102742:	c3                   	ret    

80102743 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102743:	55                   	push   %ebp
80102744:	89 e5                	mov    %esp,%ebp
80102746:	53                   	push   %ebx
80102747:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010274a:	ff 35 d4 e4 1b 80    	pushl  0x801be4d4
80102750:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
80102756:	e8 11 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010275b:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010275e:	89 1d e8 e4 1b 80    	mov    %ebx,0x801be4e8
  for (i = 0; i < log.lh.n; i++) {
80102764:	83 c4 10             	add    $0x10,%esp
80102767:	ba 00 00 00 00       	mov    $0x0,%edx
8010276c:	eb 0e                	jmp    8010277c <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010276e:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102772:	89 0c 95 ec e4 1b 80 	mov    %ecx,-0x7fe41b14(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102779:	83 c2 01             	add    $0x1,%edx
8010277c:	39 d3                	cmp    %edx,%ebx
8010277e:	7f ee                	jg     8010276e <read_head+0x2b>
  }
  brelse(buf);
80102780:	83 ec 0c             	sub    $0xc,%esp
80102783:	50                   	push   %eax
80102784:	e8 4c da ff ff       	call   801001d5 <brelse>
}
80102789:	83 c4 10             	add    $0x10,%esp
8010278c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010278f:	c9                   	leave  
80102790:	c3                   	ret    

80102791 <install_trans>:
{
80102791:	55                   	push   %ebp
80102792:	89 e5                	mov    %esp,%ebp
80102794:	57                   	push   %edi
80102795:	56                   	push   %esi
80102796:	53                   	push   %ebx
80102797:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010279a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010279f:	eb 66                	jmp    80102807 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801027a1:	89 d8                	mov    %ebx,%eax
801027a3:	03 05 d4 e4 1b 80    	add    0x801be4d4,%eax
801027a9:	83 c0 01             	add    $0x1,%eax
801027ac:	83 ec 08             	sub    $0x8,%esp
801027af:	50                   	push   %eax
801027b0:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801027b6:	e8 b1 d9 ff ff       	call   8010016c <bread>
801027bb:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801027bd:	83 c4 08             	add    $0x8,%esp
801027c0:	ff 34 9d ec e4 1b 80 	pushl  -0x7fe41b14(,%ebx,4)
801027c7:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801027cd:	e8 9a d9 ff ff       	call   8010016c <bread>
801027d2:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801027d4:	8d 57 5c             	lea    0x5c(%edi),%edx
801027d7:	8d 40 5c             	lea    0x5c(%eax),%eax
801027da:	83 c4 0c             	add    $0xc,%esp
801027dd:	68 00 02 00 00       	push   $0x200
801027e2:	52                   	push   %edx
801027e3:	50                   	push   %eax
801027e4:	e8 56 17 00 00       	call   80103f3f <memmove>
    bwrite(dbuf);  // write dst to disk
801027e9:	89 34 24             	mov    %esi,(%esp)
801027ec:	e8 a9 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801027f1:	89 3c 24             	mov    %edi,(%esp)
801027f4:	e8 dc d9 ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801027f9:	89 34 24             	mov    %esi,(%esp)
801027fc:	e8 d4 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102801:	83 c3 01             	add    $0x1,%ebx
80102804:	83 c4 10             	add    $0x10,%esp
80102807:	39 1d e8 e4 1b 80    	cmp    %ebx,0x801be4e8
8010280d:	7f 92                	jg     801027a1 <install_trans+0x10>
}
8010280f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102812:	5b                   	pop    %ebx
80102813:	5e                   	pop    %esi
80102814:	5f                   	pop    %edi
80102815:	5d                   	pop    %ebp
80102816:	c3                   	ret    

80102817 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102817:	55                   	push   %ebp
80102818:	89 e5                	mov    %esp,%ebp
8010281a:	53                   	push   %ebx
8010281b:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010281e:	ff 35 d4 e4 1b 80    	pushl  0x801be4d4
80102824:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
8010282a:	e8 3d d9 ff ff       	call   8010016c <bread>
8010282f:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102831:	8b 0d e8 e4 1b 80    	mov    0x801be4e8,%ecx
80102837:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010283a:	83 c4 10             	add    $0x10,%esp
8010283d:	b8 00 00 00 00       	mov    $0x0,%eax
80102842:	eb 0e                	jmp    80102852 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102844:	8b 14 85 ec e4 1b 80 	mov    -0x7fe41b14(,%eax,4),%edx
8010284b:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010284f:	83 c0 01             	add    $0x1,%eax
80102852:	39 c1                	cmp    %eax,%ecx
80102854:	7f ee                	jg     80102844 <write_head+0x2d>
  }
  bwrite(buf);
80102856:	83 ec 0c             	sub    $0xc,%esp
80102859:	53                   	push   %ebx
8010285a:	e8 3b d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010285f:	89 1c 24             	mov    %ebx,(%esp)
80102862:	e8 6e d9 ff ff       	call   801001d5 <brelse>
}
80102867:	83 c4 10             	add    $0x10,%esp
8010286a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010286d:	c9                   	leave  
8010286e:	c3                   	ret    

8010286f <recover_from_log>:

static void
recover_from_log(void)
{
8010286f:	55                   	push   %ebp
80102870:	89 e5                	mov    %esp,%ebp
80102872:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102875:	e8 c9 fe ff ff       	call   80102743 <read_head>
  install_trans(); // if committed, copy from log to disk
8010287a:	e8 12 ff ff ff       	call   80102791 <install_trans>
  log.lh.n = 0;
8010287f:	c7 05 e8 e4 1b 80 00 	movl   $0x0,0x801be4e8
80102886:	00 00 00 
  write_head(); // clear the log
80102889:	e8 89 ff ff ff       	call   80102817 <write_head>
}
8010288e:	c9                   	leave  
8010288f:	c3                   	ret    

80102890 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
80102893:	57                   	push   %edi
80102894:	56                   	push   %esi
80102895:	53                   	push   %ebx
80102896:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102899:	bb 00 00 00 00       	mov    $0x0,%ebx
8010289e:	eb 66                	jmp    80102906 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801028a0:	89 d8                	mov    %ebx,%eax
801028a2:	03 05 d4 e4 1b 80    	add    0x801be4d4,%eax
801028a8:	83 c0 01             	add    $0x1,%eax
801028ab:	83 ec 08             	sub    $0x8,%esp
801028ae:	50                   	push   %eax
801028af:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801028b5:	e8 b2 d8 ff ff       	call   8010016c <bread>
801028ba:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801028bc:	83 c4 08             	add    $0x8,%esp
801028bf:	ff 34 9d ec e4 1b 80 	pushl  -0x7fe41b14(,%ebx,4)
801028c6:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801028cc:	e8 9b d8 ff ff       	call   8010016c <bread>
801028d1:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801028d3:	8d 50 5c             	lea    0x5c(%eax),%edx
801028d6:	8d 46 5c             	lea    0x5c(%esi),%eax
801028d9:	83 c4 0c             	add    $0xc,%esp
801028dc:	68 00 02 00 00       	push   $0x200
801028e1:	52                   	push   %edx
801028e2:	50                   	push   %eax
801028e3:	e8 57 16 00 00       	call   80103f3f <memmove>
    bwrite(to);  // write the log
801028e8:	89 34 24             	mov    %esi,(%esp)
801028eb:	e8 aa d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
801028f0:	89 3c 24             	mov    %edi,(%esp)
801028f3:	e8 dd d8 ff ff       	call   801001d5 <brelse>
    brelse(to);
801028f8:	89 34 24             	mov    %esi,(%esp)
801028fb:	e8 d5 d8 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102900:	83 c3 01             	add    $0x1,%ebx
80102903:	83 c4 10             	add    $0x10,%esp
80102906:	39 1d e8 e4 1b 80    	cmp    %ebx,0x801be4e8
8010290c:	7f 92                	jg     801028a0 <write_log+0x10>
  }
}
8010290e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102911:	5b                   	pop    %ebx
80102912:	5e                   	pop    %esi
80102913:	5f                   	pop    %edi
80102914:	5d                   	pop    %ebp
80102915:	c3                   	ret    

80102916 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102916:	83 3d e8 e4 1b 80 00 	cmpl   $0x0,0x801be4e8
8010291d:	7e 26                	jle    80102945 <commit+0x2f>
{
8010291f:	55                   	push   %ebp
80102920:	89 e5                	mov    %esp,%ebp
80102922:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102925:	e8 66 ff ff ff       	call   80102890 <write_log>
    write_head();    // Write header to disk -- the real commit
8010292a:	e8 e8 fe ff ff       	call   80102817 <write_head>
    install_trans(); // Now install writes to home locations
8010292f:	e8 5d fe ff ff       	call   80102791 <install_trans>
    log.lh.n = 0;
80102934:	c7 05 e8 e4 1b 80 00 	movl   $0x0,0x801be4e8
8010293b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010293e:	e8 d4 fe ff ff       	call   80102817 <write_head>
  }
}
80102943:	c9                   	leave  
80102944:	c3                   	ret    
80102945:	f3 c3                	repz ret 

80102947 <initlog>:
{
80102947:	55                   	push   %ebp
80102948:	89 e5                	mov    %esp,%ebp
8010294a:	53                   	push   %ebx
8010294b:	83 ec 2c             	sub    $0x2c,%esp
8010294e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102951:	68 40 6c 10 80       	push   $0x80106c40
80102956:	68 a0 e4 1b 80       	push   $0x801be4a0
8010295b:	e8 7c 13 00 00       	call   80103cdc <initlock>
  readsb(dev, &sb);
80102960:	83 c4 08             	add    $0x8,%esp
80102963:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102966:	50                   	push   %eax
80102967:	53                   	push   %ebx
80102968:	e8 c9 e8 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
8010296d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102970:	a3 d4 e4 1b 80       	mov    %eax,0x801be4d4
  log.size = sb.nlog;
80102975:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102978:	a3 d8 e4 1b 80       	mov    %eax,0x801be4d8
  log.dev = dev;
8010297d:	89 1d e4 e4 1b 80    	mov    %ebx,0x801be4e4
  recover_from_log();
80102983:	e8 e7 fe ff ff       	call   8010286f <recover_from_log>
}
80102988:	83 c4 10             	add    $0x10,%esp
8010298b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010298e:	c9                   	leave  
8010298f:	c3                   	ret    

80102990 <begin_op>:
{
80102990:	55                   	push   %ebp
80102991:	89 e5                	mov    %esp,%ebp
80102993:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102996:	68 a0 e4 1b 80       	push   $0x801be4a0
8010299b:	e8 78 14 00 00       	call   80103e18 <acquire>
801029a0:	83 c4 10             	add    $0x10,%esp
801029a3:	eb 15                	jmp    801029ba <begin_op+0x2a>
      sleep(&log, &log.lock);
801029a5:	83 ec 08             	sub    $0x8,%esp
801029a8:	68 a0 e4 1b 80       	push   $0x801be4a0
801029ad:	68 a0 e4 1b 80       	push   $0x801be4a0
801029b2:	e8 ff 0e 00 00       	call   801038b6 <sleep>
801029b7:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801029ba:	83 3d e0 e4 1b 80 00 	cmpl   $0x0,0x801be4e0
801029c1:	75 e2                	jne    801029a5 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801029c3:	a1 dc e4 1b 80       	mov    0x801be4dc,%eax
801029c8:	83 c0 01             	add    $0x1,%eax
801029cb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801029ce:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801029d1:	03 15 e8 e4 1b 80    	add    0x801be4e8,%edx
801029d7:	83 fa 1e             	cmp    $0x1e,%edx
801029da:	7e 17                	jle    801029f3 <begin_op+0x63>
      sleep(&log, &log.lock);
801029dc:	83 ec 08             	sub    $0x8,%esp
801029df:	68 a0 e4 1b 80       	push   $0x801be4a0
801029e4:	68 a0 e4 1b 80       	push   $0x801be4a0
801029e9:	e8 c8 0e 00 00       	call   801038b6 <sleep>
801029ee:	83 c4 10             	add    $0x10,%esp
801029f1:	eb c7                	jmp    801029ba <begin_op+0x2a>
      log.outstanding += 1;
801029f3:	a3 dc e4 1b 80       	mov    %eax,0x801be4dc
      release(&log.lock);
801029f8:	83 ec 0c             	sub    $0xc,%esp
801029fb:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a00:	e8 78 14 00 00       	call   80103e7d <release>
}
80102a05:	83 c4 10             	add    $0x10,%esp
80102a08:	c9                   	leave  
80102a09:	c3                   	ret    

80102a0a <end_op>:
{
80102a0a:	55                   	push   %ebp
80102a0b:	89 e5                	mov    %esp,%ebp
80102a0d:	53                   	push   %ebx
80102a0e:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102a11:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a16:	e8 fd 13 00 00       	call   80103e18 <acquire>
  log.outstanding -= 1;
80102a1b:	a1 dc e4 1b 80       	mov    0x801be4dc,%eax
80102a20:	83 e8 01             	sub    $0x1,%eax
80102a23:	a3 dc e4 1b 80       	mov    %eax,0x801be4dc
  if(log.committing)
80102a28:	8b 1d e0 e4 1b 80    	mov    0x801be4e0,%ebx
80102a2e:	83 c4 10             	add    $0x10,%esp
80102a31:	85 db                	test   %ebx,%ebx
80102a33:	75 2c                	jne    80102a61 <end_op+0x57>
  if(log.outstanding == 0){
80102a35:	85 c0                	test   %eax,%eax
80102a37:	75 35                	jne    80102a6e <end_op+0x64>
    log.committing = 1;
80102a39:	c7 05 e0 e4 1b 80 01 	movl   $0x1,0x801be4e0
80102a40:	00 00 00 
    do_commit = 1;
80102a43:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102a48:	83 ec 0c             	sub    $0xc,%esp
80102a4b:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a50:	e8 28 14 00 00       	call   80103e7d <release>
  if(do_commit){
80102a55:	83 c4 10             	add    $0x10,%esp
80102a58:	85 db                	test   %ebx,%ebx
80102a5a:	75 24                	jne    80102a80 <end_op+0x76>
}
80102a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a5f:	c9                   	leave  
80102a60:	c3                   	ret    
    panic("log.committing");
80102a61:	83 ec 0c             	sub    $0xc,%esp
80102a64:	68 44 6c 10 80       	push   $0x80106c44
80102a69:	e8 da d8 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102a6e:	83 ec 0c             	sub    $0xc,%esp
80102a71:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a76:	e8 a0 0f 00 00       	call   80103a1b <wakeup>
80102a7b:	83 c4 10             	add    $0x10,%esp
80102a7e:	eb c8                	jmp    80102a48 <end_op+0x3e>
    commit();
80102a80:	e8 91 fe ff ff       	call   80102916 <commit>
    acquire(&log.lock);
80102a85:	83 ec 0c             	sub    $0xc,%esp
80102a88:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a8d:	e8 86 13 00 00       	call   80103e18 <acquire>
    log.committing = 0;
80102a92:	c7 05 e0 e4 1b 80 00 	movl   $0x0,0x801be4e0
80102a99:	00 00 00 
    wakeup(&log);
80102a9c:	c7 04 24 a0 e4 1b 80 	movl   $0x801be4a0,(%esp)
80102aa3:	e8 73 0f 00 00       	call   80103a1b <wakeup>
    release(&log.lock);
80102aa8:	c7 04 24 a0 e4 1b 80 	movl   $0x801be4a0,(%esp)
80102aaf:	e8 c9 13 00 00       	call   80103e7d <release>
80102ab4:	83 c4 10             	add    $0x10,%esp
}
80102ab7:	eb a3                	jmp    80102a5c <end_op+0x52>

80102ab9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102ab9:	55                   	push   %ebp
80102aba:	89 e5                	mov    %esp,%ebp
80102abc:	53                   	push   %ebx
80102abd:	83 ec 04             	sub    $0x4,%esp
80102ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102ac3:	8b 15 e8 e4 1b 80    	mov    0x801be4e8,%edx
80102ac9:	83 fa 1d             	cmp    $0x1d,%edx
80102acc:	7f 45                	jg     80102b13 <log_write+0x5a>
80102ace:	a1 d8 e4 1b 80       	mov    0x801be4d8,%eax
80102ad3:	83 e8 01             	sub    $0x1,%eax
80102ad6:	39 c2                	cmp    %eax,%edx
80102ad8:	7d 39                	jge    80102b13 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102ada:	83 3d dc e4 1b 80 00 	cmpl   $0x0,0x801be4dc
80102ae1:	7e 3d                	jle    80102b20 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102ae3:	83 ec 0c             	sub    $0xc,%esp
80102ae6:	68 a0 e4 1b 80       	push   $0x801be4a0
80102aeb:	e8 28 13 00 00       	call   80103e18 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102af0:	83 c4 10             	add    $0x10,%esp
80102af3:	b8 00 00 00 00       	mov    $0x0,%eax
80102af8:	8b 15 e8 e4 1b 80    	mov    0x801be4e8,%edx
80102afe:	39 c2                	cmp    %eax,%edx
80102b00:	7e 2b                	jle    80102b2d <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102b02:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102b05:	39 0c 85 ec e4 1b 80 	cmp    %ecx,-0x7fe41b14(,%eax,4)
80102b0c:	74 1f                	je     80102b2d <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102b0e:	83 c0 01             	add    $0x1,%eax
80102b11:	eb e5                	jmp    80102af8 <log_write+0x3f>
    panic("too big a transaction");
80102b13:	83 ec 0c             	sub    $0xc,%esp
80102b16:	68 53 6c 10 80       	push   $0x80106c53
80102b1b:	e8 28 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102b20:	83 ec 0c             	sub    $0xc,%esp
80102b23:	68 69 6c 10 80       	push   $0x80106c69
80102b28:	e8 1b d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102b2d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102b30:	89 0c 85 ec e4 1b 80 	mov    %ecx,-0x7fe41b14(,%eax,4)
  if (i == log.lh.n)
80102b37:	39 c2                	cmp    %eax,%edx
80102b39:	74 18                	je     80102b53 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102b3b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102b3e:	83 ec 0c             	sub    $0xc,%esp
80102b41:	68 a0 e4 1b 80       	push   $0x801be4a0
80102b46:	e8 32 13 00 00       	call   80103e7d <release>
}
80102b4b:	83 c4 10             	add    $0x10,%esp
80102b4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b51:	c9                   	leave  
80102b52:	c3                   	ret    
    log.lh.n++;
80102b53:	83 c2 01             	add    $0x1,%edx
80102b56:	89 15 e8 e4 1b 80    	mov    %edx,0x801be4e8
80102b5c:	eb dd                	jmp    80102b3b <log_write+0x82>

80102b5e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102b5e:	55                   	push   %ebp
80102b5f:	89 e5                	mov    %esp,%ebp
80102b61:	53                   	push   %ebx
80102b62:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b65:	68 8a 00 00 00       	push   $0x8a
80102b6a:	68 8c a4 10 80       	push   $0x8010a48c
80102b6f:	68 00 70 00 80       	push   $0x80007000
80102b74:	e8 c6 13 00 00       	call   80103f3f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b79:	83 c4 10             	add    $0x10,%esp
80102b7c:	bb a0 e5 1b 80       	mov    $0x801be5a0,%ebx
80102b81:	eb 06                	jmp    80102b89 <startothers+0x2b>
80102b83:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b89:	69 05 20 eb 1b 80 b0 	imul   $0xb0,0x801beb20,%eax
80102b90:	00 00 00 
80102b93:	05 a0 e5 1b 80       	add    $0x801be5a0,%eax
80102b98:	39 d8                	cmp    %ebx,%eax
80102b9a:	76 4c                	jbe    80102be8 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102b9c:	e8 f0 07 00 00       	call   80103391 <mycpu>
80102ba1:	39 d8                	cmp    %ebx,%eax
80102ba3:	74 de                	je     80102b83 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102ba5:	e8 11 f5 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102baa:	05 00 10 00 00       	add    $0x1000,%eax
80102baf:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102bb4:	c7 05 f8 6f 00 80 2c 	movl   $0x80102c2c,0x80006ff8
80102bbb:	2c 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102bbe:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102bc5:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102bc8:	83 ec 08             	sub    $0x8,%esp
80102bcb:	68 00 70 00 00       	push   $0x7000
80102bd0:	0f b6 03             	movzbl (%ebx),%eax
80102bd3:	50                   	push   %eax
80102bd4:	e8 c6 f9 ff ff       	call   8010259f <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102bd9:	83 c4 10             	add    $0x10,%esp
80102bdc:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102be2:	85 c0                	test   %eax,%eax
80102be4:	74 f6                	je     80102bdc <startothers+0x7e>
80102be6:	eb 9b                	jmp    80102b83 <startothers+0x25>
      ;
  }
}
80102be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102beb:	c9                   	leave  
80102bec:	c3                   	ret    

80102bed <mpmain>:
{
80102bed:	55                   	push   %ebp
80102bee:	89 e5                	mov    %esp,%ebp
80102bf0:	53                   	push   %ebx
80102bf1:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102bf4:	e8 f4 07 00 00       	call   801033ed <cpuid>
80102bf9:	89 c3                	mov    %eax,%ebx
80102bfb:	e8 ed 07 00 00       	call   801033ed <cpuid>
80102c00:	83 ec 04             	sub    $0x4,%esp
80102c03:	53                   	push   %ebx
80102c04:	50                   	push   %eax
80102c05:	68 84 6c 10 80       	push   $0x80106c84
80102c0a:	e8 fc d9 ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102c0f:	e8 89 24 00 00       	call   8010509d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102c14:	e8 78 07 00 00       	call   80103391 <mycpu>
80102c19:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102c1b:	b8 01 00 00 00       	mov    $0x1,%eax
80102c20:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102c27:	e8 65 0a 00 00       	call   80103691 <scheduler>

80102c2c <mpenter>:
{
80102c2c:	55                   	push   %ebp
80102c2d:	89 e5                	mov    %esp,%ebp
80102c2f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102c32:	e8 6f 34 00 00       	call   801060a6 <switchkvm>
  seginit();
80102c37:	e8 1e 33 00 00       	call   80105f5a <seginit>
  lapicinit();
80102c3c:	e8 15 f8 ff ff       	call   80102456 <lapicinit>
  mpmain();
80102c41:	e8 a7 ff ff ff       	call   80102bed <mpmain>

80102c46 <main>:
{
80102c46:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102c4a:	83 e4 f0             	and    $0xfffffff0,%esp
80102c4d:	ff 71 fc             	pushl  -0x4(%ecx)
80102c50:	55                   	push   %ebp
80102c51:	89 e5                	mov    %esp,%ebp
80102c53:	51                   	push   %ecx
80102c54:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102c57:	68 00 00 40 80       	push   $0x80400000
80102c5c:	68 c8 12 1c 80       	push   $0x801c12c8
80102c61:	e8 03 f4 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102c66:	e8 c8 38 00 00       	call   80106533 <kvmalloc>
  mpinit();        // detect other processors
80102c6b:	e8 c9 01 00 00       	call   80102e39 <mpinit>
  lapicinit();     // interrupt controller
80102c70:	e8 e1 f7 ff ff       	call   80102456 <lapicinit>
  seginit();       // segment descriptors
80102c75:	e8 e0 32 00 00       	call   80105f5a <seginit>
  picinit();       // disable pic
80102c7a:	e8 82 02 00 00       	call   80102f01 <picinit>
  ioapicinit();    // another interrupt controller
80102c7f:	e8 76 f2 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102c84:	e8 05 dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c89:	e8 bd 26 00 00       	call   8010534b <uartinit>
  pinit();         // process table
80102c8e:	e8 e4 06 00 00       	call   80103377 <pinit>
  tvinit();        // trap vectors
80102c93:	e8 54 23 00 00       	call   80104fec <tvinit>
  binit();         // buffer cache
80102c98:	e8 57 d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c9d:	e8 71 df ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102ca2:	e8 59 f0 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102ca7:	e8 b2 fe ff ff       	call   80102b5e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102cac:	83 c4 08             	add    $0x8,%esp
80102caf:	68 00 00 00 8e       	push   $0x8e000000
80102cb4:	68 00 00 40 80       	push   $0x80400000
80102cb9:	e8 dd f3 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102cbe:	e8 69 07 00 00       	call   8010342c <userinit>
  mpmain();        // finish this processor's setup
80102cc3:	e8 25 ff ff ff       	call   80102bed <mpmain>

80102cc8 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102cc8:	55                   	push   %ebp
80102cc9:	89 e5                	mov    %esp,%ebp
80102ccb:	56                   	push   %esi
80102ccc:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
80102cd7:	eb 09                	jmp    80102ce2 <sum+0x1a>
    sum += addr[i];
80102cd9:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102cdd:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102cdf:	83 c1 01             	add    $0x1,%ecx
80102ce2:	39 d1                	cmp    %edx,%ecx
80102ce4:	7c f3                	jl     80102cd9 <sum+0x11>
  return sum;
}
80102ce6:	89 d8                	mov    %ebx,%eax
80102ce8:	5b                   	pop    %ebx
80102ce9:	5e                   	pop    %esi
80102cea:	5d                   	pop    %ebp
80102ceb:	c3                   	ret    

80102cec <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102cec:	55                   	push   %ebp
80102ced:	89 e5                	mov    %esp,%ebp
80102cef:	56                   	push   %esi
80102cf0:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102cf1:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102cf7:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102cf9:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102cfb:	eb 03                	jmp    80102d00 <mpsearch1+0x14>
80102cfd:	83 c3 10             	add    $0x10,%ebx
80102d00:	39 f3                	cmp    %esi,%ebx
80102d02:	73 29                	jae    80102d2d <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102d04:	83 ec 04             	sub    $0x4,%esp
80102d07:	6a 04                	push   $0x4
80102d09:	68 98 6c 10 80       	push   $0x80106c98
80102d0e:	53                   	push   %ebx
80102d0f:	e8 f6 11 00 00       	call   80103f0a <memcmp>
80102d14:	83 c4 10             	add    $0x10,%esp
80102d17:	85 c0                	test   %eax,%eax
80102d19:	75 e2                	jne    80102cfd <mpsearch1+0x11>
80102d1b:	ba 10 00 00 00       	mov    $0x10,%edx
80102d20:	89 d8                	mov    %ebx,%eax
80102d22:	e8 a1 ff ff ff       	call   80102cc8 <sum>
80102d27:	84 c0                	test   %al,%al
80102d29:	75 d2                	jne    80102cfd <mpsearch1+0x11>
80102d2b:	eb 05                	jmp    80102d32 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102d32:	89 d8                	mov    %ebx,%eax
80102d34:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102d37:	5b                   	pop    %ebx
80102d38:	5e                   	pop    %esi
80102d39:	5d                   	pop    %ebp
80102d3a:	c3                   	ret    

80102d3b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102d3b:	55                   	push   %ebp
80102d3c:	89 e5                	mov    %esp,%ebp
80102d3e:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102d41:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102d48:	c1 e0 08             	shl    $0x8,%eax
80102d4b:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102d52:	09 d0                	or     %edx,%eax
80102d54:	c1 e0 04             	shl    $0x4,%eax
80102d57:	85 c0                	test   %eax,%eax
80102d59:	74 1f                	je     80102d7a <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102d5b:	ba 00 04 00 00       	mov    $0x400,%edx
80102d60:	e8 87 ff ff ff       	call   80102cec <mpsearch1>
80102d65:	85 c0                	test   %eax,%eax
80102d67:	75 0f                	jne    80102d78 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d69:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d6e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d73:	e8 74 ff ff ff       	call   80102cec <mpsearch1>
}
80102d78:	c9                   	leave  
80102d79:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d7a:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d81:	c1 e0 08             	shl    $0x8,%eax
80102d84:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d8b:	09 d0                	or     %edx,%eax
80102d8d:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d90:	2d 00 04 00 00       	sub    $0x400,%eax
80102d95:	ba 00 04 00 00       	mov    $0x400,%edx
80102d9a:	e8 4d ff ff ff       	call   80102cec <mpsearch1>
80102d9f:	85 c0                	test   %eax,%eax
80102da1:	75 d5                	jne    80102d78 <mpsearch+0x3d>
80102da3:	eb c4                	jmp    80102d69 <mpsearch+0x2e>

80102da5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102da5:	55                   	push   %ebp
80102da6:	89 e5                	mov    %esp,%ebp
80102da8:	57                   	push   %edi
80102da9:	56                   	push   %esi
80102daa:	53                   	push   %ebx
80102dab:	83 ec 1c             	sub    $0x1c,%esp
80102dae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102db1:	e8 85 ff ff ff       	call   80102d3b <mpsearch>
80102db6:	85 c0                	test   %eax,%eax
80102db8:	74 5c                	je     80102e16 <mpconfig+0x71>
80102dba:	89 c7                	mov    %eax,%edi
80102dbc:	8b 58 04             	mov    0x4(%eax),%ebx
80102dbf:	85 db                	test   %ebx,%ebx
80102dc1:	74 5a                	je     80102e1d <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102dc3:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102dc9:	83 ec 04             	sub    $0x4,%esp
80102dcc:	6a 04                	push   $0x4
80102dce:	68 9d 6c 10 80       	push   $0x80106c9d
80102dd3:	56                   	push   %esi
80102dd4:	e8 31 11 00 00       	call   80103f0a <memcmp>
80102dd9:	83 c4 10             	add    $0x10,%esp
80102ddc:	85 c0                	test   %eax,%eax
80102dde:	75 44                	jne    80102e24 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102de0:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102de7:	3c 01                	cmp    $0x1,%al
80102de9:	0f 95 c2             	setne  %dl
80102dec:	3c 04                	cmp    $0x4,%al
80102dee:	0f 95 c0             	setne  %al
80102df1:	84 c2                	test   %al,%dl
80102df3:	75 36                	jne    80102e2b <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102df5:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102dfc:	89 f0                	mov    %esi,%eax
80102dfe:	e8 c5 fe ff ff       	call   80102cc8 <sum>
80102e03:	84 c0                	test   %al,%al
80102e05:	75 2b                	jne    80102e32 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e0a:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102e0c:	89 f0                	mov    %esi,%eax
80102e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e11:	5b                   	pop    %ebx
80102e12:	5e                   	pop    %esi
80102e13:	5f                   	pop    %edi
80102e14:	5d                   	pop    %ebp
80102e15:	c3                   	ret    
    return 0;
80102e16:	be 00 00 00 00       	mov    $0x0,%esi
80102e1b:	eb ef                	jmp    80102e0c <mpconfig+0x67>
80102e1d:	be 00 00 00 00       	mov    $0x0,%esi
80102e22:	eb e8                	jmp    80102e0c <mpconfig+0x67>
    return 0;
80102e24:	be 00 00 00 00       	mov    $0x0,%esi
80102e29:	eb e1                	jmp    80102e0c <mpconfig+0x67>
    return 0;
80102e2b:	be 00 00 00 00       	mov    $0x0,%esi
80102e30:	eb da                	jmp    80102e0c <mpconfig+0x67>
    return 0;
80102e32:	be 00 00 00 00       	mov    $0x0,%esi
80102e37:	eb d3                	jmp    80102e0c <mpconfig+0x67>

80102e39 <mpinit>:

void
mpinit(void)
{
80102e39:	55                   	push   %ebp
80102e3a:	89 e5                	mov    %esp,%ebp
80102e3c:	57                   	push   %edi
80102e3d:	56                   	push   %esi
80102e3e:	53                   	push   %ebx
80102e3f:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102e42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102e45:	e8 5b ff ff ff       	call   80102da5 <mpconfig>
80102e4a:	85 c0                	test   %eax,%eax
80102e4c:	74 19                	je     80102e67 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102e4e:	8b 50 24             	mov    0x24(%eax),%edx
80102e51:	89 15 80 e4 1b 80    	mov    %edx,0x801be480
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e57:	8d 50 2c             	lea    0x2c(%eax),%edx
80102e5a:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102e5e:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102e60:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e65:	eb 34                	jmp    80102e9b <mpinit+0x62>
    panic("Expect to run on an SMP");
80102e67:	83 ec 0c             	sub    $0xc,%esp
80102e6a:	68 a2 6c 10 80       	push   $0x80106ca2
80102e6f:	e8 d4 d4 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e74:	8b 35 20 eb 1b 80    	mov    0x801beb20,%esi
80102e7a:	83 fe 07             	cmp    $0x7,%esi
80102e7d:	7f 19                	jg     80102e98 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e7f:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e83:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e89:	88 87 a0 e5 1b 80    	mov    %al,-0x7fe41a60(%edi)
        ncpu++;
80102e8f:	83 c6 01             	add    $0x1,%esi
80102e92:	89 35 20 eb 1b 80    	mov    %esi,0x801beb20
      }
      p += sizeof(struct mpproc);
80102e98:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e9b:	39 ca                	cmp    %ecx,%edx
80102e9d:	73 2b                	jae    80102eca <mpinit+0x91>
    switch(*p){
80102e9f:	0f b6 02             	movzbl (%edx),%eax
80102ea2:	3c 04                	cmp    $0x4,%al
80102ea4:	77 1d                	ja     80102ec3 <mpinit+0x8a>
80102ea6:	0f b6 c0             	movzbl %al,%eax
80102ea9:	ff 24 85 dc 6c 10 80 	jmp    *-0x7fef9324(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102eb0:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102eb4:	a2 80 e5 1b 80       	mov    %al,0x801be580
      p += sizeof(struct mpioapic);
80102eb9:	83 c2 08             	add    $0x8,%edx
      continue;
80102ebc:	eb dd                	jmp    80102e9b <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102ebe:	83 c2 08             	add    $0x8,%edx
      continue;
80102ec1:	eb d8                	jmp    80102e9b <mpinit+0x62>
    default:
      ismp = 0;
80102ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
80102ec8:	eb d1                	jmp    80102e9b <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102eca:	85 db                	test   %ebx,%ebx
80102ecc:	74 26                	je     80102ef4 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102ece:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ed1:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102ed5:	74 15                	je     80102eec <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ed7:	b8 70 00 00 00       	mov    $0x70,%eax
80102edc:	ba 22 00 00 00       	mov    $0x22,%edx
80102ee1:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ee2:	ba 23 00 00 00       	mov    $0x23,%edx
80102ee7:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102ee8:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102eeb:	ee                   	out    %al,(%dx)
  }
}
80102eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102eef:	5b                   	pop    %ebx
80102ef0:	5e                   	pop    %esi
80102ef1:	5f                   	pop    %edi
80102ef2:	5d                   	pop    %ebp
80102ef3:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102ef4:	83 ec 0c             	sub    $0xc,%esp
80102ef7:	68 bc 6c 10 80       	push   $0x80106cbc
80102efc:	e8 47 d4 ff ff       	call   80100348 <panic>

80102f01 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102f01:	55                   	push   %ebp
80102f02:	89 e5                	mov    %esp,%ebp
80102f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f09:	ba 21 00 00 00       	mov    $0x21,%edx
80102f0e:	ee                   	out    %al,(%dx)
80102f0f:	ba a1 00 00 00       	mov    $0xa1,%edx
80102f14:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102f15:	5d                   	pop    %ebp
80102f16:	c3                   	ret    

80102f17 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102f17:	55                   	push   %ebp
80102f18:	89 e5                	mov    %esp,%ebp
80102f1a:	57                   	push   %edi
80102f1b:	56                   	push   %esi
80102f1c:	53                   	push   %ebx
80102f1d:	83 ec 0c             	sub    $0xc,%esp
80102f20:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f23:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102f26:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102f2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102f32:	e8 f6 dc ff ff       	call   80100c2d <filealloc>
80102f37:	89 03                	mov    %eax,(%ebx)
80102f39:	85 c0                	test   %eax,%eax
80102f3b:	74 16                	je     80102f53 <pipealloc+0x3c>
80102f3d:	e8 eb dc ff ff       	call   80100c2d <filealloc>
80102f42:	89 06                	mov    %eax,(%esi)
80102f44:	85 c0                	test   %eax,%eax
80102f46:	74 0b                	je     80102f53 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102f48:	e8 6e f1 ff ff       	call   801020bb <kalloc>
80102f4d:	89 c7                	mov    %eax,%edi
80102f4f:	85 c0                	test   %eax,%eax
80102f51:	75 35                	jne    80102f88 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f53:	8b 03                	mov    (%ebx),%eax
80102f55:	85 c0                	test   %eax,%eax
80102f57:	74 0c                	je     80102f65 <pipealloc+0x4e>
    fileclose(*f0);
80102f59:	83 ec 0c             	sub    $0xc,%esp
80102f5c:	50                   	push   %eax
80102f5d:	e8 71 dd ff ff       	call   80100cd3 <fileclose>
80102f62:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f65:	8b 06                	mov    (%esi),%eax
80102f67:	85 c0                	test   %eax,%eax
80102f69:	0f 84 8b 00 00 00    	je     80102ffa <pipealloc+0xe3>
    fileclose(*f1);
80102f6f:	83 ec 0c             	sub    $0xc,%esp
80102f72:	50                   	push   %eax
80102f73:	e8 5b dd ff ff       	call   80100cd3 <fileclose>
80102f78:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f83:	5b                   	pop    %ebx
80102f84:	5e                   	pop    %esi
80102f85:	5f                   	pop    %edi
80102f86:	5d                   	pop    %ebp
80102f87:	c3                   	ret    
  p->readopen = 1;
80102f88:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f8f:	00 00 00 
  p->writeopen = 1;
80102f92:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f99:	00 00 00 
  p->nwrite = 0;
80102f9c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102fa3:	00 00 00 
  p->nread = 0;
80102fa6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102fad:	00 00 00 
  initlock(&p->lock, "pipe");
80102fb0:	83 ec 08             	sub    $0x8,%esp
80102fb3:	68 f0 6c 10 80       	push   $0x80106cf0
80102fb8:	50                   	push   %eax
80102fb9:	e8 1e 0d 00 00       	call   80103cdc <initlock>
  (*f0)->type = FD_PIPE;
80102fbe:	8b 03                	mov    (%ebx),%eax
80102fc0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102fc6:	8b 03                	mov    (%ebx),%eax
80102fc8:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102fcc:	8b 03                	mov    (%ebx),%eax
80102fce:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102fd2:	8b 03                	mov    (%ebx),%eax
80102fd4:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102fd7:	8b 06                	mov    (%esi),%eax
80102fd9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102fdf:	8b 06                	mov    (%esi),%eax
80102fe1:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102fe5:	8b 06                	mov    (%esi),%eax
80102fe7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102feb:	8b 06                	mov    (%esi),%eax
80102fed:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102ff0:	83 c4 10             	add    $0x10,%esp
80102ff3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ff8:	eb 86                	jmp    80102f80 <pipealloc+0x69>
  return -1;
80102ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fff:	e9 7c ff ff ff       	jmp    80102f80 <pipealloc+0x69>

80103004 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103004:	55                   	push   %ebp
80103005:	89 e5                	mov    %esp,%ebp
80103007:	53                   	push   %ebx
80103008:	83 ec 10             	sub    $0x10,%esp
8010300b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
8010300e:	53                   	push   %ebx
8010300f:	e8 04 0e 00 00       	call   80103e18 <acquire>
  if(writable){
80103014:	83 c4 10             	add    $0x10,%esp
80103017:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010301b:	74 3f                	je     8010305c <pipeclose+0x58>
    p->writeopen = 0;
8010301d:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80103024:	00 00 00 
    wakeup(&p->nread);
80103027:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010302d:	83 ec 0c             	sub    $0xc,%esp
80103030:	50                   	push   %eax
80103031:	e8 e5 09 00 00       	call   80103a1b <wakeup>
80103036:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103039:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103040:	75 09                	jne    8010304b <pipeclose+0x47>
80103042:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80103049:	74 2f                	je     8010307a <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010304b:	83 ec 0c             	sub    $0xc,%esp
8010304e:	53                   	push   %ebx
8010304f:	e8 29 0e 00 00       	call   80103e7d <release>
80103054:	83 c4 10             	add    $0x10,%esp
}
80103057:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010305a:	c9                   	leave  
8010305b:	c3                   	ret    
    p->readopen = 0;
8010305c:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103063:	00 00 00 
    wakeup(&p->nwrite);
80103066:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010306c:	83 ec 0c             	sub    $0xc,%esp
8010306f:	50                   	push   %eax
80103070:	e8 a6 09 00 00       	call   80103a1b <wakeup>
80103075:	83 c4 10             	add    $0x10,%esp
80103078:	eb bf                	jmp    80103039 <pipeclose+0x35>
    release(&p->lock);
8010307a:	83 ec 0c             	sub    $0xc,%esp
8010307d:	53                   	push   %ebx
8010307e:	e8 fa 0d 00 00       	call   80103e7d <release>
    kfree((char*)p);
80103083:	89 1c 24             	mov    %ebx,(%esp)
80103086:	e8 19 ef ff ff       	call   80101fa4 <kfree>
8010308b:	83 c4 10             	add    $0x10,%esp
8010308e:	eb c7                	jmp    80103057 <pipeclose+0x53>

80103090 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103090:	55                   	push   %ebp
80103091:	89 e5                	mov    %esp,%ebp
80103093:	57                   	push   %edi
80103094:	56                   	push   %esi
80103095:	53                   	push   %ebx
80103096:	83 ec 18             	sub    $0x18,%esp
80103099:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010309c:	89 de                	mov    %ebx,%esi
8010309e:	53                   	push   %ebx
8010309f:	e8 74 0d 00 00       	call   80103e18 <acquire>
  for(i = 0; i < n; i++){
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	bf 00 00 00 00       	mov    $0x0,%edi
801030ac:	3b 7d 10             	cmp    0x10(%ebp),%edi
801030af:	0f 8d 88 00 00 00    	jge    8010313d <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801030b5:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801030bb:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030c1:	05 00 02 00 00       	add    $0x200,%eax
801030c6:	39 c2                	cmp    %eax,%edx
801030c8:	75 51                	jne    8010311b <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
801030ca:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
801030d1:	74 2f                	je     80103102 <pipewrite+0x72>
801030d3:	e8 30 03 00 00       	call   80103408 <myproc>
801030d8:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801030dc:	75 24                	jne    80103102 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801030de:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030e4:	83 ec 0c             	sub    $0xc,%esp
801030e7:	50                   	push   %eax
801030e8:	e8 2e 09 00 00       	call   80103a1b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801030ed:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030f3:	83 c4 08             	add    $0x8,%esp
801030f6:	56                   	push   %esi
801030f7:	50                   	push   %eax
801030f8:	e8 b9 07 00 00       	call   801038b6 <sleep>
801030fd:	83 c4 10             	add    $0x10,%esp
80103100:	eb b3                	jmp    801030b5 <pipewrite+0x25>
        release(&p->lock);
80103102:	83 ec 0c             	sub    $0xc,%esp
80103105:	53                   	push   %ebx
80103106:	e8 72 0d 00 00       	call   80103e7d <release>
        return -1;
8010310b:	83 c4 10             	add    $0x10,%esp
8010310e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103113:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103116:	5b                   	pop    %ebx
80103117:	5e                   	pop    %esi
80103118:	5f                   	pop    %edi
80103119:	5d                   	pop    %ebp
8010311a:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010311b:	8d 42 01             	lea    0x1(%edx),%eax
8010311e:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103124:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010312a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010312d:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80103131:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103135:	83 c7 01             	add    $0x1,%edi
80103138:	e9 6f ff ff ff       	jmp    801030ac <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010313d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103143:	83 ec 0c             	sub    $0xc,%esp
80103146:	50                   	push   %eax
80103147:	e8 cf 08 00 00       	call   80103a1b <wakeup>
  release(&p->lock);
8010314c:	89 1c 24             	mov    %ebx,(%esp)
8010314f:	e8 29 0d 00 00       	call   80103e7d <release>
  return n;
80103154:	83 c4 10             	add    $0x10,%esp
80103157:	8b 45 10             	mov    0x10(%ebp),%eax
8010315a:	eb b7                	jmp    80103113 <pipewrite+0x83>

8010315c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010315c:	55                   	push   %ebp
8010315d:	89 e5                	mov    %esp,%ebp
8010315f:	57                   	push   %edi
80103160:	56                   	push   %esi
80103161:	53                   	push   %ebx
80103162:	83 ec 18             	sub    $0x18,%esp
80103165:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103168:	89 df                	mov    %ebx,%edi
8010316a:	53                   	push   %ebx
8010316b:	e8 a8 0c 00 00       	call   80103e18 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103170:	83 c4 10             	add    $0x10,%esp
80103173:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103179:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
8010317f:	75 3d                	jne    801031be <piperead+0x62>
80103181:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103187:	85 f6                	test   %esi,%esi
80103189:	74 38                	je     801031c3 <piperead+0x67>
    if(myproc()->killed){
8010318b:	e8 78 02 00 00       	call   80103408 <myproc>
80103190:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103194:	75 15                	jne    801031ab <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103196:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010319c:	83 ec 08             	sub    $0x8,%esp
8010319f:	57                   	push   %edi
801031a0:	50                   	push   %eax
801031a1:	e8 10 07 00 00       	call   801038b6 <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb c8                	jmp    80103173 <piperead+0x17>
      release(&p->lock);
801031ab:	83 ec 0c             	sub    $0xc,%esp
801031ae:	53                   	push   %ebx
801031af:	e8 c9 0c 00 00       	call   80103e7d <release>
      return -1;
801031b4:	83 c4 10             	add    $0x10,%esp
801031b7:	be ff ff ff ff       	mov    $0xffffffff,%esi
801031bc:	eb 50                	jmp    8010320e <piperead+0xb2>
801031be:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031c3:	3b 75 10             	cmp    0x10(%ebp),%esi
801031c6:	7d 2c                	jge    801031f4 <piperead+0x98>
    if(p->nread == p->nwrite)
801031c8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801031ce:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801031d4:	74 1e                	je     801031f4 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801031d6:	8d 50 01             	lea    0x1(%eax),%edx
801031d9:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801031df:	25 ff 01 00 00       	and    $0x1ff,%eax
801031e4:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801031e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801031ec:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031ef:	83 c6 01             	add    $0x1,%esi
801031f2:	eb cf                	jmp    801031c3 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031f4:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031fa:	83 ec 0c             	sub    $0xc,%esp
801031fd:	50                   	push   %eax
801031fe:	e8 18 08 00 00       	call   80103a1b <wakeup>
  release(&p->lock);
80103203:	89 1c 24             	mov    %ebx,(%esp)
80103206:	e8 72 0c 00 00       	call   80103e7d <release>
  return i;
8010320b:	83 c4 10             	add    $0x10,%esp
}
8010320e:	89 f0                	mov    %esi,%eax
80103210:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103213:	5b                   	pop    %ebx
80103214:	5e                   	pop    %esi
80103215:	5f                   	pop    %edi
80103216:	5d                   	pop    %ebp
80103217:	c3                   	ret    

80103218 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103218:	55                   	push   %ebp
80103219:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010321b:	ba 74 eb 1b 80       	mov    $0x801beb74,%edx
80103220:	eb 03                	jmp    80103225 <wakeup1+0xd>
80103222:	83 c2 7c             	add    $0x7c,%edx
80103225:	81 fa 74 0a 1c 80    	cmp    $0x801c0a74,%edx
8010322b:	73 14                	jae    80103241 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010322d:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103231:	75 ef                	jne    80103222 <wakeup1+0xa>
80103233:	39 42 20             	cmp    %eax,0x20(%edx)
80103236:	75 ea                	jne    80103222 <wakeup1+0xa>
      p->state = RUNNABLE;
80103238:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010323f:	eb e1                	jmp    80103222 <wakeup1+0xa>
}
80103241:	5d                   	pop    %ebp
80103242:	c3                   	ret    

80103243 <allocproc>:
{
80103243:	55                   	push   %ebp
80103244:	89 e5                	mov    %esp,%ebp
80103246:	56                   	push   %esi
80103247:	53                   	push   %ebx
80103248:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010324a:	83 ec 0c             	sub    $0xc,%esp
8010324d:	68 40 eb 1b 80       	push   $0x801beb40
80103252:	e8 c1 0b 00 00       	call   80103e18 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103257:	83 c4 10             	add    $0x10,%esp
8010325a:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
8010325f:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103265:	73 0b                	jae    80103272 <allocproc+0x2f>
    if(p->state == UNUSED)
80103267:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010326b:	74 1c                	je     80103289 <allocproc+0x46>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010326d:	83 c3 7c             	add    $0x7c,%ebx
80103270:	eb ed                	jmp    8010325f <allocproc+0x1c>
  release(&ptable.lock);
80103272:	83 ec 0c             	sub    $0xc,%esp
80103275:	68 40 eb 1b 80       	push   $0x801beb40
8010327a:	e8 fe 0b 00 00       	call   80103e7d <release>
  return 0;
8010327f:	83 c4 10             	add    $0x10,%esp
80103282:	bb 00 00 00 00       	mov    $0x0,%ebx
80103287:	eb 7a                	jmp    80103303 <allocproc+0xc0>
  p->state = EMBRYO;
80103289:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103290:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103295:	8d 50 01             	lea    0x1(%eax),%edx
80103298:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
8010329e:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801032a1:	83 ec 0c             	sub    $0xc,%esp
801032a4:	68 40 eb 1b 80       	push   $0x801beb40
801032a9:	e8 cf 0b 00 00       	call   80103e7d <release>
  if(c == -1) {
801032ae:	83 c4 10             	add    $0x10,%esp
801032b1:	83 fe ff             	cmp    $0xffffffff,%esi
801032b4:	74 56                	je     8010330c <allocproc+0xc9>
   if((p->kstack = kalloc1a(p->pid)) == 0) {
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	ff 73 10             	pushl  0x10(%ebx)
801032bc:	e8 7c ee ff ff       	call   8010213d <kalloc1a>
801032c1:	89 43 08             	mov    %eax,0x8(%ebx)
801032c4:	83 c4 10             	add    $0x10,%esp
801032c7:	85 c0                	test   %eax,%eax
801032c9:	74 5b                	je     80103326 <allocproc+0xe3>
  sp = p->kstack + KSTACKSIZE;
801032cb:	8b 43 08             	mov    0x8(%ebx),%eax
  sp -= sizeof *p->tf;
801032ce:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801032d4:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801032d7:	c7 80 b0 0f 00 00 e1 	movl   $0x80104fe1,0xfb0(%eax)
801032de:	4f 10 80 
  sp -= sizeof *p->context;
801032e1:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801032e6:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801032e9:	83 ec 04             	sub    $0x4,%esp
801032ec:	6a 14                	push   $0x14
801032ee:	6a 00                	push   $0x0
801032f0:	50                   	push   %eax
801032f1:	e8 ce 0b 00 00       	call   80103ec4 <memset>
  p->context->eip = (uint)forkret;
801032f6:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032f9:	c7 40 10 34 33 10 80 	movl   $0x80103334,0x10(%eax)
  return p;
80103300:	83 c4 10             	add    $0x10,%esp
}
80103303:	89 d8                	mov    %ebx,%eax
80103305:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103308:	5b                   	pop    %ebx
80103309:	5e                   	pop    %esi
8010330a:	5d                   	pop    %ebp
8010330b:	c3                   	ret    
    if((p->kstack = kalloc()) == 0){
8010330c:	e8 aa ed ff ff       	call   801020bb <kalloc>
80103311:	89 43 08             	mov    %eax,0x8(%ebx)
80103314:	85 c0                	test   %eax,%eax
80103316:	75 b3                	jne    801032cb <allocproc+0x88>
        p->state = UNUSED;
80103318:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        return 0;
8010331f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103324:	eb dd                	jmp    80103303 <allocproc+0xc0>
       p->state = UNUSED;
80103326:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
       return 0;
8010332d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103332:	eb cf                	jmp    80103303 <allocproc+0xc0>

80103334 <forkret>:
{
80103334:	55                   	push   %ebp
80103335:	89 e5                	mov    %esp,%ebp
80103337:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010333a:	68 40 eb 1b 80       	push   $0x801beb40
8010333f:	e8 39 0b 00 00       	call   80103e7d <release>
  if (first) {
80103344:	83 c4 10             	add    $0x10,%esp
80103347:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010334e:	75 02                	jne    80103352 <forkret+0x1e>
}
80103350:	c9                   	leave  
80103351:	c3                   	ret    
    first = 0;
80103352:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103359:	00 00 00 
    iinit(ROOTDEV);
8010335c:	83 ec 0c             	sub    $0xc,%esp
8010335f:	6a 01                	push   $0x1
80103361:	e8 86 df ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
80103366:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010336d:	e8 d5 f5 ff ff       	call   80102947 <initlog>
80103372:	83 c4 10             	add    $0x10,%esp
}
80103375:	eb d9                	jmp    80103350 <forkret+0x1c>

80103377 <pinit>:
{
80103377:	55                   	push   %ebp
80103378:	89 e5                	mov    %esp,%ebp
8010337a:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010337d:	68 f5 6c 10 80       	push   $0x80106cf5
80103382:	68 40 eb 1b 80       	push   $0x801beb40
80103387:	e8 50 09 00 00       	call   80103cdc <initlock>
}
8010338c:	83 c4 10             	add    $0x10,%esp
8010338f:	c9                   	leave  
80103390:	c3                   	ret    

80103391 <mycpu>:
{
80103391:	55                   	push   %ebp
80103392:	89 e5                	mov    %esp,%ebp
80103394:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103397:	9c                   	pushf  
80103398:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103399:	f6 c4 02             	test   $0x2,%ah
8010339c:	75 28                	jne    801033c6 <mycpu+0x35>
  apicid = lapicid();
8010339e:	e8 bd f1 ff ff       	call   80102560 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801033a3:	ba 00 00 00 00       	mov    $0x0,%edx
801033a8:	39 15 20 eb 1b 80    	cmp    %edx,0x801beb20
801033ae:	7e 23                	jle    801033d3 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801033b0:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801033b6:	0f b6 89 a0 e5 1b 80 	movzbl -0x7fe41a60(%ecx),%ecx
801033bd:	39 c1                	cmp    %eax,%ecx
801033bf:	74 1f                	je     801033e0 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801033c1:	83 c2 01             	add    $0x1,%edx
801033c4:	eb e2                	jmp    801033a8 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801033c6:	83 ec 0c             	sub    $0xc,%esp
801033c9:	68 d8 6d 10 80       	push   $0x80106dd8
801033ce:	e8 75 cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
801033d3:	83 ec 0c             	sub    $0xc,%esp
801033d6:	68 fc 6c 10 80       	push   $0x80106cfc
801033db:	e8 68 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
801033e0:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801033e6:	05 a0 e5 1b 80       	add    $0x801be5a0,%eax
}
801033eb:	c9                   	leave  
801033ec:	c3                   	ret    

801033ed <cpuid>:
cpuid() {
801033ed:	55                   	push   %ebp
801033ee:	89 e5                	mov    %esp,%ebp
801033f0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801033f3:	e8 99 ff ff ff       	call   80103391 <mycpu>
801033f8:	2d a0 e5 1b 80       	sub    $0x801be5a0,%eax
801033fd:	c1 f8 04             	sar    $0x4,%eax
80103400:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103406:	c9                   	leave  
80103407:	c3                   	ret    

80103408 <myproc>:
myproc(void) {
80103408:	55                   	push   %ebp
80103409:	89 e5                	mov    %esp,%ebp
8010340b:	53                   	push   %ebx
8010340c:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010340f:	e8 27 09 00 00       	call   80103d3b <pushcli>
  c = mycpu();
80103414:	e8 78 ff ff ff       	call   80103391 <mycpu>
  p = c->proc;
80103419:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010341f:	e8 54 09 00 00       	call   80103d78 <popcli>
}
80103424:	89 d8                	mov    %ebx,%eax
80103426:	83 c4 04             	add    $0x4,%esp
80103429:	5b                   	pop    %ebx
8010342a:	5d                   	pop    %ebp
8010342b:	c3                   	ret    

8010342c <userinit>:
{
8010342c:	55                   	push   %ebp
8010342d:	89 e5                	mov    %esp,%ebp
8010342f:	53                   	push   %ebx
80103430:	83 ec 04             	sub    $0x4,%esp
  p = allocproc(0);
80103433:	b8 00 00 00 00       	mov    $0x0,%eax
80103438:	e8 06 fe ff ff       	call   80103243 <allocproc>
8010343d:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010343f:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
80103444:	e8 7c 30 00 00       	call   801064c5 <setupkvm>
80103449:	89 43 04             	mov    %eax,0x4(%ebx)
8010344c:	85 c0                	test   %eax,%eax
8010344e:	0f 84 b7 00 00 00    	je     8010350b <userinit+0xdf>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103454:	83 ec 04             	sub    $0x4,%esp
80103457:	68 2c 00 00 00       	push   $0x2c
8010345c:	68 60 a4 10 80       	push   $0x8010a460
80103461:	50                   	push   %eax
80103462:	e8 69 2d 00 00       	call   801061d0 <inituvm>
  p->sz = PGSIZE;
80103467:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010346d:	83 c4 0c             	add    $0xc,%esp
80103470:	6a 4c                	push   $0x4c
80103472:	6a 00                	push   $0x0
80103474:	ff 73 18             	pushl  0x18(%ebx)
80103477:	e8 48 0a 00 00       	call   80103ec4 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010347c:	8b 43 18             	mov    0x18(%ebx),%eax
8010347f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103485:	8b 43 18             	mov    0x18(%ebx),%eax
80103488:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010348e:	8b 43 18             	mov    0x18(%ebx),%eax
80103491:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103495:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103499:	8b 43 18             	mov    0x18(%ebx),%eax
8010349c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801034a0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801034a4:	8b 43 18             	mov    0x18(%ebx),%eax
801034a7:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801034ae:	8b 43 18             	mov    0x18(%ebx),%eax
801034b1:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801034b8:	8b 43 18             	mov    0x18(%ebx),%eax
801034bb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801034c2:	8d 43 6c             	lea    0x6c(%ebx),%eax
801034c5:	83 c4 0c             	add    $0xc,%esp
801034c8:	6a 10                	push   $0x10
801034ca:	68 25 6d 10 80       	push   $0x80106d25
801034cf:	50                   	push   %eax
801034d0:	e8 56 0b 00 00       	call   8010402b <safestrcpy>
  p->cwd = namei("/");
801034d5:	c7 04 24 2e 6d 10 80 	movl   $0x80106d2e,(%esp)
801034dc:	e8 00 e7 ff ff       	call   80101be1 <namei>
801034e1:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801034e4:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801034eb:	e8 28 09 00 00       	call   80103e18 <acquire>
  p->state = RUNNABLE;
801034f0:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801034f7:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801034fe:	e8 7a 09 00 00       	call   80103e7d <release>
}
80103503:	83 c4 10             	add    $0x10,%esp
80103506:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103509:	c9                   	leave  
8010350a:	c3                   	ret    
    panic("userinit: out of memory?");
8010350b:	83 ec 0c             	sub    $0xc,%esp
8010350e:	68 0c 6d 10 80       	push   $0x80106d0c
80103513:	e8 30 ce ff ff       	call   80100348 <panic>

80103518 <growproc>:
{
80103518:	55                   	push   %ebp
80103519:	89 e5                	mov    %esp,%ebp
8010351b:	56                   	push   %esi
8010351c:	53                   	push   %ebx
8010351d:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103520:	e8 e3 fe ff ff       	call   80103408 <myproc>
80103525:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103527:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103529:	85 f6                	test   %esi,%esi
8010352b:	7f 21                	jg     8010354e <growproc+0x36>
  } else if(n < 0){
8010352d:	85 f6                	test   %esi,%esi
8010352f:	79 33                	jns    80103564 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103531:	83 ec 04             	sub    $0x4,%esp
80103534:	01 c6                	add    %eax,%esi
80103536:	56                   	push   %esi
80103537:	50                   	push   %eax
80103538:	ff 73 04             	pushl  0x4(%ebx)
8010353b:	e8 99 2d 00 00       	call   801062d9 <deallocuvm>
80103540:	83 c4 10             	add    $0x10,%esp
80103543:	85 c0                	test   %eax,%eax
80103545:	75 1d                	jne    80103564 <growproc+0x4c>
      return -1;
80103547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010354c:	eb 29                	jmp    80103577 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010354e:	83 ec 04             	sub    $0x4,%esp
80103551:	01 c6                	add    %eax,%esi
80103553:	56                   	push   %esi
80103554:	50                   	push   %eax
80103555:	ff 73 04             	pushl  0x4(%ebx)
80103558:	e8 0e 2e 00 00       	call   8010636b <allocuvm>
8010355d:	83 c4 10             	add    $0x10,%esp
80103560:	85 c0                	test   %eax,%eax
80103562:	74 1a                	je     8010357e <growproc+0x66>
  curproc->sz = sz;
80103564:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103566:	83 ec 0c             	sub    $0xc,%esp
80103569:	53                   	push   %ebx
8010356a:	e8 49 2b 00 00       	call   801060b8 <switchuvm>
  return 0;
8010356f:	83 c4 10             	add    $0x10,%esp
80103572:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103577:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010357a:	5b                   	pop    %ebx
8010357b:	5e                   	pop    %esi
8010357c:	5d                   	pop    %ebp
8010357d:	c3                   	ret    
      return -1;
8010357e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103583:	eb f2                	jmp    80103577 <growproc+0x5f>

80103585 <fork>:
{
80103585:	55                   	push   %ebp
80103586:	89 e5                	mov    %esp,%ebp
80103588:	57                   	push   %edi
80103589:	56                   	push   %esi
8010358a:	53                   	push   %ebx
8010358b:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010358e:	e8 75 fe ff ff       	call   80103408 <myproc>
80103593:	89 c3                	mov    %eax,%ebx
  if((np = allocproc(0)) == 0){
80103595:	b8 00 00 00 00       	mov    $0x0,%eax
8010359a:	e8 a4 fc ff ff       	call   80103243 <allocproc>
8010359f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801035a2:	85 c0                	test   %eax,%eax
801035a4:	0f 84 e0 00 00 00    	je     8010368a <fork+0x105>
801035aa:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801035ac:	83 ec 08             	sub    $0x8,%esp
801035af:	ff 33                	pushl  (%ebx)
801035b1:	ff 73 04             	pushl  0x4(%ebx)
801035b4:	e8 bd 2f 00 00       	call   80106576 <copyuvm>
801035b9:	89 47 04             	mov    %eax,0x4(%edi)
801035bc:	83 c4 10             	add    $0x10,%esp
801035bf:	85 c0                	test   %eax,%eax
801035c1:	74 2a                	je     801035ed <fork+0x68>
  np->sz = curproc->sz;
801035c3:	8b 03                	mov    (%ebx),%eax
801035c5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801035c8:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801035ca:	89 c8                	mov    %ecx,%eax
801035cc:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801035cf:	8b 73 18             	mov    0x18(%ebx),%esi
801035d2:	8b 79 18             	mov    0x18(%ecx),%edi
801035d5:	b9 13 00 00 00       	mov    $0x13,%ecx
801035da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801035dc:	8b 40 18             	mov    0x18(%eax),%eax
801035df:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801035e6:	be 00 00 00 00       	mov    $0x0,%esi
801035eb:	eb 29                	jmp    80103616 <fork+0x91>
    kfree(np->kstack);
801035ed:	83 ec 0c             	sub    $0xc,%esp
801035f0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801035f3:	ff 73 08             	pushl  0x8(%ebx)
801035f6:	e8 a9 e9 ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
801035fb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103602:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103609:	83 c4 10             	add    $0x10,%esp
8010360c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103611:	eb 6d                	jmp    80103680 <fork+0xfb>
  for(i = 0; i < NOFILE; i++)
80103613:	83 c6 01             	add    $0x1,%esi
80103616:	83 fe 0f             	cmp    $0xf,%esi
80103619:	7f 1d                	jg     80103638 <fork+0xb3>
    if(curproc->ofile[i])
8010361b:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010361f:	85 c0                	test   %eax,%eax
80103621:	74 f0                	je     80103613 <fork+0x8e>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103623:	83 ec 0c             	sub    $0xc,%esp
80103626:	50                   	push   %eax
80103627:	e8 62 d6 ff ff       	call   80100c8e <filedup>
8010362c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010362f:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103633:	83 c4 10             	add    $0x10,%esp
80103636:	eb db                	jmp    80103613 <fork+0x8e>
  np->cwd = idup(curproc->cwd);
80103638:	83 ec 0c             	sub    $0xc,%esp
8010363b:	ff 73 68             	pushl  0x68(%ebx)
8010363e:	e8 0e df ff ff       	call   80101551 <idup>
80103643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103646:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103649:	83 c3 6c             	add    $0x6c,%ebx
8010364c:	8d 47 6c             	lea    0x6c(%edi),%eax
8010364f:	83 c4 0c             	add    $0xc,%esp
80103652:	6a 10                	push   $0x10
80103654:	53                   	push   %ebx
80103655:	50                   	push   %eax
80103656:	e8 d0 09 00 00       	call   8010402b <safestrcpy>
  pid = np->pid;
8010365b:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010365e:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103665:	e8 ae 07 00 00       	call   80103e18 <acquire>
  np->state = RUNNABLE;
8010366a:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103671:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103678:	e8 00 08 00 00       	call   80103e7d <release>
  return pid;
8010367d:	83 c4 10             	add    $0x10,%esp
}
80103680:	89 d8                	mov    %ebx,%eax
80103682:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103685:	5b                   	pop    %ebx
80103686:	5e                   	pop    %esi
80103687:	5f                   	pop    %edi
80103688:	5d                   	pop    %ebp
80103689:	c3                   	ret    
    return -1;
8010368a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010368f:	eb ef                	jmp    80103680 <fork+0xfb>

80103691 <scheduler>:
{
80103691:	55                   	push   %ebp
80103692:	89 e5                	mov    %esp,%ebp
80103694:	56                   	push   %esi
80103695:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103696:	e8 f6 fc ff ff       	call   80103391 <mycpu>
8010369b:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010369d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801036a4:	00 00 00 
801036a7:	eb 5a                	jmp    80103703 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036a9:	83 c3 7c             	add    $0x7c,%ebx
801036ac:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
801036b2:	73 3f                	jae    801036f3 <scheduler+0x62>
      if(p->state != RUNNABLE)
801036b4:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801036b8:	75 ef                	jne    801036a9 <scheduler+0x18>
      c->proc = p;
801036ba:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801036c0:	83 ec 0c             	sub    $0xc,%esp
801036c3:	53                   	push   %ebx
801036c4:	e8 ef 29 00 00       	call   801060b8 <switchuvm>
      p->state = RUNNING;
801036c9:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801036d0:	83 c4 08             	add    $0x8,%esp
801036d3:	ff 73 1c             	pushl  0x1c(%ebx)
801036d6:	8d 46 04             	lea    0x4(%esi),%eax
801036d9:	50                   	push   %eax
801036da:	e8 9f 09 00 00       	call   8010407e <swtch>
      switchkvm();
801036df:	e8 c2 29 00 00       	call   801060a6 <switchkvm>
      c->proc = 0;
801036e4:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801036eb:	00 00 00 
801036ee:	83 c4 10             	add    $0x10,%esp
801036f1:	eb b6                	jmp    801036a9 <scheduler+0x18>
    release(&ptable.lock);
801036f3:	83 ec 0c             	sub    $0xc,%esp
801036f6:	68 40 eb 1b 80       	push   $0x801beb40
801036fb:	e8 7d 07 00 00       	call   80103e7d <release>
    sti();
80103700:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103703:	fb                   	sti    
    acquire(&ptable.lock);
80103704:	83 ec 0c             	sub    $0xc,%esp
80103707:	68 40 eb 1b 80       	push   $0x801beb40
8010370c:	e8 07 07 00 00       	call   80103e18 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103711:	83 c4 10             	add    $0x10,%esp
80103714:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103719:	eb 91                	jmp    801036ac <scheduler+0x1b>

8010371b <sched>:
{
8010371b:	55                   	push   %ebp
8010371c:	89 e5                	mov    %esp,%ebp
8010371e:	56                   	push   %esi
8010371f:	53                   	push   %ebx
  struct proc *p = myproc();
80103720:	e8 e3 fc ff ff       	call   80103408 <myproc>
80103725:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103727:	83 ec 0c             	sub    $0xc,%esp
8010372a:	68 40 eb 1b 80       	push   $0x801beb40
8010372f:	e8 a4 06 00 00       	call   80103dd8 <holding>
80103734:	83 c4 10             	add    $0x10,%esp
80103737:	85 c0                	test   %eax,%eax
80103739:	74 4f                	je     8010378a <sched+0x6f>
  if(mycpu()->ncli != 1)
8010373b:	e8 51 fc ff ff       	call   80103391 <mycpu>
80103740:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103747:	75 4e                	jne    80103797 <sched+0x7c>
  if(p->state == RUNNING)
80103749:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010374d:	74 55                	je     801037a4 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010374f:	9c                   	pushf  
80103750:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103751:	f6 c4 02             	test   $0x2,%ah
80103754:	75 5b                	jne    801037b1 <sched+0x96>
  intena = mycpu()->intena;
80103756:	e8 36 fc ff ff       	call   80103391 <mycpu>
8010375b:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103761:	e8 2b fc ff ff       	call   80103391 <mycpu>
80103766:	83 ec 08             	sub    $0x8,%esp
80103769:	ff 70 04             	pushl  0x4(%eax)
8010376c:	83 c3 1c             	add    $0x1c,%ebx
8010376f:	53                   	push   %ebx
80103770:	e8 09 09 00 00       	call   8010407e <swtch>
  mycpu()->intena = intena;
80103775:	e8 17 fc ff ff       	call   80103391 <mycpu>
8010377a:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103780:	83 c4 10             	add    $0x10,%esp
80103783:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103786:	5b                   	pop    %ebx
80103787:	5e                   	pop    %esi
80103788:	5d                   	pop    %ebp
80103789:	c3                   	ret    
    panic("sched ptable.lock");
8010378a:	83 ec 0c             	sub    $0xc,%esp
8010378d:	68 30 6d 10 80       	push   $0x80106d30
80103792:	e8 b1 cb ff ff       	call   80100348 <panic>
    panic("sched locks");
80103797:	83 ec 0c             	sub    $0xc,%esp
8010379a:	68 42 6d 10 80       	push   $0x80106d42
8010379f:	e8 a4 cb ff ff       	call   80100348 <panic>
    panic("sched running");
801037a4:	83 ec 0c             	sub    $0xc,%esp
801037a7:	68 4e 6d 10 80       	push   $0x80106d4e
801037ac:	e8 97 cb ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801037b1:	83 ec 0c             	sub    $0xc,%esp
801037b4:	68 5c 6d 10 80       	push   $0x80106d5c
801037b9:	e8 8a cb ff ff       	call   80100348 <panic>

801037be <exit>:
{
801037be:	55                   	push   %ebp
801037bf:	89 e5                	mov    %esp,%ebp
801037c1:	56                   	push   %esi
801037c2:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037c3:	e8 40 fc ff ff       	call   80103408 <myproc>
  if(curproc == initproc)
801037c8:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
801037ce:	74 09                	je     801037d9 <exit+0x1b>
801037d0:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801037d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801037d7:	eb 10                	jmp    801037e9 <exit+0x2b>
    panic("init exiting");
801037d9:	83 ec 0c             	sub    $0xc,%esp
801037dc:	68 70 6d 10 80       	push   $0x80106d70
801037e1:	e8 62 cb ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801037e6:	83 c3 01             	add    $0x1,%ebx
801037e9:	83 fb 0f             	cmp    $0xf,%ebx
801037ec:	7f 1e                	jg     8010380c <exit+0x4e>
    if(curproc->ofile[fd]){
801037ee:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801037f2:	85 c0                	test   %eax,%eax
801037f4:	74 f0                	je     801037e6 <exit+0x28>
      fileclose(curproc->ofile[fd]);
801037f6:	83 ec 0c             	sub    $0xc,%esp
801037f9:	50                   	push   %eax
801037fa:	e8 d4 d4 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
801037ff:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103806:	00 
80103807:	83 c4 10             	add    $0x10,%esp
8010380a:	eb da                	jmp    801037e6 <exit+0x28>
  begin_op();
8010380c:	e8 7f f1 ff ff       	call   80102990 <begin_op>
  iput(curproc->cwd);
80103811:	83 ec 0c             	sub    $0xc,%esp
80103814:	ff 76 68             	pushl  0x68(%esi)
80103817:	e8 6c de ff ff       	call   80101688 <iput>
  end_op();
8010381c:	e8 e9 f1 ff ff       	call   80102a0a <end_op>
  curproc->cwd = 0;
80103821:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103828:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
8010382f:	e8 e4 05 00 00       	call   80103e18 <acquire>
  wakeup1(curproc->parent);
80103834:	8b 46 14             	mov    0x14(%esi),%eax
80103837:	e8 dc f9 ff ff       	call   80103218 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010383c:	83 c4 10             	add    $0x10,%esp
8010383f:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103844:	eb 03                	jmp    80103849 <exit+0x8b>
80103846:	83 c3 7c             	add    $0x7c,%ebx
80103849:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
8010384f:	73 1a                	jae    8010386b <exit+0xad>
    if(p->parent == curproc){
80103851:	39 73 14             	cmp    %esi,0x14(%ebx)
80103854:	75 f0                	jne    80103846 <exit+0x88>
      p->parent = initproc;
80103856:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
8010385b:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010385e:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103862:	75 e2                	jne    80103846 <exit+0x88>
        wakeup1(initproc);
80103864:	e8 af f9 ff ff       	call   80103218 <wakeup1>
80103869:	eb db                	jmp    80103846 <exit+0x88>
  curproc->state = ZOMBIE;
8010386b:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103872:	e8 a4 fe ff ff       	call   8010371b <sched>
  panic("zombie exit");
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	68 7d 6d 10 80       	push   $0x80106d7d
8010387f:	e8 c4 ca ff ff       	call   80100348 <panic>

80103884 <yield>:
{
80103884:	55                   	push   %ebp
80103885:	89 e5                	mov    %esp,%ebp
80103887:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010388a:	68 40 eb 1b 80       	push   $0x801beb40
8010388f:	e8 84 05 00 00       	call   80103e18 <acquire>
  myproc()->state = RUNNABLE;
80103894:	e8 6f fb ff ff       	call   80103408 <myproc>
80103899:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801038a0:	e8 76 fe ff ff       	call   8010371b <sched>
  release(&ptable.lock);
801038a5:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801038ac:	e8 cc 05 00 00       	call   80103e7d <release>
}
801038b1:	83 c4 10             	add    $0x10,%esp
801038b4:	c9                   	leave  
801038b5:	c3                   	ret    

801038b6 <sleep>:
{
801038b6:	55                   	push   %ebp
801038b7:	89 e5                	mov    %esp,%ebp
801038b9:	56                   	push   %esi
801038ba:	53                   	push   %ebx
801038bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801038be:	e8 45 fb ff ff       	call   80103408 <myproc>
  if(p == 0)
801038c3:	85 c0                	test   %eax,%eax
801038c5:	74 66                	je     8010392d <sleep+0x77>
801038c7:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801038c9:	85 db                	test   %ebx,%ebx
801038cb:	74 6d                	je     8010393a <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801038cd:	81 fb 40 eb 1b 80    	cmp    $0x801beb40,%ebx
801038d3:	74 18                	je     801038ed <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801038d5:	83 ec 0c             	sub    $0xc,%esp
801038d8:	68 40 eb 1b 80       	push   $0x801beb40
801038dd:	e8 36 05 00 00       	call   80103e18 <acquire>
    release(lk);
801038e2:	89 1c 24             	mov    %ebx,(%esp)
801038e5:	e8 93 05 00 00       	call   80103e7d <release>
801038ea:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801038f3:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801038fa:	e8 1c fe ff ff       	call   8010371b <sched>
  p->chan = 0;
801038ff:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103906:	81 fb 40 eb 1b 80    	cmp    $0x801beb40,%ebx
8010390c:	74 18                	je     80103926 <sleep+0x70>
    release(&ptable.lock);
8010390e:	83 ec 0c             	sub    $0xc,%esp
80103911:	68 40 eb 1b 80       	push   $0x801beb40
80103916:	e8 62 05 00 00       	call   80103e7d <release>
    acquire(lk);
8010391b:	89 1c 24             	mov    %ebx,(%esp)
8010391e:	e8 f5 04 00 00       	call   80103e18 <acquire>
80103923:	83 c4 10             	add    $0x10,%esp
}
80103926:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103929:	5b                   	pop    %ebx
8010392a:	5e                   	pop    %esi
8010392b:	5d                   	pop    %ebp
8010392c:	c3                   	ret    
    panic("sleep");
8010392d:	83 ec 0c             	sub    $0xc,%esp
80103930:	68 89 6d 10 80       	push   $0x80106d89
80103935:	e8 0e ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010393a:	83 ec 0c             	sub    $0xc,%esp
8010393d:	68 8f 6d 10 80       	push   $0x80106d8f
80103942:	e8 01 ca ff ff       	call   80100348 <panic>

80103947 <wait>:
{
80103947:	55                   	push   %ebp
80103948:	89 e5                	mov    %esp,%ebp
8010394a:	56                   	push   %esi
8010394b:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010394c:	e8 b7 fa ff ff       	call   80103408 <myproc>
80103951:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103953:	83 ec 0c             	sub    $0xc,%esp
80103956:	68 40 eb 1b 80       	push   $0x801beb40
8010395b:	e8 b8 04 00 00       	call   80103e18 <acquire>
80103960:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103963:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103968:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
8010396d:	eb 5b                	jmp    801039ca <wait+0x83>
        pid = p->pid;
8010396f:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103972:	83 ec 0c             	sub    $0xc,%esp
80103975:	ff 73 08             	pushl  0x8(%ebx)
80103978:	e8 27 e6 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
8010397d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103984:	83 c4 04             	add    $0x4,%esp
80103987:	ff 73 04             	pushl  0x4(%ebx)
8010398a:	e8 c6 2a 00 00       	call   80106455 <freevm>
        p->pid = 0;
8010398f:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103996:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010399d:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801039a1:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801039a8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801039af:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801039b6:	e8 c2 04 00 00       	call   80103e7d <release>
        return pid;
801039bb:	83 c4 10             	add    $0x10,%esp
}
801039be:	89 f0                	mov    %esi,%eax
801039c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039c3:	5b                   	pop    %ebx
801039c4:	5e                   	pop    %esi
801039c5:	5d                   	pop    %ebp
801039c6:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039c7:	83 c3 7c             	add    $0x7c,%ebx
801039ca:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
801039d0:	73 12                	jae    801039e4 <wait+0x9d>
      if(p->parent != curproc)
801039d2:	39 73 14             	cmp    %esi,0x14(%ebx)
801039d5:	75 f0                	jne    801039c7 <wait+0x80>
      if(p->state == ZOMBIE){
801039d7:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801039db:	74 92                	je     8010396f <wait+0x28>
      havekids = 1;
801039dd:	b8 01 00 00 00       	mov    $0x1,%eax
801039e2:	eb e3                	jmp    801039c7 <wait+0x80>
    if(!havekids || curproc->killed){
801039e4:	85 c0                	test   %eax,%eax
801039e6:	74 06                	je     801039ee <wait+0xa7>
801039e8:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801039ec:	74 17                	je     80103a05 <wait+0xbe>
      release(&ptable.lock);
801039ee:	83 ec 0c             	sub    $0xc,%esp
801039f1:	68 40 eb 1b 80       	push   $0x801beb40
801039f6:	e8 82 04 00 00       	call   80103e7d <release>
      return -1;
801039fb:	83 c4 10             	add    $0x10,%esp
801039fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103a03:	eb b9                	jmp    801039be <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103a05:	83 ec 08             	sub    $0x8,%esp
80103a08:	68 40 eb 1b 80       	push   $0x801beb40
80103a0d:	56                   	push   %esi
80103a0e:	e8 a3 fe ff ff       	call   801038b6 <sleep>
    havekids = 0;
80103a13:	83 c4 10             	add    $0x10,%esp
80103a16:	e9 48 ff ff ff       	jmp    80103963 <wait+0x1c>

80103a1b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103a1b:	55                   	push   %ebp
80103a1c:	89 e5                	mov    %esp,%ebp
80103a1e:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103a21:	68 40 eb 1b 80       	push   $0x801beb40
80103a26:	e8 ed 03 00 00       	call   80103e18 <acquire>
  wakeup1(chan);
80103a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2e:	e8 e5 f7 ff ff       	call   80103218 <wakeup1>
  release(&ptable.lock);
80103a33:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103a3a:	e8 3e 04 00 00       	call   80103e7d <release>
}
80103a3f:	83 c4 10             	add    $0x10,%esp
80103a42:	c9                   	leave  
80103a43:	c3                   	ret    

80103a44 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103a44:	55                   	push   %ebp
80103a45:	89 e5                	mov    %esp,%ebp
80103a47:	53                   	push   %ebx
80103a48:	83 ec 10             	sub    $0x10,%esp
80103a4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103a4e:	68 40 eb 1b 80       	push   $0x801beb40
80103a53:	e8 c0 03 00 00       	call   80103e18 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a58:	83 c4 10             	add    $0x10,%esp
80103a5b:	b8 74 eb 1b 80       	mov    $0x801beb74,%eax
80103a60:	3d 74 0a 1c 80       	cmp    $0x801c0a74,%eax
80103a65:	73 3a                	jae    80103aa1 <kill+0x5d>
    if(p->pid == pid){
80103a67:	39 58 10             	cmp    %ebx,0x10(%eax)
80103a6a:	74 05                	je     80103a71 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a6c:	83 c0 7c             	add    $0x7c,%eax
80103a6f:	eb ef                	jmp    80103a60 <kill+0x1c>
      p->killed = 1;
80103a71:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103a78:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a7c:	74 1a                	je     80103a98 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103a7e:	83 ec 0c             	sub    $0xc,%esp
80103a81:	68 40 eb 1b 80       	push   $0x801beb40
80103a86:	e8 f2 03 00 00       	call   80103e7d <release>
      return 0;
80103a8b:	83 c4 10             	add    $0x10,%esp
80103a8e:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a96:	c9                   	leave  
80103a97:	c3                   	ret    
        p->state = RUNNABLE;
80103a98:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a9f:	eb dd                	jmp    80103a7e <kill+0x3a>
  release(&ptable.lock);
80103aa1:	83 ec 0c             	sub    $0xc,%esp
80103aa4:	68 40 eb 1b 80       	push   $0x801beb40
80103aa9:	e8 cf 03 00 00       	call   80103e7d <release>
  return -1;
80103aae:	83 c4 10             	add    $0x10,%esp
80103ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ab6:	eb db                	jmp    80103a93 <kill+0x4f>

80103ab8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103ab8:	55                   	push   %ebp
80103ab9:	89 e5                	mov    %esp,%ebp
80103abb:	56                   	push   %esi
80103abc:	53                   	push   %ebx
80103abd:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ac0:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103ac5:	eb 33                	jmp    80103afa <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103ac7:	b8 a0 6d 10 80       	mov    $0x80106da0,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103acc:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103acf:	52                   	push   %edx
80103ad0:	50                   	push   %eax
80103ad1:	ff 73 10             	pushl  0x10(%ebx)
80103ad4:	68 a4 6d 10 80       	push   $0x80106da4
80103ad9:	e8 2d cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103ade:	83 c4 10             	add    $0x10,%esp
80103ae1:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103ae5:	74 39                	je     80103b20 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103ae7:	83 ec 0c             	sub    $0xc,%esp
80103aea:	68 1b 71 10 80       	push   $0x8010711b
80103aef:	e8 17 cb ff ff       	call   8010060b <cprintf>
80103af4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103af7:	83 c3 7c             	add    $0x7c,%ebx
80103afa:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103b00:	73 61                	jae    80103b63 <procdump+0xab>
    if(p->state == UNUSED)
80103b02:	8b 43 0c             	mov    0xc(%ebx),%eax
80103b05:	85 c0                	test   %eax,%eax
80103b07:	74 ee                	je     80103af7 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103b09:	83 f8 05             	cmp    $0x5,%eax
80103b0c:	77 b9                	ja     80103ac7 <procdump+0xf>
80103b0e:	8b 04 85 00 6e 10 80 	mov    -0x7fef9200(,%eax,4),%eax
80103b15:	85 c0                	test   %eax,%eax
80103b17:	75 b3                	jne    80103acc <procdump+0x14>
      state = "???";
80103b19:	b8 a0 6d 10 80       	mov    $0x80106da0,%eax
80103b1e:	eb ac                	jmp    80103acc <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103b20:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103b23:	8b 40 0c             	mov    0xc(%eax),%eax
80103b26:	83 c0 08             	add    $0x8,%eax
80103b29:	83 ec 08             	sub    $0x8,%esp
80103b2c:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103b2f:	52                   	push   %edx
80103b30:	50                   	push   %eax
80103b31:	e8 c1 01 00 00       	call   80103cf7 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103b36:	83 c4 10             	add    $0x10,%esp
80103b39:	be 00 00 00 00       	mov    $0x0,%esi
80103b3e:	eb 14                	jmp    80103b54 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103b40:	83 ec 08             	sub    $0x8,%esp
80103b43:	50                   	push   %eax
80103b44:	68 61 67 10 80       	push   $0x80106761
80103b49:	e8 bd ca ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103b4e:	83 c6 01             	add    $0x1,%esi
80103b51:	83 c4 10             	add    $0x10,%esp
80103b54:	83 fe 09             	cmp    $0x9,%esi
80103b57:	7f 8e                	jg     80103ae7 <procdump+0x2f>
80103b59:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103b5d:	85 c0                	test   %eax,%eax
80103b5f:	75 df                	jne    80103b40 <procdump+0x88>
80103b61:	eb 84                	jmp    80103ae7 <procdump+0x2f>
  }
}
80103b63:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b66:	5b                   	pop    %ebx
80103b67:	5e                   	pop    %esi
80103b68:	5d                   	pop    %ebp
80103b69:	c3                   	ret    

80103b6a <dump_physmem>:

int 
dump_physmem(int *userFrames, int *userPids, int nframes)
{
80103b6a:	55                   	push   %ebp
80103b6b:	89 e5                	mov    %esp,%ebp
80103b6d:	56                   	push   %esi
80103b6e:	53                   	push   %ebx
80103b6f:	8b 75 08             	mov    0x8(%ebp),%esi
80103b72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103b75:	8b 55 10             	mov    0x10(%ebp),%edx
    if(nframes < 0 || userFrames == 0 || userPids == 0){
80103b78:	89 d0                	mov    %edx,%eax
80103b7a:	c1 e8 1f             	shr    $0x1f,%eax
80103b7d:	85 f6                	test   %esi,%esi
80103b7f:	0f 94 c1             	sete   %cl
80103b82:	08 c1                	or     %al,%cl
80103b84:	75 3d                	jne    80103bc3 <dump_physmem+0x59>
80103b86:	85 db                	test   %ebx,%ebx
80103b88:	74 40                	je     80103bca <dump_physmem+0x60>
     return -1;
    }
    //cprintf("Inside dump_physmem %d,\n",nframes);
    //int fr[numframes];
    for(int i=0; i < nframes; i++)
80103b8a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b8f:	eb 0d                	jmp    80103b9e <dump_physmem+0x34>
    {
      userFrames[i] = frames[i+65];
80103b91:	8b 0c 85 84 eb 1a 80 	mov    -0x7fe5147c(,%eax,4),%ecx
80103b98:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
    for(int i=0; i < nframes; i++)
80103b9b:	83 c0 01             	add    $0x1,%eax
80103b9e:	39 d0                	cmp    %edx,%eax
80103ba0:	7c ef                	jl     80103b91 <dump_physmem+0x27>
      //cprintf("%d,%x,%x\n",i,userFrames[i],frames[i]);
    }
    //userFrames = fr;
    for(int i=0; i < nframes; i++)
80103ba2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba7:	eb 0d                	jmp    80103bb6 <dump_physmem+0x4c>
    {
      userPids[i] = pid[i+65];
80103ba9:	8b 0c 85 84 27 11 80 	mov    -0x7feed87c(,%eax,4),%ecx
80103bb0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
    for(int i=0; i < nframes; i++)
80103bb3:	83 c0 01             	add    $0x1,%eax
80103bb6:	39 d0                	cmp    %edx,%eax
80103bb8:	7c ef                	jl     80103ba9 <dump_physmem+0x3f>
      //cprintf("%d\n", pid[i]);
    }

    return 0;
80103bba:	b8 00 00 00 00       	mov    $0x0,%eax

}
80103bbf:	5b                   	pop    %ebx
80103bc0:	5e                   	pop    %esi
80103bc1:	5d                   	pop    %ebp
80103bc2:	c3                   	ret    
     return -1;
80103bc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103bc8:	eb f5                	jmp    80103bbf <dump_physmem+0x55>
80103bca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103bcf:	eb ee                	jmp    80103bbf <dump_physmem+0x55>

80103bd1 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103bd1:	55                   	push   %ebp
80103bd2:	89 e5                	mov    %esp,%ebp
80103bd4:	53                   	push   %ebx
80103bd5:	83 ec 0c             	sub    $0xc,%esp
80103bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103bdb:	68 18 6e 10 80       	push   $0x80106e18
80103be0:	8d 43 04             	lea    0x4(%ebx),%eax
80103be3:	50                   	push   %eax
80103be4:	e8 f3 00 00 00       	call   80103cdc <initlock>
  lk->name = name;
80103be9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bec:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103bef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103bf5:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103bfc:	83 c4 10             	add    $0x10,%esp
80103bff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c02:	c9                   	leave  
80103c03:	c3                   	ret    

80103c04 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103c04:	55                   	push   %ebp
80103c05:	89 e5                	mov    %esp,%ebp
80103c07:	56                   	push   %esi
80103c08:	53                   	push   %ebx
80103c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c0c:	8d 73 04             	lea    0x4(%ebx),%esi
80103c0f:	83 ec 0c             	sub    $0xc,%esp
80103c12:	56                   	push   %esi
80103c13:	e8 00 02 00 00       	call   80103e18 <acquire>
  while (lk->locked) {
80103c18:	83 c4 10             	add    $0x10,%esp
80103c1b:	eb 0d                	jmp    80103c2a <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103c1d:	83 ec 08             	sub    $0x8,%esp
80103c20:	56                   	push   %esi
80103c21:	53                   	push   %ebx
80103c22:	e8 8f fc ff ff       	call   801038b6 <sleep>
80103c27:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103c2a:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c2d:	75 ee                	jne    80103c1d <acquiresleep+0x19>
  }
  lk->locked = 1;
80103c2f:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c35:	e8 ce f7 ff ff       	call   80103408 <myproc>
80103c3a:	8b 40 10             	mov    0x10(%eax),%eax
80103c3d:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c40:	83 ec 0c             	sub    $0xc,%esp
80103c43:	56                   	push   %esi
80103c44:	e8 34 02 00 00       	call   80103e7d <release>
}
80103c49:	83 c4 10             	add    $0x10,%esp
80103c4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c4f:	5b                   	pop    %ebx
80103c50:	5e                   	pop    %esi
80103c51:	5d                   	pop    %ebp
80103c52:	c3                   	ret    

80103c53 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103c53:	55                   	push   %ebp
80103c54:	89 e5                	mov    %esp,%ebp
80103c56:	56                   	push   %esi
80103c57:	53                   	push   %ebx
80103c58:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c5b:	8d 73 04             	lea    0x4(%ebx),%esi
80103c5e:	83 ec 0c             	sub    $0xc,%esp
80103c61:	56                   	push   %esi
80103c62:	e8 b1 01 00 00       	call   80103e18 <acquire>
  lk->locked = 0;
80103c67:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c6d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103c74:	89 1c 24             	mov    %ebx,(%esp)
80103c77:	e8 9f fd ff ff       	call   80103a1b <wakeup>
  release(&lk->lk);
80103c7c:	89 34 24             	mov    %esi,(%esp)
80103c7f:	e8 f9 01 00 00       	call   80103e7d <release>
}
80103c84:	83 c4 10             	add    $0x10,%esp
80103c87:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c8a:	5b                   	pop    %ebx
80103c8b:	5e                   	pop    %esi
80103c8c:	5d                   	pop    %ebp
80103c8d:	c3                   	ret    

80103c8e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103c8e:	55                   	push   %ebp
80103c8f:	89 e5                	mov    %esp,%ebp
80103c91:	56                   	push   %esi
80103c92:	53                   	push   %ebx
80103c93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103c96:	8d 73 04             	lea    0x4(%ebx),%esi
80103c99:	83 ec 0c             	sub    $0xc,%esp
80103c9c:	56                   	push   %esi
80103c9d:	e8 76 01 00 00       	call   80103e18 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103ca2:	83 c4 10             	add    $0x10,%esp
80103ca5:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ca8:	75 17                	jne    80103cc1 <holdingsleep+0x33>
80103caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103caf:	83 ec 0c             	sub    $0xc,%esp
80103cb2:	56                   	push   %esi
80103cb3:	e8 c5 01 00 00       	call   80103e7d <release>
  return r;
}
80103cb8:	89 d8                	mov    %ebx,%eax
80103cba:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cbd:	5b                   	pop    %ebx
80103cbe:	5e                   	pop    %esi
80103cbf:	5d                   	pop    %ebp
80103cc0:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103cc1:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103cc4:	e8 3f f7 ff ff       	call   80103408 <myproc>
80103cc9:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ccc:	74 07                	je     80103cd5 <holdingsleep+0x47>
80103cce:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cd3:	eb da                	jmp    80103caf <holdingsleep+0x21>
80103cd5:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cda:	eb d3                	jmp    80103caf <holdingsleep+0x21>

80103cdc <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103cdc:	55                   	push   %ebp
80103cdd:	89 e5                	mov    %esp,%ebp
80103cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103ce2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ce5:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103ce8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103cee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103cf5:	5d                   	pop    %ebp
80103cf6:	c3                   	ret    

80103cf7 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103cf7:	55                   	push   %ebp
80103cf8:	89 e5                	mov    %esp,%ebp
80103cfa:	53                   	push   %ebx
80103cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80103d01:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103d04:	b8 00 00 00 00       	mov    $0x0,%eax
80103d09:	83 f8 09             	cmp    $0x9,%eax
80103d0c:	7f 25                	jg     80103d33 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d0e:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d14:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d1a:	77 17                	ja     80103d33 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d1c:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d1f:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d22:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d24:	83 c0 01             	add    $0x1,%eax
80103d27:	eb e0                	jmp    80103d09 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d29:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d30:	83 c0 01             	add    $0x1,%eax
80103d33:	83 f8 09             	cmp    $0x9,%eax
80103d36:	7e f1                	jle    80103d29 <getcallerpcs+0x32>
}
80103d38:	5b                   	pop    %ebx
80103d39:	5d                   	pop    %ebp
80103d3a:	c3                   	ret    

80103d3b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d3b:	55                   	push   %ebp
80103d3c:	89 e5                	mov    %esp,%ebp
80103d3e:	53                   	push   %ebx
80103d3f:	83 ec 04             	sub    $0x4,%esp
80103d42:	9c                   	pushf  
80103d43:	5b                   	pop    %ebx
  asm volatile("cli");
80103d44:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d45:	e8 47 f6 ff ff       	call   80103391 <mycpu>
80103d4a:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d51:	74 12                	je     80103d65 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103d53:	e8 39 f6 ff ff       	call   80103391 <mycpu>
80103d58:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103d5f:	83 c4 04             	add    $0x4,%esp
80103d62:	5b                   	pop    %ebx
80103d63:	5d                   	pop    %ebp
80103d64:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103d65:	e8 27 f6 ff ff       	call   80103391 <mycpu>
80103d6a:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d70:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103d76:	eb db                	jmp    80103d53 <pushcli+0x18>

80103d78 <popcli>:

void
popcli(void)
{
80103d78:	55                   	push   %ebp
80103d79:	89 e5                	mov    %esp,%ebp
80103d7b:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d7e:	9c                   	pushf  
80103d7f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d80:	f6 c4 02             	test   $0x2,%ah
80103d83:	75 28                	jne    80103dad <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103d85:	e8 07 f6 ff ff       	call   80103391 <mycpu>
80103d8a:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103d90:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103d93:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103d99:	85 d2                	test   %edx,%edx
80103d9b:	78 1d                	js     80103dba <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d9d:	e8 ef f5 ff ff       	call   80103391 <mycpu>
80103da2:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103da9:	74 1c                	je     80103dc7 <popcli+0x4f>
    sti();
}
80103dab:	c9                   	leave  
80103dac:	c3                   	ret    
    panic("popcli - interruptible");
80103dad:	83 ec 0c             	sub    $0xc,%esp
80103db0:	68 23 6e 10 80       	push   $0x80106e23
80103db5:	e8 8e c5 ff ff       	call   80100348 <panic>
    panic("popcli");
80103dba:	83 ec 0c             	sub    $0xc,%esp
80103dbd:	68 3a 6e 10 80       	push   $0x80106e3a
80103dc2:	e8 81 c5 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103dc7:	e8 c5 f5 ff ff       	call   80103391 <mycpu>
80103dcc:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103dd3:	74 d6                	je     80103dab <popcli+0x33>
  asm volatile("sti");
80103dd5:	fb                   	sti    
}
80103dd6:	eb d3                	jmp    80103dab <popcli+0x33>

80103dd8 <holding>:
{
80103dd8:	55                   	push   %ebp
80103dd9:	89 e5                	mov    %esp,%ebp
80103ddb:	53                   	push   %ebx
80103ddc:	83 ec 04             	sub    $0x4,%esp
80103ddf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103de2:	e8 54 ff ff ff       	call   80103d3b <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103de7:	83 3b 00             	cmpl   $0x0,(%ebx)
80103dea:	75 12                	jne    80103dfe <holding+0x26>
80103dec:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103df1:	e8 82 ff ff ff       	call   80103d78 <popcli>
}
80103df6:	89 d8                	mov    %ebx,%eax
80103df8:	83 c4 04             	add    $0x4,%esp
80103dfb:	5b                   	pop    %ebx
80103dfc:	5d                   	pop    %ebp
80103dfd:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103dfe:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103e01:	e8 8b f5 ff ff       	call   80103391 <mycpu>
80103e06:	39 c3                	cmp    %eax,%ebx
80103e08:	74 07                	je     80103e11 <holding+0x39>
80103e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e0f:	eb e0                	jmp    80103df1 <holding+0x19>
80103e11:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e16:	eb d9                	jmp    80103df1 <holding+0x19>

80103e18 <acquire>:
{
80103e18:	55                   	push   %ebp
80103e19:	89 e5                	mov    %esp,%ebp
80103e1b:	53                   	push   %ebx
80103e1c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e1f:	e8 17 ff ff ff       	call   80103d3b <pushcli>
  if(holding(lk))
80103e24:	83 ec 0c             	sub    $0xc,%esp
80103e27:	ff 75 08             	pushl  0x8(%ebp)
80103e2a:	e8 a9 ff ff ff       	call   80103dd8 <holding>
80103e2f:	83 c4 10             	add    $0x10,%esp
80103e32:	85 c0                	test   %eax,%eax
80103e34:	75 3a                	jne    80103e70 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103e36:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103e39:	b8 01 00 00 00       	mov    $0x1,%eax
80103e3e:	f0 87 02             	lock xchg %eax,(%edx)
80103e41:	85 c0                	test   %eax,%eax
80103e43:	75 f1                	jne    80103e36 <acquire+0x1e>
  __sync_synchronize();
80103e45:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103e4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e4d:	e8 3f f5 ff ff       	call   80103391 <mycpu>
80103e52:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e55:	8b 45 08             	mov    0x8(%ebp),%eax
80103e58:	83 c0 0c             	add    $0xc,%eax
80103e5b:	83 ec 08             	sub    $0x8,%esp
80103e5e:	50                   	push   %eax
80103e5f:	8d 45 08             	lea    0x8(%ebp),%eax
80103e62:	50                   	push   %eax
80103e63:	e8 8f fe ff ff       	call   80103cf7 <getcallerpcs>
}
80103e68:	83 c4 10             	add    $0x10,%esp
80103e6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e6e:	c9                   	leave  
80103e6f:	c3                   	ret    
    panic("acquire");
80103e70:	83 ec 0c             	sub    $0xc,%esp
80103e73:	68 41 6e 10 80       	push   $0x80106e41
80103e78:	e8 cb c4 ff ff       	call   80100348 <panic>

80103e7d <release>:
{
80103e7d:	55                   	push   %ebp
80103e7e:	89 e5                	mov    %esp,%ebp
80103e80:	53                   	push   %ebx
80103e81:	83 ec 10             	sub    $0x10,%esp
80103e84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103e87:	53                   	push   %ebx
80103e88:	e8 4b ff ff ff       	call   80103dd8 <holding>
80103e8d:	83 c4 10             	add    $0x10,%esp
80103e90:	85 c0                	test   %eax,%eax
80103e92:	74 23                	je     80103eb7 <release+0x3a>
  lk->pcs[0] = 0;
80103e94:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103e9b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103ea2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ea7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103ead:	e8 c6 fe ff ff       	call   80103d78 <popcli>
}
80103eb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eb5:	c9                   	leave  
80103eb6:	c3                   	ret    
    panic("release");
80103eb7:	83 ec 0c             	sub    $0xc,%esp
80103eba:	68 49 6e 10 80       	push   $0x80106e49
80103ebf:	e8 84 c4 ff ff       	call   80100348 <panic>

80103ec4 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ec4:	55                   	push   %ebp
80103ec5:	89 e5                	mov    %esp,%ebp
80103ec7:	57                   	push   %edi
80103ec8:	53                   	push   %ebx
80103ec9:	8b 55 08             	mov    0x8(%ebp),%edx
80103ecc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103ecf:	f6 c2 03             	test   $0x3,%dl
80103ed2:	75 05                	jne    80103ed9 <memset+0x15>
80103ed4:	f6 c1 03             	test   $0x3,%cl
80103ed7:	74 0e                	je     80103ee7 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103ed9:	89 d7                	mov    %edx,%edi
80103edb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ede:	fc                   	cld    
80103edf:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103ee1:	89 d0                	mov    %edx,%eax
80103ee3:	5b                   	pop    %ebx
80103ee4:	5f                   	pop    %edi
80103ee5:	5d                   	pop    %ebp
80103ee6:	c3                   	ret    
    c &= 0xFF;
80103ee7:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103eeb:	c1 e9 02             	shr    $0x2,%ecx
80103eee:	89 f8                	mov    %edi,%eax
80103ef0:	c1 e0 18             	shl    $0x18,%eax
80103ef3:	89 fb                	mov    %edi,%ebx
80103ef5:	c1 e3 10             	shl    $0x10,%ebx
80103ef8:	09 d8                	or     %ebx,%eax
80103efa:	89 fb                	mov    %edi,%ebx
80103efc:	c1 e3 08             	shl    $0x8,%ebx
80103eff:	09 d8                	or     %ebx,%eax
80103f01:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103f03:	89 d7                	mov    %edx,%edi
80103f05:	fc                   	cld    
80103f06:	f3 ab                	rep stos %eax,%es:(%edi)
80103f08:	eb d7                	jmp    80103ee1 <memset+0x1d>

80103f0a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103f0a:	55                   	push   %ebp
80103f0b:	89 e5                	mov    %esp,%ebp
80103f0d:	56                   	push   %esi
80103f0e:	53                   	push   %ebx
80103f0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f15:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f18:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f1b:	85 c0                	test   %eax,%eax
80103f1d:	74 1c                	je     80103f3b <memcmp+0x31>
    if(*s1 != *s2)
80103f1f:	0f b6 01             	movzbl (%ecx),%eax
80103f22:	0f b6 1a             	movzbl (%edx),%ebx
80103f25:	38 d8                	cmp    %bl,%al
80103f27:	75 0a                	jne    80103f33 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103f29:	83 c1 01             	add    $0x1,%ecx
80103f2c:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103f2f:	89 f0                	mov    %esi,%eax
80103f31:	eb e5                	jmp    80103f18 <memcmp+0xe>
      return *s1 - *s2;
80103f33:	0f b6 c0             	movzbl %al,%eax
80103f36:	0f b6 db             	movzbl %bl,%ebx
80103f39:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103f3b:	5b                   	pop    %ebx
80103f3c:	5e                   	pop    %esi
80103f3d:	5d                   	pop    %ebp
80103f3e:	c3                   	ret    

80103f3f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f3f:	55                   	push   %ebp
80103f40:	89 e5                	mov    %esp,%ebp
80103f42:	56                   	push   %esi
80103f43:	53                   	push   %ebx
80103f44:	8b 45 08             	mov    0x8(%ebp),%eax
80103f47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f4a:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f4d:	39 c1                	cmp    %eax,%ecx
80103f4f:	73 3a                	jae    80103f8b <memmove+0x4c>
80103f51:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103f54:	39 c3                	cmp    %eax,%ebx
80103f56:	76 37                	jbe    80103f8f <memmove+0x50>
    s += n;
    d += n;
80103f58:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103f5b:	eb 0d                	jmp    80103f6a <memmove+0x2b>
      *--d = *--s;
80103f5d:	83 eb 01             	sub    $0x1,%ebx
80103f60:	83 e9 01             	sub    $0x1,%ecx
80103f63:	0f b6 13             	movzbl (%ebx),%edx
80103f66:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103f68:	89 f2                	mov    %esi,%edx
80103f6a:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f6d:	85 d2                	test   %edx,%edx
80103f6f:	75 ec                	jne    80103f5d <memmove+0x1e>
80103f71:	eb 14                	jmp    80103f87 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103f73:	0f b6 11             	movzbl (%ecx),%edx
80103f76:	88 13                	mov    %dl,(%ebx)
80103f78:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103f7b:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103f7e:	89 f2                	mov    %esi,%edx
80103f80:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f83:	85 d2                	test   %edx,%edx
80103f85:	75 ec                	jne    80103f73 <memmove+0x34>

  return dst;
}
80103f87:	5b                   	pop    %ebx
80103f88:	5e                   	pop    %esi
80103f89:	5d                   	pop    %ebp
80103f8a:	c3                   	ret    
80103f8b:	89 c3                	mov    %eax,%ebx
80103f8d:	eb f1                	jmp    80103f80 <memmove+0x41>
80103f8f:	89 c3                	mov    %eax,%ebx
80103f91:	eb ed                	jmp    80103f80 <memmove+0x41>

80103f93 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103f93:	55                   	push   %ebp
80103f94:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103f96:	ff 75 10             	pushl  0x10(%ebp)
80103f99:	ff 75 0c             	pushl  0xc(%ebp)
80103f9c:	ff 75 08             	pushl  0x8(%ebp)
80103f9f:	e8 9b ff ff ff       	call   80103f3f <memmove>
}
80103fa4:	c9                   	leave  
80103fa5:	c3                   	ret    

80103fa6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103fa6:	55                   	push   %ebp
80103fa7:	89 e5                	mov    %esp,%ebp
80103fa9:	53                   	push   %ebx
80103faa:	8b 55 08             	mov    0x8(%ebp),%edx
80103fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103fb3:	eb 09                	jmp    80103fbe <strncmp+0x18>
    n--, p++, q++;
80103fb5:	83 e8 01             	sub    $0x1,%eax
80103fb8:	83 c2 01             	add    $0x1,%edx
80103fbb:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103fbe:	85 c0                	test   %eax,%eax
80103fc0:	74 0b                	je     80103fcd <strncmp+0x27>
80103fc2:	0f b6 1a             	movzbl (%edx),%ebx
80103fc5:	84 db                	test   %bl,%bl
80103fc7:	74 04                	je     80103fcd <strncmp+0x27>
80103fc9:	3a 19                	cmp    (%ecx),%bl
80103fcb:	74 e8                	je     80103fb5 <strncmp+0xf>
  if(n == 0)
80103fcd:	85 c0                	test   %eax,%eax
80103fcf:	74 0b                	je     80103fdc <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103fd1:	0f b6 02             	movzbl (%edx),%eax
80103fd4:	0f b6 11             	movzbl (%ecx),%edx
80103fd7:	29 d0                	sub    %edx,%eax
}
80103fd9:	5b                   	pop    %ebx
80103fda:	5d                   	pop    %ebp
80103fdb:	c3                   	ret    
    return 0;
80103fdc:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe1:	eb f6                	jmp    80103fd9 <strncmp+0x33>

80103fe3 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103fe3:	55                   	push   %ebp
80103fe4:	89 e5                	mov    %esp,%ebp
80103fe6:	57                   	push   %edi
80103fe7:	56                   	push   %esi
80103fe8:	53                   	push   %ebx
80103fe9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103fec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	eb 04                	jmp    80103ff8 <strncpy+0x15>
80103ff4:	89 fb                	mov    %edi,%ebx
80103ff6:	89 f0                	mov    %esi,%eax
80103ff8:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ffb:	85 c9                	test   %ecx,%ecx
80103ffd:	7e 1d                	jle    8010401c <strncpy+0x39>
80103fff:	8d 7b 01             	lea    0x1(%ebx),%edi
80104002:	8d 70 01             	lea    0x1(%eax),%esi
80104005:	0f b6 1b             	movzbl (%ebx),%ebx
80104008:	88 18                	mov    %bl,(%eax)
8010400a:	89 d1                	mov    %edx,%ecx
8010400c:	84 db                	test   %bl,%bl
8010400e:	75 e4                	jne    80103ff4 <strncpy+0x11>
80104010:	89 f0                	mov    %esi,%eax
80104012:	eb 08                	jmp    8010401c <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104014:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104017:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104019:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
8010401c:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010401f:	85 d2                	test   %edx,%edx
80104021:	7f f1                	jg     80104014 <strncpy+0x31>
  return os;
}
80104023:	8b 45 08             	mov    0x8(%ebp),%eax
80104026:	5b                   	pop    %ebx
80104027:	5e                   	pop    %esi
80104028:	5f                   	pop    %edi
80104029:	5d                   	pop    %ebp
8010402a:	c3                   	ret    

8010402b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010402b:	55                   	push   %ebp
8010402c:	89 e5                	mov    %esp,%ebp
8010402e:	57                   	push   %edi
8010402f:	56                   	push   %esi
80104030:	53                   	push   %ebx
80104031:	8b 45 08             	mov    0x8(%ebp),%eax
80104034:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104037:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
8010403a:	85 d2                	test   %edx,%edx
8010403c:	7e 23                	jle    80104061 <safestrcpy+0x36>
8010403e:	89 c1                	mov    %eax,%ecx
80104040:	eb 04                	jmp    80104046 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104042:	89 fb                	mov    %edi,%ebx
80104044:	89 f1                	mov    %esi,%ecx
80104046:	83 ea 01             	sub    $0x1,%edx
80104049:	85 d2                	test   %edx,%edx
8010404b:	7e 11                	jle    8010405e <safestrcpy+0x33>
8010404d:	8d 7b 01             	lea    0x1(%ebx),%edi
80104050:	8d 71 01             	lea    0x1(%ecx),%esi
80104053:	0f b6 1b             	movzbl (%ebx),%ebx
80104056:	88 19                	mov    %bl,(%ecx)
80104058:	84 db                	test   %bl,%bl
8010405a:	75 e6                	jne    80104042 <safestrcpy+0x17>
8010405c:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010405e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104061:	5b                   	pop    %ebx
80104062:	5e                   	pop    %esi
80104063:	5f                   	pop    %edi
80104064:	5d                   	pop    %ebp
80104065:	c3                   	ret    

80104066 <strlen>:

int
strlen(const char *s)
{
80104066:	55                   	push   %ebp
80104067:	89 e5                	mov    %esp,%ebp
80104069:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
8010406c:	b8 00 00 00 00       	mov    $0x0,%eax
80104071:	eb 03                	jmp    80104076 <strlen+0x10>
80104073:	83 c0 01             	add    $0x1,%eax
80104076:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
8010407a:	75 f7                	jne    80104073 <strlen+0xd>
    ;
  return n;
}
8010407c:	5d                   	pop    %ebp
8010407d:	c3                   	ret    

8010407e <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010407e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104082:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104086:	55                   	push   %ebp
  pushl %ebx
80104087:	53                   	push   %ebx
  pushl %esi
80104088:	56                   	push   %esi
  pushl %edi
80104089:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010408a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010408c:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010408e:	5f                   	pop    %edi
  popl %esi
8010408f:	5e                   	pop    %esi
  popl %ebx
80104090:	5b                   	pop    %ebx
  popl %ebp
80104091:	5d                   	pop    %ebp
  ret
80104092:	c3                   	ret    

80104093 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104093:	55                   	push   %ebp
80104094:	89 e5                	mov    %esp,%ebp
80104096:	53                   	push   %ebx
80104097:	83 ec 04             	sub    $0x4,%esp
8010409a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
8010409d:	e8 66 f3 ff ff       	call   80103408 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801040a2:	8b 00                	mov    (%eax),%eax
801040a4:	39 d8                	cmp    %ebx,%eax
801040a6:	76 19                	jbe    801040c1 <fetchint+0x2e>
801040a8:	8d 53 04             	lea    0x4(%ebx),%edx
801040ab:	39 d0                	cmp    %edx,%eax
801040ad:	72 19                	jb     801040c8 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801040af:	8b 13                	mov    (%ebx),%edx
801040b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b4:	89 10                	mov    %edx,(%eax)
  return 0;
801040b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040bb:	83 c4 04             	add    $0x4,%esp
801040be:	5b                   	pop    %ebx
801040bf:	5d                   	pop    %ebp
801040c0:	c3                   	ret    
    return -1;
801040c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c6:	eb f3                	jmp    801040bb <fetchint+0x28>
801040c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cd:	eb ec                	jmp    801040bb <fetchint+0x28>

801040cf <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801040cf:	55                   	push   %ebp
801040d0:	89 e5                	mov    %esp,%ebp
801040d2:	53                   	push   %ebx
801040d3:	83 ec 04             	sub    $0x4,%esp
801040d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801040d9:	e8 2a f3 ff ff       	call   80103408 <myproc>

  if(addr >= curproc->sz)
801040de:	39 18                	cmp    %ebx,(%eax)
801040e0:	76 26                	jbe    80104108 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
801040e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801040e5:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801040e7:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801040e9:	89 d8                	mov    %ebx,%eax
801040eb:	39 d0                	cmp    %edx,%eax
801040ed:	73 0e                	jae    801040fd <fetchstr+0x2e>
    if(*s == 0)
801040ef:	80 38 00             	cmpb   $0x0,(%eax)
801040f2:	74 05                	je     801040f9 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
801040f4:	83 c0 01             	add    $0x1,%eax
801040f7:	eb f2                	jmp    801040eb <fetchstr+0x1c>
      return s - *pp;
801040f9:	29 d8                	sub    %ebx,%eax
801040fb:	eb 05                	jmp    80104102 <fetchstr+0x33>
  }
  return -1;
801040fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104102:	83 c4 04             	add    $0x4,%esp
80104105:	5b                   	pop    %ebx
80104106:	5d                   	pop    %ebp
80104107:	c3                   	ret    
    return -1;
80104108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410d:	eb f3                	jmp    80104102 <fetchstr+0x33>

8010410f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010410f:	55                   	push   %ebp
80104110:	89 e5                	mov    %esp,%ebp
80104112:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104115:	e8 ee f2 ff ff       	call   80103408 <myproc>
8010411a:	8b 50 18             	mov    0x18(%eax),%edx
8010411d:	8b 45 08             	mov    0x8(%ebp),%eax
80104120:	c1 e0 02             	shl    $0x2,%eax
80104123:	03 42 44             	add    0x44(%edx),%eax
80104126:	83 ec 08             	sub    $0x8,%esp
80104129:	ff 75 0c             	pushl  0xc(%ebp)
8010412c:	83 c0 04             	add    $0x4,%eax
8010412f:	50                   	push   %eax
80104130:	e8 5e ff ff ff       	call   80104093 <fetchint>
}
80104135:	c9                   	leave  
80104136:	c3                   	ret    

80104137 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104137:	55                   	push   %ebp
80104138:	89 e5                	mov    %esp,%ebp
8010413a:	56                   	push   %esi
8010413b:	53                   	push   %ebx
8010413c:	83 ec 10             	sub    $0x10,%esp
8010413f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104142:	e8 c1 f2 ff ff       	call   80103408 <myproc>
80104147:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104149:	83 ec 08             	sub    $0x8,%esp
8010414c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010414f:	50                   	push   %eax
80104150:	ff 75 08             	pushl  0x8(%ebp)
80104153:	e8 b7 ff ff ff       	call   8010410f <argint>
80104158:	83 c4 10             	add    $0x10,%esp
8010415b:	85 c0                	test   %eax,%eax
8010415d:	78 24                	js     80104183 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010415f:	85 db                	test   %ebx,%ebx
80104161:	78 27                	js     8010418a <argptr+0x53>
80104163:	8b 16                	mov    (%esi),%edx
80104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104168:	39 c2                	cmp    %eax,%edx
8010416a:	76 25                	jbe    80104191 <argptr+0x5a>
8010416c:	01 c3                	add    %eax,%ebx
8010416e:	39 da                	cmp    %ebx,%edx
80104170:	72 26                	jb     80104198 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80104172:	8b 55 0c             	mov    0xc(%ebp),%edx
80104175:	89 02                	mov    %eax,(%edx)
  return 0;
80104177:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010417c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010417f:	5b                   	pop    %ebx
80104180:	5e                   	pop    %esi
80104181:	5d                   	pop    %ebp
80104182:	c3                   	ret    
    return -1;
80104183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104188:	eb f2                	jmp    8010417c <argptr+0x45>
    return -1;
8010418a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010418f:	eb eb                	jmp    8010417c <argptr+0x45>
80104191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104196:	eb e4                	jmp    8010417c <argptr+0x45>
80104198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010419d:	eb dd                	jmp    8010417c <argptr+0x45>

8010419f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010419f:	55                   	push   %ebp
801041a0:	89 e5                	mov    %esp,%ebp
801041a2:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801041a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041a8:	50                   	push   %eax
801041a9:	ff 75 08             	pushl  0x8(%ebp)
801041ac:	e8 5e ff ff ff       	call   8010410f <argint>
801041b1:	83 c4 10             	add    $0x10,%esp
801041b4:	85 c0                	test   %eax,%eax
801041b6:	78 13                	js     801041cb <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801041b8:	83 ec 08             	sub    $0x8,%esp
801041bb:	ff 75 0c             	pushl  0xc(%ebp)
801041be:	ff 75 f4             	pushl  -0xc(%ebp)
801041c1:	e8 09 ff ff ff       	call   801040cf <fetchstr>
801041c6:	83 c4 10             	add    $0x10,%esp
}
801041c9:	c9                   	leave  
801041ca:	c3                   	ret    
    return -1;
801041cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041d0:	eb f7                	jmp    801041c9 <argstr+0x2a>

801041d2 <syscall>:
[SYS_dump_physmem]    sys_dump_physmem,
};

void
syscall(void)
{
801041d2:	55                   	push   %ebp
801041d3:	89 e5                	mov    %esp,%ebp
801041d5:	53                   	push   %ebx
801041d6:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801041d9:	e8 2a f2 ff ff       	call   80103408 <myproc>
801041de:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801041e0:	8b 40 18             	mov    0x18(%eax),%eax
801041e3:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801041e6:	8d 50 ff             	lea    -0x1(%eax),%edx
801041e9:	83 fa 15             	cmp    $0x15,%edx
801041ec:	77 18                	ja     80104206 <syscall+0x34>
801041ee:	8b 14 85 80 6e 10 80 	mov    -0x7fef9180(,%eax,4),%edx
801041f5:	85 d2                	test   %edx,%edx
801041f7:	74 0d                	je     80104206 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
801041f9:	ff d2                	call   *%edx
801041fb:	8b 53 18             	mov    0x18(%ebx),%edx
801041fe:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104204:	c9                   	leave  
80104205:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104206:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104209:	50                   	push   %eax
8010420a:	52                   	push   %edx
8010420b:	ff 73 10             	pushl  0x10(%ebx)
8010420e:	68 51 6e 10 80       	push   $0x80106e51
80104213:	e8 f3 c3 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104218:	8b 43 18             	mov    0x18(%ebx),%eax
8010421b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104222:	83 c4 10             	add    $0x10,%esp
}
80104225:	eb da                	jmp    80104201 <syscall+0x2f>

80104227 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104227:	55                   	push   %ebp
80104228:	89 e5                	mov    %esp,%ebp
8010422a:	56                   	push   %esi
8010422b:	53                   	push   %ebx
8010422c:	83 ec 18             	sub    $0x18,%esp
8010422f:	89 d6                	mov    %edx,%esi
80104231:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104233:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104236:	52                   	push   %edx
80104237:	50                   	push   %eax
80104238:	e8 d2 fe ff ff       	call   8010410f <argint>
8010423d:	83 c4 10             	add    $0x10,%esp
80104240:	85 c0                	test   %eax,%eax
80104242:	78 2e                	js     80104272 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104244:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104248:	77 2f                	ja     80104279 <argfd+0x52>
8010424a:	e8 b9 f1 ff ff       	call   80103408 <myproc>
8010424f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104252:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104256:	85 c0                	test   %eax,%eax
80104258:	74 26                	je     80104280 <argfd+0x59>
    return -1;
  if(pfd)
8010425a:	85 f6                	test   %esi,%esi
8010425c:	74 02                	je     80104260 <argfd+0x39>
    *pfd = fd;
8010425e:	89 16                	mov    %edx,(%esi)
  if(pf)
80104260:	85 db                	test   %ebx,%ebx
80104262:	74 23                	je     80104287 <argfd+0x60>
    *pf = f;
80104264:	89 03                	mov    %eax,(%ebx)
  return 0;
80104266:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010426b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010426e:	5b                   	pop    %ebx
8010426f:	5e                   	pop    %esi
80104270:	5d                   	pop    %ebp
80104271:	c3                   	ret    
    return -1;
80104272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104277:	eb f2                	jmp    8010426b <argfd+0x44>
    return -1;
80104279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010427e:	eb eb                	jmp    8010426b <argfd+0x44>
80104280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104285:	eb e4                	jmp    8010426b <argfd+0x44>
  return 0;
80104287:	b8 00 00 00 00       	mov    $0x0,%eax
8010428c:	eb dd                	jmp    8010426b <argfd+0x44>

8010428e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010428e:	55                   	push   %ebp
8010428f:	89 e5                	mov    %esp,%ebp
80104291:	53                   	push   %ebx
80104292:	83 ec 04             	sub    $0x4,%esp
80104295:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104297:	e8 6c f1 ff ff       	call   80103408 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
8010429c:	ba 00 00 00 00       	mov    $0x0,%edx
801042a1:	83 fa 0f             	cmp    $0xf,%edx
801042a4:	7f 18                	jg     801042be <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801042a6:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801042ab:	74 05                	je     801042b2 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801042ad:	83 c2 01             	add    $0x1,%edx
801042b0:	eb ef                	jmp    801042a1 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801042b2:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801042b6:	89 d0                	mov    %edx,%eax
801042b8:	83 c4 04             	add    $0x4,%esp
801042bb:	5b                   	pop    %ebx
801042bc:	5d                   	pop    %ebp
801042bd:	c3                   	ret    
  return -1;
801042be:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801042c3:	eb f1                	jmp    801042b6 <fdalloc+0x28>

801042c5 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801042c5:	55                   	push   %ebp
801042c6:	89 e5                	mov    %esp,%ebp
801042c8:	56                   	push   %esi
801042c9:	53                   	push   %ebx
801042ca:	83 ec 10             	sub    $0x10,%esp
801042cd:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042cf:	b8 20 00 00 00       	mov    $0x20,%eax
801042d4:	89 c6                	mov    %eax,%esi
801042d6:	39 43 58             	cmp    %eax,0x58(%ebx)
801042d9:	76 2e                	jbe    80104309 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801042db:	6a 10                	push   $0x10
801042dd:	50                   	push   %eax
801042de:	8d 45 e8             	lea    -0x18(%ebp),%eax
801042e1:	50                   	push   %eax
801042e2:	53                   	push   %ebx
801042e3:	e8 8b d4 ff ff       	call   80101773 <readi>
801042e8:	83 c4 10             	add    $0x10,%esp
801042eb:	83 f8 10             	cmp    $0x10,%eax
801042ee:	75 0c                	jne    801042fc <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801042f0:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801042f5:	75 1e                	jne    80104315 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042f7:	8d 46 10             	lea    0x10(%esi),%eax
801042fa:	eb d8                	jmp    801042d4 <isdirempty+0xf>
      panic("isdirempty: readi");
801042fc:	83 ec 0c             	sub    $0xc,%esp
801042ff:	68 dc 6e 10 80       	push   $0x80106edc
80104304:	e8 3f c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104309:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010430e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104311:	5b                   	pop    %ebx
80104312:	5e                   	pop    %esi
80104313:	5d                   	pop    %ebp
80104314:	c3                   	ret    
      return 0;
80104315:	b8 00 00 00 00       	mov    $0x0,%eax
8010431a:	eb f2                	jmp    8010430e <isdirempty+0x49>

8010431c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
8010431c:	55                   	push   %ebp
8010431d:	89 e5                	mov    %esp,%ebp
8010431f:	57                   	push   %edi
80104320:	56                   	push   %esi
80104321:	53                   	push   %ebx
80104322:	83 ec 44             	sub    $0x44,%esp
80104325:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104328:	89 4d c0             	mov    %ecx,-0x40(%ebp)
8010432b:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010432e:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104331:	52                   	push   %edx
80104332:	50                   	push   %eax
80104333:	e8 c1 d8 ff ff       	call   80101bf9 <nameiparent>
80104338:	89 c6                	mov    %eax,%esi
8010433a:	83 c4 10             	add    $0x10,%esp
8010433d:	85 c0                	test   %eax,%eax
8010433f:	0f 84 3a 01 00 00    	je     8010447f <create+0x163>
    return 0;
  ilock(dp);
80104345:	83 ec 0c             	sub    $0xc,%esp
80104348:	50                   	push   %eax
80104349:	e8 33 d2 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010434e:	83 c4 0c             	add    $0xc,%esp
80104351:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104354:	50                   	push   %eax
80104355:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104358:	50                   	push   %eax
80104359:	56                   	push   %esi
8010435a:	e8 51 d6 ff ff       	call   801019b0 <dirlookup>
8010435f:	89 c3                	mov    %eax,%ebx
80104361:	83 c4 10             	add    $0x10,%esp
80104364:	85 c0                	test   %eax,%eax
80104366:	74 3f                	je     801043a7 <create+0x8b>
    iunlockput(dp);
80104368:	83 ec 0c             	sub    $0xc,%esp
8010436b:	56                   	push   %esi
8010436c:	e8 b7 d3 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
80104371:	89 1c 24             	mov    %ebx,(%esp)
80104374:	e8 08 d2 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104379:	83 c4 10             	add    $0x10,%esp
8010437c:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104381:	75 11                	jne    80104394 <create+0x78>
80104383:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104388:	75 0a                	jne    80104394 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010438a:	89 d8                	mov    %ebx,%eax
8010438c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010438f:	5b                   	pop    %ebx
80104390:	5e                   	pop    %esi
80104391:	5f                   	pop    %edi
80104392:	5d                   	pop    %ebp
80104393:	c3                   	ret    
    iunlockput(ip);
80104394:	83 ec 0c             	sub    $0xc,%esp
80104397:	53                   	push   %ebx
80104398:	e8 8b d3 ff ff       	call   80101728 <iunlockput>
    return 0;
8010439d:	83 c4 10             	add    $0x10,%esp
801043a0:	bb 00 00 00 00       	mov    $0x0,%ebx
801043a5:	eb e3                	jmp    8010438a <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801043a7:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801043ab:	83 ec 08             	sub    $0x8,%esp
801043ae:	50                   	push   %eax
801043af:	ff 36                	pushl  (%esi)
801043b1:	e8 c8 cf ff ff       	call   8010137e <ialloc>
801043b6:	89 c3                	mov    %eax,%ebx
801043b8:	83 c4 10             	add    $0x10,%esp
801043bb:	85 c0                	test   %eax,%eax
801043bd:	74 55                	je     80104414 <create+0xf8>
  ilock(ip);
801043bf:	83 ec 0c             	sub    $0xc,%esp
801043c2:	50                   	push   %eax
801043c3:	e8 b9 d1 ff ff       	call   80101581 <ilock>
  ip->major = major;
801043c8:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801043cc:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801043d0:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801043d4:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801043da:	89 1c 24             	mov    %ebx,(%esp)
801043dd:	e8 3e d0 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801043e2:	83 c4 10             	add    $0x10,%esp
801043e5:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801043ea:	74 35                	je     80104421 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
801043ec:	83 ec 04             	sub    $0x4,%esp
801043ef:	ff 73 04             	pushl  0x4(%ebx)
801043f2:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801043f5:	50                   	push   %eax
801043f6:	56                   	push   %esi
801043f7:	e8 34 d7 ff ff       	call   80101b30 <dirlink>
801043fc:	83 c4 10             	add    $0x10,%esp
801043ff:	85 c0                	test   %eax,%eax
80104401:	78 6f                	js     80104472 <create+0x156>
  iunlockput(dp);
80104403:	83 ec 0c             	sub    $0xc,%esp
80104406:	56                   	push   %esi
80104407:	e8 1c d3 ff ff       	call   80101728 <iunlockput>
  return ip;
8010440c:	83 c4 10             	add    $0x10,%esp
8010440f:	e9 76 ff ff ff       	jmp    8010438a <create+0x6e>
    panic("create: ialloc");
80104414:	83 ec 0c             	sub    $0xc,%esp
80104417:	68 ee 6e 10 80       	push   $0x80106eee
8010441c:	e8 27 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104421:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104425:	83 c0 01             	add    $0x1,%eax
80104428:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010442c:	83 ec 0c             	sub    $0xc,%esp
8010442f:	56                   	push   %esi
80104430:	e8 eb cf ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104435:	83 c4 0c             	add    $0xc,%esp
80104438:	ff 73 04             	pushl  0x4(%ebx)
8010443b:	68 fe 6e 10 80       	push   $0x80106efe
80104440:	53                   	push   %ebx
80104441:	e8 ea d6 ff ff       	call   80101b30 <dirlink>
80104446:	83 c4 10             	add    $0x10,%esp
80104449:	85 c0                	test   %eax,%eax
8010444b:	78 18                	js     80104465 <create+0x149>
8010444d:	83 ec 04             	sub    $0x4,%esp
80104450:	ff 76 04             	pushl  0x4(%esi)
80104453:	68 fd 6e 10 80       	push   $0x80106efd
80104458:	53                   	push   %ebx
80104459:	e8 d2 d6 ff ff       	call   80101b30 <dirlink>
8010445e:	83 c4 10             	add    $0x10,%esp
80104461:	85 c0                	test   %eax,%eax
80104463:	79 87                	jns    801043ec <create+0xd0>
      panic("create dots");
80104465:	83 ec 0c             	sub    $0xc,%esp
80104468:	68 00 6f 10 80       	push   $0x80106f00
8010446d:	e8 d6 be ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104472:	83 ec 0c             	sub    $0xc,%esp
80104475:	68 0c 6f 10 80       	push   $0x80106f0c
8010447a:	e8 c9 be ff ff       	call   80100348 <panic>
    return 0;
8010447f:	89 c3                	mov    %eax,%ebx
80104481:	e9 04 ff ff ff       	jmp    8010438a <create+0x6e>

80104486 <sys_dup>:
{
80104486:	55                   	push   %ebp
80104487:	89 e5                	mov    %esp,%ebp
80104489:	53                   	push   %ebx
8010448a:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010448d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104490:	ba 00 00 00 00       	mov    $0x0,%edx
80104495:	b8 00 00 00 00       	mov    $0x0,%eax
8010449a:	e8 88 fd ff ff       	call   80104227 <argfd>
8010449f:	85 c0                	test   %eax,%eax
801044a1:	78 23                	js     801044c6 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801044a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a6:	e8 e3 fd ff ff       	call   8010428e <fdalloc>
801044ab:	89 c3                	mov    %eax,%ebx
801044ad:	85 c0                	test   %eax,%eax
801044af:	78 1c                	js     801044cd <sys_dup+0x47>
  filedup(f);
801044b1:	83 ec 0c             	sub    $0xc,%esp
801044b4:	ff 75 f4             	pushl  -0xc(%ebp)
801044b7:	e8 d2 c7 ff ff       	call   80100c8e <filedup>
  return fd;
801044bc:	83 c4 10             	add    $0x10,%esp
}
801044bf:	89 d8                	mov    %ebx,%eax
801044c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044c4:	c9                   	leave  
801044c5:	c3                   	ret    
    return -1;
801044c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044cb:	eb f2                	jmp    801044bf <sys_dup+0x39>
    return -1;
801044cd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044d2:	eb eb                	jmp    801044bf <sys_dup+0x39>

801044d4 <sys_read>:
{
801044d4:	55                   	push   %ebp
801044d5:	89 e5                	mov    %esp,%ebp
801044d7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044da:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044dd:	ba 00 00 00 00       	mov    $0x0,%edx
801044e2:	b8 00 00 00 00       	mov    $0x0,%eax
801044e7:	e8 3b fd ff ff       	call   80104227 <argfd>
801044ec:	85 c0                	test   %eax,%eax
801044ee:	78 43                	js     80104533 <sys_read+0x5f>
801044f0:	83 ec 08             	sub    $0x8,%esp
801044f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044f6:	50                   	push   %eax
801044f7:	6a 02                	push   $0x2
801044f9:	e8 11 fc ff ff       	call   8010410f <argint>
801044fe:	83 c4 10             	add    $0x10,%esp
80104501:	85 c0                	test   %eax,%eax
80104503:	78 35                	js     8010453a <sys_read+0x66>
80104505:	83 ec 04             	sub    $0x4,%esp
80104508:	ff 75 f0             	pushl  -0x10(%ebp)
8010450b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010450e:	50                   	push   %eax
8010450f:	6a 01                	push   $0x1
80104511:	e8 21 fc ff ff       	call   80104137 <argptr>
80104516:	83 c4 10             	add    $0x10,%esp
80104519:	85 c0                	test   %eax,%eax
8010451b:	78 24                	js     80104541 <sys_read+0x6d>
  return fileread(f, p, n);
8010451d:	83 ec 04             	sub    $0x4,%esp
80104520:	ff 75 f0             	pushl  -0x10(%ebp)
80104523:	ff 75 ec             	pushl  -0x14(%ebp)
80104526:	ff 75 f4             	pushl  -0xc(%ebp)
80104529:	e8 a9 c8 ff ff       	call   80100dd7 <fileread>
8010452e:	83 c4 10             	add    $0x10,%esp
}
80104531:	c9                   	leave  
80104532:	c3                   	ret    
    return -1;
80104533:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104538:	eb f7                	jmp    80104531 <sys_read+0x5d>
8010453a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010453f:	eb f0                	jmp    80104531 <sys_read+0x5d>
80104541:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104546:	eb e9                	jmp    80104531 <sys_read+0x5d>

80104548 <sys_write>:
{
80104548:	55                   	push   %ebp
80104549:	89 e5                	mov    %esp,%ebp
8010454b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010454e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104551:	ba 00 00 00 00       	mov    $0x0,%edx
80104556:	b8 00 00 00 00       	mov    $0x0,%eax
8010455b:	e8 c7 fc ff ff       	call   80104227 <argfd>
80104560:	85 c0                	test   %eax,%eax
80104562:	78 43                	js     801045a7 <sys_write+0x5f>
80104564:	83 ec 08             	sub    $0x8,%esp
80104567:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010456a:	50                   	push   %eax
8010456b:	6a 02                	push   $0x2
8010456d:	e8 9d fb ff ff       	call   8010410f <argint>
80104572:	83 c4 10             	add    $0x10,%esp
80104575:	85 c0                	test   %eax,%eax
80104577:	78 35                	js     801045ae <sys_write+0x66>
80104579:	83 ec 04             	sub    $0x4,%esp
8010457c:	ff 75 f0             	pushl  -0x10(%ebp)
8010457f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104582:	50                   	push   %eax
80104583:	6a 01                	push   $0x1
80104585:	e8 ad fb ff ff       	call   80104137 <argptr>
8010458a:	83 c4 10             	add    $0x10,%esp
8010458d:	85 c0                	test   %eax,%eax
8010458f:	78 24                	js     801045b5 <sys_write+0x6d>
  return filewrite(f, p, n);
80104591:	83 ec 04             	sub    $0x4,%esp
80104594:	ff 75 f0             	pushl  -0x10(%ebp)
80104597:	ff 75 ec             	pushl  -0x14(%ebp)
8010459a:	ff 75 f4             	pushl  -0xc(%ebp)
8010459d:	e8 ba c8 ff ff       	call   80100e5c <filewrite>
801045a2:	83 c4 10             	add    $0x10,%esp
}
801045a5:	c9                   	leave  
801045a6:	c3                   	ret    
    return -1;
801045a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ac:	eb f7                	jmp    801045a5 <sys_write+0x5d>
801045ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b3:	eb f0                	jmp    801045a5 <sys_write+0x5d>
801045b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ba:	eb e9                	jmp    801045a5 <sys_write+0x5d>

801045bc <sys_close>:
{
801045bc:	55                   	push   %ebp
801045bd:	89 e5                	mov    %esp,%ebp
801045bf:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801045c2:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801045c5:	8d 55 f4             	lea    -0xc(%ebp),%edx
801045c8:	b8 00 00 00 00       	mov    $0x0,%eax
801045cd:	e8 55 fc ff ff       	call   80104227 <argfd>
801045d2:	85 c0                	test   %eax,%eax
801045d4:	78 25                	js     801045fb <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801045d6:	e8 2d ee ff ff       	call   80103408 <myproc>
801045db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045de:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801045e5:	00 
  fileclose(f);
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	ff 75 f0             	pushl  -0x10(%ebp)
801045ec:	e8 e2 c6 ff ff       	call   80100cd3 <fileclose>
  return 0;
801045f1:	83 c4 10             	add    $0x10,%esp
801045f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045f9:	c9                   	leave  
801045fa:	c3                   	ret    
    return -1;
801045fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104600:	eb f7                	jmp    801045f9 <sys_close+0x3d>

80104602 <sys_fstat>:
{
80104602:	55                   	push   %ebp
80104603:	89 e5                	mov    %esp,%ebp
80104605:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104608:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010460b:	ba 00 00 00 00       	mov    $0x0,%edx
80104610:	b8 00 00 00 00       	mov    $0x0,%eax
80104615:	e8 0d fc ff ff       	call   80104227 <argfd>
8010461a:	85 c0                	test   %eax,%eax
8010461c:	78 2a                	js     80104648 <sys_fstat+0x46>
8010461e:	83 ec 04             	sub    $0x4,%esp
80104621:	6a 14                	push   $0x14
80104623:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104626:	50                   	push   %eax
80104627:	6a 01                	push   $0x1
80104629:	e8 09 fb ff ff       	call   80104137 <argptr>
8010462e:	83 c4 10             	add    $0x10,%esp
80104631:	85 c0                	test   %eax,%eax
80104633:	78 1a                	js     8010464f <sys_fstat+0x4d>
  return filestat(f, st);
80104635:	83 ec 08             	sub    $0x8,%esp
80104638:	ff 75 f0             	pushl  -0x10(%ebp)
8010463b:	ff 75 f4             	pushl  -0xc(%ebp)
8010463e:	e8 4d c7 ff ff       	call   80100d90 <filestat>
80104643:	83 c4 10             	add    $0x10,%esp
}
80104646:	c9                   	leave  
80104647:	c3                   	ret    
    return -1;
80104648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464d:	eb f7                	jmp    80104646 <sys_fstat+0x44>
8010464f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104654:	eb f0                	jmp    80104646 <sys_fstat+0x44>

80104656 <sys_link>:
{
80104656:	55                   	push   %ebp
80104657:	89 e5                	mov    %esp,%ebp
80104659:	56                   	push   %esi
8010465a:	53                   	push   %ebx
8010465b:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010465e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104661:	50                   	push   %eax
80104662:	6a 00                	push   $0x0
80104664:	e8 36 fb ff ff       	call   8010419f <argstr>
80104669:	83 c4 10             	add    $0x10,%esp
8010466c:	85 c0                	test   %eax,%eax
8010466e:	0f 88 32 01 00 00    	js     801047a6 <sys_link+0x150>
80104674:	83 ec 08             	sub    $0x8,%esp
80104677:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010467a:	50                   	push   %eax
8010467b:	6a 01                	push   $0x1
8010467d:	e8 1d fb ff ff       	call   8010419f <argstr>
80104682:	83 c4 10             	add    $0x10,%esp
80104685:	85 c0                	test   %eax,%eax
80104687:	0f 88 20 01 00 00    	js     801047ad <sys_link+0x157>
  begin_op();
8010468d:	e8 fe e2 ff ff       	call   80102990 <begin_op>
  if((ip = namei(old)) == 0){
80104692:	83 ec 0c             	sub    $0xc,%esp
80104695:	ff 75 e0             	pushl  -0x20(%ebp)
80104698:	e8 44 d5 ff ff       	call   80101be1 <namei>
8010469d:	89 c3                	mov    %eax,%ebx
8010469f:	83 c4 10             	add    $0x10,%esp
801046a2:	85 c0                	test   %eax,%eax
801046a4:	0f 84 99 00 00 00    	je     80104743 <sys_link+0xed>
  ilock(ip);
801046aa:	83 ec 0c             	sub    $0xc,%esp
801046ad:	50                   	push   %eax
801046ae:	e8 ce ce ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801046b3:	83 c4 10             	add    $0x10,%esp
801046b6:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046bb:	0f 84 8e 00 00 00    	je     8010474f <sys_link+0xf9>
  ip->nlink++;
801046c1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046c5:	83 c0 01             	add    $0x1,%eax
801046c8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046cc:	83 ec 0c             	sub    $0xc,%esp
801046cf:	53                   	push   %ebx
801046d0:	e8 4b cd ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801046d5:	89 1c 24             	mov    %ebx,(%esp)
801046d8:	e8 66 cf ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801046dd:	83 c4 08             	add    $0x8,%esp
801046e0:	8d 45 ea             	lea    -0x16(%ebp),%eax
801046e3:	50                   	push   %eax
801046e4:	ff 75 e4             	pushl  -0x1c(%ebp)
801046e7:	e8 0d d5 ff ff       	call   80101bf9 <nameiparent>
801046ec:	89 c6                	mov    %eax,%esi
801046ee:	83 c4 10             	add    $0x10,%esp
801046f1:	85 c0                	test   %eax,%eax
801046f3:	74 7e                	je     80104773 <sys_link+0x11d>
  ilock(dp);
801046f5:	83 ec 0c             	sub    $0xc,%esp
801046f8:	50                   	push   %eax
801046f9:	e8 83 ce ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801046fe:	83 c4 10             	add    $0x10,%esp
80104701:	8b 03                	mov    (%ebx),%eax
80104703:	39 06                	cmp    %eax,(%esi)
80104705:	75 60                	jne    80104767 <sys_link+0x111>
80104707:	83 ec 04             	sub    $0x4,%esp
8010470a:	ff 73 04             	pushl  0x4(%ebx)
8010470d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104710:	50                   	push   %eax
80104711:	56                   	push   %esi
80104712:	e8 19 d4 ff ff       	call   80101b30 <dirlink>
80104717:	83 c4 10             	add    $0x10,%esp
8010471a:	85 c0                	test   %eax,%eax
8010471c:	78 49                	js     80104767 <sys_link+0x111>
  iunlockput(dp);
8010471e:	83 ec 0c             	sub    $0xc,%esp
80104721:	56                   	push   %esi
80104722:	e8 01 d0 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104727:	89 1c 24             	mov    %ebx,(%esp)
8010472a:	e8 59 cf ff ff       	call   80101688 <iput>
  end_op();
8010472f:	e8 d6 e2 ff ff       	call   80102a0a <end_op>
  return 0;
80104734:	83 c4 10             	add    $0x10,%esp
80104737:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010473c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010473f:	5b                   	pop    %ebx
80104740:	5e                   	pop    %esi
80104741:	5d                   	pop    %ebp
80104742:	c3                   	ret    
    end_op();
80104743:	e8 c2 e2 ff ff       	call   80102a0a <end_op>
    return -1;
80104748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474d:	eb ed                	jmp    8010473c <sys_link+0xe6>
    iunlockput(ip);
8010474f:	83 ec 0c             	sub    $0xc,%esp
80104752:	53                   	push   %ebx
80104753:	e8 d0 cf ff ff       	call   80101728 <iunlockput>
    end_op();
80104758:	e8 ad e2 ff ff       	call   80102a0a <end_op>
    return -1;
8010475d:	83 c4 10             	add    $0x10,%esp
80104760:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104765:	eb d5                	jmp    8010473c <sys_link+0xe6>
    iunlockput(dp);
80104767:	83 ec 0c             	sub    $0xc,%esp
8010476a:	56                   	push   %esi
8010476b:	e8 b8 cf ff ff       	call   80101728 <iunlockput>
    goto bad;
80104770:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104773:	83 ec 0c             	sub    $0xc,%esp
80104776:	53                   	push   %ebx
80104777:	e8 05 ce ff ff       	call   80101581 <ilock>
  ip->nlink--;
8010477c:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104780:	83 e8 01             	sub    $0x1,%eax
80104783:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104787:	89 1c 24             	mov    %ebx,(%esp)
8010478a:	e8 91 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010478f:	89 1c 24             	mov    %ebx,(%esp)
80104792:	e8 91 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104797:	e8 6e e2 ff ff       	call   80102a0a <end_op>
  return -1;
8010479c:	83 c4 10             	add    $0x10,%esp
8010479f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a4:	eb 96                	jmp    8010473c <sys_link+0xe6>
    return -1;
801047a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ab:	eb 8f                	jmp    8010473c <sys_link+0xe6>
801047ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b2:	eb 88                	jmp    8010473c <sys_link+0xe6>

801047b4 <sys_unlink>:
{
801047b4:	55                   	push   %ebp
801047b5:	89 e5                	mov    %esp,%ebp
801047b7:	57                   	push   %edi
801047b8:	56                   	push   %esi
801047b9:	53                   	push   %ebx
801047ba:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801047bd:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047c0:	50                   	push   %eax
801047c1:	6a 00                	push   $0x0
801047c3:	e8 d7 f9 ff ff       	call   8010419f <argstr>
801047c8:	83 c4 10             	add    $0x10,%esp
801047cb:	85 c0                	test   %eax,%eax
801047cd:	0f 88 83 01 00 00    	js     80104956 <sys_unlink+0x1a2>
  begin_op();
801047d3:	e8 b8 e1 ff ff       	call   80102990 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801047d8:	83 ec 08             	sub    $0x8,%esp
801047db:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047de:	50                   	push   %eax
801047df:	ff 75 c4             	pushl  -0x3c(%ebp)
801047e2:	e8 12 d4 ff ff       	call   80101bf9 <nameiparent>
801047e7:	89 c6                	mov    %eax,%esi
801047e9:	83 c4 10             	add    $0x10,%esp
801047ec:	85 c0                	test   %eax,%eax
801047ee:	0f 84 ed 00 00 00    	je     801048e1 <sys_unlink+0x12d>
  ilock(dp);
801047f4:	83 ec 0c             	sub    $0xc,%esp
801047f7:	50                   	push   %eax
801047f8:	e8 84 cd ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801047fd:	83 c4 08             	add    $0x8,%esp
80104800:	68 fe 6e 10 80       	push   $0x80106efe
80104805:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104808:	50                   	push   %eax
80104809:	e8 8d d1 ff ff       	call   8010199b <namecmp>
8010480e:	83 c4 10             	add    $0x10,%esp
80104811:	85 c0                	test   %eax,%eax
80104813:	0f 84 fc 00 00 00    	je     80104915 <sys_unlink+0x161>
80104819:	83 ec 08             	sub    $0x8,%esp
8010481c:	68 fd 6e 10 80       	push   $0x80106efd
80104821:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104824:	50                   	push   %eax
80104825:	e8 71 d1 ff ff       	call   8010199b <namecmp>
8010482a:	83 c4 10             	add    $0x10,%esp
8010482d:	85 c0                	test   %eax,%eax
8010482f:	0f 84 e0 00 00 00    	je     80104915 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104835:	83 ec 04             	sub    $0x4,%esp
80104838:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010483b:	50                   	push   %eax
8010483c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010483f:	50                   	push   %eax
80104840:	56                   	push   %esi
80104841:	e8 6a d1 ff ff       	call   801019b0 <dirlookup>
80104846:	89 c3                	mov    %eax,%ebx
80104848:	83 c4 10             	add    $0x10,%esp
8010484b:	85 c0                	test   %eax,%eax
8010484d:	0f 84 c2 00 00 00    	je     80104915 <sys_unlink+0x161>
  ilock(ip);
80104853:	83 ec 0c             	sub    $0xc,%esp
80104856:	50                   	push   %eax
80104857:	e8 25 cd ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
8010485c:	83 c4 10             	add    $0x10,%esp
8010485f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104864:	0f 8e 83 00 00 00    	jle    801048ed <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010486a:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010486f:	0f 84 85 00 00 00    	je     801048fa <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104875:	83 ec 04             	sub    $0x4,%esp
80104878:	6a 10                	push   $0x10
8010487a:	6a 00                	push   $0x0
8010487c:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010487f:	57                   	push   %edi
80104880:	e8 3f f6 ff ff       	call   80103ec4 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104885:	6a 10                	push   $0x10
80104887:	ff 75 c0             	pushl  -0x40(%ebp)
8010488a:	57                   	push   %edi
8010488b:	56                   	push   %esi
8010488c:	e8 df cf ff ff       	call   80101870 <writei>
80104891:	83 c4 20             	add    $0x20,%esp
80104894:	83 f8 10             	cmp    $0x10,%eax
80104897:	0f 85 90 00 00 00    	jne    8010492d <sys_unlink+0x179>
  if(ip->type == T_DIR){
8010489d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801048a2:	0f 84 92 00 00 00    	je     8010493a <sys_unlink+0x186>
  iunlockput(dp);
801048a8:	83 ec 0c             	sub    $0xc,%esp
801048ab:	56                   	push   %esi
801048ac:	e8 77 ce ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801048b1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801048b5:	83 e8 01             	sub    $0x1,%eax
801048b8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801048bc:	89 1c 24             	mov    %ebx,(%esp)
801048bf:	e8 5c cb ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801048c4:	89 1c 24             	mov    %ebx,(%esp)
801048c7:	e8 5c ce ff ff       	call   80101728 <iunlockput>
  end_op();
801048cc:	e8 39 e1 ff ff       	call   80102a0a <end_op>
  return 0;
801048d1:	83 c4 10             	add    $0x10,%esp
801048d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048dc:	5b                   	pop    %ebx
801048dd:	5e                   	pop    %esi
801048de:	5f                   	pop    %edi
801048df:	5d                   	pop    %ebp
801048e0:	c3                   	ret    
    end_op();
801048e1:	e8 24 e1 ff ff       	call   80102a0a <end_op>
    return -1;
801048e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048eb:	eb ec                	jmp    801048d9 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801048ed:	83 ec 0c             	sub    $0xc,%esp
801048f0:	68 1c 6f 10 80       	push   $0x80106f1c
801048f5:	e8 4e ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801048fa:	89 d8                	mov    %ebx,%eax
801048fc:	e8 c4 f9 ff ff       	call   801042c5 <isdirempty>
80104901:	85 c0                	test   %eax,%eax
80104903:	0f 85 6c ff ff ff    	jne    80104875 <sys_unlink+0xc1>
    iunlockput(ip);
80104909:	83 ec 0c             	sub    $0xc,%esp
8010490c:	53                   	push   %ebx
8010490d:	e8 16 ce ff ff       	call   80101728 <iunlockput>
    goto bad;
80104912:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104915:	83 ec 0c             	sub    $0xc,%esp
80104918:	56                   	push   %esi
80104919:	e8 0a ce ff ff       	call   80101728 <iunlockput>
  end_op();
8010491e:	e8 e7 e0 ff ff       	call   80102a0a <end_op>
  return -1;
80104923:	83 c4 10             	add    $0x10,%esp
80104926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010492b:	eb ac                	jmp    801048d9 <sys_unlink+0x125>
    panic("unlink: writei");
8010492d:	83 ec 0c             	sub    $0xc,%esp
80104930:	68 2e 6f 10 80       	push   $0x80106f2e
80104935:	e8 0e ba ff ff       	call   80100348 <panic>
    dp->nlink--;
8010493a:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010493e:	83 e8 01             	sub    $0x1,%eax
80104941:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104945:	83 ec 0c             	sub    $0xc,%esp
80104948:	56                   	push   %esi
80104949:	e8 d2 ca ff ff       	call   80101420 <iupdate>
8010494e:	83 c4 10             	add    $0x10,%esp
80104951:	e9 52 ff ff ff       	jmp    801048a8 <sys_unlink+0xf4>
    return -1;
80104956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010495b:	e9 79 ff ff ff       	jmp    801048d9 <sys_unlink+0x125>

80104960 <sys_open>:

int
sys_open(void)
{
80104960:	55                   	push   %ebp
80104961:	89 e5                	mov    %esp,%ebp
80104963:	57                   	push   %edi
80104964:	56                   	push   %esi
80104965:	53                   	push   %ebx
80104966:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104969:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010496c:	50                   	push   %eax
8010496d:	6a 00                	push   $0x0
8010496f:	e8 2b f8 ff ff       	call   8010419f <argstr>
80104974:	83 c4 10             	add    $0x10,%esp
80104977:	85 c0                	test   %eax,%eax
80104979:	0f 88 30 01 00 00    	js     80104aaf <sys_open+0x14f>
8010497f:	83 ec 08             	sub    $0x8,%esp
80104982:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104985:	50                   	push   %eax
80104986:	6a 01                	push   $0x1
80104988:	e8 82 f7 ff ff       	call   8010410f <argint>
8010498d:	83 c4 10             	add    $0x10,%esp
80104990:	85 c0                	test   %eax,%eax
80104992:	0f 88 21 01 00 00    	js     80104ab9 <sys_open+0x159>
    return -1;

  begin_op();
80104998:	e8 f3 df ff ff       	call   80102990 <begin_op>

  if(omode & O_CREATE){
8010499d:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801049a1:	0f 84 84 00 00 00    	je     80104a2b <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801049a7:	83 ec 0c             	sub    $0xc,%esp
801049aa:	6a 00                	push   $0x0
801049ac:	b9 00 00 00 00       	mov    $0x0,%ecx
801049b1:	ba 02 00 00 00       	mov    $0x2,%edx
801049b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801049b9:	e8 5e f9 ff ff       	call   8010431c <create>
801049be:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801049c0:	83 c4 10             	add    $0x10,%esp
801049c3:	85 c0                	test   %eax,%eax
801049c5:	74 58                	je     80104a1f <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801049c7:	e8 61 c2 ff ff       	call   80100c2d <filealloc>
801049cc:	89 c3                	mov    %eax,%ebx
801049ce:	85 c0                	test   %eax,%eax
801049d0:	0f 84 ae 00 00 00    	je     80104a84 <sys_open+0x124>
801049d6:	e8 b3 f8 ff ff       	call   8010428e <fdalloc>
801049db:	89 c7                	mov    %eax,%edi
801049dd:	85 c0                	test   %eax,%eax
801049df:	0f 88 9f 00 00 00    	js     80104a84 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049e5:	83 ec 0c             	sub    $0xc,%esp
801049e8:	56                   	push   %esi
801049e9:	e8 55 cc ff ff       	call   80101643 <iunlock>
  end_op();
801049ee:	e8 17 e0 ff ff       	call   80102a0a <end_op>

  f->type = FD_INODE;
801049f3:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801049f9:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801049fc:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104a03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a06:	83 c4 10             	add    $0x10,%esp
80104a09:	a8 01                	test   $0x1,%al
80104a0b:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104a0f:	a8 03                	test   $0x3,%al
80104a11:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104a15:	89 f8                	mov    %edi,%eax
80104a17:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a1a:	5b                   	pop    %ebx
80104a1b:	5e                   	pop    %esi
80104a1c:	5f                   	pop    %edi
80104a1d:	5d                   	pop    %ebp
80104a1e:	c3                   	ret    
      end_op();
80104a1f:	e8 e6 df ff ff       	call   80102a0a <end_op>
      return -1;
80104a24:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a29:	eb ea                	jmp    80104a15 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104a2b:	83 ec 0c             	sub    $0xc,%esp
80104a2e:	ff 75 e4             	pushl  -0x1c(%ebp)
80104a31:	e8 ab d1 ff ff       	call   80101be1 <namei>
80104a36:	89 c6                	mov    %eax,%esi
80104a38:	83 c4 10             	add    $0x10,%esp
80104a3b:	85 c0                	test   %eax,%eax
80104a3d:	74 39                	je     80104a78 <sys_open+0x118>
    ilock(ip);
80104a3f:	83 ec 0c             	sub    $0xc,%esp
80104a42:	50                   	push   %eax
80104a43:	e8 39 cb ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a48:	83 c4 10             	add    $0x10,%esp
80104a4b:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104a50:	0f 85 71 ff ff ff    	jne    801049c7 <sys_open+0x67>
80104a56:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a5a:	0f 84 67 ff ff ff    	je     801049c7 <sys_open+0x67>
      iunlockput(ip);
80104a60:	83 ec 0c             	sub    $0xc,%esp
80104a63:	56                   	push   %esi
80104a64:	e8 bf cc ff ff       	call   80101728 <iunlockput>
      end_op();
80104a69:	e8 9c df ff ff       	call   80102a0a <end_op>
      return -1;
80104a6e:	83 c4 10             	add    $0x10,%esp
80104a71:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a76:	eb 9d                	jmp    80104a15 <sys_open+0xb5>
      end_op();
80104a78:	e8 8d df ff ff       	call   80102a0a <end_op>
      return -1;
80104a7d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a82:	eb 91                	jmp    80104a15 <sys_open+0xb5>
    if(f)
80104a84:	85 db                	test   %ebx,%ebx
80104a86:	74 0c                	je     80104a94 <sys_open+0x134>
      fileclose(f);
80104a88:	83 ec 0c             	sub    $0xc,%esp
80104a8b:	53                   	push   %ebx
80104a8c:	e8 42 c2 ff ff       	call   80100cd3 <fileclose>
80104a91:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104a94:	83 ec 0c             	sub    $0xc,%esp
80104a97:	56                   	push   %esi
80104a98:	e8 8b cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104a9d:	e8 68 df ff ff       	call   80102a0a <end_op>
    return -1;
80104aa2:	83 c4 10             	add    $0x10,%esp
80104aa5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104aaa:	e9 66 ff ff ff       	jmp    80104a15 <sys_open+0xb5>
    return -1;
80104aaf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ab4:	e9 5c ff ff ff       	jmp    80104a15 <sys_open+0xb5>
80104ab9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104abe:	e9 52 ff ff ff       	jmp    80104a15 <sys_open+0xb5>

80104ac3 <sys_mkdir>:

int
sys_mkdir(void)
{
80104ac3:	55                   	push   %ebp
80104ac4:	89 e5                	mov    %esp,%ebp
80104ac6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104ac9:	e8 c2 de ff ff       	call   80102990 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104ace:	83 ec 08             	sub    $0x8,%esp
80104ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ad4:	50                   	push   %eax
80104ad5:	6a 00                	push   $0x0
80104ad7:	e8 c3 f6 ff ff       	call   8010419f <argstr>
80104adc:	83 c4 10             	add    $0x10,%esp
80104adf:	85 c0                	test   %eax,%eax
80104ae1:	78 36                	js     80104b19 <sys_mkdir+0x56>
80104ae3:	83 ec 0c             	sub    $0xc,%esp
80104ae6:	6a 00                	push   $0x0
80104ae8:	b9 00 00 00 00       	mov    $0x0,%ecx
80104aed:	ba 01 00 00 00       	mov    $0x1,%edx
80104af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af5:	e8 22 f8 ff ff       	call   8010431c <create>
80104afa:	83 c4 10             	add    $0x10,%esp
80104afd:	85 c0                	test   %eax,%eax
80104aff:	74 18                	je     80104b19 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b01:	83 ec 0c             	sub    $0xc,%esp
80104b04:	50                   	push   %eax
80104b05:	e8 1e cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104b0a:	e8 fb de ff ff       	call   80102a0a <end_op>
  return 0;
80104b0f:	83 c4 10             	add    $0x10,%esp
80104b12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b17:	c9                   	leave  
80104b18:	c3                   	ret    
    end_op();
80104b19:	e8 ec de ff ff       	call   80102a0a <end_op>
    return -1;
80104b1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b23:	eb f2                	jmp    80104b17 <sys_mkdir+0x54>

80104b25 <sys_mknod>:

int
sys_mknod(void)
{
80104b25:	55                   	push   %ebp
80104b26:	89 e5                	mov    %esp,%ebp
80104b28:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104b2b:	e8 60 de ff ff       	call   80102990 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104b30:	83 ec 08             	sub    $0x8,%esp
80104b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b36:	50                   	push   %eax
80104b37:	6a 00                	push   $0x0
80104b39:	e8 61 f6 ff ff       	call   8010419f <argstr>
80104b3e:	83 c4 10             	add    $0x10,%esp
80104b41:	85 c0                	test   %eax,%eax
80104b43:	78 62                	js     80104ba7 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104b45:	83 ec 08             	sub    $0x8,%esp
80104b48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b4b:	50                   	push   %eax
80104b4c:	6a 01                	push   $0x1
80104b4e:	e8 bc f5 ff ff       	call   8010410f <argint>
  if((argstr(0, &path)) < 0 ||
80104b53:	83 c4 10             	add    $0x10,%esp
80104b56:	85 c0                	test   %eax,%eax
80104b58:	78 4d                	js     80104ba7 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104b5a:	83 ec 08             	sub    $0x8,%esp
80104b5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b60:	50                   	push   %eax
80104b61:	6a 02                	push   $0x2
80104b63:	e8 a7 f5 ff ff       	call   8010410f <argint>
     argint(1, &major) < 0 ||
80104b68:	83 c4 10             	add    $0x10,%esp
80104b6b:	85 c0                	test   %eax,%eax
80104b6d:	78 38                	js     80104ba7 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b6f:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104b73:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104b77:	83 ec 0c             	sub    $0xc,%esp
80104b7a:	50                   	push   %eax
80104b7b:	ba 03 00 00 00       	mov    $0x3,%edx
80104b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b83:	e8 94 f7 ff ff       	call   8010431c <create>
80104b88:	83 c4 10             	add    $0x10,%esp
80104b8b:	85 c0                	test   %eax,%eax
80104b8d:	74 18                	je     80104ba7 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b8f:	83 ec 0c             	sub    $0xc,%esp
80104b92:	50                   	push   %eax
80104b93:	e8 90 cb ff ff       	call   80101728 <iunlockput>
  end_op();
80104b98:	e8 6d de ff ff       	call   80102a0a <end_op>
  return 0;
80104b9d:	83 c4 10             	add    $0x10,%esp
80104ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ba5:	c9                   	leave  
80104ba6:	c3                   	ret    
    end_op();
80104ba7:	e8 5e de ff ff       	call   80102a0a <end_op>
    return -1;
80104bac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb1:	eb f2                	jmp    80104ba5 <sys_mknod+0x80>

80104bb3 <sys_chdir>:

int
sys_chdir(void)
{
80104bb3:	55                   	push   %ebp
80104bb4:	89 e5                	mov    %esp,%ebp
80104bb6:	56                   	push   %esi
80104bb7:	53                   	push   %ebx
80104bb8:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104bbb:	e8 48 e8 ff ff       	call   80103408 <myproc>
80104bc0:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104bc2:	e8 c9 dd ff ff       	call   80102990 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104bc7:	83 ec 08             	sub    $0x8,%esp
80104bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bcd:	50                   	push   %eax
80104bce:	6a 00                	push   $0x0
80104bd0:	e8 ca f5 ff ff       	call   8010419f <argstr>
80104bd5:	83 c4 10             	add    $0x10,%esp
80104bd8:	85 c0                	test   %eax,%eax
80104bda:	78 52                	js     80104c2e <sys_chdir+0x7b>
80104bdc:	83 ec 0c             	sub    $0xc,%esp
80104bdf:	ff 75 f4             	pushl  -0xc(%ebp)
80104be2:	e8 fa cf ff ff       	call   80101be1 <namei>
80104be7:	89 c3                	mov    %eax,%ebx
80104be9:	83 c4 10             	add    $0x10,%esp
80104bec:	85 c0                	test   %eax,%eax
80104bee:	74 3e                	je     80104c2e <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104bf0:	83 ec 0c             	sub    $0xc,%esp
80104bf3:	50                   	push   %eax
80104bf4:	e8 88 c9 ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104bf9:	83 c4 10             	add    $0x10,%esp
80104bfc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104c01:	75 37                	jne    80104c3a <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104c03:	83 ec 0c             	sub    $0xc,%esp
80104c06:	53                   	push   %ebx
80104c07:	e8 37 ca ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104c0c:	83 c4 04             	add    $0x4,%esp
80104c0f:	ff 76 68             	pushl  0x68(%esi)
80104c12:	e8 71 ca ff ff       	call   80101688 <iput>
  end_op();
80104c17:	e8 ee dd ff ff       	call   80102a0a <end_op>
  curproc->cwd = ip;
80104c1c:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104c1f:	83 c4 10             	add    $0x10,%esp
80104c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c27:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c2a:	5b                   	pop    %ebx
80104c2b:	5e                   	pop    %esi
80104c2c:	5d                   	pop    %ebp
80104c2d:	c3                   	ret    
    end_op();
80104c2e:	e8 d7 dd ff ff       	call   80102a0a <end_op>
    return -1;
80104c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c38:	eb ed                	jmp    80104c27 <sys_chdir+0x74>
    iunlockput(ip);
80104c3a:	83 ec 0c             	sub    $0xc,%esp
80104c3d:	53                   	push   %ebx
80104c3e:	e8 e5 ca ff ff       	call   80101728 <iunlockput>
    end_op();
80104c43:	e8 c2 dd ff ff       	call   80102a0a <end_op>
    return -1;
80104c48:	83 c4 10             	add    $0x10,%esp
80104c4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c50:	eb d5                	jmp    80104c27 <sys_chdir+0x74>

80104c52 <sys_exec>:

int
sys_exec(void)
{
80104c52:	55                   	push   %ebp
80104c53:	89 e5                	mov    %esp,%ebp
80104c55:	53                   	push   %ebx
80104c56:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c5f:	50                   	push   %eax
80104c60:	6a 00                	push   $0x0
80104c62:	e8 38 f5 ff ff       	call   8010419f <argstr>
80104c67:	83 c4 10             	add    $0x10,%esp
80104c6a:	85 c0                	test   %eax,%eax
80104c6c:	0f 88 a8 00 00 00    	js     80104d1a <sys_exec+0xc8>
80104c72:	83 ec 08             	sub    $0x8,%esp
80104c75:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104c7b:	50                   	push   %eax
80104c7c:	6a 01                	push   $0x1
80104c7e:	e8 8c f4 ff ff       	call   8010410f <argint>
80104c83:	83 c4 10             	add    $0x10,%esp
80104c86:	85 c0                	test   %eax,%eax
80104c88:	0f 88 93 00 00 00    	js     80104d21 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104c8e:	83 ec 04             	sub    $0x4,%esp
80104c91:	68 80 00 00 00       	push   $0x80
80104c96:	6a 00                	push   $0x0
80104c98:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c9e:	50                   	push   %eax
80104c9f:	e8 20 f2 ff ff       	call   80103ec4 <memset>
80104ca4:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104cac:	83 fb 1f             	cmp    $0x1f,%ebx
80104caf:	77 77                	ja     80104d28 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104cb1:	83 ec 08             	sub    $0x8,%esp
80104cb4:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104cba:	50                   	push   %eax
80104cbb:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104cc1:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104cc4:	50                   	push   %eax
80104cc5:	e8 c9 f3 ff ff       	call   80104093 <fetchint>
80104cca:	83 c4 10             	add    $0x10,%esp
80104ccd:	85 c0                	test   %eax,%eax
80104ccf:	78 5e                	js     80104d2f <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104cd1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104cd7:	85 c0                	test   %eax,%eax
80104cd9:	74 1d                	je     80104cf8 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104cdb:	83 ec 08             	sub    $0x8,%esp
80104cde:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104ce5:	52                   	push   %edx
80104ce6:	50                   	push   %eax
80104ce7:	e8 e3 f3 ff ff       	call   801040cf <fetchstr>
80104cec:	83 c4 10             	add    $0x10,%esp
80104cef:	85 c0                	test   %eax,%eax
80104cf1:	78 46                	js     80104d39 <sys_exec+0xe7>
  for(i=0;; i++){
80104cf3:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104cf6:	eb b4                	jmp    80104cac <sys_exec+0x5a>
      argv[i] = 0;
80104cf8:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104cff:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104d03:	83 ec 08             	sub    $0x8,%esp
80104d06:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104d0c:	50                   	push   %eax
80104d0d:	ff 75 f4             	pushl  -0xc(%ebp)
80104d10:	e8 bd bb ff ff       	call   801008d2 <exec>
80104d15:	83 c4 10             	add    $0x10,%esp
80104d18:	eb 1a                	jmp    80104d34 <sys_exec+0xe2>
    return -1;
80104d1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d1f:	eb 13                	jmp    80104d34 <sys_exec+0xe2>
80104d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d26:	eb 0c                	jmp    80104d34 <sys_exec+0xe2>
      return -1;
80104d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2d:	eb 05                	jmp    80104d34 <sys_exec+0xe2>
      return -1;
80104d2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d37:	c9                   	leave  
80104d38:	c3                   	ret    
      return -1;
80104d39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3e:	eb f4                	jmp    80104d34 <sys_exec+0xe2>

80104d40 <sys_pipe>:

int
sys_pipe(void)
{
80104d40:	55                   	push   %ebp
80104d41:	89 e5                	mov    %esp,%ebp
80104d43:	53                   	push   %ebx
80104d44:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104d47:	6a 08                	push   $0x8
80104d49:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4c:	50                   	push   %eax
80104d4d:	6a 00                	push   $0x0
80104d4f:	e8 e3 f3 ff ff       	call   80104137 <argptr>
80104d54:	83 c4 10             	add    $0x10,%esp
80104d57:	85 c0                	test   %eax,%eax
80104d59:	78 77                	js     80104dd2 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104d5b:	83 ec 08             	sub    $0x8,%esp
80104d5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d61:	50                   	push   %eax
80104d62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d65:	50                   	push   %eax
80104d66:	e8 ac e1 ff ff       	call   80102f17 <pipealloc>
80104d6b:	83 c4 10             	add    $0x10,%esp
80104d6e:	85 c0                	test   %eax,%eax
80104d70:	78 67                	js     80104dd9 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d75:	e8 14 f5 ff ff       	call   8010428e <fdalloc>
80104d7a:	89 c3                	mov    %eax,%ebx
80104d7c:	85 c0                	test   %eax,%eax
80104d7e:	78 21                	js     80104da1 <sys_pipe+0x61>
80104d80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d83:	e8 06 f5 ff ff       	call   8010428e <fdalloc>
80104d88:	85 c0                	test   %eax,%eax
80104d8a:	78 15                	js     80104da1 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d8f:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d94:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d9f:	c9                   	leave  
80104da0:	c3                   	ret    
    if(fd0 >= 0)
80104da1:	85 db                	test   %ebx,%ebx
80104da3:	78 0d                	js     80104db2 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104da5:	e8 5e e6 ff ff       	call   80103408 <myproc>
80104daa:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104db1:	00 
    fileclose(rf);
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	ff 75 f0             	pushl  -0x10(%ebp)
80104db8:	e8 16 bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104dbd:	83 c4 04             	add    $0x4,%esp
80104dc0:	ff 75 ec             	pushl  -0x14(%ebp)
80104dc3:	e8 0b bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104dc8:	83 c4 10             	add    $0x10,%esp
80104dcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd0:	eb ca                	jmp    80104d9c <sys_pipe+0x5c>
    return -1;
80104dd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd7:	eb c3                	jmp    80104d9c <sys_pipe+0x5c>
    return -1;
80104dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dde:	eb bc                	jmp    80104d9c <sys_pipe+0x5c>

80104de0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104de0:	55                   	push   %ebp
80104de1:	89 e5                	mov    %esp,%ebp
80104de3:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104de6:	e8 9a e7 ff ff       	call   80103585 <fork>
}
80104deb:	c9                   	leave  
80104dec:	c3                   	ret    

80104ded <sys_exit>:

int
sys_exit(void)
{
80104ded:	55                   	push   %ebp
80104dee:	89 e5                	mov    %esp,%ebp
80104df0:	83 ec 08             	sub    $0x8,%esp
  exit();
80104df3:	e8 c6 e9 ff ff       	call   801037be <exit>
  return 0;  // not reached
}
80104df8:	b8 00 00 00 00       	mov    $0x0,%eax
80104dfd:	c9                   	leave  
80104dfe:	c3                   	ret    

80104dff <sys_wait>:

int
sys_wait(void)
{
80104dff:	55                   	push   %ebp
80104e00:	89 e5                	mov    %esp,%ebp
80104e02:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104e05:	e8 3d eb ff ff       	call   80103947 <wait>
}
80104e0a:	c9                   	leave  
80104e0b:	c3                   	ret    

80104e0c <sys_kill>:

int
sys_kill(void)
{
80104e0c:	55                   	push   %ebp
80104e0d:	89 e5                	mov    %esp,%ebp
80104e0f:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e15:	50                   	push   %eax
80104e16:	6a 00                	push   $0x0
80104e18:	e8 f2 f2 ff ff       	call   8010410f <argint>
80104e1d:	83 c4 10             	add    $0x10,%esp
80104e20:	85 c0                	test   %eax,%eax
80104e22:	78 10                	js     80104e34 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104e24:	83 ec 0c             	sub    $0xc,%esp
80104e27:	ff 75 f4             	pushl  -0xc(%ebp)
80104e2a:	e8 15 ec ff ff       	call   80103a44 <kill>
80104e2f:	83 c4 10             	add    $0x10,%esp
}
80104e32:	c9                   	leave  
80104e33:	c3                   	ret    
    return -1;
80104e34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e39:	eb f7                	jmp    80104e32 <sys_kill+0x26>

80104e3b <sys_getpid>:

int
sys_getpid(void)
{
80104e3b:	55                   	push   %ebp
80104e3c:	89 e5                	mov    %esp,%ebp
80104e3e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104e41:	e8 c2 e5 ff ff       	call   80103408 <myproc>
80104e46:	8b 40 10             	mov    0x10(%eax),%eax
}
80104e49:	c9                   	leave  
80104e4a:	c3                   	ret    

80104e4b <sys_sbrk>:

int
sys_sbrk(void)
{
80104e4b:	55                   	push   %ebp
80104e4c:	89 e5                	mov    %esp,%ebp
80104e4e:	53                   	push   %ebx
80104e4f:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e55:	50                   	push   %eax
80104e56:	6a 00                	push   $0x0
80104e58:	e8 b2 f2 ff ff       	call   8010410f <argint>
80104e5d:	83 c4 10             	add    $0x10,%esp
80104e60:	85 c0                	test   %eax,%eax
80104e62:	78 27                	js     80104e8b <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104e64:	e8 9f e5 ff ff       	call   80103408 <myproc>
80104e69:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104e6b:	83 ec 0c             	sub    $0xc,%esp
80104e6e:	ff 75 f4             	pushl  -0xc(%ebp)
80104e71:	e8 a2 e6 ff ff       	call   80103518 <growproc>
80104e76:	83 c4 10             	add    $0x10,%esp
80104e79:	85 c0                	test   %eax,%eax
80104e7b:	78 07                	js     80104e84 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104e7d:	89 d8                	mov    %ebx,%eax
80104e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e82:	c9                   	leave  
80104e83:	c3                   	ret    
    return -1;
80104e84:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e89:	eb f2                	jmp    80104e7d <sys_sbrk+0x32>
    return -1;
80104e8b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e90:	eb eb                	jmp    80104e7d <sys_sbrk+0x32>

80104e92 <sys_sleep>:

int
sys_sleep(void)
{
80104e92:	55                   	push   %ebp
80104e93:	89 e5                	mov    %esp,%ebp
80104e95:	53                   	push   %ebx
80104e96:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e99:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e9c:	50                   	push   %eax
80104e9d:	6a 00                	push   $0x0
80104e9f:	e8 6b f2 ff ff       	call   8010410f <argint>
80104ea4:	83 c4 10             	add    $0x10,%esp
80104ea7:	85 c0                	test   %eax,%eax
80104ea9:	78 75                	js     80104f20 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104eab:	83 ec 0c             	sub    $0xc,%esp
80104eae:	68 80 0a 1c 80       	push   $0x801c0a80
80104eb3:	e8 60 ef ff ff       	call   80103e18 <acquire>
  ticks0 = ticks;
80104eb8:	8b 1d c0 12 1c 80    	mov    0x801c12c0,%ebx
  while(ticks - ticks0 < n){
80104ebe:	83 c4 10             	add    $0x10,%esp
80104ec1:	a1 c0 12 1c 80       	mov    0x801c12c0,%eax
80104ec6:	29 d8                	sub    %ebx,%eax
80104ec8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ecb:	73 39                	jae    80104f06 <sys_sleep+0x74>
    if(myproc()->killed){
80104ecd:	e8 36 e5 ff ff       	call   80103408 <myproc>
80104ed2:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ed6:	75 17                	jne    80104eef <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104ed8:	83 ec 08             	sub    $0x8,%esp
80104edb:	68 80 0a 1c 80       	push   $0x801c0a80
80104ee0:	68 c0 12 1c 80       	push   $0x801c12c0
80104ee5:	e8 cc e9 ff ff       	call   801038b6 <sleep>
80104eea:	83 c4 10             	add    $0x10,%esp
80104eed:	eb d2                	jmp    80104ec1 <sys_sleep+0x2f>
      release(&tickslock);
80104eef:	83 ec 0c             	sub    $0xc,%esp
80104ef2:	68 80 0a 1c 80       	push   $0x801c0a80
80104ef7:	e8 81 ef ff ff       	call   80103e7d <release>
      return -1;
80104efc:	83 c4 10             	add    $0x10,%esp
80104eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f04:	eb 15                	jmp    80104f1b <sys_sleep+0x89>
  }
  release(&tickslock);
80104f06:	83 ec 0c             	sub    $0xc,%esp
80104f09:	68 80 0a 1c 80       	push   $0x801c0a80
80104f0e:	e8 6a ef ff ff       	call   80103e7d <release>
  return 0;
80104f13:	83 c4 10             	add    $0x10,%esp
80104f16:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f1e:	c9                   	leave  
80104f1f:	c3                   	ret    
    return -1;
80104f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f25:	eb f4                	jmp    80104f1b <sys_sleep+0x89>

80104f27 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104f27:	55                   	push   %ebp
80104f28:	89 e5                	mov    %esp,%ebp
80104f2a:	53                   	push   %ebx
80104f2b:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104f2e:	68 80 0a 1c 80       	push   $0x801c0a80
80104f33:	e8 e0 ee ff ff       	call   80103e18 <acquire>
  xticks = ticks;
80104f38:	8b 1d c0 12 1c 80    	mov    0x801c12c0,%ebx
  release(&tickslock);
80104f3e:	c7 04 24 80 0a 1c 80 	movl   $0x801c0a80,(%esp)
80104f45:	e8 33 ef ff ff       	call   80103e7d <release>
  return xticks;
}
80104f4a:	89 d8                	mov    %ebx,%eax
80104f4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f4f:	c9                   	leave  
80104f50:	c3                   	ret    

80104f51 <sys_dump_physmem>:

int 
sys_dump_physmem(void)
{
80104f51:	55                   	push   %ebp
80104f52:	89 e5                	mov    %esp,%ebp
80104f54:	83 ec 1c             	sub    $0x1c,%esp
    int *frames;
    if(argptr(0, (void*)&frames, sizeof(*frames))< 0){
80104f57:	6a 04                	push   $0x4
80104f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f5c:	50                   	push   %eax
80104f5d:	6a 00                	push   $0x0
80104f5f:	e8 d3 f1 ff ff       	call   80104137 <argptr>
80104f64:	83 c4 10             	add    $0x10,%esp
80104f67:	85 c0                	test   %eax,%eax
80104f69:	78 49                	js     80104fb4 <sys_dump_physmem+0x63>
        return -1;
    }
    int *pids;
    if(argptr(1, (void*)&pids, sizeof(*pids))< 0){
80104f6b:	83 ec 04             	sub    $0x4,%esp
80104f6e:	6a 04                	push   $0x4
80104f70:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f73:	50                   	push   %eax
80104f74:	6a 01                	push   $0x1
80104f76:	e8 bc f1 ff ff       	call   80104137 <argptr>
80104f7b:	83 c4 10             	add    $0x10,%esp
80104f7e:	85 c0                	test   %eax,%eax
80104f80:	78 39                	js     80104fbb <sys_dump_physmem+0x6a>
         return -1;
    }
    int numframes = 0;
80104f82:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    if(argint(2, &numframes) < 0){
80104f89:	83 ec 08             	sub    $0x8,%esp
80104f8c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f8f:	50                   	push   %eax
80104f90:	6a 02                	push   $0x2
80104f92:	e8 78 f1 ff ff       	call   8010410f <argint>
80104f97:	83 c4 10             	add    $0x10,%esp
80104f9a:	85 c0                	test   %eax,%eax
80104f9c:	78 24                	js     80104fc2 <sys_dump_physmem+0x71>
       return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104f9e:	83 ec 04             	sub    $0x4,%esp
80104fa1:	ff 75 ec             	pushl  -0x14(%ebp)
80104fa4:	ff 75 f0             	pushl  -0x10(%ebp)
80104fa7:	ff 75 f4             	pushl  -0xc(%ebp)
80104faa:	e8 bb eb ff ff       	call   80103b6a <dump_physmem>
80104faf:	83 c4 10             	add    $0x10,%esp
}
80104fb2:	c9                   	leave  
80104fb3:	c3                   	ret    
        return -1;
80104fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fb9:	eb f7                	jmp    80104fb2 <sys_dump_physmem+0x61>
         return -1;
80104fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc0:	eb f0                	jmp    80104fb2 <sys_dump_physmem+0x61>
       return -1;
80104fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc7:	eb e9                	jmp    80104fb2 <sys_dump_physmem+0x61>

80104fc9 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104fc9:	1e                   	push   %ds
  pushl %es
80104fca:	06                   	push   %es
  pushl %fs
80104fcb:	0f a0                	push   %fs
  pushl %gs
80104fcd:	0f a8                	push   %gs
  pushal
80104fcf:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104fd0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104fd4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104fd6:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104fd8:	54                   	push   %esp
  call trap
80104fd9:	e8 e3 00 00 00       	call   801050c1 <trap>
  addl $4, %esp
80104fde:	83 c4 04             	add    $0x4,%esp

80104fe1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104fe1:	61                   	popa   
  popl %gs
80104fe2:	0f a9                	pop    %gs
  popl %fs
80104fe4:	0f a1                	pop    %fs
  popl %es
80104fe6:	07                   	pop    %es
  popl %ds
80104fe7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104fe8:	83 c4 08             	add    $0x8,%esp
  iret
80104feb:	cf                   	iret   

80104fec <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104fec:	55                   	push   %ebp
80104fed:	89 e5                	mov    %esp,%ebp
80104fef:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104ff2:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff7:	eb 4a                	jmp    80105043 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104ff9:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105000:	66 89 0c c5 c0 0a 1c 	mov    %cx,-0x7fe3f540(,%eax,8)
80105007:	80 
80105008:	66 c7 04 c5 c2 0a 1c 	movw   $0x8,-0x7fe3f53e(,%eax,8)
8010500f:	80 08 00 
80105012:	c6 04 c5 c4 0a 1c 80 	movb   $0x0,-0x7fe3f53c(,%eax,8)
80105019:	00 
8010501a:	0f b6 14 c5 c5 0a 1c 	movzbl -0x7fe3f53b(,%eax,8),%edx
80105021:	80 
80105022:	83 e2 f0             	and    $0xfffffff0,%edx
80105025:	83 ca 0e             	or     $0xe,%edx
80105028:	83 e2 8f             	and    $0xffffff8f,%edx
8010502b:	83 ca 80             	or     $0xffffff80,%edx
8010502e:	88 14 c5 c5 0a 1c 80 	mov    %dl,-0x7fe3f53b(,%eax,8)
80105035:	c1 e9 10             	shr    $0x10,%ecx
80105038:	66 89 0c c5 c6 0a 1c 	mov    %cx,-0x7fe3f53a(,%eax,8)
8010503f:	80 
  for(i = 0; i < 256; i++)
80105040:	83 c0 01             	add    $0x1,%eax
80105043:	3d ff 00 00 00       	cmp    $0xff,%eax
80105048:	7e af                	jle    80104ff9 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010504a:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80105050:	66 89 15 c0 0c 1c 80 	mov    %dx,0x801c0cc0
80105057:	66 c7 05 c2 0c 1c 80 	movw   $0x8,0x801c0cc2
8010505e:	08 00 
80105060:	c6 05 c4 0c 1c 80 00 	movb   $0x0,0x801c0cc4
80105067:	0f b6 05 c5 0c 1c 80 	movzbl 0x801c0cc5,%eax
8010506e:	83 c8 0f             	or     $0xf,%eax
80105071:	83 e0 ef             	and    $0xffffffef,%eax
80105074:	83 c8 e0             	or     $0xffffffe0,%eax
80105077:	a2 c5 0c 1c 80       	mov    %al,0x801c0cc5
8010507c:	c1 ea 10             	shr    $0x10,%edx
8010507f:	66 89 15 c6 0c 1c 80 	mov    %dx,0x801c0cc6

  initlock(&tickslock, "time");
80105086:	83 ec 08             	sub    $0x8,%esp
80105089:	68 3d 6f 10 80       	push   $0x80106f3d
8010508e:	68 80 0a 1c 80       	push   $0x801c0a80
80105093:	e8 44 ec ff ff       	call   80103cdc <initlock>
}
80105098:	83 c4 10             	add    $0x10,%esp
8010509b:	c9                   	leave  
8010509c:	c3                   	ret    

8010509d <idtinit>:

void
idtinit(void)
{
8010509d:	55                   	push   %ebp
8010509e:	89 e5                	mov    %esp,%ebp
801050a0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801050a3:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
801050a9:	b8 c0 0a 1c 80       	mov    $0x801c0ac0,%eax
801050ae:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801050b2:	c1 e8 10             	shr    $0x10,%eax
801050b5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801050b9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801050bc:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801050bf:	c9                   	leave  
801050c0:	c3                   	ret    

801050c1 <trap>:

void
trap(struct trapframe *tf)
{
801050c1:	55                   	push   %ebp
801050c2:	89 e5                	mov    %esp,%ebp
801050c4:	57                   	push   %edi
801050c5:	56                   	push   %esi
801050c6:	53                   	push   %ebx
801050c7:	83 ec 1c             	sub    $0x1c,%esp
801050ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801050cd:	8b 43 30             	mov    0x30(%ebx),%eax
801050d0:	83 f8 40             	cmp    $0x40,%eax
801050d3:	74 13                	je     801050e8 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801050d5:	83 e8 20             	sub    $0x20,%eax
801050d8:	83 f8 1f             	cmp    $0x1f,%eax
801050db:	0f 87 3a 01 00 00    	ja     8010521b <trap+0x15a>
801050e1:	ff 24 85 e4 6f 10 80 	jmp    *-0x7fef901c(,%eax,4)
    if(myproc()->killed)
801050e8:	e8 1b e3 ff ff       	call   80103408 <myproc>
801050ed:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050f1:	75 1f                	jne    80105112 <trap+0x51>
    myproc()->tf = tf;
801050f3:	e8 10 e3 ff ff       	call   80103408 <myproc>
801050f8:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801050fb:	e8 d2 f0 ff ff       	call   801041d2 <syscall>
    if(myproc()->killed)
80105100:	e8 03 e3 ff ff       	call   80103408 <myproc>
80105105:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105109:	74 7e                	je     80105189 <trap+0xc8>
      exit();
8010510b:	e8 ae e6 ff ff       	call   801037be <exit>
80105110:	eb 77                	jmp    80105189 <trap+0xc8>
      exit();
80105112:	e8 a7 e6 ff ff       	call   801037be <exit>
80105117:	eb da                	jmp    801050f3 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105119:	e8 cf e2 ff ff       	call   801033ed <cpuid>
8010511e:	85 c0                	test   %eax,%eax
80105120:	74 6f                	je     80105191 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105122:	e8 54 d4 ff ff       	call   8010257b <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105127:	e8 dc e2 ff ff       	call   80103408 <myproc>
8010512c:	85 c0                	test   %eax,%eax
8010512e:	74 1c                	je     8010514c <trap+0x8b>
80105130:	e8 d3 e2 ff ff       	call   80103408 <myproc>
80105135:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105139:	74 11                	je     8010514c <trap+0x8b>
8010513b:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010513f:	83 e0 03             	and    $0x3,%eax
80105142:	66 83 f8 03          	cmp    $0x3,%ax
80105146:	0f 84 62 01 00 00    	je     801052ae <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010514c:	e8 b7 e2 ff ff       	call   80103408 <myproc>
80105151:	85 c0                	test   %eax,%eax
80105153:	74 0f                	je     80105164 <trap+0xa3>
80105155:	e8 ae e2 ff ff       	call   80103408 <myproc>
8010515a:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010515e:	0f 84 54 01 00 00    	je     801052b8 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105164:	e8 9f e2 ff ff       	call   80103408 <myproc>
80105169:	85 c0                	test   %eax,%eax
8010516b:	74 1c                	je     80105189 <trap+0xc8>
8010516d:	e8 96 e2 ff ff       	call   80103408 <myproc>
80105172:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105176:	74 11                	je     80105189 <trap+0xc8>
80105178:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010517c:	83 e0 03             	and    $0x3,%eax
8010517f:	66 83 f8 03          	cmp    $0x3,%ax
80105183:	0f 84 43 01 00 00    	je     801052cc <trap+0x20b>
    exit();
}
80105189:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010518c:	5b                   	pop    %ebx
8010518d:	5e                   	pop    %esi
8010518e:	5f                   	pop    %edi
8010518f:	5d                   	pop    %ebp
80105190:	c3                   	ret    
      acquire(&tickslock);
80105191:	83 ec 0c             	sub    $0xc,%esp
80105194:	68 80 0a 1c 80       	push   $0x801c0a80
80105199:	e8 7a ec ff ff       	call   80103e18 <acquire>
      ticks++;
8010519e:	83 05 c0 12 1c 80 01 	addl   $0x1,0x801c12c0
      wakeup(&ticks);
801051a5:	c7 04 24 c0 12 1c 80 	movl   $0x801c12c0,(%esp)
801051ac:	e8 6a e8 ff ff       	call   80103a1b <wakeup>
      release(&tickslock);
801051b1:	c7 04 24 80 0a 1c 80 	movl   $0x801c0a80,(%esp)
801051b8:	e8 c0 ec ff ff       	call   80103e7d <release>
801051bd:	83 c4 10             	add    $0x10,%esp
801051c0:	e9 5d ff ff ff       	jmp    80105122 <trap+0x61>
    ideintr();
801051c5:	e8 a9 cb ff ff       	call   80101d73 <ideintr>
    lapiceoi();
801051ca:	e8 ac d3 ff ff       	call   8010257b <lapiceoi>
    break;
801051cf:	e9 53 ff ff ff       	jmp    80105127 <trap+0x66>
    kbdintr();
801051d4:	e8 e6 d1 ff ff       	call   801023bf <kbdintr>
    lapiceoi();
801051d9:	e8 9d d3 ff ff       	call   8010257b <lapiceoi>
    break;
801051de:	e9 44 ff ff ff       	jmp    80105127 <trap+0x66>
    uartintr();
801051e3:	e8 05 02 00 00       	call   801053ed <uartintr>
    lapiceoi();
801051e8:	e8 8e d3 ff ff       	call   8010257b <lapiceoi>
    break;
801051ed:	e9 35 ff ff ff       	jmp    80105127 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051f2:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801051f5:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051f9:	e8 ef e1 ff ff       	call   801033ed <cpuid>
801051fe:	57                   	push   %edi
801051ff:	0f b7 f6             	movzwl %si,%esi
80105202:	56                   	push   %esi
80105203:	50                   	push   %eax
80105204:	68 48 6f 10 80       	push   $0x80106f48
80105209:	e8 fd b3 ff ff       	call   8010060b <cprintf>
    lapiceoi();
8010520e:	e8 68 d3 ff ff       	call   8010257b <lapiceoi>
    break;
80105213:	83 c4 10             	add    $0x10,%esp
80105216:	e9 0c ff ff ff       	jmp    80105127 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010521b:	e8 e8 e1 ff ff       	call   80103408 <myproc>
80105220:	85 c0                	test   %eax,%eax
80105222:	74 5f                	je     80105283 <trap+0x1c2>
80105224:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105228:	74 59                	je     80105283 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010522a:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010522d:	8b 43 38             	mov    0x38(%ebx),%eax
80105230:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105233:	e8 b5 e1 ff ff       	call   801033ed <cpuid>
80105238:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010523b:	8b 53 34             	mov    0x34(%ebx),%edx
8010523e:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105241:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105244:	e8 bf e1 ff ff       	call   80103408 <myproc>
80105249:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010524c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010524f:	e8 b4 e1 ff ff       	call   80103408 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105254:	57                   	push   %edi
80105255:	ff 75 e4             	pushl  -0x1c(%ebp)
80105258:	ff 75 e0             	pushl  -0x20(%ebp)
8010525b:	ff 75 dc             	pushl  -0x24(%ebp)
8010525e:	56                   	push   %esi
8010525f:	ff 75 d8             	pushl  -0x28(%ebp)
80105262:	ff 70 10             	pushl  0x10(%eax)
80105265:	68 a0 6f 10 80       	push   $0x80106fa0
8010526a:	e8 9c b3 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
8010526f:	83 c4 20             	add    $0x20,%esp
80105272:	e8 91 e1 ff ff       	call   80103408 <myproc>
80105277:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010527e:	e9 a4 fe ff ff       	jmp    80105127 <trap+0x66>
80105283:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105286:	8b 73 38             	mov    0x38(%ebx),%esi
80105289:	e8 5f e1 ff ff       	call   801033ed <cpuid>
8010528e:	83 ec 0c             	sub    $0xc,%esp
80105291:	57                   	push   %edi
80105292:	56                   	push   %esi
80105293:	50                   	push   %eax
80105294:	ff 73 30             	pushl  0x30(%ebx)
80105297:	68 6c 6f 10 80       	push   $0x80106f6c
8010529c:	e8 6a b3 ff ff       	call   8010060b <cprintf>
      panic("trap");
801052a1:	83 c4 14             	add    $0x14,%esp
801052a4:	68 42 6f 10 80       	push   $0x80106f42
801052a9:	e8 9a b0 ff ff       	call   80100348 <panic>
    exit();
801052ae:	e8 0b e5 ff ff       	call   801037be <exit>
801052b3:	e9 94 fe ff ff       	jmp    8010514c <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801052b8:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801052bc:	0f 85 a2 fe ff ff    	jne    80105164 <trap+0xa3>
    yield();
801052c2:	e8 bd e5 ff ff       	call   80103884 <yield>
801052c7:	e9 98 fe ff ff       	jmp    80105164 <trap+0xa3>
    exit();
801052cc:	e8 ed e4 ff ff       	call   801037be <exit>
801052d1:	e9 b3 fe ff ff       	jmp    80105189 <trap+0xc8>

801052d6 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801052d6:	55                   	push   %ebp
801052d7:	89 e5                	mov    %esp,%ebp
  if(!uart)
801052d9:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801052e0:	74 15                	je     801052f7 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052e2:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052e7:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801052e8:	a8 01                	test   $0x1,%al
801052ea:	74 12                	je     801052fe <uartgetc+0x28>
801052ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052f1:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801052f2:	0f b6 c0             	movzbl %al,%eax
}
801052f5:	5d                   	pop    %ebp
801052f6:	c3                   	ret    
    return -1;
801052f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fc:	eb f7                	jmp    801052f5 <uartgetc+0x1f>
    return -1;
801052fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105303:	eb f0                	jmp    801052f5 <uartgetc+0x1f>

80105305 <uartputc>:
  if(!uart)
80105305:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
8010530c:	74 3b                	je     80105349 <uartputc+0x44>
{
8010530e:	55                   	push   %ebp
8010530f:	89 e5                	mov    %esp,%ebp
80105311:	53                   	push   %ebx
80105312:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105315:	bb 00 00 00 00       	mov    $0x0,%ebx
8010531a:	eb 10                	jmp    8010532c <uartputc+0x27>
    microdelay(10);
8010531c:	83 ec 0c             	sub    $0xc,%esp
8010531f:	6a 0a                	push   $0xa
80105321:	e8 74 d2 ff ff       	call   8010259a <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105326:	83 c3 01             	add    $0x1,%ebx
80105329:	83 c4 10             	add    $0x10,%esp
8010532c:	83 fb 7f             	cmp    $0x7f,%ebx
8010532f:	7f 0a                	jg     8010533b <uartputc+0x36>
80105331:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105336:	ec                   	in     (%dx),%al
80105337:	a8 20                	test   $0x20,%al
80105339:	74 e1                	je     8010531c <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010533b:	8b 45 08             	mov    0x8(%ebp),%eax
8010533e:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105343:	ee                   	out    %al,(%dx)
}
80105344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105347:	c9                   	leave  
80105348:	c3                   	ret    
80105349:	f3 c3                	repz ret 

8010534b <uartinit>:
{
8010534b:	55                   	push   %ebp
8010534c:	89 e5                	mov    %esp,%ebp
8010534e:	56                   	push   %esi
8010534f:	53                   	push   %ebx
80105350:	b9 00 00 00 00       	mov    $0x0,%ecx
80105355:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010535a:	89 c8                	mov    %ecx,%eax
8010535c:	ee                   	out    %al,(%dx)
8010535d:	be fb 03 00 00       	mov    $0x3fb,%esi
80105362:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105367:	89 f2                	mov    %esi,%edx
80105369:	ee                   	out    %al,(%dx)
8010536a:	b8 0c 00 00 00       	mov    $0xc,%eax
8010536f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105374:	ee                   	out    %al,(%dx)
80105375:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010537a:	89 c8                	mov    %ecx,%eax
8010537c:	89 da                	mov    %ebx,%edx
8010537e:	ee                   	out    %al,(%dx)
8010537f:	b8 03 00 00 00       	mov    $0x3,%eax
80105384:	89 f2                	mov    %esi,%edx
80105386:	ee                   	out    %al,(%dx)
80105387:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010538c:	89 c8                	mov    %ecx,%eax
8010538e:	ee                   	out    %al,(%dx)
8010538f:	b8 01 00 00 00       	mov    $0x1,%eax
80105394:	89 da                	mov    %ebx,%edx
80105396:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105397:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010539c:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010539d:	3c ff                	cmp    $0xff,%al
8010539f:	74 45                	je     801053e6 <uartinit+0x9b>
  uart = 1;
801053a1:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
801053a8:	00 00 00 
801053ab:	ba fa 03 00 00       	mov    $0x3fa,%edx
801053b0:	ec                   	in     (%dx),%al
801053b1:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053b6:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801053b7:	83 ec 08             	sub    $0x8,%esp
801053ba:	6a 00                	push   $0x0
801053bc:	6a 04                	push   $0x4
801053be:	e8 bb cb ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801053c3:	83 c4 10             	add    $0x10,%esp
801053c6:	bb 64 70 10 80       	mov    $0x80107064,%ebx
801053cb:	eb 12                	jmp    801053df <uartinit+0x94>
    uartputc(*p);
801053cd:	83 ec 0c             	sub    $0xc,%esp
801053d0:	0f be c0             	movsbl %al,%eax
801053d3:	50                   	push   %eax
801053d4:	e8 2c ff ff ff       	call   80105305 <uartputc>
  for(p="xv6...\n"; *p; p++)
801053d9:	83 c3 01             	add    $0x1,%ebx
801053dc:	83 c4 10             	add    $0x10,%esp
801053df:	0f b6 03             	movzbl (%ebx),%eax
801053e2:	84 c0                	test   %al,%al
801053e4:	75 e7                	jne    801053cd <uartinit+0x82>
}
801053e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801053e9:	5b                   	pop    %ebx
801053ea:	5e                   	pop    %esi
801053eb:	5d                   	pop    %ebp
801053ec:	c3                   	ret    

801053ed <uartintr>:

void
uartintr(void)
{
801053ed:	55                   	push   %ebp
801053ee:	89 e5                	mov    %esp,%ebp
801053f0:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801053f3:	68 d6 52 10 80       	push   $0x801052d6
801053f8:	e8 41 b3 ff ff       	call   8010073e <consoleintr>
}
801053fd:	83 c4 10             	add    $0x10,%esp
80105400:	c9                   	leave  
80105401:	c3                   	ret    

80105402 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105402:	6a 00                	push   $0x0
  pushl $0
80105404:	6a 00                	push   $0x0
  jmp alltraps
80105406:	e9 be fb ff ff       	jmp    80104fc9 <alltraps>

8010540b <vector1>:
.globl vector1
vector1:
  pushl $0
8010540b:	6a 00                	push   $0x0
  pushl $1
8010540d:	6a 01                	push   $0x1
  jmp alltraps
8010540f:	e9 b5 fb ff ff       	jmp    80104fc9 <alltraps>

80105414 <vector2>:
.globl vector2
vector2:
  pushl $0
80105414:	6a 00                	push   $0x0
  pushl $2
80105416:	6a 02                	push   $0x2
  jmp alltraps
80105418:	e9 ac fb ff ff       	jmp    80104fc9 <alltraps>

8010541d <vector3>:
.globl vector3
vector3:
  pushl $0
8010541d:	6a 00                	push   $0x0
  pushl $3
8010541f:	6a 03                	push   $0x3
  jmp alltraps
80105421:	e9 a3 fb ff ff       	jmp    80104fc9 <alltraps>

80105426 <vector4>:
.globl vector4
vector4:
  pushl $0
80105426:	6a 00                	push   $0x0
  pushl $4
80105428:	6a 04                	push   $0x4
  jmp alltraps
8010542a:	e9 9a fb ff ff       	jmp    80104fc9 <alltraps>

8010542f <vector5>:
.globl vector5
vector5:
  pushl $0
8010542f:	6a 00                	push   $0x0
  pushl $5
80105431:	6a 05                	push   $0x5
  jmp alltraps
80105433:	e9 91 fb ff ff       	jmp    80104fc9 <alltraps>

80105438 <vector6>:
.globl vector6
vector6:
  pushl $0
80105438:	6a 00                	push   $0x0
  pushl $6
8010543a:	6a 06                	push   $0x6
  jmp alltraps
8010543c:	e9 88 fb ff ff       	jmp    80104fc9 <alltraps>

80105441 <vector7>:
.globl vector7
vector7:
  pushl $0
80105441:	6a 00                	push   $0x0
  pushl $7
80105443:	6a 07                	push   $0x7
  jmp alltraps
80105445:	e9 7f fb ff ff       	jmp    80104fc9 <alltraps>

8010544a <vector8>:
.globl vector8
vector8:
  pushl $8
8010544a:	6a 08                	push   $0x8
  jmp alltraps
8010544c:	e9 78 fb ff ff       	jmp    80104fc9 <alltraps>

80105451 <vector9>:
.globl vector9
vector9:
  pushl $0
80105451:	6a 00                	push   $0x0
  pushl $9
80105453:	6a 09                	push   $0x9
  jmp alltraps
80105455:	e9 6f fb ff ff       	jmp    80104fc9 <alltraps>

8010545a <vector10>:
.globl vector10
vector10:
  pushl $10
8010545a:	6a 0a                	push   $0xa
  jmp alltraps
8010545c:	e9 68 fb ff ff       	jmp    80104fc9 <alltraps>

80105461 <vector11>:
.globl vector11
vector11:
  pushl $11
80105461:	6a 0b                	push   $0xb
  jmp alltraps
80105463:	e9 61 fb ff ff       	jmp    80104fc9 <alltraps>

80105468 <vector12>:
.globl vector12
vector12:
  pushl $12
80105468:	6a 0c                	push   $0xc
  jmp alltraps
8010546a:	e9 5a fb ff ff       	jmp    80104fc9 <alltraps>

8010546f <vector13>:
.globl vector13
vector13:
  pushl $13
8010546f:	6a 0d                	push   $0xd
  jmp alltraps
80105471:	e9 53 fb ff ff       	jmp    80104fc9 <alltraps>

80105476 <vector14>:
.globl vector14
vector14:
  pushl $14
80105476:	6a 0e                	push   $0xe
  jmp alltraps
80105478:	e9 4c fb ff ff       	jmp    80104fc9 <alltraps>

8010547d <vector15>:
.globl vector15
vector15:
  pushl $0
8010547d:	6a 00                	push   $0x0
  pushl $15
8010547f:	6a 0f                	push   $0xf
  jmp alltraps
80105481:	e9 43 fb ff ff       	jmp    80104fc9 <alltraps>

80105486 <vector16>:
.globl vector16
vector16:
  pushl $0
80105486:	6a 00                	push   $0x0
  pushl $16
80105488:	6a 10                	push   $0x10
  jmp alltraps
8010548a:	e9 3a fb ff ff       	jmp    80104fc9 <alltraps>

8010548f <vector17>:
.globl vector17
vector17:
  pushl $17
8010548f:	6a 11                	push   $0x11
  jmp alltraps
80105491:	e9 33 fb ff ff       	jmp    80104fc9 <alltraps>

80105496 <vector18>:
.globl vector18
vector18:
  pushl $0
80105496:	6a 00                	push   $0x0
  pushl $18
80105498:	6a 12                	push   $0x12
  jmp alltraps
8010549a:	e9 2a fb ff ff       	jmp    80104fc9 <alltraps>

8010549f <vector19>:
.globl vector19
vector19:
  pushl $0
8010549f:	6a 00                	push   $0x0
  pushl $19
801054a1:	6a 13                	push   $0x13
  jmp alltraps
801054a3:	e9 21 fb ff ff       	jmp    80104fc9 <alltraps>

801054a8 <vector20>:
.globl vector20
vector20:
  pushl $0
801054a8:	6a 00                	push   $0x0
  pushl $20
801054aa:	6a 14                	push   $0x14
  jmp alltraps
801054ac:	e9 18 fb ff ff       	jmp    80104fc9 <alltraps>

801054b1 <vector21>:
.globl vector21
vector21:
  pushl $0
801054b1:	6a 00                	push   $0x0
  pushl $21
801054b3:	6a 15                	push   $0x15
  jmp alltraps
801054b5:	e9 0f fb ff ff       	jmp    80104fc9 <alltraps>

801054ba <vector22>:
.globl vector22
vector22:
  pushl $0
801054ba:	6a 00                	push   $0x0
  pushl $22
801054bc:	6a 16                	push   $0x16
  jmp alltraps
801054be:	e9 06 fb ff ff       	jmp    80104fc9 <alltraps>

801054c3 <vector23>:
.globl vector23
vector23:
  pushl $0
801054c3:	6a 00                	push   $0x0
  pushl $23
801054c5:	6a 17                	push   $0x17
  jmp alltraps
801054c7:	e9 fd fa ff ff       	jmp    80104fc9 <alltraps>

801054cc <vector24>:
.globl vector24
vector24:
  pushl $0
801054cc:	6a 00                	push   $0x0
  pushl $24
801054ce:	6a 18                	push   $0x18
  jmp alltraps
801054d0:	e9 f4 fa ff ff       	jmp    80104fc9 <alltraps>

801054d5 <vector25>:
.globl vector25
vector25:
  pushl $0
801054d5:	6a 00                	push   $0x0
  pushl $25
801054d7:	6a 19                	push   $0x19
  jmp alltraps
801054d9:	e9 eb fa ff ff       	jmp    80104fc9 <alltraps>

801054de <vector26>:
.globl vector26
vector26:
  pushl $0
801054de:	6a 00                	push   $0x0
  pushl $26
801054e0:	6a 1a                	push   $0x1a
  jmp alltraps
801054e2:	e9 e2 fa ff ff       	jmp    80104fc9 <alltraps>

801054e7 <vector27>:
.globl vector27
vector27:
  pushl $0
801054e7:	6a 00                	push   $0x0
  pushl $27
801054e9:	6a 1b                	push   $0x1b
  jmp alltraps
801054eb:	e9 d9 fa ff ff       	jmp    80104fc9 <alltraps>

801054f0 <vector28>:
.globl vector28
vector28:
  pushl $0
801054f0:	6a 00                	push   $0x0
  pushl $28
801054f2:	6a 1c                	push   $0x1c
  jmp alltraps
801054f4:	e9 d0 fa ff ff       	jmp    80104fc9 <alltraps>

801054f9 <vector29>:
.globl vector29
vector29:
  pushl $0
801054f9:	6a 00                	push   $0x0
  pushl $29
801054fb:	6a 1d                	push   $0x1d
  jmp alltraps
801054fd:	e9 c7 fa ff ff       	jmp    80104fc9 <alltraps>

80105502 <vector30>:
.globl vector30
vector30:
  pushl $0
80105502:	6a 00                	push   $0x0
  pushl $30
80105504:	6a 1e                	push   $0x1e
  jmp alltraps
80105506:	e9 be fa ff ff       	jmp    80104fc9 <alltraps>

8010550b <vector31>:
.globl vector31
vector31:
  pushl $0
8010550b:	6a 00                	push   $0x0
  pushl $31
8010550d:	6a 1f                	push   $0x1f
  jmp alltraps
8010550f:	e9 b5 fa ff ff       	jmp    80104fc9 <alltraps>

80105514 <vector32>:
.globl vector32
vector32:
  pushl $0
80105514:	6a 00                	push   $0x0
  pushl $32
80105516:	6a 20                	push   $0x20
  jmp alltraps
80105518:	e9 ac fa ff ff       	jmp    80104fc9 <alltraps>

8010551d <vector33>:
.globl vector33
vector33:
  pushl $0
8010551d:	6a 00                	push   $0x0
  pushl $33
8010551f:	6a 21                	push   $0x21
  jmp alltraps
80105521:	e9 a3 fa ff ff       	jmp    80104fc9 <alltraps>

80105526 <vector34>:
.globl vector34
vector34:
  pushl $0
80105526:	6a 00                	push   $0x0
  pushl $34
80105528:	6a 22                	push   $0x22
  jmp alltraps
8010552a:	e9 9a fa ff ff       	jmp    80104fc9 <alltraps>

8010552f <vector35>:
.globl vector35
vector35:
  pushl $0
8010552f:	6a 00                	push   $0x0
  pushl $35
80105531:	6a 23                	push   $0x23
  jmp alltraps
80105533:	e9 91 fa ff ff       	jmp    80104fc9 <alltraps>

80105538 <vector36>:
.globl vector36
vector36:
  pushl $0
80105538:	6a 00                	push   $0x0
  pushl $36
8010553a:	6a 24                	push   $0x24
  jmp alltraps
8010553c:	e9 88 fa ff ff       	jmp    80104fc9 <alltraps>

80105541 <vector37>:
.globl vector37
vector37:
  pushl $0
80105541:	6a 00                	push   $0x0
  pushl $37
80105543:	6a 25                	push   $0x25
  jmp alltraps
80105545:	e9 7f fa ff ff       	jmp    80104fc9 <alltraps>

8010554a <vector38>:
.globl vector38
vector38:
  pushl $0
8010554a:	6a 00                	push   $0x0
  pushl $38
8010554c:	6a 26                	push   $0x26
  jmp alltraps
8010554e:	e9 76 fa ff ff       	jmp    80104fc9 <alltraps>

80105553 <vector39>:
.globl vector39
vector39:
  pushl $0
80105553:	6a 00                	push   $0x0
  pushl $39
80105555:	6a 27                	push   $0x27
  jmp alltraps
80105557:	e9 6d fa ff ff       	jmp    80104fc9 <alltraps>

8010555c <vector40>:
.globl vector40
vector40:
  pushl $0
8010555c:	6a 00                	push   $0x0
  pushl $40
8010555e:	6a 28                	push   $0x28
  jmp alltraps
80105560:	e9 64 fa ff ff       	jmp    80104fc9 <alltraps>

80105565 <vector41>:
.globl vector41
vector41:
  pushl $0
80105565:	6a 00                	push   $0x0
  pushl $41
80105567:	6a 29                	push   $0x29
  jmp alltraps
80105569:	e9 5b fa ff ff       	jmp    80104fc9 <alltraps>

8010556e <vector42>:
.globl vector42
vector42:
  pushl $0
8010556e:	6a 00                	push   $0x0
  pushl $42
80105570:	6a 2a                	push   $0x2a
  jmp alltraps
80105572:	e9 52 fa ff ff       	jmp    80104fc9 <alltraps>

80105577 <vector43>:
.globl vector43
vector43:
  pushl $0
80105577:	6a 00                	push   $0x0
  pushl $43
80105579:	6a 2b                	push   $0x2b
  jmp alltraps
8010557b:	e9 49 fa ff ff       	jmp    80104fc9 <alltraps>

80105580 <vector44>:
.globl vector44
vector44:
  pushl $0
80105580:	6a 00                	push   $0x0
  pushl $44
80105582:	6a 2c                	push   $0x2c
  jmp alltraps
80105584:	e9 40 fa ff ff       	jmp    80104fc9 <alltraps>

80105589 <vector45>:
.globl vector45
vector45:
  pushl $0
80105589:	6a 00                	push   $0x0
  pushl $45
8010558b:	6a 2d                	push   $0x2d
  jmp alltraps
8010558d:	e9 37 fa ff ff       	jmp    80104fc9 <alltraps>

80105592 <vector46>:
.globl vector46
vector46:
  pushl $0
80105592:	6a 00                	push   $0x0
  pushl $46
80105594:	6a 2e                	push   $0x2e
  jmp alltraps
80105596:	e9 2e fa ff ff       	jmp    80104fc9 <alltraps>

8010559b <vector47>:
.globl vector47
vector47:
  pushl $0
8010559b:	6a 00                	push   $0x0
  pushl $47
8010559d:	6a 2f                	push   $0x2f
  jmp alltraps
8010559f:	e9 25 fa ff ff       	jmp    80104fc9 <alltraps>

801055a4 <vector48>:
.globl vector48
vector48:
  pushl $0
801055a4:	6a 00                	push   $0x0
  pushl $48
801055a6:	6a 30                	push   $0x30
  jmp alltraps
801055a8:	e9 1c fa ff ff       	jmp    80104fc9 <alltraps>

801055ad <vector49>:
.globl vector49
vector49:
  pushl $0
801055ad:	6a 00                	push   $0x0
  pushl $49
801055af:	6a 31                	push   $0x31
  jmp alltraps
801055b1:	e9 13 fa ff ff       	jmp    80104fc9 <alltraps>

801055b6 <vector50>:
.globl vector50
vector50:
  pushl $0
801055b6:	6a 00                	push   $0x0
  pushl $50
801055b8:	6a 32                	push   $0x32
  jmp alltraps
801055ba:	e9 0a fa ff ff       	jmp    80104fc9 <alltraps>

801055bf <vector51>:
.globl vector51
vector51:
  pushl $0
801055bf:	6a 00                	push   $0x0
  pushl $51
801055c1:	6a 33                	push   $0x33
  jmp alltraps
801055c3:	e9 01 fa ff ff       	jmp    80104fc9 <alltraps>

801055c8 <vector52>:
.globl vector52
vector52:
  pushl $0
801055c8:	6a 00                	push   $0x0
  pushl $52
801055ca:	6a 34                	push   $0x34
  jmp alltraps
801055cc:	e9 f8 f9 ff ff       	jmp    80104fc9 <alltraps>

801055d1 <vector53>:
.globl vector53
vector53:
  pushl $0
801055d1:	6a 00                	push   $0x0
  pushl $53
801055d3:	6a 35                	push   $0x35
  jmp alltraps
801055d5:	e9 ef f9 ff ff       	jmp    80104fc9 <alltraps>

801055da <vector54>:
.globl vector54
vector54:
  pushl $0
801055da:	6a 00                	push   $0x0
  pushl $54
801055dc:	6a 36                	push   $0x36
  jmp alltraps
801055de:	e9 e6 f9 ff ff       	jmp    80104fc9 <alltraps>

801055e3 <vector55>:
.globl vector55
vector55:
  pushl $0
801055e3:	6a 00                	push   $0x0
  pushl $55
801055e5:	6a 37                	push   $0x37
  jmp alltraps
801055e7:	e9 dd f9 ff ff       	jmp    80104fc9 <alltraps>

801055ec <vector56>:
.globl vector56
vector56:
  pushl $0
801055ec:	6a 00                	push   $0x0
  pushl $56
801055ee:	6a 38                	push   $0x38
  jmp alltraps
801055f0:	e9 d4 f9 ff ff       	jmp    80104fc9 <alltraps>

801055f5 <vector57>:
.globl vector57
vector57:
  pushl $0
801055f5:	6a 00                	push   $0x0
  pushl $57
801055f7:	6a 39                	push   $0x39
  jmp alltraps
801055f9:	e9 cb f9 ff ff       	jmp    80104fc9 <alltraps>

801055fe <vector58>:
.globl vector58
vector58:
  pushl $0
801055fe:	6a 00                	push   $0x0
  pushl $58
80105600:	6a 3a                	push   $0x3a
  jmp alltraps
80105602:	e9 c2 f9 ff ff       	jmp    80104fc9 <alltraps>

80105607 <vector59>:
.globl vector59
vector59:
  pushl $0
80105607:	6a 00                	push   $0x0
  pushl $59
80105609:	6a 3b                	push   $0x3b
  jmp alltraps
8010560b:	e9 b9 f9 ff ff       	jmp    80104fc9 <alltraps>

80105610 <vector60>:
.globl vector60
vector60:
  pushl $0
80105610:	6a 00                	push   $0x0
  pushl $60
80105612:	6a 3c                	push   $0x3c
  jmp alltraps
80105614:	e9 b0 f9 ff ff       	jmp    80104fc9 <alltraps>

80105619 <vector61>:
.globl vector61
vector61:
  pushl $0
80105619:	6a 00                	push   $0x0
  pushl $61
8010561b:	6a 3d                	push   $0x3d
  jmp alltraps
8010561d:	e9 a7 f9 ff ff       	jmp    80104fc9 <alltraps>

80105622 <vector62>:
.globl vector62
vector62:
  pushl $0
80105622:	6a 00                	push   $0x0
  pushl $62
80105624:	6a 3e                	push   $0x3e
  jmp alltraps
80105626:	e9 9e f9 ff ff       	jmp    80104fc9 <alltraps>

8010562b <vector63>:
.globl vector63
vector63:
  pushl $0
8010562b:	6a 00                	push   $0x0
  pushl $63
8010562d:	6a 3f                	push   $0x3f
  jmp alltraps
8010562f:	e9 95 f9 ff ff       	jmp    80104fc9 <alltraps>

80105634 <vector64>:
.globl vector64
vector64:
  pushl $0
80105634:	6a 00                	push   $0x0
  pushl $64
80105636:	6a 40                	push   $0x40
  jmp alltraps
80105638:	e9 8c f9 ff ff       	jmp    80104fc9 <alltraps>

8010563d <vector65>:
.globl vector65
vector65:
  pushl $0
8010563d:	6a 00                	push   $0x0
  pushl $65
8010563f:	6a 41                	push   $0x41
  jmp alltraps
80105641:	e9 83 f9 ff ff       	jmp    80104fc9 <alltraps>

80105646 <vector66>:
.globl vector66
vector66:
  pushl $0
80105646:	6a 00                	push   $0x0
  pushl $66
80105648:	6a 42                	push   $0x42
  jmp alltraps
8010564a:	e9 7a f9 ff ff       	jmp    80104fc9 <alltraps>

8010564f <vector67>:
.globl vector67
vector67:
  pushl $0
8010564f:	6a 00                	push   $0x0
  pushl $67
80105651:	6a 43                	push   $0x43
  jmp alltraps
80105653:	e9 71 f9 ff ff       	jmp    80104fc9 <alltraps>

80105658 <vector68>:
.globl vector68
vector68:
  pushl $0
80105658:	6a 00                	push   $0x0
  pushl $68
8010565a:	6a 44                	push   $0x44
  jmp alltraps
8010565c:	e9 68 f9 ff ff       	jmp    80104fc9 <alltraps>

80105661 <vector69>:
.globl vector69
vector69:
  pushl $0
80105661:	6a 00                	push   $0x0
  pushl $69
80105663:	6a 45                	push   $0x45
  jmp alltraps
80105665:	e9 5f f9 ff ff       	jmp    80104fc9 <alltraps>

8010566a <vector70>:
.globl vector70
vector70:
  pushl $0
8010566a:	6a 00                	push   $0x0
  pushl $70
8010566c:	6a 46                	push   $0x46
  jmp alltraps
8010566e:	e9 56 f9 ff ff       	jmp    80104fc9 <alltraps>

80105673 <vector71>:
.globl vector71
vector71:
  pushl $0
80105673:	6a 00                	push   $0x0
  pushl $71
80105675:	6a 47                	push   $0x47
  jmp alltraps
80105677:	e9 4d f9 ff ff       	jmp    80104fc9 <alltraps>

8010567c <vector72>:
.globl vector72
vector72:
  pushl $0
8010567c:	6a 00                	push   $0x0
  pushl $72
8010567e:	6a 48                	push   $0x48
  jmp alltraps
80105680:	e9 44 f9 ff ff       	jmp    80104fc9 <alltraps>

80105685 <vector73>:
.globl vector73
vector73:
  pushl $0
80105685:	6a 00                	push   $0x0
  pushl $73
80105687:	6a 49                	push   $0x49
  jmp alltraps
80105689:	e9 3b f9 ff ff       	jmp    80104fc9 <alltraps>

8010568e <vector74>:
.globl vector74
vector74:
  pushl $0
8010568e:	6a 00                	push   $0x0
  pushl $74
80105690:	6a 4a                	push   $0x4a
  jmp alltraps
80105692:	e9 32 f9 ff ff       	jmp    80104fc9 <alltraps>

80105697 <vector75>:
.globl vector75
vector75:
  pushl $0
80105697:	6a 00                	push   $0x0
  pushl $75
80105699:	6a 4b                	push   $0x4b
  jmp alltraps
8010569b:	e9 29 f9 ff ff       	jmp    80104fc9 <alltraps>

801056a0 <vector76>:
.globl vector76
vector76:
  pushl $0
801056a0:	6a 00                	push   $0x0
  pushl $76
801056a2:	6a 4c                	push   $0x4c
  jmp alltraps
801056a4:	e9 20 f9 ff ff       	jmp    80104fc9 <alltraps>

801056a9 <vector77>:
.globl vector77
vector77:
  pushl $0
801056a9:	6a 00                	push   $0x0
  pushl $77
801056ab:	6a 4d                	push   $0x4d
  jmp alltraps
801056ad:	e9 17 f9 ff ff       	jmp    80104fc9 <alltraps>

801056b2 <vector78>:
.globl vector78
vector78:
  pushl $0
801056b2:	6a 00                	push   $0x0
  pushl $78
801056b4:	6a 4e                	push   $0x4e
  jmp alltraps
801056b6:	e9 0e f9 ff ff       	jmp    80104fc9 <alltraps>

801056bb <vector79>:
.globl vector79
vector79:
  pushl $0
801056bb:	6a 00                	push   $0x0
  pushl $79
801056bd:	6a 4f                	push   $0x4f
  jmp alltraps
801056bf:	e9 05 f9 ff ff       	jmp    80104fc9 <alltraps>

801056c4 <vector80>:
.globl vector80
vector80:
  pushl $0
801056c4:	6a 00                	push   $0x0
  pushl $80
801056c6:	6a 50                	push   $0x50
  jmp alltraps
801056c8:	e9 fc f8 ff ff       	jmp    80104fc9 <alltraps>

801056cd <vector81>:
.globl vector81
vector81:
  pushl $0
801056cd:	6a 00                	push   $0x0
  pushl $81
801056cf:	6a 51                	push   $0x51
  jmp alltraps
801056d1:	e9 f3 f8 ff ff       	jmp    80104fc9 <alltraps>

801056d6 <vector82>:
.globl vector82
vector82:
  pushl $0
801056d6:	6a 00                	push   $0x0
  pushl $82
801056d8:	6a 52                	push   $0x52
  jmp alltraps
801056da:	e9 ea f8 ff ff       	jmp    80104fc9 <alltraps>

801056df <vector83>:
.globl vector83
vector83:
  pushl $0
801056df:	6a 00                	push   $0x0
  pushl $83
801056e1:	6a 53                	push   $0x53
  jmp alltraps
801056e3:	e9 e1 f8 ff ff       	jmp    80104fc9 <alltraps>

801056e8 <vector84>:
.globl vector84
vector84:
  pushl $0
801056e8:	6a 00                	push   $0x0
  pushl $84
801056ea:	6a 54                	push   $0x54
  jmp alltraps
801056ec:	e9 d8 f8 ff ff       	jmp    80104fc9 <alltraps>

801056f1 <vector85>:
.globl vector85
vector85:
  pushl $0
801056f1:	6a 00                	push   $0x0
  pushl $85
801056f3:	6a 55                	push   $0x55
  jmp alltraps
801056f5:	e9 cf f8 ff ff       	jmp    80104fc9 <alltraps>

801056fa <vector86>:
.globl vector86
vector86:
  pushl $0
801056fa:	6a 00                	push   $0x0
  pushl $86
801056fc:	6a 56                	push   $0x56
  jmp alltraps
801056fe:	e9 c6 f8 ff ff       	jmp    80104fc9 <alltraps>

80105703 <vector87>:
.globl vector87
vector87:
  pushl $0
80105703:	6a 00                	push   $0x0
  pushl $87
80105705:	6a 57                	push   $0x57
  jmp alltraps
80105707:	e9 bd f8 ff ff       	jmp    80104fc9 <alltraps>

8010570c <vector88>:
.globl vector88
vector88:
  pushl $0
8010570c:	6a 00                	push   $0x0
  pushl $88
8010570e:	6a 58                	push   $0x58
  jmp alltraps
80105710:	e9 b4 f8 ff ff       	jmp    80104fc9 <alltraps>

80105715 <vector89>:
.globl vector89
vector89:
  pushl $0
80105715:	6a 00                	push   $0x0
  pushl $89
80105717:	6a 59                	push   $0x59
  jmp alltraps
80105719:	e9 ab f8 ff ff       	jmp    80104fc9 <alltraps>

8010571e <vector90>:
.globl vector90
vector90:
  pushl $0
8010571e:	6a 00                	push   $0x0
  pushl $90
80105720:	6a 5a                	push   $0x5a
  jmp alltraps
80105722:	e9 a2 f8 ff ff       	jmp    80104fc9 <alltraps>

80105727 <vector91>:
.globl vector91
vector91:
  pushl $0
80105727:	6a 00                	push   $0x0
  pushl $91
80105729:	6a 5b                	push   $0x5b
  jmp alltraps
8010572b:	e9 99 f8 ff ff       	jmp    80104fc9 <alltraps>

80105730 <vector92>:
.globl vector92
vector92:
  pushl $0
80105730:	6a 00                	push   $0x0
  pushl $92
80105732:	6a 5c                	push   $0x5c
  jmp alltraps
80105734:	e9 90 f8 ff ff       	jmp    80104fc9 <alltraps>

80105739 <vector93>:
.globl vector93
vector93:
  pushl $0
80105739:	6a 00                	push   $0x0
  pushl $93
8010573b:	6a 5d                	push   $0x5d
  jmp alltraps
8010573d:	e9 87 f8 ff ff       	jmp    80104fc9 <alltraps>

80105742 <vector94>:
.globl vector94
vector94:
  pushl $0
80105742:	6a 00                	push   $0x0
  pushl $94
80105744:	6a 5e                	push   $0x5e
  jmp alltraps
80105746:	e9 7e f8 ff ff       	jmp    80104fc9 <alltraps>

8010574b <vector95>:
.globl vector95
vector95:
  pushl $0
8010574b:	6a 00                	push   $0x0
  pushl $95
8010574d:	6a 5f                	push   $0x5f
  jmp alltraps
8010574f:	e9 75 f8 ff ff       	jmp    80104fc9 <alltraps>

80105754 <vector96>:
.globl vector96
vector96:
  pushl $0
80105754:	6a 00                	push   $0x0
  pushl $96
80105756:	6a 60                	push   $0x60
  jmp alltraps
80105758:	e9 6c f8 ff ff       	jmp    80104fc9 <alltraps>

8010575d <vector97>:
.globl vector97
vector97:
  pushl $0
8010575d:	6a 00                	push   $0x0
  pushl $97
8010575f:	6a 61                	push   $0x61
  jmp alltraps
80105761:	e9 63 f8 ff ff       	jmp    80104fc9 <alltraps>

80105766 <vector98>:
.globl vector98
vector98:
  pushl $0
80105766:	6a 00                	push   $0x0
  pushl $98
80105768:	6a 62                	push   $0x62
  jmp alltraps
8010576a:	e9 5a f8 ff ff       	jmp    80104fc9 <alltraps>

8010576f <vector99>:
.globl vector99
vector99:
  pushl $0
8010576f:	6a 00                	push   $0x0
  pushl $99
80105771:	6a 63                	push   $0x63
  jmp alltraps
80105773:	e9 51 f8 ff ff       	jmp    80104fc9 <alltraps>

80105778 <vector100>:
.globl vector100
vector100:
  pushl $0
80105778:	6a 00                	push   $0x0
  pushl $100
8010577a:	6a 64                	push   $0x64
  jmp alltraps
8010577c:	e9 48 f8 ff ff       	jmp    80104fc9 <alltraps>

80105781 <vector101>:
.globl vector101
vector101:
  pushl $0
80105781:	6a 00                	push   $0x0
  pushl $101
80105783:	6a 65                	push   $0x65
  jmp alltraps
80105785:	e9 3f f8 ff ff       	jmp    80104fc9 <alltraps>

8010578a <vector102>:
.globl vector102
vector102:
  pushl $0
8010578a:	6a 00                	push   $0x0
  pushl $102
8010578c:	6a 66                	push   $0x66
  jmp alltraps
8010578e:	e9 36 f8 ff ff       	jmp    80104fc9 <alltraps>

80105793 <vector103>:
.globl vector103
vector103:
  pushl $0
80105793:	6a 00                	push   $0x0
  pushl $103
80105795:	6a 67                	push   $0x67
  jmp alltraps
80105797:	e9 2d f8 ff ff       	jmp    80104fc9 <alltraps>

8010579c <vector104>:
.globl vector104
vector104:
  pushl $0
8010579c:	6a 00                	push   $0x0
  pushl $104
8010579e:	6a 68                	push   $0x68
  jmp alltraps
801057a0:	e9 24 f8 ff ff       	jmp    80104fc9 <alltraps>

801057a5 <vector105>:
.globl vector105
vector105:
  pushl $0
801057a5:	6a 00                	push   $0x0
  pushl $105
801057a7:	6a 69                	push   $0x69
  jmp alltraps
801057a9:	e9 1b f8 ff ff       	jmp    80104fc9 <alltraps>

801057ae <vector106>:
.globl vector106
vector106:
  pushl $0
801057ae:	6a 00                	push   $0x0
  pushl $106
801057b0:	6a 6a                	push   $0x6a
  jmp alltraps
801057b2:	e9 12 f8 ff ff       	jmp    80104fc9 <alltraps>

801057b7 <vector107>:
.globl vector107
vector107:
  pushl $0
801057b7:	6a 00                	push   $0x0
  pushl $107
801057b9:	6a 6b                	push   $0x6b
  jmp alltraps
801057bb:	e9 09 f8 ff ff       	jmp    80104fc9 <alltraps>

801057c0 <vector108>:
.globl vector108
vector108:
  pushl $0
801057c0:	6a 00                	push   $0x0
  pushl $108
801057c2:	6a 6c                	push   $0x6c
  jmp alltraps
801057c4:	e9 00 f8 ff ff       	jmp    80104fc9 <alltraps>

801057c9 <vector109>:
.globl vector109
vector109:
  pushl $0
801057c9:	6a 00                	push   $0x0
  pushl $109
801057cb:	6a 6d                	push   $0x6d
  jmp alltraps
801057cd:	e9 f7 f7 ff ff       	jmp    80104fc9 <alltraps>

801057d2 <vector110>:
.globl vector110
vector110:
  pushl $0
801057d2:	6a 00                	push   $0x0
  pushl $110
801057d4:	6a 6e                	push   $0x6e
  jmp alltraps
801057d6:	e9 ee f7 ff ff       	jmp    80104fc9 <alltraps>

801057db <vector111>:
.globl vector111
vector111:
  pushl $0
801057db:	6a 00                	push   $0x0
  pushl $111
801057dd:	6a 6f                	push   $0x6f
  jmp alltraps
801057df:	e9 e5 f7 ff ff       	jmp    80104fc9 <alltraps>

801057e4 <vector112>:
.globl vector112
vector112:
  pushl $0
801057e4:	6a 00                	push   $0x0
  pushl $112
801057e6:	6a 70                	push   $0x70
  jmp alltraps
801057e8:	e9 dc f7 ff ff       	jmp    80104fc9 <alltraps>

801057ed <vector113>:
.globl vector113
vector113:
  pushl $0
801057ed:	6a 00                	push   $0x0
  pushl $113
801057ef:	6a 71                	push   $0x71
  jmp alltraps
801057f1:	e9 d3 f7 ff ff       	jmp    80104fc9 <alltraps>

801057f6 <vector114>:
.globl vector114
vector114:
  pushl $0
801057f6:	6a 00                	push   $0x0
  pushl $114
801057f8:	6a 72                	push   $0x72
  jmp alltraps
801057fa:	e9 ca f7 ff ff       	jmp    80104fc9 <alltraps>

801057ff <vector115>:
.globl vector115
vector115:
  pushl $0
801057ff:	6a 00                	push   $0x0
  pushl $115
80105801:	6a 73                	push   $0x73
  jmp alltraps
80105803:	e9 c1 f7 ff ff       	jmp    80104fc9 <alltraps>

80105808 <vector116>:
.globl vector116
vector116:
  pushl $0
80105808:	6a 00                	push   $0x0
  pushl $116
8010580a:	6a 74                	push   $0x74
  jmp alltraps
8010580c:	e9 b8 f7 ff ff       	jmp    80104fc9 <alltraps>

80105811 <vector117>:
.globl vector117
vector117:
  pushl $0
80105811:	6a 00                	push   $0x0
  pushl $117
80105813:	6a 75                	push   $0x75
  jmp alltraps
80105815:	e9 af f7 ff ff       	jmp    80104fc9 <alltraps>

8010581a <vector118>:
.globl vector118
vector118:
  pushl $0
8010581a:	6a 00                	push   $0x0
  pushl $118
8010581c:	6a 76                	push   $0x76
  jmp alltraps
8010581e:	e9 a6 f7 ff ff       	jmp    80104fc9 <alltraps>

80105823 <vector119>:
.globl vector119
vector119:
  pushl $0
80105823:	6a 00                	push   $0x0
  pushl $119
80105825:	6a 77                	push   $0x77
  jmp alltraps
80105827:	e9 9d f7 ff ff       	jmp    80104fc9 <alltraps>

8010582c <vector120>:
.globl vector120
vector120:
  pushl $0
8010582c:	6a 00                	push   $0x0
  pushl $120
8010582e:	6a 78                	push   $0x78
  jmp alltraps
80105830:	e9 94 f7 ff ff       	jmp    80104fc9 <alltraps>

80105835 <vector121>:
.globl vector121
vector121:
  pushl $0
80105835:	6a 00                	push   $0x0
  pushl $121
80105837:	6a 79                	push   $0x79
  jmp alltraps
80105839:	e9 8b f7 ff ff       	jmp    80104fc9 <alltraps>

8010583e <vector122>:
.globl vector122
vector122:
  pushl $0
8010583e:	6a 00                	push   $0x0
  pushl $122
80105840:	6a 7a                	push   $0x7a
  jmp alltraps
80105842:	e9 82 f7 ff ff       	jmp    80104fc9 <alltraps>

80105847 <vector123>:
.globl vector123
vector123:
  pushl $0
80105847:	6a 00                	push   $0x0
  pushl $123
80105849:	6a 7b                	push   $0x7b
  jmp alltraps
8010584b:	e9 79 f7 ff ff       	jmp    80104fc9 <alltraps>

80105850 <vector124>:
.globl vector124
vector124:
  pushl $0
80105850:	6a 00                	push   $0x0
  pushl $124
80105852:	6a 7c                	push   $0x7c
  jmp alltraps
80105854:	e9 70 f7 ff ff       	jmp    80104fc9 <alltraps>

80105859 <vector125>:
.globl vector125
vector125:
  pushl $0
80105859:	6a 00                	push   $0x0
  pushl $125
8010585b:	6a 7d                	push   $0x7d
  jmp alltraps
8010585d:	e9 67 f7 ff ff       	jmp    80104fc9 <alltraps>

80105862 <vector126>:
.globl vector126
vector126:
  pushl $0
80105862:	6a 00                	push   $0x0
  pushl $126
80105864:	6a 7e                	push   $0x7e
  jmp alltraps
80105866:	e9 5e f7 ff ff       	jmp    80104fc9 <alltraps>

8010586b <vector127>:
.globl vector127
vector127:
  pushl $0
8010586b:	6a 00                	push   $0x0
  pushl $127
8010586d:	6a 7f                	push   $0x7f
  jmp alltraps
8010586f:	e9 55 f7 ff ff       	jmp    80104fc9 <alltraps>

80105874 <vector128>:
.globl vector128
vector128:
  pushl $0
80105874:	6a 00                	push   $0x0
  pushl $128
80105876:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010587b:	e9 49 f7 ff ff       	jmp    80104fc9 <alltraps>

80105880 <vector129>:
.globl vector129
vector129:
  pushl $0
80105880:	6a 00                	push   $0x0
  pushl $129
80105882:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105887:	e9 3d f7 ff ff       	jmp    80104fc9 <alltraps>

8010588c <vector130>:
.globl vector130
vector130:
  pushl $0
8010588c:	6a 00                	push   $0x0
  pushl $130
8010588e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105893:	e9 31 f7 ff ff       	jmp    80104fc9 <alltraps>

80105898 <vector131>:
.globl vector131
vector131:
  pushl $0
80105898:	6a 00                	push   $0x0
  pushl $131
8010589a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010589f:	e9 25 f7 ff ff       	jmp    80104fc9 <alltraps>

801058a4 <vector132>:
.globl vector132
vector132:
  pushl $0
801058a4:	6a 00                	push   $0x0
  pushl $132
801058a6:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801058ab:	e9 19 f7 ff ff       	jmp    80104fc9 <alltraps>

801058b0 <vector133>:
.globl vector133
vector133:
  pushl $0
801058b0:	6a 00                	push   $0x0
  pushl $133
801058b2:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801058b7:	e9 0d f7 ff ff       	jmp    80104fc9 <alltraps>

801058bc <vector134>:
.globl vector134
vector134:
  pushl $0
801058bc:	6a 00                	push   $0x0
  pushl $134
801058be:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801058c3:	e9 01 f7 ff ff       	jmp    80104fc9 <alltraps>

801058c8 <vector135>:
.globl vector135
vector135:
  pushl $0
801058c8:	6a 00                	push   $0x0
  pushl $135
801058ca:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801058cf:	e9 f5 f6 ff ff       	jmp    80104fc9 <alltraps>

801058d4 <vector136>:
.globl vector136
vector136:
  pushl $0
801058d4:	6a 00                	push   $0x0
  pushl $136
801058d6:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801058db:	e9 e9 f6 ff ff       	jmp    80104fc9 <alltraps>

801058e0 <vector137>:
.globl vector137
vector137:
  pushl $0
801058e0:	6a 00                	push   $0x0
  pushl $137
801058e2:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801058e7:	e9 dd f6 ff ff       	jmp    80104fc9 <alltraps>

801058ec <vector138>:
.globl vector138
vector138:
  pushl $0
801058ec:	6a 00                	push   $0x0
  pushl $138
801058ee:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801058f3:	e9 d1 f6 ff ff       	jmp    80104fc9 <alltraps>

801058f8 <vector139>:
.globl vector139
vector139:
  pushl $0
801058f8:	6a 00                	push   $0x0
  pushl $139
801058fa:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801058ff:	e9 c5 f6 ff ff       	jmp    80104fc9 <alltraps>

80105904 <vector140>:
.globl vector140
vector140:
  pushl $0
80105904:	6a 00                	push   $0x0
  pushl $140
80105906:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010590b:	e9 b9 f6 ff ff       	jmp    80104fc9 <alltraps>

80105910 <vector141>:
.globl vector141
vector141:
  pushl $0
80105910:	6a 00                	push   $0x0
  pushl $141
80105912:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105917:	e9 ad f6 ff ff       	jmp    80104fc9 <alltraps>

8010591c <vector142>:
.globl vector142
vector142:
  pushl $0
8010591c:	6a 00                	push   $0x0
  pushl $142
8010591e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105923:	e9 a1 f6 ff ff       	jmp    80104fc9 <alltraps>

80105928 <vector143>:
.globl vector143
vector143:
  pushl $0
80105928:	6a 00                	push   $0x0
  pushl $143
8010592a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010592f:	e9 95 f6 ff ff       	jmp    80104fc9 <alltraps>

80105934 <vector144>:
.globl vector144
vector144:
  pushl $0
80105934:	6a 00                	push   $0x0
  pushl $144
80105936:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010593b:	e9 89 f6 ff ff       	jmp    80104fc9 <alltraps>

80105940 <vector145>:
.globl vector145
vector145:
  pushl $0
80105940:	6a 00                	push   $0x0
  pushl $145
80105942:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105947:	e9 7d f6 ff ff       	jmp    80104fc9 <alltraps>

8010594c <vector146>:
.globl vector146
vector146:
  pushl $0
8010594c:	6a 00                	push   $0x0
  pushl $146
8010594e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105953:	e9 71 f6 ff ff       	jmp    80104fc9 <alltraps>

80105958 <vector147>:
.globl vector147
vector147:
  pushl $0
80105958:	6a 00                	push   $0x0
  pushl $147
8010595a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010595f:	e9 65 f6 ff ff       	jmp    80104fc9 <alltraps>

80105964 <vector148>:
.globl vector148
vector148:
  pushl $0
80105964:	6a 00                	push   $0x0
  pushl $148
80105966:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010596b:	e9 59 f6 ff ff       	jmp    80104fc9 <alltraps>

80105970 <vector149>:
.globl vector149
vector149:
  pushl $0
80105970:	6a 00                	push   $0x0
  pushl $149
80105972:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105977:	e9 4d f6 ff ff       	jmp    80104fc9 <alltraps>

8010597c <vector150>:
.globl vector150
vector150:
  pushl $0
8010597c:	6a 00                	push   $0x0
  pushl $150
8010597e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105983:	e9 41 f6 ff ff       	jmp    80104fc9 <alltraps>

80105988 <vector151>:
.globl vector151
vector151:
  pushl $0
80105988:	6a 00                	push   $0x0
  pushl $151
8010598a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010598f:	e9 35 f6 ff ff       	jmp    80104fc9 <alltraps>

80105994 <vector152>:
.globl vector152
vector152:
  pushl $0
80105994:	6a 00                	push   $0x0
  pushl $152
80105996:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010599b:	e9 29 f6 ff ff       	jmp    80104fc9 <alltraps>

801059a0 <vector153>:
.globl vector153
vector153:
  pushl $0
801059a0:	6a 00                	push   $0x0
  pushl $153
801059a2:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801059a7:	e9 1d f6 ff ff       	jmp    80104fc9 <alltraps>

801059ac <vector154>:
.globl vector154
vector154:
  pushl $0
801059ac:	6a 00                	push   $0x0
  pushl $154
801059ae:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801059b3:	e9 11 f6 ff ff       	jmp    80104fc9 <alltraps>

801059b8 <vector155>:
.globl vector155
vector155:
  pushl $0
801059b8:	6a 00                	push   $0x0
  pushl $155
801059ba:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801059bf:	e9 05 f6 ff ff       	jmp    80104fc9 <alltraps>

801059c4 <vector156>:
.globl vector156
vector156:
  pushl $0
801059c4:	6a 00                	push   $0x0
  pushl $156
801059c6:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801059cb:	e9 f9 f5 ff ff       	jmp    80104fc9 <alltraps>

801059d0 <vector157>:
.globl vector157
vector157:
  pushl $0
801059d0:	6a 00                	push   $0x0
  pushl $157
801059d2:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801059d7:	e9 ed f5 ff ff       	jmp    80104fc9 <alltraps>

801059dc <vector158>:
.globl vector158
vector158:
  pushl $0
801059dc:	6a 00                	push   $0x0
  pushl $158
801059de:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801059e3:	e9 e1 f5 ff ff       	jmp    80104fc9 <alltraps>

801059e8 <vector159>:
.globl vector159
vector159:
  pushl $0
801059e8:	6a 00                	push   $0x0
  pushl $159
801059ea:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801059ef:	e9 d5 f5 ff ff       	jmp    80104fc9 <alltraps>

801059f4 <vector160>:
.globl vector160
vector160:
  pushl $0
801059f4:	6a 00                	push   $0x0
  pushl $160
801059f6:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801059fb:	e9 c9 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a00 <vector161>:
.globl vector161
vector161:
  pushl $0
80105a00:	6a 00                	push   $0x0
  pushl $161
80105a02:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105a07:	e9 bd f5 ff ff       	jmp    80104fc9 <alltraps>

80105a0c <vector162>:
.globl vector162
vector162:
  pushl $0
80105a0c:	6a 00                	push   $0x0
  pushl $162
80105a0e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105a13:	e9 b1 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a18 <vector163>:
.globl vector163
vector163:
  pushl $0
80105a18:	6a 00                	push   $0x0
  pushl $163
80105a1a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105a1f:	e9 a5 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a24 <vector164>:
.globl vector164
vector164:
  pushl $0
80105a24:	6a 00                	push   $0x0
  pushl $164
80105a26:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105a2b:	e9 99 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a30 <vector165>:
.globl vector165
vector165:
  pushl $0
80105a30:	6a 00                	push   $0x0
  pushl $165
80105a32:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105a37:	e9 8d f5 ff ff       	jmp    80104fc9 <alltraps>

80105a3c <vector166>:
.globl vector166
vector166:
  pushl $0
80105a3c:	6a 00                	push   $0x0
  pushl $166
80105a3e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105a43:	e9 81 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a48 <vector167>:
.globl vector167
vector167:
  pushl $0
80105a48:	6a 00                	push   $0x0
  pushl $167
80105a4a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105a4f:	e9 75 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a54 <vector168>:
.globl vector168
vector168:
  pushl $0
80105a54:	6a 00                	push   $0x0
  pushl $168
80105a56:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105a5b:	e9 69 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a60 <vector169>:
.globl vector169
vector169:
  pushl $0
80105a60:	6a 00                	push   $0x0
  pushl $169
80105a62:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105a67:	e9 5d f5 ff ff       	jmp    80104fc9 <alltraps>

80105a6c <vector170>:
.globl vector170
vector170:
  pushl $0
80105a6c:	6a 00                	push   $0x0
  pushl $170
80105a6e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a73:	e9 51 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a78 <vector171>:
.globl vector171
vector171:
  pushl $0
80105a78:	6a 00                	push   $0x0
  pushl $171
80105a7a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a7f:	e9 45 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a84 <vector172>:
.globl vector172
vector172:
  pushl $0
80105a84:	6a 00                	push   $0x0
  pushl $172
80105a86:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a8b:	e9 39 f5 ff ff       	jmp    80104fc9 <alltraps>

80105a90 <vector173>:
.globl vector173
vector173:
  pushl $0
80105a90:	6a 00                	push   $0x0
  pushl $173
80105a92:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a97:	e9 2d f5 ff ff       	jmp    80104fc9 <alltraps>

80105a9c <vector174>:
.globl vector174
vector174:
  pushl $0
80105a9c:	6a 00                	push   $0x0
  pushl $174
80105a9e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105aa3:	e9 21 f5 ff ff       	jmp    80104fc9 <alltraps>

80105aa8 <vector175>:
.globl vector175
vector175:
  pushl $0
80105aa8:	6a 00                	push   $0x0
  pushl $175
80105aaa:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105aaf:	e9 15 f5 ff ff       	jmp    80104fc9 <alltraps>

80105ab4 <vector176>:
.globl vector176
vector176:
  pushl $0
80105ab4:	6a 00                	push   $0x0
  pushl $176
80105ab6:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105abb:	e9 09 f5 ff ff       	jmp    80104fc9 <alltraps>

80105ac0 <vector177>:
.globl vector177
vector177:
  pushl $0
80105ac0:	6a 00                	push   $0x0
  pushl $177
80105ac2:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105ac7:	e9 fd f4 ff ff       	jmp    80104fc9 <alltraps>

80105acc <vector178>:
.globl vector178
vector178:
  pushl $0
80105acc:	6a 00                	push   $0x0
  pushl $178
80105ace:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105ad3:	e9 f1 f4 ff ff       	jmp    80104fc9 <alltraps>

80105ad8 <vector179>:
.globl vector179
vector179:
  pushl $0
80105ad8:	6a 00                	push   $0x0
  pushl $179
80105ada:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105adf:	e9 e5 f4 ff ff       	jmp    80104fc9 <alltraps>

80105ae4 <vector180>:
.globl vector180
vector180:
  pushl $0
80105ae4:	6a 00                	push   $0x0
  pushl $180
80105ae6:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105aeb:	e9 d9 f4 ff ff       	jmp    80104fc9 <alltraps>

80105af0 <vector181>:
.globl vector181
vector181:
  pushl $0
80105af0:	6a 00                	push   $0x0
  pushl $181
80105af2:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105af7:	e9 cd f4 ff ff       	jmp    80104fc9 <alltraps>

80105afc <vector182>:
.globl vector182
vector182:
  pushl $0
80105afc:	6a 00                	push   $0x0
  pushl $182
80105afe:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105b03:	e9 c1 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b08 <vector183>:
.globl vector183
vector183:
  pushl $0
80105b08:	6a 00                	push   $0x0
  pushl $183
80105b0a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105b0f:	e9 b5 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b14 <vector184>:
.globl vector184
vector184:
  pushl $0
80105b14:	6a 00                	push   $0x0
  pushl $184
80105b16:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105b1b:	e9 a9 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b20 <vector185>:
.globl vector185
vector185:
  pushl $0
80105b20:	6a 00                	push   $0x0
  pushl $185
80105b22:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105b27:	e9 9d f4 ff ff       	jmp    80104fc9 <alltraps>

80105b2c <vector186>:
.globl vector186
vector186:
  pushl $0
80105b2c:	6a 00                	push   $0x0
  pushl $186
80105b2e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105b33:	e9 91 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b38 <vector187>:
.globl vector187
vector187:
  pushl $0
80105b38:	6a 00                	push   $0x0
  pushl $187
80105b3a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105b3f:	e9 85 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b44 <vector188>:
.globl vector188
vector188:
  pushl $0
80105b44:	6a 00                	push   $0x0
  pushl $188
80105b46:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105b4b:	e9 79 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b50 <vector189>:
.globl vector189
vector189:
  pushl $0
80105b50:	6a 00                	push   $0x0
  pushl $189
80105b52:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105b57:	e9 6d f4 ff ff       	jmp    80104fc9 <alltraps>

80105b5c <vector190>:
.globl vector190
vector190:
  pushl $0
80105b5c:	6a 00                	push   $0x0
  pushl $190
80105b5e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105b63:	e9 61 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b68 <vector191>:
.globl vector191
vector191:
  pushl $0
80105b68:	6a 00                	push   $0x0
  pushl $191
80105b6a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105b6f:	e9 55 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b74 <vector192>:
.globl vector192
vector192:
  pushl $0
80105b74:	6a 00                	push   $0x0
  pushl $192
80105b76:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b7b:	e9 49 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b80 <vector193>:
.globl vector193
vector193:
  pushl $0
80105b80:	6a 00                	push   $0x0
  pushl $193
80105b82:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b87:	e9 3d f4 ff ff       	jmp    80104fc9 <alltraps>

80105b8c <vector194>:
.globl vector194
vector194:
  pushl $0
80105b8c:	6a 00                	push   $0x0
  pushl $194
80105b8e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b93:	e9 31 f4 ff ff       	jmp    80104fc9 <alltraps>

80105b98 <vector195>:
.globl vector195
vector195:
  pushl $0
80105b98:	6a 00                	push   $0x0
  pushl $195
80105b9a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105b9f:	e9 25 f4 ff ff       	jmp    80104fc9 <alltraps>

80105ba4 <vector196>:
.globl vector196
vector196:
  pushl $0
80105ba4:	6a 00                	push   $0x0
  pushl $196
80105ba6:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105bab:	e9 19 f4 ff ff       	jmp    80104fc9 <alltraps>

80105bb0 <vector197>:
.globl vector197
vector197:
  pushl $0
80105bb0:	6a 00                	push   $0x0
  pushl $197
80105bb2:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105bb7:	e9 0d f4 ff ff       	jmp    80104fc9 <alltraps>

80105bbc <vector198>:
.globl vector198
vector198:
  pushl $0
80105bbc:	6a 00                	push   $0x0
  pushl $198
80105bbe:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105bc3:	e9 01 f4 ff ff       	jmp    80104fc9 <alltraps>

80105bc8 <vector199>:
.globl vector199
vector199:
  pushl $0
80105bc8:	6a 00                	push   $0x0
  pushl $199
80105bca:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105bcf:	e9 f5 f3 ff ff       	jmp    80104fc9 <alltraps>

80105bd4 <vector200>:
.globl vector200
vector200:
  pushl $0
80105bd4:	6a 00                	push   $0x0
  pushl $200
80105bd6:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105bdb:	e9 e9 f3 ff ff       	jmp    80104fc9 <alltraps>

80105be0 <vector201>:
.globl vector201
vector201:
  pushl $0
80105be0:	6a 00                	push   $0x0
  pushl $201
80105be2:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105be7:	e9 dd f3 ff ff       	jmp    80104fc9 <alltraps>

80105bec <vector202>:
.globl vector202
vector202:
  pushl $0
80105bec:	6a 00                	push   $0x0
  pushl $202
80105bee:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105bf3:	e9 d1 f3 ff ff       	jmp    80104fc9 <alltraps>

80105bf8 <vector203>:
.globl vector203
vector203:
  pushl $0
80105bf8:	6a 00                	push   $0x0
  pushl $203
80105bfa:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105bff:	e9 c5 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c04 <vector204>:
.globl vector204
vector204:
  pushl $0
80105c04:	6a 00                	push   $0x0
  pushl $204
80105c06:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105c0b:	e9 b9 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c10 <vector205>:
.globl vector205
vector205:
  pushl $0
80105c10:	6a 00                	push   $0x0
  pushl $205
80105c12:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105c17:	e9 ad f3 ff ff       	jmp    80104fc9 <alltraps>

80105c1c <vector206>:
.globl vector206
vector206:
  pushl $0
80105c1c:	6a 00                	push   $0x0
  pushl $206
80105c1e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105c23:	e9 a1 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c28 <vector207>:
.globl vector207
vector207:
  pushl $0
80105c28:	6a 00                	push   $0x0
  pushl $207
80105c2a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105c2f:	e9 95 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c34 <vector208>:
.globl vector208
vector208:
  pushl $0
80105c34:	6a 00                	push   $0x0
  pushl $208
80105c36:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105c3b:	e9 89 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c40 <vector209>:
.globl vector209
vector209:
  pushl $0
80105c40:	6a 00                	push   $0x0
  pushl $209
80105c42:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105c47:	e9 7d f3 ff ff       	jmp    80104fc9 <alltraps>

80105c4c <vector210>:
.globl vector210
vector210:
  pushl $0
80105c4c:	6a 00                	push   $0x0
  pushl $210
80105c4e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105c53:	e9 71 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c58 <vector211>:
.globl vector211
vector211:
  pushl $0
80105c58:	6a 00                	push   $0x0
  pushl $211
80105c5a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105c5f:	e9 65 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c64 <vector212>:
.globl vector212
vector212:
  pushl $0
80105c64:	6a 00                	push   $0x0
  pushl $212
80105c66:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105c6b:	e9 59 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c70 <vector213>:
.globl vector213
vector213:
  pushl $0
80105c70:	6a 00                	push   $0x0
  pushl $213
80105c72:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c77:	e9 4d f3 ff ff       	jmp    80104fc9 <alltraps>

80105c7c <vector214>:
.globl vector214
vector214:
  pushl $0
80105c7c:	6a 00                	push   $0x0
  pushl $214
80105c7e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c83:	e9 41 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c88 <vector215>:
.globl vector215
vector215:
  pushl $0
80105c88:	6a 00                	push   $0x0
  pushl $215
80105c8a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c8f:	e9 35 f3 ff ff       	jmp    80104fc9 <alltraps>

80105c94 <vector216>:
.globl vector216
vector216:
  pushl $0
80105c94:	6a 00                	push   $0x0
  pushl $216
80105c96:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c9b:	e9 29 f3 ff ff       	jmp    80104fc9 <alltraps>

80105ca0 <vector217>:
.globl vector217
vector217:
  pushl $0
80105ca0:	6a 00                	push   $0x0
  pushl $217
80105ca2:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105ca7:	e9 1d f3 ff ff       	jmp    80104fc9 <alltraps>

80105cac <vector218>:
.globl vector218
vector218:
  pushl $0
80105cac:	6a 00                	push   $0x0
  pushl $218
80105cae:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105cb3:	e9 11 f3 ff ff       	jmp    80104fc9 <alltraps>

80105cb8 <vector219>:
.globl vector219
vector219:
  pushl $0
80105cb8:	6a 00                	push   $0x0
  pushl $219
80105cba:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105cbf:	e9 05 f3 ff ff       	jmp    80104fc9 <alltraps>

80105cc4 <vector220>:
.globl vector220
vector220:
  pushl $0
80105cc4:	6a 00                	push   $0x0
  pushl $220
80105cc6:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105ccb:	e9 f9 f2 ff ff       	jmp    80104fc9 <alltraps>

80105cd0 <vector221>:
.globl vector221
vector221:
  pushl $0
80105cd0:	6a 00                	push   $0x0
  pushl $221
80105cd2:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105cd7:	e9 ed f2 ff ff       	jmp    80104fc9 <alltraps>

80105cdc <vector222>:
.globl vector222
vector222:
  pushl $0
80105cdc:	6a 00                	push   $0x0
  pushl $222
80105cde:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105ce3:	e9 e1 f2 ff ff       	jmp    80104fc9 <alltraps>

80105ce8 <vector223>:
.globl vector223
vector223:
  pushl $0
80105ce8:	6a 00                	push   $0x0
  pushl $223
80105cea:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105cef:	e9 d5 f2 ff ff       	jmp    80104fc9 <alltraps>

80105cf4 <vector224>:
.globl vector224
vector224:
  pushl $0
80105cf4:	6a 00                	push   $0x0
  pushl $224
80105cf6:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105cfb:	e9 c9 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d00 <vector225>:
.globl vector225
vector225:
  pushl $0
80105d00:	6a 00                	push   $0x0
  pushl $225
80105d02:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105d07:	e9 bd f2 ff ff       	jmp    80104fc9 <alltraps>

80105d0c <vector226>:
.globl vector226
vector226:
  pushl $0
80105d0c:	6a 00                	push   $0x0
  pushl $226
80105d0e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105d13:	e9 b1 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d18 <vector227>:
.globl vector227
vector227:
  pushl $0
80105d18:	6a 00                	push   $0x0
  pushl $227
80105d1a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105d1f:	e9 a5 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d24 <vector228>:
.globl vector228
vector228:
  pushl $0
80105d24:	6a 00                	push   $0x0
  pushl $228
80105d26:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105d2b:	e9 99 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d30 <vector229>:
.globl vector229
vector229:
  pushl $0
80105d30:	6a 00                	push   $0x0
  pushl $229
80105d32:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105d37:	e9 8d f2 ff ff       	jmp    80104fc9 <alltraps>

80105d3c <vector230>:
.globl vector230
vector230:
  pushl $0
80105d3c:	6a 00                	push   $0x0
  pushl $230
80105d3e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105d43:	e9 81 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d48 <vector231>:
.globl vector231
vector231:
  pushl $0
80105d48:	6a 00                	push   $0x0
  pushl $231
80105d4a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105d4f:	e9 75 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d54 <vector232>:
.globl vector232
vector232:
  pushl $0
80105d54:	6a 00                	push   $0x0
  pushl $232
80105d56:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105d5b:	e9 69 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d60 <vector233>:
.globl vector233
vector233:
  pushl $0
80105d60:	6a 00                	push   $0x0
  pushl $233
80105d62:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105d67:	e9 5d f2 ff ff       	jmp    80104fc9 <alltraps>

80105d6c <vector234>:
.globl vector234
vector234:
  pushl $0
80105d6c:	6a 00                	push   $0x0
  pushl $234
80105d6e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d73:	e9 51 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d78 <vector235>:
.globl vector235
vector235:
  pushl $0
80105d78:	6a 00                	push   $0x0
  pushl $235
80105d7a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d7f:	e9 45 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d84 <vector236>:
.globl vector236
vector236:
  pushl $0
80105d84:	6a 00                	push   $0x0
  pushl $236
80105d86:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d8b:	e9 39 f2 ff ff       	jmp    80104fc9 <alltraps>

80105d90 <vector237>:
.globl vector237
vector237:
  pushl $0
80105d90:	6a 00                	push   $0x0
  pushl $237
80105d92:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d97:	e9 2d f2 ff ff       	jmp    80104fc9 <alltraps>

80105d9c <vector238>:
.globl vector238
vector238:
  pushl $0
80105d9c:	6a 00                	push   $0x0
  pushl $238
80105d9e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105da3:	e9 21 f2 ff ff       	jmp    80104fc9 <alltraps>

80105da8 <vector239>:
.globl vector239
vector239:
  pushl $0
80105da8:	6a 00                	push   $0x0
  pushl $239
80105daa:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105daf:	e9 15 f2 ff ff       	jmp    80104fc9 <alltraps>

80105db4 <vector240>:
.globl vector240
vector240:
  pushl $0
80105db4:	6a 00                	push   $0x0
  pushl $240
80105db6:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105dbb:	e9 09 f2 ff ff       	jmp    80104fc9 <alltraps>

80105dc0 <vector241>:
.globl vector241
vector241:
  pushl $0
80105dc0:	6a 00                	push   $0x0
  pushl $241
80105dc2:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105dc7:	e9 fd f1 ff ff       	jmp    80104fc9 <alltraps>

80105dcc <vector242>:
.globl vector242
vector242:
  pushl $0
80105dcc:	6a 00                	push   $0x0
  pushl $242
80105dce:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105dd3:	e9 f1 f1 ff ff       	jmp    80104fc9 <alltraps>

80105dd8 <vector243>:
.globl vector243
vector243:
  pushl $0
80105dd8:	6a 00                	push   $0x0
  pushl $243
80105dda:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105ddf:	e9 e5 f1 ff ff       	jmp    80104fc9 <alltraps>

80105de4 <vector244>:
.globl vector244
vector244:
  pushl $0
80105de4:	6a 00                	push   $0x0
  pushl $244
80105de6:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105deb:	e9 d9 f1 ff ff       	jmp    80104fc9 <alltraps>

80105df0 <vector245>:
.globl vector245
vector245:
  pushl $0
80105df0:	6a 00                	push   $0x0
  pushl $245
80105df2:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105df7:	e9 cd f1 ff ff       	jmp    80104fc9 <alltraps>

80105dfc <vector246>:
.globl vector246
vector246:
  pushl $0
80105dfc:	6a 00                	push   $0x0
  pushl $246
80105dfe:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105e03:	e9 c1 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e08 <vector247>:
.globl vector247
vector247:
  pushl $0
80105e08:	6a 00                	push   $0x0
  pushl $247
80105e0a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105e0f:	e9 b5 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e14 <vector248>:
.globl vector248
vector248:
  pushl $0
80105e14:	6a 00                	push   $0x0
  pushl $248
80105e16:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105e1b:	e9 a9 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e20 <vector249>:
.globl vector249
vector249:
  pushl $0
80105e20:	6a 00                	push   $0x0
  pushl $249
80105e22:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105e27:	e9 9d f1 ff ff       	jmp    80104fc9 <alltraps>

80105e2c <vector250>:
.globl vector250
vector250:
  pushl $0
80105e2c:	6a 00                	push   $0x0
  pushl $250
80105e2e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105e33:	e9 91 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e38 <vector251>:
.globl vector251
vector251:
  pushl $0
80105e38:	6a 00                	push   $0x0
  pushl $251
80105e3a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105e3f:	e9 85 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e44 <vector252>:
.globl vector252
vector252:
  pushl $0
80105e44:	6a 00                	push   $0x0
  pushl $252
80105e46:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105e4b:	e9 79 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e50 <vector253>:
.globl vector253
vector253:
  pushl $0
80105e50:	6a 00                	push   $0x0
  pushl $253
80105e52:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105e57:	e9 6d f1 ff ff       	jmp    80104fc9 <alltraps>

80105e5c <vector254>:
.globl vector254
vector254:
  pushl $0
80105e5c:	6a 00                	push   $0x0
  pushl $254
80105e5e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105e63:	e9 61 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e68 <vector255>:
.globl vector255
vector255:
  pushl $0
80105e68:	6a 00                	push   $0x0
  pushl $255
80105e6a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105e6f:	e9 55 f1 ff ff       	jmp    80104fc9 <alltraps>

80105e74 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e74:	55                   	push   %ebp
80105e75:	89 e5                	mov    %esp,%ebp
80105e77:	57                   	push   %edi
80105e78:	56                   	push   %esi
80105e79:	53                   	push   %ebx
80105e7a:	83 ec 0c             	sub    $0xc,%esp
80105e7d:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e7f:	c1 ea 16             	shr    $0x16,%edx
80105e82:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105e85:	8b 1f                	mov    (%edi),%ebx
80105e87:	f6 c3 01             	test   $0x1,%bl
80105e8a:	74 22                	je     80105eae <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105e8c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105e92:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e98:	c1 ee 0c             	shr    $0xc,%esi
80105e9b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105ea1:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105ea4:	89 d8                	mov    %ebx,%eax
80105ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ea9:	5b                   	pop    %ebx
80105eaa:	5e                   	pop    %esi
80105eab:	5f                   	pop    %edi
80105eac:	5d                   	pop    %ebp
80105ead:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105eae:	85 c9                	test   %ecx,%ecx
80105eb0:	74 2b                	je     80105edd <walkpgdir+0x69>
80105eb2:	e8 04 c2 ff ff       	call   801020bb <kalloc>
80105eb7:	89 c3                	mov    %eax,%ebx
80105eb9:	85 c0                	test   %eax,%eax
80105ebb:	74 e7                	je     80105ea4 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105ebd:	83 ec 04             	sub    $0x4,%esp
80105ec0:	68 00 10 00 00       	push   $0x1000
80105ec5:	6a 00                	push   $0x0
80105ec7:	50                   	push   %eax
80105ec8:	e8 f7 df ff ff       	call   80103ec4 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ecd:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105ed3:	83 c8 07             	or     $0x7,%eax
80105ed6:	89 07                	mov    %eax,(%edi)
80105ed8:	83 c4 10             	add    $0x10,%esp
80105edb:	eb bb                	jmp    80105e98 <walkpgdir+0x24>
      return 0;
80105edd:	bb 00 00 00 00       	mov    $0x0,%ebx
80105ee2:	eb c0                	jmp    80105ea4 <walkpgdir+0x30>

80105ee4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105ee4:	55                   	push   %ebp
80105ee5:	89 e5                	mov    %esp,%ebp
80105ee7:	57                   	push   %edi
80105ee8:	56                   	push   %esi
80105ee9:	53                   	push   %ebx
80105eea:	83 ec 1c             	sub    $0x1c,%esp
80105eed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ef0:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ef3:	89 d3                	mov    %edx,%ebx
80105ef5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105efb:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105eff:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f05:	b9 01 00 00 00       	mov    $0x1,%ecx
80105f0a:	89 da                	mov    %ebx,%edx
80105f0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f0f:	e8 60 ff ff ff       	call   80105e74 <walkpgdir>
80105f14:	85 c0                	test   %eax,%eax
80105f16:	74 2e                	je     80105f46 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105f18:	f6 00 01             	testb  $0x1,(%eax)
80105f1b:	75 1c                	jne    80105f39 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105f1d:	89 f2                	mov    %esi,%edx
80105f1f:	0b 55 0c             	or     0xc(%ebp),%edx
80105f22:	83 ca 01             	or     $0x1,%edx
80105f25:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105f27:	39 fb                	cmp    %edi,%ebx
80105f29:	74 28                	je     80105f53 <mappages+0x6f>
      break;
    a += PGSIZE;
80105f2b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105f31:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f37:	eb cc                	jmp    80105f05 <mappages+0x21>
      panic("remap");
80105f39:	83 ec 0c             	sub    $0xc,%esp
80105f3c:	68 6c 70 10 80       	push   $0x8010706c
80105f41:	e8 02 a4 ff ff       	call   80100348 <panic>
      return -1;
80105f46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f4e:	5b                   	pop    %ebx
80105f4f:	5e                   	pop    %esi
80105f50:	5f                   	pop    %edi
80105f51:	5d                   	pop    %ebp
80105f52:	c3                   	ret    
  return 0;
80105f53:	b8 00 00 00 00       	mov    $0x0,%eax
80105f58:	eb f1                	jmp    80105f4b <mappages+0x67>

80105f5a <seginit>:
{
80105f5a:	55                   	push   %ebp
80105f5b:	89 e5                	mov    %esp,%ebp
80105f5d:	53                   	push   %ebx
80105f5e:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105f61:	e8 87 d4 ff ff       	call   801033ed <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f66:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f6c:	66 c7 80 18 e6 1b 80 	movw   $0xffff,-0x7fe419e8(%eax)
80105f73:	ff ff 
80105f75:	66 c7 80 1a e6 1b 80 	movw   $0x0,-0x7fe419e6(%eax)
80105f7c:	00 00 
80105f7e:	c6 80 1c e6 1b 80 00 	movb   $0x0,-0x7fe419e4(%eax)
80105f85:	0f b6 88 1d e6 1b 80 	movzbl -0x7fe419e3(%eax),%ecx
80105f8c:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f8f:	83 c9 1a             	or     $0x1a,%ecx
80105f92:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f95:	83 c9 80             	or     $0xffffff80,%ecx
80105f98:	88 88 1d e6 1b 80    	mov    %cl,-0x7fe419e3(%eax)
80105f9e:	0f b6 88 1e e6 1b 80 	movzbl -0x7fe419e2(%eax),%ecx
80105fa5:	83 c9 0f             	or     $0xf,%ecx
80105fa8:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fab:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fae:	88 88 1e e6 1b 80    	mov    %cl,-0x7fe419e2(%eax)
80105fb4:	c6 80 1f e6 1b 80 00 	movb   $0x0,-0x7fe419e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105fbb:	66 c7 80 20 e6 1b 80 	movw   $0xffff,-0x7fe419e0(%eax)
80105fc2:	ff ff 
80105fc4:	66 c7 80 22 e6 1b 80 	movw   $0x0,-0x7fe419de(%eax)
80105fcb:	00 00 
80105fcd:	c6 80 24 e6 1b 80 00 	movb   $0x0,-0x7fe419dc(%eax)
80105fd4:	0f b6 88 25 e6 1b 80 	movzbl -0x7fe419db(%eax),%ecx
80105fdb:	83 e1 f0             	and    $0xfffffff0,%ecx
80105fde:	83 c9 12             	or     $0x12,%ecx
80105fe1:	83 e1 9f             	and    $0xffffff9f,%ecx
80105fe4:	83 c9 80             	or     $0xffffff80,%ecx
80105fe7:	88 88 25 e6 1b 80    	mov    %cl,-0x7fe419db(%eax)
80105fed:	0f b6 88 26 e6 1b 80 	movzbl -0x7fe419da(%eax),%ecx
80105ff4:	83 c9 0f             	or     $0xf,%ecx
80105ff7:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ffa:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ffd:	88 88 26 e6 1b 80    	mov    %cl,-0x7fe419da(%eax)
80106003:	c6 80 27 e6 1b 80 00 	movb   $0x0,-0x7fe419d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010600a:	66 c7 80 28 e6 1b 80 	movw   $0xffff,-0x7fe419d8(%eax)
80106011:	ff ff 
80106013:	66 c7 80 2a e6 1b 80 	movw   $0x0,-0x7fe419d6(%eax)
8010601a:	00 00 
8010601c:	c6 80 2c e6 1b 80 00 	movb   $0x0,-0x7fe419d4(%eax)
80106023:	c6 80 2d e6 1b 80 fa 	movb   $0xfa,-0x7fe419d3(%eax)
8010602a:	0f b6 88 2e e6 1b 80 	movzbl -0x7fe419d2(%eax),%ecx
80106031:	83 c9 0f             	or     $0xf,%ecx
80106034:	83 e1 cf             	and    $0xffffffcf,%ecx
80106037:	83 c9 c0             	or     $0xffffffc0,%ecx
8010603a:	88 88 2e e6 1b 80    	mov    %cl,-0x7fe419d2(%eax)
80106040:	c6 80 2f e6 1b 80 00 	movb   $0x0,-0x7fe419d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106047:	66 c7 80 30 e6 1b 80 	movw   $0xffff,-0x7fe419d0(%eax)
8010604e:	ff ff 
80106050:	66 c7 80 32 e6 1b 80 	movw   $0x0,-0x7fe419ce(%eax)
80106057:	00 00 
80106059:	c6 80 34 e6 1b 80 00 	movb   $0x0,-0x7fe419cc(%eax)
80106060:	c6 80 35 e6 1b 80 f2 	movb   $0xf2,-0x7fe419cb(%eax)
80106067:	0f b6 88 36 e6 1b 80 	movzbl -0x7fe419ca(%eax),%ecx
8010606e:	83 c9 0f             	or     $0xf,%ecx
80106071:	83 e1 cf             	and    $0xffffffcf,%ecx
80106074:	83 c9 c0             	or     $0xffffffc0,%ecx
80106077:	88 88 36 e6 1b 80    	mov    %cl,-0x7fe419ca(%eax)
8010607d:	c6 80 37 e6 1b 80 00 	movb   $0x0,-0x7fe419c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106084:	05 10 e6 1b 80       	add    $0x801be610,%eax
  pd[0] = size-1;
80106089:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
8010608f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106093:	c1 e8 10             	shr    $0x10,%eax
80106096:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010609a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010609d:	0f 01 10             	lgdtl  (%eax)
}
801060a0:	83 c4 14             	add    $0x14,%esp
801060a3:	5b                   	pop    %ebx
801060a4:	5d                   	pop    %ebp
801060a5:	c3                   	ret    

801060a6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801060a6:	55                   	push   %ebp
801060a7:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801060a9:	a1 c4 12 1c 80       	mov    0x801c12c4,%eax
801060ae:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060b3:	0f 22 d8             	mov    %eax,%cr3
}
801060b6:	5d                   	pop    %ebp
801060b7:	c3                   	ret    

801060b8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801060b8:	55                   	push   %ebp
801060b9:	89 e5                	mov    %esp,%ebp
801060bb:	57                   	push   %edi
801060bc:	56                   	push   %esi
801060bd:	53                   	push   %ebx
801060be:	83 ec 1c             	sub    $0x1c,%esp
801060c1:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801060c4:	85 f6                	test   %esi,%esi
801060c6:	0f 84 dd 00 00 00    	je     801061a9 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801060cc:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801060d0:	0f 84 e0 00 00 00    	je     801061b6 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801060d6:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801060da:	0f 84 e3 00 00 00    	je     801061c3 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
801060e0:	e8 56 dc ff ff       	call   80103d3b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801060e5:	e8 a7 d2 ff ff       	call   80103391 <mycpu>
801060ea:	89 c3                	mov    %eax,%ebx
801060ec:	e8 a0 d2 ff ff       	call   80103391 <mycpu>
801060f1:	8d 78 08             	lea    0x8(%eax),%edi
801060f4:	e8 98 d2 ff ff       	call   80103391 <mycpu>
801060f9:	83 c0 08             	add    $0x8,%eax
801060fc:	c1 e8 10             	shr    $0x10,%eax
801060ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106102:	e8 8a d2 ff ff       	call   80103391 <mycpu>
80106107:	83 c0 08             	add    $0x8,%eax
8010610a:	c1 e8 18             	shr    $0x18,%eax
8010610d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106114:	67 00 
80106116:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010611d:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106121:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106127:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010612e:	83 e2 f0             	and    $0xfffffff0,%edx
80106131:	83 ca 19             	or     $0x19,%edx
80106134:	83 e2 9f             	and    $0xffffff9f,%edx
80106137:	83 ca 80             	or     $0xffffff80,%edx
8010613a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106140:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106147:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010614d:	e8 3f d2 ff ff       	call   80103391 <mycpu>
80106152:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106159:	83 e2 ef             	and    $0xffffffef,%edx
8010615c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106162:	e8 2a d2 ff ff       	call   80103391 <mycpu>
80106167:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010616d:	8b 5e 08             	mov    0x8(%esi),%ebx
80106170:	e8 1c d2 ff ff       	call   80103391 <mycpu>
80106175:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010617b:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010617e:	e8 0e d2 ff ff       	call   80103391 <mycpu>
80106183:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106189:	b8 28 00 00 00       	mov    $0x28,%eax
8010618e:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106191:	8b 46 04             	mov    0x4(%esi),%eax
80106194:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106199:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010619c:	e8 d7 db ff ff       	call   80103d78 <popcli>
}
801061a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061a4:	5b                   	pop    %ebx
801061a5:	5e                   	pop    %esi
801061a6:	5f                   	pop    %edi
801061a7:	5d                   	pop    %ebp
801061a8:	c3                   	ret    
    panic("switchuvm: no process");
801061a9:	83 ec 0c             	sub    $0xc,%esp
801061ac:	68 72 70 10 80       	push   $0x80107072
801061b1:	e8 92 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801061b6:	83 ec 0c             	sub    $0xc,%esp
801061b9:	68 88 70 10 80       	push   $0x80107088
801061be:	e8 85 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801061c3:	83 ec 0c             	sub    $0xc,%esp
801061c6:	68 9d 70 10 80       	push   $0x8010709d
801061cb:	e8 78 a1 ff ff       	call   80100348 <panic>

801061d0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061d0:	55                   	push   %ebp
801061d1:	89 e5                	mov    %esp,%ebp
801061d3:	56                   	push   %esi
801061d4:	53                   	push   %ebx
801061d5:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061d8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061de:	77 4c                	ja     8010622c <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
801061e0:	e8 d6 be ff ff       	call   801020bb <kalloc>
801061e5:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061e7:	83 ec 04             	sub    $0x4,%esp
801061ea:	68 00 10 00 00       	push   $0x1000
801061ef:	6a 00                	push   $0x0
801061f1:	50                   	push   %eax
801061f2:	e8 cd dc ff ff       	call   80103ec4 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801061f7:	83 c4 08             	add    $0x8,%esp
801061fa:	6a 06                	push   $0x6
801061fc:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106202:	50                   	push   %eax
80106203:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106208:	ba 00 00 00 00       	mov    $0x0,%edx
8010620d:	8b 45 08             	mov    0x8(%ebp),%eax
80106210:	e8 cf fc ff ff       	call   80105ee4 <mappages>
  memmove(mem, init, sz);
80106215:	83 c4 0c             	add    $0xc,%esp
80106218:	56                   	push   %esi
80106219:	ff 75 0c             	pushl  0xc(%ebp)
8010621c:	53                   	push   %ebx
8010621d:	e8 1d dd ff ff       	call   80103f3f <memmove>
}
80106222:	83 c4 10             	add    $0x10,%esp
80106225:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106228:	5b                   	pop    %ebx
80106229:	5e                   	pop    %esi
8010622a:	5d                   	pop    %ebp
8010622b:	c3                   	ret    
    panic("inituvm: more than a page");
8010622c:	83 ec 0c             	sub    $0xc,%esp
8010622f:	68 b1 70 10 80       	push   $0x801070b1
80106234:	e8 0f a1 ff ff       	call   80100348 <panic>

80106239 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106239:	55                   	push   %ebp
8010623a:	89 e5                	mov    %esp,%ebp
8010623c:	57                   	push   %edi
8010623d:	56                   	push   %esi
8010623e:	53                   	push   %ebx
8010623f:	83 ec 0c             	sub    $0xc,%esp
80106242:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106245:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010624c:	75 07                	jne    80106255 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010624e:	bb 00 00 00 00       	mov    $0x0,%ebx
80106253:	eb 3c                	jmp    80106291 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106255:	83 ec 0c             	sub    $0xc,%esp
80106258:	68 6c 71 10 80       	push   $0x8010716c
8010625d:	e8 e6 a0 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106262:	83 ec 0c             	sub    $0xc,%esp
80106265:	68 cb 70 10 80       	push   $0x801070cb
8010626a:	e8 d9 a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010626f:	05 00 00 00 80       	add    $0x80000000,%eax
80106274:	56                   	push   %esi
80106275:	89 da                	mov    %ebx,%edx
80106277:	03 55 14             	add    0x14(%ebp),%edx
8010627a:	52                   	push   %edx
8010627b:	50                   	push   %eax
8010627c:	ff 75 10             	pushl  0x10(%ebp)
8010627f:	e8 ef b4 ff ff       	call   80101773 <readi>
80106284:	83 c4 10             	add    $0x10,%esp
80106287:	39 f0                	cmp    %esi,%eax
80106289:	75 47                	jne    801062d2 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010628b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106291:	39 fb                	cmp    %edi,%ebx
80106293:	73 30                	jae    801062c5 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106295:	89 da                	mov    %ebx,%edx
80106297:	03 55 0c             	add    0xc(%ebp),%edx
8010629a:	b9 00 00 00 00       	mov    $0x0,%ecx
8010629f:	8b 45 08             	mov    0x8(%ebp),%eax
801062a2:	e8 cd fb ff ff       	call   80105e74 <walkpgdir>
801062a7:	85 c0                	test   %eax,%eax
801062a9:	74 b7                	je     80106262 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801062ab:	8b 00                	mov    (%eax),%eax
801062ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062b2:	89 fe                	mov    %edi,%esi
801062b4:	29 de                	sub    %ebx,%esi
801062b6:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062bc:	76 b1                	jbe    8010626f <loaduvm+0x36>
      n = PGSIZE;
801062be:	be 00 10 00 00       	mov    $0x1000,%esi
801062c3:	eb aa                	jmp    8010626f <loaduvm+0x36>
      return -1;
  }
  return 0;
801062c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062cd:	5b                   	pop    %ebx
801062ce:	5e                   	pop    %esi
801062cf:	5f                   	pop    %edi
801062d0:	5d                   	pop    %ebp
801062d1:	c3                   	ret    
      return -1;
801062d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d7:	eb f1                	jmp    801062ca <loaduvm+0x91>

801062d9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062d9:	55                   	push   %ebp
801062da:	89 e5                	mov    %esp,%ebp
801062dc:	57                   	push   %edi
801062dd:	56                   	push   %esi
801062de:	53                   	push   %ebx
801062df:	83 ec 0c             	sub    $0xc,%esp
801062e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801062e5:	39 7d 10             	cmp    %edi,0x10(%ebp)
801062e8:	73 11                	jae    801062fb <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801062ea:	8b 45 10             	mov    0x10(%ebp),%eax
801062ed:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062f3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062f9:	eb 19                	jmp    80106314 <deallocuvm+0x3b>
    return oldsz;
801062fb:	89 f8                	mov    %edi,%eax
801062fd:	eb 64                	jmp    80106363 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801062ff:	c1 eb 16             	shr    $0x16,%ebx
80106302:	83 c3 01             	add    $0x1,%ebx
80106305:	c1 e3 16             	shl    $0x16,%ebx
80106308:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010630e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106314:	39 fb                	cmp    %edi,%ebx
80106316:	73 48                	jae    80106360 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106318:	b9 00 00 00 00       	mov    $0x0,%ecx
8010631d:	89 da                	mov    %ebx,%edx
8010631f:	8b 45 08             	mov    0x8(%ebp),%eax
80106322:	e8 4d fb ff ff       	call   80105e74 <walkpgdir>
80106327:	89 c6                	mov    %eax,%esi
    if(!pte)
80106329:	85 c0                	test   %eax,%eax
8010632b:	74 d2                	je     801062ff <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010632d:	8b 00                	mov    (%eax),%eax
8010632f:	a8 01                	test   $0x1,%al
80106331:	74 db                	je     8010630e <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106333:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106338:	74 19                	je     80106353 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010633a:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010633f:	83 ec 0c             	sub    $0xc,%esp
80106342:	50                   	push   %eax
80106343:	e8 5c bc ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106348:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010634e:	83 c4 10             	add    $0x10,%esp
80106351:	eb bb                	jmp    8010630e <deallocuvm+0x35>
        panic("kfree");
80106353:	83 ec 0c             	sub    $0xc,%esp
80106356:	68 86 69 10 80       	push   $0x80106986
8010635b:	e8 e8 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106360:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106363:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106366:	5b                   	pop    %ebx
80106367:	5e                   	pop    %esi
80106368:	5f                   	pop    %edi
80106369:	5d                   	pop    %ebp
8010636a:	c3                   	ret    

8010636b <allocuvm>:
{
8010636b:	55                   	push   %ebp
8010636c:	89 e5                	mov    %esp,%ebp
8010636e:	57                   	push   %edi
8010636f:	56                   	push   %esi
80106370:	53                   	push   %ebx
80106371:	83 ec 1c             	sub    $0x1c,%esp
80106374:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106377:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010637a:	85 ff                	test   %edi,%edi
8010637c:	0f 88 c1 00 00 00    	js     80106443 <allocuvm+0xd8>
  if(newsz < oldsz)
80106382:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106385:	72 5c                	jb     801063e3 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010638a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106390:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106396:	39 fb                	cmp    %edi,%ebx
80106398:	0f 83 ac 00 00 00    	jae    8010644a <allocuvm+0xdf>
    mem = kalloc();
8010639e:	e8 18 bd ff ff       	call   801020bb <kalloc>
801063a3:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801063a5:	85 c0                	test   %eax,%eax
801063a7:	74 42                	je     801063eb <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
801063a9:	83 ec 04             	sub    $0x4,%esp
801063ac:	68 00 10 00 00       	push   $0x1000
801063b1:	6a 00                	push   $0x0
801063b3:	50                   	push   %eax
801063b4:	e8 0b db ff ff       	call   80103ec4 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063b9:	83 c4 08             	add    $0x8,%esp
801063bc:	6a 06                	push   $0x6
801063be:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801063c4:	50                   	push   %eax
801063c5:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063ca:	89 da                	mov    %ebx,%edx
801063cc:	8b 45 08             	mov    0x8(%ebp),%eax
801063cf:	e8 10 fb ff ff       	call   80105ee4 <mappages>
801063d4:	83 c4 10             	add    $0x10,%esp
801063d7:	85 c0                	test   %eax,%eax
801063d9:	78 38                	js     80106413 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801063db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063e1:	eb b3                	jmp    80106396 <allocuvm+0x2b>
    return oldsz;
801063e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801063e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801063e9:	eb 5f                	jmp    8010644a <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801063eb:	83 ec 0c             	sub    $0xc,%esp
801063ee:	68 e9 70 10 80       	push   $0x801070e9
801063f3:	e8 13 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801063f8:	83 c4 0c             	add    $0xc,%esp
801063fb:	ff 75 0c             	pushl  0xc(%ebp)
801063fe:	57                   	push   %edi
801063ff:	ff 75 08             	pushl  0x8(%ebp)
80106402:	e8 d2 fe ff ff       	call   801062d9 <deallocuvm>
      return 0;
80106407:	83 c4 10             	add    $0x10,%esp
8010640a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106411:	eb 37                	jmp    8010644a <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106413:	83 ec 0c             	sub    $0xc,%esp
80106416:	68 01 71 10 80       	push   $0x80107101
8010641b:	e8 eb a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106420:	83 c4 0c             	add    $0xc,%esp
80106423:	ff 75 0c             	pushl  0xc(%ebp)
80106426:	57                   	push   %edi
80106427:	ff 75 08             	pushl  0x8(%ebp)
8010642a:	e8 aa fe ff ff       	call   801062d9 <deallocuvm>
      kfree(mem);
8010642f:	89 34 24             	mov    %esi,(%esp)
80106432:	e8 6d bb ff ff       	call   80101fa4 <kfree>
      return 0;
80106437:	83 c4 10             	add    $0x10,%esp
8010643a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106441:	eb 07                	jmp    8010644a <allocuvm+0xdf>
    return 0;
80106443:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010644a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106450:	5b                   	pop    %ebx
80106451:	5e                   	pop    %esi
80106452:	5f                   	pop    %edi
80106453:	5d                   	pop    %ebp
80106454:	c3                   	ret    

80106455 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106455:	55                   	push   %ebp
80106456:	89 e5                	mov    %esp,%ebp
80106458:	56                   	push   %esi
80106459:	53                   	push   %ebx
8010645a:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010645d:	85 f6                	test   %esi,%esi
8010645f:	74 1a                	je     8010647b <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106461:	83 ec 04             	sub    $0x4,%esp
80106464:	6a 00                	push   $0x0
80106466:	68 00 00 00 80       	push   $0x80000000
8010646b:	56                   	push   %esi
8010646c:	e8 68 fe ff ff       	call   801062d9 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106471:	83 c4 10             	add    $0x10,%esp
80106474:	bb 00 00 00 00       	mov    $0x0,%ebx
80106479:	eb 10                	jmp    8010648b <freevm+0x36>
    panic("freevm: no pgdir");
8010647b:	83 ec 0c             	sub    $0xc,%esp
8010647e:	68 1d 71 10 80       	push   $0x8010711d
80106483:	e8 c0 9e ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106488:	83 c3 01             	add    $0x1,%ebx
8010648b:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106491:	77 1f                	ja     801064b2 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106493:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106496:	a8 01                	test   $0x1,%al
80106498:	74 ee                	je     80106488 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010649a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010649f:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801064a4:	83 ec 0c             	sub    $0xc,%esp
801064a7:	50                   	push   %eax
801064a8:	e8 f7 ba ff ff       	call   80101fa4 <kfree>
801064ad:	83 c4 10             	add    $0x10,%esp
801064b0:	eb d6                	jmp    80106488 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801064b2:	83 ec 0c             	sub    $0xc,%esp
801064b5:	56                   	push   %esi
801064b6:	e8 e9 ba ff ff       	call   80101fa4 <kfree>
}
801064bb:	83 c4 10             	add    $0x10,%esp
801064be:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064c1:	5b                   	pop    %ebx
801064c2:	5e                   	pop    %esi
801064c3:	5d                   	pop    %ebp
801064c4:	c3                   	ret    

801064c5 <setupkvm>:
{
801064c5:	55                   	push   %ebp
801064c6:	89 e5                	mov    %esp,%ebp
801064c8:	56                   	push   %esi
801064c9:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801064ca:	e8 ec bb ff ff       	call   801020bb <kalloc>
801064cf:	89 c6                	mov    %eax,%esi
801064d1:	85 c0                	test   %eax,%eax
801064d3:	74 55                	je     8010652a <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801064d5:	83 ec 04             	sub    $0x4,%esp
801064d8:	68 00 10 00 00       	push   $0x1000
801064dd:	6a 00                	push   $0x0
801064df:	50                   	push   %eax
801064e0:	e8 df d9 ff ff       	call   80103ec4 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801064e5:	83 c4 10             	add    $0x10,%esp
801064e8:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801064ed:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801064f3:	73 35                	jae    8010652a <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801064f5:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801064f8:	8b 4b 08             	mov    0x8(%ebx),%ecx
801064fb:	29 c1                	sub    %eax,%ecx
801064fd:	83 ec 08             	sub    $0x8,%esp
80106500:	ff 73 0c             	pushl  0xc(%ebx)
80106503:	50                   	push   %eax
80106504:	8b 13                	mov    (%ebx),%edx
80106506:	89 f0                	mov    %esi,%eax
80106508:	e8 d7 f9 ff ff       	call   80105ee4 <mappages>
8010650d:	83 c4 10             	add    $0x10,%esp
80106510:	85 c0                	test   %eax,%eax
80106512:	78 05                	js     80106519 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106514:	83 c3 10             	add    $0x10,%ebx
80106517:	eb d4                	jmp    801064ed <setupkvm+0x28>
      freevm(pgdir);
80106519:	83 ec 0c             	sub    $0xc,%esp
8010651c:	56                   	push   %esi
8010651d:	e8 33 ff ff ff       	call   80106455 <freevm>
      return 0;
80106522:	83 c4 10             	add    $0x10,%esp
80106525:	be 00 00 00 00       	mov    $0x0,%esi
}
8010652a:	89 f0                	mov    %esi,%eax
8010652c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010652f:	5b                   	pop    %ebx
80106530:	5e                   	pop    %esi
80106531:	5d                   	pop    %ebp
80106532:	c3                   	ret    

80106533 <kvmalloc>:
{
80106533:	55                   	push   %ebp
80106534:	89 e5                	mov    %esp,%ebp
80106536:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106539:	e8 87 ff ff ff       	call   801064c5 <setupkvm>
8010653e:	a3 c4 12 1c 80       	mov    %eax,0x801c12c4
  switchkvm();
80106543:	e8 5e fb ff ff       	call   801060a6 <switchkvm>
}
80106548:	c9                   	leave  
80106549:	c3                   	ret    

8010654a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010654a:	55                   	push   %ebp
8010654b:	89 e5                	mov    %esp,%ebp
8010654d:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106550:	b9 00 00 00 00       	mov    $0x0,%ecx
80106555:	8b 55 0c             	mov    0xc(%ebp),%edx
80106558:	8b 45 08             	mov    0x8(%ebp),%eax
8010655b:	e8 14 f9 ff ff       	call   80105e74 <walkpgdir>
  if(pte == 0)
80106560:	85 c0                	test   %eax,%eax
80106562:	74 05                	je     80106569 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106564:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106567:	c9                   	leave  
80106568:	c3                   	ret    
    panic("clearpteu");
80106569:	83 ec 0c             	sub    $0xc,%esp
8010656c:	68 2e 71 10 80       	push   $0x8010712e
80106571:	e8 d2 9d ff ff       	call   80100348 <panic>

80106576 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106576:	55                   	push   %ebp
80106577:	89 e5                	mov    %esp,%ebp
80106579:	57                   	push   %edi
8010657a:	56                   	push   %esi
8010657b:	53                   	push   %ebx
8010657c:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010657f:	e8 41 ff ff ff       	call   801064c5 <setupkvm>
80106584:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106587:	85 c0                	test   %eax,%eax
80106589:	0f 84 c4 00 00 00    	je     80106653 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010658f:	bf 00 00 00 00       	mov    $0x0,%edi
80106594:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106597:	0f 83 b6 00 00 00    	jae    80106653 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010659d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801065a0:	b9 00 00 00 00       	mov    $0x0,%ecx
801065a5:	89 fa                	mov    %edi,%edx
801065a7:	8b 45 08             	mov    0x8(%ebp),%eax
801065aa:	e8 c5 f8 ff ff       	call   80105e74 <walkpgdir>
801065af:	85 c0                	test   %eax,%eax
801065b1:	74 65                	je     80106618 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801065b3:	8b 00                	mov    (%eax),%eax
801065b5:	a8 01                	test   $0x1,%al
801065b7:	74 6c                	je     80106625 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801065b9:	89 c6                	mov    %eax,%esi
801065bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801065c1:	25 ff 0f 00 00       	and    $0xfff,%eax
801065c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801065c9:	e8 ed ba ff ff       	call   801020bb <kalloc>
801065ce:	89 c3                	mov    %eax,%ebx
801065d0:	85 c0                	test   %eax,%eax
801065d2:	74 6a                	je     8010663e <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801065d4:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801065da:	83 ec 04             	sub    $0x4,%esp
801065dd:	68 00 10 00 00       	push   $0x1000
801065e2:	56                   	push   %esi
801065e3:	50                   	push   %eax
801065e4:	e8 56 d9 ff ff       	call   80103f3f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801065e9:	83 c4 08             	add    $0x8,%esp
801065ec:	ff 75 e0             	pushl  -0x20(%ebp)
801065ef:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801065f5:	50                   	push   %eax
801065f6:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801065fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106601:	e8 de f8 ff ff       	call   80105ee4 <mappages>
80106606:	83 c4 10             	add    $0x10,%esp
80106609:	85 c0                	test   %eax,%eax
8010660b:	78 25                	js     80106632 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
8010660d:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106613:	e9 7c ff ff ff       	jmp    80106594 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106618:	83 ec 0c             	sub    $0xc,%esp
8010661b:	68 38 71 10 80       	push   $0x80107138
80106620:	e8 23 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106625:	83 ec 0c             	sub    $0xc,%esp
80106628:	68 52 71 10 80       	push   $0x80107152
8010662d:	e8 16 9d ff ff       	call   80100348 <panic>
      kfree(mem);
80106632:	83 ec 0c             	sub    $0xc,%esp
80106635:	53                   	push   %ebx
80106636:	e8 69 b9 ff ff       	call   80101fa4 <kfree>
      goto bad;
8010663b:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010663e:	83 ec 0c             	sub    $0xc,%esp
80106641:	ff 75 dc             	pushl  -0x24(%ebp)
80106644:	e8 0c fe ff ff       	call   80106455 <freevm>
  return 0;
80106649:	83 c4 10             	add    $0x10,%esp
8010664c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106653:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106656:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106659:	5b                   	pop    %ebx
8010665a:	5e                   	pop    %esi
8010665b:	5f                   	pop    %edi
8010665c:	5d                   	pop    %ebp
8010665d:	c3                   	ret    

8010665e <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010665e:	55                   	push   %ebp
8010665f:	89 e5                	mov    %esp,%ebp
80106661:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106664:	b9 00 00 00 00       	mov    $0x0,%ecx
80106669:	8b 55 0c             	mov    0xc(%ebp),%edx
8010666c:	8b 45 08             	mov    0x8(%ebp),%eax
8010666f:	e8 00 f8 ff ff       	call   80105e74 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106674:	8b 00                	mov    (%eax),%eax
80106676:	a8 01                	test   $0x1,%al
80106678:	74 10                	je     8010668a <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010667a:	a8 04                	test   $0x4,%al
8010667c:	74 13                	je     80106691 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
8010667e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106683:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106688:	c9                   	leave  
80106689:	c3                   	ret    
    return 0;
8010668a:	b8 00 00 00 00       	mov    $0x0,%eax
8010668f:	eb f7                	jmp    80106688 <uva2ka+0x2a>
    return 0;
80106691:	b8 00 00 00 00       	mov    $0x0,%eax
80106696:	eb f0                	jmp    80106688 <uva2ka+0x2a>

80106698 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106698:	55                   	push   %ebp
80106699:	89 e5                	mov    %esp,%ebp
8010669b:	57                   	push   %edi
8010669c:	56                   	push   %esi
8010669d:	53                   	push   %ebx
8010669e:	83 ec 0c             	sub    $0xc,%esp
801066a1:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801066a4:	eb 25                	jmp    801066cb <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801066a6:	8b 55 0c             	mov    0xc(%ebp),%edx
801066a9:	29 f2                	sub    %esi,%edx
801066ab:	01 d0                	add    %edx,%eax
801066ad:	83 ec 04             	sub    $0x4,%esp
801066b0:	53                   	push   %ebx
801066b1:	ff 75 10             	pushl  0x10(%ebp)
801066b4:	50                   	push   %eax
801066b5:	e8 85 d8 ff ff       	call   80103f3f <memmove>
    len -= n;
801066ba:	29 df                	sub    %ebx,%edi
    buf += n;
801066bc:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801066bf:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801066c5:	89 45 0c             	mov    %eax,0xc(%ebp)
801066c8:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801066cb:	85 ff                	test   %edi,%edi
801066cd:	74 2f                	je     801066fe <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801066cf:	8b 75 0c             	mov    0xc(%ebp),%esi
801066d2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801066d8:	83 ec 08             	sub    $0x8,%esp
801066db:	56                   	push   %esi
801066dc:	ff 75 08             	pushl  0x8(%ebp)
801066df:	e8 7a ff ff ff       	call   8010665e <uva2ka>
    if(pa0 == 0)
801066e4:	83 c4 10             	add    $0x10,%esp
801066e7:	85 c0                	test   %eax,%eax
801066e9:	74 20                	je     8010670b <copyout+0x73>
    n = PGSIZE - (va - va0);
801066eb:	89 f3                	mov    %esi,%ebx
801066ed:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801066f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801066f6:	39 df                	cmp    %ebx,%edi
801066f8:	73 ac                	jae    801066a6 <copyout+0xe>
      n = len;
801066fa:	89 fb                	mov    %edi,%ebx
801066fc:	eb a8                	jmp    801066a6 <copyout+0xe>
  }
  return 0;
801066fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106703:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106706:	5b                   	pop    %ebx
80106707:	5e                   	pop    %esi
80106708:	5f                   	pop    %edi
80106709:	5d                   	pop    %ebp
8010670a:	c3                   	ret    
      return -1;
8010670b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106710:	eb f1                	jmp    80106703 <copyout+0x6b>
