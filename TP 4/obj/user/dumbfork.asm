
obj/user/dumbfork.debug:     formato del fichero elf32-i386


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
  80002c:	e8 ad 01 00 00       	call   8001de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	6a 07                	push   $0x7
  800047:	53                   	push   %ebx
  800048:	56                   	push   %esi
  800049:	e8 d5 0c 00 00       	call   800d23 <sys_page_alloc>
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	85 c0                	test   %eax,%eax
  800053:	78 4a                	js     80009f <duppage+0x6c>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800055:	83 ec 0c             	sub    $0xc,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 40 00       	push   $0x400000
  80005f:	6a 00                	push   $0x0
  800061:	53                   	push   %ebx
  800062:	56                   	push   %esi
  800063:	e8 e3 0c 00 00       	call   800d4b <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 d1 09 00 00       	call   800a53 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 e4 0c 00 00       	call   800d75 <sys_page_unmap>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	78 2b                	js     8000c3 <duppage+0x90>
		panic("sys_page_unmap: %e", r);
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009f:	50                   	push   %eax
  8000a0:	68 60 1f 80 00       	push   $0x801f60
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 73 1f 80 00       	push   $0x801f73
  8000ac:	e8 99 01 00 00       	call   80024a <_panic>
		panic("sys_page_map: %e", r);
  8000b1:	50                   	push   %eax
  8000b2:	68 83 1f 80 00       	push   $0x801f83
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 73 1f 80 00       	push   $0x801f73
  8000be:	e8 87 01 00 00       	call   80024a <_panic>
		panic("sys_page_unmap: %e", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 94 1f 80 00       	push   $0x801f94
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 73 1f 80 00       	push   $0x801f73
  8000d0:	e8 75 01 00 00       	call   80024a <_panic>

008000d5 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8000e6:	cd 30                	int    $0x30
  8000e8:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	78 0d                	js     8000fb <dumbfork+0x26>
  8000ee:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000f0:	74 1b                	je     80010d <dumbfork+0x38>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000f2:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f9:	eb 3f                	jmp    80013a <dumbfork+0x65>
		panic("sys_exofork: %e", envid);
  8000fb:	50                   	push   %eax
  8000fc:	68 a7 1f 80 00       	push   $0x801fa7
  800101:	6a 37                	push   $0x37
  800103:	68 73 1f 80 00       	push   $0x801f73
  800108:	e8 3d 01 00 00       	call   80024a <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 be 0b 00 00       	call   800cd0 <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800124:	eb 43                	jmp    800169 <dumbfork+0x94>
		duppage(envid, addr);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	52                   	push   %edx
  80012a:	56                   	push   %esi
  80012b:	e8 03 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800130:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013d:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800143:	72 e1                	jb     800126 <dumbfork+0x51>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800150:	50                   	push   %eax
  800151:	53                   	push   %ebx
  800152:	e8 dc fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	6a 02                	push   $0x2
  80015c:	53                   	push   %ebx
  80015d:	e8 3a 0c 00 00       	call   800d9c <sys_env_set_status>
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	85 c0                	test   %eax,%eax
  800167:	78 09                	js     800172 <dumbfork+0x9d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800169:	89 d8                	mov    %ebx,%eax
  80016b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800172:	50                   	push   %eax
  800173:	68 b7 1f 80 00       	push   $0x801fb7
  800178:	6a 4c                	push   $0x4c
  80017a:	68 73 1f 80 00       	push   $0x801f73
  80017f:	e8 c6 00 00 00       	call   80024a <_panic>

00800184 <umain>:
{
  800184:	f3 0f 1e fb          	endbr32 
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800191:	e8 3f ff ff ff       	call   8000d5 <dumbfork>
  800196:	89 c6                	mov    %eax,%esi
  800198:	85 c0                	test   %eax,%eax
  80019a:	bf ce 1f 80 00       	mov    $0x801fce,%edi
  80019f:	b8 d5 1f 80 00       	mov    $0x801fd5,%eax
  8001a4:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	eb 1f                	jmp    8001cd <umain+0x49>
  8001ae:	83 fb 13             	cmp    $0x13,%ebx
  8001b1:	7f 23                	jg     8001d6 <umain+0x52>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	57                   	push   %edi
  8001b7:	53                   	push   %ebx
  8001b8:	68 db 1f 80 00       	push   $0x801fdb
  8001bd:	e8 6f 01 00 00       	call   800331 <cprintf>
		sys_yield();
  8001c2:	e8 31 0b 00 00       	call   800cf8 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c7:	83 c3 01             	add    $0x1,%ebx
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 f6                	test   %esi,%esi
  8001cf:	74 dd                	je     8001ae <umain+0x2a>
  8001d1:	83 fb 09             	cmp    $0x9,%ebx
  8001d4:	7e dd                	jle    8001b3 <umain+0x2f>
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001de:	f3 0f 1e fb          	endbr32 
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001ed:	e8 de 0a 00 00       	call   800cd0 <sys_getenvid>
	if (id >= 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	78 12                	js     800208 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800203:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7e 07                	jle    800213 <libmain+0x35>
		binaryname = argv[0];
  80020c:	8b 06                	mov    (%esi),%eax
  80020e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	e8 67 ff ff ff       	call   800184 <umain>

	// exit gracefully
	exit();
  80021d:	e8 0a 00 00 00       	call   80022c <exit>
}
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022c:	f3 0f 1e fb          	endbr32 
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800236:	e8 18 0e 00 00       	call   801053 <close_all>
	sys_env_destroy(0);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	6a 00                	push   $0x0
  800240:	e8 65 0a 00 00       	call   800caa <sys_env_destroy>
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024a:	f3 0f 1e fb          	endbr32 
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800253:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800256:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025c:	e8 6f 0a 00 00       	call   800cd0 <sys_getenvid>
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	56                   	push   %esi
  80026b:	50                   	push   %eax
  80026c:	68 f8 1f 80 00       	push   $0x801ff8
  800271:	e8 bb 00 00 00       	call   800331 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800276:	83 c4 18             	add    $0x18,%esp
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	e8 5a 00 00 00       	call   8002dc <vcprintf>
	cprintf("\n");
  800282:	c7 04 24 eb 1f 80 00 	movl   $0x801feb,(%esp)
  800289:	e8 a3 00 00 00       	call   800331 <cprintf>
  80028e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800291:	cc                   	int3   
  800292:	eb fd                	jmp    800291 <_panic+0x47>

00800294 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800294:	f3 0f 1e fb          	endbr32 
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	53                   	push   %ebx
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a2:	8b 13                	mov    (%ebx),%edx
  8002a4:	8d 42 01             	lea    0x1(%edx),%eax
  8002a7:	89 03                	mov    %eax,(%ebx)
  8002a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b5:	74 09                	je     8002c0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	68 ff 00 00 00       	push   $0xff
  8002c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cb:	50                   	push   %eax
  8002cc:	e8 87 09 00 00       	call   800c58 <sys_cputs>
		b->idx = 0;
  8002d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	eb db                	jmp    8002b7 <putch+0x23>

008002dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002dc:	f3 0f 1e fb          	endbr32 
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f0:	00 00 00 
	b.cnt = 0;
  8002f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002fd:	ff 75 0c             	pushl  0xc(%ebp)
  800300:	ff 75 08             	pushl  0x8(%ebp)
  800303:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800309:	50                   	push   %eax
  80030a:	68 94 02 80 00       	push   $0x800294
  80030f:	e8 80 01 00 00       	call   800494 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800314:	83 c4 08             	add    $0x8,%esp
  800317:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80031d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800323:	50                   	push   %eax
  800324:	e8 2f 09 00 00       	call   800c58 <sys_cputs>

	return b.cnt;
}
  800329:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80033b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033e:	50                   	push   %eax
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 95 ff ff ff       	call   8002dc <vcprintf>
	va_end(ap);

	return cnt;
}
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
  80034f:	83 ec 1c             	sub    $0x1c,%esp
  800352:	89 c7                	mov    %eax,%edi
  800354:	89 d6                	mov    %edx,%esi
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	89 d1                	mov    %edx,%ecx
  80035e:	89 c2                	mov    %eax,%edx
  800360:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800363:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800366:	8b 45 10             	mov    0x10(%ebp),%eax
  800369:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800376:	39 c2                	cmp    %eax,%edx
  800378:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80037b:	72 3e                	jb     8003bb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037d:	83 ec 0c             	sub    $0xc,%esp
  800380:	ff 75 18             	pushl  0x18(%ebp)
  800383:	83 eb 01             	sub    $0x1,%ebx
  800386:	53                   	push   %ebx
  800387:	50                   	push   %eax
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 64 19 00 00       	call   801d00 <__udivdi3>
  80039c:	83 c4 18             	add    $0x18,%esp
  80039f:	52                   	push   %edx
  8003a0:	50                   	push   %eax
  8003a1:	89 f2                	mov    %esi,%edx
  8003a3:	89 f8                	mov    %edi,%eax
  8003a5:	e8 9f ff ff ff       	call   800349 <printnum>
  8003aa:	83 c4 20             	add    $0x20,%esp
  8003ad:	eb 13                	jmp    8003c2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	56                   	push   %esi
  8003b3:	ff 75 18             	pushl  0x18(%ebp)
  8003b6:	ff d7                	call   *%edi
  8003b8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003bb:	83 eb 01             	sub    $0x1,%ebx
  8003be:	85 db                	test   %ebx,%ebx
  8003c0:	7f ed                	jg     8003af <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	56                   	push   %esi
  8003c6:	83 ec 04             	sub    $0x4,%esp
  8003c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d5:	e8 36 1a 00 00       	call   801e10 <__umoddi3>
  8003da:	83 c4 14             	add    $0x14,%esp
  8003dd:	0f be 80 1b 20 80 00 	movsbl 0x80201b(%eax),%eax
  8003e4:	50                   	push   %eax
  8003e5:	ff d7                	call   *%edi
}
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ed:	5b                   	pop    %ebx
  8003ee:	5e                   	pop    %esi
  8003ef:	5f                   	pop    %edi
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003f2:	83 fa 01             	cmp    $0x1,%edx
  8003f5:	7f 13                	jg     80040a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8003f7:	85 d2                	test   %edx,%edx
  8003f9:	74 1c                	je     800417 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8003fb:	8b 10                	mov    (%eax),%edx
  8003fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800400:	89 08                	mov    %ecx,(%eax)
  800402:	8b 02                	mov    (%edx),%eax
  800404:	ba 00 00 00 00       	mov    $0x0,%edx
  800409:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	8b 52 04             	mov    0x4(%edx),%edx
  800416:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800417:	8b 10                	mov    (%eax),%edx
  800419:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041c:	89 08                	mov    %ecx,(%eax)
  80041e:	8b 02                	mov    (%edx),%eax
  800420:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800425:	c3                   	ret    

00800426 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800426:	83 fa 01             	cmp    $0x1,%edx
  800429:	7f 0f                	jg     80043a <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 18                	je     800447 <getint+0x21>
		return va_arg(*ap, long);
  80042f:	8b 10                	mov    (%eax),%edx
  800431:	8d 4a 04             	lea    0x4(%edx),%ecx
  800434:	89 08                	mov    %ecx,(%eax)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	99                   	cltd   
  800439:	c3                   	ret    
		return va_arg(*ap, long long);
  80043a:	8b 10                	mov    (%eax),%edx
  80043c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043f:	89 08                	mov    %ecx,(%eax)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	8b 52 04             	mov    0x4(%edx),%edx
  800446:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800447:	8b 10                	mov    (%eax),%edx
  800449:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044c:	89 08                	mov    %ecx,(%eax)
  80044e:	8b 02                	mov    (%edx),%eax
  800450:	99                   	cltd   
}
  800451:	c3                   	ret    

00800452 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800452:	f3 0f 1e fb          	endbr32 
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800460:	8b 10                	mov    (%eax),%edx
  800462:	3b 50 04             	cmp    0x4(%eax),%edx
  800465:	73 0a                	jae    800471 <sprintputch+0x1f>
		*b->buf++ = ch;
  800467:	8d 4a 01             	lea    0x1(%edx),%ecx
  80046a:	89 08                	mov    %ecx,(%eax)
  80046c:	8b 45 08             	mov    0x8(%ebp),%eax
  80046f:	88 02                	mov    %al,(%edx)
}
  800471:	5d                   	pop    %ebp
  800472:	c3                   	ret    

00800473 <printfmt>:
{
  800473:	f3 0f 1e fb          	endbr32 
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80047d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800480:	50                   	push   %eax
  800481:	ff 75 10             	pushl  0x10(%ebp)
  800484:	ff 75 0c             	pushl  0xc(%ebp)
  800487:	ff 75 08             	pushl  0x8(%ebp)
  80048a:	e8 05 00 00 00       	call   800494 <vprintfmt>
}
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <vprintfmt>:
{
  800494:	f3 0f 1e fb          	endbr32 
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	57                   	push   %edi
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 2c             	sub    $0x2c,%esp
  8004a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004aa:	e9 86 02 00 00       	jmp    800735 <vprintfmt+0x2a1>
		padc = ' ';
  8004af:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004b3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004ba:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004c1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8d 47 01             	lea    0x1(%edi),%eax
  8004d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d3:	0f b6 17             	movzbl (%edi),%edx
  8004d6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004d9:	3c 55                	cmp    $0x55,%al
  8004db:	0f 87 df 02 00 00    	ja     8007c0 <vprintfmt+0x32c>
  8004e1:	0f b6 c0             	movzbl %al,%eax
  8004e4:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8004eb:	00 
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004ef:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004f3:	eb d8                	jmp    8004cd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004fc:	eb cf                	jmp    8004cd <vprintfmt+0x39>
  8004fe:	0f b6 d2             	movzbl %dl,%edx
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800504:	b8 00 00 00 00       	mov    $0x0,%eax
  800509:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80050c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80050f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800513:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800516:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800519:	83 f9 09             	cmp    $0x9,%ecx
  80051c:	77 52                	ja     800570 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80051e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800521:	eb e9                	jmp    80050c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	79 93                	jns    8004cd <vprintfmt+0x39>
				width = precision, precision = -1;
  80053a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80053d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800540:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800547:	eb 84                	jmp    8004cd <vprintfmt+0x39>
  800549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054c:	85 c0                	test   %eax,%eax
  80054e:	ba 00 00 00 00       	mov    $0x0,%edx
  800553:	0f 49 d0             	cmovns %eax,%edx
  800556:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80055c:	e9 6c ff ff ff       	jmp    8004cd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800564:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80056b:	e9 5d ff ff ff       	jmp    8004cd <vprintfmt+0x39>
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800576:	eb bc                	jmp    800534 <vprintfmt+0xa0>
			lflag++;
  800578:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80057e:	e9 4a ff ff ff       	jmp    8004cd <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	56                   	push   %esi
  800590:	ff 30                	pushl  (%eax)
  800592:	ff d3                	call   *%ebx
			break;
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	e9 96 01 00 00       	jmp    800732 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	99                   	cltd   
  8005a8:	31 d0                	xor    %edx,%eax
  8005aa:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ac:	83 f8 0f             	cmp    $0xf,%eax
  8005af:	7f 20                	jg     8005d1 <vprintfmt+0x13d>
  8005b1:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	74 15                	je     8005d1 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8005bc:	52                   	push   %edx
  8005bd:	68 f1 23 80 00       	push   $0x8023f1
  8005c2:	56                   	push   %esi
  8005c3:	53                   	push   %ebx
  8005c4:	e8 aa fe ff ff       	call   800473 <printfmt>
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	e9 61 01 00 00       	jmp    800732 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005d1:	50                   	push   %eax
  8005d2:	68 33 20 80 00       	push   $0x802033
  8005d7:	56                   	push   %esi
  8005d8:	53                   	push   %ebx
  8005d9:	e8 95 fe ff ff       	call   800473 <printfmt>
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	e9 4c 01 00 00       	jmp    800732 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	b8 2c 20 80 00       	mov    $0x80202c,%eax
  8005f8:	0f 45 c1             	cmovne %ecx,%eax
  8005fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800602:	7e 06                	jle    80060a <vprintfmt+0x176>
  800604:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800608:	75 0d                	jne    800617 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80060d:	89 c7                	mov    %eax,%edi
  80060f:	03 45 e0             	add    -0x20(%ebp),%eax
  800612:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800615:	eb 57                	jmp    80066e <vprintfmt+0x1da>
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	ff 75 d8             	pushl  -0x28(%ebp)
  80061d:	ff 75 cc             	pushl  -0x34(%ebp)
  800620:	e8 4f 02 00 00       	call   800874 <strnlen>
  800625:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800628:	29 c2                	sub    %eax,%edx
  80062a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80062d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800630:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800634:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800637:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800639:	85 db                	test   %ebx,%ebx
  80063b:	7e 10                	jle    80064d <vprintfmt+0x1b9>
					putch(padc, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	56                   	push   %esi
  800641:	57                   	push   %edi
  800642:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800645:	83 eb 01             	sub    $0x1,%ebx
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb ec                	jmp    800639 <vprintfmt+0x1a5>
  80064d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800650:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800653:	85 d2                	test   %edx,%edx
  800655:	b8 00 00 00 00       	mov    $0x0,%eax
  80065a:	0f 49 c2             	cmovns %edx,%eax
  80065d:	29 c2                	sub    %eax,%edx
  80065f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800662:	eb a6                	jmp    80060a <vprintfmt+0x176>
					putch(ch, putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	56                   	push   %esi
  800668:	52                   	push   %edx
  800669:	ff d3                	call   *%ebx
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800671:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800673:	83 c7 01             	add    $0x1,%edi
  800676:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067a:	0f be d0             	movsbl %al,%edx
  80067d:	85 d2                	test   %edx,%edx
  80067f:	74 42                	je     8006c3 <vprintfmt+0x22f>
  800681:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800685:	78 06                	js     80068d <vprintfmt+0x1f9>
  800687:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80068b:	78 1e                	js     8006ab <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80068d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800691:	74 d1                	je     800664 <vprintfmt+0x1d0>
  800693:	0f be c0             	movsbl %al,%eax
  800696:	83 e8 20             	sub    $0x20,%eax
  800699:	83 f8 5e             	cmp    $0x5e,%eax
  80069c:	76 c6                	jbe    800664 <vprintfmt+0x1d0>
					putch('?', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	56                   	push   %esi
  8006a2:	6a 3f                	push   $0x3f
  8006a4:	ff d3                	call   *%ebx
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	eb c3                	jmp    80066e <vprintfmt+0x1da>
  8006ab:	89 cf                	mov    %ecx,%edi
  8006ad:	eb 0e                	jmp    8006bd <vprintfmt+0x229>
				putch(' ', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	56                   	push   %esi
  8006b3:	6a 20                	push   $0x20
  8006b5:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8006b7:	83 ef 01             	sub    $0x1,%edi
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	7f ee                	jg     8006af <vprintfmt+0x21b>
  8006c1:	eb 6f                	jmp    800732 <vprintfmt+0x29e>
  8006c3:	89 cf                	mov    %ecx,%edi
  8006c5:	eb f6                	jmp    8006bd <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8006c7:	89 ca                	mov    %ecx,%edx
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 55 fd ff ff       	call   800426 <getint>
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	78 0b                	js     8006e6 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8006db:	89 d1                	mov    %edx,%ecx
  8006dd:	89 c2                	mov    %eax,%edx
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e4:	eb 32                	jmp    800718 <vprintfmt+0x284>
				putch('-', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	56                   	push   %esi
  8006ea:	6a 2d                	push   $0x2d
  8006ec:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006f4:	f7 da                	neg    %edx
  8006f6:	83 d1 00             	adc    $0x0,%ecx
  8006f9:	f7 d9                	neg    %ecx
  8006fb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800703:	eb 13                	jmp    800718 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800705:	89 ca                	mov    %ecx,%edx
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 e3 fc ff ff       	call   8003f2 <getuint>
  80070f:	89 d1                	mov    %edx,%ecx
  800711:	89 c2                	mov    %eax,%edx
			base = 10;
  800713:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80071f:	57                   	push   %edi
  800720:	ff 75 e0             	pushl  -0x20(%ebp)
  800723:	50                   	push   %eax
  800724:	51                   	push   %ecx
  800725:	52                   	push   %edx
  800726:	89 f2                	mov    %esi,%edx
  800728:	89 d8                	mov    %ebx,%eax
  80072a:	e8 1a fc ff ff       	call   800349 <printnum>
			break;
  80072f:	83 c4 20             	add    $0x20,%esp
{
  800732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800735:	83 c7 01             	add    $0x1,%edi
  800738:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073c:	83 f8 25             	cmp    $0x25,%eax
  80073f:	0f 84 6a fd ff ff    	je     8004af <vprintfmt+0x1b>
			if (ch == '\0')
  800745:	85 c0                	test   %eax,%eax
  800747:	0f 84 93 00 00 00    	je     8007e0 <vprintfmt+0x34c>
			putch(ch, putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	56                   	push   %esi
  800751:	50                   	push   %eax
  800752:	ff d3                	call   *%ebx
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb dc                	jmp    800735 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800759:	89 ca                	mov    %ecx,%edx
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 8f fc ff ff       	call   8003f2 <getuint>
  800763:	89 d1                	mov    %edx,%ecx
  800765:	89 c2                	mov    %eax,%edx
			base = 8;
  800767:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80076c:	eb aa                	jmp    800718 <vprintfmt+0x284>
			putch('0', putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	56                   	push   %esi
  800772:	6a 30                	push   $0x30
  800774:	ff d3                	call   *%ebx
			putch('x', putdat);
  800776:	83 c4 08             	add    $0x8,%esp
  800779:	56                   	push   %esi
  80077a:	6a 78                	push   $0x78
  80077c:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800787:	8b 10                	mov    (%eax),%edx
  800789:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80078e:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800791:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800796:	eb 80                	jmp    800718 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800798:	89 ca                	mov    %ecx,%edx
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
  80079d:	e8 50 fc ff ff       	call   8003f2 <getuint>
  8007a2:	89 d1                	mov    %edx,%ecx
  8007a4:	89 c2                	mov    %eax,%edx
			base = 16;
  8007a6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ab:	e9 68 ff ff ff       	jmp    800718 <vprintfmt+0x284>
			putch(ch, putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	56                   	push   %esi
  8007b4:	6a 25                	push   $0x25
  8007b6:	ff d3                	call   *%ebx
			break;
  8007b8:	83 c4 10             	add    $0x10,%esp
  8007bb:	e9 72 ff ff ff       	jmp    800732 <vprintfmt+0x29e>
			putch('%', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	56                   	push   %esi
  8007c4:	6a 25                	push   $0x25
  8007c6:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	89 f8                	mov    %edi,%eax
  8007cd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d1:	74 05                	je     8007d8 <vprintfmt+0x344>
  8007d3:	83 e8 01             	sub    $0x1,%eax
  8007d6:	eb f5                	jmp    8007cd <vprintfmt+0x339>
  8007d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007db:	e9 52 ff ff ff       	jmp    800732 <vprintfmt+0x29e>
}
  8007e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5f                   	pop    %edi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e8:	f3 0f 1e fb          	endbr32 
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 18             	sub    $0x18,%esp
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800802:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 26                	je     800833 <vsnprintf+0x4b>
  80080d:	85 d2                	test   %edx,%edx
  80080f:	7e 22                	jle    800833 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800811:	ff 75 14             	pushl  0x14(%ebp)
  800814:	ff 75 10             	pushl  0x10(%ebp)
  800817:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081a:	50                   	push   %eax
  80081b:	68 52 04 80 00       	push   $0x800452
  800820:	e8 6f fc ff ff       	call   800494 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800825:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800828:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082e:	83 c4 10             	add    $0x10,%esp
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    
		return -E_INVAL;
  800833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800838:	eb f7                	jmp    800831 <vsnprintf+0x49>

0080083a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083a:	f3 0f 1e fb          	endbr32 
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800847:	50                   	push   %eax
  800848:	ff 75 10             	pushl  0x10(%ebp)
  80084b:	ff 75 0c             	pushl  0xc(%ebp)
  80084e:	ff 75 08             	pushl  0x8(%ebp)
  800851:	e8 92 ff ff ff       	call   8007e8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800858:	f3 0f 1e fb          	endbr32 
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	74 05                	je     800872 <strlen+0x1a>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	eb f5                	jmp    800867 <strlen+0xf>
	return n;
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800874:	f3 0f 1e fb          	endbr32 
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	39 d0                	cmp    %edx,%eax
  800888:	74 0d                	je     800897 <strnlen+0x23>
  80088a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088e:	74 05                	je     800895 <strnlen+0x21>
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	eb f1                	jmp    800886 <strnlen+0x12>
  800895:	89 c2                	mov    %eax,%edx
	return n;
}
  800897:	89 d0                	mov    %edx,%eax
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	f3 0f 1e fb          	endbr32 
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ae:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008b2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008bc:	89 c8                	mov    %ecx,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c1:	f3 0f 1e fb          	endbr32 
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	83 ec 10             	sub    $0x10,%esp
  8008cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008cf:	53                   	push   %ebx
  8008d0:	e8 83 ff ff ff       	call   800858 <strlen>
  8008d5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	01 d8                	add    %ebx,%eax
  8008dd:	50                   	push   %eax
  8008de:	e8 b8 ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008e3:	89 d8                	mov    %ebx,%eax
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ea:	f3 0f 1e fb          	endbr32 
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f9:	89 f3                	mov    %esi,%ebx
  8008fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	39 d8                	cmp    %ebx,%eax
  800902:	74 11                	je     800915 <strncpy+0x2b>
		*dst++ = *src;
  800904:	83 c0 01             	add    $0x1,%eax
  800907:	0f b6 0a             	movzbl (%edx),%ecx
  80090a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090d:	80 f9 01             	cmp    $0x1,%cl
  800910:	83 da ff             	sbb    $0xffffffff,%edx
  800913:	eb eb                	jmp    800900 <strncpy+0x16>
	}
	return ret;
}
  800915:	89 f0                	mov    %esi,%eax
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091b:	f3 0f 1e fb          	endbr32 
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092a:	8b 55 10             	mov    0x10(%ebp),%edx
  80092d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092f:	85 d2                	test   %edx,%edx
  800931:	74 21                	je     800954 <strlcpy+0x39>
  800933:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800937:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800939:	39 c2                	cmp    %eax,%edx
  80093b:	74 14                	je     800951 <strlcpy+0x36>
  80093d:	0f b6 19             	movzbl (%ecx),%ebx
  800940:	84 db                	test   %bl,%bl
  800942:	74 0b                	je     80094f <strlcpy+0x34>
			*dst++ = *src++;
  800944:	83 c1 01             	add    $0x1,%ecx
  800947:	83 c2 01             	add    $0x1,%edx
  80094a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80094d:	eb ea                	jmp    800939 <strlcpy+0x1e>
  80094f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800951:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800954:	29 f0                	sub    %esi,%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095a:	f3 0f 1e fb          	endbr32 
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800964:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800967:	0f b6 01             	movzbl (%ecx),%eax
  80096a:	84 c0                	test   %al,%al
  80096c:	74 0c                	je     80097a <strcmp+0x20>
  80096e:	3a 02                	cmp    (%edx),%al
  800970:	75 08                	jne    80097a <strcmp+0x20>
		p++, q++;
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	eb ed                	jmp    800967 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097a:	0f b6 c0             	movzbl %al,%eax
  80097d:	0f b6 12             	movzbl (%edx),%edx
  800980:	29 d0                	sub    %edx,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	89 c3                	mov    %eax,%ebx
  800994:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800997:	eb 06                	jmp    80099f <strncmp+0x1b>
		n--, p++, q++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80099f:	39 d8                	cmp    %ebx,%eax
  8009a1:	74 16                	je     8009b9 <strncmp+0x35>
  8009a3:	0f b6 08             	movzbl (%eax),%ecx
  8009a6:	84 c9                	test   %cl,%cl
  8009a8:	74 04                	je     8009ae <strncmp+0x2a>
  8009aa:	3a 0a                	cmp    (%edx),%cl
  8009ac:	74 eb                	je     800999 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	0f b6 12             	movzbl (%edx),%edx
  8009b4:	29 d0                	sub    %edx,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    
		return 0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009be:	eb f6                	jmp    8009b6 <strncmp+0x32>

008009c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c0:	f3 0f 1e fb          	endbr32 
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	84 d2                	test   %dl,%dl
  8009d3:	74 09                	je     8009de <strchr+0x1e>
		if (*s == c)
  8009d5:	38 ca                	cmp    %cl,%dl
  8009d7:	74 0a                	je     8009e3 <strchr+0x23>
	for (; *s; s++)
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	eb f0                	jmp    8009ce <strchr+0xe>
			return (char *) s;
	return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e5:	f3 0f 1e fb          	endbr32 
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f6:	38 ca                	cmp    %cl,%dl
  8009f8:	74 09                	je     800a03 <strfind+0x1e>
  8009fa:	84 d2                	test   %dl,%dl
  8009fc:	74 05                	je     800a03 <strfind+0x1e>
	for (; *s; s++)
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	eb f0                	jmp    8009f3 <strfind+0xe>
			break;
	return (char *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	f3 0f 1e fb          	endbr32 
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a15:	85 c9                	test   %ecx,%ecx
  800a17:	74 33                	je     800a4c <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a19:	89 d0                	mov    %edx,%eax
  800a1b:	09 c8                	or     %ecx,%eax
  800a1d:	a8 03                	test   $0x3,%al
  800a1f:	75 23                	jne    800a44 <memset+0x3f>
		c &= 0xFF;
  800a21:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d8                	mov    %ebx,%eax
  800a27:	c1 e0 08             	shl    $0x8,%eax
  800a2a:	89 df                	mov    %ebx,%edi
  800a2c:	c1 e7 18             	shl    $0x18,%edi
  800a2f:	89 de                	mov    %ebx,%esi
  800a31:	c1 e6 10             	shl    $0x10,%esi
  800a34:	09 f7                	or     %esi,%edi
  800a36:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a38:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a3d:	89 d7                	mov    %edx,%edi
  800a3f:	fc                   	cld    
  800a40:	f3 ab                	rep stos %eax,%es:(%edi)
  800a42:	eb 08                	jmp    800a4c <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a44:	89 d7                	mov    %edx,%edi
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	fc                   	cld    
  800a4a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a4c:	89 d0                	mov    %edx,%eax
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a65:	39 c6                	cmp    %eax,%esi
  800a67:	73 32                	jae    800a9b <memmove+0x48>
  800a69:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6c:	39 c2                	cmp    %eax,%edx
  800a6e:	76 2b                	jbe    800a9b <memmove+0x48>
		s += n;
		d += n;
  800a70:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	89 fe                	mov    %edi,%esi
  800a75:	09 ce                	or     %ecx,%esi
  800a77:	09 d6                	or     %edx,%esi
  800a79:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7f:	75 0e                	jne    800a8f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a81:	83 ef 04             	sub    $0x4,%edi
  800a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a87:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a8a:	fd                   	std    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 09                	jmp    800a98 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a95:	fd                   	std    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a98:	fc                   	cld    
  800a99:	eb 1a                	jmp    800ab5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	09 ca                	or     %ecx,%edx
  800a9f:	09 f2                	or     %esi,%edx
  800aa1:	f6 c2 03             	test   $0x3,%dl
  800aa4:	75 0a                	jne    800ab0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aae:	eb 05                	jmp    800ab5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ab0:	89 c7                	mov    %eax,%edi
  800ab2:	fc                   	cld    
  800ab3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab9:	f3 0f 1e fb          	endbr32 
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	ff 75 08             	pushl  0x8(%ebp)
  800acc:	e8 82 ff ff ff       	call   800a53 <memmove>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad3:	f3 0f 1e fb          	endbr32 
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	89 c6                	mov    %eax,%esi
  800ae4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae7:	39 f0                	cmp    %esi,%eax
  800ae9:	74 1c                	je     800b07 <memcmp+0x34>
		if (*s1 != *s2)
  800aeb:	0f b6 08             	movzbl (%eax),%ecx
  800aee:	0f b6 1a             	movzbl (%edx),%ebx
  800af1:	38 d9                	cmp    %bl,%cl
  800af3:	75 08                	jne    800afd <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	eb ea                	jmp    800ae7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 c1             	movzbl %cl,%eax
  800b00:	0f b6 db             	movzbl %bl,%ebx
  800b03:	29 d8                	sub    %ebx,%eax
  800b05:	eb 05                	jmp    800b0c <memcmp+0x39>
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b10:	f3 0f 1e fb          	endbr32 
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	73 09                	jae    800b2f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	38 08                	cmp    %cl,(%eax)
  800b28:	74 05                	je     800b2f <memfind+0x1f>
	for (; s < ends; s++)
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	eb f3                	jmp    800b22 <memfind+0x12>
			break;
	return (void *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b31:	f3 0f 1e fb          	endbr32 
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b41:	eb 03                	jmp    800b46 <strtol+0x15>
		s++;
  800b43:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b46:	0f b6 01             	movzbl (%ecx),%eax
  800b49:	3c 20                	cmp    $0x20,%al
  800b4b:	74 f6                	je     800b43 <strtol+0x12>
  800b4d:	3c 09                	cmp    $0x9,%al
  800b4f:	74 f2                	je     800b43 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b51:	3c 2b                	cmp    $0x2b,%al
  800b53:	74 2a                	je     800b7f <strtol+0x4e>
	int neg = 0;
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	74 2b                	je     800b89 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b64:	75 0f                	jne    800b75 <strtol+0x44>
  800b66:	80 39 30             	cmpb   $0x30,(%ecx)
  800b69:	74 28                	je     800b93 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6b:	85 db                	test   %ebx,%ebx
  800b6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b72:	0f 44 d8             	cmove  %eax,%ebx
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7d:	eb 46                	jmp    800bc5 <strtol+0x94>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb d5                	jmp    800b5e <strtol+0x2d>
		s++, neg = 1;
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b91:	eb cb                	jmp    800b5e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b97:	74 0e                	je     800ba7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b99:	85 db                	test   %ebx,%ebx
  800b9b:	75 d8                	jne    800b75 <strtol+0x44>
		s++, base = 8;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba5:	eb ce                	jmp    800b75 <strtol+0x44>
		s += 2, base = 16;
  800ba7:	83 c1 02             	add    $0x2,%ecx
  800baa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800baf:	eb c4                	jmp    800b75 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bb1:	0f be d2             	movsbl %dl,%edx
  800bb4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bba:	7d 3a                	jge    800bf6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bbc:	83 c1 01             	add    $0x1,%ecx
  800bbf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc5:	0f b6 11             	movzbl (%ecx),%edx
  800bc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 09             	cmp    $0x9,%bl
  800bd0:	76 df                	jbe    800bb1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bd2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd5:	89 f3                	mov    %esi,%ebx
  800bd7:	80 fb 19             	cmp    $0x19,%bl
  800bda:	77 08                	ja     800be4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bdc:	0f be d2             	movsbl %dl,%edx
  800bdf:	83 ea 57             	sub    $0x57,%edx
  800be2:	eb d3                	jmp    800bb7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800be4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 19             	cmp    $0x19,%bl
  800bec:	77 08                	ja     800bf6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bee:	0f be d2             	movsbl %dl,%edx
  800bf1:	83 ea 37             	sub    $0x37,%edx
  800bf4:	eb c1                	jmp    800bb7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfa:	74 05                	je     800c01 <strtol+0xd0>
		*endptr = (char *) s;
  800bfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bff:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	f7 da                	neg    %edx
  800c05:	85 ff                	test   %edi,%edi
  800c07:	0f 45 c2             	cmovne %edx,%eax
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 1c             	sub    $0x1c,%esp
  800c18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c1e:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c26:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c29:	8b 75 14             	mov    0x14(%ebp),%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c32:	74 04                	je     800c38 <syscall+0x29>
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7f 08                	jg     800c40 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	ff 75 e0             	pushl  -0x20(%ebp)
  800c47:	68 1f 23 80 00       	push   $0x80231f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 3c 23 80 00       	push   $0x80233c
  800c53:	e8 f2 f5 ff ff       	call   80024a <_panic>

00800c58 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c58:	f3 0f 1e fb          	endbr32 
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c62:	6a 00                	push   $0x0
  800c64:	6a 00                	push   $0x0
  800c66:	6a 00                	push   $0x0
  800c68:	ff 75 0c             	pushl  0xc(%ebp)
  800c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	e8 92 ff ff ff       	call   800c0f <syscall>
}
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c82:	f3 0f 1e fb          	endbr32 
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c8c:	6a 00                	push   $0x0
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c99:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	e8 67 ff ff ff       	call   800c0f <syscall>
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800caa:	f3 0f 1e fb          	endbr32 
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800cb4:	6a 00                	push   $0x0
  800cb6:	6a 00                	push   $0x0
  800cb8:	6a 00                	push   $0x0
  800cba:	6a 00                	push   $0x0
  800cbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc4:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc9:	e8 41 ff ff ff       	call   800c0f <syscall>
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cda:	6a 00                	push   $0x0
  800cdc:	6a 00                	push   $0x0
  800cde:	6a 00                	push   $0x0
  800ce0:	6a 00                	push   $0x0
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf1:	e8 19 ff ff ff       	call   800c0f <syscall>
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <sys_yield>:

void
sys_yield(void)
{
  800cf8:	f3 0f 1e fb          	endbr32 
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	6a 00                	push   $0x0
  800d08:	6a 00                	push   $0x0
  800d0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d19:	e8 f1 fe ff ff       	call   800c0f <syscall>
}
  800d1e:	83 c4 10             	add    $0x10,%esp
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d23:	f3 0f 1e fb          	endbr32 
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	ff 75 10             	pushl  0x10(%ebp)
  800d34:	ff 75 0c             	pushl  0xc(%ebp)
  800d37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d44:	e8 c6 fe ff ff       	call   800c0f <syscall>
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d55:	ff 75 18             	pushl  0x18(%ebp)
  800d58:	ff 75 14             	pushl  0x14(%ebp)
  800d5b:	ff 75 10             	pushl  0x10(%ebp)
  800d5e:	ff 75 0c             	pushl  0xc(%ebp)
  800d61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d64:	ba 01 00 00 00       	mov    $0x1,%edx
  800d69:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6e:	e8 9c fe ff ff       	call   800c0f <syscall>
}
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d75:	f3 0f 1e fb          	endbr32 
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d7f:	6a 00                	push   $0x0
  800d81:	6a 00                	push   $0x0
  800d83:	6a 00                	push   $0x0
  800d85:	ff 75 0c             	pushl  0xc(%ebp)
  800d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8b:	ba 01 00 00 00       	mov    $0x1,%edx
  800d90:	b8 06 00 00 00       	mov    $0x6,%eax
  800d95:	e8 75 fe ff ff       	call   800c0f <syscall>
}
  800d9a:	c9                   	leave  
  800d9b:	c3                   	ret    

00800d9c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9c:	f3 0f 1e fb          	endbr32 
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800da6:	6a 00                	push   $0x0
  800da8:	6a 00                	push   $0x0
  800daa:	6a 00                	push   $0x0
  800dac:	ff 75 0c             	pushl  0xc(%ebp)
  800daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db2:	ba 01 00 00 00       	mov    $0x1,%edx
  800db7:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbc:	e8 4e fe ff ff       	call   800c0f <syscall>
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc3:	f3 0f 1e fb          	endbr32 
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dcd:	6a 00                	push   $0x0
  800dcf:	6a 00                	push   $0x0
  800dd1:	6a 00                	push   $0x0
  800dd3:	ff 75 0c             	pushl  0xc(%ebp)
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dde:	b8 09 00 00 00       	mov    $0x9,%eax
  800de3:	e8 27 fe ff ff       	call   800c0f <syscall>
}
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    

00800dea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dea:	f3 0f 1e fb          	endbr32 
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800df4:	6a 00                	push   $0x0
  800df6:	6a 00                	push   $0x0
  800df8:	6a 00                	push   $0x0
  800dfa:	ff 75 0c             	pushl  0xc(%ebp)
  800dfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e00:	ba 01 00 00 00       	mov    $0x1,%edx
  800e05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0a:	e8 00 fe ff ff       	call   800c0f <syscall>
}
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    

00800e11 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e11:	f3 0f 1e fb          	endbr32 
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e1b:	6a 00                	push   $0x0
  800e1d:	ff 75 14             	pushl  0x14(%ebp)
  800e20:	ff 75 10             	pushl  0x10(%ebp)
  800e23:	ff 75 0c             	pushl  0xc(%ebp)
  800e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e29:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e33:	e8 d7 fd ff ff       	call   800c0f <syscall>
}
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3a:	f3 0f 1e fb          	endbr32 
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e44:	6a 00                	push   $0x0
  800e46:	6a 00                	push   $0x0
  800e48:	6a 00                	push   $0x0
  800e4a:	6a 00                	push   $0x0
  800e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800e54:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e59:	e8 b1 fd ff ff       	call   800c0f <syscall>
}
  800e5e:	c9                   	leave  
  800e5f:	c3                   	ret    

00800e60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e60:	f3 0f 1e fb          	endbr32 
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e74:	f3 0f 1e fb          	endbr32 
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800e7e:	ff 75 08             	pushl  0x8(%ebp)
  800e81:	e8 da ff ff ff       	call   800e60 <fd2num>
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	c1 e0 0c             	shl    $0xc,%eax
  800e8c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e93:	f3 0f 1e fb          	endbr32 
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	c1 ea 16             	shr    $0x16,%edx
  800ea4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	74 2d                	je     800edd <fd_alloc+0x4a>
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	c1 ea 0c             	shr    $0xc,%edx
  800eb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	74 1c                	je     800edd <fd_alloc+0x4a>
  800ec1:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ec6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ecb:	75 d2                	jne    800e9f <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800ed6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800edb:	eb 0a                	jmp    800ee7 <fd_alloc+0x54>
			*fd_store = fd;
  800edd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ee9:	f3 0f 1e fb          	endbr32 
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef3:	83 f8 1f             	cmp    $0x1f,%eax
  800ef6:	77 30                	ja     800f28 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef8:	c1 e0 0c             	shl    $0xc,%eax
  800efb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f00:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f06:	f6 c2 01             	test   $0x1,%dl
  800f09:	74 24                	je     800f2f <fd_lookup+0x46>
  800f0b:	89 c2                	mov    %eax,%edx
  800f0d:	c1 ea 0c             	shr    $0xc,%edx
  800f10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	74 1a                	je     800f36 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
		return -E_INVAL;
  800f28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f2d:	eb f7                	jmp    800f26 <fd_lookup+0x3d>
		return -E_INVAL;
  800f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f34:	eb f0                	jmp    800f26 <fd_lookup+0x3d>
  800f36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3b:	eb e9                	jmp    800f26 <fd_lookup+0x3d>

00800f3d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f3d:	f3 0f 1e fb          	endbr32 
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4a:	ba c8 23 80 00       	mov    $0x8023c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f4f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f54:	39 08                	cmp    %ecx,(%eax)
  800f56:	74 33                	je     800f8b <dev_lookup+0x4e>
  800f58:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f5b:	8b 02                	mov    (%edx),%eax
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	75 f3                	jne    800f54 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f61:	a1 04 40 80 00       	mov    0x804004,%eax
  800f66:	8b 40 48             	mov    0x48(%eax),%eax
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	51                   	push   %ecx
  800f6d:	50                   	push   %eax
  800f6e:	68 4c 23 80 00       	push   $0x80234c
  800f73:	e8 b9 f3 ff ff       	call   800331 <cprintf>
	*dev = 0;
  800f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    
			*dev = devtab[i];
  800f8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	eb f2                	jmp    800f89 <dev_lookup+0x4c>

00800f97 <fd_close>:
{
  800f97:	f3 0f 1e fb          	endbr32 
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 28             	sub    $0x28,%esp
  800fa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800faa:	56                   	push   %esi
  800fab:	e8 b0 fe ff ff       	call   800e60 <fd2num>
  800fb0:	83 c4 08             	add    $0x8,%esp
  800fb3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800fb6:	52                   	push   %edx
  800fb7:	50                   	push   %eax
  800fb8:	e8 2c ff ff ff       	call   800ee9 <fd_lookup>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 05                	js     800fcb <fd_close+0x34>
	    || fd != fd2)
  800fc6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fc9:	74 16                	je     800fe1 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800fcb:	89 f8                	mov    %edi,%eax
  800fcd:	84 c0                	test   %al,%al
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	0f 44 d8             	cmove  %eax,%ebx
}
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 36                	pushl  (%esi)
  800fea:	e8 4e ff ff ff       	call   800f3d <dev_lookup>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 1a                	js     801012 <fd_close+0x7b>
		if (dev->dev_close)
  800ff8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ffb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801003:	85 c0                	test   %eax,%eax
  801005:	74 0b                	je     801012 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	56                   	push   %esi
  80100b:	ff d0                	call   *%eax
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	56                   	push   %esi
  801016:	6a 00                	push   $0x0
  801018:	e8 58 fd ff ff       	call   800d75 <sys_page_unmap>
	return r;
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	eb b5                	jmp    800fd7 <fd_close+0x40>

00801022 <close>:

int
close(int fdnum)
{
  801022:	f3 0f 1e fb          	endbr32 
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102f:	50                   	push   %eax
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 b1 fe ff ff       	call   800ee9 <fd_lookup>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 02                	jns    801041 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80103f:	c9                   	leave  
  801040:	c3                   	ret    
		return fd_close(fd, 1);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	6a 01                	push   $0x1
  801046:	ff 75 f4             	pushl  -0xc(%ebp)
  801049:	e8 49 ff ff ff       	call   800f97 <fd_close>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	eb ec                	jmp    80103f <close+0x1d>

00801053 <close_all>:

void
close_all(void)
{
  801053:	f3 0f 1e fb          	endbr32 
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	53                   	push   %ebx
  801067:	e8 b6 ff ff ff       	call   801022 <close>
	for (i = 0; i < MAXFD; i++)
  80106c:	83 c3 01             	add    $0x1,%ebx
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	83 fb 20             	cmp    $0x20,%ebx
  801075:	75 ec                	jne    801063 <close_all+0x10>
}
  801077:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107c:	f3 0f 1e fb          	endbr32 
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801089:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	ff 75 08             	pushl  0x8(%ebp)
  801090:	e8 54 fe ff ff       	call   800ee9 <fd_lookup>
  801095:	89 c3                	mov    %eax,%ebx
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	0f 88 81 00 00 00    	js     801123 <dup+0xa7>
		return r;
	close(newfdnum);
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	ff 75 0c             	pushl  0xc(%ebp)
  8010a8:	e8 75 ff ff ff       	call   801022 <close>

	newfd = INDEX2FD(newfdnum);
  8010ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b0:	c1 e6 0c             	shl    $0xc,%esi
  8010b3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010b9:	83 c4 04             	add    $0x4,%esp
  8010bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bf:	e8 b0 fd ff ff       	call   800e74 <fd2data>
  8010c4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010c6:	89 34 24             	mov    %esi,(%esp)
  8010c9:	e8 a6 fd ff ff       	call   800e74 <fd2data>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	c1 e8 16             	shr    $0x16,%eax
  8010d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 11                	je     8010f4 <dup+0x78>
  8010e3:	89 d8                	mov    %ebx,%eax
  8010e5:	c1 e8 0c             	shr    $0xc,%eax
  8010e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ef:	f6 c2 01             	test   $0x1,%dl
  8010f2:	75 39                	jne    80112d <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f7:	89 d0                	mov    %edx,%eax
  8010f9:	c1 e8 0c             	shr    $0xc,%eax
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	25 07 0e 00 00       	and    $0xe07,%eax
  80110b:	50                   	push   %eax
  80110c:	56                   	push   %esi
  80110d:	6a 00                	push   $0x0
  80110f:	52                   	push   %edx
  801110:	6a 00                	push   $0x0
  801112:	e8 34 fc ff ff       	call   800d4b <sys_page_map>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 31                	js     801151 <dup+0xd5>
		goto err;

	return newfdnum;
  801120:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801123:	89 d8                	mov    %ebx,%eax
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	25 07 0e 00 00       	and    $0xe07,%eax
  80113c:	50                   	push   %eax
  80113d:	57                   	push   %edi
  80113e:	6a 00                	push   $0x0
  801140:	53                   	push   %ebx
  801141:	6a 00                	push   $0x0
  801143:	e8 03 fc ff ff       	call   800d4b <sys_page_map>
  801148:	89 c3                	mov    %eax,%ebx
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 a3                	jns    8010f4 <dup+0x78>
	sys_page_unmap(0, newfd);
  801151:	83 ec 08             	sub    $0x8,%esp
  801154:	56                   	push   %esi
  801155:	6a 00                	push   $0x0
  801157:	e8 19 fc ff ff       	call   800d75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115c:	83 c4 08             	add    $0x8,%esp
  80115f:	57                   	push   %edi
  801160:	6a 00                	push   $0x0
  801162:	e8 0e fc ff ff       	call   800d75 <sys_page_unmap>
	return r;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	eb b7                	jmp    801123 <dup+0xa7>

0080116c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80116c:	f3 0f 1e fb          	endbr32 
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	53                   	push   %ebx
  80117f:	e8 65 fd ff ff       	call   800ee9 <fd_lookup>
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	78 3f                	js     8011ca <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801191:	50                   	push   %eax
  801192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801195:	ff 30                	pushl  (%eax)
  801197:	e8 a1 fd ff ff       	call   800f3d <dev_lookup>
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 27                	js     8011ca <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a6:	8b 42 08             	mov    0x8(%edx),%eax
  8011a9:	83 e0 03             	and    $0x3,%eax
  8011ac:	83 f8 01             	cmp    $0x1,%eax
  8011af:	74 1e                	je     8011cf <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b4:	8b 40 08             	mov    0x8(%eax),%eax
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	74 35                	je     8011f0 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	ff 75 10             	pushl  0x10(%ebp)
  8011c1:	ff 75 0c             	pushl  0xc(%ebp)
  8011c4:	52                   	push   %edx
  8011c5:	ff d0                	call   *%eax
  8011c7:	83 c4 10             	add    $0x10,%esp
}
  8011ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d4:	8b 40 48             	mov    0x48(%eax),%eax
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	53                   	push   %ebx
  8011db:	50                   	push   %eax
  8011dc:	68 8d 23 80 00       	push   $0x80238d
  8011e1:	e8 4b f1 ff ff       	call   800331 <cprintf>
		return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ee:	eb da                	jmp    8011ca <read+0x5e>
		return -E_NOT_SUPP;
  8011f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f5:	eb d3                	jmp    8011ca <read+0x5e>

008011f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f7:	f3 0f 1e fb          	endbr32 
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	8b 7d 08             	mov    0x8(%ebp),%edi
  801207:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120f:	eb 02                	jmp    801213 <readn+0x1c>
  801211:	01 c3                	add    %eax,%ebx
  801213:	39 f3                	cmp    %esi,%ebx
  801215:	73 21                	jae    801238 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	89 f0                	mov    %esi,%eax
  80121c:	29 d8                	sub    %ebx,%eax
  80121e:	50                   	push   %eax
  80121f:	89 d8                	mov    %ebx,%eax
  801221:	03 45 0c             	add    0xc(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	57                   	push   %edi
  801226:	e8 41 ff ff ff       	call   80116c <read>
		if (m < 0)
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 04                	js     801236 <readn+0x3f>
			return m;
		if (m == 0)
  801232:	75 dd                	jne    801211 <readn+0x1a>
  801234:	eb 02                	jmp    801238 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801236:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801238:	89 d8                	mov    %ebx,%eax
  80123a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5f                   	pop    %edi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801242:	f3 0f 1e fb          	endbr32 
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	53                   	push   %ebx
  80124a:	83 ec 1c             	sub    $0x1c,%esp
  80124d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801250:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	53                   	push   %ebx
  801255:	e8 8f fc ff ff       	call   800ee9 <fd_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 3a                	js     80129b <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126b:	ff 30                	pushl  (%eax)
  80126d:	e8 cb fc ff ff       	call   800f3d <dev_lookup>
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 22                	js     80129b <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801280:	74 1e                	je     8012a0 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801285:	8b 52 0c             	mov    0xc(%edx),%edx
  801288:	85 d2                	test   %edx,%edx
  80128a:	74 35                	je     8012c1 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	ff 75 10             	pushl  0x10(%ebp)
  801292:	ff 75 0c             	pushl  0xc(%ebp)
  801295:	50                   	push   %eax
  801296:	ff d2                	call   *%edx
  801298:	83 c4 10             	add    $0x10,%esp
}
  80129b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a5:	8b 40 48             	mov    0x48(%eax),%eax
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	50                   	push   %eax
  8012ad:	68 a9 23 80 00       	push   $0x8023a9
  8012b2:	e8 7a f0 ff ff       	call   800331 <cprintf>
		return -E_INVAL;
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bf:	eb da                	jmp    80129b <write+0x59>
		return -E_NOT_SUPP;
  8012c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c6:	eb d3                	jmp    80129b <write+0x59>

008012c8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c8:	f3 0f 1e fb          	endbr32 
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	ff 75 08             	pushl  0x8(%ebp)
  8012d9:	e8 0b fc ff ff       	call   800ee9 <fd_lookup>
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 0e                	js     8012f3 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8012e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    

008012f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f5:	f3 0f 1e fb          	endbr32 
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 1c             	sub    $0x1c,%esp
  801300:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	53                   	push   %ebx
  801308:	e8 dc fb ff ff       	call   800ee9 <fd_lookup>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 37                	js     80134b <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131e:	ff 30                	pushl  (%eax)
  801320:	e8 18 fc ff ff       	call   800f3d <dev_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 1f                	js     80134b <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801333:	74 1b                	je     801350 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801335:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801338:	8b 52 18             	mov    0x18(%edx),%edx
  80133b:	85 d2                	test   %edx,%edx
  80133d:	74 32                	je     801371 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	ff 75 0c             	pushl  0xc(%ebp)
  801345:	50                   	push   %eax
  801346:	ff d2                	call   *%edx
  801348:	83 c4 10             	add    $0x10,%esp
}
  80134b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801350:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801355:	8b 40 48             	mov    0x48(%eax),%eax
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	53                   	push   %ebx
  80135c:	50                   	push   %eax
  80135d:	68 6c 23 80 00       	push   $0x80236c
  801362:	e8 ca ef ff ff       	call   800331 <cprintf>
		return -E_INVAL;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136f:	eb da                	jmp    80134b <ftruncate+0x56>
		return -E_NOT_SUPP;
  801371:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801376:	eb d3                	jmp    80134b <ftruncate+0x56>

00801378 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801378:	f3 0f 1e fb          	endbr32 
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 1c             	sub    $0x1c,%esp
  801383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801386:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 57 fb ff ff       	call   800ee9 <fd_lookup>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 4b                	js     8013e4 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a3:	ff 30                	pushl  (%eax)
  8013a5:	e8 93 fb ff ff       	call   800f3d <dev_lookup>
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 33                	js     8013e4 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b8:	74 2f                	je     8013e9 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c4:	00 00 00 
	stat->st_isdir = 0;
  8013c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ce:	00 00 00 
	stat->st_dev = dev;
  8013d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	53                   	push   %ebx
  8013db:	ff 75 f0             	pushl  -0x10(%ebp)
  8013de:	ff 50 14             	call   *0x14(%eax)
  8013e1:	83 c4 10             	add    $0x10,%esp
}
  8013e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    
		return -E_NOT_SUPP;
  8013e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ee:	eb f4                	jmp    8013e4 <fstat+0x6c>

008013f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f0:	f3 0f 1e fb          	endbr32 
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	6a 00                	push   $0x0
  8013fe:	ff 75 08             	pushl  0x8(%ebp)
  801401:	e8 fb 01 00 00       	call   801601 <open>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 1b                	js     80142a <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	ff 75 0c             	pushl  0xc(%ebp)
  801415:	50                   	push   %eax
  801416:	e8 5d ff ff ff       	call   801378 <fstat>
  80141b:	89 c6                	mov    %eax,%esi
	close(fd);
  80141d:	89 1c 24             	mov    %ebx,(%esp)
  801420:	e8 fd fb ff ff       	call   801022 <close>
	return r;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	89 f3                	mov    %esi,%ebx
}
  80142a:	89 d8                	mov    %ebx,%eax
  80142c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	89 c6                	mov    %eax,%esi
  80143a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801443:	74 27                	je     80146c <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801445:	6a 07                	push   $0x7
  801447:	68 00 50 80 00       	push   $0x805000
  80144c:	56                   	push   %esi
  80144d:	ff 35 00 40 80 00    	pushl  0x804000
  801453:	e8 bf 07 00 00       	call   801c17 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801458:	83 c4 0c             	add    $0xc,%esp
  80145b:	6a 00                	push   $0x0
  80145d:	53                   	push   %ebx
  80145e:	6a 00                	push   $0x0
  801460:	e8 44 07 00 00       	call   801ba9 <ipc_recv>
}
  801465:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	6a 01                	push   $0x1
  801471:	e8 06 08 00 00       	call   801c7c <ipc_find_env>
  801476:	a3 00 40 80 00       	mov    %eax,0x804000
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	eb c5                	jmp    801445 <fsipc+0x12>

00801480 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801480:	f3 0f 1e fb          	endbr32 
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	8b 40 0c             	mov    0xc(%eax),%eax
  801490:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801495:	8b 45 0c             	mov    0xc(%ebp),%eax
  801498:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a7:	e8 87 ff ff ff       	call   801433 <fsipc>
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <devfile_flush>:
{
  8014ae:	f3 0f 1e fb          	endbr32 
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8014cd:	e8 61 ff ff ff       	call   801433 <fsipc>
}
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <devfile_stat>:
{
  8014d4:	f3 0f 1e fb          	endbr32 
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	53                   	push   %ebx
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f7:	e8 37 ff ff ff       	call   801433 <fsipc>
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 2c                	js     80152c <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	68 00 50 80 00       	push   $0x805000
  801508:	53                   	push   %ebx
  801509:	e8 8d f3 ff ff       	call   80089b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80150e:	a1 80 50 80 00       	mov    0x805080,%eax
  801513:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801519:	a1 84 50 80 00       	mov    0x805084,%eax
  80151e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devfile_write>:
{
  801531:	f3 0f 1e fb          	endbr32 
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80153e:	8b 55 08             	mov    0x8(%ebp),%edx
  801541:	8b 52 0c             	mov    0xc(%edx),%edx
  801544:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80154a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80154f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801554:	0f 47 c2             	cmova  %edx,%eax
  801557:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80155c:	50                   	push   %eax
  80155d:	ff 75 0c             	pushl  0xc(%ebp)
  801560:	68 08 50 80 00       	push   $0x805008
  801565:	e8 e9 f4 ff ff       	call   800a53 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80156a:	ba 00 00 00 00       	mov    $0x0,%edx
  80156f:	b8 04 00 00 00       	mov    $0x4,%eax
  801574:	e8 ba fe ff ff       	call   801433 <fsipc>
}
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <devfile_read>:
{
  80157b:	f3 0f 1e fb          	endbr32 
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
  801584:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	8b 40 0c             	mov    0xc(%eax),%eax
  80158d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801592:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801598:	ba 00 00 00 00       	mov    $0x0,%edx
  80159d:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a2:	e8 8c fe ff ff       	call   801433 <fsipc>
  8015a7:	89 c3                	mov    %eax,%ebx
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 1f                	js     8015cc <devfile_read+0x51>
	assert(r <= n);
  8015ad:	39 f0                	cmp    %esi,%eax
  8015af:	77 24                	ja     8015d5 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015b1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b6:	7f 33                	jg     8015eb <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	50                   	push   %eax
  8015bc:	68 00 50 80 00       	push   $0x805000
  8015c1:	ff 75 0c             	pushl  0xc(%ebp)
  8015c4:	e8 8a f4 ff ff       	call   800a53 <memmove>
	return r;
  8015c9:	83 c4 10             	add    $0x10,%esp
}
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    
	assert(r <= n);
  8015d5:	68 d8 23 80 00       	push   $0x8023d8
  8015da:	68 df 23 80 00       	push   $0x8023df
  8015df:	6a 7c                	push   $0x7c
  8015e1:	68 f4 23 80 00       	push   $0x8023f4
  8015e6:	e8 5f ec ff ff       	call   80024a <_panic>
	assert(r <= PGSIZE);
  8015eb:	68 ff 23 80 00       	push   $0x8023ff
  8015f0:	68 df 23 80 00       	push   $0x8023df
  8015f5:	6a 7d                	push   $0x7d
  8015f7:	68 f4 23 80 00       	push   $0x8023f4
  8015fc:	e8 49 ec ff ff       	call   80024a <_panic>

00801601 <open>:
{
  801601:	f3 0f 1e fb          	endbr32 
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
  80160a:	83 ec 1c             	sub    $0x1c,%esp
  80160d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801610:	56                   	push   %esi
  801611:	e8 42 f2 ff ff       	call   800858 <strlen>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80161e:	7f 6c                	jg     80168c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	e8 67 f8 ff ff       	call   800e93 <fd_alloc>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 3c                	js     801671 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	56                   	push   %esi
  801639:	68 00 50 80 00       	push   $0x805000
  80163e:	e8 58 f2 ff ff       	call   80089b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801643:	8b 45 0c             	mov    0xc(%ebp),%eax
  801646:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80164b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164e:	b8 01 00 00 00       	mov    $0x1,%eax
  801653:	e8 db fd ff ff       	call   801433 <fsipc>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 19                	js     80167a <open+0x79>
	return fd2num(fd);
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	ff 75 f4             	pushl  -0xc(%ebp)
  801667:	e8 f4 f7 ff ff       	call   800e60 <fd2num>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
}
  801671:	89 d8                	mov    %ebx,%eax
  801673:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801676:	5b                   	pop    %ebx
  801677:	5e                   	pop    %esi
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    
		fd_close(fd, 0);
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	6a 00                	push   $0x0
  80167f:	ff 75 f4             	pushl  -0xc(%ebp)
  801682:	e8 10 f9 ff ff       	call   800f97 <fd_close>
		return r;
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb e5                	jmp    801671 <open+0x70>
		return -E_BAD_PATH;
  80168c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801691:	eb de                	jmp    801671 <open+0x70>

00801693 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801693:	f3 0f 1e fb          	endbr32 
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a7:	e8 87 fd ff ff       	call   801433 <fsipc>
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016ae:	f3 0f 1e fb          	endbr32 
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	56                   	push   %esi
  8016b6:	53                   	push   %ebx
  8016b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 af f7 ff ff       	call   800e74 <fd2data>
  8016c5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016c7:	83 c4 08             	add    $0x8,%esp
  8016ca:	68 0b 24 80 00       	push   $0x80240b
  8016cf:	53                   	push   %ebx
  8016d0:	e8 c6 f1 ff ff       	call   80089b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016d5:	8b 46 04             	mov    0x4(%esi),%eax
  8016d8:	2b 06                	sub    (%esi),%eax
  8016da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016e0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e7:	00 00 00 
	stat->st_dev = &devpipe;
  8016ea:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016f1:	30 80 00 
	return 0;
}
  8016f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5e                   	pop    %esi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801700:	f3 0f 1e fb          	endbr32 
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	83 ec 0c             	sub    $0xc,%esp
  80170b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80170e:	53                   	push   %ebx
  80170f:	6a 00                	push   $0x0
  801711:	e8 5f f6 ff ff       	call   800d75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801716:	89 1c 24             	mov    %ebx,(%esp)
  801719:	e8 56 f7 ff ff       	call   800e74 <fd2data>
  80171e:	83 c4 08             	add    $0x8,%esp
  801721:	50                   	push   %eax
  801722:	6a 00                	push   $0x0
  801724:	e8 4c f6 ff ff       	call   800d75 <sys_page_unmap>
}
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <_pipeisclosed>:
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	57                   	push   %edi
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
  801734:	83 ec 1c             	sub    $0x1c,%esp
  801737:	89 c7                	mov    %eax,%edi
  801739:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80173b:	a1 04 40 80 00       	mov    0x804004,%eax
  801740:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	57                   	push   %edi
  801747:	e8 6d 05 00 00       	call   801cb9 <pageref>
  80174c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80174f:	89 34 24             	mov    %esi,(%esp)
  801752:	e8 62 05 00 00       	call   801cb9 <pageref>
		nn = thisenv->env_runs;
  801757:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80175d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	39 cb                	cmp    %ecx,%ebx
  801765:	74 1b                	je     801782 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801767:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80176a:	75 cf                	jne    80173b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80176c:	8b 42 58             	mov    0x58(%edx),%eax
  80176f:	6a 01                	push   $0x1
  801771:	50                   	push   %eax
  801772:	53                   	push   %ebx
  801773:	68 12 24 80 00       	push   $0x802412
  801778:	e8 b4 eb ff ff       	call   800331 <cprintf>
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	eb b9                	jmp    80173b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801782:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801785:	0f 94 c0             	sete   %al
  801788:	0f b6 c0             	movzbl %al,%eax
}
  80178b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5f                   	pop    %edi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <devpipe_write>:
{
  801793:	f3 0f 1e fb          	endbr32 
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	57                   	push   %edi
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 28             	sub    $0x28,%esp
  8017a0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8017a3:	56                   	push   %esi
  8017a4:	e8 cb f6 ff ff       	call   800e74 <fd2data>
  8017a9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8017b3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017b6:	74 4f                	je     801807 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017b8:	8b 43 04             	mov    0x4(%ebx),%eax
  8017bb:	8b 0b                	mov    (%ebx),%ecx
  8017bd:	8d 51 20             	lea    0x20(%ecx),%edx
  8017c0:	39 d0                	cmp    %edx,%eax
  8017c2:	72 14                	jb     8017d8 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8017c4:	89 da                	mov    %ebx,%edx
  8017c6:	89 f0                	mov    %esi,%eax
  8017c8:	e8 61 ff ff ff       	call   80172e <_pipeisclosed>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	75 3b                	jne    80180c <devpipe_write+0x79>
			sys_yield();
  8017d1:	e8 22 f5 ff ff       	call   800cf8 <sys_yield>
  8017d6:	eb e0                	jmp    8017b8 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017db:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017df:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	c1 fa 1f             	sar    $0x1f,%edx
  8017e7:	89 d1                	mov    %edx,%ecx
  8017e9:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ec:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017ef:	83 e2 1f             	and    $0x1f,%edx
  8017f2:	29 ca                	sub    %ecx,%edx
  8017f4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017fc:	83 c0 01             	add    $0x1,%eax
  8017ff:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801802:	83 c7 01             	add    $0x1,%edi
  801805:	eb ac                	jmp    8017b3 <devpipe_write+0x20>
	return i;
  801807:	8b 45 10             	mov    0x10(%ebp),%eax
  80180a:	eb 05                	jmp    801811 <devpipe_write+0x7e>
				return 0;
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801811:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801814:	5b                   	pop    %ebx
  801815:	5e                   	pop    %esi
  801816:	5f                   	pop    %edi
  801817:	5d                   	pop    %ebp
  801818:	c3                   	ret    

00801819 <devpipe_read>:
{
  801819:	f3 0f 1e fb          	endbr32 
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	83 ec 18             	sub    $0x18,%esp
  801826:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801829:	57                   	push   %edi
  80182a:	e8 45 f6 ff ff       	call   800e74 <fd2data>
  80182f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	be 00 00 00 00       	mov    $0x0,%esi
  801839:	3b 75 10             	cmp    0x10(%ebp),%esi
  80183c:	75 14                	jne    801852 <devpipe_read+0x39>
	return i;
  80183e:	8b 45 10             	mov    0x10(%ebp),%eax
  801841:	eb 02                	jmp    801845 <devpipe_read+0x2c>
				return i;
  801843:	89 f0                	mov    %esi,%eax
}
  801845:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801848:	5b                   	pop    %ebx
  801849:	5e                   	pop    %esi
  80184a:	5f                   	pop    %edi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    
			sys_yield();
  80184d:	e8 a6 f4 ff ff       	call   800cf8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801852:	8b 03                	mov    (%ebx),%eax
  801854:	3b 43 04             	cmp    0x4(%ebx),%eax
  801857:	75 18                	jne    801871 <devpipe_read+0x58>
			if (i > 0)
  801859:	85 f6                	test   %esi,%esi
  80185b:	75 e6                	jne    801843 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80185d:	89 da                	mov    %ebx,%edx
  80185f:	89 f8                	mov    %edi,%eax
  801861:	e8 c8 fe ff ff       	call   80172e <_pipeisclosed>
  801866:	85 c0                	test   %eax,%eax
  801868:	74 e3                	je     80184d <devpipe_read+0x34>
				return 0;
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
  80186f:	eb d4                	jmp    801845 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801871:	99                   	cltd   
  801872:	c1 ea 1b             	shr    $0x1b,%edx
  801875:	01 d0                	add    %edx,%eax
  801877:	83 e0 1f             	and    $0x1f,%eax
  80187a:	29 d0                	sub    %edx,%eax
  80187c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801884:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801887:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80188a:	83 c6 01             	add    $0x1,%esi
  80188d:	eb aa                	jmp    801839 <devpipe_read+0x20>

0080188f <pipe>:
{
  80188f:	f3 0f 1e fb          	endbr32 
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80189b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189e:	50                   	push   %eax
  80189f:	e8 ef f5 ff ff       	call   800e93 <fd_alloc>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	0f 88 23 01 00 00    	js     8019d4 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b1:	83 ec 04             	sub    $0x4,%esp
  8018b4:	68 07 04 00 00       	push   $0x407
  8018b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bc:	6a 00                	push   $0x0
  8018be:	e8 60 f4 ff ff       	call   800d23 <sys_page_alloc>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 88 04 01 00 00    	js     8019d4 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8018d0:	83 ec 0c             	sub    $0xc,%esp
  8018d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d6:	50                   	push   %eax
  8018d7:	e8 b7 f5 ff ff       	call   800e93 <fd_alloc>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	0f 88 db 00 00 00    	js     8019c4 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	68 07 04 00 00       	push   $0x407
  8018f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f4:	6a 00                	push   $0x0
  8018f6:	e8 28 f4 ff ff       	call   800d23 <sys_page_alloc>
  8018fb:	89 c3                	mov    %eax,%ebx
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	85 c0                	test   %eax,%eax
  801902:	0f 88 bc 00 00 00    	js     8019c4 <pipe+0x135>
	va = fd2data(fd0);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 61 f5 ff ff       	call   800e74 <fd2data>
  801913:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801915:	83 c4 0c             	add    $0xc,%esp
  801918:	68 07 04 00 00       	push   $0x407
  80191d:	50                   	push   %eax
  80191e:	6a 00                	push   $0x0
  801920:	e8 fe f3 ff ff       	call   800d23 <sys_page_alloc>
  801925:	89 c3                	mov    %eax,%ebx
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	85 c0                	test   %eax,%eax
  80192c:	0f 88 82 00 00 00    	js     8019b4 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	ff 75 f0             	pushl  -0x10(%ebp)
  801938:	e8 37 f5 ff ff       	call   800e74 <fd2data>
  80193d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801944:	50                   	push   %eax
  801945:	6a 00                	push   $0x0
  801947:	56                   	push   %esi
  801948:	6a 00                	push   $0x0
  80194a:	e8 fc f3 ff ff       	call   800d4b <sys_page_map>
  80194f:	89 c3                	mov    %eax,%ebx
  801951:	83 c4 20             	add    $0x20,%esp
  801954:	85 c0                	test   %eax,%eax
  801956:	78 4e                	js     8019a6 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801958:	a1 20 30 80 00       	mov    0x803020,%eax
  80195d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801960:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801962:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801965:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80196c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80196f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801974:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	ff 75 f4             	pushl  -0xc(%ebp)
  801981:	e8 da f4 ff ff       	call   800e60 <fd2num>
  801986:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801989:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80198b:	83 c4 04             	add    $0x4,%esp
  80198e:	ff 75 f0             	pushl  -0x10(%ebp)
  801991:	e8 ca f4 ff ff       	call   800e60 <fd2num>
  801996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801999:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a4:	eb 2e                	jmp    8019d4 <pipe+0x145>
	sys_page_unmap(0, va);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	56                   	push   %esi
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 c4 f3 ff ff       	call   800d75 <sys_page_unmap>
  8019b1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 b4 f3 ff ff       	call   800d75 <sys_page_unmap>
  8019c1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ca:	6a 00                	push   $0x0
  8019cc:	e8 a4 f3 ff ff       	call   800d75 <sys_page_unmap>
  8019d1:	83 c4 10             	add    $0x10,%esp
}
  8019d4:	89 d8                	mov    %ebx,%eax
  8019d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <pipeisclosed>:
{
  8019dd:	f3 0f 1e fb          	endbr32 
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	ff 75 08             	pushl  0x8(%ebp)
  8019ee:	e8 f6 f4 ff ff       	call   800ee9 <fd_lookup>
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 18                	js     801a12 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 6f f4 ff ff       	call   800e74 <fd2data>
  801a05:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0a:	e8 1f fd ff ff       	call   80172e <_pipeisclosed>
  801a0f:	83 c4 10             	add    $0x10,%esp
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a14:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1d:	c3                   	ret    

00801a1e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a1e:	f3 0f 1e fb          	endbr32 
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a28:	68 2a 24 80 00       	push   $0x80242a
  801a2d:	ff 75 0c             	pushl  0xc(%ebp)
  801a30:	e8 66 ee ff ff       	call   80089b <strcpy>
	return 0;
}
  801a35:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <devcons_write>:
{
  801a3c:	f3 0f 1e fb          	endbr32 
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	57                   	push   %edi
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a4c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a51:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a57:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a5a:	73 31                	jae    801a8d <devcons_write+0x51>
		m = n - tot;
  801a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a5f:	29 f3                	sub    %esi,%ebx
  801a61:	83 fb 7f             	cmp    $0x7f,%ebx
  801a64:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a69:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	53                   	push   %ebx
  801a70:	89 f0                	mov    %esi,%eax
  801a72:	03 45 0c             	add    0xc(%ebp),%eax
  801a75:	50                   	push   %eax
  801a76:	57                   	push   %edi
  801a77:	e8 d7 ef ff ff       	call   800a53 <memmove>
		sys_cputs(buf, m);
  801a7c:	83 c4 08             	add    $0x8,%esp
  801a7f:	53                   	push   %ebx
  801a80:	57                   	push   %edi
  801a81:	e8 d2 f1 ff ff       	call   800c58 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a86:	01 de                	add    %ebx,%esi
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb ca                	jmp    801a57 <devcons_write+0x1b>
}
  801a8d:	89 f0                	mov    %esi,%eax
  801a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <devcons_read>:
{
  801a97:	f3 0f 1e fb          	endbr32 
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 08             	sub    $0x8,%esp
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801aa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aaa:	74 21                	je     801acd <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801aac:	e8 d1 f1 ff ff       	call   800c82 <sys_cgetc>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 07                	jne    801abc <devcons_read+0x25>
		sys_yield();
  801ab5:	e8 3e f2 ff ff       	call   800cf8 <sys_yield>
  801aba:	eb f0                	jmp    801aac <devcons_read+0x15>
	if (c < 0)
  801abc:	78 0f                	js     801acd <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801abe:	83 f8 04             	cmp    $0x4,%eax
  801ac1:	74 0c                	je     801acf <devcons_read+0x38>
	*(char*)vbuf = c;
  801ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac6:	88 02                	mov    %al,(%edx)
	return 1;
  801ac8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    
		return 0;
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	eb f7                	jmp    801acd <devcons_read+0x36>

00801ad6 <cputchar>:
{
  801ad6:	f3 0f 1e fb          	endbr32 
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ae6:	6a 01                	push   $0x1
  801ae8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	e8 67 f1 ff ff       	call   800c58 <sys_cputs>
}
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <getchar>:
{
  801af6:	f3 0f 1e fb          	endbr32 
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b00:	6a 01                	push   $0x1
  801b02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	6a 00                	push   $0x0
  801b08:	e8 5f f6 ff ff       	call   80116c <read>
	if (r < 0)
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 06                	js     801b1a <getchar+0x24>
	if (r < 1)
  801b14:	74 06                	je     801b1c <getchar+0x26>
	return c;
  801b16:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    
		return -E_EOF;
  801b1c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b21:	eb f7                	jmp    801b1a <getchar+0x24>

00801b23 <iscons>:
{
  801b23:	f3 0f 1e fb          	endbr32 
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	ff 75 08             	pushl  0x8(%ebp)
  801b34:	e8 b0 f3 ff ff       	call   800ee9 <fd_lookup>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 11                	js     801b51 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b43:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b49:	39 10                	cmp    %edx,(%eax)
  801b4b:	0f 94 c0             	sete   %al
  801b4e:	0f b6 c0             	movzbl %al,%eax
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <opencons>:
{
  801b53:	f3 0f 1e fb          	endbr32 
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	e8 2d f3 ff ff       	call   800e93 <fd_alloc>
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 3a                	js     801ba7 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	68 07 04 00 00       	push   $0x407
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 a4 f1 ff ff       	call   800d23 <sys_page_alloc>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 21                	js     801ba7 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b8f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	50                   	push   %eax
  801b9f:	e8 bc f2 ff ff       	call   800e60 <fd2num>
  801ba4:	83 c4 10             	add    $0x10,%esp
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ba9:	f3 0f 1e fb          	endbr32 
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bc2:	0f 44 c2             	cmove  %edx,%eax
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	50                   	push   %eax
  801bc9:	e8 6c f2 ff ff       	call   800e3a <sys_ipc_recv>

	if (from_env_store != NULL)
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 f6                	test   %esi,%esi
  801bd3:	74 15                	je     801bea <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bda:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801bdd:	74 09                	je     801be8 <ipc_recv+0x3f>
  801bdf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801be5:	8b 52 74             	mov    0x74(%edx),%edx
  801be8:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801bea:	85 db                	test   %ebx,%ebx
  801bec:	74 15                	je     801c03 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801bee:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf3:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801bf6:	74 09                	je     801c01 <ipc_recv+0x58>
  801bf8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bfe:	8b 52 78             	mov    0x78(%edx),%edx
  801c01:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801c03:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801c06:	74 08                	je     801c10 <ipc_recv+0x67>
  801c08:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c17:	f3 0f 1e fb          	endbr32 
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	57                   	push   %edi
  801c1f:	56                   	push   %esi
  801c20:	53                   	push   %ebx
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c27:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c2d:	eb 1f                	jmp    801c4e <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801c2f:	6a 00                	push   $0x0
  801c31:	68 00 00 c0 ee       	push   $0xeec00000
  801c36:	56                   	push   %esi
  801c37:	57                   	push   %edi
  801c38:	e8 d4 f1 ff ff       	call   800e11 <sys_ipc_try_send>
  801c3d:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801c40:	85 c0                	test   %eax,%eax
  801c42:	74 30                	je     801c74 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801c44:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c47:	75 19                	jne    801c62 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801c49:	e8 aa f0 ff ff       	call   800cf8 <sys_yield>
		if (pg != NULL) {
  801c4e:	85 db                	test   %ebx,%ebx
  801c50:	74 dd                	je     801c2f <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801c52:	ff 75 14             	pushl  0x14(%ebp)
  801c55:	53                   	push   %ebx
  801c56:	56                   	push   %esi
  801c57:	57                   	push   %edi
  801c58:	e8 b4 f1 ff ff       	call   800e11 <sys_ipc_try_send>
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	eb de                	jmp    801c40 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801c62:	50                   	push   %eax
  801c63:	68 36 24 80 00       	push   $0x802436
  801c68:	6a 3e                	push   $0x3e
  801c6a:	68 43 24 80 00       	push   $0x802443
  801c6f:	e8 d6 e5 ff ff       	call   80024a <_panic>
	}
}
  801c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5f                   	pop    %edi
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    

00801c7c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c7c:	f3 0f 1e fb          	endbr32 
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c8b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c8e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c94:	8b 52 50             	mov    0x50(%edx),%edx
  801c97:	39 ca                	cmp    %ecx,%edx
  801c99:	74 11                	je     801cac <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c9b:	83 c0 01             	add    $0x1,%eax
  801c9e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ca3:	75 e6                	jne    801c8b <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  801caa:	eb 0b                	jmp    801cb7 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801cac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801caf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cb4:	8b 40 48             	mov    0x48(%eax),%eax
}
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cb9:	f3 0f 1e fb          	endbr32 
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	c1 ea 16             	shr    $0x16,%edx
  801cc8:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ccf:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cd4:	f6 c1 01             	test   $0x1,%cl
  801cd7:	74 1c                	je     801cf5 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801cd9:	c1 e8 0c             	shr    $0xc,%eax
  801cdc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ce3:	a8 01                	test   $0x1,%al
  801ce5:	74 0e                	je     801cf5 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ce7:	c1 e8 0c             	shr    $0xc,%eax
  801cea:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801cf1:	ef 
  801cf2:	0f b7 d2             	movzwl %dx,%edx
}
  801cf5:	89 d0                	mov    %edx,%eax
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	66 90                	xchg   %ax,%ax
  801cfb:	66 90                	xchg   %ax,%ax
  801cfd:	66 90                	xchg   %ax,%ax
  801cff:	90                   	nop

00801d00 <__udivdi3>:
  801d00:	f3 0f 1e fb          	endbr32 
  801d04:	55                   	push   %ebp
  801d05:	57                   	push   %edi
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	83 ec 1c             	sub    $0x1c,%esp
  801d0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d13:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d1b:	85 d2                	test   %edx,%edx
  801d1d:	75 19                	jne    801d38 <__udivdi3+0x38>
  801d1f:	39 f3                	cmp    %esi,%ebx
  801d21:	76 4d                	jbe    801d70 <__udivdi3+0x70>
  801d23:	31 ff                	xor    %edi,%edi
  801d25:	89 e8                	mov    %ebp,%eax
  801d27:	89 f2                	mov    %esi,%edx
  801d29:	f7 f3                	div    %ebx
  801d2b:	89 fa                	mov    %edi,%edx
  801d2d:	83 c4 1c             	add    $0x1c,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    
  801d35:	8d 76 00             	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	76 14                	jbe    801d50 <__udivdi3+0x50>
  801d3c:	31 ff                	xor    %edi,%edi
  801d3e:	31 c0                	xor    %eax,%eax
  801d40:	89 fa                	mov    %edi,%edx
  801d42:	83 c4 1c             	add    $0x1c,%esp
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5f                   	pop    %edi
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    
  801d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d50:	0f bd fa             	bsr    %edx,%edi
  801d53:	83 f7 1f             	xor    $0x1f,%edi
  801d56:	75 48                	jne    801da0 <__udivdi3+0xa0>
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	72 06                	jb     801d62 <__udivdi3+0x62>
  801d5c:	31 c0                	xor    %eax,%eax
  801d5e:	39 eb                	cmp    %ebp,%ebx
  801d60:	77 de                	ja     801d40 <__udivdi3+0x40>
  801d62:	b8 01 00 00 00       	mov    $0x1,%eax
  801d67:	eb d7                	jmp    801d40 <__udivdi3+0x40>
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 d9                	mov    %ebx,%ecx
  801d72:	85 db                	test   %ebx,%ebx
  801d74:	75 0b                	jne    801d81 <__udivdi3+0x81>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f3                	div    %ebx
  801d7f:	89 c1                	mov    %eax,%ecx
  801d81:	31 d2                	xor    %edx,%edx
  801d83:	89 f0                	mov    %esi,%eax
  801d85:	f7 f1                	div    %ecx
  801d87:	89 c6                	mov    %eax,%esi
  801d89:	89 e8                	mov    %ebp,%eax
  801d8b:	89 f7                	mov    %esi,%edi
  801d8d:	f7 f1                	div    %ecx
  801d8f:	89 fa                	mov    %edi,%edx
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	89 f9                	mov    %edi,%ecx
  801da2:	b8 20 00 00 00       	mov    $0x20,%eax
  801da7:	29 f8                	sub    %edi,%eax
  801da9:	d3 e2                	shl    %cl,%edx
  801dab:	89 54 24 08          	mov    %edx,0x8(%esp)
  801daf:	89 c1                	mov    %eax,%ecx
  801db1:	89 da                	mov    %ebx,%edx
  801db3:	d3 ea                	shr    %cl,%edx
  801db5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801db9:	09 d1                	or     %edx,%ecx
  801dbb:	89 f2                	mov    %esi,%edx
  801dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	d3 e3                	shl    %cl,%ebx
  801dc5:	89 c1                	mov    %eax,%ecx
  801dc7:	d3 ea                	shr    %cl,%edx
  801dc9:	89 f9                	mov    %edi,%ecx
  801dcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801dcf:	89 eb                	mov    %ebp,%ebx
  801dd1:	d3 e6                	shl    %cl,%esi
  801dd3:	89 c1                	mov    %eax,%ecx
  801dd5:	d3 eb                	shr    %cl,%ebx
  801dd7:	09 de                	or     %ebx,%esi
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	f7 74 24 08          	divl   0x8(%esp)
  801ddf:	89 d6                	mov    %edx,%esi
  801de1:	89 c3                	mov    %eax,%ebx
  801de3:	f7 64 24 0c          	mull   0xc(%esp)
  801de7:	39 d6                	cmp    %edx,%esi
  801de9:	72 15                	jb     801e00 <__udivdi3+0x100>
  801deb:	89 f9                	mov    %edi,%ecx
  801ded:	d3 e5                	shl    %cl,%ebp
  801def:	39 c5                	cmp    %eax,%ebp
  801df1:	73 04                	jae    801df7 <__udivdi3+0xf7>
  801df3:	39 d6                	cmp    %edx,%esi
  801df5:	74 09                	je     801e00 <__udivdi3+0x100>
  801df7:	89 d8                	mov    %ebx,%eax
  801df9:	31 ff                	xor    %edi,%edi
  801dfb:	e9 40 ff ff ff       	jmp    801d40 <__udivdi3+0x40>
  801e00:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e03:	31 ff                	xor    %edi,%edi
  801e05:	e9 36 ff ff ff       	jmp    801d40 <__udivdi3+0x40>
  801e0a:	66 90                	xchg   %ax,%ax
  801e0c:	66 90                	xchg   %ax,%ax
  801e0e:	66 90                	xchg   %ax,%ax

00801e10 <__umoddi3>:
  801e10:	f3 0f 1e fb          	endbr32 
  801e14:	55                   	push   %ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	83 ec 1c             	sub    $0x1c,%esp
  801e1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	75 19                	jne    801e48 <__umoddi3+0x38>
  801e2f:	39 df                	cmp    %ebx,%edi
  801e31:	76 5d                	jbe    801e90 <__umoddi3+0x80>
  801e33:	89 f0                	mov    %esi,%eax
  801e35:	89 da                	mov    %ebx,%edx
  801e37:	f7 f7                	div    %edi
  801e39:	89 d0                	mov    %edx,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	83 c4 1c             	add    $0x1c,%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    
  801e45:	8d 76 00             	lea    0x0(%esi),%esi
  801e48:	89 f2                	mov    %esi,%edx
  801e4a:	39 d8                	cmp    %ebx,%eax
  801e4c:	76 12                	jbe    801e60 <__umoddi3+0x50>
  801e4e:	89 f0                	mov    %esi,%eax
  801e50:	89 da                	mov    %ebx,%edx
  801e52:	83 c4 1c             	add    $0x1c,%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    
  801e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e60:	0f bd e8             	bsr    %eax,%ebp
  801e63:	83 f5 1f             	xor    $0x1f,%ebp
  801e66:	75 50                	jne    801eb8 <__umoddi3+0xa8>
  801e68:	39 d8                	cmp    %ebx,%eax
  801e6a:	0f 82 e0 00 00 00    	jb     801f50 <__umoddi3+0x140>
  801e70:	89 d9                	mov    %ebx,%ecx
  801e72:	39 f7                	cmp    %esi,%edi
  801e74:	0f 86 d6 00 00 00    	jbe    801f50 <__umoddi3+0x140>
  801e7a:	89 d0                	mov    %edx,%eax
  801e7c:	89 ca                	mov    %ecx,%edx
  801e7e:	83 c4 1c             	add    $0x1c,%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    
  801e86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e8d:	8d 76 00             	lea    0x0(%esi),%esi
  801e90:	89 fd                	mov    %edi,%ebp
  801e92:	85 ff                	test   %edi,%edi
  801e94:	75 0b                	jne    801ea1 <__umoddi3+0x91>
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	f7 f7                	div    %edi
  801e9f:	89 c5                	mov    %eax,%ebp
  801ea1:	89 d8                	mov    %ebx,%eax
  801ea3:	31 d2                	xor    %edx,%edx
  801ea5:	f7 f5                	div    %ebp
  801ea7:	89 f0                	mov    %esi,%eax
  801ea9:	f7 f5                	div    %ebp
  801eab:	89 d0                	mov    %edx,%eax
  801ead:	31 d2                	xor    %edx,%edx
  801eaf:	eb 8c                	jmp    801e3d <__umoddi3+0x2d>
  801eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eb8:	89 e9                	mov    %ebp,%ecx
  801eba:	ba 20 00 00 00       	mov    $0x20,%edx
  801ebf:	29 ea                	sub    %ebp,%edx
  801ec1:	d3 e0                	shl    %cl,%eax
  801ec3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec7:	89 d1                	mov    %edx,%ecx
  801ec9:	89 f8                	mov    %edi,%eax
  801ecb:	d3 e8                	shr    %cl,%eax
  801ecd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ed1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ed9:	09 c1                	or     %eax,%ecx
  801edb:	89 d8                	mov    %ebx,%eax
  801edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee1:	89 e9                	mov    %ebp,%ecx
  801ee3:	d3 e7                	shl    %cl,%edi
  801ee5:	89 d1                	mov    %edx,%ecx
  801ee7:	d3 e8                	shr    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eef:	d3 e3                	shl    %cl,%ebx
  801ef1:	89 c7                	mov    %eax,%edi
  801ef3:	89 d1                	mov    %edx,%ecx
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	d3 e8                	shr    %cl,%eax
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	89 fa                	mov    %edi,%edx
  801efd:	d3 e6                	shl    %cl,%esi
  801eff:	09 d8                	or     %ebx,%eax
  801f01:	f7 74 24 08          	divl   0x8(%esp)
  801f05:	89 d1                	mov    %edx,%ecx
  801f07:	89 f3                	mov    %esi,%ebx
  801f09:	f7 64 24 0c          	mull   0xc(%esp)
  801f0d:	89 c6                	mov    %eax,%esi
  801f0f:	89 d7                	mov    %edx,%edi
  801f11:	39 d1                	cmp    %edx,%ecx
  801f13:	72 06                	jb     801f1b <__umoddi3+0x10b>
  801f15:	75 10                	jne    801f27 <__umoddi3+0x117>
  801f17:	39 c3                	cmp    %eax,%ebx
  801f19:	73 0c                	jae    801f27 <__umoddi3+0x117>
  801f1b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f1f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f23:	89 d7                	mov    %edx,%edi
  801f25:	89 c6                	mov    %eax,%esi
  801f27:	89 ca                	mov    %ecx,%edx
  801f29:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f2e:	29 f3                	sub    %esi,%ebx
  801f30:	19 fa                	sbb    %edi,%edx
  801f32:	89 d0                	mov    %edx,%eax
  801f34:	d3 e0                	shl    %cl,%eax
  801f36:	89 e9                	mov    %ebp,%ecx
  801f38:	d3 eb                	shr    %cl,%ebx
  801f3a:	d3 ea                	shr    %cl,%edx
  801f3c:	09 d8                	or     %ebx,%eax
  801f3e:	83 c4 1c             	add    $0x1c,%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5f                   	pop    %edi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    
  801f46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi
  801f50:	29 fe                	sub    %edi,%esi
  801f52:	19 c3                	sbb    %eax,%ebx
  801f54:	89 f2                	mov    %esi,%edx
  801f56:	89 d9                	mov    %ebx,%ecx
  801f58:	e9 1d ff ff ff       	jmp    801e7a <__umoddi3+0x6a>
