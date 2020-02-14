// Physical memory allocator, intended to allocate
// memory for user processes, kernel stacks, page table pages,
// and pipe buffers. Allocates 4096-byte pages.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"

void freerange(void *vstart, void *vend);
extern char end[]; // first address after kernel loaded from ELF file
                   // defined by the kernel linker script in kernel.ld

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

int frames[20000];
int pid[200000];
int numframes = -1;

// Initialization happens in two phases.
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
  freerange(vstart, vend);
  kmem.use_lock = 1;
}

void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
    kfree(p);
}
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  if(numframes > 0) {
      int frameFreed = (V2P(v) >> 12 & 0xffff);
      int i;
      for(i= 0; i<numframes; i++) {
          if(frames[i] == frameFreed) {
              break;
          }
      } 
      for(int z = i; z < numframes; z++) {
          frames[z] = frames[z+1];
          pid[z] = pid[z+1];
      }
      frames[numframes] = 0;
      pid[numframes] = 0;
      //numframes--;
//      cprintf("Frame freed: %x at %d with numframes: %d and previous element as %x \n", frameFreed, i, numframes, frames[i-1]);
  }

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = (struct run*)v;
  //struct run *head = kmem.freelist;
  struct run *current = kmem.freelist;
  struct run *temp = current;
  int frameFreed = (V2P(v) >> 12 & 0xfffff);
  char* currentNodeFrame = (char*)current;
  int frameAddress = (V2P(currentNodeFrame) >> 12 & 0xffff);
  while(frameAddress > frameFreed)
  {
	  temp = current;
	  current = current->next;
	  frameAddress = (V2P((struct run*)current)  >> 12 & 0xffff);
  }
  if(current == temp) {

    r->next = temp;
    kmem.freelist = r;
  }
  else{
     r->next = temp->next;
     temp->next= r;
  }
  if(kmem.use_lock)
    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  struct run *r;
  //cprintf("First CAME HERE! \n");
  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  
  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
  int i; 
  for(i = 0; i< numframes; i++) {
      if(frames[i] > frameNumberFound) {
          continue;
      } else {
	      break;
      }
  }
  //cprintf("KALLOC: Will enter at %d \n", i);
  for(int z = numframes ; z >= i; z--) {
      //cprintf("%x,%x\n", frames[z], frames[z-1]);
      frames[z] = frames[z-1];
      pid[z] = pid[z-1];
  }

  numframes++;
  frames[i] = frameNumberFound;
  pid[i] = -2;

//  cprintf("ALLOCATED KALLOC: NumFrames: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[i], pid[i]);
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}

char*
kalloc1a(int processPid)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next->next;

  char* ptr = (char*)r;
  //cprintf("Allocated KALLOC1A: %x \t %x \t %x \n", PHYSTOP - V2P(ptr), PHYSTOP - (V2P(ptr) >> 12 ), (V2P(ptr) >> 12 & 0xffff));
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
 
  numframes++;
  frames[numframes] = frameNumberFound;
  pid[numframes] = processPid;

  //cprintf("ALLOCATED KALLOC1A: Numframes: %d, i: not there currently , frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}

char*
kalloc2(int processPid)
{
  struct run *r;
  struct run *head = kmem.freelist;
  struct run *temp = kmem.freelist;

  if(kmem.use_lock)
     acquire(&kmem.lock);
  int firstPass = 1;

  repeat: 
  if(firstPass == 1) {
    r = kmem.freelist;
  } else {
    r = r->next;
  }
  
  firstPass = 0;
  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);  
  //cprintf("Frame Number found %x for processID %d \n", frameNumberFound, processPid);

  int i;
  for(i = 0; i< numframes; i++) {
     if(frames[i] == (frameNumberFound - 1)) {
          if(pid[i] == -2) {
             break;
	  } else if(pid[i] != processPid) {
	     //cprintf("Cant process because of -1 %x and pid %d \n", frames[i], pid[i]);
             goto repeat;
	  }		  
     }
     /*if(frames[i] == (frameNumberFound + 1)) {
         if(pid[i] != processPid) {
	//    cprintf("Cant process because of +1 %x and pid %d \n", frames[i], pid[i]);
            goto repeat;
	 } else if (pid[i] == -2) {
            continue;
	 }
     }*/
     if(frames[i] > (frameNumberFound)) {
         continue;
     }
     break;
  }

  for(int j = 0; j< numframes; j++) {
    if(frames[j] == (frameNumberFound + 1)) {
	if(pid[j] == -2) {
           break;
	} else if(pid[j] != processPid) {
	    //cprintf("Cant process because of +1 %x and pid %d \n", frames[i], pid[i]);
           goto repeat;
	}
    }
    if(frames[j] > frameNumberFound) {
        continue;
    }
  }

  int c;
  for(c = 0; c< numframes; c++) {
        if(frames[c] > frameNumberFound) {
	        continue;
	} else {
	        break;
        }
  }
  //cprintf("KALLOC2: Will enter at %d \n", c);
  for(int z = numframes ; z >= c; z--) {
	 //cprintf("%x,%x\n", frames[z], frames[z-1]);
        frames[z] = frames[z-1];
	pid[z] = pid[z-1];
  }

  numframes++;
  frames[c] = frameNumberFound;
  pid[c] = processPid;
  //cprintf("prev pid: %d, cur pid:%d, next pid%d\n",pid[c-1],pid[c],pid[c+1]);
 //cprintf("ALLOCATED KALLOC2: NumFrames: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[c], pid[c]);

 if(head == r) {
  kmem.freelist = r->next;
 } else {
   while(temp->next != r) {
        temp = temp->next;
   }
   temp->next = r->next;
   kmem.freelist = head;
 }
 //struct run* new = kmem.freelist;
 //char* ptrNew = (char*) new;
 //cprintf("FreeList Head %x \n", (V2P(ptrNew) >> 12 & 0xffff));

 //kmem.freelist = r->next->next;
  if(kmem.use_lock)
     release(&kmem.lock);
  return (char*)r;
}
