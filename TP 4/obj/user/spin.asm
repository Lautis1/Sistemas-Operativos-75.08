
obj/user/spin.debug:     formato del fichero elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003e:	68 00 24 80 00       	push   $0x802400
  800043:	e8 7a 01 00 00       	call   8001c2 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 46 10 00 00       	call   801093 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 78 24 80 00       	push   $0x802478
  80005c:	e8 61 01 00 00       	call   8001c2 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 28 24 80 00       	push   $0x802428
  800070:	e8 4d 01 00 00       	call   8001c2 <cprintf>
	sys_yield();
  800075:	e8 0f 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  80007a:	e8 0a 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  80007f:	e8 05 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800084:	e8 00 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800089:	e8 fb 0a 00 00       	call   800b89 <sys_yield>
	sys_yield();
  80008e:	e8 f6 0a 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800093:	e8 f1 0a 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800098:	e8 ec 0a 00 00       	call   800b89 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  8000a4:	e8 19 01 00 00       	call   8001c2 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 8a 0a 00 00       	call   800b3b <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000c8:	e8 94 0a 00 00       	call   800b61 <sys_getenvid>
	if (id >= 0)
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	78 12                	js     8000e3 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x35>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 3b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0a 00 00 00       	call   800107 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800111:	e8 11 13 00 00       	call   801427 <close_all>
	sys_env_destroy(0);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	6a 00                	push   $0x0
  80011b:	e8 1b 0a 00 00       	call   800b3b <sys_env_destroy>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800125:	f3 0f 1e fb          	endbr32 
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	53                   	push   %ebx
  80012d:	83 ec 04             	sub    $0x4,%esp
  800130:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800133:	8b 13                	mov    (%ebx),%edx
  800135:	8d 42 01             	lea    0x1(%edx),%eax
  800138:	89 03                	mov    %eax,(%ebx)
  80013a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800141:	3d ff 00 00 00       	cmp    $0xff,%eax
  800146:	74 09                	je     800151 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800148:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800151:	83 ec 08             	sub    $0x8,%esp
  800154:	68 ff 00 00 00       	push   $0xff
  800159:	8d 43 08             	lea    0x8(%ebx),%eax
  80015c:	50                   	push   %eax
  80015d:	e8 87 09 00 00       	call   800ae9 <sys_cputs>
		b->idx = 0;
  800162:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	eb db                	jmp    800148 <putch+0x23>

0080016d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016d:	f3 0f 1e fb          	endbr32 
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80017a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800181:	00 00 00 
	b.cnt = 0;
  800184:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018e:	ff 75 0c             	pushl  0xc(%ebp)
  800191:	ff 75 08             	pushl  0x8(%ebp)
  800194:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	68 25 01 80 00       	push   $0x800125
  8001a0:	e8 80 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	83 c4 08             	add    $0x8,%esp
  8001a8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 2f 09 00 00       	call   800ae9 <sys_cputs>

	return b.cnt;
}
  8001ba:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c2:	f3 0f 1e fb          	endbr32 
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cf:	50                   	push   %eax
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	e8 95 ff ff ff       	call   80016d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 1c             	sub    $0x1c,%esp
  8001e3:	89 c7                	mov    %eax,%edi
  8001e5:	89 d6                	mov    %edx,%esi
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 d1                	mov    %edx,%ecx
  8001ef:	89 c2                	mov    %eax,%edx
  8001f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800200:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800207:	39 c2                	cmp    %eax,%edx
  800209:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80020c:	72 3e                	jb     80024c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	ff 75 18             	pushl  0x18(%ebp)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	53                   	push   %ebx
  800218:	50                   	push   %eax
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021f:	ff 75 e0             	pushl  -0x20(%ebp)
  800222:	ff 75 dc             	pushl  -0x24(%ebp)
  800225:	ff 75 d8             	pushl  -0x28(%ebp)
  800228:	e8 73 1f 00 00       	call   8021a0 <__udivdi3>
  80022d:	83 c4 18             	add    $0x18,%esp
  800230:	52                   	push   %edx
  800231:	50                   	push   %eax
  800232:	89 f2                	mov    %esi,%edx
  800234:	89 f8                	mov    %edi,%eax
  800236:	e8 9f ff ff ff       	call   8001da <printnum>
  80023b:	83 c4 20             	add    $0x20,%esp
  80023e:	eb 13                	jmp    800253 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	56                   	push   %esi
  800244:	ff 75 18             	pushl  0x18(%ebp)
  800247:	ff d7                	call   *%edi
  800249:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024c:	83 eb 01             	sub    $0x1,%ebx
  80024f:	85 db                	test   %ebx,%ebx
  800251:	7f ed                	jg     800240 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	83 ec 04             	sub    $0x4,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 45 20 00 00       	call   8022b0 <__umoddi3>
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	0f be 80 a0 24 80 00 	movsbl 0x8024a0(%eax),%eax
  800275:	50                   	push   %eax
  800276:	ff d7                	call   *%edi
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800283:	83 fa 01             	cmp    $0x1,%edx
  800286:	7f 13                	jg     80029b <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 1c                	je     8002a8 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	8b 52 04             	mov    0x4(%edx),%edx
  8002a7:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	c3                   	ret    

008002b7 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7f 0f                	jg     8002cb <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 18                	je     8002d8 <getint+0x21>
		return va_arg(*ap, long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	99                   	cltd   
  8002ca:	c3                   	ret    
		return va_arg(*ap, long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	99                   	cltd   
}
  8002e2:	c3                   	ret    

008002e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e3:	f3 0f 1e fb          	endbr32 
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f6:	73 0a                	jae    800302 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	88 02                	mov    %al,(%edx)
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <printfmt>:
{
  800304:	f3 0f 1e fb          	endbr32 
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 2c             	sub    $0x2c,%esp
  800332:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800335:	8b 75 0c             	mov    0xc(%ebp),%esi
  800338:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033b:	e9 86 02 00 00       	jmp    8005c6 <vprintfmt+0x2a1>
		padc = ' ';
  800340:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800344:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800352:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8d 47 01             	lea    0x1(%edi),%eax
  800361:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800364:	0f b6 17             	movzbl (%edi),%edx
  800367:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036a:	3c 55                	cmp    $0x55,%al
  80036c:	0f 87 df 02 00 00    	ja     800651 <vprintfmt+0x32c>
  800372:	0f b6 c0             	movzbl %al,%eax
  800375:	3e ff 24 85 e0 25 80 	notrack jmp *0x8025e0(,%eax,4)
  80037c:	00 
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800380:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800384:	eb d8                	jmp    80035e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80038d:	eb cf                	jmp    80035e <vprintfmt+0x39>
  80038f:	0f b6 d2             	movzbl %dl,%edx
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
  80039a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80039d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003aa:	83 f9 09             	cmp    $0x9,%ecx
  8003ad:	77 52                	ja     800401 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b2:	eb e9                	jmp    80039d <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	79 93                	jns    80035e <vprintfmt+0x39>
				width = precision, precision = -1;
  8003cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d8:	eb 84                	jmp    80035e <vprintfmt+0x39>
  8003da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e4:	0f 49 d0             	cmovns %eax,%edx
  8003e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ed:	e9 6c ff ff ff       	jmp    80035e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fc:	e9 5d ff ff ff       	jmp    80035e <vprintfmt+0x39>
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800407:	eb bc                	jmp    8003c5 <vprintfmt+0xa0>
			lflag++;
  800409:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040f:	e9 4a ff ff ff       	jmp    80035e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d3                	call   *%ebx
			break;
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	e9 96 01 00 00       	jmp    8005c3 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 0f             	cmp    $0xf,%eax
  800440:	7f 20                	jg     800462 <vprintfmt+0x13d>
  800442:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	74 15                	je     800462 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80044d:	52                   	push   %edx
  80044e:	68 55 2a 80 00       	push   $0x802a55
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	e8 aa fe ff ff       	call   800304 <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	e9 61 01 00 00       	jmp    8005c3 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 b8 24 80 00       	push   $0x8024b8
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	e8 95 fe ff ff       	call   800304 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	e9 4c 01 00 00       	jmp    8005c3 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800482:	85 c9                	test   %ecx,%ecx
  800484:	b8 b1 24 80 00       	mov    $0x8024b1,%eax
  800489:	0f 45 c1             	cmovne %ecx,%eax
  80048c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x176>
  800495:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800499:	75 0d                	jne    8004a8 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049e:	89 c7                	mov    %eax,%edi
  8004a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	eb 57                	jmp    8004ff <vprintfmt+0x1da>
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b1:	e8 4f 02 00 00       	call   800705 <strnlen>
  8004b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b9:	29 c2                	sub    %eax,%edx
  8004bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004c5:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004c8:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	7e 10                	jle    8004de <vprintfmt+0x1b9>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	56                   	push   %esi
  8004d2:	57                   	push   %edi
  8004d3:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	83 eb 01             	sub    $0x1,%ebx
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb ec                	jmp    8004ca <vprintfmt+0x1a5>
  8004de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	0f 49 c2             	cmovns %edx,%eax
  8004ee:	29 c2                	sub    %eax,%edx
  8004f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f3:	eb a6                	jmp    80049b <vprintfmt+0x176>
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	56                   	push   %esi
  8004f9:	52                   	push   %edx
  8004fa:	ff d3                	call   *%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800502:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800504:	83 c7 01             	add    $0x1,%edi
  800507:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050b:	0f be d0             	movsbl %al,%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	74 42                	je     800554 <vprintfmt+0x22f>
  800512:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800516:	78 06                	js     80051e <vprintfmt+0x1f9>
  800518:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051c:	78 1e                	js     80053c <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800522:	74 d1                	je     8004f5 <vprintfmt+0x1d0>
  800524:	0f be c0             	movsbl %al,%eax
  800527:	83 e8 20             	sub    $0x20,%eax
  80052a:	83 f8 5e             	cmp    $0x5e,%eax
  80052d:	76 c6                	jbe    8004f5 <vprintfmt+0x1d0>
					putch('?', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	56                   	push   %esi
  800533:	6a 3f                	push   $0x3f
  800535:	ff d3                	call   *%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	eb c3                	jmp    8004ff <vprintfmt+0x1da>
  80053c:	89 cf                	mov    %ecx,%edi
  80053e:	eb 0e                	jmp    80054e <vprintfmt+0x229>
				putch(' ', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	56                   	push   %esi
  800544:	6a 20                	push   $0x20
  800546:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ee                	jg     800540 <vprintfmt+0x21b>
  800552:	eb 6f                	jmp    8005c3 <vprintfmt+0x29e>
  800554:	89 cf                	mov    %ecx,%edi
  800556:	eb f6                	jmp    80054e <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800558:	89 ca                	mov    %ecx,%edx
  80055a:	8d 45 14             	lea    0x14(%ebp),%eax
  80055d:	e8 55 fd ff ff       	call   8002b7 <getint>
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800568:	85 d2                	test   %edx,%edx
  80056a:	78 0b                	js     800577 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80056c:	89 d1                	mov    %edx,%ecx
  80056e:	89 c2                	mov    %eax,%edx
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
  800575:	eb 32                	jmp    8005a9 <vprintfmt+0x284>
				putch('-', putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	56                   	push   %esi
  80057b:	6a 2d                	push   $0x2d
  80057d:	ff d3                	call   *%ebx
				num = -(long long) num;
  80057f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800582:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800585:	f7 da                	neg    %edx
  800587:	83 d1 00             	adc    $0x0,%ecx
  80058a:	f7 d9                	neg    %ecx
  80058c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800594:	eb 13                	jmp    8005a9 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800596:	89 ca                	mov    %ecx,%edx
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 e3 fc ff ff       	call   800283 <getuint>
  8005a0:	89 d1                	mov    %edx,%ecx
  8005a2:	89 c2                	mov    %eax,%edx
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005a9:	83 ec 0c             	sub    $0xc,%esp
  8005ac:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005b0:	57                   	push   %edi
  8005b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b4:	50                   	push   %eax
  8005b5:	51                   	push   %ecx
  8005b6:	52                   	push   %edx
  8005b7:	89 f2                	mov    %esi,%edx
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	e8 1a fc ff ff       	call   8001da <printnum>
			break;
  8005c0:	83 c4 20             	add    $0x20,%esp
{
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c6:	83 c7 01             	add    $0x1,%edi
  8005c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cd:	83 f8 25             	cmp    $0x25,%eax
  8005d0:	0f 84 6a fd ff ff    	je     800340 <vprintfmt+0x1b>
			if (ch == '\0')
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	0f 84 93 00 00 00    	je     800671 <vprintfmt+0x34c>
			putch(ch, putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	56                   	push   %esi
  8005e2:	50                   	push   %eax
  8005e3:	ff d3                	call   *%ebx
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	eb dc                	jmp    8005c6 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005ea:	89 ca                	mov    %ecx,%edx
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 8f fc ff ff       	call   800283 <getuint>
  8005f4:	89 d1                	mov    %edx,%ecx
  8005f6:	89 c2                	mov    %eax,%edx
			base = 8;
  8005f8:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005fd:	eb aa                	jmp    8005a9 <vprintfmt+0x284>
			putch('0', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	56                   	push   %esi
  800603:	6a 30                	push   $0x30
  800605:	ff d3                	call   *%ebx
			putch('x', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	56                   	push   %esi
  80060b:	6a 78                	push   $0x78
  80060d:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800622:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800627:	eb 80                	jmp    8005a9 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 50 fc ff ff       	call   800283 <getuint>
  800633:	89 d1                	mov    %edx,%ecx
  800635:	89 c2                	mov    %eax,%edx
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
  80063c:	e9 68 ff ff ff       	jmp    8005a9 <vprintfmt+0x284>
			putch(ch, putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	56                   	push   %esi
  800645:	6a 25                	push   $0x25
  800647:	ff d3                	call   *%ebx
			break;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	e9 72 ff ff ff       	jmp    8005c3 <vprintfmt+0x29e>
			putch('%', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	6a 25                	push   $0x25
  800657:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	89 f8                	mov    %edi,%eax
  80065e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800662:	74 05                	je     800669 <vprintfmt+0x344>
  800664:	83 e8 01             	sub    $0x1,%eax
  800667:	eb f5                	jmp    80065e <vprintfmt+0x339>
  800669:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066c:	e9 52 ff ff ff       	jmp    8005c3 <vprintfmt+0x29e>
}
  800671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800674:	5b                   	pop    %ebx
  800675:	5e                   	pop    %esi
  800676:	5f                   	pop    %edi
  800677:	5d                   	pop    %ebp
  800678:	c3                   	ret    

00800679 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800679:	f3 0f 1e fb          	endbr32 
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 18             	sub    $0x18,%esp
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800690:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 26                	je     8006c4 <vsnprintf+0x4b>
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	7e 22                	jle    8006c4 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a2:	ff 75 14             	pushl  0x14(%ebp)
  8006a5:	ff 75 10             	pushl  0x10(%ebp)
  8006a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	68 e3 02 80 00       	push   $0x8002e3
  8006b1:	e8 6f fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bf:	83 c4 10             	add    $0x10,%esp
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    
		return -E_INVAL;
  8006c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c9:	eb f7                	jmp    8006c2 <vsnprintf+0x49>

008006cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cb:	f3 0f 1e fb          	endbr32 
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 92 ff ff ff       	call   800679 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e9:	f3 0f 1e fb          	endbr32 
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fc:	74 05                	je     800703 <strlen+0x1a>
		n++;
  8006fe:	83 c0 01             	add    $0x1,%eax
  800701:	eb f5                	jmp    8006f8 <strlen+0xf>
	return n;
}
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800705:	f3 0f 1e fb          	endbr32 
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	39 d0                	cmp    %edx,%eax
  800719:	74 0d                	je     800728 <strnlen+0x23>
  80071b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071f:	74 05                	je     800726 <strnlen+0x21>
		n++;
  800721:	83 c0 01             	add    $0x1,%eax
  800724:	eb f1                	jmp    800717 <strnlen+0x12>
  800726:	89 c2                	mov    %eax,%edx
	return n;
}
  800728:	89 d0                	mov    %edx,%eax
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072c:	f3 0f 1e fb          	endbr32 
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800743:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800746:	83 c0 01             	add    $0x1,%eax
  800749:	84 d2                	test   %dl,%dl
  80074b:	75 f2                	jne    80073f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80074d:	89 c8                	mov    %ecx,%eax
  80074f:	5b                   	pop    %ebx
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800752:	f3 0f 1e fb          	endbr32 
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	83 ec 10             	sub    $0x10,%esp
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 83 ff ff ff       	call   8006e9 <strlen>
  800766:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 b8 ff ff ff       	call   80072c <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	f3 0f 1e fb          	endbr32 
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	89 f3                	mov    %esi,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078f:	89 f0                	mov    %esi,%eax
  800791:	39 d8                	cmp    %ebx,%eax
  800793:	74 11                	je     8007a6 <strncpy+0x2b>
		*dst++ = *src;
  800795:	83 c0 01             	add    $0x1,%eax
  800798:	0f b6 0a             	movzbl (%edx),%ecx
  80079b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079e:	80 f9 01             	cmp    $0x1,%cl
  8007a1:	83 da ff             	sbb    $0xffffffff,%edx
  8007a4:	eb eb                	jmp    800791 <strncpy+0x16>
	}
	return ret;
}
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007be:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 21                	je     8007e5 <strlcpy+0x39>
  8007c4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 14                	je     8007e2 <strlcpy+0x36>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	74 0b                	je     8007e0 <strlcpy+0x34>
			*dst++ = *src++;
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007de:	eb ea                	jmp    8007ca <strlcpy+0x1e>
  8007e0:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007e2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e5:	29 f0                	sub    %esi,%eax
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5e                   	pop    %esi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007eb:	f3 0f 1e fb          	endbr32 
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	84 c0                	test   %al,%al
  8007fd:	74 0c                	je     80080b <strcmp+0x20>
  8007ff:	3a 02                	cmp    (%edx),%al
  800801:	75 08                	jne    80080b <strcmp+0x20>
		p++, q++;
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	eb ed                	jmp    8007f8 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	f3 0f 1e fb          	endbr32 
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
  800823:	89 c3                	mov    %eax,%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800828:	eb 06                	jmp    800830 <strncmp+0x1b>
		n--, p++, q++;
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800830:	39 d8                	cmp    %ebx,%eax
  800832:	74 16                	je     80084a <strncmp+0x35>
  800834:	0f b6 08             	movzbl (%eax),%ecx
  800837:	84 c9                	test   %cl,%cl
  800839:	74 04                	je     80083f <strncmp+0x2a>
  80083b:	3a 0a                	cmp    (%edx),%cl
  80083d:	74 eb                	je     80082a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 00             	movzbl (%eax),%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    
		return 0;
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
  80084f:	eb f6                	jmp    800847 <strncmp+0x32>

00800851 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085f:	0f b6 10             	movzbl (%eax),%edx
  800862:	84 d2                	test   %dl,%dl
  800864:	74 09                	je     80086f <strchr+0x1e>
		if (*s == c)
  800866:	38 ca                	cmp    %cl,%dl
  800868:	74 0a                	je     800874 <strchr+0x23>
	for (; *s; s++)
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	eb f0                	jmp    80085f <strchr+0xe>
			return (char *) s;
	return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800876:	f3 0f 1e fb          	endbr32 
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 09                	je     800894 <strfind+0x1e>
  80088b:	84 d2                	test   %dl,%dl
  80088d:	74 05                	je     800894 <strfind+0x1e>
	for (; *s; s++)
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	eb f0                	jmp    800884 <strfind+0xe>
			break;
	return (char *) s;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008a6:	85 c9                	test   %ecx,%ecx
  8008a8:	74 33                	je     8008dd <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008aa:	89 d0                	mov    %edx,%eax
  8008ac:	09 c8                	or     %ecx,%eax
  8008ae:	a8 03                	test   $0x3,%al
  8008b0:	75 23                	jne    8008d5 <memset+0x3f>
		c &= 0xFF;
  8008b2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b6:	89 d8                	mov    %ebx,%eax
  8008b8:	c1 e0 08             	shl    $0x8,%eax
  8008bb:	89 df                	mov    %ebx,%edi
  8008bd:	c1 e7 18             	shl    $0x18,%edi
  8008c0:	89 de                	mov    %ebx,%esi
  8008c2:	c1 e6 10             	shl    $0x10,%esi
  8008c5:	09 f7                	or     %esi,%edi
  8008c7:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008c9:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008ce:	89 d7                	mov    %edx,%edi
  8008d0:	fc                   	cld    
  8008d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d3:	eb 08                	jmp    8008dd <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d5:	89 d7                	mov    %edx,%edi
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008da:	fc                   	cld    
  8008db:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f6:	39 c6                	cmp    %eax,%esi
  8008f8:	73 32                	jae    80092c <memmove+0x48>
  8008fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fd:	39 c2                	cmp    %eax,%edx
  8008ff:	76 2b                	jbe    80092c <memmove+0x48>
		s += n;
		d += n;
  800901:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	89 fe                	mov    %edi,%esi
  800906:	09 ce                	or     %ecx,%esi
  800908:	09 d6                	or     %edx,%esi
  80090a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800910:	75 0e                	jne    800920 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 09                	jmp    800929 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800926:	fd                   	std    
  800927:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800929:	fc                   	cld    
  80092a:	eb 1a                	jmp    800946 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	89 c2                	mov    %eax,%edx
  80092e:	09 ca                	or     %ecx,%edx
  800930:	09 f2                	or     %esi,%edx
  800932:	f6 c2 03             	test   $0x3,%dl
  800935:	75 0a                	jne    800941 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800937:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80093a:	89 c7                	mov    %eax,%edi
  80093c:	fc                   	cld    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 05                	jmp    800946 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094a:	f3 0f 1e fb          	endbr32 
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 82 ff ff ff       	call   8008e4 <memmove>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800964:	f3 0f 1e fb          	endbr32 
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c6                	mov    %eax,%esi
  800975:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800978:	39 f0                	cmp    %esi,%eax
  80097a:	74 1c                	je     800998 <memcmp+0x34>
		if (*s1 != *s2)
  80097c:	0f b6 08             	movzbl (%eax),%ecx
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	38 d9                	cmp    %bl,%cl
  800984:	75 08                	jne    80098e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	83 c2 01             	add    $0x1,%edx
  80098c:	eb ea                	jmp    800978 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80098e:	0f b6 c1             	movzbl %cl,%eax
  800991:	0f b6 db             	movzbl %bl,%ebx
  800994:	29 d8                	sub    %ebx,%eax
  800996:	eb 05                	jmp    80099d <memcmp+0x39>
	}

	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ae:	89 c2                	mov    %eax,%edx
  8009b0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b3:	39 d0                	cmp    %edx,%eax
  8009b5:	73 09                	jae    8009c0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b7:	38 08                	cmp    %cl,(%eax)
  8009b9:	74 05                	je     8009c0 <memfind+0x1f>
	for (; s < ends; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	eb f3                	jmp    8009b3 <memfind+0x12>
			break;
	return (void *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d2:	eb 03                	jmp    8009d7 <strtol+0x15>
		s++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009d7:	0f b6 01             	movzbl (%ecx),%eax
  8009da:	3c 20                	cmp    $0x20,%al
  8009dc:	74 f6                	je     8009d4 <strtol+0x12>
  8009de:	3c 09                	cmp    $0x9,%al
  8009e0:	74 f2                	je     8009d4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009e2:	3c 2b                	cmp    $0x2b,%al
  8009e4:	74 2a                	je     800a10 <strtol+0x4e>
	int neg = 0;
  8009e6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009eb:	3c 2d                	cmp    $0x2d,%al
  8009ed:	74 2b                	je     800a1a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ef:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f5:	75 0f                	jne    800a06 <strtol+0x44>
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	74 28                	je     800a24 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a03:	0f 44 d8             	cmove  %eax,%ebx
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a0e:	eb 46                	jmp    800a56 <strtol+0x94>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
  800a18:	eb d5                	jmp    8009ef <strtol+0x2d>
		s++, neg = 1;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a22:	eb cb                	jmp    8009ef <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	74 0e                	je     800a38 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	75 d8                	jne    800a06 <strtol+0x44>
		s++, base = 8;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a36:	eb ce                	jmp    800a06 <strtol+0x44>
		s += 2, base = 16;
  800a38:	83 c1 02             	add    $0x2,%ecx
  800a3b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a40:	eb c4                	jmp    800a06 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a48:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4b:	7d 3a                	jge    800a87 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a54:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	76 df                	jbe    800a42 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 57             	sub    $0x57,%edx
  800a73:	eb d3                	jmp    800a48 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 08                	ja     800a87 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 37             	sub    $0x37,%edx
  800a85:	eb c1                	jmp    800a48 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8b:	74 05                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 1c             	sub    $0x1c,%esp
  800aa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aaf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aba:	8b 75 14             	mov    0x14(%ebp),%esi
  800abd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ac3:	74 04                	je     800ac9 <syscall+0x29>
  800ac5:	85 c0                	test   %eax,%eax
  800ac7:	7f 08                	jg     800ad1 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad1:	83 ec 0c             	sub    $0xc,%esp
  800ad4:	50                   	push   %eax
  800ad5:	ff 75 e0             	pushl  -0x20(%ebp)
  800ad8:	68 9f 27 80 00       	push   $0x80279f
  800add:	6a 23                	push   $0x23
  800adf:	68 bc 27 80 00       	push   $0x8027bc
  800ae4:	e8 94 14 00 00       	call   801f7d <_panic>

00800ae9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ae9:	f3 0f 1e fb          	endbr32 
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	ff 75 0c             	pushl  0xc(%ebp)
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	e8 92 ff ff ff       	call   800aa0 <syscall>
}
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b13:	f3 0f 1e fb          	endbr32 
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b1d:	6a 00                	push   $0x0
  800b1f:	6a 00                	push   $0x0
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	e8 67 ff ff ff       	call   800aa0 <syscall>
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	f3 0f 1e fb          	endbr32 
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b50:	ba 01 00 00 00       	mov    $0x1,%edx
  800b55:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5a:	e8 41 ff ff ff       	call   800aa0 <syscall>
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b82:	e8 19 ff ff ff       	call   800aa0 <syscall>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_yield>:

void
sys_yield(void)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	e8 f1 fe ff ff       	call   800aa0 <syscall>
}
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb4:	f3 0f 1e fb          	endbr32 
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 10             	pushl  0x10(%ebp)
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd5:	e8 c6 fe ff ff       	call   800aa0 <syscall>
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdc:	f3 0f 1e fb          	endbr32 
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800be6:	ff 75 18             	pushl  0x18(%ebp)
  800be9:	ff 75 14             	pushl  0x14(%ebp)
  800bec:	ff 75 10             	pushl  0x10(%ebp)
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	e8 9c fe ff ff       	call   800aa0 <syscall>
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c06:	f3 0f 1e fb          	endbr32 
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c10:	6a 00                	push   $0x0
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	ff 75 0c             	pushl  0xc(%ebp)
  800c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c21:	b8 06 00 00 00       	mov    $0x6,%eax
  800c26:	e8 75 fe ff ff       	call   800aa0 <syscall>
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2d:	f3 0f 1e fb          	endbr32 
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c37:	6a 00                	push   $0x0
  800c39:	6a 00                	push   $0x0
  800c3b:	6a 00                	push   $0x0
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4d:	e8 4e fe ff ff       	call   800aa0 <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c74:	e8 27 fe ff ff       	call   800aa0 <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	f3 0f 1e fb          	endbr32 
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9b:	e8 00 fe ff ff       	call   800aa0 <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cac:	6a 00                	push   $0x0
  800cae:	ff 75 14             	pushl  0x14(%ebp)
  800cb1:	ff 75 10             	pushl  0x10(%ebp)
  800cb4:	ff 75 0c             	pushl  0xc(%ebp)
  800cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc4:	e8 d7 fd ff ff       	call   800aa0 <syscall>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cea:	e8 b1 fd ff ff       	call   800aa0 <syscall>
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 04             	sub    $0x4,%esp
  800cf8:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800cfa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800d01:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800d04:	f6 c6 04             	test   $0x4,%dh
  800d07:	75 54                	jne    800d5d <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800d09:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d0f:	0f 84 8d 00 00 00    	je     800da2 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	68 05 08 00 00       	push   $0x805
  800d1d:	53                   	push   %ebx
  800d1e:	50                   	push   %eax
  800d1f:	53                   	push   %ebx
  800d20:	6a 00                	push   $0x0
  800d22:	e8 b5 fe ff ff       	call   800bdc <sys_page_map>
		if (r < 0)
  800d27:	83 c4 20             	add    $0x20,%esp
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	78 5f                	js     800d8d <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	68 05 08 00 00       	push   $0x805
  800d36:	53                   	push   %ebx
  800d37:	6a 00                	push   $0x0
  800d39:	53                   	push   %ebx
  800d3a:	6a 00                	push   $0x0
  800d3c:	e8 9b fe ff ff       	call   800bdc <sys_page_map>
		if (r < 0)
  800d41:	83 c4 20             	add    $0x20,%esp
  800d44:	85 c0                	test   %eax,%eax
  800d46:	79 70                	jns    800db8 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d48:	50                   	push   %eax
  800d49:	68 cc 27 80 00       	push   $0x8027cc
  800d4e:	68 9b 00 00 00       	push   $0x9b
  800d53:	68 3a 29 80 00       	push   $0x80293a
  800d58:	e8 20 12 00 00       	call   801f7d <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d66:	52                   	push   %edx
  800d67:	53                   	push   %ebx
  800d68:	50                   	push   %eax
  800d69:	53                   	push   %ebx
  800d6a:	6a 00                	push   $0x0
  800d6c:	e8 6b fe ff ff       	call   800bdc <sys_page_map>
		if (r < 0)
  800d71:	83 c4 20             	add    $0x20,%esp
  800d74:	85 c0                	test   %eax,%eax
  800d76:	79 40                	jns    800db8 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d78:	50                   	push   %eax
  800d79:	68 cc 27 80 00       	push   $0x8027cc
  800d7e:	68 92 00 00 00       	push   $0x92
  800d83:	68 3a 29 80 00       	push   $0x80293a
  800d88:	e8 f0 11 00 00       	call   801f7d <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d8d:	50                   	push   %eax
  800d8e:	68 cc 27 80 00       	push   $0x8027cc
  800d93:	68 97 00 00 00       	push   $0x97
  800d98:	68 3a 29 80 00       	push   $0x80293a
  800d9d:	e8 db 11 00 00       	call   801f7d <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	6a 05                	push   $0x5
  800da7:	53                   	push   %ebx
  800da8:	50                   	push   %eax
  800da9:	53                   	push   %ebx
  800daa:	6a 00                	push   $0x0
  800dac:	e8 2b fe ff ff       	call   800bdc <sys_page_map>
		if (r < 0)
  800db1:	83 c4 20             	add    $0x20,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 0a                	js     800dc2 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800db8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dc2:	50                   	push   %eax
  800dc3:	68 cc 27 80 00       	push   $0x8027cc
  800dc8:	68 a0 00 00 00       	push   $0xa0
  800dcd:	68 3a 29 80 00       	push   $0x80293a
  800dd2:	e8 a6 11 00 00       	call   801f7d <_panic>

00800dd7 <dup_or_share>:
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	89 c7                	mov    %eax,%edi
  800de2:	89 d6                	mov    %edx,%esi
  800de4:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800de6:	f6 c1 02             	test   $0x2,%cl
  800de9:	0f 84 90 00 00 00    	je     800e7f <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	51                   	push   %ecx
  800df3:	52                   	push   %edx
  800df4:	50                   	push   %eax
  800df5:	e8 ba fd ff ff       	call   800bb4 <sys_page_alloc>
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	78 56                	js     800e57 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	53                   	push   %ebx
  800e05:	68 00 00 40 00       	push   $0x400000
  800e0a:	6a 00                	push   $0x0
  800e0c:	56                   	push   %esi
  800e0d:	57                   	push   %edi
  800e0e:	e8 c9 fd ff ff       	call   800bdc <sys_page_map>
  800e13:	83 c4 20             	add    $0x20,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	78 51                	js     800e6b <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	68 00 10 00 00       	push   $0x1000
  800e22:	56                   	push   %esi
  800e23:	68 00 00 40 00       	push   $0x400000
  800e28:	e8 b7 fa ff ff       	call   8008e4 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e2d:	83 c4 08             	add    $0x8,%esp
  800e30:	68 00 00 40 00       	push   $0x400000
  800e35:	6a 00                	push   $0x0
  800e37:	e8 ca fd ff ff       	call   800c06 <sys_page_unmap>
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	79 51                	jns    800e94 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800e43:	83 ec 04             	sub    $0x4,%esp
  800e46:	68 3c 28 80 00       	push   $0x80283c
  800e4b:	6a 18                	push   $0x18
  800e4d:	68 3a 29 80 00       	push   $0x80293a
  800e52:	e8 26 11 00 00       	call   801f7d <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	68 f0 27 80 00       	push   $0x8027f0
  800e5f:	6a 13                	push   $0x13
  800e61:	68 3a 29 80 00       	push   $0x80293a
  800e66:	e8 12 11 00 00       	call   801f7d <_panic>
			panic("sys_page_map failed at dup_or_share");
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	68 18 28 80 00       	push   $0x802818
  800e73:	6a 15                	push   $0x15
  800e75:	68 3a 29 80 00       	push   $0x80293a
  800e7a:	e8 fe 10 00 00       	call   801f7d <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	51                   	push   %ecx
  800e83:	52                   	push   %edx
  800e84:	50                   	push   %eax
  800e85:	52                   	push   %edx
  800e86:	6a 00                	push   $0x0
  800e88:	e8 4f fd ff ff       	call   800bdc <sys_page_map>
  800e8d:	83 c4 20             	add    $0x20,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 08                	js     800e9c <dup_or_share+0xc5>
}
  800e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	68 18 28 80 00       	push   $0x802818
  800ea4:	6a 1c                	push   $0x1c
  800ea6:	68 3a 29 80 00       	push   $0x80293a
  800eab:	e8 cd 10 00 00       	call   801f7d <_panic>

00800eb0 <pgfault>:
{
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ebe:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800ec0:	89 da                	mov    %ebx,%edx
  800ec2:	c1 ea 0c             	shr    $0xc,%edx
  800ec5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800ecc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed0:	74 6e                	je     800f40 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800ed2:	f6 c6 08             	test   $0x8,%dh
  800ed5:	74 7d                	je     800f54 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800ed7:	83 ec 04             	sub    $0x4,%esp
  800eda:	6a 07                	push   $0x7
  800edc:	68 00 f0 7f 00       	push   $0x7ff000
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 cc fc ff ff       	call   800bb4 <sys_page_alloc>
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 79                	js     800f68 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eef:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 00 10 00 00       	push   $0x1000
  800efd:	53                   	push   %ebx
  800efe:	68 00 f0 7f 00       	push   $0x7ff000
  800f03:	e8 dc f9 ff ff       	call   8008e4 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  800f08:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0f:	53                   	push   %ebx
  800f10:	6a 00                	push   $0x0
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	6a 00                	push   $0x0
  800f19:	e8 be fc ff ff       	call   800bdc <sys_page_map>
  800f1e:	83 c4 20             	add    $0x20,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 57                	js     800f7c <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	68 00 f0 7f 00       	push   $0x7ff000
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 d2 fc ff ff       	call   800c06 <sys_page_unmap>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 55                	js     800f90 <pgfault+0xe0>
}
  800f3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 45 29 80 00       	push   $0x802945
  800f48:	6a 5e                	push   $0x5e
  800f4a:	68 3a 29 80 00       	push   $0x80293a
  800f4f:	e8 29 10 00 00       	call   801f7d <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 64 28 80 00       	push   $0x802864
  800f5c:	6a 62                	push   $0x62
  800f5e:	68 3a 29 80 00       	push   $0x80293a
  800f63:	e8 15 10 00 00       	call   801f7d <_panic>
		panic("pgfault failed");
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	68 5d 29 80 00       	push   $0x80295d
  800f70:	6a 6d                	push   $0x6d
  800f72:	68 3a 29 80 00       	push   $0x80293a
  800f77:	e8 01 10 00 00       	call   801f7d <_panic>
		panic("pgfault failed");
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	68 5d 29 80 00       	push   $0x80295d
  800f84:	6a 72                	push   $0x72
  800f86:	68 3a 29 80 00       	push   $0x80293a
  800f8b:	e8 ed 0f 00 00       	call   801f7d <_panic>
		panic("pgfault failed");
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	68 5d 29 80 00       	push   $0x80295d
  800f98:	6a 74                	push   $0x74
  800f9a:	68 3a 29 80 00       	push   $0x80293a
  800f9f:	e8 d9 0f 00 00       	call   801f7d <_panic>

00800fa4 <fork_v0>:
{
  800fa4:	f3 0f 1e fb          	endbr32 
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb6:	cd 30                	int    $0x30
  800fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 1d                	js     800fdf <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  800fc2:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800fc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fcb:	74 26                	je     800ff3 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  800fcd:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  800fd2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  800fd8:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  800fdd:	eb 4b                	jmp    80102a <fork_v0+0x86>
		panic("sys_exofork failed");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 6c 29 80 00       	push   $0x80296c
  800fe7:	6a 2b                	push   $0x2b
  800fe9:	68 3a 29 80 00       	push   $0x80293a
  800fee:	e8 8a 0f 00 00       	call   801f7d <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff3:	e8 69 fb ff ff       	call   800b61 <sys_getenvid>
  800ff8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ffd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801000:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801005:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80100a:	eb 68                	jmp    801074 <fork_v0+0xd0>
				dup_or_share(envid,
  80100c:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801012:	89 da                	mov    %ebx,%edx
  801014:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801017:	e8 bb fd ff ff       	call   800dd7 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  80101c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801022:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801028:	74 36                	je     801060 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  80102a:	89 d8                	mov    %ebx,%eax
  80102c:	c1 e8 16             	shr    $0x16,%eax
  80102f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801036:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  801038:	f6 02 01             	testb  $0x1,(%edx)
  80103b:	74 df                	je     80101c <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  80103d:	89 da                	mov    %ebx,%edx
  80103f:	c1 ea 0a             	shr    $0xa,%edx
  801042:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801048:	c1 e0 0c             	shl    $0xc,%eax
  80104b:	89 f9                	mov    %edi,%ecx
  80104d:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  801053:	09 c8                	or     %ecx,%eax
  801055:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  801057:	8b 08                	mov    (%eax),%ecx
  801059:	f6 c1 01             	test   $0x1,%cl
  80105c:	74 be                	je     80101c <fork_v0+0x78>
  80105e:	eb ac                	jmp    80100c <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	6a 02                	push   $0x2
  801065:	ff 75 e0             	pushl  -0x20(%ebp)
  801068:	e8 c0 fb ff ff       	call   800c2d <sys_env_set_status>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	78 0b                	js     80107f <fork_v0+0xdb>
}
  801074:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801077:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5f                   	pop    %edi
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  80107f:	83 ec 04             	sub    $0x4,%esp
  801082:	68 84 28 80 00       	push   $0x802884
  801087:	6a 43                	push   $0x43
  801089:	68 3a 29 80 00       	push   $0x80293a
  80108e:	e8 ea 0e 00 00       	call   801f7d <_panic>

00801093 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801093:	f3 0f 1e fb          	endbr32 
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  8010a0:	68 b0 0e 80 00       	push   $0x800eb0
  8010a5:	e8 1d 0f 00 00       	call   801fc7 <set_pgfault_handler>
  8010aa:	b8 07 00 00 00       	mov    $0x7,%eax
  8010af:	cd 30                	int    $0x30
  8010b1:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 2f                	js     8010ea <fork+0x57>
  8010bb:	89 c7                	mov    %eax,%edi
  8010bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  8010c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010c8:	0f 85 9e 00 00 00    	jne    80116c <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  8010ce:	e8 8e fa ff ff       	call   800b61 <sys_getenvid>
  8010d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010e5:	e9 de 00 00 00       	jmp    8011c8 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  8010ea:	50                   	push   %eax
  8010eb:	68 ac 28 80 00       	push   $0x8028ac
  8010f0:	68 c2 00 00 00       	push   $0xc2
  8010f5:	68 3a 29 80 00       	push   $0x80293a
  8010fa:	e8 7e 0e 00 00       	call   801f7d <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	6a 07                	push   $0x7
  801104:	68 00 f0 bf ee       	push   $0xeebff000
  801109:	57                   	push   %edi
  80110a:	e8 a5 fa ff ff       	call   800bb4 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	75 33                	jne    801149 <fork+0xb6>
  801116:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801119:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80111f:	74 3d                	je     80115e <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801121:	89 d8                	mov    %ebx,%eax
  801123:	c1 e0 0c             	shl    $0xc,%eax
  801126:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  801128:	89 c2                	mov    %eax,%edx
  80112a:	c1 ea 0c             	shr    $0xc,%edx
  80112d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  801134:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801139:	74 c4                	je     8010ff <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  80113b:	f6 c1 01             	test   $0x1,%cl
  80113e:	74 d6                	je     801116 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  801140:	89 f8                	mov    %edi,%eax
  801142:	e8 aa fb ff ff       	call   800cf1 <duppage>
  801147:	eb cd                	jmp    801116 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  801149:	50                   	push   %eax
  80114a:	68 cc 28 80 00       	push   $0x8028cc
  80114f:	68 e1 00 00 00       	push   $0xe1
  801154:	68 3a 29 80 00       	push   $0x80293a
  801159:	e8 1f 0e 00 00       	call   801f7d <_panic>
  80115e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  801162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  801165:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  80116a:	74 18                	je     801184 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  80116c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80116f:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  801176:	a8 01                	test   $0x1,%al
  801178:	74 e4                	je     80115e <fork+0xcb>
  80117a:	c1 e6 16             	shl    $0x16,%esi
  80117d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801182:	eb 9d                	jmp    801121 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	6a 07                	push   $0x7
  801189:	68 00 f0 bf ee       	push   $0xeebff000
  80118e:	ff 75 e0             	pushl  -0x20(%ebp)
  801191:	e8 1e fa ff ff       	call   800bb4 <sys_page_alloc>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 36                	js     8011d3 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	68 22 20 80 00       	push   $0x802022
  8011a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a8:	e8 ce fa ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 36                	js     8011ea <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	6a 02                	push   $0x2
  8011b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bc:	e8 6c fa ff ff       	call   800c2d <sys_env_set_status>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 39                	js     801201 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  8011c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    
		panic("Error en sys_page_alloc");
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	68 7f 29 80 00       	push   $0x80297f
  8011db:	68 f4 00 00 00       	push   $0xf4
  8011e0:	68 3a 29 80 00       	push   $0x80293a
  8011e5:	e8 93 0d 00 00       	call   801f7d <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	68 f0 28 80 00       	push   $0x8028f0
  8011f2:	68 f8 00 00 00       	push   $0xf8
  8011f7:	68 3a 29 80 00       	push   $0x80293a
  8011fc:	e8 7c 0d 00 00       	call   801f7d <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801201:	50                   	push   %eax
  801202:	68 14 29 80 00       	push   $0x802914
  801207:	68 fc 00 00 00       	push   $0xfc
  80120c:	68 3a 29 80 00       	push   $0x80293a
  801211:	e8 67 0d 00 00       	call   801f7d <_panic>

00801216 <sfork>:

// Challenge!
int
sfork(void)
{
  801216:	f3 0f 1e fb          	endbr32 
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801220:	68 97 29 80 00       	push   $0x802997
  801225:	68 05 01 00 00       	push   $0x105
  80122a:	68 3a 29 80 00       	push   $0x80293a
  80122f:	e8 49 0d 00 00       	call   801f7d <_panic>

00801234 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801234:	f3 0f 1e fb          	endbr32 
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	05 00 00 00 30       	add    $0x30000000,%eax
  801243:	c1 e8 0c             	shr    $0xc,%eax
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801248:	f3 0f 1e fb          	endbr32 
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 da ff ff ff       	call   801234 <fd2num>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	c1 e0 0c             	shl    $0xc,%eax
  801260:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801267:	f3 0f 1e fb          	endbr32 
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 16             	shr    $0x16,%edx
  801278:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 2d                	je     8012b1 <fd_alloc+0x4a>
  801284:	89 c2                	mov    %eax,%edx
  801286:	c1 ea 0c             	shr    $0xc,%edx
  801289:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	74 1c                	je     8012b1 <fd_alloc+0x4a>
  801295:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80129a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129f:	75 d2                	jne    801273 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012af:	eb 0a                	jmp    8012bb <fd_alloc+0x54>
			*fd_store = fd;
  8012b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012bd:	f3 0f 1e fb          	endbr32 
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c7:	83 f8 1f             	cmp    $0x1f,%eax
  8012ca:	77 30                	ja     8012fc <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012cc:	c1 e0 0c             	shl    $0xc,%eax
  8012cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012da:	f6 c2 01             	test   $0x1,%dl
  8012dd:	74 24                	je     801303 <fd_lookup+0x46>
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	c1 ea 0c             	shr    $0xc,%edx
  8012e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012eb:	f6 c2 01             	test   $0x1,%dl
  8012ee:	74 1a                	je     80130a <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    
		return -E_INVAL;
  8012fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801301:	eb f7                	jmp    8012fa <fd_lookup+0x3d>
		return -E_INVAL;
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801308:	eb f0                	jmp    8012fa <fd_lookup+0x3d>
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130f:	eb e9                	jmp    8012fa <fd_lookup+0x3d>

00801311 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801311:	f3 0f 1e fb          	endbr32 
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131e:	ba 2c 2a 80 00       	mov    $0x802a2c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801323:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801328:	39 08                	cmp    %ecx,(%eax)
  80132a:	74 33                	je     80135f <dev_lookup+0x4e>
  80132c:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80132f:	8b 02                	mov    (%edx),%eax
  801331:	85 c0                	test   %eax,%eax
  801333:	75 f3                	jne    801328 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801335:	a1 04 40 80 00       	mov    0x804004,%eax
  80133a:	8b 40 48             	mov    0x48(%eax),%eax
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	51                   	push   %ecx
  801341:	50                   	push   %eax
  801342:	68 b0 29 80 00       	push   $0x8029b0
  801347:	e8 76 ee ff ff       	call   8001c2 <cprintf>
	*dev = 0;
  80134c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    
			*dev = devtab[i];
  80135f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801362:	89 01                	mov    %eax,(%ecx)
			return 0;
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
  801369:	eb f2                	jmp    80135d <dev_lookup+0x4c>

0080136b <fd_close>:
{
  80136b:	f3 0f 1e fb          	endbr32 
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	57                   	push   %edi
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 28             	sub    $0x28,%esp
  801378:	8b 75 08             	mov    0x8(%ebp),%esi
  80137b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137e:	56                   	push   %esi
  80137f:	e8 b0 fe ff ff       	call   801234 <fd2num>
  801384:	83 c4 08             	add    $0x8,%esp
  801387:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80138a:	52                   	push   %edx
  80138b:	50                   	push   %eax
  80138c:	e8 2c ff ff ff       	call   8012bd <fd_lookup>
  801391:	89 c3                	mov    %eax,%ebx
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 05                	js     80139f <fd_close+0x34>
	    || fd != fd2)
  80139a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80139d:	74 16                	je     8013b5 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80139f:	89 f8                	mov    %edi,%eax
  8013a1:	84 c0                	test   %al,%al
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a8:	0f 44 d8             	cmove  %eax,%ebx
}
  8013ab:	89 d8                	mov    %ebx,%eax
  8013ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 36                	pushl  (%esi)
  8013be:	e8 4e ff ff ff       	call   801311 <dev_lookup>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 1a                	js     8013e6 <fd_close+0x7b>
		if (dev->dev_close)
  8013cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013d2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	74 0b                	je     8013e6 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	56                   	push   %esi
  8013df:	ff d0                	call   *%eax
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	56                   	push   %esi
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 15 f8 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	eb b5                	jmp    8013ab <fd_close+0x40>

008013f6 <close>:

int
close(int fdnum)
{
  8013f6:	f3 0f 1e fb          	endbr32 
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801400:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801403:	50                   	push   %eax
  801404:	ff 75 08             	pushl  0x8(%ebp)
  801407:	e8 b1 fe ff ff       	call   8012bd <fd_lookup>
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	85 c0                	test   %eax,%eax
  801411:	79 02                	jns    801415 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    
		return fd_close(fd, 1);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	6a 01                	push   $0x1
  80141a:	ff 75 f4             	pushl  -0xc(%ebp)
  80141d:	e8 49 ff ff ff       	call   80136b <fd_close>
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb ec                	jmp    801413 <close+0x1d>

00801427 <close_all>:

void
close_all(void)
{
  801427:	f3 0f 1e fb          	endbr32 
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801432:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	53                   	push   %ebx
  80143b:	e8 b6 ff ff ff       	call   8013f6 <close>
	for (i = 0; i < MAXFD; i++)
  801440:	83 c3 01             	add    $0x1,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	83 fb 20             	cmp    $0x20,%ebx
  801449:	75 ec                	jne    801437 <close_all+0x10>
}
  80144b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801450:	f3 0f 1e fb          	endbr32 
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	57                   	push   %edi
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
  80145a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80145d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 54 fe ff ff       	call   8012bd <fd_lookup>
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	0f 88 81 00 00 00    	js     8014f7 <dup+0xa7>
		return r;
	close(newfdnum);
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	ff 75 0c             	pushl  0xc(%ebp)
  80147c:	e8 75 ff ff ff       	call   8013f6 <close>

	newfd = INDEX2FD(newfdnum);
  801481:	8b 75 0c             	mov    0xc(%ebp),%esi
  801484:	c1 e6 0c             	shl    $0xc,%esi
  801487:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80148d:	83 c4 04             	add    $0x4,%esp
  801490:	ff 75 e4             	pushl  -0x1c(%ebp)
  801493:	e8 b0 fd ff ff       	call   801248 <fd2data>
  801498:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80149a:	89 34 24             	mov    %esi,(%esp)
  80149d:	e8 a6 fd ff ff       	call   801248 <fd2data>
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a7:	89 d8                	mov    %ebx,%eax
  8014a9:	c1 e8 16             	shr    $0x16,%eax
  8014ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b3:	a8 01                	test   $0x1,%al
  8014b5:	74 11                	je     8014c8 <dup+0x78>
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	c1 e8 0c             	shr    $0xc,%eax
  8014bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c3:	f6 c2 01             	test   $0x1,%dl
  8014c6:	75 39                	jne    801501 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	c1 e8 0c             	shr    $0xc,%eax
  8014d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	25 07 0e 00 00       	and    $0xe07,%eax
  8014df:	50                   	push   %eax
  8014e0:	56                   	push   %esi
  8014e1:	6a 00                	push   $0x0
  8014e3:	52                   	push   %edx
  8014e4:	6a 00                	push   $0x0
  8014e6:	e8 f1 f6 ff ff       	call   800bdc <sys_page_map>
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	83 c4 20             	add    $0x20,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 31                	js     801525 <dup+0xd5>
		goto err;

	return newfdnum;
  8014f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f7:	89 d8                	mov    %ebx,%eax
  8014f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801501:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	25 07 0e 00 00       	and    $0xe07,%eax
  801510:	50                   	push   %eax
  801511:	57                   	push   %edi
  801512:	6a 00                	push   $0x0
  801514:	53                   	push   %ebx
  801515:	6a 00                	push   $0x0
  801517:	e8 c0 f6 ff ff       	call   800bdc <sys_page_map>
  80151c:	89 c3                	mov    %eax,%ebx
  80151e:	83 c4 20             	add    $0x20,%esp
  801521:	85 c0                	test   %eax,%eax
  801523:	79 a3                	jns    8014c8 <dup+0x78>
	sys_page_unmap(0, newfd);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	56                   	push   %esi
  801529:	6a 00                	push   $0x0
  80152b:	e8 d6 f6 ff ff       	call   800c06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801530:	83 c4 08             	add    $0x8,%esp
  801533:	57                   	push   %edi
  801534:	6a 00                	push   $0x0
  801536:	e8 cb f6 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	eb b7                	jmp    8014f7 <dup+0xa7>

00801540 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801540:	f3 0f 1e fb          	endbr32 
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 1c             	sub    $0x1c,%esp
  80154b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	53                   	push   %ebx
  801553:	e8 65 fd ff ff       	call   8012bd <fd_lookup>
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 3f                	js     80159e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	ff 30                	pushl  (%eax)
  80156b:	e8 a1 fd ff ff       	call   801311 <dev_lookup>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 27                	js     80159e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801577:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157a:	8b 42 08             	mov    0x8(%edx),%eax
  80157d:	83 e0 03             	and    $0x3,%eax
  801580:	83 f8 01             	cmp    $0x1,%eax
  801583:	74 1e                	je     8015a3 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801585:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801588:	8b 40 08             	mov    0x8(%eax),%eax
  80158b:	85 c0                	test   %eax,%eax
  80158d:	74 35                	je     8015c4 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	ff 75 10             	pushl  0x10(%ebp)
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	52                   	push   %edx
  801599:	ff d0                	call   *%eax
  80159b:	83 c4 10             	add    $0x10,%esp
}
  80159e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a8:	8b 40 48             	mov    0x48(%eax),%eax
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	53                   	push   %ebx
  8015af:	50                   	push   %eax
  8015b0:	68 f1 29 80 00       	push   $0x8029f1
  8015b5:	e8 08 ec ff ff       	call   8001c2 <cprintf>
		return -E_INVAL;
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c2:	eb da                	jmp    80159e <read+0x5e>
		return -E_NOT_SUPP;
  8015c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c9:	eb d3                	jmp    80159e <read+0x5e>

008015cb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015cb:	f3 0f 1e fb          	endbr32 
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	57                   	push   %edi
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e3:	eb 02                	jmp    8015e7 <readn+0x1c>
  8015e5:	01 c3                	add    %eax,%ebx
  8015e7:	39 f3                	cmp    %esi,%ebx
  8015e9:	73 21                	jae    80160c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	89 f0                	mov    %esi,%eax
  8015f0:	29 d8                	sub    %ebx,%eax
  8015f2:	50                   	push   %eax
  8015f3:	89 d8                	mov    %ebx,%eax
  8015f5:	03 45 0c             	add    0xc(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	57                   	push   %edi
  8015fa:	e8 41 ff ff ff       	call   801540 <read>
		if (m < 0)
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 04                	js     80160a <readn+0x3f>
			return m;
		if (m == 0)
  801606:	75 dd                	jne    8015e5 <readn+0x1a>
  801608:	eb 02                	jmp    80160c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80160a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801616:	f3 0f 1e fb          	endbr32 
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 1c             	sub    $0x1c,%esp
  801621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801624:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	53                   	push   %ebx
  801629:	e8 8f fc ff ff       	call   8012bd <fd_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 3a                	js     80166f <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163f:	ff 30                	pushl  (%eax)
  801641:	e8 cb fc ff ff       	call   801311 <dev_lookup>
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 22                	js     80166f <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801650:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801654:	74 1e                	je     801674 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801659:	8b 52 0c             	mov    0xc(%edx),%edx
  80165c:	85 d2                	test   %edx,%edx
  80165e:	74 35                	je     801695 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	50                   	push   %eax
  80166a:	ff d2                	call   *%edx
  80166c:	83 c4 10             	add    $0x10,%esp
}
  80166f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801672:	c9                   	leave  
  801673:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801674:	a1 04 40 80 00       	mov    0x804004,%eax
  801679:	8b 40 48             	mov    0x48(%eax),%eax
  80167c:	83 ec 04             	sub    $0x4,%esp
  80167f:	53                   	push   %ebx
  801680:	50                   	push   %eax
  801681:	68 0d 2a 80 00       	push   $0x802a0d
  801686:	e8 37 eb ff ff       	call   8001c2 <cprintf>
		return -E_INVAL;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801693:	eb da                	jmp    80166f <write+0x59>
		return -E_NOT_SUPP;
  801695:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80169a:	eb d3                	jmp    80166f <write+0x59>

0080169c <seek>:

int
seek(int fdnum, off_t offset)
{
  80169c:	f3 0f 1e fb          	endbr32 
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	ff 75 08             	pushl  0x8(%ebp)
  8016ad:	e8 0b fc ff ff       	call   8012bd <fd_lookup>
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 0e                	js     8016c7 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8016b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c9:	f3 0f 1e fb          	endbr32 
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 1c             	sub    $0x1c,%esp
  8016d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	53                   	push   %ebx
  8016dc:	e8 dc fb ff ff       	call   8012bd <fd_lookup>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 37                	js     80171f <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f2:	ff 30                	pushl  (%eax)
  8016f4:	e8 18 fc ff ff       	call   801311 <dev_lookup>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 1f                	js     80171f <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801700:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801703:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801707:	74 1b                	je     801724 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801709:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170c:	8b 52 18             	mov    0x18(%edx),%edx
  80170f:	85 d2                	test   %edx,%edx
  801711:	74 32                	je     801745 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	ff 75 0c             	pushl  0xc(%ebp)
  801719:	50                   	push   %eax
  80171a:	ff d2                	call   *%edx
  80171c:	83 c4 10             	add    $0x10,%esp
}
  80171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801722:	c9                   	leave  
  801723:	c3                   	ret    
			thisenv->env_id, fdnum);
  801724:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801729:	8b 40 48             	mov    0x48(%eax),%eax
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	53                   	push   %ebx
  801730:	50                   	push   %eax
  801731:	68 d0 29 80 00       	push   $0x8029d0
  801736:	e8 87 ea ff ff       	call   8001c2 <cprintf>
		return -E_INVAL;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801743:	eb da                	jmp    80171f <ftruncate+0x56>
		return -E_NOT_SUPP;
  801745:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80174a:	eb d3                	jmp    80171f <ftruncate+0x56>

0080174c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80174c:	f3 0f 1e fb          	endbr32 
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	53                   	push   %ebx
  801754:	83 ec 1c             	sub    $0x1c,%esp
  801757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	ff 75 08             	pushl  0x8(%ebp)
  801761:	e8 57 fb ff ff       	call   8012bd <fd_lookup>
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 4b                	js     8017b8 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801773:	50                   	push   %eax
  801774:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801777:	ff 30                	pushl  (%eax)
  801779:	e8 93 fb ff ff       	call   801311 <dev_lookup>
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	78 33                	js     8017b8 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801788:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178c:	74 2f                	je     8017bd <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80178e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801791:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801798:	00 00 00 
	stat->st_isdir = 0;
  80179b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a2:	00 00 00 
	stat->st_dev = dev;
  8017a5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	53                   	push   %ebx
  8017af:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b2:	ff 50 14             	call   *0x14(%eax)
  8017b5:	83 c4 10             	add    $0x10,%esp
}
  8017b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    
		return -E_NOT_SUPP;
  8017bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017c2:	eb f4                	jmp    8017b8 <fstat+0x6c>

008017c4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c4:	f3 0f 1e fb          	endbr32 
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	6a 00                	push   $0x0
  8017d2:	ff 75 08             	pushl  0x8(%ebp)
  8017d5:	e8 fb 01 00 00       	call   8019d5 <open>
  8017da:	89 c3                	mov    %eax,%ebx
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 1b                	js     8017fe <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	ff 75 0c             	pushl  0xc(%ebp)
  8017e9:	50                   	push   %eax
  8017ea:	e8 5d ff ff ff       	call   80174c <fstat>
  8017ef:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f1:	89 1c 24             	mov    %ebx,(%esp)
  8017f4:	e8 fd fb ff ff       	call   8013f6 <close>
	return r;
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	89 f3                	mov    %esi,%ebx
}
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	89 c6                	mov    %eax,%esi
  80180e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801810:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801817:	74 27                	je     801840 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801819:	6a 07                	push   $0x7
  80181b:	68 00 50 80 00       	push   $0x805000
  801820:	56                   	push   %esi
  801821:	ff 35 00 40 80 00    	pushl  0x804000
  801827:	e8 8c 08 00 00       	call   8020b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80182c:	83 c4 0c             	add    $0xc,%esp
  80182f:	6a 00                	push   $0x0
  801831:	53                   	push   %ebx
  801832:	6a 00                	push   $0x0
  801834:	e8 11 08 00 00       	call   80204a <ipc_recv>
}
  801839:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183c:	5b                   	pop    %ebx
  80183d:	5e                   	pop    %esi
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	6a 01                	push   $0x1
  801845:	e8 d3 08 00 00       	call   80211d <ipc_find_env>
  80184a:	a3 00 40 80 00       	mov    %eax,0x804000
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	eb c5                	jmp    801819 <fsipc+0x12>

00801854 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801854:	f3 0f 1e fb          	endbr32 
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185e:	8b 45 08             	mov    0x8(%ebp),%eax
  801861:	8b 40 0c             	mov    0xc(%eax),%eax
  801864:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	b8 02 00 00 00       	mov    $0x2,%eax
  80187b:	e8 87 ff ff ff       	call   801807 <fsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devfile_flush>:
{
  801882:	f3 0f 1e fb          	endbr32 
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a1:	e8 61 ff ff ff       	call   801807 <fsipc>
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devfile_stat>:
{
  8018a8:	f3 0f 1e fb          	endbr32 
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 04             	sub    $0x4,%esp
  8018b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8018cb:	e8 37 ff ff ff       	call   801807 <fsipc>
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 2c                	js     801900 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	68 00 50 80 00       	push   $0x805000
  8018dc:	53                   	push   %ebx
  8018dd:	e8 4a ee ff ff       	call   80072c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8018f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <devfile_write>:
{
  801905:	f3 0f 1e fb          	endbr32 
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	83 ec 0c             	sub    $0xc,%esp
  80190f:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801912:	8b 55 08             	mov    0x8(%ebp),%edx
  801915:	8b 52 0c             	mov    0xc(%edx),%edx
  801918:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80191e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801923:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801928:	0f 47 c2             	cmova  %edx,%eax
  80192b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801930:	50                   	push   %eax
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	68 08 50 80 00       	push   $0x805008
  801939:	e8 a6 ef ff ff       	call   8008e4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80193e:	ba 00 00 00 00       	mov    $0x0,%edx
  801943:	b8 04 00 00 00       	mov    $0x4,%eax
  801948:	e8 ba fe ff ff       	call   801807 <fsipc>
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <devfile_read>:
{
  80194f:	f3 0f 1e fb          	endbr32 
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	8b 40 0c             	mov    0xc(%eax),%eax
  801961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801966:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196c:	ba 00 00 00 00       	mov    $0x0,%edx
  801971:	b8 03 00 00 00       	mov    $0x3,%eax
  801976:	e8 8c fe ff ff       	call   801807 <fsipc>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 1f                	js     8019a0 <devfile_read+0x51>
	assert(r <= n);
  801981:	39 f0                	cmp    %esi,%eax
  801983:	77 24                	ja     8019a9 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801985:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198a:	7f 33                	jg     8019bf <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	50                   	push   %eax
  801990:	68 00 50 80 00       	push   $0x805000
  801995:	ff 75 0c             	pushl  0xc(%ebp)
  801998:	e8 47 ef ff ff       	call   8008e4 <memmove>
	return r;
  80199d:	83 c4 10             	add    $0x10,%esp
}
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    
	assert(r <= n);
  8019a9:	68 3c 2a 80 00       	push   $0x802a3c
  8019ae:	68 43 2a 80 00       	push   $0x802a43
  8019b3:	6a 7c                	push   $0x7c
  8019b5:	68 58 2a 80 00       	push   $0x802a58
  8019ba:	e8 be 05 00 00       	call   801f7d <_panic>
	assert(r <= PGSIZE);
  8019bf:	68 63 2a 80 00       	push   $0x802a63
  8019c4:	68 43 2a 80 00       	push   $0x802a43
  8019c9:	6a 7d                	push   $0x7d
  8019cb:	68 58 2a 80 00       	push   $0x802a58
  8019d0:	e8 a8 05 00 00       	call   801f7d <_panic>

008019d5 <open>:
{
  8019d5:	f3 0f 1e fb          	endbr32 
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	56                   	push   %esi
  8019dd:	53                   	push   %ebx
  8019de:	83 ec 1c             	sub    $0x1c,%esp
  8019e1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019e4:	56                   	push   %esi
  8019e5:	e8 ff ec ff ff       	call   8006e9 <strlen>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f2:	7f 6c                	jg     801a60 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fa:	50                   	push   %eax
  8019fb:	e8 67 f8 ff ff       	call   801267 <fd_alloc>
  801a00:	89 c3                	mov    %eax,%ebx
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 3c                	js     801a45 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	56                   	push   %esi
  801a0d:	68 00 50 80 00       	push   $0x805000
  801a12:	e8 15 ed ff ff       	call   80072c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a22:	b8 01 00 00 00       	mov    $0x1,%eax
  801a27:	e8 db fd ff ff       	call   801807 <fsipc>
  801a2c:	89 c3                	mov    %eax,%ebx
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 19                	js     801a4e <open+0x79>
	return fd2num(fd);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3b:	e8 f4 f7 ff ff       	call   801234 <fd2num>
  801a40:	89 c3                	mov    %eax,%ebx
  801a42:	83 c4 10             	add    $0x10,%esp
}
  801a45:	89 d8                	mov    %ebx,%eax
  801a47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    
		fd_close(fd, 0);
  801a4e:	83 ec 08             	sub    $0x8,%esp
  801a51:	6a 00                	push   $0x0
  801a53:	ff 75 f4             	pushl  -0xc(%ebp)
  801a56:	e8 10 f9 ff ff       	call   80136b <fd_close>
		return r;
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb e5                	jmp    801a45 <open+0x70>
		return -E_BAD_PATH;
  801a60:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a65:	eb de                	jmp    801a45 <open+0x70>

00801a67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a67:	f3 0f 1e fb          	endbr32 
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7b:	e8 87 fd ff ff       	call   801807 <fsipc>
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a82:	f3 0f 1e fb          	endbr32 
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	ff 75 08             	pushl  0x8(%ebp)
  801a94:	e8 af f7 ff ff       	call   801248 <fd2data>
  801a99:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a9b:	83 c4 08             	add    $0x8,%esp
  801a9e:	68 6f 2a 80 00       	push   $0x802a6f
  801aa3:	53                   	push   %ebx
  801aa4:	e8 83 ec ff ff       	call   80072c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa9:	8b 46 04             	mov    0x4(%esi),%eax
  801aac:	2b 06                	sub    (%esi),%eax
  801aae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801abb:	00 00 00 
	stat->st_dev = &devpipe;
  801abe:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ac5:	30 80 00 
	return 0;
}
  801ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  801acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad0:	5b                   	pop    %ebx
  801ad1:	5e                   	pop    %esi
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    

00801ad4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad4:	f3 0f 1e fb          	endbr32 
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	53                   	push   %ebx
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae2:	53                   	push   %ebx
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 1c f1 ff ff       	call   800c06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aea:	89 1c 24             	mov    %ebx,(%esp)
  801aed:	e8 56 f7 ff ff       	call   801248 <fd2data>
  801af2:	83 c4 08             	add    $0x8,%esp
  801af5:	50                   	push   %eax
  801af6:	6a 00                	push   $0x0
  801af8:	e8 09 f1 ff ff       	call   800c06 <sys_page_unmap>
}
  801afd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <_pipeisclosed>:
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	57                   	push   %edi
  801b06:	56                   	push   %esi
  801b07:	53                   	push   %ebx
  801b08:	83 ec 1c             	sub    $0x1c,%esp
  801b0b:	89 c7                	mov    %eax,%edi
  801b0d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b0f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b14:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	57                   	push   %edi
  801b1b:	e8 3a 06 00 00       	call   80215a <pageref>
  801b20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b23:	89 34 24             	mov    %esi,(%esp)
  801b26:	e8 2f 06 00 00       	call   80215a <pageref>
		nn = thisenv->env_runs;
  801b2b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	39 cb                	cmp    %ecx,%ebx
  801b39:	74 1b                	je     801b56 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b3b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b3e:	75 cf                	jne    801b0f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b40:	8b 42 58             	mov    0x58(%edx),%eax
  801b43:	6a 01                	push   $0x1
  801b45:	50                   	push   %eax
  801b46:	53                   	push   %ebx
  801b47:	68 76 2a 80 00       	push   $0x802a76
  801b4c:	e8 71 e6 ff ff       	call   8001c2 <cprintf>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	eb b9                	jmp    801b0f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b56:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b59:	0f 94 c0             	sete   %al
  801b5c:	0f b6 c0             	movzbl %al,%eax
}
  801b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <devpipe_write>:
{
  801b67:	f3 0f 1e fb          	endbr32 
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	57                   	push   %edi
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	83 ec 28             	sub    $0x28,%esp
  801b74:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b77:	56                   	push   %esi
  801b78:	e8 cb f6 ff ff       	call   801248 <fd2data>
  801b7d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	bf 00 00 00 00       	mov    $0x0,%edi
  801b87:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8a:	74 4f                	je     801bdb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8f:	8b 0b                	mov    (%ebx),%ecx
  801b91:	8d 51 20             	lea    0x20(%ecx),%edx
  801b94:	39 d0                	cmp    %edx,%eax
  801b96:	72 14                	jb     801bac <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b98:	89 da                	mov    %ebx,%edx
  801b9a:	89 f0                	mov    %esi,%eax
  801b9c:	e8 61 ff ff ff       	call   801b02 <_pipeisclosed>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	75 3b                	jne    801be0 <devpipe_write+0x79>
			sys_yield();
  801ba5:	e8 df ef ff ff       	call   800b89 <sys_yield>
  801baa:	eb e0                	jmp    801b8c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801baf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	c1 fa 1f             	sar    $0x1f,%edx
  801bbb:	89 d1                	mov    %edx,%ecx
  801bbd:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc3:	83 e2 1f             	and    $0x1f,%edx
  801bc6:	29 ca                	sub    %ecx,%edx
  801bc8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bcc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd0:	83 c0 01             	add    $0x1,%eax
  801bd3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bd6:	83 c7 01             	add    $0x1,%edi
  801bd9:	eb ac                	jmp    801b87 <devpipe_write+0x20>
	return i;
  801bdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bde:	eb 05                	jmp    801be5 <devpipe_write+0x7e>
				return 0;
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5f                   	pop    %edi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devpipe_read>:
{
  801bed:	f3 0f 1e fb          	endbr32 
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 18             	sub    $0x18,%esp
  801bfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bfd:	57                   	push   %edi
  801bfe:	e8 45 f6 ff ff       	call   801248 <fd2data>
  801c03:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	be 00 00 00 00       	mov    $0x0,%esi
  801c0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c10:	75 14                	jne    801c26 <devpipe_read+0x39>
	return i;
  801c12:	8b 45 10             	mov    0x10(%ebp),%eax
  801c15:	eb 02                	jmp    801c19 <devpipe_read+0x2c>
				return i;
  801c17:	89 f0                	mov    %esi,%eax
}
  801c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5f                   	pop    %edi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    
			sys_yield();
  801c21:	e8 63 ef ff ff       	call   800b89 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c26:	8b 03                	mov    (%ebx),%eax
  801c28:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c2b:	75 18                	jne    801c45 <devpipe_read+0x58>
			if (i > 0)
  801c2d:	85 f6                	test   %esi,%esi
  801c2f:	75 e6                	jne    801c17 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	89 f8                	mov    %edi,%eax
  801c35:	e8 c8 fe ff ff       	call   801b02 <_pipeisclosed>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	74 e3                	je     801c21 <devpipe_read+0x34>
				return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c43:	eb d4                	jmp    801c19 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c45:	99                   	cltd   
  801c46:	c1 ea 1b             	shr    $0x1b,%edx
  801c49:	01 d0                	add    %edx,%eax
  801c4b:	83 e0 1f             	and    $0x1f,%eax
  801c4e:	29 d0                	sub    %edx,%eax
  801c50:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c58:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c5b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c5e:	83 c6 01             	add    $0x1,%esi
  801c61:	eb aa                	jmp    801c0d <devpipe_read+0x20>

00801c63 <pipe>:
{
  801c63:	f3 0f 1e fb          	endbr32 
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	56                   	push   %esi
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c72:	50                   	push   %eax
  801c73:	e8 ef f5 ff ff       	call   801267 <fd_alloc>
  801c78:	89 c3                	mov    %eax,%ebx
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	0f 88 23 01 00 00    	js     801da8 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c85:	83 ec 04             	sub    $0x4,%esp
  801c88:	68 07 04 00 00       	push   $0x407
  801c8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c90:	6a 00                	push   $0x0
  801c92:	e8 1d ef ff ff       	call   800bb4 <sys_page_alloc>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	0f 88 04 01 00 00    	js     801da8 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ca4:	83 ec 0c             	sub    $0xc,%esp
  801ca7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801caa:	50                   	push   %eax
  801cab:	e8 b7 f5 ff ff       	call   801267 <fd_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	0f 88 db 00 00 00    	js     801d98 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbd:	83 ec 04             	sub    $0x4,%esp
  801cc0:	68 07 04 00 00       	push   $0x407
  801cc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 e5 ee ff ff       	call   800bb4 <sys_page_alloc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	0f 88 bc 00 00 00    	js     801d98 <pipe+0x135>
	va = fd2data(fd0);
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce2:	e8 61 f5 ff ff       	call   801248 <fd2data>
  801ce7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce9:	83 c4 0c             	add    $0xc,%esp
  801cec:	68 07 04 00 00       	push   $0x407
  801cf1:	50                   	push   %eax
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 bb ee ff ff       	call   800bb4 <sys_page_alloc>
  801cf9:	89 c3                	mov    %eax,%ebx
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	0f 88 82 00 00 00    	js     801d88 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0c:	e8 37 f5 ff ff       	call   801248 <fd2data>
  801d11:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d18:	50                   	push   %eax
  801d19:	6a 00                	push   $0x0
  801d1b:	56                   	push   %esi
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 b9 ee ff ff       	call   800bdc <sys_page_map>
  801d23:	89 c3                	mov    %eax,%ebx
  801d25:	83 c4 20             	add    $0x20,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	78 4e                	js     801d7a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d2c:	a1 20 30 80 00       	mov    0x803020,%eax
  801d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d34:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d39:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d40:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d43:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff 75 f4             	pushl  -0xc(%ebp)
  801d55:	e8 da f4 ff ff       	call   801234 <fd2num>
  801d5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d5f:	83 c4 04             	add    $0x4,%esp
  801d62:	ff 75 f0             	pushl  -0x10(%ebp)
  801d65:	e8 ca f4 ff ff       	call   801234 <fd2num>
  801d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d78:	eb 2e                	jmp    801da8 <pipe+0x145>
	sys_page_unmap(0, va);
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	56                   	push   %esi
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 81 ee ff ff       	call   800c06 <sys_page_unmap>
  801d85:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d88:	83 ec 08             	sub    $0x8,%esp
  801d8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 71 ee ff ff       	call   800c06 <sys_page_unmap>
  801d95:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 61 ee ff ff       	call   800c06 <sys_page_unmap>
  801da5:	83 c4 10             	add    $0x10,%esp
}
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <pipeisclosed>:
{
  801db1:	f3 0f 1e fb          	endbr32 
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbe:	50                   	push   %eax
  801dbf:	ff 75 08             	pushl  0x8(%ebp)
  801dc2:	e8 f6 f4 ff ff       	call   8012bd <fd_lookup>
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 18                	js     801de6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	e8 6f f4 ff ff       	call   801248 <fd2data>
  801dd9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dde:	e8 1f fd ff ff       	call   801b02 <_pipeisclosed>
  801de3:	83 c4 10             	add    $0x10,%esp
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801de8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
  801df1:	c3                   	ret    

00801df2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df2:	f3 0f 1e fb          	endbr32 
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dfc:	68 8e 2a 80 00       	push   $0x802a8e
  801e01:	ff 75 0c             	pushl  0xc(%ebp)
  801e04:	e8 23 e9 ff ff       	call   80072c <strcpy>
	return 0;
}
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <devcons_write>:
{
  801e10:	f3 0f 1e fb          	endbr32 
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e20:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e25:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2e:	73 31                	jae    801e61 <devcons_write+0x51>
		m = n - tot;
  801e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e33:	29 f3                	sub    %esi,%ebx
  801e35:	83 fb 7f             	cmp    $0x7f,%ebx
  801e38:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e3d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	53                   	push   %ebx
  801e44:	89 f0                	mov    %esi,%eax
  801e46:	03 45 0c             	add    0xc(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	57                   	push   %edi
  801e4b:	e8 94 ea ff ff       	call   8008e4 <memmove>
		sys_cputs(buf, m);
  801e50:	83 c4 08             	add    $0x8,%esp
  801e53:	53                   	push   %ebx
  801e54:	57                   	push   %edi
  801e55:	e8 8f ec ff ff       	call   800ae9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e5a:	01 de                	add    %ebx,%esi
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	eb ca                	jmp    801e2b <devcons_write+0x1b>
}
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <devcons_read>:
{
  801e6b:	f3 0f 1e fb          	endbr32 
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7e:	74 21                	je     801ea1 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e80:	e8 8e ec ff ff       	call   800b13 <sys_cgetc>
  801e85:	85 c0                	test   %eax,%eax
  801e87:	75 07                	jne    801e90 <devcons_read+0x25>
		sys_yield();
  801e89:	e8 fb ec ff ff       	call   800b89 <sys_yield>
  801e8e:	eb f0                	jmp    801e80 <devcons_read+0x15>
	if (c < 0)
  801e90:	78 0f                	js     801ea1 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e92:	83 f8 04             	cmp    $0x4,%eax
  801e95:	74 0c                	je     801ea3 <devcons_read+0x38>
	*(char*)vbuf = c;
  801e97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9a:	88 02                	mov    %al,(%edx)
	return 1;
  801e9c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    
		return 0;
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	eb f7                	jmp    801ea1 <devcons_read+0x36>

00801eaa <cputchar>:
{
  801eaa:	f3 0f 1e fb          	endbr32 
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801eba:	6a 01                	push   $0x1
  801ebc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebf:	50                   	push   %eax
  801ec0:	e8 24 ec ff ff       	call   800ae9 <sys_cputs>
}
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <getchar>:
{
  801eca:	f3 0f 1e fb          	endbr32 
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ed4:	6a 01                	push   $0x1
  801ed6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed9:	50                   	push   %eax
  801eda:	6a 00                	push   $0x0
  801edc:	e8 5f f6 ff ff       	call   801540 <read>
	if (r < 0)
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 06                	js     801eee <getchar+0x24>
	if (r < 1)
  801ee8:	74 06                	je     801ef0 <getchar+0x26>
	return c;
  801eea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    
		return -E_EOF;
  801ef0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ef5:	eb f7                	jmp    801eee <getchar+0x24>

00801ef7 <iscons>:
{
  801ef7:	f3 0f 1e fb          	endbr32 
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	ff 75 08             	pushl  0x8(%ebp)
  801f08:	e8 b0 f3 ff ff       	call   8012bd <fd_lookup>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 11                	js     801f25 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f17:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1d:	39 10                	cmp    %edx,(%eax)
  801f1f:	0f 94 c0             	sete   %al
  801f22:	0f b6 c0             	movzbl %al,%eax
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <opencons>:
{
  801f27:	f3 0f 1e fb          	endbr32 
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f34:	50                   	push   %eax
  801f35:	e8 2d f3 ff ff       	call   801267 <fd_alloc>
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 3a                	js     801f7b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f41:	83 ec 04             	sub    $0x4,%esp
  801f44:	68 07 04 00 00       	push   $0x407
  801f49:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4c:	6a 00                	push   $0x0
  801f4e:	e8 61 ec ff ff       	call   800bb4 <sys_page_alloc>
  801f53:	83 c4 10             	add    $0x10,%esp
  801f56:	85 c0                	test   %eax,%eax
  801f58:	78 21                	js     801f7b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f63:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f68:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f6f:	83 ec 0c             	sub    $0xc,%esp
  801f72:	50                   	push   %eax
  801f73:	e8 bc f2 ff ff       	call   801234 <fd2num>
  801f78:	83 c4 10             	add    $0x10,%esp
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f7d:	f3 0f 1e fb          	endbr32 
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f86:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f89:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f8f:	e8 cd eb ff ff       	call   800b61 <sys_getenvid>
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	ff 75 0c             	pushl  0xc(%ebp)
  801f9a:	ff 75 08             	pushl  0x8(%ebp)
  801f9d:	56                   	push   %esi
  801f9e:	50                   	push   %eax
  801f9f:	68 9c 2a 80 00       	push   $0x802a9c
  801fa4:	e8 19 e2 ff ff       	call   8001c2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fa9:	83 c4 18             	add    $0x18,%esp
  801fac:	53                   	push   %ebx
  801fad:	ff 75 10             	pushl  0x10(%ebp)
  801fb0:	e8 b8 e1 ff ff       	call   80016d <vcprintf>
	cprintf("\n");
  801fb5:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  801fbc:	e8 01 e2 ff ff       	call   8001c2 <cprintf>
  801fc1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc4:	cc                   	int3   
  801fc5:	eb fd                	jmp    801fc4 <_panic+0x47>

00801fc7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fc7:	f3 0f 1e fb          	endbr32 
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fd1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fd8:	74 1c                	je     801ff6 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fda:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdd:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  801fe2:	83 ec 08             	sub    $0x8,%esp
  801fe5:	68 22 20 80 00       	push   $0x802022
  801fea:	6a 00                	push   $0x0
  801fec:	e8 8a ec ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
}
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  801ff6:	83 ec 04             	sub    $0x4,%esp
  801ff9:	6a 02                	push   $0x2
  801ffb:	68 00 f0 bf ee       	push   $0xeebff000
  802000:	6a 00                	push   $0x0
  802002:	e8 ad eb ff ff       	call   800bb4 <sys_page_alloc>
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	85 c0                	test   %eax,%eax
  80200c:	79 cc                	jns    801fda <set_pgfault_handler+0x13>
  80200e:	83 ec 04             	sub    $0x4,%esp
  802011:	68 bf 2a 80 00       	push   $0x802abf
  802016:	6a 20                	push   $0x20
  802018:	68 da 2a 80 00       	push   $0x802ada
  80201d:	e8 5b ff ff ff       	call   801f7d <_panic>

00802022 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802022:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802023:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802028:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80202a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  80202d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  802031:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  802035:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  802038:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  80203a:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80203e:	83 c4 08             	add    $0x8,%esp
	popal
  802041:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802042:	83 c4 04             	add    $0x4,%esp
	popfl
  802045:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802046:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802049:	c3                   	ret    

0080204a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80204a:	f3 0f 1e fb          	endbr32 
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	56                   	push   %esi
  802052:	53                   	push   %ebx
  802053:	8b 75 08             	mov    0x8(%ebp),%esi
  802056:	8b 45 0c             	mov    0xc(%ebp),%eax
  802059:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  80205c:	85 c0                	test   %eax,%eax
  80205e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802063:	0f 44 c2             	cmove  %edx,%eax
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	50                   	push   %eax
  80206a:	e8 5c ec ff ff       	call   800ccb <sys_ipc_recv>

	if (from_env_store != NULL)
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 f6                	test   %esi,%esi
  802074:	74 15                	je     80208b <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  802076:	ba 00 00 00 00       	mov    $0x0,%edx
  80207b:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80207e:	74 09                	je     802089 <ipc_recv+0x3f>
  802080:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802086:	8b 52 74             	mov    0x74(%edx),%edx
  802089:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  80208b:	85 db                	test   %ebx,%ebx
  80208d:	74 15                	je     8020a4 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  80208f:	ba 00 00 00 00       	mov    $0x0,%edx
  802094:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802097:	74 09                	je     8020a2 <ipc_recv+0x58>
  802099:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80209f:	8b 52 78             	mov    0x78(%edx),%edx
  8020a2:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8020a4:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020a7:	74 08                	je     8020b1 <ipc_recv+0x67>
  8020a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b8:	f3 0f 1e fb          	endbr32 
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	57                   	push   %edi
  8020c0:	56                   	push   %esi
  8020c1:	53                   	push   %ebx
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020ce:	eb 1f                	jmp    8020ef <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8020d0:	6a 00                	push   $0x0
  8020d2:	68 00 00 c0 ee       	push   $0xeec00000
  8020d7:	56                   	push   %esi
  8020d8:	57                   	push   %edi
  8020d9:	e8 c4 eb ff ff       	call   800ca2 <sys_ipc_try_send>
  8020de:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	74 30                	je     802115 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8020e5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e8:	75 19                	jne    802103 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8020ea:	e8 9a ea ff ff       	call   800b89 <sys_yield>
		if (pg != NULL) {
  8020ef:	85 db                	test   %ebx,%ebx
  8020f1:	74 dd                	je     8020d0 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8020f3:	ff 75 14             	pushl  0x14(%ebp)
  8020f6:	53                   	push   %ebx
  8020f7:	56                   	push   %esi
  8020f8:	57                   	push   %edi
  8020f9:	e8 a4 eb ff ff       	call   800ca2 <sys_ipc_try_send>
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	eb de                	jmp    8020e1 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  802103:	50                   	push   %eax
  802104:	68 e8 2a 80 00       	push   $0x802ae8
  802109:	6a 3e                	push   $0x3e
  80210b:	68 f5 2a 80 00       	push   $0x802af5
  802110:	e8 68 fe ff ff       	call   801f7d <_panic>
	}
}
  802115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80211d:	f3 0f 1e fb          	endbr32 
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80212c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80212f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802135:	8b 52 50             	mov    0x50(%edx),%edx
  802138:	39 ca                	cmp    %ecx,%edx
  80213a:	74 11                	je     80214d <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80213c:	83 c0 01             	add    $0x1,%eax
  80213f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802144:	75 e6                	jne    80212c <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802146:	b8 00 00 00 00       	mov    $0x0,%eax
  80214b:	eb 0b                	jmp    802158 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80214d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802150:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802155:	8b 40 48             	mov    0x48(%eax),%eax
}
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80215a:	f3 0f 1e fb          	endbr32 
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802164:	89 c2                	mov    %eax,%edx
  802166:	c1 ea 16             	shr    $0x16,%edx
  802169:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802170:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802175:	f6 c1 01             	test   $0x1,%cl
  802178:	74 1c                	je     802196 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80217a:	c1 e8 0c             	shr    $0xc,%eax
  80217d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802184:	a8 01                	test   $0x1,%al
  802186:	74 0e                	je     802196 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802188:	c1 e8 0c             	shr    $0xc,%eax
  80218b:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802192:	ef 
  802193:	0f b7 d2             	movzwl %dx,%edx
}
  802196:	89 d0                	mov    %edx,%eax
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__udivdi3>:
  8021a0:	f3 0f 1e fb          	endbr32 
  8021a4:	55                   	push   %ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 1c             	sub    $0x1c,%esp
  8021ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021bb:	85 d2                	test   %edx,%edx
  8021bd:	75 19                	jne    8021d8 <__udivdi3+0x38>
  8021bf:	39 f3                	cmp    %esi,%ebx
  8021c1:	76 4d                	jbe    802210 <__udivdi3+0x70>
  8021c3:	31 ff                	xor    %edi,%edi
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	89 f2                	mov    %esi,%edx
  8021c9:	f7 f3                	div    %ebx
  8021cb:	89 fa                	mov    %edi,%edx
  8021cd:	83 c4 1c             	add    $0x1c,%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	76 14                	jbe    8021f0 <__udivdi3+0x50>
  8021dc:	31 ff                	xor    %edi,%edi
  8021de:	31 c0                	xor    %eax,%eax
  8021e0:	89 fa                	mov    %edi,%edx
  8021e2:	83 c4 1c             	add    $0x1c,%esp
  8021e5:	5b                   	pop    %ebx
  8021e6:	5e                   	pop    %esi
  8021e7:	5f                   	pop    %edi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    
  8021ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f0:	0f bd fa             	bsr    %edx,%edi
  8021f3:	83 f7 1f             	xor    $0x1f,%edi
  8021f6:	75 48                	jne    802240 <__udivdi3+0xa0>
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	72 06                	jb     802202 <__udivdi3+0x62>
  8021fc:	31 c0                	xor    %eax,%eax
  8021fe:	39 eb                	cmp    %ebp,%ebx
  802200:	77 de                	ja     8021e0 <__udivdi3+0x40>
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
  802207:	eb d7                	jmp    8021e0 <__udivdi3+0x40>
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d9                	mov    %ebx,%ecx
  802212:	85 db                	test   %ebx,%ebx
  802214:	75 0b                	jne    802221 <__udivdi3+0x81>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f3                	div    %ebx
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	31 d2                	xor    %edx,%edx
  802223:	89 f0                	mov    %esi,%eax
  802225:	f7 f1                	div    %ecx
  802227:	89 c6                	mov    %eax,%esi
  802229:	89 e8                	mov    %ebp,%eax
  80222b:	89 f7                	mov    %esi,%edi
  80222d:	f7 f1                	div    %ecx
  80222f:	89 fa                	mov    %edi,%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 f9                	mov    %edi,%ecx
  802242:	b8 20 00 00 00       	mov    $0x20,%eax
  802247:	29 f8                	sub    %edi,%eax
  802249:	d3 e2                	shl    %cl,%edx
  80224b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	89 da                	mov    %ebx,%edx
  802253:	d3 ea                	shr    %cl,%edx
  802255:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802259:	09 d1                	or     %edx,%ecx
  80225b:	89 f2                	mov    %esi,%edx
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e3                	shl    %cl,%ebx
  802265:	89 c1                	mov    %eax,%ecx
  802267:	d3 ea                	shr    %cl,%edx
  802269:	89 f9                	mov    %edi,%ecx
  80226b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80226f:	89 eb                	mov    %ebp,%ebx
  802271:	d3 e6                	shl    %cl,%esi
  802273:	89 c1                	mov    %eax,%ecx
  802275:	d3 eb                	shr    %cl,%ebx
  802277:	09 de                	or     %ebx,%esi
  802279:	89 f0                	mov    %esi,%eax
  80227b:	f7 74 24 08          	divl   0x8(%esp)
  80227f:	89 d6                	mov    %edx,%esi
  802281:	89 c3                	mov    %eax,%ebx
  802283:	f7 64 24 0c          	mull   0xc(%esp)
  802287:	39 d6                	cmp    %edx,%esi
  802289:	72 15                	jb     8022a0 <__udivdi3+0x100>
  80228b:	89 f9                	mov    %edi,%ecx
  80228d:	d3 e5                	shl    %cl,%ebp
  80228f:	39 c5                	cmp    %eax,%ebp
  802291:	73 04                	jae    802297 <__udivdi3+0xf7>
  802293:	39 d6                	cmp    %edx,%esi
  802295:	74 09                	je     8022a0 <__udivdi3+0x100>
  802297:	89 d8                	mov    %ebx,%eax
  802299:	31 ff                	xor    %edi,%edi
  80229b:	e9 40 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022a3:	31 ff                	xor    %edi,%edi
  8022a5:	e9 36 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	f3 0f 1e fb          	endbr32 
  8022b4:	55                   	push   %ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 1c             	sub    $0x1c,%esp
  8022bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	75 19                	jne    8022e8 <__umoddi3+0x38>
  8022cf:	39 df                	cmp    %ebx,%edi
  8022d1:	76 5d                	jbe    802330 <__umoddi3+0x80>
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	89 da                	mov    %ebx,%edx
  8022d7:	f7 f7                	div    %edi
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	83 c4 1c             	add    $0x1c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
  8022e8:	89 f2                	mov    %esi,%edx
  8022ea:	39 d8                	cmp    %ebx,%eax
  8022ec:	76 12                	jbe    802300 <__umoddi3+0x50>
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	89 da                	mov    %ebx,%edx
  8022f2:	83 c4 1c             	add    $0x1c,%esp
  8022f5:	5b                   	pop    %ebx
  8022f6:	5e                   	pop    %esi
  8022f7:	5f                   	pop    %edi
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    
  8022fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802300:	0f bd e8             	bsr    %eax,%ebp
  802303:	83 f5 1f             	xor    $0x1f,%ebp
  802306:	75 50                	jne    802358 <__umoddi3+0xa8>
  802308:	39 d8                	cmp    %ebx,%eax
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	39 f7                	cmp    %esi,%edi
  802314:	0f 86 d6 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	89 ca                	mov    %ecx,%edx
  80231e:	83 c4 1c             	add    $0x1c,%esp
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	89 fd                	mov    %edi,%ebp
  802332:	85 ff                	test   %edi,%edi
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 d8                	mov    %ebx,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 f0                	mov    %esi,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	31 d2                	xor    %edx,%edx
  80234f:	eb 8c                	jmp    8022dd <__umoddi3+0x2d>
  802351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	ba 20 00 00 00       	mov    $0x20,%edx
  80235f:	29 ea                	sub    %ebp,%edx
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 44 24 08          	mov    %eax,0x8(%esp)
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 f8                	mov    %edi,%eax
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802371:	89 54 24 04          	mov    %edx,0x4(%esp)
  802375:	8b 54 24 04          	mov    0x4(%esp),%edx
  802379:	09 c1                	or     %eax,%ecx
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 e9                	mov    %ebp,%ecx
  802383:	d3 e7                	shl    %cl,%edi
  802385:	89 d1                	mov    %edx,%ecx
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80238f:	d3 e3                	shl    %cl,%ebx
  802391:	89 c7                	mov    %eax,%edi
  802393:	89 d1                	mov    %edx,%ecx
  802395:	89 f0                	mov    %esi,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 fa                	mov    %edi,%edx
  80239d:	d3 e6                	shl    %cl,%esi
  80239f:	09 d8                	or     %ebx,%eax
  8023a1:	f7 74 24 08          	divl   0x8(%esp)
  8023a5:	89 d1                	mov    %edx,%ecx
  8023a7:	89 f3                	mov    %esi,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	89 c6                	mov    %eax,%esi
  8023af:	89 d7                	mov    %edx,%edi
  8023b1:	39 d1                	cmp    %edx,%ecx
  8023b3:	72 06                	jb     8023bb <__umoddi3+0x10b>
  8023b5:	75 10                	jne    8023c7 <__umoddi3+0x117>
  8023b7:	39 c3                	cmp    %eax,%ebx
  8023b9:	73 0c                	jae    8023c7 <__umoddi3+0x117>
  8023bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023c3:	89 d7                	mov    %edx,%edi
  8023c5:	89 c6                	mov    %eax,%esi
  8023c7:	89 ca                	mov    %ecx,%edx
  8023c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ce:	29 f3                	sub    %esi,%ebx
  8023d0:	19 fa                	sbb    %edi,%edx
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	d3 e0                	shl    %cl,%eax
  8023d6:	89 e9                	mov    %ebp,%ecx
  8023d8:	d3 eb                	shr    %cl,%ebx
  8023da:	d3 ea                	shr    %cl,%edx
  8023dc:	09 d8                	or     %ebx,%eax
  8023de:	83 c4 1c             	add    $0x1c,%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
  8023e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 fe                	sub    %edi,%esi
  8023f2:	19 c3                	sbb    %eax,%ebx
  8023f4:	89 f2                	mov    %esi,%edx
  8023f6:	89 d9                	mov    %ebx,%ecx
  8023f8:	e9 1d ff ff ff       	jmp    80231a <__umoddi3+0x6a>
