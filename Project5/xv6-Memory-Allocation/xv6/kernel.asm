
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
8010002d:	b8 a4 2d 10 80       	mov    $0x80102da4,%eax
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
80100046:	e8 35 3f 00 00       	call   80103f80 <acquire>

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
8010007c:	e8 64 3f 00 00       	call   80103fe5 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 e0 3c 00 00       	call   80103d6c <acquiresleep>
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
801000ca:	e8 16 3f 00 00       	call   80103fe5 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 92 3c 00 00       	call   80103d6c <acquiresleep>
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
801000ea:	68 00 69 10 80       	push   $0x80106900
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 11 69 10 80       	push   $0x80106911
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 3a 3d 00 00       	call   80103e44 <initlock>
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
8010013a:	68 18 69 10 80       	push   $0x80106918
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 f1 3b 00 00       	call   80103d39 <initsleeplock>
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
80100190:	e8 8b 1c 00 00       	call   80101e20 <iderw>
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
801001a8:	e8 49 3c 00 00       	call   80103df6 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 60 1c 00 00       	call   80101e20 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 1f 69 10 80       	push   $0x8010691f
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
801001e4:	e8 0d 3c 00 00       	call   80103df6 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 c2 3b 00 00       	call   80103dbb <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 7b 3d 00 00       	call   80103f80 <acquire>
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
8010024c:	e8 94 3d 00 00       	call   80103fe5 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 26 69 10 80       	push   $0x80106926
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
8010027b:	e8 d7 13 00 00       	call   80101657 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028a:	e8 f1 3c 00 00       	call   80103f80 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 ba 32 00 00       	call   80103566 <myproc>
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
801002bf:	e8 5a 37 00 00       	call   80103a1e <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 0f 3d 00 00       	call   80103fe5 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 b7 12 00 00       	call   80101595 <ilock>
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
80100331:	e8 af 3c 00 00       	call   80103fe5 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 57 12 00 00       	call   80101595 <ilock>
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
8010035a:	e8 5f 23 00 00       	call   801026be <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 2d 69 10 80       	push   $0x8010692d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 7b 72 10 80 	movl   $0x8010727b,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 cb 3a 00 00       	call   80103e5f <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 41 69 10 80       	push   $0x80106941
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
8010049e:	68 45 69 10 80       	push   $0x80106945
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 e8 3b 00 00       	call   801040a7 <memmove>
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
801004d9:	e8 4e 3b 00 00       	call   8010402c <memset>
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
80100506:	e8 62 4f 00 00       	call   8010546d <uartputc>
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
8010051f:	e8 49 4f 00 00       	call   8010546d <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 3d 4f 00 00       	call   8010546d <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 31 4f 00 00       	call   8010546d <uartputc>
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
80100576:	0f b6 92 70 69 10 80 	movzbl -0x7fef9690(%edx),%edx
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
801005be:	e8 94 10 00 00       	call   80101657 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ca:	e8 b1 39 00 00       	call   80103f80 <acquire>
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
801005f1:	e8 ef 39 00 00       	call   80103fe5 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 94 0f 00 00       	call   80101595 <ilock>

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
80100638:	e8 43 39 00 00       	call   80103f80 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 5f 69 10 80       	push   $0x8010695f
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
801006ee:	be 58 69 10 80       	mov    $0x80106958,%esi
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
80100734:	e8 ac 38 00 00       	call   80103fe5 <release>
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
8010074f:	e8 2c 38 00 00       	call   80103f80 <acquire>
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
801007de:	e8 a0 33 00 00       	call   80103b83 <wakeup>
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
80100873:	e8 6d 37 00 00       	call   80103fe5 <release>
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
80100887:	e8 94 33 00 00       	call   80103c20 <procdump>
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
80100894:	68 68 69 10 80       	push   $0x80106968
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 a1 35 00 00       	call   80103e44 <initlock>

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
801008c8:	e8 c5 16 00 00       	call   80101f92 <ioapicenable>
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
801008de:	e8 83 2c 00 00       	call   80103566 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 00 22 00 00       	call   80102aee <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 fc 12 00 00       	call   80101bf5 <namei>
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
80100906:	e8 8a 0c 00 00       	call   80101595 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 6b 0e 00 00       	call   80101787 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 f1 02 00 00    	je     80100c1d <exec+0x34b>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 07 0e 00 00       	call   8010173c <iunlockput>
    end_op();
80100935:	e8 2e 22 00 00       	call   80102b68 <end_op>
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
8010094a:	e8 19 22 00 00       	call   80102b68 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 81 69 10 80       	push   $0x80106981
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm(0)) == 0)
80100972:	83 ec 0c             	sub    $0xc,%esp
80100975:	6a 00                	push   $0x0
80100977:	e8 e8 5c 00 00       	call   80106664 <setupkvm>
8010097c:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100982:	83 c4 10             	add    $0x10,%esp
80100985:	85 c0                	test   %eax,%eax
80100987:	0f 84 12 01 00 00    	je     80100a9f <exec+0x1cd>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
8010098d:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
80100993:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100998:	be 00 00 00 00       	mov    $0x0,%esi
8010099d:	eb 0c                	jmp    801009ab <exec+0xd9>
8010099f:	83 c6 01             	add    $0x1,%esi
801009a2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a8:	83 c0 20             	add    $0x20,%eax
801009ab:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009b2:	39 f2                	cmp    %esi,%edx
801009b4:	0f 8e 9e 00 00 00    	jle    80100a58 <exec+0x186>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009ba:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009c0:	6a 20                	push   $0x20
801009c2:	50                   	push   %eax
801009c3:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c9:	50                   	push   %eax
801009ca:	53                   	push   %ebx
801009cb:	e8 b7 0d 00 00       	call   80101787 <readi>
801009d0:	83 c4 10             	add    $0x10,%esp
801009d3:	83 f8 20             	cmp    $0x20,%eax
801009d6:	0f 85 c3 00 00 00    	jne    80100a9f <exec+0x1cd>
    if(ph.type != ELF_PROG_LOAD)
801009dc:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009e3:	75 ba                	jne    8010099f <exec+0xcd>
    if(ph.memsz < ph.filesz)
801009e5:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009eb:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009f1:	0f 82 a8 00 00 00    	jb     80100a9f <exec+0x1cd>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009f7:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009fd:	0f 82 9c 00 00 00    	jb     80100a9f <exec+0x1cd>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz, curproc->pid)) == 0)
80100a03:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a09:	ff 71 10             	pushl  0x10(%ecx)
80100a0c:	50                   	push   %eax
80100a0d:	57                   	push   %edi
80100a0e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a14:	e8 d1 5a 00 00       	call   801064ea <allocuvm>
80100a19:	89 c7                	mov    %eax,%edi
80100a1b:	83 c4 10             	add    $0x10,%esp
80100a1e:	85 c0                	test   %eax,%eax
80100a20:	74 7d                	je     80100a9f <exec+0x1cd>
    if(ph.vaddr % PGSIZE != 0)
80100a22:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a28:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a2d:	75 70                	jne    80100a9f <exec+0x1cd>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a2f:	83 ec 0c             	sub    $0xc,%esp
80100a32:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a38:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a3e:	53                   	push   %ebx
80100a3f:	50                   	push   %eax
80100a40:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a46:	e8 6d 59 00 00       	call   801063b8 <loaduvm>
80100a4b:	83 c4 20             	add    $0x20,%esp
80100a4e:	85 c0                	test   %eax,%eax
80100a50:	0f 89 49 ff ff ff    	jns    8010099f <exec+0xcd>
 bad:
80100a56:	eb 47                	jmp    80100a9f <exec+0x1cd>
  iunlockput(ip);
80100a58:	83 ec 0c             	sub    $0xc,%esp
80100a5b:	53                   	push   %ebx
80100a5c:	e8 db 0c 00 00       	call   8010173c <iunlockput>
  end_op();
80100a61:	e8 02 21 00 00       	call   80102b68 <end_op>
  sz = PGROUNDUP(sz);
80100a66:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE, curproc->pid)) == 0)
80100a71:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a77:	ff 71 10             	pushl  0x10(%ecx)
80100a7a:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a80:	52                   	push   %edx
80100a81:	50                   	push   %eax
80100a82:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a88:	e8 5d 5a 00 00       	call   801064ea <allocuvm>
80100a8d:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a93:	83 c4 20             	add    $0x20,%esp
80100a96:	85 c0                	test   %eax,%eax
80100a98:	75 24                	jne    80100abe <exec+0x1ec>
  ip = 0;
80100a9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a9f:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100aa5:	85 c0                	test   %eax,%eax
80100aa7:	0f 84 77 fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100aad:	83 ec 0c             	sub    $0xc,%esp
80100ab0:	50                   	push   %eax
80100ab1:	e8 3e 5b 00 00       	call   801065f4 <freevm>
80100ab6:	83 c4 10             	add    $0x10,%esp
80100ab9:	e9 66 fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100abe:	89 c7                	mov    %eax,%edi
80100ac0:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ac6:	83 ec 08             	sub    $0x8,%esp
80100ac9:	50                   	push   %eax
80100aca:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100ad0:	e8 34 5c 00 00       	call   80106709 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ad5:	83 c4 10             	add    $0x10,%esp
80100ad8:	be 00 00 00 00       	mov    $0x0,%esi
80100add:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ae0:	8d 1c b0             	lea    (%eax,%esi,4),%ebx
80100ae3:	8b 03                	mov    (%ebx),%eax
80100ae5:	85 c0                	test   %eax,%eax
80100ae7:	74 4d                	je     80100b36 <exec+0x264>
    if(argc >= MAXARG)
80100ae9:	83 fe 1f             	cmp    $0x1f,%esi
80100aec:	0f 87 0d 01 00 00    	ja     80100bff <exec+0x32d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100af2:	83 ec 0c             	sub    $0xc,%esp
80100af5:	50                   	push   %eax
80100af6:	e8 d3 36 00 00       	call   801041ce <strlen>
80100afb:	29 c7                	sub    %eax,%edi
80100afd:	83 ef 01             	sub    $0x1,%edi
80100b00:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b03:	83 c4 04             	add    $0x4,%esp
80100b06:	ff 33                	pushl  (%ebx)
80100b08:	e8 c1 36 00 00       	call   801041ce <strlen>
80100b0d:	83 c0 01             	add    $0x1,%eax
80100b10:	50                   	push   %eax
80100b11:	ff 33                	pushl  (%ebx)
80100b13:	57                   	push   %edi
80100b14:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b1a:	e8 62 5d 00 00       	call   80106881 <copyout>
80100b1f:	83 c4 20             	add    $0x20,%esp
80100b22:	85 c0                	test   %eax,%eax
80100b24:	0f 88 df 00 00 00    	js     80100c09 <exec+0x337>
    ustack[3+argc] = sp;
80100b2a:	89 bc b5 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%esi,4)
  for(argc = 0; argv[argc]; argc++) {
80100b31:	83 c6 01             	add    $0x1,%esi
80100b34:	eb a7                	jmp    80100add <exec+0x20b>
  ustack[3+argc] = 0;
80100b36:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80100b3d:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b41:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b48:	ff ff ff 
  ustack[1] = argc;
80100b4b:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b51:	8d 04 b5 04 00 00 00 	lea    0x4(,%esi,4),%eax
80100b58:	89 f9                	mov    %edi,%ecx
80100b5a:	29 c1                	sub    %eax,%ecx
80100b5c:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b62:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
80100b69:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b6b:	50                   	push   %eax
80100b6c:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b72:	50                   	push   %eax
80100b73:	57                   	push   %edi
80100b74:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b7a:	e8 02 5d 00 00       	call   80106881 <copyout>
80100b7f:	83 c4 10             	add    $0x10,%esp
80100b82:	85 c0                	test   %eax,%eax
80100b84:	0f 88 89 00 00 00    	js     80100c13 <exec+0x341>
  for(last=s=path; *s; s++)
80100b8a:	8b 55 08             	mov    0x8(%ebp),%edx
80100b8d:	89 d0                	mov    %edx,%eax
80100b8f:	eb 03                	jmp    80100b94 <exec+0x2c2>
80100b91:	83 c0 01             	add    $0x1,%eax
80100b94:	0f b6 08             	movzbl (%eax),%ecx
80100b97:	84 c9                	test   %cl,%cl
80100b99:	74 0a                	je     80100ba5 <exec+0x2d3>
    if(*s == '/')
80100b9b:	80 f9 2f             	cmp    $0x2f,%cl
80100b9e:	75 f1                	jne    80100b91 <exec+0x2bf>
      last = s+1;
80100ba0:	8d 50 01             	lea    0x1(%eax),%edx
80100ba3:	eb ec                	jmp    80100b91 <exec+0x2bf>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ba5:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100bab:	89 f0                	mov    %esi,%eax
80100bad:	83 c0 6c             	add    $0x6c,%eax
80100bb0:	83 ec 04             	sub    $0x4,%esp
80100bb3:	6a 10                	push   $0x10
80100bb5:	52                   	push   %edx
80100bb6:	50                   	push   %eax
80100bb7:	e8 d7 35 00 00       	call   80104193 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bbc:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bbf:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bc5:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bc8:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bce:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bd0:	8b 46 18             	mov    0x18(%esi),%eax
80100bd3:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bd9:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bdc:	8b 46 18             	mov    0x18(%esi),%eax
80100bdf:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100be2:	89 34 24             	mov    %esi,(%esp)
80100be5:	e8 36 56 00 00       	call   80106220 <switchuvm>
  freevm(oldpgdir);
80100bea:	89 1c 24             	mov    %ebx,(%esp)
80100bed:	e8 02 5a 00 00       	call   801065f4 <freevm>
  return 0;
80100bf2:	83 c4 10             	add    $0x10,%esp
80100bf5:	b8 00 00 00 00       	mov    $0x0,%eax
80100bfa:	e9 43 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 96 fe ff ff       	jmp    80100a9f <exec+0x1cd>
80100c09:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c0e:	e9 8c fe ff ff       	jmp    80100a9f <exec+0x1cd>
80100c13:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c18:	e9 82 fe ff ff       	jmp    80100a9f <exec+0x1cd>
  return -1;
80100c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c22:	e9 1b fd ff ff       	jmp    80100942 <exec+0x70>

80100c27 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c27:	55                   	push   %ebp
80100c28:	89 e5                	mov    %esp,%ebp
80100c2a:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c2d:	68 8d 69 10 80       	push   $0x8010698d
80100c32:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c37:	e8 08 32 00 00       	call   80103e44 <initlock>
}
80100c3c:	83 c4 10             	add    $0x10,%esp
80100c3f:	c9                   	leave  
80100c40:	c3                   	ret    

80100c41 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c41:	55                   	push   %ebp
80100c42:	89 e5                	mov    %esp,%ebp
80100c44:	53                   	push   %ebx
80100c45:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c48:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c4d:	e8 2e 33 00 00       	call   80103f80 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c52:	83 c4 10             	add    $0x10,%esp
80100c55:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
80100c5a:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100c60:	73 29                	jae    80100c8b <filealloc+0x4a>
    if(f->ref == 0){
80100c62:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c66:	74 05                	je     80100c6d <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c68:	83 c3 18             	add    $0x18,%ebx
80100c6b:	eb ed                	jmp    80100c5a <filealloc+0x19>
      f->ref = 1;
80100c6d:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c74:	83 ec 0c             	sub    $0xc,%esp
80100c77:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c7c:	e8 64 33 00 00       	call   80103fe5 <release>
      return f;
80100c81:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c84:	89 d8                	mov    %ebx,%eax
80100c86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c89:	c9                   	leave  
80100c8a:	c3                   	ret    
  release(&ftable.lock);
80100c8b:	83 ec 0c             	sub    $0xc,%esp
80100c8e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c93:	e8 4d 33 00 00       	call   80103fe5 <release>
  return 0;
80100c98:	83 c4 10             	add    $0x10,%esp
80100c9b:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ca0:	eb e2                	jmp    80100c84 <filealloc+0x43>

80100ca2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100ca2:	55                   	push   %ebp
80100ca3:	89 e5                	mov    %esp,%ebp
80100ca5:	53                   	push   %ebx
80100ca6:	83 ec 10             	sub    $0x10,%esp
80100ca9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100cac:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cb1:	e8 ca 32 00 00       	call   80103f80 <acquire>
  if(f->ref < 1)
80100cb6:	8b 43 04             	mov    0x4(%ebx),%eax
80100cb9:	83 c4 10             	add    $0x10,%esp
80100cbc:	85 c0                	test   %eax,%eax
80100cbe:	7e 1a                	jle    80100cda <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cc0:	83 c0 01             	add    $0x1,%eax
80100cc3:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cce:	e8 12 33 00 00       	call   80103fe5 <release>
  return f;
}
80100cd3:	89 d8                	mov    %ebx,%eax
80100cd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cd8:	c9                   	leave  
80100cd9:	c3                   	ret    
    panic("filedup");
80100cda:	83 ec 0c             	sub    $0xc,%esp
80100cdd:	68 94 69 10 80       	push   $0x80106994
80100ce2:	e8 61 f6 ff ff       	call   80100348 <panic>

80100ce7 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100ce7:	55                   	push   %ebp
80100ce8:	89 e5                	mov    %esp,%ebp
80100cea:	53                   	push   %ebx
80100ceb:	83 ec 30             	sub    $0x30,%esp
80100cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cf1:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cf6:	e8 85 32 00 00       	call   80103f80 <acquire>
  if(f->ref < 1)
80100cfb:	8b 43 04             	mov    0x4(%ebx),%eax
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	85 c0                	test   %eax,%eax
80100d03:	7e 1f                	jle    80100d24 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100d05:	83 e8 01             	sub    $0x1,%eax
80100d08:	89 43 04             	mov    %eax,0x4(%ebx)
80100d0b:	85 c0                	test   %eax,%eax
80100d0d:	7e 22                	jle    80100d31 <fileclose+0x4a>
    release(&ftable.lock);
80100d0f:	83 ec 0c             	sub    $0xc,%esp
80100d12:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d17:	e8 c9 32 00 00       	call   80103fe5 <release>
    return;
80100d1c:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d22:	c9                   	leave  
80100d23:	c3                   	ret    
    panic("fileclose");
80100d24:	83 ec 0c             	sub    $0xc,%esp
80100d27:	68 9c 69 10 80       	push   $0x8010699c
80100d2c:	e8 17 f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d31:	8b 03                	mov    (%ebx),%eax
80100d33:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d36:	8b 43 08             	mov    0x8(%ebx),%eax
80100d39:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d3c:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d42:	8b 43 10             	mov    0x10(%ebx),%eax
80100d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d48:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d4f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d55:	83 ec 0c             	sub    $0xc,%esp
80100d58:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d5d:	e8 83 32 00 00       	call   80103fe5 <release>
  if(ff.type == FD_PIPE)
80100d62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d65:	83 c4 10             	add    $0x10,%esp
80100d68:	83 f8 01             	cmp    $0x1,%eax
80100d6b:	74 1f                	je     80100d8c <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d6d:	83 f8 02             	cmp    $0x2,%eax
80100d70:	75 ad                	jne    80100d1f <fileclose+0x38>
    begin_op();
80100d72:	e8 77 1d 00 00       	call   80102aee <begin_op>
    iput(ff.ip);
80100d77:	83 ec 0c             	sub    $0xc,%esp
80100d7a:	ff 75 f0             	pushl  -0x10(%ebp)
80100d7d:	e8 1a 09 00 00       	call   8010169c <iput>
    end_op();
80100d82:	e8 e1 1d 00 00       	call   80102b68 <end_op>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	eb 93                	jmp    80100d1f <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d8c:	83 ec 08             	sub    $0x8,%esp
80100d8f:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d93:	50                   	push   %eax
80100d94:	ff 75 ec             	pushl  -0x14(%ebp)
80100d97:	e8 c6 23 00 00       	call   80103162 <pipeclose>
80100d9c:	83 c4 10             	add    $0x10,%esp
80100d9f:	e9 7b ff ff ff       	jmp    80100d1f <fileclose+0x38>

80100da4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100da4:	55                   	push   %ebp
80100da5:	89 e5                	mov    %esp,%ebp
80100da7:	53                   	push   %ebx
80100da8:	83 ec 04             	sub    $0x4,%esp
80100dab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dae:	83 3b 02             	cmpl   $0x2,(%ebx)
80100db1:	75 31                	jne    80100de4 <filestat+0x40>
    ilock(f->ip);
80100db3:	83 ec 0c             	sub    $0xc,%esp
80100db6:	ff 73 10             	pushl  0x10(%ebx)
80100db9:	e8 d7 07 00 00       	call   80101595 <ilock>
    stati(f->ip, st);
80100dbe:	83 c4 08             	add    $0x8,%esp
80100dc1:	ff 75 0c             	pushl  0xc(%ebp)
80100dc4:	ff 73 10             	pushl  0x10(%ebx)
80100dc7:	e8 90 09 00 00       	call   8010175c <stati>
    iunlock(f->ip);
80100dcc:	83 c4 04             	add    $0x4,%esp
80100dcf:	ff 73 10             	pushl  0x10(%ebx)
80100dd2:	e8 80 08 00 00       	call   80101657 <iunlock>
    return 0;
80100dd7:	83 c4 10             	add    $0x10,%esp
80100dda:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100ddf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100de2:	c9                   	leave  
80100de3:	c3                   	ret    
  return -1;
80100de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100de9:	eb f4                	jmp    80100ddf <filestat+0x3b>

80100deb <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100deb:	55                   	push   %ebp
80100dec:	89 e5                	mov    %esp,%ebp
80100dee:	56                   	push   %esi
80100def:	53                   	push   %ebx
80100df0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100df3:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100df7:	74 70                	je     80100e69 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100df9:	8b 03                	mov    (%ebx),%eax
80100dfb:	83 f8 01             	cmp    $0x1,%eax
80100dfe:	74 44                	je     80100e44 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e00:	83 f8 02             	cmp    $0x2,%eax
80100e03:	75 57                	jne    80100e5c <fileread+0x71>
    ilock(f->ip);
80100e05:	83 ec 0c             	sub    $0xc,%esp
80100e08:	ff 73 10             	pushl  0x10(%ebx)
80100e0b:	e8 85 07 00 00       	call   80101595 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e10:	ff 75 10             	pushl  0x10(%ebp)
80100e13:	ff 73 14             	pushl  0x14(%ebx)
80100e16:	ff 75 0c             	pushl  0xc(%ebp)
80100e19:	ff 73 10             	pushl  0x10(%ebx)
80100e1c:	e8 66 09 00 00       	call   80101787 <readi>
80100e21:	89 c6                	mov    %eax,%esi
80100e23:	83 c4 20             	add    $0x20,%esp
80100e26:	85 c0                	test   %eax,%eax
80100e28:	7e 03                	jle    80100e2d <fileread+0x42>
      f->off += r;
80100e2a:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e2d:	83 ec 0c             	sub    $0xc,%esp
80100e30:	ff 73 10             	pushl  0x10(%ebx)
80100e33:	e8 1f 08 00 00       	call   80101657 <iunlock>
    return r;
80100e38:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e3b:	89 f0                	mov    %esi,%eax
80100e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e40:	5b                   	pop    %ebx
80100e41:	5e                   	pop    %esi
80100e42:	5d                   	pop    %ebp
80100e43:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e44:	83 ec 04             	sub    $0x4,%esp
80100e47:	ff 75 10             	pushl  0x10(%ebp)
80100e4a:	ff 75 0c             	pushl  0xc(%ebp)
80100e4d:	ff 73 0c             	pushl  0xc(%ebx)
80100e50:	e8 65 24 00 00       	call   801032ba <piperead>
80100e55:	89 c6                	mov    %eax,%esi
80100e57:	83 c4 10             	add    $0x10,%esp
80100e5a:	eb df                	jmp    80100e3b <fileread+0x50>
  panic("fileread");
80100e5c:	83 ec 0c             	sub    $0xc,%esp
80100e5f:	68 a6 69 10 80       	push   $0x801069a6
80100e64:	e8 df f4 ff ff       	call   80100348 <panic>
    return -1;
80100e69:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e6e:	eb cb                	jmp    80100e3b <fileread+0x50>

80100e70 <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e70:	55                   	push   %ebp
80100e71:	89 e5                	mov    %esp,%ebp
80100e73:	57                   	push   %edi
80100e74:	56                   	push   %esi
80100e75:	53                   	push   %ebx
80100e76:	83 ec 1c             	sub    $0x1c,%esp
80100e79:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e7c:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e80:	0f 84 c5 00 00 00    	je     80100f4b <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e86:	8b 03                	mov    (%ebx),%eax
80100e88:	83 f8 01             	cmp    $0x1,%eax
80100e8b:	74 10                	je     80100e9d <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e8d:	83 f8 02             	cmp    $0x2,%eax
80100e90:	0f 85 a8 00 00 00    	jne    80100f3e <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e96:	bf 00 00 00 00       	mov    $0x0,%edi
80100e9b:	eb 67                	jmp    80100f04 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e9d:	83 ec 04             	sub    $0x4,%esp
80100ea0:	ff 75 10             	pushl  0x10(%ebp)
80100ea3:	ff 75 0c             	pushl  0xc(%ebp)
80100ea6:	ff 73 0c             	pushl  0xc(%ebx)
80100ea9:	e8 40 23 00 00       	call   801031ee <pipewrite>
80100eae:	83 c4 10             	add    $0x10,%esp
80100eb1:	e9 80 00 00 00       	jmp    80100f36 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100eb6:	e8 33 1c 00 00       	call   80102aee <begin_op>
      ilock(f->ip);
80100ebb:	83 ec 0c             	sub    $0xc,%esp
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 cf 06 00 00       	call   80101595 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ec6:	89 f8                	mov    %edi,%eax
80100ec8:	03 45 0c             	add    0xc(%ebp),%eax
80100ecb:	ff 75 e4             	pushl  -0x1c(%ebp)
80100ece:	ff 73 14             	pushl  0x14(%ebx)
80100ed1:	50                   	push   %eax
80100ed2:	ff 73 10             	pushl  0x10(%ebx)
80100ed5:	e8 aa 09 00 00       	call   80101884 <writei>
80100eda:	89 c6                	mov    %eax,%esi
80100edc:	83 c4 20             	add    $0x20,%esp
80100edf:	85 c0                	test   %eax,%eax
80100ee1:	7e 03                	jle    80100ee6 <filewrite+0x76>
        f->off += r;
80100ee3:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ee6:	83 ec 0c             	sub    $0xc,%esp
80100ee9:	ff 73 10             	pushl  0x10(%ebx)
80100eec:	e8 66 07 00 00       	call   80101657 <iunlock>
      end_op();
80100ef1:	e8 72 1c 00 00       	call   80102b68 <end_op>

      if(r < 0)
80100ef6:	83 c4 10             	add    $0x10,%esp
80100ef9:	85 f6                	test   %esi,%esi
80100efb:	78 31                	js     80100f2e <filewrite+0xbe>
        break;
      if(r != n1)
80100efd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100f00:	75 1f                	jne    80100f21 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100f02:	01 f7                	add    %esi,%edi
    while(i < n){
80100f04:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f07:	7d 25                	jge    80100f2e <filewrite+0xbe>
      int n1 = n - i;
80100f09:	8b 45 10             	mov    0x10(%ebp),%eax
80100f0c:	29 f8                	sub    %edi,%eax
80100f0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100f11:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f16:	7e 9e                	jle    80100eb6 <filewrite+0x46>
        n1 = max;
80100f18:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f1f:	eb 95                	jmp    80100eb6 <filewrite+0x46>
        panic("short filewrite");
80100f21:	83 ec 0c             	sub    $0xc,%esp
80100f24:	68 af 69 10 80       	push   $0x801069af
80100f29:	e8 1a f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f2e:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f31:	75 1f                	jne    80100f52 <filewrite+0xe2>
80100f33:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f36:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f39:	5b                   	pop    %ebx
80100f3a:	5e                   	pop    %esi
80100f3b:	5f                   	pop    %edi
80100f3c:	5d                   	pop    %ebp
80100f3d:	c3                   	ret    
  panic("filewrite");
80100f3e:	83 ec 0c             	sub    $0xc,%esp
80100f41:	68 b5 69 10 80       	push   $0x801069b5
80100f46:	e8 fd f3 ff ff       	call   80100348 <panic>
    return -1;
80100f4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f50:	eb e4                	jmp    80100f36 <filewrite+0xc6>
    return i == n ? n : -1;
80100f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f57:	eb dd                	jmp    80100f36 <filewrite+0xc6>

80100f59 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f59:	55                   	push   %ebp
80100f5a:	89 e5                	mov    %esp,%ebp
80100f5c:	57                   	push   %edi
80100f5d:	56                   	push   %esi
80100f5e:	53                   	push   %ebx
80100f5f:	83 ec 0c             	sub    $0xc,%esp
80100f62:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f64:	eb 03                	jmp    80100f69 <skipelem+0x10>
    path++;
80100f66:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f69:	0f b6 10             	movzbl (%eax),%edx
80100f6c:	80 fa 2f             	cmp    $0x2f,%dl
80100f6f:	74 f5                	je     80100f66 <skipelem+0xd>
  if(*path == 0)
80100f71:	84 d2                	test   %dl,%dl
80100f73:	74 59                	je     80100fce <skipelem+0x75>
80100f75:	89 c3                	mov    %eax,%ebx
80100f77:	eb 03                	jmp    80100f7c <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f79:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f7c:	0f b6 13             	movzbl (%ebx),%edx
80100f7f:	80 fa 2f             	cmp    $0x2f,%dl
80100f82:	0f 95 c1             	setne  %cl
80100f85:	84 d2                	test   %dl,%dl
80100f87:	0f 95 c2             	setne  %dl
80100f8a:	84 d1                	test   %dl,%cl
80100f8c:	75 eb                	jne    80100f79 <skipelem+0x20>
  len = path - s;
80100f8e:	89 de                	mov    %ebx,%esi
80100f90:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f92:	83 fe 0d             	cmp    $0xd,%esi
80100f95:	7e 11                	jle    80100fa8 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f97:	83 ec 04             	sub    $0x4,%esp
80100f9a:	6a 0e                	push   $0xe
80100f9c:	50                   	push   %eax
80100f9d:	57                   	push   %edi
80100f9e:	e8 04 31 00 00       	call   801040a7 <memmove>
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 17                	jmp    80100fbf <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fa8:	83 ec 04             	sub    $0x4,%esp
80100fab:	56                   	push   %esi
80100fac:	50                   	push   %eax
80100fad:	57                   	push   %edi
80100fae:	e8 f4 30 00 00       	call   801040a7 <memmove>
    name[len] = 0;
80100fb3:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fb7:	83 c4 10             	add    $0x10,%esp
80100fba:	eb 03                	jmp    80100fbf <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fbc:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fbf:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fc2:	74 f8                	je     80100fbc <skipelem+0x63>
  return path;
}
80100fc4:	89 d8                	mov    %ebx,%eax
80100fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc9:	5b                   	pop    %ebx
80100fca:	5e                   	pop    %esi
80100fcb:	5f                   	pop    %edi
80100fcc:	5d                   	pop    %ebp
80100fcd:	c3                   	ret    
    return 0;
80100fce:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fd3:	eb ef                	jmp    80100fc4 <skipelem+0x6b>

80100fd5 <bzero>:
{
80100fd5:	55                   	push   %ebp
80100fd6:	89 e5                	mov    %esp,%ebp
80100fd8:	53                   	push   %ebx
80100fd9:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fdc:	52                   	push   %edx
80100fdd:	50                   	push   %eax
80100fde:	e8 89 f1 ff ff       	call   8010016c <bread>
80100fe3:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fe5:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fe8:	83 c4 0c             	add    $0xc,%esp
80100feb:	68 00 02 00 00       	push   $0x200
80100ff0:	6a 00                	push   $0x0
80100ff2:	50                   	push   %eax
80100ff3:	e8 34 30 00 00       	call   8010402c <memset>
  log_write(bp);
80100ff8:	89 1c 24             	mov    %ebx,(%esp)
80100ffb:	e8 17 1c 00 00       	call   80102c17 <log_write>
  brelse(bp);
80101000:	89 1c 24             	mov    %ebx,(%esp)
80101003:	e8 cd f1 ff ff       	call   801001d5 <brelse>
}
80101008:	83 c4 10             	add    $0x10,%esp
8010100b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010100e:	c9                   	leave  
8010100f:	c3                   	ret    

80101010 <balloc>:
{
80101010:	55                   	push   %ebp
80101011:	89 e5                	mov    %esp,%ebp
80101013:	57                   	push   %edi
80101014:	56                   	push   %esi
80101015:	53                   	push   %ebx
80101016:	83 ec 1c             	sub    $0x1c,%esp
80101019:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010101c:	be 00 00 00 00       	mov    $0x0,%esi
80101021:	eb 14                	jmp    80101037 <balloc+0x27>
    brelse(bp);
80101023:	83 ec 0c             	sub    $0xc,%esp
80101026:	ff 75 e4             	pushl  -0x1c(%ebp)
80101029:	e8 a7 f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010102e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101034:	83 c4 10             	add    $0x10,%esp
80101037:	39 35 c0 09 11 80    	cmp    %esi,0x801109c0
8010103d:	76 75                	jbe    801010b4 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010103f:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101045:	85 f6                	test   %esi,%esi
80101047:	0f 49 c6             	cmovns %esi,%eax
8010104a:	c1 f8 0c             	sar    $0xc,%eax
8010104d:	03 05 d8 09 11 80    	add    0x801109d8,%eax
80101053:	83 ec 08             	sub    $0x8,%esp
80101056:	50                   	push   %eax
80101057:	ff 75 d8             	pushl  -0x28(%ebp)
8010105a:	e8 0d f1 ff ff       	call   8010016c <bread>
8010105f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101062:	83 c4 10             	add    $0x10,%esp
80101065:	b8 00 00 00 00       	mov    $0x0,%eax
8010106a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010106f:	7f b2                	jg     80101023 <balloc+0x13>
80101071:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80101074:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101077:	3b 1d c0 09 11 80    	cmp    0x801109c0,%ebx
8010107d:	73 a4                	jae    80101023 <balloc+0x13>
      m = 1 << (bi % 8);
8010107f:	99                   	cltd   
80101080:	c1 ea 1d             	shr    $0x1d,%edx
80101083:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101086:	83 e1 07             	and    $0x7,%ecx
80101089:	29 d1                	sub    %edx,%ecx
8010108b:	ba 01 00 00 00       	mov    $0x1,%edx
80101090:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101092:	8d 48 07             	lea    0x7(%eax),%ecx
80101095:	85 c0                	test   %eax,%eax
80101097:	0f 49 c8             	cmovns %eax,%ecx
8010109a:	c1 f9 03             	sar    $0x3,%ecx
8010109d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801010a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801010a3:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
801010a8:	0f b6 f9             	movzbl %cl,%edi
801010ab:	85 d7                	test   %edx,%edi
801010ad:	74 12                	je     801010c1 <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010af:	83 c0 01             	add    $0x1,%eax
801010b2:	eb b6                	jmp    8010106a <balloc+0x5a>
  panic("balloc: out of blocks");
801010b4:	83 ec 0c             	sub    $0xc,%esp
801010b7:	68 bf 69 10 80       	push   $0x801069bf
801010bc:	e8 87 f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010c1:	09 ca                	or     %ecx,%edx
801010c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010c6:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010c9:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010cd:	83 ec 0c             	sub    $0xc,%esp
801010d0:	89 c6                	mov    %eax,%esi
801010d2:	50                   	push   %eax
801010d3:	e8 3f 1b 00 00       	call   80102c17 <log_write>
        brelse(bp);
801010d8:	89 34 24             	mov    %esi,(%esp)
801010db:	e8 f5 f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010e0:	89 da                	mov    %ebx,%edx
801010e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010e5:	e8 eb fe ff ff       	call   80100fd5 <bzero>
}
801010ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010f0:	5b                   	pop    %ebx
801010f1:	5e                   	pop    %esi
801010f2:	5f                   	pop    %edi
801010f3:	5d                   	pop    %ebp
801010f4:	c3                   	ret    

801010f5 <bmap>:
{
801010f5:	55                   	push   %ebp
801010f6:	89 e5                	mov    %esp,%ebp
801010f8:	57                   	push   %edi
801010f9:	56                   	push   %esi
801010fa:	53                   	push   %ebx
801010fb:	83 ec 1c             	sub    $0x1c,%esp
801010fe:	89 c6                	mov    %eax,%esi
80101100:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
80101102:	83 fa 0b             	cmp    $0xb,%edx
80101105:	77 17                	ja     8010111e <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
80101107:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
8010110b:	85 db                	test   %ebx,%ebx
8010110d:	75 4a                	jne    80101159 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010110f:	8b 00                	mov    (%eax),%eax
80101111:	e8 fa fe ff ff       	call   80101010 <balloc>
80101116:	89 c3                	mov    %eax,%ebx
80101118:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
8010111c:	eb 3b                	jmp    80101159 <bmap+0x64>
  bn -= NDIRECT;
8010111e:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
80101121:	83 fb 7f             	cmp    $0x7f,%ebx
80101124:	77 68                	ja     8010118e <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101126:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010112c:	85 c0                	test   %eax,%eax
8010112e:	74 33                	je     80101163 <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101130:	83 ec 08             	sub    $0x8,%esp
80101133:	50                   	push   %eax
80101134:	ff 36                	pushl  (%esi)
80101136:	e8 31 f0 ff ff       	call   8010016c <bread>
8010113b:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
8010113d:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
80101141:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101144:	8b 18                	mov    (%eax),%ebx
80101146:	83 c4 10             	add    $0x10,%esp
80101149:	85 db                	test   %ebx,%ebx
8010114b:	74 25                	je     80101172 <bmap+0x7d>
    brelse(bp);
8010114d:	83 ec 0c             	sub    $0xc,%esp
80101150:	57                   	push   %edi
80101151:	e8 7f f0 ff ff       	call   801001d5 <brelse>
    return addr;
80101156:	83 c4 10             	add    $0x10,%esp
}
80101159:	89 d8                	mov    %ebx,%eax
8010115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010115e:	5b                   	pop    %ebx
8010115f:	5e                   	pop    %esi
80101160:	5f                   	pop    %edi
80101161:	5d                   	pop    %ebp
80101162:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101163:	8b 06                	mov    (%esi),%eax
80101165:	e8 a6 fe ff ff       	call   80101010 <balloc>
8010116a:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101170:	eb be                	jmp    80101130 <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
80101172:	8b 06                	mov    (%esi),%eax
80101174:	e8 97 fe ff ff       	call   80101010 <balloc>
80101179:	89 c3                	mov    %eax,%ebx
8010117b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010117e:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
80101180:	83 ec 0c             	sub    $0xc,%esp
80101183:	57                   	push   %edi
80101184:	e8 8e 1a 00 00       	call   80102c17 <log_write>
80101189:	83 c4 10             	add    $0x10,%esp
8010118c:	eb bf                	jmp    8010114d <bmap+0x58>
  panic("bmap: out of range");
8010118e:	83 ec 0c             	sub    $0xc,%esp
80101191:	68 d5 69 10 80       	push   $0x801069d5
80101196:	e8 ad f1 ff ff       	call   80100348 <panic>

8010119b <iget>:
{
8010119b:	55                   	push   %ebp
8010119c:	89 e5                	mov    %esp,%ebp
8010119e:	57                   	push   %edi
8010119f:	56                   	push   %esi
801011a0:	53                   	push   %ebx
801011a1:	83 ec 28             	sub    $0x28,%esp
801011a4:	89 c7                	mov    %eax,%edi
801011a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801011a9:	68 e0 09 11 80       	push   $0x801109e0
801011ae:	e8 cd 2d 00 00       	call   80103f80 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b3:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011b6:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011bb:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
801011c0:	eb 0a                	jmp    801011cc <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011c2:	85 f6                	test   %esi,%esi
801011c4:	74 3b                	je     80101201 <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011c6:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011cc:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
801011d2:	73 35                	jae    80101209 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011d4:	8b 43 08             	mov    0x8(%ebx),%eax
801011d7:	85 c0                	test   %eax,%eax
801011d9:	7e e7                	jle    801011c2 <iget+0x27>
801011db:	39 3b                	cmp    %edi,(%ebx)
801011dd:	75 e3                	jne    801011c2 <iget+0x27>
801011df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011e2:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011e5:	75 db                	jne    801011c2 <iget+0x27>
      ip->ref++;
801011e7:	83 c0 01             	add    $0x1,%eax
801011ea:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011ed:	83 ec 0c             	sub    $0xc,%esp
801011f0:	68 e0 09 11 80       	push   $0x801109e0
801011f5:	e8 eb 2d 00 00       	call   80103fe5 <release>
      return ip;
801011fa:	83 c4 10             	add    $0x10,%esp
801011fd:	89 de                	mov    %ebx,%esi
801011ff:	eb 32                	jmp    80101233 <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101201:	85 c0                	test   %eax,%eax
80101203:	75 c1                	jne    801011c6 <iget+0x2b>
      empty = ip;
80101205:	89 de                	mov    %ebx,%esi
80101207:	eb bd                	jmp    801011c6 <iget+0x2b>
  if(empty == 0)
80101209:	85 f6                	test   %esi,%esi
8010120b:	74 30                	je     8010123d <iget+0xa2>
  ip->dev = dev;
8010120d:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010120f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101212:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101215:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
8010121c:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101223:	83 ec 0c             	sub    $0xc,%esp
80101226:	68 e0 09 11 80       	push   $0x801109e0
8010122b:	e8 b5 2d 00 00       	call   80103fe5 <release>
  return ip;
80101230:	83 c4 10             	add    $0x10,%esp
}
80101233:	89 f0                	mov    %esi,%eax
80101235:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101238:	5b                   	pop    %ebx
80101239:	5e                   	pop    %esi
8010123a:	5f                   	pop    %edi
8010123b:	5d                   	pop    %ebp
8010123c:	c3                   	ret    
    panic("iget: no inodes");
8010123d:	83 ec 0c             	sub    $0xc,%esp
80101240:	68 e8 69 10 80       	push   $0x801069e8
80101245:	e8 fe f0 ff ff       	call   80100348 <panic>

8010124a <readsb>:
{
8010124a:	55                   	push   %ebp
8010124b:	89 e5                	mov    %esp,%ebp
8010124d:	53                   	push   %ebx
8010124e:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
80101251:	6a 01                	push   $0x1
80101253:	ff 75 08             	pushl  0x8(%ebp)
80101256:	e8 11 ef ff ff       	call   8010016c <bread>
8010125b:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010125d:	8d 40 5c             	lea    0x5c(%eax),%eax
80101260:	83 c4 0c             	add    $0xc,%esp
80101263:	6a 1c                	push   $0x1c
80101265:	50                   	push   %eax
80101266:	ff 75 0c             	pushl  0xc(%ebp)
80101269:	e8 39 2e 00 00       	call   801040a7 <memmove>
  brelse(bp);
8010126e:	89 1c 24             	mov    %ebx,(%esp)
80101271:	e8 5f ef ff ff       	call   801001d5 <brelse>
}
80101276:	83 c4 10             	add    $0x10,%esp
80101279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010127c:	c9                   	leave  
8010127d:	c3                   	ret    

8010127e <bfree>:
{
8010127e:	55                   	push   %ebp
8010127f:	89 e5                	mov    %esp,%ebp
80101281:	56                   	push   %esi
80101282:	53                   	push   %ebx
80101283:	89 c6                	mov    %eax,%esi
80101285:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
80101287:	83 ec 08             	sub    $0x8,%esp
8010128a:	68 c0 09 11 80       	push   $0x801109c0
8010128f:	50                   	push   %eax
80101290:	e8 b5 ff ff ff       	call   8010124a <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101295:	89 d8                	mov    %ebx,%eax
80101297:	c1 e8 0c             	shr    $0xc,%eax
8010129a:	03 05 d8 09 11 80    	add    0x801109d8,%eax
801012a0:	83 c4 08             	add    $0x8,%esp
801012a3:	50                   	push   %eax
801012a4:	56                   	push   %esi
801012a5:	e8 c2 ee ff ff       	call   8010016c <bread>
801012aa:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801012ac:	89 d9                	mov    %ebx,%ecx
801012ae:	83 e1 07             	and    $0x7,%ecx
801012b1:	b8 01 00 00 00       	mov    $0x1,%eax
801012b6:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012b8:	83 c4 10             	add    $0x10,%esp
801012bb:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012c1:	c1 fb 03             	sar    $0x3,%ebx
801012c4:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012c9:	0f b6 ca             	movzbl %dl,%ecx
801012cc:	85 c1                	test   %eax,%ecx
801012ce:	74 23                	je     801012f3 <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012d0:	f7 d0                	not    %eax
801012d2:	21 d0                	and    %edx,%eax
801012d4:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012d8:	83 ec 0c             	sub    $0xc,%esp
801012db:	56                   	push   %esi
801012dc:	e8 36 19 00 00       	call   80102c17 <log_write>
  brelse(bp);
801012e1:	89 34 24             	mov    %esi,(%esp)
801012e4:	e8 ec ee ff ff       	call   801001d5 <brelse>
}
801012e9:	83 c4 10             	add    $0x10,%esp
801012ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012ef:	5b                   	pop    %ebx
801012f0:	5e                   	pop    %esi
801012f1:	5d                   	pop    %ebp
801012f2:	c3                   	ret    
    panic("freeing free block");
801012f3:	83 ec 0c             	sub    $0xc,%esp
801012f6:	68 f8 69 10 80       	push   $0x801069f8
801012fb:	e8 48 f0 ff ff       	call   80100348 <panic>

80101300 <iinit>:
{
80101300:	55                   	push   %ebp
80101301:	89 e5                	mov    %esp,%ebp
80101303:	53                   	push   %ebx
80101304:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
80101307:	68 0b 6a 10 80       	push   $0x80106a0b
8010130c:	68 e0 09 11 80       	push   $0x801109e0
80101311:	e8 2e 2b 00 00       	call   80103e44 <initlock>
  for(i = 0; i < NINODE; i++) {
80101316:	83 c4 10             	add    $0x10,%esp
80101319:	bb 00 00 00 00       	mov    $0x0,%ebx
8010131e:	eb 21                	jmp    80101341 <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
80101320:	83 ec 08             	sub    $0x8,%esp
80101323:	68 12 6a 10 80       	push   $0x80106a12
80101328:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
8010132b:	89 d0                	mov    %edx,%eax
8010132d:	c1 e0 04             	shl    $0x4,%eax
80101330:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101335:	50                   	push   %eax
80101336:	e8 fe 29 00 00       	call   80103d39 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
8010133b:	83 c3 01             	add    $0x1,%ebx
8010133e:	83 c4 10             	add    $0x10,%esp
80101341:	83 fb 31             	cmp    $0x31,%ebx
80101344:	7e da                	jle    80101320 <iinit+0x20>
  readsb(dev, &sb);
80101346:	83 ec 08             	sub    $0x8,%esp
80101349:	68 c0 09 11 80       	push   $0x801109c0
8010134e:	ff 75 08             	pushl  0x8(%ebp)
80101351:	e8 f4 fe ff ff       	call   8010124a <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101356:	ff 35 d8 09 11 80    	pushl  0x801109d8
8010135c:	ff 35 d4 09 11 80    	pushl  0x801109d4
80101362:	ff 35 d0 09 11 80    	pushl  0x801109d0
80101368:	ff 35 cc 09 11 80    	pushl  0x801109cc
8010136e:	ff 35 c8 09 11 80    	pushl  0x801109c8
80101374:	ff 35 c4 09 11 80    	pushl  0x801109c4
8010137a:	ff 35 c0 09 11 80    	pushl  0x801109c0
80101380:	68 78 6a 10 80       	push   $0x80106a78
80101385:	e8 81 f2 ff ff       	call   8010060b <cprintf>
}
8010138a:	83 c4 30             	add    $0x30,%esp
8010138d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101390:	c9                   	leave  
80101391:	c3                   	ret    

80101392 <ialloc>:
{
80101392:	55                   	push   %ebp
80101393:	89 e5                	mov    %esp,%ebp
80101395:	57                   	push   %edi
80101396:	56                   	push   %esi
80101397:	53                   	push   %ebx
80101398:	83 ec 1c             	sub    $0x1c,%esp
8010139b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801013a1:	bb 01 00 00 00       	mov    $0x1,%ebx
801013a6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801013a9:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
801013af:	76 3f                	jbe    801013f0 <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
801013b1:	89 d8                	mov    %ebx,%eax
801013b3:	c1 e8 03             	shr    $0x3,%eax
801013b6:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801013bc:	83 ec 08             	sub    $0x8,%esp
801013bf:	50                   	push   %eax
801013c0:	ff 75 08             	pushl  0x8(%ebp)
801013c3:	e8 a4 ed ff ff       	call   8010016c <bread>
801013c8:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013ca:	89 d8                	mov    %ebx,%eax
801013cc:	83 e0 07             	and    $0x7,%eax
801013cf:	c1 e0 06             	shl    $0x6,%eax
801013d2:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013d6:	83 c4 10             	add    $0x10,%esp
801013d9:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013dd:	74 1e                	je     801013fd <ialloc+0x6b>
    brelse(bp);
801013df:	83 ec 0c             	sub    $0xc,%esp
801013e2:	56                   	push   %esi
801013e3:	e8 ed ed ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013e8:	83 c3 01             	add    $0x1,%ebx
801013eb:	83 c4 10             	add    $0x10,%esp
801013ee:	eb b6                	jmp    801013a6 <ialloc+0x14>
  panic("ialloc: no inodes");
801013f0:	83 ec 0c             	sub    $0xc,%esp
801013f3:	68 18 6a 10 80       	push   $0x80106a18
801013f8:	e8 4b ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013fd:	83 ec 04             	sub    $0x4,%esp
80101400:	6a 40                	push   $0x40
80101402:	6a 00                	push   $0x0
80101404:	57                   	push   %edi
80101405:	e8 22 2c 00 00       	call   8010402c <memset>
      dip->type = type;
8010140a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010140e:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101411:	89 34 24             	mov    %esi,(%esp)
80101414:	e8 fe 17 00 00       	call   80102c17 <log_write>
      brelse(bp);
80101419:	89 34 24             	mov    %esi,(%esp)
8010141c:	e8 b4 ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
80101421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	e8 6f fd ff ff       	call   8010119b <iget>
}
8010142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010142f:	5b                   	pop    %ebx
80101430:	5e                   	pop    %esi
80101431:	5f                   	pop    %edi
80101432:	5d                   	pop    %ebp
80101433:	c3                   	ret    

80101434 <iupdate>:
{
80101434:	55                   	push   %ebp
80101435:	89 e5                	mov    %esp,%ebp
80101437:	56                   	push   %esi
80101438:	53                   	push   %ebx
80101439:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010143c:	8b 43 04             	mov    0x4(%ebx),%eax
8010143f:	c1 e8 03             	shr    $0x3,%eax
80101442:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101448:	83 ec 08             	sub    $0x8,%esp
8010144b:	50                   	push   %eax
8010144c:	ff 33                	pushl  (%ebx)
8010144e:	e8 19 ed ff ff       	call   8010016c <bread>
80101453:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101455:	8b 43 04             	mov    0x4(%ebx),%eax
80101458:	83 e0 07             	and    $0x7,%eax
8010145b:	c1 e0 06             	shl    $0x6,%eax
8010145e:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101462:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101466:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101469:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
8010146d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101471:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101475:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101479:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
8010147d:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101481:	8b 53 58             	mov    0x58(%ebx),%edx
80101484:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101487:	83 c3 5c             	add    $0x5c,%ebx
8010148a:	83 c0 0c             	add    $0xc,%eax
8010148d:	83 c4 0c             	add    $0xc,%esp
80101490:	6a 34                	push   $0x34
80101492:	53                   	push   %ebx
80101493:	50                   	push   %eax
80101494:	e8 0e 2c 00 00       	call   801040a7 <memmove>
  log_write(bp);
80101499:	89 34 24             	mov    %esi,(%esp)
8010149c:	e8 76 17 00 00       	call   80102c17 <log_write>
  brelse(bp);
801014a1:	89 34 24             	mov    %esi,(%esp)
801014a4:	e8 2c ed ff ff       	call   801001d5 <brelse>
}
801014a9:	83 c4 10             	add    $0x10,%esp
801014ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014af:	5b                   	pop    %ebx
801014b0:	5e                   	pop    %esi
801014b1:	5d                   	pop    %ebp
801014b2:	c3                   	ret    

801014b3 <itrunc>:
{
801014b3:	55                   	push   %ebp
801014b4:	89 e5                	mov    %esp,%ebp
801014b6:	57                   	push   %edi
801014b7:	56                   	push   %esi
801014b8:	53                   	push   %ebx
801014b9:	83 ec 1c             	sub    $0x1c,%esp
801014bc:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014be:	bb 00 00 00 00       	mov    $0x0,%ebx
801014c3:	eb 03                	jmp    801014c8 <itrunc+0x15>
801014c5:	83 c3 01             	add    $0x1,%ebx
801014c8:	83 fb 0b             	cmp    $0xb,%ebx
801014cb:	7f 19                	jg     801014e6 <itrunc+0x33>
    if(ip->addrs[i]){
801014cd:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014d1:	85 d2                	test   %edx,%edx
801014d3:	74 f0                	je     801014c5 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014d5:	8b 06                	mov    (%esi),%eax
801014d7:	e8 a2 fd ff ff       	call   8010127e <bfree>
      ip->addrs[i] = 0;
801014dc:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014e3:	00 
801014e4:	eb df                	jmp    801014c5 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014e6:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014ec:	85 c0                	test   %eax,%eax
801014ee:	75 1b                	jne    8010150b <itrunc+0x58>
  ip->size = 0;
801014f0:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014f7:	83 ec 0c             	sub    $0xc,%esp
801014fa:	56                   	push   %esi
801014fb:	e8 34 ff ff ff       	call   80101434 <iupdate>
}
80101500:	83 c4 10             	add    $0x10,%esp
80101503:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101506:	5b                   	pop    %ebx
80101507:	5e                   	pop    %esi
80101508:	5f                   	pop    %edi
80101509:	5d                   	pop    %ebp
8010150a:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
8010150b:	83 ec 08             	sub    $0x8,%esp
8010150e:	50                   	push   %eax
8010150f:	ff 36                	pushl  (%esi)
80101511:	e8 56 ec ff ff       	call   8010016c <bread>
80101516:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101519:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
8010151c:	83 c4 10             	add    $0x10,%esp
8010151f:	bb 00 00 00 00       	mov    $0x0,%ebx
80101524:	eb 03                	jmp    80101529 <itrunc+0x76>
80101526:	83 c3 01             	add    $0x1,%ebx
80101529:	83 fb 7f             	cmp    $0x7f,%ebx
8010152c:	77 10                	ja     8010153e <itrunc+0x8b>
      if(a[j])
8010152e:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101531:	85 d2                	test   %edx,%edx
80101533:	74 f1                	je     80101526 <itrunc+0x73>
        bfree(ip->dev, a[j]);
80101535:	8b 06                	mov    (%esi),%eax
80101537:	e8 42 fd ff ff       	call   8010127e <bfree>
8010153c:	eb e8                	jmp    80101526 <itrunc+0x73>
    brelse(bp);
8010153e:	83 ec 0c             	sub    $0xc,%esp
80101541:	ff 75 e4             	pushl  -0x1c(%ebp)
80101544:	e8 8c ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101549:	8b 06                	mov    (%esi),%eax
8010154b:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101551:	e8 28 fd ff ff       	call   8010127e <bfree>
    ip->addrs[NDIRECT] = 0;
80101556:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
8010155d:	00 00 00 
80101560:	83 c4 10             	add    $0x10,%esp
80101563:	eb 8b                	jmp    801014f0 <itrunc+0x3d>

80101565 <idup>:
{
80101565:	55                   	push   %ebp
80101566:	89 e5                	mov    %esp,%ebp
80101568:	53                   	push   %ebx
80101569:	83 ec 10             	sub    $0x10,%esp
8010156c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010156f:	68 e0 09 11 80       	push   $0x801109e0
80101574:	e8 07 2a 00 00       	call   80103f80 <acquire>
  ip->ref++;
80101579:	8b 43 08             	mov    0x8(%ebx),%eax
8010157c:	83 c0 01             	add    $0x1,%eax
8010157f:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101582:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101589:	e8 57 2a 00 00       	call   80103fe5 <release>
}
8010158e:	89 d8                	mov    %ebx,%eax
80101590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101593:	c9                   	leave  
80101594:	c3                   	ret    

80101595 <ilock>:
{
80101595:	55                   	push   %ebp
80101596:	89 e5                	mov    %esp,%ebp
80101598:	56                   	push   %esi
80101599:	53                   	push   %ebx
8010159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
8010159d:	85 db                	test   %ebx,%ebx
8010159f:	74 22                	je     801015c3 <ilock+0x2e>
801015a1:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801015a5:	7e 1c                	jle    801015c3 <ilock+0x2e>
  acquiresleep(&ip->lock);
801015a7:	83 ec 0c             	sub    $0xc,%esp
801015aa:	8d 43 0c             	lea    0xc(%ebx),%eax
801015ad:	50                   	push   %eax
801015ae:	e8 b9 27 00 00       	call   80103d6c <acquiresleep>
  if(ip->valid == 0){
801015b3:	83 c4 10             	add    $0x10,%esp
801015b6:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015ba:	74 14                	je     801015d0 <ilock+0x3b>
}
801015bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015bf:	5b                   	pop    %ebx
801015c0:	5e                   	pop    %esi
801015c1:	5d                   	pop    %ebp
801015c2:	c3                   	ret    
    panic("ilock");
801015c3:	83 ec 0c             	sub    $0xc,%esp
801015c6:	68 2a 6a 10 80       	push   $0x80106a2a
801015cb:	e8 78 ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015d0:	8b 43 04             	mov    0x4(%ebx),%eax
801015d3:	c1 e8 03             	shr    $0x3,%eax
801015d6:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	50                   	push   %eax
801015e0:	ff 33                	pushl  (%ebx)
801015e2:	e8 85 eb ff ff       	call   8010016c <bread>
801015e7:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015e9:	8b 43 04             	mov    0x4(%ebx),%eax
801015ec:	83 e0 07             	and    $0x7,%eax
801015ef:	c1 e0 06             	shl    $0x6,%eax
801015f2:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015f6:	0f b7 10             	movzwl (%eax),%edx
801015f9:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015fd:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101601:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101605:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101609:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
8010160d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101611:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101615:	8b 50 08             	mov    0x8(%eax),%edx
80101618:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010161b:	83 c0 0c             	add    $0xc,%eax
8010161e:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101621:	83 c4 0c             	add    $0xc,%esp
80101624:	6a 34                	push   $0x34
80101626:	50                   	push   %eax
80101627:	52                   	push   %edx
80101628:	e8 7a 2a 00 00       	call   801040a7 <memmove>
    brelse(bp);
8010162d:	89 34 24             	mov    %esi,(%esp)
80101630:	e8 a0 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
80101635:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
8010163c:	83 c4 10             	add    $0x10,%esp
8010163f:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101644:	0f 85 72 ff ff ff    	jne    801015bc <ilock+0x27>
      panic("ilock: no type");
8010164a:	83 ec 0c             	sub    $0xc,%esp
8010164d:	68 30 6a 10 80       	push   $0x80106a30
80101652:	e8 f1 ec ff ff       	call   80100348 <panic>

80101657 <iunlock>:
{
80101657:	55                   	push   %ebp
80101658:	89 e5                	mov    %esp,%ebp
8010165a:	56                   	push   %esi
8010165b:	53                   	push   %ebx
8010165c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010165f:	85 db                	test   %ebx,%ebx
80101661:	74 2c                	je     8010168f <iunlock+0x38>
80101663:	8d 73 0c             	lea    0xc(%ebx),%esi
80101666:	83 ec 0c             	sub    $0xc,%esp
80101669:	56                   	push   %esi
8010166a:	e8 87 27 00 00       	call   80103df6 <holdingsleep>
8010166f:	83 c4 10             	add    $0x10,%esp
80101672:	85 c0                	test   %eax,%eax
80101674:	74 19                	je     8010168f <iunlock+0x38>
80101676:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010167a:	7e 13                	jle    8010168f <iunlock+0x38>
  releasesleep(&ip->lock);
8010167c:	83 ec 0c             	sub    $0xc,%esp
8010167f:	56                   	push   %esi
80101680:	e8 36 27 00 00       	call   80103dbb <releasesleep>
}
80101685:	83 c4 10             	add    $0x10,%esp
80101688:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010168b:	5b                   	pop    %ebx
8010168c:	5e                   	pop    %esi
8010168d:	5d                   	pop    %ebp
8010168e:	c3                   	ret    
    panic("iunlock");
8010168f:	83 ec 0c             	sub    $0xc,%esp
80101692:	68 3f 6a 10 80       	push   $0x80106a3f
80101697:	e8 ac ec ff ff       	call   80100348 <panic>

8010169c <iput>:
{
8010169c:	55                   	push   %ebp
8010169d:	89 e5                	mov    %esp,%ebp
8010169f:	57                   	push   %edi
801016a0:	56                   	push   %esi
801016a1:	53                   	push   %ebx
801016a2:	83 ec 18             	sub    $0x18,%esp
801016a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801016a8:	8d 73 0c             	lea    0xc(%ebx),%esi
801016ab:	56                   	push   %esi
801016ac:	e8 bb 26 00 00       	call   80103d6c <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016b1:	83 c4 10             	add    $0x10,%esp
801016b4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016b8:	74 07                	je     801016c1 <iput+0x25>
801016ba:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016bf:	74 35                	je     801016f6 <iput+0x5a>
  releasesleep(&ip->lock);
801016c1:	83 ec 0c             	sub    $0xc,%esp
801016c4:	56                   	push   %esi
801016c5:	e8 f1 26 00 00       	call   80103dbb <releasesleep>
  acquire(&icache.lock);
801016ca:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d1:	e8 aa 28 00 00       	call   80103f80 <acquire>
  ip->ref--;
801016d6:	8b 43 08             	mov    0x8(%ebx),%eax
801016d9:	83 e8 01             	sub    $0x1,%eax
801016dc:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016df:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016e6:	e8 fa 28 00 00       	call   80103fe5 <release>
}
801016eb:	83 c4 10             	add    $0x10,%esp
801016ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016f1:	5b                   	pop    %ebx
801016f2:	5e                   	pop    %esi
801016f3:	5f                   	pop    %edi
801016f4:	5d                   	pop    %ebp
801016f5:	c3                   	ret    
    acquire(&icache.lock);
801016f6:	83 ec 0c             	sub    $0xc,%esp
801016f9:	68 e0 09 11 80       	push   $0x801109e0
801016fe:	e8 7d 28 00 00       	call   80103f80 <acquire>
    int r = ip->ref;
80101703:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
80101706:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010170d:	e8 d3 28 00 00       	call   80103fe5 <release>
    if(r == 1){
80101712:	83 c4 10             	add    $0x10,%esp
80101715:	83 ff 01             	cmp    $0x1,%edi
80101718:	75 a7                	jne    801016c1 <iput+0x25>
      itrunc(ip);
8010171a:	89 d8                	mov    %ebx,%eax
8010171c:	e8 92 fd ff ff       	call   801014b3 <itrunc>
      ip->type = 0;
80101721:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101727:	83 ec 0c             	sub    $0xc,%esp
8010172a:	53                   	push   %ebx
8010172b:	e8 04 fd ff ff       	call   80101434 <iupdate>
      ip->valid = 0;
80101730:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101737:	83 c4 10             	add    $0x10,%esp
8010173a:	eb 85                	jmp    801016c1 <iput+0x25>

8010173c <iunlockput>:
{
8010173c:	55                   	push   %ebp
8010173d:	89 e5                	mov    %esp,%ebp
8010173f:	53                   	push   %ebx
80101740:	83 ec 10             	sub    $0x10,%esp
80101743:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101746:	53                   	push   %ebx
80101747:	e8 0b ff ff ff       	call   80101657 <iunlock>
  iput(ip);
8010174c:	89 1c 24             	mov    %ebx,(%esp)
8010174f:	e8 48 ff ff ff       	call   8010169c <iput>
}
80101754:	83 c4 10             	add    $0x10,%esp
80101757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010175a:	c9                   	leave  
8010175b:	c3                   	ret    

8010175c <stati>:
{
8010175c:	55                   	push   %ebp
8010175d:	89 e5                	mov    %esp,%ebp
8010175f:	8b 55 08             	mov    0x8(%ebp),%edx
80101762:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101765:	8b 0a                	mov    (%edx),%ecx
80101767:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
8010176a:	8b 4a 04             	mov    0x4(%edx),%ecx
8010176d:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101770:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101774:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101777:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
8010177b:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010177f:	8b 52 58             	mov    0x58(%edx),%edx
80101782:	89 50 10             	mov    %edx,0x10(%eax)
}
80101785:	5d                   	pop    %ebp
80101786:	c3                   	ret    

80101787 <readi>:
{
80101787:	55                   	push   %ebp
80101788:	89 e5                	mov    %esp,%ebp
8010178a:	57                   	push   %edi
8010178b:	56                   	push   %esi
8010178c:	53                   	push   %ebx
8010178d:	83 ec 1c             	sub    $0x1c,%esp
80101790:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
80101793:	8b 45 08             	mov    0x8(%ebp),%eax
80101796:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010179b:	74 2c                	je     801017c9 <readi+0x42>
  if(off > ip->size || off + n < off)
8010179d:	8b 45 08             	mov    0x8(%ebp),%eax
801017a0:	8b 40 58             	mov    0x58(%eax),%eax
801017a3:	39 f8                	cmp    %edi,%eax
801017a5:	0f 82 cb 00 00 00    	jb     80101876 <readi+0xef>
801017ab:	89 fa                	mov    %edi,%edx
801017ad:	03 55 14             	add    0x14(%ebp),%edx
801017b0:	0f 82 c7 00 00 00    	jb     8010187d <readi+0xf6>
  if(off + n > ip->size)
801017b6:	39 d0                	cmp    %edx,%eax
801017b8:	73 05                	jae    801017bf <readi+0x38>
    n = ip->size - off;
801017ba:	29 f8                	sub    %edi,%eax
801017bc:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017bf:	be 00 00 00 00       	mov    $0x0,%esi
801017c4:	e9 8f 00 00 00       	jmp    80101858 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017c9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017cd:	66 83 f8 09          	cmp    $0x9,%ax
801017d1:	0f 87 91 00 00 00    	ja     80101868 <readi+0xe1>
801017d7:	98                   	cwtl   
801017d8:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
801017df:	85 c0                	test   %eax,%eax
801017e1:	0f 84 88 00 00 00    	je     8010186f <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017e7:	83 ec 04             	sub    $0x4,%esp
801017ea:	ff 75 14             	pushl  0x14(%ebp)
801017ed:	ff 75 0c             	pushl  0xc(%ebp)
801017f0:	ff 75 08             	pushl  0x8(%ebp)
801017f3:	ff d0                	call   *%eax
801017f5:	83 c4 10             	add    $0x10,%esp
801017f8:	eb 66                	jmp    80101860 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017fa:	89 fa                	mov    %edi,%edx
801017fc:	c1 ea 09             	shr    $0x9,%edx
801017ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101802:	e8 ee f8 ff ff       	call   801010f5 <bmap>
80101807:	83 ec 08             	sub    $0x8,%esp
8010180a:	50                   	push   %eax
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	ff 30                	pushl  (%eax)
80101810:	e8 57 e9 ff ff       	call   8010016c <bread>
80101815:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101817:	89 f8                	mov    %edi,%eax
80101819:	25 ff 01 00 00       	and    $0x1ff,%eax
8010181e:	bb 00 02 00 00       	mov    $0x200,%ebx
80101823:	29 c3                	sub    %eax,%ebx
80101825:	8b 55 14             	mov    0x14(%ebp),%edx
80101828:	29 f2                	sub    %esi,%edx
8010182a:	83 c4 0c             	add    $0xc,%esp
8010182d:	39 d3                	cmp    %edx,%ebx
8010182f:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101832:	53                   	push   %ebx
80101833:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101836:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
8010183a:	50                   	push   %eax
8010183b:	ff 75 0c             	pushl  0xc(%ebp)
8010183e:	e8 64 28 00 00       	call   801040a7 <memmove>
    brelse(bp);
80101843:	83 c4 04             	add    $0x4,%esp
80101846:	ff 75 e4             	pushl  -0x1c(%ebp)
80101849:	e8 87 e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010184e:	01 de                	add    %ebx,%esi
80101850:	01 df                	add    %ebx,%edi
80101852:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101855:	83 c4 10             	add    $0x10,%esp
80101858:	39 75 14             	cmp    %esi,0x14(%ebp)
8010185b:	77 9d                	ja     801017fa <readi+0x73>
  return n;
8010185d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101860:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101863:	5b                   	pop    %ebx
80101864:	5e                   	pop    %esi
80101865:	5f                   	pop    %edi
80101866:	5d                   	pop    %ebp
80101867:	c3                   	ret    
      return -1;
80101868:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186d:	eb f1                	jmp    80101860 <readi+0xd9>
8010186f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101874:	eb ea                	jmp    80101860 <readi+0xd9>
    return -1;
80101876:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010187b:	eb e3                	jmp    80101860 <readi+0xd9>
8010187d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101882:	eb dc                	jmp    80101860 <readi+0xd9>

80101884 <writei>:
{
80101884:	55                   	push   %ebp
80101885:	89 e5                	mov    %esp,%ebp
80101887:	57                   	push   %edi
80101888:	56                   	push   %esi
80101889:	53                   	push   %ebx
8010188a:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
8010188d:	8b 45 08             	mov    0x8(%ebp),%eax
80101890:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101895:	74 2f                	je     801018c6 <writei+0x42>
  if(off > ip->size || off + n < off)
80101897:	8b 45 08             	mov    0x8(%ebp),%eax
8010189a:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010189d:	39 48 58             	cmp    %ecx,0x58(%eax)
801018a0:	0f 82 f4 00 00 00    	jb     8010199a <writei+0x116>
801018a6:	89 c8                	mov    %ecx,%eax
801018a8:	03 45 14             	add    0x14(%ebp),%eax
801018ab:	0f 82 f0 00 00 00    	jb     801019a1 <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
801018b1:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018b6:	0f 87 ec 00 00 00    	ja     801019a8 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018bc:	be 00 00 00 00       	mov    $0x0,%esi
801018c1:	e9 94 00 00 00       	jmp    8010195a <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018c6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018ca:	66 83 f8 09          	cmp    $0x9,%ax
801018ce:	0f 87 b8 00 00 00    	ja     8010198c <writei+0x108>
801018d4:	98                   	cwtl   
801018d5:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
801018dc:	85 c0                	test   %eax,%eax
801018de:	0f 84 af 00 00 00    	je     80101993 <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018e4:	83 ec 04             	sub    $0x4,%esp
801018e7:	ff 75 14             	pushl  0x14(%ebp)
801018ea:	ff 75 0c             	pushl  0xc(%ebp)
801018ed:	ff 75 08             	pushl  0x8(%ebp)
801018f0:	ff d0                	call   *%eax
801018f2:	83 c4 10             	add    $0x10,%esp
801018f5:	eb 7c                	jmp    80101973 <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018f7:	8b 55 10             	mov    0x10(%ebp),%edx
801018fa:	c1 ea 09             	shr    $0x9,%edx
801018fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101900:	e8 f0 f7 ff ff       	call   801010f5 <bmap>
80101905:	83 ec 08             	sub    $0x8,%esp
80101908:	50                   	push   %eax
80101909:	8b 45 08             	mov    0x8(%ebp),%eax
8010190c:	ff 30                	pushl  (%eax)
8010190e:	e8 59 e8 ff ff       	call   8010016c <bread>
80101913:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101915:	8b 45 10             	mov    0x10(%ebp),%eax
80101918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010191d:	bb 00 02 00 00       	mov    $0x200,%ebx
80101922:	29 c3                	sub    %eax,%ebx
80101924:	8b 55 14             	mov    0x14(%ebp),%edx
80101927:	29 f2                	sub    %esi,%edx
80101929:	83 c4 0c             	add    $0xc,%esp
8010192c:	39 d3                	cmp    %edx,%ebx
8010192e:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101931:	53                   	push   %ebx
80101932:	ff 75 0c             	pushl  0xc(%ebp)
80101935:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101939:	50                   	push   %eax
8010193a:	e8 68 27 00 00       	call   801040a7 <memmove>
    log_write(bp);
8010193f:	89 3c 24             	mov    %edi,(%esp)
80101942:	e8 d0 12 00 00       	call   80102c17 <log_write>
    brelse(bp);
80101947:	89 3c 24             	mov    %edi,(%esp)
8010194a:	e8 86 e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010194f:	01 de                	add    %ebx,%esi
80101951:	01 5d 10             	add    %ebx,0x10(%ebp)
80101954:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101957:	83 c4 10             	add    $0x10,%esp
8010195a:	3b 75 14             	cmp    0x14(%ebp),%esi
8010195d:	72 98                	jb     801018f7 <writei+0x73>
  if(n > 0 && off > ip->size){
8010195f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80101963:	74 0b                	je     80101970 <writei+0xec>
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
80101968:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010196b:	39 48 58             	cmp    %ecx,0x58(%eax)
8010196e:	72 0b                	jb     8010197b <writei+0xf7>
  return n;
80101970:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101973:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101976:	5b                   	pop    %ebx
80101977:	5e                   	pop    %esi
80101978:	5f                   	pop    %edi
80101979:	5d                   	pop    %ebp
8010197a:	c3                   	ret    
    ip->size = off;
8010197b:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
8010197e:	83 ec 0c             	sub    $0xc,%esp
80101981:	50                   	push   %eax
80101982:	e8 ad fa ff ff       	call   80101434 <iupdate>
80101987:	83 c4 10             	add    $0x10,%esp
8010198a:	eb e4                	jmp    80101970 <writei+0xec>
      return -1;
8010198c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101991:	eb e0                	jmp    80101973 <writei+0xef>
80101993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101998:	eb d9                	jmp    80101973 <writei+0xef>
    return -1;
8010199a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010199f:	eb d2                	jmp    80101973 <writei+0xef>
801019a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019a6:	eb cb                	jmp    80101973 <writei+0xef>
    return -1;
801019a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019ad:	eb c4                	jmp    80101973 <writei+0xef>

801019af <namecmp>:
{
801019af:	55                   	push   %ebp
801019b0:	89 e5                	mov    %esp,%ebp
801019b2:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019b5:	6a 0e                	push   $0xe
801019b7:	ff 75 0c             	pushl  0xc(%ebp)
801019ba:	ff 75 08             	pushl  0x8(%ebp)
801019bd:	e8 4c 27 00 00       	call   8010410e <strncmp>
}
801019c2:	c9                   	leave  
801019c3:	c3                   	ret    

801019c4 <dirlookup>:
{
801019c4:	55                   	push   %ebp
801019c5:	89 e5                	mov    %esp,%ebp
801019c7:	57                   	push   %edi
801019c8:	56                   	push   %esi
801019c9:	53                   	push   %ebx
801019ca:	83 ec 1c             	sub    $0x1c,%esp
801019cd:	8b 75 08             	mov    0x8(%ebp),%esi
801019d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019d3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019d8:	75 07                	jne    801019e1 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019da:	bb 00 00 00 00       	mov    $0x0,%ebx
801019df:	eb 1d                	jmp    801019fe <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019e1:	83 ec 0c             	sub    $0xc,%esp
801019e4:	68 47 6a 10 80       	push   $0x80106a47
801019e9:	e8 5a e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019ee:	83 ec 0c             	sub    $0xc,%esp
801019f1:	68 59 6a 10 80       	push   $0x80106a59
801019f6:	e8 4d e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019fb:	83 c3 10             	add    $0x10,%ebx
801019fe:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101a01:	76 48                	jbe    80101a4b <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101a03:	6a 10                	push   $0x10
80101a05:	53                   	push   %ebx
80101a06:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101a09:	50                   	push   %eax
80101a0a:	56                   	push   %esi
80101a0b:	e8 77 fd ff ff       	call   80101787 <readi>
80101a10:	83 c4 10             	add    $0x10,%esp
80101a13:	83 f8 10             	cmp    $0x10,%eax
80101a16:	75 d6                	jne    801019ee <dirlookup+0x2a>
    if(de.inum == 0)
80101a18:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a1d:	74 dc                	je     801019fb <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a1f:	83 ec 08             	sub    $0x8,%esp
80101a22:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a25:	50                   	push   %eax
80101a26:	57                   	push   %edi
80101a27:	e8 83 ff ff ff       	call   801019af <namecmp>
80101a2c:	83 c4 10             	add    $0x10,%esp
80101a2f:	85 c0                	test   %eax,%eax
80101a31:	75 c8                	jne    801019fb <dirlookup+0x37>
      if(poff)
80101a33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a37:	74 05                	je     80101a3e <dirlookup+0x7a>
        *poff = off;
80101a39:	8b 45 10             	mov    0x10(%ebp),%eax
80101a3c:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a3e:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a42:	8b 06                	mov    (%esi),%eax
80101a44:	e8 52 f7 ff ff       	call   8010119b <iget>
80101a49:	eb 05                	jmp    80101a50 <dirlookup+0x8c>
  return 0;
80101a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a53:	5b                   	pop    %ebx
80101a54:	5e                   	pop    %esi
80101a55:	5f                   	pop    %edi
80101a56:	5d                   	pop    %ebp
80101a57:	c3                   	ret    

80101a58 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a58:	55                   	push   %ebp
80101a59:	89 e5                	mov    %esp,%ebp
80101a5b:	57                   	push   %edi
80101a5c:	56                   	push   %esi
80101a5d:	53                   	push   %ebx
80101a5e:	83 ec 1c             	sub    $0x1c,%esp
80101a61:	89 c6                	mov    %eax,%esi
80101a63:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a66:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a69:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a6c:	74 17                	je     80101a85 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a6e:	e8 f3 1a 00 00       	call   80103566 <myproc>
80101a73:	83 ec 0c             	sub    $0xc,%esp
80101a76:	ff 70 68             	pushl  0x68(%eax)
80101a79:	e8 e7 fa ff ff       	call   80101565 <idup>
80101a7e:	89 c3                	mov    %eax,%ebx
80101a80:	83 c4 10             	add    $0x10,%esp
80101a83:	eb 53                	jmp    80101ad8 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a85:	ba 01 00 00 00       	mov    $0x1,%edx
80101a8a:	b8 01 00 00 00       	mov    $0x1,%eax
80101a8f:	e8 07 f7 ff ff       	call   8010119b <iget>
80101a94:	89 c3                	mov    %eax,%ebx
80101a96:	eb 40                	jmp    80101ad8 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a98:	83 ec 0c             	sub    $0xc,%esp
80101a9b:	53                   	push   %ebx
80101a9c:	e8 9b fc ff ff       	call   8010173c <iunlockput>
      return 0;
80101aa1:	83 c4 10             	add    $0x10,%esp
80101aa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101aa9:	89 d8                	mov    %ebx,%eax
80101aab:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aae:	5b                   	pop    %ebx
80101aaf:	5e                   	pop    %esi
80101ab0:	5f                   	pop    %edi
80101ab1:	5d                   	pop    %ebp
80101ab2:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101ab3:	83 ec 04             	sub    $0x4,%esp
80101ab6:	6a 00                	push   $0x0
80101ab8:	ff 75 e4             	pushl  -0x1c(%ebp)
80101abb:	53                   	push   %ebx
80101abc:	e8 03 ff ff ff       	call   801019c4 <dirlookup>
80101ac1:	89 c7                	mov    %eax,%edi
80101ac3:	83 c4 10             	add    $0x10,%esp
80101ac6:	85 c0                	test   %eax,%eax
80101ac8:	74 4a                	je     80101b14 <namex+0xbc>
    iunlockput(ip);
80101aca:	83 ec 0c             	sub    $0xc,%esp
80101acd:	53                   	push   %ebx
80101ace:	e8 69 fc ff ff       	call   8010173c <iunlockput>
    ip = next;
80101ad3:	83 c4 10             	add    $0x10,%esp
80101ad6:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ad8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101adb:	89 f0                	mov    %esi,%eax
80101add:	e8 77 f4 ff ff       	call   80100f59 <skipelem>
80101ae2:	89 c6                	mov    %eax,%esi
80101ae4:	85 c0                	test   %eax,%eax
80101ae6:	74 3c                	je     80101b24 <namex+0xcc>
    ilock(ip);
80101ae8:	83 ec 0c             	sub    $0xc,%esp
80101aeb:	53                   	push   %ebx
80101aec:	e8 a4 fa ff ff       	call   80101595 <ilock>
    if(ip->type != T_DIR){
80101af1:	83 c4 10             	add    $0x10,%esp
80101af4:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101af9:	75 9d                	jne    80101a98 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101afb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aff:	74 b2                	je     80101ab3 <namex+0x5b>
80101b01:	80 3e 00             	cmpb   $0x0,(%esi)
80101b04:	75 ad                	jne    80101ab3 <namex+0x5b>
      iunlock(ip);
80101b06:	83 ec 0c             	sub    $0xc,%esp
80101b09:	53                   	push   %ebx
80101b0a:	e8 48 fb ff ff       	call   80101657 <iunlock>
      return ip;
80101b0f:	83 c4 10             	add    $0x10,%esp
80101b12:	eb 95                	jmp    80101aa9 <namex+0x51>
      iunlockput(ip);
80101b14:	83 ec 0c             	sub    $0xc,%esp
80101b17:	53                   	push   %ebx
80101b18:	e8 1f fc ff ff       	call   8010173c <iunlockput>
      return 0;
80101b1d:	83 c4 10             	add    $0x10,%esp
80101b20:	89 fb                	mov    %edi,%ebx
80101b22:	eb 85                	jmp    80101aa9 <namex+0x51>
  if(nameiparent){
80101b24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b28:	0f 84 7b ff ff ff    	je     80101aa9 <namex+0x51>
    iput(ip);
80101b2e:	83 ec 0c             	sub    $0xc,%esp
80101b31:	53                   	push   %ebx
80101b32:	e8 65 fb ff ff       	call   8010169c <iput>
    return 0;
80101b37:	83 c4 10             	add    $0x10,%esp
80101b3a:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b3f:	e9 65 ff ff ff       	jmp    80101aa9 <namex+0x51>

80101b44 <dirlink>:
{
80101b44:	55                   	push   %ebp
80101b45:	89 e5                	mov    %esp,%ebp
80101b47:	57                   	push   %edi
80101b48:	56                   	push   %esi
80101b49:	53                   	push   %ebx
80101b4a:	83 ec 20             	sub    $0x20,%esp
80101b4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b50:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b53:	6a 00                	push   $0x0
80101b55:	57                   	push   %edi
80101b56:	53                   	push   %ebx
80101b57:	e8 68 fe ff ff       	call   801019c4 <dirlookup>
80101b5c:	83 c4 10             	add    $0x10,%esp
80101b5f:	85 c0                	test   %eax,%eax
80101b61:	75 2d                	jne    80101b90 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b63:	b8 00 00 00 00       	mov    $0x0,%eax
80101b68:	89 c6                	mov    %eax,%esi
80101b6a:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b6d:	76 41                	jbe    80101bb0 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b6f:	6a 10                	push   $0x10
80101b71:	50                   	push   %eax
80101b72:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b75:	50                   	push   %eax
80101b76:	53                   	push   %ebx
80101b77:	e8 0b fc ff ff       	call   80101787 <readi>
80101b7c:	83 c4 10             	add    $0x10,%esp
80101b7f:	83 f8 10             	cmp    $0x10,%eax
80101b82:	75 1f                	jne    80101ba3 <dirlink+0x5f>
    if(de.inum == 0)
80101b84:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b89:	74 25                	je     80101bb0 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b8b:	8d 46 10             	lea    0x10(%esi),%eax
80101b8e:	eb d8                	jmp    80101b68 <dirlink+0x24>
    iput(ip);
80101b90:	83 ec 0c             	sub    $0xc,%esp
80101b93:	50                   	push   %eax
80101b94:	e8 03 fb ff ff       	call   8010169c <iput>
    return -1;
80101b99:	83 c4 10             	add    $0x10,%esp
80101b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ba1:	eb 3d                	jmp    80101be0 <dirlink+0x9c>
      panic("dirlink read");
80101ba3:	83 ec 0c             	sub    $0xc,%esp
80101ba6:	68 68 6a 10 80       	push   $0x80106a68
80101bab:	e8 98 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101bb0:	83 ec 04             	sub    $0x4,%esp
80101bb3:	6a 0e                	push   $0xe
80101bb5:	57                   	push   %edi
80101bb6:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bb9:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bbc:	50                   	push   %eax
80101bbd:	e8 89 25 00 00       	call   8010414b <strncpy>
  de.inum = inum;
80101bc2:	8b 45 10             	mov    0x10(%ebp),%eax
80101bc5:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bc9:	6a 10                	push   $0x10
80101bcb:	56                   	push   %esi
80101bcc:	57                   	push   %edi
80101bcd:	53                   	push   %ebx
80101bce:	e8 b1 fc ff ff       	call   80101884 <writei>
80101bd3:	83 c4 20             	add    $0x20,%esp
80101bd6:	83 f8 10             	cmp    $0x10,%eax
80101bd9:	75 0d                	jne    80101be8 <dirlink+0xa4>
  return 0;
80101bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101be3:	5b                   	pop    %ebx
80101be4:	5e                   	pop    %esi
80101be5:	5f                   	pop    %edi
80101be6:	5d                   	pop    %ebp
80101be7:	c3                   	ret    
    panic("dirlink");
80101be8:	83 ec 0c             	sub    $0xc,%esp
80101beb:	68 74 70 10 80       	push   $0x80107074
80101bf0:	e8 53 e7 ff ff       	call   80100348 <panic>

80101bf5 <namei>:

struct inode*
namei(char *path)
{
80101bf5:	55                   	push   %ebp
80101bf6:	89 e5                	mov    %esp,%ebp
80101bf8:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bfb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bfe:	ba 00 00 00 00       	mov    $0x0,%edx
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	e8 4d fe ff ff       	call   80101a58 <namex>
}
80101c0b:	c9                   	leave  
80101c0c:	c3                   	ret    

80101c0d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101c0d:	55                   	push   %ebp
80101c0e:	89 e5                	mov    %esp,%ebp
80101c10:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c16:	ba 01 00 00 00       	mov    $0x1,%edx
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	e8 35 fe ff ff       	call   80101a58 <namex>
}
80101c23:	c9                   	leave  
80101c24:	c3                   	ret    

80101c25 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c25:	55                   	push   %ebp
80101c26:	89 e5                	mov    %esp,%ebp
80101c28:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c2a:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c2f:	ec                   	in     (%dx),%al
80101c30:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c32:	83 e0 c0             	and    $0xffffffc0,%eax
80101c35:	3c 40                	cmp    $0x40,%al
80101c37:	75 f1                	jne    80101c2a <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c39:	85 c9                	test   %ecx,%ecx
80101c3b:	74 0c                	je     80101c49 <idewait+0x24>
80101c3d:	f6 c2 21             	test   $0x21,%dl
80101c40:	75 0e                	jne    80101c50 <idewait+0x2b>
    return -1;
  return 0;
80101c42:	b8 00 00 00 00       	mov    $0x0,%eax
80101c47:	eb 05                	jmp    80101c4e <idewait+0x29>
80101c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c4e:	5d                   	pop    %ebp
80101c4f:	c3                   	ret    
    return -1;
80101c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c55:	eb f7                	jmp    80101c4e <idewait+0x29>

80101c57 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c57:	55                   	push   %ebp
80101c58:	89 e5                	mov    %esp,%ebp
80101c5a:	56                   	push   %esi
80101c5b:	53                   	push   %ebx
  if(b == 0)
80101c5c:	85 c0                	test   %eax,%eax
80101c5e:	74 7d                	je     80101cdd <idestart+0x86>
80101c60:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c62:	8b 58 08             	mov    0x8(%eax),%ebx
80101c65:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c6b:	77 7d                	ja     80101cea <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80101c72:	e8 ae ff ff ff       	call   80101c25 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c77:	b8 00 00 00 00       	mov    $0x0,%eax
80101c7c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c81:	ee                   	out    %al,(%dx)
80101c82:	b8 01 00 00 00       	mov    $0x1,%eax
80101c87:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c8c:	ee                   	out    %al,(%dx)
80101c8d:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c92:	89 d8                	mov    %ebx,%eax
80101c94:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c95:	89 d8                	mov    %ebx,%eax
80101c97:	c1 f8 08             	sar    $0x8,%eax
80101c9a:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c9f:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101ca0:	89 d8                	mov    %ebx,%eax
80101ca2:	c1 f8 10             	sar    $0x10,%eax
80101ca5:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101caa:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101cab:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101caf:	c1 e0 04             	shl    $0x4,%eax
80101cb2:	83 e0 10             	and    $0x10,%eax
80101cb5:	c1 fb 18             	sar    $0x18,%ebx
80101cb8:	83 e3 0f             	and    $0xf,%ebx
80101cbb:	09 d8                	or     %ebx,%eax
80101cbd:	83 c8 e0             	or     $0xffffffe0,%eax
80101cc0:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cc5:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cc6:	f6 06 04             	testb  $0x4,(%esi)
80101cc9:	75 2c                	jne    80101cf7 <idestart+0xa0>
80101ccb:	b8 20 00 00 00       	mov    $0x20,%eax
80101cd0:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cd5:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cd9:	5b                   	pop    %ebx
80101cda:	5e                   	pop    %esi
80101cdb:	5d                   	pop    %ebp
80101cdc:	c3                   	ret    
    panic("idestart");
80101cdd:	83 ec 0c             	sub    $0xc,%esp
80101ce0:	68 cb 6a 10 80       	push   $0x80106acb
80101ce5:	e8 5e e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cea:	83 ec 0c             	sub    $0xc,%esp
80101ced:	68 d4 6a 10 80       	push   $0x80106ad4
80101cf2:	e8 51 e6 ff ff       	call   80100348 <panic>
80101cf7:	b8 30 00 00 00       	mov    $0x30,%eax
80101cfc:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d01:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101d02:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101d05:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d0a:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d0f:	fc                   	cld    
80101d10:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d12:	eb c2                	jmp    80101cd6 <idestart+0x7f>

80101d14 <ideinit>:
{
80101d14:	55                   	push   %ebp
80101d15:	89 e5                	mov    %esp,%ebp
80101d17:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d1a:	68 e6 6a 10 80       	push   $0x80106ae6
80101d1f:	68 80 a5 10 80       	push   $0x8010a580
80101d24:	e8 1b 21 00 00       	call   80103e44 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d29:	83 c4 08             	add    $0x8,%esp
80101d2c:	a1 a0 9a 1e 80       	mov    0x801e9aa0,%eax
80101d31:	83 e8 01             	sub    $0x1,%eax
80101d34:	50                   	push   %eax
80101d35:	6a 0e                	push   $0xe
80101d37:	e8 56 02 00 00       	call   80101f92 <ioapicenable>
  idewait(0);
80101d3c:	b8 00 00 00 00       	mov    $0x0,%eax
80101d41:	e8 df fe ff ff       	call   80101c25 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d46:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d4b:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d50:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d51:	83 c4 10             	add    $0x10,%esp
80101d54:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d59:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d5f:	7f 19                	jg     80101d7a <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d61:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d66:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d67:	84 c0                	test   %al,%al
80101d69:	75 05                	jne    80101d70 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d6b:	83 c1 01             	add    $0x1,%ecx
80101d6e:	eb e9                	jmp    80101d59 <ideinit+0x45>
      havedisk1 = 1;
80101d70:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101d77:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d7a:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d7f:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d84:	ee                   	out    %al,(%dx)
}
80101d85:	c9                   	leave  
80101d86:	c3                   	ret    

80101d87 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d87:	55                   	push   %ebp
80101d88:	89 e5                	mov    %esp,%ebp
80101d8a:	57                   	push   %edi
80101d8b:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d8c:	83 ec 0c             	sub    $0xc,%esp
80101d8f:	68 80 a5 10 80       	push   $0x8010a580
80101d94:	e8 e7 21 00 00       	call   80103f80 <acquire>

  if((b = idequeue) == 0){
80101d99:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101d9f:	83 c4 10             	add    $0x10,%esp
80101da2:	85 db                	test   %ebx,%ebx
80101da4:	74 48                	je     80101dee <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101da6:	8b 43 58             	mov    0x58(%ebx),%eax
80101da9:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dae:	f6 03 04             	testb  $0x4,(%ebx)
80101db1:	74 4d                	je     80101e00 <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101db3:	8b 03                	mov    (%ebx),%eax
80101db5:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101db8:	83 e0 fb             	and    $0xfffffffb,%eax
80101dbb:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101dbd:	83 ec 0c             	sub    $0xc,%esp
80101dc0:	53                   	push   %ebx
80101dc1:	e8 bd 1d 00 00       	call   80103b83 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101dc6:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101dcb:	83 c4 10             	add    $0x10,%esp
80101dce:	85 c0                	test   %eax,%eax
80101dd0:	74 05                	je     80101dd7 <ideintr+0x50>
    idestart(idequeue);
80101dd2:	e8 80 fe ff ff       	call   80101c57 <idestart>

  release(&idelock);
80101dd7:	83 ec 0c             	sub    $0xc,%esp
80101dda:	68 80 a5 10 80       	push   $0x8010a580
80101ddf:	e8 01 22 00 00       	call   80103fe5 <release>
80101de4:	83 c4 10             	add    $0x10,%esp
}
80101de7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dea:	5b                   	pop    %ebx
80101deb:	5f                   	pop    %edi
80101dec:	5d                   	pop    %ebp
80101ded:	c3                   	ret    
    release(&idelock);
80101dee:	83 ec 0c             	sub    $0xc,%esp
80101df1:	68 80 a5 10 80       	push   $0x8010a580
80101df6:	e8 ea 21 00 00       	call   80103fe5 <release>
    return;
80101dfb:	83 c4 10             	add    $0x10,%esp
80101dfe:	eb e7                	jmp    80101de7 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e00:	b8 01 00 00 00       	mov    $0x1,%eax
80101e05:	e8 1b fe ff ff       	call   80101c25 <idewait>
80101e0a:	85 c0                	test   %eax,%eax
80101e0c:	78 a5                	js     80101db3 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101e0e:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101e11:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e16:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e1b:	fc                   	cld    
80101e1c:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e1e:	eb 93                	jmp    80101db3 <ideintr+0x2c>

80101e20 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e20:	55                   	push   %ebp
80101e21:	89 e5                	mov    %esp,%ebp
80101e23:	53                   	push   %ebx
80101e24:	83 ec 10             	sub    $0x10,%esp
80101e27:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e2a:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e2d:	50                   	push   %eax
80101e2e:	e8 c3 1f 00 00       	call   80103df6 <holdingsleep>
80101e33:	83 c4 10             	add    $0x10,%esp
80101e36:	85 c0                	test   %eax,%eax
80101e38:	74 37                	je     80101e71 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e3a:	8b 03                	mov    (%ebx),%eax
80101e3c:	83 e0 06             	and    $0x6,%eax
80101e3f:	83 f8 02             	cmp    $0x2,%eax
80101e42:	74 3a                	je     80101e7e <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e44:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e48:	74 09                	je     80101e53 <iderw+0x33>
80101e4a:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101e51:	74 38                	je     80101e8b <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e53:	83 ec 0c             	sub    $0xc,%esp
80101e56:	68 80 a5 10 80       	push   $0x8010a580
80101e5b:	e8 20 21 00 00       	call   80103f80 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e60:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e67:	83 c4 10             	add    $0x10,%esp
80101e6a:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e6f:	eb 2a                	jmp    80101e9b <iderw+0x7b>
    panic("iderw: buf not locked");
80101e71:	83 ec 0c             	sub    $0xc,%esp
80101e74:	68 ea 6a 10 80       	push   $0x80106aea
80101e79:	e8 ca e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e7e:	83 ec 0c             	sub    $0xc,%esp
80101e81:	68 00 6b 10 80       	push   $0x80106b00
80101e86:	e8 bd e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e8b:	83 ec 0c             	sub    $0xc,%esp
80101e8e:	68 15 6b 10 80       	push   $0x80106b15
80101e93:	e8 b0 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e98:	8d 50 58             	lea    0x58(%eax),%edx
80101e9b:	8b 02                	mov    (%edx),%eax
80101e9d:	85 c0                	test   %eax,%eax
80101e9f:	75 f7                	jne    80101e98 <iderw+0x78>
    ;
  *pp = b;
80101ea1:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101ea3:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101ea9:	75 1a                	jne    80101ec5 <iderw+0xa5>
    idestart(b);
80101eab:	89 d8                	mov    %ebx,%eax
80101ead:	e8 a5 fd ff ff       	call   80101c57 <idestart>
80101eb2:	eb 11                	jmp    80101ec5 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101eb4:	83 ec 08             	sub    $0x8,%esp
80101eb7:	68 80 a5 10 80       	push   $0x8010a580
80101ebc:	53                   	push   %ebx
80101ebd:	e8 5c 1b 00 00       	call   80103a1e <sleep>
80101ec2:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101ec5:	8b 03                	mov    (%ebx),%eax
80101ec7:	83 e0 06             	and    $0x6,%eax
80101eca:	83 f8 02             	cmp    $0x2,%eax
80101ecd:	75 e5                	jne    80101eb4 <iderw+0x94>
  }


  release(&idelock);
80101ecf:	83 ec 0c             	sub    $0xc,%esp
80101ed2:	68 80 a5 10 80       	push   $0x8010a580
80101ed7:	e8 09 21 00 00       	call   80103fe5 <release>
}
80101edc:	83 c4 10             	add    $0x10,%esp
80101edf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ee2:	c9                   	leave  
80101ee3:	c3                   	ret    

80101ee4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ee4:	55                   	push   %ebp
80101ee5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ee7:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101eed:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101eef:	a1 34 26 11 80       	mov    0x80112634,%eax
80101ef4:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ef7:	5d                   	pop    %ebp
80101ef8:	c3                   	ret    

80101ef9 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ef9:	55                   	push   %ebp
80101efa:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101efc:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101f02:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101f04:	a1 34 26 11 80       	mov    0x80112634,%eax
80101f09:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f0c:	5d                   	pop    %ebp
80101f0d:	c3                   	ret    

80101f0e <ioapicinit>:

void
ioapicinit(void)
{
80101f0e:	55                   	push   %ebp
80101f0f:	89 e5                	mov    %esp,%ebp
80101f11:	57                   	push   %edi
80101f12:	56                   	push   %esi
80101f13:	53                   	push   %ebx
80101f14:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f17:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
80101f1e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f21:	b8 01 00 00 00       	mov    $0x1,%eax
80101f26:	e8 b9 ff ff ff       	call   80101ee4 <ioapicread>
80101f2b:	c1 e8 10             	shr    $0x10,%eax
80101f2e:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f31:	b8 00 00 00 00       	mov    $0x0,%eax
80101f36:	e8 a9 ff ff ff       	call   80101ee4 <ioapicread>
80101f3b:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f3e:	0f b6 15 00 95 1e 80 	movzbl 0x801e9500,%edx
80101f45:	39 c2                	cmp    %eax,%edx
80101f47:	75 07                	jne    80101f50 <ioapicinit+0x42>
{
80101f49:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f4e:	eb 36                	jmp    80101f86 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f50:	83 ec 0c             	sub    $0xc,%esp
80101f53:	68 34 6b 10 80       	push   $0x80106b34
80101f58:	e8 ae e6 ff ff       	call   8010060b <cprintf>
80101f5d:	83 c4 10             	add    $0x10,%esp
80101f60:	eb e7                	jmp    80101f49 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f62:	8d 53 20             	lea    0x20(%ebx),%edx
80101f65:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f6b:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f6f:	89 f0                	mov    %esi,%eax
80101f71:	e8 83 ff ff ff       	call   80101ef9 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f76:	8d 46 01             	lea    0x1(%esi),%eax
80101f79:	ba 00 00 00 00       	mov    $0x0,%edx
80101f7e:	e8 76 ff ff ff       	call   80101ef9 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f83:	83 c3 01             	add    $0x1,%ebx
80101f86:	39 fb                	cmp    %edi,%ebx
80101f88:	7e d8                	jle    80101f62 <ioapicinit+0x54>
  }
}
80101f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f8d:	5b                   	pop    %ebx
80101f8e:	5e                   	pop    %esi
80101f8f:	5f                   	pop    %edi
80101f90:	5d                   	pop    %ebp
80101f91:	c3                   	ret    

80101f92 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f92:	55                   	push   %ebp
80101f93:	89 e5                	mov    %esp,%ebp
80101f95:	53                   	push   %ebx
80101f96:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f99:	8d 50 20             	lea    0x20(%eax),%edx
80101f9c:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101fa0:	89 d8                	mov    %ebx,%eax
80101fa2:	e8 52 ff ff ff       	call   80101ef9 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101fa7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101faa:	c1 e2 18             	shl    $0x18,%edx
80101fad:	8d 43 01             	lea    0x1(%ebx),%eax
80101fb0:	e8 44 ff ff ff       	call   80101ef9 <ioapicwrite>
}
80101fb5:	5b                   	pop    %ebx
80101fb6:	5d                   	pop    %ebp
80101fb7:	c3                   	ret    

80101fb8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fb8:	55                   	push   %ebp
80101fb9:	89 e5                	mov    %esp,%ebp
80101fbb:	57                   	push   %edi
80101fbc:	56                   	push   %esi
80101fbd:	53                   	push   %ebx
80101fbe:	83 ec 0c             	sub    $0xc,%esp
80101fc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fc4:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fca:	75 52                	jne    8010201e <kfree+0x66>
80101fcc:	81 fb 48 c2 1e 80    	cmp    $0x801ec248,%ebx
80101fd2:	72 4a                	jb     8010201e <kfree+0x66>
80101fd4:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80101fda:	81 fe ff ff ff 0d    	cmp    $0xdffffff,%esi
80101fe0:	77 3c                	ja     8010201e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fe2:	83 ec 04             	sub    $0x4,%esp
80101fe5:	68 00 10 00 00       	push   $0x1000
80101fea:	6a 01                	push   $0x1
80101fec:	53                   	push   %ebx
80101fed:	e8 3a 20 00 00       	call   8010402c <memset>
  if(numframes > 0) {
80101ff2:	8b 0d 00 80 10 80    	mov    0x80108000,%ecx
80101ff8:	83 c4 10             	add    $0x10,%esp
80101ffb:	85 c9                	test   %ecx,%ecx
80101ffd:	7e 67                	jle    80102066 <kfree+0xae>
      int frameFreed = (V2P(v) >> 12 & 0xffff);
80101fff:	89 f2                	mov    %esi,%edx
80102001:	c1 ea 0c             	shr    $0xc,%edx
80102004:	0f b7 d2             	movzwl %dx,%edx
      int i;
      for(i= 0; i<numframes; i++) {
80102007:	b8 00 00 00 00       	mov    $0x0,%eax
8010200c:	39 c1                	cmp    %eax,%ecx
8010200e:	7e 3c                	jle    8010204c <kfree+0x94>
          if(frames[i] == frameFreed) {
80102010:	39 14 85 80 5b 1d 80 	cmp    %edx,-0x7fe2a480(,%eax,4)
80102017:	74 33                	je     8010204c <kfree+0x94>
      for(i= 0; i<numframes; i++) {
80102019:	83 c0 01             	add    $0x1,%eax
8010201c:	eb ee                	jmp    8010200c <kfree+0x54>
    panic("kfree");
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 66 6b 10 80       	push   $0x80106b66
80102026:	e8 1d e3 ff ff       	call   80100348 <panic>
              break;
          }
      } 
      for(int z = i; z < numframes; z++) {
          frames[z] = frames[z+1];
8010202b:	8d 50 01             	lea    0x1(%eax),%edx
8010202e:	8b 3c 95 80 5b 1d 80 	mov    -0x7fe2a480(,%edx,4),%edi
80102035:	89 3c 85 80 5b 1d 80 	mov    %edi,-0x7fe2a480(,%eax,4)
          pid[z] = pid[z+1];
8010203c:	8b 3c 95 80 26 11 80 	mov    -0x7feed980(,%edx,4),%edi
80102043:	89 3c 85 80 26 11 80 	mov    %edi,-0x7feed980(,%eax,4)
      for(int z = i; z < numframes; z++) {
8010204a:	89 d0                	mov    %edx,%eax
8010204c:	39 c1                	cmp    %eax,%ecx
8010204e:	7f db                	jg     8010202b <kfree+0x73>
      }
      frames[numframes] = 0;
80102050:	c7 04 8d 80 5b 1d 80 	movl   $0x0,-0x7fe2a480(,%ecx,4)
80102057:	00 00 00 00 
      pid[numframes] = 0;
8010205b:	c7 04 8d 80 26 11 80 	movl   $0x0,-0x7feed980(,%ecx,4)
80102062:	00 00 00 00 
      //numframes--;
//      cprintf("Frame freed: %x at %d with numframes: %d and previous element as %x \n", frameFreed, i, numframes, frames[i-1]);
  }

  if(kmem.use_lock)
80102066:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010206d:	75 19                	jne    80102088 <kfree+0xd0>
    acquire(&kmem.lock);
  r = (struct run*)v;
  //struct run *head = kmem.freelist;
  struct run *current = kmem.freelist;
8010206f:	8b 15 78 26 11 80    	mov    0x80112678,%edx
  struct run *temp = current;
  int frameFreed = (V2P(v) >> 12 & 0xfffff);
80102075:	c1 ee 0c             	shr    $0xc,%esi
  char* currentNodeFrame = (char*)current;
  int frameAddress = (V2P(currentNodeFrame) >> 12 & 0xffff);
80102078:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
8010207e:	c1 e8 0c             	shr    $0xc,%eax
80102081:	0f b7 c0             	movzwl %ax,%eax
  struct run *temp = current;
80102084:	89 d7                	mov    %edx,%edi
  while(frameAddress > frameFreed)
80102086:	eb 24                	jmp    801020ac <kfree+0xf4>
    acquire(&kmem.lock);
80102088:	83 ec 0c             	sub    $0xc,%esp
8010208b:	68 40 26 11 80       	push   $0x80112640
80102090:	e8 eb 1e 00 00       	call   80103f80 <acquire>
80102095:	83 c4 10             	add    $0x10,%esp
80102098:	eb d5                	jmp    8010206f <kfree+0xb7>
  {
	  temp = current;
	  current = current->next;
8010209a:	8b 0a                	mov    (%edx),%ecx
	  frameAddress = (V2P((struct run*)current)  >> 12 & 0xffff);
8010209c:	8d 81 00 00 00 80    	lea    -0x80000000(%ecx),%eax
801020a2:	c1 e8 0c             	shr    $0xc,%eax
801020a5:	0f b7 c0             	movzwl %ax,%eax
	  temp = current;
801020a8:	89 d7                	mov    %edx,%edi
	  current = current->next;
801020aa:	89 ca                	mov    %ecx,%edx
  while(frameAddress > frameFreed)
801020ac:	39 f0                	cmp    %esi,%eax
801020ae:	7f ea                	jg     8010209a <kfree+0xe2>
  }
  if(current == temp) {
801020b0:	39 fa                	cmp    %edi,%edx
801020b2:	74 17                	je     801020cb <kfree+0x113>

    r->next = temp;
    kmem.freelist = r;
  }
  else{
     r->next = temp->next;
801020b4:	8b 07                	mov    (%edi),%eax
801020b6:	89 03                	mov    %eax,(%ebx)
     temp->next= r;
801020b8:	89 1f                	mov    %ebx,(%edi)
  }
  if(kmem.use_lock)
801020ba:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801020c1:	75 12                	jne    801020d5 <kfree+0x11d>
    release(&kmem.lock);
}
801020c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020c6:	5b                   	pop    %ebx
801020c7:	5e                   	pop    %esi
801020c8:	5f                   	pop    %edi
801020c9:	5d                   	pop    %ebp
801020ca:	c3                   	ret    
    r->next = temp;
801020cb:	89 3b                	mov    %edi,(%ebx)
    kmem.freelist = r;
801020cd:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
801020d3:	eb e5                	jmp    801020ba <kfree+0x102>
    release(&kmem.lock);
801020d5:	83 ec 0c             	sub    $0xc,%esp
801020d8:	68 40 26 11 80       	push   $0x80112640
801020dd:	e8 03 1f 00 00       	call   80103fe5 <release>
801020e2:	83 c4 10             	add    $0x10,%esp
}
801020e5:	eb dc                	jmp    801020c3 <kfree+0x10b>

801020e7 <freerange>:
{
801020e7:	55                   	push   %ebp
801020e8:	89 e5                	mov    %esp,%ebp
801020ea:	56                   	push   %esi
801020eb:	53                   	push   %ebx
801020ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	05 ff 0f 00 00       	add    $0xfff,%eax
801020f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801020fc:	eb 0e                	jmp    8010210c <freerange+0x25>
    kfree(p);
801020fe:	83 ec 0c             	sub    $0xc,%esp
80102101:	50                   	push   %eax
80102102:	e8 b1 fe ff ff       	call   80101fb8 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	89 f0                	mov    %esi,%eax
8010210c:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80102112:	39 de                	cmp    %ebx,%esi
80102114:	76 e8                	jbe    801020fe <freerange+0x17>
}
80102116:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102119:	5b                   	pop    %ebx
8010211a:	5e                   	pop    %esi
8010211b:	5d                   	pop    %ebp
8010211c:	c3                   	ret    

8010211d <kinit1>:
{
8010211d:	55                   	push   %ebp
8010211e:	89 e5                	mov    %esp,%ebp
80102120:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80102123:	68 6c 6b 10 80       	push   $0x80106b6c
80102128:	68 40 26 11 80       	push   $0x80112640
8010212d:	e8 12 1d 00 00       	call   80103e44 <initlock>
  kmem.use_lock = 0;
80102132:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102139:	00 00 00 
  freerange(vstart, vend);
8010213c:	83 c4 08             	add    $0x8,%esp
8010213f:	ff 75 0c             	pushl  0xc(%ebp)
80102142:	ff 75 08             	pushl  0x8(%ebp)
80102145:	e8 9d ff ff ff       	call   801020e7 <freerange>
}
8010214a:	83 c4 10             	add    $0x10,%esp
8010214d:	c9                   	leave  
8010214e:	c3                   	ret    

8010214f <kinit2>:
{
8010214f:	55                   	push   %ebp
80102150:	89 e5                	mov    %esp,%ebp
80102152:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102155:	ff 75 0c             	pushl  0xc(%ebp)
80102158:	ff 75 08             	pushl  0x8(%ebp)
8010215b:	e8 87 ff ff ff       	call   801020e7 <freerange>
  kmem.use_lock = 1;
80102160:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
80102167:	00 00 00 
}
8010216a:	83 c4 10             	add    $0x10,%esp
8010216d:	c9                   	leave  
8010216e:	c3                   	ret    

8010216f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010216f:	55                   	push   %ebp
80102170:	89 e5                	mov    %esp,%ebp
80102172:	57                   	push   %edi
80102173:	56                   	push   %esi
80102174:	53                   	push   %ebx
80102175:	83 ec 1c             	sub    $0x1c,%esp
  struct run *r;
  //cprintf("First CAME HERE! \n");
  if(kmem.use_lock)
80102178:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010217f:	75 3c                	jne    801021bd <kalloc+0x4e>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102181:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
80102187:	85 db                	test   %ebx,%ebx
80102189:	74 07                	je     80102192 <kalloc+0x23>
    kmem.freelist = r->next;
8010218b:	8b 03                	mov    (%ebx),%eax
8010218d:	a3 78 26 11 80       	mov    %eax,0x80112678
  
  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
80102192:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80102198:	c1 ee 0c             	shr    $0xc,%esi
8010219b:	0f b7 f6             	movzwl %si,%esi
  int i; 
  for(i = 0; i< numframes; i++) {
8010219e:	b9 00 00 00 00       	mov    $0x0,%ecx
801021a3:	8b 3d 00 80 10 80    	mov    0x80108000,%edi
801021a9:	39 cf                	cmp    %ecx,%edi
801021ab:	7e 27                	jle    801021d4 <kalloc+0x65>
      if(frames[i] > frameNumberFound) {
801021ad:	39 34 8d 80 5b 1d 80 	cmp    %esi,-0x7fe2a480(,%ecx,4)
801021b4:	7f 19                	jg     801021cf <kalloc+0x60>
801021b6:	89 f8                	mov    %edi,%eax
801021b8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801021bb:	eb 3f                	jmp    801021fc <kalloc+0x8d>
    acquire(&kmem.lock);
801021bd:	83 ec 0c             	sub    $0xc,%esp
801021c0:	68 40 26 11 80       	push   $0x80112640
801021c5:	e8 b6 1d 00 00       	call   80103f80 <acquire>
801021ca:	83 c4 10             	add    $0x10,%esp
801021cd:	eb b2                	jmp    80102181 <kalloc+0x12>
  for(i = 0; i< numframes; i++) {
801021cf:	83 c1 01             	add    $0x1,%ecx
801021d2:	eb cf                	jmp    801021a3 <kalloc+0x34>
801021d4:	89 f8                	mov    %edi,%eax
801021d6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801021d9:	eb 21                	jmp    801021fc <kalloc+0x8d>
      }
  }
  //cprintf("KALLOC: Will enter at %d \n", i);
  for(int z = numframes ; z >= i; z--) {
      //cprintf("%x,%x\n", frames[z], frames[z-1]);
      frames[z] = frames[z-1];
801021db:	8d 50 ff             	lea    -0x1(%eax),%edx
801021de:	8b 1c 95 80 5b 1d 80 	mov    -0x7fe2a480(,%edx,4),%ebx
801021e5:	89 1c 85 80 5b 1d 80 	mov    %ebx,-0x7fe2a480(,%eax,4)
      pid[z] = pid[z-1];
801021ec:	8b 1c 95 80 26 11 80 	mov    -0x7feed980(,%edx,4),%ebx
801021f3:	89 1c 85 80 26 11 80 	mov    %ebx,-0x7feed980(,%eax,4)
  for(int z = numframes ; z >= i; z--) {
801021fa:	89 d0                	mov    %edx,%eax
801021fc:	39 c1                	cmp    %eax,%ecx
801021fe:	7e db                	jle    801021db <kalloc+0x6c>
80102200:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  }

  numframes++;
80102203:	83 c7 01             	add    $0x1,%edi
80102206:	89 3d 00 80 10 80    	mov    %edi,0x80108000
  frames[i] = frameNumberFound;
8010220c:	89 34 8d 80 5b 1d 80 	mov    %esi,-0x7fe2a480(,%ecx,4)
  pid[i] = -2;
80102213:	c7 04 8d 80 26 11 80 	movl   $0xfffffffe,-0x7feed980(,%ecx,4)
8010221a:	fe ff ff ff 

//  cprintf("ALLOCATED KALLOC: NumFrames: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[i], pid[i]);
  if(kmem.use_lock)
8010221e:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102225:	75 0a                	jne    80102231 <kalloc+0xc2>
    release(&kmem.lock);
  return (char*)r;
}
80102227:	89 d8                	mov    %ebx,%eax
80102229:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010222c:	5b                   	pop    %ebx
8010222d:	5e                   	pop    %esi
8010222e:	5f                   	pop    %edi
8010222f:	5d                   	pop    %ebp
80102230:	c3                   	ret    
    release(&kmem.lock);
80102231:	83 ec 0c             	sub    $0xc,%esp
80102234:	68 40 26 11 80       	push   $0x80112640
80102239:	e8 a7 1d 00 00       	call   80103fe5 <release>
8010223e:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102241:	eb e4                	jmp    80102227 <kalloc+0xb8>

80102243 <kalloc1a>:

char*
kalloc1a(int processPid)
{
80102243:	55                   	push   %ebp
80102244:	89 e5                	mov    %esp,%ebp
80102246:	53                   	push   %ebx
80102247:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
8010224a:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102251:	75 4d                	jne    801022a0 <kalloc1a+0x5d>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102253:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
80102259:	85 db                	test   %ebx,%ebx
8010225b:	74 09                	je     80102266 <kalloc1a+0x23>
    kmem.freelist = r->next->next;
8010225d:	8b 03                	mov    (%ebx),%eax
8010225f:	8b 00                	mov    (%eax),%eax
80102261:	a3 78 26 11 80       	mov    %eax,0x80112678

  char* ptr = (char*)r;
  //cprintf("Allocated KALLOC1A: %x \t %x \t %x \n", PHYSTOP - V2P(ptr), PHYSTOP - (V2P(ptr) >> 12 ), (V2P(ptr) >> 12 & 0xffff));
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
80102266:	8d 93 00 00 00 80    	lea    -0x80000000(%ebx),%edx
8010226c:	c1 ea 0c             	shr    $0xc,%edx
8010226f:	0f b7 d2             	movzwl %dx,%edx
 
  numframes++;
80102272:	a1 00 80 10 80       	mov    0x80108000,%eax
80102277:	83 c0 01             	add    $0x1,%eax
8010227a:	a3 00 80 10 80       	mov    %eax,0x80108000
  frames[numframes] = frameNumberFound;
8010227f:	89 14 85 80 5b 1d 80 	mov    %edx,-0x7fe2a480(,%eax,4)
  pid[numframes] = processPid;
80102286:	8b 55 08             	mov    0x8(%ebp),%edx
80102289:	89 14 85 80 26 11 80 	mov    %edx,-0x7feed980(,%eax,4)

  //cprintf("ALLOCATED KALLOC1A: Numframes: %d, i: not there currently , frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
  if(kmem.use_lock)
80102290:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102297:	75 19                	jne    801022b2 <kalloc1a+0x6f>
    release(&kmem.lock);
  return (char*)r;
}
80102299:	89 d8                	mov    %ebx,%eax
8010229b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010229e:	c9                   	leave  
8010229f:	c3                   	ret    
    acquire(&kmem.lock);
801022a0:	83 ec 0c             	sub    $0xc,%esp
801022a3:	68 40 26 11 80       	push   $0x80112640
801022a8:	e8 d3 1c 00 00       	call   80103f80 <acquire>
801022ad:	83 c4 10             	add    $0x10,%esp
801022b0:	eb a1                	jmp    80102253 <kalloc1a+0x10>
    release(&kmem.lock);
801022b2:	83 ec 0c             	sub    $0xc,%esp
801022b5:	68 40 26 11 80       	push   $0x80112640
801022ba:	e8 26 1d 00 00       	call   80103fe5 <release>
801022bf:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801022c2:	eb d5                	jmp    80102299 <kalloc1a+0x56>

801022c4 <kalloc2>:

char*
kalloc2(int processPid)
{
801022c4:	55                   	push   %ebp
801022c5:	89 e5                	mov    %esp,%ebp
801022c7:	57                   	push   %edi
801022c8:	56                   	push   %esi
801022c9:	53                   	push   %ebx
801022ca:	83 ec 1c             	sub    $0x1c,%esp
  struct run *r;
  struct run *head = kmem.freelist;
801022cd:	a1 78 26 11 80       	mov    0x80112678,%eax
801022d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct run *temp = kmem.freelist;

  if(kmem.use_lock)
801022d5:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801022dc:	75 40                	jne    8010231e <kalloc2+0x5a>
     acquire(&kmem.lock);
  int firstPass = 1;
801022de:	b9 01 00 00 00       	mov    $0x1,%ecx

  repeat: 
  if(firstPass == 1) {
801022e3:	83 f9 01             	cmp    $0x1,%ecx
801022e6:	74 48                	je     80102330 <kalloc2+0x6c>
    r = kmem.freelist;
  } else {
    r = r->next;
801022e8:	8b 3f                	mov    (%edi),%edi
  }
  
  firstPass = 0;
  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);  
801022ea:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
801022f0:	c1 e8 0c             	shr    $0xc,%eax
801022f3:	0f b7 c0             	movzwl %ax,%eax
  //cprintf("Frame Number found %x for processID %d \n", frameNumberFound, processPid);

  int i;
  for(i = 0; i< numframes; i++) {
801022f6:	be 00 00 00 00       	mov    $0x0,%esi
801022fb:	8b 15 00 80 10 80    	mov    0x80108000,%edx
80102301:	39 f2                	cmp    %esi,%edx
80102303:	7e 55                	jle    8010235a <kalloc2+0x96>
     if(frames[i] == (frameNumberFound - 1)) {
80102305:	8b 0c b5 80 5b 1d 80 	mov    -0x7fe2a480(,%esi,4),%ecx
8010230c:	8d 58 ff             	lea    -0x1(%eax),%ebx
8010230f:	39 d9                	cmp    %ebx,%ecx
80102311:	74 25                	je     80102338 <kalloc2+0x74>
            goto repeat;
	 } else if (pid[i] == -2) {
            continue;
	 }
     }*/
     if(frames[i] > (frameNumberFound)) {
80102313:	39 c1                	cmp    %eax,%ecx
80102315:	7f 3e                	jg     80102355 <kalloc2+0x91>
80102317:	bb 00 00 00 00       	mov    $0x0,%ebx
8010231c:	eb 46                	jmp    80102364 <kalloc2+0xa0>
     acquire(&kmem.lock);
8010231e:	83 ec 0c             	sub    $0xc,%esp
80102321:	68 40 26 11 80       	push   $0x80112640
80102326:	e8 55 1c 00 00       	call   80103f80 <acquire>
8010232b:	83 c4 10             	add    $0x10,%esp
8010232e:	eb ae                	jmp    801022de <kalloc2+0x1a>
    r = kmem.freelist;
80102330:	8b 3d 78 26 11 80    	mov    0x80112678,%edi
80102336:	eb b2                	jmp    801022ea <kalloc2+0x26>
          if(pid[i] == -2) {
80102338:	8b 1c b5 80 26 11 80 	mov    -0x7feed980(,%esi,4),%ebx
8010233f:	83 fb fe             	cmp    $0xfffffffe,%ebx
80102342:	74 4b                	je     8010238f <kalloc2+0xcb>
80102344:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	  } else if(pid[i] != processPid) {
8010234b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
8010234e:	74 c3                	je     80102313 <kalloc2+0x4f>
80102350:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80102353:	eb 8e                	jmp    801022e3 <kalloc2+0x1f>
  for(i = 0; i< numframes; i++) {
80102355:	83 c6 01             	add    $0x1,%esi
80102358:	eb a1                	jmp    801022fb <kalloc2+0x37>
8010235a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010235f:	eb 03                	jmp    80102364 <kalloc2+0xa0>
         continue;
     }
     break;
  }

  for(int j = 0; j< numframes; j++) {
80102361:	83 c3 01             	add    $0x1,%ebx
80102364:	39 da                	cmp    %ebx,%edx
80102366:	7e 2e                	jle    80102396 <kalloc2+0xd2>
    if(frames[j] == (frameNumberFound + 1)) {
80102368:	8d 48 01             	lea    0x1(%eax),%ecx
8010236b:	39 0c 9d 80 5b 1d 80 	cmp    %ecx,-0x7fe2a480(,%ebx,4)
80102372:	75 ed                	jne    80102361 <kalloc2+0x9d>
	if(pid[j] == -2) {
80102374:	8b 34 9d 80 26 11 80 	mov    -0x7feed980(,%ebx,4),%esi
8010237b:	83 fe fe             	cmp    $0xfffffffe,%esi
8010237e:	74 59                	je     801023d9 <kalloc2+0x115>
80102380:	b9 00 00 00 00       	mov    $0x0,%ecx
           break;
	} else if(pid[j] != processPid) {
80102385:	3b 75 08             	cmp    0x8(%ebp),%esi
80102388:	74 d7                	je     80102361 <kalloc2+0x9d>
  repeat: 
8010238a:	e9 54 ff ff ff       	jmp    801022e3 <kalloc2+0x1f>
8010238f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102394:	eb ce                	jmp    80102364 <kalloc2+0xa0>
80102396:	be 00 00 00 00       	mov    $0x0,%esi
        continue;
    }
  }

  int c;
  for(c = 0; c< numframes; c++) {
8010239b:	39 f2                	cmp    %esi,%edx
8010239d:	7e 41                	jle    801023e0 <kalloc2+0x11c>
        if(frames[c] > frameNumberFound) {
8010239f:	39 04 b5 80 5b 1d 80 	cmp    %eax,-0x7fe2a480(,%esi,4)
801023a6:	7f 2c                	jg     801023d4 <kalloc2+0x110>
801023a8:	89 d1                	mov    %edx,%ecx
801023aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	} else {
	        break;
        }
  }
  //cprintf("KALLOC2: Will enter at %d \n", c);
  for(int z = numframes ; z >= c; z--) {
801023ad:	39 ce                	cmp    %ecx,%esi
801023af:	7f 36                	jg     801023e7 <kalloc2+0x123>
	 //cprintf("%x,%x\n", frames[z], frames[z-1]);
        frames[z] = frames[z-1];
801023b1:	8d 59 ff             	lea    -0x1(%ecx),%ebx
801023b4:	8b 04 9d 80 5b 1d 80 	mov    -0x7fe2a480(,%ebx,4),%eax
801023bb:	89 04 8d 80 5b 1d 80 	mov    %eax,-0x7fe2a480(,%ecx,4)
	pid[z] = pid[z-1];
801023c2:	8b 04 9d 80 26 11 80 	mov    -0x7feed980(,%ebx,4),%eax
801023c9:	89 04 8d 80 26 11 80 	mov    %eax,-0x7feed980(,%ecx,4)
  for(int z = numframes ; z >= c; z--) {
801023d0:	89 d9                	mov    %ebx,%ecx
801023d2:	eb d9                	jmp    801023ad <kalloc2+0xe9>
  for(c = 0; c< numframes; c++) {
801023d4:	83 c6 01             	add    $0x1,%esi
801023d7:	eb c2                	jmp    8010239b <kalloc2+0xd7>
801023d9:	be 00 00 00 00       	mov    $0x0,%esi
801023de:	eb bb                	jmp    8010239b <kalloc2+0xd7>
801023e0:	89 d1                	mov    %edx,%ecx
801023e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801023e5:	eb c6                	jmp    801023ad <kalloc2+0xe9>
801023e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  }

  numframes++;
801023ea:	83 c2 01             	add    $0x1,%edx
801023ed:	89 15 00 80 10 80    	mov    %edx,0x80108000
  frames[c] = frameNumberFound;
801023f3:	89 04 b5 80 5b 1d 80 	mov    %eax,-0x7fe2a480(,%esi,4)
  pid[c] = processPid;
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
801023fd:	89 04 b5 80 26 11 80 	mov    %eax,-0x7feed980(,%esi,4)
  //cprintf("prev pid: %d, cur pid:%d, next pid%d\n",pid[c-1],pid[c],pid[c+1]);
 //cprintf("ALLOCATED KALLOC2: NumFrames: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[c], pid[c]);

 if(head == r) {
80102404:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
80102407:	74 05                	je     8010240e <kalloc2+0x14a>
  struct run *temp = kmem.freelist;
80102409:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010240c:	eb 0b                	jmp    80102419 <kalloc2+0x155>
  kmem.freelist = r->next;
8010240e:	8b 07                	mov    (%edi),%eax
80102410:	a3 78 26 11 80       	mov    %eax,0x80112678
80102415:	eb 14                	jmp    8010242b <kalloc2+0x167>
 } else {
   while(temp->next != r) {
        temp = temp->next;
80102417:	89 c2                	mov    %eax,%edx
   while(temp->next != r) {
80102419:	8b 02                	mov    (%edx),%eax
8010241b:	39 f8                	cmp    %edi,%eax
8010241d:	75 f8                	jne    80102417 <kalloc2+0x153>
   }
   temp->next = r->next;
8010241f:	8b 07                	mov    (%edi),%eax
80102421:	89 02                	mov    %eax,(%edx)
   kmem.freelist = head;
80102423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102426:	a3 78 26 11 80       	mov    %eax,0x80112678
 //struct run* new = kmem.freelist;
 //char* ptrNew = (char*) new;
 //cprintf("FreeList Head %x \n", (V2P(ptrNew) >> 12 & 0xffff));

 //kmem.freelist = r->next->next;
  if(kmem.use_lock)
8010242b:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102432:	75 0a                	jne    8010243e <kalloc2+0x17a>
     release(&kmem.lock);
  return (char*)r;
}
80102434:	89 f8                	mov    %edi,%eax
80102436:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102439:	5b                   	pop    %ebx
8010243a:	5e                   	pop    %esi
8010243b:	5f                   	pop    %edi
8010243c:	5d                   	pop    %ebp
8010243d:	c3                   	ret    
     release(&kmem.lock);
8010243e:	83 ec 0c             	sub    $0xc,%esp
80102441:	68 40 26 11 80       	push   $0x80112640
80102446:	e8 9a 1b 00 00       	call   80103fe5 <release>
8010244b:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010244e:	eb e4                	jmp    80102434 <kalloc2+0x170>

80102450 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102450:	55                   	push   %ebp
80102451:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102453:	ba 64 00 00 00       	mov    $0x64,%edx
80102458:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102459:	a8 01                	test   $0x1,%al
8010245b:	0f 84 b5 00 00 00    	je     80102516 <kbdgetc+0xc6>
80102461:	ba 60 00 00 00       	mov    $0x60,%edx
80102466:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102467:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010246a:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102470:	74 5c                	je     801024ce <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102472:	84 c0                	test   %al,%al
80102474:	78 66                	js     801024dc <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102476:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010247c:	f6 c1 40             	test   $0x40,%cl
8010247f:	74 0f                	je     80102490 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102481:	83 c8 80             	or     $0xffffff80,%eax
80102484:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102487:	83 e1 bf             	and    $0xffffffbf,%ecx
8010248a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102490:	0f b6 8a a0 6c 10 80 	movzbl -0x7fef9360(%edx),%ecx
80102497:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
8010249d:	0f b6 82 a0 6b 10 80 	movzbl -0x7fef9460(%edx),%eax
801024a4:	31 c1                	xor    %eax,%ecx
801024a6:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801024ac:	89 c8                	mov    %ecx,%eax
801024ae:	83 e0 03             	and    $0x3,%eax
801024b1:	8b 04 85 80 6b 10 80 	mov    -0x7fef9480(,%eax,4),%eax
801024b8:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801024bc:	f6 c1 08             	test   $0x8,%cl
801024bf:	74 19                	je     801024da <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801024c1:	8d 50 9f             	lea    -0x61(%eax),%edx
801024c4:	83 fa 19             	cmp    $0x19,%edx
801024c7:	77 40                	ja     80102509 <kbdgetc+0xb9>
      c += 'A' - 'a';
801024c9:	83 e8 20             	sub    $0x20,%eax
801024cc:	eb 0c                	jmp    801024da <kbdgetc+0x8a>
    shift |= E0ESC;
801024ce:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
801024d5:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801024da:	5d                   	pop    %ebp
801024db:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801024dc:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801024e2:	f6 c1 40             	test   $0x40,%cl
801024e5:	75 05                	jne    801024ec <kbdgetc+0x9c>
801024e7:	89 c2                	mov    %eax,%edx
801024e9:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801024ec:	0f b6 82 a0 6c 10 80 	movzbl -0x7fef9360(%edx),%eax
801024f3:	83 c8 40             	or     $0x40,%eax
801024f6:	0f b6 c0             	movzbl %al,%eax
801024f9:	f7 d0                	not    %eax
801024fb:	21 c8                	and    %ecx,%eax
801024fd:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
80102502:	b8 00 00 00 00       	mov    $0x0,%eax
80102507:	eb d1                	jmp    801024da <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
80102509:	8d 50 bf             	lea    -0x41(%eax),%edx
8010250c:	83 fa 19             	cmp    $0x19,%edx
8010250f:	77 c9                	ja     801024da <kbdgetc+0x8a>
      c += 'a' - 'A';
80102511:	83 c0 20             	add    $0x20,%eax
  return c;
80102514:	eb c4                	jmp    801024da <kbdgetc+0x8a>
    return -1;
80102516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010251b:	eb bd                	jmp    801024da <kbdgetc+0x8a>

8010251d <kbdintr>:

void
kbdintr(void)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102523:	68 50 24 10 80       	push   $0x80102450
80102528:	e8 11 e2 ff ff       	call   8010073e <consoleintr>
}
8010252d:	83 c4 10             	add    $0x10,%esp
80102530:	c9                   	leave  
80102531:	c3                   	ret    

80102532 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102532:	55                   	push   %ebp
80102533:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102535:	8b 0d 00 94 1e 80    	mov    0x801e9400,%ecx
8010253b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
8010253e:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102540:	a1 00 94 1e 80       	mov    0x801e9400,%eax
80102545:	8b 40 20             	mov    0x20(%eax),%eax
}
80102548:	5d                   	pop    %ebp
80102549:	c3                   	ret    

8010254a <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010254d:	ba 70 00 00 00       	mov    $0x70,%edx
80102552:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102553:	ba 71 00 00 00       	mov    $0x71,%edx
80102558:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102559:	0f b6 c0             	movzbl %al,%eax
}
8010255c:	5d                   	pop    %ebp
8010255d:	c3                   	ret    

8010255e <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010255e:	55                   	push   %ebp
8010255f:	89 e5                	mov    %esp,%ebp
80102561:	53                   	push   %ebx
80102562:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102564:	b8 00 00 00 00       	mov    $0x0,%eax
80102569:	e8 dc ff ff ff       	call   8010254a <cmos_read>
8010256e:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102570:	b8 02 00 00 00       	mov    $0x2,%eax
80102575:	e8 d0 ff ff ff       	call   8010254a <cmos_read>
8010257a:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010257d:	b8 04 00 00 00       	mov    $0x4,%eax
80102582:	e8 c3 ff ff ff       	call   8010254a <cmos_read>
80102587:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010258a:	b8 07 00 00 00       	mov    $0x7,%eax
8010258f:	e8 b6 ff ff ff       	call   8010254a <cmos_read>
80102594:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102597:	b8 08 00 00 00       	mov    $0x8,%eax
8010259c:	e8 a9 ff ff ff       	call   8010254a <cmos_read>
801025a1:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801025a4:	b8 09 00 00 00       	mov    $0x9,%eax
801025a9:	e8 9c ff ff ff       	call   8010254a <cmos_read>
801025ae:	89 43 14             	mov    %eax,0x14(%ebx)
}
801025b1:	5b                   	pop    %ebx
801025b2:	5d                   	pop    %ebp
801025b3:	c3                   	ret    

801025b4 <lapicinit>:
  if(!lapic)
801025b4:	83 3d 00 94 1e 80 00 	cmpl   $0x0,0x801e9400
801025bb:	0f 84 fb 00 00 00    	je     801026bc <lapicinit+0x108>
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801025c4:	ba 3f 01 00 00       	mov    $0x13f,%edx
801025c9:	b8 3c 00 00 00       	mov    $0x3c,%eax
801025ce:	e8 5f ff ff ff       	call   80102532 <lapicw>
  lapicw(TDCR, X1);
801025d3:	ba 0b 00 00 00       	mov    $0xb,%edx
801025d8:	b8 f8 00 00 00       	mov    $0xf8,%eax
801025dd:	e8 50 ff ff ff       	call   80102532 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801025e2:	ba 20 00 02 00       	mov    $0x20020,%edx
801025e7:	b8 c8 00 00 00       	mov    $0xc8,%eax
801025ec:	e8 41 ff ff ff       	call   80102532 <lapicw>
  lapicw(TICR, 10000000);
801025f1:	ba 80 96 98 00       	mov    $0x989680,%edx
801025f6:	b8 e0 00 00 00       	mov    $0xe0,%eax
801025fb:	e8 32 ff ff ff       	call   80102532 <lapicw>
  lapicw(LINT0, MASKED);
80102600:	ba 00 00 01 00       	mov    $0x10000,%edx
80102605:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010260a:	e8 23 ff ff ff       	call   80102532 <lapicw>
  lapicw(LINT1, MASKED);
8010260f:	ba 00 00 01 00       	mov    $0x10000,%edx
80102614:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102619:	e8 14 ff ff ff       	call   80102532 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010261e:	a1 00 94 1e 80       	mov    0x801e9400,%eax
80102623:	8b 40 30             	mov    0x30(%eax),%eax
80102626:	c1 e8 10             	shr    $0x10,%eax
80102629:	3c 03                	cmp    $0x3,%al
8010262b:	77 7b                	ja     801026a8 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010262d:	ba 33 00 00 00       	mov    $0x33,%edx
80102632:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102637:	e8 f6 fe ff ff       	call   80102532 <lapicw>
  lapicw(ESR, 0);
8010263c:	ba 00 00 00 00       	mov    $0x0,%edx
80102641:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102646:	e8 e7 fe ff ff       	call   80102532 <lapicw>
  lapicw(ESR, 0);
8010264b:	ba 00 00 00 00       	mov    $0x0,%edx
80102650:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102655:	e8 d8 fe ff ff       	call   80102532 <lapicw>
  lapicw(EOI, 0);
8010265a:	ba 00 00 00 00       	mov    $0x0,%edx
8010265f:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102664:	e8 c9 fe ff ff       	call   80102532 <lapicw>
  lapicw(ICRHI, 0);
80102669:	ba 00 00 00 00       	mov    $0x0,%edx
8010266e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102673:	e8 ba fe ff ff       	call   80102532 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102678:	ba 00 85 08 00       	mov    $0x88500,%edx
8010267d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102682:	e8 ab fe ff ff       	call   80102532 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102687:	a1 00 94 1e 80       	mov    0x801e9400,%eax
8010268c:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102692:	f6 c4 10             	test   $0x10,%ah
80102695:	75 f0                	jne    80102687 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102697:	ba 00 00 00 00       	mov    $0x0,%edx
8010269c:	b8 20 00 00 00       	mov    $0x20,%eax
801026a1:	e8 8c fe ff ff       	call   80102532 <lapicw>
}
801026a6:	5d                   	pop    %ebp
801026a7:	c3                   	ret    
    lapicw(PCINT, MASKED);
801026a8:	ba 00 00 01 00       	mov    $0x10000,%edx
801026ad:	b8 d0 00 00 00       	mov    $0xd0,%eax
801026b2:	e8 7b fe ff ff       	call   80102532 <lapicw>
801026b7:	e9 71 ff ff ff       	jmp    8010262d <lapicinit+0x79>
801026bc:	f3 c3                	repz ret 

801026be <lapicid>:
{
801026be:	55                   	push   %ebp
801026bf:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801026c1:	a1 00 94 1e 80       	mov    0x801e9400,%eax
801026c6:	85 c0                	test   %eax,%eax
801026c8:	74 08                	je     801026d2 <lapicid+0x14>
  return lapic[ID] >> 24;
801026ca:	8b 40 20             	mov    0x20(%eax),%eax
801026cd:	c1 e8 18             	shr    $0x18,%eax
}
801026d0:	5d                   	pop    %ebp
801026d1:	c3                   	ret    
    return 0;
801026d2:	b8 00 00 00 00       	mov    $0x0,%eax
801026d7:	eb f7                	jmp    801026d0 <lapicid+0x12>

801026d9 <lapiceoi>:
  if(lapic)
801026d9:	83 3d 00 94 1e 80 00 	cmpl   $0x0,0x801e9400
801026e0:	74 14                	je     801026f6 <lapiceoi+0x1d>
{
801026e2:	55                   	push   %ebp
801026e3:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801026e5:	ba 00 00 00 00       	mov    $0x0,%edx
801026ea:	b8 2c 00 00 00       	mov    $0x2c,%eax
801026ef:	e8 3e fe ff ff       	call   80102532 <lapicw>
}
801026f4:	5d                   	pop    %ebp
801026f5:	c3                   	ret    
801026f6:	f3 c3                	repz ret 

801026f8 <microdelay>:
{
801026f8:	55                   	push   %ebp
801026f9:	89 e5                	mov    %esp,%ebp
}
801026fb:	5d                   	pop    %ebp
801026fc:	c3                   	ret    

801026fd <lapicstartap>:
{
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	57                   	push   %edi
80102701:	56                   	push   %esi
80102702:	53                   	push   %ebx
80102703:	8b 75 08             	mov    0x8(%ebp),%esi
80102706:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102709:	b8 0f 00 00 00       	mov    $0xf,%eax
8010270e:	ba 70 00 00 00       	mov    $0x70,%edx
80102713:	ee                   	out    %al,(%dx)
80102714:	b8 0a 00 00 00       	mov    $0xa,%eax
80102719:	ba 71 00 00 00       	mov    $0x71,%edx
8010271e:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
8010271f:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102726:	00 00 
  wrv[1] = addr >> 4;
80102728:	89 f8                	mov    %edi,%eax
8010272a:	c1 e8 04             	shr    $0x4,%eax
8010272d:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102733:	c1 e6 18             	shl    $0x18,%esi
80102736:	89 f2                	mov    %esi,%edx
80102738:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010273d:	e8 f0 fd ff ff       	call   80102532 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102742:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102747:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010274c:	e8 e1 fd ff ff       	call   80102532 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102751:	ba 00 85 00 00       	mov    $0x8500,%edx
80102756:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010275b:	e8 d2 fd ff ff       	call   80102532 <lapicw>
  for(i = 0; i < 2; i++){
80102760:	bb 00 00 00 00       	mov    $0x0,%ebx
80102765:	eb 21                	jmp    80102788 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102767:	89 f2                	mov    %esi,%edx
80102769:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010276e:	e8 bf fd ff ff       	call   80102532 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102773:	89 fa                	mov    %edi,%edx
80102775:	c1 ea 0c             	shr    $0xc,%edx
80102778:	80 ce 06             	or     $0x6,%dh
8010277b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102780:	e8 ad fd ff ff       	call   80102532 <lapicw>
  for(i = 0; i < 2; i++){
80102785:	83 c3 01             	add    $0x1,%ebx
80102788:	83 fb 01             	cmp    $0x1,%ebx
8010278b:	7e da                	jle    80102767 <lapicstartap+0x6a>
}
8010278d:	5b                   	pop    %ebx
8010278e:	5e                   	pop    %esi
8010278f:	5f                   	pop    %edi
80102790:	5d                   	pop    %ebp
80102791:	c3                   	ret    

80102792 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102792:	55                   	push   %ebp
80102793:	89 e5                	mov    %esp,%ebp
80102795:	57                   	push   %edi
80102796:	56                   	push   %esi
80102797:	53                   	push   %ebx
80102798:	83 ec 3c             	sub    $0x3c,%esp
8010279b:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010279e:	b8 0b 00 00 00       	mov    $0xb,%eax
801027a3:	e8 a2 fd ff ff       	call   8010254a <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801027a8:	83 e0 04             	and    $0x4,%eax
801027ab:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801027ad:	8d 45 d0             	lea    -0x30(%ebp),%eax
801027b0:	e8 a9 fd ff ff       	call   8010255e <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801027b5:	b8 0a 00 00 00       	mov    $0xa,%eax
801027ba:	e8 8b fd ff ff       	call   8010254a <cmos_read>
801027bf:	a8 80                	test   $0x80,%al
801027c1:	75 ea                	jne    801027ad <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801027c3:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801027c6:	89 d8                	mov    %ebx,%eax
801027c8:	e8 91 fd ff ff       	call   8010255e <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801027cd:	83 ec 04             	sub    $0x4,%esp
801027d0:	6a 18                	push   $0x18
801027d2:	53                   	push   %ebx
801027d3:	8d 45 d0             	lea    -0x30(%ebp),%eax
801027d6:	50                   	push   %eax
801027d7:	e8 96 18 00 00       	call   80104072 <memcmp>
801027dc:	83 c4 10             	add    $0x10,%esp
801027df:	85 c0                	test   %eax,%eax
801027e1:	75 ca                	jne    801027ad <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801027e3:	85 ff                	test   %edi,%edi
801027e5:	0f 85 84 00 00 00    	jne    8010286f <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801027eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
801027ee:	89 d0                	mov    %edx,%eax
801027f0:	c1 e8 04             	shr    $0x4,%eax
801027f3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027f6:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801027f9:	83 e2 0f             	and    $0xf,%edx
801027fc:	01 d0                	add    %edx,%eax
801027fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102801:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102804:	89 d0                	mov    %edx,%eax
80102806:	c1 e8 04             	shr    $0x4,%eax
80102809:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010280c:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010280f:	83 e2 0f             	and    $0xf,%edx
80102812:	01 d0                	add    %edx,%eax
80102814:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102817:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010281a:	89 d0                	mov    %edx,%eax
8010281c:	c1 e8 04             	shr    $0x4,%eax
8010281f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102822:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102825:	83 e2 0f             	and    $0xf,%edx
80102828:	01 d0                	add    %edx,%eax
8010282a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
8010282d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102830:	89 d0                	mov    %edx,%eax
80102832:	c1 e8 04             	shr    $0x4,%eax
80102835:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102838:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010283b:	83 e2 0f             	and    $0xf,%edx
8010283e:	01 d0                	add    %edx,%eax
80102840:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102843:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102846:	89 d0                	mov    %edx,%eax
80102848:	c1 e8 04             	shr    $0x4,%eax
8010284b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010284e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102851:	83 e2 0f             	and    $0xf,%edx
80102854:	01 d0                	add    %edx,%eax
80102856:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102859:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010285c:	89 d0                	mov    %edx,%eax
8010285e:	c1 e8 04             	shr    $0x4,%eax
80102861:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102864:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102867:	83 e2 0f             	and    $0xf,%edx
8010286a:	01 d0                	add    %edx,%eax
8010286c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
8010286f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102872:	89 06                	mov    %eax,(%esi)
80102874:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102877:	89 46 04             	mov    %eax,0x4(%esi)
8010287a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010287d:	89 46 08             	mov    %eax,0x8(%esi)
80102880:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102883:	89 46 0c             	mov    %eax,0xc(%esi)
80102886:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102889:	89 46 10             	mov    %eax,0x10(%esi)
8010288c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010288f:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102892:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102899:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010289c:	5b                   	pop    %ebx
8010289d:	5e                   	pop    %esi
8010289e:	5f                   	pop    %edi
8010289f:	5d                   	pop    %ebp
801028a0:	c3                   	ret    

801028a1 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801028a1:	55                   	push   %ebp
801028a2:	89 e5                	mov    %esp,%ebp
801028a4:	53                   	push   %ebx
801028a5:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801028a8:	ff 35 54 94 1e 80    	pushl  0x801e9454
801028ae:	ff 35 64 94 1e 80    	pushl  0x801e9464
801028b4:	e8 b3 d8 ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801028b9:	8b 58 5c             	mov    0x5c(%eax),%ebx
801028bc:	89 1d 68 94 1e 80    	mov    %ebx,0x801e9468
  for (i = 0; i < log.lh.n; i++) {
801028c2:	83 c4 10             	add    $0x10,%esp
801028c5:	ba 00 00 00 00       	mov    $0x0,%edx
801028ca:	eb 0e                	jmp    801028da <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801028cc:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801028d0:	89 0c 95 6c 94 1e 80 	mov    %ecx,-0x7fe16b94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801028d7:	83 c2 01             	add    $0x1,%edx
801028da:	39 d3                	cmp    %edx,%ebx
801028dc:	7f ee                	jg     801028cc <read_head+0x2b>
  }
  brelse(buf);
801028de:	83 ec 0c             	sub    $0xc,%esp
801028e1:	50                   	push   %eax
801028e2:	e8 ee d8 ff ff       	call   801001d5 <brelse>
}
801028e7:	83 c4 10             	add    $0x10,%esp
801028ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028ed:	c9                   	leave  
801028ee:	c3                   	ret    

801028ef <install_trans>:
{
801028ef:	55                   	push   %ebp
801028f0:	89 e5                	mov    %esp,%ebp
801028f2:	57                   	push   %edi
801028f3:	56                   	push   %esi
801028f4:	53                   	push   %ebx
801028f5:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801028f8:	bb 00 00 00 00       	mov    $0x0,%ebx
801028fd:	eb 66                	jmp    80102965 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801028ff:	89 d8                	mov    %ebx,%eax
80102901:	03 05 54 94 1e 80    	add    0x801e9454,%eax
80102907:	83 c0 01             	add    $0x1,%eax
8010290a:	83 ec 08             	sub    $0x8,%esp
8010290d:	50                   	push   %eax
8010290e:	ff 35 64 94 1e 80    	pushl  0x801e9464
80102914:	e8 53 d8 ff ff       	call   8010016c <bread>
80102919:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010291b:	83 c4 08             	add    $0x8,%esp
8010291e:	ff 34 9d 6c 94 1e 80 	pushl  -0x7fe16b94(,%ebx,4)
80102925:	ff 35 64 94 1e 80    	pushl  0x801e9464
8010292b:	e8 3c d8 ff ff       	call   8010016c <bread>
80102930:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102932:	8d 57 5c             	lea    0x5c(%edi),%edx
80102935:	8d 40 5c             	lea    0x5c(%eax),%eax
80102938:	83 c4 0c             	add    $0xc,%esp
8010293b:	68 00 02 00 00       	push   $0x200
80102940:	52                   	push   %edx
80102941:	50                   	push   %eax
80102942:	e8 60 17 00 00       	call   801040a7 <memmove>
    bwrite(dbuf);  // write dst to disk
80102947:	89 34 24             	mov    %esi,(%esp)
8010294a:	e8 4b d8 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
8010294f:	89 3c 24             	mov    %edi,(%esp)
80102952:	e8 7e d8 ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102957:	89 34 24             	mov    %esi,(%esp)
8010295a:	e8 76 d8 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010295f:	83 c3 01             	add    $0x1,%ebx
80102962:	83 c4 10             	add    $0x10,%esp
80102965:	39 1d 68 94 1e 80    	cmp    %ebx,0x801e9468
8010296b:	7f 92                	jg     801028ff <install_trans+0x10>
}
8010296d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102970:	5b                   	pop    %ebx
80102971:	5e                   	pop    %esi
80102972:	5f                   	pop    %edi
80102973:	5d                   	pop    %ebp
80102974:	c3                   	ret    

80102975 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102975:	55                   	push   %ebp
80102976:	89 e5                	mov    %esp,%ebp
80102978:	53                   	push   %ebx
80102979:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010297c:	ff 35 54 94 1e 80    	pushl  0x801e9454
80102982:	ff 35 64 94 1e 80    	pushl  0x801e9464
80102988:	e8 df d7 ff ff       	call   8010016c <bread>
8010298d:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010298f:	8b 0d 68 94 1e 80    	mov    0x801e9468,%ecx
80102995:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102998:	83 c4 10             	add    $0x10,%esp
8010299b:	b8 00 00 00 00       	mov    $0x0,%eax
801029a0:	eb 0e                	jmp    801029b0 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801029a2:	8b 14 85 6c 94 1e 80 	mov    -0x7fe16b94(,%eax,4),%edx
801029a9:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801029ad:	83 c0 01             	add    $0x1,%eax
801029b0:	39 c1                	cmp    %eax,%ecx
801029b2:	7f ee                	jg     801029a2 <write_head+0x2d>
  }
  bwrite(buf);
801029b4:	83 ec 0c             	sub    $0xc,%esp
801029b7:	53                   	push   %ebx
801029b8:	e8 dd d7 ff ff       	call   8010019a <bwrite>
  brelse(buf);
801029bd:	89 1c 24             	mov    %ebx,(%esp)
801029c0:	e8 10 d8 ff ff       	call   801001d5 <brelse>
}
801029c5:	83 c4 10             	add    $0x10,%esp
801029c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    

801029cd <recover_from_log>:

static void
recover_from_log(void)
{
801029cd:	55                   	push   %ebp
801029ce:	89 e5                	mov    %esp,%ebp
801029d0:	83 ec 08             	sub    $0x8,%esp
  read_head();
801029d3:	e8 c9 fe ff ff       	call   801028a1 <read_head>
  install_trans(); // if committed, copy from log to disk
801029d8:	e8 12 ff ff ff       	call   801028ef <install_trans>
  log.lh.n = 0;
801029dd:	c7 05 68 94 1e 80 00 	movl   $0x0,0x801e9468
801029e4:	00 00 00 
  write_head(); // clear the log
801029e7:	e8 89 ff ff ff       	call   80102975 <write_head>
}
801029ec:	c9                   	leave  
801029ed:	c3                   	ret    

801029ee <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801029ee:	55                   	push   %ebp
801029ef:	89 e5                	mov    %esp,%ebp
801029f1:	57                   	push   %edi
801029f2:	56                   	push   %esi
801029f3:	53                   	push   %ebx
801029f4:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801029f7:	bb 00 00 00 00       	mov    $0x0,%ebx
801029fc:	eb 66                	jmp    80102a64 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801029fe:	89 d8                	mov    %ebx,%eax
80102a00:	03 05 54 94 1e 80    	add    0x801e9454,%eax
80102a06:	83 c0 01             	add    $0x1,%eax
80102a09:	83 ec 08             	sub    $0x8,%esp
80102a0c:	50                   	push   %eax
80102a0d:	ff 35 64 94 1e 80    	pushl  0x801e9464
80102a13:	e8 54 d7 ff ff       	call   8010016c <bread>
80102a18:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102a1a:	83 c4 08             	add    $0x8,%esp
80102a1d:	ff 34 9d 6c 94 1e 80 	pushl  -0x7fe16b94(,%ebx,4)
80102a24:	ff 35 64 94 1e 80    	pushl  0x801e9464
80102a2a:	e8 3d d7 ff ff       	call   8010016c <bread>
80102a2f:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102a31:	8d 50 5c             	lea    0x5c(%eax),%edx
80102a34:	8d 46 5c             	lea    0x5c(%esi),%eax
80102a37:	83 c4 0c             	add    $0xc,%esp
80102a3a:	68 00 02 00 00       	push   $0x200
80102a3f:	52                   	push   %edx
80102a40:	50                   	push   %eax
80102a41:	e8 61 16 00 00       	call   801040a7 <memmove>
    bwrite(to);  // write the log
80102a46:	89 34 24             	mov    %esi,(%esp)
80102a49:	e8 4c d7 ff ff       	call   8010019a <bwrite>
    brelse(from);
80102a4e:	89 3c 24             	mov    %edi,(%esp)
80102a51:	e8 7f d7 ff ff       	call   801001d5 <brelse>
    brelse(to);
80102a56:	89 34 24             	mov    %esi,(%esp)
80102a59:	e8 77 d7 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102a5e:	83 c3 01             	add    $0x1,%ebx
80102a61:	83 c4 10             	add    $0x10,%esp
80102a64:	39 1d 68 94 1e 80    	cmp    %ebx,0x801e9468
80102a6a:	7f 92                	jg     801029fe <write_log+0x10>
  }
}
80102a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102a6f:	5b                   	pop    %ebx
80102a70:	5e                   	pop    %esi
80102a71:	5f                   	pop    %edi
80102a72:	5d                   	pop    %ebp
80102a73:	c3                   	ret    

80102a74 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102a74:	83 3d 68 94 1e 80 00 	cmpl   $0x0,0x801e9468
80102a7b:	7e 26                	jle    80102aa3 <commit+0x2f>
{
80102a7d:	55                   	push   %ebp
80102a7e:	89 e5                	mov    %esp,%ebp
80102a80:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102a83:	e8 66 ff ff ff       	call   801029ee <write_log>
    write_head();    // Write header to disk -- the real commit
80102a88:	e8 e8 fe ff ff       	call   80102975 <write_head>
    install_trans(); // Now install writes to home locations
80102a8d:	e8 5d fe ff ff       	call   801028ef <install_trans>
    log.lh.n = 0;
80102a92:	c7 05 68 94 1e 80 00 	movl   $0x0,0x801e9468
80102a99:	00 00 00 
    write_head();    // Erase the transaction from the log
80102a9c:	e8 d4 fe ff ff       	call   80102975 <write_head>
  }
}
80102aa1:	c9                   	leave  
80102aa2:	c3                   	ret    
80102aa3:	f3 c3                	repz ret 

80102aa5 <initlog>:
{
80102aa5:	55                   	push   %ebp
80102aa6:	89 e5                	mov    %esp,%ebp
80102aa8:	53                   	push   %ebx
80102aa9:	83 ec 2c             	sub    $0x2c,%esp
80102aac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102aaf:	68 a0 6d 10 80       	push   $0x80106da0
80102ab4:	68 20 94 1e 80       	push   $0x801e9420
80102ab9:	e8 86 13 00 00       	call   80103e44 <initlock>
  readsb(dev, &sb);
80102abe:	83 c4 08             	add    $0x8,%esp
80102ac1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102ac4:	50                   	push   %eax
80102ac5:	53                   	push   %ebx
80102ac6:	e8 7f e7 ff ff       	call   8010124a <readsb>
  log.start = sb.logstart;
80102acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ace:	a3 54 94 1e 80       	mov    %eax,0x801e9454
  log.size = sb.nlog;
80102ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102ad6:	a3 58 94 1e 80       	mov    %eax,0x801e9458
  log.dev = dev;
80102adb:	89 1d 64 94 1e 80    	mov    %ebx,0x801e9464
  recover_from_log();
80102ae1:	e8 e7 fe ff ff       	call   801029cd <recover_from_log>
}
80102ae6:	83 c4 10             	add    $0x10,%esp
80102ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102aec:	c9                   	leave  
80102aed:	c3                   	ret    

80102aee <begin_op>:
{
80102aee:	55                   	push   %ebp
80102aef:	89 e5                	mov    %esp,%ebp
80102af1:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102af4:	68 20 94 1e 80       	push   $0x801e9420
80102af9:	e8 82 14 00 00       	call   80103f80 <acquire>
80102afe:	83 c4 10             	add    $0x10,%esp
80102b01:	eb 15                	jmp    80102b18 <begin_op+0x2a>
      sleep(&log, &log.lock);
80102b03:	83 ec 08             	sub    $0x8,%esp
80102b06:	68 20 94 1e 80       	push   $0x801e9420
80102b0b:	68 20 94 1e 80       	push   $0x801e9420
80102b10:	e8 09 0f 00 00       	call   80103a1e <sleep>
80102b15:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102b18:	83 3d 60 94 1e 80 00 	cmpl   $0x0,0x801e9460
80102b1f:	75 e2                	jne    80102b03 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102b21:	a1 5c 94 1e 80       	mov    0x801e945c,%eax
80102b26:	83 c0 01             	add    $0x1,%eax
80102b29:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102b2c:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102b2f:	03 15 68 94 1e 80    	add    0x801e9468,%edx
80102b35:	83 fa 1e             	cmp    $0x1e,%edx
80102b38:	7e 17                	jle    80102b51 <begin_op+0x63>
      sleep(&log, &log.lock);
80102b3a:	83 ec 08             	sub    $0x8,%esp
80102b3d:	68 20 94 1e 80       	push   $0x801e9420
80102b42:	68 20 94 1e 80       	push   $0x801e9420
80102b47:	e8 d2 0e 00 00       	call   80103a1e <sleep>
80102b4c:	83 c4 10             	add    $0x10,%esp
80102b4f:	eb c7                	jmp    80102b18 <begin_op+0x2a>
      log.outstanding += 1;
80102b51:	a3 5c 94 1e 80       	mov    %eax,0x801e945c
      release(&log.lock);
80102b56:	83 ec 0c             	sub    $0xc,%esp
80102b59:	68 20 94 1e 80       	push   $0x801e9420
80102b5e:	e8 82 14 00 00       	call   80103fe5 <release>
}
80102b63:	83 c4 10             	add    $0x10,%esp
80102b66:	c9                   	leave  
80102b67:	c3                   	ret    

80102b68 <end_op>:
{
80102b68:	55                   	push   %ebp
80102b69:	89 e5                	mov    %esp,%ebp
80102b6b:	53                   	push   %ebx
80102b6c:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102b6f:	68 20 94 1e 80       	push   $0x801e9420
80102b74:	e8 07 14 00 00       	call   80103f80 <acquire>
  log.outstanding -= 1;
80102b79:	a1 5c 94 1e 80       	mov    0x801e945c,%eax
80102b7e:	83 e8 01             	sub    $0x1,%eax
80102b81:	a3 5c 94 1e 80       	mov    %eax,0x801e945c
  if(log.committing)
80102b86:	8b 1d 60 94 1e 80    	mov    0x801e9460,%ebx
80102b8c:	83 c4 10             	add    $0x10,%esp
80102b8f:	85 db                	test   %ebx,%ebx
80102b91:	75 2c                	jne    80102bbf <end_op+0x57>
  if(log.outstanding == 0){
80102b93:	85 c0                	test   %eax,%eax
80102b95:	75 35                	jne    80102bcc <end_op+0x64>
    log.committing = 1;
80102b97:	c7 05 60 94 1e 80 01 	movl   $0x1,0x801e9460
80102b9e:	00 00 00 
    do_commit = 1;
80102ba1:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102ba6:	83 ec 0c             	sub    $0xc,%esp
80102ba9:	68 20 94 1e 80       	push   $0x801e9420
80102bae:	e8 32 14 00 00       	call   80103fe5 <release>
  if(do_commit){
80102bb3:	83 c4 10             	add    $0x10,%esp
80102bb6:	85 db                	test   %ebx,%ebx
80102bb8:	75 24                	jne    80102bde <end_op+0x76>
}
80102bba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102bbd:	c9                   	leave  
80102bbe:	c3                   	ret    
    panic("log.committing");
80102bbf:	83 ec 0c             	sub    $0xc,%esp
80102bc2:	68 a4 6d 10 80       	push   $0x80106da4
80102bc7:	e8 7c d7 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102bcc:	83 ec 0c             	sub    $0xc,%esp
80102bcf:	68 20 94 1e 80       	push   $0x801e9420
80102bd4:	e8 aa 0f 00 00       	call   80103b83 <wakeup>
80102bd9:	83 c4 10             	add    $0x10,%esp
80102bdc:	eb c8                	jmp    80102ba6 <end_op+0x3e>
    commit();
80102bde:	e8 91 fe ff ff       	call   80102a74 <commit>
    acquire(&log.lock);
80102be3:	83 ec 0c             	sub    $0xc,%esp
80102be6:	68 20 94 1e 80       	push   $0x801e9420
80102beb:	e8 90 13 00 00       	call   80103f80 <acquire>
    log.committing = 0;
80102bf0:	c7 05 60 94 1e 80 00 	movl   $0x0,0x801e9460
80102bf7:	00 00 00 
    wakeup(&log);
80102bfa:	c7 04 24 20 94 1e 80 	movl   $0x801e9420,(%esp)
80102c01:	e8 7d 0f 00 00       	call   80103b83 <wakeup>
    release(&log.lock);
80102c06:	c7 04 24 20 94 1e 80 	movl   $0x801e9420,(%esp)
80102c0d:	e8 d3 13 00 00       	call   80103fe5 <release>
80102c12:	83 c4 10             	add    $0x10,%esp
}
80102c15:	eb a3                	jmp    80102bba <end_op+0x52>

80102c17 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102c17:	55                   	push   %ebp
80102c18:	89 e5                	mov    %esp,%ebp
80102c1a:	53                   	push   %ebx
80102c1b:	83 ec 04             	sub    $0x4,%esp
80102c1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102c21:	8b 15 68 94 1e 80    	mov    0x801e9468,%edx
80102c27:	83 fa 1d             	cmp    $0x1d,%edx
80102c2a:	7f 45                	jg     80102c71 <log_write+0x5a>
80102c2c:	a1 58 94 1e 80       	mov    0x801e9458,%eax
80102c31:	83 e8 01             	sub    $0x1,%eax
80102c34:	39 c2                	cmp    %eax,%edx
80102c36:	7d 39                	jge    80102c71 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102c38:	83 3d 5c 94 1e 80 00 	cmpl   $0x0,0x801e945c
80102c3f:	7e 3d                	jle    80102c7e <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102c41:	83 ec 0c             	sub    $0xc,%esp
80102c44:	68 20 94 1e 80       	push   $0x801e9420
80102c49:	e8 32 13 00 00       	call   80103f80 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102c4e:	83 c4 10             	add    $0x10,%esp
80102c51:	b8 00 00 00 00       	mov    $0x0,%eax
80102c56:	8b 15 68 94 1e 80    	mov    0x801e9468,%edx
80102c5c:	39 c2                	cmp    %eax,%edx
80102c5e:	7e 2b                	jle    80102c8b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102c60:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102c63:	39 0c 85 6c 94 1e 80 	cmp    %ecx,-0x7fe16b94(,%eax,4)
80102c6a:	74 1f                	je     80102c8b <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102c6c:	83 c0 01             	add    $0x1,%eax
80102c6f:	eb e5                	jmp    80102c56 <log_write+0x3f>
    panic("too big a transaction");
80102c71:	83 ec 0c             	sub    $0xc,%esp
80102c74:	68 b3 6d 10 80       	push   $0x80106db3
80102c79:	e8 ca d6 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102c7e:	83 ec 0c             	sub    $0xc,%esp
80102c81:	68 c9 6d 10 80       	push   $0x80106dc9
80102c86:	e8 bd d6 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102c8b:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102c8e:	89 0c 85 6c 94 1e 80 	mov    %ecx,-0x7fe16b94(,%eax,4)
  if (i == log.lh.n)
80102c95:	39 c2                	cmp    %eax,%edx
80102c97:	74 18                	je     80102cb1 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102c99:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102c9c:	83 ec 0c             	sub    $0xc,%esp
80102c9f:	68 20 94 1e 80       	push   $0x801e9420
80102ca4:	e8 3c 13 00 00       	call   80103fe5 <release>
}
80102ca9:	83 c4 10             	add    $0x10,%esp
80102cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102caf:	c9                   	leave  
80102cb0:	c3                   	ret    
    log.lh.n++;
80102cb1:	83 c2 01             	add    $0x1,%edx
80102cb4:	89 15 68 94 1e 80    	mov    %edx,0x801e9468
80102cba:	eb dd                	jmp    80102c99 <log_write+0x82>

80102cbc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102cbc:	55                   	push   %ebp
80102cbd:	89 e5                	mov    %esp,%ebp
80102cbf:	53                   	push   %ebx
80102cc0:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102cc3:	68 8a 00 00 00       	push   $0x8a
80102cc8:	68 8c a4 10 80       	push   $0x8010a48c
80102ccd:	68 00 70 00 80       	push   $0x80007000
80102cd2:	e8 d0 13 00 00       	call   801040a7 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102cd7:	83 c4 10             	add    $0x10,%esp
80102cda:	bb 20 95 1e 80       	mov    $0x801e9520,%ebx
80102cdf:	eb 06                	jmp    80102ce7 <startothers+0x2b>
80102ce1:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102ce7:	69 05 a0 9a 1e 80 b0 	imul   $0xb0,0x801e9aa0,%eax
80102cee:	00 00 00 
80102cf1:	05 20 95 1e 80       	add    $0x801e9520,%eax
80102cf6:	39 d8                	cmp    %ebx,%eax
80102cf8:	76 4c                	jbe    80102d46 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102cfa:	e8 f0 07 00 00       	call   801034ef <mycpu>
80102cff:	39 d8                	cmp    %ebx,%eax
80102d01:	74 de                	je     80102ce1 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102d03:	e8 67 f4 ff ff       	call   8010216f <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102d08:	05 00 10 00 00       	add    $0x1000,%eax
80102d0d:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102d12:	c7 05 f8 6f 00 80 8a 	movl   $0x80102d8a,0x80006ff8
80102d19:	2d 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102d1c:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102d23:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102d26:	83 ec 08             	sub    $0x8,%esp
80102d29:	68 00 70 00 00       	push   $0x7000
80102d2e:	0f b6 03             	movzbl (%ebx),%eax
80102d31:	50                   	push   %eax
80102d32:	e8 c6 f9 ff ff       	call   801026fd <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102d37:	83 c4 10             	add    $0x10,%esp
80102d3a:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102d40:	85 c0                	test   %eax,%eax
80102d42:	74 f6                	je     80102d3a <startothers+0x7e>
80102d44:	eb 9b                	jmp    80102ce1 <startothers+0x25>
      ;
  }
}
80102d46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d49:	c9                   	leave  
80102d4a:	c3                   	ret    

80102d4b <mpmain>:
{
80102d4b:	55                   	push   %ebp
80102d4c:	89 e5                	mov    %esp,%ebp
80102d4e:	53                   	push   %ebx
80102d4f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102d52:	e8 f4 07 00 00       	call   8010354b <cpuid>
80102d57:	89 c3                	mov    %eax,%ebx
80102d59:	e8 ed 07 00 00       	call   8010354b <cpuid>
80102d5e:	83 ec 04             	sub    $0x4,%esp
80102d61:	53                   	push   %ebx
80102d62:	50                   	push   %eax
80102d63:	68 e4 6d 10 80       	push   $0x80106de4
80102d68:	e8 9e d8 ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102d6d:	e8 93 24 00 00       	call   80105205 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102d72:	e8 78 07 00 00       	call   801034ef <mycpu>
80102d77:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102d79:	b8 01 00 00 00       	mov    $0x1,%eax
80102d7e:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102d85:	e8 6f 0a 00 00       	call   801037f9 <scheduler>

80102d8a <mpenter>:
{
80102d8a:	55                   	push   %ebp
80102d8b:	89 e5                	mov    %esp,%ebp
80102d8d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102d90:	e8 79 34 00 00       	call   8010620e <switchkvm>
  seginit();
80102d95:	e8 28 33 00 00       	call   801060c2 <seginit>
  lapicinit();
80102d9a:	e8 15 f8 ff ff       	call   801025b4 <lapicinit>
  mpmain();
80102d9f:	e8 a7 ff ff ff       	call   80102d4b <mpmain>

80102da4 <main>:
{
80102da4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102da8:	83 e4 f0             	and    $0xfffffff0,%esp
80102dab:	ff 71 fc             	pushl  -0x4(%ecx)
80102dae:	55                   	push   %ebp
80102daf:	89 e5                	mov    %esp,%ebp
80102db1:	51                   	push   %ecx
80102db2:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102db5:	68 00 00 40 80       	push   $0x80400000
80102dba:	68 48 c2 1e 80       	push   $0x801ec248
80102dbf:	e8 59 f3 ff ff       	call   8010211d <kinit1>
  kvmalloc();      // kernel page table
80102dc4:	e8 24 39 00 00       	call   801066ed <kvmalloc>
  mpinit();        // detect other processors
80102dc9:	e8 c9 01 00 00       	call   80102f97 <mpinit>
  lapicinit();     // interrupt controller
80102dce:	e8 e1 f7 ff ff       	call   801025b4 <lapicinit>
  seginit();       // segment descriptors
80102dd3:	e8 ea 32 00 00       	call   801060c2 <seginit>
  picinit();       // disable pic
80102dd8:	e8 82 02 00 00       	call   8010305f <picinit>
  ioapicinit();    // another interrupt controller
80102ddd:	e8 2c f1 ff ff       	call   80101f0e <ioapicinit>
  consoleinit();   // console hardware
80102de2:	e8 a7 da ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102de7:	e8 c7 26 00 00       	call   801054b3 <uartinit>
  pinit();         // process table
80102dec:	e8 e4 06 00 00       	call   801034d5 <pinit>
  tvinit();        // trap vectors
80102df1:	e8 5e 23 00 00       	call   80105154 <tvinit>
  binit();         // buffer cache
80102df6:	e8 f9 d2 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102dfb:	e8 27 de ff ff       	call   80100c27 <fileinit>
  ideinit();       // disk 
80102e00:	e8 0f ef ff ff       	call   80101d14 <ideinit>
  startothers();   // start other processors
80102e05:	e8 b2 fe ff ff       	call   80102cbc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102e0a:	83 c4 08             	add    $0x8,%esp
80102e0d:	68 00 00 00 8e       	push   $0x8e000000
80102e12:	68 00 00 40 80       	push   $0x80400000
80102e17:	e8 33 f3 ff ff       	call   8010214f <kinit2>
  userinit();      // first user process
80102e1c:	e8 69 07 00 00       	call   8010358a <userinit>
  mpmain();        // finish this processor's setup
80102e21:	e8 25 ff ff ff       	call   80102d4b <mpmain>

80102e26 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102e26:	55                   	push   %ebp
80102e27:	89 e5                	mov    %esp,%ebp
80102e29:	56                   	push   %esi
80102e2a:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102e2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102e30:	b9 00 00 00 00       	mov    $0x0,%ecx
80102e35:	eb 09                	jmp    80102e40 <sum+0x1a>
    sum += addr[i];
80102e37:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102e3b:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102e3d:	83 c1 01             	add    $0x1,%ecx
80102e40:	39 d1                	cmp    %edx,%ecx
80102e42:	7c f3                	jl     80102e37 <sum+0x11>
  return sum;
}
80102e44:	89 d8                	mov    %ebx,%eax
80102e46:	5b                   	pop    %ebx
80102e47:	5e                   	pop    %esi
80102e48:	5d                   	pop    %ebp
80102e49:	c3                   	ret    

80102e4a <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102e4a:	55                   	push   %ebp
80102e4b:	89 e5                	mov    %esp,%ebp
80102e4d:	56                   	push   %esi
80102e4e:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102e4f:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102e55:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102e57:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102e59:	eb 03                	jmp    80102e5e <mpsearch1+0x14>
80102e5b:	83 c3 10             	add    $0x10,%ebx
80102e5e:	39 f3                	cmp    %esi,%ebx
80102e60:	73 29                	jae    80102e8b <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102e62:	83 ec 04             	sub    $0x4,%esp
80102e65:	6a 04                	push   $0x4
80102e67:	68 f8 6d 10 80       	push   $0x80106df8
80102e6c:	53                   	push   %ebx
80102e6d:	e8 00 12 00 00       	call   80104072 <memcmp>
80102e72:	83 c4 10             	add    $0x10,%esp
80102e75:	85 c0                	test   %eax,%eax
80102e77:	75 e2                	jne    80102e5b <mpsearch1+0x11>
80102e79:	ba 10 00 00 00       	mov    $0x10,%edx
80102e7e:	89 d8                	mov    %ebx,%eax
80102e80:	e8 a1 ff ff ff       	call   80102e26 <sum>
80102e85:	84 c0                	test   %al,%al
80102e87:	75 d2                	jne    80102e5b <mpsearch1+0x11>
80102e89:	eb 05                	jmp    80102e90 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102e90:	89 d8                	mov    %ebx,%eax
80102e92:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102e95:	5b                   	pop    %ebx
80102e96:	5e                   	pop    %esi
80102e97:	5d                   	pop    %ebp
80102e98:	c3                   	ret    

80102e99 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102e99:	55                   	push   %ebp
80102e9a:	89 e5                	mov    %esp,%ebp
80102e9c:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102e9f:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102ea6:	c1 e0 08             	shl    $0x8,%eax
80102ea9:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102eb0:	09 d0                	or     %edx,%eax
80102eb2:	c1 e0 04             	shl    $0x4,%eax
80102eb5:	85 c0                	test   %eax,%eax
80102eb7:	74 1f                	je     80102ed8 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102eb9:	ba 00 04 00 00       	mov    $0x400,%edx
80102ebe:	e8 87 ff ff ff       	call   80102e4a <mpsearch1>
80102ec3:	85 c0                	test   %eax,%eax
80102ec5:	75 0f                	jne    80102ed6 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102ec7:	ba 00 00 01 00       	mov    $0x10000,%edx
80102ecc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ed1:	e8 74 ff ff ff       	call   80102e4a <mpsearch1>
}
80102ed6:	c9                   	leave  
80102ed7:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ed8:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102edf:	c1 e0 08             	shl    $0x8,%eax
80102ee2:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102ee9:	09 d0                	or     %edx,%eax
80102eeb:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102eee:	2d 00 04 00 00       	sub    $0x400,%eax
80102ef3:	ba 00 04 00 00       	mov    $0x400,%edx
80102ef8:	e8 4d ff ff ff       	call   80102e4a <mpsearch1>
80102efd:	85 c0                	test   %eax,%eax
80102eff:	75 d5                	jne    80102ed6 <mpsearch+0x3d>
80102f01:	eb c4                	jmp    80102ec7 <mpsearch+0x2e>

80102f03 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102f03:	55                   	push   %ebp
80102f04:	89 e5                	mov    %esp,%ebp
80102f06:	57                   	push   %edi
80102f07:	56                   	push   %esi
80102f08:	53                   	push   %ebx
80102f09:	83 ec 1c             	sub    $0x1c,%esp
80102f0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102f0f:	e8 85 ff ff ff       	call   80102e99 <mpsearch>
80102f14:	85 c0                	test   %eax,%eax
80102f16:	74 5c                	je     80102f74 <mpconfig+0x71>
80102f18:	89 c7                	mov    %eax,%edi
80102f1a:	8b 58 04             	mov    0x4(%eax),%ebx
80102f1d:	85 db                	test   %ebx,%ebx
80102f1f:	74 5a                	je     80102f7b <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102f21:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102f27:	83 ec 04             	sub    $0x4,%esp
80102f2a:	6a 04                	push   $0x4
80102f2c:	68 fd 6d 10 80       	push   $0x80106dfd
80102f31:	56                   	push   %esi
80102f32:	e8 3b 11 00 00       	call   80104072 <memcmp>
80102f37:	83 c4 10             	add    $0x10,%esp
80102f3a:	85 c0                	test   %eax,%eax
80102f3c:	75 44                	jne    80102f82 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102f3e:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102f45:	3c 01                	cmp    $0x1,%al
80102f47:	0f 95 c2             	setne  %dl
80102f4a:	3c 04                	cmp    $0x4,%al
80102f4c:	0f 95 c0             	setne  %al
80102f4f:	84 c2                	test   %al,%dl
80102f51:	75 36                	jne    80102f89 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102f53:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102f5a:	89 f0                	mov    %esi,%eax
80102f5c:	e8 c5 fe ff ff       	call   80102e26 <sum>
80102f61:	84 c0                	test   %al,%al
80102f63:	75 2b                	jne    80102f90 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f68:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102f6a:	89 f0                	mov    %esi,%eax
80102f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f6f:	5b                   	pop    %ebx
80102f70:	5e                   	pop    %esi
80102f71:	5f                   	pop    %edi
80102f72:	5d                   	pop    %ebp
80102f73:	c3                   	ret    
    return 0;
80102f74:	be 00 00 00 00       	mov    $0x0,%esi
80102f79:	eb ef                	jmp    80102f6a <mpconfig+0x67>
80102f7b:	be 00 00 00 00       	mov    $0x0,%esi
80102f80:	eb e8                	jmp    80102f6a <mpconfig+0x67>
    return 0;
80102f82:	be 00 00 00 00       	mov    $0x0,%esi
80102f87:	eb e1                	jmp    80102f6a <mpconfig+0x67>
    return 0;
80102f89:	be 00 00 00 00       	mov    $0x0,%esi
80102f8e:	eb da                	jmp    80102f6a <mpconfig+0x67>
    return 0;
80102f90:	be 00 00 00 00       	mov    $0x0,%esi
80102f95:	eb d3                	jmp    80102f6a <mpconfig+0x67>

80102f97 <mpinit>:

void
mpinit(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	57                   	push   %edi
80102f9b:	56                   	push   %esi
80102f9c:	53                   	push   %ebx
80102f9d:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102fa0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102fa3:	e8 5b ff ff ff       	call   80102f03 <mpconfig>
80102fa8:	85 c0                	test   %eax,%eax
80102faa:	74 19                	je     80102fc5 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102fac:	8b 50 24             	mov    0x24(%eax),%edx
80102faf:	89 15 00 94 1e 80    	mov    %edx,0x801e9400
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102fb5:	8d 50 2c             	lea    0x2c(%eax),%edx
80102fb8:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102fbc:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102fbe:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102fc3:	eb 34                	jmp    80102ff9 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102fc5:	83 ec 0c             	sub    $0xc,%esp
80102fc8:	68 02 6e 10 80       	push   $0x80106e02
80102fcd:	e8 76 d3 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102fd2:	8b 35 a0 9a 1e 80    	mov    0x801e9aa0,%esi
80102fd8:	83 fe 07             	cmp    $0x7,%esi
80102fdb:	7f 19                	jg     80102ff6 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102fdd:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102fe1:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102fe7:	88 87 20 95 1e 80    	mov    %al,-0x7fe16ae0(%edi)
        ncpu++;
80102fed:	83 c6 01             	add    $0x1,%esi
80102ff0:	89 35 a0 9a 1e 80    	mov    %esi,0x801e9aa0
      }
      p += sizeof(struct mpproc);
80102ff6:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ff9:	39 ca                	cmp    %ecx,%edx
80102ffb:	73 2b                	jae    80103028 <mpinit+0x91>
    switch(*p){
80102ffd:	0f b6 02             	movzbl (%edx),%eax
80103000:	3c 04                	cmp    $0x4,%al
80103002:	77 1d                	ja     80103021 <mpinit+0x8a>
80103004:	0f b6 c0             	movzbl %al,%eax
80103007:	ff 24 85 3c 6e 10 80 	jmp    *-0x7fef91c4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
8010300e:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80103012:	a2 00 95 1e 80       	mov    %al,0x801e9500
      p += sizeof(struct mpioapic);
80103017:	83 c2 08             	add    $0x8,%edx
      continue;
8010301a:	eb dd                	jmp    80102ff9 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010301c:	83 c2 08             	add    $0x8,%edx
      continue;
8010301f:	eb d8                	jmp    80102ff9 <mpinit+0x62>
    default:
      ismp = 0;
80103021:	bb 00 00 00 00       	mov    $0x0,%ebx
80103026:	eb d1                	jmp    80102ff9 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80103028:	85 db                	test   %ebx,%ebx
8010302a:	74 26                	je     80103052 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010302c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010302f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80103033:	74 15                	je     8010304a <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103035:	b8 70 00 00 00       	mov    $0x70,%eax
8010303a:	ba 22 00 00 00       	mov    $0x22,%edx
8010303f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103040:	ba 23 00 00 00       	mov    $0x23,%edx
80103045:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103046:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103049:	ee                   	out    %al,(%dx)
  }
}
8010304a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010304d:	5b                   	pop    %ebx
8010304e:	5e                   	pop    %esi
8010304f:	5f                   	pop    %edi
80103050:	5d                   	pop    %ebp
80103051:	c3                   	ret    
    panic("Didn't find a suitable machine");
80103052:	83 ec 0c             	sub    $0xc,%esp
80103055:	68 1c 6e 10 80       	push   $0x80106e1c
8010305a:	e8 e9 d2 ff ff       	call   80100348 <panic>

8010305f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010305f:	55                   	push   %ebp
80103060:	89 e5                	mov    %esp,%ebp
80103062:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103067:	ba 21 00 00 00       	mov    $0x21,%edx
8010306c:	ee                   	out    %al,(%dx)
8010306d:	ba a1 00 00 00       	mov    $0xa1,%edx
80103072:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103073:	5d                   	pop    %ebp
80103074:	c3                   	ret    

80103075 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103075:	55                   	push   %ebp
80103076:	89 e5                	mov    %esp,%ebp
80103078:	57                   	push   %edi
80103079:	56                   	push   %esi
8010307a:	53                   	push   %ebx
8010307b:	83 ec 0c             	sub    $0xc,%esp
8010307e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103081:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80103084:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010308a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103090:	e8 ac db ff ff       	call   80100c41 <filealloc>
80103095:	89 03                	mov    %eax,(%ebx)
80103097:	85 c0                	test   %eax,%eax
80103099:	74 16                	je     801030b1 <pipealloc+0x3c>
8010309b:	e8 a1 db ff ff       	call   80100c41 <filealloc>
801030a0:	89 06                	mov    %eax,(%esi)
801030a2:	85 c0                	test   %eax,%eax
801030a4:	74 0b                	je     801030b1 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801030a6:	e8 c4 f0 ff ff       	call   8010216f <kalloc>
801030ab:	89 c7                	mov    %eax,%edi
801030ad:	85 c0                	test   %eax,%eax
801030af:	75 35                	jne    801030e6 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
801030b1:	8b 03                	mov    (%ebx),%eax
801030b3:	85 c0                	test   %eax,%eax
801030b5:	74 0c                	je     801030c3 <pipealloc+0x4e>
    fileclose(*f0);
801030b7:	83 ec 0c             	sub    $0xc,%esp
801030ba:	50                   	push   %eax
801030bb:	e8 27 dc ff ff       	call   80100ce7 <fileclose>
801030c0:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801030c3:	8b 06                	mov    (%esi),%eax
801030c5:	85 c0                	test   %eax,%eax
801030c7:	0f 84 8b 00 00 00    	je     80103158 <pipealloc+0xe3>
    fileclose(*f1);
801030cd:	83 ec 0c             	sub    $0xc,%esp
801030d0:	50                   	push   %eax
801030d1:	e8 11 dc ff ff       	call   80100ce7 <fileclose>
801030d6:	83 c4 10             	add    $0x10,%esp
  return -1;
801030d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801030de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030e1:	5b                   	pop    %ebx
801030e2:	5e                   	pop    %esi
801030e3:	5f                   	pop    %edi
801030e4:	5d                   	pop    %ebp
801030e5:	c3                   	ret    
  p->readopen = 1;
801030e6:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801030ed:	00 00 00 
  p->writeopen = 1;
801030f0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801030f7:	00 00 00 
  p->nwrite = 0;
801030fa:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103101:	00 00 00 
  p->nread = 0;
80103104:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010310b:	00 00 00 
  initlock(&p->lock, "pipe");
8010310e:	83 ec 08             	sub    $0x8,%esp
80103111:	68 50 6e 10 80       	push   $0x80106e50
80103116:	50                   	push   %eax
80103117:	e8 28 0d 00 00       	call   80103e44 <initlock>
  (*f0)->type = FD_PIPE;
8010311c:	8b 03                	mov    (%ebx),%eax
8010311e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103124:	8b 03                	mov    (%ebx),%eax
80103126:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010312a:	8b 03                	mov    (%ebx),%eax
8010312c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103130:	8b 03                	mov    (%ebx),%eax
80103132:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103135:	8b 06                	mov    (%esi),%eax
80103137:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010313d:	8b 06                	mov    (%esi),%eax
8010313f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103143:	8b 06                	mov    (%esi),%eax
80103145:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103149:	8b 06                	mov    (%esi),%eax
8010314b:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
8010314e:	83 c4 10             	add    $0x10,%esp
80103151:	b8 00 00 00 00       	mov    $0x0,%eax
80103156:	eb 86                	jmp    801030de <pipealloc+0x69>
  return -1;
80103158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010315d:	e9 7c ff ff ff       	jmp    801030de <pipealloc+0x69>

80103162 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103162:	55                   	push   %ebp
80103163:	89 e5                	mov    %esp,%ebp
80103165:	53                   	push   %ebx
80103166:	83 ec 10             	sub    $0x10,%esp
80103169:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
8010316c:	53                   	push   %ebx
8010316d:	e8 0e 0e 00 00       	call   80103f80 <acquire>
  if(writable){
80103172:	83 c4 10             	add    $0x10,%esp
80103175:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103179:	74 3f                	je     801031ba <pipeclose+0x58>
    p->writeopen = 0;
8010317b:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80103182:	00 00 00 
    wakeup(&p->nread);
80103185:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010318b:	83 ec 0c             	sub    $0xc,%esp
8010318e:	50                   	push   %eax
8010318f:	e8 ef 09 00 00       	call   80103b83 <wakeup>
80103194:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103197:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
8010319e:	75 09                	jne    801031a9 <pipeclose+0x47>
801031a0:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
801031a7:	74 2f                	je     801031d8 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
801031a9:	83 ec 0c             	sub    $0xc,%esp
801031ac:	53                   	push   %ebx
801031ad:	e8 33 0e 00 00       	call   80103fe5 <release>
801031b2:	83 c4 10             	add    $0x10,%esp
}
801031b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801031b8:	c9                   	leave  
801031b9:	c3                   	ret    
    p->readopen = 0;
801031ba:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801031c1:	00 00 00 
    wakeup(&p->nwrite);
801031c4:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031ca:	83 ec 0c             	sub    $0xc,%esp
801031cd:	50                   	push   %eax
801031ce:	e8 b0 09 00 00       	call   80103b83 <wakeup>
801031d3:	83 c4 10             	add    $0x10,%esp
801031d6:	eb bf                	jmp    80103197 <pipeclose+0x35>
    release(&p->lock);
801031d8:	83 ec 0c             	sub    $0xc,%esp
801031db:	53                   	push   %ebx
801031dc:	e8 04 0e 00 00       	call   80103fe5 <release>
    kfree((char*)p);
801031e1:	89 1c 24             	mov    %ebx,(%esp)
801031e4:	e8 cf ed ff ff       	call   80101fb8 <kfree>
801031e9:	83 c4 10             	add    $0x10,%esp
801031ec:	eb c7                	jmp    801031b5 <pipeclose+0x53>

801031ee <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
801031ee:	55                   	push   %ebp
801031ef:	89 e5                	mov    %esp,%ebp
801031f1:	57                   	push   %edi
801031f2:	56                   	push   %esi
801031f3:	53                   	push   %ebx
801031f4:	83 ec 18             	sub    $0x18,%esp
801031f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801031fa:	89 de                	mov    %ebx,%esi
801031fc:	53                   	push   %ebx
801031fd:	e8 7e 0d 00 00       	call   80103f80 <acquire>
  for(i = 0; i < n; i++){
80103202:	83 c4 10             	add    $0x10,%esp
80103205:	bf 00 00 00 00       	mov    $0x0,%edi
8010320a:	3b 7d 10             	cmp    0x10(%ebp),%edi
8010320d:	0f 8d 88 00 00 00    	jge    8010329b <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103213:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103219:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010321f:	05 00 02 00 00       	add    $0x200,%eax
80103224:	39 c2                	cmp    %eax,%edx
80103226:	75 51                	jne    80103279 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80103228:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
8010322f:	74 2f                	je     80103260 <pipewrite+0x72>
80103231:	e8 30 03 00 00       	call   80103566 <myproc>
80103236:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010323a:	75 24                	jne    80103260 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010323c:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103242:	83 ec 0c             	sub    $0xc,%esp
80103245:	50                   	push   %eax
80103246:	e8 38 09 00 00       	call   80103b83 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010324b:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103251:	83 c4 08             	add    $0x8,%esp
80103254:	56                   	push   %esi
80103255:	50                   	push   %eax
80103256:	e8 c3 07 00 00       	call   80103a1e <sleep>
8010325b:	83 c4 10             	add    $0x10,%esp
8010325e:	eb b3                	jmp    80103213 <pipewrite+0x25>
        release(&p->lock);
80103260:	83 ec 0c             	sub    $0xc,%esp
80103263:	53                   	push   %ebx
80103264:	e8 7c 0d 00 00       	call   80103fe5 <release>
        return -1;
80103269:	83 c4 10             	add    $0x10,%esp
8010326c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103271:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103274:	5b                   	pop    %ebx
80103275:	5e                   	pop    %esi
80103276:	5f                   	pop    %edi
80103277:	5d                   	pop    %ebp
80103278:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103279:	8d 42 01             	lea    0x1(%edx),%eax
8010327c:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103282:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010328b:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
8010328f:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103293:	83 c7 01             	add    $0x1,%edi
80103296:	e9 6f ff ff ff       	jmp    8010320a <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010329b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801032a1:	83 ec 0c             	sub    $0xc,%esp
801032a4:	50                   	push   %eax
801032a5:	e8 d9 08 00 00       	call   80103b83 <wakeup>
  release(&p->lock);
801032aa:	89 1c 24             	mov    %ebx,(%esp)
801032ad:	e8 33 0d 00 00       	call   80103fe5 <release>
  return n;
801032b2:	83 c4 10             	add    $0x10,%esp
801032b5:	8b 45 10             	mov    0x10(%ebp),%eax
801032b8:	eb b7                	jmp    80103271 <pipewrite+0x83>

801032ba <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801032ba:	55                   	push   %ebp
801032bb:	89 e5                	mov    %esp,%ebp
801032bd:	57                   	push   %edi
801032be:	56                   	push   %esi
801032bf:	53                   	push   %ebx
801032c0:	83 ec 18             	sub    $0x18,%esp
801032c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801032c6:	89 df                	mov    %ebx,%edi
801032c8:	53                   	push   %ebx
801032c9:	e8 b2 0c 00 00       	call   80103f80 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801032ce:	83 c4 10             	add    $0x10,%esp
801032d1:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801032d7:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801032dd:	75 3d                	jne    8010331c <piperead+0x62>
801032df:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
801032e5:	85 f6                	test   %esi,%esi
801032e7:	74 38                	je     80103321 <piperead+0x67>
    if(myproc()->killed){
801032e9:	e8 78 02 00 00       	call   80103566 <myproc>
801032ee:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801032f2:	75 15                	jne    80103309 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801032f4:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801032fa:	83 ec 08             	sub    $0x8,%esp
801032fd:	57                   	push   %edi
801032fe:	50                   	push   %eax
801032ff:	e8 1a 07 00 00       	call   80103a1e <sleep>
80103304:	83 c4 10             	add    $0x10,%esp
80103307:	eb c8                	jmp    801032d1 <piperead+0x17>
      release(&p->lock);
80103309:	83 ec 0c             	sub    $0xc,%esp
8010330c:	53                   	push   %ebx
8010330d:	e8 d3 0c 00 00       	call   80103fe5 <release>
      return -1;
80103312:	83 c4 10             	add    $0x10,%esp
80103315:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010331a:	eb 50                	jmp    8010336c <piperead+0xb2>
8010331c:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103321:	3b 75 10             	cmp    0x10(%ebp),%esi
80103324:	7d 2c                	jge    80103352 <piperead+0x98>
    if(p->nread == p->nwrite)
80103326:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010332c:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103332:	74 1e                	je     80103352 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103334:	8d 50 01             	lea    0x1(%eax),%edx
80103337:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
8010333d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103342:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010334a:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010334d:	83 c6 01             	add    $0x1,%esi
80103350:	eb cf                	jmp    80103321 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103352:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103358:	83 ec 0c             	sub    $0xc,%esp
8010335b:	50                   	push   %eax
8010335c:	e8 22 08 00 00       	call   80103b83 <wakeup>
  release(&p->lock);
80103361:	89 1c 24             	mov    %ebx,(%esp)
80103364:	e8 7c 0c 00 00       	call   80103fe5 <release>
  return i;
80103369:	83 c4 10             	add    $0x10,%esp
}
8010336c:	89 f0                	mov    %esi,%eax
8010336e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103371:	5b                   	pop    %ebx
80103372:	5e                   	pop    %esi
80103373:	5f                   	pop    %edi
80103374:	5d                   	pop    %ebp
80103375:	c3                   	ret    

80103376 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103376:	55                   	push   %ebp
80103377:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103379:	ba f4 9a 1e 80       	mov    $0x801e9af4,%edx
8010337e:	eb 03                	jmp    80103383 <wakeup1+0xd>
80103380:	83 c2 7c             	add    $0x7c,%edx
80103383:	81 fa f4 b9 1e 80    	cmp    $0x801eb9f4,%edx
80103389:	73 14                	jae    8010339f <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010338b:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010338f:	75 ef                	jne    80103380 <wakeup1+0xa>
80103391:	39 42 20             	cmp    %eax,0x20(%edx)
80103394:	75 ea                	jne    80103380 <wakeup1+0xa>
      p->state = RUNNABLE;
80103396:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010339d:	eb e1                	jmp    80103380 <wakeup1+0xa>
}
8010339f:	5d                   	pop    %ebp
801033a0:	c3                   	ret    

801033a1 <allocproc>:
{
801033a1:	55                   	push   %ebp
801033a2:	89 e5                	mov    %esp,%ebp
801033a4:	56                   	push   %esi
801033a5:	53                   	push   %ebx
801033a6:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801033a8:	83 ec 0c             	sub    $0xc,%esp
801033ab:	68 c0 9a 1e 80       	push   $0x801e9ac0
801033b0:	e8 cb 0b 00 00       	call   80103f80 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801033b5:	83 c4 10             	add    $0x10,%esp
801033b8:	bb f4 9a 1e 80       	mov    $0x801e9af4,%ebx
801033bd:	81 fb f4 b9 1e 80    	cmp    $0x801eb9f4,%ebx
801033c3:	73 0b                	jae    801033d0 <allocproc+0x2f>
    if(p->state == UNUSED)
801033c5:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801033c9:	74 1c                	je     801033e7 <allocproc+0x46>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801033cb:	83 c3 7c             	add    $0x7c,%ebx
801033ce:	eb ed                	jmp    801033bd <allocproc+0x1c>
  release(&ptable.lock);
801033d0:	83 ec 0c             	sub    $0xc,%esp
801033d3:	68 c0 9a 1e 80       	push   $0x801e9ac0
801033d8:	e8 08 0c 00 00       	call   80103fe5 <release>
  return 0;
801033dd:	83 c4 10             	add    $0x10,%esp
801033e0:	bb 00 00 00 00       	mov    $0x0,%ebx
801033e5:	eb 7a                	jmp    80103461 <allocproc+0xc0>
  p->state = EMBRYO;
801033e7:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801033ee:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801033f3:	8d 50 01             	lea    0x1(%eax),%edx
801033f6:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801033fc:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801033ff:	83 ec 0c             	sub    $0xc,%esp
80103402:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103407:	e8 d9 0b 00 00       	call   80103fe5 <release>
  if(c == -1) {
8010340c:	83 c4 10             	add    $0x10,%esp
8010340f:	83 fe ff             	cmp    $0xffffffff,%esi
80103412:	74 56                	je     8010346a <allocproc+0xc9>
   if((p->kstack = kalloc2(p->pid)) == 0) {
80103414:	83 ec 0c             	sub    $0xc,%esp
80103417:	ff 73 10             	pushl  0x10(%ebx)
8010341a:	e8 a5 ee ff ff       	call   801022c4 <kalloc2>
8010341f:	89 43 08             	mov    %eax,0x8(%ebx)
80103422:	83 c4 10             	add    $0x10,%esp
80103425:	85 c0                	test   %eax,%eax
80103427:	74 5b                	je     80103484 <allocproc+0xe3>
  sp = p->kstack + KSTACKSIZE;
80103429:	8b 43 08             	mov    0x8(%ebx),%eax
  sp -= sizeof *p->tf;
8010342c:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103432:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103435:	c7 80 b0 0f 00 00 49 	movl   $0x80105149,0xfb0(%eax)
8010343c:	51 10 80 
  sp -= sizeof *p->context;
8010343f:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103444:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103447:	83 ec 04             	sub    $0x4,%esp
8010344a:	6a 14                	push   $0x14
8010344c:	6a 00                	push   $0x0
8010344e:	50                   	push   %eax
8010344f:	e8 d8 0b 00 00       	call   8010402c <memset>
  p->context->eip = (uint)forkret;
80103454:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103457:	c7 40 10 92 34 10 80 	movl   $0x80103492,0x10(%eax)
  return p;
8010345e:	83 c4 10             	add    $0x10,%esp
}
80103461:	89 d8                	mov    %ebx,%eax
80103463:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103466:	5b                   	pop    %ebx
80103467:	5e                   	pop    %esi
80103468:	5d                   	pop    %ebp
80103469:	c3                   	ret    
    if((p->kstack = kalloc()) == 0){
8010346a:	e8 00 ed ff ff       	call   8010216f <kalloc>
8010346f:	89 43 08             	mov    %eax,0x8(%ebx)
80103472:	85 c0                	test   %eax,%eax
80103474:	75 b3                	jne    80103429 <allocproc+0x88>
        p->state = UNUSED;
80103476:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        return 0;
8010347d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103482:	eb dd                	jmp    80103461 <allocproc+0xc0>
       p->state = UNUSED;
80103484:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
       return 0;
8010348b:	bb 00 00 00 00       	mov    $0x0,%ebx
80103490:	eb cf                	jmp    80103461 <allocproc+0xc0>

80103492 <forkret>:
{
80103492:	55                   	push   %ebp
80103493:	89 e5                	mov    %esp,%ebp
80103495:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103498:	68 c0 9a 1e 80       	push   $0x801e9ac0
8010349d:	e8 43 0b 00 00       	call   80103fe5 <release>
  if (first) {
801034a2:	83 c4 10             	add    $0x10,%esp
801034a5:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801034ac:	75 02                	jne    801034b0 <forkret+0x1e>
}
801034ae:	c9                   	leave  
801034af:	c3                   	ret    
    first = 0;
801034b0:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801034b7:	00 00 00 
    iinit(ROOTDEV);
801034ba:	83 ec 0c             	sub    $0xc,%esp
801034bd:	6a 01                	push   $0x1
801034bf:	e8 3c de ff ff       	call   80101300 <iinit>
    initlog(ROOTDEV);
801034c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801034cb:	e8 d5 f5 ff ff       	call   80102aa5 <initlog>
801034d0:	83 c4 10             	add    $0x10,%esp
}
801034d3:	eb d9                	jmp    801034ae <forkret+0x1c>

801034d5 <pinit>:
{
801034d5:	55                   	push   %ebp
801034d6:	89 e5                	mov    %esp,%ebp
801034d8:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801034db:	68 55 6e 10 80       	push   $0x80106e55
801034e0:	68 c0 9a 1e 80       	push   $0x801e9ac0
801034e5:	e8 5a 09 00 00       	call   80103e44 <initlock>
}
801034ea:	83 c4 10             	add    $0x10,%esp
801034ed:	c9                   	leave  
801034ee:	c3                   	ret    

801034ef <mycpu>:
{
801034ef:	55                   	push   %ebp
801034f0:	89 e5                	mov    %esp,%ebp
801034f2:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801034f5:	9c                   	pushf  
801034f6:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801034f7:	f6 c4 02             	test   $0x2,%ah
801034fa:	75 28                	jne    80103524 <mycpu+0x35>
  apicid = lapicid();
801034fc:	e8 bd f1 ff ff       	call   801026be <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103501:	ba 00 00 00 00       	mov    $0x0,%edx
80103506:	39 15 a0 9a 1e 80    	cmp    %edx,0x801e9aa0
8010350c:	7e 23                	jle    80103531 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
8010350e:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103514:	0f b6 89 20 95 1e 80 	movzbl -0x7fe16ae0(%ecx),%ecx
8010351b:	39 c1                	cmp    %eax,%ecx
8010351d:	74 1f                	je     8010353e <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010351f:	83 c2 01             	add    $0x1,%edx
80103522:	eb e2                	jmp    80103506 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103524:	83 ec 0c             	sub    $0xc,%esp
80103527:	68 38 6f 10 80       	push   $0x80106f38
8010352c:	e8 17 ce ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103531:	83 ec 0c             	sub    $0xc,%esp
80103534:	68 5c 6e 10 80       	push   $0x80106e5c
80103539:	e8 0a ce ff ff       	call   80100348 <panic>
      return &cpus[i];
8010353e:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103544:	05 20 95 1e 80       	add    $0x801e9520,%eax
}
80103549:	c9                   	leave  
8010354a:	c3                   	ret    

8010354b <cpuid>:
cpuid() {
8010354b:	55                   	push   %ebp
8010354c:	89 e5                	mov    %esp,%ebp
8010354e:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103551:	e8 99 ff ff ff       	call   801034ef <mycpu>
80103556:	2d 20 95 1e 80       	sub    $0x801e9520,%eax
8010355b:	c1 f8 04             	sar    $0x4,%eax
8010355e:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103564:	c9                   	leave  
80103565:	c3                   	ret    

80103566 <myproc>:
myproc(void) {
80103566:	55                   	push   %ebp
80103567:	89 e5                	mov    %esp,%ebp
80103569:	53                   	push   %ebx
8010356a:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010356d:	e8 31 09 00 00       	call   80103ea3 <pushcli>
  c = mycpu();
80103572:	e8 78 ff ff ff       	call   801034ef <mycpu>
  p = c->proc;
80103577:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010357d:	e8 5e 09 00 00       	call   80103ee0 <popcli>
}
80103582:	89 d8                	mov    %ebx,%eax
80103584:	83 c4 04             	add    $0x4,%esp
80103587:	5b                   	pop    %ebx
80103588:	5d                   	pop    %ebp
80103589:	c3                   	ret    

8010358a <userinit>:
{
8010358a:	55                   	push   %ebp
8010358b:	89 e5                	mov    %esp,%ebp
8010358d:	53                   	push   %ebx
8010358e:	83 ec 04             	sub    $0x4,%esp
  p = allocproc(0);
80103591:	b8 00 00 00 00       	mov    $0x0,%eax
80103596:	e8 06 fe ff ff       	call   801033a1 <allocproc>
8010359b:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010359d:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm(0)) == 0)
801035a2:	83 ec 0c             	sub    $0xc,%esp
801035a5:	6a 00                	push   $0x0
801035a7:	e8 b8 30 00 00       	call   80106664 <setupkvm>
801035ac:	89 43 04             	mov    %eax,0x4(%ebx)
801035af:	83 c4 10             	add    $0x10,%esp
801035b2:	85 c0                	test   %eax,%eax
801035b4:	0f 84 b6 00 00 00    	je     80103670 <userinit+0xe6>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size, 0);
801035ba:	6a 00                	push   $0x0
801035bc:	68 2c 00 00 00       	push   $0x2c
801035c1:	68 60 a4 10 80       	push   $0x8010a460
801035c6:	50                   	push   %eax
801035c7:	e8 6c 2d 00 00       	call   80106338 <inituvm>
  p->sz = PGSIZE;
801035cc:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801035d2:	83 c4 0c             	add    $0xc,%esp
801035d5:	6a 4c                	push   $0x4c
801035d7:	6a 00                	push   $0x0
801035d9:	ff 73 18             	pushl  0x18(%ebx)
801035dc:	e8 4b 0a 00 00       	call   8010402c <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801035e1:	8b 43 18             	mov    0x18(%ebx),%eax
801035e4:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801035ea:	8b 43 18             	mov    0x18(%ebx),%eax
801035ed:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801035f3:	8b 43 18             	mov    0x18(%ebx),%eax
801035f6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801035fa:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801035fe:	8b 43 18             	mov    0x18(%ebx),%eax
80103601:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103605:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103609:	8b 43 18             	mov    0x18(%ebx),%eax
8010360c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103613:	8b 43 18             	mov    0x18(%ebx),%eax
80103616:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010361d:	8b 43 18             	mov    0x18(%ebx),%eax
80103620:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103627:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010362a:	83 c4 0c             	add    $0xc,%esp
8010362d:	6a 10                	push   $0x10
8010362f:	68 85 6e 10 80       	push   $0x80106e85
80103634:	50                   	push   %eax
80103635:	e8 59 0b 00 00       	call   80104193 <safestrcpy>
  p->cwd = namei("/");
8010363a:	c7 04 24 8e 6e 10 80 	movl   $0x80106e8e,(%esp)
80103641:	e8 af e5 ff ff       	call   80101bf5 <namei>
80103646:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103649:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
80103650:	e8 2b 09 00 00       	call   80103f80 <acquire>
  p->state = RUNNABLE;
80103655:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010365c:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
80103663:	e8 7d 09 00 00       	call   80103fe5 <release>
}
80103668:	83 c4 10             	add    $0x10,%esp
8010366b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010366e:	c9                   	leave  
8010366f:	c3                   	ret    
    panic("userinit: out of memory?");
80103670:	83 ec 0c             	sub    $0xc,%esp
80103673:	68 6c 6e 10 80       	push   $0x80106e6c
80103678:	e8 cb cc ff ff       	call   80100348 <panic>

8010367d <growproc>:
{
8010367d:	55                   	push   %ebp
8010367e:	89 e5                	mov    %esp,%ebp
80103680:	56                   	push   %esi
80103681:	53                   	push   %ebx
80103682:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103685:	e8 dc fe ff ff       	call   80103566 <myproc>
8010368a:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
8010368c:	8b 00                	mov    (%eax),%eax
  if(n > 0){
8010368e:	85 f6                	test   %esi,%esi
80103690:	7f 21                	jg     801036b3 <growproc+0x36>
  } else if(n < 0){
80103692:	85 f6                	test   %esi,%esi
80103694:	79 33                	jns    801036c9 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103696:	83 ec 04             	sub    $0x4,%esp
80103699:	01 c6                	add    %eax,%esi
8010369b:	56                   	push   %esi
8010369c:	50                   	push   %eax
8010369d:	ff 73 04             	pushl  0x4(%ebx)
801036a0:	e8 b3 2d 00 00       	call   80106458 <deallocuvm>
801036a5:	83 c4 10             	add    $0x10,%esp
801036a8:	85 c0                	test   %eax,%eax
801036aa:	75 1d                	jne    801036c9 <growproc+0x4c>
      return -1;
801036ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036b1:	eb 29                	jmp    801036dc <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n, curproc->pid)) == 0)
801036b3:	ff 73 10             	pushl  0x10(%ebx)
801036b6:	01 c6                	add    %eax,%esi
801036b8:	56                   	push   %esi
801036b9:	50                   	push   %eax
801036ba:	ff 73 04             	pushl  0x4(%ebx)
801036bd:	e8 28 2e 00 00       	call   801064ea <allocuvm>
801036c2:	83 c4 10             	add    $0x10,%esp
801036c5:	85 c0                	test   %eax,%eax
801036c7:	74 1a                	je     801036e3 <growproc+0x66>
  curproc->sz = sz;
801036c9:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801036cb:	83 ec 0c             	sub    $0xc,%esp
801036ce:	53                   	push   %ebx
801036cf:	e8 4c 2b 00 00       	call   80106220 <switchuvm>
  return 0;
801036d4:	83 c4 10             	add    $0x10,%esp
801036d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036df:	5b                   	pop    %ebx
801036e0:	5e                   	pop    %esi
801036e1:	5d                   	pop    %ebp
801036e2:	c3                   	ret    
      return -1;
801036e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036e8:	eb f2                	jmp    801036dc <growproc+0x5f>

801036ea <fork>:
{
801036ea:	55                   	push   %ebp
801036eb:	89 e5                	mov    %esp,%ebp
801036ed:	57                   	push   %edi
801036ee:	56                   	push   %esi
801036ef:	53                   	push   %ebx
801036f0:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801036f3:	e8 6e fe ff ff       	call   80103566 <myproc>
801036f8:	89 c3                	mov    %eax,%ebx
  if((np = allocproc(0)) == 0){
801036fa:	b8 00 00 00 00       	mov    $0x0,%eax
801036ff:	e8 9d fc ff ff       	call   801033a1 <allocproc>
80103704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103707:	85 c0                	test   %eax,%eax
80103709:	0f 84 e3 00 00 00    	je     801037f2 <fork+0x108>
8010370f:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->pid)) == 0){
80103711:	83 ec 04             	sub    $0x4,%esp
80103714:	ff 73 10             	pushl  0x10(%ebx)
80103717:	ff 33                	pushl  (%ebx)
80103719:	ff 73 04             	pushl  0x4(%ebx)
8010371c:	e8 14 30 00 00       	call   80106735 <copyuvm>
80103721:	89 47 04             	mov    %eax,0x4(%edi)
80103724:	83 c4 10             	add    $0x10,%esp
80103727:	85 c0                	test   %eax,%eax
80103729:	74 2a                	je     80103755 <fork+0x6b>
  np->sz = curproc->sz;
8010372b:	8b 03                	mov    (%ebx),%eax
8010372d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103730:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103732:	89 c8                	mov    %ecx,%eax
80103734:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103737:	8b 73 18             	mov    0x18(%ebx),%esi
8010373a:	8b 79 18             	mov    0x18(%ecx),%edi
8010373d:	b9 13 00 00 00       	mov    $0x13,%ecx
80103742:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103744:	8b 40 18             	mov    0x18(%eax),%eax
80103747:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010374e:	be 00 00 00 00       	mov    $0x0,%esi
80103753:	eb 29                	jmp    8010377e <fork+0x94>
    kfree(np->kstack);
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010375b:	ff 73 08             	pushl  0x8(%ebx)
8010375e:	e8 55 e8 ff ff       	call   80101fb8 <kfree>
    np->kstack = 0;
80103763:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010376a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103771:	83 c4 10             	add    $0x10,%esp
80103774:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103779:	eb 6d                	jmp    801037e8 <fork+0xfe>
  for(i = 0; i < NOFILE; i++)
8010377b:	83 c6 01             	add    $0x1,%esi
8010377e:	83 fe 0f             	cmp    $0xf,%esi
80103781:	7f 1d                	jg     801037a0 <fork+0xb6>
    if(curproc->ofile[i])
80103783:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103787:	85 c0                	test   %eax,%eax
80103789:	74 f0                	je     8010377b <fork+0x91>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010378b:	83 ec 0c             	sub    $0xc,%esp
8010378e:	50                   	push   %eax
8010378f:	e8 0e d5 ff ff       	call   80100ca2 <filedup>
80103794:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103797:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
8010379b:	83 c4 10             	add    $0x10,%esp
8010379e:	eb db                	jmp    8010377b <fork+0x91>
  np->cwd = idup(curproc->cwd);
801037a0:	83 ec 0c             	sub    $0xc,%esp
801037a3:	ff 73 68             	pushl  0x68(%ebx)
801037a6:	e8 ba dd ff ff       	call   80101565 <idup>
801037ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801037ae:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801037b1:	83 c3 6c             	add    $0x6c,%ebx
801037b4:	8d 47 6c             	lea    0x6c(%edi),%eax
801037b7:	83 c4 0c             	add    $0xc,%esp
801037ba:	6a 10                	push   $0x10
801037bc:	53                   	push   %ebx
801037bd:	50                   	push   %eax
801037be:	e8 d0 09 00 00       	call   80104193 <safestrcpy>
  pid = np->pid;
801037c3:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801037c6:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
801037cd:	e8 ae 07 00 00       	call   80103f80 <acquire>
  np->state = RUNNABLE;
801037d2:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801037d9:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
801037e0:	e8 00 08 00 00       	call   80103fe5 <release>
  return pid;
801037e5:	83 c4 10             	add    $0x10,%esp
}
801037e8:	89 d8                	mov    %ebx,%eax
801037ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037ed:	5b                   	pop    %ebx
801037ee:	5e                   	pop    %esi
801037ef:	5f                   	pop    %edi
801037f0:	5d                   	pop    %ebp
801037f1:	c3                   	ret    
    return -1;
801037f2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801037f7:	eb ef                	jmp    801037e8 <fork+0xfe>

801037f9 <scheduler>:
{
801037f9:	55                   	push   %ebp
801037fa:	89 e5                	mov    %esp,%ebp
801037fc:	56                   	push   %esi
801037fd:	53                   	push   %ebx
  struct cpu *c = mycpu();
801037fe:	e8 ec fc ff ff       	call   801034ef <mycpu>
80103803:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103805:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010380c:	00 00 00 
8010380f:	eb 5a                	jmp    8010386b <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103811:	83 c3 7c             	add    $0x7c,%ebx
80103814:	81 fb f4 b9 1e 80    	cmp    $0x801eb9f4,%ebx
8010381a:	73 3f                	jae    8010385b <scheduler+0x62>
      if(p->state != RUNNABLE)
8010381c:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103820:	75 ef                	jne    80103811 <scheduler+0x18>
      c->proc = p;
80103822:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103828:	83 ec 0c             	sub    $0xc,%esp
8010382b:	53                   	push   %ebx
8010382c:	e8 ef 29 00 00       	call   80106220 <switchuvm>
      p->state = RUNNING;
80103831:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103838:	83 c4 08             	add    $0x8,%esp
8010383b:	ff 73 1c             	pushl  0x1c(%ebx)
8010383e:	8d 46 04             	lea    0x4(%esi),%eax
80103841:	50                   	push   %eax
80103842:	e8 9f 09 00 00       	call   801041e6 <swtch>
      switchkvm();
80103847:	e8 c2 29 00 00       	call   8010620e <switchkvm>
      c->proc = 0;
8010384c:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103853:	00 00 00 
80103856:	83 c4 10             	add    $0x10,%esp
80103859:	eb b6                	jmp    80103811 <scheduler+0x18>
    release(&ptable.lock);
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103863:	e8 7d 07 00 00       	call   80103fe5 <release>
    sti();
80103868:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
8010386b:	fb                   	sti    
    acquire(&ptable.lock);
8010386c:	83 ec 0c             	sub    $0xc,%esp
8010386f:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103874:	e8 07 07 00 00       	call   80103f80 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103879:	83 c4 10             	add    $0x10,%esp
8010387c:	bb f4 9a 1e 80       	mov    $0x801e9af4,%ebx
80103881:	eb 91                	jmp    80103814 <scheduler+0x1b>

80103883 <sched>:
{
80103883:	55                   	push   %ebp
80103884:	89 e5                	mov    %esp,%ebp
80103886:	56                   	push   %esi
80103887:	53                   	push   %ebx
  struct proc *p = myproc();
80103888:	e8 d9 fc ff ff       	call   80103566 <myproc>
8010388d:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010388f:	83 ec 0c             	sub    $0xc,%esp
80103892:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103897:	e8 a4 06 00 00       	call   80103f40 <holding>
8010389c:	83 c4 10             	add    $0x10,%esp
8010389f:	85 c0                	test   %eax,%eax
801038a1:	74 4f                	je     801038f2 <sched+0x6f>
  if(mycpu()->ncli != 1)
801038a3:	e8 47 fc ff ff       	call   801034ef <mycpu>
801038a8:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801038af:	75 4e                	jne    801038ff <sched+0x7c>
  if(p->state == RUNNING)
801038b1:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801038b5:	74 55                	je     8010390c <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801038b7:	9c                   	pushf  
801038b8:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801038b9:	f6 c4 02             	test   $0x2,%ah
801038bc:	75 5b                	jne    80103919 <sched+0x96>
  intena = mycpu()->intena;
801038be:	e8 2c fc ff ff       	call   801034ef <mycpu>
801038c3:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801038c9:	e8 21 fc ff ff       	call   801034ef <mycpu>
801038ce:	83 ec 08             	sub    $0x8,%esp
801038d1:	ff 70 04             	pushl  0x4(%eax)
801038d4:	83 c3 1c             	add    $0x1c,%ebx
801038d7:	53                   	push   %ebx
801038d8:	e8 09 09 00 00       	call   801041e6 <swtch>
  mycpu()->intena = intena;
801038dd:	e8 0d fc ff ff       	call   801034ef <mycpu>
801038e2:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801038e8:	83 c4 10             	add    $0x10,%esp
801038eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038ee:	5b                   	pop    %ebx
801038ef:	5e                   	pop    %esi
801038f0:	5d                   	pop    %ebp
801038f1:	c3                   	ret    
    panic("sched ptable.lock");
801038f2:	83 ec 0c             	sub    $0xc,%esp
801038f5:	68 90 6e 10 80       	push   $0x80106e90
801038fa:	e8 49 ca ff ff       	call   80100348 <panic>
    panic("sched locks");
801038ff:	83 ec 0c             	sub    $0xc,%esp
80103902:	68 a2 6e 10 80       	push   $0x80106ea2
80103907:	e8 3c ca ff ff       	call   80100348 <panic>
    panic("sched running");
8010390c:	83 ec 0c             	sub    $0xc,%esp
8010390f:	68 ae 6e 10 80       	push   $0x80106eae
80103914:	e8 2f ca ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103919:	83 ec 0c             	sub    $0xc,%esp
8010391c:	68 bc 6e 10 80       	push   $0x80106ebc
80103921:	e8 22 ca ff ff       	call   80100348 <panic>

80103926 <exit>:
{
80103926:	55                   	push   %ebp
80103927:	89 e5                	mov    %esp,%ebp
80103929:	56                   	push   %esi
8010392a:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010392b:	e8 36 fc ff ff       	call   80103566 <myproc>
  if(curproc == initproc)
80103930:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
80103936:	74 09                	je     80103941 <exit+0x1b>
80103938:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
8010393a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010393f:	eb 10                	jmp    80103951 <exit+0x2b>
    panic("init exiting");
80103941:	83 ec 0c             	sub    $0xc,%esp
80103944:	68 d0 6e 10 80       	push   $0x80106ed0
80103949:	e8 fa c9 ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010394e:	83 c3 01             	add    $0x1,%ebx
80103951:	83 fb 0f             	cmp    $0xf,%ebx
80103954:	7f 1e                	jg     80103974 <exit+0x4e>
    if(curproc->ofile[fd]){
80103956:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010395a:	85 c0                	test   %eax,%eax
8010395c:	74 f0                	je     8010394e <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010395e:	83 ec 0c             	sub    $0xc,%esp
80103961:	50                   	push   %eax
80103962:	e8 80 d3 ff ff       	call   80100ce7 <fileclose>
      curproc->ofile[fd] = 0;
80103967:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010396e:	00 
8010396f:	83 c4 10             	add    $0x10,%esp
80103972:	eb da                	jmp    8010394e <exit+0x28>
  begin_op();
80103974:	e8 75 f1 ff ff       	call   80102aee <begin_op>
  iput(curproc->cwd);
80103979:	83 ec 0c             	sub    $0xc,%esp
8010397c:	ff 76 68             	pushl  0x68(%esi)
8010397f:	e8 18 dd ff ff       	call   8010169c <iput>
  end_op();
80103984:	e8 df f1 ff ff       	call   80102b68 <end_op>
  curproc->cwd = 0;
80103989:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103990:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
80103997:	e8 e4 05 00 00       	call   80103f80 <acquire>
  wakeup1(curproc->parent);
8010399c:	8b 46 14             	mov    0x14(%esi),%eax
8010399f:	e8 d2 f9 ff ff       	call   80103376 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039a4:	83 c4 10             	add    $0x10,%esp
801039a7:	bb f4 9a 1e 80       	mov    $0x801e9af4,%ebx
801039ac:	eb 03                	jmp    801039b1 <exit+0x8b>
801039ae:	83 c3 7c             	add    $0x7c,%ebx
801039b1:	81 fb f4 b9 1e 80    	cmp    $0x801eb9f4,%ebx
801039b7:	73 1a                	jae    801039d3 <exit+0xad>
    if(p->parent == curproc){
801039b9:	39 73 14             	cmp    %esi,0x14(%ebx)
801039bc:	75 f0                	jne    801039ae <exit+0x88>
      p->parent = initproc;
801039be:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801039c3:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801039c6:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801039ca:	75 e2                	jne    801039ae <exit+0x88>
        wakeup1(initproc);
801039cc:	e8 a5 f9 ff ff       	call   80103376 <wakeup1>
801039d1:	eb db                	jmp    801039ae <exit+0x88>
  curproc->state = ZOMBIE;
801039d3:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801039da:	e8 a4 fe ff ff       	call   80103883 <sched>
  panic("zombie exit");
801039df:	83 ec 0c             	sub    $0xc,%esp
801039e2:	68 dd 6e 10 80       	push   $0x80106edd
801039e7:	e8 5c c9 ff ff       	call   80100348 <panic>

801039ec <yield>:
{
801039ec:	55                   	push   %ebp
801039ed:	89 e5                	mov    %esp,%ebp
801039ef:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801039f2:	68 c0 9a 1e 80       	push   $0x801e9ac0
801039f7:	e8 84 05 00 00       	call   80103f80 <acquire>
  myproc()->state = RUNNABLE;
801039fc:	e8 65 fb ff ff       	call   80103566 <myproc>
80103a01:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103a08:	e8 76 fe ff ff       	call   80103883 <sched>
  release(&ptable.lock);
80103a0d:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
80103a14:	e8 cc 05 00 00       	call   80103fe5 <release>
}
80103a19:	83 c4 10             	add    $0x10,%esp
80103a1c:	c9                   	leave  
80103a1d:	c3                   	ret    

80103a1e <sleep>:
{
80103a1e:	55                   	push   %ebp
80103a1f:	89 e5                	mov    %esp,%ebp
80103a21:	56                   	push   %esi
80103a22:	53                   	push   %ebx
80103a23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103a26:	e8 3b fb ff ff       	call   80103566 <myproc>
  if(p == 0)
80103a2b:	85 c0                	test   %eax,%eax
80103a2d:	74 66                	je     80103a95 <sleep+0x77>
80103a2f:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103a31:	85 db                	test   %ebx,%ebx
80103a33:	74 6d                	je     80103aa2 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103a35:	81 fb c0 9a 1e 80    	cmp    $0x801e9ac0,%ebx
80103a3b:	74 18                	je     80103a55 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103a3d:	83 ec 0c             	sub    $0xc,%esp
80103a40:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103a45:	e8 36 05 00 00       	call   80103f80 <acquire>
    release(lk);
80103a4a:	89 1c 24             	mov    %ebx,(%esp)
80103a4d:	e8 93 05 00 00       	call   80103fe5 <release>
80103a52:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103a55:	8b 45 08             	mov    0x8(%ebp),%eax
80103a58:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103a5b:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103a62:	e8 1c fe ff ff       	call   80103883 <sched>
  p->chan = 0;
80103a67:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103a6e:	81 fb c0 9a 1e 80    	cmp    $0x801e9ac0,%ebx
80103a74:	74 18                	je     80103a8e <sleep+0x70>
    release(&ptable.lock);
80103a76:	83 ec 0c             	sub    $0xc,%esp
80103a79:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103a7e:	e8 62 05 00 00       	call   80103fe5 <release>
    acquire(lk);
80103a83:	89 1c 24             	mov    %ebx,(%esp)
80103a86:	e8 f5 04 00 00       	call   80103f80 <acquire>
80103a8b:	83 c4 10             	add    $0x10,%esp
}
80103a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a91:	5b                   	pop    %ebx
80103a92:	5e                   	pop    %esi
80103a93:	5d                   	pop    %ebp
80103a94:	c3                   	ret    
    panic("sleep");
80103a95:	83 ec 0c             	sub    $0xc,%esp
80103a98:	68 e9 6e 10 80       	push   $0x80106ee9
80103a9d:	e8 a6 c8 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103aa2:	83 ec 0c             	sub    $0xc,%esp
80103aa5:	68 ef 6e 10 80       	push   $0x80106eef
80103aaa:	e8 99 c8 ff ff       	call   80100348 <panic>

80103aaf <wait>:
{
80103aaf:	55                   	push   %ebp
80103ab0:	89 e5                	mov    %esp,%ebp
80103ab2:	56                   	push   %esi
80103ab3:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103ab4:	e8 ad fa ff ff       	call   80103566 <myproc>
80103ab9:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103abb:	83 ec 0c             	sub    $0xc,%esp
80103abe:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103ac3:	e8 b8 04 00 00       	call   80103f80 <acquire>
80103ac8:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103acb:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ad0:	bb f4 9a 1e 80       	mov    $0x801e9af4,%ebx
80103ad5:	eb 5b                	jmp    80103b32 <wait+0x83>
        pid = p->pid;
80103ad7:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103ada:	83 ec 0c             	sub    $0xc,%esp
80103add:	ff 73 08             	pushl  0x8(%ebx)
80103ae0:	e8 d3 e4 ff ff       	call   80101fb8 <kfree>
        p->kstack = 0;
80103ae5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103aec:	83 c4 04             	add    $0x4,%esp
80103aef:	ff 73 04             	pushl  0x4(%ebx)
80103af2:	e8 fd 2a 00 00       	call   801065f4 <freevm>
        p->pid = 0;
80103af7:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103afe:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103b05:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103b09:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103b10:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103b17:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
80103b1e:	e8 c2 04 00 00       	call   80103fe5 <release>
        return pid;
80103b23:	83 c4 10             	add    $0x10,%esp
}
80103b26:	89 f0                	mov    %esi,%eax
80103b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b2b:	5b                   	pop    %ebx
80103b2c:	5e                   	pop    %esi
80103b2d:	5d                   	pop    %ebp
80103b2e:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b2f:	83 c3 7c             	add    $0x7c,%ebx
80103b32:	81 fb f4 b9 1e 80    	cmp    $0x801eb9f4,%ebx
80103b38:	73 12                	jae    80103b4c <wait+0x9d>
      if(p->parent != curproc)
80103b3a:	39 73 14             	cmp    %esi,0x14(%ebx)
80103b3d:	75 f0                	jne    80103b2f <wait+0x80>
      if(p->state == ZOMBIE){
80103b3f:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103b43:	74 92                	je     80103ad7 <wait+0x28>
      havekids = 1;
80103b45:	b8 01 00 00 00       	mov    $0x1,%eax
80103b4a:	eb e3                	jmp    80103b2f <wait+0x80>
    if(!havekids || curproc->killed){
80103b4c:	85 c0                	test   %eax,%eax
80103b4e:	74 06                	je     80103b56 <wait+0xa7>
80103b50:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103b54:	74 17                	je     80103b6d <wait+0xbe>
      release(&ptable.lock);
80103b56:	83 ec 0c             	sub    $0xc,%esp
80103b59:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103b5e:	e8 82 04 00 00       	call   80103fe5 <release>
      return -1;
80103b63:	83 c4 10             	add    $0x10,%esp
80103b66:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103b6b:	eb b9                	jmp    80103b26 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103b6d:	83 ec 08             	sub    $0x8,%esp
80103b70:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103b75:	56                   	push   %esi
80103b76:	e8 a3 fe ff ff       	call   80103a1e <sleep>
    havekids = 0;
80103b7b:	83 c4 10             	add    $0x10,%esp
80103b7e:	e9 48 ff ff ff       	jmp    80103acb <wait+0x1c>

80103b83 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103b83:	55                   	push   %ebp
80103b84:	89 e5                	mov    %esp,%ebp
80103b86:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103b89:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103b8e:	e8 ed 03 00 00       	call   80103f80 <acquire>
  wakeup1(chan);
80103b93:	8b 45 08             	mov    0x8(%ebp),%eax
80103b96:	e8 db f7 ff ff       	call   80103376 <wakeup1>
  release(&ptable.lock);
80103b9b:	c7 04 24 c0 9a 1e 80 	movl   $0x801e9ac0,(%esp)
80103ba2:	e8 3e 04 00 00       	call   80103fe5 <release>
}
80103ba7:	83 c4 10             	add    $0x10,%esp
80103baa:	c9                   	leave  
80103bab:	c3                   	ret    

80103bac <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103bac:	55                   	push   %ebp
80103bad:	89 e5                	mov    %esp,%ebp
80103baf:	53                   	push   %ebx
80103bb0:	83 ec 10             	sub    $0x10,%esp
80103bb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103bb6:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103bbb:	e8 c0 03 00 00       	call   80103f80 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103bc0:	83 c4 10             	add    $0x10,%esp
80103bc3:	b8 f4 9a 1e 80       	mov    $0x801e9af4,%eax
80103bc8:	3d f4 b9 1e 80       	cmp    $0x801eb9f4,%eax
80103bcd:	73 3a                	jae    80103c09 <kill+0x5d>
    if(p->pid == pid){
80103bcf:	39 58 10             	cmp    %ebx,0x10(%eax)
80103bd2:	74 05                	je     80103bd9 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103bd4:	83 c0 7c             	add    $0x7c,%eax
80103bd7:	eb ef                	jmp    80103bc8 <kill+0x1c>
      p->killed = 1;
80103bd9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103be0:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103be4:	74 1a                	je     80103c00 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103be6:	83 ec 0c             	sub    $0xc,%esp
80103be9:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103bee:	e8 f2 03 00 00       	call   80103fe5 <release>
      return 0;
80103bf3:	83 c4 10             	add    $0x10,%esp
80103bf6:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103bfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bfe:	c9                   	leave  
80103bff:	c3                   	ret    
        p->state = RUNNABLE;
80103c00:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103c07:	eb dd                	jmp    80103be6 <kill+0x3a>
  release(&ptable.lock);
80103c09:	83 ec 0c             	sub    $0xc,%esp
80103c0c:	68 c0 9a 1e 80       	push   $0x801e9ac0
80103c11:	e8 cf 03 00 00       	call   80103fe5 <release>
  return -1;
80103c16:	83 c4 10             	add    $0x10,%esp
80103c19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c1e:	eb db                	jmp    80103bfb <kill+0x4f>

80103c20 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103c20:	55                   	push   %ebp
80103c21:	89 e5                	mov    %esp,%ebp
80103c23:	56                   	push   %esi
80103c24:	53                   	push   %ebx
80103c25:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c28:	bb f4 9a 1e 80       	mov    $0x801e9af4,%ebx
80103c2d:	eb 33                	jmp    80103c62 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103c2f:	b8 00 6f 10 80       	mov    $0x80106f00,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103c34:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103c37:	52                   	push   %edx
80103c38:	50                   	push   %eax
80103c39:	ff 73 10             	pushl  0x10(%ebx)
80103c3c:	68 04 6f 10 80       	push   $0x80106f04
80103c41:	e8 c5 c9 ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103c46:	83 c4 10             	add    $0x10,%esp
80103c49:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103c4d:	74 39                	je     80103c88 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103c4f:	83 ec 0c             	sub    $0xc,%esp
80103c52:	68 7b 72 10 80       	push   $0x8010727b
80103c57:	e8 af c9 ff ff       	call   8010060b <cprintf>
80103c5c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c5f:	83 c3 7c             	add    $0x7c,%ebx
80103c62:	81 fb f4 b9 1e 80    	cmp    $0x801eb9f4,%ebx
80103c68:	73 61                	jae    80103ccb <procdump+0xab>
    if(p->state == UNUSED)
80103c6a:	8b 43 0c             	mov    0xc(%ebx),%eax
80103c6d:	85 c0                	test   %eax,%eax
80103c6f:	74 ee                	je     80103c5f <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103c71:	83 f8 05             	cmp    $0x5,%eax
80103c74:	77 b9                	ja     80103c2f <procdump+0xf>
80103c76:	8b 04 85 60 6f 10 80 	mov    -0x7fef90a0(,%eax,4),%eax
80103c7d:	85 c0                	test   %eax,%eax
80103c7f:	75 b3                	jne    80103c34 <procdump+0x14>
      state = "???";
80103c81:	b8 00 6f 10 80       	mov    $0x80106f00,%eax
80103c86:	eb ac                	jmp    80103c34 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103c88:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103c8b:	8b 40 0c             	mov    0xc(%eax),%eax
80103c8e:	83 c0 08             	add    $0x8,%eax
80103c91:	83 ec 08             	sub    $0x8,%esp
80103c94:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103c97:	52                   	push   %edx
80103c98:	50                   	push   %eax
80103c99:	e8 c1 01 00 00       	call   80103e5f <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103c9e:	83 c4 10             	add    $0x10,%esp
80103ca1:	be 00 00 00 00       	mov    $0x0,%esi
80103ca6:	eb 14                	jmp    80103cbc <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103ca8:	83 ec 08             	sub    $0x8,%esp
80103cab:	50                   	push   %eax
80103cac:	68 41 69 10 80       	push   $0x80106941
80103cb1:	e8 55 c9 ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103cb6:	83 c6 01             	add    $0x1,%esi
80103cb9:	83 c4 10             	add    $0x10,%esp
80103cbc:	83 fe 09             	cmp    $0x9,%esi
80103cbf:	7f 8e                	jg     80103c4f <procdump+0x2f>
80103cc1:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103cc5:	85 c0                	test   %eax,%eax
80103cc7:	75 df                	jne    80103ca8 <procdump+0x88>
80103cc9:	eb 84                	jmp    80103c4f <procdump+0x2f>
  }
}
80103ccb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cce:	5b                   	pop    %ebx
80103ccf:	5e                   	pop    %esi
80103cd0:	5d                   	pop    %ebp
80103cd1:	c3                   	ret    

80103cd2 <dump_physmem>:

int 
dump_physmem(int *userFrames, int *userPids, int nframes)
{
80103cd2:	55                   	push   %ebp
80103cd3:	89 e5                	mov    %esp,%ebp
80103cd5:	56                   	push   %esi
80103cd6:	53                   	push   %ebx
80103cd7:	8b 75 08             	mov    0x8(%ebp),%esi
80103cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103cdd:	8b 55 10             	mov    0x10(%ebp),%edx
    if(nframes < 0 || userFrames == 0 || userPids == 0){
80103ce0:	89 d0                	mov    %edx,%eax
80103ce2:	c1 e8 1f             	shr    $0x1f,%eax
80103ce5:	85 f6                	test   %esi,%esi
80103ce7:	0f 94 c1             	sete   %cl
80103cea:	08 c1                	or     %al,%cl
80103cec:	75 3d                	jne    80103d2b <dump_physmem+0x59>
80103cee:	85 db                	test   %ebx,%ebx
80103cf0:	74 40                	je     80103d32 <dump_physmem+0x60>
     return -1;
    }
    //cprintf("Inside dump_physmem %d,\n",nframes);
    //int fr[numframes];
    for(int i=0; i < nframes; i++)
80103cf2:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf7:	eb 0d                	jmp    80103d06 <dump_physmem+0x34>
    {
      userFrames[i] = frames[i];
80103cf9:	8b 0c 85 80 5b 1d 80 	mov    -0x7fe2a480(,%eax,4),%ecx
80103d00:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
    for(int i=0; i < nframes; i++)
80103d03:	83 c0 01             	add    $0x1,%eax
80103d06:	39 d0                	cmp    %edx,%eax
80103d08:	7c ef                	jl     80103cf9 <dump_physmem+0x27>
      //cprintf("%d,%x,%x\n",i,userFrames[i],frames[i]);
    }
    //userFrames = fr;
    for(int i=0; i < nframes; i++)
80103d0a:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0f:	eb 0d                	jmp    80103d1e <dump_physmem+0x4c>
    {
      userPids[i] = pid[i];
80103d11:	8b 0c 85 80 26 11 80 	mov    -0x7feed980(,%eax,4),%ecx
80103d18:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
    for(int i=0; i < nframes; i++)
80103d1b:	83 c0 01             	add    $0x1,%eax
80103d1e:	39 d0                	cmp    %edx,%eax
80103d20:	7c ef                	jl     80103d11 <dump_physmem+0x3f>
      //cprintf("%d\n", pid[i]);
    }

    return 0;
80103d22:	b8 00 00 00 00       	mov    $0x0,%eax

}
80103d27:	5b                   	pop    %ebx
80103d28:	5e                   	pop    %esi
80103d29:	5d                   	pop    %ebp
80103d2a:	c3                   	ret    
     return -1;
80103d2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d30:	eb f5                	jmp    80103d27 <dump_physmem+0x55>
80103d32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d37:	eb ee                	jmp    80103d27 <dump_physmem+0x55>

80103d39 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103d39:	55                   	push   %ebp
80103d3a:	89 e5                	mov    %esp,%ebp
80103d3c:	53                   	push   %ebx
80103d3d:	83 ec 0c             	sub    $0xc,%esp
80103d40:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103d43:	68 78 6f 10 80       	push   $0x80106f78
80103d48:	8d 43 04             	lea    0x4(%ebx),%eax
80103d4b:	50                   	push   %eax
80103d4c:	e8 f3 00 00 00       	call   80103e44 <initlock>
  lk->name = name;
80103d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d54:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103d57:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103d5d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103d64:	83 c4 10             	add    $0x10,%esp
80103d67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d6a:	c9                   	leave  
80103d6b:	c3                   	ret    

80103d6c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103d6c:	55                   	push   %ebp
80103d6d:	89 e5                	mov    %esp,%ebp
80103d6f:	56                   	push   %esi
80103d70:	53                   	push   %ebx
80103d71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103d74:	8d 73 04             	lea    0x4(%ebx),%esi
80103d77:	83 ec 0c             	sub    $0xc,%esp
80103d7a:	56                   	push   %esi
80103d7b:	e8 00 02 00 00       	call   80103f80 <acquire>
  while (lk->locked) {
80103d80:	83 c4 10             	add    $0x10,%esp
80103d83:	eb 0d                	jmp    80103d92 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103d85:	83 ec 08             	sub    $0x8,%esp
80103d88:	56                   	push   %esi
80103d89:	53                   	push   %ebx
80103d8a:	e8 8f fc ff ff       	call   80103a1e <sleep>
80103d8f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103d92:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d95:	75 ee                	jne    80103d85 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103d97:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103d9d:	e8 c4 f7 ff ff       	call   80103566 <myproc>
80103da2:	8b 40 10             	mov    0x10(%eax),%eax
80103da5:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103da8:	83 ec 0c             	sub    $0xc,%esp
80103dab:	56                   	push   %esi
80103dac:	e8 34 02 00 00       	call   80103fe5 <release>
}
80103db1:	83 c4 10             	add    $0x10,%esp
80103db4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103db7:	5b                   	pop    %ebx
80103db8:	5e                   	pop    %esi
80103db9:	5d                   	pop    %ebp
80103dba:	c3                   	ret    

80103dbb <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103dbb:	55                   	push   %ebp
80103dbc:	89 e5                	mov    %esp,%ebp
80103dbe:	56                   	push   %esi
80103dbf:	53                   	push   %ebx
80103dc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103dc3:	8d 73 04             	lea    0x4(%ebx),%esi
80103dc6:	83 ec 0c             	sub    $0xc,%esp
80103dc9:	56                   	push   %esi
80103dca:	e8 b1 01 00 00       	call   80103f80 <acquire>
  lk->locked = 0;
80103dcf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103dd5:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ddc:	89 1c 24             	mov    %ebx,(%esp)
80103ddf:	e8 9f fd ff ff       	call   80103b83 <wakeup>
  release(&lk->lk);
80103de4:	89 34 24             	mov    %esi,(%esp)
80103de7:	e8 f9 01 00 00       	call   80103fe5 <release>
}
80103dec:	83 c4 10             	add    $0x10,%esp
80103def:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103df2:	5b                   	pop    %ebx
80103df3:	5e                   	pop    %esi
80103df4:	5d                   	pop    %ebp
80103df5:	c3                   	ret    

80103df6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103df6:	55                   	push   %ebp
80103df7:	89 e5                	mov    %esp,%ebp
80103df9:	56                   	push   %esi
80103dfa:	53                   	push   %ebx
80103dfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103dfe:	8d 73 04             	lea    0x4(%ebx),%esi
80103e01:	83 ec 0c             	sub    $0xc,%esp
80103e04:	56                   	push   %esi
80103e05:	e8 76 01 00 00       	call   80103f80 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103e0a:	83 c4 10             	add    $0x10,%esp
80103e0d:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e10:	75 17                	jne    80103e29 <holdingsleep+0x33>
80103e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	56                   	push   %esi
80103e1b:	e8 c5 01 00 00       	call   80103fe5 <release>
  return r;
}
80103e20:	89 d8                	mov    %ebx,%eax
80103e22:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e25:	5b                   	pop    %ebx
80103e26:	5e                   	pop    %esi
80103e27:	5d                   	pop    %ebp
80103e28:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103e29:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103e2c:	e8 35 f7 ff ff       	call   80103566 <myproc>
80103e31:	3b 58 10             	cmp    0x10(%eax),%ebx
80103e34:	74 07                	je     80103e3d <holdingsleep+0x47>
80103e36:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e3b:	eb da                	jmp    80103e17 <holdingsleep+0x21>
80103e3d:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e42:	eb d3                	jmp    80103e17 <holdingsleep+0x21>

80103e44 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103e44:	55                   	push   %ebp
80103e45:	89 e5                	mov    %esp,%ebp
80103e47:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e4d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103e50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103e56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103e5d:	5d                   	pop    %ebp
80103e5e:	c3                   	ret    

80103e5f <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103e5f:	55                   	push   %ebp
80103e60:	89 e5                	mov    %esp,%ebp
80103e62:	53                   	push   %ebx
80103e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103e66:	8b 45 08             	mov    0x8(%ebp),%eax
80103e69:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103e6c:	b8 00 00 00 00       	mov    $0x0,%eax
80103e71:	83 f8 09             	cmp    $0x9,%eax
80103e74:	7f 25                	jg     80103e9b <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103e76:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103e7c:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103e82:	77 17                	ja     80103e9b <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103e84:	8b 5a 04             	mov    0x4(%edx),%ebx
80103e87:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103e8a:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103e8c:	83 c0 01             	add    $0x1,%eax
80103e8f:	eb e0                	jmp    80103e71 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103e91:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103e98:	83 c0 01             	add    $0x1,%eax
80103e9b:	83 f8 09             	cmp    $0x9,%eax
80103e9e:	7e f1                	jle    80103e91 <getcallerpcs+0x32>
}
80103ea0:	5b                   	pop    %ebx
80103ea1:	5d                   	pop    %ebp
80103ea2:	c3                   	ret    

80103ea3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103ea3:	55                   	push   %ebp
80103ea4:	89 e5                	mov    %esp,%ebp
80103ea6:	53                   	push   %ebx
80103ea7:	83 ec 04             	sub    $0x4,%esp
80103eaa:	9c                   	pushf  
80103eab:	5b                   	pop    %ebx
  asm volatile("cli");
80103eac:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103ead:	e8 3d f6 ff ff       	call   801034ef <mycpu>
80103eb2:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103eb9:	74 12                	je     80103ecd <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103ebb:	e8 2f f6 ff ff       	call   801034ef <mycpu>
80103ec0:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103ec7:	83 c4 04             	add    $0x4,%esp
80103eca:	5b                   	pop    %ebx
80103ecb:	5d                   	pop    %ebp
80103ecc:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103ecd:	e8 1d f6 ff ff       	call   801034ef <mycpu>
80103ed2:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ed8:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103ede:	eb db                	jmp    80103ebb <pushcli+0x18>

80103ee0 <popcli>:

void
popcli(void)
{
80103ee0:	55                   	push   %ebp
80103ee1:	89 e5                	mov    %esp,%ebp
80103ee3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ee6:	9c                   	pushf  
80103ee7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103ee8:	f6 c4 02             	test   $0x2,%ah
80103eeb:	75 28                	jne    80103f15 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103eed:	e8 fd f5 ff ff       	call   801034ef <mycpu>
80103ef2:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103ef8:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103efb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103f01:	85 d2                	test   %edx,%edx
80103f03:	78 1d                	js     80103f22 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103f05:	e8 e5 f5 ff ff       	call   801034ef <mycpu>
80103f0a:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103f11:	74 1c                	je     80103f2f <popcli+0x4f>
    sti();
}
80103f13:	c9                   	leave  
80103f14:	c3                   	ret    
    panic("popcli - interruptible");
80103f15:	83 ec 0c             	sub    $0xc,%esp
80103f18:	68 83 6f 10 80       	push   $0x80106f83
80103f1d:	e8 26 c4 ff ff       	call   80100348 <panic>
    panic("popcli");
80103f22:	83 ec 0c             	sub    $0xc,%esp
80103f25:	68 9a 6f 10 80       	push   $0x80106f9a
80103f2a:	e8 19 c4 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103f2f:	e8 bb f5 ff ff       	call   801034ef <mycpu>
80103f34:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103f3b:	74 d6                	je     80103f13 <popcli+0x33>
  asm volatile("sti");
80103f3d:	fb                   	sti    
}
80103f3e:	eb d3                	jmp    80103f13 <popcli+0x33>

80103f40 <holding>:
{
80103f40:	55                   	push   %ebp
80103f41:	89 e5                	mov    %esp,%ebp
80103f43:	53                   	push   %ebx
80103f44:	83 ec 04             	sub    $0x4,%esp
80103f47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103f4a:	e8 54 ff ff ff       	call   80103ea3 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103f4f:	83 3b 00             	cmpl   $0x0,(%ebx)
80103f52:	75 12                	jne    80103f66 <holding+0x26>
80103f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103f59:	e8 82 ff ff ff       	call   80103ee0 <popcli>
}
80103f5e:	89 d8                	mov    %ebx,%eax
80103f60:	83 c4 04             	add    $0x4,%esp
80103f63:	5b                   	pop    %ebx
80103f64:	5d                   	pop    %ebp
80103f65:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103f66:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103f69:	e8 81 f5 ff ff       	call   801034ef <mycpu>
80103f6e:	39 c3                	cmp    %eax,%ebx
80103f70:	74 07                	je     80103f79 <holding+0x39>
80103f72:	bb 00 00 00 00       	mov    $0x0,%ebx
80103f77:	eb e0                	jmp    80103f59 <holding+0x19>
80103f79:	bb 01 00 00 00       	mov    $0x1,%ebx
80103f7e:	eb d9                	jmp    80103f59 <holding+0x19>

80103f80 <acquire>:
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
80103f83:	53                   	push   %ebx
80103f84:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103f87:	e8 17 ff ff ff       	call   80103ea3 <pushcli>
  if(holding(lk))
80103f8c:	83 ec 0c             	sub    $0xc,%esp
80103f8f:	ff 75 08             	pushl  0x8(%ebp)
80103f92:	e8 a9 ff ff ff       	call   80103f40 <holding>
80103f97:	83 c4 10             	add    $0x10,%esp
80103f9a:	85 c0                	test   %eax,%eax
80103f9c:	75 3a                	jne    80103fd8 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103fa1:	b8 01 00 00 00       	mov    $0x1,%eax
80103fa6:	f0 87 02             	lock xchg %eax,(%edx)
80103fa9:	85 c0                	test   %eax,%eax
80103fab:	75 f1                	jne    80103f9e <acquire+0x1e>
  __sync_synchronize();
80103fad:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103fb5:	e8 35 f5 ff ff       	call   801034ef <mycpu>
80103fba:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	83 c0 0c             	add    $0xc,%eax
80103fc3:	83 ec 08             	sub    $0x8,%esp
80103fc6:	50                   	push   %eax
80103fc7:	8d 45 08             	lea    0x8(%ebp),%eax
80103fca:	50                   	push   %eax
80103fcb:	e8 8f fe ff ff       	call   80103e5f <getcallerpcs>
}
80103fd0:	83 c4 10             	add    $0x10,%esp
80103fd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103fd6:	c9                   	leave  
80103fd7:	c3                   	ret    
    panic("acquire");
80103fd8:	83 ec 0c             	sub    $0xc,%esp
80103fdb:	68 a1 6f 10 80       	push   $0x80106fa1
80103fe0:	e8 63 c3 ff ff       	call   80100348 <panic>

80103fe5 <release>:
{
80103fe5:	55                   	push   %ebp
80103fe6:	89 e5                	mov    %esp,%ebp
80103fe8:	53                   	push   %ebx
80103fe9:	83 ec 10             	sub    $0x10,%esp
80103fec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103fef:	53                   	push   %ebx
80103ff0:	e8 4b ff ff ff       	call   80103f40 <holding>
80103ff5:	83 c4 10             	add    $0x10,%esp
80103ff8:	85 c0                	test   %eax,%eax
80103ffa:	74 23                	je     8010401f <release+0x3a>
  lk->pcs[0] = 0;
80103ffc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104003:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
8010400a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010400f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80104015:	e8 c6 fe ff ff       	call   80103ee0 <popcli>
}
8010401a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010401d:	c9                   	leave  
8010401e:	c3                   	ret    
    panic("release");
8010401f:	83 ec 0c             	sub    $0xc,%esp
80104022:	68 a9 6f 10 80       	push   $0x80106fa9
80104027:	e8 1c c3 ff ff       	call   80100348 <panic>

8010402c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010402c:	55                   	push   %ebp
8010402d:	89 e5                	mov    %esp,%ebp
8010402f:	57                   	push   %edi
80104030:	53                   	push   %ebx
80104031:	8b 55 08             	mov    0x8(%ebp),%edx
80104034:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104037:	f6 c2 03             	test   $0x3,%dl
8010403a:	75 05                	jne    80104041 <memset+0x15>
8010403c:	f6 c1 03             	test   $0x3,%cl
8010403f:	74 0e                	je     8010404f <memset+0x23>
  asm volatile("cld; rep stosb" :
80104041:	89 d7                	mov    %edx,%edi
80104043:	8b 45 0c             	mov    0xc(%ebp),%eax
80104046:	fc                   	cld    
80104047:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104049:	89 d0                	mov    %edx,%eax
8010404b:	5b                   	pop    %ebx
8010404c:	5f                   	pop    %edi
8010404d:	5d                   	pop    %ebp
8010404e:	c3                   	ret    
    c &= 0xFF;
8010404f:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104053:	c1 e9 02             	shr    $0x2,%ecx
80104056:	89 f8                	mov    %edi,%eax
80104058:	c1 e0 18             	shl    $0x18,%eax
8010405b:	89 fb                	mov    %edi,%ebx
8010405d:	c1 e3 10             	shl    $0x10,%ebx
80104060:	09 d8                	or     %ebx,%eax
80104062:	89 fb                	mov    %edi,%ebx
80104064:	c1 e3 08             	shl    $0x8,%ebx
80104067:	09 d8                	or     %ebx,%eax
80104069:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
8010406b:	89 d7                	mov    %edx,%edi
8010406d:	fc                   	cld    
8010406e:	f3 ab                	rep stos %eax,%es:(%edi)
80104070:	eb d7                	jmp    80104049 <memset+0x1d>

80104072 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104072:	55                   	push   %ebp
80104073:	89 e5                	mov    %esp,%ebp
80104075:	56                   	push   %esi
80104076:	53                   	push   %ebx
80104077:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010407a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010407d:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104080:	8d 70 ff             	lea    -0x1(%eax),%esi
80104083:	85 c0                	test   %eax,%eax
80104085:	74 1c                	je     801040a3 <memcmp+0x31>
    if(*s1 != *s2)
80104087:	0f b6 01             	movzbl (%ecx),%eax
8010408a:	0f b6 1a             	movzbl (%edx),%ebx
8010408d:	38 d8                	cmp    %bl,%al
8010408f:	75 0a                	jne    8010409b <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80104091:	83 c1 01             	add    $0x1,%ecx
80104094:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104097:	89 f0                	mov    %esi,%eax
80104099:	eb e5                	jmp    80104080 <memcmp+0xe>
      return *s1 - *s2;
8010409b:	0f b6 c0             	movzbl %al,%eax
8010409e:	0f b6 db             	movzbl %bl,%ebx
801040a1:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
801040a3:	5b                   	pop    %ebx
801040a4:	5e                   	pop    %esi
801040a5:	5d                   	pop    %ebp
801040a6:	c3                   	ret    

801040a7 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801040a7:	55                   	push   %ebp
801040a8:	89 e5                	mov    %esp,%ebp
801040aa:	56                   	push   %esi
801040ab:	53                   	push   %ebx
801040ac:	8b 45 08             	mov    0x8(%ebp),%eax
801040af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801040b2:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801040b5:	39 c1                	cmp    %eax,%ecx
801040b7:	73 3a                	jae    801040f3 <memmove+0x4c>
801040b9:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
801040bc:	39 c3                	cmp    %eax,%ebx
801040be:	76 37                	jbe    801040f7 <memmove+0x50>
    s += n;
    d += n;
801040c0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
801040c3:	eb 0d                	jmp    801040d2 <memmove+0x2b>
      *--d = *--s;
801040c5:	83 eb 01             	sub    $0x1,%ebx
801040c8:	83 e9 01             	sub    $0x1,%ecx
801040cb:	0f b6 13             	movzbl (%ebx),%edx
801040ce:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
801040d0:	89 f2                	mov    %esi,%edx
801040d2:	8d 72 ff             	lea    -0x1(%edx),%esi
801040d5:	85 d2                	test   %edx,%edx
801040d7:	75 ec                	jne    801040c5 <memmove+0x1e>
801040d9:	eb 14                	jmp    801040ef <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
801040db:	0f b6 11             	movzbl (%ecx),%edx
801040de:	88 13                	mov    %dl,(%ebx)
801040e0:	8d 5b 01             	lea    0x1(%ebx),%ebx
801040e3:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
801040e6:	89 f2                	mov    %esi,%edx
801040e8:	8d 72 ff             	lea    -0x1(%edx),%esi
801040eb:	85 d2                	test   %edx,%edx
801040ed:	75 ec                	jne    801040db <memmove+0x34>

  return dst;
}
801040ef:	5b                   	pop    %ebx
801040f0:	5e                   	pop    %esi
801040f1:	5d                   	pop    %ebp
801040f2:	c3                   	ret    
801040f3:	89 c3                	mov    %eax,%ebx
801040f5:	eb f1                	jmp    801040e8 <memmove+0x41>
801040f7:	89 c3                	mov    %eax,%ebx
801040f9:	eb ed                	jmp    801040e8 <memmove+0x41>

801040fb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801040fb:	55                   	push   %ebp
801040fc:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801040fe:	ff 75 10             	pushl  0x10(%ebp)
80104101:	ff 75 0c             	pushl  0xc(%ebp)
80104104:	ff 75 08             	pushl  0x8(%ebp)
80104107:	e8 9b ff ff ff       	call   801040a7 <memmove>
}
8010410c:	c9                   	leave  
8010410d:	c3                   	ret    

8010410e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010410e:	55                   	push   %ebp
8010410f:	89 e5                	mov    %esp,%ebp
80104111:	53                   	push   %ebx
80104112:	8b 55 08             	mov    0x8(%ebp),%edx
80104115:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104118:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
8010411b:	eb 09                	jmp    80104126 <strncmp+0x18>
    n--, p++, q++;
8010411d:	83 e8 01             	sub    $0x1,%eax
80104120:	83 c2 01             	add    $0x1,%edx
80104123:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104126:	85 c0                	test   %eax,%eax
80104128:	74 0b                	je     80104135 <strncmp+0x27>
8010412a:	0f b6 1a             	movzbl (%edx),%ebx
8010412d:	84 db                	test   %bl,%bl
8010412f:	74 04                	je     80104135 <strncmp+0x27>
80104131:	3a 19                	cmp    (%ecx),%bl
80104133:	74 e8                	je     8010411d <strncmp+0xf>
  if(n == 0)
80104135:	85 c0                	test   %eax,%eax
80104137:	74 0b                	je     80104144 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80104139:	0f b6 02             	movzbl (%edx),%eax
8010413c:	0f b6 11             	movzbl (%ecx),%edx
8010413f:	29 d0                	sub    %edx,%eax
}
80104141:	5b                   	pop    %ebx
80104142:	5d                   	pop    %ebp
80104143:	c3                   	ret    
    return 0;
80104144:	b8 00 00 00 00       	mov    $0x0,%eax
80104149:	eb f6                	jmp    80104141 <strncmp+0x33>

8010414b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010414b:	55                   	push   %ebp
8010414c:	89 e5                	mov    %esp,%ebp
8010414e:	57                   	push   %edi
8010414f:	56                   	push   %esi
80104150:	53                   	push   %ebx
80104151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104154:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104157:	8b 45 08             	mov    0x8(%ebp),%eax
8010415a:	eb 04                	jmp    80104160 <strncpy+0x15>
8010415c:	89 fb                	mov    %edi,%ebx
8010415e:	89 f0                	mov    %esi,%eax
80104160:	8d 51 ff             	lea    -0x1(%ecx),%edx
80104163:	85 c9                	test   %ecx,%ecx
80104165:	7e 1d                	jle    80104184 <strncpy+0x39>
80104167:	8d 7b 01             	lea    0x1(%ebx),%edi
8010416a:	8d 70 01             	lea    0x1(%eax),%esi
8010416d:	0f b6 1b             	movzbl (%ebx),%ebx
80104170:	88 18                	mov    %bl,(%eax)
80104172:	89 d1                	mov    %edx,%ecx
80104174:	84 db                	test   %bl,%bl
80104176:	75 e4                	jne    8010415c <strncpy+0x11>
80104178:	89 f0                	mov    %esi,%eax
8010417a:	eb 08                	jmp    80104184 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
8010417c:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010417f:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104181:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80104184:	8d 4a ff             	lea    -0x1(%edx),%ecx
80104187:	85 d2                	test   %edx,%edx
80104189:	7f f1                	jg     8010417c <strncpy+0x31>
  return os;
}
8010418b:	8b 45 08             	mov    0x8(%ebp),%eax
8010418e:	5b                   	pop    %ebx
8010418f:	5e                   	pop    %esi
80104190:	5f                   	pop    %edi
80104191:	5d                   	pop    %ebp
80104192:	c3                   	ret    

80104193 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104193:	55                   	push   %ebp
80104194:	89 e5                	mov    %esp,%ebp
80104196:	57                   	push   %edi
80104197:	56                   	push   %esi
80104198:	53                   	push   %ebx
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010419f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
801041a2:	85 d2                	test   %edx,%edx
801041a4:	7e 23                	jle    801041c9 <safestrcpy+0x36>
801041a6:	89 c1                	mov    %eax,%ecx
801041a8:	eb 04                	jmp    801041ae <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
801041aa:	89 fb                	mov    %edi,%ebx
801041ac:	89 f1                	mov    %esi,%ecx
801041ae:	83 ea 01             	sub    $0x1,%edx
801041b1:	85 d2                	test   %edx,%edx
801041b3:	7e 11                	jle    801041c6 <safestrcpy+0x33>
801041b5:	8d 7b 01             	lea    0x1(%ebx),%edi
801041b8:	8d 71 01             	lea    0x1(%ecx),%esi
801041bb:	0f b6 1b             	movzbl (%ebx),%ebx
801041be:	88 19                	mov    %bl,(%ecx)
801041c0:	84 db                	test   %bl,%bl
801041c2:	75 e6                	jne    801041aa <safestrcpy+0x17>
801041c4:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
801041c6:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
801041c9:	5b                   	pop    %ebx
801041ca:	5e                   	pop    %esi
801041cb:	5f                   	pop    %edi
801041cc:	5d                   	pop    %ebp
801041cd:	c3                   	ret    

801041ce <strlen>:

int
strlen(const char *s)
{
801041ce:	55                   	push   %ebp
801041cf:	89 e5                	mov    %esp,%ebp
801041d1:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
801041d4:	b8 00 00 00 00       	mov    $0x0,%eax
801041d9:	eb 03                	jmp    801041de <strlen+0x10>
801041db:	83 c0 01             	add    $0x1,%eax
801041de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801041e2:	75 f7                	jne    801041db <strlen+0xd>
    ;
  return n;
}
801041e4:	5d                   	pop    %ebp
801041e5:	c3                   	ret    

801041e6 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801041e6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801041ea:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801041ee:	55                   	push   %ebp
  pushl %ebx
801041ef:	53                   	push   %ebx
  pushl %esi
801041f0:	56                   	push   %esi
  pushl %edi
801041f1:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801041f2:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801041f4:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801041f6:	5f                   	pop    %edi
  popl %esi
801041f7:	5e                   	pop    %esi
  popl %ebx
801041f8:	5b                   	pop    %ebx
  popl %ebp
801041f9:	5d                   	pop    %ebp
  ret
801041fa:	c3                   	ret    

801041fb <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801041fb:	55                   	push   %ebp
801041fc:	89 e5                	mov    %esp,%ebp
801041fe:	53                   	push   %ebx
801041ff:	83 ec 04             	sub    $0x4,%esp
80104202:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104205:	e8 5c f3 ff ff       	call   80103566 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010420a:	8b 00                	mov    (%eax),%eax
8010420c:	39 d8                	cmp    %ebx,%eax
8010420e:	76 19                	jbe    80104229 <fetchint+0x2e>
80104210:	8d 53 04             	lea    0x4(%ebx),%edx
80104213:	39 d0                	cmp    %edx,%eax
80104215:	72 19                	jb     80104230 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80104217:	8b 13                	mov    (%ebx),%edx
80104219:	8b 45 0c             	mov    0xc(%ebp),%eax
8010421c:	89 10                	mov    %edx,(%eax)
  return 0;
8010421e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104223:	83 c4 04             	add    $0x4,%esp
80104226:	5b                   	pop    %ebx
80104227:	5d                   	pop    %ebp
80104228:	c3                   	ret    
    return -1;
80104229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010422e:	eb f3                	jmp    80104223 <fetchint+0x28>
80104230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104235:	eb ec                	jmp    80104223 <fetchint+0x28>

80104237 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104237:	55                   	push   %ebp
80104238:	89 e5                	mov    %esp,%ebp
8010423a:	53                   	push   %ebx
8010423b:	83 ec 04             	sub    $0x4,%esp
8010423e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104241:	e8 20 f3 ff ff       	call   80103566 <myproc>

  if(addr >= curproc->sz)
80104246:	39 18                	cmp    %ebx,(%eax)
80104248:	76 26                	jbe    80104270 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
8010424a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010424d:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010424f:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104251:	89 d8                	mov    %ebx,%eax
80104253:	39 d0                	cmp    %edx,%eax
80104255:	73 0e                	jae    80104265 <fetchstr+0x2e>
    if(*s == 0)
80104257:	80 38 00             	cmpb   $0x0,(%eax)
8010425a:	74 05                	je     80104261 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
8010425c:	83 c0 01             	add    $0x1,%eax
8010425f:	eb f2                	jmp    80104253 <fetchstr+0x1c>
      return s - *pp;
80104261:	29 d8                	sub    %ebx,%eax
80104263:	eb 05                	jmp    8010426a <fetchstr+0x33>
  }
  return -1;
80104265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010426a:	83 c4 04             	add    $0x4,%esp
8010426d:	5b                   	pop    %ebx
8010426e:	5d                   	pop    %ebp
8010426f:	c3                   	ret    
    return -1;
80104270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104275:	eb f3                	jmp    8010426a <fetchstr+0x33>

80104277 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104277:	55                   	push   %ebp
80104278:	89 e5                	mov    %esp,%ebp
8010427a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010427d:	e8 e4 f2 ff ff       	call   80103566 <myproc>
80104282:	8b 50 18             	mov    0x18(%eax),%edx
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	c1 e0 02             	shl    $0x2,%eax
8010428b:	03 42 44             	add    0x44(%edx),%eax
8010428e:	83 ec 08             	sub    $0x8,%esp
80104291:	ff 75 0c             	pushl  0xc(%ebp)
80104294:	83 c0 04             	add    $0x4,%eax
80104297:	50                   	push   %eax
80104298:	e8 5e ff ff ff       	call   801041fb <fetchint>
}
8010429d:	c9                   	leave  
8010429e:	c3                   	ret    

8010429f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010429f:	55                   	push   %ebp
801042a0:	89 e5                	mov    %esp,%ebp
801042a2:	56                   	push   %esi
801042a3:	53                   	push   %ebx
801042a4:	83 ec 10             	sub    $0x10,%esp
801042a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
801042aa:	e8 b7 f2 ff ff       	call   80103566 <myproc>
801042af:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801042b1:	83 ec 08             	sub    $0x8,%esp
801042b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801042b7:	50                   	push   %eax
801042b8:	ff 75 08             	pushl  0x8(%ebp)
801042bb:	e8 b7 ff ff ff       	call   80104277 <argint>
801042c0:	83 c4 10             	add    $0x10,%esp
801042c3:	85 c0                	test   %eax,%eax
801042c5:	78 24                	js     801042eb <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801042c7:	85 db                	test   %ebx,%ebx
801042c9:	78 27                	js     801042f2 <argptr+0x53>
801042cb:	8b 16                	mov    (%esi),%edx
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	39 c2                	cmp    %eax,%edx
801042d2:	76 25                	jbe    801042f9 <argptr+0x5a>
801042d4:	01 c3                	add    %eax,%ebx
801042d6:	39 da                	cmp    %ebx,%edx
801042d8:	72 26                	jb     80104300 <argptr+0x61>
    return -1;
  *pp = (char*)i;
801042da:	8b 55 0c             	mov    0xc(%ebp),%edx
801042dd:	89 02                	mov    %eax,(%edx)
  return 0;
801042df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801042e7:	5b                   	pop    %ebx
801042e8:	5e                   	pop    %esi
801042e9:	5d                   	pop    %ebp
801042ea:	c3                   	ret    
    return -1;
801042eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042f0:	eb f2                	jmp    801042e4 <argptr+0x45>
    return -1;
801042f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042f7:	eb eb                	jmp    801042e4 <argptr+0x45>
801042f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042fe:	eb e4                	jmp    801042e4 <argptr+0x45>
80104300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104305:	eb dd                	jmp    801042e4 <argptr+0x45>

80104307 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104307:	55                   	push   %ebp
80104308:	89 e5                	mov    %esp,%ebp
8010430a:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010430d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104310:	50                   	push   %eax
80104311:	ff 75 08             	pushl  0x8(%ebp)
80104314:	e8 5e ff ff ff       	call   80104277 <argint>
80104319:	83 c4 10             	add    $0x10,%esp
8010431c:	85 c0                	test   %eax,%eax
8010431e:	78 13                	js     80104333 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104320:	83 ec 08             	sub    $0x8,%esp
80104323:	ff 75 0c             	pushl  0xc(%ebp)
80104326:	ff 75 f4             	pushl  -0xc(%ebp)
80104329:	e8 09 ff ff ff       	call   80104237 <fetchstr>
8010432e:	83 c4 10             	add    $0x10,%esp
}
80104331:	c9                   	leave  
80104332:	c3                   	ret    
    return -1;
80104333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104338:	eb f7                	jmp    80104331 <argstr+0x2a>

8010433a <syscall>:
[SYS_dump_physmem]    sys_dump_physmem,
};

void
syscall(void)
{
8010433a:	55                   	push   %ebp
8010433b:	89 e5                	mov    %esp,%ebp
8010433d:	53                   	push   %ebx
8010433e:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104341:	e8 20 f2 ff ff       	call   80103566 <myproc>
80104346:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104348:	8b 40 18             	mov    0x18(%eax),%eax
8010434b:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010434e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104351:	83 fa 15             	cmp    $0x15,%edx
80104354:	77 18                	ja     8010436e <syscall+0x34>
80104356:	8b 14 85 e0 6f 10 80 	mov    -0x7fef9020(,%eax,4),%edx
8010435d:	85 d2                	test   %edx,%edx
8010435f:	74 0d                	je     8010436e <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104361:	ff d2                	call   *%edx
80104363:	8b 53 18             	mov    0x18(%ebx),%edx
80104366:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010436c:	c9                   	leave  
8010436d:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010436e:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104371:	50                   	push   %eax
80104372:	52                   	push   %edx
80104373:	ff 73 10             	pushl  0x10(%ebx)
80104376:	68 b1 6f 10 80       	push   $0x80106fb1
8010437b:	e8 8b c2 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104380:	8b 43 18             	mov    0x18(%ebx),%eax
80104383:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010438a:	83 c4 10             	add    $0x10,%esp
}
8010438d:	eb da                	jmp    80104369 <syscall+0x2f>

8010438f <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010438f:	55                   	push   %ebp
80104390:	89 e5                	mov    %esp,%ebp
80104392:	56                   	push   %esi
80104393:	53                   	push   %ebx
80104394:	83 ec 18             	sub    $0x18,%esp
80104397:	89 d6                	mov    %edx,%esi
80104399:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010439b:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010439e:	52                   	push   %edx
8010439f:	50                   	push   %eax
801043a0:	e8 d2 fe ff ff       	call   80104277 <argint>
801043a5:	83 c4 10             	add    $0x10,%esp
801043a8:	85 c0                	test   %eax,%eax
801043aa:	78 2e                	js     801043da <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801043ac:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801043b0:	77 2f                	ja     801043e1 <argfd+0x52>
801043b2:	e8 af f1 ff ff       	call   80103566 <myproc>
801043b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ba:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801043be:	85 c0                	test   %eax,%eax
801043c0:	74 26                	je     801043e8 <argfd+0x59>
    return -1;
  if(pfd)
801043c2:	85 f6                	test   %esi,%esi
801043c4:	74 02                	je     801043c8 <argfd+0x39>
    *pfd = fd;
801043c6:	89 16                	mov    %edx,(%esi)
  if(pf)
801043c8:	85 db                	test   %ebx,%ebx
801043ca:	74 23                	je     801043ef <argfd+0x60>
    *pf = f;
801043cc:	89 03                	mov    %eax,(%ebx)
  return 0;
801043ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043d6:	5b                   	pop    %ebx
801043d7:	5e                   	pop    %esi
801043d8:	5d                   	pop    %ebp
801043d9:	c3                   	ret    
    return -1;
801043da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043df:	eb f2                	jmp    801043d3 <argfd+0x44>
    return -1;
801043e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043e6:	eb eb                	jmp    801043d3 <argfd+0x44>
801043e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ed:	eb e4                	jmp    801043d3 <argfd+0x44>
  return 0;
801043ef:	b8 00 00 00 00       	mov    $0x0,%eax
801043f4:	eb dd                	jmp    801043d3 <argfd+0x44>

801043f6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801043f6:	55                   	push   %ebp
801043f7:	89 e5                	mov    %esp,%ebp
801043f9:	53                   	push   %ebx
801043fa:	83 ec 04             	sub    $0x4,%esp
801043fd:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801043ff:	e8 62 f1 ff ff       	call   80103566 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104404:	ba 00 00 00 00       	mov    $0x0,%edx
80104409:	83 fa 0f             	cmp    $0xf,%edx
8010440c:	7f 18                	jg     80104426 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
8010440e:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104413:	74 05                	je     8010441a <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104415:	83 c2 01             	add    $0x1,%edx
80104418:	eb ef                	jmp    80104409 <fdalloc+0x13>
      curproc->ofile[fd] = f;
8010441a:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
8010441e:	89 d0                	mov    %edx,%eax
80104420:	83 c4 04             	add    $0x4,%esp
80104423:	5b                   	pop    %ebx
80104424:	5d                   	pop    %ebp
80104425:	c3                   	ret    
  return -1;
80104426:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010442b:	eb f1                	jmp    8010441e <fdalloc+0x28>

8010442d <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010442d:	55                   	push   %ebp
8010442e:	89 e5                	mov    %esp,%ebp
80104430:	56                   	push   %esi
80104431:	53                   	push   %ebx
80104432:	83 ec 10             	sub    $0x10,%esp
80104435:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104437:	b8 20 00 00 00       	mov    $0x20,%eax
8010443c:	89 c6                	mov    %eax,%esi
8010443e:	39 43 58             	cmp    %eax,0x58(%ebx)
80104441:	76 2e                	jbe    80104471 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104443:	6a 10                	push   $0x10
80104445:	50                   	push   %eax
80104446:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104449:	50                   	push   %eax
8010444a:	53                   	push   %ebx
8010444b:	e8 37 d3 ff ff       	call   80101787 <readi>
80104450:	83 c4 10             	add    $0x10,%esp
80104453:	83 f8 10             	cmp    $0x10,%eax
80104456:	75 0c                	jne    80104464 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104458:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010445d:	75 1e                	jne    8010447d <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010445f:	8d 46 10             	lea    0x10(%esi),%eax
80104462:	eb d8                	jmp    8010443c <isdirempty+0xf>
      panic("isdirempty: readi");
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	68 3c 70 10 80       	push   $0x8010703c
8010446c:	e8 d7 be ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104471:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104476:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104479:	5b                   	pop    %ebx
8010447a:	5e                   	pop    %esi
8010447b:	5d                   	pop    %ebp
8010447c:	c3                   	ret    
      return 0;
8010447d:	b8 00 00 00 00       	mov    $0x0,%eax
80104482:	eb f2                	jmp    80104476 <isdirempty+0x49>

80104484 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104484:	55                   	push   %ebp
80104485:	89 e5                	mov    %esp,%ebp
80104487:	57                   	push   %edi
80104488:	56                   	push   %esi
80104489:	53                   	push   %ebx
8010448a:	83 ec 44             	sub    $0x44,%esp
8010448d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104490:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104493:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104496:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104499:	52                   	push   %edx
8010449a:	50                   	push   %eax
8010449b:	e8 6d d7 ff ff       	call   80101c0d <nameiparent>
801044a0:	89 c6                	mov    %eax,%esi
801044a2:	83 c4 10             	add    $0x10,%esp
801044a5:	85 c0                	test   %eax,%eax
801044a7:	0f 84 3a 01 00 00    	je     801045e7 <create+0x163>
    return 0;
  ilock(dp);
801044ad:	83 ec 0c             	sub    $0xc,%esp
801044b0:	50                   	push   %eax
801044b1:	e8 df d0 ff ff       	call   80101595 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801044b6:	83 c4 0c             	add    $0xc,%esp
801044b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801044bc:	50                   	push   %eax
801044bd:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801044c0:	50                   	push   %eax
801044c1:	56                   	push   %esi
801044c2:	e8 fd d4 ff ff       	call   801019c4 <dirlookup>
801044c7:	89 c3                	mov    %eax,%ebx
801044c9:	83 c4 10             	add    $0x10,%esp
801044cc:	85 c0                	test   %eax,%eax
801044ce:	74 3f                	je     8010450f <create+0x8b>
    iunlockput(dp);
801044d0:	83 ec 0c             	sub    $0xc,%esp
801044d3:	56                   	push   %esi
801044d4:	e8 63 d2 ff ff       	call   8010173c <iunlockput>
    ilock(ip);
801044d9:	89 1c 24             	mov    %ebx,(%esp)
801044dc:	e8 b4 d0 ff ff       	call   80101595 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801044e1:	83 c4 10             	add    $0x10,%esp
801044e4:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801044e9:	75 11                	jne    801044fc <create+0x78>
801044eb:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801044f0:	75 0a                	jne    801044fc <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801044f2:	89 d8                	mov    %ebx,%eax
801044f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044f7:	5b                   	pop    %ebx
801044f8:	5e                   	pop    %esi
801044f9:	5f                   	pop    %edi
801044fa:	5d                   	pop    %ebp
801044fb:	c3                   	ret    
    iunlockput(ip);
801044fc:	83 ec 0c             	sub    $0xc,%esp
801044ff:	53                   	push   %ebx
80104500:	e8 37 d2 ff ff       	call   8010173c <iunlockput>
    return 0;
80104505:	83 c4 10             	add    $0x10,%esp
80104508:	bb 00 00 00 00       	mov    $0x0,%ebx
8010450d:	eb e3                	jmp    801044f2 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
8010450f:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104513:	83 ec 08             	sub    $0x8,%esp
80104516:	50                   	push   %eax
80104517:	ff 36                	pushl  (%esi)
80104519:	e8 74 ce ff ff       	call   80101392 <ialloc>
8010451e:	89 c3                	mov    %eax,%ebx
80104520:	83 c4 10             	add    $0x10,%esp
80104523:	85 c0                	test   %eax,%eax
80104525:	74 55                	je     8010457c <create+0xf8>
  ilock(ip);
80104527:	83 ec 0c             	sub    $0xc,%esp
8010452a:	50                   	push   %eax
8010452b:	e8 65 d0 ff ff       	call   80101595 <ilock>
  ip->major = major;
80104530:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104534:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104538:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010453c:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104542:	89 1c 24             	mov    %ebx,(%esp)
80104545:	e8 ea ce ff ff       	call   80101434 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010454a:	83 c4 10             	add    $0x10,%esp
8010454d:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104552:	74 35                	je     80104589 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104554:	83 ec 04             	sub    $0x4,%esp
80104557:	ff 73 04             	pushl  0x4(%ebx)
8010455a:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010455d:	50                   	push   %eax
8010455e:	56                   	push   %esi
8010455f:	e8 e0 d5 ff ff       	call   80101b44 <dirlink>
80104564:	83 c4 10             	add    $0x10,%esp
80104567:	85 c0                	test   %eax,%eax
80104569:	78 6f                	js     801045da <create+0x156>
  iunlockput(dp);
8010456b:	83 ec 0c             	sub    $0xc,%esp
8010456e:	56                   	push   %esi
8010456f:	e8 c8 d1 ff ff       	call   8010173c <iunlockput>
  return ip;
80104574:	83 c4 10             	add    $0x10,%esp
80104577:	e9 76 ff ff ff       	jmp    801044f2 <create+0x6e>
    panic("create: ialloc");
8010457c:	83 ec 0c             	sub    $0xc,%esp
8010457f:	68 4e 70 10 80       	push   $0x8010704e
80104584:	e8 bf bd ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104589:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010458d:	83 c0 01             	add    $0x1,%eax
80104590:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104594:	83 ec 0c             	sub    $0xc,%esp
80104597:	56                   	push   %esi
80104598:	e8 97 ce ff ff       	call   80101434 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010459d:	83 c4 0c             	add    $0xc,%esp
801045a0:	ff 73 04             	pushl  0x4(%ebx)
801045a3:	68 5e 70 10 80       	push   $0x8010705e
801045a8:	53                   	push   %ebx
801045a9:	e8 96 d5 ff ff       	call   80101b44 <dirlink>
801045ae:	83 c4 10             	add    $0x10,%esp
801045b1:	85 c0                	test   %eax,%eax
801045b3:	78 18                	js     801045cd <create+0x149>
801045b5:	83 ec 04             	sub    $0x4,%esp
801045b8:	ff 76 04             	pushl  0x4(%esi)
801045bb:	68 5d 70 10 80       	push   $0x8010705d
801045c0:	53                   	push   %ebx
801045c1:	e8 7e d5 ff ff       	call   80101b44 <dirlink>
801045c6:	83 c4 10             	add    $0x10,%esp
801045c9:	85 c0                	test   %eax,%eax
801045cb:	79 87                	jns    80104554 <create+0xd0>
      panic("create dots");
801045cd:	83 ec 0c             	sub    $0xc,%esp
801045d0:	68 60 70 10 80       	push   $0x80107060
801045d5:	e8 6e bd ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801045da:	83 ec 0c             	sub    $0xc,%esp
801045dd:	68 6c 70 10 80       	push   $0x8010706c
801045e2:	e8 61 bd ff ff       	call   80100348 <panic>
    return 0;
801045e7:	89 c3                	mov    %eax,%ebx
801045e9:	e9 04 ff ff ff       	jmp    801044f2 <create+0x6e>

801045ee <sys_dup>:
{
801045ee:	55                   	push   %ebp
801045ef:	89 e5                	mov    %esp,%ebp
801045f1:	53                   	push   %ebx
801045f2:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801045f5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801045f8:	ba 00 00 00 00       	mov    $0x0,%edx
801045fd:	b8 00 00 00 00       	mov    $0x0,%eax
80104602:	e8 88 fd ff ff       	call   8010438f <argfd>
80104607:	85 c0                	test   %eax,%eax
80104609:	78 23                	js     8010462e <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
8010460b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460e:	e8 e3 fd ff ff       	call   801043f6 <fdalloc>
80104613:	89 c3                	mov    %eax,%ebx
80104615:	85 c0                	test   %eax,%eax
80104617:	78 1c                	js     80104635 <sys_dup+0x47>
  filedup(f);
80104619:	83 ec 0c             	sub    $0xc,%esp
8010461c:	ff 75 f4             	pushl  -0xc(%ebp)
8010461f:	e8 7e c6 ff ff       	call   80100ca2 <filedup>
  return fd;
80104624:	83 c4 10             	add    $0x10,%esp
}
80104627:	89 d8                	mov    %ebx,%eax
80104629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010462c:	c9                   	leave  
8010462d:	c3                   	ret    
    return -1;
8010462e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104633:	eb f2                	jmp    80104627 <sys_dup+0x39>
    return -1;
80104635:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010463a:	eb eb                	jmp    80104627 <sys_dup+0x39>

8010463c <sys_read>:
{
8010463c:	55                   	push   %ebp
8010463d:	89 e5                	mov    %esp,%ebp
8010463f:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104642:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104645:	ba 00 00 00 00       	mov    $0x0,%edx
8010464a:	b8 00 00 00 00       	mov    $0x0,%eax
8010464f:	e8 3b fd ff ff       	call   8010438f <argfd>
80104654:	85 c0                	test   %eax,%eax
80104656:	78 43                	js     8010469b <sys_read+0x5f>
80104658:	83 ec 08             	sub    $0x8,%esp
8010465b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010465e:	50                   	push   %eax
8010465f:	6a 02                	push   $0x2
80104661:	e8 11 fc ff ff       	call   80104277 <argint>
80104666:	83 c4 10             	add    $0x10,%esp
80104669:	85 c0                	test   %eax,%eax
8010466b:	78 35                	js     801046a2 <sys_read+0x66>
8010466d:	83 ec 04             	sub    $0x4,%esp
80104670:	ff 75 f0             	pushl  -0x10(%ebp)
80104673:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104676:	50                   	push   %eax
80104677:	6a 01                	push   $0x1
80104679:	e8 21 fc ff ff       	call   8010429f <argptr>
8010467e:	83 c4 10             	add    $0x10,%esp
80104681:	85 c0                	test   %eax,%eax
80104683:	78 24                	js     801046a9 <sys_read+0x6d>
  return fileread(f, p, n);
80104685:	83 ec 04             	sub    $0x4,%esp
80104688:	ff 75 f0             	pushl  -0x10(%ebp)
8010468b:	ff 75 ec             	pushl  -0x14(%ebp)
8010468e:	ff 75 f4             	pushl  -0xc(%ebp)
80104691:	e8 55 c7 ff ff       	call   80100deb <fileread>
80104696:	83 c4 10             	add    $0x10,%esp
}
80104699:	c9                   	leave  
8010469a:	c3                   	ret    
    return -1;
8010469b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a0:	eb f7                	jmp    80104699 <sys_read+0x5d>
801046a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a7:	eb f0                	jmp    80104699 <sys_read+0x5d>
801046a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ae:	eb e9                	jmp    80104699 <sys_read+0x5d>

801046b0 <sys_write>:
{
801046b0:	55                   	push   %ebp
801046b1:	89 e5                	mov    %esp,%ebp
801046b3:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801046b6:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801046b9:	ba 00 00 00 00       	mov    $0x0,%edx
801046be:	b8 00 00 00 00       	mov    $0x0,%eax
801046c3:	e8 c7 fc ff ff       	call   8010438f <argfd>
801046c8:	85 c0                	test   %eax,%eax
801046ca:	78 43                	js     8010470f <sys_write+0x5f>
801046cc:	83 ec 08             	sub    $0x8,%esp
801046cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801046d2:	50                   	push   %eax
801046d3:	6a 02                	push   $0x2
801046d5:	e8 9d fb ff ff       	call   80104277 <argint>
801046da:	83 c4 10             	add    $0x10,%esp
801046dd:	85 c0                	test   %eax,%eax
801046df:	78 35                	js     80104716 <sys_write+0x66>
801046e1:	83 ec 04             	sub    $0x4,%esp
801046e4:	ff 75 f0             	pushl  -0x10(%ebp)
801046e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801046ea:	50                   	push   %eax
801046eb:	6a 01                	push   $0x1
801046ed:	e8 ad fb ff ff       	call   8010429f <argptr>
801046f2:	83 c4 10             	add    $0x10,%esp
801046f5:	85 c0                	test   %eax,%eax
801046f7:	78 24                	js     8010471d <sys_write+0x6d>
  return filewrite(f, p, n);
801046f9:	83 ec 04             	sub    $0x4,%esp
801046fc:	ff 75 f0             	pushl  -0x10(%ebp)
801046ff:	ff 75 ec             	pushl  -0x14(%ebp)
80104702:	ff 75 f4             	pushl  -0xc(%ebp)
80104705:	e8 66 c7 ff ff       	call   80100e70 <filewrite>
8010470a:	83 c4 10             	add    $0x10,%esp
}
8010470d:	c9                   	leave  
8010470e:	c3                   	ret    
    return -1;
8010470f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104714:	eb f7                	jmp    8010470d <sys_write+0x5d>
80104716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471b:	eb f0                	jmp    8010470d <sys_write+0x5d>
8010471d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104722:	eb e9                	jmp    8010470d <sys_write+0x5d>

80104724 <sys_close>:
{
80104724:	55                   	push   %ebp
80104725:	89 e5                	mov    %esp,%ebp
80104727:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
8010472a:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010472d:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104730:	b8 00 00 00 00       	mov    $0x0,%eax
80104735:	e8 55 fc ff ff       	call   8010438f <argfd>
8010473a:	85 c0                	test   %eax,%eax
8010473c:	78 25                	js     80104763 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010473e:	e8 23 ee ff ff       	call   80103566 <myproc>
80104743:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104746:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010474d:	00 
  fileclose(f);
8010474e:	83 ec 0c             	sub    $0xc,%esp
80104751:	ff 75 f0             	pushl  -0x10(%ebp)
80104754:	e8 8e c5 ff ff       	call   80100ce7 <fileclose>
  return 0;
80104759:	83 c4 10             	add    $0x10,%esp
8010475c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104761:	c9                   	leave  
80104762:	c3                   	ret    
    return -1;
80104763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104768:	eb f7                	jmp    80104761 <sys_close+0x3d>

8010476a <sys_fstat>:
{
8010476a:	55                   	push   %ebp
8010476b:	89 e5                	mov    %esp,%ebp
8010476d:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104770:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104773:	ba 00 00 00 00       	mov    $0x0,%edx
80104778:	b8 00 00 00 00       	mov    $0x0,%eax
8010477d:	e8 0d fc ff ff       	call   8010438f <argfd>
80104782:	85 c0                	test   %eax,%eax
80104784:	78 2a                	js     801047b0 <sys_fstat+0x46>
80104786:	83 ec 04             	sub    $0x4,%esp
80104789:	6a 14                	push   $0x14
8010478b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010478e:	50                   	push   %eax
8010478f:	6a 01                	push   $0x1
80104791:	e8 09 fb ff ff       	call   8010429f <argptr>
80104796:	83 c4 10             	add    $0x10,%esp
80104799:	85 c0                	test   %eax,%eax
8010479b:	78 1a                	js     801047b7 <sys_fstat+0x4d>
  return filestat(f, st);
8010479d:	83 ec 08             	sub    $0x8,%esp
801047a0:	ff 75 f0             	pushl  -0x10(%ebp)
801047a3:	ff 75 f4             	pushl  -0xc(%ebp)
801047a6:	e8 f9 c5 ff ff       	call   80100da4 <filestat>
801047ab:	83 c4 10             	add    $0x10,%esp
}
801047ae:	c9                   	leave  
801047af:	c3                   	ret    
    return -1;
801047b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b5:	eb f7                	jmp    801047ae <sys_fstat+0x44>
801047b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047bc:	eb f0                	jmp    801047ae <sys_fstat+0x44>

801047be <sys_link>:
{
801047be:	55                   	push   %ebp
801047bf:	89 e5                	mov    %esp,%ebp
801047c1:	56                   	push   %esi
801047c2:	53                   	push   %ebx
801047c3:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801047c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047c9:	50                   	push   %eax
801047ca:	6a 00                	push   $0x0
801047cc:	e8 36 fb ff ff       	call   80104307 <argstr>
801047d1:	83 c4 10             	add    $0x10,%esp
801047d4:	85 c0                	test   %eax,%eax
801047d6:	0f 88 32 01 00 00    	js     8010490e <sys_link+0x150>
801047dc:	83 ec 08             	sub    $0x8,%esp
801047df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047e2:	50                   	push   %eax
801047e3:	6a 01                	push   $0x1
801047e5:	e8 1d fb ff ff       	call   80104307 <argstr>
801047ea:	83 c4 10             	add    $0x10,%esp
801047ed:	85 c0                	test   %eax,%eax
801047ef:	0f 88 20 01 00 00    	js     80104915 <sys_link+0x157>
  begin_op();
801047f5:	e8 f4 e2 ff ff       	call   80102aee <begin_op>
  if((ip = namei(old)) == 0){
801047fa:	83 ec 0c             	sub    $0xc,%esp
801047fd:	ff 75 e0             	pushl  -0x20(%ebp)
80104800:	e8 f0 d3 ff ff       	call   80101bf5 <namei>
80104805:	89 c3                	mov    %eax,%ebx
80104807:	83 c4 10             	add    $0x10,%esp
8010480a:	85 c0                	test   %eax,%eax
8010480c:	0f 84 99 00 00 00    	je     801048ab <sys_link+0xed>
  ilock(ip);
80104812:	83 ec 0c             	sub    $0xc,%esp
80104815:	50                   	push   %eax
80104816:	e8 7a cd ff ff       	call   80101595 <ilock>
  if(ip->type == T_DIR){
8010481b:	83 c4 10             	add    $0x10,%esp
8010481e:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104823:	0f 84 8e 00 00 00    	je     801048b7 <sys_link+0xf9>
  ip->nlink++;
80104829:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010482d:	83 c0 01             	add    $0x1,%eax
80104830:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104834:	83 ec 0c             	sub    $0xc,%esp
80104837:	53                   	push   %ebx
80104838:	e8 f7 cb ff ff       	call   80101434 <iupdate>
  iunlock(ip);
8010483d:	89 1c 24             	mov    %ebx,(%esp)
80104840:	e8 12 ce ff ff       	call   80101657 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104845:	83 c4 08             	add    $0x8,%esp
80104848:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010484b:	50                   	push   %eax
8010484c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010484f:	e8 b9 d3 ff ff       	call   80101c0d <nameiparent>
80104854:	89 c6                	mov    %eax,%esi
80104856:	83 c4 10             	add    $0x10,%esp
80104859:	85 c0                	test   %eax,%eax
8010485b:	74 7e                	je     801048db <sys_link+0x11d>
  ilock(dp);
8010485d:	83 ec 0c             	sub    $0xc,%esp
80104860:	50                   	push   %eax
80104861:	e8 2f cd ff ff       	call   80101595 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104866:	83 c4 10             	add    $0x10,%esp
80104869:	8b 03                	mov    (%ebx),%eax
8010486b:	39 06                	cmp    %eax,(%esi)
8010486d:	75 60                	jne    801048cf <sys_link+0x111>
8010486f:	83 ec 04             	sub    $0x4,%esp
80104872:	ff 73 04             	pushl  0x4(%ebx)
80104875:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104878:	50                   	push   %eax
80104879:	56                   	push   %esi
8010487a:	e8 c5 d2 ff ff       	call   80101b44 <dirlink>
8010487f:	83 c4 10             	add    $0x10,%esp
80104882:	85 c0                	test   %eax,%eax
80104884:	78 49                	js     801048cf <sys_link+0x111>
  iunlockput(dp);
80104886:	83 ec 0c             	sub    $0xc,%esp
80104889:	56                   	push   %esi
8010488a:	e8 ad ce ff ff       	call   8010173c <iunlockput>
  iput(ip);
8010488f:	89 1c 24             	mov    %ebx,(%esp)
80104892:	e8 05 ce ff ff       	call   8010169c <iput>
  end_op();
80104897:	e8 cc e2 ff ff       	call   80102b68 <end_op>
  return 0;
8010489c:	83 c4 10             	add    $0x10,%esp
8010489f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801048a7:	5b                   	pop    %ebx
801048a8:	5e                   	pop    %esi
801048a9:	5d                   	pop    %ebp
801048aa:	c3                   	ret    
    end_op();
801048ab:	e8 b8 e2 ff ff       	call   80102b68 <end_op>
    return -1;
801048b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b5:	eb ed                	jmp    801048a4 <sys_link+0xe6>
    iunlockput(ip);
801048b7:	83 ec 0c             	sub    $0xc,%esp
801048ba:	53                   	push   %ebx
801048bb:	e8 7c ce ff ff       	call   8010173c <iunlockput>
    end_op();
801048c0:	e8 a3 e2 ff ff       	call   80102b68 <end_op>
    return -1;
801048c5:	83 c4 10             	add    $0x10,%esp
801048c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048cd:	eb d5                	jmp    801048a4 <sys_link+0xe6>
    iunlockput(dp);
801048cf:	83 ec 0c             	sub    $0xc,%esp
801048d2:	56                   	push   %esi
801048d3:	e8 64 ce ff ff       	call   8010173c <iunlockput>
    goto bad;
801048d8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801048db:	83 ec 0c             	sub    $0xc,%esp
801048de:	53                   	push   %ebx
801048df:	e8 b1 cc ff ff       	call   80101595 <ilock>
  ip->nlink--;
801048e4:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801048e8:	83 e8 01             	sub    $0x1,%eax
801048eb:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801048ef:	89 1c 24             	mov    %ebx,(%esp)
801048f2:	e8 3d cb ff ff       	call   80101434 <iupdate>
  iunlockput(ip);
801048f7:	89 1c 24             	mov    %ebx,(%esp)
801048fa:	e8 3d ce ff ff       	call   8010173c <iunlockput>
  end_op();
801048ff:	e8 64 e2 ff ff       	call   80102b68 <end_op>
  return -1;
80104904:	83 c4 10             	add    $0x10,%esp
80104907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010490c:	eb 96                	jmp    801048a4 <sys_link+0xe6>
    return -1;
8010490e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104913:	eb 8f                	jmp    801048a4 <sys_link+0xe6>
80104915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010491a:	eb 88                	jmp    801048a4 <sys_link+0xe6>

8010491c <sys_unlink>:
{
8010491c:	55                   	push   %ebp
8010491d:	89 e5                	mov    %esp,%ebp
8010491f:	57                   	push   %edi
80104920:	56                   	push   %esi
80104921:	53                   	push   %ebx
80104922:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104925:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104928:	50                   	push   %eax
80104929:	6a 00                	push   $0x0
8010492b:	e8 d7 f9 ff ff       	call   80104307 <argstr>
80104930:	83 c4 10             	add    $0x10,%esp
80104933:	85 c0                	test   %eax,%eax
80104935:	0f 88 83 01 00 00    	js     80104abe <sys_unlink+0x1a2>
  begin_op();
8010493b:	e8 ae e1 ff ff       	call   80102aee <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104940:	83 ec 08             	sub    $0x8,%esp
80104943:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104946:	50                   	push   %eax
80104947:	ff 75 c4             	pushl  -0x3c(%ebp)
8010494a:	e8 be d2 ff ff       	call   80101c0d <nameiparent>
8010494f:	89 c6                	mov    %eax,%esi
80104951:	83 c4 10             	add    $0x10,%esp
80104954:	85 c0                	test   %eax,%eax
80104956:	0f 84 ed 00 00 00    	je     80104a49 <sys_unlink+0x12d>
  ilock(dp);
8010495c:	83 ec 0c             	sub    $0xc,%esp
8010495f:	50                   	push   %eax
80104960:	e8 30 cc ff ff       	call   80101595 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104965:	83 c4 08             	add    $0x8,%esp
80104968:	68 5e 70 10 80       	push   $0x8010705e
8010496d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104970:	50                   	push   %eax
80104971:	e8 39 d0 ff ff       	call   801019af <namecmp>
80104976:	83 c4 10             	add    $0x10,%esp
80104979:	85 c0                	test   %eax,%eax
8010497b:	0f 84 fc 00 00 00    	je     80104a7d <sys_unlink+0x161>
80104981:	83 ec 08             	sub    $0x8,%esp
80104984:	68 5d 70 10 80       	push   $0x8010705d
80104989:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010498c:	50                   	push   %eax
8010498d:	e8 1d d0 ff ff       	call   801019af <namecmp>
80104992:	83 c4 10             	add    $0x10,%esp
80104995:	85 c0                	test   %eax,%eax
80104997:	0f 84 e0 00 00 00    	je     80104a7d <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010499d:	83 ec 04             	sub    $0x4,%esp
801049a0:	8d 45 c0             	lea    -0x40(%ebp),%eax
801049a3:	50                   	push   %eax
801049a4:	8d 45 ca             	lea    -0x36(%ebp),%eax
801049a7:	50                   	push   %eax
801049a8:	56                   	push   %esi
801049a9:	e8 16 d0 ff ff       	call   801019c4 <dirlookup>
801049ae:	89 c3                	mov    %eax,%ebx
801049b0:	83 c4 10             	add    $0x10,%esp
801049b3:	85 c0                	test   %eax,%eax
801049b5:	0f 84 c2 00 00 00    	je     80104a7d <sys_unlink+0x161>
  ilock(ip);
801049bb:	83 ec 0c             	sub    $0xc,%esp
801049be:	50                   	push   %eax
801049bf:	e8 d1 cb ff ff       	call   80101595 <ilock>
  if(ip->nlink < 1)
801049c4:	83 c4 10             	add    $0x10,%esp
801049c7:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801049cc:	0f 8e 83 00 00 00    	jle    80104a55 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801049d2:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801049d7:	0f 84 85 00 00 00    	je     80104a62 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801049dd:	83 ec 04             	sub    $0x4,%esp
801049e0:	6a 10                	push   $0x10
801049e2:	6a 00                	push   $0x0
801049e4:	8d 7d d8             	lea    -0x28(%ebp),%edi
801049e7:	57                   	push   %edi
801049e8:	e8 3f f6 ff ff       	call   8010402c <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801049ed:	6a 10                	push   $0x10
801049ef:	ff 75 c0             	pushl  -0x40(%ebp)
801049f2:	57                   	push   %edi
801049f3:	56                   	push   %esi
801049f4:	e8 8b ce ff ff       	call   80101884 <writei>
801049f9:	83 c4 20             	add    $0x20,%esp
801049fc:	83 f8 10             	cmp    $0x10,%eax
801049ff:	0f 85 90 00 00 00    	jne    80104a95 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104a05:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a0a:	0f 84 92 00 00 00    	je     80104aa2 <sys_unlink+0x186>
  iunlockput(dp);
80104a10:	83 ec 0c             	sub    $0xc,%esp
80104a13:	56                   	push   %esi
80104a14:	e8 23 cd ff ff       	call   8010173c <iunlockput>
  ip->nlink--;
80104a19:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104a1d:	83 e8 01             	sub    $0x1,%eax
80104a20:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104a24:	89 1c 24             	mov    %ebx,(%esp)
80104a27:	e8 08 ca ff ff       	call   80101434 <iupdate>
  iunlockput(ip);
80104a2c:	89 1c 24             	mov    %ebx,(%esp)
80104a2f:	e8 08 cd ff ff       	call   8010173c <iunlockput>
  end_op();
80104a34:	e8 2f e1 ff ff       	call   80102b68 <end_op>
  return 0;
80104a39:	83 c4 10             	add    $0x10,%esp
80104a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a41:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a44:	5b                   	pop    %ebx
80104a45:	5e                   	pop    %esi
80104a46:	5f                   	pop    %edi
80104a47:	5d                   	pop    %ebp
80104a48:	c3                   	ret    
    end_op();
80104a49:	e8 1a e1 ff ff       	call   80102b68 <end_op>
    return -1;
80104a4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a53:	eb ec                	jmp    80104a41 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104a55:	83 ec 0c             	sub    $0xc,%esp
80104a58:	68 7c 70 10 80       	push   $0x8010707c
80104a5d:	e8 e6 b8 ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104a62:	89 d8                	mov    %ebx,%eax
80104a64:	e8 c4 f9 ff ff       	call   8010442d <isdirempty>
80104a69:	85 c0                	test   %eax,%eax
80104a6b:	0f 85 6c ff ff ff    	jne    801049dd <sys_unlink+0xc1>
    iunlockput(ip);
80104a71:	83 ec 0c             	sub    $0xc,%esp
80104a74:	53                   	push   %ebx
80104a75:	e8 c2 cc ff ff       	call   8010173c <iunlockput>
    goto bad;
80104a7a:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104a7d:	83 ec 0c             	sub    $0xc,%esp
80104a80:	56                   	push   %esi
80104a81:	e8 b6 cc ff ff       	call   8010173c <iunlockput>
  end_op();
80104a86:	e8 dd e0 ff ff       	call   80102b68 <end_op>
  return -1;
80104a8b:	83 c4 10             	add    $0x10,%esp
80104a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a93:	eb ac                	jmp    80104a41 <sys_unlink+0x125>
    panic("unlink: writei");
80104a95:	83 ec 0c             	sub    $0xc,%esp
80104a98:	68 8e 70 10 80       	push   $0x8010708e
80104a9d:	e8 a6 b8 ff ff       	call   80100348 <panic>
    dp->nlink--;
80104aa2:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104aa6:	83 e8 01             	sub    $0x1,%eax
80104aa9:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104aad:	83 ec 0c             	sub    $0xc,%esp
80104ab0:	56                   	push   %esi
80104ab1:	e8 7e c9 ff ff       	call   80101434 <iupdate>
80104ab6:	83 c4 10             	add    $0x10,%esp
80104ab9:	e9 52 ff ff ff       	jmp    80104a10 <sys_unlink+0xf4>
    return -1;
80104abe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ac3:	e9 79 ff ff ff       	jmp    80104a41 <sys_unlink+0x125>

80104ac8 <sys_open>:

int
sys_open(void)
{
80104ac8:	55                   	push   %ebp
80104ac9:	89 e5                	mov    %esp,%ebp
80104acb:	57                   	push   %edi
80104acc:	56                   	push   %esi
80104acd:	53                   	push   %ebx
80104ace:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104ad1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104ad4:	50                   	push   %eax
80104ad5:	6a 00                	push   $0x0
80104ad7:	e8 2b f8 ff ff       	call   80104307 <argstr>
80104adc:	83 c4 10             	add    $0x10,%esp
80104adf:	85 c0                	test   %eax,%eax
80104ae1:	0f 88 30 01 00 00    	js     80104c17 <sys_open+0x14f>
80104ae7:	83 ec 08             	sub    $0x8,%esp
80104aea:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104aed:	50                   	push   %eax
80104aee:	6a 01                	push   $0x1
80104af0:	e8 82 f7 ff ff       	call   80104277 <argint>
80104af5:	83 c4 10             	add    $0x10,%esp
80104af8:	85 c0                	test   %eax,%eax
80104afa:	0f 88 21 01 00 00    	js     80104c21 <sys_open+0x159>
    return -1;

  begin_op();
80104b00:	e8 e9 df ff ff       	call   80102aee <begin_op>

  if(omode & O_CREATE){
80104b05:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104b09:	0f 84 84 00 00 00    	je     80104b93 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104b0f:	83 ec 0c             	sub    $0xc,%esp
80104b12:	6a 00                	push   $0x0
80104b14:	b9 00 00 00 00       	mov    $0x0,%ecx
80104b19:	ba 02 00 00 00       	mov    $0x2,%edx
80104b1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b21:	e8 5e f9 ff ff       	call   80104484 <create>
80104b26:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104b28:	83 c4 10             	add    $0x10,%esp
80104b2b:	85 c0                	test   %eax,%eax
80104b2d:	74 58                	je     80104b87 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104b2f:	e8 0d c1 ff ff       	call   80100c41 <filealloc>
80104b34:	89 c3                	mov    %eax,%ebx
80104b36:	85 c0                	test   %eax,%eax
80104b38:	0f 84 ae 00 00 00    	je     80104bec <sys_open+0x124>
80104b3e:	e8 b3 f8 ff ff       	call   801043f6 <fdalloc>
80104b43:	89 c7                	mov    %eax,%edi
80104b45:	85 c0                	test   %eax,%eax
80104b47:	0f 88 9f 00 00 00    	js     80104bec <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b4d:	83 ec 0c             	sub    $0xc,%esp
80104b50:	56                   	push   %esi
80104b51:	e8 01 cb ff ff       	call   80101657 <iunlock>
  end_op();
80104b56:	e8 0d e0 ff ff       	call   80102b68 <end_op>

  f->type = FD_INODE;
80104b5b:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104b61:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104b64:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104b6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b6e:	83 c4 10             	add    $0x10,%esp
80104b71:	a8 01                	test   $0x1,%al
80104b73:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104b77:	a8 03                	test   $0x3,%al
80104b79:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104b7d:	89 f8                	mov    %edi,%eax
80104b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b82:	5b                   	pop    %ebx
80104b83:	5e                   	pop    %esi
80104b84:	5f                   	pop    %edi
80104b85:	5d                   	pop    %ebp
80104b86:	c3                   	ret    
      end_op();
80104b87:	e8 dc df ff ff       	call   80102b68 <end_op>
      return -1;
80104b8c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104b91:	eb ea                	jmp    80104b7d <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104b93:	83 ec 0c             	sub    $0xc,%esp
80104b96:	ff 75 e4             	pushl  -0x1c(%ebp)
80104b99:	e8 57 d0 ff ff       	call   80101bf5 <namei>
80104b9e:	89 c6                	mov    %eax,%esi
80104ba0:	83 c4 10             	add    $0x10,%esp
80104ba3:	85 c0                	test   %eax,%eax
80104ba5:	74 39                	je     80104be0 <sys_open+0x118>
    ilock(ip);
80104ba7:	83 ec 0c             	sub    $0xc,%esp
80104baa:	50                   	push   %eax
80104bab:	e8 e5 c9 ff ff       	call   80101595 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104bb0:	83 c4 10             	add    $0x10,%esp
80104bb3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104bb8:	0f 85 71 ff ff ff    	jne    80104b2f <sys_open+0x67>
80104bbe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104bc2:	0f 84 67 ff ff ff    	je     80104b2f <sys_open+0x67>
      iunlockput(ip);
80104bc8:	83 ec 0c             	sub    $0xc,%esp
80104bcb:	56                   	push   %esi
80104bcc:	e8 6b cb ff ff       	call   8010173c <iunlockput>
      end_op();
80104bd1:	e8 92 df ff ff       	call   80102b68 <end_op>
      return -1;
80104bd6:	83 c4 10             	add    $0x10,%esp
80104bd9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104bde:	eb 9d                	jmp    80104b7d <sys_open+0xb5>
      end_op();
80104be0:	e8 83 df ff ff       	call   80102b68 <end_op>
      return -1;
80104be5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104bea:	eb 91                	jmp    80104b7d <sys_open+0xb5>
    if(f)
80104bec:	85 db                	test   %ebx,%ebx
80104bee:	74 0c                	je     80104bfc <sys_open+0x134>
      fileclose(f);
80104bf0:	83 ec 0c             	sub    $0xc,%esp
80104bf3:	53                   	push   %ebx
80104bf4:	e8 ee c0 ff ff       	call   80100ce7 <fileclose>
80104bf9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104bfc:	83 ec 0c             	sub    $0xc,%esp
80104bff:	56                   	push   %esi
80104c00:	e8 37 cb ff ff       	call   8010173c <iunlockput>
    end_op();
80104c05:	e8 5e df ff ff       	call   80102b68 <end_op>
    return -1;
80104c0a:	83 c4 10             	add    $0x10,%esp
80104c0d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104c12:	e9 66 ff ff ff       	jmp    80104b7d <sys_open+0xb5>
    return -1;
80104c17:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104c1c:	e9 5c ff ff ff       	jmp    80104b7d <sys_open+0xb5>
80104c21:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104c26:	e9 52 ff ff ff       	jmp    80104b7d <sys_open+0xb5>

80104c2b <sys_mkdir>:

int
sys_mkdir(void)
{
80104c2b:	55                   	push   %ebp
80104c2c:	89 e5                	mov    %esp,%ebp
80104c2e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104c31:	e8 b8 de ff ff       	call   80102aee <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104c36:	83 ec 08             	sub    $0x8,%esp
80104c39:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c3c:	50                   	push   %eax
80104c3d:	6a 00                	push   $0x0
80104c3f:	e8 c3 f6 ff ff       	call   80104307 <argstr>
80104c44:	83 c4 10             	add    $0x10,%esp
80104c47:	85 c0                	test   %eax,%eax
80104c49:	78 36                	js     80104c81 <sys_mkdir+0x56>
80104c4b:	83 ec 0c             	sub    $0xc,%esp
80104c4e:	6a 00                	push   $0x0
80104c50:	b9 00 00 00 00       	mov    $0x0,%ecx
80104c55:	ba 01 00 00 00       	mov    $0x1,%edx
80104c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5d:	e8 22 f8 ff ff       	call   80104484 <create>
80104c62:	83 c4 10             	add    $0x10,%esp
80104c65:	85 c0                	test   %eax,%eax
80104c67:	74 18                	je     80104c81 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104c69:	83 ec 0c             	sub    $0xc,%esp
80104c6c:	50                   	push   %eax
80104c6d:	e8 ca ca ff ff       	call   8010173c <iunlockput>
  end_op();
80104c72:	e8 f1 de ff ff       	call   80102b68 <end_op>
  return 0;
80104c77:	83 c4 10             	add    $0x10,%esp
80104c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c7f:	c9                   	leave  
80104c80:	c3                   	ret    
    end_op();
80104c81:	e8 e2 de ff ff       	call   80102b68 <end_op>
    return -1;
80104c86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c8b:	eb f2                	jmp    80104c7f <sys_mkdir+0x54>

80104c8d <sys_mknod>:

int
sys_mknod(void)
{
80104c8d:	55                   	push   %ebp
80104c8e:	89 e5                	mov    %esp,%ebp
80104c90:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104c93:	e8 56 de ff ff       	call   80102aee <begin_op>
  if((argstr(0, &path)) < 0 ||
80104c98:	83 ec 08             	sub    $0x8,%esp
80104c9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c9e:	50                   	push   %eax
80104c9f:	6a 00                	push   $0x0
80104ca1:	e8 61 f6 ff ff       	call   80104307 <argstr>
80104ca6:	83 c4 10             	add    $0x10,%esp
80104ca9:	85 c0                	test   %eax,%eax
80104cab:	78 62                	js     80104d0f <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104cad:	83 ec 08             	sub    $0x8,%esp
80104cb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cb3:	50                   	push   %eax
80104cb4:	6a 01                	push   $0x1
80104cb6:	e8 bc f5 ff ff       	call   80104277 <argint>
  if((argstr(0, &path)) < 0 ||
80104cbb:	83 c4 10             	add    $0x10,%esp
80104cbe:	85 c0                	test   %eax,%eax
80104cc0:	78 4d                	js     80104d0f <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104cc2:	83 ec 08             	sub    $0x8,%esp
80104cc5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104cc8:	50                   	push   %eax
80104cc9:	6a 02                	push   $0x2
80104ccb:	e8 a7 f5 ff ff       	call   80104277 <argint>
     argint(1, &major) < 0 ||
80104cd0:	83 c4 10             	add    $0x10,%esp
80104cd3:	85 c0                	test   %eax,%eax
80104cd5:	78 38                	js     80104d0f <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104cd7:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104cdb:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104cdf:	83 ec 0c             	sub    $0xc,%esp
80104ce2:	50                   	push   %eax
80104ce3:	ba 03 00 00 00       	mov    $0x3,%edx
80104ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ceb:	e8 94 f7 ff ff       	call   80104484 <create>
80104cf0:	83 c4 10             	add    $0x10,%esp
80104cf3:	85 c0                	test   %eax,%eax
80104cf5:	74 18                	je     80104d0f <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104cf7:	83 ec 0c             	sub    $0xc,%esp
80104cfa:	50                   	push   %eax
80104cfb:	e8 3c ca ff ff       	call   8010173c <iunlockput>
  end_op();
80104d00:	e8 63 de ff ff       	call   80102b68 <end_op>
  return 0;
80104d05:	83 c4 10             	add    $0x10,%esp
80104d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d0d:	c9                   	leave  
80104d0e:	c3                   	ret    
    end_op();
80104d0f:	e8 54 de ff ff       	call   80102b68 <end_op>
    return -1;
80104d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d19:	eb f2                	jmp    80104d0d <sys_mknod+0x80>

80104d1b <sys_chdir>:

int
sys_chdir(void)
{
80104d1b:	55                   	push   %ebp
80104d1c:	89 e5                	mov    %esp,%ebp
80104d1e:	56                   	push   %esi
80104d1f:	53                   	push   %ebx
80104d20:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104d23:	e8 3e e8 ff ff       	call   80103566 <myproc>
80104d28:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104d2a:	e8 bf dd ff ff       	call   80102aee <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104d2f:	83 ec 08             	sub    $0x8,%esp
80104d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d35:	50                   	push   %eax
80104d36:	6a 00                	push   $0x0
80104d38:	e8 ca f5 ff ff       	call   80104307 <argstr>
80104d3d:	83 c4 10             	add    $0x10,%esp
80104d40:	85 c0                	test   %eax,%eax
80104d42:	78 52                	js     80104d96 <sys_chdir+0x7b>
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	ff 75 f4             	pushl  -0xc(%ebp)
80104d4a:	e8 a6 ce ff ff       	call   80101bf5 <namei>
80104d4f:	89 c3                	mov    %eax,%ebx
80104d51:	83 c4 10             	add    $0x10,%esp
80104d54:	85 c0                	test   %eax,%eax
80104d56:	74 3e                	je     80104d96 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104d58:	83 ec 0c             	sub    $0xc,%esp
80104d5b:	50                   	push   %eax
80104d5c:	e8 34 c8 ff ff       	call   80101595 <ilock>
  if(ip->type != T_DIR){
80104d61:	83 c4 10             	add    $0x10,%esp
80104d64:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104d69:	75 37                	jne    80104da2 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104d6b:	83 ec 0c             	sub    $0xc,%esp
80104d6e:	53                   	push   %ebx
80104d6f:	e8 e3 c8 ff ff       	call   80101657 <iunlock>
  iput(curproc->cwd);
80104d74:	83 c4 04             	add    $0x4,%esp
80104d77:	ff 76 68             	pushl  0x68(%esi)
80104d7a:	e8 1d c9 ff ff       	call   8010169c <iput>
  end_op();
80104d7f:	e8 e4 dd ff ff       	call   80102b68 <end_op>
  curproc->cwd = ip;
80104d84:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104d87:	83 c4 10             	add    $0x10,%esp
80104d8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104d92:	5b                   	pop    %ebx
80104d93:	5e                   	pop    %esi
80104d94:	5d                   	pop    %ebp
80104d95:	c3                   	ret    
    end_op();
80104d96:	e8 cd dd ff ff       	call   80102b68 <end_op>
    return -1;
80104d9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104da0:	eb ed                	jmp    80104d8f <sys_chdir+0x74>
    iunlockput(ip);
80104da2:	83 ec 0c             	sub    $0xc,%esp
80104da5:	53                   	push   %ebx
80104da6:	e8 91 c9 ff ff       	call   8010173c <iunlockput>
    end_op();
80104dab:	e8 b8 dd ff ff       	call   80102b68 <end_op>
    return -1;
80104db0:	83 c4 10             	add    $0x10,%esp
80104db3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104db8:	eb d5                	jmp    80104d8f <sys_chdir+0x74>

80104dba <sys_exec>:

int
sys_exec(void)
{
80104dba:	55                   	push   %ebp
80104dbb:	89 e5                	mov    %esp,%ebp
80104dbd:	53                   	push   %ebx
80104dbe:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dc7:	50                   	push   %eax
80104dc8:	6a 00                	push   $0x0
80104dca:	e8 38 f5 ff ff       	call   80104307 <argstr>
80104dcf:	83 c4 10             	add    $0x10,%esp
80104dd2:	85 c0                	test   %eax,%eax
80104dd4:	0f 88 a8 00 00 00    	js     80104e82 <sys_exec+0xc8>
80104dda:	83 ec 08             	sub    $0x8,%esp
80104ddd:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104de3:	50                   	push   %eax
80104de4:	6a 01                	push   $0x1
80104de6:	e8 8c f4 ff ff       	call   80104277 <argint>
80104deb:	83 c4 10             	add    $0x10,%esp
80104dee:	85 c0                	test   %eax,%eax
80104df0:	0f 88 93 00 00 00    	js     80104e89 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104df6:	83 ec 04             	sub    $0x4,%esp
80104df9:	68 80 00 00 00       	push   $0x80
80104dfe:	6a 00                	push   $0x0
80104e00:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104e06:	50                   	push   %eax
80104e07:	e8 20 f2 ff ff       	call   8010402c <memset>
80104e0c:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104e14:	83 fb 1f             	cmp    $0x1f,%ebx
80104e17:	77 77                	ja     80104e90 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104e19:	83 ec 08             	sub    $0x8,%esp
80104e1c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104e22:	50                   	push   %eax
80104e23:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104e29:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104e2c:	50                   	push   %eax
80104e2d:	e8 c9 f3 ff ff       	call   801041fb <fetchint>
80104e32:	83 c4 10             	add    $0x10,%esp
80104e35:	85 c0                	test   %eax,%eax
80104e37:	78 5e                	js     80104e97 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104e39:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104e3f:	85 c0                	test   %eax,%eax
80104e41:	74 1d                	je     80104e60 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104e43:	83 ec 08             	sub    $0x8,%esp
80104e46:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104e4d:	52                   	push   %edx
80104e4e:	50                   	push   %eax
80104e4f:	e8 e3 f3 ff ff       	call   80104237 <fetchstr>
80104e54:	83 c4 10             	add    $0x10,%esp
80104e57:	85 c0                	test   %eax,%eax
80104e59:	78 46                	js     80104ea1 <sys_exec+0xe7>
  for(i=0;; i++){
80104e5b:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104e5e:	eb b4                	jmp    80104e14 <sys_exec+0x5a>
      argv[i] = 0;
80104e60:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104e67:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104e6b:	83 ec 08             	sub    $0x8,%esp
80104e6e:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104e74:	50                   	push   %eax
80104e75:	ff 75 f4             	pushl  -0xc(%ebp)
80104e78:	e8 55 ba ff ff       	call   801008d2 <exec>
80104e7d:	83 c4 10             	add    $0x10,%esp
80104e80:	eb 1a                	jmp    80104e9c <sys_exec+0xe2>
    return -1;
80104e82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e87:	eb 13                	jmp    80104e9c <sys_exec+0xe2>
80104e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8e:	eb 0c                	jmp    80104e9c <sys_exec+0xe2>
      return -1;
80104e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e95:	eb 05                	jmp    80104e9c <sys_exec+0xe2>
      return -1;
80104e97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e9f:	c9                   	leave  
80104ea0:	c3                   	ret    
      return -1;
80104ea1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ea6:	eb f4                	jmp    80104e9c <sys_exec+0xe2>

80104ea8 <sys_pipe>:

int
sys_pipe(void)
{
80104ea8:	55                   	push   %ebp
80104ea9:	89 e5                	mov    %esp,%ebp
80104eab:	53                   	push   %ebx
80104eac:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104eaf:	6a 08                	push   $0x8
80104eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104eb4:	50                   	push   %eax
80104eb5:	6a 00                	push   $0x0
80104eb7:	e8 e3 f3 ff ff       	call   8010429f <argptr>
80104ebc:	83 c4 10             	add    $0x10,%esp
80104ebf:	85 c0                	test   %eax,%eax
80104ec1:	78 77                	js     80104f3a <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104ec3:	83 ec 08             	sub    $0x8,%esp
80104ec6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ec9:	50                   	push   %eax
80104eca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ecd:	50                   	push   %eax
80104ece:	e8 a2 e1 ff ff       	call   80103075 <pipealloc>
80104ed3:	83 c4 10             	add    $0x10,%esp
80104ed6:	85 c0                	test   %eax,%eax
80104ed8:	78 67                	js     80104f41 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edd:	e8 14 f5 ff ff       	call   801043f6 <fdalloc>
80104ee2:	89 c3                	mov    %eax,%ebx
80104ee4:	85 c0                	test   %eax,%eax
80104ee6:	78 21                	js     80104f09 <sys_pipe+0x61>
80104ee8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104eeb:	e8 06 f5 ff ff       	call   801043f6 <fdalloc>
80104ef0:	85 c0                	test   %eax,%eax
80104ef2:	78 15                	js     80104f09 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104ef4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ef7:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104ef9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104efc:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104eff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f07:	c9                   	leave  
80104f08:	c3                   	ret    
    if(fd0 >= 0)
80104f09:	85 db                	test   %ebx,%ebx
80104f0b:	78 0d                	js     80104f1a <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104f0d:	e8 54 e6 ff ff       	call   80103566 <myproc>
80104f12:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104f19:	00 
    fileclose(rf);
80104f1a:	83 ec 0c             	sub    $0xc,%esp
80104f1d:	ff 75 f0             	pushl  -0x10(%ebp)
80104f20:	e8 c2 bd ff ff       	call   80100ce7 <fileclose>
    fileclose(wf);
80104f25:	83 c4 04             	add    $0x4,%esp
80104f28:	ff 75 ec             	pushl  -0x14(%ebp)
80104f2b:	e8 b7 bd ff ff       	call   80100ce7 <fileclose>
    return -1;
80104f30:	83 c4 10             	add    $0x10,%esp
80104f33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f38:	eb ca                	jmp    80104f04 <sys_pipe+0x5c>
    return -1;
80104f3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f3f:	eb c3                	jmp    80104f04 <sys_pipe+0x5c>
    return -1;
80104f41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f46:	eb bc                	jmp    80104f04 <sys_pipe+0x5c>

80104f48 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104f48:	55                   	push   %ebp
80104f49:	89 e5                	mov    %esp,%ebp
80104f4b:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104f4e:	e8 97 e7 ff ff       	call   801036ea <fork>
}
80104f53:	c9                   	leave  
80104f54:	c3                   	ret    

80104f55 <sys_exit>:

int
sys_exit(void)
{
80104f55:	55                   	push   %ebp
80104f56:	89 e5                	mov    %esp,%ebp
80104f58:	83 ec 08             	sub    $0x8,%esp
  exit();
80104f5b:	e8 c6 e9 ff ff       	call   80103926 <exit>
  return 0;  // not reached
}
80104f60:	b8 00 00 00 00       	mov    $0x0,%eax
80104f65:	c9                   	leave  
80104f66:	c3                   	ret    

80104f67 <sys_wait>:

int
sys_wait(void)
{
80104f67:	55                   	push   %ebp
80104f68:	89 e5                	mov    %esp,%ebp
80104f6a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104f6d:	e8 3d eb ff ff       	call   80103aaf <wait>
}
80104f72:	c9                   	leave  
80104f73:	c3                   	ret    

80104f74 <sys_kill>:

int
sys_kill(void)
{
80104f74:	55                   	push   %ebp
80104f75:	89 e5                	mov    %esp,%ebp
80104f77:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f7d:	50                   	push   %eax
80104f7e:	6a 00                	push   $0x0
80104f80:	e8 f2 f2 ff ff       	call   80104277 <argint>
80104f85:	83 c4 10             	add    $0x10,%esp
80104f88:	85 c0                	test   %eax,%eax
80104f8a:	78 10                	js     80104f9c <sys_kill+0x28>
    return -1;
  return kill(pid);
80104f8c:	83 ec 0c             	sub    $0xc,%esp
80104f8f:	ff 75 f4             	pushl  -0xc(%ebp)
80104f92:	e8 15 ec ff ff       	call   80103bac <kill>
80104f97:	83 c4 10             	add    $0x10,%esp
}
80104f9a:	c9                   	leave  
80104f9b:	c3                   	ret    
    return -1;
80104f9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa1:	eb f7                	jmp    80104f9a <sys_kill+0x26>

80104fa3 <sys_getpid>:

int
sys_getpid(void)
{
80104fa3:	55                   	push   %ebp
80104fa4:	89 e5                	mov    %esp,%ebp
80104fa6:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104fa9:	e8 b8 e5 ff ff       	call   80103566 <myproc>
80104fae:	8b 40 10             	mov    0x10(%eax),%eax
}
80104fb1:	c9                   	leave  
80104fb2:	c3                   	ret    

80104fb3 <sys_sbrk>:

int
sys_sbrk(void)
{
80104fb3:	55                   	push   %ebp
80104fb4:	89 e5                	mov    %esp,%ebp
80104fb6:	53                   	push   %ebx
80104fb7:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fbd:	50                   	push   %eax
80104fbe:	6a 00                	push   $0x0
80104fc0:	e8 b2 f2 ff ff       	call   80104277 <argint>
80104fc5:	83 c4 10             	add    $0x10,%esp
80104fc8:	85 c0                	test   %eax,%eax
80104fca:	78 27                	js     80104ff3 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104fcc:	e8 95 e5 ff ff       	call   80103566 <myproc>
80104fd1:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104fd3:	83 ec 0c             	sub    $0xc,%esp
80104fd6:	ff 75 f4             	pushl  -0xc(%ebp)
80104fd9:	e8 9f e6 ff ff       	call   8010367d <growproc>
80104fde:	83 c4 10             	add    $0x10,%esp
80104fe1:	85 c0                	test   %eax,%eax
80104fe3:	78 07                	js     80104fec <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104fe5:	89 d8                	mov    %ebx,%eax
80104fe7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fea:	c9                   	leave  
80104feb:	c3                   	ret    
    return -1;
80104fec:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ff1:	eb f2                	jmp    80104fe5 <sys_sbrk+0x32>
    return -1;
80104ff3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ff8:	eb eb                	jmp    80104fe5 <sys_sbrk+0x32>

80104ffa <sys_sleep>:

int
sys_sleep(void)
{
80104ffa:	55                   	push   %ebp
80104ffb:	89 e5                	mov    %esp,%ebp
80104ffd:	53                   	push   %ebx
80104ffe:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105001:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105004:	50                   	push   %eax
80105005:	6a 00                	push   $0x0
80105007:	e8 6b f2 ff ff       	call   80104277 <argint>
8010500c:	83 c4 10             	add    $0x10,%esp
8010500f:	85 c0                	test   %eax,%eax
80105011:	78 75                	js     80105088 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80105013:	83 ec 0c             	sub    $0xc,%esp
80105016:	68 00 ba 1e 80       	push   $0x801eba00
8010501b:	e8 60 ef ff ff       	call   80103f80 <acquire>
  ticks0 = ticks;
80105020:	8b 1d 40 c2 1e 80    	mov    0x801ec240,%ebx
  while(ticks - ticks0 < n){
80105026:	83 c4 10             	add    $0x10,%esp
80105029:	a1 40 c2 1e 80       	mov    0x801ec240,%eax
8010502e:	29 d8                	sub    %ebx,%eax
80105030:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105033:	73 39                	jae    8010506e <sys_sleep+0x74>
    if(myproc()->killed){
80105035:	e8 2c e5 ff ff       	call   80103566 <myproc>
8010503a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010503e:	75 17                	jne    80105057 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105040:	83 ec 08             	sub    $0x8,%esp
80105043:	68 00 ba 1e 80       	push   $0x801eba00
80105048:	68 40 c2 1e 80       	push   $0x801ec240
8010504d:	e8 cc e9 ff ff       	call   80103a1e <sleep>
80105052:	83 c4 10             	add    $0x10,%esp
80105055:	eb d2                	jmp    80105029 <sys_sleep+0x2f>
      release(&tickslock);
80105057:	83 ec 0c             	sub    $0xc,%esp
8010505a:	68 00 ba 1e 80       	push   $0x801eba00
8010505f:	e8 81 ef ff ff       	call   80103fe5 <release>
      return -1;
80105064:	83 c4 10             	add    $0x10,%esp
80105067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010506c:	eb 15                	jmp    80105083 <sys_sleep+0x89>
  }
  release(&tickslock);
8010506e:	83 ec 0c             	sub    $0xc,%esp
80105071:	68 00 ba 1e 80       	push   $0x801eba00
80105076:	e8 6a ef ff ff       	call   80103fe5 <release>
  return 0;
8010507b:	83 c4 10             	add    $0x10,%esp
8010507e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105083:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105086:	c9                   	leave  
80105087:	c3                   	ret    
    return -1;
80105088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010508d:	eb f4                	jmp    80105083 <sys_sleep+0x89>

8010508f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010508f:	55                   	push   %ebp
80105090:	89 e5                	mov    %esp,%ebp
80105092:	53                   	push   %ebx
80105093:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105096:	68 00 ba 1e 80       	push   $0x801eba00
8010509b:	e8 e0 ee ff ff       	call   80103f80 <acquire>
  xticks = ticks;
801050a0:	8b 1d 40 c2 1e 80    	mov    0x801ec240,%ebx
  release(&tickslock);
801050a6:	c7 04 24 00 ba 1e 80 	movl   $0x801eba00,(%esp)
801050ad:	e8 33 ef ff ff       	call   80103fe5 <release>
  return xticks;
}
801050b2:	89 d8                	mov    %ebx,%eax
801050b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050b7:	c9                   	leave  
801050b8:	c3                   	ret    

801050b9 <sys_dump_physmem>:

int 
sys_dump_physmem(void)
{
801050b9:	55                   	push   %ebp
801050ba:	89 e5                	mov    %esp,%ebp
801050bc:	83 ec 1c             	sub    $0x1c,%esp
    int *frames;
    if(argptr(0, (void*)&frames, sizeof(*frames))< 0){
801050bf:	6a 04                	push   $0x4
801050c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050c4:	50                   	push   %eax
801050c5:	6a 00                	push   $0x0
801050c7:	e8 d3 f1 ff ff       	call   8010429f <argptr>
801050cc:	83 c4 10             	add    $0x10,%esp
801050cf:	85 c0                	test   %eax,%eax
801050d1:	78 49                	js     8010511c <sys_dump_physmem+0x63>
        return -1;
    }
    int *pids;
    if(argptr(1, (void*)&pids, sizeof(*pids))< 0){
801050d3:	83 ec 04             	sub    $0x4,%esp
801050d6:	6a 04                	push   $0x4
801050d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050db:	50                   	push   %eax
801050dc:	6a 01                	push   $0x1
801050de:	e8 bc f1 ff ff       	call   8010429f <argptr>
801050e3:	83 c4 10             	add    $0x10,%esp
801050e6:	85 c0                	test   %eax,%eax
801050e8:	78 39                	js     80105123 <sys_dump_physmem+0x6a>
         return -1;
    }
    int numframes = 0;
801050ea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    if(argint(2, &numframes) < 0){
801050f1:	83 ec 08             	sub    $0x8,%esp
801050f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050f7:	50                   	push   %eax
801050f8:	6a 02                	push   $0x2
801050fa:	e8 78 f1 ff ff       	call   80104277 <argint>
801050ff:	83 c4 10             	add    $0x10,%esp
80105102:	85 c0                	test   %eax,%eax
80105104:	78 24                	js     8010512a <sys_dump_physmem+0x71>
       return -1;
    }
    return dump_physmem(frames, pids, numframes);
80105106:	83 ec 04             	sub    $0x4,%esp
80105109:	ff 75 ec             	pushl  -0x14(%ebp)
8010510c:	ff 75 f0             	pushl  -0x10(%ebp)
8010510f:	ff 75 f4             	pushl  -0xc(%ebp)
80105112:	e8 bb eb ff ff       	call   80103cd2 <dump_physmem>
80105117:	83 c4 10             	add    $0x10,%esp
}
8010511a:	c9                   	leave  
8010511b:	c3                   	ret    
        return -1;
8010511c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105121:	eb f7                	jmp    8010511a <sys_dump_physmem+0x61>
         return -1;
80105123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105128:	eb f0                	jmp    8010511a <sys_dump_physmem+0x61>
       return -1;
8010512a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512f:	eb e9                	jmp    8010511a <sys_dump_physmem+0x61>

80105131 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105131:	1e                   	push   %ds
  pushl %es
80105132:	06                   	push   %es
  pushl %fs
80105133:	0f a0                	push   %fs
  pushl %gs
80105135:	0f a8                	push   %gs
  pushal
80105137:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105138:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010513c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010513e:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105140:	54                   	push   %esp
  call trap
80105141:	e8 e3 00 00 00       	call   80105229 <trap>
  addl $4, %esp
80105146:	83 c4 04             	add    $0x4,%esp

80105149 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105149:	61                   	popa   
  popl %gs
8010514a:	0f a9                	pop    %gs
  popl %fs
8010514c:	0f a1                	pop    %fs
  popl %es
8010514e:	07                   	pop    %es
  popl %ds
8010514f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105150:	83 c4 08             	add    $0x8,%esp
  iret
80105153:	cf                   	iret   

80105154 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105154:	55                   	push   %ebp
80105155:	89 e5                	mov    %esp,%ebp
80105157:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
8010515a:	b8 00 00 00 00       	mov    $0x0,%eax
8010515f:	eb 4a                	jmp    801051ab <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105161:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105168:	66 89 0c c5 40 ba 1e 	mov    %cx,-0x7fe145c0(,%eax,8)
8010516f:	80 
80105170:	66 c7 04 c5 42 ba 1e 	movw   $0x8,-0x7fe145be(,%eax,8)
80105177:	80 08 00 
8010517a:	c6 04 c5 44 ba 1e 80 	movb   $0x0,-0x7fe145bc(,%eax,8)
80105181:	00 
80105182:	0f b6 14 c5 45 ba 1e 	movzbl -0x7fe145bb(,%eax,8),%edx
80105189:	80 
8010518a:	83 e2 f0             	and    $0xfffffff0,%edx
8010518d:	83 ca 0e             	or     $0xe,%edx
80105190:	83 e2 8f             	and    $0xffffff8f,%edx
80105193:	83 ca 80             	or     $0xffffff80,%edx
80105196:	88 14 c5 45 ba 1e 80 	mov    %dl,-0x7fe145bb(,%eax,8)
8010519d:	c1 e9 10             	shr    $0x10,%ecx
801051a0:	66 89 0c c5 46 ba 1e 	mov    %cx,-0x7fe145ba(,%eax,8)
801051a7:	80 
  for(i = 0; i < 256; i++)
801051a8:	83 c0 01             	add    $0x1,%eax
801051ab:	3d ff 00 00 00       	cmp    $0xff,%eax
801051b0:	7e af                	jle    80105161 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801051b2:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
801051b8:	66 89 15 40 bc 1e 80 	mov    %dx,0x801ebc40
801051bf:	66 c7 05 42 bc 1e 80 	movw   $0x8,0x801ebc42
801051c6:	08 00 
801051c8:	c6 05 44 bc 1e 80 00 	movb   $0x0,0x801ebc44
801051cf:	0f b6 05 45 bc 1e 80 	movzbl 0x801ebc45,%eax
801051d6:	83 c8 0f             	or     $0xf,%eax
801051d9:	83 e0 ef             	and    $0xffffffef,%eax
801051dc:	83 c8 e0             	or     $0xffffffe0,%eax
801051df:	a2 45 bc 1e 80       	mov    %al,0x801ebc45
801051e4:	c1 ea 10             	shr    $0x10,%edx
801051e7:	66 89 15 46 bc 1e 80 	mov    %dx,0x801ebc46

  initlock(&tickslock, "time");
801051ee:	83 ec 08             	sub    $0x8,%esp
801051f1:	68 9d 70 10 80       	push   $0x8010709d
801051f6:	68 00 ba 1e 80       	push   $0x801eba00
801051fb:	e8 44 ec ff ff       	call   80103e44 <initlock>
}
80105200:	83 c4 10             	add    $0x10,%esp
80105203:	c9                   	leave  
80105204:	c3                   	ret    

80105205 <idtinit>:

void
idtinit(void)
{
80105205:	55                   	push   %ebp
80105206:	89 e5                	mov    %esp,%ebp
80105208:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010520b:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105211:	b8 40 ba 1e 80       	mov    $0x801eba40,%eax
80105216:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010521a:	c1 e8 10             	shr    $0x10,%eax
8010521d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105221:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105224:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105227:	c9                   	leave  
80105228:	c3                   	ret    

80105229 <trap>:

void
trap(struct trapframe *tf)
{
80105229:	55                   	push   %ebp
8010522a:	89 e5                	mov    %esp,%ebp
8010522c:	57                   	push   %edi
8010522d:	56                   	push   %esi
8010522e:	53                   	push   %ebx
8010522f:	83 ec 1c             	sub    $0x1c,%esp
80105232:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105235:	8b 43 30             	mov    0x30(%ebx),%eax
80105238:	83 f8 40             	cmp    $0x40,%eax
8010523b:	74 13                	je     80105250 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010523d:	83 e8 20             	sub    $0x20,%eax
80105240:	83 f8 1f             	cmp    $0x1f,%eax
80105243:	0f 87 3a 01 00 00    	ja     80105383 <trap+0x15a>
80105249:	ff 24 85 44 71 10 80 	jmp    *-0x7fef8ebc(,%eax,4)
    if(myproc()->killed)
80105250:	e8 11 e3 ff ff       	call   80103566 <myproc>
80105255:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105259:	75 1f                	jne    8010527a <trap+0x51>
    myproc()->tf = tf;
8010525b:	e8 06 e3 ff ff       	call   80103566 <myproc>
80105260:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105263:	e8 d2 f0 ff ff       	call   8010433a <syscall>
    if(myproc()->killed)
80105268:	e8 f9 e2 ff ff       	call   80103566 <myproc>
8010526d:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105271:	74 7e                	je     801052f1 <trap+0xc8>
      exit();
80105273:	e8 ae e6 ff ff       	call   80103926 <exit>
80105278:	eb 77                	jmp    801052f1 <trap+0xc8>
      exit();
8010527a:	e8 a7 e6 ff ff       	call   80103926 <exit>
8010527f:	eb da                	jmp    8010525b <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105281:	e8 c5 e2 ff ff       	call   8010354b <cpuid>
80105286:	85 c0                	test   %eax,%eax
80105288:	74 6f                	je     801052f9 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
8010528a:	e8 4a d4 ff ff       	call   801026d9 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010528f:	e8 d2 e2 ff ff       	call   80103566 <myproc>
80105294:	85 c0                	test   %eax,%eax
80105296:	74 1c                	je     801052b4 <trap+0x8b>
80105298:	e8 c9 e2 ff ff       	call   80103566 <myproc>
8010529d:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801052a1:	74 11                	je     801052b4 <trap+0x8b>
801052a3:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801052a7:	83 e0 03             	and    $0x3,%eax
801052aa:	66 83 f8 03          	cmp    $0x3,%ax
801052ae:	0f 84 62 01 00 00    	je     80105416 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801052b4:	e8 ad e2 ff ff       	call   80103566 <myproc>
801052b9:	85 c0                	test   %eax,%eax
801052bb:	74 0f                	je     801052cc <trap+0xa3>
801052bd:	e8 a4 e2 ff ff       	call   80103566 <myproc>
801052c2:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801052c6:	0f 84 54 01 00 00    	je     80105420 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801052cc:	e8 95 e2 ff ff       	call   80103566 <myproc>
801052d1:	85 c0                	test   %eax,%eax
801052d3:	74 1c                	je     801052f1 <trap+0xc8>
801052d5:	e8 8c e2 ff ff       	call   80103566 <myproc>
801052da:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801052de:	74 11                	je     801052f1 <trap+0xc8>
801052e0:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801052e4:	83 e0 03             	and    $0x3,%eax
801052e7:	66 83 f8 03          	cmp    $0x3,%ax
801052eb:	0f 84 43 01 00 00    	je     80105434 <trap+0x20b>
    exit();
}
801052f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801052f4:	5b                   	pop    %ebx
801052f5:	5e                   	pop    %esi
801052f6:	5f                   	pop    %edi
801052f7:	5d                   	pop    %ebp
801052f8:	c3                   	ret    
      acquire(&tickslock);
801052f9:	83 ec 0c             	sub    $0xc,%esp
801052fc:	68 00 ba 1e 80       	push   $0x801eba00
80105301:	e8 7a ec ff ff       	call   80103f80 <acquire>
      ticks++;
80105306:	83 05 40 c2 1e 80 01 	addl   $0x1,0x801ec240
      wakeup(&ticks);
8010530d:	c7 04 24 40 c2 1e 80 	movl   $0x801ec240,(%esp)
80105314:	e8 6a e8 ff ff       	call   80103b83 <wakeup>
      release(&tickslock);
80105319:	c7 04 24 00 ba 1e 80 	movl   $0x801eba00,(%esp)
80105320:	e8 c0 ec ff ff       	call   80103fe5 <release>
80105325:	83 c4 10             	add    $0x10,%esp
80105328:	e9 5d ff ff ff       	jmp    8010528a <trap+0x61>
    ideintr();
8010532d:	e8 55 ca ff ff       	call   80101d87 <ideintr>
    lapiceoi();
80105332:	e8 a2 d3 ff ff       	call   801026d9 <lapiceoi>
    break;
80105337:	e9 53 ff ff ff       	jmp    8010528f <trap+0x66>
    kbdintr();
8010533c:	e8 dc d1 ff ff       	call   8010251d <kbdintr>
    lapiceoi();
80105341:	e8 93 d3 ff ff       	call   801026d9 <lapiceoi>
    break;
80105346:	e9 44 ff ff ff       	jmp    8010528f <trap+0x66>
    uartintr();
8010534b:	e8 05 02 00 00       	call   80105555 <uartintr>
    lapiceoi();
80105350:	e8 84 d3 ff ff       	call   801026d9 <lapiceoi>
    break;
80105355:	e9 35 ff ff ff       	jmp    8010528f <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010535a:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010535d:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105361:	e8 e5 e1 ff ff       	call   8010354b <cpuid>
80105366:	57                   	push   %edi
80105367:	0f b7 f6             	movzwl %si,%esi
8010536a:	56                   	push   %esi
8010536b:	50                   	push   %eax
8010536c:	68 a8 70 10 80       	push   $0x801070a8
80105371:	e8 95 b2 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105376:	e8 5e d3 ff ff       	call   801026d9 <lapiceoi>
    break;
8010537b:	83 c4 10             	add    $0x10,%esp
8010537e:	e9 0c ff ff ff       	jmp    8010528f <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105383:	e8 de e1 ff ff       	call   80103566 <myproc>
80105388:	85 c0                	test   %eax,%eax
8010538a:	74 5f                	je     801053eb <trap+0x1c2>
8010538c:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105390:	74 59                	je     801053eb <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105392:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105395:	8b 43 38             	mov    0x38(%ebx),%eax
80105398:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010539b:	e8 ab e1 ff ff       	call   8010354b <cpuid>
801053a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801053a3:	8b 53 34             	mov    0x34(%ebx),%edx
801053a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
801053a9:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801053ac:	e8 b5 e1 ff ff       	call   80103566 <myproc>
801053b1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801053b4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801053b7:	e8 aa e1 ff ff       	call   80103566 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801053bc:	57                   	push   %edi
801053bd:	ff 75 e4             	pushl  -0x1c(%ebp)
801053c0:	ff 75 e0             	pushl  -0x20(%ebp)
801053c3:	ff 75 dc             	pushl  -0x24(%ebp)
801053c6:	56                   	push   %esi
801053c7:	ff 75 d8             	pushl  -0x28(%ebp)
801053ca:	ff 70 10             	pushl  0x10(%eax)
801053cd:	68 00 71 10 80       	push   $0x80107100
801053d2:	e8 34 b2 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801053d7:	83 c4 20             	add    $0x20,%esp
801053da:	e8 87 e1 ff ff       	call   80103566 <myproc>
801053df:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801053e6:	e9 a4 fe ff ff       	jmp    8010528f <trap+0x66>
801053eb:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801053ee:	8b 73 38             	mov    0x38(%ebx),%esi
801053f1:	e8 55 e1 ff ff       	call   8010354b <cpuid>
801053f6:	83 ec 0c             	sub    $0xc,%esp
801053f9:	57                   	push   %edi
801053fa:	56                   	push   %esi
801053fb:	50                   	push   %eax
801053fc:	ff 73 30             	pushl  0x30(%ebx)
801053ff:	68 cc 70 10 80       	push   $0x801070cc
80105404:	e8 02 b2 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105409:	83 c4 14             	add    $0x14,%esp
8010540c:	68 a2 70 10 80       	push   $0x801070a2
80105411:	e8 32 af ff ff       	call   80100348 <panic>
    exit();
80105416:	e8 0b e5 ff ff       	call   80103926 <exit>
8010541b:	e9 94 fe ff ff       	jmp    801052b4 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105420:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105424:	0f 85 a2 fe ff ff    	jne    801052cc <trap+0xa3>
    yield();
8010542a:	e8 bd e5 ff ff       	call   801039ec <yield>
8010542f:	e9 98 fe ff ff       	jmp    801052cc <trap+0xa3>
    exit();
80105434:	e8 ed e4 ff ff       	call   80103926 <exit>
80105439:	e9 b3 fe ff ff       	jmp    801052f1 <trap+0xc8>

8010543e <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010543e:	55                   	push   %ebp
8010543f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105441:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105448:	74 15                	je     8010545f <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010544a:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010544f:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105450:	a8 01                	test   $0x1,%al
80105452:	74 12                	je     80105466 <uartgetc+0x28>
80105454:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105459:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010545a:	0f b6 c0             	movzbl %al,%eax
}
8010545d:	5d                   	pop    %ebp
8010545e:	c3                   	ret    
    return -1;
8010545f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105464:	eb f7                	jmp    8010545d <uartgetc+0x1f>
    return -1;
80105466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546b:	eb f0                	jmp    8010545d <uartgetc+0x1f>

8010546d <uartputc>:
  if(!uart)
8010546d:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105474:	74 3b                	je     801054b1 <uartputc+0x44>
{
80105476:	55                   	push   %ebp
80105477:	89 e5                	mov    %esp,%ebp
80105479:	53                   	push   %ebx
8010547a:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010547d:	bb 00 00 00 00       	mov    $0x0,%ebx
80105482:	eb 10                	jmp    80105494 <uartputc+0x27>
    microdelay(10);
80105484:	83 ec 0c             	sub    $0xc,%esp
80105487:	6a 0a                	push   $0xa
80105489:	e8 6a d2 ff ff       	call   801026f8 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010548e:	83 c3 01             	add    $0x1,%ebx
80105491:	83 c4 10             	add    $0x10,%esp
80105494:	83 fb 7f             	cmp    $0x7f,%ebx
80105497:	7f 0a                	jg     801054a3 <uartputc+0x36>
80105499:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010549e:	ec                   	in     (%dx),%al
8010549f:	a8 20                	test   $0x20,%al
801054a1:	74 e1                	je     80105484 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801054a3:	8b 45 08             	mov    0x8(%ebp),%eax
801054a6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801054ab:	ee                   	out    %al,(%dx)
}
801054ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054af:	c9                   	leave  
801054b0:	c3                   	ret    
801054b1:	f3 c3                	repz ret 

801054b3 <uartinit>:
{
801054b3:	55                   	push   %ebp
801054b4:	89 e5                	mov    %esp,%ebp
801054b6:	56                   	push   %esi
801054b7:	53                   	push   %ebx
801054b8:	b9 00 00 00 00       	mov    $0x0,%ecx
801054bd:	ba fa 03 00 00       	mov    $0x3fa,%edx
801054c2:	89 c8                	mov    %ecx,%eax
801054c4:	ee                   	out    %al,(%dx)
801054c5:	be fb 03 00 00       	mov    $0x3fb,%esi
801054ca:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801054cf:	89 f2                	mov    %esi,%edx
801054d1:	ee                   	out    %al,(%dx)
801054d2:	b8 0c 00 00 00       	mov    $0xc,%eax
801054d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
801054dc:	ee                   	out    %al,(%dx)
801054dd:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801054e2:	89 c8                	mov    %ecx,%eax
801054e4:	89 da                	mov    %ebx,%edx
801054e6:	ee                   	out    %al,(%dx)
801054e7:	b8 03 00 00 00       	mov    $0x3,%eax
801054ec:	89 f2                	mov    %esi,%edx
801054ee:	ee                   	out    %al,(%dx)
801054ef:	ba fc 03 00 00       	mov    $0x3fc,%edx
801054f4:	89 c8                	mov    %ecx,%eax
801054f6:	ee                   	out    %al,(%dx)
801054f7:	b8 01 00 00 00       	mov    $0x1,%eax
801054fc:	89 da                	mov    %ebx,%edx
801054fe:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801054ff:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105504:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105505:	3c ff                	cmp    $0xff,%al
80105507:	74 45                	je     8010554e <uartinit+0x9b>
  uart = 1;
80105509:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105510:	00 00 00 
80105513:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105518:	ec                   	in     (%dx),%al
80105519:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010551e:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010551f:	83 ec 08             	sub    $0x8,%esp
80105522:	6a 00                	push   $0x0
80105524:	6a 04                	push   $0x4
80105526:	e8 67 ca ff ff       	call   80101f92 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
8010552b:	83 c4 10             	add    $0x10,%esp
8010552e:	bb c4 71 10 80       	mov    $0x801071c4,%ebx
80105533:	eb 12                	jmp    80105547 <uartinit+0x94>
    uartputc(*p);
80105535:	83 ec 0c             	sub    $0xc,%esp
80105538:	0f be c0             	movsbl %al,%eax
8010553b:	50                   	push   %eax
8010553c:	e8 2c ff ff ff       	call   8010546d <uartputc>
  for(p="xv6...\n"; *p; p++)
80105541:	83 c3 01             	add    $0x1,%ebx
80105544:	83 c4 10             	add    $0x10,%esp
80105547:	0f b6 03             	movzbl (%ebx),%eax
8010554a:	84 c0                	test   %al,%al
8010554c:	75 e7                	jne    80105535 <uartinit+0x82>
}
8010554e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105551:	5b                   	pop    %ebx
80105552:	5e                   	pop    %esi
80105553:	5d                   	pop    %ebp
80105554:	c3                   	ret    

80105555 <uartintr>:

void
uartintr(void)
{
80105555:	55                   	push   %ebp
80105556:	89 e5                	mov    %esp,%ebp
80105558:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
8010555b:	68 3e 54 10 80       	push   $0x8010543e
80105560:	e8 d9 b1 ff ff       	call   8010073e <consoleintr>
}
80105565:	83 c4 10             	add    $0x10,%esp
80105568:	c9                   	leave  
80105569:	c3                   	ret    

8010556a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010556a:	6a 00                	push   $0x0
  pushl $0
8010556c:	6a 00                	push   $0x0
  jmp alltraps
8010556e:	e9 be fb ff ff       	jmp    80105131 <alltraps>

80105573 <vector1>:
.globl vector1
vector1:
  pushl $0
80105573:	6a 00                	push   $0x0
  pushl $1
80105575:	6a 01                	push   $0x1
  jmp alltraps
80105577:	e9 b5 fb ff ff       	jmp    80105131 <alltraps>

8010557c <vector2>:
.globl vector2
vector2:
  pushl $0
8010557c:	6a 00                	push   $0x0
  pushl $2
8010557e:	6a 02                	push   $0x2
  jmp alltraps
80105580:	e9 ac fb ff ff       	jmp    80105131 <alltraps>

80105585 <vector3>:
.globl vector3
vector3:
  pushl $0
80105585:	6a 00                	push   $0x0
  pushl $3
80105587:	6a 03                	push   $0x3
  jmp alltraps
80105589:	e9 a3 fb ff ff       	jmp    80105131 <alltraps>

8010558e <vector4>:
.globl vector4
vector4:
  pushl $0
8010558e:	6a 00                	push   $0x0
  pushl $4
80105590:	6a 04                	push   $0x4
  jmp alltraps
80105592:	e9 9a fb ff ff       	jmp    80105131 <alltraps>

80105597 <vector5>:
.globl vector5
vector5:
  pushl $0
80105597:	6a 00                	push   $0x0
  pushl $5
80105599:	6a 05                	push   $0x5
  jmp alltraps
8010559b:	e9 91 fb ff ff       	jmp    80105131 <alltraps>

801055a0 <vector6>:
.globl vector6
vector6:
  pushl $0
801055a0:	6a 00                	push   $0x0
  pushl $6
801055a2:	6a 06                	push   $0x6
  jmp alltraps
801055a4:	e9 88 fb ff ff       	jmp    80105131 <alltraps>

801055a9 <vector7>:
.globl vector7
vector7:
  pushl $0
801055a9:	6a 00                	push   $0x0
  pushl $7
801055ab:	6a 07                	push   $0x7
  jmp alltraps
801055ad:	e9 7f fb ff ff       	jmp    80105131 <alltraps>

801055b2 <vector8>:
.globl vector8
vector8:
  pushl $8
801055b2:	6a 08                	push   $0x8
  jmp alltraps
801055b4:	e9 78 fb ff ff       	jmp    80105131 <alltraps>

801055b9 <vector9>:
.globl vector9
vector9:
  pushl $0
801055b9:	6a 00                	push   $0x0
  pushl $9
801055bb:	6a 09                	push   $0x9
  jmp alltraps
801055bd:	e9 6f fb ff ff       	jmp    80105131 <alltraps>

801055c2 <vector10>:
.globl vector10
vector10:
  pushl $10
801055c2:	6a 0a                	push   $0xa
  jmp alltraps
801055c4:	e9 68 fb ff ff       	jmp    80105131 <alltraps>

801055c9 <vector11>:
.globl vector11
vector11:
  pushl $11
801055c9:	6a 0b                	push   $0xb
  jmp alltraps
801055cb:	e9 61 fb ff ff       	jmp    80105131 <alltraps>

801055d0 <vector12>:
.globl vector12
vector12:
  pushl $12
801055d0:	6a 0c                	push   $0xc
  jmp alltraps
801055d2:	e9 5a fb ff ff       	jmp    80105131 <alltraps>

801055d7 <vector13>:
.globl vector13
vector13:
  pushl $13
801055d7:	6a 0d                	push   $0xd
  jmp alltraps
801055d9:	e9 53 fb ff ff       	jmp    80105131 <alltraps>

801055de <vector14>:
.globl vector14
vector14:
  pushl $14
801055de:	6a 0e                	push   $0xe
  jmp alltraps
801055e0:	e9 4c fb ff ff       	jmp    80105131 <alltraps>

801055e5 <vector15>:
.globl vector15
vector15:
  pushl $0
801055e5:	6a 00                	push   $0x0
  pushl $15
801055e7:	6a 0f                	push   $0xf
  jmp alltraps
801055e9:	e9 43 fb ff ff       	jmp    80105131 <alltraps>

801055ee <vector16>:
.globl vector16
vector16:
  pushl $0
801055ee:	6a 00                	push   $0x0
  pushl $16
801055f0:	6a 10                	push   $0x10
  jmp alltraps
801055f2:	e9 3a fb ff ff       	jmp    80105131 <alltraps>

801055f7 <vector17>:
.globl vector17
vector17:
  pushl $17
801055f7:	6a 11                	push   $0x11
  jmp alltraps
801055f9:	e9 33 fb ff ff       	jmp    80105131 <alltraps>

801055fe <vector18>:
.globl vector18
vector18:
  pushl $0
801055fe:	6a 00                	push   $0x0
  pushl $18
80105600:	6a 12                	push   $0x12
  jmp alltraps
80105602:	e9 2a fb ff ff       	jmp    80105131 <alltraps>

80105607 <vector19>:
.globl vector19
vector19:
  pushl $0
80105607:	6a 00                	push   $0x0
  pushl $19
80105609:	6a 13                	push   $0x13
  jmp alltraps
8010560b:	e9 21 fb ff ff       	jmp    80105131 <alltraps>

80105610 <vector20>:
.globl vector20
vector20:
  pushl $0
80105610:	6a 00                	push   $0x0
  pushl $20
80105612:	6a 14                	push   $0x14
  jmp alltraps
80105614:	e9 18 fb ff ff       	jmp    80105131 <alltraps>

80105619 <vector21>:
.globl vector21
vector21:
  pushl $0
80105619:	6a 00                	push   $0x0
  pushl $21
8010561b:	6a 15                	push   $0x15
  jmp alltraps
8010561d:	e9 0f fb ff ff       	jmp    80105131 <alltraps>

80105622 <vector22>:
.globl vector22
vector22:
  pushl $0
80105622:	6a 00                	push   $0x0
  pushl $22
80105624:	6a 16                	push   $0x16
  jmp alltraps
80105626:	e9 06 fb ff ff       	jmp    80105131 <alltraps>

8010562b <vector23>:
.globl vector23
vector23:
  pushl $0
8010562b:	6a 00                	push   $0x0
  pushl $23
8010562d:	6a 17                	push   $0x17
  jmp alltraps
8010562f:	e9 fd fa ff ff       	jmp    80105131 <alltraps>

80105634 <vector24>:
.globl vector24
vector24:
  pushl $0
80105634:	6a 00                	push   $0x0
  pushl $24
80105636:	6a 18                	push   $0x18
  jmp alltraps
80105638:	e9 f4 fa ff ff       	jmp    80105131 <alltraps>

8010563d <vector25>:
.globl vector25
vector25:
  pushl $0
8010563d:	6a 00                	push   $0x0
  pushl $25
8010563f:	6a 19                	push   $0x19
  jmp alltraps
80105641:	e9 eb fa ff ff       	jmp    80105131 <alltraps>

80105646 <vector26>:
.globl vector26
vector26:
  pushl $0
80105646:	6a 00                	push   $0x0
  pushl $26
80105648:	6a 1a                	push   $0x1a
  jmp alltraps
8010564a:	e9 e2 fa ff ff       	jmp    80105131 <alltraps>

8010564f <vector27>:
.globl vector27
vector27:
  pushl $0
8010564f:	6a 00                	push   $0x0
  pushl $27
80105651:	6a 1b                	push   $0x1b
  jmp alltraps
80105653:	e9 d9 fa ff ff       	jmp    80105131 <alltraps>

80105658 <vector28>:
.globl vector28
vector28:
  pushl $0
80105658:	6a 00                	push   $0x0
  pushl $28
8010565a:	6a 1c                	push   $0x1c
  jmp alltraps
8010565c:	e9 d0 fa ff ff       	jmp    80105131 <alltraps>

80105661 <vector29>:
.globl vector29
vector29:
  pushl $0
80105661:	6a 00                	push   $0x0
  pushl $29
80105663:	6a 1d                	push   $0x1d
  jmp alltraps
80105665:	e9 c7 fa ff ff       	jmp    80105131 <alltraps>

8010566a <vector30>:
.globl vector30
vector30:
  pushl $0
8010566a:	6a 00                	push   $0x0
  pushl $30
8010566c:	6a 1e                	push   $0x1e
  jmp alltraps
8010566e:	e9 be fa ff ff       	jmp    80105131 <alltraps>

80105673 <vector31>:
.globl vector31
vector31:
  pushl $0
80105673:	6a 00                	push   $0x0
  pushl $31
80105675:	6a 1f                	push   $0x1f
  jmp alltraps
80105677:	e9 b5 fa ff ff       	jmp    80105131 <alltraps>

8010567c <vector32>:
.globl vector32
vector32:
  pushl $0
8010567c:	6a 00                	push   $0x0
  pushl $32
8010567e:	6a 20                	push   $0x20
  jmp alltraps
80105680:	e9 ac fa ff ff       	jmp    80105131 <alltraps>

80105685 <vector33>:
.globl vector33
vector33:
  pushl $0
80105685:	6a 00                	push   $0x0
  pushl $33
80105687:	6a 21                	push   $0x21
  jmp alltraps
80105689:	e9 a3 fa ff ff       	jmp    80105131 <alltraps>

8010568e <vector34>:
.globl vector34
vector34:
  pushl $0
8010568e:	6a 00                	push   $0x0
  pushl $34
80105690:	6a 22                	push   $0x22
  jmp alltraps
80105692:	e9 9a fa ff ff       	jmp    80105131 <alltraps>

80105697 <vector35>:
.globl vector35
vector35:
  pushl $0
80105697:	6a 00                	push   $0x0
  pushl $35
80105699:	6a 23                	push   $0x23
  jmp alltraps
8010569b:	e9 91 fa ff ff       	jmp    80105131 <alltraps>

801056a0 <vector36>:
.globl vector36
vector36:
  pushl $0
801056a0:	6a 00                	push   $0x0
  pushl $36
801056a2:	6a 24                	push   $0x24
  jmp alltraps
801056a4:	e9 88 fa ff ff       	jmp    80105131 <alltraps>

801056a9 <vector37>:
.globl vector37
vector37:
  pushl $0
801056a9:	6a 00                	push   $0x0
  pushl $37
801056ab:	6a 25                	push   $0x25
  jmp alltraps
801056ad:	e9 7f fa ff ff       	jmp    80105131 <alltraps>

801056b2 <vector38>:
.globl vector38
vector38:
  pushl $0
801056b2:	6a 00                	push   $0x0
  pushl $38
801056b4:	6a 26                	push   $0x26
  jmp alltraps
801056b6:	e9 76 fa ff ff       	jmp    80105131 <alltraps>

801056bb <vector39>:
.globl vector39
vector39:
  pushl $0
801056bb:	6a 00                	push   $0x0
  pushl $39
801056bd:	6a 27                	push   $0x27
  jmp alltraps
801056bf:	e9 6d fa ff ff       	jmp    80105131 <alltraps>

801056c4 <vector40>:
.globl vector40
vector40:
  pushl $0
801056c4:	6a 00                	push   $0x0
  pushl $40
801056c6:	6a 28                	push   $0x28
  jmp alltraps
801056c8:	e9 64 fa ff ff       	jmp    80105131 <alltraps>

801056cd <vector41>:
.globl vector41
vector41:
  pushl $0
801056cd:	6a 00                	push   $0x0
  pushl $41
801056cf:	6a 29                	push   $0x29
  jmp alltraps
801056d1:	e9 5b fa ff ff       	jmp    80105131 <alltraps>

801056d6 <vector42>:
.globl vector42
vector42:
  pushl $0
801056d6:	6a 00                	push   $0x0
  pushl $42
801056d8:	6a 2a                	push   $0x2a
  jmp alltraps
801056da:	e9 52 fa ff ff       	jmp    80105131 <alltraps>

801056df <vector43>:
.globl vector43
vector43:
  pushl $0
801056df:	6a 00                	push   $0x0
  pushl $43
801056e1:	6a 2b                	push   $0x2b
  jmp alltraps
801056e3:	e9 49 fa ff ff       	jmp    80105131 <alltraps>

801056e8 <vector44>:
.globl vector44
vector44:
  pushl $0
801056e8:	6a 00                	push   $0x0
  pushl $44
801056ea:	6a 2c                	push   $0x2c
  jmp alltraps
801056ec:	e9 40 fa ff ff       	jmp    80105131 <alltraps>

801056f1 <vector45>:
.globl vector45
vector45:
  pushl $0
801056f1:	6a 00                	push   $0x0
  pushl $45
801056f3:	6a 2d                	push   $0x2d
  jmp alltraps
801056f5:	e9 37 fa ff ff       	jmp    80105131 <alltraps>

801056fa <vector46>:
.globl vector46
vector46:
  pushl $0
801056fa:	6a 00                	push   $0x0
  pushl $46
801056fc:	6a 2e                	push   $0x2e
  jmp alltraps
801056fe:	e9 2e fa ff ff       	jmp    80105131 <alltraps>

80105703 <vector47>:
.globl vector47
vector47:
  pushl $0
80105703:	6a 00                	push   $0x0
  pushl $47
80105705:	6a 2f                	push   $0x2f
  jmp alltraps
80105707:	e9 25 fa ff ff       	jmp    80105131 <alltraps>

8010570c <vector48>:
.globl vector48
vector48:
  pushl $0
8010570c:	6a 00                	push   $0x0
  pushl $48
8010570e:	6a 30                	push   $0x30
  jmp alltraps
80105710:	e9 1c fa ff ff       	jmp    80105131 <alltraps>

80105715 <vector49>:
.globl vector49
vector49:
  pushl $0
80105715:	6a 00                	push   $0x0
  pushl $49
80105717:	6a 31                	push   $0x31
  jmp alltraps
80105719:	e9 13 fa ff ff       	jmp    80105131 <alltraps>

8010571e <vector50>:
.globl vector50
vector50:
  pushl $0
8010571e:	6a 00                	push   $0x0
  pushl $50
80105720:	6a 32                	push   $0x32
  jmp alltraps
80105722:	e9 0a fa ff ff       	jmp    80105131 <alltraps>

80105727 <vector51>:
.globl vector51
vector51:
  pushl $0
80105727:	6a 00                	push   $0x0
  pushl $51
80105729:	6a 33                	push   $0x33
  jmp alltraps
8010572b:	e9 01 fa ff ff       	jmp    80105131 <alltraps>

80105730 <vector52>:
.globl vector52
vector52:
  pushl $0
80105730:	6a 00                	push   $0x0
  pushl $52
80105732:	6a 34                	push   $0x34
  jmp alltraps
80105734:	e9 f8 f9 ff ff       	jmp    80105131 <alltraps>

80105739 <vector53>:
.globl vector53
vector53:
  pushl $0
80105739:	6a 00                	push   $0x0
  pushl $53
8010573b:	6a 35                	push   $0x35
  jmp alltraps
8010573d:	e9 ef f9 ff ff       	jmp    80105131 <alltraps>

80105742 <vector54>:
.globl vector54
vector54:
  pushl $0
80105742:	6a 00                	push   $0x0
  pushl $54
80105744:	6a 36                	push   $0x36
  jmp alltraps
80105746:	e9 e6 f9 ff ff       	jmp    80105131 <alltraps>

8010574b <vector55>:
.globl vector55
vector55:
  pushl $0
8010574b:	6a 00                	push   $0x0
  pushl $55
8010574d:	6a 37                	push   $0x37
  jmp alltraps
8010574f:	e9 dd f9 ff ff       	jmp    80105131 <alltraps>

80105754 <vector56>:
.globl vector56
vector56:
  pushl $0
80105754:	6a 00                	push   $0x0
  pushl $56
80105756:	6a 38                	push   $0x38
  jmp alltraps
80105758:	e9 d4 f9 ff ff       	jmp    80105131 <alltraps>

8010575d <vector57>:
.globl vector57
vector57:
  pushl $0
8010575d:	6a 00                	push   $0x0
  pushl $57
8010575f:	6a 39                	push   $0x39
  jmp alltraps
80105761:	e9 cb f9 ff ff       	jmp    80105131 <alltraps>

80105766 <vector58>:
.globl vector58
vector58:
  pushl $0
80105766:	6a 00                	push   $0x0
  pushl $58
80105768:	6a 3a                	push   $0x3a
  jmp alltraps
8010576a:	e9 c2 f9 ff ff       	jmp    80105131 <alltraps>

8010576f <vector59>:
.globl vector59
vector59:
  pushl $0
8010576f:	6a 00                	push   $0x0
  pushl $59
80105771:	6a 3b                	push   $0x3b
  jmp alltraps
80105773:	e9 b9 f9 ff ff       	jmp    80105131 <alltraps>

80105778 <vector60>:
.globl vector60
vector60:
  pushl $0
80105778:	6a 00                	push   $0x0
  pushl $60
8010577a:	6a 3c                	push   $0x3c
  jmp alltraps
8010577c:	e9 b0 f9 ff ff       	jmp    80105131 <alltraps>

80105781 <vector61>:
.globl vector61
vector61:
  pushl $0
80105781:	6a 00                	push   $0x0
  pushl $61
80105783:	6a 3d                	push   $0x3d
  jmp alltraps
80105785:	e9 a7 f9 ff ff       	jmp    80105131 <alltraps>

8010578a <vector62>:
.globl vector62
vector62:
  pushl $0
8010578a:	6a 00                	push   $0x0
  pushl $62
8010578c:	6a 3e                	push   $0x3e
  jmp alltraps
8010578e:	e9 9e f9 ff ff       	jmp    80105131 <alltraps>

80105793 <vector63>:
.globl vector63
vector63:
  pushl $0
80105793:	6a 00                	push   $0x0
  pushl $63
80105795:	6a 3f                	push   $0x3f
  jmp alltraps
80105797:	e9 95 f9 ff ff       	jmp    80105131 <alltraps>

8010579c <vector64>:
.globl vector64
vector64:
  pushl $0
8010579c:	6a 00                	push   $0x0
  pushl $64
8010579e:	6a 40                	push   $0x40
  jmp alltraps
801057a0:	e9 8c f9 ff ff       	jmp    80105131 <alltraps>

801057a5 <vector65>:
.globl vector65
vector65:
  pushl $0
801057a5:	6a 00                	push   $0x0
  pushl $65
801057a7:	6a 41                	push   $0x41
  jmp alltraps
801057a9:	e9 83 f9 ff ff       	jmp    80105131 <alltraps>

801057ae <vector66>:
.globl vector66
vector66:
  pushl $0
801057ae:	6a 00                	push   $0x0
  pushl $66
801057b0:	6a 42                	push   $0x42
  jmp alltraps
801057b2:	e9 7a f9 ff ff       	jmp    80105131 <alltraps>

801057b7 <vector67>:
.globl vector67
vector67:
  pushl $0
801057b7:	6a 00                	push   $0x0
  pushl $67
801057b9:	6a 43                	push   $0x43
  jmp alltraps
801057bb:	e9 71 f9 ff ff       	jmp    80105131 <alltraps>

801057c0 <vector68>:
.globl vector68
vector68:
  pushl $0
801057c0:	6a 00                	push   $0x0
  pushl $68
801057c2:	6a 44                	push   $0x44
  jmp alltraps
801057c4:	e9 68 f9 ff ff       	jmp    80105131 <alltraps>

801057c9 <vector69>:
.globl vector69
vector69:
  pushl $0
801057c9:	6a 00                	push   $0x0
  pushl $69
801057cb:	6a 45                	push   $0x45
  jmp alltraps
801057cd:	e9 5f f9 ff ff       	jmp    80105131 <alltraps>

801057d2 <vector70>:
.globl vector70
vector70:
  pushl $0
801057d2:	6a 00                	push   $0x0
  pushl $70
801057d4:	6a 46                	push   $0x46
  jmp alltraps
801057d6:	e9 56 f9 ff ff       	jmp    80105131 <alltraps>

801057db <vector71>:
.globl vector71
vector71:
  pushl $0
801057db:	6a 00                	push   $0x0
  pushl $71
801057dd:	6a 47                	push   $0x47
  jmp alltraps
801057df:	e9 4d f9 ff ff       	jmp    80105131 <alltraps>

801057e4 <vector72>:
.globl vector72
vector72:
  pushl $0
801057e4:	6a 00                	push   $0x0
  pushl $72
801057e6:	6a 48                	push   $0x48
  jmp alltraps
801057e8:	e9 44 f9 ff ff       	jmp    80105131 <alltraps>

801057ed <vector73>:
.globl vector73
vector73:
  pushl $0
801057ed:	6a 00                	push   $0x0
  pushl $73
801057ef:	6a 49                	push   $0x49
  jmp alltraps
801057f1:	e9 3b f9 ff ff       	jmp    80105131 <alltraps>

801057f6 <vector74>:
.globl vector74
vector74:
  pushl $0
801057f6:	6a 00                	push   $0x0
  pushl $74
801057f8:	6a 4a                	push   $0x4a
  jmp alltraps
801057fa:	e9 32 f9 ff ff       	jmp    80105131 <alltraps>

801057ff <vector75>:
.globl vector75
vector75:
  pushl $0
801057ff:	6a 00                	push   $0x0
  pushl $75
80105801:	6a 4b                	push   $0x4b
  jmp alltraps
80105803:	e9 29 f9 ff ff       	jmp    80105131 <alltraps>

80105808 <vector76>:
.globl vector76
vector76:
  pushl $0
80105808:	6a 00                	push   $0x0
  pushl $76
8010580a:	6a 4c                	push   $0x4c
  jmp alltraps
8010580c:	e9 20 f9 ff ff       	jmp    80105131 <alltraps>

80105811 <vector77>:
.globl vector77
vector77:
  pushl $0
80105811:	6a 00                	push   $0x0
  pushl $77
80105813:	6a 4d                	push   $0x4d
  jmp alltraps
80105815:	e9 17 f9 ff ff       	jmp    80105131 <alltraps>

8010581a <vector78>:
.globl vector78
vector78:
  pushl $0
8010581a:	6a 00                	push   $0x0
  pushl $78
8010581c:	6a 4e                	push   $0x4e
  jmp alltraps
8010581e:	e9 0e f9 ff ff       	jmp    80105131 <alltraps>

80105823 <vector79>:
.globl vector79
vector79:
  pushl $0
80105823:	6a 00                	push   $0x0
  pushl $79
80105825:	6a 4f                	push   $0x4f
  jmp alltraps
80105827:	e9 05 f9 ff ff       	jmp    80105131 <alltraps>

8010582c <vector80>:
.globl vector80
vector80:
  pushl $0
8010582c:	6a 00                	push   $0x0
  pushl $80
8010582e:	6a 50                	push   $0x50
  jmp alltraps
80105830:	e9 fc f8 ff ff       	jmp    80105131 <alltraps>

80105835 <vector81>:
.globl vector81
vector81:
  pushl $0
80105835:	6a 00                	push   $0x0
  pushl $81
80105837:	6a 51                	push   $0x51
  jmp alltraps
80105839:	e9 f3 f8 ff ff       	jmp    80105131 <alltraps>

8010583e <vector82>:
.globl vector82
vector82:
  pushl $0
8010583e:	6a 00                	push   $0x0
  pushl $82
80105840:	6a 52                	push   $0x52
  jmp alltraps
80105842:	e9 ea f8 ff ff       	jmp    80105131 <alltraps>

80105847 <vector83>:
.globl vector83
vector83:
  pushl $0
80105847:	6a 00                	push   $0x0
  pushl $83
80105849:	6a 53                	push   $0x53
  jmp alltraps
8010584b:	e9 e1 f8 ff ff       	jmp    80105131 <alltraps>

80105850 <vector84>:
.globl vector84
vector84:
  pushl $0
80105850:	6a 00                	push   $0x0
  pushl $84
80105852:	6a 54                	push   $0x54
  jmp alltraps
80105854:	e9 d8 f8 ff ff       	jmp    80105131 <alltraps>

80105859 <vector85>:
.globl vector85
vector85:
  pushl $0
80105859:	6a 00                	push   $0x0
  pushl $85
8010585b:	6a 55                	push   $0x55
  jmp alltraps
8010585d:	e9 cf f8 ff ff       	jmp    80105131 <alltraps>

80105862 <vector86>:
.globl vector86
vector86:
  pushl $0
80105862:	6a 00                	push   $0x0
  pushl $86
80105864:	6a 56                	push   $0x56
  jmp alltraps
80105866:	e9 c6 f8 ff ff       	jmp    80105131 <alltraps>

8010586b <vector87>:
.globl vector87
vector87:
  pushl $0
8010586b:	6a 00                	push   $0x0
  pushl $87
8010586d:	6a 57                	push   $0x57
  jmp alltraps
8010586f:	e9 bd f8 ff ff       	jmp    80105131 <alltraps>

80105874 <vector88>:
.globl vector88
vector88:
  pushl $0
80105874:	6a 00                	push   $0x0
  pushl $88
80105876:	6a 58                	push   $0x58
  jmp alltraps
80105878:	e9 b4 f8 ff ff       	jmp    80105131 <alltraps>

8010587d <vector89>:
.globl vector89
vector89:
  pushl $0
8010587d:	6a 00                	push   $0x0
  pushl $89
8010587f:	6a 59                	push   $0x59
  jmp alltraps
80105881:	e9 ab f8 ff ff       	jmp    80105131 <alltraps>

80105886 <vector90>:
.globl vector90
vector90:
  pushl $0
80105886:	6a 00                	push   $0x0
  pushl $90
80105888:	6a 5a                	push   $0x5a
  jmp alltraps
8010588a:	e9 a2 f8 ff ff       	jmp    80105131 <alltraps>

8010588f <vector91>:
.globl vector91
vector91:
  pushl $0
8010588f:	6a 00                	push   $0x0
  pushl $91
80105891:	6a 5b                	push   $0x5b
  jmp alltraps
80105893:	e9 99 f8 ff ff       	jmp    80105131 <alltraps>

80105898 <vector92>:
.globl vector92
vector92:
  pushl $0
80105898:	6a 00                	push   $0x0
  pushl $92
8010589a:	6a 5c                	push   $0x5c
  jmp alltraps
8010589c:	e9 90 f8 ff ff       	jmp    80105131 <alltraps>

801058a1 <vector93>:
.globl vector93
vector93:
  pushl $0
801058a1:	6a 00                	push   $0x0
  pushl $93
801058a3:	6a 5d                	push   $0x5d
  jmp alltraps
801058a5:	e9 87 f8 ff ff       	jmp    80105131 <alltraps>

801058aa <vector94>:
.globl vector94
vector94:
  pushl $0
801058aa:	6a 00                	push   $0x0
  pushl $94
801058ac:	6a 5e                	push   $0x5e
  jmp alltraps
801058ae:	e9 7e f8 ff ff       	jmp    80105131 <alltraps>

801058b3 <vector95>:
.globl vector95
vector95:
  pushl $0
801058b3:	6a 00                	push   $0x0
  pushl $95
801058b5:	6a 5f                	push   $0x5f
  jmp alltraps
801058b7:	e9 75 f8 ff ff       	jmp    80105131 <alltraps>

801058bc <vector96>:
.globl vector96
vector96:
  pushl $0
801058bc:	6a 00                	push   $0x0
  pushl $96
801058be:	6a 60                	push   $0x60
  jmp alltraps
801058c0:	e9 6c f8 ff ff       	jmp    80105131 <alltraps>

801058c5 <vector97>:
.globl vector97
vector97:
  pushl $0
801058c5:	6a 00                	push   $0x0
  pushl $97
801058c7:	6a 61                	push   $0x61
  jmp alltraps
801058c9:	e9 63 f8 ff ff       	jmp    80105131 <alltraps>

801058ce <vector98>:
.globl vector98
vector98:
  pushl $0
801058ce:	6a 00                	push   $0x0
  pushl $98
801058d0:	6a 62                	push   $0x62
  jmp alltraps
801058d2:	e9 5a f8 ff ff       	jmp    80105131 <alltraps>

801058d7 <vector99>:
.globl vector99
vector99:
  pushl $0
801058d7:	6a 00                	push   $0x0
  pushl $99
801058d9:	6a 63                	push   $0x63
  jmp alltraps
801058db:	e9 51 f8 ff ff       	jmp    80105131 <alltraps>

801058e0 <vector100>:
.globl vector100
vector100:
  pushl $0
801058e0:	6a 00                	push   $0x0
  pushl $100
801058e2:	6a 64                	push   $0x64
  jmp alltraps
801058e4:	e9 48 f8 ff ff       	jmp    80105131 <alltraps>

801058e9 <vector101>:
.globl vector101
vector101:
  pushl $0
801058e9:	6a 00                	push   $0x0
  pushl $101
801058eb:	6a 65                	push   $0x65
  jmp alltraps
801058ed:	e9 3f f8 ff ff       	jmp    80105131 <alltraps>

801058f2 <vector102>:
.globl vector102
vector102:
  pushl $0
801058f2:	6a 00                	push   $0x0
  pushl $102
801058f4:	6a 66                	push   $0x66
  jmp alltraps
801058f6:	e9 36 f8 ff ff       	jmp    80105131 <alltraps>

801058fb <vector103>:
.globl vector103
vector103:
  pushl $0
801058fb:	6a 00                	push   $0x0
  pushl $103
801058fd:	6a 67                	push   $0x67
  jmp alltraps
801058ff:	e9 2d f8 ff ff       	jmp    80105131 <alltraps>

80105904 <vector104>:
.globl vector104
vector104:
  pushl $0
80105904:	6a 00                	push   $0x0
  pushl $104
80105906:	6a 68                	push   $0x68
  jmp alltraps
80105908:	e9 24 f8 ff ff       	jmp    80105131 <alltraps>

8010590d <vector105>:
.globl vector105
vector105:
  pushl $0
8010590d:	6a 00                	push   $0x0
  pushl $105
8010590f:	6a 69                	push   $0x69
  jmp alltraps
80105911:	e9 1b f8 ff ff       	jmp    80105131 <alltraps>

80105916 <vector106>:
.globl vector106
vector106:
  pushl $0
80105916:	6a 00                	push   $0x0
  pushl $106
80105918:	6a 6a                	push   $0x6a
  jmp alltraps
8010591a:	e9 12 f8 ff ff       	jmp    80105131 <alltraps>

8010591f <vector107>:
.globl vector107
vector107:
  pushl $0
8010591f:	6a 00                	push   $0x0
  pushl $107
80105921:	6a 6b                	push   $0x6b
  jmp alltraps
80105923:	e9 09 f8 ff ff       	jmp    80105131 <alltraps>

80105928 <vector108>:
.globl vector108
vector108:
  pushl $0
80105928:	6a 00                	push   $0x0
  pushl $108
8010592a:	6a 6c                	push   $0x6c
  jmp alltraps
8010592c:	e9 00 f8 ff ff       	jmp    80105131 <alltraps>

80105931 <vector109>:
.globl vector109
vector109:
  pushl $0
80105931:	6a 00                	push   $0x0
  pushl $109
80105933:	6a 6d                	push   $0x6d
  jmp alltraps
80105935:	e9 f7 f7 ff ff       	jmp    80105131 <alltraps>

8010593a <vector110>:
.globl vector110
vector110:
  pushl $0
8010593a:	6a 00                	push   $0x0
  pushl $110
8010593c:	6a 6e                	push   $0x6e
  jmp alltraps
8010593e:	e9 ee f7 ff ff       	jmp    80105131 <alltraps>

80105943 <vector111>:
.globl vector111
vector111:
  pushl $0
80105943:	6a 00                	push   $0x0
  pushl $111
80105945:	6a 6f                	push   $0x6f
  jmp alltraps
80105947:	e9 e5 f7 ff ff       	jmp    80105131 <alltraps>

8010594c <vector112>:
.globl vector112
vector112:
  pushl $0
8010594c:	6a 00                	push   $0x0
  pushl $112
8010594e:	6a 70                	push   $0x70
  jmp alltraps
80105950:	e9 dc f7 ff ff       	jmp    80105131 <alltraps>

80105955 <vector113>:
.globl vector113
vector113:
  pushl $0
80105955:	6a 00                	push   $0x0
  pushl $113
80105957:	6a 71                	push   $0x71
  jmp alltraps
80105959:	e9 d3 f7 ff ff       	jmp    80105131 <alltraps>

8010595e <vector114>:
.globl vector114
vector114:
  pushl $0
8010595e:	6a 00                	push   $0x0
  pushl $114
80105960:	6a 72                	push   $0x72
  jmp alltraps
80105962:	e9 ca f7 ff ff       	jmp    80105131 <alltraps>

80105967 <vector115>:
.globl vector115
vector115:
  pushl $0
80105967:	6a 00                	push   $0x0
  pushl $115
80105969:	6a 73                	push   $0x73
  jmp alltraps
8010596b:	e9 c1 f7 ff ff       	jmp    80105131 <alltraps>

80105970 <vector116>:
.globl vector116
vector116:
  pushl $0
80105970:	6a 00                	push   $0x0
  pushl $116
80105972:	6a 74                	push   $0x74
  jmp alltraps
80105974:	e9 b8 f7 ff ff       	jmp    80105131 <alltraps>

80105979 <vector117>:
.globl vector117
vector117:
  pushl $0
80105979:	6a 00                	push   $0x0
  pushl $117
8010597b:	6a 75                	push   $0x75
  jmp alltraps
8010597d:	e9 af f7 ff ff       	jmp    80105131 <alltraps>

80105982 <vector118>:
.globl vector118
vector118:
  pushl $0
80105982:	6a 00                	push   $0x0
  pushl $118
80105984:	6a 76                	push   $0x76
  jmp alltraps
80105986:	e9 a6 f7 ff ff       	jmp    80105131 <alltraps>

8010598b <vector119>:
.globl vector119
vector119:
  pushl $0
8010598b:	6a 00                	push   $0x0
  pushl $119
8010598d:	6a 77                	push   $0x77
  jmp alltraps
8010598f:	e9 9d f7 ff ff       	jmp    80105131 <alltraps>

80105994 <vector120>:
.globl vector120
vector120:
  pushl $0
80105994:	6a 00                	push   $0x0
  pushl $120
80105996:	6a 78                	push   $0x78
  jmp alltraps
80105998:	e9 94 f7 ff ff       	jmp    80105131 <alltraps>

8010599d <vector121>:
.globl vector121
vector121:
  pushl $0
8010599d:	6a 00                	push   $0x0
  pushl $121
8010599f:	6a 79                	push   $0x79
  jmp alltraps
801059a1:	e9 8b f7 ff ff       	jmp    80105131 <alltraps>

801059a6 <vector122>:
.globl vector122
vector122:
  pushl $0
801059a6:	6a 00                	push   $0x0
  pushl $122
801059a8:	6a 7a                	push   $0x7a
  jmp alltraps
801059aa:	e9 82 f7 ff ff       	jmp    80105131 <alltraps>

801059af <vector123>:
.globl vector123
vector123:
  pushl $0
801059af:	6a 00                	push   $0x0
  pushl $123
801059b1:	6a 7b                	push   $0x7b
  jmp alltraps
801059b3:	e9 79 f7 ff ff       	jmp    80105131 <alltraps>

801059b8 <vector124>:
.globl vector124
vector124:
  pushl $0
801059b8:	6a 00                	push   $0x0
  pushl $124
801059ba:	6a 7c                	push   $0x7c
  jmp alltraps
801059bc:	e9 70 f7 ff ff       	jmp    80105131 <alltraps>

801059c1 <vector125>:
.globl vector125
vector125:
  pushl $0
801059c1:	6a 00                	push   $0x0
  pushl $125
801059c3:	6a 7d                	push   $0x7d
  jmp alltraps
801059c5:	e9 67 f7 ff ff       	jmp    80105131 <alltraps>

801059ca <vector126>:
.globl vector126
vector126:
  pushl $0
801059ca:	6a 00                	push   $0x0
  pushl $126
801059cc:	6a 7e                	push   $0x7e
  jmp alltraps
801059ce:	e9 5e f7 ff ff       	jmp    80105131 <alltraps>

801059d3 <vector127>:
.globl vector127
vector127:
  pushl $0
801059d3:	6a 00                	push   $0x0
  pushl $127
801059d5:	6a 7f                	push   $0x7f
  jmp alltraps
801059d7:	e9 55 f7 ff ff       	jmp    80105131 <alltraps>

801059dc <vector128>:
.globl vector128
vector128:
  pushl $0
801059dc:	6a 00                	push   $0x0
  pushl $128
801059de:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801059e3:	e9 49 f7 ff ff       	jmp    80105131 <alltraps>

801059e8 <vector129>:
.globl vector129
vector129:
  pushl $0
801059e8:	6a 00                	push   $0x0
  pushl $129
801059ea:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801059ef:	e9 3d f7 ff ff       	jmp    80105131 <alltraps>

801059f4 <vector130>:
.globl vector130
vector130:
  pushl $0
801059f4:	6a 00                	push   $0x0
  pushl $130
801059f6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801059fb:	e9 31 f7 ff ff       	jmp    80105131 <alltraps>

80105a00 <vector131>:
.globl vector131
vector131:
  pushl $0
80105a00:	6a 00                	push   $0x0
  pushl $131
80105a02:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105a07:	e9 25 f7 ff ff       	jmp    80105131 <alltraps>

80105a0c <vector132>:
.globl vector132
vector132:
  pushl $0
80105a0c:	6a 00                	push   $0x0
  pushl $132
80105a0e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105a13:	e9 19 f7 ff ff       	jmp    80105131 <alltraps>

80105a18 <vector133>:
.globl vector133
vector133:
  pushl $0
80105a18:	6a 00                	push   $0x0
  pushl $133
80105a1a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105a1f:	e9 0d f7 ff ff       	jmp    80105131 <alltraps>

80105a24 <vector134>:
.globl vector134
vector134:
  pushl $0
80105a24:	6a 00                	push   $0x0
  pushl $134
80105a26:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105a2b:	e9 01 f7 ff ff       	jmp    80105131 <alltraps>

80105a30 <vector135>:
.globl vector135
vector135:
  pushl $0
80105a30:	6a 00                	push   $0x0
  pushl $135
80105a32:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105a37:	e9 f5 f6 ff ff       	jmp    80105131 <alltraps>

80105a3c <vector136>:
.globl vector136
vector136:
  pushl $0
80105a3c:	6a 00                	push   $0x0
  pushl $136
80105a3e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105a43:	e9 e9 f6 ff ff       	jmp    80105131 <alltraps>

80105a48 <vector137>:
.globl vector137
vector137:
  pushl $0
80105a48:	6a 00                	push   $0x0
  pushl $137
80105a4a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105a4f:	e9 dd f6 ff ff       	jmp    80105131 <alltraps>

80105a54 <vector138>:
.globl vector138
vector138:
  pushl $0
80105a54:	6a 00                	push   $0x0
  pushl $138
80105a56:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105a5b:	e9 d1 f6 ff ff       	jmp    80105131 <alltraps>

80105a60 <vector139>:
.globl vector139
vector139:
  pushl $0
80105a60:	6a 00                	push   $0x0
  pushl $139
80105a62:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105a67:	e9 c5 f6 ff ff       	jmp    80105131 <alltraps>

80105a6c <vector140>:
.globl vector140
vector140:
  pushl $0
80105a6c:	6a 00                	push   $0x0
  pushl $140
80105a6e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105a73:	e9 b9 f6 ff ff       	jmp    80105131 <alltraps>

80105a78 <vector141>:
.globl vector141
vector141:
  pushl $0
80105a78:	6a 00                	push   $0x0
  pushl $141
80105a7a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105a7f:	e9 ad f6 ff ff       	jmp    80105131 <alltraps>

80105a84 <vector142>:
.globl vector142
vector142:
  pushl $0
80105a84:	6a 00                	push   $0x0
  pushl $142
80105a86:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105a8b:	e9 a1 f6 ff ff       	jmp    80105131 <alltraps>

80105a90 <vector143>:
.globl vector143
vector143:
  pushl $0
80105a90:	6a 00                	push   $0x0
  pushl $143
80105a92:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105a97:	e9 95 f6 ff ff       	jmp    80105131 <alltraps>

80105a9c <vector144>:
.globl vector144
vector144:
  pushl $0
80105a9c:	6a 00                	push   $0x0
  pushl $144
80105a9e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105aa3:	e9 89 f6 ff ff       	jmp    80105131 <alltraps>

80105aa8 <vector145>:
.globl vector145
vector145:
  pushl $0
80105aa8:	6a 00                	push   $0x0
  pushl $145
80105aaa:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105aaf:	e9 7d f6 ff ff       	jmp    80105131 <alltraps>

80105ab4 <vector146>:
.globl vector146
vector146:
  pushl $0
80105ab4:	6a 00                	push   $0x0
  pushl $146
80105ab6:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105abb:	e9 71 f6 ff ff       	jmp    80105131 <alltraps>

80105ac0 <vector147>:
.globl vector147
vector147:
  pushl $0
80105ac0:	6a 00                	push   $0x0
  pushl $147
80105ac2:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105ac7:	e9 65 f6 ff ff       	jmp    80105131 <alltraps>

80105acc <vector148>:
.globl vector148
vector148:
  pushl $0
80105acc:	6a 00                	push   $0x0
  pushl $148
80105ace:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105ad3:	e9 59 f6 ff ff       	jmp    80105131 <alltraps>

80105ad8 <vector149>:
.globl vector149
vector149:
  pushl $0
80105ad8:	6a 00                	push   $0x0
  pushl $149
80105ada:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105adf:	e9 4d f6 ff ff       	jmp    80105131 <alltraps>

80105ae4 <vector150>:
.globl vector150
vector150:
  pushl $0
80105ae4:	6a 00                	push   $0x0
  pushl $150
80105ae6:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105aeb:	e9 41 f6 ff ff       	jmp    80105131 <alltraps>

80105af0 <vector151>:
.globl vector151
vector151:
  pushl $0
80105af0:	6a 00                	push   $0x0
  pushl $151
80105af2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105af7:	e9 35 f6 ff ff       	jmp    80105131 <alltraps>

80105afc <vector152>:
.globl vector152
vector152:
  pushl $0
80105afc:	6a 00                	push   $0x0
  pushl $152
80105afe:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105b03:	e9 29 f6 ff ff       	jmp    80105131 <alltraps>

80105b08 <vector153>:
.globl vector153
vector153:
  pushl $0
80105b08:	6a 00                	push   $0x0
  pushl $153
80105b0a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105b0f:	e9 1d f6 ff ff       	jmp    80105131 <alltraps>

80105b14 <vector154>:
.globl vector154
vector154:
  pushl $0
80105b14:	6a 00                	push   $0x0
  pushl $154
80105b16:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105b1b:	e9 11 f6 ff ff       	jmp    80105131 <alltraps>

80105b20 <vector155>:
.globl vector155
vector155:
  pushl $0
80105b20:	6a 00                	push   $0x0
  pushl $155
80105b22:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105b27:	e9 05 f6 ff ff       	jmp    80105131 <alltraps>

80105b2c <vector156>:
.globl vector156
vector156:
  pushl $0
80105b2c:	6a 00                	push   $0x0
  pushl $156
80105b2e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105b33:	e9 f9 f5 ff ff       	jmp    80105131 <alltraps>

80105b38 <vector157>:
.globl vector157
vector157:
  pushl $0
80105b38:	6a 00                	push   $0x0
  pushl $157
80105b3a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105b3f:	e9 ed f5 ff ff       	jmp    80105131 <alltraps>

80105b44 <vector158>:
.globl vector158
vector158:
  pushl $0
80105b44:	6a 00                	push   $0x0
  pushl $158
80105b46:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105b4b:	e9 e1 f5 ff ff       	jmp    80105131 <alltraps>

80105b50 <vector159>:
.globl vector159
vector159:
  pushl $0
80105b50:	6a 00                	push   $0x0
  pushl $159
80105b52:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105b57:	e9 d5 f5 ff ff       	jmp    80105131 <alltraps>

80105b5c <vector160>:
.globl vector160
vector160:
  pushl $0
80105b5c:	6a 00                	push   $0x0
  pushl $160
80105b5e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105b63:	e9 c9 f5 ff ff       	jmp    80105131 <alltraps>

80105b68 <vector161>:
.globl vector161
vector161:
  pushl $0
80105b68:	6a 00                	push   $0x0
  pushl $161
80105b6a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105b6f:	e9 bd f5 ff ff       	jmp    80105131 <alltraps>

80105b74 <vector162>:
.globl vector162
vector162:
  pushl $0
80105b74:	6a 00                	push   $0x0
  pushl $162
80105b76:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105b7b:	e9 b1 f5 ff ff       	jmp    80105131 <alltraps>

80105b80 <vector163>:
.globl vector163
vector163:
  pushl $0
80105b80:	6a 00                	push   $0x0
  pushl $163
80105b82:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105b87:	e9 a5 f5 ff ff       	jmp    80105131 <alltraps>

80105b8c <vector164>:
.globl vector164
vector164:
  pushl $0
80105b8c:	6a 00                	push   $0x0
  pushl $164
80105b8e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105b93:	e9 99 f5 ff ff       	jmp    80105131 <alltraps>

80105b98 <vector165>:
.globl vector165
vector165:
  pushl $0
80105b98:	6a 00                	push   $0x0
  pushl $165
80105b9a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105b9f:	e9 8d f5 ff ff       	jmp    80105131 <alltraps>

80105ba4 <vector166>:
.globl vector166
vector166:
  pushl $0
80105ba4:	6a 00                	push   $0x0
  pushl $166
80105ba6:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105bab:	e9 81 f5 ff ff       	jmp    80105131 <alltraps>

80105bb0 <vector167>:
.globl vector167
vector167:
  pushl $0
80105bb0:	6a 00                	push   $0x0
  pushl $167
80105bb2:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105bb7:	e9 75 f5 ff ff       	jmp    80105131 <alltraps>

80105bbc <vector168>:
.globl vector168
vector168:
  pushl $0
80105bbc:	6a 00                	push   $0x0
  pushl $168
80105bbe:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105bc3:	e9 69 f5 ff ff       	jmp    80105131 <alltraps>

80105bc8 <vector169>:
.globl vector169
vector169:
  pushl $0
80105bc8:	6a 00                	push   $0x0
  pushl $169
80105bca:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105bcf:	e9 5d f5 ff ff       	jmp    80105131 <alltraps>

80105bd4 <vector170>:
.globl vector170
vector170:
  pushl $0
80105bd4:	6a 00                	push   $0x0
  pushl $170
80105bd6:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105bdb:	e9 51 f5 ff ff       	jmp    80105131 <alltraps>

80105be0 <vector171>:
.globl vector171
vector171:
  pushl $0
80105be0:	6a 00                	push   $0x0
  pushl $171
80105be2:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105be7:	e9 45 f5 ff ff       	jmp    80105131 <alltraps>

80105bec <vector172>:
.globl vector172
vector172:
  pushl $0
80105bec:	6a 00                	push   $0x0
  pushl $172
80105bee:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105bf3:	e9 39 f5 ff ff       	jmp    80105131 <alltraps>

80105bf8 <vector173>:
.globl vector173
vector173:
  pushl $0
80105bf8:	6a 00                	push   $0x0
  pushl $173
80105bfa:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105bff:	e9 2d f5 ff ff       	jmp    80105131 <alltraps>

80105c04 <vector174>:
.globl vector174
vector174:
  pushl $0
80105c04:	6a 00                	push   $0x0
  pushl $174
80105c06:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105c0b:	e9 21 f5 ff ff       	jmp    80105131 <alltraps>

80105c10 <vector175>:
.globl vector175
vector175:
  pushl $0
80105c10:	6a 00                	push   $0x0
  pushl $175
80105c12:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105c17:	e9 15 f5 ff ff       	jmp    80105131 <alltraps>

80105c1c <vector176>:
.globl vector176
vector176:
  pushl $0
80105c1c:	6a 00                	push   $0x0
  pushl $176
80105c1e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105c23:	e9 09 f5 ff ff       	jmp    80105131 <alltraps>

80105c28 <vector177>:
.globl vector177
vector177:
  pushl $0
80105c28:	6a 00                	push   $0x0
  pushl $177
80105c2a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105c2f:	e9 fd f4 ff ff       	jmp    80105131 <alltraps>

80105c34 <vector178>:
.globl vector178
vector178:
  pushl $0
80105c34:	6a 00                	push   $0x0
  pushl $178
80105c36:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105c3b:	e9 f1 f4 ff ff       	jmp    80105131 <alltraps>

80105c40 <vector179>:
.globl vector179
vector179:
  pushl $0
80105c40:	6a 00                	push   $0x0
  pushl $179
80105c42:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105c47:	e9 e5 f4 ff ff       	jmp    80105131 <alltraps>

80105c4c <vector180>:
.globl vector180
vector180:
  pushl $0
80105c4c:	6a 00                	push   $0x0
  pushl $180
80105c4e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105c53:	e9 d9 f4 ff ff       	jmp    80105131 <alltraps>

80105c58 <vector181>:
.globl vector181
vector181:
  pushl $0
80105c58:	6a 00                	push   $0x0
  pushl $181
80105c5a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105c5f:	e9 cd f4 ff ff       	jmp    80105131 <alltraps>

80105c64 <vector182>:
.globl vector182
vector182:
  pushl $0
80105c64:	6a 00                	push   $0x0
  pushl $182
80105c66:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105c6b:	e9 c1 f4 ff ff       	jmp    80105131 <alltraps>

80105c70 <vector183>:
.globl vector183
vector183:
  pushl $0
80105c70:	6a 00                	push   $0x0
  pushl $183
80105c72:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105c77:	e9 b5 f4 ff ff       	jmp    80105131 <alltraps>

80105c7c <vector184>:
.globl vector184
vector184:
  pushl $0
80105c7c:	6a 00                	push   $0x0
  pushl $184
80105c7e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105c83:	e9 a9 f4 ff ff       	jmp    80105131 <alltraps>

80105c88 <vector185>:
.globl vector185
vector185:
  pushl $0
80105c88:	6a 00                	push   $0x0
  pushl $185
80105c8a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105c8f:	e9 9d f4 ff ff       	jmp    80105131 <alltraps>

80105c94 <vector186>:
.globl vector186
vector186:
  pushl $0
80105c94:	6a 00                	push   $0x0
  pushl $186
80105c96:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105c9b:	e9 91 f4 ff ff       	jmp    80105131 <alltraps>

80105ca0 <vector187>:
.globl vector187
vector187:
  pushl $0
80105ca0:	6a 00                	push   $0x0
  pushl $187
80105ca2:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105ca7:	e9 85 f4 ff ff       	jmp    80105131 <alltraps>

80105cac <vector188>:
.globl vector188
vector188:
  pushl $0
80105cac:	6a 00                	push   $0x0
  pushl $188
80105cae:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105cb3:	e9 79 f4 ff ff       	jmp    80105131 <alltraps>

80105cb8 <vector189>:
.globl vector189
vector189:
  pushl $0
80105cb8:	6a 00                	push   $0x0
  pushl $189
80105cba:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105cbf:	e9 6d f4 ff ff       	jmp    80105131 <alltraps>

80105cc4 <vector190>:
.globl vector190
vector190:
  pushl $0
80105cc4:	6a 00                	push   $0x0
  pushl $190
80105cc6:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105ccb:	e9 61 f4 ff ff       	jmp    80105131 <alltraps>

80105cd0 <vector191>:
.globl vector191
vector191:
  pushl $0
80105cd0:	6a 00                	push   $0x0
  pushl $191
80105cd2:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105cd7:	e9 55 f4 ff ff       	jmp    80105131 <alltraps>

80105cdc <vector192>:
.globl vector192
vector192:
  pushl $0
80105cdc:	6a 00                	push   $0x0
  pushl $192
80105cde:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105ce3:	e9 49 f4 ff ff       	jmp    80105131 <alltraps>

80105ce8 <vector193>:
.globl vector193
vector193:
  pushl $0
80105ce8:	6a 00                	push   $0x0
  pushl $193
80105cea:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105cef:	e9 3d f4 ff ff       	jmp    80105131 <alltraps>

80105cf4 <vector194>:
.globl vector194
vector194:
  pushl $0
80105cf4:	6a 00                	push   $0x0
  pushl $194
80105cf6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105cfb:	e9 31 f4 ff ff       	jmp    80105131 <alltraps>

80105d00 <vector195>:
.globl vector195
vector195:
  pushl $0
80105d00:	6a 00                	push   $0x0
  pushl $195
80105d02:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105d07:	e9 25 f4 ff ff       	jmp    80105131 <alltraps>

80105d0c <vector196>:
.globl vector196
vector196:
  pushl $0
80105d0c:	6a 00                	push   $0x0
  pushl $196
80105d0e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105d13:	e9 19 f4 ff ff       	jmp    80105131 <alltraps>

80105d18 <vector197>:
.globl vector197
vector197:
  pushl $0
80105d18:	6a 00                	push   $0x0
  pushl $197
80105d1a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105d1f:	e9 0d f4 ff ff       	jmp    80105131 <alltraps>

80105d24 <vector198>:
.globl vector198
vector198:
  pushl $0
80105d24:	6a 00                	push   $0x0
  pushl $198
80105d26:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105d2b:	e9 01 f4 ff ff       	jmp    80105131 <alltraps>

80105d30 <vector199>:
.globl vector199
vector199:
  pushl $0
80105d30:	6a 00                	push   $0x0
  pushl $199
80105d32:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105d37:	e9 f5 f3 ff ff       	jmp    80105131 <alltraps>

80105d3c <vector200>:
.globl vector200
vector200:
  pushl $0
80105d3c:	6a 00                	push   $0x0
  pushl $200
80105d3e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105d43:	e9 e9 f3 ff ff       	jmp    80105131 <alltraps>

80105d48 <vector201>:
.globl vector201
vector201:
  pushl $0
80105d48:	6a 00                	push   $0x0
  pushl $201
80105d4a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105d4f:	e9 dd f3 ff ff       	jmp    80105131 <alltraps>

80105d54 <vector202>:
.globl vector202
vector202:
  pushl $0
80105d54:	6a 00                	push   $0x0
  pushl $202
80105d56:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105d5b:	e9 d1 f3 ff ff       	jmp    80105131 <alltraps>

80105d60 <vector203>:
.globl vector203
vector203:
  pushl $0
80105d60:	6a 00                	push   $0x0
  pushl $203
80105d62:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105d67:	e9 c5 f3 ff ff       	jmp    80105131 <alltraps>

80105d6c <vector204>:
.globl vector204
vector204:
  pushl $0
80105d6c:	6a 00                	push   $0x0
  pushl $204
80105d6e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105d73:	e9 b9 f3 ff ff       	jmp    80105131 <alltraps>

80105d78 <vector205>:
.globl vector205
vector205:
  pushl $0
80105d78:	6a 00                	push   $0x0
  pushl $205
80105d7a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105d7f:	e9 ad f3 ff ff       	jmp    80105131 <alltraps>

80105d84 <vector206>:
.globl vector206
vector206:
  pushl $0
80105d84:	6a 00                	push   $0x0
  pushl $206
80105d86:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105d8b:	e9 a1 f3 ff ff       	jmp    80105131 <alltraps>

80105d90 <vector207>:
.globl vector207
vector207:
  pushl $0
80105d90:	6a 00                	push   $0x0
  pushl $207
80105d92:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105d97:	e9 95 f3 ff ff       	jmp    80105131 <alltraps>

80105d9c <vector208>:
.globl vector208
vector208:
  pushl $0
80105d9c:	6a 00                	push   $0x0
  pushl $208
80105d9e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105da3:	e9 89 f3 ff ff       	jmp    80105131 <alltraps>

80105da8 <vector209>:
.globl vector209
vector209:
  pushl $0
80105da8:	6a 00                	push   $0x0
  pushl $209
80105daa:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105daf:	e9 7d f3 ff ff       	jmp    80105131 <alltraps>

80105db4 <vector210>:
.globl vector210
vector210:
  pushl $0
80105db4:	6a 00                	push   $0x0
  pushl $210
80105db6:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105dbb:	e9 71 f3 ff ff       	jmp    80105131 <alltraps>

80105dc0 <vector211>:
.globl vector211
vector211:
  pushl $0
80105dc0:	6a 00                	push   $0x0
  pushl $211
80105dc2:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105dc7:	e9 65 f3 ff ff       	jmp    80105131 <alltraps>

80105dcc <vector212>:
.globl vector212
vector212:
  pushl $0
80105dcc:	6a 00                	push   $0x0
  pushl $212
80105dce:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105dd3:	e9 59 f3 ff ff       	jmp    80105131 <alltraps>

80105dd8 <vector213>:
.globl vector213
vector213:
  pushl $0
80105dd8:	6a 00                	push   $0x0
  pushl $213
80105dda:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105ddf:	e9 4d f3 ff ff       	jmp    80105131 <alltraps>

80105de4 <vector214>:
.globl vector214
vector214:
  pushl $0
80105de4:	6a 00                	push   $0x0
  pushl $214
80105de6:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105deb:	e9 41 f3 ff ff       	jmp    80105131 <alltraps>

80105df0 <vector215>:
.globl vector215
vector215:
  pushl $0
80105df0:	6a 00                	push   $0x0
  pushl $215
80105df2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105df7:	e9 35 f3 ff ff       	jmp    80105131 <alltraps>

80105dfc <vector216>:
.globl vector216
vector216:
  pushl $0
80105dfc:	6a 00                	push   $0x0
  pushl $216
80105dfe:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105e03:	e9 29 f3 ff ff       	jmp    80105131 <alltraps>

80105e08 <vector217>:
.globl vector217
vector217:
  pushl $0
80105e08:	6a 00                	push   $0x0
  pushl $217
80105e0a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105e0f:	e9 1d f3 ff ff       	jmp    80105131 <alltraps>

80105e14 <vector218>:
.globl vector218
vector218:
  pushl $0
80105e14:	6a 00                	push   $0x0
  pushl $218
80105e16:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105e1b:	e9 11 f3 ff ff       	jmp    80105131 <alltraps>

80105e20 <vector219>:
.globl vector219
vector219:
  pushl $0
80105e20:	6a 00                	push   $0x0
  pushl $219
80105e22:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105e27:	e9 05 f3 ff ff       	jmp    80105131 <alltraps>

80105e2c <vector220>:
.globl vector220
vector220:
  pushl $0
80105e2c:	6a 00                	push   $0x0
  pushl $220
80105e2e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105e33:	e9 f9 f2 ff ff       	jmp    80105131 <alltraps>

80105e38 <vector221>:
.globl vector221
vector221:
  pushl $0
80105e38:	6a 00                	push   $0x0
  pushl $221
80105e3a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105e3f:	e9 ed f2 ff ff       	jmp    80105131 <alltraps>

80105e44 <vector222>:
.globl vector222
vector222:
  pushl $0
80105e44:	6a 00                	push   $0x0
  pushl $222
80105e46:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105e4b:	e9 e1 f2 ff ff       	jmp    80105131 <alltraps>

80105e50 <vector223>:
.globl vector223
vector223:
  pushl $0
80105e50:	6a 00                	push   $0x0
  pushl $223
80105e52:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105e57:	e9 d5 f2 ff ff       	jmp    80105131 <alltraps>

80105e5c <vector224>:
.globl vector224
vector224:
  pushl $0
80105e5c:	6a 00                	push   $0x0
  pushl $224
80105e5e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105e63:	e9 c9 f2 ff ff       	jmp    80105131 <alltraps>

80105e68 <vector225>:
.globl vector225
vector225:
  pushl $0
80105e68:	6a 00                	push   $0x0
  pushl $225
80105e6a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105e6f:	e9 bd f2 ff ff       	jmp    80105131 <alltraps>

80105e74 <vector226>:
.globl vector226
vector226:
  pushl $0
80105e74:	6a 00                	push   $0x0
  pushl $226
80105e76:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105e7b:	e9 b1 f2 ff ff       	jmp    80105131 <alltraps>

80105e80 <vector227>:
.globl vector227
vector227:
  pushl $0
80105e80:	6a 00                	push   $0x0
  pushl $227
80105e82:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105e87:	e9 a5 f2 ff ff       	jmp    80105131 <alltraps>

80105e8c <vector228>:
.globl vector228
vector228:
  pushl $0
80105e8c:	6a 00                	push   $0x0
  pushl $228
80105e8e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105e93:	e9 99 f2 ff ff       	jmp    80105131 <alltraps>

80105e98 <vector229>:
.globl vector229
vector229:
  pushl $0
80105e98:	6a 00                	push   $0x0
  pushl $229
80105e9a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105e9f:	e9 8d f2 ff ff       	jmp    80105131 <alltraps>

80105ea4 <vector230>:
.globl vector230
vector230:
  pushl $0
80105ea4:	6a 00                	push   $0x0
  pushl $230
80105ea6:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105eab:	e9 81 f2 ff ff       	jmp    80105131 <alltraps>

80105eb0 <vector231>:
.globl vector231
vector231:
  pushl $0
80105eb0:	6a 00                	push   $0x0
  pushl $231
80105eb2:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105eb7:	e9 75 f2 ff ff       	jmp    80105131 <alltraps>

80105ebc <vector232>:
.globl vector232
vector232:
  pushl $0
80105ebc:	6a 00                	push   $0x0
  pushl $232
80105ebe:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105ec3:	e9 69 f2 ff ff       	jmp    80105131 <alltraps>

80105ec8 <vector233>:
.globl vector233
vector233:
  pushl $0
80105ec8:	6a 00                	push   $0x0
  pushl $233
80105eca:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105ecf:	e9 5d f2 ff ff       	jmp    80105131 <alltraps>

80105ed4 <vector234>:
.globl vector234
vector234:
  pushl $0
80105ed4:	6a 00                	push   $0x0
  pushl $234
80105ed6:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105edb:	e9 51 f2 ff ff       	jmp    80105131 <alltraps>

80105ee0 <vector235>:
.globl vector235
vector235:
  pushl $0
80105ee0:	6a 00                	push   $0x0
  pushl $235
80105ee2:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105ee7:	e9 45 f2 ff ff       	jmp    80105131 <alltraps>

80105eec <vector236>:
.globl vector236
vector236:
  pushl $0
80105eec:	6a 00                	push   $0x0
  pushl $236
80105eee:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105ef3:	e9 39 f2 ff ff       	jmp    80105131 <alltraps>

80105ef8 <vector237>:
.globl vector237
vector237:
  pushl $0
80105ef8:	6a 00                	push   $0x0
  pushl $237
80105efa:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105eff:	e9 2d f2 ff ff       	jmp    80105131 <alltraps>

80105f04 <vector238>:
.globl vector238
vector238:
  pushl $0
80105f04:	6a 00                	push   $0x0
  pushl $238
80105f06:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105f0b:	e9 21 f2 ff ff       	jmp    80105131 <alltraps>

80105f10 <vector239>:
.globl vector239
vector239:
  pushl $0
80105f10:	6a 00                	push   $0x0
  pushl $239
80105f12:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105f17:	e9 15 f2 ff ff       	jmp    80105131 <alltraps>

80105f1c <vector240>:
.globl vector240
vector240:
  pushl $0
80105f1c:	6a 00                	push   $0x0
  pushl $240
80105f1e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105f23:	e9 09 f2 ff ff       	jmp    80105131 <alltraps>

80105f28 <vector241>:
.globl vector241
vector241:
  pushl $0
80105f28:	6a 00                	push   $0x0
  pushl $241
80105f2a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105f2f:	e9 fd f1 ff ff       	jmp    80105131 <alltraps>

80105f34 <vector242>:
.globl vector242
vector242:
  pushl $0
80105f34:	6a 00                	push   $0x0
  pushl $242
80105f36:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105f3b:	e9 f1 f1 ff ff       	jmp    80105131 <alltraps>

80105f40 <vector243>:
.globl vector243
vector243:
  pushl $0
80105f40:	6a 00                	push   $0x0
  pushl $243
80105f42:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105f47:	e9 e5 f1 ff ff       	jmp    80105131 <alltraps>

80105f4c <vector244>:
.globl vector244
vector244:
  pushl $0
80105f4c:	6a 00                	push   $0x0
  pushl $244
80105f4e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105f53:	e9 d9 f1 ff ff       	jmp    80105131 <alltraps>

80105f58 <vector245>:
.globl vector245
vector245:
  pushl $0
80105f58:	6a 00                	push   $0x0
  pushl $245
80105f5a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105f5f:	e9 cd f1 ff ff       	jmp    80105131 <alltraps>

80105f64 <vector246>:
.globl vector246
vector246:
  pushl $0
80105f64:	6a 00                	push   $0x0
  pushl $246
80105f66:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105f6b:	e9 c1 f1 ff ff       	jmp    80105131 <alltraps>

80105f70 <vector247>:
.globl vector247
vector247:
  pushl $0
80105f70:	6a 00                	push   $0x0
  pushl $247
80105f72:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105f77:	e9 b5 f1 ff ff       	jmp    80105131 <alltraps>

80105f7c <vector248>:
.globl vector248
vector248:
  pushl $0
80105f7c:	6a 00                	push   $0x0
  pushl $248
80105f7e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105f83:	e9 a9 f1 ff ff       	jmp    80105131 <alltraps>

80105f88 <vector249>:
.globl vector249
vector249:
  pushl $0
80105f88:	6a 00                	push   $0x0
  pushl $249
80105f8a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105f8f:	e9 9d f1 ff ff       	jmp    80105131 <alltraps>

80105f94 <vector250>:
.globl vector250
vector250:
  pushl $0
80105f94:	6a 00                	push   $0x0
  pushl $250
80105f96:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105f9b:	e9 91 f1 ff ff       	jmp    80105131 <alltraps>

80105fa0 <vector251>:
.globl vector251
vector251:
  pushl $0
80105fa0:	6a 00                	push   $0x0
  pushl $251
80105fa2:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105fa7:	e9 85 f1 ff ff       	jmp    80105131 <alltraps>

80105fac <vector252>:
.globl vector252
vector252:
  pushl $0
80105fac:	6a 00                	push   $0x0
  pushl $252
80105fae:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105fb3:	e9 79 f1 ff ff       	jmp    80105131 <alltraps>

80105fb8 <vector253>:
.globl vector253
vector253:
  pushl $0
80105fb8:	6a 00                	push   $0x0
  pushl $253
80105fba:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105fbf:	e9 6d f1 ff ff       	jmp    80105131 <alltraps>

80105fc4 <vector254>:
.globl vector254
vector254:
  pushl $0
80105fc4:	6a 00                	push   $0x0
  pushl $254
80105fc6:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105fcb:	e9 61 f1 ff ff       	jmp    80105131 <alltraps>

80105fd0 <vector255>:
.globl vector255
vector255:
  pushl $0
80105fd0:	6a 00                	push   $0x0
  pushl $255
80105fd2:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105fd7:	e9 55 f1 ff ff       	jmp    80105131 <alltraps>

80105fdc <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105fdc:	55                   	push   %ebp
80105fdd:	89 e5                	mov    %esp,%ebp
80105fdf:	57                   	push   %edi
80105fe0:	56                   	push   %esi
80105fe1:	53                   	push   %ebx
80105fe2:	83 ec 0c             	sub    $0xc,%esp
80105fe5:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105fe7:	c1 ea 16             	shr    $0x16,%edx
80105fea:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105fed:	8b 1f                	mov    (%edi),%ebx
80105fef:	f6 c3 01             	test   $0x1,%bl
80105ff2:	74 22                	je     80106016 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105ff4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105ffa:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106000:	c1 ee 0c             	shr    $0xc,%esi
80106003:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80106009:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
8010600c:	89 d8                	mov    %ebx,%eax
8010600e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106011:	5b                   	pop    %ebx
80106012:	5e                   	pop    %esi
80106013:	5f                   	pop    %edi
80106014:	5d                   	pop    %ebp
80106015:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106016:	85 c9                	test   %ecx,%ecx
80106018:	74 2b                	je     80106045 <walkpgdir+0x69>
8010601a:	e8 50 c1 ff ff       	call   8010216f <kalloc>
8010601f:	89 c3                	mov    %eax,%ebx
80106021:	85 c0                	test   %eax,%eax
80106023:	74 e7                	je     8010600c <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80106025:	83 ec 04             	sub    $0x4,%esp
80106028:	68 00 10 00 00       	push   $0x1000
8010602d:	6a 00                	push   $0x0
8010602f:	50                   	push   %eax
80106030:	e8 f7 df ff ff       	call   8010402c <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106035:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010603b:	83 c8 07             	or     $0x7,%eax
8010603e:	89 07                	mov    %eax,(%edi)
80106040:	83 c4 10             	add    $0x10,%esp
80106043:	eb bb                	jmp    80106000 <walkpgdir+0x24>
      return 0;
80106045:	bb 00 00 00 00       	mov    $0x0,%ebx
8010604a:	eb c0                	jmp    8010600c <walkpgdir+0x30>

8010604c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010604c:	55                   	push   %ebp
8010604d:	89 e5                	mov    %esp,%ebp
8010604f:	57                   	push   %edi
80106050:	56                   	push   %esi
80106051:	53                   	push   %ebx
80106052:	83 ec 1c             	sub    $0x1c,%esp
80106055:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106058:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010605b:	89 d3                	mov    %edx,%ebx
8010605d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106063:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106067:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010606d:	b9 01 00 00 00       	mov    $0x1,%ecx
80106072:	89 da                	mov    %ebx,%edx
80106074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106077:	e8 60 ff ff ff       	call   80105fdc <walkpgdir>
8010607c:	85 c0                	test   %eax,%eax
8010607e:	74 2e                	je     801060ae <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80106080:	f6 00 01             	testb  $0x1,(%eax)
80106083:	75 1c                	jne    801060a1 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106085:	89 f2                	mov    %esi,%edx
80106087:	0b 55 0c             	or     0xc(%ebp),%edx
8010608a:	83 ca 01             	or     $0x1,%edx
8010608d:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010608f:	39 fb                	cmp    %edi,%ebx
80106091:	74 28                	je     801060bb <mappages+0x6f>
      break;
    a += PGSIZE;
80106093:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106099:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010609f:	eb cc                	jmp    8010606d <mappages+0x21>
      panic("remap");
801060a1:	83 ec 0c             	sub    $0xc,%esp
801060a4:	68 cc 71 10 80       	push   $0x801071cc
801060a9:	e8 9a a2 ff ff       	call   80100348 <panic>
      return -1;
801060ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801060b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060b6:	5b                   	pop    %ebx
801060b7:	5e                   	pop    %esi
801060b8:	5f                   	pop    %edi
801060b9:	5d                   	pop    %ebp
801060ba:	c3                   	ret    
  return 0;
801060bb:	b8 00 00 00 00       	mov    $0x0,%eax
801060c0:	eb f1                	jmp    801060b3 <mappages+0x67>

801060c2 <seginit>:
{
801060c2:	55                   	push   %ebp
801060c3:	89 e5                	mov    %esp,%ebp
801060c5:	53                   	push   %ebx
801060c6:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
801060c9:	e8 7d d4 ff ff       	call   8010354b <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801060ce:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801060d4:	66 c7 80 98 95 1e 80 	movw   $0xffff,-0x7fe16a68(%eax)
801060db:	ff ff 
801060dd:	66 c7 80 9a 95 1e 80 	movw   $0x0,-0x7fe16a66(%eax)
801060e4:	00 00 
801060e6:	c6 80 9c 95 1e 80 00 	movb   $0x0,-0x7fe16a64(%eax)
801060ed:	0f b6 88 9d 95 1e 80 	movzbl -0x7fe16a63(%eax),%ecx
801060f4:	83 e1 f0             	and    $0xfffffff0,%ecx
801060f7:	83 c9 1a             	or     $0x1a,%ecx
801060fa:	83 e1 9f             	and    $0xffffff9f,%ecx
801060fd:	83 c9 80             	or     $0xffffff80,%ecx
80106100:	88 88 9d 95 1e 80    	mov    %cl,-0x7fe16a63(%eax)
80106106:	0f b6 88 9e 95 1e 80 	movzbl -0x7fe16a62(%eax),%ecx
8010610d:	83 c9 0f             	or     $0xf,%ecx
80106110:	83 e1 cf             	and    $0xffffffcf,%ecx
80106113:	83 c9 c0             	or     $0xffffffc0,%ecx
80106116:	88 88 9e 95 1e 80    	mov    %cl,-0x7fe16a62(%eax)
8010611c:	c6 80 9f 95 1e 80 00 	movb   $0x0,-0x7fe16a61(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106123:	66 c7 80 a0 95 1e 80 	movw   $0xffff,-0x7fe16a60(%eax)
8010612a:	ff ff 
8010612c:	66 c7 80 a2 95 1e 80 	movw   $0x0,-0x7fe16a5e(%eax)
80106133:	00 00 
80106135:	c6 80 a4 95 1e 80 00 	movb   $0x0,-0x7fe16a5c(%eax)
8010613c:	0f b6 88 a5 95 1e 80 	movzbl -0x7fe16a5b(%eax),%ecx
80106143:	83 e1 f0             	and    $0xfffffff0,%ecx
80106146:	83 c9 12             	or     $0x12,%ecx
80106149:	83 e1 9f             	and    $0xffffff9f,%ecx
8010614c:	83 c9 80             	or     $0xffffff80,%ecx
8010614f:	88 88 a5 95 1e 80    	mov    %cl,-0x7fe16a5b(%eax)
80106155:	0f b6 88 a6 95 1e 80 	movzbl -0x7fe16a5a(%eax),%ecx
8010615c:	83 c9 0f             	or     $0xf,%ecx
8010615f:	83 e1 cf             	and    $0xffffffcf,%ecx
80106162:	83 c9 c0             	or     $0xffffffc0,%ecx
80106165:	88 88 a6 95 1e 80    	mov    %cl,-0x7fe16a5a(%eax)
8010616b:	c6 80 a7 95 1e 80 00 	movb   $0x0,-0x7fe16a59(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106172:	66 c7 80 a8 95 1e 80 	movw   $0xffff,-0x7fe16a58(%eax)
80106179:	ff ff 
8010617b:	66 c7 80 aa 95 1e 80 	movw   $0x0,-0x7fe16a56(%eax)
80106182:	00 00 
80106184:	c6 80 ac 95 1e 80 00 	movb   $0x0,-0x7fe16a54(%eax)
8010618b:	c6 80 ad 95 1e 80 fa 	movb   $0xfa,-0x7fe16a53(%eax)
80106192:	0f b6 88 ae 95 1e 80 	movzbl -0x7fe16a52(%eax),%ecx
80106199:	83 c9 0f             	or     $0xf,%ecx
8010619c:	83 e1 cf             	and    $0xffffffcf,%ecx
8010619f:	83 c9 c0             	or     $0xffffffc0,%ecx
801061a2:	88 88 ae 95 1e 80    	mov    %cl,-0x7fe16a52(%eax)
801061a8:	c6 80 af 95 1e 80 00 	movb   $0x0,-0x7fe16a51(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801061af:	66 c7 80 b0 95 1e 80 	movw   $0xffff,-0x7fe16a50(%eax)
801061b6:	ff ff 
801061b8:	66 c7 80 b2 95 1e 80 	movw   $0x0,-0x7fe16a4e(%eax)
801061bf:	00 00 
801061c1:	c6 80 b4 95 1e 80 00 	movb   $0x0,-0x7fe16a4c(%eax)
801061c8:	c6 80 b5 95 1e 80 f2 	movb   $0xf2,-0x7fe16a4b(%eax)
801061cf:	0f b6 88 b6 95 1e 80 	movzbl -0x7fe16a4a(%eax),%ecx
801061d6:	83 c9 0f             	or     $0xf,%ecx
801061d9:	83 e1 cf             	and    $0xffffffcf,%ecx
801061dc:	83 c9 c0             	or     $0xffffffc0,%ecx
801061df:	88 88 b6 95 1e 80    	mov    %cl,-0x7fe16a4a(%eax)
801061e5:	c6 80 b7 95 1e 80 00 	movb   $0x0,-0x7fe16a49(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801061ec:	05 90 95 1e 80       	add    $0x801e9590,%eax
  pd[0] = size-1;
801061f1:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
801061f7:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
801061fb:	c1 e8 10             	shr    $0x10,%eax
801061fe:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106202:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106205:	0f 01 10             	lgdtl  (%eax)
}
80106208:	83 c4 14             	add    $0x14,%esp
8010620b:	5b                   	pop    %ebx
8010620c:	5d                   	pop    %ebp
8010620d:	c3                   	ret    

8010620e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010620e:	55                   	push   %ebp
8010620f:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106211:	a1 44 c2 1e 80       	mov    0x801ec244,%eax
80106216:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010621b:	0f 22 d8             	mov    %eax,%cr3
}
8010621e:	5d                   	pop    %ebp
8010621f:	c3                   	ret    

80106220 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106220:	55                   	push   %ebp
80106221:	89 e5                	mov    %esp,%ebp
80106223:	57                   	push   %edi
80106224:	56                   	push   %esi
80106225:	53                   	push   %ebx
80106226:	83 ec 1c             	sub    $0x1c,%esp
80106229:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
8010622c:	85 f6                	test   %esi,%esi
8010622e:	0f 84 dd 00 00 00    	je     80106311 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106234:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106238:	0f 84 e0 00 00 00    	je     8010631e <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010623e:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106242:	0f 84 e3 00 00 00    	je     8010632b <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80106248:	e8 56 dc ff ff       	call   80103ea3 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010624d:	e8 9d d2 ff ff       	call   801034ef <mycpu>
80106252:	89 c3                	mov    %eax,%ebx
80106254:	e8 96 d2 ff ff       	call   801034ef <mycpu>
80106259:	8d 78 08             	lea    0x8(%eax),%edi
8010625c:	e8 8e d2 ff ff       	call   801034ef <mycpu>
80106261:	83 c0 08             	add    $0x8,%eax
80106264:	c1 e8 10             	shr    $0x10,%eax
80106267:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010626a:	e8 80 d2 ff ff       	call   801034ef <mycpu>
8010626f:	83 c0 08             	add    $0x8,%eax
80106272:	c1 e8 18             	shr    $0x18,%eax
80106275:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010627c:	67 00 
8010627e:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106285:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106289:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010628f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106296:	83 e2 f0             	and    $0xfffffff0,%edx
80106299:	83 ca 19             	or     $0x19,%edx
8010629c:	83 e2 9f             	and    $0xffffff9f,%edx
8010629f:	83 ca 80             	or     $0xffffff80,%edx
801062a2:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801062a8:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
801062af:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801062b5:	e8 35 d2 ff ff       	call   801034ef <mycpu>
801062ba:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801062c1:	83 e2 ef             	and    $0xffffffef,%edx
801062c4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801062ca:	e8 20 d2 ff ff       	call   801034ef <mycpu>
801062cf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801062d5:	8b 5e 08             	mov    0x8(%esi),%ebx
801062d8:	e8 12 d2 ff ff       	call   801034ef <mycpu>
801062dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062e3:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801062e6:	e8 04 d2 ff ff       	call   801034ef <mycpu>
801062eb:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801062f1:	b8 28 00 00 00       	mov    $0x28,%eax
801062f6:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801062f9:	8b 46 04             	mov    0x4(%esi),%eax
801062fc:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106301:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106304:	e8 d7 db ff ff       	call   80103ee0 <popcli>
}
80106309:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010630c:	5b                   	pop    %ebx
8010630d:	5e                   	pop    %esi
8010630e:	5f                   	pop    %edi
8010630f:	5d                   	pop    %ebp
80106310:	c3                   	ret    
    panic("switchuvm: no process");
80106311:	83 ec 0c             	sub    $0xc,%esp
80106314:	68 d2 71 10 80       	push   $0x801071d2
80106319:	e8 2a a0 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010631e:	83 ec 0c             	sub    $0xc,%esp
80106321:	68 e8 71 10 80       	push   $0x801071e8
80106326:	e8 1d a0 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
8010632b:	83 ec 0c             	sub    $0xc,%esp
8010632e:	68 fd 71 10 80       	push   $0x801071fd
80106333:	e8 10 a0 ff ff       	call   80100348 <panic>

80106338 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz, int pid)
{
80106338:	55                   	push   %ebp
80106339:	89 e5                	mov    %esp,%ebp
8010633b:	56                   	push   %esi
8010633c:	53                   	push   %ebx
8010633d:	8b 75 10             	mov    0x10(%ebp),%esi
80106340:	8b 45 14             	mov    0x14(%ebp),%eax
  char *mem;

  if(sz >= PGSIZE)
80106343:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106349:	77 50                	ja     8010639b <inituvm+0x63>
    panic("inituvm: more than a page");
  if(pid)
8010634b:	85 c0                	test   %eax,%eax
8010634d:	75 59                	jne    801063a8 <inituvm+0x70>
  	mem = kalloc2(pid);
  else {
	//cprintf("INITUVM \n");
	mem = kalloc();
8010634f:	e8 1b be ff ff       	call   8010216f <kalloc>
80106354:	89 c3                	mov    %eax,%ebx
  }
  memset(mem, 0, PGSIZE);
80106356:	83 ec 04             	sub    $0x4,%esp
80106359:	68 00 10 00 00       	push   $0x1000
8010635e:	6a 00                	push   $0x0
80106360:	53                   	push   %ebx
80106361:	e8 c6 dc ff ff       	call   8010402c <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106366:	83 c4 08             	add    $0x8,%esp
80106369:	6a 06                	push   $0x6
8010636b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106371:	50                   	push   %eax
80106372:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106377:	ba 00 00 00 00       	mov    $0x0,%edx
8010637c:	8b 45 08             	mov    0x8(%ebp),%eax
8010637f:	e8 c8 fc ff ff       	call   8010604c <mappages>
  memmove(mem, init, sz);
80106384:	83 c4 0c             	add    $0xc,%esp
80106387:	56                   	push   %esi
80106388:	ff 75 0c             	pushl  0xc(%ebp)
8010638b:	53                   	push   %ebx
8010638c:	e8 16 dd ff ff       	call   801040a7 <memmove>
}
80106391:	83 c4 10             	add    $0x10,%esp
80106394:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106397:	5b                   	pop    %ebx
80106398:	5e                   	pop    %esi
80106399:	5d                   	pop    %ebp
8010639a:	c3                   	ret    
    panic("inituvm: more than a page");
8010639b:	83 ec 0c             	sub    $0xc,%esp
8010639e:	68 11 72 10 80       	push   $0x80107211
801063a3:	e8 a0 9f ff ff       	call   80100348 <panic>
  	mem = kalloc2(pid);
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	50                   	push   %eax
801063ac:	e8 13 bf ff ff       	call   801022c4 <kalloc2>
801063b1:	89 c3                	mov    %eax,%ebx
801063b3:	83 c4 10             	add    $0x10,%esp
801063b6:	eb 9e                	jmp    80106356 <inituvm+0x1e>

801063b8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801063b8:	55                   	push   %ebp
801063b9:	89 e5                	mov    %esp,%ebp
801063bb:	57                   	push   %edi
801063bc:	56                   	push   %esi
801063bd:	53                   	push   %ebx
801063be:	83 ec 0c             	sub    $0xc,%esp
801063c1:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801063c4:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801063cb:	75 07                	jne    801063d4 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801063cd:	bb 00 00 00 00       	mov    $0x0,%ebx
801063d2:	eb 3c                	jmp    80106410 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
801063d4:	83 ec 0c             	sub    $0xc,%esp
801063d7:	68 cc 72 10 80       	push   $0x801072cc
801063dc:	e8 67 9f ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801063e1:	83 ec 0c             	sub    $0xc,%esp
801063e4:	68 2b 72 10 80       	push   $0x8010722b
801063e9:	e8 5a 9f ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801063ee:	05 00 00 00 80       	add    $0x80000000,%eax
801063f3:	56                   	push   %esi
801063f4:	89 da                	mov    %ebx,%edx
801063f6:	03 55 14             	add    0x14(%ebp),%edx
801063f9:	52                   	push   %edx
801063fa:	50                   	push   %eax
801063fb:	ff 75 10             	pushl  0x10(%ebp)
801063fe:	e8 84 b3 ff ff       	call   80101787 <readi>
80106403:	83 c4 10             	add    $0x10,%esp
80106406:	39 f0                	cmp    %esi,%eax
80106408:	75 47                	jne    80106451 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010640a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106410:	39 fb                	cmp    %edi,%ebx
80106412:	73 30                	jae    80106444 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106414:	89 da                	mov    %ebx,%edx
80106416:	03 55 0c             	add    0xc(%ebp),%edx
80106419:	b9 00 00 00 00       	mov    $0x0,%ecx
8010641e:	8b 45 08             	mov    0x8(%ebp),%eax
80106421:	e8 b6 fb ff ff       	call   80105fdc <walkpgdir>
80106426:	85 c0                	test   %eax,%eax
80106428:	74 b7                	je     801063e1 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
8010642a:	8b 00                	mov    (%eax),%eax
8010642c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106431:	89 fe                	mov    %edi,%esi
80106433:	29 de                	sub    %ebx,%esi
80106435:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010643b:	76 b1                	jbe    801063ee <loaduvm+0x36>
      n = PGSIZE;
8010643d:	be 00 10 00 00       	mov    $0x1000,%esi
80106442:	eb aa                	jmp    801063ee <loaduvm+0x36>
      return -1;
  }
  return 0;
80106444:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106449:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010644c:	5b                   	pop    %ebx
8010644d:	5e                   	pop    %esi
8010644e:	5f                   	pop    %edi
8010644f:	5d                   	pop    %ebp
80106450:	c3                   	ret    
      return -1;
80106451:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106456:	eb f1                	jmp    80106449 <loaduvm+0x91>

80106458 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106458:	55                   	push   %ebp
80106459:	89 e5                	mov    %esp,%ebp
8010645b:	57                   	push   %edi
8010645c:	56                   	push   %esi
8010645d:	53                   	push   %ebx
8010645e:	83 ec 0c             	sub    $0xc,%esp
80106461:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106464:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106467:	73 11                	jae    8010647a <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106469:	8b 45 10             	mov    0x10(%ebp),%eax
8010646c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106472:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106478:	eb 19                	jmp    80106493 <deallocuvm+0x3b>
    return oldsz;
8010647a:	89 f8                	mov    %edi,%eax
8010647c:	eb 64                	jmp    801064e2 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010647e:	c1 eb 16             	shr    $0x16,%ebx
80106481:	83 c3 01             	add    $0x1,%ebx
80106484:	c1 e3 16             	shl    $0x16,%ebx
80106487:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010648d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106493:	39 fb                	cmp    %edi,%ebx
80106495:	73 48                	jae    801064df <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106497:	b9 00 00 00 00       	mov    $0x0,%ecx
8010649c:	89 da                	mov    %ebx,%edx
8010649e:	8b 45 08             	mov    0x8(%ebp),%eax
801064a1:	e8 36 fb ff ff       	call   80105fdc <walkpgdir>
801064a6:	89 c6                	mov    %eax,%esi
    if(!pte)
801064a8:	85 c0                	test   %eax,%eax
801064aa:	74 d2                	je     8010647e <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
801064ac:	8b 00                	mov    (%eax),%eax
801064ae:	a8 01                	test   $0x1,%al
801064b0:	74 db                	je     8010648d <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801064b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064b7:	74 19                	je     801064d2 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
801064b9:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801064be:	83 ec 0c             	sub    $0xc,%esp
801064c1:	50                   	push   %eax
801064c2:	e8 f1 ba ff ff       	call   80101fb8 <kfree>
      *pte = 0;
801064c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801064cd:	83 c4 10             	add    $0x10,%esp
801064d0:	eb bb                	jmp    8010648d <deallocuvm+0x35>
        panic("kfree");
801064d2:	83 ec 0c             	sub    $0xc,%esp
801064d5:	68 66 6b 10 80       	push   $0x80106b66
801064da:	e8 69 9e ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801064df:	8b 45 10             	mov    0x10(%ebp),%eax
}
801064e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064e5:	5b                   	pop    %ebx
801064e6:	5e                   	pop    %esi
801064e7:	5f                   	pop    %edi
801064e8:	5d                   	pop    %ebp
801064e9:	c3                   	ret    

801064ea <allocuvm>:
{
801064ea:	55                   	push   %ebp
801064eb:	89 e5                	mov    %esp,%ebp
801064ed:	57                   	push   %edi
801064ee:	56                   	push   %esi
801064ef:	53                   	push   %ebx
801064f0:	83 ec 1c             	sub    $0x1c,%esp
801064f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801064f6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801064f9:	85 ff                	test   %edi,%edi
801064fb:	0f 88 e1 00 00 00    	js     801065e2 <allocuvm+0xf8>
  if(newsz < oldsz)
80106501:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106504:	72 17                	jb     8010651d <allocuvm+0x33>
  a = PGROUNDUP(oldsz);
80106506:	8b 45 0c             	mov    0xc(%ebp),%eax
80106509:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010650f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106515:	89 7d 10             	mov    %edi,0x10(%ebp)
80106518:	8b 7d 14             	mov    0x14(%ebp),%edi
  for(; a < newsz; a += PGSIZE){
8010651b:	eb 4e                	jmp    8010656b <allocuvm+0x81>
    return oldsz;
8010651d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106520:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106523:	e9 c1 00 00 00       	jmp    801065e9 <allocuvm+0xff>
	mem  = kalloc();
80106528:	e8 42 bc ff ff       	call   8010216f <kalloc>
8010652d:	89 c6                	mov    %eax,%esi
    if(mem == 0){
8010652f:	85 f6                	test   %esi,%esi
80106531:	74 51                	je     80106584 <allocuvm+0x9a>
    memset(mem, 0, PGSIZE);
80106533:	83 ec 04             	sub    $0x4,%esp
80106536:	68 00 10 00 00       	push   $0x1000
8010653b:	6a 00                	push   $0x0
8010653d:	56                   	push   %esi
8010653e:	e8 e9 da ff ff       	call   8010402c <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106543:	83 c4 08             	add    $0x8,%esp
80106546:	6a 06                	push   $0x6
80106548:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
8010654e:	50                   	push   %eax
8010654f:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106554:	89 da                	mov    %ebx,%edx
80106556:	8b 45 08             	mov    0x8(%ebp),%eax
80106559:	e8 ee fa ff ff       	call   8010604c <mappages>
8010655e:	83 c4 10             	add    $0x10,%esp
80106561:	85 c0                	test   %eax,%eax
80106563:	78 4a                	js     801065af <allocuvm+0xc5>
  for(; a < newsz; a += PGSIZE){
80106565:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010656b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
8010656e:	73 79                	jae    801065e9 <allocuvm+0xff>
    if(pid != 0)
80106570:	85 ff                	test   %edi,%edi
80106572:	74 b4                	je     80106528 <allocuvm+0x3e>
    	mem = kalloc2(pid);
80106574:	83 ec 0c             	sub    $0xc,%esp
80106577:	57                   	push   %edi
80106578:	e8 47 bd ff ff       	call   801022c4 <kalloc2>
8010657d:	89 c6                	mov    %eax,%esi
8010657f:	83 c4 10             	add    $0x10,%esp
80106582:	eb ab                	jmp    8010652f <allocuvm+0x45>
80106584:	8b 7d 10             	mov    0x10(%ebp),%edi
      cprintf("allocuvm out of memory\n");
80106587:	83 ec 0c             	sub    $0xc,%esp
8010658a:	68 49 72 10 80       	push   $0x80107249
8010658f:	e8 77 a0 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106594:	83 c4 0c             	add    $0xc,%esp
80106597:	ff 75 0c             	pushl  0xc(%ebp)
8010659a:	57                   	push   %edi
8010659b:	ff 75 08             	pushl  0x8(%ebp)
8010659e:	e8 b5 fe ff ff       	call   80106458 <deallocuvm>
      return 0;
801065a3:	83 c4 10             	add    $0x10,%esp
801065a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801065ad:	eb 3a                	jmp    801065e9 <allocuvm+0xff>
801065af:	8b 7d 10             	mov    0x10(%ebp),%edi
      cprintf("allocuvm out of memory (2)\n");
801065b2:	83 ec 0c             	sub    $0xc,%esp
801065b5:	68 61 72 10 80       	push   $0x80107261
801065ba:	e8 4c a0 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801065bf:	83 c4 0c             	add    $0xc,%esp
801065c2:	ff 75 0c             	pushl  0xc(%ebp)
801065c5:	57                   	push   %edi
801065c6:	ff 75 08             	pushl  0x8(%ebp)
801065c9:	e8 8a fe ff ff       	call   80106458 <deallocuvm>
      kfree(mem);
801065ce:	89 34 24             	mov    %esi,(%esp)
801065d1:	e8 e2 b9 ff ff       	call   80101fb8 <kfree>
      return 0;
801065d6:	83 c4 10             	add    $0x10,%esp
801065d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801065e0:	eb 07                	jmp    801065e9 <allocuvm+0xff>
    return 0;
801065e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801065e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065ef:	5b                   	pop    %ebx
801065f0:	5e                   	pop    %esi
801065f1:	5f                   	pop    %edi
801065f2:	5d                   	pop    %ebp
801065f3:	c3                   	ret    

801065f4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801065f4:	55                   	push   %ebp
801065f5:	89 e5                	mov    %esp,%ebp
801065f7:	56                   	push   %esi
801065f8:	53                   	push   %ebx
801065f9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801065fc:	85 f6                	test   %esi,%esi
801065fe:	74 1a                	je     8010661a <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106600:	83 ec 04             	sub    $0x4,%esp
80106603:	6a 00                	push   $0x0
80106605:	68 00 00 00 80       	push   $0x80000000
8010660a:	56                   	push   %esi
8010660b:	e8 48 fe ff ff       	call   80106458 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106610:	83 c4 10             	add    $0x10,%esp
80106613:	bb 00 00 00 00       	mov    $0x0,%ebx
80106618:	eb 10                	jmp    8010662a <freevm+0x36>
    panic("freevm: no pgdir");
8010661a:	83 ec 0c             	sub    $0xc,%esp
8010661d:	68 7d 72 10 80       	push   $0x8010727d
80106622:	e8 21 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106627:	83 c3 01             	add    $0x1,%ebx
8010662a:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106630:	77 1f                	ja     80106651 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106632:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106635:	a8 01                	test   $0x1,%al
80106637:	74 ee                	je     80106627 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106639:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010663e:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106643:	83 ec 0c             	sub    $0xc,%esp
80106646:	50                   	push   %eax
80106647:	e8 6c b9 ff ff       	call   80101fb8 <kfree>
8010664c:	83 c4 10             	add    $0x10,%esp
8010664f:	eb d6                	jmp    80106627 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106651:	83 ec 0c             	sub    $0xc,%esp
80106654:	56                   	push   %esi
80106655:	e8 5e b9 ff ff       	call   80101fb8 <kfree>
}
8010665a:	83 c4 10             	add    $0x10,%esp
8010665d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106660:	5b                   	pop    %ebx
80106661:	5e                   	pop    %esi
80106662:	5d                   	pop    %ebp
80106663:	c3                   	ret    

80106664 <setupkvm>:
{
80106664:	55                   	push   %ebp
80106665:	89 e5                	mov    %esp,%ebp
80106667:	56                   	push   %esi
80106668:	53                   	push   %ebx
80106669:	8b 45 08             	mov    0x8(%ebp),%eax
  if(pid) {
8010666c:	85 c0                	test   %eax,%eax
8010666e:	74 56                	je     801066c6 <setupkvm+0x62>
  if((pgdir = (pde_t*)kalloc2(pid)) == 0)
80106670:	83 ec 0c             	sub    $0xc,%esp
80106673:	50                   	push   %eax
80106674:	e8 4b bc ff ff       	call   801022c4 <kalloc2>
80106679:	89 c6                	mov    %eax,%esi
8010667b:	83 c4 10             	add    $0x10,%esp
8010667e:	85 c0                	test   %eax,%eax
80106680:	74 62                	je     801066e4 <setupkvm+0x80>
  memset(pgdir, 0, PGSIZE);
80106682:	83 ec 04             	sub    $0x4,%esp
80106685:	68 00 10 00 00       	push   $0x1000
8010668a:	6a 00                	push   $0x0
8010668c:	56                   	push   %esi
8010668d:	e8 9a d9 ff ff       	call   8010402c <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106692:	83 c4 10             	add    $0x10,%esp
80106695:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010669a:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801066a0:	73 42                	jae    801066e4 <setupkvm+0x80>
                (uint)k->phys_start, k->perm) < 0) {
801066a2:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801066a5:	8b 4b 08             	mov    0x8(%ebx),%ecx
801066a8:	29 c1                	sub    %eax,%ecx
801066aa:	83 ec 08             	sub    $0x8,%esp
801066ad:	ff 73 0c             	pushl  0xc(%ebx)
801066b0:	50                   	push   %eax
801066b1:	8b 13                	mov    (%ebx),%edx
801066b3:	89 f0                	mov    %esi,%eax
801066b5:	e8 92 f9 ff ff       	call   8010604c <mappages>
801066ba:	83 c4 10             	add    $0x10,%esp
801066bd:	85 c0                	test   %eax,%eax
801066bf:	78 12                	js     801066d3 <setupkvm+0x6f>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066c1:	83 c3 10             	add    $0x10,%ebx
801066c4:	eb d4                	jmp    8010669a <setupkvm+0x36>
      if((pgdir = (pde_t*)kalloc()) == 0)
801066c6:	e8 a4 ba ff ff       	call   8010216f <kalloc>
801066cb:	89 c6                	mov    %eax,%esi
801066cd:	85 c0                	test   %eax,%eax
801066cf:	75 b1                	jne    80106682 <setupkvm+0x1e>
801066d1:	eb 11                	jmp    801066e4 <setupkvm+0x80>
      freevm(pgdir);
801066d3:	83 ec 0c             	sub    $0xc,%esp
801066d6:	56                   	push   %esi
801066d7:	e8 18 ff ff ff       	call   801065f4 <freevm>
      return 0;
801066dc:	83 c4 10             	add    $0x10,%esp
801066df:	be 00 00 00 00       	mov    $0x0,%esi
}
801066e4:	89 f0                	mov    %esi,%eax
801066e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801066e9:	5b                   	pop    %ebx
801066ea:	5e                   	pop    %esi
801066eb:	5d                   	pop    %ebp
801066ec:	c3                   	ret    

801066ed <kvmalloc>:
{
801066ed:	55                   	push   %ebp
801066ee:	89 e5                	mov    %esp,%ebp
801066f0:	83 ec 14             	sub    $0x14,%esp
  kpgdir = setupkvm(0);
801066f3:	6a 00                	push   $0x0
801066f5:	e8 6a ff ff ff       	call   80106664 <setupkvm>
801066fa:	a3 44 c2 1e 80       	mov    %eax,0x801ec244
  switchkvm();
801066ff:	e8 0a fb ff ff       	call   8010620e <switchkvm>
}
80106704:	83 c4 10             	add    $0x10,%esp
80106707:	c9                   	leave  
80106708:	c3                   	ret    

80106709 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106709:	55                   	push   %ebp
8010670a:	89 e5                	mov    %esp,%ebp
8010670c:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010670f:	b9 00 00 00 00       	mov    $0x0,%ecx
80106714:	8b 55 0c             	mov    0xc(%ebp),%edx
80106717:	8b 45 08             	mov    0x8(%ebp),%eax
8010671a:	e8 bd f8 ff ff       	call   80105fdc <walkpgdir>
  if(pte == 0)
8010671f:	85 c0                	test   %eax,%eax
80106721:	74 05                	je     80106728 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106723:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106726:	c9                   	leave  
80106727:	c3                   	ret    
    panic("clearpteu");
80106728:	83 ec 0c             	sub    $0xc,%esp
8010672b:	68 8e 72 10 80       	push   $0x8010728e
80106730:	e8 13 9c ff ff       	call   80100348 <panic>

80106735 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, int pid)
{
80106735:	55                   	push   %ebp
80106736:	89 e5                	mov    %esp,%ebp
80106738:	57                   	push   %edi
80106739:	56                   	push   %esi
8010673a:	53                   	push   %ebx
8010673b:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm(0)) == 0)
8010673e:	6a 00                	push   $0x0
80106740:	e8 1f ff ff ff       	call   80106664 <setupkvm>
80106745:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106748:	83 c4 10             	add    $0x10,%esp
8010674b:	85 c0                	test   %eax,%eax
8010674d:	0f 84 e9 00 00 00    	je     8010683c <copyuvm+0x107>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106753:	bf 00 00 00 00       	mov    $0x0,%edi
80106758:	eb 68                	jmp    801067c2 <copyuvm+0x8d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010675a:	83 ec 0c             	sub    $0xc,%esp
8010675d:	68 98 72 10 80       	push   $0x80107298
80106762:	e8 e1 9b ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106767:	83 ec 0c             	sub    $0xc,%esp
8010676a:	68 b2 72 10 80       	push   $0x801072b2
8010676f:	e8 d4 9b ff ff       	call   80100348 <panic>
    if((mem = kalloc2(pid)) == 0)
      goto bad;
    }
    else{
       //cprintf("COPYUVM \n");
       if((mem = kalloc()) == 0)
80106774:	e8 f6 b9 ff ff       	call   8010216f <kalloc>
80106779:	89 c3                	mov    %eax,%ebx
8010677b:	85 c0                	test   %eax,%eax
8010677d:	0f 84 a4 00 00 00    	je     80106827 <copyuvm+0xf2>
         goto bad;
    }

    memmove(mem, (char*)P2V(pa), PGSIZE);
80106783:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106789:	83 ec 04             	sub    $0x4,%esp
8010678c:	68 00 10 00 00       	push   $0x1000
80106791:	56                   	push   %esi
80106792:	53                   	push   %ebx
80106793:	e8 0f d9 ff ff       	call   801040a7 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106798:	83 c4 08             	add    $0x8,%esp
8010679b:	ff 75 e0             	pushl  -0x20(%ebp)
8010679e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801067a4:	50                   	push   %eax
801067a5:	b9 00 10 00 00       	mov    $0x1000,%ecx
801067aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801067b0:	e8 97 f8 ff ff       	call   8010604c <mappages>
801067b5:	83 c4 10             	add    $0x10,%esp
801067b8:	85 c0                	test   %eax,%eax
801067ba:	78 5f                	js     8010681b <copyuvm+0xe6>
  for(i = 0; i < sz; i += PGSIZE){
801067bc:	81 c7 00 10 00 00    	add    $0x1000,%edi
801067c2:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801067c5:	73 75                	jae    8010683c <copyuvm+0x107>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801067c7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801067ca:	b9 00 00 00 00       	mov    $0x0,%ecx
801067cf:	89 fa                	mov    %edi,%edx
801067d1:	8b 45 08             	mov    0x8(%ebp),%eax
801067d4:	e8 03 f8 ff ff       	call   80105fdc <walkpgdir>
801067d9:	85 c0                	test   %eax,%eax
801067db:	0f 84 79 ff ff ff    	je     8010675a <copyuvm+0x25>
    if(!(*pte & PTE_P))
801067e1:	8b 00                	mov    (%eax),%eax
801067e3:	a8 01                	test   $0x1,%al
801067e5:	74 80                	je     80106767 <copyuvm+0x32>
    pa = PTE_ADDR(*pte);
801067e7:	89 c6                	mov    %eax,%esi
801067e9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801067ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801067f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid != 0){
801067f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801067fb:	0f 84 73 ff ff ff    	je     80106774 <copyuvm+0x3f>
    if((mem = kalloc2(pid)) == 0)
80106801:	83 ec 0c             	sub    $0xc,%esp
80106804:	ff 75 10             	pushl  0x10(%ebp)
80106807:	e8 b8 ba ff ff       	call   801022c4 <kalloc2>
8010680c:	89 c3                	mov    %eax,%ebx
8010680e:	83 c4 10             	add    $0x10,%esp
80106811:	85 c0                	test   %eax,%eax
80106813:	0f 85 6a ff ff ff    	jne    80106783 <copyuvm+0x4e>
80106819:	eb 0c                	jmp    80106827 <copyuvm+0xf2>
      kfree(mem);
8010681b:	83 ec 0c             	sub    $0xc,%esp
8010681e:	53                   	push   %ebx
8010681f:	e8 94 b7 ff ff       	call   80101fb8 <kfree>
      goto bad;
80106824:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106827:	83 ec 0c             	sub    $0xc,%esp
8010682a:	ff 75 dc             	pushl  -0x24(%ebp)
8010682d:	e8 c2 fd ff ff       	call   801065f4 <freevm>
  return 0;
80106832:	83 c4 10             	add    $0x10,%esp
80106835:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010683c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010683f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106842:	5b                   	pop    %ebx
80106843:	5e                   	pop    %esi
80106844:	5f                   	pop    %edi
80106845:	5d                   	pop    %ebp
80106846:	c3                   	ret    

80106847 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106847:	55                   	push   %ebp
80106848:	89 e5                	mov    %esp,%ebp
8010684a:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010684d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106852:	8b 55 0c             	mov    0xc(%ebp),%edx
80106855:	8b 45 08             	mov    0x8(%ebp),%eax
80106858:	e8 7f f7 ff ff       	call   80105fdc <walkpgdir>
  if((*pte & PTE_P) == 0)
8010685d:	8b 00                	mov    (%eax),%eax
8010685f:	a8 01                	test   $0x1,%al
80106861:	74 10                	je     80106873 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106863:	a8 04                	test   $0x4,%al
80106865:	74 13                	je     8010687a <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106867:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010686c:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106871:	c9                   	leave  
80106872:	c3                   	ret    
    return 0;
80106873:	b8 00 00 00 00       	mov    $0x0,%eax
80106878:	eb f7                	jmp    80106871 <uva2ka+0x2a>
    return 0;
8010687a:	b8 00 00 00 00       	mov    $0x0,%eax
8010687f:	eb f0                	jmp    80106871 <uva2ka+0x2a>

80106881 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106881:	55                   	push   %ebp
80106882:	89 e5                	mov    %esp,%ebp
80106884:	57                   	push   %edi
80106885:	56                   	push   %esi
80106886:	53                   	push   %ebx
80106887:	83 ec 0c             	sub    $0xc,%esp
8010688a:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010688d:	eb 25                	jmp    801068b4 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010688f:	8b 55 0c             	mov    0xc(%ebp),%edx
80106892:	29 f2                	sub    %esi,%edx
80106894:	01 d0                	add    %edx,%eax
80106896:	83 ec 04             	sub    $0x4,%esp
80106899:	53                   	push   %ebx
8010689a:	ff 75 10             	pushl  0x10(%ebp)
8010689d:	50                   	push   %eax
8010689e:	e8 04 d8 ff ff       	call   801040a7 <memmove>
    len -= n;
801068a3:	29 df                	sub    %ebx,%edi
    buf += n;
801068a5:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801068a8:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801068ae:	89 45 0c             	mov    %eax,0xc(%ebp)
801068b1:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801068b4:	85 ff                	test   %edi,%edi
801068b6:	74 2f                	je     801068e7 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801068b8:	8b 75 0c             	mov    0xc(%ebp),%esi
801068bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801068c1:	83 ec 08             	sub    $0x8,%esp
801068c4:	56                   	push   %esi
801068c5:	ff 75 08             	pushl  0x8(%ebp)
801068c8:	e8 7a ff ff ff       	call   80106847 <uva2ka>
    if(pa0 == 0)
801068cd:	83 c4 10             	add    $0x10,%esp
801068d0:	85 c0                	test   %eax,%eax
801068d2:	74 20                	je     801068f4 <copyout+0x73>
    n = PGSIZE - (va - va0);
801068d4:	89 f3                	mov    %esi,%ebx
801068d6:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801068d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801068df:	39 df                	cmp    %ebx,%edi
801068e1:	73 ac                	jae    8010688f <copyout+0xe>
      n = len;
801068e3:	89 fb                	mov    %edi,%ebx
801068e5:	eb a8                	jmp    8010688f <copyout+0xe>
  }
  return 0;
801068e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068ef:	5b                   	pop    %ebx
801068f0:	5e                   	pop    %esi
801068f1:	5f                   	pop    %edi
801068f2:	5d                   	pop    %ebp
801068f3:	c3                   	ret    
      return -1;
801068f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f9:	eb f1                	jmp    801068ec <copyout+0x6b>
