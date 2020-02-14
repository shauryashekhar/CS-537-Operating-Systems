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

int frames[16000];
int pid[160000];
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
   
  //cprintf("Freed: %x \t %x \t %x \n",V2P(v), (V2P(v) >> 12 ), (V2P(v) >> 12 & 0xffff));
  /*if(numframes != -1) {
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
      //cprintf("Frame Freed: %d \n", i);
      numframes--;
  }*/

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
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

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next->next;
  
  char* ptr = (char*)r;
  //cprintf("Allocated: %x \t %x \t %x \n", PHYSTOP - V2P(ptr), PHYSTOP - (V2P(ptr) >> 12 ), (V2P(ptr) >> 12 & 0xffff));
  
  numframes++;
  frames[numframes] = (V2P(ptr) >> 12 & 0xffff);
  pid[numframes] = -2;

  //cprintf("ALLOCATED: Numframes: %d, frame position at numframes: %x, pid at numframes: %d \n", numframes, frames[numframes], pid[numframes]);
  //cprintf("0. %x %d \n", frames[0], pid[0]);
  //cprintf("64. %x %d \n", frames[64], pid[64]);
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}

char*
kalloc2(int processPid)
{
  struct run *r, *head;
  head = kmem.freelist;

  if(kmem.use_lock)
     acquire(&kmem.lock);
  int firstPass = 1;
  
  repeat: 
  if(firstPass) {
    r = kmem.freelist;
    firstPass = 0;
  } else {
    r = r->next;
  }

  char* ptr = (char*)r;
  int frameNumberFound = (V2P(ptr) >> 12 & 0xffff);
 
  int i;
  for(i = 0; i<numframes; i++) {
     if(frames[i] == (frameNumberFound - 1)) {
          if(pid[i] != processPid) {
             goto repeat;
	  }		  
     }
     if(frames[i] == (frameNumberFound + 1)) {
         if(pid[i] != processPid) {
            goto repeat;
	 }
     }
     if(frames[i] > (frameNumberFound)) {
         continue;
     }
     break;
  }
  
  numframes++;
  for(int z = i+1; z<numframes; z++) {
     frames[z] = frames[z-1];
     pid[z] = pid[z-1];
  }
  frames[i] = frameNumberFound;
  pid[i] = processPid;

  while(head->next != r) {
      head = head->next;
  }
  head->next = r->next;

  if(!kmem.use_lock)
     release(&kmem.lock);
  return (char*)r;
}

