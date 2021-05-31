
obj/user/forktree.debug:     formato del fichero elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800041:	e8 51 0b 00 00       	call   800b97 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 40 24 80 00       	push   $0x802440
  800050:	e8 a3 01 00 00       	call   8001f8 <cprintf>

	forkchild(cur, '0');
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	6a 30                	push   $0x30
  80005a:	53                   	push   %ebx
  80005b:	e8 13 00 00 00       	call   800073 <forkchild>
	forkchild(cur, '1');
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	6a 31                	push   $0x31
  800065:	53                   	push   %ebx
  800066:	e8 08 00 00 00       	call   800073 <forkchild>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <forkchild>:
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	83 ec 1c             	sub    $0x1c,%esp
  80007f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800082:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  800085:	53                   	push   %ebx
  800086:	e8 94 06 00 00       	call   80071f <strlen>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 f8 02             	cmp    $0x2,%eax
  800091:	7e 07                	jle    80009a <forkchild+0x27>
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 51 24 80 00       	push   $0x802451
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 4d 06 00 00       	call   800701 <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 0d 10 00 00       	call   8010c9 <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 6c 00 00 00       	call   80013d <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	eb bd                	jmp    800093 <forkchild+0x20>

008000d6 <umain>:

void
umain(int argc, char **argv)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e0:	68 50 24 80 00       	push   $0x802450
  8000e5:	e8 49 ff ff ff       	call   800033 <forktree>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000fe:	e8 94 0a 00 00       	call   800b97 <sys_getenvid>
	if (id >= 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	78 12                	js     800119 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x35>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	e8 a8 ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  80012e:	e8 0a 00 00 00       	call   80013d <exit>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013d:	f3 0f 1e fb          	endbr32 
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800147:	e8 11 13 00 00       	call   80145d <close_all>
	sys_env_destroy(0);
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	6a 00                	push   $0x0
  800151:	e8 1b 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	f3 0f 1e fb          	endbr32 
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	53                   	push   %ebx
  800163:	83 ec 04             	sub    $0x4,%esp
  800166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800169:	8b 13                	mov    (%ebx),%edx
  80016b:	8d 42 01             	lea    0x1(%edx),%eax
  80016e:	89 03                	mov    %eax,(%ebx)
  800170:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800173:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800177:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017c:	74 09                	je     800187 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 87 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb db                	jmp    80017e <putch+0x23>

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 5b 01 80 00       	push   $0x80015b
  8001d6:	e8 80 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 2f 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	f3 0f 1e fb          	endbr32 
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 95 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 1c             	sub    $0x1c,%esp
  800219:	89 c7                	mov    %eax,%edi
  80021b:	89 d6                	mov    %edx,%esi
  80021d:	8b 45 08             	mov    0x8(%ebp),%eax
  800220:	8b 55 0c             	mov    0xc(%ebp),%edx
  800223:	89 d1                	mov    %edx,%ecx
  800225:	89 c2                	mov    %eax,%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022d:	8b 45 10             	mov    0x10(%ebp),%eax
  800230:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800233:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800236:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023d:	39 c2                	cmp    %eax,%edx
  80023f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800242:	72 3e                	jb     800282 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	53                   	push   %ebx
  80024e:	50                   	push   %eax
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 6d 1f 00 00       	call   8021d0 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9f ff ff ff       	call   800210 <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 13                	jmp    800289 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800282:	83 eb 01             	sub    $0x1,%ebx
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f ed                	jg     800276 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	83 ec 04             	sub    $0x4,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 3f 20 00 00       	call   8022e0 <__umoddi3>
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	0f be 80 60 24 80 00 	movsbl 0x802460(%eax),%eax
  8002ab:	50                   	push   %eax
  8002ac:	ff d7                	call   *%edi
}
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7f 13                	jg     8002d1 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002be:	85 d2                	test   %edx,%edx
  8002c0:	74 1c                	je     8002de <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	8b 52 04             	mov    0x4(%edx),%edx
  8002dd:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	c3                   	ret    

008002ed <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7f 0f                	jg     800301 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002f2:	85 d2                	test   %edx,%edx
  8002f4:	74 18                	je     80030e <getint+0x21>
		return va_arg(*ap, long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	99                   	cltd   
  800300:	c3                   	ret    
		return va_arg(*ap, long long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 08             	lea    0x8(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	8b 52 04             	mov    0x4(%edx),%edx
  80030d:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
}
  800318:	c3                   	ret    

00800319 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800319:	f3 0f 1e fb          	endbr32 
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800323:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800327:	8b 10                	mov    (%eax),%edx
  800329:	3b 50 04             	cmp    0x4(%eax),%edx
  80032c:	73 0a                	jae    800338 <sprintputch+0x1f>
		*b->buf++ = ch;
  80032e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800331:	89 08                	mov    %ecx,(%eax)
  800333:	8b 45 08             	mov    0x8(%ebp),%eax
  800336:	88 02                	mov    %al,(%edx)
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <printfmt>:
{
  80033a:	f3 0f 1e fb          	endbr32 
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	50                   	push   %eax
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	ff 75 0c             	pushl  0xc(%ebp)
  80034e:	ff 75 08             	pushl  0x8(%ebp)
  800351:	e8 05 00 00 00       	call   80035b <vprintfmt>
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
{
  80035b:	f3 0f 1e fb          	endbr32 
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	53                   	push   %ebx
  800365:	83 ec 2c             	sub    $0x2c,%esp
  800368:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80036b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800371:	e9 86 02 00 00       	jmp    8005fc <vprintfmt+0x2a1>
		padc = ' ';
  800376:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80037a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800381:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800388:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8d 47 01             	lea    0x1(%edi),%eax
  800397:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039a:	0f b6 17             	movzbl (%edi),%edx
  80039d:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003a0:	3c 55                	cmp    $0x55,%al
  8003a2:	0f 87 df 02 00 00    	ja     800687 <vprintfmt+0x32c>
  8003a8:	0f b6 c0             	movzbl %al,%eax
  8003ab:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  8003b2:	00 
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003b6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003ba:	eb d8                	jmp    800394 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bf:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003c3:	eb cf                	jmp    800394 <vprintfmt+0x39>
  8003c5:	0f b6 d2             	movzbl %dl,%edx
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003da:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003dd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003e0:	83 f9 09             	cmp    $0x9,%ecx
  8003e3:	77 52                	ja     800437 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003e8:	eb e9                	jmp    8003d3 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	79 93                	jns    800394 <vprintfmt+0x39>
				width = precision, precision = -1;
  800401:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800407:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80040e:	eb 84                	jmp    800394 <vprintfmt+0x39>
  800410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800413:	85 c0                	test   %eax,%eax
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
  80041a:	0f 49 d0             	cmovns %eax,%edx
  80041d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800423:	e9 6c ff ff ff       	jmp    800394 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80042b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800432:	e9 5d ff ff ff       	jmp    800394 <vprintfmt+0x39>
  800437:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80043d:	eb bc                	jmp    8003fb <vprintfmt+0xa0>
			lflag++;
  80043f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800445:	e9 4a ff ff ff       	jmp    800394 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	56                   	push   %esi
  800457:	ff 30                	pushl  (%eax)
  800459:	ff d3                	call   *%ebx
			break;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	e9 96 01 00 00       	jmp    8005f9 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 00                	mov    (%eax),%eax
  80046e:	99                   	cltd   
  80046f:	31 d0                	xor    %edx,%eax
  800471:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	83 f8 0f             	cmp    $0xf,%eax
  800476:	7f 20                	jg     800498 <vprintfmt+0x13d>
  800478:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	74 15                	je     800498 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 15 2a 80 00       	push   $0x802a15
  800489:	56                   	push   %esi
  80048a:	53                   	push   %ebx
  80048b:	e8 aa fe ff ff       	call   80033a <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	e9 61 01 00 00       	jmp    8005f9 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800498:	50                   	push   %eax
  800499:	68 78 24 80 00       	push   $0x802478
  80049e:	56                   	push   %esi
  80049f:	53                   	push   %ebx
  8004a0:	e8 95 fe ff ff       	call   80033a <printfmt>
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	e9 4c 01 00 00       	jmp    8005f9 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 71 24 80 00       	mov    $0x802471,%eax
  8004bf:	0f 45 c1             	cmovne %ecx,%eax
  8004c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	7e 06                	jle    8004d1 <vprintfmt+0x176>
  8004cb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cf:	75 0d                	jne    8004de <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 c7                	mov    %eax,%edi
  8004d6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dc:	eb 57                	jmp    800535 <vprintfmt+0x1da>
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e7:	e8 4f 02 00 00       	call   80073b <strnlen>
  8004ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ef:	29 c2                	sub    %eax,%edx
  8004f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004fe:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	85 db                	test   %ebx,%ebx
  800502:	7e 10                	jle    800514 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	56                   	push   %esi
  800508:	57                   	push   %edi
  800509:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 eb 01             	sub    $0x1,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	eb ec                	jmp    800500 <vprintfmt+0x1a5>
  800514:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800517:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	b8 00 00 00 00       	mov    $0x0,%eax
  800521:	0f 49 c2             	cmovns %edx,%eax
  800524:	29 c2                	sub    %eax,%edx
  800526:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800529:	eb a6                	jmp    8004d1 <vprintfmt+0x176>
					putch(ch, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	56                   	push   %esi
  80052f:	52                   	push   %edx
  800530:	ff d3                	call   *%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800538:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053a:	83 c7 01             	add    $0x1,%edi
  80053d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800541:	0f be d0             	movsbl %al,%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	74 42                	je     80058a <vprintfmt+0x22f>
  800548:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054c:	78 06                	js     800554 <vprintfmt+0x1f9>
  80054e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800552:	78 1e                	js     800572 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800554:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800558:	74 d1                	je     80052b <vprintfmt+0x1d0>
  80055a:	0f be c0             	movsbl %al,%eax
  80055d:	83 e8 20             	sub    $0x20,%eax
  800560:	83 f8 5e             	cmp    $0x5e,%eax
  800563:	76 c6                	jbe    80052b <vprintfmt+0x1d0>
					putch('?', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	56                   	push   %esi
  800569:	6a 3f                	push   $0x3f
  80056b:	ff d3                	call   *%ebx
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb c3                	jmp    800535 <vprintfmt+0x1da>
  800572:	89 cf                	mov    %ecx,%edi
  800574:	eb 0e                	jmp    800584 <vprintfmt+0x229>
				putch(' ', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	56                   	push   %esi
  80057a:	6a 20                	push   $0x20
  80057c:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80057e:	83 ef 01             	sub    $0x1,%edi
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	85 ff                	test   %edi,%edi
  800586:	7f ee                	jg     800576 <vprintfmt+0x21b>
  800588:	eb 6f                	jmp    8005f9 <vprintfmt+0x29e>
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	eb f6                	jmp    800584 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80058e:	89 ca                	mov    %ecx,%edx
  800590:	8d 45 14             	lea    0x14(%ebp),%eax
  800593:	e8 55 fd ff ff       	call   8002ed <getint>
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	78 0b                	js     8005ad <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005a2:	89 d1                	mov    %edx,%ecx
  8005a4:	89 c2                	mov    %eax,%edx
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	eb 32                	jmp    8005df <vprintfmt+0x284>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	56                   	push   %esi
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bb:	f7 da                	neg    %edx
  8005bd:	83 d1 00             	adc    $0x0,%ecx
  8005c0:	f7 d9                	neg    %ecx
  8005c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	eb 13                	jmp    8005df <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 e3 fc ff ff       	call   8002b9 <getuint>
  8005d6:	89 d1                	mov    %edx,%ecx
  8005d8:	89 c2                	mov    %eax,%edx
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005e6:	57                   	push   %edi
  8005e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ea:	50                   	push   %eax
  8005eb:	51                   	push   %ecx
  8005ec:	52                   	push   %edx
  8005ed:	89 f2                	mov    %esi,%edx
  8005ef:	89 d8                	mov    %ebx,%eax
  8005f1:	e8 1a fc ff ff       	call   800210 <printnum>
			break;
  8005f6:	83 c4 20             	add    $0x20,%esp
{
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005fc:	83 c7 01             	add    $0x1,%edi
  8005ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800603:	83 f8 25             	cmp    $0x25,%eax
  800606:	0f 84 6a fd ff ff    	je     800376 <vprintfmt+0x1b>
			if (ch == '\0')
  80060c:	85 c0                	test   %eax,%eax
  80060e:	0f 84 93 00 00 00    	je     8006a7 <vprintfmt+0x34c>
			putch(ch, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	56                   	push   %esi
  800618:	50                   	push   %eax
  800619:	ff d3                	call   *%ebx
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	eb dc                	jmp    8005fc <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 8f fc ff ff       	call   8002b9 <getuint>
  80062a:	89 d1                	mov    %edx,%ecx
  80062c:	89 c2                	mov    %eax,%edx
			base = 8;
  80062e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800633:	eb aa                	jmp    8005df <vprintfmt+0x284>
			putch('0', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	56                   	push   %esi
  800639:	6a 30                	push   $0x30
  80063b:	ff d3                	call   *%ebx
			putch('x', putdat);
  80063d:	83 c4 08             	add    $0x8,%esp
  800640:	56                   	push   %esi
  800641:	6a 78                	push   $0x78
  800643:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 50 04             	lea    0x4(%eax),%edx
  80064b:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800655:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800658:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065d:	eb 80                	jmp    8005df <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80065f:	89 ca                	mov    %ecx,%edx
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 50 fc ff ff       	call   8002b9 <getuint>
  800669:	89 d1                	mov    %edx,%ecx
  80066b:	89 c2                	mov    %eax,%edx
			base = 16;
  80066d:	b8 10 00 00 00       	mov    $0x10,%eax
  800672:	e9 68 ff ff ff       	jmp    8005df <vprintfmt+0x284>
			putch(ch, putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	56                   	push   %esi
  80067b:	6a 25                	push   $0x25
  80067d:	ff d3                	call   *%ebx
			break;
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	e9 72 ff ff ff       	jmp    8005f9 <vprintfmt+0x29e>
			putch('%', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	56                   	push   %esi
  80068b:	6a 25                	push   $0x25
  80068d:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	89 f8                	mov    %edi,%eax
  800694:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800698:	74 05                	je     80069f <vprintfmt+0x344>
  80069a:	83 e8 01             	sub    $0x1,%eax
  80069d:	eb f5                	jmp    800694 <vprintfmt+0x339>
  80069f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a2:	e9 52 ff ff ff       	jmp    8005f9 <vprintfmt+0x29e>
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006af:	f3 0f 1e fb          	endbr32 
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x4b>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 22                	jle    8006fa <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 19 03 80 00       	push   $0x800319
  8006e7:	e8 6f fc ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ff:	eb f7                	jmp    8006f8 <vsnprintf+0x49>

00800701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800701:	f3 0f 1e fb          	endbr32 
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	50                   	push   %eax
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	e8 92 ff ff ff       	call   8006af <vsnprintf>
	va_end(ap);

	return rc;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071f:	f3 0f 1e fb          	endbr32 
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	74 05                	je     800739 <strlen+0x1a>
		n++;
  800734:	83 c0 01             	add    $0x1,%eax
  800737:	eb f5                	jmp    80072e <strlen+0xf>
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	f3 0f 1e fb          	endbr32 
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	39 d0                	cmp    %edx,%eax
  80074f:	74 0d                	je     80075e <strnlen+0x23>
  800751:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800755:	74 05                	je     80075c <strnlen+0x21>
		n++;
  800757:	83 c0 01             	add    $0x1,%eax
  80075a:	eb f1                	jmp    80074d <strnlen+0x12>
  80075c:	89 c2                	mov    %eax,%edx
	return n;
}
  80075e:	89 d0                	mov    %edx,%eax
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800762:	f3 0f 1e fb          	endbr32 
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800779:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077c:	83 c0 01             	add    $0x1,%eax
  80077f:	84 d2                	test   %dl,%dl
  800781:	75 f2                	jne    800775 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800783:	89 c8                	mov    %ecx,%eax
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	f3 0f 1e fb          	endbr32 
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	83 ec 10             	sub    $0x10,%esp
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 83 ff ff ff       	call   80071f <strlen>
  80079c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	01 d8                	add    %ebx,%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 b8 ff ff ff       	call   800762 <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b1:	f3 0f 1e fb          	endbr32 
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	39 d8                	cmp    %ebx,%eax
  8007c9:	74 11                	je     8007dc <strncpy+0x2b>
		*dst++ = *src;
  8007cb:	83 c0 01             	add    $0x1,%eax
  8007ce:	0f b6 0a             	movzbl (%edx),%ecx
  8007d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 f9 01             	cmp    $0x1,%cl
  8007d7:	83 da ff             	sbb    $0xffffffff,%edx
  8007da:	eb eb                	jmp    8007c7 <strncpy+0x16>
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	f3 0f 1e fb          	endbr32 
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x39>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800800:	39 c2                	cmp    %eax,%edx
  800802:	74 14                	je     800818 <strlcpy+0x36>
  800804:	0f b6 19             	movzbl (%ecx),%ebx
  800807:	84 db                	test   %bl,%bl
  800809:	74 0b                	je     800816 <strlcpy+0x34>
			*dst++ = *src++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
  800814:	eb ea                	jmp    800800 <strlcpy+0x1e>
  800816:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	f3 0f 1e fb          	endbr32 
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 0c                	je     800841 <strcmp+0x20>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	75 08                	jne    800841 <strcmp+0x20>
		p++, q++;
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	eb ed                	jmp    80082e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	f3 0f 1e fb          	endbr32 
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 c3                	mov    %eax,%ebx
  80085b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strncmp+0x1b>
		n--, p++, q++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 16                	je     800880 <strncmp+0x35>
  80086a:	0f b6 08             	movzbl (%eax),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	74 04                	je     800875 <strncmp+0x2a>
  800871:	3a 0a                	cmp    (%edx),%cl
  800873:	74 eb                	je     800860 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 00             	movzbl (%eax),%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb f6                	jmp    80087d <strncmp+0x32>

00800887 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	0f b6 10             	movzbl (%eax),%edx
  800898:	84 d2                	test   %dl,%dl
  80089a:	74 09                	je     8008a5 <strchr+0x1e>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0a                	je     8008aa <strchr+0x23>
	for (; *s; s++)
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	eb f0                	jmp    800895 <strchr+0xe>
			return (char *) s;
	return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ac:	f3 0f 1e fb          	endbr32 
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 09                	je     8008ca <strfind+0x1e>
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 05                	je     8008ca <strfind+0x1e>
	for (; *s; s++)
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	eb f0                	jmp    8008ba <strfind+0xe>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	57                   	push   %edi
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
  8008d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 33                	je     800913 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	09 c8                	or     %ecx,%eax
  8008e4:	a8 03                	test   $0x3,%al
  8008e6:	75 23                	jne    80090b <memset+0x3f>
		c &= 0xFF;
  8008e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	c1 e0 08             	shl    $0x8,%eax
  8008f1:	89 df                	mov    %ebx,%edi
  8008f3:	c1 e7 18             	shl    $0x18,%edi
  8008f6:	89 de                	mov    %ebx,%esi
  8008f8:	c1 e6 10             	shl    $0x10,%esi
  8008fb:	09 f7                	or     %esi,%edi
  8008fd:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800904:	89 d7                	mov    %edx,%edi
  800906:	fc                   	cld    
  800907:	f3 ab                	rep stos %eax,%es:(%edi)
  800909:	eb 08                	jmp    800913 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090b:	89 d7                	mov    %edx,%edi
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 d0                	mov    %edx,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	f3 0f 1e fb          	endbr32 
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 75 0c             	mov    0xc(%ebp),%esi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092c:	39 c6                	cmp    %eax,%esi
  80092e:	73 32                	jae    800962 <memmove+0x48>
  800930:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800933:	39 c2                	cmp    %eax,%edx
  800935:	76 2b                	jbe    800962 <memmove+0x48>
		s += n;
		d += n;
  800937:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	89 fe                	mov    %edi,%esi
  80093c:	09 ce                	or     %ecx,%esi
  80093e:	09 d6                	or     %edx,%esi
  800940:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800946:	75 0e                	jne    800956 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800948:	83 ef 04             	sub    $0x4,%edi
  80094b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800951:	fd                   	std    
  800952:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800954:	eb 09                	jmp    80095f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800956:	83 ef 01             	sub    $0x1,%edi
  800959:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095c:	fd                   	std    
  80095d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095f:	fc                   	cld    
  800960:	eb 1a                	jmp    80097c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	89 c2                	mov    %eax,%edx
  800964:	09 ca                	or     %ecx,%edx
  800966:	09 f2                	or     %esi,%edx
  800968:	f6 c2 03             	test   $0x3,%dl
  80096b:	75 0a                	jne    800977 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800970:	89 c7                	mov    %eax,%edi
  800972:	fc                   	cld    
  800973:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800975:	eb 05                	jmp    80097c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800977:	89 c7                	mov    %eax,%edi
  800979:	fc                   	cld    
  80097a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800980:	f3 0f 1e fb          	endbr32 
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098a:	ff 75 10             	pushl  0x10(%ebp)
  80098d:	ff 75 0c             	pushl  0xc(%ebp)
  800990:	ff 75 08             	pushl  0x8(%ebp)
  800993:	e8 82 ff ff ff       	call   80091a <memmove>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099a:	f3 0f 1e fb          	endbr32 
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	74 1c                	je     8009ce <memcmp+0x34>
		if (*s1 != *s2)
  8009b2:	0f b6 08             	movzbl (%eax),%ecx
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	38 d9                	cmp    %bl,%cl
  8009ba:	75 08                	jne    8009c4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	83 c2 01             	add    $0x1,%edx
  8009c2:	eb ea                	jmp    8009ae <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009c4:	0f b6 c1             	movzbl %cl,%eax
  8009c7:	0f b6 db             	movzbl %bl,%ebx
  8009ca:	29 d8                	sub    %ebx,%eax
  8009cc:	eb 05                	jmp    8009d3 <memcmp+0x39>
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	f3 0f 1e fb          	endbr32 
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 09                	jae    8009f6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	74 05                	je     8009f6 <memfind+0x1f>
	for (; s < ends; s++)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	eb f3                	jmp    8009e9 <memfind+0x12>
			break;
	return (void *) s;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f8:	f3 0f 1e fb          	endbr32 
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a08:	eb 03                	jmp    800a0d <strtol+0x15>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	3c 20                	cmp    $0x20,%al
  800a12:	74 f6                	je     800a0a <strtol+0x12>
  800a14:	3c 09                	cmp    $0x9,%al
  800a16:	74 f2                	je     800a0a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a18:	3c 2b                	cmp    $0x2b,%al
  800a1a:	74 2a                	je     800a46 <strtol+0x4e>
	int neg = 0;
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a21:	3c 2d                	cmp    $0x2d,%al
  800a23:	74 2b                	je     800a50 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a25:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2b:	75 0f                	jne    800a3c <strtol+0x44>
  800a2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a30:	74 28                	je     800a5a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a32:	85 db                	test   %ebx,%ebx
  800a34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a39:	0f 44 d8             	cmove  %eax,%ebx
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a44:	eb 46                	jmp    800a8c <strtol+0x94>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb d5                	jmp    800a25 <strtol+0x2d>
		s++, neg = 1;
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	bf 01 00 00 00       	mov    $0x1,%edi
  800a58:	eb cb                	jmp    800a25 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5e:	74 0e                	je     800a6e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	75 d8                	jne    800a3c <strtol+0x44>
		s++, base = 8;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6c:	eb ce                	jmp    800a3c <strtol+0x44>
		s += 2, base = 16;
  800a6e:	83 c1 02             	add    $0x2,%ecx
  800a71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a76:	eb c4                	jmp    800a3c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a81:	7d 3a                	jge    800abd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a8c:	0f b6 11             	movzbl (%ecx),%edx
  800a8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 09             	cmp    $0x9,%bl
  800a97:	76 df                	jbe    800a78 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 08                	ja     800aab <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 57             	sub    $0x57,%edx
  800aa9:	eb d3                	jmp    800a7e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 37             	sub    $0x37,%edx
  800abb:	eb c1                	jmp    800a7e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 05                	je     800ac8 <strtol+0xd0>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	f7 da                	neg    %edx
  800acc:	85 ff                	test   %edi,%edi
  800ace:	0f 45 c2             	cmovne %edx,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	83 ec 1c             	sub    $0x1c,%esp
  800adf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ae2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ae5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aed:	8b 7d 10             	mov    0x10(%ebp),%edi
  800af0:	8b 75 14             	mov    0x14(%ebp),%esi
  800af3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800af9:	74 04                	je     800aff <syscall+0x29>
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7f 08                	jg     800b07 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b0e:	68 5f 27 80 00       	push   $0x80275f
  800b13:	6a 23                	push   $0x23
  800b15:	68 7c 27 80 00       	push   $0x80277c
  800b1a:	e8 94 14 00 00       	call   801fb3 <_panic>

00800b1f <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	f3 0f 1e fb          	endbr32 
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	ff 75 0c             	pushl  0xc(%ebp)
  800b32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	e8 92 ff ff ff       	call   800ad6 <syscall>
}
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	e8 67 ff ff ff       	call   800ad6 <syscall>
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b86:	ba 01 00 00 00       	mov    $0x1,%edx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	e8 41 ff ff ff       	call   800ad6 <syscall>
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb8:	e8 19 ff ff ff       	call   800ad6 <syscall>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <sys_yield>:

void
sys_yield(void)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be0:	e8 f1 fe ff ff       	call   800ad6 <syscall>
}
  800be5:	83 c4 10             	add    $0x10,%esp
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bea:	f3 0f 1e fb          	endbr32 
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bf4:	6a 00                	push   $0x0
  800bf6:	6a 00                	push   $0x0
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c01:	ba 01 00 00 00       	mov    $0x1,%edx
  800c06:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0b:	e8 c6 fe ff ff       	call   800ad6 <syscall>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c12:	f3 0f 1e fb          	endbr32 
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c1c:	ff 75 18             	pushl  0x18(%ebp)
  800c1f:	ff 75 14             	pushl  0x14(%ebp)
  800c22:	ff 75 10             	pushl  0x10(%ebp)
  800c25:	ff 75 0c             	pushl  0xc(%ebp)
  800c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c30:	b8 05 00 00 00       	mov    $0x5,%eax
  800c35:	e8 9c fe ff ff       	call   800ad6 <syscall>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3c:	f3 0f 1e fb          	endbr32 
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	6a 00                	push   $0x0
  800c4c:	ff 75 0c             	pushl  0xc(%ebp)
  800c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c52:	ba 01 00 00 00       	mov    $0x1,%edx
  800c57:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5c:	e8 75 fe ff ff       	call   800ad6 <syscall>
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c6d:	6a 00                	push   $0x0
  800c6f:	6a 00                	push   $0x0
  800c71:	6a 00                	push   $0x0
  800c73:	ff 75 0c             	pushl  0xc(%ebp)
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c83:	e8 4e fe ff ff       	call   800ad6 <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8a:	f3 0f 1e fb          	endbr32 
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c94:	6a 00                	push   $0x0
  800c96:	6a 00                	push   $0x0
  800c98:	6a 00                	push   $0x0
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca5:	b8 09 00 00 00       	mov    $0x9,%eax
  800caa:	e8 27 fe ff ff       	call   800ad6 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	f3 0f 1e fb          	endbr32 
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	ff 75 0c             	pushl  0xc(%ebp)
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd1:	e8 00 fe ff ff       	call   800ad6 <syscall>
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd8:	f3 0f 1e fb          	endbr32 
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ce2:	6a 00                	push   $0x0
  800ce4:	ff 75 14             	pushl  0x14(%ebp)
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfa:	e8 d7 fd ff ff       	call   800ad6 <syscall>
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d20:	e8 b1 fd ff ff       	call   800ad6 <syscall>
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 04             	sub    $0x4,%esp
  800d2e:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800d30:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800d37:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800d3a:	f6 c6 04             	test   $0x4,%dh
  800d3d:	75 54                	jne    800d93 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800d3f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d45:	0f 84 8d 00 00 00    	je     800dd8 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	68 05 08 00 00       	push   $0x805
  800d53:	53                   	push   %ebx
  800d54:	50                   	push   %eax
  800d55:	53                   	push   %ebx
  800d56:	6a 00                	push   $0x0
  800d58:	e8 b5 fe ff ff       	call   800c12 <sys_page_map>
		if (r < 0)
  800d5d:	83 c4 20             	add    $0x20,%esp
  800d60:	85 c0                	test   %eax,%eax
  800d62:	78 5f                	js     800dc3 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	68 05 08 00 00       	push   $0x805
  800d6c:	53                   	push   %ebx
  800d6d:	6a 00                	push   $0x0
  800d6f:	53                   	push   %ebx
  800d70:	6a 00                	push   $0x0
  800d72:	e8 9b fe ff ff       	call   800c12 <sys_page_map>
		if (r < 0)
  800d77:	83 c4 20             	add    $0x20,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	79 70                	jns    800dee <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d7e:	50                   	push   %eax
  800d7f:	68 8c 27 80 00       	push   $0x80278c
  800d84:	68 9b 00 00 00       	push   $0x9b
  800d89:	68 fa 28 80 00       	push   $0x8028fa
  800d8e:	e8 20 12 00 00       	call   801fb3 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d9c:	52                   	push   %edx
  800d9d:	53                   	push   %ebx
  800d9e:	50                   	push   %eax
  800d9f:	53                   	push   %ebx
  800da0:	6a 00                	push   $0x0
  800da2:	e8 6b fe ff ff       	call   800c12 <sys_page_map>
		if (r < 0)
  800da7:	83 c4 20             	add    $0x20,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	79 40                	jns    800dee <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dae:	50                   	push   %eax
  800daf:	68 8c 27 80 00       	push   $0x80278c
  800db4:	68 92 00 00 00       	push   $0x92
  800db9:	68 fa 28 80 00       	push   $0x8028fa
  800dbe:	e8 f0 11 00 00       	call   801fb3 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dc3:	50                   	push   %eax
  800dc4:	68 8c 27 80 00       	push   $0x80278c
  800dc9:	68 97 00 00 00       	push   $0x97
  800dce:	68 fa 28 80 00       	push   $0x8028fa
  800dd3:	e8 db 11 00 00       	call   801fb3 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	6a 05                	push   $0x5
  800ddd:	53                   	push   %ebx
  800dde:	50                   	push   %eax
  800ddf:	53                   	push   %ebx
  800de0:	6a 00                	push   $0x0
  800de2:	e8 2b fe ff ff       	call   800c12 <sys_page_map>
		if (r < 0)
  800de7:	83 c4 20             	add    $0x20,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 0a                	js     800df8 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
  800df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800df8:	50                   	push   %eax
  800df9:	68 8c 27 80 00       	push   $0x80278c
  800dfe:	68 a0 00 00 00       	push   $0xa0
  800e03:	68 fa 28 80 00       	push   $0x8028fa
  800e08:	e8 a6 11 00 00       	call   801fb3 <_panic>

00800e0d <dup_or_share>:
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	89 c7                	mov    %eax,%edi
  800e18:	89 d6                	mov    %edx,%esi
  800e1a:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800e1c:	f6 c1 02             	test   $0x2,%cl
  800e1f:	0f 84 90 00 00 00    	je     800eb5 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	51                   	push   %ecx
  800e29:	52                   	push   %edx
  800e2a:	50                   	push   %eax
  800e2b:	e8 ba fd ff ff       	call   800bea <sys_page_alloc>
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	78 56                	js     800e8d <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	53                   	push   %ebx
  800e3b:	68 00 00 40 00       	push   $0x400000
  800e40:	6a 00                	push   $0x0
  800e42:	56                   	push   %esi
  800e43:	57                   	push   %edi
  800e44:	e8 c9 fd ff ff       	call   800c12 <sys_page_map>
  800e49:	83 c4 20             	add    $0x20,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 51                	js     800ea1 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	68 00 10 00 00       	push   $0x1000
  800e58:	56                   	push   %esi
  800e59:	68 00 00 40 00       	push   $0x400000
  800e5e:	e8 b7 fa ff ff       	call   80091a <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e63:	83 c4 08             	add    $0x8,%esp
  800e66:	68 00 00 40 00       	push   $0x400000
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 ca fd ff ff       	call   800c3c <sys_page_unmap>
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	79 51                	jns    800eca <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800e79:	83 ec 04             	sub    $0x4,%esp
  800e7c:	68 fc 27 80 00       	push   $0x8027fc
  800e81:	6a 18                	push   $0x18
  800e83:	68 fa 28 80 00       	push   $0x8028fa
  800e88:	e8 26 11 00 00       	call   801fb3 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	68 b0 27 80 00       	push   $0x8027b0
  800e95:	6a 13                	push   $0x13
  800e97:	68 fa 28 80 00       	push   $0x8028fa
  800e9c:	e8 12 11 00 00       	call   801fb3 <_panic>
			panic("sys_page_map failed at dup_or_share");
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	68 d8 27 80 00       	push   $0x8027d8
  800ea9:	6a 15                	push   $0x15
  800eab:	68 fa 28 80 00       	push   $0x8028fa
  800eb0:	e8 fe 10 00 00       	call   801fb3 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	51                   	push   %ecx
  800eb9:	52                   	push   %edx
  800eba:	50                   	push   %eax
  800ebb:	52                   	push   %edx
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 4f fd ff ff       	call   800c12 <sys_page_map>
  800ec3:	83 c4 20             	add    $0x20,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 08                	js     800ed2 <dup_or_share+0xc5>
}
  800eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	68 d8 27 80 00       	push   $0x8027d8
  800eda:	6a 1c                	push   $0x1c
  800edc:	68 fa 28 80 00       	push   $0x8028fa
  800ee1:	e8 cd 10 00 00       	call   801fb3 <_panic>

00800ee6 <pgfault>:
{
  800ee6:	f3 0f 1e fb          	endbr32 
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	53                   	push   %ebx
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef4:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800ef6:	89 da                	mov    %ebx,%edx
  800ef8:	c1 ea 0c             	shr    $0xc,%edx
  800efb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800f02:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f06:	74 6e                	je     800f76 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800f08:	f6 c6 08             	test   $0x8,%dh
  800f0b:	74 7d                	je     800f8a <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	6a 07                	push   $0x7
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	6a 00                	push   $0x0
  800f19:	e8 cc fc ff ff       	call   800bea <sys_page_alloc>
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 79                	js     800f9e <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f25:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 00 10 00 00       	push   $0x1000
  800f33:	53                   	push   %ebx
  800f34:	68 00 f0 7f 00       	push   $0x7ff000
  800f39:	e8 dc f9 ff ff       	call   80091a <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  800f3e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f45:	53                   	push   %ebx
  800f46:	6a 00                	push   $0x0
  800f48:	68 00 f0 7f 00       	push   $0x7ff000
  800f4d:	6a 00                	push   $0x0
  800f4f:	e8 be fc ff ff       	call   800c12 <sys_page_map>
  800f54:	83 c4 20             	add    $0x20,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 57                	js     800fb2 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	6a 00                	push   $0x0
  800f65:	e8 d2 fc ff ff       	call   800c3c <sys_page_unmap>
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 55                	js     800fc6 <pgfault+0xe0>
}
  800f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	68 05 29 80 00       	push   $0x802905
  800f7e:	6a 5e                	push   $0x5e
  800f80:	68 fa 28 80 00       	push   $0x8028fa
  800f85:	e8 29 10 00 00       	call   801fb3 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 24 28 80 00       	push   $0x802824
  800f92:	6a 62                	push   $0x62
  800f94:	68 fa 28 80 00       	push   $0x8028fa
  800f99:	e8 15 10 00 00       	call   801fb3 <_panic>
		panic("pgfault failed");
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	68 1d 29 80 00       	push   $0x80291d
  800fa6:	6a 6d                	push   $0x6d
  800fa8:	68 fa 28 80 00       	push   $0x8028fa
  800fad:	e8 01 10 00 00       	call   801fb3 <_panic>
		panic("pgfault failed");
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	68 1d 29 80 00       	push   $0x80291d
  800fba:	6a 72                	push   $0x72
  800fbc:	68 fa 28 80 00       	push   $0x8028fa
  800fc1:	e8 ed 0f 00 00       	call   801fb3 <_panic>
		panic("pgfault failed");
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 1d 29 80 00       	push   $0x80291d
  800fce:	6a 74                	push   $0x74
  800fd0:	68 fa 28 80 00       	push   $0x8028fa
  800fd5:	e8 d9 0f 00 00       	call   801fb3 <_panic>

00800fda <fork_v0>:
{
  800fda:	f3 0f 1e fb          	endbr32 
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fec:	cd 30                	int    $0x30
  800fee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ff1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 1d                	js     801015 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  800ff8:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ffd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801001:	74 26                	je     801029 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801003:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801008:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  80100e:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801013:	eb 4b                	jmp    801060 <fork_v0+0x86>
		panic("sys_exofork failed");
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	68 2c 29 80 00       	push   $0x80292c
  80101d:	6a 2b                	push   $0x2b
  80101f:	68 fa 28 80 00       	push   $0x8028fa
  801024:	e8 8a 0f 00 00       	call   801fb3 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801029:	e8 69 fb ff ff       	call   800b97 <sys_getenvid>
  80102e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801033:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801036:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801040:	eb 68                	jmp    8010aa <fork_v0+0xd0>
				dup_or_share(envid,
  801042:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801048:	89 da                	mov    %ebx,%edx
  80104a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104d:	e8 bb fd ff ff       	call   800e0d <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801052:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801058:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80105e:	74 36                	je     801096 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801060:	89 d8                	mov    %ebx,%eax
  801062:	c1 e8 16             	shr    $0x16,%eax
  801065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80106c:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  80106e:	f6 02 01             	testb  $0x1,(%edx)
  801071:	74 df                	je     801052 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801073:	89 da                	mov    %ebx,%edx
  801075:	c1 ea 0a             	shr    $0xa,%edx
  801078:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80107e:	c1 e0 0c             	shl    $0xc,%eax
  801081:	89 f9                	mov    %edi,%ecx
  801083:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  801089:	09 c8                	or     %ecx,%eax
  80108b:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  80108d:	8b 08                	mov    (%eax),%ecx
  80108f:	f6 c1 01             	test   $0x1,%cl
  801092:	74 be                	je     801052 <fork_v0+0x78>
  801094:	eb ac                	jmp    801042 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	6a 02                	push   $0x2
  80109b:	ff 75 e0             	pushl  -0x20(%ebp)
  80109e:	e8 c0 fb ff ff       	call   800c63 <sys_env_set_status>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	78 0b                	js     8010b5 <fork_v0+0xdb>
}
  8010aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	68 44 28 80 00       	push   $0x802844
  8010bd:	6a 43                	push   $0x43
  8010bf:	68 fa 28 80 00       	push   $0x8028fa
  8010c4:	e8 ea 0e 00 00       	call   801fb3 <_panic>

008010c9 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8010c9:	f3 0f 1e fb          	endbr32 
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  8010d6:	68 e6 0e 80 00       	push   $0x800ee6
  8010db:	e8 1d 0f 00 00       	call   801ffd <set_pgfault_handler>
  8010e0:	b8 07 00 00 00       	mov    $0x7,%eax
  8010e5:	cd 30                	int    $0x30
  8010e7:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 2f                	js     801120 <fork+0x57>
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  8010fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010fe:	0f 85 9e 00 00 00    	jne    8011a2 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801104:	e8 8e fa ff ff       	call   800b97 <sys_getenvid>
  801109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80110e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801116:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80111b:	e9 de 00 00 00       	jmp    8011fe <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  801120:	50                   	push   %eax
  801121:	68 6c 28 80 00       	push   $0x80286c
  801126:	68 c2 00 00 00       	push   $0xc2
  80112b:	68 fa 28 80 00       	push   $0x8028fa
  801130:	e8 7e 0e 00 00       	call   801fb3 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	6a 07                	push   $0x7
  80113a:	68 00 f0 bf ee       	push   $0xeebff000
  80113f:	57                   	push   %edi
  801140:	e8 a5 fa ff ff       	call   800bea <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	75 33                	jne    80117f <fork+0xb6>
  80114c:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  80114f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801155:	74 3d                	je     801194 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801157:	89 d8                	mov    %ebx,%eax
  801159:	c1 e0 0c             	shl    $0xc,%eax
  80115c:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  80115e:	89 c2                	mov    %eax,%edx
  801160:	c1 ea 0c             	shr    $0xc,%edx
  801163:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  80116a:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  80116f:	74 c4                	je     801135 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801171:	f6 c1 01             	test   $0x1,%cl
  801174:	74 d6                	je     80114c <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  801176:	89 f8                	mov    %edi,%eax
  801178:	e8 aa fb ff ff       	call   800d27 <duppage>
  80117d:	eb cd                	jmp    80114c <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  80117f:	50                   	push   %eax
  801180:	68 8c 28 80 00       	push   $0x80288c
  801185:	68 e1 00 00 00       	push   $0xe1
  80118a:	68 fa 28 80 00       	push   $0x8028fa
  80118f:	e8 1f 0e 00 00       	call   801fb3 <_panic>
  801194:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  801198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  80119b:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8011a0:	74 18                	je     8011ba <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8011a2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011a5:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8011ac:	a8 01                	test   $0x1,%al
  8011ae:	74 e4                	je     801194 <fork+0xcb>
  8011b0:	c1 e6 16             	shl    $0x16,%esi
  8011b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b8:	eb 9d                	jmp    801157 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	6a 07                	push   $0x7
  8011bf:	68 00 f0 bf ee       	push   $0xeebff000
  8011c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c7:	e8 1e fa ff ff       	call   800bea <sys_page_alloc>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 36                	js     801209 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	68 58 20 80 00       	push   $0x802058
  8011db:	ff 75 e0             	pushl  -0x20(%ebp)
  8011de:	e8 ce fa ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 36                	js     801220 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	6a 02                	push   $0x2
  8011ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f2:	e8 6c fa ff ff       	call   800c63 <sys_env_set_status>
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 39                	js     801237 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  8011fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	68 3f 29 80 00       	push   $0x80293f
  801211:	68 f4 00 00 00       	push   $0xf4
  801216:	68 fa 28 80 00       	push   $0x8028fa
  80121b:	e8 93 0d 00 00       	call   801fb3 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	68 b0 28 80 00       	push   $0x8028b0
  801228:	68 f8 00 00 00       	push   $0xf8
  80122d:	68 fa 28 80 00       	push   $0x8028fa
  801232:	e8 7c 0d 00 00       	call   801fb3 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801237:	50                   	push   %eax
  801238:	68 d4 28 80 00       	push   $0x8028d4
  80123d:	68 fc 00 00 00       	push   $0xfc
  801242:	68 fa 28 80 00       	push   $0x8028fa
  801247:	e8 67 0d 00 00       	call   801fb3 <_panic>

0080124c <sfork>:

// Challenge!
int
sfork(void)
{
  80124c:	f3 0f 1e fb          	endbr32 
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801256:	68 57 29 80 00       	push   $0x802957
  80125b:	68 05 01 00 00       	push   $0x105
  801260:	68 fa 28 80 00       	push   $0x8028fa
  801265:	e8 49 0d 00 00       	call   801fb3 <_panic>

0080126a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126a:	f3 0f 1e fb          	endbr32 
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	05 00 00 00 30       	add    $0x30000000,%eax
  801279:	c1 e8 0c             	shr    $0xc,%eax
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127e:	f3 0f 1e fb          	endbr32 
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 da ff ff ff       	call   80126a <fd2num>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	c1 e0 0c             	shl    $0xc,%eax
  801296:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80129d:	f3 0f 1e fb          	endbr32 
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	c1 ea 16             	shr    $0x16,%edx
  8012ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b5:	f6 c2 01             	test   $0x1,%dl
  8012b8:	74 2d                	je     8012e7 <fd_alloc+0x4a>
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	c1 ea 0c             	shr    $0xc,%edx
  8012bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 1c                	je     8012e7 <fd_alloc+0x4a>
  8012cb:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d5:	75 d2                	jne    8012a9 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012e5:	eb 0a                	jmp    8012f1 <fd_alloc+0x54>
			*fd_store = fd;
  8012e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ea:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f3:	f3 0f 1e fb          	endbr32 
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012fd:	83 f8 1f             	cmp    $0x1f,%eax
  801300:	77 30                	ja     801332 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801302:	c1 e0 0c             	shl    $0xc,%eax
  801305:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 24                	je     801339 <fd_lookup+0x46>
  801315:	89 c2                	mov    %eax,%edx
  801317:	c1 ea 0c             	shr    $0xc,%edx
  80131a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801321:	f6 c2 01             	test   $0x1,%dl
  801324:	74 1a                	je     801340 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801326:	8b 55 0c             	mov    0xc(%ebp),%edx
  801329:	89 02                	mov    %eax,(%edx)
	return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    
		return -E_INVAL;
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801337:	eb f7                	jmp    801330 <fd_lookup+0x3d>
		return -E_INVAL;
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb f0                	jmp    801330 <fd_lookup+0x3d>
  801340:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801345:	eb e9                	jmp    801330 <fd_lookup+0x3d>

00801347 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801347:	f3 0f 1e fb          	endbr32 
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801354:	ba ec 29 80 00       	mov    $0x8029ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801359:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80135e:	39 08                	cmp    %ecx,(%eax)
  801360:	74 33                	je     801395 <dev_lookup+0x4e>
  801362:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801365:	8b 02                	mov    (%edx),%eax
  801367:	85 c0                	test   %eax,%eax
  801369:	75 f3                	jne    80135e <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80136b:	a1 04 40 80 00       	mov    0x804004,%eax
  801370:	8b 40 48             	mov    0x48(%eax),%eax
  801373:	83 ec 04             	sub    $0x4,%esp
  801376:	51                   	push   %ecx
  801377:	50                   	push   %eax
  801378:	68 70 29 80 00       	push   $0x802970
  80137d:	e8 76 ee ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  801382:	8b 45 0c             	mov    0xc(%ebp),%eax
  801385:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    
			*dev = devtab[i];
  801395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801398:	89 01                	mov    %eax,(%ecx)
			return 0;
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	eb f2                	jmp    801393 <dev_lookup+0x4c>

008013a1 <fd_close>:
{
  8013a1:	f3 0f 1e fb          	endbr32 
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 28             	sub    $0x28,%esp
  8013ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b4:	56                   	push   %esi
  8013b5:	e8 b0 fe ff ff       	call   80126a <fd2num>
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8013c0:	52                   	push   %edx
  8013c1:	50                   	push   %eax
  8013c2:	e8 2c ff ff ff       	call   8012f3 <fd_lookup>
  8013c7:	89 c3                	mov    %eax,%ebx
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 05                	js     8013d5 <fd_close+0x34>
	    || fd != fd2)
  8013d0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013d3:	74 16                	je     8013eb <fd_close+0x4a>
		return (must_exist ? r : 0);
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	84 c0                	test   %al,%al
  8013d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013de:	0f 44 d8             	cmove  %eax,%ebx
}
  8013e1:	89 d8                	mov    %ebx,%eax
  8013e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e6:	5b                   	pop    %ebx
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013f1:	50                   	push   %eax
  8013f2:	ff 36                	pushl  (%esi)
  8013f4:	e8 4e ff ff ff       	call   801347 <dev_lookup>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 1a                	js     80141c <fd_close+0x7b>
		if (dev->dev_close)
  801402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801405:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801408:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80140d:	85 c0                	test   %eax,%eax
  80140f:	74 0b                	je     80141c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801411:	83 ec 0c             	sub    $0xc,%esp
  801414:	56                   	push   %esi
  801415:	ff d0                	call   *%eax
  801417:	89 c3                	mov    %eax,%ebx
  801419:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	56                   	push   %esi
  801420:	6a 00                	push   $0x0
  801422:	e8 15 f8 ff ff       	call   800c3c <sys_page_unmap>
	return r;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	eb b5                	jmp    8013e1 <fd_close+0x40>

0080142c <close>:

int
close(int fdnum)
{
  80142c:	f3 0f 1e fb          	endbr32 
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 75 08             	pushl  0x8(%ebp)
  80143d:	e8 b1 fe ff ff       	call   8012f3 <fd_lookup>
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	79 02                	jns    80144b <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    
		return fd_close(fd, 1);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	6a 01                	push   $0x1
  801450:	ff 75 f4             	pushl  -0xc(%ebp)
  801453:	e8 49 ff ff ff       	call   8013a1 <fd_close>
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	eb ec                	jmp    801449 <close+0x1d>

0080145d <close_all>:

void
close_all(void)
{
  80145d:	f3 0f 1e fb          	endbr32 
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	53                   	push   %ebx
  801465:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801468:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	53                   	push   %ebx
  801471:	e8 b6 ff ff ff       	call   80142c <close>
	for (i = 0; i < MAXFD; i++)
  801476:	83 c3 01             	add    $0x1,%ebx
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	83 fb 20             	cmp    $0x20,%ebx
  80147f:	75 ec                	jne    80146d <close_all+0x10>
}
  801481:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801486:	f3 0f 1e fb          	endbr32 
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	57                   	push   %edi
  80148e:	56                   	push   %esi
  80148f:	53                   	push   %ebx
  801490:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801493:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	e8 54 fe ff ff       	call   8012f3 <fd_lookup>
  80149f:	89 c3                	mov    %eax,%ebx
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	0f 88 81 00 00 00    	js     80152d <dup+0xa7>
		return r;
	close(newfdnum);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	ff 75 0c             	pushl  0xc(%ebp)
  8014b2:	e8 75 ff ff ff       	call   80142c <close>

	newfd = INDEX2FD(newfdnum);
  8014b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014ba:	c1 e6 0c             	shl    $0xc,%esi
  8014bd:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014c3:	83 c4 04             	add    $0x4,%esp
  8014c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c9:	e8 b0 fd ff ff       	call   80127e <fd2data>
  8014ce:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014d0:	89 34 24             	mov    %esi,(%esp)
  8014d3:	e8 a6 fd ff ff       	call   80127e <fd2data>
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014dd:	89 d8                	mov    %ebx,%eax
  8014df:	c1 e8 16             	shr    $0x16,%eax
  8014e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e9:	a8 01                	test   $0x1,%al
  8014eb:	74 11                	je     8014fe <dup+0x78>
  8014ed:	89 d8                	mov    %ebx,%eax
  8014ef:	c1 e8 0c             	shr    $0xc,%eax
  8014f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f9:	f6 c2 01             	test   $0x1,%dl
  8014fc:	75 39                	jne    801537 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801501:	89 d0                	mov    %edx,%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
  801506:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	25 07 0e 00 00       	and    $0xe07,%eax
  801515:	50                   	push   %eax
  801516:	56                   	push   %esi
  801517:	6a 00                	push   $0x0
  801519:	52                   	push   %edx
  80151a:	6a 00                	push   $0x0
  80151c:	e8 f1 f6 ff ff       	call   800c12 <sys_page_map>
  801521:	89 c3                	mov    %eax,%ebx
  801523:	83 c4 20             	add    $0x20,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 31                	js     80155b <dup+0xd5>
		goto err;

	return newfdnum;
  80152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80152d:	89 d8                	mov    %ebx,%eax
  80152f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801537:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	25 07 0e 00 00       	and    $0xe07,%eax
  801546:	50                   	push   %eax
  801547:	57                   	push   %edi
  801548:	6a 00                	push   $0x0
  80154a:	53                   	push   %ebx
  80154b:	6a 00                	push   $0x0
  80154d:	e8 c0 f6 ff ff       	call   800c12 <sys_page_map>
  801552:	89 c3                	mov    %eax,%ebx
  801554:	83 c4 20             	add    $0x20,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	79 a3                	jns    8014fe <dup+0x78>
	sys_page_unmap(0, newfd);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	56                   	push   %esi
  80155f:	6a 00                	push   $0x0
  801561:	e8 d6 f6 ff ff       	call   800c3c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	57                   	push   %edi
  80156a:	6a 00                	push   $0x0
  80156c:	e8 cb f6 ff ff       	call   800c3c <sys_page_unmap>
	return r;
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	eb b7                	jmp    80152d <dup+0xa7>

00801576 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801576:	f3 0f 1e fb          	endbr32 
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 1c             	sub    $0x1c,%esp
  801581:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801584:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	53                   	push   %ebx
  801589:	e8 65 fd ff ff       	call   8012f3 <fd_lookup>
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 3f                	js     8015d4 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	ff 30                	pushl  (%eax)
  8015a1:	e8 a1 fd ff ff       	call   801347 <dev_lookup>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 27                	js     8015d4 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015b0:	8b 42 08             	mov    0x8(%edx),%eax
  8015b3:	83 e0 03             	and    $0x3,%eax
  8015b6:	83 f8 01             	cmp    $0x1,%eax
  8015b9:	74 1e                	je     8015d9 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	8b 40 08             	mov    0x8(%eax),%eax
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 35                	je     8015fa <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	ff 75 10             	pushl  0x10(%ebp)
  8015cb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ce:	52                   	push   %edx
  8015cf:	ff d0                	call   *%eax
  8015d1:	83 c4 10             	add    $0x10,%esp
}
  8015d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015de:	8b 40 48             	mov    0x48(%eax),%eax
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	50                   	push   %eax
  8015e6:	68 b1 29 80 00       	push   $0x8029b1
  8015eb:	e8 08 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f8:	eb da                	jmp    8015d4 <read+0x5e>
		return -E_NOT_SUPP;
  8015fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ff:	eb d3                	jmp    8015d4 <read+0x5e>

00801601 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801601:	f3 0f 1e fb          	endbr32 
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	57                   	push   %edi
  801609:	56                   	push   %esi
  80160a:	53                   	push   %ebx
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801611:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801614:	bb 00 00 00 00       	mov    $0x0,%ebx
  801619:	eb 02                	jmp    80161d <readn+0x1c>
  80161b:	01 c3                	add    %eax,%ebx
  80161d:	39 f3                	cmp    %esi,%ebx
  80161f:	73 21                	jae    801642 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	89 f0                	mov    %esi,%eax
  801626:	29 d8                	sub    %ebx,%eax
  801628:	50                   	push   %eax
  801629:	89 d8                	mov    %ebx,%eax
  80162b:	03 45 0c             	add    0xc(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	57                   	push   %edi
  801630:	e8 41 ff ff ff       	call   801576 <read>
		if (m < 0)
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 04                	js     801640 <readn+0x3f>
			return m;
		if (m == 0)
  80163c:	75 dd                	jne    80161b <readn+0x1a>
  80163e:	eb 02                	jmp    801642 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801640:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801642:	89 d8                	mov    %ebx,%eax
  801644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5f                   	pop    %edi
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80164c:	f3 0f 1e fb          	endbr32 
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	53                   	push   %ebx
  801654:	83 ec 1c             	sub    $0x1c,%esp
  801657:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	53                   	push   %ebx
  80165f:	e8 8f fc ff ff       	call   8012f3 <fd_lookup>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 3a                	js     8016a5 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	ff 30                	pushl  (%eax)
  801677:	e8 cb fc ff ff       	call   801347 <dev_lookup>
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 22                	js     8016a5 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168a:	74 1e                	je     8016aa <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168f:	8b 52 0c             	mov    0xc(%edx),%edx
  801692:	85 d2                	test   %edx,%edx
  801694:	74 35                	je     8016cb <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801696:	83 ec 04             	sub    $0x4,%esp
  801699:	ff 75 10             	pushl  0x10(%ebp)
  80169c:	ff 75 0c             	pushl  0xc(%ebp)
  80169f:	50                   	push   %eax
  8016a0:	ff d2                	call   *%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
}
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8016af:	8b 40 48             	mov    0x48(%eax),%eax
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	53                   	push   %ebx
  8016b6:	50                   	push   %eax
  8016b7:	68 cd 29 80 00       	push   $0x8029cd
  8016bc:	e8 37 eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c9:	eb da                	jmp    8016a5 <write+0x59>
		return -E_NOT_SUPP;
  8016cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d0:	eb d3                	jmp    8016a5 <write+0x59>

008016d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d2:	f3 0f 1e fb          	endbr32 
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	ff 75 08             	pushl  0x8(%ebp)
  8016e3:	e8 0b fc ff ff       	call   8012f3 <fd_lookup>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 0e                	js     8016fd <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8016ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ff:	f3 0f 1e fb          	endbr32 
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 1c             	sub    $0x1c,%esp
  80170a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	53                   	push   %ebx
  801712:	e8 dc fb ff ff       	call   8012f3 <fd_lookup>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 37                	js     801755 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801728:	ff 30                	pushl  (%eax)
  80172a:	e8 18 fc ff ff       	call   801347 <dev_lookup>
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 1f                	js     801755 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173d:	74 1b                	je     80175a <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80173f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801742:	8b 52 18             	mov    0x18(%edx),%edx
  801745:	85 d2                	test   %edx,%edx
  801747:	74 32                	je     80177b <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	50                   	push   %eax
  801750:	ff d2                	call   *%edx
  801752:	83 c4 10             	add    $0x10,%esp
}
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    
			thisenv->env_id, fdnum);
  80175a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80175f:	8b 40 48             	mov    0x48(%eax),%eax
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	53                   	push   %ebx
  801766:	50                   	push   %eax
  801767:	68 90 29 80 00       	push   $0x802990
  80176c:	e8 87 ea ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801779:	eb da                	jmp    801755 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80177b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801780:	eb d3                	jmp    801755 <ftruncate+0x56>

00801782 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801782:	f3 0f 1e fb          	endbr32 
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	83 ec 1c             	sub    $0x1c,%esp
  80178d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801790:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	e8 57 fb ff ff       	call   8012f3 <fd_lookup>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 4b                	js     8017ee <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	ff 30                	pushl  (%eax)
  8017af:	e8 93 fb ff ff       	call   801347 <dev_lookup>
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 33                	js     8017ee <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c2:	74 2f                	je     8017f3 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ce:	00 00 00 
	stat->st_isdir = 0;
  8017d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d8:	00 00 00 
	stat->st_dev = dev;
  8017db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	53                   	push   %ebx
  8017e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e8:	ff 50 14             	call   *0x14(%eax)
  8017eb:	83 c4 10             	add    $0x10,%esp
}
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    
		return -E_NOT_SUPP;
  8017f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f8:	eb f4                	jmp    8017ee <fstat+0x6c>

008017fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017fa:	f3 0f 1e fb          	endbr32 
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	6a 00                	push   $0x0
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 fb 01 00 00       	call   801a0b <open>
  801810:	89 c3                	mov    %eax,%ebx
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	85 c0                	test   %eax,%eax
  801817:	78 1b                	js     801834 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	ff 75 0c             	pushl  0xc(%ebp)
  80181f:	50                   	push   %eax
  801820:	e8 5d ff ff ff       	call   801782 <fstat>
  801825:	89 c6                	mov    %eax,%esi
	close(fd);
  801827:	89 1c 24             	mov    %ebx,(%esp)
  80182a:	e8 fd fb ff ff       	call   80142c <close>
	return r;
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	89 f3                	mov    %esi,%ebx
}
  801834:	89 d8                	mov    %ebx,%eax
  801836:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	89 c6                	mov    %eax,%esi
  801844:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801846:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80184d:	74 27                	je     801876 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184f:	6a 07                	push   $0x7
  801851:	68 00 50 80 00       	push   $0x805000
  801856:	56                   	push   %esi
  801857:	ff 35 00 40 80 00    	pushl  0x804000
  80185d:	e8 8c 08 00 00       	call   8020ee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801862:	83 c4 0c             	add    $0xc,%esp
  801865:	6a 00                	push   $0x0
  801867:	53                   	push   %ebx
  801868:	6a 00                	push   $0x0
  80186a:	e8 11 08 00 00       	call   802080 <ipc_recv>
}
  80186f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	6a 01                	push   $0x1
  80187b:	e8 d3 08 00 00       	call   802153 <ipc_find_env>
  801880:	a3 00 40 80 00       	mov    %eax,0x804000
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	eb c5                	jmp    80184f <fsipc+0x12>

0080188a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80188a:	f3 0f 1e fb          	endbr32 
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	8b 40 0c             	mov    0xc(%eax),%eax
  80189a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80189f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b1:	e8 87 ff ff ff       	call   80183d <fsipc>
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <devfile_flush>:
{
  8018b8:	f3 0f 1e fb          	endbr32 
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d7:	e8 61 ff ff ff       	call   80183d <fsipc>
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devfile_stat>:
{
  8018de:	f3 0f 1e fb          	endbr32 
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 05 00 00 00       	mov    $0x5,%eax
  801901:	e8 37 ff ff ff       	call   80183d <fsipc>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 2c                	js     801936 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80190a:	83 ec 08             	sub    $0x8,%esp
  80190d:	68 00 50 80 00       	push   $0x805000
  801912:	53                   	push   %ebx
  801913:	e8 4a ee ff ff       	call   800762 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801918:	a1 80 50 80 00       	mov    0x805080,%eax
  80191d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801923:	a1 84 50 80 00       	mov    0x805084,%eax
  801928:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801936:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <devfile_write>:
{
  80193b:	f3 0f 1e fb          	endbr32 
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 0c             	sub    $0xc,%esp
  801945:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801948:	8b 55 08             	mov    0x8(%ebp),%edx
  80194b:	8b 52 0c             	mov    0xc(%edx),%edx
  80194e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801954:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801959:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80195e:	0f 47 c2             	cmova  %edx,%eax
  801961:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801966:	50                   	push   %eax
  801967:	ff 75 0c             	pushl  0xc(%ebp)
  80196a:	68 08 50 80 00       	push   $0x805008
  80196f:	e8 a6 ef ff ff       	call   80091a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 04 00 00 00       	mov    $0x4,%eax
  80197e:	e8 ba fe ff ff       	call   80183d <fsipc>
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <devfile_read>:
{
  801985:	f3 0f 1e fb          	endbr32 
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	56                   	push   %esi
  80198d:	53                   	push   %ebx
  80198e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801991:	8b 45 08             	mov    0x8(%ebp),%eax
  801994:	8b 40 0c             	mov    0xc(%eax),%eax
  801997:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80199c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ac:	e8 8c fe ff ff       	call   80183d <fsipc>
  8019b1:	89 c3                	mov    %eax,%ebx
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 1f                	js     8019d6 <devfile_read+0x51>
	assert(r <= n);
  8019b7:	39 f0                	cmp    %esi,%eax
  8019b9:	77 24                	ja     8019df <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8019bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c0:	7f 33                	jg     8019f5 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c2:	83 ec 04             	sub    $0x4,%esp
  8019c5:	50                   	push   %eax
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	e8 47 ef ff ff       	call   80091a <memmove>
	return r;
  8019d3:	83 c4 10             	add    $0x10,%esp
}
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    
	assert(r <= n);
  8019df:	68 fc 29 80 00       	push   $0x8029fc
  8019e4:	68 03 2a 80 00       	push   $0x802a03
  8019e9:	6a 7c                	push   $0x7c
  8019eb:	68 18 2a 80 00       	push   $0x802a18
  8019f0:	e8 be 05 00 00       	call   801fb3 <_panic>
	assert(r <= PGSIZE);
  8019f5:	68 23 2a 80 00       	push   $0x802a23
  8019fa:	68 03 2a 80 00       	push   $0x802a03
  8019ff:	6a 7d                	push   $0x7d
  801a01:	68 18 2a 80 00       	push   $0x802a18
  801a06:	e8 a8 05 00 00       	call   801fb3 <_panic>

00801a0b <open>:
{
  801a0b:	f3 0f 1e fb          	endbr32 
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	83 ec 1c             	sub    $0x1c,%esp
  801a17:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a1a:	56                   	push   %esi
  801a1b:	e8 ff ec ff ff       	call   80071f <strlen>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a28:	7f 6c                	jg     801a96 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	e8 67 f8 ff ff       	call   80129d <fd_alloc>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 3c                	js     801a7b <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a3f:	83 ec 08             	sub    $0x8,%esp
  801a42:	56                   	push   %esi
  801a43:	68 00 50 80 00       	push   $0x805000
  801a48:	e8 15 ed ff ff       	call   800762 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a50:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a58:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5d:	e8 db fd ff ff       	call   80183d <fsipc>
  801a62:	89 c3                	mov    %eax,%ebx
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 19                	js     801a84 <open+0x79>
	return fd2num(fd);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a71:	e8 f4 f7 ff ff       	call   80126a <fd2num>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	83 c4 10             	add    $0x10,%esp
}
  801a7b:	89 d8                	mov    %ebx,%eax
  801a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    
		fd_close(fd, 0);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	6a 00                	push   $0x0
  801a89:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8c:	e8 10 f9 ff ff       	call   8013a1 <fd_close>
		return r;
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	eb e5                	jmp    801a7b <open+0x70>
		return -E_BAD_PATH;
  801a96:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a9b:	eb de                	jmp    801a7b <open+0x70>

00801a9d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a9d:	f3 0f 1e fb          	endbr32 
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aac:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab1:	e8 87 fd ff ff       	call   80183d <fsipc>
}
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab8:	f3 0f 1e fb          	endbr32 
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	ff 75 08             	pushl  0x8(%ebp)
  801aca:	e8 af f7 ff ff       	call   80127e <fd2data>
  801acf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ad1:	83 c4 08             	add    $0x8,%esp
  801ad4:	68 2f 2a 80 00       	push   $0x802a2f
  801ad9:	53                   	push   %ebx
  801ada:	e8 83 ec ff ff       	call   800762 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801adf:	8b 46 04             	mov    0x4(%esi),%eax
  801ae2:	2b 06                	sub    (%esi),%eax
  801ae4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801af1:	00 00 00 
	stat->st_dev = &devpipe;
  801af4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801afb:	30 80 00 
	return 0;
}
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
  801b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b0a:	f3 0f 1e fb          	endbr32 
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	53                   	push   %ebx
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b18:	53                   	push   %ebx
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 1c f1 ff ff       	call   800c3c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b20:	89 1c 24             	mov    %ebx,(%esp)
  801b23:	e8 56 f7 ff ff       	call   80127e <fd2data>
  801b28:	83 c4 08             	add    $0x8,%esp
  801b2b:	50                   	push   %eax
  801b2c:	6a 00                	push   $0x0
  801b2e:	e8 09 f1 ff ff       	call   800c3c <sys_page_unmap>
}
  801b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <_pipeisclosed>:
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	57                   	push   %edi
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 1c             	sub    $0x1c,%esp
  801b41:	89 c7                	mov    %eax,%edi
  801b43:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b45:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	57                   	push   %edi
  801b51:	e8 3a 06 00 00       	call   802190 <pageref>
  801b56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b59:	89 34 24             	mov    %esi,(%esp)
  801b5c:	e8 2f 06 00 00       	call   802190 <pageref>
		nn = thisenv->env_runs;
  801b61:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b67:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	39 cb                	cmp    %ecx,%ebx
  801b6f:	74 1b                	je     801b8c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b71:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b74:	75 cf                	jne    801b45 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b76:	8b 42 58             	mov    0x58(%edx),%eax
  801b79:	6a 01                	push   $0x1
  801b7b:	50                   	push   %eax
  801b7c:	53                   	push   %ebx
  801b7d:	68 36 2a 80 00       	push   $0x802a36
  801b82:	e8 71 e6 ff ff       	call   8001f8 <cprintf>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	eb b9                	jmp    801b45 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b8f:	0f 94 c0             	sete   %al
  801b92:	0f b6 c0             	movzbl %al,%eax
}
  801b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5f                   	pop    %edi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <devpipe_write>:
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	57                   	push   %edi
  801ba5:	56                   	push   %esi
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 28             	sub    $0x28,%esp
  801baa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bad:	56                   	push   %esi
  801bae:	e8 cb f6 ff ff       	call   80127e <fd2data>
  801bb3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801bbd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc0:	74 4f                	je     801c11 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc2:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc5:	8b 0b                	mov    (%ebx),%ecx
  801bc7:	8d 51 20             	lea    0x20(%ecx),%edx
  801bca:	39 d0                	cmp    %edx,%eax
  801bcc:	72 14                	jb     801be2 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801bce:	89 da                	mov    %ebx,%edx
  801bd0:	89 f0                	mov    %esi,%eax
  801bd2:	e8 61 ff ff ff       	call   801b38 <_pipeisclosed>
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	75 3b                	jne    801c16 <devpipe_write+0x79>
			sys_yield();
  801bdb:	e8 df ef ff ff       	call   800bbf <sys_yield>
  801be0:	eb e0                	jmp    801bc2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801be9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bec:	89 c2                	mov    %eax,%edx
  801bee:	c1 fa 1f             	sar    $0x1f,%edx
  801bf1:	89 d1                	mov    %edx,%ecx
  801bf3:	c1 e9 1b             	shr    $0x1b,%ecx
  801bf6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bf9:	83 e2 1f             	and    $0x1f,%edx
  801bfc:	29 ca                	sub    %ecx,%edx
  801bfe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c06:	83 c0 01             	add    $0x1,%eax
  801c09:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c0c:	83 c7 01             	add    $0x1,%edi
  801c0f:	eb ac                	jmp    801bbd <devpipe_write+0x20>
	return i;
  801c11:	8b 45 10             	mov    0x10(%ebp),%eax
  801c14:	eb 05                	jmp    801c1b <devpipe_write+0x7e>
				return 0;
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5f                   	pop    %edi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <devpipe_read>:
{
  801c23:	f3 0f 1e fb          	endbr32 
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	57                   	push   %edi
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 18             	sub    $0x18,%esp
  801c30:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c33:	57                   	push   %edi
  801c34:	e8 45 f6 ff ff       	call   80127e <fd2data>
  801c39:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	be 00 00 00 00       	mov    $0x0,%esi
  801c43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c46:	75 14                	jne    801c5c <devpipe_read+0x39>
	return i;
  801c48:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4b:	eb 02                	jmp    801c4f <devpipe_read+0x2c>
				return i;
  801c4d:	89 f0                	mov    %esi,%eax
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    
			sys_yield();
  801c57:	e8 63 ef ff ff       	call   800bbf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c5c:	8b 03                	mov    (%ebx),%eax
  801c5e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c61:	75 18                	jne    801c7b <devpipe_read+0x58>
			if (i > 0)
  801c63:	85 f6                	test   %esi,%esi
  801c65:	75 e6                	jne    801c4d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c67:	89 da                	mov    %ebx,%edx
  801c69:	89 f8                	mov    %edi,%eax
  801c6b:	e8 c8 fe ff ff       	call   801b38 <_pipeisclosed>
  801c70:	85 c0                	test   %eax,%eax
  801c72:	74 e3                	je     801c57 <devpipe_read+0x34>
				return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
  801c79:	eb d4                	jmp    801c4f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7b:	99                   	cltd   
  801c7c:	c1 ea 1b             	shr    $0x1b,%edx
  801c7f:	01 d0                	add    %edx,%eax
  801c81:	83 e0 1f             	and    $0x1f,%eax
  801c84:	29 d0                	sub    %edx,%eax
  801c86:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c91:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c94:	83 c6 01             	add    $0x1,%esi
  801c97:	eb aa                	jmp    801c43 <devpipe_read+0x20>

00801c99 <pipe>:
{
  801c99:	f3 0f 1e fb          	endbr32 
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	e8 ef f5 ff ff       	call   80129d <fd_alloc>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 23 01 00 00    	js     801dde <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	68 07 04 00 00       	push   $0x407
  801cc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 1d ef ff ff       	call   800bea <sys_page_alloc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 04 01 00 00    	js     801dde <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce0:	50                   	push   %eax
  801ce1:	e8 b7 f5 ff ff       	call   80129d <fd_alloc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	0f 88 db 00 00 00    	js     801dce <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf3:	83 ec 04             	sub    $0x4,%esp
  801cf6:	68 07 04 00 00       	push   $0x407
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 e5 ee ff ff       	call   800bea <sys_page_alloc>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 bc 00 00 00    	js     801dce <pipe+0x135>
	va = fd2data(fd0);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff 75 f4             	pushl  -0xc(%ebp)
  801d18:	e8 61 f5 ff ff       	call   80127e <fd2data>
  801d1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1f:	83 c4 0c             	add    $0xc,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	50                   	push   %eax
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 bb ee ff ff       	call   800bea <sys_page_alloc>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	0f 88 82 00 00 00    	js     801dbe <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d42:	e8 37 f5 ff ff       	call   80127e <fd2data>
  801d47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d4e:	50                   	push   %eax
  801d4f:	6a 00                	push   $0x0
  801d51:	56                   	push   %esi
  801d52:	6a 00                	push   $0x0
  801d54:	e8 b9 ee ff ff       	call   800c12 <sys_page_map>
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	83 c4 20             	add    $0x20,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 4e                	js     801db0 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d62:	a1 20 30 80 00       	mov    0x803020,%eax
  801d67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d6a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d6f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d79:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8b:	e8 da f4 ff ff       	call   80126a <fd2num>
  801d90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d95:	83 c4 04             	add    $0x4,%esp
  801d98:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9b:	e8 ca f4 ff ff       	call   80126a <fd2num>
  801da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dae:	eb 2e                	jmp    801dde <pipe+0x145>
	sys_page_unmap(0, va);
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	56                   	push   %esi
  801db4:	6a 00                	push   $0x0
  801db6:	e8 81 ee ff ff       	call   800c3c <sys_page_unmap>
  801dbb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 71 ee ff ff       	call   800c3c <sys_page_unmap>
  801dcb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801dce:	83 ec 08             	sub    $0x8,%esp
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 61 ee ff ff       	call   800c3c <sys_page_unmap>
  801ddb:	83 c4 10             	add    $0x10,%esp
}
  801dde:	89 d8                	mov    %ebx,%eax
  801de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <pipeisclosed>:
{
  801de7:	f3 0f 1e fb          	endbr32 
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	ff 75 08             	pushl  0x8(%ebp)
  801df8:	e8 f6 f4 ff ff       	call   8012f3 <fd_lookup>
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 18                	js     801e1c <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	e8 6f f4 ff ff       	call   80127e <fd2data>
  801e0f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e14:	e8 1f fd ff ff       	call   801b38 <_pipeisclosed>
  801e19:	83 c4 10             	add    $0x10,%esp
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e1e:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
  801e27:	c3                   	ret    

00801e28 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e28:	f3 0f 1e fb          	endbr32 
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e32:	68 4e 2a 80 00       	push   $0x802a4e
  801e37:	ff 75 0c             	pushl  0xc(%ebp)
  801e3a:	e8 23 e9 ff ff       	call   800762 <strcpy>
	return 0;
}
  801e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <devcons_write>:
{
  801e46:	f3 0f 1e fb          	endbr32 
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	57                   	push   %edi
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e56:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e5b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e61:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e64:	73 31                	jae    801e97 <devcons_write+0x51>
		m = n - tot;
  801e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e69:	29 f3                	sub    %esi,%ebx
  801e6b:	83 fb 7f             	cmp    $0x7f,%ebx
  801e6e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e73:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	53                   	push   %ebx
  801e7a:	89 f0                	mov    %esi,%eax
  801e7c:	03 45 0c             	add    0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	57                   	push   %edi
  801e81:	e8 94 ea ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  801e86:	83 c4 08             	add    $0x8,%esp
  801e89:	53                   	push   %ebx
  801e8a:	57                   	push   %edi
  801e8b:	e8 8f ec ff ff       	call   800b1f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e90:	01 de                	add    %ebx,%esi
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	eb ca                	jmp    801e61 <devcons_write+0x1b>
}
  801e97:	89 f0                	mov    %esi,%eax
  801e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devcons_read>:
{
  801ea1:	f3 0f 1e fb          	endbr32 
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801eb0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb4:	74 21                	je     801ed7 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801eb6:	e8 8e ec ff ff       	call   800b49 <sys_cgetc>
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	75 07                	jne    801ec6 <devcons_read+0x25>
		sys_yield();
  801ebf:	e8 fb ec ff ff       	call   800bbf <sys_yield>
  801ec4:	eb f0                	jmp    801eb6 <devcons_read+0x15>
	if (c < 0)
  801ec6:	78 0f                	js     801ed7 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801ec8:	83 f8 04             	cmp    $0x4,%eax
  801ecb:	74 0c                	je     801ed9 <devcons_read+0x38>
	*(char*)vbuf = c;
  801ecd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed0:	88 02                	mov    %al,(%edx)
	return 1;
  801ed2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    
		return 0;
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ede:	eb f7                	jmp    801ed7 <devcons_read+0x36>

00801ee0 <cputchar>:
{
  801ee0:	f3 0f 1e fb          	endbr32 
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eea:	8b 45 08             	mov    0x8(%ebp),%eax
  801eed:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ef0:	6a 01                	push   $0x1
  801ef2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	e8 24 ec ff ff       	call   800b1f <sys_cputs>
}
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <getchar>:
{
  801f00:	f3 0f 1e fb          	endbr32 
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f0a:	6a 01                	push   $0x1
  801f0c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0f:	50                   	push   %eax
  801f10:	6a 00                	push   $0x0
  801f12:	e8 5f f6 ff ff       	call   801576 <read>
	if (r < 0)
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 06                	js     801f24 <getchar+0x24>
	if (r < 1)
  801f1e:	74 06                	je     801f26 <getchar+0x26>
	return c;
  801f20:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    
		return -E_EOF;
  801f26:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f2b:	eb f7                	jmp    801f24 <getchar+0x24>

00801f2d <iscons>:
{
  801f2d:	f3 0f 1e fb          	endbr32 
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3a:	50                   	push   %eax
  801f3b:	ff 75 08             	pushl  0x8(%ebp)
  801f3e:	e8 b0 f3 ff ff       	call   8012f3 <fd_lookup>
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 11                	js     801f5b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f53:	39 10                	cmp    %edx,(%eax)
  801f55:	0f 94 c0             	sete   %al
  801f58:	0f b6 c0             	movzbl %al,%eax
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <opencons>:
{
  801f5d:	f3 0f 1e fb          	endbr32 
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	50                   	push   %eax
  801f6b:	e8 2d f3 ff ff       	call   80129d <fd_alloc>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 3a                	js     801fb1 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f77:	83 ec 04             	sub    $0x4,%esp
  801f7a:	68 07 04 00 00       	push   $0x407
  801f7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f82:	6a 00                	push   $0x0
  801f84:	e8 61 ec ff ff       	call   800bea <sys_page_alloc>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 21                	js     801fb1 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f99:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa5:	83 ec 0c             	sub    $0xc,%esp
  801fa8:	50                   	push   %eax
  801fa9:	e8 bc f2 ff ff       	call   80126a <fd2num>
  801fae:	83 c4 10             	add    $0x10,%esp
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fb3:	f3 0f 1e fb          	endbr32 
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fbc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fbf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fc5:	e8 cd eb ff ff       	call   800b97 <sys_getenvid>
  801fca:	83 ec 0c             	sub    $0xc,%esp
  801fcd:	ff 75 0c             	pushl  0xc(%ebp)
  801fd0:	ff 75 08             	pushl  0x8(%ebp)
  801fd3:	56                   	push   %esi
  801fd4:	50                   	push   %eax
  801fd5:	68 5c 2a 80 00       	push   $0x802a5c
  801fda:	e8 19 e2 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fdf:	83 c4 18             	add    $0x18,%esp
  801fe2:	53                   	push   %ebx
  801fe3:	ff 75 10             	pushl  0x10(%ebp)
  801fe6:	e8 b8 e1 ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  801feb:	c7 04 24 4f 24 80 00 	movl   $0x80244f,(%esp)
  801ff2:	e8 01 e2 ff ff       	call   8001f8 <cprintf>
  801ff7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ffa:	cc                   	int3   
  801ffb:	eb fd                	jmp    801ffa <_panic+0x47>

00801ffd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ffd:	f3 0f 1e fb          	endbr32 
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802007:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80200e:	74 1c                	je     80202c <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802010:	8b 45 08             	mov    0x8(%ebp),%eax
  802013:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802018:	83 ec 08             	sub    $0x8,%esp
  80201b:	68 58 20 80 00       	push   $0x802058
  802020:	6a 00                	push   $0x0
  802022:	e8 8a ec ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
}
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  80202c:	83 ec 04             	sub    $0x4,%esp
  80202f:	6a 02                	push   $0x2
  802031:	68 00 f0 bf ee       	push   $0xeebff000
  802036:	6a 00                	push   $0x0
  802038:	e8 ad eb ff ff       	call   800bea <sys_page_alloc>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	79 cc                	jns    802010 <set_pgfault_handler+0x13>
  802044:	83 ec 04             	sub    $0x4,%esp
  802047:	68 7f 2a 80 00       	push   $0x802a7f
  80204c:	6a 20                	push   $0x20
  80204e:	68 9a 2a 80 00       	push   $0x802a9a
  802053:	e8 5b ff ff ff       	call   801fb3 <_panic>

00802058 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802058:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802059:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80205e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802060:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  802063:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  802067:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80206b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  80206e:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  802070:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802074:	83 c4 08             	add    $0x8,%esp
	popal
  802077:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802078:	83 c4 04             	add    $0x4,%esp
	popfl
  80207b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80207c:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80207f:	c3                   	ret    

00802080 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802080:	f3 0f 1e fb          	endbr32 
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	8b 75 08             	mov    0x8(%ebp),%esi
  80208c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  802092:	85 c0                	test   %eax,%eax
  802094:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802099:	0f 44 c2             	cmove  %edx,%eax
  80209c:	83 ec 0c             	sub    $0xc,%esp
  80209f:	50                   	push   %eax
  8020a0:	e8 5c ec ff ff       	call   800d01 <sys_ipc_recv>

	if (from_env_store != NULL)
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	85 f6                	test   %esi,%esi
  8020aa:	74 15                	je     8020c1 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8020ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b1:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020b4:	74 09                	je     8020bf <ipc_recv+0x3f>
  8020b6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8020bc:	8b 52 74             	mov    0x74(%edx),%edx
  8020bf:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8020c1:	85 db                	test   %ebx,%ebx
  8020c3:	74 15                	je     8020da <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8020c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ca:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020cd:	74 09                	je     8020d8 <ipc_recv+0x58>
  8020cf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8020d5:	8b 52 78             	mov    0x78(%edx),%edx
  8020d8:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8020da:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020dd:	74 08                	je     8020e7 <ipc_recv+0x67>
  8020df:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ea:	5b                   	pop    %ebx
  8020eb:	5e                   	pop    %esi
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ee:	f3 0f 1e fb          	endbr32 
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 0c             	sub    $0xc,%esp
  8020fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  802101:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802104:	eb 1f                	jmp    802125 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802106:	6a 00                	push   $0x0
  802108:	68 00 00 c0 ee       	push   $0xeec00000
  80210d:	56                   	push   %esi
  80210e:	57                   	push   %edi
  80210f:	e8 c4 eb ff ff       	call   800cd8 <sys_ipc_try_send>
  802114:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  802117:	85 c0                	test   %eax,%eax
  802119:	74 30                	je     80214b <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  80211b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80211e:	75 19                	jne    802139 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  802120:	e8 9a ea ff ff       	call   800bbf <sys_yield>
		if (pg != NULL) {
  802125:	85 db                	test   %ebx,%ebx
  802127:	74 dd                	je     802106 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  802129:	ff 75 14             	pushl  0x14(%ebp)
  80212c:	53                   	push   %ebx
  80212d:	56                   	push   %esi
  80212e:	57                   	push   %edi
  80212f:	e8 a4 eb ff ff       	call   800cd8 <sys_ipc_try_send>
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	eb de                	jmp    802117 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  802139:	50                   	push   %eax
  80213a:	68 a8 2a 80 00       	push   $0x802aa8
  80213f:	6a 3e                	push   $0x3e
  802141:	68 b5 2a 80 00       	push   $0x802ab5
  802146:	e8 68 fe ff ff       	call   801fb3 <_panic>
	}
}
  80214b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214e:	5b                   	pop    %ebx
  80214f:	5e                   	pop    %esi
  802150:	5f                   	pop    %edi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802153:	f3 0f 1e fb          	endbr32 
  802157:	55                   	push   %ebp
  802158:	89 e5                	mov    %esp,%ebp
  80215a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802162:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802165:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216b:	8b 52 50             	mov    0x50(%edx),%edx
  80216e:	39 ca                	cmp    %ecx,%edx
  802170:	74 11                	je     802183 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802172:	83 c0 01             	add    $0x1,%eax
  802175:	3d 00 04 00 00       	cmp    $0x400,%eax
  80217a:	75 e6                	jne    802162 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
  802181:	eb 0b                	jmp    80218e <ipc_find_env+0x3b>
			return envs[i].env_id;
  802183:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802186:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80218b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    

00802190 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802190:	f3 0f 1e fb          	endbr32 
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219a:	89 c2                	mov    %eax,%edx
  80219c:	c1 ea 16             	shr    $0x16,%edx
  80219f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021a6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021ab:	f6 c1 01             	test   $0x1,%cl
  8021ae:	74 1c                	je     8021cc <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021b0:	c1 e8 0c             	shr    $0xc,%eax
  8021b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021ba:	a8 01                	test   $0x1,%al
  8021bc:	74 0e                	je     8021cc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021be:	c1 e8 0c             	shr    $0xc,%eax
  8021c1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021c8:	ef 
  8021c9:	0f b7 d2             	movzwl %dx,%edx
}
  8021cc:	89 d0                	mov    %edx,%eax
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    

008021d0 <__udivdi3>:
  8021d0:	f3 0f 1e fb          	endbr32 
  8021d4:	55                   	push   %ebp
  8021d5:	57                   	push   %edi
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	83 ec 1c             	sub    $0x1c,%esp
  8021db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021eb:	85 d2                	test   %edx,%edx
  8021ed:	75 19                	jne    802208 <__udivdi3+0x38>
  8021ef:	39 f3                	cmp    %esi,%ebx
  8021f1:	76 4d                	jbe    802240 <__udivdi3+0x70>
  8021f3:	31 ff                	xor    %edi,%edi
  8021f5:	89 e8                	mov    %ebp,%eax
  8021f7:	89 f2                	mov    %esi,%edx
  8021f9:	f7 f3                	div    %ebx
  8021fb:	89 fa                	mov    %edi,%edx
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	76 14                	jbe    802220 <__udivdi3+0x50>
  80220c:	31 ff                	xor    %edi,%edi
  80220e:	31 c0                	xor    %eax,%eax
  802210:	89 fa                	mov    %edi,%edx
  802212:	83 c4 1c             	add    $0x1c,%esp
  802215:	5b                   	pop    %ebx
  802216:	5e                   	pop    %esi
  802217:	5f                   	pop    %edi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    
  80221a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802220:	0f bd fa             	bsr    %edx,%edi
  802223:	83 f7 1f             	xor    $0x1f,%edi
  802226:	75 48                	jne    802270 <__udivdi3+0xa0>
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	72 06                	jb     802232 <__udivdi3+0x62>
  80222c:	31 c0                	xor    %eax,%eax
  80222e:	39 eb                	cmp    %ebp,%ebx
  802230:	77 de                	ja     802210 <__udivdi3+0x40>
  802232:	b8 01 00 00 00       	mov    $0x1,%eax
  802237:	eb d7                	jmp    802210 <__udivdi3+0x40>
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 d9                	mov    %ebx,%ecx
  802242:	85 db                	test   %ebx,%ebx
  802244:	75 0b                	jne    802251 <__udivdi3+0x81>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f3                	div    %ebx
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	31 d2                	xor    %edx,%edx
  802253:	89 f0                	mov    %esi,%eax
  802255:	f7 f1                	div    %ecx
  802257:	89 c6                	mov    %eax,%esi
  802259:	89 e8                	mov    %ebp,%eax
  80225b:	89 f7                	mov    %esi,%edi
  80225d:	f7 f1                	div    %ecx
  80225f:	89 fa                	mov    %edi,%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 f9                	mov    %edi,%ecx
  802272:	b8 20 00 00 00       	mov    $0x20,%eax
  802277:	29 f8                	sub    %edi,%eax
  802279:	d3 e2                	shl    %cl,%edx
  80227b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	89 da                	mov    %ebx,%edx
  802283:	d3 ea                	shr    %cl,%edx
  802285:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802289:	09 d1                	or     %edx,%ecx
  80228b:	89 f2                	mov    %esi,%edx
  80228d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802291:	89 f9                	mov    %edi,%ecx
  802293:	d3 e3                	shl    %cl,%ebx
  802295:	89 c1                	mov    %eax,%ecx
  802297:	d3 ea                	shr    %cl,%edx
  802299:	89 f9                	mov    %edi,%ecx
  80229b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80229f:	89 eb                	mov    %ebp,%ebx
  8022a1:	d3 e6                	shl    %cl,%esi
  8022a3:	89 c1                	mov    %eax,%ecx
  8022a5:	d3 eb                	shr    %cl,%ebx
  8022a7:	09 de                	or     %ebx,%esi
  8022a9:	89 f0                	mov    %esi,%eax
  8022ab:	f7 74 24 08          	divl   0x8(%esp)
  8022af:	89 d6                	mov    %edx,%esi
  8022b1:	89 c3                	mov    %eax,%ebx
  8022b3:	f7 64 24 0c          	mull   0xc(%esp)
  8022b7:	39 d6                	cmp    %edx,%esi
  8022b9:	72 15                	jb     8022d0 <__udivdi3+0x100>
  8022bb:	89 f9                	mov    %edi,%ecx
  8022bd:	d3 e5                	shl    %cl,%ebp
  8022bf:	39 c5                	cmp    %eax,%ebp
  8022c1:	73 04                	jae    8022c7 <__udivdi3+0xf7>
  8022c3:	39 d6                	cmp    %edx,%esi
  8022c5:	74 09                	je     8022d0 <__udivdi3+0x100>
  8022c7:	89 d8                	mov    %ebx,%eax
  8022c9:	31 ff                	xor    %edi,%edi
  8022cb:	e9 40 ff ff ff       	jmp    802210 <__udivdi3+0x40>
  8022d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022d3:	31 ff                	xor    %edi,%edi
  8022d5:	e9 36 ff ff ff       	jmp    802210 <__udivdi3+0x40>
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <__umoddi3>:
  8022e0:	f3 0f 1e fb          	endbr32 
  8022e4:	55                   	push   %ebp
  8022e5:	57                   	push   %edi
  8022e6:	56                   	push   %esi
  8022e7:	53                   	push   %ebx
  8022e8:	83 ec 1c             	sub    $0x1c,%esp
  8022eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	75 19                	jne    802318 <__umoddi3+0x38>
  8022ff:	39 df                	cmp    %ebx,%edi
  802301:	76 5d                	jbe    802360 <__umoddi3+0x80>
  802303:	89 f0                	mov    %esi,%eax
  802305:	89 da                	mov    %ebx,%edx
  802307:	f7 f7                	div    %edi
  802309:	89 d0                	mov    %edx,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	83 c4 1c             	add    $0x1c,%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    
  802315:	8d 76 00             	lea    0x0(%esi),%esi
  802318:	89 f2                	mov    %esi,%edx
  80231a:	39 d8                	cmp    %ebx,%eax
  80231c:	76 12                	jbe    802330 <__umoddi3+0x50>
  80231e:	89 f0                	mov    %esi,%eax
  802320:	89 da                	mov    %ebx,%edx
  802322:	83 c4 1c             	add    $0x1c,%esp
  802325:	5b                   	pop    %ebx
  802326:	5e                   	pop    %esi
  802327:	5f                   	pop    %edi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    
  80232a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802330:	0f bd e8             	bsr    %eax,%ebp
  802333:	83 f5 1f             	xor    $0x1f,%ebp
  802336:	75 50                	jne    802388 <__umoddi3+0xa8>
  802338:	39 d8                	cmp    %ebx,%eax
  80233a:	0f 82 e0 00 00 00    	jb     802420 <__umoddi3+0x140>
  802340:	89 d9                	mov    %ebx,%ecx
  802342:	39 f7                	cmp    %esi,%edi
  802344:	0f 86 d6 00 00 00    	jbe    802420 <__umoddi3+0x140>
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	89 ca                	mov    %ecx,%edx
  80234e:	83 c4 1c             	add    $0x1c,%esp
  802351:	5b                   	pop    %ebx
  802352:	5e                   	pop    %esi
  802353:	5f                   	pop    %edi
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    
  802356:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	89 fd                	mov    %edi,%ebp
  802362:	85 ff                	test   %edi,%edi
  802364:	75 0b                	jne    802371 <__umoddi3+0x91>
  802366:	b8 01 00 00 00       	mov    $0x1,%eax
  80236b:	31 d2                	xor    %edx,%edx
  80236d:	f7 f7                	div    %edi
  80236f:	89 c5                	mov    %eax,%ebp
  802371:	89 d8                	mov    %ebx,%eax
  802373:	31 d2                	xor    %edx,%edx
  802375:	f7 f5                	div    %ebp
  802377:	89 f0                	mov    %esi,%eax
  802379:	f7 f5                	div    %ebp
  80237b:	89 d0                	mov    %edx,%eax
  80237d:	31 d2                	xor    %edx,%edx
  80237f:	eb 8c                	jmp    80230d <__umoddi3+0x2d>
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	ba 20 00 00 00       	mov    $0x20,%edx
  80238f:	29 ea                	sub    %ebp,%edx
  802391:	d3 e0                	shl    %cl,%eax
  802393:	89 44 24 08          	mov    %eax,0x8(%esp)
  802397:	89 d1                	mov    %edx,%ecx
  802399:	89 f8                	mov    %edi,%eax
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a9:	09 c1                	or     %eax,%ecx
  8023ab:	89 d8                	mov    %ebx,%eax
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 e9                	mov    %ebp,%ecx
  8023b3:	d3 e7                	shl    %cl,%edi
  8023b5:	89 d1                	mov    %edx,%ecx
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023bf:	d3 e3                	shl    %cl,%ebx
  8023c1:	89 c7                	mov    %eax,%edi
  8023c3:	89 d1                	mov    %edx,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e8                	shr    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	89 fa                	mov    %edi,%edx
  8023cd:	d3 e6                	shl    %cl,%esi
  8023cf:	09 d8                	or     %ebx,%eax
  8023d1:	f7 74 24 08          	divl   0x8(%esp)
  8023d5:	89 d1                	mov    %edx,%ecx
  8023d7:	89 f3                	mov    %esi,%ebx
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)
  8023dd:	89 c6                	mov    %eax,%esi
  8023df:	89 d7                	mov    %edx,%edi
  8023e1:	39 d1                	cmp    %edx,%ecx
  8023e3:	72 06                	jb     8023eb <__umoddi3+0x10b>
  8023e5:	75 10                	jne    8023f7 <__umoddi3+0x117>
  8023e7:	39 c3                	cmp    %eax,%ebx
  8023e9:	73 0c                	jae    8023f7 <__umoddi3+0x117>
  8023eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023f3:	89 d7                	mov    %edx,%edi
  8023f5:	89 c6                	mov    %eax,%esi
  8023f7:	89 ca                	mov    %ecx,%edx
  8023f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023fe:	29 f3                	sub    %esi,%ebx
  802400:	19 fa                	sbb    %edi,%edx
  802402:	89 d0                	mov    %edx,%eax
  802404:	d3 e0                	shl    %cl,%eax
  802406:	89 e9                	mov    %ebp,%ecx
  802408:	d3 eb                	shr    %cl,%ebx
  80240a:	d3 ea                	shr    %cl,%edx
  80240c:	09 d8                	or     %ebx,%eax
  80240e:	83 c4 1c             	add    $0x1c,%esp
  802411:	5b                   	pop    %ebx
  802412:	5e                   	pop    %esi
  802413:	5f                   	pop    %edi
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    
  802416:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80241d:	8d 76 00             	lea    0x0(%esi),%esi
  802420:	29 fe                	sub    %edi,%esi
  802422:	19 c3                	sbb    %eax,%ebx
  802424:	89 f2                	mov    %esi,%edx
  802426:	89 d9                	mov    %ebx,%ecx
  802428:	e9 1d ff ff ff       	jmp    80234a <__umoddi3+0x6a>
