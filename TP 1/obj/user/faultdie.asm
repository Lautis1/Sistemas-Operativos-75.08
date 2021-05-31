
obj/user/faultdie.debug:     formato del fichero elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800040:	8b 42 04             	mov    0x4(%edx),%eax
  800043:	83 e0 07             	and    $0x7,%eax
  800046:	50                   	push   %eax
  800047:	ff 32                	pushl  (%edx)
  800049:	68 a0 1e 80 00       	push   $0x801ea0
  80004e:	e8 3e 01 00 00       	call   800191 <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 d8 0a 00 00       	call   800b30 <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 aa 0a 00 00       	call   800b0a <sys_env_destroy>
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	f3 0f 1e fb          	endbr32 
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80006f:	68 33 00 80 00       	push   $0x800033
  800074:	e8 47 0c 00 00       	call   800cc0 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800079:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800080:	00 00 00 
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800097:	e8 94 0a 00 00       	call   800b30 <sys_getenvid>
	if (id >= 0)
  80009c:	85 c0                	test   %eax,%eax
  80009e:	78 12                	js     8000b2 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ad:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b2:	85 db                	test   %ebx,%ebx
  8000b4:	7e 07                	jle    8000bd <libmain+0x35>
		binaryname = argv[0];
  8000b6:	8b 06                	mov    (%esi),%eax
  8000b8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	e8 9e ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000c7:	e8 0a 00 00 00       	call   8000d6 <exit>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e0:	e8 51 0e 00 00       	call   800f36 <close_all>
	sys_env_destroy(0);
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	6a 00                	push   $0x0
  8000ea:	e8 1b 0a 00 00       	call   800b0a <sys_env_destroy>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f4:	f3 0f 1e fb          	endbr32 
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 04             	sub    $0x4,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 13                	mov    (%ebx),%edx
  800104:	8d 42 01             	lea    0x1(%edx),%eax
  800107:	89 03                	mov    %eax,(%ebx)
  800109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	74 09                	je     800120 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800117:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 87 09 00 00       	call   800ab8 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	eb db                	jmp    800117 <putch+0x23>

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	f3 0f 1e fb          	endbr32 
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	68 f4 00 80 00       	push   $0x8000f4
  80016f:	e8 80 01 00 00       	call   8002f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800174:	83 c4 08             	add    $0x8,%esp
  800177:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800183:	50                   	push   %eax
  800184:	e8 2f 09 00 00       	call   800ab8 <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	f3 0f 1e fb          	endbr32 
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019e:	50                   	push   %eax
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	e8 95 ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 1c             	sub    $0x1c,%esp
  8001b2:	89 c7                	mov    %eax,%edi
  8001b4:	89 d6                	mov    %edx,%esi
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bc:	89 d1                	mov    %edx,%ecx
  8001be:	89 c2                	mov    %eax,%edx
  8001c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d6:	39 c2                	cmp    %eax,%edx
  8001d8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001db:	72 3e                	jb     80021b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	pushl  0x18(%ebp)
  8001e3:	83 eb 01             	sub    $0x1,%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	50                   	push   %eax
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 34 1a 00 00       	call   801c30 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9f ff ff ff       	call   8001a9 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 13                	jmp    800222 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	85 db                	test   %ebx,%ebx
  800220:	7f ed                	jg     80020f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022c:	ff 75 e0             	pushl  -0x20(%ebp)
  80022f:	ff 75 dc             	pushl  -0x24(%ebp)
  800232:	ff 75 d8             	pushl  -0x28(%ebp)
  800235:	e8 06 1b 00 00       	call   801d40 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 c6 1e 80 00 	movsbl 0x801ec6(%eax),%eax
  800244:	50                   	push   %eax
  800245:	ff d7                	call   *%edi
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7f 13                	jg     80026a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800257:	85 d2                	test   %edx,%edx
  800259:	74 1c                	je     800277 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 02                	mov    (%edx),%eax
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
  800269:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	8b 52 04             	mov    0x4(%edx),%edx
  800276:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800285:	c3                   	ret    

00800286 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800286:	83 fa 01             	cmp    $0x1,%edx
  800289:	7f 0f                	jg     80029a <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 18                	je     8002a7 <getint+0x21>
		return va_arg(*ap, long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	99                   	cltd   
  800299:	c3                   	ret    
		return va_arg(*ap, long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	99                   	cltd   
}
  8002b1:	c3                   	ret    

008002b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b2:	f3 0f 1e fb          	endbr32 
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c5:	73 0a                	jae    8002d1 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	88 02                	mov    %al,(%edx)
}
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <printfmt>:
{
  8002d3:	f3 0f 1e fb          	endbr32 
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e0:	50                   	push   %eax
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	ff 75 0c             	pushl  0xc(%ebp)
  8002e7:	ff 75 08             	pushl  0x8(%ebp)
  8002ea:	e8 05 00 00 00       	call   8002f4 <vprintfmt>
}
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <vprintfmt>:
{
  8002f4:	f3 0f 1e fb          	endbr32 
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 2c             	sub    $0x2c,%esp
  800301:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800304:	8b 75 0c             	mov    0xc(%ebp),%esi
  800307:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030a:	e9 86 02 00 00       	jmp    800595 <vprintfmt+0x2a1>
		padc = ' ';
  80030f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800313:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80031a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800321:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800328:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8d 47 01             	lea    0x1(%edi),%eax
  800330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800333:	0f b6 17             	movzbl (%edi),%edx
  800336:	8d 42 dd             	lea    -0x23(%edx),%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 df 02 00 00    	ja     800620 <vprintfmt+0x32c>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	3e ff 24 85 00 20 80 	notrack jmp *0x802000(,%eax,4)
  80034b:	00 
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800353:	eb d8                	jmp    80032d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80035c:	eb cf                	jmp    80032d <vprintfmt+0x39>
  80035e:	0f b6 d2             	movzbl %dl,%edx
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800364:	b8 00 00 00 00       	mov    $0x0,%eax
  800369:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800373:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800376:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800379:	83 f9 09             	cmp    $0x9,%ecx
  80037c:	77 52                	ja     8003d0 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80037e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800381:	eb e9                	jmp    80036c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 50 04             	lea    0x4(%eax),%edx
  800389:	89 55 14             	mov    %edx,0x14(%ebp)
  80038c:	8b 00                	mov    (%eax),%eax
  80038e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800394:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800398:	79 93                	jns    80032d <vprintfmt+0x39>
				width = precision, precision = -1;
  80039a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a7:	eb 84                	jmp    80032d <vprintfmt+0x39>
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	0f 49 d0             	cmovns %eax,%edx
  8003b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bc:	e9 6c ff ff ff       	jmp    80032d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003cb:	e9 5d ff ff ff       	jmp    80032d <vprintfmt+0x39>
  8003d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d6:	eb bc                	jmp    800394 <vprintfmt+0xa0>
			lflag++;
  8003d8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003de:	e9 4a ff ff ff       	jmp    80032d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 50 04             	lea    0x4(%eax),%edx
  8003e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 30                	pushl  (%eax)
  8003f2:	ff d3                	call   *%ebx
			break;
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	e9 96 01 00 00       	jmp    800592 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	99                   	cltd   
  800408:	31 d0                	xor    %edx,%eax
  80040a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040c:	83 f8 0f             	cmp    $0xf,%eax
  80040f:	7f 20                	jg     800431 <vprintfmt+0x13d>
  800411:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  800418:	85 d2                	test   %edx,%edx
  80041a:	74 15                	je     800431 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80041c:	52                   	push   %edx
  80041d:	68 b9 22 80 00       	push   $0x8022b9
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	e8 aa fe ff ff       	call   8002d3 <printfmt>
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	e9 61 01 00 00       	jmp    800592 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800431:	50                   	push   %eax
  800432:	68 de 1e 80 00       	push   $0x801ede
  800437:	56                   	push   %esi
  800438:	53                   	push   %ebx
  800439:	e8 95 fe ff ff       	call   8002d3 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	e9 4c 01 00 00       	jmp    800592 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800451:	85 c9                	test   %ecx,%ecx
  800453:	b8 d7 1e 80 00       	mov    $0x801ed7,%eax
  800458:	0f 45 c1             	cmovne %ecx,%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	7e 06                	jle    80046a <vprintfmt+0x176>
  800464:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800468:	75 0d                	jne    800477 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046d:	89 c7                	mov    %eax,%edi
  80046f:	03 45 e0             	add    -0x20(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	eb 57                	jmp    8004ce <vprintfmt+0x1da>
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 d8             	pushl  -0x28(%ebp)
  80047d:	ff 75 cc             	pushl  -0x34(%ebp)
  800480:	e8 4f 02 00 00       	call   8006d4 <strnlen>
  800485:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800488:	29 c2                	sub    %eax,%edx
  80048a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800490:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800494:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800497:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	85 db                	test   %ebx,%ebx
  80049b:	7e 10                	jle    8004ad <vprintfmt+0x1b9>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	57                   	push   %edi
  8004a2:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	eb ec                	jmp    800499 <vprintfmt+0x1a5>
  8004ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	0f 49 c2             	cmovns %edx,%eax
  8004bd:	29 c2                	sub    %eax,%edx
  8004bf:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c2:	eb a6                	jmp    80046a <vprintfmt+0x176>
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	56                   	push   %esi
  8004c8:	52                   	push   %edx
  8004c9:	ff d3                	call   *%ebx
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d3:	83 c7 01             	add    $0x1,%edi
  8004d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004da:	0f be d0             	movsbl %al,%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	74 42                	je     800523 <vprintfmt+0x22f>
  8004e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e5:	78 06                	js     8004ed <vprintfmt+0x1f9>
  8004e7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004eb:	78 1e                	js     80050b <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f1:	74 d1                	je     8004c4 <vprintfmt+0x1d0>
  8004f3:	0f be c0             	movsbl %al,%eax
  8004f6:	83 e8 20             	sub    $0x20,%eax
  8004f9:	83 f8 5e             	cmp    $0x5e,%eax
  8004fc:	76 c6                	jbe    8004c4 <vprintfmt+0x1d0>
					putch('?', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	56                   	push   %esi
  800502:	6a 3f                	push   $0x3f
  800504:	ff d3                	call   *%ebx
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb c3                	jmp    8004ce <vprintfmt+0x1da>
  80050b:	89 cf                	mov    %ecx,%edi
  80050d:	eb 0e                	jmp    80051d <vprintfmt+0x229>
				putch(' ', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	56                   	push   %esi
  800513:	6a 20                	push   $0x20
  800515:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800517:	83 ef 01             	sub    $0x1,%edi
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 ff                	test   %edi,%edi
  80051f:	7f ee                	jg     80050f <vprintfmt+0x21b>
  800521:	eb 6f                	jmp    800592 <vprintfmt+0x29e>
  800523:	89 cf                	mov    %ecx,%edi
  800525:	eb f6                	jmp    80051d <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800527:	89 ca                	mov    %ecx,%edx
  800529:	8d 45 14             	lea    0x14(%ebp),%eax
  80052c:	e8 55 fd ff ff       	call   800286 <getint>
  800531:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800534:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800537:	85 d2                	test   %edx,%edx
  800539:	78 0b                	js     800546 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80053b:	89 d1                	mov    %edx,%ecx
  80053d:	89 c2                	mov    %eax,%edx
			base = 10;
  80053f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800544:	eb 32                	jmp    800578 <vprintfmt+0x284>
				putch('-', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	56                   	push   %esi
  80054a:	6a 2d                	push   $0x2d
  80054c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80054e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800551:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800554:	f7 da                	neg    %edx
  800556:	83 d1 00             	adc    $0x0,%ecx
  800559:	f7 d9                	neg    %ecx
  80055b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	eb 13                	jmp    800578 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800565:	89 ca                	mov    %ecx,%edx
  800567:	8d 45 14             	lea    0x14(%ebp),%eax
  80056a:	e8 e3 fc ff ff       	call   800252 <getuint>
  80056f:	89 d1                	mov    %edx,%ecx
  800571:	89 c2                	mov    %eax,%edx
			base = 10;
  800573:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80057f:	57                   	push   %edi
  800580:	ff 75 e0             	pushl  -0x20(%ebp)
  800583:	50                   	push   %eax
  800584:	51                   	push   %ecx
  800585:	52                   	push   %edx
  800586:	89 f2                	mov    %esi,%edx
  800588:	89 d8                	mov    %ebx,%eax
  80058a:	e8 1a fc ff ff       	call   8001a9 <printnum>
			break;
  80058f:	83 c4 20             	add    $0x20,%esp
{
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800595:	83 c7 01             	add    $0x1,%edi
  800598:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059c:	83 f8 25             	cmp    $0x25,%eax
  80059f:	0f 84 6a fd ff ff    	je     80030f <vprintfmt+0x1b>
			if (ch == '\0')
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	0f 84 93 00 00 00    	je     800640 <vprintfmt+0x34c>
			putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	56                   	push   %esi
  8005b1:	50                   	push   %eax
  8005b2:	ff d3                	call   *%ebx
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb dc                	jmp    800595 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005b9:	89 ca                	mov    %ecx,%edx
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 8f fc ff ff       	call   800252 <getuint>
  8005c3:	89 d1                	mov    %edx,%ecx
  8005c5:	89 c2                	mov    %eax,%edx
			base = 8;
  8005c7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005cc:	eb aa                	jmp    800578 <vprintfmt+0x284>
			putch('0', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	56                   	push   %esi
  8005d2:	6a 30                	push   $0x30
  8005d4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	56                   	push   %esi
  8005da:	6a 78                	push   $0x78
  8005dc:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ee:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005f1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f6:	eb 80                	jmp    800578 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005f8:	89 ca                	mov    %ecx,%edx
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 50 fc ff ff       	call   800252 <getuint>
  800602:	89 d1                	mov    %edx,%ecx
  800604:	89 c2                	mov    %eax,%edx
			base = 16;
  800606:	b8 10 00 00 00       	mov    $0x10,%eax
  80060b:	e9 68 ff ff ff       	jmp    800578 <vprintfmt+0x284>
			putch(ch, putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	6a 25                	push   $0x25
  800616:	ff d3                	call   *%ebx
			break;
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	e9 72 ff ff ff       	jmp    800592 <vprintfmt+0x29e>
			putch('%', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	56                   	push   %esi
  800624:	6a 25                	push   $0x25
  800626:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	89 f8                	mov    %edi,%eax
  80062d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800631:	74 05                	je     800638 <vprintfmt+0x344>
  800633:	83 e8 01             	sub    $0x1,%eax
  800636:	eb f5                	jmp    80062d <vprintfmt+0x339>
  800638:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063b:	e9 52 ff ff ff       	jmp    800592 <vprintfmt+0x29e>
}
  800640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5f                   	pop    %edi
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800648:	f3 0f 1e fb          	endbr32 
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 26                	je     800693 <vsnprintf+0x4b>
  80066d:	85 d2                	test   %edx,%edx
  80066f:	7e 22                	jle    800693 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800671:	ff 75 14             	pushl  0x14(%ebp)
  800674:	ff 75 10             	pushl  0x10(%ebp)
  800677:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	68 b2 02 80 00       	push   $0x8002b2
  800680:	e8 6f fc ff ff       	call   8002f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800688:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	83 c4 10             	add    $0x10,%esp
}
  800691:	c9                   	leave  
  800692:	c3                   	ret    
		return -E_INVAL;
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800698:	eb f7                	jmp    800691 <vsnprintf+0x49>

0080069a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069a:	f3 0f 1e fb          	endbr32 
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a7:	50                   	push   %eax
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	ff 75 08             	pushl  0x8(%ebp)
  8006b1:	e8 92 ff ff ff       	call   800648 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b8:	f3 0f 1e fb          	endbr32 
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cb:	74 05                	je     8006d2 <strlen+0x1a>
		n++;
  8006cd:	83 c0 01             	add    $0x1,%eax
  8006d0:	eb f5                	jmp    8006c7 <strlen+0xf>
	return n;
}
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d4:	f3 0f 1e fb          	endbr32 
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	39 d0                	cmp    %edx,%eax
  8006e8:	74 0d                	je     8006f7 <strnlen+0x23>
  8006ea:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006ee:	74 05                	je     8006f5 <strnlen+0x21>
		n++;
  8006f0:	83 c0 01             	add    $0x1,%eax
  8006f3:	eb f1                	jmp    8006e6 <strnlen+0x12>
  8006f5:	89 c2                	mov    %eax,%edx
	return n;
}
  8006f7:	89 d0                	mov    %edx,%eax
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fb:	f3 0f 1e fb          	endbr32 
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	53                   	push   %ebx
  800703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800709:	b8 00 00 00 00       	mov    $0x0,%eax
  80070e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800712:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800715:	83 c0 01             	add    $0x1,%eax
  800718:	84 d2                	test   %dl,%dl
  80071a:	75 f2                	jne    80070e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80071c:	89 c8                	mov    %ecx,%eax
  80071e:	5b                   	pop    %ebx
  80071f:	5d                   	pop    %ebp
  800720:	c3                   	ret    

00800721 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800721:	f3 0f 1e fb          	endbr32 
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	83 ec 10             	sub    $0x10,%esp
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072f:	53                   	push   %ebx
  800730:	e8 83 ff ff ff       	call   8006b8 <strlen>
  800735:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	01 d8                	add    %ebx,%eax
  80073d:	50                   	push   %eax
  80073e:	e8 b8 ff ff ff       	call   8006fb <strcpy>
	return dst;
}
  800743:	89 d8                	mov    %ebx,%eax
  800745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074a:	f3 0f 1e fb          	endbr32 
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
  800753:	8b 75 08             	mov    0x8(%ebp),%esi
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
  800759:	89 f3                	mov    %esi,%ebx
  80075b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075e:	89 f0                	mov    %esi,%eax
  800760:	39 d8                	cmp    %ebx,%eax
  800762:	74 11                	je     800775 <strncpy+0x2b>
		*dst++ = *src;
  800764:	83 c0 01             	add    $0x1,%eax
  800767:	0f b6 0a             	movzbl (%edx),%ecx
  80076a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076d:	80 f9 01             	cmp    $0x1,%cl
  800770:	83 da ff             	sbb    $0xffffffff,%edx
  800773:	eb eb                	jmp    800760 <strncpy+0x16>
	}
	return ret;
}
  800775:	89 f0                	mov    %esi,%eax
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077b:	f3 0f 1e fb          	endbr32 
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078a:	8b 55 10             	mov    0x10(%ebp),%edx
  80078d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078f:	85 d2                	test   %edx,%edx
  800791:	74 21                	je     8007b4 <strlcpy+0x39>
  800793:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800797:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800799:	39 c2                	cmp    %eax,%edx
  80079b:	74 14                	je     8007b1 <strlcpy+0x36>
  80079d:	0f b6 19             	movzbl (%ecx),%ebx
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	74 0b                	je     8007af <strlcpy+0x34>
			*dst++ = *src++;
  8007a4:	83 c1 01             	add    $0x1,%ecx
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	eb ea                	jmp    800799 <strlcpy+0x1e>
  8007af:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b4:	29 f0                	sub    %esi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	f3 0f 1e fb          	endbr32 
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c7:	0f b6 01             	movzbl (%ecx),%eax
  8007ca:	84 c0                	test   %al,%al
  8007cc:	74 0c                	je     8007da <strcmp+0x20>
  8007ce:	3a 02                	cmp    (%edx),%al
  8007d0:	75 08                	jne    8007da <strcmp+0x20>
		p++, q++;
  8007d2:	83 c1 01             	add    $0x1,%ecx
  8007d5:	83 c2 01             	add    $0x1,%edx
  8007d8:	eb ed                	jmp    8007c7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007da:	0f b6 c0             	movzbl %al,%eax
  8007dd:	0f b6 12             	movzbl (%edx),%edx
  8007e0:	29 d0                	sub    %edx,%eax
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e4:	f3 0f 1e fb          	endbr32 
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 c3                	mov    %eax,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strncmp+0x1b>
		n--, p++, q++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007ff:	39 d8                	cmp    %ebx,%eax
  800801:	74 16                	je     800819 <strncmp+0x35>
  800803:	0f b6 08             	movzbl (%eax),%ecx
  800806:	84 c9                	test   %cl,%cl
  800808:	74 04                	je     80080e <strncmp+0x2a>
  80080a:	3a 0a                	cmp    (%edx),%cl
  80080c:	74 eb                	je     8007f9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 00             	movzbl (%eax),%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
  80081e:	eb f6                	jmp    800816 <strncmp+0x32>

00800820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082e:	0f b6 10             	movzbl (%eax),%edx
  800831:	84 d2                	test   %dl,%dl
  800833:	74 09                	je     80083e <strchr+0x1e>
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 0a                	je     800843 <strchr+0x23>
	for (; *s; s++)
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	eb f0                	jmp    80082e <strchr+0xe>
			return (char *) s;
	return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800853:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800856:	38 ca                	cmp    %cl,%dl
  800858:	74 09                	je     800863 <strfind+0x1e>
  80085a:	84 d2                	test   %dl,%dl
  80085c:	74 05                	je     800863 <strfind+0x1e>
	for (; *s; s++)
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	eb f0                	jmp    800853 <strfind+0xe>
			break;
	return (char *) s;
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800865:	f3 0f 1e fb          	endbr32 
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	57                   	push   %edi
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 55 08             	mov    0x8(%ebp),%edx
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 33                	je     8008ac <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800879:	89 d0                	mov    %edx,%eax
  80087b:	09 c8                	or     %ecx,%eax
  80087d:	a8 03                	test   $0x3,%al
  80087f:	75 23                	jne    8008a4 <memset+0x3f>
		c &= 0xFF;
  800881:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800885:	89 d8                	mov    %ebx,%eax
  800887:	c1 e0 08             	shl    $0x8,%eax
  80088a:	89 df                	mov    %ebx,%edi
  80088c:	c1 e7 18             	shl    $0x18,%edi
  80088f:	89 de                	mov    %ebx,%esi
  800891:	c1 e6 10             	shl    $0x10,%esi
  800894:	09 f7                	or     %esi,%edi
  800896:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800898:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80089d:	89 d7                	mov    %edx,%edi
  80089f:	fc                   	cld    
  8008a0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a2:	eb 08                	jmp    8008ac <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a4:	89 d7                	mov    %edx,%edi
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a9:	fc                   	cld    
  8008aa:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008ac:	89 d0                	mov    %edx,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b3:	f3 0f 1e fb          	endbr32 
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c5:	39 c6                	cmp    %eax,%esi
  8008c7:	73 32                	jae    8008fb <memmove+0x48>
  8008c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cc:	39 c2                	cmp    %eax,%edx
  8008ce:	76 2b                	jbe    8008fb <memmove+0x48>
		s += n;
		d += n;
  8008d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d3:	89 fe                	mov    %edi,%esi
  8008d5:	09 ce                	or     %ecx,%esi
  8008d7:	09 d6                	or     %edx,%esi
  8008d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008df:	75 0e                	jne    8008ef <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e1:	83 ef 04             	sub    $0x4,%edi
  8008e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008ea:	fd                   	std    
  8008eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ed:	eb 09                	jmp    8008f8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ef:	83 ef 01             	sub    $0x1,%edi
  8008f2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f5:	fd                   	std    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f8:	fc                   	cld    
  8008f9:	eb 1a                	jmp    800915 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	09 ca                	or     %ecx,%edx
  8008ff:	09 f2                	or     %esi,%edx
  800901:	f6 c2 03             	test   $0x3,%dl
  800904:	75 0a                	jne    800910 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800906:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 05                	jmp    800915 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800910:	89 c7                	mov    %eax,%edi
  800912:	fc                   	cld    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800919:	f3 0f 1e fb          	endbr32 
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800923:	ff 75 10             	pushl  0x10(%ebp)
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	ff 75 08             	pushl  0x8(%ebp)
  80092c:	e8 82 ff ff ff       	call   8008b3 <memmove>
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800933:	f3 0f 1e fb          	endbr32 
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	89 c6                	mov    %eax,%esi
  800944:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	39 f0                	cmp    %esi,%eax
  800949:	74 1c                	je     800967 <memcmp+0x34>
		if (*s1 != *s2)
  80094b:	0f b6 08             	movzbl (%eax),%ecx
  80094e:	0f b6 1a             	movzbl (%edx),%ebx
  800951:	38 d9                	cmp    %bl,%cl
  800953:	75 08                	jne    80095d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	83 c2 01             	add    $0x1,%edx
  80095b:	eb ea                	jmp    800947 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80095d:	0f b6 c1             	movzbl %cl,%eax
  800960:	0f b6 db             	movzbl %bl,%ebx
  800963:	29 d8                	sub    %ebx,%eax
  800965:	eb 05                	jmp    80096c <memcmp+0x39>
	}

	return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800970:	f3 0f 1e fb          	endbr32 
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800982:	39 d0                	cmp    %edx,%eax
  800984:	73 09                	jae    80098f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800986:	38 08                	cmp    %cl,(%eax)
  800988:	74 05                	je     80098f <memfind+0x1f>
	for (; s < ends; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	eb f3                	jmp    800982 <memfind+0x12>
			break;
	return (void *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800991:	f3 0f 1e fb          	endbr32 
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a1:	eb 03                	jmp    8009a6 <strtol+0x15>
		s++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009a6:	0f b6 01             	movzbl (%ecx),%eax
  8009a9:	3c 20                	cmp    $0x20,%al
  8009ab:	74 f6                	je     8009a3 <strtol+0x12>
  8009ad:	3c 09                	cmp    $0x9,%al
  8009af:	74 f2                	je     8009a3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009b1:	3c 2b                	cmp    $0x2b,%al
  8009b3:	74 2a                	je     8009df <strtol+0x4e>
	int neg = 0;
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ba:	3c 2d                	cmp    $0x2d,%al
  8009bc:	74 2b                	je     8009e9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009be:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c4:	75 0f                	jne    8009d5 <strtol+0x44>
  8009c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c9:	74 28                	je     8009f3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d2:	0f 44 d8             	cmove  %eax,%ebx
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009dd:	eb 46                	jmp    800a25 <strtol+0x94>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb d5                	jmp    8009be <strtol+0x2d>
		s++, neg = 1;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f1:	eb cb                	jmp    8009be <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f7:	74 0e                	je     800a07 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	75 d8                	jne    8009d5 <strtol+0x44>
		s++, base = 8;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a05:	eb ce                	jmp    8009d5 <strtol+0x44>
		s += 2, base = 16;
  800a07:	83 c1 02             	add    $0x2,%ecx
  800a0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0f:	eb c4                	jmp    8009d5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a11:	0f be d2             	movsbl %dl,%edx
  800a14:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a17:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a1a:	7d 3a                	jge    800a56 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a23:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a25:	0f b6 11             	movzbl (%ecx),%edx
  800a28:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 09             	cmp    $0x9,%bl
  800a30:	76 df                	jbe    800a11 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a35:	89 f3                	mov    %esi,%ebx
  800a37:	80 fb 19             	cmp    $0x19,%bl
  800a3a:	77 08                	ja     800a44 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a3c:	0f be d2             	movsbl %dl,%edx
  800a3f:	83 ea 57             	sub    $0x57,%edx
  800a42:	eb d3                	jmp    800a17 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a44:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a47:	89 f3                	mov    %esi,%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a4e:	0f be d2             	movsbl %dl,%edx
  800a51:	83 ea 37             	sub    $0x37,%edx
  800a54:	eb c1                	jmp    800a17 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5a:	74 05                	je     800a61 <strtol+0xd0>
		*endptr = (char *) s;
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a61:	89 c2                	mov    %eax,%edx
  800a63:	f7 da                	neg    %edx
  800a65:	85 ff                	test   %edi,%edi
  800a67:	0f 45 c2             	cmovne %edx,%eax
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 1c             	sub    $0x1c,%esp
  800a78:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a7e:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a86:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a89:	8b 75 14             	mov    0x14(%ebp),%esi
  800a8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a92:	74 04                	je     800a98 <syscall+0x29>
  800a94:	85 c0                	test   %eax,%eax
  800a96:	7f 08                	jg     800aa0 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	50                   	push   %eax
  800aa4:	ff 75 e0             	pushl  -0x20(%ebp)
  800aa7:	68 bf 21 80 00       	push   $0x8021bf
  800aac:	6a 23                	push   $0x23
  800aae:	68 dc 21 80 00       	push   $0x8021dc
  800ab3:	e8 d4 0f 00 00       	call   801a8c <_panic>

00800ab8 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ac2:	6a 00                	push   $0x0
  800ac4:	6a 00                	push   $0x0
  800ac6:	6a 00                	push   $0x0
  800ac8:	ff 75 0c             	pushl  0xc(%ebp)
  800acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	e8 92 ff ff ff       	call   800a6f <syscall>
}
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	f3 0f 1e fb          	endbr32 
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800aec:	6a 00                	push   $0x0
  800aee:	6a 00                	push   $0x0
  800af0:	6a 00                	push   $0x0
  800af2:	6a 00                	push   $0x0
  800af4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 01 00 00 00       	mov    $0x1,%eax
  800b03:	e8 67 ff ff ff       	call   800a6f <syscall>
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0a:	f3 0f 1e fb          	endbr32 
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b14:	6a 00                	push   $0x0
  800b16:	6a 00                	push   $0x0
  800b18:	6a 00                	push   $0x0
  800b1a:	6a 00                	push   $0x0
  800b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b24:	b8 03 00 00 00       	mov    $0x3,%eax
  800b29:	e8 41 ff ff ff       	call   800a6f <syscall>
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b30:	f3 0f 1e fb          	endbr32 
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b3a:	6a 00                	push   $0x0
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	6a 00                	push   $0x0
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b51:	e8 19 ff ff ff       	call   800a6f <syscall>
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <sys_yield>:

void
sys_yield(void)
{
  800b58:	f3 0f 1e fb          	endbr32 
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b62:	6a 00                	push   $0x0
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b79:	e8 f1 fe ff ff       	call   800a6f <syscall>
}
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	f3 0f 1e fb          	endbr32 
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	ff 75 10             	pushl  0x10(%ebp)
  800b94:	ff 75 0c             	pushl  0xc(%ebp)
  800b97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba4:	e8 c6 fe ff ff       	call   800a6f <syscall>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bb5:	ff 75 18             	pushl  0x18(%ebp)
  800bb8:	ff 75 14             	pushl  0x14(%ebp)
  800bbb:	ff 75 10             	pushl  0x10(%ebp)
  800bbe:	ff 75 0c             	pushl  0xc(%ebp)
  800bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bce:	e8 9c fe ff ff       	call   800a6f <syscall>
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd5:	f3 0f 1e fb          	endbr32 
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	ff 75 0c             	pushl  0xc(%ebp)
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf5:	e8 75 fe ff ff       	call   800a6f <syscall>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfc:	f3 0f 1e fb          	endbr32 
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c06:	6a 00                	push   $0x0
  800c08:	6a 00                	push   $0x0
  800c0a:	6a 00                	push   $0x0
  800c0c:	ff 75 0c             	pushl  0xc(%ebp)
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	ba 01 00 00 00       	mov    $0x1,%edx
  800c17:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1c:	e8 4e fe ff ff       	call   800a6f <syscall>
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c23:	f3 0f 1e fb          	endbr32 
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c39:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c43:	e8 27 fe ff ff       	call   800a6f <syscall>
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4a:	f3 0f 1e fb          	endbr32 
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	ff 75 0c             	pushl  0xc(%ebp)
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	ba 01 00 00 00       	mov    $0x1,%edx
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6a:	e8 00 fe ff ff       	call   800a6f <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c7b:	6a 00                	push   $0x0
  800c7d:	ff 75 14             	pushl  0x14(%ebp)
  800c80:	ff 75 10             	pushl  0x10(%ebp)
  800c83:	ff 75 0c             	pushl  0xc(%ebp)
  800c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c93:	e8 d7 fd ff ff       	call   800a6f <syscall>
}
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c9a:	f3 0f 1e fb          	endbr32 
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ca4:	6a 00                	push   $0x0
  800ca6:	6a 00                	push   $0x0
  800ca8:	6a 00                	push   $0x0
  800caa:	6a 00                	push   $0x0
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb9:	e8 b1 fd ff ff       	call   800a6f <syscall>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cca:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800cd1:	74 1c                	je     800cef <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	a3 08 40 80 00       	mov    %eax,0x804008

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  800cdb:	83 ec 08             	sub    $0x8,%esp
  800cde:	68 1b 0d 80 00       	push   $0x800d1b
  800ce3:	6a 00                	push   $0x0
  800ce5:	e8 60 ff ff ff       	call   800c4a <sys_env_set_pgfault_upcall>
}
  800cea:	83 c4 10             	add    $0x10,%esp
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  800cef:	83 ec 04             	sub    $0x4,%esp
  800cf2:	6a 02                	push   $0x2
  800cf4:	68 00 f0 bf ee       	push   $0xeebff000
  800cf9:	6a 00                	push   $0x0
  800cfb:	e8 83 fe ff ff       	call   800b83 <sys_page_alloc>
  800d00:	83 c4 10             	add    $0x10,%esp
  800d03:	85 c0                	test   %eax,%eax
  800d05:	79 cc                	jns    800cd3 <set_pgfault_handler+0x13>
  800d07:	83 ec 04             	sub    $0x4,%esp
  800d0a:	68 ea 21 80 00       	push   $0x8021ea
  800d0f:	6a 20                	push   $0x20
  800d11:	68 05 22 80 00       	push   $0x802205
  800d16:	e8 71 0d 00 00       	call   801a8c <_panic>

00800d1b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d1b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d1c:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d21:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d23:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  800d26:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  800d2a:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800d2e:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  800d31:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  800d33:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800d37:	83 c4 08             	add    $0x8,%esp
	popal
  800d3a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800d3b:	83 c4 04             	add    $0x4,%esp
	popfl
  800d3e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800d3f:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800d42:	c3                   	ret    

00800d43 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d43:	f3 0f 1e fb          	endbr32 
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d52:	c1 e8 0c             	shr    $0xc,%eax
}
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d57:	f3 0f 1e fb          	endbr32 
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800d61:	ff 75 08             	pushl  0x8(%ebp)
  800d64:	e8 da ff ff ff       	call   800d43 <fd2num>
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	c1 e0 0c             	shl    $0xc,%eax
  800d6f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d76:	f3 0f 1e fb          	endbr32 
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	c1 ea 16             	shr    $0x16,%edx
  800d87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8e:	f6 c2 01             	test   $0x1,%dl
  800d91:	74 2d                	je     800dc0 <fd_alloc+0x4a>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 0c             	shr    $0xc,%edx
  800d98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9f:	f6 c2 01             	test   $0x1,%dl
  800da2:	74 1c                	je     800dc0 <fd_alloc+0x4a>
  800da4:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800da9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dae:	75 d2                	jne    800d82 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800db9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dbe:	eb 0a                	jmp    800dca <fd_alloc+0x54>
			*fd_store = fd;
  800dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dcc:	f3 0f 1e fb          	endbr32 
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd6:	83 f8 1f             	cmp    $0x1f,%eax
  800dd9:	77 30                	ja     800e0b <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ddb:	c1 e0 0c             	shl    $0xc,%eax
  800dde:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de3:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800de9:	f6 c2 01             	test   $0x1,%dl
  800dec:	74 24                	je     800e12 <fd_lookup+0x46>
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	c1 ea 0c             	shr    $0xc,%edx
  800df3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfa:	f6 c2 01             	test   $0x1,%dl
  800dfd:	74 1a                	je     800e19 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e02:	89 02                	mov    %eax,(%edx)
	return 0;
  800e04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
		return -E_INVAL;
  800e0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e10:	eb f7                	jmp    800e09 <fd_lookup+0x3d>
		return -E_INVAL;
  800e12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e17:	eb f0                	jmp    800e09 <fd_lookup+0x3d>
  800e19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1e:	eb e9                	jmp    800e09 <fd_lookup+0x3d>

00800e20 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	ba 90 22 80 00       	mov    $0x802290,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e32:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e37:	39 08                	cmp    %ecx,(%eax)
  800e39:	74 33                	je     800e6e <dev_lookup+0x4e>
  800e3b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e3e:	8b 02                	mov    (%edx),%eax
  800e40:	85 c0                	test   %eax,%eax
  800e42:	75 f3                	jne    800e37 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e44:	a1 04 40 80 00       	mov    0x804004,%eax
  800e49:	8b 40 48             	mov    0x48(%eax),%eax
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	51                   	push   %ecx
  800e50:	50                   	push   %eax
  800e51:	68 14 22 80 00       	push   $0x802214
  800e56:	e8 36 f3 ff ff       	call   800191 <cprintf>
	*dev = 0;
  800e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    
			*dev = devtab[i];
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e73:	b8 00 00 00 00       	mov    $0x0,%eax
  800e78:	eb f2                	jmp    800e6c <dev_lookup+0x4c>

00800e7a <fd_close>:
{
  800e7a:	f3 0f 1e fb          	endbr32 
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 28             	sub    $0x28,%esp
  800e87:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8d:	56                   	push   %esi
  800e8e:	e8 b0 fe ff ff       	call   800d43 <fd2num>
  800e93:	83 c4 08             	add    $0x8,%esp
  800e96:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800e99:	52                   	push   %edx
  800e9a:	50                   	push   %eax
  800e9b:	e8 2c ff ff ff       	call   800dcc <fd_lookup>
  800ea0:	89 c3                	mov    %eax,%ebx
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 05                	js     800eae <fd_close+0x34>
	    || fd != fd2)
  800ea9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eac:	74 16                	je     800ec4 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800eae:	89 f8                	mov    %edi,%eax
  800eb0:	84 c0                	test   %al,%al
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	0f 44 d8             	cmove  %eax,%ebx
}
  800eba:	89 d8                	mov    %ebx,%eax
  800ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800eca:	50                   	push   %eax
  800ecb:	ff 36                	pushl  (%esi)
  800ecd:	e8 4e ff ff ff       	call   800e20 <dev_lookup>
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 1a                	js     800ef5 <fd_close+0x7b>
		if (dev->dev_close)
  800edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ede:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	74 0b                	je     800ef5 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	56                   	push   %esi
  800eee:	ff d0                	call   *%eax
  800ef0:	89 c3                	mov    %eax,%ebx
  800ef2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	56                   	push   %esi
  800ef9:	6a 00                	push   $0x0
  800efb:	e8 d5 fc ff ff       	call   800bd5 <sys_page_unmap>
	return r;
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	eb b5                	jmp    800eba <fd_close+0x40>

00800f05 <close>:

int
close(int fdnum)
{
  800f05:	f3 0f 1e fb          	endbr32 
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	ff 75 08             	pushl  0x8(%ebp)
  800f16:	e8 b1 fe ff ff       	call   800dcc <fd_lookup>
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	79 02                	jns    800f24 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    
		return fd_close(fd, 1);
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	6a 01                	push   $0x1
  800f29:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2c:	e8 49 ff ff ff       	call   800e7a <fd_close>
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	eb ec                	jmp    800f22 <close+0x1d>

00800f36 <close_all>:

void
close_all(void)
{
  800f36:	f3 0f 1e fb          	endbr32 
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f41:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	53                   	push   %ebx
  800f4a:	e8 b6 ff ff ff       	call   800f05 <close>
	for (i = 0; i < MAXFD; i++)
  800f4f:	83 c3 01             	add    $0x1,%ebx
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	83 fb 20             	cmp    $0x20,%ebx
  800f58:	75 ec                	jne    800f46 <close_all+0x10>
}
  800f5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f5f:	f3 0f 1e fb          	endbr32 
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f6c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 75 08             	pushl  0x8(%ebp)
  800f73:	e8 54 fe ff ff       	call   800dcc <fd_lookup>
  800f78:	89 c3                	mov    %eax,%ebx
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	0f 88 81 00 00 00    	js     801006 <dup+0xa7>
		return r;
	close(newfdnum);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	ff 75 0c             	pushl  0xc(%ebp)
  800f8b:	e8 75 ff ff ff       	call   800f05 <close>

	newfd = INDEX2FD(newfdnum);
  800f90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f93:	c1 e6 0c             	shl    $0xc,%esi
  800f96:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f9c:	83 c4 04             	add    $0x4,%esp
  800f9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa2:	e8 b0 fd ff ff       	call   800d57 <fd2data>
  800fa7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fa9:	89 34 24             	mov    %esi,(%esp)
  800fac:	e8 a6 fd ff ff       	call   800d57 <fd2data>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	c1 e8 16             	shr    $0x16,%eax
  800fbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc2:	a8 01                	test   $0x1,%al
  800fc4:	74 11                	je     800fd7 <dup+0x78>
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	c1 e8 0c             	shr    $0xc,%eax
  800fcb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd2:	f6 c2 01             	test   $0x1,%dl
  800fd5:	75 39                	jne    801010 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fda:	89 d0                	mov    %edx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fee:	50                   	push   %eax
  800fef:	56                   	push   %esi
  800ff0:	6a 00                	push   $0x0
  800ff2:	52                   	push   %edx
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 b1 fb ff ff       	call   800bab <sys_page_map>
  800ffa:	89 c3                	mov    %eax,%ebx
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 31                	js     801034 <dup+0xd5>
		goto err;

	return newfdnum;
  801003:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801006:	89 d8                	mov    %ebx,%eax
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	25 07 0e 00 00       	and    $0xe07,%eax
  80101f:	50                   	push   %eax
  801020:	57                   	push   %edi
  801021:	6a 00                	push   $0x0
  801023:	53                   	push   %ebx
  801024:	6a 00                	push   $0x0
  801026:	e8 80 fb ff ff       	call   800bab <sys_page_map>
  80102b:	89 c3                	mov    %eax,%ebx
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	79 a3                	jns    800fd7 <dup+0x78>
	sys_page_unmap(0, newfd);
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	56                   	push   %esi
  801038:	6a 00                	push   $0x0
  80103a:	e8 96 fb ff ff       	call   800bd5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	57                   	push   %edi
  801043:	6a 00                	push   $0x0
  801045:	e8 8b fb ff ff       	call   800bd5 <sys_page_unmap>
	return r;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	eb b7                	jmp    801006 <dup+0xa7>

0080104f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80104f:	f3 0f 1e fb          	endbr32 
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 1c             	sub    $0x1c,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	53                   	push   %ebx
  801062:	e8 65 fd ff ff       	call   800dcc <fd_lookup>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 3f                	js     8010ad <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801074:	50                   	push   %eax
  801075:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801078:	ff 30                	pushl  (%eax)
  80107a:	e8 a1 fd ff ff       	call   800e20 <dev_lookup>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 27                	js     8010ad <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801086:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801089:	8b 42 08             	mov    0x8(%edx),%eax
  80108c:	83 e0 03             	and    $0x3,%eax
  80108f:	83 f8 01             	cmp    $0x1,%eax
  801092:	74 1e                	je     8010b2 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801097:	8b 40 08             	mov    0x8(%eax),%eax
  80109a:	85 c0                	test   %eax,%eax
  80109c:	74 35                	je     8010d3 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	ff 75 10             	pushl  0x10(%ebp)
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	52                   	push   %edx
  8010a8:	ff d0                	call   *%eax
  8010aa:	83 c4 10             	add    $0x10,%esp
}
  8010ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b7:	8b 40 48             	mov    0x48(%eax),%eax
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	53                   	push   %ebx
  8010be:	50                   	push   %eax
  8010bf:	68 55 22 80 00       	push   $0x802255
  8010c4:	e8 c8 f0 ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d1:	eb da                	jmp    8010ad <read+0x5e>
		return -E_NOT_SUPP;
  8010d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010d8:	eb d3                	jmp    8010ad <read+0x5e>

008010da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010da:	f3 0f 1e fb          	endbr32 
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	eb 02                	jmp    8010f6 <readn+0x1c>
  8010f4:	01 c3                	add    %eax,%ebx
  8010f6:	39 f3                	cmp    %esi,%ebx
  8010f8:	73 21                	jae    80111b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	89 f0                	mov    %esi,%eax
  8010ff:	29 d8                	sub    %ebx,%eax
  801101:	50                   	push   %eax
  801102:	89 d8                	mov    %ebx,%eax
  801104:	03 45 0c             	add    0xc(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	57                   	push   %edi
  801109:	e8 41 ff ff ff       	call   80104f <read>
		if (m < 0)
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 04                	js     801119 <readn+0x3f>
			return m;
		if (m == 0)
  801115:	75 dd                	jne    8010f4 <readn+0x1a>
  801117:	eb 02                	jmp    80111b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801119:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80111b:	89 d8                	mov    %ebx,%eax
  80111d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801125:	f3 0f 1e fb          	endbr32 
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	53                   	push   %ebx
  80112d:	83 ec 1c             	sub    $0x1c,%esp
  801130:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801133:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	53                   	push   %ebx
  801138:	e8 8f fc ff ff       	call   800dcc <fd_lookup>
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 3a                	js     80117e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114e:	ff 30                	pushl  (%eax)
  801150:	e8 cb fc ff ff       	call   800e20 <dev_lookup>
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 22                	js     80117e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801163:	74 1e                	je     801183 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801165:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801168:	8b 52 0c             	mov    0xc(%edx),%edx
  80116b:	85 d2                	test   %edx,%edx
  80116d:	74 35                	je     8011a4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 10             	pushl  0x10(%ebp)
  801175:	ff 75 0c             	pushl  0xc(%ebp)
  801178:	50                   	push   %eax
  801179:	ff d2                	call   *%edx
  80117b:	83 c4 10             	add    $0x10,%esp
}
  80117e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801181:	c9                   	leave  
  801182:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801183:	a1 04 40 80 00       	mov    0x804004,%eax
  801188:	8b 40 48             	mov    0x48(%eax),%eax
  80118b:	83 ec 04             	sub    $0x4,%esp
  80118e:	53                   	push   %ebx
  80118f:	50                   	push   %eax
  801190:	68 71 22 80 00       	push   $0x802271
  801195:	e8 f7 ef ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a2:	eb da                	jmp    80117e <write+0x59>
		return -E_NOT_SUPP;
  8011a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a9:	eb d3                	jmp    80117e <write+0x59>

008011ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ab:	f3 0f 1e fb          	endbr32 
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	ff 75 08             	pushl  0x8(%ebp)
  8011bc:	e8 0b fc ff ff       	call   800dcc <fd_lookup>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 0e                	js     8011d6 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8011c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d8:	f3 0f 1e fb          	endbr32 
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 1c             	sub    $0x1c,%esp
  8011e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	53                   	push   %ebx
  8011eb:	e8 dc fb ff ff       	call   800dcc <fd_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 37                	js     80122e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801201:	ff 30                	pushl  (%eax)
  801203:	e8 18 fc ff ff       	call   800e20 <dev_lookup>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 1f                	js     80122e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801212:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801216:	74 1b                	je     801233 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121b:	8b 52 18             	mov    0x18(%edx),%edx
  80121e:	85 d2                	test   %edx,%edx
  801220:	74 32                	je     801254 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	ff 75 0c             	pushl  0xc(%ebp)
  801228:	50                   	push   %eax
  801229:	ff d2                	call   *%edx
  80122b:	83 c4 10             	add    $0x10,%esp
}
  80122e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801231:	c9                   	leave  
  801232:	c3                   	ret    
			thisenv->env_id, fdnum);
  801233:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801238:	8b 40 48             	mov    0x48(%eax),%eax
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	53                   	push   %ebx
  80123f:	50                   	push   %eax
  801240:	68 34 22 80 00       	push   $0x802234
  801245:	e8 47 ef ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb da                	jmp    80122e <ftruncate+0x56>
		return -E_NOT_SUPP;
  801254:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801259:	eb d3                	jmp    80122e <ftruncate+0x56>

0080125b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80125b:	f3 0f 1e fb          	endbr32 
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	53                   	push   %ebx
  801263:	83 ec 1c             	sub    $0x1c,%esp
  801266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801269:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 57 fb ff ff       	call   800dcc <fd_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 4b                	js     8012c7 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801286:	ff 30                	pushl  (%eax)
  801288:	e8 93 fb ff ff       	call   800e20 <dev_lookup>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 33                	js     8012c7 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801294:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801297:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80129b:	74 2f                	je     8012cc <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80129d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a7:	00 00 00 
	stat->st_isdir = 0;
  8012aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b1:	00 00 00 
	stat->st_dev = dev;
  8012b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	53                   	push   %ebx
  8012be:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c1:	ff 50 14             	call   *0x14(%eax)
  8012c4:	83 c4 10             	add    $0x10,%esp
}
  8012c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    
		return -E_NOT_SUPP;
  8012cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d1:	eb f4                	jmp    8012c7 <fstat+0x6c>

008012d3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d3:	f3 0f 1e fb          	endbr32 
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	6a 00                	push   $0x0
  8012e1:	ff 75 08             	pushl  0x8(%ebp)
  8012e4:	e8 fb 01 00 00       	call   8014e4 <open>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 1b                	js     80130d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	ff 75 0c             	pushl  0xc(%ebp)
  8012f8:	50                   	push   %eax
  8012f9:	e8 5d ff ff ff       	call   80125b <fstat>
  8012fe:	89 c6                	mov    %eax,%esi
	close(fd);
  801300:	89 1c 24             	mov    %ebx,(%esp)
  801303:	e8 fd fb ff ff       	call   800f05 <close>
	return r;
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	89 f3                	mov    %esi,%ebx
}
  80130d:	89 d8                	mov    %ebx,%eax
  80130f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	56                   	push   %esi
  80131a:	53                   	push   %ebx
  80131b:	89 c6                	mov    %eax,%esi
  80131d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80131f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801326:	74 27                	je     80134f <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801328:	6a 07                	push   $0x7
  80132a:	68 00 50 80 00       	push   $0x805000
  80132f:	56                   	push   %esi
  801330:	ff 35 00 40 80 00    	pushl  0x804000
  801336:	e8 09 08 00 00       	call   801b44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80133b:	83 c4 0c             	add    $0xc,%esp
  80133e:	6a 00                	push   $0x0
  801340:	53                   	push   %ebx
  801341:	6a 00                	push   $0x0
  801343:	e8 8e 07 00 00       	call   801ad6 <ipc_recv>
}
  801348:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	6a 01                	push   $0x1
  801354:	e8 50 08 00 00       	call   801ba9 <ipc_find_env>
  801359:	a3 00 40 80 00       	mov    %eax,0x804000
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	eb c5                	jmp    801328 <fsipc+0x12>

00801363 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801363:	f3 0f 1e fb          	endbr32 
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80136d:	8b 45 08             	mov    0x8(%ebp),%eax
  801370:	8b 40 0c             	mov    0xc(%eax),%eax
  801373:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	b8 02 00 00 00       	mov    $0x2,%eax
  80138a:	e8 87 ff ff ff       	call   801316 <fsipc>
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devfile_flush>:
{
  801391:	f3 0f 1e fb          	endbr32 
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b0:	e8 61 ff ff ff       	call   801316 <fsipc>
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <devfile_stat>:
{
  8013b7:	f3 0f 1e fb          	endbr32 
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	53                   	push   %ebx
  8013bf:	83 ec 04             	sub    $0x4,%esp
  8013c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8013da:	e8 37 ff ff ff       	call   801316 <fsipc>
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 2c                	js     80140f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	68 00 50 80 00       	push   $0x805000
  8013eb:	53                   	push   %ebx
  8013ec:	e8 0a f3 ff ff       	call   8006fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801401:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <devfile_write>:
{
  801414:	f3 0f 1e fb          	endbr32 
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 0c             	sub    $0xc,%esp
  80141e:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801421:	8b 55 08             	mov    0x8(%ebp),%edx
  801424:	8b 52 0c             	mov    0xc(%edx),%edx
  801427:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80142d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801432:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801437:	0f 47 c2             	cmova  %edx,%eax
  80143a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80143f:	50                   	push   %eax
  801440:	ff 75 0c             	pushl  0xc(%ebp)
  801443:	68 08 50 80 00       	push   $0x805008
  801448:	e8 66 f4 ff ff       	call   8008b3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	b8 04 00 00 00       	mov    $0x4,%eax
  801457:	e8 ba fe ff ff       	call   801316 <fsipc>
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <devfile_read>:
{
  80145e:	f3 0f 1e fb          	endbr32 
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	8b 40 0c             	mov    0xc(%eax),%eax
  801470:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801475:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80147b:	ba 00 00 00 00       	mov    $0x0,%edx
  801480:	b8 03 00 00 00       	mov    $0x3,%eax
  801485:	e8 8c fe ff ff       	call   801316 <fsipc>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 1f                	js     8014af <devfile_read+0x51>
	assert(r <= n);
  801490:	39 f0                	cmp    %esi,%eax
  801492:	77 24                	ja     8014b8 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801494:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801499:	7f 33                	jg     8014ce <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	50                   	push   %eax
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	e8 07 f4 ff ff       	call   8008b3 <memmove>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    
	assert(r <= n);
  8014b8:	68 a0 22 80 00       	push   $0x8022a0
  8014bd:	68 a7 22 80 00       	push   $0x8022a7
  8014c2:	6a 7c                	push   $0x7c
  8014c4:	68 bc 22 80 00       	push   $0x8022bc
  8014c9:	e8 be 05 00 00       	call   801a8c <_panic>
	assert(r <= PGSIZE);
  8014ce:	68 c7 22 80 00       	push   $0x8022c7
  8014d3:	68 a7 22 80 00       	push   $0x8022a7
  8014d8:	6a 7d                	push   $0x7d
  8014da:	68 bc 22 80 00       	push   $0x8022bc
  8014df:	e8 a8 05 00 00       	call   801a8c <_panic>

008014e4 <open>:
{
  8014e4:	f3 0f 1e fb          	endbr32 
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 1c             	sub    $0x1c,%esp
  8014f0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014f3:	56                   	push   %esi
  8014f4:	e8 bf f1 ff ff       	call   8006b8 <strlen>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801501:	7f 6c                	jg     80156f <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	e8 67 f8 ff ff       	call   800d76 <fd_alloc>
  80150f:	89 c3                	mov    %eax,%ebx
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 3c                	js     801554 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	56                   	push   %esi
  80151c:	68 00 50 80 00       	push   $0x805000
  801521:	e8 d5 f1 ff ff       	call   8006fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801526:	8b 45 0c             	mov    0xc(%ebp),%eax
  801529:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80152e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801531:	b8 01 00 00 00       	mov    $0x1,%eax
  801536:	e8 db fd ff ff       	call   801316 <fsipc>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 19                	js     80155d <open+0x79>
	return fd2num(fd);
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	ff 75 f4             	pushl  -0xc(%ebp)
  80154a:	e8 f4 f7 ff ff       	call   800d43 <fd2num>
  80154f:	89 c3                	mov    %eax,%ebx
  801551:	83 c4 10             	add    $0x10,%esp
}
  801554:	89 d8                	mov    %ebx,%eax
  801556:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    
		fd_close(fd, 0);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	6a 00                	push   $0x0
  801562:	ff 75 f4             	pushl  -0xc(%ebp)
  801565:	e8 10 f9 ff ff       	call   800e7a <fd_close>
		return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	eb e5                	jmp    801554 <open+0x70>
		return -E_BAD_PATH;
  80156f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801574:	eb de                	jmp    801554 <open+0x70>

00801576 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801576:	f3 0f 1e fb          	endbr32 
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 08 00 00 00       	mov    $0x8,%eax
  80158a:	e8 87 fd ff ff       	call   801316 <fsipc>
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801591:	f3 0f 1e fb          	endbr32 
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	56                   	push   %esi
  801599:	53                   	push   %ebx
  80159a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80159d:	83 ec 0c             	sub    $0xc,%esp
  8015a0:	ff 75 08             	pushl  0x8(%ebp)
  8015a3:	e8 af f7 ff ff       	call   800d57 <fd2data>
  8015a8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	68 d3 22 80 00       	push   $0x8022d3
  8015b2:	53                   	push   %ebx
  8015b3:	e8 43 f1 ff ff       	call   8006fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015b8:	8b 46 04             	mov    0x4(%esi),%eax
  8015bb:	2b 06                	sub    (%esi),%eax
  8015bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ca:	00 00 00 
	stat->st_dev = &devpipe;
  8015cd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015d4:	30 80 00 
	return 0;
}
  8015d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    

008015e3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015e3:	f3 0f 1e fb          	endbr32 
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	53                   	push   %ebx
  8015eb:	83 ec 0c             	sub    $0xc,%esp
  8015ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015f1:	53                   	push   %ebx
  8015f2:	6a 00                	push   $0x0
  8015f4:	e8 dc f5 ff ff       	call   800bd5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015f9:	89 1c 24             	mov    %ebx,(%esp)
  8015fc:	e8 56 f7 ff ff       	call   800d57 <fd2data>
  801601:	83 c4 08             	add    $0x8,%esp
  801604:	50                   	push   %eax
  801605:	6a 00                	push   $0x0
  801607:	e8 c9 f5 ff ff       	call   800bd5 <sys_page_unmap>
}
  80160c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160f:	c9                   	leave  
  801610:	c3                   	ret    

00801611 <_pipeisclosed>:
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	57                   	push   %edi
  801615:	56                   	push   %esi
  801616:	53                   	push   %ebx
  801617:	83 ec 1c             	sub    $0x1c,%esp
  80161a:	89 c7                	mov    %eax,%edi
  80161c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80161e:	a1 04 40 80 00       	mov    0x804004,%eax
  801623:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	57                   	push   %edi
  80162a:	e8 b7 05 00 00       	call   801be6 <pageref>
  80162f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801632:	89 34 24             	mov    %esi,(%esp)
  801635:	e8 ac 05 00 00       	call   801be6 <pageref>
		nn = thisenv->env_runs;
  80163a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801640:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	39 cb                	cmp    %ecx,%ebx
  801648:	74 1b                	je     801665 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80164a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80164d:	75 cf                	jne    80161e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80164f:	8b 42 58             	mov    0x58(%edx),%eax
  801652:	6a 01                	push   $0x1
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	68 da 22 80 00       	push   $0x8022da
  80165b:	e8 31 eb ff ff       	call   800191 <cprintf>
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	eb b9                	jmp    80161e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801665:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801668:	0f 94 c0             	sete   %al
  80166b:	0f b6 c0             	movzbl %al,%eax
}
  80166e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5f                   	pop    %edi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <devpipe_write>:
{
  801676:	f3 0f 1e fb          	endbr32 
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 28             	sub    $0x28,%esp
  801683:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801686:	56                   	push   %esi
  801687:	e8 cb f6 ff ff       	call   800d57 <fd2data>
  80168c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	bf 00 00 00 00       	mov    $0x0,%edi
  801696:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801699:	74 4f                	je     8016ea <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80169b:	8b 43 04             	mov    0x4(%ebx),%eax
  80169e:	8b 0b                	mov    (%ebx),%ecx
  8016a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8016a3:	39 d0                	cmp    %edx,%eax
  8016a5:	72 14                	jb     8016bb <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8016a7:	89 da                	mov    %ebx,%edx
  8016a9:	89 f0                	mov    %esi,%eax
  8016ab:	e8 61 ff ff ff       	call   801611 <_pipeisclosed>
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	75 3b                	jne    8016ef <devpipe_write+0x79>
			sys_yield();
  8016b4:	e8 9f f4 ff ff       	call   800b58 <sys_yield>
  8016b9:	eb e0                	jmp    80169b <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016be:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016c2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	c1 fa 1f             	sar    $0x1f,%edx
  8016ca:	89 d1                	mov    %edx,%ecx
  8016cc:	c1 e9 1b             	shr    $0x1b,%ecx
  8016cf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016d2:	83 e2 1f             	and    $0x1f,%edx
  8016d5:	29 ca                	sub    %ecx,%edx
  8016d7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016df:	83 c0 01             	add    $0x1,%eax
  8016e2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8016e5:	83 c7 01             	add    $0x1,%edi
  8016e8:	eb ac                	jmp    801696 <devpipe_write+0x20>
	return i;
  8016ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ed:	eb 05                	jmp    8016f4 <devpipe_write+0x7e>
				return 0;
  8016ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <devpipe_read>:
{
  8016fc:	f3 0f 1e fb          	endbr32 
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	83 ec 18             	sub    $0x18,%esp
  801709:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80170c:	57                   	push   %edi
  80170d:	e8 45 f6 ff ff       	call   800d57 <fd2data>
  801712:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	be 00 00 00 00       	mov    $0x0,%esi
  80171c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80171f:	75 14                	jne    801735 <devpipe_read+0x39>
	return i;
  801721:	8b 45 10             	mov    0x10(%ebp),%eax
  801724:	eb 02                	jmp    801728 <devpipe_read+0x2c>
				return i;
  801726:	89 f0                	mov    %esi,%eax
}
  801728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    
			sys_yield();
  801730:	e8 23 f4 ff ff       	call   800b58 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801735:	8b 03                	mov    (%ebx),%eax
  801737:	3b 43 04             	cmp    0x4(%ebx),%eax
  80173a:	75 18                	jne    801754 <devpipe_read+0x58>
			if (i > 0)
  80173c:	85 f6                	test   %esi,%esi
  80173e:	75 e6                	jne    801726 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801740:	89 da                	mov    %ebx,%edx
  801742:	89 f8                	mov    %edi,%eax
  801744:	e8 c8 fe ff ff       	call   801611 <_pipeisclosed>
  801749:	85 c0                	test   %eax,%eax
  80174b:	74 e3                	je     801730 <devpipe_read+0x34>
				return 0;
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
  801752:	eb d4                	jmp    801728 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801754:	99                   	cltd   
  801755:	c1 ea 1b             	shr    $0x1b,%edx
  801758:	01 d0                	add    %edx,%eax
  80175a:	83 e0 1f             	and    $0x1f,%eax
  80175d:	29 d0                	sub    %edx,%eax
  80175f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801767:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80176a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80176d:	83 c6 01             	add    $0x1,%esi
  801770:	eb aa                	jmp    80171c <devpipe_read+0x20>

00801772 <pipe>:
{
  801772:	f3 0f 1e fb          	endbr32 
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80177e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	e8 ef f5 ff ff       	call   800d76 <fd_alloc>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	85 c0                	test   %eax,%eax
  80178e:	0f 88 23 01 00 00    	js     8018b7 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801794:	83 ec 04             	sub    $0x4,%esp
  801797:	68 07 04 00 00       	push   $0x407
  80179c:	ff 75 f4             	pushl  -0xc(%ebp)
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 dd f3 ff ff       	call   800b83 <sys_page_alloc>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	0f 88 04 01 00 00    	js     8018b7 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8017b3:	83 ec 0c             	sub    $0xc,%esp
  8017b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b9:	50                   	push   %eax
  8017ba:	e8 b7 f5 ff ff       	call   800d76 <fd_alloc>
  8017bf:	89 c3                	mov    %eax,%ebx
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	0f 88 db 00 00 00    	js     8018a7 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cc:	83 ec 04             	sub    $0x4,%esp
  8017cf:	68 07 04 00 00       	push   $0x407
  8017d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 a5 f3 ff ff       	call   800b83 <sys_page_alloc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	0f 88 bc 00 00 00    	js     8018a7 <pipe+0x135>
	va = fd2data(fd0);
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f1:	e8 61 f5 ff ff       	call   800d57 <fd2data>
  8017f6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f8:	83 c4 0c             	add    $0xc,%esp
  8017fb:	68 07 04 00 00       	push   $0x407
  801800:	50                   	push   %eax
  801801:	6a 00                	push   $0x0
  801803:	e8 7b f3 ff ff       	call   800b83 <sys_page_alloc>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	0f 88 82 00 00 00    	js     801897 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	ff 75 f0             	pushl  -0x10(%ebp)
  80181b:	e8 37 f5 ff ff       	call   800d57 <fd2data>
  801820:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801827:	50                   	push   %eax
  801828:	6a 00                	push   $0x0
  80182a:	56                   	push   %esi
  80182b:	6a 00                	push   $0x0
  80182d:	e8 79 f3 ff ff       	call   800bab <sys_page_map>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	83 c4 20             	add    $0x20,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	78 4e                	js     801889 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80183b:	a1 20 30 80 00       	mov    0x803020,%eax
  801840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801843:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801845:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801848:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80184f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801852:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801857:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80185e:	83 ec 0c             	sub    $0xc,%esp
  801861:	ff 75 f4             	pushl  -0xc(%ebp)
  801864:	e8 da f4 ff ff       	call   800d43 <fd2num>
  801869:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80186e:	83 c4 04             	add    $0x4,%esp
  801871:	ff 75 f0             	pushl  -0x10(%ebp)
  801874:	e8 ca f4 ff ff       	call   800d43 <fd2num>
  801879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80187c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	bb 00 00 00 00       	mov    $0x0,%ebx
  801887:	eb 2e                	jmp    8018b7 <pipe+0x145>
	sys_page_unmap(0, va);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	56                   	push   %esi
  80188d:	6a 00                	push   $0x0
  80188f:	e8 41 f3 ff ff       	call   800bd5 <sys_page_unmap>
  801894:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	ff 75 f0             	pushl  -0x10(%ebp)
  80189d:	6a 00                	push   $0x0
  80189f:	e8 31 f3 ff ff       	call   800bd5 <sys_page_unmap>
  8018a4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	6a 00                	push   $0x0
  8018af:	e8 21 f3 ff ff       	call   800bd5 <sys_page_unmap>
  8018b4:	83 c4 10             	add    $0x10,%esp
}
  8018b7:	89 d8                	mov    %ebx,%eax
  8018b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5e                   	pop    %esi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <pipeisclosed>:
{
  8018c0:	f3 0f 1e fb          	endbr32 
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	ff 75 08             	pushl  0x8(%ebp)
  8018d1:	e8 f6 f4 ff ff       	call   800dcc <fd_lookup>
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 18                	js     8018f5 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e3:	e8 6f f4 ff ff       	call   800d57 <fd2data>
  8018e8:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ed:	e8 1f fd ff ff       	call   801611 <_pipeisclosed>
  8018f2:	83 c4 10             	add    $0x10,%esp
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018f7:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801900:	c3                   	ret    

00801901 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801901:	f3 0f 1e fb          	endbr32 
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80190b:	68 f2 22 80 00       	push   $0x8022f2
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	e8 e3 ed ff ff       	call   8006fb <strcpy>
	return 0;
}
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <devcons_write>:
{
  80191f:	f3 0f 1e fb          	endbr32 
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	57                   	push   %edi
  801927:	56                   	push   %esi
  801928:	53                   	push   %ebx
  801929:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80192f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801934:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80193a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80193d:	73 31                	jae    801970 <devcons_write+0x51>
		m = n - tot;
  80193f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801942:	29 f3                	sub    %esi,%ebx
  801944:	83 fb 7f             	cmp    $0x7f,%ebx
  801947:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80194c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80194f:	83 ec 04             	sub    $0x4,%esp
  801952:	53                   	push   %ebx
  801953:	89 f0                	mov    %esi,%eax
  801955:	03 45 0c             	add    0xc(%ebp),%eax
  801958:	50                   	push   %eax
  801959:	57                   	push   %edi
  80195a:	e8 54 ef ff ff       	call   8008b3 <memmove>
		sys_cputs(buf, m);
  80195f:	83 c4 08             	add    $0x8,%esp
  801962:	53                   	push   %ebx
  801963:	57                   	push   %edi
  801964:	e8 4f f1 ff ff       	call   800ab8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801969:	01 de                	add    %ebx,%esi
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	eb ca                	jmp    80193a <devcons_write+0x1b>
}
  801970:	89 f0                	mov    %esi,%eax
  801972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5f                   	pop    %edi
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devcons_read>:
{
  80197a:	f3 0f 1e fb          	endbr32 
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801989:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80198d:	74 21                	je     8019b0 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80198f:	e8 4e f1 ff ff       	call   800ae2 <sys_cgetc>
  801994:	85 c0                	test   %eax,%eax
  801996:	75 07                	jne    80199f <devcons_read+0x25>
		sys_yield();
  801998:	e8 bb f1 ff ff       	call   800b58 <sys_yield>
  80199d:	eb f0                	jmp    80198f <devcons_read+0x15>
	if (c < 0)
  80199f:	78 0f                	js     8019b0 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8019a1:	83 f8 04             	cmp    $0x4,%eax
  8019a4:	74 0c                	je     8019b2 <devcons_read+0x38>
	*(char*)vbuf = c;
  8019a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a9:	88 02                	mov    %al,(%edx)
	return 1;
  8019ab:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    
		return 0;
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b7:	eb f7                	jmp    8019b0 <devcons_read+0x36>

008019b9 <cputchar>:
{
  8019b9:	f3 0f 1e fb          	endbr32 
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8019c9:	6a 01                	push   $0x1
  8019cb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ce:	50                   	push   %eax
  8019cf:	e8 e4 f0 ff ff       	call   800ab8 <sys_cputs>
}
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <getchar>:
{
  8019d9:	f3 0f 1e fb          	endbr32 
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8019e3:	6a 01                	push   $0x1
  8019e5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 5f f6 ff ff       	call   80104f <read>
	if (r < 0)
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 06                	js     8019fd <getchar+0x24>
	if (r < 1)
  8019f7:	74 06                	je     8019ff <getchar+0x26>
	return c;
  8019f9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    
		return -E_EOF;
  8019ff:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a04:	eb f7                	jmp    8019fd <getchar+0x24>

00801a06 <iscons>:
{
  801a06:	f3 0f 1e fb          	endbr32 
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a13:	50                   	push   %eax
  801a14:	ff 75 08             	pushl  0x8(%ebp)
  801a17:	e8 b0 f3 ff ff       	call   800dcc <fd_lookup>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 11                	js     801a34 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a2c:	39 10                	cmp    %edx,(%eax)
  801a2e:	0f 94 c0             	sete   %al
  801a31:	0f b6 c0             	movzbl %al,%eax
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <opencons>:
{
  801a36:	f3 0f 1e fb          	endbr32 
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	e8 2d f3 ff ff       	call   800d76 <fd_alloc>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 3a                	js     801a8a <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a50:	83 ec 04             	sub    $0x4,%esp
  801a53:	68 07 04 00 00       	push   $0x407
  801a58:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5b:	6a 00                	push   $0x0
  801a5d:	e8 21 f1 ff ff       	call   800b83 <sys_page_alloc>
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 21                	js     801a8a <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a72:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a77:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	50                   	push   %eax
  801a82:	e8 bc f2 ff ff       	call   800d43 <fd2num>
  801a87:	83 c4 10             	add    $0x10,%esp
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a8c:	f3 0f 1e fb          	endbr32 
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a95:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a98:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a9e:	e8 8d f0 ff ff       	call   800b30 <sys_getenvid>
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	ff 75 0c             	pushl  0xc(%ebp)
  801aa9:	ff 75 08             	pushl  0x8(%ebp)
  801aac:	56                   	push   %esi
  801aad:	50                   	push   %eax
  801aae:	68 00 23 80 00       	push   $0x802300
  801ab3:	e8 d9 e6 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ab8:	83 c4 18             	add    $0x18,%esp
  801abb:	53                   	push   %ebx
  801abc:	ff 75 10             	pushl  0x10(%ebp)
  801abf:	e8 78 e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801ac4:	c7 04 24 eb 22 80 00 	movl   $0x8022eb,(%esp)
  801acb:	e8 c1 e6 ff ff       	call   800191 <cprintf>
  801ad0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ad3:	cc                   	int3   
  801ad4:	eb fd                	jmp    801ad3 <_panic+0x47>

00801ad6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ad6:	f3 0f 1e fb          	endbr32 
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aef:	0f 44 c2             	cmove  %edx,%eax
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	50                   	push   %eax
  801af6:	e8 9f f1 ff ff       	call   800c9a <sys_ipc_recv>

	if (from_env_store != NULL)
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 f6                	test   %esi,%esi
  801b00:	74 15                	je     801b17 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801b02:	ba 00 00 00 00       	mov    $0x0,%edx
  801b07:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b0a:	74 09                	je     801b15 <ipc_recv+0x3f>
  801b0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b12:	8b 52 74             	mov    0x74(%edx),%edx
  801b15:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801b17:	85 db                	test   %ebx,%ebx
  801b19:	74 15                	je     801b30 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b23:	74 09                	je     801b2e <ipc_recv+0x58>
  801b25:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b2b:	8b 52 78             	mov    0x78(%edx),%edx
  801b2e:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801b30:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b33:	74 08                	je     801b3d <ipc_recv+0x67>
  801b35:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b44:	f3 0f 1e fb          	endbr32 
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b5a:	eb 1f                	jmp    801b7b <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801b5c:	6a 00                	push   $0x0
  801b5e:	68 00 00 c0 ee       	push   $0xeec00000
  801b63:	56                   	push   %esi
  801b64:	57                   	push   %edi
  801b65:	e8 07 f1 ff ff       	call   800c71 <sys_ipc_try_send>
  801b6a:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	74 30                	je     801ba1 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801b71:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b74:	75 19                	jne    801b8f <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801b76:	e8 dd ef ff ff       	call   800b58 <sys_yield>
		if (pg != NULL) {
  801b7b:	85 db                	test   %ebx,%ebx
  801b7d:	74 dd                	je     801b5c <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801b7f:	ff 75 14             	pushl  0x14(%ebp)
  801b82:	53                   	push   %ebx
  801b83:	56                   	push   %esi
  801b84:	57                   	push   %edi
  801b85:	e8 e7 f0 ff ff       	call   800c71 <sys_ipc_try_send>
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	eb de                	jmp    801b6d <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801b8f:	50                   	push   %eax
  801b90:	68 23 23 80 00       	push   $0x802323
  801b95:	6a 3e                	push   $0x3e
  801b97:	68 30 23 80 00       	push   $0x802330
  801b9c:	e8 eb fe ff ff       	call   801a8c <_panic>
	}
}
  801ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba9:	f3 0f 1e fb          	endbr32 
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bb8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bbb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bc1:	8b 52 50             	mov    0x50(%edx),%edx
  801bc4:	39 ca                	cmp    %ecx,%edx
  801bc6:	74 11                	je     801bd9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bc8:	83 c0 01             	add    $0x1,%eax
  801bcb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bd0:	75 e6                	jne    801bb8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd7:	eb 0b                	jmp    801be4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bd9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bdc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801be1:	8b 40 48             	mov    0x48(%eax),%eax
}
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801be6:	f3 0f 1e fb          	endbr32 
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	c1 ea 16             	shr    $0x16,%edx
  801bf5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801bfc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c01:	f6 c1 01             	test   $0x1,%cl
  801c04:	74 1c                	je     801c22 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c06:	c1 e8 0c             	shr    $0xc,%eax
  801c09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c10:	a8 01                	test   $0x1,%al
  801c12:	74 0e                	je     801c22 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c14:	c1 e8 0c             	shr    $0xc,%eax
  801c17:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c1e:	ef 
  801c1f:	0f b7 d2             	movzwl %dx,%edx
}
  801c22:	89 d0                	mov    %edx,%eax
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__udivdi3>:
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c4b:	85 d2                	test   %edx,%edx
  801c4d:	75 19                	jne    801c68 <__udivdi3+0x38>
  801c4f:	39 f3                	cmp    %esi,%ebx
  801c51:	76 4d                	jbe    801ca0 <__udivdi3+0x70>
  801c53:	31 ff                	xor    %edi,%edi
  801c55:	89 e8                	mov    %ebp,%eax
  801c57:	89 f2                	mov    %esi,%edx
  801c59:	f7 f3                	div    %ebx
  801c5b:	89 fa                	mov    %edi,%edx
  801c5d:	83 c4 1c             	add    $0x1c,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
  801c68:	39 f2                	cmp    %esi,%edx
  801c6a:	76 14                	jbe    801c80 <__udivdi3+0x50>
  801c6c:	31 ff                	xor    %edi,%edi
  801c6e:	31 c0                	xor    %eax,%eax
  801c70:	89 fa                	mov    %edi,%edx
  801c72:	83 c4 1c             	add    $0x1c,%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5f                   	pop    %edi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    
  801c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c80:	0f bd fa             	bsr    %edx,%edi
  801c83:	83 f7 1f             	xor    $0x1f,%edi
  801c86:	75 48                	jne    801cd0 <__udivdi3+0xa0>
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x62>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 de                	ja     801c70 <__udivdi3+0x40>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb d7                	jmp    801c70 <__udivdi3+0x40>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d9                	mov    %ebx,%ecx
  801ca2:	85 db                	test   %ebx,%ebx
  801ca4:	75 0b                	jne    801cb1 <__udivdi3+0x81>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f3                	div    %ebx
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	31 d2                	xor    %edx,%edx
  801cb3:	89 f0                	mov    %esi,%eax
  801cb5:	f7 f1                	div    %ecx
  801cb7:	89 c6                	mov    %eax,%esi
  801cb9:	89 e8                	mov    %ebp,%eax
  801cbb:	89 f7                	mov    %esi,%edi
  801cbd:	f7 f1                	div    %ecx
  801cbf:	89 fa                	mov    %edi,%edx
  801cc1:	83 c4 1c             	add    $0x1c,%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 f9                	mov    %edi,%ecx
  801cd2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cd7:	29 f8                	sub    %edi,%eax
  801cd9:	d3 e2                	shl    %cl,%edx
  801cdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	89 da                	mov    %ebx,%edx
  801ce3:	d3 ea                	shr    %cl,%edx
  801ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ce9:	09 d1                	or     %edx,%ecx
  801ceb:	89 f2                	mov    %esi,%edx
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	d3 e3                	shl    %cl,%ebx
  801cf5:	89 c1                	mov    %eax,%ecx
  801cf7:	d3 ea                	shr    %cl,%edx
  801cf9:	89 f9                	mov    %edi,%ecx
  801cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cff:	89 eb                	mov    %ebp,%ebx
  801d01:	d3 e6                	shl    %cl,%esi
  801d03:	89 c1                	mov    %eax,%ecx
  801d05:	d3 eb                	shr    %cl,%ebx
  801d07:	09 de                	or     %ebx,%esi
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	f7 74 24 08          	divl   0x8(%esp)
  801d0f:	89 d6                	mov    %edx,%esi
  801d11:	89 c3                	mov    %eax,%ebx
  801d13:	f7 64 24 0c          	mull   0xc(%esp)
  801d17:	39 d6                	cmp    %edx,%esi
  801d19:	72 15                	jb     801d30 <__udivdi3+0x100>
  801d1b:	89 f9                	mov    %edi,%ecx
  801d1d:	d3 e5                	shl    %cl,%ebp
  801d1f:	39 c5                	cmp    %eax,%ebp
  801d21:	73 04                	jae    801d27 <__udivdi3+0xf7>
  801d23:	39 d6                	cmp    %edx,%esi
  801d25:	74 09                	je     801d30 <__udivdi3+0x100>
  801d27:	89 d8                	mov    %ebx,%eax
  801d29:	31 ff                	xor    %edi,%edi
  801d2b:	e9 40 ff ff ff       	jmp    801c70 <__udivdi3+0x40>
  801d30:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d33:	31 ff                	xor    %edi,%edi
  801d35:	e9 36 ff ff ff       	jmp    801c70 <__udivdi3+0x40>
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	f3 0f 1e fb          	endbr32 
  801d44:	55                   	push   %ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 1c             	sub    $0x1c,%esp
  801d4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d4f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d53:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d57:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	75 19                	jne    801d78 <__umoddi3+0x38>
  801d5f:	39 df                	cmp    %ebx,%edi
  801d61:	76 5d                	jbe    801dc0 <__umoddi3+0x80>
  801d63:	89 f0                	mov    %esi,%eax
  801d65:	89 da                	mov    %ebx,%edx
  801d67:	f7 f7                	div    %edi
  801d69:	89 d0                	mov    %edx,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	83 c4 1c             	add    $0x1c,%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    
  801d75:	8d 76 00             	lea    0x0(%esi),%esi
  801d78:	89 f2                	mov    %esi,%edx
  801d7a:	39 d8                	cmp    %ebx,%eax
  801d7c:	76 12                	jbe    801d90 <__umoddi3+0x50>
  801d7e:	89 f0                	mov    %esi,%eax
  801d80:	89 da                	mov    %ebx,%edx
  801d82:	83 c4 1c             	add    $0x1c,%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5f                   	pop    %edi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    
  801d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d90:	0f bd e8             	bsr    %eax,%ebp
  801d93:	83 f5 1f             	xor    $0x1f,%ebp
  801d96:	75 50                	jne    801de8 <__umoddi3+0xa8>
  801d98:	39 d8                	cmp    %ebx,%eax
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	89 d9                	mov    %ebx,%ecx
  801da2:	39 f7                	cmp    %esi,%edi
  801da4:	0f 86 d6 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	89 ca                	mov    %ecx,%edx
  801dae:	83 c4 1c             	add    $0x1c,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
  801db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	89 fd                	mov    %edi,%ebp
  801dc2:	85 ff                	test   %edi,%edi
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 d8                	mov    %ebx,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	31 d2                	xor    %edx,%edx
  801ddf:	eb 8c                	jmp    801d6d <__umoddi3+0x2d>
  801de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de8:	89 e9                	mov    %ebp,%ecx
  801dea:	ba 20 00 00 00       	mov    $0x20,%edx
  801def:	29 ea                	sub    %ebp,%edx
  801df1:	d3 e0                	shl    %cl,%eax
  801df3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 f8                	mov    %edi,%eax
  801dfb:	d3 e8                	shr    %cl,%eax
  801dfd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e01:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e05:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e09:	09 c1                	or     %eax,%ecx
  801e0b:	89 d8                	mov    %ebx,%eax
  801e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e11:	89 e9                	mov    %ebp,%ecx
  801e13:	d3 e7                	shl    %cl,%edi
  801e15:	89 d1                	mov    %edx,%ecx
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e1f:	d3 e3                	shl    %cl,%ebx
  801e21:	89 c7                	mov    %eax,%edi
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	89 fa                	mov    %edi,%edx
  801e2d:	d3 e6                	shl    %cl,%esi
  801e2f:	09 d8                	or     %ebx,%eax
  801e31:	f7 74 24 08          	divl   0x8(%esp)
  801e35:	89 d1                	mov    %edx,%ecx
  801e37:	89 f3                	mov    %esi,%ebx
  801e39:	f7 64 24 0c          	mull   0xc(%esp)
  801e3d:	89 c6                	mov    %eax,%esi
  801e3f:	89 d7                	mov    %edx,%edi
  801e41:	39 d1                	cmp    %edx,%ecx
  801e43:	72 06                	jb     801e4b <__umoddi3+0x10b>
  801e45:	75 10                	jne    801e57 <__umoddi3+0x117>
  801e47:	39 c3                	cmp    %eax,%ebx
  801e49:	73 0c                	jae    801e57 <__umoddi3+0x117>
  801e4b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e4f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e53:	89 d7                	mov    %edx,%edi
  801e55:	89 c6                	mov    %eax,%esi
  801e57:	89 ca                	mov    %ecx,%edx
  801e59:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e5e:	29 f3                	sub    %esi,%ebx
  801e60:	19 fa                	sbb    %edi,%edx
  801e62:	89 d0                	mov    %edx,%eax
  801e64:	d3 e0                	shl    %cl,%eax
  801e66:	89 e9                	mov    %ebp,%ecx
  801e68:	d3 eb                	shr    %cl,%ebx
  801e6a:	d3 ea                	shr    %cl,%edx
  801e6c:	09 d8                	or     %ebx,%eax
  801e6e:	83 c4 1c             	add    $0x1c,%esp
  801e71:	5b                   	pop    %ebx
  801e72:	5e                   	pop    %esi
  801e73:	5f                   	pop    %edi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    
  801e76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 fe                	sub    %edi,%esi
  801e82:	19 c3                	sbb    %eax,%ebx
  801e84:	89 f2                	mov    %esi,%edx
  801e86:	89 d9                	mov    %ebx,%ecx
  801e88:	e9 1d ff ff ff       	jmp    801daa <__umoddi3+0x6a>
