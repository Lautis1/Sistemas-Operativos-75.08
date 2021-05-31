
obj/kern/kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

f0100000 <_start+0xeffffff4>:
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
_start = RELOC(entry)

.globl entry
.func entry
entry:
	movw	$0x1234,0x472			# warm boot
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3

	# Activar soporte de large pages
	movl %cr4, %eax
f010001d:	0f 20 e0             	mov    %cr4,%eax
	orl $CR4_PSE, %eax
f0100020:	83 c8 10             	or     $0x10,%eax
	movl %eax, %cr4
f0100023:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl	%cr0, %eax
f0100026:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100029:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f010002e:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100031:	b8 38 00 10 f0       	mov    $0xf0100038,%eax
	jmp	*%eax
f0100036:	ff e0                	jmp    *%eax

f0100038 <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f0100038:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f010003d:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100042:	e8 83 01 00 00       	call   f01001ca <i386_init>

f0100047 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f0100047:	eb fe                	jmp    f0100047 <spin>

f0100049 <lcr3>:
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100049:	0f 22 d8             	mov    %eax,%cr3
}
f010004c:	c3                   	ret    

f010004d <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f010004d:	89 c1                	mov    %eax,%ecx
f010004f:	89 d0                	mov    %edx,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100051:	f0 87 01             	lock xchg %eax,(%ecx)
		     : "+m" (*addr), "=a" (result)
		     : "1" (newval)
		     : "cc");
	return result;
}
f0100054:	c3                   	ret    

f0100055 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0100055:	55                   	push   %ebp
f0100056:	89 e5                	mov    %esp,%ebp
f0100058:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f010005b:	68 c0 23 12 f0       	push   $0xf01223c0
f0100060:	e8 44 61 00 00       	call   f01061a9 <spin_lock>
}
f0100065:	83 c4 10             	add    $0x10,%esp
f0100068:	c9                   	leave  
f0100069:	c3                   	ret    

f010006a <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
f010006a:	f3 0f 1e fb          	endbr32 
f010006e:	55                   	push   %ebp
f010006f:	89 e5                	mov    %esp,%ebp
f0100071:	56                   	push   %esi
f0100072:	53                   	push   %ebx
f0100073:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100076:	83 3d 80 2e 22 f0 00 	cmpl   $0x0,0xf0222e80
f010007d:	74 0f                	je     f010008e <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010007f:	83 ec 0c             	sub    $0xc,%esp
f0100082:	6a 00                	push   $0x0
f0100084:	e8 6c 0b 00 00       	call   f0100bf5 <monitor>
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	eb f1                	jmp    f010007f <_panic+0x15>
	panicstr = fmt;
f010008e:	89 35 80 2e 22 f0    	mov    %esi,0xf0222e80
	asm volatile("cli; cld");
f0100094:	fa                   	cli    
f0100095:	fc                   	cld    
	va_start(ap, fmt);
f0100096:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf(">>>\n>>> kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100099:	e8 06 5e 00 00       	call   f0105ea4 <cpunum>
f010009e:	ff 75 0c             	pushl  0xc(%ebp)
f01000a1:	ff 75 08             	pushl  0x8(%ebp)
f01000a4:	50                   	push   %eax
f01000a5:	68 60 65 10 f0       	push   $0xf0106560
f01000aa:	e8 5c 39 00 00       	call   f0103a0b <cprintf>
	vcprintf(fmt, ap);
f01000af:	83 c4 08             	add    $0x8,%esp
f01000b2:	53                   	push   %ebx
f01000b3:	56                   	push   %esi
f01000b4:	e8 28 39 00 00       	call   f01039e1 <vcprintf>
	cprintf("\n>>>\n");
f01000b9:	c7 04 24 d4 65 10 f0 	movl   $0xf01065d4,(%esp)
f01000c0:	e8 46 39 00 00       	call   f0103a0b <cprintf>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb b5                	jmp    f010007f <_panic+0x15>

f01000ca <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01000ca:	55                   	push   %ebp
f01000cb:	89 e5                	mov    %esp,%ebp
f01000cd:	53                   	push   %ebx
f01000ce:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f01000d1:	89 cb                	mov    %ecx,%ebx
f01000d3:	c1 eb 0c             	shr    $0xc,%ebx
f01000d6:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f01000dc:	73 0b                	jae    f01000e9 <_kaddr+0x1f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01000de:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f01000e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000e7:	c9                   	leave  
f01000e8:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000e9:	51                   	push   %ecx
f01000ea:	68 8c 65 10 f0       	push   $0xf010658c
f01000ef:	52                   	push   %edx
f01000f0:	50                   	push   %eax
f01000f1:	e8 74 ff ff ff       	call   f010006a <_panic>

f01000f6 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f01000f6:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01000fc:	76 07                	jbe    f0100105 <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f01000fe:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100104:	c3                   	ret    
{
f0100105:	55                   	push   %ebp
f0100106:	89 e5                	mov    %esp,%ebp
f0100108:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010010b:	51                   	push   %ecx
f010010c:	68 b0 65 10 f0       	push   $0xf01065b0
f0100111:	52                   	push   %edx
f0100112:	50                   	push   %eax
f0100113:	e8 52 ff ff ff       	call   f010006a <_panic>

f0100118 <boot_aps>:
{
f0100118:	55                   	push   %ebp
f0100119:	89 e5                	mov    %esp,%ebp
f010011b:	56                   	push   %esi
f010011c:	53                   	push   %ebx
	code = KADDR(MPENTRY_PADDR);
f010011d:	b9 00 70 00 00       	mov    $0x7000,%ecx
f0100122:	ba 69 00 00 00       	mov    $0x69,%edx
f0100127:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f010012c:	e8 99 ff ff ff       	call   f01000ca <_kaddr>
f0100131:	89 c6                	mov    %eax,%esi
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100133:	83 ec 04             	sub    $0x4,%esp
f0100136:	b8 a2 5a 10 f0       	mov    $0xf0105aa2,%eax
f010013b:	2d 20 5a 10 f0       	sub    $0xf0105a20,%eax
f0100140:	50                   	push   %eax
f0100141:	68 20 5a 10 f0       	push   $0xf0105a20
f0100146:	56                   	push   %esi
f0100147:	e8 15 57 00 00       	call   f0105861 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010014c:	83 c4 10             	add    $0x10,%esp
f010014f:	bb 20 30 22 f0       	mov    $0xf0223020,%ebx
f0100154:	eb 4a                	jmp    f01001a0 <boot_aps+0x88>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100156:	89 d8                	mov    %ebx,%eax
f0100158:	2d 20 30 22 f0       	sub    $0xf0223020,%eax
f010015d:	c1 f8 02             	sar    $0x2,%eax
f0100160:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100166:	c1 e0 0f             	shl    $0xf,%eax
f0100169:	8d 80 00 c0 22 f0    	lea    -0xfdd4000(%eax),%eax
f010016f:	a3 84 2e 22 f0       	mov    %eax,0xf0222e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100174:	89 f1                	mov    %esi,%ecx
f0100176:	ba 74 00 00 00       	mov    $0x74,%edx
f010017b:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f0100180:	e8 71 ff ff ff       	call   f01000f6 <_paddr>
f0100185:	83 ec 08             	sub    $0x8,%esp
f0100188:	50                   	push   %eax
f0100189:	0f b6 03             	movzbl (%ebx),%eax
f010018c:	50                   	push   %eax
f010018d:	e8 86 5e 00 00       	call   f0106018 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f0100192:	83 c4 10             	add    $0x10,%esp
f0100195:	8b 43 04             	mov    0x4(%ebx),%eax
f0100198:	83 f8 01             	cmp    $0x1,%eax
f010019b:	75 f8                	jne    f0100195 <boot_aps+0x7d>
	for (c = cpus; c < cpus + ncpu; c++) {
f010019d:	83 c3 74             	add    $0x74,%ebx
f01001a0:	6b 05 c4 33 22 f0 74 	imul   $0x74,0xf02233c4,%eax
f01001a7:	05 20 30 22 f0       	add    $0xf0223020,%eax
f01001ac:	39 c3                	cmp    %eax,%ebx
f01001ae:	73 13                	jae    f01001c3 <boot_aps+0xab>
		if (c == cpus + cpunum())  // We've started already.
f01001b0:	e8 ef 5c 00 00       	call   f0105ea4 <cpunum>
f01001b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001b8:	05 20 30 22 f0       	add    $0xf0223020,%eax
f01001bd:	39 c3                	cmp    %eax,%ebx
f01001bf:	74 dc                	je     f010019d <boot_aps+0x85>
f01001c1:	eb 93                	jmp    f0100156 <boot_aps+0x3e>
}
f01001c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c6:	5b                   	pop    %ebx
f01001c7:	5e                   	pop    %esi
f01001c8:	5d                   	pop    %ebp
f01001c9:	c3                   	ret    

f01001ca <i386_init>:
{
f01001ca:	f3 0f 1e fb          	endbr32 
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	83 ec 0c             	sub    $0xc,%esp
	memset(__bss_start, 0, end - __bss_start);
f01001d4:	b8 08 40 26 f0       	mov    $0xf0264008,%eax
f01001d9:	2d 00 10 22 f0       	sub    $0xf0221000,%eax
f01001de:	50                   	push   %eax
f01001df:	6a 00                	push   $0x0
f01001e1:	68 00 10 22 f0       	push   $0xf0221000
f01001e6:	e8 28 56 00 00       	call   f0105813 <memset>
	cons_init();
f01001eb:	e8 1a 07 00 00       	call   f010090a <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01001f0:	83 c4 08             	add    $0x8,%esp
f01001f3:	68 ac 1a 00 00       	push   $0x1aac
f01001f8:	68 e6 65 10 f0       	push   $0xf01065e6
f01001fd:	e8 09 38 00 00       	call   f0103a0b <cprintf>
	mem_init();
f0100202:	e8 75 2b 00 00       	call   f0102d7c <mem_init>
	env_init();
f0100207:	e8 4f 31 00 00       	call   f010335b <env_init>
	trap_init();
f010020c:	e8 00 39 00 00       	call   f0103b11 <trap_init>
	mp_init();
f0100211:	e8 d1 5a 00 00       	call   f0105ce7 <mp_init>
	lapic_init();
f0100216:	e8 a3 5c 00 00       	call   f0105ebe <lapic_init>
	pic_init();
f010021b:	e8 9d 36 00 00       	call   f01038bd <pic_init>
	lock_kernel();
f0100220:	e8 30 fe ff ff       	call   f0100055 <lock_kernel>
	boot_aps();
f0100225:	e8 ee fe ff ff       	call   f0100118 <boot_aps>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010022a:	83 c4 08             	add    $0x8,%esp
f010022d:	6a 01                	push   $0x1
f010022f:	68 cc d2 1d f0       	push   $0xf01dd2cc
f0100234:	e8 73 32 00 00       	call   f01034ac <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100239:	83 c4 08             	add    $0x8,%esp
f010023c:	6a 00                	push   $0x0
f010023e:	68 38 07 21 f0       	push   $0xf0210738
f0100243:	e8 64 32 00 00       	call   f01034ac <env_create>
	kbd_intr();
f0100248:	e8 3c 06 00 00       	call   f0100889 <kbd_intr>
	sched_yield();
f010024d:	e8 2a 43 00 00       	call   f010457c <sched_yield>

f0100252 <mp_main>:
{
f0100252:	f3 0f 1e fb          	endbr32 
f0100256:	55                   	push   %ebp
f0100257:	89 e5                	mov    %esp,%ebp
f0100259:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f010025c:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0100262:	ba 80 00 00 00       	mov    $0x80,%edx
f0100267:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f010026c:	e8 85 fe ff ff       	call   f01000f6 <_paddr>
f0100271:	e8 d3 fd ff ff       	call   f0100049 <lcr3>
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100276:	e8 29 5c 00 00       	call   f0105ea4 <cpunum>
f010027b:	83 ec 08             	sub    $0x8,%esp
f010027e:	50                   	push   %eax
f010027f:	68 01 66 10 f0       	push   $0xf0106601
f0100284:	e8 82 37 00 00       	call   f0103a0b <cprintf>
	lapic_init();
f0100289:	e8 30 5c 00 00       	call   f0105ebe <lapic_init>
	env_init_percpu();
f010028e:	e8 8d 30 00 00       	call   f0103320 <env_init_percpu>
	trap_init_percpu();
f0100293:	e8 e5 37 00 00       	call   f0103a7d <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED);  // tell boot_aps() we're up
f0100298:	e8 07 5c 00 00       	call   f0105ea4 <cpunum>
f010029d:	6b c0 74             	imul   $0x74,%eax,%eax
f01002a0:	05 24 30 22 f0       	add    $0xf0223024,%eax
f01002a5:	ba 01 00 00 00       	mov    $0x1,%edx
f01002aa:	e8 9e fd ff ff       	call   f010004d <xchg>
	lock_kernel();
f01002af:	e8 a1 fd ff ff       	call   f0100055 <lock_kernel>
	sched_yield();
f01002b4:	e8 c3 42 00 00       	call   f010457c <sched_yield>

f01002b9 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...)
{
f01002b9:	f3 0f 1e fb          	endbr32 
f01002bd:	55                   	push   %ebp
f01002be:	89 e5                	mov    %esp,%ebp
f01002c0:	53                   	push   %ebx
f01002c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002c4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002c7:	ff 75 0c             	pushl  0xc(%ebp)
f01002ca:	ff 75 08             	pushl  0x8(%ebp)
f01002cd:	68 17 66 10 f0       	push   $0xf0106617
f01002d2:	e8 34 37 00 00       	call   f0103a0b <cprintf>
	vcprintf(fmt, ap);
f01002d7:	83 c4 08             	add    $0x8,%esp
f01002da:	53                   	push   %ebx
f01002db:	ff 75 10             	pushl  0x10(%ebp)
f01002de:	e8 fe 36 00 00       	call   f01039e1 <vcprintf>
	cprintf("\n");
f01002e3:	c7 04 24 f5 77 10 f0 	movl   $0xf01077f5,(%esp)
f01002ea:	e8 1c 37 00 00       	call   f0103a0b <cprintf>
	va_end(ap);
}
f01002ef:	83 c4 10             	add    $0x10,%esp
f01002f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f5:	c9                   	leave  
f01002f6:	c3                   	ret    

f01002f7 <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f7:	89 c2                	mov    %eax,%edx
f01002f9:	ec                   	in     (%dx),%al
}
f01002fa:	c3                   	ret    

f01002fb <outb>:
{
f01002fb:	89 c1                	mov    %eax,%ecx
f01002fd:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	89 ca                	mov    %ecx,%edx
f0100301:	ee                   	out    %al,(%dx)
}
f0100302:	c3                   	ret    

f0100303 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100303:	55                   	push   %ebp
f0100304:	89 e5                	mov    %esp,%ebp
f0100306:	83 ec 08             	sub    $0x8,%esp
	inb(0x84);
f0100309:	b8 84 00 00 00       	mov    $0x84,%eax
f010030e:	e8 e4 ff ff ff       	call   f01002f7 <inb>
	inb(0x84);
f0100313:	b8 84 00 00 00       	mov    $0x84,%eax
f0100318:	e8 da ff ff ff       	call   f01002f7 <inb>
	inb(0x84);
f010031d:	b8 84 00 00 00       	mov    $0x84,%eax
f0100322:	e8 d0 ff ff ff       	call   f01002f7 <inb>
	inb(0x84);
f0100327:	b8 84 00 00 00       	mov    $0x84,%eax
f010032c:	e8 c6 ff ff ff       	call   f01002f7 <inb>
}
f0100331:	c9                   	leave  
f0100332:	c3                   	ret    

f0100333 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100333:	f3 0f 1e fb          	endbr32 
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	83 ec 08             	sub    $0x8,%esp
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010033d:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100342:	e8 b0 ff ff ff       	call   f01002f7 <inb>
f0100347:	a8 01                	test   $0x1,%al
f0100349:	74 0f                	je     f010035a <serial_proc_data+0x27>
		return -1;
	return inb(COM1+COM_RX);
f010034b:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100350:	e8 a2 ff ff ff       	call   f01002f7 <inb>
f0100355:	0f b6 c0             	movzbl %al,%eax
}
f0100358:	c9                   	leave  
f0100359:	c3                   	ret    
		return -1;
f010035a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010035f:	eb f7                	jmp    f0100358 <serial_proc_data+0x25>

f0100361 <serial_putc>:
		cons_intr(serial_proc_data);
}

static void
serial_putc(int c)
{
f0100361:	55                   	push   %ebp
f0100362:	89 e5                	mov    %esp,%ebp
f0100364:	56                   	push   %esi
f0100365:	53                   	push   %ebx
f0100366:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0;
f0100368:	bb 00 00 00 00       	mov    $0x0,%ebx
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010036d:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100372:	e8 80 ff ff ff       	call   f01002f7 <inb>
f0100377:	a8 20                	test   $0x20,%al
f0100379:	75 12                	jne    f010038d <serial_putc+0x2c>
f010037b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100381:	7f 0a                	jg     f010038d <serial_putc+0x2c>
	     i++)
		delay();
f0100383:	e8 7b ff ff ff       	call   f0100303 <delay>
	     i++)
f0100388:	83 c3 01             	add    $0x1,%ebx
f010038b:	eb e0                	jmp    f010036d <serial_putc+0xc>

	outb(COM1 + COM_TX, c);
f010038d:	89 f0                	mov    %esi,%eax
f010038f:	0f b6 d0             	movzbl %al,%edx
f0100392:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100397:	e8 5f ff ff ff       	call   f01002fb <outb>
}
f010039c:	5b                   	pop    %ebx
f010039d:	5e                   	pop    %esi
f010039e:	5d                   	pop    %ebp
f010039f:	c3                   	ret    

f01003a0 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f01003a0:	55                   	push   %ebp
f01003a1:	89 e5                	mov    %esp,%ebp
f01003a3:	56                   	push   %esi
f01003a4:	53                   	push   %ebx
f01003a5:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ac:	b8 79 03 00 00       	mov    $0x379,%eax
f01003b1:	e8 41 ff ff ff       	call   f01002f7 <inb>
f01003b6:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003bc:	7f 0e                	jg     f01003cc <lpt_putc+0x2c>
f01003be:	84 c0                	test   %al,%al
f01003c0:	78 0a                	js     f01003cc <lpt_putc+0x2c>
		delay();
f01003c2:	e8 3c ff ff ff       	call   f0100303 <delay>
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c7:	83 c3 01             	add    $0x1,%ebx
f01003ca:	eb e0                	jmp    f01003ac <lpt_putc+0xc>
	outb(0x378+0, c);
f01003cc:	89 f0                	mov    %esi,%eax
f01003ce:	0f b6 d0             	movzbl %al,%edx
f01003d1:	b8 78 03 00 00       	mov    $0x378,%eax
f01003d6:	e8 20 ff ff ff       	call   f01002fb <outb>
	outb(0x378+2, 0x08|0x04|0x01);
f01003db:	ba 0d 00 00 00       	mov    $0xd,%edx
f01003e0:	b8 7a 03 00 00       	mov    $0x37a,%eax
f01003e5:	e8 11 ff ff ff       	call   f01002fb <outb>
	outb(0x378+2, 0x08);
f01003ea:	ba 08 00 00 00       	mov    $0x8,%edx
f01003ef:	b8 7a 03 00 00       	mov    $0x37a,%eax
f01003f4:	e8 02 ff ff ff       	call   f01002fb <outb>
}
f01003f9:	5b                   	pop    %ebx
f01003fa:	5e                   	pop    %esi
f01003fb:	5d                   	pop    %ebp
f01003fc:	c3                   	ret    

f01003fd <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f01003fd:	55                   	push   %ebp
f01003fe:	89 e5                	mov    %esp,%ebp
f0100400:	57                   	push   %edi
f0100401:	56                   	push   %esi
f0100402:	53                   	push   %ebx
f0100403:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100406:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010040d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100414:	5a a5 
	if (*cp != 0xA55A) {
f0100416:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010041d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100421:	74 63                	je     f0100486 <cga_init+0x89>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100423:	c7 05 30 12 22 f0 b4 	movl   $0x3b4,0xf0221230
f010042a:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010042d:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100434:	8b 35 30 12 22 f0    	mov    0xf0221230,%esi
f010043a:	ba 0e 00 00 00       	mov    $0xe,%edx
f010043f:	89 f0                	mov    %esi,%eax
f0100441:	e8 b5 fe ff ff       	call   f01002fb <outb>
	pos = inb(addr_6845 + 1) << 8;
f0100446:	8d 7e 01             	lea    0x1(%esi),%edi
f0100449:	89 f8                	mov    %edi,%eax
f010044b:	e8 a7 fe ff ff       	call   f01002f7 <inb>
f0100450:	0f b6 d8             	movzbl %al,%ebx
f0100453:	c1 e3 08             	shl    $0x8,%ebx
	outb(addr_6845, 15);
f0100456:	ba 0f 00 00 00       	mov    $0xf,%edx
f010045b:	89 f0                	mov    %esi,%eax
f010045d:	e8 99 fe ff ff       	call   f01002fb <outb>
	pos |= inb(addr_6845 + 1);
f0100462:	89 f8                	mov    %edi,%eax
f0100464:	e8 8e fe ff ff       	call   f01002f7 <inb>

	crt_buf = (uint16_t*) cp;
f0100469:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010046c:	89 0d 2c 12 22 f0    	mov    %ecx,0xf022122c
	pos |= inb(addr_6845 + 1);
f0100472:	0f b6 c0             	movzbl %al,%eax
f0100475:	09 c3                	or     %eax,%ebx
	crt_pos = pos;
f0100477:	66 89 1d 28 12 22 f0 	mov    %bx,0xf0221228
}
f010047e:	83 c4 1c             	add    $0x1c,%esp
f0100481:	5b                   	pop    %ebx
f0100482:	5e                   	pop    %esi
f0100483:	5f                   	pop    %edi
f0100484:	5d                   	pop    %ebp
f0100485:	c3                   	ret    
		*cp = was;
f0100486:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010048d:	c7 05 30 12 22 f0 d4 	movl   $0x3d4,0xf0221230
f0100494:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100497:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010049e:	eb 94                	jmp    f0100434 <cga_init+0x37>

f01004a0 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	53                   	push   %ebx
f01004a4:	83 ec 04             	sub    $0x4,%esp
f01004a7:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01004a9:	ff d3                	call   *%ebx
f01004ab:	83 f8 ff             	cmp    $0xffffffff,%eax
f01004ae:	74 29                	je     f01004d9 <cons_intr+0x39>
		if (c == 0)
f01004b0:	85 c0                	test   %eax,%eax
f01004b2:	74 f5                	je     f01004a9 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01004b4:	8b 0d 24 12 22 f0    	mov    0xf0221224,%ecx
f01004ba:	8d 51 01             	lea    0x1(%ecx),%edx
f01004bd:	88 81 20 10 22 f0    	mov    %al,-0xfddefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01004c3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01004c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ce:	0f 44 d0             	cmove  %eax,%edx
f01004d1:	89 15 24 12 22 f0    	mov    %edx,0xf0221224
f01004d7:	eb d0                	jmp    f01004a9 <cons_intr+0x9>
	}
}
f01004d9:	83 c4 04             	add    $0x4,%esp
f01004dc:	5b                   	pop    %ebx
f01004dd:	5d                   	pop    %ebp
f01004de:	c3                   	ret    

f01004df <kbd_proc_data>:
{
f01004df:	f3 0f 1e fb          	endbr32 
f01004e3:	55                   	push   %ebp
f01004e4:	89 e5                	mov    %esp,%ebp
f01004e6:	53                   	push   %ebx
f01004e7:	83 ec 04             	sub    $0x4,%esp
	stat = inb(KBSTATP);
f01004ea:	b8 64 00 00 00       	mov    $0x64,%eax
f01004ef:	e8 03 fe ff ff       	call   f01002f7 <inb>
	if ((stat & KBS_DIB) == 0)
f01004f4:	a8 01                	test   $0x1,%al
f01004f6:	0f 84 f7 00 00 00    	je     f01005f3 <kbd_proc_data+0x114>
	if (stat & KBS_TERR)
f01004fc:	a8 20                	test   $0x20,%al
f01004fe:	0f 85 f6 00 00 00    	jne    f01005fa <kbd_proc_data+0x11b>
	data = inb(KBDATAP);
f0100504:	b8 60 00 00 00       	mov    $0x60,%eax
f0100509:	e8 e9 fd ff ff       	call   f01002f7 <inb>
	if (data == 0xE0) {
f010050e:	3c e0                	cmp    $0xe0,%al
f0100510:	74 61                	je     f0100573 <kbd_proc_data+0x94>
	} else if (data & 0x80) {
f0100512:	84 c0                	test   %al,%al
f0100514:	78 70                	js     f0100586 <kbd_proc_data+0xa7>
	} else if (shift & E0ESC) {
f0100516:	8b 15 00 10 22 f0    	mov    0xf0221000,%edx
f010051c:	f6 c2 40             	test   $0x40,%dl
f010051f:	74 0c                	je     f010052d <kbd_proc_data+0x4e>
		data |= 0x80;
f0100521:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100524:	83 e2 bf             	and    $0xffffffbf,%edx
f0100527:	89 15 00 10 22 f0    	mov    %edx,0xf0221000
	shift |= shiftcode[data];
f010052d:	0f b6 c0             	movzbl %al,%eax
f0100530:	0f b6 90 80 67 10 f0 	movzbl -0xfef9880(%eax),%edx
f0100537:	0b 15 00 10 22 f0    	or     0xf0221000,%edx
	shift ^= togglecode[data];
f010053d:	0f b6 88 80 66 10 f0 	movzbl -0xfef9980(%eax),%ecx
f0100544:	31 ca                	xor    %ecx,%edx
f0100546:	89 15 00 10 22 f0    	mov    %edx,0xf0221000
	c = charcode[shift & (CTL | SHIFT)][data];
f010054c:	89 d1                	mov    %edx,%ecx
f010054e:	83 e1 03             	and    $0x3,%ecx
f0100551:	8b 0c 8d 60 66 10 f0 	mov    -0xfef99a0(,%ecx,4),%ecx
f0100558:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010055c:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010055f:	f6 c2 08             	test   $0x8,%dl
f0100562:	74 5f                	je     f01005c3 <kbd_proc_data+0xe4>
		if ('a' <= c && c <= 'z')
f0100564:	89 d8                	mov    %ebx,%eax
f0100566:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100569:	83 f9 19             	cmp    $0x19,%ecx
f010056c:	77 49                	ja     f01005b7 <kbd_proc_data+0xd8>
			c += 'A' - 'a';
f010056e:	83 eb 20             	sub    $0x20,%ebx
f0100571:	eb 0c                	jmp    f010057f <kbd_proc_data+0xa0>
		shift |= E0ESC;
f0100573:	83 0d 00 10 22 f0 40 	orl    $0x40,0xf0221000
		return 0;
f010057a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010057f:	89 d8                	mov    %ebx,%eax
f0100581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100584:	c9                   	leave  
f0100585:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100586:	8b 15 00 10 22 f0    	mov    0xf0221000,%edx
f010058c:	89 c1                	mov    %eax,%ecx
f010058e:	83 e1 7f             	and    $0x7f,%ecx
f0100591:	f6 c2 40             	test   $0x40,%dl
f0100594:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100597:	0f b6 c0             	movzbl %al,%eax
f010059a:	0f b6 80 80 67 10 f0 	movzbl -0xfef9880(%eax),%eax
f01005a1:	83 c8 40             	or     $0x40,%eax
f01005a4:	0f b6 c0             	movzbl %al,%eax
f01005a7:	f7 d0                	not    %eax
f01005a9:	21 d0                	and    %edx,%eax
f01005ab:	a3 00 10 22 f0       	mov    %eax,0xf0221000
		return 0;
f01005b0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005b5:	eb c8                	jmp    f010057f <kbd_proc_data+0xa0>
		else if ('A' <= c && c <= 'Z')
f01005b7:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f01005ba:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01005bd:	83 f8 1a             	cmp    $0x1a,%eax
f01005c0:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005c3:	f7 d2                	not    %edx
f01005c5:	f6 c2 06             	test   $0x6,%dl
f01005c8:	75 b5                	jne    f010057f <kbd_proc_data+0xa0>
f01005ca:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005d0:	75 ad                	jne    f010057f <kbd_proc_data+0xa0>
		cprintf("Rebooting!\n");
f01005d2:	83 ec 0c             	sub    $0xc,%esp
f01005d5:	68 31 66 10 f0       	push   $0xf0106631
f01005da:	e8 2c 34 00 00       	call   f0103a0b <cprintf>
		outb(0x92, 0x3); // courtesy of Chris Frost
f01005df:	ba 03 00 00 00       	mov    $0x3,%edx
f01005e4:	b8 92 00 00 00       	mov    $0x92,%eax
f01005e9:	e8 0d fd ff ff       	call   f01002fb <outb>
f01005ee:	83 c4 10             	add    $0x10,%esp
f01005f1:	eb 8c                	jmp    f010057f <kbd_proc_data+0xa0>
		return -1;
f01005f3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005f8:	eb 85                	jmp    f010057f <kbd_proc_data+0xa0>
		return -1;
f01005fa:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005ff:	e9 7b ff ff ff       	jmp    f010057f <kbd_proc_data+0xa0>

f0100604 <serial_init>:
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	53                   	push   %ebx
f0100608:	83 ec 04             	sub    $0x4,%esp
	outb(COM1+COM_FCR, 0);
f010060b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100610:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f0100615:	e8 e1 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_LCR, COM_LCR_DLAB);
f010061a:	ba 80 00 00 00       	mov    $0x80,%edx
f010061f:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f0100624:	e8 d2 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_DLL, (uint8_t) (115200 / 9600));
f0100629:	ba 0c 00 00 00       	mov    $0xc,%edx
f010062e:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100633:	e8 c3 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_DLM, 0);
f0100638:	ba 00 00 00 00       	mov    $0x0,%edx
f010063d:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f0100642:	e8 b4 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);
f0100647:	ba 03 00 00 00       	mov    $0x3,%edx
f010064c:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f0100651:	e8 a5 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_MCR, 0);
f0100656:	ba 00 00 00 00       	mov    $0x0,%edx
f010065b:	b8 fc 03 00 00       	mov    $0x3fc,%eax
f0100660:	e8 96 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_IER, COM_IER_RDI);
f0100665:	ba 01 00 00 00       	mov    $0x1,%edx
f010066a:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f010066f:	e8 87 fc ff ff       	call   f01002fb <outb>
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100674:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100679:	e8 79 fc ff ff       	call   f01002f7 <inb>
f010067e:	89 c3                	mov    %eax,%ebx
f0100680:	3c ff                	cmp    $0xff,%al
f0100682:	0f 95 05 34 12 22 f0 	setne  0xf0221234
	(void) inb(COM1+COM_IIR);
f0100689:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f010068e:	e8 64 fc ff ff       	call   f01002f7 <inb>
	(void) inb(COM1+COM_RX);
f0100693:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100698:	e8 5a fc ff ff       	call   f01002f7 <inb>
	if (serial_exists)
f010069d:	80 fb ff             	cmp    $0xff,%bl
f01006a0:	75 05                	jne    f01006a7 <serial_init+0xa3>
}
f01006a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006a5:	c9                   	leave  
f01006a6:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f01006a7:	83 ec 0c             	sub    $0xc,%esp
f01006aa:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006b1:	25 ef ff 00 00       	and    $0xffef,%eax
f01006b6:	50                   	push   %eax
f01006b7:	e8 74 31 00 00       	call   f0103830 <irq_setmask_8259A>
f01006bc:	83 c4 10             	add    $0x10,%esp
}
f01006bf:	eb e1                	jmp    f01006a2 <serial_init+0x9e>

f01006c1 <cga_putc>:
{
f01006c1:	55                   	push   %ebp
f01006c2:	89 e5                	mov    %esp,%ebp
f01006c4:	57                   	push   %edi
f01006c5:	56                   	push   %esi
f01006c6:	53                   	push   %ebx
f01006c7:	83 ec 0c             	sub    $0xc,%esp
		c |= 0x0700;
f01006ca:	89 c2                	mov    %eax,%edx
f01006cc:	80 ce 07             	or     $0x7,%dh
f01006cf:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01006d4:	0f 44 c2             	cmove  %edx,%eax
	switch (c & 0xff) {
f01006d7:	3c 0a                	cmp    $0xa,%al
f01006d9:	0f 84 f0 00 00 00    	je     f01007cf <cga_putc+0x10e>
f01006df:	0f b6 d0             	movzbl %al,%edx
f01006e2:	83 fa 0a             	cmp    $0xa,%edx
f01006e5:	7f 46                	jg     f010072d <cga_putc+0x6c>
f01006e7:	83 fa 08             	cmp    $0x8,%edx
f01006ea:	0f 84 b5 00 00 00    	je     f01007a5 <cga_putc+0xe4>
f01006f0:	83 fa 09             	cmp    $0x9,%edx
f01006f3:	0f 85 e3 00 00 00    	jne    f01007dc <cga_putc+0x11b>
		cons_putc(' ');
f01006f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01006fe:	e8 44 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f0100703:	b8 20 00 00 00       	mov    $0x20,%eax
f0100708:	e8 3a 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f010070d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100712:	e8 30 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f0100717:	b8 20 00 00 00       	mov    $0x20,%eax
f010071c:	e8 26 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f0100721:	b8 20 00 00 00       	mov    $0x20,%eax
f0100726:	e8 1c 01 00 00       	call   f0100847 <cons_putc>
		break;
f010072b:	eb 25                	jmp    f0100752 <cga_putc+0x91>
	switch (c & 0xff) {
f010072d:	83 fa 0d             	cmp    $0xd,%edx
f0100730:	0f 85 a6 00 00 00    	jne    f01007dc <cga_putc+0x11b>
		crt_pos -= (crt_pos % CRT_COLS);
f0100736:	0f b7 05 28 12 22 f0 	movzwl 0xf0221228,%eax
f010073d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100743:	c1 e8 16             	shr    $0x16,%eax
f0100746:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100749:	c1 e0 04             	shl    $0x4,%eax
f010074c:	66 a3 28 12 22 f0    	mov    %ax,0xf0221228
	if (crt_pos >= CRT_SIZE) {
f0100752:	66 81 3d 28 12 22 f0 	cmpw   $0x7cf,0xf0221228
f0100759:	cf 07 
f010075b:	0f 87 9e 00 00 00    	ja     f01007ff <cga_putc+0x13e>
	outb(addr_6845, 14);
f0100761:	8b 3d 30 12 22 f0    	mov    0xf0221230,%edi
f0100767:	ba 0e 00 00 00       	mov    $0xe,%edx
f010076c:	89 f8                	mov    %edi,%eax
f010076e:	e8 88 fb ff ff       	call   f01002fb <outb>
	outb(addr_6845 + 1, crt_pos >> 8);
f0100773:	0f b7 1d 28 12 22 f0 	movzwl 0xf0221228,%ebx
f010077a:	8d 77 01             	lea    0x1(%edi),%esi
f010077d:	0f b6 d7             	movzbl %bh,%edx
f0100780:	89 f0                	mov    %esi,%eax
f0100782:	e8 74 fb ff ff       	call   f01002fb <outb>
	outb(addr_6845, 15);
f0100787:	ba 0f 00 00 00       	mov    $0xf,%edx
f010078c:	89 f8                	mov    %edi,%eax
f010078e:	e8 68 fb ff ff       	call   f01002fb <outb>
	outb(addr_6845 + 1, crt_pos);
f0100793:	0f b6 d3             	movzbl %bl,%edx
f0100796:	89 f0                	mov    %esi,%eax
f0100798:	e8 5e fb ff ff       	call   f01002fb <outb>
}
f010079d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a0:	5b                   	pop    %ebx
f01007a1:	5e                   	pop    %esi
f01007a2:	5f                   	pop    %edi
f01007a3:	5d                   	pop    %ebp
f01007a4:	c3                   	ret    
		if (crt_pos > 0) {
f01007a5:	0f b7 15 28 12 22 f0 	movzwl 0xf0221228,%edx
f01007ac:	66 85 d2             	test   %dx,%dx
f01007af:	74 b0                	je     f0100761 <cga_putc+0xa0>
			crt_pos--;
f01007b1:	83 ea 01             	sub    $0x1,%edx
f01007b4:	66 89 15 28 12 22 f0 	mov    %dx,0xf0221228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01007bb:	0f b7 d2             	movzwl %dx,%edx
f01007be:	b0 00                	mov    $0x0,%al
f01007c0:	83 c8 20             	or     $0x20,%eax
f01007c3:	8b 0d 2c 12 22 f0    	mov    0xf022122c,%ecx
f01007c9:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01007cd:	eb 83                	jmp    f0100752 <cga_putc+0x91>
		crt_pos += CRT_COLS;
f01007cf:	66 83 05 28 12 22 f0 	addw   $0x50,0xf0221228
f01007d6:	50 
f01007d7:	e9 5a ff ff ff       	jmp    f0100736 <cga_putc+0x75>
		crt_buf[crt_pos++] = c;		/* write the character */
f01007dc:	0f b7 15 28 12 22 f0 	movzwl 0xf0221228,%edx
f01007e3:	8d 4a 01             	lea    0x1(%edx),%ecx
f01007e6:	66 89 0d 28 12 22 f0 	mov    %cx,0xf0221228
f01007ed:	0f b7 d2             	movzwl %dx,%edx
f01007f0:	8b 0d 2c 12 22 f0    	mov    0xf022122c,%ecx
f01007f6:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
		break;
f01007fa:	e9 53 ff ff ff       	jmp    f0100752 <cga_putc+0x91>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01007ff:	a1 2c 12 22 f0       	mov    0xf022122c,%eax
f0100804:	83 ec 04             	sub    $0x4,%esp
f0100807:	68 00 0f 00 00       	push   $0xf00
f010080c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100812:	52                   	push   %edx
f0100813:	50                   	push   %eax
f0100814:	e8 48 50 00 00       	call   f0105861 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100819:	8b 15 2c 12 22 f0    	mov    0xf022122c,%edx
f010081f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100825:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010082b:	83 c4 10             	add    $0x10,%esp
f010082e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100833:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100836:	39 d0                	cmp    %edx,%eax
f0100838:	75 f4                	jne    f010082e <cga_putc+0x16d>
		crt_pos -= CRT_COLS;
f010083a:	66 83 2d 28 12 22 f0 	subw   $0x50,0xf0221228
f0100841:	50 
f0100842:	e9 1a ff ff ff       	jmp    f0100761 <cga_putc+0xa0>

f0100847 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100847:	55                   	push   %ebp
f0100848:	89 e5                	mov    %esp,%ebp
f010084a:	53                   	push   %ebx
f010084b:	83 ec 04             	sub    $0x4,%esp
f010084e:	89 c3                	mov    %eax,%ebx
	serial_putc(c);
f0100850:	e8 0c fb ff ff       	call   f0100361 <serial_putc>
	lpt_putc(c);
f0100855:	89 d8                	mov    %ebx,%eax
f0100857:	e8 44 fb ff ff       	call   f01003a0 <lpt_putc>
	cga_putc(c);
f010085c:	89 d8                	mov    %ebx,%eax
f010085e:	e8 5e fe ff ff       	call   f01006c1 <cga_putc>
}
f0100863:	83 c4 04             	add    $0x4,%esp
f0100866:	5b                   	pop    %ebx
f0100867:	5d                   	pop    %ebp
f0100868:	c3                   	ret    

f0100869 <serial_intr>:
{
f0100869:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f010086d:	80 3d 34 12 22 f0 00 	cmpb   $0x0,0xf0221234
f0100874:	75 01                	jne    f0100877 <serial_intr+0xe>
f0100876:	c3                   	ret    
{
f0100877:	55                   	push   %ebp
f0100878:	89 e5                	mov    %esp,%ebp
f010087a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010087d:	b8 33 03 10 f0       	mov    $0xf0100333,%eax
f0100882:	e8 19 fc ff ff       	call   f01004a0 <cons_intr>
}
f0100887:	c9                   	leave  
f0100888:	c3                   	ret    

f0100889 <kbd_intr>:
{
f0100889:	f3 0f 1e fb          	endbr32 
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
f0100890:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100893:	b8 df 04 10 f0       	mov    $0xf01004df,%eax
f0100898:	e8 03 fc ff ff       	call   f01004a0 <cons_intr>
}
f010089d:	c9                   	leave  
f010089e:	c3                   	ret    

f010089f <kbd_init>:
{
f010089f:	55                   	push   %ebp
f01008a0:	89 e5                	mov    %esp,%ebp
f01008a2:	83 ec 08             	sub    $0x8,%esp
	kbd_intr();
f01008a5:	e8 df ff ff ff       	call   f0100889 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01008aa:	83 ec 0c             	sub    $0xc,%esp
f01008ad:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01008b4:	25 fd ff 00 00       	and    $0xfffd,%eax
f01008b9:	50                   	push   %eax
f01008ba:	e8 71 2f 00 00       	call   f0103830 <irq_setmask_8259A>
}
f01008bf:	83 c4 10             	add    $0x10,%esp
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <cons_getc>:
{
f01008c4:	f3 0f 1e fb          	endbr32 
f01008c8:	55                   	push   %ebp
f01008c9:	89 e5                	mov    %esp,%ebp
f01008cb:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01008ce:	e8 96 ff ff ff       	call   f0100869 <serial_intr>
	kbd_intr();
f01008d3:	e8 b1 ff ff ff       	call   f0100889 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01008d8:	a1 20 12 22 f0       	mov    0xf0221220,%eax
	return 0;
f01008dd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01008e2:	3b 05 24 12 22 f0    	cmp    0xf0221224,%eax
f01008e8:	74 1c                	je     f0100906 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f01008ea:	8d 48 01             	lea    0x1(%eax),%ecx
f01008ed:	0f b6 90 20 10 22 f0 	movzbl -0xfddefe0(%eax),%edx
			cons.rpos = 0;
f01008f4:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01008f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fe:	0f 45 c1             	cmovne %ecx,%eax
f0100901:	a3 20 12 22 f0       	mov    %eax,0xf0221220
}
f0100906:	89 d0                	mov    %edx,%eax
f0100908:	c9                   	leave  
f0100909:	c3                   	ret    

f010090a <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010090a:	f3 0f 1e fb          	endbr32 
f010090e:	55                   	push   %ebp
f010090f:	89 e5                	mov    %esp,%ebp
f0100911:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f0100914:	e8 e4 fa ff ff       	call   f01003fd <cga_init>
	kbd_init();
f0100919:	e8 81 ff ff ff       	call   f010089f <kbd_init>
	serial_init();
f010091e:	e8 e1 fc ff ff       	call   f0100604 <serial_init>

	if (!serial_exists)
f0100923:	80 3d 34 12 22 f0 00 	cmpb   $0x0,0xf0221234
f010092a:	74 02                	je     f010092e <cons_init+0x24>
		cprintf("Serial port does not exist!\n");
}
f010092c:	c9                   	leave  
f010092d:	c3                   	ret    
		cprintf("Serial port does not exist!\n");
f010092e:	83 ec 0c             	sub    $0xc,%esp
f0100931:	68 3d 66 10 f0       	push   $0xf010663d
f0100936:	e8 d0 30 00 00       	call   f0103a0b <cprintf>
f010093b:	83 c4 10             	add    $0x10,%esp
}
f010093e:	eb ec                	jmp    f010092c <cons_init+0x22>

f0100940 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100940:	f3 0f 1e fb          	endbr32 
f0100944:	55                   	push   %ebp
f0100945:	89 e5                	mov    %esp,%ebp
f0100947:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010094a:	8b 45 08             	mov    0x8(%ebp),%eax
f010094d:	e8 f5 fe ff ff       	call   f0100847 <cons_putc>
}
f0100952:	c9                   	leave  
f0100953:	c3                   	ret    

f0100954 <getchar>:

int
getchar(void)
{
f0100954:	f3 0f 1e fb          	endbr32 
f0100958:	55                   	push   %ebp
f0100959:	89 e5                	mov    %esp,%ebp
f010095b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010095e:	e8 61 ff ff ff       	call   f01008c4 <cons_getc>
f0100963:	85 c0                	test   %eax,%eax
f0100965:	74 f7                	je     f010095e <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100967:	c9                   	leave  
f0100968:	c3                   	ret    

f0100969 <iscons>:

int
iscons(int fdnum)
{
f0100969:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010096d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100972:	c3                   	ret    

f0100973 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100973:	f3 0f 1e fb          	endbr32 
f0100977:	55                   	push   %ebp
f0100978:	89 e5                	mov    %esp,%ebp
f010097a:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010097d:	68 80 68 10 f0       	push   $0xf0106880
f0100982:	68 9e 68 10 f0       	push   $0xf010689e
f0100987:	68 a3 68 10 f0       	push   $0xf01068a3
f010098c:	e8 7a 30 00 00       	call   f0103a0b <cprintf>
f0100991:	83 c4 0c             	add    $0xc,%esp
f0100994:	68 28 69 10 f0       	push   $0xf0106928
f0100999:	68 ac 68 10 f0       	push   $0xf01068ac
f010099e:	68 a3 68 10 f0       	push   $0xf01068a3
f01009a3:	e8 63 30 00 00       	call   f0103a0b <cprintf>
f01009a8:	83 c4 0c             	add    $0xc,%esp
f01009ab:	68 b5 68 10 f0       	push   $0xf01068b5
f01009b0:	68 c9 68 10 f0       	push   $0xf01068c9
f01009b5:	68 a3 68 10 f0       	push   $0xf01068a3
f01009ba:	e8 4c 30 00 00       	call   f0103a0b <cprintf>
	return 0;
}
f01009bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c4:	c9                   	leave  
f01009c5:	c3                   	ret    

f01009c6 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01009c6:	f3 0f 1e fb          	endbr32 
f01009ca:	55                   	push   %ebp
f01009cb:	89 e5                	mov    %esp,%ebp
f01009cd:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01009d0:	68 d3 68 10 f0       	push   $0xf01068d3
f01009d5:	e8 31 30 00 00       	call   f0103a0b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01009da:	83 c4 08             	add    $0x8,%esp
f01009dd:	68 0c 00 10 00       	push   $0x10000c
f01009e2:	68 50 69 10 f0       	push   $0xf0106950
f01009e7:	e8 1f 30 00 00       	call   f0103a0b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01009ec:	83 c4 0c             	add    $0xc,%esp
f01009ef:	68 0c 00 10 00       	push   $0x10000c
f01009f4:	68 0c 00 10 f0       	push   $0xf010000c
f01009f9:	68 78 69 10 f0       	push   $0xf0106978
f01009fe:	e8 08 30 00 00       	call   f0103a0b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a03:	83 c4 0c             	add    $0xc,%esp
f0100a06:	68 5d 65 10 00       	push   $0x10655d
f0100a0b:	68 5d 65 10 f0       	push   $0xf010655d
f0100a10:	68 9c 69 10 f0       	push   $0xf010699c
f0100a15:	e8 f1 2f 00 00       	call   f0103a0b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a1a:	83 c4 0c             	add    $0xc,%esp
f0100a1d:	68 0c 06 22 00       	push   $0x22060c
f0100a22:	68 0c 06 22 f0       	push   $0xf022060c
f0100a27:	68 c0 69 10 f0       	push   $0xf01069c0
f0100a2c:	e8 da 2f 00 00       	call   f0103a0b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a31:	83 c4 0c             	add    $0xc,%esp
f0100a34:	68 08 40 26 00       	push   $0x264008
f0100a39:	68 08 40 26 f0       	push   $0xf0264008
f0100a3e:	68 e4 69 10 f0       	push   $0xf01069e4
f0100a43:	e8 c3 2f 00 00       	call   f0103a0b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a48:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100a4b:	b8 08 40 26 f0       	mov    $0xf0264008,%eax
f0100a50:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a55:	c1 f8 0a             	sar    $0xa,%eax
f0100a58:	50                   	push   %eax
f0100a59:	68 08 6a 10 f0       	push   $0xf0106a08
f0100a5e:	e8 a8 2f 00 00       	call   f0103a0b <cprintf>
	return 0;
}
f0100a63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a68:	c9                   	leave  
f0100a69:	c3                   	ret    

f0100a6a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a6a:	f3 0f 1e fb          	endbr32 
f0100a6e:	55                   	push   %ebp
f0100a6f:	89 e5                	mov    %esp,%ebp
f0100a71:	57                   	push   %edi
f0100a72:	56                   	push   %esi
f0100a73:	53                   	push   %ebx
f0100a74:	83 ec 4c             	sub    $0x4c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a77:	89 e8                	mov    %ebp,%eax
	// Your code here.
	uint32_t *ebp = (uint32_t *)read_ebp();
f0100a79:	89 c6                	mov    %eax,%esi
	while(ebp){
f0100a7b:	85 f6                	test   %esi,%esi
f0100a7d:	74 5d                	je     f0100adc <mon_backtrace+0x72>
		uint32_t saved_ebp = ebp[0];
f0100a7f:	8b 06                	mov    (%esi),%eax
f0100a81:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		uint32_t return_address = ebp[1];
f0100a84:	8b 5e 04             	mov    0x4(%esi),%ebx
		uint32_t param0 = ebp[2];
f0100a87:	8b 56 08             	mov    0x8(%esi),%edx
f0100a8a:	89 55 c0             	mov    %edx,-0x40(%ebp)
		uint32_t param1 = ebp[3];
f0100a8d:	8b 4e 0c             	mov    0xc(%esi),%ecx
f0100a90:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		uint32_t param2 = ebp[4];
f0100a93:	8b 7e 10             	mov    0x10(%esi),%edi
f0100a96:	89 7d b8             	mov    %edi,-0x48(%ebp)
		uint32_t param3 = ebp[5];
f0100a99:	8b 46 14             	mov    0x14(%esi),%eax
f0100a9c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		uint32_t param4 = ebp[6];
f0100a9f:	8b 7e 18             	mov    0x18(%esi),%edi

		struct Eipdebuginfo info;
		debuginfo_eip(return_address,&info);
f0100aa2:	83 ec 08             	sub    $0x8,%esp
f0100aa5:	8d 55 d0             	lea    -0x30(%ebp),%edx
f0100aa8:	52                   	push   %edx
f0100aa9:	53                   	push   %ebx
f0100aaa:	e8 c6 42 00 00       	call   f0104d75 <debuginfo_eip>

		//impirmir en hexa en formato ebp[...] eip[...] args[...]

		//como el tester espera 8bits, agrego un pad de 0's a izquierda
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n"
f0100aaf:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ab2:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ab5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ab8:	ff 75 d0             	pushl  -0x30(%ebp)
f0100abb:	57                   	push   %edi
f0100abc:	ff 75 b4             	pushl  -0x4c(%ebp)
f0100abf:	ff 75 b8             	pushl  -0x48(%ebp)
f0100ac2:	ff 75 bc             	pushl  -0x44(%ebp)
f0100ac5:	ff 75 c0             	pushl  -0x40(%ebp)
f0100ac8:	53                   	push   %ebx
f0100ac9:	56                   	push   %esi
f0100aca:	68 34 6a 10 f0       	push   $0xf0106a34
f0100acf:	e8 37 2f 00 00       	call   f0103a0b <cprintf>
		"%s:%d: %.*s+%p\n",
			ebp,return_address,param0,param1,param2,param3,param4,info.eip_file,info.eip_line,
			info.eip_fn_namelen,info.eip_fn_name);

		//Actualizar el ebp para que no quede loopeando el while
		ebp = (uint32_t *)saved_ebp;
f0100ad4:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0100ad7:	83 c4 40             	add    $0x40,%esp
f0100ada:	eb 9f                	jmp    f0100a7b <mon_backtrace+0x11>

	}
	return 0;
}
f0100adc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ae4:	5b                   	pop    %ebx
f0100ae5:	5e                   	pop    %esi
f0100ae6:	5f                   	pop    %edi
f0100ae7:	5d                   	pop    %ebp
f0100ae8:	c3                   	ret    

f0100ae9 <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f0100ae9:	55                   	push   %ebp
f0100aea:	89 e5                	mov    %esp,%ebp
f0100aec:	57                   	push   %edi
f0100aed:	56                   	push   %esi
f0100aee:	53                   	push   %ebx
f0100aef:	83 ec 5c             	sub    $0x5c,%esp
f0100af2:	89 c3                	mov    %eax,%ebx
f0100af4:	89 55 a4             	mov    %edx,-0x5c(%ebp)
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100af7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100afe:	be 00 00 00 00       	mov    $0x0,%esi
f0100b03:	eb 5d                	jmp    f0100b62 <runcmd+0x79>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b05:	83 ec 08             	sub    $0x8,%esp
f0100b08:	0f be c0             	movsbl %al,%eax
f0100b0b:	50                   	push   %eax
f0100b0c:	68 ec 68 10 f0       	push   $0xf01068ec
f0100b11:	e8 b8 4c 00 00       	call   f01057ce <strchr>
f0100b16:	83 c4 10             	add    $0x10,%esp
f0100b19:	85 c0                	test   %eax,%eax
f0100b1b:	74 0a                	je     f0100b27 <runcmd+0x3e>
			*buf++ = 0;
f0100b1d:	c6 03 00             	movb   $0x0,(%ebx)
f0100b20:	89 f7                	mov    %esi,%edi
f0100b22:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b25:	eb 39                	jmp    f0100b60 <runcmd+0x77>
		if (*buf == 0)
f0100b27:	0f b6 03             	movzbl (%ebx),%eax
f0100b2a:	84 c0                	test   %al,%al
f0100b2c:	74 3b                	je     f0100b69 <runcmd+0x80>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b2e:	83 fe 0f             	cmp    $0xf,%esi
f0100b31:	0f 84 81 00 00 00    	je     f0100bb8 <runcmd+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f0100b37:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b3a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b3e:	83 ec 08             	sub    $0x8,%esp
f0100b41:	0f be c0             	movsbl %al,%eax
f0100b44:	50                   	push   %eax
f0100b45:	68 ec 68 10 f0       	push   $0xf01068ec
f0100b4a:	e8 7f 4c 00 00       	call   f01057ce <strchr>
f0100b4f:	83 c4 10             	add    $0x10,%esp
f0100b52:	85 c0                	test   %eax,%eax
f0100b54:	75 0a                	jne    f0100b60 <runcmd+0x77>
			buf++;
f0100b56:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b59:	0f b6 03             	movzbl (%ebx),%eax
f0100b5c:	84 c0                	test   %al,%al
f0100b5e:	75 de                	jne    f0100b3e <runcmd+0x55>
			*buf++ = 0;
f0100b60:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100b62:	0f b6 03             	movzbl (%ebx),%eax
f0100b65:	84 c0                	test   %al,%al
f0100b67:	75 9c                	jne    f0100b05 <runcmd+0x1c>
	}
	argv[argc] = 0;
f0100b69:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b70:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b71:	85 f6                	test   %esi,%esi
f0100b73:	74 5a                	je     f0100bcf <runcmd+0xe6>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b75:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b7a:	83 ec 08             	sub    $0x8,%esp
f0100b7d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b80:	ff 34 85 c0 6a 10 f0 	pushl  -0xfef9540(,%eax,4)
f0100b87:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b8a:	e8 d9 4b 00 00       	call   f0105768 <strcmp>
f0100b8f:	83 c4 10             	add    $0x10,%esp
f0100b92:	85 c0                	test   %eax,%eax
f0100b94:	74 43                	je     f0100bd9 <runcmd+0xf0>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b96:	83 c3 01             	add    $0x1,%ebx
f0100b99:	83 fb 03             	cmp    $0x3,%ebx
f0100b9c:	75 dc                	jne    f0100b7a <runcmd+0x91>
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b9e:	83 ec 08             	sub    $0x8,%esp
f0100ba1:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ba4:	68 0e 69 10 f0       	push   $0xf010690e
f0100ba9:	e8 5d 2e 00 00       	call   f0103a0b <cprintf>
	return 0;
f0100bae:	83 c4 10             	add    $0x10,%esp
f0100bb1:	be 00 00 00 00       	mov    $0x0,%esi
f0100bb6:	eb 17                	jmp    f0100bcf <runcmd+0xe6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100bb8:	83 ec 08             	sub    $0x8,%esp
f0100bbb:	6a 10                	push   $0x10
f0100bbd:	68 f1 68 10 f0       	push   $0xf01068f1
f0100bc2:	e8 44 2e 00 00       	call   f0103a0b <cprintf>
			return 0;
f0100bc7:	83 c4 10             	add    $0x10,%esp
f0100bca:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100bcf:	89 f0                	mov    %esi,%eax
f0100bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bd4:	5b                   	pop    %ebx
f0100bd5:	5e                   	pop    %esi
f0100bd6:	5f                   	pop    %edi
f0100bd7:	5d                   	pop    %ebp
f0100bd8:	c3                   	ret    
			return commands[i].func(argc, argv, tf);
f0100bd9:	83 ec 04             	sub    $0x4,%esp
f0100bdc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bdf:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100be2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100be5:	52                   	push   %edx
f0100be6:	56                   	push   %esi
f0100be7:	ff 14 85 c8 6a 10 f0 	call   *-0xfef9538(,%eax,4)
f0100bee:	89 c6                	mov    %eax,%esi
f0100bf0:	83 c4 10             	add    $0x10,%esp
f0100bf3:	eb da                	jmp    f0100bcf <runcmd+0xe6>

f0100bf5 <monitor>:

void
monitor(struct Trapframe *tf)
{
f0100bf5:	f3 0f 1e fb          	endbr32 
f0100bf9:	55                   	push   %ebp
f0100bfa:	89 e5                	mov    %esp,%ebp
f0100bfc:	53                   	push   %ebx
f0100bfd:	83 ec 10             	sub    $0x10,%esp
f0100c00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c03:	68 74 6a 10 f0       	push   $0xf0106a74
f0100c08:	e8 fe 2d 00 00       	call   f0103a0b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c0d:	c7 04 24 98 6a 10 f0 	movl   $0xf0106a98,(%esp)
f0100c14:	e8 f2 2d 00 00       	call   f0103a0b <cprintf>

	if (tf != NULL)
f0100c19:	83 c4 10             	add    $0x10,%esp
f0100c1c:	85 db                	test   %ebx,%ebx
f0100c1e:	74 0c                	je     f0100c2c <monitor+0x37>
		print_trapframe(tf);
f0100c20:	83 ec 0c             	sub    $0xc,%esp
f0100c23:	53                   	push   %ebx
f0100c24:	e8 e7 32 00 00       	call   f0103f10 <print_trapframe>
f0100c29:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100c2c:	83 ec 0c             	sub    $0xc,%esp
f0100c2f:	68 24 69 10 f0       	push   $0xf0106924
f0100c34:	e8 3b 49 00 00       	call   f0105574 <readline>
		if (buf != NULL)
f0100c39:	83 c4 10             	add    $0x10,%esp
f0100c3c:	85 c0                	test   %eax,%eax
f0100c3e:	74 ec                	je     f0100c2c <monitor+0x37>
			if (runcmd(buf, tf) < 0)
f0100c40:	89 da                	mov    %ebx,%edx
f0100c42:	e8 a2 fe ff ff       	call   f0100ae9 <runcmd>
f0100c47:	85 c0                	test   %eax,%eax
f0100c49:	79 e1                	jns    f0100c2c <monitor+0x37>
				break;
	}
}
f0100c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c4e:	c9                   	leave  
f0100c4f:	c3                   	ret    

f0100c50 <invlpg>:
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100c50:	0f 01 38             	invlpg (%eax)
}
f0100c53:	c3                   	ret    

f0100c54 <lcr0>:
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0100c54:	0f 22 c0             	mov    %eax,%cr0
}
f0100c57:	c3                   	ret    

f0100c58 <rcr0>:
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0100c58:	0f 20 c0             	mov    %cr0,%eax
}
f0100c5b:	c3                   	ret    

f0100c5c <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100c5c:	0f 22 d8             	mov    %eax,%cr3
}
f0100c5f:	c3                   	ret    

f0100c60 <page2pa>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c60:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0100c66:	c1 f8 03             	sar    $0x3,%eax
f0100c69:	c1 e0 0c             	shl    $0xc,%eax
}
f0100c6c:	c3                   	ret    

f0100c6d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c6d:	55                   	push   %ebp
f0100c6e:	89 e5                	mov    %esp,%ebp
f0100c70:	56                   	push   %esi
f0100c71:	53                   	push   %ebx
f0100c72:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c74:	83 ec 0c             	sub    $0xc,%esp
f0100c77:	50                   	push   %eax
f0100c78:	e8 5c 2b 00 00       	call   f01037d9 <mc146818_read>
f0100c7d:	89 c6                	mov    %eax,%esi
f0100c7f:	83 c3 01             	add    $0x1,%ebx
f0100c82:	89 1c 24             	mov    %ebx,(%esp)
f0100c85:	e8 4f 2b 00 00       	call   f01037d9 <mc146818_read>
f0100c8a:	c1 e0 08             	shl    $0x8,%eax
f0100c8d:	09 f0                	or     %esi,%eax
}
f0100c8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c92:	5b                   	pop    %ebx
f0100c93:	5e                   	pop    %esi
f0100c94:	5d                   	pop    %ebp
f0100c95:	c3                   	ret    

f0100c96 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100c96:	55                   	push   %ebp
f0100c97:	89 e5                	mov    %esp,%ebp
f0100c99:	56                   	push   %esi
f0100c9a:	53                   	push   %ebx
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100c9b:	b8 15 00 00 00       	mov    $0x15,%eax
f0100ca0:	e8 c8 ff ff ff       	call   f0100c6d <nvram_read>
f0100ca5:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100ca7:	b8 17 00 00 00       	mov    $0x17,%eax
f0100cac:	e8 bc ff ff ff       	call   f0100c6d <nvram_read>
f0100cb1:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100cb3:	b8 34 00 00 00       	mov    $0x34,%eax
f0100cb8:	e8 b0 ff ff ff       	call   f0100c6d <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100cbd:	c1 e0 06             	shl    $0x6,%eax
f0100cc0:	74 2b                	je     f0100ced <i386_detect_memory+0x57>
		totalmem = 16 * 1024 + ext16mem;
f0100cc2:	05 00 40 00 00       	add    $0x4000,%eax
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100cc7:	89 c2                	mov    %eax,%edx
f0100cc9:	c1 ea 02             	shr    $0x2,%edx
f0100ccc:	89 15 88 2e 22 f0    	mov    %edx,0xf0222e88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100cd2:	89 c2                	mov    %eax,%edx
f0100cd4:	29 da                	sub    %ebx,%edx
f0100cd6:	52                   	push   %edx
f0100cd7:	53                   	push   %ebx
f0100cd8:	50                   	push   %eax
f0100cd9:	68 e4 6a 10 f0       	push   $0xf0106ae4
f0100cde:	e8 28 2d 00 00       	call   f0103a0b <cprintf>
	        totalmem,
	        basemem,
	        totalmem - basemem);
}
f0100ce3:	83 c4 10             	add    $0x10,%esp
f0100ce6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ce9:	5b                   	pop    %ebx
f0100cea:	5e                   	pop    %esi
f0100ceb:	5d                   	pop    %ebp
f0100cec:	c3                   	ret    
		totalmem = 1 * 1024 + extmem;
f0100ced:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100cf3:	85 f6                	test   %esi,%esi
f0100cf5:	0f 44 c3             	cmove  %ebx,%eax
f0100cf8:	eb cd                	jmp    f0100cc7 <i386_detect_memory+0x31>

f0100cfa <_kaddr>:
{
f0100cfa:	55                   	push   %ebp
f0100cfb:	89 e5                	mov    %esp,%ebp
f0100cfd:	53                   	push   %ebx
f0100cfe:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0100d01:	89 cb                	mov    %ecx,%ebx
f0100d03:	c1 eb 0c             	shr    $0xc,%ebx
f0100d06:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0100d0c:	73 0b                	jae    f0100d19 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0100d0e:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0100d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d17:	c9                   	leave  
f0100d18:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d19:	51                   	push   %ecx
f0100d1a:	68 8c 65 10 f0       	push   $0xf010658c
f0100d1f:	52                   	push   %edx
f0100d20:	50                   	push   %eax
f0100d21:	e8 44 f3 ff ff       	call   f010006a <_panic>

f0100d26 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100d26:	55                   	push   %ebp
f0100d27:	89 e5                	mov    %esp,%ebp
f0100d29:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0100d2c:	e8 2f ff ff ff       	call   f0100c60 <page2pa>
f0100d31:	89 c1                	mov    %eax,%ecx
f0100d33:	ba 58 00 00 00       	mov    $0x58,%edx
f0100d38:	b8 c1 74 10 f0       	mov    $0xf01074c1,%eax
f0100d3d:	e8 b8 ff ff ff       	call   f0100cfa <_kaddr>
}
f0100d42:	c9                   	leave  
f0100d43:	c3                   	ret    

f0100d44 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100d44:	55                   	push   %ebp
f0100d45:	89 e5                	mov    %esp,%ebp
f0100d47:	53                   	push   %ebx
f0100d48:	83 ec 04             	sub    $0x4,%esp
f0100d4b:	89 d3                	mov    %edx,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100d4d:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100d50:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
		return ~0;
f0100d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if (!(*pgdir & PTE_P))
f0100d58:	f6 c1 01             	test   $0x1,%cl
f0100d5b:	74 14                	je     f0100d71 <check_va2pa+0x2d>
	if (*pgdir & PTE_PS)
f0100d5d:	f6 c1 80             	test   $0x80,%cl
f0100d60:	74 15                	je     f0100d77 <check_va2pa+0x33>
		return (physaddr_t) PGADDR(PDX(*pgdir), PTX(va), PGOFF(va));
f0100d62:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100d68:	89 d8                	mov    %ebx,%eax
f0100d6a:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f0100d6f:	09 c8                	or     %ecx,%eax
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100d71:	83 c4 04             	add    $0x4,%esp
f0100d74:	5b                   	pop    %ebx
f0100d75:	5d                   	pop    %ebp
f0100d76:	c3                   	ret    
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
f0100d77:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100d7d:	ba c4 03 00 00       	mov    $0x3c4,%edx
f0100d82:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0100d87:	e8 6e ff ff ff       	call   f0100cfa <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f0100d8c:	c1 eb 0c             	shr    $0xc,%ebx
f0100d8f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0100d95:	8b 14 98             	mov    (%eax,%ebx,4),%edx
	return PTE_ADDR(p[PTX(va)]);
f0100d98:	89 d0                	mov    %edx,%eax
f0100d9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d9f:	f6 c2 01             	test   $0x1,%dl
f0100da2:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0100da7:	0f 44 c1             	cmove  %ecx,%eax
f0100daa:	eb c5                	jmp    f0100d71 <check_va2pa+0x2d>

f0100dac <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0100dac:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0100db2:	76 07                	jbe    f0100dbb <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0100db4:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100dba:	c3                   	ret    
{
f0100dbb:	55                   	push   %ebp
f0100dbc:	89 e5                	mov    %esp,%ebp
f0100dbe:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dc1:	51                   	push   %ecx
f0100dc2:	68 b0 65 10 f0       	push   $0xf01065b0
f0100dc7:	52                   	push   %edx
f0100dc8:	50                   	push   %eax
f0100dc9:	e8 9c f2 ff ff       	call   f010006a <_panic>

f0100dce <boot_alloc>:
{
f0100dce:	55                   	push   %ebp
f0100dcf:	89 e5                	mov    %esp,%ebp
f0100dd1:	56                   	push   %esi
f0100dd2:	53                   	push   %ebx
	if (!nextfree) {
f0100dd3:	83 3d 38 12 22 f0 00 	cmpl   $0x0,0xf0221238
f0100dda:	74 41                	je     f0100e1d <boot_alloc+0x4f>
	void *nextfreevalue = ROUNDUP((char *) nextfree + n, PGSIZE);
f0100ddc:	8b 35 38 12 22 f0    	mov    0xf0221238,%esi
f0100de2:	8d 9c 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%ebx
f0100de9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PADDR(nextfreevalue) >= max_phisical_mem) {
f0100def:	89 d9                	mov    %ebx,%ecx
f0100df1:	ba 73 00 00 00       	mov    $0x73,%edx
f0100df6:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0100dfb:	e8 ac ff ff ff       	call   f0100dac <_paddr>
f0100e00:	89 c2                	mov    %eax,%edx
	uint32_t max_phisical_mem = PGSIZE * npages;
f0100e02:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0100e07:	c1 e0 0c             	shl    $0xc,%eax
	if (PADDR(nextfreevalue) >= max_phisical_mem) {
f0100e0a:	39 c2                	cmp    %eax,%edx
f0100e0c:	73 22                	jae    f0100e30 <boot_alloc+0x62>
	nextfree = nextfreevalue;
f0100e0e:	89 1d 38 12 22 f0    	mov    %ebx,0xf0221238
}
f0100e14:	89 f0                	mov    %esi,%eax
f0100e16:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e19:	5b                   	pop    %ebx
f0100e1a:	5e                   	pop    %esi
f0100e1b:	5d                   	pop    %ebp
f0100e1c:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e1d:	ba 07 50 26 f0       	mov    $0xf0265007,%edx
f0100e22:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e28:	89 15 38 12 22 f0    	mov    %edx,0xf0221238
f0100e2e:	eb ac                	jmp    f0100ddc <boot_alloc+0xe>
		panic("Physical memory not enough! - boot_alloc");
f0100e30:	83 ec 04             	sub    $0x4,%esp
f0100e33:	68 20 6b 10 f0       	push   $0xf0106b20
f0100e38:	6a 74                	push   $0x74
f0100e3a:	68 cf 74 10 f0       	push   $0xf01074cf
f0100e3f:	e8 26 f2 ff ff       	call   f010006a <_panic>

f0100e44 <check_page_free_list>:
{
f0100e44:	55                   	push   %ebp
f0100e45:	89 e5                	mov    %esp,%ebp
f0100e47:	57                   	push   %edi
f0100e48:	56                   	push   %esi
f0100e49:	53                   	push   %ebx
f0100e4a:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e4d:	84 c0                	test   %al,%al
f0100e4f:	0f 85 3f 02 00 00    	jne    f0101094 <check_page_free_list+0x250>
	if (!page_free_list)
f0100e55:	83 3d 40 12 22 f0 00 	cmpl   $0x0,0xf0221240
f0100e5c:	74 0a                	je     f0100e68 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e5e:	be 00 04 00 00       	mov    $0x400,%esi
f0100e63:	e9 84 02 00 00       	jmp    f01010ec <check_page_free_list+0x2a8>
		panic("'page_free_list' is a null pointer!");
f0100e68:	83 ec 04             	sub    $0x4,%esp
f0100e6b:	68 4c 6b 10 f0       	push   $0xf0106b4c
f0100e70:	68 e1 02 00 00       	push   $0x2e1
f0100e75:	68 cf 74 10 f0       	push   $0xf01074cf
f0100e7a:	e8 eb f1 ff ff       	call   f010006a <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e7f:	8b 1b                	mov    (%ebx),%ebx
f0100e81:	85 db                	test   %ebx,%ebx
f0100e83:	74 2d                	je     f0100eb2 <check_page_free_list+0x6e>
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e85:	89 d8                	mov    %ebx,%eax
f0100e87:	e8 d4 fd ff ff       	call   f0100c60 <page2pa>
f0100e8c:	c1 e8 16             	shr    $0x16,%eax
f0100e8f:	39 f0                	cmp    %esi,%eax
f0100e91:	73 ec                	jae    f0100e7f <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100e93:	89 d8                	mov    %ebx,%eax
f0100e95:	e8 8c fe ff ff       	call   f0100d26 <page2kva>
f0100e9a:	83 ec 04             	sub    $0x4,%esp
f0100e9d:	68 80 00 00 00       	push   $0x80
f0100ea2:	68 97 00 00 00       	push   $0x97
f0100ea7:	50                   	push   %eax
f0100ea8:	e8 66 49 00 00       	call   f0105813 <memset>
f0100ead:	83 c4 10             	add    $0x10,%esp
f0100eb0:	eb cd                	jmp    f0100e7f <check_page_free_list+0x3b>
	first_free_page = (char *) boot_alloc(0);
f0100eb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eb7:	e8 12 ff ff ff       	call   f0100dce <boot_alloc>
f0100ebc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ebf:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
		assert(pp >= pages);
f0100ec5:	8b 35 90 2e 22 f0    	mov    0xf0222e90,%esi
		assert(pp < pages + npages);
f0100ecb:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0100ed0:	8d 3c c6             	lea    (%esi,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ed3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0100eda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ee1:	e9 e0 00 00 00       	jmp    f0100fc6 <check_page_free_list+0x182>
		assert(pp >= pages);
f0100ee6:	68 db 74 10 f0       	push   $0xf01074db
f0100eeb:	68 e7 74 10 f0       	push   $0xf01074e7
f0100ef0:	68 fb 02 00 00       	push   $0x2fb
f0100ef5:	68 cf 74 10 f0       	push   $0xf01074cf
f0100efa:	e8 6b f1 ff ff       	call   f010006a <_panic>
		assert(pp < pages + npages);
f0100eff:	68 fc 74 10 f0       	push   $0xf01074fc
f0100f04:	68 e7 74 10 f0       	push   $0xf01074e7
f0100f09:	68 fc 02 00 00       	push   $0x2fc
f0100f0e:	68 cf 74 10 f0       	push   $0xf01074cf
f0100f13:	e8 52 f1 ff ff       	call   f010006a <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f18:	68 70 6b 10 f0       	push   $0xf0106b70
f0100f1d:	68 e7 74 10 f0       	push   $0xf01074e7
f0100f22:	68 fd 02 00 00       	push   $0x2fd
f0100f27:	68 cf 74 10 f0       	push   $0xf01074cf
f0100f2c:	e8 39 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != 0);
f0100f31:	68 10 75 10 f0       	push   $0xf0107510
f0100f36:	68 e7 74 10 f0       	push   $0xf01074e7
f0100f3b:	68 00 03 00 00       	push   $0x300
f0100f40:	68 cf 74 10 f0       	push   $0xf01074cf
f0100f45:	e8 20 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f4a:	68 21 75 10 f0       	push   $0xf0107521
f0100f4f:	68 e7 74 10 f0       	push   $0xf01074e7
f0100f54:	68 01 03 00 00       	push   $0x301
f0100f59:	68 cf 74 10 f0       	push   $0xf01074cf
f0100f5e:	e8 07 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f63:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0100f68:	68 e7 74 10 f0       	push   $0xf01074e7
f0100f6d:	68 02 03 00 00       	push   $0x302
f0100f72:	68 cf 74 10 f0       	push   $0xf01074cf
f0100f77:	e8 ee f0 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100f7c:	68 3a 75 10 f0       	push   $0xf010753a
f0100f81:	68 e7 74 10 f0       	push   $0xf01074e7
f0100f86:	68 03 03 00 00       	push   $0x303
f0100f8b:	68 cf 74 10 f0       	push   $0xf01074cf
f0100f90:	e8 d5 f0 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100f95:	89 d8                	mov    %ebx,%eax
f0100f97:	e8 8a fd ff ff       	call   f0100d26 <page2kva>
f0100f9c:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100f9f:	77 06                	ja     f0100fa7 <check_page_free_list+0x163>
			++nfree_extmem;
f0100fa1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100fa5:	eb 1d                	jmp    f0100fc4 <check_page_free_list+0x180>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100fa7:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0100fac:	68 e7 74 10 f0       	push   $0xf01074e7
f0100fb1:	68 04 03 00 00       	push   $0x304
f0100fb6:	68 cf 74 10 f0       	push   $0xf01074cf
f0100fbb:	e8 aa f0 ff ff       	call   f010006a <_panic>
			++nfree_basemem;
f0100fc0:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fc4:	8b 1b                	mov    (%ebx),%ebx
f0100fc6:	85 db                	test   %ebx,%ebx
f0100fc8:	74 77                	je     f0101041 <check_page_free_list+0x1fd>
		assert(pp >= pages);
f0100fca:	39 de                	cmp    %ebx,%esi
f0100fcc:	0f 87 14 ff ff ff    	ja     f0100ee6 <check_page_free_list+0xa2>
		assert(pp < pages + npages);
f0100fd2:	39 df                	cmp    %ebx,%edi
f0100fd4:	0f 86 25 ff ff ff    	jbe    f0100eff <check_page_free_list+0xbb>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100fda:	89 d8                	mov    %ebx,%eax
f0100fdc:	29 f0                	sub    %esi,%eax
f0100fde:	a8 07                	test   $0x7,%al
f0100fe0:	0f 85 32 ff ff ff    	jne    f0100f18 <check_page_free_list+0xd4>
		assert(page2pa(pp) != 0);
f0100fe6:	89 d8                	mov    %ebx,%eax
f0100fe8:	e8 73 fc ff ff       	call   f0100c60 <page2pa>
f0100fed:	85 c0                	test   %eax,%eax
f0100fef:	0f 84 3c ff ff ff    	je     f0100f31 <check_page_free_list+0xed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ff5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ffa:	0f 84 4a ff ff ff    	je     f0100f4a <check_page_free_list+0x106>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101000:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101005:	0f 84 58 ff ff ff    	je     f0100f63 <check_page_free_list+0x11f>
		assert(page2pa(pp) != EXTPHYSMEM);
f010100b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101010:	0f 84 66 ff ff ff    	je     f0100f7c <check_page_free_list+0x138>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0101016:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010101b:	0f 87 74 ff ff ff    	ja     f0100f95 <check_page_free_list+0x151>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101021:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101026:	75 98                	jne    f0100fc0 <check_page_free_list+0x17c>
f0101028:	68 54 75 10 f0       	push   $0xf0107554
f010102d:	68 e7 74 10 f0       	push   $0xf01074e7
f0101032:	68 07 03 00 00       	push   $0x307
f0101037:	68 cf 74 10 f0       	push   $0xf01074cf
f010103c:	e8 29 f0 ff ff       	call   f010006a <_panic>
	assert(nfree_basemem > 0);
f0101041:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101045:	7e 1b                	jle    f0101062 <check_page_free_list+0x21e>
	assert(nfree_extmem > 0);
f0101047:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010104b:	7e 2e                	jle    f010107b <check_page_free_list+0x237>
	cprintf("check_page_free_list() succeeded!\n");
f010104d:	83 ec 0c             	sub    $0xc,%esp
f0101050:	68 10 6c 10 f0       	push   $0xf0106c10
f0101055:	e8 b1 29 00 00       	call   f0103a0b <cprintf>
}
f010105a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010105d:	5b                   	pop    %ebx
f010105e:	5e                   	pop    %esi
f010105f:	5f                   	pop    %edi
f0101060:	5d                   	pop    %ebp
f0101061:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101062:	68 71 75 10 f0       	push   $0xf0107571
f0101067:	68 e7 74 10 f0       	push   $0xf01074e7
f010106c:	68 0f 03 00 00       	push   $0x30f
f0101071:	68 cf 74 10 f0       	push   $0xf01074cf
f0101076:	e8 ef ef ff ff       	call   f010006a <_panic>
	assert(nfree_extmem > 0);
f010107b:	68 83 75 10 f0       	push   $0xf0107583
f0101080:	68 e7 74 10 f0       	push   $0xf01074e7
f0101085:	68 10 03 00 00       	push   $0x310
f010108a:	68 cf 74 10 f0       	push   $0xf01074cf
f010108f:	e8 d6 ef ff ff       	call   f010006a <_panic>
	if (!page_free_list)
f0101094:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
f010109a:	85 db                	test   %ebx,%ebx
f010109c:	0f 84 c6 fd ff ff    	je     f0100e68 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01010a2:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01010a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01010ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01010ae:	89 d8                	mov    %ebx,%eax
f01010b0:	e8 ab fb ff ff       	call   f0100c60 <page2pa>
f01010b5:	c1 e8 16             	shr    $0x16,%eax
f01010b8:	0f 95 c0             	setne  %al
f01010bb:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01010be:	8b 54 85 e0          	mov    -0x20(%ebp,%eax,4),%edx
f01010c2:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01010c4:	89 5c 85 e0          	mov    %ebx,-0x20(%ebp,%eax,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010c8:	8b 1b                	mov    (%ebx),%ebx
f01010ca:	85 db                	test   %ebx,%ebx
f01010cc:	75 e0                	jne    f01010ae <check_page_free_list+0x26a>
		*tp[1] = 0;
f01010ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01010d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010dd:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01010df:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010e2:	a3 40 12 22 f0       	mov    %eax,0xf0221240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01010e7:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010ec:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
f01010f2:	e9 8a fd ff ff       	jmp    f0100e81 <check_page_free_list+0x3d>

f01010f7 <pa2page>:
	if (PGNUM(pa) >= npages)
f01010f7:	c1 e8 0c             	shr    $0xc,%eax
f01010fa:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f0101100:	73 0a                	jae    f010110c <pa2page+0x15>
	return &pages[PGNUM(pa)];
f0101102:	8b 15 90 2e 22 f0    	mov    0xf0222e90,%edx
f0101108:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010110b:	c3                   	ret    
{
f010110c:	55                   	push   %ebp
f010110d:	89 e5                	mov    %esp,%ebp
f010110f:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f0101112:	68 34 6c 10 f0       	push   $0xf0106c34
f0101117:	6a 51                	push   $0x51
f0101119:	68 c1 74 10 f0       	push   $0xf01074c1
f010111e:	e8 47 ef ff ff       	call   f010006a <_panic>

f0101123 <page_init>:
{
f0101123:	f3 0f 1e fb          	endbr32 
f0101127:	55                   	push   %ebp
f0101128:	89 e5                	mov    %esp,%ebp
f010112a:	57                   	push   %edi
f010112b:	56                   	push   %esi
f010112c:	53                   	push   %ebx
f010112d:	83 ec 0c             	sub    $0xc,%esp
	uint32_t last_page_used = PGNUM(PADDR(boot_alloc(0)));
f0101130:	b8 00 00 00 00       	mov    $0x0,%eax
f0101135:	e8 94 fc ff ff       	call   f0100dce <boot_alloc>
f010113a:	89 c1                	mov    %eax,%ecx
f010113c:	ba 4f 01 00 00       	mov    $0x14f,%edx
f0101141:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0101146:	e8 61 fc ff ff       	call   f0100dac <_paddr>
f010114b:	c1 e8 0c             	shr    $0xc,%eax
f010114e:	8b 0d 40 12 22 f0    	mov    0xf0221240,%ecx
	for (i = 0; i < npages; i++) {
f0101154:	bf 00 00 00 00       	mov    $0x0,%edi
f0101159:	ba 00 00 00 00       	mov    $0x0,%edx
		page_free_list = &pages[i];
f010115e:	be 01 00 00 00       	mov    $0x1,%esi
		if (i == 0 || (i >= page_iophysmem && i <= last_page_used - 1) ||
f0101163:	8d 58 ff             	lea    -0x1(%eax),%ebx
	for (i = 0; i < npages; i++) {
f0101166:	eb 17                	jmp    f010117f <page_init+0x5c>
			pages[i].pp_ref = 1;
f0101168:	a1 90 2e 22 f0       	mov    0xf0222e90,%eax
f010116d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0101170:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0101176:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for (i = 0; i < npages; i++) {
f010117c:	83 c2 01             	add    $0x1,%edx
f010117f:	39 15 88 2e 22 f0    	cmp    %edx,0xf0222e88
f0101185:	76 38                	jbe    f01011bf <page_init+0x9c>
		if (i == 0 || (i >= page_iophysmem && i <= last_page_used - 1) ||
f0101187:	85 d2                	test   %edx,%edx
f0101189:	74 dd                	je     f0101168 <page_init+0x45>
f010118b:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f0101191:	76 04                	jbe    f0101197 <page_init+0x74>
f0101193:	39 d3                	cmp    %edx,%ebx
f0101195:	73 d1                	jae    f0101168 <page_init+0x45>
f0101197:	83 fa 07             	cmp    $0x7,%edx
f010119a:	74 cc                	je     f0101168 <page_init+0x45>
f010119c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		pages[i].pp_ref = 0;
f01011a3:	89 c7                	mov    %eax,%edi
f01011a5:	03 3d 90 2e 22 f0    	add    0xf0222e90,%edi
f01011ab:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f01011b1:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f01011b3:	03 05 90 2e 22 f0    	add    0xf0222e90,%eax
f01011b9:	89 c1                	mov    %eax,%ecx
f01011bb:	89 f7                	mov    %esi,%edi
f01011bd:	eb bd                	jmp    f010117c <page_init+0x59>
f01011bf:	89 f8                	mov    %edi,%eax
f01011c1:	84 c0                	test   %al,%al
f01011c3:	74 06                	je     f01011cb <page_init+0xa8>
f01011c5:	89 0d 40 12 22 f0    	mov    %ecx,0xf0221240
}
f01011cb:	83 c4 0c             	add    $0xc,%esp
f01011ce:	5b                   	pop    %ebx
f01011cf:	5e                   	pop    %esi
f01011d0:	5f                   	pop    %edi
f01011d1:	5d                   	pop    %ebp
f01011d2:	c3                   	ret    

f01011d3 <page_alloc>:
{
f01011d3:	f3 0f 1e fb          	endbr32 
f01011d7:	55                   	push   %ebp
f01011d8:	89 e5                	mov    %esp,%ebp
f01011da:	53                   	push   %ebx
f01011db:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL)
f01011de:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
f01011e4:	85 db                	test   %ebx,%ebx
f01011e6:	74 13                	je     f01011fb <page_alloc+0x28>
	page_free_list = page_free_list->pp_link;
f01011e8:	8b 03                	mov    (%ebx),%eax
f01011ea:	a3 40 12 22 f0       	mov    %eax,0xf0221240
	page_info->pp_link = NULL;
f01011ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f01011f5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01011f9:	75 07                	jne    f0101202 <page_alloc+0x2f>
}
f01011fb:	89 d8                	mov    %ebx,%eax
f01011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101200:	c9                   	leave  
f0101201:	c3                   	ret    
		memset(page2kva(page_info), 0, PGSIZE);
f0101202:	89 d8                	mov    %ebx,%eax
f0101204:	e8 1d fb ff ff       	call   f0100d26 <page2kva>
f0101209:	83 ec 04             	sub    $0x4,%esp
f010120c:	68 00 10 00 00       	push   $0x1000
f0101211:	6a 00                	push   $0x0
f0101213:	50                   	push   %eax
f0101214:	e8 fa 45 00 00       	call   f0105813 <memset>
f0101219:	83 c4 10             	add    $0x10,%esp
f010121c:	eb dd                	jmp    f01011fb <page_alloc+0x28>

f010121e <page_free>:
{
f010121e:	f3 0f 1e fb          	endbr32 
f0101222:	55                   	push   %ebp
f0101223:	89 e5                	mov    %esp,%ebp
f0101225:	83 ec 08             	sub    $0x8,%esp
f0101228:	8b 55 08             	mov    0x8(%ebp),%edx
	if (pp->pp_link != NULL || pp->pp_ref != 0)
f010122b:	83 3a 00             	cmpl   $0x0,(%edx)
f010122e:	75 26                	jne    f0101256 <page_free+0x38>
f0101230:	66 83 7a 04 00       	cmpw   $0x0,0x4(%edx)
f0101235:	75 1f                	jne    f0101256 <page_free+0x38>
	struct PageInfo *current = page_free_list;
f0101237:	a1 40 12 22 f0       	mov    0xf0221240,%eax
	if (current == NULL || pp > current) {
f010123c:	85 c0                	test   %eax,%eax
f010123e:	74 2d                	je     f010126d <page_free+0x4f>
f0101240:	39 c2                	cmp    %eax,%edx
f0101242:	77 29                	ja     f010126d <page_free+0x4f>
f0101244:	89 c1                	mov    %eax,%ecx
	while (current->pp_link != NULL && current->pp_link > pp) {
f0101246:	8b 00                	mov    (%eax),%eax
f0101248:	39 d0                	cmp    %edx,%eax
f010124a:	76 04                	jbe    f0101250 <page_free+0x32>
f010124c:	85 c0                	test   %eax,%eax
f010124e:	75 f4                	jne    f0101244 <page_free+0x26>
	pp->pp_link = current->pp_link;
f0101250:	89 02                	mov    %eax,(%edx)
	current->pp_link = pp;
f0101252:	89 11                	mov    %edx,(%ecx)
}
f0101254:	c9                   	leave  
f0101255:	c3                   	ret    
		panic("Page is referenced, cant free");
f0101256:	83 ec 04             	sub    $0x4,%esp
f0101259:	68 94 75 10 f0       	push   $0xf0107594
f010125e:	68 82 01 00 00       	push   $0x182
f0101263:	68 cf 74 10 f0       	push   $0xf01074cf
f0101268:	e8 fd ed ff ff       	call   f010006a <_panic>
		pp->pp_link = page_free_list;
f010126d:	89 02                	mov    %eax,(%edx)
		page_free_list = pp;
f010126f:	89 15 40 12 22 f0    	mov    %edx,0xf0221240
		return;
f0101275:	eb dd                	jmp    f0101254 <page_free+0x36>

f0101277 <check_page_alloc>:
{
f0101277:	55                   	push   %ebp
f0101278:	89 e5                	mov    %esp,%ebp
f010127a:	57                   	push   %edi
f010127b:	56                   	push   %esi
f010127c:	53                   	push   %ebx
f010127d:	83 ec 1c             	sub    $0x1c,%esp
	if (!pages)
f0101280:	83 3d 90 2e 22 f0 00 	cmpl   $0x0,0xf0222e90
f0101287:	74 0c                	je     f0101295 <check_page_alloc+0x1e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101289:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f010128e:	be 00 00 00 00       	mov    $0x0,%esi
f0101293:	eb 1c                	jmp    f01012b1 <check_page_alloc+0x3a>
		panic("'pages' is a null pointer!");
f0101295:	83 ec 04             	sub    $0x4,%esp
f0101298:	68 b2 75 10 f0       	push   $0xf01075b2
f010129d:	68 23 03 00 00       	push   $0x323
f01012a2:	68 cf 74 10 f0       	push   $0xf01074cf
f01012a7:	e8 be ed ff ff       	call   f010006a <_panic>
		++nfree;
f01012ac:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012af:	8b 00                	mov    (%eax),%eax
f01012b1:	85 c0                	test   %eax,%eax
f01012b3:	75 f7                	jne    f01012ac <check_page_alloc+0x35>
	assert((pp0 = page_alloc(0)));
f01012b5:	83 ec 0c             	sub    $0xc,%esp
f01012b8:	6a 00                	push   $0x0
f01012ba:	e8 14 ff ff ff       	call   f01011d3 <page_alloc>
f01012bf:	89 c7                	mov    %eax,%edi
f01012c1:	83 c4 10             	add    $0x10,%esp
f01012c4:	85 c0                	test   %eax,%eax
f01012c6:	0f 84 d3 01 00 00    	je     f010149f <check_page_alloc+0x228>
	assert((pp1 = page_alloc(0)));
f01012cc:	83 ec 0c             	sub    $0xc,%esp
f01012cf:	6a 00                	push   $0x0
f01012d1:	e8 fd fe ff ff       	call   f01011d3 <page_alloc>
f01012d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012d9:	83 c4 10             	add    $0x10,%esp
f01012dc:	85 c0                	test   %eax,%eax
f01012de:	0f 84 d4 01 00 00    	je     f01014b8 <check_page_alloc+0x241>
	assert((pp2 = page_alloc(0)));
f01012e4:	83 ec 0c             	sub    $0xc,%esp
f01012e7:	6a 00                	push   $0x0
f01012e9:	e8 e5 fe ff ff       	call   f01011d3 <page_alloc>
f01012ee:	89 c3                	mov    %eax,%ebx
f01012f0:	83 c4 10             	add    $0x10,%esp
f01012f3:	85 c0                	test   %eax,%eax
f01012f5:	0f 84 d6 01 00 00    	je     f01014d1 <check_page_alloc+0x25a>
	assert(pp1 && pp1 != pp0);
f01012fb:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f01012fe:	0f 84 e6 01 00 00    	je     f01014ea <check_page_alloc+0x273>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101304:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101307:	0f 84 f6 01 00 00    	je     f0101503 <check_page_alloc+0x28c>
f010130d:	39 c7                	cmp    %eax,%edi
f010130f:	0f 84 ee 01 00 00    	je     f0101503 <check_page_alloc+0x28c>
	assert(page2pa(pp0) < npages * PGSIZE);
f0101315:	89 f8                	mov    %edi,%eax
f0101317:	e8 44 f9 ff ff       	call   f0100c60 <page2pa>
f010131c:	8b 0d 88 2e 22 f0    	mov    0xf0222e88,%ecx
f0101322:	c1 e1 0c             	shl    $0xc,%ecx
f0101325:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101328:	39 c8                	cmp    %ecx,%eax
f010132a:	0f 83 ec 01 00 00    	jae    f010151c <check_page_alloc+0x2a5>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101333:	e8 28 f9 ff ff       	call   f0100c60 <page2pa>
f0101338:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010133b:	0f 86 f4 01 00 00    	jbe    f0101535 <check_page_alloc+0x2be>
	assert(page2pa(pp2) < npages * PGSIZE);
f0101341:	89 d8                	mov    %ebx,%eax
f0101343:	e8 18 f9 ff ff       	call   f0100c60 <page2pa>
f0101348:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010134b:	0f 86 fd 01 00 00    	jbe    f010154e <check_page_alloc+0x2d7>
	fl = page_free_list;
f0101351:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f0101356:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f0101359:	c7 05 40 12 22 f0 00 	movl   $0x0,0xf0221240
f0101360:	00 00 00 
	assert(!page_alloc(0));
f0101363:	83 ec 0c             	sub    $0xc,%esp
f0101366:	6a 00                	push   $0x0
f0101368:	e8 66 fe ff ff       	call   f01011d3 <page_alloc>
f010136d:	83 c4 10             	add    $0x10,%esp
f0101370:	85 c0                	test   %eax,%eax
f0101372:	0f 85 ef 01 00 00    	jne    f0101567 <check_page_alloc+0x2f0>
	page_free(pp0);
f0101378:	83 ec 0c             	sub    $0xc,%esp
f010137b:	57                   	push   %edi
f010137c:	e8 9d fe ff ff       	call   f010121e <page_free>
	page_free(pp1);
f0101381:	83 c4 04             	add    $0x4,%esp
f0101384:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101387:	e8 92 fe ff ff       	call   f010121e <page_free>
	page_free(pp2);
f010138c:	89 1c 24             	mov    %ebx,(%esp)
f010138f:	e8 8a fe ff ff       	call   f010121e <page_free>
	assert((pp0 = page_alloc(0)));
f0101394:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010139b:	e8 33 fe ff ff       	call   f01011d3 <page_alloc>
f01013a0:	89 c3                	mov    %eax,%ebx
f01013a2:	83 c4 10             	add    $0x10,%esp
f01013a5:	85 c0                	test   %eax,%eax
f01013a7:	0f 84 d3 01 00 00    	je     f0101580 <check_page_alloc+0x309>
	assert((pp1 = page_alloc(0)));
f01013ad:	83 ec 0c             	sub    $0xc,%esp
f01013b0:	6a 00                	push   $0x0
f01013b2:	e8 1c fe ff ff       	call   f01011d3 <page_alloc>
f01013b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013ba:	83 c4 10             	add    $0x10,%esp
f01013bd:	85 c0                	test   %eax,%eax
f01013bf:	0f 84 d4 01 00 00    	je     f0101599 <check_page_alloc+0x322>
	assert((pp2 = page_alloc(0)));
f01013c5:	83 ec 0c             	sub    $0xc,%esp
f01013c8:	6a 00                	push   $0x0
f01013ca:	e8 04 fe ff ff       	call   f01011d3 <page_alloc>
f01013cf:	89 c7                	mov    %eax,%edi
f01013d1:	83 c4 10             	add    $0x10,%esp
f01013d4:	85 c0                	test   %eax,%eax
f01013d6:	0f 84 d6 01 00 00    	je     f01015b2 <check_page_alloc+0x33b>
	assert(pp1 && pp1 != pp0);
f01013dc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01013df:	0f 84 e6 01 00 00    	je     f01015cb <check_page_alloc+0x354>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013e5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01013e8:	0f 84 f6 01 00 00    	je     f01015e4 <check_page_alloc+0x36d>
f01013ee:	39 c3                	cmp    %eax,%ebx
f01013f0:	0f 84 ee 01 00 00    	je     f01015e4 <check_page_alloc+0x36d>
	assert(!page_alloc(0));
f01013f6:	83 ec 0c             	sub    $0xc,%esp
f01013f9:	6a 00                	push   $0x0
f01013fb:	e8 d3 fd ff ff       	call   f01011d3 <page_alloc>
f0101400:	83 c4 10             	add    $0x10,%esp
f0101403:	85 c0                	test   %eax,%eax
f0101405:	0f 85 f2 01 00 00    	jne    f01015fd <check_page_alloc+0x386>
	memset(page2kva(pp0), 1, PGSIZE);
f010140b:	89 d8                	mov    %ebx,%eax
f010140d:	e8 14 f9 ff ff       	call   f0100d26 <page2kva>
f0101412:	83 ec 04             	sub    $0x4,%esp
f0101415:	68 00 10 00 00       	push   $0x1000
f010141a:	6a 01                	push   $0x1
f010141c:	50                   	push   %eax
f010141d:	e8 f1 43 00 00       	call   f0105813 <memset>
	page_free(pp0);
f0101422:	89 1c 24             	mov    %ebx,(%esp)
f0101425:	e8 f4 fd ff ff       	call   f010121e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010142a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101431:	e8 9d fd ff ff       	call   f01011d3 <page_alloc>
f0101436:	83 c4 10             	add    $0x10,%esp
f0101439:	85 c0                	test   %eax,%eax
f010143b:	0f 84 d5 01 00 00    	je     f0101616 <check_page_alloc+0x39f>
	assert(pp && pp0 == pp);
f0101441:	39 c3                	cmp    %eax,%ebx
f0101443:	0f 85 e6 01 00 00    	jne    f010162f <check_page_alloc+0x3b8>
	c = page2kva(pp);
f0101449:	e8 d8 f8 ff ff       	call   f0100d26 <page2kva>
f010144e:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f0101454:	80 38 00             	cmpb   $0x0,(%eax)
f0101457:	0f 85 eb 01 00 00    	jne    f0101648 <check_page_alloc+0x3d1>
f010145d:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101460:	39 d0                	cmp    %edx,%eax
f0101462:	75 f0                	jne    f0101454 <check_page_alloc+0x1dd>
	page_free_list = fl;
f0101464:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101467:	a3 40 12 22 f0       	mov    %eax,0xf0221240
	page_free(pp0);
f010146c:	83 ec 0c             	sub    $0xc,%esp
f010146f:	53                   	push   %ebx
f0101470:	e8 a9 fd ff ff       	call   f010121e <page_free>
	page_free(pp1);
f0101475:	83 c4 04             	add    $0x4,%esp
f0101478:	ff 75 e4             	pushl  -0x1c(%ebp)
f010147b:	e8 9e fd ff ff       	call   f010121e <page_free>
	page_free(pp2);
f0101480:	89 3c 24             	mov    %edi,(%esp)
f0101483:	e8 96 fd ff ff       	call   f010121e <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101488:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f010148d:	83 c4 10             	add    $0x10,%esp
f0101490:	85 c0                	test   %eax,%eax
f0101492:	0f 84 c9 01 00 00    	je     f0101661 <check_page_alloc+0x3ea>
		--nfree;
f0101498:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010149b:	8b 00                	mov    (%eax),%eax
f010149d:	eb f1                	jmp    f0101490 <check_page_alloc+0x219>
	assert((pp0 = page_alloc(0)));
f010149f:	68 cd 75 10 f0       	push   $0xf01075cd
f01014a4:	68 e7 74 10 f0       	push   $0xf01074e7
f01014a9:	68 2b 03 00 00       	push   $0x32b
f01014ae:	68 cf 74 10 f0       	push   $0xf01074cf
f01014b3:	e8 b2 eb ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f01014b8:	68 e3 75 10 f0       	push   $0xf01075e3
f01014bd:	68 e7 74 10 f0       	push   $0xf01074e7
f01014c2:	68 2c 03 00 00       	push   $0x32c
f01014c7:	68 cf 74 10 f0       	push   $0xf01074cf
f01014cc:	e8 99 eb ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f01014d1:	68 f9 75 10 f0       	push   $0xf01075f9
f01014d6:	68 e7 74 10 f0       	push   $0xf01074e7
f01014db:	68 2d 03 00 00       	push   $0x32d
f01014e0:	68 cf 74 10 f0       	push   $0xf01074cf
f01014e5:	e8 80 eb ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f01014ea:	68 0f 76 10 f0       	push   $0xf010760f
f01014ef:	68 e7 74 10 f0       	push   $0xf01074e7
f01014f4:	68 30 03 00 00       	push   $0x330
f01014f9:	68 cf 74 10 f0       	push   $0xf01074cf
f01014fe:	e8 67 eb ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101503:	68 54 6c 10 f0       	push   $0xf0106c54
f0101508:	68 e7 74 10 f0       	push   $0xf01074e7
f010150d:	68 31 03 00 00       	push   $0x331
f0101512:	68 cf 74 10 f0       	push   $0xf01074cf
f0101517:	e8 4e eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f010151c:	68 74 6c 10 f0       	push   $0xf0106c74
f0101521:	68 e7 74 10 f0       	push   $0xf01074e7
f0101526:	68 32 03 00 00       	push   $0x332
f010152b:	68 cf 74 10 f0       	push   $0xf01074cf
f0101530:	e8 35 eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101535:	68 94 6c 10 f0       	push   $0xf0106c94
f010153a:	68 e7 74 10 f0       	push   $0xf01074e7
f010153f:	68 33 03 00 00       	push   $0x333
f0101544:	68 cf 74 10 f0       	push   $0xf01074cf
f0101549:	e8 1c eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f010154e:	68 b4 6c 10 f0       	push   $0xf0106cb4
f0101553:	68 e7 74 10 f0       	push   $0xf01074e7
f0101558:	68 34 03 00 00       	push   $0x334
f010155d:	68 cf 74 10 f0       	push   $0xf01074cf
f0101562:	e8 03 eb ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0101567:	68 21 76 10 f0       	push   $0xf0107621
f010156c:	68 e7 74 10 f0       	push   $0xf01074e7
f0101571:	68 3b 03 00 00       	push   $0x33b
f0101576:	68 cf 74 10 f0       	push   $0xf01074cf
f010157b:	e8 ea ea ff ff       	call   f010006a <_panic>
	assert((pp0 = page_alloc(0)));
f0101580:	68 cd 75 10 f0       	push   $0xf01075cd
f0101585:	68 e7 74 10 f0       	push   $0xf01074e7
f010158a:	68 42 03 00 00       	push   $0x342
f010158f:	68 cf 74 10 f0       	push   $0xf01074cf
f0101594:	e8 d1 ea ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101599:	68 e3 75 10 f0       	push   $0xf01075e3
f010159e:	68 e7 74 10 f0       	push   $0xf01074e7
f01015a3:	68 43 03 00 00       	push   $0x343
f01015a8:	68 cf 74 10 f0       	push   $0xf01074cf
f01015ad:	e8 b8 ea ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f01015b2:	68 f9 75 10 f0       	push   $0xf01075f9
f01015b7:	68 e7 74 10 f0       	push   $0xf01074e7
f01015bc:	68 44 03 00 00       	push   $0x344
f01015c1:	68 cf 74 10 f0       	push   $0xf01074cf
f01015c6:	e8 9f ea ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f01015cb:	68 0f 76 10 f0       	push   $0xf010760f
f01015d0:	68 e7 74 10 f0       	push   $0xf01074e7
f01015d5:	68 46 03 00 00       	push   $0x346
f01015da:	68 cf 74 10 f0       	push   $0xf01074cf
f01015df:	e8 86 ea ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015e4:	68 54 6c 10 f0       	push   $0xf0106c54
f01015e9:	68 e7 74 10 f0       	push   $0xf01074e7
f01015ee:	68 47 03 00 00       	push   $0x347
f01015f3:	68 cf 74 10 f0       	push   $0xf01074cf
f01015f8:	e8 6d ea ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01015fd:	68 21 76 10 f0       	push   $0xf0107621
f0101602:	68 e7 74 10 f0       	push   $0xf01074e7
f0101607:	68 48 03 00 00       	push   $0x348
f010160c:	68 cf 74 10 f0       	push   $0xf01074cf
f0101611:	e8 54 ea ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101616:	68 30 76 10 f0       	push   $0xf0107630
f010161b:	68 e7 74 10 f0       	push   $0xf01074e7
f0101620:	68 4d 03 00 00       	push   $0x34d
f0101625:	68 cf 74 10 f0       	push   $0xf01074cf
f010162a:	e8 3b ea ff ff       	call   f010006a <_panic>
	assert(pp && pp0 == pp);
f010162f:	68 4e 76 10 f0       	push   $0xf010764e
f0101634:	68 e7 74 10 f0       	push   $0xf01074e7
f0101639:	68 4e 03 00 00       	push   $0x34e
f010163e:	68 cf 74 10 f0       	push   $0xf01074cf
f0101643:	e8 22 ea ff ff       	call   f010006a <_panic>
		assert(c[i] == 0);
f0101648:	68 5e 76 10 f0       	push   $0xf010765e
f010164d:	68 e7 74 10 f0       	push   $0xf01074e7
f0101652:	68 51 03 00 00       	push   $0x351
f0101657:	68 cf 74 10 f0       	push   $0xf01074cf
f010165c:	e8 09 ea ff ff       	call   f010006a <_panic>
	assert(nfree == 0);
f0101661:	85 f6                	test   %esi,%esi
f0101663:	75 18                	jne    f010167d <check_page_alloc+0x406>
	cprintf("check_page_alloc() succeeded!\n");
f0101665:	83 ec 0c             	sub    $0xc,%esp
f0101668:	68 d4 6c 10 f0       	push   $0xf0106cd4
f010166d:	e8 99 23 00 00       	call   f0103a0b <cprintf>
}
f0101672:	83 c4 10             	add    $0x10,%esp
f0101675:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101678:	5b                   	pop    %ebx
f0101679:	5e                   	pop    %esi
f010167a:	5f                   	pop    %edi
f010167b:	5d                   	pop    %ebp
f010167c:	c3                   	ret    
	assert(nfree == 0);
f010167d:	68 68 76 10 f0       	push   $0xf0107668
f0101682:	68 e7 74 10 f0       	push   $0xf01074e7
f0101687:	68 5e 03 00 00       	push   $0x35e
f010168c:	68 cf 74 10 f0       	push   $0xf01074cf
f0101691:	e8 d4 e9 ff ff       	call   f010006a <_panic>

f0101696 <page_decref>:
{
f0101696:	f3 0f 1e fb          	endbr32 
f010169a:	55                   	push   %ebp
f010169b:	89 e5                	mov    %esp,%ebp
f010169d:	83 ec 08             	sub    $0x8,%esp
f01016a0:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01016a3:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01016a7:	83 e8 01             	sub    $0x1,%eax
f01016aa:	66 89 42 04          	mov    %ax,0x4(%edx)
f01016ae:	66 85 c0             	test   %ax,%ax
f01016b1:	74 02                	je     f01016b5 <page_decref+0x1f>
}
f01016b3:	c9                   	leave  
f01016b4:	c3                   	ret    
		page_free(pp);
f01016b5:	83 ec 0c             	sub    $0xc,%esp
f01016b8:	52                   	push   %edx
f01016b9:	e8 60 fb ff ff       	call   f010121e <page_free>
f01016be:	83 c4 10             	add    $0x10,%esp
}
f01016c1:	eb f0                	jmp    f01016b3 <page_decref+0x1d>

f01016c3 <pgdir_walk>:
{
f01016c3:	f3 0f 1e fb          	endbr32 
f01016c7:	55                   	push   %ebp
f01016c8:	89 e5                	mov    %esp,%ebp
f01016ca:	56                   	push   %esi
f01016cb:	53                   	push   %ebx
f01016cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pd_entry = &pgdir[PDX(va)];
f01016cf:	89 f3                	mov    %esi,%ebx
f01016d1:	c1 eb 16             	shr    $0x16,%ebx
f01016d4:	c1 e3 02             	shl    $0x2,%ebx
f01016d7:	03 5d 08             	add    0x8(%ebp),%ebx
	if ((pte_t *) *pd_entry == NULL) {
f01016da:	83 3b 00             	cmpl   $0x0,(%ebx)
f01016dd:	75 2b                	jne    f010170a <pgdir_walk+0x47>
			return NULL;
f01016df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (!create)
f01016e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01016e8:	74 42                	je     f010172c <pgdir_walk+0x69>
		struct PageInfo *new_page_info = page_alloc(ALLOC_ZERO);
f01016ea:	83 ec 0c             	sub    $0xc,%esp
f01016ed:	6a 01                	push   $0x1
f01016ef:	e8 df fa ff ff       	call   f01011d3 <page_alloc>
		if (new_page_info == NULL)
f01016f4:	83 c4 10             	add    $0x10,%esp
f01016f7:	85 c0                	test   %eax,%eax
f01016f9:	74 31                	je     f010172c <pgdir_walk+0x69>
		new_page_info->pp_ref++;
f01016fb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		*pd_entry = page2pa(new_page_info) | PTE_P | PTE_U | PTE_W;
f0101700:	e8 5b f5 ff ff       	call   f0100c60 <page2pa>
f0101705:	83 c8 07             	or     $0x7,%eax
f0101708:	89 03                	mov    %eax,(%ebx)
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pd_entry));
f010170a:	8b 0b                	mov    (%ebx),%ecx
f010170c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101712:	ba c5 01 00 00       	mov    $0x1c5,%edx
f0101717:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f010171c:	e8 d9 f5 ff ff       	call   f0100cfa <_kaddr>
	return &p[PTX(va)];
f0101721:	c1 ee 0a             	shr    $0xa,%esi
f0101724:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010172a:	01 f0                	add    %esi,%eax
}
f010172c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010172f:	5b                   	pop    %ebx
f0101730:	5e                   	pop    %esi
f0101731:	5d                   	pop    %ebp
f0101732:	c3                   	ret    

f0101733 <boot_map_region>:
{
f0101733:	55                   	push   %ebp
f0101734:	89 e5                	mov    %esp,%ebp
f0101736:	57                   	push   %edi
f0101737:	56                   	push   %esi
f0101738:	53                   	push   %ebx
f0101739:	83 ec 1c             	sub    $0x1c,%esp
f010173c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010173f:	8b 7d 08             	mov    0x8(%ebp),%edi
	assert(va % PGSIZE == 0);
f0101742:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101748:	75 28                	jne    f0101772 <boot_map_region+0x3f>
	assert(pa % PGSIZE == 0);
f010174a:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0101750:	75 39                	jne    f010178b <boot_map_region+0x58>
	assert(size % PGSIZE == 0);
f0101752:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0101758:	75 4a                	jne    f01017a4 <boot_map_region+0x71>
	assert(perm < (1 << PTXSHIFT));
f010175a:	81 7d 0c ff 0f 00 00 	cmpl   $0xfff,0xc(%ebp)
f0101761:	7f 5a                	jg     f01017bd <boot_map_region+0x8a>
f0101763:	89 ce                	mov    %ecx,%esi
f0101765:	01 cf                	add    %ecx,%edi
		pte_t *page_table_entry = pgdir_walk(pgdir, (void *) (va), 1);
f0101767:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010176a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010176d:	e9 88 00 00 00       	jmp    f01017fa <boot_map_region+0xc7>
	assert(va % PGSIZE == 0);
f0101772:	68 73 76 10 f0       	push   $0xf0107673
f0101777:	68 e7 74 10 f0       	push   $0xf01074e7
f010177c:	68 d8 01 00 00       	push   $0x1d8
f0101781:	68 cf 74 10 f0       	push   $0xf01074cf
f0101786:	e8 df e8 ff ff       	call   f010006a <_panic>
	assert(pa % PGSIZE == 0);
f010178b:	68 84 76 10 f0       	push   $0xf0107684
f0101790:	68 e7 74 10 f0       	push   $0xf01074e7
f0101795:	68 d9 01 00 00       	push   $0x1d9
f010179a:	68 cf 74 10 f0       	push   $0xf01074cf
f010179f:	e8 c6 e8 ff ff       	call   f010006a <_panic>
	assert(size % PGSIZE == 0);
f01017a4:	68 95 76 10 f0       	push   $0xf0107695
f01017a9:	68 e7 74 10 f0       	push   $0xf01074e7
f01017ae:	68 da 01 00 00       	push   $0x1da
f01017b3:	68 cf 74 10 f0       	push   $0xf01074cf
f01017b8:	e8 ad e8 ff ff       	call   f010006a <_panic>
	assert(perm < (1 << PTXSHIFT));
f01017bd:	68 a8 76 10 f0       	push   $0xf01076a8
f01017c2:	68 e7 74 10 f0       	push   $0xf01074e7
f01017c7:	68 db 01 00 00       	push   $0x1db
f01017cc:	68 cf 74 10 f0       	push   $0xf01074cf
f01017d1:	e8 94 e8 ff ff       	call   f010006a <_panic>
		pte_t *page_table_entry = pgdir_walk(pgdir, (void *) (va), 1);
f01017d6:	83 ec 04             	sub    $0x4,%esp
f01017d9:	6a 01                	push   $0x1
f01017db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01017de:	29 f0                	sub    %esi,%eax
f01017e0:	50                   	push   %eax
f01017e1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01017e4:	e8 da fe ff ff       	call   f01016c3 <pgdir_walk>
		*page_table_entry = pa | perm | PTE_P;
f01017e9:	0b 5d 0c             	or     0xc(%ebp),%ebx
f01017ec:	83 cb 01             	or     $0x1,%ebx
f01017ef:	89 18                	mov    %ebx,(%eax)
		size -= PGSIZE;
f01017f1:	81 ee 00 10 00 00    	sub    $0x1000,%esi
f01017f7:	83 c4 10             	add    $0x10,%esp
f01017fa:	89 fb                	mov    %edi,%ebx
f01017fc:	29 f3                	sub    %esi,%ebx
	while (size > 0) {
f01017fe:	85 f6                	test   %esi,%esi
f0101800:	75 d4                	jne    f01017d6 <boot_map_region+0xa3>
}
f0101802:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101805:	5b                   	pop    %ebx
f0101806:	5e                   	pop    %esi
f0101807:	5f                   	pop    %edi
f0101808:	5d                   	pop    %ebp
f0101809:	c3                   	ret    

f010180a <mem_init_mp>:
{
f010180a:	55                   	push   %ebp
f010180b:	89 e5                	mov    %esp,%ebp
f010180d:	57                   	push   %edi
f010180e:	56                   	push   %esi
f010180f:	53                   	push   %ebx
f0101810:	83 ec 0c             	sub    $0xc,%esp
f0101813:	bb 00 40 22 f0       	mov    $0xf0224000,%ebx
f0101818:	bf 00 40 26 f0       	mov    $0xf0264000,%edi
f010181d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		boot_map_region(kern_pgdir,
f0101822:	89 d9                	mov    %ebx,%ecx
f0101824:	ba 24 01 00 00       	mov    $0x124,%edx
f0101829:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f010182e:	e8 79 f5 ff ff       	call   f0100dac <_paddr>
f0101833:	83 ec 08             	sub    $0x8,%esp
f0101836:	6a 02                	push   $0x2
f0101838:	50                   	push   %eax
f0101839:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010183e:	89 f2                	mov    %esi,%edx
f0101840:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101845:	e8 e9 fe ff ff       	call   f0101733 <boot_map_region>
f010184a:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0101850:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++) {
f0101856:	83 c4 10             	add    $0x10,%esp
f0101859:	39 fb                	cmp    %edi,%ebx
f010185b:	75 c5                	jne    f0101822 <mem_init_mp+0x18>
}
f010185d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101860:	5b                   	pop    %ebx
f0101861:	5e                   	pop    %esi
f0101862:	5f                   	pop    %edi
f0101863:	5d                   	pop    %ebp
f0101864:	c3                   	ret    

f0101865 <check_kern_pgdir>:
{
f0101865:	55                   	push   %ebp
f0101866:	89 e5                	mov    %esp,%ebp
f0101868:	57                   	push   %edi
f0101869:	56                   	push   %esi
f010186a:	53                   	push   %ebx
f010186b:	83 ec 1c             	sub    $0x1c,%esp
	pgdir = kern_pgdir;
f010186e:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0101874:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0101879:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101880:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101885:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < n; i += PGSIZE) {
f0101888:	bb 00 00 00 00       	mov    $0x0,%ebx
f010188d:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0101890:	0f 83 83 00 00 00    	jae    f0101919 <check_kern_pgdir+0xb4>
f0101896:	8d b3 00 00 00 ef    	lea    -0x11000000(%ebx),%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010189c:	89 f2                	mov    %esi,%edx
f010189e:	89 f8                	mov    %edi,%eax
f01018a0:	e8 9f f4 ff ff       	call   f0100d44 <check_va2pa>
f01018a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01018a8:	8b 0d 90 2e 22 f0    	mov    0xf0222e90,%ecx
f01018ae:	ba 77 03 00 00       	mov    $0x377,%edx
f01018b3:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f01018b8:	e8 ef f4 ff ff       	call   f0100dac <_paddr>
f01018bd:	01 d8                	add    %ebx,%eax
f01018bf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01018c2:	75 23                	jne    f01018e7 <check_kern_pgdir+0x82>
		pte = pgdir_walk(pgdir, (void *) (UPAGES + i), 0);
f01018c4:	83 ec 04             	sub    $0x4,%esp
f01018c7:	6a 00                	push   $0x0
f01018c9:	56                   	push   %esi
f01018ca:	57                   	push   %edi
f01018cb:	e8 f3 fd ff ff       	call   f01016c3 <pgdir_walk>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01018d0:	8b 00                	mov    (%eax),%eax
f01018d2:	25 ff 0f 00 00       	and    $0xfff,%eax
f01018d7:	83 c4 10             	add    $0x10,%esp
f01018da:	83 f8 05             	cmp    $0x5,%eax
f01018dd:	75 21                	jne    f0101900 <check_kern_pgdir+0x9b>
	for (i = 0; i < n; i += PGSIZE) {
f01018df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01018e5:	eb a6                	jmp    f010188d <check_kern_pgdir+0x28>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01018e7:	68 f4 6c 10 f0       	push   $0xf0106cf4
f01018ec:	68 e7 74 10 f0       	push   $0xf01074e7
f01018f1:	68 77 03 00 00       	push   $0x377
f01018f6:	68 cf 74 10 f0       	push   $0xf01074cf
f01018fb:	e8 6a e7 ff ff       	call   f010006a <_panic>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f0101900:	68 28 6d 10 f0       	push   $0xf0106d28
f0101905:	68 e7 74 10 f0       	push   $0xf01074e7
f010190a:	68 7a 03 00 00       	push   $0x37a
f010190f:	68 cf 74 10 f0       	push   $0xf01074cf
f0101914:	e8 51 e7 ff ff       	call   f010006a <_panic>
f0101919:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010191e:	89 da                	mov    %ebx,%edx
f0101920:	89 f8                	mov    %edi,%eax
f0101922:	e8 1d f4 ff ff       	call   f0100d44 <check_va2pa>
f0101927:	89 c6                	mov    %eax,%esi
f0101929:	8b 0d 44 12 22 f0    	mov    0xf0221244,%ecx
f010192f:	ba 80 03 00 00       	mov    $0x380,%edx
f0101934:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0101939:	e8 6e f4 ff ff       	call   f0100dac <_paddr>
f010193e:	8d 84 03 00 00 40 11 	lea    0x11400000(%ebx,%eax,1),%eax
f0101945:	39 c6                	cmp    %eax,%esi
f0101947:	75 54                	jne    f010199d <check_kern_pgdir+0x138>
		pte = pgdir_walk(pgdir, (void *) (UENVS + i), 0);
f0101949:	83 ec 04             	sub    $0x4,%esp
f010194c:	6a 00                	push   $0x0
f010194e:	53                   	push   %ebx
f010194f:	57                   	push   %edi
f0101950:	e8 6e fd ff ff       	call   f01016c3 <pgdir_walk>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f0101955:	8b 00                	mov    (%eax),%eax
f0101957:	25 ff 0f 00 00       	and    $0xfff,%eax
f010195c:	83 c4 10             	add    $0x10,%esp
f010195f:	83 f8 05             	cmp    $0x5,%eax
f0101962:	75 52                	jne    f01019b6 <check_kern_pgdir+0x151>
f0101964:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f010196a:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0101970:	75 ac                	jne    f010191e <check_kern_pgdir+0xb9>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101972:	8b 35 88 2e 22 f0    	mov    0xf0222e88,%esi
f0101978:	c1 e6 0c             	shl    $0xc,%esi
f010197b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101980:	39 de                	cmp    %ebx,%esi
f0101982:	76 64                	jbe    f01019e8 <check_kern_pgdir+0x183>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101984:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010198a:	89 f8                	mov    %edi,%eax
f010198c:	e8 b3 f3 ff ff       	call   f0100d44 <check_va2pa>
f0101991:	39 d8                	cmp    %ebx,%eax
f0101993:	75 3a                	jne    f01019cf <check_kern_pgdir+0x16a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101995:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010199b:	eb e3                	jmp    f0101980 <check_kern_pgdir+0x11b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010199d:	68 48 6d 10 f0       	push   $0xf0106d48
f01019a2:	68 e7 74 10 f0       	push   $0xf01074e7
f01019a7:	68 80 03 00 00       	push   $0x380
f01019ac:	68 cf 74 10 f0       	push   $0xf01074cf
f01019b1:	e8 b4 e6 ff ff       	call   f010006a <_panic>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01019b6:	68 28 6d 10 f0       	push   $0xf0106d28
f01019bb:	68 e7 74 10 f0       	push   $0xf01074e7
f01019c0:	68 83 03 00 00       	push   $0x383
f01019c5:	68 cf 74 10 f0       	push   $0xf01074cf
f01019ca:	e8 9b e6 ff ff       	call   f010006a <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01019cf:	68 7c 6d 10 f0       	push   $0xf0106d7c
f01019d4:	68 e7 74 10 f0       	push   $0xf01074e7
f01019d9:	68 88 03 00 00       	push   $0x388
f01019de:	68 cf 74 10 f0       	push   $0xf01074cf
f01019e3:	e8 82 e6 ff ff       	call   f010006a <_panic>
f01019e8:	c7 45 dc 00 40 22 f0 	movl   $0xf0224000,-0x24(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01019ef:	b8 00 80 ff ef       	mov    $0xefff8000,%eax
f01019f4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01019f7:	89 c7                	mov    %eax,%edi
f01019f9:	8d b7 00 80 ff ff    	lea    -0x8000(%edi),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f01019ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101a02:	89 45 e0             	mov    %eax,-0x20(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101a05:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a0a:	89 75 d8             	mov    %esi,-0x28(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0101a0d:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0101a10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101a13:	e8 2c f3 ff ff       	call   f0100d44 <check_va2pa>
f0101a18:	89 c6                	mov    %eax,%esi
f0101a1a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101a1d:	ba 90 03 00 00       	mov    $0x390,%edx
f0101a22:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0101a27:	e8 80 f3 ff ff       	call   f0100dac <_paddr>
f0101a2c:	01 d8                	add    %ebx,%eax
f0101a2e:	39 c6                	cmp    %eax,%esi
f0101a30:	75 4d                	jne    f0101a7f <check_kern_pgdir+0x21a>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101a32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101a38:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0101a3e:	75 cd                	jne    f0101a0d <check_kern_pgdir+0x1a8>
f0101a40:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101a43:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0101a46:	89 f2                	mov    %esi,%edx
f0101a48:	89 d8                	mov    %ebx,%eax
f0101a4a:	e8 f5 f2 ff ff       	call   f0100d44 <check_va2pa>
f0101a4f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101a52:	75 44                	jne    f0101a98 <check_kern_pgdir+0x233>
f0101a54:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0101a5a:	39 fe                	cmp    %edi,%esi
f0101a5c:	75 e8                	jne    f0101a46 <check_kern_pgdir+0x1e1>
f0101a5e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101a61:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0101a67:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (n = 0; n < NCPU; n++) {
f0101a6e:	81 ff 00 80 f7 ef    	cmp    $0xeff78000,%edi
f0101a74:	75 83                	jne    f01019f9 <check_kern_pgdir+0x194>
f0101a76:	89 df                	mov    %ebx,%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0101a78:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a7d:	eb 68                	jmp    f0101ae7 <check_kern_pgdir+0x282>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0101a7f:	68 a4 6d 10 f0       	push   $0xf0106da4
f0101a84:	68 e7 74 10 f0       	push   $0xf01074e7
f0101a89:	68 8f 03 00 00       	push   $0x38f
f0101a8e:	68 cf 74 10 f0       	push   $0xf01074cf
f0101a93:	e8 d2 e5 ff ff       	call   f010006a <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0101a98:	68 ec 6d 10 f0       	push   $0xf0106dec
f0101a9d:	68 e7 74 10 f0       	push   $0xf01074e7
f0101aa2:	68 92 03 00 00       	push   $0x392
f0101aa7:	68 cf 74 10 f0       	push   $0xf01074cf
f0101aac:	e8 b9 e5 ff ff       	call   f010006a <_panic>
			assert(pgdir[i] & PTE_P);
f0101ab1:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0101ab5:	75 48                	jne    f0101aff <check_kern_pgdir+0x29a>
f0101ab7:	68 bf 76 10 f0       	push   $0xf01076bf
f0101abc:	68 e7 74 10 f0       	push   $0xf01074e7
f0101ac1:	68 9d 03 00 00       	push   $0x39d
f0101ac6:	68 cf 74 10 f0       	push   $0xf01074cf
f0101acb:	e8 9a e5 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_P);
f0101ad0:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0101ad3:	f6 c2 01             	test   $0x1,%dl
f0101ad6:	74 2c                	je     f0101b04 <check_kern_pgdir+0x29f>
				assert(pgdir[i] &
f0101ad8:	f6 c2 02             	test   $0x2,%dl
f0101adb:	74 40                	je     f0101b1d <check_kern_pgdir+0x2b8>
	for (i = 0; i < NPDENTRIES; i++) {
f0101add:	83 c0 01             	add    $0x1,%eax
f0101ae0:	3d 00 04 00 00       	cmp    $0x400,%eax
f0101ae5:	74 68                	je     f0101b4f <check_kern_pgdir+0x2ea>
		switch (i) {
f0101ae7:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0101aed:	83 fa 04             	cmp    $0x4,%edx
f0101af0:	76 bf                	jbe    f0101ab1 <check_kern_pgdir+0x24c>
			if (i >= PDX(KERNBASE)) {
f0101af2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0101af7:	77 d7                	ja     f0101ad0 <check_kern_pgdir+0x26b>
				assert(pgdir[i] == 0);
f0101af9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0101afd:	75 37                	jne    f0101b36 <check_kern_pgdir+0x2d1>
	for (i = 0; i < NPDENTRIES; i++) {
f0101aff:	83 c0 01             	add    $0x1,%eax
f0101b02:	eb e3                	jmp    f0101ae7 <check_kern_pgdir+0x282>
				assert(pgdir[i] & PTE_P);
f0101b04:	68 bf 76 10 f0       	push   $0xf01076bf
f0101b09:	68 e7 74 10 f0       	push   $0xf01074e7
f0101b0e:	68 a1 03 00 00       	push   $0x3a1
f0101b13:	68 cf 74 10 f0       	push   $0xf01074cf
f0101b18:	e8 4d e5 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] &
f0101b1d:	68 d0 76 10 f0       	push   $0xf01076d0
f0101b22:	68 e7 74 10 f0       	push   $0xf01074e7
f0101b27:	68 a2 03 00 00       	push   $0x3a2
f0101b2c:	68 cf 74 10 f0       	push   $0xf01074cf
f0101b31:	e8 34 e5 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] == 0);
f0101b36:	68 e1 76 10 f0       	push   $0xf01076e1
f0101b3b:	68 e7 74 10 f0       	push   $0xf01074e7
f0101b40:	68 a5 03 00 00       	push   $0x3a5
f0101b45:	68 cf 74 10 f0       	push   $0xf01074cf
f0101b4a:	e8 1b e5 ff ff       	call   f010006a <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0101b4f:	83 ec 0c             	sub    $0xc,%esp
f0101b52:	68 10 6e 10 f0       	push   $0xf0106e10
f0101b57:	e8 af 1e 00 00       	call   f0103a0b <cprintf>
}
f0101b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101b5f:	5b                   	pop    %ebx
f0101b60:	5e                   	pop    %esi
f0101b61:	5f                   	pop    %edi
f0101b62:	5d                   	pop    %ebp
f0101b63:	c3                   	ret    

f0101b64 <page_lookup>:
{
f0101b64:	f3 0f 1e fb          	endbr32 
f0101b68:	55                   	push   %ebp
f0101b69:	89 e5                	mov    %esp,%ebp
f0101b6b:	83 ec 0c             	sub    $0xc,%esp
	pte_t *page_table_entry = pgdir_walk(pgdir, va, 0);
f0101b6e:	6a 00                	push   $0x0
f0101b70:	ff 75 0c             	pushl  0xc(%ebp)
f0101b73:	ff 75 08             	pushl  0x8(%ebp)
f0101b76:	e8 48 fb ff ff       	call   f01016c3 <pgdir_walk>
	if (!page_table_entry)
f0101b7b:	83 c4 10             	add    $0x10,%esp
f0101b7e:	85 c0                	test   %eax,%eax
f0101b80:	74 11                	je     f0101b93 <page_lookup+0x2f>
	*pte_store = page_table_entry;
f0101b82:	8b 55 10             	mov    0x10(%ebp),%edx
f0101b85:	89 02                	mov    %eax,(%edx)
	return (struct PageInfo *) pa2page(PTE_ADDR(*page_table_entry));
f0101b87:	8b 00                	mov    (%eax),%eax
f0101b89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b8e:	e8 64 f5 ff ff       	call   f01010f7 <pa2page>
}
f0101b93:	c9                   	leave  
f0101b94:	c3                   	ret    

f0101b95 <tlb_invalidate>:
{
f0101b95:	f3 0f 1e fb          	endbr32 
f0101b99:	55                   	push   %ebp
f0101b9a:	89 e5                	mov    %esp,%ebp
f0101b9c:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101b9f:	e8 00 43 00 00       	call   f0105ea4 <cpunum>
f0101ba4:	6b c0 74             	imul   $0x74,%eax,%eax
f0101ba7:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0101bae:	74 16                	je     f0101bc6 <tlb_invalidate+0x31>
f0101bb0:	e8 ef 42 00 00       	call   f0105ea4 <cpunum>
f0101bb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0101bb8:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0101bbe:	8b 55 08             	mov    0x8(%ebp),%edx
f0101bc1:	39 50 60             	cmp    %edx,0x60(%eax)
f0101bc4:	75 08                	jne    f0101bce <tlb_invalidate+0x39>
		invlpg(va);
f0101bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bc9:	e8 82 f0 ff ff       	call   f0100c50 <invlpg>
}
f0101bce:	c9                   	leave  
f0101bcf:	c3                   	ret    

f0101bd0 <page_remove>:
{
f0101bd0:	f3 0f 1e fb          	endbr32 
f0101bd4:	55                   	push   %ebp
f0101bd5:	89 e5                	mov    %esp,%ebp
f0101bd7:	56                   	push   %esi
f0101bd8:	53                   	push   %ebx
f0101bd9:	83 ec 14             	sub    $0x14,%esp
f0101bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pinfo = page_lookup(pgdir, va, &pte);
f0101be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101be5:	50                   	push   %eax
f0101be6:	56                   	push   %esi
f0101be7:	53                   	push   %ebx
f0101be8:	e8 77 ff ff ff       	call   f0101b64 <page_lookup>
	if (!pte || !(*pte & PTE_P))
f0101bed:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101bf0:	83 c4 10             	add    $0x10,%esp
f0101bf3:	85 d2                	test   %edx,%edx
f0101bf5:	74 05                	je     f0101bfc <page_remove+0x2c>
f0101bf7:	f6 02 01             	testb  $0x1,(%edx)
f0101bfa:	75 07                	jne    f0101c03 <page_remove+0x33>
}
f0101bfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101bff:	5b                   	pop    %ebx
f0101c00:	5e                   	pop    %esi
f0101c01:	5d                   	pop    %ebp
f0101c02:	c3                   	ret    
	page_decref(pinfo);
f0101c03:	83 ec 0c             	sub    $0xc,%esp
f0101c06:	50                   	push   %eax
f0101c07:	e8 8a fa ff ff       	call   f0101696 <page_decref>
	*pte = 0;
f0101c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101c15:	83 c4 08             	add    $0x8,%esp
f0101c18:	56                   	push   %esi
f0101c19:	53                   	push   %ebx
f0101c1a:	e8 76 ff ff ff       	call   f0101b95 <tlb_invalidate>
f0101c1f:	83 c4 10             	add    $0x10,%esp
f0101c22:	eb d8                	jmp    f0101bfc <page_remove+0x2c>

f0101c24 <page_insert>:
{
f0101c24:	f3 0f 1e fb          	endbr32 
f0101c28:	55                   	push   %ebp
f0101c29:	89 e5                	mov    %esp,%ebp
f0101c2b:	57                   	push   %edi
f0101c2c:	56                   	push   %esi
f0101c2d:	53                   	push   %ebx
f0101c2e:	83 ec 10             	sub    $0x10,%esp
f0101c31:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c34:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101c37:	6a 01                	push   $0x1
f0101c39:	57                   	push   %edi
f0101c3a:	ff 75 08             	pushl  0x8(%ebp)
f0101c3d:	e8 81 fa ff ff       	call   f01016c3 <pgdir_walk>
	if (!pte)
f0101c42:	83 c4 10             	add    $0x10,%esp
f0101c45:	85 c0                	test   %eax,%eax
f0101c47:	74 32                	je     f0101c7b <page_insert+0x57>
f0101c49:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101c4b:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	page_remove(pgdir, va);
f0101c50:	83 ec 08             	sub    $0x8,%esp
f0101c53:	57                   	push   %edi
f0101c54:	ff 75 08             	pushl  0x8(%ebp)
f0101c57:	e8 74 ff ff ff       	call   f0101bd0 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f0101c5c:	89 f0                	mov    %esi,%eax
f0101c5e:	e8 fd ef ff ff       	call   f0100c60 <page2pa>
f0101c63:	0b 45 14             	or     0x14(%ebp),%eax
f0101c66:	83 c8 01             	or     $0x1,%eax
f0101c69:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101c6b:	83 c4 10             	add    $0x10,%esp
f0101c6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101c76:	5b                   	pop    %ebx
f0101c77:	5e                   	pop    %esi
f0101c78:	5f                   	pop    %edi
f0101c79:	5d                   	pop    %ebp
f0101c7a:	c3                   	ret    
		return -E_NO_MEM;
f0101c7b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101c80:	eb f1                	jmp    f0101c73 <page_insert+0x4f>

f0101c82 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0101c82:	55                   	push   %ebp
f0101c83:	89 e5                	mov    %esp,%ebp
f0101c85:	57                   	push   %edi
f0101c86:	56                   	push   %esi
f0101c87:	53                   	push   %ebx
f0101c88:	83 ec 18             	sub    $0x18,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c8b:	6a 00                	push   $0x0
f0101c8d:	e8 41 f5 ff ff       	call   f01011d3 <page_alloc>
f0101c92:	83 c4 10             	add    $0x10,%esp
f0101c95:	85 c0                	test   %eax,%eax
f0101c97:	0f 84 67 01 00 00    	je     f0101e04 <check_page_installed_pgdir+0x182>
f0101c9d:	89 c6                	mov    %eax,%esi
	assert((pp1 = page_alloc(0)));
f0101c9f:	83 ec 0c             	sub    $0xc,%esp
f0101ca2:	6a 00                	push   $0x0
f0101ca4:	e8 2a f5 ff ff       	call   f01011d3 <page_alloc>
f0101ca9:	89 c7                	mov    %eax,%edi
f0101cab:	83 c4 10             	add    $0x10,%esp
f0101cae:	85 c0                	test   %eax,%eax
f0101cb0:	0f 84 67 01 00 00    	je     f0101e1d <check_page_installed_pgdir+0x19b>
	assert((pp2 = page_alloc(0)));
f0101cb6:	83 ec 0c             	sub    $0xc,%esp
f0101cb9:	6a 00                	push   $0x0
f0101cbb:	e8 13 f5 ff ff       	call   f01011d3 <page_alloc>
f0101cc0:	89 c3                	mov    %eax,%ebx
f0101cc2:	83 c4 10             	add    $0x10,%esp
f0101cc5:	85 c0                	test   %eax,%eax
f0101cc7:	0f 84 69 01 00 00    	je     f0101e36 <check_page_installed_pgdir+0x1b4>
	page_free(pp0);
f0101ccd:	83 ec 0c             	sub    $0xc,%esp
f0101cd0:	56                   	push   %esi
f0101cd1:	e8 48 f5 ff ff       	call   f010121e <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0101cd6:	89 f8                	mov    %edi,%eax
f0101cd8:	e8 49 f0 ff ff       	call   f0100d26 <page2kva>
f0101cdd:	83 c4 0c             	add    $0xc,%esp
f0101ce0:	68 00 10 00 00       	push   $0x1000
f0101ce5:	6a 01                	push   $0x1
f0101ce7:	50                   	push   %eax
f0101ce8:	e8 26 3b 00 00       	call   f0105813 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0101ced:	89 d8                	mov    %ebx,%eax
f0101cef:	e8 32 f0 ff ff       	call   f0100d26 <page2kva>
f0101cf4:	83 c4 0c             	add    $0xc,%esp
f0101cf7:	68 00 10 00 00       	push   $0x1000
f0101cfc:	6a 02                	push   $0x2
f0101cfe:	50                   	push   %eax
f0101cff:	e8 0f 3b 00 00       	call   f0105813 <memset>
	page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W);
f0101d04:	6a 02                	push   $0x2
f0101d06:	68 00 10 00 00       	push   $0x1000
f0101d0b:	57                   	push   %edi
f0101d0c:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101d12:	e8 0d ff ff ff       	call   f0101c24 <page_insert>
	assert(pp1->pp_ref == 1);
f0101d17:	83 c4 20             	add    $0x20,%esp
f0101d1a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d1f:	0f 85 2a 01 00 00    	jne    f0101e4f <check_page_installed_pgdir+0x1cd>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101d25:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0101d2c:	01 01 01 
f0101d2f:	0f 85 33 01 00 00    	jne    f0101e68 <check_page_installed_pgdir+0x1e6>
	page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W);
f0101d35:	6a 02                	push   $0x2
f0101d37:	68 00 10 00 00       	push   $0x1000
f0101d3c:	53                   	push   %ebx
f0101d3d:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101d43:	e8 dc fe ff ff       	call   f0101c24 <page_insert>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101d48:	83 c4 10             	add    $0x10,%esp
f0101d4b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0101d52:	02 02 02 
f0101d55:	0f 85 26 01 00 00    	jne    f0101e81 <check_page_installed_pgdir+0x1ff>
	assert(pp2->pp_ref == 1);
f0101d5b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d60:	0f 85 34 01 00 00    	jne    f0101e9a <check_page_installed_pgdir+0x218>
	assert(pp1->pp_ref == 0);
f0101d66:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d6b:	0f 85 42 01 00 00    	jne    f0101eb3 <check_page_installed_pgdir+0x231>
	*(uint32_t *) PGSIZE = 0x03030303U;
f0101d71:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0101d78:	03 03 03 
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101d7b:	89 d8                	mov    %ebx,%eax
f0101d7d:	e8 a4 ef ff ff       	call   f0100d26 <page2kva>
f0101d82:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0101d88:	0f 85 3e 01 00 00    	jne    f0101ecc <check_page_installed_pgdir+0x24a>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0101d8e:	83 ec 08             	sub    $0x8,%esp
f0101d91:	68 00 10 00 00       	push   $0x1000
f0101d96:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101d9c:	e8 2f fe ff ff       	call   f0101bd0 <page_remove>
	assert(pp2->pp_ref == 0);
f0101da1:	83 c4 10             	add    $0x10,%esp
f0101da4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101da9:	0f 85 36 01 00 00    	jne    f0101ee5 <check_page_installed_pgdir+0x263>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101daf:	8b 1d 8c 2e 22 f0    	mov    0xf0222e8c,%ebx
f0101db5:	89 f0                	mov    %esi,%eax
f0101db7:	e8 a4 ee ff ff       	call   f0100c60 <page2pa>
f0101dbc:	89 c2                	mov    %eax,%edx
f0101dbe:	8b 03                	mov    (%ebx),%eax
f0101dc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101dc5:	39 d0                	cmp    %edx,%eax
f0101dc7:	0f 85 31 01 00 00    	jne    f0101efe <check_page_installed_pgdir+0x27c>
	kern_pgdir[0] = 0;
f0101dcd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	assert(pp0->pp_ref == 1);
f0101dd3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dd8:	0f 85 39 01 00 00    	jne    f0101f17 <check_page_installed_pgdir+0x295>
	pp0->pp_ref = 0;
f0101dde:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0101de4:	83 ec 0c             	sub    $0xc,%esp
f0101de7:	56                   	push   %esi
f0101de8:	e8 31 f4 ff ff       	call   f010121e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101ded:	c7 04 24 cc 6e 10 f0 	movl   $0xf0106ecc,(%esp)
f0101df4:	e8 12 1c 00 00       	call   f0103a0b <cprintf>
}
f0101df9:	83 c4 10             	add    $0x10,%esp
f0101dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101dff:	5b                   	pop    %ebx
f0101e00:	5e                   	pop    %esi
f0101e01:	5f                   	pop    %edi
f0101e02:	5d                   	pop    %ebp
f0101e03:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f0101e04:	68 cd 75 10 f0       	push   $0xf01075cd
f0101e09:	68 e7 74 10 f0       	push   $0xf01074e7
f0101e0e:	68 8b 04 00 00       	push   $0x48b
f0101e13:	68 cf 74 10 f0       	push   $0xf01074cf
f0101e18:	e8 4d e2 ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101e1d:	68 e3 75 10 f0       	push   $0xf01075e3
f0101e22:	68 e7 74 10 f0       	push   $0xf01074e7
f0101e27:	68 8c 04 00 00       	push   $0x48c
f0101e2c:	68 cf 74 10 f0       	push   $0xf01074cf
f0101e31:	e8 34 e2 ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0101e36:	68 f9 75 10 f0       	push   $0xf01075f9
f0101e3b:	68 e7 74 10 f0       	push   $0xf01074e7
f0101e40:	68 8d 04 00 00       	push   $0x48d
f0101e45:	68 cf 74 10 f0       	push   $0xf01074cf
f0101e4a:	e8 1b e2 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0101e4f:	68 ef 76 10 f0       	push   $0xf01076ef
f0101e54:	68 e7 74 10 f0       	push   $0xf01074e7
f0101e59:	68 92 04 00 00       	push   $0x492
f0101e5e:	68 cf 74 10 f0       	push   $0xf01074cf
f0101e63:	e8 02 e2 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101e68:	68 30 6e 10 f0       	push   $0xf0106e30
f0101e6d:	68 e7 74 10 f0       	push   $0xf01074e7
f0101e72:	68 93 04 00 00       	push   $0x493
f0101e77:	68 cf 74 10 f0       	push   $0xf01074cf
f0101e7c:	e8 e9 e1 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101e81:	68 54 6e 10 f0       	push   $0xf0106e54
f0101e86:	68 e7 74 10 f0       	push   $0xf01074e7
f0101e8b:	68 95 04 00 00       	push   $0x495
f0101e90:	68 cf 74 10 f0       	push   $0xf01074cf
f0101e95:	e8 d0 e1 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0101e9a:	68 00 77 10 f0       	push   $0xf0107700
f0101e9f:	68 e7 74 10 f0       	push   $0xf01074e7
f0101ea4:	68 96 04 00 00       	push   $0x496
f0101ea9:	68 cf 74 10 f0       	push   $0xf01074cf
f0101eae:	e8 b7 e1 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0101eb3:	68 11 77 10 f0       	push   $0xf0107711
f0101eb8:	68 e7 74 10 f0       	push   $0xf01074e7
f0101ebd:	68 97 04 00 00       	push   $0x497
f0101ec2:	68 cf 74 10 f0       	push   $0xf01074cf
f0101ec7:	e8 9e e1 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101ecc:	68 78 6e 10 f0       	push   $0xf0106e78
f0101ed1:	68 e7 74 10 f0       	push   $0xf01074e7
f0101ed6:	68 99 04 00 00       	push   $0x499
f0101edb:	68 cf 74 10 f0       	push   $0xf01074cf
f0101ee0:	e8 85 e1 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0101ee5:	68 22 77 10 f0       	push   $0xf0107722
f0101eea:	68 e7 74 10 f0       	push   $0xf01074e7
f0101eef:	68 9b 04 00 00       	push   $0x49b
f0101ef4:	68 cf 74 10 f0       	push   $0xf01074cf
f0101ef9:	e8 6c e1 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101efe:	68 a4 6e 10 f0       	push   $0xf0106ea4
f0101f03:	68 e7 74 10 f0       	push   $0xf01074e7
f0101f08:	68 9e 04 00 00       	push   $0x49e
f0101f0d:	68 cf 74 10 f0       	push   $0xf01074cf
f0101f12:	e8 53 e1 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0101f17:	68 33 77 10 f0       	push   $0xf0107733
f0101f1c:	68 e7 74 10 f0       	push   $0xf01074e7
f0101f21:	68 a0 04 00 00       	push   $0x4a0
f0101f26:	68 cf 74 10 f0       	push   $0xf01074cf
f0101f2b:	e8 3a e1 ff ff       	call   f010006a <_panic>

f0101f30 <mmio_map_region>:
{
f0101f30:	f3 0f 1e fb          	endbr32 
f0101f34:	55                   	push   %ebp
f0101f35:	89 e5                	mov    %esp,%ebp
f0101f37:	56                   	push   %esi
f0101f38:	53                   	push   %ebx
	size = ROUNDUP(size, PGSIZE);
f0101f39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101f3c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101f42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t resultado = base;
f0101f48:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi
	if ((void *) base + size > (void *) MMIOLIM)
f0101f4e:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101f51:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101f56:	77 25                	ja     f0101f7d <mmio_map_region+0x4d>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101f58:	83 ec 08             	sub    $0x8,%esp
f0101f5b:	6a 1a                	push   $0x1a
f0101f5d:	ff 75 08             	pushl  0x8(%ebp)
f0101f60:	89 d9                	mov    %ebx,%ecx
f0101f62:	89 f2                	mov    %esi,%edx
f0101f64:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101f69:	e8 c5 f7 ff ff       	call   f0101733 <boot_map_region>
	base += size;
f0101f6e:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300
}
f0101f74:	89 f0                	mov    %esi,%eax
f0101f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101f79:	5b                   	pop    %ebx
f0101f7a:	5e                   	pop    %esi
f0101f7b:	5d                   	pop    %ebp
f0101f7c:	c3                   	ret    
		panic("overflow mmiolim");
f0101f7d:	83 ec 04             	sub    $0x4,%esp
f0101f80:	68 44 77 10 f0       	push   $0xf0107744
f0101f85:	68 92 02 00 00       	push   $0x292
f0101f8a:	68 cf 74 10 f0       	push   $0xf01074cf
f0101f8f:	e8 d6 e0 ff ff       	call   f010006a <_panic>

f0101f94 <check_page>:
{
f0101f94:	55                   	push   %ebp
f0101f95:	89 e5                	mov    %esp,%ebp
f0101f97:	57                   	push   %edi
f0101f98:	56                   	push   %esi
f0101f99:	53                   	push   %ebx
f0101f9a:	83 ec 38             	sub    $0x38,%esp
	assert((pp0 = page_alloc(0)));
f0101f9d:	6a 00                	push   $0x0
f0101f9f:	e8 2f f2 ff ff       	call   f01011d3 <page_alloc>
f0101fa4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fa7:	83 c4 10             	add    $0x10,%esp
f0101faa:	85 c0                	test   %eax,%eax
f0101fac:	0f 84 71 07 00 00    	je     f0102723 <check_page+0x78f>
	assert((pp1 = page_alloc(0)));
f0101fb2:	83 ec 0c             	sub    $0xc,%esp
f0101fb5:	6a 00                	push   $0x0
f0101fb7:	e8 17 f2 ff ff       	call   f01011d3 <page_alloc>
f0101fbc:	89 c6                	mov    %eax,%esi
f0101fbe:	83 c4 10             	add    $0x10,%esp
f0101fc1:	85 c0                	test   %eax,%eax
f0101fc3:	0f 84 73 07 00 00    	je     f010273c <check_page+0x7a8>
	assert((pp2 = page_alloc(0)));
f0101fc9:	83 ec 0c             	sub    $0xc,%esp
f0101fcc:	6a 00                	push   $0x0
f0101fce:	e8 00 f2 ff ff       	call   f01011d3 <page_alloc>
f0101fd3:	89 c3                	mov    %eax,%ebx
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	85 c0                	test   %eax,%eax
f0101fda:	0f 84 75 07 00 00    	je     f0102755 <check_page+0x7c1>
	assert(pp1 && pp1 != pp0);
f0101fe0:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101fe3:	0f 84 85 07 00 00    	je     f010276e <check_page+0x7da>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fe9:	39 c6                	cmp    %eax,%esi
f0101feb:	0f 84 96 07 00 00    	je     f0102787 <check_page+0x7f3>
f0101ff1:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ff4:	0f 84 8d 07 00 00    	je     f0102787 <check_page+0x7f3>
	fl = page_free_list;
f0101ffa:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f0101fff:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0102002:	c7 05 40 12 22 f0 00 	movl   $0x0,0xf0221240
f0102009:	00 00 00 
	assert(!page_alloc(0));
f010200c:	83 ec 0c             	sub    $0xc,%esp
f010200f:	6a 00                	push   $0x0
f0102011:	e8 bd f1 ff ff       	call   f01011d3 <page_alloc>
f0102016:	83 c4 10             	add    $0x10,%esp
f0102019:	85 c0                	test   %eax,%eax
f010201b:	0f 85 7f 07 00 00    	jne    f01027a0 <check_page+0x80c>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102021:	83 ec 04             	sub    $0x4,%esp
f0102024:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102027:	50                   	push   %eax
f0102028:	6a 00                	push   $0x0
f010202a:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102030:	e8 2f fb ff ff       	call   f0101b64 <page_lookup>
f0102035:	83 c4 10             	add    $0x10,%esp
f0102038:	85 c0                	test   %eax,%eax
f010203a:	0f 85 79 07 00 00    	jne    f01027b9 <check_page+0x825>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102040:	6a 02                	push   $0x2
f0102042:	6a 00                	push   $0x0
f0102044:	56                   	push   %esi
f0102045:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f010204b:	e8 d4 fb ff ff       	call   f0101c24 <page_insert>
f0102050:	83 c4 10             	add    $0x10,%esp
f0102053:	85 c0                	test   %eax,%eax
f0102055:	0f 89 77 07 00 00    	jns    f01027d2 <check_page+0x83e>
	page_free(pp0);
f010205b:	83 ec 0c             	sub    $0xc,%esp
f010205e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102061:	e8 b8 f1 ff ff       	call   f010121e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102066:	6a 02                	push   $0x2
f0102068:	6a 00                	push   $0x0
f010206a:	56                   	push   %esi
f010206b:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102071:	e8 ae fb ff ff       	call   f0101c24 <page_insert>
f0102076:	83 c4 20             	add    $0x20,%esp
f0102079:	85 c0                	test   %eax,%eax
f010207b:	0f 85 6a 07 00 00    	jne    f01027eb <check_page+0x857>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102081:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f0102087:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010208a:	e8 d1 eb ff ff       	call   f0100c60 <page2pa>
f010208f:	89 c2                	mov    %eax,%edx
f0102091:	8b 07                	mov    (%edi),%eax
f0102093:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102098:	39 d0                	cmp    %edx,%eax
f010209a:	0f 85 64 07 00 00    	jne    f0102804 <check_page+0x870>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01020a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01020a5:	89 f8                	mov    %edi,%eax
f01020a7:	e8 98 ec ff ff       	call   f0100d44 <check_va2pa>
f01020ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01020af:	89 f0                	mov    %esi,%eax
f01020b1:	e8 aa eb ff ff       	call   f0100c60 <page2pa>
f01020b6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01020b9:	0f 85 5e 07 00 00    	jne    f010281d <check_page+0x889>
	assert(pp1->pp_ref == 1);
f01020bf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020c4:	0f 85 6c 07 00 00    	jne    f0102836 <check_page+0x8a2>
	assert(pp0->pp_ref == 1);
f01020ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020cd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020d2:	0f 85 77 07 00 00    	jne    f010284f <check_page+0x8bb>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01020d8:	6a 02                	push   $0x2
f01020da:	68 00 10 00 00       	push   $0x1000
f01020df:	53                   	push   %ebx
f01020e0:	57                   	push   %edi
f01020e1:	e8 3e fb ff ff       	call   f0101c24 <page_insert>
f01020e6:	83 c4 10             	add    $0x10,%esp
f01020e9:	85 c0                	test   %eax,%eax
f01020eb:	0f 85 77 07 00 00    	jne    f0102868 <check_page+0x8d4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020f1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020f6:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01020fb:	e8 44 ec ff ff       	call   f0100d44 <check_va2pa>
f0102100:	89 c7                	mov    %eax,%edi
f0102102:	89 d8                	mov    %ebx,%eax
f0102104:	e8 57 eb ff ff       	call   f0100c60 <page2pa>
f0102109:	39 c7                	cmp    %eax,%edi
f010210b:	0f 85 70 07 00 00    	jne    f0102881 <check_page+0x8ed>
	assert(pp2->pp_ref == 1);
f0102111:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102116:	0f 85 7e 07 00 00    	jne    f010289a <check_page+0x906>
	assert(!page_alloc(0));
f010211c:	83 ec 0c             	sub    $0xc,%esp
f010211f:	6a 00                	push   $0x0
f0102121:	e8 ad f0 ff ff       	call   f01011d3 <page_alloc>
f0102126:	83 c4 10             	add    $0x10,%esp
f0102129:	85 c0                	test   %eax,%eax
f010212b:	0f 85 82 07 00 00    	jne    f01028b3 <check_page+0x91f>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102131:	6a 02                	push   $0x2
f0102133:	68 00 10 00 00       	push   $0x1000
f0102138:	53                   	push   %ebx
f0102139:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f010213f:	e8 e0 fa ff ff       	call   f0101c24 <page_insert>
f0102144:	83 c4 10             	add    $0x10,%esp
f0102147:	85 c0                	test   %eax,%eax
f0102149:	0f 85 7d 07 00 00    	jne    f01028cc <check_page+0x938>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010214f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102154:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102159:	e8 e6 eb ff ff       	call   f0100d44 <check_va2pa>
f010215e:	89 c7                	mov    %eax,%edi
f0102160:	89 d8                	mov    %ebx,%eax
f0102162:	e8 f9 ea ff ff       	call   f0100c60 <page2pa>
f0102167:	39 c7                	cmp    %eax,%edi
f0102169:	0f 85 76 07 00 00    	jne    f01028e5 <check_page+0x951>
	assert(pp2->pp_ref == 1);
f010216f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102174:	0f 85 84 07 00 00    	jne    f01028fe <check_page+0x96a>
	assert(!page_alloc(0));
f010217a:	83 ec 0c             	sub    $0xc,%esp
f010217d:	6a 00                	push   $0x0
f010217f:	e8 4f f0 ff ff       	call   f01011d3 <page_alloc>
f0102184:	83 c4 10             	add    $0x10,%esp
f0102187:	85 c0                	test   %eax,%eax
f0102189:	0f 85 88 07 00 00    	jne    f0102917 <check_page+0x983>
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010218f:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f0102195:	8b 0f                	mov    (%edi),%ecx
f0102197:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010219d:	ba 09 04 00 00       	mov    $0x409,%edx
f01021a2:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f01021a7:	e8 4e eb ff ff       	call   f0100cfa <_kaddr>
f01021ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f01021af:	83 ec 04             	sub    $0x4,%esp
f01021b2:	6a 00                	push   $0x0
f01021b4:	68 00 10 00 00       	push   $0x1000
f01021b9:	57                   	push   %edi
f01021ba:	e8 04 f5 ff ff       	call   f01016c3 <pgdir_walk>
f01021bf:	89 c2                	mov    %eax,%edx
f01021c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01021c4:	83 c0 04             	add    $0x4,%eax
f01021c7:	83 c4 10             	add    $0x10,%esp
f01021ca:	39 d0                	cmp    %edx,%eax
f01021cc:	0f 85 5e 07 00 00    	jne    f0102930 <check_page+0x99c>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f01021d2:	6a 06                	push   $0x6
f01021d4:	68 00 10 00 00       	push   $0x1000
f01021d9:	53                   	push   %ebx
f01021da:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01021e0:	e8 3f fa ff ff       	call   f0101c24 <page_insert>
f01021e5:	83 c4 10             	add    $0x10,%esp
f01021e8:	85 c0                	test   %eax,%eax
f01021ea:	0f 85 59 07 00 00    	jne    f0102949 <check_page+0x9b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021f0:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f01021f6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021fb:	89 f8                	mov    %edi,%eax
f01021fd:	e8 42 eb ff ff       	call   f0100d44 <check_va2pa>
f0102202:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102205:	89 d8                	mov    %ebx,%eax
f0102207:	e8 54 ea ff ff       	call   f0100c60 <page2pa>
f010220c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010220f:	0f 85 4d 07 00 00    	jne    f0102962 <check_page+0x9ce>
	assert(pp2->pp_ref == 1);
f0102215:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010221a:	0f 85 5b 07 00 00    	jne    f010297b <check_page+0x9e7>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f0102220:	83 ec 04             	sub    $0x4,%esp
f0102223:	6a 00                	push   $0x0
f0102225:	68 00 10 00 00       	push   $0x1000
f010222a:	57                   	push   %edi
f010222b:	e8 93 f4 ff ff       	call   f01016c3 <pgdir_walk>
f0102230:	83 c4 10             	add    $0x10,%esp
f0102233:	f6 00 04             	testb  $0x4,(%eax)
f0102236:	0f 84 58 07 00 00    	je     f0102994 <check_page+0xa00>
	assert(kern_pgdir[0] & PTE_U);
f010223c:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102241:	f6 00 04             	testb  $0x4,(%eax)
f0102244:	0f 84 63 07 00 00    	je     f01029ad <check_page+0xa19>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f010224a:	6a 02                	push   $0x2
f010224c:	68 00 10 00 00       	push   $0x1000
f0102251:	53                   	push   %ebx
f0102252:	50                   	push   %eax
f0102253:	e8 cc f9 ff ff       	call   f0101c24 <page_insert>
f0102258:	83 c4 10             	add    $0x10,%esp
f010225b:	85 c0                	test   %eax,%eax
f010225d:	0f 85 63 07 00 00    	jne    f01029c6 <check_page+0xa32>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f0102263:	83 ec 04             	sub    $0x4,%esp
f0102266:	6a 00                	push   $0x0
f0102268:	68 00 10 00 00       	push   $0x1000
f010226d:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102273:	e8 4b f4 ff ff       	call   f01016c3 <pgdir_walk>
f0102278:	83 c4 10             	add    $0x10,%esp
f010227b:	f6 00 02             	testb  $0x2,(%eax)
f010227e:	0f 84 5b 07 00 00    	je     f01029df <check_page+0xa4b>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102284:	83 ec 04             	sub    $0x4,%esp
f0102287:	6a 00                	push   $0x0
f0102289:	68 00 10 00 00       	push   $0x1000
f010228e:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102294:	e8 2a f4 ff ff       	call   f01016c3 <pgdir_walk>
f0102299:	83 c4 10             	add    $0x10,%esp
f010229c:	f6 00 04             	testb  $0x4,(%eax)
f010229f:	0f 85 53 07 00 00    	jne    f01029f8 <check_page+0xa64>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f01022a5:	6a 02                	push   $0x2
f01022a7:	68 00 00 40 00       	push   $0x400000
f01022ac:	ff 75 d4             	pushl  -0x2c(%ebp)
f01022af:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01022b5:	e8 6a f9 ff ff       	call   f0101c24 <page_insert>
f01022ba:	83 c4 10             	add    $0x10,%esp
f01022bd:	85 c0                	test   %eax,%eax
f01022bf:	0f 89 4c 07 00 00    	jns    f0102a11 <check_page+0xa7d>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f01022c5:	6a 02                	push   $0x2
f01022c7:	68 00 10 00 00       	push   $0x1000
f01022cc:	56                   	push   %esi
f01022cd:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01022d3:	e8 4c f9 ff ff       	call   f0101c24 <page_insert>
f01022d8:	83 c4 10             	add    $0x10,%esp
f01022db:	85 c0                	test   %eax,%eax
f01022dd:	0f 85 47 07 00 00    	jne    f0102a2a <check_page+0xa96>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f01022e3:	83 ec 04             	sub    $0x4,%esp
f01022e6:	6a 00                	push   $0x0
f01022e8:	68 00 10 00 00       	push   $0x1000
f01022ed:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01022f3:	e8 cb f3 ff ff       	call   f01016c3 <pgdir_walk>
f01022f8:	83 c4 10             	add    $0x10,%esp
f01022fb:	f6 00 04             	testb  $0x4,(%eax)
f01022fe:	0f 85 3f 07 00 00    	jne    f0102a43 <check_page+0xaaf>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102304:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010230a:	ba 00 00 00 00       	mov    $0x0,%edx
f010230f:	89 f8                	mov    %edi,%eax
f0102311:	e8 2e ea ff ff       	call   f0100d44 <check_va2pa>
f0102316:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102319:	89 f0                	mov    %esi,%eax
f010231b:	e8 40 e9 ff ff       	call   f0100c60 <page2pa>
f0102320:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102323:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102326:	0f 85 30 07 00 00    	jne    f0102a5c <check_page+0xac8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010232c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102331:	89 f8                	mov    %edi,%eax
f0102333:	e8 0c ea ff ff       	call   f0100d44 <check_va2pa>
f0102338:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010233b:	0f 85 34 07 00 00    	jne    f0102a75 <check_page+0xae1>
	assert(pp1->pp_ref == 2);
f0102341:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102346:	0f 85 42 07 00 00    	jne    f0102a8e <check_page+0xafa>
	assert(pp2->pp_ref == 0);
f010234c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102351:	0f 85 50 07 00 00    	jne    f0102aa7 <check_page+0xb13>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102357:	83 ec 0c             	sub    $0xc,%esp
f010235a:	6a 00                	push   $0x0
f010235c:	e8 72 ee ff ff       	call   f01011d3 <page_alloc>
f0102361:	83 c4 10             	add    $0x10,%esp
f0102364:	39 c3                	cmp    %eax,%ebx
f0102366:	0f 85 54 07 00 00    	jne    f0102ac0 <check_page+0xb2c>
f010236c:	85 c0                	test   %eax,%eax
f010236e:	0f 84 4c 07 00 00    	je     f0102ac0 <check_page+0xb2c>
	page_remove(kern_pgdir, 0x0);
f0102374:	83 ec 08             	sub    $0x8,%esp
f0102377:	6a 00                	push   $0x0
f0102379:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f010237f:	e8 4c f8 ff ff       	call   f0101bd0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102384:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010238a:	ba 00 00 00 00       	mov    $0x0,%edx
f010238f:	89 f8                	mov    %edi,%eax
f0102391:	e8 ae e9 ff ff       	call   f0100d44 <check_va2pa>
f0102396:	83 c4 10             	add    $0x10,%esp
f0102399:	83 f8 ff             	cmp    $0xffffffff,%eax
f010239c:	0f 85 37 07 00 00    	jne    f0102ad9 <check_page+0xb45>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023a2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023a7:	89 f8                	mov    %edi,%eax
f01023a9:	e8 96 e9 ff ff       	call   f0100d44 <check_va2pa>
f01023ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023b1:	89 f0                	mov    %esi,%eax
f01023b3:	e8 a8 e8 ff ff       	call   f0100c60 <page2pa>
f01023b8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01023bb:	0f 85 31 07 00 00    	jne    f0102af2 <check_page+0xb5e>
	assert(pp1->pp_ref == 1);
f01023c1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023c6:	0f 85 3f 07 00 00    	jne    f0102b0b <check_page+0xb77>
	assert(pp2->pp_ref == 0);
f01023cc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023d1:	0f 85 4d 07 00 00    	jne    f0102b24 <check_page+0xb90>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f01023d7:	6a 00                	push   $0x0
f01023d9:	68 00 10 00 00       	push   $0x1000
f01023de:	56                   	push   %esi
f01023df:	57                   	push   %edi
f01023e0:	e8 3f f8 ff ff       	call   f0101c24 <page_insert>
f01023e5:	83 c4 10             	add    $0x10,%esp
f01023e8:	85 c0                	test   %eax,%eax
f01023ea:	0f 85 4d 07 00 00    	jne    f0102b3d <check_page+0xba9>
	assert(pp1->pp_ref);
f01023f0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01023f5:	0f 84 5b 07 00 00    	je     f0102b56 <check_page+0xbc2>
	assert(pp1->pp_link == NULL);
f01023fb:	83 3e 00             	cmpl   $0x0,(%esi)
f01023fe:	0f 85 6b 07 00 00    	jne    f0102b6f <check_page+0xbdb>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0102404:	83 ec 08             	sub    $0x8,%esp
f0102407:	68 00 10 00 00       	push   $0x1000
f010240c:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102412:	e8 b9 f7 ff ff       	call   f0101bd0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102417:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010241d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102422:	89 f8                	mov    %edi,%eax
f0102424:	e8 1b e9 ff ff       	call   f0100d44 <check_va2pa>
f0102429:	83 c4 10             	add    $0x10,%esp
f010242c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010242f:	0f 85 53 07 00 00    	jne    f0102b88 <check_page+0xbf4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102435:	ba 00 10 00 00       	mov    $0x1000,%edx
f010243a:	89 f8                	mov    %edi,%eax
f010243c:	e8 03 e9 ff ff       	call   f0100d44 <check_va2pa>
f0102441:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102444:	0f 85 57 07 00 00    	jne    f0102ba1 <check_page+0xc0d>
	assert(pp1->pp_ref == 0);
f010244a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010244f:	0f 85 65 07 00 00    	jne    f0102bba <check_page+0xc26>
	assert(pp2->pp_ref == 0);
f0102455:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010245a:	0f 85 73 07 00 00    	jne    f0102bd3 <check_page+0xc3f>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102460:	83 ec 0c             	sub    $0xc,%esp
f0102463:	6a 00                	push   $0x0
f0102465:	e8 69 ed ff ff       	call   f01011d3 <page_alloc>
f010246a:	83 c4 10             	add    $0x10,%esp
f010246d:	39 c6                	cmp    %eax,%esi
f010246f:	0f 85 77 07 00 00    	jne    f0102bec <check_page+0xc58>
f0102475:	85 c0                	test   %eax,%eax
f0102477:	0f 84 6f 07 00 00    	je     f0102bec <check_page+0xc58>
	assert(!page_alloc(0));
f010247d:	83 ec 0c             	sub    $0xc,%esp
f0102480:	6a 00                	push   $0x0
f0102482:	e8 4c ed ff ff       	call   f01011d3 <page_alloc>
f0102487:	83 c4 10             	add    $0x10,%esp
f010248a:	85 c0                	test   %eax,%eax
f010248c:	0f 85 73 07 00 00    	jne    f0102c05 <check_page+0xc71>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102492:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f0102498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010249b:	e8 c0 e7 ff ff       	call   f0100c60 <page2pa>
f01024a0:	89 c2                	mov    %eax,%edx
f01024a2:	8b 07                	mov    (%edi),%eax
f01024a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01024a9:	39 d0                	cmp    %edx,%eax
f01024ab:	0f 85 6d 07 00 00    	jne    f0102c1e <check_page+0xc8a>
	kern_pgdir[0] = 0;
f01024b1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	assert(pp0->pp_ref == 1);
f01024b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024ba:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01024bf:	0f 85 72 07 00 00    	jne    f0102c37 <check_page+0xca3>
	pp0->pp_ref = 0;
f01024c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024c8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free(pp0);
f01024ce:	83 ec 0c             	sub    $0xc,%esp
f01024d1:	50                   	push   %eax
f01024d2:	e8 47 ed ff ff       	call   f010121e <page_free>
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01024d7:	83 c4 0c             	add    $0xc,%esp
f01024da:	6a 01                	push   $0x1
f01024dc:	68 00 10 40 00       	push   $0x401000
f01024e1:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01024e7:	e8 d7 f1 ff ff       	call   f01016c3 <pgdir_walk>
f01024ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01024ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01024f2:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f01024f8:	8b 4f 04             	mov    0x4(%edi),%ecx
f01024fb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102501:	ba 4d 04 00 00       	mov    $0x44d,%edx
f0102506:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f010250b:	e8 ea e7 ff ff       	call   f0100cfa <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f0102510:	83 c0 04             	add    $0x4,%eax
f0102513:	83 c4 10             	add    $0x10,%esp
f0102516:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102519:	0f 85 31 07 00 00    	jne    f0102c50 <check_page+0xcbc>
	kern_pgdir[PDX(va)] = 0;
f010251f:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	pp0->pp_ref = 0;
f0102526:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102529:	89 f8                	mov    %edi,%eax
f010252b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102531:	e8 f0 e7 ff ff       	call   f0100d26 <page2kva>
f0102536:	83 ec 04             	sub    $0x4,%esp
f0102539:	68 00 10 00 00       	push   $0x1000
f010253e:	68 ff 00 00 00       	push   $0xff
f0102543:	50                   	push   %eax
f0102544:	e8 ca 32 00 00       	call   f0105813 <memset>
	page_free(pp0);
f0102549:	89 3c 24             	mov    %edi,(%esp)
f010254c:	e8 cd ec ff ff       	call   f010121e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102551:	83 c4 0c             	add    $0xc,%esp
f0102554:	6a 01                	push   $0x1
f0102556:	6a 00                	push   $0x0
f0102558:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f010255e:	e8 60 f1 ff ff       	call   f01016c3 <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0102563:	89 f8                	mov    %edi,%eax
f0102565:	e8 bc e7 ff ff       	call   f0100d26 <page2kva>
f010256a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010256d:	89 c2                	mov    %eax,%edx
f010256f:	05 00 10 00 00       	add    $0x1000,%eax
f0102574:	83 c4 10             	add    $0x10,%esp
		assert((ptep[i] & PTE_P) == 0);
f0102577:	f6 02 01             	testb  $0x1,(%edx)
f010257a:	0f 85 e9 06 00 00    	jne    f0102c69 <check_page+0xcd5>
f0102580:	83 c2 04             	add    $0x4,%edx
	for (i = 0; i < NPTENTRIES; i++)
f0102583:	39 c2                	cmp    %eax,%edx
f0102585:	75 f0                	jne    f0102577 <check_page+0x5e3>
	kern_pgdir[0] = 0;
f0102587:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010258c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102592:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102595:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free_list = fl;
f010259b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010259e:	89 0d 40 12 22 f0    	mov    %ecx,0xf0221240
	page_free(pp0);
f01025a4:	83 ec 0c             	sub    $0xc,%esp
f01025a7:	50                   	push   %eax
f01025a8:	e8 71 ec ff ff       	call   f010121e <page_free>
	page_free(pp1);
f01025ad:	89 34 24             	mov    %esi,(%esp)
f01025b0:	e8 69 ec ff ff       	call   f010121e <page_free>
	page_free(pp2);
f01025b5:	89 1c 24             	mov    %ebx,(%esp)
f01025b8:	e8 61 ec ff ff       	call   f010121e <page_free>
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01025bd:	83 c4 08             	add    $0x8,%esp
f01025c0:	68 01 10 00 00       	push   $0x1001
f01025c5:	6a 00                	push   $0x0
f01025c7:	e8 64 f9 ff ff       	call   f0101f30 <mmio_map_region>
f01025cc:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01025ce:	83 c4 08             	add    $0x8,%esp
f01025d1:	68 00 10 00 00       	push   $0x1000
f01025d6:	6a 00                	push   $0x0
f01025d8:	e8 53 f9 ff ff       	call   f0101f30 <mmio_map_region>
f01025dd:	89 c6                	mov    %eax,%esi
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01025df:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01025e5:	83 c4 10             	add    $0x10,%esp
f01025e8:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01025ee:	0f 86 8e 06 00 00    	jbe    f0102c82 <check_page+0xcee>
f01025f4:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01025f9:	0f 87 83 06 00 00    	ja     f0102c82 <check_page+0xcee>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01025ff:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102605:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010260b:	0f 87 8a 06 00 00    	ja     f0102c9b <check_page+0xd07>
f0102611:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102617:	0f 86 7e 06 00 00    	jbe    f0102c9b <check_page+0xd07>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010261d:	89 da                	mov    %ebx,%edx
f010261f:	09 f2                	or     %esi,%edx
f0102621:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102627:	0f 85 87 06 00 00    	jne    f0102cb4 <check_page+0xd20>
	assert(mm1 + 8096 <= mm2);
f010262d:	39 f0                	cmp    %esi,%eax
f010262f:	0f 87 98 06 00 00    	ja     f0102ccd <check_page+0xd39>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102635:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010263b:	89 da                	mov    %ebx,%edx
f010263d:	89 f8                	mov    %edi,%eax
f010263f:	e8 00 e7 ff ff       	call   f0100d44 <check_va2pa>
f0102644:	85 c0                	test   %eax,%eax
f0102646:	0f 85 9a 06 00 00    	jne    f0102ce6 <check_page+0xd52>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f010264c:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102652:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102655:	89 c2                	mov    %eax,%edx
f0102657:	89 f8                	mov    %edi,%eax
f0102659:	e8 e6 e6 ff ff       	call   f0100d44 <check_va2pa>
f010265e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102663:	0f 85 96 06 00 00    	jne    f0102cff <check_page+0xd6b>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102669:	89 f2                	mov    %esi,%edx
f010266b:	89 f8                	mov    %edi,%eax
f010266d:	e8 d2 e6 ff ff       	call   f0100d44 <check_va2pa>
f0102672:	85 c0                	test   %eax,%eax
f0102674:	0f 85 9e 06 00 00    	jne    f0102d18 <check_page+0xd84>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f010267a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102680:	89 f8                	mov    %edi,%eax
f0102682:	e8 bd e6 ff ff       	call   f0100d44 <check_va2pa>
f0102687:	83 f8 ff             	cmp    $0xffffffff,%eax
f010268a:	0f 85 a1 06 00 00    	jne    f0102d31 <check_page+0xd9d>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f0102690:	83 ec 04             	sub    $0x4,%esp
f0102693:	6a 00                	push   $0x0
f0102695:	53                   	push   %ebx
f0102696:	57                   	push   %edi
f0102697:	e8 27 f0 ff ff       	call   f01016c3 <pgdir_walk>
f010269c:	83 c4 10             	add    $0x10,%esp
f010269f:	f6 00 1a             	testb  $0x1a,(%eax)
f01026a2:	0f 84 a2 06 00 00    	je     f0102d4a <check_page+0xdb6>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f01026a8:	83 ec 04             	sub    $0x4,%esp
f01026ab:	6a 00                	push   $0x0
f01026ad:	53                   	push   %ebx
f01026ae:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01026b4:	e8 0a f0 ff ff       	call   f01016c3 <pgdir_walk>
f01026b9:	83 c4 10             	add    $0x10,%esp
f01026bc:	f6 00 04             	testb  $0x4,(%eax)
f01026bf:	0f 85 9e 06 00 00    	jne    f0102d63 <check_page+0xdcf>
	*pgdir_walk(kern_pgdir, (void *) mm1, 0) = 0;
f01026c5:	83 ec 04             	sub    $0x4,%esp
f01026c8:	6a 00                	push   $0x0
f01026ca:	53                   	push   %ebx
f01026cb:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01026d1:	e8 ed ef ff ff       	call   f01016c3 <pgdir_walk>
f01026d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm1 + PGSIZE, 0) = 0;
f01026dc:	83 c4 0c             	add    $0xc,%esp
f01026df:	6a 00                	push   $0x0
f01026e1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026e4:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01026ea:	e8 d4 ef ff ff       	call   f01016c3 <pgdir_walk>
f01026ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm2, 0) = 0;
f01026f5:	83 c4 0c             	add    $0xc,%esp
f01026f8:	6a 00                	push   $0x0
f01026fa:	56                   	push   %esi
f01026fb:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102701:	e8 bd ef ff ff       	call   f01016c3 <pgdir_walk>
f0102706:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("check_page() succeeded!\n");
f010270c:	c7 04 24 de 77 10 f0 	movl   $0xf01077de,(%esp)
f0102713:	e8 f3 12 00 00       	call   f0103a0b <cprintf>
}
f0102718:	83 c4 10             	add    $0x10,%esp
f010271b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010271e:	5b                   	pop    %ebx
f010271f:	5e                   	pop    %esi
f0102720:	5f                   	pop    %edi
f0102721:	5d                   	pop    %ebp
f0102722:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f0102723:	68 cd 75 10 f0       	push   $0xf01075cd
f0102728:	68 e7 74 10 f0       	push   $0xf01074e7
f010272d:	68 d9 03 00 00       	push   $0x3d9
f0102732:	68 cf 74 10 f0       	push   $0xf01074cf
f0102737:	e8 2e d9 ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f010273c:	68 e3 75 10 f0       	push   $0xf01075e3
f0102741:	68 e7 74 10 f0       	push   $0xf01074e7
f0102746:	68 da 03 00 00       	push   $0x3da
f010274b:	68 cf 74 10 f0       	push   $0xf01074cf
f0102750:	e8 15 d9 ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0102755:	68 f9 75 10 f0       	push   $0xf01075f9
f010275a:	68 e7 74 10 f0       	push   $0xf01074e7
f010275f:	68 db 03 00 00       	push   $0x3db
f0102764:	68 cf 74 10 f0       	push   $0xf01074cf
f0102769:	e8 fc d8 ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f010276e:	68 0f 76 10 f0       	push   $0xf010760f
f0102773:	68 e7 74 10 f0       	push   $0xf01074e7
f0102778:	68 de 03 00 00       	push   $0x3de
f010277d:	68 cf 74 10 f0       	push   $0xf01074cf
f0102782:	e8 e3 d8 ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102787:	68 54 6c 10 f0       	push   $0xf0106c54
f010278c:	68 e7 74 10 f0       	push   $0xf01074e7
f0102791:	68 df 03 00 00       	push   $0x3df
f0102796:	68 cf 74 10 f0       	push   $0xf01074cf
f010279b:	e8 ca d8 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01027a0:	68 21 76 10 f0       	push   $0xf0107621
f01027a5:	68 e7 74 10 f0       	push   $0xf01074e7
f01027aa:	68 e6 03 00 00       	push   $0x3e6
f01027af:	68 cf 74 10 f0       	push   $0xf01074cf
f01027b4:	e8 b1 d8 ff ff       	call   f010006a <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01027b9:	68 f8 6e 10 f0       	push   $0xf0106ef8
f01027be:	68 e7 74 10 f0       	push   $0xf01074e7
f01027c3:	68 e9 03 00 00       	push   $0x3e9
f01027c8:	68 cf 74 10 f0       	push   $0xf01074cf
f01027cd:	e8 98 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01027d2:	68 30 6f 10 f0       	push   $0xf0106f30
f01027d7:	68 e7 74 10 f0       	push   $0xf01074e7
f01027dc:	68 ec 03 00 00       	push   $0x3ec
f01027e1:	68 cf 74 10 f0       	push   $0xf01074cf
f01027e6:	e8 7f d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01027eb:	68 60 6f 10 f0       	push   $0xf0106f60
f01027f0:	68 e7 74 10 f0       	push   $0xf01074e7
f01027f5:	68 f0 03 00 00       	push   $0x3f0
f01027fa:	68 cf 74 10 f0       	push   $0xf01074cf
f01027ff:	e8 66 d8 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102804:	68 a4 6e 10 f0       	push   $0xf0106ea4
f0102809:	68 e7 74 10 f0       	push   $0xf01074e7
f010280e:	68 f1 03 00 00       	push   $0x3f1
f0102813:	68 cf 74 10 f0       	push   $0xf01074cf
f0102818:	e8 4d d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010281d:	68 90 6f 10 f0       	push   $0xf0106f90
f0102822:	68 e7 74 10 f0       	push   $0xf01074e7
f0102827:	68 f2 03 00 00       	push   $0x3f2
f010282c:	68 cf 74 10 f0       	push   $0xf01074cf
f0102831:	e8 34 d8 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102836:	68 ef 76 10 f0       	push   $0xf01076ef
f010283b:	68 e7 74 10 f0       	push   $0xf01074e7
f0102840:	68 f3 03 00 00       	push   $0x3f3
f0102845:	68 cf 74 10 f0       	push   $0xf01074cf
f010284a:	e8 1b d8 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f010284f:	68 33 77 10 f0       	push   $0xf0107733
f0102854:	68 e7 74 10 f0       	push   $0xf01074e7
f0102859:	68 f4 03 00 00       	push   $0x3f4
f010285e:	68 cf 74 10 f0       	push   $0xf01074cf
f0102863:	e8 02 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102868:	68 c0 6f 10 f0       	push   $0xf0106fc0
f010286d:	68 e7 74 10 f0       	push   $0xf01074e7
f0102872:	68 f8 03 00 00       	push   $0x3f8
f0102877:	68 cf 74 10 f0       	push   $0xf01074cf
f010287c:	e8 e9 d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102881:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0102886:	68 e7 74 10 f0       	push   $0xf01074e7
f010288b:	68 f9 03 00 00       	push   $0x3f9
f0102890:	68 cf 74 10 f0       	push   $0xf01074cf
f0102895:	e8 d0 d7 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f010289a:	68 00 77 10 f0       	push   $0xf0107700
f010289f:	68 e7 74 10 f0       	push   $0xf01074e7
f01028a4:	68 fa 03 00 00       	push   $0x3fa
f01028a9:	68 cf 74 10 f0       	push   $0xf01074cf
f01028ae:	e8 b7 d7 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01028b3:	68 21 76 10 f0       	push   $0xf0107621
f01028b8:	68 e7 74 10 f0       	push   $0xf01074e7
f01028bd:	68 fd 03 00 00       	push   $0x3fd
f01028c2:	68 cf 74 10 f0       	push   $0xf01074cf
f01028c7:	e8 9e d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01028cc:	68 c0 6f 10 f0       	push   $0xf0106fc0
f01028d1:	68 e7 74 10 f0       	push   $0xf01074e7
f01028d6:	68 00 04 00 00       	push   $0x400
f01028db:	68 cf 74 10 f0       	push   $0xf01074cf
f01028e0:	e8 85 d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028e5:	68 fc 6f 10 f0       	push   $0xf0106ffc
f01028ea:	68 e7 74 10 f0       	push   $0xf01074e7
f01028ef:	68 01 04 00 00       	push   $0x401
f01028f4:	68 cf 74 10 f0       	push   $0xf01074cf
f01028f9:	e8 6c d7 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f01028fe:	68 00 77 10 f0       	push   $0xf0107700
f0102903:	68 e7 74 10 f0       	push   $0xf01074e7
f0102908:	68 02 04 00 00       	push   $0x402
f010290d:	68 cf 74 10 f0       	push   $0xf01074cf
f0102912:	e8 53 d7 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102917:	68 21 76 10 f0       	push   $0xf0107621
f010291c:	68 e7 74 10 f0       	push   $0xf01074e7
f0102921:	68 06 04 00 00       	push   $0x406
f0102926:	68 cf 74 10 f0       	push   $0xf01074cf
f010292b:	e8 3a d7 ff ff       	call   f010006a <_panic>
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102930:	68 2c 70 10 f0       	push   $0xf010702c
f0102935:	68 e7 74 10 f0       	push   $0xf01074e7
f010293a:	68 0a 04 00 00       	push   $0x40a
f010293f:	68 cf 74 10 f0       	push   $0xf01074cf
f0102944:	e8 21 d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f0102949:	68 70 70 10 f0       	push   $0xf0107070
f010294e:	68 e7 74 10 f0       	push   $0xf01074e7
f0102953:	68 0d 04 00 00       	push   $0x40d
f0102958:	68 cf 74 10 f0       	push   $0xf01074cf
f010295d:	e8 08 d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102962:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0102967:	68 e7 74 10 f0       	push   $0xf01074e7
f010296c:	68 0e 04 00 00       	push   $0x40e
f0102971:	68 cf 74 10 f0       	push   $0xf01074cf
f0102976:	e8 ef d6 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f010297b:	68 00 77 10 f0       	push   $0xf0107700
f0102980:	68 e7 74 10 f0       	push   $0xf01074e7
f0102985:	68 0f 04 00 00       	push   $0x40f
f010298a:	68 cf 74 10 f0       	push   $0xf01074cf
f010298f:	e8 d6 d6 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f0102994:	68 b4 70 10 f0       	push   $0xf01070b4
f0102999:	68 e7 74 10 f0       	push   $0xf01074e7
f010299e:	68 10 04 00 00       	push   $0x410
f01029a3:	68 cf 74 10 f0       	push   $0xf01074cf
f01029a8:	e8 bd d6 ff ff       	call   f010006a <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029ad:	68 55 77 10 f0       	push   $0xf0107755
f01029b2:	68 e7 74 10 f0       	push   $0xf01074e7
f01029b7:	68 11 04 00 00       	push   $0x411
f01029bc:	68 cf 74 10 f0       	push   $0xf01074cf
f01029c1:	e8 a4 d6 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01029c6:	68 c0 6f 10 f0       	push   $0xf0106fc0
f01029cb:	68 e7 74 10 f0       	push   $0xf01074e7
f01029d0:	68 14 04 00 00       	push   $0x414
f01029d5:	68 cf 74 10 f0       	push   $0xf01074cf
f01029da:	e8 8b d6 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f01029df:	68 e8 70 10 f0       	push   $0xf01070e8
f01029e4:	68 e7 74 10 f0       	push   $0xf01074e7
f01029e9:	68 15 04 00 00       	push   $0x415
f01029ee:	68 cf 74 10 f0       	push   $0xf01074cf
f01029f3:	e8 72 d6 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f01029f8:	68 1c 71 10 f0       	push   $0xf010711c
f01029fd:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a02:	68 16 04 00 00       	push   $0x416
f0102a07:	68 cf 74 10 f0       	push   $0xf01074cf
f0102a0c:	e8 59 d6 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f0102a11:	68 54 71 10 f0       	push   $0xf0107154
f0102a16:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a1b:	68 1a 04 00 00       	push   $0x41a
f0102a20:	68 cf 74 10 f0       	push   $0xf01074cf
f0102a25:	e8 40 d6 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f0102a2a:	68 90 71 10 f0       	push   $0xf0107190
f0102a2f:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a34:	68 1d 04 00 00       	push   $0x41d
f0102a39:	68 cf 74 10 f0       	push   $0xf01074cf
f0102a3e:	e8 27 d6 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102a43:	68 1c 71 10 f0       	push   $0xf010711c
f0102a48:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a4d:	68 1e 04 00 00       	push   $0x41e
f0102a52:	68 cf 74 10 f0       	push   $0xf01074cf
f0102a57:	e8 0e d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a5c:	68 cc 71 10 f0       	push   $0xf01071cc
f0102a61:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a66:	68 21 04 00 00       	push   $0x421
f0102a6b:	68 cf 74 10 f0       	push   $0xf01074cf
f0102a70:	e8 f5 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a75:	68 f8 71 10 f0       	push   $0xf01071f8
f0102a7a:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a7f:	68 22 04 00 00       	push   $0x422
f0102a84:	68 cf 74 10 f0       	push   $0xf01074cf
f0102a89:	e8 dc d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 2);
f0102a8e:	68 6b 77 10 f0       	push   $0xf010776b
f0102a93:	68 e7 74 10 f0       	push   $0xf01074e7
f0102a98:	68 24 04 00 00       	push   $0x424
f0102a9d:	68 cf 74 10 f0       	push   $0xf01074cf
f0102aa2:	e8 c3 d5 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102aa7:	68 22 77 10 f0       	push   $0xf0107722
f0102aac:	68 e7 74 10 f0       	push   $0xf01074e7
f0102ab1:	68 25 04 00 00       	push   $0x425
f0102ab6:	68 cf 74 10 f0       	push   $0xf01074cf
f0102abb:	e8 aa d5 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102ac0:	68 28 72 10 f0       	push   $0xf0107228
f0102ac5:	68 e7 74 10 f0       	push   $0xf01074e7
f0102aca:	68 28 04 00 00       	push   $0x428
f0102acf:	68 cf 74 10 f0       	push   $0xf01074cf
f0102ad4:	e8 91 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ad9:	68 4c 72 10 f0       	push   $0xf010724c
f0102ade:	68 e7 74 10 f0       	push   $0xf01074e7
f0102ae3:	68 2c 04 00 00       	push   $0x42c
f0102ae8:	68 cf 74 10 f0       	push   $0xf01074cf
f0102aed:	e8 78 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102af2:	68 f8 71 10 f0       	push   $0xf01071f8
f0102af7:	68 e7 74 10 f0       	push   $0xf01074e7
f0102afc:	68 2d 04 00 00       	push   $0x42d
f0102b01:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b06:	e8 5f d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102b0b:	68 ef 76 10 f0       	push   $0xf01076ef
f0102b10:	68 e7 74 10 f0       	push   $0xf01074e7
f0102b15:	68 2e 04 00 00       	push   $0x42e
f0102b1a:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b1f:	e8 46 d5 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102b24:	68 22 77 10 f0       	push   $0xf0107722
f0102b29:	68 e7 74 10 f0       	push   $0xf01074e7
f0102b2e:	68 2f 04 00 00       	push   $0x42f
f0102b33:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b38:	e8 2d d5 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f0102b3d:	68 70 72 10 f0       	push   $0xf0107270
f0102b42:	68 e7 74 10 f0       	push   $0xf01074e7
f0102b47:	68 32 04 00 00       	push   $0x432
f0102b4c:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b51:	e8 14 d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref);
f0102b56:	68 7c 77 10 f0       	push   $0xf010777c
f0102b5b:	68 e7 74 10 f0       	push   $0xf01074e7
f0102b60:	68 33 04 00 00       	push   $0x433
f0102b65:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b6a:	e8 fb d4 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_link == NULL);
f0102b6f:	68 88 77 10 f0       	push   $0xf0107788
f0102b74:	68 e7 74 10 f0       	push   $0xf01074e7
f0102b79:	68 34 04 00 00       	push   $0x434
f0102b7e:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b83:	e8 e2 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b88:	68 4c 72 10 f0       	push   $0xf010724c
f0102b8d:	68 e7 74 10 f0       	push   $0xf01074e7
f0102b92:	68 38 04 00 00       	push   $0x438
f0102b97:	68 cf 74 10 f0       	push   $0xf01074cf
f0102b9c:	e8 c9 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102ba1:	68 a8 72 10 f0       	push   $0xf01072a8
f0102ba6:	68 e7 74 10 f0       	push   $0xf01074e7
f0102bab:	68 39 04 00 00       	push   $0x439
f0102bb0:	68 cf 74 10 f0       	push   $0xf01074cf
f0102bb5:	e8 b0 d4 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0102bba:	68 11 77 10 f0       	push   $0xf0107711
f0102bbf:	68 e7 74 10 f0       	push   $0xf01074e7
f0102bc4:	68 3a 04 00 00       	push   $0x43a
f0102bc9:	68 cf 74 10 f0       	push   $0xf01074cf
f0102bce:	e8 97 d4 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102bd3:	68 22 77 10 f0       	push   $0xf0107722
f0102bd8:	68 e7 74 10 f0       	push   $0xf01074e7
f0102bdd:	68 3b 04 00 00       	push   $0x43b
f0102be2:	68 cf 74 10 f0       	push   $0xf01074cf
f0102be7:	e8 7e d4 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102bec:	68 d0 72 10 f0       	push   $0xf01072d0
f0102bf1:	68 e7 74 10 f0       	push   $0xf01074e7
f0102bf6:	68 3e 04 00 00       	push   $0x43e
f0102bfb:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c00:	e8 65 d4 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102c05:	68 21 76 10 f0       	push   $0xf0107621
f0102c0a:	68 e7 74 10 f0       	push   $0xf01074e7
f0102c0f:	68 41 04 00 00       	push   $0x441
f0102c14:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c19:	e8 4c d4 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c1e:	68 a4 6e 10 f0       	push   $0xf0106ea4
f0102c23:	68 e7 74 10 f0       	push   $0xf01074e7
f0102c28:	68 44 04 00 00       	push   $0x444
f0102c2d:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c32:	e8 33 d4 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0102c37:	68 33 77 10 f0       	push   $0xf0107733
f0102c3c:	68 e7 74 10 f0       	push   $0xf01074e7
f0102c41:	68 46 04 00 00       	push   $0x446
f0102c46:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c4b:	e8 1a d4 ff ff       	call   f010006a <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c50:	68 9d 77 10 f0       	push   $0xf010779d
f0102c55:	68 e7 74 10 f0       	push   $0xf01074e7
f0102c5a:	68 4e 04 00 00       	push   $0x44e
f0102c5f:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c64:	e8 01 d4 ff ff       	call   f010006a <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102c69:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c6e:	68 e7 74 10 f0       	push   $0xf01074e7
f0102c73:	68 58 04 00 00       	push   $0x458
f0102c78:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c7d:	e8 e8 d3 ff ff       	call   f010006a <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102c82:	68 f4 72 10 f0       	push   $0xf01072f4
f0102c87:	68 e7 74 10 f0       	push   $0xf01074e7
f0102c8c:	68 68 04 00 00       	push   $0x468
f0102c91:	68 cf 74 10 f0       	push   $0xf01074cf
f0102c96:	e8 cf d3 ff ff       	call   f010006a <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102c9b:	68 1c 73 10 f0       	push   $0xf010731c
f0102ca0:	68 e7 74 10 f0       	push   $0xf01074e7
f0102ca5:	68 69 04 00 00       	push   $0x469
f0102caa:	68 cf 74 10 f0       	push   $0xf01074cf
f0102caf:	e8 b6 d3 ff ff       	call   f010006a <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102cb4:	68 44 73 10 f0       	push   $0xf0107344
f0102cb9:	68 e7 74 10 f0       	push   $0xf01074e7
f0102cbe:	68 6b 04 00 00       	push   $0x46b
f0102cc3:	68 cf 74 10 f0       	push   $0xf01074cf
f0102cc8:	e8 9d d3 ff ff       	call   f010006a <_panic>
	assert(mm1 + 8096 <= mm2);
f0102ccd:	68 cc 77 10 f0       	push   $0xf01077cc
f0102cd2:	68 e7 74 10 f0       	push   $0xf01074e7
f0102cd7:	68 6d 04 00 00       	push   $0x46d
f0102cdc:	68 cf 74 10 f0       	push   $0xf01074cf
f0102ce1:	e8 84 d3 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102ce6:	68 6c 73 10 f0       	push   $0xf010736c
f0102ceb:	68 e7 74 10 f0       	push   $0xf01074e7
f0102cf0:	68 6f 04 00 00       	push   $0x46f
f0102cf5:	68 cf 74 10 f0       	push   $0xf01074cf
f0102cfa:	e8 6b d3 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102cff:	68 90 73 10 f0       	push   $0xf0107390
f0102d04:	68 e7 74 10 f0       	push   $0xf01074e7
f0102d09:	68 70 04 00 00       	push   $0x470
f0102d0e:	68 cf 74 10 f0       	push   $0xf01074cf
f0102d13:	e8 52 d3 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d18:	68 c0 73 10 f0       	push   $0xf01073c0
f0102d1d:	68 e7 74 10 f0       	push   $0xf01074e7
f0102d22:	68 71 04 00 00       	push   $0x471
f0102d27:	68 cf 74 10 f0       	push   $0xf01074cf
f0102d2c:	e8 39 d3 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102d31:	68 e4 73 10 f0       	push   $0xf01073e4
f0102d36:	68 e7 74 10 f0       	push   $0xf01074e7
f0102d3b:	68 72 04 00 00       	push   $0x472
f0102d40:	68 cf 74 10 f0       	push   $0xf01074cf
f0102d45:	e8 20 d3 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f0102d4a:	68 10 74 10 f0       	push   $0xf0107410
f0102d4f:	68 e7 74 10 f0       	push   $0xf01074e7
f0102d54:	68 74 04 00 00       	push   $0x474
f0102d59:	68 cf 74 10 f0       	push   $0xf01074cf
f0102d5e:	e8 07 d3 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f0102d63:	68 58 74 10 f0       	push   $0xf0107458
f0102d68:	68 e7 74 10 f0       	push   $0xf01074e7
f0102d6d:	68 76 04 00 00       	push   $0x476
f0102d72:	68 cf 74 10 f0       	push   $0xf01074cf
f0102d77:	e8 ee d2 ff ff       	call   f010006a <_panic>

f0102d7c <mem_init>:
{
f0102d7c:	f3 0f 1e fb          	endbr32 
f0102d80:	55                   	push   %ebp
f0102d81:	89 e5                	mov    %esp,%ebp
f0102d83:	53                   	push   %ebx
f0102d84:	83 ec 04             	sub    $0x4,%esp
	i386_detect_memory();
f0102d87:	e8 0a df ff ff       	call   f0100c96 <i386_detect_memory>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102d8c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102d91:	e8 38 e0 ff ff       	call   f0100dce <boot_alloc>
f0102d96:	a3 8c 2e 22 f0       	mov    %eax,0xf0222e8c
	memset(kern_pgdir, 0, PGSIZE);
f0102d9b:	83 ec 04             	sub    $0x4,%esp
f0102d9e:	68 00 10 00 00       	push   $0x1000
f0102da3:	6a 00                	push   $0x0
f0102da5:	50                   	push   %eax
f0102da6:	e8 68 2a 00 00       	call   f0105813 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102dab:	8b 1d 8c 2e 22 f0    	mov    0xf0222e8c,%ebx
f0102db1:	89 d9                	mov    %ebx,%ecx
f0102db3:	ba 9e 00 00 00       	mov    $0x9e,%edx
f0102db8:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0102dbd:	e8 ea df ff ff       	call   f0100dac <_paddr>
f0102dc2:	83 c8 05             	or     $0x5,%eax
f0102dc5:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	uint32_t pages_mem = sizeof(struct PageInfo) * npages;
f0102dcb:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0102dd0:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = boot_alloc(pages_mem);
f0102dd7:	89 d8                	mov    %ebx,%eax
f0102dd9:	e8 f0 df ff ff       	call   f0100dce <boot_alloc>
f0102dde:	a3 90 2e 22 f0       	mov    %eax,0xf0222e90
	memset(pages, 0, pages_mem);
f0102de3:	83 c4 0c             	add    $0xc,%esp
f0102de6:	53                   	push   %ebx
f0102de7:	6a 00                	push   $0x0
f0102de9:	50                   	push   %eax
f0102dea:	e8 24 2a 00 00       	call   f0105813 <memset>
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0102def:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0102df4:	e8 d5 df ff ff       	call   f0100dce <boot_alloc>
f0102df9:	a3 44 12 22 f0       	mov    %eax,0xf0221244
	memset(envs, 0, NENV * sizeof(struct Env));
f0102dfe:	83 c4 0c             	add    $0xc,%esp
f0102e01:	68 00 f0 01 00       	push   $0x1f000
f0102e06:	6a 00                	push   $0x0
f0102e08:	50                   	push   %eax
f0102e09:	e8 05 2a 00 00       	call   f0105813 <memset>
	page_init();
f0102e0e:	e8 10 e3 ff ff       	call   f0101123 <page_init>
	check_page_free_list(1);
f0102e13:	b8 01 00 00 00       	mov    $0x1,%eax
f0102e18:	e8 27 e0 ff ff       	call   f0100e44 <check_page_free_list>
	check_page_alloc();
f0102e1d:	e8 55 e4 ff ff       	call   f0101277 <check_page_alloc>
	check_page();
f0102e22:	e8 6d f1 ff ff       	call   f0101f94 <check_page>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), (PTE_U | PTE_P));
f0102e27:	8b 0d 90 2e 22 f0    	mov    0xf0222e90,%ecx
f0102e2d:	ba c8 00 00 00       	mov    $0xc8,%edx
f0102e32:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0102e37:	e8 70 df ff ff       	call   f0100dac <_paddr>
f0102e3c:	83 c4 08             	add    $0x8,%esp
f0102e3f:	6a 05                	push   $0x5
f0102e41:	50                   	push   %eax
f0102e42:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102e47:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102e4c:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102e51:	e8 dd e8 ff ff       	call   f0101733 <boot_map_region>
	boot_map_region(
f0102e56:	8b 0d 44 12 22 f0    	mov    0xf0221244,%ecx
f0102e5c:	ba d1 00 00 00       	mov    $0xd1,%edx
f0102e61:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0102e66:	e8 41 df ff ff       	call   f0100dac <_paddr>
f0102e6b:	83 c4 08             	add    $0x8,%esp
f0102e6e:	6a 04                	push   $0x4
f0102e70:	50                   	push   %eax
f0102e71:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102e76:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e7b:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102e80:	e8 ae e8 ff ff       	call   f0101733 <boot_map_region>
	boot_map_region(kern_pgdir,
f0102e85:	b9 00 90 11 f0       	mov    $0xf0119000,%ecx
f0102e8a:	ba e0 00 00 00       	mov    $0xe0,%edx
f0102e8f:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0102e94:	e8 13 df ff ff       	call   f0100dac <_paddr>
f0102e99:	83 c4 08             	add    $0x8,%esp
f0102e9c:	6a 02                	push   $0x2
f0102e9e:	50                   	push   %eax
f0102e9f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102ea4:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102ea9:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102eae:	e8 80 e8 ff ff       	call   f0101733 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102eb3:	83 c4 08             	add    $0x8,%esp
f0102eb6:	6a 02                	push   $0x2
f0102eb8:	6a 00                	push   $0x0
f0102eba:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102ebf:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102ec4:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102ec9:	e8 65 e8 ff ff       	call   f0101733 <boot_map_region>
	mem_init_mp();
f0102ece:	e8 37 e9 ff ff       	call   f010180a <mem_init_mp>
	check_kern_pgdir();
f0102ed3:	e8 8d e9 ff ff       	call   f0101865 <check_kern_pgdir>
	lcr3(PADDR(kern_pgdir));
f0102ed8:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0102ede:	ba fb 00 00 00       	mov    $0xfb,%edx
f0102ee3:	b8 cf 74 10 f0       	mov    $0xf01074cf,%eax
f0102ee8:	e8 bf de ff ff       	call   f0100dac <_paddr>
f0102eed:	e8 6a dd ff ff       	call   f0100c5c <lcr3>
	check_page_free_list(0);
f0102ef2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ef7:	e8 48 df ff ff       	call   f0100e44 <check_page_free_list>
	cr0 = rcr0();
f0102efc:	e8 57 dd ff ff       	call   f0100c58 <rcr0>
f0102f01:	83 e0 f3             	and    $0xfffffff3,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102f04:	0d 23 00 05 80       	or     $0x80050023,%eax
	lcr0(cr0);
f0102f09:	e8 46 dd ff ff       	call   f0100c54 <lcr0>
	check_page_installed_pgdir();
f0102f0e:	e8 6f ed ff ff       	call   f0101c82 <check_page_installed_pgdir>
}
f0102f13:	83 c4 10             	add    $0x10,%esp
f0102f16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f19:	c9                   	leave  
f0102f1a:	c3                   	ret    

f0102f1b <user_mem_check>:
{
f0102f1b:	f3 0f 1e fb          	endbr32 
f0102f1f:	55                   	push   %ebp
f0102f20:	89 e5                	mov    %esp,%ebp
f0102f22:	57                   	push   %edi
f0102f23:	56                   	push   %esi
f0102f24:	53                   	push   %ebx
f0102f25:	83 ec 0c             	sub    $0xc,%esp
f0102f28:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102f2b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	pde_t *pgdir = env->env_pgdir;
f0102f2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f31:	8b 78 60             	mov    0x60(%eax),%edi
	user_mem_check_addr = (uintptr_t) va;
f0102f34:	89 35 3c 12 22 f0    	mov    %esi,0xf022123c
	while (user_mem_check_addr < (uintptr_t)(va + len)) {
f0102f3a:	03 75 10             	add    0x10(%ebp),%esi
f0102f3d:	eb 08                	jmp    f0102f47 <user_mem_check+0x2c>
		user_mem_check_addr++;
f0102f3f:	83 c0 01             	add    $0x1,%eax
f0102f42:	a3 3c 12 22 f0       	mov    %eax,0xf022123c
	while (user_mem_check_addr < (uintptr_t)(va + len)) {
f0102f47:	a1 3c 12 22 f0       	mov    0xf022123c,%eax
f0102f4c:	39 c6                	cmp    %eax,%esi
f0102f4e:	76 2e                	jbe    f0102f7e <user_mem_check+0x63>
		pte_t *pte = pgdir_walk(pgdir, (void *) user_mem_check_addr, 0);
f0102f50:	83 ec 04             	sub    $0x4,%esp
f0102f53:	6a 00                	push   $0x0
f0102f55:	50                   	push   %eax
f0102f56:	57                   	push   %edi
f0102f57:	e8 67 e7 ff ff       	call   f01016c3 <pgdir_walk>
		if (!pte || (*pte & perm) != perm || user_mem_check_addr >= ULIM)
f0102f5c:	83 c4 10             	add    $0x10,%esp
f0102f5f:	85 c0                	test   %eax,%eax
f0102f61:	74 28                	je     f0102f8b <user_mem_check+0x70>
f0102f63:	89 da                	mov    %ebx,%edx
f0102f65:	23 10                	and    (%eax),%edx
f0102f67:	39 d3                	cmp    %edx,%ebx
f0102f69:	75 27                	jne    f0102f92 <user_mem_check+0x77>
f0102f6b:	a1 3c 12 22 f0       	mov    0xf022123c,%eax
f0102f70:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0102f75:	76 c8                	jbe    f0102f3f <user_mem_check+0x24>
			return -E_FAULT;
f0102f77:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f7c:	eb 05                	jmp    f0102f83 <user_mem_check+0x68>
	return 0;
f0102f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f83:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f86:	5b                   	pop    %ebx
f0102f87:	5e                   	pop    %esi
f0102f88:	5f                   	pop    %edi
f0102f89:	5d                   	pop    %ebp
f0102f8a:	c3                   	ret    
			return -E_FAULT;
f0102f8b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f90:	eb f1                	jmp    f0102f83 <user_mem_check+0x68>
f0102f92:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f97:	eb ea                	jmp    f0102f83 <user_mem_check+0x68>

f0102f99 <user_mem_assert>:
{
f0102f99:	f3 0f 1e fb          	endbr32 
f0102f9d:	55                   	push   %ebp
f0102f9e:	89 e5                	mov    %esp,%ebp
f0102fa0:	53                   	push   %ebx
f0102fa1:	83 ec 04             	sub    $0x4,%esp
f0102fa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fa7:	8b 45 14             	mov    0x14(%ebp),%eax
f0102faa:	83 c8 04             	or     $0x4,%eax
f0102fad:	50                   	push   %eax
f0102fae:	ff 75 10             	pushl  0x10(%ebp)
f0102fb1:	ff 75 0c             	pushl  0xc(%ebp)
f0102fb4:	53                   	push   %ebx
f0102fb5:	e8 61 ff ff ff       	call   f0102f1b <user_mem_check>
f0102fba:	83 c4 10             	add    $0x10,%esp
f0102fbd:	85 c0                	test   %eax,%eax
f0102fbf:	78 05                	js     f0102fc6 <user_mem_assert+0x2d>
}
f0102fc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fc4:	c9                   	leave  
f0102fc5:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fc6:	83 ec 04             	sub    $0x4,%esp
f0102fc9:	ff 35 3c 12 22 f0    	pushl  0xf022123c
f0102fcf:	ff 73 48             	pushl  0x48(%ebx)
f0102fd2:	68 8c 74 10 f0       	push   $0xf010748c
f0102fd7:	e8 2f 0a 00 00       	call   f0103a0b <cprintf>
		env_destroy(env);  // may not return
f0102fdc:	89 1c 24             	mov    %ebx,(%esp)
f0102fdf:	e8 81 06 00 00       	call   f0103665 <env_destroy>
f0102fe4:	83 c4 10             	add    $0x10,%esp
}
f0102fe7:	eb d8                	jmp    f0102fc1 <user_mem_assert+0x28>

f0102fe9 <lgdt>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0102fe9:	0f 01 10             	lgdtl  (%eax)
}
f0102fec:	c3                   	ret    

f0102fed <lldt>:
	asm volatile("lldt %0" : : "r" (sel));
f0102fed:	0f 00 d0             	lldt   %ax
}
f0102ff0:	c3                   	ret    

f0102ff1 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ff1:	0f 22 d8             	mov    %eax,%cr3
}
f0102ff4:	c3                   	ret    

f0102ff5 <page2pa>:
	return (pp - pages) << PGSHIFT;
f0102ff5:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0102ffb:	c1 f8 03             	sar    $0x3,%eax
f0102ffe:	c1 e0 0c             	shl    $0xc,%eax
}
f0103001:	c3                   	ret    

f0103002 <_kaddr>:
{
f0103002:	55                   	push   %ebp
f0103003:	89 e5                	mov    %esp,%ebp
f0103005:	53                   	push   %ebx
f0103006:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0103009:	89 cb                	mov    %ecx,%ebx
f010300b:	c1 eb 0c             	shr    $0xc,%ebx
f010300e:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0103014:	73 0b                	jae    f0103021 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0103016:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f010301c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010301f:	c9                   	leave  
f0103020:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103021:	51                   	push   %ecx
f0103022:	68 8c 65 10 f0       	push   $0xf010658c
f0103027:	52                   	push   %edx
f0103028:	50                   	push   %eax
f0103029:	e8 3c d0 ff ff       	call   f010006a <_panic>

f010302e <page2kva>:
{
f010302e:	55                   	push   %ebp
f010302f:	89 e5                	mov    %esp,%ebp
f0103031:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0103034:	e8 bc ff ff ff       	call   f0102ff5 <page2pa>
f0103039:	89 c1                	mov    %eax,%ecx
f010303b:	ba 58 00 00 00       	mov    $0x58,%edx
f0103040:	b8 c1 74 10 f0       	mov    $0xf01074c1,%eax
f0103045:	e8 b8 ff ff ff       	call   f0103002 <_kaddr>
}
f010304a:	c9                   	leave  
f010304b:	c3                   	ret    

f010304c <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f010304c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0103052:	76 07                	jbe    f010305b <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0103054:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f010305a:	c3                   	ret    
{
f010305b:	55                   	push   %ebp
f010305c:	89 e5                	mov    %esp,%ebp
f010305e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103061:	51                   	push   %ecx
f0103062:	68 b0 65 10 f0       	push   $0xf01065b0
f0103067:	52                   	push   %edx
f0103068:	50                   	push   %eax
f0103069:	e8 fc cf ff ff       	call   f010006a <_panic>

f010306e <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f010306e:	55                   	push   %ebp
f010306f:	89 e5                	mov    %esp,%ebp
f0103071:	56                   	push   %esi
f0103072:	53                   	push   %ebx
f0103073:	89 c6                	mov    %eax,%esi
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103075:	83 ec 0c             	sub    $0xc,%esp
f0103078:	6a 01                	push   $0x1
f010307a:	e8 54 e1 ff ff       	call   f01011d3 <page_alloc>
f010307f:	83 c4 10             	add    $0x10,%esp
f0103082:	85 c0                	test   %eax,%eax
f0103084:	74 4f                	je     f01030d5 <env_setup_vm+0x67>
f0103086:	89 c3                	mov    %eax,%ebx
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	// Inicializar la direccion de memoria virtual del kernel (page2kva?)
	e->env_pgdir = page2kva(p);
f0103088:	e8 a1 ff ff ff       	call   f010302e <page2kva>
f010308d:	89 46 60             	mov    %eax,0x60(%esi)
	// El usuario puede usar hasta UTOP (tamaño PGSIZE), y como dice que
	// puedo usar kern_pgdir como template , copia PGSIZE bytes de
	// kern_pgdir a env_pgdir
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103090:	83 ec 04             	sub    $0x4,%esp
f0103093:	68 00 10 00 00       	push   $0x1000
f0103098:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f010309e:	50                   	push   %eax
f010309f:	e8 23 28 00 00       	call   f01058c7 <memcpy>
	// Pide incrementar pp_ref
	p->pp_ref++;
f01030a4:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030a9:	8b 5e 60             	mov    0x60(%esi),%ebx
f01030ac:	89 d9                	mov    %ebx,%ecx
f01030ae:	ba c7 00 00 00       	mov    $0xc7,%edx
f01030b3:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f01030b8:	e8 8f ff ff ff       	call   f010304c <_paddr>
f01030bd:	83 c8 05             	or     $0x5,%eax
f01030c0:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)

	return 0;
f01030c6:	83 c4 10             	add    $0x10,%esp
f01030c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030d1:	5b                   	pop    %ebx
f01030d2:	5e                   	pop    %esi
f01030d3:	5d                   	pop    %ebp
f01030d4:	c3                   	ret    
		return -E_NO_MEM;
f01030d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01030da:	eb f2                	jmp    f01030ce <env_setup_vm+0x60>

f01030dc <pa2page>:
	if (PGNUM(pa) >= npages)
f01030dc:	c1 e8 0c             	shr    $0xc,%eax
f01030df:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f01030e5:	73 0a                	jae    f01030f1 <pa2page+0x15>
	return &pages[PGNUM(pa)];
f01030e7:	8b 15 90 2e 22 f0    	mov    0xf0222e90,%edx
f01030ed:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01030f0:	c3                   	ret    
{
f01030f1:	55                   	push   %ebp
f01030f2:	89 e5                	mov    %esp,%ebp
f01030f4:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f01030f7:	68 34 6c 10 f0       	push   $0xf0106c34
f01030fc:	6a 51                	push   $0x51
f01030fe:	68 c1 74 10 f0       	push   $0xf01074c1
f0103103:	e8 62 cf ff ff       	call   f010006a <_panic>

f0103108 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103108:	55                   	push   %ebp
f0103109:	89 e5                	mov    %esp,%ebp
f010310b:	57                   	push   %edi
f010310c:	56                   	push   %esi
f010310d:	53                   	push   %ebx
f010310e:	83 ec 0c             	sub    $0xc,%esp
f0103111:	89 c7                	mov    %eax,%edi
f0103113:	89 d3                	mov    %edx,%ebx
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uint32_t max_mem = ROUNDUP((uint32_t)(va + len), PGSIZE);
f0103115:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010311c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uint32_t min_mem = ROUNDDOWN((uint32_t) va, PGSIZE);
f0103122:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t page_count = (max_mem - min_mem) / PGSIZE;

	struct PageInfo *p;
	for (size_t i = 0; i < page_count; i++) {
f0103128:	39 de                	cmp    %ebx,%esi
f010312a:	74 58                	je     f0103184 <region_alloc+0x7c>
		p = page_alloc(0);
f010312c:	83 ec 0c             	sub    $0xc,%esp
f010312f:	6a 00                	push   $0x0
f0103131:	e8 9d e0 ff ff       	call   f01011d3 <page_alloc>
		if (!p)
f0103136:	83 c4 10             	add    $0x10,%esp
f0103139:	85 c0                	test   %eax,%eax
f010313b:	74 30                	je     f010316d <region_alloc+0x65>
			panic("Fallo la asignacion");

		if (page_insert(e->env_pgdir,
f010313d:	6a 06                	push   $0x6
f010313f:	53                   	push   %ebx
f0103140:	50                   	push   %eax
f0103141:	ff 77 60             	pushl  0x60(%edi)
f0103144:	e8 db ea ff ff       	call   f0101c24 <page_insert>
f0103149:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010314f:	83 c4 10             	add    $0x10,%esp
f0103152:	85 c0                	test   %eax,%eax
f0103154:	74 d2                	je     f0103128 <region_alloc+0x20>
		                p,
		                (void *) (min_mem + i * PGSIZE),
		                PTE_W | PTE_U) != 0)
			panic("Fallo el mapeo");
f0103156:	83 ec 04             	sub    $0x4,%esp
f0103159:	68 16 78 10 f0       	push   $0xf0107816
f010315e:	68 34 01 00 00       	push   $0x134
f0103163:	68 f7 77 10 f0       	push   $0xf01077f7
f0103168:	e8 fd ce ff ff       	call   f010006a <_panic>
			panic("Fallo la asignacion");
f010316d:	83 ec 04             	sub    $0x4,%esp
f0103170:	68 02 78 10 f0       	push   $0xf0107802
f0103175:	68 2e 01 00 00       	push   $0x12e
f010317a:	68 f7 77 10 f0       	push   $0xf01077f7
f010317f:	e8 e6 ce ff ff       	call   f010006a <_panic>
	}
}
f0103184:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103187:	5b                   	pop    %ebx
f0103188:	5e                   	pop    %esi
f0103189:	5f                   	pop    %edi
f010318a:	5d                   	pop    %ebp
f010318b:	c3                   	ret    

f010318c <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
f010318c:	55                   	push   %ebp
f010318d:	89 e5                	mov    %esp,%ebp
f010318f:	57                   	push   %edi
f0103190:	56                   	push   %esi
f0103191:	53                   	push   %ebx
f0103192:	83 ec 1c             	sub    $0x1c,%esp
f0103195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	assert(elf->e_magic == ELF_MAGIC);
f0103198:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f010319e:	75 2c                	jne    f01031cc <load_icode+0x40>
f01031a0:	89 d7                	mov    %edx,%edi
	struct Proghdr *ph_start = (struct Proghdr *) (elf->e_phoff + binary);
f01031a2:	89 d3                	mov    %edx,%ebx
f01031a4:	03 5a 1c             	add    0x1c(%edx),%ebx
	struct Proghdr *ph_end = ph_start + elf->e_phnum;
f01031a7:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi
f01031ab:	c1 e6 05             	shl    $0x5,%esi
f01031ae:	01 de                	add    %ebx,%esi

	// switch al env_pgdir
	// Este switch debe modificar CR3 (usar lcr3, ya que rcr3 no modifica, solo lee)
	lcr3(PADDR(e->env_pgdir));
f01031b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031b3:	8b 48 60             	mov    0x60(%eax),%ecx
f01031b6:	ba 75 01 00 00       	mov    $0x175,%edx
f01031bb:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f01031c0:	e8 87 fe ff ff       	call   f010304c <_paddr>
f01031c5:	e8 27 fe ff ff       	call   f0102ff1 <lcr3>

	while (ph_start < ph_end) {
f01031ca:	eb 58                	jmp    f0103224 <load_icode+0x98>
	assert(elf->e_magic == ELF_MAGIC);
f01031cc:	68 25 78 10 f0       	push   $0xf0107825
f01031d1:	68 e7 74 10 f0       	push   $0xf01074e7
f01031d6:	68 6f 01 00 00       	push   $0x16f
f01031db:	68 f7 77 10 f0       	push   $0xf01077f7
f01031e0:	e8 85 ce ff ff       	call   f010006a <_panic>
		if (ph_start->p_type == ELF_PROG_LOAD) {
			region_alloc(e,
f01031e5:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01031e8:	8b 53 08             	mov    0x8(%ebx),%edx
f01031eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031ee:	e8 15 ff ff ff       	call   f0103108 <region_alloc>
			             (void *) (ph_start->p_va),
			             ph_start->p_memsz);
			memcpy((void *) (ph_start->p_va),
f01031f3:	83 ec 04             	sub    $0x4,%esp
f01031f6:	ff 73 10             	pushl  0x10(%ebx)
			       ph_start->p_offset + binary,
f01031f9:	89 f8                	mov    %edi,%eax
f01031fb:	03 43 04             	add    0x4(%ebx),%eax
			memcpy((void *) (ph_start->p_va),
f01031fe:	50                   	push   %eax
f01031ff:	ff 73 08             	pushl  0x8(%ebx)
f0103202:	e8 c0 26 00 00       	call   f01058c7 <memcpy>
			       ph_start->p_filesz);
			memset((void *) (ph_start->p_va + ph_start->p_filesz),
			       0,
			       ph_start->p_memsz - ph_start->p_filesz);
f0103207:	8b 43 10             	mov    0x10(%ebx),%eax
			memset((void *) (ph_start->p_va + ph_start->p_filesz),
f010320a:	83 c4 0c             	add    $0xc,%esp
f010320d:	8b 53 14             	mov    0x14(%ebx),%edx
f0103210:	29 c2                	sub    %eax,%edx
f0103212:	52                   	push   %edx
f0103213:	6a 00                	push   $0x0
f0103215:	03 43 08             	add    0x8(%ebx),%eax
f0103218:	50                   	push   %eax
f0103219:	e8 f5 25 00 00       	call   f0105813 <memset>
f010321e:	83 c4 10             	add    $0x10,%esp
		}

		ph_start++;
f0103221:	83 c3 20             	add    $0x20,%ebx
	while (ph_start < ph_end) {
f0103224:	39 f3                	cmp    %esi,%ebx
f0103226:	73 07                	jae    f010322f <load_icode+0xa3>
		if (ph_start->p_type == ELF_PROG_LOAD) {
f0103228:	83 3b 01             	cmpl   $0x1,(%ebx)
f010322b:	75 f4                	jne    f0103221 <load_icode+0x95>
f010322d:	eb b6                	jmp    f01031e5 <load_icode+0x59>
	}

	// volver al kern_pgdir para estar en lugar protegido
	// Este switch debe modificar CR3 (usar lcr3, ya que rcr3 no modifica, solo lee)
	lcr3(PADDR(kern_pgdir));
f010322f:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0103235:	ba 89 01 00 00       	mov    $0x189,%edx
f010323a:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f010323f:	e8 08 fe ff ff       	call   f010304c <_paddr>
f0103244:	e8 a8 fd ff ff       	call   f0102ff1 <lcr3>

	// Seteo Entry Point
	e->env_tf.tf_eip = elf->e_entry;
f0103249:	8b 47 18             	mov    0x18(%edi),%eax
f010324c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010324f:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103252:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103257:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010325c:	89 f8                	mov    %edi,%eax
f010325e:	e8 a5 fe ff ff       	call   f0103108 <region_alloc>
}
f0103263:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103266:	5b                   	pop    %ebx
f0103267:	5e                   	pop    %esi
f0103268:	5f                   	pop    %edi
f0103269:	5d                   	pop    %ebp
f010326a:	c3                   	ret    

f010326b <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010326b:	55                   	push   %ebp
f010326c:	89 e5                	mov    %esp,%ebp
f010326e:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f0103271:	68 c0 23 12 f0       	push   $0xf01223c0
f0103276:	e8 94 2f 00 00       	call   f010620f <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010327b:	f3 90                	pause  
}
f010327d:	83 c4 10             	add    $0x10,%esp
f0103280:	c9                   	leave  
f0103281:	c3                   	ret    

f0103282 <envid2env>:
{
f0103282:	f3 0f 1e fb          	endbr32 
f0103286:	55                   	push   %ebp
f0103287:	89 e5                	mov    %esp,%ebp
f0103289:	56                   	push   %esi
f010328a:	53                   	push   %ebx
f010328b:	8b 75 08             	mov    0x8(%ebp),%esi
f010328e:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0103291:	85 f6                	test   %esi,%esi
f0103293:	74 2e                	je     f01032c3 <envid2env+0x41>
	e = &envs[ENVX(envid)];
f0103295:	89 f3                	mov    %esi,%ebx
f0103297:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010329d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01032a0:	03 1d 44 12 22 f0    	add    0xf0221244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01032a6:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01032aa:	74 2e                	je     f01032da <envid2env+0x58>
f01032ac:	39 73 48             	cmp    %esi,0x48(%ebx)
f01032af:	75 29                	jne    f01032da <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01032b1:	84 c0                	test   %al,%al
f01032b3:	75 35                	jne    f01032ea <envid2env+0x68>
	*env_store = e;
f01032b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032b8:	89 18                	mov    %ebx,(%eax)
	return 0;
f01032ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032bf:	5b                   	pop    %ebx
f01032c0:	5e                   	pop    %esi
f01032c1:	5d                   	pop    %ebp
f01032c2:	c3                   	ret    
		*env_store = curenv;
f01032c3:	e8 dc 2b 00 00       	call   f0105ea4 <cpunum>
f01032c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01032cb:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01032d1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032d4:	89 02                	mov    %eax,(%edx)
		return 0;
f01032d6:	89 f0                	mov    %esi,%eax
f01032d8:	eb e5                	jmp    f01032bf <envid2env+0x3d>
		*env_store = 0;
f01032da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01032e3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01032e8:	eb d5                	jmp    f01032bf <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01032ea:	e8 b5 2b 00 00       	call   f0105ea4 <cpunum>
f01032ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01032f2:	39 98 28 30 22 f0    	cmp    %ebx,-0xfddcfd8(%eax)
f01032f8:	74 bb                	je     f01032b5 <envid2env+0x33>
f01032fa:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01032fd:	e8 a2 2b 00 00       	call   f0105ea4 <cpunum>
f0103302:	6b c0 74             	imul   $0x74,%eax,%eax
f0103305:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010330b:	3b 70 48             	cmp    0x48(%eax),%esi
f010330e:	74 a5                	je     f01032b5 <envid2env+0x33>
		*env_store = 0;
f0103310:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103313:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103319:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010331e:	eb 9f                	jmp    f01032bf <envid2env+0x3d>

f0103320 <env_init_percpu>:
{
f0103320:	f3 0f 1e fb          	endbr32 
f0103324:	55                   	push   %ebp
f0103325:	89 e5                	mov    %esp,%ebp
f0103327:	83 ec 08             	sub    $0x8,%esp
	lgdt(&gdt_pd);
f010332a:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f010332f:	e8 b5 fc ff ff       	call   f0102fe9 <lgdt>
	asm volatile("movw %%ax,%%gs" : : "a"(GD_UD | 3));
f0103334:	b8 23 00 00 00       	mov    $0x23,%eax
f0103339:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a"(GD_UD | 3));
f010333b:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a"(GD_KD));
f010333d:	b8 10 00 00 00       	mov    $0x10,%eax
f0103342:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a"(GD_KD));
f0103344:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a"(GD_KD));
f0103346:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i"(GD_KT));
f0103348:	ea 4f 33 10 f0 08 00 	ljmp   $0x8,$0xf010334f
	lldt(0);
f010334f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103354:	e8 94 fc ff ff       	call   f0102fed <lldt>
}
f0103359:	c9                   	leave  
f010335a:	c3                   	ret    

f010335b <env_init>:
{
f010335b:	f3 0f 1e fb          	endbr32 
f010335f:	55                   	push   %ebp
f0103360:	89 e5                	mov    %esp,%ebp
f0103362:	56                   	push   %esi
f0103363:	53                   	push   %ebx
		envs[i].env_status = ENV_FREE;  // en inc/env.h env_free es 0
f0103364:	8b 35 44 12 22 f0    	mov    0xf0221244,%esi
f010336a:	8b 15 48 12 22 f0    	mov    0xf0221248,%edx
f0103370:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103376:	89 f3                	mov    %esi,%ebx
f0103378:	89 d1                	mov    %edx,%ecx
f010337a:	89 c2                	mov    %eax,%edx
f010337c:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103383:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010338a:	89 48 44             	mov    %ecx,0x44(%eax)
f010338d:	83 e8 7c             	sub    $0x7c,%eax
	for (int i = NENV - 1; i >= 0; i--) {
f0103390:	39 da                	cmp    %ebx,%edx
f0103392:	75 e4                	jne    f0103378 <env_init+0x1d>
f0103394:	89 35 48 12 22 f0    	mov    %esi,0xf0221248
	env_init_percpu();
f010339a:	e8 81 ff ff ff       	call   f0103320 <env_init_percpu>
}
f010339f:	5b                   	pop    %ebx
f01033a0:	5e                   	pop    %esi
f01033a1:	5d                   	pop    %ebp
f01033a2:	c3                   	ret    

f01033a3 <env_alloc>:
{
f01033a3:	f3 0f 1e fb          	endbr32 
f01033a7:	55                   	push   %ebp
f01033a8:	89 e5                	mov    %esp,%ebp
f01033aa:	53                   	push   %ebx
f01033ab:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01033ae:	8b 1d 48 12 22 f0    	mov    0xf0221248,%ebx
f01033b4:	85 db                	test   %ebx,%ebx
f01033b6:	0f 84 e9 00 00 00    	je     f01034a5 <env_alloc+0x102>
	if ((r = env_setup_vm(e)) < 0)
f01033bc:	89 d8                	mov    %ebx,%eax
f01033be:	e8 ab fc ff ff       	call   f010306e <env_setup_vm>
f01033c3:	85 c0                	test   %eax,%eax
f01033c5:	0f 88 d5 00 00 00    	js     f01034a0 <env_alloc+0xfd>
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01033cb:	8b 43 48             	mov    0x48(%ebx),%eax
f01033ce:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f01033d3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01033d8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01033dd:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01033e0:	89 da                	mov    %ebx,%edx
f01033e2:	2b 15 44 12 22 f0    	sub    0xf0221244,%edx
f01033e8:	c1 fa 02             	sar    $0x2,%edx
f01033eb:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01033f1:	09 d0                	or     %edx,%eax
f01033f3:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01033f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033f9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01033fc:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103403:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010340a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103411:	83 ec 04             	sub    $0x4,%esp
f0103414:	6a 44                	push   $0x44
f0103416:	6a 00                	push   $0x0
f0103418:	53                   	push   %ebx
f0103419:	e8 f5 23 00 00       	call   f0105813 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010341e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103424:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010342a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103430:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103437:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f010343d:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103444:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f010344b:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010344f:	8b 43 44             	mov    0x44(%ebx),%eax
f0103452:	a3 48 12 22 f0       	mov    %eax,0xf0221248
	*newenv_store = e;
f0103457:	8b 45 08             	mov    0x8(%ebp),%eax
f010345a:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010345c:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010345f:	e8 40 2a 00 00       	call   f0105ea4 <cpunum>
f0103464:	6b c0 74             	imul   $0x74,%eax,%eax
f0103467:	83 c4 10             	add    $0x10,%esp
f010346a:	ba 00 00 00 00       	mov    $0x0,%edx
f010346f:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0103476:	74 11                	je     f0103489 <env_alloc+0xe6>
f0103478:	e8 27 2a 00 00       	call   f0105ea4 <cpunum>
f010347d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103480:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103486:	8b 50 48             	mov    0x48(%eax),%edx
f0103489:	83 ec 04             	sub    $0x4,%esp
f010348c:	53                   	push   %ebx
f010348d:	52                   	push   %edx
f010348e:	68 3f 78 10 f0       	push   $0xf010783f
f0103493:	e8 73 05 00 00       	call   f0103a0b <cprintf>
	return 0;
f0103498:	83 c4 10             	add    $0x10,%esp
f010349b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034a3:	c9                   	leave  
f01034a4:	c3                   	ret    
		return -E_NO_FREE_ENV;
f01034a5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01034aa:	eb f4                	jmp    f01034a0 <env_alloc+0xfd>

f01034ac <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01034ac:	f3 0f 1e fb          	endbr32 
f01034b0:	55                   	push   %ebp
f01034b1:	89 e5                	mov    %esp,%ebp
f01034b3:	53                   	push   %ebx
f01034b4:	83 ec 1c             	sub    $0x1c,%esp
f01034b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	struct Env *e = NULL;
f01034ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int err = env_alloc(&e, 0);
f01034c1:	6a 00                	push   $0x0
f01034c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01034c6:	50                   	push   %eax
f01034c7:	e8 d7 fe ff ff       	call   f01033a3 <env_alloc>
	if (err < 0)
f01034cc:	83 c4 10             	add    $0x10,%esp
f01034cf:	85 c0                	test   %eax,%eax
f01034d1:	78 1b                	js     f01034ee <env_create+0x42>
		panic("env_create: %e", err);

	load_icode(e, binary);
f01034d3:	8b 55 08             	mov    0x8(%ebp),%edx
f01034d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034d9:	e8 ae fc ff ff       	call   f010318c <load_icode>
	e->env_type = type;
f01034de:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034e1:	89 58 50             	mov    %ebx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O
	// privileges.
	// LAB 5: Your code here.
	if(type == ENV_TYPE_FS)
f01034e4:	83 fb 01             	cmp    $0x1,%ebx
f01034e7:	74 1a                	je     f0103503 <env_create+0x57>
		e->env_tf.tf_eflags |= FL_IOPL_3;
}
f01034e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034ec:	c9                   	leave  
f01034ed:	c3                   	ret    
		panic("env_create: %e", err);
f01034ee:	50                   	push   %eax
f01034ef:	68 54 78 10 f0       	push   $0xf0107854
f01034f4:	68 a3 01 00 00       	push   $0x1a3
f01034f9:	68 f7 77 10 f0       	push   $0xf01077f7
f01034fe:	e8 67 cb ff ff       	call   f010006a <_panic>
		e->env_tf.tf_eflags |= FL_IOPL_3;
f0103503:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f010350a:	eb dd                	jmp    f01034e9 <env_create+0x3d>

f010350c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010350c:	f3 0f 1e fb          	endbr32 
f0103510:	55                   	push   %ebp
f0103511:	89 e5                	mov    %esp,%ebp
f0103513:	57                   	push   %edi
f0103514:	56                   	push   %esi
f0103515:	53                   	push   %ebx
f0103516:	83 ec 1c             	sub    $0x1c,%esp
f0103519:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010351c:	e8 83 29 00 00       	call   f0105ea4 <cpunum>
f0103521:	6b c0 74             	imul   $0x74,%eax,%eax
f0103524:	39 b8 28 30 22 f0    	cmp    %edi,-0xfddcfd8(%eax)
f010352a:	74 45                	je     f0103571 <env_free+0x65>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010352c:	8b 5f 48             	mov    0x48(%edi),%ebx
f010352f:	e8 70 29 00 00       	call   f0105ea4 <cpunum>
f0103534:	6b c0 74             	imul   $0x74,%eax,%eax
f0103537:	ba 00 00 00 00       	mov    $0x0,%edx
f010353c:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0103543:	74 11                	je     f0103556 <env_free+0x4a>
f0103545:	e8 5a 29 00 00       	call   f0105ea4 <cpunum>
f010354a:	6b c0 74             	imul   $0x74,%eax,%eax
f010354d:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103553:	8b 50 48             	mov    0x48(%eax),%edx
f0103556:	83 ec 04             	sub    $0x4,%esp
f0103559:	53                   	push   %ebx
f010355a:	52                   	push   %edx
f010355b:	68 63 78 10 f0       	push   $0xf0107863
f0103560:	e8 a6 04 00 00       	call   f0103a0b <cprintf>
f0103565:	83 c4 10             	add    $0x10,%esp
f0103568:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010356f:	eb 75                	jmp    f01035e6 <env_free+0xda>
		lcr3(PADDR(kern_pgdir));
f0103571:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0103577:	ba bd 01 00 00       	mov    $0x1bd,%edx
f010357c:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f0103581:	e8 c6 fa ff ff       	call   f010304c <_paddr>
f0103586:	e8 66 fa ff ff       	call   f0102ff1 <lcr3>
f010358b:	eb 9f                	jmp    f010352c <env_free+0x20>
		pt = (pte_t *) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010358d:	83 ec 08             	sub    $0x8,%esp
f0103590:	89 d8                	mov    %ebx,%eax
f0103592:	c1 e0 0c             	shl    $0xc,%eax
f0103595:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103598:	50                   	push   %eax
f0103599:	ff 77 60             	pushl  0x60(%edi)
f010359c:	e8 2f e6 ff ff       	call   f0101bd0 <page_remove>
f01035a1:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01035a4:	83 c3 01             	add    $0x1,%ebx
f01035a7:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01035ad:	74 08                	je     f01035b7 <env_free+0xab>
			if (pt[pteno] & PTE_P)
f01035af:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f01035b3:	74 ef                	je     f01035a4 <env_free+0x98>
f01035b5:	eb d6                	jmp    f010358d <env_free+0x81>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01035b7:	8b 47 60             	mov    0x60(%edi),%eax
f01035ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035bd:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
		page_decref(pa2page(pa));
f01035c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01035c7:	e8 10 fb ff ff       	call   f01030dc <pa2page>
f01035cc:	83 ec 0c             	sub    $0xc,%esp
f01035cf:	50                   	push   %eax
f01035d0:	e8 c1 e0 ff ff       	call   f0101696 <page_decref>
f01035d5:	83 c4 10             	add    $0x10,%esp
f01035d8:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01035dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035df:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01035e4:	74 38                	je     f010361e <env_free+0x112>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035e6:	8b 47 60             	mov    0x60(%edi),%eax
f01035e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035ec:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01035ef:	a8 01                	test   $0x1,%al
f01035f1:	74 e5                	je     f01035d8 <env_free+0xcc>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01035f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		pt = (pte_t *) KADDR(pa);
f01035fb:	89 c1                	mov    %eax,%ecx
f01035fd:	ba cb 01 00 00       	mov    $0x1cb,%edx
f0103602:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f0103607:	e8 f6 f9 ff ff       	call   f0103002 <_kaddr>
f010360c:	89 c6                	mov    %eax,%esi
f010360e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103611:	c1 e0 14             	shl    $0x14,%eax
f0103614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103617:	bb 00 00 00 00       	mov    $0x0,%ebx
f010361c:	eb 91                	jmp    f01035af <env_free+0xa3>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010361e:	8b 4f 60             	mov    0x60(%edi),%ecx
f0103621:	ba d9 01 00 00       	mov    $0x1d9,%edx
f0103626:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f010362b:	e8 1c fa ff ff       	call   f010304c <_paddr>
	e->env_pgdir = 0;
f0103630:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	page_decref(pa2page(pa));
f0103637:	e8 a0 fa ff ff       	call   f01030dc <pa2page>
f010363c:	83 ec 0c             	sub    $0xc,%esp
f010363f:	50                   	push   %eax
f0103640:	e8 51 e0 ff ff       	call   f0101696 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103645:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010364c:	a1 48 12 22 f0       	mov    0xf0221248,%eax
f0103651:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103654:	89 3d 48 12 22 f0    	mov    %edi,0xf0221248
}
f010365a:	83 c4 10             	add    $0x10,%esp
f010365d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103660:	5b                   	pop    %ebx
f0103661:	5e                   	pop    %esi
f0103662:	5f                   	pop    %edi
f0103663:	5d                   	pop    %ebp
f0103664:	c3                   	ret    

f0103665 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103665:	f3 0f 1e fb          	endbr32 
f0103669:	55                   	push   %ebp
f010366a:	89 e5                	mov    %esp,%ebp
f010366c:	53                   	push   %ebx
f010366d:	83 ec 04             	sub    $0x4,%esp
f0103670:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103673:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103677:	74 21                	je     f010369a <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103679:	83 ec 0c             	sub    $0xc,%esp
f010367c:	53                   	push   %ebx
f010367d:	e8 8a fe ff ff       	call   f010350c <env_free>

	if (curenv == e) {
f0103682:	e8 1d 28 00 00       	call   f0105ea4 <cpunum>
f0103687:	6b c0 74             	imul   $0x74,%eax,%eax
f010368a:	83 c4 10             	add    $0x10,%esp
f010368d:	39 98 28 30 22 f0    	cmp    %ebx,-0xfddcfd8(%eax)
f0103693:	74 1e                	je     f01036b3 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f0103695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103698:	c9                   	leave  
f0103699:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010369a:	e8 05 28 00 00       	call   f0105ea4 <cpunum>
f010369f:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a2:	39 98 28 30 22 f0    	cmp    %ebx,-0xfddcfd8(%eax)
f01036a8:	74 cf                	je     f0103679 <env_destroy+0x14>
		e->env_status = ENV_DYING;
f01036aa:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01036b1:	eb e2                	jmp    f0103695 <env_destroy+0x30>
		curenv = NULL;
f01036b3:	e8 ec 27 00 00       	call   f0105ea4 <cpunum>
f01036b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bb:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f01036c2:	00 00 00 
		sched_yield();
f01036c5:	e8 b2 0e 00 00       	call   f010457c <sched_yield>

f01036ca <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036ca:	f3 0f 1e fb          	endbr32 
f01036ce:	55                   	push   %ebp
f01036cf:	89 e5                	mov    %esp,%ebp
f01036d1:	53                   	push   %ebx
f01036d2:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036d5:	e8 ca 27 00 00       	call   f0105ea4 <cpunum>
f01036da:	6b c0 74             	imul   $0x74,%eax,%eax
f01036dd:	8b 98 28 30 22 f0    	mov    -0xfddcfd8(%eax),%ebx
f01036e3:	e8 bc 27 00 00       	call   f0105ea4 <cpunum>
f01036e8:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile("\tmovl %0,%%esp\n"
f01036eb:	8b 65 08             	mov    0x8(%ebp),%esp
f01036ee:	61                   	popa   
f01036ef:	07                   	pop    %es
f01036f0:	1f                   	pop    %ds
f01036f1:	83 c4 08             	add    $0x8,%esp
f01036f4:	cf                   	iret   
	             "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
	             "\tiret\n"
	             :
	             : "g"(tf)
	             : "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f01036f5:	83 ec 04             	sub    $0x4,%esp
f01036f8:	68 79 78 10 f0       	push   $0xf0107879
f01036fd:	68 11 02 00 00       	push   $0x211
f0103702:	68 f7 77 10 f0       	push   $0xf01077f7
f0103707:	e8 5e c9 ff ff       	call   f010006a <_panic>

f010370c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010370c:	f3 0f 1e fb          	endbr32 
f0103710:	55                   	push   %ebp
f0103711:	89 e5                	mov    %esp,%ebp
f0103713:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103716:	e8 89 27 00 00       	call   f0105ea4 <cpunum>
f010371b:	6b c0 74             	imul   $0x74,%eax,%eax
f010371e:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0103725:	74 14                	je     f010373b <env_run+0x2f>
f0103727:	e8 78 27 00 00       	call   f0105ea4 <cpunum>
f010372c:	6b c0 74             	imul   $0x74,%eax,%eax
f010372f:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103735:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103739:	74 78                	je     f01037b3 <env_run+0xa7>
		curenv->env_status = ENV_RUNNABLE;
	curenv = e;
f010373b:	e8 64 27 00 00       	call   f0105ea4 <cpunum>
f0103740:	6b c0 74             	imul   $0x74,%eax,%eax
f0103743:	8b 55 08             	mov    0x8(%ebp),%edx
f0103746:	89 90 28 30 22 f0    	mov    %edx,-0xfddcfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010374c:	e8 53 27 00 00       	call   f0105ea4 <cpunum>
f0103751:	6b c0 74             	imul   $0x74,%eax,%eax
f0103754:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010375a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103761:	e8 3e 27 00 00       	call   f0105ea4 <cpunum>
f0103766:	6b c0 74             	imul   $0x74,%eax,%eax
f0103769:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010376f:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f0103773:	e8 2c 27 00 00       	call   f0105ea4 <cpunum>
f0103778:	6b c0 74             	imul   $0x74,%eax,%eax
f010377b:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103781:	8b 48 60             	mov    0x60(%eax),%ecx
f0103784:	ba 35 02 00 00       	mov    $0x235,%edx
f0103789:	b8 f7 77 10 f0       	mov    $0xf01077f7,%eax
f010378e:	e8 b9 f8 ff ff       	call   f010304c <_paddr>
f0103793:	e8 59 f8 ff ff       	call   f0102ff1 <lcr3>
	unlock_kernel();
f0103798:	e8 ce fa ff ff       	call   f010326b <unlock_kernel>
	env_pop_tf(&curenv->env_tf);
f010379d:	e8 02 27 00 00       	call   f0105ea4 <cpunum>
f01037a2:	83 ec 0c             	sub    $0xc,%esp
f01037a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01037a8:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01037ae:	e8 17 ff ff ff       	call   f01036ca <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f01037b3:	e8 ec 26 00 00       	call   f0105ea4 <cpunum>
f01037b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01037bb:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01037c1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01037c8:	e9 6e ff ff ff       	jmp    f010373b <env_run+0x2f>

f01037cd <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037cd:	89 c2                	mov    %eax,%edx
f01037cf:	ec                   	in     (%dx),%al
}
f01037d0:	c3                   	ret    

f01037d1 <outb>:
{
f01037d1:	89 c1                	mov    %eax,%ecx
f01037d3:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037d5:	89 ca                	mov    %ecx,%edx
f01037d7:	ee                   	out    %al,(%dx)
}
f01037d8:	c3                   	ret    

f01037d9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037d9:	f3 0f 1e fb          	endbr32 
f01037dd:	55                   	push   %ebp
f01037de:	89 e5                	mov    %esp,%ebp
f01037e0:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f01037e3:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f01037e7:	b8 70 00 00 00       	mov    $0x70,%eax
f01037ec:	e8 e0 ff ff ff       	call   f01037d1 <outb>
	return inb(IO_RTC+1);
f01037f1:	b8 71 00 00 00       	mov    $0x71,%eax
f01037f6:	e8 d2 ff ff ff       	call   f01037cd <inb>
f01037fb:	0f b6 c0             	movzbl %al,%eax
}
f01037fe:	c9                   	leave  
f01037ff:	c3                   	ret    

f0103800 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103800:	f3 0f 1e fb          	endbr32 
f0103804:	55                   	push   %ebp
f0103805:	89 e5                	mov    %esp,%ebp
f0103807:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f010380a:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f010380e:	b8 70 00 00 00       	mov    $0x70,%eax
f0103813:	e8 b9 ff ff ff       	call   f01037d1 <outb>
	outb(IO_RTC+1, datum);
f0103818:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f010381c:	b8 71 00 00 00       	mov    $0x71,%eax
f0103821:	e8 ab ff ff ff       	call   f01037d1 <outb>
}
f0103826:	c9                   	leave  
f0103827:	c3                   	ret    

f0103828 <outb>:
{
f0103828:	89 c1                	mov    %eax,%ecx
f010382a:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010382c:	89 ca                	mov    %ecx,%edx
f010382e:	ee                   	out    %al,(%dx)
}
f010382f:	c3                   	ret    

f0103830 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103830:	f3 0f 1e fb          	endbr32 
f0103834:	55                   	push   %ebp
f0103835:	89 e5                	mov    %esp,%ebp
f0103837:	56                   	push   %esi
f0103838:	53                   	push   %ebx
f0103839:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	irq_mask_8259A = mask;
f010383c:	66 89 1d a8 23 12 f0 	mov    %bx,0xf01223a8
	if (!didinit)
f0103843:	80 3d 4c 12 22 f0 00 	cmpb   $0x0,0xf022124c
f010384a:	75 07                	jne    f0103853 <irq_setmask_8259A+0x23>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010384c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010384f:	5b                   	pop    %ebx
f0103850:	5e                   	pop    %esi
f0103851:	5d                   	pop    %ebp
f0103852:	c3                   	ret    
f0103853:	89 de                	mov    %ebx,%esi
	outb(IO_PIC1+1, (char)mask);
f0103855:	0f b6 d3             	movzbl %bl,%edx
f0103858:	b8 21 00 00 00       	mov    $0x21,%eax
f010385d:	e8 c6 ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103862:	0f b6 d7             	movzbl %bh,%edx
f0103865:	b8 a1 00 00 00       	mov    $0xa1,%eax
f010386a:	e8 b9 ff ff ff       	call   f0103828 <outb>
	cprintf("enabled interrupts:");
f010386f:	83 ec 0c             	sub    $0xc,%esp
f0103872:	68 85 78 10 f0       	push   $0xf0107885
f0103877:	e8 8f 01 00 00       	call   f0103a0b <cprintf>
f010387c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010387f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103884:	0f b7 f6             	movzwl %si,%esi
f0103887:	f7 d6                	not    %esi
f0103889:	eb 19                	jmp    f01038a4 <irq_setmask_8259A+0x74>
			cprintf(" %d", i);
f010388b:	83 ec 08             	sub    $0x8,%esp
f010388e:	53                   	push   %ebx
f010388f:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0103894:	e8 72 01 00 00       	call   f0103a0b <cprintf>
f0103899:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010389c:	83 c3 01             	add    $0x1,%ebx
f010389f:	83 fb 10             	cmp    $0x10,%ebx
f01038a2:	74 07                	je     f01038ab <irq_setmask_8259A+0x7b>
		if (~mask & (1<<i))
f01038a4:	0f a3 de             	bt     %ebx,%esi
f01038a7:	73 f3                	jae    f010389c <irq_setmask_8259A+0x6c>
f01038a9:	eb e0                	jmp    f010388b <irq_setmask_8259A+0x5b>
	cprintf("\n");
f01038ab:	83 ec 0c             	sub    $0xc,%esp
f01038ae:	68 f5 77 10 f0       	push   $0xf01077f5
f01038b3:	e8 53 01 00 00       	call   f0103a0b <cprintf>
f01038b8:	83 c4 10             	add    $0x10,%esp
f01038bb:	eb 8f                	jmp    f010384c <irq_setmask_8259A+0x1c>

f01038bd <pic_init>:
{
f01038bd:	f3 0f 1e fb          	endbr32 
f01038c1:	55                   	push   %ebp
f01038c2:	89 e5                	mov    %esp,%ebp
f01038c4:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f01038c7:	c6 05 4c 12 22 f0 01 	movb   $0x1,0xf022124c
	outb(IO_PIC1+1, 0xFF);
f01038ce:	ba ff 00 00 00       	mov    $0xff,%edx
f01038d3:	b8 21 00 00 00       	mov    $0x21,%eax
f01038d8:	e8 4b ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC2+1, 0xFF);
f01038dd:	ba ff 00 00 00       	mov    $0xff,%edx
f01038e2:	b8 a1 00 00 00       	mov    $0xa1,%eax
f01038e7:	e8 3c ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC1, 0x11);
f01038ec:	ba 11 00 00 00       	mov    $0x11,%edx
f01038f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01038f6:	e8 2d ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC1+1, IRQ_OFFSET);
f01038fb:	ba 20 00 00 00       	mov    $0x20,%edx
f0103900:	b8 21 00 00 00       	mov    $0x21,%eax
f0103905:	e8 1e ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC1+1, 1<<IRQ_SLAVE);
f010390a:	ba 04 00 00 00       	mov    $0x4,%edx
f010390f:	b8 21 00 00 00       	mov    $0x21,%eax
f0103914:	e8 0f ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC1+1, 0x3);
f0103919:	ba 03 00 00 00       	mov    $0x3,%edx
f010391e:	b8 21 00 00 00       	mov    $0x21,%eax
f0103923:	e8 00 ff ff ff       	call   f0103828 <outb>
	outb(IO_PIC2, 0x11);			// ICW1
f0103928:	ba 11 00 00 00       	mov    $0x11,%edx
f010392d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0103932:	e8 f1 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC2+1, IRQ_OFFSET + 8);	// ICW2
f0103937:	ba 28 00 00 00       	mov    $0x28,%edx
f010393c:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103941:	e8 e2 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC2+1, IRQ_SLAVE);		// ICW3
f0103946:	ba 02 00 00 00       	mov    $0x2,%edx
f010394b:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103950:	e8 d3 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC2+1, 0x01);			// ICW4
f0103955:	ba 01 00 00 00       	mov    $0x1,%edx
f010395a:	b8 a1 00 00 00       	mov    $0xa1,%eax
f010395f:	e8 c4 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC1, 0x68);             /* clear specific mask */
f0103964:	ba 68 00 00 00       	mov    $0x68,%edx
f0103969:	b8 20 00 00 00       	mov    $0x20,%eax
f010396e:	e8 b5 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC1, 0x0a);             /* read IRR by default */
f0103973:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103978:	b8 20 00 00 00       	mov    $0x20,%eax
f010397d:	e8 a6 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC2, 0x68);               /* OCW3 */
f0103982:	ba 68 00 00 00       	mov    $0x68,%edx
f0103987:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010398c:	e8 97 fe ff ff       	call   f0103828 <outb>
	outb(IO_PIC2, 0x0a);               /* OCW3 */
f0103991:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103996:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010399b:	e8 88 fe ff ff       	call   f0103828 <outb>
	if (irq_mask_8259A != 0xFFFF)
f01039a0:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01039a7:	66 83 f8 ff          	cmp    $0xffff,%ax
f01039ab:	75 02                	jne    f01039af <pic_init+0xf2>
}
f01039ad:	c9                   	leave  
f01039ae:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01039af:	83 ec 0c             	sub    $0xc,%esp
f01039b2:	0f b7 c0             	movzwl %ax,%eax
f01039b5:	50                   	push   %eax
f01039b6:	e8 75 fe ff ff       	call   f0103830 <irq_setmask_8259A>
f01039bb:	83 c4 10             	add    $0x10,%esp
}
f01039be:	eb ed                	jmp    f01039ad <pic_init+0xf0>

f01039c0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01039c0:	f3 0f 1e fb          	endbr32 
f01039c4:	55                   	push   %ebp
f01039c5:	89 e5                	mov    %esp,%ebp
f01039c7:	53                   	push   %ebx
f01039c8:	83 ec 10             	sub    $0x10,%esp
f01039cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01039ce:	ff 75 08             	pushl  0x8(%ebp)
f01039d1:	e8 6a cf ff ff       	call   f0100940 <cputchar>
	(*cnt)++;
f01039d6:	83 03 01             	addl   $0x1,(%ebx)
}
f01039d9:	83 c4 10             	add    $0x10,%esp
f01039dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039df:	c9                   	leave  
f01039e0:	c3                   	ret    

f01039e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039e1:	f3 0f 1e fb          	endbr32 
f01039e5:	55                   	push   %ebp
f01039e6:	89 e5                	mov    %esp,%ebp
f01039e8:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01039eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039f2:	ff 75 0c             	pushl  0xc(%ebp)
f01039f5:	ff 75 08             	pushl  0x8(%ebp)
f01039f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039fb:	50                   	push   %eax
f01039fc:	68 c0 39 10 f0       	push   $0xf01039c0
f0103a01:	e8 aa 17 00 00       	call   f01051b0 <vprintfmt>
	return cnt;
}
f0103a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a09:	c9                   	leave  
f0103a0a:	c3                   	ret    

f0103a0b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a0b:	f3 0f 1e fb          	endbr32 
f0103a0f:	55                   	push   %ebp
f0103a10:	89 e5                	mov    %esp,%ebp
f0103a12:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103a15:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103a18:	50                   	push   %eax
f0103a19:	ff 75 08             	pushl  0x8(%ebp)
f0103a1c:	e8 c0 ff ff ff       	call   f01039e1 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a21:	c9                   	leave  
f0103a22:	c3                   	ret    

f0103a23 <lidt>:
	asm volatile("lidt (%0)" : : "r" (p));
f0103a23:	0f 01 18             	lidtl  (%eax)
}
f0103a26:	c3                   	ret    

f0103a27 <ltr>:
	asm volatile("ltr %0" : : "r" (sel));
f0103a27:	0f 00 d8             	ltr    %ax
}
f0103a2a:	c3                   	ret    

f0103a2b <rcr2>:
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103a2b:	0f 20 d0             	mov    %cr2,%eax
}
f0103a2e:	c3                   	ret    

f0103a2f <read_eflags>:
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103a2f:	9c                   	pushf  
f0103a30:	58                   	pop    %eax
}
f0103a31:	c3                   	ret    

f0103a32 <xchg>:
{
f0103a32:	89 c1                	mov    %eax,%ecx
f0103a34:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f0103a36:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0103a39:	c3                   	ret    

f0103a3a <trapname>:
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103a3a:	83 f8 13             	cmp    $0x13,%eax
f0103a3d:	76 20                	jbe    f0103a5f <trapname+0x25>
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103a3f:	ba a8 78 10 f0       	mov    $0xf01078a8,%edx
	if (trapno == T_SYSCALL)
f0103a44:	83 f8 30             	cmp    $0x30,%eax
f0103a47:	74 13                	je     f0103a5c <trapname+0x22>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103a49:	83 e8 20             	sub    $0x20,%eax
		return "Hardware Interrupt";
f0103a4c:	83 f8 0f             	cmp    $0xf,%eax
f0103a4f:	ba 99 78 10 f0       	mov    $0xf0107899,%edx
f0103a54:	b8 b4 78 10 f0       	mov    $0xf01078b4,%eax
f0103a59:	0f 46 d0             	cmovbe %eax,%edx
	return "(unknown trap)";
}
f0103a5c:	89 d0                	mov    %edx,%eax
f0103a5e:	c3                   	ret    
		return excnames[trapno];
f0103a5f:	8b 14 85 20 7c 10 f0 	mov    -0xfef83e0(,%eax,4),%edx
f0103a66:	eb f4                	jmp    f0103a5c <trapname+0x22>

f0103a68 <lock_kernel>:
{
f0103a68:	55                   	push   %ebp
f0103a69:	89 e5                	mov    %esp,%ebp
f0103a6b:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f0103a6e:	68 c0 23 12 f0       	push   $0xf01223c0
f0103a73:	e8 31 27 00 00       	call   f01061a9 <spin_lock>
}
f0103a78:	83 c4 10             	add    $0x10,%esp
f0103a7b:	c9                   	leave  
f0103a7c:	c3                   	ret    

f0103a7d <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103a7d:	f3 0f 1e fb          	endbr32 
f0103a81:	55                   	push   %ebp
f0103a82:	89 e5                	mov    %esp,%ebp
f0103a84:	56                   	push   %esi
f0103a85:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int id = cpunum();
f0103a86:	e8 19 24 00 00       	call   f0105ea4 <cpunum>
	struct CpuInfo *cpu = &cpus[id];
	struct Taskstate *ts = &cpu->cpu_ts;
f0103a8b:	6b c8 74             	imul   $0x74,%eax,%ecx
f0103a8e:	8d 99 2c 30 22 f0    	lea    -0xfddcfd4(%ecx),%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	uint16_t idx = (GD_TSS0 >> 3) + id;
f0103a94:	8d 50 05             	lea    0x5(%eax),%edx
	uint16_t seg = idx << 3;

	ts->ts_esp0 = KSTACKTOP - id * (KSTKSIZE + KSTKGAP);
f0103a97:	c1 e0 10             	shl    $0x10,%eax
f0103a9a:	be 00 00 00 f0       	mov    $0xf0000000,%esi
f0103a9f:	29 c6                	sub    %eax,%esi
f0103aa1:	89 b1 30 30 22 f0    	mov    %esi,-0xfddcfd0(%ecx)
	ts->ts_ss0 = GD_KD;
f0103aa7:	66 c7 81 34 30 22 f0 	movw   $0x10,-0xfddcfcc(%ecx)
f0103aae:	10 00 
	ts->ts_iomb = sizeof(struct Taskstate);
f0103ab0:	66 c7 81 92 30 22 f0 	movw   $0x68,-0xfddcf6e(%ecx)
f0103ab7:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[idx] =
f0103ab9:	0f b7 c2             	movzwl %dx,%eax
f0103abc:	66 c7 04 c5 40 23 12 	movw   $0x67,-0xfeddcc0(,%eax,8)
f0103ac3:	f0 67 00 
f0103ac6:	66 89 1c c5 42 23 12 	mov    %bx,-0xfeddcbe(,%eax,8)
f0103acd:	f0 
	        SEG16(STS_T32A, (uint32_t)(ts), sizeof(struct Taskstate) - 1, 0);
f0103ace:	89 d9                	mov    %ebx,%ecx
f0103ad0:	c1 e9 10             	shr    $0x10,%ecx
	gdt[idx] =
f0103ad3:	88 0c c5 44 23 12 f0 	mov    %cl,-0xfeddcbc(,%eax,8)
f0103ada:	c6 04 c5 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%eax,8)
f0103ae1:	40 
	        SEG16(STS_T32A, (uint32_t)(ts), sizeof(struct Taskstate) - 1, 0);
f0103ae2:	c1 eb 18             	shr    $0x18,%ebx
	gdt[idx] =
f0103ae5:	88 1c c5 47 23 12 f0 	mov    %bl,-0xfeddcb9(,%eax,8)
	gdt[idx].sd_s = 0;
f0103aec:	c6 04 c5 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%eax,8)
f0103af3:	89 
	uint16_t seg = idx << 3;
f0103af4:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(seg);
f0103afb:	0f b7 c0             	movzwl %ax,%eax
f0103afe:	e8 24 ff ff ff       	call   f0103a27 <ltr>

	// Load the IDT
	lidt(&idt_pd);
f0103b03:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103b08:	e8 16 ff ff ff       	call   f0103a23 <lidt>
}
f0103b0d:	5b                   	pop    %ebx
f0103b0e:	5e                   	pop    %esi
f0103b0f:	5d                   	pop    %ebp
f0103b10:	c3                   	ret    

f0103b11 <trap_init>:
{
f0103b11:	f3 0f 1e fb          	endbr32 
f0103b15:	55                   	push   %ebp
f0103b16:	89 e5                	mov    %esp,%ebp
f0103b18:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], false, GD_KT, trap_0, 0);
f0103b1b:	b8 f8 43 10 f0       	mov    $0xf01043f8,%eax
f0103b20:	66 a3 60 12 22 f0    	mov    %ax,0xf0221260
f0103b26:	66 c7 05 62 12 22 f0 	movw   $0x8,0xf0221262
f0103b2d:	08 00 
f0103b2f:	c6 05 64 12 22 f0 00 	movb   $0x0,0xf0221264
f0103b36:	c6 05 65 12 22 f0 8e 	movb   $0x8e,0xf0221265
f0103b3d:	c1 e8 10             	shr    $0x10,%eax
f0103b40:	66 a3 66 12 22 f0    	mov    %ax,0xf0221266
	SETGATE(idt[T_DEBUG], false, GD_KT, trap_1, 0);
f0103b46:	b8 fe 43 10 f0       	mov    $0xf01043fe,%eax
f0103b4b:	66 a3 68 12 22 f0    	mov    %ax,0xf0221268
f0103b51:	66 c7 05 6a 12 22 f0 	movw   $0x8,0xf022126a
f0103b58:	08 00 
f0103b5a:	c6 05 6c 12 22 f0 00 	movb   $0x0,0xf022126c
f0103b61:	c6 05 6d 12 22 f0 8e 	movb   $0x8e,0xf022126d
f0103b68:	c1 e8 10             	shr    $0x10,%eax
f0103b6b:	66 a3 6e 12 22 f0    	mov    %ax,0xf022126e
	SETGATE(idt[T_NMI], false, GD_KT, trap_2, 0);
f0103b71:	b8 04 44 10 f0       	mov    $0xf0104404,%eax
f0103b76:	66 a3 70 12 22 f0    	mov    %ax,0xf0221270
f0103b7c:	66 c7 05 72 12 22 f0 	movw   $0x8,0xf0221272
f0103b83:	08 00 
f0103b85:	c6 05 74 12 22 f0 00 	movb   $0x0,0xf0221274
f0103b8c:	c6 05 75 12 22 f0 8e 	movb   $0x8e,0xf0221275
f0103b93:	c1 e8 10             	shr    $0x10,%eax
f0103b96:	66 a3 76 12 22 f0    	mov    %ax,0xf0221276
	SETGATE(idt[T_BRKPT], false, GD_KT, trap_3, 3);
f0103b9c:	b8 0a 44 10 f0       	mov    $0xf010440a,%eax
f0103ba1:	66 a3 78 12 22 f0    	mov    %ax,0xf0221278
f0103ba7:	66 c7 05 7a 12 22 f0 	movw   $0x8,0xf022127a
f0103bae:	08 00 
f0103bb0:	c6 05 7c 12 22 f0 00 	movb   $0x0,0xf022127c
f0103bb7:	c6 05 7d 12 22 f0 ee 	movb   $0xee,0xf022127d
f0103bbe:	c1 e8 10             	shr    $0x10,%eax
f0103bc1:	66 a3 7e 12 22 f0    	mov    %ax,0xf022127e
	SETGATE(idt[T_OFLOW], false, GD_KT, trap_4, 0);
f0103bc7:	b8 10 44 10 f0       	mov    $0xf0104410,%eax
f0103bcc:	66 a3 80 12 22 f0    	mov    %ax,0xf0221280
f0103bd2:	66 c7 05 82 12 22 f0 	movw   $0x8,0xf0221282
f0103bd9:	08 00 
f0103bdb:	c6 05 84 12 22 f0 00 	movb   $0x0,0xf0221284
f0103be2:	c6 05 85 12 22 f0 8e 	movb   $0x8e,0xf0221285
f0103be9:	c1 e8 10             	shr    $0x10,%eax
f0103bec:	66 a3 86 12 22 f0    	mov    %ax,0xf0221286
	SETGATE(idt[T_BOUND], false, GD_KT, trap_5, 0);
f0103bf2:	b8 16 44 10 f0       	mov    $0xf0104416,%eax
f0103bf7:	66 a3 88 12 22 f0    	mov    %ax,0xf0221288
f0103bfd:	66 c7 05 8a 12 22 f0 	movw   $0x8,0xf022128a
f0103c04:	08 00 
f0103c06:	c6 05 8c 12 22 f0 00 	movb   $0x0,0xf022128c
f0103c0d:	c6 05 8d 12 22 f0 8e 	movb   $0x8e,0xf022128d
f0103c14:	c1 e8 10             	shr    $0x10,%eax
f0103c17:	66 a3 8e 12 22 f0    	mov    %ax,0xf022128e
	SETGATE(idt[T_ILLOP], false, GD_KT, trap_6, 0);
f0103c1d:	b8 1c 44 10 f0       	mov    $0xf010441c,%eax
f0103c22:	66 a3 90 12 22 f0    	mov    %ax,0xf0221290
f0103c28:	66 c7 05 92 12 22 f0 	movw   $0x8,0xf0221292
f0103c2f:	08 00 
f0103c31:	c6 05 94 12 22 f0 00 	movb   $0x0,0xf0221294
f0103c38:	c6 05 95 12 22 f0 8e 	movb   $0x8e,0xf0221295
f0103c3f:	c1 e8 10             	shr    $0x10,%eax
f0103c42:	66 a3 96 12 22 f0    	mov    %ax,0xf0221296
	SETGATE(idt[T_DEVICE], false, GD_KT, trap_7, 0);
f0103c48:	b8 22 44 10 f0       	mov    $0xf0104422,%eax
f0103c4d:	66 a3 98 12 22 f0    	mov    %ax,0xf0221298
f0103c53:	66 c7 05 9a 12 22 f0 	movw   $0x8,0xf022129a
f0103c5a:	08 00 
f0103c5c:	c6 05 9c 12 22 f0 00 	movb   $0x0,0xf022129c
f0103c63:	c6 05 9d 12 22 f0 8e 	movb   $0x8e,0xf022129d
f0103c6a:	c1 e8 10             	shr    $0x10,%eax
f0103c6d:	66 a3 9e 12 22 f0    	mov    %ax,0xf022129e
	SETGATE(idt[T_DBLFLT], false, GD_KT, trap_8, 0);
f0103c73:	b8 28 44 10 f0       	mov    $0xf0104428,%eax
f0103c78:	66 a3 a0 12 22 f0    	mov    %ax,0xf02212a0
f0103c7e:	66 c7 05 a2 12 22 f0 	movw   $0x8,0xf02212a2
f0103c85:	08 00 
f0103c87:	c6 05 a4 12 22 f0 00 	movb   $0x0,0xf02212a4
f0103c8e:	c6 05 a5 12 22 f0 8e 	movb   $0x8e,0xf02212a5
f0103c95:	c1 e8 10             	shr    $0x10,%eax
f0103c98:	66 a3 a6 12 22 f0    	mov    %ax,0xf02212a6
	SETGATE(idt[T_TSS], false, GD_KT, trap_10, 0);
f0103c9e:	b8 2e 44 10 f0       	mov    $0xf010442e,%eax
f0103ca3:	66 a3 b0 12 22 f0    	mov    %ax,0xf02212b0
f0103ca9:	66 c7 05 b2 12 22 f0 	movw   $0x8,0xf02212b2
f0103cb0:	08 00 
f0103cb2:	c6 05 b4 12 22 f0 00 	movb   $0x0,0xf02212b4
f0103cb9:	c6 05 b5 12 22 f0 8e 	movb   $0x8e,0xf02212b5
f0103cc0:	c1 e8 10             	shr    $0x10,%eax
f0103cc3:	66 a3 b6 12 22 f0    	mov    %ax,0xf02212b6
	SETGATE(idt[T_SEGNP], false, GD_KT, trap_11, 0);
f0103cc9:	b8 34 44 10 f0       	mov    $0xf0104434,%eax
f0103cce:	66 a3 b8 12 22 f0    	mov    %ax,0xf02212b8
f0103cd4:	66 c7 05 ba 12 22 f0 	movw   $0x8,0xf02212ba
f0103cdb:	08 00 
f0103cdd:	c6 05 bc 12 22 f0 00 	movb   $0x0,0xf02212bc
f0103ce4:	c6 05 bd 12 22 f0 8e 	movb   $0x8e,0xf02212bd
f0103ceb:	c1 e8 10             	shr    $0x10,%eax
f0103cee:	66 a3 be 12 22 f0    	mov    %ax,0xf02212be
	SETGATE(idt[T_STACK], false, GD_KT, trap_12, 0);
f0103cf4:	b8 38 44 10 f0       	mov    $0xf0104438,%eax
f0103cf9:	66 a3 c0 12 22 f0    	mov    %ax,0xf02212c0
f0103cff:	66 c7 05 c2 12 22 f0 	movw   $0x8,0xf02212c2
f0103d06:	08 00 
f0103d08:	c6 05 c4 12 22 f0 00 	movb   $0x0,0xf02212c4
f0103d0f:	c6 05 c5 12 22 f0 8e 	movb   $0x8e,0xf02212c5
f0103d16:	c1 e8 10             	shr    $0x10,%eax
f0103d19:	66 a3 c6 12 22 f0    	mov    %ax,0xf02212c6
	SETGATE(idt[T_GPFLT], false, GD_KT, trap_13, 0);
f0103d1f:	b8 3c 44 10 f0       	mov    $0xf010443c,%eax
f0103d24:	66 a3 c8 12 22 f0    	mov    %ax,0xf02212c8
f0103d2a:	66 c7 05 ca 12 22 f0 	movw   $0x8,0xf02212ca
f0103d31:	08 00 
f0103d33:	c6 05 cc 12 22 f0 00 	movb   $0x0,0xf02212cc
f0103d3a:	c6 05 cd 12 22 f0 8e 	movb   $0x8e,0xf02212cd
f0103d41:	c1 e8 10             	shr    $0x10,%eax
f0103d44:	66 a3 ce 12 22 f0    	mov    %ax,0xf02212ce
	SETGATE(idt[T_PGFLT], false, GD_KT, trap_14, 0);
f0103d4a:	b8 40 44 10 f0       	mov    $0xf0104440,%eax
f0103d4f:	66 a3 d0 12 22 f0    	mov    %ax,0xf02212d0
f0103d55:	66 c7 05 d2 12 22 f0 	movw   $0x8,0xf02212d2
f0103d5c:	08 00 
f0103d5e:	c6 05 d4 12 22 f0 00 	movb   $0x0,0xf02212d4
f0103d65:	c6 05 d5 12 22 f0 8e 	movb   $0x8e,0xf02212d5
f0103d6c:	c1 e8 10             	shr    $0x10,%eax
f0103d6f:	66 a3 d6 12 22 f0    	mov    %ax,0xf02212d6
	SETGATE(idt[T_FPERR], false, GD_KT, trap_16, 0);
f0103d75:	b8 44 44 10 f0       	mov    $0xf0104444,%eax
f0103d7a:	66 a3 e0 12 22 f0    	mov    %ax,0xf02212e0
f0103d80:	66 c7 05 e2 12 22 f0 	movw   $0x8,0xf02212e2
f0103d87:	08 00 
f0103d89:	c6 05 e4 12 22 f0 00 	movb   $0x0,0xf02212e4
f0103d90:	c6 05 e5 12 22 f0 8e 	movb   $0x8e,0xf02212e5
f0103d97:	c1 e8 10             	shr    $0x10,%eax
f0103d9a:	66 a3 e6 12 22 f0    	mov    %ax,0xf02212e6
	SETGATE(idt[T_ALIGN], false, GD_KT, trap_17, 0);
f0103da0:	b8 4a 44 10 f0       	mov    $0xf010444a,%eax
f0103da5:	66 a3 e8 12 22 f0    	mov    %ax,0xf02212e8
f0103dab:	66 c7 05 ea 12 22 f0 	movw   $0x8,0xf02212ea
f0103db2:	08 00 
f0103db4:	c6 05 ec 12 22 f0 00 	movb   $0x0,0xf02212ec
f0103dbb:	c6 05 ed 12 22 f0 8e 	movb   $0x8e,0xf02212ed
f0103dc2:	c1 e8 10             	shr    $0x10,%eax
f0103dc5:	66 a3 ee 12 22 f0    	mov    %ax,0xf02212ee
	SETGATE(idt[T_MCHK], false, GD_KT, trap_18, 0);
f0103dcb:	b8 4e 44 10 f0       	mov    $0xf010444e,%eax
f0103dd0:	66 a3 f0 12 22 f0    	mov    %ax,0xf02212f0
f0103dd6:	66 c7 05 f2 12 22 f0 	movw   $0x8,0xf02212f2
f0103ddd:	08 00 
f0103ddf:	c6 05 f4 12 22 f0 00 	movb   $0x0,0xf02212f4
f0103de6:	c6 05 f5 12 22 f0 8e 	movb   $0x8e,0xf02212f5
f0103ded:	c1 e8 10             	shr    $0x10,%eax
f0103df0:	66 a3 f6 12 22 f0    	mov    %ax,0xf02212f6
	SETGATE(idt[T_SIMDERR], false, GD_KT, trap_19, 0);
f0103df6:	b8 54 44 10 f0       	mov    $0xf0104454,%eax
f0103dfb:	66 a3 f8 12 22 f0    	mov    %ax,0xf02212f8
f0103e01:	66 c7 05 fa 12 22 f0 	movw   $0x8,0xf02212fa
f0103e08:	08 00 
f0103e0a:	c6 05 fc 12 22 f0 00 	movb   $0x0,0xf02212fc
f0103e11:	c6 05 fd 12 22 f0 8e 	movb   $0x8e,0xf02212fd
f0103e18:	c1 e8 10             	shr    $0x10,%eax
f0103e1b:	66 a3 fe 12 22 f0    	mov    %ax,0xf02212fe
	SETGATE(idt[T_SYSCALL], false, GD_KT, trap_48, 3);
f0103e21:	b8 5a 44 10 f0       	mov    $0xf010445a,%eax
f0103e26:	66 a3 e0 13 22 f0    	mov    %ax,0xf02213e0
f0103e2c:	66 c7 05 e2 13 22 f0 	movw   $0x8,0xf02213e2
f0103e33:	08 00 
f0103e35:	c6 05 e4 13 22 f0 00 	movb   $0x0,0xf02213e4
f0103e3c:	c6 05 e5 13 22 f0 ee 	movb   $0xee,0xf02213e5
f0103e43:	c1 e8 10             	shr    $0x10,%eax
f0103e46:	66 a3 e6 13 22 f0    	mov    %ax,0xf02213e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], false, GD_KT, (&irq_timer), 3);
f0103e4c:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103e51:	66 a3 60 13 22 f0    	mov    %ax,0xf0221360
f0103e57:	66 c7 05 62 13 22 f0 	movw   $0x8,0xf0221362
f0103e5e:	08 00 
f0103e60:	c6 05 64 13 22 f0 00 	movb   $0x0,0xf0221364
f0103e67:	c6 05 65 13 22 f0 ee 	movb   $0xee,0xf0221365
f0103e6e:	c1 e8 10             	shr    $0x10,%eax
f0103e71:	66 a3 66 13 22 f0    	mov    %ax,0xf0221366
	trap_init_percpu();
f0103e77:	e8 01 fc ff ff       	call   f0103a7d <trap_init_percpu>
}
f0103e7c:	c9                   	leave  
f0103e7d:	c3                   	ret    

f0103e7e <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e7e:	f3 0f 1e fb          	endbr32 
f0103e82:	55                   	push   %ebp
f0103e83:	89 e5                	mov    %esp,%ebp
f0103e85:	53                   	push   %ebx
f0103e86:	83 ec 0c             	sub    $0xc,%esp
f0103e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e8c:	ff 33                	pushl  (%ebx)
f0103e8e:	68 c7 78 10 f0       	push   $0xf01078c7
f0103e93:	e8 73 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e98:	83 c4 08             	add    $0x8,%esp
f0103e9b:	ff 73 04             	pushl  0x4(%ebx)
f0103e9e:	68 d6 78 10 f0       	push   $0xf01078d6
f0103ea3:	e8 63 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ea8:	83 c4 08             	add    $0x8,%esp
f0103eab:	ff 73 08             	pushl  0x8(%ebx)
f0103eae:	68 e5 78 10 f0       	push   $0xf01078e5
f0103eb3:	e8 53 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103eb8:	83 c4 08             	add    $0x8,%esp
f0103ebb:	ff 73 0c             	pushl  0xc(%ebx)
f0103ebe:	68 f4 78 10 f0       	push   $0xf01078f4
f0103ec3:	e8 43 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103ec8:	83 c4 08             	add    $0x8,%esp
f0103ecb:	ff 73 10             	pushl  0x10(%ebx)
f0103ece:	68 03 79 10 f0       	push   $0xf0107903
f0103ed3:	e8 33 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ed8:	83 c4 08             	add    $0x8,%esp
f0103edb:	ff 73 14             	pushl  0x14(%ebx)
f0103ede:	68 12 79 10 f0       	push   $0xf0107912
f0103ee3:	e8 23 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ee8:	83 c4 08             	add    $0x8,%esp
f0103eeb:	ff 73 18             	pushl  0x18(%ebx)
f0103eee:	68 21 79 10 f0       	push   $0xf0107921
f0103ef3:	e8 13 fb ff ff       	call   f0103a0b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ef8:	83 c4 08             	add    $0x8,%esp
f0103efb:	ff 73 1c             	pushl  0x1c(%ebx)
f0103efe:	68 30 79 10 f0       	push   $0xf0107930
f0103f03:	e8 03 fb ff ff       	call   f0103a0b <cprintf>
}
f0103f08:	83 c4 10             	add    $0x10,%esp
f0103f0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f0e:	c9                   	leave  
f0103f0f:	c3                   	ret    

f0103f10 <print_trapframe>:
{
f0103f10:	f3 0f 1e fb          	endbr32 
f0103f14:	55                   	push   %ebp
f0103f15:	89 e5                	mov    %esp,%ebp
f0103f17:	56                   	push   %esi
f0103f18:	53                   	push   %ebx
f0103f19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f1c:	e8 83 1f 00 00       	call   f0105ea4 <cpunum>
f0103f21:	83 ec 04             	sub    $0x4,%esp
f0103f24:	50                   	push   %eax
f0103f25:	53                   	push   %ebx
f0103f26:	68 66 79 10 f0       	push   $0xf0107966
f0103f2b:	e8 db fa ff ff       	call   f0103a0b <cprintf>
	print_regs(&tf->tf_regs);
f0103f30:	89 1c 24             	mov    %ebx,(%esp)
f0103f33:	e8 46 ff ff ff       	call   f0103e7e <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f38:	83 c4 08             	add    $0x8,%esp
f0103f3b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f3f:	50                   	push   %eax
f0103f40:	68 84 79 10 f0       	push   $0xf0107984
f0103f45:	e8 c1 fa ff ff       	call   f0103a0b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f4a:	83 c4 08             	add    $0x8,%esp
f0103f4d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f51:	50                   	push   %eax
f0103f52:	68 97 79 10 f0       	push   $0xf0107997
f0103f57:	e8 af fa ff ff       	call   f0103a0b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f5c:	8b 73 28             	mov    0x28(%ebx),%esi
f0103f5f:	89 f0                	mov    %esi,%eax
f0103f61:	e8 d4 fa ff ff       	call   f0103a3a <trapname>
f0103f66:	83 c4 0c             	add    $0xc,%esp
f0103f69:	50                   	push   %eax
f0103f6a:	56                   	push   %esi
f0103f6b:	68 aa 79 10 f0       	push   $0xf01079aa
f0103f70:	e8 96 fa ff ff       	call   f0103a0b <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f75:	83 c4 10             	add    $0x10,%esp
f0103f78:	39 1d 60 1a 22 f0    	cmp    %ebx,0xf0221a60
f0103f7e:	0f 84 9f 00 00 00    	je     f0104023 <print_trapframe+0x113>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f84:	83 ec 08             	sub    $0x8,%esp
f0103f87:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f8a:	68 cb 79 10 f0       	push   $0xf01079cb
f0103f8f:	e8 77 fa ff ff       	call   f0103a0b <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f94:	83 c4 10             	add    $0x10,%esp
f0103f97:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f9b:	0f 85 a7 00 00 00    	jne    f0104048 <print_trapframe+0x138>
		        tf->tf_err & 1 ? "protection" : "not-present");
f0103fa1:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103fa4:	a8 01                	test   $0x1,%al
f0103fa6:	b9 3f 79 10 f0       	mov    $0xf010793f,%ecx
f0103fab:	ba 4a 79 10 f0       	mov    $0xf010794a,%edx
f0103fb0:	0f 44 ca             	cmove  %edx,%ecx
f0103fb3:	a8 02                	test   $0x2,%al
f0103fb5:	be 56 79 10 f0       	mov    $0xf0107956,%esi
f0103fba:	ba 5c 79 10 f0       	mov    $0xf010795c,%edx
f0103fbf:	0f 45 d6             	cmovne %esi,%edx
f0103fc2:	a8 04                	test   $0x4,%al
f0103fc4:	b8 61 79 10 f0       	mov    $0xf0107961,%eax
f0103fc9:	be 88 7a 10 f0       	mov    $0xf0107a88,%esi
f0103fce:	0f 44 c6             	cmove  %esi,%eax
f0103fd1:	51                   	push   %ecx
f0103fd2:	52                   	push   %edx
f0103fd3:	50                   	push   %eax
f0103fd4:	68 d9 79 10 f0       	push   $0xf01079d9
f0103fd9:	e8 2d fa ff ff       	call   f0103a0b <cprintf>
f0103fde:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fe1:	83 ec 08             	sub    $0x8,%esp
f0103fe4:	ff 73 30             	pushl  0x30(%ebx)
f0103fe7:	68 e8 79 10 f0       	push   $0xf01079e8
f0103fec:	e8 1a fa ff ff       	call   f0103a0b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ff1:	83 c4 08             	add    $0x8,%esp
f0103ff4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ff8:	50                   	push   %eax
f0103ff9:	68 f7 79 10 f0       	push   $0xf01079f7
f0103ffe:	e8 08 fa ff ff       	call   f0103a0b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104003:	83 c4 08             	add    $0x8,%esp
f0104006:	ff 73 38             	pushl  0x38(%ebx)
f0104009:	68 0a 7a 10 f0       	push   $0xf0107a0a
f010400e:	e8 f8 f9 ff ff       	call   f0103a0b <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104013:	83 c4 10             	add    $0x10,%esp
f0104016:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010401a:	75 3e                	jne    f010405a <print_trapframe+0x14a>
}
f010401c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010401f:	5b                   	pop    %ebx
f0104020:	5e                   	pop    %esi
f0104021:	5d                   	pop    %ebp
f0104022:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104023:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104027:	0f 85 57 ff ff ff    	jne    f0103f84 <print_trapframe+0x74>
		cprintf("  cr2  0x%08x\n", rcr2());
f010402d:	e8 f9 f9 ff ff       	call   f0103a2b <rcr2>
f0104032:	83 ec 08             	sub    $0x8,%esp
f0104035:	50                   	push   %eax
f0104036:	68 bc 79 10 f0       	push   $0xf01079bc
f010403b:	e8 cb f9 ff ff       	call   f0103a0b <cprintf>
f0104040:	83 c4 10             	add    $0x10,%esp
f0104043:	e9 3c ff ff ff       	jmp    f0103f84 <print_trapframe+0x74>
		cprintf("\n");
f0104048:	83 ec 0c             	sub    $0xc,%esp
f010404b:	68 f5 77 10 f0       	push   $0xf01077f5
f0104050:	e8 b6 f9 ff ff       	call   f0103a0b <cprintf>
f0104055:	83 c4 10             	add    $0x10,%esp
f0104058:	eb 87                	jmp    f0103fe1 <print_trapframe+0xd1>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010405a:	83 ec 08             	sub    $0x8,%esp
f010405d:	ff 73 3c             	pushl  0x3c(%ebx)
f0104060:	68 19 7a 10 f0       	push   $0xf0107a19
f0104065:	e8 a1 f9 ff ff       	call   f0103a0b <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010406a:	83 c4 08             	add    $0x8,%esp
f010406d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104071:	50                   	push   %eax
f0104072:	68 28 7a 10 f0       	push   $0xf0107a28
f0104077:	e8 8f f9 ff ff       	call   f0103a0b <cprintf>
f010407c:	83 c4 10             	add    $0x10,%esp
}
f010407f:	eb 9b                	jmp    f010401c <print_trapframe+0x10c>

f0104081 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104081:	f3 0f 1e fb          	endbr32 
f0104085:	55                   	push   %ebp
f0104086:	89 e5                	mov    %esp,%ebp
f0104088:	57                   	push   %edi
f0104089:	56                   	push   %esi
f010408a:	53                   	push   %ebx
f010408b:	83 ec 0c             	sub    $0xc,%esp
f010408e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f0104091:	e8 95 f9 ff ff       	call   f0103a2b <rcr2>

	// Handle kernel-mode page faults.
	if ((tf->tf_cs & 3) == 0)
f0104096:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010409a:	74 69                	je     f0104105 <page_fault_handler+0x84>
f010409c:	89 c6                	mov    %eax,%esi
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall && tf->tf_esp != USTACKTOP) {
f010409e:	e8 01 1e 00 00       	call   f0105ea4 <cpunum>
f01040a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a6:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01040ac:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01040b0:	74 0a                	je     f01040bc <page_fault_handler+0x3b>
f01040b2:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040b5:	3d 00 e0 bf ee       	cmp    $0xeebfe000,%eax
f01040ba:	75 60                	jne    f010411c <page_fault_handler+0x9b>

		env_run(curenv);

	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01040bc:	8b 7b 30             	mov    0x30(%ebx),%edi
		        curenv->env_id,
f01040bf:	e8 e0 1d 00 00       	call   f0105ea4 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01040c4:	57                   	push   %edi
f01040c5:	56                   	push   %esi
		        curenv->env_id,
f01040c6:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01040c9:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01040cf:	ff 70 48             	pushl  0x48(%eax)
f01040d2:	68 f4 7b 10 f0       	push   $0xf0107bf4
f01040d7:	e8 2f f9 ff ff       	call   f0103a0b <cprintf>
		        fault_va,
		        tf->tf_eip);
		print_trapframe(tf);
f01040dc:	89 1c 24             	mov    %ebx,(%esp)
f01040df:	e8 2c fe ff ff       	call   f0103f10 <print_trapframe>
		env_destroy(curenv);
f01040e4:	e8 bb 1d 00 00       	call   f0105ea4 <cpunum>
f01040e9:	83 c4 04             	add    $0x4,%esp
f01040ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ef:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01040f5:	e8 6b f5 ff ff       	call   f0103665 <env_destroy>
	}
}
f01040fa:	83 c4 10             	add    $0x10,%esp
f01040fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104100:	5b                   	pop    %ebx
f0104101:	5e                   	pop    %esi
f0104102:	5f                   	pop    %edi
f0104103:	5d                   	pop    %ebp
f0104104:	c3                   	ret    
		panic("Kernel page fault");
f0104105:	83 ec 04             	sub    $0x4,%esp
f0104108:	68 3b 7a 10 f0       	push   $0xf0107a3b
f010410d:	68 76 01 00 00       	push   $0x176
f0104112:	68 4d 7a 10 f0       	push   $0xf0107a4d
f0104117:	e8 4e bf ff ff       	call   f010006a <_panic>
		if (tf->tf_esp < USTACKTOP && tf->tf_esp >= USTACKTOP - PGSIZE) {
f010411c:	8d 90 00 30 40 11    	lea    0x11403000(%eax),%edx
			u = (struct UTrapframe *) (UXSTACKTOP -
f0104122:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if (tf->tf_esp < USTACKTOP && tf->tf_esp >= USTACKTOP - PGSIZE) {
f0104127:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010412d:	76 05                	jbe    f0104134 <page_fault_handler+0xb3>
			u = (struct UTrapframe *) (tf->tf_esp - 4 -
f010412f:	83 e8 38             	sub    $0x38,%eax
f0104132:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (void *) u, sizeof(struct UTrapframe), PTE_W);
f0104134:	e8 6b 1d 00 00       	call   f0105ea4 <cpunum>
f0104139:	6a 02                	push   $0x2
f010413b:	6a 34                	push   $0x34
f010413d:	57                   	push   %edi
f010413e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104141:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104147:	e8 4d ee ff ff       	call   f0102f99 <user_mem_assert>
		u->utf_fault_va = fault_va;
f010414c:	89 fa                	mov    %edi,%edx
f010414e:	89 37                	mov    %esi,(%edi)
		u->utf_err = tf->tf_err;
f0104150:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104153:	89 47 04             	mov    %eax,0x4(%edi)
		u->utf_regs = tf->tf_regs;
f0104156:	8d 7f 08             	lea    0x8(%edi),%edi
f0104159:	b9 08 00 00 00       	mov    $0x8,%ecx
f010415e:	89 de                	mov    %ebx,%esi
f0104160:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		u->utf_eip = tf->tf_eip;
f0104162:	8b 43 30             	mov    0x30(%ebx),%eax
f0104165:	89 42 28             	mov    %eax,0x28(%edx)
		u->utf_eflags = tf->tf_eflags;
f0104168:	8b 43 38             	mov    0x38(%ebx),%eax
f010416b:	89 d7                	mov    %edx,%edi
f010416d:	89 42 2c             	mov    %eax,0x2c(%edx)
		u->utf_esp = tf->tf_esp;
f0104170:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104173:	89 42 30             	mov    %eax,0x30(%edx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104176:	e8 29 1d 00 00       	call   f0105ea4 <cpunum>
f010417b:	6b c0 74             	imul   $0x74,%eax,%eax
f010417e:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104184:	8b 40 64             	mov    0x64(%eax),%eax
f0104187:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t) u;
f010418a:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		env_run(curenv);
f010418d:	e8 12 1d 00 00       	call   f0105ea4 <cpunum>
f0104192:	83 c4 04             	add    $0x4,%esp
f0104195:	6b c0 74             	imul   $0x74,%eax,%eax
f0104198:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f010419e:	e8 69 f5 ff ff       	call   f010370c <env_run>

f01041a3 <trap_dispatch>:
{
f01041a3:	55                   	push   %ebp
f01041a4:	89 e5                	mov    %esp,%ebp
f01041a6:	53                   	push   %ebx
f01041a7:	83 ec 04             	sub    $0x4,%esp
f01041aa:	89 c3                	mov    %eax,%ebx
	switch (tf->tf_trapno) {
f01041ac:	8b 40 28             	mov    0x28(%eax),%eax
f01041af:	83 f8 0e             	cmp    $0xe,%eax
f01041b2:	74 60                	je     f0104214 <trap_dispatch+0x71>
f01041b4:	83 f8 30             	cmp    $0x30,%eax
f01041b7:	74 7a                	je     f0104233 <trap_dispatch+0x90>
f01041b9:	83 f8 03             	cmp    $0x3,%eax
f01041bc:	74 67                	je     f0104225 <trap_dispatch+0x82>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041be:	83 f8 27             	cmp    $0x27,%eax
f01041c1:	0f 84 8d 00 00 00    	je     f0104254 <trap_dispatch+0xb1>
	if (tf->tf_trapno == IRQ_OFFSET) {
f01041c7:	83 f8 20             	cmp    $0x20,%eax
f01041ca:	0f 84 9e 00 00 00    	je     f010426e <trap_dispatch+0xcb>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f01041d0:	83 f8 21             	cmp    $0x21,%eax
f01041d3:	0f 84 9f 00 00 00    	je     f0104278 <trap_dispatch+0xd5>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f01041d9:	83 f8 24             	cmp    $0x24,%eax
f01041dc:	0f 84 a0 00 00 00    	je     f0104282 <trap_dispatch+0xdf>
	print_trapframe(tf);
f01041e2:	83 ec 0c             	sub    $0xc,%esp
f01041e5:	53                   	push   %ebx
f01041e6:	e8 25 fd ff ff       	call   f0103f10 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01041eb:	83 c4 10             	add    $0x10,%esp
f01041ee:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01041f3:	0f 84 93 00 00 00    	je     f010428c <trap_dispatch+0xe9>
		env_destroy(curenv);
f01041f9:	e8 a6 1c 00 00       	call   f0105ea4 <cpunum>
f01041fe:	83 ec 0c             	sub    $0xc,%esp
f0104201:	6b c0 74             	imul   $0x74,%eax,%eax
f0104204:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f010420a:	e8 56 f4 ff ff       	call   f0103665 <env_destroy>
		return;
f010420f:	83 c4 10             	add    $0x10,%esp
f0104212:	eb 0c                	jmp    f0104220 <trap_dispatch+0x7d>
		page_fault_handler(tf);
f0104214:	83 ec 0c             	sub    $0xc,%esp
f0104217:	53                   	push   %ebx
f0104218:	e8 64 fe ff ff       	call   f0104081 <page_fault_handler>
		return;
f010421d:	83 c4 10             	add    $0x10,%esp
}
f0104220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104223:	c9                   	leave  
f0104224:	c3                   	ret    
		monitor(tf);
f0104225:	83 ec 0c             	sub    $0xc,%esp
f0104228:	53                   	push   %ebx
f0104229:	e8 c7 c9 ff ff       	call   f0100bf5 <monitor>
		return;
f010422e:	83 c4 10             	add    $0x10,%esp
f0104231:	eb ed                	jmp    f0104220 <trap_dispatch+0x7d>
		int res = syscall(registers->reg_eax,
f0104233:	83 ec 08             	sub    $0x8,%esp
f0104236:	ff 73 04             	pushl  0x4(%ebx)
f0104239:	ff 33                	pushl  (%ebx)
f010423b:	ff 73 10             	pushl  0x10(%ebx)
f010423e:	ff 73 18             	pushl  0x18(%ebx)
f0104241:	ff 73 14             	pushl  0x14(%ebx)
f0104244:	ff 73 1c             	pushl  0x1c(%ebx)
f0104247:	e8 4a 09 00 00       	call   f0104b96 <syscall>
		registers->reg_eax = res;
f010424c:	89 43 1c             	mov    %eax,0x1c(%ebx)
		return;
f010424f:	83 c4 20             	add    $0x20,%esp
f0104252:	eb cc                	jmp    f0104220 <trap_dispatch+0x7d>
		cprintf("Spurious interrupt on irq 7\n");
f0104254:	83 ec 0c             	sub    $0xc,%esp
f0104257:	68 59 7a 10 f0       	push   $0xf0107a59
f010425c:	e8 aa f7 ff ff       	call   f0103a0b <cprintf>
		print_trapframe(tf);
f0104261:	89 1c 24             	mov    %ebx,(%esp)
f0104264:	e8 a7 fc ff ff       	call   f0103f10 <print_trapframe>
		return;
f0104269:	83 c4 10             	add    $0x10,%esp
f010426c:	eb b2                	jmp    f0104220 <trap_dispatch+0x7d>
		lapic_eoi();
f010426e:	e8 80 1d 00 00       	call   f0105ff3 <lapic_eoi>
		sched_yield();
f0104273:	e8 04 03 00 00       	call   f010457c <sched_yield>
		kbd_intr();
f0104278:	e8 0c c6 ff ff       	call   f0100889 <kbd_intr>
		sched_yield();
f010427d:	e8 fa 02 00 00       	call   f010457c <sched_yield>
		serial_intr();
f0104282:	e8 e2 c5 ff ff       	call   f0100869 <serial_intr>
		sched_yield();
f0104287:	e8 f0 02 00 00       	call   f010457c <sched_yield>
		panic("unhandled trap in kernel");
f010428c:	83 ec 04             	sub    $0x4,%esp
f010428f:	68 76 7a 10 f0       	push   $0xf0107a76
f0104294:	68 28 01 00 00       	push   $0x128
f0104299:	68 4d 7a 10 f0       	push   $0xf0107a4d
f010429e:	e8 c7 bd ff ff       	call   f010006a <_panic>

f01042a3 <trap>:
{
f01042a3:	f3 0f 1e fb          	endbr32 
f01042a7:	55                   	push   %ebp
f01042a8:	89 e5                	mov    %esp,%ebp
f01042aa:	57                   	push   %edi
f01042ab:	56                   	push   %esi
f01042ac:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01042af:	fc                   	cld    
	if (panicstr)
f01042b0:	83 3d 80 2e 22 f0 00 	cmpl   $0x0,0xf0222e80
f01042b7:	74 01                	je     f01042ba <trap+0x17>
		asm volatile("hlt");
f01042b9:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01042ba:	e8 e5 1b 00 00       	call   f0105ea4 <cpunum>
f01042bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c2:	05 24 30 22 f0       	add    $0xf0223024,%eax
f01042c7:	ba 01 00 00 00       	mov    $0x1,%edx
f01042cc:	e8 61 f7 ff ff       	call   f0103a32 <xchg>
f01042d1:	83 f8 02             	cmp    $0x2,%eax
f01042d4:	74 52                	je     f0104328 <trap+0x85>
	assert(!(read_eflags() & FL_IF));
f01042d6:	e8 54 f7 ff ff       	call   f0103a2f <read_eflags>
f01042db:	f6 c4 02             	test   $0x2,%ah
f01042de:	75 4f                	jne    f010432f <trap+0x8c>
	if ((tf->tf_cs & 3) == 3) {
f01042e0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01042e4:	83 e0 03             	and    $0x3,%eax
f01042e7:	66 83 f8 03          	cmp    $0x3,%ax
f01042eb:	74 5b                	je     f0104348 <trap+0xa5>
	last_tf = tf;
f01042ed:	89 35 60 1a 22 f0    	mov    %esi,0xf0221a60
	trap_dispatch(tf);
f01042f3:	89 f0                	mov    %esi,%eax
f01042f5:	e8 a9 fe ff ff       	call   f01041a3 <trap_dispatch>
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042fa:	e8 a5 1b 00 00       	call   f0105ea4 <cpunum>
f01042ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104302:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0104309:	74 18                	je     f0104323 <trap+0x80>
f010430b:	e8 94 1b 00 00       	call   f0105ea4 <cpunum>
f0104310:	6b c0 74             	imul   $0x74,%eax,%eax
f0104313:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104319:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010431d:	0f 84 bf 00 00 00    	je     f01043e2 <trap+0x13f>
		sched_yield();
f0104323:	e8 54 02 00 00       	call   f010457c <sched_yield>
		lock_kernel();
f0104328:	e8 3b f7 ff ff       	call   f0103a68 <lock_kernel>
f010432d:	eb a7                	jmp    f01042d6 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f010432f:	68 8f 7a 10 f0       	push   $0xf0107a8f
f0104334:	68 e7 74 10 f0       	push   $0xf01074e7
f0104339:	68 42 01 00 00       	push   $0x142
f010433e:	68 4d 7a 10 f0       	push   $0xf0107a4d
f0104343:	e8 22 bd ff ff       	call   f010006a <_panic>
		lock_kernel();
f0104348:	e8 1b f7 ff ff       	call   f0103a68 <lock_kernel>
		assert(curenv);
f010434d:	e8 52 1b 00 00       	call   f0105ea4 <cpunum>
f0104352:	6b c0 74             	imul   $0x74,%eax,%eax
f0104355:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f010435c:	74 3e                	je     f010439c <trap+0xf9>
		if (curenv->env_status == ENV_DYING) {
f010435e:	e8 41 1b 00 00       	call   f0105ea4 <cpunum>
f0104363:	6b c0 74             	imul   $0x74,%eax,%eax
f0104366:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010436c:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104370:	74 43                	je     f01043b5 <trap+0x112>
		curenv->env_tf = *tf;
f0104372:	e8 2d 1b 00 00       	call   f0105ea4 <cpunum>
f0104377:	6b c0 74             	imul   $0x74,%eax,%eax
f010437a:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104380:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104385:	89 c7                	mov    %eax,%edi
f0104387:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104389:	e8 16 1b 00 00       	call   f0105ea4 <cpunum>
f010438e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104391:	8b b0 28 30 22 f0    	mov    -0xfddcfd8(%eax),%esi
f0104397:	e9 51 ff ff ff       	jmp    f01042ed <trap+0x4a>
		assert(curenv);
f010439c:	68 a8 7a 10 f0       	push   $0xf0107aa8
f01043a1:	68 e7 74 10 f0       	push   $0xf01074e7
f01043a6:	68 4a 01 00 00       	push   $0x14a
f01043ab:	68 4d 7a 10 f0       	push   $0xf0107a4d
f01043b0:	e8 b5 bc ff ff       	call   f010006a <_panic>
			env_free(curenv);
f01043b5:	e8 ea 1a 00 00       	call   f0105ea4 <cpunum>
f01043ba:	83 ec 0c             	sub    $0xc,%esp
f01043bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01043c0:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01043c6:	e8 41 f1 ff ff       	call   f010350c <env_free>
			curenv = NULL;
f01043cb:	e8 d4 1a 00 00       	call   f0105ea4 <cpunum>
f01043d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d3:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f01043da:	00 00 00 
			sched_yield();
f01043dd:	e8 9a 01 00 00       	call   f010457c <sched_yield>
		env_run(curenv);
f01043e2:	e8 bd 1a 00 00       	call   f0105ea4 <cpunum>
f01043e7:	83 ec 0c             	sub    $0xc,%esp
f01043ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ed:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01043f3:	e8 14 f3 ff ff       	call   f010370c <env_run>

f01043f8 <trap_0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(trap_0, T_DIVIDE);
f01043f8:	6a 00                	push   $0x0
f01043fa:	6a 00                	push   $0x0
f01043fc:	eb 72                	jmp    f0104470 <_alltraps>

f01043fe <trap_1>:
	TRAPHANDLER_NOEC(trap_1, T_DEBUG);
f01043fe:	6a 00                	push   $0x0
f0104400:	6a 01                	push   $0x1
f0104402:	eb 6c                	jmp    f0104470 <_alltraps>

f0104404 <trap_2>:
	TRAPHANDLER_NOEC(trap_2, T_NMI);
f0104404:	6a 00                	push   $0x0
f0104406:	6a 02                	push   $0x2
f0104408:	eb 66                	jmp    f0104470 <_alltraps>

f010440a <trap_3>:
	TRAPHANDLER_NOEC(trap_3, T_BRKPT);
f010440a:	6a 00                	push   $0x0
f010440c:	6a 03                	push   $0x3
f010440e:	eb 60                	jmp    f0104470 <_alltraps>

f0104410 <trap_4>:
	TRAPHANDLER_NOEC(trap_4, T_OFLOW);
f0104410:	6a 00                	push   $0x0
f0104412:	6a 04                	push   $0x4
f0104414:	eb 5a                	jmp    f0104470 <_alltraps>

f0104416 <trap_5>:
	TRAPHANDLER_NOEC(trap_5, T_BOUND);
f0104416:	6a 00                	push   $0x0
f0104418:	6a 05                	push   $0x5
f010441a:	eb 54                	jmp    f0104470 <_alltraps>

f010441c <trap_6>:
	TRAPHANDLER_NOEC(trap_6, T_ILLOP);
f010441c:	6a 00                	push   $0x0
f010441e:	6a 06                	push   $0x6
f0104420:	eb 4e                	jmp    f0104470 <_alltraps>

f0104422 <trap_7>:
	TRAPHANDLER_NOEC(trap_7, T_DEVICE);
f0104422:	6a 00                	push   $0x0
f0104424:	6a 07                	push   $0x7
f0104426:	eb 48                	jmp    f0104470 <_alltraps>

f0104428 <trap_8>:
	TRAPHANDLER_NOEC(trap_8, T_DBLFLT);
f0104428:	6a 00                	push   $0x0
f010442a:	6a 08                	push   $0x8
f010442c:	eb 42                	jmp    f0104470 <_alltraps>

f010442e <trap_10>:
	TRAPHANDLER_NOEC(trap_10, T_TSS);
f010442e:	6a 00                	push   $0x0
f0104430:	6a 0a                	push   $0xa
f0104432:	eb 3c                	jmp    f0104470 <_alltraps>

f0104434 <trap_11>:
	TRAPHANDLER(trap_11, T_SEGNP);
f0104434:	6a 0b                	push   $0xb
f0104436:	eb 38                	jmp    f0104470 <_alltraps>

f0104438 <trap_12>:
	TRAPHANDLER(trap_12, T_STACK);
f0104438:	6a 0c                	push   $0xc
f010443a:	eb 34                	jmp    f0104470 <_alltraps>

f010443c <trap_13>:
	TRAPHANDLER(trap_13, T_GPFLT);
f010443c:	6a 0d                	push   $0xd
f010443e:	eb 30                	jmp    f0104470 <_alltraps>

f0104440 <trap_14>:
	TRAPHANDLER(trap_14, T_PGFLT);
f0104440:	6a 0e                	push   $0xe
f0104442:	eb 2c                	jmp    f0104470 <_alltraps>

f0104444 <trap_16>:
	TRAPHANDLER_NOEC(trap_16, T_FPERR);
f0104444:	6a 00                	push   $0x0
f0104446:	6a 10                	push   $0x10
f0104448:	eb 26                	jmp    f0104470 <_alltraps>

f010444a <trap_17>:
	TRAPHANDLER(trap_17, T_ALIGN);
f010444a:	6a 11                	push   $0x11
f010444c:	eb 22                	jmp    f0104470 <_alltraps>

f010444e <trap_18>:
	TRAPHANDLER_NOEC(trap_18, T_MCHK);
f010444e:	6a 00                	push   $0x0
f0104450:	6a 12                	push   $0x12
f0104452:	eb 1c                	jmp    f0104470 <_alltraps>

f0104454 <trap_19>:
	TRAPHANDLER_NOEC(trap_19, T_SIMDERR);
f0104454:	6a 00                	push   $0x0
f0104456:	6a 13                	push   $0x13
f0104458:	eb 16                	jmp    f0104470 <_alltraps>

f010445a <trap_48>:

	TRAPHANDLER_NOEC(trap_48, T_SYSCALL);
f010445a:	6a 00                	push   $0x0
f010445c:	6a 30                	push   $0x30
f010445e:	eb 10                	jmp    f0104470 <_alltraps>

f0104460 <trap_500>:
	TRAPHANDLER_NOEC(trap_500, T_DEFAULT);
f0104460:	6a 00                	push   $0x0
f0104462:	68 f4 01 00 00       	push   $0x1f4
f0104467:	eb 07                	jmp    f0104470 <_alltraps>
f0104469:	90                   	nop

f010446a <irq_timer>:

	TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET + IRQ_TIMER);
f010446a:	6a 00                	push   $0x0
f010446c:	6a 20                	push   $0x20
f010446e:	eb 00                	jmp    f0104470 <_alltraps>

f0104470 <_alltraps>:
	/*Pushear todos los registros push*/
	/*pushear ds y es */
	/*antes de llamar a trap, convertir en puntero
	*el struct trapframe para pasarle a trap*/

	pushl %ds
f0104470:	1e                   	push   %ds
	pushl %es
f0104471:	06                   	push   %es
	pushal
f0104472:	60                   	pusha  
	movl $GD_KD, %ax
f0104473:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %ax,%ds
f0104478:	8e d8                	mov    %eax,%ds
	movl %ax,%es
f010447a:	8e c0                	mov    %eax,%es
	pushl %esp
f010447c:	54                   	push   %esp
f010447d:	e8 21 fe ff ff       	call   f01042a3 <trap>

f0104482 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104482:	0f 22 d8             	mov    %eax,%cr3
}
f0104485:	c3                   	ret    

f0104486 <xchg>:
{
f0104486:	89 c1                	mov    %eax,%ecx
f0104488:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f010448a:	f0 87 01             	lock xchg %eax,(%ecx)
}
f010448d:	c3                   	ret    

f010448e <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f010448e:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0104494:	76 07                	jbe    f010449d <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0104496:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f010449c:	c3                   	ret    
{
f010449d:	55                   	push   %ebp
f010449e:	89 e5                	mov    %esp,%ebp
f01044a0:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044a3:	51                   	push   %ecx
f01044a4:	68 b0 65 10 f0       	push   $0xf01065b0
f01044a9:	52                   	push   %edx
f01044aa:	50                   	push   %eax
f01044ab:	e8 ba bb ff ff       	call   f010006a <_panic>

f01044b0 <unlock_kernel>:
{
f01044b0:	55                   	push   %ebp
f01044b1:	89 e5                	mov    %esp,%ebp
f01044b3:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f01044b6:	68 c0 23 12 f0       	push   $0xf01223c0
f01044bb:	e8 4f 1d 00 00       	call   f010620f <spin_unlock>
	asm volatile("pause");
f01044c0:	f3 90                	pause  
}
f01044c2:	83 c4 10             	add    $0x10,%esp
f01044c5:	c9                   	leave  
f01044c6:	c3                   	ret    

f01044c7 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044c7:	f3 0f 1e fb          	endbr32 
f01044cb:	55                   	push   %ebp
f01044cc:	89 e5                	mov    %esp,%ebp
f01044ce:	83 ec 08             	sub    $0x8,%esp
f01044d1:	a1 44 12 22 f0       	mov    0xf0221244,%eax
f01044d6:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044d9:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044de:	8b 02                	mov    (%edx),%eax
f01044e0:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044e3:	83 f8 02             	cmp    $0x2,%eax
f01044e6:	76 2d                	jbe    f0104515 <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f01044e8:	83 c1 01             	add    $0x1,%ecx
f01044eb:	83 c2 7c             	add    $0x7c,%edx
f01044ee:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044f4:	75 e8                	jne    f01044de <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044f6:	83 ec 0c             	sub    $0xc,%esp
f01044f9:	68 70 7c 10 f0       	push   $0xf0107c70
f01044fe:	e8 08 f5 ff ff       	call   f0103a0b <cprintf>
f0104503:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104506:	83 ec 0c             	sub    $0xc,%esp
f0104509:	6a 00                	push   $0x0
f010450b:	e8 e5 c6 ff ff       	call   f0100bf5 <monitor>
f0104510:	83 c4 10             	add    $0x10,%esp
f0104513:	eb f1                	jmp    f0104506 <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104515:	e8 8a 19 00 00       	call   f0105ea4 <cpunum>
f010451a:	6b c0 74             	imul   $0x74,%eax,%eax
f010451d:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f0104524:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104527:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f010452d:	ba 4b 00 00 00       	mov    $0x4b,%edx
f0104532:	b8 99 7c 10 f0       	mov    $0xf0107c99,%eax
f0104537:	e8 52 ff ff ff       	call   f010448e <_paddr>
f010453c:	e8 41 ff ff ff       	call   f0104482 <lcr3>

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104541:	e8 5e 19 00 00       	call   f0105ea4 <cpunum>
f0104546:	6b c0 74             	imul   $0x74,%eax,%eax
f0104549:	05 24 30 22 f0       	add    $0xf0223024,%eax
f010454e:	ba 02 00 00 00       	mov    $0x2,%edx
f0104553:	e8 2e ff ff ff       	call   f0104486 <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f0104558:	e8 53 ff ff ff       	call   f01044b0 <unlock_kernel>
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
f010455d:	e8 42 19 00 00       	call   f0105ea4 <cpunum>
f0104562:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile("movl $0, %%ebp\n"
f0104565:	8b 80 30 30 22 f0    	mov    -0xfddcfd0(%eax),%eax
f010456b:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104570:	89 c4                	mov    %eax,%esp
f0104572:	6a 00                	push   $0x0
f0104574:	6a 00                	push   $0x0
f0104576:	fb                   	sti    
f0104577:	f4                   	hlt    
f0104578:	eb fd                	jmp    f0104577 <sched_halt+0xb0>
}
f010457a:	c9                   	leave  
f010457b:	c3                   	ret    

f010457c <sched_yield>:
{
f010457c:	f3 0f 1e fb          	endbr32 
f0104580:	55                   	push   %ebp
f0104581:	89 e5                	mov    %esp,%ebp
f0104583:	53                   	push   %ebx
f0104584:	83 ec 04             	sub    $0x4,%esp
	if (curenv)
f0104587:	e8 18 19 00 00       	call   f0105ea4 <cpunum>
f010458c:	6b c0 74             	imul   $0x74,%eax,%eax
	int env_inicial = 0;
f010458f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (curenv)
f0104594:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f010459b:	74 18                	je     f01045b5 <sched_yield+0x39>
		env_inicial = ENVX(curenv->env_id);
f010459d:	e8 02 19 00 00       	call   f0105ea4 <cpunum>
f01045a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a5:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01045ab:	8b 40 48             	mov    0x48(%eax),%eax
f01045ae:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045b3:	89 c3                	mov    %eax,%ebx
		if (envs[env_inicial].env_status == ENV_RUNNABLE) {
f01045b5:	8b 0d 44 12 22 f0    	mov    0xf0221244,%ecx
f01045bb:	ba 00 04 00 00       	mov    $0x400,%edx
		env_inicial = (env_inicial + 1) % NENV;
f01045c0:	8d 43 01             	lea    0x1(%ebx),%eax
f01045c3:	89 c3                	mov    %eax,%ebx
f01045c5:	c1 fb 1f             	sar    $0x1f,%ebx
f01045c8:	c1 eb 16             	shr    $0x16,%ebx
f01045cb:	01 d8                	add    %ebx,%eax
f01045cd:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045d2:	29 d8                	sub    %ebx,%eax
f01045d4:	89 c3                	mov    %eax,%ebx
		if (envs[env_inicial].env_status == ENV_RUNNABLE) {
f01045d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045d9:	01 c8                	add    %ecx,%eax
f01045db:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01045df:	74 34                	je     f0104615 <sched_yield+0x99>
	for (int i = 0; i < NENV; i++) {
f01045e1:	83 ea 01             	sub    $0x1,%edx
f01045e4:	75 da                	jne    f01045c0 <sched_yield+0x44>
	if (curenv) {
f01045e6:	e8 b9 18 00 00       	call   f0105ea4 <cpunum>
f01045eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ee:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f01045f5:	74 14                	je     f010460b <sched_yield+0x8f>
		if (curenv->env_status == ENV_RUNNING)
f01045f7:	e8 a8 18 00 00       	call   f0105ea4 <cpunum>
f01045fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ff:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104605:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104609:	74 13                	je     f010461e <sched_yield+0xa2>
	sched_halt();
f010460b:	e8 b7 fe ff ff       	call   f01044c7 <sched_halt>
}
f0104610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104613:	c9                   	leave  
f0104614:	c3                   	ret    
			env_run(&envs[env_inicial]);
f0104615:	83 ec 0c             	sub    $0xc,%esp
f0104618:	50                   	push   %eax
f0104619:	e8 ee f0 ff ff       	call   f010370c <env_run>
			env_run(curenv);
f010461e:	e8 81 18 00 00       	call   f0105ea4 <cpunum>
f0104623:	83 ec 0c             	sub    $0xc,%esp
f0104626:	6b c0 74             	imul   $0x74,%eax,%eax
f0104629:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f010462f:	e8 d8 f0 ff ff       	call   f010370c <env_run>

f0104634 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104634:	55                   	push   %ebp
f0104635:	89 e5                	mov    %esp,%ebp
f0104637:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f010463a:	e8 65 18 00 00       	call   f0105ea4 <cpunum>
f010463f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104642:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104648:	8b 40 48             	mov    0x48(%eax),%eax
}
f010464b:	c9                   	leave  
f010464c:	c3                   	ret    

f010464d <sys_cputs>:
{
f010464d:	55                   	push   %ebp
f010464e:	89 e5                	mov    %esp,%ebp
f0104650:	56                   	push   %esi
f0104651:	53                   	push   %ebx
f0104652:	89 c6                	mov    %eax,%esi
f0104654:	89 d3                	mov    %edx,%ebx
	user_mem_assert(curenv, s, len, PTE_U);
f0104656:	e8 49 18 00 00       	call   f0105ea4 <cpunum>
f010465b:	6a 04                	push   $0x4
f010465d:	53                   	push   %ebx
f010465e:	56                   	push   %esi
f010465f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104662:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104668:	e8 2c e9 ff ff       	call   f0102f99 <user_mem_assert>
	cprintf("%.*s", len, s);
f010466d:	83 c4 0c             	add    $0xc,%esp
f0104670:	56                   	push   %esi
f0104671:	53                   	push   %ebx
f0104672:	68 a6 7c 10 f0       	push   $0xf0107ca6
f0104677:	e8 8f f3 ff ff       	call   f0103a0b <cprintf>
}
f010467c:	83 c4 10             	add    $0x10,%esp
f010467f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104682:	5b                   	pop    %ebx
f0104683:	5e                   	pop    %esi
f0104684:	5d                   	pop    %ebp
f0104685:	c3                   	ret    

f0104686 <sys_cgetc>:
{
f0104686:	55                   	push   %ebp
f0104687:	89 e5                	mov    %esp,%ebp
f0104689:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f010468c:	e8 33 c2 ff ff       	call   f01008c4 <cons_getc>
}
f0104691:	c9                   	leave  
f0104692:	c3                   	ret    

f0104693 <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0104693:	55                   	push   %ebp
f0104694:	89 e5                	mov    %esp,%ebp
f0104696:	53                   	push   %ebx
f0104697:	83 ec 14             	sub    $0x14,%esp
f010469a:	89 d3                	mov    %edx,%ebx
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE)
f010469c:	8d 52 fe             	lea    -0x2(%edx),%edx
f010469f:	f7 c2 fd ff ff ff    	test   $0xfffffffd,%edx
f01046a5:	75 26                	jne    f01046cd <sys_env_set_status+0x3a>
		return -E_INVAL;
	struct Env *env;
	int ret = envid2env(envid, &env, 1);
f01046a7:	83 ec 04             	sub    $0x4,%esp
f01046aa:	6a 01                	push   $0x1
f01046ac:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01046af:	52                   	push   %edx
f01046b0:	50                   	push   %eax
f01046b1:	e8 cc eb ff ff       	call   f0103282 <envid2env>
	if (ret < 0)
f01046b6:	83 c4 10             	add    $0x10,%esp
f01046b9:	85 c0                	test   %eax,%eax
f01046bb:	78 0b                	js     f01046c8 <sys_env_set_status+0x35>
		return ret;
	env->env_status = status;
f01046bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046c0:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f01046c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046cb:	c9                   	leave  
f01046cc:	c3                   	ret    
		return -E_INVAL;
f01046cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046d2:	eb f4                	jmp    f01046c8 <sys_env_set_status+0x35>

f01046d4 <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f01046d4:	55                   	push   %ebp
f01046d5:	89 e5                	mov    %esp,%ebp
f01046d7:	53                   	push   %ebx
f01046d8:	83 ec 18             	sub    $0x18,%esp
f01046db:	89 d3                	mov    %edx,%ebx
	// LAB 4: Your code here.
	struct Env *env;
	// tercer argumento en 1 para chequear que el currenv tiene permiso
	// para setear el estado de envid a func
	int ret = envid2env(envid, &env, 1);
f01046dd:	6a 01                	push   $0x1
f01046df:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01046e2:	52                   	push   %edx
f01046e3:	50                   	push   %eax
f01046e4:	e8 99 eb ff ff       	call   f0103282 <envid2env>
	if (ret < 0)
f01046e9:	83 c4 10             	add    $0x10,%esp
f01046ec:	85 c0                	test   %eax,%eax
f01046ee:	78 0b                	js     f01046fb <sys_env_set_pgfault_upcall+0x27>
		return ret;
	env->env_pgfault_upcall = func;
f01046f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046f3:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f01046f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046fe:	c9                   	leave  
f01046ff:	c3                   	ret    

f0104700 <sys_env_set_trapframe>:
{
f0104700:	55                   	push   %ebp
f0104701:	89 e5                	mov    %esp,%ebp
f0104703:	57                   	push   %edi
f0104704:	56                   	push   %esi
f0104705:	83 ec 14             	sub    $0x14,%esp
f0104708:	89 d6                	mov    %edx,%esi
	if ((r = envid2env(envid,&env,1))< 0) return r;
f010470a:	6a 01                	push   $0x1
f010470c:	8d 55 f4             	lea    -0xc(%ebp),%edx
f010470f:	52                   	push   %edx
f0104710:	50                   	push   %eax
f0104711:	e8 6c eb ff ff       	call   f0103282 <envid2env>
f0104716:	83 c4 10             	add    $0x10,%esp
f0104719:	85 c0                	test   %eax,%eax
f010471b:	78 19                	js     f0104736 <sys_env_set_trapframe+0x36>
	env->env_tf = *tf;
f010471d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104722:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104725:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f0104727:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010472a:	81 60 38 ff cf ff ff 	andl   $0xffffcfff,0x38(%eax)
	return 0;
f0104731:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104736:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104739:	5e                   	pop    %esi
f010473a:	5f                   	pop    %edi
f010473b:	5d                   	pop    %ebp
f010473c:	c3                   	ret    

f010473d <sys_env_destroy>:
{
f010473d:	55                   	push   %ebp
f010473e:	89 e5                	mov    %esp,%ebp
f0104740:	53                   	push   %ebx
f0104741:	83 ec 18             	sub    $0x18,%esp
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104744:	6a 01                	push   $0x1
f0104746:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104749:	52                   	push   %edx
f010474a:	50                   	push   %eax
f010474b:	e8 32 eb ff ff       	call   f0103282 <envid2env>
f0104750:	83 c4 10             	add    $0x10,%esp
f0104753:	85 c0                	test   %eax,%eax
f0104755:	78 4b                	js     f01047a2 <sys_env_destroy+0x65>
	if (e == curenv)
f0104757:	e8 48 17 00 00       	call   f0105ea4 <cpunum>
f010475c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010475f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104762:	39 90 28 30 22 f0    	cmp    %edx,-0xfddcfd8(%eax)
f0104768:	74 3d                	je     f01047a7 <sys_env_destroy+0x6a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010476a:	8b 5a 48             	mov    0x48(%edx),%ebx
f010476d:	e8 32 17 00 00       	call   f0105ea4 <cpunum>
f0104772:	83 ec 04             	sub    $0x4,%esp
f0104775:	53                   	push   %ebx
f0104776:	6b c0 74             	imul   $0x74,%eax,%eax
f0104779:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010477f:	ff 70 48             	pushl  0x48(%eax)
f0104782:	68 c6 7c 10 f0       	push   $0xf0107cc6
f0104787:	e8 7f f2 ff ff       	call   f0103a0b <cprintf>
f010478c:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f010478f:	83 ec 0c             	sub    $0xc,%esp
f0104792:	ff 75 f4             	pushl  -0xc(%ebp)
f0104795:	e8 cb ee ff ff       	call   f0103665 <env_destroy>
	return 0;
f010479a:	83 c4 10             	add    $0x10,%esp
f010479d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047a5:	c9                   	leave  
f01047a6:	c3                   	ret    
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01047a7:	e8 f8 16 00 00       	call   f0105ea4 <cpunum>
f01047ac:	83 ec 08             	sub    $0x8,%esp
f01047af:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b2:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01047b8:	ff 70 48             	pushl  0x48(%eax)
f01047bb:	68 ab 7c 10 f0       	push   $0xf0107cab
f01047c0:	e8 46 f2 ff ff       	call   f0103a0b <cprintf>
f01047c5:	83 c4 10             	add    $0x10,%esp
f01047c8:	eb c5                	jmp    f010478f <sys_env_destroy+0x52>

f01047ca <sys_yield>:
{
f01047ca:	55                   	push   %ebp
f01047cb:	89 e5                	mov    %esp,%ebp
f01047cd:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f01047d0:	e8 a7 fd ff ff       	call   f010457c <sched_yield>

f01047d5 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f01047d5:	55                   	push   %ebp
f01047d6:	89 e5                	mov    %esp,%ebp
f01047d8:	53                   	push   %ebx
f01047d9:	83 ec 04             	sub    $0x4,%esp
f01047dc:	89 c3                	mov    %eax,%ebx
	curenv->env_status = ENV_NOT_RUNNABLE;
f01047de:	e8 c1 16 00 00       	call   f0105ea4 <cpunum>
f01047e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e6:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01047ec:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = true;
f01047f3:	e8 ac 16 00 00       	call   f0105ea4 <cpunum>
f01047f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01047fb:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104801:	c6 40 68 01          	movb   $0x1,0x68(%eax)

	if (dstva < (void *) UTOP) {
f0104805:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010480b:	77 24                	ja     f0104831 <sys_ipc_recv+0x5c>
		if ((uintptr_t) dstva % PGSIZE != 0)
f010480d:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104813:	74 0b                	je     f0104820 <sys_ipc_recv+0x4b>
	}

	sched_yield();
	// LAB 4: Your code here.
	return 0;
}
f0104815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010481a:	83 c4 04             	add    $0x4,%esp
f010481d:	5b                   	pop    %ebx
f010481e:	5d                   	pop    %ebp
f010481f:	c3                   	ret    
		curenv->env_ipc_dstva = dstva;
f0104820:	e8 7f 16 00 00       	call   f0105ea4 <cpunum>
f0104825:	6b c0 74             	imul   $0x74,%eax,%eax
f0104828:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010482e:	89 58 6c             	mov    %ebx,0x6c(%eax)
	sched_yield();
f0104831:	e8 46 fd ff ff       	call   f010457c <sched_yield>

f0104836 <sys_exofork>:
{
f0104836:	55                   	push   %ebp
f0104837:	89 e5                	mov    %esp,%ebp
f0104839:	57                   	push   %edi
f010483a:	56                   	push   %esi
f010483b:	83 ec 10             	sub    $0x10,%esp
	int e = env_alloc(&env, curenv->env_id);
f010483e:	e8 61 16 00 00       	call   f0105ea4 <cpunum>
f0104843:	83 ec 08             	sub    $0x8,%esp
f0104846:	6b c0 74             	imul   $0x74,%eax,%eax
f0104849:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010484f:	ff 70 48             	pushl  0x48(%eax)
f0104852:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104855:	50                   	push   %eax
f0104856:	e8 48 eb ff ff       	call   f01033a3 <env_alloc>
	if (e < 0)
f010485b:	83 c4 10             	add    $0x10,%esp
f010485e:	85 c0                	test   %eax,%eax
f0104860:	78 2f                	js     f0104891 <sys_exofork+0x5b>
	env->env_status = ENV_NOT_RUNNABLE;
f0104862:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104865:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	env->env_tf = curenv->env_tf;
f010486c:	e8 33 16 00 00       	call   f0105ea4 <cpunum>
f0104871:	6b c0 74             	imul   $0x74,%eax,%eax
f0104874:	8b b0 28 30 22 f0    	mov    -0xfddcfd8(%eax),%esi
f010487a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010487f:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104882:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_regs.reg_eax = 0;
f0104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104887:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env->env_id;
f010488e:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104891:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104894:	5e                   	pop    %esi
f0104895:	5f                   	pop    %edi
f0104896:	5d                   	pop    %ebp
f0104897:	c3                   	ret    

f0104898 <sys_page_alloc>:
{
f0104898:	55                   	push   %ebp
f0104899:	89 e5                	mov    %esp,%ebp
f010489b:	57                   	push   %edi
f010489c:	56                   	push   %esi
f010489d:	53                   	push   %ebx
f010489e:	83 ec 20             	sub    $0x20,%esp
f01048a1:	89 d6                	mov    %edx,%esi
f01048a3:	89 cf                	mov    %ecx,%edi
	int ret = envid2env(envid, &env, 1);
f01048a5:	6a 01                	push   $0x1
f01048a7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01048aa:	52                   	push   %edx
f01048ab:	50                   	push   %eax
f01048ac:	e8 d1 e9 ff ff       	call   f0103282 <envid2env>
f01048b1:	89 c3                	mov    %eax,%ebx
	if (ret < 0)
f01048b3:	83 c4 10             	add    $0x10,%esp
f01048b6:	85 c0                	test   %eax,%eax
f01048b8:	78 4e                	js     f0104908 <sys_page_alloc+0x70>
	if ((va >= (void *) UTOP) || ((uintptr_t) va % PGSIZE != 0))
f01048ba:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01048c0:	77 5e                	ja     f0104920 <sys_page_alloc+0x88>
f01048c2:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f01048c8:	75 5d                	jne    f0104927 <sys_page_alloc+0x8f>
	if ((perm | PTE_SYSCALL) != PTE_SYSCALL)
f01048ca:	89 fb                	mov    %edi,%ebx
f01048cc:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f01048d2:	75 5a                	jne    f010492e <sys_page_alloc+0x96>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01048d4:	83 ec 0c             	sub    $0xc,%esp
f01048d7:	6a 01                	push   $0x1
f01048d9:	e8 f5 c8 ff ff       	call   f01011d3 <page_alloc>
f01048de:	89 c7                	mov    %eax,%edi
	if (!pp)
f01048e0:	83 c4 10             	add    $0x10,%esp
f01048e3:	85 c0                	test   %eax,%eax
f01048e5:	74 4e                	je     f0104935 <sys_page_alloc+0x9d>
	if ((ret = page_insert(env->env_pgdir, pp, va, perm | PTE_U | PTE_P)) < 0) {
f01048e7:	89 d9                	mov    %ebx,%ecx
f01048e9:	83 c9 05             	or     $0x5,%ecx
f01048ec:	51                   	push   %ecx
f01048ed:	56                   	push   %esi
f01048ee:	50                   	push   %eax
f01048ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048f2:	ff 70 60             	pushl  0x60(%eax)
f01048f5:	e8 2a d3 ff ff       	call   f0101c24 <page_insert>
f01048fa:	89 c3                	mov    %eax,%ebx
f01048fc:	83 c4 10             	add    $0x10,%esp
f01048ff:	85 c0                	test   %eax,%eax
f0104901:	78 0f                	js     f0104912 <sys_page_alloc+0x7a>
	return 0;
f0104903:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104908:	89 d8                	mov    %ebx,%eax
f010490a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010490d:	5b                   	pop    %ebx
f010490e:	5e                   	pop    %esi
f010490f:	5f                   	pop    %edi
f0104910:	5d                   	pop    %ebp
f0104911:	c3                   	ret    
		page_free(pp);
f0104912:	83 ec 0c             	sub    $0xc,%esp
f0104915:	57                   	push   %edi
f0104916:	e8 03 c9 ff ff       	call   f010121e <page_free>
		return ret;
f010491b:	83 c4 10             	add    $0x10,%esp
f010491e:	eb e8                	jmp    f0104908 <sys_page_alloc+0x70>
		return -E_INVAL;
f0104920:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104925:	eb e1                	jmp    f0104908 <sys_page_alloc+0x70>
f0104927:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010492c:	eb da                	jmp    f0104908 <sys_page_alloc+0x70>
		return -E_INVAL;
f010492e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104933:	eb d3                	jmp    f0104908 <sys_page_alloc+0x70>
		return -E_NO_MEM;
f0104935:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010493a:	eb cc                	jmp    f0104908 <sys_page_alloc+0x70>

f010493c <sys_page_map>:
{
f010493c:	55                   	push   %ebp
f010493d:	89 e5                	mov    %esp,%ebp
f010493f:	57                   	push   %edi
f0104940:	56                   	push   %esi
f0104941:	53                   	push   %ebx
f0104942:	83 ec 1c             	sub    $0x1c,%esp
f0104945:	8b 7d 08             	mov    0x8(%ebp),%edi
	if ((perm | PTE_SYSCALL) != PTE_SYSCALL)
f0104948:	f7 45 0c f8 f1 ff ff 	testl  $0xfffff1f8,0xc(%ebp)
f010494f:	0f 85 ad 00 00 00    	jne    f0104a02 <sys_page_map+0xc6>
f0104955:	89 d3                	mov    %edx,%ebx
f0104957:	89 ce                	mov    %ecx,%esi
	if ((uintptr_t) srcva >= UTOP || (uintptr_t) srcva % PGSIZE != 0 ||
f0104959:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f010495f:	0f 87 a4 00 00 00    	ja     f0104a09 <sys_page_map+0xcd>
f0104965:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010496b:	0f 85 9f 00 00 00    	jne    f0104a10 <sys_page_map+0xd4>
f0104971:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104977:	0f 87 9a 00 00 00    	ja     f0104a17 <sys_page_map+0xdb>
	    (uintptr_t) dstva >= UTOP || (uintptr_t) dstva % PGSIZE != 0)
f010497d:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104983:	0f 85 95 00 00 00    	jne    f0104a1e <sys_page_map+0xe2>
	if ((ret = envid2env(srcenvid, &srcenv, 1)) < 0)
f0104989:	83 ec 04             	sub    $0x4,%esp
f010498c:	6a 01                	push   $0x1
f010498e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104991:	52                   	push   %edx
f0104992:	50                   	push   %eax
f0104993:	e8 ea e8 ff ff       	call   f0103282 <envid2env>
f0104998:	83 c4 10             	add    $0x10,%esp
f010499b:	85 c0                	test   %eax,%eax
f010499d:	78 5b                	js     f01049fa <sys_page_map+0xbe>
	if ((ret = envid2env(dstenvid, &destenv, 1)) < 0)
f010499f:	83 ec 04             	sub    $0x4,%esp
f01049a2:	6a 01                	push   $0x1
f01049a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049a7:	50                   	push   %eax
f01049a8:	56                   	push   %esi
f01049a9:	e8 d4 e8 ff ff       	call   f0103282 <envid2env>
f01049ae:	83 c4 10             	add    $0x10,%esp
f01049b1:	85 c0                	test   %eax,%eax
f01049b3:	78 45                	js     f01049fa <sys_page_map+0xbe>
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f01049b5:	83 ec 04             	sub    $0x4,%esp
f01049b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01049bb:	50                   	push   %eax
f01049bc:	53                   	push   %ebx
f01049bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c0:	ff 70 60             	pushl  0x60(%eax)
f01049c3:	e8 9c d1 ff ff       	call   f0101b64 <page_lookup>
	if (!pp)
f01049c8:	83 c4 10             	add    $0x10,%esp
f01049cb:	85 c0                	test   %eax,%eax
f01049cd:	74 56                	je     f0104a25 <sys_page_map+0xe9>
	if ((perm & PTE_W) && !(*src_pte & PTE_W))
f01049cf:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f01049d3:	74 08                	je     f01049dd <sys_page_map+0xa1>
f01049d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01049d8:	f6 02 02             	testb  $0x2,(%edx)
f01049db:	74 4f                	je     f0104a2c <sys_page_map+0xf0>
	if ((ret = page_insert(destenv->env_pgdir, pp, dstva, perm)) < 0)
f01049dd:	ff 75 0c             	pushl  0xc(%ebp)
f01049e0:	57                   	push   %edi
f01049e1:	50                   	push   %eax
f01049e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049e5:	ff 70 60             	pushl  0x60(%eax)
f01049e8:	e8 37 d2 ff ff       	call   f0101c24 <page_insert>
f01049ed:	83 c4 10             	add    $0x10,%esp
f01049f0:	85 c0                	test   %eax,%eax
f01049f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01049f7:	0f 4f c2             	cmovg  %edx,%eax
}
f01049fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049fd:	5b                   	pop    %ebx
f01049fe:	5e                   	pop    %esi
f01049ff:	5f                   	pop    %edi
f0104a00:	5d                   	pop    %ebp
f0104a01:	c3                   	ret    
		return -E_INVAL;
f0104a02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a07:	eb f1                	jmp    f01049fa <sys_page_map+0xbe>
		return -E_INVAL;
f0104a09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a0e:	eb ea                	jmp    f01049fa <sys_page_map+0xbe>
f0104a10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a15:	eb e3                	jmp    f01049fa <sys_page_map+0xbe>
f0104a17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a1c:	eb dc                	jmp    f01049fa <sys_page_map+0xbe>
f0104a1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a23:	eb d5                	jmp    f01049fa <sys_page_map+0xbe>
		return -E_INVAL;
f0104a25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a2a:	eb ce                	jmp    f01049fa <sys_page_map+0xbe>
		return -E_INVAL;
f0104a2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a31:	eb c7                	jmp    f01049fa <sys_page_map+0xbe>

f0104a33 <sys_ipc_try_send>:
{
f0104a33:	55                   	push   %ebp
f0104a34:	89 e5                	mov    %esp,%ebp
f0104a36:	56                   	push   %esi
f0104a37:	53                   	push   %ebx
f0104a38:	83 ec 14             	sub    $0x14,%esp
f0104a3b:	89 d6                	mov    %edx,%esi
f0104a3d:	89 cb                	mov    %ecx,%ebx
	int ret = envid2env(envid, &env, 0);
f0104a3f:	6a 00                	push   $0x0
f0104a41:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104a44:	52                   	push   %edx
f0104a45:	50                   	push   %eax
f0104a46:	e8 37 e8 ff ff       	call   f0103282 <envid2env>
	if (ret < 0)
f0104a4b:	83 c4 10             	add    $0x10,%esp
f0104a4e:	85 c0                	test   %eax,%eax
f0104a50:	0f 88 da 00 00 00    	js     f0104b30 <sys_ipc_try_send+0xfd>
	if (env->env_status != ENV_NOT_RUNNABLE)
f0104a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a59:	83 78 54 04          	cmpl   $0x4,0x54(%eax)
f0104a5d:	0f 85 d4 00 00 00    	jne    f0104b37 <sys_ipc_try_send+0x104>
	if ((uintptr_t) srcva < UTOP) {
f0104a63:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104a69:	77 7d                	ja     f0104ae8 <sys_ipc_try_send+0xb5>
			return -E_INVAL;
f0104a6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if ((uintptr_t) srcva % PGSIZE != 0 ||
f0104a70:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104a76:	0f 85 a6 00 00 00    	jne    f0104b22 <sys_ipc_try_send+0xef>
f0104a7c:	f7 45 08 f8 f1 ff ff 	testl  $0xfffff1f8,0x8(%ebp)
f0104a83:	0f 85 99 00 00 00    	jne    f0104b22 <sys_ipc_try_send+0xef>
		        page_lookup(curenv->env_pgdir, srcva, &src_pte);
f0104a89:	e8 16 14 00 00       	call   f0105ea4 <cpunum>
f0104a8e:	83 ec 04             	sub    $0x4,%esp
f0104a91:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0104a94:	52                   	push   %edx
f0104a95:	53                   	push   %ebx
f0104a96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a99:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104a9f:	ff 70 60             	pushl  0x60(%eax)
f0104aa2:	e8 bd d0 ff ff       	call   f0101b64 <page_lookup>
f0104aa7:	89 c2                	mov    %eax,%edx
		if (!pp)
f0104aa9:	83 c4 10             	add    $0x10,%esp
f0104aac:	85 c0                	test   %eax,%eax
f0104aae:	74 79                	je     f0104b29 <sys_ipc_try_send+0xf6>
		if ((perm & PTE_W) && !(*src_pte & PTE_W))
f0104ab0:	f6 45 08 02          	testb  $0x2,0x8(%ebp)
f0104ab4:	74 0d                	je     f0104ac3 <sys_ipc_try_send+0x90>
			return -E_INVAL;
f0104ab6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if ((perm & PTE_W) && !(*src_pte & PTE_W))
f0104abb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104abe:	f6 01 02             	testb  $0x2,(%ecx)
f0104ac1:	74 5f                	je     f0104b22 <sys_ipc_try_send+0xef>
		if (env->env_ipc_dstva != NULL)
f0104ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ac6:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0104ac9:	85 c9                	test   %ecx,%ecx
f0104acb:	74 1b                	je     f0104ae8 <sys_ipc_try_send+0xb5>
			if ((page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) <
f0104acd:	ff 75 08             	pushl  0x8(%ebp)
f0104ad0:	51                   	push   %ecx
f0104ad1:	52                   	push   %edx
f0104ad2:	ff 70 60             	pushl  0x60(%eax)
f0104ad5:	e8 4a d1 ff ff       	call   f0101c24 <page_insert>
f0104ada:	89 c2                	mov    %eax,%edx
f0104adc:	83 c4 10             	add    $0x10,%esp
				return -E_NO_MEM;
f0104adf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
			if ((page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) <
f0104ae4:	85 d2                	test   %edx,%edx
f0104ae6:	78 3a                	js     f0104b22 <sys_ipc_try_send+0xef>
	env->env_ipc_recving = 0;
f0104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104aeb:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_from = curenv->env_id;
f0104aef:	e8 b0 13 00 00       	call   f0105ea4 <cpunum>
f0104af4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104af7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afa:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104b00:	8b 40 48             	mov    0x48(%eax),%eax
f0104b03:	89 42 74             	mov    %eax,0x74(%edx)
	env->env_ipc_perm = perm;
f0104b06:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b09:	89 42 78             	mov    %eax,0x78(%edx)
	env->env_ipc_value = value;
f0104b0c:	89 72 70             	mov    %esi,0x70(%edx)
	env->env_status = ENV_RUNNABLE;
f0104b0f:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	env->env_tf.tf_regs.reg_eax = 0;
f0104b16:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	return 0;
f0104b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104b25:	5b                   	pop    %ebx
f0104b26:	5e                   	pop    %esi
f0104b27:	5d                   	pop    %ebp
f0104b28:	c3                   	ret    
			return -E_INVAL;
f0104b29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b2e:	eb f2                	jmp    f0104b22 <sys_ipc_try_send+0xef>
		return -E_BAD_ENV;
f0104b30:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104b35:	eb eb                	jmp    f0104b22 <sys_ipc_try_send+0xef>
		return -E_IPC_NOT_RECV;
f0104b37:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104b3c:	eb e4                	jmp    f0104b22 <sys_ipc_try_send+0xef>

f0104b3e <sys_page_unmap>:
	if ((uintptr_t) va >= UTOP || (uintptr_t) va % PGSIZE != 0)
f0104b3e:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0104b44:	77 43                	ja     f0104b89 <sys_page_unmap+0x4b>
{
f0104b46:	55                   	push   %ebp
f0104b47:	89 e5                	mov    %esp,%ebp
f0104b49:	53                   	push   %ebx
f0104b4a:	83 ec 14             	sub    $0x14,%esp
f0104b4d:	89 d3                	mov    %edx,%ebx
	if ((uintptr_t) va >= UTOP || (uintptr_t) va % PGSIZE != 0)
f0104b4f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0104b55:	75 38                	jne    f0104b8f <sys_page_unmap+0x51>
	if ((ret = envid2env(envid, &env, 1)) < 0)
f0104b57:	83 ec 04             	sub    $0x4,%esp
f0104b5a:	6a 01                	push   $0x1
f0104b5c:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104b5f:	52                   	push   %edx
f0104b60:	50                   	push   %eax
f0104b61:	e8 1c e7 ff ff       	call   f0103282 <envid2env>
f0104b66:	83 c4 10             	add    $0x10,%esp
f0104b69:	85 c0                	test   %eax,%eax
f0104b6b:	78 17                	js     f0104b84 <sys_page_unmap+0x46>
	page_remove(env->env_pgdir, va);
f0104b6d:	83 ec 08             	sub    $0x8,%esp
f0104b70:	53                   	push   %ebx
f0104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b74:	ff 70 60             	pushl  0x60(%eax)
f0104b77:	e8 54 d0 ff ff       	call   f0101bd0 <page_remove>
	return 0;
f0104b7c:	83 c4 10             	add    $0x10,%esp
f0104b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104b87:	c9                   	leave  
f0104b88:	c3                   	ret    
		return -E_INVAL;
f0104b89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0104b8e:	c3                   	ret    
		return -E_INVAL;
f0104b8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b94:	eb ee                	jmp    f0104b84 <sys_page_unmap+0x46>

f0104b96 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104b96:	f3 0f 1e fb          	endbr32 
f0104b9a:	55                   	push   %ebp
f0104b9b:	89 e5                	mov    %esp,%ebp
f0104b9d:	83 ec 08             	sub    $0x8,%esp
f0104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ba3:	83 f8 0d             	cmp    $0xd,%eax
f0104ba6:	0f 87 ca 00 00 00    	ja     f0104c76 <syscall+0xe0>
f0104bac:	3e ff 24 85 e0 7c 10 	notrack jmp *-0xfef8320(,%eax,4)
f0104bb3:	f0 
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char *) a1, a2);
f0104bb4:	8b 55 10             	mov    0x10(%ebp),%edx
f0104bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104bba:	e8 8e fa ff ff       	call   f010464d <sys_cputs>
		return 0;
f0104bbf:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe((envid_t) a1, (struct Trapframe*)a2);
	default:
		return -E_INVAL;
	}
}
f0104bc4:	c9                   	leave  
f0104bc5:	c3                   	ret    
		return sys_cgetc();
f0104bc6:	e8 bb fa ff ff       	call   f0104686 <sys_cgetc>
f0104bcb:	eb f7                	jmp    f0104bc4 <syscall+0x2e>
		return sys_getenvid();
f0104bcd:	e8 62 fa ff ff       	call   f0104634 <sys_getenvid>
f0104bd2:	eb f0                	jmp    f0104bc4 <syscall+0x2e>
		return sys_env_destroy(a1);
f0104bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104bd7:	e8 61 fb ff ff       	call   f010473d <sys_env_destroy>
f0104bdc:	eb e6                	jmp    f0104bc4 <syscall+0x2e>
		sys_yield();
f0104bde:	e8 e7 fb ff ff       	call   f01047ca <sys_yield>
		return sys_exofork();
f0104be3:	e8 4e fc ff ff       	call   f0104836 <sys_exofork>
f0104be8:	eb da                	jmp    f0104bc4 <syscall+0x2e>
		return sys_env_set_status(a1, a2);
f0104bea:	8b 55 10             	mov    0x10(%ebp),%edx
f0104bed:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104bf0:	e8 9e fa ff ff       	call   f0104693 <sys_env_set_status>
f0104bf5:	eb cd                	jmp    f0104bc4 <syscall+0x2e>
		return sys_page_alloc(a1, (void *) a2, a3);
f0104bf7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104bfa:	8b 55 10             	mov    0x10(%ebp),%edx
f0104bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c00:	e8 93 fc ff ff       	call   f0104898 <sys_page_alloc>
f0104c05:	eb bd                	jmp    f0104bc4 <syscall+0x2e>
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f0104c07:	83 ec 08             	sub    $0x8,%esp
f0104c0a:	ff 75 1c             	pushl  0x1c(%ebp)
f0104c0d:	ff 75 18             	pushl  0x18(%ebp)
f0104c10:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104c13:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c19:	e8 1e fd ff ff       	call   f010493c <sys_page_map>
f0104c1e:	83 c4 10             	add    $0x10,%esp
f0104c21:	eb a1                	jmp    f0104bc4 <syscall+0x2e>
		return sys_page_unmap(a1, (void *) a2);
f0104c23:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c29:	e8 10 ff ff ff       	call   f0104b3e <sys_page_unmap>
f0104c2e:	eb 94                	jmp    f0104bc4 <syscall+0x2e>
		return sys_ipc_recv((void *) a1);
f0104c30:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c33:	e8 9d fb ff ff       	call   f01047d5 <sys_ipc_recv>
f0104c38:	eb 8a                	jmp    f0104bc4 <syscall+0x2e>
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
f0104c3a:	83 ec 0c             	sub    $0xc,%esp
f0104c3d:	ff 75 18             	pushl  0x18(%ebp)
f0104c40:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104c43:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c49:	e8 e5 fd ff ff       	call   f0104a33 <sys_ipc_try_send>
f0104c4e:	83 c4 10             	add    $0x10,%esp
f0104c51:	e9 6e ff ff ff       	jmp    f0104bc4 <syscall+0x2e>
		return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
f0104c56:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c59:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c5c:	e8 73 fa ff ff       	call   f01046d4 <sys_env_set_pgfault_upcall>
f0104c61:	e9 5e ff ff ff       	jmp    f0104bc4 <syscall+0x2e>
		return sys_env_set_trapframe((envid_t) a1, (struct Trapframe*)a2);
f0104c66:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c69:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c6c:	e8 8f fa ff ff       	call   f0104700 <sys_env_set_trapframe>
f0104c71:	e9 4e ff ff ff       	jmp    f0104bc4 <syscall+0x2e>
		return 0;
f0104c76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c7b:	e9 44 ff ff ff       	jmp    f0104bc4 <syscall+0x2e>

f0104c80 <stab_binsearch>:
stab_binsearch(const struct Stab *stabs,
               int *region_left,
               int *region_right,
               int type,
               uintptr_t addr)
{
f0104c80:	55                   	push   %ebp
f0104c81:	89 e5                	mov    %esp,%ebp
f0104c83:	57                   	push   %edi
f0104c84:	56                   	push   %esi
f0104c85:	53                   	push   %ebx
f0104c86:	83 ec 14             	sub    $0x14,%esp
f0104c89:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c8f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c92:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c95:	8b 1a                	mov    (%edx),%ebx
f0104c97:	8b 01                	mov    (%ecx),%eax
f0104c99:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c9c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ca3:	eb 23                	jmp    f0104cc8 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {  // no match in [l, m]
			l = true_m + 1;
f0104ca5:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104ca8:	eb 1e                	jmp    f0104cc8 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104caa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cad:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cb0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cb4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cb7:	73 46                	jae    f0104cff <stab_binsearch+0x7f>
			*region_left = m;
f0104cb9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cbc:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cbe:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104cc1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104cc8:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104ccb:	7f 5f                	jg     f0104d2c <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104cd0:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104cd3:	89 d0                	mov    %edx,%eax
f0104cd5:	c1 e8 1f             	shr    $0x1f,%eax
f0104cd8:	01 d0                	add    %edx,%eax
f0104cda:	89 c7                	mov    %eax,%edi
f0104cdc:	d1 ff                	sar    %edi
f0104cde:	83 e0 fe             	and    $0xfffffffe,%eax
f0104ce1:	01 f8                	add    %edi,%eax
f0104ce3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ce6:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104cea:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104cec:	39 c3                	cmp    %eax,%ebx
f0104cee:	7f b5                	jg     f0104ca5 <stab_binsearch+0x25>
f0104cf0:	0f b6 0a             	movzbl (%edx),%ecx
f0104cf3:	83 ea 0c             	sub    $0xc,%edx
f0104cf6:	39 f1                	cmp    %esi,%ecx
f0104cf8:	74 b0                	je     f0104caa <stab_binsearch+0x2a>
			m--;
f0104cfa:	83 e8 01             	sub    $0x1,%eax
f0104cfd:	eb ed                	jmp    f0104cec <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0104cff:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d02:	76 14                	jbe    f0104d18 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104d04:	83 e8 01             	sub    $0x1,%eax
f0104d07:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d0a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d0d:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104d0f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d16:	eb b0                	jmp    f0104cc8 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d1b:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104d1d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d21:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104d23:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d2a:	eb 9c                	jmp    f0104cc8 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104d2c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d30:	75 15                	jne    f0104d47 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104d32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d35:	8b 00                	mov    (%eax),%eax
f0104d37:	83 e8 01             	sub    $0x1,%eax
f0104d3a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d3d:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104d3f:	83 c4 14             	add    $0x14,%esp
f0104d42:	5b                   	pop    %ebx
f0104d43:	5e                   	pop    %esi
f0104d44:	5f                   	pop    %edi
f0104d45:	5d                   	pop    %ebp
f0104d46:	c3                   	ret    
		for (l = *region_right;
f0104d47:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d4a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d4f:	8b 0f                	mov    (%edi),%ecx
f0104d51:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d54:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104d57:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104d5b:	eb 03                	jmp    f0104d60 <stab_binsearch+0xe0>
		     l--)
f0104d5d:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104d60:	39 c1                	cmp    %eax,%ecx
f0104d62:	7d 0a                	jge    f0104d6e <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0104d64:	0f b6 1a             	movzbl (%edx),%ebx
f0104d67:	83 ea 0c             	sub    $0xc,%edx
f0104d6a:	39 f3                	cmp    %esi,%ebx
f0104d6c:	75 ef                	jne    f0104d5d <stab_binsearch+0xdd>
		*region_left = l;
f0104d6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d71:	89 07                	mov    %eax,(%edi)
}
f0104d73:	eb ca                	jmp    f0104d3f <stab_binsearch+0xbf>

f0104d75 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d75:	f3 0f 1e fb          	endbr32 
f0104d79:	55                   	push   %ebp
f0104d7a:	89 e5                	mov    %esp,%ebp
f0104d7c:	57                   	push   %edi
f0104d7d:	56                   	push   %esi
f0104d7e:	53                   	push   %ebx
f0104d7f:	83 ec 4c             	sub    $0x4c,%esp
f0104d82:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d88:	c7 03 18 7d 10 f0    	movl   $0xf0107d18,(%ebx)
	info->eip_line = 0;
f0104d8e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d95:	c7 43 08 18 7d 10 f0 	movl   $0xf0107d18,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d9c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104da3:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104da6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104dad:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104db3:	0f 86 21 01 00 00    	jbe    f0104eda <debuginfo_eip+0x165>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104db9:	c7 45 b8 69 8e 11 f0 	movl   $0xf0118e69,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104dc0:	c7 45 b4 49 4d 11 f0 	movl   $0xf0114d49,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104dc7:	be 48 4d 11 f0       	mov    $0xf0114d48,%esi
		stabs = __STAB_BEGIN__;
f0104dcc:	c7 45 bc b0 82 10 f0 	movl   $0xf01082b0,-0x44(%ebp)
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104dd3:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104dd6:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104dd9:	0f 83 62 02 00 00    	jae    f0105041 <debuginfo_eip+0x2cc>
f0104ddf:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104de3:	0f 85 5f 02 00 00    	jne    f0105048 <debuginfo_eip+0x2d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104de9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104df0:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0104df3:	c1 fe 02             	sar    $0x2,%esi
f0104df6:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104dfc:	83 e8 01             	sub    $0x1,%eax
f0104dff:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e02:	83 ec 08             	sub    $0x8,%esp
f0104e05:	57                   	push   %edi
f0104e06:	6a 64                	push   $0x64
f0104e08:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e0b:	89 d1                	mov    %edx,%ecx
f0104e0d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e10:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104e13:	89 f0                	mov    %esi,%eax
f0104e15:	e8 66 fe ff ff       	call   f0104c80 <stab_binsearch>
	if (lfile == 0)
f0104e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e1d:	83 c4 10             	add    $0x10,%esp
f0104e20:	85 c0                	test   %eax,%eax
f0104e22:	0f 84 27 02 00 00    	je     f010504f <debuginfo_eip+0x2da>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e28:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e31:	83 ec 08             	sub    $0x8,%esp
f0104e34:	57                   	push   %edi
f0104e35:	6a 24                	push   $0x24
f0104e37:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e3a:	89 d1                	mov    %edx,%ecx
f0104e3c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e3f:	89 f0                	mov    %esi,%eax
f0104e41:	e8 3a fe ff ff       	call   f0104c80 <stab_binsearch>

	if (lfun <= rfun) {
f0104e46:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e49:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e4c:	83 c4 10             	add    $0x10,%esp
f0104e4f:	39 d0                	cmp    %edx,%eax
f0104e51:	0f 8f 32 01 00 00    	jg     f0104f89 <debuginfo_eip+0x214>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e57:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104e5a:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104e5d:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e60:	8b 36                	mov    (%esi),%esi
f0104e62:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104e65:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104e68:	39 ce                	cmp    %ecx,%esi
f0104e6a:	73 06                	jae    f0104e72 <debuginfo_eip+0xfd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e6c:	03 75 b4             	add    -0x4c(%ebp),%esi
f0104e6f:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e72:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104e75:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104e78:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e7b:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e7d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e80:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e83:	83 ec 08             	sub    $0x8,%esp
f0104e86:	6a 3a                	push   $0x3a
f0104e88:	ff 73 08             	pushl  0x8(%ebx)
f0104e8b:	e8 63 09 00 00       	call   f01057f3 <strfind>
f0104e90:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e93:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e96:	83 c4 08             	add    $0x8,%esp
f0104e99:	57                   	push   %edi
f0104e9a:	6a 44                	push   $0x44
f0104e9c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e9f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104ea2:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104ea5:	89 f8                	mov    %edi,%eax
f0104ea7:	e8 d4 fd ff ff       	call   f0104c80 <stab_binsearch>
	if (lline <= rline) {
f0104eac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104eaf:	83 c4 10             	add    $0x10,%esp
f0104eb2:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104eb5:	7f 0b                	jg     f0104ec2 <debuginfo_eip+0x14d>
		info->eip_line = stabs[lline].n_desc;
f0104eb7:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104eba:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104ebf:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f0104ec2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ec5:	89 d0                	mov    %edx,%eax
f0104ec7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104eca:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104ecd:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0104ed1:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104ed5:	e9 cd 00 00 00       	jmp    f0104fa7 <debuginfo_eip+0x232>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), 0))
f0104eda:	e8 c5 0f 00 00       	call   f0105ea4 <cpunum>
f0104edf:	6a 00                	push   $0x0
f0104ee1:	6a 10                	push   $0x10
f0104ee3:	68 00 00 20 00       	push   $0x200000
f0104ee8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eeb:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104ef1:	e8 25 e0 ff ff       	call   f0102f1b <user_mem_check>
f0104ef6:	83 c4 10             	add    $0x10,%esp
f0104ef9:	85 c0                	test   %eax,%eax
f0104efb:	0f 85 32 01 00 00    	jne    f0105033 <debuginfo_eip+0x2be>
		stabs = usd->stabs;
f0104f01:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104f07:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104f0a:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104f10:	a1 08 00 20 00       	mov    0x200008,%eax
f0104f15:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104f18:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104f1e:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f0104f21:	e8 7e 0f 00 00       	call   f0105ea4 <cpunum>
f0104f26:	89 c2                	mov    %eax,%edx
f0104f28:	6a 00                	push   $0x0
f0104f2a:	89 f0                	mov    %esi,%eax
f0104f2c:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f2f:	29 c8                	sub    %ecx,%eax
f0104f31:	c1 f8 02             	sar    $0x2,%eax
f0104f34:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104f3a:	50                   	push   %eax
f0104f3b:	51                   	push   %ecx
f0104f3c:	6b d2 74             	imul   $0x74,%edx,%edx
f0104f3f:	ff b2 28 30 22 f0    	pushl  -0xfddcfd8(%edx)
f0104f45:	e8 d1 df ff ff       	call   f0102f1b <user_mem_check>
f0104f4a:	83 c4 10             	add    $0x10,%esp
f0104f4d:	85 c0                	test   %eax,%eax
f0104f4f:	0f 85 e5 00 00 00    	jne    f010503a <debuginfo_eip+0x2c5>
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
f0104f55:	e8 4a 0f 00 00       	call   f0105ea4 <cpunum>
f0104f5a:	6a 00                	push   $0x0
f0104f5c:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104f5f:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0104f62:	29 ca                	sub    %ecx,%edx
f0104f64:	52                   	push   %edx
f0104f65:	51                   	push   %ecx
f0104f66:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f69:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104f6f:	e8 a7 df ff ff       	call   f0102f1b <user_mem_check>
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f0104f74:	83 c4 10             	add    $0x10,%esp
f0104f77:	85 c0                	test   %eax,%eax
f0104f79:	0f 84 54 fe ff ff    	je     f0104dd3 <debuginfo_eip+0x5e>
			return -1;
f0104f7f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0104f84:	e9 d2 00 00 00       	jmp    f010505b <debuginfo_eip+0x2e6>
		info->eip_fn_addr = addr;
f0104f89:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f95:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104f98:	e9 e6 fe ff ff       	jmp    f0104e83 <debuginfo_eip+0x10e>
f0104f9d:	83 e8 01             	sub    $0x1,%eax
f0104fa0:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f0104fa3:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104fa7:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104faa:	39 c7                	cmp    %eax,%edi
f0104fac:	7f 45                	jg     f0104ff3 <debuginfo_eip+0x27e>
f0104fae:	0f b6 0a             	movzbl (%edx),%ecx
f0104fb1:	80 f9 84             	cmp    $0x84,%cl
f0104fb4:	74 19                	je     f0104fcf <debuginfo_eip+0x25a>
f0104fb6:	80 f9 64             	cmp    $0x64,%cl
f0104fb9:	75 e2                	jne    f0104f9d <debuginfo_eip+0x228>
	       (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104fbb:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104fbf:	74 dc                	je     f0104f9d <debuginfo_eip+0x228>
f0104fc1:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104fc5:	74 11                	je     f0104fd8 <debuginfo_eip+0x263>
f0104fc7:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104fca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104fcd:	eb 09                	jmp    f0104fd8 <debuginfo_eip+0x263>
f0104fcf:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104fd3:	74 03                	je     f0104fd8 <debuginfo_eip+0x263>
f0104fd5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104fd8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104fdb:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104fde:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104fe1:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104fe4:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104fe7:	29 f8                	sub    %edi,%eax
f0104fe9:	39 c2                	cmp    %eax,%edx
f0104feb:	73 06                	jae    f0104ff3 <debuginfo_eip+0x27e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104fed:	89 f8                	mov    %edi,%eax
f0104fef:	01 d0                	add    %edx,%eax
f0104ff1:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ff3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ff6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ff9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0104ffe:	39 f0                	cmp    %esi,%eax
f0105000:	7d 59                	jge    f010505b <debuginfo_eip+0x2e6>
		for (lline = lfun + 1;
f0105002:	8d 50 01             	lea    0x1(%eax),%edx
f0105005:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105008:	89 d0                	mov    %edx,%eax
f010500a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010500d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105010:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105014:	eb 04                	jmp    f010501a <debuginfo_eip+0x2a5>
			info->eip_fn_narg++;
f0105016:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f010501a:	39 c6                	cmp    %eax,%esi
f010501c:	7e 38                	jle    f0105056 <debuginfo_eip+0x2e1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010501e:	0f b6 0a             	movzbl (%edx),%ecx
f0105021:	83 c0 01             	add    $0x1,%eax
f0105024:	83 c2 0c             	add    $0xc,%edx
f0105027:	80 f9 a0             	cmp    $0xa0,%cl
f010502a:	74 ea                	je     f0105016 <debuginfo_eip+0x2a1>
	return 0;
f010502c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105031:	eb 28                	jmp    f010505b <debuginfo_eip+0x2e6>
			return -1;
f0105033:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105038:	eb 21                	jmp    f010505b <debuginfo_eip+0x2e6>
			return -1;
f010503a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010503f:	eb 1a                	jmp    f010505b <debuginfo_eip+0x2e6>
		return -1;
f0105041:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105046:	eb 13                	jmp    f010505b <debuginfo_eip+0x2e6>
f0105048:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010504d:	eb 0c                	jmp    f010505b <debuginfo_eip+0x2e6>
		return -1;
f010504f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105054:	eb 05                	jmp    f010505b <debuginfo_eip+0x2e6>
	return 0;
f0105056:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010505b:	89 d0                	mov    %edx,%eax
f010505d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105060:	5b                   	pop    %ebx
f0105061:	5e                   	pop    %esi
f0105062:	5f                   	pop    %edi
f0105063:	5d                   	pop    %ebp
f0105064:	c3                   	ret    

f0105065 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105065:	55                   	push   %ebp
f0105066:	89 e5                	mov    %esp,%ebp
f0105068:	57                   	push   %edi
f0105069:	56                   	push   %esi
f010506a:	53                   	push   %ebx
f010506b:	83 ec 1c             	sub    $0x1c,%esp
f010506e:	89 c7                	mov    %eax,%edi
f0105070:	89 d6                	mov    %edx,%esi
f0105072:	8b 45 08             	mov    0x8(%ebp),%eax
f0105075:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105078:	89 d1                	mov    %edx,%ecx
f010507a:	89 c2                	mov    %eax,%edx
f010507c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010507f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105082:	8b 45 10             	mov    0x10(%ebp),%eax
f0105085:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105088:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010508b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105092:	39 c2                	cmp    %eax,%edx
f0105094:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0105097:	72 3e                	jb     f01050d7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105099:	83 ec 0c             	sub    $0xc,%esp
f010509c:	ff 75 18             	pushl  0x18(%ebp)
f010509f:	83 eb 01             	sub    $0x1,%ebx
f01050a2:	53                   	push   %ebx
f01050a3:	50                   	push   %eax
f01050a4:	83 ec 08             	sub    $0x8,%esp
f01050a7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050aa:	ff 75 e0             	pushl  -0x20(%ebp)
f01050ad:	ff 75 dc             	pushl  -0x24(%ebp)
f01050b0:	ff 75 d8             	pushl  -0x28(%ebp)
f01050b3:	e8 48 12 00 00       	call   f0106300 <__udivdi3>
f01050b8:	83 c4 18             	add    $0x18,%esp
f01050bb:	52                   	push   %edx
f01050bc:	50                   	push   %eax
f01050bd:	89 f2                	mov    %esi,%edx
f01050bf:	89 f8                	mov    %edi,%eax
f01050c1:	e8 9f ff ff ff       	call   f0105065 <printnum>
f01050c6:	83 c4 20             	add    $0x20,%esp
f01050c9:	eb 13                	jmp    f01050de <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01050cb:	83 ec 08             	sub    $0x8,%esp
f01050ce:	56                   	push   %esi
f01050cf:	ff 75 18             	pushl  0x18(%ebp)
f01050d2:	ff d7                	call   *%edi
f01050d4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01050d7:	83 eb 01             	sub    $0x1,%ebx
f01050da:	85 db                	test   %ebx,%ebx
f01050dc:	7f ed                	jg     f01050cb <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050de:	83 ec 08             	sub    $0x8,%esp
f01050e1:	56                   	push   %esi
f01050e2:	83 ec 04             	sub    $0x4,%esp
f01050e5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050e8:	ff 75 e0             	pushl  -0x20(%ebp)
f01050eb:	ff 75 dc             	pushl  -0x24(%ebp)
f01050ee:	ff 75 d8             	pushl  -0x28(%ebp)
f01050f1:	e8 1a 13 00 00       	call   f0106410 <__umoddi3>
f01050f6:	83 c4 14             	add    $0x14,%esp
f01050f9:	0f be 80 22 7d 10 f0 	movsbl -0xfef82de(%eax),%eax
f0105100:	50                   	push   %eax
f0105101:	ff d7                	call   *%edi
}
f0105103:	83 c4 10             	add    $0x10,%esp
f0105106:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105109:	5b                   	pop    %ebx
f010510a:	5e                   	pop    %esi
f010510b:	5f                   	pop    %edi
f010510c:	5d                   	pop    %ebp
f010510d:	c3                   	ret    

f010510e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010510e:	83 fa 01             	cmp    $0x1,%edx
f0105111:	7f 13                	jg     f0105126 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0105113:	85 d2                	test   %edx,%edx
f0105115:	74 1c                	je     f0105133 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f0105117:	8b 10                	mov    (%eax),%edx
f0105119:	8d 4a 04             	lea    0x4(%edx),%ecx
f010511c:	89 08                	mov    %ecx,(%eax)
f010511e:	8b 02                	mov    (%edx),%eax
f0105120:	ba 00 00 00 00       	mov    $0x0,%edx
f0105125:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
f0105126:	8b 10                	mov    (%eax),%edx
f0105128:	8d 4a 08             	lea    0x8(%edx),%ecx
f010512b:	89 08                	mov    %ecx,(%eax)
f010512d:	8b 02                	mov    (%edx),%eax
f010512f:	8b 52 04             	mov    0x4(%edx),%edx
f0105132:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f0105133:	8b 10                	mov    (%eax),%edx
f0105135:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105138:	89 08                	mov    %ecx,(%eax)
f010513a:	8b 02                	mov    (%edx),%eax
f010513c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105141:	c3                   	ret    

f0105142 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105142:	83 fa 01             	cmp    $0x1,%edx
f0105145:	7f 0f                	jg     f0105156 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
f0105147:	85 d2                	test   %edx,%edx
f0105149:	74 18                	je     f0105163 <getint+0x21>
		return va_arg(*ap, long);
f010514b:	8b 10                	mov    (%eax),%edx
f010514d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105150:	89 08                	mov    %ecx,(%eax)
f0105152:	8b 02                	mov    (%edx),%eax
f0105154:	99                   	cltd   
f0105155:	c3                   	ret    
		return va_arg(*ap, long long);
f0105156:	8b 10                	mov    (%eax),%edx
f0105158:	8d 4a 08             	lea    0x8(%edx),%ecx
f010515b:	89 08                	mov    %ecx,(%eax)
f010515d:	8b 02                	mov    (%edx),%eax
f010515f:	8b 52 04             	mov    0x4(%edx),%edx
f0105162:	c3                   	ret    
	else
		return va_arg(*ap, int);
f0105163:	8b 10                	mov    (%eax),%edx
f0105165:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105168:	89 08                	mov    %ecx,(%eax)
f010516a:	8b 02                	mov    (%edx),%eax
f010516c:	99                   	cltd   
}
f010516d:	c3                   	ret    

f010516e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010516e:	f3 0f 1e fb          	endbr32 
f0105172:	55                   	push   %ebp
f0105173:	89 e5                	mov    %esp,%ebp
f0105175:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105178:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010517c:	8b 10                	mov    (%eax),%edx
f010517e:	3b 50 04             	cmp    0x4(%eax),%edx
f0105181:	73 0a                	jae    f010518d <sprintputch+0x1f>
		*b->buf++ = ch;
f0105183:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105186:	89 08                	mov    %ecx,(%eax)
f0105188:	8b 45 08             	mov    0x8(%ebp),%eax
f010518b:	88 02                	mov    %al,(%edx)
}
f010518d:	5d                   	pop    %ebp
f010518e:	c3                   	ret    

f010518f <printfmt>:
{
f010518f:	f3 0f 1e fb          	endbr32 
f0105193:	55                   	push   %ebp
f0105194:	89 e5                	mov    %esp,%ebp
f0105196:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105199:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010519c:	50                   	push   %eax
f010519d:	ff 75 10             	pushl  0x10(%ebp)
f01051a0:	ff 75 0c             	pushl  0xc(%ebp)
f01051a3:	ff 75 08             	pushl  0x8(%ebp)
f01051a6:	e8 05 00 00 00       	call   f01051b0 <vprintfmt>
}
f01051ab:	83 c4 10             	add    $0x10,%esp
f01051ae:	c9                   	leave  
f01051af:	c3                   	ret    

f01051b0 <vprintfmt>:
{
f01051b0:	f3 0f 1e fb          	endbr32 
f01051b4:	55                   	push   %ebp
f01051b5:	89 e5                	mov    %esp,%ebp
f01051b7:	57                   	push   %edi
f01051b8:	56                   	push   %esi
f01051b9:	53                   	push   %ebx
f01051ba:	83 ec 2c             	sub    $0x2c,%esp
f01051bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01051c0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051c3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01051c6:	e9 86 02 00 00       	jmp    f0105451 <vprintfmt+0x2a1>
		padc = ' ';
f01051cb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01051cf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01051d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01051dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01051e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01051e9:	8d 47 01             	lea    0x1(%edi),%eax
f01051ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051ef:	0f b6 17             	movzbl (%edi),%edx
f01051f2:	8d 42 dd             	lea    -0x23(%edx),%eax
f01051f5:	3c 55                	cmp    $0x55,%al
f01051f7:	0f 87 df 02 00 00    	ja     f01054dc <vprintfmt+0x32c>
f01051fd:	0f b6 c0             	movzbl %al,%eax
f0105200:	3e ff 24 85 60 7e 10 	notrack jmp *-0xfef81a0(,%eax,4)
f0105207:	f0 
f0105208:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010520b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010520f:	eb d8                	jmp    f01051e9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0105211:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105214:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105218:	eb cf                	jmp    f01051e9 <vprintfmt+0x39>
f010521a:	0f b6 d2             	movzbl %dl,%edx
f010521d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105220:	b8 00 00 00 00       	mov    $0x0,%eax
f0105225:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105228:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010522b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010522f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105232:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105235:	83 f9 09             	cmp    $0x9,%ecx
f0105238:	77 52                	ja     f010528c <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
f010523a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010523d:	eb e9                	jmp    f0105228 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f010523f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105242:	8d 50 04             	lea    0x4(%eax),%edx
f0105245:	89 55 14             	mov    %edx,0x14(%ebp)
f0105248:	8b 00                	mov    (%eax),%eax
f010524a:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010524d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105250:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105254:	79 93                	jns    f01051e9 <vprintfmt+0x39>
				width = precision, precision = -1;
f0105256:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105259:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010525c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105263:	eb 84                	jmp    f01051e9 <vprintfmt+0x39>
f0105265:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105268:	85 c0                	test   %eax,%eax
f010526a:	ba 00 00 00 00       	mov    $0x0,%edx
f010526f:	0f 49 d0             	cmovns %eax,%edx
f0105272:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105278:	e9 6c ff ff ff       	jmp    f01051e9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010527d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105280:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0105287:	e9 5d ff ff ff       	jmp    f01051e9 <vprintfmt+0x39>
f010528c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010528f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105292:	eb bc                	jmp    f0105250 <vprintfmt+0xa0>
			lflag++;
f0105294:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010529a:	e9 4a ff ff ff       	jmp    f01051e9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f010529f:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a2:	8d 50 04             	lea    0x4(%eax),%edx
f01052a5:	89 55 14             	mov    %edx,0x14(%ebp)
f01052a8:	83 ec 08             	sub    $0x8,%esp
f01052ab:	56                   	push   %esi
f01052ac:	ff 30                	pushl  (%eax)
f01052ae:	ff d3                	call   *%ebx
			break;
f01052b0:	83 c4 10             	add    $0x10,%esp
f01052b3:	e9 96 01 00 00       	jmp    f010544e <vprintfmt+0x29e>
			err = va_arg(ap, int);
f01052b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052bb:	8d 50 04             	lea    0x4(%eax),%edx
f01052be:	89 55 14             	mov    %edx,0x14(%ebp)
f01052c1:	8b 00                	mov    (%eax),%eax
f01052c3:	99                   	cltd   
f01052c4:	31 d0                	xor    %edx,%eax
f01052c6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01052c8:	83 f8 0f             	cmp    $0xf,%eax
f01052cb:	7f 20                	jg     f01052ed <vprintfmt+0x13d>
f01052cd:	8b 14 85 c0 7f 10 f0 	mov    -0xfef8040(,%eax,4),%edx
f01052d4:	85 d2                	test   %edx,%edx
f01052d6:	74 15                	je     f01052ed <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
f01052d8:	52                   	push   %edx
f01052d9:	68 f9 74 10 f0       	push   $0xf01074f9
f01052de:	56                   	push   %esi
f01052df:	53                   	push   %ebx
f01052e0:	e8 aa fe ff ff       	call   f010518f <printfmt>
f01052e5:	83 c4 10             	add    $0x10,%esp
f01052e8:	e9 61 01 00 00       	jmp    f010544e <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f01052ed:	50                   	push   %eax
f01052ee:	68 3a 7d 10 f0       	push   $0xf0107d3a
f01052f3:	56                   	push   %esi
f01052f4:	53                   	push   %ebx
f01052f5:	e8 95 fe ff ff       	call   f010518f <printfmt>
f01052fa:	83 c4 10             	add    $0x10,%esp
f01052fd:	e9 4c 01 00 00       	jmp    f010544e <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
f0105302:	8b 45 14             	mov    0x14(%ebp),%eax
f0105305:	8d 50 04             	lea    0x4(%eax),%edx
f0105308:	89 55 14             	mov    %edx,0x14(%ebp)
f010530b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
f010530d:	85 c9                	test   %ecx,%ecx
f010530f:	b8 33 7d 10 f0       	mov    $0xf0107d33,%eax
f0105314:	0f 45 c1             	cmovne %ecx,%eax
f0105317:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010531a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010531e:	7e 06                	jle    f0105326 <vprintfmt+0x176>
f0105320:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105324:	75 0d                	jne    f0105333 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105326:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105329:	89 c7                	mov    %eax,%edi
f010532b:	03 45 e0             	add    -0x20(%ebp),%eax
f010532e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105331:	eb 57                	jmp    f010538a <vprintfmt+0x1da>
f0105333:	83 ec 08             	sub    $0x8,%esp
f0105336:	ff 75 d8             	pushl  -0x28(%ebp)
f0105339:	ff 75 cc             	pushl  -0x34(%ebp)
f010533c:	e8 41 03 00 00       	call   f0105682 <strnlen>
f0105341:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105344:	29 c2                	sub    %eax,%edx
f0105346:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105349:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010534c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105350:	89 5d 08             	mov    %ebx,0x8(%ebp)
f0105353:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f0105355:	85 db                	test   %ebx,%ebx
f0105357:	7e 10                	jle    f0105369 <vprintfmt+0x1b9>
					putch(padc, putdat);
f0105359:	83 ec 08             	sub    $0x8,%esp
f010535c:	56                   	push   %esi
f010535d:	57                   	push   %edi
f010535e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105361:	83 eb 01             	sub    $0x1,%ebx
f0105364:	83 c4 10             	add    $0x10,%esp
f0105367:	eb ec                	jmp    f0105355 <vprintfmt+0x1a5>
f0105369:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010536c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010536f:	85 d2                	test   %edx,%edx
f0105371:	b8 00 00 00 00       	mov    $0x0,%eax
f0105376:	0f 49 c2             	cmovns %edx,%eax
f0105379:	29 c2                	sub    %eax,%edx
f010537b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010537e:	eb a6                	jmp    f0105326 <vprintfmt+0x176>
					putch(ch, putdat);
f0105380:	83 ec 08             	sub    $0x8,%esp
f0105383:	56                   	push   %esi
f0105384:	52                   	push   %edx
f0105385:	ff d3                	call   *%ebx
f0105387:	83 c4 10             	add    $0x10,%esp
f010538a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010538d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010538f:	83 c7 01             	add    $0x1,%edi
f0105392:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105396:	0f be d0             	movsbl %al,%edx
f0105399:	85 d2                	test   %edx,%edx
f010539b:	74 42                	je     f01053df <vprintfmt+0x22f>
f010539d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01053a1:	78 06                	js     f01053a9 <vprintfmt+0x1f9>
f01053a3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01053a7:	78 1e                	js     f01053c7 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
f01053a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01053ad:	74 d1                	je     f0105380 <vprintfmt+0x1d0>
f01053af:	0f be c0             	movsbl %al,%eax
f01053b2:	83 e8 20             	sub    $0x20,%eax
f01053b5:	83 f8 5e             	cmp    $0x5e,%eax
f01053b8:	76 c6                	jbe    f0105380 <vprintfmt+0x1d0>
					putch('?', putdat);
f01053ba:	83 ec 08             	sub    $0x8,%esp
f01053bd:	56                   	push   %esi
f01053be:	6a 3f                	push   $0x3f
f01053c0:	ff d3                	call   *%ebx
f01053c2:	83 c4 10             	add    $0x10,%esp
f01053c5:	eb c3                	jmp    f010538a <vprintfmt+0x1da>
f01053c7:	89 cf                	mov    %ecx,%edi
f01053c9:	eb 0e                	jmp    f01053d9 <vprintfmt+0x229>
				putch(' ', putdat);
f01053cb:	83 ec 08             	sub    $0x8,%esp
f01053ce:	56                   	push   %esi
f01053cf:	6a 20                	push   $0x20
f01053d1:	ff d3                	call   *%ebx
			for (; width > 0; width--)
f01053d3:	83 ef 01             	sub    $0x1,%edi
f01053d6:	83 c4 10             	add    $0x10,%esp
f01053d9:	85 ff                	test   %edi,%edi
f01053db:	7f ee                	jg     f01053cb <vprintfmt+0x21b>
f01053dd:	eb 6f                	jmp    f010544e <vprintfmt+0x29e>
f01053df:	89 cf                	mov    %ecx,%edi
f01053e1:	eb f6                	jmp    f01053d9 <vprintfmt+0x229>
			num = getint(&ap, lflag);
f01053e3:	89 ca                	mov    %ecx,%edx
f01053e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01053e8:	e8 55 fd ff ff       	call   f0105142 <getint>
f01053ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f01053f3:	85 d2                	test   %edx,%edx
f01053f5:	78 0b                	js     f0105402 <vprintfmt+0x252>
			num = getint(&ap, lflag);
f01053f7:	89 d1                	mov    %edx,%ecx
f01053f9:	89 c2                	mov    %eax,%edx
			base = 10;
f01053fb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105400:	eb 32                	jmp    f0105434 <vprintfmt+0x284>
				putch('-', putdat);
f0105402:	83 ec 08             	sub    $0x8,%esp
f0105405:	56                   	push   %esi
f0105406:	6a 2d                	push   $0x2d
f0105408:	ff d3                	call   *%ebx
				num = -(long long) num;
f010540a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010540d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105410:	f7 da                	neg    %edx
f0105412:	83 d1 00             	adc    $0x0,%ecx
f0105415:	f7 d9                	neg    %ecx
f0105417:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010541a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010541f:	eb 13                	jmp    f0105434 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
f0105421:	89 ca                	mov    %ecx,%edx
f0105423:	8d 45 14             	lea    0x14(%ebp),%eax
f0105426:	e8 e3 fc ff ff       	call   f010510e <getuint>
f010542b:	89 d1                	mov    %edx,%ecx
f010542d:	89 c2                	mov    %eax,%edx
			base = 10;
f010542f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105434:	83 ec 0c             	sub    $0xc,%esp
f0105437:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010543b:	57                   	push   %edi
f010543c:	ff 75 e0             	pushl  -0x20(%ebp)
f010543f:	50                   	push   %eax
f0105440:	51                   	push   %ecx
f0105441:	52                   	push   %edx
f0105442:	89 f2                	mov    %esi,%edx
f0105444:	89 d8                	mov    %ebx,%eax
f0105446:	e8 1a fc ff ff       	call   f0105065 <printnum>
			break;
f010544b:	83 c4 20             	add    $0x20,%esp
{
f010544e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105451:	83 c7 01             	add    $0x1,%edi
f0105454:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105458:	83 f8 25             	cmp    $0x25,%eax
f010545b:	0f 84 6a fd ff ff    	je     f01051cb <vprintfmt+0x1b>
			if (ch == '\0')
f0105461:	85 c0                	test   %eax,%eax
f0105463:	0f 84 93 00 00 00    	je     f01054fc <vprintfmt+0x34c>
			putch(ch, putdat);
f0105469:	83 ec 08             	sub    $0x8,%esp
f010546c:	56                   	push   %esi
f010546d:	50                   	push   %eax
f010546e:	ff d3                	call   *%ebx
f0105470:	83 c4 10             	add    $0x10,%esp
f0105473:	eb dc                	jmp    f0105451 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
f0105475:	89 ca                	mov    %ecx,%edx
f0105477:	8d 45 14             	lea    0x14(%ebp),%eax
f010547a:	e8 8f fc ff ff       	call   f010510e <getuint>
f010547f:	89 d1                	mov    %edx,%ecx
f0105481:	89 c2                	mov    %eax,%edx
			base = 8;
f0105483:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105488:	eb aa                	jmp    f0105434 <vprintfmt+0x284>
			putch('0', putdat);
f010548a:	83 ec 08             	sub    $0x8,%esp
f010548d:	56                   	push   %esi
f010548e:	6a 30                	push   $0x30
f0105490:	ff d3                	call   *%ebx
			putch('x', putdat);
f0105492:	83 c4 08             	add    $0x8,%esp
f0105495:	56                   	push   %esi
f0105496:	6a 78                	push   $0x78
f0105498:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
f010549a:	8b 45 14             	mov    0x14(%ebp),%eax
f010549d:	8d 50 04             	lea    0x4(%eax),%edx
f01054a0:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f01054a3:	8b 10                	mov    (%eax),%edx
f01054a5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01054aa:	83 c4 10             	add    $0x10,%esp
			base = 16;
f01054ad:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01054b2:	eb 80                	jmp    f0105434 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
f01054b4:	89 ca                	mov    %ecx,%edx
f01054b6:	8d 45 14             	lea    0x14(%ebp),%eax
f01054b9:	e8 50 fc ff ff       	call   f010510e <getuint>
f01054be:	89 d1                	mov    %edx,%ecx
f01054c0:	89 c2                	mov    %eax,%edx
			base = 16;
f01054c2:	b8 10 00 00 00       	mov    $0x10,%eax
f01054c7:	e9 68 ff ff ff       	jmp    f0105434 <vprintfmt+0x284>
			putch(ch, putdat);
f01054cc:	83 ec 08             	sub    $0x8,%esp
f01054cf:	56                   	push   %esi
f01054d0:	6a 25                	push   $0x25
f01054d2:	ff d3                	call   *%ebx
			break;
f01054d4:	83 c4 10             	add    $0x10,%esp
f01054d7:	e9 72 ff ff ff       	jmp    f010544e <vprintfmt+0x29e>
			putch('%', putdat);
f01054dc:	83 ec 08             	sub    $0x8,%esp
f01054df:	56                   	push   %esi
f01054e0:	6a 25                	push   $0x25
f01054e2:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054e4:	83 c4 10             	add    $0x10,%esp
f01054e7:	89 f8                	mov    %edi,%eax
f01054e9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01054ed:	74 05                	je     f01054f4 <vprintfmt+0x344>
f01054ef:	83 e8 01             	sub    $0x1,%eax
f01054f2:	eb f5                	jmp    f01054e9 <vprintfmt+0x339>
f01054f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054f7:	e9 52 ff ff ff       	jmp    f010544e <vprintfmt+0x29e>
}
f01054fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054ff:	5b                   	pop    %ebx
f0105500:	5e                   	pop    %esi
f0105501:	5f                   	pop    %edi
f0105502:	5d                   	pop    %ebp
f0105503:	c3                   	ret    

f0105504 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105504:	f3 0f 1e fb          	endbr32 
f0105508:	55                   	push   %ebp
f0105509:	89 e5                	mov    %esp,%ebp
f010550b:	83 ec 18             	sub    $0x18,%esp
f010550e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105511:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105514:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105517:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010551b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010551e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105525:	85 c0                	test   %eax,%eax
f0105527:	74 26                	je     f010554f <vsnprintf+0x4b>
f0105529:	85 d2                	test   %edx,%edx
f010552b:	7e 22                	jle    f010554f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010552d:	ff 75 14             	pushl  0x14(%ebp)
f0105530:	ff 75 10             	pushl  0x10(%ebp)
f0105533:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105536:	50                   	push   %eax
f0105537:	68 6e 51 10 f0       	push   $0xf010516e
f010553c:	e8 6f fc ff ff       	call   f01051b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105541:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105544:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105547:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010554a:	83 c4 10             	add    $0x10,%esp
}
f010554d:	c9                   	leave  
f010554e:	c3                   	ret    
		return -E_INVAL;
f010554f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105554:	eb f7                	jmp    f010554d <vsnprintf+0x49>

f0105556 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105556:	f3 0f 1e fb          	endbr32 
f010555a:	55                   	push   %ebp
f010555b:	89 e5                	mov    %esp,%ebp
f010555d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105560:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105563:	50                   	push   %eax
f0105564:	ff 75 10             	pushl  0x10(%ebp)
f0105567:	ff 75 0c             	pushl  0xc(%ebp)
f010556a:	ff 75 08             	pushl  0x8(%ebp)
f010556d:	e8 92 ff ff ff       	call   f0105504 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105572:	c9                   	leave  
f0105573:	c3                   	ret    

f0105574 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105574:	f3 0f 1e fb          	endbr32 
f0105578:	55                   	push   %ebp
f0105579:	89 e5                	mov    %esp,%ebp
f010557b:	57                   	push   %edi
f010557c:	56                   	push   %esi
f010557d:	53                   	push   %ebx
f010557e:	83 ec 0c             	sub    $0xc,%esp
f0105581:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105584:	85 c0                	test   %eax,%eax
f0105586:	74 11                	je     f0105599 <readline+0x25>
		cprintf("%s", prompt);
f0105588:	83 ec 08             	sub    $0x8,%esp
f010558b:	50                   	push   %eax
f010558c:	68 f9 74 10 f0       	push   $0xf01074f9
f0105591:	e8 75 e4 ff ff       	call   f0103a0b <cprintf>
f0105596:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105599:	83 ec 0c             	sub    $0xc,%esp
f010559c:	6a 00                	push   $0x0
f010559e:	e8 c6 b3 ff ff       	call   f0100969 <iscons>
f01055a3:	89 c7                	mov    %eax,%edi
f01055a5:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01055a8:	be 00 00 00 00       	mov    $0x0,%esi
f01055ad:	eb 57                	jmp    f0105606 <readline+0x92>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01055af:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f01055b4:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01055b7:	75 08                	jne    f01055c1 <readline+0x4d>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01055b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055bc:	5b                   	pop    %ebx
f01055bd:	5e                   	pop    %esi
f01055be:	5f                   	pop    %edi
f01055bf:	5d                   	pop    %ebp
f01055c0:	c3                   	ret    
				cprintf("read error: %e\n", c);
f01055c1:	83 ec 08             	sub    $0x8,%esp
f01055c4:	53                   	push   %ebx
f01055c5:	68 1f 80 10 f0       	push   $0xf010801f
f01055ca:	e8 3c e4 ff ff       	call   f0103a0b <cprintf>
f01055cf:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01055d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01055d7:	eb e0                	jmp    f01055b9 <readline+0x45>
			if (echoing)
f01055d9:	85 ff                	test   %edi,%edi
f01055db:	75 05                	jne    f01055e2 <readline+0x6e>
			i--;
f01055dd:	83 ee 01             	sub    $0x1,%esi
f01055e0:	eb 24                	jmp    f0105606 <readline+0x92>
				cputchar('\b');
f01055e2:	83 ec 0c             	sub    $0xc,%esp
f01055e5:	6a 08                	push   $0x8
f01055e7:	e8 54 b3 ff ff       	call   f0100940 <cputchar>
f01055ec:	83 c4 10             	add    $0x10,%esp
f01055ef:	eb ec                	jmp    f01055dd <readline+0x69>
				cputchar(c);
f01055f1:	83 ec 0c             	sub    $0xc,%esp
f01055f4:	53                   	push   %ebx
f01055f5:	e8 46 b3 ff ff       	call   f0100940 <cputchar>
f01055fa:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055fd:	88 9e 80 1a 22 f0    	mov    %bl,-0xfdde580(%esi)
f0105603:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105606:	e8 49 b3 ff ff       	call   f0100954 <getchar>
f010560b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010560d:	85 c0                	test   %eax,%eax
f010560f:	78 9e                	js     f01055af <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105611:	83 f8 08             	cmp    $0x8,%eax
f0105614:	0f 94 c2             	sete   %dl
f0105617:	83 f8 7f             	cmp    $0x7f,%eax
f010561a:	0f 94 c0             	sete   %al
f010561d:	08 c2                	or     %al,%dl
f010561f:	74 04                	je     f0105625 <readline+0xb1>
f0105621:	85 f6                	test   %esi,%esi
f0105623:	7f b4                	jg     f01055d9 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105625:	83 fb 1f             	cmp    $0x1f,%ebx
f0105628:	7e 0e                	jle    f0105638 <readline+0xc4>
f010562a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105630:	7f 06                	jg     f0105638 <readline+0xc4>
			if (echoing)
f0105632:	85 ff                	test   %edi,%edi
f0105634:	74 c7                	je     f01055fd <readline+0x89>
f0105636:	eb b9                	jmp    f01055f1 <readline+0x7d>
		} else if (c == '\n' || c == '\r') {
f0105638:	83 fb 0a             	cmp    $0xa,%ebx
f010563b:	74 05                	je     f0105642 <readline+0xce>
f010563d:	83 fb 0d             	cmp    $0xd,%ebx
f0105640:	75 c4                	jne    f0105606 <readline+0x92>
			if (echoing)
f0105642:	85 ff                	test   %edi,%edi
f0105644:	75 11                	jne    f0105657 <readline+0xe3>
			buf[i] = 0;
f0105646:	c6 86 80 1a 22 f0 00 	movb   $0x0,-0xfdde580(%esi)
			return buf;
f010564d:	b8 80 1a 22 f0       	mov    $0xf0221a80,%eax
f0105652:	e9 62 ff ff ff       	jmp    f01055b9 <readline+0x45>
				cputchar('\n');
f0105657:	83 ec 0c             	sub    $0xc,%esp
f010565a:	6a 0a                	push   $0xa
f010565c:	e8 df b2 ff ff       	call   f0100940 <cputchar>
f0105661:	83 c4 10             	add    $0x10,%esp
f0105664:	eb e0                	jmp    f0105646 <readline+0xd2>

f0105666 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105666:	f3 0f 1e fb          	endbr32 
f010566a:	55                   	push   %ebp
f010566b:	89 e5                	mov    %esp,%ebp
f010566d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105670:	b8 00 00 00 00       	mov    $0x0,%eax
f0105675:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105679:	74 05                	je     f0105680 <strlen+0x1a>
		n++;
f010567b:	83 c0 01             	add    $0x1,%eax
f010567e:	eb f5                	jmp    f0105675 <strlen+0xf>
	return n;
}
f0105680:	5d                   	pop    %ebp
f0105681:	c3                   	ret    

f0105682 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105682:	f3 0f 1e fb          	endbr32 
f0105686:	55                   	push   %ebp
f0105687:	89 e5                	mov    %esp,%ebp
f0105689:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010568c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010568f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105694:	39 d0                	cmp    %edx,%eax
f0105696:	74 0d                	je     f01056a5 <strnlen+0x23>
f0105698:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010569c:	74 05                	je     f01056a3 <strnlen+0x21>
		n++;
f010569e:	83 c0 01             	add    $0x1,%eax
f01056a1:	eb f1                	jmp    f0105694 <strnlen+0x12>
f01056a3:	89 c2                	mov    %eax,%edx
	return n;
}
f01056a5:	89 d0                	mov    %edx,%eax
f01056a7:	5d                   	pop    %ebp
f01056a8:	c3                   	ret    

f01056a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01056a9:	f3 0f 1e fb          	endbr32 
f01056ad:	55                   	push   %ebp
f01056ae:	89 e5                	mov    %esp,%ebp
f01056b0:	53                   	push   %ebx
f01056b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01056b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01056bc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01056c0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01056c3:	83 c0 01             	add    $0x1,%eax
f01056c6:	84 d2                	test   %dl,%dl
f01056c8:	75 f2                	jne    f01056bc <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01056ca:	89 c8                	mov    %ecx,%eax
f01056cc:	5b                   	pop    %ebx
f01056cd:	5d                   	pop    %ebp
f01056ce:	c3                   	ret    

f01056cf <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056cf:	f3 0f 1e fb          	endbr32 
f01056d3:	55                   	push   %ebp
f01056d4:	89 e5                	mov    %esp,%ebp
f01056d6:	53                   	push   %ebx
f01056d7:	83 ec 10             	sub    $0x10,%esp
f01056da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056dd:	53                   	push   %ebx
f01056de:	e8 83 ff ff ff       	call   f0105666 <strlen>
f01056e3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01056e6:	ff 75 0c             	pushl  0xc(%ebp)
f01056e9:	01 d8                	add    %ebx,%eax
f01056eb:	50                   	push   %eax
f01056ec:	e8 b8 ff ff ff       	call   f01056a9 <strcpy>
	return dst;
}
f01056f1:	89 d8                	mov    %ebx,%eax
f01056f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056f6:	c9                   	leave  
f01056f7:	c3                   	ret    

f01056f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056f8:	f3 0f 1e fb          	endbr32 
f01056fc:	55                   	push   %ebp
f01056fd:	89 e5                	mov    %esp,%ebp
f01056ff:	56                   	push   %esi
f0105700:	53                   	push   %ebx
f0105701:	8b 75 08             	mov    0x8(%ebp),%esi
f0105704:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105707:	89 f3                	mov    %esi,%ebx
f0105709:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010570c:	89 f0                	mov    %esi,%eax
f010570e:	39 d8                	cmp    %ebx,%eax
f0105710:	74 11                	je     f0105723 <strncpy+0x2b>
		*dst++ = *src;
f0105712:	83 c0 01             	add    $0x1,%eax
f0105715:	0f b6 0a             	movzbl (%edx),%ecx
f0105718:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010571b:	80 f9 01             	cmp    $0x1,%cl
f010571e:	83 da ff             	sbb    $0xffffffff,%edx
f0105721:	eb eb                	jmp    f010570e <strncpy+0x16>
	}
	return ret;
}
f0105723:	89 f0                	mov    %esi,%eax
f0105725:	5b                   	pop    %ebx
f0105726:	5e                   	pop    %esi
f0105727:	5d                   	pop    %ebp
f0105728:	c3                   	ret    

f0105729 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105729:	f3 0f 1e fb          	endbr32 
f010572d:	55                   	push   %ebp
f010572e:	89 e5                	mov    %esp,%ebp
f0105730:	56                   	push   %esi
f0105731:	53                   	push   %ebx
f0105732:	8b 75 08             	mov    0x8(%ebp),%esi
f0105735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105738:	8b 55 10             	mov    0x10(%ebp),%edx
f010573b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010573d:	85 d2                	test   %edx,%edx
f010573f:	74 21                	je     f0105762 <strlcpy+0x39>
f0105741:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105745:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105747:	39 c2                	cmp    %eax,%edx
f0105749:	74 14                	je     f010575f <strlcpy+0x36>
f010574b:	0f b6 19             	movzbl (%ecx),%ebx
f010574e:	84 db                	test   %bl,%bl
f0105750:	74 0b                	je     f010575d <strlcpy+0x34>
			*dst++ = *src++;
f0105752:	83 c1 01             	add    $0x1,%ecx
f0105755:	83 c2 01             	add    $0x1,%edx
f0105758:	88 5a ff             	mov    %bl,-0x1(%edx)
f010575b:	eb ea                	jmp    f0105747 <strlcpy+0x1e>
f010575d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010575f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105762:	29 f0                	sub    %esi,%eax
}
f0105764:	5b                   	pop    %ebx
f0105765:	5e                   	pop    %esi
f0105766:	5d                   	pop    %ebp
f0105767:	c3                   	ret    

f0105768 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105768:	f3 0f 1e fb          	endbr32 
f010576c:	55                   	push   %ebp
f010576d:	89 e5                	mov    %esp,%ebp
f010576f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105772:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105775:	0f b6 01             	movzbl (%ecx),%eax
f0105778:	84 c0                	test   %al,%al
f010577a:	74 0c                	je     f0105788 <strcmp+0x20>
f010577c:	3a 02                	cmp    (%edx),%al
f010577e:	75 08                	jne    f0105788 <strcmp+0x20>
		p++, q++;
f0105780:	83 c1 01             	add    $0x1,%ecx
f0105783:	83 c2 01             	add    $0x1,%edx
f0105786:	eb ed                	jmp    f0105775 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105788:	0f b6 c0             	movzbl %al,%eax
f010578b:	0f b6 12             	movzbl (%edx),%edx
f010578e:	29 d0                	sub    %edx,%eax
}
f0105790:	5d                   	pop    %ebp
f0105791:	c3                   	ret    

f0105792 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105792:	f3 0f 1e fb          	endbr32 
f0105796:	55                   	push   %ebp
f0105797:	89 e5                	mov    %esp,%ebp
f0105799:	53                   	push   %ebx
f010579a:	8b 45 08             	mov    0x8(%ebp),%eax
f010579d:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057a0:	89 c3                	mov    %eax,%ebx
f01057a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01057a5:	eb 06                	jmp    f01057ad <strncmp+0x1b>
		n--, p++, q++;
f01057a7:	83 c0 01             	add    $0x1,%eax
f01057aa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01057ad:	39 d8                	cmp    %ebx,%eax
f01057af:	74 16                	je     f01057c7 <strncmp+0x35>
f01057b1:	0f b6 08             	movzbl (%eax),%ecx
f01057b4:	84 c9                	test   %cl,%cl
f01057b6:	74 04                	je     f01057bc <strncmp+0x2a>
f01057b8:	3a 0a                	cmp    (%edx),%cl
f01057ba:	74 eb                	je     f01057a7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01057bc:	0f b6 00             	movzbl (%eax),%eax
f01057bf:	0f b6 12             	movzbl (%edx),%edx
f01057c2:	29 d0                	sub    %edx,%eax
}
f01057c4:	5b                   	pop    %ebx
f01057c5:	5d                   	pop    %ebp
f01057c6:	c3                   	ret    
		return 0;
f01057c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01057cc:	eb f6                	jmp    f01057c4 <strncmp+0x32>

f01057ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01057ce:	f3 0f 1e fb          	endbr32 
f01057d2:	55                   	push   %ebp
f01057d3:	89 e5                	mov    %esp,%ebp
f01057d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057dc:	0f b6 10             	movzbl (%eax),%edx
f01057df:	84 d2                	test   %dl,%dl
f01057e1:	74 09                	je     f01057ec <strchr+0x1e>
		if (*s == c)
f01057e3:	38 ca                	cmp    %cl,%dl
f01057e5:	74 0a                	je     f01057f1 <strchr+0x23>
	for (; *s; s++)
f01057e7:	83 c0 01             	add    $0x1,%eax
f01057ea:	eb f0                	jmp    f01057dc <strchr+0xe>
			return (char *) s;
	return 0;
f01057ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057f1:	5d                   	pop    %ebp
f01057f2:	c3                   	ret    

f01057f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057f3:	f3 0f 1e fb          	endbr32 
f01057f7:	55                   	push   %ebp
f01057f8:	89 e5                	mov    %esp,%ebp
f01057fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01057fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105801:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105804:	38 ca                	cmp    %cl,%dl
f0105806:	74 09                	je     f0105811 <strfind+0x1e>
f0105808:	84 d2                	test   %dl,%dl
f010580a:	74 05                	je     f0105811 <strfind+0x1e>
	for (; *s; s++)
f010580c:	83 c0 01             	add    $0x1,%eax
f010580f:	eb f0                	jmp    f0105801 <strfind+0xe>
			break;
	return (char *) s;
}
f0105811:	5d                   	pop    %ebp
f0105812:	c3                   	ret    

f0105813 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105813:	f3 0f 1e fb          	endbr32 
f0105817:	55                   	push   %ebp
f0105818:	89 e5                	mov    %esp,%ebp
f010581a:	57                   	push   %edi
f010581b:	56                   	push   %esi
f010581c:	53                   	push   %ebx
f010581d:	8b 55 08             	mov    0x8(%ebp),%edx
f0105820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
f0105823:	85 c9                	test   %ecx,%ecx
f0105825:	74 33                	je     f010585a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105827:	89 d0                	mov    %edx,%eax
f0105829:	09 c8                	or     %ecx,%eax
f010582b:	a8 03                	test   $0x3,%al
f010582d:	75 23                	jne    f0105852 <memset+0x3f>
		c &= 0xFF;
f010582f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105833:	89 d8                	mov    %ebx,%eax
f0105835:	c1 e0 08             	shl    $0x8,%eax
f0105838:	89 df                	mov    %ebx,%edi
f010583a:	c1 e7 18             	shl    $0x18,%edi
f010583d:	89 de                	mov    %ebx,%esi
f010583f:	c1 e6 10             	shl    $0x10,%esi
f0105842:	09 f7                	or     %esi,%edi
f0105844:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
f0105846:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105849:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
f010584b:	89 d7                	mov    %edx,%edi
f010584d:	fc                   	cld    
f010584e:	f3 ab                	rep stos %eax,%es:(%edi)
f0105850:	eb 08                	jmp    f010585a <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105852:	89 d7                	mov    %edx,%edi
f0105854:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105857:	fc                   	cld    
f0105858:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
f010585a:	89 d0                	mov    %edx,%eax
f010585c:	5b                   	pop    %ebx
f010585d:	5e                   	pop    %esi
f010585e:	5f                   	pop    %edi
f010585f:	5d                   	pop    %ebp
f0105860:	c3                   	ret    

f0105861 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105861:	f3 0f 1e fb          	endbr32 
f0105865:	55                   	push   %ebp
f0105866:	89 e5                	mov    %esp,%ebp
f0105868:	57                   	push   %edi
f0105869:	56                   	push   %esi
f010586a:	8b 45 08             	mov    0x8(%ebp),%eax
f010586d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105873:	39 c6                	cmp    %eax,%esi
f0105875:	73 32                	jae    f01058a9 <memmove+0x48>
f0105877:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010587a:	39 c2                	cmp    %eax,%edx
f010587c:	76 2b                	jbe    f01058a9 <memmove+0x48>
		s += n;
		d += n;
f010587e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105881:	89 fe                	mov    %edi,%esi
f0105883:	09 ce                	or     %ecx,%esi
f0105885:	09 d6                	or     %edx,%esi
f0105887:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010588d:	75 0e                	jne    f010589d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010588f:	83 ef 04             	sub    $0x4,%edi
f0105892:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105895:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105898:	fd                   	std    
f0105899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010589b:	eb 09                	jmp    f01058a6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010589d:	83 ef 01             	sub    $0x1,%edi
f01058a0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01058a3:	fd                   	std    
f01058a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01058a6:	fc                   	cld    
f01058a7:	eb 1a                	jmp    f01058c3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058a9:	89 c2                	mov    %eax,%edx
f01058ab:	09 ca                	or     %ecx,%edx
f01058ad:	09 f2                	or     %esi,%edx
f01058af:	f6 c2 03             	test   $0x3,%dl
f01058b2:	75 0a                	jne    f01058be <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01058b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01058b7:	89 c7                	mov    %eax,%edi
f01058b9:	fc                   	cld    
f01058ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058bc:	eb 05                	jmp    f01058c3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01058be:	89 c7                	mov    %eax,%edi
f01058c0:	fc                   	cld    
f01058c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01058c3:	5e                   	pop    %esi
f01058c4:	5f                   	pop    %edi
f01058c5:	5d                   	pop    %ebp
f01058c6:	c3                   	ret    

f01058c7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01058c7:	f3 0f 1e fb          	endbr32 
f01058cb:	55                   	push   %ebp
f01058cc:	89 e5                	mov    %esp,%ebp
f01058ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01058d1:	ff 75 10             	pushl  0x10(%ebp)
f01058d4:	ff 75 0c             	pushl  0xc(%ebp)
f01058d7:	ff 75 08             	pushl  0x8(%ebp)
f01058da:	e8 82 ff ff ff       	call   f0105861 <memmove>
}
f01058df:	c9                   	leave  
f01058e0:	c3                   	ret    

f01058e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058e1:	f3 0f 1e fb          	endbr32 
f01058e5:	55                   	push   %ebp
f01058e6:	89 e5                	mov    %esp,%ebp
f01058e8:	56                   	push   %esi
f01058e9:	53                   	push   %ebx
f01058ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ed:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058f0:	89 c6                	mov    %eax,%esi
f01058f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058f5:	39 f0                	cmp    %esi,%eax
f01058f7:	74 1c                	je     f0105915 <memcmp+0x34>
		if (*s1 != *s2)
f01058f9:	0f b6 08             	movzbl (%eax),%ecx
f01058fc:	0f b6 1a             	movzbl (%edx),%ebx
f01058ff:	38 d9                	cmp    %bl,%cl
f0105901:	75 08                	jne    f010590b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105903:	83 c0 01             	add    $0x1,%eax
f0105906:	83 c2 01             	add    $0x1,%edx
f0105909:	eb ea                	jmp    f01058f5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f010590b:	0f b6 c1             	movzbl %cl,%eax
f010590e:	0f b6 db             	movzbl %bl,%ebx
f0105911:	29 d8                	sub    %ebx,%eax
f0105913:	eb 05                	jmp    f010591a <memcmp+0x39>
	}

	return 0;
f0105915:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010591a:	5b                   	pop    %ebx
f010591b:	5e                   	pop    %esi
f010591c:	5d                   	pop    %ebp
f010591d:	c3                   	ret    

f010591e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010591e:	f3 0f 1e fb          	endbr32 
f0105922:	55                   	push   %ebp
f0105923:	89 e5                	mov    %esp,%ebp
f0105925:	8b 45 08             	mov    0x8(%ebp),%eax
f0105928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010592b:	89 c2                	mov    %eax,%edx
f010592d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105930:	39 d0                	cmp    %edx,%eax
f0105932:	73 09                	jae    f010593d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105934:	38 08                	cmp    %cl,(%eax)
f0105936:	74 05                	je     f010593d <memfind+0x1f>
	for (; s < ends; s++)
f0105938:	83 c0 01             	add    $0x1,%eax
f010593b:	eb f3                	jmp    f0105930 <memfind+0x12>
			break;
	return (void *) s;
}
f010593d:	5d                   	pop    %ebp
f010593e:	c3                   	ret    

f010593f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010593f:	f3 0f 1e fb          	endbr32 
f0105943:	55                   	push   %ebp
f0105944:	89 e5                	mov    %esp,%ebp
f0105946:	57                   	push   %edi
f0105947:	56                   	push   %esi
f0105948:	53                   	push   %ebx
f0105949:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010594c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010594f:	eb 03                	jmp    f0105954 <strtol+0x15>
		s++;
f0105951:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105954:	0f b6 01             	movzbl (%ecx),%eax
f0105957:	3c 20                	cmp    $0x20,%al
f0105959:	74 f6                	je     f0105951 <strtol+0x12>
f010595b:	3c 09                	cmp    $0x9,%al
f010595d:	74 f2                	je     f0105951 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f010595f:	3c 2b                	cmp    $0x2b,%al
f0105961:	74 2a                	je     f010598d <strtol+0x4e>
	int neg = 0;
f0105963:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105968:	3c 2d                	cmp    $0x2d,%al
f010596a:	74 2b                	je     f0105997 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010596c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105972:	75 0f                	jne    f0105983 <strtol+0x44>
f0105974:	80 39 30             	cmpb   $0x30,(%ecx)
f0105977:	74 28                	je     f01059a1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105979:	85 db                	test   %ebx,%ebx
f010597b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105980:	0f 44 d8             	cmove  %eax,%ebx
f0105983:	b8 00 00 00 00       	mov    $0x0,%eax
f0105988:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010598b:	eb 46                	jmp    f01059d3 <strtol+0x94>
		s++;
f010598d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105990:	bf 00 00 00 00       	mov    $0x0,%edi
f0105995:	eb d5                	jmp    f010596c <strtol+0x2d>
		s++, neg = 1;
f0105997:	83 c1 01             	add    $0x1,%ecx
f010599a:	bf 01 00 00 00       	mov    $0x1,%edi
f010599f:	eb cb                	jmp    f010596c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01059a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01059a5:	74 0e                	je     f01059b5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01059a7:	85 db                	test   %ebx,%ebx
f01059a9:	75 d8                	jne    f0105983 <strtol+0x44>
		s++, base = 8;
f01059ab:	83 c1 01             	add    $0x1,%ecx
f01059ae:	bb 08 00 00 00       	mov    $0x8,%ebx
f01059b3:	eb ce                	jmp    f0105983 <strtol+0x44>
		s += 2, base = 16;
f01059b5:	83 c1 02             	add    $0x2,%ecx
f01059b8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01059bd:	eb c4                	jmp    f0105983 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01059bf:	0f be d2             	movsbl %dl,%edx
f01059c2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01059c5:	3b 55 10             	cmp    0x10(%ebp),%edx
f01059c8:	7d 3a                	jge    f0105a04 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01059ca:	83 c1 01             	add    $0x1,%ecx
f01059cd:	0f af 45 10          	imul   0x10(%ebp),%eax
f01059d1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01059d3:	0f b6 11             	movzbl (%ecx),%edx
f01059d6:	8d 72 d0             	lea    -0x30(%edx),%esi
f01059d9:	89 f3                	mov    %esi,%ebx
f01059db:	80 fb 09             	cmp    $0x9,%bl
f01059de:	76 df                	jbe    f01059bf <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01059e0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01059e3:	89 f3                	mov    %esi,%ebx
f01059e5:	80 fb 19             	cmp    $0x19,%bl
f01059e8:	77 08                	ja     f01059f2 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01059ea:	0f be d2             	movsbl %dl,%edx
f01059ed:	83 ea 57             	sub    $0x57,%edx
f01059f0:	eb d3                	jmp    f01059c5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01059f2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01059f5:	89 f3                	mov    %esi,%ebx
f01059f7:	80 fb 19             	cmp    $0x19,%bl
f01059fa:	77 08                	ja     f0105a04 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01059fc:	0f be d2             	movsbl %dl,%edx
f01059ff:	83 ea 37             	sub    $0x37,%edx
f0105a02:	eb c1                	jmp    f01059c5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105a04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105a08:	74 05                	je     f0105a0f <strtol+0xd0>
		*endptr = (char *) s;
f0105a0a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105a0d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105a0f:	89 c2                	mov    %eax,%edx
f0105a11:	f7 da                	neg    %edx
f0105a13:	85 ff                	test   %edi,%edi
f0105a15:	0f 45 c2             	cmovne %edx,%eax
}
f0105a18:	5b                   	pop    %ebx
f0105a19:	5e                   	pop    %esi
f0105a1a:	5f                   	pop    %edi
f0105a1b:	5d                   	pop    %ebp
f0105a1c:	c3                   	ret    
f0105a1d:	66 90                	xchg   %ax,%ax
f0105a1f:	90                   	nop

f0105a20 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105a20:	fa                   	cli    

	xorw    %ax, %ax
f0105a21:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105a23:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a25:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a27:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105a29:	0f 01 16             	lgdtl  (%esi)
f0105a2c:	7c 70                	jl     f0105a9e <gdtdesc+0x2>
	movl    %cr0, %eax
f0105a2e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a31:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a35:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a38:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a3e:	08 00                	or     %al,(%eax)

f0105a40 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a40:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a44:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a46:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a48:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a4a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a4e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a50:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a52:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105a57:	0f 22 d8             	mov    %eax,%cr3

	# Activar soporte de large pages
	movl %cr4, %eax
f0105a5a:	0f 20 e0             	mov    %cr4,%eax
	orl $(CR4_PSE), %eax
f0105a5d:	83 c8 10             	or     $0x10,%eax
	movl %eax, %cr4
f0105a60:	0f 22 e0             	mov    %eax,%cr4
	
	# Turn on paging.
	movl    %cr0, %eax
f0105a63:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a66:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a6b:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a6e:	8b 25 84 2e 22 f0    	mov    0xf0222e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a74:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a79:	b8 52 02 10 f0       	mov    $0xf0100252,%eax
	call    *%eax
f0105a7e:	ff d0                	call   *%eax

f0105a80 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a80:	eb fe                	jmp    f0105a80 <spin>
f0105a82:	66 90                	xchg   %ax,%ax

f0105a84 <gdt>:
	...
f0105a8c:	ff                   	(bad)  
f0105a8d:	ff 00                	incl   (%eax)
f0105a8f:	00 00                	add    %al,(%eax)
f0105a91:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a98:	00                   	.byte 0x0
f0105a99:	92                   	xchg   %eax,%edx
f0105a9a:	cf                   	iret   
	...

f0105a9c <gdtdesc>:
f0105a9c:	17                   	pop    %ss
f0105a9d:	00 64 70 00          	add    %ah,0x0(%eax,%esi,2)
	...

f0105aa2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105aa2:	90                   	nop

f0105aa3 <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105aa3:	89 c2                	mov    %eax,%edx
f0105aa5:	ec                   	in     (%dx),%al
}
f0105aa6:	c3                   	ret    

f0105aa7 <outb>:
{
f0105aa7:	89 c1                	mov    %eax,%ecx
f0105aa9:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105aab:	89 ca                	mov    %ecx,%edx
f0105aad:	ee                   	out    %al,(%dx)
}
f0105aae:	c3                   	ret    

f0105aaf <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105aaf:	55                   	push   %ebp
f0105ab0:	89 e5                	mov    %esp,%ebp
f0105ab2:	56                   	push   %esi
f0105ab3:	53                   	push   %ebx
f0105ab4:	89 c6                	mov    %eax,%esi
	int i, sum;

	sum = 0;
f0105ab6:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
f0105abb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105ac0:	39 d1                	cmp    %edx,%ecx
f0105ac2:	7d 0b                	jge    f0105acf <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0105ac4:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
f0105ac8:	01 d8                	add    %ebx,%eax
	for (i = 0; i < len; i++)
f0105aca:	83 c1 01             	add    $0x1,%ecx
f0105acd:	eb f1                	jmp    f0105ac0 <sum+0x11>
	return sum;
}
f0105acf:	5b                   	pop    %ebx
f0105ad0:	5e                   	pop    %esi
f0105ad1:	5d                   	pop    %ebp
f0105ad2:	c3                   	ret    

f0105ad3 <_kaddr>:
{
f0105ad3:	55                   	push   %ebp
f0105ad4:	89 e5                	mov    %esp,%ebp
f0105ad6:	53                   	push   %ebx
f0105ad7:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105ada:	89 cb                	mov    %ecx,%ebx
f0105adc:	c1 eb 0c             	shr    $0xc,%ebx
f0105adf:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0105ae5:	73 0b                	jae    f0105af2 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0105ae7:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105aed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105af0:	c9                   	leave  
f0105af1:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105af2:	51                   	push   %ecx
f0105af3:	68 8c 65 10 f0       	push   $0xf010658c
f0105af8:	52                   	push   %edx
f0105af9:	50                   	push   %eax
f0105afa:	e8 6b a5 ff ff       	call   f010006a <_panic>

f0105aff <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105aff:	55                   	push   %ebp
f0105b00:	89 e5                	mov    %esp,%ebp
f0105b02:	57                   	push   %edi
f0105b03:	56                   	push   %esi
f0105b04:	53                   	push   %ebx
f0105b05:	83 ec 0c             	sub    $0xc,%esp
f0105b08:	89 c7                	mov    %eax,%edi
f0105b0a:	89 d6                	mov    %edx,%esi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105b0c:	89 c1                	mov    %eax,%ecx
f0105b0e:	ba 57 00 00 00       	mov    $0x57,%edx
f0105b13:	b8 bd 81 10 f0       	mov    $0xf01081bd,%eax
f0105b18:	e8 b6 ff ff ff       	call   f0105ad3 <_kaddr>
f0105b1d:	89 c3                	mov    %eax,%ebx
f0105b1f:	8d 0c 3e             	lea    (%esi,%edi,1),%ecx
f0105b22:	ba 57 00 00 00       	mov    $0x57,%edx
f0105b27:	b8 bd 81 10 f0       	mov    $0xf01081bd,%eax
f0105b2c:	e8 a2 ff ff ff       	call   f0105ad3 <_kaddr>
f0105b31:	89 c6                	mov    %eax,%esi

	for (; mp < end; mp++)
f0105b33:	eb 03                	jmp    f0105b38 <mpsearch1+0x39>
f0105b35:	83 c3 10             	add    $0x10,%ebx
f0105b38:	39 f3                	cmp    %esi,%ebx
f0105b3a:	73 29                	jae    f0105b65 <mpsearch1+0x66>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b3c:	83 ec 04             	sub    $0x4,%esp
f0105b3f:	6a 04                	push   $0x4
f0105b41:	68 cd 81 10 f0       	push   $0xf01081cd
f0105b46:	53                   	push   %ebx
f0105b47:	e8 95 fd ff ff       	call   f01058e1 <memcmp>
f0105b4c:	83 c4 10             	add    $0x10,%esp
f0105b4f:	85 c0                	test   %eax,%eax
f0105b51:	75 e2                	jne    f0105b35 <mpsearch1+0x36>
		    sum(mp, sizeof(*mp)) == 0)
f0105b53:	ba 10 00 00 00       	mov    $0x10,%edx
f0105b58:	89 d8                	mov    %ebx,%eax
f0105b5a:	e8 50 ff ff ff       	call   f0105aaf <sum>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b5f:	84 c0                	test   %al,%al
f0105b61:	75 d2                	jne    f0105b35 <mpsearch1+0x36>
f0105b63:	eb 05                	jmp    f0105b6a <mpsearch1+0x6b>
			return mp;
	return NULL;
f0105b65:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105b6a:	89 d8                	mov    %ebx,%eax
f0105b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b6f:	5b                   	pop    %ebx
f0105b70:	5e                   	pop    %esi
f0105b71:	5f                   	pop    %edi
f0105b72:	5d                   	pop    %ebp
f0105b73:	c3                   	ret    

f0105b74 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0105b74:	55                   	push   %ebp
f0105b75:	89 e5                	mov    %esp,%ebp
f0105b77:	83 ec 08             	sub    $0x8,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0105b7a:	b9 00 04 00 00       	mov    $0x400,%ecx
f0105b7f:	ba 6f 00 00 00       	mov    $0x6f,%edx
f0105b84:	b8 bd 81 10 f0       	mov    $0xf01081bd,%eax
f0105b89:	e8 45 ff ff ff       	call   f0105ad3 <_kaddr>

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b8e:	0f b7 50 0e          	movzwl 0xe(%eax),%edx
f0105b92:	85 d2                	test   %edx,%edx
f0105b94:	74 24                	je     f0105bba <mpsearch+0x46>
		p <<= 4;	// Translate from segment to PA
f0105b96:	89 d0                	mov    %edx,%eax
f0105b98:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b9b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ba0:	e8 5a ff ff ff       	call   f0105aff <mpsearch1>
f0105ba5:	85 c0                	test   %eax,%eax
f0105ba7:	75 0f                	jne    f0105bb8 <mpsearch+0x44>
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105ba9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bae:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105bb3:	e8 47 ff ff ff       	call   f0105aff <mpsearch1>
}
f0105bb8:	c9                   	leave  
f0105bb9:	c3                   	ret    
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105bba:	0f b7 40 13          	movzwl 0x13(%eax),%eax
f0105bbe:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105bc1:	2d 00 04 00 00       	sub    $0x400,%eax
f0105bc6:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bcb:	e8 2f ff ff ff       	call   f0105aff <mpsearch1>
f0105bd0:	85 c0                	test   %eax,%eax
f0105bd2:	75 e4                	jne    f0105bb8 <mpsearch+0x44>
f0105bd4:	eb d3                	jmp    f0105ba9 <mpsearch+0x35>

f0105bd6 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0105bd6:	55                   	push   %ebp
f0105bd7:	89 e5                	mov    %esp,%ebp
f0105bd9:	57                   	push   %edi
f0105bda:	56                   	push   %esi
f0105bdb:	53                   	push   %ebx
f0105bdc:	83 ec 1c             	sub    $0x1c,%esp
f0105bdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105be2:	e8 8d ff ff ff       	call   f0105b74 <mpsearch>
f0105be7:	89 c6                	mov    %eax,%esi
f0105be9:	85 c0                	test   %eax,%eax
f0105beb:	0f 84 ef 00 00 00    	je     f0105ce0 <mpconfig+0x10a>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105bf1:	8b 48 04             	mov    0x4(%eax),%ecx
f0105bf4:	85 c9                	test   %ecx,%ecx
f0105bf6:	74 6e                	je     f0105c66 <mpconfig+0x90>
f0105bf8:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105bfc:	75 68                	jne    f0105c66 <mpconfig+0x90>
		cprintf("SMP: Default configurations not implemented\n");
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0105bfe:	ba 90 00 00 00       	mov    $0x90,%edx
f0105c03:	b8 bd 81 10 f0       	mov    $0xf01081bd,%eax
f0105c08:	e8 c6 fe ff ff       	call   f0105ad3 <_kaddr>
f0105c0d:	89 c3                	mov    %eax,%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c0f:	83 ec 04             	sub    $0x4,%esp
f0105c12:	6a 04                	push   $0x4
f0105c14:	68 d2 81 10 f0       	push   $0xf01081d2
f0105c19:	50                   	push   %eax
f0105c1a:	e8 c2 fc ff ff       	call   f01058e1 <memcmp>
f0105c1f:	83 c4 10             	add    $0x10,%esp
f0105c22:	85 c0                	test   %eax,%eax
f0105c24:	75 57                	jne    f0105c7d <mpconfig+0xa7>
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c26:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105c2a:	0f b7 d7             	movzwl %di,%edx
f0105c2d:	89 d8                	mov    %ebx,%eax
f0105c2f:	e8 7b fe ff ff       	call   f0105aaf <sum>
f0105c34:	84 c0                	test   %al,%al
f0105c36:	75 5c                	jne    f0105c94 <mpconfig+0xbe>
		cprintf("SMP: Bad MP configuration checksum\n");
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c38:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c3c:	3c 01                	cmp    $0x1,%al
f0105c3e:	74 04                	je     f0105c44 <mpconfig+0x6e>
f0105c40:	3c 04                	cmp    $0x4,%al
f0105c42:	75 67                	jne    f0105cab <mpconfig+0xd5>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c44:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0105c48:	0f b7 c7             	movzwl %di,%eax
f0105c4b:	01 d8                	add    %ebx,%eax
f0105c4d:	e8 5d fe ff ff       	call   f0105aaf <sum>
f0105c52:	02 43 2a             	add    0x2a(%ebx),%al
f0105c55:	75 6f                	jne    f0105cc6 <mpconfig+0xf0>
		cprintf("SMP: Bad MP configuration extended checksum\n");
		return NULL;
	}
	*pmp = mp;
f0105c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c5a:	89 30                	mov    %esi,(%eax)
	return conf;
}
f0105c5c:	89 d8                	mov    %ebx,%eax
f0105c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c61:	5b                   	pop    %ebx
f0105c62:	5e                   	pop    %esi
f0105c63:	5f                   	pop    %edi
f0105c64:	5d                   	pop    %ebp
f0105c65:	c3                   	ret    
		cprintf("SMP: Default configurations not implemented\n");
f0105c66:	83 ec 0c             	sub    $0xc,%esp
f0105c69:	68 30 80 10 f0       	push   $0xf0108030
f0105c6e:	e8 98 dd ff ff       	call   f0103a0b <cprintf>
		return NULL;
f0105c73:	83 c4 10             	add    $0x10,%esp
f0105c76:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105c7b:	eb df                	jmp    f0105c5c <mpconfig+0x86>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c7d:	83 ec 0c             	sub    $0xc,%esp
f0105c80:	68 60 80 10 f0       	push   $0xf0108060
f0105c85:	e8 81 dd ff ff       	call   f0103a0b <cprintf>
		return NULL;
f0105c8a:	83 c4 10             	add    $0x10,%esp
f0105c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105c92:	eb c8                	jmp    f0105c5c <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c94:	83 ec 0c             	sub    $0xc,%esp
f0105c97:	68 94 80 10 f0       	push   $0xf0108094
f0105c9c:	e8 6a dd ff ff       	call   f0103a0b <cprintf>
		return NULL;
f0105ca1:	83 c4 10             	add    $0x10,%esp
f0105ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105ca9:	eb b1                	jmp    f0105c5c <mpconfig+0x86>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105cab:	83 ec 08             	sub    $0x8,%esp
f0105cae:	0f b6 c0             	movzbl %al,%eax
f0105cb1:	50                   	push   %eax
f0105cb2:	68 b8 80 10 f0       	push   $0xf01080b8
f0105cb7:	e8 4f dd ff ff       	call   f0103a0b <cprintf>
		return NULL;
f0105cbc:	83 c4 10             	add    $0x10,%esp
f0105cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105cc4:	eb 96                	jmp    f0105c5c <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105cc6:	83 ec 0c             	sub    $0xc,%esp
f0105cc9:	68 d8 80 10 f0       	push   $0xf01080d8
f0105cce:	e8 38 dd ff ff       	call   f0103a0b <cprintf>
		return NULL;
f0105cd3:	83 c4 10             	add    $0x10,%esp
f0105cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105cdb:	e9 7c ff ff ff       	jmp    f0105c5c <mpconfig+0x86>
		return NULL;
f0105ce0:	89 c3                	mov    %eax,%ebx
f0105ce2:	e9 75 ff ff ff       	jmp    f0105c5c <mpconfig+0x86>

f0105ce7 <mp_init>:

void
mp_init(void)
{
f0105ce7:	f3 0f 1e fb          	endbr32 
f0105ceb:	55                   	push   %ebp
f0105cec:	89 e5                	mov    %esp,%ebp
f0105cee:	57                   	push   %edi
f0105cef:	56                   	push   %esi
f0105cf0:	53                   	push   %ebx
f0105cf1:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105cf4:	c7 05 c0 33 22 f0 20 	movl   $0xf0223020,0xf02233c0
f0105cfb:	30 22 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0105cfe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105d01:	e8 d0 fe ff ff       	call   f0105bd6 <mpconfig>
f0105d06:	85 c0                	test   %eax,%eax
f0105d08:	0f 84 e5 00 00 00    	je     f0105df3 <mp_init+0x10c>
f0105d0e:	89 c7                	mov    %eax,%edi
		return;
	ismp = 1;
f0105d10:	c7 05 00 30 22 f0 01 	movl   $0x1,0xf0223000
f0105d17:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105d1a:	8b 40 24             	mov    0x24(%eax),%eax
f0105d1d:	a3 00 40 26 f0       	mov    %eax,0xf0264000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d22:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105d25:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d2a:	eb 38                	jmp    f0105d64 <mp_init+0x7d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105d2c:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105d30:	74 11                	je     f0105d43 <mp_init+0x5c>
				bootcpu = &cpus[ncpu];
f0105d32:	6b 05 c4 33 22 f0 74 	imul   $0x74,0xf02233c4,%eax
f0105d39:	05 20 30 22 f0       	add    $0xf0223020,%eax
f0105d3e:	a3 c0 33 22 f0       	mov    %eax,0xf02233c0
			if (ncpu < NCPU) {
f0105d43:	a1 c4 33 22 f0       	mov    0xf02233c4,%eax
f0105d48:	83 f8 07             	cmp    $0x7,%eax
f0105d4b:	7f 33                	jg     f0105d80 <mp_init+0x99>
				cpus[ncpu].cpu_id = ncpu;
f0105d4d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d50:	88 82 20 30 22 f0    	mov    %al,-0xfddcfe0(%edx)
				ncpu++;
f0105d56:	83 c0 01             	add    $0x1,%eax
f0105d59:	a3 c4 33 22 f0       	mov    %eax,0xf02233c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d5e:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d61:	83 c3 01             	add    $0x1,%ebx
f0105d64:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105d68:	39 d8                	cmp    %ebx,%eax
f0105d6a:	76 4f                	jbe    f0105dbb <mp_init+0xd4>
		switch (*p) {
f0105d6c:	0f b6 06             	movzbl (%esi),%eax
f0105d6f:	84 c0                	test   %al,%al
f0105d71:	74 b9                	je     f0105d2c <mp_init+0x45>
f0105d73:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105d76:	80 fa 03             	cmp    $0x3,%dl
f0105d79:	77 1c                	ja     f0105d97 <mp_init+0xb0>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d7b:	83 c6 08             	add    $0x8,%esi
			continue;
f0105d7e:	eb e1                	jmp    f0105d61 <mp_init+0x7a>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d80:	83 ec 08             	sub    $0x8,%esp
f0105d83:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105d87:	50                   	push   %eax
f0105d88:	68 08 81 10 f0       	push   $0xf0108108
f0105d8d:	e8 79 dc ff ff       	call   f0103a0b <cprintf>
f0105d92:	83 c4 10             	add    $0x10,%esp
f0105d95:	eb c7                	jmp    f0105d5e <mp_init+0x77>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d97:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105d9a:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d9d:	50                   	push   %eax
f0105d9e:	68 30 81 10 f0       	push   $0xf0108130
f0105da3:	e8 63 dc ff ff       	call   f0103a0b <cprintf>
			ismp = 0;
f0105da8:	c7 05 00 30 22 f0 00 	movl   $0x0,0xf0223000
f0105daf:	00 00 00 
			i = conf->entry;
f0105db2:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0105db6:	83 c4 10             	add    $0x10,%esp
f0105db9:	eb a6                	jmp    f0105d61 <mp_init+0x7a>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105dbb:	a1 c0 33 22 f0       	mov    0xf02233c0,%eax
f0105dc0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105dc7:	83 3d 00 30 22 f0 00 	cmpl   $0x0,0xf0223000
f0105dce:	74 2b                	je     f0105dfb <mp_init+0x114>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105dd0:	83 ec 04             	sub    $0x4,%esp
f0105dd3:	ff 35 c4 33 22 f0    	pushl  0xf02233c4
f0105dd9:	0f b6 00             	movzbl (%eax),%eax
f0105ddc:	50                   	push   %eax
f0105ddd:	68 d7 81 10 f0       	push   $0xf01081d7
f0105de2:	e8 24 dc ff ff       	call   f0103a0b <cprintf>

	if (mp->imcrp) {
f0105de7:	83 c4 10             	add    $0x10,%esp
f0105dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ded:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105df1:	75 2e                	jne    f0105e21 <mp_init+0x13a>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105df6:	5b                   	pop    %ebx
f0105df7:	5e                   	pop    %esi
f0105df8:	5f                   	pop    %edi
f0105df9:	5d                   	pop    %ebp
f0105dfa:	c3                   	ret    
		ncpu = 1;
f0105dfb:	c7 05 c4 33 22 f0 01 	movl   $0x1,0xf02233c4
f0105e02:	00 00 00 
		lapicaddr = 0;
f0105e05:	c7 05 00 40 26 f0 00 	movl   $0x0,0xf0264000
f0105e0c:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105e0f:	83 ec 0c             	sub    $0xc,%esp
f0105e12:	68 50 81 10 f0       	push   $0xf0108150
f0105e17:	e8 ef db ff ff       	call   f0103a0b <cprintf>
		return;
f0105e1c:	83 c4 10             	add    $0x10,%esp
f0105e1f:	eb d2                	jmp    f0105df3 <mp_init+0x10c>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105e21:	83 ec 0c             	sub    $0xc,%esp
f0105e24:	68 7c 81 10 f0       	push   $0xf010817c
f0105e29:	e8 dd db ff ff       	call   f0103a0b <cprintf>
		outb(0x22, 0x70);   // Select IMCR
f0105e2e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e33:	b8 22 00 00 00       	mov    $0x22,%eax
f0105e38:	e8 6a fc ff ff       	call   f0105aa7 <outb>
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105e3d:	b8 23 00 00 00       	mov    $0x23,%eax
f0105e42:	e8 5c fc ff ff       	call   f0105aa3 <inb>
f0105e47:	83 c8 01             	or     $0x1,%eax
f0105e4a:	0f b6 d0             	movzbl %al,%edx
f0105e4d:	b8 23 00 00 00       	mov    $0x23,%eax
f0105e52:	e8 50 fc ff ff       	call   f0105aa7 <outb>
f0105e57:	83 c4 10             	add    $0x10,%esp
f0105e5a:	eb 97                	jmp    f0105df3 <mp_init+0x10c>

f0105e5c <outb>:
{
f0105e5c:	89 c1                	mov    %eax,%ecx
f0105e5e:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e60:	89 ca                	mov    %ecx,%edx
f0105e62:	ee                   	out    %al,(%dx)
}
f0105e63:	c3                   	ret    

f0105e64 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105e64:	8b 0d 04 40 26 f0    	mov    0xf0264004,%ecx
f0105e6a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105e6d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e6f:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f0105e74:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e77:	c3                   	ret    

f0105e78 <_kaddr>:
{
f0105e78:	55                   	push   %ebp
f0105e79:	89 e5                	mov    %esp,%ebp
f0105e7b:	53                   	push   %ebx
f0105e7c:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105e7f:	89 cb                	mov    %ecx,%ebx
f0105e81:	c1 eb 0c             	shr    $0xc,%ebx
f0105e84:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0105e8a:	73 0b                	jae    f0105e97 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0105e8c:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105e92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105e95:	c9                   	leave  
f0105e96:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e97:	51                   	push   %ecx
f0105e98:	68 8c 65 10 f0       	push   $0xf010658c
f0105e9d:	52                   	push   %edx
f0105e9e:	50                   	push   %eax
f0105e9f:	e8 c6 a1 ff ff       	call   f010006a <_panic>

f0105ea4 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105ea4:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0105ea8:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105eae:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105eb3:	85 d2                	test   %edx,%edx
f0105eb5:	74 06                	je     f0105ebd <cpunum+0x19>
		return lapic[ID] >> 24;
f0105eb7:	8b 42 20             	mov    0x20(%edx),%eax
f0105eba:	c1 e8 18             	shr    $0x18,%eax
}
f0105ebd:	c3                   	ret    

f0105ebe <lapic_init>:
{
f0105ebe:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0105ec2:	a1 00 40 26 f0       	mov    0xf0264000,%eax
f0105ec7:	85 c0                	test   %eax,%eax
f0105ec9:	75 01                	jne    f0105ecc <lapic_init+0xe>
f0105ecb:	c3                   	ret    
{
f0105ecc:	55                   	push   %ebp
f0105ecd:	89 e5                	mov    %esp,%ebp
f0105ecf:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105ed2:	68 00 10 00 00       	push   $0x1000
f0105ed7:	50                   	push   %eax
f0105ed8:	e8 53 c0 ff ff       	call   f0101f30 <mmio_map_region>
f0105edd:	a3 04 40 26 f0       	mov    %eax,0xf0264004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105ee2:	ba 27 01 00 00       	mov    $0x127,%edx
f0105ee7:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105eec:	e8 73 ff ff ff       	call   f0105e64 <lapicw>
	lapicw(TDCR, X1);
f0105ef1:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105ef6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105efb:	e8 64 ff ff ff       	call   f0105e64 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105f00:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105f05:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105f0a:	e8 55 ff ff ff       	call   f0105e64 <lapicw>
	lapicw(TICR, 10000000); 
f0105f0f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105f14:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105f19:	e8 46 ff ff ff       	call   f0105e64 <lapicw>
	if (thiscpu != bootcpu)
f0105f1e:	e8 81 ff ff ff       	call   f0105ea4 <cpunum>
f0105f23:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f26:	05 20 30 22 f0       	add    $0xf0223020,%eax
f0105f2b:	83 c4 10             	add    $0x10,%esp
f0105f2e:	39 05 c0 33 22 f0    	cmp    %eax,0xf02233c0
f0105f34:	74 0f                	je     f0105f45 <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0105f36:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f3b:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105f40:	e8 1f ff ff ff       	call   f0105e64 <lapicw>
	lapicw(LINT1, MASKED);
f0105f45:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f4a:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105f4f:	e8 10 ff ff ff       	call   f0105e64 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105f54:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f0105f59:	8b 40 30             	mov    0x30(%eax),%eax
f0105f5c:	c1 e8 10             	shr    $0x10,%eax
f0105f5f:	a8 fc                	test   $0xfc,%al
f0105f61:	75 7c                	jne    f0105fdf <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105f63:	ba 33 00 00 00       	mov    $0x33,%edx
f0105f68:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105f6d:	e8 f2 fe ff ff       	call   f0105e64 <lapicw>
	lapicw(ESR, 0);
f0105f72:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f77:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f7c:	e8 e3 fe ff ff       	call   f0105e64 <lapicw>
	lapicw(ESR, 0);
f0105f81:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f86:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f8b:	e8 d4 fe ff ff       	call   f0105e64 <lapicw>
	lapicw(EOI, 0);
f0105f90:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f95:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f9a:	e8 c5 fe ff ff       	call   f0105e64 <lapicw>
	lapicw(ICRHI, 0);
f0105f9f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fa4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fa9:	e8 b6 fe ff ff       	call   f0105e64 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105fae:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105fb3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fb8:	e8 a7 fe ff ff       	call   f0105e64 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105fbd:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
f0105fc3:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fc9:	f6 c4 10             	test   $0x10,%ah
f0105fcc:	75 f5                	jne    f0105fc3 <lapic_init+0x105>
	lapicw(TPR, 0);
f0105fce:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fd3:	b8 20 00 00 00       	mov    $0x20,%eax
f0105fd8:	e8 87 fe ff ff       	call   f0105e64 <lapicw>
}
f0105fdd:	c9                   	leave  
f0105fde:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105fdf:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fe4:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105fe9:	e8 76 fe ff ff       	call   f0105e64 <lapicw>
f0105fee:	e9 70 ff ff ff       	jmp    f0105f63 <lapic_init+0xa5>

f0105ff3 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105ff3:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0105ff7:	83 3d 04 40 26 f0 00 	cmpl   $0x0,0xf0264004
f0105ffe:	74 17                	je     f0106017 <lapic_eoi+0x24>
{
f0106000:	55                   	push   %ebp
f0106001:	89 e5                	mov    %esp,%ebp
f0106003:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0106006:	ba 00 00 00 00       	mov    $0x0,%edx
f010600b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106010:	e8 4f fe ff ff       	call   f0105e64 <lapicw>
}
f0106015:	c9                   	leave  
f0106016:	c3                   	ret    
f0106017:	c3                   	ret    

f0106018 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106018:	f3 0f 1e fb          	endbr32 
f010601c:	55                   	push   %ebp
f010601d:	89 e5                	mov    %esp,%ebp
f010601f:	56                   	push   %esi
f0106020:	53                   	push   %ebx
f0106021:	8b 75 08             	mov    0x8(%ebp),%esi
f0106024:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint16_t *wrv;

	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
f0106027:	ba 0f 00 00 00       	mov    $0xf,%edx
f010602c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106031:	e8 26 fe ff ff       	call   f0105e5c <outb>
	outb(IO_RTC+1, 0x0A);
f0106036:	ba 0a 00 00 00       	mov    $0xa,%edx
f010603b:	b8 71 00 00 00       	mov    $0x71,%eax
f0106040:	e8 17 fe ff ff       	call   f0105e5c <outb>
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f0106045:	b9 67 04 00 00       	mov    $0x467,%ecx
f010604a:	ba 98 00 00 00       	mov    $0x98,%edx
f010604f:	b8 f4 81 10 f0       	mov    $0xf01081f4,%eax
f0106054:	e8 1f fe ff ff       	call   f0105e78 <_kaddr>
	wrv[0] = 0;
f0106059:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f010605e:	89 da                	mov    %ebx,%edx
f0106060:	c1 ea 04             	shr    $0x4,%edx
f0106063:	66 89 50 02          	mov    %dx,0x2(%eax)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106067:	c1 e6 18             	shl    $0x18,%esi
f010606a:	89 f2                	mov    %esi,%edx
f010606c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106071:	e8 ee fd ff ff       	call   f0105e64 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106076:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010607b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106080:	e8 df fd ff ff       	call   f0105e64 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106085:	ba 00 85 00 00       	mov    $0x8500,%edx
f010608a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010608f:	e8 d0 fd ff ff       	call   f0105e64 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106094:	c1 eb 0c             	shr    $0xc,%ebx
f0106097:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010609a:	89 f2                	mov    %esi,%edx
f010609c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060a1:	e8 be fd ff ff       	call   f0105e64 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060a6:	89 da                	mov    %ebx,%edx
f01060a8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060ad:	e8 b2 fd ff ff       	call   f0105e64 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01060b2:	89 f2                	mov    %esi,%edx
f01060b4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060b9:	e8 a6 fd ff ff       	call   f0105e64 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060be:	89 da                	mov    %ebx,%edx
f01060c0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060c5:	e8 9a fd ff ff       	call   f0105e64 <lapicw>
		microdelay(200);
	}
}
f01060ca:	5b                   	pop    %ebx
f01060cb:	5e                   	pop    %esi
f01060cc:	5d                   	pop    %ebp
f01060cd:	c3                   	ret    

f01060ce <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01060ce:	f3 0f 1e fb          	endbr32 
f01060d2:	55                   	push   %ebp
f01060d3:	89 e5                	mov    %esp,%ebp
f01060d5:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01060d8:	8b 55 08             	mov    0x8(%ebp),%edx
f01060db:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01060e1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060e6:	e8 79 fd ff ff       	call   f0105e64 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01060eb:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
f01060f1:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01060f7:	f6 c4 10             	test   $0x10,%ah
f01060fa:	75 f5                	jne    f01060f1 <lapic_ipi+0x23>
		;
}
f01060fc:	c9                   	leave  
f01060fd:	c3                   	ret    

f01060fe <xchg>:
{
f01060fe:	89 c1                	mov    %eax,%ecx
f0106100:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f0106102:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0106105:	c3                   	ret    

f0106106 <get_caller_pcs>:
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106106:	89 e9                	mov    %ebp,%ecx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106108:	ba 00 00 00 00       	mov    $0x0,%edx
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010610d:	81 f9 ff ff 7f ef    	cmp    $0xef7fffff,%ecx
f0106113:	76 3f                	jbe    f0106154 <get_caller_pcs+0x4e>
f0106115:	83 fa 09             	cmp    $0x9,%edx
f0106118:	7f 3a                	jg     f0106154 <get_caller_pcs+0x4e>
{
f010611a:	55                   	push   %ebp
f010611b:	89 e5                	mov    %esp,%ebp
f010611d:	53                   	push   %ebx
			break;
		pcs[i] = ebp[1];          // saved %eip
f010611e:	8b 59 04             	mov    0x4(%ecx),%ebx
f0106121:	89 1c 90             	mov    %ebx,(%eax,%edx,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106124:	8b 09                	mov    (%ecx),%ecx
	for (i = 0; i < 10; i++){
f0106126:	83 c2 01             	add    $0x1,%edx
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106129:	81 f9 ff ff 7f ef    	cmp    $0xef7fffff,%ecx
f010612f:	76 11                	jbe    f0106142 <get_caller_pcs+0x3c>
f0106131:	83 fa 09             	cmp    $0x9,%edx
f0106134:	7e e8                	jle    f010611e <get_caller_pcs+0x18>
f0106136:	eb 0a                	jmp    f0106142 <get_caller_pcs+0x3c>
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106138:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	for (; i < 10; i++)
f010613f:	83 c2 01             	add    $0x1,%edx
f0106142:	83 fa 09             	cmp    $0x9,%edx
f0106145:	7e f1                	jle    f0106138 <get_caller_pcs+0x32>
}
f0106147:	5b                   	pop    %ebx
f0106148:	5d                   	pop    %ebp
f0106149:	c3                   	ret    
		pcs[i] = 0;
f010614a:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	for (; i < 10; i++)
f0106151:	83 c2 01             	add    $0x1,%edx
f0106154:	83 fa 09             	cmp    $0x9,%edx
f0106157:	7e f1                	jle    f010614a <get_caller_pcs+0x44>
f0106159:	c3                   	ret    

f010615a <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010615a:	83 38 00             	cmpl   $0x0,(%eax)
f010615d:	75 06                	jne    f0106165 <holding+0xb>
f010615f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106164:	c3                   	ret    
{
f0106165:	55                   	push   %ebp
f0106166:	89 e5                	mov    %esp,%ebp
f0106168:	53                   	push   %ebx
f0106169:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010616c:	8b 58 08             	mov    0x8(%eax),%ebx
f010616f:	e8 30 fd ff ff       	call   f0105ea4 <cpunum>
f0106174:	6b c0 74             	imul   $0x74,%eax,%eax
f0106177:	05 20 30 22 f0       	add    $0xf0223020,%eax
f010617c:	39 c3                	cmp    %eax,%ebx
f010617e:	0f 94 c0             	sete   %al
f0106181:	0f b6 c0             	movzbl %al,%eax
}
f0106184:	83 c4 04             	add    $0x4,%esp
f0106187:	5b                   	pop    %ebx
f0106188:	5d                   	pop    %ebp
f0106189:	c3                   	ret    

f010618a <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010618a:	f3 0f 1e fb          	endbr32 
f010618e:	55                   	push   %ebp
f010618f:	89 e5                	mov    %esp,%ebp
f0106191:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106194:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010619a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010619d:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01061a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01061a7:	5d                   	pop    %ebp
f01061a8:	c3                   	ret    

f01061a9 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01061a9:	f3 0f 1e fb          	endbr32 
f01061ad:	55                   	push   %ebp
f01061ae:	89 e5                	mov    %esp,%ebp
f01061b0:	53                   	push   %ebx
f01061b1:	83 ec 04             	sub    $0x4,%esp
f01061b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01061b7:	89 d8                	mov    %ebx,%eax
f01061b9:	e8 9c ff ff ff       	call   f010615a <holding>
f01061be:	85 c0                	test   %eax,%eax
f01061c0:	74 20                	je     f01061e2 <spin_lock+0x39>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01061c2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01061c5:	e8 da fc ff ff       	call   f0105ea4 <cpunum>
f01061ca:	83 ec 0c             	sub    $0xc,%esp
f01061cd:	53                   	push   %ebx
f01061ce:	50                   	push   %eax
f01061cf:	68 04 82 10 f0       	push   $0xf0108204
f01061d4:	6a 41                	push   $0x41
f01061d6:	68 66 82 10 f0       	push   $0xf0108266
f01061db:	e8 8a 9e ff ff       	call   f010006a <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01061e0:	f3 90                	pause  
	while (xchg(&lk->locked, 1) != 0)
f01061e2:	ba 01 00 00 00       	mov    $0x1,%edx
f01061e7:	89 d8                	mov    %ebx,%eax
f01061e9:	e8 10 ff ff ff       	call   f01060fe <xchg>
f01061ee:	85 c0                	test   %eax,%eax
f01061f0:	75 ee                	jne    f01061e0 <spin_lock+0x37>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01061f2:	e8 ad fc ff ff       	call   f0105ea4 <cpunum>
f01061f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01061fa:	05 20 30 22 f0       	add    $0xf0223020,%eax
f01061ff:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106202:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106205:	e8 fc fe ff ff       	call   f0106106 <get_caller_pcs>
#endif
}
f010620a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010620d:	c9                   	leave  
f010620e:	c3                   	ret    

f010620f <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010620f:	f3 0f 1e fb          	endbr32 
f0106213:	55                   	push   %ebp
f0106214:	89 e5                	mov    %esp,%ebp
f0106216:	57                   	push   %edi
f0106217:	56                   	push   %esi
f0106218:	53                   	push   %ebx
f0106219:	83 ec 4c             	sub    $0x4c,%esp
f010621c:	8b 75 08             	mov    0x8(%ebp),%esi
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010621f:	89 f0                	mov    %esi,%eax
f0106221:	e8 34 ff ff ff       	call   f010615a <holding>
f0106226:	85 c0                	test   %eax,%eax
f0106228:	74 22                	je     f010624c <spin_unlock+0x3d>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010622a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106231:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	// The xchg instruction is atomic (i.e. uses the "lock" prefix) with
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
f0106238:	ba 00 00 00 00       	mov    $0x0,%edx
f010623d:	89 f0                	mov    %esi,%eax
f010623f:	e8 ba fe ff ff       	call   f01060fe <xchg>
}
f0106244:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106247:	5b                   	pop    %ebx
f0106248:	5e                   	pop    %esi
f0106249:	5f                   	pop    %edi
f010624a:	5d                   	pop    %ebp
f010624b:	c3                   	ret    
		memmove(pcs, lk->pcs, sizeof pcs);
f010624c:	83 ec 04             	sub    $0x4,%esp
f010624f:	6a 28                	push   $0x28
f0106251:	8d 46 0c             	lea    0xc(%esi),%eax
f0106254:	50                   	push   %eax
f0106255:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106258:	53                   	push   %ebx
f0106259:	e8 03 f6 ff ff       	call   f0105861 <memmove>
			cpunum(), lk->name, lk->cpu->cpu_id);
f010625e:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106261:	0f b6 38             	movzbl (%eax),%edi
f0106264:	8b 76 04             	mov    0x4(%esi),%esi
f0106267:	e8 38 fc ff ff       	call   f0105ea4 <cpunum>
f010626c:	57                   	push   %edi
f010626d:	56                   	push   %esi
f010626e:	50                   	push   %eax
f010626f:	68 30 82 10 f0       	push   $0xf0108230
f0106274:	e8 92 d7 ff ff       	call   f0103a0b <cprintf>
f0106279:	83 c4 20             	add    $0x20,%esp
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010627c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010627f:	eb 1c                	jmp    f010629d <spin_unlock+0x8e>
				cprintf("  %08x\n", pcs[i]);
f0106281:	83 ec 08             	sub    $0x8,%esp
f0106284:	ff 36                	pushl  (%esi)
f0106286:	68 8d 82 10 f0       	push   $0xf010828d
f010628b:	e8 7b d7 ff ff       	call   f0103a0b <cprintf>
f0106290:	83 c4 10             	add    $0x10,%esp
f0106293:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106296:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106299:	39 c3                	cmp    %eax,%ebx
f010629b:	74 40                	je     f01062dd <spin_unlock+0xce>
f010629d:	89 de                	mov    %ebx,%esi
f010629f:	8b 03                	mov    (%ebx),%eax
f01062a1:	85 c0                	test   %eax,%eax
f01062a3:	74 38                	je     f01062dd <spin_unlock+0xce>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01062a5:	83 ec 08             	sub    $0x8,%esp
f01062a8:	57                   	push   %edi
f01062a9:	50                   	push   %eax
f01062aa:	e8 c6 ea ff ff       	call   f0104d75 <debuginfo_eip>
f01062af:	83 c4 10             	add    $0x10,%esp
f01062b2:	85 c0                	test   %eax,%eax
f01062b4:	78 cb                	js     f0106281 <spin_unlock+0x72>
					pcs[i] - info.eip_fn_addr);
f01062b6:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01062b8:	83 ec 04             	sub    $0x4,%esp
f01062bb:	89 c2                	mov    %eax,%edx
f01062bd:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01062c0:	52                   	push   %edx
f01062c1:	ff 75 b0             	pushl  -0x50(%ebp)
f01062c4:	ff 75 b4             	pushl  -0x4c(%ebp)
f01062c7:	ff 75 ac             	pushl  -0x54(%ebp)
f01062ca:	ff 75 a8             	pushl  -0x58(%ebp)
f01062cd:	50                   	push   %eax
f01062ce:	68 76 82 10 f0       	push   $0xf0108276
f01062d3:	e8 33 d7 ff ff       	call   f0103a0b <cprintf>
f01062d8:	83 c4 20             	add    $0x20,%esp
f01062db:	eb b6                	jmp    f0106293 <spin_unlock+0x84>
		panic("spin_unlock");
f01062dd:	83 ec 04             	sub    $0x4,%esp
f01062e0:	68 95 82 10 f0       	push   $0xf0108295
f01062e5:	6a 67                	push   $0x67
f01062e7:	68 66 82 10 f0       	push   $0xf0108266
f01062ec:	e8 79 9d ff ff       	call   f010006a <_panic>
f01062f1:	66 90                	xchg   %ax,%ax
f01062f3:	66 90                	xchg   %ax,%ax
f01062f5:	66 90                	xchg   %ax,%ax
f01062f7:	66 90                	xchg   %ax,%ax
f01062f9:	66 90                	xchg   %ax,%ax
f01062fb:	66 90                	xchg   %ax,%ax
f01062fd:	66 90                	xchg   %ax,%ax
f01062ff:	90                   	nop

f0106300 <__udivdi3>:
f0106300:	f3 0f 1e fb          	endbr32 
f0106304:	55                   	push   %ebp
f0106305:	57                   	push   %edi
f0106306:	56                   	push   %esi
f0106307:	53                   	push   %ebx
f0106308:	83 ec 1c             	sub    $0x1c,%esp
f010630b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010630f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106313:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106317:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010631b:	85 d2                	test   %edx,%edx
f010631d:	75 19                	jne    f0106338 <__udivdi3+0x38>
f010631f:	39 f3                	cmp    %esi,%ebx
f0106321:	76 4d                	jbe    f0106370 <__udivdi3+0x70>
f0106323:	31 ff                	xor    %edi,%edi
f0106325:	89 e8                	mov    %ebp,%eax
f0106327:	89 f2                	mov    %esi,%edx
f0106329:	f7 f3                	div    %ebx
f010632b:	89 fa                	mov    %edi,%edx
f010632d:	83 c4 1c             	add    $0x1c,%esp
f0106330:	5b                   	pop    %ebx
f0106331:	5e                   	pop    %esi
f0106332:	5f                   	pop    %edi
f0106333:	5d                   	pop    %ebp
f0106334:	c3                   	ret    
f0106335:	8d 76 00             	lea    0x0(%esi),%esi
f0106338:	39 f2                	cmp    %esi,%edx
f010633a:	76 14                	jbe    f0106350 <__udivdi3+0x50>
f010633c:	31 ff                	xor    %edi,%edi
f010633e:	31 c0                	xor    %eax,%eax
f0106340:	89 fa                	mov    %edi,%edx
f0106342:	83 c4 1c             	add    $0x1c,%esp
f0106345:	5b                   	pop    %ebx
f0106346:	5e                   	pop    %esi
f0106347:	5f                   	pop    %edi
f0106348:	5d                   	pop    %ebp
f0106349:	c3                   	ret    
f010634a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106350:	0f bd fa             	bsr    %edx,%edi
f0106353:	83 f7 1f             	xor    $0x1f,%edi
f0106356:	75 48                	jne    f01063a0 <__udivdi3+0xa0>
f0106358:	39 f2                	cmp    %esi,%edx
f010635a:	72 06                	jb     f0106362 <__udivdi3+0x62>
f010635c:	31 c0                	xor    %eax,%eax
f010635e:	39 eb                	cmp    %ebp,%ebx
f0106360:	77 de                	ja     f0106340 <__udivdi3+0x40>
f0106362:	b8 01 00 00 00       	mov    $0x1,%eax
f0106367:	eb d7                	jmp    f0106340 <__udivdi3+0x40>
f0106369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106370:	89 d9                	mov    %ebx,%ecx
f0106372:	85 db                	test   %ebx,%ebx
f0106374:	75 0b                	jne    f0106381 <__udivdi3+0x81>
f0106376:	b8 01 00 00 00       	mov    $0x1,%eax
f010637b:	31 d2                	xor    %edx,%edx
f010637d:	f7 f3                	div    %ebx
f010637f:	89 c1                	mov    %eax,%ecx
f0106381:	31 d2                	xor    %edx,%edx
f0106383:	89 f0                	mov    %esi,%eax
f0106385:	f7 f1                	div    %ecx
f0106387:	89 c6                	mov    %eax,%esi
f0106389:	89 e8                	mov    %ebp,%eax
f010638b:	89 f7                	mov    %esi,%edi
f010638d:	f7 f1                	div    %ecx
f010638f:	89 fa                	mov    %edi,%edx
f0106391:	83 c4 1c             	add    $0x1c,%esp
f0106394:	5b                   	pop    %ebx
f0106395:	5e                   	pop    %esi
f0106396:	5f                   	pop    %edi
f0106397:	5d                   	pop    %ebp
f0106398:	c3                   	ret    
f0106399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01063a0:	89 f9                	mov    %edi,%ecx
f01063a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01063a7:	29 f8                	sub    %edi,%eax
f01063a9:	d3 e2                	shl    %cl,%edx
f01063ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063af:	89 c1                	mov    %eax,%ecx
f01063b1:	89 da                	mov    %ebx,%edx
f01063b3:	d3 ea                	shr    %cl,%edx
f01063b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01063b9:	09 d1                	or     %edx,%ecx
f01063bb:	89 f2                	mov    %esi,%edx
f01063bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063c1:	89 f9                	mov    %edi,%ecx
f01063c3:	d3 e3                	shl    %cl,%ebx
f01063c5:	89 c1                	mov    %eax,%ecx
f01063c7:	d3 ea                	shr    %cl,%edx
f01063c9:	89 f9                	mov    %edi,%ecx
f01063cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01063cf:	89 eb                	mov    %ebp,%ebx
f01063d1:	d3 e6                	shl    %cl,%esi
f01063d3:	89 c1                	mov    %eax,%ecx
f01063d5:	d3 eb                	shr    %cl,%ebx
f01063d7:	09 de                	or     %ebx,%esi
f01063d9:	89 f0                	mov    %esi,%eax
f01063db:	f7 74 24 08          	divl   0x8(%esp)
f01063df:	89 d6                	mov    %edx,%esi
f01063e1:	89 c3                	mov    %eax,%ebx
f01063e3:	f7 64 24 0c          	mull   0xc(%esp)
f01063e7:	39 d6                	cmp    %edx,%esi
f01063e9:	72 15                	jb     f0106400 <__udivdi3+0x100>
f01063eb:	89 f9                	mov    %edi,%ecx
f01063ed:	d3 e5                	shl    %cl,%ebp
f01063ef:	39 c5                	cmp    %eax,%ebp
f01063f1:	73 04                	jae    f01063f7 <__udivdi3+0xf7>
f01063f3:	39 d6                	cmp    %edx,%esi
f01063f5:	74 09                	je     f0106400 <__udivdi3+0x100>
f01063f7:	89 d8                	mov    %ebx,%eax
f01063f9:	31 ff                	xor    %edi,%edi
f01063fb:	e9 40 ff ff ff       	jmp    f0106340 <__udivdi3+0x40>
f0106400:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106403:	31 ff                	xor    %edi,%edi
f0106405:	e9 36 ff ff ff       	jmp    f0106340 <__udivdi3+0x40>
f010640a:	66 90                	xchg   %ax,%ax
f010640c:	66 90                	xchg   %ax,%ax
f010640e:	66 90                	xchg   %ax,%ax

f0106410 <__umoddi3>:
f0106410:	f3 0f 1e fb          	endbr32 
f0106414:	55                   	push   %ebp
f0106415:	57                   	push   %edi
f0106416:	56                   	push   %esi
f0106417:	53                   	push   %ebx
f0106418:	83 ec 1c             	sub    $0x1c,%esp
f010641b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010641f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106423:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106427:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010642b:	85 c0                	test   %eax,%eax
f010642d:	75 19                	jne    f0106448 <__umoddi3+0x38>
f010642f:	39 df                	cmp    %ebx,%edi
f0106431:	76 5d                	jbe    f0106490 <__umoddi3+0x80>
f0106433:	89 f0                	mov    %esi,%eax
f0106435:	89 da                	mov    %ebx,%edx
f0106437:	f7 f7                	div    %edi
f0106439:	89 d0                	mov    %edx,%eax
f010643b:	31 d2                	xor    %edx,%edx
f010643d:	83 c4 1c             	add    $0x1c,%esp
f0106440:	5b                   	pop    %ebx
f0106441:	5e                   	pop    %esi
f0106442:	5f                   	pop    %edi
f0106443:	5d                   	pop    %ebp
f0106444:	c3                   	ret    
f0106445:	8d 76 00             	lea    0x0(%esi),%esi
f0106448:	89 f2                	mov    %esi,%edx
f010644a:	39 d8                	cmp    %ebx,%eax
f010644c:	76 12                	jbe    f0106460 <__umoddi3+0x50>
f010644e:	89 f0                	mov    %esi,%eax
f0106450:	89 da                	mov    %ebx,%edx
f0106452:	83 c4 1c             	add    $0x1c,%esp
f0106455:	5b                   	pop    %ebx
f0106456:	5e                   	pop    %esi
f0106457:	5f                   	pop    %edi
f0106458:	5d                   	pop    %ebp
f0106459:	c3                   	ret    
f010645a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106460:	0f bd e8             	bsr    %eax,%ebp
f0106463:	83 f5 1f             	xor    $0x1f,%ebp
f0106466:	75 50                	jne    f01064b8 <__umoddi3+0xa8>
f0106468:	39 d8                	cmp    %ebx,%eax
f010646a:	0f 82 e0 00 00 00    	jb     f0106550 <__umoddi3+0x140>
f0106470:	89 d9                	mov    %ebx,%ecx
f0106472:	39 f7                	cmp    %esi,%edi
f0106474:	0f 86 d6 00 00 00    	jbe    f0106550 <__umoddi3+0x140>
f010647a:	89 d0                	mov    %edx,%eax
f010647c:	89 ca                	mov    %ecx,%edx
f010647e:	83 c4 1c             	add    $0x1c,%esp
f0106481:	5b                   	pop    %ebx
f0106482:	5e                   	pop    %esi
f0106483:	5f                   	pop    %edi
f0106484:	5d                   	pop    %ebp
f0106485:	c3                   	ret    
f0106486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010648d:	8d 76 00             	lea    0x0(%esi),%esi
f0106490:	89 fd                	mov    %edi,%ebp
f0106492:	85 ff                	test   %edi,%edi
f0106494:	75 0b                	jne    f01064a1 <__umoddi3+0x91>
f0106496:	b8 01 00 00 00       	mov    $0x1,%eax
f010649b:	31 d2                	xor    %edx,%edx
f010649d:	f7 f7                	div    %edi
f010649f:	89 c5                	mov    %eax,%ebp
f01064a1:	89 d8                	mov    %ebx,%eax
f01064a3:	31 d2                	xor    %edx,%edx
f01064a5:	f7 f5                	div    %ebp
f01064a7:	89 f0                	mov    %esi,%eax
f01064a9:	f7 f5                	div    %ebp
f01064ab:	89 d0                	mov    %edx,%eax
f01064ad:	31 d2                	xor    %edx,%edx
f01064af:	eb 8c                	jmp    f010643d <__umoddi3+0x2d>
f01064b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064b8:	89 e9                	mov    %ebp,%ecx
f01064ba:	ba 20 00 00 00       	mov    $0x20,%edx
f01064bf:	29 ea                	sub    %ebp,%edx
f01064c1:	d3 e0                	shl    %cl,%eax
f01064c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01064c7:	89 d1                	mov    %edx,%ecx
f01064c9:	89 f8                	mov    %edi,%eax
f01064cb:	d3 e8                	shr    %cl,%eax
f01064cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01064d1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01064d5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01064d9:	09 c1                	or     %eax,%ecx
f01064db:	89 d8                	mov    %ebx,%eax
f01064dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01064e1:	89 e9                	mov    %ebp,%ecx
f01064e3:	d3 e7                	shl    %cl,%edi
f01064e5:	89 d1                	mov    %edx,%ecx
f01064e7:	d3 e8                	shr    %cl,%eax
f01064e9:	89 e9                	mov    %ebp,%ecx
f01064eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01064ef:	d3 e3                	shl    %cl,%ebx
f01064f1:	89 c7                	mov    %eax,%edi
f01064f3:	89 d1                	mov    %edx,%ecx
f01064f5:	89 f0                	mov    %esi,%eax
f01064f7:	d3 e8                	shr    %cl,%eax
f01064f9:	89 e9                	mov    %ebp,%ecx
f01064fb:	89 fa                	mov    %edi,%edx
f01064fd:	d3 e6                	shl    %cl,%esi
f01064ff:	09 d8                	or     %ebx,%eax
f0106501:	f7 74 24 08          	divl   0x8(%esp)
f0106505:	89 d1                	mov    %edx,%ecx
f0106507:	89 f3                	mov    %esi,%ebx
f0106509:	f7 64 24 0c          	mull   0xc(%esp)
f010650d:	89 c6                	mov    %eax,%esi
f010650f:	89 d7                	mov    %edx,%edi
f0106511:	39 d1                	cmp    %edx,%ecx
f0106513:	72 06                	jb     f010651b <__umoddi3+0x10b>
f0106515:	75 10                	jne    f0106527 <__umoddi3+0x117>
f0106517:	39 c3                	cmp    %eax,%ebx
f0106519:	73 0c                	jae    f0106527 <__umoddi3+0x117>
f010651b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010651f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106523:	89 d7                	mov    %edx,%edi
f0106525:	89 c6                	mov    %eax,%esi
f0106527:	89 ca                	mov    %ecx,%edx
f0106529:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010652e:	29 f3                	sub    %esi,%ebx
f0106530:	19 fa                	sbb    %edi,%edx
f0106532:	89 d0                	mov    %edx,%eax
f0106534:	d3 e0                	shl    %cl,%eax
f0106536:	89 e9                	mov    %ebp,%ecx
f0106538:	d3 eb                	shr    %cl,%ebx
f010653a:	d3 ea                	shr    %cl,%edx
f010653c:	09 d8                	or     %ebx,%eax
f010653e:	83 c4 1c             	add    $0x1c,%esp
f0106541:	5b                   	pop    %ebx
f0106542:	5e                   	pop    %esi
f0106543:	5f                   	pop    %edi
f0106544:	5d                   	pop    %ebp
f0106545:	c3                   	ret    
f0106546:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010654d:	8d 76 00             	lea    0x0(%esi),%esi
f0106550:	29 fe                	sub    %edi,%esi
f0106552:	19 c3                	sbb    %eax,%ebx
f0106554:	89 f2                	mov    %esi,%edx
f0106556:	89 d9                	mov    %ebx,%ecx
f0106558:	e9 1d ff ff ff       	jmp    f010647a <__umoddi3+0x6a>
