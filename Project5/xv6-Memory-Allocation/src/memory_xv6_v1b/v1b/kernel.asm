
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
8010002d:	b8 36 2c 10 80       	mov    $0x80102c36,%eax
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
80100046:	e8 bd 3d 00 00       	call   80103e08 <acquire>

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
8010007c:	e8 ec 3d 00 00       	call   80103e6d <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 68 3b 00 00       	call   80103bf4 <acquiresleep>
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
801000ca:	e8 9e 3d 00 00       	call   80103e6d <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 1a 3b 00 00       	call   80103bf4 <acquiresleep>
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
80100105:	e8 c2 3b 00 00       	call   80103ccc <initlock>
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
80100143:	e8 79 3a 00 00       	call   80103bc1 <initsleeplock>
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
801001a8:	e8 d1 3a 00 00       	call   80103c7e <holdingsleep>
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
801001e4:	e8 95 3a 00 00       	call   80103c7e <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 4a 3a 00 00       	call   80103c43 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 03 3c 00 00       	call   80103e08 <acquire>
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
8010024c:	e8 1c 3c 00 00       	call   80103e6d <release>
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
8010028a:	e8 79 3b 00 00       	call   80103e08 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 4c 31 00 00       	call   801033f8 <myproc>
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
801002bf:	e8 e2 35 00 00       	call   801038a6 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 97 3b 00 00       	call   80103e6d <release>
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
80100331:	e8 37 3b 00 00       	call   80103e6d <release>
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
8010035a:	e8 f1 21 00 00       	call   80102550 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 4d 67 10 80       	push   $0x8010674d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 9b 70 10 80 	movl   $0x8010709b,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 53 39 00 00       	call   80103ce7 <getcallerpcs>
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
801004ba:	e8 70 3a 00 00       	call   80103f2f <memmove>
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
801004d9:	e8 d6 39 00 00       	call   80103eb4 <memset>
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
80100506:	e8 ea 4d 00 00       	call   801052f5 <uartputc>
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
8010051f:	e8 d1 4d 00 00       	call   801052f5 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 c5 4d 00 00       	call   801052f5 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 b9 4d 00 00       	call   801052f5 <uartputc>
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
801005ca:	e8 39 38 00 00       	call   80103e08 <acquire>
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
801005f1:	e8 77 38 00 00       	call   80103e6d <release>
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
80100638:	e8 cb 37 00 00       	call   80103e08 <acquire>
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
80100734:	e8 34 37 00 00       	call   80103e6d <release>
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
8010074f:	e8 b4 36 00 00       	call   80103e08 <acquire>
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
801007de:	e8 28 32 00 00       	call   80103a0b <wakeup>
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
80100873:	e8 f5 35 00 00       	call   80103e6d <release>
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
80100887:	e8 1c 32 00 00       	call   80103aa8 <procdump>
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
8010089e:	e8 29 34 00 00       	call   80103ccc <initlock>

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
801008de:	e8 15 2b 00 00       	call   801033f8 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 92 20 00 00       	call   80102980 <begin_op>

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
80100935:	e8 c0 20 00 00       	call   801029fa <end_op>
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
8010094a:	e8 ab 20 00 00       	call   801029fa <end_op>
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
80100972:	e8 3e 5b 00 00       	call   801064b5 <setupkvm>
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
80100a06:	e8 50 59 00 00       	call   8010635b <allocuvm>
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
80100a38:	e8 ec 57 00 00       	call   80106229 <loaduvm>
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
80100a53:	e8 a2 1f 00 00       	call   801029fa <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 e2 58 00 00       	call   8010635b <allocuvm>
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
80100a9d:	e8 a3 59 00 00       	call   80106445 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 79 5a 00 00       	call   8010653a <clearpteu>
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
80100ae2:	e8 6f 35 00 00       	call   80104056 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 5d 35 00 00       	call   80104056 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 7d 5b 00 00       	call   80106688 <copyout>
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
80100b66:	e8 1d 5b 00 00       	call   80106688 <copyout>
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
80100ba3:	e8 73 34 00 00       	call   8010401b <safestrcpy>
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
80100bd1:	e8 d2 54 00 00       	call   801060a8 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 67 58 00 00       	call   80106445 <freevm>
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
80100c23:	e8 a4 30 00 00       	call   80103ccc <initlock>
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
80100c39:	e8 ca 31 00 00       	call   80103e08 <acquire>
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
80100c68:	e8 00 32 00 00       	call   80103e6d <release>
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
80100c7f:	e8 e9 31 00 00       	call   80103e6d <release>
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
80100c9d:	e8 66 31 00 00       	call   80103e08 <acquire>
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
80100cba:	e8 ae 31 00 00       	call   80103e6d <release>
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
80100ce2:	e8 21 31 00 00       	call   80103e08 <acquire>
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
80100d03:	e8 65 31 00 00       	call   80103e6d <release>
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
80100d49:	e8 1f 31 00 00       	call   80103e6d <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 1d 1c 00 00       	call   80102980 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 87 1c 00 00       	call   801029fa <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 6c 22 00 00       	call   80102ff4 <pipeclose>
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
80100e3c:	e8 0b 23 00 00       	call   8010314c <piperead>
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
80100e95:	e8 e6 21 00 00       	call   80103080 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 d9 1a 00 00       	call   80102980 <begin_op>
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
80100edd:	e8 18 1b 00 00       	call   801029fa <end_op>

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
80100f8a:	e8 a0 2f 00 00       	call   80103f2f <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 90 2f 00 00       	call   80103f2f <memmove>
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
80100fdf:	e8 d0 2e 00 00       	call   80103eb4 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 bd 1a 00 00       	call   80102aa9 <log_write>
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
801010bf:	e8 e5 19 00 00       	call   80102aa9 <log_write>
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
80101170:	e8 34 19 00 00       	call   80102aa9 <log_write>
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
8010119a:	e8 69 2c 00 00       	call   80103e08 <acquire>
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
801011e1:	e8 87 2c 00 00       	call   80103e6d <release>
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
80101217:	e8 51 2c 00 00       	call   80103e6d <release>
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
80101255:	e8 d5 2c 00 00       	call   80103f2f <memmove>
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
801012c8:	e8 dc 17 00 00       	call   80102aa9 <log_write>
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
801012fd:	e8 ca 29 00 00       	call   80103ccc <initlock>
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
80101322:	e8 9a 28 00 00       	call   80103bc1 <initsleeplock>
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
801013f1:	e8 be 2a 00 00       	call   80103eb4 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 a4 16 00 00       	call   80102aa9 <log_write>
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
80101480:	e8 aa 2a 00 00       	call   80103f2f <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 1c 16 00 00       	call   80102aa9 <log_write>
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
80101560:	e8 a3 28 00 00       	call   80103e08 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101575:	e8 f3 28 00 00       	call   80103e6d <release>
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
8010159a:	e8 55 26 00 00       	call   80103bf4 <acquiresleep>
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
80101614:	e8 16 29 00 00       	call   80103f2f <memmove>
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
80101656:	e8 23 26 00 00       	call   80103c7e <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 d2 25 00 00       	call   80103c43 <releasesleep>
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
80101698:	e8 57 25 00 00       	call   80103bf4 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 8d 25 00 00       	call   80103c43 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016bd:	e8 46 27 00 00       	call   80103e08 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d2:	e8 96 27 00 00       	call   80103e6d <release>
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
801016ea:	e8 19 27 00 00       	call   80103e08 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016f9:	e8 6f 27 00 00       	call   80103e6d <release>
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
8010182a:	e8 00 27 00 00       	call   80103f2f <memmove>
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
80101926:	e8 04 26 00 00       	call   80103f2f <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 76 11 00 00       	call   80102aa9 <log_write>
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
801019a9:	e8 e8 25 00 00       	call   80103f96 <strncmp>
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
80101a5a:	e8 99 19 00 00       	call   801033f8 <myproc>
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
80101ba9:	e8 25 24 00 00       	call   80103fd3 <strncpy>
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
80101bd7:	68 94 6e 10 80       	push   $0x80106e94
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
80101d10:	e8 b7 1f 00 00       	call   80103ccc <initlock>
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
80101d80:	e8 83 20 00 00       	call   80103e08 <acquire>

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
80101dad:	e8 59 1c 00 00       	call   80103a0b <wakeup>

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
80101dcb:	e8 9d 20 00 00       	call   80103e6d <release>
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
80101de2:	e8 86 20 00 00       	call   80103e6d <release>
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
80101e1a:	e8 5f 1e 00 00       	call   80103c7e <holdingsleep>
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
80101e47:	e8 bc 1f 00 00       	call   80103e08 <acquire>

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
80101ea9:	e8 f8 19 00 00       	call   801038a6 <sleep>
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
80101ec3:	e8 a5 1f 00 00       	call   80103e6d <release>
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
80101fd6:	e8 d9 1e 00 00       	call   80103eb4 <memset>
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
80102017:	e8 ec 1d 00 00       	call   80103e08 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 40 26 11 80       	push   $0x80112640
80102029:	e8 3f 1e 00 00       	call   80103e6d <release>
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
80102079:	e8 4e 1c 00 00       	call   80103ccc <initlock>
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
80102121:	e8 e2 1c 00 00       	call   80103e08 <acquire>
80102126:	83 c4 10             	add    $0x10,%esp
80102129:	eb a0                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
8010212b:	83 ec 0c             	sub    $0xc,%esp
8010212e:	68 40 26 11 80       	push   $0x80112640
80102133:	e8 35 1d 00 00       	call   80103e6d <release>
80102138:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010213b:	eb d5                	jmp    80102112 <kalloc+0x57>

8010213d <kalloc1a>:


char*
kalloc1a(int processPid)
{
8010213d:	55                   	push   %ebp
8010213e:	89 e5                	mov    %esp,%ebp
80102140:	53                   	push   %ebx
80102141:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
80102144:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010214b:	75 4d                	jne    8010219a <kalloc1a+0x5d>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010214d:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
80102153:	85 db                	test   %ebx,%ebx
80102155:	74 09                	je     80102160 <kalloc1a+0x23>
    kmem.freelist = r->next->next;
80102157:	8b 03                	mov    (%ebx),%eax
80102159:	8b 00                	mov    (%eax),%eax
8010215b:	a3 78 26 11 80       	mov    %eax,0x80112678

  char* ptr = (char*)r;
  //cprintf("Allocated KALLOC1A: %x \t %x \t %x \n", PHYSTOP - V2P(ptr), PHYSTOP - (V2P(ptr) >> 12 ), (V2P(ptr) >> 12 & 0xffff));
  //int i;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
80102160:	8d 93 00 00 00 80    	lea    -0x80000000(%ebx),%edx
80102166:	c1 ea 0c             	shr    $0xc,%edx
80102169:	0f b7 d2             	movzwl %dx,%edx
  for(int z = i+1; z<numframes; z++) {
	frames[z] = frames[z-1];
	pid[z] = pid[z-1];
  } */
  
  numframes++;
8010216c:	a1 00 80 10 80       	mov    0x80108000,%eax
80102171:	83 c0 01             	add    $0x1,%eax
80102174:	a3 00 80 10 80       	mov    %eax,0x80108000
  frames[numframes] = frameNumberFound;
80102179:	89 14 85 80 ea 1a 80 	mov    %edx,-0x7fe51580(,%eax,4)
  pid[numframes] = processPid;
80102180:	8b 55 08             	mov    0x8(%ebp),%edx
80102183:	89 14 85 80 26 11 80 	mov    %edx,-0x7feed980(,%eax,4)

  //cprintf("ALLOCATED KALLOC1A: Numframes: %d, i: not there currently , frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
  //cprintf("0. %x %d \n", frames[0], pid[0]);
  //cprintf("64. %x %d \n", frames[64], pid[64]);
  if(kmem.use_lock)
8010218a:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102191:	75 19                	jne    801021ac <kalloc1a+0x6f>
    release(&kmem.lock);
  return (char*)r;
}
80102193:	89 d8                	mov    %ebx,%eax
80102195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102198:	c9                   	leave  
80102199:	c3                   	ret    
    acquire(&kmem.lock);
8010219a:	83 ec 0c             	sub    $0xc,%esp
8010219d:	68 40 26 11 80       	push   $0x80112640
801021a2:	e8 61 1c 00 00       	call   80103e08 <acquire>
801021a7:	83 c4 10             	add    $0x10,%esp
801021aa:	eb a1                	jmp    8010214d <kalloc1a+0x10>
    release(&kmem.lock);
801021ac:	83 ec 0c             	sub    $0xc,%esp
801021af:	68 40 26 11 80       	push   $0x80112640
801021b4:	e8 b4 1c 00 00       	call   80103e6d <release>
801021b9:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801021bc:	eb d5                	jmp    80102193 <kalloc1a+0x56>

801021be <kalloc2>:

char*
kalloc2(int processPid)
{
801021be:	55                   	push   %ebp
801021bf:	89 e5                	mov    %esp,%ebp
801021c1:	57                   	push   %edi
801021c2:	56                   	push   %esi
801021c3:	53                   	push   %ebx
801021c4:	83 ec 1c             	sub    $0x1c,%esp
  struct run *r, *head;
  head = kmem.freelist;
801021c7:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx

  if(kmem.use_lock)
801021cd:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801021d4:	75 62                	jne    80102238 <kalloc2+0x7a>
     acquire(&kmem.lock);
  int firstPass = 1;
801021d6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
801021dd:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  
  repeat: 
  if(firstPass) {
801021e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801021e4:	74 64                	je     8010224a <kalloc2+0x8c>
    r = kmem.freelist;
801021e6:	8b 35 78 26 11 80    	mov    0x80112678,%esi
    firstPass = 0;
801021ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  } else {
    r = r->next;
  }

  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
801021f3:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801021f9:	c1 e8 0c             	shr    $0xc,%eax
801021fc:	0f b7 d8             	movzwl %ax,%ebx
 
  int i;
  for(i = 0; i<numframes; i++) {
801021ff:	bf 00 00 00 00       	mov    $0x0,%edi
80102204:	8b 0d 00 80 10 80    	mov    0x80108000,%ecx
8010220a:	39 f9                	cmp    %edi,%ecx
8010220c:	7e 19                	jle    80102227 <kalloc2+0x69>
     if(frames[i] == (frameNumberFound - 1)) {
8010220e:	8b 04 bd 80 ea 1a 80 	mov    -0x7fe51580(,%edi,4),%eax
80102215:	8d 53 ff             	lea    -0x1(%ebx),%edx
80102218:	39 d0                	cmp    %edx,%eax
8010221a:	74 32                	je     8010224e <kalloc2+0x90>
          if(pid[i] != processPid) {
             goto repeat;
	  }		  
     }
     if(frames[i] == (frameNumberFound + 1)) {
8010221c:	8d 53 01             	lea    0x1(%ebx),%edx
8010221f:	39 d0                	cmp    %edx,%eax
80102221:	74 39                	je     8010225c <kalloc2+0x9e>
         if(pid[i] != processPid) {
            goto repeat;
	 }
     }
     if(frames[i] > (frameNumberFound)) {
80102223:	39 d8                	cmp    %ebx,%eax
80102225:	7f 46                	jg     8010226d <kalloc2+0xaf>
80102227:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
         continue;
     }
     break;
  }
  
  numframes++;
8010222a:	83 c1 01             	add    $0x1,%ecx
8010222d:	89 0d 00 80 10 80    	mov    %ecx,0x80108000
  for(int z = i+1; z<numframes; z++) {
80102233:	8d 47 01             	lea    0x1(%edi),%eax
80102236:	eb 5c                	jmp    80102294 <kalloc2+0xd6>
     acquire(&kmem.lock);
80102238:	83 ec 0c             	sub    $0xc,%esp
8010223b:	68 40 26 11 80       	push   $0x80112640
80102240:	e8 c3 1b 00 00       	call   80103e08 <acquire>
80102245:	83 c4 10             	add    $0x10,%esp
80102248:	eb 8c                	jmp    801021d6 <kalloc2+0x18>
    r = r->next;
8010224a:	8b 36                	mov    (%esi),%esi
8010224c:	eb a5                	jmp    801021f3 <kalloc2+0x35>
          if(pid[i] != processPid) {
8010224e:	8b 55 08             	mov    0x8(%ebp),%edx
80102251:	39 14 bd 80 26 11 80 	cmp    %edx,-0x7feed980(,%edi,4)
80102258:	74 c2                	je     8010221c <kalloc2+0x5e>
  repeat: 
8010225a:	eb 84                	jmp    801021e0 <kalloc2+0x22>
         if(pid[i] != processPid) {
8010225c:	8b 55 08             	mov    0x8(%ebp),%edx
8010225f:	39 14 bd 80 26 11 80 	cmp    %edx,-0x7feed980(,%edi,4)
80102266:	74 bb                	je     80102223 <kalloc2+0x65>
  repeat: 
80102268:	e9 73 ff ff ff       	jmp    801021e0 <kalloc2+0x22>
  for(i = 0; i<numframes; i++) {
8010226d:	83 c7 01             	add    $0x1,%edi
80102270:	eb 92                	jmp    80102204 <kalloc2+0x46>
     frames[z] = frames[z-1];
80102272:	8d 50 ff             	lea    -0x1(%eax),%edx
80102275:	8b 1c 95 80 ea 1a 80 	mov    -0x7fe51580(,%edx,4),%ebx
8010227c:	89 1c 85 80 ea 1a 80 	mov    %ebx,-0x7fe51580(,%eax,4)
     pid[z] = pid[z-1];
80102283:	8b 14 95 80 26 11 80 	mov    -0x7feed980(,%edx,4),%edx
8010228a:	89 14 85 80 26 11 80 	mov    %edx,-0x7feed980(,%eax,4)
  for(int z = i+1; z<numframes; z++) {
80102291:	83 c0 01             	add    $0x1,%eax
80102294:	39 c1                	cmp    %eax,%ecx
80102296:	7f da                	jg     80102272 <kalloc2+0xb4>
80102298:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  }
  frames[i] = frameNumberFound;
8010229b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010229e:	89 04 bd 80 ea 1a 80 	mov    %eax,-0x7fe51580(,%edi,4)
  pid[i] = processPid;
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	89 04 bd 80 26 11 80 	mov    %eax,-0x7feed980(,%edi,4)

  while(head->next != r) {
801022af:	eb 02                	jmp    801022b3 <kalloc2+0xf5>
      head = head->next;
801022b1:	89 c3                	mov    %eax,%ebx
  while(head->next != r) {
801022b3:	8b 03                	mov    (%ebx),%eax
801022b5:	39 f0                	cmp    %esi,%eax
801022b7:	75 f8                	jne    801022b1 <kalloc2+0xf3>
  }
  head->next = r->next;
801022b9:	8b 06                	mov    (%esi),%eax
801022bb:	89 03                	mov    %eax,(%ebx)

  if(!kmem.use_lock)
801022bd:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801022c4:	74 0a                	je     801022d0 <kalloc2+0x112>
     release(&kmem.lock);
  return (char*)r;
}
801022c6:	89 f0                	mov    %esi,%eax
801022c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022cb:	5b                   	pop    %ebx
801022cc:	5e                   	pop    %esi
801022cd:	5f                   	pop    %edi
801022ce:	5d                   	pop    %ebp
801022cf:	c3                   	ret    
     release(&kmem.lock);
801022d0:	83 ec 0c             	sub    $0xc,%esp
801022d3:	68 40 26 11 80       	push   $0x80112640
801022d8:	e8 90 1b 00 00       	call   80103e6d <release>
801022dd:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801022e0:	eb e4                	jmp    801022c6 <kalloc2+0x108>

801022e2 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801022e2:	55                   	push   %ebp
801022e3:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022e5:	ba 64 00 00 00       	mov    $0x64,%edx
801022ea:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022eb:	a8 01                	test   $0x1,%al
801022ed:	0f 84 b5 00 00 00    	je     801023a8 <kbdgetc+0xc6>
801022f3:	ba 60 00 00 00       	mov    $0x60,%edx
801022f8:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801022f9:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801022fc:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102302:	74 5c                	je     80102360 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102304:	84 c0                	test   %al,%al
80102306:	78 66                	js     8010236e <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102308:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010230e:	f6 c1 40             	test   $0x40,%cl
80102311:	74 0f                	je     80102322 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102313:	83 c8 80             	or     $0xffffff80,%eax
80102316:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102319:	83 e1 bf             	and    $0xffffffbf,%ecx
8010231c:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102322:	0f b6 8a c0 6a 10 80 	movzbl -0x7fef9540(%edx),%ecx
80102329:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
8010232f:	0f b6 82 c0 69 10 80 	movzbl -0x7fef9640(%edx),%eax
80102336:	31 c1                	xor    %eax,%ecx
80102338:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010233e:	89 c8                	mov    %ecx,%eax
80102340:	83 e0 03             	and    $0x3,%eax
80102343:	8b 04 85 a0 69 10 80 	mov    -0x7fef9660(,%eax,4),%eax
8010234a:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010234e:	f6 c1 08             	test   $0x8,%cl
80102351:	74 19                	je     8010236c <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102353:	8d 50 9f             	lea    -0x61(%eax),%edx
80102356:	83 fa 19             	cmp    $0x19,%edx
80102359:	77 40                	ja     8010239b <kbdgetc+0xb9>
      c += 'A' - 'a';
8010235b:	83 e8 20             	sub    $0x20,%eax
8010235e:	eb 0c                	jmp    8010236c <kbdgetc+0x8a>
    shift |= E0ESC;
80102360:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
80102367:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010236c:	5d                   	pop    %ebp
8010236d:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010236e:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102374:	f6 c1 40             	test   $0x40,%cl
80102377:	75 05                	jne    8010237e <kbdgetc+0x9c>
80102379:	89 c2                	mov    %eax,%edx
8010237b:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
8010237e:	0f b6 82 c0 6a 10 80 	movzbl -0x7fef9540(%edx),%eax
80102385:	83 c8 40             	or     $0x40,%eax
80102388:	0f b6 c0             	movzbl %al,%eax
8010238b:	f7 d0                	not    %eax
8010238d:	21 c8                	and    %ecx,%eax
8010238f:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
80102394:	b8 00 00 00 00       	mov    $0x0,%eax
80102399:	eb d1                	jmp    8010236c <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010239b:	8d 50 bf             	lea    -0x41(%eax),%edx
8010239e:	83 fa 19             	cmp    $0x19,%edx
801023a1:	77 c9                	ja     8010236c <kbdgetc+0x8a>
      c += 'a' - 'A';
801023a3:	83 c0 20             	add    $0x20,%eax
  return c;
801023a6:	eb c4                	jmp    8010236c <kbdgetc+0x8a>
    return -1;
801023a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ad:	eb bd                	jmp    8010236c <kbdgetc+0x8a>

801023af <kbdintr>:

void
kbdintr(void)
{
801023af:	55                   	push   %ebp
801023b0:	89 e5                	mov    %esp,%ebp
801023b2:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801023b5:	68 e2 22 10 80       	push   $0x801022e2
801023ba:	e8 7f e3 ff ff       	call   8010073e <consoleintr>
}
801023bf:	83 c4 10             	add    $0x10,%esp
801023c2:	c9                   	leave  
801023c3:	c3                   	ret    

801023c4 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801023c4:	55                   	push   %ebp
801023c5:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801023c7:	8b 0d 80 e4 1b 80    	mov    0x801be480,%ecx
801023cd:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801023d0:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023d2:	a1 80 e4 1b 80       	mov    0x801be480,%eax
801023d7:	8b 40 20             	mov    0x20(%eax),%eax
}
801023da:	5d                   	pop    %ebp
801023db:	c3                   	ret    

801023dc <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801023dc:	55                   	push   %ebp
801023dd:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023df:	ba 70 00 00 00       	mov    $0x70,%edx
801023e4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023e5:	ba 71 00 00 00       	mov    $0x71,%edx
801023ea:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801023eb:	0f b6 c0             	movzbl %al,%eax
}
801023ee:	5d                   	pop    %ebp
801023ef:	c3                   	ret    

801023f0 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801023f0:	55                   	push   %ebp
801023f1:	89 e5                	mov    %esp,%ebp
801023f3:	53                   	push   %ebx
801023f4:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801023f6:	b8 00 00 00 00       	mov    $0x0,%eax
801023fb:	e8 dc ff ff ff       	call   801023dc <cmos_read>
80102400:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102402:	b8 02 00 00 00       	mov    $0x2,%eax
80102407:	e8 d0 ff ff ff       	call   801023dc <cmos_read>
8010240c:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010240f:	b8 04 00 00 00       	mov    $0x4,%eax
80102414:	e8 c3 ff ff ff       	call   801023dc <cmos_read>
80102419:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010241c:	b8 07 00 00 00       	mov    $0x7,%eax
80102421:	e8 b6 ff ff ff       	call   801023dc <cmos_read>
80102426:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102429:	b8 08 00 00 00       	mov    $0x8,%eax
8010242e:	e8 a9 ff ff ff       	call   801023dc <cmos_read>
80102433:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102436:	b8 09 00 00 00       	mov    $0x9,%eax
8010243b:	e8 9c ff ff ff       	call   801023dc <cmos_read>
80102440:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102443:	5b                   	pop    %ebx
80102444:	5d                   	pop    %ebp
80102445:	c3                   	ret    

80102446 <lapicinit>:
  if(!lapic)
80102446:	83 3d 80 e4 1b 80 00 	cmpl   $0x0,0x801be480
8010244d:	0f 84 fb 00 00 00    	je     8010254e <lapicinit+0x108>
{
80102453:	55                   	push   %ebp
80102454:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102456:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010245b:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102460:	e8 5f ff ff ff       	call   801023c4 <lapicw>
  lapicw(TDCR, X1);
80102465:	ba 0b 00 00 00       	mov    $0xb,%edx
8010246a:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010246f:	e8 50 ff ff ff       	call   801023c4 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102474:	ba 20 00 02 00       	mov    $0x20020,%edx
80102479:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010247e:	e8 41 ff ff ff       	call   801023c4 <lapicw>
  lapicw(TICR, 10000000);
80102483:	ba 80 96 98 00       	mov    $0x989680,%edx
80102488:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010248d:	e8 32 ff ff ff       	call   801023c4 <lapicw>
  lapicw(LINT0, MASKED);
80102492:	ba 00 00 01 00       	mov    $0x10000,%edx
80102497:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010249c:	e8 23 ff ff ff       	call   801023c4 <lapicw>
  lapicw(LINT1, MASKED);
801024a1:	ba 00 00 01 00       	mov    $0x10000,%edx
801024a6:	b8 d8 00 00 00       	mov    $0xd8,%eax
801024ab:	e8 14 ff ff ff       	call   801023c4 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801024b0:	a1 80 e4 1b 80       	mov    0x801be480,%eax
801024b5:	8b 40 30             	mov    0x30(%eax),%eax
801024b8:	c1 e8 10             	shr    $0x10,%eax
801024bb:	3c 03                	cmp    $0x3,%al
801024bd:	77 7b                	ja     8010253a <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801024bf:	ba 33 00 00 00       	mov    $0x33,%edx
801024c4:	b8 dc 00 00 00       	mov    $0xdc,%eax
801024c9:	e8 f6 fe ff ff       	call   801023c4 <lapicw>
  lapicw(ESR, 0);
801024ce:	ba 00 00 00 00       	mov    $0x0,%edx
801024d3:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024d8:	e8 e7 fe ff ff       	call   801023c4 <lapicw>
  lapicw(ESR, 0);
801024dd:	ba 00 00 00 00       	mov    $0x0,%edx
801024e2:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024e7:	e8 d8 fe ff ff       	call   801023c4 <lapicw>
  lapicw(EOI, 0);
801024ec:	ba 00 00 00 00       	mov    $0x0,%edx
801024f1:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024f6:	e8 c9 fe ff ff       	call   801023c4 <lapicw>
  lapicw(ICRHI, 0);
801024fb:	ba 00 00 00 00       	mov    $0x0,%edx
80102500:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102505:	e8 ba fe ff ff       	call   801023c4 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010250a:	ba 00 85 08 00       	mov    $0x88500,%edx
8010250f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102514:	e8 ab fe ff ff       	call   801023c4 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102519:	a1 80 e4 1b 80       	mov    0x801be480,%eax
8010251e:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102524:	f6 c4 10             	test   $0x10,%ah
80102527:	75 f0                	jne    80102519 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102529:	ba 00 00 00 00       	mov    $0x0,%edx
8010252e:	b8 20 00 00 00       	mov    $0x20,%eax
80102533:	e8 8c fe ff ff       	call   801023c4 <lapicw>
}
80102538:	5d                   	pop    %ebp
80102539:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010253a:	ba 00 00 01 00       	mov    $0x10000,%edx
8010253f:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102544:	e8 7b fe ff ff       	call   801023c4 <lapicw>
80102549:	e9 71 ff ff ff       	jmp    801024bf <lapicinit+0x79>
8010254e:	f3 c3                	repz ret 

80102550 <lapicid>:
{
80102550:	55                   	push   %ebp
80102551:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102553:	a1 80 e4 1b 80       	mov    0x801be480,%eax
80102558:	85 c0                	test   %eax,%eax
8010255a:	74 08                	je     80102564 <lapicid+0x14>
  return lapic[ID] >> 24;
8010255c:	8b 40 20             	mov    0x20(%eax),%eax
8010255f:	c1 e8 18             	shr    $0x18,%eax
}
80102562:	5d                   	pop    %ebp
80102563:	c3                   	ret    
    return 0;
80102564:	b8 00 00 00 00       	mov    $0x0,%eax
80102569:	eb f7                	jmp    80102562 <lapicid+0x12>

8010256b <lapiceoi>:
  if(lapic)
8010256b:	83 3d 80 e4 1b 80 00 	cmpl   $0x0,0x801be480
80102572:	74 14                	je     80102588 <lapiceoi+0x1d>
{
80102574:	55                   	push   %ebp
80102575:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102577:	ba 00 00 00 00       	mov    $0x0,%edx
8010257c:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102581:	e8 3e fe ff ff       	call   801023c4 <lapicw>
}
80102586:	5d                   	pop    %ebp
80102587:	c3                   	ret    
80102588:	f3 c3                	repz ret 

8010258a <microdelay>:
{
8010258a:	55                   	push   %ebp
8010258b:	89 e5                	mov    %esp,%ebp
}
8010258d:	5d                   	pop    %ebp
8010258e:	c3                   	ret    

8010258f <lapicstartap>:
{
8010258f:	55                   	push   %ebp
80102590:	89 e5                	mov    %esp,%ebp
80102592:	57                   	push   %edi
80102593:	56                   	push   %esi
80102594:	53                   	push   %ebx
80102595:	8b 75 08             	mov    0x8(%ebp),%esi
80102598:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010259b:	b8 0f 00 00 00       	mov    $0xf,%eax
801025a0:	ba 70 00 00 00       	mov    $0x70,%edx
801025a5:	ee                   	out    %al,(%dx)
801025a6:	b8 0a 00 00 00       	mov    $0xa,%eax
801025ab:	ba 71 00 00 00       	mov    $0x71,%edx
801025b0:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801025b1:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801025b8:	00 00 
  wrv[1] = addr >> 4;
801025ba:	89 f8                	mov    %edi,%eax
801025bc:	c1 e8 04             	shr    $0x4,%eax
801025bf:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801025c5:	c1 e6 18             	shl    $0x18,%esi
801025c8:	89 f2                	mov    %esi,%edx
801025ca:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025cf:	e8 f0 fd ff ff       	call   801023c4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801025d4:	ba 00 c5 00 00       	mov    $0xc500,%edx
801025d9:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025de:	e8 e1 fd ff ff       	call   801023c4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801025e3:	ba 00 85 00 00       	mov    $0x8500,%edx
801025e8:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025ed:	e8 d2 fd ff ff       	call   801023c4 <lapicw>
  for(i = 0; i < 2; i++){
801025f2:	bb 00 00 00 00       	mov    $0x0,%ebx
801025f7:	eb 21                	jmp    8010261a <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801025f9:	89 f2                	mov    %esi,%edx
801025fb:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102600:	e8 bf fd ff ff       	call   801023c4 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102605:	89 fa                	mov    %edi,%edx
80102607:	c1 ea 0c             	shr    $0xc,%edx
8010260a:	80 ce 06             	or     $0x6,%dh
8010260d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102612:	e8 ad fd ff ff       	call   801023c4 <lapicw>
  for(i = 0; i < 2; i++){
80102617:	83 c3 01             	add    $0x1,%ebx
8010261a:	83 fb 01             	cmp    $0x1,%ebx
8010261d:	7e da                	jle    801025f9 <lapicstartap+0x6a>
}
8010261f:	5b                   	pop    %ebx
80102620:	5e                   	pop    %esi
80102621:	5f                   	pop    %edi
80102622:	5d                   	pop    %ebp
80102623:	c3                   	ret    

80102624 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102624:	55                   	push   %ebp
80102625:	89 e5                	mov    %esp,%ebp
80102627:	57                   	push   %edi
80102628:	56                   	push   %esi
80102629:	53                   	push   %ebx
8010262a:	83 ec 3c             	sub    $0x3c,%esp
8010262d:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102630:	b8 0b 00 00 00       	mov    $0xb,%eax
80102635:	e8 a2 fd ff ff       	call   801023dc <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010263a:	83 e0 04             	and    $0x4,%eax
8010263d:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010263f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102642:	e8 a9 fd ff ff       	call   801023f0 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102647:	b8 0a 00 00 00       	mov    $0xa,%eax
8010264c:	e8 8b fd ff ff       	call   801023dc <cmos_read>
80102651:	a8 80                	test   $0x80,%al
80102653:	75 ea                	jne    8010263f <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102655:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102658:	89 d8                	mov    %ebx,%eax
8010265a:	e8 91 fd ff ff       	call   801023f0 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010265f:	83 ec 04             	sub    $0x4,%esp
80102662:	6a 18                	push   $0x18
80102664:	53                   	push   %ebx
80102665:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102668:	50                   	push   %eax
80102669:	e8 8c 18 00 00       	call   80103efa <memcmp>
8010266e:	83 c4 10             	add    $0x10,%esp
80102671:	85 c0                	test   %eax,%eax
80102673:	75 ca                	jne    8010263f <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102675:	85 ff                	test   %edi,%edi
80102677:	0f 85 84 00 00 00    	jne    80102701 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010267d:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102680:	89 d0                	mov    %edx,%eax
80102682:	c1 e8 04             	shr    $0x4,%eax
80102685:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102688:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010268b:	83 e2 0f             	and    $0xf,%edx
8010268e:	01 d0                	add    %edx,%eax
80102690:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102693:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102696:	89 d0                	mov    %edx,%eax
80102698:	c1 e8 04             	shr    $0x4,%eax
8010269b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010269e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026a1:	83 e2 0f             	and    $0xf,%edx
801026a4:	01 d0                	add    %edx,%eax
801026a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801026a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801026ac:	89 d0                	mov    %edx,%eax
801026ae:	c1 e8 04             	shr    $0x4,%eax
801026b1:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026b4:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026b7:	83 e2 0f             	and    $0xf,%edx
801026ba:	01 d0                	add    %edx,%eax
801026bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801026bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
801026c2:	89 d0                	mov    %edx,%eax
801026c4:	c1 e8 04             	shr    $0x4,%eax
801026c7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026ca:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026cd:	83 e2 0f             	and    $0xf,%edx
801026d0:	01 d0                	add    %edx,%eax
801026d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801026d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801026d8:	89 d0                	mov    %edx,%eax
801026da:	c1 e8 04             	shr    $0x4,%eax
801026dd:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026e0:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026e3:	83 e2 0f             	and    $0xf,%edx
801026e6:	01 d0                	add    %edx,%eax
801026e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801026eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801026ee:	89 d0                	mov    %edx,%eax
801026f0:	c1 e8 04             	shr    $0x4,%eax
801026f3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026f6:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026f9:	83 e2 0f             	and    $0xf,%edx
801026fc:	01 d0                	add    %edx,%eax
801026fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102701:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102704:	89 06                	mov    %eax,(%esi)
80102706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102709:	89 46 04             	mov    %eax,0x4(%esi)
8010270c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010270f:	89 46 08             	mov    %eax,0x8(%esi)
80102712:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102715:	89 46 0c             	mov    %eax,0xc(%esi)
80102718:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010271b:	89 46 10             	mov    %eax,0x10(%esi)
8010271e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102721:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102724:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010272b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010272e:	5b                   	pop    %ebx
8010272f:	5e                   	pop    %esi
80102730:	5f                   	pop    %edi
80102731:	5d                   	pop    %ebp
80102732:	c3                   	ret    

80102733 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102733:	55                   	push   %ebp
80102734:	89 e5                	mov    %esp,%ebp
80102736:	53                   	push   %ebx
80102737:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010273a:	ff 35 d4 e4 1b 80    	pushl  0x801be4d4
80102740:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
80102746:	e8 21 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010274b:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010274e:	89 1d e8 e4 1b 80    	mov    %ebx,0x801be4e8
  for (i = 0; i < log.lh.n; i++) {
80102754:	83 c4 10             	add    $0x10,%esp
80102757:	ba 00 00 00 00       	mov    $0x0,%edx
8010275c:	eb 0e                	jmp    8010276c <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010275e:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102762:	89 0c 95 ec e4 1b 80 	mov    %ecx,-0x7fe41b14(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102769:	83 c2 01             	add    $0x1,%edx
8010276c:	39 d3                	cmp    %edx,%ebx
8010276e:	7f ee                	jg     8010275e <read_head+0x2b>
  }
  brelse(buf);
80102770:	83 ec 0c             	sub    $0xc,%esp
80102773:	50                   	push   %eax
80102774:	e8 5c da ff ff       	call   801001d5 <brelse>
}
80102779:	83 c4 10             	add    $0x10,%esp
8010277c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010277f:	c9                   	leave  
80102780:	c3                   	ret    

80102781 <install_trans>:
{
80102781:	55                   	push   %ebp
80102782:	89 e5                	mov    %esp,%ebp
80102784:	57                   	push   %edi
80102785:	56                   	push   %esi
80102786:	53                   	push   %ebx
80102787:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010278a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010278f:	eb 66                	jmp    801027f7 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102791:	89 d8                	mov    %ebx,%eax
80102793:	03 05 d4 e4 1b 80    	add    0x801be4d4,%eax
80102799:	83 c0 01             	add    $0x1,%eax
8010279c:	83 ec 08             	sub    $0x8,%esp
8010279f:	50                   	push   %eax
801027a0:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801027a6:	e8 c1 d9 ff ff       	call   8010016c <bread>
801027ab:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801027ad:	83 c4 08             	add    $0x8,%esp
801027b0:	ff 34 9d ec e4 1b 80 	pushl  -0x7fe41b14(,%ebx,4)
801027b7:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801027bd:	e8 aa d9 ff ff       	call   8010016c <bread>
801027c2:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801027c4:	8d 57 5c             	lea    0x5c(%edi),%edx
801027c7:	8d 40 5c             	lea    0x5c(%eax),%eax
801027ca:	83 c4 0c             	add    $0xc,%esp
801027cd:	68 00 02 00 00       	push   $0x200
801027d2:	52                   	push   %edx
801027d3:	50                   	push   %eax
801027d4:	e8 56 17 00 00       	call   80103f2f <memmove>
    bwrite(dbuf);  // write dst to disk
801027d9:	89 34 24             	mov    %esi,(%esp)
801027dc:	e8 b9 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801027e1:	89 3c 24             	mov    %edi,(%esp)
801027e4:	e8 ec d9 ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801027e9:	89 34 24             	mov    %esi,(%esp)
801027ec:	e8 e4 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027f1:	83 c3 01             	add    $0x1,%ebx
801027f4:	83 c4 10             	add    $0x10,%esp
801027f7:	39 1d e8 e4 1b 80    	cmp    %ebx,0x801be4e8
801027fd:	7f 92                	jg     80102791 <install_trans+0x10>
}
801027ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102802:	5b                   	pop    %ebx
80102803:	5e                   	pop    %esi
80102804:	5f                   	pop    %edi
80102805:	5d                   	pop    %ebp
80102806:	c3                   	ret    

80102807 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102807:	55                   	push   %ebp
80102808:	89 e5                	mov    %esp,%ebp
8010280a:	53                   	push   %ebx
8010280b:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010280e:	ff 35 d4 e4 1b 80    	pushl  0x801be4d4
80102814:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
8010281a:	e8 4d d9 ff ff       	call   8010016c <bread>
8010281f:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102821:	8b 0d e8 e4 1b 80    	mov    0x801be4e8,%ecx
80102827:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010282a:	83 c4 10             	add    $0x10,%esp
8010282d:	b8 00 00 00 00       	mov    $0x0,%eax
80102832:	eb 0e                	jmp    80102842 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102834:	8b 14 85 ec e4 1b 80 	mov    -0x7fe41b14(,%eax,4),%edx
8010283b:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010283f:	83 c0 01             	add    $0x1,%eax
80102842:	39 c1                	cmp    %eax,%ecx
80102844:	7f ee                	jg     80102834 <write_head+0x2d>
  }
  bwrite(buf);
80102846:	83 ec 0c             	sub    $0xc,%esp
80102849:	53                   	push   %ebx
8010284a:	e8 4b d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010284f:	89 1c 24             	mov    %ebx,(%esp)
80102852:	e8 7e d9 ff ff       	call   801001d5 <brelse>
}
80102857:	83 c4 10             	add    $0x10,%esp
8010285a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010285d:	c9                   	leave  
8010285e:	c3                   	ret    

8010285f <recover_from_log>:

static void
recover_from_log(void)
{
8010285f:	55                   	push   %ebp
80102860:	89 e5                	mov    %esp,%ebp
80102862:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102865:	e8 c9 fe ff ff       	call   80102733 <read_head>
  install_trans(); // if committed, copy from log to disk
8010286a:	e8 12 ff ff ff       	call   80102781 <install_trans>
  log.lh.n = 0;
8010286f:	c7 05 e8 e4 1b 80 00 	movl   $0x0,0x801be4e8
80102876:	00 00 00 
  write_head(); // clear the log
80102879:	e8 89 ff ff ff       	call   80102807 <write_head>
}
8010287e:	c9                   	leave  
8010287f:	c3                   	ret    

80102880 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102880:	55                   	push   %ebp
80102881:	89 e5                	mov    %esp,%ebp
80102883:	57                   	push   %edi
80102884:	56                   	push   %esi
80102885:	53                   	push   %ebx
80102886:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102889:	bb 00 00 00 00       	mov    $0x0,%ebx
8010288e:	eb 66                	jmp    801028f6 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102890:	89 d8                	mov    %ebx,%eax
80102892:	03 05 d4 e4 1b 80    	add    0x801be4d4,%eax
80102898:	83 c0 01             	add    $0x1,%eax
8010289b:	83 ec 08             	sub    $0x8,%esp
8010289e:	50                   	push   %eax
8010289f:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801028a5:	e8 c2 d8 ff ff       	call   8010016c <bread>
801028aa:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801028ac:	83 c4 08             	add    $0x8,%esp
801028af:	ff 34 9d ec e4 1b 80 	pushl  -0x7fe41b14(,%ebx,4)
801028b6:	ff 35 e4 e4 1b 80    	pushl  0x801be4e4
801028bc:	e8 ab d8 ff ff       	call   8010016c <bread>
801028c1:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801028c3:	8d 50 5c             	lea    0x5c(%eax),%edx
801028c6:	8d 46 5c             	lea    0x5c(%esi),%eax
801028c9:	83 c4 0c             	add    $0xc,%esp
801028cc:	68 00 02 00 00       	push   $0x200
801028d1:	52                   	push   %edx
801028d2:	50                   	push   %eax
801028d3:	e8 57 16 00 00       	call   80103f2f <memmove>
    bwrite(to);  // write the log
801028d8:	89 34 24             	mov    %esi,(%esp)
801028db:	e8 ba d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
801028e0:	89 3c 24             	mov    %edi,(%esp)
801028e3:	e8 ed d8 ff ff       	call   801001d5 <brelse>
    brelse(to);
801028e8:	89 34 24             	mov    %esi,(%esp)
801028eb:	e8 e5 d8 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801028f0:	83 c3 01             	add    $0x1,%ebx
801028f3:	83 c4 10             	add    $0x10,%esp
801028f6:	39 1d e8 e4 1b 80    	cmp    %ebx,0x801be4e8
801028fc:	7f 92                	jg     80102890 <write_log+0x10>
  }
}
801028fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102901:	5b                   	pop    %ebx
80102902:	5e                   	pop    %esi
80102903:	5f                   	pop    %edi
80102904:	5d                   	pop    %ebp
80102905:	c3                   	ret    

80102906 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102906:	83 3d e8 e4 1b 80 00 	cmpl   $0x0,0x801be4e8
8010290d:	7e 26                	jle    80102935 <commit+0x2f>
{
8010290f:	55                   	push   %ebp
80102910:	89 e5                	mov    %esp,%ebp
80102912:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102915:	e8 66 ff ff ff       	call   80102880 <write_log>
    write_head();    // Write header to disk -- the real commit
8010291a:	e8 e8 fe ff ff       	call   80102807 <write_head>
    install_trans(); // Now install writes to home locations
8010291f:	e8 5d fe ff ff       	call   80102781 <install_trans>
    log.lh.n = 0;
80102924:	c7 05 e8 e4 1b 80 00 	movl   $0x0,0x801be4e8
8010292b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010292e:	e8 d4 fe ff ff       	call   80102807 <write_head>
  }
}
80102933:	c9                   	leave  
80102934:	c3                   	ret    
80102935:	f3 c3                	repz ret 

80102937 <initlog>:
{
80102937:	55                   	push   %ebp
80102938:	89 e5                	mov    %esp,%ebp
8010293a:	53                   	push   %ebx
8010293b:	83 ec 2c             	sub    $0x2c,%esp
8010293e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102941:	68 c0 6b 10 80       	push   $0x80106bc0
80102946:	68 a0 e4 1b 80       	push   $0x801be4a0
8010294b:	e8 7c 13 00 00       	call   80103ccc <initlock>
  readsb(dev, &sb);
80102950:	83 c4 08             	add    $0x8,%esp
80102953:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102956:	50                   	push   %eax
80102957:	53                   	push   %ebx
80102958:	e8 d9 e8 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
8010295d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102960:	a3 d4 e4 1b 80       	mov    %eax,0x801be4d4
  log.size = sb.nlog;
80102965:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102968:	a3 d8 e4 1b 80       	mov    %eax,0x801be4d8
  log.dev = dev;
8010296d:	89 1d e4 e4 1b 80    	mov    %ebx,0x801be4e4
  recover_from_log();
80102973:	e8 e7 fe ff ff       	call   8010285f <recover_from_log>
}
80102978:	83 c4 10             	add    $0x10,%esp
8010297b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010297e:	c9                   	leave  
8010297f:	c3                   	ret    

80102980 <begin_op>:
{
80102980:	55                   	push   %ebp
80102981:	89 e5                	mov    %esp,%ebp
80102983:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102986:	68 a0 e4 1b 80       	push   $0x801be4a0
8010298b:	e8 78 14 00 00       	call   80103e08 <acquire>
80102990:	83 c4 10             	add    $0x10,%esp
80102993:	eb 15                	jmp    801029aa <begin_op+0x2a>
      sleep(&log, &log.lock);
80102995:	83 ec 08             	sub    $0x8,%esp
80102998:	68 a0 e4 1b 80       	push   $0x801be4a0
8010299d:	68 a0 e4 1b 80       	push   $0x801be4a0
801029a2:	e8 ff 0e 00 00       	call   801038a6 <sleep>
801029a7:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801029aa:	83 3d e0 e4 1b 80 00 	cmpl   $0x0,0x801be4e0
801029b1:	75 e2                	jne    80102995 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801029b3:	a1 dc e4 1b 80       	mov    0x801be4dc,%eax
801029b8:	83 c0 01             	add    $0x1,%eax
801029bb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801029be:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801029c1:	03 15 e8 e4 1b 80    	add    0x801be4e8,%edx
801029c7:	83 fa 1e             	cmp    $0x1e,%edx
801029ca:	7e 17                	jle    801029e3 <begin_op+0x63>
      sleep(&log, &log.lock);
801029cc:	83 ec 08             	sub    $0x8,%esp
801029cf:	68 a0 e4 1b 80       	push   $0x801be4a0
801029d4:	68 a0 e4 1b 80       	push   $0x801be4a0
801029d9:	e8 c8 0e 00 00       	call   801038a6 <sleep>
801029de:	83 c4 10             	add    $0x10,%esp
801029e1:	eb c7                	jmp    801029aa <begin_op+0x2a>
      log.outstanding += 1;
801029e3:	a3 dc e4 1b 80       	mov    %eax,0x801be4dc
      release(&log.lock);
801029e8:	83 ec 0c             	sub    $0xc,%esp
801029eb:	68 a0 e4 1b 80       	push   $0x801be4a0
801029f0:	e8 78 14 00 00       	call   80103e6d <release>
}
801029f5:	83 c4 10             	add    $0x10,%esp
801029f8:	c9                   	leave  
801029f9:	c3                   	ret    

801029fa <end_op>:
{
801029fa:	55                   	push   %ebp
801029fb:	89 e5                	mov    %esp,%ebp
801029fd:	53                   	push   %ebx
801029fe:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102a01:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a06:	e8 fd 13 00 00       	call   80103e08 <acquire>
  log.outstanding -= 1;
80102a0b:	a1 dc e4 1b 80       	mov    0x801be4dc,%eax
80102a10:	83 e8 01             	sub    $0x1,%eax
80102a13:	a3 dc e4 1b 80       	mov    %eax,0x801be4dc
  if(log.committing)
80102a18:	8b 1d e0 e4 1b 80    	mov    0x801be4e0,%ebx
80102a1e:	83 c4 10             	add    $0x10,%esp
80102a21:	85 db                	test   %ebx,%ebx
80102a23:	75 2c                	jne    80102a51 <end_op+0x57>
  if(log.outstanding == 0){
80102a25:	85 c0                	test   %eax,%eax
80102a27:	75 35                	jne    80102a5e <end_op+0x64>
    log.committing = 1;
80102a29:	c7 05 e0 e4 1b 80 01 	movl   $0x1,0x801be4e0
80102a30:	00 00 00 
    do_commit = 1;
80102a33:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102a38:	83 ec 0c             	sub    $0xc,%esp
80102a3b:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a40:	e8 28 14 00 00       	call   80103e6d <release>
  if(do_commit){
80102a45:	83 c4 10             	add    $0x10,%esp
80102a48:	85 db                	test   %ebx,%ebx
80102a4a:	75 24                	jne    80102a70 <end_op+0x76>
}
80102a4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a4f:	c9                   	leave  
80102a50:	c3                   	ret    
    panic("log.committing");
80102a51:	83 ec 0c             	sub    $0xc,%esp
80102a54:	68 c4 6b 10 80       	push   $0x80106bc4
80102a59:	e8 ea d8 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102a5e:	83 ec 0c             	sub    $0xc,%esp
80102a61:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a66:	e8 a0 0f 00 00       	call   80103a0b <wakeup>
80102a6b:	83 c4 10             	add    $0x10,%esp
80102a6e:	eb c8                	jmp    80102a38 <end_op+0x3e>
    commit();
80102a70:	e8 91 fe ff ff       	call   80102906 <commit>
    acquire(&log.lock);
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 a0 e4 1b 80       	push   $0x801be4a0
80102a7d:	e8 86 13 00 00       	call   80103e08 <acquire>
    log.committing = 0;
80102a82:	c7 05 e0 e4 1b 80 00 	movl   $0x0,0x801be4e0
80102a89:	00 00 00 
    wakeup(&log);
80102a8c:	c7 04 24 a0 e4 1b 80 	movl   $0x801be4a0,(%esp)
80102a93:	e8 73 0f 00 00       	call   80103a0b <wakeup>
    release(&log.lock);
80102a98:	c7 04 24 a0 e4 1b 80 	movl   $0x801be4a0,(%esp)
80102a9f:	e8 c9 13 00 00       	call   80103e6d <release>
80102aa4:	83 c4 10             	add    $0x10,%esp
}
80102aa7:	eb a3                	jmp    80102a4c <end_op+0x52>

80102aa9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102aa9:	55                   	push   %ebp
80102aaa:	89 e5                	mov    %esp,%ebp
80102aac:	53                   	push   %ebx
80102aad:	83 ec 04             	sub    $0x4,%esp
80102ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102ab3:	8b 15 e8 e4 1b 80    	mov    0x801be4e8,%edx
80102ab9:	83 fa 1d             	cmp    $0x1d,%edx
80102abc:	7f 45                	jg     80102b03 <log_write+0x5a>
80102abe:	a1 d8 e4 1b 80       	mov    0x801be4d8,%eax
80102ac3:	83 e8 01             	sub    $0x1,%eax
80102ac6:	39 c2                	cmp    %eax,%edx
80102ac8:	7d 39                	jge    80102b03 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102aca:	83 3d dc e4 1b 80 00 	cmpl   $0x0,0x801be4dc
80102ad1:	7e 3d                	jle    80102b10 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102ad3:	83 ec 0c             	sub    $0xc,%esp
80102ad6:	68 a0 e4 1b 80       	push   $0x801be4a0
80102adb:	e8 28 13 00 00       	call   80103e08 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102ae0:	83 c4 10             	add    $0x10,%esp
80102ae3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ae8:	8b 15 e8 e4 1b 80    	mov    0x801be4e8,%edx
80102aee:	39 c2                	cmp    %eax,%edx
80102af0:	7e 2b                	jle    80102b1d <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102af2:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102af5:	39 0c 85 ec e4 1b 80 	cmp    %ecx,-0x7fe41b14(,%eax,4)
80102afc:	74 1f                	je     80102b1d <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102afe:	83 c0 01             	add    $0x1,%eax
80102b01:	eb e5                	jmp    80102ae8 <log_write+0x3f>
    panic("too big a transaction");
80102b03:	83 ec 0c             	sub    $0xc,%esp
80102b06:	68 d3 6b 10 80       	push   $0x80106bd3
80102b0b:	e8 38 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102b10:	83 ec 0c             	sub    $0xc,%esp
80102b13:	68 e9 6b 10 80       	push   $0x80106be9
80102b18:	e8 2b d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102b1d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102b20:	89 0c 85 ec e4 1b 80 	mov    %ecx,-0x7fe41b14(,%eax,4)
  if (i == log.lh.n)
80102b27:	39 c2                	cmp    %eax,%edx
80102b29:	74 18                	je     80102b43 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102b2b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102b2e:	83 ec 0c             	sub    $0xc,%esp
80102b31:	68 a0 e4 1b 80       	push   $0x801be4a0
80102b36:	e8 32 13 00 00       	call   80103e6d <release>
}
80102b3b:	83 c4 10             	add    $0x10,%esp
80102b3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b41:	c9                   	leave  
80102b42:	c3                   	ret    
    log.lh.n++;
80102b43:	83 c2 01             	add    $0x1,%edx
80102b46:	89 15 e8 e4 1b 80    	mov    %edx,0x801be4e8
80102b4c:	eb dd                	jmp    80102b2b <log_write+0x82>

80102b4e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102b4e:	55                   	push   %ebp
80102b4f:	89 e5                	mov    %esp,%ebp
80102b51:	53                   	push   %ebx
80102b52:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b55:	68 8a 00 00 00       	push   $0x8a
80102b5a:	68 8c a4 10 80       	push   $0x8010a48c
80102b5f:	68 00 70 00 80       	push   $0x80007000
80102b64:	e8 c6 13 00 00       	call   80103f2f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b69:	83 c4 10             	add    $0x10,%esp
80102b6c:	bb a0 e5 1b 80       	mov    $0x801be5a0,%ebx
80102b71:	eb 06                	jmp    80102b79 <startothers+0x2b>
80102b73:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b79:	69 05 20 eb 1b 80 b0 	imul   $0xb0,0x801beb20,%eax
80102b80:	00 00 00 
80102b83:	05 a0 e5 1b 80       	add    $0x801be5a0,%eax
80102b88:	39 d8                	cmp    %ebx,%eax
80102b8a:	76 4c                	jbe    80102bd8 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102b8c:	e8 f0 07 00 00       	call   80103381 <mycpu>
80102b91:	39 d8                	cmp    %ebx,%eax
80102b93:	74 de                	je     80102b73 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102b95:	e8 21 f5 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b9a:	05 00 10 00 00       	add    $0x1000,%eax
80102b9f:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102ba4:	c7 05 f8 6f 00 80 1c 	movl   $0x80102c1c,0x80006ff8
80102bab:	2c 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102bae:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102bb5:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102bb8:	83 ec 08             	sub    $0x8,%esp
80102bbb:	68 00 70 00 00       	push   $0x7000
80102bc0:	0f b6 03             	movzbl (%ebx),%eax
80102bc3:	50                   	push   %eax
80102bc4:	e8 c6 f9 ff ff       	call   8010258f <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102bc9:	83 c4 10             	add    $0x10,%esp
80102bcc:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102bd2:	85 c0                	test   %eax,%eax
80102bd4:	74 f6                	je     80102bcc <startothers+0x7e>
80102bd6:	eb 9b                	jmp    80102b73 <startothers+0x25>
      ;
  }
}
80102bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102bdb:	c9                   	leave  
80102bdc:	c3                   	ret    

80102bdd <mpmain>:
{
80102bdd:	55                   	push   %ebp
80102bde:	89 e5                	mov    %esp,%ebp
80102be0:	53                   	push   %ebx
80102be1:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102be4:	e8 f4 07 00 00       	call   801033dd <cpuid>
80102be9:	89 c3                	mov    %eax,%ebx
80102beb:	e8 ed 07 00 00       	call   801033dd <cpuid>
80102bf0:	83 ec 04             	sub    $0x4,%esp
80102bf3:	53                   	push   %ebx
80102bf4:	50                   	push   %eax
80102bf5:	68 04 6c 10 80       	push   $0x80106c04
80102bfa:	e8 0c da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102bff:	e8 89 24 00 00       	call   8010508d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102c04:	e8 78 07 00 00       	call   80103381 <mycpu>
80102c09:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102c0b:	b8 01 00 00 00       	mov    $0x1,%eax
80102c10:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102c17:	e8 65 0a 00 00       	call   80103681 <scheduler>

80102c1c <mpenter>:
{
80102c1c:	55                   	push   %ebp
80102c1d:	89 e5                	mov    %esp,%ebp
80102c1f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102c22:	e8 6f 34 00 00       	call   80106096 <switchkvm>
  seginit();
80102c27:	e8 1e 33 00 00       	call   80105f4a <seginit>
  lapicinit();
80102c2c:	e8 15 f8 ff ff       	call   80102446 <lapicinit>
  mpmain();
80102c31:	e8 a7 ff ff ff       	call   80102bdd <mpmain>

80102c36 <main>:
{
80102c36:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102c3a:	83 e4 f0             	and    $0xfffffff0,%esp
80102c3d:	ff 71 fc             	pushl  -0x4(%ecx)
80102c40:	55                   	push   %ebp
80102c41:	89 e5                	mov    %esp,%ebp
80102c43:	51                   	push   %ecx
80102c44:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102c47:	68 00 00 40 80       	push   $0x80400000
80102c4c:	68 c8 12 1c 80       	push   $0x801c12c8
80102c51:	e8 13 f4 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102c56:	e8 c8 38 00 00       	call   80106523 <kvmalloc>
  mpinit();        // detect other processors
80102c5b:	e8 c9 01 00 00       	call   80102e29 <mpinit>
  lapicinit();     // interrupt controller
80102c60:	e8 e1 f7 ff ff       	call   80102446 <lapicinit>
  seginit();       // segment descriptors
80102c65:	e8 e0 32 00 00       	call   80105f4a <seginit>
  picinit();       // disable pic
80102c6a:	e8 82 02 00 00       	call   80102ef1 <picinit>
  ioapicinit();    // another interrupt controller
80102c6f:	e8 86 f2 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102c74:	e8 15 dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c79:	e8 bd 26 00 00       	call   8010533b <uartinit>
  pinit();         // process table
80102c7e:	e8 e4 06 00 00       	call   80103367 <pinit>
  tvinit();        // trap vectors
80102c83:	e8 54 23 00 00       	call   80104fdc <tvinit>
  binit();         // buffer cache
80102c88:	e8 67 d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c8d:	e8 81 df ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102c92:	e8 69 f0 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102c97:	e8 b2 fe ff ff       	call   80102b4e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c9c:	83 c4 08             	add    $0x8,%esp
80102c9f:	68 00 00 00 8e       	push   $0x8e000000
80102ca4:	68 00 00 40 80       	push   $0x80400000
80102ca9:	e8 ed f3 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102cae:	e8 69 07 00 00       	call   8010341c <userinit>
  mpmain();        // finish this processor's setup
80102cb3:	e8 25 ff ff ff       	call   80102bdd <mpmain>

80102cb8 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	56                   	push   %esi
80102cbc:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102cc2:	b9 00 00 00 00       	mov    $0x0,%ecx
80102cc7:	eb 09                	jmp    80102cd2 <sum+0x1a>
    sum += addr[i];
80102cc9:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102ccd:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102ccf:	83 c1 01             	add    $0x1,%ecx
80102cd2:	39 d1                	cmp    %edx,%ecx
80102cd4:	7c f3                	jl     80102cc9 <sum+0x11>
  return sum;
}
80102cd6:	89 d8                	mov    %ebx,%eax
80102cd8:	5b                   	pop    %ebx
80102cd9:	5e                   	pop    %esi
80102cda:	5d                   	pop    %ebp
80102cdb:	c3                   	ret    

80102cdc <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	56                   	push   %esi
80102ce0:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102ce1:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102ce7:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102ce9:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102ceb:	eb 03                	jmp    80102cf0 <mpsearch1+0x14>
80102ced:	83 c3 10             	add    $0x10,%ebx
80102cf0:	39 f3                	cmp    %esi,%ebx
80102cf2:	73 29                	jae    80102d1d <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102cf4:	83 ec 04             	sub    $0x4,%esp
80102cf7:	6a 04                	push   $0x4
80102cf9:	68 18 6c 10 80       	push   $0x80106c18
80102cfe:	53                   	push   %ebx
80102cff:	e8 f6 11 00 00       	call   80103efa <memcmp>
80102d04:	83 c4 10             	add    $0x10,%esp
80102d07:	85 c0                	test   %eax,%eax
80102d09:	75 e2                	jne    80102ced <mpsearch1+0x11>
80102d0b:	ba 10 00 00 00       	mov    $0x10,%edx
80102d10:	89 d8                	mov    %ebx,%eax
80102d12:	e8 a1 ff ff ff       	call   80102cb8 <sum>
80102d17:	84 c0                	test   %al,%al
80102d19:	75 d2                	jne    80102ced <mpsearch1+0x11>
80102d1b:	eb 05                	jmp    80102d22 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102d22:	89 d8                	mov    %ebx,%eax
80102d24:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102d27:	5b                   	pop    %ebx
80102d28:	5e                   	pop    %esi
80102d29:	5d                   	pop    %ebp
80102d2a:	c3                   	ret    

80102d2b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102d2b:	55                   	push   %ebp
80102d2c:	89 e5                	mov    %esp,%ebp
80102d2e:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102d31:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102d38:	c1 e0 08             	shl    $0x8,%eax
80102d3b:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102d42:	09 d0                	or     %edx,%eax
80102d44:	c1 e0 04             	shl    $0x4,%eax
80102d47:	85 c0                	test   %eax,%eax
80102d49:	74 1f                	je     80102d6a <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102d4b:	ba 00 04 00 00       	mov    $0x400,%edx
80102d50:	e8 87 ff ff ff       	call   80102cdc <mpsearch1>
80102d55:	85 c0                	test   %eax,%eax
80102d57:	75 0f                	jne    80102d68 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d59:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d5e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d63:	e8 74 ff ff ff       	call   80102cdc <mpsearch1>
}
80102d68:	c9                   	leave  
80102d69:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d6a:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d71:	c1 e0 08             	shl    $0x8,%eax
80102d74:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d7b:	09 d0                	or     %edx,%eax
80102d7d:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d80:	2d 00 04 00 00       	sub    $0x400,%eax
80102d85:	ba 00 04 00 00       	mov    $0x400,%edx
80102d8a:	e8 4d ff ff ff       	call   80102cdc <mpsearch1>
80102d8f:	85 c0                	test   %eax,%eax
80102d91:	75 d5                	jne    80102d68 <mpsearch+0x3d>
80102d93:	eb c4                	jmp    80102d59 <mpsearch+0x2e>

80102d95 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d95:	55                   	push   %ebp
80102d96:	89 e5                	mov    %esp,%ebp
80102d98:	57                   	push   %edi
80102d99:	56                   	push   %esi
80102d9a:	53                   	push   %ebx
80102d9b:	83 ec 1c             	sub    $0x1c,%esp
80102d9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102da1:	e8 85 ff ff ff       	call   80102d2b <mpsearch>
80102da6:	85 c0                	test   %eax,%eax
80102da8:	74 5c                	je     80102e06 <mpconfig+0x71>
80102daa:	89 c7                	mov    %eax,%edi
80102dac:	8b 58 04             	mov    0x4(%eax),%ebx
80102daf:	85 db                	test   %ebx,%ebx
80102db1:	74 5a                	je     80102e0d <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102db3:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102db9:	83 ec 04             	sub    $0x4,%esp
80102dbc:	6a 04                	push   $0x4
80102dbe:	68 1d 6c 10 80       	push   $0x80106c1d
80102dc3:	56                   	push   %esi
80102dc4:	e8 31 11 00 00       	call   80103efa <memcmp>
80102dc9:	83 c4 10             	add    $0x10,%esp
80102dcc:	85 c0                	test   %eax,%eax
80102dce:	75 44                	jne    80102e14 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102dd0:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102dd7:	3c 01                	cmp    $0x1,%al
80102dd9:	0f 95 c2             	setne  %dl
80102ddc:	3c 04                	cmp    $0x4,%al
80102dde:	0f 95 c0             	setne  %al
80102de1:	84 c2                	test   %al,%dl
80102de3:	75 36                	jne    80102e1b <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102de5:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102dec:	89 f0                	mov    %esi,%eax
80102dee:	e8 c5 fe ff ff       	call   80102cb8 <sum>
80102df3:	84 c0                	test   %al,%al
80102df5:	75 2b                	jne    80102e22 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dfa:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102dfc:	89 f0                	mov    %esi,%eax
80102dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e01:	5b                   	pop    %ebx
80102e02:	5e                   	pop    %esi
80102e03:	5f                   	pop    %edi
80102e04:	5d                   	pop    %ebp
80102e05:	c3                   	ret    
    return 0;
80102e06:	be 00 00 00 00       	mov    $0x0,%esi
80102e0b:	eb ef                	jmp    80102dfc <mpconfig+0x67>
80102e0d:	be 00 00 00 00       	mov    $0x0,%esi
80102e12:	eb e8                	jmp    80102dfc <mpconfig+0x67>
    return 0;
80102e14:	be 00 00 00 00       	mov    $0x0,%esi
80102e19:	eb e1                	jmp    80102dfc <mpconfig+0x67>
    return 0;
80102e1b:	be 00 00 00 00       	mov    $0x0,%esi
80102e20:	eb da                	jmp    80102dfc <mpconfig+0x67>
    return 0;
80102e22:	be 00 00 00 00       	mov    $0x0,%esi
80102e27:	eb d3                	jmp    80102dfc <mpconfig+0x67>

80102e29 <mpinit>:

void
mpinit(void)
{
80102e29:	55                   	push   %ebp
80102e2a:	89 e5                	mov    %esp,%ebp
80102e2c:	57                   	push   %edi
80102e2d:	56                   	push   %esi
80102e2e:	53                   	push   %ebx
80102e2f:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102e32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102e35:	e8 5b ff ff ff       	call   80102d95 <mpconfig>
80102e3a:	85 c0                	test   %eax,%eax
80102e3c:	74 19                	je     80102e57 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102e3e:	8b 50 24             	mov    0x24(%eax),%edx
80102e41:	89 15 80 e4 1b 80    	mov    %edx,0x801be480
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e47:	8d 50 2c             	lea    0x2c(%eax),%edx
80102e4a:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102e4e:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102e50:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e55:	eb 34                	jmp    80102e8b <mpinit+0x62>
    panic("Expect to run on an SMP");
80102e57:	83 ec 0c             	sub    $0xc,%esp
80102e5a:	68 22 6c 10 80       	push   $0x80106c22
80102e5f:	e8 e4 d4 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e64:	8b 35 20 eb 1b 80    	mov    0x801beb20,%esi
80102e6a:	83 fe 07             	cmp    $0x7,%esi
80102e6d:	7f 19                	jg     80102e88 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e6f:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e73:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e79:	88 87 a0 e5 1b 80    	mov    %al,-0x7fe41a60(%edi)
        ncpu++;
80102e7f:	83 c6 01             	add    $0x1,%esi
80102e82:	89 35 20 eb 1b 80    	mov    %esi,0x801beb20
      }
      p += sizeof(struct mpproc);
80102e88:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e8b:	39 ca                	cmp    %ecx,%edx
80102e8d:	73 2b                	jae    80102eba <mpinit+0x91>
    switch(*p){
80102e8f:	0f b6 02             	movzbl (%edx),%eax
80102e92:	3c 04                	cmp    $0x4,%al
80102e94:	77 1d                	ja     80102eb3 <mpinit+0x8a>
80102e96:	0f b6 c0             	movzbl %al,%eax
80102e99:	ff 24 85 5c 6c 10 80 	jmp    *-0x7fef93a4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102ea0:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102ea4:	a2 80 e5 1b 80       	mov    %al,0x801be580
      p += sizeof(struct mpioapic);
80102ea9:	83 c2 08             	add    $0x8,%edx
      continue;
80102eac:	eb dd                	jmp    80102e8b <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102eae:	83 c2 08             	add    $0x8,%edx
      continue;
80102eb1:	eb d8                	jmp    80102e8b <mpinit+0x62>
    default:
      ismp = 0;
80102eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
80102eb8:	eb d1                	jmp    80102e8b <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102eba:	85 db                	test   %ebx,%ebx
80102ebc:	74 26                	je     80102ee4 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ec1:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102ec5:	74 15                	je     80102edc <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ec7:	b8 70 00 00 00       	mov    $0x70,%eax
80102ecc:	ba 22 00 00 00       	mov    $0x22,%edx
80102ed1:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ed2:	ba 23 00 00 00       	mov    $0x23,%edx
80102ed7:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102ed8:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102edb:	ee                   	out    %al,(%dx)
  }
}
80102edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102edf:	5b                   	pop    %ebx
80102ee0:	5e                   	pop    %esi
80102ee1:	5f                   	pop    %edi
80102ee2:	5d                   	pop    %ebp
80102ee3:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102ee4:	83 ec 0c             	sub    $0xc,%esp
80102ee7:	68 3c 6c 10 80       	push   $0x80106c3c
80102eec:	e8 57 d4 ff ff       	call   80100348 <panic>

80102ef1 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102ef1:	55                   	push   %ebp
80102ef2:	89 e5                	mov    %esp,%ebp
80102ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ef9:	ba 21 00 00 00       	mov    $0x21,%edx
80102efe:	ee                   	out    %al,(%dx)
80102eff:	ba a1 00 00 00       	mov    $0xa1,%edx
80102f04:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102f05:	5d                   	pop    %ebp
80102f06:	c3                   	ret    

80102f07 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102f07:	55                   	push   %ebp
80102f08:	89 e5                	mov    %esp,%ebp
80102f0a:	57                   	push   %edi
80102f0b:	56                   	push   %esi
80102f0c:	53                   	push   %ebx
80102f0d:	83 ec 0c             	sub    $0xc,%esp
80102f10:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f13:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102f16:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102f1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102f22:	e8 06 dd ff ff       	call   80100c2d <filealloc>
80102f27:	89 03                	mov    %eax,(%ebx)
80102f29:	85 c0                	test   %eax,%eax
80102f2b:	74 16                	je     80102f43 <pipealloc+0x3c>
80102f2d:	e8 fb dc ff ff       	call   80100c2d <filealloc>
80102f32:	89 06                	mov    %eax,(%esi)
80102f34:	85 c0                	test   %eax,%eax
80102f36:	74 0b                	je     80102f43 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102f38:	e8 7e f1 ff ff       	call   801020bb <kalloc>
80102f3d:	89 c7                	mov    %eax,%edi
80102f3f:	85 c0                	test   %eax,%eax
80102f41:	75 35                	jne    80102f78 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f43:	8b 03                	mov    (%ebx),%eax
80102f45:	85 c0                	test   %eax,%eax
80102f47:	74 0c                	je     80102f55 <pipealloc+0x4e>
    fileclose(*f0);
80102f49:	83 ec 0c             	sub    $0xc,%esp
80102f4c:	50                   	push   %eax
80102f4d:	e8 81 dd ff ff       	call   80100cd3 <fileclose>
80102f52:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f55:	8b 06                	mov    (%esi),%eax
80102f57:	85 c0                	test   %eax,%eax
80102f59:	0f 84 8b 00 00 00    	je     80102fea <pipealloc+0xe3>
    fileclose(*f1);
80102f5f:	83 ec 0c             	sub    $0xc,%esp
80102f62:	50                   	push   %eax
80102f63:	e8 6b dd ff ff       	call   80100cd3 <fileclose>
80102f68:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f73:	5b                   	pop    %ebx
80102f74:	5e                   	pop    %esi
80102f75:	5f                   	pop    %edi
80102f76:	5d                   	pop    %ebp
80102f77:	c3                   	ret    
  p->readopen = 1;
80102f78:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f7f:	00 00 00 
  p->writeopen = 1;
80102f82:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f89:	00 00 00 
  p->nwrite = 0;
80102f8c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f93:	00 00 00 
  p->nread = 0;
80102f96:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f9d:	00 00 00 
  initlock(&p->lock, "pipe");
80102fa0:	83 ec 08             	sub    $0x8,%esp
80102fa3:	68 70 6c 10 80       	push   $0x80106c70
80102fa8:	50                   	push   %eax
80102fa9:	e8 1e 0d 00 00       	call   80103ccc <initlock>
  (*f0)->type = FD_PIPE;
80102fae:	8b 03                	mov    (%ebx),%eax
80102fb0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102fb6:	8b 03                	mov    (%ebx),%eax
80102fb8:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102fbc:	8b 03                	mov    (%ebx),%eax
80102fbe:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102fc2:	8b 03                	mov    (%ebx),%eax
80102fc4:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102fc7:	8b 06                	mov    (%esi),%eax
80102fc9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102fcf:	8b 06                	mov    (%esi),%eax
80102fd1:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102fd5:	8b 06                	mov    (%esi),%eax
80102fd7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102fdb:	8b 06                	mov    (%esi),%eax
80102fdd:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102fe0:	83 c4 10             	add    $0x10,%esp
80102fe3:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe8:	eb 86                	jmp    80102f70 <pipealloc+0x69>
  return -1;
80102fea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fef:	e9 7c ff ff ff       	jmp    80102f70 <pipealloc+0x69>

80102ff4 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102ff4:	55                   	push   %ebp
80102ff5:	89 e5                	mov    %esp,%ebp
80102ff7:	53                   	push   %ebx
80102ff8:	83 ec 10             	sub    $0x10,%esp
80102ffb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102ffe:	53                   	push   %ebx
80102fff:	e8 04 0e 00 00       	call   80103e08 <acquire>
  if(writable){
80103004:	83 c4 10             	add    $0x10,%esp
80103007:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010300b:	74 3f                	je     8010304c <pipeclose+0x58>
    p->writeopen = 0;
8010300d:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80103014:	00 00 00 
    wakeup(&p->nread);
80103017:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010301d:	83 ec 0c             	sub    $0xc,%esp
80103020:	50                   	push   %eax
80103021:	e8 e5 09 00 00       	call   80103a0b <wakeup>
80103026:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103029:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103030:	75 09                	jne    8010303b <pipeclose+0x47>
80103032:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80103039:	74 2f                	je     8010306a <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010303b:	83 ec 0c             	sub    $0xc,%esp
8010303e:	53                   	push   %ebx
8010303f:	e8 29 0e 00 00       	call   80103e6d <release>
80103044:	83 c4 10             	add    $0x10,%esp
}
80103047:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    
    p->readopen = 0;
8010304c:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103053:	00 00 00 
    wakeup(&p->nwrite);
80103056:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010305c:	83 ec 0c             	sub    $0xc,%esp
8010305f:	50                   	push   %eax
80103060:	e8 a6 09 00 00       	call   80103a0b <wakeup>
80103065:	83 c4 10             	add    $0x10,%esp
80103068:	eb bf                	jmp    80103029 <pipeclose+0x35>
    release(&p->lock);
8010306a:	83 ec 0c             	sub    $0xc,%esp
8010306d:	53                   	push   %ebx
8010306e:	e8 fa 0d 00 00       	call   80103e6d <release>
    kfree((char*)p);
80103073:	89 1c 24             	mov    %ebx,(%esp)
80103076:	e8 29 ef ff ff       	call   80101fa4 <kfree>
8010307b:	83 c4 10             	add    $0x10,%esp
8010307e:	eb c7                	jmp    80103047 <pipeclose+0x53>

80103080 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103080:	55                   	push   %ebp
80103081:	89 e5                	mov    %esp,%ebp
80103083:	57                   	push   %edi
80103084:	56                   	push   %esi
80103085:	53                   	push   %ebx
80103086:	83 ec 18             	sub    $0x18,%esp
80103089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010308c:	89 de                	mov    %ebx,%esi
8010308e:	53                   	push   %ebx
8010308f:	e8 74 0d 00 00       	call   80103e08 <acquire>
  for(i = 0; i < n; i++){
80103094:	83 c4 10             	add    $0x10,%esp
80103097:	bf 00 00 00 00       	mov    $0x0,%edi
8010309c:	3b 7d 10             	cmp    0x10(%ebp),%edi
8010309f:	0f 8d 88 00 00 00    	jge    8010312d <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801030a5:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801030ab:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030b1:	05 00 02 00 00       	add    $0x200,%eax
801030b6:	39 c2                	cmp    %eax,%edx
801030b8:	75 51                	jne    8010310b <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
801030ba:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
801030c1:	74 2f                	je     801030f2 <pipewrite+0x72>
801030c3:	e8 30 03 00 00       	call   801033f8 <myproc>
801030c8:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801030cc:	75 24                	jne    801030f2 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801030ce:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030d4:	83 ec 0c             	sub    $0xc,%esp
801030d7:	50                   	push   %eax
801030d8:	e8 2e 09 00 00       	call   80103a0b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801030dd:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030e3:	83 c4 08             	add    $0x8,%esp
801030e6:	56                   	push   %esi
801030e7:	50                   	push   %eax
801030e8:	e8 b9 07 00 00       	call   801038a6 <sleep>
801030ed:	83 c4 10             	add    $0x10,%esp
801030f0:	eb b3                	jmp    801030a5 <pipewrite+0x25>
        release(&p->lock);
801030f2:	83 ec 0c             	sub    $0xc,%esp
801030f5:	53                   	push   %ebx
801030f6:	e8 72 0d 00 00       	call   80103e6d <release>
        return -1;
801030fb:	83 c4 10             	add    $0x10,%esp
801030fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103103:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103106:	5b                   	pop    %ebx
80103107:	5e                   	pop    %esi
80103108:	5f                   	pop    %edi
80103109:	5d                   	pop    %ebp
8010310a:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010310b:	8d 42 01             	lea    0x1(%edx),%eax
8010310e:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103114:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010311a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010311d:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80103121:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103125:	83 c7 01             	add    $0x1,%edi
80103128:	e9 6f ff ff ff       	jmp    8010309c <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010312d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103133:	83 ec 0c             	sub    $0xc,%esp
80103136:	50                   	push   %eax
80103137:	e8 cf 08 00 00       	call   80103a0b <wakeup>
  release(&p->lock);
8010313c:	89 1c 24             	mov    %ebx,(%esp)
8010313f:	e8 29 0d 00 00       	call   80103e6d <release>
  return n;
80103144:	83 c4 10             	add    $0x10,%esp
80103147:	8b 45 10             	mov    0x10(%ebp),%eax
8010314a:	eb b7                	jmp    80103103 <pipewrite+0x83>

8010314c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010314c:	55                   	push   %ebp
8010314d:	89 e5                	mov    %esp,%ebp
8010314f:	57                   	push   %edi
80103150:	56                   	push   %esi
80103151:	53                   	push   %ebx
80103152:	83 ec 18             	sub    $0x18,%esp
80103155:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103158:	89 df                	mov    %ebx,%edi
8010315a:	53                   	push   %ebx
8010315b:	e8 a8 0c 00 00       	call   80103e08 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103160:	83 c4 10             	add    $0x10,%esp
80103163:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103169:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
8010316f:	75 3d                	jne    801031ae <piperead+0x62>
80103171:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103177:	85 f6                	test   %esi,%esi
80103179:	74 38                	je     801031b3 <piperead+0x67>
    if(myproc()->killed){
8010317b:	e8 78 02 00 00       	call   801033f8 <myproc>
80103180:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103184:	75 15                	jne    8010319b <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103186:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010318c:	83 ec 08             	sub    $0x8,%esp
8010318f:	57                   	push   %edi
80103190:	50                   	push   %eax
80103191:	e8 10 07 00 00       	call   801038a6 <sleep>
80103196:	83 c4 10             	add    $0x10,%esp
80103199:	eb c8                	jmp    80103163 <piperead+0x17>
      release(&p->lock);
8010319b:	83 ec 0c             	sub    $0xc,%esp
8010319e:	53                   	push   %ebx
8010319f:	e8 c9 0c 00 00       	call   80103e6d <release>
      return -1;
801031a4:	83 c4 10             	add    $0x10,%esp
801031a7:	be ff ff ff ff       	mov    $0xffffffff,%esi
801031ac:	eb 50                	jmp    801031fe <piperead+0xb2>
801031ae:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031b3:	3b 75 10             	cmp    0x10(%ebp),%esi
801031b6:	7d 2c                	jge    801031e4 <piperead+0x98>
    if(p->nread == p->nwrite)
801031b8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801031be:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801031c4:	74 1e                	je     801031e4 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801031c6:	8d 50 01             	lea    0x1(%eax),%edx
801031c9:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801031cf:	25 ff 01 00 00       	and    $0x1ff,%eax
801031d4:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801031d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801031dc:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031df:	83 c6 01             	add    $0x1,%esi
801031e2:	eb cf                	jmp    801031b3 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031e4:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031ea:	83 ec 0c             	sub    $0xc,%esp
801031ed:	50                   	push   %eax
801031ee:	e8 18 08 00 00       	call   80103a0b <wakeup>
  release(&p->lock);
801031f3:	89 1c 24             	mov    %ebx,(%esp)
801031f6:	e8 72 0c 00 00       	call   80103e6d <release>
  return i;
801031fb:	83 c4 10             	add    $0x10,%esp
}
801031fe:	89 f0                	mov    %esi,%eax
80103200:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103203:	5b                   	pop    %ebx
80103204:	5e                   	pop    %esi
80103205:	5f                   	pop    %edi
80103206:	5d                   	pop    %ebp
80103207:	c3                   	ret    

80103208 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103208:	55                   	push   %ebp
80103209:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010320b:	ba 74 eb 1b 80       	mov    $0x801beb74,%edx
80103210:	eb 03                	jmp    80103215 <wakeup1+0xd>
80103212:	83 c2 7c             	add    $0x7c,%edx
80103215:	81 fa 74 0a 1c 80    	cmp    $0x801c0a74,%edx
8010321b:	73 14                	jae    80103231 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010321d:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103221:	75 ef                	jne    80103212 <wakeup1+0xa>
80103223:	39 42 20             	cmp    %eax,0x20(%edx)
80103226:	75 ea                	jne    80103212 <wakeup1+0xa>
      p->state = RUNNABLE;
80103228:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010322f:	eb e1                	jmp    80103212 <wakeup1+0xa>
}
80103231:	5d                   	pop    %ebp
80103232:	c3                   	ret    

80103233 <allocproc>:
{
80103233:	55                   	push   %ebp
80103234:	89 e5                	mov    %esp,%ebp
80103236:	56                   	push   %esi
80103237:	53                   	push   %ebx
80103238:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010323a:	83 ec 0c             	sub    $0xc,%esp
8010323d:	68 40 eb 1b 80       	push   $0x801beb40
80103242:	e8 c1 0b 00 00       	call   80103e08 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103247:	83 c4 10             	add    $0x10,%esp
8010324a:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
8010324f:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103255:	73 0b                	jae    80103262 <allocproc+0x2f>
    if(p->state == UNUSED)
80103257:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010325b:	74 1c                	je     80103279 <allocproc+0x46>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010325d:	83 c3 7c             	add    $0x7c,%ebx
80103260:	eb ed                	jmp    8010324f <allocproc+0x1c>
  release(&ptable.lock);
80103262:	83 ec 0c             	sub    $0xc,%esp
80103265:	68 40 eb 1b 80       	push   $0x801beb40
8010326a:	e8 fe 0b 00 00       	call   80103e6d <release>
  return 0;
8010326f:	83 c4 10             	add    $0x10,%esp
80103272:	bb 00 00 00 00       	mov    $0x0,%ebx
80103277:	eb 7a                	jmp    801032f3 <allocproc+0xc0>
  p->state = EMBRYO;
80103279:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103280:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103285:	8d 50 01             	lea    0x1(%eax),%edx
80103288:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
8010328e:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103291:	83 ec 0c             	sub    $0xc,%esp
80103294:	68 40 eb 1b 80       	push   $0x801beb40
80103299:	e8 cf 0b 00 00       	call   80103e6d <release>
  if(c == -1) {
8010329e:	83 c4 10             	add    $0x10,%esp
801032a1:	83 fe ff             	cmp    $0xffffffff,%esi
801032a4:	74 56                	je     801032fc <allocproc+0xc9>
   if((p->kstack = kalloc1a(p->pid)) == 0) {
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	ff 73 10             	pushl  0x10(%ebx)
801032ac:	e8 8c ee ff ff       	call   8010213d <kalloc1a>
801032b1:	89 43 08             	mov    %eax,0x8(%ebx)
801032b4:	83 c4 10             	add    $0x10,%esp
801032b7:	85 c0                	test   %eax,%eax
801032b9:	74 5b                	je     80103316 <allocproc+0xe3>
  sp = p->kstack + KSTACKSIZE;
801032bb:	8b 43 08             	mov    0x8(%ebx),%eax
  sp -= sizeof *p->tf;
801032be:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801032c4:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801032c7:	c7 80 b0 0f 00 00 d1 	movl   $0x80104fd1,0xfb0(%eax)
801032ce:	4f 10 80 
  sp -= sizeof *p->context;
801032d1:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801032d6:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801032d9:	83 ec 04             	sub    $0x4,%esp
801032dc:	6a 14                	push   $0x14
801032de:	6a 00                	push   $0x0
801032e0:	50                   	push   %eax
801032e1:	e8 ce 0b 00 00       	call   80103eb4 <memset>
  p->context->eip = (uint)forkret;
801032e6:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032e9:	c7 40 10 24 33 10 80 	movl   $0x80103324,0x10(%eax)
  return p;
801032f0:	83 c4 10             	add    $0x10,%esp
}
801032f3:	89 d8                	mov    %ebx,%eax
801032f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801032f8:	5b                   	pop    %ebx
801032f9:	5e                   	pop    %esi
801032fa:	5d                   	pop    %ebp
801032fb:	c3                   	ret    
    if((p->kstack = kalloc()) == 0){
801032fc:	e8 ba ed ff ff       	call   801020bb <kalloc>
80103301:	89 43 08             	mov    %eax,0x8(%ebx)
80103304:	85 c0                	test   %eax,%eax
80103306:	75 b3                	jne    801032bb <allocproc+0x88>
        p->state = UNUSED;
80103308:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        return 0;
8010330f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103314:	eb dd                	jmp    801032f3 <allocproc+0xc0>
       p->state = UNUSED;
80103316:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
       return 0;
8010331d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103322:	eb cf                	jmp    801032f3 <allocproc+0xc0>

80103324 <forkret>:
{
80103324:	55                   	push   %ebp
80103325:	89 e5                	mov    %esp,%ebp
80103327:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010332a:	68 40 eb 1b 80       	push   $0x801beb40
8010332f:	e8 39 0b 00 00       	call   80103e6d <release>
  if (first) {
80103334:	83 c4 10             	add    $0x10,%esp
80103337:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010333e:	75 02                	jne    80103342 <forkret+0x1e>
}
80103340:	c9                   	leave  
80103341:	c3                   	ret    
    first = 0;
80103342:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103349:	00 00 00 
    iinit(ROOTDEV);
8010334c:	83 ec 0c             	sub    $0xc,%esp
8010334f:	6a 01                	push   $0x1
80103351:	e8 96 df ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
80103356:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010335d:	e8 d5 f5 ff ff       	call   80102937 <initlog>
80103362:	83 c4 10             	add    $0x10,%esp
}
80103365:	eb d9                	jmp    80103340 <forkret+0x1c>

80103367 <pinit>:
{
80103367:	55                   	push   %ebp
80103368:	89 e5                	mov    %esp,%ebp
8010336a:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010336d:	68 75 6c 10 80       	push   $0x80106c75
80103372:	68 40 eb 1b 80       	push   $0x801beb40
80103377:	e8 50 09 00 00       	call   80103ccc <initlock>
}
8010337c:	83 c4 10             	add    $0x10,%esp
8010337f:	c9                   	leave  
80103380:	c3                   	ret    

80103381 <mycpu>:
{
80103381:	55                   	push   %ebp
80103382:	89 e5                	mov    %esp,%ebp
80103384:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103387:	9c                   	pushf  
80103388:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103389:	f6 c4 02             	test   $0x2,%ah
8010338c:	75 28                	jne    801033b6 <mycpu+0x35>
  apicid = lapicid();
8010338e:	e8 bd f1 ff ff       	call   80102550 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103393:	ba 00 00 00 00       	mov    $0x0,%edx
80103398:	39 15 20 eb 1b 80    	cmp    %edx,0x801beb20
8010339e:	7e 23                	jle    801033c3 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801033a0:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801033a6:	0f b6 89 a0 e5 1b 80 	movzbl -0x7fe41a60(%ecx),%ecx
801033ad:	39 c1                	cmp    %eax,%ecx
801033af:	74 1f                	je     801033d0 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801033b1:	83 c2 01             	add    $0x1,%edx
801033b4:	eb e2                	jmp    80103398 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801033b6:	83 ec 0c             	sub    $0xc,%esp
801033b9:	68 58 6d 10 80       	push   $0x80106d58
801033be:	e8 85 cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
801033c3:	83 ec 0c             	sub    $0xc,%esp
801033c6:	68 7c 6c 10 80       	push   $0x80106c7c
801033cb:	e8 78 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
801033d0:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801033d6:	05 a0 e5 1b 80       	add    $0x801be5a0,%eax
}
801033db:	c9                   	leave  
801033dc:	c3                   	ret    

801033dd <cpuid>:
cpuid() {
801033dd:	55                   	push   %ebp
801033de:	89 e5                	mov    %esp,%ebp
801033e0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801033e3:	e8 99 ff ff ff       	call   80103381 <mycpu>
801033e8:	2d a0 e5 1b 80       	sub    $0x801be5a0,%eax
801033ed:	c1 f8 04             	sar    $0x4,%eax
801033f0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801033f6:	c9                   	leave  
801033f7:	c3                   	ret    

801033f8 <myproc>:
myproc(void) {
801033f8:	55                   	push   %ebp
801033f9:	89 e5                	mov    %esp,%ebp
801033fb:	53                   	push   %ebx
801033fc:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801033ff:	e8 27 09 00 00       	call   80103d2b <pushcli>
  c = mycpu();
80103404:	e8 78 ff ff ff       	call   80103381 <mycpu>
  p = c->proc;
80103409:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010340f:	e8 54 09 00 00       	call   80103d68 <popcli>
}
80103414:	89 d8                	mov    %ebx,%eax
80103416:	83 c4 04             	add    $0x4,%esp
80103419:	5b                   	pop    %ebx
8010341a:	5d                   	pop    %ebp
8010341b:	c3                   	ret    

8010341c <userinit>:
{
8010341c:	55                   	push   %ebp
8010341d:	89 e5                	mov    %esp,%ebp
8010341f:	53                   	push   %ebx
80103420:	83 ec 04             	sub    $0x4,%esp
  p = allocproc(0);
80103423:	b8 00 00 00 00       	mov    $0x0,%eax
80103428:	e8 06 fe ff ff       	call   80103233 <allocproc>
8010342d:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010342f:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
80103434:	e8 7c 30 00 00       	call   801064b5 <setupkvm>
80103439:	89 43 04             	mov    %eax,0x4(%ebx)
8010343c:	85 c0                	test   %eax,%eax
8010343e:	0f 84 b7 00 00 00    	je     801034fb <userinit+0xdf>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103444:	83 ec 04             	sub    $0x4,%esp
80103447:	68 2c 00 00 00       	push   $0x2c
8010344c:	68 60 a4 10 80       	push   $0x8010a460
80103451:	50                   	push   %eax
80103452:	e8 69 2d 00 00       	call   801061c0 <inituvm>
  p->sz = PGSIZE;
80103457:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010345d:	83 c4 0c             	add    $0xc,%esp
80103460:	6a 4c                	push   $0x4c
80103462:	6a 00                	push   $0x0
80103464:	ff 73 18             	pushl  0x18(%ebx)
80103467:	e8 48 0a 00 00       	call   80103eb4 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010346c:	8b 43 18             	mov    0x18(%ebx),%eax
8010346f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103475:	8b 43 18             	mov    0x18(%ebx),%eax
80103478:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010347e:	8b 43 18             	mov    0x18(%ebx),%eax
80103481:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103485:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103489:	8b 43 18             	mov    0x18(%ebx),%eax
8010348c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103490:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103494:	8b 43 18             	mov    0x18(%ebx),%eax
80103497:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010349e:	8b 43 18             	mov    0x18(%ebx),%eax
801034a1:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801034a8:	8b 43 18             	mov    0x18(%ebx),%eax
801034ab:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801034b2:	8d 43 6c             	lea    0x6c(%ebx),%eax
801034b5:	83 c4 0c             	add    $0xc,%esp
801034b8:	6a 10                	push   $0x10
801034ba:	68 a5 6c 10 80       	push   $0x80106ca5
801034bf:	50                   	push   %eax
801034c0:	e8 56 0b 00 00       	call   8010401b <safestrcpy>
  p->cwd = namei("/");
801034c5:	c7 04 24 ae 6c 10 80 	movl   $0x80106cae,(%esp)
801034cc:	e8 10 e7 ff ff       	call   80101be1 <namei>
801034d1:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801034d4:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801034db:	e8 28 09 00 00       	call   80103e08 <acquire>
  p->state = RUNNABLE;
801034e0:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801034e7:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801034ee:	e8 7a 09 00 00       	call   80103e6d <release>
}
801034f3:	83 c4 10             	add    $0x10,%esp
801034f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801034f9:	c9                   	leave  
801034fa:	c3                   	ret    
    panic("userinit: out of memory?");
801034fb:	83 ec 0c             	sub    $0xc,%esp
801034fe:	68 8c 6c 10 80       	push   $0x80106c8c
80103503:	e8 40 ce ff ff       	call   80100348 <panic>

80103508 <growproc>:
{
80103508:	55                   	push   %ebp
80103509:	89 e5                	mov    %esp,%ebp
8010350b:	56                   	push   %esi
8010350c:	53                   	push   %ebx
8010350d:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103510:	e8 e3 fe ff ff       	call   801033f8 <myproc>
80103515:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103517:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103519:	85 f6                	test   %esi,%esi
8010351b:	7f 21                	jg     8010353e <growproc+0x36>
  } else if(n < 0){
8010351d:	85 f6                	test   %esi,%esi
8010351f:	79 33                	jns    80103554 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103521:	83 ec 04             	sub    $0x4,%esp
80103524:	01 c6                	add    %eax,%esi
80103526:	56                   	push   %esi
80103527:	50                   	push   %eax
80103528:	ff 73 04             	pushl  0x4(%ebx)
8010352b:	e8 99 2d 00 00       	call   801062c9 <deallocuvm>
80103530:	83 c4 10             	add    $0x10,%esp
80103533:	85 c0                	test   %eax,%eax
80103535:	75 1d                	jne    80103554 <growproc+0x4c>
      return -1;
80103537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010353c:	eb 29                	jmp    80103567 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010353e:	83 ec 04             	sub    $0x4,%esp
80103541:	01 c6                	add    %eax,%esi
80103543:	56                   	push   %esi
80103544:	50                   	push   %eax
80103545:	ff 73 04             	pushl  0x4(%ebx)
80103548:	e8 0e 2e 00 00       	call   8010635b <allocuvm>
8010354d:	83 c4 10             	add    $0x10,%esp
80103550:	85 c0                	test   %eax,%eax
80103552:	74 1a                	je     8010356e <growproc+0x66>
  curproc->sz = sz;
80103554:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103556:	83 ec 0c             	sub    $0xc,%esp
80103559:	53                   	push   %ebx
8010355a:	e8 49 2b 00 00       	call   801060a8 <switchuvm>
  return 0;
8010355f:	83 c4 10             	add    $0x10,%esp
80103562:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103567:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010356a:	5b                   	pop    %ebx
8010356b:	5e                   	pop    %esi
8010356c:	5d                   	pop    %ebp
8010356d:	c3                   	ret    
      return -1;
8010356e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103573:	eb f2                	jmp    80103567 <growproc+0x5f>

80103575 <fork>:
{
80103575:	55                   	push   %ebp
80103576:	89 e5                	mov    %esp,%ebp
80103578:	57                   	push   %edi
80103579:	56                   	push   %esi
8010357a:	53                   	push   %ebx
8010357b:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010357e:	e8 75 fe ff ff       	call   801033f8 <myproc>
80103583:	89 c3                	mov    %eax,%ebx
  if((np = allocproc(0)) == 0){
80103585:	b8 00 00 00 00       	mov    $0x0,%eax
8010358a:	e8 a4 fc ff ff       	call   80103233 <allocproc>
8010358f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103592:	85 c0                	test   %eax,%eax
80103594:	0f 84 e0 00 00 00    	je     8010367a <fork+0x105>
8010359a:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010359c:	83 ec 08             	sub    $0x8,%esp
8010359f:	ff 33                	pushl  (%ebx)
801035a1:	ff 73 04             	pushl  0x4(%ebx)
801035a4:	e8 bd 2f 00 00       	call   80106566 <copyuvm>
801035a9:	89 47 04             	mov    %eax,0x4(%edi)
801035ac:	83 c4 10             	add    $0x10,%esp
801035af:	85 c0                	test   %eax,%eax
801035b1:	74 2a                	je     801035dd <fork+0x68>
  np->sz = curproc->sz;
801035b3:	8b 03                	mov    (%ebx),%eax
801035b5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801035b8:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801035ba:	89 c8                	mov    %ecx,%eax
801035bc:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801035bf:	8b 73 18             	mov    0x18(%ebx),%esi
801035c2:	8b 79 18             	mov    0x18(%ecx),%edi
801035c5:	b9 13 00 00 00       	mov    $0x13,%ecx
801035ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801035cc:	8b 40 18             	mov    0x18(%eax),%eax
801035cf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801035d6:	be 00 00 00 00       	mov    $0x0,%esi
801035db:	eb 29                	jmp    80103606 <fork+0x91>
    kfree(np->kstack);
801035dd:	83 ec 0c             	sub    $0xc,%esp
801035e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801035e3:	ff 73 08             	pushl  0x8(%ebx)
801035e6:	e8 b9 e9 ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
801035eb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801035f2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801035f9:	83 c4 10             	add    $0x10,%esp
801035fc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103601:	eb 6d                	jmp    80103670 <fork+0xfb>
  for(i = 0; i < NOFILE; i++)
80103603:	83 c6 01             	add    $0x1,%esi
80103606:	83 fe 0f             	cmp    $0xf,%esi
80103609:	7f 1d                	jg     80103628 <fork+0xb3>
    if(curproc->ofile[i])
8010360b:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010360f:	85 c0                	test   %eax,%eax
80103611:	74 f0                	je     80103603 <fork+0x8e>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103613:	83 ec 0c             	sub    $0xc,%esp
80103616:	50                   	push   %eax
80103617:	e8 72 d6 ff ff       	call   80100c8e <filedup>
8010361c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010361f:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103623:	83 c4 10             	add    $0x10,%esp
80103626:	eb db                	jmp    80103603 <fork+0x8e>
  np->cwd = idup(curproc->cwd);
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	ff 73 68             	pushl  0x68(%ebx)
8010362e:	e8 1e df ff ff       	call   80101551 <idup>
80103633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103636:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103639:	83 c3 6c             	add    $0x6c,%ebx
8010363c:	8d 47 6c             	lea    0x6c(%edi),%eax
8010363f:	83 c4 0c             	add    $0xc,%esp
80103642:	6a 10                	push   $0x10
80103644:	53                   	push   %ebx
80103645:	50                   	push   %eax
80103646:	e8 d0 09 00 00       	call   8010401b <safestrcpy>
  pid = np->pid;
8010364b:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010364e:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103655:	e8 ae 07 00 00       	call   80103e08 <acquire>
  np->state = RUNNABLE;
8010365a:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103661:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103668:	e8 00 08 00 00       	call   80103e6d <release>
  return pid;
8010366d:	83 c4 10             	add    $0x10,%esp
}
80103670:	89 d8                	mov    %ebx,%eax
80103672:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103675:	5b                   	pop    %ebx
80103676:	5e                   	pop    %esi
80103677:	5f                   	pop    %edi
80103678:	5d                   	pop    %ebp
80103679:	c3                   	ret    
    return -1;
8010367a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010367f:	eb ef                	jmp    80103670 <fork+0xfb>

80103681 <scheduler>:
{
80103681:	55                   	push   %ebp
80103682:	89 e5                	mov    %esp,%ebp
80103684:	56                   	push   %esi
80103685:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103686:	e8 f6 fc ff ff       	call   80103381 <mycpu>
8010368b:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010368d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103694:	00 00 00 
80103697:	eb 5a                	jmp    801036f3 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103699:	83 c3 7c             	add    $0x7c,%ebx
8010369c:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
801036a2:	73 3f                	jae    801036e3 <scheduler+0x62>
      if(p->state != RUNNABLE)
801036a4:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801036a8:	75 ef                	jne    80103699 <scheduler+0x18>
      c->proc = p;
801036aa:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	53                   	push   %ebx
801036b4:	e8 ef 29 00 00       	call   801060a8 <switchuvm>
      p->state = RUNNING;
801036b9:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801036c0:	83 c4 08             	add    $0x8,%esp
801036c3:	ff 73 1c             	pushl  0x1c(%ebx)
801036c6:	8d 46 04             	lea    0x4(%esi),%eax
801036c9:	50                   	push   %eax
801036ca:	e8 9f 09 00 00       	call   8010406e <swtch>
      switchkvm();
801036cf:	e8 c2 29 00 00       	call   80106096 <switchkvm>
      c->proc = 0;
801036d4:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801036db:	00 00 00 
801036de:	83 c4 10             	add    $0x10,%esp
801036e1:	eb b6                	jmp    80103699 <scheduler+0x18>
    release(&ptable.lock);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 40 eb 1b 80       	push   $0x801beb40
801036eb:	e8 7d 07 00 00       	call   80103e6d <release>
    sti();
801036f0:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801036f3:	fb                   	sti    
    acquire(&ptable.lock);
801036f4:	83 ec 0c             	sub    $0xc,%esp
801036f7:	68 40 eb 1b 80       	push   $0x801beb40
801036fc:	e8 07 07 00 00       	call   80103e08 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103701:	83 c4 10             	add    $0x10,%esp
80103704:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103709:	eb 91                	jmp    8010369c <scheduler+0x1b>

8010370b <sched>:
{
8010370b:	55                   	push   %ebp
8010370c:	89 e5                	mov    %esp,%ebp
8010370e:	56                   	push   %esi
8010370f:	53                   	push   %ebx
  struct proc *p = myproc();
80103710:	e8 e3 fc ff ff       	call   801033f8 <myproc>
80103715:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	68 40 eb 1b 80       	push   $0x801beb40
8010371f:	e8 a4 06 00 00       	call   80103dc8 <holding>
80103724:	83 c4 10             	add    $0x10,%esp
80103727:	85 c0                	test   %eax,%eax
80103729:	74 4f                	je     8010377a <sched+0x6f>
  if(mycpu()->ncli != 1)
8010372b:	e8 51 fc ff ff       	call   80103381 <mycpu>
80103730:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103737:	75 4e                	jne    80103787 <sched+0x7c>
  if(p->state == RUNNING)
80103739:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010373d:	74 55                	je     80103794 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010373f:	9c                   	pushf  
80103740:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103741:	f6 c4 02             	test   $0x2,%ah
80103744:	75 5b                	jne    801037a1 <sched+0x96>
  intena = mycpu()->intena;
80103746:	e8 36 fc ff ff       	call   80103381 <mycpu>
8010374b:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103751:	e8 2b fc ff ff       	call   80103381 <mycpu>
80103756:	83 ec 08             	sub    $0x8,%esp
80103759:	ff 70 04             	pushl  0x4(%eax)
8010375c:	83 c3 1c             	add    $0x1c,%ebx
8010375f:	53                   	push   %ebx
80103760:	e8 09 09 00 00       	call   8010406e <swtch>
  mycpu()->intena = intena;
80103765:	e8 17 fc ff ff       	call   80103381 <mycpu>
8010376a:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103770:	83 c4 10             	add    $0x10,%esp
80103773:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103776:	5b                   	pop    %ebx
80103777:	5e                   	pop    %esi
80103778:	5d                   	pop    %ebp
80103779:	c3                   	ret    
    panic("sched ptable.lock");
8010377a:	83 ec 0c             	sub    $0xc,%esp
8010377d:	68 b0 6c 10 80       	push   $0x80106cb0
80103782:	e8 c1 cb ff ff       	call   80100348 <panic>
    panic("sched locks");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 c2 6c 10 80       	push   $0x80106cc2
8010378f:	e8 b4 cb ff ff       	call   80100348 <panic>
    panic("sched running");
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	68 ce 6c 10 80       	push   $0x80106cce
8010379c:	e8 a7 cb ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801037a1:	83 ec 0c             	sub    $0xc,%esp
801037a4:	68 dc 6c 10 80       	push   $0x80106cdc
801037a9:	e8 9a cb ff ff       	call   80100348 <panic>

801037ae <exit>:
{
801037ae:	55                   	push   %ebp
801037af:	89 e5                	mov    %esp,%ebp
801037b1:	56                   	push   %esi
801037b2:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037b3:	e8 40 fc ff ff       	call   801033f8 <myproc>
  if(curproc == initproc)
801037b8:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
801037be:	74 09                	je     801037c9 <exit+0x1b>
801037c0:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801037c2:	bb 00 00 00 00       	mov    $0x0,%ebx
801037c7:	eb 10                	jmp    801037d9 <exit+0x2b>
    panic("init exiting");
801037c9:	83 ec 0c             	sub    $0xc,%esp
801037cc:	68 f0 6c 10 80       	push   $0x80106cf0
801037d1:	e8 72 cb ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801037d6:	83 c3 01             	add    $0x1,%ebx
801037d9:	83 fb 0f             	cmp    $0xf,%ebx
801037dc:	7f 1e                	jg     801037fc <exit+0x4e>
    if(curproc->ofile[fd]){
801037de:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801037e2:	85 c0                	test   %eax,%eax
801037e4:	74 f0                	je     801037d6 <exit+0x28>
      fileclose(curproc->ofile[fd]);
801037e6:	83 ec 0c             	sub    $0xc,%esp
801037e9:	50                   	push   %eax
801037ea:	e8 e4 d4 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
801037ef:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801037f6:	00 
801037f7:	83 c4 10             	add    $0x10,%esp
801037fa:	eb da                	jmp    801037d6 <exit+0x28>
  begin_op();
801037fc:	e8 7f f1 ff ff       	call   80102980 <begin_op>
  iput(curproc->cwd);
80103801:	83 ec 0c             	sub    $0xc,%esp
80103804:	ff 76 68             	pushl  0x68(%esi)
80103807:	e8 7c de ff ff       	call   80101688 <iput>
  end_op();
8010380c:	e8 e9 f1 ff ff       	call   801029fa <end_op>
  curproc->cwd = 0;
80103811:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103818:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
8010381f:	e8 e4 05 00 00       	call   80103e08 <acquire>
  wakeup1(curproc->parent);
80103824:	8b 46 14             	mov    0x14(%esi),%eax
80103827:	e8 dc f9 ff ff       	call   80103208 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010382c:	83 c4 10             	add    $0x10,%esp
8010382f:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103834:	eb 03                	jmp    80103839 <exit+0x8b>
80103836:	83 c3 7c             	add    $0x7c,%ebx
80103839:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
8010383f:	73 1a                	jae    8010385b <exit+0xad>
    if(p->parent == curproc){
80103841:	39 73 14             	cmp    %esi,0x14(%ebx)
80103844:	75 f0                	jne    80103836 <exit+0x88>
      p->parent = initproc;
80103846:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
8010384b:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010384e:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103852:	75 e2                	jne    80103836 <exit+0x88>
        wakeup1(initproc);
80103854:	e8 af f9 ff ff       	call   80103208 <wakeup1>
80103859:	eb db                	jmp    80103836 <exit+0x88>
  curproc->state = ZOMBIE;
8010385b:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103862:	e8 a4 fe ff ff       	call   8010370b <sched>
  panic("zombie exit");
80103867:	83 ec 0c             	sub    $0xc,%esp
8010386a:	68 fd 6c 10 80       	push   $0x80106cfd
8010386f:	e8 d4 ca ff ff       	call   80100348 <panic>

80103874 <yield>:
{
80103874:	55                   	push   %ebp
80103875:	89 e5                	mov    %esp,%ebp
80103877:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010387a:	68 40 eb 1b 80       	push   $0x801beb40
8010387f:	e8 84 05 00 00       	call   80103e08 <acquire>
  myproc()->state = RUNNABLE;
80103884:	e8 6f fb ff ff       	call   801033f8 <myproc>
80103889:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103890:	e8 76 fe ff ff       	call   8010370b <sched>
  release(&ptable.lock);
80103895:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
8010389c:	e8 cc 05 00 00       	call   80103e6d <release>
}
801038a1:	83 c4 10             	add    $0x10,%esp
801038a4:	c9                   	leave  
801038a5:	c3                   	ret    

801038a6 <sleep>:
{
801038a6:	55                   	push   %ebp
801038a7:	89 e5                	mov    %esp,%ebp
801038a9:	56                   	push   %esi
801038aa:	53                   	push   %ebx
801038ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801038ae:	e8 45 fb ff ff       	call   801033f8 <myproc>
  if(p == 0)
801038b3:	85 c0                	test   %eax,%eax
801038b5:	74 66                	je     8010391d <sleep+0x77>
801038b7:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801038b9:	85 db                	test   %ebx,%ebx
801038bb:	74 6d                	je     8010392a <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801038bd:	81 fb 40 eb 1b 80    	cmp    $0x801beb40,%ebx
801038c3:	74 18                	je     801038dd <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801038c5:	83 ec 0c             	sub    $0xc,%esp
801038c8:	68 40 eb 1b 80       	push   $0x801beb40
801038cd:	e8 36 05 00 00       	call   80103e08 <acquire>
    release(lk);
801038d2:	89 1c 24             	mov    %ebx,(%esp)
801038d5:	e8 93 05 00 00       	call   80103e6d <release>
801038da:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801038dd:	8b 45 08             	mov    0x8(%ebp),%eax
801038e0:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801038e3:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801038ea:	e8 1c fe ff ff       	call   8010370b <sched>
  p->chan = 0;
801038ef:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801038f6:	81 fb 40 eb 1b 80    	cmp    $0x801beb40,%ebx
801038fc:	74 18                	je     80103916 <sleep+0x70>
    release(&ptable.lock);
801038fe:	83 ec 0c             	sub    $0xc,%esp
80103901:	68 40 eb 1b 80       	push   $0x801beb40
80103906:	e8 62 05 00 00       	call   80103e6d <release>
    acquire(lk);
8010390b:	89 1c 24             	mov    %ebx,(%esp)
8010390e:	e8 f5 04 00 00       	call   80103e08 <acquire>
80103913:	83 c4 10             	add    $0x10,%esp
}
80103916:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103919:	5b                   	pop    %ebx
8010391a:	5e                   	pop    %esi
8010391b:	5d                   	pop    %ebp
8010391c:	c3                   	ret    
    panic("sleep");
8010391d:	83 ec 0c             	sub    $0xc,%esp
80103920:	68 09 6d 10 80       	push   $0x80106d09
80103925:	e8 1e ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010392a:	83 ec 0c             	sub    $0xc,%esp
8010392d:	68 0f 6d 10 80       	push   $0x80106d0f
80103932:	e8 11 ca ff ff       	call   80100348 <panic>

80103937 <wait>:
{
80103937:	55                   	push   %ebp
80103938:	89 e5                	mov    %esp,%ebp
8010393a:	56                   	push   %esi
8010393b:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010393c:	e8 b7 fa ff ff       	call   801033f8 <myproc>
80103941:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103943:	83 ec 0c             	sub    $0xc,%esp
80103946:	68 40 eb 1b 80       	push   $0x801beb40
8010394b:	e8 b8 04 00 00       	call   80103e08 <acquire>
80103950:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103953:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103958:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
8010395d:	eb 5b                	jmp    801039ba <wait+0x83>
        pid = p->pid;
8010395f:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103962:	83 ec 0c             	sub    $0xc,%esp
80103965:	ff 73 08             	pushl  0x8(%ebx)
80103968:	e8 37 e6 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
8010396d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103974:	83 c4 04             	add    $0x4,%esp
80103977:	ff 73 04             	pushl  0x4(%ebx)
8010397a:	e8 c6 2a 00 00       	call   80106445 <freevm>
        p->pid = 0;
8010397f:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103986:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010398d:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103991:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103998:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010399f:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
801039a6:	e8 c2 04 00 00       	call   80103e6d <release>
        return pid;
801039ab:	83 c4 10             	add    $0x10,%esp
}
801039ae:	89 f0                	mov    %esi,%eax
801039b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039b3:	5b                   	pop    %ebx
801039b4:	5e                   	pop    %esi
801039b5:	5d                   	pop    %ebp
801039b6:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039b7:	83 c3 7c             	add    $0x7c,%ebx
801039ba:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
801039c0:	73 12                	jae    801039d4 <wait+0x9d>
      if(p->parent != curproc)
801039c2:	39 73 14             	cmp    %esi,0x14(%ebx)
801039c5:	75 f0                	jne    801039b7 <wait+0x80>
      if(p->state == ZOMBIE){
801039c7:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801039cb:	74 92                	je     8010395f <wait+0x28>
      havekids = 1;
801039cd:	b8 01 00 00 00       	mov    $0x1,%eax
801039d2:	eb e3                	jmp    801039b7 <wait+0x80>
    if(!havekids || curproc->killed){
801039d4:	85 c0                	test   %eax,%eax
801039d6:	74 06                	je     801039de <wait+0xa7>
801039d8:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801039dc:	74 17                	je     801039f5 <wait+0xbe>
      release(&ptable.lock);
801039de:	83 ec 0c             	sub    $0xc,%esp
801039e1:	68 40 eb 1b 80       	push   $0x801beb40
801039e6:	e8 82 04 00 00       	call   80103e6d <release>
      return -1;
801039eb:	83 c4 10             	add    $0x10,%esp
801039ee:	be ff ff ff ff       	mov    $0xffffffff,%esi
801039f3:	eb b9                	jmp    801039ae <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801039f5:	83 ec 08             	sub    $0x8,%esp
801039f8:	68 40 eb 1b 80       	push   $0x801beb40
801039fd:	56                   	push   %esi
801039fe:	e8 a3 fe ff ff       	call   801038a6 <sleep>
    havekids = 0;
80103a03:	83 c4 10             	add    $0x10,%esp
80103a06:	e9 48 ff ff ff       	jmp    80103953 <wait+0x1c>

80103a0b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103a0b:	55                   	push   %ebp
80103a0c:	89 e5                	mov    %esp,%ebp
80103a0e:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103a11:	68 40 eb 1b 80       	push   $0x801beb40
80103a16:	e8 ed 03 00 00       	call   80103e08 <acquire>
  wakeup1(chan);
80103a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1e:	e8 e5 f7 ff ff       	call   80103208 <wakeup1>
  release(&ptable.lock);
80103a23:	c7 04 24 40 eb 1b 80 	movl   $0x801beb40,(%esp)
80103a2a:	e8 3e 04 00 00       	call   80103e6d <release>
}
80103a2f:	83 c4 10             	add    $0x10,%esp
80103a32:	c9                   	leave  
80103a33:	c3                   	ret    

80103a34 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103a34:	55                   	push   %ebp
80103a35:	89 e5                	mov    %esp,%ebp
80103a37:	53                   	push   %ebx
80103a38:	83 ec 10             	sub    $0x10,%esp
80103a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103a3e:	68 40 eb 1b 80       	push   $0x801beb40
80103a43:	e8 c0 03 00 00       	call   80103e08 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a48:	83 c4 10             	add    $0x10,%esp
80103a4b:	b8 74 eb 1b 80       	mov    $0x801beb74,%eax
80103a50:	3d 74 0a 1c 80       	cmp    $0x801c0a74,%eax
80103a55:	73 3a                	jae    80103a91 <kill+0x5d>
    if(p->pid == pid){
80103a57:	39 58 10             	cmp    %ebx,0x10(%eax)
80103a5a:	74 05                	je     80103a61 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a5c:	83 c0 7c             	add    $0x7c,%eax
80103a5f:	eb ef                	jmp    80103a50 <kill+0x1c>
      p->killed = 1;
80103a61:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103a68:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a6c:	74 1a                	je     80103a88 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103a6e:	83 ec 0c             	sub    $0xc,%esp
80103a71:	68 40 eb 1b 80       	push   $0x801beb40
80103a76:	e8 f2 03 00 00       	call   80103e6d <release>
      return 0;
80103a7b:	83 c4 10             	add    $0x10,%esp
80103a7e:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a86:	c9                   	leave  
80103a87:	c3                   	ret    
        p->state = RUNNABLE;
80103a88:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a8f:	eb dd                	jmp    80103a6e <kill+0x3a>
  release(&ptable.lock);
80103a91:	83 ec 0c             	sub    $0xc,%esp
80103a94:	68 40 eb 1b 80       	push   $0x801beb40
80103a99:	e8 cf 03 00 00       	call   80103e6d <release>
  return -1;
80103a9e:	83 c4 10             	add    $0x10,%esp
80103aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103aa6:	eb db                	jmp    80103a83 <kill+0x4f>

80103aa8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103aa8:	55                   	push   %ebp
80103aa9:	89 e5                	mov    %esp,%ebp
80103aab:	56                   	push   %esi
80103aac:	53                   	push   %ebx
80103aad:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ab0:	bb 74 eb 1b 80       	mov    $0x801beb74,%ebx
80103ab5:	eb 33                	jmp    80103aea <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103ab7:	b8 20 6d 10 80       	mov    $0x80106d20,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103abc:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103abf:	52                   	push   %edx
80103ac0:	50                   	push   %eax
80103ac1:	ff 73 10             	pushl  0x10(%ebx)
80103ac4:	68 24 6d 10 80       	push   $0x80106d24
80103ac9:	e8 3d cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103ace:	83 c4 10             	add    $0x10,%esp
80103ad1:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103ad5:	74 39                	je     80103b10 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103ad7:	83 ec 0c             	sub    $0xc,%esp
80103ada:	68 9b 70 10 80       	push   $0x8010709b
80103adf:	e8 27 cb ff ff       	call   8010060b <cprintf>
80103ae4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ae7:	83 c3 7c             	add    $0x7c,%ebx
80103aea:	81 fb 74 0a 1c 80    	cmp    $0x801c0a74,%ebx
80103af0:	73 61                	jae    80103b53 <procdump+0xab>
    if(p->state == UNUSED)
80103af2:	8b 43 0c             	mov    0xc(%ebx),%eax
80103af5:	85 c0                	test   %eax,%eax
80103af7:	74 ee                	je     80103ae7 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103af9:	83 f8 05             	cmp    $0x5,%eax
80103afc:	77 b9                	ja     80103ab7 <procdump+0xf>
80103afe:	8b 04 85 80 6d 10 80 	mov    -0x7fef9280(,%eax,4),%eax
80103b05:	85 c0                	test   %eax,%eax
80103b07:	75 b3                	jne    80103abc <procdump+0x14>
      state = "???";
80103b09:	b8 20 6d 10 80       	mov    $0x80106d20,%eax
80103b0e:	eb ac                	jmp    80103abc <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103b10:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103b13:	8b 40 0c             	mov    0xc(%eax),%eax
80103b16:	83 c0 08             	add    $0x8,%eax
80103b19:	83 ec 08             	sub    $0x8,%esp
80103b1c:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103b1f:	52                   	push   %edx
80103b20:	50                   	push   %eax
80103b21:	e8 c1 01 00 00       	call   80103ce7 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103b26:	83 c4 10             	add    $0x10,%esp
80103b29:	be 00 00 00 00       	mov    $0x0,%esi
80103b2e:	eb 14                	jmp    80103b44 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103b30:	83 ec 08             	sub    $0x8,%esp
80103b33:	50                   	push   %eax
80103b34:	68 61 67 10 80       	push   $0x80106761
80103b39:	e8 cd ca ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103b3e:	83 c6 01             	add    $0x1,%esi
80103b41:	83 c4 10             	add    $0x10,%esp
80103b44:	83 fe 09             	cmp    $0x9,%esi
80103b47:	7f 8e                	jg     80103ad7 <procdump+0x2f>
80103b49:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103b4d:	85 c0                	test   %eax,%eax
80103b4f:	75 df                	jne    80103b30 <procdump+0x88>
80103b51:	eb 84                	jmp    80103ad7 <procdump+0x2f>
  }
}
80103b53:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b56:	5b                   	pop    %ebx
80103b57:	5e                   	pop    %esi
80103b58:	5d                   	pop    %ebp
80103b59:	c3                   	ret    

80103b5a <dump_physmem>:

int 
dump_physmem(int *userFrames, int *userPids, int nframes)
{
80103b5a:	55                   	push   %ebp
80103b5b:	89 e5                	mov    %esp,%ebp
80103b5d:	56                   	push   %esi
80103b5e:	53                   	push   %ebx
80103b5f:	8b 75 08             	mov    0x8(%ebp),%esi
80103b62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103b65:	8b 55 10             	mov    0x10(%ebp),%edx
    if(nframes < 0 || userFrames == 0 || userPids == 0){
80103b68:	89 d0                	mov    %edx,%eax
80103b6a:	c1 e8 1f             	shr    $0x1f,%eax
80103b6d:	85 f6                	test   %esi,%esi
80103b6f:	0f 94 c1             	sete   %cl
80103b72:	08 c1                	or     %al,%cl
80103b74:	75 3d                	jne    80103bb3 <dump_physmem+0x59>
80103b76:	85 db                	test   %ebx,%ebx
80103b78:	74 40                	je     80103bba <dump_physmem+0x60>
     return -1;
    }
    //cprintf("Inside dump_physmem %d,\n",nframes);
    //int fr[numframes];
    for(int i=0; i < nframes; i++)
80103b7a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b7f:	eb 0d                	jmp    80103b8e <dump_physmem+0x34>
    {
      userFrames[i] = frames[i+65];
80103b81:	8b 0c 85 84 eb 1a 80 	mov    -0x7fe5147c(,%eax,4),%ecx
80103b88:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
    for(int i=0; i < nframes; i++)
80103b8b:	83 c0 01             	add    $0x1,%eax
80103b8e:	39 d0                	cmp    %edx,%eax
80103b90:	7c ef                	jl     80103b81 <dump_physmem+0x27>
      //cprintf("%d,%x,%x\n",i,userFrames[i],frames[i]);
    }
    //userFrames = fr;
    for(int i=0; i < nframes; i++)
80103b92:	b8 00 00 00 00       	mov    $0x0,%eax
80103b97:	eb 0d                	jmp    80103ba6 <dump_physmem+0x4c>
    {
      userPids[i] = pid[i+65];
80103b99:	8b 0c 85 84 27 11 80 	mov    -0x7feed87c(,%eax,4),%ecx
80103ba0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
    for(int i=0; i < nframes; i++)
80103ba3:	83 c0 01             	add    $0x1,%eax
80103ba6:	39 d0                	cmp    %edx,%eax
80103ba8:	7c ef                	jl     80103b99 <dump_physmem+0x3f>
      //cprintf("%d\n", pid[i]);
    }

    return 0;
80103baa:	b8 00 00 00 00       	mov    $0x0,%eax

}
80103baf:	5b                   	pop    %ebx
80103bb0:	5e                   	pop    %esi
80103bb1:	5d                   	pop    %ebp
80103bb2:	c3                   	ret    
     return -1;
80103bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103bb8:	eb f5                	jmp    80103baf <dump_physmem+0x55>
80103bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103bbf:	eb ee                	jmp    80103baf <dump_physmem+0x55>

80103bc1 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103bc1:	55                   	push   %ebp
80103bc2:	89 e5                	mov    %esp,%ebp
80103bc4:	53                   	push   %ebx
80103bc5:	83 ec 0c             	sub    $0xc,%esp
80103bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103bcb:	68 98 6d 10 80       	push   $0x80106d98
80103bd0:	8d 43 04             	lea    0x4(%ebx),%eax
80103bd3:	50                   	push   %eax
80103bd4:	e8 f3 00 00 00       	call   80103ccc <initlock>
  lk->name = name;
80103bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bdc:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103bdf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103be5:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103bec:	83 c4 10             	add    $0x10,%esp
80103bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bf2:	c9                   	leave  
80103bf3:	c3                   	ret    

80103bf4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103bf4:	55                   	push   %ebp
80103bf5:	89 e5                	mov    %esp,%ebp
80103bf7:	56                   	push   %esi
80103bf8:	53                   	push   %ebx
80103bf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103bfc:	8d 73 04             	lea    0x4(%ebx),%esi
80103bff:	83 ec 0c             	sub    $0xc,%esp
80103c02:	56                   	push   %esi
80103c03:	e8 00 02 00 00       	call   80103e08 <acquire>
  while (lk->locked) {
80103c08:	83 c4 10             	add    $0x10,%esp
80103c0b:	eb 0d                	jmp    80103c1a <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103c0d:	83 ec 08             	sub    $0x8,%esp
80103c10:	56                   	push   %esi
80103c11:	53                   	push   %ebx
80103c12:	e8 8f fc ff ff       	call   801038a6 <sleep>
80103c17:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103c1a:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c1d:	75 ee                	jne    80103c0d <acquiresleep+0x19>
  }
  lk->locked = 1;
80103c1f:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c25:	e8 ce f7 ff ff       	call   801033f8 <myproc>
80103c2a:	8b 40 10             	mov    0x10(%eax),%eax
80103c2d:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c30:	83 ec 0c             	sub    $0xc,%esp
80103c33:	56                   	push   %esi
80103c34:	e8 34 02 00 00       	call   80103e6d <release>
}
80103c39:	83 c4 10             	add    $0x10,%esp
80103c3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c3f:	5b                   	pop    %ebx
80103c40:	5e                   	pop    %esi
80103c41:	5d                   	pop    %ebp
80103c42:	c3                   	ret    

80103c43 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103c43:	55                   	push   %ebp
80103c44:	89 e5                	mov    %esp,%ebp
80103c46:	56                   	push   %esi
80103c47:	53                   	push   %ebx
80103c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c4b:	8d 73 04             	lea    0x4(%ebx),%esi
80103c4e:	83 ec 0c             	sub    $0xc,%esp
80103c51:	56                   	push   %esi
80103c52:	e8 b1 01 00 00       	call   80103e08 <acquire>
  lk->locked = 0;
80103c57:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c5d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103c64:	89 1c 24             	mov    %ebx,(%esp)
80103c67:	e8 9f fd ff ff       	call   80103a0b <wakeup>
  release(&lk->lk);
80103c6c:	89 34 24             	mov    %esi,(%esp)
80103c6f:	e8 f9 01 00 00       	call   80103e6d <release>
}
80103c74:	83 c4 10             	add    $0x10,%esp
80103c77:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c7a:	5b                   	pop    %ebx
80103c7b:	5e                   	pop    %esi
80103c7c:	5d                   	pop    %ebp
80103c7d:	c3                   	ret    

80103c7e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103c7e:	55                   	push   %ebp
80103c7f:	89 e5                	mov    %esp,%ebp
80103c81:	56                   	push   %esi
80103c82:	53                   	push   %ebx
80103c83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103c86:	8d 73 04             	lea    0x4(%ebx),%esi
80103c89:	83 ec 0c             	sub    $0xc,%esp
80103c8c:	56                   	push   %esi
80103c8d:	e8 76 01 00 00       	call   80103e08 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103c92:	83 c4 10             	add    $0x10,%esp
80103c95:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c98:	75 17                	jne    80103cb1 <holdingsleep+0x33>
80103c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103c9f:	83 ec 0c             	sub    $0xc,%esp
80103ca2:	56                   	push   %esi
80103ca3:	e8 c5 01 00 00       	call   80103e6d <release>
  return r;
}
80103ca8:	89 d8                	mov    %ebx,%eax
80103caa:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cad:	5b                   	pop    %ebx
80103cae:	5e                   	pop    %esi
80103caf:	5d                   	pop    %ebp
80103cb0:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103cb1:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103cb4:	e8 3f f7 ff ff       	call   801033f8 <myproc>
80103cb9:	3b 58 10             	cmp    0x10(%eax),%ebx
80103cbc:	74 07                	je     80103cc5 <holdingsleep+0x47>
80103cbe:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cc3:	eb da                	jmp    80103c9f <holdingsleep+0x21>
80103cc5:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cca:	eb d3                	jmp    80103c9f <holdingsleep+0x21>

80103ccc <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103ccc:	55                   	push   %ebp
80103ccd:	89 e5                	mov    %esp,%ebp
80103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103cd2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cd5:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103cd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103cde:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103ce5:	5d                   	pop    %ebp
80103ce6:	c3                   	ret    

80103ce7 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103ce7:	55                   	push   %ebp
80103ce8:	89 e5                	mov    %esp,%ebp
80103cea:	53                   	push   %ebx
80103ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103cee:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf1:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103cf4:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf9:	83 f8 09             	cmp    $0x9,%eax
80103cfc:	7f 25                	jg     80103d23 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103cfe:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d04:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d0a:	77 17                	ja     80103d23 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d0c:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d0f:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d12:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d14:	83 c0 01             	add    $0x1,%eax
80103d17:	eb e0                	jmp    80103cf9 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d19:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d20:	83 c0 01             	add    $0x1,%eax
80103d23:	83 f8 09             	cmp    $0x9,%eax
80103d26:	7e f1                	jle    80103d19 <getcallerpcs+0x32>
}
80103d28:	5b                   	pop    %ebx
80103d29:	5d                   	pop    %ebp
80103d2a:	c3                   	ret    

80103d2b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d2b:	55                   	push   %ebp
80103d2c:	89 e5                	mov    %esp,%ebp
80103d2e:	53                   	push   %ebx
80103d2f:	83 ec 04             	sub    $0x4,%esp
80103d32:	9c                   	pushf  
80103d33:	5b                   	pop    %ebx
  asm volatile("cli");
80103d34:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d35:	e8 47 f6 ff ff       	call   80103381 <mycpu>
80103d3a:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d41:	74 12                	je     80103d55 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103d43:	e8 39 f6 ff ff       	call   80103381 <mycpu>
80103d48:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103d4f:	83 c4 04             	add    $0x4,%esp
80103d52:	5b                   	pop    %ebx
80103d53:	5d                   	pop    %ebp
80103d54:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103d55:	e8 27 f6 ff ff       	call   80103381 <mycpu>
80103d5a:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d60:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103d66:	eb db                	jmp    80103d43 <pushcli+0x18>

80103d68 <popcli>:

void
popcli(void)
{
80103d68:	55                   	push   %ebp
80103d69:	89 e5                	mov    %esp,%ebp
80103d6b:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d6e:	9c                   	pushf  
80103d6f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d70:	f6 c4 02             	test   $0x2,%ah
80103d73:	75 28                	jne    80103d9d <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103d75:	e8 07 f6 ff ff       	call   80103381 <mycpu>
80103d7a:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103d80:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103d83:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103d89:	85 d2                	test   %edx,%edx
80103d8b:	78 1d                	js     80103daa <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d8d:	e8 ef f5 ff ff       	call   80103381 <mycpu>
80103d92:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d99:	74 1c                	je     80103db7 <popcli+0x4f>
    sti();
}
80103d9b:	c9                   	leave  
80103d9c:	c3                   	ret    
    panic("popcli - interruptible");
80103d9d:	83 ec 0c             	sub    $0xc,%esp
80103da0:	68 a3 6d 10 80       	push   $0x80106da3
80103da5:	e8 9e c5 ff ff       	call   80100348 <panic>
    panic("popcli");
80103daa:	83 ec 0c             	sub    $0xc,%esp
80103dad:	68 ba 6d 10 80       	push   $0x80106dba
80103db2:	e8 91 c5 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103db7:	e8 c5 f5 ff ff       	call   80103381 <mycpu>
80103dbc:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103dc3:	74 d6                	je     80103d9b <popcli+0x33>
  asm volatile("sti");
80103dc5:	fb                   	sti    
}
80103dc6:	eb d3                	jmp    80103d9b <popcli+0x33>

80103dc8 <holding>:
{
80103dc8:	55                   	push   %ebp
80103dc9:	89 e5                	mov    %esp,%ebp
80103dcb:	53                   	push   %ebx
80103dcc:	83 ec 04             	sub    $0x4,%esp
80103dcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103dd2:	e8 54 ff ff ff       	call   80103d2b <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103dd7:	83 3b 00             	cmpl   $0x0,(%ebx)
80103dda:	75 12                	jne    80103dee <holding+0x26>
80103ddc:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103de1:	e8 82 ff ff ff       	call   80103d68 <popcli>
}
80103de6:	89 d8                	mov    %ebx,%eax
80103de8:	83 c4 04             	add    $0x4,%esp
80103deb:	5b                   	pop    %ebx
80103dec:	5d                   	pop    %ebp
80103ded:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103dee:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103df1:	e8 8b f5 ff ff       	call   80103381 <mycpu>
80103df6:	39 c3                	cmp    %eax,%ebx
80103df8:	74 07                	je     80103e01 <holding+0x39>
80103dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
80103dff:	eb e0                	jmp    80103de1 <holding+0x19>
80103e01:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e06:	eb d9                	jmp    80103de1 <holding+0x19>

80103e08 <acquire>:
{
80103e08:	55                   	push   %ebp
80103e09:	89 e5                	mov    %esp,%ebp
80103e0b:	53                   	push   %ebx
80103e0c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e0f:	e8 17 ff ff ff       	call   80103d2b <pushcli>
  if(holding(lk))
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	ff 75 08             	pushl  0x8(%ebp)
80103e1a:	e8 a9 ff ff ff       	call   80103dc8 <holding>
80103e1f:	83 c4 10             	add    $0x10,%esp
80103e22:	85 c0                	test   %eax,%eax
80103e24:	75 3a                	jne    80103e60 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103e26:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103e29:	b8 01 00 00 00       	mov    $0x1,%eax
80103e2e:	f0 87 02             	lock xchg %eax,(%edx)
80103e31:	85 c0                	test   %eax,%eax
80103e33:	75 f1                	jne    80103e26 <acquire+0x1e>
  __sync_synchronize();
80103e35:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103e3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e3d:	e8 3f f5 ff ff       	call   80103381 <mycpu>
80103e42:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e45:	8b 45 08             	mov    0x8(%ebp),%eax
80103e48:	83 c0 0c             	add    $0xc,%eax
80103e4b:	83 ec 08             	sub    $0x8,%esp
80103e4e:	50                   	push   %eax
80103e4f:	8d 45 08             	lea    0x8(%ebp),%eax
80103e52:	50                   	push   %eax
80103e53:	e8 8f fe ff ff       	call   80103ce7 <getcallerpcs>
}
80103e58:	83 c4 10             	add    $0x10,%esp
80103e5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e5e:	c9                   	leave  
80103e5f:	c3                   	ret    
    panic("acquire");
80103e60:	83 ec 0c             	sub    $0xc,%esp
80103e63:	68 c1 6d 10 80       	push   $0x80106dc1
80103e68:	e8 db c4 ff ff       	call   80100348 <panic>

80103e6d <release>:
{
80103e6d:	55                   	push   %ebp
80103e6e:	89 e5                	mov    %esp,%ebp
80103e70:	53                   	push   %ebx
80103e71:	83 ec 10             	sub    $0x10,%esp
80103e74:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103e77:	53                   	push   %ebx
80103e78:	e8 4b ff ff ff       	call   80103dc8 <holding>
80103e7d:	83 c4 10             	add    $0x10,%esp
80103e80:	85 c0                	test   %eax,%eax
80103e82:	74 23                	je     80103ea7 <release+0x3a>
  lk->pcs[0] = 0;
80103e84:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103e8b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103e92:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103e97:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103e9d:	e8 c6 fe ff ff       	call   80103d68 <popcli>
}
80103ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ea5:	c9                   	leave  
80103ea6:	c3                   	ret    
    panic("release");
80103ea7:	83 ec 0c             	sub    $0xc,%esp
80103eaa:	68 c9 6d 10 80       	push   $0x80106dc9
80103eaf:	e8 94 c4 ff ff       	call   80100348 <panic>

80103eb4 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103eb4:	55                   	push   %ebp
80103eb5:	89 e5                	mov    %esp,%ebp
80103eb7:	57                   	push   %edi
80103eb8:	53                   	push   %ebx
80103eb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103ebf:	f6 c2 03             	test   $0x3,%dl
80103ec2:	75 05                	jne    80103ec9 <memset+0x15>
80103ec4:	f6 c1 03             	test   $0x3,%cl
80103ec7:	74 0e                	je     80103ed7 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103ec9:	89 d7                	mov    %edx,%edi
80103ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ece:	fc                   	cld    
80103ecf:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103ed1:	89 d0                	mov    %edx,%eax
80103ed3:	5b                   	pop    %ebx
80103ed4:	5f                   	pop    %edi
80103ed5:	5d                   	pop    %ebp
80103ed6:	c3                   	ret    
    c &= 0xFF;
80103ed7:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103edb:	c1 e9 02             	shr    $0x2,%ecx
80103ede:	89 f8                	mov    %edi,%eax
80103ee0:	c1 e0 18             	shl    $0x18,%eax
80103ee3:	89 fb                	mov    %edi,%ebx
80103ee5:	c1 e3 10             	shl    $0x10,%ebx
80103ee8:	09 d8                	or     %ebx,%eax
80103eea:	89 fb                	mov    %edi,%ebx
80103eec:	c1 e3 08             	shl    $0x8,%ebx
80103eef:	09 d8                	or     %ebx,%eax
80103ef1:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103ef3:	89 d7                	mov    %edx,%edi
80103ef5:	fc                   	cld    
80103ef6:	f3 ab                	rep stos %eax,%es:(%edi)
80103ef8:	eb d7                	jmp    80103ed1 <memset+0x1d>

80103efa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103efa:	55                   	push   %ebp
80103efb:	89 e5                	mov    %esp,%ebp
80103efd:	56                   	push   %esi
80103efe:	53                   	push   %ebx
80103eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f02:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f05:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f08:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f0b:	85 c0                	test   %eax,%eax
80103f0d:	74 1c                	je     80103f2b <memcmp+0x31>
    if(*s1 != *s2)
80103f0f:	0f b6 01             	movzbl (%ecx),%eax
80103f12:	0f b6 1a             	movzbl (%edx),%ebx
80103f15:	38 d8                	cmp    %bl,%al
80103f17:	75 0a                	jne    80103f23 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103f19:	83 c1 01             	add    $0x1,%ecx
80103f1c:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103f1f:	89 f0                	mov    %esi,%eax
80103f21:	eb e5                	jmp    80103f08 <memcmp+0xe>
      return *s1 - *s2;
80103f23:	0f b6 c0             	movzbl %al,%eax
80103f26:	0f b6 db             	movzbl %bl,%ebx
80103f29:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103f2b:	5b                   	pop    %ebx
80103f2c:	5e                   	pop    %esi
80103f2d:	5d                   	pop    %ebp
80103f2e:	c3                   	ret    

80103f2f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f2f:	55                   	push   %ebp
80103f30:	89 e5                	mov    %esp,%ebp
80103f32:	56                   	push   %esi
80103f33:	53                   	push   %ebx
80103f34:	8b 45 08             	mov    0x8(%ebp),%eax
80103f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f3a:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f3d:	39 c1                	cmp    %eax,%ecx
80103f3f:	73 3a                	jae    80103f7b <memmove+0x4c>
80103f41:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103f44:	39 c3                	cmp    %eax,%ebx
80103f46:	76 37                	jbe    80103f7f <memmove+0x50>
    s += n;
    d += n;
80103f48:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103f4b:	eb 0d                	jmp    80103f5a <memmove+0x2b>
      *--d = *--s;
80103f4d:	83 eb 01             	sub    $0x1,%ebx
80103f50:	83 e9 01             	sub    $0x1,%ecx
80103f53:	0f b6 13             	movzbl (%ebx),%edx
80103f56:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103f58:	89 f2                	mov    %esi,%edx
80103f5a:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f5d:	85 d2                	test   %edx,%edx
80103f5f:	75 ec                	jne    80103f4d <memmove+0x1e>
80103f61:	eb 14                	jmp    80103f77 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103f63:	0f b6 11             	movzbl (%ecx),%edx
80103f66:	88 13                	mov    %dl,(%ebx)
80103f68:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103f6b:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103f6e:	89 f2                	mov    %esi,%edx
80103f70:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f73:	85 d2                	test   %edx,%edx
80103f75:	75 ec                	jne    80103f63 <memmove+0x34>

  return dst;
}
80103f77:	5b                   	pop    %ebx
80103f78:	5e                   	pop    %esi
80103f79:	5d                   	pop    %ebp
80103f7a:	c3                   	ret    
80103f7b:	89 c3                	mov    %eax,%ebx
80103f7d:	eb f1                	jmp    80103f70 <memmove+0x41>
80103f7f:	89 c3                	mov    %eax,%ebx
80103f81:	eb ed                	jmp    80103f70 <memmove+0x41>

80103f83 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103f83:	55                   	push   %ebp
80103f84:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103f86:	ff 75 10             	pushl  0x10(%ebp)
80103f89:	ff 75 0c             	pushl  0xc(%ebp)
80103f8c:	ff 75 08             	pushl  0x8(%ebp)
80103f8f:	e8 9b ff ff ff       	call   80103f2f <memmove>
}
80103f94:	c9                   	leave  
80103f95:	c3                   	ret    

80103f96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103f96:	55                   	push   %ebp
80103f97:	89 e5                	mov    %esp,%ebp
80103f99:	53                   	push   %ebx
80103f9a:	8b 55 08             	mov    0x8(%ebp),%edx
80103f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103fa3:	eb 09                	jmp    80103fae <strncmp+0x18>
    n--, p++, q++;
80103fa5:	83 e8 01             	sub    $0x1,%eax
80103fa8:	83 c2 01             	add    $0x1,%edx
80103fab:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103fae:	85 c0                	test   %eax,%eax
80103fb0:	74 0b                	je     80103fbd <strncmp+0x27>
80103fb2:	0f b6 1a             	movzbl (%edx),%ebx
80103fb5:	84 db                	test   %bl,%bl
80103fb7:	74 04                	je     80103fbd <strncmp+0x27>
80103fb9:	3a 19                	cmp    (%ecx),%bl
80103fbb:	74 e8                	je     80103fa5 <strncmp+0xf>
  if(n == 0)
80103fbd:	85 c0                	test   %eax,%eax
80103fbf:	74 0b                	je     80103fcc <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103fc1:	0f b6 02             	movzbl (%edx),%eax
80103fc4:	0f b6 11             	movzbl (%ecx),%edx
80103fc7:	29 d0                	sub    %edx,%eax
}
80103fc9:	5b                   	pop    %ebx
80103fca:	5d                   	pop    %ebp
80103fcb:	c3                   	ret    
    return 0;
80103fcc:	b8 00 00 00 00       	mov    $0x0,%eax
80103fd1:	eb f6                	jmp    80103fc9 <strncmp+0x33>

80103fd3 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103fd3:	55                   	push   %ebp
80103fd4:	89 e5                	mov    %esp,%ebp
80103fd6:	57                   	push   %edi
80103fd7:	56                   	push   %esi
80103fd8:	53                   	push   %ebx
80103fd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103fdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe2:	eb 04                	jmp    80103fe8 <strncpy+0x15>
80103fe4:	89 fb                	mov    %edi,%ebx
80103fe6:	89 f0                	mov    %esi,%eax
80103fe8:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103feb:	85 c9                	test   %ecx,%ecx
80103fed:	7e 1d                	jle    8010400c <strncpy+0x39>
80103fef:	8d 7b 01             	lea    0x1(%ebx),%edi
80103ff2:	8d 70 01             	lea    0x1(%eax),%esi
80103ff5:	0f b6 1b             	movzbl (%ebx),%ebx
80103ff8:	88 18                	mov    %bl,(%eax)
80103ffa:	89 d1                	mov    %edx,%ecx
80103ffc:	84 db                	test   %bl,%bl
80103ffe:	75 e4                	jne    80103fe4 <strncpy+0x11>
80104000:	89 f0                	mov    %esi,%eax
80104002:	eb 08                	jmp    8010400c <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104004:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104007:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104009:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
8010400c:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010400f:	85 d2                	test   %edx,%edx
80104011:	7f f1                	jg     80104004 <strncpy+0x31>
  return os;
}
80104013:	8b 45 08             	mov    0x8(%ebp),%eax
80104016:	5b                   	pop    %ebx
80104017:	5e                   	pop    %esi
80104018:	5f                   	pop    %edi
80104019:	5d                   	pop    %ebp
8010401a:	c3                   	ret    

8010401b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010401b:	55                   	push   %ebp
8010401c:	89 e5                	mov    %esp,%ebp
8010401e:	57                   	push   %edi
8010401f:	56                   	push   %esi
80104020:	53                   	push   %ebx
80104021:	8b 45 08             	mov    0x8(%ebp),%eax
80104024:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104027:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
8010402a:	85 d2                	test   %edx,%edx
8010402c:	7e 23                	jle    80104051 <safestrcpy+0x36>
8010402e:	89 c1                	mov    %eax,%ecx
80104030:	eb 04                	jmp    80104036 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104032:	89 fb                	mov    %edi,%ebx
80104034:	89 f1                	mov    %esi,%ecx
80104036:	83 ea 01             	sub    $0x1,%edx
80104039:	85 d2                	test   %edx,%edx
8010403b:	7e 11                	jle    8010404e <safestrcpy+0x33>
8010403d:	8d 7b 01             	lea    0x1(%ebx),%edi
80104040:	8d 71 01             	lea    0x1(%ecx),%esi
80104043:	0f b6 1b             	movzbl (%ebx),%ebx
80104046:	88 19                	mov    %bl,(%ecx)
80104048:	84 db                	test   %bl,%bl
8010404a:	75 e6                	jne    80104032 <safestrcpy+0x17>
8010404c:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010404e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104051:	5b                   	pop    %ebx
80104052:	5e                   	pop    %esi
80104053:	5f                   	pop    %edi
80104054:	5d                   	pop    %ebp
80104055:	c3                   	ret    

80104056 <strlen>:

int
strlen(const char *s)
{
80104056:	55                   	push   %ebp
80104057:	89 e5                	mov    %esp,%ebp
80104059:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
8010405c:	b8 00 00 00 00       	mov    $0x0,%eax
80104061:	eb 03                	jmp    80104066 <strlen+0x10>
80104063:	83 c0 01             	add    $0x1,%eax
80104066:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
8010406a:	75 f7                	jne    80104063 <strlen+0xd>
    ;
  return n;
}
8010406c:	5d                   	pop    %ebp
8010406d:	c3                   	ret    

8010406e <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010406e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104072:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104076:	55                   	push   %ebp
  pushl %ebx
80104077:	53                   	push   %ebx
  pushl %esi
80104078:	56                   	push   %esi
  pushl %edi
80104079:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010407a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010407c:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010407e:	5f                   	pop    %edi
  popl %esi
8010407f:	5e                   	pop    %esi
  popl %ebx
80104080:	5b                   	pop    %ebx
  popl %ebp
80104081:	5d                   	pop    %ebp
  ret
80104082:	c3                   	ret    

80104083 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104083:	55                   	push   %ebp
80104084:	89 e5                	mov    %esp,%ebp
80104086:	53                   	push   %ebx
80104087:	83 ec 04             	sub    $0x4,%esp
8010408a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
8010408d:	e8 66 f3 ff ff       	call   801033f8 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104092:	8b 00                	mov    (%eax),%eax
80104094:	39 d8                	cmp    %ebx,%eax
80104096:	76 19                	jbe    801040b1 <fetchint+0x2e>
80104098:	8d 53 04             	lea    0x4(%ebx),%edx
8010409b:	39 d0                	cmp    %edx,%eax
8010409d:	72 19                	jb     801040b8 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
8010409f:	8b 13                	mov    (%ebx),%edx
801040a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a4:	89 10                	mov    %edx,(%eax)
  return 0;
801040a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040ab:	83 c4 04             	add    $0x4,%esp
801040ae:	5b                   	pop    %ebx
801040af:	5d                   	pop    %ebp
801040b0:	c3                   	ret    
    return -1;
801040b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040b6:	eb f3                	jmp    801040ab <fetchint+0x28>
801040b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040bd:	eb ec                	jmp    801040ab <fetchint+0x28>

801040bf <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801040bf:	55                   	push   %ebp
801040c0:	89 e5                	mov    %esp,%ebp
801040c2:	53                   	push   %ebx
801040c3:	83 ec 04             	sub    $0x4,%esp
801040c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801040c9:	e8 2a f3 ff ff       	call   801033f8 <myproc>

  if(addr >= curproc->sz)
801040ce:	39 18                	cmp    %ebx,(%eax)
801040d0:	76 26                	jbe    801040f8 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
801040d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801040d5:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801040d7:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801040d9:	89 d8                	mov    %ebx,%eax
801040db:	39 d0                	cmp    %edx,%eax
801040dd:	73 0e                	jae    801040ed <fetchstr+0x2e>
    if(*s == 0)
801040df:	80 38 00             	cmpb   $0x0,(%eax)
801040e2:	74 05                	je     801040e9 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
801040e4:	83 c0 01             	add    $0x1,%eax
801040e7:	eb f2                	jmp    801040db <fetchstr+0x1c>
      return s - *pp;
801040e9:	29 d8                	sub    %ebx,%eax
801040eb:	eb 05                	jmp    801040f2 <fetchstr+0x33>
  }
  return -1;
801040ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040f2:	83 c4 04             	add    $0x4,%esp
801040f5:	5b                   	pop    %ebx
801040f6:	5d                   	pop    %ebp
801040f7:	c3                   	ret    
    return -1;
801040f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040fd:	eb f3                	jmp    801040f2 <fetchstr+0x33>

801040ff <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801040ff:	55                   	push   %ebp
80104100:	89 e5                	mov    %esp,%ebp
80104102:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104105:	e8 ee f2 ff ff       	call   801033f8 <myproc>
8010410a:	8b 50 18             	mov    0x18(%eax),%edx
8010410d:	8b 45 08             	mov    0x8(%ebp),%eax
80104110:	c1 e0 02             	shl    $0x2,%eax
80104113:	03 42 44             	add    0x44(%edx),%eax
80104116:	83 ec 08             	sub    $0x8,%esp
80104119:	ff 75 0c             	pushl  0xc(%ebp)
8010411c:	83 c0 04             	add    $0x4,%eax
8010411f:	50                   	push   %eax
80104120:	e8 5e ff ff ff       	call   80104083 <fetchint>
}
80104125:	c9                   	leave  
80104126:	c3                   	ret    

80104127 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104127:	55                   	push   %ebp
80104128:	89 e5                	mov    %esp,%ebp
8010412a:	56                   	push   %esi
8010412b:	53                   	push   %ebx
8010412c:	83 ec 10             	sub    $0x10,%esp
8010412f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104132:	e8 c1 f2 ff ff       	call   801033f8 <myproc>
80104137:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104139:	83 ec 08             	sub    $0x8,%esp
8010413c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010413f:	50                   	push   %eax
80104140:	ff 75 08             	pushl  0x8(%ebp)
80104143:	e8 b7 ff ff ff       	call   801040ff <argint>
80104148:	83 c4 10             	add    $0x10,%esp
8010414b:	85 c0                	test   %eax,%eax
8010414d:	78 24                	js     80104173 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010414f:	85 db                	test   %ebx,%ebx
80104151:	78 27                	js     8010417a <argptr+0x53>
80104153:	8b 16                	mov    (%esi),%edx
80104155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104158:	39 c2                	cmp    %eax,%edx
8010415a:	76 25                	jbe    80104181 <argptr+0x5a>
8010415c:	01 c3                	add    %eax,%ebx
8010415e:	39 da                	cmp    %ebx,%edx
80104160:	72 26                	jb     80104188 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80104162:	8b 55 0c             	mov    0xc(%ebp),%edx
80104165:	89 02                	mov    %eax,(%edx)
  return 0;
80104167:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010416c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010416f:	5b                   	pop    %ebx
80104170:	5e                   	pop    %esi
80104171:	5d                   	pop    %ebp
80104172:	c3                   	ret    
    return -1;
80104173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104178:	eb f2                	jmp    8010416c <argptr+0x45>
    return -1;
8010417a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010417f:	eb eb                	jmp    8010416c <argptr+0x45>
80104181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104186:	eb e4                	jmp    8010416c <argptr+0x45>
80104188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010418d:	eb dd                	jmp    8010416c <argptr+0x45>

8010418f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010418f:	55                   	push   %ebp
80104190:	89 e5                	mov    %esp,%ebp
80104192:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104195:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104198:	50                   	push   %eax
80104199:	ff 75 08             	pushl  0x8(%ebp)
8010419c:	e8 5e ff ff ff       	call   801040ff <argint>
801041a1:	83 c4 10             	add    $0x10,%esp
801041a4:	85 c0                	test   %eax,%eax
801041a6:	78 13                	js     801041bb <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801041a8:	83 ec 08             	sub    $0x8,%esp
801041ab:	ff 75 0c             	pushl  0xc(%ebp)
801041ae:	ff 75 f4             	pushl  -0xc(%ebp)
801041b1:	e8 09 ff ff ff       	call   801040bf <fetchstr>
801041b6:	83 c4 10             	add    $0x10,%esp
}
801041b9:	c9                   	leave  
801041ba:	c3                   	ret    
    return -1;
801041bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c0:	eb f7                	jmp    801041b9 <argstr+0x2a>

801041c2 <syscall>:
[SYS_dump_physmem]    sys_dump_physmem,
};

void
syscall(void)
{
801041c2:	55                   	push   %ebp
801041c3:	89 e5                	mov    %esp,%ebp
801041c5:	53                   	push   %ebx
801041c6:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801041c9:	e8 2a f2 ff ff       	call   801033f8 <myproc>
801041ce:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801041d0:	8b 40 18             	mov    0x18(%eax),%eax
801041d3:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801041d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801041d9:	83 fa 15             	cmp    $0x15,%edx
801041dc:	77 18                	ja     801041f6 <syscall+0x34>
801041de:	8b 14 85 00 6e 10 80 	mov    -0x7fef9200(,%eax,4),%edx
801041e5:	85 d2                	test   %edx,%edx
801041e7:	74 0d                	je     801041f6 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
801041e9:	ff d2                	call   *%edx
801041eb:	8b 53 18             	mov    0x18(%ebx),%edx
801041ee:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
801041f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041f4:	c9                   	leave  
801041f5:	c3                   	ret    
            curproc->pid, curproc->name, num);
801041f6:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
801041f9:	50                   	push   %eax
801041fa:	52                   	push   %edx
801041fb:	ff 73 10             	pushl  0x10(%ebx)
801041fe:	68 d1 6d 10 80       	push   $0x80106dd1
80104203:	e8 03 c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104208:	8b 43 18             	mov    0x18(%ebx),%eax
8010420b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104212:	83 c4 10             	add    $0x10,%esp
}
80104215:	eb da                	jmp    801041f1 <syscall+0x2f>

80104217 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104217:	55                   	push   %ebp
80104218:	89 e5                	mov    %esp,%ebp
8010421a:	56                   	push   %esi
8010421b:	53                   	push   %ebx
8010421c:	83 ec 18             	sub    $0x18,%esp
8010421f:	89 d6                	mov    %edx,%esi
80104221:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104223:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104226:	52                   	push   %edx
80104227:	50                   	push   %eax
80104228:	e8 d2 fe ff ff       	call   801040ff <argint>
8010422d:	83 c4 10             	add    $0x10,%esp
80104230:	85 c0                	test   %eax,%eax
80104232:	78 2e                	js     80104262 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104234:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104238:	77 2f                	ja     80104269 <argfd+0x52>
8010423a:	e8 b9 f1 ff ff       	call   801033f8 <myproc>
8010423f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104242:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104246:	85 c0                	test   %eax,%eax
80104248:	74 26                	je     80104270 <argfd+0x59>
    return -1;
  if(pfd)
8010424a:	85 f6                	test   %esi,%esi
8010424c:	74 02                	je     80104250 <argfd+0x39>
    *pfd = fd;
8010424e:	89 16                	mov    %edx,(%esi)
  if(pf)
80104250:	85 db                	test   %ebx,%ebx
80104252:	74 23                	je     80104277 <argfd+0x60>
    *pf = f;
80104254:	89 03                	mov    %eax,(%ebx)
  return 0;
80104256:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010425b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010425e:	5b                   	pop    %ebx
8010425f:	5e                   	pop    %esi
80104260:	5d                   	pop    %ebp
80104261:	c3                   	ret    
    return -1;
80104262:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104267:	eb f2                	jmp    8010425b <argfd+0x44>
    return -1;
80104269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426e:	eb eb                	jmp    8010425b <argfd+0x44>
80104270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104275:	eb e4                	jmp    8010425b <argfd+0x44>
  return 0;
80104277:	b8 00 00 00 00       	mov    $0x0,%eax
8010427c:	eb dd                	jmp    8010425b <argfd+0x44>

8010427e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010427e:	55                   	push   %ebp
8010427f:	89 e5                	mov    %esp,%ebp
80104281:	53                   	push   %ebx
80104282:	83 ec 04             	sub    $0x4,%esp
80104285:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104287:	e8 6c f1 ff ff       	call   801033f8 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
8010428c:	ba 00 00 00 00       	mov    $0x0,%edx
80104291:	83 fa 0f             	cmp    $0xf,%edx
80104294:	7f 18                	jg     801042ae <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
80104296:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
8010429b:	74 05                	je     801042a2 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
8010429d:	83 c2 01             	add    $0x1,%edx
801042a0:	eb ef                	jmp    80104291 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801042a2:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801042a6:	89 d0                	mov    %edx,%eax
801042a8:	83 c4 04             	add    $0x4,%esp
801042ab:	5b                   	pop    %ebx
801042ac:	5d                   	pop    %ebp
801042ad:	c3                   	ret    
  return -1;
801042ae:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801042b3:	eb f1                	jmp    801042a6 <fdalloc+0x28>

801042b5 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801042b5:	55                   	push   %ebp
801042b6:	89 e5                	mov    %esp,%ebp
801042b8:	56                   	push   %esi
801042b9:	53                   	push   %ebx
801042ba:	83 ec 10             	sub    $0x10,%esp
801042bd:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042bf:	b8 20 00 00 00       	mov    $0x20,%eax
801042c4:	89 c6                	mov    %eax,%esi
801042c6:	39 43 58             	cmp    %eax,0x58(%ebx)
801042c9:	76 2e                	jbe    801042f9 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801042cb:	6a 10                	push   $0x10
801042cd:	50                   	push   %eax
801042ce:	8d 45 e8             	lea    -0x18(%ebp),%eax
801042d1:	50                   	push   %eax
801042d2:	53                   	push   %ebx
801042d3:	e8 9b d4 ff ff       	call   80101773 <readi>
801042d8:	83 c4 10             	add    $0x10,%esp
801042db:	83 f8 10             	cmp    $0x10,%eax
801042de:	75 0c                	jne    801042ec <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801042e0:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801042e5:	75 1e                	jne    80104305 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042e7:	8d 46 10             	lea    0x10(%esi),%eax
801042ea:	eb d8                	jmp    801042c4 <isdirempty+0xf>
      panic("isdirempty: readi");
801042ec:	83 ec 0c             	sub    $0xc,%esp
801042ef:	68 5c 6e 10 80       	push   $0x80106e5c
801042f4:	e8 4f c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801042f9:	b8 01 00 00 00       	mov    $0x1,%eax
}
801042fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104301:	5b                   	pop    %ebx
80104302:	5e                   	pop    %esi
80104303:	5d                   	pop    %ebp
80104304:	c3                   	ret    
      return 0;
80104305:	b8 00 00 00 00       	mov    $0x0,%eax
8010430a:	eb f2                	jmp    801042fe <isdirempty+0x49>

8010430c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
8010430c:	55                   	push   %ebp
8010430d:	89 e5                	mov    %esp,%ebp
8010430f:	57                   	push   %edi
80104310:	56                   	push   %esi
80104311:	53                   	push   %ebx
80104312:	83 ec 44             	sub    $0x44,%esp
80104315:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104318:	89 4d c0             	mov    %ecx,-0x40(%ebp)
8010431b:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010431e:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104321:	52                   	push   %edx
80104322:	50                   	push   %eax
80104323:	e8 d1 d8 ff ff       	call   80101bf9 <nameiparent>
80104328:	89 c6                	mov    %eax,%esi
8010432a:	83 c4 10             	add    $0x10,%esp
8010432d:	85 c0                	test   %eax,%eax
8010432f:	0f 84 3a 01 00 00    	je     8010446f <create+0x163>
    return 0;
  ilock(dp);
80104335:	83 ec 0c             	sub    $0xc,%esp
80104338:	50                   	push   %eax
80104339:	e8 43 d2 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010433e:	83 c4 0c             	add    $0xc,%esp
80104341:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104344:	50                   	push   %eax
80104345:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104348:	50                   	push   %eax
80104349:	56                   	push   %esi
8010434a:	e8 61 d6 ff ff       	call   801019b0 <dirlookup>
8010434f:	89 c3                	mov    %eax,%ebx
80104351:	83 c4 10             	add    $0x10,%esp
80104354:	85 c0                	test   %eax,%eax
80104356:	74 3f                	je     80104397 <create+0x8b>
    iunlockput(dp);
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	56                   	push   %esi
8010435c:	e8 c7 d3 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
80104361:	89 1c 24             	mov    %ebx,(%esp)
80104364:	e8 18 d2 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104369:	83 c4 10             	add    $0x10,%esp
8010436c:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104371:	75 11                	jne    80104384 <create+0x78>
80104373:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104378:	75 0a                	jne    80104384 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010437a:	89 d8                	mov    %ebx,%eax
8010437c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010437f:	5b                   	pop    %ebx
80104380:	5e                   	pop    %esi
80104381:	5f                   	pop    %edi
80104382:	5d                   	pop    %ebp
80104383:	c3                   	ret    
    iunlockput(ip);
80104384:	83 ec 0c             	sub    $0xc,%esp
80104387:	53                   	push   %ebx
80104388:	e8 9b d3 ff ff       	call   80101728 <iunlockput>
    return 0;
8010438d:	83 c4 10             	add    $0x10,%esp
80104390:	bb 00 00 00 00       	mov    $0x0,%ebx
80104395:	eb e3                	jmp    8010437a <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
80104397:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
8010439b:	83 ec 08             	sub    $0x8,%esp
8010439e:	50                   	push   %eax
8010439f:	ff 36                	pushl  (%esi)
801043a1:	e8 d8 cf ff ff       	call   8010137e <ialloc>
801043a6:	89 c3                	mov    %eax,%ebx
801043a8:	83 c4 10             	add    $0x10,%esp
801043ab:	85 c0                	test   %eax,%eax
801043ad:	74 55                	je     80104404 <create+0xf8>
  ilock(ip);
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	50                   	push   %eax
801043b3:	e8 c9 d1 ff ff       	call   80101581 <ilock>
  ip->major = major;
801043b8:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801043bc:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801043c0:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801043c4:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801043ca:	89 1c 24             	mov    %ebx,(%esp)
801043cd:	e8 4e d0 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801043d2:	83 c4 10             	add    $0x10,%esp
801043d5:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801043da:	74 35                	je     80104411 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
801043dc:	83 ec 04             	sub    $0x4,%esp
801043df:	ff 73 04             	pushl  0x4(%ebx)
801043e2:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801043e5:	50                   	push   %eax
801043e6:	56                   	push   %esi
801043e7:	e8 44 d7 ff ff       	call   80101b30 <dirlink>
801043ec:	83 c4 10             	add    $0x10,%esp
801043ef:	85 c0                	test   %eax,%eax
801043f1:	78 6f                	js     80104462 <create+0x156>
  iunlockput(dp);
801043f3:	83 ec 0c             	sub    $0xc,%esp
801043f6:	56                   	push   %esi
801043f7:	e8 2c d3 ff ff       	call   80101728 <iunlockput>
  return ip;
801043fc:	83 c4 10             	add    $0x10,%esp
801043ff:	e9 76 ff ff ff       	jmp    8010437a <create+0x6e>
    panic("create: ialloc");
80104404:	83 ec 0c             	sub    $0xc,%esp
80104407:	68 6e 6e 10 80       	push   $0x80106e6e
8010440c:	e8 37 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104411:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104415:	83 c0 01             	add    $0x1,%eax
80104418:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010441c:	83 ec 0c             	sub    $0xc,%esp
8010441f:	56                   	push   %esi
80104420:	e8 fb cf ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104425:	83 c4 0c             	add    $0xc,%esp
80104428:	ff 73 04             	pushl  0x4(%ebx)
8010442b:	68 7e 6e 10 80       	push   $0x80106e7e
80104430:	53                   	push   %ebx
80104431:	e8 fa d6 ff ff       	call   80101b30 <dirlink>
80104436:	83 c4 10             	add    $0x10,%esp
80104439:	85 c0                	test   %eax,%eax
8010443b:	78 18                	js     80104455 <create+0x149>
8010443d:	83 ec 04             	sub    $0x4,%esp
80104440:	ff 76 04             	pushl  0x4(%esi)
80104443:	68 7d 6e 10 80       	push   $0x80106e7d
80104448:	53                   	push   %ebx
80104449:	e8 e2 d6 ff ff       	call   80101b30 <dirlink>
8010444e:	83 c4 10             	add    $0x10,%esp
80104451:	85 c0                	test   %eax,%eax
80104453:	79 87                	jns    801043dc <create+0xd0>
      panic("create dots");
80104455:	83 ec 0c             	sub    $0xc,%esp
80104458:	68 80 6e 10 80       	push   $0x80106e80
8010445d:	e8 e6 be ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104462:	83 ec 0c             	sub    $0xc,%esp
80104465:	68 8c 6e 10 80       	push   $0x80106e8c
8010446a:	e8 d9 be ff ff       	call   80100348 <panic>
    return 0;
8010446f:	89 c3                	mov    %eax,%ebx
80104471:	e9 04 ff ff ff       	jmp    8010437a <create+0x6e>

80104476 <sys_dup>:
{
80104476:	55                   	push   %ebp
80104477:	89 e5                	mov    %esp,%ebp
80104479:	53                   	push   %ebx
8010447a:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010447d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104480:	ba 00 00 00 00       	mov    $0x0,%edx
80104485:	b8 00 00 00 00       	mov    $0x0,%eax
8010448a:	e8 88 fd ff ff       	call   80104217 <argfd>
8010448f:	85 c0                	test   %eax,%eax
80104491:	78 23                	js     801044b6 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	e8 e3 fd ff ff       	call   8010427e <fdalloc>
8010449b:	89 c3                	mov    %eax,%ebx
8010449d:	85 c0                	test   %eax,%eax
8010449f:	78 1c                	js     801044bd <sys_dup+0x47>
  filedup(f);
801044a1:	83 ec 0c             	sub    $0xc,%esp
801044a4:	ff 75 f4             	pushl  -0xc(%ebp)
801044a7:	e8 e2 c7 ff ff       	call   80100c8e <filedup>
  return fd;
801044ac:	83 c4 10             	add    $0x10,%esp
}
801044af:	89 d8                	mov    %ebx,%eax
801044b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044b4:	c9                   	leave  
801044b5:	c3                   	ret    
    return -1;
801044b6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044bb:	eb f2                	jmp    801044af <sys_dup+0x39>
    return -1;
801044bd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044c2:	eb eb                	jmp    801044af <sys_dup+0x39>

801044c4 <sys_read>:
{
801044c4:	55                   	push   %ebp
801044c5:	89 e5                	mov    %esp,%ebp
801044c7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044ca:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044cd:	ba 00 00 00 00       	mov    $0x0,%edx
801044d2:	b8 00 00 00 00       	mov    $0x0,%eax
801044d7:	e8 3b fd ff ff       	call   80104217 <argfd>
801044dc:	85 c0                	test   %eax,%eax
801044de:	78 43                	js     80104523 <sys_read+0x5f>
801044e0:	83 ec 08             	sub    $0x8,%esp
801044e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044e6:	50                   	push   %eax
801044e7:	6a 02                	push   $0x2
801044e9:	e8 11 fc ff ff       	call   801040ff <argint>
801044ee:	83 c4 10             	add    $0x10,%esp
801044f1:	85 c0                	test   %eax,%eax
801044f3:	78 35                	js     8010452a <sys_read+0x66>
801044f5:	83 ec 04             	sub    $0x4,%esp
801044f8:	ff 75 f0             	pushl  -0x10(%ebp)
801044fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044fe:	50                   	push   %eax
801044ff:	6a 01                	push   $0x1
80104501:	e8 21 fc ff ff       	call   80104127 <argptr>
80104506:	83 c4 10             	add    $0x10,%esp
80104509:	85 c0                	test   %eax,%eax
8010450b:	78 24                	js     80104531 <sys_read+0x6d>
  return fileread(f, p, n);
8010450d:	83 ec 04             	sub    $0x4,%esp
80104510:	ff 75 f0             	pushl  -0x10(%ebp)
80104513:	ff 75 ec             	pushl  -0x14(%ebp)
80104516:	ff 75 f4             	pushl  -0xc(%ebp)
80104519:	e8 b9 c8 ff ff       	call   80100dd7 <fileread>
8010451e:	83 c4 10             	add    $0x10,%esp
}
80104521:	c9                   	leave  
80104522:	c3                   	ret    
    return -1;
80104523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104528:	eb f7                	jmp    80104521 <sys_read+0x5d>
8010452a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010452f:	eb f0                	jmp    80104521 <sys_read+0x5d>
80104531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104536:	eb e9                	jmp    80104521 <sys_read+0x5d>

80104538 <sys_write>:
{
80104538:	55                   	push   %ebp
80104539:	89 e5                	mov    %esp,%ebp
8010453b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010453e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104541:	ba 00 00 00 00       	mov    $0x0,%edx
80104546:	b8 00 00 00 00       	mov    $0x0,%eax
8010454b:	e8 c7 fc ff ff       	call   80104217 <argfd>
80104550:	85 c0                	test   %eax,%eax
80104552:	78 43                	js     80104597 <sys_write+0x5f>
80104554:	83 ec 08             	sub    $0x8,%esp
80104557:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010455a:	50                   	push   %eax
8010455b:	6a 02                	push   $0x2
8010455d:	e8 9d fb ff ff       	call   801040ff <argint>
80104562:	83 c4 10             	add    $0x10,%esp
80104565:	85 c0                	test   %eax,%eax
80104567:	78 35                	js     8010459e <sys_write+0x66>
80104569:	83 ec 04             	sub    $0x4,%esp
8010456c:	ff 75 f0             	pushl  -0x10(%ebp)
8010456f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104572:	50                   	push   %eax
80104573:	6a 01                	push   $0x1
80104575:	e8 ad fb ff ff       	call   80104127 <argptr>
8010457a:	83 c4 10             	add    $0x10,%esp
8010457d:	85 c0                	test   %eax,%eax
8010457f:	78 24                	js     801045a5 <sys_write+0x6d>
  return filewrite(f, p, n);
80104581:	83 ec 04             	sub    $0x4,%esp
80104584:	ff 75 f0             	pushl  -0x10(%ebp)
80104587:	ff 75 ec             	pushl  -0x14(%ebp)
8010458a:	ff 75 f4             	pushl  -0xc(%ebp)
8010458d:	e8 ca c8 ff ff       	call   80100e5c <filewrite>
80104592:	83 c4 10             	add    $0x10,%esp
}
80104595:	c9                   	leave  
80104596:	c3                   	ret    
    return -1;
80104597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010459c:	eb f7                	jmp    80104595 <sys_write+0x5d>
8010459e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a3:	eb f0                	jmp    80104595 <sys_write+0x5d>
801045a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045aa:	eb e9                	jmp    80104595 <sys_write+0x5d>

801045ac <sys_close>:
{
801045ac:	55                   	push   %ebp
801045ad:	89 e5                	mov    %esp,%ebp
801045af:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801045b2:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801045b5:	8d 55 f4             	lea    -0xc(%ebp),%edx
801045b8:	b8 00 00 00 00       	mov    $0x0,%eax
801045bd:	e8 55 fc ff ff       	call   80104217 <argfd>
801045c2:	85 c0                	test   %eax,%eax
801045c4:	78 25                	js     801045eb <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801045c6:	e8 2d ee ff ff       	call   801033f8 <myproc>
801045cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ce:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801045d5:	00 
  fileclose(f);
801045d6:	83 ec 0c             	sub    $0xc,%esp
801045d9:	ff 75 f0             	pushl  -0x10(%ebp)
801045dc:	e8 f2 c6 ff ff       	call   80100cd3 <fileclose>
  return 0;
801045e1:	83 c4 10             	add    $0x10,%esp
801045e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045e9:	c9                   	leave  
801045ea:	c3                   	ret    
    return -1;
801045eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f0:	eb f7                	jmp    801045e9 <sys_close+0x3d>

801045f2 <sys_fstat>:
{
801045f2:	55                   	push   %ebp
801045f3:	89 e5                	mov    %esp,%ebp
801045f5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801045f8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801045fb:	ba 00 00 00 00       	mov    $0x0,%edx
80104600:	b8 00 00 00 00       	mov    $0x0,%eax
80104605:	e8 0d fc ff ff       	call   80104217 <argfd>
8010460a:	85 c0                	test   %eax,%eax
8010460c:	78 2a                	js     80104638 <sys_fstat+0x46>
8010460e:	83 ec 04             	sub    $0x4,%esp
80104611:	6a 14                	push   $0x14
80104613:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104616:	50                   	push   %eax
80104617:	6a 01                	push   $0x1
80104619:	e8 09 fb ff ff       	call   80104127 <argptr>
8010461e:	83 c4 10             	add    $0x10,%esp
80104621:	85 c0                	test   %eax,%eax
80104623:	78 1a                	js     8010463f <sys_fstat+0x4d>
  return filestat(f, st);
80104625:	83 ec 08             	sub    $0x8,%esp
80104628:	ff 75 f0             	pushl  -0x10(%ebp)
8010462b:	ff 75 f4             	pushl  -0xc(%ebp)
8010462e:	e8 5d c7 ff ff       	call   80100d90 <filestat>
80104633:	83 c4 10             	add    $0x10,%esp
}
80104636:	c9                   	leave  
80104637:	c3                   	ret    
    return -1;
80104638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010463d:	eb f7                	jmp    80104636 <sys_fstat+0x44>
8010463f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104644:	eb f0                	jmp    80104636 <sys_fstat+0x44>

80104646 <sys_link>:
{
80104646:	55                   	push   %ebp
80104647:	89 e5                	mov    %esp,%ebp
80104649:	56                   	push   %esi
8010464a:	53                   	push   %ebx
8010464b:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010464e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104651:	50                   	push   %eax
80104652:	6a 00                	push   $0x0
80104654:	e8 36 fb ff ff       	call   8010418f <argstr>
80104659:	83 c4 10             	add    $0x10,%esp
8010465c:	85 c0                	test   %eax,%eax
8010465e:	0f 88 32 01 00 00    	js     80104796 <sys_link+0x150>
80104664:	83 ec 08             	sub    $0x8,%esp
80104667:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010466a:	50                   	push   %eax
8010466b:	6a 01                	push   $0x1
8010466d:	e8 1d fb ff ff       	call   8010418f <argstr>
80104672:	83 c4 10             	add    $0x10,%esp
80104675:	85 c0                	test   %eax,%eax
80104677:	0f 88 20 01 00 00    	js     8010479d <sys_link+0x157>
  begin_op();
8010467d:	e8 fe e2 ff ff       	call   80102980 <begin_op>
  if((ip = namei(old)) == 0){
80104682:	83 ec 0c             	sub    $0xc,%esp
80104685:	ff 75 e0             	pushl  -0x20(%ebp)
80104688:	e8 54 d5 ff ff       	call   80101be1 <namei>
8010468d:	89 c3                	mov    %eax,%ebx
8010468f:	83 c4 10             	add    $0x10,%esp
80104692:	85 c0                	test   %eax,%eax
80104694:	0f 84 99 00 00 00    	je     80104733 <sys_link+0xed>
  ilock(ip);
8010469a:	83 ec 0c             	sub    $0xc,%esp
8010469d:	50                   	push   %eax
8010469e:	e8 de ce ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801046a3:	83 c4 10             	add    $0x10,%esp
801046a6:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046ab:	0f 84 8e 00 00 00    	je     8010473f <sys_link+0xf9>
  ip->nlink++;
801046b1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046b5:	83 c0 01             	add    $0x1,%eax
801046b8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046bc:	83 ec 0c             	sub    $0xc,%esp
801046bf:	53                   	push   %ebx
801046c0:	e8 5b cd ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801046c5:	89 1c 24             	mov    %ebx,(%esp)
801046c8:	e8 76 cf ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801046cd:	83 c4 08             	add    $0x8,%esp
801046d0:	8d 45 ea             	lea    -0x16(%ebp),%eax
801046d3:	50                   	push   %eax
801046d4:	ff 75 e4             	pushl  -0x1c(%ebp)
801046d7:	e8 1d d5 ff ff       	call   80101bf9 <nameiparent>
801046dc:	89 c6                	mov    %eax,%esi
801046de:	83 c4 10             	add    $0x10,%esp
801046e1:	85 c0                	test   %eax,%eax
801046e3:	74 7e                	je     80104763 <sys_link+0x11d>
  ilock(dp);
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	50                   	push   %eax
801046e9:	e8 93 ce ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801046ee:	83 c4 10             	add    $0x10,%esp
801046f1:	8b 03                	mov    (%ebx),%eax
801046f3:	39 06                	cmp    %eax,(%esi)
801046f5:	75 60                	jne    80104757 <sys_link+0x111>
801046f7:	83 ec 04             	sub    $0x4,%esp
801046fa:	ff 73 04             	pushl  0x4(%ebx)
801046fd:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104700:	50                   	push   %eax
80104701:	56                   	push   %esi
80104702:	e8 29 d4 ff ff       	call   80101b30 <dirlink>
80104707:	83 c4 10             	add    $0x10,%esp
8010470a:	85 c0                	test   %eax,%eax
8010470c:	78 49                	js     80104757 <sys_link+0x111>
  iunlockput(dp);
8010470e:	83 ec 0c             	sub    $0xc,%esp
80104711:	56                   	push   %esi
80104712:	e8 11 d0 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104717:	89 1c 24             	mov    %ebx,(%esp)
8010471a:	e8 69 cf ff ff       	call   80101688 <iput>
  end_op();
8010471f:	e8 d6 e2 ff ff       	call   801029fa <end_op>
  return 0;
80104724:	83 c4 10             	add    $0x10,%esp
80104727:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010472c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010472f:	5b                   	pop    %ebx
80104730:	5e                   	pop    %esi
80104731:	5d                   	pop    %ebp
80104732:	c3                   	ret    
    end_op();
80104733:	e8 c2 e2 ff ff       	call   801029fa <end_op>
    return -1;
80104738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010473d:	eb ed                	jmp    8010472c <sys_link+0xe6>
    iunlockput(ip);
8010473f:	83 ec 0c             	sub    $0xc,%esp
80104742:	53                   	push   %ebx
80104743:	e8 e0 cf ff ff       	call   80101728 <iunlockput>
    end_op();
80104748:	e8 ad e2 ff ff       	call   801029fa <end_op>
    return -1;
8010474d:	83 c4 10             	add    $0x10,%esp
80104750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104755:	eb d5                	jmp    8010472c <sys_link+0xe6>
    iunlockput(dp);
80104757:	83 ec 0c             	sub    $0xc,%esp
8010475a:	56                   	push   %esi
8010475b:	e8 c8 cf ff ff       	call   80101728 <iunlockput>
    goto bad;
80104760:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104763:	83 ec 0c             	sub    $0xc,%esp
80104766:	53                   	push   %ebx
80104767:	e8 15 ce ff ff       	call   80101581 <ilock>
  ip->nlink--;
8010476c:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104770:	83 e8 01             	sub    $0x1,%eax
80104773:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104777:	89 1c 24             	mov    %ebx,(%esp)
8010477a:	e8 a1 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010477f:	89 1c 24             	mov    %ebx,(%esp)
80104782:	e8 a1 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104787:	e8 6e e2 ff ff       	call   801029fa <end_op>
  return -1;
8010478c:	83 c4 10             	add    $0x10,%esp
8010478f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104794:	eb 96                	jmp    8010472c <sys_link+0xe6>
    return -1;
80104796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010479b:	eb 8f                	jmp    8010472c <sys_link+0xe6>
8010479d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a2:	eb 88                	jmp    8010472c <sys_link+0xe6>

801047a4 <sys_unlink>:
{
801047a4:	55                   	push   %ebp
801047a5:	89 e5                	mov    %esp,%ebp
801047a7:	57                   	push   %edi
801047a8:	56                   	push   %esi
801047a9:	53                   	push   %ebx
801047aa:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801047ad:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047b0:	50                   	push   %eax
801047b1:	6a 00                	push   $0x0
801047b3:	e8 d7 f9 ff ff       	call   8010418f <argstr>
801047b8:	83 c4 10             	add    $0x10,%esp
801047bb:	85 c0                	test   %eax,%eax
801047bd:	0f 88 83 01 00 00    	js     80104946 <sys_unlink+0x1a2>
  begin_op();
801047c3:	e8 b8 e1 ff ff       	call   80102980 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801047c8:	83 ec 08             	sub    $0x8,%esp
801047cb:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047ce:	50                   	push   %eax
801047cf:	ff 75 c4             	pushl  -0x3c(%ebp)
801047d2:	e8 22 d4 ff ff       	call   80101bf9 <nameiparent>
801047d7:	89 c6                	mov    %eax,%esi
801047d9:	83 c4 10             	add    $0x10,%esp
801047dc:	85 c0                	test   %eax,%eax
801047de:	0f 84 ed 00 00 00    	je     801048d1 <sys_unlink+0x12d>
  ilock(dp);
801047e4:	83 ec 0c             	sub    $0xc,%esp
801047e7:	50                   	push   %eax
801047e8:	e8 94 cd ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801047ed:	83 c4 08             	add    $0x8,%esp
801047f0:	68 7e 6e 10 80       	push   $0x80106e7e
801047f5:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047f8:	50                   	push   %eax
801047f9:	e8 9d d1 ff ff       	call   8010199b <namecmp>
801047fe:	83 c4 10             	add    $0x10,%esp
80104801:	85 c0                	test   %eax,%eax
80104803:	0f 84 fc 00 00 00    	je     80104905 <sys_unlink+0x161>
80104809:	83 ec 08             	sub    $0x8,%esp
8010480c:	68 7d 6e 10 80       	push   $0x80106e7d
80104811:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104814:	50                   	push   %eax
80104815:	e8 81 d1 ff ff       	call   8010199b <namecmp>
8010481a:	83 c4 10             	add    $0x10,%esp
8010481d:	85 c0                	test   %eax,%eax
8010481f:	0f 84 e0 00 00 00    	je     80104905 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104825:	83 ec 04             	sub    $0x4,%esp
80104828:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010482b:	50                   	push   %eax
8010482c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010482f:	50                   	push   %eax
80104830:	56                   	push   %esi
80104831:	e8 7a d1 ff ff       	call   801019b0 <dirlookup>
80104836:	89 c3                	mov    %eax,%ebx
80104838:	83 c4 10             	add    $0x10,%esp
8010483b:	85 c0                	test   %eax,%eax
8010483d:	0f 84 c2 00 00 00    	je     80104905 <sys_unlink+0x161>
  ilock(ip);
80104843:	83 ec 0c             	sub    $0xc,%esp
80104846:	50                   	push   %eax
80104847:	e8 35 cd ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
8010484c:	83 c4 10             	add    $0x10,%esp
8010484f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104854:	0f 8e 83 00 00 00    	jle    801048dd <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010485a:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010485f:	0f 84 85 00 00 00    	je     801048ea <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104865:	83 ec 04             	sub    $0x4,%esp
80104868:	6a 10                	push   $0x10
8010486a:	6a 00                	push   $0x0
8010486c:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010486f:	57                   	push   %edi
80104870:	e8 3f f6 ff ff       	call   80103eb4 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104875:	6a 10                	push   $0x10
80104877:	ff 75 c0             	pushl  -0x40(%ebp)
8010487a:	57                   	push   %edi
8010487b:	56                   	push   %esi
8010487c:	e8 ef cf ff ff       	call   80101870 <writei>
80104881:	83 c4 20             	add    $0x20,%esp
80104884:	83 f8 10             	cmp    $0x10,%eax
80104887:	0f 85 90 00 00 00    	jne    8010491d <sys_unlink+0x179>
  if(ip->type == T_DIR){
8010488d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104892:	0f 84 92 00 00 00    	je     8010492a <sys_unlink+0x186>
  iunlockput(dp);
80104898:	83 ec 0c             	sub    $0xc,%esp
8010489b:	56                   	push   %esi
8010489c:	e8 87 ce ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801048a1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801048a5:	83 e8 01             	sub    $0x1,%eax
801048a8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801048ac:	89 1c 24             	mov    %ebx,(%esp)
801048af:	e8 6c cb ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801048b4:	89 1c 24             	mov    %ebx,(%esp)
801048b7:	e8 6c ce ff ff       	call   80101728 <iunlockput>
  end_op();
801048bc:	e8 39 e1 ff ff       	call   801029fa <end_op>
  return 0;
801048c1:	83 c4 10             	add    $0x10,%esp
801048c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048cc:	5b                   	pop    %ebx
801048cd:	5e                   	pop    %esi
801048ce:	5f                   	pop    %edi
801048cf:	5d                   	pop    %ebp
801048d0:	c3                   	ret    
    end_op();
801048d1:	e8 24 e1 ff ff       	call   801029fa <end_op>
    return -1;
801048d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048db:	eb ec                	jmp    801048c9 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801048dd:	83 ec 0c             	sub    $0xc,%esp
801048e0:	68 9c 6e 10 80       	push   $0x80106e9c
801048e5:	e8 5e ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801048ea:	89 d8                	mov    %ebx,%eax
801048ec:	e8 c4 f9 ff ff       	call   801042b5 <isdirempty>
801048f1:	85 c0                	test   %eax,%eax
801048f3:	0f 85 6c ff ff ff    	jne    80104865 <sys_unlink+0xc1>
    iunlockput(ip);
801048f9:	83 ec 0c             	sub    $0xc,%esp
801048fc:	53                   	push   %ebx
801048fd:	e8 26 ce ff ff       	call   80101728 <iunlockput>
    goto bad;
80104902:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104905:	83 ec 0c             	sub    $0xc,%esp
80104908:	56                   	push   %esi
80104909:	e8 1a ce ff ff       	call   80101728 <iunlockput>
  end_op();
8010490e:	e8 e7 e0 ff ff       	call   801029fa <end_op>
  return -1;
80104913:	83 c4 10             	add    $0x10,%esp
80104916:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010491b:	eb ac                	jmp    801048c9 <sys_unlink+0x125>
    panic("unlink: writei");
8010491d:	83 ec 0c             	sub    $0xc,%esp
80104920:	68 ae 6e 10 80       	push   $0x80106eae
80104925:	e8 1e ba ff ff       	call   80100348 <panic>
    dp->nlink--;
8010492a:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010492e:	83 e8 01             	sub    $0x1,%eax
80104931:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104935:	83 ec 0c             	sub    $0xc,%esp
80104938:	56                   	push   %esi
80104939:	e8 e2 ca ff ff       	call   80101420 <iupdate>
8010493e:	83 c4 10             	add    $0x10,%esp
80104941:	e9 52 ff ff ff       	jmp    80104898 <sys_unlink+0xf4>
    return -1;
80104946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010494b:	e9 79 ff ff ff       	jmp    801048c9 <sys_unlink+0x125>

80104950 <sys_open>:

int
sys_open(void)
{
80104950:	55                   	push   %ebp
80104951:	89 e5                	mov    %esp,%ebp
80104953:	57                   	push   %edi
80104954:	56                   	push   %esi
80104955:	53                   	push   %ebx
80104956:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104959:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010495c:	50                   	push   %eax
8010495d:	6a 00                	push   $0x0
8010495f:	e8 2b f8 ff ff       	call   8010418f <argstr>
80104964:	83 c4 10             	add    $0x10,%esp
80104967:	85 c0                	test   %eax,%eax
80104969:	0f 88 30 01 00 00    	js     80104a9f <sys_open+0x14f>
8010496f:	83 ec 08             	sub    $0x8,%esp
80104972:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104975:	50                   	push   %eax
80104976:	6a 01                	push   $0x1
80104978:	e8 82 f7 ff ff       	call   801040ff <argint>
8010497d:	83 c4 10             	add    $0x10,%esp
80104980:	85 c0                	test   %eax,%eax
80104982:	0f 88 21 01 00 00    	js     80104aa9 <sys_open+0x159>
    return -1;

  begin_op();
80104988:	e8 f3 df ff ff       	call   80102980 <begin_op>

  if(omode & O_CREATE){
8010498d:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104991:	0f 84 84 00 00 00    	je     80104a1b <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104997:	83 ec 0c             	sub    $0xc,%esp
8010499a:	6a 00                	push   $0x0
8010499c:	b9 00 00 00 00       	mov    $0x0,%ecx
801049a1:	ba 02 00 00 00       	mov    $0x2,%edx
801049a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801049a9:	e8 5e f9 ff ff       	call   8010430c <create>
801049ae:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801049b0:	83 c4 10             	add    $0x10,%esp
801049b3:	85 c0                	test   %eax,%eax
801049b5:	74 58                	je     80104a0f <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801049b7:	e8 71 c2 ff ff       	call   80100c2d <filealloc>
801049bc:	89 c3                	mov    %eax,%ebx
801049be:	85 c0                	test   %eax,%eax
801049c0:	0f 84 ae 00 00 00    	je     80104a74 <sys_open+0x124>
801049c6:	e8 b3 f8 ff ff       	call   8010427e <fdalloc>
801049cb:	89 c7                	mov    %eax,%edi
801049cd:	85 c0                	test   %eax,%eax
801049cf:	0f 88 9f 00 00 00    	js     80104a74 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049d5:	83 ec 0c             	sub    $0xc,%esp
801049d8:	56                   	push   %esi
801049d9:	e8 65 cc ff ff       	call   80101643 <iunlock>
  end_op();
801049de:	e8 17 e0 ff ff       	call   801029fa <end_op>

  f->type = FD_INODE;
801049e3:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801049e9:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801049ec:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801049f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f6:	83 c4 10             	add    $0x10,%esp
801049f9:	a8 01                	test   $0x1,%al
801049fb:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801049ff:	a8 03                	test   $0x3,%al
80104a01:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104a05:	89 f8                	mov    %edi,%eax
80104a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a0a:	5b                   	pop    %ebx
80104a0b:	5e                   	pop    %esi
80104a0c:	5f                   	pop    %edi
80104a0d:	5d                   	pop    %ebp
80104a0e:	c3                   	ret    
      end_op();
80104a0f:	e8 e6 df ff ff       	call   801029fa <end_op>
      return -1;
80104a14:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a19:	eb ea                	jmp    80104a05 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104a1b:	83 ec 0c             	sub    $0xc,%esp
80104a1e:	ff 75 e4             	pushl  -0x1c(%ebp)
80104a21:	e8 bb d1 ff ff       	call   80101be1 <namei>
80104a26:	89 c6                	mov    %eax,%esi
80104a28:	83 c4 10             	add    $0x10,%esp
80104a2b:	85 c0                	test   %eax,%eax
80104a2d:	74 39                	je     80104a68 <sys_open+0x118>
    ilock(ip);
80104a2f:	83 ec 0c             	sub    $0xc,%esp
80104a32:	50                   	push   %eax
80104a33:	e8 49 cb ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a38:	83 c4 10             	add    $0x10,%esp
80104a3b:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104a40:	0f 85 71 ff ff ff    	jne    801049b7 <sys_open+0x67>
80104a46:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a4a:	0f 84 67 ff ff ff    	je     801049b7 <sys_open+0x67>
      iunlockput(ip);
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	56                   	push   %esi
80104a54:	e8 cf cc ff ff       	call   80101728 <iunlockput>
      end_op();
80104a59:	e8 9c df ff ff       	call   801029fa <end_op>
      return -1;
80104a5e:	83 c4 10             	add    $0x10,%esp
80104a61:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a66:	eb 9d                	jmp    80104a05 <sys_open+0xb5>
      end_op();
80104a68:	e8 8d df ff ff       	call   801029fa <end_op>
      return -1;
80104a6d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a72:	eb 91                	jmp    80104a05 <sys_open+0xb5>
    if(f)
80104a74:	85 db                	test   %ebx,%ebx
80104a76:	74 0c                	je     80104a84 <sys_open+0x134>
      fileclose(f);
80104a78:	83 ec 0c             	sub    $0xc,%esp
80104a7b:	53                   	push   %ebx
80104a7c:	e8 52 c2 ff ff       	call   80100cd3 <fileclose>
80104a81:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104a84:	83 ec 0c             	sub    $0xc,%esp
80104a87:	56                   	push   %esi
80104a88:	e8 9b cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104a8d:	e8 68 df ff ff       	call   801029fa <end_op>
    return -1;
80104a92:	83 c4 10             	add    $0x10,%esp
80104a95:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a9a:	e9 66 ff ff ff       	jmp    80104a05 <sys_open+0xb5>
    return -1;
80104a9f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104aa4:	e9 5c ff ff ff       	jmp    80104a05 <sys_open+0xb5>
80104aa9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104aae:	e9 52 ff ff ff       	jmp    80104a05 <sys_open+0xb5>

80104ab3 <sys_mkdir>:

int
sys_mkdir(void)
{
80104ab3:	55                   	push   %ebp
80104ab4:	89 e5                	mov    %esp,%ebp
80104ab6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104ab9:	e8 c2 de ff ff       	call   80102980 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104abe:	83 ec 08             	sub    $0x8,%esp
80104ac1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ac4:	50                   	push   %eax
80104ac5:	6a 00                	push   $0x0
80104ac7:	e8 c3 f6 ff ff       	call   8010418f <argstr>
80104acc:	83 c4 10             	add    $0x10,%esp
80104acf:	85 c0                	test   %eax,%eax
80104ad1:	78 36                	js     80104b09 <sys_mkdir+0x56>
80104ad3:	83 ec 0c             	sub    $0xc,%esp
80104ad6:	6a 00                	push   $0x0
80104ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
80104add:	ba 01 00 00 00       	mov    $0x1,%edx
80104ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae5:	e8 22 f8 ff ff       	call   8010430c <create>
80104aea:	83 c4 10             	add    $0x10,%esp
80104aed:	85 c0                	test   %eax,%eax
80104aef:	74 18                	je     80104b09 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	50                   	push   %eax
80104af5:	e8 2e cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104afa:	e8 fb de ff ff       	call   801029fa <end_op>
  return 0;
80104aff:	83 c4 10             	add    $0x10,%esp
80104b02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b07:	c9                   	leave  
80104b08:	c3                   	ret    
    end_op();
80104b09:	e8 ec de ff ff       	call   801029fa <end_op>
    return -1;
80104b0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b13:	eb f2                	jmp    80104b07 <sys_mkdir+0x54>

80104b15 <sys_mknod>:

int
sys_mknod(void)
{
80104b15:	55                   	push   %ebp
80104b16:	89 e5                	mov    %esp,%ebp
80104b18:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104b1b:	e8 60 de ff ff       	call   80102980 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104b20:	83 ec 08             	sub    $0x8,%esp
80104b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b26:	50                   	push   %eax
80104b27:	6a 00                	push   $0x0
80104b29:	e8 61 f6 ff ff       	call   8010418f <argstr>
80104b2e:	83 c4 10             	add    $0x10,%esp
80104b31:	85 c0                	test   %eax,%eax
80104b33:	78 62                	js     80104b97 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104b35:	83 ec 08             	sub    $0x8,%esp
80104b38:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b3b:	50                   	push   %eax
80104b3c:	6a 01                	push   $0x1
80104b3e:	e8 bc f5 ff ff       	call   801040ff <argint>
  if((argstr(0, &path)) < 0 ||
80104b43:	83 c4 10             	add    $0x10,%esp
80104b46:	85 c0                	test   %eax,%eax
80104b48:	78 4d                	js     80104b97 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104b4a:	83 ec 08             	sub    $0x8,%esp
80104b4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b50:	50                   	push   %eax
80104b51:	6a 02                	push   $0x2
80104b53:	e8 a7 f5 ff ff       	call   801040ff <argint>
     argint(1, &major) < 0 ||
80104b58:	83 c4 10             	add    $0x10,%esp
80104b5b:	85 c0                	test   %eax,%eax
80104b5d:	78 38                	js     80104b97 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b5f:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104b63:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104b67:	83 ec 0c             	sub    $0xc,%esp
80104b6a:	50                   	push   %eax
80104b6b:	ba 03 00 00 00       	mov    $0x3,%edx
80104b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b73:	e8 94 f7 ff ff       	call   8010430c <create>
80104b78:	83 c4 10             	add    $0x10,%esp
80104b7b:	85 c0                	test   %eax,%eax
80104b7d:	74 18                	je     80104b97 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b7f:	83 ec 0c             	sub    $0xc,%esp
80104b82:	50                   	push   %eax
80104b83:	e8 a0 cb ff ff       	call   80101728 <iunlockput>
  end_op();
80104b88:	e8 6d de ff ff       	call   801029fa <end_op>
  return 0;
80104b8d:	83 c4 10             	add    $0x10,%esp
80104b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b95:	c9                   	leave  
80104b96:	c3                   	ret    
    end_op();
80104b97:	e8 5e de ff ff       	call   801029fa <end_op>
    return -1;
80104b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba1:	eb f2                	jmp    80104b95 <sys_mknod+0x80>

80104ba3 <sys_chdir>:

int
sys_chdir(void)
{
80104ba3:	55                   	push   %ebp
80104ba4:	89 e5                	mov    %esp,%ebp
80104ba6:	56                   	push   %esi
80104ba7:	53                   	push   %ebx
80104ba8:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104bab:	e8 48 e8 ff ff       	call   801033f8 <myproc>
80104bb0:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104bb2:	e8 c9 dd ff ff       	call   80102980 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104bb7:	83 ec 08             	sub    $0x8,%esp
80104bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bbd:	50                   	push   %eax
80104bbe:	6a 00                	push   $0x0
80104bc0:	e8 ca f5 ff ff       	call   8010418f <argstr>
80104bc5:	83 c4 10             	add    $0x10,%esp
80104bc8:	85 c0                	test   %eax,%eax
80104bca:	78 52                	js     80104c1e <sys_chdir+0x7b>
80104bcc:	83 ec 0c             	sub    $0xc,%esp
80104bcf:	ff 75 f4             	pushl  -0xc(%ebp)
80104bd2:	e8 0a d0 ff ff       	call   80101be1 <namei>
80104bd7:	89 c3                	mov    %eax,%ebx
80104bd9:	83 c4 10             	add    $0x10,%esp
80104bdc:	85 c0                	test   %eax,%eax
80104bde:	74 3e                	je     80104c1e <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104be0:	83 ec 0c             	sub    $0xc,%esp
80104be3:	50                   	push   %eax
80104be4:	e8 98 c9 ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104be9:	83 c4 10             	add    $0x10,%esp
80104bec:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104bf1:	75 37                	jne    80104c2a <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104bf3:	83 ec 0c             	sub    $0xc,%esp
80104bf6:	53                   	push   %ebx
80104bf7:	e8 47 ca ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104bfc:	83 c4 04             	add    $0x4,%esp
80104bff:	ff 76 68             	pushl  0x68(%esi)
80104c02:	e8 81 ca ff ff       	call   80101688 <iput>
  end_op();
80104c07:	e8 ee dd ff ff       	call   801029fa <end_op>
  curproc->cwd = ip;
80104c0c:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104c0f:	83 c4 10             	add    $0x10,%esp
80104c12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c17:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c1a:	5b                   	pop    %ebx
80104c1b:	5e                   	pop    %esi
80104c1c:	5d                   	pop    %ebp
80104c1d:	c3                   	ret    
    end_op();
80104c1e:	e8 d7 dd ff ff       	call   801029fa <end_op>
    return -1;
80104c23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c28:	eb ed                	jmp    80104c17 <sys_chdir+0x74>
    iunlockput(ip);
80104c2a:	83 ec 0c             	sub    $0xc,%esp
80104c2d:	53                   	push   %ebx
80104c2e:	e8 f5 ca ff ff       	call   80101728 <iunlockput>
    end_op();
80104c33:	e8 c2 dd ff ff       	call   801029fa <end_op>
    return -1;
80104c38:	83 c4 10             	add    $0x10,%esp
80104c3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c40:	eb d5                	jmp    80104c17 <sys_chdir+0x74>

80104c42 <sys_exec>:

int
sys_exec(void)
{
80104c42:	55                   	push   %ebp
80104c43:	89 e5                	mov    %esp,%ebp
80104c45:	53                   	push   %ebx
80104c46:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104c4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c4f:	50                   	push   %eax
80104c50:	6a 00                	push   $0x0
80104c52:	e8 38 f5 ff ff       	call   8010418f <argstr>
80104c57:	83 c4 10             	add    $0x10,%esp
80104c5a:	85 c0                	test   %eax,%eax
80104c5c:	0f 88 a8 00 00 00    	js     80104d0a <sys_exec+0xc8>
80104c62:	83 ec 08             	sub    $0x8,%esp
80104c65:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104c6b:	50                   	push   %eax
80104c6c:	6a 01                	push   $0x1
80104c6e:	e8 8c f4 ff ff       	call   801040ff <argint>
80104c73:	83 c4 10             	add    $0x10,%esp
80104c76:	85 c0                	test   %eax,%eax
80104c78:	0f 88 93 00 00 00    	js     80104d11 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104c7e:	83 ec 04             	sub    $0x4,%esp
80104c81:	68 80 00 00 00       	push   $0x80
80104c86:	6a 00                	push   $0x0
80104c88:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c8e:	50                   	push   %eax
80104c8f:	e8 20 f2 ff ff       	call   80103eb4 <memset>
80104c94:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104c97:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104c9c:	83 fb 1f             	cmp    $0x1f,%ebx
80104c9f:	77 77                	ja     80104d18 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104ca1:	83 ec 08             	sub    $0x8,%esp
80104ca4:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104caa:	50                   	push   %eax
80104cab:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104cb1:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104cb4:	50                   	push   %eax
80104cb5:	e8 c9 f3 ff ff       	call   80104083 <fetchint>
80104cba:	83 c4 10             	add    $0x10,%esp
80104cbd:	85 c0                	test   %eax,%eax
80104cbf:	78 5e                	js     80104d1f <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104cc1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104cc7:	85 c0                	test   %eax,%eax
80104cc9:	74 1d                	je     80104ce8 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104ccb:	83 ec 08             	sub    $0x8,%esp
80104cce:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104cd5:	52                   	push   %edx
80104cd6:	50                   	push   %eax
80104cd7:	e8 e3 f3 ff ff       	call   801040bf <fetchstr>
80104cdc:	83 c4 10             	add    $0x10,%esp
80104cdf:	85 c0                	test   %eax,%eax
80104ce1:	78 46                	js     80104d29 <sys_exec+0xe7>
  for(i=0;; i++){
80104ce3:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104ce6:	eb b4                	jmp    80104c9c <sys_exec+0x5a>
      argv[i] = 0;
80104ce8:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104cef:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104cf3:	83 ec 08             	sub    $0x8,%esp
80104cf6:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104cfc:	50                   	push   %eax
80104cfd:	ff 75 f4             	pushl  -0xc(%ebp)
80104d00:	e8 cd bb ff ff       	call   801008d2 <exec>
80104d05:	83 c4 10             	add    $0x10,%esp
80104d08:	eb 1a                	jmp    80104d24 <sys_exec+0xe2>
    return -1;
80104d0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d0f:	eb 13                	jmp    80104d24 <sys_exec+0xe2>
80104d11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d16:	eb 0c                	jmp    80104d24 <sys_exec+0xe2>
      return -1;
80104d18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d1d:	eb 05                	jmp    80104d24 <sys_exec+0xe2>
      return -1;
80104d1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d27:	c9                   	leave  
80104d28:	c3                   	ret    
      return -1;
80104d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2e:	eb f4                	jmp    80104d24 <sys_exec+0xe2>

80104d30 <sys_pipe>:

int
sys_pipe(void)
{
80104d30:	55                   	push   %ebp
80104d31:	89 e5                	mov    %esp,%ebp
80104d33:	53                   	push   %ebx
80104d34:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104d37:	6a 08                	push   $0x8
80104d39:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d3c:	50                   	push   %eax
80104d3d:	6a 00                	push   $0x0
80104d3f:	e8 e3 f3 ff ff       	call   80104127 <argptr>
80104d44:	83 c4 10             	add    $0x10,%esp
80104d47:	85 c0                	test   %eax,%eax
80104d49:	78 77                	js     80104dc2 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104d4b:	83 ec 08             	sub    $0x8,%esp
80104d4e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d51:	50                   	push   %eax
80104d52:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d55:	50                   	push   %eax
80104d56:	e8 ac e1 ff ff       	call   80102f07 <pipealloc>
80104d5b:	83 c4 10             	add    $0x10,%esp
80104d5e:	85 c0                	test   %eax,%eax
80104d60:	78 67                	js     80104dc9 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d65:	e8 14 f5 ff ff       	call   8010427e <fdalloc>
80104d6a:	89 c3                	mov    %eax,%ebx
80104d6c:	85 c0                	test   %eax,%eax
80104d6e:	78 21                	js     80104d91 <sys_pipe+0x61>
80104d70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d73:	e8 06 f5 ff ff       	call   8010427e <fdalloc>
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	78 15                	js     80104d91 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104d7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d7f:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104d81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d84:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d8f:	c9                   	leave  
80104d90:	c3                   	ret    
    if(fd0 >= 0)
80104d91:	85 db                	test   %ebx,%ebx
80104d93:	78 0d                	js     80104da2 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104d95:	e8 5e e6 ff ff       	call   801033f8 <myproc>
80104d9a:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104da1:	00 
    fileclose(rf);
80104da2:	83 ec 0c             	sub    $0xc,%esp
80104da5:	ff 75 f0             	pushl  -0x10(%ebp)
80104da8:	e8 26 bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104dad:	83 c4 04             	add    $0x4,%esp
80104db0:	ff 75 ec             	pushl  -0x14(%ebp)
80104db3:	e8 1b bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104db8:	83 c4 10             	add    $0x10,%esp
80104dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dc0:	eb ca                	jmp    80104d8c <sys_pipe+0x5c>
    return -1;
80104dc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dc7:	eb c3                	jmp    80104d8c <sys_pipe+0x5c>
    return -1;
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dce:	eb bc                	jmp    80104d8c <sys_pipe+0x5c>

80104dd0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104dd0:	55                   	push   %ebp
80104dd1:	89 e5                	mov    %esp,%ebp
80104dd3:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104dd6:	e8 9a e7 ff ff       	call   80103575 <fork>
}
80104ddb:	c9                   	leave  
80104ddc:	c3                   	ret    

80104ddd <sys_exit>:

int
sys_exit(void)
{
80104ddd:	55                   	push   %ebp
80104dde:	89 e5                	mov    %esp,%ebp
80104de0:	83 ec 08             	sub    $0x8,%esp
  exit();
80104de3:	e8 c6 e9 ff ff       	call   801037ae <exit>
  return 0;  // not reached
}
80104de8:	b8 00 00 00 00       	mov    $0x0,%eax
80104ded:	c9                   	leave  
80104dee:	c3                   	ret    

80104def <sys_wait>:

int
sys_wait(void)
{
80104def:	55                   	push   %ebp
80104df0:	89 e5                	mov    %esp,%ebp
80104df2:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104df5:	e8 3d eb ff ff       	call   80103937 <wait>
}
80104dfa:	c9                   	leave  
80104dfb:	c3                   	ret    

80104dfc <sys_kill>:

int
sys_kill(void)
{
80104dfc:	55                   	push   %ebp
80104dfd:	89 e5                	mov    %esp,%ebp
80104dff:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104e02:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e05:	50                   	push   %eax
80104e06:	6a 00                	push   $0x0
80104e08:	e8 f2 f2 ff ff       	call   801040ff <argint>
80104e0d:	83 c4 10             	add    $0x10,%esp
80104e10:	85 c0                	test   %eax,%eax
80104e12:	78 10                	js     80104e24 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104e14:	83 ec 0c             	sub    $0xc,%esp
80104e17:	ff 75 f4             	pushl  -0xc(%ebp)
80104e1a:	e8 15 ec ff ff       	call   80103a34 <kill>
80104e1f:	83 c4 10             	add    $0x10,%esp
}
80104e22:	c9                   	leave  
80104e23:	c3                   	ret    
    return -1;
80104e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e29:	eb f7                	jmp    80104e22 <sys_kill+0x26>

80104e2b <sys_getpid>:

int
sys_getpid(void)
{
80104e2b:	55                   	push   %ebp
80104e2c:	89 e5                	mov    %esp,%ebp
80104e2e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104e31:	e8 c2 e5 ff ff       	call   801033f8 <myproc>
80104e36:	8b 40 10             	mov    0x10(%eax),%eax
}
80104e39:	c9                   	leave  
80104e3a:	c3                   	ret    

80104e3b <sys_sbrk>:

int
sys_sbrk(void)
{
80104e3b:	55                   	push   %ebp
80104e3c:	89 e5                	mov    %esp,%ebp
80104e3e:	53                   	push   %ebx
80104e3f:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104e42:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e45:	50                   	push   %eax
80104e46:	6a 00                	push   $0x0
80104e48:	e8 b2 f2 ff ff       	call   801040ff <argint>
80104e4d:	83 c4 10             	add    $0x10,%esp
80104e50:	85 c0                	test   %eax,%eax
80104e52:	78 27                	js     80104e7b <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104e54:	e8 9f e5 ff ff       	call   801033f8 <myproc>
80104e59:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104e5b:	83 ec 0c             	sub    $0xc,%esp
80104e5e:	ff 75 f4             	pushl  -0xc(%ebp)
80104e61:	e8 a2 e6 ff ff       	call   80103508 <growproc>
80104e66:	83 c4 10             	add    $0x10,%esp
80104e69:	85 c0                	test   %eax,%eax
80104e6b:	78 07                	js     80104e74 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104e6d:	89 d8                	mov    %ebx,%eax
80104e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e72:	c9                   	leave  
80104e73:	c3                   	ret    
    return -1;
80104e74:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e79:	eb f2                	jmp    80104e6d <sys_sbrk+0x32>
    return -1;
80104e7b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e80:	eb eb                	jmp    80104e6d <sys_sbrk+0x32>

80104e82 <sys_sleep>:

int
sys_sleep(void)
{
80104e82:	55                   	push   %ebp
80104e83:	89 e5                	mov    %esp,%ebp
80104e85:	53                   	push   %ebx
80104e86:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e8c:	50                   	push   %eax
80104e8d:	6a 00                	push   $0x0
80104e8f:	e8 6b f2 ff ff       	call   801040ff <argint>
80104e94:	83 c4 10             	add    $0x10,%esp
80104e97:	85 c0                	test   %eax,%eax
80104e99:	78 75                	js     80104f10 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e9b:	83 ec 0c             	sub    $0xc,%esp
80104e9e:	68 80 0a 1c 80       	push   $0x801c0a80
80104ea3:	e8 60 ef ff ff       	call   80103e08 <acquire>
  ticks0 = ticks;
80104ea8:	8b 1d c0 12 1c 80    	mov    0x801c12c0,%ebx
  while(ticks - ticks0 < n){
80104eae:	83 c4 10             	add    $0x10,%esp
80104eb1:	a1 c0 12 1c 80       	mov    0x801c12c0,%eax
80104eb6:	29 d8                	sub    %ebx,%eax
80104eb8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ebb:	73 39                	jae    80104ef6 <sys_sleep+0x74>
    if(myproc()->killed){
80104ebd:	e8 36 e5 ff ff       	call   801033f8 <myproc>
80104ec2:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ec6:	75 17                	jne    80104edf <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104ec8:	83 ec 08             	sub    $0x8,%esp
80104ecb:	68 80 0a 1c 80       	push   $0x801c0a80
80104ed0:	68 c0 12 1c 80       	push   $0x801c12c0
80104ed5:	e8 cc e9 ff ff       	call   801038a6 <sleep>
80104eda:	83 c4 10             	add    $0x10,%esp
80104edd:	eb d2                	jmp    80104eb1 <sys_sleep+0x2f>
      release(&tickslock);
80104edf:	83 ec 0c             	sub    $0xc,%esp
80104ee2:	68 80 0a 1c 80       	push   $0x801c0a80
80104ee7:	e8 81 ef ff ff       	call   80103e6d <release>
      return -1;
80104eec:	83 c4 10             	add    $0x10,%esp
80104eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef4:	eb 15                	jmp    80104f0b <sys_sleep+0x89>
  }
  release(&tickslock);
80104ef6:	83 ec 0c             	sub    $0xc,%esp
80104ef9:	68 80 0a 1c 80       	push   $0x801c0a80
80104efe:	e8 6a ef ff ff       	call   80103e6d <release>
  return 0;
80104f03:	83 c4 10             	add    $0x10,%esp
80104f06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f0e:	c9                   	leave  
80104f0f:	c3                   	ret    
    return -1;
80104f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f15:	eb f4                	jmp    80104f0b <sys_sleep+0x89>

80104f17 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104f17:	55                   	push   %ebp
80104f18:	89 e5                	mov    %esp,%ebp
80104f1a:	53                   	push   %ebx
80104f1b:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104f1e:	68 80 0a 1c 80       	push   $0x801c0a80
80104f23:	e8 e0 ee ff ff       	call   80103e08 <acquire>
  xticks = ticks;
80104f28:	8b 1d c0 12 1c 80    	mov    0x801c12c0,%ebx
  release(&tickslock);
80104f2e:	c7 04 24 80 0a 1c 80 	movl   $0x801c0a80,(%esp)
80104f35:	e8 33 ef ff ff       	call   80103e6d <release>
  return xticks;
}
80104f3a:	89 d8                	mov    %ebx,%eax
80104f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f3f:	c9                   	leave  
80104f40:	c3                   	ret    

80104f41 <sys_dump_physmem>:

int 
sys_dump_physmem(void)
{
80104f41:	55                   	push   %ebp
80104f42:	89 e5                	mov    %esp,%ebp
80104f44:	83 ec 1c             	sub    $0x1c,%esp
    int *frames;
    if(argptr(0, (void*)&frames, sizeof(*frames))< 0){
80104f47:	6a 04                	push   $0x4
80104f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f4c:	50                   	push   %eax
80104f4d:	6a 00                	push   $0x0
80104f4f:	e8 d3 f1 ff ff       	call   80104127 <argptr>
80104f54:	83 c4 10             	add    $0x10,%esp
80104f57:	85 c0                	test   %eax,%eax
80104f59:	78 49                	js     80104fa4 <sys_dump_physmem+0x63>
        return -1;
    }
    int *pids;
    if(argptr(1, (void*)&pids, sizeof(*pids))< 0){
80104f5b:	83 ec 04             	sub    $0x4,%esp
80104f5e:	6a 04                	push   $0x4
80104f60:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f63:	50                   	push   %eax
80104f64:	6a 01                	push   $0x1
80104f66:	e8 bc f1 ff ff       	call   80104127 <argptr>
80104f6b:	83 c4 10             	add    $0x10,%esp
80104f6e:	85 c0                	test   %eax,%eax
80104f70:	78 39                	js     80104fab <sys_dump_physmem+0x6a>
         return -1;
    }
    int numframes = 0;
80104f72:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    if(argint(2, &numframes) < 0){
80104f79:	83 ec 08             	sub    $0x8,%esp
80104f7c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f7f:	50                   	push   %eax
80104f80:	6a 02                	push   $0x2
80104f82:	e8 78 f1 ff ff       	call   801040ff <argint>
80104f87:	83 c4 10             	add    $0x10,%esp
80104f8a:	85 c0                	test   %eax,%eax
80104f8c:	78 24                	js     80104fb2 <sys_dump_physmem+0x71>
       return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104f8e:	83 ec 04             	sub    $0x4,%esp
80104f91:	ff 75 ec             	pushl  -0x14(%ebp)
80104f94:	ff 75 f0             	pushl  -0x10(%ebp)
80104f97:	ff 75 f4             	pushl  -0xc(%ebp)
80104f9a:	e8 bb eb ff ff       	call   80103b5a <dump_physmem>
80104f9f:	83 c4 10             	add    $0x10,%esp
}
80104fa2:	c9                   	leave  
80104fa3:	c3                   	ret    
        return -1;
80104fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa9:	eb f7                	jmp    80104fa2 <sys_dump_physmem+0x61>
         return -1;
80104fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fb0:	eb f0                	jmp    80104fa2 <sys_dump_physmem+0x61>
       return -1;
80104fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fb7:	eb e9                	jmp    80104fa2 <sys_dump_physmem+0x61>

80104fb9 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104fb9:	1e                   	push   %ds
  pushl %es
80104fba:	06                   	push   %es
  pushl %fs
80104fbb:	0f a0                	push   %fs
  pushl %gs
80104fbd:	0f a8                	push   %gs
  pushal
80104fbf:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104fc0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104fc4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104fc6:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104fc8:	54                   	push   %esp
  call trap
80104fc9:	e8 e3 00 00 00       	call   801050b1 <trap>
  addl $4, %esp
80104fce:	83 c4 04             	add    $0x4,%esp

80104fd1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104fd1:	61                   	popa   
  popl %gs
80104fd2:	0f a9                	pop    %gs
  popl %fs
80104fd4:	0f a1                	pop    %fs
  popl %es
80104fd6:	07                   	pop    %es
  popl %ds
80104fd7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104fd8:	83 c4 08             	add    $0x8,%esp
  iret
80104fdb:	cf                   	iret   

80104fdc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104fdc:	55                   	push   %ebp
80104fdd:	89 e5                	mov    %esp,%ebp
80104fdf:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104fe2:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe7:	eb 4a                	jmp    80105033 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104fe9:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104ff0:	66 89 0c c5 c0 0a 1c 	mov    %cx,-0x7fe3f540(,%eax,8)
80104ff7:	80 
80104ff8:	66 c7 04 c5 c2 0a 1c 	movw   $0x8,-0x7fe3f53e(,%eax,8)
80104fff:	80 08 00 
80105002:	c6 04 c5 c4 0a 1c 80 	movb   $0x0,-0x7fe3f53c(,%eax,8)
80105009:	00 
8010500a:	0f b6 14 c5 c5 0a 1c 	movzbl -0x7fe3f53b(,%eax,8),%edx
80105011:	80 
80105012:	83 e2 f0             	and    $0xfffffff0,%edx
80105015:	83 ca 0e             	or     $0xe,%edx
80105018:	83 e2 8f             	and    $0xffffff8f,%edx
8010501b:	83 ca 80             	or     $0xffffff80,%edx
8010501e:	88 14 c5 c5 0a 1c 80 	mov    %dl,-0x7fe3f53b(,%eax,8)
80105025:	c1 e9 10             	shr    $0x10,%ecx
80105028:	66 89 0c c5 c6 0a 1c 	mov    %cx,-0x7fe3f53a(,%eax,8)
8010502f:	80 
  for(i = 0; i < 256; i++)
80105030:	83 c0 01             	add    $0x1,%eax
80105033:	3d ff 00 00 00       	cmp    $0xff,%eax
80105038:	7e af                	jle    80104fe9 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010503a:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80105040:	66 89 15 c0 0c 1c 80 	mov    %dx,0x801c0cc0
80105047:	66 c7 05 c2 0c 1c 80 	movw   $0x8,0x801c0cc2
8010504e:	08 00 
80105050:	c6 05 c4 0c 1c 80 00 	movb   $0x0,0x801c0cc4
80105057:	0f b6 05 c5 0c 1c 80 	movzbl 0x801c0cc5,%eax
8010505e:	83 c8 0f             	or     $0xf,%eax
80105061:	83 e0 ef             	and    $0xffffffef,%eax
80105064:	83 c8 e0             	or     $0xffffffe0,%eax
80105067:	a2 c5 0c 1c 80       	mov    %al,0x801c0cc5
8010506c:	c1 ea 10             	shr    $0x10,%edx
8010506f:	66 89 15 c6 0c 1c 80 	mov    %dx,0x801c0cc6

  initlock(&tickslock, "time");
80105076:	83 ec 08             	sub    $0x8,%esp
80105079:	68 bd 6e 10 80       	push   $0x80106ebd
8010507e:	68 80 0a 1c 80       	push   $0x801c0a80
80105083:	e8 44 ec ff ff       	call   80103ccc <initlock>
}
80105088:	83 c4 10             	add    $0x10,%esp
8010508b:	c9                   	leave  
8010508c:	c3                   	ret    

8010508d <idtinit>:

void
idtinit(void)
{
8010508d:	55                   	push   %ebp
8010508e:	89 e5                	mov    %esp,%ebp
80105090:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105093:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105099:	b8 c0 0a 1c 80       	mov    $0x801c0ac0,%eax
8010509e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801050a2:	c1 e8 10             	shr    $0x10,%eax
801050a5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801050a9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801050ac:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801050af:	c9                   	leave  
801050b0:	c3                   	ret    

801050b1 <trap>:

void
trap(struct trapframe *tf)
{
801050b1:	55                   	push   %ebp
801050b2:	89 e5                	mov    %esp,%ebp
801050b4:	57                   	push   %edi
801050b5:	56                   	push   %esi
801050b6:	53                   	push   %ebx
801050b7:	83 ec 1c             	sub    $0x1c,%esp
801050ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801050bd:	8b 43 30             	mov    0x30(%ebx),%eax
801050c0:	83 f8 40             	cmp    $0x40,%eax
801050c3:	74 13                	je     801050d8 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801050c5:	83 e8 20             	sub    $0x20,%eax
801050c8:	83 f8 1f             	cmp    $0x1f,%eax
801050cb:	0f 87 3a 01 00 00    	ja     8010520b <trap+0x15a>
801050d1:	ff 24 85 64 6f 10 80 	jmp    *-0x7fef909c(,%eax,4)
    if(myproc()->killed)
801050d8:	e8 1b e3 ff ff       	call   801033f8 <myproc>
801050dd:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050e1:	75 1f                	jne    80105102 <trap+0x51>
    myproc()->tf = tf;
801050e3:	e8 10 e3 ff ff       	call   801033f8 <myproc>
801050e8:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801050eb:	e8 d2 f0 ff ff       	call   801041c2 <syscall>
    if(myproc()->killed)
801050f0:	e8 03 e3 ff ff       	call   801033f8 <myproc>
801050f5:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050f9:	74 7e                	je     80105179 <trap+0xc8>
      exit();
801050fb:	e8 ae e6 ff ff       	call   801037ae <exit>
80105100:	eb 77                	jmp    80105179 <trap+0xc8>
      exit();
80105102:	e8 a7 e6 ff ff       	call   801037ae <exit>
80105107:	eb da                	jmp    801050e3 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105109:	e8 cf e2 ff ff       	call   801033dd <cpuid>
8010510e:	85 c0                	test   %eax,%eax
80105110:	74 6f                	je     80105181 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105112:	e8 54 d4 ff ff       	call   8010256b <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105117:	e8 dc e2 ff ff       	call   801033f8 <myproc>
8010511c:	85 c0                	test   %eax,%eax
8010511e:	74 1c                	je     8010513c <trap+0x8b>
80105120:	e8 d3 e2 ff ff       	call   801033f8 <myproc>
80105125:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105129:	74 11                	je     8010513c <trap+0x8b>
8010512b:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010512f:	83 e0 03             	and    $0x3,%eax
80105132:	66 83 f8 03          	cmp    $0x3,%ax
80105136:	0f 84 62 01 00 00    	je     8010529e <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010513c:	e8 b7 e2 ff ff       	call   801033f8 <myproc>
80105141:	85 c0                	test   %eax,%eax
80105143:	74 0f                	je     80105154 <trap+0xa3>
80105145:	e8 ae e2 ff ff       	call   801033f8 <myproc>
8010514a:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010514e:	0f 84 54 01 00 00    	je     801052a8 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105154:	e8 9f e2 ff ff       	call   801033f8 <myproc>
80105159:	85 c0                	test   %eax,%eax
8010515b:	74 1c                	je     80105179 <trap+0xc8>
8010515d:	e8 96 e2 ff ff       	call   801033f8 <myproc>
80105162:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105166:	74 11                	je     80105179 <trap+0xc8>
80105168:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010516c:	83 e0 03             	and    $0x3,%eax
8010516f:	66 83 f8 03          	cmp    $0x3,%ax
80105173:	0f 84 43 01 00 00    	je     801052bc <trap+0x20b>
    exit();
}
80105179:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010517c:	5b                   	pop    %ebx
8010517d:	5e                   	pop    %esi
8010517e:	5f                   	pop    %edi
8010517f:	5d                   	pop    %ebp
80105180:	c3                   	ret    
      acquire(&tickslock);
80105181:	83 ec 0c             	sub    $0xc,%esp
80105184:	68 80 0a 1c 80       	push   $0x801c0a80
80105189:	e8 7a ec ff ff       	call   80103e08 <acquire>
      ticks++;
8010518e:	83 05 c0 12 1c 80 01 	addl   $0x1,0x801c12c0
      wakeup(&ticks);
80105195:	c7 04 24 c0 12 1c 80 	movl   $0x801c12c0,(%esp)
8010519c:	e8 6a e8 ff ff       	call   80103a0b <wakeup>
      release(&tickslock);
801051a1:	c7 04 24 80 0a 1c 80 	movl   $0x801c0a80,(%esp)
801051a8:	e8 c0 ec ff ff       	call   80103e6d <release>
801051ad:	83 c4 10             	add    $0x10,%esp
801051b0:	e9 5d ff ff ff       	jmp    80105112 <trap+0x61>
    ideintr();
801051b5:	e8 b9 cb ff ff       	call   80101d73 <ideintr>
    lapiceoi();
801051ba:	e8 ac d3 ff ff       	call   8010256b <lapiceoi>
    break;
801051bf:	e9 53 ff ff ff       	jmp    80105117 <trap+0x66>
    kbdintr();
801051c4:	e8 e6 d1 ff ff       	call   801023af <kbdintr>
    lapiceoi();
801051c9:	e8 9d d3 ff ff       	call   8010256b <lapiceoi>
    break;
801051ce:	e9 44 ff ff ff       	jmp    80105117 <trap+0x66>
    uartintr();
801051d3:	e8 05 02 00 00       	call   801053dd <uartintr>
    lapiceoi();
801051d8:	e8 8e d3 ff ff       	call   8010256b <lapiceoi>
    break;
801051dd:	e9 35 ff ff ff       	jmp    80105117 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051e2:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801051e5:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051e9:	e8 ef e1 ff ff       	call   801033dd <cpuid>
801051ee:	57                   	push   %edi
801051ef:	0f b7 f6             	movzwl %si,%esi
801051f2:	56                   	push   %esi
801051f3:	50                   	push   %eax
801051f4:	68 c8 6e 10 80       	push   $0x80106ec8
801051f9:	e8 0d b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
801051fe:	e8 68 d3 ff ff       	call   8010256b <lapiceoi>
    break;
80105203:	83 c4 10             	add    $0x10,%esp
80105206:	e9 0c ff ff ff       	jmp    80105117 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010520b:	e8 e8 e1 ff ff       	call   801033f8 <myproc>
80105210:	85 c0                	test   %eax,%eax
80105212:	74 5f                	je     80105273 <trap+0x1c2>
80105214:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105218:	74 59                	je     80105273 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010521a:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010521d:	8b 43 38             	mov    0x38(%ebx),%eax
80105220:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105223:	e8 b5 e1 ff ff       	call   801033dd <cpuid>
80105228:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010522b:	8b 53 34             	mov    0x34(%ebx),%edx
8010522e:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105231:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105234:	e8 bf e1 ff ff       	call   801033f8 <myproc>
80105239:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010523c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010523f:	e8 b4 e1 ff ff       	call   801033f8 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105244:	57                   	push   %edi
80105245:	ff 75 e4             	pushl  -0x1c(%ebp)
80105248:	ff 75 e0             	pushl  -0x20(%ebp)
8010524b:	ff 75 dc             	pushl  -0x24(%ebp)
8010524e:	56                   	push   %esi
8010524f:	ff 75 d8             	pushl  -0x28(%ebp)
80105252:	ff 70 10             	pushl  0x10(%eax)
80105255:	68 20 6f 10 80       	push   $0x80106f20
8010525a:	e8 ac b3 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
8010525f:	83 c4 20             	add    $0x20,%esp
80105262:	e8 91 e1 ff ff       	call   801033f8 <myproc>
80105267:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010526e:	e9 a4 fe ff ff       	jmp    80105117 <trap+0x66>
80105273:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105276:	8b 73 38             	mov    0x38(%ebx),%esi
80105279:	e8 5f e1 ff ff       	call   801033dd <cpuid>
8010527e:	83 ec 0c             	sub    $0xc,%esp
80105281:	57                   	push   %edi
80105282:	56                   	push   %esi
80105283:	50                   	push   %eax
80105284:	ff 73 30             	pushl  0x30(%ebx)
80105287:	68 ec 6e 10 80       	push   $0x80106eec
8010528c:	e8 7a b3 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105291:	83 c4 14             	add    $0x14,%esp
80105294:	68 c2 6e 10 80       	push   $0x80106ec2
80105299:	e8 aa b0 ff ff       	call   80100348 <panic>
    exit();
8010529e:	e8 0b e5 ff ff       	call   801037ae <exit>
801052a3:	e9 94 fe ff ff       	jmp    8010513c <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801052a8:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801052ac:	0f 85 a2 fe ff ff    	jne    80105154 <trap+0xa3>
    yield();
801052b2:	e8 bd e5 ff ff       	call   80103874 <yield>
801052b7:	e9 98 fe ff ff       	jmp    80105154 <trap+0xa3>
    exit();
801052bc:	e8 ed e4 ff ff       	call   801037ae <exit>
801052c1:	e9 b3 fe ff ff       	jmp    80105179 <trap+0xc8>

801052c6 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801052c6:	55                   	push   %ebp
801052c7:	89 e5                	mov    %esp,%ebp
  if(!uart)
801052c9:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801052d0:	74 15                	je     801052e7 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052d2:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052d7:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801052d8:	a8 01                	test   $0x1,%al
801052da:	74 12                	je     801052ee <uartgetc+0x28>
801052dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052e1:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801052e2:	0f b6 c0             	movzbl %al,%eax
}
801052e5:	5d                   	pop    %ebp
801052e6:	c3                   	ret    
    return -1;
801052e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ec:	eb f7                	jmp    801052e5 <uartgetc+0x1f>
    return -1;
801052ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f3:	eb f0                	jmp    801052e5 <uartgetc+0x1f>

801052f5 <uartputc>:
  if(!uart)
801052f5:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801052fc:	74 3b                	je     80105339 <uartputc+0x44>
{
801052fe:	55                   	push   %ebp
801052ff:	89 e5                	mov    %esp,%ebp
80105301:	53                   	push   %ebx
80105302:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010530a:	eb 10                	jmp    8010531c <uartputc+0x27>
    microdelay(10);
8010530c:	83 ec 0c             	sub    $0xc,%esp
8010530f:	6a 0a                	push   $0xa
80105311:	e8 74 d2 ff ff       	call   8010258a <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105316:	83 c3 01             	add    $0x1,%ebx
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	83 fb 7f             	cmp    $0x7f,%ebx
8010531f:	7f 0a                	jg     8010532b <uartputc+0x36>
80105321:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105326:	ec                   	in     (%dx),%al
80105327:	a8 20                	test   $0x20,%al
80105329:	74 e1                	je     8010530c <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010532b:	8b 45 08             	mov    0x8(%ebp),%eax
8010532e:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105333:	ee                   	out    %al,(%dx)
}
80105334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105337:	c9                   	leave  
80105338:	c3                   	ret    
80105339:	f3 c3                	repz ret 

8010533b <uartinit>:
{
8010533b:	55                   	push   %ebp
8010533c:	89 e5                	mov    %esp,%ebp
8010533e:	56                   	push   %esi
8010533f:	53                   	push   %ebx
80105340:	b9 00 00 00 00       	mov    $0x0,%ecx
80105345:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010534a:	89 c8                	mov    %ecx,%eax
8010534c:	ee                   	out    %al,(%dx)
8010534d:	be fb 03 00 00       	mov    $0x3fb,%esi
80105352:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105357:	89 f2                	mov    %esi,%edx
80105359:	ee                   	out    %al,(%dx)
8010535a:	b8 0c 00 00 00       	mov    $0xc,%eax
8010535f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105364:	ee                   	out    %al,(%dx)
80105365:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010536a:	89 c8                	mov    %ecx,%eax
8010536c:	89 da                	mov    %ebx,%edx
8010536e:	ee                   	out    %al,(%dx)
8010536f:	b8 03 00 00 00       	mov    $0x3,%eax
80105374:	89 f2                	mov    %esi,%edx
80105376:	ee                   	out    %al,(%dx)
80105377:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010537c:	89 c8                	mov    %ecx,%eax
8010537e:	ee                   	out    %al,(%dx)
8010537f:	b8 01 00 00 00       	mov    $0x1,%eax
80105384:	89 da                	mov    %ebx,%edx
80105386:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105387:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010538c:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010538d:	3c ff                	cmp    $0xff,%al
8010538f:	74 45                	je     801053d6 <uartinit+0x9b>
  uart = 1;
80105391:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105398:	00 00 00 
8010539b:	ba fa 03 00 00       	mov    $0x3fa,%edx
801053a0:	ec                   	in     (%dx),%al
801053a1:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053a6:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801053a7:	83 ec 08             	sub    $0x8,%esp
801053aa:	6a 00                	push   $0x0
801053ac:	6a 04                	push   $0x4
801053ae:	e8 cb cb ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801053b3:	83 c4 10             	add    $0x10,%esp
801053b6:	bb e4 6f 10 80       	mov    $0x80106fe4,%ebx
801053bb:	eb 12                	jmp    801053cf <uartinit+0x94>
    uartputc(*p);
801053bd:	83 ec 0c             	sub    $0xc,%esp
801053c0:	0f be c0             	movsbl %al,%eax
801053c3:	50                   	push   %eax
801053c4:	e8 2c ff ff ff       	call   801052f5 <uartputc>
  for(p="xv6...\n"; *p; p++)
801053c9:	83 c3 01             	add    $0x1,%ebx
801053cc:	83 c4 10             	add    $0x10,%esp
801053cf:	0f b6 03             	movzbl (%ebx),%eax
801053d2:	84 c0                	test   %al,%al
801053d4:	75 e7                	jne    801053bd <uartinit+0x82>
}
801053d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801053d9:	5b                   	pop    %ebx
801053da:	5e                   	pop    %esi
801053db:	5d                   	pop    %ebp
801053dc:	c3                   	ret    

801053dd <uartintr>:

void
uartintr(void)
{
801053dd:	55                   	push   %ebp
801053de:	89 e5                	mov    %esp,%ebp
801053e0:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801053e3:	68 c6 52 10 80       	push   $0x801052c6
801053e8:	e8 51 b3 ff ff       	call   8010073e <consoleintr>
}
801053ed:	83 c4 10             	add    $0x10,%esp
801053f0:	c9                   	leave  
801053f1:	c3                   	ret    

801053f2 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801053f2:	6a 00                	push   $0x0
  pushl $0
801053f4:	6a 00                	push   $0x0
  jmp alltraps
801053f6:	e9 be fb ff ff       	jmp    80104fb9 <alltraps>

801053fb <vector1>:
.globl vector1
vector1:
  pushl $0
801053fb:	6a 00                	push   $0x0
  pushl $1
801053fd:	6a 01                	push   $0x1
  jmp alltraps
801053ff:	e9 b5 fb ff ff       	jmp    80104fb9 <alltraps>

80105404 <vector2>:
.globl vector2
vector2:
  pushl $0
80105404:	6a 00                	push   $0x0
  pushl $2
80105406:	6a 02                	push   $0x2
  jmp alltraps
80105408:	e9 ac fb ff ff       	jmp    80104fb9 <alltraps>

8010540d <vector3>:
.globl vector3
vector3:
  pushl $0
8010540d:	6a 00                	push   $0x0
  pushl $3
8010540f:	6a 03                	push   $0x3
  jmp alltraps
80105411:	e9 a3 fb ff ff       	jmp    80104fb9 <alltraps>

80105416 <vector4>:
.globl vector4
vector4:
  pushl $0
80105416:	6a 00                	push   $0x0
  pushl $4
80105418:	6a 04                	push   $0x4
  jmp alltraps
8010541a:	e9 9a fb ff ff       	jmp    80104fb9 <alltraps>

8010541f <vector5>:
.globl vector5
vector5:
  pushl $0
8010541f:	6a 00                	push   $0x0
  pushl $5
80105421:	6a 05                	push   $0x5
  jmp alltraps
80105423:	e9 91 fb ff ff       	jmp    80104fb9 <alltraps>

80105428 <vector6>:
.globl vector6
vector6:
  pushl $0
80105428:	6a 00                	push   $0x0
  pushl $6
8010542a:	6a 06                	push   $0x6
  jmp alltraps
8010542c:	e9 88 fb ff ff       	jmp    80104fb9 <alltraps>

80105431 <vector7>:
.globl vector7
vector7:
  pushl $0
80105431:	6a 00                	push   $0x0
  pushl $7
80105433:	6a 07                	push   $0x7
  jmp alltraps
80105435:	e9 7f fb ff ff       	jmp    80104fb9 <alltraps>

8010543a <vector8>:
.globl vector8
vector8:
  pushl $8
8010543a:	6a 08                	push   $0x8
  jmp alltraps
8010543c:	e9 78 fb ff ff       	jmp    80104fb9 <alltraps>

80105441 <vector9>:
.globl vector9
vector9:
  pushl $0
80105441:	6a 00                	push   $0x0
  pushl $9
80105443:	6a 09                	push   $0x9
  jmp alltraps
80105445:	e9 6f fb ff ff       	jmp    80104fb9 <alltraps>

8010544a <vector10>:
.globl vector10
vector10:
  pushl $10
8010544a:	6a 0a                	push   $0xa
  jmp alltraps
8010544c:	e9 68 fb ff ff       	jmp    80104fb9 <alltraps>

80105451 <vector11>:
.globl vector11
vector11:
  pushl $11
80105451:	6a 0b                	push   $0xb
  jmp alltraps
80105453:	e9 61 fb ff ff       	jmp    80104fb9 <alltraps>

80105458 <vector12>:
.globl vector12
vector12:
  pushl $12
80105458:	6a 0c                	push   $0xc
  jmp alltraps
8010545a:	e9 5a fb ff ff       	jmp    80104fb9 <alltraps>

8010545f <vector13>:
.globl vector13
vector13:
  pushl $13
8010545f:	6a 0d                	push   $0xd
  jmp alltraps
80105461:	e9 53 fb ff ff       	jmp    80104fb9 <alltraps>

80105466 <vector14>:
.globl vector14
vector14:
  pushl $14
80105466:	6a 0e                	push   $0xe
  jmp alltraps
80105468:	e9 4c fb ff ff       	jmp    80104fb9 <alltraps>

8010546d <vector15>:
.globl vector15
vector15:
  pushl $0
8010546d:	6a 00                	push   $0x0
  pushl $15
8010546f:	6a 0f                	push   $0xf
  jmp alltraps
80105471:	e9 43 fb ff ff       	jmp    80104fb9 <alltraps>

80105476 <vector16>:
.globl vector16
vector16:
  pushl $0
80105476:	6a 00                	push   $0x0
  pushl $16
80105478:	6a 10                	push   $0x10
  jmp alltraps
8010547a:	e9 3a fb ff ff       	jmp    80104fb9 <alltraps>

8010547f <vector17>:
.globl vector17
vector17:
  pushl $17
8010547f:	6a 11                	push   $0x11
  jmp alltraps
80105481:	e9 33 fb ff ff       	jmp    80104fb9 <alltraps>

80105486 <vector18>:
.globl vector18
vector18:
  pushl $0
80105486:	6a 00                	push   $0x0
  pushl $18
80105488:	6a 12                	push   $0x12
  jmp alltraps
8010548a:	e9 2a fb ff ff       	jmp    80104fb9 <alltraps>

8010548f <vector19>:
.globl vector19
vector19:
  pushl $0
8010548f:	6a 00                	push   $0x0
  pushl $19
80105491:	6a 13                	push   $0x13
  jmp alltraps
80105493:	e9 21 fb ff ff       	jmp    80104fb9 <alltraps>

80105498 <vector20>:
.globl vector20
vector20:
  pushl $0
80105498:	6a 00                	push   $0x0
  pushl $20
8010549a:	6a 14                	push   $0x14
  jmp alltraps
8010549c:	e9 18 fb ff ff       	jmp    80104fb9 <alltraps>

801054a1 <vector21>:
.globl vector21
vector21:
  pushl $0
801054a1:	6a 00                	push   $0x0
  pushl $21
801054a3:	6a 15                	push   $0x15
  jmp alltraps
801054a5:	e9 0f fb ff ff       	jmp    80104fb9 <alltraps>

801054aa <vector22>:
.globl vector22
vector22:
  pushl $0
801054aa:	6a 00                	push   $0x0
  pushl $22
801054ac:	6a 16                	push   $0x16
  jmp alltraps
801054ae:	e9 06 fb ff ff       	jmp    80104fb9 <alltraps>

801054b3 <vector23>:
.globl vector23
vector23:
  pushl $0
801054b3:	6a 00                	push   $0x0
  pushl $23
801054b5:	6a 17                	push   $0x17
  jmp alltraps
801054b7:	e9 fd fa ff ff       	jmp    80104fb9 <alltraps>

801054bc <vector24>:
.globl vector24
vector24:
  pushl $0
801054bc:	6a 00                	push   $0x0
  pushl $24
801054be:	6a 18                	push   $0x18
  jmp alltraps
801054c0:	e9 f4 fa ff ff       	jmp    80104fb9 <alltraps>

801054c5 <vector25>:
.globl vector25
vector25:
  pushl $0
801054c5:	6a 00                	push   $0x0
  pushl $25
801054c7:	6a 19                	push   $0x19
  jmp alltraps
801054c9:	e9 eb fa ff ff       	jmp    80104fb9 <alltraps>

801054ce <vector26>:
.globl vector26
vector26:
  pushl $0
801054ce:	6a 00                	push   $0x0
  pushl $26
801054d0:	6a 1a                	push   $0x1a
  jmp alltraps
801054d2:	e9 e2 fa ff ff       	jmp    80104fb9 <alltraps>

801054d7 <vector27>:
.globl vector27
vector27:
  pushl $0
801054d7:	6a 00                	push   $0x0
  pushl $27
801054d9:	6a 1b                	push   $0x1b
  jmp alltraps
801054db:	e9 d9 fa ff ff       	jmp    80104fb9 <alltraps>

801054e0 <vector28>:
.globl vector28
vector28:
  pushl $0
801054e0:	6a 00                	push   $0x0
  pushl $28
801054e2:	6a 1c                	push   $0x1c
  jmp alltraps
801054e4:	e9 d0 fa ff ff       	jmp    80104fb9 <alltraps>

801054e9 <vector29>:
.globl vector29
vector29:
  pushl $0
801054e9:	6a 00                	push   $0x0
  pushl $29
801054eb:	6a 1d                	push   $0x1d
  jmp alltraps
801054ed:	e9 c7 fa ff ff       	jmp    80104fb9 <alltraps>

801054f2 <vector30>:
.globl vector30
vector30:
  pushl $0
801054f2:	6a 00                	push   $0x0
  pushl $30
801054f4:	6a 1e                	push   $0x1e
  jmp alltraps
801054f6:	e9 be fa ff ff       	jmp    80104fb9 <alltraps>

801054fb <vector31>:
.globl vector31
vector31:
  pushl $0
801054fb:	6a 00                	push   $0x0
  pushl $31
801054fd:	6a 1f                	push   $0x1f
  jmp alltraps
801054ff:	e9 b5 fa ff ff       	jmp    80104fb9 <alltraps>

80105504 <vector32>:
.globl vector32
vector32:
  pushl $0
80105504:	6a 00                	push   $0x0
  pushl $32
80105506:	6a 20                	push   $0x20
  jmp alltraps
80105508:	e9 ac fa ff ff       	jmp    80104fb9 <alltraps>

8010550d <vector33>:
.globl vector33
vector33:
  pushl $0
8010550d:	6a 00                	push   $0x0
  pushl $33
8010550f:	6a 21                	push   $0x21
  jmp alltraps
80105511:	e9 a3 fa ff ff       	jmp    80104fb9 <alltraps>

80105516 <vector34>:
.globl vector34
vector34:
  pushl $0
80105516:	6a 00                	push   $0x0
  pushl $34
80105518:	6a 22                	push   $0x22
  jmp alltraps
8010551a:	e9 9a fa ff ff       	jmp    80104fb9 <alltraps>

8010551f <vector35>:
.globl vector35
vector35:
  pushl $0
8010551f:	6a 00                	push   $0x0
  pushl $35
80105521:	6a 23                	push   $0x23
  jmp alltraps
80105523:	e9 91 fa ff ff       	jmp    80104fb9 <alltraps>

80105528 <vector36>:
.globl vector36
vector36:
  pushl $0
80105528:	6a 00                	push   $0x0
  pushl $36
8010552a:	6a 24                	push   $0x24
  jmp alltraps
8010552c:	e9 88 fa ff ff       	jmp    80104fb9 <alltraps>

80105531 <vector37>:
.globl vector37
vector37:
  pushl $0
80105531:	6a 00                	push   $0x0
  pushl $37
80105533:	6a 25                	push   $0x25
  jmp alltraps
80105535:	e9 7f fa ff ff       	jmp    80104fb9 <alltraps>

8010553a <vector38>:
.globl vector38
vector38:
  pushl $0
8010553a:	6a 00                	push   $0x0
  pushl $38
8010553c:	6a 26                	push   $0x26
  jmp alltraps
8010553e:	e9 76 fa ff ff       	jmp    80104fb9 <alltraps>

80105543 <vector39>:
.globl vector39
vector39:
  pushl $0
80105543:	6a 00                	push   $0x0
  pushl $39
80105545:	6a 27                	push   $0x27
  jmp alltraps
80105547:	e9 6d fa ff ff       	jmp    80104fb9 <alltraps>

8010554c <vector40>:
.globl vector40
vector40:
  pushl $0
8010554c:	6a 00                	push   $0x0
  pushl $40
8010554e:	6a 28                	push   $0x28
  jmp alltraps
80105550:	e9 64 fa ff ff       	jmp    80104fb9 <alltraps>

80105555 <vector41>:
.globl vector41
vector41:
  pushl $0
80105555:	6a 00                	push   $0x0
  pushl $41
80105557:	6a 29                	push   $0x29
  jmp alltraps
80105559:	e9 5b fa ff ff       	jmp    80104fb9 <alltraps>

8010555e <vector42>:
.globl vector42
vector42:
  pushl $0
8010555e:	6a 00                	push   $0x0
  pushl $42
80105560:	6a 2a                	push   $0x2a
  jmp alltraps
80105562:	e9 52 fa ff ff       	jmp    80104fb9 <alltraps>

80105567 <vector43>:
.globl vector43
vector43:
  pushl $0
80105567:	6a 00                	push   $0x0
  pushl $43
80105569:	6a 2b                	push   $0x2b
  jmp alltraps
8010556b:	e9 49 fa ff ff       	jmp    80104fb9 <alltraps>

80105570 <vector44>:
.globl vector44
vector44:
  pushl $0
80105570:	6a 00                	push   $0x0
  pushl $44
80105572:	6a 2c                	push   $0x2c
  jmp alltraps
80105574:	e9 40 fa ff ff       	jmp    80104fb9 <alltraps>

80105579 <vector45>:
.globl vector45
vector45:
  pushl $0
80105579:	6a 00                	push   $0x0
  pushl $45
8010557b:	6a 2d                	push   $0x2d
  jmp alltraps
8010557d:	e9 37 fa ff ff       	jmp    80104fb9 <alltraps>

80105582 <vector46>:
.globl vector46
vector46:
  pushl $0
80105582:	6a 00                	push   $0x0
  pushl $46
80105584:	6a 2e                	push   $0x2e
  jmp alltraps
80105586:	e9 2e fa ff ff       	jmp    80104fb9 <alltraps>

8010558b <vector47>:
.globl vector47
vector47:
  pushl $0
8010558b:	6a 00                	push   $0x0
  pushl $47
8010558d:	6a 2f                	push   $0x2f
  jmp alltraps
8010558f:	e9 25 fa ff ff       	jmp    80104fb9 <alltraps>

80105594 <vector48>:
.globl vector48
vector48:
  pushl $0
80105594:	6a 00                	push   $0x0
  pushl $48
80105596:	6a 30                	push   $0x30
  jmp alltraps
80105598:	e9 1c fa ff ff       	jmp    80104fb9 <alltraps>

8010559d <vector49>:
.globl vector49
vector49:
  pushl $0
8010559d:	6a 00                	push   $0x0
  pushl $49
8010559f:	6a 31                	push   $0x31
  jmp alltraps
801055a1:	e9 13 fa ff ff       	jmp    80104fb9 <alltraps>

801055a6 <vector50>:
.globl vector50
vector50:
  pushl $0
801055a6:	6a 00                	push   $0x0
  pushl $50
801055a8:	6a 32                	push   $0x32
  jmp alltraps
801055aa:	e9 0a fa ff ff       	jmp    80104fb9 <alltraps>

801055af <vector51>:
.globl vector51
vector51:
  pushl $0
801055af:	6a 00                	push   $0x0
  pushl $51
801055b1:	6a 33                	push   $0x33
  jmp alltraps
801055b3:	e9 01 fa ff ff       	jmp    80104fb9 <alltraps>

801055b8 <vector52>:
.globl vector52
vector52:
  pushl $0
801055b8:	6a 00                	push   $0x0
  pushl $52
801055ba:	6a 34                	push   $0x34
  jmp alltraps
801055bc:	e9 f8 f9 ff ff       	jmp    80104fb9 <alltraps>

801055c1 <vector53>:
.globl vector53
vector53:
  pushl $0
801055c1:	6a 00                	push   $0x0
  pushl $53
801055c3:	6a 35                	push   $0x35
  jmp alltraps
801055c5:	e9 ef f9 ff ff       	jmp    80104fb9 <alltraps>

801055ca <vector54>:
.globl vector54
vector54:
  pushl $0
801055ca:	6a 00                	push   $0x0
  pushl $54
801055cc:	6a 36                	push   $0x36
  jmp alltraps
801055ce:	e9 e6 f9 ff ff       	jmp    80104fb9 <alltraps>

801055d3 <vector55>:
.globl vector55
vector55:
  pushl $0
801055d3:	6a 00                	push   $0x0
  pushl $55
801055d5:	6a 37                	push   $0x37
  jmp alltraps
801055d7:	e9 dd f9 ff ff       	jmp    80104fb9 <alltraps>

801055dc <vector56>:
.globl vector56
vector56:
  pushl $0
801055dc:	6a 00                	push   $0x0
  pushl $56
801055de:	6a 38                	push   $0x38
  jmp alltraps
801055e0:	e9 d4 f9 ff ff       	jmp    80104fb9 <alltraps>

801055e5 <vector57>:
.globl vector57
vector57:
  pushl $0
801055e5:	6a 00                	push   $0x0
  pushl $57
801055e7:	6a 39                	push   $0x39
  jmp alltraps
801055e9:	e9 cb f9 ff ff       	jmp    80104fb9 <alltraps>

801055ee <vector58>:
.globl vector58
vector58:
  pushl $0
801055ee:	6a 00                	push   $0x0
  pushl $58
801055f0:	6a 3a                	push   $0x3a
  jmp alltraps
801055f2:	e9 c2 f9 ff ff       	jmp    80104fb9 <alltraps>

801055f7 <vector59>:
.globl vector59
vector59:
  pushl $0
801055f7:	6a 00                	push   $0x0
  pushl $59
801055f9:	6a 3b                	push   $0x3b
  jmp alltraps
801055fb:	e9 b9 f9 ff ff       	jmp    80104fb9 <alltraps>

80105600 <vector60>:
.globl vector60
vector60:
  pushl $0
80105600:	6a 00                	push   $0x0
  pushl $60
80105602:	6a 3c                	push   $0x3c
  jmp alltraps
80105604:	e9 b0 f9 ff ff       	jmp    80104fb9 <alltraps>

80105609 <vector61>:
.globl vector61
vector61:
  pushl $0
80105609:	6a 00                	push   $0x0
  pushl $61
8010560b:	6a 3d                	push   $0x3d
  jmp alltraps
8010560d:	e9 a7 f9 ff ff       	jmp    80104fb9 <alltraps>

80105612 <vector62>:
.globl vector62
vector62:
  pushl $0
80105612:	6a 00                	push   $0x0
  pushl $62
80105614:	6a 3e                	push   $0x3e
  jmp alltraps
80105616:	e9 9e f9 ff ff       	jmp    80104fb9 <alltraps>

8010561b <vector63>:
.globl vector63
vector63:
  pushl $0
8010561b:	6a 00                	push   $0x0
  pushl $63
8010561d:	6a 3f                	push   $0x3f
  jmp alltraps
8010561f:	e9 95 f9 ff ff       	jmp    80104fb9 <alltraps>

80105624 <vector64>:
.globl vector64
vector64:
  pushl $0
80105624:	6a 00                	push   $0x0
  pushl $64
80105626:	6a 40                	push   $0x40
  jmp alltraps
80105628:	e9 8c f9 ff ff       	jmp    80104fb9 <alltraps>

8010562d <vector65>:
.globl vector65
vector65:
  pushl $0
8010562d:	6a 00                	push   $0x0
  pushl $65
8010562f:	6a 41                	push   $0x41
  jmp alltraps
80105631:	e9 83 f9 ff ff       	jmp    80104fb9 <alltraps>

80105636 <vector66>:
.globl vector66
vector66:
  pushl $0
80105636:	6a 00                	push   $0x0
  pushl $66
80105638:	6a 42                	push   $0x42
  jmp alltraps
8010563a:	e9 7a f9 ff ff       	jmp    80104fb9 <alltraps>

8010563f <vector67>:
.globl vector67
vector67:
  pushl $0
8010563f:	6a 00                	push   $0x0
  pushl $67
80105641:	6a 43                	push   $0x43
  jmp alltraps
80105643:	e9 71 f9 ff ff       	jmp    80104fb9 <alltraps>

80105648 <vector68>:
.globl vector68
vector68:
  pushl $0
80105648:	6a 00                	push   $0x0
  pushl $68
8010564a:	6a 44                	push   $0x44
  jmp alltraps
8010564c:	e9 68 f9 ff ff       	jmp    80104fb9 <alltraps>

80105651 <vector69>:
.globl vector69
vector69:
  pushl $0
80105651:	6a 00                	push   $0x0
  pushl $69
80105653:	6a 45                	push   $0x45
  jmp alltraps
80105655:	e9 5f f9 ff ff       	jmp    80104fb9 <alltraps>

8010565a <vector70>:
.globl vector70
vector70:
  pushl $0
8010565a:	6a 00                	push   $0x0
  pushl $70
8010565c:	6a 46                	push   $0x46
  jmp alltraps
8010565e:	e9 56 f9 ff ff       	jmp    80104fb9 <alltraps>

80105663 <vector71>:
.globl vector71
vector71:
  pushl $0
80105663:	6a 00                	push   $0x0
  pushl $71
80105665:	6a 47                	push   $0x47
  jmp alltraps
80105667:	e9 4d f9 ff ff       	jmp    80104fb9 <alltraps>

8010566c <vector72>:
.globl vector72
vector72:
  pushl $0
8010566c:	6a 00                	push   $0x0
  pushl $72
8010566e:	6a 48                	push   $0x48
  jmp alltraps
80105670:	e9 44 f9 ff ff       	jmp    80104fb9 <alltraps>

80105675 <vector73>:
.globl vector73
vector73:
  pushl $0
80105675:	6a 00                	push   $0x0
  pushl $73
80105677:	6a 49                	push   $0x49
  jmp alltraps
80105679:	e9 3b f9 ff ff       	jmp    80104fb9 <alltraps>

8010567e <vector74>:
.globl vector74
vector74:
  pushl $0
8010567e:	6a 00                	push   $0x0
  pushl $74
80105680:	6a 4a                	push   $0x4a
  jmp alltraps
80105682:	e9 32 f9 ff ff       	jmp    80104fb9 <alltraps>

80105687 <vector75>:
.globl vector75
vector75:
  pushl $0
80105687:	6a 00                	push   $0x0
  pushl $75
80105689:	6a 4b                	push   $0x4b
  jmp alltraps
8010568b:	e9 29 f9 ff ff       	jmp    80104fb9 <alltraps>

80105690 <vector76>:
.globl vector76
vector76:
  pushl $0
80105690:	6a 00                	push   $0x0
  pushl $76
80105692:	6a 4c                	push   $0x4c
  jmp alltraps
80105694:	e9 20 f9 ff ff       	jmp    80104fb9 <alltraps>

80105699 <vector77>:
.globl vector77
vector77:
  pushl $0
80105699:	6a 00                	push   $0x0
  pushl $77
8010569b:	6a 4d                	push   $0x4d
  jmp alltraps
8010569d:	e9 17 f9 ff ff       	jmp    80104fb9 <alltraps>

801056a2 <vector78>:
.globl vector78
vector78:
  pushl $0
801056a2:	6a 00                	push   $0x0
  pushl $78
801056a4:	6a 4e                	push   $0x4e
  jmp alltraps
801056a6:	e9 0e f9 ff ff       	jmp    80104fb9 <alltraps>

801056ab <vector79>:
.globl vector79
vector79:
  pushl $0
801056ab:	6a 00                	push   $0x0
  pushl $79
801056ad:	6a 4f                	push   $0x4f
  jmp alltraps
801056af:	e9 05 f9 ff ff       	jmp    80104fb9 <alltraps>

801056b4 <vector80>:
.globl vector80
vector80:
  pushl $0
801056b4:	6a 00                	push   $0x0
  pushl $80
801056b6:	6a 50                	push   $0x50
  jmp alltraps
801056b8:	e9 fc f8 ff ff       	jmp    80104fb9 <alltraps>

801056bd <vector81>:
.globl vector81
vector81:
  pushl $0
801056bd:	6a 00                	push   $0x0
  pushl $81
801056bf:	6a 51                	push   $0x51
  jmp alltraps
801056c1:	e9 f3 f8 ff ff       	jmp    80104fb9 <alltraps>

801056c6 <vector82>:
.globl vector82
vector82:
  pushl $0
801056c6:	6a 00                	push   $0x0
  pushl $82
801056c8:	6a 52                	push   $0x52
  jmp alltraps
801056ca:	e9 ea f8 ff ff       	jmp    80104fb9 <alltraps>

801056cf <vector83>:
.globl vector83
vector83:
  pushl $0
801056cf:	6a 00                	push   $0x0
  pushl $83
801056d1:	6a 53                	push   $0x53
  jmp alltraps
801056d3:	e9 e1 f8 ff ff       	jmp    80104fb9 <alltraps>

801056d8 <vector84>:
.globl vector84
vector84:
  pushl $0
801056d8:	6a 00                	push   $0x0
  pushl $84
801056da:	6a 54                	push   $0x54
  jmp alltraps
801056dc:	e9 d8 f8 ff ff       	jmp    80104fb9 <alltraps>

801056e1 <vector85>:
.globl vector85
vector85:
  pushl $0
801056e1:	6a 00                	push   $0x0
  pushl $85
801056e3:	6a 55                	push   $0x55
  jmp alltraps
801056e5:	e9 cf f8 ff ff       	jmp    80104fb9 <alltraps>

801056ea <vector86>:
.globl vector86
vector86:
  pushl $0
801056ea:	6a 00                	push   $0x0
  pushl $86
801056ec:	6a 56                	push   $0x56
  jmp alltraps
801056ee:	e9 c6 f8 ff ff       	jmp    80104fb9 <alltraps>

801056f3 <vector87>:
.globl vector87
vector87:
  pushl $0
801056f3:	6a 00                	push   $0x0
  pushl $87
801056f5:	6a 57                	push   $0x57
  jmp alltraps
801056f7:	e9 bd f8 ff ff       	jmp    80104fb9 <alltraps>

801056fc <vector88>:
.globl vector88
vector88:
  pushl $0
801056fc:	6a 00                	push   $0x0
  pushl $88
801056fe:	6a 58                	push   $0x58
  jmp alltraps
80105700:	e9 b4 f8 ff ff       	jmp    80104fb9 <alltraps>

80105705 <vector89>:
.globl vector89
vector89:
  pushl $0
80105705:	6a 00                	push   $0x0
  pushl $89
80105707:	6a 59                	push   $0x59
  jmp alltraps
80105709:	e9 ab f8 ff ff       	jmp    80104fb9 <alltraps>

8010570e <vector90>:
.globl vector90
vector90:
  pushl $0
8010570e:	6a 00                	push   $0x0
  pushl $90
80105710:	6a 5a                	push   $0x5a
  jmp alltraps
80105712:	e9 a2 f8 ff ff       	jmp    80104fb9 <alltraps>

80105717 <vector91>:
.globl vector91
vector91:
  pushl $0
80105717:	6a 00                	push   $0x0
  pushl $91
80105719:	6a 5b                	push   $0x5b
  jmp alltraps
8010571b:	e9 99 f8 ff ff       	jmp    80104fb9 <alltraps>

80105720 <vector92>:
.globl vector92
vector92:
  pushl $0
80105720:	6a 00                	push   $0x0
  pushl $92
80105722:	6a 5c                	push   $0x5c
  jmp alltraps
80105724:	e9 90 f8 ff ff       	jmp    80104fb9 <alltraps>

80105729 <vector93>:
.globl vector93
vector93:
  pushl $0
80105729:	6a 00                	push   $0x0
  pushl $93
8010572b:	6a 5d                	push   $0x5d
  jmp alltraps
8010572d:	e9 87 f8 ff ff       	jmp    80104fb9 <alltraps>

80105732 <vector94>:
.globl vector94
vector94:
  pushl $0
80105732:	6a 00                	push   $0x0
  pushl $94
80105734:	6a 5e                	push   $0x5e
  jmp alltraps
80105736:	e9 7e f8 ff ff       	jmp    80104fb9 <alltraps>

8010573b <vector95>:
.globl vector95
vector95:
  pushl $0
8010573b:	6a 00                	push   $0x0
  pushl $95
8010573d:	6a 5f                	push   $0x5f
  jmp alltraps
8010573f:	e9 75 f8 ff ff       	jmp    80104fb9 <alltraps>

80105744 <vector96>:
.globl vector96
vector96:
  pushl $0
80105744:	6a 00                	push   $0x0
  pushl $96
80105746:	6a 60                	push   $0x60
  jmp alltraps
80105748:	e9 6c f8 ff ff       	jmp    80104fb9 <alltraps>

8010574d <vector97>:
.globl vector97
vector97:
  pushl $0
8010574d:	6a 00                	push   $0x0
  pushl $97
8010574f:	6a 61                	push   $0x61
  jmp alltraps
80105751:	e9 63 f8 ff ff       	jmp    80104fb9 <alltraps>

80105756 <vector98>:
.globl vector98
vector98:
  pushl $0
80105756:	6a 00                	push   $0x0
  pushl $98
80105758:	6a 62                	push   $0x62
  jmp alltraps
8010575a:	e9 5a f8 ff ff       	jmp    80104fb9 <alltraps>

8010575f <vector99>:
.globl vector99
vector99:
  pushl $0
8010575f:	6a 00                	push   $0x0
  pushl $99
80105761:	6a 63                	push   $0x63
  jmp alltraps
80105763:	e9 51 f8 ff ff       	jmp    80104fb9 <alltraps>

80105768 <vector100>:
.globl vector100
vector100:
  pushl $0
80105768:	6a 00                	push   $0x0
  pushl $100
8010576a:	6a 64                	push   $0x64
  jmp alltraps
8010576c:	e9 48 f8 ff ff       	jmp    80104fb9 <alltraps>

80105771 <vector101>:
.globl vector101
vector101:
  pushl $0
80105771:	6a 00                	push   $0x0
  pushl $101
80105773:	6a 65                	push   $0x65
  jmp alltraps
80105775:	e9 3f f8 ff ff       	jmp    80104fb9 <alltraps>

8010577a <vector102>:
.globl vector102
vector102:
  pushl $0
8010577a:	6a 00                	push   $0x0
  pushl $102
8010577c:	6a 66                	push   $0x66
  jmp alltraps
8010577e:	e9 36 f8 ff ff       	jmp    80104fb9 <alltraps>

80105783 <vector103>:
.globl vector103
vector103:
  pushl $0
80105783:	6a 00                	push   $0x0
  pushl $103
80105785:	6a 67                	push   $0x67
  jmp alltraps
80105787:	e9 2d f8 ff ff       	jmp    80104fb9 <alltraps>

8010578c <vector104>:
.globl vector104
vector104:
  pushl $0
8010578c:	6a 00                	push   $0x0
  pushl $104
8010578e:	6a 68                	push   $0x68
  jmp alltraps
80105790:	e9 24 f8 ff ff       	jmp    80104fb9 <alltraps>

80105795 <vector105>:
.globl vector105
vector105:
  pushl $0
80105795:	6a 00                	push   $0x0
  pushl $105
80105797:	6a 69                	push   $0x69
  jmp alltraps
80105799:	e9 1b f8 ff ff       	jmp    80104fb9 <alltraps>

8010579e <vector106>:
.globl vector106
vector106:
  pushl $0
8010579e:	6a 00                	push   $0x0
  pushl $106
801057a0:	6a 6a                	push   $0x6a
  jmp alltraps
801057a2:	e9 12 f8 ff ff       	jmp    80104fb9 <alltraps>

801057a7 <vector107>:
.globl vector107
vector107:
  pushl $0
801057a7:	6a 00                	push   $0x0
  pushl $107
801057a9:	6a 6b                	push   $0x6b
  jmp alltraps
801057ab:	e9 09 f8 ff ff       	jmp    80104fb9 <alltraps>

801057b0 <vector108>:
.globl vector108
vector108:
  pushl $0
801057b0:	6a 00                	push   $0x0
  pushl $108
801057b2:	6a 6c                	push   $0x6c
  jmp alltraps
801057b4:	e9 00 f8 ff ff       	jmp    80104fb9 <alltraps>

801057b9 <vector109>:
.globl vector109
vector109:
  pushl $0
801057b9:	6a 00                	push   $0x0
  pushl $109
801057bb:	6a 6d                	push   $0x6d
  jmp alltraps
801057bd:	e9 f7 f7 ff ff       	jmp    80104fb9 <alltraps>

801057c2 <vector110>:
.globl vector110
vector110:
  pushl $0
801057c2:	6a 00                	push   $0x0
  pushl $110
801057c4:	6a 6e                	push   $0x6e
  jmp alltraps
801057c6:	e9 ee f7 ff ff       	jmp    80104fb9 <alltraps>

801057cb <vector111>:
.globl vector111
vector111:
  pushl $0
801057cb:	6a 00                	push   $0x0
  pushl $111
801057cd:	6a 6f                	push   $0x6f
  jmp alltraps
801057cf:	e9 e5 f7 ff ff       	jmp    80104fb9 <alltraps>

801057d4 <vector112>:
.globl vector112
vector112:
  pushl $0
801057d4:	6a 00                	push   $0x0
  pushl $112
801057d6:	6a 70                	push   $0x70
  jmp alltraps
801057d8:	e9 dc f7 ff ff       	jmp    80104fb9 <alltraps>

801057dd <vector113>:
.globl vector113
vector113:
  pushl $0
801057dd:	6a 00                	push   $0x0
  pushl $113
801057df:	6a 71                	push   $0x71
  jmp alltraps
801057e1:	e9 d3 f7 ff ff       	jmp    80104fb9 <alltraps>

801057e6 <vector114>:
.globl vector114
vector114:
  pushl $0
801057e6:	6a 00                	push   $0x0
  pushl $114
801057e8:	6a 72                	push   $0x72
  jmp alltraps
801057ea:	e9 ca f7 ff ff       	jmp    80104fb9 <alltraps>

801057ef <vector115>:
.globl vector115
vector115:
  pushl $0
801057ef:	6a 00                	push   $0x0
  pushl $115
801057f1:	6a 73                	push   $0x73
  jmp alltraps
801057f3:	e9 c1 f7 ff ff       	jmp    80104fb9 <alltraps>

801057f8 <vector116>:
.globl vector116
vector116:
  pushl $0
801057f8:	6a 00                	push   $0x0
  pushl $116
801057fa:	6a 74                	push   $0x74
  jmp alltraps
801057fc:	e9 b8 f7 ff ff       	jmp    80104fb9 <alltraps>

80105801 <vector117>:
.globl vector117
vector117:
  pushl $0
80105801:	6a 00                	push   $0x0
  pushl $117
80105803:	6a 75                	push   $0x75
  jmp alltraps
80105805:	e9 af f7 ff ff       	jmp    80104fb9 <alltraps>

8010580a <vector118>:
.globl vector118
vector118:
  pushl $0
8010580a:	6a 00                	push   $0x0
  pushl $118
8010580c:	6a 76                	push   $0x76
  jmp alltraps
8010580e:	e9 a6 f7 ff ff       	jmp    80104fb9 <alltraps>

80105813 <vector119>:
.globl vector119
vector119:
  pushl $0
80105813:	6a 00                	push   $0x0
  pushl $119
80105815:	6a 77                	push   $0x77
  jmp alltraps
80105817:	e9 9d f7 ff ff       	jmp    80104fb9 <alltraps>

8010581c <vector120>:
.globl vector120
vector120:
  pushl $0
8010581c:	6a 00                	push   $0x0
  pushl $120
8010581e:	6a 78                	push   $0x78
  jmp alltraps
80105820:	e9 94 f7 ff ff       	jmp    80104fb9 <alltraps>

80105825 <vector121>:
.globl vector121
vector121:
  pushl $0
80105825:	6a 00                	push   $0x0
  pushl $121
80105827:	6a 79                	push   $0x79
  jmp alltraps
80105829:	e9 8b f7 ff ff       	jmp    80104fb9 <alltraps>

8010582e <vector122>:
.globl vector122
vector122:
  pushl $0
8010582e:	6a 00                	push   $0x0
  pushl $122
80105830:	6a 7a                	push   $0x7a
  jmp alltraps
80105832:	e9 82 f7 ff ff       	jmp    80104fb9 <alltraps>

80105837 <vector123>:
.globl vector123
vector123:
  pushl $0
80105837:	6a 00                	push   $0x0
  pushl $123
80105839:	6a 7b                	push   $0x7b
  jmp alltraps
8010583b:	e9 79 f7 ff ff       	jmp    80104fb9 <alltraps>

80105840 <vector124>:
.globl vector124
vector124:
  pushl $0
80105840:	6a 00                	push   $0x0
  pushl $124
80105842:	6a 7c                	push   $0x7c
  jmp alltraps
80105844:	e9 70 f7 ff ff       	jmp    80104fb9 <alltraps>

80105849 <vector125>:
.globl vector125
vector125:
  pushl $0
80105849:	6a 00                	push   $0x0
  pushl $125
8010584b:	6a 7d                	push   $0x7d
  jmp alltraps
8010584d:	e9 67 f7 ff ff       	jmp    80104fb9 <alltraps>

80105852 <vector126>:
.globl vector126
vector126:
  pushl $0
80105852:	6a 00                	push   $0x0
  pushl $126
80105854:	6a 7e                	push   $0x7e
  jmp alltraps
80105856:	e9 5e f7 ff ff       	jmp    80104fb9 <alltraps>

8010585b <vector127>:
.globl vector127
vector127:
  pushl $0
8010585b:	6a 00                	push   $0x0
  pushl $127
8010585d:	6a 7f                	push   $0x7f
  jmp alltraps
8010585f:	e9 55 f7 ff ff       	jmp    80104fb9 <alltraps>

80105864 <vector128>:
.globl vector128
vector128:
  pushl $0
80105864:	6a 00                	push   $0x0
  pushl $128
80105866:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010586b:	e9 49 f7 ff ff       	jmp    80104fb9 <alltraps>

80105870 <vector129>:
.globl vector129
vector129:
  pushl $0
80105870:	6a 00                	push   $0x0
  pushl $129
80105872:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105877:	e9 3d f7 ff ff       	jmp    80104fb9 <alltraps>

8010587c <vector130>:
.globl vector130
vector130:
  pushl $0
8010587c:	6a 00                	push   $0x0
  pushl $130
8010587e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105883:	e9 31 f7 ff ff       	jmp    80104fb9 <alltraps>

80105888 <vector131>:
.globl vector131
vector131:
  pushl $0
80105888:	6a 00                	push   $0x0
  pushl $131
8010588a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010588f:	e9 25 f7 ff ff       	jmp    80104fb9 <alltraps>

80105894 <vector132>:
.globl vector132
vector132:
  pushl $0
80105894:	6a 00                	push   $0x0
  pushl $132
80105896:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010589b:	e9 19 f7 ff ff       	jmp    80104fb9 <alltraps>

801058a0 <vector133>:
.globl vector133
vector133:
  pushl $0
801058a0:	6a 00                	push   $0x0
  pushl $133
801058a2:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801058a7:	e9 0d f7 ff ff       	jmp    80104fb9 <alltraps>

801058ac <vector134>:
.globl vector134
vector134:
  pushl $0
801058ac:	6a 00                	push   $0x0
  pushl $134
801058ae:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801058b3:	e9 01 f7 ff ff       	jmp    80104fb9 <alltraps>

801058b8 <vector135>:
.globl vector135
vector135:
  pushl $0
801058b8:	6a 00                	push   $0x0
  pushl $135
801058ba:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801058bf:	e9 f5 f6 ff ff       	jmp    80104fb9 <alltraps>

801058c4 <vector136>:
.globl vector136
vector136:
  pushl $0
801058c4:	6a 00                	push   $0x0
  pushl $136
801058c6:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801058cb:	e9 e9 f6 ff ff       	jmp    80104fb9 <alltraps>

801058d0 <vector137>:
.globl vector137
vector137:
  pushl $0
801058d0:	6a 00                	push   $0x0
  pushl $137
801058d2:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801058d7:	e9 dd f6 ff ff       	jmp    80104fb9 <alltraps>

801058dc <vector138>:
.globl vector138
vector138:
  pushl $0
801058dc:	6a 00                	push   $0x0
  pushl $138
801058de:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801058e3:	e9 d1 f6 ff ff       	jmp    80104fb9 <alltraps>

801058e8 <vector139>:
.globl vector139
vector139:
  pushl $0
801058e8:	6a 00                	push   $0x0
  pushl $139
801058ea:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801058ef:	e9 c5 f6 ff ff       	jmp    80104fb9 <alltraps>

801058f4 <vector140>:
.globl vector140
vector140:
  pushl $0
801058f4:	6a 00                	push   $0x0
  pushl $140
801058f6:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801058fb:	e9 b9 f6 ff ff       	jmp    80104fb9 <alltraps>

80105900 <vector141>:
.globl vector141
vector141:
  pushl $0
80105900:	6a 00                	push   $0x0
  pushl $141
80105902:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105907:	e9 ad f6 ff ff       	jmp    80104fb9 <alltraps>

8010590c <vector142>:
.globl vector142
vector142:
  pushl $0
8010590c:	6a 00                	push   $0x0
  pushl $142
8010590e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105913:	e9 a1 f6 ff ff       	jmp    80104fb9 <alltraps>

80105918 <vector143>:
.globl vector143
vector143:
  pushl $0
80105918:	6a 00                	push   $0x0
  pushl $143
8010591a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010591f:	e9 95 f6 ff ff       	jmp    80104fb9 <alltraps>

80105924 <vector144>:
.globl vector144
vector144:
  pushl $0
80105924:	6a 00                	push   $0x0
  pushl $144
80105926:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010592b:	e9 89 f6 ff ff       	jmp    80104fb9 <alltraps>

80105930 <vector145>:
.globl vector145
vector145:
  pushl $0
80105930:	6a 00                	push   $0x0
  pushl $145
80105932:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105937:	e9 7d f6 ff ff       	jmp    80104fb9 <alltraps>

8010593c <vector146>:
.globl vector146
vector146:
  pushl $0
8010593c:	6a 00                	push   $0x0
  pushl $146
8010593e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105943:	e9 71 f6 ff ff       	jmp    80104fb9 <alltraps>

80105948 <vector147>:
.globl vector147
vector147:
  pushl $0
80105948:	6a 00                	push   $0x0
  pushl $147
8010594a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010594f:	e9 65 f6 ff ff       	jmp    80104fb9 <alltraps>

80105954 <vector148>:
.globl vector148
vector148:
  pushl $0
80105954:	6a 00                	push   $0x0
  pushl $148
80105956:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010595b:	e9 59 f6 ff ff       	jmp    80104fb9 <alltraps>

80105960 <vector149>:
.globl vector149
vector149:
  pushl $0
80105960:	6a 00                	push   $0x0
  pushl $149
80105962:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105967:	e9 4d f6 ff ff       	jmp    80104fb9 <alltraps>

8010596c <vector150>:
.globl vector150
vector150:
  pushl $0
8010596c:	6a 00                	push   $0x0
  pushl $150
8010596e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105973:	e9 41 f6 ff ff       	jmp    80104fb9 <alltraps>

80105978 <vector151>:
.globl vector151
vector151:
  pushl $0
80105978:	6a 00                	push   $0x0
  pushl $151
8010597a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010597f:	e9 35 f6 ff ff       	jmp    80104fb9 <alltraps>

80105984 <vector152>:
.globl vector152
vector152:
  pushl $0
80105984:	6a 00                	push   $0x0
  pushl $152
80105986:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010598b:	e9 29 f6 ff ff       	jmp    80104fb9 <alltraps>

80105990 <vector153>:
.globl vector153
vector153:
  pushl $0
80105990:	6a 00                	push   $0x0
  pushl $153
80105992:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105997:	e9 1d f6 ff ff       	jmp    80104fb9 <alltraps>

8010599c <vector154>:
.globl vector154
vector154:
  pushl $0
8010599c:	6a 00                	push   $0x0
  pushl $154
8010599e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801059a3:	e9 11 f6 ff ff       	jmp    80104fb9 <alltraps>

801059a8 <vector155>:
.globl vector155
vector155:
  pushl $0
801059a8:	6a 00                	push   $0x0
  pushl $155
801059aa:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801059af:	e9 05 f6 ff ff       	jmp    80104fb9 <alltraps>

801059b4 <vector156>:
.globl vector156
vector156:
  pushl $0
801059b4:	6a 00                	push   $0x0
  pushl $156
801059b6:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801059bb:	e9 f9 f5 ff ff       	jmp    80104fb9 <alltraps>

801059c0 <vector157>:
.globl vector157
vector157:
  pushl $0
801059c0:	6a 00                	push   $0x0
  pushl $157
801059c2:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801059c7:	e9 ed f5 ff ff       	jmp    80104fb9 <alltraps>

801059cc <vector158>:
.globl vector158
vector158:
  pushl $0
801059cc:	6a 00                	push   $0x0
  pushl $158
801059ce:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801059d3:	e9 e1 f5 ff ff       	jmp    80104fb9 <alltraps>

801059d8 <vector159>:
.globl vector159
vector159:
  pushl $0
801059d8:	6a 00                	push   $0x0
  pushl $159
801059da:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801059df:	e9 d5 f5 ff ff       	jmp    80104fb9 <alltraps>

801059e4 <vector160>:
.globl vector160
vector160:
  pushl $0
801059e4:	6a 00                	push   $0x0
  pushl $160
801059e6:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801059eb:	e9 c9 f5 ff ff       	jmp    80104fb9 <alltraps>

801059f0 <vector161>:
.globl vector161
vector161:
  pushl $0
801059f0:	6a 00                	push   $0x0
  pushl $161
801059f2:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801059f7:	e9 bd f5 ff ff       	jmp    80104fb9 <alltraps>

801059fc <vector162>:
.globl vector162
vector162:
  pushl $0
801059fc:	6a 00                	push   $0x0
  pushl $162
801059fe:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105a03:	e9 b1 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a08 <vector163>:
.globl vector163
vector163:
  pushl $0
80105a08:	6a 00                	push   $0x0
  pushl $163
80105a0a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105a0f:	e9 a5 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a14 <vector164>:
.globl vector164
vector164:
  pushl $0
80105a14:	6a 00                	push   $0x0
  pushl $164
80105a16:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105a1b:	e9 99 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a20 <vector165>:
.globl vector165
vector165:
  pushl $0
80105a20:	6a 00                	push   $0x0
  pushl $165
80105a22:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105a27:	e9 8d f5 ff ff       	jmp    80104fb9 <alltraps>

80105a2c <vector166>:
.globl vector166
vector166:
  pushl $0
80105a2c:	6a 00                	push   $0x0
  pushl $166
80105a2e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105a33:	e9 81 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a38 <vector167>:
.globl vector167
vector167:
  pushl $0
80105a38:	6a 00                	push   $0x0
  pushl $167
80105a3a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105a3f:	e9 75 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a44 <vector168>:
.globl vector168
vector168:
  pushl $0
80105a44:	6a 00                	push   $0x0
  pushl $168
80105a46:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105a4b:	e9 69 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a50 <vector169>:
.globl vector169
vector169:
  pushl $0
80105a50:	6a 00                	push   $0x0
  pushl $169
80105a52:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105a57:	e9 5d f5 ff ff       	jmp    80104fb9 <alltraps>

80105a5c <vector170>:
.globl vector170
vector170:
  pushl $0
80105a5c:	6a 00                	push   $0x0
  pushl $170
80105a5e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a63:	e9 51 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a68 <vector171>:
.globl vector171
vector171:
  pushl $0
80105a68:	6a 00                	push   $0x0
  pushl $171
80105a6a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a6f:	e9 45 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a74 <vector172>:
.globl vector172
vector172:
  pushl $0
80105a74:	6a 00                	push   $0x0
  pushl $172
80105a76:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a7b:	e9 39 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a80 <vector173>:
.globl vector173
vector173:
  pushl $0
80105a80:	6a 00                	push   $0x0
  pushl $173
80105a82:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a87:	e9 2d f5 ff ff       	jmp    80104fb9 <alltraps>

80105a8c <vector174>:
.globl vector174
vector174:
  pushl $0
80105a8c:	6a 00                	push   $0x0
  pushl $174
80105a8e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105a93:	e9 21 f5 ff ff       	jmp    80104fb9 <alltraps>

80105a98 <vector175>:
.globl vector175
vector175:
  pushl $0
80105a98:	6a 00                	push   $0x0
  pushl $175
80105a9a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105a9f:	e9 15 f5 ff ff       	jmp    80104fb9 <alltraps>

80105aa4 <vector176>:
.globl vector176
vector176:
  pushl $0
80105aa4:	6a 00                	push   $0x0
  pushl $176
80105aa6:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105aab:	e9 09 f5 ff ff       	jmp    80104fb9 <alltraps>

80105ab0 <vector177>:
.globl vector177
vector177:
  pushl $0
80105ab0:	6a 00                	push   $0x0
  pushl $177
80105ab2:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105ab7:	e9 fd f4 ff ff       	jmp    80104fb9 <alltraps>

80105abc <vector178>:
.globl vector178
vector178:
  pushl $0
80105abc:	6a 00                	push   $0x0
  pushl $178
80105abe:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105ac3:	e9 f1 f4 ff ff       	jmp    80104fb9 <alltraps>

80105ac8 <vector179>:
.globl vector179
vector179:
  pushl $0
80105ac8:	6a 00                	push   $0x0
  pushl $179
80105aca:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105acf:	e9 e5 f4 ff ff       	jmp    80104fb9 <alltraps>

80105ad4 <vector180>:
.globl vector180
vector180:
  pushl $0
80105ad4:	6a 00                	push   $0x0
  pushl $180
80105ad6:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105adb:	e9 d9 f4 ff ff       	jmp    80104fb9 <alltraps>

80105ae0 <vector181>:
.globl vector181
vector181:
  pushl $0
80105ae0:	6a 00                	push   $0x0
  pushl $181
80105ae2:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105ae7:	e9 cd f4 ff ff       	jmp    80104fb9 <alltraps>

80105aec <vector182>:
.globl vector182
vector182:
  pushl $0
80105aec:	6a 00                	push   $0x0
  pushl $182
80105aee:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105af3:	e9 c1 f4 ff ff       	jmp    80104fb9 <alltraps>

80105af8 <vector183>:
.globl vector183
vector183:
  pushl $0
80105af8:	6a 00                	push   $0x0
  pushl $183
80105afa:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105aff:	e9 b5 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b04 <vector184>:
.globl vector184
vector184:
  pushl $0
80105b04:	6a 00                	push   $0x0
  pushl $184
80105b06:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105b0b:	e9 a9 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b10 <vector185>:
.globl vector185
vector185:
  pushl $0
80105b10:	6a 00                	push   $0x0
  pushl $185
80105b12:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105b17:	e9 9d f4 ff ff       	jmp    80104fb9 <alltraps>

80105b1c <vector186>:
.globl vector186
vector186:
  pushl $0
80105b1c:	6a 00                	push   $0x0
  pushl $186
80105b1e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105b23:	e9 91 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b28 <vector187>:
.globl vector187
vector187:
  pushl $0
80105b28:	6a 00                	push   $0x0
  pushl $187
80105b2a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105b2f:	e9 85 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b34 <vector188>:
.globl vector188
vector188:
  pushl $0
80105b34:	6a 00                	push   $0x0
  pushl $188
80105b36:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105b3b:	e9 79 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b40 <vector189>:
.globl vector189
vector189:
  pushl $0
80105b40:	6a 00                	push   $0x0
  pushl $189
80105b42:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105b47:	e9 6d f4 ff ff       	jmp    80104fb9 <alltraps>

80105b4c <vector190>:
.globl vector190
vector190:
  pushl $0
80105b4c:	6a 00                	push   $0x0
  pushl $190
80105b4e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105b53:	e9 61 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b58 <vector191>:
.globl vector191
vector191:
  pushl $0
80105b58:	6a 00                	push   $0x0
  pushl $191
80105b5a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105b5f:	e9 55 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b64 <vector192>:
.globl vector192
vector192:
  pushl $0
80105b64:	6a 00                	push   $0x0
  pushl $192
80105b66:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b6b:	e9 49 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b70 <vector193>:
.globl vector193
vector193:
  pushl $0
80105b70:	6a 00                	push   $0x0
  pushl $193
80105b72:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b77:	e9 3d f4 ff ff       	jmp    80104fb9 <alltraps>

80105b7c <vector194>:
.globl vector194
vector194:
  pushl $0
80105b7c:	6a 00                	push   $0x0
  pushl $194
80105b7e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b83:	e9 31 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b88 <vector195>:
.globl vector195
vector195:
  pushl $0
80105b88:	6a 00                	push   $0x0
  pushl $195
80105b8a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105b8f:	e9 25 f4 ff ff       	jmp    80104fb9 <alltraps>

80105b94 <vector196>:
.globl vector196
vector196:
  pushl $0
80105b94:	6a 00                	push   $0x0
  pushl $196
80105b96:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105b9b:	e9 19 f4 ff ff       	jmp    80104fb9 <alltraps>

80105ba0 <vector197>:
.globl vector197
vector197:
  pushl $0
80105ba0:	6a 00                	push   $0x0
  pushl $197
80105ba2:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105ba7:	e9 0d f4 ff ff       	jmp    80104fb9 <alltraps>

80105bac <vector198>:
.globl vector198
vector198:
  pushl $0
80105bac:	6a 00                	push   $0x0
  pushl $198
80105bae:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105bb3:	e9 01 f4 ff ff       	jmp    80104fb9 <alltraps>

80105bb8 <vector199>:
.globl vector199
vector199:
  pushl $0
80105bb8:	6a 00                	push   $0x0
  pushl $199
80105bba:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105bbf:	e9 f5 f3 ff ff       	jmp    80104fb9 <alltraps>

80105bc4 <vector200>:
.globl vector200
vector200:
  pushl $0
80105bc4:	6a 00                	push   $0x0
  pushl $200
80105bc6:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105bcb:	e9 e9 f3 ff ff       	jmp    80104fb9 <alltraps>

80105bd0 <vector201>:
.globl vector201
vector201:
  pushl $0
80105bd0:	6a 00                	push   $0x0
  pushl $201
80105bd2:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105bd7:	e9 dd f3 ff ff       	jmp    80104fb9 <alltraps>

80105bdc <vector202>:
.globl vector202
vector202:
  pushl $0
80105bdc:	6a 00                	push   $0x0
  pushl $202
80105bde:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105be3:	e9 d1 f3 ff ff       	jmp    80104fb9 <alltraps>

80105be8 <vector203>:
.globl vector203
vector203:
  pushl $0
80105be8:	6a 00                	push   $0x0
  pushl $203
80105bea:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105bef:	e9 c5 f3 ff ff       	jmp    80104fb9 <alltraps>

80105bf4 <vector204>:
.globl vector204
vector204:
  pushl $0
80105bf4:	6a 00                	push   $0x0
  pushl $204
80105bf6:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105bfb:	e9 b9 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c00 <vector205>:
.globl vector205
vector205:
  pushl $0
80105c00:	6a 00                	push   $0x0
  pushl $205
80105c02:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105c07:	e9 ad f3 ff ff       	jmp    80104fb9 <alltraps>

80105c0c <vector206>:
.globl vector206
vector206:
  pushl $0
80105c0c:	6a 00                	push   $0x0
  pushl $206
80105c0e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105c13:	e9 a1 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c18 <vector207>:
.globl vector207
vector207:
  pushl $0
80105c18:	6a 00                	push   $0x0
  pushl $207
80105c1a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105c1f:	e9 95 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c24 <vector208>:
.globl vector208
vector208:
  pushl $0
80105c24:	6a 00                	push   $0x0
  pushl $208
80105c26:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105c2b:	e9 89 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c30 <vector209>:
.globl vector209
vector209:
  pushl $0
80105c30:	6a 00                	push   $0x0
  pushl $209
80105c32:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105c37:	e9 7d f3 ff ff       	jmp    80104fb9 <alltraps>

80105c3c <vector210>:
.globl vector210
vector210:
  pushl $0
80105c3c:	6a 00                	push   $0x0
  pushl $210
80105c3e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105c43:	e9 71 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c48 <vector211>:
.globl vector211
vector211:
  pushl $0
80105c48:	6a 00                	push   $0x0
  pushl $211
80105c4a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105c4f:	e9 65 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c54 <vector212>:
.globl vector212
vector212:
  pushl $0
80105c54:	6a 00                	push   $0x0
  pushl $212
80105c56:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105c5b:	e9 59 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c60 <vector213>:
.globl vector213
vector213:
  pushl $0
80105c60:	6a 00                	push   $0x0
  pushl $213
80105c62:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c67:	e9 4d f3 ff ff       	jmp    80104fb9 <alltraps>

80105c6c <vector214>:
.globl vector214
vector214:
  pushl $0
80105c6c:	6a 00                	push   $0x0
  pushl $214
80105c6e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c73:	e9 41 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c78 <vector215>:
.globl vector215
vector215:
  pushl $0
80105c78:	6a 00                	push   $0x0
  pushl $215
80105c7a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c7f:	e9 35 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c84 <vector216>:
.globl vector216
vector216:
  pushl $0
80105c84:	6a 00                	push   $0x0
  pushl $216
80105c86:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c8b:	e9 29 f3 ff ff       	jmp    80104fb9 <alltraps>

80105c90 <vector217>:
.globl vector217
vector217:
  pushl $0
80105c90:	6a 00                	push   $0x0
  pushl $217
80105c92:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105c97:	e9 1d f3 ff ff       	jmp    80104fb9 <alltraps>

80105c9c <vector218>:
.globl vector218
vector218:
  pushl $0
80105c9c:	6a 00                	push   $0x0
  pushl $218
80105c9e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105ca3:	e9 11 f3 ff ff       	jmp    80104fb9 <alltraps>

80105ca8 <vector219>:
.globl vector219
vector219:
  pushl $0
80105ca8:	6a 00                	push   $0x0
  pushl $219
80105caa:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105caf:	e9 05 f3 ff ff       	jmp    80104fb9 <alltraps>

80105cb4 <vector220>:
.globl vector220
vector220:
  pushl $0
80105cb4:	6a 00                	push   $0x0
  pushl $220
80105cb6:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105cbb:	e9 f9 f2 ff ff       	jmp    80104fb9 <alltraps>

80105cc0 <vector221>:
.globl vector221
vector221:
  pushl $0
80105cc0:	6a 00                	push   $0x0
  pushl $221
80105cc2:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105cc7:	e9 ed f2 ff ff       	jmp    80104fb9 <alltraps>

80105ccc <vector222>:
.globl vector222
vector222:
  pushl $0
80105ccc:	6a 00                	push   $0x0
  pushl $222
80105cce:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105cd3:	e9 e1 f2 ff ff       	jmp    80104fb9 <alltraps>

80105cd8 <vector223>:
.globl vector223
vector223:
  pushl $0
80105cd8:	6a 00                	push   $0x0
  pushl $223
80105cda:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105cdf:	e9 d5 f2 ff ff       	jmp    80104fb9 <alltraps>

80105ce4 <vector224>:
.globl vector224
vector224:
  pushl $0
80105ce4:	6a 00                	push   $0x0
  pushl $224
80105ce6:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105ceb:	e9 c9 f2 ff ff       	jmp    80104fb9 <alltraps>

80105cf0 <vector225>:
.globl vector225
vector225:
  pushl $0
80105cf0:	6a 00                	push   $0x0
  pushl $225
80105cf2:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105cf7:	e9 bd f2 ff ff       	jmp    80104fb9 <alltraps>

80105cfc <vector226>:
.globl vector226
vector226:
  pushl $0
80105cfc:	6a 00                	push   $0x0
  pushl $226
80105cfe:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105d03:	e9 b1 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d08 <vector227>:
.globl vector227
vector227:
  pushl $0
80105d08:	6a 00                	push   $0x0
  pushl $227
80105d0a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105d0f:	e9 a5 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d14 <vector228>:
.globl vector228
vector228:
  pushl $0
80105d14:	6a 00                	push   $0x0
  pushl $228
80105d16:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105d1b:	e9 99 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d20 <vector229>:
.globl vector229
vector229:
  pushl $0
80105d20:	6a 00                	push   $0x0
  pushl $229
80105d22:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105d27:	e9 8d f2 ff ff       	jmp    80104fb9 <alltraps>

80105d2c <vector230>:
.globl vector230
vector230:
  pushl $0
80105d2c:	6a 00                	push   $0x0
  pushl $230
80105d2e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105d33:	e9 81 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d38 <vector231>:
.globl vector231
vector231:
  pushl $0
80105d38:	6a 00                	push   $0x0
  pushl $231
80105d3a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105d3f:	e9 75 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d44 <vector232>:
.globl vector232
vector232:
  pushl $0
80105d44:	6a 00                	push   $0x0
  pushl $232
80105d46:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105d4b:	e9 69 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d50 <vector233>:
.globl vector233
vector233:
  pushl $0
80105d50:	6a 00                	push   $0x0
  pushl $233
80105d52:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105d57:	e9 5d f2 ff ff       	jmp    80104fb9 <alltraps>

80105d5c <vector234>:
.globl vector234
vector234:
  pushl $0
80105d5c:	6a 00                	push   $0x0
  pushl $234
80105d5e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d63:	e9 51 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d68 <vector235>:
.globl vector235
vector235:
  pushl $0
80105d68:	6a 00                	push   $0x0
  pushl $235
80105d6a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d6f:	e9 45 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d74 <vector236>:
.globl vector236
vector236:
  pushl $0
80105d74:	6a 00                	push   $0x0
  pushl $236
80105d76:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d7b:	e9 39 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d80 <vector237>:
.globl vector237
vector237:
  pushl $0
80105d80:	6a 00                	push   $0x0
  pushl $237
80105d82:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d87:	e9 2d f2 ff ff       	jmp    80104fb9 <alltraps>

80105d8c <vector238>:
.globl vector238
vector238:
  pushl $0
80105d8c:	6a 00                	push   $0x0
  pushl $238
80105d8e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105d93:	e9 21 f2 ff ff       	jmp    80104fb9 <alltraps>

80105d98 <vector239>:
.globl vector239
vector239:
  pushl $0
80105d98:	6a 00                	push   $0x0
  pushl $239
80105d9a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105d9f:	e9 15 f2 ff ff       	jmp    80104fb9 <alltraps>

80105da4 <vector240>:
.globl vector240
vector240:
  pushl $0
80105da4:	6a 00                	push   $0x0
  pushl $240
80105da6:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105dab:	e9 09 f2 ff ff       	jmp    80104fb9 <alltraps>

80105db0 <vector241>:
.globl vector241
vector241:
  pushl $0
80105db0:	6a 00                	push   $0x0
  pushl $241
80105db2:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105db7:	e9 fd f1 ff ff       	jmp    80104fb9 <alltraps>

80105dbc <vector242>:
.globl vector242
vector242:
  pushl $0
80105dbc:	6a 00                	push   $0x0
  pushl $242
80105dbe:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105dc3:	e9 f1 f1 ff ff       	jmp    80104fb9 <alltraps>

80105dc8 <vector243>:
.globl vector243
vector243:
  pushl $0
80105dc8:	6a 00                	push   $0x0
  pushl $243
80105dca:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105dcf:	e9 e5 f1 ff ff       	jmp    80104fb9 <alltraps>

80105dd4 <vector244>:
.globl vector244
vector244:
  pushl $0
80105dd4:	6a 00                	push   $0x0
  pushl $244
80105dd6:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105ddb:	e9 d9 f1 ff ff       	jmp    80104fb9 <alltraps>

80105de0 <vector245>:
.globl vector245
vector245:
  pushl $0
80105de0:	6a 00                	push   $0x0
  pushl $245
80105de2:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105de7:	e9 cd f1 ff ff       	jmp    80104fb9 <alltraps>

80105dec <vector246>:
.globl vector246
vector246:
  pushl $0
80105dec:	6a 00                	push   $0x0
  pushl $246
80105dee:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105df3:	e9 c1 f1 ff ff       	jmp    80104fb9 <alltraps>

80105df8 <vector247>:
.globl vector247
vector247:
  pushl $0
80105df8:	6a 00                	push   $0x0
  pushl $247
80105dfa:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105dff:	e9 b5 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e04 <vector248>:
.globl vector248
vector248:
  pushl $0
80105e04:	6a 00                	push   $0x0
  pushl $248
80105e06:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105e0b:	e9 a9 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e10 <vector249>:
.globl vector249
vector249:
  pushl $0
80105e10:	6a 00                	push   $0x0
  pushl $249
80105e12:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105e17:	e9 9d f1 ff ff       	jmp    80104fb9 <alltraps>

80105e1c <vector250>:
.globl vector250
vector250:
  pushl $0
80105e1c:	6a 00                	push   $0x0
  pushl $250
80105e1e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105e23:	e9 91 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e28 <vector251>:
.globl vector251
vector251:
  pushl $0
80105e28:	6a 00                	push   $0x0
  pushl $251
80105e2a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105e2f:	e9 85 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e34 <vector252>:
.globl vector252
vector252:
  pushl $0
80105e34:	6a 00                	push   $0x0
  pushl $252
80105e36:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105e3b:	e9 79 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e40 <vector253>:
.globl vector253
vector253:
  pushl $0
80105e40:	6a 00                	push   $0x0
  pushl $253
80105e42:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105e47:	e9 6d f1 ff ff       	jmp    80104fb9 <alltraps>

80105e4c <vector254>:
.globl vector254
vector254:
  pushl $0
80105e4c:	6a 00                	push   $0x0
  pushl $254
80105e4e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105e53:	e9 61 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e58 <vector255>:
.globl vector255
vector255:
  pushl $0
80105e58:	6a 00                	push   $0x0
  pushl $255
80105e5a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105e5f:	e9 55 f1 ff ff       	jmp    80104fb9 <alltraps>

80105e64 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e64:	55                   	push   %ebp
80105e65:	89 e5                	mov    %esp,%ebp
80105e67:	57                   	push   %edi
80105e68:	56                   	push   %esi
80105e69:	53                   	push   %ebx
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e6f:	c1 ea 16             	shr    $0x16,%edx
80105e72:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105e75:	8b 1f                	mov    (%edi),%ebx
80105e77:	f6 c3 01             	test   $0x1,%bl
80105e7a:	74 22                	je     80105e9e <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105e7c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105e82:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e88:	c1 ee 0c             	shr    $0xc,%esi
80105e8b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105e91:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105e94:	89 d8                	mov    %ebx,%eax
80105e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e99:	5b                   	pop    %ebx
80105e9a:	5e                   	pop    %esi
80105e9b:	5f                   	pop    %edi
80105e9c:	5d                   	pop    %ebp
80105e9d:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105e9e:	85 c9                	test   %ecx,%ecx
80105ea0:	74 2b                	je     80105ecd <walkpgdir+0x69>
80105ea2:	e8 14 c2 ff ff       	call   801020bb <kalloc>
80105ea7:	89 c3                	mov    %eax,%ebx
80105ea9:	85 c0                	test   %eax,%eax
80105eab:	74 e7                	je     80105e94 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105ead:	83 ec 04             	sub    $0x4,%esp
80105eb0:	68 00 10 00 00       	push   $0x1000
80105eb5:	6a 00                	push   $0x0
80105eb7:	50                   	push   %eax
80105eb8:	e8 f7 df ff ff       	call   80103eb4 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ebd:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105ec3:	83 c8 07             	or     $0x7,%eax
80105ec6:	89 07                	mov    %eax,(%edi)
80105ec8:	83 c4 10             	add    $0x10,%esp
80105ecb:	eb bb                	jmp    80105e88 <walkpgdir+0x24>
      return 0;
80105ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
80105ed2:	eb c0                	jmp    80105e94 <walkpgdir+0x30>

80105ed4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105ed4:	55                   	push   %ebp
80105ed5:	89 e5                	mov    %esp,%ebp
80105ed7:	57                   	push   %edi
80105ed8:	56                   	push   %esi
80105ed9:	53                   	push   %ebx
80105eda:	83 ec 1c             	sub    $0x1c,%esp
80105edd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ee0:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ee3:	89 d3                	mov    %edx,%ebx
80105ee5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105eeb:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105eef:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ef5:	b9 01 00 00 00       	mov    $0x1,%ecx
80105efa:	89 da                	mov    %ebx,%edx
80105efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eff:	e8 60 ff ff ff       	call   80105e64 <walkpgdir>
80105f04:	85 c0                	test   %eax,%eax
80105f06:	74 2e                	je     80105f36 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105f08:	f6 00 01             	testb  $0x1,(%eax)
80105f0b:	75 1c                	jne    80105f29 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105f0d:	89 f2                	mov    %esi,%edx
80105f0f:	0b 55 0c             	or     0xc(%ebp),%edx
80105f12:	83 ca 01             	or     $0x1,%edx
80105f15:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105f17:	39 fb                	cmp    %edi,%ebx
80105f19:	74 28                	je     80105f43 <mappages+0x6f>
      break;
    a += PGSIZE;
80105f1b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105f21:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f27:	eb cc                	jmp    80105ef5 <mappages+0x21>
      panic("remap");
80105f29:	83 ec 0c             	sub    $0xc,%esp
80105f2c:	68 ec 6f 10 80       	push   $0x80106fec
80105f31:	e8 12 a4 ff ff       	call   80100348 <panic>
      return -1;
80105f36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105f3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f3e:	5b                   	pop    %ebx
80105f3f:	5e                   	pop    %esi
80105f40:	5f                   	pop    %edi
80105f41:	5d                   	pop    %ebp
80105f42:	c3                   	ret    
  return 0;
80105f43:	b8 00 00 00 00       	mov    $0x0,%eax
80105f48:	eb f1                	jmp    80105f3b <mappages+0x67>

80105f4a <seginit>:
{
80105f4a:	55                   	push   %ebp
80105f4b:	89 e5                	mov    %esp,%ebp
80105f4d:	53                   	push   %ebx
80105f4e:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105f51:	e8 87 d4 ff ff       	call   801033dd <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f56:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f5c:	66 c7 80 18 e6 1b 80 	movw   $0xffff,-0x7fe419e8(%eax)
80105f63:	ff ff 
80105f65:	66 c7 80 1a e6 1b 80 	movw   $0x0,-0x7fe419e6(%eax)
80105f6c:	00 00 
80105f6e:	c6 80 1c e6 1b 80 00 	movb   $0x0,-0x7fe419e4(%eax)
80105f75:	0f b6 88 1d e6 1b 80 	movzbl -0x7fe419e3(%eax),%ecx
80105f7c:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f7f:	83 c9 1a             	or     $0x1a,%ecx
80105f82:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f85:	83 c9 80             	or     $0xffffff80,%ecx
80105f88:	88 88 1d e6 1b 80    	mov    %cl,-0x7fe419e3(%eax)
80105f8e:	0f b6 88 1e e6 1b 80 	movzbl -0x7fe419e2(%eax),%ecx
80105f95:	83 c9 0f             	or     $0xf,%ecx
80105f98:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f9b:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f9e:	88 88 1e e6 1b 80    	mov    %cl,-0x7fe419e2(%eax)
80105fa4:	c6 80 1f e6 1b 80 00 	movb   $0x0,-0x7fe419e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105fab:	66 c7 80 20 e6 1b 80 	movw   $0xffff,-0x7fe419e0(%eax)
80105fb2:	ff ff 
80105fb4:	66 c7 80 22 e6 1b 80 	movw   $0x0,-0x7fe419de(%eax)
80105fbb:	00 00 
80105fbd:	c6 80 24 e6 1b 80 00 	movb   $0x0,-0x7fe419dc(%eax)
80105fc4:	0f b6 88 25 e6 1b 80 	movzbl -0x7fe419db(%eax),%ecx
80105fcb:	83 e1 f0             	and    $0xfffffff0,%ecx
80105fce:	83 c9 12             	or     $0x12,%ecx
80105fd1:	83 e1 9f             	and    $0xffffff9f,%ecx
80105fd4:	83 c9 80             	or     $0xffffff80,%ecx
80105fd7:	88 88 25 e6 1b 80    	mov    %cl,-0x7fe419db(%eax)
80105fdd:	0f b6 88 26 e6 1b 80 	movzbl -0x7fe419da(%eax),%ecx
80105fe4:	83 c9 0f             	or     $0xf,%ecx
80105fe7:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fea:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fed:	88 88 26 e6 1b 80    	mov    %cl,-0x7fe419da(%eax)
80105ff3:	c6 80 27 e6 1b 80 00 	movb   $0x0,-0x7fe419d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105ffa:	66 c7 80 28 e6 1b 80 	movw   $0xffff,-0x7fe419d8(%eax)
80106001:	ff ff 
80106003:	66 c7 80 2a e6 1b 80 	movw   $0x0,-0x7fe419d6(%eax)
8010600a:	00 00 
8010600c:	c6 80 2c e6 1b 80 00 	movb   $0x0,-0x7fe419d4(%eax)
80106013:	c6 80 2d e6 1b 80 fa 	movb   $0xfa,-0x7fe419d3(%eax)
8010601a:	0f b6 88 2e e6 1b 80 	movzbl -0x7fe419d2(%eax),%ecx
80106021:	83 c9 0f             	or     $0xf,%ecx
80106024:	83 e1 cf             	and    $0xffffffcf,%ecx
80106027:	83 c9 c0             	or     $0xffffffc0,%ecx
8010602a:	88 88 2e e6 1b 80    	mov    %cl,-0x7fe419d2(%eax)
80106030:	c6 80 2f e6 1b 80 00 	movb   $0x0,-0x7fe419d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106037:	66 c7 80 30 e6 1b 80 	movw   $0xffff,-0x7fe419d0(%eax)
8010603e:	ff ff 
80106040:	66 c7 80 32 e6 1b 80 	movw   $0x0,-0x7fe419ce(%eax)
80106047:	00 00 
80106049:	c6 80 34 e6 1b 80 00 	movb   $0x0,-0x7fe419cc(%eax)
80106050:	c6 80 35 e6 1b 80 f2 	movb   $0xf2,-0x7fe419cb(%eax)
80106057:	0f b6 88 36 e6 1b 80 	movzbl -0x7fe419ca(%eax),%ecx
8010605e:	83 c9 0f             	or     $0xf,%ecx
80106061:	83 e1 cf             	and    $0xffffffcf,%ecx
80106064:	83 c9 c0             	or     $0xffffffc0,%ecx
80106067:	88 88 36 e6 1b 80    	mov    %cl,-0x7fe419ca(%eax)
8010606d:	c6 80 37 e6 1b 80 00 	movb   $0x0,-0x7fe419c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106074:	05 10 e6 1b 80       	add    $0x801be610,%eax
  pd[0] = size-1;
80106079:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
8010607f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106083:	c1 e8 10             	shr    $0x10,%eax
80106086:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010608a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010608d:	0f 01 10             	lgdtl  (%eax)
}
80106090:	83 c4 14             	add    $0x14,%esp
80106093:	5b                   	pop    %ebx
80106094:	5d                   	pop    %ebp
80106095:	c3                   	ret    

80106096 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80106096:	55                   	push   %ebp
80106097:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106099:	a1 c4 12 1c 80       	mov    0x801c12c4,%eax
8010609e:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060a3:	0f 22 d8             	mov    %eax,%cr3
}
801060a6:	5d                   	pop    %ebp
801060a7:	c3                   	ret    

801060a8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801060a8:	55                   	push   %ebp
801060a9:	89 e5                	mov    %esp,%ebp
801060ab:	57                   	push   %edi
801060ac:	56                   	push   %esi
801060ad:	53                   	push   %ebx
801060ae:	83 ec 1c             	sub    $0x1c,%esp
801060b1:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801060b4:	85 f6                	test   %esi,%esi
801060b6:	0f 84 dd 00 00 00    	je     80106199 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801060bc:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801060c0:	0f 84 e0 00 00 00    	je     801061a6 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801060c6:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801060ca:	0f 84 e3 00 00 00    	je     801061b3 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
801060d0:	e8 56 dc ff ff       	call   80103d2b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801060d5:	e8 a7 d2 ff ff       	call   80103381 <mycpu>
801060da:	89 c3                	mov    %eax,%ebx
801060dc:	e8 a0 d2 ff ff       	call   80103381 <mycpu>
801060e1:	8d 78 08             	lea    0x8(%eax),%edi
801060e4:	e8 98 d2 ff ff       	call   80103381 <mycpu>
801060e9:	83 c0 08             	add    $0x8,%eax
801060ec:	c1 e8 10             	shr    $0x10,%eax
801060ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060f2:	e8 8a d2 ff ff       	call   80103381 <mycpu>
801060f7:	83 c0 08             	add    $0x8,%eax
801060fa:	c1 e8 18             	shr    $0x18,%eax
801060fd:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106104:	67 00 
80106106:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010610d:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106111:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106117:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010611e:	83 e2 f0             	and    $0xfffffff0,%edx
80106121:	83 ca 19             	or     $0x19,%edx
80106124:	83 e2 9f             	and    $0xffffff9f,%edx
80106127:	83 ca 80             	or     $0xffffff80,%edx
8010612a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106130:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106137:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010613d:	e8 3f d2 ff ff       	call   80103381 <mycpu>
80106142:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106149:	83 e2 ef             	and    $0xffffffef,%edx
8010614c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106152:	e8 2a d2 ff ff       	call   80103381 <mycpu>
80106157:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010615d:	8b 5e 08             	mov    0x8(%esi),%ebx
80106160:	e8 1c d2 ff ff       	call   80103381 <mycpu>
80106165:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010616b:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010616e:	e8 0e d2 ff ff       	call   80103381 <mycpu>
80106173:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106179:	b8 28 00 00 00       	mov    $0x28,%eax
8010617e:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106181:	8b 46 04             	mov    0x4(%esi),%eax
80106184:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106189:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010618c:	e8 d7 db ff ff       	call   80103d68 <popcli>
}
80106191:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106194:	5b                   	pop    %ebx
80106195:	5e                   	pop    %esi
80106196:	5f                   	pop    %edi
80106197:	5d                   	pop    %ebp
80106198:	c3                   	ret    
    panic("switchuvm: no process");
80106199:	83 ec 0c             	sub    $0xc,%esp
8010619c:	68 f2 6f 10 80       	push   $0x80106ff2
801061a1:	e8 a2 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801061a6:	83 ec 0c             	sub    $0xc,%esp
801061a9:	68 08 70 10 80       	push   $0x80107008
801061ae:	e8 95 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801061b3:	83 ec 0c             	sub    $0xc,%esp
801061b6:	68 1d 70 10 80       	push   $0x8010701d
801061bb:	e8 88 a1 ff ff       	call   80100348 <panic>

801061c0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061c0:	55                   	push   %ebp
801061c1:	89 e5                	mov    %esp,%ebp
801061c3:	56                   	push   %esi
801061c4:	53                   	push   %ebx
801061c5:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061c8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061ce:	77 4c                	ja     8010621c <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
801061d0:	e8 e6 be ff ff       	call   801020bb <kalloc>
801061d5:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061d7:	83 ec 04             	sub    $0x4,%esp
801061da:	68 00 10 00 00       	push   $0x1000
801061df:	6a 00                	push   $0x0
801061e1:	50                   	push   %eax
801061e2:	e8 cd dc ff ff       	call   80103eb4 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801061e7:	83 c4 08             	add    $0x8,%esp
801061ea:	6a 06                	push   $0x6
801061ec:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801061f2:	50                   	push   %eax
801061f3:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061f8:	ba 00 00 00 00       	mov    $0x0,%edx
801061fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106200:	e8 cf fc ff ff       	call   80105ed4 <mappages>
  memmove(mem, init, sz);
80106205:	83 c4 0c             	add    $0xc,%esp
80106208:	56                   	push   %esi
80106209:	ff 75 0c             	pushl  0xc(%ebp)
8010620c:	53                   	push   %ebx
8010620d:	e8 1d dd ff ff       	call   80103f2f <memmove>
}
80106212:	83 c4 10             	add    $0x10,%esp
80106215:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106218:	5b                   	pop    %ebx
80106219:	5e                   	pop    %esi
8010621a:	5d                   	pop    %ebp
8010621b:	c3                   	ret    
    panic("inituvm: more than a page");
8010621c:	83 ec 0c             	sub    $0xc,%esp
8010621f:	68 31 70 10 80       	push   $0x80107031
80106224:	e8 1f a1 ff ff       	call   80100348 <panic>

80106229 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106229:	55                   	push   %ebp
8010622a:	89 e5                	mov    %esp,%ebp
8010622c:	57                   	push   %edi
8010622d:	56                   	push   %esi
8010622e:	53                   	push   %ebx
8010622f:	83 ec 0c             	sub    $0xc,%esp
80106232:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106235:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010623c:	75 07                	jne    80106245 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010623e:	bb 00 00 00 00       	mov    $0x0,%ebx
80106243:	eb 3c                	jmp    80106281 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106245:	83 ec 0c             	sub    $0xc,%esp
80106248:	68 ec 70 10 80       	push   $0x801070ec
8010624d:	e8 f6 a0 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106252:	83 ec 0c             	sub    $0xc,%esp
80106255:	68 4b 70 10 80       	push   $0x8010704b
8010625a:	e8 e9 a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010625f:	05 00 00 00 80       	add    $0x80000000,%eax
80106264:	56                   	push   %esi
80106265:	89 da                	mov    %ebx,%edx
80106267:	03 55 14             	add    0x14(%ebp),%edx
8010626a:	52                   	push   %edx
8010626b:	50                   	push   %eax
8010626c:	ff 75 10             	pushl  0x10(%ebp)
8010626f:	e8 ff b4 ff ff       	call   80101773 <readi>
80106274:	83 c4 10             	add    $0x10,%esp
80106277:	39 f0                	cmp    %esi,%eax
80106279:	75 47                	jne    801062c2 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010627b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106281:	39 fb                	cmp    %edi,%ebx
80106283:	73 30                	jae    801062b5 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106285:	89 da                	mov    %ebx,%edx
80106287:	03 55 0c             	add    0xc(%ebp),%edx
8010628a:	b9 00 00 00 00       	mov    $0x0,%ecx
8010628f:	8b 45 08             	mov    0x8(%ebp),%eax
80106292:	e8 cd fb ff ff       	call   80105e64 <walkpgdir>
80106297:	85 c0                	test   %eax,%eax
80106299:	74 b7                	je     80106252 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
8010629b:	8b 00                	mov    (%eax),%eax
8010629d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062a2:	89 fe                	mov    %edi,%esi
801062a4:	29 de                	sub    %ebx,%esi
801062a6:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062ac:	76 b1                	jbe    8010625f <loaduvm+0x36>
      n = PGSIZE;
801062ae:	be 00 10 00 00       	mov    $0x1000,%esi
801062b3:	eb aa                	jmp    8010625f <loaduvm+0x36>
      return -1;
  }
  return 0;
801062b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062bd:	5b                   	pop    %ebx
801062be:	5e                   	pop    %esi
801062bf:	5f                   	pop    %edi
801062c0:	5d                   	pop    %ebp
801062c1:	c3                   	ret    
      return -1;
801062c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c7:	eb f1                	jmp    801062ba <loaduvm+0x91>

801062c9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062c9:	55                   	push   %ebp
801062ca:	89 e5                	mov    %esp,%ebp
801062cc:	57                   	push   %edi
801062cd:	56                   	push   %esi
801062ce:	53                   	push   %ebx
801062cf:	83 ec 0c             	sub    $0xc,%esp
801062d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801062d5:	39 7d 10             	cmp    %edi,0x10(%ebp)
801062d8:	73 11                	jae    801062eb <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801062da:	8b 45 10             	mov    0x10(%ebp),%eax
801062dd:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062e3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062e9:	eb 19                	jmp    80106304 <deallocuvm+0x3b>
    return oldsz;
801062eb:	89 f8                	mov    %edi,%eax
801062ed:	eb 64                	jmp    80106353 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801062ef:	c1 eb 16             	shr    $0x16,%ebx
801062f2:	83 c3 01             	add    $0x1,%ebx
801062f5:	c1 e3 16             	shl    $0x16,%ebx
801062f8:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106304:	39 fb                	cmp    %edi,%ebx
80106306:	73 48                	jae    80106350 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106308:	b9 00 00 00 00       	mov    $0x0,%ecx
8010630d:	89 da                	mov    %ebx,%edx
8010630f:	8b 45 08             	mov    0x8(%ebp),%eax
80106312:	e8 4d fb ff ff       	call   80105e64 <walkpgdir>
80106317:	89 c6                	mov    %eax,%esi
    if(!pte)
80106319:	85 c0                	test   %eax,%eax
8010631b:	74 d2                	je     801062ef <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010631d:	8b 00                	mov    (%eax),%eax
8010631f:	a8 01                	test   $0x1,%al
80106321:	74 db                	je     801062fe <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106323:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106328:	74 19                	je     80106343 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010632a:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010632f:	83 ec 0c             	sub    $0xc,%esp
80106332:	50                   	push   %eax
80106333:	e8 6c bc ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106338:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010633e:	83 c4 10             	add    $0x10,%esp
80106341:	eb bb                	jmp    801062fe <deallocuvm+0x35>
        panic("kfree");
80106343:	83 ec 0c             	sub    $0xc,%esp
80106346:	68 86 69 10 80       	push   $0x80106986
8010634b:	e8 f8 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106350:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106353:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106356:	5b                   	pop    %ebx
80106357:	5e                   	pop    %esi
80106358:	5f                   	pop    %edi
80106359:	5d                   	pop    %ebp
8010635a:	c3                   	ret    

8010635b <allocuvm>:
{
8010635b:	55                   	push   %ebp
8010635c:	89 e5                	mov    %esp,%ebp
8010635e:	57                   	push   %edi
8010635f:	56                   	push   %esi
80106360:	53                   	push   %ebx
80106361:	83 ec 1c             	sub    $0x1c,%esp
80106364:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106367:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010636a:	85 ff                	test   %edi,%edi
8010636c:	0f 88 c1 00 00 00    	js     80106433 <allocuvm+0xd8>
  if(newsz < oldsz)
80106372:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106375:	72 5c                	jb     801063d3 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106377:	8b 45 0c             	mov    0xc(%ebp),%eax
8010637a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106380:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106386:	39 fb                	cmp    %edi,%ebx
80106388:	0f 83 ac 00 00 00    	jae    8010643a <allocuvm+0xdf>
    mem = kalloc();
8010638e:	e8 28 bd ff ff       	call   801020bb <kalloc>
80106393:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106395:	85 c0                	test   %eax,%eax
80106397:	74 42                	je     801063db <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
80106399:	83 ec 04             	sub    $0x4,%esp
8010639c:	68 00 10 00 00       	push   $0x1000
801063a1:	6a 00                	push   $0x0
801063a3:	50                   	push   %eax
801063a4:	e8 0b db ff ff       	call   80103eb4 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063a9:	83 c4 08             	add    $0x8,%esp
801063ac:	6a 06                	push   $0x6
801063ae:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801063b4:	50                   	push   %eax
801063b5:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063ba:	89 da                	mov    %ebx,%edx
801063bc:	8b 45 08             	mov    0x8(%ebp),%eax
801063bf:	e8 10 fb ff ff       	call   80105ed4 <mappages>
801063c4:	83 c4 10             	add    $0x10,%esp
801063c7:	85 c0                	test   %eax,%eax
801063c9:	78 38                	js     80106403 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801063cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063d1:	eb b3                	jmp    80106386 <allocuvm+0x2b>
    return oldsz;
801063d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801063d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801063d9:	eb 5f                	jmp    8010643a <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801063db:	83 ec 0c             	sub    $0xc,%esp
801063de:	68 69 70 10 80       	push   $0x80107069
801063e3:	e8 23 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801063e8:	83 c4 0c             	add    $0xc,%esp
801063eb:	ff 75 0c             	pushl  0xc(%ebp)
801063ee:	57                   	push   %edi
801063ef:	ff 75 08             	pushl  0x8(%ebp)
801063f2:	e8 d2 fe ff ff       	call   801062c9 <deallocuvm>
      return 0;
801063f7:	83 c4 10             	add    $0x10,%esp
801063fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106401:	eb 37                	jmp    8010643a <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106403:	83 ec 0c             	sub    $0xc,%esp
80106406:	68 81 70 10 80       	push   $0x80107081
8010640b:	e8 fb a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106410:	83 c4 0c             	add    $0xc,%esp
80106413:	ff 75 0c             	pushl  0xc(%ebp)
80106416:	57                   	push   %edi
80106417:	ff 75 08             	pushl  0x8(%ebp)
8010641a:	e8 aa fe ff ff       	call   801062c9 <deallocuvm>
      kfree(mem);
8010641f:	89 34 24             	mov    %esi,(%esp)
80106422:	e8 7d bb ff ff       	call   80101fa4 <kfree>
      return 0;
80106427:	83 c4 10             	add    $0x10,%esp
8010642a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106431:	eb 07                	jmp    8010643a <allocuvm+0xdf>
    return 0;
80106433:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010643a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010643d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106440:	5b                   	pop    %ebx
80106441:	5e                   	pop    %esi
80106442:	5f                   	pop    %edi
80106443:	5d                   	pop    %ebp
80106444:	c3                   	ret    

80106445 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106445:	55                   	push   %ebp
80106446:	89 e5                	mov    %esp,%ebp
80106448:	56                   	push   %esi
80106449:	53                   	push   %ebx
8010644a:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010644d:	85 f6                	test   %esi,%esi
8010644f:	74 1a                	je     8010646b <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106451:	83 ec 04             	sub    $0x4,%esp
80106454:	6a 00                	push   $0x0
80106456:	68 00 00 00 80       	push   $0x80000000
8010645b:	56                   	push   %esi
8010645c:	e8 68 fe ff ff       	call   801062c9 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106461:	83 c4 10             	add    $0x10,%esp
80106464:	bb 00 00 00 00       	mov    $0x0,%ebx
80106469:	eb 10                	jmp    8010647b <freevm+0x36>
    panic("freevm: no pgdir");
8010646b:	83 ec 0c             	sub    $0xc,%esp
8010646e:	68 9d 70 10 80       	push   $0x8010709d
80106473:	e8 d0 9e ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106478:	83 c3 01             	add    $0x1,%ebx
8010647b:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106481:	77 1f                	ja     801064a2 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106483:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106486:	a8 01                	test   $0x1,%al
80106488:	74 ee                	je     80106478 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010648a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010648f:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106494:	83 ec 0c             	sub    $0xc,%esp
80106497:	50                   	push   %eax
80106498:	e8 07 bb ff ff       	call   80101fa4 <kfree>
8010649d:	83 c4 10             	add    $0x10,%esp
801064a0:	eb d6                	jmp    80106478 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801064a2:	83 ec 0c             	sub    $0xc,%esp
801064a5:	56                   	push   %esi
801064a6:	e8 f9 ba ff ff       	call   80101fa4 <kfree>
}
801064ab:	83 c4 10             	add    $0x10,%esp
801064ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064b1:	5b                   	pop    %ebx
801064b2:	5e                   	pop    %esi
801064b3:	5d                   	pop    %ebp
801064b4:	c3                   	ret    

801064b5 <setupkvm>:
{
801064b5:	55                   	push   %ebp
801064b6:	89 e5                	mov    %esp,%ebp
801064b8:	56                   	push   %esi
801064b9:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801064ba:	e8 fc bb ff ff       	call   801020bb <kalloc>
801064bf:	89 c6                	mov    %eax,%esi
801064c1:	85 c0                	test   %eax,%eax
801064c3:	74 55                	je     8010651a <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801064c5:	83 ec 04             	sub    $0x4,%esp
801064c8:	68 00 10 00 00       	push   $0x1000
801064cd:	6a 00                	push   $0x0
801064cf:	50                   	push   %eax
801064d0:	e8 df d9 ff ff       	call   80103eb4 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801064d5:	83 c4 10             	add    $0x10,%esp
801064d8:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801064dd:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801064e3:	73 35                	jae    8010651a <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801064e5:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801064e8:	8b 4b 08             	mov    0x8(%ebx),%ecx
801064eb:	29 c1                	sub    %eax,%ecx
801064ed:	83 ec 08             	sub    $0x8,%esp
801064f0:	ff 73 0c             	pushl  0xc(%ebx)
801064f3:	50                   	push   %eax
801064f4:	8b 13                	mov    (%ebx),%edx
801064f6:	89 f0                	mov    %esi,%eax
801064f8:	e8 d7 f9 ff ff       	call   80105ed4 <mappages>
801064fd:	83 c4 10             	add    $0x10,%esp
80106500:	85 c0                	test   %eax,%eax
80106502:	78 05                	js     80106509 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106504:	83 c3 10             	add    $0x10,%ebx
80106507:	eb d4                	jmp    801064dd <setupkvm+0x28>
      freevm(pgdir);
80106509:	83 ec 0c             	sub    $0xc,%esp
8010650c:	56                   	push   %esi
8010650d:	e8 33 ff ff ff       	call   80106445 <freevm>
      return 0;
80106512:	83 c4 10             	add    $0x10,%esp
80106515:	be 00 00 00 00       	mov    $0x0,%esi
}
8010651a:	89 f0                	mov    %esi,%eax
8010651c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010651f:	5b                   	pop    %ebx
80106520:	5e                   	pop    %esi
80106521:	5d                   	pop    %ebp
80106522:	c3                   	ret    

80106523 <kvmalloc>:
{
80106523:	55                   	push   %ebp
80106524:	89 e5                	mov    %esp,%ebp
80106526:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106529:	e8 87 ff ff ff       	call   801064b5 <setupkvm>
8010652e:	a3 c4 12 1c 80       	mov    %eax,0x801c12c4
  switchkvm();
80106533:	e8 5e fb ff ff       	call   80106096 <switchkvm>
}
80106538:	c9                   	leave  
80106539:	c3                   	ret    

8010653a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010653a:	55                   	push   %ebp
8010653b:	89 e5                	mov    %esp,%ebp
8010653d:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106540:	b9 00 00 00 00       	mov    $0x0,%ecx
80106545:	8b 55 0c             	mov    0xc(%ebp),%edx
80106548:	8b 45 08             	mov    0x8(%ebp),%eax
8010654b:	e8 14 f9 ff ff       	call   80105e64 <walkpgdir>
  if(pte == 0)
80106550:	85 c0                	test   %eax,%eax
80106552:	74 05                	je     80106559 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106554:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106557:	c9                   	leave  
80106558:	c3                   	ret    
    panic("clearpteu");
80106559:	83 ec 0c             	sub    $0xc,%esp
8010655c:	68 ae 70 10 80       	push   $0x801070ae
80106561:	e8 e2 9d ff ff       	call   80100348 <panic>

80106566 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106566:	55                   	push   %ebp
80106567:	89 e5                	mov    %esp,%ebp
80106569:	57                   	push   %edi
8010656a:	56                   	push   %esi
8010656b:	53                   	push   %ebx
8010656c:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010656f:	e8 41 ff ff ff       	call   801064b5 <setupkvm>
80106574:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106577:	85 c0                	test   %eax,%eax
80106579:	0f 84 c4 00 00 00    	je     80106643 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010657f:	bf 00 00 00 00       	mov    $0x0,%edi
80106584:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106587:	0f 83 b6 00 00 00    	jae    80106643 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010658d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106590:	b9 00 00 00 00       	mov    $0x0,%ecx
80106595:	89 fa                	mov    %edi,%edx
80106597:	8b 45 08             	mov    0x8(%ebp),%eax
8010659a:	e8 c5 f8 ff ff       	call   80105e64 <walkpgdir>
8010659f:	85 c0                	test   %eax,%eax
801065a1:	74 65                	je     80106608 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801065a3:	8b 00                	mov    (%eax),%eax
801065a5:	a8 01                	test   $0x1,%al
801065a7:	74 6c                	je     80106615 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801065a9:	89 c6                	mov    %eax,%esi
801065ab:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801065b1:	25 ff 0f 00 00       	and    $0xfff,%eax
801065b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801065b9:	e8 fd ba ff ff       	call   801020bb <kalloc>
801065be:	89 c3                	mov    %eax,%ebx
801065c0:	85 c0                	test   %eax,%eax
801065c2:	74 6a                	je     8010662e <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801065c4:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801065ca:	83 ec 04             	sub    $0x4,%esp
801065cd:	68 00 10 00 00       	push   $0x1000
801065d2:	56                   	push   %esi
801065d3:	50                   	push   %eax
801065d4:	e8 56 d9 ff ff       	call   80103f2f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801065d9:	83 c4 08             	add    $0x8,%esp
801065dc:	ff 75 e0             	pushl  -0x20(%ebp)
801065df:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801065e5:	50                   	push   %eax
801065e6:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801065ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065f1:	e8 de f8 ff ff       	call   80105ed4 <mappages>
801065f6:	83 c4 10             	add    $0x10,%esp
801065f9:	85 c0                	test   %eax,%eax
801065fb:	78 25                	js     80106622 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801065fd:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106603:	e9 7c ff ff ff       	jmp    80106584 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106608:	83 ec 0c             	sub    $0xc,%esp
8010660b:	68 b8 70 10 80       	push   $0x801070b8
80106610:	e8 33 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106615:	83 ec 0c             	sub    $0xc,%esp
80106618:	68 d2 70 10 80       	push   $0x801070d2
8010661d:	e8 26 9d ff ff       	call   80100348 <panic>
      kfree(mem);
80106622:	83 ec 0c             	sub    $0xc,%esp
80106625:	53                   	push   %ebx
80106626:	e8 79 b9 ff ff       	call   80101fa4 <kfree>
      goto bad;
8010662b:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010662e:	83 ec 0c             	sub    $0xc,%esp
80106631:	ff 75 dc             	pushl  -0x24(%ebp)
80106634:	e8 0c fe ff ff       	call   80106445 <freevm>
  return 0;
80106639:	83 c4 10             	add    $0x10,%esp
8010663c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106643:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106646:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106649:	5b                   	pop    %ebx
8010664a:	5e                   	pop    %esi
8010664b:	5f                   	pop    %edi
8010664c:	5d                   	pop    %ebp
8010664d:	c3                   	ret    

8010664e <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010664e:	55                   	push   %ebp
8010664f:	89 e5                	mov    %esp,%ebp
80106651:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106654:	b9 00 00 00 00       	mov    $0x0,%ecx
80106659:	8b 55 0c             	mov    0xc(%ebp),%edx
8010665c:	8b 45 08             	mov    0x8(%ebp),%eax
8010665f:	e8 00 f8 ff ff       	call   80105e64 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106664:	8b 00                	mov    (%eax),%eax
80106666:	a8 01                	test   $0x1,%al
80106668:	74 10                	je     8010667a <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010666a:	a8 04                	test   $0x4,%al
8010666c:	74 13                	je     80106681 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
8010666e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106673:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106678:	c9                   	leave  
80106679:	c3                   	ret    
    return 0;
8010667a:	b8 00 00 00 00       	mov    $0x0,%eax
8010667f:	eb f7                	jmp    80106678 <uva2ka+0x2a>
    return 0;
80106681:	b8 00 00 00 00       	mov    $0x0,%eax
80106686:	eb f0                	jmp    80106678 <uva2ka+0x2a>

80106688 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106688:	55                   	push   %ebp
80106689:	89 e5                	mov    %esp,%ebp
8010668b:	57                   	push   %edi
8010668c:	56                   	push   %esi
8010668d:	53                   	push   %ebx
8010668e:	83 ec 0c             	sub    $0xc,%esp
80106691:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106694:	eb 25                	jmp    801066bb <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106696:	8b 55 0c             	mov    0xc(%ebp),%edx
80106699:	29 f2                	sub    %esi,%edx
8010669b:	01 d0                	add    %edx,%eax
8010669d:	83 ec 04             	sub    $0x4,%esp
801066a0:	53                   	push   %ebx
801066a1:	ff 75 10             	pushl  0x10(%ebp)
801066a4:	50                   	push   %eax
801066a5:	e8 85 d8 ff ff       	call   80103f2f <memmove>
    len -= n;
801066aa:	29 df                	sub    %ebx,%edi
    buf += n;
801066ac:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801066af:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801066b5:	89 45 0c             	mov    %eax,0xc(%ebp)
801066b8:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801066bb:	85 ff                	test   %edi,%edi
801066bd:	74 2f                	je     801066ee <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801066bf:	8b 75 0c             	mov    0xc(%ebp),%esi
801066c2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801066c8:	83 ec 08             	sub    $0x8,%esp
801066cb:	56                   	push   %esi
801066cc:	ff 75 08             	pushl  0x8(%ebp)
801066cf:	e8 7a ff ff ff       	call   8010664e <uva2ka>
    if(pa0 == 0)
801066d4:	83 c4 10             	add    $0x10,%esp
801066d7:	85 c0                	test   %eax,%eax
801066d9:	74 20                	je     801066fb <copyout+0x73>
    n = PGSIZE - (va - va0);
801066db:	89 f3                	mov    %esi,%ebx
801066dd:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801066e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801066e6:	39 df                	cmp    %ebx,%edi
801066e8:	73 ac                	jae    80106696 <copyout+0xe>
      n = len;
801066ea:	89 fb                	mov    %edi,%ebx
801066ec:	eb a8                	jmp    80106696 <copyout+0xe>
  }
  return 0;
801066ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066f6:	5b                   	pop    %ebx
801066f7:	5e                   	pop    %esi
801066f8:	5f                   	pop    %edi
801066f9:	5d                   	pop    %ebp
801066fa:	c3                   	ret    
      return -1;
801066fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106700:	eb f1                	jmp    801066f3 <copyout+0x6b>
