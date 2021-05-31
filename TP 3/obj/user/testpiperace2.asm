
obj/user/testpiperace2.debug:     formato del fichero elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  800040:	68 20 25 80 00       	push   $0x802520
  800045:	e8 dd 02 00 00       	call   800327 <cprintf>
	if ((r = pipe(p)) < 0)
  80004a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004d:	89 04 24             	mov    %eax,(%esp)
  800050:	e8 73 1d 00 00       	call   801dc8 <pipe>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	85 c0                	test   %eax,%eax
  80005a:	78 5b                	js     8000b7 <umain+0x84>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  80005c:	e8 97 11 00 00       	call   8011f8 <fork>
  800061:	89 c7                	mov    %eax,%edi
  800063:	85 c0                	test   %eax,%eax
  800065:	78 62                	js     8000c9 <umain+0x96>
		panic("fork: %e", r);
	if (r == 0) {
  800067:	74 72                	je     8000db <umain+0xa8>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800069:	89 fb                	mov    %edi,%ebx
  80006b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  800071:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800074:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80007a:	8b 43 54             	mov    0x54(%ebx),%eax
  80007d:	83 f8 02             	cmp    $0x2,%eax
  800080:	0f 85 d1 00 00 00    	jne    800157 <umain+0x124>
		if (pipeisclosed(p[0]) != 0) {
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	ff 75 e0             	pushl  -0x20(%ebp)
  80008c:	e8 85 1e 00 00       	call   801f16 <pipeisclosed>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	74 e2                	je     80007a <umain+0x47>
			cprintf("\nRACE: pipe appears closed\n");
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	68 99 25 80 00       	push   $0x802599
  8000a0:	e8 82 02 00 00       	call   800327 <cprintf>
			sys_env_destroy(r);
  8000a5:	89 3c 24             	mov    %edi,(%esp)
  8000a8:	e8 f3 0b 00 00       	call   800ca0 <sys_env_destroy>
			exit();
  8000ad:	e8 70 01 00 00       	call   800222 <exit>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	eb c3                	jmp    80007a <umain+0x47>
		panic("pipe: %e", r);
  8000b7:	50                   	push   %eax
  8000b8:	68 6e 25 80 00       	push   $0x80256e
  8000bd:	6a 0d                	push   $0xd
  8000bf:	68 77 25 80 00       	push   $0x802577
  8000c4:	e8 77 01 00 00       	call   800240 <_panic>
		panic("fork: %e", r);
  8000c9:	50                   	push   %eax
  8000ca:	68 8c 25 80 00       	push   $0x80258c
  8000cf:	6a 0f                	push   $0xf
  8000d1:	68 77 25 80 00       	push   $0x802577
  8000d6:	e8 65 01 00 00       	call   800240 <_panic>
		close(p[1]);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e1:	e8 75 14 00 00       	call   80155b <close>
  8000e6:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  8000e9:	89 fb                	mov    %edi,%ebx
			if (i % 10 == 0)
  8000eb:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000f0:	eb 42                	jmp    800134 <umain+0x101>
				cprintf("%d.", i);
  8000f2:	83 ec 08             	sub    $0x8,%esp
  8000f5:	53                   	push   %ebx
  8000f6:	68 95 25 80 00       	push   $0x802595
  8000fb:	e8 27 02 00 00       	call   800327 <cprintf>
  800100:	83 c4 10             	add    $0x10,%esp
			dup(p[0], 10);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	6a 0a                	push   $0xa
  800108:	ff 75 e0             	pushl  -0x20(%ebp)
  80010b:	e8 a5 14 00 00       	call   8015b5 <dup>
			sys_yield();
  800110:	e8 d9 0b 00 00       	call   800cee <sys_yield>
			close(10);
  800115:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80011c:	e8 3a 14 00 00       	call   80155b <close>
			sys_yield();
  800121:	e8 c8 0b 00 00       	call   800cee <sys_yield>
		for (i = 0; i < 200; i++) {
  800126:	83 c3 01             	add    $0x1,%ebx
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800132:	74 19                	je     80014d <umain+0x11a>
			if (i % 10 == 0)
  800134:	89 d8                	mov    %ebx,%eax
  800136:	f7 ee                	imul   %esi
  800138:	c1 fa 02             	sar    $0x2,%edx
  80013b:	89 d8                	mov    %ebx,%eax
  80013d:	c1 f8 1f             	sar    $0x1f,%eax
  800140:	29 c2                	sub    %eax,%edx
  800142:	8d 04 92             	lea    (%edx,%edx,4),%eax
  800145:	01 c0                	add    %eax,%eax
  800147:	39 c3                	cmp    %eax,%ebx
  800149:	75 b8                	jne    800103 <umain+0xd0>
  80014b:	eb a5                	jmp    8000f2 <umain+0xbf>
		exit();
  80014d:	e8 d0 00 00 00       	call   800222 <exit>
  800152:	e9 12 ff ff ff       	jmp    800069 <umain+0x36>
		}
	cprintf("child done with loop\n");
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 b5 25 80 00       	push   $0x8025b5
  80015f:	e8 c3 01 00 00       	call   800327 <cprintf>
	if (pipeisclosed(p[0]))
  800164:	83 c4 04             	add    $0x4,%esp
  800167:	ff 75 e0             	pushl  -0x20(%ebp)
  80016a:	e8 a7 1d 00 00       	call   801f16 <pipeisclosed>
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	85 c0                	test   %eax,%eax
  800174:	75 38                	jne    8001ae <umain+0x17b>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017c:	50                   	push   %eax
  80017d:	ff 75 e0             	pushl  -0x20(%ebp)
  800180:	e8 9d 12 00 00       	call   801422 <fd_lookup>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	85 c0                	test   %eax,%eax
  80018a:	78 36                	js     8001c2 <umain+0x18f>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	ff 75 dc             	pushl  -0x24(%ebp)
  800192:	e8 16 12 00 00       	call   8013ad <fd2data>
	cprintf("race didn't happen\n");
  800197:	c7 04 24 e3 25 80 00 	movl   $0x8025e3,(%esp)
  80019e:	e8 84 01 00 00       	call   800327 <cprintf>
}
  8001a3:	83 c4 10             	add    $0x10,%esp
  8001a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5f                   	pop    %edi
  8001ac:	5d                   	pop    %ebp
  8001ad:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001ae:	83 ec 04             	sub    $0x4,%esp
  8001b1:	68 44 25 80 00       	push   $0x802544
  8001b6:	6a 40                	push   $0x40
  8001b8:	68 77 25 80 00       	push   $0x802577
  8001bd:	e8 7e 00 00 00       	call   800240 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c2:	50                   	push   %eax
  8001c3:	68 cb 25 80 00       	push   $0x8025cb
  8001c8:	6a 42                	push   $0x42
  8001ca:	68 77 25 80 00       	push   $0x802577
  8001cf:	e8 6c 00 00 00       	call   800240 <_panic>

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	f3 0f 1e fb          	endbr32 
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001e3:	e8 de 0a 00 00       	call   800cc6 <sys_getenvid>
	if (id >= 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	78 12                	js     8001fe <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	7e 07                	jle    800209 <libmain+0x35>
		binaryname = argv[0];
  800202:	8b 06                	mov    (%esi),%eax
  800204:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	e8 20 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800213:	e8 0a 00 00 00       	call   800222 <exit>
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800222:	f3 0f 1e fb          	endbr32 
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80022c:	e8 5b 13 00 00       	call   80158c <close_all>
	sys_env_destroy(0);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	6a 00                	push   $0x0
  800236:	e8 65 0a 00 00       	call   800ca0 <sys_env_destroy>
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800240:	f3 0f 1e fb          	endbr32 
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 6f 0a 00 00       	call   800cc6 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 04 26 80 00       	push   $0x802604
  800267:	e8 bb 00 00 00       	call   800327 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 5a 00 00 00       	call   8002d2 <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 07 2c 80 00 	movl   $0x802c07,(%esp)
  80027f:	e8 a3 00 00 00       	call   800327 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x47>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	f3 0f 1e fb          	endbr32 
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	53                   	push   %ebx
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800298:	8b 13                	mov    (%ebx),%edx
  80029a:	8d 42 01             	lea    0x1(%edx),%eax
  80029d:	89 03                	mov    %eax,(%ebx)
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ab:	74 09                	je     8002b6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	68 ff 00 00 00       	push   $0xff
  8002be:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c1:	50                   	push   %eax
  8002c2:	e8 87 09 00 00       	call   800c4e <sys_cputs>
		b->idx = 0;
  8002c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	eb db                	jmp    8002ad <putch+0x23>

008002d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d2:	f3 0f 1e fb          	endbr32 
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e6:	00 00 00 
	b.cnt = 0;
  8002e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	68 8a 02 80 00       	push   $0x80028a
  800305:	e8 80 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030a:	83 c4 08             	add    $0x8,%esp
  80030d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800313:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800319:	50                   	push   %eax
  80031a:	e8 2f 09 00 00       	call   800c4e <sys_cputs>

	return b.cnt;
}
  80031f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800327:	f3 0f 1e fb          	endbr32 
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800331:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 95 ff ff ff       	call   8002d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 1c             	sub    $0x1c,%esp
  800348:	89 c7                	mov    %eax,%edi
  80034a:	89 d6                	mov    %edx,%esi
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	89 d1                	mov    %edx,%ecx
  800354:	89 c2                	mov    %eax,%edx
  800356:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800359:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036c:	39 c2                	cmp    %eax,%edx
  80036e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800371:	72 3e                	jb     8003b1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800373:	83 ec 0c             	sub    $0xc,%esp
  800376:	ff 75 18             	pushl  0x18(%ebp)
  800379:	83 eb 01             	sub    $0x1,%ebx
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	ff 75 e4             	pushl  -0x1c(%ebp)
  800384:	ff 75 e0             	pushl  -0x20(%ebp)
  800387:	ff 75 dc             	pushl  -0x24(%ebp)
  80038a:	ff 75 d8             	pushl  -0x28(%ebp)
  80038d:	e8 2e 1f 00 00       	call   8022c0 <__udivdi3>
  800392:	83 c4 18             	add    $0x18,%esp
  800395:	52                   	push   %edx
  800396:	50                   	push   %eax
  800397:	89 f2                	mov    %esi,%edx
  800399:	89 f8                	mov    %edi,%eax
  80039b:	e8 9f ff ff ff       	call   80033f <printnum>
  8003a0:	83 c4 20             	add    $0x20,%esp
  8003a3:	eb 13                	jmp    8003b8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	56                   	push   %esi
  8003a9:	ff 75 18             	pushl  0x18(%ebp)
  8003ac:	ff d7                	call   *%edi
  8003ae:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b1:	83 eb 01             	sub    $0x1,%ebx
  8003b4:	85 db                	test   %ebx,%ebx
  8003b6:	7f ed                	jg     8003a5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b8:	83 ec 08             	sub    $0x8,%esp
  8003bb:	56                   	push   %esi
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cb:	e8 00 20 00 00       	call   8023d0 <__umoddi3>
  8003d0:	83 c4 14             	add    $0x14,%esp
  8003d3:	0f be 80 27 26 80 00 	movsbl 0x802627(%eax),%eax
  8003da:	50                   	push   %eax
  8003db:	ff d7                	call   *%edi
}
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e3:	5b                   	pop    %ebx
  8003e4:	5e                   	pop    %esi
  8003e5:	5f                   	pop    %edi
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003e8:	83 fa 01             	cmp    $0x1,%edx
  8003eb:	7f 13                	jg     800400 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 1c                	je     80040d <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 08             	lea    0x8(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	8b 52 04             	mov    0x4(%edx),%edx
  80040c:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80040d:	8b 10                	mov    (%eax),%edx
  80040f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800412:	89 08                	mov    %ecx,(%eax)
  800414:	8b 02                	mov    (%edx),%eax
  800416:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041b:	c3                   	ret    

0080041c <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80041c:	83 fa 01             	cmp    $0x1,%edx
  80041f:	7f 0f                	jg     800430 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800421:	85 d2                	test   %edx,%edx
  800423:	74 18                	je     80043d <getint+0x21>
		return va_arg(*ap, long);
  800425:	8b 10                	mov    (%eax),%edx
  800427:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042a:	89 08                	mov    %ecx,(%eax)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	99                   	cltd   
  80042f:	c3                   	ret    
		return va_arg(*ap, long long);
  800430:	8b 10                	mov    (%eax),%edx
  800432:	8d 4a 08             	lea    0x8(%edx),%ecx
  800435:	89 08                	mov    %ecx,(%eax)
  800437:	8b 02                	mov    (%edx),%eax
  800439:	8b 52 04             	mov    0x4(%edx),%edx
  80043c:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800442:	89 08                	mov    %ecx,(%eax)
  800444:	8b 02                	mov    (%edx),%eax
  800446:	99                   	cltd   
}
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	f3 0f 1e fb          	endbr32 
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800452:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800456:	8b 10                	mov    (%eax),%edx
  800458:	3b 50 04             	cmp    0x4(%eax),%edx
  80045b:	73 0a                	jae    800467 <sprintputch+0x1f>
		*b->buf++ = ch;
  80045d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800460:	89 08                	mov    %ecx,(%eax)
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	88 02                	mov    %al,(%edx)
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <printfmt>:
{
  800469:	f3 0f 1e fb          	endbr32 
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800473:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800476:	50                   	push   %eax
  800477:	ff 75 10             	pushl  0x10(%ebp)
  80047a:	ff 75 0c             	pushl  0xc(%ebp)
  80047d:	ff 75 08             	pushl  0x8(%ebp)
  800480:	e8 05 00 00 00       	call   80048a <vprintfmt>
}
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
{
  80048a:	f3 0f 1e fb          	endbr32 
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	53                   	push   %ebx
  800494:	83 ec 2c             	sub    $0x2c,%esp
  800497:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80049a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80049d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a0:	e9 86 02 00 00       	jmp    80072b <vprintfmt+0x2a1>
		padc = ' ';
  8004a5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8d 47 01             	lea    0x1(%edi),%eax
  8004c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c9:	0f b6 17             	movzbl (%edi),%edx
  8004cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004cf:	3c 55                	cmp    $0x55,%al
  8004d1:	0f 87 df 02 00 00    	ja     8007b6 <vprintfmt+0x32c>
  8004d7:	0f b6 c0             	movzbl %al,%eax
  8004da:	3e ff 24 85 60 27 80 	notrack jmp *0x802760(,%eax,4)
  8004e1:	00 
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004e5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004e9:	eb d8                	jmp    8004c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004f2:	eb cf                	jmp    8004c3 <vprintfmt+0x39>
  8004f4:	0f b6 d2             	movzbl %dl,%edx
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800502:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800505:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800509:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80050c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80050f:	83 f9 09             	cmp    $0x9,%ecx
  800512:	77 52                	ja     800566 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800514:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800517:	eb e9                	jmp    800502 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	79 93                	jns    8004c3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800530:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800533:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800536:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80053d:	eb 84                	jmp    8004c3 <vprintfmt+0x39>
  80053f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800542:	85 c0                	test   %eax,%eax
  800544:	ba 00 00 00 00       	mov    $0x0,%edx
  800549:	0f 49 d0             	cmovns %eax,%edx
  80054c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800552:	e9 6c ff ff ff       	jmp    8004c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80055a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800561:	e9 5d ff ff ff       	jmp    8004c3 <vprintfmt+0x39>
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80056c:	eb bc                	jmp    80052a <vprintfmt+0xa0>
			lflag++;
  80056e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800574:	e9 4a ff ff ff       	jmp    8004c3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	56                   	push   %esi
  800586:	ff 30                	pushl  (%eax)
  800588:	ff d3                	call   *%ebx
			break;
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	e9 96 01 00 00       	jmp    800728 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	99                   	cltd   
  80059e:	31 d0                	xor    %edx,%eax
  8005a0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a2:	83 f8 0f             	cmp    $0xf,%eax
  8005a5:	7f 20                	jg     8005c7 <vprintfmt+0x13d>
  8005a7:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	74 15                	je     8005c7 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8005b2:	52                   	push   %edx
  8005b3:	68 d5 2b 80 00       	push   $0x802bd5
  8005b8:	56                   	push   %esi
  8005b9:	53                   	push   %ebx
  8005ba:	e8 aa fe ff ff       	call   800469 <printfmt>
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	e9 61 01 00 00       	jmp    800728 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005c7:	50                   	push   %eax
  8005c8:	68 3f 26 80 00       	push   $0x80263f
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	e8 95 fe ff ff       	call   800469 <printfmt>
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	e9 4c 01 00 00       	jmp    800728 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	b8 38 26 80 00       	mov    $0x802638,%eax
  8005ee:	0f 45 c1             	cmovne %ecx,%eax
  8005f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f8:	7e 06                	jle    800600 <vprintfmt+0x176>
  8005fa:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005fe:	75 0d                	jne    80060d <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800600:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800603:	89 c7                	mov    %eax,%edi
  800605:	03 45 e0             	add    -0x20(%ebp),%eax
  800608:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060b:	eb 57                	jmp    800664 <vprintfmt+0x1da>
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 d8             	pushl  -0x28(%ebp)
  800613:	ff 75 cc             	pushl  -0x34(%ebp)
  800616:	e8 4f 02 00 00       	call   80086a <strnlen>
  80061b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80061e:	29 c2                	sub    %eax,%edx
  800620:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800623:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800626:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80062a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80062d:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	85 db                	test   %ebx,%ebx
  800631:	7e 10                	jle    800643 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	56                   	push   %esi
  800637:	57                   	push   %edi
  800638:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	83 eb 01             	sub    $0x1,%ebx
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb ec                	jmp    80062f <vprintfmt+0x1a5>
  800643:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800646:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800649:	85 d2                	test   %edx,%edx
  80064b:	b8 00 00 00 00       	mov    $0x0,%eax
  800650:	0f 49 c2             	cmovns %edx,%eax
  800653:	29 c2                	sub    %eax,%edx
  800655:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800658:	eb a6                	jmp    800600 <vprintfmt+0x176>
					putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	56                   	push   %esi
  80065e:	52                   	push   %edx
  80065f:	ff d3                	call   *%ebx
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800667:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800669:	83 c7 01             	add    $0x1,%edi
  80066c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800670:	0f be d0             	movsbl %al,%edx
  800673:	85 d2                	test   %edx,%edx
  800675:	74 42                	je     8006b9 <vprintfmt+0x22f>
  800677:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067b:	78 06                	js     800683 <vprintfmt+0x1f9>
  80067d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800681:	78 1e                	js     8006a1 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800683:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800687:	74 d1                	je     80065a <vprintfmt+0x1d0>
  800689:	0f be c0             	movsbl %al,%eax
  80068c:	83 e8 20             	sub    $0x20,%eax
  80068f:	83 f8 5e             	cmp    $0x5e,%eax
  800692:	76 c6                	jbe    80065a <vprintfmt+0x1d0>
					putch('?', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	56                   	push   %esi
  800698:	6a 3f                	push   $0x3f
  80069a:	ff d3                	call   *%ebx
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb c3                	jmp    800664 <vprintfmt+0x1da>
  8006a1:	89 cf                	mov    %ecx,%edi
  8006a3:	eb 0e                	jmp    8006b3 <vprintfmt+0x229>
				putch(' ', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	56                   	push   %esi
  8006a9:	6a 20                	push   $0x20
  8006ab:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8006ad:	83 ef 01             	sub    $0x1,%edi
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 ff                	test   %edi,%edi
  8006b5:	7f ee                	jg     8006a5 <vprintfmt+0x21b>
  8006b7:	eb 6f                	jmp    800728 <vprintfmt+0x29e>
  8006b9:	89 cf                	mov    %ecx,%edi
  8006bb:	eb f6                	jmp    8006b3 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 55 fd ff ff       	call   80041c <getint>
  8006c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	78 0b                	js     8006dc <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8006d1:	89 d1                	mov    %edx,%ecx
  8006d3:	89 c2                	mov    %eax,%edx
			base = 10;
  8006d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006da:	eb 32                	jmp    80070e <vprintfmt+0x284>
				putch('-', putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	56                   	push   %esi
  8006e0:	6a 2d                	push   $0x2d
  8006e2:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ea:	f7 da                	neg    %edx
  8006ec:	83 d1 00             	adc    $0x0,%ecx
  8006ef:	f7 d9                	neg    %ecx
  8006f1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f9:	eb 13                	jmp    80070e <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006fb:	89 ca                	mov    %ecx,%edx
  8006fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800700:	e8 e3 fc ff ff       	call   8003e8 <getuint>
  800705:	89 d1                	mov    %edx,%ecx
  800707:	89 c2                	mov    %eax,%edx
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800715:	57                   	push   %edi
  800716:	ff 75 e0             	pushl  -0x20(%ebp)
  800719:	50                   	push   %eax
  80071a:	51                   	push   %ecx
  80071b:	52                   	push   %edx
  80071c:	89 f2                	mov    %esi,%edx
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	e8 1a fc ff ff       	call   80033f <printnum>
			break;
  800725:	83 c4 20             	add    $0x20,%esp
{
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072b:	83 c7 01             	add    $0x1,%edi
  80072e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800732:	83 f8 25             	cmp    $0x25,%eax
  800735:	0f 84 6a fd ff ff    	je     8004a5 <vprintfmt+0x1b>
			if (ch == '\0')
  80073b:	85 c0                	test   %eax,%eax
  80073d:	0f 84 93 00 00 00    	je     8007d6 <vprintfmt+0x34c>
			putch(ch, putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	56                   	push   %esi
  800747:	50                   	push   %eax
  800748:	ff d3                	call   *%ebx
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb dc                	jmp    80072b <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80074f:	89 ca                	mov    %ecx,%edx
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 8f fc ff ff       	call   8003e8 <getuint>
  800759:	89 d1                	mov    %edx,%ecx
  80075b:	89 c2                	mov    %eax,%edx
			base = 8;
  80075d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800762:	eb aa                	jmp    80070e <vprintfmt+0x284>
			putch('0', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	56                   	push   %esi
  800768:	6a 30                	push   $0x30
  80076a:	ff d3                	call   *%ebx
			putch('x', putdat);
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	56                   	push   %esi
  800770:	6a 78                	push   $0x78
  800772:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800784:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800787:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80078c:	eb 80                	jmp    80070e <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80078e:	89 ca                	mov    %ecx,%edx
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	e8 50 fc ff ff       	call   8003e8 <getuint>
  800798:	89 d1                	mov    %edx,%ecx
  80079a:	89 c2                	mov    %eax,%edx
			base = 16;
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a1:	e9 68 ff ff ff       	jmp    80070e <vprintfmt+0x284>
			putch(ch, putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	56                   	push   %esi
  8007aa:	6a 25                	push   $0x25
  8007ac:	ff d3                	call   *%ebx
			break;
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	e9 72 ff ff ff       	jmp    800728 <vprintfmt+0x29e>
			putch('%', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	56                   	push   %esi
  8007ba:	6a 25                	push   $0x25
  8007bc:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	89 f8                	mov    %edi,%eax
  8007c3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c7:	74 05                	je     8007ce <vprintfmt+0x344>
  8007c9:	83 e8 01             	sub    $0x1,%eax
  8007cc:	eb f5                	jmp    8007c3 <vprintfmt+0x339>
  8007ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d1:	e9 52 ff ff ff       	jmp    800728 <vprintfmt+0x29e>
}
  8007d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5f                   	pop    %edi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007de:	f3 0f 1e fb          	endbr32 
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 18             	sub    $0x18,%esp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 26                	je     800829 <vsnprintf+0x4b>
  800803:	85 d2                	test   %edx,%edx
  800805:	7e 22                	jle    800829 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	ff 75 14             	pushl  0x14(%ebp)
  80080a:	ff 75 10             	pushl  0x10(%ebp)
  80080d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	68 48 04 80 00       	push   $0x800448
  800816:	e8 6f fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800824:	83 c4 10             	add    $0x10,%esp
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb f7                	jmp    800827 <vsnprintf+0x49>

00800830 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083d:	50                   	push   %eax
  80083e:	ff 75 10             	pushl  0x10(%ebp)
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 92 ff ff ff       	call   8007de <vsnprintf>
	va_end(ap);

	return rc;
}
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800861:	74 05                	je     800868 <strlen+0x1a>
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	eb f5                	jmp    80085d <strlen+0xf>
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	f3 0f 1e fb          	endbr32 
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	39 d0                	cmp    %edx,%eax
  80087e:	74 0d                	je     80088d <strnlen+0x23>
  800880:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800884:	74 05                	je     80088b <strnlen+0x21>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	eb f1                	jmp    80087c <strnlen+0x12>
  80088b:	89 c2                	mov    %eax,%edx
	return n;
}
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008b2:	89 c8                	mov    %ecx,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 10             	sub    $0x10,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	53                   	push   %ebx
  8008c6:	e8 83 ff ff ff       	call   80084e <strlen>
  8008cb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	50                   	push   %eax
  8008d4:	e8 b8 ff ff ff       	call   800891 <strcpy>
	return dst;
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 11                	je     80090b <strncpy+0x2b>
		*dst++ = *src;
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 0a             	movzbl (%edx),%ecx
  800900:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 f9 01             	cmp    $0x1,%cl
  800906:	83 da ff             	sbb    $0xffffffff,%edx
  800909:	eb eb                	jmp    8008f6 <strncpy+0x16>
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 75 08             	mov    0x8(%ebp),%esi
  80091d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800920:	8b 55 10             	mov    0x10(%ebp),%edx
  800923:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800925:	85 d2                	test   %edx,%edx
  800927:	74 21                	je     80094a <strlcpy+0x39>
  800929:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80092f:	39 c2                	cmp    %eax,%edx
  800931:	74 14                	je     800947 <strlcpy+0x36>
  800933:	0f b6 19             	movzbl (%ecx),%ebx
  800936:	84 db                	test   %bl,%bl
  800938:	74 0b                	je     800945 <strlcpy+0x34>
			*dst++ = *src++;
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	88 5a ff             	mov    %bl,-0x1(%edx)
  800943:	eb ea                	jmp    80092f <strlcpy+0x1e>
  800945:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800947:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094a:	29 f0                	sub    %esi,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 0c                	je     800970 <strcmp+0x20>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	75 08                	jne    800970 <strcmp+0x20>
		p++, q++;
  800968:	83 c1 01             	add    $0x1,%ecx
  80096b:	83 c2 01             	add    $0x1,%edx
  80096e:	eb ed                	jmp    80095d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 c0             	movzbl %al,%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097a:	f3 0f 1e fb          	endbr32 
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 c3                	mov    %eax,%ebx
  80098a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098d:	eb 06                	jmp    800995 <strncmp+0x1b>
		n--, p++, q++;
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800995:	39 d8                	cmp    %ebx,%eax
  800997:	74 16                	je     8009af <strncmp+0x35>
  800999:	0f b6 08             	movzbl (%eax),%ecx
  80099c:	84 c9                	test   %cl,%cl
  80099e:	74 04                	je     8009a4 <strncmp+0x2a>
  8009a0:	3a 0a                	cmp    (%edx),%cl
  8009a2:	74 eb                	je     80098f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	0f b6 00             	movzbl (%eax),%eax
  8009a7:	0f b6 12             	movzbl (%edx),%edx
  8009aa:	29 d0                	sub    %edx,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    
		return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	eb f6                	jmp    8009ac <strncmp+0x32>

008009b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b6:	f3 0f 1e fb          	endbr32 
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	0f b6 10             	movzbl (%eax),%edx
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	74 09                	je     8009d4 <strchr+0x1e>
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 0a                	je     8009d9 <strchr+0x23>
	for (; *s; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	eb f0                	jmp    8009c4 <strchr+0xe>
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	f3 0f 1e fb          	endbr32 
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	74 09                	je     8009f9 <strfind+0x1e>
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	74 05                	je     8009f9 <strfind+0x1e>
	for (; *s; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	eb f0                	jmp    8009e9 <strfind+0xe>
			break;
	return (char *) s;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fb:	f3 0f 1e fb          	endbr32 
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 55 08             	mov    0x8(%ebp),%edx
  800a08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a0b:	85 c9                	test   %ecx,%ecx
  800a0d:	74 33                	je     800a42 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0f:	89 d0                	mov    %edx,%eax
  800a11:	09 c8                	or     %ecx,%eax
  800a13:	a8 03                	test   $0x3,%al
  800a15:	75 23                	jne    800a3a <memset+0x3f>
		c &= 0xFF;
  800a17:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	c1 e0 08             	shl    $0x8,%eax
  800a20:	89 df                	mov    %ebx,%edi
  800a22:	c1 e7 18             	shl    $0x18,%edi
  800a25:	89 de                	mov    %ebx,%esi
  800a27:	c1 e6 10             	shl    $0x10,%esi
  800a2a:	09 f7                	or     %esi,%edi
  800a2c:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a31:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a33:	89 d7                	mov    %edx,%edi
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 08                	jmp    800a42 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	89 d7                	mov    %edx,%edi
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	fc                   	cld    
  800a40:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a49:	f3 0f 1e fb          	endbr32 
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5b:	39 c6                	cmp    %eax,%esi
  800a5d:	73 32                	jae    800a91 <memmove+0x48>
  800a5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a62:	39 c2                	cmp    %eax,%edx
  800a64:	76 2b                	jbe    800a91 <memmove+0x48>
		s += n;
		d += n;
  800a66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	89 fe                	mov    %edi,%esi
  800a6b:	09 ce                	or     %ecx,%esi
  800a6d:	09 d6                	or     %edx,%esi
  800a6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a75:	75 0e                	jne    800a85 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a77:	83 ef 04             	sub    $0x4,%edi
  800a7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a80:	fd                   	std    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 09                	jmp    800a8e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8b:	fd                   	std    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8e:	fc                   	cld    
  800a8f:	eb 1a                	jmp    800aab <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	09 ca                	or     %ecx,%edx
  800a95:	09 f2                	or     %esi,%edx
  800a97:	f6 c2 03             	test   $0x3,%dl
  800a9a:	75 0a                	jne    800aa6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 05                	jmp    800aab <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaf:	f3 0f 1e fb          	endbr32 
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab9:	ff 75 10             	pushl  0x10(%ebp)
  800abc:	ff 75 0c             	pushl  0xc(%ebp)
  800abf:	ff 75 08             	pushl  0x8(%ebp)
  800ac2:	e8 82 ff ff ff       	call   800a49 <memmove>
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac9:	f3 0f 1e fb          	endbr32 
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	39 f0                	cmp    %esi,%eax
  800adf:	74 1c                	je     800afd <memcmp+0x34>
		if (*s1 != *s2)
  800ae1:	0f b6 08             	movzbl (%eax),%ecx
  800ae4:	0f b6 1a             	movzbl (%edx),%ebx
  800ae7:	38 d9                	cmp    %bl,%cl
  800ae9:	75 08                	jne    800af3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	eb ea                	jmp    800add <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800af3:	0f b6 c1             	movzbl %cl,%eax
  800af6:	0f b6 db             	movzbl %bl,%ebx
  800af9:	29 d8                	sub    %ebx,%eax
  800afb:	eb 05                	jmp    800b02 <memcmp+0x39>
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	f3 0f 1e fb          	endbr32 
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b18:	39 d0                	cmp    %edx,%eax
  800b1a:	73 09                	jae    800b25 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1c:	38 08                	cmp    %cl,(%eax)
  800b1e:	74 05                	je     800b25 <memfind+0x1f>
	for (; s < ends; s++)
  800b20:	83 c0 01             	add    $0x1,%eax
  800b23:	eb f3                	jmp    800b18 <memfind+0x12>
			break;
	return (void *) s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b27:	f3 0f 1e fb          	endbr32 
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	eb 03                	jmp    800b3c <strtol+0x15>
		s++;
  800b39:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	3c 20                	cmp    $0x20,%al
  800b41:	74 f6                	je     800b39 <strtol+0x12>
  800b43:	3c 09                	cmp    $0x9,%al
  800b45:	74 f2                	je     800b39 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b47:	3c 2b                	cmp    $0x2b,%al
  800b49:	74 2a                	je     800b75 <strtol+0x4e>
	int neg = 0;
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b50:	3c 2d                	cmp    $0x2d,%al
  800b52:	74 2b                	je     800b7f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5a:	75 0f                	jne    800b6b <strtol+0x44>
  800b5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5f:	74 28                	je     800b89 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b61:	85 db                	test   %ebx,%ebx
  800b63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b68:	0f 44 d8             	cmove  %eax,%ebx
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b73:	eb 46                	jmp    800bbb <strtol+0x94>
		s++;
  800b75:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b78:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7d:	eb d5                	jmp    800b54 <strtol+0x2d>
		s++, neg = 1;
  800b7f:	83 c1 01             	add    $0x1,%ecx
  800b82:	bf 01 00 00 00       	mov    $0x1,%edi
  800b87:	eb cb                	jmp    800b54 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8d:	74 0e                	je     800b9d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b8f:	85 db                	test   %ebx,%ebx
  800b91:	75 d8                	jne    800b6b <strtol+0x44>
		s++, base = 8;
  800b93:	83 c1 01             	add    $0x1,%ecx
  800b96:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9b:	eb ce                	jmp    800b6b <strtol+0x44>
		s += 2, base = 16;
  800b9d:	83 c1 02             	add    $0x2,%ecx
  800ba0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba5:	eb c4                	jmp    800b6b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ba7:	0f be d2             	movsbl %dl,%edx
  800baa:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb0:	7d 3a                	jge    800bec <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bb2:	83 c1 01             	add    $0x1,%ecx
  800bb5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bbb:	0f b6 11             	movzbl (%ecx),%edx
  800bbe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 09             	cmp    $0x9,%bl
  800bc6:	76 df                	jbe    800ba7 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 08                	ja     800bda <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd2:	0f be d2             	movsbl %dl,%edx
  800bd5:	83 ea 57             	sub    $0x57,%edx
  800bd8:	eb d3                	jmp    800bad <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	80 fb 19             	cmp    $0x19,%bl
  800be2:	77 08                	ja     800bec <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be4:	0f be d2             	movsbl %dl,%edx
  800be7:	83 ea 37             	sub    $0x37,%edx
  800bea:	eb c1                	jmp    800bad <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf0:	74 05                	je     800bf7 <strtol+0xd0>
		*endptr = (char *) s;
  800bf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf7:	89 c2                	mov    %eax,%edx
  800bf9:	f7 da                	neg    %edx
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	0f 45 c2             	cmovne %edx,%eax
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 1c             	sub    $0x1c,%esp
  800c0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c14:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c1f:	8b 75 14             	mov    0x14(%ebp),%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c28:	74 04                	je     800c2e <syscall+0x29>
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7f 08                	jg     800c36 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3d:	68 1f 29 80 00       	push   $0x80291f
  800c42:	6a 23                	push   $0x23
  800c44:	68 3c 29 80 00       	push   $0x80293c
  800c49:	e8 f2 f5 ff ff       	call   800240 <_panic>

00800c4e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c4e:	f3 0f 1e fb          	endbr32 
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	6a 00                	push   $0x0
  800c5e:	ff 75 0c             	pushl  0xc(%ebp)
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	e8 92 ff ff ff       	call   800c05 <syscall>
}
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c78:	f3 0f 1e fb          	endbr32 
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c82:	6a 00                	push   $0x0
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 01 00 00 00       	mov    $0x1,%eax
  800c99:	e8 67 ff ff ff       	call   800c05 <syscall>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800caa:	6a 00                	push   $0x0
  800cac:	6a 00                	push   $0x0
  800cae:	6a 00                	push   $0x0
  800cb0:	6a 00                	push   $0x0
  800cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cba:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbf:	e8 41 ff ff ff       	call   800c05 <syscall>
}
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc6:	f3 0f 1e fb          	endbr32 
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cd0:	6a 00                	push   $0x0
  800cd2:	6a 00                	push   $0x0
  800cd4:	6a 00                	push   $0x0
  800cd6:	6a 00                	push   $0x0
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce7:	e8 19 ff ff ff       	call   800c05 <syscall>
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <sys_yield>:

void
sys_yield(void)
{
  800cee:	f3 0f 1e fb          	endbr32 
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800cf8:	6a 00                	push   $0x0
  800cfa:	6a 00                	push   $0x0
  800cfc:	6a 00                	push   $0x0
  800cfe:	6a 00                	push   $0x0
  800d00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d05:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0f:	e8 f1 fe ff ff       	call   800c05 <syscall>
}
  800d14:	83 c4 10             	add    $0x10,%esp
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d19:	f3 0f 1e fb          	endbr32 
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	ff 75 10             	pushl  0x10(%ebp)
  800d2a:	ff 75 0c             	pushl  0xc(%ebp)
  800d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d30:	ba 01 00 00 00       	mov    $0x1,%edx
  800d35:	b8 04 00 00 00       	mov    $0x4,%eax
  800d3a:	e8 c6 fe ff ff       	call   800c05 <syscall>
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d41:	f3 0f 1e fb          	endbr32 
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d4b:	ff 75 18             	pushl  0x18(%ebp)
  800d4e:	ff 75 14             	pushl  0x14(%ebp)
  800d51:	ff 75 10             	pushl  0x10(%ebp)
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d64:	e8 9c fe ff ff       	call   800c05 <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	ff 75 0c             	pushl  0xc(%ebp)
  800d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d81:	ba 01 00 00 00       	mov    $0x1,%edx
  800d86:	b8 06 00 00 00       	mov    $0x6,%eax
  800d8b:	e8 75 fe ff ff       	call   800c05 <syscall>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d92:	f3 0f 1e fb          	endbr32 
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d9c:	6a 00                	push   $0x0
  800d9e:	6a 00                	push   $0x0
  800da0:	6a 00                	push   $0x0
  800da2:	ff 75 0c             	pushl  0xc(%ebp)
  800da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da8:	ba 01 00 00 00       	mov    $0x1,%edx
  800dad:	b8 08 00 00 00       	mov    $0x8,%eax
  800db2:	e8 4e fe ff ff       	call   800c05 <syscall>
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db9:	f3 0f 1e fb          	endbr32 
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dc3:	6a 00                	push   $0x0
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	ff 75 0c             	pushl  0xc(%ebp)
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd9:	e8 27 fe ff ff       	call   800c05 <syscall>
}
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800dea:	6a 00                	push   $0x0
  800dec:	6a 00                	push   $0x0
  800dee:	6a 00                	push   $0x0
  800df0:	ff 75 0c             	pushl  0xc(%ebp)
  800df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df6:	ba 01 00 00 00       	mov    $0x1,%edx
  800dfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e00:	e8 00 fe ff ff       	call   800c05 <syscall>
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e11:	6a 00                	push   $0x0
  800e13:	ff 75 14             	pushl  0x14(%ebp)
  800e16:	ff 75 10             	pushl  0x10(%ebp)
  800e19:	ff 75 0c             	pushl  0xc(%ebp)
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e29:	e8 d7 fd ff ff       	call   800c05 <syscall>
}
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    

00800e30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e3a:	6a 00                	push   $0x0
  800e3c:	6a 00                	push   $0x0
  800e3e:	6a 00                	push   $0x0
  800e40:	6a 00                	push   $0x0
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4f:	e8 b1 fd ff ff       	call   800c05 <syscall>
}
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800e5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800e66:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800e69:	f6 c6 04             	test   $0x4,%dh
  800e6c:	75 54                	jne    800ec2 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800e6e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e74:	0f 84 8d 00 00 00    	je     800f07 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	68 05 08 00 00       	push   $0x805
  800e82:	53                   	push   %ebx
  800e83:	50                   	push   %eax
  800e84:	53                   	push   %ebx
  800e85:	6a 00                	push   $0x0
  800e87:	e8 b5 fe ff ff       	call   800d41 <sys_page_map>
		if (r < 0)
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 5f                	js     800ef2 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	68 05 08 00 00       	push   $0x805
  800e9b:	53                   	push   %ebx
  800e9c:	6a 00                	push   $0x0
  800e9e:	53                   	push   %ebx
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 9b fe ff ff       	call   800d41 <sys_page_map>
		if (r < 0)
  800ea6:	83 c4 20             	add    $0x20,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 70                	jns    800f1d <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ead:	50                   	push   %eax
  800eae:	68 4c 29 80 00       	push   $0x80294c
  800eb3:	68 9b 00 00 00       	push   $0x9b
  800eb8:	68 ba 2a 80 00       	push   $0x802aba
  800ebd:	e8 7e f3 ff ff       	call   800240 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800ec2:	83 ec 0c             	sub    $0xc,%esp
  800ec5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ecb:	52                   	push   %edx
  800ecc:	53                   	push   %ebx
  800ecd:	50                   	push   %eax
  800ece:	53                   	push   %ebx
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 6b fe ff ff       	call   800d41 <sys_page_map>
		if (r < 0)
  800ed6:	83 c4 20             	add    $0x20,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 40                	jns    800f1d <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800edd:	50                   	push   %eax
  800ede:	68 4c 29 80 00       	push   $0x80294c
  800ee3:	68 92 00 00 00       	push   $0x92
  800ee8:	68 ba 2a 80 00       	push   $0x802aba
  800eed:	e8 4e f3 ff ff       	call   800240 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ef2:	50                   	push   %eax
  800ef3:	68 4c 29 80 00       	push   $0x80294c
  800ef8:	68 97 00 00 00       	push   $0x97
  800efd:	68 ba 2a 80 00       	push   $0x802aba
  800f02:	e8 39 f3 ff ff       	call   800240 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	6a 05                	push   $0x5
  800f0c:	53                   	push   %ebx
  800f0d:	50                   	push   %eax
  800f0e:	53                   	push   %ebx
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 2b fe ff ff       	call   800d41 <sys_page_map>
		if (r < 0)
  800f16:	83 c4 20             	add    $0x20,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 0a                	js     800f27 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f27:	50                   	push   %eax
  800f28:	68 4c 29 80 00       	push   $0x80294c
  800f2d:	68 a0 00 00 00       	push   $0xa0
  800f32:	68 ba 2a 80 00       	push   $0x802aba
  800f37:	e8 04 f3 ff ff       	call   800240 <_panic>

00800f3c <dup_or_share>:
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	89 c7                	mov    %eax,%edi
  800f47:	89 d6                	mov    %edx,%esi
  800f49:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800f4b:	f6 c1 02             	test   $0x2,%cl
  800f4e:	0f 84 90 00 00 00    	je     800fe4 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	51                   	push   %ecx
  800f58:	52                   	push   %edx
  800f59:	50                   	push   %eax
  800f5a:	e8 ba fd ff ff       	call   800d19 <sys_page_alloc>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 56                	js     800fbc <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	53                   	push   %ebx
  800f6a:	68 00 00 40 00       	push   $0x400000
  800f6f:	6a 00                	push   $0x0
  800f71:	56                   	push   %esi
  800f72:	57                   	push   %edi
  800f73:	e8 c9 fd ff ff       	call   800d41 <sys_page_map>
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 51                	js     800fd0 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 00 10 00 00       	push   $0x1000
  800f87:	56                   	push   %esi
  800f88:	68 00 00 40 00       	push   $0x400000
  800f8d:	e8 b7 fa ff ff       	call   800a49 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f92:	83 c4 08             	add    $0x8,%esp
  800f95:	68 00 00 40 00       	push   $0x400000
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 ca fd ff ff       	call   800d6b <sys_page_unmap>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 51                	jns    800ff9 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 bc 29 80 00       	push   $0x8029bc
  800fb0:	6a 18                	push   $0x18
  800fb2:	68 ba 2a 80 00       	push   $0x802aba
  800fb7:	e8 84 f2 ff ff       	call   800240 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	68 70 29 80 00       	push   $0x802970
  800fc4:	6a 13                	push   $0x13
  800fc6:	68 ba 2a 80 00       	push   $0x802aba
  800fcb:	e8 70 f2 ff ff       	call   800240 <_panic>
			panic("sys_page_map failed at dup_or_share");
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	68 98 29 80 00       	push   $0x802998
  800fd8:	6a 15                	push   $0x15
  800fda:	68 ba 2a 80 00       	push   $0x802aba
  800fdf:	e8 5c f2 ff ff       	call   800240 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	51                   	push   %ecx
  800fe8:	52                   	push   %edx
  800fe9:	50                   	push   %eax
  800fea:	52                   	push   %edx
  800feb:	6a 00                	push   $0x0
  800fed:	e8 4f fd ff ff       	call   800d41 <sys_page_map>
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 08                	js     801001 <dup_or_share+0xc5>
}
  800ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	68 98 29 80 00       	push   $0x802998
  801009:	6a 1c                	push   $0x1c
  80100b:	68 ba 2a 80 00       	push   $0x802aba
  801010:	e8 2b f2 ff ff       	call   800240 <_panic>

00801015 <pgfault>:
{
  801015:	f3 0f 1e fb          	endbr32 
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	53                   	push   %ebx
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801023:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  801025:	89 da                	mov    %ebx,%edx
  801027:	c1 ea 0c             	shr    $0xc,%edx
  80102a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  801031:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801035:	74 6e                	je     8010a5 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  801037:	f6 c6 08             	test   $0x8,%dh
  80103a:	74 7d                	je     8010b9 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	6a 07                	push   $0x7
  801041:	68 00 f0 7f 00       	push   $0x7ff000
  801046:	6a 00                	push   $0x0
  801048:	e8 cc fc ff ff       	call   800d19 <sys_page_alloc>
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 79                	js     8010cd <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801054:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	68 00 10 00 00       	push   $0x1000
  801062:	53                   	push   %ebx
  801063:	68 00 f0 7f 00       	push   $0x7ff000
  801068:	e8 dc f9 ff ff       	call   800a49 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  80106d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801074:	53                   	push   %ebx
  801075:	6a 00                	push   $0x0
  801077:	68 00 f0 7f 00       	push   $0x7ff000
  80107c:	6a 00                	push   $0x0
  80107e:	e8 be fc ff ff       	call   800d41 <sys_page_map>
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 57                	js     8010e1 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	68 00 f0 7f 00       	push   $0x7ff000
  801092:	6a 00                	push   $0x0
  801094:	e8 d2 fc ff ff       	call   800d6b <sys_page_unmap>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 55                	js     8010f5 <pgfault+0xe0>
}
  8010a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	68 c5 2a 80 00       	push   $0x802ac5
  8010ad:	6a 5e                	push   $0x5e
  8010af:	68 ba 2a 80 00       	push   $0x802aba
  8010b4:	e8 87 f1 ff ff       	call   800240 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	68 e4 29 80 00       	push   $0x8029e4
  8010c1:	6a 62                	push   $0x62
  8010c3:	68 ba 2a 80 00       	push   $0x802aba
  8010c8:	e8 73 f1 ff ff       	call   800240 <_panic>
		panic("pgfault failed");
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	68 dd 2a 80 00       	push   $0x802add
  8010d5:	6a 6d                	push   $0x6d
  8010d7:	68 ba 2a 80 00       	push   $0x802aba
  8010dc:	e8 5f f1 ff ff       	call   800240 <_panic>
		panic("pgfault failed");
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	68 dd 2a 80 00       	push   $0x802add
  8010e9:	6a 72                	push   $0x72
  8010eb:	68 ba 2a 80 00       	push   $0x802aba
  8010f0:	e8 4b f1 ff ff       	call   800240 <_panic>
		panic("pgfault failed");
  8010f5:	83 ec 04             	sub    $0x4,%esp
  8010f8:	68 dd 2a 80 00       	push   $0x802add
  8010fd:	6a 74                	push   $0x74
  8010ff:	68 ba 2a 80 00       	push   $0x802aba
  801104:	e8 37 f1 ff ff       	call   800240 <_panic>

00801109 <fork_v0>:
{
  801109:	f3 0f 1e fb          	endbr32 
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801116:	b8 07 00 00 00       	mov    $0x7,%eax
  80111b:	cd 30                	int    $0x30
  80111d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801120:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	78 1d                	js     801144 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801127:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80112c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801130:	74 26                	je     801158 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801132:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801137:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  80113d:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801142:	eb 4b                	jmp    80118f <fork_v0+0x86>
		panic("sys_exofork failed");
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	68 ec 2a 80 00       	push   $0x802aec
  80114c:	6a 2b                	push   $0x2b
  80114e:	68 ba 2a 80 00       	push   $0x802aba
  801153:	e8 e8 f0 ff ff       	call   800240 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801158:	e8 69 fb ff ff       	call   800cc6 <sys_getenvid>
  80115d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801162:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801165:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80116a:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80116f:	eb 68                	jmp    8011d9 <fork_v0+0xd0>
				dup_or_share(envid,
  801171:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801177:	89 da                	mov    %ebx,%edx
  801179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80117c:	e8 bb fd ff ff       	call   800f3c <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801181:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801187:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80118d:	74 36                	je     8011c5 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	c1 e8 16             	shr    $0x16,%eax
  801194:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80119b:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  80119d:	f6 02 01             	testb  $0x1,(%edx)
  8011a0:	74 df                	je     801181 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  8011a2:	89 da                	mov    %ebx,%edx
  8011a4:	c1 ea 0a             	shr    $0xa,%edx
  8011a7:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8011ad:	c1 e0 0c             	shl    $0xc,%eax
  8011b0:	89 f9                	mov    %edi,%ecx
  8011b2:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  8011b8:	09 c8                	or     %ecx,%eax
  8011ba:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  8011bc:	8b 08                	mov    (%eax),%ecx
  8011be:	f6 c1 01             	test   $0x1,%cl
  8011c1:	74 be                	je     801181 <fork_v0+0x78>
  8011c3:	eb ac                	jmp    801171 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	6a 02                	push   $0x2
  8011ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cd:	e8 c0 fb ff ff       	call   800d92 <sys_env_set_status>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 0b                	js     8011e4 <fork_v0+0xdb>
}
  8011d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	68 04 2a 80 00       	push   $0x802a04
  8011ec:	6a 43                	push   $0x43
  8011ee:	68 ba 2a 80 00       	push   $0x802aba
  8011f3:	e8 48 f0 ff ff       	call   800240 <_panic>

008011f8 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8011f8:	f3 0f 1e fb          	endbr32 
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	57                   	push   %edi
  801200:	56                   	push   %esi
  801201:	53                   	push   %ebx
  801202:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  801205:	68 15 10 80 00       	push   $0x801015
  80120a:	e8 d3 0e 00 00       	call   8020e2 <set_pgfault_handler>
  80120f:	b8 07 00 00 00       	mov    $0x7,%eax
  801214:	cd 30                	int    $0x30
  801216:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 2f                	js     80124f <fork+0x57>
  801220:	89 c7                	mov    %eax,%edi
  801222:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  801229:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80122d:	0f 85 9e 00 00 00    	jne    8012d1 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801233:	e8 8e fa ff ff       	call   800cc6 <sys_getenvid>
  801238:	25 ff 03 00 00       	and    $0x3ff,%eax
  80123d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801245:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80124a:	e9 de 00 00 00       	jmp    80132d <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  80124f:	50                   	push   %eax
  801250:	68 2c 2a 80 00       	push   $0x802a2c
  801255:	68 c2 00 00 00       	push   $0xc2
  80125a:	68 ba 2a 80 00       	push   $0x802aba
  80125f:	e8 dc ef ff ff       	call   800240 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801264:	83 ec 04             	sub    $0x4,%esp
  801267:	6a 07                	push   $0x7
  801269:	68 00 f0 bf ee       	push   $0xeebff000
  80126e:	57                   	push   %edi
  80126f:	e8 a5 fa ff ff       	call   800d19 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	75 33                	jne    8012ae <fork+0xb6>
  80127b:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  80127e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801284:	74 3d                	je     8012c3 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801286:	89 d8                	mov    %ebx,%eax
  801288:	c1 e0 0c             	shl    $0xc,%eax
  80128b:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	c1 ea 0c             	shr    $0xc,%edx
  801292:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  801299:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  80129e:	74 c4                	je     801264 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  8012a0:	f6 c1 01             	test   $0x1,%cl
  8012a3:	74 d6                	je     80127b <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  8012a5:	89 f8                	mov    %edi,%eax
  8012a7:	e8 aa fb ff ff       	call   800e56 <duppage>
  8012ac:	eb cd                	jmp    80127b <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  8012ae:	50                   	push   %eax
  8012af:	68 4c 2a 80 00       	push   $0x802a4c
  8012b4:	68 e1 00 00 00       	push   $0xe1
  8012b9:	68 ba 2a 80 00       	push   $0x802aba
  8012be:	e8 7d ef ff ff       	call   800240 <_panic>
  8012c3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8012c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8012ca:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8012cf:	74 18                	je     8012e9 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8012d1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012d4:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8012db:	a8 01                	test   $0x1,%al
  8012dd:	74 e4                	je     8012c3 <fork+0xcb>
  8012df:	c1 e6 16             	shl    $0x16,%esi
  8012e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e7:	eb 9d                	jmp    801286 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	6a 07                	push   $0x7
  8012ee:	68 00 f0 bf ee       	push   $0xeebff000
  8012f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8012f6:	e8 1e fa ff ff       	call   800d19 <sys_page_alloc>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 36                	js     801338 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	68 3d 21 80 00       	push   $0x80213d
  80130a:	ff 75 e0             	pushl  -0x20(%ebp)
  80130d:	e8 ce fa ff ff       	call   800de0 <sys_env_set_pgfault_upcall>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 36                	js     80134f <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	6a 02                	push   $0x2
  80131e:	ff 75 e0             	pushl  -0x20(%ebp)
  801321:	e8 6c fa ff ff       	call   800d92 <sys_env_set_status>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 39                	js     801366 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  80132d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801338:	83 ec 04             	sub    $0x4,%esp
  80133b:	68 ff 2a 80 00       	push   $0x802aff
  801340:	68 f4 00 00 00       	push   $0xf4
  801345:	68 ba 2a 80 00       	push   $0x802aba
  80134a:	e8 f1 ee ff ff       	call   800240 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	68 70 2a 80 00       	push   $0x802a70
  801357:	68 f8 00 00 00       	push   $0xf8
  80135c:	68 ba 2a 80 00       	push   $0x802aba
  801361:	e8 da ee ff ff       	call   800240 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801366:	50                   	push   %eax
  801367:	68 94 2a 80 00       	push   $0x802a94
  80136c:	68 fc 00 00 00       	push   $0xfc
  801371:	68 ba 2a 80 00       	push   $0x802aba
  801376:	e8 c5 ee ff ff       	call   800240 <_panic>

0080137b <sfork>:

// Challenge!
int
sfork(void)
{
  80137b:	f3 0f 1e fb          	endbr32 
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801385:	68 17 2b 80 00       	push   $0x802b17
  80138a:	68 05 01 00 00       	push   $0x105
  80138f:	68 ba 2a 80 00       	push   $0x802aba
  801394:	e8 a7 ee ff ff       	call   800240 <_panic>

00801399 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801399:	f3 0f 1e fb          	endbr32 
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a8:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ad:	f3 0f 1e fb          	endbr32 
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8013b7:	ff 75 08             	pushl  0x8(%ebp)
  8013ba:	e8 da ff ff ff       	call   801399 <fd2num>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	c1 e0 0c             	shl    $0xc,%eax
  8013c5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013cc:	f3 0f 1e fb          	endbr32 
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	c1 ea 16             	shr    $0x16,%edx
  8013dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e4:	f6 c2 01             	test   $0x1,%dl
  8013e7:	74 2d                	je     801416 <fd_alloc+0x4a>
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	c1 ea 0c             	shr    $0xc,%edx
  8013ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	74 1c                	je     801416 <fd_alloc+0x4a>
  8013fa:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013ff:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801404:	75 d2                	jne    8013d8 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801406:	8b 45 08             	mov    0x8(%ebp),%eax
  801409:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80140f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801414:	eb 0a                	jmp    801420 <fd_alloc+0x54>
			*fd_store = fd;
  801416:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801419:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801422:	f3 0f 1e fb          	endbr32 
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80142c:	83 f8 1f             	cmp    $0x1f,%eax
  80142f:	77 30                	ja     801461 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801431:	c1 e0 0c             	shl    $0xc,%eax
  801434:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801439:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	74 24                	je     801468 <fd_lookup+0x46>
  801444:	89 c2                	mov    %eax,%edx
  801446:	c1 ea 0c             	shr    $0xc,%edx
  801449:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801450:	f6 c2 01             	test   $0x1,%dl
  801453:	74 1a                	je     80146f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801455:	8b 55 0c             	mov    0xc(%ebp),%edx
  801458:	89 02                	mov    %eax,(%edx)
	return 0;
  80145a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    
		return -E_INVAL;
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801466:	eb f7                	jmp    80145f <fd_lookup+0x3d>
		return -E_INVAL;
  801468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146d:	eb f0                	jmp    80145f <fd_lookup+0x3d>
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801474:	eb e9                	jmp    80145f <fd_lookup+0x3d>

00801476 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801476:	f3 0f 1e fb          	endbr32 
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801483:	ba ac 2b 80 00       	mov    $0x802bac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801488:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80148d:	39 08                	cmp    %ecx,(%eax)
  80148f:	74 33                	je     8014c4 <dev_lookup+0x4e>
  801491:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801494:	8b 02                	mov    (%edx),%eax
  801496:	85 c0                	test   %eax,%eax
  801498:	75 f3                	jne    80148d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149a:	a1 04 40 80 00       	mov    0x804004,%eax
  80149f:	8b 40 48             	mov    0x48(%eax),%eax
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	51                   	push   %ecx
  8014a6:	50                   	push   %eax
  8014a7:	68 30 2b 80 00       	push   $0x802b30
  8014ac:	e8 76 ee ff ff       	call   800327 <cprintf>
	*dev = 0;
  8014b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    
			*dev = devtab[i];
  8014c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ce:	eb f2                	jmp    8014c2 <dev_lookup+0x4c>

008014d0 <fd_close>:
{
  8014d0:	f3 0f 1e fb          	endbr32 
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	57                   	push   %edi
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 28             	sub    $0x28,%esp
  8014dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e3:	56                   	push   %esi
  8014e4:	e8 b0 fe ff ff       	call   801399 <fd2num>
  8014e9:	83 c4 08             	add    $0x8,%esp
  8014ec:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8014ef:	52                   	push   %edx
  8014f0:	50                   	push   %eax
  8014f1:	e8 2c ff ff ff       	call   801422 <fd_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 05                	js     801504 <fd_close+0x34>
	    || fd != fd2)
  8014ff:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801502:	74 16                	je     80151a <fd_close+0x4a>
		return (must_exist ? r : 0);
  801504:	89 f8                	mov    %edi,%eax
  801506:	84 c0                	test   %al,%al
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
  80150d:	0f 44 d8             	cmove  %eax,%ebx
}
  801510:	89 d8                	mov    %ebx,%eax
  801512:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5f                   	pop    %edi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	ff 36                	pushl  (%esi)
  801523:	e8 4e ff ff ff       	call   801476 <dev_lookup>
  801528:	89 c3                	mov    %eax,%ebx
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 1a                	js     80154b <fd_close+0x7b>
		if (dev->dev_close)
  801531:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801534:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801537:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80153c:	85 c0                	test   %eax,%eax
  80153e:	74 0b                	je     80154b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	56                   	push   %esi
  801544:	ff d0                	call   *%eax
  801546:	89 c3                	mov    %eax,%ebx
  801548:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	56                   	push   %esi
  80154f:	6a 00                	push   $0x0
  801551:	e8 15 f8 ff ff       	call   800d6b <sys_page_unmap>
	return r;
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	eb b5                	jmp    801510 <fd_close+0x40>

0080155b <close>:

int
close(int fdnum)
{
  80155b:	f3 0f 1e fb          	endbr32 
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	ff 75 08             	pushl  0x8(%ebp)
  80156c:	e8 b1 fe ff ff       	call   801422 <fd_lookup>
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	79 02                	jns    80157a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    
		return fd_close(fd, 1);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	6a 01                	push   $0x1
  80157f:	ff 75 f4             	pushl  -0xc(%ebp)
  801582:	e8 49 ff ff ff       	call   8014d0 <fd_close>
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	eb ec                	jmp    801578 <close+0x1d>

0080158c <close_all>:

void
close_all(void)
{
  80158c:	f3 0f 1e fb          	endbr32 
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801597:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	53                   	push   %ebx
  8015a0:	e8 b6 ff ff ff       	call   80155b <close>
	for (i = 0; i < MAXFD; i++)
  8015a5:	83 c3 01             	add    $0x1,%ebx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	83 fb 20             	cmp    $0x20,%ebx
  8015ae:	75 ec                	jne    80159c <close_all+0x10>
}
  8015b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015b5:	f3 0f 1e fb          	endbr32 
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	e8 54 fe ff ff       	call   801422 <fd_lookup>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	0f 88 81 00 00 00    	js     80165c <dup+0xa7>
		return r;
	close(newfdnum);
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	ff 75 0c             	pushl  0xc(%ebp)
  8015e1:	e8 75 ff ff ff       	call   80155b <close>

	newfd = INDEX2FD(newfdnum);
  8015e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015e9:	c1 e6 0c             	shl    $0xc,%esi
  8015ec:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015f2:	83 c4 04             	add    $0x4,%esp
  8015f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f8:	e8 b0 fd ff ff       	call   8013ad <fd2data>
  8015fd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015ff:	89 34 24             	mov    %esi,(%esp)
  801602:	e8 a6 fd ff ff       	call   8013ad <fd2data>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	c1 e8 16             	shr    $0x16,%eax
  801611:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801618:	a8 01                	test   $0x1,%al
  80161a:	74 11                	je     80162d <dup+0x78>
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801628:	f6 c2 01             	test   $0x1,%dl
  80162b:	75 39                	jne    801666 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80162d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801630:	89 d0                	mov    %edx,%eax
  801632:	c1 e8 0c             	shr    $0xc,%eax
  801635:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	25 07 0e 00 00       	and    $0xe07,%eax
  801644:	50                   	push   %eax
  801645:	56                   	push   %esi
  801646:	6a 00                	push   $0x0
  801648:	52                   	push   %edx
  801649:	6a 00                	push   $0x0
  80164b:	e8 f1 f6 ff ff       	call   800d41 <sys_page_map>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 20             	add    $0x20,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 31                	js     80168a <dup+0xd5>
		goto err;

	return newfdnum;
  801659:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801666:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80166d:	83 ec 0c             	sub    $0xc,%esp
  801670:	25 07 0e 00 00       	and    $0xe07,%eax
  801675:	50                   	push   %eax
  801676:	57                   	push   %edi
  801677:	6a 00                	push   $0x0
  801679:	53                   	push   %ebx
  80167a:	6a 00                	push   $0x0
  80167c:	e8 c0 f6 ff ff       	call   800d41 <sys_page_map>
  801681:	89 c3                	mov    %eax,%ebx
  801683:	83 c4 20             	add    $0x20,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	79 a3                	jns    80162d <dup+0x78>
	sys_page_unmap(0, newfd);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	56                   	push   %esi
  80168e:	6a 00                	push   $0x0
  801690:	e8 d6 f6 ff ff       	call   800d6b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801695:	83 c4 08             	add    $0x8,%esp
  801698:	57                   	push   %edi
  801699:	6a 00                	push   $0x0
  80169b:	e8 cb f6 ff ff       	call   800d6b <sys_page_unmap>
	return r;
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	eb b7                	jmp    80165c <dup+0xa7>

008016a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016a5:	f3 0f 1e fb          	endbr32 
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 1c             	sub    $0x1c,%esp
  8016b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	53                   	push   %ebx
  8016b8:	e8 65 fd ff ff       	call   801422 <fd_lookup>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 3f                	js     801703 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ce:	ff 30                	pushl  (%eax)
  8016d0:	e8 a1 fd ff ff       	call   801476 <dev_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 27                	js     801703 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016df:	8b 42 08             	mov    0x8(%edx),%eax
  8016e2:	83 e0 03             	and    $0x3,%eax
  8016e5:	83 f8 01             	cmp    $0x1,%eax
  8016e8:	74 1e                	je     801708 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ed:	8b 40 08             	mov    0x8(%eax),%eax
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	74 35                	je     801729 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	ff 75 10             	pushl  0x10(%ebp)
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	52                   	push   %edx
  8016fe:	ff d0                	call   *%eax
  801700:	83 c4 10             	add    $0x10,%esp
}
  801703:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801706:	c9                   	leave  
  801707:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801708:	a1 04 40 80 00       	mov    0x804004,%eax
  80170d:	8b 40 48             	mov    0x48(%eax),%eax
  801710:	83 ec 04             	sub    $0x4,%esp
  801713:	53                   	push   %ebx
  801714:	50                   	push   %eax
  801715:	68 71 2b 80 00       	push   $0x802b71
  80171a:	e8 08 ec ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801727:	eb da                	jmp    801703 <read+0x5e>
		return -E_NOT_SUPP;
  801729:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80172e:	eb d3                	jmp    801703 <read+0x5e>

00801730 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801730:	f3 0f 1e fb          	endbr32 
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	57                   	push   %edi
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801740:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801743:	bb 00 00 00 00       	mov    $0x0,%ebx
  801748:	eb 02                	jmp    80174c <readn+0x1c>
  80174a:	01 c3                	add    %eax,%ebx
  80174c:	39 f3                	cmp    %esi,%ebx
  80174e:	73 21                	jae    801771 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	89 f0                	mov    %esi,%eax
  801755:	29 d8                	sub    %ebx,%eax
  801757:	50                   	push   %eax
  801758:	89 d8                	mov    %ebx,%eax
  80175a:	03 45 0c             	add    0xc(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	57                   	push   %edi
  80175f:	e8 41 ff ff ff       	call   8016a5 <read>
		if (m < 0)
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 04                	js     80176f <readn+0x3f>
			return m;
		if (m == 0)
  80176b:	75 dd                	jne    80174a <readn+0x1a>
  80176d:	eb 02                	jmp    801771 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801771:	89 d8                	mov    %ebx,%eax
  801773:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5f                   	pop    %edi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80177b:	f3 0f 1e fb          	endbr32 
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	53                   	push   %ebx
  801783:	83 ec 1c             	sub    $0x1c,%esp
  801786:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801789:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	53                   	push   %ebx
  80178e:	e8 8f fc ff ff       	call   801422 <fd_lookup>
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	85 c0                	test   %eax,%eax
  801798:	78 3a                	js     8017d4 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	ff 30                	pushl  (%eax)
  8017a6:	e8 cb fc ff ff       	call   801476 <dev_lookup>
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 22                	js     8017d4 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b9:	74 1e                	je     8017d9 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017be:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c1:	85 d2                	test   %edx,%edx
  8017c3:	74 35                	je     8017fa <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	ff 75 10             	pushl  0x10(%ebp)
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	50                   	push   %eax
  8017cf:	ff d2                	call   *%edx
  8017d1:	83 c4 10             	add    $0x10,%esp
}
  8017d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8017de:	8b 40 48             	mov    0x48(%eax),%eax
  8017e1:	83 ec 04             	sub    $0x4,%esp
  8017e4:	53                   	push   %ebx
  8017e5:	50                   	push   %eax
  8017e6:	68 8d 2b 80 00       	push   $0x802b8d
  8017eb:	e8 37 eb ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f8:	eb da                	jmp    8017d4 <write+0x59>
		return -E_NOT_SUPP;
  8017fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ff:	eb d3                	jmp    8017d4 <write+0x59>

00801801 <seek>:

int
seek(int fdnum, off_t offset)
{
  801801:	f3 0f 1e fb          	endbr32 
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80180b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	ff 75 08             	pushl  0x8(%ebp)
  801812:	e8 0b fc ff ff       	call   801422 <fd_lookup>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 0e                	js     80182c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80181e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801824:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80182e:	f3 0f 1e fb          	endbr32 
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	53                   	push   %ebx
  801836:	83 ec 1c             	sub    $0x1c,%esp
  801839:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	53                   	push   %ebx
  801841:	e8 dc fb ff ff       	call   801422 <fd_lookup>
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 37                	js     801884 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801857:	ff 30                	pushl  (%eax)
  801859:	e8 18 fc ff ff       	call   801476 <dev_lookup>
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	78 1f                	js     801884 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801868:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80186c:	74 1b                	je     801889 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80186e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801871:	8b 52 18             	mov    0x18(%edx),%edx
  801874:	85 d2                	test   %edx,%edx
  801876:	74 32                	je     8018aa <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	ff 75 0c             	pushl  0xc(%ebp)
  80187e:	50                   	push   %eax
  80187f:	ff d2                	call   *%edx
  801881:	83 c4 10             	add    $0x10,%esp
}
  801884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801887:	c9                   	leave  
  801888:	c3                   	ret    
			thisenv->env_id, fdnum);
  801889:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188e:	8b 40 48             	mov    0x48(%eax),%eax
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	53                   	push   %ebx
  801895:	50                   	push   %eax
  801896:	68 50 2b 80 00       	push   $0x802b50
  80189b:	e8 87 ea ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a8:	eb da                	jmp    801884 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8018aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018af:	eb d3                	jmp    801884 <ftruncate+0x56>

008018b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b1:	f3 0f 1e fb          	endbr32 
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 1c             	sub    $0x1c,%esp
  8018bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c2:	50                   	push   %eax
  8018c3:	ff 75 08             	pushl  0x8(%ebp)
  8018c6:	e8 57 fb ff ff       	call   801422 <fd_lookup>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 4b                	js     80191d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d8:	50                   	push   %eax
  8018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dc:	ff 30                	pushl  (%eax)
  8018de:	e8 93 fb ff ff       	call   801476 <dev_lookup>
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 33                	js     80191d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ed:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f1:	74 2f                	je     801922 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018f6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018fd:	00 00 00 
	stat->st_isdir = 0;
  801900:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801907:	00 00 00 
	stat->st_dev = dev;
  80190a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	53                   	push   %ebx
  801914:	ff 75 f0             	pushl  -0x10(%ebp)
  801917:	ff 50 14             	call   *0x14(%eax)
  80191a:	83 c4 10             	add    $0x10,%esp
}
  80191d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801920:	c9                   	leave  
  801921:	c3                   	ret    
		return -E_NOT_SUPP;
  801922:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801927:	eb f4                	jmp    80191d <fstat+0x6c>

00801929 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801929:	f3 0f 1e fb          	endbr32 
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	6a 00                	push   $0x0
  801937:	ff 75 08             	pushl  0x8(%ebp)
  80193a:	e8 fb 01 00 00       	call   801b3a <open>
  80193f:	89 c3                	mov    %eax,%ebx
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 1b                	js     801963 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	ff 75 0c             	pushl  0xc(%ebp)
  80194e:	50                   	push   %eax
  80194f:	e8 5d ff ff ff       	call   8018b1 <fstat>
  801954:	89 c6                	mov    %eax,%esi
	close(fd);
  801956:	89 1c 24             	mov    %ebx,(%esp)
  801959:	e8 fd fb ff ff       	call   80155b <close>
	return r;
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	89 f3                	mov    %esi,%ebx
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	89 c6                	mov    %eax,%esi
  801973:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801975:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80197c:	74 27                	je     8019a5 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197e:	6a 07                	push   $0x7
  801980:	68 00 50 80 00       	push   $0x805000
  801985:	56                   	push   %esi
  801986:	ff 35 00 40 80 00    	pushl  0x804000
  80198c:	e8 42 08 00 00       	call   8021d3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801991:	83 c4 0c             	add    $0xc,%esp
  801994:	6a 00                	push   $0x0
  801996:	53                   	push   %ebx
  801997:	6a 00                	push   $0x0
  801999:	e8 c7 07 00 00       	call   802165 <ipc_recv>
}
  80199e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5e                   	pop    %esi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	6a 01                	push   $0x1
  8019aa:	e8 89 08 00 00       	call   802238 <ipc_find_env>
  8019af:	a3 00 40 80 00       	mov    %eax,0x804000
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	eb c5                	jmp    80197e <fsipc+0x12>

008019b9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b9:	f3 0f 1e fb          	endbr32 
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	b8 02 00 00 00       	mov    $0x2,%eax
  8019e0:	e8 87 ff ff ff       	call   80196c <fsipc>
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <devfile_flush>:
{
  8019e7:	f3 0f 1e fb          	endbr32 
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801a01:	b8 06 00 00 00       	mov    $0x6,%eax
  801a06:	e8 61 ff ff ff       	call   80196c <fsipc>
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <devfile_stat>:
{
  801a0d:	f3 0f 1e fb          	endbr32 
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	53                   	push   %ebx
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a21:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 05 00 00 00       	mov    $0x5,%eax
  801a30:	e8 37 ff ff ff       	call   80196c <fsipc>
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 2c                	js     801a65 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a39:	83 ec 08             	sub    $0x8,%esp
  801a3c:	68 00 50 80 00       	push   $0x805000
  801a41:	53                   	push   %ebx
  801a42:	e8 4a ee ff ff       	call   800891 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a47:	a1 80 50 80 00       	mov    0x805080,%eax
  801a4c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a52:	a1 84 50 80 00       	mov    0x805084,%eax
  801a57:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <devfile_write>:
{
  801a6a:	f3 0f 1e fb          	endbr32 
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a77:	8b 55 08             	mov    0x8(%ebp),%edx
  801a7a:	8b 52 0c             	mov    0xc(%edx),%edx
  801a7d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a83:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a88:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a8d:	0f 47 c2             	cmova  %edx,%eax
  801a90:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a95:	50                   	push   %eax
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	68 08 50 80 00       	push   $0x805008
  801a9e:	e8 a6 ef ff ff       	call   800a49 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa8:	b8 04 00 00 00       	mov    $0x4,%eax
  801aad:	e8 ba fe ff ff       	call   80196c <fsipc>
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <devfile_read>:
{
  801ab4:	f3 0f 1e fb          	endbr32 
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801acb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad6:	b8 03 00 00 00       	mov    $0x3,%eax
  801adb:	e8 8c fe ff ff       	call   80196c <fsipc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 1f                	js     801b05 <devfile_read+0x51>
	assert(r <= n);
  801ae6:	39 f0                	cmp    %esi,%eax
  801ae8:	77 24                	ja     801b0e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801aea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aef:	7f 33                	jg     801b24 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	50                   	push   %eax
  801af5:	68 00 50 80 00       	push   $0x805000
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	e8 47 ef ff ff       	call   800a49 <memmove>
	return r;
  801b02:	83 c4 10             	add    $0x10,%esp
}
  801b05:	89 d8                	mov    %ebx,%eax
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    
	assert(r <= n);
  801b0e:	68 bc 2b 80 00       	push   $0x802bbc
  801b13:	68 c3 2b 80 00       	push   $0x802bc3
  801b18:	6a 7c                	push   $0x7c
  801b1a:	68 d8 2b 80 00       	push   $0x802bd8
  801b1f:	e8 1c e7 ff ff       	call   800240 <_panic>
	assert(r <= PGSIZE);
  801b24:	68 e3 2b 80 00       	push   $0x802be3
  801b29:	68 c3 2b 80 00       	push   $0x802bc3
  801b2e:	6a 7d                	push   $0x7d
  801b30:	68 d8 2b 80 00       	push   $0x802bd8
  801b35:	e8 06 e7 ff ff       	call   800240 <_panic>

00801b3a <open>:
{
  801b3a:	f3 0f 1e fb          	endbr32 
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	83 ec 1c             	sub    $0x1c,%esp
  801b46:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b49:	56                   	push   %esi
  801b4a:	e8 ff ec ff ff       	call   80084e <strlen>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b57:	7f 6c                	jg     801bc5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5f:	50                   	push   %eax
  801b60:	e8 67 f8 ff ff       	call   8013cc <fd_alloc>
  801b65:	89 c3                	mov    %eax,%ebx
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	78 3c                	js     801baa <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b6e:	83 ec 08             	sub    $0x8,%esp
  801b71:	56                   	push   %esi
  801b72:	68 00 50 80 00       	push   $0x805000
  801b77:	e8 15 ed ff ff       	call   800891 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b87:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8c:	e8 db fd ff ff       	call   80196c <fsipc>
  801b91:	89 c3                	mov    %eax,%ebx
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 19                	js     801bb3 <open+0x79>
	return fd2num(fd);
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba0:	e8 f4 f7 ff ff       	call   801399 <fd2num>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	83 c4 10             	add    $0x10,%esp
}
  801baa:	89 d8                	mov    %ebx,%eax
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    
		fd_close(fd, 0);
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	6a 00                	push   $0x0
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	e8 10 f9 ff ff       	call   8014d0 <fd_close>
		return r;
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	eb e5                	jmp    801baa <open+0x70>
		return -E_BAD_PATH;
  801bc5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801bca:	eb de                	jmp    801baa <open+0x70>

00801bcc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bcc:	f3 0f 1e fb          	endbr32 
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdb:	b8 08 00 00 00       	mov    $0x8,%eax
  801be0:	e8 87 fd ff ff       	call   80196c <fsipc>
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be7:	f3 0f 1e fb          	endbr32 
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bf3:	83 ec 0c             	sub    $0xc,%esp
  801bf6:	ff 75 08             	pushl  0x8(%ebp)
  801bf9:	e8 af f7 ff ff       	call   8013ad <fd2data>
  801bfe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c00:	83 c4 08             	add    $0x8,%esp
  801c03:	68 ef 2b 80 00       	push   $0x802bef
  801c08:	53                   	push   %ebx
  801c09:	e8 83 ec ff ff       	call   800891 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c0e:	8b 46 04             	mov    0x4(%esi),%eax
  801c11:	2b 06                	sub    (%esi),%eax
  801c13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c19:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c20:	00 00 00 
	stat->st_dev = &devpipe;
  801c23:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c2a:	30 80 00 
	return 0;
}
  801c2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c39:	f3 0f 1e fb          	endbr32 
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	53                   	push   %ebx
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c47:	53                   	push   %ebx
  801c48:	6a 00                	push   $0x0
  801c4a:	e8 1c f1 ff ff       	call   800d6b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c4f:	89 1c 24             	mov    %ebx,(%esp)
  801c52:	e8 56 f7 ff ff       	call   8013ad <fd2data>
  801c57:	83 c4 08             	add    $0x8,%esp
  801c5a:	50                   	push   %eax
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 09 f1 ff ff       	call   800d6b <sys_page_unmap>
}
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <_pipeisclosed>:
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	57                   	push   %edi
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 1c             	sub    $0x1c,%esp
  801c70:	89 c7                	mov    %eax,%edi
  801c72:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c74:	a1 04 40 80 00       	mov    0x804004,%eax
  801c79:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c7c:	83 ec 0c             	sub    $0xc,%esp
  801c7f:	57                   	push   %edi
  801c80:	e8 f0 05 00 00       	call   802275 <pageref>
  801c85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c88:	89 34 24             	mov    %esi,(%esp)
  801c8b:	e8 e5 05 00 00       	call   802275 <pageref>
		nn = thisenv->env_runs;
  801c90:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c96:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	39 cb                	cmp    %ecx,%ebx
  801c9e:	74 1b                	je     801cbb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ca0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ca3:	75 cf                	jne    801c74 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca5:	8b 42 58             	mov    0x58(%edx),%eax
  801ca8:	6a 01                	push   $0x1
  801caa:	50                   	push   %eax
  801cab:	53                   	push   %ebx
  801cac:	68 f6 2b 80 00       	push   $0x802bf6
  801cb1:	e8 71 e6 ff ff       	call   800327 <cprintf>
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	eb b9                	jmp    801c74 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cbb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cbe:	0f 94 c0             	sete   %al
  801cc1:	0f b6 c0             	movzbl %al,%eax
}
  801cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <devpipe_write>:
{
  801ccc:	f3 0f 1e fb          	endbr32 
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	57                   	push   %edi
  801cd4:	56                   	push   %esi
  801cd5:	53                   	push   %ebx
  801cd6:	83 ec 28             	sub    $0x28,%esp
  801cd9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cdc:	56                   	push   %esi
  801cdd:	e8 cb f6 ff ff       	call   8013ad <fd2data>
  801ce2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	bf 00 00 00 00       	mov    $0x0,%edi
  801cec:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cef:	74 4f                	je     801d40 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cf1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cf4:	8b 0b                	mov    (%ebx),%ecx
  801cf6:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf9:	39 d0                	cmp    %edx,%eax
  801cfb:	72 14                	jb     801d11 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801cfd:	89 da                	mov    %ebx,%edx
  801cff:	89 f0                	mov    %esi,%eax
  801d01:	e8 61 ff ff ff       	call   801c67 <_pipeisclosed>
  801d06:	85 c0                	test   %eax,%eax
  801d08:	75 3b                	jne    801d45 <devpipe_write+0x79>
			sys_yield();
  801d0a:	e8 df ef ff ff       	call   800cee <sys_yield>
  801d0f:	eb e0                	jmp    801cf1 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d14:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d18:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d1b:	89 c2                	mov    %eax,%edx
  801d1d:	c1 fa 1f             	sar    $0x1f,%edx
  801d20:	89 d1                	mov    %edx,%ecx
  801d22:	c1 e9 1b             	shr    $0x1b,%ecx
  801d25:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d28:	83 e2 1f             	and    $0x1f,%edx
  801d2b:	29 ca                	sub    %ecx,%edx
  801d2d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d31:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d35:	83 c0 01             	add    $0x1,%eax
  801d38:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d3b:	83 c7 01             	add    $0x1,%edi
  801d3e:	eb ac                	jmp    801cec <devpipe_write+0x20>
	return i;
  801d40:	8b 45 10             	mov    0x10(%ebp),%eax
  801d43:	eb 05                	jmp    801d4a <devpipe_write+0x7e>
				return 0;
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <devpipe_read>:
{
  801d52:	f3 0f 1e fb          	endbr32 
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	57                   	push   %edi
  801d5a:	56                   	push   %esi
  801d5b:	53                   	push   %ebx
  801d5c:	83 ec 18             	sub    $0x18,%esp
  801d5f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d62:	57                   	push   %edi
  801d63:	e8 45 f6 ff ff       	call   8013ad <fd2data>
  801d68:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	be 00 00 00 00       	mov    $0x0,%esi
  801d72:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d75:	75 14                	jne    801d8b <devpipe_read+0x39>
	return i;
  801d77:	8b 45 10             	mov    0x10(%ebp),%eax
  801d7a:	eb 02                	jmp    801d7e <devpipe_read+0x2c>
				return i;
  801d7c:	89 f0                	mov    %esi,%eax
}
  801d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    
			sys_yield();
  801d86:	e8 63 ef ff ff       	call   800cee <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d8b:	8b 03                	mov    (%ebx),%eax
  801d8d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d90:	75 18                	jne    801daa <devpipe_read+0x58>
			if (i > 0)
  801d92:	85 f6                	test   %esi,%esi
  801d94:	75 e6                	jne    801d7c <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d96:	89 da                	mov    %ebx,%edx
  801d98:	89 f8                	mov    %edi,%eax
  801d9a:	e8 c8 fe ff ff       	call   801c67 <_pipeisclosed>
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	74 e3                	je     801d86 <devpipe_read+0x34>
				return 0;
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
  801da8:	eb d4                	jmp    801d7e <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801daa:	99                   	cltd   
  801dab:	c1 ea 1b             	shr    $0x1b,%edx
  801dae:	01 d0                	add    %edx,%eax
  801db0:	83 e0 1f             	and    $0x1f,%eax
  801db3:	29 d0                	sub    %edx,%eax
  801db5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dbd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dc0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dc3:	83 c6 01             	add    $0x1,%esi
  801dc6:	eb aa                	jmp    801d72 <devpipe_read+0x20>

00801dc8 <pipe>:
{
  801dc8:	f3 0f 1e fb          	endbr32 
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd7:	50                   	push   %eax
  801dd8:	e8 ef f5 ff ff       	call   8013cc <fd_alloc>
  801ddd:	89 c3                	mov    %eax,%ebx
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	0f 88 23 01 00 00    	js     801f0d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dea:	83 ec 04             	sub    $0x4,%esp
  801ded:	68 07 04 00 00       	push   $0x407
  801df2:	ff 75 f4             	pushl  -0xc(%ebp)
  801df5:	6a 00                	push   $0x0
  801df7:	e8 1d ef ff ff       	call   800d19 <sys_page_alloc>
  801dfc:	89 c3                	mov    %eax,%ebx
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	85 c0                	test   %eax,%eax
  801e03:	0f 88 04 01 00 00    	js     801f0d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e0f:	50                   	push   %eax
  801e10:	e8 b7 f5 ff ff       	call   8013cc <fd_alloc>
  801e15:	89 c3                	mov    %eax,%ebx
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	0f 88 db 00 00 00    	js     801efd <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	68 07 04 00 00       	push   $0x407
  801e2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 e5 ee ff ff       	call   800d19 <sys_page_alloc>
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	0f 88 bc 00 00 00    	js     801efd <pipe+0x135>
	va = fd2data(fd0);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 f4             	pushl  -0xc(%ebp)
  801e47:	e8 61 f5 ff ff       	call   8013ad <fd2data>
  801e4c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4e:	83 c4 0c             	add    $0xc,%esp
  801e51:	68 07 04 00 00       	push   $0x407
  801e56:	50                   	push   %eax
  801e57:	6a 00                	push   $0x0
  801e59:	e8 bb ee ff ff       	call   800d19 <sys_page_alloc>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	0f 88 82 00 00 00    	js     801eed <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6b:	83 ec 0c             	sub    $0xc,%esp
  801e6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e71:	e8 37 f5 ff ff       	call   8013ad <fd2data>
  801e76:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e7d:	50                   	push   %eax
  801e7e:	6a 00                	push   $0x0
  801e80:	56                   	push   %esi
  801e81:	6a 00                	push   $0x0
  801e83:	e8 b9 ee ff ff       	call   800d41 <sys_page_map>
  801e88:	89 c3                	mov    %eax,%ebx
  801e8a:	83 c4 20             	add    $0x20,%esp
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 4e                	js     801edf <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e91:	a1 20 30 80 00       	mov    0x803020,%eax
  801e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e99:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e9e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ea5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ea8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ead:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eba:	e8 da f4 ff ff       	call   801399 <fd2num>
  801ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ec4:	83 c4 04             	add    $0x4,%esp
  801ec7:	ff 75 f0             	pushl  -0x10(%ebp)
  801eca:	e8 ca f4 ff ff       	call   801399 <fd2num>
  801ecf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801edd:	eb 2e                	jmp    801f0d <pipe+0x145>
	sys_page_unmap(0, va);
  801edf:	83 ec 08             	sub    $0x8,%esp
  801ee2:	56                   	push   %esi
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 81 ee ff ff       	call   800d6b <sys_page_unmap>
  801eea:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 71 ee ff ff       	call   800d6b <sys_page_unmap>
  801efa:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	ff 75 f4             	pushl  -0xc(%ebp)
  801f03:	6a 00                	push   $0x0
  801f05:	e8 61 ee ff ff       	call   800d6b <sys_page_unmap>
  801f0a:	83 c4 10             	add    $0x10,%esp
}
  801f0d:	89 d8                	mov    %ebx,%eax
  801f0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    

00801f16 <pipeisclosed>:
{
  801f16:	f3 0f 1e fb          	endbr32 
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f23:	50                   	push   %eax
  801f24:	ff 75 08             	pushl  0x8(%ebp)
  801f27:	e8 f6 f4 ff ff       	call   801422 <fd_lookup>
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 18                	js     801f4b <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f33:	83 ec 0c             	sub    $0xc,%esp
  801f36:	ff 75 f4             	pushl  -0xc(%ebp)
  801f39:	e8 6f f4 ff ff       	call   8013ad <fd2data>
  801f3e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f43:	e8 1f fd ff ff       	call   801c67 <_pipeisclosed>
  801f48:	83 c4 10             	add    $0x10,%esp
}
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f4d:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
  801f56:	c3                   	ret    

00801f57 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f57:	f3 0f 1e fb          	endbr32 
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f61:	68 0e 2c 80 00       	push   $0x802c0e
  801f66:	ff 75 0c             	pushl  0xc(%ebp)
  801f69:	e8 23 e9 ff ff       	call   800891 <strcpy>
	return 0;
}
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <devcons_write>:
{
  801f75:	f3 0f 1e fb          	endbr32 
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	57                   	push   %edi
  801f7d:	56                   	push   %esi
  801f7e:	53                   	push   %ebx
  801f7f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f85:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f8a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f90:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f93:	73 31                	jae    801fc6 <devcons_write+0x51>
		m = n - tot;
  801f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f98:	29 f3                	sub    %esi,%ebx
  801f9a:	83 fb 7f             	cmp    $0x7f,%ebx
  801f9d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fa2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fa5:	83 ec 04             	sub    $0x4,%esp
  801fa8:	53                   	push   %ebx
  801fa9:	89 f0                	mov    %esi,%eax
  801fab:	03 45 0c             	add    0xc(%ebp),%eax
  801fae:	50                   	push   %eax
  801faf:	57                   	push   %edi
  801fb0:	e8 94 ea ff ff       	call   800a49 <memmove>
		sys_cputs(buf, m);
  801fb5:	83 c4 08             	add    $0x8,%esp
  801fb8:	53                   	push   %ebx
  801fb9:	57                   	push   %edi
  801fba:	e8 8f ec ff ff       	call   800c4e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fbf:	01 de                	add    %ebx,%esi
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	eb ca                	jmp    801f90 <devcons_write+0x1b>
}
  801fc6:	89 f0                	mov    %esi,%eax
  801fc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcb:	5b                   	pop    %ebx
  801fcc:	5e                   	pop    %esi
  801fcd:	5f                   	pop    %edi
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

00801fd0 <devcons_read>:
{
  801fd0:	f3 0f 1e fb          	endbr32 
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	83 ec 08             	sub    $0x8,%esp
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe3:	74 21                	je     802006 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fe5:	e8 8e ec ff ff       	call   800c78 <sys_cgetc>
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 07                	jne    801ff5 <devcons_read+0x25>
		sys_yield();
  801fee:	e8 fb ec ff ff       	call   800cee <sys_yield>
  801ff3:	eb f0                	jmp    801fe5 <devcons_read+0x15>
	if (c < 0)
  801ff5:	78 0f                	js     802006 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801ff7:	83 f8 04             	cmp    $0x4,%eax
  801ffa:	74 0c                	je     802008 <devcons_read+0x38>
	*(char*)vbuf = c;
  801ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fff:	88 02                	mov    %al,(%edx)
	return 1;
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802006:	c9                   	leave  
  802007:	c3                   	ret    
		return 0;
  802008:	b8 00 00 00 00       	mov    $0x0,%eax
  80200d:	eb f7                	jmp    802006 <devcons_read+0x36>

0080200f <cputchar>:
{
  80200f:	f3 0f 1e fb          	endbr32 
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80201f:	6a 01                	push   $0x1
  802021:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802024:	50                   	push   %eax
  802025:	e8 24 ec ff ff       	call   800c4e <sys_cputs>
}
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <getchar>:
{
  80202f:	f3 0f 1e fb          	endbr32 
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802039:	6a 01                	push   $0x1
  80203b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203e:	50                   	push   %eax
  80203f:	6a 00                	push   $0x0
  802041:	e8 5f f6 ff ff       	call   8016a5 <read>
	if (r < 0)
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 06                	js     802053 <getchar+0x24>
	if (r < 1)
  80204d:	74 06                	je     802055 <getchar+0x26>
	return c;
  80204f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    
		return -E_EOF;
  802055:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80205a:	eb f7                	jmp    802053 <getchar+0x24>

0080205c <iscons>:
{
  80205c:	f3 0f 1e fb          	endbr32 
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	ff 75 08             	pushl  0x8(%ebp)
  80206d:	e8 b0 f3 ff ff       	call   801422 <fd_lookup>
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	78 11                	js     80208a <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802082:	39 10                	cmp    %edx,(%eax)
  802084:	0f 94 c0             	sete   %al
  802087:	0f b6 c0             	movzbl %al,%eax
}
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <opencons>:
{
  80208c:	f3 0f 1e fb          	endbr32 
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802096:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802099:	50                   	push   %eax
  80209a:	e8 2d f3 ff ff       	call   8013cc <fd_alloc>
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	78 3a                	js     8020e0 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a6:	83 ec 04             	sub    $0x4,%esp
  8020a9:	68 07 04 00 00       	push   $0x407
  8020ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b1:	6a 00                	push   $0x0
  8020b3:	e8 61 ec ff ff       	call   800d19 <sys_page_alloc>
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	78 21                	js     8020e0 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d4:	83 ec 0c             	sub    $0xc,%esp
  8020d7:	50                   	push   %eax
  8020d8:	e8 bc f2 ff ff       	call   801399 <fd2num>
  8020dd:	83 c4 10             	add    $0x10,%esp
}
  8020e0:	c9                   	leave  
  8020e1:	c3                   	ret    

008020e2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020e2:	f3 0f 1e fb          	endbr32 
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020ec:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020f3:	74 1c                	je     802111 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f8:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  8020fd:	83 ec 08             	sub    $0x8,%esp
  802100:	68 3d 21 80 00       	push   $0x80213d
  802105:	6a 00                	push   $0x0
  802107:	e8 d4 ec ff ff       	call   800de0 <sys_env_set_pgfault_upcall>
}
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	c9                   	leave  
  802110:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802111:	83 ec 04             	sub    $0x4,%esp
  802114:	6a 02                	push   $0x2
  802116:	68 00 f0 bf ee       	push   $0xeebff000
  80211b:	6a 00                	push   $0x0
  80211d:	e8 f7 eb ff ff       	call   800d19 <sys_page_alloc>
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	85 c0                	test   %eax,%eax
  802127:	79 cc                	jns    8020f5 <set_pgfault_handler+0x13>
  802129:	83 ec 04             	sub    $0x4,%esp
  80212c:	68 1a 2c 80 00       	push   $0x802c1a
  802131:	6a 20                	push   $0x20
  802133:	68 35 2c 80 00       	push   $0x802c35
  802138:	e8 03 e1 ff ff       	call   800240 <_panic>

0080213d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80213d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80213e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802143:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802145:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  802148:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  80214c:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  802150:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  802153:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  802155:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802159:	83 c4 08             	add    $0x8,%esp
	popal
  80215c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80215d:	83 c4 04             	add    $0x4,%esp
	popfl
  802160:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802161:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802164:	c3                   	ret    

00802165 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802165:	f3 0f 1e fb          	endbr32 
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	56                   	push   %esi
  80216d:	53                   	push   %ebx
  80216e:	8b 75 08             	mov    0x8(%ebp),%esi
  802171:	8b 45 0c             	mov    0xc(%ebp),%eax
  802174:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  802177:	85 c0                	test   %eax,%eax
  802179:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80217e:	0f 44 c2             	cmove  %edx,%eax
  802181:	83 ec 0c             	sub    $0xc,%esp
  802184:	50                   	push   %eax
  802185:	e8 a6 ec ff ff       	call   800e30 <sys_ipc_recv>

	if (from_env_store != NULL)
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 f6                	test   %esi,%esi
  80218f:	74 15                	je     8021a6 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  802191:	ba 00 00 00 00       	mov    $0x0,%edx
  802196:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802199:	74 09                	je     8021a4 <ipc_recv+0x3f>
  80219b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8021a1:	8b 52 74             	mov    0x74(%edx),%edx
  8021a4:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8021a6:	85 db                	test   %ebx,%ebx
  8021a8:	74 15                	je     8021bf <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8021aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8021af:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8021b2:	74 09                	je     8021bd <ipc_recv+0x58>
  8021b4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8021ba:	8b 52 78             	mov    0x78(%edx),%edx
  8021bd:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8021bf:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8021c2:	74 08                	je     8021cc <ipc_recv+0x67>
  8021c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8021c9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    

008021d3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021d3:	f3 0f 1e fb          	endbr32 
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	57                   	push   %edi
  8021db:	56                   	push   %esi
  8021dc:	53                   	push   %ebx
  8021dd:	83 ec 0c             	sub    $0xc,%esp
  8021e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021e9:	eb 1f                	jmp    80220a <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8021eb:	6a 00                	push   $0x0
  8021ed:	68 00 00 c0 ee       	push   $0xeec00000
  8021f2:	56                   	push   %esi
  8021f3:	57                   	push   %edi
  8021f4:	e8 0e ec ff ff       	call   800e07 <sys_ipc_try_send>
  8021f9:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	74 30                	je     802230 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  802200:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802203:	75 19                	jne    80221e <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  802205:	e8 e4 ea ff ff       	call   800cee <sys_yield>
		if (pg != NULL) {
  80220a:	85 db                	test   %ebx,%ebx
  80220c:	74 dd                	je     8021eb <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  80220e:	ff 75 14             	pushl  0x14(%ebp)
  802211:	53                   	push   %ebx
  802212:	56                   	push   %esi
  802213:	57                   	push   %edi
  802214:	e8 ee eb ff ff       	call   800e07 <sys_ipc_try_send>
  802219:	83 c4 10             	add    $0x10,%esp
  80221c:	eb de                	jmp    8021fc <ipc_send+0x29>
			panic("ipc_send: %d", res);
  80221e:	50                   	push   %eax
  80221f:	68 43 2c 80 00       	push   $0x802c43
  802224:	6a 3e                	push   $0x3e
  802226:	68 50 2c 80 00       	push   $0x802c50
  80222b:	e8 10 e0 ff ff       	call   800240 <_panic>
	}
}
  802230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802238:	f3 0f 1e fb          	endbr32 
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802247:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80224a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802250:	8b 52 50             	mov    0x50(%edx),%edx
  802253:	39 ca                	cmp    %ecx,%edx
  802255:	74 11                	je     802268 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802257:	83 c0 01             	add    $0x1,%eax
  80225a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80225f:	75 e6                	jne    802247 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802261:	b8 00 00 00 00       	mov    $0x0,%eax
  802266:	eb 0b                	jmp    802273 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802268:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80226b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802270:	8b 40 48             	mov    0x48(%eax),%eax
}
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    

00802275 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802275:	f3 0f 1e fb          	endbr32 
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80227f:	89 c2                	mov    %eax,%edx
  802281:	c1 ea 16             	shr    $0x16,%edx
  802284:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80228b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802290:	f6 c1 01             	test   $0x1,%cl
  802293:	74 1c                	je     8022b1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802295:	c1 e8 0c             	shr    $0xc,%eax
  802298:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80229f:	a8 01                	test   $0x1,%al
  8022a1:	74 0e                	je     8022b1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022a3:	c1 e8 0c             	shr    $0xc,%eax
  8022a6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8022ad:	ef 
  8022ae:	0f b7 d2             	movzwl %dx,%edx
}
  8022b1:	89 d0                	mov    %edx,%eax
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
  8022b5:	66 90                	xchg   %ax,%ax
  8022b7:	66 90                	xchg   %ax,%ax
  8022b9:	66 90                	xchg   %ax,%ax
  8022bb:	66 90                	xchg   %ax,%ax
  8022bd:	66 90                	xchg   %ax,%ax
  8022bf:	90                   	nop

008022c0 <__udivdi3>:
  8022c0:	f3 0f 1e fb          	endbr32 
  8022c4:	55                   	push   %ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	83 ec 1c             	sub    $0x1c,%esp
  8022cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022db:	85 d2                	test   %edx,%edx
  8022dd:	75 19                	jne    8022f8 <__udivdi3+0x38>
  8022df:	39 f3                	cmp    %esi,%ebx
  8022e1:	76 4d                	jbe    802330 <__udivdi3+0x70>
  8022e3:	31 ff                	xor    %edi,%edi
  8022e5:	89 e8                	mov    %ebp,%eax
  8022e7:	89 f2                	mov    %esi,%edx
  8022e9:	f7 f3                	div    %ebx
  8022eb:	89 fa                	mov    %edi,%edx
  8022ed:	83 c4 1c             	add    $0x1c,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	76 14                	jbe    802310 <__udivdi3+0x50>
  8022fc:	31 ff                	xor    %edi,%edi
  8022fe:	31 c0                	xor    %eax,%eax
  802300:	89 fa                	mov    %edi,%edx
  802302:	83 c4 1c             	add    $0x1c,%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5f                   	pop    %edi
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    
  80230a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802310:	0f bd fa             	bsr    %edx,%edi
  802313:	83 f7 1f             	xor    $0x1f,%edi
  802316:	75 48                	jne    802360 <__udivdi3+0xa0>
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	72 06                	jb     802322 <__udivdi3+0x62>
  80231c:	31 c0                	xor    %eax,%eax
  80231e:	39 eb                	cmp    %ebp,%ebx
  802320:	77 de                	ja     802300 <__udivdi3+0x40>
  802322:	b8 01 00 00 00       	mov    $0x1,%eax
  802327:	eb d7                	jmp    802300 <__udivdi3+0x40>
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 d9                	mov    %ebx,%ecx
  802332:	85 db                	test   %ebx,%ebx
  802334:	75 0b                	jne    802341 <__udivdi3+0x81>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f3                	div    %ebx
  80233f:	89 c1                	mov    %eax,%ecx
  802341:	31 d2                	xor    %edx,%edx
  802343:	89 f0                	mov    %esi,%eax
  802345:	f7 f1                	div    %ecx
  802347:	89 c6                	mov    %eax,%esi
  802349:	89 e8                	mov    %ebp,%eax
  80234b:	89 f7                	mov    %esi,%edi
  80234d:	f7 f1                	div    %ecx
  80234f:	89 fa                	mov    %edi,%edx
  802351:	83 c4 1c             	add    $0x1c,%esp
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	89 f9                	mov    %edi,%ecx
  802362:	b8 20 00 00 00       	mov    $0x20,%eax
  802367:	29 f8                	sub    %edi,%eax
  802369:	d3 e2                	shl    %cl,%edx
  80236b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80236f:	89 c1                	mov    %eax,%ecx
  802371:	89 da                	mov    %ebx,%edx
  802373:	d3 ea                	shr    %cl,%edx
  802375:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802379:	09 d1                	or     %edx,%ecx
  80237b:	89 f2                	mov    %esi,%edx
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e3                	shl    %cl,%ebx
  802385:	89 c1                	mov    %eax,%ecx
  802387:	d3 ea                	shr    %cl,%edx
  802389:	89 f9                	mov    %edi,%ecx
  80238b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80238f:	89 eb                	mov    %ebp,%ebx
  802391:	d3 e6                	shl    %cl,%esi
  802393:	89 c1                	mov    %eax,%ecx
  802395:	d3 eb                	shr    %cl,%ebx
  802397:	09 de                	or     %ebx,%esi
  802399:	89 f0                	mov    %esi,%eax
  80239b:	f7 74 24 08          	divl   0x8(%esp)
  80239f:	89 d6                	mov    %edx,%esi
  8023a1:	89 c3                	mov    %eax,%ebx
  8023a3:	f7 64 24 0c          	mull   0xc(%esp)
  8023a7:	39 d6                	cmp    %edx,%esi
  8023a9:	72 15                	jb     8023c0 <__udivdi3+0x100>
  8023ab:	89 f9                	mov    %edi,%ecx
  8023ad:	d3 e5                	shl    %cl,%ebp
  8023af:	39 c5                	cmp    %eax,%ebp
  8023b1:	73 04                	jae    8023b7 <__udivdi3+0xf7>
  8023b3:	39 d6                	cmp    %edx,%esi
  8023b5:	74 09                	je     8023c0 <__udivdi3+0x100>
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	31 ff                	xor    %edi,%edi
  8023bb:	e9 40 ff ff ff       	jmp    802300 <__udivdi3+0x40>
  8023c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023c3:	31 ff                	xor    %edi,%edi
  8023c5:	e9 36 ff ff ff       	jmp    802300 <__udivdi3+0x40>
  8023ca:	66 90                	xchg   %ax,%ax
  8023cc:	66 90                	xchg   %ax,%ax
  8023ce:	66 90                	xchg   %ax,%ax

008023d0 <__umoddi3>:
  8023d0:	f3 0f 1e fb          	endbr32 
  8023d4:	55                   	push   %ebp
  8023d5:	57                   	push   %edi
  8023d6:	56                   	push   %esi
  8023d7:	53                   	push   %ebx
  8023d8:	83 ec 1c             	sub    $0x1c,%esp
  8023db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	75 19                	jne    802408 <__umoddi3+0x38>
  8023ef:	39 df                	cmp    %ebx,%edi
  8023f1:	76 5d                	jbe    802450 <__umoddi3+0x80>
  8023f3:	89 f0                	mov    %esi,%eax
  8023f5:	89 da                	mov    %ebx,%edx
  8023f7:	f7 f7                	div    %edi
  8023f9:	89 d0                	mov    %edx,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	83 c4 1c             	add    $0x1c,%esp
  802400:	5b                   	pop    %ebx
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	89 f2                	mov    %esi,%edx
  80240a:	39 d8                	cmp    %ebx,%eax
  80240c:	76 12                	jbe    802420 <__umoddi3+0x50>
  80240e:	89 f0                	mov    %esi,%eax
  802410:	89 da                	mov    %ebx,%edx
  802412:	83 c4 1c             	add    $0x1c,%esp
  802415:	5b                   	pop    %ebx
  802416:	5e                   	pop    %esi
  802417:	5f                   	pop    %edi
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    
  80241a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802420:	0f bd e8             	bsr    %eax,%ebp
  802423:	83 f5 1f             	xor    $0x1f,%ebp
  802426:	75 50                	jne    802478 <__umoddi3+0xa8>
  802428:	39 d8                	cmp    %ebx,%eax
  80242a:	0f 82 e0 00 00 00    	jb     802510 <__umoddi3+0x140>
  802430:	89 d9                	mov    %ebx,%ecx
  802432:	39 f7                	cmp    %esi,%edi
  802434:	0f 86 d6 00 00 00    	jbe    802510 <__umoddi3+0x140>
  80243a:	89 d0                	mov    %edx,%eax
  80243c:	89 ca                	mov    %ecx,%edx
  80243e:	83 c4 1c             	add    $0x1c,%esp
  802441:	5b                   	pop    %ebx
  802442:	5e                   	pop    %esi
  802443:	5f                   	pop    %edi
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    
  802446:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	89 fd                	mov    %edi,%ebp
  802452:	85 ff                	test   %edi,%edi
  802454:	75 0b                	jne    802461 <__umoddi3+0x91>
  802456:	b8 01 00 00 00       	mov    $0x1,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	f7 f7                	div    %edi
  80245f:	89 c5                	mov    %eax,%ebp
  802461:	89 d8                	mov    %ebx,%eax
  802463:	31 d2                	xor    %edx,%edx
  802465:	f7 f5                	div    %ebp
  802467:	89 f0                	mov    %esi,%eax
  802469:	f7 f5                	div    %ebp
  80246b:	89 d0                	mov    %edx,%eax
  80246d:	31 d2                	xor    %edx,%edx
  80246f:	eb 8c                	jmp    8023fd <__umoddi3+0x2d>
  802471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	ba 20 00 00 00       	mov    $0x20,%edx
  80247f:	29 ea                	sub    %ebp,%edx
  802481:	d3 e0                	shl    %cl,%eax
  802483:	89 44 24 08          	mov    %eax,0x8(%esp)
  802487:	89 d1                	mov    %edx,%ecx
  802489:	89 f8                	mov    %edi,%eax
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802491:	89 54 24 04          	mov    %edx,0x4(%esp)
  802495:	8b 54 24 04          	mov    0x4(%esp),%edx
  802499:	09 c1                	or     %eax,%ecx
  80249b:	89 d8                	mov    %ebx,%eax
  80249d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024a1:	89 e9                	mov    %ebp,%ecx
  8024a3:	d3 e7                	shl    %cl,%edi
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	d3 e8                	shr    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024af:	d3 e3                	shl    %cl,%ebx
  8024b1:	89 c7                	mov    %eax,%edi
  8024b3:	89 d1                	mov    %edx,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e8                	shr    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	89 fa                	mov    %edi,%edx
  8024bd:	d3 e6                	shl    %cl,%esi
  8024bf:	09 d8                	or     %ebx,%eax
  8024c1:	f7 74 24 08          	divl   0x8(%esp)
  8024c5:	89 d1                	mov    %edx,%ecx
  8024c7:	89 f3                	mov    %esi,%ebx
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)
  8024cd:	89 c6                	mov    %eax,%esi
  8024cf:	89 d7                	mov    %edx,%edi
  8024d1:	39 d1                	cmp    %edx,%ecx
  8024d3:	72 06                	jb     8024db <__umoddi3+0x10b>
  8024d5:	75 10                	jne    8024e7 <__umoddi3+0x117>
  8024d7:	39 c3                	cmp    %eax,%ebx
  8024d9:	73 0c                	jae    8024e7 <__umoddi3+0x117>
  8024db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024e3:	89 d7                	mov    %edx,%edi
  8024e5:	89 c6                	mov    %eax,%esi
  8024e7:	89 ca                	mov    %ecx,%edx
  8024e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ee:	29 f3                	sub    %esi,%ebx
  8024f0:	19 fa                	sbb    %edi,%edx
  8024f2:	89 d0                	mov    %edx,%eax
  8024f4:	d3 e0                	shl    %cl,%eax
  8024f6:	89 e9                	mov    %ebp,%ecx
  8024f8:	d3 eb                	shr    %cl,%ebx
  8024fa:	d3 ea                	shr    %cl,%edx
  8024fc:	09 d8                	or     %ebx,%eax
  8024fe:	83 c4 1c             	add    $0x1c,%esp
  802501:	5b                   	pop    %ebx
  802502:	5e                   	pop    %esi
  802503:	5f                   	pop    %edi
  802504:	5d                   	pop    %ebp
  802505:	c3                   	ret    
  802506:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80250d:	8d 76 00             	lea    0x0(%esi),%esi
  802510:	29 fe                	sub    %edi,%esi
  802512:	19 c3                	sbb    %eax,%ebx
  802514:	89 f2                	mov    %esi,%edx
  802516:	89 d9                	mov    %ebx,%ecx
  802518:	e9 1d ff ff ff       	jmp    80243a <__umoddi3+0x6a>
