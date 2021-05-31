
obj/fs/fs:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b9 1b 00 00       	call   801bea <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <inb>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800033:	89 c2                	mov    %eax,%edx
  800035:	ec                   	in     (%dx),%al
	return data;
}
  800036:	c3                   	ret    

00800037 <insl>:
	return data;
}

static inline void
insl(int port, void *addr, int cnt)
{
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
	asm volatile("cld\n\trepne\n\tinsl"
  80003b:	89 d7                	mov    %edx,%edi
  80003d:	89 c2                	mov    %eax,%edx
  80003f:	fc                   	cld    
  800040:	f2 6d                	repnz insl (%dx),%es:(%edi)
		     : "=D" (addr), "=c" (cnt)
		     : "d" (port), "0" (addr), "1" (cnt)
		     : "memory", "cc");
}
  800042:	5f                   	pop    %edi
  800043:	5d                   	pop    %ebp
  800044:	c3                   	ret    

00800045 <outb>:

static inline void
outb(int port, uint8_t data)
{
  800045:	89 c1                	mov    %eax,%ecx
  800047:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800049:	89 ca                	mov    %ecx,%edx
  80004b:	ee                   	out    %al,(%dx)
}
  80004c:	c3                   	ret    

0080004d <outsl>:
		     : "cc");
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	56                   	push   %esi
	asm volatile("cld\n\trepne\n\toutsl"
  800051:	89 d6                	mov    %edx,%esi
  800053:	89 c2                	mov    %eax,%edx
  800055:	fc                   	cld    
  800056:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
		     : "=S" (addr), "=c" (cnt)
		     : "d" (port), "0" (addr), "1" (cnt)
		     : "cc");
}
  800058:	5e                   	pop    %esi
  800059:	5d                   	pop    %ebp
  80005a:	c3                   	ret    

0080005b <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  80005b:	55                   	push   %ebp
  80005c:	89 e5                	mov    %esp,%ebp
  80005e:	53                   	push   %ebx
  80005f:	83 ec 04             	sub    $0x4,%esp
  800062:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800064:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  800069:	e8 c5 ff ff ff       	call   800033 <inb>
  80006e:	89 c2                	mov    %eax,%edx
  800070:	83 e2 c0             	and    $0xffffffc0,%edx
  800073:	80 fa 40             	cmp    $0x40,%dl
  800076:	75 ec                	jne    800064 <ide_wait_ready+0x9>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800078:	ba 00 00 00 00       	mov    $0x0,%edx
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80007d:	84 db                	test   %bl,%bl
  80007f:	74 0a                	je     80008b <ide_wait_ready+0x30>
  800081:	a8 21                	test   $0x21,%al
  800083:	0f 95 c2             	setne  %dl
  800086:	0f b6 d2             	movzbl %dl,%edx
  800089:	f7 da                	neg    %edx
}
  80008b:	89 d0                	mov    %edx,%eax
  80008d:	83 c4 04             	add    $0x4,%esp
  800090:	5b                   	pop    %ebx
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800093:	f3 0f 1e fb          	endbr32 
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	53                   	push   %ebx
  80009b:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	e8 b3 ff ff ff       	call   80005b <ide_wait_ready>

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));
  8000a8:	ba f0 00 00 00       	mov    $0xf0,%edx
  8000ad:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8000b2:	e8 8e ff ff ff       	call   800045 <outb>

	// check for Device 1 to be ready for a while
	for (x = 0;
  8000b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  8000bc:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  8000c1:	e8 6d ff ff ff       	call   800033 <inb>
  8000c6:	a8 a1                	test   $0xa1,%al
  8000c8:	74 0b                	je     8000d5 <ide_probe_disk1+0x42>
	     x++)
  8000ca:	83 c3 01             	add    $0x1,%ebx
	for (x = 0;
  8000cd:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  8000d3:	75 e7                	jne    8000bc <ide_probe_disk1+0x29>
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));
  8000d5:	ba e0 00 00 00       	mov    $0xe0,%edx
  8000da:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8000df:	e8 61 ff ff ff       	call   800045 <outb>

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000e4:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000ea:	0f 9e c3             	setle  %bl
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	0f b6 c3             	movzbl %bl,%eax
  8000f3:	50                   	push   %eax
  8000f4:	68 00 3a 80 00       	push   $0x803a00
  8000f9:	e8 3f 1c 00 00       	call   801d3d <cprintf>
	return (x < 1000);
}
  8000fe:	89 d8                	mov    %ebx,%eax
  800100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <ide_set_disk>:

void
ide_set_disk(int d)
{
  800105:	f3 0f 1e fb          	endbr32 
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  800112:	83 f8 01             	cmp    $0x1,%eax
  800115:	77 07                	ja     80011e <ide_set_disk+0x19>
		panic("bad disk number");
	diskno = d;
  800117:	a3 00 50 80 00       	mov    %eax,0x805000
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    
		panic("bad disk number");
  80011e:	83 ec 04             	sub    $0x4,%esp
  800121:	68 17 3a 80 00       	push   $0x803a17
  800126:	6a 3a                	push   $0x3a
  800128:	68 27 3a 80 00       	push   $0x803a27
  80012d:	e8 24 1b 00 00       	call   801c56 <_panic>

00800132 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800145:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800148:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80014e:	0f 87 84 00 00 00    	ja     8001d8 <ide_read+0xa6>

	ide_wait_ready(0);
  800154:	b8 00 00 00 00       	mov    $0x0,%eax
  800159:	e8 fd fe ff ff       	call   80005b <ide_wait_ready>

	outb(0x1F2, nsecs);
  80015e:	89 f0                	mov    %esi,%eax
  800160:	0f b6 d0             	movzbl %al,%edx
  800163:	b8 f2 01 00 00       	mov    $0x1f2,%eax
  800168:	e8 d8 fe ff ff       	call   800045 <outb>
	outb(0x1F3, secno & 0xFF);
  80016d:	89 f8                	mov    %edi,%eax
  80016f:	0f b6 d0             	movzbl %al,%edx
  800172:	b8 f3 01 00 00       	mov    $0x1f3,%eax
  800177:	e8 c9 fe ff ff       	call   800045 <outb>
	outb(0x1F4, (secno >> 8) & 0xFF);
  80017c:	89 f8                	mov    %edi,%eax
  80017e:	0f b6 d4             	movzbl %ah,%edx
  800181:	b8 f4 01 00 00       	mov    $0x1f4,%eax
  800186:	e8 ba fe ff ff       	call   800045 <outb>
	outb(0x1F5, (secno >> 16) & 0xFF);
  80018b:	89 fa                	mov    %edi,%edx
  80018d:	c1 ea 10             	shr    $0x10,%edx
  800190:	0f b6 d2             	movzbl %dl,%edx
  800193:	b8 f5 01 00 00       	mov    $0x1f5,%eax
  800198:	e8 a8 fe ff ff       	call   800045 <outb>
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80019d:	0f b6 15 00 50 80 00 	movzbl 0x805000,%edx
  8001a4:	c1 e2 04             	shl    $0x4,%edx
  8001a7:	83 e2 10             	and    $0x10,%edx
  8001aa:	c1 ef 18             	shr    $0x18,%edi
  8001ad:	83 e7 0f             	and    $0xf,%edi
  8001b0:	09 fa                	or     %edi,%edx
  8001b2:	83 ca e0             	or     $0xffffffe0,%edx
  8001b5:	0f b6 d2             	movzbl %dl,%edx
  8001b8:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8001bd:	e8 83 fe ff ff       	call   800045 <outb>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector
  8001c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8001c7:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  8001cc:	e8 74 fe ff ff       	call   800045 <outb>
  8001d1:	c1 e6 09             	shl    $0x9,%esi
  8001d4:	01 de                	add    %ebx,%esi

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001d6:	eb 2d                	jmp    800205 <ide_read+0xd3>
	assert(nsecs <= 256);
  8001d8:	68 30 3a 80 00       	push   $0x803a30
  8001dd:	68 3d 3a 80 00       	push   $0x803a3d
  8001e2:	6a 44                	push   $0x44
  8001e4:	68 27 3a 80 00       	push   $0x803a27
  8001e9:	e8 68 1a 00 00       	call   801c56 <_panic>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
  8001ee:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001f3:	89 da                	mov    %ebx,%edx
  8001f5:	b8 f0 01 00 00       	mov    $0x1f0,%eax
  8001fa:	e8 38 fe ff ff       	call   800037 <insl>
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001ff:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800205:	39 f3                	cmp    %esi,%ebx
  800207:	74 10                	je     800219 <ide_read+0xe7>
		if ((r = ide_wait_ready(1)) < 0)
  800209:	b8 01 00 00 00       	mov    $0x1,%eax
  80020e:	e8 48 fe ff ff       	call   80005b <ide_wait_ready>
  800213:	85 c0                	test   %eax,%eax
  800215:	79 d7                	jns    8001ee <ide_read+0xbc>
  800217:	eb 05                	jmp    80021e <ide_read+0xec>
	}

	return 0;
  800219:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80021e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  800226:	f3 0f 1e fb          	endbr32 
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	8b 7d 08             	mov    0x8(%ebp),%edi
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800239:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  80023c:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800242:	0f 87 84 00 00 00    	ja     8002cc <ide_write+0xa6>

	ide_wait_ready(0);
  800248:	b8 00 00 00 00       	mov    $0x0,%eax
  80024d:	e8 09 fe ff ff       	call   80005b <ide_wait_ready>

	outb(0x1F2, nsecs);
  800252:	89 f0                	mov    %esi,%eax
  800254:	0f b6 d0             	movzbl %al,%edx
  800257:	b8 f2 01 00 00       	mov    $0x1f2,%eax
  80025c:	e8 e4 fd ff ff       	call   800045 <outb>
	outb(0x1F3, secno & 0xFF);
  800261:	89 f8                	mov    %edi,%eax
  800263:	0f b6 d0             	movzbl %al,%edx
  800266:	b8 f3 01 00 00       	mov    $0x1f3,%eax
  80026b:	e8 d5 fd ff ff       	call   800045 <outb>
	outb(0x1F4, (secno >> 8) & 0xFF);
  800270:	89 f8                	mov    %edi,%eax
  800272:	0f b6 d4             	movzbl %ah,%edx
  800275:	b8 f4 01 00 00       	mov    $0x1f4,%eax
  80027a:	e8 c6 fd ff ff       	call   800045 <outb>
	outb(0x1F5, (secno >> 16) & 0xFF);
  80027f:	89 fa                	mov    %edi,%edx
  800281:	c1 ea 10             	shr    $0x10,%edx
  800284:	0f b6 d2             	movzbl %dl,%edx
  800287:	b8 f5 01 00 00       	mov    $0x1f5,%eax
  80028c:	e8 b4 fd ff ff       	call   800045 <outb>
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800291:	0f b6 15 00 50 80 00 	movzbl 0x805000,%edx
  800298:	c1 e2 04             	shl    $0x4,%edx
  80029b:	83 e2 10             	and    $0x10,%edx
  80029e:	c1 ef 18             	shr    $0x18,%edi
  8002a1:	83 e7 0f             	and    $0xf,%edi
  8002a4:	09 fa                	or     %edi,%edx
  8002a6:	83 ca e0             	or     $0xffffffe0,%edx
  8002a9:	0f b6 d2             	movzbl %dl,%edx
  8002ac:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8002b1:	e8 8f fd ff ff       	call   800045 <outb>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector
  8002b6:	ba 30 00 00 00       	mov    $0x30,%edx
  8002bb:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  8002c0:	e8 80 fd ff ff       	call   800045 <outb>
  8002c5:	c1 e6 09             	shl    $0x9,%esi
  8002c8:	01 de                	add    %ebx,%esi

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  8002ca:	eb 2d                	jmp    8002f9 <ide_write+0xd3>
	assert(nsecs <= 256);
  8002cc:	68 30 3a 80 00       	push   $0x803a30
  8002d1:	68 3d 3a 80 00       	push   $0x803a3d
  8002d6:	6a 5d                	push   $0x5d
  8002d8:	68 27 3a 80 00       	push   $0x803a27
  8002dd:	e8 74 19 00 00       	call   801c56 <_panic>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
  8002e2:	b9 80 00 00 00       	mov    $0x80,%ecx
  8002e7:	89 da                	mov    %ebx,%edx
  8002e9:	b8 f0 01 00 00       	mov    $0x1f0,%eax
  8002ee:	e8 5a fd ff ff       	call   80004d <outsl>
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  8002f3:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8002f9:	39 f3                	cmp    %esi,%ebx
  8002fb:	74 10                	je     80030d <ide_write+0xe7>
		if ((r = ide_wait_ready(1)) < 0)
  8002fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800302:	e8 54 fd ff ff       	call   80005b <ide_wait_ready>
  800307:	85 c0                	test   %eax,%eax
  800309:	79 d7                	jns    8002e2 <ide_write+0xbc>
  80030b:	eb 05                	jmp    800312 <ide_write+0xec>
	}

	return 0;
  80030d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80031a:	f3 0f 1e fb          	endbr32 
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800326:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t) addr - DISKMAP) / BLKSIZE;
  800328:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80032e:	89 c6                	mov    %eax,%esi
  800330:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void *) DISKMAP || addr >= (void *) (DISKMAP + DISKSIZE))
  800333:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800338:	0f 87 89 00 00 00    	ja     8003c7 <bc_pgfault+0xad>
		      utf->utf_eip,
		      addr,
		      utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80033e:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	74 09                	je     800350 <bc_pgfault+0x36>
  800347:	39 70 04             	cmp    %esi,0x4(%eax)
  80034a:	0f 86 92 00 00 00    	jbe    8003e2 <bc_pgfault+0xc8>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = ROUNDDOWN(addr,PGSIZE);
  800350:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if((r = sys_page_alloc(0,addr,PTE_W))<0)
  800356:	83 ec 04             	sub    $0x4,%esp
  800359:	6a 02                	push   $0x2
  80035b:	53                   	push   %ebx
  80035c:	6a 00                	push   $0x0
  80035e:	e8 cc 23 00 00       	call   80272f <sys_page_alloc>
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	85 c0                	test   %eax,%eax
  800368:	0f 88 86 00 00 00    	js     8003f4 <bc_pgfault+0xda>
		panic("in bc_pfgault, sys_page_alloc:%e",r);
	ide_read(blockno*BLKSECTS, addr, BLKSECTS);
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	6a 08                	push   $0x8
  800373:	53                   	push   %ebx
  800374:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  80037b:	50                   	push   %eax
  80037c:	e8 b1 fd ff ff       	call   800132 <ide_read>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) <
  800381:	89 d8                	mov    %ebx,%eax
  800383:	c1 e8 0c             	shr    $0xc,%eax
  800386:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80038d:	25 07 0e 00 00       	and    $0xe07,%eax
  800392:	89 04 24             	mov    %eax,(%esp)
  800395:	53                   	push   %ebx
  800396:	6a 00                	push   $0x0
  800398:	53                   	push   %ebx
  800399:	6a 00                	push   $0x0
  80039b:	e8 b7 23 00 00       	call   802757 <sys_page_map>
  8003a0:	83 c4 20             	add    $0x20,%esp
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	78 5f                	js     800406 <bc_pgfault+0xec>
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003a7:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003ae:	74 10                	je     8003c0 <bc_pgfault+0xa6>
  8003b0:	83 ec 0c             	sub    $0xc,%esp
  8003b3:	56                   	push   %esi
  8003b4:	e8 fb 04 00 00       	call   8008b4 <block_is_free>
  8003b9:	83 c4 10             	add    $0x10,%esp
  8003bc:	84 c0                	test   %al,%al
  8003be:	75 58                	jne    800418 <bc_pgfault+0xfe>
		panic("reading free block %08x\n", blockno);
}
  8003c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8003c7:	83 ec 08             	sub    $0x8,%esp
  8003ca:	ff 72 04             	pushl  0x4(%edx)
  8003cd:	53                   	push   %ebx
  8003ce:	ff 72 28             	pushl  0x28(%edx)
  8003d1:	68 54 3a 80 00       	push   $0x803a54
  8003d6:	6a 26                	push   $0x26
  8003d8:	68 54 3b 80 00       	push   $0x803b54
  8003dd:	e8 74 18 00 00       	call   801c56 <_panic>
		panic("reading non-existent block %08x\n", blockno);
  8003e2:	56                   	push   %esi
  8003e3:	68 84 3a 80 00       	push   $0x803a84
  8003e8:	6a 2d                	push   $0x2d
  8003ea:	68 54 3b 80 00       	push   $0x803b54
  8003ef:	e8 62 18 00 00       	call   801c56 <_panic>
		panic("in bc_pfgault, sys_page_alloc:%e",r);
  8003f4:	50                   	push   %eax
  8003f5:	68 a8 3a 80 00       	push   $0x803aa8
  8003fa:	6a 37                	push   $0x37
  8003fc:	68 54 3b 80 00       	push   $0x803b54
  800401:	e8 50 18 00 00       	call   801c56 <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800406:	50                   	push   %eax
  800407:	68 cc 3a 80 00       	push   $0x803acc
  80040c:	6a 3e                	push   $0x3e
  80040e:	68 54 3b 80 00       	push   $0x803b54
  800413:	e8 3e 18 00 00       	call   801c56 <_panic>
		panic("reading free block %08x\n", blockno);
  800418:	56                   	push   %esi
  800419:	68 5c 3b 80 00       	push   $0x803b5c
  80041e:	6a 44                	push   $0x44
  800420:	68 54 3b 80 00       	push   $0x803b54
  800425:	e8 2c 18 00 00       	call   801c56 <_panic>

0080042a <diskaddr>:
{
  80042a:	f3 0f 1e fb          	endbr32 
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800437:	85 c0                	test   %eax,%eax
  800439:	74 19                	je     800454 <diskaddr+0x2a>
  80043b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	74 05                	je     80044a <diskaddr+0x20>
  800445:	39 42 04             	cmp    %eax,0x4(%edx)
  800448:	76 0a                	jbe    800454 <diskaddr+0x2a>
	return (char *) (DISKMAP + blockno * BLKSIZE);
  80044a:	05 00 00 01 00       	add    $0x10000,%eax
  80044f:	c1 e0 0c             	shl    $0xc,%eax
}
  800452:	c9                   	leave  
  800453:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  800454:	50                   	push   %eax
  800455:	68 ec 3a 80 00       	push   $0x803aec
  80045a:	6a 09                	push   $0x9
  80045c:	68 54 3b 80 00       	push   $0x803b54
  800461:	e8 f0 17 00 00       	call   801c56 <_panic>

00800466 <va_is_mapped>:
{
  800466:	f3 0f 1e fb          	endbr32 
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800470:	89 d0                	mov    %edx,%eax
  800472:	c1 e8 16             	shr    $0x16,%eax
  800475:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	f6 c1 01             	test   $0x1,%cl
  800484:	74 0d                	je     800493 <va_is_mapped+0x2d>
  800486:	c1 ea 0c             	shr    $0xc,%edx
  800489:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800490:	83 e0 01             	and    $0x1,%eax
  800493:	83 e0 01             	and    $0x1,%eax
}
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <va_is_dirty>:
{
  800498:	f3 0f 1e fb          	endbr32 
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a2:	c1 e8 0c             	shr    $0xc,%eax
  8004a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004ac:	c1 e8 06             	shr    $0x6,%eax
  8004af:	83 e0 01             	and    $0x1,%eax
}
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    

008004b4 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8004b4:	f3 0f 1e fb          	endbr32 
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	56                   	push   %esi
  8004bc:	53                   	push   %ebx
  8004bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t) addr - DISKMAP) / BLKSIZE;
  8004c0:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi

	if (addr < (void *) DISKMAP || addr >= (void *) (DISKMAP + DISKSIZE))
  8004c6:	81 fe ff ff ff bf    	cmp    $0xbfffffff,%esi
  8004cc:	77 1d                	ja     8004eb <flush_block+0x37>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	addr = ROUNDDOWN(addr,PGSIZE);
  8004ce:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(va_is_dirty(addr)){
  8004d4:	83 ec 0c             	sub    $0xc,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	e8 bb ff ff ff       	call   800498 <va_is_dirty>
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	84 c0                	test   %al,%al
  8004e2:	75 19                	jne    8004fd <flush_block+0x49>
		int r;
		//poner el bit dirty a 0 igual que en la funcion anterior
		if((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL))<0)
			panic("in flush_block, sys_page_map:%e",r);
	}
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  8004eb:	53                   	push   %ebx
  8004ec:	68 75 3b 80 00       	push   $0x803b75
  8004f1:	6a 54                	push   $0x54
  8004f3:	68 54 3b 80 00       	push   $0x803b54
  8004f8:	e8 59 17 00 00       	call   801c56 <_panic>
		ide_write(blockno*BLKSECTS, addr, BLKSECTS);
  8004fd:	83 ec 04             	sub    $0x4,%esp
  800500:	6a 08                	push   $0x8
  800502:	53                   	push   %ebx
	uint32_t blockno = ((uint32_t) addr - DISKMAP) / BLKSIZE;
  800503:	c1 ee 0c             	shr    $0xc,%esi
		ide_write(blockno*BLKSECTS, addr, BLKSECTS);
  800506:	c1 e6 03             	shl    $0x3,%esi
  800509:	56                   	push   %esi
  80050a:	e8 17 fd ff ff       	call   800226 <ide_write>
		if((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL))<0)
  80050f:	89 d8                	mov    %ebx,%eax
  800511:	c1 e8 0c             	shr    $0xc,%eax
  800514:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80051b:	25 07 0e 00 00       	and    $0xe07,%eax
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	53                   	push   %ebx
  800524:	6a 00                	push   $0x0
  800526:	53                   	push   %ebx
  800527:	6a 00                	push   $0x0
  800529:	e8 29 22 00 00       	call   802757 <sys_page_map>
  80052e:	83 c4 20             	add    $0x20,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	79 af                	jns    8004e4 <flush_block+0x30>
			panic("in flush_block, sys_page_map:%e",r);
  800535:	50                   	push   %eax
  800536:	68 10 3b 80 00       	push   $0x803b10
  80053b:	6a 5d                	push   $0x5d
  80053d:	68 54 3b 80 00       	push   $0x803b54
  800542:	e8 0f 17 00 00       	call   801c56 <_panic>

00800547 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	53                   	push   %ebx
  80054b:	81 ec 20 01 00 00    	sub    $0x120,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800551:	6a 01                	push   $0x1
  800553:	e8 d2 fe ff ff       	call   80042a <diskaddr>
  800558:	83 c4 0c             	add    $0xc,%esp
  80055b:	68 08 01 00 00       	push   $0x108
  800560:	50                   	push   %eax
  800561:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800567:	50                   	push   %eax
  800568:	e8 f2 1e 00 00       	call   80245f <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80056d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800574:	e8 b1 fe ff ff       	call   80042a <diskaddr>
  800579:	83 c4 08             	add    $0x8,%esp
  80057c:	68 90 3b 80 00       	push   $0x803b90
  800581:	50                   	push   %eax
  800582:	e8 20 1d 00 00       	call   8022a7 <strcpy>
	flush_block(diskaddr(1));
  800587:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80058e:	e8 97 fe ff ff       	call   80042a <diskaddr>
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 19 ff ff ff       	call   8004b4 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80059b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a2:	e8 83 fe ff ff       	call   80042a <diskaddr>
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	e8 b7 fe ff ff       	call   800466 <va_is_mapped>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	84 c0                	test   %al,%al
  8005b4:	0f 84 b0 01 00 00    	je     80076a <check_bc+0x223>
	assert(!va_is_dirty(diskaddr(1)));
  8005ba:	83 ec 0c             	sub    $0xc,%esp
  8005bd:	6a 01                	push   $0x1
  8005bf:	e8 66 fe ff ff       	call   80042a <diskaddr>
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	e8 cc fe ff ff       	call   800498 <va_is_dirty>
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	84 c0                	test   %al,%al
  8005d1:	0f 85 a9 01 00 00    	jne    800780 <check_bc+0x239>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	6a 01                	push   $0x1
  8005dc:	e8 49 fe ff ff       	call   80042a <diskaddr>
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	50                   	push   %eax
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 95 21 00 00       	call   802781 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005f3:	e8 32 fe ff ff       	call   80042a <diskaddr>
  8005f8:	89 04 24             	mov    %eax,(%esp)
  8005fb:	e8 66 fe ff ff       	call   800466 <va_is_mapped>
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	84 c0                	test   %al,%al
  800605:	0f 85 8b 01 00 00    	jne    800796 <check_bc+0x24f>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	6a 01                	push   $0x1
  800610:	e8 15 fe ff ff       	call   80042a <diskaddr>
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	68 90 3b 80 00       	push   $0x803b90
  80061d:	50                   	push   %eax
  80061e:	e8 43 1d 00 00       	call   802366 <strcmp>
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	0f 85 7e 01 00 00    	jne    8007ac <check_bc+0x265>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	6a 01                	push   $0x1
  800633:	e8 f2 fd ff ff       	call   80042a <diskaddr>
  800638:	83 c4 0c             	add    $0xc,%esp
  80063b:	68 08 01 00 00       	push   $0x108
  800640:	8d 9d f0 fe ff ff    	lea    -0x110(%ebp),%ebx
  800646:	53                   	push   %ebx
  800647:	50                   	push   %eax
  800648:	e8 12 1e 00 00       	call   80245f <memmove>
	flush_block(diskaddr(1));
  80064d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800654:	e8 d1 fd ff ff       	call   80042a <diskaddr>
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	e8 53 fe ff ff       	call   8004b4 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800661:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800668:	e8 bd fd ff ff       	call   80042a <diskaddr>
  80066d:	83 c4 0c             	add    $0xc,%esp
  800670:	68 08 01 00 00       	push   $0x108
  800675:	50                   	push   %eax
  800676:	53                   	push   %ebx
  800677:	e8 e3 1d 00 00       	call   80245f <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80067c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800683:	e8 a2 fd ff ff       	call   80042a <diskaddr>
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	68 90 3b 80 00       	push   $0x803b90
  800690:	50                   	push   %eax
  800691:	e8 11 1c 00 00       	call   8022a7 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800696:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80069d:	e8 88 fd ff ff       	call   80042a <diskaddr>
  8006a2:	83 c0 14             	add    $0x14,%eax
  8006a5:	89 04 24             	mov    %eax,(%esp)
  8006a8:	e8 07 fe ff ff       	call   8004b4 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8006ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006b4:	e8 71 fd ff ff       	call   80042a <diskaddr>
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 a5 fd ff ff       	call   800466 <va_is_mapped>
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	84 c0                	test   %al,%al
  8006c6:	0f 84 f6 00 00 00    	je     8007c2 <check_bc+0x27b>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	// assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006cc:	83 ec 0c             	sub    $0xc,%esp
  8006cf:	6a 01                	push   $0x1
  8006d1:	e8 54 fd ff ff       	call   80042a <diskaddr>
  8006d6:	83 c4 08             	add    $0x8,%esp
  8006d9:	50                   	push   %eax
  8006da:	6a 00                	push   $0x0
  8006dc:	e8 a0 20 00 00       	call   802781 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e8:	e8 3d fd ff ff       	call   80042a <diskaddr>
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	e8 71 fd ff ff       	call   800466 <va_is_mapped>
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	84 c0                	test   %al,%al
  8006fa:	0f 85 db 00 00 00    	jne    8007db <check_bc+0x294>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800700:	83 ec 0c             	sub    $0xc,%esp
  800703:	6a 01                	push   $0x1
  800705:	e8 20 fd ff ff       	call   80042a <diskaddr>
  80070a:	83 c4 08             	add    $0x8,%esp
  80070d:	68 90 3b 80 00       	push   $0x803b90
  800712:	50                   	push   %eax
  800713:	e8 4e 1c 00 00       	call   802366 <strcmp>
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	85 c0                	test   %eax,%eax
  80071d:	0f 85 d1 00 00 00    	jne    8007f4 <check_bc+0x2ad>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800723:	83 ec 0c             	sub    $0xc,%esp
  800726:	6a 01                	push   $0x1
  800728:	e8 fd fc ff ff       	call   80042a <diskaddr>
  80072d:	83 c4 0c             	add    $0xc,%esp
  800730:	68 08 01 00 00       	push   $0x108
  800735:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	e8 1d 1d 00 00       	call   80245f <memmove>
	flush_block(diskaddr(1));
  800742:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800749:	e8 dc fc ff ff       	call   80042a <diskaddr>
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	e8 5e fd ff ff       	call   8004b4 <flush_block>

	cprintf("block cache is good\n");
  800756:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  80075d:	e8 db 15 00 00       	call   801d3d <cprintf>
}
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  80076a:	68 b2 3b 80 00       	push   $0x803bb2
  80076f:	68 3d 3a 80 00       	push   $0x803a3d
  800774:	6a 6e                	push   $0x6e
  800776:	68 54 3b 80 00       	push   $0x803b54
  80077b:	e8 d6 14 00 00       	call   801c56 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800780:	68 97 3b 80 00       	push   $0x803b97
  800785:	68 3d 3a 80 00       	push   $0x803a3d
  80078a:	6a 6f                	push   $0x6f
  80078c:	68 54 3b 80 00       	push   $0x803b54
  800791:	e8 c0 14 00 00       	call   801c56 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800796:	68 b1 3b 80 00       	push   $0x803bb1
  80079b:	68 3d 3a 80 00       	push   $0x803a3d
  8007a0:	6a 73                	push   $0x73
  8007a2:	68 54 3b 80 00       	push   $0x803b54
  8007a7:	e8 aa 14 00 00       	call   801c56 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007ac:	68 30 3b 80 00       	push   $0x803b30
  8007b1:	68 3d 3a 80 00       	push   $0x803a3d
  8007b6:	6a 76                	push   $0x76
  8007b8:	68 54 3b 80 00       	push   $0x803b54
  8007bd:	e8 94 14 00 00       	call   801c56 <_panic>
	assert(va_is_mapped(diskaddr(1)));
  8007c2:	68 b2 3b 80 00       	push   $0x803bb2
  8007c7:	68 3d 3a 80 00       	push   $0x803a3d
  8007cc:	68 87 00 00 00       	push   $0x87
  8007d1:	68 54 3b 80 00       	push   $0x803b54
  8007d6:	e8 7b 14 00 00       	call   801c56 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  8007db:	68 b1 3b 80 00       	push   $0x803bb1
  8007e0:	68 3d 3a 80 00       	push   $0x803a3d
  8007e5:	68 8f 00 00 00       	push   $0x8f
  8007ea:	68 54 3b 80 00       	push   $0x803b54
  8007ef:	e8 62 14 00 00       	call   801c56 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007f4:	68 30 3b 80 00       	push   $0x803b30
  8007f9:	68 3d 3a 80 00       	push   $0x803a3d
  8007fe:	68 92 00 00 00       	push   $0x92
  800803:	68 54 3b 80 00       	push   $0x803b54
  800808:	e8 49 14 00 00       	call   801c56 <_panic>

0080080d <bc_init>:

void
bc_init(void)
{
  80080d:	f3 0f 1e fb          	endbr32 
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  80081a:	68 1a 03 80 00       	push   $0x80031a
  80081f:	e8 48 20 00 00       	call   80286c <set_pgfault_handler>
	check_bc();
  800824:	e8 1e fd ff ff       	call   800547 <check_bc>

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800829:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800830:	e8 f5 fb ff ff       	call   80042a <diskaddr>
  800835:	83 c4 0c             	add    $0xc,%esp
  800838:	68 08 01 00 00       	push   $0x108
  80083d:	50                   	push   %eax
  80083e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800844:	50                   	push   %eax
  800845:	e8 15 1c 00 00       	call   80245f <memmove>
}
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <skip_slash>:

// Skip over slashes.
static const char *
skip_slash(const char *p)
{
	while (*p == '/')
  80084f:	80 38 2f             	cmpb   $0x2f,(%eax)
  800852:	75 05                	jne    800859 <skip_slash+0xa>
		p++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	eb f6                	jmp    80084f <skip_slash>
	return p;
}
  800859:	c3                   	ret    

0080085a <check_super>:
{
  80085a:	f3 0f 1e fb          	endbr32 
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800864:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800869:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80086f:	75 1b                	jne    80088c <check_super+0x32>
	if (super->s_nblocks > DISKSIZE / BLKSIZE)
  800871:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800878:	77 26                	ja     8008a0 <check_super+0x46>
	cprintf("superblock is good\n");
  80087a:	83 ec 0c             	sub    $0xc,%esp
  80087d:	68 1f 3c 80 00       	push   $0x803c1f
  800882:	e8 b6 14 00 00       	call   801d3d <cprintf>
}
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    
		panic("bad file system magic number");
  80088c:	83 ec 04             	sub    $0x4,%esp
  80088f:	68 e1 3b 80 00       	push   $0x803be1
  800894:	6a 12                	push   $0x12
  800896:	68 fe 3b 80 00       	push   $0x803bfe
  80089b:	e8 b6 13 00 00       	call   801c56 <_panic>
		panic("file system is too large");
  8008a0:	83 ec 04             	sub    $0x4,%esp
  8008a3:	68 06 3c 80 00       	push   $0x803c06
  8008a8:	6a 15                	push   $0x15
  8008aa:	68 fe 3b 80 00       	push   $0x803bfe
  8008af:	e8 a2 13 00 00       	call   801c56 <_panic>

008008b4 <block_is_free>:
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8008bf:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	74 27                	je     8008ef <block_is_free+0x3b>
		return 0;
  8008c8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (super == 0 || blockno >= super->s_nblocks)
  8008cd:	39 48 04             	cmp    %ecx,0x4(%eax)
  8008d0:	76 18                	jbe    8008ea <block_is_free+0x36>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8008d2:	89 cb                	mov    %ecx,%ebx
  8008d4:	c1 eb 05             	shr    $0x5,%ebx
  8008d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8008dc:	d3 e0                	shl    %cl,%eax
  8008de:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8008e4:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8008e7:	0f 95 c2             	setne  %dl
}
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	5b                   	pop    %ebx
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    
		return 0;
  8008ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f4:	eb f4                	jmp    8008ea <block_is_free+0x36>

008008f6 <free_block>:
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	83 ec 04             	sub    $0x4,%esp
  800901:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (blockno == 0)
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 1a                	je     800922 <free_block+0x2c>
	bitmap[blockno / 32] |= 1 << (blockno % 32);
  800908:	89 cb                	mov    %ecx,%ebx
  80090a:	c1 eb 05             	shr    $0x5,%ebx
  80090d:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800913:	b8 01 00 00 00       	mov    $0x1,%eax
  800918:	d3 e0                	shl    %cl,%eax
  80091a:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80091d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800920:	c9                   	leave  
  800921:	c3                   	ret    
		panic("attempt to free zero block");
  800922:	83 ec 04             	sub    $0x4,%esp
  800925:	68 33 3c 80 00       	push   $0x803c33
  80092a:	6a 30                	push   $0x30
  80092c:	68 fe 3b 80 00       	push   $0x803bfe
  800931:	e8 20 13 00 00       	call   801c56 <_panic>

00800936 <alloc_block>:
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
	for(uint32_t blockno = 0; blockno < super->s_nblocks; blockno++){
  80093f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800944:	8b 70 04             	mov    0x4(%eax),%esi
  800947:	bb 00 00 00 00       	mov    $0x0,%ebx
  80094c:	39 de                	cmp    %ebx,%esi
  80094e:	74 43                	je     800993 <alloc_block+0x5d>
		if(block_is_free(blockno)){
  800950:	83 ec 0c             	sub    $0xc,%esp
  800953:	53                   	push   %ebx
  800954:	e8 5b ff ff ff       	call   8008b4 <block_is_free>
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	84 c0                	test   %al,%al
  80095e:	75 05                	jne    800965 <alloc_block+0x2f>
	for(uint32_t blockno = 0; blockno < super->s_nblocks; blockno++){
  800960:	83 c3 01             	add    $0x1,%ebx
  800963:	eb e7                	jmp    80094c <alloc_block+0x16>
			bitmap[blockno / 32] &= ~(1 << (blockno % 32));
  800965:	89 de                	mov    %ebx,%esi
  800967:	c1 ee 05             	shr    $0x5,%esi
  80096a:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800970:	b8 01 00 00 00       	mov    $0x1,%eax
  800975:	89 d9                	mov    %ebx,%ecx
  800977:	d3 e0                	shl    %cl,%eax
  800979:	f7 d0                	not    %eax
  80097b:	21 04 b2             	and    %eax,(%edx,%esi,4)
			flush_block(bitmap);
  80097e:	83 ec 0c             	sub    $0xc,%esp
  800981:	ff 35 04 a0 80 00    	pushl  0x80a004
  800987:	e8 28 fb ff ff       	call   8004b4 <flush_block>
			return blockno;
  80098c:	89 d8                	mov    %ebx,%eax
  80098e:	83 c4 10             	add    $0x10,%esp
  800991:	eb 05                	jmp    800998 <alloc_block+0x62>
	return -E_NO_DISK;
  800993:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800998:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <file_block_walk>:
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 1c             	sub    $0x1c,%esp
  8009a8:	89 c6                	mov    %eax,%esi
  8009aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
	if(filebno >= NDIRECT + NINDIRECT) return -E_INVAL;
  8009b0:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8009b6:	0f 87 9c 00 00 00    	ja     800a58 <file_block_walk+0xb9>
  8009bc:	89 d3                	mov    %edx,%ebx
	if(filebno >= NDIRECT){
  8009be:	83 fa 09             	cmp    $0x9,%edx
  8009c1:	76 7c                	jbe    800a3f <file_block_walk+0xa0>
		if(f->f_indirect == 0){
  8009c3:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  8009ca:	75 52                	jne    800a1e <file_block_walk+0x7f>
			if(!alloc) return -E_NOT_FOUND;
  8009cc:	84 c0                	test   %al,%al
  8009ce:	0f 84 8b 00 00 00    	je     800a5f <file_block_walk+0xc0>
			uint32_t blockno = alloc_block();
  8009d4:	e8 5d ff ff ff       	call   800936 <alloc_block>
  8009d9:	89 c7                	mov    %eax,%edi
			if(blockno == -E_NO_DISK) return -E_NO_DISK;
  8009db:	83 f8 f7             	cmp    $0xfffffff7,%eax
  8009de:	0f 84 82 00 00 00    	je     800a66 <file_block_walk+0xc7>
			f->f_indirect = blockno;
  8009e4:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			void *block = diskaddr(blockno);
  8009ea:	83 ec 0c             	sub    $0xc,%esp
  8009ed:	50                   	push   %eax
  8009ee:	e8 37 fa ff ff       	call   80042a <diskaddr>
			memset(diskaddr(blockno),0, BLKSIZE);
  8009f3:	89 3c 24             	mov    %edi,(%esp)
  8009f6:	e8 2f fa ff ff       	call   80042a <diskaddr>
  8009fb:	83 c4 0c             	add    $0xc,%esp
  8009fe:	68 00 10 00 00       	push   $0x1000
  800a03:	6a 00                	push   $0x0
  800a05:	50                   	push   %eax
  800a06:	e8 06 1a 00 00       	call   802411 <memset>
			flush_block(diskaddr(blockno));
  800a0b:	89 3c 24             	mov    %edi,(%esp)
  800a0e:	e8 17 fa ff ff       	call   80042a <diskaddr>
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 99 fa ff ff       	call   8004b4 <flush_block>
  800a1b:	83 c4 10             	add    $0x10,%esp
		uint32_t *addr = diskaddr(f->f_indirect);
  800a1e:	83 ec 0c             	sub    $0xc,%esp
  800a21:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800a27:	e8 fe f9 ff ff       	call   80042a <diskaddr>
		addr += (filebno - NDIRECT);
  800a2c:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800a30:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800a33:	89 06                	mov    %eax,(%esi)
  800a35:	83 c4 10             	add    $0x10,%esp
	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3d:	eb 11                	jmp    800a50 <file_block_walk+0xb1>
		*ppdiskbno = &f->f_direct[filebno];
  800a3f:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  800a46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a49:	89 07                	mov    %eax,(%edi)
	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    
	if(filebno >= NDIRECT + NINDIRECT) return -E_INVAL;
  800a58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a5d:	eb f1                	jmp    800a50 <file_block_walk+0xb1>
			if(!alloc) return -E_NOT_FOUND;
  800a5f:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a64:	eb ea                	jmp    800a50 <file_block_walk+0xb1>
			if(blockno == -E_NO_DISK) return -E_NO_DISK;
  800a66:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800a6b:	eb e3                	jmp    800a50 <file_block_walk+0xb1>

00800a6d <file_free_block>:

// Remove a block from file f.  If it's not there, just silently succeed.
// Returns 0 on success, < 0 on error.
static int
file_free_block(struct File *f, uint32_t filebno)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	83 ec 24             	sub    $0x24,%esp
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800a73:	6a 00                	push   $0x0
  800a75:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a78:	e8 22 ff ff ff       	call   80099f <file_block_walk>
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	85 c0                	test   %eax,%eax
  800a82:	78 0e                	js     800a92 <file_free_block+0x25>
		return r;
	if (*ptr) {
  800a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a87:	8b 10                	mov    (%eax),%edx
		free_block(*ptr);
		*ptr = 0;
	}
	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
	if (*ptr) {
  800a8e:	85 d2                	test   %edx,%edx
  800a90:	75 02                	jne    800a94 <file_free_block+0x27>
}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    
		free_block(*ptr);
  800a94:	83 ec 0c             	sub    $0xc,%esp
  800a97:	52                   	push   %edx
  800a98:	e8 59 fe ff ff       	call   8008f6 <free_block>
		*ptr = 0;
  800a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800aa6:	83 c4 10             	add    $0x10,%esp
	return 0;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	eb e2                	jmp    800a92 <file_free_block+0x25>

00800ab0 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 1c             	sub    $0x1c,%esp
  800ab9:	89 c7                	mov    %eax,%edi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800abb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800ac1:	8d b0 fe 1f 00 00    	lea    0x1ffe(%eax),%esi
  800ac7:	05 ff 0f 00 00       	add    $0xfff,%eax
  800acc:	0f 49 f0             	cmovns %eax,%esi
  800acf:	c1 fe 0c             	sar    $0xc,%esi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ad2:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800ad8:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800ade:	0f 48 d0             	cmovs  %eax,%edx
  800ae1:	c1 fa 0c             	sar    $0xc,%edx
  800ae4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ae7:	89 d3                	mov    %edx,%ebx
  800ae9:	eb 03                	jmp    800aee <file_truncate_blocks+0x3e>
  800aeb:	83 c3 01             	add    $0x1,%ebx
  800aee:	39 f3                	cmp    %esi,%ebx
  800af0:	73 20                	jae    800b12 <file_truncate_blocks+0x62>
		if ((r = file_free_block(f, bno)) < 0)
  800af2:	89 da                	mov    %ebx,%edx
  800af4:	89 f8                	mov    %edi,%eax
  800af6:	e8 72 ff ff ff       	call   800a6d <file_free_block>
  800afb:	85 c0                	test   %eax,%eax
  800afd:	79 ec                	jns    800aeb <file_truncate_blocks+0x3b>
			cprintf("warning: file_free_block: %e", r);
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	50                   	push   %eax
  800b03:	68 4e 3c 80 00       	push   $0x803c4e
  800b08:	e8 30 12 00 00       	call   801d3d <cprintf>
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	eb d9                	jmp    800aeb <file_truncate_blocks+0x3b>

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800b12:	83 7d e4 0a          	cmpl   $0xa,-0x1c(%ebp)
  800b16:	77 0a                	ja     800b22 <file_truncate_blocks+0x72>
  800b18:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	75 08                	jne    800b2a <file_truncate_blocks+0x7a>
		free_block(f->f_indirect);
		f->f_indirect = 0;
	}
}
  800b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    
		free_block(f->f_indirect);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	50                   	push   %eax
  800b2e:	e8 c3 fd ff ff       	call   8008f6 <free_block>
		f->f_indirect = 0;
  800b33:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
  800b3a:	00 00 00 
  800b3d:	83 c4 10             	add    $0x10,%esp
}
  800b40:	eb e0                	jmp    800b22 <file_truncate_blocks+0x72>

00800b42 <check_bitmap>:
{
  800b42:	f3 0f 1e fb          	endbr32 
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800b4b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800b50:	8b 70 04             	mov    0x4(%eax),%esi
  800b53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b58:	89 d8                	mov    %ebx,%eax
  800b5a:	c1 e0 0f             	shl    $0xf,%eax
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	76 2e                	jbe    800b8f <check_bitmap+0x4d>
		assert(!block_is_free(2 + i));
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	8d 43 02             	lea    0x2(%ebx),%eax
  800b67:	50                   	push   %eax
  800b68:	e8 47 fd ff ff       	call   8008b4 <block_is_free>
  800b6d:	83 c4 10             	add    $0x10,%esp
  800b70:	84 c0                	test   %al,%al
  800b72:	75 05                	jne    800b79 <check_bitmap+0x37>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800b74:	83 c3 01             	add    $0x1,%ebx
  800b77:	eb df                	jmp    800b58 <check_bitmap+0x16>
		assert(!block_is_free(2 + i));
  800b79:	68 6b 3c 80 00       	push   $0x803c6b
  800b7e:	68 3d 3a 80 00       	push   $0x803a3d
  800b83:	6a 5a                	push   $0x5a
  800b85:	68 fe 3b 80 00       	push   $0x803bfe
  800b8a:	e8 c7 10 00 00       	call   801c56 <_panic>
	assert(!block_is_free(0));
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	6a 00                	push   $0x0
  800b94:	e8 1b fd ff ff       	call   8008b4 <block_is_free>
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	84 c0                	test   %al,%al
  800b9e:	75 28                	jne    800bc8 <check_bitmap+0x86>
	assert(!block_is_free(1));
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	6a 01                	push   $0x1
  800ba5:	e8 0a fd ff ff       	call   8008b4 <block_is_free>
  800baa:	83 c4 10             	add    $0x10,%esp
  800bad:	84 c0                	test   %al,%al
  800baf:	75 2d                	jne    800bde <check_bitmap+0x9c>
	cprintf("bitmap is good\n");
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	68 a5 3c 80 00       	push   $0x803ca5
  800bb9:	e8 7f 11 00 00       	call   801d3d <cprintf>
}
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    
	assert(!block_is_free(0));
  800bc8:	68 81 3c 80 00       	push   $0x803c81
  800bcd:	68 3d 3a 80 00       	push   $0x803a3d
  800bd2:	6a 5d                	push   $0x5d
  800bd4:	68 fe 3b 80 00       	push   $0x803bfe
  800bd9:	e8 78 10 00 00       	call   801c56 <_panic>
	assert(!block_is_free(1));
  800bde:	68 93 3c 80 00       	push   $0x803c93
  800be3:	68 3d 3a 80 00       	push   $0x803a3d
  800be8:	6a 5e                	push   $0x5e
  800bea:	68 fe 3b 80 00       	push   $0x803bfe
  800bef:	e8 62 10 00 00       	call   801c56 <_panic>

00800bf4 <fs_init>:
{
  800bf4:	f3 0f 1e fb          	endbr32 
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800bfe:	e8 90 f4 ff ff       	call   800093 <ide_probe_disk1>
  800c03:	84 c0                	test   %al,%al
  800c05:	74 41                	je     800c48 <fs_init+0x54>
		ide_set_disk(1);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	6a 01                	push   $0x1
  800c0c:	e8 f4 f4 ff ff       	call   800105 <ide_set_disk>
  800c11:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800c14:	e8 f4 fb ff ff       	call   80080d <bc_init>
	super = diskaddr(1);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	6a 01                	push   $0x1
  800c1e:	e8 07 f8 ff ff       	call   80042a <diskaddr>
  800c23:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800c28:	e8 2d fc ff ff       	call   80085a <check_super>
	bitmap = diskaddr(2);
  800c2d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800c34:	e8 f1 f7 ff ff       	call   80042a <diskaddr>
  800c39:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800c3e:	e8 ff fe ff ff       	call   800b42 <check_bitmap>
}
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    
		ide_set_disk(0);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	6a 00                	push   $0x0
  800c4d:	e8 b3 f4 ff ff       	call   800105 <ide_set_disk>
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	eb bd                	jmp    800c14 <fs_init+0x20>

00800c57 <file_get_block>:
{
  800c57:	f3 0f 1e fb          	endbr32 
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	83 ec 18             	sub    $0x18,%esp
  800c61:	8b 55 0c             	mov    0xc(%ebp),%edx
	if(filebno >= NDIRECT + NINDIRECT) return -E_INVAL;
  800c64:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800c6a:	77 4a                	ja     800cb6 <file_get_block+0x5f>
	int r = file_block_walk(f,filebno,&ppdiskbno,true);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	6a 01                	push   $0x1
  800c71:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	e8 23 fd ff ff       	call   80099f <file_block_walk>
	if(r<0) return r;
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	78 31                	js     800cb4 <file_get_block+0x5d>
	if(*ppdiskbno == 0){
  800c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c86:	83 38 00             	cmpl   $0x0,(%eax)
  800c89:	75 0f                	jne    800c9a <file_get_block+0x43>
		uint32_t blockno = alloc_block();
  800c8b:	e8 a6 fc ff ff       	call   800936 <alloc_block>
		if(blockno == -E_NO_DISK) return -E_NO_DISK;
  800c90:	83 f8 f7             	cmp    $0xfffffff7,%eax
  800c93:	74 28                	je     800cbd <file_get_block+0x66>
		*ppdiskbno = blockno;
  800c95:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c98:	89 02                	mov    %eax,(%edx)
	*blk = diskaddr(*ppdiskbno);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca0:	ff 30                	pushl  (%eax)
  800ca2:	e8 83 f7 ff ff       	call   80042a <diskaddr>
  800ca7:	8b 55 10             	mov    0x10(%ebp),%edx
  800caa:	89 02                	mov    %eax,(%edx)
	return 0;
  800cac:	83 c4 10             	add    $0x10,%esp
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    
	if(filebno >= NDIRECT + NINDIRECT) return -E_INVAL;
  800cb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cbb:	eb f7                	jmp    800cb4 <file_get_block+0x5d>
		if(blockno == -E_NO_DISK) return -E_NO_DISK;
  800cbd:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800cc2:	eb f0                	jmp    800cb4 <file_get_block+0x5d>

00800cc4 <dir_lookup>:
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 3c             	sub    $0x3c,%esp
  800ccd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
	assert((dir->f_size % BLKSIZE) == 0);
  800cd5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800cdb:	89 c2                	mov    %eax,%edx
  800cdd:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  800ce3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800ce6:	75 5f                	jne    800d47 <dir_lookup+0x83>
	nblock = dir->f_size / BLKSIZE;
  800ce8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	0f 48 c2             	cmovs  %edx,%eax
  800cf3:	c1 f8 0c             	sar    $0xc,%eax
  800cf6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < nblock; i++) {
  800cf9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800cfc:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
  800cff:	74 6f                	je     800d70 <dir_lookup+0xac>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d07:	50                   	push   %eax
  800d08:	ff 75 d0             	pushl  -0x30(%ebp)
  800d0b:	ff 75 c8             	pushl  -0x38(%ebp)
  800d0e:	e8 44 ff ff ff       	call   800c57 <file_get_block>
  800d13:	83 c4 10             	add    $0x10,%esp
  800d16:	85 c0                	test   %eax,%eax
  800d18:	78 4e                	js     800d68 <dir_lookup+0xa4>
  800d1a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d1d:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			if (strcmp(f[j].f_name, name) == 0) {
  800d23:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800d26:	83 ec 08             	sub    $0x8,%esp
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	e8 36 16 00 00       	call   802366 <strcmp>
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	85 c0                	test   %eax,%eax
  800d35:	74 29                	je     800d60 <dir_lookup+0x9c>
  800d37:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800d3d:	39 fb                	cmp    %edi,%ebx
  800d3f:	75 e2                	jne    800d23 <dir_lookup+0x5f>
	for (i = 0; i < nblock; i++) {
  800d41:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
  800d45:	eb b2                	jmp    800cf9 <dir_lookup+0x35>
	assert((dir->f_size % BLKSIZE) == 0);
  800d47:	68 b5 3c 80 00       	push   $0x803cb5
  800d4c:	68 3d 3a 80 00       	push   $0x803a3d
  800d51:	68 d1 00 00 00       	push   $0xd1
  800d56:	68 fe 3b 80 00       	push   $0x803bfe
  800d5b:	e8 f6 0e 00 00       	call   801c56 <_panic>
				*file = &f[j];
  800d60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800d63:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d66:	89 11                	mov    %edx,(%ecx)
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    
	return -E_NOT_FOUND;
  800d70:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d75:	eb f1                	jmp    800d68 <dir_lookup+0xa4>

00800d77 <walk_path>:
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	81 ec ac 00 00 00    	sub    $0xac,%esp
  800d83:	89 d7                	mov    %edx,%edi
  800d85:	89 95 4c ff ff ff    	mov    %edx,-0xb4(%ebp)
  800d8b:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
	path = skip_slash(path);
  800d91:	e8 b9 fa ff ff       	call   80084f <skip_slash>
  800d96:	89 c6                	mov    %eax,%esi
	f = &super->s_root;
  800d98:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800d9d:	83 c0 08             	add    $0x8,%eax
  800da0:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
	name[0] = 0;
  800da6:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)
	if (pdir)
  800dad:	85 ff                	test   %edi,%edi
  800daf:	74 06                	je     800db7 <walk_path+0x40>
		*pdir = 0;
  800db1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*pf = 0;
  800db7:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800dbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	dir = 0;
  800dc3:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800dca:	00 00 00 
	while (*path != '\0') {
  800dcd:	eb 68                	jmp    800e37 <walk_path+0xc0>
			path++;
  800dcf:	83 c3 01             	add    $0x1,%ebx
		while (*path != '/' && *path != '\0')
  800dd2:	0f b6 03             	movzbl (%ebx),%eax
  800dd5:	3c 2f                	cmp    $0x2f,%al
  800dd7:	74 04                	je     800ddd <walk_path+0x66>
  800dd9:	84 c0                	test   %al,%al
  800ddb:	75 f2                	jne    800dcf <walk_path+0x58>
		if (path - p >= MAXNAMELEN)
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	29 f7                	sub    %esi,%edi
  800de1:	83 ff 7f             	cmp    $0x7f,%edi
  800de4:	0f 8f d8 00 00 00    	jg     800ec2 <walk_path+0x14b>
		memmove(name, p, path - p);
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800df5:	50                   	push   %eax
  800df6:	e8 64 16 00 00       	call   80245f <memmove>
		name[path - p] = '\0';
  800dfb:	c6 84 3d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%edi,1)
  800e02:	00 
		path = skip_slash(path);
  800e03:	89 d8                	mov    %ebx,%eax
  800e05:	e8 45 fa ff ff       	call   80084f <skip_slash>
  800e0a:	89 c6                	mov    %eax,%esi
		if (dir->f_type != FTYPE_DIR)
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800e15:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800e1c:	0f 85 a7 00 00 00    	jne    800ec9 <walk_path+0x152>
		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800e22:	8d 8d 64 ff ff ff    	lea    -0x9c(%ebp),%ecx
  800e28:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800e2e:	e8 91 fe ff ff       	call   800cc4 <dir_lookup>
  800e33:	85 c0                	test   %eax,%eax
  800e35:	78 15                	js     800e4c <walk_path+0xd5>
	while (*path != '\0') {
  800e37:	80 3e 00             	cmpb   $0x0,(%esi)
  800e3a:	74 57                	je     800e93 <walk_path+0x11c>
		dir = f;
  800e3c:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800e42:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
		while (*path != '/' && *path != '\0')
  800e48:	89 f3                	mov    %esi,%ebx
  800e4a:	eb 86                	jmp    800dd2 <walk_path+0x5b>
  800e4c:	89 c3                	mov    %eax,%ebx
			if (r == -E_NOT_FOUND && *path == '\0') {
  800e4e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800e51:	75 65                	jne    800eb8 <walk_path+0x141>
  800e53:	80 3e 00             	cmpb   $0x0,(%esi)
  800e56:	75 60                	jne    800eb8 <walk_path+0x141>
				if (pdir)
  800e58:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	74 08                	je     800e6a <walk_path+0xf3>
					*pdir = dir;
  800e62:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800e68:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800e6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e6e:	74 15                	je     800e85 <walk_path+0x10e>
					strcpy(lastelem, name);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e79:	50                   	push   %eax
  800e7a:	ff 75 08             	pushl  0x8(%ebp)
  800e7d:	e8 25 14 00 00       	call   8022a7 <strcpy>
  800e82:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800e85:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800e8b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e91:	eb 25                	jmp    800eb8 <walk_path+0x141>
	if (pdir)
  800e93:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	74 08                	je     800ea5 <walk_path+0x12e>
		*pdir = dir;
  800e9d:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800ea3:	89 08                	mov    %ecx,(%eax)
	*pf = f;
  800ea5:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800eab:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800eb1:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
			return -E_BAD_PATH;
  800ec2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ec7:	eb ef                	jmp    800eb8 <walk_path+0x141>
			return -E_NOT_FOUND;
  800ec9:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
  800ece:	eb e8                	jmp    800eb8 <walk_path+0x141>

00800ed0 <dir_alloc_file>:
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 2c             	sub    $0x2c,%esp
  800ed9:	89 c6                	mov    %eax,%esi
  800edb:	89 55 d0             	mov    %edx,-0x30(%ebp)
	assert((dir->f_size % BLKSIZE) == 0);
  800ede:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  800eec:	75 4c                	jne    800f3a <dir_alloc_file+0x6a>
	nblock = dir->f_size / BLKSIZE;
  800eee:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	0f 48 c2             	cmovs  %edx,%eax
  800ef9:	c1 f8 0c             	sar    $0xc,%eax
  800efc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800eff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f02:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	for (i = 0; i < nblock; i++) {
  800f05:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800f08:	74 5b                	je     800f65 <dir_alloc_file+0x95>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	57                   	push   %edi
  800f0e:	53                   	push   %ebx
  800f0f:	56                   	push   %esi
  800f10:	e8 42 fd ff ff       	call   800c57 <file_get_block>
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 41                	js     800f5d <dir_alloc_file+0x8d>
  800f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
			if (f[j].f_name[0] == '\0') {
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	80 38 00             	cmpb   $0x0,(%eax)
  800f2a:	74 27                	je     800f53 <dir_alloc_file+0x83>
  800f2c:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  800f31:	39 d0                	cmp    %edx,%eax
  800f33:	75 f0                	jne    800f25 <dir_alloc_file+0x55>
	for (i = 0; i < nblock; i++) {
  800f35:	83 c3 01             	add    $0x1,%ebx
  800f38:	eb cb                	jmp    800f05 <dir_alloc_file+0x35>
	assert((dir->f_size % BLKSIZE) == 0);
  800f3a:	68 b5 3c 80 00       	push   $0x803cb5
  800f3f:	68 3d 3a 80 00       	push   $0x803a3d
  800f44:	68 ea 00 00 00       	push   $0xea
  800f49:	68 fe 3b 80 00       	push   $0x803bfe
  800f4e:	e8 03 0d 00 00       	call   801c56 <_panic>
				*file = &f[j];
  800f53:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800f56:	89 08                	mov    %ecx,(%eax)
				return 0;
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
	dir->f_size += BLKSIZE;
  800f65:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800f6c:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	ff 75 cc             	pushl  -0x34(%ebp)
  800f79:	56                   	push   %esi
  800f7a:	e8 d8 fc ff ff       	call   800c57 <file_get_block>
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	78 d7                	js     800f5d <dir_alloc_file+0x8d>
	*file = &f[0];
  800f86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f89:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800f8c:	89 07                	mov    %eax,(%edi)
	return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f93:	eb c8                	jmp    800f5d <dir_alloc_file+0x8d>

00800f95 <file_open>:
{
  800f95:	f3 0f 1e fb          	endbr32 
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800f9f:	6a 00                	push   $0x0
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fac:	e8 c6 fd ff ff       	call   800d77 <walk_path>
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <file_read>:
{
  800fb3:	f3 0f 1e fb          	endbr32 
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 2c             	sub    $0x2c,%esp
  800fc0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc6:	8b 4d 14             	mov    0x14(%ebp),%ecx
	if (offset >= f->f_size)
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800fd7:	39 ca                	cmp    %ecx,%edx
  800fd9:	7e 7e                	jle    801059 <file_read+0xa6>
	count = MIN(count, f->f_size - offset);
  800fdb:	29 ca                	sub    %ecx,%edx
  800fdd:	39 da                	cmp    %ebx,%edx
  800fdf:	89 d8                	mov    %ebx,%eax
  800fe1:	0f 46 c2             	cmovbe %edx,%eax
  800fe4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (pos = offset; pos < offset + count;) {
  800fe7:	89 cb                	mov    %ecx,%ebx
  800fe9:	01 c1                	add    %eax,%ecx
  800feb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800fee:	89 de                	mov    %ebx,%esi
  800ff0:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800ff3:	76 61                	jbe    801056 <file_read+0xa3>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ff5:	83 ec 04             	sub    $0x4,%esp
  800ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  801002:	85 db                	test   %ebx,%ebx
  801004:	0f 49 c3             	cmovns %ebx,%eax
  801007:	c1 f8 0c             	sar    $0xc,%eax
  80100a:	50                   	push   %eax
  80100b:	ff 75 08             	pushl  0x8(%ebp)
  80100e:	e8 44 fc ff ff       	call   800c57 <file_get_block>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 3f                	js     801059 <file_read+0xa6>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  80101a:	89 da                	mov    %ebx,%edx
  80101c:	c1 fa 1f             	sar    $0x1f,%edx
  80101f:	c1 ea 14             	shr    $0x14,%edx
  801022:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801025:	25 ff 0f 00 00       	and    $0xfff,%eax
  80102a:	29 d0                	sub    %edx,%eax
  80102c:	ba 00 10 00 00       	mov    $0x1000,%edx
  801031:	29 c2                	sub    %eax,%edx
  801033:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801036:	29 f1                	sub    %esi,%ecx
  801038:	89 ce                	mov    %ecx,%esi
  80103a:	39 ca                	cmp    %ecx,%edx
  80103c:	0f 46 f2             	cmovbe %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	56                   	push   %esi
  801043:	03 45 e4             	add    -0x1c(%ebp),%eax
  801046:	50                   	push   %eax
  801047:	57                   	push   %edi
  801048:	e8 12 14 00 00       	call   80245f <memmove>
		pos += bn;
  80104d:	01 f3                	add    %esi,%ebx
		buf += bn;
  80104f:	01 f7                	add    %esi,%edi
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	eb 98                	jmp    800fee <file_read+0x3b>
	return count;
  801056:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  801059:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  801061:	f3 0f 1e fb          	endbr32 
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	56                   	push   %esi
  801069:	53                   	push   %ebx
  80106a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80106d:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  801070:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  801076:	7f 1b                	jg     801093 <file_set_size+0x32>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  801078:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	53                   	push   %ebx
  801082:	e8 2d f4 ff ff       	call   8004b4 <flush_block>
	return 0;
}
  801087:	b8 00 00 00 00       	mov    $0x0,%eax
  80108c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
		file_truncate_blocks(f, newsize);
  801093:	89 f2                	mov    %esi,%edx
  801095:	89 d8                	mov    %ebx,%eax
  801097:	e8 14 fa ff ff       	call   800ab0 <file_truncate_blocks>
  80109c:	eb da                	jmp    801078 <file_set_size+0x17>

0080109e <file_write>:
{
  80109e:	f3 0f 1e fb          	endbr32 
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 2c             	sub    $0x2c,%esp
  8010ab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
	if (offset + count > f->f_size)
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	03 45 10             	add    0x10(%ebp),%eax
  8010b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8010b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bc:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  8010c2:	77 68                	ja     80112c <file_write+0x8e>
	for (pos = offset; pos < offset + count;) {
  8010c4:	89 de                	mov    %ebx,%esi
  8010c6:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  8010c9:	76 74                	jbe    80113f <file_write+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8010d8:	85 db                	test   %ebx,%ebx
  8010da:	0f 49 c3             	cmovns %ebx,%eax
  8010dd:	c1 f8 0c             	sar    $0xc,%eax
  8010e0:	50                   	push   %eax
  8010e1:	ff 75 08             	pushl  0x8(%ebp)
  8010e4:	e8 6e fb ff ff       	call   800c57 <file_get_block>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 52                	js     801142 <file_write+0xa4>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8010f0:	89 da                	mov    %ebx,%edx
  8010f2:	c1 fa 1f             	sar    $0x1f,%edx
  8010f5:	c1 ea 14             	shr    $0x14,%edx
  8010f8:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  8010fb:	25 ff 0f 00 00       	and    $0xfff,%eax
  801100:	29 d0                	sub    %edx,%eax
  801102:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801107:	29 c1                	sub    %eax,%ecx
  801109:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80110c:	29 f2                	sub    %esi,%edx
  80110e:	39 d1                	cmp    %edx,%ecx
  801110:	89 d6                	mov    %edx,%esi
  801112:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	56                   	push   %esi
  801119:	57                   	push   %edi
  80111a:	03 45 e4             	add    -0x1c(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	e8 3c 13 00 00       	call   80245f <memmove>
		pos += bn;
  801123:	01 f3                	add    %esi,%ebx
		buf += bn;
  801125:	01 f7                	add    %esi,%edi
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	eb 98                	jmp    8010c4 <file_write+0x26>
		if ((r = file_set_size(f, offset + count)) < 0)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	50                   	push   %eax
  801130:	51                   	push   %ecx
  801131:	e8 2b ff ff ff       	call   801061 <file_set_size>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	79 87                	jns    8010c4 <file_write+0x26>
  80113d:	eb 03                	jmp    801142 <file_write+0xa4>
	return count;
  80113f:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801142:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  80114a:	f3 0f 1e fb          	endbr32 
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 10             	sub    $0x10,%esp
  801156:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801159:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115e:	eb 03                	jmp    801163 <file_flush+0x19>
  801160:	83 c3 01             	add    $0x1,%ebx
  801163:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801169:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80116f:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  801175:	0f 49 c2             	cmovns %edx,%eax
  801178:	c1 f8 0c             	sar    $0xc,%eax
  80117b:	39 d8                	cmp    %ebx,%eax
  80117d:	7e 3b                	jle    8011ba <file_flush+0x70>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	6a 00                	push   $0x0
  801184:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801187:	89 da                	mov    %ebx,%edx
  801189:	89 f0                	mov    %esi,%eax
  80118b:	e8 0f f8 ff ff       	call   80099f <file_block_walk>
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 c9                	js     801160 <file_flush+0x16>
		    pdiskbno == NULL || *pdiskbno == 0)
  801197:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80119a:	85 c0                	test   %eax,%eax
  80119c:	74 c2                	je     801160 <file_flush+0x16>
		    pdiskbno == NULL || *pdiskbno == 0)
  80119e:	8b 00                	mov    (%eax),%eax
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	74 bc                	je     801160 <file_flush+0x16>
			continue;
		flush_block(diskaddr(*pdiskbno));
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	50                   	push   %eax
  8011a8:	e8 7d f2 ff ff       	call   80042a <diskaddr>
  8011ad:	89 04 24             	mov    %eax,(%esp)
  8011b0:	e8 ff f2 ff ff       	call   8004b4 <flush_block>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	eb a6                	jmp    801160 <file_flush+0x16>
	}
	flush_block(f);
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	56                   	push   %esi
  8011be:	e8 f1 f2 ff ff       	call   8004b4 <flush_block>
	if (f->f_indirect)
  8011c3:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	75 07                	jne    8011d7 <file_flush+0x8d>
		flush_block(diskaddr(f->f_indirect));
}
  8011d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	50                   	push   %eax
  8011db:	e8 4a f2 ff ff       	call   80042a <diskaddr>
  8011e0:	89 04 24             	mov    %eax,(%esp)
  8011e3:	e8 cc f2 ff ff       	call   8004b4 <flush_block>
  8011e8:	83 c4 10             	add    $0x10,%esp
}
  8011eb:	eb e3                	jmp    8011d0 <file_flush+0x86>

008011ed <file_create>:
{
  8011ed:	f3 0f 1e fb          	endbr32 
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	81 ec a4 00 00 00    	sub    $0xa4,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8011fa:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  801207:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	e8 62 fb ff ff       	call   800d77 <walk_path>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	74 58                	je     801274 <file_create+0x87>
	if (r != -E_NOT_FOUND || dir == 0)
  80121c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80121f:	75 51                	jne    801272 <file_create+0x85>
  801221:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  801227:	85 c9                	test   %ecx,%ecx
  801229:	74 47                	je     801272 <file_create+0x85>
	if ((r = dir_alloc_file(dir, &f)) < 0)
  80122b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
  801231:	89 c8                	mov    %ecx,%eax
  801233:	e8 98 fc ff ff       	call   800ed0 <dir_alloc_file>
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 36                	js     801272 <file_create+0x85>
	strcpy(f->f_name, name);
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
  80124c:	e8 56 10 00 00       	call   8022a7 <strcpy>
	*pf = f;
  801251:	8b 45 0c             	mov    0xc(%ebp),%eax
  801254:	8b 95 70 ff ff ff    	mov    -0x90(%ebp),%edx
  80125a:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80125c:	83 c4 04             	add    $0x4,%esp
  80125f:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
  801265:	e8 e0 fe ff ff       	call   80114a <file_flush>
	return 0;
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    
		return -E_FILE_EXISTS;
  801274:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801279:	eb f7                	jmp    801272 <file_create+0x85>

0080127b <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80127b:	f3 0f 1e fb          	endbr32 
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	53                   	push   %ebx
  801283:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801286:	bb 01 00 00 00       	mov    $0x1,%ebx
  80128b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801290:	39 58 04             	cmp    %ebx,0x4(%eax)
  801293:	76 19                	jbe    8012ae <fs_sync+0x33>
		flush_block(diskaddr(i));
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	53                   	push   %ebx
  801299:	e8 8c f1 ff ff       	call   80042a <diskaddr>
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 0e f2 ff ff       	call   8004b4 <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  8012a6:	83 c3 01             	add    $0x1,%ebx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	eb dd                	jmp    80128b <fs_sync+0x10>
}
  8012ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <outw>:
{
  8012b3:	89 c1                	mov    %eax,%ecx
  8012b5:	89 d0                	mov    %edx,%eax
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8012b7:	89 ca                	mov    %ecx,%edx
  8012b9:	66 ef                	out    %ax,(%dx)
}
  8012bb:	c3                   	ret    

008012bc <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8012bc:	f3 0f 1e fb          	endbr32 
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8012c6:	e8 b0 ff ff ff       	call   80127b <fs_sync>
	return 0;
}
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    

008012d2 <serve_init>:
{
  8012d2:	f3 0f 1e fb          	endbr32 
  8012d6:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  8012db:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8012e5:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd *) va;
  8012e7:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8012ea:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8012f0:	83 c0 01             	add    $0x1,%eax
  8012f3:	83 c2 10             	add    $0x10,%edx
  8012f6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012fb:	75 e8                	jne    8012e5 <serve_init+0x13>
}
  8012fd:	c3                   	ret    

008012fe <openfile_alloc>:
{
  8012fe:	f3 0f 1e fb          	endbr32 
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801313:	89 de                	mov    %ebx,%esi
  801315:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
  801321:	e8 27 1f 00 00       	call   80324d <pageref>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	74 17                	je     801344 <openfile_alloc+0x46>
  80132d:	83 f8 01             	cmp    $0x1,%eax
  801330:	74 30                	je     801362 <openfile_alloc+0x64>
	for (i = 0; i < MAXOPEN; i++) {
  801332:	83 c3 01             	add    $0x1,%ebx
  801335:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80133b:	75 d6                	jne    801313 <openfile_alloc+0x15>
	return -E_MAX_OPEN;
  80133d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801342:	eb 4f                	jmp    801393 <openfile_alloc+0x95>
			if ((r = sys_page_alloc(0,
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	6a 07                	push   $0x7
			                        opentab[i].o_fd,
  801349:	89 d8                	mov    %ebx,%eax
  80134b:	c1 e0 04             	shl    $0x4,%eax
			if ((r = sys_page_alloc(0,
  80134e:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801354:	6a 00                	push   $0x0
  801356:	e8 d4 13 00 00       	call   80272f <sys_page_alloc>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 31                	js     801393 <openfile_alloc+0x95>
			opentab[i].o_fileid += MAXOPEN;
  801362:	c1 e3 04             	shl    $0x4,%ebx
  801365:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80136c:	04 00 00 
			*o = &opentab[i];
  80136f:	81 c6 60 50 80 00    	add    $0x805060,%esi
  801375:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	68 00 10 00 00       	push   $0x1000
  80137f:	6a 00                	push   $0x0
  801381:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801387:	e8 85 10 00 00       	call   802411 <memset>
			return (*o)->o_fileid;
  80138c:	8b 07                	mov    (%edi),%eax
  80138e:	8b 00                	mov    (%eax),%eax
  801390:	83 c4 10             	add    $0x10,%esp
}
  801393:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <openfile_lookup>:
{
  80139b:	f3 0f 1e fb          	endbr32 
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	57                   	push   %edi
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 18             	sub    $0x18,%esp
  8013a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  8013ab:	89 fb                	mov    %edi,%ebx
  8013ad:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8013b3:	89 de                	mov    %ebx,%esi
  8013b5:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8013b8:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  8013be:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8013c4:	e8 84 1e 00 00       	call   80324d <pageref>
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	83 f8 01             	cmp    $0x1,%eax
  8013cf:	7e 1d                	jle    8013ee <openfile_lookup+0x53>
  8013d1:	c1 e3 04             	shl    $0x4,%ebx
  8013d4:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  8013da:	75 19                	jne    8013f5 <openfile_lookup+0x5a>
	*po = o;
  8013dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8013df:	89 30                	mov    %esi,(%eax)
	return 0;
  8013e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5e                   	pop    %esi
  8013eb:	5f                   	pop    %edi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    
		return -E_INVAL;
  8013ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f3:	eb f1                	jmp    8013e6 <openfile_lookup+0x4b>
  8013f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fa:	eb ea                	jmp    8013e6 <openfile_lookup+0x4b>

008013fc <serve_set_size>:
{
  8013fc:	f3 0f 1e fb          	endbr32 
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 18             	sub    $0x18,%esp
  801407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80140a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 33                	pushl  (%ebx)
  801410:	ff 75 08             	pushl  0x8(%ebp)
  801413:	e8 83 ff ff ff       	call   80139b <openfile_lookup>
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 14                	js     801433 <serve_set_size+0x37>
	return file_set_size(o->o_file, req->req_size);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	ff 73 04             	pushl  0x4(%ebx)
  801425:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801428:	ff 70 04             	pushl  0x4(%eax)
  80142b:	e8 31 fc ff ff       	call   801061 <file_set_size>
  801430:	83 c4 10             	add    $0x10,%esp
}
  801433:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <serve_read>:
{
  801438:	f3 0f 1e fb          	endbr32 
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	83 ec 18             	sub    $0x18,%esp
  801443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int file_is_open = openfile_lookup(envid, req->req_fileid, &file);
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	ff 33                	pushl  (%ebx)
  80144c:	ff 75 08             	pushl  0x8(%ebp)
  80144f:	e8 47 ff ff ff       	call   80139b <openfile_lookup>
	if (file_is_open < 0)
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 25                	js     801480 <serve_read+0x48>
	int bytes_read = file_read(file->o_file, ret->ret_buf, req->req_n, file->o_fd->fd_offset);
  80145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145e:	8b 50 0c             	mov    0xc(%eax),%edx
  801461:	ff 72 04             	pushl  0x4(%edx)
  801464:	ff 73 04             	pushl  0x4(%ebx)
  801467:	53                   	push   %ebx
  801468:	ff 70 04             	pushl  0x4(%eax)
  80146b:	e8 43 fb ff ff       	call   800fb3 <file_read>
	if (bytes_read < 0)
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 09                	js     801480 <serve_read+0x48>
	file->o_fd->fd_offset += bytes_read;
  801477:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147a:	8b 52 0c             	mov    0xc(%edx),%edx
  80147d:	01 42 04             	add    %eax,0x4(%edx)
}
  801480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <serve_write>:
{
  801485:	f3 0f 1e fb          	endbr32 
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 18             	sub    $0x18,%esp
  801490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int file_is_open = openfile_lookup(envid, req->req_fileid, &file);
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 33                	pushl  (%ebx)
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 fa fe ff ff       	call   80139b <openfile_lookup>
	if (file_is_open < 0)
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 28                	js     8014d0 <serve_write+0x4b>
	int bytes_write = file_write(file->o_file, req->req_buf, req->req_n, file->o_fd->fd_offset);
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	8b 50 0c             	mov    0xc(%eax),%edx
  8014ae:	ff 72 04             	pushl  0x4(%edx)
  8014b1:	ff 73 04             	pushl  0x4(%ebx)
  8014b4:	83 c3 08             	add    $0x8,%ebx
  8014b7:	53                   	push   %ebx
  8014b8:	ff 70 04             	pushl  0x4(%eax)
  8014bb:	e8 de fb ff ff       	call   80109e <file_write>
	if (bytes_write < 0)
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 09                	js     8014d0 <serve_write+0x4b>
	file->o_fd->fd_offset += bytes_write;
  8014c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ca:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cd:	01 42 04             	add    %eax,0x4(%edx)
}
  8014d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <serve_stat>:
{
  8014d5:	f3 0f 1e fb          	endbr32 
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 18             	sub    $0x18,%esp
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	ff 33                	pushl  (%ebx)
  8014e9:	ff 75 08             	pushl  0x8(%ebp)
  8014ec:	e8 aa fe ff ff       	call   80139b <openfile_lookup>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 3f                	js     801537 <serve_stat+0x62>
	strcpy(ret->ret_name, o->o_file->f_name);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	ff 70 04             	pushl  0x4(%eax)
  801501:	53                   	push   %ebx
  801502:	e8 a0 0d 00 00       	call   8022a7 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150a:	8b 50 04             	mov    0x4(%eax),%edx
  80150d:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801513:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801519:	8b 40 04             	mov    0x4(%eax),%eax
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801526:	0f 94 c0             	sete   %al
  801529:	0f b6 c0             	movzbl %al,%eax
  80152c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801537:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <serve_flush>:
{
  80153c:	f3 0f 1e fb          	endbr32 
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	e8 44 fe ff ff       	call   80139b <openfile_lookup>
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 16                	js     801574 <serve_flush+0x38>
	file_flush(o->o_file);
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	ff 70 04             	pushl  0x4(%eax)
  801567:	e8 de fb ff ff       	call   80114a <file_flush>
	return 0;
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <serve_open>:
{
  801576:	f3 0f 1e fb          	endbr32 
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801584:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  801587:	68 00 04 00 00       	push   $0x400
  80158c:	53                   	push   %ebx
  80158d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	e8 c6 0e 00 00       	call   80245f <memmove>
	path[MAXPATHLEN - 1] = 0;
  801599:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  80159d:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8015a3:	89 04 24             	mov    %eax,(%esp)
  8015a6:	e8 53 fd ff ff       	call   8012fe <openfile_alloc>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	0f 88 f0 00 00 00    	js     8016a6 <serve_open+0x130>
	if (req->req_omode & O_CREAT) {
  8015b6:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8015bd:	74 33                	je     8015f2 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	e8 18 fc ff ff       	call   8011ed <file_create>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	79 37                	jns    801613 <serve_open+0x9d>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8015dc:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8015e3:	0f 85 bd 00 00 00    	jne    8016a6 <serve_open+0x130>
  8015e9:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8015ec:	0f 85 b4 00 00 00    	jne    8016a6 <serve_open+0x130>
		if ((r = file_open(path, &f)) < 0) {
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	e8 8d f9 ff ff       	call   800f95 <file_open>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	0f 88 93 00 00 00    	js     8016a6 <serve_open+0x130>
	if (req->req_omode & O_TRUNC) {
  801613:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80161a:	74 17                	je     801633 <serve_open+0xbd>
		if ((r = file_set_size(f, 0)) < 0) {
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	6a 00                	push   $0x0
  801621:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801627:	e8 35 fa ff ff       	call   801061 <file_set_size>
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 73                	js     8016a6 <serve_open+0x130>
	if ((r = file_open(path, &f)) < 0) {
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	e8 4c f9 ff ff       	call   800f95 <file_open>
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 56                	js     8016a6 <serve_open+0x130>
	o->o_file = f;
  801650:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801656:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80165c:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  80165f:	8b 50 0c             	mov    0xc(%eax),%edx
  801662:	8b 08                	mov    (%eax),%ecx
  801664:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801667:	8b 48 0c             	mov    0xc(%eax),%ecx
  80166a:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801670:	83 e2 03             	and    $0x3,%edx
  801673:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801676:	8b 40 0c             	mov    0xc(%eax),%eax
  801679:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80167f:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801681:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801687:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80168d:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  801690:	8b 50 0c             	mov    0xc(%eax),%edx
  801693:	8b 45 10             	mov    0x10(%ebp),%eax
  801696:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P | PTE_U | PTE_W | PTE_SHARE;
  801698:	8b 45 14             	mov    0x14(%ebp),%eax
  80169b:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <serve>:
	[FSREQ_SYNC] = serve_sync
};

void
serve(void)
{
  8016ab:	f3 0f 1e fb          	endbr32 
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8016b7:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8016ba:	8d 75 f4             	lea    -0xc(%ebp),%esi
  8016bd:	e9 82 00 00 00       	jmp    801744 <serve+0x99>
			cprintf("Invalid request from %08x: no argument page\n",
			        whom);
			continue;  // just leave it hanging...
		}

		pg = NULL;
  8016c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8016c9:	83 f8 01             	cmp    $0x1,%eax
  8016cc:	74 23                	je     8016f1 <serve+0x46>
			r = serve_open(whom, (struct Fsreq_open *) fsreq, &pg, &perm);
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8016ce:	83 f8 08             	cmp    $0x8,%eax
  8016d1:	77 36                	ja     801709 <serve+0x5e>
  8016d3:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8016da:	85 d2                	test   %edx,%edx
  8016dc:	74 2b                	je     801709 <serve+0x5e>
			r = handlers[req](whom, fsreq);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	ff 35 44 50 80 00    	pushl  0x805044
  8016e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ea:	ff d2                	call   *%edx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb 31                	jmp    801722 <serve+0x77>
			r = serve_open(whom, (struct Fsreq_open *) fsreq, &pg, &perm);
  8016f1:	53                   	push   %ebx
  8016f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	ff 35 44 50 80 00    	pushl  0x805044
  8016fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ff:	e8 72 fe ff ff       	call   801576 <serve_open>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	eb 19                	jmp    801722 <serve+0x77>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	ff 75 f4             	pushl  -0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	68 04 3d 80 00       	push   $0x803d04
  801715:	e8 23 06 00 00       	call   801d3d <cprintf>
  80171a:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80171d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801722:	ff 75 f0             	pushl  -0x10(%ebp)
  801725:	ff 75 ec             	pushl  -0x14(%ebp)
  801728:	50                   	push   %eax
  801729:	ff 75 f4             	pushl  -0xc(%ebp)
  80172c:	e8 2c 12 00 00       	call   80295d <ipc_send>
		sys_page_unmap(0, fsreq);
  801731:	83 c4 08             	add    $0x8,%esp
  801734:	ff 35 44 50 80 00    	pushl  0x805044
  80173a:	6a 00                	push   $0x0
  80173c:	e8 40 10 00 00       	call   802781 <sys_page_unmap>
  801741:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  801744:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80174b:	83 ec 04             	sub    $0x4,%esp
  80174e:	53                   	push   %ebx
  80174f:	ff 35 44 50 80 00    	pushl  0x805044
  801755:	56                   	push   %esi
  801756:	e8 94 11 00 00       	call   8028ef <ipc_recv>
		if (!(perm & PTE_P)) {
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801762:	0f 85 5a ff ff ff    	jne    8016c2 <serve+0x17>
			cprintf("Invalid request from %08x: no argument page\n",
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	ff 75 f4             	pushl  -0xc(%ebp)
  80176e:	68 d4 3c 80 00       	push   $0x803cd4
  801773:	e8 c5 05 00 00       	call   801d3d <cprintf>
			continue;  // just leave it hanging...
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	eb c7                	jmp    801744 <serve+0x99>

0080177d <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80177d:	f3 0f 1e fb          	endbr32 
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801787:	c7 05 60 90 80 00 27 	movl   $0x803d27,0x809060
  80178e:	3d 80 00 
	cprintf("FS is running\n");
  801791:	68 2a 3d 80 00       	push   $0x803d2a
  801796:	e8 a2 05 00 00       	call   801d3d <cprintf>

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
  80179b:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8017a0:	b8 00 8a 00 00       	mov    $0x8a00,%eax
  8017a5:	e8 09 fb ff ff       	call   8012b3 <outw>
	cprintf("FS can do I/O\n");
  8017aa:	c7 04 24 39 3d 80 00 	movl   $0x803d39,(%esp)
  8017b1:	e8 87 05 00 00       	call   801d3d <cprintf>

	serve_init();
  8017b6:	e8 17 fb ff ff       	call   8012d2 <serve_init>
	fs_init();
  8017bb:	e8 34 f4 ff ff       	call   800bf4 <fs_init>
	fs_test();
  8017c0:	e8 05 00 00 00       	call   8017ca <fs_test>
	serve();
  8017c5:	e8 e1 fe ff ff       	call   8016ab <serve>

008017ca <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8017ca:	f3 0f 1e fb          	endbr32 
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8017d5:	6a 07                	push   $0x7
  8017d7:	68 00 10 00 00       	push   $0x1000
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 4c 0f 00 00       	call   80272f <sys_page_alloc>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	0f 88 68 02 00 00    	js     801a56 <fs_test+0x28c>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	68 00 10 00 00       	push   $0x1000
  8017f6:	ff 35 04 a0 80 00    	pushl  0x80a004
  8017fc:	68 00 10 00 00       	push   $0x1000
  801801:	e8 59 0c 00 00       	call   80245f <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801806:	e8 2b f1 ff ff       	call   800936 <alloc_block>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	0f 88 52 02 00 00    	js     801a68 <fs_test+0x29e>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801816:	8d 50 1f             	lea    0x1f(%eax),%edx
  801819:	0f 49 d0             	cmovns %eax,%edx
  80181c:	c1 fa 05             	sar    $0x5,%edx
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	c1 fb 1f             	sar    $0x1f,%ebx
  801824:	c1 eb 1b             	shr    $0x1b,%ebx
  801827:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  80182a:	83 e1 1f             	and    $0x1f,%ecx
  80182d:	29 d9                	sub    %ebx,%ecx
  80182f:	b8 01 00 00 00       	mov    $0x1,%eax
  801834:	d3 e0                	shl    %cl,%eax
  801836:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  80183d:	0f 84 37 02 00 00    	je     801a7a <fs_test+0x2b0>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801843:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801849:	85 04 91             	test   %eax,(%ecx,%edx,4)
  80184c:	0f 85 3e 02 00 00    	jne    801a90 <fs_test+0x2c6>
	cprintf("alloc_block is good\n");
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	68 90 3d 80 00       	push   $0x803d90
  80185a:	e8 de 04 00 00       	call   801d3d <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80185f:	83 c4 08             	add    $0x8,%esp
  801862:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801865:	50                   	push   %eax
  801866:	68 a5 3d 80 00       	push   $0x803da5
  80186b:	e8 25 f7 ff ff       	call   800f95 <file_open>
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801876:	74 08                	je     801880 <fs_test+0xb6>
  801878:	85 c0                	test   %eax,%eax
  80187a:	0f 88 26 02 00 00    	js     801aa6 <fs_test+0x2dc>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 84 30 02 00 00    	je     801ab8 <fs_test+0x2ee>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	68 c9 3d 80 00       	push   $0x803dc9
  801894:	e8 fc f6 ff ff       	call   800f95 <file_open>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	0f 88 28 02 00 00    	js     801acc <fs_test+0x302>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  8018a4:	83 ec 0c             	sub    $0xc,%esp
  8018a7:	68 e9 3d 80 00       	push   $0x803de9
  8018ac:	e8 8c 04 00 00       	call   801d3d <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8018b1:	83 c4 0c             	add    $0xc,%esp
  8018b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b7:	50                   	push   %eax
  8018b8:	6a 00                	push   $0x0
  8018ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bd:	e8 95 f3 ff ff       	call   800c57 <file_get_block>
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	0f 88 11 02 00 00    	js     801ade <fs_test+0x314>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	68 30 3f 80 00       	push   $0x803f30
  8018d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d8:	e8 89 0a 00 00       	call   802366 <strcmp>
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	0f 85 08 02 00 00    	jne    801af0 <fs_test+0x326>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	68 0f 3e 80 00       	push   $0x803e0f
  8018f0:	e8 48 04 00 00       	call   801d3d <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8018f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f8:	0f b6 10             	movzbl (%eax),%edx
  8018fb:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801900:	c1 e8 0c             	shr    $0xc,%eax
  801903:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	a8 40                	test   $0x40,%al
  80190f:	0f 84 ef 01 00 00    	je     801b04 <fs_test+0x33a>
	file_flush(f);
  801915:	83 ec 0c             	sub    $0xc,%esp
  801918:	ff 75 f4             	pushl  -0xc(%ebp)
  80191b:	e8 2a f8 ff ff       	call   80114a <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801920:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801923:	c1 e8 0c             	shr    $0xc,%eax
  801926:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	a8 40                	test   $0x40,%al
  801932:	0f 85 e2 01 00 00    	jne    801b1a <fs_test+0x350>
	cprintf("file_flush is good\n");
  801938:	83 ec 0c             	sub    $0xc,%esp
  80193b:	68 43 3e 80 00       	push   $0x803e43
  801940:	e8 f8 03 00 00       	call   801d3d <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801945:	83 c4 08             	add    $0x8,%esp
  801948:	6a 00                	push   $0x0
  80194a:	ff 75 f4             	pushl  -0xc(%ebp)
  80194d:	e8 0f f7 ff ff       	call   801061 <file_set_size>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	0f 88 d3 01 00 00    	js     801b30 <fs_test+0x366>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  80195d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801960:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801967:	0f 85 d5 01 00 00    	jne    801b42 <fs_test+0x378>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80196d:	c1 e8 0c             	shr    $0xc,%eax
  801970:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801977:	a8 40                	test   $0x40,%al
  801979:	0f 85 d9 01 00 00    	jne    801b58 <fs_test+0x38e>
	cprintf("file_truncate is good\n");
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	68 97 3e 80 00       	push   $0x803e97
  801987:	e8 b1 03 00 00       	call   801d3d <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80198c:	c7 04 24 30 3f 80 00 	movl   $0x803f30,(%esp)
  801993:	e8 cc 08 00 00       	call   802264 <strlen>
  801998:	83 c4 08             	add    $0x8,%esp
  80199b:	50                   	push   %eax
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	e8 bd f6 ff ff       	call   801061 <file_set_size>
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 bf 01 00 00    	js     801b6e <fs_test+0x3a4>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b2:	89 c2                	mov    %eax,%edx
  8019b4:	c1 ea 0c             	shr    $0xc,%edx
  8019b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019be:	f6 c2 40             	test   $0x40,%dl
  8019c1:	0f 85 b9 01 00 00    	jne    801b80 <fs_test+0x3b6>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019c7:	83 ec 04             	sub    $0x4,%esp
  8019ca:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8019cd:	52                   	push   %edx
  8019ce:	6a 00                	push   $0x0
  8019d0:	50                   	push   %eax
  8019d1:	e8 81 f2 ff ff       	call   800c57 <file_get_block>
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	0f 88 b5 01 00 00    	js     801b96 <fs_test+0x3cc>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	68 30 3f 80 00       	push   $0x803f30
  8019e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ec:	e8 b6 08 00 00       	call   8022a7 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f4:	c1 e8 0c             	shr    $0xc,%eax
  8019f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	a8 40                	test   $0x40,%al
  801a03:	0f 84 9f 01 00 00    	je     801ba8 <fs_test+0x3de>
	file_flush(f);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0f:	e8 36 f7 ff ff       	call   80114a <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a17:	c1 e8 0c             	shr    $0xc,%eax
  801a1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	a8 40                	test   $0x40,%al
  801a26:	0f 85 92 01 00 00    	jne    801bbe <fs_test+0x3f4>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2f:	c1 e8 0c             	shr    $0xc,%eax
  801a32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a39:	a8 40                	test   $0x40,%al
  801a3b:	0f 85 93 01 00 00    	jne    801bd4 <fs_test+0x40a>
	cprintf("file rewrite is good\n");
  801a41:	83 ec 0c             	sub    $0xc,%esp
  801a44:	68 d7 3e 80 00       	push   $0x803ed7
  801a49:	e8 ef 02 00 00       	call   801d3d <cprintf>
}
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  801a56:	50                   	push   %eax
  801a57:	68 48 3d 80 00       	push   $0x803d48
  801a5c:	6a 12                	push   $0x12
  801a5e:	68 5b 3d 80 00       	push   $0x803d5b
  801a63:	e8 ee 01 00 00       	call   801c56 <_panic>
		panic("alloc_block: %e", r);
  801a68:	50                   	push   %eax
  801a69:	68 65 3d 80 00       	push   $0x803d65
  801a6e:	6a 17                	push   $0x17
  801a70:	68 5b 3d 80 00       	push   $0x803d5b
  801a75:	e8 dc 01 00 00       	call   801c56 <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  801a7a:	68 75 3d 80 00       	push   $0x803d75
  801a7f:	68 3d 3a 80 00       	push   $0x803a3d
  801a84:	6a 19                	push   $0x19
  801a86:	68 5b 3d 80 00       	push   $0x803d5b
  801a8b:	e8 c6 01 00 00       	call   801c56 <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801a90:	68 f0 3e 80 00       	push   $0x803ef0
  801a95:	68 3d 3a 80 00       	push   $0x803a3d
  801a9a:	6a 1b                	push   $0x1b
  801a9c:	68 5b 3d 80 00       	push   $0x803d5b
  801aa1:	e8 b0 01 00 00       	call   801c56 <_panic>
		panic("file_open /not-found: %e", r);
  801aa6:	50                   	push   %eax
  801aa7:	68 b0 3d 80 00       	push   $0x803db0
  801aac:	6a 1f                	push   $0x1f
  801aae:	68 5b 3d 80 00       	push   $0x803d5b
  801ab3:	e8 9e 01 00 00       	call   801c56 <_panic>
		panic("file_open /not-found succeeded!");
  801ab8:	83 ec 04             	sub    $0x4,%esp
  801abb:	68 10 3f 80 00       	push   $0x803f10
  801ac0:	6a 21                	push   $0x21
  801ac2:	68 5b 3d 80 00       	push   $0x803d5b
  801ac7:	e8 8a 01 00 00       	call   801c56 <_panic>
		panic("file_open /newmotd: %e", r);
  801acc:	50                   	push   %eax
  801acd:	68 d2 3d 80 00       	push   $0x803dd2
  801ad2:	6a 23                	push   $0x23
  801ad4:	68 5b 3d 80 00       	push   $0x803d5b
  801ad9:	e8 78 01 00 00       	call   801c56 <_panic>
		panic("file_get_block: %e", r);
  801ade:	50                   	push   %eax
  801adf:	68 fc 3d 80 00       	push   $0x803dfc
  801ae4:	6a 27                	push   $0x27
  801ae6:	68 5b 3d 80 00       	push   $0x803d5b
  801aeb:	e8 66 01 00 00       	call   801c56 <_panic>
		panic("file_get_block returned wrong data");
  801af0:	83 ec 04             	sub    $0x4,%esp
  801af3:	68 58 3f 80 00       	push   $0x803f58
  801af8:	6a 29                	push   $0x29
  801afa:	68 5b 3d 80 00       	push   $0x803d5b
  801aff:	e8 52 01 00 00       	call   801c56 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b04:	68 28 3e 80 00       	push   $0x803e28
  801b09:	68 3d 3a 80 00       	push   $0x803a3d
  801b0e:	6a 2d                	push   $0x2d
  801b10:	68 5b 3d 80 00       	push   $0x803d5b
  801b15:	e8 3c 01 00 00       	call   801c56 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b1a:	68 27 3e 80 00       	push   $0x803e27
  801b1f:	68 3d 3a 80 00       	push   $0x803a3d
  801b24:	6a 2f                	push   $0x2f
  801b26:	68 5b 3d 80 00       	push   $0x803d5b
  801b2b:	e8 26 01 00 00       	call   801c56 <_panic>
		panic("file_set_size: %e", r);
  801b30:	50                   	push   %eax
  801b31:	68 57 3e 80 00       	push   $0x803e57
  801b36:	6a 33                	push   $0x33
  801b38:	68 5b 3d 80 00       	push   $0x803d5b
  801b3d:	e8 14 01 00 00       	call   801c56 <_panic>
	assert(f->f_direct[0] == 0);
  801b42:	68 69 3e 80 00       	push   $0x803e69
  801b47:	68 3d 3a 80 00       	push   $0x803a3d
  801b4c:	6a 34                	push   $0x34
  801b4e:	68 5b 3d 80 00       	push   $0x803d5b
  801b53:	e8 fe 00 00 00       	call   801c56 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b58:	68 7d 3e 80 00       	push   $0x803e7d
  801b5d:	68 3d 3a 80 00       	push   $0x803a3d
  801b62:	6a 35                	push   $0x35
  801b64:	68 5b 3d 80 00       	push   $0x803d5b
  801b69:	e8 e8 00 00 00       	call   801c56 <_panic>
		panic("file_set_size 2: %e", r);
  801b6e:	50                   	push   %eax
  801b6f:	68 ae 3e 80 00       	push   $0x803eae
  801b74:	6a 39                	push   $0x39
  801b76:	68 5b 3d 80 00       	push   $0x803d5b
  801b7b:	e8 d6 00 00 00       	call   801c56 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b80:	68 7d 3e 80 00       	push   $0x803e7d
  801b85:	68 3d 3a 80 00       	push   $0x803a3d
  801b8a:	6a 3a                	push   $0x3a
  801b8c:	68 5b 3d 80 00       	push   $0x803d5b
  801b91:	e8 c0 00 00 00       	call   801c56 <_panic>
		panic("file_get_block 2: %e", r);
  801b96:	50                   	push   %eax
  801b97:	68 c2 3e 80 00       	push   $0x803ec2
  801b9c:	6a 3c                	push   $0x3c
  801b9e:	68 5b 3d 80 00       	push   $0x803d5b
  801ba3:	e8 ae 00 00 00       	call   801c56 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801ba8:	68 28 3e 80 00       	push   $0x803e28
  801bad:	68 3d 3a 80 00       	push   $0x803a3d
  801bb2:	6a 3e                	push   $0x3e
  801bb4:	68 5b 3d 80 00       	push   $0x803d5b
  801bb9:	e8 98 00 00 00       	call   801c56 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801bbe:	68 27 3e 80 00       	push   $0x803e27
  801bc3:	68 3d 3a 80 00       	push   $0x803a3d
  801bc8:	6a 40                	push   $0x40
  801bca:	68 5b 3d 80 00       	push   $0x803d5b
  801bcf:	e8 82 00 00 00       	call   801c56 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801bd4:	68 7d 3e 80 00       	push   $0x803e7d
  801bd9:	68 3d 3a 80 00       	push   $0x803a3d
  801bde:	6a 41                	push   $0x41
  801be0:	68 5b 3d 80 00       	push   $0x803d5b
  801be5:	e8 6c 00 00 00       	call   801c56 <_panic>

00801bea <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801bea:	f3 0f 1e fb          	endbr32 
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bf6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  801bf9:	e8 de 0a 00 00       	call   8026dc <sys_getenvid>
	if (id >= 0)
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 12                	js     801c14 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  801c02:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c07:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c0a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c0f:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c14:	85 db                	test   %ebx,%ebx
  801c16:	7e 07                	jle    801c1f <libmain+0x35>
		binaryname = argv[0];
  801c18:	8b 06                	mov    (%esi),%eax
  801c1a:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c1f:	83 ec 08             	sub    $0x8,%esp
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	e8 54 fb ff ff       	call   80177d <umain>

	// exit gracefully
	exit();
  801c29:	e8 0a 00 00 00       	call   801c38 <exit>
}
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c38:	f3 0f 1e fb          	endbr32 
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801c42:	e8 ab 0f 00 00       	call   802bf2 <close_all>
	sys_env_destroy(0);
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 65 0a 00 00       	call   8026b6 <sys_env_destroy>
}
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c56:	f3 0f 1e fb          	endbr32 
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c5f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c62:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801c68:	e8 6f 0a 00 00       	call   8026dc <sys_getenvid>
  801c6d:	83 ec 0c             	sub    $0xc,%esp
  801c70:	ff 75 0c             	pushl  0xc(%ebp)
  801c73:	ff 75 08             	pushl  0x8(%ebp)
  801c76:	56                   	push   %esi
  801c77:	50                   	push   %eax
  801c78:	68 88 3f 80 00       	push   $0x803f88
  801c7d:	e8 bb 00 00 00       	call   801d3d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c82:	83 c4 18             	add    $0x18,%esp
  801c85:	53                   	push   %ebx
  801c86:	ff 75 10             	pushl  0x10(%ebp)
  801c89:	e8 5a 00 00 00       	call   801ce8 <vcprintf>
	cprintf("\n");
  801c8e:	c7 04 24 95 3b 80 00 	movl   $0x803b95,(%esp)
  801c95:	e8 a3 00 00 00       	call   801d3d <cprintf>
  801c9a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c9d:	cc                   	int3   
  801c9e:	eb fd                	jmp    801c9d <_panic+0x47>

00801ca0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 04             	sub    $0x4,%esp
  801cab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801cae:	8b 13                	mov    (%ebx),%edx
  801cb0:	8d 42 01             	lea    0x1(%edx),%eax
  801cb3:	89 03                	mov    %eax,(%ebx)
  801cb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801cbc:	3d ff 00 00 00       	cmp    $0xff,%eax
  801cc1:	74 09                	je     801ccc <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801cc3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801ccc:	83 ec 08             	sub    $0x8,%esp
  801ccf:	68 ff 00 00 00       	push   $0xff
  801cd4:	8d 43 08             	lea    0x8(%ebx),%eax
  801cd7:	50                   	push   %eax
  801cd8:	e8 87 09 00 00       	call   802664 <sys_cputs>
		b->idx = 0;
  801cdd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	eb db                	jmp    801cc3 <putch+0x23>

00801ce8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801ce8:	f3 0f 1e fb          	endbr32 
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801cf5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801cfc:	00 00 00 
	b.cnt = 0;
  801cff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d06:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d09:	ff 75 0c             	pushl  0xc(%ebp)
  801d0c:	ff 75 08             	pushl  0x8(%ebp)
  801d0f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	68 a0 1c 80 00       	push   $0x801ca0
  801d1b:	e8 80 01 00 00       	call   801ea0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d20:	83 c4 08             	add    $0x8,%esp
  801d23:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801d29:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d2f:	50                   	push   %eax
  801d30:	e8 2f 09 00 00       	call   802664 <sys_cputs>

	return b.cnt;
}
  801d35:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d3d:	f3 0f 1e fb          	endbr32 
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801d4a:	50                   	push   %eax
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 95 ff ff ff       	call   801ce8 <vcprintf>
	va_end(ap);

	return cnt;
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	57                   	push   %edi
  801d59:	56                   	push   %esi
  801d5a:	53                   	push   %ebx
  801d5b:	83 ec 1c             	sub    $0x1c,%esp
  801d5e:	89 c7                	mov    %eax,%edi
  801d60:	89 d6                	mov    %edx,%esi
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d68:	89 d1                	mov    %edx,%ecx
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d6f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801d72:	8b 45 10             	mov    0x10(%ebp),%eax
  801d75:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801d78:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801d82:	39 c2                	cmp    %eax,%edx
  801d84:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801d87:	72 3e                	jb     801dc7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801d89:	83 ec 0c             	sub    $0xc,%esp
  801d8c:	ff 75 18             	pushl  0x18(%ebp)
  801d8f:	83 eb 01             	sub    $0x1,%ebx
  801d92:	53                   	push   %ebx
  801d93:	50                   	push   %eax
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d9a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d9d:	ff 75 dc             	pushl  -0x24(%ebp)
  801da0:	ff 75 d8             	pushl  -0x28(%ebp)
  801da3:	e8 e8 19 00 00       	call   803790 <__udivdi3>
  801da8:	83 c4 18             	add    $0x18,%esp
  801dab:	52                   	push   %edx
  801dac:	50                   	push   %eax
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	e8 9f ff ff ff       	call   801d55 <printnum>
  801db6:	83 c4 20             	add    $0x20,%esp
  801db9:	eb 13                	jmp    801dce <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	56                   	push   %esi
  801dbf:	ff 75 18             	pushl  0x18(%ebp)
  801dc2:	ff d7                	call   *%edi
  801dc4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801dc7:	83 eb 01             	sub    $0x1,%ebx
  801dca:	85 db                	test   %ebx,%ebx
  801dcc:	7f ed                	jg     801dbb <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801dce:	83 ec 08             	sub    $0x8,%esp
  801dd1:	56                   	push   %esi
  801dd2:	83 ec 04             	sub    $0x4,%esp
  801dd5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dd8:	ff 75 e0             	pushl  -0x20(%ebp)
  801ddb:	ff 75 dc             	pushl  -0x24(%ebp)
  801dde:	ff 75 d8             	pushl  -0x28(%ebp)
  801de1:	e8 ba 1a 00 00       	call   8038a0 <__umoddi3>
  801de6:	83 c4 14             	add    $0x14,%esp
  801de9:	0f be 80 ab 3f 80 00 	movsbl 0x803fab(%eax),%eax
  801df0:	50                   	push   %eax
  801df1:	ff d7                	call   *%edi
}
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5f                   	pop    %edi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801dfe:	83 fa 01             	cmp    $0x1,%edx
  801e01:	7f 13                	jg     801e16 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801e03:	85 d2                	test   %edx,%edx
  801e05:	74 1c                	je     801e23 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801e07:	8b 10                	mov    (%eax),%edx
  801e09:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e0c:	89 08                	mov    %ecx,(%eax)
  801e0e:	8b 02                	mov    (%edx),%eax
  801e10:	ba 00 00 00 00       	mov    $0x0,%edx
  801e15:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801e16:	8b 10                	mov    (%eax),%edx
  801e18:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e1b:	89 08                	mov    %ecx,(%eax)
  801e1d:	8b 02                	mov    (%edx),%eax
  801e1f:	8b 52 04             	mov    0x4(%edx),%edx
  801e22:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801e23:	8b 10                	mov    (%eax),%edx
  801e25:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e28:	89 08                	mov    %ecx,(%eax)
  801e2a:	8b 02                	mov    (%edx),%eax
  801e2c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e31:	c3                   	ret    

00801e32 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e32:	83 fa 01             	cmp    $0x1,%edx
  801e35:	7f 0f                	jg     801e46 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801e37:	85 d2                	test   %edx,%edx
  801e39:	74 18                	je     801e53 <getint+0x21>
		return va_arg(*ap, long);
  801e3b:	8b 10                	mov    (%eax),%edx
  801e3d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e40:	89 08                	mov    %ecx,(%eax)
  801e42:	8b 02                	mov    (%edx),%eax
  801e44:	99                   	cltd   
  801e45:	c3                   	ret    
		return va_arg(*ap, long long);
  801e46:	8b 10                	mov    (%eax),%edx
  801e48:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e4b:	89 08                	mov    %ecx,(%eax)
  801e4d:	8b 02                	mov    (%edx),%eax
  801e4f:	8b 52 04             	mov    0x4(%edx),%edx
  801e52:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801e53:	8b 10                	mov    (%eax),%edx
  801e55:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e58:	89 08                	mov    %ecx,(%eax)
  801e5a:	8b 02                	mov    (%edx),%eax
  801e5c:	99                   	cltd   
}
  801e5d:	c3                   	ret    

00801e5e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801e5e:	f3 0f 1e fb          	endbr32 
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801e68:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801e6c:	8b 10                	mov    (%eax),%edx
  801e6e:	3b 50 04             	cmp    0x4(%eax),%edx
  801e71:	73 0a                	jae    801e7d <sprintputch+0x1f>
		*b->buf++ = ch;
  801e73:	8d 4a 01             	lea    0x1(%edx),%ecx
  801e76:	89 08                	mov    %ecx,(%eax)
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	88 02                	mov    %al,(%edx)
}
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    

00801e7f <printfmt>:
{
  801e7f:	f3 0f 1e fb          	endbr32 
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801e89:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801e8c:	50                   	push   %eax
  801e8d:	ff 75 10             	pushl  0x10(%ebp)
  801e90:	ff 75 0c             	pushl  0xc(%ebp)
  801e93:	ff 75 08             	pushl  0x8(%ebp)
  801e96:	e8 05 00 00 00       	call   801ea0 <vprintfmt>
}
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <vprintfmt>:
{
  801ea0:	f3 0f 1e fb          	endbr32 
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	57                   	push   %edi
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
  801eaa:	83 ec 2c             	sub    $0x2c,%esp
  801ead:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801eb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb3:	8b 7d 10             	mov    0x10(%ebp),%edi
  801eb6:	e9 86 02 00 00       	jmp    802141 <vprintfmt+0x2a1>
		padc = ' ';
  801ebb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801ebf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801ec6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801ecd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801ed4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801ed9:	8d 47 01             	lea    0x1(%edi),%eax
  801edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801edf:	0f b6 17             	movzbl (%edi),%edx
  801ee2:	8d 42 dd             	lea    -0x23(%edx),%eax
  801ee5:	3c 55                	cmp    $0x55,%al
  801ee7:	0f 87 df 02 00 00    	ja     8021cc <vprintfmt+0x32c>
  801eed:	0f b6 c0             	movzbl %al,%eax
  801ef0:	3e ff 24 85 e0 40 80 	notrack jmp *0x8040e0(,%eax,4)
  801ef7:	00 
  801ef8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801efb:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801eff:	eb d8                	jmp    801ed9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801f01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f04:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801f08:	eb cf                	jmp    801ed9 <vprintfmt+0x39>
  801f0a:	0f b6 d2             	movzbl %dl,%edx
  801f0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
  801f15:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801f18:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801f1b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801f1f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801f22:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801f25:	83 f9 09             	cmp    $0x9,%ecx
  801f28:	77 52                	ja     801f7c <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801f2a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801f2d:	eb e9                	jmp    801f18 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801f2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f32:	8d 50 04             	lea    0x4(%eax),%edx
  801f35:	89 55 14             	mov    %edx,0x14(%ebp)
  801f38:	8b 00                	mov    (%eax),%eax
  801f3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801f3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801f40:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801f44:	79 93                	jns    801ed9 <vprintfmt+0x39>
				width = precision, precision = -1;
  801f46:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f4c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801f53:	eb 84                	jmp    801ed9 <vprintfmt+0x39>
  801f55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f5f:	0f 49 d0             	cmovns %eax,%edx
  801f62:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801f65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801f68:	e9 6c ff ff ff       	jmp    801ed9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801f6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801f70:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801f77:	e9 5d ff ff ff       	jmp    801ed9 <vprintfmt+0x39>
  801f7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f7f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801f82:	eb bc                	jmp    801f40 <vprintfmt+0xa0>
			lflag++;
  801f84:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801f87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801f8a:	e9 4a ff ff ff       	jmp    801ed9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801f8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f92:	8d 50 04             	lea    0x4(%eax),%edx
  801f95:	89 55 14             	mov    %edx,0x14(%ebp)
  801f98:	83 ec 08             	sub    $0x8,%esp
  801f9b:	56                   	push   %esi
  801f9c:	ff 30                	pushl  (%eax)
  801f9e:	ff d3                	call   *%ebx
			break;
  801fa0:	83 c4 10             	add    $0x10,%esp
  801fa3:	e9 96 01 00 00       	jmp    80213e <vprintfmt+0x29e>
			err = va_arg(ap, int);
  801fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  801fab:	8d 50 04             	lea    0x4(%eax),%edx
  801fae:	89 55 14             	mov    %edx,0x14(%ebp)
  801fb1:	8b 00                	mov    (%eax),%eax
  801fb3:	99                   	cltd   
  801fb4:	31 d0                	xor    %edx,%eax
  801fb6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801fb8:	83 f8 0f             	cmp    $0xf,%eax
  801fbb:	7f 20                	jg     801fdd <vprintfmt+0x13d>
  801fbd:	8b 14 85 40 42 80 00 	mov    0x804240(,%eax,4),%edx
  801fc4:	85 d2                	test   %edx,%edx
  801fc6:	74 15                	je     801fdd <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  801fc8:	52                   	push   %edx
  801fc9:	68 4f 3a 80 00       	push   $0x803a4f
  801fce:	56                   	push   %esi
  801fcf:	53                   	push   %ebx
  801fd0:	e8 aa fe ff ff       	call   801e7f <printfmt>
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	e9 61 01 00 00       	jmp    80213e <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801fdd:	50                   	push   %eax
  801fde:	68 c3 3f 80 00       	push   $0x803fc3
  801fe3:	56                   	push   %esi
  801fe4:	53                   	push   %ebx
  801fe5:	e8 95 fe ff ff       	call   801e7f <printfmt>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	e9 4c 01 00 00       	jmp    80213e <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801ff2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff5:	8d 50 04             	lea    0x4(%eax),%edx
  801ff8:	89 55 14             	mov    %edx,0x14(%ebp)
  801ffb:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801ffd:	85 c9                	test   %ecx,%ecx
  801fff:	b8 bc 3f 80 00       	mov    $0x803fbc,%eax
  802004:	0f 45 c1             	cmovne %ecx,%eax
  802007:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80200a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80200e:	7e 06                	jle    802016 <vprintfmt+0x176>
  802010:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  802014:	75 0d                	jne    802023 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  802016:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802019:	89 c7                	mov    %eax,%edi
  80201b:	03 45 e0             	add    -0x20(%ebp),%eax
  80201e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802021:	eb 57                	jmp    80207a <vprintfmt+0x1da>
  802023:	83 ec 08             	sub    $0x8,%esp
  802026:	ff 75 d8             	pushl  -0x28(%ebp)
  802029:	ff 75 cc             	pushl  -0x34(%ebp)
  80202c:	e8 4f 02 00 00       	call   802280 <strnlen>
  802031:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802034:	29 c2                	sub    %eax,%edx
  802036:	89 55 e0             	mov    %edx,-0x20(%ebp)
  802039:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80203c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  802040:	89 5d 08             	mov    %ebx,0x8(%ebp)
  802043:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  802045:	85 db                	test   %ebx,%ebx
  802047:	7e 10                	jle    802059 <vprintfmt+0x1b9>
					putch(padc, putdat);
  802049:	83 ec 08             	sub    $0x8,%esp
  80204c:	56                   	push   %esi
  80204d:	57                   	push   %edi
  80204e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	eb ec                	jmp    802045 <vprintfmt+0x1a5>
  802059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80205c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80205f:	85 d2                	test   %edx,%edx
  802061:	b8 00 00 00 00       	mov    $0x0,%eax
  802066:	0f 49 c2             	cmovns %edx,%eax
  802069:	29 c2                	sub    %eax,%edx
  80206b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80206e:	eb a6                	jmp    802016 <vprintfmt+0x176>
					putch(ch, putdat);
  802070:	83 ec 08             	sub    $0x8,%esp
  802073:	56                   	push   %esi
  802074:	52                   	push   %edx
  802075:	ff d3                	call   *%ebx
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80207d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80207f:	83 c7 01             	add    $0x1,%edi
  802082:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  802086:	0f be d0             	movsbl %al,%edx
  802089:	85 d2                	test   %edx,%edx
  80208b:	74 42                	je     8020cf <vprintfmt+0x22f>
  80208d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  802091:	78 06                	js     802099 <vprintfmt+0x1f9>
  802093:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  802097:	78 1e                	js     8020b7 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  802099:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80209d:	74 d1                	je     802070 <vprintfmt+0x1d0>
  80209f:	0f be c0             	movsbl %al,%eax
  8020a2:	83 e8 20             	sub    $0x20,%eax
  8020a5:	83 f8 5e             	cmp    $0x5e,%eax
  8020a8:	76 c6                	jbe    802070 <vprintfmt+0x1d0>
					putch('?', putdat);
  8020aa:	83 ec 08             	sub    $0x8,%esp
  8020ad:	56                   	push   %esi
  8020ae:	6a 3f                	push   $0x3f
  8020b0:	ff d3                	call   *%ebx
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	eb c3                	jmp    80207a <vprintfmt+0x1da>
  8020b7:	89 cf                	mov    %ecx,%edi
  8020b9:	eb 0e                	jmp    8020c9 <vprintfmt+0x229>
				putch(' ', putdat);
  8020bb:	83 ec 08             	sub    $0x8,%esp
  8020be:	56                   	push   %esi
  8020bf:	6a 20                	push   $0x20
  8020c1:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8020c3:	83 ef 01             	sub    $0x1,%edi
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	85 ff                	test   %edi,%edi
  8020cb:	7f ee                	jg     8020bb <vprintfmt+0x21b>
  8020cd:	eb 6f                	jmp    80213e <vprintfmt+0x29e>
  8020cf:	89 cf                	mov    %ecx,%edi
  8020d1:	eb f6                	jmp    8020c9 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8020d3:	89 ca                	mov    %ecx,%edx
  8020d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8020d8:	e8 55 fd ff ff       	call   801e32 <getint>
  8020dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8020e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8020e3:	85 d2                	test   %edx,%edx
  8020e5:	78 0b                	js     8020f2 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8020e7:	89 d1                	mov    %edx,%ecx
  8020e9:	89 c2                	mov    %eax,%edx
			base = 10;
  8020eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8020f0:	eb 32                	jmp    802124 <vprintfmt+0x284>
				putch('-', putdat);
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	56                   	push   %esi
  8020f6:	6a 2d                	push   $0x2d
  8020f8:	ff d3                	call   *%ebx
				num = -(long long) num;
  8020fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8020fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  802100:	f7 da                	neg    %edx
  802102:	83 d1 00             	adc    $0x0,%ecx
  802105:	f7 d9                	neg    %ecx
  802107:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80210a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80210f:	eb 13                	jmp    802124 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  802111:	89 ca                	mov    %ecx,%edx
  802113:	8d 45 14             	lea    0x14(%ebp),%eax
  802116:	e8 e3 fc ff ff       	call   801dfe <getuint>
  80211b:	89 d1                	mov    %edx,%ecx
  80211d:	89 c2                	mov    %eax,%edx
			base = 10;
  80211f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  802124:	83 ec 0c             	sub    $0xc,%esp
  802127:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80212b:	57                   	push   %edi
  80212c:	ff 75 e0             	pushl  -0x20(%ebp)
  80212f:	50                   	push   %eax
  802130:	51                   	push   %ecx
  802131:	52                   	push   %edx
  802132:	89 f2                	mov    %esi,%edx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	e8 1a fc ff ff       	call   801d55 <printnum>
			break;
  80213b:	83 c4 20             	add    $0x20,%esp
{
  80213e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802141:	83 c7 01             	add    $0x1,%edi
  802144:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  802148:	83 f8 25             	cmp    $0x25,%eax
  80214b:	0f 84 6a fd ff ff    	je     801ebb <vprintfmt+0x1b>
			if (ch == '\0')
  802151:	85 c0                	test   %eax,%eax
  802153:	0f 84 93 00 00 00    	je     8021ec <vprintfmt+0x34c>
			putch(ch, putdat);
  802159:	83 ec 08             	sub    $0x8,%esp
  80215c:	56                   	push   %esi
  80215d:	50                   	push   %eax
  80215e:	ff d3                	call   *%ebx
  802160:	83 c4 10             	add    $0x10,%esp
  802163:	eb dc                	jmp    802141 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  802165:	89 ca                	mov    %ecx,%edx
  802167:	8d 45 14             	lea    0x14(%ebp),%eax
  80216a:	e8 8f fc ff ff       	call   801dfe <getuint>
  80216f:	89 d1                	mov    %edx,%ecx
  802171:	89 c2                	mov    %eax,%edx
			base = 8;
  802173:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  802178:	eb aa                	jmp    802124 <vprintfmt+0x284>
			putch('0', putdat);
  80217a:	83 ec 08             	sub    $0x8,%esp
  80217d:	56                   	push   %esi
  80217e:	6a 30                	push   $0x30
  802180:	ff d3                	call   *%ebx
			putch('x', putdat);
  802182:	83 c4 08             	add    $0x8,%esp
  802185:	56                   	push   %esi
  802186:	6a 78                	push   $0x78
  802188:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80218a:	8b 45 14             	mov    0x14(%ebp),%eax
  80218d:	8d 50 04             	lea    0x4(%eax),%edx
  802190:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  802193:	8b 10                	mov    (%eax),%edx
  802195:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80219a:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80219d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8021a2:	eb 80                	jmp    802124 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8021a4:	89 ca                	mov    %ecx,%edx
  8021a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8021a9:	e8 50 fc ff ff       	call   801dfe <getuint>
  8021ae:	89 d1                	mov    %edx,%ecx
  8021b0:	89 c2                	mov    %eax,%edx
			base = 16;
  8021b2:	b8 10 00 00 00       	mov    $0x10,%eax
  8021b7:	e9 68 ff ff ff       	jmp    802124 <vprintfmt+0x284>
			putch(ch, putdat);
  8021bc:	83 ec 08             	sub    $0x8,%esp
  8021bf:	56                   	push   %esi
  8021c0:	6a 25                	push   $0x25
  8021c2:	ff d3                	call   *%ebx
			break;
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	e9 72 ff ff ff       	jmp    80213e <vprintfmt+0x29e>
			putch('%', putdat);
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	56                   	push   %esi
  8021d0:	6a 25                	push   $0x25
  8021d2:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	89 f8                	mov    %edi,%eax
  8021d9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8021dd:	74 05                	je     8021e4 <vprintfmt+0x344>
  8021df:	83 e8 01             	sub    $0x1,%eax
  8021e2:	eb f5                	jmp    8021d9 <vprintfmt+0x339>
  8021e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021e7:	e9 52 ff ff ff       	jmp    80213e <vprintfmt+0x29e>
}
  8021ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    

008021f4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8021f4:	f3 0f 1e fb          	endbr32 
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	83 ec 18             	sub    $0x18,%esp
  8021fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802201:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802204:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802207:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80220b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80220e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802215:	85 c0                	test   %eax,%eax
  802217:	74 26                	je     80223f <vsnprintf+0x4b>
  802219:	85 d2                	test   %edx,%edx
  80221b:	7e 22                	jle    80223f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80221d:	ff 75 14             	pushl  0x14(%ebp)
  802220:	ff 75 10             	pushl  0x10(%ebp)
  802223:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802226:	50                   	push   %eax
  802227:	68 5e 1e 80 00       	push   $0x801e5e
  80222c:	e8 6f fc ff ff       	call   801ea0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802231:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802234:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802237:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223a:	83 c4 10             	add    $0x10,%esp
}
  80223d:	c9                   	leave  
  80223e:	c3                   	ret    
		return -E_INVAL;
  80223f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802244:	eb f7                	jmp    80223d <vsnprintf+0x49>

00802246 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802246:	f3 0f 1e fb          	endbr32 
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802250:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802253:	50                   	push   %eax
  802254:	ff 75 10             	pushl  0x10(%ebp)
  802257:	ff 75 0c             	pushl  0xc(%ebp)
  80225a:	ff 75 08             	pushl  0x8(%ebp)
  80225d:	e8 92 ff ff ff       	call   8021f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  802262:	c9                   	leave  
  802263:	c3                   	ret    

00802264 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802264:	f3 0f 1e fb          	endbr32 
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80226e:	b8 00 00 00 00       	mov    $0x0,%eax
  802273:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802277:	74 05                	je     80227e <strlen+0x1a>
		n++;
  802279:	83 c0 01             	add    $0x1,%eax
  80227c:	eb f5                	jmp    802273 <strlen+0xf>
	return n;
}
  80227e:	5d                   	pop    %ebp
  80227f:	c3                   	ret    

00802280 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802280:	f3 0f 1e fb          	endbr32 
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80228a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80228d:	b8 00 00 00 00       	mov    $0x0,%eax
  802292:	39 d0                	cmp    %edx,%eax
  802294:	74 0d                	je     8022a3 <strnlen+0x23>
  802296:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80229a:	74 05                	je     8022a1 <strnlen+0x21>
		n++;
  80229c:	83 c0 01             	add    $0x1,%eax
  80229f:	eb f1                	jmp    802292 <strnlen+0x12>
  8022a1:	89 c2                	mov    %eax,%edx
	return n;
}
  8022a3:	89 d0                	mov    %edx,%eax
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    

008022a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8022a7:	f3 0f 1e fb          	endbr32 
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	53                   	push   %ebx
  8022af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ba:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8022be:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8022c1:	83 c0 01             	add    $0x1,%eax
  8022c4:	84 d2                	test   %dl,%dl
  8022c6:	75 f2                	jne    8022ba <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8022c8:	89 c8                	mov    %ecx,%eax
  8022ca:	5b                   	pop    %ebx
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    

008022cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8022cd:	f3 0f 1e fb          	endbr32 
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	53                   	push   %ebx
  8022d5:	83 ec 10             	sub    $0x10,%esp
  8022d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8022db:	53                   	push   %ebx
  8022dc:	e8 83 ff ff ff       	call   802264 <strlen>
  8022e1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8022e4:	ff 75 0c             	pushl  0xc(%ebp)
  8022e7:	01 d8                	add    %ebx,%eax
  8022e9:	50                   	push   %eax
  8022ea:	e8 b8 ff ff ff       	call   8022a7 <strcpy>
	return dst;
}
  8022ef:	89 d8                	mov    %ebx,%eax
  8022f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022f4:	c9                   	leave  
  8022f5:	c3                   	ret    

008022f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8022f6:	f3 0f 1e fb          	endbr32 
  8022fa:	55                   	push   %ebp
  8022fb:	89 e5                	mov    %esp,%ebp
  8022fd:	56                   	push   %esi
  8022fe:	53                   	push   %ebx
  8022ff:	8b 75 08             	mov    0x8(%ebp),%esi
  802302:	8b 55 0c             	mov    0xc(%ebp),%edx
  802305:	89 f3                	mov    %esi,%ebx
  802307:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80230a:	89 f0                	mov    %esi,%eax
  80230c:	39 d8                	cmp    %ebx,%eax
  80230e:	74 11                	je     802321 <strncpy+0x2b>
		*dst++ = *src;
  802310:	83 c0 01             	add    $0x1,%eax
  802313:	0f b6 0a             	movzbl (%edx),%ecx
  802316:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802319:	80 f9 01             	cmp    $0x1,%cl
  80231c:	83 da ff             	sbb    $0xffffffff,%edx
  80231f:	eb eb                	jmp    80230c <strncpy+0x16>
	}
	return ret;
}
  802321:	89 f0                	mov    %esi,%eax
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    

00802327 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802327:	f3 0f 1e fb          	endbr32 
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	56                   	push   %esi
  80232f:	53                   	push   %ebx
  802330:	8b 75 08             	mov    0x8(%ebp),%esi
  802333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802336:	8b 55 10             	mov    0x10(%ebp),%edx
  802339:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80233b:	85 d2                	test   %edx,%edx
  80233d:	74 21                	je     802360 <strlcpy+0x39>
  80233f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802343:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  802345:	39 c2                	cmp    %eax,%edx
  802347:	74 14                	je     80235d <strlcpy+0x36>
  802349:	0f b6 19             	movzbl (%ecx),%ebx
  80234c:	84 db                	test   %bl,%bl
  80234e:	74 0b                	je     80235b <strlcpy+0x34>
			*dst++ = *src++;
  802350:	83 c1 01             	add    $0x1,%ecx
  802353:	83 c2 01             	add    $0x1,%edx
  802356:	88 5a ff             	mov    %bl,-0x1(%edx)
  802359:	eb ea                	jmp    802345 <strlcpy+0x1e>
  80235b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80235d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802360:	29 f0                	sub    %esi,%eax
}
  802362:	5b                   	pop    %ebx
  802363:	5e                   	pop    %esi
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    

00802366 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802366:	f3 0f 1e fb          	endbr32 
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802370:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802373:	0f b6 01             	movzbl (%ecx),%eax
  802376:	84 c0                	test   %al,%al
  802378:	74 0c                	je     802386 <strcmp+0x20>
  80237a:	3a 02                	cmp    (%edx),%al
  80237c:	75 08                	jne    802386 <strcmp+0x20>
		p++, q++;
  80237e:	83 c1 01             	add    $0x1,%ecx
  802381:	83 c2 01             	add    $0x1,%edx
  802384:	eb ed                	jmp    802373 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802386:	0f b6 c0             	movzbl %al,%eax
  802389:	0f b6 12             	movzbl (%edx),%edx
  80238c:	29 d0                	sub    %edx,%eax
}
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802390:	f3 0f 1e fb          	endbr32 
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	53                   	push   %ebx
  802398:	8b 45 08             	mov    0x8(%ebp),%eax
  80239b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239e:	89 c3                	mov    %eax,%ebx
  8023a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8023a3:	eb 06                	jmp    8023ab <strncmp+0x1b>
		n--, p++, q++;
  8023a5:	83 c0 01             	add    $0x1,%eax
  8023a8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8023ab:	39 d8                	cmp    %ebx,%eax
  8023ad:	74 16                	je     8023c5 <strncmp+0x35>
  8023af:	0f b6 08             	movzbl (%eax),%ecx
  8023b2:	84 c9                	test   %cl,%cl
  8023b4:	74 04                	je     8023ba <strncmp+0x2a>
  8023b6:	3a 0a                	cmp    (%edx),%cl
  8023b8:	74 eb                	je     8023a5 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8023ba:	0f b6 00             	movzbl (%eax),%eax
  8023bd:	0f b6 12             	movzbl (%edx),%edx
  8023c0:	29 d0                	sub    %edx,%eax
}
  8023c2:	5b                   	pop    %ebx
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
		return 0;
  8023c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ca:	eb f6                	jmp    8023c2 <strncmp+0x32>

008023cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8023cc:	f3 0f 1e fb          	endbr32 
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8023da:	0f b6 10             	movzbl (%eax),%edx
  8023dd:	84 d2                	test   %dl,%dl
  8023df:	74 09                	je     8023ea <strchr+0x1e>
		if (*s == c)
  8023e1:	38 ca                	cmp    %cl,%dl
  8023e3:	74 0a                	je     8023ef <strchr+0x23>
	for (; *s; s++)
  8023e5:	83 c0 01             	add    $0x1,%eax
  8023e8:	eb f0                	jmp    8023da <strchr+0xe>
			return (char *) s;
	return 0;
  8023ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8023f1:	f3 0f 1e fb          	endbr32 
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8023ff:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802402:	38 ca                	cmp    %cl,%dl
  802404:	74 09                	je     80240f <strfind+0x1e>
  802406:	84 d2                	test   %dl,%dl
  802408:	74 05                	je     80240f <strfind+0x1e>
	for (; *s; s++)
  80240a:	83 c0 01             	add    $0x1,%eax
  80240d:	eb f0                	jmp    8023ff <strfind+0xe>
			break;
	return (char *) s;
}
  80240f:	5d                   	pop    %ebp
  802410:	c3                   	ret    

00802411 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802411:	f3 0f 1e fb          	endbr32 
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	57                   	push   %edi
  802419:	56                   	push   %esi
  80241a:	53                   	push   %ebx
  80241b:	8b 55 08             	mov    0x8(%ebp),%edx
  80241e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  802421:	85 c9                	test   %ecx,%ecx
  802423:	74 33                	je     802458 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802425:	89 d0                	mov    %edx,%eax
  802427:	09 c8                	or     %ecx,%eax
  802429:	a8 03                	test   $0x3,%al
  80242b:	75 23                	jne    802450 <memset+0x3f>
		c &= 0xFF;
  80242d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802431:	89 d8                	mov    %ebx,%eax
  802433:	c1 e0 08             	shl    $0x8,%eax
  802436:	89 df                	mov    %ebx,%edi
  802438:	c1 e7 18             	shl    $0x18,%edi
  80243b:	89 de                	mov    %ebx,%esi
  80243d:	c1 e6 10             	shl    $0x10,%esi
  802440:	09 f7                	or     %esi,%edi
  802442:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  802444:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802447:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  802449:	89 d7                	mov    %edx,%edi
  80244b:	fc                   	cld    
  80244c:	f3 ab                	rep stos %eax,%es:(%edi)
  80244e:	eb 08                	jmp    802458 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802450:	89 d7                	mov    %edx,%edi
  802452:	8b 45 0c             	mov    0xc(%ebp),%eax
  802455:	fc                   	cld    
  802456:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  802458:	89 d0                	mov    %edx,%eax
  80245a:	5b                   	pop    %ebx
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80245f:	f3 0f 1e fb          	endbr32 
  802463:	55                   	push   %ebp
  802464:	89 e5                	mov    %esp,%ebp
  802466:	57                   	push   %edi
  802467:	56                   	push   %esi
  802468:	8b 45 08             	mov    0x8(%ebp),%eax
  80246b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80246e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802471:	39 c6                	cmp    %eax,%esi
  802473:	73 32                	jae    8024a7 <memmove+0x48>
  802475:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802478:	39 c2                	cmp    %eax,%edx
  80247a:	76 2b                	jbe    8024a7 <memmove+0x48>
		s += n;
		d += n;
  80247c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80247f:	89 fe                	mov    %edi,%esi
  802481:	09 ce                	or     %ecx,%esi
  802483:	09 d6                	or     %edx,%esi
  802485:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80248b:	75 0e                	jne    80249b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80248d:	83 ef 04             	sub    $0x4,%edi
  802490:	8d 72 fc             	lea    -0x4(%edx),%esi
  802493:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  802496:	fd                   	std    
  802497:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802499:	eb 09                	jmp    8024a4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80249b:	83 ef 01             	sub    $0x1,%edi
  80249e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8024a1:	fd                   	std    
  8024a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8024a4:	fc                   	cld    
  8024a5:	eb 1a                	jmp    8024c1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024a7:	89 c2                	mov    %eax,%edx
  8024a9:	09 ca                	or     %ecx,%edx
  8024ab:	09 f2                	or     %esi,%edx
  8024ad:	f6 c2 03             	test   $0x3,%dl
  8024b0:	75 0a                	jne    8024bc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8024b2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8024b5:	89 c7                	mov    %eax,%edi
  8024b7:	fc                   	cld    
  8024b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024ba:	eb 05                	jmp    8024c1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8024bc:	89 c7                	mov    %eax,%edi
  8024be:	fc                   	cld    
  8024bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    

008024c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8024c5:	f3 0f 1e fb          	endbr32 
  8024c9:	55                   	push   %ebp
  8024ca:	89 e5                	mov    %esp,%ebp
  8024cc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8024cf:	ff 75 10             	pushl  0x10(%ebp)
  8024d2:	ff 75 0c             	pushl  0xc(%ebp)
  8024d5:	ff 75 08             	pushl  0x8(%ebp)
  8024d8:	e8 82 ff ff ff       	call   80245f <memmove>
}
  8024dd:	c9                   	leave  
  8024de:	c3                   	ret    

008024df <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8024df:	f3 0f 1e fb          	endbr32 
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ee:	89 c6                	mov    %eax,%esi
  8024f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8024f3:	39 f0                	cmp    %esi,%eax
  8024f5:	74 1c                	je     802513 <memcmp+0x34>
		if (*s1 != *s2)
  8024f7:	0f b6 08             	movzbl (%eax),%ecx
  8024fa:	0f b6 1a             	movzbl (%edx),%ebx
  8024fd:	38 d9                	cmp    %bl,%cl
  8024ff:	75 08                	jne    802509 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  802501:	83 c0 01             	add    $0x1,%eax
  802504:	83 c2 01             	add    $0x1,%edx
  802507:	eb ea                	jmp    8024f3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  802509:	0f b6 c1             	movzbl %cl,%eax
  80250c:	0f b6 db             	movzbl %bl,%ebx
  80250f:	29 d8                	sub    %ebx,%eax
  802511:	eb 05                	jmp    802518 <memcmp+0x39>
	}

	return 0;
  802513:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    

0080251c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80251c:	f3 0f 1e fb          	endbr32 
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	8b 45 08             	mov    0x8(%ebp),%eax
  802526:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802529:	89 c2                	mov    %eax,%edx
  80252b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80252e:	39 d0                	cmp    %edx,%eax
  802530:	73 09                	jae    80253b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  802532:	38 08                	cmp    %cl,(%eax)
  802534:	74 05                	je     80253b <memfind+0x1f>
	for (; s < ends; s++)
  802536:	83 c0 01             	add    $0x1,%eax
  802539:	eb f3                	jmp    80252e <memfind+0x12>
			break;
	return (void *) s;
}
  80253b:	5d                   	pop    %ebp
  80253c:	c3                   	ret    

0080253d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80253d:	f3 0f 1e fb          	endbr32 
  802541:	55                   	push   %ebp
  802542:	89 e5                	mov    %esp,%ebp
  802544:	57                   	push   %edi
  802545:	56                   	push   %esi
  802546:	53                   	push   %ebx
  802547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80254a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80254d:	eb 03                	jmp    802552 <strtol+0x15>
		s++;
  80254f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  802552:	0f b6 01             	movzbl (%ecx),%eax
  802555:	3c 20                	cmp    $0x20,%al
  802557:	74 f6                	je     80254f <strtol+0x12>
  802559:	3c 09                	cmp    $0x9,%al
  80255b:	74 f2                	je     80254f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80255d:	3c 2b                	cmp    $0x2b,%al
  80255f:	74 2a                	je     80258b <strtol+0x4e>
	int neg = 0;
  802561:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  802566:	3c 2d                	cmp    $0x2d,%al
  802568:	74 2b                	je     802595 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80256a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802570:	75 0f                	jne    802581 <strtol+0x44>
  802572:	80 39 30             	cmpb   $0x30,(%ecx)
  802575:	74 28                	je     80259f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802577:	85 db                	test   %ebx,%ebx
  802579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80257e:	0f 44 d8             	cmove  %eax,%ebx
  802581:	b8 00 00 00 00       	mov    $0x0,%eax
  802586:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802589:	eb 46                	jmp    8025d1 <strtol+0x94>
		s++;
  80258b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80258e:	bf 00 00 00 00       	mov    $0x0,%edi
  802593:	eb d5                	jmp    80256a <strtol+0x2d>
		s++, neg = 1;
  802595:	83 c1 01             	add    $0x1,%ecx
  802598:	bf 01 00 00 00       	mov    $0x1,%edi
  80259d:	eb cb                	jmp    80256a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80259f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8025a3:	74 0e                	je     8025b3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8025a5:	85 db                	test   %ebx,%ebx
  8025a7:	75 d8                	jne    802581 <strtol+0x44>
		s++, base = 8;
  8025a9:	83 c1 01             	add    $0x1,%ecx
  8025ac:	bb 08 00 00 00       	mov    $0x8,%ebx
  8025b1:	eb ce                	jmp    802581 <strtol+0x44>
		s += 2, base = 16;
  8025b3:	83 c1 02             	add    $0x2,%ecx
  8025b6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8025bb:	eb c4                	jmp    802581 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8025bd:	0f be d2             	movsbl %dl,%edx
  8025c0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8025c3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8025c6:	7d 3a                	jge    802602 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8025c8:	83 c1 01             	add    $0x1,%ecx
  8025cb:	0f af 45 10          	imul   0x10(%ebp),%eax
  8025cf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8025d1:	0f b6 11             	movzbl (%ecx),%edx
  8025d4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8025d7:	89 f3                	mov    %esi,%ebx
  8025d9:	80 fb 09             	cmp    $0x9,%bl
  8025dc:	76 df                	jbe    8025bd <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8025de:	8d 72 9f             	lea    -0x61(%edx),%esi
  8025e1:	89 f3                	mov    %esi,%ebx
  8025e3:	80 fb 19             	cmp    $0x19,%bl
  8025e6:	77 08                	ja     8025f0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8025e8:	0f be d2             	movsbl %dl,%edx
  8025eb:	83 ea 57             	sub    $0x57,%edx
  8025ee:	eb d3                	jmp    8025c3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8025f0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8025f3:	89 f3                	mov    %esi,%ebx
  8025f5:	80 fb 19             	cmp    $0x19,%bl
  8025f8:	77 08                	ja     802602 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8025fa:	0f be d2             	movsbl %dl,%edx
  8025fd:	83 ea 37             	sub    $0x37,%edx
  802600:	eb c1                	jmp    8025c3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  802602:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802606:	74 05                	je     80260d <strtol+0xd0>
		*endptr = (char *) s;
  802608:	8b 75 0c             	mov    0xc(%ebp),%esi
  80260b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80260d:	89 c2                	mov    %eax,%edx
  80260f:	f7 da                	neg    %edx
  802611:	85 ff                	test   %edi,%edi
  802613:	0f 45 c2             	cmovne %edx,%eax
}
  802616:	5b                   	pop    %ebx
  802617:	5e                   	pop    %esi
  802618:	5f                   	pop    %edi
  802619:	5d                   	pop    %ebp
  80261a:	c3                   	ret    

0080261b <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80261b:	55                   	push   %ebp
  80261c:	89 e5                	mov    %esp,%ebp
  80261e:	57                   	push   %edi
  80261f:	56                   	push   %esi
  802620:	53                   	push   %ebx
  802621:	83 ec 1c             	sub    $0x1c,%esp
  802624:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802627:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80262a:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80262c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802632:	8b 7d 10             	mov    0x10(%ebp),%edi
  802635:	8b 75 14             	mov    0x14(%ebp),%esi
  802638:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80263a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80263e:	74 04                	je     802644 <syscall+0x29>
  802640:	85 c0                	test   %eax,%eax
  802642:	7f 08                	jg     80264c <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  802644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80264c:	83 ec 0c             	sub    $0xc,%esp
  80264f:	50                   	push   %eax
  802650:	ff 75 e0             	pushl  -0x20(%ebp)
  802653:	68 9f 42 80 00       	push   $0x80429f
  802658:	6a 23                	push   $0x23
  80265a:	68 bc 42 80 00       	push   $0x8042bc
  80265f:	e8 f2 f5 ff ff       	call   801c56 <_panic>

00802664 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  802664:	f3 0f 1e fb          	endbr32 
  802668:	55                   	push   %ebp
  802669:	89 e5                	mov    %esp,%ebp
  80266b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80266e:	6a 00                	push   $0x0
  802670:	6a 00                	push   $0x0
  802672:	6a 00                	push   $0x0
  802674:	ff 75 0c             	pushl  0xc(%ebp)
  802677:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80267a:	ba 00 00 00 00       	mov    $0x0,%edx
  80267f:	b8 00 00 00 00       	mov    $0x0,%eax
  802684:	e8 92 ff ff ff       	call   80261b <syscall>
}
  802689:	83 c4 10             	add    $0x10,%esp
  80268c:	c9                   	leave  
  80268d:	c3                   	ret    

0080268e <sys_cgetc>:

int
sys_cgetc(void)
{
  80268e:	f3 0f 1e fb          	endbr32 
  802692:	55                   	push   %ebp
  802693:	89 e5                	mov    %esp,%ebp
  802695:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  802698:	6a 00                	push   $0x0
  80269a:	6a 00                	push   $0x0
  80269c:	6a 00                	push   $0x0
  80269e:	6a 00                	push   $0x0
  8026a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8026aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8026af:	e8 67 ff ff ff       	call   80261b <syscall>
}
  8026b4:	c9                   	leave  
  8026b5:	c3                   	ret    

008026b6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8026b6:	f3 0f 1e fb          	endbr32 
  8026ba:	55                   	push   %ebp
  8026bb:	89 e5                	mov    %esp,%ebp
  8026bd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8026c0:	6a 00                	push   $0x0
  8026c2:	6a 00                	push   $0x0
  8026c4:	6a 00                	push   $0x0
  8026c6:	6a 00                	push   $0x0
  8026c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8026d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8026d5:	e8 41 ff ff ff       	call   80261b <syscall>
}
  8026da:	c9                   	leave  
  8026db:	c3                   	ret    

008026dc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8026dc:	f3 0f 1e fb          	endbr32 
  8026e0:	55                   	push   %ebp
  8026e1:	89 e5                	mov    %esp,%ebp
  8026e3:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8026e6:	6a 00                	push   $0x0
  8026e8:	6a 00                	push   $0x0
  8026ea:	6a 00                	push   $0x0
  8026ec:	6a 00                	push   $0x0
  8026ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8026f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8026fd:	e8 19 ff ff ff       	call   80261b <syscall>
}
  802702:	c9                   	leave  
  802703:	c3                   	ret    

00802704 <sys_yield>:

void
sys_yield(void)
{
  802704:	f3 0f 1e fb          	endbr32 
  802708:	55                   	push   %ebp
  802709:	89 e5                	mov    %esp,%ebp
  80270b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80270e:	6a 00                	push   $0x0
  802710:	6a 00                	push   $0x0
  802712:	6a 00                	push   $0x0
  802714:	6a 00                	push   $0x0
  802716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80271b:	ba 00 00 00 00       	mov    $0x0,%edx
  802720:	b8 0b 00 00 00       	mov    $0xb,%eax
  802725:	e8 f1 fe ff ff       	call   80261b <syscall>
}
  80272a:	83 c4 10             	add    $0x10,%esp
  80272d:	c9                   	leave  
  80272e:	c3                   	ret    

0080272f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80272f:	f3 0f 1e fb          	endbr32 
  802733:	55                   	push   %ebp
  802734:	89 e5                	mov    %esp,%ebp
  802736:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  802739:	6a 00                	push   $0x0
  80273b:	6a 00                	push   $0x0
  80273d:	ff 75 10             	pushl  0x10(%ebp)
  802740:	ff 75 0c             	pushl  0xc(%ebp)
  802743:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802746:	ba 01 00 00 00       	mov    $0x1,%edx
  80274b:	b8 04 00 00 00       	mov    $0x4,%eax
  802750:	e8 c6 fe ff ff       	call   80261b <syscall>
}
  802755:	c9                   	leave  
  802756:	c3                   	ret    

00802757 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802757:	f3 0f 1e fb          	endbr32 
  80275b:	55                   	push   %ebp
  80275c:	89 e5                	mov    %esp,%ebp
  80275e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  802761:	ff 75 18             	pushl  0x18(%ebp)
  802764:	ff 75 14             	pushl  0x14(%ebp)
  802767:	ff 75 10             	pushl  0x10(%ebp)
  80276a:	ff 75 0c             	pushl  0xc(%ebp)
  80276d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802770:	ba 01 00 00 00       	mov    $0x1,%edx
  802775:	b8 05 00 00 00       	mov    $0x5,%eax
  80277a:	e8 9c fe ff ff       	call   80261b <syscall>
}
  80277f:	c9                   	leave  
  802780:	c3                   	ret    

00802781 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802781:	f3 0f 1e fb          	endbr32 
  802785:	55                   	push   %ebp
  802786:	89 e5                	mov    %esp,%ebp
  802788:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80278b:	6a 00                	push   $0x0
  80278d:	6a 00                	push   $0x0
  80278f:	6a 00                	push   $0x0
  802791:	ff 75 0c             	pushl  0xc(%ebp)
  802794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802797:	ba 01 00 00 00       	mov    $0x1,%edx
  80279c:	b8 06 00 00 00       	mov    $0x6,%eax
  8027a1:	e8 75 fe ff ff       	call   80261b <syscall>
}
  8027a6:	c9                   	leave  
  8027a7:	c3                   	ret    

008027a8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8027a8:	f3 0f 1e fb          	endbr32 
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8027b2:	6a 00                	push   $0x0
  8027b4:	6a 00                	push   $0x0
  8027b6:	6a 00                	push   $0x0
  8027b8:	ff 75 0c             	pushl  0xc(%ebp)
  8027bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027be:	ba 01 00 00 00       	mov    $0x1,%edx
  8027c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8027c8:	e8 4e fe ff ff       	call   80261b <syscall>
}
  8027cd:	c9                   	leave  
  8027ce:	c3                   	ret    

008027cf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8027cf:	f3 0f 1e fb          	endbr32 
  8027d3:	55                   	push   %ebp
  8027d4:	89 e5                	mov    %esp,%ebp
  8027d6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8027d9:	6a 00                	push   $0x0
  8027db:	6a 00                	push   $0x0
  8027dd:	6a 00                	push   $0x0
  8027df:	ff 75 0c             	pushl  0xc(%ebp)
  8027e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8027ea:	b8 09 00 00 00       	mov    $0x9,%eax
  8027ef:	e8 27 fe ff ff       	call   80261b <syscall>
}
  8027f4:	c9                   	leave  
  8027f5:	c3                   	ret    

008027f6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8027f6:	f3 0f 1e fb          	endbr32 
  8027fa:	55                   	push   %ebp
  8027fb:	89 e5                	mov    %esp,%ebp
  8027fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  802800:	6a 00                	push   $0x0
  802802:	6a 00                	push   $0x0
  802804:	6a 00                	push   $0x0
  802806:	ff 75 0c             	pushl  0xc(%ebp)
  802809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80280c:	ba 01 00 00 00       	mov    $0x1,%edx
  802811:	b8 0a 00 00 00       	mov    $0xa,%eax
  802816:	e8 00 fe ff ff       	call   80261b <syscall>
}
  80281b:	c9                   	leave  
  80281c:	c3                   	ret    

0080281d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80281d:	f3 0f 1e fb          	endbr32 
  802821:	55                   	push   %ebp
  802822:	89 e5                	mov    %esp,%ebp
  802824:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  802827:	6a 00                	push   $0x0
  802829:	ff 75 14             	pushl  0x14(%ebp)
  80282c:	ff 75 10             	pushl  0x10(%ebp)
  80282f:	ff 75 0c             	pushl  0xc(%ebp)
  802832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802835:	ba 00 00 00 00       	mov    $0x0,%edx
  80283a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80283f:	e8 d7 fd ff ff       	call   80261b <syscall>
}
  802844:	c9                   	leave  
  802845:	c3                   	ret    

00802846 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802846:	f3 0f 1e fb          	endbr32 
  80284a:	55                   	push   %ebp
  80284b:	89 e5                	mov    %esp,%ebp
  80284d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  802850:	6a 00                	push   $0x0
  802852:	6a 00                	push   $0x0
  802854:	6a 00                	push   $0x0
  802856:	6a 00                	push   $0x0
  802858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80285b:	ba 01 00 00 00       	mov    $0x1,%edx
  802860:	b8 0d 00 00 00       	mov    $0xd,%eax
  802865:	e8 b1 fd ff ff       	call   80261b <syscall>
}
  80286a:	c9                   	leave  
  80286b:	c3                   	ret    

0080286c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80286c:	f3 0f 1e fb          	endbr32 
  802870:	55                   	push   %ebp
  802871:	89 e5                	mov    %esp,%ebp
  802873:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802876:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  80287d:	74 1c                	je     80289b <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80287f:	8b 45 08             	mov    0x8(%ebp),%eax
  802882:	a3 10 a0 80 00       	mov    %eax,0x80a010

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802887:	83 ec 08             	sub    $0x8,%esp
  80288a:	68 c7 28 80 00       	push   $0x8028c7
  80288f:	6a 00                	push   $0x0
  802891:	e8 60 ff ff ff       	call   8027f6 <sys_env_set_pgfault_upcall>
}
  802896:	83 c4 10             	add    $0x10,%esp
  802899:	c9                   	leave  
  80289a:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  80289b:	83 ec 04             	sub    $0x4,%esp
  80289e:	6a 02                	push   $0x2
  8028a0:	68 00 f0 bf ee       	push   $0xeebff000
  8028a5:	6a 00                	push   $0x0
  8028a7:	e8 83 fe ff ff       	call   80272f <sys_page_alloc>
  8028ac:	83 c4 10             	add    $0x10,%esp
  8028af:	85 c0                	test   %eax,%eax
  8028b1:	79 cc                	jns    80287f <set_pgfault_handler+0x13>
  8028b3:	83 ec 04             	sub    $0x4,%esp
  8028b6:	68 ca 42 80 00       	push   $0x8042ca
  8028bb:	6a 20                	push   $0x20
  8028bd:	68 e5 42 80 00       	push   $0x8042e5
  8028c2:	e8 8f f3 ff ff       	call   801c56 <_panic>

008028c7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028c7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028c8:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8028cd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028cf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  8028d2:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  8028d6:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8028da:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  8028dd:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  8028df:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8028e3:	83 c4 08             	add    $0x8,%esp
	popal
  8028e6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8028e7:	83 c4 04             	add    $0x4,%esp
	popfl
  8028ea:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8028eb:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8028ee:	c3                   	ret    

008028ef <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028ef:	f3 0f 1e fb          	endbr32 
  8028f3:	55                   	push   %ebp
  8028f4:	89 e5                	mov    %esp,%ebp
  8028f6:	56                   	push   %esi
  8028f7:	53                   	push   %ebx
  8028f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8028fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  802901:	85 c0                	test   %eax,%eax
  802903:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802908:	0f 44 c2             	cmove  %edx,%eax
  80290b:	83 ec 0c             	sub    $0xc,%esp
  80290e:	50                   	push   %eax
  80290f:	e8 32 ff ff ff       	call   802846 <sys_ipc_recv>

	if (from_env_store != NULL)
  802914:	83 c4 10             	add    $0x10,%esp
  802917:	85 f6                	test   %esi,%esi
  802919:	74 15                	je     802930 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  80291b:	ba 00 00 00 00       	mov    $0x0,%edx
  802920:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802923:	74 09                	je     80292e <ipc_recv+0x3f>
  802925:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80292b:	8b 52 74             	mov    0x74(%edx),%edx
  80292e:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  802930:	85 db                	test   %ebx,%ebx
  802932:	74 15                	je     802949 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  802934:	ba 00 00 00 00       	mov    $0x0,%edx
  802939:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80293c:	74 09                	je     802947 <ipc_recv+0x58>
  80293e:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  802944:	8b 52 78             	mov    0x78(%edx),%edx
  802947:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  802949:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80294c:	74 08                	je     802956 <ipc_recv+0x67>
  80294e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802953:	8b 40 70             	mov    0x70(%eax),%eax
}
  802956:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802959:	5b                   	pop    %ebx
  80295a:	5e                   	pop    %esi
  80295b:	5d                   	pop    %ebp
  80295c:	c3                   	ret    

0080295d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80295d:	f3 0f 1e fb          	endbr32 
  802961:	55                   	push   %ebp
  802962:	89 e5                	mov    %esp,%ebp
  802964:	57                   	push   %edi
  802965:	56                   	push   %esi
  802966:	53                   	push   %ebx
  802967:	83 ec 0c             	sub    $0xc,%esp
  80296a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80296d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802970:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802973:	eb 1f                	jmp    802994 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802975:	6a 00                	push   $0x0
  802977:	68 00 00 c0 ee       	push   $0xeec00000
  80297c:	56                   	push   %esi
  80297d:	57                   	push   %edi
  80297e:	e8 9a fe ff ff       	call   80281d <sys_ipc_try_send>
  802983:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  802986:	85 c0                	test   %eax,%eax
  802988:	74 30                	je     8029ba <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  80298a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80298d:	75 19                	jne    8029a8 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  80298f:	e8 70 fd ff ff       	call   802704 <sys_yield>
		if (pg != NULL) {
  802994:	85 db                	test   %ebx,%ebx
  802996:	74 dd                	je     802975 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  802998:	ff 75 14             	pushl  0x14(%ebp)
  80299b:	53                   	push   %ebx
  80299c:	56                   	push   %esi
  80299d:	57                   	push   %edi
  80299e:	e8 7a fe ff ff       	call   80281d <sys_ipc_try_send>
  8029a3:	83 c4 10             	add    $0x10,%esp
  8029a6:	eb de                	jmp    802986 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  8029a8:	50                   	push   %eax
  8029a9:	68 f3 42 80 00       	push   $0x8042f3
  8029ae:	6a 3e                	push   $0x3e
  8029b0:	68 00 43 80 00       	push   $0x804300
  8029b5:	e8 9c f2 ff ff       	call   801c56 <_panic>
	}
}
  8029ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029bd:	5b                   	pop    %ebx
  8029be:	5e                   	pop    %esi
  8029bf:	5f                   	pop    %edi
  8029c0:	5d                   	pop    %ebp
  8029c1:	c3                   	ret    

008029c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029c2:	f3 0f 1e fb          	endbr32 
  8029c6:	55                   	push   %ebp
  8029c7:	89 e5                	mov    %esp,%ebp
  8029c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029d1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029d4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029da:	8b 52 50             	mov    0x50(%edx),%edx
  8029dd:	39 ca                	cmp    %ecx,%edx
  8029df:	74 11                	je     8029f2 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8029e1:	83 c0 01             	add    $0x1,%eax
  8029e4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029e9:	75 e6                	jne    8029d1 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8029eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8029f0:	eb 0b                	jmp    8029fd <ipc_find_env+0x3b>
			return envs[i].env_id;
  8029f2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029f5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029fa:	8b 40 48             	mov    0x48(%eax),%eax
}
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    

008029ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8029ff:	f3 0f 1e fb          	endbr32 
  802a03:	55                   	push   %ebp
  802a04:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a06:	8b 45 08             	mov    0x8(%ebp),%eax
  802a09:	05 00 00 00 30       	add    $0x30000000,%eax
  802a0e:	c1 e8 0c             	shr    $0xc,%eax
}
  802a11:	5d                   	pop    %ebp
  802a12:	c3                   	ret    

00802a13 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802a13:	f3 0f 1e fb          	endbr32 
  802a17:	55                   	push   %ebp
  802a18:	89 e5                	mov    %esp,%ebp
  802a1a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  802a1d:	ff 75 08             	pushl  0x8(%ebp)
  802a20:	e8 da ff ff ff       	call   8029ff <fd2num>
  802a25:	83 c4 10             	add    $0x10,%esp
  802a28:	c1 e0 0c             	shl    $0xc,%eax
  802a2b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802a30:	c9                   	leave  
  802a31:	c3                   	ret    

00802a32 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a32:	f3 0f 1e fb          	endbr32 
  802a36:	55                   	push   %ebp
  802a37:	89 e5                	mov    %esp,%ebp
  802a39:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a3e:	89 c2                	mov    %eax,%edx
  802a40:	c1 ea 16             	shr    $0x16,%edx
  802a43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a4a:	f6 c2 01             	test   $0x1,%dl
  802a4d:	74 2d                	je     802a7c <fd_alloc+0x4a>
  802a4f:	89 c2                	mov    %eax,%edx
  802a51:	c1 ea 0c             	shr    $0xc,%edx
  802a54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a5b:	f6 c2 01             	test   $0x1,%dl
  802a5e:	74 1c                	je     802a7c <fd_alloc+0x4a>
  802a60:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  802a65:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802a6a:	75 d2                	jne    802a3e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  802a75:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  802a7a:	eb 0a                	jmp    802a86 <fd_alloc+0x54>
			*fd_store = fd;
  802a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a7f:	89 01                	mov    %eax,(%ecx)
			return 0;
  802a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a86:	5d                   	pop    %ebp
  802a87:	c3                   	ret    

00802a88 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802a88:	f3 0f 1e fb          	endbr32 
  802a8c:	55                   	push   %ebp
  802a8d:	89 e5                	mov    %esp,%ebp
  802a8f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802a92:	83 f8 1f             	cmp    $0x1f,%eax
  802a95:	77 30                	ja     802ac7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802a97:	c1 e0 0c             	shl    $0xc,%eax
  802a9a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802a9f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  802aa5:	f6 c2 01             	test   $0x1,%dl
  802aa8:	74 24                	je     802ace <fd_lookup+0x46>
  802aaa:	89 c2                	mov    %eax,%edx
  802aac:	c1 ea 0c             	shr    $0xc,%edx
  802aaf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ab6:	f6 c2 01             	test   $0x1,%dl
  802ab9:	74 1a                	je     802ad5 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802abb:	8b 55 0c             	mov    0xc(%ebp),%edx
  802abe:	89 02                	mov    %eax,(%edx)
	return 0;
  802ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ac5:	5d                   	pop    %ebp
  802ac6:	c3                   	ret    
		return -E_INVAL;
  802ac7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802acc:	eb f7                	jmp    802ac5 <fd_lookup+0x3d>
		return -E_INVAL;
  802ace:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802ad3:	eb f0                	jmp    802ac5 <fd_lookup+0x3d>
  802ad5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802ada:	eb e9                	jmp    802ac5 <fd_lookup+0x3d>

00802adc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802adc:	f3 0f 1e fb          	endbr32 
  802ae0:	55                   	push   %ebp
  802ae1:	89 e5                	mov    %esp,%ebp
  802ae3:	83 ec 08             	sub    $0x8,%esp
  802ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ae9:	ba 88 43 80 00       	mov    $0x804388,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802aee:	b8 64 90 80 00       	mov    $0x809064,%eax
		if (devtab[i]->dev_id == dev_id) {
  802af3:	39 08                	cmp    %ecx,(%eax)
  802af5:	74 33                	je     802b2a <dev_lookup+0x4e>
  802af7:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  802afa:	8b 02                	mov    (%edx),%eax
  802afc:	85 c0                	test   %eax,%eax
  802afe:	75 f3                	jne    802af3 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802b00:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b05:	8b 40 48             	mov    0x48(%eax),%eax
  802b08:	83 ec 04             	sub    $0x4,%esp
  802b0b:	51                   	push   %ecx
  802b0c:	50                   	push   %eax
  802b0d:	68 0c 43 80 00       	push   $0x80430c
  802b12:	e8 26 f2 ff ff       	call   801d3d <cprintf>
	*dev = 0;
  802b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802b20:	83 c4 10             	add    $0x10,%esp
  802b23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802b28:	c9                   	leave  
  802b29:	c3                   	ret    
			*dev = devtab[i];
  802b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b2d:	89 01                	mov    %eax,(%ecx)
			return 0;
  802b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802b34:	eb f2                	jmp    802b28 <dev_lookup+0x4c>

00802b36 <fd_close>:
{
  802b36:	f3 0f 1e fb          	endbr32 
  802b3a:	55                   	push   %ebp
  802b3b:	89 e5                	mov    %esp,%ebp
  802b3d:	57                   	push   %edi
  802b3e:	56                   	push   %esi
  802b3f:	53                   	push   %ebx
  802b40:	83 ec 28             	sub    $0x28,%esp
  802b43:	8b 75 08             	mov    0x8(%ebp),%esi
  802b46:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b49:	56                   	push   %esi
  802b4a:	e8 b0 fe ff ff       	call   8029ff <fd2num>
  802b4f:	83 c4 08             	add    $0x8,%esp
  802b52:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  802b55:	52                   	push   %edx
  802b56:	50                   	push   %eax
  802b57:	e8 2c ff ff ff       	call   802a88 <fd_lookup>
  802b5c:	89 c3                	mov    %eax,%ebx
  802b5e:	83 c4 10             	add    $0x10,%esp
  802b61:	85 c0                	test   %eax,%eax
  802b63:	78 05                	js     802b6a <fd_close+0x34>
	    || fd != fd2)
  802b65:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802b68:	74 16                	je     802b80 <fd_close+0x4a>
		return (must_exist ? r : 0);
  802b6a:	89 f8                	mov    %edi,%eax
  802b6c:	84 c0                	test   %al,%al
  802b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  802b73:	0f 44 d8             	cmove  %eax,%ebx
}
  802b76:	89 d8                	mov    %ebx,%eax
  802b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b7b:	5b                   	pop    %ebx
  802b7c:	5e                   	pop    %esi
  802b7d:	5f                   	pop    %edi
  802b7e:	5d                   	pop    %ebp
  802b7f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802b80:	83 ec 08             	sub    $0x8,%esp
  802b83:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802b86:	50                   	push   %eax
  802b87:	ff 36                	pushl  (%esi)
  802b89:	e8 4e ff ff ff       	call   802adc <dev_lookup>
  802b8e:	89 c3                	mov    %eax,%ebx
  802b90:	83 c4 10             	add    $0x10,%esp
  802b93:	85 c0                	test   %eax,%eax
  802b95:	78 1a                	js     802bb1 <fd_close+0x7b>
		if (dev->dev_close)
  802b97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b9a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802ba2:	85 c0                	test   %eax,%eax
  802ba4:	74 0b                	je     802bb1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  802ba6:	83 ec 0c             	sub    $0xc,%esp
  802ba9:	56                   	push   %esi
  802baa:	ff d0                	call   *%eax
  802bac:	89 c3                	mov    %eax,%ebx
  802bae:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802bb1:	83 ec 08             	sub    $0x8,%esp
  802bb4:	56                   	push   %esi
  802bb5:	6a 00                	push   $0x0
  802bb7:	e8 c5 fb ff ff       	call   802781 <sys_page_unmap>
	return r;
  802bbc:	83 c4 10             	add    $0x10,%esp
  802bbf:	eb b5                	jmp    802b76 <fd_close+0x40>

00802bc1 <close>:

int
close(int fdnum)
{
  802bc1:	f3 0f 1e fb          	endbr32 
  802bc5:	55                   	push   %ebp
  802bc6:	89 e5                	mov    %esp,%ebp
  802bc8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bce:	50                   	push   %eax
  802bcf:	ff 75 08             	pushl  0x8(%ebp)
  802bd2:	e8 b1 fe ff ff       	call   802a88 <fd_lookup>
  802bd7:	83 c4 10             	add    $0x10,%esp
  802bda:	85 c0                	test   %eax,%eax
  802bdc:	79 02                	jns    802be0 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  802bde:	c9                   	leave  
  802bdf:	c3                   	ret    
		return fd_close(fd, 1);
  802be0:	83 ec 08             	sub    $0x8,%esp
  802be3:	6a 01                	push   $0x1
  802be5:	ff 75 f4             	pushl  -0xc(%ebp)
  802be8:	e8 49 ff ff ff       	call   802b36 <fd_close>
  802bed:	83 c4 10             	add    $0x10,%esp
  802bf0:	eb ec                	jmp    802bde <close+0x1d>

00802bf2 <close_all>:

void
close_all(void)
{
  802bf2:	f3 0f 1e fb          	endbr32 
  802bf6:	55                   	push   %ebp
  802bf7:	89 e5                	mov    %esp,%ebp
  802bf9:	53                   	push   %ebx
  802bfa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802c02:	83 ec 0c             	sub    $0xc,%esp
  802c05:	53                   	push   %ebx
  802c06:	e8 b6 ff ff ff       	call   802bc1 <close>
	for (i = 0; i < MAXFD; i++)
  802c0b:	83 c3 01             	add    $0x1,%ebx
  802c0e:	83 c4 10             	add    $0x10,%esp
  802c11:	83 fb 20             	cmp    $0x20,%ebx
  802c14:	75 ec                	jne    802c02 <close_all+0x10>
}
  802c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c19:	c9                   	leave  
  802c1a:	c3                   	ret    

00802c1b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802c1b:	f3 0f 1e fb          	endbr32 
  802c1f:	55                   	push   %ebp
  802c20:	89 e5                	mov    %esp,%ebp
  802c22:	57                   	push   %edi
  802c23:	56                   	push   %esi
  802c24:	53                   	push   %ebx
  802c25:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802c28:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c2b:	50                   	push   %eax
  802c2c:	ff 75 08             	pushl  0x8(%ebp)
  802c2f:	e8 54 fe ff ff       	call   802a88 <fd_lookup>
  802c34:	89 c3                	mov    %eax,%ebx
  802c36:	83 c4 10             	add    $0x10,%esp
  802c39:	85 c0                	test   %eax,%eax
  802c3b:	0f 88 81 00 00 00    	js     802cc2 <dup+0xa7>
		return r;
	close(newfdnum);
  802c41:	83 ec 0c             	sub    $0xc,%esp
  802c44:	ff 75 0c             	pushl  0xc(%ebp)
  802c47:	e8 75 ff ff ff       	call   802bc1 <close>

	newfd = INDEX2FD(newfdnum);
  802c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  802c4f:	c1 e6 0c             	shl    $0xc,%esi
  802c52:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802c58:	83 c4 04             	add    $0x4,%esp
  802c5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c5e:	e8 b0 fd ff ff       	call   802a13 <fd2data>
  802c63:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802c65:	89 34 24             	mov    %esi,(%esp)
  802c68:	e8 a6 fd ff ff       	call   802a13 <fd2data>
  802c6d:	83 c4 10             	add    $0x10,%esp
  802c70:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802c72:	89 d8                	mov    %ebx,%eax
  802c74:	c1 e8 16             	shr    $0x16,%eax
  802c77:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c7e:	a8 01                	test   $0x1,%al
  802c80:	74 11                	je     802c93 <dup+0x78>
  802c82:	89 d8                	mov    %ebx,%eax
  802c84:	c1 e8 0c             	shr    $0xc,%eax
  802c87:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c8e:	f6 c2 01             	test   $0x1,%dl
  802c91:	75 39                	jne    802ccc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802c93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802c96:	89 d0                	mov    %edx,%eax
  802c98:	c1 e8 0c             	shr    $0xc,%eax
  802c9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ca2:	83 ec 0c             	sub    $0xc,%esp
  802ca5:	25 07 0e 00 00       	and    $0xe07,%eax
  802caa:	50                   	push   %eax
  802cab:	56                   	push   %esi
  802cac:	6a 00                	push   $0x0
  802cae:	52                   	push   %edx
  802caf:	6a 00                	push   $0x0
  802cb1:	e8 a1 fa ff ff       	call   802757 <sys_page_map>
  802cb6:	89 c3                	mov    %eax,%ebx
  802cb8:	83 c4 20             	add    $0x20,%esp
  802cbb:	85 c0                	test   %eax,%eax
  802cbd:	78 31                	js     802cf0 <dup+0xd5>
		goto err;

	return newfdnum;
  802cbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802cc2:	89 d8                	mov    %ebx,%eax
  802cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cc7:	5b                   	pop    %ebx
  802cc8:	5e                   	pop    %esi
  802cc9:	5f                   	pop    %edi
  802cca:	5d                   	pop    %ebp
  802ccb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ccc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cd3:	83 ec 0c             	sub    $0xc,%esp
  802cd6:	25 07 0e 00 00       	and    $0xe07,%eax
  802cdb:	50                   	push   %eax
  802cdc:	57                   	push   %edi
  802cdd:	6a 00                	push   $0x0
  802cdf:	53                   	push   %ebx
  802ce0:	6a 00                	push   $0x0
  802ce2:	e8 70 fa ff ff       	call   802757 <sys_page_map>
  802ce7:	89 c3                	mov    %eax,%ebx
  802ce9:	83 c4 20             	add    $0x20,%esp
  802cec:	85 c0                	test   %eax,%eax
  802cee:	79 a3                	jns    802c93 <dup+0x78>
	sys_page_unmap(0, newfd);
  802cf0:	83 ec 08             	sub    $0x8,%esp
  802cf3:	56                   	push   %esi
  802cf4:	6a 00                	push   $0x0
  802cf6:	e8 86 fa ff ff       	call   802781 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802cfb:	83 c4 08             	add    $0x8,%esp
  802cfe:	57                   	push   %edi
  802cff:	6a 00                	push   $0x0
  802d01:	e8 7b fa ff ff       	call   802781 <sys_page_unmap>
	return r;
  802d06:	83 c4 10             	add    $0x10,%esp
  802d09:	eb b7                	jmp    802cc2 <dup+0xa7>

00802d0b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802d0b:	f3 0f 1e fb          	endbr32 
  802d0f:	55                   	push   %ebp
  802d10:	89 e5                	mov    %esp,%ebp
  802d12:	53                   	push   %ebx
  802d13:	83 ec 1c             	sub    $0x1c,%esp
  802d16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d1c:	50                   	push   %eax
  802d1d:	53                   	push   %ebx
  802d1e:	e8 65 fd ff ff       	call   802a88 <fd_lookup>
  802d23:	83 c4 10             	add    $0x10,%esp
  802d26:	85 c0                	test   %eax,%eax
  802d28:	78 3f                	js     802d69 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d2a:	83 ec 08             	sub    $0x8,%esp
  802d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d30:	50                   	push   %eax
  802d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d34:	ff 30                	pushl  (%eax)
  802d36:	e8 a1 fd ff ff       	call   802adc <dev_lookup>
  802d3b:	83 c4 10             	add    $0x10,%esp
  802d3e:	85 c0                	test   %eax,%eax
  802d40:	78 27                	js     802d69 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802d42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d45:	8b 42 08             	mov    0x8(%edx),%eax
  802d48:	83 e0 03             	and    $0x3,%eax
  802d4b:	83 f8 01             	cmp    $0x1,%eax
  802d4e:	74 1e                	je     802d6e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d53:	8b 40 08             	mov    0x8(%eax),%eax
  802d56:	85 c0                	test   %eax,%eax
  802d58:	74 35                	je     802d8f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802d5a:	83 ec 04             	sub    $0x4,%esp
  802d5d:	ff 75 10             	pushl  0x10(%ebp)
  802d60:	ff 75 0c             	pushl  0xc(%ebp)
  802d63:	52                   	push   %edx
  802d64:	ff d0                	call   *%eax
  802d66:	83 c4 10             	add    $0x10,%esp
}
  802d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d6c:	c9                   	leave  
  802d6d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802d6e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d73:	8b 40 48             	mov    0x48(%eax),%eax
  802d76:	83 ec 04             	sub    $0x4,%esp
  802d79:	53                   	push   %ebx
  802d7a:	50                   	push   %eax
  802d7b:	68 4d 43 80 00       	push   $0x80434d
  802d80:	e8 b8 ef ff ff       	call   801d3d <cprintf>
		return -E_INVAL;
  802d85:	83 c4 10             	add    $0x10,%esp
  802d88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d8d:	eb da                	jmp    802d69 <read+0x5e>
		return -E_NOT_SUPP;
  802d8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d94:	eb d3                	jmp    802d69 <read+0x5e>

00802d96 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802d96:	f3 0f 1e fb          	endbr32 
  802d9a:	55                   	push   %ebp
  802d9b:	89 e5                	mov    %esp,%ebp
  802d9d:	57                   	push   %edi
  802d9e:	56                   	push   %esi
  802d9f:	53                   	push   %ebx
  802da0:	83 ec 0c             	sub    $0xc,%esp
  802da3:	8b 7d 08             	mov    0x8(%ebp),%edi
  802da6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dae:	eb 02                	jmp    802db2 <readn+0x1c>
  802db0:	01 c3                	add    %eax,%ebx
  802db2:	39 f3                	cmp    %esi,%ebx
  802db4:	73 21                	jae    802dd7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802db6:	83 ec 04             	sub    $0x4,%esp
  802db9:	89 f0                	mov    %esi,%eax
  802dbb:	29 d8                	sub    %ebx,%eax
  802dbd:	50                   	push   %eax
  802dbe:	89 d8                	mov    %ebx,%eax
  802dc0:	03 45 0c             	add    0xc(%ebp),%eax
  802dc3:	50                   	push   %eax
  802dc4:	57                   	push   %edi
  802dc5:	e8 41 ff ff ff       	call   802d0b <read>
		if (m < 0)
  802dca:	83 c4 10             	add    $0x10,%esp
  802dcd:	85 c0                	test   %eax,%eax
  802dcf:	78 04                	js     802dd5 <readn+0x3f>
			return m;
		if (m == 0)
  802dd1:	75 dd                	jne    802db0 <readn+0x1a>
  802dd3:	eb 02                	jmp    802dd7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802dd5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802dd7:	89 d8                	mov    %ebx,%eax
  802dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ddc:	5b                   	pop    %ebx
  802ddd:	5e                   	pop    %esi
  802dde:	5f                   	pop    %edi
  802ddf:	5d                   	pop    %ebp
  802de0:	c3                   	ret    

00802de1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802de1:	f3 0f 1e fb          	endbr32 
  802de5:	55                   	push   %ebp
  802de6:	89 e5                	mov    %esp,%ebp
  802de8:	53                   	push   %ebx
  802de9:	83 ec 1c             	sub    $0x1c,%esp
  802dec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802def:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802df2:	50                   	push   %eax
  802df3:	53                   	push   %ebx
  802df4:	e8 8f fc ff ff       	call   802a88 <fd_lookup>
  802df9:	83 c4 10             	add    $0x10,%esp
  802dfc:	85 c0                	test   %eax,%eax
  802dfe:	78 3a                	js     802e3a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e00:	83 ec 08             	sub    $0x8,%esp
  802e03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e06:	50                   	push   %eax
  802e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e0a:	ff 30                	pushl  (%eax)
  802e0c:	e8 cb fc ff ff       	call   802adc <dev_lookup>
  802e11:	83 c4 10             	add    $0x10,%esp
  802e14:	85 c0                	test   %eax,%eax
  802e16:	78 22                	js     802e3a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e1b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e1f:	74 1e                	je     802e3f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e24:	8b 52 0c             	mov    0xc(%edx),%edx
  802e27:	85 d2                	test   %edx,%edx
  802e29:	74 35                	je     802e60 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802e2b:	83 ec 04             	sub    $0x4,%esp
  802e2e:	ff 75 10             	pushl  0x10(%ebp)
  802e31:	ff 75 0c             	pushl  0xc(%ebp)
  802e34:	50                   	push   %eax
  802e35:	ff d2                	call   *%edx
  802e37:	83 c4 10             	add    $0x10,%esp
}
  802e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e3d:	c9                   	leave  
  802e3e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802e3f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802e44:	8b 40 48             	mov    0x48(%eax),%eax
  802e47:	83 ec 04             	sub    $0x4,%esp
  802e4a:	53                   	push   %ebx
  802e4b:	50                   	push   %eax
  802e4c:	68 69 43 80 00       	push   $0x804369
  802e51:	e8 e7 ee ff ff       	call   801d3d <cprintf>
		return -E_INVAL;
  802e56:	83 c4 10             	add    $0x10,%esp
  802e59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e5e:	eb da                	jmp    802e3a <write+0x59>
		return -E_NOT_SUPP;
  802e60:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e65:	eb d3                	jmp    802e3a <write+0x59>

00802e67 <seek>:

int
seek(int fdnum, off_t offset)
{
  802e67:	f3 0f 1e fb          	endbr32 
  802e6b:	55                   	push   %ebp
  802e6c:	89 e5                	mov    %esp,%ebp
  802e6e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e74:	50                   	push   %eax
  802e75:	ff 75 08             	pushl  0x8(%ebp)
  802e78:	e8 0b fc ff ff       	call   802a88 <fd_lookup>
  802e7d:	83 c4 10             	add    $0x10,%esp
  802e80:	85 c0                	test   %eax,%eax
  802e82:	78 0e                	js     802e92 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  802e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e8a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e92:	c9                   	leave  
  802e93:	c3                   	ret    

00802e94 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802e94:	f3 0f 1e fb          	endbr32 
  802e98:	55                   	push   %ebp
  802e99:	89 e5                	mov    %esp,%ebp
  802e9b:	53                   	push   %ebx
  802e9c:	83 ec 1c             	sub    $0x1c,%esp
  802e9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ea2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ea5:	50                   	push   %eax
  802ea6:	53                   	push   %ebx
  802ea7:	e8 dc fb ff ff       	call   802a88 <fd_lookup>
  802eac:	83 c4 10             	add    $0x10,%esp
  802eaf:	85 c0                	test   %eax,%eax
  802eb1:	78 37                	js     802eea <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802eb3:	83 ec 08             	sub    $0x8,%esp
  802eb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802eb9:	50                   	push   %eax
  802eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ebd:	ff 30                	pushl  (%eax)
  802ebf:	e8 18 fc ff ff       	call   802adc <dev_lookup>
  802ec4:	83 c4 10             	add    $0x10,%esp
  802ec7:	85 c0                	test   %eax,%eax
  802ec9:	78 1f                	js     802eea <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ece:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ed2:	74 1b                	je     802eef <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802ed4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ed7:	8b 52 18             	mov    0x18(%edx),%edx
  802eda:	85 d2                	test   %edx,%edx
  802edc:	74 32                	je     802f10 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802ede:	83 ec 08             	sub    $0x8,%esp
  802ee1:	ff 75 0c             	pushl  0xc(%ebp)
  802ee4:	50                   	push   %eax
  802ee5:	ff d2                	call   *%edx
  802ee7:	83 c4 10             	add    $0x10,%esp
}
  802eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802eed:	c9                   	leave  
  802eee:	c3                   	ret    
			thisenv->env_id, fdnum);
  802eef:	a1 0c a0 80 00       	mov    0x80a00c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802ef4:	8b 40 48             	mov    0x48(%eax),%eax
  802ef7:	83 ec 04             	sub    $0x4,%esp
  802efa:	53                   	push   %ebx
  802efb:	50                   	push   %eax
  802efc:	68 2c 43 80 00       	push   $0x80432c
  802f01:	e8 37 ee ff ff       	call   801d3d <cprintf>
		return -E_INVAL;
  802f06:	83 c4 10             	add    $0x10,%esp
  802f09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802f0e:	eb da                	jmp    802eea <ftruncate+0x56>
		return -E_NOT_SUPP;
  802f10:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f15:	eb d3                	jmp    802eea <ftruncate+0x56>

00802f17 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802f17:	f3 0f 1e fb          	endbr32 
  802f1b:	55                   	push   %ebp
  802f1c:	89 e5                	mov    %esp,%ebp
  802f1e:	53                   	push   %ebx
  802f1f:	83 ec 1c             	sub    $0x1c,%esp
  802f22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f28:	50                   	push   %eax
  802f29:	ff 75 08             	pushl  0x8(%ebp)
  802f2c:	e8 57 fb ff ff       	call   802a88 <fd_lookup>
  802f31:	83 c4 10             	add    $0x10,%esp
  802f34:	85 c0                	test   %eax,%eax
  802f36:	78 4b                	js     802f83 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f38:	83 ec 08             	sub    $0x8,%esp
  802f3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f3e:	50                   	push   %eax
  802f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f42:	ff 30                	pushl  (%eax)
  802f44:	e8 93 fb ff ff       	call   802adc <dev_lookup>
  802f49:	83 c4 10             	add    $0x10,%esp
  802f4c:	85 c0                	test   %eax,%eax
  802f4e:	78 33                	js     802f83 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  802f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f53:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802f57:	74 2f                	je     802f88 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f59:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802f5c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802f63:	00 00 00 
	stat->st_isdir = 0;
  802f66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f6d:	00 00 00 
	stat->st_dev = dev;
  802f70:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802f76:	83 ec 08             	sub    $0x8,%esp
  802f79:	53                   	push   %ebx
  802f7a:	ff 75 f0             	pushl  -0x10(%ebp)
  802f7d:	ff 50 14             	call   *0x14(%eax)
  802f80:	83 c4 10             	add    $0x10,%esp
}
  802f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f86:	c9                   	leave  
  802f87:	c3                   	ret    
		return -E_NOT_SUPP;
  802f88:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f8d:	eb f4                	jmp    802f83 <fstat+0x6c>

00802f8f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802f8f:	f3 0f 1e fb          	endbr32 
  802f93:	55                   	push   %ebp
  802f94:	89 e5                	mov    %esp,%ebp
  802f96:	56                   	push   %esi
  802f97:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802f98:	83 ec 08             	sub    $0x8,%esp
  802f9b:	6a 00                	push   $0x0
  802f9d:	ff 75 08             	pushl  0x8(%ebp)
  802fa0:	e8 fb 01 00 00       	call   8031a0 <open>
  802fa5:	89 c3                	mov    %eax,%ebx
  802fa7:	83 c4 10             	add    $0x10,%esp
  802faa:	85 c0                	test   %eax,%eax
  802fac:	78 1b                	js     802fc9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  802fae:	83 ec 08             	sub    $0x8,%esp
  802fb1:	ff 75 0c             	pushl  0xc(%ebp)
  802fb4:	50                   	push   %eax
  802fb5:	e8 5d ff ff ff       	call   802f17 <fstat>
  802fba:	89 c6                	mov    %eax,%esi
	close(fd);
  802fbc:	89 1c 24             	mov    %ebx,(%esp)
  802fbf:	e8 fd fb ff ff       	call   802bc1 <close>
	return r;
  802fc4:	83 c4 10             	add    $0x10,%esp
  802fc7:	89 f3                	mov    %esi,%ebx
}
  802fc9:	89 d8                	mov    %ebx,%eax
  802fcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fce:	5b                   	pop    %ebx
  802fcf:	5e                   	pop    %esi
  802fd0:	5d                   	pop    %ebp
  802fd1:	c3                   	ret    

00802fd2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802fd2:	55                   	push   %ebp
  802fd3:	89 e5                	mov    %esp,%ebp
  802fd5:	56                   	push   %esi
  802fd6:	53                   	push   %ebx
  802fd7:	89 c6                	mov    %eax,%esi
  802fd9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802fdb:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802fe2:	74 27                	je     80300b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802fe4:	6a 07                	push   $0x7
  802fe6:	68 00 b0 80 00       	push   $0x80b000
  802feb:	56                   	push   %esi
  802fec:	ff 35 00 a0 80 00    	pushl  0x80a000
  802ff2:	e8 66 f9 ff ff       	call   80295d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802ff7:	83 c4 0c             	add    $0xc,%esp
  802ffa:	6a 00                	push   $0x0
  802ffc:	53                   	push   %ebx
  802ffd:	6a 00                	push   $0x0
  802fff:	e8 eb f8 ff ff       	call   8028ef <ipc_recv>
}
  803004:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803007:	5b                   	pop    %ebx
  803008:	5e                   	pop    %esi
  803009:	5d                   	pop    %ebp
  80300a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80300b:	83 ec 0c             	sub    $0xc,%esp
  80300e:	6a 01                	push   $0x1
  803010:	e8 ad f9 ff ff       	call   8029c2 <ipc_find_env>
  803015:	a3 00 a0 80 00       	mov    %eax,0x80a000
  80301a:	83 c4 10             	add    $0x10,%esp
  80301d:	eb c5                	jmp    802fe4 <fsipc+0x12>

0080301f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80301f:	f3 0f 1e fb          	endbr32 
  803023:	55                   	push   %ebp
  803024:	89 e5                	mov    %esp,%ebp
  803026:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  803029:	8b 45 08             	mov    0x8(%ebp),%eax
  80302c:	8b 40 0c             	mov    0xc(%eax),%eax
  80302f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  803034:	8b 45 0c             	mov    0xc(%ebp),%eax
  803037:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80303c:	ba 00 00 00 00       	mov    $0x0,%edx
  803041:	b8 02 00 00 00       	mov    $0x2,%eax
  803046:	e8 87 ff ff ff       	call   802fd2 <fsipc>
}
  80304b:	c9                   	leave  
  80304c:	c3                   	ret    

0080304d <devfile_flush>:
{
  80304d:	f3 0f 1e fb          	endbr32 
  803051:	55                   	push   %ebp
  803052:	89 e5                	mov    %esp,%ebp
  803054:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803057:	8b 45 08             	mov    0x8(%ebp),%eax
  80305a:	8b 40 0c             	mov    0xc(%eax),%eax
  80305d:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  803062:	ba 00 00 00 00       	mov    $0x0,%edx
  803067:	b8 06 00 00 00       	mov    $0x6,%eax
  80306c:	e8 61 ff ff ff       	call   802fd2 <fsipc>
}
  803071:	c9                   	leave  
  803072:	c3                   	ret    

00803073 <devfile_stat>:
{
  803073:	f3 0f 1e fb          	endbr32 
  803077:	55                   	push   %ebp
  803078:	89 e5                	mov    %esp,%ebp
  80307a:	53                   	push   %ebx
  80307b:	83 ec 04             	sub    $0x4,%esp
  80307e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803081:	8b 45 08             	mov    0x8(%ebp),%eax
  803084:	8b 40 0c             	mov    0xc(%eax),%eax
  803087:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80308c:	ba 00 00 00 00       	mov    $0x0,%edx
  803091:	b8 05 00 00 00       	mov    $0x5,%eax
  803096:	e8 37 ff ff ff       	call   802fd2 <fsipc>
  80309b:	85 c0                	test   %eax,%eax
  80309d:	78 2c                	js     8030cb <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80309f:	83 ec 08             	sub    $0x8,%esp
  8030a2:	68 00 b0 80 00       	push   $0x80b000
  8030a7:	53                   	push   %ebx
  8030a8:	e8 fa f1 ff ff       	call   8022a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8030ad:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8030b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8030b8:	a1 84 b0 80 00       	mov    0x80b084,%eax
  8030bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8030c3:	83 c4 10             	add    $0x10,%esp
  8030c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030ce:	c9                   	leave  
  8030cf:	c3                   	ret    

008030d0 <devfile_write>:
{
  8030d0:	f3 0f 1e fb          	endbr32 
  8030d4:	55                   	push   %ebp
  8030d5:	89 e5                	mov    %esp,%ebp
  8030d7:	83 ec 0c             	sub    $0xc,%esp
  8030da:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8030dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8030e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8030e3:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  8030e9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8030ee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8030f3:	0f 47 c2             	cmova  %edx,%eax
  8030f6:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8030fb:	50                   	push   %eax
  8030fc:	ff 75 0c             	pushl  0xc(%ebp)
  8030ff:	68 08 b0 80 00       	push   $0x80b008
  803104:	e8 56 f3 ff ff       	call   80245f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  803109:	ba 00 00 00 00       	mov    $0x0,%edx
  80310e:	b8 04 00 00 00       	mov    $0x4,%eax
  803113:	e8 ba fe ff ff       	call   802fd2 <fsipc>
}
  803118:	c9                   	leave  
  803119:	c3                   	ret    

0080311a <devfile_read>:
{
  80311a:	f3 0f 1e fb          	endbr32 
  80311e:	55                   	push   %ebp
  80311f:	89 e5                	mov    %esp,%ebp
  803121:	56                   	push   %esi
  803122:	53                   	push   %ebx
  803123:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  803126:	8b 45 08             	mov    0x8(%ebp),%eax
  803129:	8b 40 0c             	mov    0xc(%eax),%eax
  80312c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803131:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803137:	ba 00 00 00 00       	mov    $0x0,%edx
  80313c:	b8 03 00 00 00       	mov    $0x3,%eax
  803141:	e8 8c fe ff ff       	call   802fd2 <fsipc>
  803146:	89 c3                	mov    %eax,%ebx
  803148:	85 c0                	test   %eax,%eax
  80314a:	78 1f                	js     80316b <devfile_read+0x51>
	assert(r <= n);
  80314c:	39 f0                	cmp    %esi,%eax
  80314e:	77 24                	ja     803174 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  803150:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803155:	7f 33                	jg     80318a <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803157:	83 ec 04             	sub    $0x4,%esp
  80315a:	50                   	push   %eax
  80315b:	68 00 b0 80 00       	push   $0x80b000
  803160:	ff 75 0c             	pushl  0xc(%ebp)
  803163:	e8 f7 f2 ff ff       	call   80245f <memmove>
	return r;
  803168:	83 c4 10             	add    $0x10,%esp
}
  80316b:	89 d8                	mov    %ebx,%eax
  80316d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803170:	5b                   	pop    %ebx
  803171:	5e                   	pop    %esi
  803172:	5d                   	pop    %ebp
  803173:	c3                   	ret    
	assert(r <= n);
  803174:	68 98 43 80 00       	push   $0x804398
  803179:	68 3d 3a 80 00       	push   $0x803a3d
  80317e:	6a 7c                	push   $0x7c
  803180:	68 9f 43 80 00       	push   $0x80439f
  803185:	e8 cc ea ff ff       	call   801c56 <_panic>
	assert(r <= PGSIZE);
  80318a:	68 aa 43 80 00       	push   $0x8043aa
  80318f:	68 3d 3a 80 00       	push   $0x803a3d
  803194:	6a 7d                	push   $0x7d
  803196:	68 9f 43 80 00       	push   $0x80439f
  80319b:	e8 b6 ea ff ff       	call   801c56 <_panic>

008031a0 <open>:
{
  8031a0:	f3 0f 1e fb          	endbr32 
  8031a4:	55                   	push   %ebp
  8031a5:	89 e5                	mov    %esp,%ebp
  8031a7:	56                   	push   %esi
  8031a8:	53                   	push   %ebx
  8031a9:	83 ec 1c             	sub    $0x1c,%esp
  8031ac:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8031af:	56                   	push   %esi
  8031b0:	e8 af f0 ff ff       	call   802264 <strlen>
  8031b5:	83 c4 10             	add    $0x10,%esp
  8031b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8031bd:	7f 6c                	jg     80322b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8031bf:	83 ec 0c             	sub    $0xc,%esp
  8031c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031c5:	50                   	push   %eax
  8031c6:	e8 67 f8 ff ff       	call   802a32 <fd_alloc>
  8031cb:	89 c3                	mov    %eax,%ebx
  8031cd:	83 c4 10             	add    $0x10,%esp
  8031d0:	85 c0                	test   %eax,%eax
  8031d2:	78 3c                	js     803210 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8031d4:	83 ec 08             	sub    $0x8,%esp
  8031d7:	56                   	push   %esi
  8031d8:	68 00 b0 80 00       	push   $0x80b000
  8031dd:	e8 c5 f0 ff ff       	call   8022a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8031e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031e5:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8031ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8031f2:	e8 db fd ff ff       	call   802fd2 <fsipc>
  8031f7:	89 c3                	mov    %eax,%ebx
  8031f9:	83 c4 10             	add    $0x10,%esp
  8031fc:	85 c0                	test   %eax,%eax
  8031fe:	78 19                	js     803219 <open+0x79>
	return fd2num(fd);
  803200:	83 ec 0c             	sub    $0xc,%esp
  803203:	ff 75 f4             	pushl  -0xc(%ebp)
  803206:	e8 f4 f7 ff ff       	call   8029ff <fd2num>
  80320b:	89 c3                	mov    %eax,%ebx
  80320d:	83 c4 10             	add    $0x10,%esp
}
  803210:	89 d8                	mov    %ebx,%eax
  803212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803215:	5b                   	pop    %ebx
  803216:	5e                   	pop    %esi
  803217:	5d                   	pop    %ebp
  803218:	c3                   	ret    
		fd_close(fd, 0);
  803219:	83 ec 08             	sub    $0x8,%esp
  80321c:	6a 00                	push   $0x0
  80321e:	ff 75 f4             	pushl  -0xc(%ebp)
  803221:	e8 10 f9 ff ff       	call   802b36 <fd_close>
		return r;
  803226:	83 c4 10             	add    $0x10,%esp
  803229:	eb e5                	jmp    803210 <open+0x70>
		return -E_BAD_PATH;
  80322b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  803230:	eb de                	jmp    803210 <open+0x70>

00803232 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803232:	f3 0f 1e fb          	endbr32 
  803236:	55                   	push   %ebp
  803237:	89 e5                	mov    %esp,%ebp
  803239:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80323c:	ba 00 00 00 00       	mov    $0x0,%edx
  803241:	b8 08 00 00 00       	mov    $0x8,%eax
  803246:	e8 87 fd ff ff       	call   802fd2 <fsipc>
}
  80324b:	c9                   	leave  
  80324c:	c3                   	ret    

0080324d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80324d:	f3 0f 1e fb          	endbr32 
  803251:	55                   	push   %ebp
  803252:	89 e5                	mov    %esp,%ebp
  803254:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803257:	89 c2                	mov    %eax,%edx
  803259:	c1 ea 16             	shr    $0x16,%edx
  80325c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  803263:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  803268:	f6 c1 01             	test   $0x1,%cl
  80326b:	74 1c                	je     803289 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80326d:	c1 e8 0c             	shr    $0xc,%eax
  803270:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803277:	a8 01                	test   $0x1,%al
  803279:	74 0e                	je     803289 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80327b:	c1 e8 0c             	shr    $0xc,%eax
  80327e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  803285:	ef 
  803286:	0f b7 d2             	movzwl %dx,%edx
}
  803289:	89 d0                	mov    %edx,%eax
  80328b:	5d                   	pop    %ebp
  80328c:	c3                   	ret    

0080328d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80328d:	f3 0f 1e fb          	endbr32 
  803291:	55                   	push   %ebp
  803292:	89 e5                	mov    %esp,%ebp
  803294:	56                   	push   %esi
  803295:	53                   	push   %ebx
  803296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803299:	83 ec 0c             	sub    $0xc,%esp
  80329c:	ff 75 08             	pushl  0x8(%ebp)
  80329f:	e8 6f f7 ff ff       	call   802a13 <fd2data>
  8032a4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8032a6:	83 c4 08             	add    $0x8,%esp
  8032a9:	68 b6 43 80 00       	push   $0x8043b6
  8032ae:	53                   	push   %ebx
  8032af:	e8 f3 ef ff ff       	call   8022a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8032b4:	8b 46 04             	mov    0x4(%esi),%eax
  8032b7:	2b 06                	sub    (%esi),%eax
  8032b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8032bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8032c6:	00 00 00 
	stat->st_dev = &devpipe;
  8032c9:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8032d0:	90 80 00 
	return 0;
}
  8032d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8032d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032db:	5b                   	pop    %ebx
  8032dc:	5e                   	pop    %esi
  8032dd:	5d                   	pop    %ebp
  8032de:	c3                   	ret    

008032df <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8032df:	f3 0f 1e fb          	endbr32 
  8032e3:	55                   	push   %ebp
  8032e4:	89 e5                	mov    %esp,%ebp
  8032e6:	53                   	push   %ebx
  8032e7:	83 ec 0c             	sub    $0xc,%esp
  8032ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8032ed:	53                   	push   %ebx
  8032ee:	6a 00                	push   $0x0
  8032f0:	e8 8c f4 ff ff       	call   802781 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8032f5:	89 1c 24             	mov    %ebx,(%esp)
  8032f8:	e8 16 f7 ff ff       	call   802a13 <fd2data>
  8032fd:	83 c4 08             	add    $0x8,%esp
  803300:	50                   	push   %eax
  803301:	6a 00                	push   $0x0
  803303:	e8 79 f4 ff ff       	call   802781 <sys_page_unmap>
}
  803308:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80330b:	c9                   	leave  
  80330c:	c3                   	ret    

0080330d <_pipeisclosed>:
{
  80330d:	55                   	push   %ebp
  80330e:	89 e5                	mov    %esp,%ebp
  803310:	57                   	push   %edi
  803311:	56                   	push   %esi
  803312:	53                   	push   %ebx
  803313:	83 ec 1c             	sub    $0x1c,%esp
  803316:	89 c7                	mov    %eax,%edi
  803318:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80331a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80331f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803322:	83 ec 0c             	sub    $0xc,%esp
  803325:	57                   	push   %edi
  803326:	e8 22 ff ff ff       	call   80324d <pageref>
  80332b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80332e:	89 34 24             	mov    %esi,(%esp)
  803331:	e8 17 ff ff ff       	call   80324d <pageref>
		nn = thisenv->env_runs;
  803336:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80333c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80333f:	83 c4 10             	add    $0x10,%esp
  803342:	39 cb                	cmp    %ecx,%ebx
  803344:	74 1b                	je     803361 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  803346:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803349:	75 cf                	jne    80331a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80334b:	8b 42 58             	mov    0x58(%edx),%eax
  80334e:	6a 01                	push   $0x1
  803350:	50                   	push   %eax
  803351:	53                   	push   %ebx
  803352:	68 bd 43 80 00       	push   $0x8043bd
  803357:	e8 e1 e9 ff ff       	call   801d3d <cprintf>
  80335c:	83 c4 10             	add    $0x10,%esp
  80335f:	eb b9                	jmp    80331a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  803361:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803364:	0f 94 c0             	sete   %al
  803367:	0f b6 c0             	movzbl %al,%eax
}
  80336a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80336d:	5b                   	pop    %ebx
  80336e:	5e                   	pop    %esi
  80336f:	5f                   	pop    %edi
  803370:	5d                   	pop    %ebp
  803371:	c3                   	ret    

00803372 <devpipe_write>:
{
  803372:	f3 0f 1e fb          	endbr32 
  803376:	55                   	push   %ebp
  803377:	89 e5                	mov    %esp,%ebp
  803379:	57                   	push   %edi
  80337a:	56                   	push   %esi
  80337b:	53                   	push   %ebx
  80337c:	83 ec 28             	sub    $0x28,%esp
  80337f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803382:	56                   	push   %esi
  803383:	e8 8b f6 ff ff       	call   802a13 <fd2data>
  803388:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80338a:	83 c4 10             	add    $0x10,%esp
  80338d:	bf 00 00 00 00       	mov    $0x0,%edi
  803392:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803395:	74 4f                	je     8033e6 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803397:	8b 43 04             	mov    0x4(%ebx),%eax
  80339a:	8b 0b                	mov    (%ebx),%ecx
  80339c:	8d 51 20             	lea    0x20(%ecx),%edx
  80339f:	39 d0                	cmp    %edx,%eax
  8033a1:	72 14                	jb     8033b7 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8033a3:	89 da                	mov    %ebx,%edx
  8033a5:	89 f0                	mov    %esi,%eax
  8033a7:	e8 61 ff ff ff       	call   80330d <_pipeisclosed>
  8033ac:	85 c0                	test   %eax,%eax
  8033ae:	75 3b                	jne    8033eb <devpipe_write+0x79>
			sys_yield();
  8033b0:	e8 4f f3 ff ff       	call   802704 <sys_yield>
  8033b5:	eb e0                	jmp    803397 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8033b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8033ba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8033be:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8033c1:	89 c2                	mov    %eax,%edx
  8033c3:	c1 fa 1f             	sar    $0x1f,%edx
  8033c6:	89 d1                	mov    %edx,%ecx
  8033c8:	c1 e9 1b             	shr    $0x1b,%ecx
  8033cb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8033ce:	83 e2 1f             	and    $0x1f,%edx
  8033d1:	29 ca                	sub    %ecx,%edx
  8033d3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8033d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8033db:	83 c0 01             	add    $0x1,%eax
  8033de:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8033e1:	83 c7 01             	add    $0x1,%edi
  8033e4:	eb ac                	jmp    803392 <devpipe_write+0x20>
	return i;
  8033e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8033e9:	eb 05                	jmp    8033f0 <devpipe_write+0x7e>
				return 0;
  8033eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8033f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033f3:	5b                   	pop    %ebx
  8033f4:	5e                   	pop    %esi
  8033f5:	5f                   	pop    %edi
  8033f6:	5d                   	pop    %ebp
  8033f7:	c3                   	ret    

008033f8 <devpipe_read>:
{
  8033f8:	f3 0f 1e fb          	endbr32 
  8033fc:	55                   	push   %ebp
  8033fd:	89 e5                	mov    %esp,%ebp
  8033ff:	57                   	push   %edi
  803400:	56                   	push   %esi
  803401:	53                   	push   %ebx
  803402:	83 ec 18             	sub    $0x18,%esp
  803405:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803408:	57                   	push   %edi
  803409:	e8 05 f6 ff ff       	call   802a13 <fd2data>
  80340e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803410:	83 c4 10             	add    $0x10,%esp
  803413:	be 00 00 00 00       	mov    $0x0,%esi
  803418:	3b 75 10             	cmp    0x10(%ebp),%esi
  80341b:	75 14                	jne    803431 <devpipe_read+0x39>
	return i;
  80341d:	8b 45 10             	mov    0x10(%ebp),%eax
  803420:	eb 02                	jmp    803424 <devpipe_read+0x2c>
				return i;
  803422:	89 f0                	mov    %esi,%eax
}
  803424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803427:	5b                   	pop    %ebx
  803428:	5e                   	pop    %esi
  803429:	5f                   	pop    %edi
  80342a:	5d                   	pop    %ebp
  80342b:	c3                   	ret    
			sys_yield();
  80342c:	e8 d3 f2 ff ff       	call   802704 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  803431:	8b 03                	mov    (%ebx),%eax
  803433:	3b 43 04             	cmp    0x4(%ebx),%eax
  803436:	75 18                	jne    803450 <devpipe_read+0x58>
			if (i > 0)
  803438:	85 f6                	test   %esi,%esi
  80343a:	75 e6                	jne    803422 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80343c:	89 da                	mov    %ebx,%edx
  80343e:	89 f8                	mov    %edi,%eax
  803440:	e8 c8 fe ff ff       	call   80330d <_pipeisclosed>
  803445:	85 c0                	test   %eax,%eax
  803447:	74 e3                	je     80342c <devpipe_read+0x34>
				return 0;
  803449:	b8 00 00 00 00       	mov    $0x0,%eax
  80344e:	eb d4                	jmp    803424 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803450:	99                   	cltd   
  803451:	c1 ea 1b             	shr    $0x1b,%edx
  803454:	01 d0                	add    %edx,%eax
  803456:	83 e0 1f             	and    $0x1f,%eax
  803459:	29 d0                	sub    %edx,%eax
  80345b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803460:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803463:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803466:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  803469:	83 c6 01             	add    $0x1,%esi
  80346c:	eb aa                	jmp    803418 <devpipe_read+0x20>

0080346e <pipe>:
{
  80346e:	f3 0f 1e fb          	endbr32 
  803472:	55                   	push   %ebp
  803473:	89 e5                	mov    %esp,%ebp
  803475:	56                   	push   %esi
  803476:	53                   	push   %ebx
  803477:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80347a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80347d:	50                   	push   %eax
  80347e:	e8 af f5 ff ff       	call   802a32 <fd_alloc>
  803483:	89 c3                	mov    %eax,%ebx
  803485:	83 c4 10             	add    $0x10,%esp
  803488:	85 c0                	test   %eax,%eax
  80348a:	0f 88 23 01 00 00    	js     8035b3 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803490:	83 ec 04             	sub    $0x4,%esp
  803493:	68 07 04 00 00       	push   $0x407
  803498:	ff 75 f4             	pushl  -0xc(%ebp)
  80349b:	6a 00                	push   $0x0
  80349d:	e8 8d f2 ff ff       	call   80272f <sys_page_alloc>
  8034a2:	89 c3                	mov    %eax,%ebx
  8034a4:	83 c4 10             	add    $0x10,%esp
  8034a7:	85 c0                	test   %eax,%eax
  8034a9:	0f 88 04 01 00 00    	js     8035b3 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8034af:	83 ec 0c             	sub    $0xc,%esp
  8034b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8034b5:	50                   	push   %eax
  8034b6:	e8 77 f5 ff ff       	call   802a32 <fd_alloc>
  8034bb:	89 c3                	mov    %eax,%ebx
  8034bd:	83 c4 10             	add    $0x10,%esp
  8034c0:	85 c0                	test   %eax,%eax
  8034c2:	0f 88 db 00 00 00    	js     8035a3 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034c8:	83 ec 04             	sub    $0x4,%esp
  8034cb:	68 07 04 00 00       	push   $0x407
  8034d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8034d3:	6a 00                	push   $0x0
  8034d5:	e8 55 f2 ff ff       	call   80272f <sys_page_alloc>
  8034da:	89 c3                	mov    %eax,%ebx
  8034dc:	83 c4 10             	add    $0x10,%esp
  8034df:	85 c0                	test   %eax,%eax
  8034e1:	0f 88 bc 00 00 00    	js     8035a3 <pipe+0x135>
	va = fd2data(fd0);
  8034e7:	83 ec 0c             	sub    $0xc,%esp
  8034ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8034ed:	e8 21 f5 ff ff       	call   802a13 <fd2data>
  8034f2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034f4:	83 c4 0c             	add    $0xc,%esp
  8034f7:	68 07 04 00 00       	push   $0x407
  8034fc:	50                   	push   %eax
  8034fd:	6a 00                	push   $0x0
  8034ff:	e8 2b f2 ff ff       	call   80272f <sys_page_alloc>
  803504:	89 c3                	mov    %eax,%ebx
  803506:	83 c4 10             	add    $0x10,%esp
  803509:	85 c0                	test   %eax,%eax
  80350b:	0f 88 82 00 00 00    	js     803593 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803511:	83 ec 0c             	sub    $0xc,%esp
  803514:	ff 75 f0             	pushl  -0x10(%ebp)
  803517:	e8 f7 f4 ff ff       	call   802a13 <fd2data>
  80351c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803523:	50                   	push   %eax
  803524:	6a 00                	push   $0x0
  803526:	56                   	push   %esi
  803527:	6a 00                	push   $0x0
  803529:	e8 29 f2 ff ff       	call   802757 <sys_page_map>
  80352e:	89 c3                	mov    %eax,%ebx
  803530:	83 c4 20             	add    $0x20,%esp
  803533:	85 c0                	test   %eax,%eax
  803535:	78 4e                	js     803585 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  803537:	a1 80 90 80 00       	mov    0x809080,%eax
  80353c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80353f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  803541:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803544:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80354b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80354e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  803550:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803553:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80355a:	83 ec 0c             	sub    $0xc,%esp
  80355d:	ff 75 f4             	pushl  -0xc(%ebp)
  803560:	e8 9a f4 ff ff       	call   8029ff <fd2num>
  803565:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803568:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80356a:	83 c4 04             	add    $0x4,%esp
  80356d:	ff 75 f0             	pushl  -0x10(%ebp)
  803570:	e8 8a f4 ff ff       	call   8029ff <fd2num>
  803575:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803578:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80357b:	83 c4 10             	add    $0x10,%esp
  80357e:	bb 00 00 00 00       	mov    $0x0,%ebx
  803583:	eb 2e                	jmp    8035b3 <pipe+0x145>
	sys_page_unmap(0, va);
  803585:	83 ec 08             	sub    $0x8,%esp
  803588:	56                   	push   %esi
  803589:	6a 00                	push   $0x0
  80358b:	e8 f1 f1 ff ff       	call   802781 <sys_page_unmap>
  803590:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  803593:	83 ec 08             	sub    $0x8,%esp
  803596:	ff 75 f0             	pushl  -0x10(%ebp)
  803599:	6a 00                	push   $0x0
  80359b:	e8 e1 f1 ff ff       	call   802781 <sys_page_unmap>
  8035a0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8035a3:	83 ec 08             	sub    $0x8,%esp
  8035a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8035a9:	6a 00                	push   $0x0
  8035ab:	e8 d1 f1 ff ff       	call   802781 <sys_page_unmap>
  8035b0:	83 c4 10             	add    $0x10,%esp
}
  8035b3:	89 d8                	mov    %ebx,%eax
  8035b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8035b8:	5b                   	pop    %ebx
  8035b9:	5e                   	pop    %esi
  8035ba:	5d                   	pop    %ebp
  8035bb:	c3                   	ret    

008035bc <pipeisclosed>:
{
  8035bc:	f3 0f 1e fb          	endbr32 
  8035c0:	55                   	push   %ebp
  8035c1:	89 e5                	mov    %esp,%ebp
  8035c3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035c9:	50                   	push   %eax
  8035ca:	ff 75 08             	pushl  0x8(%ebp)
  8035cd:	e8 b6 f4 ff ff       	call   802a88 <fd_lookup>
  8035d2:	83 c4 10             	add    $0x10,%esp
  8035d5:	85 c0                	test   %eax,%eax
  8035d7:	78 18                	js     8035f1 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8035d9:	83 ec 0c             	sub    $0xc,%esp
  8035dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8035df:	e8 2f f4 ff ff       	call   802a13 <fd2data>
  8035e4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8035e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e9:	e8 1f fd ff ff       	call   80330d <_pipeisclosed>
  8035ee:	83 c4 10             	add    $0x10,%esp
}
  8035f1:	c9                   	leave  
  8035f2:	c3                   	ret    

008035f3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8035f3:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8035f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8035fc:	c3                   	ret    

008035fd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8035fd:	f3 0f 1e fb          	endbr32 
  803601:	55                   	push   %ebp
  803602:	89 e5                	mov    %esp,%ebp
  803604:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803607:	68 d5 43 80 00       	push   $0x8043d5
  80360c:	ff 75 0c             	pushl  0xc(%ebp)
  80360f:	e8 93 ec ff ff       	call   8022a7 <strcpy>
	return 0;
}
  803614:	b8 00 00 00 00       	mov    $0x0,%eax
  803619:	c9                   	leave  
  80361a:	c3                   	ret    

0080361b <devcons_write>:
{
  80361b:	f3 0f 1e fb          	endbr32 
  80361f:	55                   	push   %ebp
  803620:	89 e5                	mov    %esp,%ebp
  803622:	57                   	push   %edi
  803623:	56                   	push   %esi
  803624:	53                   	push   %ebx
  803625:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80362b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803630:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  803636:	3b 75 10             	cmp    0x10(%ebp),%esi
  803639:	73 31                	jae    80366c <devcons_write+0x51>
		m = n - tot;
  80363b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80363e:	29 f3                	sub    %esi,%ebx
  803640:	83 fb 7f             	cmp    $0x7f,%ebx
  803643:	b8 7f 00 00 00       	mov    $0x7f,%eax
  803648:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80364b:	83 ec 04             	sub    $0x4,%esp
  80364e:	53                   	push   %ebx
  80364f:	89 f0                	mov    %esi,%eax
  803651:	03 45 0c             	add    0xc(%ebp),%eax
  803654:	50                   	push   %eax
  803655:	57                   	push   %edi
  803656:	e8 04 ee ff ff       	call   80245f <memmove>
		sys_cputs(buf, m);
  80365b:	83 c4 08             	add    $0x8,%esp
  80365e:	53                   	push   %ebx
  80365f:	57                   	push   %edi
  803660:	e8 ff ef ff ff       	call   802664 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  803665:	01 de                	add    %ebx,%esi
  803667:	83 c4 10             	add    $0x10,%esp
  80366a:	eb ca                	jmp    803636 <devcons_write+0x1b>
}
  80366c:	89 f0                	mov    %esi,%eax
  80366e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803671:	5b                   	pop    %ebx
  803672:	5e                   	pop    %esi
  803673:	5f                   	pop    %edi
  803674:	5d                   	pop    %ebp
  803675:	c3                   	ret    

00803676 <devcons_read>:
{
  803676:	f3 0f 1e fb          	endbr32 
  80367a:	55                   	push   %ebp
  80367b:	89 e5                	mov    %esp,%ebp
  80367d:	83 ec 08             	sub    $0x8,%esp
  803680:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  803685:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803689:	74 21                	je     8036ac <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80368b:	e8 fe ef ff ff       	call   80268e <sys_cgetc>
  803690:	85 c0                	test   %eax,%eax
  803692:	75 07                	jne    80369b <devcons_read+0x25>
		sys_yield();
  803694:	e8 6b f0 ff ff       	call   802704 <sys_yield>
  803699:	eb f0                	jmp    80368b <devcons_read+0x15>
	if (c < 0)
  80369b:	78 0f                	js     8036ac <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80369d:	83 f8 04             	cmp    $0x4,%eax
  8036a0:	74 0c                	je     8036ae <devcons_read+0x38>
	*(char*)vbuf = c;
  8036a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8036a5:	88 02                	mov    %al,(%edx)
	return 1;
  8036a7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8036ac:	c9                   	leave  
  8036ad:	c3                   	ret    
		return 0;
  8036ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8036b3:	eb f7                	jmp    8036ac <devcons_read+0x36>

008036b5 <cputchar>:
{
  8036b5:	f3 0f 1e fb          	endbr32 
  8036b9:	55                   	push   %ebp
  8036ba:	89 e5                	mov    %esp,%ebp
  8036bc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8036bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8036c2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8036c5:	6a 01                	push   $0x1
  8036c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036ca:	50                   	push   %eax
  8036cb:	e8 94 ef ff ff       	call   802664 <sys_cputs>
}
  8036d0:	83 c4 10             	add    $0x10,%esp
  8036d3:	c9                   	leave  
  8036d4:	c3                   	ret    

008036d5 <getchar>:
{
  8036d5:	f3 0f 1e fb          	endbr32 
  8036d9:	55                   	push   %ebp
  8036da:	89 e5                	mov    %esp,%ebp
  8036dc:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8036df:	6a 01                	push   $0x1
  8036e1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036e4:	50                   	push   %eax
  8036e5:	6a 00                	push   $0x0
  8036e7:	e8 1f f6 ff ff       	call   802d0b <read>
	if (r < 0)
  8036ec:	83 c4 10             	add    $0x10,%esp
  8036ef:	85 c0                	test   %eax,%eax
  8036f1:	78 06                	js     8036f9 <getchar+0x24>
	if (r < 1)
  8036f3:	74 06                	je     8036fb <getchar+0x26>
	return c;
  8036f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8036f9:	c9                   	leave  
  8036fa:	c3                   	ret    
		return -E_EOF;
  8036fb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  803700:	eb f7                	jmp    8036f9 <getchar+0x24>

00803702 <iscons>:
{
  803702:	f3 0f 1e fb          	endbr32 
  803706:	55                   	push   %ebp
  803707:	89 e5                	mov    %esp,%ebp
  803709:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80370c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80370f:	50                   	push   %eax
  803710:	ff 75 08             	pushl  0x8(%ebp)
  803713:	e8 70 f3 ff ff       	call   802a88 <fd_lookup>
  803718:	83 c4 10             	add    $0x10,%esp
  80371b:	85 c0                	test   %eax,%eax
  80371d:	78 11                	js     803730 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80371f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803722:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803728:	39 10                	cmp    %edx,(%eax)
  80372a:	0f 94 c0             	sete   %al
  80372d:	0f b6 c0             	movzbl %al,%eax
}
  803730:	c9                   	leave  
  803731:	c3                   	ret    

00803732 <opencons>:
{
  803732:	f3 0f 1e fb          	endbr32 
  803736:	55                   	push   %ebp
  803737:	89 e5                	mov    %esp,%ebp
  803739:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80373c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80373f:	50                   	push   %eax
  803740:	e8 ed f2 ff ff       	call   802a32 <fd_alloc>
  803745:	83 c4 10             	add    $0x10,%esp
  803748:	85 c0                	test   %eax,%eax
  80374a:	78 3a                	js     803786 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80374c:	83 ec 04             	sub    $0x4,%esp
  80374f:	68 07 04 00 00       	push   $0x407
  803754:	ff 75 f4             	pushl  -0xc(%ebp)
  803757:	6a 00                	push   $0x0
  803759:	e8 d1 ef ff ff       	call   80272f <sys_page_alloc>
  80375e:	83 c4 10             	add    $0x10,%esp
  803761:	85 c0                	test   %eax,%eax
  803763:	78 21                	js     803786 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  803765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803768:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80376e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803773:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80377a:	83 ec 0c             	sub    $0xc,%esp
  80377d:	50                   	push   %eax
  80377e:	e8 7c f2 ff ff       	call   8029ff <fd2num>
  803783:	83 c4 10             	add    $0x10,%esp
}
  803786:	c9                   	leave  
  803787:	c3                   	ret    
  803788:	66 90                	xchg   %ax,%ax
  80378a:	66 90                	xchg   %ax,%ax
  80378c:	66 90                	xchg   %ax,%ax
  80378e:	66 90                	xchg   %ax,%ax

00803790 <__udivdi3>:
  803790:	f3 0f 1e fb          	endbr32 
  803794:	55                   	push   %ebp
  803795:	57                   	push   %edi
  803796:	56                   	push   %esi
  803797:	53                   	push   %ebx
  803798:	83 ec 1c             	sub    $0x1c,%esp
  80379b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80379f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8037a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8037a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8037ab:	85 d2                	test   %edx,%edx
  8037ad:	75 19                	jne    8037c8 <__udivdi3+0x38>
  8037af:	39 f3                	cmp    %esi,%ebx
  8037b1:	76 4d                	jbe    803800 <__udivdi3+0x70>
  8037b3:	31 ff                	xor    %edi,%edi
  8037b5:	89 e8                	mov    %ebp,%eax
  8037b7:	89 f2                	mov    %esi,%edx
  8037b9:	f7 f3                	div    %ebx
  8037bb:	89 fa                	mov    %edi,%edx
  8037bd:	83 c4 1c             	add    $0x1c,%esp
  8037c0:	5b                   	pop    %ebx
  8037c1:	5e                   	pop    %esi
  8037c2:	5f                   	pop    %edi
  8037c3:	5d                   	pop    %ebp
  8037c4:	c3                   	ret    
  8037c5:	8d 76 00             	lea    0x0(%esi),%esi
  8037c8:	39 f2                	cmp    %esi,%edx
  8037ca:	76 14                	jbe    8037e0 <__udivdi3+0x50>
  8037cc:	31 ff                	xor    %edi,%edi
  8037ce:	31 c0                	xor    %eax,%eax
  8037d0:	89 fa                	mov    %edi,%edx
  8037d2:	83 c4 1c             	add    $0x1c,%esp
  8037d5:	5b                   	pop    %ebx
  8037d6:	5e                   	pop    %esi
  8037d7:	5f                   	pop    %edi
  8037d8:	5d                   	pop    %ebp
  8037d9:	c3                   	ret    
  8037da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8037e0:	0f bd fa             	bsr    %edx,%edi
  8037e3:	83 f7 1f             	xor    $0x1f,%edi
  8037e6:	75 48                	jne    803830 <__udivdi3+0xa0>
  8037e8:	39 f2                	cmp    %esi,%edx
  8037ea:	72 06                	jb     8037f2 <__udivdi3+0x62>
  8037ec:	31 c0                	xor    %eax,%eax
  8037ee:	39 eb                	cmp    %ebp,%ebx
  8037f0:	77 de                	ja     8037d0 <__udivdi3+0x40>
  8037f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8037f7:	eb d7                	jmp    8037d0 <__udivdi3+0x40>
  8037f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803800:	89 d9                	mov    %ebx,%ecx
  803802:	85 db                	test   %ebx,%ebx
  803804:	75 0b                	jne    803811 <__udivdi3+0x81>
  803806:	b8 01 00 00 00       	mov    $0x1,%eax
  80380b:	31 d2                	xor    %edx,%edx
  80380d:	f7 f3                	div    %ebx
  80380f:	89 c1                	mov    %eax,%ecx
  803811:	31 d2                	xor    %edx,%edx
  803813:	89 f0                	mov    %esi,%eax
  803815:	f7 f1                	div    %ecx
  803817:	89 c6                	mov    %eax,%esi
  803819:	89 e8                	mov    %ebp,%eax
  80381b:	89 f7                	mov    %esi,%edi
  80381d:	f7 f1                	div    %ecx
  80381f:	89 fa                	mov    %edi,%edx
  803821:	83 c4 1c             	add    $0x1c,%esp
  803824:	5b                   	pop    %ebx
  803825:	5e                   	pop    %esi
  803826:	5f                   	pop    %edi
  803827:	5d                   	pop    %ebp
  803828:	c3                   	ret    
  803829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803830:	89 f9                	mov    %edi,%ecx
  803832:	b8 20 00 00 00       	mov    $0x20,%eax
  803837:	29 f8                	sub    %edi,%eax
  803839:	d3 e2                	shl    %cl,%edx
  80383b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80383f:	89 c1                	mov    %eax,%ecx
  803841:	89 da                	mov    %ebx,%edx
  803843:	d3 ea                	shr    %cl,%edx
  803845:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803849:	09 d1                	or     %edx,%ecx
  80384b:	89 f2                	mov    %esi,%edx
  80384d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803851:	89 f9                	mov    %edi,%ecx
  803853:	d3 e3                	shl    %cl,%ebx
  803855:	89 c1                	mov    %eax,%ecx
  803857:	d3 ea                	shr    %cl,%edx
  803859:	89 f9                	mov    %edi,%ecx
  80385b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80385f:	89 eb                	mov    %ebp,%ebx
  803861:	d3 e6                	shl    %cl,%esi
  803863:	89 c1                	mov    %eax,%ecx
  803865:	d3 eb                	shr    %cl,%ebx
  803867:	09 de                	or     %ebx,%esi
  803869:	89 f0                	mov    %esi,%eax
  80386b:	f7 74 24 08          	divl   0x8(%esp)
  80386f:	89 d6                	mov    %edx,%esi
  803871:	89 c3                	mov    %eax,%ebx
  803873:	f7 64 24 0c          	mull   0xc(%esp)
  803877:	39 d6                	cmp    %edx,%esi
  803879:	72 15                	jb     803890 <__udivdi3+0x100>
  80387b:	89 f9                	mov    %edi,%ecx
  80387d:	d3 e5                	shl    %cl,%ebp
  80387f:	39 c5                	cmp    %eax,%ebp
  803881:	73 04                	jae    803887 <__udivdi3+0xf7>
  803883:	39 d6                	cmp    %edx,%esi
  803885:	74 09                	je     803890 <__udivdi3+0x100>
  803887:	89 d8                	mov    %ebx,%eax
  803889:	31 ff                	xor    %edi,%edi
  80388b:	e9 40 ff ff ff       	jmp    8037d0 <__udivdi3+0x40>
  803890:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803893:	31 ff                	xor    %edi,%edi
  803895:	e9 36 ff ff ff       	jmp    8037d0 <__udivdi3+0x40>
  80389a:	66 90                	xchg   %ax,%ax
  80389c:	66 90                	xchg   %ax,%ax
  80389e:	66 90                	xchg   %ax,%ax

008038a0 <__umoddi3>:
  8038a0:	f3 0f 1e fb          	endbr32 
  8038a4:	55                   	push   %ebp
  8038a5:	57                   	push   %edi
  8038a6:	56                   	push   %esi
  8038a7:	53                   	push   %ebx
  8038a8:	83 ec 1c             	sub    $0x1c,%esp
  8038ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8038af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8038b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8038b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8038bb:	85 c0                	test   %eax,%eax
  8038bd:	75 19                	jne    8038d8 <__umoddi3+0x38>
  8038bf:	39 df                	cmp    %ebx,%edi
  8038c1:	76 5d                	jbe    803920 <__umoddi3+0x80>
  8038c3:	89 f0                	mov    %esi,%eax
  8038c5:	89 da                	mov    %ebx,%edx
  8038c7:	f7 f7                	div    %edi
  8038c9:	89 d0                	mov    %edx,%eax
  8038cb:	31 d2                	xor    %edx,%edx
  8038cd:	83 c4 1c             	add    $0x1c,%esp
  8038d0:	5b                   	pop    %ebx
  8038d1:	5e                   	pop    %esi
  8038d2:	5f                   	pop    %edi
  8038d3:	5d                   	pop    %ebp
  8038d4:	c3                   	ret    
  8038d5:	8d 76 00             	lea    0x0(%esi),%esi
  8038d8:	89 f2                	mov    %esi,%edx
  8038da:	39 d8                	cmp    %ebx,%eax
  8038dc:	76 12                	jbe    8038f0 <__umoddi3+0x50>
  8038de:	89 f0                	mov    %esi,%eax
  8038e0:	89 da                	mov    %ebx,%edx
  8038e2:	83 c4 1c             	add    $0x1c,%esp
  8038e5:	5b                   	pop    %ebx
  8038e6:	5e                   	pop    %esi
  8038e7:	5f                   	pop    %edi
  8038e8:	5d                   	pop    %ebp
  8038e9:	c3                   	ret    
  8038ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8038f0:	0f bd e8             	bsr    %eax,%ebp
  8038f3:	83 f5 1f             	xor    $0x1f,%ebp
  8038f6:	75 50                	jne    803948 <__umoddi3+0xa8>
  8038f8:	39 d8                	cmp    %ebx,%eax
  8038fa:	0f 82 e0 00 00 00    	jb     8039e0 <__umoddi3+0x140>
  803900:	89 d9                	mov    %ebx,%ecx
  803902:	39 f7                	cmp    %esi,%edi
  803904:	0f 86 d6 00 00 00    	jbe    8039e0 <__umoddi3+0x140>
  80390a:	89 d0                	mov    %edx,%eax
  80390c:	89 ca                	mov    %ecx,%edx
  80390e:	83 c4 1c             	add    $0x1c,%esp
  803911:	5b                   	pop    %ebx
  803912:	5e                   	pop    %esi
  803913:	5f                   	pop    %edi
  803914:	5d                   	pop    %ebp
  803915:	c3                   	ret    
  803916:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80391d:	8d 76 00             	lea    0x0(%esi),%esi
  803920:	89 fd                	mov    %edi,%ebp
  803922:	85 ff                	test   %edi,%edi
  803924:	75 0b                	jne    803931 <__umoddi3+0x91>
  803926:	b8 01 00 00 00       	mov    $0x1,%eax
  80392b:	31 d2                	xor    %edx,%edx
  80392d:	f7 f7                	div    %edi
  80392f:	89 c5                	mov    %eax,%ebp
  803931:	89 d8                	mov    %ebx,%eax
  803933:	31 d2                	xor    %edx,%edx
  803935:	f7 f5                	div    %ebp
  803937:	89 f0                	mov    %esi,%eax
  803939:	f7 f5                	div    %ebp
  80393b:	89 d0                	mov    %edx,%eax
  80393d:	31 d2                	xor    %edx,%edx
  80393f:	eb 8c                	jmp    8038cd <__umoddi3+0x2d>
  803941:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803948:	89 e9                	mov    %ebp,%ecx
  80394a:	ba 20 00 00 00       	mov    $0x20,%edx
  80394f:	29 ea                	sub    %ebp,%edx
  803951:	d3 e0                	shl    %cl,%eax
  803953:	89 44 24 08          	mov    %eax,0x8(%esp)
  803957:	89 d1                	mov    %edx,%ecx
  803959:	89 f8                	mov    %edi,%eax
  80395b:	d3 e8                	shr    %cl,%eax
  80395d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803961:	89 54 24 04          	mov    %edx,0x4(%esp)
  803965:	8b 54 24 04          	mov    0x4(%esp),%edx
  803969:	09 c1                	or     %eax,%ecx
  80396b:	89 d8                	mov    %ebx,%eax
  80396d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803971:	89 e9                	mov    %ebp,%ecx
  803973:	d3 e7                	shl    %cl,%edi
  803975:	89 d1                	mov    %edx,%ecx
  803977:	d3 e8                	shr    %cl,%eax
  803979:	89 e9                	mov    %ebp,%ecx
  80397b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80397f:	d3 e3                	shl    %cl,%ebx
  803981:	89 c7                	mov    %eax,%edi
  803983:	89 d1                	mov    %edx,%ecx
  803985:	89 f0                	mov    %esi,%eax
  803987:	d3 e8                	shr    %cl,%eax
  803989:	89 e9                	mov    %ebp,%ecx
  80398b:	89 fa                	mov    %edi,%edx
  80398d:	d3 e6                	shl    %cl,%esi
  80398f:	09 d8                	or     %ebx,%eax
  803991:	f7 74 24 08          	divl   0x8(%esp)
  803995:	89 d1                	mov    %edx,%ecx
  803997:	89 f3                	mov    %esi,%ebx
  803999:	f7 64 24 0c          	mull   0xc(%esp)
  80399d:	89 c6                	mov    %eax,%esi
  80399f:	89 d7                	mov    %edx,%edi
  8039a1:	39 d1                	cmp    %edx,%ecx
  8039a3:	72 06                	jb     8039ab <__umoddi3+0x10b>
  8039a5:	75 10                	jne    8039b7 <__umoddi3+0x117>
  8039a7:	39 c3                	cmp    %eax,%ebx
  8039a9:	73 0c                	jae    8039b7 <__umoddi3+0x117>
  8039ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8039af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8039b3:	89 d7                	mov    %edx,%edi
  8039b5:	89 c6                	mov    %eax,%esi
  8039b7:	89 ca                	mov    %ecx,%edx
  8039b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8039be:	29 f3                	sub    %esi,%ebx
  8039c0:	19 fa                	sbb    %edi,%edx
  8039c2:	89 d0                	mov    %edx,%eax
  8039c4:	d3 e0                	shl    %cl,%eax
  8039c6:	89 e9                	mov    %ebp,%ecx
  8039c8:	d3 eb                	shr    %cl,%ebx
  8039ca:	d3 ea                	shr    %cl,%edx
  8039cc:	09 d8                	or     %ebx,%eax
  8039ce:	83 c4 1c             	add    $0x1c,%esp
  8039d1:	5b                   	pop    %ebx
  8039d2:	5e                   	pop    %esi
  8039d3:	5f                   	pop    %edi
  8039d4:	5d                   	pop    %ebp
  8039d5:	c3                   	ret    
  8039d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039dd:	8d 76 00             	lea    0x0(%esi),%esi
  8039e0:	29 fe                	sub    %edi,%esi
  8039e2:	19 c3                	sbb    %eax,%ebx
  8039e4:	89 f2                	mov    %esi,%edx
  8039e6:	89 d9                	mov    %ebx,%ecx
  8039e8:	e9 1d ff ff ff       	jmp    80390a <__umoddi3+0x6a>
