
obj/user/primes.debug:     formato del fichero elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800040:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 00                	push   $0x0
  800048:	6a 00                	push   $0x0
  80004a:	56                   	push   %esi
  80004b:	e8 73 12 00 00       	call   8012c3 <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 40 80 00       	mov    0x804004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 40 24 80 00       	push   $0x802440
  800064:	e8 e8 01 00 00       	call   800251 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 b4 10 00 00       	call   801122 <fork>
  80006e:	89 c7                	mov    %eax,%edi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	78 07                	js     80007e <primeproc+0x4b>
		panic("fork: %e", id);
	if (id == 0)
  800077:	74 ca                	je     800043 <primeproc+0x10>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800079:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007c:	eb 20                	jmp    80009e <primeproc+0x6b>
		panic("fork: %e", id);
  80007e:	50                   	push   %eax
  80007f:	68 4c 24 80 00       	push   $0x80244c
  800084:	6a 1a                	push   $0x1a
  800086:	68 55 24 80 00       	push   $0x802455
  80008b:	e8 da 00 00 00       	call   80016a <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 96 12 00 00       	call   801331 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 18 12 00 00       	call   8012c3 <ipc_recv>
  8000ab:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000ad:	99                   	cltd   
  8000ae:	f7 fb                	idiv   %ebx
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	85 d2                	test   %edx,%edx
  8000b5:	74 e7                	je     80009e <primeproc+0x6b>
  8000b7:	eb d7                	jmp    800090 <primeproc+0x5d>

008000b9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 5b 10 00 00       	call   801122 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	78 1a                	js     8000e7 <umain+0x2e>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000cd:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000d2:	74 25                	je     8000f9 <umain+0x40>
		ipc_send(id, i, 0, 0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	6a 00                	push   $0x0
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 52 12 00 00       	call   801331 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 4c 24 80 00       	push   $0x80244c
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 55 24 80 00       	push   $0x802455
  8000f4:	e8 71 00 00 00       	call   80016a <_panic>
		primeproc();
  8000f9:	e8 35 ff ff ff       	call   800033 <primeproc>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80010d:	e8 de 0a 00 00       	call   800bf0 <sys_getenvid>
	if (id >= 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	78 12                	js     800128 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800116:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800123:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800128:	85 db                	test   %ebx,%ebx
  80012a:	7e 07                	jle    800133 <libmain+0x35>
		binaryname = argv[0];
  80012c:	8b 06                	mov    (%esi),%eax
  80012e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800133:	83 ec 08             	sub    $0x8,%esp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	e8 7c ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	f3 0f 1e fb          	endbr32 
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800156:	e8 6b 14 00 00       	call   8015c6 <close_all>
	sys_env_destroy(0);
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	6a 00                	push   $0x0
  800160:	e8 65 0a 00 00       	call   800bca <sys_env_destroy>
}
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016a:	f3 0f 1e fb          	endbr32 
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800173:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800176:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80017c:	e8 6f 0a 00 00       	call   800bf0 <sys_getenvid>
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 0c             	pushl  0xc(%ebp)
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	56                   	push   %esi
  80018b:	50                   	push   %eax
  80018c:	68 70 24 80 00       	push   $0x802470
  800191:	e8 bb 00 00 00       	call   800251 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	83 c4 18             	add    $0x18,%esp
  800199:	53                   	push   %ebx
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	e8 5a 00 00 00       	call   8001fc <vcprintf>
	cprintf("\n");
  8001a2:	c7 04 24 9b 2a 80 00 	movl   $0x802a9b,(%esp)
  8001a9:	e8 a3 00 00 00       	call   800251 <cprintf>
  8001ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b1:	cc                   	int3   
  8001b2:	eb fd                	jmp    8001b1 <_panic+0x47>

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 13                	mov    (%ebx),%edx
  8001c4:	8d 42 01             	lea    0x1(%edx),%eax
  8001c7:	89 03                	mov    %eax,(%ebx)
  8001c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	74 09                	je     8001e0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	68 ff 00 00 00       	push   $0xff
  8001e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001eb:	50                   	push   %eax
  8001ec:	e8 87 09 00 00       	call   800b78 <sys_cputs>
		b->idx = 0;
  8001f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb db                	jmp    8001d7 <putch+0x23>

008001fc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fc:	f3 0f 1e fb          	endbr32 
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800209:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800210:	00 00 00 
	b.cnt = 0;
  800213:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	ff 75 08             	pushl  0x8(%ebp)
  800223:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800229:	50                   	push   %eax
  80022a:	68 b4 01 80 00       	push   $0x8001b4
  80022f:	e8 80 01 00 00       	call   8003b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800234:	83 c4 08             	add    $0x8,%esp
  800237:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800243:	50                   	push   %eax
  800244:	e8 2f 09 00 00       	call   800b78 <sys_cputs>

	return b.cnt;
}
  800249:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800251:	f3 0f 1e fb          	endbr32 
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 95 ff ff ff       	call   8001fc <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 1c             	sub    $0x1c,%esp
  800272:	89 c7                	mov    %eax,%edi
  800274:	89 d6                	mov    %edx,%esi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 d1                	mov    %edx,%ecx
  80027e:	89 c2                	mov    %eax,%edx
  800280:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800283:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800286:	8b 45 10             	mov    0x10(%ebp),%eax
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800296:	39 c2                	cmp    %eax,%edx
  800298:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80029b:	72 3e                	jb     8002db <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029d:	83 ec 0c             	sub    $0xc,%esp
  8002a0:	ff 75 18             	pushl  0x18(%ebp)
  8002a3:	83 eb 01             	sub    $0x1,%ebx
  8002a6:	53                   	push   %ebx
  8002a7:	50                   	push   %eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b7:	e8 24 1f 00 00       	call   8021e0 <__udivdi3>
  8002bc:	83 c4 18             	add    $0x18,%esp
  8002bf:	52                   	push   %edx
  8002c0:	50                   	push   %eax
  8002c1:	89 f2                	mov    %esi,%edx
  8002c3:	89 f8                	mov    %edi,%eax
  8002c5:	e8 9f ff ff ff       	call   800269 <printnum>
  8002ca:	83 c4 20             	add    $0x20,%esp
  8002cd:	eb 13                	jmp    8002e2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cf:	83 ec 08             	sub    $0x8,%esp
  8002d2:	56                   	push   %esi
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	ff d7                	call   *%edi
  8002d8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002db:	83 eb 01             	sub    $0x1,%ebx
  8002de:	85 db                	test   %ebx,%ebx
  8002e0:	7f ed                	jg     8002cf <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	56                   	push   %esi
  8002e6:	83 ec 04             	sub    $0x4,%esp
  8002e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f5:	e8 f6 1f 00 00       	call   8022f0 <__umoddi3>
  8002fa:	83 c4 14             	add    $0x14,%esp
  8002fd:	0f be 80 93 24 80 00 	movsbl 0x802493(%eax),%eax
  800304:	50                   	push   %eax
  800305:	ff d7                	call   *%edi
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5f                   	pop    %edi
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800312:	83 fa 01             	cmp    $0x1,%edx
  800315:	7f 13                	jg     80032a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800317:	85 d2                	test   %edx,%edx
  800319:	74 1c                	je     800337 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800320:	89 08                	mov    %ecx,(%eax)
  800322:	8b 02                	mov    (%edx),%eax
  800324:	ba 00 00 00 00       	mov    $0x0,%edx
  800329:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	8b 52 04             	mov    0x4(%edx),%edx
  800336:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800345:	c3                   	ret    

00800346 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800346:	83 fa 01             	cmp    $0x1,%edx
  800349:	7f 0f                	jg     80035a <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80034b:	85 d2                	test   %edx,%edx
  80034d:	74 18                	je     800367 <getint+0x21>
		return va_arg(*ap, long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	99                   	cltd   
  800359:	c3                   	ret    
		return va_arg(*ap, long long);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	8b 52 04             	mov    0x4(%edx),%edx
  800366:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	99                   	cltd   
}
  800371:	c3                   	ret    

00800372 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800372:	f3 0f 1e fb          	endbr32 
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800380:	8b 10                	mov    (%eax),%edx
  800382:	3b 50 04             	cmp    0x4(%eax),%edx
  800385:	73 0a                	jae    800391 <sprintputch+0x1f>
		*b->buf++ = ch;
  800387:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	88 02                	mov    %al,(%edx)
}
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <printfmt>:
{
  800393:	f3 0f 1e fb          	endbr32 
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a0:	50                   	push   %eax
  8003a1:	ff 75 10             	pushl  0x10(%ebp)
  8003a4:	ff 75 0c             	pushl  0xc(%ebp)
  8003a7:	ff 75 08             	pushl  0x8(%ebp)
  8003aa:	e8 05 00 00 00       	call   8003b4 <vprintfmt>
}
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <vprintfmt>:
{
  8003b4:	f3 0f 1e fb          	endbr32 
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	57                   	push   %edi
  8003bc:	56                   	push   %esi
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 2c             	sub    $0x2c,%esp
  8003c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003c7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003ca:	e9 86 02 00 00       	jmp    800655 <vprintfmt+0x2a1>
		padc = ' ';
  8003cf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8d 47 01             	lea    0x1(%edi),%eax
  8003f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f3:	0f b6 17             	movzbl (%edi),%edx
  8003f6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f9:	3c 55                	cmp    $0x55,%al
  8003fb:	0f 87 df 02 00 00    	ja     8006e0 <vprintfmt+0x32c>
  800401:	0f b6 c0             	movzbl %al,%eax
  800404:	3e ff 24 85 e0 25 80 	notrack jmp *0x8025e0(,%eax,4)
  80040b:	00 
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80040f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800413:	eb d8                	jmp    8003ed <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800418:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80041c:	eb cf                	jmp    8003ed <vprintfmt+0x39>
  80041e:	0f b6 d2             	movzbl %dl,%edx
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800424:	b8 00 00 00 00       	mov    $0x0,%eax
  800429:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80042c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800433:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800436:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800439:	83 f9 09             	cmp    $0x9,%ecx
  80043c:	77 52                	ja     800490 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80043e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800441:	eb e9                	jmp    80042c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	79 93                	jns    8003ed <vprintfmt+0x39>
				width = precision, precision = -1;
  80045a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800467:	eb 84                	jmp    8003ed <vprintfmt+0x39>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	0f 49 d0             	cmovns %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80047c:	e9 6c ff ff ff       	jmp    8003ed <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800484:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048b:	e9 5d ff ff ff       	jmp    8003ed <vprintfmt+0x39>
  800490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800493:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800496:	eb bc                	jmp    800454 <vprintfmt+0xa0>
			lflag++;
  800498:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049e:	e9 4a ff ff ff       	jmp    8003ed <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 50 04             	lea    0x4(%eax),%edx
  8004a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	56                   	push   %esi
  8004b0:	ff 30                	pushl  (%eax)
  8004b2:	ff d3                	call   *%ebx
			break;
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	e9 96 01 00 00       	jmp    800652 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	99                   	cltd   
  8004c8:	31 d0                	xor    %edx,%eax
  8004ca:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cc:	83 f8 0f             	cmp    $0xf,%eax
  8004cf:	7f 20                	jg     8004f1 <vprintfmt+0x13d>
  8004d1:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	74 15                	je     8004f1 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8004dc:	52                   	push   %edx
  8004dd:	68 69 2a 80 00       	push   $0x802a69
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	e8 aa fe ff ff       	call   800393 <printfmt>
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	e9 61 01 00 00       	jmp    800652 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004f1:	50                   	push   %eax
  8004f2:	68 ab 24 80 00       	push   $0x8024ab
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	e8 95 fe ff ff       	call   800393 <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	e9 4c 01 00 00       	jmp    800652 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800511:	85 c9                	test   %ecx,%ecx
  800513:	b8 a4 24 80 00       	mov    $0x8024a4,%eax
  800518:	0f 45 c1             	cmovne %ecx,%eax
  80051b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80051e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800522:	7e 06                	jle    80052a <vprintfmt+0x176>
  800524:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800528:	75 0d                	jne    800537 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052d:	89 c7                	mov    %eax,%edi
  80052f:	03 45 e0             	add    -0x20(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	eb 57                	jmp    80058e <vprintfmt+0x1da>
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 d8             	pushl  -0x28(%ebp)
  80053d:	ff 75 cc             	pushl  -0x34(%ebp)
  800540:	e8 4f 02 00 00       	call   800794 <strnlen>
  800545:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800548:	29 c2                	sub    %eax,%edx
  80054a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800550:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800554:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800557:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	85 db                	test   %ebx,%ebx
  80055b:	7e 10                	jle    80056d <vprintfmt+0x1b9>
					putch(padc, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	56                   	push   %esi
  800561:	57                   	push   %edi
  800562:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb ec                	jmp    800559 <vprintfmt+0x1a5>
  80056d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800570:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800573:	85 d2                	test   %edx,%edx
  800575:	b8 00 00 00 00       	mov    $0x0,%eax
  80057a:	0f 49 c2             	cmovns %edx,%eax
  80057d:	29 c2                	sub    %eax,%edx
  80057f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800582:	eb a6                	jmp    80052a <vprintfmt+0x176>
					putch(ch, putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	56                   	push   %esi
  800588:	52                   	push   %edx
  800589:	ff d3                	call   *%ebx
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800591:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800593:	83 c7 01             	add    $0x1,%edi
  800596:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059a:	0f be d0             	movsbl %al,%edx
  80059d:	85 d2                	test   %edx,%edx
  80059f:	74 42                	je     8005e3 <vprintfmt+0x22f>
  8005a1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a5:	78 06                	js     8005ad <vprintfmt+0x1f9>
  8005a7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ab:	78 1e                	js     8005cb <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b1:	74 d1                	je     800584 <vprintfmt+0x1d0>
  8005b3:	0f be c0             	movsbl %al,%eax
  8005b6:	83 e8 20             	sub    $0x20,%eax
  8005b9:	83 f8 5e             	cmp    $0x5e,%eax
  8005bc:	76 c6                	jbe    800584 <vprintfmt+0x1d0>
					putch('?', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	6a 3f                	push   $0x3f
  8005c4:	ff d3                	call   *%ebx
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	eb c3                	jmp    80058e <vprintfmt+0x1da>
  8005cb:	89 cf                	mov    %ecx,%edi
  8005cd:	eb 0e                	jmp    8005dd <vprintfmt+0x229>
				putch(' ', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	56                   	push   %esi
  8005d3:	6a 20                	push   $0x20
  8005d5:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005d7:	83 ef 01             	sub    $0x1,%edi
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	7f ee                	jg     8005cf <vprintfmt+0x21b>
  8005e1:	eb 6f                	jmp    800652 <vprintfmt+0x29e>
  8005e3:	89 cf                	mov    %ecx,%edi
  8005e5:	eb f6                	jmp    8005dd <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005e7:	89 ca                	mov    %ecx,%edx
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 55 fd ff ff       	call   800346 <getint>
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	78 0b                	js     800606 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005fb:	89 d1                	mov    %edx,%ecx
  8005fd:	89 c2                	mov    %eax,%edx
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	eb 32                	jmp    800638 <vprintfmt+0x284>
				putch('-', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	56                   	push   %esi
  80060a:	6a 2d                	push   $0x2d
  80060c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80060e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800611:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800614:	f7 da                	neg    %edx
  800616:	83 d1 00             	adc    $0x0,%ecx
  800619:	f7 d9                	neg    %ecx
  80061b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80061e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800623:	eb 13                	jmp    800638 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800625:	89 ca                	mov    %ecx,%edx
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 e3 fc ff ff       	call   800312 <getuint>
  80062f:	89 d1                	mov    %edx,%ecx
  800631:	89 c2                	mov    %eax,%edx
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80063f:	57                   	push   %edi
  800640:	ff 75 e0             	pushl  -0x20(%ebp)
  800643:	50                   	push   %eax
  800644:	51                   	push   %ecx
  800645:	52                   	push   %edx
  800646:	89 f2                	mov    %esi,%edx
  800648:	89 d8                	mov    %ebx,%eax
  80064a:	e8 1a fc ff ff       	call   800269 <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
{
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800655:	83 c7 01             	add    $0x1,%edi
  800658:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065c:	83 f8 25             	cmp    $0x25,%eax
  80065f:	0f 84 6a fd ff ff    	je     8003cf <vprintfmt+0x1b>
			if (ch == '\0')
  800665:	85 c0                	test   %eax,%eax
  800667:	0f 84 93 00 00 00    	je     800700 <vprintfmt+0x34c>
			putch(ch, putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	56                   	push   %esi
  800671:	50                   	push   %eax
  800672:	ff d3                	call   *%ebx
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	eb dc                	jmp    800655 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 8f fc ff ff       	call   800312 <getuint>
  800683:	89 d1                	mov    %edx,%ecx
  800685:	89 c2                	mov    %eax,%edx
			base = 8;
  800687:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80068c:	eb aa                	jmp    800638 <vprintfmt+0x284>
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	56                   	push   %esi
  800692:	6a 30                	push   $0x30
  800694:	ff d3                	call   *%ebx
			putch('x', putdat);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	56                   	push   %esi
  80069a:	6a 78                	push   $0x78
  80069c:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ae:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b6:	eb 80                	jmp    800638 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006b8:	89 ca                	mov    %ecx,%edx
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bd:	e8 50 fc ff ff       	call   800312 <getuint>
  8006c2:	89 d1                	mov    %edx,%ecx
  8006c4:	89 c2                	mov    %eax,%edx
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cb:	e9 68 ff ff ff       	jmp    800638 <vprintfmt+0x284>
			putch(ch, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	56                   	push   %esi
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d3                	call   *%ebx
			break;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	e9 72 ff ff ff       	jmp    800652 <vprintfmt+0x29e>
			putch('%', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	56                   	push   %esi
  8006e4:	6a 25                	push   $0x25
  8006e6:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	89 f8                	mov    %edi,%eax
  8006ed:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f1:	74 05                	je     8006f8 <vprintfmt+0x344>
  8006f3:	83 e8 01             	sub    $0x1,%eax
  8006f6:	eb f5                	jmp    8006ed <vprintfmt+0x339>
  8006f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fb:	e9 52 ff ff ff       	jmp    800652 <vprintfmt+0x29e>
}
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	f3 0f 1e fb          	endbr32 
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	83 ec 18             	sub    $0x18,%esp
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800718:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 26                	je     800753 <vsnprintf+0x4b>
  80072d:	85 d2                	test   %edx,%edx
  80072f:	7e 22                	jle    800753 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800731:	ff 75 14             	pushl  0x14(%ebp)
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073a:	50                   	push   %eax
  80073b:	68 72 03 80 00       	push   $0x800372
  800740:	e8 6f fc ff ff       	call   8003b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800745:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800748:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074e:	83 c4 10             	add    $0x10,%esp
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    
		return -E_INVAL;
  800753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800758:	eb f7                	jmp    800751 <vsnprintf+0x49>

0080075a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075a:	f3 0f 1e fb          	endbr32 
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800767:	50                   	push   %eax
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	ff 75 08             	pushl  0x8(%ebp)
  800771:	e8 92 ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	f3 0f 1e fb          	endbr32 
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078b:	74 05                	je     800792 <strlen+0x1a>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	eb f5                	jmp    800787 <strlen+0xf>
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	39 d0                	cmp    %edx,%eax
  8007a8:	74 0d                	je     8007b7 <strnlen+0x23>
  8007aa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ae:	74 05                	je     8007b5 <strnlen+0x21>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
  8007b3:	eb f1                	jmp    8007a6 <strnlen+0x12>
  8007b5:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b7:	89 d0                	mov    %edx,%eax
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ce:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d5:	83 c0 01             	add    $0x1,%eax
  8007d8:	84 d2                	test   %dl,%dl
  8007da:	75 f2                	jne    8007ce <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007dc:	89 c8                	mov    %ecx,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e1:	f3 0f 1e fb          	endbr32 
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 10             	sub    $0x10,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ef:	53                   	push   %ebx
  8007f0:	e8 83 ff ff ff       	call   800778 <strlen>
  8007f5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	01 d8                	add    %ebx,%eax
  8007fd:	50                   	push   %eax
  8007fe:	e8 b8 ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  800803:	89 d8                	mov    %ebx,%eax
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080a:	f3 0f 1e fb          	endbr32 
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 f3                	mov    %esi,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	89 f0                	mov    %esi,%eax
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 11                	je     800835 <strncpy+0x2b>
		*dst++ = *src;
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	0f b6 0a             	movzbl (%edx),%ecx
  80082a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082d:	80 f9 01             	cmp    $0x1,%cl
  800830:	83 da ff             	sbb    $0xffffffff,%edx
  800833:	eb eb                	jmp    800820 <strncpy+0x16>
	}
	return ret;
}
  800835:	89 f0                	mov    %esi,%eax
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	f3 0f 1e fb          	endbr32 
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084a:	8b 55 10             	mov    0x10(%ebp),%edx
  80084d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	85 d2                	test   %edx,%edx
  800851:	74 21                	je     800874 <strlcpy+0x39>
  800853:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800857:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800859:	39 c2                	cmp    %eax,%edx
  80085b:	74 14                	je     800871 <strlcpy+0x36>
  80085d:	0f b6 19             	movzbl (%ecx),%ebx
  800860:	84 db                	test   %bl,%bl
  800862:	74 0b                	je     80086f <strlcpy+0x34>
			*dst++ = *src++;
  800864:	83 c1 01             	add    $0x1,%ecx
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086d:	eb ea                	jmp    800859 <strlcpy+0x1e>
  80086f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	f3 0f 1e fb          	endbr32 
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	84 c0                	test   %al,%al
  80088c:	74 0c                	je     80089a <strcmp+0x20>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	75 08                	jne    80089a <strcmp+0x20>
		p++, q++;
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	83 c2 01             	add    $0x1,%edx
  800898:	eb ed                	jmp    800887 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	f3 0f 1e fb          	endbr32 
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x1b>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 16                	je     8008d9 <strncmp+0x35>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x2a>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    
		return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	eb f6                	jmp    8008d6 <strncmp+0x32>

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	74 09                	je     8008fe <strchr+0x1e>
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 0a                	je     800903 <strchr+0x23>
	for (; *s; s++)
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	eb f0                	jmp    8008ee <strchr+0xe>
			return (char *) s;
	return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800905:	f3 0f 1e fb          	endbr32 
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 09                	je     800923 <strfind+0x1e>
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 05                	je     800923 <strfind+0x1e>
	for (; *s; s++)
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	eb f0                	jmp    800913 <strfind+0xe>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	f3 0f 1e fb          	endbr32 
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 55 08             	mov    0x8(%ebp),%edx
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 33                	je     80096c <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	89 d0                	mov    %edx,%eax
  80093b:	09 c8                	or     %ecx,%eax
  80093d:	a8 03                	test   $0x3,%al
  80093f:	75 23                	jne    800964 <memset+0x3f>
		c &= 0xFF;
  800941:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800945:	89 d8                	mov    %ebx,%eax
  800947:	c1 e0 08             	shl    $0x8,%eax
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	c1 e7 18             	shl    $0x18,%edi
  80094f:	89 de                	mov    %ebx,%esi
  800951:	c1 e6 10             	shl    $0x10,%esi
  800954:	09 f7                	or     %esi,%edi
  800956:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80095d:	89 d7                	mov    %edx,%edi
  80095f:	fc                   	cld    
  800960:	f3 ab                	rep stos %eax,%es:(%edi)
  800962:	eb 08                	jmp    80096c <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800964:	89 d7                	mov    %edx,%edi
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800973:	f3 0f 1e fb          	endbr32 
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 32                	jae    8009bb <memmove+0x48>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	76 2b                	jbe    8009bb <memmove+0x48>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 fe                	mov    %edi,%esi
  800995:	09 ce                	or     %ecx,%esi
  800997:	09 d6                	or     %edx,%esi
  800999:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099f:	75 0e                	jne    8009af <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 09                	jmp    8009b8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	83 ef 01             	sub    $0x1,%edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 1a                	jmp    8009d5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	09 ca                	or     %ecx,%edx
  8009bf:	09 f2                	or     %esi,%edx
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 0a                	jne    8009d0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 05                	jmp    8009d5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d9:	f3 0f 1e fb          	endbr32 
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e3:	ff 75 10             	pushl  0x10(%ebp)
  8009e6:	ff 75 0c             	pushl  0xc(%ebp)
  8009e9:	ff 75 08             	pushl  0x8(%ebp)
  8009ec:	e8 82 ff ff ff       	call   800973 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	f3 0f 1e fb          	endbr32 
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	39 f0                	cmp    %esi,%eax
  800a09:	74 1c                	je     800a27 <memcmp+0x34>
		if (*s1 != *s2)
  800a0b:	0f b6 08             	movzbl (%eax),%ecx
  800a0e:	0f b6 1a             	movzbl (%edx),%ebx
  800a11:	38 d9                	cmp    %bl,%cl
  800a13:	75 08                	jne    800a1d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	eb ea                	jmp    800a07 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c1             	movzbl %cl,%eax
  800a20:	0f b6 db             	movzbl %bl,%ebx
  800a23:	29 d8                	sub    %ebx,%eax
  800a25:	eb 05                	jmp    800a2c <memcmp+0x39>
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	f3 0f 1e fb          	endbr32 
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	73 09                	jae    800a4f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	38 08                	cmp    %cl,(%eax)
  800a48:	74 05                	je     800a4f <memfind+0x1f>
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	eb f3                	jmp    800a42 <memfind+0x12>
			break;
	return (void *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	eb 03                	jmp    800a66 <strtol+0x15>
		s++;
  800a63:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a66:	0f b6 01             	movzbl (%ecx),%eax
  800a69:	3c 20                	cmp    $0x20,%al
  800a6b:	74 f6                	je     800a63 <strtol+0x12>
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	74 f2                	je     800a63 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a71:	3c 2b                	cmp    $0x2b,%al
  800a73:	74 2a                	je     800a9f <strtol+0x4e>
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7a:	3c 2d                	cmp    $0x2d,%al
  800a7c:	74 2b                	je     800aa9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a84:	75 0f                	jne    800a95 <strtol+0x44>
  800a86:	80 39 30             	cmpb   $0x30,(%ecx)
  800a89:	74 28                	je     800ab3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a92:	0f 44 d8             	cmove  %eax,%ebx
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9d:	eb 46                	jmp    800ae5 <strtol+0x94>
		s++;
  800a9f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb d5                	jmp    800a7e <strtol+0x2d>
		s++, neg = 1;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb cb                	jmp    800a7e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab7:	74 0e                	je     800ac7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 d8                	jne    800a95 <strtol+0x44>
		s++, base = 8;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac5:	eb ce                	jmp    800a95 <strtol+0x44>
		s += 2, base = 16;
  800ac7:	83 c1 02             	add    $0x2,%ecx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb c4                	jmp    800a95 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ada:	7d 3a                	jge    800b16 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae5:	0f b6 11             	movzbl (%ecx),%edx
  800ae8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 09             	cmp    $0x9,%bl
  800af0:	76 df                	jbe    800ad1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 57             	sub    $0x57,%edx
  800b02:	eb d3                	jmp    800ad7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 37             	sub    $0x37,%edx
  800b14:	eb c1                	jmp    800ad7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xd0>
		*endptr = (char *) s;
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	f7 da                	neg    %edx
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c2             	cmovne %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 1c             	sub    $0x1c,%esp
  800b38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b3b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b3e:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b46:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b49:	8b 75 14             	mov    0x14(%ebp),%esi
  800b4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b52:	74 04                	je     800b58 <syscall+0x29>
  800b54:	85 c0                	test   %eax,%eax
  800b56:	7f 08                	jg     800b60 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	ff 75 e0             	pushl  -0x20(%ebp)
  800b67:	68 9f 27 80 00       	push   $0x80279f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 bc 27 80 00       	push   $0x8027bc
  800b73:	e8 f2 f5 ff ff       	call   80016a <_panic>

00800b78 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b78:	f3 0f 1e fb          	endbr32 
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	ff 75 0c             	pushl  0xc(%ebp)
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	e8 92 ff ff ff       	call   800b2f <syscall>
}
  800b9d:	83 c4 10             	add    $0x10,%esp
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bac:	6a 00                	push   $0x0
  800bae:	6a 00                	push   $0x0
  800bb0:	6a 00                	push   $0x0
  800bb2:	6a 00                	push   $0x0
  800bb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc3:	e8 67 ff ff ff       	call   800b2f <syscall>
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bd4:	6a 00                	push   $0x0
  800bd6:	6a 00                	push   $0x0
  800bd8:	6a 00                	push   $0x0
  800bda:	6a 00                	push   $0x0
  800bdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdf:	ba 01 00 00 00       	mov    $0x1,%edx
  800be4:	b8 03 00 00 00       	mov    $0x3,%eax
  800be9:	e8 41 ff ff ff       	call   800b2f <syscall>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	6a 00                	push   $0x0
  800c00:	6a 00                	push   $0x0
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c11:	e8 19 ff ff ff       	call   800b2f <syscall>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_yield>:

void
sys_yield(void)
{
  800c18:	f3 0f 1e fb          	endbr32 
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c22:	6a 00                	push   $0x0
  800c24:	6a 00                	push   $0x0
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c39:	e8 f1 fe ff ff       	call   800b2f <syscall>
}
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c43:	f3 0f 1e fb          	endbr32 
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	ff 75 10             	pushl  0x10(%ebp)
  800c54:	ff 75 0c             	pushl  0xc(%ebp)
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c64:	e8 c6 fe ff ff       	call   800b2f <syscall>
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6b:	f3 0f 1e fb          	endbr32 
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c75:	ff 75 18             	pushl  0x18(%ebp)
  800c78:	ff 75 14             	pushl  0x14(%ebp)
  800c7b:	ff 75 10             	pushl  0x10(%ebp)
  800c7e:	ff 75 0c             	pushl  0xc(%ebp)
  800c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c84:	ba 01 00 00 00       	mov    $0x1,%edx
  800c89:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8e:	e8 9c fe ff ff       	call   800b2f <syscall>
}
  800c93:	c9                   	leave  
  800c94:	c3                   	ret    

00800c95 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c95:	f3 0f 1e fb          	endbr32 
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb5:	e8 75 fe ff ff       	call   800b2f <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdc:	e8 4e fe ff ff       	call   800b2f <syscall>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce3:	f3 0f 1e fb          	endbr32 
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800d03:	e8 27 fe ff ff       	call   800b2f <syscall>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0a:	f3 0f 1e fb          	endbr32 
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d14:	6a 00                	push   $0x0
  800d16:	6a 00                	push   $0x0
  800d18:	6a 00                	push   $0x0
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	ba 01 00 00 00       	mov    $0x1,%edx
  800d25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2a:	e8 00 fe ff ff       	call   800b2f <syscall>
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d31:	f3 0f 1e fb          	endbr32 
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d3b:	6a 00                	push   $0x0
  800d3d:	ff 75 14             	pushl  0x14(%ebp)
  800d40:	ff 75 10             	pushl  0x10(%ebp)
  800d43:	ff 75 0c             	pushl  0xc(%ebp)
  800d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d49:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d53:	e8 d7 fd ff ff       	call   800b2f <syscall>
}
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d64:	6a 00                	push   $0x0
  800d66:	6a 00                	push   $0x0
  800d68:	6a 00                	push   $0x0
  800d6a:	6a 00                	push   $0x0
  800d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d74:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d79:	e8 b1 fd ff ff       	call   800b2f <syscall>
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800d89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800d90:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800d93:	f6 c6 04             	test   $0x4,%dh
  800d96:	75 54                	jne    800dec <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800d98:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d9e:	0f 84 8d 00 00 00    	je     800e31 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	68 05 08 00 00       	push   $0x805
  800dac:	53                   	push   %ebx
  800dad:	50                   	push   %eax
  800dae:	53                   	push   %ebx
  800daf:	6a 00                	push   $0x0
  800db1:	e8 b5 fe ff ff       	call   800c6b <sys_page_map>
		if (r < 0)
  800db6:	83 c4 20             	add    $0x20,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	78 5f                	js     800e1c <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	68 05 08 00 00       	push   $0x805
  800dc5:	53                   	push   %ebx
  800dc6:	6a 00                	push   $0x0
  800dc8:	53                   	push   %ebx
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 9b fe ff ff       	call   800c6b <sys_page_map>
		if (r < 0)
  800dd0:	83 c4 20             	add    $0x20,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	79 70                	jns    800e47 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dd7:	50                   	push   %eax
  800dd8:	68 cc 27 80 00       	push   $0x8027cc
  800ddd:	68 9b 00 00 00       	push   $0x9b
  800de2:	68 3a 29 80 00       	push   $0x80293a
  800de7:	e8 7e f3 ff ff       	call   80016a <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800df5:	52                   	push   %edx
  800df6:	53                   	push   %ebx
  800df7:	50                   	push   %eax
  800df8:	53                   	push   %ebx
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 6b fe ff ff       	call   800c6b <sys_page_map>
		if (r < 0)
  800e00:	83 c4 20             	add    $0x20,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 40                	jns    800e47 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e07:	50                   	push   %eax
  800e08:	68 cc 27 80 00       	push   $0x8027cc
  800e0d:	68 92 00 00 00       	push   $0x92
  800e12:	68 3a 29 80 00       	push   $0x80293a
  800e17:	e8 4e f3 ff ff       	call   80016a <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e1c:	50                   	push   %eax
  800e1d:	68 cc 27 80 00       	push   $0x8027cc
  800e22:	68 97 00 00 00       	push   $0x97
  800e27:	68 3a 29 80 00       	push   $0x80293a
  800e2c:	e8 39 f3 ff ff       	call   80016a <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	6a 05                	push   $0x5
  800e36:	53                   	push   %ebx
  800e37:	50                   	push   %eax
  800e38:	53                   	push   %ebx
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 2b fe ff ff       	call   800c6b <sys_page_map>
		if (r < 0)
  800e40:	83 c4 20             	add    $0x20,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 0a                	js     800e51 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800e47:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e51:	50                   	push   %eax
  800e52:	68 cc 27 80 00       	push   $0x8027cc
  800e57:	68 a0 00 00 00       	push   $0xa0
  800e5c:	68 3a 29 80 00       	push   $0x80293a
  800e61:	e8 04 f3 ff ff       	call   80016a <_panic>

00800e66 <dup_or_share>:
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	89 c7                	mov    %eax,%edi
  800e71:	89 d6                	mov    %edx,%esi
  800e73:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800e75:	f6 c1 02             	test   $0x2,%cl
  800e78:	0f 84 90 00 00 00    	je     800f0e <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	51                   	push   %ecx
  800e82:	52                   	push   %edx
  800e83:	50                   	push   %eax
  800e84:	e8 ba fd ff ff       	call   800c43 <sys_page_alloc>
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	78 56                	js     800ee6 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	53                   	push   %ebx
  800e94:	68 00 00 40 00       	push   $0x400000
  800e99:	6a 00                	push   $0x0
  800e9b:	56                   	push   %esi
  800e9c:	57                   	push   %edi
  800e9d:	e8 c9 fd ff ff       	call   800c6b <sys_page_map>
  800ea2:	83 c4 20             	add    $0x20,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 51                	js     800efa <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 00 10 00 00       	push   $0x1000
  800eb1:	56                   	push   %esi
  800eb2:	68 00 00 40 00       	push   $0x400000
  800eb7:	e8 b7 fa ff ff       	call   800973 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800ebc:	83 c4 08             	add    $0x8,%esp
  800ebf:	68 00 00 40 00       	push   $0x400000
  800ec4:	6a 00                	push   $0x0
  800ec6:	e8 ca fd ff ff       	call   800c95 <sys_page_unmap>
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	79 51                	jns    800f23 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	68 3c 28 80 00       	push   $0x80283c
  800eda:	6a 18                	push   $0x18
  800edc:	68 3a 29 80 00       	push   $0x80293a
  800ee1:	e8 84 f2 ff ff       	call   80016a <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800ee6:	83 ec 04             	sub    $0x4,%esp
  800ee9:	68 f0 27 80 00       	push   $0x8027f0
  800eee:	6a 13                	push   $0x13
  800ef0:	68 3a 29 80 00       	push   $0x80293a
  800ef5:	e8 70 f2 ff ff       	call   80016a <_panic>
			panic("sys_page_map failed at dup_or_share");
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	68 18 28 80 00       	push   $0x802818
  800f02:	6a 15                	push   $0x15
  800f04:	68 3a 29 80 00       	push   $0x80293a
  800f09:	e8 5c f2 ff ff       	call   80016a <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	51                   	push   %ecx
  800f12:	52                   	push   %edx
  800f13:	50                   	push   %eax
  800f14:	52                   	push   %edx
  800f15:	6a 00                	push   $0x0
  800f17:	e8 4f fd ff ff       	call   800c6b <sys_page_map>
  800f1c:	83 c4 20             	add    $0x20,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	78 08                	js     800f2b <dup_or_share+0xc5>
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 18 28 80 00       	push   $0x802818
  800f33:	6a 1c                	push   $0x1c
  800f35:	68 3a 29 80 00       	push   $0x80293a
  800f3a:	e8 2b f2 ff ff       	call   80016a <_panic>

00800f3f <pgfault>:
{
  800f3f:	f3 0f 1e fb          	endbr32 
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	53                   	push   %ebx
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f4d:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800f4f:	89 da                	mov    %ebx,%edx
  800f51:	c1 ea 0c             	shr    $0xc,%edx
  800f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800f5b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5f:	74 6e                	je     800fcf <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800f61:	f6 c6 08             	test   $0x8,%dh
  800f64:	74 7d                	je     800fe3 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	6a 07                	push   $0x7
  800f6b:	68 00 f0 7f 00       	push   $0x7ff000
  800f70:	6a 00                	push   $0x0
  800f72:	e8 cc fc ff ff       	call   800c43 <sys_page_alloc>
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 79                	js     800ff7 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f7e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	68 00 10 00 00       	push   $0x1000
  800f8c:	53                   	push   %ebx
  800f8d:	68 00 f0 7f 00       	push   $0x7ff000
  800f92:	e8 dc f9 ff ff       	call   800973 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  800f97:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f9e:	53                   	push   %ebx
  800f9f:	6a 00                	push   $0x0
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 be fc ff ff       	call   800c6b <sys_page_map>
  800fad:	83 c4 20             	add    $0x20,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 57                	js     80100b <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 d2 fc ff ff       	call   800c95 <sys_page_unmap>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 55                	js     80101f <pgfault+0xe0>
}
  800fca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 45 29 80 00       	push   $0x802945
  800fd7:	6a 5e                	push   $0x5e
  800fd9:	68 3a 29 80 00       	push   $0x80293a
  800fde:	e8 87 f1 ff ff       	call   80016a <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	68 64 28 80 00       	push   $0x802864
  800feb:	6a 62                	push   $0x62
  800fed:	68 3a 29 80 00       	push   $0x80293a
  800ff2:	e8 73 f1 ff ff       	call   80016a <_panic>
		panic("pgfault failed");
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 5d 29 80 00       	push   $0x80295d
  800fff:	6a 6d                	push   $0x6d
  801001:	68 3a 29 80 00       	push   $0x80293a
  801006:	e8 5f f1 ff ff       	call   80016a <_panic>
		panic("pgfault failed");
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	68 5d 29 80 00       	push   $0x80295d
  801013:	6a 72                	push   $0x72
  801015:	68 3a 29 80 00       	push   $0x80293a
  80101a:	e8 4b f1 ff ff       	call   80016a <_panic>
		panic("pgfault failed");
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 5d 29 80 00       	push   $0x80295d
  801027:	6a 74                	push   $0x74
  801029:	68 3a 29 80 00       	push   $0x80293a
  80102e:	e8 37 f1 ff ff       	call   80016a <_panic>

00801033 <fork_v0>:
{
  801033:	f3 0f 1e fb          	endbr32 
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801040:	b8 07 00 00 00       	mov    $0x7,%eax
  801045:	cd 30                	int    $0x30
  801047:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80104a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 1d                	js     80106e <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801051:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801056:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80105a:	74 26                	je     801082 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  80105c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801061:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  801067:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  80106c:	eb 4b                	jmp    8010b9 <fork_v0+0x86>
		panic("sys_exofork failed");
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	68 6c 29 80 00       	push   $0x80296c
  801076:	6a 2b                	push   $0x2b
  801078:	68 3a 29 80 00       	push   $0x80293a
  80107d:	e8 e8 f0 ff ff       	call   80016a <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801082:	e8 69 fb ff ff       	call   800bf0 <sys_getenvid>
  801087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80108f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801094:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801099:	eb 68                	jmp    801103 <fork_v0+0xd0>
				dup_or_share(envid,
  80109b:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010a1:	89 da                	mov    %ebx,%edx
  8010a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a6:	e8 bb fd ff ff       	call   800e66 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  8010ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b1:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010b7:	74 36                	je     8010ef <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	c1 e8 16             	shr    $0x16,%eax
  8010be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010c5:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  8010c7:	f6 02 01             	testb  $0x1,(%edx)
  8010ca:	74 df                	je     8010ab <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  8010cc:	89 da                	mov    %ebx,%edx
  8010ce:	c1 ea 0a             	shr    $0xa,%edx
  8010d1:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8010d7:	c1 e0 0c             	shl    $0xc,%eax
  8010da:	89 f9                	mov    %edi,%ecx
  8010dc:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  8010e2:	09 c8                	or     %ecx,%eax
  8010e4:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  8010e6:	8b 08                	mov    (%eax),%ecx
  8010e8:	f6 c1 01             	test   $0x1,%cl
  8010eb:	74 be                	je     8010ab <fork_v0+0x78>
  8010ed:	eb ac                	jmp    80109b <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	6a 02                	push   $0x2
  8010f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f7:	e8 c0 fb ff ff       	call   800cbc <sys_env_set_status>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 0b                	js     80110e <fork_v0+0xdb>
}
  801103:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5f                   	pop    %edi
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	68 84 28 80 00       	push   $0x802884
  801116:	6a 43                	push   $0x43
  801118:	68 3a 29 80 00       	push   $0x80293a
  80111d:	e8 48 f0 ff ff       	call   80016a <_panic>

00801122 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801122:	f3 0f 1e fb          	endbr32 
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  80112f:	68 3f 0f 80 00       	push   $0x800f3f
  801134:	e8 e3 0f 00 00       	call   80211c <set_pgfault_handler>
  801139:	b8 07 00 00 00       	mov    $0x7,%eax
  80113e:	cd 30                	int    $0x30
  801140:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 2f                	js     801179 <fork+0x57>
  80114a:	89 c7                	mov    %eax,%edi
  80114c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  801153:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801157:	0f 85 9e 00 00 00    	jne    8011fb <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  80115d:	e8 8e fa ff ff       	call   800bf0 <sys_getenvid>
  801162:	25 ff 03 00 00       	and    $0x3ff,%eax
  801167:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80116f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801174:	e9 de 00 00 00       	jmp    801257 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  801179:	50                   	push   %eax
  80117a:	68 ac 28 80 00       	push   $0x8028ac
  80117f:	68 c2 00 00 00       	push   $0xc2
  801184:	68 3a 29 80 00       	push   $0x80293a
  801189:	e8 dc ef ff ff       	call   80016a <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	6a 07                	push   $0x7
  801193:	68 00 f0 bf ee       	push   $0xeebff000
  801198:	57                   	push   %edi
  801199:	e8 a5 fa ff ff       	call   800c43 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	75 33                	jne    8011d8 <fork+0xb6>
  8011a5:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  8011a8:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8011ae:	74 3d                	je     8011ed <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  8011b0:	89 d8                	mov    %ebx,%eax
  8011b2:	c1 e0 0c             	shl    $0xc,%eax
  8011b5:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	c1 ea 0c             	shr    $0xc,%edx
  8011bc:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  8011c3:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  8011c8:	74 c4                	je     80118e <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  8011ca:	f6 c1 01             	test   $0x1,%cl
  8011cd:	74 d6                	je     8011a5 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  8011cf:	89 f8                	mov    %edi,%eax
  8011d1:	e8 aa fb ff ff       	call   800d80 <duppage>
  8011d6:	eb cd                	jmp    8011a5 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  8011d8:	50                   	push   %eax
  8011d9:	68 cc 28 80 00       	push   $0x8028cc
  8011de:	68 e1 00 00 00       	push   $0xe1
  8011e3:	68 3a 29 80 00       	push   $0x80293a
  8011e8:	e8 7d ef ff ff       	call   80016a <_panic>
  8011ed:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8011f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8011f4:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8011f9:	74 18                	je     801213 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8011fb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011fe:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  801205:	a8 01                	test   $0x1,%al
  801207:	74 e4                	je     8011ed <fork+0xcb>
  801209:	c1 e6 16             	shl    $0x16,%esi
  80120c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801211:	eb 9d                	jmp    8011b0 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	6a 07                	push   $0x7
  801218:	68 00 f0 bf ee       	push   $0xeebff000
  80121d:	ff 75 e0             	pushl  -0x20(%ebp)
  801220:	e8 1e fa ff ff       	call   800c43 <sys_page_alloc>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 36                	js     801262 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	68 77 21 80 00       	push   $0x802177
  801234:	ff 75 e0             	pushl  -0x20(%ebp)
  801237:	e8 ce fa ff ff       	call   800d0a <sys_env_set_pgfault_upcall>
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 36                	js     801279 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	6a 02                	push   $0x2
  801248:	ff 75 e0             	pushl  -0x20(%ebp)
  80124b:	e8 6c fa ff ff       	call   800cbc <sys_env_set_status>
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 39                	js     801290 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  801257:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	68 7f 29 80 00       	push   $0x80297f
  80126a:	68 f4 00 00 00       	push   $0xf4
  80126f:	68 3a 29 80 00       	push   $0x80293a
  801274:	e8 f1 ee ff ff       	call   80016a <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	68 f0 28 80 00       	push   $0x8028f0
  801281:	68 f8 00 00 00       	push   $0xf8
  801286:	68 3a 29 80 00       	push   $0x80293a
  80128b:	e8 da ee ff ff       	call   80016a <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801290:	50                   	push   %eax
  801291:	68 14 29 80 00       	push   $0x802914
  801296:	68 fc 00 00 00       	push   $0xfc
  80129b:	68 3a 29 80 00       	push   $0x80293a
  8012a0:	e8 c5 ee ff ff       	call   80016a <_panic>

008012a5 <sfork>:

// Challenge!
int
sfork(void)
{
  8012a5:	f3 0f 1e fb          	endbr32 
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012af:	68 97 29 80 00       	push   $0x802997
  8012b4:	68 05 01 00 00       	push   $0x105
  8012b9:	68 3a 29 80 00       	push   $0x80293a
  8012be:	e8 a7 ee ff ff       	call   80016a <_panic>

008012c3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012c3:	f3 0f 1e fb          	endbr32 
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	56                   	push   %esi
  8012cb:	53                   	push   %ebx
  8012cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012dc:	0f 44 c2             	cmove  %edx,%eax
  8012df:	83 ec 0c             	sub    $0xc,%esp
  8012e2:	50                   	push   %eax
  8012e3:	e8 72 fa ff ff       	call   800d5a <sys_ipc_recv>

	if (from_env_store != NULL)
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 f6                	test   %esi,%esi
  8012ed:	74 15                	je     801304 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8012ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f4:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8012f7:	74 09                	je     801302 <ipc_recv+0x3f>
  8012f9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012ff:	8b 52 74             	mov    0x74(%edx),%edx
  801302:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801304:	85 db                	test   %ebx,%ebx
  801306:	74 15                	je     80131d <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801308:	ba 00 00 00 00       	mov    $0x0,%edx
  80130d:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801310:	74 09                	je     80131b <ipc_recv+0x58>
  801312:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801318:	8b 52 78             	mov    0x78(%edx),%edx
  80131b:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  80131d:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801320:	74 08                	je     80132a <ipc_recv+0x67>
  801322:	a1 04 40 80 00       	mov    0x804004,%eax
  801327:	8b 40 70             	mov    0x70(%eax),%eax
}
  80132a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801331:	f3 0f 1e fb          	endbr32 
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	57                   	push   %edi
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801341:	8b 75 0c             	mov    0xc(%ebp),%esi
  801344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801347:	eb 1f                	jmp    801368 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801349:	6a 00                	push   $0x0
  80134b:	68 00 00 c0 ee       	push   $0xeec00000
  801350:	56                   	push   %esi
  801351:	57                   	push   %edi
  801352:	e8 da f9 ff ff       	call   800d31 <sys_ipc_try_send>
  801357:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  80135a:	85 c0                	test   %eax,%eax
  80135c:	74 30                	je     80138e <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  80135e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801361:	75 19                	jne    80137c <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801363:	e8 b0 f8 ff ff       	call   800c18 <sys_yield>
		if (pg != NULL) {
  801368:	85 db                	test   %ebx,%ebx
  80136a:	74 dd                	je     801349 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  80136c:	ff 75 14             	pushl  0x14(%ebp)
  80136f:	53                   	push   %ebx
  801370:	56                   	push   %esi
  801371:	57                   	push   %edi
  801372:	e8 ba f9 ff ff       	call   800d31 <sys_ipc_try_send>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	eb de                	jmp    80135a <ipc_send+0x29>
			panic("ipc_send: %d", res);
  80137c:	50                   	push   %eax
  80137d:	68 ad 29 80 00       	push   $0x8029ad
  801382:	6a 3e                	push   $0x3e
  801384:	68 ba 29 80 00       	push   $0x8029ba
  801389:	e8 dc ed ff ff       	call   80016a <_panic>
	}
}
  80138e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5f                   	pop    %edi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801396:	f3 0f 1e fb          	endbr32 
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013a5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013a8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013ae:	8b 52 50             	mov    0x50(%edx),%edx
  8013b1:	39 ca                	cmp    %ecx,%edx
  8013b3:	74 11                	je     8013c6 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8013b5:	83 c0 01             	add    $0x1,%eax
  8013b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013bd:	75 e6                	jne    8013a5 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c4:	eb 0b                	jmp    8013d1 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8013c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013ce:	8b 40 48             	mov    0x48(%eax),%eax
}
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    

008013d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013d3:	f3 0f 1e fb          	endbr32 
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e2:	c1 e8 0c             	shr    $0xc,%eax
}
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013e7:	f3 0f 1e fb          	endbr32 
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8013f1:	ff 75 08             	pushl  0x8(%ebp)
  8013f4:	e8 da ff ff ff       	call   8013d3 <fd2num>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	c1 e0 0c             	shl    $0xc,%eax
  8013ff:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801406:	f3 0f 1e fb          	endbr32 
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801412:	89 c2                	mov    %eax,%edx
  801414:	c1 ea 16             	shr    $0x16,%edx
  801417:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141e:	f6 c2 01             	test   $0x1,%dl
  801421:	74 2d                	je     801450 <fd_alloc+0x4a>
  801423:	89 c2                	mov    %eax,%edx
  801425:	c1 ea 0c             	shr    $0xc,%edx
  801428:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142f:	f6 c2 01             	test   $0x1,%dl
  801432:	74 1c                	je     801450 <fd_alloc+0x4a>
  801434:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801439:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80143e:	75 d2                	jne    801412 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801440:	8b 45 08             	mov    0x8(%ebp),%eax
  801443:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801449:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80144e:	eb 0a                	jmp    80145a <fd_alloc+0x54>
			*fd_store = fd;
  801450:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801453:	89 01                	mov    %eax,(%ecx)
			return 0;
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145c:	f3 0f 1e fb          	endbr32 
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801466:	83 f8 1f             	cmp    $0x1f,%eax
  801469:	77 30                	ja     80149b <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80146b:	c1 e0 0c             	shl    $0xc,%eax
  80146e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801473:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801479:	f6 c2 01             	test   $0x1,%dl
  80147c:	74 24                	je     8014a2 <fd_lookup+0x46>
  80147e:	89 c2                	mov    %eax,%edx
  801480:	c1 ea 0c             	shr    $0xc,%edx
  801483:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	74 1a                	je     8014a9 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80148f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801492:	89 02                	mov    %eax,(%edx)
	return 0;
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
		return -E_INVAL;
  80149b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a0:	eb f7                	jmp    801499 <fd_lookup+0x3d>
		return -E_INVAL;
  8014a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a7:	eb f0                	jmp    801499 <fd_lookup+0x3d>
  8014a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ae:	eb e9                	jmp    801499 <fd_lookup+0x3d>

008014b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b0:	f3 0f 1e fb          	endbr32 
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bd:	ba 40 2a 80 00       	mov    $0x802a40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c2:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8014c7:	39 08                	cmp    %ecx,(%eax)
  8014c9:	74 33                	je     8014fe <dev_lookup+0x4e>
  8014cb:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8014ce:	8b 02                	mov    (%edx),%eax
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	75 f3                	jne    8014c7 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d9:	8b 40 48             	mov    0x48(%eax),%eax
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	51                   	push   %ecx
  8014e0:	50                   	push   %eax
  8014e1:	68 c4 29 80 00       	push   $0x8029c4
  8014e6:	e8 66 ed ff ff       	call   800251 <cprintf>
	*dev = 0;
  8014eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    
			*dev = devtab[i];
  8014fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801501:	89 01                	mov    %eax,(%ecx)
			return 0;
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
  801508:	eb f2                	jmp    8014fc <dev_lookup+0x4c>

0080150a <fd_close>:
{
  80150a:	f3 0f 1e fb          	endbr32 
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 28             	sub    $0x28,%esp
  801517:	8b 75 08             	mov    0x8(%ebp),%esi
  80151a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151d:	56                   	push   %esi
  80151e:	e8 b0 fe ff ff       	call   8013d3 <fd2num>
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801529:	52                   	push   %edx
  80152a:	50                   	push   %eax
  80152b:	e8 2c ff ff ff       	call   80145c <fd_lookup>
  801530:	89 c3                	mov    %eax,%ebx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 05                	js     80153e <fd_close+0x34>
	    || fd != fd2)
  801539:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80153c:	74 16                	je     801554 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80153e:	89 f8                	mov    %edi,%eax
  801540:	84 c0                	test   %al,%al
  801542:	b8 00 00 00 00       	mov    $0x0,%eax
  801547:	0f 44 d8             	cmove  %eax,%ebx
}
  80154a:	89 d8                	mov    %ebx,%eax
  80154c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 36                	pushl  (%esi)
  80155d:	e8 4e ff ff ff       	call   8014b0 <dev_lookup>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 1a                	js     801585 <fd_close+0x7b>
		if (dev->dev_close)
  80156b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80156e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801571:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801576:	85 c0                	test   %eax,%eax
  801578:	74 0b                	je     801585 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	56                   	push   %esi
  80157e:	ff d0                	call   *%eax
  801580:	89 c3                	mov    %eax,%ebx
  801582:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	56                   	push   %esi
  801589:	6a 00                	push   $0x0
  80158b:	e8 05 f7 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	eb b5                	jmp    80154a <fd_close+0x40>

00801595 <close>:

int
close(int fdnum)
{
  801595:	f3 0f 1e fb          	endbr32 
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	ff 75 08             	pushl  0x8(%ebp)
  8015a6:	e8 b1 fe ff ff       	call   80145c <fd_lookup>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	79 02                	jns    8015b4 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    
		return fd_close(fd, 1);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	6a 01                	push   $0x1
  8015b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bc:	e8 49 ff ff ff       	call   80150a <fd_close>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	eb ec                	jmp    8015b2 <close+0x1d>

008015c6 <close_all>:

void
close_all(void)
{
  8015c6:	f3 0f 1e fb          	endbr32 
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	53                   	push   %ebx
  8015da:	e8 b6 ff ff ff       	call   801595 <close>
	for (i = 0; i < MAXFD; i++)
  8015df:	83 c3 01             	add    $0x1,%ebx
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	83 fb 20             	cmp    $0x20,%ebx
  8015e8:	75 ec                	jne    8015d6 <close_all+0x10>
}
  8015ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ef:	f3 0f 1e fb          	endbr32 
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 54 fe ff ff       	call   80145c <fd_lookup>
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	0f 88 81 00 00 00    	js     801696 <dup+0xa7>
		return r;
	close(newfdnum);
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	e8 75 ff ff ff       	call   801595 <close>

	newfd = INDEX2FD(newfdnum);
  801620:	8b 75 0c             	mov    0xc(%ebp),%esi
  801623:	c1 e6 0c             	shl    $0xc,%esi
  801626:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80162c:	83 c4 04             	add    $0x4,%esp
  80162f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801632:	e8 b0 fd ff ff       	call   8013e7 <fd2data>
  801637:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801639:	89 34 24             	mov    %esi,(%esp)
  80163c:	e8 a6 fd ff ff       	call   8013e7 <fd2data>
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801646:	89 d8                	mov    %ebx,%eax
  801648:	c1 e8 16             	shr    $0x16,%eax
  80164b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801652:	a8 01                	test   $0x1,%al
  801654:	74 11                	je     801667 <dup+0x78>
  801656:	89 d8                	mov    %ebx,%eax
  801658:	c1 e8 0c             	shr    $0xc,%eax
  80165b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801662:	f6 c2 01             	test   $0x1,%dl
  801665:	75 39                	jne    8016a0 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801667:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	c1 e8 0c             	shr    $0xc,%eax
  80166f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	25 07 0e 00 00       	and    $0xe07,%eax
  80167e:	50                   	push   %eax
  80167f:	56                   	push   %esi
  801680:	6a 00                	push   $0x0
  801682:	52                   	push   %edx
  801683:	6a 00                	push   $0x0
  801685:	e8 e1 f5 ff ff       	call   800c6b <sys_page_map>
  80168a:	89 c3                	mov    %eax,%ebx
  80168c:	83 c4 20             	add    $0x20,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 31                	js     8016c4 <dup+0xd5>
		goto err;

	return newfdnum;
  801693:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801696:	89 d8                	mov    %ebx,%eax
  801698:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5f                   	pop    %edi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a7:	83 ec 0c             	sub    $0xc,%esp
  8016aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8016af:	50                   	push   %eax
  8016b0:	57                   	push   %edi
  8016b1:	6a 00                	push   $0x0
  8016b3:	53                   	push   %ebx
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 b0 f5 ff ff       	call   800c6b <sys_page_map>
  8016bb:	89 c3                	mov    %eax,%ebx
  8016bd:	83 c4 20             	add    $0x20,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	79 a3                	jns    801667 <dup+0x78>
	sys_page_unmap(0, newfd);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	56                   	push   %esi
  8016c8:	6a 00                	push   $0x0
  8016ca:	e8 c6 f5 ff ff       	call   800c95 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	57                   	push   %edi
  8016d3:	6a 00                	push   $0x0
  8016d5:	e8 bb f5 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb b7                	jmp    801696 <dup+0xa7>

008016df <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016df:	f3 0f 1e fb          	endbr32 
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 1c             	sub    $0x1c,%esp
  8016ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	53                   	push   %ebx
  8016f2:	e8 65 fd ff ff       	call   80145c <fd_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 3f                	js     80173d <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801708:	ff 30                	pushl  (%eax)
  80170a:	e8 a1 fd ff ff       	call   8014b0 <dev_lookup>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	78 27                	js     80173d <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801716:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801719:	8b 42 08             	mov    0x8(%edx),%eax
  80171c:	83 e0 03             	and    $0x3,%eax
  80171f:	83 f8 01             	cmp    $0x1,%eax
  801722:	74 1e                	je     801742 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801727:	8b 40 08             	mov    0x8(%eax),%eax
  80172a:	85 c0                	test   %eax,%eax
  80172c:	74 35                	je     801763 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	ff 75 10             	pushl  0x10(%ebp)
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	52                   	push   %edx
  801738:	ff d0                	call   *%eax
  80173a:	83 c4 10             	add    $0x10,%esp
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801742:	a1 04 40 80 00       	mov    0x804004,%eax
  801747:	8b 40 48             	mov    0x48(%eax),%eax
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	53                   	push   %ebx
  80174e:	50                   	push   %eax
  80174f:	68 05 2a 80 00       	push   $0x802a05
  801754:	e8 f8 ea ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801761:	eb da                	jmp    80173d <read+0x5e>
		return -E_NOT_SUPP;
  801763:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801768:	eb d3                	jmp    80173d <read+0x5e>

0080176a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80176a:	f3 0f 1e fb          	endbr32 
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	57                   	push   %edi
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	8b 7d 08             	mov    0x8(%ebp),%edi
  80177a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80177d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801782:	eb 02                	jmp    801786 <readn+0x1c>
  801784:	01 c3                	add    %eax,%ebx
  801786:	39 f3                	cmp    %esi,%ebx
  801788:	73 21                	jae    8017ab <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	89 f0                	mov    %esi,%eax
  80178f:	29 d8                	sub    %ebx,%eax
  801791:	50                   	push   %eax
  801792:	89 d8                	mov    %ebx,%eax
  801794:	03 45 0c             	add    0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	57                   	push   %edi
  801799:	e8 41 ff ff ff       	call   8016df <read>
		if (m < 0)
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 04                	js     8017a9 <readn+0x3f>
			return m;
		if (m == 0)
  8017a5:	75 dd                	jne    801784 <readn+0x1a>
  8017a7:	eb 02                	jmp    8017ab <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017ab:	89 d8                	mov    %ebx,%eax
  8017ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5f                   	pop    %edi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b5:	f3 0f 1e fb          	endbr32 
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 1c             	sub    $0x1c,%esp
  8017c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	53                   	push   %ebx
  8017c8:	e8 8f fc ff ff       	call   80145c <fd_lookup>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 3a                	js     80180e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017da:	50                   	push   %eax
  8017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017de:	ff 30                	pushl  (%eax)
  8017e0:	e8 cb fc ff ff       	call   8014b0 <dev_lookup>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 22                	js     80180e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f3:	74 1e                	je     801813 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	74 35                	je     801834 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	ff 75 10             	pushl  0x10(%ebp)
  801805:	ff 75 0c             	pushl  0xc(%ebp)
  801808:	50                   	push   %eax
  801809:	ff d2                	call   *%edx
  80180b:	83 c4 10             	add    $0x10,%esp
}
  80180e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801811:	c9                   	leave  
  801812:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801813:	a1 04 40 80 00       	mov    0x804004,%eax
  801818:	8b 40 48             	mov    0x48(%eax),%eax
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	53                   	push   %ebx
  80181f:	50                   	push   %eax
  801820:	68 21 2a 80 00       	push   $0x802a21
  801825:	e8 27 ea ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801832:	eb da                	jmp    80180e <write+0x59>
		return -E_NOT_SUPP;
  801834:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801839:	eb d3                	jmp    80180e <write+0x59>

0080183b <seek>:

int
seek(int fdnum, off_t offset)
{
  80183b:	f3 0f 1e fb          	endbr32 
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801848:	50                   	push   %eax
  801849:	ff 75 08             	pushl  0x8(%ebp)
  80184c:	e8 0b fc ff ff       	call   80145c <fd_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 0e                	js     801866 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801868:	f3 0f 1e fb          	endbr32 
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 1c             	sub    $0x1c,%esp
  801873:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801876:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801879:	50                   	push   %eax
  80187a:	53                   	push   %ebx
  80187b:	e8 dc fb ff ff       	call   80145c <fd_lookup>
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	78 37                	js     8018be <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801891:	ff 30                	pushl  (%eax)
  801893:	e8 18 fc ff ff       	call   8014b0 <dev_lookup>
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 1f                	js     8018be <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a6:	74 1b                	je     8018c3 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ab:	8b 52 18             	mov    0x18(%edx),%edx
  8018ae:	85 d2                	test   %edx,%edx
  8018b0:	74 32                	je     8018e4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	50                   	push   %eax
  8018b9:	ff d2                	call   *%edx
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018c3:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c8:	8b 40 48             	mov    0x48(%eax),%eax
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	53                   	push   %ebx
  8018cf:	50                   	push   %eax
  8018d0:	68 e4 29 80 00       	push   $0x8029e4
  8018d5:	e8 77 e9 ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e2:	eb da                	jmp    8018be <ftruncate+0x56>
		return -E_NOT_SUPP;
  8018e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018e9:	eb d3                	jmp    8018be <ftruncate+0x56>

008018eb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018eb:	f3 0f 1e fb          	endbr32 
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 1c             	sub    $0x1c,%esp
  8018f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fc:	50                   	push   %eax
  8018fd:	ff 75 08             	pushl  0x8(%ebp)
  801900:	e8 57 fb ff ff       	call   80145c <fd_lookup>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 4b                	js     801957 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801912:	50                   	push   %eax
  801913:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801916:	ff 30                	pushl  (%eax)
  801918:	e8 93 fb ff ff       	call   8014b0 <dev_lookup>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 33                	js     801957 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801927:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80192b:	74 2f                	je     80195c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80192d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801930:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801937:	00 00 00 
	stat->st_isdir = 0;
  80193a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801941:	00 00 00 
	stat->st_dev = dev;
  801944:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	53                   	push   %ebx
  80194e:	ff 75 f0             	pushl  -0x10(%ebp)
  801951:	ff 50 14             	call   *0x14(%eax)
  801954:	83 c4 10             	add    $0x10,%esp
}
  801957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    
		return -E_NOT_SUPP;
  80195c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801961:	eb f4                	jmp    801957 <fstat+0x6c>

00801963 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801963:	f3 0f 1e fb          	endbr32 
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	6a 00                	push   $0x0
  801971:	ff 75 08             	pushl  0x8(%ebp)
  801974:	e8 fb 01 00 00       	call   801b74 <open>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 1b                	js     80199d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801982:	83 ec 08             	sub    $0x8,%esp
  801985:	ff 75 0c             	pushl  0xc(%ebp)
  801988:	50                   	push   %eax
  801989:	e8 5d ff ff ff       	call   8018eb <fstat>
  80198e:	89 c6                	mov    %eax,%esi
	close(fd);
  801990:	89 1c 24             	mov    %ebx,(%esp)
  801993:	e8 fd fb ff ff       	call   801595 <close>
	return r;
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	89 f3                	mov    %esi,%ebx
}
  80199d:	89 d8                	mov    %ebx,%eax
  80199f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	89 c6                	mov    %eax,%esi
  8019ad:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019af:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019b6:	74 27                	je     8019df <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019b8:	6a 07                	push   $0x7
  8019ba:	68 00 50 80 00       	push   $0x805000
  8019bf:	56                   	push   %esi
  8019c0:	ff 35 00 40 80 00    	pushl  0x804000
  8019c6:	e8 66 f9 ff ff       	call   801331 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019cb:	83 c4 0c             	add    $0xc,%esp
  8019ce:	6a 00                	push   $0x0
  8019d0:	53                   	push   %ebx
  8019d1:	6a 00                	push   $0x0
  8019d3:	e8 eb f8 ff ff       	call   8012c3 <ipc_recv>
}
  8019d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	6a 01                	push   $0x1
  8019e4:	e8 ad f9 ff ff       	call   801396 <ipc_find_env>
  8019e9:	a3 00 40 80 00       	mov    %eax,0x804000
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	eb c5                	jmp    8019b8 <fsipc+0x12>

008019f3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f3:	f3 0f 1e fb          	endbr32 
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	8b 40 0c             	mov    0xc(%eax),%eax
  801a03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a10:	ba 00 00 00 00       	mov    $0x0,%edx
  801a15:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1a:	e8 87 ff ff ff       	call   8019a6 <fsipc>
}
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <devfile_flush>:
{
  801a21:	f3 0f 1e fb          	endbr32 
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a31:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	b8 06 00 00 00       	mov    $0x6,%eax
  801a40:	e8 61 ff ff ff       	call   8019a6 <fsipc>
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devfile_stat>:
{
  801a47:	f3 0f 1e fb          	endbr32 
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 04             	sub    $0x4,%esp
  801a52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a60:	ba 00 00 00 00       	mov    $0x0,%edx
  801a65:	b8 05 00 00 00       	mov    $0x5,%eax
  801a6a:	e8 37 ff ff ff       	call   8019a6 <fsipc>
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	78 2c                	js     801a9f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	68 00 50 80 00       	push   $0x805000
  801a7b:	53                   	push   %ebx
  801a7c:	e8 3a ed ff ff       	call   8007bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a81:	a1 80 50 80 00       	mov    0x805080,%eax
  801a86:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a8c:	a1 84 50 80 00       	mov    0x805084,%eax
  801a91:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <devfile_write>:
{
  801aa4:	f3 0f 1e fb          	endbr32 
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ab1:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab4:	8b 52 0c             	mov    0xc(%edx),%edx
  801ab7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801abd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ac2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ac7:	0f 47 c2             	cmova  %edx,%eax
  801aca:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801acf:	50                   	push   %eax
  801ad0:	ff 75 0c             	pushl  0xc(%ebp)
  801ad3:	68 08 50 80 00       	push   $0x805008
  801ad8:	e8 96 ee ff ff       	call   800973 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801add:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ae7:	e8 ba fe ff ff       	call   8019a6 <fsipc>
}
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <devfile_read>:
{
  801aee:	f3 0f 1e fb          	endbr32 
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	8b 40 0c             	mov    0xc(%eax),%eax
  801b00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b05:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	b8 03 00 00 00       	mov    $0x3,%eax
  801b15:	e8 8c fe ff ff       	call   8019a6 <fsipc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 1f                	js     801b3f <devfile_read+0x51>
	assert(r <= n);
  801b20:	39 f0                	cmp    %esi,%eax
  801b22:	77 24                	ja     801b48 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b24:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b29:	7f 33                	jg     801b5e <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b2b:	83 ec 04             	sub    $0x4,%esp
  801b2e:	50                   	push   %eax
  801b2f:	68 00 50 80 00       	push   $0x805000
  801b34:	ff 75 0c             	pushl  0xc(%ebp)
  801b37:	e8 37 ee ff ff       	call   800973 <memmove>
	return r;
  801b3c:	83 c4 10             	add    $0x10,%esp
}
  801b3f:	89 d8                	mov    %ebx,%eax
  801b41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b44:	5b                   	pop    %ebx
  801b45:	5e                   	pop    %esi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    
	assert(r <= n);
  801b48:	68 50 2a 80 00       	push   $0x802a50
  801b4d:	68 57 2a 80 00       	push   $0x802a57
  801b52:	6a 7c                	push   $0x7c
  801b54:	68 6c 2a 80 00       	push   $0x802a6c
  801b59:	e8 0c e6 ff ff       	call   80016a <_panic>
	assert(r <= PGSIZE);
  801b5e:	68 77 2a 80 00       	push   $0x802a77
  801b63:	68 57 2a 80 00       	push   $0x802a57
  801b68:	6a 7d                	push   $0x7d
  801b6a:	68 6c 2a 80 00       	push   $0x802a6c
  801b6f:	e8 f6 e5 ff ff       	call   80016a <_panic>

00801b74 <open>:
{
  801b74:	f3 0f 1e fb          	endbr32 
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	56                   	push   %esi
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 1c             	sub    $0x1c,%esp
  801b80:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b83:	56                   	push   %esi
  801b84:	e8 ef eb ff ff       	call   800778 <strlen>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b91:	7f 6c                	jg     801bff <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b99:	50                   	push   %eax
  801b9a:	e8 67 f8 ff ff       	call   801406 <fd_alloc>
  801b9f:	89 c3                	mov    %eax,%ebx
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 3c                	js     801be4 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801ba8:	83 ec 08             	sub    $0x8,%esp
  801bab:	56                   	push   %esi
  801bac:	68 00 50 80 00       	push   $0x805000
  801bb1:	e8 05 ec ff ff       	call   8007bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb9:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	e8 db fd ff ff       	call   8019a6 <fsipc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	78 19                	js     801bed <open+0x79>
	return fd2num(fd);
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bda:	e8 f4 f7 ff ff       	call   8013d3 <fd2num>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    
		fd_close(fd, 0);
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	6a 00                	push   $0x0
  801bf2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf5:	e8 10 f9 ff ff       	call   80150a <fd_close>
		return r;
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	eb e5                	jmp    801be4 <open+0x70>
		return -E_BAD_PATH;
  801bff:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c04:	eb de                	jmp    801be4 <open+0x70>

00801c06 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c06:	f3 0f 1e fb          	endbr32 
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c10:	ba 00 00 00 00       	mov    $0x0,%edx
  801c15:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1a:	e8 87 fd ff ff       	call   8019a6 <fsipc>
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c21:	f3 0f 1e fb          	endbr32 
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	56                   	push   %esi
  801c29:	53                   	push   %ebx
  801c2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	ff 75 08             	pushl  0x8(%ebp)
  801c33:	e8 af f7 ff ff       	call   8013e7 <fd2data>
  801c38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c3a:	83 c4 08             	add    $0x8,%esp
  801c3d:	68 83 2a 80 00       	push   $0x802a83
  801c42:	53                   	push   %ebx
  801c43:	e8 73 eb ff ff       	call   8007bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c48:	8b 46 04             	mov    0x4(%esi),%eax
  801c4b:	2b 06                	sub    (%esi),%eax
  801c4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c5a:	00 00 00 
	stat->st_dev = &devpipe;
  801c5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c64:	30 80 00 
	return 0;
}
  801c67:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c73:	f3 0f 1e fb          	endbr32 
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c81:	53                   	push   %ebx
  801c82:	6a 00                	push   $0x0
  801c84:	e8 0c f0 ff ff       	call   800c95 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c89:	89 1c 24             	mov    %ebx,(%esp)
  801c8c:	e8 56 f7 ff ff       	call   8013e7 <fd2data>
  801c91:	83 c4 08             	add    $0x8,%esp
  801c94:	50                   	push   %eax
  801c95:	6a 00                	push   $0x0
  801c97:	e8 f9 ef ff ff       	call   800c95 <sys_page_unmap>
}
  801c9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <_pipeisclosed>:
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 1c             	sub    $0x1c,%esp
  801caa:	89 c7                	mov    %eax,%edi
  801cac:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cae:	a1 04 40 80 00       	mov    0x804004,%eax
  801cb3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	57                   	push   %edi
  801cba:	e8 e0 04 00 00       	call   80219f <pageref>
  801cbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cc2:	89 34 24             	mov    %esi,(%esp)
  801cc5:	e8 d5 04 00 00       	call   80219f <pageref>
		nn = thisenv->env_runs;
  801cca:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cd0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	39 cb                	cmp    %ecx,%ebx
  801cd8:	74 1b                	je     801cf5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cda:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cdd:	75 cf                	jne    801cae <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cdf:	8b 42 58             	mov    0x58(%edx),%eax
  801ce2:	6a 01                	push   $0x1
  801ce4:	50                   	push   %eax
  801ce5:	53                   	push   %ebx
  801ce6:	68 8a 2a 80 00       	push   $0x802a8a
  801ceb:	e8 61 e5 ff ff       	call   800251 <cprintf>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	eb b9                	jmp    801cae <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cf5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cf8:	0f 94 c0             	sete   %al
  801cfb:	0f b6 c0             	movzbl %al,%eax
}
  801cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <devpipe_write>:
{
  801d06:	f3 0f 1e fb          	endbr32 
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	57                   	push   %edi
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 28             	sub    $0x28,%esp
  801d13:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d16:	56                   	push   %esi
  801d17:	e8 cb f6 ff ff       	call   8013e7 <fd2data>
  801d1c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	bf 00 00 00 00       	mov    $0x0,%edi
  801d26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d29:	74 4f                	je     801d7a <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d2b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2e:	8b 0b                	mov    (%ebx),%ecx
  801d30:	8d 51 20             	lea    0x20(%ecx),%edx
  801d33:	39 d0                	cmp    %edx,%eax
  801d35:	72 14                	jb     801d4b <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d37:	89 da                	mov    %ebx,%edx
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	e8 61 ff ff ff       	call   801ca1 <_pipeisclosed>
  801d40:	85 c0                	test   %eax,%eax
  801d42:	75 3b                	jne    801d7f <devpipe_write+0x79>
			sys_yield();
  801d44:	e8 cf ee ff ff       	call   800c18 <sys_yield>
  801d49:	eb e0                	jmp    801d2b <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d52:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d55:	89 c2                	mov    %eax,%edx
  801d57:	c1 fa 1f             	sar    $0x1f,%edx
  801d5a:	89 d1                	mov    %edx,%ecx
  801d5c:	c1 e9 1b             	shr    $0x1b,%ecx
  801d5f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d62:	83 e2 1f             	and    $0x1f,%edx
  801d65:	29 ca                	sub    %ecx,%edx
  801d67:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d6b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d6f:	83 c0 01             	add    $0x1,%eax
  801d72:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d75:	83 c7 01             	add    $0x1,%edi
  801d78:	eb ac                	jmp    801d26 <devpipe_write+0x20>
	return i;
  801d7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d7d:	eb 05                	jmp    801d84 <devpipe_write+0x7e>
				return 0;
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <devpipe_read>:
{
  801d8c:	f3 0f 1e fb          	endbr32 
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	57                   	push   %edi
  801d94:	56                   	push   %esi
  801d95:	53                   	push   %ebx
  801d96:	83 ec 18             	sub    $0x18,%esp
  801d99:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d9c:	57                   	push   %edi
  801d9d:	e8 45 f6 ff ff       	call   8013e7 <fd2data>
  801da2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	be 00 00 00 00       	mov    $0x0,%esi
  801dac:	3b 75 10             	cmp    0x10(%ebp),%esi
  801daf:	75 14                	jne    801dc5 <devpipe_read+0x39>
	return i;
  801db1:	8b 45 10             	mov    0x10(%ebp),%eax
  801db4:	eb 02                	jmp    801db8 <devpipe_read+0x2c>
				return i;
  801db6:	89 f0                	mov    %esi,%eax
}
  801db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    
			sys_yield();
  801dc0:	e8 53 ee ff ff       	call   800c18 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dc5:	8b 03                	mov    (%ebx),%eax
  801dc7:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dca:	75 18                	jne    801de4 <devpipe_read+0x58>
			if (i > 0)
  801dcc:	85 f6                	test   %esi,%esi
  801dce:	75 e6                	jne    801db6 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801dd0:	89 da                	mov    %ebx,%edx
  801dd2:	89 f8                	mov    %edi,%eax
  801dd4:	e8 c8 fe ff ff       	call   801ca1 <_pipeisclosed>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	74 e3                	je     801dc0 <devpipe_read+0x34>
				return 0;
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  801de2:	eb d4                	jmp    801db8 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801de4:	99                   	cltd   
  801de5:	c1 ea 1b             	shr    $0x1b,%edx
  801de8:	01 d0                	add    %edx,%eax
  801dea:	83 e0 1f             	and    $0x1f,%eax
  801ded:	29 d0                	sub    %edx,%eax
  801def:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dfa:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dfd:	83 c6 01             	add    $0x1,%esi
  801e00:	eb aa                	jmp    801dac <devpipe_read+0x20>

00801e02 <pipe>:
{
  801e02:	f3 0f 1e fb          	endbr32 
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	56                   	push   %esi
  801e0a:	53                   	push   %ebx
  801e0b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e11:	50                   	push   %eax
  801e12:	e8 ef f5 ff ff       	call   801406 <fd_alloc>
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 23 01 00 00    	js     801f47 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e24:	83 ec 04             	sub    $0x4,%esp
  801e27:	68 07 04 00 00       	push   $0x407
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 0d ee ff ff       	call   800c43 <sys_page_alloc>
  801e36:	89 c3                	mov    %eax,%ebx
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	0f 88 04 01 00 00    	js     801f47 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	e8 b7 f5 ff ff       	call   801406 <fd_alloc>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	0f 88 db 00 00 00    	js     801f37 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	68 07 04 00 00       	push   $0x407
  801e64:	ff 75 f0             	pushl  -0x10(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 d5 ed ff ff       	call   800c43 <sys_page_alloc>
  801e6e:	89 c3                	mov    %eax,%ebx
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 bc 00 00 00    	js     801f37 <pipe+0x135>
	va = fd2data(fd0);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e81:	e8 61 f5 ff ff       	call   8013e7 <fd2data>
  801e86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e88:	83 c4 0c             	add    $0xc,%esp
  801e8b:	68 07 04 00 00       	push   $0x407
  801e90:	50                   	push   %eax
  801e91:	6a 00                	push   $0x0
  801e93:	e8 ab ed ff ff       	call   800c43 <sys_page_alloc>
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 82 00 00 00    	js     801f27 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  801eab:	e8 37 f5 ff ff       	call   8013e7 <fd2data>
  801eb0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eb7:	50                   	push   %eax
  801eb8:	6a 00                	push   $0x0
  801eba:	56                   	push   %esi
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 a9 ed ff ff       	call   800c6b <sys_page_map>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	83 c4 20             	add    $0x20,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 4e                	js     801f19 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801ecb:	a1 20 30 80 00       	mov    0x803020,%eax
  801ed0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ed5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801edf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ee2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef4:	e8 da f4 ff ff       	call   8013d3 <fd2num>
  801ef9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801efc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801efe:	83 c4 04             	add    $0x4,%esp
  801f01:	ff 75 f0             	pushl  -0x10(%ebp)
  801f04:	e8 ca f4 ff ff       	call   8013d3 <fd2num>
  801f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f17:	eb 2e                	jmp    801f47 <pipe+0x145>
	sys_page_unmap(0, va);
  801f19:	83 ec 08             	sub    $0x8,%esp
  801f1c:	56                   	push   %esi
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 71 ed ff ff       	call   800c95 <sys_page_unmap>
  801f24:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f27:	83 ec 08             	sub    $0x8,%esp
  801f2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2d:	6a 00                	push   $0x0
  801f2f:	e8 61 ed ff ff       	call   800c95 <sys_page_unmap>
  801f34:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f37:	83 ec 08             	sub    $0x8,%esp
  801f3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3d:	6a 00                	push   $0x0
  801f3f:	e8 51 ed ff ff       	call   800c95 <sys_page_unmap>
  801f44:	83 c4 10             	add    $0x10,%esp
}
  801f47:	89 d8                	mov    %ebx,%eax
  801f49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <pipeisclosed>:
{
  801f50:	f3 0f 1e fb          	endbr32 
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	ff 75 08             	pushl  0x8(%ebp)
  801f61:	e8 f6 f4 ff ff       	call   80145c <fd_lookup>
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 18                	js     801f85 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	ff 75 f4             	pushl  -0xc(%ebp)
  801f73:	e8 6f f4 ff ff       	call   8013e7 <fd2data>
  801f78:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7d:	e8 1f fd ff ff       	call   801ca1 <_pipeisclosed>
  801f82:	83 c4 10             	add    $0x10,%esp
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f87:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f90:	c3                   	ret    

00801f91 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f91:	f3 0f 1e fb          	endbr32 
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f9b:	68 a2 2a 80 00       	push   $0x802aa2
  801fa0:	ff 75 0c             	pushl  0xc(%ebp)
  801fa3:	e8 13 e8 ff ff       	call   8007bb <strcpy>
	return 0;
}
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <devcons_write>:
{
  801faf:	f3 0f 1e fb          	endbr32 
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	57                   	push   %edi
  801fb7:	56                   	push   %esi
  801fb8:	53                   	push   %ebx
  801fb9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fbf:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fc4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fca:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fcd:	73 31                	jae    802000 <devcons_write+0x51>
		m = n - tot;
  801fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd2:	29 f3                	sub    %esi,%ebx
  801fd4:	83 fb 7f             	cmp    $0x7f,%ebx
  801fd7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fdc:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fdf:	83 ec 04             	sub    $0x4,%esp
  801fe2:	53                   	push   %ebx
  801fe3:	89 f0                	mov    %esi,%eax
  801fe5:	03 45 0c             	add    0xc(%ebp),%eax
  801fe8:	50                   	push   %eax
  801fe9:	57                   	push   %edi
  801fea:	e8 84 e9 ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  801fef:	83 c4 08             	add    $0x8,%esp
  801ff2:	53                   	push   %ebx
  801ff3:	57                   	push   %edi
  801ff4:	e8 7f eb ff ff       	call   800b78 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ff9:	01 de                	add    %ebx,%esi
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	eb ca                	jmp    801fca <devcons_write+0x1b>
}
  802000:	89 f0                	mov    %esi,%eax
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <devcons_read>:
{
  80200a:	f3 0f 1e fb          	endbr32 
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 08             	sub    $0x8,%esp
  802014:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802019:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80201d:	74 21                	je     802040 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80201f:	e8 7e eb ff ff       	call   800ba2 <sys_cgetc>
  802024:	85 c0                	test   %eax,%eax
  802026:	75 07                	jne    80202f <devcons_read+0x25>
		sys_yield();
  802028:	e8 eb eb ff ff       	call   800c18 <sys_yield>
  80202d:	eb f0                	jmp    80201f <devcons_read+0x15>
	if (c < 0)
  80202f:	78 0f                	js     802040 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802031:	83 f8 04             	cmp    $0x4,%eax
  802034:	74 0c                	je     802042 <devcons_read+0x38>
	*(char*)vbuf = c;
  802036:	8b 55 0c             	mov    0xc(%ebp),%edx
  802039:	88 02                	mov    %al,(%edx)
	return 1;
  80203b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    
		return 0;
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
  802047:	eb f7                	jmp    802040 <devcons_read+0x36>

00802049 <cputchar>:
{
  802049:	f3 0f 1e fb          	endbr32 
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802053:	8b 45 08             	mov    0x8(%ebp),%eax
  802056:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802059:	6a 01                	push   $0x1
  80205b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80205e:	50                   	push   %eax
  80205f:	e8 14 eb ff ff       	call   800b78 <sys_cputs>
}
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <getchar>:
{
  802069:	f3 0f 1e fb          	endbr32 
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802073:	6a 01                	push   $0x1
  802075:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802078:	50                   	push   %eax
  802079:	6a 00                	push   $0x0
  80207b:	e8 5f f6 ff ff       	call   8016df <read>
	if (r < 0)
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	78 06                	js     80208d <getchar+0x24>
	if (r < 1)
  802087:	74 06                	je     80208f <getchar+0x26>
	return c;
  802089:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    
		return -E_EOF;
  80208f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802094:	eb f7                	jmp    80208d <getchar+0x24>

00802096 <iscons>:
{
  802096:	f3 0f 1e fb          	endbr32 
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a3:	50                   	push   %eax
  8020a4:	ff 75 08             	pushl  0x8(%ebp)
  8020a7:	e8 b0 f3 ff ff       	call   80145c <fd_lookup>
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	78 11                	js     8020c4 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020bc:	39 10                	cmp    %edx,(%eax)
  8020be:	0f 94 c0             	sete   %al
  8020c1:	0f b6 c0             	movzbl %al,%eax
}
  8020c4:	c9                   	leave  
  8020c5:	c3                   	ret    

008020c6 <opencons>:
{
  8020c6:	f3 0f 1e fb          	endbr32 
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	e8 2d f3 ff ff       	call   801406 <fd_alloc>
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	78 3a                	js     80211a <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e0:	83 ec 04             	sub    $0x4,%esp
  8020e3:	68 07 04 00 00       	push   $0x407
  8020e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020eb:	6a 00                	push   $0x0
  8020ed:	e8 51 eb ff ff       	call   800c43 <sys_page_alloc>
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 21                	js     80211a <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802102:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802107:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80210e:	83 ec 0c             	sub    $0xc,%esp
  802111:	50                   	push   %eax
  802112:	e8 bc f2 ff ff       	call   8013d3 <fd2num>
  802117:	83 c4 10             	add    $0x10,%esp
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80211c:	f3 0f 1e fb          	endbr32 
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802126:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80212d:	74 1c                	je     80214b <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80212f:	8b 45 08             	mov    0x8(%ebp),%eax
  802132:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802137:	83 ec 08             	sub    $0x8,%esp
  80213a:	68 77 21 80 00       	push   $0x802177
  80213f:	6a 00                	push   $0x0
  802141:	e8 c4 eb ff ff       	call   800d0a <sys_env_set_pgfault_upcall>
}
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	c9                   	leave  
  80214a:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  80214b:	83 ec 04             	sub    $0x4,%esp
  80214e:	6a 02                	push   $0x2
  802150:	68 00 f0 bf ee       	push   $0xeebff000
  802155:	6a 00                	push   $0x0
  802157:	e8 e7 ea ff ff       	call   800c43 <sys_page_alloc>
  80215c:	83 c4 10             	add    $0x10,%esp
  80215f:	85 c0                	test   %eax,%eax
  802161:	79 cc                	jns    80212f <set_pgfault_handler+0x13>
  802163:	83 ec 04             	sub    $0x4,%esp
  802166:	68 ae 2a 80 00       	push   $0x802aae
  80216b:	6a 20                	push   $0x20
  80216d:	68 c9 2a 80 00       	push   $0x802ac9
  802172:	e8 f3 df ff ff       	call   80016a <_panic>

00802177 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802177:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802178:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80217d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80217f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  802182:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  802186:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80218a:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  80218d:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  80218f:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802193:	83 c4 08             	add    $0x8,%esp
	popal
  802196:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802197:	83 c4 04             	add    $0x4,%esp
	popfl
  80219a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80219b:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80219e:	c3                   	ret    

0080219f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219f:	f3 0f 1e fb          	endbr32 
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a9:	89 c2                	mov    %eax,%edx
  8021ab:	c1 ea 16             	shr    $0x16,%edx
  8021ae:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021b5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021ba:	f6 c1 01             	test   $0x1,%cl
  8021bd:	74 1c                	je     8021db <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021bf:	c1 e8 0c             	shr    $0xc,%eax
  8021c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021c9:	a8 01                	test   $0x1,%al
  8021cb:	74 0e                	je     8021db <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021cd:	c1 e8 0c             	shr    $0xc,%eax
  8021d0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021d7:	ef 
  8021d8:	0f b7 d2             	movzwl %dx,%edx
}
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	f3 0f 1e fb          	endbr32 
  8021e4:	55                   	push   %ebp
  8021e5:	57                   	push   %edi
  8021e6:	56                   	push   %esi
  8021e7:	53                   	push   %ebx
  8021e8:	83 ec 1c             	sub    $0x1c,%esp
  8021eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021fb:	85 d2                	test   %edx,%edx
  8021fd:	75 19                	jne    802218 <__udivdi3+0x38>
  8021ff:	39 f3                	cmp    %esi,%ebx
  802201:	76 4d                	jbe    802250 <__udivdi3+0x70>
  802203:	31 ff                	xor    %edi,%edi
  802205:	89 e8                	mov    %ebp,%eax
  802207:	89 f2                	mov    %esi,%edx
  802209:	f7 f3                	div    %ebx
  80220b:	89 fa                	mov    %edi,%edx
  80220d:	83 c4 1c             	add    $0x1c,%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    
  802215:	8d 76 00             	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	76 14                	jbe    802230 <__udivdi3+0x50>
  80221c:	31 ff                	xor    %edi,%edi
  80221e:	31 c0                	xor    %eax,%eax
  802220:	89 fa                	mov    %edi,%edx
  802222:	83 c4 1c             	add    $0x1c,%esp
  802225:	5b                   	pop    %ebx
  802226:	5e                   	pop    %esi
  802227:	5f                   	pop    %edi
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    
  80222a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802230:	0f bd fa             	bsr    %edx,%edi
  802233:	83 f7 1f             	xor    $0x1f,%edi
  802236:	75 48                	jne    802280 <__udivdi3+0xa0>
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	72 06                	jb     802242 <__udivdi3+0x62>
  80223c:	31 c0                	xor    %eax,%eax
  80223e:	39 eb                	cmp    %ebp,%ebx
  802240:	77 de                	ja     802220 <__udivdi3+0x40>
  802242:	b8 01 00 00 00       	mov    $0x1,%eax
  802247:	eb d7                	jmp    802220 <__udivdi3+0x40>
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d9                	mov    %ebx,%ecx
  802252:	85 db                	test   %ebx,%ebx
  802254:	75 0b                	jne    802261 <__udivdi3+0x81>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f3                	div    %ebx
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	31 d2                	xor    %edx,%edx
  802263:	89 f0                	mov    %esi,%eax
  802265:	f7 f1                	div    %ecx
  802267:	89 c6                	mov    %eax,%esi
  802269:	89 e8                	mov    %ebp,%eax
  80226b:	89 f7                	mov    %esi,%edi
  80226d:	f7 f1                	div    %ecx
  80226f:	89 fa                	mov    %edi,%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	89 f9                	mov    %edi,%ecx
  802282:	b8 20 00 00 00       	mov    $0x20,%eax
  802287:	29 f8                	sub    %edi,%eax
  802289:	d3 e2                	shl    %cl,%edx
  80228b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	89 da                	mov    %ebx,%edx
  802293:	d3 ea                	shr    %cl,%edx
  802295:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802299:	09 d1                	or     %edx,%ecx
  80229b:	89 f2                	mov    %esi,%edx
  80229d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e3                	shl    %cl,%ebx
  8022a5:	89 c1                	mov    %eax,%ecx
  8022a7:	d3 ea                	shr    %cl,%edx
  8022a9:	89 f9                	mov    %edi,%ecx
  8022ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022af:	89 eb                	mov    %ebp,%ebx
  8022b1:	d3 e6                	shl    %cl,%esi
  8022b3:	89 c1                	mov    %eax,%ecx
  8022b5:	d3 eb                	shr    %cl,%ebx
  8022b7:	09 de                	or     %ebx,%esi
  8022b9:	89 f0                	mov    %esi,%eax
  8022bb:	f7 74 24 08          	divl   0x8(%esp)
  8022bf:	89 d6                	mov    %edx,%esi
  8022c1:	89 c3                	mov    %eax,%ebx
  8022c3:	f7 64 24 0c          	mull   0xc(%esp)
  8022c7:	39 d6                	cmp    %edx,%esi
  8022c9:	72 15                	jb     8022e0 <__udivdi3+0x100>
  8022cb:	89 f9                	mov    %edi,%ecx
  8022cd:	d3 e5                	shl    %cl,%ebp
  8022cf:	39 c5                	cmp    %eax,%ebp
  8022d1:	73 04                	jae    8022d7 <__udivdi3+0xf7>
  8022d3:	39 d6                	cmp    %edx,%esi
  8022d5:	74 09                	je     8022e0 <__udivdi3+0x100>
  8022d7:	89 d8                	mov    %ebx,%eax
  8022d9:	31 ff                	xor    %edi,%edi
  8022db:	e9 40 ff ff ff       	jmp    802220 <__udivdi3+0x40>
  8022e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022e3:	31 ff                	xor    %edi,%edi
  8022e5:	e9 36 ff ff ff       	jmp    802220 <__udivdi3+0x40>
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	f3 0f 1e fb          	endbr32 
  8022f4:	55                   	push   %ebp
  8022f5:	57                   	push   %edi
  8022f6:	56                   	push   %esi
  8022f7:	53                   	push   %ebx
  8022f8:	83 ec 1c             	sub    $0x1c,%esp
  8022fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  802303:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802307:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80230b:	85 c0                	test   %eax,%eax
  80230d:	75 19                	jne    802328 <__umoddi3+0x38>
  80230f:	39 df                	cmp    %ebx,%edi
  802311:	76 5d                	jbe    802370 <__umoddi3+0x80>
  802313:	89 f0                	mov    %esi,%eax
  802315:	89 da                	mov    %ebx,%edx
  802317:	f7 f7                	div    %edi
  802319:	89 d0                	mov    %edx,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	83 c4 1c             	add    $0x1c,%esp
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5f                   	pop    %edi
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    
  802325:	8d 76 00             	lea    0x0(%esi),%esi
  802328:	89 f2                	mov    %esi,%edx
  80232a:	39 d8                	cmp    %ebx,%eax
  80232c:	76 12                	jbe    802340 <__umoddi3+0x50>
  80232e:	89 f0                	mov    %esi,%eax
  802330:	89 da                	mov    %ebx,%edx
  802332:	83 c4 1c             	add    $0x1c,%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5f                   	pop    %edi
  802338:	5d                   	pop    %ebp
  802339:	c3                   	ret    
  80233a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802340:	0f bd e8             	bsr    %eax,%ebp
  802343:	83 f5 1f             	xor    $0x1f,%ebp
  802346:	75 50                	jne    802398 <__umoddi3+0xa8>
  802348:	39 d8                	cmp    %ebx,%eax
  80234a:	0f 82 e0 00 00 00    	jb     802430 <__umoddi3+0x140>
  802350:	89 d9                	mov    %ebx,%ecx
  802352:	39 f7                	cmp    %esi,%edi
  802354:	0f 86 d6 00 00 00    	jbe    802430 <__umoddi3+0x140>
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	89 ca                	mov    %ecx,%edx
  80235e:	83 c4 1c             	add    $0x1c,%esp
  802361:	5b                   	pop    %ebx
  802362:	5e                   	pop    %esi
  802363:	5f                   	pop    %edi
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    
  802366:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	89 fd                	mov    %edi,%ebp
  802372:	85 ff                	test   %edi,%edi
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	89 d8                	mov    %ebx,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f5                	div    %ebp
  802387:	89 f0                	mov    %esi,%eax
  802389:	f7 f5                	div    %ebp
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	31 d2                	xor    %edx,%edx
  80238f:	eb 8c                	jmp    80231d <__umoddi3+0x2d>
  802391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802398:	89 e9                	mov    %ebp,%ecx
  80239a:	ba 20 00 00 00       	mov    $0x20,%edx
  80239f:	29 ea                	sub    %ebp,%edx
  8023a1:	d3 e0                	shl    %cl,%eax
  8023a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 f8                	mov    %edi,%eax
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023b9:	09 c1                	or     %eax,%ecx
  8023bb:	89 d8                	mov    %ebx,%eax
  8023bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023c1:	89 e9                	mov    %ebp,%ecx
  8023c3:	d3 e7                	shl    %cl,%edi
  8023c5:	89 d1                	mov    %edx,%ecx
  8023c7:	d3 e8                	shr    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023cf:	d3 e3                	shl    %cl,%ebx
  8023d1:	89 c7                	mov    %eax,%edi
  8023d3:	89 d1                	mov    %edx,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	89 fa                	mov    %edi,%edx
  8023dd:	d3 e6                	shl    %cl,%esi
  8023df:	09 d8                	or     %ebx,%eax
  8023e1:	f7 74 24 08          	divl   0x8(%esp)
  8023e5:	89 d1                	mov    %edx,%ecx
  8023e7:	89 f3                	mov    %esi,%ebx
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	89 c6                	mov    %eax,%esi
  8023ef:	89 d7                	mov    %edx,%edi
  8023f1:	39 d1                	cmp    %edx,%ecx
  8023f3:	72 06                	jb     8023fb <__umoddi3+0x10b>
  8023f5:	75 10                	jne    802407 <__umoddi3+0x117>
  8023f7:	39 c3                	cmp    %eax,%ebx
  8023f9:	73 0c                	jae    802407 <__umoddi3+0x117>
  8023fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802403:	89 d7                	mov    %edx,%edi
  802405:	89 c6                	mov    %eax,%esi
  802407:	89 ca                	mov    %ecx,%edx
  802409:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80240e:	29 f3                	sub    %esi,%ebx
  802410:	19 fa                	sbb    %edi,%edx
  802412:	89 d0                	mov    %edx,%eax
  802414:	d3 e0                	shl    %cl,%eax
  802416:	89 e9                	mov    %ebp,%ecx
  802418:	d3 eb                	shr    %cl,%ebx
  80241a:	d3 ea                	shr    %cl,%edx
  80241c:	09 d8                	or     %ebx,%eax
  80241e:	83 c4 1c             	add    $0x1c,%esp
  802421:	5b                   	pop    %ebx
  802422:	5e                   	pop    %esi
  802423:	5f                   	pop    %edi
  802424:	5d                   	pop    %ebp
  802425:	c3                   	ret    
  802426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	29 fe                	sub    %edi,%esi
  802432:	19 c3                	sbb    %eax,%ebx
  802434:	89 f2                	mov    %esi,%edx
  802436:	89 d9                	mov    %ebx,%ecx
  802438:	e9 1d ff ff ff       	jmp    80235a <__umoddi3+0x6a>
