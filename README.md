# cs3400Kernel

(DONE) - Start a new project directory: copy over the xv6 Makefile, create a kernel directory, and copy all of the .h files into the kernel directory
Modify the Makefile:
  (DONE)- Remove "$U/initcode" as a dependency for the "$K/kernel" target
  (DONE)- Delete the "QEMUOPTS +=" lines (keep the line that creates it, but delete the three lines that build on it
  (DONE)- Remove "fs.img" as a dependency for the "qemu" target
  - Delete any "$K/foo.o" lines for .c files that are not needed. For example, "$K/vm.o \"
In the kernel directory, copy and modify any files that are needed:
  (DONE)- entry.S and swtch.S (no modifications)
  (DONE)- kernel.ld (delete the references to trampoline--there are 4 lines in a row that you can delete)
  (DONE)- start.c (delete timerinit and the call to timerinit)
  - main.c (delete init calls related to virtual memory, traps, interrupt controllers, anything disk for file system related)
  (maybe done, but might need to delete the last function)- console.c (delete the functions related to read(), write(), and interrupts)
  - uart.c (delete the functions related to interrupt-driven code paths: look for interrupt/sleep/wakeup references or anything related to reading from the uart)
  (DONE)- printf.c (no changes)
  (DONE)- string.c (no changes)
  (DONE)- spinlock.c (no changes)
  (DONE)- kalloc.c (no changes)
proc.c: this is the fun one!
  - delete proc_mapstacks, but first copy the code that allocates a physical stack page and transfer it to procinit, where you should use it to allocate a physical stack page for each process instead of using KSTACK to point it to the stack page that proc_mapstacks would have set up
  - delete any code related to trap frames, page tables, freeing processes, anything userspace, anything designed to service system calls, sleeping and waking up, etc.
  - set up some kernel threads in userinit. instead of crafting one userspace process, allocate several processes and make them runnable (delete anything related to trapframes, the user address space, cwd, etc.)
  - write a function to run in each kernel thread (see below for an example)
