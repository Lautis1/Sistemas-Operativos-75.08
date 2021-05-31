
obj/user/testpiperace.debug:     formato del fichero elf32-i386


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
  80002c:	e8 c1 01 00 00       	call   8001f2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003f:	68 40 25 80 00       	push   $0x802540
  800044:	e8 fc 02 00 00       	call   800345 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 e2 1e 00 00       	call   801f36 <pipe>
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	78 59                	js     8000b4 <umain+0x81>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  80005b:	e8 b6 11 00 00       	call   801216 <fork>
  800060:	89 c6                	mov    %eax,%esi
  800062:	85 c0                	test   %eax,%eax
  800064:	78 60                	js     8000c6 <umain+0x93>
		panic("fork: %e", r);
	if (r == 0) {
  800066:	74 70                	je     8000d8 <umain+0xa5>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	56                   	push   %esi
  80006c:	68 9a 25 80 00       	push   $0x80259a
  800071:	e8 cf 02 00 00       	call   800345 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800076:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  80007c:	83 c4 08             	add    $0x8,%esp
  80007f:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800082:	c1 f8 02             	sar    $0x2,%eax
  800085:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  80008b:	50                   	push   %eax
  80008c:	68 a5 25 80 00       	push   $0x8025a5
  800091:	e8 af 02 00 00       	call   800345 <cprintf>
	dup(p[0], 10);
  800096:	83 c4 08             	add    $0x8,%esp
  800099:	6a 0a                	push   $0xa
  80009b:	ff 75 f0             	pushl  -0x10(%ebp)
  80009e:	e8 40 16 00 00       	call   8016e3 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000af:	e9 92 00 00 00       	jmp    800146 <umain+0x113>
		panic("pipe: %e", r);
  8000b4:	50                   	push   %eax
  8000b5:	68 59 25 80 00       	push   $0x802559
  8000ba:	6a 0d                	push   $0xd
  8000bc:	68 62 25 80 00       	push   $0x802562
  8000c1:	e8 98 01 00 00       	call   80025e <_panic>
		panic("fork: %e", r);
  8000c6:	50                   	push   %eax
  8000c7:	68 76 25 80 00       	push   $0x802576
  8000cc:	6a 10                	push   $0x10
  8000ce:	68 62 25 80 00       	push   $0x802562
  8000d3:	e8 86 01 00 00       	call   80025e <_panic>
		close(p[1]);
  8000d8:	83 ec 0c             	sub    $0xc,%esp
  8000db:	ff 75 f4             	pushl  -0xc(%ebp)
  8000de:	e8 a6 15 00 00       	call   801689 <close>
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000eb:	eb 1f                	jmp    80010c <umain+0xd9>
				cprintf("RACE: pipe appears closed\n");
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	68 7f 25 80 00       	push   $0x80257f
  8000f5:	e8 4b 02 00 00       	call   800345 <cprintf>
				exit();
  8000fa:	e8 41 01 00 00       	call   800240 <exit>
  8000ff:	83 c4 10             	add    $0x10,%esp
			sys_yield();
  800102:	e8 05 0c 00 00       	call   800d0c <sys_yield>
		for (i=0; i<max; i++) {
  800107:	83 eb 01             	sub    $0x1,%ebx
  80010a:	74 14                	je     800120 <umain+0xed>
			if(pipeisclosed(p[0])){
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	ff 75 f0             	pushl  -0x10(%ebp)
  800112:	e8 6d 1f 00 00       	call   802084 <pipeisclosed>
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	85 c0                	test   %eax,%eax
  80011c:	74 e4                	je     800102 <umain+0xcf>
  80011e:	eb cd                	jmp    8000ed <umain+0xba>
		ipc_recv(0,0,0);
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	e8 89 12 00 00       	call   8013b7 <ipc_recv>
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	e9 32 ff ff ff       	jmp    800068 <umain+0x35>
		dup(p[0], 10);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	6a 0a                	push   $0xa
  80013b:	ff 75 f0             	pushl  -0x10(%ebp)
  80013e:	e8 a0 15 00 00       	call   8016e3 <dup>
  800143:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 43 54             	mov    0x54(%ebx),%eax
  800149:	83 f8 02             	cmp    $0x2,%eax
  80014c:	74 e8                	je     800136 <umain+0x103>

	cprintf("child done with loop\n");
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	68 b0 25 80 00       	push   $0x8025b0
  800156:	e8 ea 01 00 00       	call   800345 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	83 c4 04             	add    $0x4,%esp
  80015e:	ff 75 f0             	pushl  -0x10(%ebp)
  800161:	e8 1e 1f 00 00       	call   802084 <pipeisclosed>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	85 c0                	test   %eax,%eax
  80016b:	75 48                	jne    8001b5 <umain+0x182>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800173:	50                   	push   %eax
  800174:	ff 75 f0             	pushl  -0x10(%ebp)
  800177:	e8 d4 13 00 00       	call   801550 <fd_lookup>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	85 c0                	test   %eax,%eax
  800181:	78 46                	js     8001c9 <umain+0x196>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 ec             	pushl  -0x14(%ebp)
  800189:	e8 4d 13 00 00       	call   8014db <fd2data>
	if (pageref(va) != 3+1)
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 7f 1b 00 00       	call   801d15 <pageref>
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	83 f8 04             	cmp    $0x4,%eax
  80019c:	74 3d                	je     8001db <umain+0x1a8>
		cprintf("\nchild detected race\n");
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	68 de 25 80 00       	push   $0x8025de
  8001a6:	e8 9a 01 00 00       	call   800345 <cprintf>
  8001ab:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b5:	83 ec 04             	sub    $0x4,%esp
  8001b8:	68 0c 26 80 00       	push   $0x80260c
  8001bd:	6a 3a                	push   $0x3a
  8001bf:	68 62 25 80 00       	push   $0x802562
  8001c4:	e8 95 00 00 00       	call   80025e <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c9:	50                   	push   %eax
  8001ca:	68 c6 25 80 00       	push   $0x8025c6
  8001cf:	6a 3c                	push   $0x3c
  8001d1:	68 62 25 80 00       	push   $0x802562
  8001d6:	e8 83 00 00 00       	call   80025e <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	68 c8 00 00 00       	push   $0xc8
  8001e3:	68 f4 25 80 00       	push   $0x8025f4
  8001e8:	e8 58 01 00 00       	call   800345 <cprintf>
  8001ed:	83 c4 10             	add    $0x10,%esp
}
  8001f0:	eb bc                	jmp    8001ae <umain+0x17b>

008001f2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f2:	f3 0f 1e fb          	endbr32 
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800201:	e8 de 0a 00 00       	call   800ce4 <sys_getenvid>
	if (id >= 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	78 12                	js     80021c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80020a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80020f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800212:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800217:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7e 07                	jle    800227 <libmain+0x35>
		binaryname = argv[0];
  800220:	8b 06                	mov    (%esi),%eax
  800222:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	e8 02 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800231:	e8 0a 00 00 00       	call   800240 <exit>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800240:	f3 0f 1e fb          	endbr32 
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80024a:	e8 6b 14 00 00       	call   8016ba <close_all>
	sys_env_destroy(0);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	6a 00                	push   $0x0
  800254:	e8 65 0a 00 00       	call   800cbe <sys_env_destroy>
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80025e:	f3 0f 1e fb          	endbr32 
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800267:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80026a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800270:	e8 6f 0a 00 00       	call   800ce4 <sys_getenvid>
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	56                   	push   %esi
  80027f:	50                   	push   %eax
  800280:	68 40 26 80 00       	push   $0x802640
  800285:	e8 bb 00 00 00       	call   800345 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80028a:	83 c4 18             	add    $0x18,%esp
  80028d:	53                   	push   %ebx
  80028e:	ff 75 10             	pushl  0x10(%ebp)
  800291:	e8 5a 00 00 00       	call   8002f0 <vcprintf>
	cprintf("\n");
  800296:	c7 04 24 57 25 80 00 	movl   $0x802557,(%esp)
  80029d:	e8 a3 00 00 00       	call   800345 <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a5:	cc                   	int3   
  8002a6:	eb fd                	jmp    8002a5 <_panic+0x47>

008002a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b6:	8b 13                	mov    (%ebx),%edx
  8002b8:	8d 42 01             	lea    0x1(%edx),%eax
  8002bb:	89 03                	mov    %eax,(%ebx)
  8002bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c9:	74 09                	je     8002d4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	68 ff 00 00 00       	push   $0xff
  8002dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002df:	50                   	push   %eax
  8002e0:	e8 87 09 00 00       	call   800c6c <sys_cputs>
		b->idx = 0;
  8002e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	eb db                	jmp    8002cb <putch+0x23>

008002f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800304:	00 00 00 
	b.cnt = 0;
  800307:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80030e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	68 a8 02 80 00       	push   $0x8002a8
  800323:	e8 80 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800328:	83 c4 08             	add    $0x8,%esp
  80032b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800331:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800337:	50                   	push   %eax
  800338:	e8 2f 09 00 00       	call   800c6c <sys_cputs>

	return b.cnt;
}
  80033d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800345:	f3 0f 1e fb          	endbr32 
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800352:	50                   	push   %eax
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 95 ff ff ff       	call   8002f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 1c             	sub    $0x1c,%esp
  800366:	89 c7                	mov    %eax,%edi
  800368:	89 d6                	mov    %edx,%esi
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800370:	89 d1                	mov    %edx,%ecx
  800372:	89 c2                	mov    %eax,%edx
  800374:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800377:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80037a:	8b 45 10             	mov    0x10(%ebp),%eax
  80037d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038a:	39 c2                	cmp    %eax,%edx
  80038c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80038f:	72 3e                	jb     8003cf <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	ff 75 18             	pushl  0x18(%ebp)
  800397:	83 eb 01             	sub    $0x1,%ebx
  80039a:	53                   	push   %ebx
  80039b:	50                   	push   %eax
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	e8 30 1f 00 00       	call   8022e0 <__udivdi3>
  8003b0:	83 c4 18             	add    $0x18,%esp
  8003b3:	52                   	push   %edx
  8003b4:	50                   	push   %eax
  8003b5:	89 f2                	mov    %esi,%edx
  8003b7:	89 f8                	mov    %edi,%eax
  8003b9:	e8 9f ff ff ff       	call   80035d <printnum>
  8003be:	83 c4 20             	add    $0x20,%esp
  8003c1:	eb 13                	jmp    8003d6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	56                   	push   %esi
  8003c7:	ff 75 18             	pushl  0x18(%ebp)
  8003ca:	ff d7                	call   *%edi
  8003cc:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003cf:	83 eb 01             	sub    $0x1,%ebx
  8003d2:	85 db                	test   %ebx,%ebx
  8003d4:	7f ed                	jg     8003c3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	56                   	push   %esi
  8003da:	83 ec 04             	sub    $0x4,%esp
  8003dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e9:	e8 02 20 00 00       	call   8023f0 <__umoddi3>
  8003ee:	83 c4 14             	add    $0x14,%esp
  8003f1:	0f be 80 63 26 80 00 	movsbl 0x802663(%eax),%eax
  8003f8:	50                   	push   %eax
  8003f9:	ff d7                	call   *%edi
}
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800401:	5b                   	pop    %ebx
  800402:	5e                   	pop    %esi
  800403:	5f                   	pop    %edi
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800406:	83 fa 01             	cmp    $0x1,%edx
  800409:	7f 13                	jg     80041e <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80040b:	85 d2                	test   %edx,%edx
  80040d:	74 1c                	je     80042b <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	8d 4a 04             	lea    0x4(%edx),%ecx
  800414:	89 08                	mov    %ecx,(%eax)
  800416:	8b 02                	mov    (%edx),%eax
  800418:	ba 00 00 00 00       	mov    $0x0,%edx
  80041d:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80041e:	8b 10                	mov    (%eax),%edx
  800420:	8d 4a 08             	lea    0x8(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 02                	mov    (%edx),%eax
  800427:	8b 52 04             	mov    0x4(%edx),%edx
  80042a:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80042b:	8b 10                	mov    (%eax),%edx
  80042d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800430:	89 08                	mov    %ecx,(%eax)
  800432:	8b 02                	mov    (%edx),%eax
  800434:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800439:	c3                   	ret    

0080043a <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80043a:	83 fa 01             	cmp    $0x1,%edx
  80043d:	7f 0f                	jg     80044e <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <getint+0x21>
		return va_arg(*ap, long);
  800443:	8b 10                	mov    (%eax),%edx
  800445:	8d 4a 04             	lea    0x4(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	99                   	cltd   
  80044d:	c3                   	ret    
		return va_arg(*ap, long long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 08             	lea    0x8(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	8b 52 04             	mov    0x4(%edx),%edx
  80045a:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80045b:	8b 10                	mov    (%eax),%edx
  80045d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800460:	89 08                	mov    %ecx,(%eax)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	99                   	cltd   
}
  800465:	c3                   	ret    

00800466 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800466:	f3 0f 1e fb          	endbr32 
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800470:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800474:	8b 10                	mov    (%eax),%edx
  800476:	3b 50 04             	cmp    0x4(%eax),%edx
  800479:	73 0a                	jae    800485 <sprintputch+0x1f>
		*b->buf++ = ch;
  80047b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047e:	89 08                	mov    %ecx,(%eax)
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	88 02                	mov    %al,(%edx)
}
  800485:	5d                   	pop    %ebp
  800486:	c3                   	ret    

00800487 <printfmt>:
{
  800487:	f3 0f 1e fb          	endbr32 
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
{
  8004a8:	f3 0f 1e fb          	endbr32 
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 2c             	sub    $0x2c,%esp
  8004b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004be:	e9 86 02 00 00       	jmp    800749 <vprintfmt+0x2a1>
		padc = ' ';
  8004c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8d 47 01             	lea    0x1(%edi),%eax
  8004e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e7:	0f b6 17             	movzbl (%edi),%edx
  8004ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004ed:	3c 55                	cmp    $0x55,%al
  8004ef:	0f 87 df 02 00 00    	ja     8007d4 <vprintfmt+0x32c>
  8004f5:	0f b6 c0             	movzbl %al,%eax
  8004f8:	3e ff 24 85 a0 27 80 	notrack jmp *0x8027a0(,%eax,4)
  8004ff:	00 
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800503:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800507:	eb d8                	jmp    8004e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800510:	eb cf                	jmp    8004e1 <vprintfmt+0x39>
  800512:	0f b6 d2             	movzbl %dl,%edx
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800520:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800523:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800527:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80052a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80052d:	83 f9 09             	cmp    $0x9,%ecx
  800530:	77 52                	ja     800584 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800532:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800535:	eb e9                	jmp    800520 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 00                	mov    (%eax),%eax
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800548:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054c:	79 93                	jns    8004e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80054e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800551:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800554:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80055b:	eb 84                	jmp    8004e1 <vprintfmt+0x39>
  80055d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800560:	85 c0                	test   %eax,%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	0f 49 d0             	cmovns %eax,%edx
  80056a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800570:	e9 6c ff ff ff       	jmp    8004e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800578:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80057f:	e9 5d ff ff ff       	jmp    8004e1 <vprintfmt+0x39>
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80058a:	eb bc                	jmp    800548 <vprintfmt+0xa0>
			lflag++;
  80058c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800592:	e9 4a ff ff ff       	jmp    8004e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	56                   	push   %esi
  8005a4:	ff 30                	pushl  (%eax)
  8005a6:	ff d3                	call   *%ebx
			break;
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	e9 96 01 00 00       	jmp    800746 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	99                   	cltd   
  8005bc:	31 d0                	xor    %edx,%eax
  8005be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c0:	83 f8 0f             	cmp    $0xf,%eax
  8005c3:	7f 20                	jg     8005e5 <vprintfmt+0x13d>
  8005c5:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	74 15                	je     8005e5 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8005d0:	52                   	push   %edx
  8005d1:	68 29 2c 80 00       	push   $0x802c29
  8005d6:	56                   	push   %esi
  8005d7:	53                   	push   %ebx
  8005d8:	e8 aa fe ff ff       	call   800487 <printfmt>
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	e9 61 01 00 00       	jmp    800746 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005e5:	50                   	push   %eax
  8005e6:	68 7b 26 80 00       	push   $0x80267b
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	e8 95 fe ff ff       	call   800487 <printfmt>
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	e9 4c 01 00 00       	jmp    800746 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800605:	85 c9                	test   %ecx,%ecx
  800607:	b8 74 26 80 00       	mov    $0x802674,%eax
  80060c:	0f 45 c1             	cmovne %ecx,%eax
  80060f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800612:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800616:	7e 06                	jle    80061e <vprintfmt+0x176>
  800618:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80061c:	75 0d                	jne    80062b <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800621:	89 c7                	mov    %eax,%edi
  800623:	03 45 e0             	add    -0x20(%ebp),%eax
  800626:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800629:	eb 57                	jmp    800682 <vprintfmt+0x1da>
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 d8             	pushl  -0x28(%ebp)
  800631:	ff 75 cc             	pushl  -0x34(%ebp)
  800634:	e8 4f 02 00 00       	call   800888 <strnlen>
  800639:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800641:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800644:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800648:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80064b:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	7e 10                	jle    800661 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	57                   	push   %edi
  800656:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800659:	83 eb 01             	sub    $0x1,%ebx
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb ec                	jmp    80064d <vprintfmt+0x1a5>
  800661:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800664:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800667:	85 d2                	test   %edx,%edx
  800669:	b8 00 00 00 00       	mov    $0x0,%eax
  80066e:	0f 49 c2             	cmovns %edx,%eax
  800671:	29 c2                	sub    %eax,%edx
  800673:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800676:	eb a6                	jmp    80061e <vprintfmt+0x176>
					putch(ch, putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	56                   	push   %esi
  80067c:	52                   	push   %edx
  80067d:	ff d3                	call   *%ebx
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800685:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800687:	83 c7 01             	add    $0x1,%edi
  80068a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068e:	0f be d0             	movsbl %al,%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	74 42                	je     8006d7 <vprintfmt+0x22f>
  800695:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800699:	78 06                	js     8006a1 <vprintfmt+0x1f9>
  80069b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80069f:	78 1e                	js     8006bf <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8006a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006a5:	74 d1                	je     800678 <vprintfmt+0x1d0>
  8006a7:	0f be c0             	movsbl %al,%eax
  8006aa:	83 e8 20             	sub    $0x20,%eax
  8006ad:	83 f8 5e             	cmp    $0x5e,%eax
  8006b0:	76 c6                	jbe    800678 <vprintfmt+0x1d0>
					putch('?', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	56                   	push   %esi
  8006b6:	6a 3f                	push   $0x3f
  8006b8:	ff d3                	call   *%ebx
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb c3                	jmp    800682 <vprintfmt+0x1da>
  8006bf:	89 cf                	mov    %ecx,%edi
  8006c1:	eb 0e                	jmp    8006d1 <vprintfmt+0x229>
				putch(' ', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	56                   	push   %esi
  8006c7:	6a 20                	push   $0x20
  8006c9:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8006cb:	83 ef 01             	sub    $0x1,%edi
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	85 ff                	test   %edi,%edi
  8006d3:	7f ee                	jg     8006c3 <vprintfmt+0x21b>
  8006d5:	eb 6f                	jmp    800746 <vprintfmt+0x29e>
  8006d7:	89 cf                	mov    %ecx,%edi
  8006d9:	eb f6                	jmp    8006d1 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8006db:	89 ca                	mov    %ecx,%edx
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e0:	e8 55 fd ff ff       	call   80043a <getint>
  8006e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	78 0b                	js     8006fa <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8006ef:	89 d1                	mov    %edx,%ecx
  8006f1:	89 c2                	mov    %eax,%edx
			base = 10;
  8006f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f8:	eb 32                	jmp    80072c <vprintfmt+0x284>
				putch('-', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	56                   	push   %esi
  8006fe:	6a 2d                	push   $0x2d
  800700:	ff d3                	call   *%ebx
				num = -(long long) num;
  800702:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800705:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800708:	f7 da                	neg    %edx
  80070a:	83 d1 00             	adc    $0x0,%ecx
  80070d:	f7 d9                	neg    %ecx
  80070f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	eb 13                	jmp    80072c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800719:	89 ca                	mov    %ecx,%edx
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 e3 fc ff ff       	call   800406 <getuint>
  800723:	89 d1                	mov    %edx,%ecx
  800725:	89 c2                	mov    %eax,%edx
			base = 10;
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800733:	57                   	push   %edi
  800734:	ff 75 e0             	pushl  -0x20(%ebp)
  800737:	50                   	push   %eax
  800738:	51                   	push   %ecx
  800739:	52                   	push   %edx
  80073a:	89 f2                	mov    %esi,%edx
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	e8 1a fc ff ff       	call   80035d <printnum>
			break;
  800743:	83 c4 20             	add    $0x20,%esp
{
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800749:	83 c7 01             	add    $0x1,%edi
  80074c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800750:	83 f8 25             	cmp    $0x25,%eax
  800753:	0f 84 6a fd ff ff    	je     8004c3 <vprintfmt+0x1b>
			if (ch == '\0')
  800759:	85 c0                	test   %eax,%eax
  80075b:	0f 84 93 00 00 00    	je     8007f4 <vprintfmt+0x34c>
			putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	56                   	push   %esi
  800765:	50                   	push   %eax
  800766:	ff d3                	call   *%ebx
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	eb dc                	jmp    800749 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80076d:	89 ca                	mov    %ecx,%edx
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 8f fc ff ff       	call   800406 <getuint>
  800777:	89 d1                	mov    %edx,%ecx
  800779:	89 c2                	mov    %eax,%edx
			base = 8;
  80077b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800780:	eb aa                	jmp    80072c <vprintfmt+0x284>
			putch('0', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	56                   	push   %esi
  800786:	6a 30                	push   $0x30
  800788:	ff d3                	call   *%ebx
			putch('x', putdat);
  80078a:	83 c4 08             	add    $0x8,%esp
  80078d:	56                   	push   %esi
  80078e:	6a 78                	push   $0x78
  800790:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007a2:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007a5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007aa:	eb 80                	jmp    80072c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007ac:	89 ca                	mov    %ecx,%edx
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	e8 50 fc ff ff       	call   800406 <getuint>
  8007b6:	89 d1                	mov    %edx,%ecx
  8007b8:	89 c2                	mov    %eax,%edx
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bf:	e9 68 ff ff ff       	jmp    80072c <vprintfmt+0x284>
			putch(ch, putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	56                   	push   %esi
  8007c8:	6a 25                	push   $0x25
  8007ca:	ff d3                	call   *%ebx
			break;
  8007cc:	83 c4 10             	add    $0x10,%esp
  8007cf:	e9 72 ff ff ff       	jmp    800746 <vprintfmt+0x29e>
			putch('%', putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	56                   	push   %esi
  8007d8:	6a 25                	push   $0x25
  8007da:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	89 f8                	mov    %edi,%eax
  8007e1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e5:	74 05                	je     8007ec <vprintfmt+0x344>
  8007e7:	83 e8 01             	sub    $0x1,%eax
  8007ea:	eb f5                	jmp    8007e1 <vprintfmt+0x339>
  8007ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ef:	e9 52 ff ff ff       	jmp    800746 <vprintfmt+0x29e>
}
  8007f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5f                   	pop    %edi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fc:	f3 0f 1e fb          	endbr32 
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 26                	je     800847 <vsnprintf+0x4b>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 22                	jle    800847 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	ff 75 14             	pushl  0x14(%ebp)
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	68 66 04 80 00       	push   $0x800466
  800834:	e8 6f fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800839:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	83 c4 10             	add    $0x10,%esp
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb f7                	jmp    800845 <vsnprintf+0x49>

0080084e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085b:	50                   	push   %eax
  80085c:	ff 75 10             	pushl  0x10(%ebp)
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	ff 75 08             	pushl  0x8(%ebp)
  800865:	e8 92 ff ff ff       	call   8007fc <vsnprintf>
	va_end(ap);

	return rc;
}
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086c:	f3 0f 1e fb          	endbr32 
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087f:	74 05                	je     800886 <strlen+0x1a>
		n++;
  800881:	83 c0 01             	add    $0x1,%eax
  800884:	eb f5                	jmp    80087b <strlen+0xf>
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	f3 0f 1e fb          	endbr32 
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	39 d0                	cmp    %edx,%eax
  80089c:	74 0d                	je     8008ab <strnlen+0x23>
  80089e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a2:	74 05                	je     8008a9 <strnlen+0x21>
		n++;
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	eb f1                	jmp    80089a <strnlen+0x12>
  8008a9:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ab:	89 d0                	mov    %edx,%eax
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008af:	f3 0f 1e fb          	endbr32 
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	75 f2                	jne    8008c2 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008d0:	89 c8                	mov    %ecx,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d5:	f3 0f 1e fb          	endbr32 
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	83 ec 10             	sub    $0x10,%esp
  8008e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e3:	53                   	push   %ebx
  8008e4:	e8 83 ff ff ff       	call   80086c <strlen>
  8008e9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	01 d8                	add    %ebx,%eax
  8008f1:	50                   	push   %eax
  8008f2:	e8 b8 ff ff ff       	call   8008af <strcpy>
	return dst;
}
  8008f7:	89 d8                	mov    %ebx,%eax
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fe:	f3 0f 1e fb          	endbr32 
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f0                	mov    %esi,%eax
  800914:	39 d8                	cmp    %ebx,%eax
  800916:	74 11                	je     800929 <strncpy+0x2b>
		*dst++ = *src;
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	0f b6 0a             	movzbl (%edx),%ecx
  80091e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800921:	80 f9 01             	cmp    $0x1,%cl
  800924:	83 da ff             	sbb    $0xffffffff,%edx
  800927:	eb eb                	jmp    800914 <strncpy+0x16>
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	f3 0f 1e fb          	endbr32 
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	8b 55 10             	mov    0x10(%ebp),%edx
  800941:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800943:	85 d2                	test   %edx,%edx
  800945:	74 21                	je     800968 <strlcpy+0x39>
  800947:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80094b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80094d:	39 c2                	cmp    %eax,%edx
  80094f:	74 14                	je     800965 <strlcpy+0x36>
  800951:	0f b6 19             	movzbl (%ecx),%ebx
  800954:	84 db                	test   %bl,%bl
  800956:	74 0b                	je     800963 <strlcpy+0x34>
			*dst++ = *src++;
  800958:	83 c1 01             	add    $0x1,%ecx
  80095b:	83 c2 01             	add    $0x1,%edx
  80095e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800961:	eb ea                	jmp    80094d <strlcpy+0x1e>
  800963:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800965:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800968:	29 f0                	sub    %esi,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 0c                	je     80098e <strcmp+0x20>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	75 08                	jne    80098e <strcmp+0x20>
		p++, q++;
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	83 c2 01             	add    $0x1,%edx
  80098c:	eb ed                	jmp    80097b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098e:	0f b6 c0             	movzbl %al,%eax
  800991:	0f b6 12             	movzbl (%edx),%edx
  800994:	29 d0                	sub    %edx,%eax
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strncmp+0x1b>
		n--, p++, q++;
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b3:	39 d8                	cmp    %ebx,%eax
  8009b5:	74 16                	je     8009cd <strncmp+0x35>
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	84 c9                	test   %cl,%cl
  8009bc:	74 04                	je     8009c2 <strncmp+0x2a>
  8009be:	3a 0a                	cmp    (%edx),%cl
  8009c0:	74 eb                	je     8009ad <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c2:	0f b6 00             	movzbl (%eax),%eax
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	29 d0                	sub    %edx,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    
		return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	eb f6                	jmp    8009ca <strncmp+0x32>

008009d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d4:	f3 0f 1e fb          	endbr32 
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	0f b6 10             	movzbl (%eax),%edx
  8009e5:	84 d2                	test   %dl,%dl
  8009e7:	74 09                	je     8009f2 <strchr+0x1e>
		if (*s == c)
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	74 0a                	je     8009f7 <strchr+0x23>
	for (; *s; s++)
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	eb f0                	jmp    8009e2 <strchr+0xe>
			return (char *) s;
	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f9:	f3 0f 1e fb          	endbr32 
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 09                	je     800a17 <strfind+0x1e>
  800a0e:	84 d2                	test   %dl,%dl
  800a10:	74 05                	je     800a17 <strfind+0x1e>
	for (; *s; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	eb f0                	jmp    800a07 <strfind+0xe>
			break;
	return (char *) s;
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a19:	f3 0f 1e fb          	endbr32 
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	74 33                	je     800a60 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2d:	89 d0                	mov    %edx,%eax
  800a2f:	09 c8                	or     %ecx,%eax
  800a31:	a8 03                	test   $0x3,%al
  800a33:	75 23                	jne    800a58 <memset+0x3f>
		c &= 0xFF;
  800a35:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	c1 e0 08             	shl    $0x8,%eax
  800a3e:	89 df                	mov    %ebx,%edi
  800a40:	c1 e7 18             	shl    $0x18,%edi
  800a43:	89 de                	mov    %ebx,%esi
  800a45:	c1 e6 10             	shl    $0x10,%esi
  800a48:	09 f7                	or     %esi,%edi
  800a4a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a51:	89 d7                	mov    %edx,%edi
  800a53:	fc                   	cld    
  800a54:	f3 ab                	rep stos %eax,%es:(%edi)
  800a56:	eb 08                	jmp    800a60 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a58:	89 d7                	mov    %edx,%edi
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	fc                   	cld    
  800a5e:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a60:	89 d0                	mov    %edx,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a67:	f3 0f 1e fb          	endbr32 
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a79:	39 c6                	cmp    %eax,%esi
  800a7b:	73 32                	jae    800aaf <memmove+0x48>
  800a7d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a80:	39 c2                	cmp    %eax,%edx
  800a82:	76 2b                	jbe    800aaf <memmove+0x48>
		s += n;
		d += n;
  800a84:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a87:	89 fe                	mov    %edi,%esi
  800a89:	09 ce                	or     %ecx,%esi
  800a8b:	09 d6                	or     %edx,%esi
  800a8d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a93:	75 0e                	jne    800aa3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a95:	83 ef 04             	sub    $0x4,%edi
  800a98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9e:	fd                   	std    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 09                	jmp    800aac <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa3:	83 ef 01             	sub    $0x1,%edi
  800aa6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa9:	fd                   	std    
  800aaa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aac:	fc                   	cld    
  800aad:	eb 1a                	jmp    800ac9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	09 ca                	or     %ecx,%edx
  800ab3:	09 f2                	or     %esi,%edx
  800ab5:	f6 c2 03             	test   $0x3,%dl
  800ab8:	75 0a                	jne    800ac4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abd:	89 c7                	mov    %eax,%edi
  800abf:	fc                   	cld    
  800ac0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac2:	eb 05                	jmp    800ac9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ac4:	89 c7                	mov    %eax,%edi
  800ac6:	fc                   	cld    
  800ac7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acd:	f3 0f 1e fb          	endbr32 
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	ff 75 10             	pushl  0x10(%ebp)
  800ada:	ff 75 0c             	pushl  0xc(%ebp)
  800add:	ff 75 08             	pushl  0x8(%ebp)
  800ae0:	e8 82 ff ff ff       	call   800a67 <memmove>
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae7:	f3 0f 1e fb          	endbr32 
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 f0                	cmp    %esi,%eax
  800afd:	74 1c                	je     800b1b <memcmp+0x34>
		if (*s1 != *s2)
  800aff:	0f b6 08             	movzbl (%eax),%ecx
  800b02:	0f b6 1a             	movzbl (%edx),%ebx
  800b05:	38 d9                	cmp    %bl,%cl
  800b07:	75 08                	jne    800b11 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	83 c2 01             	add    $0x1,%edx
  800b0f:	eb ea                	jmp    800afb <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b11:	0f b6 c1             	movzbl %cl,%eax
  800b14:	0f b6 db             	movzbl %bl,%ebx
  800b17:	29 d8                	sub    %ebx,%eax
  800b19:	eb 05                	jmp    800b20 <memcmp+0x39>
	}

	return 0;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b36:	39 d0                	cmp    %edx,%eax
  800b38:	73 09                	jae    800b43 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3a:	38 08                	cmp    %cl,(%eax)
  800b3c:	74 05                	je     800b43 <memfind+0x1f>
	for (; s < ends; s++)
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	eb f3                	jmp    800b36 <memfind+0x12>
			break;
	return (void *) s;
}
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b55:	eb 03                	jmp    800b5a <strtol+0x15>
		s++;
  800b57:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 01             	movzbl (%ecx),%eax
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 f6                	je     800b57 <strtol+0x12>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	74 f2                	je     800b57 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b65:	3c 2b                	cmp    $0x2b,%al
  800b67:	74 2a                	je     800b93 <strtol+0x4e>
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6e:	3c 2d                	cmp    $0x2d,%al
  800b70:	74 2b                	je     800b9d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b78:	75 0f                	jne    800b89 <strtol+0x44>
  800b7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7d:	74 28                	je     800ba7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b86:	0f 44 d8             	cmove  %eax,%ebx
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b91:	eb 46                	jmp    800bd9 <strtol+0x94>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b96:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9b:	eb d5                	jmp    800b72 <strtol+0x2d>
		s++, neg = 1;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba5:	eb cb                	jmp    800b72 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	74 0e                	je     800bbb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bad:	85 db                	test   %ebx,%ebx
  800baf:	75 d8                	jne    800b89 <strtol+0x44>
		s++, base = 8;
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb9:	eb ce                	jmp    800b89 <strtol+0x44>
		s += 2, base = 16;
  800bbb:	83 c1 02             	add    $0x2,%ecx
  800bbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc3:	eb c4                	jmp    800b89 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 3a                	jge    800c0a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd9:	0f b6 11             	movzbl (%ecx),%edx
  800bdc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	76 df                	jbe    800bc5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 57             	sub    $0x57,%edx
  800bf6:	eb d3                	jmp    800bcb <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 19             	cmp    $0x19,%bl
  800c00:	77 08                	ja     800c0a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c02:	0f be d2             	movsbl %dl,%edx
  800c05:	83 ea 37             	sub    $0x37,%edx
  800c08:	eb c1                	jmp    800bcb <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0e:	74 05                	je     800c15 <strtol+0xd0>
		*endptr = (char *) s;
  800c10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c13:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	f7 da                	neg    %edx
  800c19:	85 ff                	test   %edi,%edi
  800c1b:	0f 45 c2             	cmovne %edx,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 1c             	sub    $0x1c,%esp
  800c2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c32:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c3d:	8b 75 14             	mov    0x14(%ebp),%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c46:	74 04                	je     800c4c <syscall+0x29>
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7f 08                	jg     800c54 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	ff 75 e0             	pushl  -0x20(%ebp)
  800c5b:	68 5f 29 80 00       	push   $0x80295f
  800c60:	6a 23                	push   $0x23
  800c62:	68 7c 29 80 00       	push   $0x80297c
  800c67:	e8 f2 f5 ff ff       	call   80025e <_panic>

00800c6c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c6c:	f3 0f 1e fb          	endbr32 
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	ff 75 0c             	pushl  0xc(%ebp)
  800c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8c:	e8 92 ff ff ff       	call   800c23 <syscall>
}
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	6a 00                	push   $0x0
  800ca6:	6a 00                	push   $0x0
  800ca8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb7:	e8 67 ff ff ff       	call   800c23 <syscall>
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbe:	f3 0f 1e fb          	endbr32 
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	6a 00                	push   $0x0
  800cd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd8:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdd:	e8 41 ff ff ff       	call   800c23 <syscall>
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce4:	f3 0f 1e fb          	endbr32 
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cee:	6a 00                	push   $0x0
  800cf0:	6a 00                	push   $0x0
  800cf2:	6a 00                	push   $0x0
  800cf4:	6a 00                	push   $0x0
  800cf6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 02 00 00 00       	mov    $0x2,%eax
  800d05:	e8 19 ff ff ff       	call   800c23 <syscall>
}
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <sys_yield>:

void
sys_yield(void)
{
  800d0c:	f3 0f 1e fb          	endbr32 
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d16:	6a 00                	push   $0x0
  800d18:	6a 00                	push   $0x0
  800d1a:	6a 00                	push   $0x0
  800d1c:	6a 00                	push   $0x0
  800d1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2d:	e8 f1 fe ff ff       	call   800c23 <syscall>
}
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	ff 75 10             	pushl  0x10(%ebp)
  800d48:	ff 75 0c             	pushl  0xc(%ebp)
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d53:	b8 04 00 00 00       	mov    $0x4,%eax
  800d58:	e8 c6 fe ff ff       	call   800c23 <syscall>
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5f:	f3 0f 1e fb          	endbr32 
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d69:	ff 75 18             	pushl  0x18(%ebp)
  800d6c:	ff 75 14             	pushl  0x14(%ebp)
  800d6f:	ff 75 10             	pushl  0x10(%ebp)
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d78:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d82:	e8 9c fe ff ff       	call   800c23 <syscall>
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d89:	f3 0f 1e fb          	endbr32 
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	6a 00                	push   $0x0
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9f:	ba 01 00 00 00       	mov    $0x1,%edx
  800da4:	b8 06 00 00 00       	mov    $0x6,%eax
  800da9:	e8 75 fe ff ff       	call   800c23 <syscall>
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800dba:	6a 00                	push   $0x0
  800dbc:	6a 00                	push   $0x0
  800dbe:	6a 00                	push   $0x0
  800dc0:	ff 75 0c             	pushl  0xc(%ebp)
  800dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc6:	ba 01 00 00 00       	mov    $0x1,%edx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	e8 4e fe ff ff       	call   800c23 <syscall>
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd7:	f3 0f 1e fb          	endbr32 
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800de1:	6a 00                	push   $0x0
  800de3:	6a 00                	push   $0x0
  800de5:	6a 00                	push   $0x0
  800de7:	ff 75 0c             	pushl  0xc(%ebp)
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	ba 01 00 00 00       	mov    $0x1,%edx
  800df2:	b8 09 00 00 00       	mov    $0x9,%eax
  800df7:	e8 27 fe ff ff       	call   800c23 <syscall>
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e08:	6a 00                	push   $0x0
  800e0a:	6a 00                	push   $0x0
  800e0c:	6a 00                	push   $0x0
  800e0e:	ff 75 0c             	pushl  0xc(%ebp)
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	ba 01 00 00 00       	mov    $0x1,%edx
  800e19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1e:	e8 00 fe ff ff       	call   800c23 <syscall>
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e25:	f3 0f 1e fb          	endbr32 
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e2f:	6a 00                	push   $0x0
  800e31:	ff 75 14             	pushl  0x14(%ebp)
  800e34:	ff 75 10             	pushl  0x10(%ebp)
  800e37:	ff 75 0c             	pushl  0xc(%ebp)
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e47:	e8 d7 fd ff ff       	call   800c23 <syscall>
}
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4e:	f3 0f 1e fb          	endbr32 
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e58:	6a 00                	push   $0x0
  800e5a:	6a 00                	push   $0x0
  800e5c:	6a 00                	push   $0x0
  800e5e:	6a 00                	push   $0x0
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	ba 01 00 00 00       	mov    $0x1,%edx
  800e68:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6d:	e8 b1 fd ff ff       	call   800c23 <syscall>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	53                   	push   %ebx
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800e7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800e84:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800e87:	f6 c6 04             	test   $0x4,%dh
  800e8a:	75 54                	jne    800ee0 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800e8c:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e92:	0f 84 8d 00 00 00    	je     800f25 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	68 05 08 00 00       	push   $0x805
  800ea0:	53                   	push   %ebx
  800ea1:	50                   	push   %eax
  800ea2:	53                   	push   %ebx
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 b5 fe ff ff       	call   800d5f <sys_page_map>
		if (r < 0)
  800eaa:	83 c4 20             	add    $0x20,%esp
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	78 5f                	js     800f10 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	68 05 08 00 00       	push   $0x805
  800eb9:	53                   	push   %ebx
  800eba:	6a 00                	push   $0x0
  800ebc:	53                   	push   %ebx
  800ebd:	6a 00                	push   $0x0
  800ebf:	e8 9b fe ff ff       	call   800d5f <sys_page_map>
		if (r < 0)
  800ec4:	83 c4 20             	add    $0x20,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	79 70                	jns    800f3b <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ecb:	50                   	push   %eax
  800ecc:	68 8c 29 80 00       	push   $0x80298c
  800ed1:	68 9b 00 00 00       	push   $0x9b
  800ed6:	68 fa 2a 80 00       	push   $0x802afa
  800edb:	e8 7e f3 ff ff       	call   80025e <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ee9:	52                   	push   %edx
  800eea:	53                   	push   %ebx
  800eeb:	50                   	push   %eax
  800eec:	53                   	push   %ebx
  800eed:	6a 00                	push   $0x0
  800eef:	e8 6b fe ff ff       	call   800d5f <sys_page_map>
		if (r < 0)
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	79 40                	jns    800f3b <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800efb:	50                   	push   %eax
  800efc:	68 8c 29 80 00       	push   $0x80298c
  800f01:	68 92 00 00 00       	push   $0x92
  800f06:	68 fa 2a 80 00       	push   $0x802afa
  800f0b:	e8 4e f3 ff ff       	call   80025e <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f10:	50                   	push   %eax
  800f11:	68 8c 29 80 00       	push   $0x80298c
  800f16:	68 97 00 00 00       	push   $0x97
  800f1b:	68 fa 2a 80 00       	push   $0x802afa
  800f20:	e8 39 f3 ff ff       	call   80025e <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	6a 05                	push   $0x5
  800f2a:	53                   	push   %ebx
  800f2b:	50                   	push   %eax
  800f2c:	53                   	push   %ebx
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 2b fe ff ff       	call   800d5f <sys_page_map>
		if (r < 0)
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 0a                	js     800f45 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f45:	50                   	push   %eax
  800f46:	68 8c 29 80 00       	push   $0x80298c
  800f4b:	68 a0 00 00 00       	push   $0xa0
  800f50:	68 fa 2a 80 00       	push   $0x802afa
  800f55:	e8 04 f3 ff ff       	call   80025e <_panic>

00800f5a <dup_or_share>:
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	89 c7                	mov    %eax,%edi
  800f65:	89 d6                	mov    %edx,%esi
  800f67:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800f69:	f6 c1 02             	test   $0x2,%cl
  800f6c:	0f 84 90 00 00 00    	je     801002 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	51                   	push   %ecx
  800f76:	52                   	push   %edx
  800f77:	50                   	push   %eax
  800f78:	e8 ba fd ff ff       	call   800d37 <sys_page_alloc>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 56                	js     800fda <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	53                   	push   %ebx
  800f88:	68 00 00 40 00       	push   $0x400000
  800f8d:	6a 00                	push   $0x0
  800f8f:	56                   	push   %esi
  800f90:	57                   	push   %edi
  800f91:	e8 c9 fd ff ff       	call   800d5f <sys_page_map>
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 51                	js     800fee <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	68 00 10 00 00       	push   $0x1000
  800fa5:	56                   	push   %esi
  800fa6:	68 00 00 40 00       	push   $0x400000
  800fab:	e8 b7 fa ff ff       	call   800a67 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800fb0:	83 c4 08             	add    $0x8,%esp
  800fb3:	68 00 00 40 00       	push   $0x400000
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 ca fd ff ff       	call   800d89 <sys_page_unmap>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	79 51                	jns    801017 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 fc 29 80 00       	push   $0x8029fc
  800fce:	6a 18                	push   $0x18
  800fd0:	68 fa 2a 80 00       	push   $0x802afa
  800fd5:	e8 84 f2 ff ff       	call   80025e <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800fda:	83 ec 04             	sub    $0x4,%esp
  800fdd:	68 b0 29 80 00       	push   $0x8029b0
  800fe2:	6a 13                	push   $0x13
  800fe4:	68 fa 2a 80 00       	push   $0x802afa
  800fe9:	e8 70 f2 ff ff       	call   80025e <_panic>
			panic("sys_page_map failed at dup_or_share");
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 d8 29 80 00       	push   $0x8029d8
  800ff6:	6a 15                	push   $0x15
  800ff8:	68 fa 2a 80 00       	push   $0x802afa
  800ffd:	e8 5c f2 ff ff       	call   80025e <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	51                   	push   %ecx
  801006:	52                   	push   %edx
  801007:	50                   	push   %eax
  801008:	52                   	push   %edx
  801009:	6a 00                	push   $0x0
  80100b:	e8 4f fd ff ff       	call   800d5f <sys_page_map>
  801010:	83 c4 20             	add    $0x20,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	78 08                	js     80101f <dup_or_share+0xc5>
}
  801017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 d8 29 80 00       	push   $0x8029d8
  801027:	6a 1c                	push   $0x1c
  801029:	68 fa 2a 80 00       	push   $0x802afa
  80102e:	e8 2b f2 ff ff       	call   80025e <_panic>

00801033 <pgfault>:
{
  801033:	f3 0f 1e fb          	endbr32 
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	53                   	push   %ebx
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801041:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  801043:	89 da                	mov    %ebx,%edx
  801045:	c1 ea 0c             	shr    $0xc,%edx
  801048:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  80104f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801053:	74 6e                	je     8010c3 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  801055:	f6 c6 08             	test   $0x8,%dh
  801058:	74 7d                	je     8010d7 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	6a 07                	push   $0x7
  80105f:	68 00 f0 7f 00       	push   $0x7ff000
  801064:	6a 00                	push   $0x0
  801066:	e8 cc fc ff ff       	call   800d37 <sys_page_alloc>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 79                	js     8010eb <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801072:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	68 00 10 00 00       	push   $0x1000
  801080:	53                   	push   %ebx
  801081:	68 00 f0 7f 00       	push   $0x7ff000
  801086:	e8 dc f9 ff ff       	call   800a67 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  80108b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801092:	53                   	push   %ebx
  801093:	6a 00                	push   $0x0
  801095:	68 00 f0 7f 00       	push   $0x7ff000
  80109a:	6a 00                	push   $0x0
  80109c:	e8 be fc ff ff       	call   800d5f <sys_page_map>
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 57                	js     8010ff <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	68 00 f0 7f 00       	push   $0x7ff000
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 d2 fc ff ff       	call   800d89 <sys_page_unmap>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 55                	js     801113 <pgfault+0xe0>
}
  8010be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	68 05 2b 80 00       	push   $0x802b05
  8010cb:	6a 5e                	push   $0x5e
  8010cd:	68 fa 2a 80 00       	push   $0x802afa
  8010d2:	e8 87 f1 ff ff       	call   80025e <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	68 24 2a 80 00       	push   $0x802a24
  8010df:	6a 62                	push   $0x62
  8010e1:	68 fa 2a 80 00       	push   $0x802afa
  8010e6:	e8 73 f1 ff ff       	call   80025e <_panic>
		panic("pgfault failed");
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	68 1d 2b 80 00       	push   $0x802b1d
  8010f3:	6a 6d                	push   $0x6d
  8010f5:	68 fa 2a 80 00       	push   $0x802afa
  8010fa:	e8 5f f1 ff ff       	call   80025e <_panic>
		panic("pgfault failed");
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	68 1d 2b 80 00       	push   $0x802b1d
  801107:	6a 72                	push   $0x72
  801109:	68 fa 2a 80 00       	push   $0x802afa
  80110e:	e8 4b f1 ff ff       	call   80025e <_panic>
		panic("pgfault failed");
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	68 1d 2b 80 00       	push   $0x802b1d
  80111b:	6a 74                	push   $0x74
  80111d:	68 fa 2a 80 00       	push   $0x802afa
  801122:	e8 37 f1 ff ff       	call   80025e <_panic>

00801127 <fork_v0>:
{
  801127:	f3 0f 1e fb          	endbr32 
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801134:	b8 07 00 00 00       	mov    $0x7,%eax
  801139:	cd 30                	int    $0x30
  80113b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80113e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801141:	85 c0                	test   %eax,%eax
  801143:	78 1d                	js     801162 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801145:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80114a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80114e:	74 26                	je     801176 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801150:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801155:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  80115b:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801160:	eb 4b                	jmp    8011ad <fork_v0+0x86>
		panic("sys_exofork failed");
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	68 2c 2b 80 00       	push   $0x802b2c
  80116a:	6a 2b                	push   $0x2b
  80116c:	68 fa 2a 80 00       	push   $0x802afa
  801171:	e8 e8 f0 ff ff       	call   80025e <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801176:	e8 69 fb ff ff       	call   800ce4 <sys_getenvid>
  80117b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801180:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801183:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801188:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80118d:	eb 68                	jmp    8011f7 <fork_v0+0xd0>
				dup_or_share(envid,
  80118f:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801195:	89 da                	mov    %ebx,%edx
  801197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119a:	e8 bb fd ff ff       	call   800f5a <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  80119f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011a5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8011ab:	74 36                	je     8011e3 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  8011ad:	89 d8                	mov    %ebx,%eax
  8011af:	c1 e8 16             	shr    $0x16,%eax
  8011b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011b9:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  8011bb:	f6 02 01             	testb  $0x1,(%edx)
  8011be:	74 df                	je     80119f <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  8011c0:	89 da                	mov    %ebx,%edx
  8011c2:	c1 ea 0a             	shr    $0xa,%edx
  8011c5:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8011cb:	c1 e0 0c             	shl    $0xc,%eax
  8011ce:	89 f9                	mov    %edi,%ecx
  8011d0:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  8011d6:	09 c8                	or     %ecx,%eax
  8011d8:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  8011da:	8b 08                	mov    (%eax),%ecx
  8011dc:	f6 c1 01             	test   $0x1,%cl
  8011df:	74 be                	je     80119f <fork_v0+0x78>
  8011e1:	eb ac                	jmp    80118f <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	6a 02                	push   $0x2
  8011e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011eb:	e8 c0 fb ff ff       	call   800db0 <sys_env_set_status>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 0b                	js     801202 <fork_v0+0xdb>
}
  8011f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	68 44 2a 80 00       	push   $0x802a44
  80120a:	6a 43                	push   $0x43
  80120c:	68 fa 2a 80 00       	push   $0x802afa
  801211:	e8 48 f0 ff ff       	call   80025e <_panic>

00801216 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801216:	f3 0f 1e fb          	endbr32 
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  801223:	68 33 10 80 00       	push   $0x801033
  801228:	e8 23 10 00 00       	call   802250 <set_pgfault_handler>
  80122d:	b8 07 00 00 00       	mov    $0x7,%eax
  801232:	cd 30                	int    $0x30
  801234:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 2f                	js     80126d <fork+0x57>
  80123e:	89 c7                	mov    %eax,%edi
  801240:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  801247:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80124b:	0f 85 9e 00 00 00    	jne    8012ef <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801251:	e8 8e fa ff ff       	call   800ce4 <sys_getenvid>
  801256:	25 ff 03 00 00       	and    $0x3ff,%eax
  80125b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80125e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801263:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801268:	e9 de 00 00 00       	jmp    80134b <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  80126d:	50                   	push   %eax
  80126e:	68 6c 2a 80 00       	push   $0x802a6c
  801273:	68 c2 00 00 00       	push   $0xc2
  801278:	68 fa 2a 80 00       	push   $0x802afa
  80127d:	e8 dc ef ff ff       	call   80025e <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801282:	83 ec 04             	sub    $0x4,%esp
  801285:	6a 07                	push   $0x7
  801287:	68 00 f0 bf ee       	push   $0xeebff000
  80128c:	57                   	push   %edi
  80128d:	e8 a5 fa ff ff       	call   800d37 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	75 33                	jne    8012cc <fork+0xb6>
  801299:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  80129c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012a2:	74 3d                	je     8012e1 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  8012a4:	89 d8                	mov    %ebx,%eax
  8012a6:	c1 e0 0c             	shl    $0xc,%eax
  8012a9:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	c1 ea 0c             	shr    $0xc,%edx
  8012b0:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  8012b7:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  8012bc:	74 c4                	je     801282 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  8012be:	f6 c1 01             	test   $0x1,%cl
  8012c1:	74 d6                	je     801299 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  8012c3:	89 f8                	mov    %edi,%eax
  8012c5:	e8 aa fb ff ff       	call   800e74 <duppage>
  8012ca:	eb cd                	jmp    801299 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  8012cc:	50                   	push   %eax
  8012cd:	68 8c 2a 80 00       	push   $0x802a8c
  8012d2:	68 e1 00 00 00       	push   $0xe1
  8012d7:	68 fa 2a 80 00       	push   $0x802afa
  8012dc:	e8 7d ef ff ff       	call   80025e <_panic>
  8012e1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8012e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8012e8:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8012ed:	74 18                	je     801307 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8012ef:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012f2:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8012f9:	a8 01                	test   $0x1,%al
  8012fb:	74 e4                	je     8012e1 <fork+0xcb>
  8012fd:	c1 e6 16             	shl    $0x16,%esi
  801300:	bb 00 00 00 00       	mov    $0x0,%ebx
  801305:	eb 9d                	jmp    8012a4 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	6a 07                	push   $0x7
  80130c:	68 00 f0 bf ee       	push   $0xeebff000
  801311:	ff 75 e0             	pushl  -0x20(%ebp)
  801314:	e8 1e fa ff ff       	call   800d37 <sys_page_alloc>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 36                	js     801356 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	68 ab 22 80 00       	push   $0x8022ab
  801328:	ff 75 e0             	pushl  -0x20(%ebp)
  80132b:	e8 ce fa ff ff       	call   800dfe <sys_env_set_pgfault_upcall>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 36                	js     80136d <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	6a 02                	push   $0x2
  80133c:	ff 75 e0             	pushl  -0x20(%ebp)
  80133f:	e8 6c fa ff ff       	call   800db0 <sys_env_set_status>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 39                	js     801384 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  80134b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801356:	83 ec 04             	sub    $0x4,%esp
  801359:	68 3f 2b 80 00       	push   $0x802b3f
  80135e:	68 f4 00 00 00       	push   $0xf4
  801363:	68 fa 2a 80 00       	push   $0x802afa
  801368:	e8 f1 ee ff ff       	call   80025e <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	68 b0 2a 80 00       	push   $0x802ab0
  801375:	68 f8 00 00 00       	push   $0xf8
  80137a:	68 fa 2a 80 00       	push   $0x802afa
  80137f:	e8 da ee ff ff       	call   80025e <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801384:	50                   	push   %eax
  801385:	68 d4 2a 80 00       	push   $0x802ad4
  80138a:	68 fc 00 00 00       	push   $0xfc
  80138f:	68 fa 2a 80 00       	push   $0x802afa
  801394:	e8 c5 ee ff ff       	call   80025e <_panic>

00801399 <sfork>:

// Challenge!
int
sfork(void)
{
  801399:	f3 0f 1e fb          	endbr32 
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8013a3:	68 57 2b 80 00       	push   $0x802b57
  8013a8:	68 05 01 00 00       	push   $0x105
  8013ad:	68 fa 2a 80 00       	push   $0x802afa
  8013b2:	e8 a7 ee ff ff       	call   80025e <_panic>

008013b7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013b7:	f3 0f 1e fb          	endbr32 
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8013d0:	0f 44 c2             	cmove  %edx,%eax
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	50                   	push   %eax
  8013d7:	e8 72 fa ff ff       	call   800e4e <sys_ipc_recv>

	if (from_env_store != NULL)
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 f6                	test   %esi,%esi
  8013e1:	74 15                	je     8013f8 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8013e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e8:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8013eb:	74 09                	je     8013f6 <ipc_recv+0x3f>
  8013ed:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013f3:	8b 52 74             	mov    0x74(%edx),%edx
  8013f6:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8013f8:	85 db                	test   %ebx,%ebx
  8013fa:	74 15                	je     801411 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8013fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801401:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801404:	74 09                	je     80140f <ipc_recv+0x58>
  801406:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80140c:	8b 52 78             	mov    0x78(%edx),%edx
  80140f:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801411:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801414:	74 08                	je     80141e <ipc_recv+0x67>
  801416:	a1 04 40 80 00       	mov    0x804004,%eax
  80141b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80141e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801425:	f3 0f 1e fb          	endbr32 
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	57                   	push   %edi
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	83 ec 0c             	sub    $0xc,%esp
  801432:	8b 7d 08             	mov    0x8(%ebp),%edi
  801435:	8b 75 0c             	mov    0xc(%ebp),%esi
  801438:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80143b:	eb 1f                	jmp    80145c <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  80143d:	6a 00                	push   $0x0
  80143f:	68 00 00 c0 ee       	push   $0xeec00000
  801444:	56                   	push   %esi
  801445:	57                   	push   %edi
  801446:	e8 da f9 ff ff       	call   800e25 <sys_ipc_try_send>
  80144b:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  80144e:	85 c0                	test   %eax,%eax
  801450:	74 30                	je     801482 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801452:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801455:	75 19                	jne    801470 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801457:	e8 b0 f8 ff ff       	call   800d0c <sys_yield>
		if (pg != NULL) {
  80145c:	85 db                	test   %ebx,%ebx
  80145e:	74 dd                	je     80143d <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801460:	ff 75 14             	pushl  0x14(%ebp)
  801463:	53                   	push   %ebx
  801464:	56                   	push   %esi
  801465:	57                   	push   %edi
  801466:	e8 ba f9 ff ff       	call   800e25 <sys_ipc_try_send>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	eb de                	jmp    80144e <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801470:	50                   	push   %eax
  801471:	68 6d 2b 80 00       	push   $0x802b6d
  801476:	6a 3e                	push   $0x3e
  801478:	68 7a 2b 80 00       	push   $0x802b7a
  80147d:	e8 dc ed ff ff       	call   80025e <_panic>
	}
}
  801482:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5f                   	pop    %edi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80148a:	f3 0f 1e fb          	endbr32 
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801499:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80149c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014a2:	8b 52 50             	mov    0x50(%edx),%edx
  8014a5:	39 ca                	cmp    %ecx,%edx
  8014a7:	74 11                	je     8014ba <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8014a9:	83 c0 01             	add    $0x1,%eax
  8014ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014b1:	75 e6                	jne    801499 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	eb 0b                	jmp    8014c5 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8014ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014c2:	8b 40 48             	mov    0x48(%eax),%eax
}
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014c7:	f3 0f 1e fb          	endbr32 
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d6:	c1 e8 0c             	shr    $0xc,%eax
}
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014db:	f3 0f 1e fb          	endbr32 
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8014e5:	ff 75 08             	pushl  0x8(%ebp)
  8014e8:	e8 da ff ff ff       	call   8014c7 <fd2num>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	c1 e0 0c             	shl    $0xc,%eax
  8014f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014fa:	f3 0f 1e fb          	endbr32 
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801506:	89 c2                	mov    %eax,%edx
  801508:	c1 ea 16             	shr    $0x16,%edx
  80150b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801512:	f6 c2 01             	test   $0x1,%dl
  801515:	74 2d                	je     801544 <fd_alloc+0x4a>
  801517:	89 c2                	mov    %eax,%edx
  801519:	c1 ea 0c             	shr    $0xc,%edx
  80151c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801523:	f6 c2 01             	test   $0x1,%dl
  801526:	74 1c                	je     801544 <fd_alloc+0x4a>
  801528:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80152d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801532:	75 d2                	jne    801506 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80153d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801542:	eb 0a                	jmp    80154e <fd_alloc+0x54>
			*fd_store = fd;
  801544:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801547:	89 01                	mov    %eax,(%ecx)
			return 0;
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801550:	f3 0f 1e fb          	endbr32 
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80155a:	83 f8 1f             	cmp    $0x1f,%eax
  80155d:	77 30                	ja     80158f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80155f:	c1 e0 0c             	shl    $0xc,%eax
  801562:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801567:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80156d:	f6 c2 01             	test   $0x1,%dl
  801570:	74 24                	je     801596 <fd_lookup+0x46>
  801572:	89 c2                	mov    %eax,%edx
  801574:	c1 ea 0c             	shr    $0xc,%edx
  801577:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80157e:	f6 c2 01             	test   $0x1,%dl
  801581:	74 1a                	je     80159d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801583:	8b 55 0c             	mov    0xc(%ebp),%edx
  801586:	89 02                	mov    %eax,(%edx)
	return 0;
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
		return -E_INVAL;
  80158f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801594:	eb f7                	jmp    80158d <fd_lookup+0x3d>
		return -E_INVAL;
  801596:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159b:	eb f0                	jmp    80158d <fd_lookup+0x3d>
  80159d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a2:	eb e9                	jmp    80158d <fd_lookup+0x3d>

008015a4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015a4:	f3 0f 1e fb          	endbr32 
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015b1:	ba 00 2c 80 00       	mov    $0x802c00,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015b6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8015bb:	39 08                	cmp    %ecx,(%eax)
  8015bd:	74 33                	je     8015f2 <dev_lookup+0x4e>
  8015bf:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8015c2:	8b 02                	mov    (%edx),%eax
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	75 f3                	jne    8015bb <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cd:	8b 40 48             	mov    0x48(%eax),%eax
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	51                   	push   %ecx
  8015d4:	50                   	push   %eax
  8015d5:	68 84 2b 80 00       	push   $0x802b84
  8015da:	e8 66 ed ff ff       	call   800345 <cprintf>
	*dev = 0;
  8015df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    
			*dev = devtab[i];
  8015f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fc:	eb f2                	jmp    8015f0 <dev_lookup+0x4c>

008015fe <fd_close>:
{
  8015fe:	f3 0f 1e fb          	endbr32 
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	57                   	push   %edi
  801606:	56                   	push   %esi
  801607:	53                   	push   %ebx
  801608:	83 ec 28             	sub    $0x28,%esp
  80160b:	8b 75 08             	mov    0x8(%ebp),%esi
  80160e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801611:	56                   	push   %esi
  801612:	e8 b0 fe ff ff       	call   8014c7 <fd2num>
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80161d:	52                   	push   %edx
  80161e:	50                   	push   %eax
  80161f:	e8 2c ff ff ff       	call   801550 <fd_lookup>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 05                	js     801632 <fd_close+0x34>
	    || fd != fd2)
  80162d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801630:	74 16                	je     801648 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801632:	89 f8                	mov    %edi,%eax
  801634:	84 c0                	test   %al,%al
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
  80163b:	0f 44 d8             	cmove  %eax,%ebx
}
  80163e:	89 d8                	mov    %ebx,%eax
  801640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5f                   	pop    %edi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 36                	pushl  (%esi)
  801651:	e8 4e ff ff ff       	call   8015a4 <dev_lookup>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1a                	js     801679 <fd_close+0x7b>
		if (dev->dev_close)
  80165f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801662:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801665:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80166a:	85 c0                	test   %eax,%eax
  80166c:	74 0b                	je     801679 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	56                   	push   %esi
  801672:	ff d0                	call   *%eax
  801674:	89 c3                	mov    %eax,%ebx
  801676:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	56                   	push   %esi
  80167d:	6a 00                	push   $0x0
  80167f:	e8 05 f7 ff ff       	call   800d89 <sys_page_unmap>
	return r;
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb b5                	jmp    80163e <fd_close+0x40>

00801689 <close>:

int
close(int fdnum)
{
  801689:	f3 0f 1e fb          	endbr32 
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	ff 75 08             	pushl  0x8(%ebp)
  80169a:	e8 b1 fe ff ff       	call   801550 <fd_lookup>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	79 02                	jns    8016a8 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    
		return fd_close(fd, 1);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	6a 01                	push   $0x1
  8016ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b0:	e8 49 ff ff ff       	call   8015fe <fd_close>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	eb ec                	jmp    8016a6 <close+0x1d>

008016ba <close_all>:

void
close_all(void)
{
  8016ba:	f3 0f 1e fb          	endbr32 
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	e8 b6 ff ff ff       	call   801689 <close>
	for (i = 0; i < MAXFD; i++)
  8016d3:	83 c3 01             	add    $0x1,%ebx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	83 fb 20             	cmp    $0x20,%ebx
  8016dc:	75 ec                	jne    8016ca <close_all+0x10>
}
  8016de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e3:	f3 0f 1e fb          	endbr32 
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 54 fe ff ff       	call   801550 <fd_lookup>
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	0f 88 81 00 00 00    	js     80178a <dup+0xa7>
		return r;
	close(newfdnum);
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	e8 75 ff ff ff       	call   801689 <close>

	newfd = INDEX2FD(newfdnum);
  801714:	8b 75 0c             	mov    0xc(%ebp),%esi
  801717:	c1 e6 0c             	shl    $0xc,%esi
  80171a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801720:	83 c4 04             	add    $0x4,%esp
  801723:	ff 75 e4             	pushl  -0x1c(%ebp)
  801726:	e8 b0 fd ff ff       	call   8014db <fd2data>
  80172b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80172d:	89 34 24             	mov    %esi,(%esp)
  801730:	e8 a6 fd ff ff       	call   8014db <fd2data>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80173a:	89 d8                	mov    %ebx,%eax
  80173c:	c1 e8 16             	shr    $0x16,%eax
  80173f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801746:	a8 01                	test   $0x1,%al
  801748:	74 11                	je     80175b <dup+0x78>
  80174a:	89 d8                	mov    %ebx,%eax
  80174c:	c1 e8 0c             	shr    $0xc,%eax
  80174f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801756:	f6 c2 01             	test   $0x1,%dl
  801759:	75 39                	jne    801794 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80175e:	89 d0                	mov    %edx,%eax
  801760:	c1 e8 0c             	shr    $0xc,%eax
  801763:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	25 07 0e 00 00       	and    $0xe07,%eax
  801772:	50                   	push   %eax
  801773:	56                   	push   %esi
  801774:	6a 00                	push   $0x0
  801776:	52                   	push   %edx
  801777:	6a 00                	push   $0x0
  801779:	e8 e1 f5 ff ff       	call   800d5f <sys_page_map>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 20             	add    $0x20,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 31                	js     8017b8 <dup+0xd5>
		goto err;

	return newfdnum;
  801787:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80178a:	89 d8                	mov    %ebx,%eax
  80178c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5f                   	pop    %edi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801794:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a3:	50                   	push   %eax
  8017a4:	57                   	push   %edi
  8017a5:	6a 00                	push   $0x0
  8017a7:	53                   	push   %ebx
  8017a8:	6a 00                	push   $0x0
  8017aa:	e8 b0 f5 ff ff       	call   800d5f <sys_page_map>
  8017af:	89 c3                	mov    %eax,%ebx
  8017b1:	83 c4 20             	add    $0x20,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	79 a3                	jns    80175b <dup+0x78>
	sys_page_unmap(0, newfd);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	56                   	push   %esi
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 c6 f5 ff ff       	call   800d89 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017c3:	83 c4 08             	add    $0x8,%esp
  8017c6:	57                   	push   %edi
  8017c7:	6a 00                	push   $0x0
  8017c9:	e8 bb f5 ff ff       	call   800d89 <sys_page_unmap>
	return r;
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	eb b7                	jmp    80178a <dup+0xa7>

008017d3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017d3:	f3 0f 1e fb          	endbr32 
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 1c             	sub    $0x1c,%esp
  8017de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e4:	50                   	push   %eax
  8017e5:	53                   	push   %ebx
  8017e6:	e8 65 fd ff ff       	call   801550 <fd_lookup>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 3f                	js     801831 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	ff 30                	pushl  (%eax)
  8017fe:	e8 a1 fd ff ff       	call   8015a4 <dev_lookup>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 27                	js     801831 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80180a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180d:	8b 42 08             	mov    0x8(%edx),%eax
  801810:	83 e0 03             	and    $0x3,%eax
  801813:	83 f8 01             	cmp    $0x1,%eax
  801816:	74 1e                	je     801836 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181b:	8b 40 08             	mov    0x8(%eax),%eax
  80181e:	85 c0                	test   %eax,%eax
  801820:	74 35                	je     801857 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801822:	83 ec 04             	sub    $0x4,%esp
  801825:	ff 75 10             	pushl  0x10(%ebp)
  801828:	ff 75 0c             	pushl  0xc(%ebp)
  80182b:	52                   	push   %edx
  80182c:	ff d0                	call   *%eax
  80182e:	83 c4 10             	add    $0x10,%esp
}
  801831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801834:	c9                   	leave  
  801835:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801836:	a1 04 40 80 00       	mov    0x804004,%eax
  80183b:	8b 40 48             	mov    0x48(%eax),%eax
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	53                   	push   %ebx
  801842:	50                   	push   %eax
  801843:	68 c5 2b 80 00       	push   $0x802bc5
  801848:	e8 f8 ea ff ff       	call   800345 <cprintf>
		return -E_INVAL;
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801855:	eb da                	jmp    801831 <read+0x5e>
		return -E_NOT_SUPP;
  801857:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80185c:	eb d3                	jmp    801831 <read+0x5e>

0080185e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80185e:	f3 0f 1e fb          	endbr32 
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	57                   	push   %edi
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801871:	bb 00 00 00 00       	mov    $0x0,%ebx
  801876:	eb 02                	jmp    80187a <readn+0x1c>
  801878:	01 c3                	add    %eax,%ebx
  80187a:	39 f3                	cmp    %esi,%ebx
  80187c:	73 21                	jae    80189f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187e:	83 ec 04             	sub    $0x4,%esp
  801881:	89 f0                	mov    %esi,%eax
  801883:	29 d8                	sub    %ebx,%eax
  801885:	50                   	push   %eax
  801886:	89 d8                	mov    %ebx,%eax
  801888:	03 45 0c             	add    0xc(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	57                   	push   %edi
  80188d:	e8 41 ff ff ff       	call   8017d3 <read>
		if (m < 0)
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	78 04                	js     80189d <readn+0x3f>
			return m;
		if (m == 0)
  801899:	75 dd                	jne    801878 <readn+0x1a>
  80189b:	eb 02                	jmp    80189f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80189d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80189f:	89 d8                	mov    %ebx,%eax
  8018a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5f                   	pop    %edi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018a9:	f3 0f 1e fb          	endbr32 
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 1c             	sub    $0x1c,%esp
  8018b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ba:	50                   	push   %eax
  8018bb:	53                   	push   %ebx
  8018bc:	e8 8f fc ff ff       	call   801550 <fd_lookup>
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 3a                	js     801902 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ce:	50                   	push   %eax
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	ff 30                	pushl  (%eax)
  8018d4:	e8 cb fc ff ff       	call   8015a4 <dev_lookup>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 22                	js     801902 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e7:	74 1e                	je     801907 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ef:	85 d2                	test   %edx,%edx
  8018f1:	74 35                	je     801928 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	ff 75 10             	pushl  0x10(%ebp)
  8018f9:	ff 75 0c             	pushl  0xc(%ebp)
  8018fc:	50                   	push   %eax
  8018fd:	ff d2                	call   *%edx
  8018ff:	83 c4 10             	add    $0x10,%esp
}
  801902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801905:	c9                   	leave  
  801906:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801907:	a1 04 40 80 00       	mov    0x804004,%eax
  80190c:	8b 40 48             	mov    0x48(%eax),%eax
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	53                   	push   %ebx
  801913:	50                   	push   %eax
  801914:	68 e1 2b 80 00       	push   $0x802be1
  801919:	e8 27 ea ff ff       	call   800345 <cprintf>
		return -E_INVAL;
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801926:	eb da                	jmp    801902 <write+0x59>
		return -E_NOT_SUPP;
  801928:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80192d:	eb d3                	jmp    801902 <write+0x59>

0080192f <seek>:

int
seek(int fdnum, off_t offset)
{
  80192f:	f3 0f 1e fb          	endbr32 
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801939:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193c:	50                   	push   %eax
  80193d:	ff 75 08             	pushl  0x8(%ebp)
  801940:	e8 0b fc ff ff       	call   801550 <fd_lookup>
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 0e                	js     80195a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80194c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80195c:	f3 0f 1e fb          	endbr32 
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	53                   	push   %ebx
  801964:	83 ec 1c             	sub    $0x1c,%esp
  801967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	53                   	push   %ebx
  80196f:	e8 dc fb ff ff       	call   801550 <fd_lookup>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 37                	js     8019b2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	ff 30                	pushl  (%eax)
  801987:	e8 18 fc ff ff       	call   8015a4 <dev_lookup>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 1f                	js     8019b2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801996:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80199a:	74 1b                	je     8019b7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80199c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199f:	8b 52 18             	mov    0x18(%edx),%edx
  8019a2:	85 d2                	test   %edx,%edx
  8019a4:	74 32                	je     8019d8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	50                   	push   %eax
  8019ad:	ff d2                	call   *%edx
  8019af:	83 c4 10             	add    $0x10,%esp
}
  8019b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8019b7:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019bc:	8b 40 48             	mov    0x48(%eax),%eax
  8019bf:	83 ec 04             	sub    $0x4,%esp
  8019c2:	53                   	push   %ebx
  8019c3:	50                   	push   %eax
  8019c4:	68 a4 2b 80 00       	push   $0x802ba4
  8019c9:	e8 77 e9 ff ff       	call   800345 <cprintf>
		return -E_INVAL;
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019d6:	eb da                	jmp    8019b2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8019d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019dd:	eb d3                	jmp    8019b2 <ftruncate+0x56>

008019df <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019df:	f3 0f 1e fb          	endbr32 
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 1c             	sub    $0x1c,%esp
  8019ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	ff 75 08             	pushl  0x8(%ebp)
  8019f4:	e8 57 fb ff ff       	call   801550 <fd_lookup>
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 4b                	js     801a4b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a06:	50                   	push   %eax
  801a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0a:	ff 30                	pushl  (%eax)
  801a0c:	e8 93 fb ff ff       	call   8015a4 <dev_lookup>
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 33                	js     801a4b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a1f:	74 2f                	je     801a50 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a21:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a24:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a2b:	00 00 00 
	stat->st_isdir = 0;
  801a2e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a35:	00 00 00 
	stat->st_dev = dev;
  801a38:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a3e:	83 ec 08             	sub    $0x8,%esp
  801a41:	53                   	push   %ebx
  801a42:	ff 75 f0             	pushl  -0x10(%ebp)
  801a45:	ff 50 14             	call   *0x14(%eax)
  801a48:	83 c4 10             	add    $0x10,%esp
}
  801a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    
		return -E_NOT_SUPP;
  801a50:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a55:	eb f4                	jmp    801a4b <fstat+0x6c>

00801a57 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a57:	f3 0f 1e fb          	endbr32 
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a60:	83 ec 08             	sub    $0x8,%esp
  801a63:	6a 00                	push   $0x0
  801a65:	ff 75 08             	pushl  0x8(%ebp)
  801a68:	e8 fb 01 00 00       	call   801c68 <open>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 1b                	js     801a91 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	ff 75 0c             	pushl  0xc(%ebp)
  801a7c:	50                   	push   %eax
  801a7d:	e8 5d ff ff ff       	call   8019df <fstat>
  801a82:	89 c6                	mov    %eax,%esi
	close(fd);
  801a84:	89 1c 24             	mov    %ebx,(%esp)
  801a87:	e8 fd fb ff ff       	call   801689 <close>
	return r;
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	89 f3                	mov    %esi,%ebx
}
  801a91:	89 d8                	mov    %ebx,%eax
  801a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	89 c6                	mov    %eax,%esi
  801aa1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801aa3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801aaa:	74 27                	je     801ad3 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aac:	6a 07                	push   $0x7
  801aae:	68 00 50 80 00       	push   $0x805000
  801ab3:	56                   	push   %esi
  801ab4:	ff 35 00 40 80 00    	pushl  0x804000
  801aba:	e8 66 f9 ff ff       	call   801425 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801abf:	83 c4 0c             	add    $0xc,%esp
  801ac2:	6a 00                	push   $0x0
  801ac4:	53                   	push   %ebx
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 eb f8 ff ff       	call   8013b7 <ipc_recv>
}
  801acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	6a 01                	push   $0x1
  801ad8:	e8 ad f9 ff ff       	call   80148a <ipc_find_env>
  801add:	a3 00 40 80 00       	mov    %eax,0x804000
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	eb c5                	jmp    801aac <fsipc+0x12>

00801ae7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ae7:	f3 0f 1e fb          	endbr32 
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	8b 40 0c             	mov    0xc(%eax),%eax
  801af7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aff:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0e:	e8 87 ff ff ff       	call   801a9a <fsipc>
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <devfile_flush>:
{
  801b15:	f3 0f 1e fb          	endbr32 
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	8b 40 0c             	mov    0xc(%eax),%eax
  801b25:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b34:	e8 61 ff ff ff       	call   801a9a <fsipc>
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <devfile_stat>:
{
  801b3b:	f3 0f 1e fb          	endbr32 
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	53                   	push   %ebx
  801b43:	83 ec 04             	sub    $0x4,%esp
  801b46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b54:	ba 00 00 00 00       	mov    $0x0,%edx
  801b59:	b8 05 00 00 00       	mov    $0x5,%eax
  801b5e:	e8 37 ff ff ff       	call   801a9a <fsipc>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 2c                	js     801b93 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	68 00 50 80 00       	push   $0x805000
  801b6f:	53                   	push   %ebx
  801b70:	e8 3a ed ff ff       	call   8008af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b75:	a1 80 50 80 00       	mov    0x805080,%eax
  801b7a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b80:	a1 84 50 80 00       	mov    0x805084,%eax
  801b85:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <devfile_write>:
{
  801b98:	f3 0f 1e fb          	endbr32 
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  801ba8:	8b 52 0c             	mov    0xc(%edx),%edx
  801bab:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801bb1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bb6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bbb:	0f 47 c2             	cmova  %edx,%eax
  801bbe:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801bc3:	50                   	push   %eax
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	68 08 50 80 00       	push   $0x805008
  801bcc:	e8 96 ee ff ff       	call   800a67 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  801bdb:	e8 ba fe ff ff       	call   801a9a <fsipc>
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devfile_read>:
{
  801be2:	f3 0f 1e fb          	endbr32 
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	56                   	push   %esi
  801bea:	53                   	push   %ebx
  801beb:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bee:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf1:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bf9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bff:	ba 00 00 00 00       	mov    $0x0,%edx
  801c04:	b8 03 00 00 00       	mov    $0x3,%eax
  801c09:	e8 8c fe ff ff       	call   801a9a <fsipc>
  801c0e:	89 c3                	mov    %eax,%ebx
  801c10:	85 c0                	test   %eax,%eax
  801c12:	78 1f                	js     801c33 <devfile_read+0x51>
	assert(r <= n);
  801c14:	39 f0                	cmp    %esi,%eax
  801c16:	77 24                	ja     801c3c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801c18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1d:	7f 33                	jg     801c52 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c1f:	83 ec 04             	sub    $0x4,%esp
  801c22:	50                   	push   %eax
  801c23:	68 00 50 80 00       	push   $0x805000
  801c28:	ff 75 0c             	pushl  0xc(%ebp)
  801c2b:	e8 37 ee ff ff       	call   800a67 <memmove>
	return r;
  801c30:	83 c4 10             	add    $0x10,%esp
}
  801c33:	89 d8                	mov    %ebx,%eax
  801c35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    
	assert(r <= n);
  801c3c:	68 10 2c 80 00       	push   $0x802c10
  801c41:	68 17 2c 80 00       	push   $0x802c17
  801c46:	6a 7c                	push   $0x7c
  801c48:	68 2c 2c 80 00       	push   $0x802c2c
  801c4d:	e8 0c e6 ff ff       	call   80025e <_panic>
	assert(r <= PGSIZE);
  801c52:	68 37 2c 80 00       	push   $0x802c37
  801c57:	68 17 2c 80 00       	push   $0x802c17
  801c5c:	6a 7d                	push   $0x7d
  801c5e:	68 2c 2c 80 00       	push   $0x802c2c
  801c63:	e8 f6 e5 ff ff       	call   80025e <_panic>

00801c68 <open>:
{
  801c68:	f3 0f 1e fb          	endbr32 
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 1c             	sub    $0x1c,%esp
  801c74:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c77:	56                   	push   %esi
  801c78:	e8 ef eb ff ff       	call   80086c <strlen>
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c85:	7f 6c                	jg     801cf3 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	e8 67 f8 ff ff       	call   8014fa <fd_alloc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 3c                	js     801cd8 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	56                   	push   %esi
  801ca0:	68 00 50 80 00       	push   $0x805000
  801ca5:	e8 05 ec ff ff       	call   8008af <strcpy>
	fsipcbuf.open.req_omode = mode;
  801caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cad:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cba:	e8 db fd ff ff       	call   801a9a <fsipc>
  801cbf:	89 c3                	mov    %eax,%ebx
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 19                	js     801ce1 <open+0x79>
	return fd2num(fd);
  801cc8:	83 ec 0c             	sub    $0xc,%esp
  801ccb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cce:	e8 f4 f7 ff ff       	call   8014c7 <fd2num>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 10             	add    $0x10,%esp
}
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    
		fd_close(fd, 0);
  801ce1:	83 ec 08             	sub    $0x8,%esp
  801ce4:	6a 00                	push   $0x0
  801ce6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce9:	e8 10 f9 ff ff       	call   8015fe <fd_close>
		return r;
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	eb e5                	jmp    801cd8 <open+0x70>
		return -E_BAD_PATH;
  801cf3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cf8:	eb de                	jmp    801cd8 <open+0x70>

00801cfa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cfa:	f3 0f 1e fb          	endbr32 
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d04:	ba 00 00 00 00       	mov    $0x0,%edx
  801d09:	b8 08 00 00 00       	mov    $0x8,%eax
  801d0e:	e8 87 fd ff ff       	call   801a9a <fsipc>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d15:	f3 0f 1e fb          	endbr32 
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d1f:	89 c2                	mov    %eax,%edx
  801d21:	c1 ea 16             	shr    $0x16,%edx
  801d24:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d2b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d30:	f6 c1 01             	test   $0x1,%cl
  801d33:	74 1c                	je     801d51 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801d35:	c1 e8 0c             	shr    $0xc,%eax
  801d38:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d3f:	a8 01                	test   $0x1,%al
  801d41:	74 0e                	je     801d51 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d43:	c1 e8 0c             	shr    $0xc,%eax
  801d46:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d4d:	ef 
  801d4e:	0f b7 d2             	movzwl %dx,%edx
}
  801d51:	89 d0                	mov    %edx,%eax
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    

00801d55 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d55:	f3 0f 1e fb          	endbr32 
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	ff 75 08             	pushl  0x8(%ebp)
  801d67:	e8 6f f7 ff ff       	call   8014db <fd2data>
  801d6c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d6e:	83 c4 08             	add    $0x8,%esp
  801d71:	68 43 2c 80 00       	push   $0x802c43
  801d76:	53                   	push   %ebx
  801d77:	e8 33 eb ff ff       	call   8008af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d7c:	8b 46 04             	mov    0x4(%esi),%eax
  801d7f:	2b 06                	sub    (%esi),%eax
  801d81:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d87:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d8e:	00 00 00 
	stat->st_dev = &devpipe;
  801d91:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d98:	30 80 00 
	return 0;
}
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801da0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801da7:	f3 0f 1e fb          	endbr32 
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 0c             	sub    $0xc,%esp
  801db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801db5:	53                   	push   %ebx
  801db6:	6a 00                	push   $0x0
  801db8:	e8 cc ef ff ff       	call   800d89 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dbd:	89 1c 24             	mov    %ebx,(%esp)
  801dc0:	e8 16 f7 ff ff       	call   8014db <fd2data>
  801dc5:	83 c4 08             	add    $0x8,%esp
  801dc8:	50                   	push   %eax
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 b9 ef ff ff       	call   800d89 <sys_page_unmap>
}
  801dd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <_pipeisclosed>:
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 1c             	sub    $0x1c,%esp
  801dde:	89 c7                	mov    %eax,%edi
  801de0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801de2:	a1 04 40 80 00       	mov    0x804004,%eax
  801de7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	57                   	push   %edi
  801dee:	e8 22 ff ff ff       	call   801d15 <pageref>
  801df3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801df6:	89 34 24             	mov    %esi,(%esp)
  801df9:	e8 17 ff ff ff       	call   801d15 <pageref>
		nn = thisenv->env_runs;
  801dfe:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	39 cb                	cmp    %ecx,%ebx
  801e0c:	74 1b                	je     801e29 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e0e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e11:	75 cf                	jne    801de2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e13:	8b 42 58             	mov    0x58(%edx),%eax
  801e16:	6a 01                	push   $0x1
  801e18:	50                   	push   %eax
  801e19:	53                   	push   %ebx
  801e1a:	68 4a 2c 80 00       	push   $0x802c4a
  801e1f:	e8 21 e5 ff ff       	call   800345 <cprintf>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	eb b9                	jmp    801de2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e29:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e2c:	0f 94 c0             	sete   %al
  801e2f:	0f b6 c0             	movzbl %al,%eax
}
  801e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e35:	5b                   	pop    %ebx
  801e36:	5e                   	pop    %esi
  801e37:	5f                   	pop    %edi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <devpipe_write>:
{
  801e3a:	f3 0f 1e fb          	endbr32 
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 28             	sub    $0x28,%esp
  801e47:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e4a:	56                   	push   %esi
  801e4b:	e8 8b f6 ff ff       	call   8014db <fd2data>
  801e50:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	bf 00 00 00 00       	mov    $0x0,%edi
  801e5a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e5d:	74 4f                	je     801eae <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e62:	8b 0b                	mov    (%ebx),%ecx
  801e64:	8d 51 20             	lea    0x20(%ecx),%edx
  801e67:	39 d0                	cmp    %edx,%eax
  801e69:	72 14                	jb     801e7f <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801e6b:	89 da                	mov    %ebx,%edx
  801e6d:	89 f0                	mov    %esi,%eax
  801e6f:	e8 61 ff ff ff       	call   801dd5 <_pipeisclosed>
  801e74:	85 c0                	test   %eax,%eax
  801e76:	75 3b                	jne    801eb3 <devpipe_write+0x79>
			sys_yield();
  801e78:	e8 8f ee ff ff       	call   800d0c <sys_yield>
  801e7d:	eb e0                	jmp    801e5f <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e82:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e86:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e89:	89 c2                	mov    %eax,%edx
  801e8b:	c1 fa 1f             	sar    $0x1f,%edx
  801e8e:	89 d1                	mov    %edx,%ecx
  801e90:	c1 e9 1b             	shr    $0x1b,%ecx
  801e93:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e96:	83 e2 1f             	and    $0x1f,%edx
  801e99:	29 ca                	sub    %ecx,%edx
  801e9b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e9f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ea3:	83 c0 01             	add    $0x1,%eax
  801ea6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ea9:	83 c7 01             	add    $0x1,%edi
  801eac:	eb ac                	jmp    801e5a <devpipe_write+0x20>
	return i;
  801eae:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb1:	eb 05                	jmp    801eb8 <devpipe_write+0x7e>
				return 0;
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <devpipe_read>:
{
  801ec0:	f3 0f 1e fb          	endbr32 
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 18             	sub    $0x18,%esp
  801ecd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ed0:	57                   	push   %edi
  801ed1:	e8 05 f6 ff ff       	call   8014db <fd2data>
  801ed6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	be 00 00 00 00       	mov    $0x0,%esi
  801ee0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee3:	75 14                	jne    801ef9 <devpipe_read+0x39>
	return i;
  801ee5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee8:	eb 02                	jmp    801eec <devpipe_read+0x2c>
				return i;
  801eea:	89 f0                	mov    %esi,%eax
}
  801eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5f                   	pop    %edi
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    
			sys_yield();
  801ef4:	e8 13 ee ff ff       	call   800d0c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ef9:	8b 03                	mov    (%ebx),%eax
  801efb:	3b 43 04             	cmp    0x4(%ebx),%eax
  801efe:	75 18                	jne    801f18 <devpipe_read+0x58>
			if (i > 0)
  801f00:	85 f6                	test   %esi,%esi
  801f02:	75 e6                	jne    801eea <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801f04:	89 da                	mov    %ebx,%edx
  801f06:	89 f8                	mov    %edi,%eax
  801f08:	e8 c8 fe ff ff       	call   801dd5 <_pipeisclosed>
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	74 e3                	je     801ef4 <devpipe_read+0x34>
				return 0;
  801f11:	b8 00 00 00 00       	mov    $0x0,%eax
  801f16:	eb d4                	jmp    801eec <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f18:	99                   	cltd   
  801f19:	c1 ea 1b             	shr    $0x1b,%edx
  801f1c:	01 d0                	add    %edx,%eax
  801f1e:	83 e0 1f             	and    $0x1f,%eax
  801f21:	29 d0                	sub    %edx,%eax
  801f23:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f2b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f2e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f31:	83 c6 01             	add    $0x1,%esi
  801f34:	eb aa                	jmp    801ee0 <devpipe_read+0x20>

00801f36 <pipe>:
{
  801f36:	f3 0f 1e fb          	endbr32 
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	56                   	push   %esi
  801f3e:	53                   	push   %ebx
  801f3f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f45:	50                   	push   %eax
  801f46:	e8 af f5 ff ff       	call   8014fa <fd_alloc>
  801f4b:	89 c3                	mov    %eax,%ebx
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 88 23 01 00 00    	js     80207b <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f58:	83 ec 04             	sub    $0x4,%esp
  801f5b:	68 07 04 00 00       	push   $0x407
  801f60:	ff 75 f4             	pushl  -0xc(%ebp)
  801f63:	6a 00                	push   $0x0
  801f65:	e8 cd ed ff ff       	call   800d37 <sys_page_alloc>
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	0f 88 04 01 00 00    	js     80207b <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7d:	50                   	push   %eax
  801f7e:	e8 77 f5 ff ff       	call   8014fa <fd_alloc>
  801f83:	89 c3                	mov    %eax,%ebx
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	0f 88 db 00 00 00    	js     80206b <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	68 07 04 00 00       	push   $0x407
  801f98:	ff 75 f0             	pushl  -0x10(%ebp)
  801f9b:	6a 00                	push   $0x0
  801f9d:	e8 95 ed ff ff       	call   800d37 <sys_page_alloc>
  801fa2:	89 c3                	mov    %eax,%ebx
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	0f 88 bc 00 00 00    	js     80206b <pipe+0x135>
	va = fd2data(fd0);
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb5:	e8 21 f5 ff ff       	call   8014db <fd2data>
  801fba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fbc:	83 c4 0c             	add    $0xc,%esp
  801fbf:	68 07 04 00 00       	push   $0x407
  801fc4:	50                   	push   %eax
  801fc5:	6a 00                	push   $0x0
  801fc7:	e8 6b ed ff ff       	call   800d37 <sys_page_alloc>
  801fcc:	89 c3                	mov    %eax,%ebx
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	0f 88 82 00 00 00    	js     80205b <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	ff 75 f0             	pushl  -0x10(%ebp)
  801fdf:	e8 f7 f4 ff ff       	call   8014db <fd2data>
  801fe4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801feb:	50                   	push   %eax
  801fec:	6a 00                	push   $0x0
  801fee:	56                   	push   %esi
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 69 ed ff ff       	call   800d5f <sys_page_map>
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	83 c4 20             	add    $0x20,%esp
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	78 4e                	js     80204d <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801fff:	a1 20 30 80 00       	mov    0x803020,%eax
  802004:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802007:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802009:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80200c:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802013:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802016:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802018:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80201b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802022:	83 ec 0c             	sub    $0xc,%esp
  802025:	ff 75 f4             	pushl  -0xc(%ebp)
  802028:	e8 9a f4 ff ff       	call   8014c7 <fd2num>
  80202d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802030:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802032:	83 c4 04             	add    $0x4,%esp
  802035:	ff 75 f0             	pushl  -0x10(%ebp)
  802038:	e8 8a f4 ff ff       	call   8014c7 <fd2num>
  80203d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802040:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80204b:	eb 2e                	jmp    80207b <pipe+0x145>
	sys_page_unmap(0, va);
  80204d:	83 ec 08             	sub    $0x8,%esp
  802050:	56                   	push   %esi
  802051:	6a 00                	push   $0x0
  802053:	e8 31 ed ff ff       	call   800d89 <sys_page_unmap>
  802058:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80205b:	83 ec 08             	sub    $0x8,%esp
  80205e:	ff 75 f0             	pushl  -0x10(%ebp)
  802061:	6a 00                	push   $0x0
  802063:	e8 21 ed ff ff       	call   800d89 <sys_page_unmap>
  802068:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80206b:	83 ec 08             	sub    $0x8,%esp
  80206e:	ff 75 f4             	pushl  -0xc(%ebp)
  802071:	6a 00                	push   $0x0
  802073:	e8 11 ed ff ff       	call   800d89 <sys_page_unmap>
  802078:	83 c4 10             	add    $0x10,%esp
}
  80207b:	89 d8                	mov    %ebx,%eax
  80207d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <pipeisclosed>:
{
  802084:	f3 0f 1e fb          	endbr32 
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	ff 75 08             	pushl  0x8(%ebp)
  802095:	e8 b6 f4 ff ff       	call   801550 <fd_lookup>
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 18                	js     8020b9 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a7:	e8 2f f4 ff ff       	call   8014db <fd2data>
  8020ac:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	e8 1f fd ff ff       	call   801dd5 <_pipeisclosed>
  8020b6:	83 c4 10             	add    $0x10,%esp
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020bb:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c4:	c3                   	ret    

008020c5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020c5:	f3 0f 1e fb          	endbr32 
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020cf:	68 62 2c 80 00       	push   $0x802c62
  8020d4:	ff 75 0c             	pushl  0xc(%ebp)
  8020d7:	e8 d3 e7 ff ff       	call   8008af <strcpy>
	return 0;
}
  8020dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e1:	c9                   	leave  
  8020e2:	c3                   	ret    

008020e3 <devcons_write>:
{
  8020e3:	f3 0f 1e fb          	endbr32 
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	57                   	push   %edi
  8020eb:	56                   	push   %esi
  8020ec:	53                   	push   %ebx
  8020ed:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020f3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020f8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8020fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  802101:	73 31                	jae    802134 <devcons_write+0x51>
		m = n - tot;
  802103:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802106:	29 f3                	sub    %esi,%ebx
  802108:	83 fb 7f             	cmp    $0x7f,%ebx
  80210b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802110:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802113:	83 ec 04             	sub    $0x4,%esp
  802116:	53                   	push   %ebx
  802117:	89 f0                	mov    %esi,%eax
  802119:	03 45 0c             	add    0xc(%ebp),%eax
  80211c:	50                   	push   %eax
  80211d:	57                   	push   %edi
  80211e:	e8 44 e9 ff ff       	call   800a67 <memmove>
		sys_cputs(buf, m);
  802123:	83 c4 08             	add    $0x8,%esp
  802126:	53                   	push   %ebx
  802127:	57                   	push   %edi
  802128:	e8 3f eb ff ff       	call   800c6c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80212d:	01 de                	add    %ebx,%esi
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	eb ca                	jmp    8020fe <devcons_write+0x1b>
}
  802134:	89 f0                	mov    %esi,%eax
  802136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802139:	5b                   	pop    %ebx
  80213a:	5e                   	pop    %esi
  80213b:	5f                   	pop    %edi
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    

0080213e <devcons_read>:
{
  80213e:	f3 0f 1e fb          	endbr32 
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 08             	sub    $0x8,%esp
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80214d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802151:	74 21                	je     802174 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802153:	e8 3e eb ff ff       	call   800c96 <sys_cgetc>
  802158:	85 c0                	test   %eax,%eax
  80215a:	75 07                	jne    802163 <devcons_read+0x25>
		sys_yield();
  80215c:	e8 ab eb ff ff       	call   800d0c <sys_yield>
  802161:	eb f0                	jmp    802153 <devcons_read+0x15>
	if (c < 0)
  802163:	78 0f                	js     802174 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802165:	83 f8 04             	cmp    $0x4,%eax
  802168:	74 0c                	je     802176 <devcons_read+0x38>
	*(char*)vbuf = c;
  80216a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80216d:	88 02                	mov    %al,(%edx)
	return 1;
  80216f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802174:	c9                   	leave  
  802175:	c3                   	ret    
		return 0;
  802176:	b8 00 00 00 00       	mov    $0x0,%eax
  80217b:	eb f7                	jmp    802174 <devcons_read+0x36>

0080217d <cputchar>:
{
  80217d:	f3 0f 1e fb          	endbr32 
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802187:	8b 45 08             	mov    0x8(%ebp),%eax
  80218a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80218d:	6a 01                	push   $0x1
  80218f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802192:	50                   	push   %eax
  802193:	e8 d4 ea ff ff       	call   800c6c <sys_cputs>
}
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	c9                   	leave  
  80219c:	c3                   	ret    

0080219d <getchar>:
{
  80219d:	f3 0f 1e fb          	endbr32 
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8021a7:	6a 01                	push   $0x1
  8021a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ac:	50                   	push   %eax
  8021ad:	6a 00                	push   $0x0
  8021af:	e8 1f f6 ff ff       	call   8017d3 <read>
	if (r < 0)
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	78 06                	js     8021c1 <getchar+0x24>
	if (r < 1)
  8021bb:	74 06                	je     8021c3 <getchar+0x26>
	return c;
  8021bd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    
		return -E_EOF;
  8021c3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8021c8:	eb f7                	jmp    8021c1 <getchar+0x24>

008021ca <iscons>:
{
  8021ca:	f3 0f 1e fb          	endbr32 
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d7:	50                   	push   %eax
  8021d8:	ff 75 08             	pushl  0x8(%ebp)
  8021db:	e8 70 f3 ff ff       	call   801550 <fd_lookup>
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	78 11                	js     8021f8 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8021e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021f0:	39 10                	cmp    %edx,(%eax)
  8021f2:	0f 94 c0             	sete   %al
  8021f5:	0f b6 c0             	movzbl %al,%eax
}
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    

008021fa <opencons>:
{
  8021fa:	f3 0f 1e fb          	endbr32 
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802207:	50                   	push   %eax
  802208:	e8 ed f2 ff ff       	call   8014fa <fd_alloc>
  80220d:	83 c4 10             	add    $0x10,%esp
  802210:	85 c0                	test   %eax,%eax
  802212:	78 3a                	js     80224e <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802214:	83 ec 04             	sub    $0x4,%esp
  802217:	68 07 04 00 00       	push   $0x407
  80221c:	ff 75 f4             	pushl  -0xc(%ebp)
  80221f:	6a 00                	push   $0x0
  802221:	e8 11 eb ff ff       	call   800d37 <sys_page_alloc>
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	85 c0                	test   %eax,%eax
  80222b:	78 21                	js     80224e <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80222d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802230:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802236:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802238:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802242:	83 ec 0c             	sub    $0xc,%esp
  802245:	50                   	push   %eax
  802246:	e8 7c f2 ff ff       	call   8014c7 <fd2num>
  80224b:	83 c4 10             	add    $0x10,%esp
}
  80224e:	c9                   	leave  
  80224f:	c3                   	ret    

00802250 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802250:	f3 0f 1e fb          	endbr32 
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80225a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802261:	74 1c                	je     80227f <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802263:	8b 45 08             	mov    0x8(%ebp),%eax
  802266:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  80226b:	83 ec 08             	sub    $0x8,%esp
  80226e:	68 ab 22 80 00       	push   $0x8022ab
  802273:	6a 00                	push   $0x0
  802275:	e8 84 eb ff ff       	call   800dfe <sys_env_set_pgfault_upcall>
}
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	c9                   	leave  
  80227e:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  80227f:	83 ec 04             	sub    $0x4,%esp
  802282:	6a 02                	push   $0x2
  802284:	68 00 f0 bf ee       	push   $0xeebff000
  802289:	6a 00                	push   $0x0
  80228b:	e8 a7 ea ff ff       	call   800d37 <sys_page_alloc>
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	85 c0                	test   %eax,%eax
  802295:	79 cc                	jns    802263 <set_pgfault_handler+0x13>
  802297:	83 ec 04             	sub    $0x4,%esp
  80229a:	68 6e 2c 80 00       	push   $0x802c6e
  80229f:	6a 20                	push   $0x20
  8022a1:	68 89 2c 80 00       	push   $0x802c89
  8022a6:	e8 b3 df ff ff       	call   80025e <_panic>

008022ab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022ab:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022ac:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022b1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022b3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  8022b6:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  8022ba:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8022be:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  8022c1:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  8022c3:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8022c7:	83 c4 08             	add    $0x8,%esp
	popal
  8022ca:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8022cb:	83 c4 04             	add    $0x4,%esp
	popfl
  8022ce:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8022cf:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8022d2:	c3                   	ret    
  8022d3:	66 90                	xchg   %ax,%ax
  8022d5:	66 90                	xchg   %ax,%ax
  8022d7:	66 90                	xchg   %ax,%ax
  8022d9:	66 90                	xchg   %ax,%ax
  8022db:	66 90                	xchg   %ax,%ax
  8022dd:	66 90                	xchg   %ax,%ax
  8022df:	90                   	nop

008022e0 <__udivdi3>:
  8022e0:	f3 0f 1e fb          	endbr32 
  8022e4:	55                   	push   %ebp
  8022e5:	57                   	push   %edi
  8022e6:	56                   	push   %esi
  8022e7:	53                   	push   %ebx
  8022e8:	83 ec 1c             	sub    $0x1c,%esp
  8022eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022fb:	85 d2                	test   %edx,%edx
  8022fd:	75 19                	jne    802318 <__udivdi3+0x38>
  8022ff:	39 f3                	cmp    %esi,%ebx
  802301:	76 4d                	jbe    802350 <__udivdi3+0x70>
  802303:	31 ff                	xor    %edi,%edi
  802305:	89 e8                	mov    %ebp,%eax
  802307:	89 f2                	mov    %esi,%edx
  802309:	f7 f3                	div    %ebx
  80230b:	89 fa                	mov    %edi,%edx
  80230d:	83 c4 1c             	add    $0x1c,%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    
  802315:	8d 76 00             	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	76 14                	jbe    802330 <__udivdi3+0x50>
  80231c:	31 ff                	xor    %edi,%edi
  80231e:	31 c0                	xor    %eax,%eax
  802320:	89 fa                	mov    %edi,%edx
  802322:	83 c4 1c             	add    $0x1c,%esp
  802325:	5b                   	pop    %ebx
  802326:	5e                   	pop    %esi
  802327:	5f                   	pop    %edi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    
  80232a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802330:	0f bd fa             	bsr    %edx,%edi
  802333:	83 f7 1f             	xor    $0x1f,%edi
  802336:	75 48                	jne    802380 <__udivdi3+0xa0>
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	72 06                	jb     802342 <__udivdi3+0x62>
  80233c:	31 c0                	xor    %eax,%eax
  80233e:	39 eb                	cmp    %ebp,%ebx
  802340:	77 de                	ja     802320 <__udivdi3+0x40>
  802342:	b8 01 00 00 00       	mov    $0x1,%eax
  802347:	eb d7                	jmp    802320 <__udivdi3+0x40>
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	89 d9                	mov    %ebx,%ecx
  802352:	85 db                	test   %ebx,%ebx
  802354:	75 0b                	jne    802361 <__udivdi3+0x81>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f3                	div    %ebx
  80235f:	89 c1                	mov    %eax,%ecx
  802361:	31 d2                	xor    %edx,%edx
  802363:	89 f0                	mov    %esi,%eax
  802365:	f7 f1                	div    %ecx
  802367:	89 c6                	mov    %eax,%esi
  802369:	89 e8                	mov    %ebp,%eax
  80236b:	89 f7                	mov    %esi,%edi
  80236d:	f7 f1                	div    %ecx
  80236f:	89 fa                	mov    %edi,%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	89 f9                	mov    %edi,%ecx
  802382:	b8 20 00 00 00       	mov    $0x20,%eax
  802387:	29 f8                	sub    %edi,%eax
  802389:	d3 e2                	shl    %cl,%edx
  80238b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80238f:	89 c1                	mov    %eax,%ecx
  802391:	89 da                	mov    %ebx,%edx
  802393:	d3 ea                	shr    %cl,%edx
  802395:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802399:	09 d1                	or     %edx,%ecx
  80239b:	89 f2                	mov    %esi,%edx
  80239d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	d3 e3                	shl    %cl,%ebx
  8023a5:	89 c1                	mov    %eax,%ecx
  8023a7:	d3 ea                	shr    %cl,%edx
  8023a9:	89 f9                	mov    %edi,%ecx
  8023ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023af:	89 eb                	mov    %ebp,%ebx
  8023b1:	d3 e6                	shl    %cl,%esi
  8023b3:	89 c1                	mov    %eax,%ecx
  8023b5:	d3 eb                	shr    %cl,%ebx
  8023b7:	09 de                	or     %ebx,%esi
  8023b9:	89 f0                	mov    %esi,%eax
  8023bb:	f7 74 24 08          	divl   0x8(%esp)
  8023bf:	89 d6                	mov    %edx,%esi
  8023c1:	89 c3                	mov    %eax,%ebx
  8023c3:	f7 64 24 0c          	mull   0xc(%esp)
  8023c7:	39 d6                	cmp    %edx,%esi
  8023c9:	72 15                	jb     8023e0 <__udivdi3+0x100>
  8023cb:	89 f9                	mov    %edi,%ecx
  8023cd:	d3 e5                	shl    %cl,%ebp
  8023cf:	39 c5                	cmp    %eax,%ebp
  8023d1:	73 04                	jae    8023d7 <__udivdi3+0xf7>
  8023d3:	39 d6                	cmp    %edx,%esi
  8023d5:	74 09                	je     8023e0 <__udivdi3+0x100>
  8023d7:	89 d8                	mov    %ebx,%eax
  8023d9:	31 ff                	xor    %edi,%edi
  8023db:	e9 40 ff ff ff       	jmp    802320 <__udivdi3+0x40>
  8023e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023e3:	31 ff                	xor    %edi,%edi
  8023e5:	e9 36 ff ff ff       	jmp    802320 <__udivdi3+0x40>
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	66 90                	xchg   %ax,%ax
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__umoddi3>:
  8023f0:	f3 0f 1e fb          	endbr32 
  8023f4:	55                   	push   %ebp
  8023f5:	57                   	push   %edi
  8023f6:	56                   	push   %esi
  8023f7:	53                   	push   %ebx
  8023f8:	83 ec 1c             	sub    $0x1c,%esp
  8023fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  802403:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802407:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80240b:	85 c0                	test   %eax,%eax
  80240d:	75 19                	jne    802428 <__umoddi3+0x38>
  80240f:	39 df                	cmp    %ebx,%edi
  802411:	76 5d                	jbe    802470 <__umoddi3+0x80>
  802413:	89 f0                	mov    %esi,%eax
  802415:	89 da                	mov    %ebx,%edx
  802417:	f7 f7                	div    %edi
  802419:	89 d0                	mov    %edx,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	83 c4 1c             	add    $0x1c,%esp
  802420:	5b                   	pop    %ebx
  802421:	5e                   	pop    %esi
  802422:	5f                   	pop    %edi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    
  802425:	8d 76 00             	lea    0x0(%esi),%esi
  802428:	89 f2                	mov    %esi,%edx
  80242a:	39 d8                	cmp    %ebx,%eax
  80242c:	76 12                	jbe    802440 <__umoddi3+0x50>
  80242e:	89 f0                	mov    %esi,%eax
  802430:	89 da                	mov    %ebx,%edx
  802432:	83 c4 1c             	add    $0x1c,%esp
  802435:	5b                   	pop    %ebx
  802436:	5e                   	pop    %esi
  802437:	5f                   	pop    %edi
  802438:	5d                   	pop    %ebp
  802439:	c3                   	ret    
  80243a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802440:	0f bd e8             	bsr    %eax,%ebp
  802443:	83 f5 1f             	xor    $0x1f,%ebp
  802446:	75 50                	jne    802498 <__umoddi3+0xa8>
  802448:	39 d8                	cmp    %ebx,%eax
  80244a:	0f 82 e0 00 00 00    	jb     802530 <__umoddi3+0x140>
  802450:	89 d9                	mov    %ebx,%ecx
  802452:	39 f7                	cmp    %esi,%edi
  802454:	0f 86 d6 00 00 00    	jbe    802530 <__umoddi3+0x140>
  80245a:	89 d0                	mov    %edx,%eax
  80245c:	89 ca                	mov    %ecx,%edx
  80245e:	83 c4 1c             	add    $0x1c,%esp
  802461:	5b                   	pop    %ebx
  802462:	5e                   	pop    %esi
  802463:	5f                   	pop    %edi
  802464:	5d                   	pop    %ebp
  802465:	c3                   	ret    
  802466:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	89 fd                	mov    %edi,%ebp
  802472:	85 ff                	test   %edi,%edi
  802474:	75 0b                	jne    802481 <__umoddi3+0x91>
  802476:	b8 01 00 00 00       	mov    $0x1,%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	f7 f7                	div    %edi
  80247f:	89 c5                	mov    %eax,%ebp
  802481:	89 d8                	mov    %ebx,%eax
  802483:	31 d2                	xor    %edx,%edx
  802485:	f7 f5                	div    %ebp
  802487:	89 f0                	mov    %esi,%eax
  802489:	f7 f5                	div    %ebp
  80248b:	89 d0                	mov    %edx,%eax
  80248d:	31 d2                	xor    %edx,%edx
  80248f:	eb 8c                	jmp    80241d <__umoddi3+0x2d>
  802491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802498:	89 e9                	mov    %ebp,%ecx
  80249a:	ba 20 00 00 00       	mov    $0x20,%edx
  80249f:	29 ea                	sub    %ebp,%edx
  8024a1:	d3 e0                	shl    %cl,%eax
  8024a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a7:	89 d1                	mov    %edx,%ecx
  8024a9:	89 f8                	mov    %edi,%eax
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024b9:	09 c1                	or     %eax,%ecx
  8024bb:	89 d8                	mov    %ebx,%eax
  8024bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024c1:	89 e9                	mov    %ebp,%ecx
  8024c3:	d3 e7                	shl    %cl,%edi
  8024c5:	89 d1                	mov    %edx,%ecx
  8024c7:	d3 e8                	shr    %cl,%eax
  8024c9:	89 e9                	mov    %ebp,%ecx
  8024cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024cf:	d3 e3                	shl    %cl,%ebx
  8024d1:	89 c7                	mov    %eax,%edi
  8024d3:	89 d1                	mov    %edx,%ecx
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	d3 e8                	shr    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	89 fa                	mov    %edi,%edx
  8024dd:	d3 e6                	shl    %cl,%esi
  8024df:	09 d8                	or     %ebx,%eax
  8024e1:	f7 74 24 08          	divl   0x8(%esp)
  8024e5:	89 d1                	mov    %edx,%ecx
  8024e7:	89 f3                	mov    %esi,%ebx
  8024e9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ed:	89 c6                	mov    %eax,%esi
  8024ef:	89 d7                	mov    %edx,%edi
  8024f1:	39 d1                	cmp    %edx,%ecx
  8024f3:	72 06                	jb     8024fb <__umoddi3+0x10b>
  8024f5:	75 10                	jne    802507 <__umoddi3+0x117>
  8024f7:	39 c3                	cmp    %eax,%ebx
  8024f9:	73 0c                	jae    802507 <__umoddi3+0x117>
  8024fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802503:	89 d7                	mov    %edx,%edi
  802505:	89 c6                	mov    %eax,%esi
  802507:	89 ca                	mov    %ecx,%edx
  802509:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80250e:	29 f3                	sub    %esi,%ebx
  802510:	19 fa                	sbb    %edi,%edx
  802512:	89 d0                	mov    %edx,%eax
  802514:	d3 e0                	shl    %cl,%eax
  802516:	89 e9                	mov    %ebp,%ecx
  802518:	d3 eb                	shr    %cl,%ebx
  80251a:	d3 ea                	shr    %cl,%edx
  80251c:	09 d8                	or     %ebx,%eax
  80251e:	83 c4 1c             	add    $0x1c,%esp
  802521:	5b                   	pop    %ebx
  802522:	5e                   	pop    %esi
  802523:	5f                   	pop    %edi
  802524:	5d                   	pop    %ebp
  802525:	c3                   	ret    
  802526:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80252d:	8d 76 00             	lea    0x0(%esi),%esi
  802530:	29 fe                	sub    %edi,%esi
  802532:	19 c3                	sbb    %eax,%ebx
  802534:	89 f2                	mov    %esi,%edx
  802536:	89 d9                	mov    %ebx,%ecx
  802538:	e9 1d ff ff ff       	jmp    80245a <__umoddi3+0x6a>
