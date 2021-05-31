
obj/user/testpteshare.debug:     formato del fichero elf32-i386


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
  80002c:	e8 71 01 00 00       	call   8001a2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <breakpoint>:
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800035:	f3 0f 1e fb          	endbr32 
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  80003f:	ff 35 00 40 80 00    	pushl  0x804000
  800045:	68 00 00 00 a0       	push   $0xa0000000
  80004a:	e8 10 08 00 00       	call   80085f <strcpy>
	exit();
  80004f:	e8 9c 01 00 00       	call   8001f0 <exit>
}
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <umain>:
{
  800059:	f3 0f 1e fb          	endbr32 
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	53                   	push   %ebx
  800061:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  800064:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800068:	0f 85 d4 00 00 00    	jne    800142 <umain+0xe9>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80006e:	83 ec 04             	sub    $0x4,%esp
  800071:	68 07 04 00 00       	push   $0x407
  800076:	68 00 00 00 a0       	push   $0xa0000000
  80007b:	6a 00                	push   $0x0
  80007d:	e8 65 0c 00 00       	call   800ce7 <sys_page_alloc>
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	85 c0                	test   %eax,%eax
  800087:	0f 88 bf 00 00 00    	js     80014c <umain+0xf3>
	if ((r = fork()) < 0)
  80008d:	e8 34 11 00 00       	call   8011c6 <fork>
  800092:	89 c3                	mov    %eax,%ebx
  800094:	85 c0                	test   %eax,%eax
  800096:	0f 88 c2 00 00 00    	js     80015e <umain+0x105>
	if (r == 0) {
  80009c:	0f 84 ce 00 00 00    	je     800170 <umain+0x117>
	wait(r);
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	e8 78 24 00 00       	call   802523 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000ab:	83 c4 08             	add    $0x8,%esp
  8000ae:	ff 35 04 40 80 00    	pushl  0x804004
  8000b4:	68 00 00 00 a0       	push   $0xa0000000
  8000b9:	e8 60 08 00 00       	call   80091e <strcmp>
  8000be:	83 c4 08             	add    $0x8,%esp
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	b8 40 2b 80 00       	mov    $0x802b40,%eax
  8000c8:	ba 46 2b 80 00       	mov    $0x802b46,%edx
  8000cd:	0f 45 c2             	cmovne %edx,%eax
  8000d0:	50                   	push   %eax
  8000d1:	68 7c 2b 80 00       	push   $0x802b7c
  8000d6:	e8 1a 02 00 00       	call   8002f5 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000db:	6a 00                	push   $0x0
  8000dd:	68 97 2b 80 00       	push   $0x802b97
  8000e2:	68 9c 2b 80 00       	push   $0x802b9c
  8000e7:	68 9b 2b 80 00       	push   $0x802b9b
  8000ec:	e8 1a 20 00 00       	call   80210b <spawnl>
  8000f1:	83 c4 20             	add    $0x20,%esp
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	0f 88 94 00 00 00    	js     800190 <umain+0x137>
	wait(r);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	e8 1e 24 00 00       	call   802523 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800105:	83 c4 08             	add    $0x8,%esp
  800108:	ff 35 00 40 80 00    	pushl  0x804000
  80010e:	68 00 00 00 a0       	push   $0xa0000000
  800113:	e8 06 08 00 00       	call   80091e <strcmp>
  800118:	83 c4 08             	add    $0x8,%esp
  80011b:	85 c0                	test   %eax,%eax
  80011d:	b8 40 2b 80 00       	mov    $0x802b40,%eax
  800122:	ba 46 2b 80 00       	mov    $0x802b46,%edx
  800127:	0f 45 c2             	cmovne %edx,%eax
  80012a:	50                   	push   %eax
  80012b:	68 b3 2b 80 00       	push   $0x802bb3
  800130:	e8 c0 01 00 00       	call   8002f5 <cprintf>
	breakpoint();
  800135:	e8 f9 fe ff ff       	call   800033 <breakpoint>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800140:	c9                   	leave  
  800141:	c3                   	ret    
		childofspawn();
  800142:	e8 ee fe ff ff       	call   800035 <childofspawn>
  800147:	e9 22 ff ff ff       	jmp    80006e <umain+0x15>
		panic("sys_page_alloc: %e", r);
  80014c:	50                   	push   %eax
  80014d:	68 4c 2b 80 00       	push   $0x802b4c
  800152:	6a 13                	push   $0x13
  800154:	68 5f 2b 80 00       	push   $0x802b5f
  800159:	e8 b0 00 00 00       	call   80020e <_panic>
		panic("fork: %e", r);
  80015e:	50                   	push   %eax
  80015f:	68 73 2b 80 00       	push   $0x802b73
  800164:	6a 17                	push   $0x17
  800166:	68 5f 2b 80 00       	push   $0x802b5f
  80016b:	e8 9e 00 00 00       	call   80020e <_panic>
		strcpy(VA, msg);
  800170:	83 ec 08             	sub    $0x8,%esp
  800173:	ff 35 04 40 80 00    	pushl  0x804004
  800179:	68 00 00 00 a0       	push   $0xa0000000
  80017e:	e8 dc 06 00 00       	call   80085f <strcpy>
		exit();
  800183:	e8 68 00 00 00       	call   8001f0 <exit>
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	e9 12 ff ff ff       	jmp    8000a2 <umain+0x49>
		panic("spawn: %e", r);
  800190:	50                   	push   %eax
  800191:	68 a9 2b 80 00       	push   $0x802ba9
  800196:	6a 21                	push   $0x21
  800198:	68 5f 2b 80 00       	push   $0x802b5f
  80019d:	e8 6c 00 00 00       	call   80020e <_panic>

008001a2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a2:	f3 0f 1e fb          	endbr32 
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001b1:	e8 de 0a 00 00       	call   800c94 <sys_getenvid>
	if (id >= 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	78 12                	js     8001cc <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c7:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7e 07                	jle    8001d7 <libmain+0x35>
		binaryname = argv[0];
  8001d0:	8b 06                	mov    (%esi),%eax
  8001d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	e8 78 fe ff ff       	call   800059 <umain>

	// exit gracefully
	exit();
  8001e1:	e8 0a 00 00 00       	call   8001f0 <exit>
}
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f0:	f3 0f 1e fb          	endbr32 
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001fa:	e8 5b 13 00 00       	call   80155a <close_all>
	sys_env_destroy(0);
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	6a 00                	push   $0x0
  800204:	e8 65 0a 00 00       	call   800c6e <sys_env_destroy>
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80020e:	f3 0f 1e fb          	endbr32 
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800217:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80021a:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800220:	e8 6f 0a 00 00       	call   800c94 <sys_getenvid>
  800225:	83 ec 0c             	sub    $0xc,%esp
  800228:	ff 75 0c             	pushl  0xc(%ebp)
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	56                   	push   %esi
  80022f:	50                   	push   %eax
  800230:	68 f8 2b 80 00       	push   $0x802bf8
  800235:	e8 bb 00 00 00       	call   8002f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80023a:	83 c4 18             	add    $0x18,%esp
  80023d:	53                   	push   %ebx
  80023e:	ff 75 10             	pushl  0x10(%ebp)
  800241:	e8 5a 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  800246:	c7 04 24 ba 32 80 00 	movl   $0x8032ba,(%esp)
  80024d:	e8 a3 00 00 00       	call   8002f5 <cprintf>
  800252:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800255:	cc                   	int3   
  800256:	eb fd                	jmp    800255 <_panic+0x47>

00800258 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800258:	f3 0f 1e fb          	endbr32 
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	53                   	push   %ebx
  800260:	83 ec 04             	sub    $0x4,%esp
  800263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800266:	8b 13                	mov    (%ebx),%edx
  800268:	8d 42 01             	lea    0x1(%edx),%eax
  80026b:	89 03                	mov    %eax,(%ebx)
  80026d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800270:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800274:	3d ff 00 00 00       	cmp    $0xff,%eax
  800279:	74 09                	je     800284 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80027b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800282:	c9                   	leave  
  800283:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	68 ff 00 00 00       	push   $0xff
  80028c:	8d 43 08             	lea    0x8(%ebx),%eax
  80028f:	50                   	push   %eax
  800290:	e8 87 09 00 00       	call   800c1c <sys_cputs>
		b->idx = 0;
  800295:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80029b:	83 c4 10             	add    $0x10,%esp
  80029e:	eb db                	jmp    80027b <putch+0x23>

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	f3 0f 1e fb          	endbr32 
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b4:	00 00 00 
	b.cnt = 0;
  8002b7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002cd:	50                   	push   %eax
  8002ce:	68 58 02 80 00       	push   $0x800258
  8002d3:	e8 80 01 00 00       	call   800458 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d8:	83 c4 08             	add    $0x8,%esp
  8002db:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	e8 2f 09 00 00       	call   800c1c <sys_cputs>

	return b.cnt;
}
  8002ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f5:	f3 0f 1e fb          	endbr32 
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 95 ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 1c             	sub    $0x1c,%esp
  800316:	89 c7                	mov    %eax,%edi
  800318:	89 d6                	mov    %edx,%esi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800320:	89 d1                	mov    %edx,%ecx
  800322:	89 c2                	mov    %eax,%edx
  800324:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800327:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032a:	8b 45 10             	mov    0x10(%ebp),%eax
  80032d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033a:	39 c2                	cmp    %eax,%edx
  80033c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80033f:	72 3e                	jb     80037f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800341:	83 ec 0c             	sub    $0xc,%esp
  800344:	ff 75 18             	pushl  0x18(%ebp)
  800347:	83 eb 01             	sub    $0x1,%ebx
  80034a:	53                   	push   %ebx
  80034b:	50                   	push   %eax
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800352:	ff 75 e0             	pushl  -0x20(%ebp)
  800355:	ff 75 dc             	pushl  -0x24(%ebp)
  800358:	ff 75 d8             	pushl  -0x28(%ebp)
  80035b:	e8 80 25 00 00       	call   8028e0 <__udivdi3>
  800360:	83 c4 18             	add    $0x18,%esp
  800363:	52                   	push   %edx
  800364:	50                   	push   %eax
  800365:	89 f2                	mov    %esi,%edx
  800367:	89 f8                	mov    %edi,%eax
  800369:	e8 9f ff ff ff       	call   80030d <printnum>
  80036e:	83 c4 20             	add    $0x20,%esp
  800371:	eb 13                	jmp    800386 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800373:	83 ec 08             	sub    $0x8,%esp
  800376:	56                   	push   %esi
  800377:	ff 75 18             	pushl  0x18(%ebp)
  80037a:	ff d7                	call   *%edi
  80037c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80037f:	83 eb 01             	sub    $0x1,%ebx
  800382:	85 db                	test   %ebx,%ebx
  800384:	7f ed                	jg     800373 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	56                   	push   %esi
  80038a:	83 ec 04             	sub    $0x4,%esp
  80038d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800390:	ff 75 e0             	pushl  -0x20(%ebp)
  800393:	ff 75 dc             	pushl  -0x24(%ebp)
  800396:	ff 75 d8             	pushl  -0x28(%ebp)
  800399:	e8 52 26 00 00       	call   8029f0 <__umoddi3>
  80039e:	83 c4 14             	add    $0x14,%esp
  8003a1:	0f be 80 1b 2c 80 00 	movsbl 0x802c1b(%eax),%eax
  8003a8:	50                   	push   %eax
  8003a9:	ff d7                	call   *%edi
}
  8003ab:	83 c4 10             	add    $0x10,%esp
  8003ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5f                   	pop    %edi
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003b6:	83 fa 01             	cmp    $0x1,%edx
  8003b9:	7f 13                	jg     8003ce <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 1c                	je     8003db <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e0:	89 08                	mov    %ecx,(%eax)
  8003e2:	8b 02                	mov    (%edx),%eax
  8003e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e9:	c3                   	ret    

008003ea <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003ea:	83 fa 01             	cmp    $0x1,%edx
  8003ed:	7f 0f                	jg     8003fe <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 18                	je     80040b <getint+0x21>
		return va_arg(*ap, long);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	99                   	cltd   
  8003fd:	c3                   	ret    
		return va_arg(*ap, long long);
  8003fe:	8b 10                	mov    (%eax),%edx
  800400:	8d 4a 08             	lea    0x8(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 02                	mov    (%edx),%eax
  800407:	8b 52 04             	mov    0x4(%edx),%edx
  80040a:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80040b:	8b 10                	mov    (%eax),%edx
  80040d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800410:	89 08                	mov    %ecx,(%eax)
  800412:	8b 02                	mov    (%edx),%eax
  800414:	99                   	cltd   
}
  800415:	c3                   	ret    

00800416 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800416:	f3 0f 1e fb          	endbr32 
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1f>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
{
  800437:	f3 0f 1e fb          	endbr32 
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800441:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800444:	50                   	push   %eax
  800445:	ff 75 10             	pushl  0x10(%ebp)
  800448:	ff 75 0c             	pushl  0xc(%ebp)
  80044b:	ff 75 08             	pushl  0x8(%ebp)
  80044e:	e8 05 00 00 00       	call   800458 <vprintfmt>
}
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	c9                   	leave  
  800457:	c3                   	ret    

00800458 <vprintfmt>:
{
  800458:	f3 0f 1e fb          	endbr32 
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	57                   	push   %edi
  800460:	56                   	push   %esi
  800461:	53                   	push   %ebx
  800462:	83 ec 2c             	sub    $0x2c,%esp
  800465:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800468:	8b 75 0c             	mov    0xc(%ebp),%esi
  80046b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80046e:	e9 86 02 00 00       	jmp    8006f9 <vprintfmt+0x2a1>
		padc = ' ';
  800473:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800477:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80047e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800485:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8d 47 01             	lea    0x1(%edi),%eax
  800494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800497:	0f b6 17             	movzbl (%edi),%edx
  80049a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80049d:	3c 55                	cmp    $0x55,%al
  80049f:	0f 87 df 02 00 00    	ja     800784 <vprintfmt+0x32c>
  8004a5:	0f b6 c0             	movzbl %al,%eax
  8004a8:	3e ff 24 85 60 2d 80 	notrack jmp *0x802d60(,%eax,4)
  8004af:	00 
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004b3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004b7:	eb d8                	jmp    800491 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004c0:	eb cf                	jmp    800491 <vprintfmt+0x39>
  8004c2:	0f b6 d2             	movzbl %dl,%edx
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004d7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004da:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004dd:	83 f9 09             	cmp    $0x9,%ecx
  8004e0:	77 52                	ja     800534 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8004e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004e5:	eb e9                	jmp    8004d0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fc:	79 93                	jns    800491 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80050b:	eb 84                	jmp    800491 <vprintfmt+0x39>
  80050d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800510:	85 c0                	test   %eax,%eax
  800512:	ba 00 00 00 00       	mov    $0x0,%edx
  800517:	0f 49 d0             	cmovns %eax,%edx
  80051a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800520:	e9 6c ff ff ff       	jmp    800491 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800528:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80052f:	e9 5d ff ff ff       	jmp    800491 <vprintfmt+0x39>
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80053a:	eb bc                	jmp    8004f8 <vprintfmt+0xa0>
			lflag++;
  80053c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800542:	e9 4a ff ff ff       	jmp    800491 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	ff 30                	pushl  (%eax)
  800556:	ff d3                	call   *%ebx
			break;
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	e9 96 01 00 00       	jmp    8006f6 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	99                   	cltd   
  80056c:	31 d0                	xor    %edx,%eax
  80056e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800570:	83 f8 0f             	cmp    $0xf,%eax
  800573:	7f 20                	jg     800595 <vprintfmt+0x13d>
  800575:	8b 14 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 15                	je     800595 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800580:	52                   	push   %edx
  800581:	68 d5 31 80 00       	push   $0x8031d5
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	e8 aa fe ff ff       	call   800437 <printfmt>
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	e9 61 01 00 00       	jmp    8006f6 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800595:	50                   	push   %eax
  800596:	68 33 2c 80 00       	push   $0x802c33
  80059b:	56                   	push   %esi
  80059c:	53                   	push   %ebx
  80059d:	e8 95 fe ff ff       	call   800437 <printfmt>
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	e9 4c 01 00 00       	jmp    8006f6 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8005b5:	85 c9                	test   %ecx,%ecx
  8005b7:	b8 2c 2c 80 00       	mov    $0x802c2c,%eax
  8005bc:	0f 45 c1             	cmovne %ecx,%eax
  8005bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c6:	7e 06                	jle    8005ce <vprintfmt+0x176>
  8005c8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005cc:	75 0d                	jne    8005db <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005d1:	89 c7                	mov    %eax,%edi
  8005d3:	03 45 e0             	add    -0x20(%ebp),%eax
  8005d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d9:	eb 57                	jmp    800632 <vprintfmt+0x1da>
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	ff 75 d8             	pushl  -0x28(%ebp)
  8005e1:	ff 75 cc             	pushl  -0x34(%ebp)
  8005e4:	e8 4f 02 00 00       	call   800838 <strnlen>
  8005e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ec:	29 c2                	sub    %eax,%edx
  8005ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f4:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005f8:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8005fb:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	85 db                	test   %ebx,%ebx
  8005ff:	7e 10                	jle    800611 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	56                   	push   %esi
  800605:	57                   	push   %edi
  800606:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 eb 01             	sub    $0x1,%ebx
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	eb ec                	jmp    8005fd <vprintfmt+0x1a5>
  800611:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800614:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800617:	85 d2                	test   %edx,%edx
  800619:	b8 00 00 00 00       	mov    $0x0,%eax
  80061e:	0f 49 c2             	cmovns %edx,%eax
  800621:	29 c2                	sub    %eax,%edx
  800623:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800626:	eb a6                	jmp    8005ce <vprintfmt+0x176>
					putch(ch, putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	56                   	push   %esi
  80062c:	52                   	push   %edx
  80062d:	ff d3                	call   *%ebx
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800635:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800637:	83 c7 01             	add    $0x1,%edi
  80063a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063e:	0f be d0             	movsbl %al,%edx
  800641:	85 d2                	test   %edx,%edx
  800643:	74 42                	je     800687 <vprintfmt+0x22f>
  800645:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800649:	78 06                	js     800651 <vprintfmt+0x1f9>
  80064b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80064f:	78 1e                	js     80066f <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800651:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800655:	74 d1                	je     800628 <vprintfmt+0x1d0>
  800657:	0f be c0             	movsbl %al,%eax
  80065a:	83 e8 20             	sub    $0x20,%eax
  80065d:	83 f8 5e             	cmp    $0x5e,%eax
  800660:	76 c6                	jbe    800628 <vprintfmt+0x1d0>
					putch('?', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	56                   	push   %esi
  800666:	6a 3f                	push   $0x3f
  800668:	ff d3                	call   *%ebx
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb c3                	jmp    800632 <vprintfmt+0x1da>
  80066f:	89 cf                	mov    %ecx,%edi
  800671:	eb 0e                	jmp    800681 <vprintfmt+0x229>
				putch(' ', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	56                   	push   %esi
  800677:	6a 20                	push   $0x20
  800679:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80067b:	83 ef 01             	sub    $0x1,%edi
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	85 ff                	test   %edi,%edi
  800683:	7f ee                	jg     800673 <vprintfmt+0x21b>
  800685:	eb 6f                	jmp    8006f6 <vprintfmt+0x29e>
  800687:	89 cf                	mov    %ecx,%edi
  800689:	eb f6                	jmp    800681 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80068b:	89 ca                	mov    %ecx,%edx
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
  800690:	e8 55 fd ff ff       	call   8003ea <getint>
  800695:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800698:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80069b:	85 d2                	test   %edx,%edx
  80069d:	78 0b                	js     8006aa <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80069f:	89 d1                	mov    %edx,%ecx
  8006a1:	89 c2                	mov    %eax,%edx
			base = 10;
  8006a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a8:	eb 32                	jmp    8006dc <vprintfmt+0x284>
				putch('-', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	56                   	push   %esi
  8006ae:	6a 2d                	push   $0x2d
  8006b0:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 d1 00             	adc    $0x0,%ecx
  8006bd:	f7 d9                	neg    %ecx
  8006bf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	eb 13                	jmp    8006dc <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 e3 fc ff ff       	call   8003b6 <getuint>
  8006d3:	89 d1                	mov    %edx,%ecx
  8006d5:	89 c2                	mov    %eax,%edx
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e3:	57                   	push   %edi
  8006e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e7:	50                   	push   %eax
  8006e8:	51                   	push   %ecx
  8006e9:	52                   	push   %edx
  8006ea:	89 f2                	mov    %esi,%edx
  8006ec:	89 d8                	mov    %ebx,%eax
  8006ee:	e8 1a fc ff ff       	call   80030d <printnum>
			break;
  8006f3:	83 c4 20             	add    $0x20,%esp
{
  8006f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f9:	83 c7 01             	add    $0x1,%edi
  8006fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800700:	83 f8 25             	cmp    $0x25,%eax
  800703:	0f 84 6a fd ff ff    	je     800473 <vprintfmt+0x1b>
			if (ch == '\0')
  800709:	85 c0                	test   %eax,%eax
  80070b:	0f 84 93 00 00 00    	je     8007a4 <vprintfmt+0x34c>
			putch(ch, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	56                   	push   %esi
  800715:	50                   	push   %eax
  800716:	ff d3                	call   *%ebx
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb dc                	jmp    8006f9 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80071d:	89 ca                	mov    %ecx,%edx
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 8f fc ff ff       	call   8003b6 <getuint>
  800727:	89 d1                	mov    %edx,%ecx
  800729:	89 c2                	mov    %eax,%edx
			base = 8;
  80072b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800730:	eb aa                	jmp    8006dc <vprintfmt+0x284>
			putch('0', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	56                   	push   %esi
  800736:	6a 30                	push   $0x30
  800738:	ff d3                	call   *%ebx
			putch('x', putdat);
  80073a:	83 c4 08             	add    $0x8,%esp
  80073d:	56                   	push   %esi
  80073e:	6a 78                	push   $0x78
  800740:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 04             	lea    0x4(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800752:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800755:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075a:	eb 80                	jmp    8006dc <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 50 fc ff ff       	call   8003b6 <getuint>
  800766:	89 d1                	mov    %edx,%ecx
  800768:	89 c2                	mov    %eax,%edx
			base = 16;
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
  80076f:	e9 68 ff ff ff       	jmp    8006dc <vprintfmt+0x284>
			putch(ch, putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	56                   	push   %esi
  800778:	6a 25                	push   $0x25
  80077a:	ff d3                	call   *%ebx
			break;
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	e9 72 ff ff ff       	jmp    8006f6 <vprintfmt+0x29e>
			putch('%', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	56                   	push   %esi
  800788:	6a 25                	push   $0x25
  80078a:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	89 f8                	mov    %edi,%eax
  800791:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800795:	74 05                	je     80079c <vprintfmt+0x344>
  800797:	83 e8 01             	sub    $0x1,%eax
  80079a:	eb f5                	jmp    800791 <vprintfmt+0x339>
  80079c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079f:	e9 52 ff ff ff       	jmp    8006f6 <vprintfmt+0x29e>
}
  8007a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5f                   	pop    %edi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 18             	sub    $0x18,%esp
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 26                	je     8007f7 <vsnprintf+0x4b>
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	7e 22                	jle    8007f7 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d5:	ff 75 14             	pushl  0x14(%ebp)
  8007d8:	ff 75 10             	pushl  0x10(%ebp)
  8007db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	68 16 04 80 00       	push   $0x800416
  8007e4:	e8 6f fc ff ff       	call   800458 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f2:	83 c4 10             	add    $0x10,%esp
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb f7                	jmp    8007f5 <vsnprintf+0x49>

008007fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fe:	f3 0f 1e fb          	endbr32 
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080b:	50                   	push   %eax
  80080c:	ff 75 10             	pushl  0x10(%ebp)
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	ff 75 08             	pushl  0x8(%ebp)
  800815:	e8 92 ff ff ff       	call   8007ac <vsnprintf>
	va_end(ap);

	return rc;
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081c:	f3 0f 1e fb          	endbr32 
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082f:	74 05                	je     800836 <strlen+0x1a>
		n++;
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	eb f5                	jmp    80082b <strlen+0xf>
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	f3 0f 1e fb          	endbr32 
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	39 d0                	cmp    %edx,%eax
  80084c:	74 0d                	je     80085b <strnlen+0x23>
  80084e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800852:	74 05                	je     800859 <strnlen+0x21>
		n++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	eb f1                	jmp    80084a <strnlen+0x12>
  800859:	89 c2                	mov    %eax,%edx
	return n;
}
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085f:	f3 0f 1e fb          	endbr32 
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
  800872:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800876:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	84 d2                	test   %dl,%dl
  80087e:	75 f2                	jne    800872 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800880:	89 c8                	mov    %ecx,%eax
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800885:	f3 0f 1e fb          	endbr32 
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	83 ec 10             	sub    $0x10,%esp
  800890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800893:	53                   	push   %ebx
  800894:	e8 83 ff ff ff       	call   80081c <strlen>
  800899:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80089c:	ff 75 0c             	pushl  0xc(%ebp)
  80089f:	01 d8                	add    %ebx,%eax
  8008a1:	50                   	push   %eax
  8008a2:	e8 b8 ff ff ff       	call   80085f <strcpy>
	return dst;
}
  8008a7:	89 d8                	mov    %ebx,%eax
  8008a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ae:	f3 0f 1e fb          	endbr32 
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	39 d8                	cmp    %ebx,%eax
  8008c6:	74 11                	je     8008d9 <strncpy+0x2b>
		*dst++ = *src;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	0f b6 0a             	movzbl (%edx),%ecx
  8008ce:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d1:	80 f9 01             	cmp    $0x1,%cl
  8008d4:	83 da ff             	sbb    $0xffffffff,%edx
  8008d7:	eb eb                	jmp    8008c4 <strncpy+0x16>
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	f3 0f 1e fb          	endbr32 
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ee:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 d2                	test   %edx,%edx
  8008f5:	74 21                	je     800918 <strlcpy+0x39>
  8008f7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008fd:	39 c2                	cmp    %eax,%edx
  8008ff:	74 14                	je     800915 <strlcpy+0x36>
  800901:	0f b6 19             	movzbl (%ecx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	74 0b                	je     800913 <strlcpy+0x34>
			*dst++ = *src++;
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800911:	eb ea                	jmp    8008fd <strlcpy+0x1e>
  800913:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800915:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800918:	29 f0                	sub    %esi,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092b:	0f b6 01             	movzbl (%ecx),%eax
  80092e:	84 c0                	test   %al,%al
  800930:	74 0c                	je     80093e <strcmp+0x20>
  800932:	3a 02                	cmp    (%edx),%al
  800934:	75 08                	jne    80093e <strcmp+0x20>
		p++, q++;
  800936:	83 c1 01             	add    $0x1,%ecx
  800939:	83 c2 01             	add    $0x1,%edx
  80093c:	eb ed                	jmp    80092b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093e:	0f b6 c0             	movzbl %al,%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800948:	f3 0f 1e fb          	endbr32 
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
  800956:	89 c3                	mov    %eax,%ebx
  800958:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095b:	eb 06                	jmp    800963 <strncmp+0x1b>
		n--, p++, q++;
  80095d:	83 c0 01             	add    $0x1,%eax
  800960:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800963:	39 d8                	cmp    %ebx,%eax
  800965:	74 16                	je     80097d <strncmp+0x35>
  800967:	0f b6 08             	movzbl (%eax),%ecx
  80096a:	84 c9                	test   %cl,%cl
  80096c:	74 04                	je     800972 <strncmp+0x2a>
  80096e:	3a 0a                	cmp    (%edx),%cl
  800970:	74 eb                	je     80095d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800972:	0f b6 00             	movzbl (%eax),%eax
  800975:	0f b6 12             	movzbl (%edx),%edx
  800978:	29 d0                	sub    %edx,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    
		return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
  800982:	eb f6                	jmp    80097a <strncmp+0x32>

00800984 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800992:	0f b6 10             	movzbl (%eax),%edx
  800995:	84 d2                	test   %dl,%dl
  800997:	74 09                	je     8009a2 <strchr+0x1e>
		if (*s == c)
  800999:	38 ca                	cmp    %cl,%dl
  80099b:	74 0a                	je     8009a7 <strchr+0x23>
	for (; *s; s++)
  80099d:	83 c0 01             	add    $0x1,%eax
  8009a0:	eb f0                	jmp    800992 <strchr+0xe>
			return (char *) s;
	return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a9:	f3 0f 1e fb          	endbr32 
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ba:	38 ca                	cmp    %cl,%dl
  8009bc:	74 09                	je     8009c7 <strfind+0x1e>
  8009be:	84 d2                	test   %dl,%dl
  8009c0:	74 05                	je     8009c7 <strfind+0x1e>
	for (; *s; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	eb f0                	jmp    8009b7 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c9:	f3 0f 1e fb          	endbr32 
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	74 33                	je     800a10 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dd:	89 d0                	mov    %edx,%eax
  8009df:	09 c8                	or     %ecx,%eax
  8009e1:	a8 03                	test   $0x3,%al
  8009e3:	75 23                	jne    800a08 <memset+0x3f>
		c &= 0xFF;
  8009e5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e9:	89 d8                	mov    %ebx,%eax
  8009eb:	c1 e0 08             	shl    $0x8,%eax
  8009ee:	89 df                	mov    %ebx,%edi
  8009f0:	c1 e7 18             	shl    $0x18,%edi
  8009f3:	89 de                	mov    %ebx,%esi
  8009f5:	c1 e6 10             	shl    $0x10,%esi
  8009f8:	09 f7                	or     %esi,%edi
  8009fa:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a01:	89 d7                	mov    %edx,%edi
  800a03:	fc                   	cld    
  800a04:	f3 ab                	rep stos %eax,%es:(%edi)
  800a06:	eb 08                	jmp    800a10 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a08:	89 d7                	mov    %edx,%edi
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	fc                   	cld    
  800a0e:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a17:	f3 0f 1e fb          	endbr32 
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a29:	39 c6                	cmp    %eax,%esi
  800a2b:	73 32                	jae    800a5f <memmove+0x48>
  800a2d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a30:	39 c2                	cmp    %eax,%edx
  800a32:	76 2b                	jbe    800a5f <memmove+0x48>
		s += n;
		d += n;
  800a34:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a37:	89 fe                	mov    %edi,%esi
  800a39:	09 ce                	or     %ecx,%esi
  800a3b:	09 d6                	or     %edx,%esi
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 0e                	jne    800a53 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a45:	83 ef 04             	sub    $0x4,%edi
  800a48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4e:	fd                   	std    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a51:	eb 09                	jmp    800a5c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a53:	83 ef 01             	sub    $0x1,%edi
  800a56:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a59:	fd                   	std    
  800a5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5c:	fc                   	cld    
  800a5d:	eb 1a                	jmp    800a79 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	09 ca                	or     %ecx,%edx
  800a63:	09 f2                	or     %esi,%edx
  800a65:	f6 c2 03             	test   $0x3,%dl
  800a68:	75 0a                	jne    800a74 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a72:	eb 05                	jmp    800a79 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 82 ff ff ff       	call   800a17 <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	f3 0f 1e fb          	endbr32 
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	89 c6                	mov    %eax,%esi
  800aa8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aab:	39 f0                	cmp    %esi,%eax
  800aad:	74 1c                	je     800acb <memcmp+0x34>
		if (*s1 != *s2)
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	0f b6 1a             	movzbl (%edx),%ebx
  800ab5:	38 d9                	cmp    %bl,%cl
  800ab7:	75 08                	jne    800ac1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	83 c2 01             	add    $0x1,%edx
  800abf:	eb ea                	jmp    800aab <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ac1:	0f b6 c1             	movzbl %cl,%eax
  800ac4:	0f b6 db             	movzbl %bl,%ebx
  800ac7:	29 d8                	sub    %ebx,%eax
  800ac9:	eb 05                	jmp    800ad0 <memcmp+0x39>
	}

	return 0;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad4:	f3 0f 1e fb          	endbr32 
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae6:	39 d0                	cmp    %edx,%eax
  800ae8:	73 09                	jae    800af3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aea:	38 08                	cmp    %cl,(%eax)
  800aec:	74 05                	je     800af3 <memfind+0x1f>
	for (; s < ends; s++)
  800aee:	83 c0 01             	add    $0x1,%eax
  800af1:	eb f3                	jmp    800ae6 <memfind+0x12>
			break;
	return (void *) s;
}
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af5:	f3 0f 1e fb          	endbr32 
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x15>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f6                	je     800b07 <strtol+0x12>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f2                	je     800b07 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	74 2a                	je     800b43 <strtol+0x4e>
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1e:	3c 2d                	cmp    $0x2d,%al
  800b20:	74 2b                	je     800b4d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b28:	75 0f                	jne    800b39 <strtol+0x44>
  800b2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2d:	74 28                	je     800b57 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2f:	85 db                	test   %ebx,%ebx
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b36:	0f 44 d8             	cmove  %eax,%ebx
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b41:	eb 46                	jmp    800b89 <strtol+0x94>
		s++;
  800b43:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	eb d5                	jmp    800b22 <strtol+0x2d>
		s++, neg = 1;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	bf 01 00 00 00       	mov    $0x1,%edi
  800b55:	eb cb                	jmp    800b22 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b5b:	74 0e                	je     800b6b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	75 d8                	jne    800b39 <strtol+0x44>
		s++, base = 8;
  800b61:	83 c1 01             	add    $0x1,%ecx
  800b64:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b69:	eb ce                	jmp    800b39 <strtol+0x44>
		s += 2, base = 16;
  800b6b:	83 c1 02             	add    $0x2,%ecx
  800b6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b73:	eb c4                	jmp    800b39 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b75:	0f be d2             	movsbl %dl,%edx
  800b78:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7e:	7d 3a                	jge    800bba <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b80:	83 c1 01             	add    $0x1,%ecx
  800b83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b87:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b89:	0f b6 11             	movzbl (%ecx),%edx
  800b8c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 09             	cmp    $0x9,%bl
  800b94:	76 df                	jbe    800b75 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb d3                	jmp    800b7b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
  800bb8:	eb c1                	jmp    800b7b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 05                	je     800bc5 <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	f7 da                	neg    %edx
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	0f 45 c2             	cmovne %edx,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 1c             	sub    $0x1c,%esp
  800bdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800be2:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bea:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bed:	8b 75 14             	mov    0x14(%ebp),%esi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bf6:	74 04                	je     800bfc <syscall+0x29>
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7f 08                	jg     800c04 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	ff 75 e0             	pushl  -0x20(%ebp)
  800c0b:	68 1f 2f 80 00       	push   $0x802f1f
  800c10:	6a 23                	push   $0x23
  800c12:	68 3c 2f 80 00       	push   $0x802f3c
  800c17:	e8 f2 f5 ff ff       	call   80020e <_panic>

00800c1c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c1c:	f3 0f 1e fb          	endbr32 
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	e8 92 ff ff ff       	call   800bd3 <syscall>
}
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c46:	f3 0f 1e fb          	endbr32 
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c50:	6a 00                	push   $0x0
  800c52:	6a 00                	push   $0x0
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 01 00 00 00       	mov    $0x1,%eax
  800c67:	e8 67 ff ff ff       	call   800bd3 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	6a 00                	push   $0x0
  800c7e:	6a 00                	push   $0x0
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c83:	ba 01 00 00 00       	mov    $0x1,%edx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	e8 41 ff ff ff       	call   800bd3 <syscall>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c94:	f3 0f 1e fb          	endbr32 
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	6a 00                	push   $0x0
  800ca6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb5:	e8 19 ff ff ff       	call   800bd3 <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_yield>:

void
sys_yield(void)
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cdd:	e8 f1 fe ff ff       	call   800bd3 <syscall>
}
  800ce2:	83 c4 10             	add    $0x10,%esp
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce7:	f3 0f 1e fb          	endbr32 
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cf1:	6a 00                	push   $0x0
  800cf3:	6a 00                	push   $0x0
  800cf5:	ff 75 10             	pushl  0x10(%ebp)
  800cf8:	ff 75 0c             	pushl  0xc(%ebp)
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	ba 01 00 00 00       	mov    $0x1,%edx
  800d03:	b8 04 00 00 00       	mov    $0x4,%eax
  800d08:	e8 c6 fe ff ff       	call   800bd3 <syscall>
}
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d0f:	f3 0f 1e fb          	endbr32 
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d19:	ff 75 18             	pushl  0x18(%ebp)
  800d1c:	ff 75 14             	pushl  0x14(%ebp)
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	ba 01 00 00 00       	mov    $0x1,%edx
  800d2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d32:	e8 9c fe ff ff       	call   800bd3 <syscall>
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	ff 75 0c             	pushl  0xc(%ebp)
  800d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d54:	b8 06 00 00 00       	mov    $0x6,%eax
  800d59:	e8 75 fe ff ff       	call   800bd3 <syscall>
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d6a:	6a 00                	push   $0x0
  800d6c:	6a 00                	push   $0x0
  800d6e:	6a 00                	push   $0x0
  800d70:	ff 75 0c             	pushl  0xc(%ebp)
  800d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d76:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	e8 4e fe ff ff       	call   800bd3 <syscall>
}
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    

00800d87 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d87:	f3 0f 1e fb          	endbr32 
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d91:	6a 00                	push   $0x0
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	ff 75 0c             	pushl  0xc(%ebp)
  800d9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800da2:	b8 09 00 00 00       	mov    $0x9,%eax
  800da7:	e8 27 fe ff ff       	call   800bd3 <syscall>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dae:	f3 0f 1e fb          	endbr32 
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800db8:	6a 00                	push   $0x0
  800dba:	6a 00                	push   $0x0
  800dbc:	6a 00                	push   $0x0
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dce:	e8 00 fe ff ff       	call   800bd3 <syscall>
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd5:	f3 0f 1e fb          	endbr32 
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ddf:	6a 00                	push   $0x0
  800de1:	ff 75 14             	pushl  0x14(%ebp)
  800de4:	ff 75 10             	pushl  0x10(%ebp)
  800de7:	ff 75 0c             	pushl  0xc(%ebp)
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	ba 00 00 00 00       	mov    $0x0,%edx
  800df2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df7:	e8 d7 fd ff ff       	call   800bd3 <syscall>
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e08:	6a 00                	push   $0x0
  800e0a:	6a 00                	push   $0x0
  800e0c:	6a 00                	push   $0x0
  800e0e:	6a 00                	push   $0x0
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	ba 01 00 00 00       	mov    $0x1,%edx
  800e18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1d:	e8 b1 fd ff ff       	call   800bd3 <syscall>
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800e2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800e34:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800e37:	f6 c6 04             	test   $0x4,%dh
  800e3a:	75 54                	jne    800e90 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800e3c:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e42:	0f 84 8d 00 00 00    	je     800ed5 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	68 05 08 00 00       	push   $0x805
  800e50:	53                   	push   %ebx
  800e51:	50                   	push   %eax
  800e52:	53                   	push   %ebx
  800e53:	6a 00                	push   $0x0
  800e55:	e8 b5 fe ff ff       	call   800d0f <sys_page_map>
		if (r < 0)
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 5f                	js     800ec0 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800e61:	83 ec 0c             	sub    $0xc,%esp
  800e64:	68 05 08 00 00       	push   $0x805
  800e69:	53                   	push   %ebx
  800e6a:	6a 00                	push   $0x0
  800e6c:	53                   	push   %ebx
  800e6d:	6a 00                	push   $0x0
  800e6f:	e8 9b fe ff ff       	call   800d0f <sys_page_map>
		if (r < 0)
  800e74:	83 c4 20             	add    $0x20,%esp
  800e77:	85 c0                	test   %eax,%eax
  800e79:	79 70                	jns    800eeb <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e7b:	50                   	push   %eax
  800e7c:	68 4c 2f 80 00       	push   $0x802f4c
  800e81:	68 9b 00 00 00       	push   $0x9b
  800e86:	68 ba 30 80 00       	push   $0x8030ba
  800e8b:	e8 7e f3 ff ff       	call   80020e <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e99:	52                   	push   %edx
  800e9a:	53                   	push   %ebx
  800e9b:	50                   	push   %eax
  800e9c:	53                   	push   %ebx
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 6b fe ff ff       	call   800d0f <sys_page_map>
		if (r < 0)
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 40                	jns    800eeb <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800eab:	50                   	push   %eax
  800eac:	68 4c 2f 80 00       	push   $0x802f4c
  800eb1:	68 92 00 00 00       	push   $0x92
  800eb6:	68 ba 30 80 00       	push   $0x8030ba
  800ebb:	e8 4e f3 ff ff       	call   80020e <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ec0:	50                   	push   %eax
  800ec1:	68 4c 2f 80 00       	push   $0x802f4c
  800ec6:	68 97 00 00 00       	push   $0x97
  800ecb:	68 ba 30 80 00       	push   $0x8030ba
  800ed0:	e8 39 f3 ff ff       	call   80020e <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	6a 05                	push   $0x5
  800eda:	53                   	push   %ebx
  800edb:	50                   	push   %eax
  800edc:	53                   	push   %ebx
  800edd:	6a 00                	push   $0x0
  800edf:	e8 2b fe ff ff       	call   800d0f <sys_page_map>
		if (r < 0)
  800ee4:	83 c4 20             	add    $0x20,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	78 0a                	js     800ef5 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ef5:	50                   	push   %eax
  800ef6:	68 4c 2f 80 00       	push   $0x802f4c
  800efb:	68 a0 00 00 00       	push   $0xa0
  800f00:	68 ba 30 80 00       	push   $0x8030ba
  800f05:	e8 04 f3 ff ff       	call   80020e <_panic>

00800f0a <dup_or_share>:
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	89 d6                	mov    %edx,%esi
  800f17:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800f19:	f6 c1 02             	test   $0x2,%cl
  800f1c:	0f 84 90 00 00 00    	je     800fb2 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	51                   	push   %ecx
  800f26:	52                   	push   %edx
  800f27:	50                   	push   %eax
  800f28:	e8 ba fd ff ff       	call   800ce7 <sys_page_alloc>
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 56                	js     800f8a <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	53                   	push   %ebx
  800f38:	68 00 00 40 00       	push   $0x400000
  800f3d:	6a 00                	push   $0x0
  800f3f:	56                   	push   %esi
  800f40:	57                   	push   %edi
  800f41:	e8 c9 fd ff ff       	call   800d0f <sys_page_map>
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 51                	js     800f9e <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800f4d:	83 ec 04             	sub    $0x4,%esp
  800f50:	68 00 10 00 00       	push   $0x1000
  800f55:	56                   	push   %esi
  800f56:	68 00 00 40 00       	push   $0x400000
  800f5b:	e8 b7 fa ff ff       	call   800a17 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f60:	83 c4 08             	add    $0x8,%esp
  800f63:	68 00 00 40 00       	push   $0x400000
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 ca fd ff ff       	call   800d39 <sys_page_unmap>
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 51                	jns    800fc7 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	68 bc 2f 80 00       	push   $0x802fbc
  800f7e:	6a 18                	push   $0x18
  800f80:	68 ba 30 80 00       	push   $0x8030ba
  800f85:	e8 84 f2 ff ff       	call   80020e <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 70 2f 80 00       	push   $0x802f70
  800f92:	6a 13                	push   $0x13
  800f94:	68 ba 30 80 00       	push   $0x8030ba
  800f99:	e8 70 f2 ff ff       	call   80020e <_panic>
			panic("sys_page_map failed at dup_or_share");
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	68 98 2f 80 00       	push   $0x802f98
  800fa6:	6a 15                	push   $0x15
  800fa8:	68 ba 30 80 00       	push   $0x8030ba
  800fad:	e8 5c f2 ff ff       	call   80020e <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	51                   	push   %ecx
  800fb6:	52                   	push   %edx
  800fb7:	50                   	push   %eax
  800fb8:	52                   	push   %edx
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 4f fd ff ff       	call   800d0f <sys_page_map>
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 08                	js     800fcf <dup_or_share+0xc5>
}
  800fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 98 2f 80 00       	push   $0x802f98
  800fd7:	6a 1c                	push   $0x1c
  800fd9:	68 ba 30 80 00       	push   $0x8030ba
  800fde:	e8 2b f2 ff ff       	call   80020e <_panic>

00800fe3 <pgfault>:
{
  800fe3:	f3 0f 1e fb          	endbr32 
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	53                   	push   %ebx
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ff1:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800ff3:	89 da                	mov    %ebx,%edx
  800ff5:	c1 ea 0c             	shr    $0xc,%edx
  800ff8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800fff:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801003:	74 6e                	je     801073 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  801005:	f6 c6 08             	test   $0x8,%dh
  801008:	74 7d                	je     801087 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  80100a:	83 ec 04             	sub    $0x4,%esp
  80100d:	6a 07                	push   $0x7
  80100f:	68 00 f0 7f 00       	push   $0x7ff000
  801014:	6a 00                	push   $0x0
  801016:	e8 cc fc ff ff       	call   800ce7 <sys_page_alloc>
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 79                	js     80109b <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801022:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	68 00 10 00 00       	push   $0x1000
  801030:	53                   	push   %ebx
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	e8 dc f9 ff ff       	call   800a17 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  80103b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801042:	53                   	push   %ebx
  801043:	6a 00                	push   $0x0
  801045:	68 00 f0 7f 00       	push   $0x7ff000
  80104a:	6a 00                	push   $0x0
  80104c:	e8 be fc ff ff       	call   800d0f <sys_page_map>
  801051:	83 c4 20             	add    $0x20,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 57                	js     8010af <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	68 00 f0 7f 00       	push   $0x7ff000
  801060:	6a 00                	push   $0x0
  801062:	e8 d2 fc ff ff       	call   800d39 <sys_page_unmap>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 55                	js     8010c3 <pgfault+0xe0>
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	68 c5 30 80 00       	push   $0x8030c5
  80107b:	6a 5e                	push   $0x5e
  80107d:	68 ba 30 80 00       	push   $0x8030ba
  801082:	e8 87 f1 ff ff       	call   80020e <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	68 e4 2f 80 00       	push   $0x802fe4
  80108f:	6a 62                	push   $0x62
  801091:	68 ba 30 80 00       	push   $0x8030ba
  801096:	e8 73 f1 ff ff       	call   80020e <_panic>
		panic("pgfault failed");
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	68 dd 30 80 00       	push   $0x8030dd
  8010a3:	6a 6d                	push   $0x6d
  8010a5:	68 ba 30 80 00       	push   $0x8030ba
  8010aa:	e8 5f f1 ff ff       	call   80020e <_panic>
		panic("pgfault failed");
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	68 dd 30 80 00       	push   $0x8030dd
  8010b7:	6a 72                	push   $0x72
  8010b9:	68 ba 30 80 00       	push   $0x8030ba
  8010be:	e8 4b f1 ff ff       	call   80020e <_panic>
		panic("pgfault failed");
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	68 dd 30 80 00       	push   $0x8030dd
  8010cb:	6a 74                	push   $0x74
  8010cd:	68 ba 30 80 00       	push   $0x8030ba
  8010d2:	e8 37 f1 ff ff       	call   80020e <_panic>

008010d7 <fork_v0>:
{
  8010d7:	f3 0f 1e fb          	endbr32 
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010e4:	b8 07 00 00 00       	mov    $0x7,%eax
  8010e9:	cd 30                	int    $0x30
  8010eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 1d                	js     801112 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  8010f5:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8010fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010fe:	74 26                	je     801126 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801100:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801105:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  80110b:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801110:	eb 4b                	jmp    80115d <fork_v0+0x86>
		panic("sys_exofork failed");
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	68 ec 30 80 00       	push   $0x8030ec
  80111a:	6a 2b                	push   $0x2b
  80111c:	68 ba 30 80 00       	push   $0x8030ba
  801121:	e8 e8 f0 ff ff       	call   80020e <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801126:	e8 69 fb ff ff       	call   800c94 <sys_getenvid>
  80112b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801130:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801133:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801138:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80113d:	eb 68                	jmp    8011a7 <fork_v0+0xd0>
				dup_or_share(envid,
  80113f:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801145:	89 da                	mov    %ebx,%edx
  801147:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80114a:	e8 bb fd ff ff       	call   800f0a <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  80114f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801155:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80115b:	74 36                	je     801193 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  80115d:	89 d8                	mov    %ebx,%eax
  80115f:	c1 e8 16             	shr    $0x16,%eax
  801162:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801169:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  80116b:	f6 02 01             	testb  $0x1,(%edx)
  80116e:	74 df                	je     80114f <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801170:	89 da                	mov    %ebx,%edx
  801172:	c1 ea 0a             	shr    $0xa,%edx
  801175:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80117b:	c1 e0 0c             	shl    $0xc,%eax
  80117e:	89 f9                	mov    %edi,%ecx
  801180:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  801186:	09 c8                	or     %ecx,%eax
  801188:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  80118a:	8b 08                	mov    (%eax),%ecx
  80118c:	f6 c1 01             	test   $0x1,%cl
  80118f:	74 be                	je     80114f <fork_v0+0x78>
  801191:	eb ac                	jmp    80113f <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	6a 02                	push   $0x2
  801198:	ff 75 e0             	pushl  -0x20(%ebp)
  80119b:	e8 c0 fb ff ff       	call   800d60 <sys_env_set_status>
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 0b                	js     8011b2 <fork_v0+0xdb>
}
  8011a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	68 04 30 80 00       	push   $0x803004
  8011ba:	6a 43                	push   $0x43
  8011bc:	68 ba 30 80 00       	push   $0x8030ba
  8011c1:	e8 48 f0 ff ff       	call   80020e <_panic>

008011c6 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8011c6:	f3 0f 1e fb          	endbr32 
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  8011d3:	68 e3 0f 80 00       	push   $0x800fe3
  8011d8:	e8 2e 15 00 00       	call   80270b <set_pgfault_handler>
  8011dd:	b8 07 00 00 00       	mov    $0x7,%eax
  8011e2:	cd 30                	int    $0x30
  8011e4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 2f                	js     80121d <fork+0x57>
  8011ee:	89 c7                	mov    %eax,%edi
  8011f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  8011f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011fb:	0f 85 9e 00 00 00    	jne    80129f <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801201:	e8 8e fa ff ff       	call   800c94 <sys_getenvid>
  801206:	25 ff 03 00 00       	and    $0x3ff,%eax
  80120b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80120e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801213:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801218:	e9 de 00 00 00       	jmp    8012fb <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  80121d:	50                   	push   %eax
  80121e:	68 2c 30 80 00       	push   $0x80302c
  801223:	68 c2 00 00 00       	push   $0xc2
  801228:	68 ba 30 80 00       	push   $0x8030ba
  80122d:	e8 dc ef ff ff       	call   80020e <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801232:	83 ec 04             	sub    $0x4,%esp
  801235:	6a 07                	push   $0x7
  801237:	68 00 f0 bf ee       	push   $0xeebff000
  80123c:	57                   	push   %edi
  80123d:	e8 a5 fa ff ff       	call   800ce7 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	75 33                	jne    80127c <fork+0xb6>
  801249:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  80124c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801252:	74 3d                	je     801291 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801254:	89 d8                	mov    %ebx,%eax
  801256:	c1 e0 0c             	shl    $0xc,%eax
  801259:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  801267:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  80126c:	74 c4                	je     801232 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  80126e:	f6 c1 01             	test   $0x1,%cl
  801271:	74 d6                	je     801249 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  801273:	89 f8                	mov    %edi,%eax
  801275:	e8 aa fb ff ff       	call   800e24 <duppage>
  80127a:	eb cd                	jmp    801249 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  80127c:	50                   	push   %eax
  80127d:	68 4c 30 80 00       	push   $0x80304c
  801282:	68 e1 00 00 00       	push   $0xe1
  801287:	68 ba 30 80 00       	push   $0x8030ba
  80128c:	e8 7d ef ff ff       	call   80020e <_panic>
  801291:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  801295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  801298:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  80129d:	74 18                	je     8012b7 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  80129f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012a2:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8012a9:	a8 01                	test   $0x1,%al
  8012ab:	74 e4                	je     801291 <fork+0xcb>
  8012ad:	c1 e6 16             	shl    $0x16,%esi
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b5:	eb 9d                	jmp    801254 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	6a 07                	push   $0x7
  8012bc:	68 00 f0 bf ee       	push   $0xeebff000
  8012c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8012c4:	e8 1e fa ff ff       	call   800ce7 <sys_page_alloc>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 36                	js     801306 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	68 66 27 80 00       	push   $0x802766
  8012d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8012db:	e8 ce fa ff ff       	call   800dae <sys_env_set_pgfault_upcall>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 36                	js     80131d <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	6a 02                	push   $0x2
  8012ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8012ef:	e8 6c fa ff ff       	call   800d60 <sys_env_set_status>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 39                	js     801334 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  8012fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	68 ff 30 80 00       	push   $0x8030ff
  80130e:	68 f4 00 00 00       	push   $0xf4
  801313:	68 ba 30 80 00       	push   $0x8030ba
  801318:	e8 f1 ee ff ff       	call   80020e <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	68 70 30 80 00       	push   $0x803070
  801325:	68 f8 00 00 00       	push   $0xf8
  80132a:	68 ba 30 80 00       	push   $0x8030ba
  80132f:	e8 da ee ff ff       	call   80020e <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801334:	50                   	push   %eax
  801335:	68 94 30 80 00       	push   $0x803094
  80133a:	68 fc 00 00 00       	push   $0xfc
  80133f:	68 ba 30 80 00       	push   $0x8030ba
  801344:	e8 c5 ee ff ff       	call   80020e <_panic>

00801349 <sfork>:

// Challenge!
int
sfork(void)
{
  801349:	f3 0f 1e fb          	endbr32 
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801353:	68 17 31 80 00       	push   $0x803117
  801358:	68 05 01 00 00       	push   $0x105
  80135d:	68 ba 30 80 00       	push   $0x8030ba
  801362:	e8 a7 ee ff ff       	call   80020e <_panic>

00801367 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801367:	f3 0f 1e fb          	endbr32 
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	05 00 00 00 30       	add    $0x30000000,%eax
  801376:	c1 e8 0c             	shr    $0xc,%eax
}
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80137b:	f3 0f 1e fb          	endbr32 
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 da ff ff ff       	call   801367 <fd2num>
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	c1 e0 0c             	shl    $0xc,%eax
  801393:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80139a:	f3 0f 1e fb          	endbr32 
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	c1 ea 16             	shr    $0x16,%edx
  8013ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b2:	f6 c2 01             	test   $0x1,%dl
  8013b5:	74 2d                	je     8013e4 <fd_alloc+0x4a>
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	c1 ea 0c             	shr    $0xc,%edx
  8013bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c3:	f6 c2 01             	test   $0x1,%dl
  8013c6:	74 1c                	je     8013e4 <fd_alloc+0x4a>
  8013c8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013d2:	75 d2                	jne    8013a6 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8013dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8013e2:	eb 0a                	jmp    8013ee <fd_alloc+0x54>
			*fd_store = fd;
  8013e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f0:	f3 0f 1e fb          	endbr32 
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013fa:	83 f8 1f             	cmp    $0x1f,%eax
  8013fd:	77 30                	ja     80142f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ff:	c1 e0 0c             	shl    $0xc,%eax
  801402:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801407:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80140d:	f6 c2 01             	test   $0x1,%dl
  801410:	74 24                	je     801436 <fd_lookup+0x46>
  801412:	89 c2                	mov    %eax,%edx
  801414:	c1 ea 0c             	shr    $0xc,%edx
  801417:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80141e:	f6 c2 01             	test   $0x1,%dl
  801421:	74 1a                	je     80143d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801423:	8b 55 0c             	mov    0xc(%ebp),%edx
  801426:	89 02                	mov    %eax,(%edx)
	return 0;
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    
		return -E_INVAL;
  80142f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801434:	eb f7                	jmp    80142d <fd_lookup+0x3d>
		return -E_INVAL;
  801436:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143b:	eb f0                	jmp    80142d <fd_lookup+0x3d>
  80143d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801442:	eb e9                	jmp    80142d <fd_lookup+0x3d>

00801444 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801444:	f3 0f 1e fb          	endbr32 
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801451:	ba ac 31 80 00       	mov    $0x8031ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801456:	b8 0c 40 80 00       	mov    $0x80400c,%eax
		if (devtab[i]->dev_id == dev_id) {
  80145b:	39 08                	cmp    %ecx,(%eax)
  80145d:	74 33                	je     801492 <dev_lookup+0x4e>
  80145f:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801462:	8b 02                	mov    (%edx),%eax
  801464:	85 c0                	test   %eax,%eax
  801466:	75 f3                	jne    80145b <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801468:	a1 04 50 80 00       	mov    0x805004,%eax
  80146d:	8b 40 48             	mov    0x48(%eax),%eax
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	51                   	push   %ecx
  801474:	50                   	push   %eax
  801475:	68 30 31 80 00       	push   $0x803130
  80147a:	e8 76 ee ff ff       	call   8002f5 <cprintf>
	*dev = 0;
  80147f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801482:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    
			*dev = devtab[i];
  801492:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801495:	89 01                	mov    %eax,(%ecx)
			return 0;
  801497:	b8 00 00 00 00       	mov    $0x0,%eax
  80149c:	eb f2                	jmp    801490 <dev_lookup+0x4c>

0080149e <fd_close>:
{
  80149e:	f3 0f 1e fb          	endbr32 
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	57                   	push   %edi
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 28             	sub    $0x28,%esp
  8014ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b1:	56                   	push   %esi
  8014b2:	e8 b0 fe ff ff       	call   801367 <fd2num>
  8014b7:	83 c4 08             	add    $0x8,%esp
  8014ba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8014bd:	52                   	push   %edx
  8014be:	50                   	push   %eax
  8014bf:	e8 2c ff ff ff       	call   8013f0 <fd_lookup>
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 05                	js     8014d2 <fd_close+0x34>
	    || fd != fd2)
  8014cd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014d0:	74 16                	je     8014e8 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8014d2:	89 f8                	mov    %edi,%eax
  8014d4:	84 c0                	test   %al,%al
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014db:	0f 44 d8             	cmove  %eax,%ebx
}
  8014de:	89 d8                	mov    %ebx,%eax
  8014e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	ff 36                	pushl  (%esi)
  8014f1:	e8 4e ff ff ff       	call   801444 <dev_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 1a                	js     801519 <fd_close+0x7b>
		if (dev->dev_close)
  8014ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801502:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801505:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	74 0b                	je     801519 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	56                   	push   %esi
  801512:	ff d0                	call   *%eax
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	56                   	push   %esi
  80151d:	6a 00                	push   $0x0
  80151f:	e8 15 f8 ff ff       	call   800d39 <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	eb b5                	jmp    8014de <fd_close+0x40>

00801529 <close>:

int
close(int fdnum)
{
  801529:	f3 0f 1e fb          	endbr32 
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801533:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	ff 75 08             	pushl  0x8(%ebp)
  80153a:	e8 b1 fe ff ff       	call   8013f0 <fd_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	79 02                	jns    801548 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801546:	c9                   	leave  
  801547:	c3                   	ret    
		return fd_close(fd, 1);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	6a 01                	push   $0x1
  80154d:	ff 75 f4             	pushl  -0xc(%ebp)
  801550:	e8 49 ff ff ff       	call   80149e <fd_close>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb ec                	jmp    801546 <close+0x1d>

0080155a <close_all>:

void
close_all(void)
{
  80155a:	f3 0f 1e fb          	endbr32 
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	53                   	push   %ebx
  801562:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801565:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	53                   	push   %ebx
  80156e:	e8 b6 ff ff ff       	call   801529 <close>
	for (i = 0; i < MAXFD; i++)
  801573:	83 c3 01             	add    $0x1,%ebx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	83 fb 20             	cmp    $0x20,%ebx
  80157c:	75 ec                	jne    80156a <close_all+0x10>
}
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801583:	f3 0f 1e fb          	endbr32 
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801590:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	e8 54 fe ff ff       	call   8013f0 <fd_lookup>
  80159c:	89 c3                	mov    %eax,%ebx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	0f 88 81 00 00 00    	js     80162a <dup+0xa7>
		return r;
	close(newfdnum);
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	ff 75 0c             	pushl  0xc(%ebp)
  8015af:	e8 75 ff ff ff       	call   801529 <close>

	newfd = INDEX2FD(newfdnum);
  8015b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015b7:	c1 e6 0c             	shl    $0xc,%esi
  8015ba:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015c0:	83 c4 04             	add    $0x4,%esp
  8015c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015c6:	e8 b0 fd ff ff       	call   80137b <fd2data>
  8015cb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015cd:	89 34 24             	mov    %esi,(%esp)
  8015d0:	e8 a6 fd ff ff       	call   80137b <fd2data>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015da:	89 d8                	mov    %ebx,%eax
  8015dc:	c1 e8 16             	shr    $0x16,%eax
  8015df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015e6:	a8 01                	test   $0x1,%al
  8015e8:	74 11                	je     8015fb <dup+0x78>
  8015ea:	89 d8                	mov    %ebx,%eax
  8015ec:	c1 e8 0c             	shr    $0xc,%eax
  8015ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015f6:	f6 c2 01             	test   $0x1,%dl
  8015f9:	75 39                	jne    801634 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015fe:	89 d0                	mov    %edx,%eax
  801600:	c1 e8 0c             	shr    $0xc,%eax
  801603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	25 07 0e 00 00       	and    $0xe07,%eax
  801612:	50                   	push   %eax
  801613:	56                   	push   %esi
  801614:	6a 00                	push   $0x0
  801616:	52                   	push   %edx
  801617:	6a 00                	push   $0x0
  801619:	e8 f1 f6 ff ff       	call   800d0f <sys_page_map>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	83 c4 20             	add    $0x20,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 31                	js     801658 <dup+0xd5>
		goto err;

	return newfdnum;
  801627:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80162a:	89 d8                	mov    %ebx,%eax
  80162c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5f                   	pop    %edi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801634:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	25 07 0e 00 00       	and    $0xe07,%eax
  801643:	50                   	push   %eax
  801644:	57                   	push   %edi
  801645:	6a 00                	push   $0x0
  801647:	53                   	push   %ebx
  801648:	6a 00                	push   $0x0
  80164a:	e8 c0 f6 ff ff       	call   800d0f <sys_page_map>
  80164f:	89 c3                	mov    %eax,%ebx
  801651:	83 c4 20             	add    $0x20,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	79 a3                	jns    8015fb <dup+0x78>
	sys_page_unmap(0, newfd);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	56                   	push   %esi
  80165c:	6a 00                	push   $0x0
  80165e:	e8 d6 f6 ff ff       	call   800d39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801663:	83 c4 08             	add    $0x8,%esp
  801666:	57                   	push   %edi
  801667:	6a 00                	push   $0x0
  801669:	e8 cb f6 ff ff       	call   800d39 <sys_page_unmap>
	return r;
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb b7                	jmp    80162a <dup+0xa7>

00801673 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801673:	f3 0f 1e fb          	endbr32 
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 1c             	sub    $0x1c,%esp
  80167e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	53                   	push   %ebx
  801686:	e8 65 fd ff ff       	call   8013f0 <fd_lookup>
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 3f                	js     8016d1 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169c:	ff 30                	pushl  (%eax)
  80169e:	e8 a1 fd ff ff       	call   801444 <dev_lookup>
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 27                	js     8016d1 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ad:	8b 42 08             	mov    0x8(%edx),%eax
  8016b0:	83 e0 03             	and    $0x3,%eax
  8016b3:	83 f8 01             	cmp    $0x1,%eax
  8016b6:	74 1e                	je     8016d6 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	8b 40 08             	mov    0x8(%eax),%eax
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	74 35                	je     8016f7 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016c2:	83 ec 04             	sub    $0x4,%esp
  8016c5:	ff 75 10             	pushl  0x10(%ebp)
  8016c8:	ff 75 0c             	pushl  0xc(%ebp)
  8016cb:	52                   	push   %edx
  8016cc:	ff d0                	call   *%eax
  8016ce:	83 c4 10             	add    $0x10,%esp
}
  8016d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d6:	a1 04 50 80 00       	mov    0x805004,%eax
  8016db:	8b 40 48             	mov    0x48(%eax),%eax
  8016de:	83 ec 04             	sub    $0x4,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	50                   	push   %eax
  8016e3:	68 71 31 80 00       	push   $0x803171
  8016e8:	e8 08 ec ff ff       	call   8002f5 <cprintf>
		return -E_INVAL;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f5:	eb da                	jmp    8016d1 <read+0x5e>
		return -E_NOT_SUPP;
  8016f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016fc:	eb d3                	jmp    8016d1 <read+0x5e>

008016fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016fe:	f3 0f 1e fb          	endbr32 
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	57                   	push   %edi
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	83 ec 0c             	sub    $0xc,%esp
  80170b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801711:	bb 00 00 00 00       	mov    $0x0,%ebx
  801716:	eb 02                	jmp    80171a <readn+0x1c>
  801718:	01 c3                	add    %eax,%ebx
  80171a:	39 f3                	cmp    %esi,%ebx
  80171c:	73 21                	jae    80173f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80171e:	83 ec 04             	sub    $0x4,%esp
  801721:	89 f0                	mov    %esi,%eax
  801723:	29 d8                	sub    %ebx,%eax
  801725:	50                   	push   %eax
  801726:	89 d8                	mov    %ebx,%eax
  801728:	03 45 0c             	add    0xc(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	57                   	push   %edi
  80172d:	e8 41 ff ff ff       	call   801673 <read>
		if (m < 0)
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	78 04                	js     80173d <readn+0x3f>
			return m;
		if (m == 0)
  801739:	75 dd                	jne    801718 <readn+0x1a>
  80173b:	eb 02                	jmp    80173f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80173d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80173f:	89 d8                	mov    %ebx,%eax
  801741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801744:	5b                   	pop    %ebx
  801745:	5e                   	pop    %esi
  801746:	5f                   	pop    %edi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801749:	f3 0f 1e fb          	endbr32 
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 1c             	sub    $0x1c,%esp
  801754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	53                   	push   %ebx
  80175c:	e8 8f fc ff ff       	call   8013f0 <fd_lookup>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 3a                	js     8017a2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801772:	ff 30                	pushl  (%eax)
  801774:	e8 cb fc ff ff       	call   801444 <dev_lookup>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 22                	js     8017a2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801780:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801783:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801787:	74 1e                	je     8017a7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801789:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178c:	8b 52 0c             	mov    0xc(%edx),%edx
  80178f:	85 d2                	test   %edx,%edx
  801791:	74 35                	je     8017c8 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801793:	83 ec 04             	sub    $0x4,%esp
  801796:	ff 75 10             	pushl  0x10(%ebp)
  801799:	ff 75 0c             	pushl  0xc(%ebp)
  80179c:	50                   	push   %eax
  80179d:	ff d2                	call   *%edx
  80179f:	83 c4 10             	add    $0x10,%esp
}
  8017a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a7:	a1 04 50 80 00       	mov    0x805004,%eax
  8017ac:	8b 40 48             	mov    0x48(%eax),%eax
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	53                   	push   %ebx
  8017b3:	50                   	push   %eax
  8017b4:	68 8d 31 80 00       	push   $0x80318d
  8017b9:	e8 37 eb ff ff       	call   8002f5 <cprintf>
		return -E_INVAL;
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c6:	eb da                	jmp    8017a2 <write+0x59>
		return -E_NOT_SUPP;
  8017c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cd:	eb d3                	jmp    8017a2 <write+0x59>

008017cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8017cf:	f3 0f 1e fb          	endbr32 
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 0b fc ff ff       	call   8013f0 <fd_lookup>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 0e                	js     8017fa <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8017ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017fc:	f3 0f 1e fb          	endbr32 
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 1c             	sub    $0x1c,%esp
  801807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180d:	50                   	push   %eax
  80180e:	53                   	push   %ebx
  80180f:	e8 dc fb ff ff       	call   8013f0 <fd_lookup>
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	78 37                	js     801852 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801825:	ff 30                	pushl  (%eax)
  801827:	e8 18 fc ff ff       	call   801444 <dev_lookup>
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 1f                	js     801852 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801836:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183a:	74 1b                	je     801857 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80183c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183f:	8b 52 18             	mov    0x18(%edx),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	74 32                	je     801878 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	ff d2                	call   *%edx
  80184f:	83 c4 10             	add    $0x10,%esp
}
  801852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801855:	c9                   	leave  
  801856:	c3                   	ret    
			thisenv->env_id, fdnum);
  801857:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80185c:	8b 40 48             	mov    0x48(%eax),%eax
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	53                   	push   %ebx
  801863:	50                   	push   %eax
  801864:	68 50 31 80 00       	push   $0x803150
  801869:	e8 87 ea ff ff       	call   8002f5 <cprintf>
		return -E_INVAL;
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801876:	eb da                	jmp    801852 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801878:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80187d:	eb d3                	jmp    801852 <ftruncate+0x56>

0080187f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80187f:	f3 0f 1e fb          	endbr32 
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	53                   	push   %ebx
  801887:	83 ec 1c             	sub    $0x1c,%esp
  80188a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801890:	50                   	push   %eax
  801891:	ff 75 08             	pushl  0x8(%ebp)
  801894:	e8 57 fb ff ff       	call   8013f0 <fd_lookup>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 4b                	js     8018eb <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a6:	50                   	push   %eax
  8018a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018aa:	ff 30                	pushl  (%eax)
  8018ac:	e8 93 fb ff ff       	call   801444 <dev_lookup>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 33                	js     8018eb <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018bf:	74 2f                	je     8018f0 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018cb:	00 00 00 
	stat->st_isdir = 0;
  8018ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d5:	00 00 00 
	stat->st_dev = dev;
  8018d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	53                   	push   %ebx
  8018e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e5:	ff 50 14             	call   *0x14(%eax)
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    
		return -E_NOT_SUPP;
  8018f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018f5:	eb f4                	jmp    8018eb <fstat+0x6c>

008018f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f7:	f3 0f 1e fb          	endbr32 
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	56                   	push   %esi
  8018ff:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	6a 00                	push   $0x0
  801905:	ff 75 08             	pushl  0x8(%ebp)
  801908:	e8 fb 01 00 00       	call   801b08 <open>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	78 1b                	js     801931 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	50                   	push   %eax
  80191d:	e8 5d ff ff ff       	call   80187f <fstat>
  801922:	89 c6                	mov    %eax,%esi
	close(fd);
  801924:	89 1c 24             	mov    %ebx,(%esp)
  801927:	e8 fd fb ff ff       	call   801529 <close>
	return r;
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	89 f3                	mov    %esi,%ebx
}
  801931:	89 d8                	mov    %ebx,%eax
  801933:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	89 c6                	mov    %eax,%esi
  801941:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801943:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80194a:	74 27                	je     801973 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80194c:	6a 07                	push   $0x7
  80194e:	68 00 60 80 00       	push   $0x806000
  801953:	56                   	push   %esi
  801954:	ff 35 00 50 80 00    	pushl  0x805000
  80195a:	e8 9d 0e 00 00       	call   8027fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80195f:	83 c4 0c             	add    $0xc,%esp
  801962:	6a 00                	push   $0x0
  801964:	53                   	push   %ebx
  801965:	6a 00                	push   $0x0
  801967:	e8 22 0e 00 00       	call   80278e <ipc_recv>
}
  80196c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196f:	5b                   	pop    %ebx
  801970:	5e                   	pop    %esi
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	6a 01                	push   $0x1
  801978:	e8 e4 0e 00 00       	call   802861 <ipc_find_env>
  80197d:	a3 00 50 80 00       	mov    %eax,0x805000
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	eb c5                	jmp    80194c <fsipc+0x12>

00801987 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801987:	f3 0f 1e fb          	endbr32 
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801991:	8b 45 08             	mov    0x8(%ebp),%eax
  801994:	8b 40 0c             	mov    0xc(%eax),%eax
  801997:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199f:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ae:	e8 87 ff ff ff       	call   80193a <fsipc>
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <devfile_flush>:
{
  8019b5:	f3 0f 1e fb          	endbr32 
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c5:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d4:	e8 61 ff ff ff       	call   80193a <fsipc>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devfile_stat>:
{
  8019db:	f3 0f 1e fb          	endbr32 
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 04             	sub    $0x4,%esp
  8019e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ef:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019fe:	e8 37 ff ff ff       	call   80193a <fsipc>
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 2c                	js     801a33 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	68 00 60 80 00       	push   $0x806000
  801a0f:	53                   	push   %ebx
  801a10:	e8 4a ee ff ff       	call   80085f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a15:	a1 80 60 80 00       	mov    0x806080,%eax
  801a1a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a20:	a1 84 60 80 00       	mov    0x806084,%eax
  801a25:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <devfile_write>:
{
  801a38:	f3 0f 1e fb          	endbr32 
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a45:	8b 55 08             	mov    0x8(%ebp),%edx
  801a48:	8b 52 0c             	mov    0xc(%edx),%edx
  801a4b:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801a51:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a56:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a5b:	0f 47 c2             	cmova  %edx,%eax
  801a5e:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a63:	50                   	push   %eax
  801a64:	ff 75 0c             	pushl  0xc(%ebp)
  801a67:	68 08 60 80 00       	push   $0x806008
  801a6c:	e8 a6 ef ff ff       	call   800a17 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 04 00 00 00       	mov    $0x4,%eax
  801a7b:	e8 ba fe ff ff       	call   80193a <fsipc>
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devfile_read>:
{
  801a82:	f3 0f 1e fb          	endbr32 
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	8b 40 0c             	mov    0xc(%eax),%eax
  801a94:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a99:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  801aa9:	e8 8c fe ff ff       	call   80193a <fsipc>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 1f                	js     801ad3 <devfile_read+0x51>
	assert(r <= n);
  801ab4:	39 f0                	cmp    %esi,%eax
  801ab6:	77 24                	ja     801adc <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801ab8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801abd:	7f 33                	jg     801af2 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801abf:	83 ec 04             	sub    $0x4,%esp
  801ac2:	50                   	push   %eax
  801ac3:	68 00 60 80 00       	push   $0x806000
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	e8 47 ef ff ff       	call   800a17 <memmove>
	return r;
  801ad0:	83 c4 10             	add    $0x10,%esp
}
  801ad3:	89 d8                	mov    %ebx,%eax
  801ad5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    
	assert(r <= n);
  801adc:	68 bc 31 80 00       	push   $0x8031bc
  801ae1:	68 c3 31 80 00       	push   $0x8031c3
  801ae6:	6a 7c                	push   $0x7c
  801ae8:	68 d8 31 80 00       	push   $0x8031d8
  801aed:	e8 1c e7 ff ff       	call   80020e <_panic>
	assert(r <= PGSIZE);
  801af2:	68 e3 31 80 00       	push   $0x8031e3
  801af7:	68 c3 31 80 00       	push   $0x8031c3
  801afc:	6a 7d                	push   $0x7d
  801afe:	68 d8 31 80 00       	push   $0x8031d8
  801b03:	e8 06 e7 ff ff       	call   80020e <_panic>

00801b08 <open>:
{
  801b08:	f3 0f 1e fb          	endbr32 
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 1c             	sub    $0x1c,%esp
  801b14:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b17:	56                   	push   %esi
  801b18:	e8 ff ec ff ff       	call   80081c <strlen>
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b25:	7f 6c                	jg     801b93 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2d:	50                   	push   %eax
  801b2e:	e8 67 f8 ff ff       	call   80139a <fd_alloc>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 3c                	js     801b78 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b3c:	83 ec 08             	sub    $0x8,%esp
  801b3f:	56                   	push   %esi
  801b40:	68 00 60 80 00       	push   $0x806000
  801b45:	e8 15 ed ff ff       	call   80085f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4d:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b55:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5a:	e8 db fd ff ff       	call   80193a <fsipc>
  801b5f:	89 c3                	mov    %eax,%ebx
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 19                	js     801b81 <open+0x79>
	return fd2num(fd);
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6e:	e8 f4 f7 ff ff       	call   801367 <fd2num>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	83 c4 10             	add    $0x10,%esp
}
  801b78:	89 d8                	mov    %ebx,%eax
  801b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    
		fd_close(fd, 0);
  801b81:	83 ec 08             	sub    $0x8,%esp
  801b84:	6a 00                	push   $0x0
  801b86:	ff 75 f4             	pushl  -0xc(%ebp)
  801b89:	e8 10 f9 ff ff       	call   80149e <fd_close>
		return r;
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	eb e5                	jmp    801b78 <open+0x70>
		return -E_BAD_PATH;
  801b93:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b98:	eb de                	jmp    801b78 <open+0x70>

00801b9a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9a:	f3 0f 1e fb          	endbr32 
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bae:	e8 87 fd ff ff       	call   80193a <fsipc>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801bbc:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801bc1:	eb 33                	jmp    801bf6 <copy_shared_pages+0x41>
		if(addr != UXSTACKTOP - PGSIZE){
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
				sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801bc3:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	25 07 0e 00 00       	and    $0xe07,%eax
  801bd2:	50                   	push   %eax
  801bd3:	53                   	push   %ebx
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 32 f1 ff ff       	call   800d0f <sys_page_map>
  801bdd:	83 c4 20             	add    $0x20,%esp
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801be0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801be6:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801bec:	77 2f                	ja     801c1d <copy_shared_pages+0x68>
		if(addr != UXSTACKTOP - PGSIZE){
  801bee:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801bf4:	74 ea                	je     801be0 <copy_shared_pages+0x2b>
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
  801bf6:	89 d8                	mov    %ebx,%eax
  801bf8:	c1 e8 16             	shr    $0x16,%eax
  801bfb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c02:	a8 01                	test   $0x1,%al
  801c04:	74 da                	je     801be0 <copy_shared_pages+0x2b>
  801c06:	89 da                	mov    %ebx,%edx
  801c08:	c1 ea 0c             	shr    $0xc,%edx
  801c0b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c12:	f7 d0                	not    %eax
  801c14:	a9 05 04 00 00       	test   $0x405,%eax
  801c19:	75 c5                	jne    801be0 <copy_shared_pages+0x2b>
  801c1b:	eb a6                	jmp    801bc3 <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <init_stack>:
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	57                   	push   %edi
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 2c             	sub    $0x2c,%esp
  801c32:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801c35:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801c38:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  801c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801c40:	be 00 00 00 00       	mov    $0x0,%esi
  801c45:	89 d7                	mov    %edx,%edi
  801c47:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801c4e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801c51:	85 c0                	test   %eax,%eax
  801c53:	74 15                	je     801c6a <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	50                   	push   %eax
  801c59:	e8 be eb ff ff       	call   80081c <strlen>
  801c5e:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801c62:	83 c3 01             	add    $0x1,%ebx
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	eb dd                	jmp    801c47 <init_stack+0x1e>
  801c6a:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801c6d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  801c70:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c75:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c77:	89 fa                	mov    %edi,%edx
  801c79:	83 e2 fc             	and    $0xfffffffc,%edx
  801c7c:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801c83:	29 c2                	sub    %eax,%edx
  801c85:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801c88:	8d 42 f8             	lea    -0x8(%edx),%eax
  801c8b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c90:	0f 86 06 01 00 00    	jbe    801d9c <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801c96:	83 ec 04             	sub    $0x4,%esp
  801c99:	6a 07                	push   $0x7
  801c9b:	68 00 00 40 00       	push   $0x400000
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 40 f0 ff ff       	call   800ce7 <sys_page_alloc>
  801ca7:	89 c6                	mov    %eax,%esi
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	0f 88 de 00 00 00    	js     801d92 <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  801cb4:	be 00 00 00 00       	mov    $0x0,%esi
  801cb9:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801cbc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801cbf:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  801cc2:	7e 2f                	jle    801cf3 <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  801cc4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801cca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801ccd:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801cd6:	57                   	push   %edi
  801cd7:	e8 83 eb ff ff       	call   80085f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801cdc:	83 c4 04             	add    $0x4,%esp
  801cdf:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ce2:	e8 35 eb ff ff       	call   80081c <strlen>
  801ce7:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801ceb:	83 c6 01             	add    $0x1,%esi
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	eb cc                	jmp    801cbf <init_stack+0x96>
	argv_store[argc] = 0;
  801cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  801cf9:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  801d00:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d06:	75 5f                	jne    801d67 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d08:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d0b:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  801d11:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801d14:	89 d0                	mov    %edx,%eax
  801d16:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801d19:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d1c:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801d21:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d24:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  801d26:	83 ec 0c             	sub    $0xc,%esp
  801d29:	6a 07                	push   $0x7
  801d2b:	68 00 d0 bf ee       	push   $0xeebfd000
  801d30:	ff 75 d4             	pushl  -0x2c(%ebp)
  801d33:	68 00 00 40 00       	push   $0x400000
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 d0 ef ff ff       	call   800d0f <sys_page_map>
  801d3f:	89 c6                	mov    %eax,%esi
  801d41:	83 c4 20             	add    $0x20,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 38                	js     801d80 <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d48:	83 ec 08             	sub    $0x8,%esp
  801d4b:	68 00 00 40 00       	push   $0x400000
  801d50:	6a 00                	push   $0x0
  801d52:	e8 e2 ef ff ff       	call   800d39 <sys_page_unmap>
  801d57:	89 c6                	mov    %eax,%esi
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 20                	js     801d80 <init_stack+0x157>
	return 0;
  801d60:	be 00 00 00 00       	mov    $0x0,%esi
  801d65:	eb 2b                	jmp    801d92 <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  801d67:	68 f0 31 80 00       	push   $0x8031f0
  801d6c:	68 c3 31 80 00       	push   $0x8031c3
  801d71:	68 fc 00 00 00       	push   $0xfc
  801d76:	68 18 32 80 00       	push   $0x803218
  801d7b:	e8 8e e4 ff ff       	call   80020e <_panic>
	sys_page_unmap(0, UTEMP);
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	68 00 00 40 00       	push   $0x400000
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 aa ef ff ff       	call   800d39 <sys_page_unmap>
	return r;
  801d8f:	83 c4 10             	add    $0x10,%esp
}
  801d92:	89 f0                	mov    %esi,%eax
  801d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
		return -E_NO_MEM;
  801d9c:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801da1:	eb ef                	jmp    801d92 <init_stack+0x169>

00801da3 <map_segment>:
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 1c             	sub    $0x1c,%esp
  801dac:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801daf:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801db2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801db5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  801db8:	89 d0                	mov    %edx,%eax
  801dba:	25 ff 0f 00 00       	and    $0xfff,%eax
  801dbf:	74 0f                	je     801dd0 <map_segment+0x2d>
		va -= i;
  801dc1:	29 c2                	sub    %eax,%edx
  801dc3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  801dc6:	01 c1                	add    %eax,%ecx
  801dc8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  801dcb:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801dcd:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dd5:	e9 99 00 00 00       	jmp    801e73 <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801dda:	83 ec 04             	sub    $0x4,%esp
  801ddd:	6a 07                	push   $0x7
  801ddf:	68 00 00 40 00       	push   $0x400000
  801de4:	6a 00                	push   $0x0
  801de6:	e8 fc ee ff ff       	call   800ce7 <sys_page_alloc>
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	85 c0                	test   %eax,%eax
  801df0:	0f 88 c1 00 00 00    	js     801eb7 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801df6:	83 ec 08             	sub    $0x8,%esp
  801df9:	89 f0                	mov    %esi,%eax
  801dfb:	03 45 10             	add    0x10(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	ff 75 08             	pushl  0x8(%ebp)
  801e02:	e8 c8 f9 ff ff       	call   8017cf <seek>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	0f 88 a5 00 00 00    	js     801eb7 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  801e12:	83 ec 04             	sub    $0x4,%esp
  801e15:	89 f8                	mov    %edi,%eax
  801e17:	29 f0                	sub    %esi,%eax
  801e19:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e1e:	ba 00 10 00 00       	mov    $0x1000,%edx
  801e23:	0f 47 c2             	cmova  %edx,%eax
  801e26:	50                   	push   %eax
  801e27:	68 00 00 40 00       	push   $0x400000
  801e2c:	ff 75 08             	pushl  0x8(%ebp)
  801e2f:	e8 ca f8 ff ff       	call   8016fe <readn>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 7c                	js     801eb7 <map_segment+0x114>
			if ((r = sys_page_map(
  801e3b:	83 ec 0c             	sub    $0xc,%esp
  801e3e:	ff 75 14             	pushl  0x14(%ebp)
  801e41:	03 75 e0             	add    -0x20(%ebp),%esi
  801e44:	56                   	push   %esi
  801e45:	ff 75 dc             	pushl  -0x24(%ebp)
  801e48:	68 00 00 40 00       	push   $0x400000
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 bb ee ff ff       	call   800d0f <sys_page_map>
  801e54:	83 c4 20             	add    $0x20,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 42                	js     801e9d <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	68 00 00 40 00       	push   $0x400000
  801e63:	6a 00                	push   $0x0
  801e65:	e8 cf ee ff ff       	call   800d39 <sys_page_unmap>
  801e6a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801e6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e73:	89 de                	mov    %ebx,%esi
  801e75:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  801e78:	76 38                	jbe    801eb2 <map_segment+0x10f>
		if (i >= filesz) {
  801e7a:	39 df                	cmp    %ebx,%edi
  801e7c:	0f 87 58 ff ff ff    	ja     801dda <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	ff 75 14             	pushl  0x14(%ebp)
  801e88:	03 75 e0             	add    -0x20(%ebp),%esi
  801e8b:	56                   	push   %esi
  801e8c:	ff 75 dc             	pushl  -0x24(%ebp)
  801e8f:	e8 53 ee ff ff       	call   800ce7 <sys_page_alloc>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	79 d2                	jns    801e6d <map_segment+0xca>
  801e9b:	eb 1a                	jmp    801eb7 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  801e9d:	50                   	push   %eax
  801e9e:	68 24 32 80 00       	push   $0x803224
  801ea3:	68 3a 01 00 00       	push   $0x13a
  801ea8:	68 18 32 80 00       	push   $0x803218
  801ead:	e8 5c e3 ff ff       	call   80020e <_panic>
	return 0;
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5f                   	pop    %edi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <spawn>:
{
  801ebf:	f3 0f 1e fb          	endbr32 
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	57                   	push   %edi
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  801ecf:	6a 00                	push   $0x0
  801ed1:	ff 75 08             	pushl  0x8(%ebp)
  801ed4:	e8 2f fc ff ff       	call   801b08 <open>
  801ed9:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	0f 88 0b 02 00 00    	js     8020f5 <spawn+0x236>
  801eea:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  801eec:	83 ec 04             	sub    $0x4,%esp
  801eef:	68 00 02 00 00       	push   $0x200
  801ef4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801efa:	50                   	push   %eax
  801efb:	57                   	push   %edi
  801efc:	e8 fd f7 ff ff       	call   8016fe <readn>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f09:	0f 85 85 00 00 00    	jne    801f94 <spawn+0xd5>
  801f0f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f16:	45 4c 46 
  801f19:	75 79                	jne    801f94 <spawn+0xd5>
  801f1b:	b8 07 00 00 00       	mov    $0x7,%eax
  801f20:	cd 30                	int    $0x30
  801f22:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801f28:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	85 c0                	test   %eax,%eax
  801f32:	0f 88 b1 01 00 00    	js     8020e9 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  801f38:	89 c6                	mov    %eax,%esi
  801f3a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801f40:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801f43:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801f49:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801f4f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801f54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f56:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801f5c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801f62:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801f68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6b:	89 d8                	mov    %ebx,%eax
  801f6d:	e8 b7 fc ff ff       	call   801c29 <init_stack>
  801f72:	85 c0                	test   %eax,%eax
  801f74:	0f 88 89 01 00 00    	js     802103 <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  801f7a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801f80:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f87:	be 00 00 00 00       	mov    $0x0,%esi
  801f8c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801f92:	eb 3e                	jmp    801fd2 <spawn+0x113>
		close(fd);
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801f9d:	e8 87 f5 ff ff       	call   801529 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801fa2:	83 c4 0c             	add    $0xc,%esp
  801fa5:	68 7f 45 4c 46       	push   $0x464c457f
  801faa:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801fb0:	68 41 32 80 00       	push   $0x803241
  801fb5:	e8 3b e3 ff ff       	call   8002f5 <cprintf>
		return -E_NOT_EXEC;
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801fc4:	ff ff ff 
  801fc7:	e9 29 01 00 00       	jmp    8020f5 <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fcc:	83 c6 01             	add    $0x1,%esi
  801fcf:	83 c3 20             	add    $0x20,%ebx
  801fd2:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fd9:	39 f0                	cmp    %esi,%eax
  801fdb:	7e 62                	jle    80203f <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  801fdd:	83 3b 01             	cmpl   $0x1,(%ebx)
  801fe0:	75 ea                	jne    801fcc <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801fe2:	8b 43 18             	mov    0x18(%ebx),%eax
  801fe5:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801fe8:	83 f8 01             	cmp    $0x1,%eax
  801feb:	19 c0                	sbb    %eax,%eax
  801fed:	83 e0 fe             	and    $0xfffffffe,%eax
  801ff0:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  801ff3:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801ff6:	8b 53 08             	mov    0x8(%ebx),%edx
  801ff9:	50                   	push   %eax
  801ffa:	ff 73 04             	pushl  0x4(%ebx)
  801ffd:	ff 73 10             	pushl  0x10(%ebx)
  802000:	57                   	push   %edi
  802001:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802007:	e8 97 fd ff ff       	call   801da3 <map_segment>
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	79 b9                	jns    801fcc <spawn+0x10d>
  802013:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80201e:	e8 4b ec ff ff       	call   800c6e <sys_env_destroy>
	close(fd);
  802023:	83 c4 04             	add    $0x4,%esp
  802026:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80202c:	e8 f8 f4 ff ff       	call   801529 <close>
	return r;
  802031:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  802034:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  80203a:	e9 b6 00 00 00       	jmp    8020f5 <spawn+0x236>
	close(fd);
  80203f:	83 ec 0c             	sub    $0xc,%esp
  802042:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802048:	e8 dc f4 ff ff       	call   801529 <close>
	if ((r = copy_shared_pages(child)) < 0)
  80204d:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802053:	e8 5d fb ff ff       	call   801bb5 <copy_shared_pages>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 4b                	js     8020aa <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  80205f:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802066:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802069:	83 ec 08             	sub    $0x8,%esp
  80206c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802079:	e8 09 ed ff ff       	call   800d87 <sys_env_set_trapframe>
  80207e:	83 c4 10             	add    $0x10,%esp
  802081:	85 c0                	test   %eax,%eax
  802083:	78 3a                	js     8020bf <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802085:	83 ec 08             	sub    $0x8,%esp
  802088:	6a 02                	push   $0x2
  80208a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802090:	e8 cb ec ff ff       	call   800d60 <sys_env_set_status>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 38                	js     8020d4 <spawn+0x215>
	return child;
  80209c:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8020a2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8020a8:	eb 4b                	jmp    8020f5 <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  8020aa:	50                   	push   %eax
  8020ab:	68 5b 32 80 00       	push   $0x80325b
  8020b0:	68 8c 00 00 00       	push   $0x8c
  8020b5:	68 18 32 80 00       	push   $0x803218
  8020ba:	e8 4f e1 ff ff       	call   80020e <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8020bf:	50                   	push   %eax
  8020c0:	68 71 32 80 00       	push   $0x803271
  8020c5:	68 90 00 00 00       	push   $0x90
  8020ca:	68 18 32 80 00       	push   $0x803218
  8020cf:	e8 3a e1 ff ff       	call   80020e <_panic>
		panic("sys_env_set_status: %e", r);
  8020d4:	50                   	push   %eax
  8020d5:	68 8b 32 80 00       	push   $0x80328b
  8020da:	68 93 00 00 00       	push   $0x93
  8020df:	68 18 32 80 00       	push   $0x803218
  8020e4:	e8 25 e1 ff ff       	call   80020e <_panic>
		return r;
  8020e9:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8020ef:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  8020f5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8020fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fe:	5b                   	pop    %ebx
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
		return r;
  802103:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802109:	eb ea                	jmp    8020f5 <spawn+0x236>

0080210b <spawnl>:
{
  80210b:	f3 0f 1e fb          	endbr32 
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	57                   	push   %edi
  802113:	56                   	push   %esi
  802114:	53                   	push   %ebx
  802115:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802118:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  80211b:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  802120:	8d 4a 04             	lea    0x4(%edx),%ecx
  802123:	83 3a 00             	cmpl   $0x0,(%edx)
  802126:	74 07                	je     80212f <spawnl+0x24>
		argc++;
  802128:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  80212b:	89 ca                	mov    %ecx,%edx
  80212d:	eb f1                	jmp    802120 <spawnl+0x15>
	const char *argv[argc + 2];
  80212f:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802136:	89 d1                	mov    %edx,%ecx
  802138:	83 e1 f0             	and    $0xfffffff0,%ecx
  80213b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802141:	89 e6                	mov    %esp,%esi
  802143:	29 d6                	sub    %edx,%esi
  802145:	89 f2                	mov    %esi,%edx
  802147:	39 d4                	cmp    %edx,%esp
  802149:	74 10                	je     80215b <spawnl+0x50>
  80214b:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802151:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802158:	00 
  802159:	eb ec                	jmp    802147 <spawnl+0x3c>
  80215b:	89 ca                	mov    %ecx,%edx
  80215d:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802163:	29 d4                	sub    %edx,%esp
  802165:	85 d2                	test   %edx,%edx
  802167:	74 05                	je     80216e <spawnl+0x63>
  802169:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  80216e:	8d 74 24 03          	lea    0x3(%esp),%esi
  802172:	89 f2                	mov    %esi,%edx
  802174:	c1 ea 02             	shr    $0x2,%edx
  802177:	83 e6 fc             	and    $0xfffffffc,%esi
  80217a:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80217c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80217f:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  802186:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80218d:	00 
	va_start(vl, arg0);
  80218e:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802191:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
  802198:	eb 0b                	jmp    8021a5 <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  80219a:	83 c0 01             	add    $0x1,%eax
  80219d:	8b 39                	mov    (%ecx),%edi
  80219f:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  8021a2:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  8021a5:	39 d0                	cmp    %edx,%eax
  8021a7:	75 f1                	jne    80219a <spawnl+0x8f>
	return spawn(prog, argv);
  8021a9:	83 ec 08             	sub    $0x8,%esp
  8021ac:	56                   	push   %esi
  8021ad:	ff 75 08             	pushl  0x8(%ebp)
  8021b0:	e8 0a fd ff ff       	call   801ebf <spawn>
}
  8021b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b8:	5b                   	pop    %ebx
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    

008021bd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021bd:	f3 0f 1e fb          	endbr32 
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	56                   	push   %esi
  8021c5:	53                   	push   %ebx
  8021c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021c9:	83 ec 0c             	sub    $0xc,%esp
  8021cc:	ff 75 08             	pushl  0x8(%ebp)
  8021cf:	e8 a7 f1 ff ff       	call   80137b <fd2data>
  8021d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021d6:	83 c4 08             	add    $0x8,%esp
  8021d9:	68 a2 32 80 00       	push   $0x8032a2
  8021de:	53                   	push   %ebx
  8021df:	e8 7b e6 ff ff       	call   80085f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021e4:	8b 46 04             	mov    0x4(%esi),%eax
  8021e7:	2b 06                	sub    (%esi),%eax
  8021e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021f6:	00 00 00 
	stat->st_dev = &devpipe;
  8021f9:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  802200:	40 80 00 
	return 0;
}
  802203:	b8 00 00 00 00       	mov    $0x0,%eax
  802208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220b:	5b                   	pop    %ebx
  80220c:	5e                   	pop    %esi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80220f:	f3 0f 1e fb          	endbr32 
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	53                   	push   %ebx
  802217:	83 ec 0c             	sub    $0xc,%esp
  80221a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80221d:	53                   	push   %ebx
  80221e:	6a 00                	push   $0x0
  802220:	e8 14 eb ff ff       	call   800d39 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802225:	89 1c 24             	mov    %ebx,(%esp)
  802228:	e8 4e f1 ff ff       	call   80137b <fd2data>
  80222d:	83 c4 08             	add    $0x8,%esp
  802230:	50                   	push   %eax
  802231:	6a 00                	push   $0x0
  802233:	e8 01 eb ff ff       	call   800d39 <sys_page_unmap>
}
  802238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80223b:	c9                   	leave  
  80223c:	c3                   	ret    

0080223d <_pipeisclosed>:
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	57                   	push   %edi
  802241:	56                   	push   %esi
  802242:	53                   	push   %ebx
  802243:	83 ec 1c             	sub    $0x1c,%esp
  802246:	89 c7                	mov    %eax,%edi
  802248:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80224a:	a1 04 50 80 00       	mov    0x805004,%eax
  80224f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802252:	83 ec 0c             	sub    $0xc,%esp
  802255:	57                   	push   %edi
  802256:	e8 43 06 00 00       	call   80289e <pageref>
  80225b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80225e:	89 34 24             	mov    %esi,(%esp)
  802261:	e8 38 06 00 00       	call   80289e <pageref>
		nn = thisenv->env_runs;
  802266:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80226c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	39 cb                	cmp    %ecx,%ebx
  802274:	74 1b                	je     802291 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802276:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802279:	75 cf                	jne    80224a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80227b:	8b 42 58             	mov    0x58(%edx),%eax
  80227e:	6a 01                	push   $0x1
  802280:	50                   	push   %eax
  802281:	53                   	push   %ebx
  802282:	68 a9 32 80 00       	push   $0x8032a9
  802287:	e8 69 e0 ff ff       	call   8002f5 <cprintf>
  80228c:	83 c4 10             	add    $0x10,%esp
  80228f:	eb b9                	jmp    80224a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802291:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802294:	0f 94 c0             	sete   %al
  802297:	0f b6 c0             	movzbl %al,%eax
}
  80229a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    

008022a2 <devpipe_write>:
{
  8022a2:	f3 0f 1e fb          	endbr32 
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	57                   	push   %edi
  8022aa:	56                   	push   %esi
  8022ab:	53                   	push   %ebx
  8022ac:	83 ec 28             	sub    $0x28,%esp
  8022af:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8022b2:	56                   	push   %esi
  8022b3:	e8 c3 f0 ff ff       	call   80137b <fd2data>
  8022b8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	bf 00 00 00 00       	mov    $0x0,%edi
  8022c2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022c5:	74 4f                	je     802316 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8022ca:	8b 0b                	mov    (%ebx),%ecx
  8022cc:	8d 51 20             	lea    0x20(%ecx),%edx
  8022cf:	39 d0                	cmp    %edx,%eax
  8022d1:	72 14                	jb     8022e7 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8022d3:	89 da                	mov    %ebx,%edx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	e8 61 ff ff ff       	call   80223d <_pipeisclosed>
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	75 3b                	jne    80231b <devpipe_write+0x79>
			sys_yield();
  8022e0:	e8 d7 e9 ff ff       	call   800cbc <sys_yield>
  8022e5:	eb e0                	jmp    8022c7 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022ea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022ee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	c1 fa 1f             	sar    $0x1f,%edx
  8022f6:	89 d1                	mov    %edx,%ecx
  8022f8:	c1 e9 1b             	shr    $0x1b,%ecx
  8022fb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022fe:	83 e2 1f             	and    $0x1f,%edx
  802301:	29 ca                	sub    %ecx,%edx
  802303:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802307:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80230b:	83 c0 01             	add    $0x1,%eax
  80230e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802311:	83 c7 01             	add    $0x1,%edi
  802314:	eb ac                	jmp    8022c2 <devpipe_write+0x20>
	return i;
  802316:	8b 45 10             	mov    0x10(%ebp),%eax
  802319:	eb 05                	jmp    802320 <devpipe_write+0x7e>
				return 0;
  80231b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    

00802328 <devpipe_read>:
{
  802328:	f3 0f 1e fb          	endbr32 
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	57                   	push   %edi
  802330:	56                   	push   %esi
  802331:	53                   	push   %ebx
  802332:	83 ec 18             	sub    $0x18,%esp
  802335:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802338:	57                   	push   %edi
  802339:	e8 3d f0 ff ff       	call   80137b <fd2data>
  80233e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	be 00 00 00 00       	mov    $0x0,%esi
  802348:	3b 75 10             	cmp    0x10(%ebp),%esi
  80234b:	75 14                	jne    802361 <devpipe_read+0x39>
	return i;
  80234d:	8b 45 10             	mov    0x10(%ebp),%eax
  802350:	eb 02                	jmp    802354 <devpipe_read+0x2c>
				return i;
  802352:	89 f0                	mov    %esi,%eax
}
  802354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
			sys_yield();
  80235c:	e8 5b e9 ff ff       	call   800cbc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802361:	8b 03                	mov    (%ebx),%eax
  802363:	3b 43 04             	cmp    0x4(%ebx),%eax
  802366:	75 18                	jne    802380 <devpipe_read+0x58>
			if (i > 0)
  802368:	85 f6                	test   %esi,%esi
  80236a:	75 e6                	jne    802352 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80236c:	89 da                	mov    %ebx,%edx
  80236e:	89 f8                	mov    %edi,%eax
  802370:	e8 c8 fe ff ff       	call   80223d <_pipeisclosed>
  802375:	85 c0                	test   %eax,%eax
  802377:	74 e3                	je     80235c <devpipe_read+0x34>
				return 0;
  802379:	b8 00 00 00 00       	mov    $0x0,%eax
  80237e:	eb d4                	jmp    802354 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802380:	99                   	cltd   
  802381:	c1 ea 1b             	shr    $0x1b,%edx
  802384:	01 d0                	add    %edx,%eax
  802386:	83 e0 1f             	and    $0x1f,%eax
  802389:	29 d0                	sub    %edx,%eax
  80238b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802390:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802393:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802396:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802399:	83 c6 01             	add    $0x1,%esi
  80239c:	eb aa                	jmp    802348 <devpipe_read+0x20>

0080239e <pipe>:
{
  80239e:	f3 0f 1e fb          	endbr32 
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	56                   	push   %esi
  8023a6:	53                   	push   %ebx
  8023a7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8023aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ad:	50                   	push   %eax
  8023ae:	e8 e7 ef ff ff       	call   80139a <fd_alloc>
  8023b3:	89 c3                	mov    %eax,%ebx
  8023b5:	83 c4 10             	add    $0x10,%esp
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	0f 88 23 01 00 00    	js     8024e3 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c0:	83 ec 04             	sub    $0x4,%esp
  8023c3:	68 07 04 00 00       	push   $0x407
  8023c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8023cb:	6a 00                	push   $0x0
  8023cd:	e8 15 e9 ff ff       	call   800ce7 <sys_page_alloc>
  8023d2:	89 c3                	mov    %eax,%ebx
  8023d4:	83 c4 10             	add    $0x10,%esp
  8023d7:	85 c0                	test   %eax,%eax
  8023d9:	0f 88 04 01 00 00    	js     8024e3 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8023df:	83 ec 0c             	sub    $0xc,%esp
  8023e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023e5:	50                   	push   %eax
  8023e6:	e8 af ef ff ff       	call   80139a <fd_alloc>
  8023eb:	89 c3                	mov    %eax,%ebx
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	0f 88 db 00 00 00    	js     8024d3 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023f8:	83 ec 04             	sub    $0x4,%esp
  8023fb:	68 07 04 00 00       	push   $0x407
  802400:	ff 75 f0             	pushl  -0x10(%ebp)
  802403:	6a 00                	push   $0x0
  802405:	e8 dd e8 ff ff       	call   800ce7 <sys_page_alloc>
  80240a:	89 c3                	mov    %eax,%ebx
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	85 c0                	test   %eax,%eax
  802411:	0f 88 bc 00 00 00    	js     8024d3 <pipe+0x135>
	va = fd2data(fd0);
  802417:	83 ec 0c             	sub    $0xc,%esp
  80241a:	ff 75 f4             	pushl  -0xc(%ebp)
  80241d:	e8 59 ef ff ff       	call   80137b <fd2data>
  802422:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802424:	83 c4 0c             	add    $0xc,%esp
  802427:	68 07 04 00 00       	push   $0x407
  80242c:	50                   	push   %eax
  80242d:	6a 00                	push   $0x0
  80242f:	e8 b3 e8 ff ff       	call   800ce7 <sys_page_alloc>
  802434:	89 c3                	mov    %eax,%ebx
  802436:	83 c4 10             	add    $0x10,%esp
  802439:	85 c0                	test   %eax,%eax
  80243b:	0f 88 82 00 00 00    	js     8024c3 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802441:	83 ec 0c             	sub    $0xc,%esp
  802444:	ff 75 f0             	pushl  -0x10(%ebp)
  802447:	e8 2f ef ff ff       	call   80137b <fd2data>
  80244c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802453:	50                   	push   %eax
  802454:	6a 00                	push   $0x0
  802456:	56                   	push   %esi
  802457:	6a 00                	push   $0x0
  802459:	e8 b1 e8 ff ff       	call   800d0f <sys_page_map>
  80245e:	89 c3                	mov    %eax,%ebx
  802460:	83 c4 20             	add    $0x20,%esp
  802463:	85 c0                	test   %eax,%eax
  802465:	78 4e                	js     8024b5 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802467:	a1 28 40 80 00       	mov    0x804028,%eax
  80246c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80246f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802471:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802474:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80247b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80247e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802480:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802483:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80248a:	83 ec 0c             	sub    $0xc,%esp
  80248d:	ff 75 f4             	pushl  -0xc(%ebp)
  802490:	e8 d2 ee ff ff       	call   801367 <fd2num>
  802495:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802498:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80249a:	83 c4 04             	add    $0x4,%esp
  80249d:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a0:	e8 c2 ee ff ff       	call   801367 <fd2num>
  8024a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024a8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024ab:	83 c4 10             	add    $0x10,%esp
  8024ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b3:	eb 2e                	jmp    8024e3 <pipe+0x145>
	sys_page_unmap(0, va);
  8024b5:	83 ec 08             	sub    $0x8,%esp
  8024b8:	56                   	push   %esi
  8024b9:	6a 00                	push   $0x0
  8024bb:	e8 79 e8 ff ff       	call   800d39 <sys_page_unmap>
  8024c0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8024c3:	83 ec 08             	sub    $0x8,%esp
  8024c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8024c9:	6a 00                	push   $0x0
  8024cb:	e8 69 e8 ff ff       	call   800d39 <sys_page_unmap>
  8024d0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8024d3:	83 ec 08             	sub    $0x8,%esp
  8024d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d9:	6a 00                	push   $0x0
  8024db:	e8 59 e8 ff ff       	call   800d39 <sys_page_unmap>
  8024e0:	83 c4 10             	add    $0x10,%esp
}
  8024e3:	89 d8                	mov    %ebx,%eax
  8024e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5d                   	pop    %ebp
  8024eb:	c3                   	ret    

008024ec <pipeisclosed>:
{
  8024ec:	f3 0f 1e fb          	endbr32 
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f9:	50                   	push   %eax
  8024fa:	ff 75 08             	pushl  0x8(%ebp)
  8024fd:	e8 ee ee ff ff       	call   8013f0 <fd_lookup>
  802502:	83 c4 10             	add    $0x10,%esp
  802505:	85 c0                	test   %eax,%eax
  802507:	78 18                	js     802521 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802509:	83 ec 0c             	sub    $0xc,%esp
  80250c:	ff 75 f4             	pushl  -0xc(%ebp)
  80250f:	e8 67 ee ff ff       	call   80137b <fd2data>
  802514:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802519:	e8 1f fd ff ff       	call   80223d <_pipeisclosed>
  80251e:	83 c4 10             	add    $0x10,%esp
}
  802521:	c9                   	leave  
  802522:	c3                   	ret    

00802523 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802523:	f3 0f 1e fb          	endbr32 
  802527:	55                   	push   %ebp
  802528:	89 e5                	mov    %esp,%ebp
  80252a:	56                   	push   %esi
  80252b:	53                   	push   %ebx
  80252c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80252f:	85 f6                	test   %esi,%esi
  802531:	74 13                	je     802546 <wait+0x23>
	e = &envs[ENVX(envid)];
  802533:	89 f3                	mov    %esi,%ebx
  802535:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80253b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80253e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802544:	eb 1b                	jmp    802561 <wait+0x3e>
	assert(envid != 0);
  802546:	68 c1 32 80 00       	push   $0x8032c1
  80254b:	68 c3 31 80 00       	push   $0x8031c3
  802550:	6a 09                	push   $0x9
  802552:	68 cc 32 80 00       	push   $0x8032cc
  802557:	e8 b2 dc ff ff       	call   80020e <_panic>
		sys_yield();
  80255c:	e8 5b e7 ff ff       	call   800cbc <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802561:	8b 43 48             	mov    0x48(%ebx),%eax
  802564:	39 f0                	cmp    %esi,%eax
  802566:	75 07                	jne    80256f <wait+0x4c>
  802568:	8b 43 54             	mov    0x54(%ebx),%eax
  80256b:	85 c0                	test   %eax,%eax
  80256d:	75 ed                	jne    80255c <wait+0x39>
}
  80256f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802572:	5b                   	pop    %ebx
  802573:	5e                   	pop    %esi
  802574:	5d                   	pop    %ebp
  802575:	c3                   	ret    

00802576 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802576:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80257a:	b8 00 00 00 00       	mov    $0x0,%eax
  80257f:	c3                   	ret    

00802580 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802580:	f3 0f 1e fb          	endbr32 
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80258a:	68 d7 32 80 00       	push   $0x8032d7
  80258f:	ff 75 0c             	pushl  0xc(%ebp)
  802592:	e8 c8 e2 ff ff       	call   80085f <strcpy>
	return 0;
}
  802597:	b8 00 00 00 00       	mov    $0x0,%eax
  80259c:	c9                   	leave  
  80259d:	c3                   	ret    

0080259e <devcons_write>:
{
  80259e:	f3 0f 1e fb          	endbr32 
  8025a2:	55                   	push   %ebp
  8025a3:	89 e5                	mov    %esp,%ebp
  8025a5:	57                   	push   %edi
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8025ae:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8025b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8025b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025bc:	73 31                	jae    8025ef <devcons_write+0x51>
		m = n - tot;
  8025be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025c1:	29 f3                	sub    %esi,%ebx
  8025c3:	83 fb 7f             	cmp    $0x7f,%ebx
  8025c6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8025cb:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8025ce:	83 ec 04             	sub    $0x4,%esp
  8025d1:	53                   	push   %ebx
  8025d2:	89 f0                	mov    %esi,%eax
  8025d4:	03 45 0c             	add    0xc(%ebp),%eax
  8025d7:	50                   	push   %eax
  8025d8:	57                   	push   %edi
  8025d9:	e8 39 e4 ff ff       	call   800a17 <memmove>
		sys_cputs(buf, m);
  8025de:	83 c4 08             	add    $0x8,%esp
  8025e1:	53                   	push   %ebx
  8025e2:	57                   	push   %edi
  8025e3:	e8 34 e6 ff ff       	call   800c1c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8025e8:	01 de                	add    %ebx,%esi
  8025ea:	83 c4 10             	add    $0x10,%esp
  8025ed:	eb ca                	jmp    8025b9 <devcons_write+0x1b>
}
  8025ef:	89 f0                	mov    %esi,%eax
  8025f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    

008025f9 <devcons_read>:
{
  8025f9:	f3 0f 1e fb          	endbr32 
  8025fd:	55                   	push   %ebp
  8025fe:	89 e5                	mov    %esp,%ebp
  802600:	83 ec 08             	sub    $0x8,%esp
  802603:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802608:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80260c:	74 21                	je     80262f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80260e:	e8 33 e6 ff ff       	call   800c46 <sys_cgetc>
  802613:	85 c0                	test   %eax,%eax
  802615:	75 07                	jne    80261e <devcons_read+0x25>
		sys_yield();
  802617:	e8 a0 e6 ff ff       	call   800cbc <sys_yield>
  80261c:	eb f0                	jmp    80260e <devcons_read+0x15>
	if (c < 0)
  80261e:	78 0f                	js     80262f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802620:	83 f8 04             	cmp    $0x4,%eax
  802623:	74 0c                	je     802631 <devcons_read+0x38>
	*(char*)vbuf = c;
  802625:	8b 55 0c             	mov    0xc(%ebp),%edx
  802628:	88 02                	mov    %al,(%edx)
	return 1;
  80262a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80262f:	c9                   	leave  
  802630:	c3                   	ret    
		return 0;
  802631:	b8 00 00 00 00       	mov    $0x0,%eax
  802636:	eb f7                	jmp    80262f <devcons_read+0x36>

00802638 <cputchar>:
{
  802638:	f3 0f 1e fb          	endbr32 
  80263c:	55                   	push   %ebp
  80263d:	89 e5                	mov    %esp,%ebp
  80263f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802642:	8b 45 08             	mov    0x8(%ebp),%eax
  802645:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802648:	6a 01                	push   $0x1
  80264a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80264d:	50                   	push   %eax
  80264e:	e8 c9 e5 ff ff       	call   800c1c <sys_cputs>
}
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	c9                   	leave  
  802657:	c3                   	ret    

00802658 <getchar>:
{
  802658:	f3 0f 1e fb          	endbr32 
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802662:	6a 01                	push   $0x1
  802664:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802667:	50                   	push   %eax
  802668:	6a 00                	push   $0x0
  80266a:	e8 04 f0 ff ff       	call   801673 <read>
	if (r < 0)
  80266f:	83 c4 10             	add    $0x10,%esp
  802672:	85 c0                	test   %eax,%eax
  802674:	78 06                	js     80267c <getchar+0x24>
	if (r < 1)
  802676:	74 06                	je     80267e <getchar+0x26>
	return c;
  802678:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80267c:	c9                   	leave  
  80267d:	c3                   	ret    
		return -E_EOF;
  80267e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802683:	eb f7                	jmp    80267c <getchar+0x24>

00802685 <iscons>:
{
  802685:	f3 0f 1e fb          	endbr32 
  802689:	55                   	push   %ebp
  80268a:	89 e5                	mov    %esp,%ebp
  80268c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80268f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802692:	50                   	push   %eax
  802693:	ff 75 08             	pushl  0x8(%ebp)
  802696:	e8 55 ed ff ff       	call   8013f0 <fd_lookup>
  80269b:	83 c4 10             	add    $0x10,%esp
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	78 11                	js     8026b3 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8026a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a5:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026ab:	39 10                	cmp    %edx,(%eax)
  8026ad:	0f 94 c0             	sete   %al
  8026b0:	0f b6 c0             	movzbl %al,%eax
}
  8026b3:	c9                   	leave  
  8026b4:	c3                   	ret    

008026b5 <opencons>:
{
  8026b5:	f3 0f 1e fb          	endbr32 
  8026b9:	55                   	push   %ebp
  8026ba:	89 e5                	mov    %esp,%ebp
  8026bc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8026bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026c2:	50                   	push   %eax
  8026c3:	e8 d2 ec ff ff       	call   80139a <fd_alloc>
  8026c8:	83 c4 10             	add    $0x10,%esp
  8026cb:	85 c0                	test   %eax,%eax
  8026cd:	78 3a                	js     802709 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026cf:	83 ec 04             	sub    $0x4,%esp
  8026d2:	68 07 04 00 00       	push   $0x407
  8026d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8026da:	6a 00                	push   $0x0
  8026dc:	e8 06 e6 ff ff       	call   800ce7 <sys_page_alloc>
  8026e1:	83 c4 10             	add    $0x10,%esp
  8026e4:	85 c0                	test   %eax,%eax
  8026e6:	78 21                	js     802709 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8026e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026eb:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026fd:	83 ec 0c             	sub    $0xc,%esp
  802700:	50                   	push   %eax
  802701:	e8 61 ec ff ff       	call   801367 <fd2num>
  802706:	83 c4 10             	add    $0x10,%esp
}
  802709:	c9                   	leave  
  80270a:	c3                   	ret    

0080270b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80270b:	f3 0f 1e fb          	endbr32 
  80270f:	55                   	push   %ebp
  802710:	89 e5                	mov    %esp,%ebp
  802712:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802715:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80271c:	74 1c                	je     80273a <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80271e:	8b 45 08             	mov    0x8(%ebp),%eax
  802721:	a3 00 70 80 00       	mov    %eax,0x807000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802726:	83 ec 08             	sub    $0x8,%esp
  802729:	68 66 27 80 00       	push   $0x802766
  80272e:	6a 00                	push   $0x0
  802730:	e8 79 e6 ff ff       	call   800dae <sys_env_set_pgfault_upcall>
}
  802735:	83 c4 10             	add    $0x10,%esp
  802738:	c9                   	leave  
  802739:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  80273a:	83 ec 04             	sub    $0x4,%esp
  80273d:	6a 02                	push   $0x2
  80273f:	68 00 f0 bf ee       	push   $0xeebff000
  802744:	6a 00                	push   $0x0
  802746:	e8 9c e5 ff ff       	call   800ce7 <sys_page_alloc>
  80274b:	83 c4 10             	add    $0x10,%esp
  80274e:	85 c0                	test   %eax,%eax
  802750:	79 cc                	jns    80271e <set_pgfault_handler+0x13>
  802752:	83 ec 04             	sub    $0x4,%esp
  802755:	68 e3 32 80 00       	push   $0x8032e3
  80275a:	6a 20                	push   $0x20
  80275c:	68 fe 32 80 00       	push   $0x8032fe
  802761:	e8 a8 da ff ff       	call   80020e <_panic>

00802766 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802766:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802767:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80276c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80276e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  802771:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  802775:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  802779:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  80277c:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  80277e:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802782:	83 c4 08             	add    $0x8,%esp
	popal
  802785:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802786:	83 c4 04             	add    $0x4,%esp
	popfl
  802789:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80278a:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80278d:	c3                   	ret    

0080278e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80278e:	f3 0f 1e fb          	endbr32 
  802792:	55                   	push   %ebp
  802793:	89 e5                	mov    %esp,%ebp
  802795:	56                   	push   %esi
  802796:	53                   	push   %ebx
  802797:	8b 75 08             	mov    0x8(%ebp),%esi
  80279a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80279d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  8027a0:	85 c0                	test   %eax,%eax
  8027a2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8027a7:	0f 44 c2             	cmove  %edx,%eax
  8027aa:	83 ec 0c             	sub    $0xc,%esp
  8027ad:	50                   	push   %eax
  8027ae:	e8 4b e6 ff ff       	call   800dfe <sys_ipc_recv>

	if (from_env_store != NULL)
  8027b3:	83 c4 10             	add    $0x10,%esp
  8027b6:	85 f6                	test   %esi,%esi
  8027b8:	74 15                	je     8027cf <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8027ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8027bf:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8027c2:	74 09                	je     8027cd <ipc_recv+0x3f>
  8027c4:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8027ca:	8b 52 74             	mov    0x74(%edx),%edx
  8027cd:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8027cf:	85 db                	test   %ebx,%ebx
  8027d1:	74 15                	je     8027e8 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8027d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8027d8:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8027db:	74 09                	je     8027e6 <ipc_recv+0x58>
  8027dd:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8027e3:	8b 52 78             	mov    0x78(%edx),%edx
  8027e6:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8027e8:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8027eb:	74 08                	je     8027f5 <ipc_recv+0x67>
  8027ed:	a1 04 50 80 00       	mov    0x805004,%eax
  8027f2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027f8:	5b                   	pop    %ebx
  8027f9:	5e                   	pop    %esi
  8027fa:	5d                   	pop    %ebp
  8027fb:	c3                   	ret    

008027fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027fc:	f3 0f 1e fb          	endbr32 
  802800:	55                   	push   %ebp
  802801:	89 e5                	mov    %esp,%ebp
  802803:	57                   	push   %edi
  802804:	56                   	push   %esi
  802805:	53                   	push   %ebx
  802806:	83 ec 0c             	sub    $0xc,%esp
  802809:	8b 7d 08             	mov    0x8(%ebp),%edi
  80280c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80280f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802812:	eb 1f                	jmp    802833 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802814:	6a 00                	push   $0x0
  802816:	68 00 00 c0 ee       	push   $0xeec00000
  80281b:	56                   	push   %esi
  80281c:	57                   	push   %edi
  80281d:	e8 b3 e5 ff ff       	call   800dd5 <sys_ipc_try_send>
  802822:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  802825:	85 c0                	test   %eax,%eax
  802827:	74 30                	je     802859 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  802829:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80282c:	75 19                	jne    802847 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  80282e:	e8 89 e4 ff ff       	call   800cbc <sys_yield>
		if (pg != NULL) {
  802833:	85 db                	test   %ebx,%ebx
  802835:	74 dd                	je     802814 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  802837:	ff 75 14             	pushl  0x14(%ebp)
  80283a:	53                   	push   %ebx
  80283b:	56                   	push   %esi
  80283c:	57                   	push   %edi
  80283d:	e8 93 e5 ff ff       	call   800dd5 <sys_ipc_try_send>
  802842:	83 c4 10             	add    $0x10,%esp
  802845:	eb de                	jmp    802825 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  802847:	50                   	push   %eax
  802848:	68 0c 33 80 00       	push   $0x80330c
  80284d:	6a 3e                	push   $0x3e
  80284f:	68 19 33 80 00       	push   $0x803319
  802854:	e8 b5 d9 ff ff       	call   80020e <_panic>
	}
}
  802859:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80285c:	5b                   	pop    %ebx
  80285d:	5e                   	pop    %esi
  80285e:	5f                   	pop    %edi
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    

00802861 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802861:	f3 0f 1e fb          	endbr32 
  802865:	55                   	push   %ebp
  802866:	89 e5                	mov    %esp,%ebp
  802868:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80286b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802870:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802873:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802879:	8b 52 50             	mov    0x50(%edx),%edx
  80287c:	39 ca                	cmp    %ecx,%edx
  80287e:	74 11                	je     802891 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802880:	83 c0 01             	add    $0x1,%eax
  802883:	3d 00 04 00 00       	cmp    $0x400,%eax
  802888:	75 e6                	jne    802870 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80288a:	b8 00 00 00 00       	mov    $0x0,%eax
  80288f:	eb 0b                	jmp    80289c <ipc_find_env+0x3b>
			return envs[i].env_id;
  802891:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802894:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802899:	8b 40 48             	mov    0x48(%eax),%eax
}
  80289c:	5d                   	pop    %ebp
  80289d:	c3                   	ret    

0080289e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80289e:	f3 0f 1e fb          	endbr32 
  8028a2:	55                   	push   %ebp
  8028a3:	89 e5                	mov    %esp,%ebp
  8028a5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028a8:	89 c2                	mov    %eax,%edx
  8028aa:	c1 ea 16             	shr    $0x16,%edx
  8028ad:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8028b4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8028b9:	f6 c1 01             	test   $0x1,%cl
  8028bc:	74 1c                	je     8028da <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8028be:	c1 e8 0c             	shr    $0xc,%eax
  8028c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8028c8:	a8 01                	test   $0x1,%al
  8028ca:	74 0e                	je     8028da <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028cc:	c1 e8 0c             	shr    $0xc,%eax
  8028cf:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8028d6:	ef 
  8028d7:	0f b7 d2             	movzwl %dx,%edx
}
  8028da:	89 d0                	mov    %edx,%eax
  8028dc:	5d                   	pop    %ebp
  8028dd:	c3                   	ret    
  8028de:	66 90                	xchg   %ax,%ax

008028e0 <__udivdi3>:
  8028e0:	f3 0f 1e fb          	endbr32 
  8028e4:	55                   	push   %ebp
  8028e5:	57                   	push   %edi
  8028e6:	56                   	push   %esi
  8028e7:	53                   	push   %ebx
  8028e8:	83 ec 1c             	sub    $0x1c,%esp
  8028eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8028f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8028fb:	85 d2                	test   %edx,%edx
  8028fd:	75 19                	jne    802918 <__udivdi3+0x38>
  8028ff:	39 f3                	cmp    %esi,%ebx
  802901:	76 4d                	jbe    802950 <__udivdi3+0x70>
  802903:	31 ff                	xor    %edi,%edi
  802905:	89 e8                	mov    %ebp,%eax
  802907:	89 f2                	mov    %esi,%edx
  802909:	f7 f3                	div    %ebx
  80290b:	89 fa                	mov    %edi,%edx
  80290d:	83 c4 1c             	add    $0x1c,%esp
  802910:	5b                   	pop    %ebx
  802911:	5e                   	pop    %esi
  802912:	5f                   	pop    %edi
  802913:	5d                   	pop    %ebp
  802914:	c3                   	ret    
  802915:	8d 76 00             	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	76 14                	jbe    802930 <__udivdi3+0x50>
  80291c:	31 ff                	xor    %edi,%edi
  80291e:	31 c0                	xor    %eax,%eax
  802920:	89 fa                	mov    %edi,%edx
  802922:	83 c4 1c             	add    $0x1c,%esp
  802925:	5b                   	pop    %ebx
  802926:	5e                   	pop    %esi
  802927:	5f                   	pop    %edi
  802928:	5d                   	pop    %ebp
  802929:	c3                   	ret    
  80292a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802930:	0f bd fa             	bsr    %edx,%edi
  802933:	83 f7 1f             	xor    $0x1f,%edi
  802936:	75 48                	jne    802980 <__udivdi3+0xa0>
  802938:	39 f2                	cmp    %esi,%edx
  80293a:	72 06                	jb     802942 <__udivdi3+0x62>
  80293c:	31 c0                	xor    %eax,%eax
  80293e:	39 eb                	cmp    %ebp,%ebx
  802940:	77 de                	ja     802920 <__udivdi3+0x40>
  802942:	b8 01 00 00 00       	mov    $0x1,%eax
  802947:	eb d7                	jmp    802920 <__udivdi3+0x40>
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	89 d9                	mov    %ebx,%ecx
  802952:	85 db                	test   %ebx,%ebx
  802954:	75 0b                	jne    802961 <__udivdi3+0x81>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f3                	div    %ebx
  80295f:	89 c1                	mov    %eax,%ecx
  802961:	31 d2                	xor    %edx,%edx
  802963:	89 f0                	mov    %esi,%eax
  802965:	f7 f1                	div    %ecx
  802967:	89 c6                	mov    %eax,%esi
  802969:	89 e8                	mov    %ebp,%eax
  80296b:	89 f7                	mov    %esi,%edi
  80296d:	f7 f1                	div    %ecx
  80296f:	89 fa                	mov    %edi,%edx
  802971:	83 c4 1c             	add    $0x1c,%esp
  802974:	5b                   	pop    %ebx
  802975:	5e                   	pop    %esi
  802976:	5f                   	pop    %edi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    
  802979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802980:	89 f9                	mov    %edi,%ecx
  802982:	b8 20 00 00 00       	mov    $0x20,%eax
  802987:	29 f8                	sub    %edi,%eax
  802989:	d3 e2                	shl    %cl,%edx
  80298b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80298f:	89 c1                	mov    %eax,%ecx
  802991:	89 da                	mov    %ebx,%edx
  802993:	d3 ea                	shr    %cl,%edx
  802995:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802999:	09 d1                	or     %edx,%ecx
  80299b:	89 f2                	mov    %esi,%edx
  80299d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	d3 e3                	shl    %cl,%ebx
  8029a5:	89 c1                	mov    %eax,%ecx
  8029a7:	d3 ea                	shr    %cl,%edx
  8029a9:	89 f9                	mov    %edi,%ecx
  8029ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8029af:	89 eb                	mov    %ebp,%ebx
  8029b1:	d3 e6                	shl    %cl,%esi
  8029b3:	89 c1                	mov    %eax,%ecx
  8029b5:	d3 eb                	shr    %cl,%ebx
  8029b7:	09 de                	or     %ebx,%esi
  8029b9:	89 f0                	mov    %esi,%eax
  8029bb:	f7 74 24 08          	divl   0x8(%esp)
  8029bf:	89 d6                	mov    %edx,%esi
  8029c1:	89 c3                	mov    %eax,%ebx
  8029c3:	f7 64 24 0c          	mull   0xc(%esp)
  8029c7:	39 d6                	cmp    %edx,%esi
  8029c9:	72 15                	jb     8029e0 <__udivdi3+0x100>
  8029cb:	89 f9                	mov    %edi,%ecx
  8029cd:	d3 e5                	shl    %cl,%ebp
  8029cf:	39 c5                	cmp    %eax,%ebp
  8029d1:	73 04                	jae    8029d7 <__udivdi3+0xf7>
  8029d3:	39 d6                	cmp    %edx,%esi
  8029d5:	74 09                	je     8029e0 <__udivdi3+0x100>
  8029d7:	89 d8                	mov    %ebx,%eax
  8029d9:	31 ff                	xor    %edi,%edi
  8029db:	e9 40 ff ff ff       	jmp    802920 <__udivdi3+0x40>
  8029e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8029e3:	31 ff                	xor    %edi,%edi
  8029e5:	e9 36 ff ff ff       	jmp    802920 <__udivdi3+0x40>
  8029ea:	66 90                	xchg   %ax,%ax
  8029ec:	66 90                	xchg   %ax,%ax
  8029ee:	66 90                	xchg   %ax,%ax

008029f0 <__umoddi3>:
  8029f0:	f3 0f 1e fb          	endbr32 
  8029f4:	55                   	push   %ebp
  8029f5:	57                   	push   %edi
  8029f6:	56                   	push   %esi
  8029f7:	53                   	push   %ebx
  8029f8:	83 ec 1c             	sub    $0x1c,%esp
  8029fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8029ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  802a03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802a07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a0b:	85 c0                	test   %eax,%eax
  802a0d:	75 19                	jne    802a28 <__umoddi3+0x38>
  802a0f:	39 df                	cmp    %ebx,%edi
  802a11:	76 5d                	jbe    802a70 <__umoddi3+0x80>
  802a13:	89 f0                	mov    %esi,%eax
  802a15:	89 da                	mov    %ebx,%edx
  802a17:	f7 f7                	div    %edi
  802a19:	89 d0                	mov    %edx,%eax
  802a1b:	31 d2                	xor    %edx,%edx
  802a1d:	83 c4 1c             	add    $0x1c,%esp
  802a20:	5b                   	pop    %ebx
  802a21:	5e                   	pop    %esi
  802a22:	5f                   	pop    %edi
  802a23:	5d                   	pop    %ebp
  802a24:	c3                   	ret    
  802a25:	8d 76 00             	lea    0x0(%esi),%esi
  802a28:	89 f2                	mov    %esi,%edx
  802a2a:	39 d8                	cmp    %ebx,%eax
  802a2c:	76 12                	jbe    802a40 <__umoddi3+0x50>
  802a2e:	89 f0                	mov    %esi,%eax
  802a30:	89 da                	mov    %ebx,%edx
  802a32:	83 c4 1c             	add    $0x1c,%esp
  802a35:	5b                   	pop    %ebx
  802a36:	5e                   	pop    %esi
  802a37:	5f                   	pop    %edi
  802a38:	5d                   	pop    %ebp
  802a39:	c3                   	ret    
  802a3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a40:	0f bd e8             	bsr    %eax,%ebp
  802a43:	83 f5 1f             	xor    $0x1f,%ebp
  802a46:	75 50                	jne    802a98 <__umoddi3+0xa8>
  802a48:	39 d8                	cmp    %ebx,%eax
  802a4a:	0f 82 e0 00 00 00    	jb     802b30 <__umoddi3+0x140>
  802a50:	89 d9                	mov    %ebx,%ecx
  802a52:	39 f7                	cmp    %esi,%edi
  802a54:	0f 86 d6 00 00 00    	jbe    802b30 <__umoddi3+0x140>
  802a5a:	89 d0                	mov    %edx,%eax
  802a5c:	89 ca                	mov    %ecx,%edx
  802a5e:	83 c4 1c             	add    $0x1c,%esp
  802a61:	5b                   	pop    %ebx
  802a62:	5e                   	pop    %esi
  802a63:	5f                   	pop    %edi
  802a64:	5d                   	pop    %ebp
  802a65:	c3                   	ret    
  802a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a6d:	8d 76 00             	lea    0x0(%esi),%esi
  802a70:	89 fd                	mov    %edi,%ebp
  802a72:	85 ff                	test   %edi,%edi
  802a74:	75 0b                	jne    802a81 <__umoddi3+0x91>
  802a76:	b8 01 00 00 00       	mov    $0x1,%eax
  802a7b:	31 d2                	xor    %edx,%edx
  802a7d:	f7 f7                	div    %edi
  802a7f:	89 c5                	mov    %eax,%ebp
  802a81:	89 d8                	mov    %ebx,%eax
  802a83:	31 d2                	xor    %edx,%edx
  802a85:	f7 f5                	div    %ebp
  802a87:	89 f0                	mov    %esi,%eax
  802a89:	f7 f5                	div    %ebp
  802a8b:	89 d0                	mov    %edx,%eax
  802a8d:	31 d2                	xor    %edx,%edx
  802a8f:	eb 8c                	jmp    802a1d <__umoddi3+0x2d>
  802a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a98:	89 e9                	mov    %ebp,%ecx
  802a9a:	ba 20 00 00 00       	mov    $0x20,%edx
  802a9f:	29 ea                	sub    %ebp,%edx
  802aa1:	d3 e0                	shl    %cl,%eax
  802aa3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802aa7:	89 d1                	mov    %edx,%ecx
  802aa9:	89 f8                	mov    %edi,%eax
  802aab:	d3 e8                	shr    %cl,%eax
  802aad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ab5:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ab9:	09 c1                	or     %eax,%ecx
  802abb:	89 d8                	mov    %ebx,%eax
  802abd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ac1:	89 e9                	mov    %ebp,%ecx
  802ac3:	d3 e7                	shl    %cl,%edi
  802ac5:	89 d1                	mov    %edx,%ecx
  802ac7:	d3 e8                	shr    %cl,%eax
  802ac9:	89 e9                	mov    %ebp,%ecx
  802acb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802acf:	d3 e3                	shl    %cl,%ebx
  802ad1:	89 c7                	mov    %eax,%edi
  802ad3:	89 d1                	mov    %edx,%ecx
  802ad5:	89 f0                	mov    %esi,%eax
  802ad7:	d3 e8                	shr    %cl,%eax
  802ad9:	89 e9                	mov    %ebp,%ecx
  802adb:	89 fa                	mov    %edi,%edx
  802add:	d3 e6                	shl    %cl,%esi
  802adf:	09 d8                	or     %ebx,%eax
  802ae1:	f7 74 24 08          	divl   0x8(%esp)
  802ae5:	89 d1                	mov    %edx,%ecx
  802ae7:	89 f3                	mov    %esi,%ebx
  802ae9:	f7 64 24 0c          	mull   0xc(%esp)
  802aed:	89 c6                	mov    %eax,%esi
  802aef:	89 d7                	mov    %edx,%edi
  802af1:	39 d1                	cmp    %edx,%ecx
  802af3:	72 06                	jb     802afb <__umoddi3+0x10b>
  802af5:	75 10                	jne    802b07 <__umoddi3+0x117>
  802af7:	39 c3                	cmp    %eax,%ebx
  802af9:	73 0c                	jae    802b07 <__umoddi3+0x117>
  802afb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802aff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802b03:	89 d7                	mov    %edx,%edi
  802b05:	89 c6                	mov    %eax,%esi
  802b07:	89 ca                	mov    %ecx,%edx
  802b09:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802b0e:	29 f3                	sub    %esi,%ebx
  802b10:	19 fa                	sbb    %edi,%edx
  802b12:	89 d0                	mov    %edx,%eax
  802b14:	d3 e0                	shl    %cl,%eax
  802b16:	89 e9                	mov    %ebp,%ecx
  802b18:	d3 eb                	shr    %cl,%ebx
  802b1a:	d3 ea                	shr    %cl,%edx
  802b1c:	09 d8                	or     %ebx,%eax
  802b1e:	83 c4 1c             	add    $0x1c,%esp
  802b21:	5b                   	pop    %ebx
  802b22:	5e                   	pop    %esi
  802b23:	5f                   	pop    %edi
  802b24:	5d                   	pop    %ebp
  802b25:	c3                   	ret    
  802b26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b2d:	8d 76 00             	lea    0x0(%esi),%esi
  802b30:	29 fe                	sub    %edi,%esi
  802b32:	19 c3                	sbb    %eax,%ebx
  802b34:	89 f2                	mov    %esi,%edx
  802b36:	89 d9                	mov    %ebx,%ecx
  802b38:	e9 1d ff ff ff       	jmp    802a5a <__umoddi3+0x6a>
