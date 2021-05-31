
obj/user/faultreadkernel.debug:     formato del fichero elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003d:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800043:	68 e0 1d 80 00       	push   $0x801de0
  800048:	e8 0e 01 00 00       	call   80015b <cprintf>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800061:	e8 94 0a 00 00       	call   800afa <sys_getenvid>
	if (id >= 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	78 12                	js     80007c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800077:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 db                	test   %ebx,%ebx
  80007e:	7e 07                	jle    800087 <libmain+0x35>
		binaryname = argv[0];
  800080:	8b 06                	mov    (%esi),%eax
  800082:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	e8 a2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5e                   	pop    %esi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	f3 0f 1e fb          	endbr32 
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 ce 0d 00 00       	call   800e7d <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 1b 0a 00 00       	call   800ad4 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	f3 0f 1e fb          	endbr32 
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	53                   	push   %ebx
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cc:	8b 13                	mov    (%ebx),%edx
  8000ce:	8d 42 01             	lea    0x1(%edx),%eax
  8000d1:	89 03                	mov    %eax,(%ebx)
  8000d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	74 09                	je     8000ea <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000ea:	83 ec 08             	sub    $0x8,%esp
  8000ed:	68 ff 00 00 00       	push   $0xff
  8000f2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	e8 87 09 00 00       	call   800a82 <sys_cputs>
		b->idx = 0;
  8000fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	eb db                	jmp    8000e1 <putch+0x23>

00800106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800106:	f3 0f 1e fb          	endbr32 
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011a:	00 00 00 
	b.cnt = 0;
  80011d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800127:	ff 75 0c             	pushl  0xc(%ebp)
  80012a:	ff 75 08             	pushl  0x8(%ebp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	68 be 00 80 00       	push   $0x8000be
  800139:	e8 80 01 00 00       	call   8002be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013e:	83 c4 08             	add    $0x8,%esp
  800141:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	e8 2f 09 00 00       	call   800a82 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	f3 0f 1e fb          	endbr32 
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800165:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800168:	50                   	push   %eax
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	e8 95 ff ff ff       	call   800106 <vcprintf>
	va_end(ap);

	return cnt;
}
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 1c             	sub    $0x1c,%esp
  80017c:	89 c7                	mov    %eax,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	8b 45 08             	mov    0x8(%ebp),%eax
  800183:	8b 55 0c             	mov    0xc(%ebp),%edx
  800186:	89 d1                	mov    %edx,%ecx
  800188:	89 c2                	mov    %eax,%edx
  80018a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800196:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800199:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a0:	39 c2                	cmp    %eax,%edx
  8001a2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001a5:	72 3e                	jb     8001e5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 18             	pushl  0x18(%ebp)
  8001ad:	83 eb 01             	sub    $0x1,%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	50                   	push   %eax
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001be:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c1:	e8 aa 19 00 00       	call   801b70 <__udivdi3>
  8001c6:	83 c4 18             	add    $0x18,%esp
  8001c9:	52                   	push   %edx
  8001ca:	50                   	push   %eax
  8001cb:	89 f2                	mov    %esi,%edx
  8001cd:	89 f8                	mov    %edi,%eax
  8001cf:	e8 9f ff ff ff       	call   800173 <printnum>
  8001d4:	83 c4 20             	add    $0x20,%esp
  8001d7:	eb 13                	jmp    8001ec <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	ff d7                	call   *%edi
  8001e2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e5:	83 eb 01             	sub    $0x1,%ebx
  8001e8:	85 db                	test   %ebx,%ebx
  8001ea:	7f ed                	jg     8001d9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	56                   	push   %esi
  8001f0:	83 ec 04             	sub    $0x4,%esp
  8001f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ff:	e8 7c 1a 00 00       	call   801c80 <__umoddi3>
  800204:	83 c4 14             	add    $0x14,%esp
  800207:	0f be 80 11 1e 80 00 	movsbl 0x801e11(%eax),%eax
  80020e:	50                   	push   %eax
  80020f:	ff d7                	call   *%edi
}
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80021c:	83 fa 01             	cmp    $0x1,%edx
  80021f:	7f 13                	jg     800234 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800221:	85 d2                	test   %edx,%edx
  800223:	74 1c                	je     800241 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800225:	8b 10                	mov    (%eax),%edx
  800227:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022a:	89 08                	mov    %ecx,(%eax)
  80022c:	8b 02                	mov    (%edx),%eax
  80022e:	ba 00 00 00 00       	mov    $0x0,%edx
  800233:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800234:	8b 10                	mov    (%eax),%edx
  800236:	8d 4a 08             	lea    0x8(%edx),%ecx
  800239:	89 08                	mov    %ecx,(%eax)
  80023b:	8b 02                	mov    (%edx),%eax
  80023d:	8b 52 04             	mov    0x4(%edx),%edx
  800240:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800241:	8b 10                	mov    (%eax),%edx
  800243:	8d 4a 04             	lea    0x4(%edx),%ecx
  800246:	89 08                	mov    %ecx,(%eax)
  800248:	8b 02                	mov    (%edx),%eax
  80024a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024f:	c3                   	ret    

00800250 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800250:	83 fa 01             	cmp    $0x1,%edx
  800253:	7f 0f                	jg     800264 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800255:	85 d2                	test   %edx,%edx
  800257:	74 18                	je     800271 <getint+0x21>
		return va_arg(*ap, long);
  800259:	8b 10                	mov    (%eax),%edx
  80025b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 02                	mov    (%edx),%eax
  800262:	99                   	cltd   
  800263:	c3                   	ret    
		return va_arg(*ap, long long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 08             	lea    0x8(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	8b 52 04             	mov    0x4(%edx),%edx
  800270:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	99                   	cltd   
}
  80027b:	c3                   	ret    

0080027c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027c:	f3 0f 1e fb          	endbr32 
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800286:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	3b 50 04             	cmp    0x4(%eax),%edx
  80028f:	73 0a                	jae    80029b <sprintputch+0x1f>
		*b->buf++ = ch;
  800291:	8d 4a 01             	lea    0x1(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	88 02                	mov    %al,(%edx)
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <printfmt>:
{
  80029d:	f3 0f 1e fb          	endbr32 
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 10             	pushl  0x10(%ebp)
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	e8 05 00 00 00       	call   8002be <vprintfmt>
}
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vprintfmt>:
{
  8002be:	f3 0f 1e fb          	endbr32 
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 2c             	sub    $0x2c,%esp
  8002cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d4:	e9 86 02 00 00       	jmp    80055f <vprintfmt+0x2a1>
		padc = ' ';
  8002d9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002dd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002eb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8d 47 01             	lea    0x1(%edi),%eax
  8002fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fd:	0f b6 17             	movzbl (%edi),%edx
  800300:	8d 42 dd             	lea    -0x23(%edx),%eax
  800303:	3c 55                	cmp    $0x55,%al
  800305:	0f 87 df 02 00 00    	ja     8005ea <vprintfmt+0x32c>
  80030b:	0f b6 c0             	movzbl %al,%eax
  80030e:	3e ff 24 85 60 1f 80 	notrack jmp *0x801f60(,%eax,4)
  800315:	00 
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800319:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80031d:	eb d8                	jmp    8002f7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800322:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800326:	eb cf                	jmp    8002f7 <vprintfmt+0x39>
  800328:	0f b6 d2             	movzbl %dl,%edx
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032e:	b8 00 00 00 00       	mov    $0x0,%eax
  800333:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800336:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800339:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800340:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800343:	83 f9 09             	cmp    $0x9,%ecx
  800346:	77 52                	ja     80039a <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800348:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80034b:	eb e9                	jmp    800336 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80034d:	8b 45 14             	mov    0x14(%ebp),%eax
  800350:	8d 50 04             	lea    0x4(%eax),%edx
  800353:	89 55 14             	mov    %edx,0x14(%ebp)
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800362:	79 93                	jns    8002f7 <vprintfmt+0x39>
				width = precision, precision = -1;
  800364:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800371:	eb 84                	jmp    8002f7 <vprintfmt+0x39>
  800373:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800376:	85 c0                	test   %eax,%eax
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	0f 49 d0             	cmovns %eax,%edx
  800380:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800386:	e9 6c ff ff ff       	jmp    8002f7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800395:	e9 5d ff ff ff       	jmp    8002f7 <vprintfmt+0x39>
  80039a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a0:	eb bc                	jmp    80035e <vprintfmt+0xa0>
			lflag++;
  8003a2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a8:	e9 4a ff ff ff       	jmp    8002f7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	56                   	push   %esi
  8003ba:	ff 30                	pushl  (%eax)
  8003bc:	ff d3                	call   *%ebx
			break;
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	e9 96 01 00 00       	jmp    80055c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 50 04             	lea    0x4(%eax),%edx
  8003cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	99                   	cltd   
  8003d2:	31 d0                	xor    %edx,%eax
  8003d4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d6:	83 f8 0f             	cmp    $0xf,%eax
  8003d9:	7f 20                	jg     8003fb <vprintfmt+0x13d>
  8003db:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003e2:	85 d2                	test   %edx,%edx
  8003e4:	74 15                	je     8003fb <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8003e6:	52                   	push   %edx
  8003e7:	68 f1 21 80 00       	push   $0x8021f1
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	e8 aa fe ff ff       	call   80029d <printfmt>
  8003f3:	83 c4 10             	add    $0x10,%esp
  8003f6:	e9 61 01 00 00       	jmp    80055c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8003fb:	50                   	push   %eax
  8003fc:	68 29 1e 80 00       	push   $0x801e29
  800401:	56                   	push   %esi
  800402:	53                   	push   %ebx
  800403:	e8 95 fe ff ff       	call   80029d <printfmt>
  800408:	83 c4 10             	add    $0x10,%esp
  80040b:	e9 4c 01 00 00       	jmp    80055c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80041b:	85 c9                	test   %ecx,%ecx
  80041d:	b8 22 1e 80 00       	mov    $0x801e22,%eax
  800422:	0f 45 c1             	cmovne %ecx,%eax
  800425:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	7e 06                	jle    800434 <vprintfmt+0x176>
  80042e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800432:	75 0d                	jne    800441 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800434:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800437:	89 c7                	mov    %eax,%edi
  800439:	03 45 e0             	add    -0x20(%ebp),%eax
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043f:	eb 57                	jmp    800498 <vprintfmt+0x1da>
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	ff 75 d8             	pushl  -0x28(%ebp)
  800447:	ff 75 cc             	pushl  -0x34(%ebp)
  80044a:	e8 4f 02 00 00       	call   80069e <strnlen>
  80044f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800452:	29 c2                	sub    %eax,%edx
  800454:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800457:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80045e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800461:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	85 db                	test   %ebx,%ebx
  800465:	7e 10                	jle    800477 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	57                   	push   %edi
  80046c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	83 eb 01             	sub    $0x1,%ebx
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb ec                	jmp    800463 <vprintfmt+0x1a5>
  800477:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80047a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80047d:	85 d2                	test   %edx,%edx
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	0f 49 c2             	cmovns %edx,%eax
  800487:	29 c2                	sub    %eax,%edx
  800489:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048c:	eb a6                	jmp    800434 <vprintfmt+0x176>
					putch(ch, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	56                   	push   %esi
  800492:	52                   	push   %edx
  800493:	ff d3                	call   *%ebx
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049d:	83 c7 01             	add    $0x1,%edi
  8004a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a4:	0f be d0             	movsbl %al,%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	74 42                	je     8004ed <vprintfmt+0x22f>
  8004ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004af:	78 06                	js     8004b7 <vprintfmt+0x1f9>
  8004b1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b5:	78 1e                	js     8004d5 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bb:	74 d1                	je     80048e <vprintfmt+0x1d0>
  8004bd:	0f be c0             	movsbl %al,%eax
  8004c0:	83 e8 20             	sub    $0x20,%eax
  8004c3:	83 f8 5e             	cmp    $0x5e,%eax
  8004c6:	76 c6                	jbe    80048e <vprintfmt+0x1d0>
					putch('?', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	56                   	push   %esi
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff d3                	call   *%ebx
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	eb c3                	jmp    800498 <vprintfmt+0x1da>
  8004d5:	89 cf                	mov    %ecx,%edi
  8004d7:	eb 0e                	jmp    8004e7 <vprintfmt+0x229>
				putch(' ', putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	56                   	push   %esi
  8004dd:	6a 20                	push   $0x20
  8004df:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004e1:	83 ef 01             	sub    $0x1,%edi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	7f ee                	jg     8004d9 <vprintfmt+0x21b>
  8004eb:	eb 6f                	jmp    80055c <vprintfmt+0x29e>
  8004ed:	89 cf                	mov    %ecx,%edi
  8004ef:	eb f6                	jmp    8004e7 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8004f1:	89 ca                	mov    %ecx,%edx
  8004f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f6:	e8 55 fd ff ff       	call   800250 <getint>
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800501:	85 d2                	test   %edx,%edx
  800503:	78 0b                	js     800510 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800505:	89 d1                	mov    %edx,%ecx
  800507:	89 c2                	mov    %eax,%edx
			base = 10;
  800509:	b8 0a 00 00 00       	mov    $0xa,%eax
  80050e:	eb 32                	jmp    800542 <vprintfmt+0x284>
				putch('-', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 2d                	push   $0x2d
  800516:	ff d3                	call   *%ebx
				num = -(long long) num;
  800518:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051e:	f7 da                	neg    %edx
  800520:	83 d1 00             	adc    $0x0,%ecx
  800523:	f7 d9                	neg    %ecx
  800525:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800528:	b8 0a 00 00 00       	mov    $0xa,%eax
  80052d:	eb 13                	jmp    800542 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80052f:	89 ca                	mov    %ecx,%edx
  800531:	8d 45 14             	lea    0x14(%ebp),%eax
  800534:	e8 e3 fc ff ff       	call   80021c <getuint>
  800539:	89 d1                	mov    %edx,%ecx
  80053b:	89 c2                	mov    %eax,%edx
			base = 10;
  80053d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800542:	83 ec 0c             	sub    $0xc,%esp
  800545:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800549:	57                   	push   %edi
  80054a:	ff 75 e0             	pushl  -0x20(%ebp)
  80054d:	50                   	push   %eax
  80054e:	51                   	push   %ecx
  80054f:	52                   	push   %edx
  800550:	89 f2                	mov    %esi,%edx
  800552:	89 d8                	mov    %ebx,%eax
  800554:	e8 1a fc ff ff       	call   800173 <printnum>
			break;
  800559:	83 c4 20             	add    $0x20,%esp
{
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055f:	83 c7 01             	add    $0x1,%edi
  800562:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800566:	83 f8 25             	cmp    $0x25,%eax
  800569:	0f 84 6a fd ff ff    	je     8002d9 <vprintfmt+0x1b>
			if (ch == '\0')
  80056f:	85 c0                	test   %eax,%eax
  800571:	0f 84 93 00 00 00    	je     80060a <vprintfmt+0x34c>
			putch(ch, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	56                   	push   %esi
  80057b:	50                   	push   %eax
  80057c:	ff d3                	call   *%ebx
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb dc                	jmp    80055f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800583:	89 ca                	mov    %ecx,%edx
  800585:	8d 45 14             	lea    0x14(%ebp),%eax
  800588:	e8 8f fc ff ff       	call   80021c <getuint>
  80058d:	89 d1                	mov    %edx,%ecx
  80058f:	89 c2                	mov    %eax,%edx
			base = 8;
  800591:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800596:	eb aa                	jmp    800542 <vprintfmt+0x284>
			putch('0', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	56                   	push   %esi
  80059c:	6a 30                	push   $0x30
  80059e:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	56                   	push   %esi
  8005a4:	6a 78                	push   $0x78
  8005a6:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005b8:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005bb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005c0:	eb 80                	jmp    800542 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005c2:	89 ca                	mov    %ecx,%edx
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 50 fc ff ff       	call   80021c <getuint>
  8005cc:	89 d1                	mov    %edx,%ecx
  8005ce:	89 c2                	mov    %eax,%edx
			base = 16;
  8005d0:	b8 10 00 00 00       	mov    $0x10,%eax
  8005d5:	e9 68 ff ff ff       	jmp    800542 <vprintfmt+0x284>
			putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	56                   	push   %esi
  8005de:	6a 25                	push   $0x25
  8005e0:	ff d3                	call   *%ebx
			break;
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	e9 72 ff ff ff       	jmp    80055c <vprintfmt+0x29e>
			putch('%', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	56                   	push   %esi
  8005ee:	6a 25                	push   $0x25
  8005f0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	89 f8                	mov    %edi,%eax
  8005f7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005fb:	74 05                	je     800602 <vprintfmt+0x344>
  8005fd:	83 e8 01             	sub    $0x1,%eax
  800600:	eb f5                	jmp    8005f7 <vprintfmt+0x339>
  800602:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800605:	e9 52 ff ff ff       	jmp    80055c <vprintfmt+0x29e>
}
  80060a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80060d:	5b                   	pop    %ebx
  80060e:	5e                   	pop    %esi
  80060f:	5f                   	pop    %edi
  800610:	5d                   	pop    %ebp
  800611:	c3                   	ret    

00800612 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800612:	f3 0f 1e fb          	endbr32 
  800616:	55                   	push   %ebp
  800617:	89 e5                	mov    %esp,%ebp
  800619:	83 ec 18             	sub    $0x18,%esp
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800622:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800625:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800629:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80062c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800633:	85 c0                	test   %eax,%eax
  800635:	74 26                	je     80065d <vsnprintf+0x4b>
  800637:	85 d2                	test   %edx,%edx
  800639:	7e 22                	jle    80065d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80063b:	ff 75 14             	pushl  0x14(%ebp)
  80063e:	ff 75 10             	pushl  0x10(%ebp)
  800641:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	68 7c 02 80 00       	push   $0x80027c
  80064a:	e8 6f fc ff ff       	call   8002be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80064f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800652:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800658:	83 c4 10             	add    $0x10,%esp
}
  80065b:	c9                   	leave  
  80065c:	c3                   	ret    
		return -E_INVAL;
  80065d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800662:	eb f7                	jmp    80065b <vsnprintf+0x49>

00800664 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800664:	f3 0f 1e fb          	endbr32 
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800671:	50                   	push   %eax
  800672:	ff 75 10             	pushl  0x10(%ebp)
  800675:	ff 75 0c             	pushl  0xc(%ebp)
  800678:	ff 75 08             	pushl  0x8(%ebp)
  80067b:	e8 92 ff ff ff       	call   800612 <vsnprintf>
	va_end(ap);

	return rc;
}
  800680:	c9                   	leave  
  800681:	c3                   	ret    

00800682 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800682:	f3 0f 1e fb          	endbr32 
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80068c:	b8 00 00 00 00       	mov    $0x0,%eax
  800691:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800695:	74 05                	je     80069c <strlen+0x1a>
		n++;
  800697:	83 c0 01             	add    $0x1,%eax
  80069a:	eb f5                	jmp    800691 <strlen+0xf>
	return n;
}
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80069e:	f3 0f 1e fb          	endbr32 
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b0:	39 d0                	cmp    %edx,%eax
  8006b2:	74 0d                	je     8006c1 <strnlen+0x23>
  8006b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006b8:	74 05                	je     8006bf <strnlen+0x21>
		n++;
  8006ba:	83 c0 01             	add    $0x1,%eax
  8006bd:	eb f1                	jmp    8006b0 <strnlen+0x12>
  8006bf:	89 c2                	mov    %eax,%edx
	return n;
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c5:	f3 0f 1e fb          	endbr32 
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	53                   	push   %ebx
  8006cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006dc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006df:	83 c0 01             	add    $0x1,%eax
  8006e2:	84 d2                	test   %dl,%dl
  8006e4:	75 f2                	jne    8006d8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8006e6:	89 c8                	mov    %ecx,%eax
  8006e8:	5b                   	pop    %ebx
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006eb:	f3 0f 1e fb          	endbr32 
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	53                   	push   %ebx
  8006f3:	83 ec 10             	sub    $0x10,%esp
  8006f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f9:	53                   	push   %ebx
  8006fa:	e8 83 ff ff ff       	call   800682 <strlen>
  8006ff:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	01 d8                	add    %ebx,%eax
  800707:	50                   	push   %eax
  800708:	e8 b8 ff ff ff       	call   8006c5 <strcpy>
	return dst;
}
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800714:	f3 0f 1e fb          	endbr32 
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
  800723:	89 f3                	mov    %esi,%ebx
  800725:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800728:	89 f0                	mov    %esi,%eax
  80072a:	39 d8                	cmp    %ebx,%eax
  80072c:	74 11                	je     80073f <strncpy+0x2b>
		*dst++ = *src;
  80072e:	83 c0 01             	add    $0x1,%eax
  800731:	0f b6 0a             	movzbl (%edx),%ecx
  800734:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800737:	80 f9 01             	cmp    $0x1,%cl
  80073a:	83 da ff             	sbb    $0xffffffff,%edx
  80073d:	eb eb                	jmp    80072a <strncpy+0x16>
	}
	return ret;
}
  80073f:	89 f0                	mov    %esi,%eax
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800745:	f3 0f 1e fb          	endbr32 
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	56                   	push   %esi
  80074d:	53                   	push   %ebx
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800754:	8b 55 10             	mov    0x10(%ebp),%edx
  800757:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800759:	85 d2                	test   %edx,%edx
  80075b:	74 21                	je     80077e <strlcpy+0x39>
  80075d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800761:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800763:	39 c2                	cmp    %eax,%edx
  800765:	74 14                	je     80077b <strlcpy+0x36>
  800767:	0f b6 19             	movzbl (%ecx),%ebx
  80076a:	84 db                	test   %bl,%bl
  80076c:	74 0b                	je     800779 <strlcpy+0x34>
			*dst++ = *src++;
  80076e:	83 c1 01             	add    $0x1,%ecx
  800771:	83 c2 01             	add    $0x1,%edx
  800774:	88 5a ff             	mov    %bl,-0x1(%edx)
  800777:	eb ea                	jmp    800763 <strlcpy+0x1e>
  800779:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80077b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077e:	29 f0                	sub    %esi,%eax
}
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800784:	f3 0f 1e fb          	endbr32 
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800791:	0f b6 01             	movzbl (%ecx),%eax
  800794:	84 c0                	test   %al,%al
  800796:	74 0c                	je     8007a4 <strcmp+0x20>
  800798:	3a 02                	cmp    (%edx),%al
  80079a:	75 08                	jne    8007a4 <strcmp+0x20>
		p++, q++;
  80079c:	83 c1 01             	add    $0x1,%ecx
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	eb ed                	jmp    800791 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a4:	0f b6 c0             	movzbl %al,%eax
  8007a7:	0f b6 12             	movzbl (%edx),%edx
  8007aa:	29 d0                	sub    %edx,%eax
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ae:	f3 0f 1e fb          	endbr32 
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 c3                	mov    %eax,%ebx
  8007be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c1:	eb 06                	jmp    8007c9 <strncmp+0x1b>
		n--, p++, q++;
  8007c3:	83 c0 01             	add    $0x1,%eax
  8007c6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007c9:	39 d8                	cmp    %ebx,%eax
  8007cb:	74 16                	je     8007e3 <strncmp+0x35>
  8007cd:	0f b6 08             	movzbl (%eax),%ecx
  8007d0:	84 c9                	test   %cl,%cl
  8007d2:	74 04                	je     8007d8 <strncmp+0x2a>
  8007d4:	3a 0a                	cmp    (%edx),%cl
  8007d6:	74 eb                	je     8007c3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 00             	movzbl (%eax),%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    
		return 0;
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e8:	eb f6                	jmp    8007e0 <strncmp+0x32>

008007ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ea:	f3 0f 1e fb          	endbr32 
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f8:	0f b6 10             	movzbl (%eax),%edx
  8007fb:	84 d2                	test   %dl,%dl
  8007fd:	74 09                	je     800808 <strchr+0x1e>
		if (*s == c)
  8007ff:	38 ca                	cmp    %cl,%dl
  800801:	74 0a                	je     80080d <strchr+0x23>
	for (; *s; s++)
  800803:	83 c0 01             	add    $0x1,%eax
  800806:	eb f0                	jmp    8007f8 <strchr+0xe>
			return (char *) s;
	return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 09                	je     80082d <strfind+0x1e>
  800824:	84 d2                	test   %dl,%dl
  800826:	74 05                	je     80082d <strfind+0x1e>
	for (; *s; s++)
  800828:	83 c0 01             	add    $0x1,%eax
  80082b:	eb f0                	jmp    80081d <strfind+0xe>
			break;
	return (char *) s;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082f:	f3 0f 1e fb          	endbr32 
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	57                   	push   %edi
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 55 08             	mov    0x8(%ebp),%edx
  80083c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80083f:	85 c9                	test   %ecx,%ecx
  800841:	74 33                	je     800876 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800843:	89 d0                	mov    %edx,%eax
  800845:	09 c8                	or     %ecx,%eax
  800847:	a8 03                	test   $0x3,%al
  800849:	75 23                	jne    80086e <memset+0x3f>
		c &= 0xFF;
  80084b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	c1 e0 08             	shl    $0x8,%eax
  800854:	89 df                	mov    %ebx,%edi
  800856:	c1 e7 18             	shl    $0x18,%edi
  800859:	89 de                	mov    %ebx,%esi
  80085b:	c1 e6 10             	shl    $0x10,%esi
  80085e:	09 f7                	or     %esi,%edi
  800860:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800862:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800865:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800867:	89 d7                	mov    %edx,%edi
  800869:	fc                   	cld    
  80086a:	f3 ab                	rep stos %eax,%es:(%edi)
  80086c:	eb 08                	jmp    800876 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086e:	89 d7                	mov    %edx,%edi
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
  800873:	fc                   	cld    
  800874:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800876:	89 d0                	mov    %edx,%eax
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5f                   	pop    %edi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087d:	f3 0f 1e fb          	endbr32 
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088f:	39 c6                	cmp    %eax,%esi
  800891:	73 32                	jae    8008c5 <memmove+0x48>
  800893:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800896:	39 c2                	cmp    %eax,%edx
  800898:	76 2b                	jbe    8008c5 <memmove+0x48>
		s += n;
		d += n;
  80089a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089d:	89 fe                	mov    %edi,%esi
  80089f:	09 ce                	or     %ecx,%esi
  8008a1:	09 d6                	or     %edx,%esi
  8008a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a9:	75 0e                	jne    8008b9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ab:	83 ef 04             	sub    $0x4,%edi
  8008ae:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008b4:	fd                   	std    
  8008b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b7:	eb 09                	jmp    8008c2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008b9:	83 ef 01             	sub    $0x1,%edi
  8008bc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008bf:	fd                   	std    
  8008c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c2:	fc                   	cld    
  8008c3:	eb 1a                	jmp    8008df <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	09 ca                	or     %ecx,%edx
  8008c9:	09 f2                	or     %esi,%edx
  8008cb:	f6 c2 03             	test   $0x3,%dl
  8008ce:	75 0a                	jne    8008da <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008d0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008d3:	89 c7                	mov    %eax,%edi
  8008d5:	fc                   	cld    
  8008d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d8:	eb 05                	jmp    8008df <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	fc                   	cld    
  8008dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008df:	5e                   	pop    %esi
  8008e0:	5f                   	pop    %edi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e3:	f3 0f 1e fb          	endbr32 
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 82 ff ff ff       	call   80087d <memmove>
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c6                	mov    %eax,%esi
  80090e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800911:	39 f0                	cmp    %esi,%eax
  800913:	74 1c                	je     800931 <memcmp+0x34>
		if (*s1 != *s2)
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	0f b6 1a             	movzbl (%edx),%ebx
  80091b:	38 d9                	cmp    %bl,%cl
  80091d:	75 08                	jne    800927 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	83 c2 01             	add    $0x1,%edx
  800925:	eb ea                	jmp    800911 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800927:	0f b6 c1             	movzbl %cl,%eax
  80092a:	0f b6 db             	movzbl %bl,%ebx
  80092d:	29 d8                	sub    %ebx,%eax
  80092f:	eb 05                	jmp    800936 <memcmp+0x39>
	}

	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093a:	f3 0f 1e fb          	endbr32 
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800947:	89 c2                	mov    %eax,%edx
  800949:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094c:	39 d0                	cmp    %edx,%eax
  80094e:	73 09                	jae    800959 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	38 08                	cmp    %cl,(%eax)
  800952:	74 05                	je     800959 <memfind+0x1f>
	for (; s < ends; s++)
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	eb f3                	jmp    80094c <memfind+0x12>
			break;
	return (void *) s;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095b:	f3 0f 1e fb          	endbr32 
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096b:	eb 03                	jmp    800970 <strtol+0x15>
		s++;
  80096d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800970:	0f b6 01             	movzbl (%ecx),%eax
  800973:	3c 20                	cmp    $0x20,%al
  800975:	74 f6                	je     80096d <strtol+0x12>
  800977:	3c 09                	cmp    $0x9,%al
  800979:	74 f2                	je     80096d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80097b:	3c 2b                	cmp    $0x2b,%al
  80097d:	74 2a                	je     8009a9 <strtol+0x4e>
	int neg = 0;
  80097f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800984:	3c 2d                	cmp    $0x2d,%al
  800986:	74 2b                	je     8009b3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800988:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80098e:	75 0f                	jne    80099f <strtol+0x44>
  800990:	80 39 30             	cmpb   $0x30,(%ecx)
  800993:	74 28                	je     8009bd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800995:	85 db                	test   %ebx,%ebx
  800997:	b8 0a 00 00 00       	mov    $0xa,%eax
  80099c:	0f 44 d8             	cmove  %eax,%ebx
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009a7:	eb 46                	jmp    8009ef <strtol+0x94>
		s++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b1:	eb d5                	jmp    800988 <strtol+0x2d>
		s++, neg = 1;
  8009b3:	83 c1 01             	add    $0x1,%ecx
  8009b6:	bf 01 00 00 00       	mov    $0x1,%edi
  8009bb:	eb cb                	jmp    800988 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c1:	74 0e                	je     8009d1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	75 d8                	jne    80099f <strtol+0x44>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009cf:	eb ce                	jmp    80099f <strtol+0x44>
		s += 2, base = 16;
  8009d1:	83 c1 02             	add    $0x2,%ecx
  8009d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d9:	eb c4                	jmp    80099f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009db:	0f be d2             	movsbl %dl,%edx
  8009de:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009e1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e4:	7d 3a                	jge    800a20 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009ed:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009ef:	0f b6 11             	movzbl (%ecx),%edx
  8009f2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f5:	89 f3                	mov    %esi,%ebx
  8009f7:	80 fb 09             	cmp    $0x9,%bl
  8009fa:	76 df                	jbe    8009db <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8009fc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 08                	ja     800a0e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 57             	sub    $0x57,%edx
  800a0c:	eb d3                	jmp    8009e1 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 19             	cmp    $0x19,%bl
  800a16:	77 08                	ja     800a20 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 37             	sub    $0x37,%edx
  800a1e:	eb c1                	jmp    8009e1 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a24:	74 05                	je     800a2b <strtol+0xd0>
		*endptr = (char *) s;
  800a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a2b:	89 c2                	mov    %eax,%edx
  800a2d:	f7 da                	neg    %edx
  800a2f:	85 ff                	test   %edi,%edi
  800a31:	0f 45 c2             	cmovne %edx,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	83 ec 1c             	sub    $0x1c,%esp
  800a42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a48:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a50:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a53:	8b 75 14             	mov    0x14(%ebp),%esi
  800a56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a58:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a5c:	74 04                	je     800a62 <syscall+0x29>
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	7f 08                	jg     800a6a <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6a:	83 ec 0c             	sub    $0xc,%esp
  800a6d:	50                   	push   %eax
  800a6e:	ff 75 e0             	pushl  -0x20(%ebp)
  800a71:	68 1f 21 80 00       	push   $0x80211f
  800a76:	6a 23                	push   $0x23
  800a78:	68 3c 21 80 00       	push   $0x80213c
  800a7d:	e8 51 0f 00 00       	call   8019d3 <_panic>

00800a82 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a82:	f3 0f 1e fb          	endbr32 
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	6a 00                	push   $0x0
  800a92:	ff 75 0c             	pushl  0xc(%ebp)
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	e8 92 ff ff ff       	call   800a39 <syscall>
}
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <sys_cgetc>:

int
sys_cgetc(void)
{
  800aac:	f3 0f 1e fb          	endbr32 
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ab6:	6a 00                	push   $0x0
  800ab8:	6a 00                	push   $0x0
  800aba:	6a 00                	push   $0x0
  800abc:	6a 00                	push   $0x0
  800abe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 01 00 00 00       	mov    $0x1,%eax
  800acd:	e8 67 ff ff ff       	call   800a39 <syscall>
}
  800ad2:	c9                   	leave  
  800ad3:	c3                   	ret    

00800ad4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad4:	f3 0f 1e fb          	endbr32 
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ade:	6a 00                	push   $0x0
  800ae0:	6a 00                	push   $0x0
  800ae2:	6a 00                	push   $0x0
  800ae4:	6a 00                	push   $0x0
  800ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae9:	ba 01 00 00 00       	mov    $0x1,%edx
  800aee:	b8 03 00 00 00       	mov    $0x3,%eax
  800af3:	e8 41 ff ff ff       	call   800a39 <syscall>
}
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    

00800afa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afa:	f3 0f 1e fb          	endbr32 
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b04:	6a 00                	push   $0x0
  800b06:	6a 00                	push   $0x0
  800b08:	6a 00                	push   $0x0
  800b0a:	6a 00                	push   $0x0
  800b0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1b:	e8 19 ff ff ff       	call   800a39 <syscall>
}
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <sys_yield>:

void
sys_yield(void)
{
  800b22:	f3 0f 1e fb          	endbr32 
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b2c:	6a 00                	push   $0x0
  800b2e:	6a 00                	push   $0x0
  800b30:	6a 00                	push   $0x0
  800b32:	6a 00                	push   $0x0
  800b34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b43:	e8 f1 fe ff ff       	call   800a39 <syscall>
}
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4d:	f3 0f 1e fb          	endbr32 
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	ff 75 10             	pushl  0x10(%ebp)
  800b5e:	ff 75 0c             	pushl  0xc(%ebp)
  800b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b64:	ba 01 00 00 00       	mov    $0x1,%edx
  800b69:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6e:	e8 c6 fe ff ff       	call   800a39 <syscall>
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b75:	f3 0f 1e fb          	endbr32 
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b7f:	ff 75 18             	pushl  0x18(%ebp)
  800b82:	ff 75 14             	pushl  0x14(%ebp)
  800b85:	ff 75 10             	pushl  0x10(%ebp)
  800b88:	ff 75 0c             	pushl  0xc(%ebp)
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	ba 01 00 00 00       	mov    $0x1,%edx
  800b93:	b8 05 00 00 00       	mov    $0x5,%eax
  800b98:	e8 9c fe ff ff       	call   800a39 <syscall>
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9f:	f3 0f 1e fb          	endbr32 
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bba:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbf:	e8 75 fe ff ff       	call   800a39 <syscall>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc6:	f3 0f 1e fb          	endbr32 
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bd0:	6a 00                	push   $0x0
  800bd2:	6a 00                	push   $0x0
  800bd4:	6a 00                	push   $0x0
  800bd6:	ff 75 0c             	pushl  0xc(%ebp)
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800be1:	b8 08 00 00 00       	mov    $0x8,%eax
  800be6:	e8 4e fe ff ff       	call   800a39 <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bed:	f3 0f 1e fb          	endbr32 
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	ff 75 0c             	pushl  0xc(%ebp)
  800c00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c03:	ba 01 00 00 00       	mov    $0x1,%edx
  800c08:	b8 09 00 00 00       	mov    $0x9,%eax
  800c0d:	e8 27 fe ff ff       	call   800a39 <syscall>
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c14:	f3 0f 1e fb          	endbr32 
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c1e:	6a 00                	push   $0x0
  800c20:	6a 00                	push   $0x0
  800c22:	6a 00                	push   $0x0
  800c24:	ff 75 0c             	pushl  0xc(%ebp)
  800c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c34:	e8 00 fe ff ff       	call   800a39 <syscall>
}
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c3b:	f3 0f 1e fb          	endbr32 
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c45:	6a 00                	push   $0x0
  800c47:	ff 75 14             	pushl  0x14(%ebp)
  800c4a:	ff 75 10             	pushl  0x10(%ebp)
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c53:	ba 00 00 00 00       	mov    $0x0,%edx
  800c58:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c5d:	e8 d7 fd ff ff       	call   800a39 <syscall>
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c64:	f3 0f 1e fb          	endbr32 
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c6e:	6a 00                	push   $0x0
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	6a 00                	push   $0x0
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c83:	e8 b1 fd ff ff       	call   800a39 <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800c8a:	f3 0f 1e fb          	endbr32 
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	05 00 00 00 30       	add    $0x30000000,%eax
  800c99:	c1 e8 0c             	shr    $0xc,%eax
}
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800c9e:	f3 0f 1e fb          	endbr32 
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800ca8:	ff 75 08             	pushl  0x8(%ebp)
  800cab:	e8 da ff ff ff       	call   800c8a <fd2num>
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	c1 e0 0c             	shl    $0xc,%eax
  800cb6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cc9:	89 c2                	mov    %eax,%edx
  800ccb:	c1 ea 16             	shr    $0x16,%edx
  800cce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800cd5:	f6 c2 01             	test   $0x1,%dl
  800cd8:	74 2d                	je     800d07 <fd_alloc+0x4a>
  800cda:	89 c2                	mov    %eax,%edx
  800cdc:	c1 ea 0c             	shr    $0xc,%edx
  800cdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ce6:	f6 c2 01             	test   $0x1,%dl
  800ce9:	74 1c                	je     800d07 <fd_alloc+0x4a>
  800ceb:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800cf0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800cf5:	75 d2                	jne    800cc9 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800d00:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800d05:	eb 0a                	jmp    800d11 <fd_alloc+0x54>
			*fd_store = fd;
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d13:	f3 0f 1e fb          	endbr32 
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d1d:	83 f8 1f             	cmp    $0x1f,%eax
  800d20:	77 30                	ja     800d52 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d22:	c1 e0 0c             	shl    $0xc,%eax
  800d25:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d2a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800d30:	f6 c2 01             	test   $0x1,%dl
  800d33:	74 24                	je     800d59 <fd_lookup+0x46>
  800d35:	89 c2                	mov    %eax,%edx
  800d37:	c1 ea 0c             	shr    $0xc,%edx
  800d3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d41:	f6 c2 01             	test   $0x1,%dl
  800d44:	74 1a                	je     800d60 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d49:	89 02                	mov    %eax,(%edx)
	return 0;
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		return -E_INVAL;
  800d52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d57:	eb f7                	jmp    800d50 <fd_lookup+0x3d>
		return -E_INVAL;
  800d59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d5e:	eb f0                	jmp    800d50 <fd_lookup+0x3d>
  800d60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d65:	eb e9                	jmp    800d50 <fd_lookup+0x3d>

00800d67 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d67:	f3 0f 1e fb          	endbr32 
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d74:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800d79:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800d7e:	39 08                	cmp    %ecx,(%eax)
  800d80:	74 33                	je     800db5 <dev_lookup+0x4e>
  800d82:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800d85:	8b 02                	mov    (%edx),%eax
  800d87:	85 c0                	test   %eax,%eax
  800d89:	75 f3                	jne    800d7e <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800d8b:	a1 04 40 80 00       	mov    0x804004,%eax
  800d90:	8b 40 48             	mov    0x48(%eax),%eax
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	51                   	push   %ecx
  800d97:	50                   	push   %eax
  800d98:	68 4c 21 80 00       	push   $0x80214c
  800d9d:	e8 b9 f3 ff ff       	call   80015b <cprintf>
	*dev = 0;
  800da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    
			*dev = devtab[i];
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbf:	eb f2                	jmp    800db3 <dev_lookup+0x4c>

00800dc1 <fd_close>:
{
  800dc1:	f3 0f 1e fb          	endbr32 
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 28             	sub    $0x28,%esp
  800dce:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800dd4:	56                   	push   %esi
  800dd5:	e8 b0 fe ff ff       	call   800c8a <fd2num>
  800dda:	83 c4 08             	add    $0x8,%esp
  800ddd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800de0:	52                   	push   %edx
  800de1:	50                   	push   %eax
  800de2:	e8 2c ff ff ff       	call   800d13 <fd_lookup>
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	85 c0                	test   %eax,%eax
  800dee:	78 05                	js     800df5 <fd_close+0x34>
	    || fd != fd2)
  800df0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800df3:	74 16                	je     800e0b <fd_close+0x4a>
		return (must_exist ? r : 0);
  800df5:	89 f8                	mov    %edi,%eax
  800df7:	84 c0                	test   %al,%al
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	0f 44 d8             	cmove  %eax,%ebx
}
  800e01:	89 d8                	mov    %ebx,%eax
  800e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e0b:	83 ec 08             	sub    $0x8,%esp
  800e0e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e11:	50                   	push   %eax
  800e12:	ff 36                	pushl  (%esi)
  800e14:	e8 4e ff ff ff       	call   800d67 <dev_lookup>
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	78 1a                	js     800e3c <fd_close+0x7b>
		if (dev->dev_close)
  800e22:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e25:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	74 0b                	je     800e3c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	56                   	push   %esi
  800e35:	ff d0                	call   *%eax
  800e37:	89 c3                	mov    %eax,%ebx
  800e39:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	56                   	push   %esi
  800e40:	6a 00                	push   $0x0
  800e42:	e8 58 fd ff ff       	call   800b9f <sys_page_unmap>
	return r;
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	eb b5                	jmp    800e01 <fd_close+0x40>

00800e4c <close>:

int
close(int fdnum)
{
  800e4c:	f3 0f 1e fb          	endbr32 
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e59:	50                   	push   %eax
  800e5a:	ff 75 08             	pushl  0x8(%ebp)
  800e5d:	e8 b1 fe ff ff       	call   800d13 <fd_lookup>
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 02                	jns    800e6b <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    
		return fd_close(fd, 1);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	6a 01                	push   $0x1
  800e70:	ff 75 f4             	pushl  -0xc(%ebp)
  800e73:	e8 49 ff ff ff       	call   800dc1 <fd_close>
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	eb ec                	jmp    800e69 <close+0x1d>

00800e7d <close_all>:

void
close_all(void)
{
  800e7d:	f3 0f 1e fb          	endbr32 
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	53                   	push   %ebx
  800e85:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	53                   	push   %ebx
  800e91:	e8 b6 ff ff ff       	call   800e4c <close>
	for (i = 0; i < MAXFD; i++)
  800e96:	83 c3 01             	add    $0x1,%ebx
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	83 fb 20             	cmp    $0x20,%ebx
  800e9f:	75 ec                	jne    800e8d <close_all+0x10>
}
  800ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ea6:	f3 0f 1e fb          	endbr32 
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800eb3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eb6:	50                   	push   %eax
  800eb7:	ff 75 08             	pushl  0x8(%ebp)
  800eba:	e8 54 fe ff ff       	call   800d13 <fd_lookup>
  800ebf:	89 c3                	mov    %eax,%ebx
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	0f 88 81 00 00 00    	js     800f4d <dup+0xa7>
		return r;
	close(newfdnum);
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	ff 75 0c             	pushl  0xc(%ebp)
  800ed2:	e8 75 ff ff ff       	call   800e4c <close>

	newfd = INDEX2FD(newfdnum);
  800ed7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eda:	c1 e6 0c             	shl    $0xc,%esi
  800edd:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800ee3:	83 c4 04             	add    $0x4,%esp
  800ee6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ee9:	e8 b0 fd ff ff       	call   800c9e <fd2data>
  800eee:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800ef0:	89 34 24             	mov    %esi,(%esp)
  800ef3:	e8 a6 fd ff ff       	call   800c9e <fd2data>
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	c1 e8 16             	shr    $0x16,%eax
  800f02:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f09:	a8 01                	test   $0x1,%al
  800f0b:	74 11                	je     800f1e <dup+0x78>
  800f0d:	89 d8                	mov    %ebx,%eax
  800f0f:	c1 e8 0c             	shr    $0xc,%eax
  800f12:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f19:	f6 c2 01             	test   $0x1,%dl
  800f1c:	75 39                	jne    800f57 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f21:	89 d0                	mov    %edx,%eax
  800f23:	c1 e8 0c             	shr    $0xc,%eax
  800f26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	25 07 0e 00 00       	and    $0xe07,%eax
  800f35:	50                   	push   %eax
  800f36:	56                   	push   %esi
  800f37:	6a 00                	push   $0x0
  800f39:	52                   	push   %edx
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 34 fc ff ff       	call   800b75 <sys_page_map>
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	83 c4 20             	add    $0x20,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 31                	js     800f7b <dup+0xd5>
		goto err;

	return newfdnum;
  800f4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800f4d:	89 d8                	mov    %ebx,%eax
  800f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	25 07 0e 00 00       	and    $0xe07,%eax
  800f66:	50                   	push   %eax
  800f67:	57                   	push   %edi
  800f68:	6a 00                	push   $0x0
  800f6a:	53                   	push   %ebx
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 03 fc ff ff       	call   800b75 <sys_page_map>
  800f72:	89 c3                	mov    %eax,%ebx
  800f74:	83 c4 20             	add    $0x20,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	79 a3                	jns    800f1e <dup+0x78>
	sys_page_unmap(0, newfd);
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 19 fc ff ff       	call   800b9f <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f86:	83 c4 08             	add    $0x8,%esp
  800f89:	57                   	push   %edi
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 0e fc ff ff       	call   800b9f <sys_page_unmap>
	return r;
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	eb b7                	jmp    800f4d <dup+0xa7>

00800f96 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800f96:	f3 0f 1e fb          	endbr32 
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	53                   	push   %ebx
  800f9e:	83 ec 1c             	sub    $0x1c,%esp
  800fa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fa4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	53                   	push   %ebx
  800fa9:	e8 65 fd ff ff       	call   800d13 <fd_lookup>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 3f                	js     800ff4 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbf:	ff 30                	pushl  (%eax)
  800fc1:	e8 a1 fd ff ff       	call   800d67 <dev_lookup>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 27                	js     800ff4 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fcd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fd0:	8b 42 08             	mov    0x8(%edx),%eax
  800fd3:	83 e0 03             	and    $0x3,%eax
  800fd6:	83 f8 01             	cmp    $0x1,%eax
  800fd9:	74 1e                	je     800ff9 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fde:	8b 40 08             	mov    0x8(%eax),%eax
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	74 35                	je     80101a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	ff 75 10             	pushl  0x10(%ebp)
  800feb:	ff 75 0c             	pushl  0xc(%ebp)
  800fee:	52                   	push   %edx
  800fef:	ff d0                	call   *%eax
  800ff1:	83 c4 10             	add    $0x10,%esp
}
  800ff4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ff9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffe:	8b 40 48             	mov    0x48(%eax),%eax
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	53                   	push   %ebx
  801005:	50                   	push   %eax
  801006:	68 8d 21 80 00       	push   $0x80218d
  80100b:	e8 4b f1 ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801018:	eb da                	jmp    800ff4 <read+0x5e>
		return -E_NOT_SUPP;
  80101a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80101f:	eb d3                	jmp    800ff4 <read+0x5e>

00801021 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801021:	f3 0f 1e fb          	endbr32 
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	57                   	push   %edi
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801031:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
  801039:	eb 02                	jmp    80103d <readn+0x1c>
  80103b:	01 c3                	add    %eax,%ebx
  80103d:	39 f3                	cmp    %esi,%ebx
  80103f:	73 21                	jae    801062 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	89 f0                	mov    %esi,%eax
  801046:	29 d8                	sub    %ebx,%eax
  801048:	50                   	push   %eax
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	03 45 0c             	add    0xc(%ebp),%eax
  80104e:	50                   	push   %eax
  80104f:	57                   	push   %edi
  801050:	e8 41 ff ff ff       	call   800f96 <read>
		if (m < 0)
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 04                	js     801060 <readn+0x3f>
			return m;
		if (m == 0)
  80105c:	75 dd                	jne    80103b <readn+0x1a>
  80105e:	eb 02                	jmp    801062 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801060:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801062:	89 d8                	mov    %ebx,%eax
  801064:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80106c:	f3 0f 1e fb          	endbr32 
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	53                   	push   %ebx
  801074:	83 ec 1c             	sub    $0x1c,%esp
  801077:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	53                   	push   %ebx
  80107f:	e8 8f fc ff ff       	call   800d13 <fd_lookup>
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 3a                	js     8010c5 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801095:	ff 30                	pushl  (%eax)
  801097:	e8 cb fc ff ff       	call   800d67 <dev_lookup>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 22                	js     8010c5 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010aa:	74 1e                	je     8010ca <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010af:	8b 52 0c             	mov    0xc(%edx),%edx
  8010b2:	85 d2                	test   %edx,%edx
  8010b4:	74 35                	je     8010eb <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	ff 75 0c             	pushl  0xc(%ebp)
  8010bf:	50                   	push   %eax
  8010c0:	ff d2                	call   *%edx
  8010c2:	83 c4 10             	add    $0x10,%esp
}
  8010c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cf:	8b 40 48             	mov    0x48(%eax),%eax
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	53                   	push   %ebx
  8010d6:	50                   	push   %eax
  8010d7:	68 a9 21 80 00       	push   $0x8021a9
  8010dc:	e8 7a f0 ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e9:	eb da                	jmp    8010c5 <write+0x59>
		return -E_NOT_SUPP;
  8010eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010f0:	eb d3                	jmp    8010c5 <write+0x59>

008010f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8010f2:	f3 0f 1e fb          	endbr32 
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ff:	50                   	push   %eax
  801100:	ff 75 08             	pushl  0x8(%ebp)
  801103:	e8 0b fc ff ff       	call   800d13 <fd_lookup>
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 0e                	js     80111d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80110f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801115:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80111f:	f3 0f 1e fb          	endbr32 
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	53                   	push   %ebx
  801127:	83 ec 1c             	sub    $0x1c,%esp
  80112a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	53                   	push   %ebx
  801132:	e8 dc fb ff ff       	call   800d13 <fd_lookup>
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 37                	js     801175 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801148:	ff 30                	pushl  (%eax)
  80114a:	e8 18 fc ff ff       	call   800d67 <dev_lookup>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 1f                	js     801175 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801156:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801159:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115d:	74 1b                	je     80117a <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80115f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801162:	8b 52 18             	mov    0x18(%edx),%edx
  801165:	85 d2                	test   %edx,%edx
  801167:	74 32                	je     80119b <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	ff 75 0c             	pushl  0xc(%ebp)
  80116f:	50                   	push   %eax
  801170:	ff d2                	call   *%edx
  801172:	83 c4 10             	add    $0x10,%esp
}
  801175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801178:	c9                   	leave  
  801179:	c3                   	ret    
			thisenv->env_id, fdnum);
  80117a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80117f:	8b 40 48             	mov    0x48(%eax),%eax
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	53                   	push   %ebx
  801186:	50                   	push   %eax
  801187:	68 6c 21 80 00       	push   $0x80216c
  80118c:	e8 ca ef ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801199:	eb da                	jmp    801175 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80119b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a0:	eb d3                	jmp    801175 <ftruncate+0x56>

008011a2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011a2:	f3 0f 1e fb          	endbr32 
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 1c             	sub    $0x1c,%esp
  8011ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	ff 75 08             	pushl  0x8(%ebp)
  8011b7:	e8 57 fb ff ff       	call   800d13 <fd_lookup>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 4b                	js     80120e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	ff 30                	pushl  (%eax)
  8011cf:	e8 93 fb ff ff       	call   800d67 <dev_lookup>
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 33                	js     80120e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8011db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011e2:	74 2f                	je     801213 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011ee:	00 00 00 
	stat->st_isdir = 0;
  8011f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011f8:	00 00 00 
	stat->st_dev = dev;
  8011fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	53                   	push   %ebx
  801205:	ff 75 f0             	pushl  -0x10(%ebp)
  801208:	ff 50 14             	call   *0x14(%eax)
  80120b:	83 c4 10             	add    $0x10,%esp
}
  80120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    
		return -E_NOT_SUPP;
  801213:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801218:	eb f4                	jmp    80120e <fstat+0x6c>

0080121a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80121a:	f3 0f 1e fb          	endbr32 
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	6a 00                	push   $0x0
  801228:	ff 75 08             	pushl  0x8(%ebp)
  80122b:	e8 fb 01 00 00       	call   80142b <open>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 1b                	js     801254 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	ff 75 0c             	pushl  0xc(%ebp)
  80123f:	50                   	push   %eax
  801240:	e8 5d ff ff ff       	call   8011a2 <fstat>
  801245:	89 c6                	mov    %eax,%esi
	close(fd);
  801247:	89 1c 24             	mov    %ebx,(%esp)
  80124a:	e8 fd fb ff ff       	call   800e4c <close>
	return r;
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	89 f3                	mov    %esi,%ebx
}
  801254:	89 d8                	mov    %ebx,%eax
  801256:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	89 c6                	mov    %eax,%esi
  801264:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801266:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80126d:	74 27                	je     801296 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80126f:	6a 07                	push   $0x7
  801271:	68 00 50 80 00       	push   $0x805000
  801276:	56                   	push   %esi
  801277:	ff 35 00 40 80 00    	pushl  0x804000
  80127d:	e8 09 08 00 00       	call   801a8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801282:	83 c4 0c             	add    $0xc,%esp
  801285:	6a 00                	push   $0x0
  801287:	53                   	push   %ebx
  801288:	6a 00                	push   $0x0
  80128a:	e8 8e 07 00 00       	call   801a1d <ipc_recv>
}
  80128f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801292:	5b                   	pop    %ebx
  801293:	5e                   	pop    %esi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	6a 01                	push   $0x1
  80129b:	e8 50 08 00 00       	call   801af0 <ipc_find_env>
  8012a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	eb c5                	jmp    80126f <fsipc+0x12>

008012aa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012aa:	f3 0f 1e fb          	endbr32 
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8012d1:	e8 87 ff ff ff       	call   80125d <fsipc>
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <devfile_flush>:
{
  8012d8:	f3 0f 1e fb          	endbr32 
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8012e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8012ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8012f7:	e8 61 ff ff ff       	call   80125d <fsipc>
}
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <devfile_stat>:
{
  8012fe:	f3 0f 1e fb          	endbr32 
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80130c:	8b 45 08             	mov    0x8(%ebp),%eax
  80130f:	8b 40 0c             	mov    0xc(%eax),%eax
  801312:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801317:	ba 00 00 00 00       	mov    $0x0,%edx
  80131c:	b8 05 00 00 00       	mov    $0x5,%eax
  801321:	e8 37 ff ff ff       	call   80125d <fsipc>
  801326:	85 c0                	test   %eax,%eax
  801328:	78 2c                	js     801356 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	68 00 50 80 00       	push   $0x805000
  801332:	53                   	push   %ebx
  801333:	e8 8d f3 ff ff       	call   8006c5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801338:	a1 80 50 80 00       	mov    0x805080,%eax
  80133d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801343:	a1 84 50 80 00       	mov    0x805084,%eax
  801348:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <devfile_write>:
{
  80135b:	f3 0f 1e fb          	endbr32 
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801368:	8b 55 08             	mov    0x8(%ebp),%edx
  80136b:	8b 52 0c             	mov    0xc(%edx),%edx
  80136e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801374:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801379:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80137e:	0f 47 c2             	cmova  %edx,%eax
  801381:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801386:	50                   	push   %eax
  801387:	ff 75 0c             	pushl  0xc(%ebp)
  80138a:	68 08 50 80 00       	push   $0x805008
  80138f:	e8 e9 f4 ff ff       	call   80087d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801394:	ba 00 00 00 00       	mov    $0x0,%edx
  801399:	b8 04 00 00 00       	mov    $0x4,%eax
  80139e:	e8 ba fe ff ff       	call   80125d <fsipc>
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <devfile_read>:
{
  8013a5:	f3 0f 1e fb          	endbr32 
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	56                   	push   %esi
  8013ad:	53                   	push   %ebx
  8013ae:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013bc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8013cc:	e8 8c fe ff ff       	call   80125d <fsipc>
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 1f                	js     8013f6 <devfile_read+0x51>
	assert(r <= n);
  8013d7:	39 f0                	cmp    %esi,%eax
  8013d9:	77 24                	ja     8013ff <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8013db:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013e0:	7f 33                	jg     801415 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8013e2:	83 ec 04             	sub    $0x4,%esp
  8013e5:	50                   	push   %eax
  8013e6:	68 00 50 80 00       	push   $0x805000
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	e8 8a f4 ff ff       	call   80087d <memmove>
	return r;
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
	assert(r <= n);
  8013ff:	68 d8 21 80 00       	push   $0x8021d8
  801404:	68 df 21 80 00       	push   $0x8021df
  801409:	6a 7c                	push   $0x7c
  80140b:	68 f4 21 80 00       	push   $0x8021f4
  801410:	e8 be 05 00 00       	call   8019d3 <_panic>
	assert(r <= PGSIZE);
  801415:	68 ff 21 80 00       	push   $0x8021ff
  80141a:	68 df 21 80 00       	push   $0x8021df
  80141f:	6a 7d                	push   $0x7d
  801421:	68 f4 21 80 00       	push   $0x8021f4
  801426:	e8 a8 05 00 00       	call   8019d3 <_panic>

0080142b <open>:
{
  80142b:	f3 0f 1e fb          	endbr32 
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 1c             	sub    $0x1c,%esp
  801437:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80143a:	56                   	push   %esi
  80143b:	e8 42 f2 ff ff       	call   800682 <strlen>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801448:	7f 6c                	jg     8014b6 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	e8 67 f8 ff ff       	call   800cbd <fd_alloc>
  801456:	89 c3                	mov    %eax,%ebx
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 3c                	js     80149b <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	56                   	push   %esi
  801463:	68 00 50 80 00       	push   $0x805000
  801468:	e8 58 f2 ff ff       	call   8006c5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80146d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801470:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801475:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801478:	b8 01 00 00 00       	mov    $0x1,%eax
  80147d:	e8 db fd ff ff       	call   80125d <fsipc>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 19                	js     8014a4 <open+0x79>
	return fd2num(fd);
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	ff 75 f4             	pushl  -0xc(%ebp)
  801491:	e8 f4 f7 ff ff       	call   800c8a <fd2num>
  801496:	89 c3                	mov    %eax,%ebx
  801498:	83 c4 10             	add    $0x10,%esp
}
  80149b:	89 d8                	mov    %ebx,%eax
  80149d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a0:	5b                   	pop    %ebx
  8014a1:	5e                   	pop    %esi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    
		fd_close(fd, 0);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	6a 00                	push   $0x0
  8014a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ac:	e8 10 f9 ff ff       	call   800dc1 <fd_close>
		return r;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	eb e5                	jmp    80149b <open+0x70>
		return -E_BAD_PATH;
  8014b6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014bb:	eb de                	jmp    80149b <open+0x70>

008014bd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014bd:	f3 0f 1e fb          	endbr32 
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d1:	e8 87 fd ff ff       	call   80125d <fsipc>
}
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014d8:	f3 0f 1e fb          	endbr32 
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	e8 af f7 ff ff       	call   800c9e <fd2data>
  8014ef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	68 0b 22 80 00       	push   $0x80220b
  8014f9:	53                   	push   %ebx
  8014fa:	e8 c6 f1 ff ff       	call   8006c5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014ff:	8b 46 04             	mov    0x4(%esi),%eax
  801502:	2b 06                	sub    (%esi),%eax
  801504:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80150a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801511:	00 00 00 
	stat->st_dev = &devpipe;
  801514:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80151b:	30 80 00 
	return 0;
}
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80152a:	f3 0f 1e fb          	endbr32 
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801538:	53                   	push   %ebx
  801539:	6a 00                	push   $0x0
  80153b:	e8 5f f6 ff ff       	call   800b9f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801540:	89 1c 24             	mov    %ebx,(%esp)
  801543:	e8 56 f7 ff ff       	call   800c9e <fd2data>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	50                   	push   %eax
  80154c:	6a 00                	push   $0x0
  80154e:	e8 4c f6 ff ff       	call   800b9f <sys_page_unmap>
}
  801553:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <_pipeisclosed>:
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	57                   	push   %edi
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	83 ec 1c             	sub    $0x1c,%esp
  801561:	89 c7                	mov    %eax,%edi
  801563:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801565:	a1 04 40 80 00       	mov    0x804004,%eax
  80156a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	57                   	push   %edi
  801571:	e8 b7 05 00 00       	call   801b2d <pageref>
  801576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801579:	89 34 24             	mov    %esi,(%esp)
  80157c:	e8 ac 05 00 00       	call   801b2d <pageref>
		nn = thisenv->env_runs;
  801581:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801587:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	39 cb                	cmp    %ecx,%ebx
  80158f:	74 1b                	je     8015ac <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801591:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801594:	75 cf                	jne    801565 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801596:	8b 42 58             	mov    0x58(%edx),%eax
  801599:	6a 01                	push   $0x1
  80159b:	50                   	push   %eax
  80159c:	53                   	push   %ebx
  80159d:	68 12 22 80 00       	push   $0x802212
  8015a2:	e8 b4 eb ff ff       	call   80015b <cprintf>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb b9                	jmp    801565 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015ac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015af:	0f 94 c0             	sete   %al
  8015b2:	0f b6 c0             	movzbl %al,%eax
}
  8015b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5f                   	pop    %edi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <devpipe_write>:
{
  8015bd:	f3 0f 1e fb          	endbr32 
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	57                   	push   %edi
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 28             	sub    $0x28,%esp
  8015ca:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8015cd:	56                   	push   %esi
  8015ce:	e8 cb f6 ff ff       	call   800c9e <fd2data>
  8015d3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8015dd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015e0:	74 4f                	je     801631 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8015e5:	8b 0b                	mov    (%ebx),%ecx
  8015e7:	8d 51 20             	lea    0x20(%ecx),%edx
  8015ea:	39 d0                	cmp    %edx,%eax
  8015ec:	72 14                	jb     801602 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8015ee:	89 da                	mov    %ebx,%edx
  8015f0:	89 f0                	mov    %esi,%eax
  8015f2:	e8 61 ff ff ff       	call   801558 <_pipeisclosed>
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	75 3b                	jne    801636 <devpipe_write+0x79>
			sys_yield();
  8015fb:	e8 22 f5 ff ff       	call   800b22 <sys_yield>
  801600:	eb e0                	jmp    8015e2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801602:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801605:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801609:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	c1 fa 1f             	sar    $0x1f,%edx
  801611:	89 d1                	mov    %edx,%ecx
  801613:	c1 e9 1b             	shr    $0x1b,%ecx
  801616:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801619:	83 e2 1f             	and    $0x1f,%edx
  80161c:	29 ca                	sub    %ecx,%edx
  80161e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801622:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801626:	83 c0 01             	add    $0x1,%eax
  801629:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80162c:	83 c7 01             	add    $0x1,%edi
  80162f:	eb ac                	jmp    8015dd <devpipe_write+0x20>
	return i;
  801631:	8b 45 10             	mov    0x10(%ebp),%eax
  801634:	eb 05                	jmp    80163b <devpipe_write+0x7e>
				return 0;
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <devpipe_read>:
{
  801643:	f3 0f 1e fb          	endbr32 
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 18             	sub    $0x18,%esp
  801650:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801653:	57                   	push   %edi
  801654:	e8 45 f6 ff ff       	call   800c9e <fd2data>
  801659:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	be 00 00 00 00       	mov    $0x0,%esi
  801663:	3b 75 10             	cmp    0x10(%ebp),%esi
  801666:	75 14                	jne    80167c <devpipe_read+0x39>
	return i;
  801668:	8b 45 10             	mov    0x10(%ebp),%eax
  80166b:	eb 02                	jmp    80166f <devpipe_read+0x2c>
				return i;
  80166d:	89 f0                	mov    %esi,%eax
}
  80166f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    
			sys_yield();
  801677:	e8 a6 f4 ff ff       	call   800b22 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80167c:	8b 03                	mov    (%ebx),%eax
  80167e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801681:	75 18                	jne    80169b <devpipe_read+0x58>
			if (i > 0)
  801683:	85 f6                	test   %esi,%esi
  801685:	75 e6                	jne    80166d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801687:	89 da                	mov    %ebx,%edx
  801689:	89 f8                	mov    %edi,%eax
  80168b:	e8 c8 fe ff ff       	call   801558 <_pipeisclosed>
  801690:	85 c0                	test   %eax,%eax
  801692:	74 e3                	je     801677 <devpipe_read+0x34>
				return 0;
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
  801699:	eb d4                	jmp    80166f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80169b:	99                   	cltd   
  80169c:	c1 ea 1b             	shr    $0x1b,%edx
  80169f:	01 d0                	add    %edx,%eax
  8016a1:	83 e0 1f             	and    $0x1f,%eax
  8016a4:	29 d0                	sub    %edx,%eax
  8016a6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ae:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016b1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016b4:	83 c6 01             	add    $0x1,%esi
  8016b7:	eb aa                	jmp    801663 <devpipe_read+0x20>

008016b9 <pipe>:
{
  8016b9:	f3 0f 1e fb          	endbr32 
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	56                   	push   %esi
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	e8 ef f5 ff ff       	call   800cbd <fd_alloc>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 23 01 00 00    	js     8017fe <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	68 07 04 00 00       	push   $0x407
  8016e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 60 f4 ff ff       	call   800b4d <sys_page_alloc>
  8016ed:	89 c3                	mov    %eax,%ebx
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	0f 88 04 01 00 00    	js     8017fe <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	e8 b7 f5 ff ff       	call   800cbd <fd_alloc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	0f 88 db 00 00 00    	js     8017ee <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	68 07 04 00 00       	push   $0x407
  80171b:	ff 75 f0             	pushl  -0x10(%ebp)
  80171e:	6a 00                	push   $0x0
  801720:	e8 28 f4 ff ff       	call   800b4d <sys_page_alloc>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	0f 88 bc 00 00 00    	js     8017ee <pipe+0x135>
	va = fd2data(fd0);
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	ff 75 f4             	pushl  -0xc(%ebp)
  801738:	e8 61 f5 ff ff       	call   800c9e <fd2data>
  80173d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173f:	83 c4 0c             	add    $0xc,%esp
  801742:	68 07 04 00 00       	push   $0x407
  801747:	50                   	push   %eax
  801748:	6a 00                	push   $0x0
  80174a:	e8 fe f3 ff ff       	call   800b4d <sys_page_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	0f 88 82 00 00 00    	js     8017de <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175c:	83 ec 0c             	sub    $0xc,%esp
  80175f:	ff 75 f0             	pushl  -0x10(%ebp)
  801762:	e8 37 f5 ff ff       	call   800c9e <fd2data>
  801767:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80176e:	50                   	push   %eax
  80176f:	6a 00                	push   $0x0
  801771:	56                   	push   %esi
  801772:	6a 00                	push   $0x0
  801774:	e8 fc f3 ff ff       	call   800b75 <sys_page_map>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	83 c4 20             	add    $0x20,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 4e                	js     8017d0 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801782:	a1 20 30 80 00       	mov    0x803020,%eax
  801787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80178c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801796:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801799:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ab:	e8 da f4 ff ff       	call   800c8a <fd2num>
  8017b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017b5:	83 c4 04             	add    $0x4,%esp
  8017b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bb:	e8 ca f4 ff ff       	call   800c8a <fd2num>
  8017c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ce:	eb 2e                	jmp    8017fe <pipe+0x145>
	sys_page_unmap(0, va);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	56                   	push   %esi
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 c4 f3 ff ff       	call   800b9f <sys_page_unmap>
  8017db:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e4:	6a 00                	push   $0x0
  8017e6:	e8 b4 f3 ff ff       	call   800b9f <sys_page_unmap>
  8017eb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 a4 f3 ff ff       	call   800b9f <sys_page_unmap>
  8017fb:	83 c4 10             	add    $0x10,%esp
}
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <pipeisclosed>:
{
  801807:	f3 0f 1e fb          	endbr32 
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801814:	50                   	push   %eax
  801815:	ff 75 08             	pushl  0x8(%ebp)
  801818:	e8 f6 f4 ff ff       	call   800d13 <fd_lookup>
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	78 18                	js     80183c <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	ff 75 f4             	pushl  -0xc(%ebp)
  80182a:	e8 6f f4 ff ff       	call   800c9e <fd2data>
  80182f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801834:	e8 1f fd ff ff       	call   801558 <_pipeisclosed>
  801839:	83 c4 10             	add    $0x10,%esp
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80183e:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801842:	b8 00 00 00 00       	mov    $0x0,%eax
  801847:	c3                   	ret    

00801848 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801848:	f3 0f 1e fb          	endbr32 
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801852:	68 2a 22 80 00       	push   $0x80222a
  801857:	ff 75 0c             	pushl  0xc(%ebp)
  80185a:	e8 66 ee ff ff       	call   8006c5 <strcpy>
	return 0;
}
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <devcons_write>:
{
  801866:	f3 0f 1e fb          	endbr32 
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	57                   	push   %edi
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
  801870:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801876:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80187b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801881:	3b 75 10             	cmp    0x10(%ebp),%esi
  801884:	73 31                	jae    8018b7 <devcons_write+0x51>
		m = n - tot;
  801886:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801889:	29 f3                	sub    %esi,%ebx
  80188b:	83 fb 7f             	cmp    $0x7f,%ebx
  80188e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801893:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801896:	83 ec 04             	sub    $0x4,%esp
  801899:	53                   	push   %ebx
  80189a:	89 f0                	mov    %esi,%eax
  80189c:	03 45 0c             	add    0xc(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	57                   	push   %edi
  8018a1:	e8 d7 ef ff ff       	call   80087d <memmove>
		sys_cputs(buf, m);
  8018a6:	83 c4 08             	add    $0x8,%esp
  8018a9:	53                   	push   %ebx
  8018aa:	57                   	push   %edi
  8018ab:	e8 d2 f1 ff ff       	call   800a82 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018b0:	01 de                	add    %ebx,%esi
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	eb ca                	jmp    801881 <devcons_write+0x1b>
}
  8018b7:	89 f0                	mov    %esi,%eax
  8018b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5e                   	pop    %esi
  8018be:	5f                   	pop    %edi
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    

008018c1 <devcons_read>:
{
  8018c1:	f3 0f 1e fb          	endbr32 
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8018d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d4:	74 21                	je     8018f7 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8018d6:	e8 d1 f1 ff ff       	call   800aac <sys_cgetc>
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	75 07                	jne    8018e6 <devcons_read+0x25>
		sys_yield();
  8018df:	e8 3e f2 ff ff       	call   800b22 <sys_yield>
  8018e4:	eb f0                	jmp    8018d6 <devcons_read+0x15>
	if (c < 0)
  8018e6:	78 0f                	js     8018f7 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8018e8:	83 f8 04             	cmp    $0x4,%eax
  8018eb:	74 0c                	je     8018f9 <devcons_read+0x38>
	*(char*)vbuf = c;
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	88 02                	mov    %al,(%edx)
	return 1;
  8018f2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    
		return 0;
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fe:	eb f7                	jmp    8018f7 <devcons_read+0x36>

00801900 <cputchar>:
{
  801900:	f3 0f 1e fb          	endbr32 
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801910:	6a 01                	push   $0x1
  801912:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	e8 67 f1 ff ff       	call   800a82 <sys_cputs>
}
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <getchar>:
{
  801920:	f3 0f 1e fb          	endbr32 
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80192a:	6a 01                	push   $0x1
  80192c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	6a 00                	push   $0x0
  801932:	e8 5f f6 ff ff       	call   800f96 <read>
	if (r < 0)
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 06                	js     801944 <getchar+0x24>
	if (r < 1)
  80193e:	74 06                	je     801946 <getchar+0x26>
	return c;
  801940:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    
		return -E_EOF;
  801946:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80194b:	eb f7                	jmp    801944 <getchar+0x24>

0080194d <iscons>:
{
  80194d:	f3 0f 1e fb          	endbr32 
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195a:	50                   	push   %eax
  80195b:	ff 75 08             	pushl  0x8(%ebp)
  80195e:	e8 b0 f3 ff ff       	call   800d13 <fd_lookup>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	78 11                	js     80197b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801973:	39 10                	cmp    %edx,(%eax)
  801975:	0f 94 c0             	sete   %al
  801978:	0f b6 c0             	movzbl %al,%eax
}
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <opencons>:
{
  80197d:	f3 0f 1e fb          	endbr32 
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801987:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198a:	50                   	push   %eax
  80198b:	e8 2d f3 ff ff       	call   800cbd <fd_alloc>
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	78 3a                	js     8019d1 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801997:	83 ec 04             	sub    $0x4,%esp
  80199a:	68 07 04 00 00       	push   $0x407
  80199f:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a2:	6a 00                	push   $0x0
  8019a4:	e8 a4 f1 ff ff       	call   800b4d <sys_page_alloc>
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 21                	js     8019d1 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	50                   	push   %eax
  8019c9:	e8 bc f2 ff ff       	call   800c8a <fd2num>
  8019ce:	83 c4 10             	add    $0x10,%esp
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019d3:	f3 0f 1e fb          	endbr32 
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	56                   	push   %esi
  8019db:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019df:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019e5:	e8 10 f1 ff ff       	call   800afa <sys_getenvid>
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	ff 75 0c             	pushl  0xc(%ebp)
  8019f0:	ff 75 08             	pushl  0x8(%ebp)
  8019f3:	56                   	push   %esi
  8019f4:	50                   	push   %eax
  8019f5:	68 38 22 80 00       	push   $0x802238
  8019fa:	e8 5c e7 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ff:	83 c4 18             	add    $0x18,%esp
  801a02:	53                   	push   %ebx
  801a03:	ff 75 10             	pushl  0x10(%ebp)
  801a06:	e8 fb e6 ff ff       	call   800106 <vcprintf>
	cprintf("\n");
  801a0b:	c7 04 24 23 22 80 00 	movl   $0x802223,(%esp)
  801a12:	e8 44 e7 ff ff       	call   80015b <cprintf>
  801a17:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a1a:	cc                   	int3   
  801a1b:	eb fd                	jmp    801a1a <_panic+0x47>

00801a1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1d:	f3 0f 1e fb          	endbr32 
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	8b 75 08             	mov    0x8(%ebp),%esi
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a36:	0f 44 c2             	cmove  %edx,%eax
  801a39:	83 ec 0c             	sub    $0xc,%esp
  801a3c:	50                   	push   %eax
  801a3d:	e8 22 f2 ff ff       	call   800c64 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	85 f6                	test   %esi,%esi
  801a47:	74 15                	je     801a5e <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a49:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a51:	74 09                	je     801a5c <ipc_recv+0x3f>
  801a53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a59:	8b 52 74             	mov    0x74(%edx),%edx
  801a5c:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a5e:	85 db                	test   %ebx,%ebx
  801a60:	74 15                	je     801a77 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a6a:	74 09                	je     801a75 <ipc_recv+0x58>
  801a6c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a72:	8b 52 78             	mov    0x78(%edx),%edx
  801a75:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a77:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a7a:	74 08                	je     801a84 <ipc_recv+0x67>
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8b:	f3 0f 1e fb          	endbr32 
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	57                   	push   %edi
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa1:	eb 1f                	jmp    801ac2 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801aa3:	6a 00                	push   $0x0
  801aa5:	68 00 00 c0 ee       	push   $0xeec00000
  801aaa:	56                   	push   %esi
  801aab:	57                   	push   %edi
  801aac:	e8 8a f1 ff ff       	call   800c3b <sys_ipc_try_send>
  801ab1:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	74 30                	je     801ae8 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801ab8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abb:	75 19                	jne    801ad6 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801abd:	e8 60 f0 ff ff       	call   800b22 <sys_yield>
		if (pg != NULL) {
  801ac2:	85 db                	test   %ebx,%ebx
  801ac4:	74 dd                	je     801aa3 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801ac6:	ff 75 14             	pushl  0x14(%ebp)
  801ac9:	53                   	push   %ebx
  801aca:	56                   	push   %esi
  801acb:	57                   	push   %edi
  801acc:	e8 6a f1 ff ff       	call   800c3b <sys_ipc_try_send>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	eb de                	jmp    801ab4 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801ad6:	50                   	push   %eax
  801ad7:	68 5b 22 80 00       	push   $0x80225b
  801adc:	6a 3e                	push   $0x3e
  801ade:	68 68 22 80 00       	push   $0x802268
  801ae3:	e8 eb fe ff ff       	call   8019d3 <_panic>
	}
}
  801ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5f                   	pop    %edi
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    

00801af0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af0:	f3 0f 1e fb          	endbr32 
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b02:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b08:	8b 52 50             	mov    0x50(%edx),%edx
  801b0b:	39 ca                	cmp    %ecx,%edx
  801b0d:	74 11                	je     801b20 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b17:	75 e6                	jne    801aff <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb 0b                	jmp    801b2b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b28:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2d:	f3 0f 1e fb          	endbr32 
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	c1 ea 16             	shr    $0x16,%edx
  801b3c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b48:	f6 c1 01             	test   $0x1,%cl
  801b4b:	74 1c                	je     801b69 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b4d:	c1 e8 0c             	shr    $0xc,%eax
  801b50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b57:	a8 01                	test   $0x1,%al
  801b59:	74 0e                	je     801b69 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5b:	c1 e8 0c             	shr    $0xc,%eax
  801b5e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b65:	ef 
  801b66:	0f b7 d2             	movzwl %dx,%edx
}
  801b69:	89 d0                	mov    %edx,%eax
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    
  801b6d:	66 90                	xchg   %ax,%ax
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 1c             	sub    $0x1c,%esp
  801b7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	75 19                	jne    801ba8 <__udivdi3+0x38>
  801b8f:	39 f3                	cmp    %esi,%ebx
  801b91:	76 4d                	jbe    801be0 <__udivdi3+0x70>
  801b93:	31 ff                	xor    %edi,%edi
  801b95:	89 e8                	mov    %ebp,%eax
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	f7 f3                	div    %ebx
  801b9b:	89 fa                	mov    %edi,%edx
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    
  801ba5:	8d 76 00             	lea    0x0(%esi),%esi
  801ba8:	39 f2                	cmp    %esi,%edx
  801baa:	76 14                	jbe    801bc0 <__udivdi3+0x50>
  801bac:	31 ff                	xor    %edi,%edi
  801bae:	31 c0                	xor    %eax,%eax
  801bb0:	89 fa                	mov    %edi,%edx
  801bb2:	83 c4 1c             	add    $0x1c,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	0f bd fa             	bsr    %edx,%edi
  801bc3:	83 f7 1f             	xor    $0x1f,%edi
  801bc6:	75 48                	jne    801c10 <__udivdi3+0xa0>
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	72 06                	jb     801bd2 <__udivdi3+0x62>
  801bcc:	31 c0                	xor    %eax,%eax
  801bce:	39 eb                	cmp    %ebp,%ebx
  801bd0:	77 de                	ja     801bb0 <__udivdi3+0x40>
  801bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd7:	eb d7                	jmp    801bb0 <__udivdi3+0x40>
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d9                	mov    %ebx,%ecx
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	75 0b                	jne    801bf1 <__udivdi3+0x81>
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	31 d2                	xor    %edx,%edx
  801bed:	f7 f3                	div    %ebx
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c6                	mov    %eax,%esi
  801bf9:	89 e8                	mov    %ebp,%eax
  801bfb:	89 f7                	mov    %esi,%edi
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	83 c4 1c             	add    $0x1c,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	b8 20 00 00 00       	mov    $0x20,%eax
  801c17:	29 f8                	sub    %edi,%eax
  801c19:	d3 e2                	shl    %cl,%edx
  801c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c29:	09 d1                	or     %edx,%ecx
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e3                	shl    %cl,%ebx
  801c35:	89 c1                	mov    %eax,%ecx
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 f9                	mov    %edi,%ecx
  801c3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c3f:	89 eb                	mov    %ebp,%ebx
  801c41:	d3 e6                	shl    %cl,%esi
  801c43:	89 c1                	mov    %eax,%ecx
  801c45:	d3 eb                	shr    %cl,%ebx
  801c47:	09 de                	or     %ebx,%esi
  801c49:	89 f0                	mov    %esi,%eax
  801c4b:	f7 74 24 08          	divl   0x8(%esp)
  801c4f:	89 d6                	mov    %edx,%esi
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	f7 64 24 0c          	mull   0xc(%esp)
  801c57:	39 d6                	cmp    %edx,%esi
  801c59:	72 15                	jb     801c70 <__udivdi3+0x100>
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e5                	shl    %cl,%ebp
  801c5f:	39 c5                	cmp    %eax,%ebp
  801c61:	73 04                	jae    801c67 <__udivdi3+0xf7>
  801c63:	39 d6                	cmp    %edx,%esi
  801c65:	74 09                	je     801c70 <__udivdi3+0x100>
  801c67:	89 d8                	mov    %ebx,%eax
  801c69:	31 ff                	xor    %edi,%edi
  801c6b:	e9 40 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	e9 36 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	75 19                	jne    801cb8 <__umoddi3+0x38>
  801c9f:	39 df                	cmp    %ebx,%edi
  801ca1:	76 5d                	jbe    801d00 <__umoddi3+0x80>
  801ca3:	89 f0                	mov    %esi,%eax
  801ca5:	89 da                	mov    %ebx,%edx
  801ca7:	f7 f7                	div    %edi
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	39 d8                	cmp    %ebx,%eax
  801cbc:	76 12                	jbe    801cd0 <__umoddi3+0x50>
  801cbe:	89 f0                	mov    %esi,%eax
  801cc0:	89 da                	mov    %ebx,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd e8             	bsr    %eax,%ebp
  801cd3:	83 f5 1f             	xor    $0x1f,%ebp
  801cd6:	75 50                	jne    801d28 <__umoddi3+0xa8>
  801cd8:	39 d8                	cmp    %ebx,%eax
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	39 f7                	cmp    %esi,%edi
  801ce4:	0f 86 d6 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	89 ca                	mov    %ecx,%edx
  801cee:	83 c4 1c             	add    $0x1c,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    
  801cf6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
  801d00:	89 fd                	mov    %edi,%ebp
  801d02:	85 ff                	test   %edi,%edi
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 d8                	mov    %ebx,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	eb 8c                	jmp    801cad <__umoddi3+0x2d>
  801d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d2f:	29 ea                	sub    %ebp,%edx
  801d31:	d3 e0                	shl    %cl,%eax
  801d33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d49:	09 c1                	or     %eax,%ecx
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 e9                	mov    %ebp,%ecx
  801d53:	d3 e7                	shl    %cl,%edi
  801d55:	89 d1                	mov    %edx,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d5f:	d3 e3                	shl    %cl,%ebx
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	89 d1                	mov    %edx,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	09 d8                	or     %ebx,%eax
  801d71:	f7 74 24 08          	divl   0x8(%esp)
  801d75:	89 d1                	mov    %edx,%ecx
  801d77:	89 f3                	mov    %esi,%ebx
  801d79:	f7 64 24 0c          	mull   0xc(%esp)
  801d7d:	89 c6                	mov    %eax,%esi
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	39 d1                	cmp    %edx,%ecx
  801d83:	72 06                	jb     801d8b <__umoddi3+0x10b>
  801d85:	75 10                	jne    801d97 <__umoddi3+0x117>
  801d87:	39 c3                	cmp    %eax,%ebx
  801d89:	73 0c                	jae    801d97 <__umoddi3+0x117>
  801d8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d93:	89 d7                	mov    %edx,%edi
  801d95:	89 c6                	mov    %eax,%esi
  801d97:	89 ca                	mov    %ecx,%edx
  801d99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d9e:	29 f3                	sub    %esi,%ebx
  801da0:	19 fa                	sbb    %edi,%edx
  801da2:	89 d0                	mov    %edx,%eax
  801da4:	d3 e0                	shl    %cl,%eax
  801da6:	89 e9                	mov    %ebp,%ecx
  801da8:	d3 eb                	shr    %cl,%ebx
  801daa:	d3 ea                	shr    %cl,%edx
  801dac:	09 d8                	or     %ebx,%eax
  801dae:	83 c4 1c             	add    $0x1c,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
  801db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 fe                	sub    %edi,%esi
  801dc2:	19 c3                	sbb    %eax,%ebx
  801dc4:	89 f2                	mov    %esi,%edx
  801dc6:	89 d9                	mov    %ebx,%ecx
  801dc8:	e9 1d ff ff ff       	jmp    801cea <__umoddi3+0x6a>
