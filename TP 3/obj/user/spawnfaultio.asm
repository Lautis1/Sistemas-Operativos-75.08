
obj/user/spawnfaultio.debug:     formato del fichero elf32-i386


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
  80002c:	e8 4e 00 00 00       	call   80007f <libmain>
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
  80003a:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003d:	a1 04 40 80 00       	mov    0x804004,%eax
  800042:	8b 40 48             	mov    0x48(%eax),%eax
  800045:	50                   	push   %eax
  800046:	68 20 24 80 00       	push   $0x802420
  80004b:	e8 82 01 00 00       	call   8001d2 <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  800050:	83 c4 0c             	add    $0xc,%esp
  800053:	6a 00                	push   $0x0
  800055:	68 3e 24 80 00       	push   $0x80243e
  80005a:	68 3e 24 80 00       	push   $0x80243e
  80005f:	e8 41 1a 00 00       	call   801aa5 <spawnl>
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 02                	js     80006d <umain+0x3a>
		panic("spawn(faultio) failed: %e", r);
}
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    
		panic("spawn(faultio) failed: %e", r);
  80006d:	50                   	push   %eax
  80006e:	68 46 24 80 00       	push   $0x802446
  800073:	6a 09                	push   $0x9
  800075:	68 60 24 80 00       	push   $0x802460
  80007a:	e8 6c 00 00 00       	call   8000eb <_panic>

0080007f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007f:	f3 0f 1e fb          	endbr32 
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80008e:	e8 de 0a 00 00       	call   800b71 <sys_getenvid>
	if (id >= 0)
  800093:	85 c0                	test   %eax,%eax
  800095:	78 12                	js     8000a9 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80009f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a9:	85 db                	test   %ebx,%ebx
  8000ab:	7e 07                	jle    8000b4 <libmain+0x35>
		binaryname = argv[0];
  8000ad:	8b 06                	mov    (%esi),%eax
  8000af:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	e8 75 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000be:	e8 0a 00 00 00       	call   8000cd <exit>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cd:	f3 0f 1e fb          	endbr32 
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d7:	e8 18 0e 00 00       	call   800ef4 <close_all>
	sys_env_destroy(0);
  8000dc:	83 ec 0c             	sub    $0xc,%esp
  8000df:	6a 00                	push   $0x0
  8000e1:	e8 65 0a 00 00       	call   800b4b <sys_env_destroy>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000f4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000f7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000fd:	e8 6f 0a 00 00       	call   800b71 <sys_getenvid>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	56                   	push   %esi
  80010c:	50                   	push   %eax
  80010d:	68 80 24 80 00       	push   $0x802480
  800112:	e8 bb 00 00 00       	call   8001d2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800117:	83 c4 18             	add    $0x18,%esp
  80011a:	53                   	push   %ebx
  80011b:	ff 75 10             	pushl  0x10(%ebp)
  80011e:	e8 5a 00 00 00       	call   80017d <vcprintf>
	cprintf("\n");
  800123:	c7 04 24 56 29 80 00 	movl   $0x802956,(%esp)
  80012a:	e8 a3 00 00 00       	call   8001d2 <cprintf>
  80012f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800132:	cc                   	int3   
  800133:	eb fd                	jmp    800132 <_panic+0x47>

00800135 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	74 09                	je     800161 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800158:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	68 ff 00 00 00       	push   $0xff
  800169:	8d 43 08             	lea    0x8(%ebx),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 87 09 00 00       	call   800af9 <sys_cputs>
		b->idx = 0;
  800172:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800178:	83 c4 10             	add    $0x10,%esp
  80017b:	eb db                	jmp    800158 <putch+0x23>

0080017d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017d:	f3 0f 1e fb          	endbr32 
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800191:	00 00 00 
	b.cnt = 0;
  800194:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019e:	ff 75 0c             	pushl  0xc(%ebp)
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001aa:	50                   	push   %eax
  8001ab:	68 35 01 80 00       	push   $0x800135
  8001b0:	e8 80 01 00 00       	call   800335 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b5:	83 c4 08             	add    $0x8,%esp
  8001b8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	e8 2f 09 00 00       	call   800af9 <sys_cputs>

	return b.cnt;
}
  8001ca:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    

008001d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d2:	f3 0f 1e fb          	endbr32 
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001df:	50                   	push   %eax
  8001e0:	ff 75 08             	pushl  0x8(%ebp)
  8001e3:	e8 95 ff ff ff       	call   80017d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	57                   	push   %edi
  8001ee:	56                   	push   %esi
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 1c             	sub    $0x1c,%esp
  8001f3:	89 c7                	mov    %eax,%edi
  8001f5:	89 d6                	mov    %edx,%esi
  8001f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fd:	89 d1                	mov    %edx,%ecx
  8001ff:	89 c2                	mov    %eax,%edx
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800207:	8b 45 10             	mov    0x10(%ebp),%eax
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800210:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800217:	39 c2                	cmp    %eax,%edx
  800219:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80021c:	72 3e                	jb     80025c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	ff 75 18             	pushl  0x18(%ebp)
  800224:	83 eb 01             	sub    $0x1,%ebx
  800227:	53                   	push   %ebx
  800228:	50                   	push   %eax
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022f:	ff 75 e0             	pushl  -0x20(%ebp)
  800232:	ff 75 dc             	pushl  -0x24(%ebp)
  800235:	ff 75 d8             	pushl  -0x28(%ebp)
  800238:	e8 73 1f 00 00       	call   8021b0 <__udivdi3>
  80023d:	83 c4 18             	add    $0x18,%esp
  800240:	52                   	push   %edx
  800241:	50                   	push   %eax
  800242:	89 f2                	mov    %esi,%edx
  800244:	89 f8                	mov    %edi,%eax
  800246:	e8 9f ff ff ff       	call   8001ea <printnum>
  80024b:	83 c4 20             	add    $0x20,%esp
  80024e:	eb 13                	jmp    800263 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	56                   	push   %esi
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	ff d7                	call   *%edi
  800259:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025c:	83 eb 01             	sub    $0x1,%ebx
  80025f:	85 db                	test   %ebx,%ebx
  800261:	7f ed                	jg     800250 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	56                   	push   %esi
  800267:	83 ec 04             	sub    $0x4,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 45 20 00 00       	call   8022c0 <__umoddi3>
  80027b:	83 c4 14             	add    $0x14,%esp
  80027e:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  800285:	50                   	push   %eax
  800286:	ff d7                	call   *%edi
}
  800288:	83 c4 10             	add    $0x10,%esp
  80028b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800293:	83 fa 01             	cmp    $0x1,%edx
  800296:	7f 13                	jg     8002ab <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800298:	85 d2                	test   %edx,%edx
  80029a:	74 1c                	je     8002b8 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002aa:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 02                	mov    (%edx),%eax
  8002b4:	8b 52 04             	mov    0x4(%edx),%edx
  8002b7:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c6:	c3                   	ret    

008002c7 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002c7:	83 fa 01             	cmp    $0x1,%edx
  8002ca:	7f 0f                	jg     8002db <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002cc:	85 d2                	test   %edx,%edx
  8002ce:	74 18                	je     8002e8 <getint+0x21>
		return va_arg(*ap, long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	99                   	cltd   
  8002da:	c3                   	ret    
		return va_arg(*ap, long long);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	8b 52 04             	mov    0x4(%edx),%edx
  8002e7:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	99                   	cltd   
}
  8002f2:	c3                   	ret    

008002f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f3:	f3 0f 1e fb          	endbr32 
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800301:	8b 10                	mov    (%eax),%edx
  800303:	3b 50 04             	cmp    0x4(%eax),%edx
  800306:	73 0a                	jae    800312 <sprintputch+0x1f>
		*b->buf++ = ch;
  800308:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	88 02                	mov    %al,(%edx)
}
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <printfmt>:
{
  800314:	f3 0f 1e fb          	endbr32 
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80031e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 05 00 00 00       	call   800335 <vprintfmt>
}
  800330:	83 c4 10             	add    $0x10,%esp
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <vprintfmt>:
{
  800335:	f3 0f 1e fb          	endbr32 
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
  80033f:	83 ec 2c             	sub    $0x2c,%esp
  800342:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800345:	8b 75 0c             	mov    0xc(%ebp),%esi
  800348:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034b:	e9 86 02 00 00       	jmp    8005d6 <vprintfmt+0x2a1>
		padc = ' ';
  800350:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800354:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800362:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8d 47 01             	lea    0x1(%edi),%eax
  800371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800374:	0f b6 17             	movzbl (%edi),%edx
  800377:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037a:	3c 55                	cmp    $0x55,%al
  80037c:	0f 87 df 02 00 00    	ja     800661 <vprintfmt+0x32c>
  800382:	0f b6 c0             	movzbl %al,%eax
  800385:	3e ff 24 85 e0 25 80 	notrack jmp *0x8025e0(,%eax,4)
  80038c:	00 
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800390:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800394:	eb d8                	jmp    80036e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80039d:	eb cf                	jmp    80036e <vprintfmt+0x39>
  80039f:	0f b6 d2             	movzbl %dl,%edx
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ba:	83 f9 09             	cmp    $0x9,%ecx
  8003bd:	77 52                	ja     800411 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003bf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c2:	eb e9                	jmp    8003ad <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d9:	79 93                	jns    80036e <vprintfmt+0x39>
				width = precision, precision = -1;
  8003db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e8:	eb 84                	jmp    80036e <vprintfmt+0x39>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	0f 49 d0             	cmovns %eax,%edx
  8003f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fd:	e9 6c ff ff ff       	jmp    80036e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800405:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80040c:	e9 5d ff ff ff       	jmp    80036e <vprintfmt+0x39>
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800417:	eb bc                	jmp    8003d5 <vprintfmt+0xa0>
			lflag++;
  800419:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041f:	e9 4a ff ff ff       	jmp    80036e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	56                   	push   %esi
  800431:	ff 30                	pushl  (%eax)
  800433:	ff d3                	call   *%ebx
			break;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 96 01 00 00       	jmp    8005d3 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 00                	mov    (%eax),%eax
  800448:	99                   	cltd   
  800449:	31 d0                	xor    %edx,%eax
  80044b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 0f             	cmp    $0xf,%eax
  800450:	7f 20                	jg     800472 <vprintfmt+0x13d>
  800452:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	74 15                	je     800472 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 71 28 80 00       	push   $0x802871
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	e8 aa fe ff ff       	call   800314 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	e9 61 01 00 00       	jmp    8005d3 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800472:	50                   	push   %eax
  800473:	68 bb 24 80 00       	push   $0x8024bb
  800478:	56                   	push   %esi
  800479:	53                   	push   %ebx
  80047a:	e8 95 fe ff ff       	call   800314 <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	e9 4c 01 00 00       	jmp    8005d3 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 50 04             	lea    0x4(%eax),%edx
  80048d:	89 55 14             	mov    %edx,0x14(%ebp)
  800490:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800492:	85 c9                	test   %ecx,%ecx
  800494:	b8 b4 24 80 00       	mov    $0x8024b4,%eax
  800499:	0f 45 c1             	cmovne %ecx,%eax
  80049c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a3:	7e 06                	jle    8004ab <vprintfmt+0x176>
  8004a5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a9:	75 0d                	jne    8004b8 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ae:	89 c7                	mov    %eax,%edi
  8004b0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	eb 57                	jmp    80050f <vprintfmt+0x1da>
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8004be:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c1:	e8 4f 02 00 00       	call   800715 <strnlen>
  8004c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c9:	29 c2                	sub    %eax,%edx
  8004cb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004d5:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004d8:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	85 db                	test   %ebx,%ebx
  8004dc:	7e 10                	jle    8004ee <vprintfmt+0x1b9>
					putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	56                   	push   %esi
  8004e2:	57                   	push   %edi
  8004e3:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 eb 01             	sub    $0x1,%ebx
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	eb ec                	jmp    8004da <vprintfmt+0x1a5>
  8004ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fb:	0f 49 c2             	cmovns %edx,%eax
  8004fe:	29 c2                	sub    %eax,%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	eb a6                	jmp    8004ab <vprintfmt+0x176>
					putch(ch, putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	56                   	push   %esi
  800509:	52                   	push   %edx
  80050a:	ff d3                	call   *%ebx
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051b:	0f be d0             	movsbl %al,%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	74 42                	je     800564 <vprintfmt+0x22f>
  800522:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800526:	78 06                	js     80052e <vprintfmt+0x1f9>
  800528:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052c:	78 1e                	js     80054c <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80052e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800532:	74 d1                	je     800505 <vprintfmt+0x1d0>
  800534:	0f be c0             	movsbl %al,%eax
  800537:	83 e8 20             	sub    $0x20,%eax
  80053a:	83 f8 5e             	cmp    $0x5e,%eax
  80053d:	76 c6                	jbe    800505 <vprintfmt+0x1d0>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	56                   	push   %esi
  800543:	6a 3f                	push   $0x3f
  800545:	ff d3                	call   *%ebx
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	eb c3                	jmp    80050f <vprintfmt+0x1da>
  80054c:	89 cf                	mov    %ecx,%edi
  80054e:	eb 0e                	jmp    80055e <vprintfmt+0x229>
				putch(' ', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	6a 20                	push   $0x20
  800556:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800558:	83 ef 01             	sub    $0x1,%edi
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	85 ff                	test   %edi,%edi
  800560:	7f ee                	jg     800550 <vprintfmt+0x21b>
  800562:	eb 6f                	jmp    8005d3 <vprintfmt+0x29e>
  800564:	89 cf                	mov    %ecx,%edi
  800566:	eb f6                	jmp    80055e <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800568:	89 ca                	mov    %ecx,%edx
  80056a:	8d 45 14             	lea    0x14(%ebp),%eax
  80056d:	e8 55 fd ff ff       	call   8002c7 <getint>
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800578:	85 d2                	test   %edx,%edx
  80057a:	78 0b                	js     800587 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80057c:	89 d1                	mov    %edx,%ecx
  80057e:	89 c2                	mov    %eax,%edx
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x284>
				putch('-', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	56                   	push   %esi
  80058b:	6a 2d                	push   $0x2d
  80058d:	ff d3                	call   *%ebx
				num = -(long long) num;
  80058f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800592:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800595:	f7 da                	neg    %edx
  800597:	83 d1 00             	adc    $0x0,%ecx
  80059a:	f7 d9                	neg    %ecx
  80059c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a4:	eb 13                	jmp    8005b9 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005a6:	89 ca                	mov    %ecx,%edx
  8005a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ab:	e8 e3 fc ff ff       	call   800293 <getuint>
  8005b0:	89 d1                	mov    %edx,%ecx
  8005b2:	89 c2                	mov    %eax,%edx
			base = 10;
  8005b4:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005c0:	57                   	push   %edi
  8005c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c4:	50                   	push   %eax
  8005c5:	51                   	push   %ecx
  8005c6:	52                   	push   %edx
  8005c7:	89 f2                	mov    %esi,%edx
  8005c9:	89 d8                	mov    %ebx,%eax
  8005cb:	e8 1a fc ff ff       	call   8001ea <printnum>
			break;
  8005d0:	83 c4 20             	add    $0x20,%esp
{
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d6:	83 c7 01             	add    $0x1,%edi
  8005d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005dd:	83 f8 25             	cmp    $0x25,%eax
  8005e0:	0f 84 6a fd ff ff    	je     800350 <vprintfmt+0x1b>
			if (ch == '\0')
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	0f 84 93 00 00 00    	je     800681 <vprintfmt+0x34c>
			putch(ch, putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	56                   	push   %esi
  8005f2:	50                   	push   %eax
  8005f3:	ff d3                	call   *%ebx
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	eb dc                	jmp    8005d6 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005fa:	89 ca                	mov    %ecx,%edx
  8005fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ff:	e8 8f fc ff ff       	call   800293 <getuint>
  800604:	89 d1                	mov    %edx,%ecx
  800606:	89 c2                	mov    %eax,%edx
			base = 8;
  800608:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80060d:	eb aa                	jmp    8005b9 <vprintfmt+0x284>
			putch('0', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	56                   	push   %esi
  800613:	6a 30                	push   $0x30
  800615:	ff d3                	call   *%ebx
			putch('x', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 78                	push   $0x78
  80061d:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062f:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800632:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800637:	eb 80                	jmp    8005b9 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 50 fc ff ff       	call   800293 <getuint>
  800643:	89 d1                	mov    %edx,%ecx
  800645:	89 c2                	mov    %eax,%edx
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
  80064c:	e9 68 ff ff ff       	jmp    8005b9 <vprintfmt+0x284>
			putch(ch, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	6a 25                	push   $0x25
  800657:	ff d3                	call   *%ebx
			break;
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	e9 72 ff ff ff       	jmp    8005d3 <vprintfmt+0x29e>
			putch('%', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	56                   	push   %esi
  800665:	6a 25                	push   $0x25
  800667:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	89 f8                	mov    %edi,%eax
  80066e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800672:	74 05                	je     800679 <vprintfmt+0x344>
  800674:	83 e8 01             	sub    $0x1,%eax
  800677:	eb f5                	jmp    80066e <vprintfmt+0x339>
  800679:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80067c:	e9 52 ff ff ff       	jmp    8005d3 <vprintfmt+0x29e>
}
  800681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800684:	5b                   	pop    %ebx
  800685:	5e                   	pop    %esi
  800686:	5f                   	pop    %edi
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800689:	f3 0f 1e fb          	endbr32 
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 18             	sub    $0x18,%esp
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800699:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	74 26                	je     8006d4 <vsnprintf+0x4b>
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	7e 22                	jle    8006d4 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b2:	ff 75 14             	pushl  0x14(%ebp)
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	68 f3 02 80 00       	push   $0x8002f3
  8006c1:	e8 6f fc ff ff       	call   800335 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cf:	83 c4 10             	add    $0x10,%esp
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    
		return -E_INVAL;
  8006d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d9:	eb f7                	jmp    8006d2 <vsnprintf+0x49>

008006db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006db:	f3 0f 1e fb          	endbr32 
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e8:	50                   	push   %eax
  8006e9:	ff 75 10             	pushl  0x10(%ebp)
  8006ec:	ff 75 0c             	pushl  0xc(%ebp)
  8006ef:	ff 75 08             	pushl  0x8(%ebp)
  8006f2:	e8 92 ff ff ff       	call   800689 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    

008006f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f9:	f3 0f 1e fb          	endbr32 
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070c:	74 05                	je     800713 <strlen+0x1a>
		n++;
  80070e:	83 c0 01             	add    $0x1,%eax
  800711:	eb f5                	jmp    800708 <strlen+0xf>
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800715:	f3 0f 1e fb          	endbr32 
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800722:	b8 00 00 00 00       	mov    $0x0,%eax
  800727:	39 d0                	cmp    %edx,%eax
  800729:	74 0d                	je     800738 <strnlen+0x23>
  80072b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072f:	74 05                	je     800736 <strnlen+0x21>
		n++;
  800731:	83 c0 01             	add    $0x1,%eax
  800734:	eb f1                	jmp    800727 <strnlen+0x12>
  800736:	89 c2                	mov    %eax,%edx
	return n;
}
  800738:	89 d0                	mov    %edx,%eax
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073c:	f3 0f 1e fb          	endbr32 
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800753:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800756:	83 c0 01             	add    $0x1,%eax
  800759:	84 d2                	test   %dl,%dl
  80075b:	75 f2                	jne    80074f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80075d:	89 c8                	mov    %ecx,%eax
  80075f:	5b                   	pop    %ebx
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800762:	f3 0f 1e fb          	endbr32 
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	83 ec 10             	sub    $0x10,%esp
  80076d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800770:	53                   	push   %ebx
  800771:	e8 83 ff ff ff       	call   8006f9 <strlen>
  800776:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	01 d8                	add    %ebx,%eax
  80077e:	50                   	push   %eax
  80077f:	e8 b8 ff ff ff       	call   80073c <strcpy>
	return dst;
}
  800784:	89 d8                	mov    %ebx,%eax
  800786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	89 f3                	mov    %esi,%ebx
  80079c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	39 d8                	cmp    %ebx,%eax
  8007a3:	74 11                	je     8007b6 <strncpy+0x2b>
		*dst++ = *src;
  8007a5:	83 c0 01             	add    $0x1,%eax
  8007a8:	0f b6 0a             	movzbl (%edx),%ecx
  8007ab:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ae:	80 f9 01             	cmp    $0x1,%cl
  8007b1:	83 da ff             	sbb    $0xffffffff,%edx
  8007b4:	eb eb                	jmp    8007a1 <strncpy+0x16>
	}
	return ret;
}
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007bc:	f3 0f 1e fb          	endbr32 
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 21                	je     8007f5 <strlcpy+0x39>
  8007d4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007da:	39 c2                	cmp    %eax,%edx
  8007dc:	74 14                	je     8007f2 <strlcpy+0x36>
  8007de:	0f b6 19             	movzbl (%ecx),%ebx
  8007e1:	84 db                	test   %bl,%bl
  8007e3:	74 0b                	je     8007f0 <strlcpy+0x34>
			*dst++ = *src++;
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ee:	eb ea                	jmp    8007da <strlcpy+0x1e>
  8007f0:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007f2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f5:	29 f0                	sub    %esi,%eax
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fb:	f3 0f 1e fb          	endbr32 
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800808:	0f b6 01             	movzbl (%ecx),%eax
  80080b:	84 c0                	test   %al,%al
  80080d:	74 0c                	je     80081b <strcmp+0x20>
  80080f:	3a 02                	cmp    (%edx),%al
  800811:	75 08                	jne    80081b <strcmp+0x20>
		p++, q++;
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	eb ed                	jmp    800808 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 c0             	movzbl %al,%eax
  80081e:	0f b6 12             	movzbl (%edx),%edx
  800821:	29 d0                	sub    %edx,%eax
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800825:	f3 0f 1e fb          	endbr32 
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 c3                	mov    %eax,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800838:	eb 06                	jmp    800840 <strncmp+0x1b>
		n--, p++, q++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 16                	je     80085a <strncmp+0x35>
  800844:	0f b6 08             	movzbl (%eax),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	74 04                	je     80084f <strncmp+0x2a>
  80084b:	3a 0a                	cmp    (%edx),%cl
  80084d:	74 eb                	je     80083a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	0f b6 12             	movzbl (%edx),%edx
  800855:	29 d0                	sub    %edx,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    
		return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
  80085f:	eb f6                	jmp    800857 <strncmp+0x32>

00800861 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800861:	f3 0f 1e fb          	endbr32 
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086f:	0f b6 10             	movzbl (%eax),%edx
  800872:	84 d2                	test   %dl,%dl
  800874:	74 09                	je     80087f <strchr+0x1e>
		if (*s == c)
  800876:	38 ca                	cmp    %cl,%dl
  800878:	74 0a                	je     800884 <strchr+0x23>
	for (; *s; s++)
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	eb f0                	jmp    80086f <strchr+0xe>
			return (char *) s;
	return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800886:	f3 0f 1e fb          	endbr32 
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800894:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	74 09                	je     8008a4 <strfind+0x1e>
  80089b:	84 d2                	test   %dl,%dl
  80089d:	74 05                	je     8008a4 <strfind+0x1e>
	for (; *s; s++)
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	eb f0                	jmp    800894 <strfind+0xe>
			break;
	return (char *) s;
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a6:	f3 0f 1e fb          	endbr32 
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	57                   	push   %edi
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008b6:	85 c9                	test   %ecx,%ecx
  8008b8:	74 33                	je     8008ed <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	09 c8                	or     %ecx,%eax
  8008be:	a8 03                	test   $0x3,%al
  8008c0:	75 23                	jne    8008e5 <memset+0x3f>
		c &= 0xFF;
  8008c2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c6:	89 d8                	mov    %ebx,%eax
  8008c8:	c1 e0 08             	shl    $0x8,%eax
  8008cb:	89 df                	mov    %ebx,%edi
  8008cd:	c1 e7 18             	shl    $0x18,%edi
  8008d0:	89 de                	mov    %ebx,%esi
  8008d2:	c1 e6 10             	shl    $0x10,%esi
  8008d5:	09 f7                	or     %esi,%edi
  8008d7:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008d9:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008de:	89 d7                	mov    %edx,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e3:	eb 08                	jmp    8008ed <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e5:	89 d7                	mov    %edx,%edi
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	fc                   	cld    
  8008eb:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008ed:	89 d0                	mov    %edx,%eax
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5f                   	pop    %edi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f4:	f3 0f 1e fb          	endbr32 
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 75 0c             	mov    0xc(%ebp),%esi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800906:	39 c6                	cmp    %eax,%esi
  800908:	73 32                	jae    80093c <memmove+0x48>
  80090a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090d:	39 c2                	cmp    %eax,%edx
  80090f:	76 2b                	jbe    80093c <memmove+0x48>
		s += n;
		d += n;
  800911:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800914:	89 fe                	mov    %edi,%esi
  800916:	09 ce                	or     %ecx,%esi
  800918:	09 d6                	or     %edx,%esi
  80091a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800920:	75 0e                	jne    800930 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800922:	83 ef 04             	sub    $0x4,%edi
  800925:	8d 72 fc             	lea    -0x4(%edx),%esi
  800928:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80092b:	fd                   	std    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 09                	jmp    800939 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800930:	83 ef 01             	sub    $0x1,%edi
  800933:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800936:	fd                   	std    
  800937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800939:	fc                   	cld    
  80093a:	eb 1a                	jmp    800956 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	89 c2                	mov    %eax,%edx
  80093e:	09 ca                	or     %ecx,%edx
  800940:	09 f2                	or     %esi,%edx
  800942:	f6 c2 03             	test   $0x3,%dl
  800945:	75 0a                	jne    800951 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800947:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094f:	eb 05                	jmp    800956 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095a:	f3 0f 1e fb          	endbr32 
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800964:	ff 75 10             	pushl  0x10(%ebp)
  800967:	ff 75 0c             	pushl  0xc(%ebp)
  80096a:	ff 75 08             	pushl  0x8(%ebp)
  80096d:	e8 82 ff ff ff       	call   8008f4 <memmove>
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800974:	f3 0f 1e fb          	endbr32 
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
  800983:	89 c6                	mov    %eax,%esi
  800985:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800988:	39 f0                	cmp    %esi,%eax
  80098a:	74 1c                	je     8009a8 <memcmp+0x34>
		if (*s1 != *s2)
  80098c:	0f b6 08             	movzbl (%eax),%ecx
  80098f:	0f b6 1a             	movzbl (%edx),%ebx
  800992:	38 d9                	cmp    %bl,%cl
  800994:	75 08                	jne    80099e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c2 01             	add    $0x1,%edx
  80099c:	eb ea                	jmp    800988 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80099e:	0f b6 c1             	movzbl %cl,%eax
  8009a1:	0f b6 db             	movzbl %bl,%ebx
  8009a4:	29 d8                	sub    %ebx,%eax
  8009a6:	eb 05                	jmp    8009ad <memcmp+0x39>
	}

	return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b1:	f3 0f 1e fb          	endbr32 
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c3:	39 d0                	cmp    %edx,%eax
  8009c5:	73 09                	jae    8009d0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	38 08                	cmp    %cl,(%eax)
  8009c9:	74 05                	je     8009d0 <memfind+0x1f>
	for (; s < ends; s++)
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	eb f3                	jmp    8009c3 <memfind+0x12>
			break;
	return (void *) s;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d2:	f3 0f 1e fb          	endbr32 
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	eb 03                	jmp    8009e7 <strtol+0x15>
		s++;
  8009e4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e7:	0f b6 01             	movzbl (%ecx),%eax
  8009ea:	3c 20                	cmp    $0x20,%al
  8009ec:	74 f6                	je     8009e4 <strtol+0x12>
  8009ee:	3c 09                	cmp    $0x9,%al
  8009f0:	74 f2                	je     8009e4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009f2:	3c 2b                	cmp    $0x2b,%al
  8009f4:	74 2a                	je     800a20 <strtol+0x4e>
	int neg = 0;
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009fb:	3c 2d                	cmp    $0x2d,%al
  8009fd:	74 2b                	je     800a2a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a05:	75 0f                	jne    800a16 <strtol+0x44>
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	74 28                	je     800a34 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0c:	85 db                	test   %ebx,%ebx
  800a0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a13:	0f 44 d8             	cmove  %eax,%ebx
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a1e:	eb 46                	jmp    800a66 <strtol+0x94>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb d5                	jmp    8009ff <strtol+0x2d>
		s++, neg = 1;
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a32:	eb cb                	jmp    8009ff <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a38:	74 0e                	je     800a48 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	75 d8                	jne    800a16 <strtol+0x44>
		s++, base = 8;
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a46:	eb ce                	jmp    800a16 <strtol+0x44>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb c4                	jmp    800a16 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a52:	0f be d2             	movsbl %dl,%edx
  800a55:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5b:	7d 3a                	jge    800a97 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a5d:	83 c1 01             	add    $0x1,%ecx
  800a60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a64:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a66:	0f b6 11             	movzbl (%ecx),%edx
  800a69:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 09             	cmp    $0x9,%bl
  800a71:	76 df                	jbe    800a52 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 19             	cmp    $0x19,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 57             	sub    $0x57,%edx
  800a83:	eb d3                	jmp    800a58 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 37             	sub    $0x37,%edx
  800a95:	eb c1                	jmp    800a58 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9b:	74 05                	je     800aa2 <strtol+0xd0>
		*endptr = (char *) s;
  800a9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa2:	89 c2                	mov    %eax,%edx
  800aa4:	f7 da                	neg    %edx
  800aa6:	85 ff                	test   %edi,%edi
  800aa8:	0f 45 c2             	cmovne %edx,%eax
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 1c             	sub    $0x1c,%esp
  800ab9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800abc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800abf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aca:	8b 75 14             	mov    0x14(%ebp),%esi
  800acd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800acf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ad3:	74 04                	je     800ad9 <syscall+0x29>
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	7f 08                	jg     800ae1 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	50                   	push   %eax
  800ae5:	ff 75 e0             	pushl  -0x20(%ebp)
  800ae8:	68 9f 27 80 00       	push   $0x80279f
  800aed:	6a 23                	push   $0x23
  800aef:	68 bc 27 80 00       	push   $0x8027bc
  800af4:	e8 f2 f5 ff ff       	call   8000eb <_panic>

00800af9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800af9:	f3 0f 1e fb          	endbr32 
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b03:	6a 00                	push   $0x0
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	ff 75 0c             	pushl  0xc(%ebp)
  800b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
  800b19:	e8 92 ff ff ff       	call   800ab0 <syscall>
}
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b23:	f3 0f 1e fb          	endbr32 
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b2d:	6a 00                	push   $0x0
  800b2f:	6a 00                	push   $0x0
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	e8 67 ff ff ff       	call   800ab0 <syscall>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4b:	f3 0f 1e fb          	endbr32 
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b60:	ba 01 00 00 00       	mov    $0x1,%edx
  800b65:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6a:	e8 41 ff ff ff       	call   800ab0 <syscall>
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b92:	e8 19 ff ff ff       	call   800ab0 <syscall>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	f3 0f 1e fb          	endbr32 
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bba:	e8 f1 fe ff ff       	call   800ab0 <syscall>
}
  800bbf:	83 c4 10             	add    $0x10,%esp
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	ff 75 10             	pushl  0x10(%ebp)
  800bd5:	ff 75 0c             	pushl  0xc(%ebp)
  800bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdb:	ba 01 00 00 00       	mov    $0x1,%edx
  800be0:	b8 04 00 00 00       	mov    $0x4,%eax
  800be5:	e8 c6 fe ff ff       	call   800ab0 <syscall>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bec:	f3 0f 1e fb          	endbr32 
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bf6:	ff 75 18             	pushl  0x18(%ebp)
  800bf9:	ff 75 14             	pushl  0x14(%ebp)
  800bfc:	ff 75 10             	pushl  0x10(%ebp)
  800bff:	ff 75 0c             	pushl  0xc(%ebp)
  800c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c05:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0f:	e8 9c fe ff ff       	call   800ab0 <syscall>
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c16:	f3 0f 1e fb          	endbr32 
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c20:	6a 00                	push   $0x0
  800c22:	6a 00                	push   $0x0
  800c24:	6a 00                	push   $0x0
  800c26:	ff 75 0c             	pushl  0xc(%ebp)
  800c29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c31:	b8 06 00 00 00       	mov    $0x6,%eax
  800c36:	e8 75 fe ff ff       	call   800ab0 <syscall>
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	f3 0f 1e fb          	endbr32 
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c47:	6a 00                	push   $0x0
  800c49:	6a 00                	push   $0x0
  800c4b:	6a 00                	push   $0x0
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c53:	ba 01 00 00 00       	mov    $0x1,%edx
  800c58:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5d:	e8 4e fe ff ff       	call   800ab0 <syscall>
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c64:	f3 0f 1e fb          	endbr32 
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c6e:	6a 00                	push   $0x0
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	ff 75 0c             	pushl  0xc(%ebp)
  800c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c84:	e8 27 fe ff ff       	call   800ab0 <syscall>
}
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8b:	f3 0f 1e fb          	endbr32 
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	ff 75 0c             	pushl  0xc(%ebp)
  800c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cab:	e8 00 fe ff ff       	call   800ab0 <syscall>
}
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb2:	f3 0f 1e fb          	endbr32 
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cbc:	6a 00                	push   $0x0
  800cbe:	ff 75 14             	pushl  0x14(%ebp)
  800cc1:	ff 75 10             	pushl  0x10(%ebp)
  800cc4:	ff 75 0c             	pushl  0xc(%ebp)
  800cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd4:	e8 d7 fd ff ff       	call   800ab0 <syscall>
}
  800cd9:	c9                   	leave  
  800cda:	c3                   	ret    

00800cdb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdb:	f3 0f 1e fb          	endbr32 
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ce5:	6a 00                	push   $0x0
  800ce7:	6a 00                	push   $0x0
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfa:	e8 b1 fd ff ff       	call   800ab0 <syscall>
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d10:	c1 e8 0c             	shr    $0xc,%eax
}
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d15:	f3 0f 1e fb          	endbr32 
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800d1f:	ff 75 08             	pushl  0x8(%ebp)
  800d22:	e8 da ff ff ff       	call   800d01 <fd2num>
  800d27:	83 c4 10             	add    $0x10,%esp
  800d2a:	c1 e0 0c             	shl    $0xc,%eax
  800d2d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d34:	f3 0f 1e fb          	endbr32 
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d40:	89 c2                	mov    %eax,%edx
  800d42:	c1 ea 16             	shr    $0x16,%edx
  800d45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d4c:	f6 c2 01             	test   $0x1,%dl
  800d4f:	74 2d                	je     800d7e <fd_alloc+0x4a>
  800d51:	89 c2                	mov    %eax,%edx
  800d53:	c1 ea 0c             	shr    $0xc,%edx
  800d56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d5d:	f6 c2 01             	test   $0x1,%dl
  800d60:	74 1c                	je     800d7e <fd_alloc+0x4a>
  800d62:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800d67:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d6c:	75 d2                	jne    800d40 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800d77:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800d7c:	eb 0a                	jmp    800d88 <fd_alloc+0x54>
			*fd_store = fd;
  800d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d81:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d8a:	f3 0f 1e fb          	endbr32 
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d94:	83 f8 1f             	cmp    $0x1f,%eax
  800d97:	77 30                	ja     800dc9 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d99:	c1 e0 0c             	shl    $0xc,%eax
  800d9c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800da1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800da7:	f6 c2 01             	test   $0x1,%dl
  800daa:	74 24                	je     800dd0 <fd_lookup+0x46>
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	c1 ea 0c             	shr    $0xc,%edx
  800db1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db8:	f6 c2 01             	test   $0x1,%dl
  800dbb:	74 1a                	je     800dd7 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
		return -E_INVAL;
  800dc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dce:	eb f7                	jmp    800dc7 <fd_lookup+0x3d>
		return -E_INVAL;
  800dd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd5:	eb f0                	jmp    800dc7 <fd_lookup+0x3d>
  800dd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ddc:	eb e9                	jmp    800dc7 <fd_lookup+0x3d>

00800dde <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dde:	f3 0f 1e fb          	endbr32 
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	ba 48 28 80 00       	mov    $0x802848,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800df0:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800df5:	39 08                	cmp    %ecx,(%eax)
  800df7:	74 33                	je     800e2c <dev_lookup+0x4e>
  800df9:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800dfc:	8b 02                	mov    (%edx),%eax
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	75 f3                	jne    800df5 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e02:	a1 04 40 80 00       	mov    0x804004,%eax
  800e07:	8b 40 48             	mov    0x48(%eax),%eax
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	51                   	push   %ecx
  800e0e:	50                   	push   %eax
  800e0f:	68 cc 27 80 00       	push   $0x8027cc
  800e14:	e8 b9 f3 ff ff       	call   8001d2 <cprintf>
	*dev = 0;
  800e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    
			*dev = devtab[i];
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	eb f2                	jmp    800e2a <dev_lookup+0x4c>

00800e38 <fd_close>:
{
  800e38:	f3 0f 1e fb          	endbr32 
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	83 ec 28             	sub    $0x28,%esp
  800e45:	8b 75 08             	mov    0x8(%ebp),%esi
  800e48:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e4b:	56                   	push   %esi
  800e4c:	e8 b0 fe ff ff       	call   800d01 <fd2num>
  800e51:	83 c4 08             	add    $0x8,%esp
  800e54:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800e57:	52                   	push   %edx
  800e58:	50                   	push   %eax
  800e59:	e8 2c ff ff ff       	call   800d8a <fd_lookup>
  800e5e:	89 c3                	mov    %eax,%ebx
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 05                	js     800e6c <fd_close+0x34>
	    || fd != fd2)
  800e67:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e6a:	74 16                	je     800e82 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800e6c:	89 f8                	mov    %edi,%eax
  800e6e:	84 c0                	test   %al,%al
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
  800e75:	0f 44 d8             	cmove  %eax,%ebx
}
  800e78:	89 d8                	mov    %ebx,%eax
  800e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e88:	50                   	push   %eax
  800e89:	ff 36                	pushl  (%esi)
  800e8b:	e8 4e ff ff ff       	call   800dde <dev_lookup>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 1a                	js     800eb3 <fd_close+0x7b>
		if (dev->dev_close)
  800e99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e9c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	74 0b                	je     800eb3 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	56                   	push   %esi
  800eac:	ff d0                	call   *%eax
  800eae:	89 c3                	mov    %eax,%ebx
  800eb0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800eb3:	83 ec 08             	sub    $0x8,%esp
  800eb6:	56                   	push   %esi
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 58 fd ff ff       	call   800c16 <sys_page_unmap>
	return r;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	eb b5                	jmp    800e78 <fd_close+0x40>

00800ec3 <close>:

int
close(int fdnum)
{
  800ec3:	f3 0f 1e fb          	endbr32 
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed0:	50                   	push   %eax
  800ed1:	ff 75 08             	pushl  0x8(%ebp)
  800ed4:	e8 b1 fe ff ff       	call   800d8a <fd_lookup>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	79 02                	jns    800ee2 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    
		return fd_close(fd, 1);
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	6a 01                	push   $0x1
  800ee7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eea:	e8 49 ff ff ff       	call   800e38 <fd_close>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	eb ec                	jmp    800ee0 <close+0x1d>

00800ef4 <close_all>:

void
close_all(void)
{
  800ef4:	f3 0f 1e fb          	endbr32 
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	53                   	push   %ebx
  800efc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	53                   	push   %ebx
  800f08:	e8 b6 ff ff ff       	call   800ec3 <close>
	for (i = 0; i < MAXFD; i++)
  800f0d:	83 c3 01             	add    $0x1,%ebx
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	83 fb 20             	cmp    $0x20,%ebx
  800f16:	75 ec                	jne    800f04 <close_all+0x10>
}
  800f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1d:	f3 0f 1e fb          	endbr32 
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 75 08             	pushl  0x8(%ebp)
  800f31:	e8 54 fe ff ff       	call   800d8a <fd_lookup>
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	0f 88 81 00 00 00    	js     800fc4 <dup+0xa7>
		return r;
	close(newfdnum);
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	ff 75 0c             	pushl  0xc(%ebp)
  800f49:	e8 75 ff ff ff       	call   800ec3 <close>

	newfd = INDEX2FD(newfdnum);
  800f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f51:	c1 e6 0c             	shl    $0xc,%esi
  800f54:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f5a:	83 c4 04             	add    $0x4,%esp
  800f5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f60:	e8 b0 fd ff ff       	call   800d15 <fd2data>
  800f65:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f67:	89 34 24             	mov    %esi,(%esp)
  800f6a:	e8 a6 fd ff ff       	call   800d15 <fd2data>
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	c1 e8 16             	shr    $0x16,%eax
  800f79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f80:	a8 01                	test   $0x1,%al
  800f82:	74 11                	je     800f95 <dup+0x78>
  800f84:	89 d8                	mov    %ebx,%eax
  800f86:	c1 e8 0c             	shr    $0xc,%eax
  800f89:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f90:	f6 c2 01             	test   $0x1,%dl
  800f93:	75 39                	jne    800fce <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f98:	89 d0                	mov    %edx,%eax
  800f9a:	c1 e8 0c             	shr    $0xc,%eax
  800f9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fac:	50                   	push   %eax
  800fad:	56                   	push   %esi
  800fae:	6a 00                	push   $0x0
  800fb0:	52                   	push   %edx
  800fb1:	6a 00                	push   $0x0
  800fb3:	e8 34 fc ff ff       	call   800bec <sys_page_map>
  800fb8:	89 c3                	mov    %eax,%ebx
  800fba:	83 c4 20             	add    $0x20,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 31                	js     800ff2 <dup+0xd5>
		goto err;

	return newfdnum;
  800fc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdd:	50                   	push   %eax
  800fde:	57                   	push   %edi
  800fdf:	6a 00                	push   $0x0
  800fe1:	53                   	push   %ebx
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 03 fc ff ff       	call   800bec <sys_page_map>
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 a3                	jns    800f95 <dup+0x78>
	sys_page_unmap(0, newfd);
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	56                   	push   %esi
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 19 fc ff ff       	call   800c16 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ffd:	83 c4 08             	add    $0x8,%esp
  801000:	57                   	push   %edi
  801001:	6a 00                	push   $0x0
  801003:	e8 0e fc ff ff       	call   800c16 <sys_page_unmap>
	return r;
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	eb b7                	jmp    800fc4 <dup+0xa7>

0080100d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80100d:	f3 0f 1e fb          	endbr32 
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	53                   	push   %ebx
  801015:	83 ec 1c             	sub    $0x1c,%esp
  801018:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80101b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101e:	50                   	push   %eax
  80101f:	53                   	push   %ebx
  801020:	e8 65 fd ff ff       	call   800d8a <fd_lookup>
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 3f                	js     80106b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801036:	ff 30                	pushl  (%eax)
  801038:	e8 a1 fd ff ff       	call   800dde <dev_lookup>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 27                	js     80106b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801044:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801047:	8b 42 08             	mov    0x8(%edx),%eax
  80104a:	83 e0 03             	and    $0x3,%eax
  80104d:	83 f8 01             	cmp    $0x1,%eax
  801050:	74 1e                	je     801070 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801055:	8b 40 08             	mov    0x8(%eax),%eax
  801058:	85 c0                	test   %eax,%eax
  80105a:	74 35                	je     801091 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	ff 75 10             	pushl  0x10(%ebp)
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	52                   	push   %edx
  801066:	ff d0                	call   *%eax
  801068:	83 c4 10             	add    $0x10,%esp
}
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801070:	a1 04 40 80 00       	mov    0x804004,%eax
  801075:	8b 40 48             	mov    0x48(%eax),%eax
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	53                   	push   %ebx
  80107c:	50                   	push   %eax
  80107d:	68 0d 28 80 00       	push   $0x80280d
  801082:	e8 4b f1 ff ff       	call   8001d2 <cprintf>
		return -E_INVAL;
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108f:	eb da                	jmp    80106b <read+0x5e>
		return -E_NOT_SUPP;
  801091:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801096:	eb d3                	jmp    80106b <read+0x5e>

00801098 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801098:	f3 0f 1e fb          	endbr32 
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b0:	eb 02                	jmp    8010b4 <readn+0x1c>
  8010b2:	01 c3                	add    %eax,%ebx
  8010b4:	39 f3                	cmp    %esi,%ebx
  8010b6:	73 21                	jae    8010d9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	89 f0                	mov    %esi,%eax
  8010bd:	29 d8                	sub    %ebx,%eax
  8010bf:	50                   	push   %eax
  8010c0:	89 d8                	mov    %ebx,%eax
  8010c2:	03 45 0c             	add    0xc(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	57                   	push   %edi
  8010c7:	e8 41 ff ff ff       	call   80100d <read>
		if (m < 0)
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 04                	js     8010d7 <readn+0x3f>
			return m;
		if (m == 0)
  8010d3:	75 dd                	jne    8010b2 <readn+0x1a>
  8010d5:	eb 02                	jmp    8010d9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e3:	f3 0f 1e fb          	endbr32 
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 1c             	sub    $0x1c,%esp
  8010ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	53                   	push   %ebx
  8010f6:	e8 8f fc ff ff       	call   800d8a <fd_lookup>
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 3a                	js     80113c <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801102:	83 ec 08             	sub    $0x8,%esp
  801105:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801108:	50                   	push   %eax
  801109:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110c:	ff 30                	pushl  (%eax)
  80110e:	e8 cb fc ff ff       	call   800dde <dev_lookup>
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	78 22                	js     80113c <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80111a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801121:	74 1e                	je     801141 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801123:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801126:	8b 52 0c             	mov    0xc(%edx),%edx
  801129:	85 d2                	test   %edx,%edx
  80112b:	74 35                	je     801162 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	ff 75 10             	pushl  0x10(%ebp)
  801133:	ff 75 0c             	pushl  0xc(%ebp)
  801136:	50                   	push   %eax
  801137:	ff d2                	call   *%edx
  801139:	83 c4 10             	add    $0x10,%esp
}
  80113c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113f:	c9                   	leave  
  801140:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801141:	a1 04 40 80 00       	mov    0x804004,%eax
  801146:	8b 40 48             	mov    0x48(%eax),%eax
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	53                   	push   %ebx
  80114d:	50                   	push   %eax
  80114e:	68 29 28 80 00       	push   $0x802829
  801153:	e8 7a f0 ff ff       	call   8001d2 <cprintf>
		return -E_INVAL;
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801160:	eb da                	jmp    80113c <write+0x59>
		return -E_NOT_SUPP;
  801162:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801167:	eb d3                	jmp    80113c <write+0x59>

00801169 <seek>:

int
seek(int fdnum, off_t offset)
{
  801169:	f3 0f 1e fb          	endbr32 
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	ff 75 08             	pushl  0x8(%ebp)
  80117a:	e8 0b fc ff ff       	call   800d8a <fd_lookup>
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 0e                	js     801194 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801186:	8b 55 0c             	mov    0xc(%ebp),%edx
  801189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801196:	f3 0f 1e fb          	endbr32 
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	53                   	push   %ebx
  80119e:	83 ec 1c             	sub    $0x1c,%esp
  8011a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a7:	50                   	push   %eax
  8011a8:	53                   	push   %ebx
  8011a9:	e8 dc fb ff ff       	call   800d8a <fd_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 37                	js     8011ec <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bf:	ff 30                	pushl  (%eax)
  8011c1:	e8 18 fc ff ff       	call   800dde <dev_lookup>
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 1f                	js     8011ec <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d4:	74 1b                	je     8011f1 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d9:	8b 52 18             	mov    0x18(%edx),%edx
  8011dc:	85 d2                	test   %edx,%edx
  8011de:	74 32                	je     801212 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011e0:	83 ec 08             	sub    $0x8,%esp
  8011e3:	ff 75 0c             	pushl  0xc(%ebp)
  8011e6:	50                   	push   %eax
  8011e7:	ff d2                	call   *%edx
  8011e9:	83 c4 10             	add    $0x10,%esp
}
  8011ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8011f1:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f6:	8b 40 48             	mov    0x48(%eax),%eax
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	53                   	push   %ebx
  8011fd:	50                   	push   %eax
  8011fe:	68 ec 27 80 00       	push   $0x8027ec
  801203:	e8 ca ef ff ff       	call   8001d2 <cprintf>
		return -E_INVAL;
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb da                	jmp    8011ec <ftruncate+0x56>
		return -E_NOT_SUPP;
  801212:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801217:	eb d3                	jmp    8011ec <ftruncate+0x56>

00801219 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801219:	f3 0f 1e fb          	endbr32 
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	53                   	push   %ebx
  801221:	83 ec 1c             	sub    $0x1c,%esp
  801224:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801227:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	ff 75 08             	pushl  0x8(%ebp)
  80122e:	e8 57 fb ff ff       	call   800d8a <fd_lookup>
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	78 4b                	js     801285 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	ff 30                	pushl  (%eax)
  801246:	e8 93 fb ff ff       	call   800dde <dev_lookup>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 33                	js     801285 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801252:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801255:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801259:	74 2f                	je     80128a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80125b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801265:	00 00 00 
	stat->st_isdir = 0;
  801268:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80126f:	00 00 00 
	stat->st_dev = dev;
  801272:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	53                   	push   %ebx
  80127c:	ff 75 f0             	pushl  -0x10(%ebp)
  80127f:	ff 50 14             	call   *0x14(%eax)
  801282:	83 c4 10             	add    $0x10,%esp
}
  801285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801288:	c9                   	leave  
  801289:	c3                   	ret    
		return -E_NOT_SUPP;
  80128a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80128f:	eb f4                	jmp    801285 <fstat+0x6c>

00801291 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801291:	f3 0f 1e fb          	endbr32 
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	6a 00                	push   $0x0
  80129f:	ff 75 08             	pushl  0x8(%ebp)
  8012a2:	e8 fb 01 00 00       	call   8014a2 <open>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 1b                	js     8012cb <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	ff 75 0c             	pushl  0xc(%ebp)
  8012b6:	50                   	push   %eax
  8012b7:	e8 5d ff ff ff       	call   801219 <fstat>
  8012bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8012be:	89 1c 24             	mov    %ebx,(%esp)
  8012c1:	e8 fd fb ff ff       	call   800ec3 <close>
	return r;
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 f3                	mov    %esi,%ebx
}
  8012cb:	89 d8                	mov    %ebx,%eax
  8012cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	89 c6                	mov    %eax,%esi
  8012db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e4:	74 27                	je     80130d <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e6:	6a 07                	push   $0x7
  8012e8:	68 00 50 80 00       	push   $0x805000
  8012ed:	56                   	push   %esi
  8012ee:	ff 35 00 40 80 00    	pushl  0x804000
  8012f4:	e8 c7 0d 00 00       	call   8020c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012f9:	83 c4 0c             	add    $0xc,%esp
  8012fc:	6a 00                	push   $0x0
  8012fe:	53                   	push   %ebx
  8012ff:	6a 00                	push   $0x0
  801301:	e8 4c 0d 00 00       	call   802052 <ipc_recv>
}
  801306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	6a 01                	push   $0x1
  801312:	e8 0e 0e 00 00       	call   802125 <ipc_find_env>
  801317:	a3 00 40 80 00       	mov    %eax,0x804000
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	eb c5                	jmp    8012e6 <fsipc+0x12>

00801321 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801321:	f3 0f 1e fb          	endbr32 
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	8b 40 0c             	mov    0xc(%eax),%eax
  801331:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801336:	8b 45 0c             	mov    0xc(%ebp),%eax
  801339:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80133e:	ba 00 00 00 00       	mov    $0x0,%edx
  801343:	b8 02 00 00 00       	mov    $0x2,%eax
  801348:	e8 87 ff ff ff       	call   8012d4 <fsipc>
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <devfile_flush>:
{
  80134f:	f3 0f 1e fb          	endbr32 
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	8b 40 0c             	mov    0xc(%eax),%eax
  80135f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801364:	ba 00 00 00 00       	mov    $0x0,%edx
  801369:	b8 06 00 00 00       	mov    $0x6,%eax
  80136e:	e8 61 ff ff ff       	call   8012d4 <fsipc>
}
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <devfile_stat>:
{
  801375:	f3 0f 1e fb          	endbr32 
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	53                   	push   %ebx
  80137d:	83 ec 04             	sub    $0x4,%esp
  801380:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	8b 40 0c             	mov    0xc(%eax),%eax
  801389:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80138e:	ba 00 00 00 00       	mov    $0x0,%edx
  801393:	b8 05 00 00 00       	mov    $0x5,%eax
  801398:	e8 37 ff ff ff       	call   8012d4 <fsipc>
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 2c                	js     8013cd <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	68 00 50 80 00       	push   $0x805000
  8013a9:	53                   	push   %ebx
  8013aa:	e8 8d f3 ff ff       	call   80073c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013af:	a1 80 50 80 00       	mov    0x805080,%eax
  8013b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ba:	a1 84 50 80 00       	mov    0x805084,%eax
  8013bf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    

008013d2 <devfile_write>:
{
  8013d2:	f3 0f 1e fb          	endbr32 
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013df:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8013e5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013eb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013f0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013f5:	0f 47 c2             	cmova  %edx,%eax
  8013f8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013fd:	50                   	push   %eax
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	68 08 50 80 00       	push   $0x805008
  801406:	e8 e9 f4 ff ff       	call   8008f4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	b8 04 00 00 00       	mov    $0x4,%eax
  801415:	e8 ba fe ff ff       	call   8012d4 <fsipc>
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devfile_read>:
{
  80141c:	f3 0f 1e fb          	endbr32 
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
  80142b:	8b 40 0c             	mov    0xc(%eax),%eax
  80142e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801433:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801439:	ba 00 00 00 00       	mov    $0x0,%edx
  80143e:	b8 03 00 00 00       	mov    $0x3,%eax
  801443:	e8 8c fe ff ff       	call   8012d4 <fsipc>
  801448:	89 c3                	mov    %eax,%ebx
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 1f                	js     80146d <devfile_read+0x51>
	assert(r <= n);
  80144e:	39 f0                	cmp    %esi,%eax
  801450:	77 24                	ja     801476 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801452:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801457:	7f 33                	jg     80148c <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	50                   	push   %eax
  80145d:	68 00 50 80 00       	push   $0x805000
  801462:	ff 75 0c             	pushl  0xc(%ebp)
  801465:	e8 8a f4 ff ff       	call   8008f4 <memmove>
	return r;
  80146a:	83 c4 10             	add    $0x10,%esp
}
  80146d:	89 d8                	mov    %ebx,%eax
  80146f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    
	assert(r <= n);
  801476:	68 58 28 80 00       	push   $0x802858
  80147b:	68 5f 28 80 00       	push   $0x80285f
  801480:	6a 7c                	push   $0x7c
  801482:	68 74 28 80 00       	push   $0x802874
  801487:	e8 5f ec ff ff       	call   8000eb <_panic>
	assert(r <= PGSIZE);
  80148c:	68 7f 28 80 00       	push   $0x80287f
  801491:	68 5f 28 80 00       	push   $0x80285f
  801496:	6a 7d                	push   $0x7d
  801498:	68 74 28 80 00       	push   $0x802874
  80149d:	e8 49 ec ff ff       	call   8000eb <_panic>

008014a2 <open>:
{
  8014a2:	f3 0f 1e fb          	endbr32 
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 1c             	sub    $0x1c,%esp
  8014ae:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014b1:	56                   	push   %esi
  8014b2:	e8 42 f2 ff ff       	call   8006f9 <strlen>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014bf:	7f 6c                	jg     80152d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	e8 67 f8 ff ff       	call   800d34 <fd_alloc>
  8014cd:	89 c3                	mov    %eax,%ebx
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 3c                	js     801512 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	56                   	push   %esi
  8014da:	68 00 50 80 00       	push   $0x805000
  8014df:	e8 58 f2 ff ff       	call   80073c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f4:	e8 db fd ff ff       	call   8012d4 <fsipc>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 19                	js     80151b <open+0x79>
	return fd2num(fd);
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	ff 75 f4             	pushl  -0xc(%ebp)
  801508:	e8 f4 f7 ff ff       	call   800d01 <fd2num>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	83 c4 10             	add    $0x10,%esp
}
  801512:	89 d8                	mov    %ebx,%eax
  801514:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    
		fd_close(fd, 0);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	6a 00                	push   $0x0
  801520:	ff 75 f4             	pushl  -0xc(%ebp)
  801523:	e8 10 f9 ff ff       	call   800e38 <fd_close>
		return r;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	eb e5                	jmp    801512 <open+0x70>
		return -E_BAD_PATH;
  80152d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801532:	eb de                	jmp    801512 <open+0x70>

00801534 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801534:	f3 0f 1e fb          	endbr32 
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80153e:	ba 00 00 00 00       	mov    $0x0,%edx
  801543:	b8 08 00 00 00       	mov    $0x8,%eax
  801548:	e8 87 fd ff ff       	call   8012d4 <fsipc>
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801556:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80155b:	eb 33                	jmp    801590 <copy_shared_pages+0x41>
		if(addr != UXSTACKTOP - PGSIZE){
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
				sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80155d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	25 07 0e 00 00       	and    $0xe07,%eax
  80156c:	50                   	push   %eax
  80156d:	53                   	push   %ebx
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	6a 00                	push   $0x0
  801572:	e8 75 f6 ff ff       	call   800bec <sys_page_map>
  801577:	83 c4 20             	add    $0x20,%esp
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  80157a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801580:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801586:	77 2f                	ja     8015b7 <copy_shared_pages+0x68>
		if(addr != UXSTACKTOP - PGSIZE){
  801588:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80158e:	74 ea                	je     80157a <copy_shared_pages+0x2b>
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
  801590:	89 d8                	mov    %ebx,%eax
  801592:	c1 e8 16             	shr    $0x16,%eax
  801595:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80159c:	a8 01                	test   $0x1,%al
  80159e:	74 da                	je     80157a <copy_shared_pages+0x2b>
  8015a0:	89 da                	mov    %ebx,%edx
  8015a2:	c1 ea 0c             	shr    $0xc,%edx
  8015a5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015ac:	f7 d0                	not    %eax
  8015ae:	a9 05 04 00 00       	test   $0x405,%eax
  8015b3:	75 c5                	jne    80157a <copy_shared_pages+0x2b>
  8015b5:	eb a6                	jmp    80155d <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  8015b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <init_stack>:
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 2c             	sub    $0x2c,%esp
  8015cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8015cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8015d2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  8015d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8015da:	be 00 00 00 00       	mov    $0x0,%esi
  8015df:	89 d7                	mov    %edx,%edi
  8015e1:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  8015e8:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 15                	je     801604 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	50                   	push   %eax
  8015f3:	e8 01 f1 ff ff       	call   8006f9 <strlen>
  8015f8:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8015fc:	83 c3 01             	add    $0x1,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb dd                	jmp    8015e1 <init_stack+0x1e>
  801604:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801607:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  80160a:	bf 00 10 40 00       	mov    $0x401000,%edi
  80160f:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801611:	89 fa                	mov    %edi,%edx
  801613:	83 e2 fc             	and    $0xfffffffc,%edx
  801616:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80161d:	29 c2                	sub    %eax,%edx
  80161f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801622:	8d 42 f8             	lea    -0x8(%edx),%eax
  801625:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80162a:	0f 86 06 01 00 00    	jbe    801736 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801630:	83 ec 04             	sub    $0x4,%esp
  801633:	6a 07                	push   $0x7
  801635:	68 00 00 40 00       	push   $0x400000
  80163a:	6a 00                	push   $0x0
  80163c:	e8 83 f5 ff ff       	call   800bc4 <sys_page_alloc>
  801641:	89 c6                	mov    %eax,%esi
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	0f 88 de 00 00 00    	js     80172c <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  80164e:	be 00 00 00 00       	mov    $0x0,%esi
  801653:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801656:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801659:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  80165c:	7e 2f                	jle    80168d <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  80165e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801664:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801667:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801670:	57                   	push   %edi
  801671:	e8 c6 f0 ff ff       	call   80073c <strcpy>
		string_store += strlen(argv[i]) + 1;
  801676:	83 c4 04             	add    $0x4,%esp
  801679:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80167c:	e8 78 f0 ff ff       	call   8006f9 <strlen>
  801681:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801685:	83 c6 01             	add    $0x1,%esi
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb cc                	jmp    801659 <init_stack+0x96>
	argv_store[argc] = 0;
  80168d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801690:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  801693:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  80169a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8016a0:	75 5f                	jne    801701 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  8016a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016a5:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  8016ab:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8016ae:	89 d0                	mov    %edx,%eax
  8016b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8016b3:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8016b6:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8016bb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8016be:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	6a 07                	push   $0x7
  8016c5:	68 00 d0 bf ee       	push   $0xeebfd000
  8016ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016cd:	68 00 00 40 00       	push   $0x400000
  8016d2:	6a 00                	push   $0x0
  8016d4:	e8 13 f5 ff ff       	call   800bec <sys_page_map>
  8016d9:	89 c6                	mov    %eax,%esi
  8016db:	83 c4 20             	add    $0x20,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 38                	js     80171a <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	68 00 00 40 00       	push   $0x400000
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 25 f5 ff ff       	call   800c16 <sys_page_unmap>
  8016f1:	89 c6                	mov    %eax,%esi
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 20                	js     80171a <init_stack+0x157>
	return 0;
  8016fa:	be 00 00 00 00       	mov    $0x0,%esi
  8016ff:	eb 2b                	jmp    80172c <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  801701:	68 8c 28 80 00       	push   $0x80288c
  801706:	68 5f 28 80 00       	push   $0x80285f
  80170b:	68 fc 00 00 00       	push   $0xfc
  801710:	68 b4 28 80 00       	push   $0x8028b4
  801715:	e8 d1 e9 ff ff       	call   8000eb <_panic>
	sys_page_unmap(0, UTEMP);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	68 00 00 40 00       	push   $0x400000
  801722:	6a 00                	push   $0x0
  801724:	e8 ed f4 ff ff       	call   800c16 <sys_page_unmap>
	return r;
  801729:	83 c4 10             	add    $0x10,%esp
}
  80172c:	89 f0                	mov    %esi,%eax
  80172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    
		return -E_NO_MEM;
  801736:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  80173b:	eb ef                	jmp    80172c <init_stack+0x169>

0080173d <map_segment>:
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	57                   	push   %edi
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	83 ec 1c             	sub    $0x1c,%esp
  801746:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801749:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80174c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80174f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  801752:	89 d0                	mov    %edx,%eax
  801754:	25 ff 0f 00 00       	and    $0xfff,%eax
  801759:	74 0f                	je     80176a <map_segment+0x2d>
		va -= i;
  80175b:	29 c2                	sub    %eax,%edx
  80175d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  801760:	01 c1                	add    %eax,%ecx
  801762:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  801765:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801767:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  80176a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176f:	e9 99 00 00 00       	jmp    80180d <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	6a 07                	push   $0x7
  801779:	68 00 00 40 00       	push   $0x400000
  80177e:	6a 00                	push   $0x0
  801780:	e8 3f f4 ff ff       	call   800bc4 <sys_page_alloc>
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	0f 88 c1 00 00 00    	js     801851 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801790:	83 ec 08             	sub    $0x8,%esp
  801793:	89 f0                	mov    %esi,%eax
  801795:	03 45 10             	add    0x10(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	ff 75 08             	pushl  0x8(%ebp)
  80179c:	e8 c8 f9 ff ff       	call   801169 <seek>
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	0f 88 a5 00 00 00    	js     801851 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	89 f8                	mov    %edi,%eax
  8017b1:	29 f0                	sub    %esi,%eax
  8017b3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b8:	ba 00 10 00 00       	mov    $0x1000,%edx
  8017bd:	0f 47 c2             	cmova  %edx,%eax
  8017c0:	50                   	push   %eax
  8017c1:	68 00 00 40 00       	push   $0x400000
  8017c6:	ff 75 08             	pushl  0x8(%ebp)
  8017c9:	e8 ca f8 ff ff       	call   801098 <readn>
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 7c                	js     801851 <map_segment+0x114>
			if ((r = sys_page_map(
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	ff 75 14             	pushl  0x14(%ebp)
  8017db:	03 75 e0             	add    -0x20(%ebp),%esi
  8017de:	56                   	push   %esi
  8017df:	ff 75 dc             	pushl  -0x24(%ebp)
  8017e2:	68 00 00 40 00       	push   $0x400000
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 fe f3 ff ff       	call   800bec <sys_page_map>
  8017ee:	83 c4 20             	add    $0x20,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 42                	js     801837 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	68 00 00 40 00       	push   $0x400000
  8017fd:	6a 00                	push   $0x0
  8017ff:	e8 12 f4 ff ff       	call   800c16 <sys_page_unmap>
  801804:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801807:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80180d:	89 de                	mov    %ebx,%esi
  80180f:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  801812:	76 38                	jbe    80184c <map_segment+0x10f>
		if (i >= filesz) {
  801814:	39 df                	cmp    %ebx,%edi
  801816:	0f 87 58 ff ff ff    	ja     801774 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	ff 75 14             	pushl  0x14(%ebp)
  801822:	03 75 e0             	add    -0x20(%ebp),%esi
  801825:	56                   	push   %esi
  801826:	ff 75 dc             	pushl  -0x24(%ebp)
  801829:	e8 96 f3 ff ff       	call   800bc4 <sys_page_alloc>
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	79 d2                	jns    801807 <map_segment+0xca>
  801835:	eb 1a                	jmp    801851 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  801837:	50                   	push   %eax
  801838:	68 c0 28 80 00       	push   $0x8028c0
  80183d:	68 3a 01 00 00       	push   $0x13a
  801842:	68 b4 28 80 00       	push   $0x8028b4
  801847:	e8 9f e8 ff ff       	call   8000eb <_panic>
	return 0;
  80184c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801851:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801854:	5b                   	pop    %ebx
  801855:	5e                   	pop    %esi
  801856:	5f                   	pop    %edi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <spawn>:
{
  801859:	f3 0f 1e fb          	endbr32 
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	57                   	push   %edi
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  801869:	6a 00                	push   $0x0
  80186b:	ff 75 08             	pushl  0x8(%ebp)
  80186e:	e8 2f fc ff ff       	call   8014a2 <open>
  801873:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 c0                	test   %eax,%eax
  80187e:	0f 88 0b 02 00 00    	js     801a8f <spawn+0x236>
  801884:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	68 00 02 00 00       	push   $0x200
  80188e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801894:	50                   	push   %eax
  801895:	57                   	push   %edi
  801896:	e8 fd f7 ff ff       	call   801098 <readn>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018a3:	0f 85 85 00 00 00    	jne    80192e <spawn+0xd5>
  8018a9:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018b0:	45 4c 46 
  8018b3:	75 79                	jne    80192e <spawn+0xd5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018b5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ba:	cd 30                	int    $0x30
  8018bc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c2:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	0f 88 b1 01 00 00    	js     801a83 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  8018d2:	89 c6                	mov    %eax,%esi
  8018d4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8018da:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8018dd:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8018e3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018e9:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018f0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018f6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  8018fc:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801902:	8b 55 0c             	mov    0xc(%ebp),%edx
  801905:	89 d8                	mov    %ebx,%eax
  801907:	e8 b7 fc ff ff       	call   8015c3 <init_stack>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	0f 88 89 01 00 00    	js     801a9d <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  801914:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80191a:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801921:	be 00 00 00 00       	mov    $0x0,%esi
  801926:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80192c:	eb 3e                	jmp    80196c <spawn+0x113>
		close(fd);
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801937:	e8 87 f5 ff ff       	call   800ec3 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80193c:	83 c4 0c             	add    $0xc,%esp
  80193f:	68 7f 45 4c 46       	push   $0x464c457f
  801944:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80194a:	68 dd 28 80 00       	push   $0x8028dd
  80194f:	e8 7e e8 ff ff       	call   8001d2 <cprintf>
		return -E_NOT_EXEC;
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  80195e:	ff ff ff 
  801961:	e9 29 01 00 00       	jmp    801a8f <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801966:	83 c6 01             	add    $0x1,%esi
  801969:	83 c3 20             	add    $0x20,%ebx
  80196c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801973:	39 f0                	cmp    %esi,%eax
  801975:	7e 62                	jle    8019d9 <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  801977:	83 3b 01             	cmpl   $0x1,(%ebx)
  80197a:	75 ea                	jne    801966 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80197c:	8b 43 18             	mov    0x18(%ebx),%eax
  80197f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801982:	83 f8 01             	cmp    $0x1,%eax
  801985:	19 c0                	sbb    %eax,%eax
  801987:	83 e0 fe             	and    $0xfffffffe,%eax
  80198a:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  80198d:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801990:	8b 53 08             	mov    0x8(%ebx),%edx
  801993:	50                   	push   %eax
  801994:	ff 73 04             	pushl  0x4(%ebx)
  801997:	ff 73 10             	pushl  0x10(%ebx)
  80199a:	57                   	push   %edi
  80199b:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8019a1:	e8 97 fd ff ff       	call   80173d <map_segment>
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	79 b9                	jns    801966 <spawn+0x10d>
  8019ad:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019b8:	e8 8e f1 ff ff       	call   800b4b <sys_env_destroy>
	close(fd);
  8019bd:	83 c4 04             	add    $0x4,%esp
  8019c0:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8019c6:	e8 f8 f4 ff ff       	call   800ec3 <close>
	return r;
  8019cb:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  8019ce:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  8019d4:	e9 b6 00 00 00       	jmp    801a8f <spawn+0x236>
	close(fd);
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8019e2:	e8 dc f4 ff ff       	call   800ec3 <close>
	if ((r = copy_shared_pages(child)) < 0)
  8019e7:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8019ed:	e8 5d fb ff ff       	call   80154f <copy_shared_pages>
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 4b                	js     801a44 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  8019f9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801a00:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a13:	e8 4c f2 ff ff       	call   800c64 <sys_env_set_trapframe>
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 3a                	js     801a59 <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	6a 02                	push   $0x2
  801a24:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a2a:	e8 0e f2 ff ff       	call   800c3d <sys_env_set_status>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 38                	js     801a6e <spawn+0x215>
	return child;
  801a36:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801a3c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a42:	eb 4b                	jmp    801a8f <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  801a44:	50                   	push   %eax
  801a45:	68 f7 28 80 00       	push   $0x8028f7
  801a4a:	68 8c 00 00 00       	push   $0x8c
  801a4f:	68 b4 28 80 00       	push   $0x8028b4
  801a54:	e8 92 e6 ff ff       	call   8000eb <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801a59:	50                   	push   %eax
  801a5a:	68 0d 29 80 00       	push   $0x80290d
  801a5f:	68 90 00 00 00       	push   $0x90
  801a64:	68 b4 28 80 00       	push   $0x8028b4
  801a69:	e8 7d e6 ff ff       	call   8000eb <_panic>
		panic("sys_env_set_status: %e", r);
  801a6e:	50                   	push   %eax
  801a6f:	68 27 29 80 00       	push   $0x802927
  801a74:	68 93 00 00 00       	push   $0x93
  801a79:	68 b4 28 80 00       	push   $0x8028b4
  801a7e:	e8 68 e6 ff ff       	call   8000eb <_panic>
		return r;
  801a83:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801a89:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801a8f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5f                   	pop    %edi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    
		return r;
  801a9d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801aa3:	eb ea                	jmp    801a8f <spawn+0x236>

00801aa5 <spawnl>:
{
  801aa5:	f3 0f 1e fb          	endbr32 
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801ab2:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  801aba:	8d 4a 04             	lea    0x4(%edx),%ecx
  801abd:	83 3a 00             	cmpl   $0x0,(%edx)
  801ac0:	74 07                	je     801ac9 <spawnl+0x24>
		argc++;
  801ac2:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  801ac5:	89 ca                	mov    %ecx,%edx
  801ac7:	eb f1                	jmp    801aba <spawnl+0x15>
	const char *argv[argc + 2];
  801ac9:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801ad0:	89 d1                	mov    %edx,%ecx
  801ad2:	83 e1 f0             	and    $0xfffffff0,%ecx
  801ad5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801adb:	89 e6                	mov    %esp,%esi
  801add:	29 d6                	sub    %edx,%esi
  801adf:	89 f2                	mov    %esi,%edx
  801ae1:	39 d4                	cmp    %edx,%esp
  801ae3:	74 10                	je     801af5 <spawnl+0x50>
  801ae5:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801aeb:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801af2:	00 
  801af3:	eb ec                	jmp    801ae1 <spawnl+0x3c>
  801af5:	89 ca                	mov    %ecx,%edx
  801af7:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801afd:	29 d4                	sub    %edx,%esp
  801aff:	85 d2                	test   %edx,%edx
  801b01:	74 05                	je     801b08 <spawnl+0x63>
  801b03:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801b08:	8d 74 24 03          	lea    0x3(%esp),%esi
  801b0c:	89 f2                	mov    %esi,%edx
  801b0e:	c1 ea 02             	shr    $0x2,%edx
  801b11:	83 e6 fc             	and    $0xfffffffc,%esi
  801b14:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b19:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  801b20:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b27:	00 
	va_start(vl, arg0);
  801b28:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801b2b:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b32:	eb 0b                	jmp    801b3f <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  801b34:	83 c0 01             	add    $0x1,%eax
  801b37:	8b 39                	mov    (%ecx),%edi
  801b39:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801b3c:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  801b3f:	39 d0                	cmp    %edx,%eax
  801b41:	75 f1                	jne    801b34 <spawnl+0x8f>
	return spawn(prog, argv);
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	56                   	push   %esi
  801b47:	ff 75 08             	pushl  0x8(%ebp)
  801b4a:	e8 0a fd ff ff       	call   801859 <spawn>
}
  801b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b52:	5b                   	pop    %ebx
  801b53:	5e                   	pop    %esi
  801b54:	5f                   	pop    %edi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b57:	f3 0f 1e fb          	endbr32 
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	ff 75 08             	pushl  0x8(%ebp)
  801b69:	e8 a7 f1 ff ff       	call   800d15 <fd2data>
  801b6e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b70:	83 c4 08             	add    $0x8,%esp
  801b73:	68 3e 29 80 00       	push   $0x80293e
  801b78:	53                   	push   %ebx
  801b79:	e8 be eb ff ff       	call   80073c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b7e:	8b 46 04             	mov    0x4(%esi),%eax
  801b81:	2b 06                	sub    (%esi),%eax
  801b83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b89:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b90:	00 00 00 
	stat->st_dev = &devpipe;
  801b93:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b9a:	30 80 00 
	return 0;
}
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba9:	f3 0f 1e fb          	endbr32 
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb7:	53                   	push   %ebx
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 57 f0 ff ff       	call   800c16 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bbf:	89 1c 24             	mov    %ebx,(%esp)
  801bc2:	e8 4e f1 ff ff       	call   800d15 <fd2data>
  801bc7:	83 c4 08             	add    $0x8,%esp
  801bca:	50                   	push   %eax
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 44 f0 ff ff       	call   800c16 <sys_page_unmap>
}
  801bd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <_pipeisclosed>:
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 1c             	sub    $0x1c,%esp
  801be0:	89 c7                	mov    %eax,%edi
  801be2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801be4:	a1 04 40 80 00       	mov    0x804004,%eax
  801be9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	57                   	push   %edi
  801bf0:	e8 6d 05 00 00       	call   802162 <pageref>
  801bf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bf8:	89 34 24             	mov    %esi,(%esp)
  801bfb:	e8 62 05 00 00       	call   802162 <pageref>
		nn = thisenv->env_runs;
  801c00:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c06:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	39 cb                	cmp    %ecx,%ebx
  801c0e:	74 1b                	je     801c2b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c10:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c13:	75 cf                	jne    801be4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c15:	8b 42 58             	mov    0x58(%edx),%eax
  801c18:	6a 01                	push   $0x1
  801c1a:	50                   	push   %eax
  801c1b:	53                   	push   %ebx
  801c1c:	68 45 29 80 00       	push   $0x802945
  801c21:	e8 ac e5 ff ff       	call   8001d2 <cprintf>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	eb b9                	jmp    801be4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c2b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c2e:	0f 94 c0             	sete   %al
  801c31:	0f b6 c0             	movzbl %al,%eax
}
  801c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c37:	5b                   	pop    %ebx
  801c38:	5e                   	pop    %esi
  801c39:	5f                   	pop    %edi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <devpipe_write>:
{
  801c3c:	f3 0f 1e fb          	endbr32 
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	83 ec 28             	sub    $0x28,%esp
  801c49:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c4c:	56                   	push   %esi
  801c4d:	e8 c3 f0 ff ff       	call   800d15 <fd2data>
  801c52:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	bf 00 00 00 00       	mov    $0x0,%edi
  801c5c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c5f:	74 4f                	je     801cb0 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c61:	8b 43 04             	mov    0x4(%ebx),%eax
  801c64:	8b 0b                	mov    (%ebx),%ecx
  801c66:	8d 51 20             	lea    0x20(%ecx),%edx
  801c69:	39 d0                	cmp    %edx,%eax
  801c6b:	72 14                	jb     801c81 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c6d:	89 da                	mov    %ebx,%edx
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	e8 61 ff ff ff       	call   801bd7 <_pipeisclosed>
  801c76:	85 c0                	test   %eax,%eax
  801c78:	75 3b                	jne    801cb5 <devpipe_write+0x79>
			sys_yield();
  801c7a:	e8 1a ef ff ff       	call   800b99 <sys_yield>
  801c7f:	eb e0                	jmp    801c61 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c84:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c88:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c8b:	89 c2                	mov    %eax,%edx
  801c8d:	c1 fa 1f             	sar    $0x1f,%edx
  801c90:	89 d1                	mov    %edx,%ecx
  801c92:	c1 e9 1b             	shr    $0x1b,%ecx
  801c95:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c98:	83 e2 1f             	and    $0x1f,%edx
  801c9b:	29 ca                	sub    %ecx,%edx
  801c9d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca5:	83 c0 01             	add    $0x1,%eax
  801ca8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cab:	83 c7 01             	add    $0x1,%edi
  801cae:	eb ac                	jmp    801c5c <devpipe_write+0x20>
	return i;
  801cb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb3:	eb 05                	jmp    801cba <devpipe_write+0x7e>
				return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <devpipe_read>:
{
  801cc2:	f3 0f 1e fb          	endbr32 
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	57                   	push   %edi
  801cca:	56                   	push   %esi
  801ccb:	53                   	push   %ebx
  801ccc:	83 ec 18             	sub    $0x18,%esp
  801ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cd2:	57                   	push   %edi
  801cd3:	e8 3d f0 ff ff       	call   800d15 <fd2data>
  801cd8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	be 00 00 00 00       	mov    $0x0,%esi
  801ce2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ce5:	75 14                	jne    801cfb <devpipe_read+0x39>
	return i;
  801ce7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cea:	eb 02                	jmp    801cee <devpipe_read+0x2c>
				return i;
  801cec:	89 f0                	mov    %esi,%eax
}
  801cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    
			sys_yield();
  801cf6:	e8 9e ee ff ff       	call   800b99 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cfb:	8b 03                	mov    (%ebx),%eax
  801cfd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d00:	75 18                	jne    801d1a <devpipe_read+0x58>
			if (i > 0)
  801d02:	85 f6                	test   %esi,%esi
  801d04:	75 e6                	jne    801cec <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d06:	89 da                	mov    %ebx,%edx
  801d08:	89 f8                	mov    %edi,%eax
  801d0a:	e8 c8 fe ff ff       	call   801bd7 <_pipeisclosed>
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	74 e3                	je     801cf6 <devpipe_read+0x34>
				return 0;
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	eb d4                	jmp    801cee <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d1a:	99                   	cltd   
  801d1b:	c1 ea 1b             	shr    $0x1b,%edx
  801d1e:	01 d0                	add    %edx,%eax
  801d20:	83 e0 1f             	and    $0x1f,%eax
  801d23:	29 d0                	sub    %edx,%eax
  801d25:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d30:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d33:	83 c6 01             	add    $0x1,%esi
  801d36:	eb aa                	jmp    801ce2 <devpipe_read+0x20>

00801d38 <pipe>:
{
  801d38:	f3 0f 1e fb          	endbr32 
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d47:	50                   	push   %eax
  801d48:	e8 e7 ef ff ff       	call   800d34 <fd_alloc>
  801d4d:	89 c3                	mov    %eax,%ebx
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 23 01 00 00    	js     801e7d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	68 07 04 00 00       	push   $0x407
  801d62:	ff 75 f4             	pushl  -0xc(%ebp)
  801d65:	6a 00                	push   $0x0
  801d67:	e8 58 ee ff ff       	call   800bc4 <sys_page_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	0f 88 04 01 00 00    	js     801e7d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7f:	50                   	push   %eax
  801d80:	e8 af ef ff ff       	call   800d34 <fd_alloc>
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	0f 88 db 00 00 00    	js     801e6d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d92:	83 ec 04             	sub    $0x4,%esp
  801d95:	68 07 04 00 00       	push   $0x407
  801d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9d:	6a 00                	push   $0x0
  801d9f:	e8 20 ee ff ff       	call   800bc4 <sys_page_alloc>
  801da4:	89 c3                	mov    %eax,%ebx
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	0f 88 bc 00 00 00    	js     801e6d <pipe+0x135>
	va = fd2data(fd0);
  801db1:	83 ec 0c             	sub    $0xc,%esp
  801db4:	ff 75 f4             	pushl  -0xc(%ebp)
  801db7:	e8 59 ef ff ff       	call   800d15 <fd2data>
  801dbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbe:	83 c4 0c             	add    $0xc,%esp
  801dc1:	68 07 04 00 00       	push   $0x407
  801dc6:	50                   	push   %eax
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 f6 ed ff ff       	call   800bc4 <sys_page_alloc>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	0f 88 82 00 00 00    	js     801e5d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	ff 75 f0             	pushl  -0x10(%ebp)
  801de1:	e8 2f ef ff ff       	call   800d15 <fd2data>
  801de6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ded:	50                   	push   %eax
  801dee:	6a 00                	push   $0x0
  801df0:	56                   	push   %esi
  801df1:	6a 00                	push   $0x0
  801df3:	e8 f4 ed ff ff       	call   800bec <sys_page_map>
  801df8:	89 c3                	mov    %eax,%ebx
  801dfa:	83 c4 20             	add    $0x20,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 4e                	js     801e4f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e01:	a1 20 30 80 00       	mov    0x803020,%eax
  801e06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e09:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e0e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e15:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e18:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2a:	e8 d2 ee ff ff       	call   800d01 <fd2num>
  801e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e32:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e34:	83 c4 04             	add    $0x4,%esp
  801e37:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3a:	e8 c2 ee ff ff       	call   800d01 <fd2num>
  801e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e42:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e4d:	eb 2e                	jmp    801e7d <pipe+0x145>
	sys_page_unmap(0, va);
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	56                   	push   %esi
  801e53:	6a 00                	push   $0x0
  801e55:	e8 bc ed ff ff       	call   800c16 <sys_page_unmap>
  801e5a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e5d:	83 ec 08             	sub    $0x8,%esp
  801e60:	ff 75 f0             	pushl  -0x10(%ebp)
  801e63:	6a 00                	push   $0x0
  801e65:	e8 ac ed ff ff       	call   800c16 <sys_page_unmap>
  801e6a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	ff 75 f4             	pushl  -0xc(%ebp)
  801e73:	6a 00                	push   $0x0
  801e75:	e8 9c ed ff ff       	call   800c16 <sys_page_unmap>
  801e7a:	83 c4 10             	add    $0x10,%esp
}
  801e7d:	89 d8                	mov    %ebx,%eax
  801e7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <pipeisclosed>:
{
  801e86:	f3 0f 1e fb          	endbr32 
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e93:	50                   	push   %eax
  801e94:	ff 75 08             	pushl  0x8(%ebp)
  801e97:	e8 ee ee ff ff       	call   800d8a <fd_lookup>
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	78 18                	js     801ebb <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801ea3:	83 ec 0c             	sub    $0xc,%esp
  801ea6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea9:	e8 67 ee ff ff       	call   800d15 <fd2data>
  801eae:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb3:	e8 1f fd ff ff       	call   801bd7 <_pipeisclosed>
  801eb8:	83 c4 10             	add    $0x10,%esp
}
  801ebb:	c9                   	leave  
  801ebc:	c3                   	ret    

00801ebd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ebd:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec6:	c3                   	ret    

00801ec7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec7:	f3 0f 1e fb          	endbr32 
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ed1:	68 5d 29 80 00       	push   $0x80295d
  801ed6:	ff 75 0c             	pushl  0xc(%ebp)
  801ed9:	e8 5e e8 ff ff       	call   80073c <strcpy>
	return 0;
}
  801ede:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <devcons_write>:
{
  801ee5:	f3 0f 1e fb          	endbr32 
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	57                   	push   %edi
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ef5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801efa:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f00:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f03:	73 31                	jae    801f36 <devcons_write+0x51>
		m = n - tot;
  801f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f08:	29 f3                	sub    %esi,%ebx
  801f0a:	83 fb 7f             	cmp    $0x7f,%ebx
  801f0d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f12:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f15:	83 ec 04             	sub    $0x4,%esp
  801f18:	53                   	push   %ebx
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	03 45 0c             	add    0xc(%ebp),%eax
  801f1e:	50                   	push   %eax
  801f1f:	57                   	push   %edi
  801f20:	e8 cf e9 ff ff       	call   8008f4 <memmove>
		sys_cputs(buf, m);
  801f25:	83 c4 08             	add    $0x8,%esp
  801f28:	53                   	push   %ebx
  801f29:	57                   	push   %edi
  801f2a:	e8 ca eb ff ff       	call   800af9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f2f:	01 de                	add    %ebx,%esi
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	eb ca                	jmp    801f00 <devcons_write+0x1b>
}
  801f36:	89 f0                	mov    %esi,%eax
  801f38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5f                   	pop    %edi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <devcons_read>:
{
  801f40:	f3 0f 1e fb          	endbr32 
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 08             	sub    $0x8,%esp
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f53:	74 21                	je     801f76 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f55:	e8 c9 eb ff ff       	call   800b23 <sys_cgetc>
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	75 07                	jne    801f65 <devcons_read+0x25>
		sys_yield();
  801f5e:	e8 36 ec ff ff       	call   800b99 <sys_yield>
  801f63:	eb f0                	jmp    801f55 <devcons_read+0x15>
	if (c < 0)
  801f65:	78 0f                	js     801f76 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f67:	83 f8 04             	cmp    $0x4,%eax
  801f6a:	74 0c                	je     801f78 <devcons_read+0x38>
	*(char*)vbuf = c;
  801f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6f:	88 02                	mov    %al,(%edx)
	return 1;
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    
		return 0;
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7d:	eb f7                	jmp    801f76 <devcons_read+0x36>

00801f7f <cputchar>:
{
  801f7f:	f3 0f 1e fb          	endbr32 
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f8f:	6a 01                	push   $0x1
  801f91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	e8 5f eb ff ff       	call   800af9 <sys_cputs>
}
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    

00801f9f <getchar>:
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fa9:	6a 01                	push   $0x1
  801fab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fae:	50                   	push   %eax
  801faf:	6a 00                	push   $0x0
  801fb1:	e8 57 f0 ff ff       	call   80100d <read>
	if (r < 0)
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 06                	js     801fc3 <getchar+0x24>
	if (r < 1)
  801fbd:	74 06                	je     801fc5 <getchar+0x26>
	return c;
  801fbf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    
		return -E_EOF;
  801fc5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fca:	eb f7                	jmp    801fc3 <getchar+0x24>

00801fcc <iscons>:
{
  801fcc:	f3 0f 1e fb          	endbr32 
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd9:	50                   	push   %eax
  801fda:	ff 75 08             	pushl  0x8(%ebp)
  801fdd:	e8 a8 ed ff ff       	call   800d8a <fd_lookup>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 11                	js     801ffa <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ff2:	39 10                	cmp    %edx,(%eax)
  801ff4:	0f 94 c0             	sete   %al
  801ff7:	0f b6 c0             	movzbl %al,%eax
}
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <opencons>:
{
  801ffc:	f3 0f 1e fb          	endbr32 
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802006:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802009:	50                   	push   %eax
  80200a:	e8 25 ed ff ff       	call   800d34 <fd_alloc>
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	85 c0                	test   %eax,%eax
  802014:	78 3a                	js     802050 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802016:	83 ec 04             	sub    $0x4,%esp
  802019:	68 07 04 00 00       	push   $0x407
  80201e:	ff 75 f4             	pushl  -0xc(%ebp)
  802021:	6a 00                	push   $0x0
  802023:	e8 9c eb ff ff       	call   800bc4 <sys_page_alloc>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 21                	js     802050 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802038:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80203a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	50                   	push   %eax
  802048:	e8 b4 ec ff ff       	call   800d01 <fd2num>
  80204d:	83 c4 10             	add    $0x10,%esp
}
  802050:	c9                   	leave  
  802051:	c3                   	ret    

00802052 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802052:	f3 0f 1e fb          	endbr32 
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	56                   	push   %esi
  80205a:	53                   	push   %ebx
  80205b:	8b 75 08             	mov    0x8(%ebp),%esi
  80205e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  802064:	85 c0                	test   %eax,%eax
  802066:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80206b:	0f 44 c2             	cmove  %edx,%eax
  80206e:	83 ec 0c             	sub    $0xc,%esp
  802071:	50                   	push   %eax
  802072:	e8 64 ec ff ff       	call   800cdb <sys_ipc_recv>

	if (from_env_store != NULL)
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	85 f6                	test   %esi,%esi
  80207c:	74 15                	je     802093 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  80207e:	ba 00 00 00 00       	mov    $0x0,%edx
  802083:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802086:	74 09                	je     802091 <ipc_recv+0x3f>
  802088:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80208e:	8b 52 74             	mov    0x74(%edx),%edx
  802091:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  802093:	85 db                	test   %ebx,%ebx
  802095:	74 15                	je     8020ac <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  802097:	ba 00 00 00 00       	mov    $0x0,%edx
  80209c:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80209f:	74 09                	je     8020aa <ipc_recv+0x58>
  8020a1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8020a7:	8b 52 78             	mov    0x78(%edx),%edx
  8020aa:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8020ac:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020af:	74 08                	je     8020b9 <ipc_recv+0x67>
  8020b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020b6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020bc:	5b                   	pop    %ebx
  8020bd:	5e                   	pop    %esi
  8020be:	5d                   	pop    %ebp
  8020bf:	c3                   	ret    

008020c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020c0:	f3 0f 1e fb          	endbr32 
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	57                   	push   %edi
  8020c8:	56                   	push   %esi
  8020c9:	53                   	push   %ebx
  8020ca:	83 ec 0c             	sub    $0xc,%esp
  8020cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020d6:	eb 1f                	jmp    8020f7 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8020d8:	6a 00                	push   $0x0
  8020da:	68 00 00 c0 ee       	push   $0xeec00000
  8020df:	56                   	push   %esi
  8020e0:	57                   	push   %edi
  8020e1:	e8 cc eb ff ff       	call   800cb2 <sys_ipc_try_send>
  8020e6:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	74 30                	je     80211d <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8020ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020f0:	75 19                	jne    80210b <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8020f2:	e8 a2 ea ff ff       	call   800b99 <sys_yield>
		if (pg != NULL) {
  8020f7:	85 db                	test   %ebx,%ebx
  8020f9:	74 dd                	je     8020d8 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8020fb:	ff 75 14             	pushl  0x14(%ebp)
  8020fe:	53                   	push   %ebx
  8020ff:	56                   	push   %esi
  802100:	57                   	push   %edi
  802101:	e8 ac eb ff ff       	call   800cb2 <sys_ipc_try_send>
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	eb de                	jmp    8020e9 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  80210b:	50                   	push   %eax
  80210c:	68 69 29 80 00       	push   $0x802969
  802111:	6a 3e                	push   $0x3e
  802113:	68 76 29 80 00       	push   $0x802976
  802118:	e8 ce df ff ff       	call   8000eb <_panic>
	}
}
  80211d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802125:	f3 0f 1e fb          	endbr32 
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80212f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802134:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802137:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80213d:	8b 52 50             	mov    0x50(%edx),%edx
  802140:	39 ca                	cmp    %ecx,%edx
  802142:	74 11                	je     802155 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802144:	83 c0 01             	add    $0x1,%eax
  802147:	3d 00 04 00 00       	cmp    $0x400,%eax
  80214c:	75 e6                	jne    802134 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80214e:	b8 00 00 00 00       	mov    $0x0,%eax
  802153:	eb 0b                	jmp    802160 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802155:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80215d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802162:	f3 0f 1e fb          	endbr32 
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216c:	89 c2                	mov    %eax,%edx
  80216e:	c1 ea 16             	shr    $0x16,%edx
  802171:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802178:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80217d:	f6 c1 01             	test   $0x1,%cl
  802180:	74 1c                	je     80219e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802182:	c1 e8 0c             	shr    $0xc,%eax
  802185:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80218c:	a8 01                	test   $0x1,%al
  80218e:	74 0e                	je     80219e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802190:	c1 e8 0c             	shr    $0xc,%eax
  802193:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80219a:	ef 
  80219b:	0f b7 d2             	movzwl %dx,%edx
}
  80219e:	89 d0                	mov    %edx,%eax
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__udivdi3>:
  8021b0:	f3 0f 1e fb          	endbr32 
  8021b4:	55                   	push   %ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 1c             	sub    $0x1c,%esp
  8021bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021cb:	85 d2                	test   %edx,%edx
  8021cd:	75 19                	jne    8021e8 <__udivdi3+0x38>
  8021cf:	39 f3                	cmp    %esi,%ebx
  8021d1:	76 4d                	jbe    802220 <__udivdi3+0x70>
  8021d3:	31 ff                	xor    %edi,%edi
  8021d5:	89 e8                	mov    %ebp,%eax
  8021d7:	89 f2                	mov    %esi,%edx
  8021d9:	f7 f3                	div    %ebx
  8021db:	89 fa                	mov    %edi,%edx
  8021dd:	83 c4 1c             	add    $0x1c,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	76 14                	jbe    802200 <__udivdi3+0x50>
  8021ec:	31 ff                	xor    %edi,%edi
  8021ee:	31 c0                	xor    %eax,%eax
  8021f0:	89 fa                	mov    %edi,%edx
  8021f2:	83 c4 1c             	add    $0x1c,%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
  8021fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802200:	0f bd fa             	bsr    %edx,%edi
  802203:	83 f7 1f             	xor    $0x1f,%edi
  802206:	75 48                	jne    802250 <__udivdi3+0xa0>
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	72 06                	jb     802212 <__udivdi3+0x62>
  80220c:	31 c0                	xor    %eax,%eax
  80220e:	39 eb                	cmp    %ebp,%ebx
  802210:	77 de                	ja     8021f0 <__udivdi3+0x40>
  802212:	b8 01 00 00 00       	mov    $0x1,%eax
  802217:	eb d7                	jmp    8021f0 <__udivdi3+0x40>
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d9                	mov    %ebx,%ecx
  802222:	85 db                	test   %ebx,%ebx
  802224:	75 0b                	jne    802231 <__udivdi3+0x81>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f3                	div    %ebx
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	31 d2                	xor    %edx,%edx
  802233:	89 f0                	mov    %esi,%eax
  802235:	f7 f1                	div    %ecx
  802237:	89 c6                	mov    %eax,%esi
  802239:	89 e8                	mov    %ebp,%eax
  80223b:	89 f7                	mov    %esi,%edi
  80223d:	f7 f1                	div    %ecx
  80223f:	89 fa                	mov    %edi,%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 f9                	mov    %edi,%ecx
  802252:	b8 20 00 00 00       	mov    $0x20,%eax
  802257:	29 f8                	sub    %edi,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	89 da                	mov    %ebx,%edx
  802263:	d3 ea                	shr    %cl,%edx
  802265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802269:	09 d1                	or     %edx,%ecx
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e3                	shl    %cl,%ebx
  802275:	89 c1                	mov    %eax,%ecx
  802277:	d3 ea                	shr    %cl,%edx
  802279:	89 f9                	mov    %edi,%ecx
  80227b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80227f:	89 eb                	mov    %ebp,%ebx
  802281:	d3 e6                	shl    %cl,%esi
  802283:	89 c1                	mov    %eax,%ecx
  802285:	d3 eb                	shr    %cl,%ebx
  802287:	09 de                	or     %ebx,%esi
  802289:	89 f0                	mov    %esi,%eax
  80228b:	f7 74 24 08          	divl   0x8(%esp)
  80228f:	89 d6                	mov    %edx,%esi
  802291:	89 c3                	mov    %eax,%ebx
  802293:	f7 64 24 0c          	mull   0xc(%esp)
  802297:	39 d6                	cmp    %edx,%esi
  802299:	72 15                	jb     8022b0 <__udivdi3+0x100>
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	d3 e5                	shl    %cl,%ebp
  80229f:	39 c5                	cmp    %eax,%ebp
  8022a1:	73 04                	jae    8022a7 <__udivdi3+0xf7>
  8022a3:	39 d6                	cmp    %edx,%esi
  8022a5:	74 09                	je     8022b0 <__udivdi3+0x100>
  8022a7:	89 d8                	mov    %ebx,%eax
  8022a9:	31 ff                	xor    %edi,%edi
  8022ab:	e9 40 ff ff ff       	jmp    8021f0 <__udivdi3+0x40>
  8022b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022b3:	31 ff                	xor    %edi,%edi
  8022b5:	e9 36 ff ff ff       	jmp    8021f0 <__udivdi3+0x40>
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__umoddi3>:
  8022c0:	f3 0f 1e fb          	endbr32 
  8022c4:	55                   	push   %ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	83 ec 1c             	sub    $0x1c,%esp
  8022cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022db:	85 c0                	test   %eax,%eax
  8022dd:	75 19                	jne    8022f8 <__umoddi3+0x38>
  8022df:	39 df                	cmp    %ebx,%edi
  8022e1:	76 5d                	jbe    802340 <__umoddi3+0x80>
  8022e3:	89 f0                	mov    %esi,%eax
  8022e5:	89 da                	mov    %ebx,%edx
  8022e7:	f7 f7                	div    %edi
  8022e9:	89 d0                	mov    %edx,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	83 c4 1c             	add    $0x1c,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	39 d8                	cmp    %ebx,%eax
  8022fc:	76 12                	jbe    802310 <__umoddi3+0x50>
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	89 da                	mov    %ebx,%edx
  802302:	83 c4 1c             	add    $0x1c,%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5f                   	pop    %edi
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    
  80230a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802310:	0f bd e8             	bsr    %eax,%ebp
  802313:	83 f5 1f             	xor    $0x1f,%ebp
  802316:	75 50                	jne    802368 <__umoddi3+0xa8>
  802318:	39 d8                	cmp    %ebx,%eax
  80231a:	0f 82 e0 00 00 00    	jb     802400 <__umoddi3+0x140>
  802320:	89 d9                	mov    %ebx,%ecx
  802322:	39 f7                	cmp    %esi,%edi
  802324:	0f 86 d6 00 00 00    	jbe    802400 <__umoddi3+0x140>
  80232a:	89 d0                	mov    %edx,%eax
  80232c:	89 ca                	mov    %ecx,%edx
  80232e:	83 c4 1c             	add    $0x1c,%esp
  802331:	5b                   	pop    %ebx
  802332:	5e                   	pop    %esi
  802333:	5f                   	pop    %edi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    
  802336:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	89 fd                	mov    %edi,%ebp
  802342:	85 ff                	test   %edi,%edi
  802344:	75 0b                	jne    802351 <__umoddi3+0x91>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f7                	div    %edi
  80234f:	89 c5                	mov    %eax,%ebp
  802351:	89 d8                	mov    %ebx,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f5                	div    %ebp
  802357:	89 f0                	mov    %esi,%eax
  802359:	f7 f5                	div    %ebp
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	31 d2                	xor    %edx,%edx
  80235f:	eb 8c                	jmp    8022ed <__umoddi3+0x2d>
  802361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	ba 20 00 00 00       	mov    $0x20,%edx
  80236f:	29 ea                	sub    %ebp,%edx
  802371:	d3 e0                	shl    %cl,%eax
  802373:	89 44 24 08          	mov    %eax,0x8(%esp)
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 f8                	mov    %edi,%eax
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802381:	89 54 24 04          	mov    %edx,0x4(%esp)
  802385:	8b 54 24 04          	mov    0x4(%esp),%edx
  802389:	09 c1                	or     %eax,%ecx
  80238b:	89 d8                	mov    %ebx,%eax
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 e9                	mov    %ebp,%ecx
  802393:	d3 e7                	shl    %cl,%edi
  802395:	89 d1                	mov    %edx,%ecx
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80239f:	d3 e3                	shl    %cl,%ebx
  8023a1:	89 c7                	mov    %eax,%edi
  8023a3:	89 d1                	mov    %edx,%ecx
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	89 fa                	mov    %edi,%edx
  8023ad:	d3 e6                	shl    %cl,%esi
  8023af:	09 d8                	or     %ebx,%eax
  8023b1:	f7 74 24 08          	divl   0x8(%esp)
  8023b5:	89 d1                	mov    %edx,%ecx
  8023b7:	89 f3                	mov    %esi,%ebx
  8023b9:	f7 64 24 0c          	mull   0xc(%esp)
  8023bd:	89 c6                	mov    %eax,%esi
  8023bf:	89 d7                	mov    %edx,%edi
  8023c1:	39 d1                	cmp    %edx,%ecx
  8023c3:	72 06                	jb     8023cb <__umoddi3+0x10b>
  8023c5:	75 10                	jne    8023d7 <__umoddi3+0x117>
  8023c7:	39 c3                	cmp    %eax,%ebx
  8023c9:	73 0c                	jae    8023d7 <__umoddi3+0x117>
  8023cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023d3:	89 d7                	mov    %edx,%edi
  8023d5:	89 c6                	mov    %eax,%esi
  8023d7:	89 ca                	mov    %ecx,%edx
  8023d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023de:	29 f3                	sub    %esi,%ebx
  8023e0:	19 fa                	sbb    %edi,%edx
  8023e2:	89 d0                	mov    %edx,%eax
  8023e4:	d3 e0                	shl    %cl,%eax
  8023e6:	89 e9                	mov    %ebp,%ecx
  8023e8:	d3 eb                	shr    %cl,%ebx
  8023ea:	d3 ea                	shr    %cl,%edx
  8023ec:	09 d8                	or     %ebx,%eax
  8023ee:	83 c4 1c             	add    $0x1c,%esp
  8023f1:	5b                   	pop    %ebx
  8023f2:	5e                   	pop    %esi
  8023f3:	5f                   	pop    %edi
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    
  8023f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	29 fe                	sub    %edi,%esi
  802402:	19 c3                	sbb    %eax,%ebx
  802404:	89 f2                	mov    %esi,%edx
  802406:	89 d9                	mov    %ebx,%ecx
  802408:	e9 1d ff ff ff       	jmp    80232a <__umoddi3+0x6a>
