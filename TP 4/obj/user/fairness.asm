
obj/user/fairness.debug:     formato del fichero elf32-i386


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
  80002c:	e8 74 00 00 00       	call   8000a5 <libmain>
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
  80003c:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003f:	e8 09 0b 00 00       	call   800b4d <sys_getenvid>
  800044:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800046:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  80004d:	00 c0 ee 
  800050:	74 2d                	je     80007f <umain+0x4c>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800052:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	53                   	push   %ebx
  80005c:	68 31 1e 80 00       	push   $0x801e31
  800061:	e8 48 01 00 00       	call   8001ae <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 d1 0c 00 00       	call   800d4b <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 4e 0c 00 00       	call   800cdd <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 20 1e 80 00       	push   $0x801e20
  80009b:	e8 0e 01 00 00       	call   8001ae <cprintf>
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	eb dd                	jmp    800082 <umain+0x4f>

008000a5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000b4:	e8 94 0a 00 00       	call   800b4d <sys_getenvid>
	if (id >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 12                	js     8000cf <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000bd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ca:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cf:	85 db                	test   %ebx,%ebx
  8000d1:	7e 07                	jle    8000da <libmain+0x35>
		binaryname = argv[0];
  8000d3:	8b 06                	mov    (%esi),%eax
  8000d5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	e8 4f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e4:	e8 0a 00 00 00       	call   8000f3 <exit>
}
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000fd:	e8 de 0e 00 00       	call   800fe0 <close_all>
	sys_env_destroy(0);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	6a 00                	push   $0x0
  800107:	e8 1b 0a 00 00       	call   800b27 <sys_env_destroy>
}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800111:	f3 0f 1e fb          	endbr32 
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	74 09                	je     80013d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800134:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 87 09 00 00       	call   800ad5 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	eb db                	jmp    800134 <putch+0x23>

00800159 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800166:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016d:	00 00 00 
	b.cnt = 0;
  800170:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800177:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017a:	ff 75 0c             	pushl  0xc(%ebp)
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	68 11 01 80 00       	push   $0x800111
  80018c:	e8 80 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800191:	83 c4 08             	add    $0x8,%esp
  800194:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a0:	50                   	push   %eax
  8001a1:	e8 2f 09 00 00       	call   800ad5 <sys_cputs>

	return b.cnt;
}
  8001a6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    

008001ae <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ae:	f3 0f 1e fb          	endbr32 
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bb:	50                   	push   %eax
  8001bc:	ff 75 08             	pushl  0x8(%ebp)
  8001bf:	e8 95 ff ff ff       	call   800159 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 1c             	sub    $0x1c,%esp
  8001cf:	89 c7                	mov    %eax,%edi
  8001d1:	89 d6                	mov    %edx,%esi
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 d1                	mov    %edx,%ecx
  8001db:	89 c2                	mov    %eax,%edx
  8001dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f3:	39 c2                	cmp    %eax,%edx
  8001f5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f8:	72 3e                	jb     800238 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	53                   	push   %ebx
  800204:	50                   	push   %eax
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 a7 19 00 00       	call   801bc0 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9f ff ff ff       	call   8001c6 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 13                	jmp    80023f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	7f ed                	jg     80022c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	83 ec 04             	sub    $0x4,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 79 1a 00 00       	call   801cd0 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800261:	50                   	push   %eax
  800262:	ff d7                	call   *%edi
}
  800264:	83 c4 10             	add    $0x10,%esp
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7f 13                	jg     800287 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800274:	85 d2                	test   %edx,%edx
  800276:	74 1c                	je     800294 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
  800286:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800287:	8b 10                	mov    (%eax),%edx
  800289:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 02                	mov    (%edx),%eax
  800290:	8b 52 04             	mov    0x4(%edx),%edx
  800293:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a2:	c3                   	ret    

008002a3 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002a3:	83 fa 01             	cmp    $0x1,%edx
  8002a6:	7f 0f                	jg     8002b7 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 18                	je     8002c4 <getint+0x21>
		return va_arg(*ap, long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	99                   	cltd   
  8002b6:	c3                   	ret    
		return va_arg(*ap, long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
  8002c3:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	99                   	cltd   
}
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	f3 0f 1e fb          	endbr32 
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e2:	73 0a                	jae    8002ee <sprintputch+0x1f>
		*b->buf++ = ch;
  8002e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	88 02                	mov    %al,(%edx)
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <printfmt>:
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fd:	50                   	push   %eax
  8002fe:	ff 75 10             	pushl  0x10(%ebp)
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	ff 75 08             	pushl  0x8(%ebp)
  800307:	e8 05 00 00 00       	call   800311 <vprintfmt>
}
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
{
  800311:	f3 0f 1e fb          	endbr32 
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 2c             	sub    $0x2c,%esp
  80031e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800321:	8b 75 0c             	mov    0xc(%ebp),%esi
  800324:	8b 7d 10             	mov    0x10(%ebp),%edi
  800327:	e9 86 02 00 00       	jmp    8005b2 <vprintfmt+0x2a1>
		padc = ' ';
  80032c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800330:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800337:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8d 47 01             	lea    0x1(%edi),%eax
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	0f b6 17             	movzbl (%edi),%edx
  800353:	8d 42 dd             	lea    -0x23(%edx),%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 df 02 00 00    	ja     80063d <vprintfmt+0x32c>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	3e ff 24 85 a0 1f 80 	notrack jmp *0x801fa0(,%eax,4)
  800368:	00 
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800370:	eb d8                	jmp    80034a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800379:	eb cf                	jmp    80034a <vprintfmt+0x39>
  80037b:	0f b6 d2             	movzbl %dl,%edx
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
  800386:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800389:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800390:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800393:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800396:	83 f9 09             	cmp    $0x9,%ecx
  800399:	77 52                	ja     8003ed <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80039b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80039e:	eb e9                	jmp    800389 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b5:	79 93                	jns    80034a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c4:	eb 84                	jmp    80034a <vprintfmt+0x39>
  8003c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d0:	0f 49 d0             	cmovns %eax,%edx
  8003d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d9:	e9 6c ff ff ff       	jmp    80034a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e8:	e9 5d ff ff ff       	jmp    80034a <vprintfmt+0x39>
  8003ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f3:	eb bc                	jmp    8003b1 <vprintfmt+0xa0>
			lflag++;
  8003f5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fb:	e9 4a ff ff ff       	jmp    80034a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	56                   	push   %esi
  80040d:	ff 30                	pushl  (%eax)
  80040f:	ff d3                	call   *%ebx
			break;
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	e9 96 01 00 00       	jmp    8005af <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	8b 00                	mov    (%eax),%eax
  800424:	99                   	cltd   
  800425:	31 d0                	xor    %edx,%eax
  800427:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800429:	83 f8 0f             	cmp    $0xf,%eax
  80042c:	7f 20                	jg     80044e <vprintfmt+0x13d>
  80042e:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	74 15                	je     80044e <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 49 22 80 00       	push   $0x802249
  80043f:	56                   	push   %esi
  800440:	53                   	push   %ebx
  800441:	e8 aa fe ff ff       	call   8002f0 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	e9 61 01 00 00       	jmp    8005af <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80044e:	50                   	push   %eax
  80044f:	68 6a 1e 80 00       	push   $0x801e6a
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	e8 95 fe ff ff       	call   8002f0 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	e9 4c 01 00 00       	jmp    8005af <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80046e:	85 c9                	test   %ecx,%ecx
  800470:	b8 63 1e 80 00       	mov    $0x801e63,%eax
  800475:	0f 45 c1             	cmovne %ecx,%eax
  800478:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80047b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047f:	7e 06                	jle    800487 <vprintfmt+0x176>
  800481:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800485:	75 0d                	jne    800494 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048a:	89 c7                	mov    %eax,%edi
  80048c:	03 45 e0             	add    -0x20(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	eb 57                	jmp    8004eb <vprintfmt+0x1da>
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	ff 75 d8             	pushl  -0x28(%ebp)
  80049a:	ff 75 cc             	pushl  -0x34(%ebp)
  80049d:	e8 4f 02 00 00       	call   8006f1 <strnlen>
  8004a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a5:	29 c2                	sub    %eax,%edx
  8004a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ad:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004b1:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004b4:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	85 db                	test   %ebx,%ebx
  8004b8:	7e 10                	jle    8004ca <vprintfmt+0x1b9>
					putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	57                   	push   %edi
  8004bf:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 eb 01             	sub    $0x1,%ebx
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb ec                	jmp    8004b6 <vprintfmt+0x1a5>
  8004ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c2             	cmovns %edx,%eax
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004df:	eb a6                	jmp    800487 <vprintfmt+0x176>
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	56                   	push   %esi
  8004e5:	52                   	push   %edx
  8004e6:	ff d3                	call   *%ebx
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ee:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f7:	0f be d0             	movsbl %al,%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 42                	je     800540 <vprintfmt+0x22f>
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	78 06                	js     80050a <vprintfmt+0x1f9>
  800504:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800508:	78 1e                	js     800528 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050e:	74 d1                	je     8004e1 <vprintfmt+0x1d0>
  800510:	0f be c0             	movsbl %al,%eax
  800513:	83 e8 20             	sub    $0x20,%eax
  800516:	83 f8 5e             	cmp    $0x5e,%eax
  800519:	76 c6                	jbe    8004e1 <vprintfmt+0x1d0>
					putch('?', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	56                   	push   %esi
  80051f:	6a 3f                	push   $0x3f
  800521:	ff d3                	call   *%ebx
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	eb c3                	jmp    8004eb <vprintfmt+0x1da>
  800528:	89 cf                	mov    %ecx,%edi
  80052a:	eb 0e                	jmp    80053a <vprintfmt+0x229>
				putch(' ', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	56                   	push   %esi
  800530:	6a 20                	push   $0x20
  800532:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ee                	jg     80052c <vprintfmt+0x21b>
  80053e:	eb 6f                	jmp    8005af <vprintfmt+0x29e>
  800540:	89 cf                	mov    %ecx,%edi
  800542:	eb f6                	jmp    80053a <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800544:	89 ca                	mov    %ecx,%edx
  800546:	8d 45 14             	lea    0x14(%ebp),%eax
  800549:	e8 55 fd ff ff       	call   8002a3 <getint>
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800554:	85 d2                	test   %edx,%edx
  800556:	78 0b                	js     800563 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800558:	89 d1                	mov    %edx,%ecx
  80055a:	89 c2                	mov    %eax,%edx
			base = 10;
  80055c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800561:	eb 32                	jmp    800595 <vprintfmt+0x284>
				putch('-', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	56                   	push   %esi
  800567:	6a 2d                	push   $0x2d
  800569:	ff d3                	call   *%ebx
				num = -(long long) num;
  80056b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800571:	f7 da                	neg    %edx
  800573:	83 d1 00             	adc    $0x0,%ecx
  800576:	f7 d9                	neg    %ecx
  800578:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80057b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800580:	eb 13                	jmp    800595 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800582:	89 ca                	mov    %ecx,%edx
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	e8 e3 fc ff ff       	call   80026f <getuint>
  80058c:	89 d1                	mov    %edx,%ecx
  80058e:	89 c2                	mov    %eax,%edx
			base = 10;
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800595:	83 ec 0c             	sub    $0xc,%esp
  800598:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80059c:	57                   	push   %edi
  80059d:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a0:	50                   	push   %eax
  8005a1:	51                   	push   %ecx
  8005a2:	52                   	push   %edx
  8005a3:	89 f2                	mov    %esi,%edx
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	e8 1a fc ff ff       	call   8001c6 <printnum>
			break;
  8005ac:	83 c4 20             	add    $0x20,%esp
{
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b2:	83 c7 01             	add    $0x1,%edi
  8005b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b9:	83 f8 25             	cmp    $0x25,%eax
  8005bc:	0f 84 6a fd ff ff    	je     80032c <vprintfmt+0x1b>
			if (ch == '\0')
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	0f 84 93 00 00 00    	je     80065d <vprintfmt+0x34c>
			putch(ch, putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	56                   	push   %esi
  8005ce:	50                   	push   %eax
  8005cf:	ff d3                	call   *%ebx
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb dc                	jmp    8005b2 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005d6:	89 ca                	mov    %ecx,%edx
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 8f fc ff ff       	call   80026f <getuint>
  8005e0:	89 d1                	mov    %edx,%ecx
  8005e2:	89 c2                	mov    %eax,%edx
			base = 8;
  8005e4:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005e9:	eb aa                	jmp    800595 <vprintfmt+0x284>
			putch('0', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	56                   	push   %esi
  8005ef:	6a 30                	push   $0x30
  8005f1:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	56                   	push   %esi
  8005f7:	6a 78                	push   $0x78
  8005f9:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800604:	8b 10                	mov    (%eax),%edx
  800606:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80060b:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80060e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800613:	eb 80                	jmp    800595 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800615:	89 ca                	mov    %ecx,%edx
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 50 fc ff ff       	call   80026f <getuint>
  80061f:	89 d1                	mov    %edx,%ecx
  800621:	89 c2                	mov    %eax,%edx
			base = 16;
  800623:	b8 10 00 00 00       	mov    $0x10,%eax
  800628:	e9 68 ff ff ff       	jmp    800595 <vprintfmt+0x284>
			putch(ch, putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	56                   	push   %esi
  800631:	6a 25                	push   $0x25
  800633:	ff d3                	call   *%ebx
			break;
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	e9 72 ff ff ff       	jmp    8005af <vprintfmt+0x29e>
			putch('%', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	56                   	push   %esi
  800641:	6a 25                	push   $0x25
  800643:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
  80064a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80064e:	74 05                	je     800655 <vprintfmt+0x344>
  800650:	83 e8 01             	sub    $0x1,%eax
  800653:	eb f5                	jmp    80064a <vprintfmt+0x339>
  800655:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800658:	e9 52 ff ff ff       	jmp    8005af <vprintfmt+0x29e>
}
  80065d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800660:	5b                   	pop    %ebx
  800661:	5e                   	pop    %esi
  800662:	5f                   	pop    %edi
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800665:	f3 0f 1e fb          	endbr32 
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	83 ec 18             	sub    $0x18,%esp
  80066f:	8b 45 08             	mov    0x8(%ebp),%eax
  800672:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800675:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800678:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800686:	85 c0                	test   %eax,%eax
  800688:	74 26                	je     8006b0 <vsnprintf+0x4b>
  80068a:	85 d2                	test   %edx,%edx
  80068c:	7e 22                	jle    8006b0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068e:	ff 75 14             	pushl  0x14(%ebp)
  800691:	ff 75 10             	pushl  0x10(%ebp)
  800694:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800697:	50                   	push   %eax
  800698:	68 cf 02 80 00       	push   $0x8002cf
  80069d:	e8 6f fc ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ab:	83 c4 10             	add    $0x10,%esp
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    
		return -E_INVAL;
  8006b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b5:	eb f7                	jmp    8006ae <vsnprintf+0x49>

008006b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b7:	f3 0f 1e fb          	endbr32 
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c4:	50                   	push   %eax
  8006c5:	ff 75 10             	pushl  0x10(%ebp)
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	ff 75 08             	pushl  0x8(%ebp)
  8006ce:	e8 92 ff ff ff       	call   800665 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d5:	f3 0f 1e fb          	endbr32 
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e8:	74 05                	je     8006ef <strlen+0x1a>
		n++;
  8006ea:	83 c0 01             	add    $0x1,%eax
  8006ed:	eb f5                	jmp    8006e4 <strlen+0xf>
	return n;
}
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f1:	f3 0f 1e fb          	endbr32 
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	39 d0                	cmp    %edx,%eax
  800705:	74 0d                	je     800714 <strnlen+0x23>
  800707:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070b:	74 05                	je     800712 <strnlen+0x21>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
  800710:	eb f1                	jmp    800703 <strnlen+0x12>
  800712:	89 c2                	mov    %eax,%edx
	return n;
}
  800714:	89 d0                	mov    %edx,%eax
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800718:	f3 0f 1e fb          	endbr32 
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800723:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80072f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800732:	83 c0 01             	add    $0x1,%eax
  800735:	84 d2                	test   %dl,%dl
  800737:	75 f2                	jne    80072b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800739:	89 c8                	mov    %ecx,%eax
  80073b:	5b                   	pop    %ebx
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073e:	f3 0f 1e fb          	endbr32 
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	53                   	push   %ebx
  800746:	83 ec 10             	sub    $0x10,%esp
  800749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074c:	53                   	push   %ebx
  80074d:	e8 83 ff ff ff       	call   8006d5 <strlen>
  800752:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	01 d8                	add    %ebx,%eax
  80075a:	50                   	push   %eax
  80075b:	e8 b8 ff ff ff       	call   800718 <strcpy>
	return dst;
}
  800760:	89 d8                	mov    %ebx,%eax
  800762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	f3 0f 1e fb          	endbr32 
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	56                   	push   %esi
  80076f:	53                   	push   %ebx
  800770:	8b 75 08             	mov    0x8(%ebp),%esi
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
  800776:	89 f3                	mov    %esi,%ebx
  800778:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	39 d8                	cmp    %ebx,%eax
  80077f:	74 11                	je     800792 <strncpy+0x2b>
		*dst++ = *src;
  800781:	83 c0 01             	add    $0x1,%eax
  800784:	0f b6 0a             	movzbl (%edx),%ecx
  800787:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078a:	80 f9 01             	cmp    $0x1,%cl
  80078d:	83 da ff             	sbb    $0xffffffff,%edx
  800790:	eb eb                	jmp    80077d <strncpy+0x16>
	}
	return ret;
}
  800792:	89 f0                	mov    %esi,%eax
  800794:	5b                   	pop    %ebx
  800795:	5e                   	pop    %esi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800798:	f3 0f 1e fb          	endbr32 
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 21                	je     8007d1 <strlcpy+0x39>
  8007b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007b6:	39 c2                	cmp    %eax,%edx
  8007b8:	74 14                	je     8007ce <strlcpy+0x36>
  8007ba:	0f b6 19             	movzbl (%ecx),%ebx
  8007bd:	84 db                	test   %bl,%bl
  8007bf:	74 0b                	je     8007cc <strlcpy+0x34>
			*dst++ = *src++;
  8007c1:	83 c1 01             	add    $0x1,%ecx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ca:	eb ea                	jmp    8007b6 <strlcpy+0x1e>
  8007cc:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d1:	29 f0                	sub    %esi,%eax
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d7:	f3 0f 1e fb          	endbr32 
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e4:	0f b6 01             	movzbl (%ecx),%eax
  8007e7:	84 c0                	test   %al,%al
  8007e9:	74 0c                	je     8007f7 <strcmp+0x20>
  8007eb:	3a 02                	cmp    (%edx),%al
  8007ed:	75 08                	jne    8007f7 <strcmp+0x20>
		p++, q++;
  8007ef:	83 c1 01             	add    $0x1,%ecx
  8007f2:	83 c2 01             	add    $0x1,%edx
  8007f5:	eb ed                	jmp    8007e4 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f7:	0f b6 c0             	movzbl %al,%eax
  8007fa:	0f b6 12             	movzbl (%edx),%edx
  8007fd:	29 d0                	sub    %edx,%eax
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800801:	f3 0f 1e fb          	endbr32 
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080f:	89 c3                	mov    %eax,%ebx
  800811:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800814:	eb 06                	jmp    80081c <strncmp+0x1b>
		n--, p++, q++;
  800816:	83 c0 01             	add    $0x1,%eax
  800819:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80081c:	39 d8                	cmp    %ebx,%eax
  80081e:	74 16                	je     800836 <strncmp+0x35>
  800820:	0f b6 08             	movzbl (%eax),%ecx
  800823:	84 c9                	test   %cl,%cl
  800825:	74 04                	je     80082b <strncmp+0x2a>
  800827:	3a 0a                	cmp    (%edx),%cl
  800829:	74 eb                	je     800816 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f b6 12             	movzbl (%edx),%edx
  800831:	29 d0                	sub    %edx,%eax
}
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb f6                	jmp    800833 <strncmp+0x32>

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	f3 0f 1e fb          	endbr32 
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	0f b6 10             	movzbl (%eax),%edx
  80084e:	84 d2                	test   %dl,%dl
  800850:	74 09                	je     80085b <strchr+0x1e>
		if (*s == c)
  800852:	38 ca                	cmp    %cl,%dl
  800854:	74 0a                	je     800860 <strchr+0x23>
	for (; *s; s++)
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	eb f0                	jmp    80084b <strchr+0xe>
			return (char *) s;
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800862:	f3 0f 1e fb          	endbr32 
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800870:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800873:	38 ca                	cmp    %cl,%dl
  800875:	74 09                	je     800880 <strfind+0x1e>
  800877:	84 d2                	test   %dl,%dl
  800879:	74 05                	je     800880 <strfind+0x1e>
	for (; *s; s++)
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	eb f0                	jmp    800870 <strfind+0xe>
			break;
	return (char *) s;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800882:	f3 0f 1e fb          	endbr32 
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	57                   	push   %edi
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 55 08             	mov    0x8(%ebp),%edx
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800892:	85 c9                	test   %ecx,%ecx
  800894:	74 33                	je     8008c9 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800896:	89 d0                	mov    %edx,%eax
  800898:	09 c8                	or     %ecx,%eax
  80089a:	a8 03                	test   $0x3,%al
  80089c:	75 23                	jne    8008c1 <memset+0x3f>
		c &= 0xFF;
  80089e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a2:	89 d8                	mov    %ebx,%eax
  8008a4:	c1 e0 08             	shl    $0x8,%eax
  8008a7:	89 df                	mov    %ebx,%edi
  8008a9:	c1 e7 18             	shl    $0x18,%edi
  8008ac:	89 de                	mov    %ebx,%esi
  8008ae:	c1 e6 10             	shl    $0x10,%esi
  8008b1:	09 f7                	or     %esi,%edi
  8008b3:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008ba:	89 d7                	mov    %edx,%edi
  8008bc:	fc                   	cld    
  8008bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bf:	eb 08                	jmp    8008c9 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	89 d7                	mov    %edx,%edi
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c6:	fc                   	cld    
  8008c7:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d0:	f3 0f 1e fb          	endbr32 
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e2:	39 c6                	cmp    %eax,%esi
  8008e4:	73 32                	jae    800918 <memmove+0x48>
  8008e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e9:	39 c2                	cmp    %eax,%edx
  8008eb:	76 2b                	jbe    800918 <memmove+0x48>
		s += n;
		d += n;
  8008ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	89 fe                	mov    %edi,%esi
  8008f2:	09 ce                	or     %ecx,%esi
  8008f4:	09 d6                	or     %edx,%esi
  8008f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fc:	75 0e                	jne    80090c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fe:	83 ef 04             	sub    $0x4,%edi
  800901:	8d 72 fc             	lea    -0x4(%edx),%esi
  800904:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800907:	fd                   	std    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 09                	jmp    800915 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090c:	83 ef 01             	sub    $0x1,%edi
  80090f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800912:	fd                   	std    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800915:	fc                   	cld    
  800916:	eb 1a                	jmp    800932 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	89 c2                	mov    %eax,%edx
  80091a:	09 ca                	or     %ecx,%edx
  80091c:	09 f2                	or     %esi,%edx
  80091e:	f6 c2 03             	test   $0x3,%dl
  800921:	75 0a                	jne    80092d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800923:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 05                	jmp    800932 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800940:	ff 75 10             	pushl  0x10(%ebp)
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	ff 75 08             	pushl  0x8(%ebp)
  800949:	e8 82 ff ff ff       	call   8008d0 <memmove>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	89 c6                	mov    %eax,%esi
  800961:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800964:	39 f0                	cmp    %esi,%eax
  800966:	74 1c                	je     800984 <memcmp+0x34>
		if (*s1 != *s2)
  800968:	0f b6 08             	movzbl (%eax),%ecx
  80096b:	0f b6 1a             	movzbl (%edx),%ebx
  80096e:	38 d9                	cmp    %bl,%cl
  800970:	75 08                	jne    80097a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	eb ea                	jmp    800964 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80097a:	0f b6 c1             	movzbl %cl,%eax
  80097d:	0f b6 db             	movzbl %bl,%ebx
  800980:	29 d8                	sub    %ebx,%eax
  800982:	eb 05                	jmp    800989 <memcmp+0x39>
	}

	return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098d:	f3 0f 1e fb          	endbr32 
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099f:	39 d0                	cmp    %edx,%eax
  8009a1:	73 09                	jae    8009ac <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a3:	38 08                	cmp    %cl,(%eax)
  8009a5:	74 05                	je     8009ac <memfind+0x1f>
	for (; s < ends; s++)
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	eb f3                	jmp    80099f <memfind+0x12>
			break;
	return (void *) s;
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	f3 0f 1e fb          	endbr32 
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009be:	eb 03                	jmp    8009c3 <strtol+0x15>
		s++;
  8009c0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009c3:	0f b6 01             	movzbl (%ecx),%eax
  8009c6:	3c 20                	cmp    $0x20,%al
  8009c8:	74 f6                	je     8009c0 <strtol+0x12>
  8009ca:	3c 09                	cmp    $0x9,%al
  8009cc:	74 f2                	je     8009c0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009ce:	3c 2b                	cmp    $0x2b,%al
  8009d0:	74 2a                	je     8009fc <strtol+0x4e>
	int neg = 0;
  8009d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009d7:	3c 2d                	cmp    $0x2d,%al
  8009d9:	74 2b                	je     800a06 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009db:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e1:	75 0f                	jne    8009f2 <strtol+0x44>
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	74 28                	je     800a10 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e8:	85 db                	test   %ebx,%ebx
  8009ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ef:	0f 44 d8             	cmove  %eax,%ebx
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009fa:	eb 46                	jmp    800a42 <strtol+0x94>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb d5                	jmp    8009db <strtol+0x2d>
		s++, neg = 1;
  800a06:	83 c1 01             	add    $0x1,%ecx
  800a09:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0e:	eb cb                	jmp    8009db <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a10:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a14:	74 0e                	je     800a24 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a16:	85 db                	test   %ebx,%ebx
  800a18:	75 d8                	jne    8009f2 <strtol+0x44>
		s++, base = 8;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a22:	eb ce                	jmp    8009f2 <strtol+0x44>
		s += 2, base = 16;
  800a24:	83 c1 02             	add    $0x2,%ecx
  800a27:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2c:	eb c4                	jmp    8009f2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a2e:	0f be d2             	movsbl %dl,%edx
  800a31:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a34:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a37:	7d 3a                	jge    800a73 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a40:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a42:	0f b6 11             	movzbl (%ecx),%edx
  800a45:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 09             	cmp    $0x9,%bl
  800a4d:	76 df                	jbe    800a2e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a4f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a52:	89 f3                	mov    %esi,%ebx
  800a54:	80 fb 19             	cmp    $0x19,%bl
  800a57:	77 08                	ja     800a61 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a59:	0f be d2             	movsbl %dl,%edx
  800a5c:	83 ea 57             	sub    $0x57,%edx
  800a5f:	eb d3                	jmp    800a34 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a61:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a64:	89 f3                	mov    %esi,%ebx
  800a66:	80 fb 19             	cmp    $0x19,%bl
  800a69:	77 08                	ja     800a73 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a6b:	0f be d2             	movsbl %dl,%edx
  800a6e:	83 ea 37             	sub    $0x37,%edx
  800a71:	eb c1                	jmp    800a34 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a73:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a77:	74 05                	je     800a7e <strtol+0xd0>
		*endptr = (char *) s;
  800a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	f7 da                	neg    %edx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	0f 45 c2             	cmovne %edx,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	83 ec 1c             	sub    $0x1c,%esp
  800a95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a9b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa3:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aa6:	8b 75 14             	mov    0x14(%ebp),%esi
  800aa9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800aaf:	74 04                	je     800ab5 <syscall+0x29>
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	7f 08                	jg     800abd <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800abd:	83 ec 0c             	sub    $0xc,%esp
  800ac0:	50                   	push   %eax
  800ac1:	ff 75 e0             	pushl  -0x20(%ebp)
  800ac4:	68 5f 21 80 00       	push   $0x80215f
  800ac9:	6a 23                	push   $0x23
  800acb:	68 7c 21 80 00       	push   $0x80217c
  800ad0:	e8 61 10 00 00       	call   801b36 <_panic>

00800ad5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ad5:	f3 0f 1e fb          	endbr32 
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800adf:	6a 00                	push   $0x0
  800ae1:	6a 00                	push   $0x0
  800ae3:	6a 00                	push   $0x0
  800ae5:	ff 75 0c             	pushl  0xc(%ebp)
  800ae8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	e8 92 ff ff ff       	call   800a8c <syscall>
}
  800afa:	83 c4 10             	add    $0x10,%esp
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <sys_cgetc>:

int
sys_cgetc(void)
{
  800aff:	f3 0f 1e fb          	endbr32 
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b09:	6a 00                	push   $0x0
  800b0b:	6a 00                	push   $0x0
  800b0d:	6a 00                	push   $0x0
  800b0f:	6a 00                	push   $0x0
  800b11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	e8 67 ff ff ff       	call   800a8c <syscall>
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b27:	f3 0f 1e fb          	endbr32 
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	6a 00                	push   $0x0
  800b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b41:	b8 03 00 00 00       	mov    $0x3,%eax
  800b46:	e8 41 ff ff ff       	call   800a8c <syscall>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	f3 0f 1e fb          	endbr32 
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	6a 00                	push   $0x0
  800b5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6e:	e8 19 ff ff ff       	call   800a8c <syscall>
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <sys_yield>:

void
sys_yield(void)
{
  800b75:	f3 0f 1e fb          	endbr32 
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	6a 00                	push   $0x0
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b96:	e8 f1 fe ff ff       	call   800a8c <syscall>
}
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba0:	f3 0f 1e fb          	endbr32 
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	ff 75 10             	pushl  0x10(%ebp)
  800bb1:	ff 75 0c             	pushl  0xc(%ebp)
  800bb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	e8 c6 fe ff ff       	call   800a8c <syscall>
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc8:	f3 0f 1e fb          	endbr32 
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bd2:	ff 75 18             	pushl  0x18(%ebp)
  800bd5:	ff 75 14             	pushl  0x14(%ebp)
  800bd8:	ff 75 10             	pushl  0x10(%ebp)
  800bdb:	ff 75 0c             	pushl  0xc(%ebp)
  800bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be1:	ba 01 00 00 00       	mov    $0x1,%edx
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	e8 9c fe ff ff       	call   800a8c <syscall>
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf2:	f3 0f 1e fb          	endbr32 
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bfc:	6a 00                	push   $0x0
  800bfe:	6a 00                	push   $0x0
  800c00:	6a 00                	push   $0x0
  800c02:	ff 75 0c             	pushl  0xc(%ebp)
  800c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c08:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c12:	e8 75 fe ff ff       	call   800a8c <syscall>
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c19:	f3 0f 1e fb          	endbr32 
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c23:	6a 00                	push   $0x0
  800c25:	6a 00                	push   $0x0
  800c27:	6a 00                	push   $0x0
  800c29:	ff 75 0c             	pushl  0xc(%ebp)
  800c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c34:	b8 08 00 00 00       	mov    $0x8,%eax
  800c39:	e8 4e fe ff ff       	call   800a8c <syscall>
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c40:	f3 0f 1e fb          	endbr32 
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	6a 00                	push   $0x0
  800c50:	ff 75 0c             	pushl  0xc(%ebp)
  800c53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c56:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c60:	e8 27 fe ff ff       	call   800a8c <syscall>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	ff 75 0c             	pushl  0xc(%ebp)
  800c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c87:	e8 00 fe ff ff       	call   800a8c <syscall>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8e:	f3 0f 1e fb          	endbr32 
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c98:	6a 00                	push   $0x0
  800c9a:	ff 75 14             	pushl  0x14(%ebp)
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb0:	e8 d7 fd ff ff       	call   800a8c <syscall>
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb7:	f3 0f 1e fb          	endbr32 
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	6a 00                	push   $0x0
  800cc7:	6a 00                	push   $0x0
  800cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccc:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd6:	e8 b1 fd ff ff       	call   800a8c <syscall>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800cdd:	f3 0f 1e fb          	endbr32 
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800cf6:	0f 44 c2             	cmove  %edx,%eax
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	e8 b5 ff ff ff       	call   800cb7 <sys_ipc_recv>

	if (from_env_store != NULL)
  800d02:	83 c4 10             	add    $0x10,%esp
  800d05:	85 f6                	test   %esi,%esi
  800d07:	74 15                	je     800d1e <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800d11:	74 09                	je     800d1c <ipc_recv+0x3f>
  800d13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d19:	8b 52 74             	mov    0x74(%edx),%edx
  800d1c:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  800d1e:	85 db                	test   %ebx,%ebx
  800d20:	74 15                	je     800d37 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800d2a:	74 09                	je     800d35 <ipc_recv+0x58>
  800d2c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d32:	8b 52 78             	mov    0x78(%edx),%edx
  800d35:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  800d37:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800d3a:	74 08                	je     800d44 <ipc_recv+0x67>
  800d3c:	a1 04 40 80 00       	mov    0x804004,%eax
  800d41:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	eb 1f                	jmp    800d82 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  800d63:	6a 00                	push   $0x0
  800d65:	68 00 00 c0 ee       	push   $0xeec00000
  800d6a:	56                   	push   %esi
  800d6b:	57                   	push   %edi
  800d6c:	e8 1d ff ff ff       	call   800c8e <sys_ipc_try_send>
  800d71:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	74 30                	je     800da8 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  800d78:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800d7b:	75 19                	jne    800d96 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  800d7d:	e8 f3 fd ff ff       	call   800b75 <sys_yield>
		if (pg != NULL) {
  800d82:	85 db                	test   %ebx,%ebx
  800d84:	74 dd                	je     800d63 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  800d86:	ff 75 14             	pushl  0x14(%ebp)
  800d89:	53                   	push   %ebx
  800d8a:	56                   	push   %esi
  800d8b:	57                   	push   %edi
  800d8c:	e8 fd fe ff ff       	call   800c8e <sys_ipc_try_send>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	eb de                	jmp    800d74 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  800d96:	50                   	push   %eax
  800d97:	68 8a 21 80 00       	push   $0x80218a
  800d9c:	6a 3e                	push   $0x3e
  800d9e:	68 97 21 80 00       	push   $0x802197
  800da3:	e8 8e 0d 00 00       	call   801b36 <_panic>
	}
}
  800da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800dbf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800dc2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dc8:	8b 52 50             	mov    0x50(%edx),%edx
  800dcb:	39 ca                	cmp    %ecx,%edx
  800dcd:	74 11                	je     800de0 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  800dcf:	83 c0 01             	add    $0x1,%eax
  800dd2:	3d 00 04 00 00       	cmp    $0x400,%eax
  800dd7:	75 e6                	jne    800dbf <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	eb 0b                	jmp    800deb <ipc_find_env+0x3b>
			return envs[i].env_id;
  800de0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800de3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800de8:	8b 40 48             	mov    0x48(%eax),%eax
}
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ded:	f3 0f 1e fb          	endbr32 
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfc:	c1 e8 0c             	shr    $0xc,%eax
}
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e01:	f3 0f 1e fb          	endbr32 
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800e0b:	ff 75 08             	pushl  0x8(%ebp)
  800e0e:	e8 da ff ff ff       	call   800ded <fd2num>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	c1 e0 0c             	shl    $0xc,%eax
  800e19:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	c1 ea 16             	shr    $0x16,%edx
  800e31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e38:	f6 c2 01             	test   $0x1,%dl
  800e3b:	74 2d                	je     800e6a <fd_alloc+0x4a>
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	c1 ea 0c             	shr    $0xc,%edx
  800e42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e49:	f6 c2 01             	test   $0x1,%dl
  800e4c:	74 1c                	je     800e6a <fd_alloc+0x4a>
  800e4e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e53:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e58:	75 d2                	jne    800e2c <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e63:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e68:	eb 0a                	jmp    800e74 <fd_alloc+0x54>
			*fd_store = fd;
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e76:	f3 0f 1e fb          	endbr32 
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e80:	83 f8 1f             	cmp    $0x1f,%eax
  800e83:	77 30                	ja     800eb5 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e85:	c1 e0 0c             	shl    $0xc,%eax
  800e88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e93:	f6 c2 01             	test   $0x1,%dl
  800e96:	74 24                	je     800ebc <fd_lookup+0x46>
  800e98:	89 c2                	mov    %eax,%edx
  800e9a:	c1 ea 0c             	shr    $0xc,%edx
  800e9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea4:	f6 c2 01             	test   $0x1,%dl
  800ea7:	74 1a                	je     800ec3 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eac:	89 02                	mov    %eax,(%edx)
	return 0;
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
		return -E_INVAL;
  800eb5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eba:	eb f7                	jmp    800eb3 <fd_lookup+0x3d>
		return -E_INVAL;
  800ebc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec1:	eb f0                	jmp    800eb3 <fd_lookup+0x3d>
  800ec3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec8:	eb e9                	jmp    800eb3 <fd_lookup+0x3d>

00800eca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eca:	f3 0f 1e fb          	endbr32 
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 08             	sub    $0x8,%esp
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed7:	ba 20 22 80 00       	mov    $0x802220,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ee1:	39 08                	cmp    %ecx,(%eax)
  800ee3:	74 33                	je     800f18 <dev_lookup+0x4e>
  800ee5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ee8:	8b 02                	mov    (%edx),%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	75 f3                	jne    800ee1 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eee:	a1 04 40 80 00       	mov    0x804004,%eax
  800ef3:	8b 40 48             	mov    0x48(%eax),%eax
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	51                   	push   %ecx
  800efa:	50                   	push   %eax
  800efb:	68 a4 21 80 00       	push   $0x8021a4
  800f00:	e8 a9 f2 ff ff       	call   8001ae <cprintf>
	*dev = 0;
  800f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    
			*dev = devtab[i];
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	eb f2                	jmp    800f16 <dev_lookup+0x4c>

00800f24 <fd_close>:
{
  800f24:	f3 0f 1e fb          	endbr32 
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 28             	sub    $0x28,%esp
  800f31:	8b 75 08             	mov    0x8(%ebp),%esi
  800f34:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f37:	56                   	push   %esi
  800f38:	e8 b0 fe ff ff       	call   800ded <fd2num>
  800f3d:	83 c4 08             	add    $0x8,%esp
  800f40:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f43:	52                   	push   %edx
  800f44:	50                   	push   %eax
  800f45:	e8 2c ff ff ff       	call   800e76 <fd_lookup>
  800f4a:	89 c3                	mov    %eax,%ebx
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 05                	js     800f58 <fd_close+0x34>
	    || fd != fd2)
  800f53:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f56:	74 16                	je     800f6e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f58:	89 f8                	mov    %edi,%eax
  800f5a:	84 c0                	test   %al,%al
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	0f 44 d8             	cmove  %eax,%ebx
}
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 36                	pushl  (%esi)
  800f77:	e8 4e ff ff ff       	call   800eca <dev_lookup>
  800f7c:	89 c3                	mov    %eax,%ebx
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 1a                	js     800f9f <fd_close+0x7b>
		if (dev->dev_close)
  800f85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f88:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f8b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	74 0b                	je     800f9f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	56                   	push   %esi
  800f98:	ff d0                	call   *%eax
  800f9a:	89 c3                	mov    %eax,%ebx
  800f9c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 48 fc ff ff       	call   800bf2 <sys_page_unmap>
	return r;
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	eb b5                	jmp    800f64 <fd_close+0x40>

00800faf <close>:

int
close(int fdnum)
{
  800faf:	f3 0f 1e fb          	endbr32 
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	ff 75 08             	pushl  0x8(%ebp)
  800fc0:	e8 b1 fe ff ff       	call   800e76 <fd_lookup>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 02                	jns    800fce <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    
		return fd_close(fd, 1);
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	6a 01                	push   $0x1
  800fd3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd6:	e8 49 ff ff ff       	call   800f24 <fd_close>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	eb ec                	jmp    800fcc <close+0x1d>

00800fe0 <close_all>:

void
close_all(void)
{
  800fe0:	f3 0f 1e fb          	endbr32 
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	53                   	push   %ebx
  800ff4:	e8 b6 ff ff ff       	call   800faf <close>
	for (i = 0; i < MAXFD; i++)
  800ff9:	83 c3 01             	add    $0x1,%ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	83 fb 20             	cmp    $0x20,%ebx
  801002:	75 ec                	jne    800ff0 <close_all+0x10>
}
  801004:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801009:	f3 0f 1e fb          	endbr32 
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801016:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801019:	50                   	push   %eax
  80101a:	ff 75 08             	pushl  0x8(%ebp)
  80101d:	e8 54 fe ff ff       	call   800e76 <fd_lookup>
  801022:	89 c3                	mov    %eax,%ebx
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	0f 88 81 00 00 00    	js     8010b0 <dup+0xa7>
		return r;
	close(newfdnum);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	ff 75 0c             	pushl  0xc(%ebp)
  801035:	e8 75 ff ff ff       	call   800faf <close>

	newfd = INDEX2FD(newfdnum);
  80103a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80103d:	c1 e6 0c             	shl    $0xc,%esi
  801040:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801046:	83 c4 04             	add    $0x4,%esp
  801049:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104c:	e8 b0 fd ff ff       	call   800e01 <fd2data>
  801051:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801053:	89 34 24             	mov    %esi,(%esp)
  801056:	e8 a6 fd ff ff       	call   800e01 <fd2data>
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801060:	89 d8                	mov    %ebx,%eax
  801062:	c1 e8 16             	shr    $0x16,%eax
  801065:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106c:	a8 01                	test   $0x1,%al
  80106e:	74 11                	je     801081 <dup+0x78>
  801070:	89 d8                	mov    %ebx,%eax
  801072:	c1 e8 0c             	shr    $0xc,%eax
  801075:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107c:	f6 c2 01             	test   $0x1,%dl
  80107f:	75 39                	jne    8010ba <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801081:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801084:	89 d0                	mov    %edx,%eax
  801086:	c1 e8 0c             	shr    $0xc,%eax
  801089:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	25 07 0e 00 00       	and    $0xe07,%eax
  801098:	50                   	push   %eax
  801099:	56                   	push   %esi
  80109a:	6a 00                	push   $0x0
  80109c:	52                   	push   %edx
  80109d:	6a 00                	push   $0x0
  80109f:	e8 24 fb ff ff       	call   800bc8 <sys_page_map>
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 31                	js     8010de <dup+0xd5>
		goto err;

	return newfdnum;
  8010ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c9:	50                   	push   %eax
  8010ca:	57                   	push   %edi
  8010cb:	6a 00                	push   $0x0
  8010cd:	53                   	push   %ebx
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 f3 fa ff ff       	call   800bc8 <sys_page_map>
  8010d5:	89 c3                	mov    %eax,%ebx
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 a3                	jns    801081 <dup+0x78>
	sys_page_unmap(0, newfd);
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	56                   	push   %esi
  8010e2:	6a 00                	push   $0x0
  8010e4:	e8 09 fb ff ff       	call   800bf2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	57                   	push   %edi
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 fe fa ff ff       	call   800bf2 <sys_page_unmap>
	return r;
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	eb b7                	jmp    8010b0 <dup+0xa7>

008010f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f9:	f3 0f 1e fb          	endbr32 
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	53                   	push   %ebx
  801101:	83 ec 1c             	sub    $0x1c,%esp
  801104:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801107:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	53                   	push   %ebx
  80110c:	e8 65 fd ff ff       	call   800e76 <fd_lookup>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 3f                	js     801157 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801122:	ff 30                	pushl  (%eax)
  801124:	e8 a1 fd ff ff       	call   800eca <dev_lookup>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 27                	js     801157 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801130:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801133:	8b 42 08             	mov    0x8(%edx),%eax
  801136:	83 e0 03             	and    $0x3,%eax
  801139:	83 f8 01             	cmp    $0x1,%eax
  80113c:	74 1e                	je     80115c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80113e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801141:	8b 40 08             	mov    0x8(%eax),%eax
  801144:	85 c0                	test   %eax,%eax
  801146:	74 35                	je     80117d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	ff 75 10             	pushl  0x10(%ebp)
  80114e:	ff 75 0c             	pushl  0xc(%ebp)
  801151:	52                   	push   %edx
  801152:	ff d0                	call   *%eax
  801154:	83 c4 10             	add    $0x10,%esp
}
  801157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115c:	a1 04 40 80 00       	mov    0x804004,%eax
  801161:	8b 40 48             	mov    0x48(%eax),%eax
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	53                   	push   %ebx
  801168:	50                   	push   %eax
  801169:	68 e5 21 80 00       	push   $0x8021e5
  80116e:	e8 3b f0 ff ff       	call   8001ae <cprintf>
		return -E_INVAL;
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb da                	jmp    801157 <read+0x5e>
		return -E_NOT_SUPP;
  80117d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801182:	eb d3                	jmp    801157 <read+0x5e>

00801184 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801184:	f3 0f 1e fb          	endbr32 
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	8b 7d 08             	mov    0x8(%ebp),%edi
  801194:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	eb 02                	jmp    8011a0 <readn+0x1c>
  80119e:	01 c3                	add    %eax,%ebx
  8011a0:	39 f3                	cmp    %esi,%ebx
  8011a2:	73 21                	jae    8011c5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	89 f0                	mov    %esi,%eax
  8011a9:	29 d8                	sub    %ebx,%eax
  8011ab:	50                   	push   %eax
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	03 45 0c             	add    0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	57                   	push   %edi
  8011b3:	e8 41 ff ff ff       	call   8010f9 <read>
		if (m < 0)
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 04                	js     8011c3 <readn+0x3f>
			return m;
		if (m == 0)
  8011bf:	75 dd                	jne    80119e <readn+0x1a>
  8011c1:	eb 02                	jmp    8011c5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011cf:	f3 0f 1e fb          	endbr32 
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 1c             	sub    $0x1c,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	53                   	push   %ebx
  8011e2:	e8 8f fc ff ff       	call   800e76 <fd_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 3a                	js     801228 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	ff 30                	pushl  (%eax)
  8011fa:	e8 cb fc ff ff       	call   800eca <dev_lookup>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 22                	js     801228 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120d:	74 1e                	je     80122d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801212:	8b 52 0c             	mov    0xc(%edx),%edx
  801215:	85 d2                	test   %edx,%edx
  801217:	74 35                	je     80124e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	ff 75 10             	pushl  0x10(%ebp)
  80121f:	ff 75 0c             	pushl  0xc(%ebp)
  801222:	50                   	push   %eax
  801223:	ff d2                	call   *%edx
  801225:	83 c4 10             	add    $0x10,%esp
}
  801228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122d:	a1 04 40 80 00       	mov    0x804004,%eax
  801232:	8b 40 48             	mov    0x48(%eax),%eax
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	53                   	push   %ebx
  801239:	50                   	push   %eax
  80123a:	68 01 22 80 00       	push   $0x802201
  80123f:	e8 6a ef ff ff       	call   8001ae <cprintf>
		return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb da                	jmp    801228 <write+0x59>
		return -E_NOT_SUPP;
  80124e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801253:	eb d3                	jmp    801228 <write+0x59>

00801255 <seek>:

int
seek(int fdnum, off_t offset)
{
  801255:	f3 0f 1e fb          	endbr32 
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	ff 75 08             	pushl  0x8(%ebp)
  801266:	e8 0b fc ff ff       	call   800e76 <fd_lookup>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 0e                	js     801280 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801272:	8b 55 0c             	mov    0xc(%ebp),%edx
  801275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801278:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801282:	f3 0f 1e fb          	endbr32 
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	53                   	push   %ebx
  80128a:	83 ec 1c             	sub    $0x1c,%esp
  80128d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801290:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	53                   	push   %ebx
  801295:	e8 dc fb ff ff       	call   800e76 <fd_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 37                	js     8012d8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	ff 30                	pushl  (%eax)
  8012ad:	e8 18 fc ff ff       	call   800eca <dev_lookup>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 1f                	js     8012d8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c0:	74 1b                	je     8012dd <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c5:	8b 52 18             	mov    0x18(%edx),%edx
  8012c8:	85 d2                	test   %edx,%edx
  8012ca:	74 32                	je     8012fe <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	ff 75 0c             	pushl  0xc(%ebp)
  8012d2:	50                   	push   %eax
  8012d3:	ff d2                	call   *%edx
  8012d5:	83 c4 10             	add    $0x10,%esp
}
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012dd:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e2:	8b 40 48             	mov    0x48(%eax),%eax
  8012e5:	83 ec 04             	sub    $0x4,%esp
  8012e8:	53                   	push   %ebx
  8012e9:	50                   	push   %eax
  8012ea:	68 c4 21 80 00       	push   $0x8021c4
  8012ef:	e8 ba ee ff ff       	call   8001ae <cprintf>
		return -E_INVAL;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb da                	jmp    8012d8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801303:	eb d3                	jmp    8012d8 <ftruncate+0x56>

00801305 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801305:	f3 0f 1e fb          	endbr32 
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 1c             	sub    $0x1c,%esp
  801310:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	ff 75 08             	pushl  0x8(%ebp)
  80131a:	e8 57 fb ff ff       	call   800e76 <fd_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 4b                	js     801371 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	ff 30                	pushl  (%eax)
  801332:	e8 93 fb ff ff       	call   800eca <dev_lookup>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 33                	js     801371 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80133e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801341:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801345:	74 2f                	je     801376 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801347:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801351:	00 00 00 
	stat->st_isdir = 0;
  801354:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135b:	00 00 00 
	stat->st_dev = dev;
  80135e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	53                   	push   %ebx
  801368:	ff 75 f0             	pushl  -0x10(%ebp)
  80136b:	ff 50 14             	call   *0x14(%eax)
  80136e:	83 c4 10             	add    $0x10,%esp
}
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    
		return -E_NOT_SUPP;
  801376:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80137b:	eb f4                	jmp    801371 <fstat+0x6c>

0080137d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137d:	f3 0f 1e fb          	endbr32 
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	6a 00                	push   $0x0
  80138b:	ff 75 08             	pushl  0x8(%ebp)
  80138e:	e8 fb 01 00 00       	call   80158e <open>
  801393:	89 c3                	mov    %eax,%ebx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 1b                	js     8013b7 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	ff 75 0c             	pushl  0xc(%ebp)
  8013a2:	50                   	push   %eax
  8013a3:	e8 5d ff ff ff       	call   801305 <fstat>
  8013a8:	89 c6                	mov    %eax,%esi
	close(fd);
  8013aa:	89 1c 24             	mov    %ebx,(%esp)
  8013ad:	e8 fd fb ff ff       	call   800faf <close>
	return r;
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	89 f3                	mov    %esi,%ebx
}
  8013b7:	89 d8                	mov    %ebx,%eax
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	89 c6                	mov    %eax,%esi
  8013c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d0:	74 27                	je     8013f9 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d2:	6a 07                	push   $0x7
  8013d4:	68 00 50 80 00       	push   $0x805000
  8013d9:	56                   	push   %esi
  8013da:	ff 35 00 40 80 00    	pushl  0x804000
  8013e0:	e8 66 f9 ff ff       	call   800d4b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e5:	83 c4 0c             	add    $0xc,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 eb f8 ff ff       	call   800cdd <ipc_recv>
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	6a 01                	push   $0x1
  8013fe:	e8 ad f9 ff ff       	call   800db0 <ipc_find_env>
  801403:	a3 00 40 80 00       	mov    %eax,0x804000
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb c5                	jmp    8013d2 <fsipc+0x12>

0080140d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140d:	f3 0f 1e fb          	endbr32 
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	8b 40 0c             	mov    0xc(%eax),%eax
  80141d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801422:	8b 45 0c             	mov    0xc(%ebp),%eax
  801425:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80142a:	ba 00 00 00 00       	mov    $0x0,%edx
  80142f:	b8 02 00 00 00       	mov    $0x2,%eax
  801434:	e8 87 ff ff ff       	call   8013c0 <fsipc>
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <devfile_flush>:
{
  80143b:	f3 0f 1e fb          	endbr32 
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	8b 40 0c             	mov    0xc(%eax),%eax
  80144b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801450:	ba 00 00 00 00       	mov    $0x0,%edx
  801455:	b8 06 00 00 00       	mov    $0x6,%eax
  80145a:	e8 61 ff ff ff       	call   8013c0 <fsipc>
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <devfile_stat>:
{
  801461:	f3 0f 1e fb          	endbr32 
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	53                   	push   %ebx
  801469:	83 ec 04             	sub    $0x4,%esp
  80146c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	8b 40 0c             	mov    0xc(%eax),%eax
  801475:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147a:	ba 00 00 00 00       	mov    $0x0,%edx
  80147f:	b8 05 00 00 00       	mov    $0x5,%eax
  801484:	e8 37 ff ff ff       	call   8013c0 <fsipc>
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 2c                	js     8014b9 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	68 00 50 80 00       	push   $0x805000
  801495:	53                   	push   %ebx
  801496:	e8 7d f2 ff ff       	call   800718 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80149b:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a6:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ab:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <devfile_write>:
{
  8014be:	f3 0f 1e fb          	endbr32 
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014d7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014dc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014e1:	0f 47 c2             	cmova  %edx,%eax
  8014e4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014e9:	50                   	push   %eax
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	68 08 50 80 00       	push   $0x805008
  8014f2:	e8 d9 f3 ff ff       	call   8008d0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801501:	e8 ba fe ff ff       	call   8013c0 <fsipc>
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <devfile_read>:
{
  801508:	f3 0f 1e fb          	endbr32 
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	8b 40 0c             	mov    0xc(%eax),%eax
  80151a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
  80152a:	b8 03 00 00 00       	mov    $0x3,%eax
  80152f:	e8 8c fe ff ff       	call   8013c0 <fsipc>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	85 c0                	test   %eax,%eax
  801538:	78 1f                	js     801559 <devfile_read+0x51>
	assert(r <= n);
  80153a:	39 f0                	cmp    %esi,%eax
  80153c:	77 24                	ja     801562 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80153e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801543:	7f 33                	jg     801578 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	50                   	push   %eax
  801549:	68 00 50 80 00       	push   $0x805000
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	e8 7a f3 ff ff       	call   8008d0 <memmove>
	return r;
  801556:	83 c4 10             	add    $0x10,%esp
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    
	assert(r <= n);
  801562:	68 30 22 80 00       	push   $0x802230
  801567:	68 37 22 80 00       	push   $0x802237
  80156c:	6a 7c                	push   $0x7c
  80156e:	68 4c 22 80 00       	push   $0x80224c
  801573:	e8 be 05 00 00       	call   801b36 <_panic>
	assert(r <= PGSIZE);
  801578:	68 57 22 80 00       	push   $0x802257
  80157d:	68 37 22 80 00       	push   $0x802237
  801582:	6a 7d                	push   $0x7d
  801584:	68 4c 22 80 00       	push   $0x80224c
  801589:	e8 a8 05 00 00       	call   801b36 <_panic>

0080158e <open>:
{
  80158e:	f3 0f 1e fb          	endbr32 
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	56                   	push   %esi
  801596:	53                   	push   %ebx
  801597:	83 ec 1c             	sub    $0x1c,%esp
  80159a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80159d:	56                   	push   %esi
  80159e:	e8 32 f1 ff ff       	call   8006d5 <strlen>
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ab:	7f 6c                	jg     801619 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	e8 67 f8 ff ff       	call   800e20 <fd_alloc>
  8015b9:	89 c3                	mov    %eax,%ebx
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 3c                	js     8015fe <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	56                   	push   %esi
  8015c6:	68 00 50 80 00       	push   $0x805000
  8015cb:	e8 48 f1 ff ff       	call   800718 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015db:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e0:	e8 db fd ff ff       	call   8013c0 <fsipc>
  8015e5:	89 c3                	mov    %eax,%ebx
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 19                	js     801607 <open+0x79>
	return fd2num(fd);
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f4:	e8 f4 f7 ff ff       	call   800ded <fd2num>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	83 c4 10             	add    $0x10,%esp
}
  8015fe:	89 d8                	mov    %ebx,%eax
  801600:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801603:	5b                   	pop    %ebx
  801604:	5e                   	pop    %esi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    
		fd_close(fd, 0);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	6a 00                	push   $0x0
  80160c:	ff 75 f4             	pushl  -0xc(%ebp)
  80160f:	e8 10 f9 ff ff       	call   800f24 <fd_close>
		return r;
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb e5                	jmp    8015fe <open+0x70>
		return -E_BAD_PATH;
  801619:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80161e:	eb de                	jmp    8015fe <open+0x70>

00801620 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801620:	f3 0f 1e fb          	endbr32 
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162a:	ba 00 00 00 00       	mov    $0x0,%edx
  80162f:	b8 08 00 00 00       	mov    $0x8,%eax
  801634:	e8 87 fd ff ff       	call   8013c0 <fsipc>
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80163b:	f3 0f 1e fb          	endbr32 
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	ff 75 08             	pushl  0x8(%ebp)
  80164d:	e8 af f7 ff ff       	call   800e01 <fd2data>
  801652:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	68 63 22 80 00       	push   $0x802263
  80165c:	53                   	push   %ebx
  80165d:	e8 b6 f0 ff ff       	call   800718 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801662:	8b 46 04             	mov    0x4(%esi),%eax
  801665:	2b 06                	sub    (%esi),%eax
  801667:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80166d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801674:	00 00 00 
	stat->st_dev = &devpipe;
  801677:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80167e:	30 80 00 
	return 0;
}
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
  801686:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    

0080168d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80168d:	f3 0f 1e fb          	endbr32 
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80169b:	53                   	push   %ebx
  80169c:	6a 00                	push   $0x0
  80169e:	e8 4f f5 ff ff       	call   800bf2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a3:	89 1c 24             	mov    %ebx,(%esp)
  8016a6:	e8 56 f7 ff ff       	call   800e01 <fd2data>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	50                   	push   %eax
  8016af:	6a 00                	push   $0x0
  8016b1:	e8 3c f5 ff ff       	call   800bf2 <sys_page_unmap>
}
  8016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <_pipeisclosed>:
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 1c             	sub    $0x1c,%esp
  8016c4:	89 c7                	mov    %eax,%edi
  8016c6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8016cd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016d0:	83 ec 0c             	sub    $0xc,%esp
  8016d3:	57                   	push   %edi
  8016d4:	e8 a7 04 00 00       	call   801b80 <pageref>
  8016d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016dc:	89 34 24             	mov    %esi,(%esp)
  8016df:	e8 9c 04 00 00       	call   801b80 <pageref>
		nn = thisenv->env_runs;
  8016e4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016ea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	39 cb                	cmp    %ecx,%ebx
  8016f2:	74 1b                	je     80170f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016f4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016f7:	75 cf                	jne    8016c8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f9:	8b 42 58             	mov    0x58(%edx),%eax
  8016fc:	6a 01                	push   $0x1
  8016fe:	50                   	push   %eax
  8016ff:	53                   	push   %ebx
  801700:	68 6a 22 80 00       	push   $0x80226a
  801705:	e8 a4 ea ff ff       	call   8001ae <cprintf>
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	eb b9                	jmp    8016c8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80170f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801712:	0f 94 c0             	sete   %al
  801715:	0f b6 c0             	movzbl %al,%eax
}
  801718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5f                   	pop    %edi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <devpipe_write>:
{
  801720:	f3 0f 1e fb          	endbr32 
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	57                   	push   %edi
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	83 ec 28             	sub    $0x28,%esp
  80172d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801730:	56                   	push   %esi
  801731:	e8 cb f6 ff ff       	call   800e01 <fd2data>
  801736:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	bf 00 00 00 00       	mov    $0x0,%edi
  801740:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801743:	74 4f                	je     801794 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801745:	8b 43 04             	mov    0x4(%ebx),%eax
  801748:	8b 0b                	mov    (%ebx),%ecx
  80174a:	8d 51 20             	lea    0x20(%ecx),%edx
  80174d:	39 d0                	cmp    %edx,%eax
  80174f:	72 14                	jb     801765 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801751:	89 da                	mov    %ebx,%edx
  801753:	89 f0                	mov    %esi,%eax
  801755:	e8 61 ff ff ff       	call   8016bb <_pipeisclosed>
  80175a:	85 c0                	test   %eax,%eax
  80175c:	75 3b                	jne    801799 <devpipe_write+0x79>
			sys_yield();
  80175e:	e8 12 f4 ff ff       	call   800b75 <sys_yield>
  801763:	eb e0                	jmp    801745 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801765:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801768:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80176c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176f:	89 c2                	mov    %eax,%edx
  801771:	c1 fa 1f             	sar    $0x1f,%edx
  801774:	89 d1                	mov    %edx,%ecx
  801776:	c1 e9 1b             	shr    $0x1b,%ecx
  801779:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80177c:	83 e2 1f             	and    $0x1f,%edx
  80177f:	29 ca                	sub    %ecx,%edx
  801781:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801785:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801789:	83 c0 01             	add    $0x1,%eax
  80178c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80178f:	83 c7 01             	add    $0x1,%edi
  801792:	eb ac                	jmp    801740 <devpipe_write+0x20>
	return i;
  801794:	8b 45 10             	mov    0x10(%ebp),%eax
  801797:	eb 05                	jmp    80179e <devpipe_write+0x7e>
				return 0;
  801799:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5f                   	pop    %edi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <devpipe_read>:
{
  8017a6:	f3 0f 1e fb          	endbr32 
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	57                   	push   %edi
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 18             	sub    $0x18,%esp
  8017b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017b6:	57                   	push   %edi
  8017b7:	e8 45 f6 ff ff       	call   800e01 <fd2data>
  8017bc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	be 00 00 00 00       	mov    $0x0,%esi
  8017c6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017c9:	75 14                	jne    8017df <devpipe_read+0x39>
	return i;
  8017cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ce:	eb 02                	jmp    8017d2 <devpipe_read+0x2c>
				return i;
  8017d0:	89 f0                	mov    %esi,%eax
}
  8017d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5f                   	pop    %edi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    
			sys_yield();
  8017da:	e8 96 f3 ff ff       	call   800b75 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017df:	8b 03                	mov    (%ebx),%eax
  8017e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017e4:	75 18                	jne    8017fe <devpipe_read+0x58>
			if (i > 0)
  8017e6:	85 f6                	test   %esi,%esi
  8017e8:	75 e6                	jne    8017d0 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8017ea:	89 da                	mov    %ebx,%edx
  8017ec:	89 f8                	mov    %edi,%eax
  8017ee:	e8 c8 fe ff ff       	call   8016bb <_pipeisclosed>
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	74 e3                	je     8017da <devpipe_read+0x34>
				return 0;
  8017f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fc:	eb d4                	jmp    8017d2 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017fe:	99                   	cltd   
  8017ff:	c1 ea 1b             	shr    $0x1b,%edx
  801802:	01 d0                	add    %edx,%eax
  801804:	83 e0 1f             	and    $0x1f,%eax
  801807:	29 d0                	sub    %edx,%eax
  801809:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80180e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801811:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801814:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801817:	83 c6 01             	add    $0x1,%esi
  80181a:	eb aa                	jmp    8017c6 <devpipe_read+0x20>

0080181c <pipe>:
{
  80181c:	f3 0f 1e fb          	endbr32 
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	e8 ef f5 ff ff       	call   800e20 <fd_alloc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	0f 88 23 01 00 00    	js     801961 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	68 07 04 00 00       	push   $0x407
  801846:	ff 75 f4             	pushl  -0xc(%ebp)
  801849:	6a 00                	push   $0x0
  80184b:	e8 50 f3 ff ff       	call   800ba0 <sys_page_alloc>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	0f 88 04 01 00 00    	js     801961 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	e8 b7 f5 ff ff       	call   800e20 <fd_alloc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	0f 88 db 00 00 00    	js     801951 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	68 07 04 00 00       	push   $0x407
  80187e:	ff 75 f0             	pushl  -0x10(%ebp)
  801881:	6a 00                	push   $0x0
  801883:	e8 18 f3 ff ff       	call   800ba0 <sys_page_alloc>
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	0f 88 bc 00 00 00    	js     801951 <pipe+0x135>
	va = fd2data(fd0);
  801895:	83 ec 0c             	sub    $0xc,%esp
  801898:	ff 75 f4             	pushl  -0xc(%ebp)
  80189b:	e8 61 f5 ff ff       	call   800e01 <fd2data>
  8018a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a2:	83 c4 0c             	add    $0xc,%esp
  8018a5:	68 07 04 00 00       	push   $0x407
  8018aa:	50                   	push   %eax
  8018ab:	6a 00                	push   $0x0
  8018ad:	e8 ee f2 ff ff       	call   800ba0 <sys_page_alloc>
  8018b2:	89 c3                	mov    %eax,%ebx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	0f 88 82 00 00 00    	js     801941 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c5:	e8 37 f5 ff ff       	call   800e01 <fd2data>
  8018ca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018d1:	50                   	push   %eax
  8018d2:	6a 00                	push   $0x0
  8018d4:	56                   	push   %esi
  8018d5:	6a 00                	push   $0x0
  8018d7:	e8 ec f2 ff ff       	call   800bc8 <sys_page_map>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	83 c4 20             	add    $0x20,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 4e                	js     801933 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018e5:	a1 20 30 80 00       	mov    0x803020,%eax
  8018ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ed:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018fc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801901:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 da f4 ff ff       	call   800ded <fd2num>
  801913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801916:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801918:	83 c4 04             	add    $0x4,%esp
  80191b:	ff 75 f0             	pushl  -0x10(%ebp)
  80191e:	e8 ca f4 ff ff       	call   800ded <fd2num>
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801926:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801931:	eb 2e                	jmp    801961 <pipe+0x145>
	sys_page_unmap(0, va);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	56                   	push   %esi
  801937:	6a 00                	push   $0x0
  801939:	e8 b4 f2 ff ff       	call   800bf2 <sys_page_unmap>
  80193e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	ff 75 f0             	pushl  -0x10(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 a4 f2 ff ff       	call   800bf2 <sys_page_unmap>
  80194e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	6a 00                	push   $0x0
  801959:	e8 94 f2 ff ff       	call   800bf2 <sys_page_unmap>
  80195e:	83 c4 10             	add    $0x10,%esp
}
  801961:	89 d8                	mov    %ebx,%eax
  801963:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <pipeisclosed>:
{
  80196a:	f3 0f 1e fb          	endbr32 
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801974:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	ff 75 08             	pushl  0x8(%ebp)
  80197b:	e8 f6 f4 ff ff       	call   800e76 <fd_lookup>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 c0                	test   %eax,%eax
  801985:	78 18                	js     80199f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	e8 6f f4 ff ff       	call   800e01 <fd2data>
  801992:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801997:	e8 1f fd ff ff       	call   8016bb <_pipeisclosed>
  80199c:	83 c4 10             	add    $0x10,%esp
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019a1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8019a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019aa:	c3                   	ret    

008019ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ab:	f3 0f 1e fb          	endbr32 
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019b5:	68 82 22 80 00       	push   $0x802282
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	e8 56 ed ff ff       	call   800718 <strcpy>
	return 0;
}
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devcons_write>:
{
  8019c9:	f3 0f 1e fb          	endbr32 
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	57                   	push   %edi
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019d9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019de:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e7:	73 31                	jae    801a1a <devcons_write+0x51>
		m = n - tot;
  8019e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019ec:	29 f3                	sub    %esi,%ebx
  8019ee:	83 fb 7f             	cmp    $0x7f,%ebx
  8019f1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019f6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019f9:	83 ec 04             	sub    $0x4,%esp
  8019fc:	53                   	push   %ebx
  8019fd:	89 f0                	mov    %esi,%eax
  8019ff:	03 45 0c             	add    0xc(%ebp),%eax
  801a02:	50                   	push   %eax
  801a03:	57                   	push   %edi
  801a04:	e8 c7 ee ff ff       	call   8008d0 <memmove>
		sys_cputs(buf, m);
  801a09:	83 c4 08             	add    $0x8,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	57                   	push   %edi
  801a0e:	e8 c2 f0 ff ff       	call   800ad5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a13:	01 de                	add    %ebx,%esi
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	eb ca                	jmp    8019e4 <devcons_write+0x1b>
}
  801a1a:	89 f0                	mov    %esi,%eax
  801a1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <devcons_read>:
{
  801a24:	f3 0f 1e fb          	endbr32 
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a37:	74 21                	je     801a5a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a39:	e8 c1 f0 ff ff       	call   800aff <sys_cgetc>
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	75 07                	jne    801a49 <devcons_read+0x25>
		sys_yield();
  801a42:	e8 2e f1 ff ff       	call   800b75 <sys_yield>
  801a47:	eb f0                	jmp    801a39 <devcons_read+0x15>
	if (c < 0)
  801a49:	78 0f                	js     801a5a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a4b:	83 f8 04             	cmp    $0x4,%eax
  801a4e:	74 0c                	je     801a5c <devcons_read+0x38>
	*(char*)vbuf = c;
  801a50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a53:	88 02                	mov    %al,(%edx)
	return 1;
  801a55:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    
		return 0;
  801a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a61:	eb f7                	jmp    801a5a <devcons_read+0x36>

00801a63 <cputchar>:
{
  801a63:	f3 0f 1e fb          	endbr32 
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a70:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a73:	6a 01                	push   $0x1
  801a75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a78:	50                   	push   %eax
  801a79:	e8 57 f0 ff ff       	call   800ad5 <sys_cputs>
}
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <getchar>:
{
  801a83:	f3 0f 1e fb          	endbr32 
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a8d:	6a 01                	push   $0x1
  801a8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	6a 00                	push   $0x0
  801a95:	e8 5f f6 ff ff       	call   8010f9 <read>
	if (r < 0)
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 06                	js     801aa7 <getchar+0x24>
	if (r < 1)
  801aa1:	74 06                	je     801aa9 <getchar+0x26>
	return c;
  801aa3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    
		return -E_EOF;
  801aa9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801aae:	eb f7                	jmp    801aa7 <getchar+0x24>

00801ab0 <iscons>:
{
  801ab0:	f3 0f 1e fb          	endbr32 
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abd:	50                   	push   %eax
  801abe:	ff 75 08             	pushl  0x8(%ebp)
  801ac1:	e8 b0 f3 ff ff       	call   800e76 <fd_lookup>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 11                	js     801ade <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad6:	39 10                	cmp    %edx,(%eax)
  801ad8:	0f 94 c0             	sete   %al
  801adb:	0f b6 c0             	movzbl %al,%eax
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <opencons>:
{
  801ae0:	f3 0f 1e fb          	endbr32 
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801aea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aed:	50                   	push   %eax
  801aee:	e8 2d f3 ff ff       	call   800e20 <fd_alloc>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 3a                	js     801b34 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	68 07 04 00 00       	push   $0x407
  801b02:	ff 75 f4             	pushl  -0xc(%ebp)
  801b05:	6a 00                	push   $0x0
  801b07:	e8 94 f0 ff ff       	call   800ba0 <sys_page_alloc>
  801b0c:	83 c4 10             	add    $0x10,%esp
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 21                	js     801b34 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b1c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b21:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	50                   	push   %eax
  801b2c:	e8 bc f2 ff ff       	call   800ded <fd2num>
  801b31:	83 c4 10             	add    $0x10,%esp
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b36:	f3 0f 1e fb          	endbr32 
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b3f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b42:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b48:	e8 00 f0 ff ff       	call   800b4d <sys_getenvid>
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	ff 75 0c             	pushl  0xc(%ebp)
  801b53:	ff 75 08             	pushl  0x8(%ebp)
  801b56:	56                   	push   %esi
  801b57:	50                   	push   %eax
  801b58:	68 90 22 80 00       	push   $0x802290
  801b5d:	e8 4c e6 ff ff       	call   8001ae <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b62:	83 c4 18             	add    $0x18,%esp
  801b65:	53                   	push   %ebx
  801b66:	ff 75 10             	pushl  0x10(%ebp)
  801b69:	e8 eb e5 ff ff       	call   800159 <vcprintf>
	cprintf("\n");
  801b6e:	c7 04 24 7b 22 80 00 	movl   $0x80227b,(%esp)
  801b75:	e8 34 e6 ff ff       	call   8001ae <cprintf>
  801b7a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b7d:	cc                   	int3   
  801b7e:	eb fd                	jmp    801b7d <_panic+0x47>

00801b80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b80:	f3 0f 1e fb          	endbr32 
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	c1 ea 16             	shr    $0x16,%edx
  801b8f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b96:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b9b:	f6 c1 01             	test   $0x1,%cl
  801b9e:	74 1c                	je     801bbc <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801ba0:	c1 e8 0c             	shr    $0xc,%eax
  801ba3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801baa:	a8 01                	test   $0x1,%al
  801bac:	74 0e                	je     801bbc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bae:	c1 e8 0c             	shr    $0xc,%eax
  801bb1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801bb8:	ef 
  801bb9:	0f b7 d2             	movzwl %dx,%edx
}
  801bbc:	89 d0                	mov    %edx,%eax
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <__udivdi3>:
  801bc0:	f3 0f 1e fb          	endbr32 
  801bc4:	55                   	push   %ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 1c             	sub    $0x1c,%esp
  801bcb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bdb:	85 d2                	test   %edx,%edx
  801bdd:	75 19                	jne    801bf8 <__udivdi3+0x38>
  801bdf:	39 f3                	cmp    %esi,%ebx
  801be1:	76 4d                	jbe    801c30 <__udivdi3+0x70>
  801be3:	31 ff                	xor    %edi,%edi
  801be5:	89 e8                	mov    %ebp,%eax
  801be7:	89 f2                	mov    %esi,%edx
  801be9:	f7 f3                	div    %ebx
  801beb:	89 fa                	mov    %edi,%edx
  801bed:	83 c4 1c             	add    $0x1c,%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5f                   	pop    %edi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    
  801bf5:	8d 76 00             	lea    0x0(%esi),%esi
  801bf8:	39 f2                	cmp    %esi,%edx
  801bfa:	76 14                	jbe    801c10 <__udivdi3+0x50>
  801bfc:	31 ff                	xor    %edi,%edi
  801bfe:	31 c0                	xor    %eax,%eax
  801c00:	89 fa                	mov    %edi,%edx
  801c02:	83 c4 1c             	add    $0x1c,%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
  801c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c10:	0f bd fa             	bsr    %edx,%edi
  801c13:	83 f7 1f             	xor    $0x1f,%edi
  801c16:	75 48                	jne    801c60 <__udivdi3+0xa0>
  801c18:	39 f2                	cmp    %esi,%edx
  801c1a:	72 06                	jb     801c22 <__udivdi3+0x62>
  801c1c:	31 c0                	xor    %eax,%eax
  801c1e:	39 eb                	cmp    %ebp,%ebx
  801c20:	77 de                	ja     801c00 <__udivdi3+0x40>
  801c22:	b8 01 00 00 00       	mov    $0x1,%eax
  801c27:	eb d7                	jmp    801c00 <__udivdi3+0x40>
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d9                	mov    %ebx,%ecx
  801c32:	85 db                	test   %ebx,%ebx
  801c34:	75 0b                	jne    801c41 <__udivdi3+0x81>
  801c36:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3b:	31 d2                	xor    %edx,%edx
  801c3d:	f7 f3                	div    %ebx
  801c3f:	89 c1                	mov    %eax,%ecx
  801c41:	31 d2                	xor    %edx,%edx
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	f7 f1                	div    %ecx
  801c47:	89 c6                	mov    %eax,%esi
  801c49:	89 e8                	mov    %ebp,%eax
  801c4b:	89 f7                	mov    %esi,%edi
  801c4d:	f7 f1                	div    %ecx
  801c4f:	89 fa                	mov    %edi,%edx
  801c51:	83 c4 1c             	add    $0x1c,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 f9                	mov    %edi,%ecx
  801c62:	b8 20 00 00 00       	mov    $0x20,%eax
  801c67:	29 f8                	sub    %edi,%eax
  801c69:	d3 e2                	shl    %cl,%edx
  801c6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c6f:	89 c1                	mov    %eax,%ecx
  801c71:	89 da                	mov    %ebx,%edx
  801c73:	d3 ea                	shr    %cl,%edx
  801c75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c79:	09 d1                	or     %edx,%ecx
  801c7b:	89 f2                	mov    %esi,%edx
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f9                	mov    %edi,%ecx
  801c83:	d3 e3                	shl    %cl,%ebx
  801c85:	89 c1                	mov    %eax,%ecx
  801c87:	d3 ea                	shr    %cl,%edx
  801c89:	89 f9                	mov    %edi,%ecx
  801c8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c8f:	89 eb                	mov    %ebp,%ebx
  801c91:	d3 e6                	shl    %cl,%esi
  801c93:	89 c1                	mov    %eax,%ecx
  801c95:	d3 eb                	shr    %cl,%ebx
  801c97:	09 de                	or     %ebx,%esi
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	f7 74 24 08          	divl   0x8(%esp)
  801c9f:	89 d6                	mov    %edx,%esi
  801ca1:	89 c3                	mov    %eax,%ebx
  801ca3:	f7 64 24 0c          	mull   0xc(%esp)
  801ca7:	39 d6                	cmp    %edx,%esi
  801ca9:	72 15                	jb     801cc0 <__udivdi3+0x100>
  801cab:	89 f9                	mov    %edi,%ecx
  801cad:	d3 e5                	shl    %cl,%ebp
  801caf:	39 c5                	cmp    %eax,%ebp
  801cb1:	73 04                	jae    801cb7 <__udivdi3+0xf7>
  801cb3:	39 d6                	cmp    %edx,%esi
  801cb5:	74 09                	je     801cc0 <__udivdi3+0x100>
  801cb7:	89 d8                	mov    %ebx,%eax
  801cb9:	31 ff                	xor    %edi,%edi
  801cbb:	e9 40 ff ff ff       	jmp    801c00 <__udivdi3+0x40>
  801cc0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cc3:	31 ff                	xor    %edi,%edi
  801cc5:	e9 36 ff ff ff       	jmp    801c00 <__udivdi3+0x40>
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	f3 0f 1e fb          	endbr32 
  801cd4:	55                   	push   %ebp
  801cd5:	57                   	push   %edi
  801cd6:	56                   	push   %esi
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 1c             	sub    $0x1c,%esp
  801cdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cdf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ce3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ce7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	75 19                	jne    801d08 <__umoddi3+0x38>
  801cef:	39 df                	cmp    %ebx,%edi
  801cf1:	76 5d                	jbe    801d50 <__umoddi3+0x80>
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	89 da                	mov    %ebx,%edx
  801cf7:	f7 f7                	div    %edi
  801cf9:	89 d0                	mov    %edx,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	83 c4 1c             	add    $0x1c,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    
  801d05:	8d 76 00             	lea    0x0(%esi),%esi
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	39 d8                	cmp    %ebx,%eax
  801d0c:	76 12                	jbe    801d20 <__umoddi3+0x50>
  801d0e:	89 f0                	mov    %esi,%eax
  801d10:	89 da                	mov    %ebx,%edx
  801d12:	83 c4 1c             	add    $0x1c,%esp
  801d15:	5b                   	pop    %ebx
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    
  801d1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d20:	0f bd e8             	bsr    %eax,%ebp
  801d23:	83 f5 1f             	xor    $0x1f,%ebp
  801d26:	75 50                	jne    801d78 <__umoddi3+0xa8>
  801d28:	39 d8                	cmp    %ebx,%eax
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	89 d9                	mov    %ebx,%ecx
  801d32:	39 f7                	cmp    %esi,%edi
  801d34:	0f 86 d6 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	89 ca                	mov    %ecx,%edx
  801d3e:	83 c4 1c             	add    $0x1c,%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    
  801d46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d4d:	8d 76 00             	lea    0x0(%esi),%esi
  801d50:	89 fd                	mov    %edi,%ebp
  801d52:	85 ff                	test   %edi,%edi
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 d8                	mov    %ebx,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	eb 8c                	jmp    801cfd <__umoddi3+0x2d>
  801d71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d7f:	29 ea                	sub    %ebp,%edx
  801d81:	d3 e0                	shl    %cl,%eax
  801d83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 f8                	mov    %edi,%eax
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d91:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d95:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d99:	09 c1                	or     %eax,%ecx
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 e9                	mov    %ebp,%ecx
  801da3:	d3 e7                	shl    %cl,%edi
  801da5:	89 d1                	mov    %edx,%ecx
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801daf:	d3 e3                	shl    %cl,%ebx
  801db1:	89 c7                	mov    %eax,%edi
  801db3:	89 d1                	mov    %edx,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	89 fa                	mov    %edi,%edx
  801dbd:	d3 e6                	shl    %cl,%esi
  801dbf:	09 d8                	or     %ebx,%eax
  801dc1:	f7 74 24 08          	divl   0x8(%esp)
  801dc5:	89 d1                	mov    %edx,%ecx
  801dc7:	89 f3                	mov    %esi,%ebx
  801dc9:	f7 64 24 0c          	mull   0xc(%esp)
  801dcd:	89 c6                	mov    %eax,%esi
  801dcf:	89 d7                	mov    %edx,%edi
  801dd1:	39 d1                	cmp    %edx,%ecx
  801dd3:	72 06                	jb     801ddb <__umoddi3+0x10b>
  801dd5:	75 10                	jne    801de7 <__umoddi3+0x117>
  801dd7:	39 c3                	cmp    %eax,%ebx
  801dd9:	73 0c                	jae    801de7 <__umoddi3+0x117>
  801ddb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801ddf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801de3:	89 d7                	mov    %edx,%edi
  801de5:	89 c6                	mov    %eax,%esi
  801de7:	89 ca                	mov    %ecx,%edx
  801de9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dee:	29 f3                	sub    %esi,%ebx
  801df0:	19 fa                	sbb    %edi,%edx
  801df2:	89 d0                	mov    %edx,%eax
  801df4:	d3 e0                	shl    %cl,%eax
  801df6:	89 e9                	mov    %ebp,%ecx
  801df8:	d3 eb                	shr    %cl,%ebx
  801dfa:	d3 ea                	shr    %cl,%edx
  801dfc:	09 d8                	or     %ebx,%eax
  801dfe:	83 c4 1c             	add    $0x1c,%esp
  801e01:	5b                   	pop    %ebx
  801e02:	5e                   	pop    %esi
  801e03:	5f                   	pop    %edi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    
  801e06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 fe                	sub    %edi,%esi
  801e12:	19 c3                	sbb    %eax,%ebx
  801e14:	89 f2                	mov    %esi,%edx
  801e16:	89 d9                	mov    %ebx,%ecx
  801e18:	e9 1d ff ff ff       	jmp    801d3a <__umoddi3+0x6a>
