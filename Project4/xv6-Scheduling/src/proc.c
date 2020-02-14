#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "x86.h"
#include "spinlock.h"
#include "pstat.h"
struct {
  struct spinlock lock;
  struct proc proc[NPROC];
  int queue[4][NPROC];
  //int ticks[4][NPROC];
  int priorityLevelCount[4];
} ptable;

static struct proc *initproc;
struct pstat pstat;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

int ticksPerPriority[4] = {20,16,12,8};

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
  ptable.priorityLevelCount[0] = -1;
  ptable.priorityLevelCount[1] = -1;
  ptable.priorityLevelCount[2] = -1;
  ptable.priorityLevelCount[3] = -1;
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;
  p->ticks[0] = 0;
  p->ticks[1] = 0;
  p->ticks[2] = 0;
  p->ticks[3] = 0;
  p->qtail[0] = 0;
  p->qtail[1] = 0;
  p->qtail[2] = 0;
  p->qtail[3] = 0;
  p->time[0] = 20;
  p->time[1] = 16;
  p->time[2] = 12;
  p->time[3] = 8;
  return p;
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  p->priority = 3;
  ptable.priorityLevelCount[3]++;
  //cprintf("%d %s inside userinit\n", p->pid, p->name);
  ptable.queue[3][ptable.priorityLevelCount[3]] = p->pid;
  //p->qtail[3] = p->qtail[3] + 1;
  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
  //if(getpinfo(pstat)== -1){
  //{
  //  return -1;
  //} 

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;
  if(!np->parent) {
       ptable.priorityLevelCount[3]++;
       np->priority = 3;
       cprintf("Entered in queue %s \n", np->name);
       ptable.queue[3][ptable.priorityLevelCount[3]] = np->pid;
       np->qtail[3] = np->qtail[3] + 1;
  } else {
       int parentPriority = np->parent->priority;
       np->priority = parentPriority;
       ptable.priorityLevelCount[parentPriority]++;
       ptable.queue[parentPriority][ptable.priorityLevelCount[parentPriority]] = np->pid;
       np->qtail[parentPriority] = np->qtail[parentPriority] + 1;
  }
  //cprintf("Parent Is %s\n",np->parent->name);
  release(&ptable.lock);
  getpinfo(&pstat);
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}


void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  for(;;) {
   sti();
   acquire(&ptable.lock);
   int priority, y;
   for(priority = 3; priority >=0; priority--) {
     int found = 0;
     for(y = 0; y <= ptable.priorityLevelCount[priority]; y++) {
      int processToBeRunPID = ptable.queue[priority][y];
      for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++) {
        if(p->pid == processToBeRunPID) {
          break;
	}
      }
      if(p->state == RUNNABLE) {
         found = 1;
	 break;
      }
     }
     if(found == 1) {
        break;
     }
   }
   if(p->state == RUNNABLE) {
   //int currentTickValue = p->ticks[priority];
   //int timeLeft = p->time[p->priority];
   /*if(currentTickValue != 0 && currentTickValue % ticksPerPriority[priority] == 0 && timeLeft == 0) {
      //cprintf("%s has finished time slice. Moving to back of queue\n", p->name);
      for(int z = 0; z < ptable.priorityLevelCount[priority]; z++) {
           ptable.queue[priority][z] = ptable.queue[priority][z+1];
      }
      ptable.queue[priority][ptable.priorityLevelCount[priority]] = p->pid;
      p->qtail[priority] = p->qtail[priority] + 1;
      p->time[p->priority] = ticksPerPriority[p->priority];
   } else {
     //cprintf("%s chosen to run \n", p->name);
     c->proc = p;
     switchuvm(p);
     p->state = RUNNING;
     swtch(&(c->scheduler), p->context);
     switchkvm();
     p->ticks[priority] = currentTickValue + 1;
     p->time[p->priority] = p->time[p->priority] - 1;
     getpinfo(&pstat);
     c->proc = 0;
   }*/
   if(p->time[p->priority] > 0) {
     c->proc = p;
     switchuvm(p);
     p->state = RUNNING;
     swtch(&(c->scheduler), p->context);
     switchkvm();
     p->ticks[priority] = p->ticks[priority] + 1;
     p->time[p->priority] = p->time[p->priority] - 1;
     getpinfo(&pstat);
   } 
   if((p->ticks[p->priority] != 0 && p->ticks[p->priority] % ticksPerPriority[p->priority] == 0 && p->time[p->priority] == 0)) {
   //else if ((p->ticks[p->priority] != 0 && p->ticks[p->priority] % ticksPerPriority[p->priority] == 0) || (p->time[p->priority] == 0)) {
	         //cprintf("%s has finished time slice. Moving to back of queue %d %d \n", p->name, p->priority, p->ticks[p->priority]);
       int a;
       for(a = 0; a < ptable.priorityLevelCount[priority]; a++) {
             if(ptable.queue[priority][a] == p->pid) {
                 break;
	     }
       }
       for(int z = a; z < ptable.priorityLevelCount[priority]; z++) {
	     ptable.queue[priority][z] = ptable.queue[priority][z+1];
       }
       ptable.queue[priority][ptable.priorityLevelCount[priority]] = p->pid;
       //cprintf("qtail updated. Time slice over.\n");
       p->qtail[priority] = p->qtail[priority] + 1;
       p->time[p->priority] = ticksPerPriority[p->priority];
   }
   
   getpinfo(&pstat);
   c->proc = 0;
   }
   release(&ptable.lock);
  }  
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
//void
//scheduler(void)
//{
//  struct proc *p;
//  struct cpu *c = mycpu();
//  c->proc = 0;
  
//  for(;;){
    // Enable interrupts on this processor.
//    sti();
    // Loop over process table looking for process to run.
/*    acquire(&ptable.lock);
    int priority;
    int y;
    int currentTickValue;
    //Loop starting with highest priority
    for(priority = 3; priority >= 0; priority--) {
      //cprintf("%d being checked. \n", ptable.priorityLevelCount[1]);
      //Loop over individual priority level
      for(y = 0; y <= ptable.priorityLevelCount[priority]; y++) {
	//cprintf("%d %d %d %d\n",priority, y, ptable.priorityLevelCount[priority], ptable.queue[priority][y]);
        int processToBeRunPID = ptable.queue[priority][y];
	for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++) {
           if(p->pid == processToBeRunPID) {
		//cprintf("%s chosen \n", p->name);
		break;
	   }
	}
       if(p->state == RUNNABLE) {
       //getpinfo(&pstat);
       //cprintf("Ëntered here! %s \n", p->name);
       //if number of ticks it has run for is equal to tick count of level
       //move other processes ahead and enqueue current process (p) to the end
       //also reset its tick counter for this priority level
           currentTickValue = p->ticks[priority];
	   //cprintf("%d \n", currentTickValue);
           if(currentTickValue != 0 && currentTickValue % ticksPerPriority[priority] == 0) {
	       //cprintf("TICK OVER \n");
               for(int z = 0; z < ptable.priorityLevelCount[priority]; z++) {
                    ptable.queue[priority][z] = ptable.queue[priority][z+1];
       	       }
	       ptable.queue[priority][ptable.priorityLevelCount[priority]] = p->pid;
               p->qtail[priority] = p->qtail[priority] + 1;
	   //    continue;
           }
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      //cprintf("%s \n", p->name);
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();
      p->ticks[priority] = currentTickValue + 1;
      getpinfo(&pstat);
      //cprintf("%d %s %d\n", p->qtail[0], p->name, p->priority);
      //if(p->state == ZOMBIE) {
	//  for(int z = y; z < ptable.priorityLevelCount[priority]; z++) {
        //        ptable.queue[priority][z] = ptable.queue[priority][z+1];
	//  }
	//  ptable.priorityLevelCount[p->priority]--;
      //}
      //cprintf("%d \n", ptable.priorityLevelCount[0]);
      //cprintf("Returned to scheduler() \n");
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
      priority = 3;
     }
    }
   }
   release(&ptable.lock);
 }
}
*/
// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  //ptable.queue[myproc()->priority][ptable.priorityLevelCount[myproc()->priority]] = myproc();
  //cprintf("Yielded! \n");
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;
  //cprintf("%s slept \n", p->name);
  //for(int z = 0; z < ptable.priorityLevelCount[p->priority]; z++) {
  //    ptable.queue[p->priority][z] = ptable.queue[p->priority][z+1];
  //} 
  //ptable.priorityLevelCount[p->priority] = ptable.priorityLevelCount[p->priority] - 1;
  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;
  int y;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan) {
      for(y = 0; y < ptable.priorityLevelCount[p->priority]; y++) {
        if(ptable.queue[p->priority][y] == p->pid) {
          break;
	}
      }
      for(int k=y; k < ptable.priorityLevelCount[p->priority]; k++) {
        ptable.queue[p->priority][k] = ptable.queue[p->priority][k+1];
      }
      //cprintf("%s woken \n", p->name);
      //ptable.priorityLevelCount[p->priority]++;
      ptable.queue[p->priority][ptable.priorityLevelCount[p->priority]] = p->pid;
      //cprintf("Woken up. Qtail updated.\n");
      if(p->time[p->priority] != 1) {
          p->qtail[p->priority] = p->qtail[p->priority] + 1;     
      } 
      p->state = RUNNABLE;
    }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING) {
        ptable.priorityLevelCount[p->priority]++;
        ptable.queue[p->priority][ptable.priorityLevelCount[p->priority]] = p->pid;
        p->state = RUNNABLE;
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

int 
setpri(int PID, int pri) {
    struct proc *p;
    int count = 0;
    //cprintf("Executing setpri\n");
    if(pri < 0 || pri > 3) {
      return -1;
    }
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        if(p->pid == PID) {
            pstat.priority[count]  = pri; 
	    acquire(&ptable.lock);
	    if(p->priority == pri) {
	       release(&ptable.lock);
	       return 0;
	    }
	    int prevPriority = p->priority;
	    p->priority = pri;
	    p->qtail[p->priority] = p->qtail[p->priority] + 1;
	    ptable.priorityLevelCount[p->priority]++;
	    ptable.queue[pri][ptable.priorityLevelCount[pri]] = p->pid;
	    int pLoc = 0;
	    for(int i =0; i< ptable.priorityLevelCount[prevPriority]; i++) {
	        if(PID == ptable.queue[prevPriority][i]) {
	            pLoc = i;
		}
	    }
	    for(int i = pLoc; i < ptable.priorityLevelCount[prevPriority]; i++) {
	        ptable.queue[prevPriority][i] = ptable.queue[prevPriority][i+1];
	    }

	    ptable.priorityLevelCount[prevPriority]--;
	    release(&ptable.lock);
            return 0;
        }
	count++;
    }
    return -1;
}

int
getpri(int PID) {
    struct proc *p;
    int count = 0;
    //cprintf("Executing getpri\n");
     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
         if(p->pid == PID) {
		 return pstat.priority[count];
	 }
	 count++;
     }
     return -1;
 }

int 
getpinfo(struct pstat *ps){
	int i = 0;
	if(!ps) {
	 return -1;
	}
	struct proc *p;
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	    ps->pid[i] = p->pid;
	    if(p->state == UNUSED || p->state == ZOMBIE || p->state == EMBRYO)
	    {
		    ps->inuse[i] = 0;
		   }
	    else{
		    ps->inuse[i] = 1;
	    }
	    ps->priority[i] = p->priority;
	    ps->state[i] = p->state;
	    for(int j = 0; j< 4; j++) {
	        ps->ticks[i][j] = p->ticks[j];
	    }
	    for(int j = 0; j<4; j++) {
		    ps->qtail[i][j] = p->qtail[j];
	    }
	    //cprintf("%d : %d : %d\n",ps->pid[i],ps->priority[i],ps->state[i]);
	    i++;
        }
	return 0;
}

int 
fork2(int pri)
{
    //cprintf("fork2:%d\n",pri);
    if(pri < 0 || pri > 3){
	    return -1;
    }
    /*
    int pid = fork();
    if(pid < 0)
        return -1;
    if(setpri(pid, pri) == -1) {
	    return -1;
    }*/
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
  //if(getpinfo(pstat)== -1){
  //{
  //  return -1;
  //}

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;
  np->priority = pri;
  ptable.priorityLevelCount[pri]++;
  ptable.queue[pri][ptable.priorityLevelCount[pri]] = np->pid;
  np->qtail[pri] = np->qtail[pri] + 1;
  release(&ptable.lock);
  if(getpinfo(&pstat) == -1) {
     return -1;
  }
  return pid;
}

